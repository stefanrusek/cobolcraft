/* Implementation test of the present mode choice of shim/src/cc_vk.c on the real device: CC_VK_PRESENT=immediate gives an IMMEDIATE
 * swapchain when the surface offers that mode (MoltenVK does: the layer's display sync is off) and FIFO, which every surface offers,
 * when it does not; frames are presented in it, one frame in flight (CC_VK_INFLIGHT=1) included; and without CC_VK_PRESENT the mode
 * is FIFO (test_cc_vk_resize). */
#include <stdlib.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"

#define S cc_vk_state

static const float CLEAR[4] = {0.1f, 0.2f, 0.3f, 1};

int main(void) {
    setenv("CC_VK_PRESENT", "immediate", 1);
    setenv("CC_VK_INFLIGHT", "1", 1);
    cc_win_open(320, 240, "test_cc_vk_present_mode", 0);
    cc_vk_init();
    uint32_t count = 16;
    VkPresentModeKHR modes[16];
    vkGetPhysicalDeviceSurfacePresentModesKHR(S.gpu, S.surface, &count, modes);
    int immediate = 0;
    for (uint32_t i = 0; i < count; i++) immediate |= modes[i] == VK_PRESENT_MODE_IMMEDIATE_KHR;
    tl_int("test cc_vk present mode is IMMEDIATE when CC_VK_PRESENT asks for it and the surface offers it, else FIFO",
           immediate ? VK_PRESENT_MODE_IMMEDIATE_KHR : VK_PRESENT_MODE_FIFO_KHR, S.present_mode);
    tl_int("test cc_vk runs one frame in flight when CC_VK_INFLIGHT is 1", 1, S.in_flight);
    int begun = 0;
    for (int i = 0; i < 4; i++) {
        begun += cc_vk_frame_begin(CLEAR) == 0;
        cc_vk_frame_end();
    }
    tl_int("test cc_vk presents four frames in that mode with one frame in flight", 4, begun);
    tl_int("test cc_vk counts the frames it submitted", 4, (long long)S.frames_submitted);
    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
