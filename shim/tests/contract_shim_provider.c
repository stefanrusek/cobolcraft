/* Contract test, provider side of contracts/shim-abi.md (§3 cc_net, §5 cc_zlib, §6 cc_tls, §7 cc_fs,
 * §8 cc_win, §9 cc_vk, §10 cc_f64):
 * every function against the real libraries (loopback sockets, real zlib, OpenSSL against
 * tools/testsrv/testsrv.py over HTTPS with SSL_CERT_FILE at its test CA, a hidden GLFW window,
 * MoltenVK), asserting the return codes and outputs the contract states. cc_fatal (§2) is the
 * fatal-path program contract_shim_fatal.c. */
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "f64_vectors.h"
#include "testlib.h"
#include "tls_testsrv.h"

/* Polls `h` (up to 2 s) until cc_net_poll reports it ready; returns the ready flag. */
static int wait_ready(int32_t h) {
    uint8_t ready = 0;
    for (int i = 0; i < 20 && !ready; i++) cc_net_poll(100, &h, 1, 0, &ready);
    return ready;
}

/* A connected pair over loopback: *client from cc_net_connect, *server from cc_net_accept. */
static void connected_pair(int32_t listener, int32_t port, int32_t *client, int32_t *server) {
    cc_net_connect("127.0.0.1", port, client);
    wait_ready(*client);
    wait_ready(listener);
    cc_net_accept(listener, server);
}

static void net_listen_accept(void) {
    int32_t listener = 0, port = 0, again = 0, other = 0, client = 0, server = 0;
    int32_t rc = cc_net_listen(0, &listener, &port);
    tl_int("contract shim cc_net_listen port 0 returns 0", 0, rc);
    tl_int("contract shim cc_net_listen port 0 returns a positive handle", 1, listener > 0);
    tl_int("contract shim cc_net_listen port 0 reports the actual port", 1, port > 0 && port < 65536);
    rc = cc_net_listen(port, &other, &again);
    tl_int("contract shim cc_net_listen on a port in use returns CC_ADDR_IN_USE", CC_ADDR_IN_USE, rc);
    rc = cc_net_accept(listener, &server);
    tl_int("contract shim cc_net_accept with no pending client returns CC_AGAIN", CC_AGAIN, rc);
    cc_net_connect("127.0.0.1", port, &client);
    wait_ready(listener);
    rc = cc_net_accept(listener, &server);
    tl_int("contract shim cc_net_accept after a loopback connect returns 0", 0, rc);
    tl_int("contract shim cc_net_accept returns a positive handle", 1, server > 0);
    cc_net_close(server);
    cc_net_close(client);
    cc_net_close(listener);
}

static void net_connect_status(void) {
    int32_t listener = 0, port = 0, client = 0, server = 0, h = 0;
    cc_net_listen(0, &listener, &port);
    int32_t rc = cc_net_connect("127.0.0.1", port, &client);
    tl_int("contract shim cc_net_connect on loopback returns 0 (started)", 0, rc);
    tl_int("contract shim cc_net_connect returns a positive handle", 1, client > 0);
    wait_ready(client);
    tl_int("contract shim cc_net_status of a completed loopback connect returns 0", 0, cc_net_status(client));
    wait_ready(listener);
    cc_net_accept(listener, &server);
    cc_net_close(server);
    cc_net_close(client);
    cc_net_close(listener);

    rc = cc_net_connect("no-such-host.invalid", 25565, &h);
    tl_int("contract shim cc_net_connect to an unresolvable host returns CC_UNRESOLVED", CC_UNRESOLVED, rc);

    /* A port nobody listens on: the listener is closed before connecting. */
    cc_net_listen(0, &listener, &port);
    cc_net_close(listener);
    cc_net_connect("127.0.0.1", port, &client);
    wait_ready(client);
    tl_int("contract shim cc_net_status of a refused connect returns CC_CLOSED", CC_CLOSED, cc_net_status(client));
    cc_net_close(client);

    /* Still connecting: 127.0.0.2 is on the loopback network but not assigned to lo0 on macOS, so the
     * connection attempt gets no answer and stays in progress. */
    cc_net_connect("127.0.0.2", 25565, &h);
    tl_int("contract shim cc_net_status while connecting returns CC_AGAIN", CC_AGAIN, cc_net_status(h));
    cc_net_close(h);
}

