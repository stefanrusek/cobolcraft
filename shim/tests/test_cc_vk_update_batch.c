/* Implementation test of cc_vk_texture_update_begin and _end (contracts/shim-delta.md): updates made between them read back as
 * they do when made one by one, the end with nothing recorded does nothing, and a batch of more updates than the shim holds at
 * once (256) is flushed part way and still reads back whole. */
#include <stdio.h>
#include <string.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"
#include "vk_readback.h"

static void hex(const uint8_t *p, size_t n, char *out) {
    for (size_t i = 0; i < n; i++) snprintf(out + 2 * i, 3, "%02X", p[i]);
}

int main(void) {
    cc_win_open(320, 240, "test_cc_vk_update_batch", 0);
    cc_vk_init();

    uint8_t red[4 * 4 * 4], blue[4], green[4], got[4 * 4 * 4], want[4 * 4 * 4];
    char a[4 * 4 * 4 * 2 + 1], b[4 * 4 * 4 * 2 + 1];
    for (int i = 0; i < 16; i++) memcpy(red + 4 * i, "\xff\x00\x00\xff", 4);
    memcpy(blue, "\x00\x00\xff\xff", 4);
    memcpy(green, "\x00\xff\x00\xff", 4);

    cc_vk_texture_update_end();
    cc_vk_texture_ex(CC_TEX_BLOCKS, 4, 4, red, 1);
    cc_vk_texture_update_begin();
    cc_vk_texture_update(CC_TEX_BLOCKS, 0, 0, 1, 1, blue);
    cc_vk_texture_update(CC_TEX_BLOCKS, 3, 3, 1, 1, green);
    cc_vk_texture_update_end();
    memcpy(want, red, 64);
    memcpy(want, "\x00\x00\xff\xff", 4);
    memcpy(want + (3 * 4 + 3) * 4, "\x00\xff\x00\xff", 4);
    read_level(CC_TEX_BLOCKS, 0, 4, 4, got);
    hex(got, 64, a);
    hex(want, 64, b);
    tl_str("test cc_vk_texture_update_end shows both updates of the batch", b, a);

    cc_vk_texture_update_begin();
    cc_vk_texture_update_end();
    read_level(CC_TEX_BLOCKS, 0, 4, 4, got);
    hex(got, 64, a);
    tl_str("test cc_vk_texture_update_end with nothing recorded changes nothing", b, a);

    cc_vk_texture_update_begin();
    for (int i = 0; i < 300; i++) cc_vk_texture_update(CC_TEX_BLOCKS, i % 4, (i / 4) % 4, 1, 1, i % 2 ? blue : green);
    cc_vk_texture_update_end();
    memcpy(want, red, 64);
    for (int i = 0; i < 300; i++) memcpy(want + (((i / 4) % 4) * 4 + i % 4) * 4, i % 2 ? blue : green, 4);
    read_level(CC_TEX_BLOCKS, 0, 4, 4, got);
    hex(got, 64, a);
    hex(want, 64, b);
    tl_str("test cc_vk_texture_update 300 updates in one batch all show", b, a);

    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
