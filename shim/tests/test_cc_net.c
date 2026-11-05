/* Implementation test of shim/src/cc_net.c: partial sends. When the peer does not read, the socket
 * buffers fill: cc_net_send then reports fewer bytes sent than asked, and finally 0 bytes (still
 * return code 0, "nothing sent now"); everything sent arrives intact once the peer reads. */
#include <stdlib.h>
#include <string.h>

#include "ccshim.h"
#include "testlib.h"

#define CHUNK (1 << 20)

int main(void) {
    int32_t listener, port, client, server, ready_handle;
    uint8_t ready;
    cc_net_listen(0, &listener, &port);
    cc_net_connect("127.0.0.1", port, &client);
    ready_handle = client;
    cc_net_poll(2000, &ready_handle, 1, 0, &ready);
    cc_net_status(client);
    cc_net_poll(2000, &listener, 1, 0, &ready);
    cc_net_accept(listener, &server);

    uint8_t *data = malloc(CHUNK);
    for (int i = 0; i < CHUNK; i++) data[i] = (uint8_t)(i * 7 + i / 251);
    int32_t sent = 0, total = 0, rc = 0, partial = 0;
    while (rc == 0 && total < CHUNK) {
        rc = cc_net_send(client, data + total, CHUNK - total, &sent);
        partial |= sent < CHUNK - total;
        total += sent;
        if (sent == 0) break;
    }
    tl_int("test cc_net_send into full socket buffers returns 0", 0, rc);
    tl_int("test cc_net_send into full socket buffers sends fewer bytes than asked", 1, partial);
    tl_int("test cc_net_send into full socket buffers finally reports 0 bytes sent", 0, sent);

    uint8_t *received = malloc(CHUNK);
    int32_t got = 0, have = 0;
    while (have < total) {
        cc_net_poll(2000, &server, 1, 0, &ready);
        if (cc_net_recv(server, received + have, CHUNK - have, &got) == 0) have += got;
        int32_t more = 0;
        if (total < CHUNK && cc_net_send(client, data + total, CHUNK - total, &more) == 0) total += more;
    }
    tl_int("test cc_net partial sends deliver every byte", CHUNK, have);
    tl_int("test cc_net partial sends deliver the bytes in order", 0, memcmp(data, received, CHUNK));

    free(data);
    free(received);
    cc_net_close(server);
    cc_net_close(client);
    cc_net_close(listener);
    return 0;
}