static void net_send_recv_close(void) {
    int32_t listener = 0, port = 0, client = 0, server = 0, sent = -1, got = -1;
    uint8_t buffer[64];
    cc_net_listen(0, &listener, &port);
    connected_pair(listener, port, &client, &server);

    int32_t rc = cc_net_recv(server, buffer, sizeof buffer, &got);
    tl_int("contract shim cc_net_recv with no data returns CC_AGAIN", CC_AGAIN, rc);
    rc = cc_net_send(client, (const uint8_t *)"hello", 5, &sent);
    tl_int("contract shim cc_net_send returns 0", 0, rc);
    tl_int("contract shim cc_net_send reports the bytes sent", 5, sent);
    wait_ready(server);
    rc = cc_net_recv(server, buffer, sizeof buffer, &got);
    tl_int("contract shim cc_net_recv with data returns 0", 0, rc);
    tl_bytes("contract shim cc_net_recv delivers the bytes sent", "hello", 5, buffer, (size_t)got);

    cc_net_close(client);
    wait_ready(server);
    rc = cc_net_recv(server, buffer, sizeof buffer, &got);
    tl_int("contract shim cc_net_recv after the peer closed returns CC_CLOSED", CC_CLOSED, rc);
    rc = 0;
    for (int i = 0; i < 50 && rc == 0; i++) {
        rc = cc_net_send(server, (const uint8_t *)"x", 1, &sent);
        usleep(10000);
    }
    tl_int("contract shim cc_net_send to a closed peer returns CC_CLOSED", CC_CLOSED, rc);
    cc_net_close(server);
    cc_net_close(listener);
    rc = cc_net_listen(port, &listener, &port);
    tl_int("contract shim cc_net_close releases the listener's port", 0, rc);
    cc_net_close(listener);
}

static void net_poll(void) {
    int32_t listener = 0, port = 0, client = 0, server = 0, sent = 0;
    uint8_t ready[3] = {9, 9, 9};
    cc_net_listen(0, &listener, &port);
    int32_t rc = cc_net_poll(0, &listener, 1, 0, ready);
    tl_int("contract shim cc_net_poll returns 0", 0, rc);
    tl_int("contract shim cc_net_poll idle listener is not ready", 0, ready[0]);
    cc_net_connect("127.0.0.1", port, &client);
    tl_int("contract shim cc_net_poll connecting handle is ready when connected", 1, wait_ready(client));
    tl_int("contract shim cc_net_poll listener with a pending client is ready", 1, wait_ready(listener));
    cc_net_status(client);
    cc_net_accept(listener, &server);
    int32_t handles[3] = {listener, server, client};
    cc_net_poll(0, handles, 3, 0, ready);
    tl_int("contract shim cc_net_poll connection without data is not ready", 0, ready[1]);
    cc_net_send(client, (const uint8_t *)"ping", 4, &sent);
    tl_int("contract shim cc_net_poll readable connection is ready", 1, wait_ready(server));
    cc_net_poll(0, handles, 3, 0, ready);
    tl_int("contract shim cc_net_poll marks each listed handle", 1, ready[0] == 0 && ready[1] == 1 && ready[2] == 0);
    cc_net_close(server);
    cc_net_close(client);
    cc_net_close(listener);
}

/* Polls the TLS handle and calls cc_tls_status (up to 10 s) until it is no longer CC_AGAIN. */
static int32_t tls_settle(int32_t h) {
    int32_t rc = CC_AGAIN;
    for (int i = 0; i < 100 && rc == CC_AGAIN; i++) {
        uint8_t ready = 0;
        cc_net_poll(100, &h, 1, 0, &ready);
        rc = cc_tls_status(h);
    }
    return rc;
}

/* Receives from the TLS handle into `buf` until the peer closes (or 10 s pass); returns the byte
 * count and leaves the last cc_tls_recv outcome in *last. */
static int32_t tls_read_all(int32_t h, uint8_t *buf, int32_t cap, int32_t *last) {
    int32_t have = 0, got = 0;
    *last = CC_AGAIN;
    for (int i = 0; i < 100 && *last != CC_CLOSED && have < cap; i++) {
        if (!wait_ready(h)) continue;
        *last = cc_tls_recv(h, buf + have, cap - have, &got);
        if (*last == 0) have += got;
    }
    return have;
}

static const char TLS_BODY[] = "CobolCraft over TLS\n";

