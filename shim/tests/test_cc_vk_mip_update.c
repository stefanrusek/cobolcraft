/* Implementation test of cc_vk_texture_update on a multi-level texture (12 §2.4) against the real GPU:
 * the touched mip levels are regenerated from the new level 0 and the untouched texels keep their values. */
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
    cc_win_open(320, 240, "test_cc_vk_mip_update", 0);
    cc_vk_init();

    uint8_t black[8 * 8 * 4], white[4 * 4 * 4], got[4 * 4 * 4];
    char a[4 * 4 * 4 * 2 + 1];
    for (int i = 0; i < 64; i++) memcpy(black + 4 * i, "\x00\x00\x00\xff", 4);
    for (int i = 0; i < 16; i++) memcpy(white + 4 * i, "\xff\xff\xff\xff", 4);

    cc_vk_texture_ex(CC_TEX_BLOCKS, 8, 8, black, 4);
    /* White over the top-left 4 x 4 quarter: level 1 texels (0..1, 0..1) become white, level 2 texel 0 too. */
    tl_int("test cc_vk_mip_update returns 0", 0, cc_vk_texture_update(CC_TEX_BLOCKS, 0, 0, 4, 4, white));

    read_level(CC_TEX_BLOCKS, 1, 4, 4, got);
    hex(got, 4, a);
    tl_str("test cc_vk_mip_update level 1 touched texel is white", "FFFFFFFF", a);
    hex(got + 4 * (1 * 4 + 1), 4, a);
    tl_str("test cc_vk_mip_update level 1 last touched texel is white", "FFFFFFFF", a);
    hex(got + 4 * 2, 4, a);
    tl_str("test cc_vk_mip_update level 1 untouched texel stays black", "000000FF", a);

    read_level(CC_TEX_BLOCKS, 2, 2, 2, got);
    hex(got, 4, a);
    tl_str("test cc_vk_mip_update level 2 touched texel is white", "FFFFFFFF", a);
    hex(got + 4, 4, a);
    tl_str("test cc_vk_mip_update level 2 untouched texel stays black", "000000FF", a);

    read_level(CC_TEX_BLOCKS, 3, 1, 1, got);
    hex(got, 4, a);
    /* One white texel of four, linear-light mean 0.25 = sRGB 137 (89), alpha 255 (12 §2.3). */
    tl_str("test cc_vk_mip_update level 3 is a quarter white in linear light", "898989FF", a);

    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
