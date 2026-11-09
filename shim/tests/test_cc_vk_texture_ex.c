/* Implementation test of cc_vk_texture_ex (contracts/shim-delta.md) against the real GPU: a texture
 * uploaded with mip_levels 1 reads back identical to its RGBA input, cc_vk_texture still uploads the
 * same way, and with mip_levels 3 level 1 and level 2 are the box-filtered averages of a texture made of
 * four uniform quadrants. */
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
    cc_win_open(320, 240, "test_cc_vk_texture_ex", 0);
    cc_vk_init();

    uint8_t src[4 * 4 * 4], got[4 * 4 * 4];
    char want[4 * 4 * 4 * 2 + 1], seen[4 * 4 * 4 * 2 + 1];
    for (int i = 0; i < 64; i++) src[i] = (uint8_t)(i * 7 + 3);
    hex(src, 64, want);

    tl_int("test cc_vk_texture_ex mip_levels 1 returns 0", 0, cc_vk_texture_ex(CC_TEX_BLOCKS, 4, 4, src, 1));
    read_level(CC_TEX_BLOCKS, 0, 4, 4, got);
    hex(got, 64, seen);
    tl_str("test cc_vk_texture_ex mip_levels 1 reads back identical to the input", want, seen);

    tl_int("test cc_vk_texture returns 0", 0, cc_vk_texture(CC_TEX_UI, 4, 4, src));
    read_level(CC_TEX_UI, 0, 4, 4, got);
    hex(got, 64, seen);
    tl_str("test cc_vk_texture still reads back identical to the input", want, seen);

    /* Quadrants: top-left red, top-right green, bottom-left blue, bottom-right white (opaque). */
    static const uint8_t col[4][4] = {{255, 0, 0, 255}, {0, 255, 0, 255}, {0, 0, 255, 255}, {255, 255, 255, 255}};
    for (int y = 0; y < 4; y++)
        for (int x = 0; x < 4; x++) memcpy(src + (y * 4 + x) * 4, col[(y / 2) * 2 + x / 2], 4);
    tl_int("test cc_vk_texture_ex mip_levels 3 returns 0", 0, cc_vk_texture_ex(CC_TEX_BLOCKS, 4, 4, src, 3));
    read_level(CC_TEX_BLOCKS, 0, 4, 4, got);
    hex(got, 64, seen);
    hex(src, 64, want);
    tl_str("test cc_vk_texture_ex mip_levels 3 keeps level 0 identical", want, seen);
    uint8_t l1[2 * 2 * 4];
    read_level(CC_TEX_BLOCKS, 1, 2, 2, l1);
    hex(l1, 16, seen);
    tl_str("test cc_vk_texture_ex level 1 is one texel per quadrant", "FF0000FF00FF00FF0000FFFFFFFFFFFF", seen);
    uint8_t l2[4];
    read_level(CC_TEX_BLOCKS, 2, 1, 1, l2);
    /* Average of red, green, blue, white = (127.5, 127.5, 127.5, 255): 7F or 80 per channel. */
    int ok = (l2[0] == 0x7F || l2[0] == 0x80) && (l2[1] == 0x7F || l2[1] == 0x80) && (l2[2] == 0x7F || l2[2] == 0x80) && l2[3] == 0xFF;
    tl_int("test cc_vk_texture_ex level 2 is the average of the four quadrants", 1, ok);

    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