static void tls(void) {
    char dir[] = "/tmp/cc_tls.XXXXXX";
    mkdtemp(dir);
    char file[600];
    snprintf(file, sizeof file, "%s/hello.txt", dir);
    FILE *f = fopen(file, "w");
    fputs(TLS_BODY, f);
    fclose(f);
    pid_t server = 0;
    int port = testsrv_start(dir, &server);

    int32_t h = 0, sent = -1, got = -1, last = 0;
    uint8_t buffer[1024];
    int32_t rc = cc_tls_connect("127.0.0.1", port, &h);
    tl_int("contract shim cc_tls_connect on loopback returns 0 (started)", 0, rc);
    tl_int("contract shim cc_tls_connect returns a positive handle", 1, h > 0);
    tl_int("contract shim cc_tls_status with the test CA trusted returns 0 (ready)", 0, tls_settle(h));
    rc = cc_tls_recv(h, buffer, sizeof buffer, &got);
    tl_int("contract shim cc_tls_recv with no data returns CC_AGAIN", CC_AGAIN, rc);
    uint8_t ready = 9;
    cc_net_poll(0, &h, 1, 0, &ready);
    tl_int("contract shim cc_net_poll TLS handle without data is not ready", 0, ready);
    static const char request[] = "GET /hello.txt HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n";
    rc = cc_tls_send(h, (const uint8_t *)request, (int32_t)strlen(request), &sent);
    tl_int("contract shim cc_tls_send returns 0", 0, rc);
    tl_int("contract shim cc_tls_send reports the bytes sent", (long long)strlen(request), sent);
    tl_int("contract shim cc_net_poll TLS handle with a response is ready", 1, wait_ready(h));
    int32_t have = tls_read_all(h, buffer, sizeof buffer, &last);
    buffer[have < (int32_t)sizeof buffer ? have : (int32_t)sizeof buffer - 1] = 0;
    tl_int("contract shim cc_tls_recv delivers the response status line", 0,
           strncmp((const char *)buffer, "HTTP/1.1 200", 12));
    size_t body = strlen(TLS_BODY);
    tl_bytes("contract shim cc_tls_recv delivers the response body", TLS_BODY, body,
             have >= (int32_t)body ? buffer + have - body : buffer, have >= (int32_t)body ? body : (size_t)have);
    tl_int("contract shim cc_tls_recv after the peer closed returns CC_CLOSED", CC_CLOSED, last);
    rc = 0;
    for (int i = 0; i < 50 && rc == 0; i++) {
        rc = cc_tls_send(h, (const uint8_t *)"x", 1, &sent);
        usleep(10000);
    }
    tl_int("contract shim cc_tls_send to a closed peer returns CC_CLOSED", CC_CLOSED, rc);
    cc_tls_close(h);
    tl_int("contract shim cc_tls_close completes", 1, 1);

    rc = cc_tls_connect("no-such-host.invalid", port, &h);
    tl_int("contract shim cc_tls_connect to an unresolvable host returns CC_UNRESOLVED", CC_UNRESOLVED, rc);

    /* "127.1" resolves to 127.0.0.1 but is a host name the test certificate (localhost, 127.0.0.1)
     * does not list. */
    cc_tls_connect("127.1", port, &h);
    tl_int("contract shim cc_tls_status on a host-name mismatch returns CC_CLOSED", CC_CLOSED, tls_settle(h));
    cc_tls_close(h);

    setenv("SSL_CERT_FILE", "/dev/null", 1);
    cc_tls_connect("127.0.0.1", port, &h);
    tl_int("contract shim cc_tls_status with SSL_CERT_FILE=/dev/null returns CC_CLOSED", CC_CLOSED, tls_settle(h));
    cc_tls_close(h);
    testsrv_trust_ca();

    testsrv_stop(server);
    cc_tls_connect("127.0.0.1", port, &h);
    tl_int("contract shim cc_tls_status of a refused connect returns CC_CLOSED", CC_CLOSED, tls_settle(h));
    cc_tls_close(h);

    cc_tls_connect("127.0.0.2", 443, &h);
    tl_int("contract shim cc_tls_status while connecting returns CC_AGAIN", CC_AGAIN, cc_tls_status(h));
    cc_tls_close(h);

    remove(file);
    rmdir(dir);
}

