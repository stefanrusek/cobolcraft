/* Implementation test of cc_vk_screenshot and cc_vk_screenshot_result (contracts/shim-delta.md §14) on the real device: a frame
 * cleared to (0.2, 0.4, 0.6) with a red quad over the centre is saved as the PNG the request names; the file holds the
 * presented pixels in RGBA order (corner = clear colour, centre = red), only the frame after the request is saved, a second
 * request while one waits is CC_AGAIN, and an unwritable path gives CC_FAILED from the result. */
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"

#define S cc_vk_state

static const float QUAD[6 * 11] = {
    -0.5f, -0.5f, 0.3f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, -0.5f, 0.3f, 1, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.3f, 1, 1, 1, 1, 0, 1, 1, 1,
    -0.5f, -0.5f, 0.3f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.3f, 1, 1, 1, 1, 0, 1, 1, 1,  -0.5f, 0.5f, 0.3f, 0, 1, 1, 1, 0, 1, 1, 1,
};
static const float IDENTITY[16] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};

static void frame(void) {
    const float clear[4] = {0.2f, 0.4f, 0.6f, 1};
    cc_vk_frame_begin(clear);
    cc_vk_draw(1, CC_PIPE_OPAQUE, CC_TEX_BLOCKS, IDENTITY);
    cc_vk_frame_end();
}

/* Reads the PNG written by cc_png_write (zlib stream inflated with cc_inflate): the RGBA of pixel (x, y). */
static int pixel(const char *path, int x, int y, uint8_t rgba[4], int *w, int *h) {
    static uint8_t file[1 << 22], raw[1 << 22];
    FILE *f = fopen(path, "rb");
    if (f == NULL) return 0;
    size_t n = fread(file, 1, sizeof file, f);
    fclose(f);
    if (n < 45) return 0;
    *w = file[16] << 24 | file[17] << 16 | file[18] << 8 | file[19];
    *h = file[20] << 24 | file[21] << 16 | file[22] << 8 | file[23];
    int32_t len = (int32_t)((uint32_t)file[33] << 24 | (uint32_t)file[34] << 16 | (uint32_t)file[35] << 8 | file[36]), out = 0;
    if (cc_inflate(CC_ZLIB, file + 41, len, raw, sizeof raw, &out) != 0) return 0;
    memcpy(rgba, raw + (size_t)y * (*w * 4 + 1) + 1 + (size_t)x * 4, 4);
    return 1;
}

int main(void) {
    cc_win_open(320, 240, "test_cc_vk_screenshot", 0);
    cc_vk_init();
    static const uint8_t red[2 * 2 * 4] = {0xff, 0, 0, 0xff, 0xff, 0, 0, 0xff, 0xff, 0, 0, 0xff, 0xff, 0, 0, 0xff};
    cc_vk_texture(CC_TEX_BLOCKS, 2, 2, red);
    cc_vk_mesh(1, QUAD, 6);
    char path[] = "/tmp/test_cc_vk_screenshot_XXXXXX";
    close(mkstemp(path));
    unlink(path);
    tl_int("test cc_vk_screenshot_result without a request is 0", 0, cc_vk_screenshot_result());
    tl_int("test cc_vk_screenshot accepts a request", 0, cc_vk_screenshot(path));
    tl_int("test cc_vk_screenshot a second request while one waits is CC_AGAIN", CC_AGAIN, cc_vk_screenshot("/tmp/other.png"));
    tl_int("test cc_vk_screenshot_result before the frame is CC_AGAIN", CC_AGAIN, cc_vk_screenshot_result());
    tl_int("test cc_vk_screenshot writes no file before the frame", 1, access(path, F_OK) != 0);
    frame();
    tl_int("test cc_vk_screenshot_result after the frame is 0", 0, cc_vk_screenshot_result());
    uint8_t p[4];
    int w = 0, h = 0;
    tl_int("test cc_vk_screenshot file is a readable PNG", 1, pixel(path, 3, 3, p, &w, &h));
    tl_int("test cc_vk_screenshot image is the swapchain extent", 1, (uint32_t)w == S.extent.width && (uint32_t)h == S.extent.height);
    char hex[9];
    snprintf(hex, sizeof hex, "%02X%02X%02X%02X", p[0], p[1], p[2], p[3]);
    tl_str("test cc_vk_screenshot corner pixel is the clear colour in RGBA order", "336699FF", hex);
    pixel(path, w / 2, h / 2, p, &w, &h);
    snprintf(hex, sizeof hex, "%02X%02X%02X%02X", p[0], p[1], p[2], p[3]);
    tl_str("test cc_vk_screenshot centre pixel is the red quad", "FF0000FF", hex);
    unlink(path);
    frame();
    tl_int("test cc_vk_screenshot saves only the frame after the request", 1, access(path, F_OK) != 0);
    tl_int("test cc_vk_screenshot accepts a new request once served", 0, cc_vk_screenshot("/nonexistent-dir/x.png"));
    frame();
    tl_int("test cc_vk_screenshot_result for an unwritable path is CC_FAILED", CC_FAILED, cc_vk_screenshot_result());
    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
