/* cc_net: non-blocking TCP sockets (contracts/shim-abi.md §3). Glue only: BSD sockets need
 * struct sockaddr / addrinfo / pollfd layouts, variadic fcntl and errno, which COBOL cannot use
 * cleanly (shim-abi §1 table).
 *
 * A handle is the socket's file descriptor plus 1, so handles are positive. Every connection has
 * O_NONBLOCK, TCP_NODELAY and SO_NOSIGPIPE (a send to a closed peer returns EPIPE instead of raising
 * SIGPIPE). Failures that are not a defined outcome of §3 go through cc_fatal. */
#include <errno.h>
#include <fcntl.h>
#include <netdb.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#include "ccshim.h"

/* Connection state per file descriptor: what cc_net_status and cc_net_poll need to know. */
enum { ST_NONE = 0, ST_LISTENER, ST_CONNECTING, ST_CONNECTED, ST_FAILED };
#define MAX_FD 4096
static unsigned char state[MAX_FD];

static int fd_of(int32_t h) {
    int fd = h - 1;
    if (fd < 0 || fd >= MAX_FD) cc_fatal("cc_net: invalid handle");
    return fd;
}

static int32_t track(int fd, int st) {
    if (fd >= MAX_FD) cc_fatal("cc_net: too many open sockets");
    state[fd] = (unsigned char)st;
    return fd + 1;
}

static void set_nonblocking(int fd) {
    int flags = fcntl(fd, F_GETFL, 0);
    if (flags < 0 || fcntl(fd, F_SETFL, flags | O_NONBLOCK) < 0) cc_fatal("cc_net: fcntl O_NONBLOCK failed");
}

static void set_option(int fd, int level, int name) {
    int on = 1;
    if (setsockopt(fd, level, name, &on, sizeof on) < 0) cc_fatal("cc_net: setsockopt failed");
}

static void prepare_connection(int fd) {
    set_nonblocking(fd);
    set_option(fd, IPPROTO_TCP, TCP_NODELAY);
    set_option(fd, SOL_SOCKET, SO_NOSIGPIPE);
}

int32_t cc_net_listen(int32_t port, int32_t *handle_out, int32_t *port_out) {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) cc_fatal("cc_net_listen: socket failed");
    set_option(fd, SOL_SOCKET, SO_REUSEADDR);
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof addr);
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons((uint16_t)port);
    if (bind(fd, (struct sockaddr *)&addr, sizeof addr) < 0) {
        if (errno != EADDRINUSE) cc_fatal("cc_net_listen: bind failed");
        close(fd);
        return CC_ADDR_IN_USE;
    }
    if (listen(fd, SOMAXCONN) < 0) cc_fatal("cc_net_listen: listen failed");
    set_nonblocking(fd);
    socklen_t length = sizeof addr;
    if (getsockname(fd, (struct sockaddr *)&addr, &length) < 0) cc_fatal("cc_net_listen: getsockname failed");
    *port_out = ntohs(addr.sin_port);
    *handle_out = track(fd, ST_LISTENER);
    return 0;
}

int32_t cc_net_accept(int32_t listener, int32_t *handle_out) {
    int fd = accept(fd_of(listener), NULL, NULL);
    if (fd < 0) {
        if (errno != EAGAIN && errno != ECONNABORTED) cc_fatal("cc_net_accept: accept failed");
        return CC_AGAIN;
    }
    prepare_connection(fd);
    *handle_out = track(fd, ST_CONNECTED);
    return 0;
}

int32_t cc_net_connect(const char *host, int32_t port, int32_t *handle_out) {
    struct addrinfo hints;
    struct addrinfo *found = NULL;
    char service[16];
    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    snprintf(service, sizeof service, "%d", (int)port);
    if (getaddrinfo(host, service, &hints, &found) != 0) return CC_UNRESOLVED;
    int fd = socket(found->ai_family, found->ai_socktype, found->ai_protocol);
    if (fd < 0) cc_fatal("cc_net_connect: socket failed");
    prepare_connection(fd);
    int started = connect(fd, found->ai_addr, found->ai_addrlen) == 0 || errno == EINPROGRESS;
    freeaddrinfo(found);
    /* An immediate refusal is still "started": cc_net_status reports it as CC_CLOSED (§3). */
    *handle_out = track(fd, started ? ST_CONNECTING : ST_FAILED);
    return 0;
}

int32_t cc_net_status(int32_t h) {
    int fd = fd_of(h);
    if (state[fd] == ST_CONNECTING) {
        struct pollfd p = {.fd = fd, .events = POLLOUT, .revents = 0};
        if (poll(&p, 1, 0) < 0 && errno != EINTR) cc_fatal("cc_net_status: poll failed");
        if (p.revents == 0) return CC_AGAIN;
        int error = 0;
        socklen_t length = sizeof error;
        if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &length) < 0) cc_fatal("cc_net_status: getsockopt failed");
        state[fd] = error == 0 ? ST_CONNECTED : ST_FAILED;
    }
    return state[fd] == ST_FAILED ? CC_CLOSED : 0;
}

/* errno values that mean the peer closed or reset the connection (§3 CC_CLOSED). */
static int is_closed_error(int error) {
    return error == EPIPE || error == ECONNRESET || error == ENOTCONN || error == ETIMEDOUT;
}

int32_t cc_net_send(int32_t h, const uint8_t *buf, int32_t len, int32_t *sent_out) {
    ssize_t n = send(fd_of(h), buf, (size_t)len, 0);
    *sent_out = n > 0 ? (int32_t)n : 0;
    if (n >= 0 || errno == EAGAIN) return 0;
    if (!is_closed_error(errno)) cc_fatal("cc_net_send: send failed");
    return CC_CLOSED;
}

int32_t cc_net_recv(int32_t h, uint8_t *buf, int32_t cap, int32_t *got_out) {
    ssize_t n = recv(fd_of(h), buf, (size_t)cap, 0);
    *got_out = n > 0 ? (int32_t)n : 0;
    if (n > 0) return 0;
    if (n < 0 && errno == EAGAIN) return CC_AGAIN;
    if (n < 0 && !is_closed_error(errno)) cc_fatal("cc_net_recv: recv failed");
    return CC_CLOSED;
}

void cc_net_close(int32_t h) {
    int fd = fd_of(h);
    state[fd] = ST_NONE;
    close(fd);
}

int32_t cc_net_poll(int32_t timeout_ms, const int32_t *handles, int32_t count, int32_t include_console,
                    uint8_t *ready_out) {
    struct pollfd *fds = calloc((size_t)count + 1, sizeof *fds);
    if (fds == NULL) cc_fatal("cc_net_poll: out of memory");
    for (int32_t i = 0; i < count; i++) {
        fds[i].fd = fd_of(handles[i]);
        fds[i].events = state[fds[i].fd] == ST_CONNECTING ? POLLOUT : POLLIN;
    }
    /* The console (standard input, read by cc_con_readline) is the extra entry after the handles. */
    nfds_t nfds = (nfds_t)count;
    if (include_console) {
        fds[count].fd = STDIN_FILENO;
        fds[count].events = POLLIN;
        nfds++;
    }
    if (poll(fds, nfds, timeout_ms) < 0 && errno != EINTR) cc_fatal("cc_net_poll: poll failed");
    for (int32_t i = 0; i < count; i++) ready_out[i] = fds[i].revents != 0;
    if (include_console) ready_out[count] = fds[count].revents != 0;
    free(fds);
    return 0;
}