/* Whether `text` (length `n`) is a dotted IPv4 address: four decimal parts 0 to 255. */
static int is_dotted_ipv4(const char *text, size_t n) {
    int parts = 0, digits = 0, value = 0;
    for (size_t i = 0; i <= n; i++) {
        if (i == n || text[i] == '.') {
            if (digits == 0 || value > 255) return 0;
            parts++;
            digits = value = 0;
        } else if (text[i] >= '0' && text[i] <= '9' && digits < 3) {
            value = value * 10 + (text[i] - '0');
            digits++;
        } else {
            return 0;
        }
    }
    return parts == 4;
}

/* cc_net_local_addresses (US17-1): the count, one dotted IPv4 entry per line, never 127.0.0.1. */
static void net_local_addresses(void) {
    char out[4096];
    memset(out, 0, sizeof out);
    int32_t count = cc_net_local_addresses((uint8_t *)out, (int32_t)sizeof out - 1);
    tl_int("contract shim cc_net_local_addresses returns a non-negative count", 1, count >= 0);
    int lines = 0, dotted = 1, loopback = 0;
    for (char *line = out; *line != '\0'; lines++) {
        char *end = strchr(line, '\n');
        size_t n = end ? (size_t)(end - line) : strlen(line);
        dotted = dotted && is_dotted_ipv4(line, n);
        loopback = loopback || (n == 9 && memcmp(line, "127.0.0.1", 9) == 0);
        line += end ? n + 1 : n;
    }
    tl_int("contract shim cc_net_local_addresses returns the number of entries written", count, lines);
    tl_int("contract shim cc_net_local_addresses writes every entry as a dotted IPv4 string", 1, dotted);
    tl_int("contract shim cc_net_local_addresses never lists 127.0.0.1", 0, loopback);
    count = cc_net_local_addresses((uint8_t *)out, 0);
    tl_int("contract shim cc_net_local_addresses with no room writes no entry", 0, count);
}

/* include_console = 1: ready_out[count] reports whether standard input has input. Standard input is
 * replaced by a pipe for these cases (and restored afterwards), so "no input" can be observed. */
static void net_poll_console(void) {
    int32_t listener = 0, port = 0;
    int pipe_fds[2];
    int saved_stdin = dup(STDIN_FILENO);
    pipe(pipe_fds);
    dup2(pipe_fds[0], STDIN_FILENO);
    cc_net_listen(0, &listener, &port);
    uint8_t ready[2] = {9, 9};
    int32_t rc = cc_net_poll(0, &listener, 1, 1, ready);
    tl_int("contract shim cc_net_poll include_console returns 0", 0, rc);
    tl_int("contract shim cc_net_poll include_console without console input sets ready_out[count] to 0", 0, ready[1]);
    tl_int("contract shim cc_net_poll include_console still marks the handles", 0, ready[0]);
    write(pipe_fds[1], "stop\n", 5);
    cc_net_poll(1000, &listener, 1, 1, ready);
    tl_int("contract shim cc_net_poll include_console with console input sets ready_out[count] to 1", 1, ready[1]);
    uint8_t console_only = 9;
    cc_net_poll(1000, NULL, 0, 1, &console_only);
    tl_int("contract shim cc_net_poll with no handles and console input sets ready_out[0] to 1", 1, console_only);
    ready[1] = 9;
    cc_net_poll(0, &listener, 1, 0, ready);
    tl_int("contract shim cc_net_poll include_console 0 leaves ready_out[count] untouched", 9, ready[1]);
    cc_net_close(listener);
    dup2(saved_stdin, STDIN_FILENO);
    close(saved_stdin);
    close(pipe_fds[0]);
    close(pipe_fds[1]);
}

static const char *TEXT = "CobolCraft compresses this text, CobolCraft compresses this text, again and again.";

static void zlib_deflate(void) {
    uint8_t out[256];
    int32_t length = 0;
    int32_t inlen = (int32_t)strlen(TEXT);
    int32_t rc = cc_deflate(CC_ZLIB, (const uint8_t *)TEXT, inlen, out, sizeof out, &length);
    tl_int("contract shim cc_deflate CC_ZLIB returns 0", 0, rc);
    tl_bytes("contract shim cc_deflate CC_ZLIB starts with the level-6 zlib header 789c", "\x78\x9c", 2, out, 2);
    rc = cc_deflate(CC_GZIP, (const uint8_t *)TEXT, inlen, out, sizeof out, &length);
    tl_int("contract shim cc_deflate CC_GZIP returns 0", 0, rc);
    tl_bytes("contract shim cc_deflate CC_GZIP starts with the gzip magic 1f8b", "\x1f\x8b", 2, out, 2);
    rc = cc_deflate(CC_RAW, (const uint8_t *)TEXT, inlen, out, sizeof out, &length);
    tl_int("contract shim cc_deflate CC_RAW returns 0", 0, rc);
    tl_int("contract shim cc_deflate CC_RAW output has no zlib or gzip header", 1,
           length > 0 && !(out[0] == 0x78 && out[1] == 0x9c) && !(out[0] == 0x1f && out[1] == 0x8b));
    rc = cc_deflate(CC_ZLIB, (const uint8_t *)TEXT, inlen, out, 4, &length);
    tl_int("contract shim cc_deflate on a short output buffer returns CC_SMALL", CC_SMALL, rc);
}

