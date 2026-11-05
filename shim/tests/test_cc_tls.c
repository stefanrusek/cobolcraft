/* Implementation test of shim/src/cc_tls.c: partial reads and a peer closing mid-stream.
 * - Partial reads: a 64 KiB body read 100 bytes at a time. TLS records are larger than 100 bytes, so
 *   after a read decrypted bytes stay buffered in OpenSSL while the socket has nothing to read;
 *   cc_net_poll must still report the handle ready (without waiting), and every byte arrives in order.
 * - Peer close mid-stream: a peer that closes the TCP connection during the handshake, and a peer
 *   that answers the handshake with bytes that are not TLS, both end in CC_CLOSED; testsrv.py closing
 *   after its response ends the stream with CC_CLOSED. */
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>

#include "ccshim.h"
#include "testlib.h"
#include "tls_testsrv.h"

#define BODY (64 * 1024)
#define PIECE 100

static long long now_ms(void) {
    struct timeval t;
    gettimeofday(&t, NULL);
    return (long long)t.tv_sec * 1000 + t.tv_usec / 1000;
}

static int32_t settle(int32_t h) {
    int32_t rc = CC_AGAIN;
    for (int i = 0; i < 100 && rc == CC_AGAIN; i++) {
        uint8_t ready = 0;
        cc_net_poll(100, &h, 1, 0, &ready);
        rc = cc_tls_status(h);
    }
    return rc;
}

static void partial_reads(void) {
    char dir[] = "/tmp/cc_tls_partial.XXXXXX";
    mkdtemp(dir);
    char file[600];
    snprintf(file, sizeof file, "%s/body.bin", dir);
    uint8_t *data = malloc(BODY);
    for (int i = 0; i < BODY; i++) data[i] = (uint8_t)(i * 13 + i / 97);
    FILE *f = fopen(file, "wb");
    fwrite(data, 1, BODY, f);
    fclose(f);
    pid_t server = 0;
    int port = testsrv_start(dir, &server);

    int32_t h = 0, sent = 0, got = 0, rc = 0;
    cc_tls_connect("127.0.0.1", port, &h);
    settle(h);
    static const char request[] = "GET /body.bin HTTP/1.1\r\nHost: 127.0.0.1\r\nConnection: close\r\n\r\n";
    cc_tls_send(h, (const uint8_t *)request, (int32_t)strlen(request), &sent);

    uint8_t *received = malloc(BODY + 4096);
    int32_t have = 0, largest = 0, buffered_ready = 1;
    long long slowest = 0;
    rc = CC_AGAIN;
    while (rc != CC_CLOSED && have < BODY + 4096 - PIECE) {
        uint8_t ready = 0;
        long long start = now_ms();
        cc_net_poll(5000, &h, 1, 0, &ready);
        long long waited = now_ms() - start;
        rc = cc_tls_recv(h, received + have, PIECE, &got);
        if (rc == 0) {
            /* After a full piece the record is usually not used up: the next poll must not wait. */
            if (got == PIECE && waited > slowest) slowest = waited;
            buffered_ready &= ready;
            have += got;
            if (got > largest) largest = got;
        }
    }
    tl_int("test cc_tls_recv never returns more than cap", PIECE, largest);
    tl_int("test cc_net_poll reports a TLS handle with buffered bytes ready", 1, buffered_ready);
    tl_int("test cc_net_poll does not wait for a TLS handle with buffered bytes", 1, slowest < 1000);
    tl_int("test cc_tls_recv ends with CC_CLOSED when the server closes after its response", CC_CLOSED, rc);
    tl_int("test cc_tls partial reads deliver every body byte in order", 1,
           have >= BODY && memcmp(received + have - BODY, data, BODY) == 0);
    cc_tls_close(h);
    testsrv_stop(server);
    free(received);
    free(data);
    remove(file);
    rmdir(dir);
}

/* A TCP peer (cc_net listener) that accepts the TLS client's connection and then, with
 * `reply` NULL, closes it, or otherwise sends `reply` (not TLS) and keeps it open. */
static int32_t broken_peer(const char *reply) {
    int32_t listener = 0, port = 0, h = 0, peer = 0, sent = 0;
    uint8_t ready = 0;
    cc_net_listen(0, &listener, &port);
    cc_tls_connect("127.0.0.1", port, &h);
    cc_net_poll(2000, &listener, 1, 0, &ready);
    cc_net_accept(listener, &peer);
    if (reply == NULL) {
        cc_net_close(peer);
    } else {
        uint8_t hello[512];
        int32_t got = 0;
        cc_net_poll(2000, &peer, 1, 0, &ready);
        cc_tls_status(h);
        cc_net_poll(2000, &peer, 1, 0, &ready);
        cc_net_recv(peer, hello, sizeof hello, &got);
        cc_net_send(peer, (const uint8_t *)reply, (int32_t)strlen(reply), &sent);
    }
    int32_t rc = settle(h);
    cc_tls_close(h);
    if (reply != NULL) cc_net_close(peer);
    cc_net_close(listener);
    return rc;
}

int main(void) {
    testsrv_trust_ca();
    partial_reads();
    tl_int("test cc_tls_status when the peer closes during the handshake returns CC_CLOSED", CC_CLOSED,
           broken_peer(NULL));
    tl_int("test cc_tls_status when the peer answers with bytes that are not TLS returns CC_CLOSED", CC_CLOSED,
           broken_peer("HTTP/1.1 400 Bad Request\r\n\r\n"));
    return 0;
}
