/* Implementation test of shim/src/cc_vk.c and shim/src/cc_win.c: swapchain recreation after the
 * window is resized, a frame skipped while the window is minimised, and meshes and textures replaced
 * while a frame is being recorded (their old buffers stay valid until the frame has completed). */
#include <string.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"

#define S cc_vk_state

static const float TRIANGLE[3 * 7] = {
    -0.5f, -0.5f, 0.5f, 0, 0, 1, 1,  0.5f, -0.5f, 0.5f, 1, 0, 1, 1,  0.0f, 0.5f, 0.5f, 0.5f, 1, 1, 1,
};
static const float IDENTITY[16] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
static const float CLEAR[4] = {0.2f, 0.3f, 0.4f, 1};

int main(void) {
    cc_win_open(320, 240, "test_cc_vk_resize", 0);
    cc_vk_init();
    uint8_t rgba[4] = {255, 255, 255, 255};
    cc_vk_texture(CC_TEX_UI, 1, 1, rgba);
    cc_vk_mesh(7, TRIANGLE, 3);

    int32_t win_w, win_h, fb_w, fb_h;
    cc_win_size(&win_w, &win_h, &fb_w, &fb_h);
    tl_int("test cc_vk swapchain extent is the framebuffer size", 1,
           S.extent.width == (uint32_t)fb_w && S.extent.height == (uint32_t)fb_h);

    glfwSetWindowSize(cc_win_window, 400, 300);
    uint8_t events[24 * 16];
    int32_t count;
    cc_win_poll(events, sizeof events, &count);
    cc_win_size(&win_w, &win_h, &fb_w, &fb_h);
    tl_int("test cc_win window size follows a resize", 1, win_w == 400 && win_h == 300);
    tl_int("test cc_vk_frame_begin after a resize returns 0", 0, cc_vk_frame_begin(CLEAR));
    tl_int("test cc_vk_frame_begin after a resize recreates the swapchain at the new framebuffer size", 1,
           S.extent.width == (uint32_t)fb_w && S.extent.height == (uint32_t)fb_h);
    cc_vk_draw(7, CC_PIPE_UI, CC_TEX_UI, IDENTITY);

    /* Replaced while the frame is recording: the old buffer and texture are destroyed only after the
     * frame's commands have completed. */
    cc_vk_mesh(7, TRIANGLE, 3);
    cc_vk_texture(CC_TEX_UI, 1, 1, rgba);
    tl_int("test cc_vk resources replaced during a frame wait for the frame to complete", 2, (long long)S.garbage_count);
    cc_vk_draw(7, CC_PIPE_UI, CC_TEX_UI, IDENTITY);
    cc_vk_draw(8, CC_PIPE_UI, CC_TEX_UI, IDENTITY); /* empty slot: nothing is drawn */
    cc_vk_frame_end();
    tl_int("test cc_vk replaced resources are destroyed once the frame has completed", 0, (long long)S.garbage_count);

    /* A swapchain reported out of date by presentation is recreated at the next frame. */
    S.stale = 1;
    tl_int("test cc_vk_frame_begin recreates a stale swapchain and returns 0", 0, cc_vk_frame_begin(CLEAR));
    tl_int("test cc_vk recreated swapchain is no longer stale", 0, S.stale);
    cc_vk_frame_end();

    glfwIconifyWindow(cc_win_window);
    for (int i = 0; i < 40 && !glfwGetWindowAttrib(cc_win_window, GLFW_ICONIFIED); i++) {
        glfwWaitEventsTimeout(0.05);
        cc_win_poll(events, sizeof events, &count);
    }
    tl_int("test cc_win window is minimised", 1, glfwGetWindowAttrib(cc_win_window, GLFW_ICONIFIED));
    tl_int("test cc_vk_frame_begin while the window is minimised returns CC_AGAIN (frame skipped)", CC_AGAIN,
           cc_vk_frame_begin(CLEAR));

    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