static void zlib_inflate(void) {
    static const char *names[] = {"CC_ZLIB", "CC_GZIP", "CC_RAW"};
    uint8_t packed[256], plain[256];
    int32_t packed_length = 0, plain_length = 0;
    int32_t inlen = (int32_t)strlen(TEXT);
    char name[128];
    for (int32_t mode = CC_ZLIB; mode <= CC_RAW; mode++) {
        cc_deflate(mode, (const uint8_t *)TEXT, inlen, packed, sizeof packed, &packed_length);
        int32_t rc = cc_inflate(mode, packed, packed_length, plain, sizeof plain, &plain_length);
        snprintf(name, sizeof name, "contract shim cc_inflate %s round trip returns 0", names[mode]);
        tl_int(name, 0, rc);
        snprintf(name, sizeof name, "contract shim cc_inflate %s round trip restores the input", names[mode]);
        tl_bytes(name, TEXT, (size_t)inlen, plain, (size_t)plain_length);
    }
    cc_deflate(CC_ZLIB, (const uint8_t *)TEXT, inlen, packed, sizeof packed, &packed_length);
    int32_t rc = cc_inflate(CC_ZLIB, packed, packed_length, plain, 10, &plain_length);
    tl_int("contract shim cc_inflate on a short output buffer returns CC_SMALL", CC_SMALL, rc);
    packed[2] ^= 0xff;
    packed[3] ^= 0xff;
    rc = cc_inflate(CC_ZLIB, packed, packed_length, plain, sizeof plain, &plain_length);
    tl_int("contract shim cc_inflate on corrupt input returns CC_BADDATA", CC_BADDATA, rc);
}

/* Creates `name` under `dir`: a directory when is_dir, otherwise an empty file. */
static void make_entry(const char *dir, const char *name, int is_dir) {
    char path[512];
    snprintf(path, sizeof path, "%s/%s", dir, name);
    if (is_dir) {
        mkdir(path, 0700);
    } else {
        FILE *f = fopen(path, "w");
        fclose(f);
    }
}

static void fs_list(void) {
    char dir[] = "/tmp/cc_fs_list.XXXXXX";
    mkdtemp(dir);
    /* Created out of order; "B" < "_" < "a" < "\xc3\xa9" in byte order. */
    make_entry(dir, "a.txt", 0);
    make_entry(dir, "\xc3\xa9t\xc3\xa9", 1);
    make_entry(dir, "Beta", 1);
    make_entry(dir, "_x", 0);
    static const char expected[] = "DBeta\nF_x\nFa.txt\nD\xc3\xa9t\xc3\xa9\n";
    uint8_t out[256];
    int32_t count = -1;
    int32_t rc = cc_fs_list(dir, out, sizeof out, &count);
    tl_int("contract shim cc_fs_list on a directory returns 0", 0, rc);
    tl_int("contract shim cc_fs_list count is the number of entries without . and ..", 4, count);
    tl_bytes("contract shim cc_fs_list writes F and D entries in byte order, one per line", expected,
             strlen(expected), out, strlen(expected));
    rc = cc_fs_list(dir, out, (int32_t)strlen(expected), &count);
    tl_int("contract shim cc_fs_list fits a listing of exactly cap bytes", 0, rc);
    rc = cc_fs_list(dir, out, (int32_t)strlen(expected) - 1, &count);
    tl_int("contract shim cc_fs_list on a short output buffer returns CC_SMALL", CC_SMALL, rc);
    char missing[600];
    snprintf(missing, sizeof missing, "%s/absent", dir);
    rc = cc_fs_list(missing, out, sizeof out, &count);
    tl_int("contract shim cc_fs_list on an absent directory returns CC_NOTFOUND", CC_NOTFOUND, rc);
    char empty[600];
    snprintf(empty, sizeof empty, "%s/Beta", dir);
    rc = cc_fs_list(empty, out, sizeof out, &count);
    tl_int("contract shim cc_fs_list on an empty directory returns 0", 0, rc);
    tl_int("contract shim cc_fs_list on an empty directory counts 0 entries", 0, count);
    static const char *const names[] = {"a.txt", "\xc3\xa9t\xc3\xa9", "Beta", "_x"};
    for (int i = 0; i < 4; i++) {
        snprintf(missing, sizeof missing, "%s/%s", dir, names[i]);
        remove(missing);
    }
    rmdir(dir);
}

