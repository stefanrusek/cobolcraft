/* Implementation test of cc_vk_texture_update (contracts/shim-delta.md) against the real GPU: after an
 * update of one rectangle only that rectangle reads back changed, and on a texture with mip levels the
 * touched level 1 texel changes while the untouched one does not. */
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
    cc_win_open(320, 240, "test_cc_vk_texture_update", 0);
    cc_vk_init();

    uint8_t red[4 * 4 * 4], blue[2 * 2 * 4], got[4 * 4 * 4], want[4 * 4 * 4];
    char a[4 * 4 * 4 * 2 + 1], b[4 * 4 * 4 * 2 + 1];
    for (int i = 0; i < 16; i++) memcpy(red + 4 * i, "\xff\x00\x00\xff", 4);
    for (int i = 0; i < 4; i++) memcpy(blue + 4 * i, "\x00\x00\xff\xff", 4);

    cc_vk_texture_ex(CC_TEX_BLOCKS, 4, 4, red, 1);
    tl_int("test cc_vk_texture_update of a rectangle returns 0", 0, cc_vk_texture_update(CC_TEX_BLOCKS, 1, 1, 2, 2, blue));
    memcpy(want, red, 64);
    for (int y = 1; y < 3; y++)
        for (int x = 1; x < 3; x++) memcpy(want + (y * 4 + x) * 4, "\x00\x00\xff\xff", 4);
    read_level(CC_TEX_BLOCKS, 0, 4, 4, got);
    hex(got, 64, a);
    hex(want, 64, b);
    tl_str("test cc_vk_texture_update changes only the updated rectangle", b, a);

    cc_vk_texture_ex(CC_TEX_BLOCKS, 4, 4, red, 3);
    tl_int("test cc_vk_texture_update on a mipped texture returns 0", 0, cc_vk_texture_update(CC_TEX_BLOCKS, 0, 0, 2, 2, blue));
    uint8_t l1[2 * 2 * 4];
    read_level(CC_TEX_BLOCKS, 1, 2, 2, l1);
    hex(l1, 4, a);
    tl_str("test cc_vk_texture_update regenerates the touched level 1 texel", "0000FFFF", a);
    hex(l1 + 12, 4, a);
    tl_str("test cc_vk_texture_update leaves the untouched level 1 texel", "FF0000FF", a);

    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
