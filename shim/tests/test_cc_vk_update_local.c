/* Implementation test of cc_vk_texture_update recomputing only the changed rectangle (operator playtest: the client
 * was sluggish at the main menu because every animated sprite change rebuilt the whole mip chain of the block atlas).
 * (1) On an odd-sized texture with a full mip chain, every level after an update equals a fresh upload of the changed
 * image. (2) 20 updates of a 16 x 16 sprite of a 1024 x 1024 mip texture finish in under 150 ms. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"
#include "vk_readback.h"

static uint32_t seed = 12345;
static uint8_t next_byte(void) {
    seed = seed * 1664525u + 1013904223u;
    return (uint8_t)(seed >> 24);
}

static double now_ms(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec * 1000.0 + ts.tv_nsec / 1e6;
}

int main(void) {
    cc_win_open(320, 240, "test_cc_vk_update_local", 0);
    cc_vk_init();

    enum { W = 100, H = 75, MIPS = 7, RW = 21, RH = 17, RX = 13, RY = 9 };
    static uint8_t image[W * H * 4], patch[RW * RH * 4];
    for (int i = 0; i < W * H * 4; i++) image[i] = next_byte();
    for (int i = 0; i < RW * RH * 4; i++) patch[i] = next_byte();
    cc_vk_texture_ex(CC_TEX_BLOCKS, W, H, image, MIPS);
    cc_vk_texture_update(CC_TEX_BLOCKS, RX, RY, RW, RH, patch);
    for (int r = 0; r < RH; r++) memcpy(image + ((RY + r) * W + RX) * 4, patch + r * RW * 4, RW * 4);
    cc_vk_texture_ex(CC_TEX_ENTITIES, W, H, image, MIPS);
    static uint8_t a[W * H * 4], b[W * H * 4];
    int all_equal = 1;
    int lw = W, lh = H;
    for (uint32_t level = 0; level < MIPS; level++) {
        read_level(CC_TEX_BLOCKS, level, (uint32_t)lw, (uint32_t)lh, a);
        read_level(CC_TEX_ENTITIES, level, (uint32_t)lw, (uint32_t)lh, b);
        if (memcmp(a, b, (size_t)lw * (size_t)lh * 4) != 0) all_equal = 0;
        lw = lw > 1 ? lw / 2 : 1;
        lh = lh > 1 ? lh / 2 : 1;
    }
    tl_int("test cc_vk_update_local every level equals a fresh upload of the changed image", 1, all_equal);

    static uint8_t big[1024 * 1024 * 4], sprite[16 * 16 * 4];
    for (int i = 0; i < 1024 * 1024 * 4; i += 4) memcpy(big + i, "\x40\x80\xc0\xff", 4);
    memset(sprite, 0x77, sizeof sprite);
    cc_vk_texture_ex(CC_TEX_BLOCKS, 1024, 1024, big, 11);
    double t0 = now_ms();
    for (int i = 0; i < 20; i++) cc_vk_texture_update(CC_TEX_BLOCKS, 16 * (i % 8), 32, 16, 16, sprite);
    double ms = now_ms() - t0;
    printf("PERF 20 sprite updates of a 1024 x 1024 mip texture: %.1f ms\n", ms);
    tl_int("test cc_vk_update_local 20 sprite updates take under 150 ms", 1, ms < 150.0);

    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