static void window(void) {
    int32_t rc = cc_win_open(320, 240, "contract_shim_provider", 0);
    tl_int("contract shim cc_win_open hidden window returns 0", 0, rc);
    tl_int("contract shim cc_win_open creates a window", 1, cc_win_window != NULL);

    int32_t win_w = 0, win_h = 0, fb_w = 0, fb_h = 0;
    cc_win_size(&win_w, &win_h, &fb_w, &fb_h);
    tl_int("contract shim cc_win_size reports the window size", 1, win_w == 320 && win_h == 240);
    tl_int("contract shim cc_win_size framebuffer is at least the window size", 1, fb_w >= win_w && fb_h >= win_h);

    cc_win_capture_cursor(1);
    tl_int("contract shim cc_win_capture_cursor 1 hides and locks the cursor", GLFW_CURSOR_DISABLED,
           glfwGetInputMode(cc_win_window, GLFW_CURSOR));
    cc_win_capture_cursor(0);
    tl_int("contract shim cc_win_capture_cursor 0 releases the cursor", GLFW_CURSOR_NORMAL,
           glfwGetInputMode(cc_win_window, GLFW_CURSOR));

    uint8_t events[24 * 64];
    int32_t count = -1;
    rc = cc_win_poll(events, sizeof events, &count);
    tl_int("contract shim cc_win_poll returns 0", 0, rc);
    int well_formed = count >= 0 && count <= 64;
    for (int32_t i = 0; i < count && well_formed; i++) {
        cc_event e;
        memcpy(&e, events + 24 * i, sizeof e);
        well_formed = e.kind >= CC_EV_KEY_DOWN && e.kind <= CC_EV_CLOSE_REQUEST;
    }
    tl_int("contract shim cc_win_poll returns 0 events or well-formed 24-byte records", 1, well_formed);
}

/* One textured quad (two triangles) covering the clip-space square [-0.5, 0.5]. */
static const float QUAD[6 * 11] = {
    -0.5f, -0.5f, 0.5f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, -0.5f, 0.5f, 1, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.5f, 1, 1, 1, 1, 0, 1, 1, 1,
    -0.5f, -0.5f, 0.5f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.5f, 1, 1, 1, 1, 0, 1, 1, 1,  -0.5f, 0.5f, 0.5f, 0, 1, 1, 1, 0, 1, 1, 1,
};
static const float IDENTITY[16] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};

