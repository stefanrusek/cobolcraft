/* Implementation test of shim/src/cc_vk.c against the real GPU: draws one textured quad with each
 * pipeline into a hidden window, copies the rendered swapchain image to host memory between the two
 * halves of cc_vk_frame_end (cc_vk_submit, then cc_vk_present) and asserts the centre pixel (the
 * texture's colour) and a corner pixel (the clear colour). Then the wrap modes (§9, 08 §10.11
 * weather sampling): a 2 x 1 texture (red, blue) drawn with u from 0 to 2 shows, 5/8 across the
 * quad (u = 1.25), the left texel again with CC_WRAP_REPEAT and the right edge texel with
 * CC_WRAP_CLAMP. */
#include <stdio.h>
#include <string.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"

#define S cc_vk_state

/* The quad covers clip space [-0.5, 0.5]; brightness 1, alpha multiplier 1. */
static const float QUAD[6 * 11] = {
    -0.5f, -0.5f, 0.5f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, -0.5f, 0.5f, 1, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.5f, 1, 1, 1, 1, 0, 1, 1, 1,
    -0.5f, -0.5f, 0.5f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.5f, 1, 1, 1, 1, 0, 1, 1, 1,  -0.5f, 0.5f, 0.5f, 0, 1, 1, 1, 0, 1, 1, 1,
};
/* The same quad with u from 0 to 2. */
static const float QUAD_U2[6 * 11] = {
    -0.5f, -0.5f, 0.5f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, -0.5f, 0.5f, 2, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.5f, 2, 1, 1, 1, 0, 1, 1, 1,
    -0.5f, -0.5f, 0.5f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.5f, 2, 1, 1, 1, 0, 1, 1, 1,  -0.5f, 0.5f, 0.5f, 0, 1, 1, 1, 0, 1, 1, 1,
};
static const float IDENTITY[16] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};

static uint32_t host_memory_type(uint32_t bits) {
    VkMemoryPropertyFlags want = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    uint32_t i = 0;
    while (!((bits >> i & 1u) && (S.memory_properties.memoryTypes[i].propertyFlags & want) == want)) i++;
    return i;
}

static void image_barrier(VkCommandBuffer cmd, VkImage image, VkImageLayout from, VkImageLayout to) {
    VkImageMemoryBarrier b = {
        .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
        .srcAccessMask = VK_ACCESS_MEMORY_WRITE_BIT,
        .dstAccessMask = VK_ACCESS_MEMORY_READ_BIT,
        .oldLayout = from,
        .newLayout = to,
        .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
        .image = image,
        .subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1},
    };
    vkCmdPipelineBarrier(cmd, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, 0, 0, NULL, 0, NULL, 1, &b);
}

/* Copies the frame's rendered image (layout PRESENT_SRC after the render pass) to host memory and
 * writes the colour of each pixel (xs[i], ys[i]) to out[i] as "RRGGBBAA". */
static void read_pixels(int nx, const int *xs, const int *ys, char out[][9]) {
    VkExtent2D e = S.extent;
    VkDeviceSize size = (VkDeviceSize)e.width * e.height * 4;
    VkBufferCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = size,
        .usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT,
    };
    VkBuffer buffer;
    vkCreateBuffer(S.device, &info, NULL, &buffer);
    VkMemoryRequirements need;
    vkGetBufferMemoryRequirements(S.device, buffer, &need);
    VkMemoryAllocateInfo alloc = {
        .sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = need.size,
        .memoryTypeIndex = host_memory_type(need.memoryTypeBits),
    };
    VkDeviceMemory memory;
    vkAllocateMemory(S.device, &alloc, NULL, &memory);
    vkBindBufferMemory(S.device, buffer, memory, 0);

    VkCommandBufferAllocateInfo cmd_info = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = S.commands,
        .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = 1,
    };
    VkCommandBuffer cmd;
    vkAllocateCommandBuffers(S.device, &cmd_info, &cmd);
    VkCommandBufferBeginInfo begin = {.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO};
    vkBeginCommandBuffer(cmd, &begin);
    VkImage image = S.images[S.image_index];
    image_barrier(cmd, image, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
    VkBufferImageCopy region = {
        .imageSubresource = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1},
        .imageExtent = {e.width, e.height, 1},
    };
    vkCmdCopyImageToBuffer(cmd, image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, buffer, 1, &region);
    image_barrier(cmd, image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR);
    vkEndCommandBuffer(cmd);
    VkSubmitInfo submit = {.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = &cmd};
    vkQueueSubmit(S.queue, 1, &submit, VK_NULL_HANDLE);
    vkQueueWaitIdle(S.queue);

    uint8_t *pixels;
    vkMapMemory(S.device, memory, 0, size, 0, (void **)&pixels);
    int bgra = S.format.format == VK_FORMAT_B8G8R8A8_UNORM || S.format.format == VK_FORMAT_B8G8R8A8_SRGB;
    for (int i = 0; i < nx; i++) {
        const uint8_t *p = pixels + ((size_t)ys[i] * e.width + (size_t)xs[i]) * 4;
        snprintf(out[i], 9, "%02X%02X%02X%02X", p[bgra ? 2 : 0], p[1], p[bgra ? 0 : 2], p[3]);
    }
    vkUnmapMemory(S.device, memory);
    vkFreeCommandBuffers(S.device, S.commands, 1, &cmd);
    vkDestroyBuffer(S.device, buffer, NULL);
    vkFreeMemory(S.device, memory, NULL);
}

