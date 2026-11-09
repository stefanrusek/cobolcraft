/* Implementation test of the mip chain of cc_vk_texture_ex (12 §2.4, FR-011) against the real GPU: an 8 x 8
 * texture with mip_levels 4 reads back a box-filtered level 1 (4 x 4), level 2 (2 x 2) and level 3 (1 x 1). */
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
    cc_win_open(320, 240, "test_cc_vk_mips", 0);
    cc_vk_init();

    /* Each 2 x 2 block of level 0 holds the grey 8 * k (k = block row * 4 + block column), so level 1 texel k
     * is that grey, and level 2 texel (i, j) is the mean of four of them. Blue and alpha are fixed. */
    uint8_t src[8 * 8 * 4], got[8 * 8 * 4], want[16 * 4];
    char a[16 * 4 * 2 + 1], b[16 * 4 * 2 + 1];
    for (int y = 0; y < 8; y++)
        for (int x = 0; x < 8; x++) {
            uint8_t g = (uint8_t)(8 * ((y / 2) * 4 + x / 2));
            uint8_t *p = src + (y * 8 + x) * 4;
            p[0] = g;
            p[1] = g;
            p[2] = 0x40;
            p[3] = 0xff;
        }
    tl_int("test cc_vk_mips upload with mip_levels 4 returns 0", 0, cc_vk_texture_ex(CC_TEX_BLOCKS, 8, 8, src, 4));

    for (int k = 0; k < 16; k++) memcpy(want + 4 * k, (uint8_t[]){(uint8_t)(8 * k), (uint8_t)(8 * k), 0x40, 0xff}, 4);
    read_level(CC_TEX_BLOCKS, 1, 4, 4, got);
    hex(got, 64, a);
    hex(want, 64, b);
    tl_str("test cc_vk_mips level 1 is the 2 x 2 box filter of level 0", b, a);

    /* Level 2: linear-light means (12 §2.3) of the greys of blocks {0,1,4,5}, {2,3,6,7}, {8,9,12,13}, {10,11,14,15}. */
    const uint8_t l2[4] = {25, 40, 86, 102};
    for (int k = 0; k < 4; k++) memcpy(want + 4 * k, (uint8_t[]){l2[k], l2[k], 0x40, 0xff}, 4);
    read_level(CC_TEX_BLOCKS, 2, 2, 2, got);
    hex(got, 16, a);
    hex(want, 16, b);
    tl_str("test cc_vk_mips level 2 is the box filter of level 1", b, a);

    /* Level 3: mean of the four level 2 greys = the linear-light mean of 25, 40, 86, 102 = 72. */
    read_level(CC_TEX_BLOCKS, 3, 1, 1, got);
    hex(got, 4, a);
    tl_str("test cc_vk_mips level 3 is the box filter of level 2", "484840FF", a);

    /* Linear-light mean (12 §2.3, V8): every 2 x 2 block holds red 255,255,0,0 (mean 0.5 linear = sRGB 188),
     * green 255,0,255,0 (188), blue 255,0,0,0 (0.25 linear = sRGB 137) and alpha 255,255,0,0 (integer mean
     * 510 / 4 = 127). Level 2 averages four equal texels, so it keeps level 1's value. */
    uint8_t hc[4 * 4 * 4], lin[4 * 4];
    const uint8_t block[4][4] = {{255, 255, 255, 255}, {255, 0, 0, 255}, {0, 255, 0, 0}, {0, 0, 0, 0}};
    for (int y = 0; y < 4; y++)
        for (int x = 0; x < 4; x++) memcpy(hc + (y * 4 + x) * 4, block[(y % 2) * 2 + x % 2], 4);
    cc_vk_texture_ex(CC_TEX_BLOCKS, 4, 4, hc, 3);
    read_level(CC_TEX_BLOCKS, 1, 2, 2, lin);
    hex(lin, 16, a);
    tl_str("test cc_vk_mips level 1 averages colour in linear light, alpha by integer mean", "BCBC897FBCBC897FBCBC897FBCBC897F", a);
    read_level(CC_TEX_BLOCKS, 2, 1, 1, lin);
    hex(lin, 4, a);
    tl_str("test cc_vk_mips level 2 of equal texels keeps the linear-light mean", "BCBC897F", a);

    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