static void vulkan(void) {
    int32_t rc = cc_vk_init();
    tl_int("contract shim cc_vk_init on a hidden window returns 0", 0, rc);

    uint8_t rgba[4 * 4 * 4];
    memset(rgba, 0x80, sizeof rgba);
    char name[128];
    for (int32_t id = CC_TEX_BLOCKS; id <= CC_TEX_ENVIRONMENT; id++) {
        snprintf(name, sizeof name, "contract shim cc_vk_texture id %d returns 0", (int)id);
        tl_int(name, 0, cc_vk_texture(id, 4, 4, rgba));
    }
    tl_int("contract shim cc_vk_texture replacing a texture returns 0", 0, cc_vk_texture(CC_TEX_BLOCKS, 4, 4, rgba));
    tl_int("contract shim cc_vk_texture_wrap repeat returns 0", 0, cc_vk_texture_wrap(CC_TEX_ENVIRONMENT, CC_WRAP_REPEAT));
    tl_int("contract shim cc_vk_texture after repeat wrap returns 0", 0, cc_vk_texture(CC_TEX_ENVIRONMENT, 4, 4, rgba));
    tl_int("contract shim cc_vk_texture_wrap clamp returns 0", 0, cc_vk_texture_wrap(CC_TEX_ENVIRONMENT, CC_WRAP_CLAMP));

    tl_int("contract shim cc_vk_texture_ex with 1 level returns 0", 0, cc_vk_texture_ex(CC_TEX_BLOCKS, 4, 4, rgba, 1));
    tl_int("contract shim cc_vk_texture_ex with 3 levels returns 0", 0, cc_vk_texture_ex(CC_TEX_BLOCKS, 4, 4, rgba, 3));
    tl_int("contract shim cc_vk_texture_ex with 3 levels on the repeat texture returns 0", 0, cc_vk_texture_ex(CC_TEX_ENVIRONMENT, 4, 4, rgba, 3));
    tl_int("contract shim cc_vk_texture_update of a rectangle returns 0", 0, cc_vk_texture_update(CC_TEX_BLOCKS, 1, 2, 3, 2, rgba));
    tl_int("contract shim cc_vk_texture_update of the whole texture returns 0", 0, cc_vk_texture_update(CC_TEX_BLOCKS, 0, 0, 4, 4, rgba));
    tl_int("contract shim cc_vk_mesh create returns 0", 0, cc_vk_mesh(1, QUAD, 6));
    tl_int("contract shim cc_vk_mesh replace returns 0", 0, cc_vk_mesh(1, QUAD, 3));
    tl_int("contract shim cc_vk_mesh free returns 0", 0, cc_vk_mesh(1, NULL, 0));
    tl_int("contract shim cc_vk_mesh highest slot returns 0", 0, cc_vk_mesh(CC_MESH_SLOT_MAX, QUAD, 6));

    {
        const float half = 0.5f, full = 1.0f;
        cc_vk_daylight(&half);
        cc_vk_daylight(&full);
        tl_int("contract shim cc_vk_daylight takes a pointer to the factor and returns", 1, 1);
    }
    static const char *pipes[] = {"opaque", "translucent", "ui", "crumbling"};
    const float clear[4] = {0, 0, 0, 1};
    for (int32_t p = CC_PIPE_OPAQUE; p <= CC_PIPE_CRUMBLING; p++) {
        rc = cc_vk_frame_begin(clear);
        snprintf(name, sizeof name, "contract shim cc_vk_frame_begin returns 0 (%s frame)", pipes[p]);
        tl_int(name, 0, rc);
        cc_vk_draw(CC_MESH_SLOT_MAX, p, CC_TEX_BLOCKS, IDENTITY);
        cc_vk_frame_end();
        snprintf(name, sizeof name, "contract shim cc_vk_draw and cc_vk_frame_end with the %s pipeline complete", pipes[p]);
        tl_int(name, 1, 1);
    }
    cc_vk_shutdown();
    tl_int("contract shim cc_vk_shutdown completes", 1, 1);
}

/* §12 cc_open_path: an opener that exists returns 0 at once, a missing one CC_NOTFOUND. */
static void open_path(void) {
    tl_int("contract shim cc_open_path with an existing opener returns 0", 0, cc_open_path("/usr/bin/true", "/tmp"));
    tl_int("contract shim cc_open_path with a missing opener returns CC_NOTFOUND", CC_NOTFOUND,
           cc_open_path("/nonexistent/opener", "/tmp"));
}

/* §10 cc_f64: every function, operands and result by reference, against the IEEE vectors of
 * f64_vectors.txt computed independently (Python struct and math); the call shapes of the contract. */
static void f64(void) {
    double a = 0.1, b = 0.2, r = 0;
    cc_f64_add(&a, &b, &r);
    tl_int("contract shim cc_f64_add 0.1 + 0.2 is 3FD3333333333334", 0x3FD3333333333334LL, (long long)f64_bits_of(r));
    cc_f64_from_text("0.1", &a);
    cc_f64_from_text("0.2", &b);
    cc_f64_add(&a, &b, &r);
    tl_int("contract shim cc_f64_from_text operands add to the IEEE sum", 0x3FD3333333333334LL, (long long)f64_bits_of(r));
    f64_run_group(G_ARITH);
    f64_run_group(G_LIBM);
}

int main(void) {
    f64();
    net_listen_accept();
    net_connect_status();
    net_send_recv_close();
    net_poll();
    net_poll_console();
    net_local_addresses();
    tls();
    zlib_deflate();
    zlib_inflate();
    fs_list();
    open_path();
    window();
    vulkan();
    cc_win_close();
    tl_int("contract shim cc_win_close destroys the window", 1, cc_win_window == NULL);
    return 0;
}
