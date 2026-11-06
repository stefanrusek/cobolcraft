/* cc_tls: TLS 1.2+ client connections (contracts/shim-abi.md §6, research R10). Glue only:
 * SSL_set_tlsext_host_name and SSL_CTX_set_min_proto_version are macros over SSL_ctrl, and the
 * non-blocking handshake needs SSL_get_error mapping, which COBOL cannot use cleanly (shim-abi §1).
 *
 * A TLS handle is the cc_net handle of its TCP connection (cc_net_connect), so cc_net_poll accepts
 * it; cc_tls tells cc_net_poll what the TLS layer waits for through cc_net_tls_events. Each
 * connection gets its own context: OpenSSL 3 (pinned, research R1), default verify paths (system
 * trust, or the file named by the standard SSL_CERT_FILE), peer verification, TLS 1.2 minimum,
 * host-name (or IP address) verification and, for a host name, SNI. Failures that are not a defined
 * outcome of §6 go through cc_fatal. */
#include <arpa/inet.h>
#include <poll.h>
#include <stddef.h>

#include <openssl/err.h>
#include <openssl/ssl.h>

#include "cc_internal.h"
#include "ccshim.h"

/* Progress of one connection: TCP connect, TLS handshake, ready, or failed (§6 CC_CLOSED). */
enum { TLS_CONNECTING = 0, TLS_HANDSHAKING, TLS_READY, TLS_FAILED };

static SSL *sessions[CC_NET_MAX_FD];
static unsigned char phase[CC_NET_MAX_FD];
/* The poll events the TLS layer waits for (0 while the TCP connect runs: cc_net_poll decides). */
static short wanted[CC_NET_MAX_FD];

static int fd_of(int32_t h) {
    int fd = h - 1;
    if (fd < 0 || fd >= CC_NET_MAX_FD || sessions[fd] == NULL) cc_fatal("cc_tls: invalid handle");
    return fd;
}

static short tls_events(int fd, int *buffered) {
    if (sessions[fd] == NULL) return 0;
    *buffered = SSL_has_pending(sessions[fd]);
    return wanted[fd];
}

/* Whether `host` is an IPv4 or IPv6 address literal (no SNI is sent for those, RFC 6066 §3). */
static int is_address(const char *host) {
    unsigned char address[16];
    return inet_pton(AF_INET, host, address) == 1 || inet_pton(AF_INET6, host, address) == 1;
}

int32_t cc_tls_connect(const char *host, int32_t port, int32_t *handle_out) {
    int32_t h = 0;
    if (cc_net_connect(host, port, &h) == CC_UNRESOLVED) return CC_UNRESOLVED;
    SSL_CTX *context = SSL_CTX_new(TLS_client_method());
    if (context == NULL) cc_fatal("cc_tls_connect: SSL_CTX_new failed");
    SSL_CTX_set_verify(context, SSL_VERIFY_PEER, NULL);
    if (SSL_CTX_set_default_verify_paths(context) != 1) cc_fatal("cc_tls_connect: default verify paths failed");
    if (SSL_CTX_set_min_proto_version(context, TLS1_2_VERSION) != 1) cc_fatal("cc_tls_connect: TLS 1.2 minimum failed");
    /* cc_tls_send may report fewer bytes than asked, and is retried with the rest from wherever the
     * caller keeps it. */
    SSL_CTX_set_mode(context, SSL_MODE_ENABLE_PARTIAL_WRITE | SSL_MODE_ACCEPT_MOVING_WRITE_BUFFER);
    SSL *ssl = SSL_new(context);
    SSL_CTX_free(context);
    if (ssl == NULL || SSL_set_fd(ssl, h - 1) != 1) cc_fatal("cc_tls_connect: SSL_new failed");
    if (SSL_set1_host(ssl, host) != 1) cc_fatal("cc_tls_connect: SSL_set1_host failed");
    if (!is_address(host) && SSL_set_tlsext_host_name(ssl, host) != 1) cc_fatal("cc_tls_connect: SNI failed");
    sessions[h - 1] = ssl;
    phase[h - 1] = TLS_CONNECTING;
    wanted[h - 1] = 0;
    cc_net_tls_events = tls_events;
    *handle_out = h;
    return 0;
}

int32_t cc_tls_status(int32_t h) {
    int fd = fd_of(h);
    if (phase[fd] == TLS_CONNECTING) {
        int32_t tcp = cc_net_status(h);
        if (tcp == CC_AGAIN) return CC_AGAIN;
        phase[fd] = tcp == 0 ? TLS_HANDSHAKING : TLS_FAILED;
    }
    if (phase[fd] == TLS_HANDSHAKING) {
        ERR_clear_error();
        int rc = SSL_connect(sessions[fd]);
        int error = SSL_get_error(sessions[fd], rc);
        if (error == SSL_ERROR_WANT_READ || error == SSL_ERROR_WANT_WRITE) {
            wanted[fd] = error == SSL_ERROR_WANT_READ ? POLLIN : POLLOUT;
            return CC_AGAIN;
        }
        phase[fd] = rc == 1 ? TLS_READY : TLS_FAILED;
        wanted[fd] = POLLIN;
    }
    return phase[fd] == TLS_READY ? 0 : CC_CLOSED;
}

/* SSL_get_error outcomes that mean "try again later"; every other failure means the connection is
 * closed (peer close with or without close_notify, reset, protocol error: §3 CC_CLOSED). */
static int is_retry(int error) {
    return error == SSL_ERROR_WANT_READ || error == SSL_ERROR_WANT_WRITE;
}

int32_t cc_tls_send(int32_t h, const uint8_t *buf, int32_t len, int32_t *sent_out) {
    SSL *ssl = sessions[fd_of(h)];
    size_t sent = 0;
    ERR_clear_error();
    int rc = SSL_write_ex(ssl, buf, (size_t)len, &sent);
    *sent_out = (int32_t)sent;
    if (rc == 1 || is_retry(SSL_get_error(ssl, rc))) return 0;
    return CC_CLOSED;
}

int32_t cc_tls_recv(int32_t h, uint8_t *buf, int32_t cap, int32_t *got_out) {
    SSL *ssl = sessions[fd_of(h)];
    size_t got = 0;
    ERR_clear_error();
    int rc = SSL_read_ex(ssl, buf, (size_t)cap, &got);
    *got_out = (int32_t)got;
    if (rc == 1) return 0;
    return is_retry(SSL_get_error(ssl, rc)) ? CC_AGAIN : CC_CLOSED;
}

/* Sends close_notify when it can without waiting, then frees the session and closes the socket. */
void cc_tls_close(int32_t h) {
    int fd = fd_of(h);
    if (phase[fd] == TLS_READY) SSL_shutdown(sessions[fd]);
    ERR_clear_error();
    SSL_free(sessions[fd]);
    sessions[fd] = NULL;
    cc_net_close(h);
}
