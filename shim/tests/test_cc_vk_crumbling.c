/* Implementation test of CC_PIPE_CRUMBLING (12 section 4.3, the crack overlay) against the real GPU. An opaque
 * quad (texture 0: colour 100, 200, 50) is drawn, then a crumbling quad over it at the same depth. The
 * crumbling blend is result.rgb = src.rgb * dst.rgb + dst.rgb * src.rgb (factors DST_COLOR and SRC_COLOR) and
 * result.a = src.a (factors ONE and ZERO): a texel of 64 (0x40) darkens the pixel to 2 * 64 / 255 of it
 * (50, 100, 25), alpha 255. A texel whose alpha is under 0.1 is discarded (the pixel stays), and a crumbling
 * quad behind the opaque one fails the depth test (the pixel stays). */
#include <stdio.h>
#include <string.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"

#define S cc_vk_state

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


static void quad(float z, float *out) {
    static const float base[6][7] = {
        {-0.5f, -0.5f, 0, 0, 0, 1, 1}, {0.5f, -0.5f, 0, 1, 0, 1, 1}, {0.5f, 0.5f, 0, 1, 1, 1, 1},
        {-0.5f, -0.5f, 0, 0, 0, 1, 1}, {0.5f, 0.5f, 0, 1, 1, 1, 1}, {-0.5f, 0.5f, 0, 0, 1, 1, 1},
    };
    for (int i = 0; i < 6; i++) {
        memcpy(out + i * 7, base[i], sizeof base[i]);
        out[i * 7 + 2] = z;
    }
}

/* One frame: the opaque quad (z 0.5), then the crumbling quad at depth z; the centre pixel. */
static void frame(float z, char out[9]) {
    float crack[6 * 7];
    quad(z, crack);
    cc_vk_mesh(2, crack, 6);
    const float clear[4] = {0, 0, 0, 1};
    cc_vk_frame_begin(clear);
    cc_vk_draw(1, CC_PIPE_OPAQUE, CC_TEX_BLOCKS, IDENTITY);
    cc_vk_draw(2, CC_PIPE_CRUMBLING, CC_TEX_ENTITIES, IDENTITY);
    cc_vk_submit();
    centre_pixel(out);
    cc_vk_present();
}

int main(void) {
    cc_win_open(320, 240, "test_cc_vk_crumbling", 0);
    cc_vk_init();
    tl_int("test cc_vk swapchain format is 8-bit UNORM (pixel values are compared exactly)", 1,
           S.format.format == VK_FORMAT_B8G8R8A8_UNORM || S.format.format == VK_FORMAT_R8G8B8A8_UNORM);
    static const uint8_t ground[2 * 2 * 4] = {100, 200, 50, 255, 100, 200, 50, 255, 100, 200, 50, 255, 100, 200, 50, 255};
    static const uint8_t dark[2 * 2 * 4] = {64, 64, 64, 255, 64, 64, 64, 255, 64, 64, 64, 255, 64, 64, 64, 255};
    static const uint8_t clear_texel[2 * 2 * 4] = {64, 64, 64, 0, 64, 64, 64, 0, 64, 64, 64, 0, 64, 64, 64, 0};
    float opaque[6 * 7];
    quad(0.5f, opaque);
    cc_vk_mesh(1, opaque, 6);
    cc_vk_texture(CC_TEX_BLOCKS, 2, 2, ground);
    char pixel[9];
    cc_vk_texture(CC_TEX_ENTITIES, 2, 2, dark);
    frame(0.5f, pixel);
    tl_str("test cc_vk crumbling quad at the same depth darkens the pixel to 2 x src x dst (64 -> 50, 100, 25)", "326419FF", pixel);
    frame(0.9f, pixel);
    tl_str("test cc_vk crumbling quad behind the opaque quad fails the depth test (pixel stays)", "64C832FF", pixel);
    cc_vk_texture(CC_TEX_ENTITIES, 2, 2, clear_texel);
    frame(0.5f, pixel);
    tl_str("test cc_vk crumbling texel with alpha under 0.1 is discarded (pixel stays)", "64C832FF", pixel);
    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