int main(void) {
    cc_win_open(320, 240, "test_cc_vk_pixels", 0);
    cc_vk_init();
    tl_int("test cc_vk swapchain format is 8-bit UNORM (pixel values are compared exactly)", 1,
           S.format.format == VK_FORMAT_B8G8R8A8_UNORM || S.format.format == VK_FORMAT_R8G8B8A8_UNORM);
    /* A 2 x 2 texture in the greystone fill colour 7D7F86 (standin-content §1.4). */
    uint8_t rgba[2 * 2 * 4];
    for (int i = 0; i < 4; i++) memcpy(rgba + 4 * i, "\x7d\x7f\x86\xff", 4);
    cc_vk_texture(CC_TEX_BLOCKS, 2, 2, rgba);
    cc_vk_mesh(1, QUAD, 6);

    static const char *names[] = {"opaque", "translucent", "ui"};
    const float clear[4] = {0, 0, 0, 1};
    char name[128];
    for (int32_t p = CC_PIPE_OPAQUE; p <= CC_PIPE_UI; p++) {
        cc_vk_frame_begin(clear);
        cc_vk_draw(1, p, CC_TEX_BLOCKS, IDENTITY);
        cc_vk_submit();
        int xs[2] = {(int)S.extent.width / 2, 1};
        int ys[2] = {(int)S.extent.height / 2, 1};
        char pixels[2][9];
        read_pixels(2, xs, ys, pixels);
        cc_vk_present();
        snprintf(name, sizeof name, "test cc_vk %s pipeline centre pixel is the texel colour", names[p]);
        tl_str(name, "7D7F86FF", pixels[0]);
        snprintf(name, sizeof name, "test cc_vk %s pipeline corner pixel is the clear colour", names[p]);
        tl_str(name, "000000FF", pixels[1]);
    }

    /* Wrap modes: texture 3 is a red texel then a blue one. */
    static const uint8_t two[2 * 4] = {0xff, 0, 0, 0xff, 0, 0, 0xff, 0xff};
    cc_vk_mesh(2, QUAD_U2, 6);
    static const char *wraps[] = {"clamp", "repeat"};
    static const char *expect[] = {"0000FFFF", "FF0000FF"};
    for (int32_t w = CC_WRAP_CLAMP; w <= CC_WRAP_REPEAT; w++) {
        tl_int("test cc_vk_texture_wrap of a valid texture id and mode returns 0", 0,
               cc_vk_texture_wrap(CC_TEX_ENVIRONMENT, w));
        cc_vk_texture(CC_TEX_ENVIRONMENT, 2, 1, two);
        cc_vk_frame_begin(clear);
        cc_vk_draw(2, CC_PIPE_UI, CC_TEX_ENVIRONMENT, IDENTITY);
        cc_vk_submit();
        int xs[1] = {(int)S.extent.width * 9 / 16};
        int ys[1] = {(int)S.extent.height / 2};
        char pixels[1][9];
        read_pixels(1, xs, ys, pixels);
        cc_vk_present();
        snprintf(name, sizeof name, "test cc_vk %s wrap at u 1.25 samples the %s texel", wraps[w],
                 w == CC_WRAP_REPEAT ? "first (repeated)" : "last (edge)");
        tl_str(name, expect[w], pixels[0]);
    }

    /* The tint channel and the daylight uniform (§9 vertex of 11 floats: x y z u v brightness alpha sky r g b):
     * the colour is texel x tint x max(brightness, sky x daylight). The texture is a white texel. */
    static const uint8_t white[2 * 2 * 4] = {255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255};
    cc_vk_texture(CC_TEX_BLOCKS, 2, 2, white);
    float lit[6 * 11];
    memcpy(lit, QUAD, sizeof lit);
    static const struct {
        const char *what;
        float brightness, sky, r, g, b, daylight;
        const char *expect;
    } cases[] = {
        {"tint (1, 0.5, 0) on white at full brightness", 1, 0, 1, 0.5f, 0, 1, "FF8000FF"},
        {"tint (0, 1, 1) with brightness 0.5 halves the tinted colour", 0.5f, 0, 0, 1, 1, 1, "008080FF"},
        {"sky 1 at daylight 1 is full brightness", 0.1f, 1, 1, 1, 1, 1, "FFFFFFFF"},
        {"sky 1 at daylight 0.5 is half brightness", 0.1f, 1, 1, 1, 1, 0.5f, "808080FF"},
        {"sky 1 at daylight 0.2 under a block light brightness 0.6 stays at the brighter term", 0.6f, 1, 1, 1, 1, 0.2f, "999999FF"},
        {"sky 0 ignores the daylight", 0.5f, 0, 1, 1, 1, 0.1f, "808080FF"},
    };
    for (size_t c = 0; c < sizeof cases / sizeof cases[0]; c++) {
        for (int v = 0; v < 6; v++) {
            float *f = lit + v * 11;
            f[5] = cases[c].brightness;
            f[7] = cases[c].sky;
            f[8] = cases[c].r;
            f[9] = cases[c].g;
            f[10] = cases[c].b;
        }
        cc_vk_mesh(3, lit, 6);
        cc_vk_daylight(&cases[c].daylight);
        cc_vk_frame_begin(clear);
        cc_vk_draw(3, CC_PIPE_OPAQUE, CC_TEX_BLOCKS, IDENTITY);
        cc_vk_submit();
        int xs[1] = {(int)S.extent.width / 2};
        int ys[1] = {(int)S.extent.height / 2};
        char pixels[1][9];
        read_pixels(1, xs, ys, pixels);
        cc_vk_present();
        snprintf(name, sizeof name, "test cc_vk %s", cases[c].what);
        tl_str(name, cases[c].expect, pixels[0]);
    }
    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
