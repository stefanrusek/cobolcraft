/* Implementation test of cc_vk_clear_depth (contracts/shim-delta.md, 12 §6) against the real GPU.
 * A near quad (z 0.3, red) is drawn with the opaque pipeline, then a far quad (z 0.7, blue) over the
 * same area. Without a depth clear the far quad is rejected by the depth test and the centre pixel
 * stays red (this shows the test can tell); with cc_vk_clear_depth between the two draws the far
 * quad draws over the near one and the centre pixel is blue. */
#include <stdio.h>
#include <string.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"

#define S cc_vk_state

static const float NEAR_QUAD[6 * 7] = {
    -0.5f, -0.5f, 0.3f, 0, 0, 1, 1,  0.5f, -0.5f, 0.3f, 1, 0, 1, 1,  0.5f, 0.5f, 0.3f, 1, 1, 1, 1,
    -0.5f, -0.5f, 0.3f, 0, 0, 1, 1,  0.5f, 0.5f, 0.3f, 1, 1, 1, 1,  -0.5f, 0.5f, 0.3f, 0, 1, 1, 1,
};
static const float FAR_QUAD[6 * 7] = {
    -0.5f, -0.5f, 0.7f, 0, 0, 1, 1,  0.5f, -0.5f, 0.7f, 1, 0, 1, 1,  0.5f, 0.5f, 0.7f, 1, 1, 1, 1,
    -0.5f, -0.5f, 0.7f, 0, 0, 1, 1,  0.5f, 0.5f, 0.7f, 1, 1, 1, 1,  -0.5f, 0.5f, 0.7f, 0, 1, 1, 1,
};
static const float IDENTITY[16] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};

/* Colour of the frame's centre pixel as "RRGGBBAA" (copy of the swapchain image after the pass). */
static void centre_pixel(char out[9]) {
    VkExtent2D e = S.extent;
    VkDeviceSize size = (VkDeviceSize)e.width * e.height * 4;
    VkBufferCreateInfo info = {.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .size = size, .usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT};
    VkBuffer buffer;
    vkCreateBuffer(S.device, &info, NULL, &buffer);
    VkMemoryRequirements need;
    vkGetBufferMemoryRequirements(S.device, buffer, &need);
    VkMemoryPropertyFlags want = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    uint32_t type = 0;
    while (!((need.memoryTypeBits >> type & 1u) && (S.memory_properties.memoryTypes[type].propertyFlags & want) == want)) type++;
    VkMemoryAllocateInfo alloc = {.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = need.size, .memoryTypeIndex = type};
    VkDeviceMemory memory;
    vkAllocateMemory(S.device, &alloc, NULL, &memory);
    vkBindBufferMemory(S.device, buffer, memory, 0);
    VkCommandBufferAllocateInfo cmd_info = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, .commandPool = S.commands,
        .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY, .commandBufferCount = 1,
    };
    VkCommandBuffer cmd;
    vkAllocateCommandBuffers(S.device, &cmd_info, &cmd);
    VkCommandBufferBeginInfo begin = {.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO};
    vkBeginCommandBuffer(cmd, &begin);
    VkImage image = S.images[S.image_index];
    VkImageMemoryBarrier b = {
        .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER, .srcAccessMask = VK_ACCESS_MEMORY_WRITE_BIT,
        .dstAccessMask = VK_ACCESS_MEMORY_READ_BIT, .oldLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
        .newLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED, .image = image,
        .subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1},
    };
    vkCmdPipelineBarrier(cmd, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, 0, 0, NULL, 0, NULL, 1, &b);
    VkBufferImageCopy region = {.imageSubresource = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1}, .imageExtent = {e.width, e.height, 1}};
    vkCmdCopyImageToBuffer(cmd, image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, buffer, 1, &region);
    b.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL;
    b.newLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR;
    vkCmdPipelineBarrier(cmd, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, 0, 0, NULL, 0, NULL, 1, &b);
    vkEndCommandBuffer(cmd);
    VkSubmitInfo submit = {.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = &cmd};
    vkQueueSubmit(S.queue, 1, &submit, VK_NULL_HANDLE);
    vkQueueWaitIdle(S.queue);
    uint8_t *pixels;
    vkMapMemory(S.device, memory, 0, size, 0, (void **)&pixels);
    int bgra = S.format.format == VK_FORMAT_B8G8R8A8_UNORM || S.format.format == VK_FORMAT_B8G8R8A8_SRGB;
    const uint8_t *p = pixels + ((size_t)(e.height / 2) * e.width + e.width / 2) * 4;
    snprintf(out, 9, "%02X%02X%02X%02X", p[bgra ? 2 : 0], p[1], p[bgra ? 0 : 2], p[3]);
    vkUnmapMemory(S.device, memory);
    vkFreeCommandBuffers(S.device, S.commands, 1, &cmd);
    vkDestroyBuffer(S.device, buffer, NULL);
    vkFreeMemory(S.device, memory, NULL);
}

/* One frame: near quad (red), optional depth clear, far quad (blue); returns the centre pixel. */
static void frame(int clear_between, char out[9]) {
    const float clear[4] = {0, 0, 0, 1};
    cc_vk_frame_begin(clear);
    cc_vk_draw(1, CC_PIPE_OPAQUE, CC_TEX_BLOCKS, IDENTITY);
    if (clear_between) cc_vk_clear_depth();
    cc_vk_draw(2, CC_PIPE_OPAQUE, CC_TEX_ENVIRONMENT, IDENTITY);
    cc_vk_submit();
    centre_pixel(out);
    cc_vk_present();
}

int main(void) {
    cc_win_open(320, 240, "test_cc_vk_clear_depth", 0);
    cc_vk_init();
    tl_int("test cc_vk swapchain format is 8-bit UNORM (pixel values are compared exactly)", 1,
           S.format.format == VK_FORMAT_B8G8R8A8_UNORM || S.format.format == VK_FORMAT_R8G8B8A8_UNORM);
    static const uint8_t red[2 * 2 * 4] = {0xff, 0, 0, 0xff, 0xff, 0, 0, 0xff, 0xff, 0, 0, 0xff, 0xff, 0, 0, 0xff};
    static const uint8_t blue[2 * 2 * 4] = {0, 0, 0xff, 0xff, 0, 0, 0xff, 0xff, 0, 0, 0xff, 0xff, 0, 0, 0xff, 0xff};
    cc_vk_texture(CC_TEX_BLOCKS, 2, 2, red);
    cc_vk_texture(CC_TEX_ENVIRONMENT, 2, 2, blue);
    cc_vk_mesh(1, NEAR_QUAD, 6);
    cc_vk_mesh(2, FAR_QUAD, 6);
    char pixel[9];
    frame(0, pixel);
    tl_str("test cc_vk far quad after near quad without a depth clear stays hidden (centre is red)", "FF0000FF", pixel);
    frame(1, pixel);
    tl_str("test cc_vk_clear_depth lets a quad behind the first draw over it (centre is blue)", "0000FFFF", pixel);
    frame(0, pixel);
    tl_str("test cc_vk depth is cleared again at the next frame begin (no clear call, centre is red)", "FF0000FF", pixel);
    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
