/* Contract probe (make gate-contract, T076): includes contract/include/ccshim.h and asserts the
 * record sizes, field offsets and constant values of contracts/shim-abi.md, and (at compile time)
 * that every prototype has the signature the contract states. Links nothing from the shim package.
 * Test infrastructure. */
#include <stddef.h>

#include "ccshim.h"
#include "testlib.h"

/* Each prototype as shim-abi.md §2 to §9 states it. _Generic does not evaluate its operand, so the
 * functions need no definition here. */
#define SIGNATURE(function, type) _Static_assert(_Generic(&(function), type: 1, default: 0), #function)
SIGNATURE(cc_fatal, void (*)(const char *));
SIGNATURE(cc_net_listen, int32_t (*)(int32_t, int32_t *, int32_t *));
SIGNATURE(cc_net_accept, int32_t (*)(int32_t, int32_t *));
SIGNATURE(cc_net_connect, int32_t (*)(const char *, int32_t, int32_t *));
SIGNATURE(cc_net_status, int32_t (*)(int32_t));
SIGNATURE(cc_net_send, int32_t (*)(int32_t, const uint8_t *, int32_t, int32_t *));
SIGNATURE(cc_net_recv, int32_t (*)(int32_t, uint8_t *, int32_t, int32_t *));
SIGNATURE(cc_net_close, void (*)(int32_t));
SIGNATURE(cc_net_poll, int32_t (*)(int32_t, const int32_t *, int32_t, int32_t, uint8_t *));
SIGNATURE(cc_net_local_addresses, int32_t (*)(uint8_t *, int32_t));
SIGNATURE(cc_con_readline, int32_t (*)(uint8_t *, int32_t, int32_t *));
SIGNATURE(cc_deflate, int32_t (*)(int32_t, const uint8_t *, int32_t, uint8_t *, int32_t, int32_t *));
SIGNATURE(cc_inflate, int32_t (*)(int32_t, const uint8_t *, int32_t, uint8_t *, int32_t, int32_t *));
SIGNATURE(cc_tls_connect, int32_t (*)(const char *, int32_t, int32_t *));
SIGNATURE(cc_tls_status, int32_t (*)(int32_t));
SIGNATURE(cc_tls_send, int32_t (*)(int32_t, const uint8_t *, int32_t, int32_t *));
SIGNATURE(cc_tls_recv, int32_t (*)(int32_t, uint8_t *, int32_t, int32_t *));
SIGNATURE(cc_tls_close, void (*)(int32_t));
SIGNATURE(cc_fs_list, int32_t (*)(const char *, uint8_t *, int32_t, int32_t *));
SIGNATURE(cc_win_open, int32_t (*)(int32_t, int32_t, const char *, int32_t));
SIGNATURE(cc_win_poll, int32_t (*)(uint8_t *, int32_t, int32_t *));
SIGNATURE(cc_win_size, void (*)(int32_t *, int32_t *, int32_t *, int32_t *));
SIGNATURE(cc_win_capture_cursor, void (*)(int32_t));
SIGNATURE(cc_win_close, void (*)(void));
SIGNATURE(cc_vk_init, int32_t (*)(void));
SIGNATURE(cc_vk_texture, int32_t (*)(int32_t, int32_t, int32_t, const uint8_t *));
SIGNATURE(cc_vk_texture_wrap, int32_t (*)(int32_t, int32_t));
SIGNATURE(cc_vk_mesh, int32_t (*)(int32_t, const float *, int32_t));
SIGNATURE(cc_vk_frame_begin, int32_t (*)(const float *));
SIGNATURE(cc_vk_draw, void (*)(int32_t, int32_t, int32_t, const float *));
SIGNATURE(cc_vk_frame_end, void (*)(void));
SIGNATURE(cc_vk_shutdown, void (*)(void));

int main(void) {
    tl_int("contract ccshim prototypes match shim-abi", 1, 1);

    tl_int("contract ccshim cc_event size", 24, (long long)sizeof(cc_event));
    tl_int("contract ccshim cc_event offset kind", 0, (long long)offsetof(cc_event, kind));
    tl_int("contract ccshim cc_event offset a", 4, (long long)offsetof(cc_event, a));
    tl_int("contract ccshim cc_event offset b", 8, (long long)offsetof(cc_event, b));
    tl_int("contract ccshim cc_event offset c", 12, (long long)offsetof(cc_event, c));
    tl_int("contract ccshim cc_event offset x", 16, (long long)offsetof(cc_event, x));
    tl_int("contract ccshim cc_event offset y", 20, (long long)offsetof(cc_event, y));
    tl_int("contract ccshim float is 4 bytes", 4, (long long)sizeof(float));
    tl_int("contract ccshim cc_vertex size", 28, (long long)sizeof(cc_vertex));
    tl_int("contract ccshim cc_vertex offset alpha", 24, (long long)offsetof(cc_vertex, alpha));

    {
        const int32_t one = 1;
        const uint8_t *bytes = (const uint8_t *)&one;
        tl_int("contract ccshim int32 is little-endian", 1, bytes[0]);
    }

    tl_int("contract ccshim CC_AGAIN", 1, CC_AGAIN);
    tl_int("contract ccshim CC_ADDR_IN_USE", 2, CC_ADDR_IN_USE);
    tl_int("contract ccshim CC_UNRESOLVED", 3, CC_UNRESOLVED);
    tl_int("contract ccshim CC_CLOSED", 4, CC_CLOSED);
    tl_int("contract ccshim CC_SMALL", 5, CC_SMALL);
    tl_int("contract ccshim CC_BADDATA", 6, CC_BADDATA);
    tl_int("contract ccshim CC_NOTFOUND", 7, CC_NOTFOUND);
    tl_int("contract ccshim CC_ZLIB", 0, CC_ZLIB);
    tl_int("contract ccshim CC_GZIP", 1, CC_GZIP);
    tl_int("contract ccshim CC_RAW", 2, CC_RAW);
    tl_int("contract ccshim CC_PIPE_OPAQUE", 0, CC_PIPE_OPAQUE);
    tl_int("contract ccshim CC_PIPE_TRANSLUCENT", 1, CC_PIPE_TRANSLUCENT);
    tl_int("contract ccshim CC_PIPE_UI", 2, CC_PIPE_UI);
    tl_int("contract ccshim CC_TEX_BLOCKS", 0, CC_TEX_BLOCKS);
    tl_int("contract ccshim CC_TEX_ENTITIES", 1, CC_TEX_ENTITIES);
    tl_int("contract ccshim CC_TEX_UI", 2, CC_TEX_UI);
    tl_int("contract ccshim CC_TEX_ENVIRONMENT", 3, CC_TEX_ENVIRONMENT);
    tl_int("contract ccshim CC_WRAP_CLAMP", 0, CC_WRAP_CLAMP);
    tl_int("contract ccshim CC_WRAP_REPEAT", 1, CC_WRAP_REPEAT);
    tl_int("contract ccshim CC_EV_KEY_DOWN", 1, CC_EV_KEY_DOWN);
    tl_int("contract ccshim CC_EV_CLOSE_REQUEST", 9, CC_EV_CLOSE_REQUEST);
    tl_int("contract ccshim CC_MESH_SLOT_MAX", 65535, CC_MESH_SLOT_MAX);
    return 0;
}
