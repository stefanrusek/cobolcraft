/* Implementation test of CC_PIPE_GLINT (54 section 19.3, the enchantment glint pass) against the real GPU. An opaque quad (texture 0:
 * colour 100, 200, 50) is drawn, then a glint quad over it at the same depth. The blend is additive, result.rgb = src.rgb * src.rgb +
 * dst.rgb (factors SRC_COLOR and ONE), result.a = dst.a (factors ZERO and ONE): a texel of 128 adds 128/255 squared = 64 to each channel
 * (164, 255 clamped, 114). A glint quad behind the opaque one fails the depth test (the pixel stays). The glint has its own texture id
 * (CC_TEX_GLINT, repeat wrap) and cc_vk_glint_offset shifts the texture coordinates of CC_PIPE_GLINT draws only (the scrolling of 54 section
 * 19.4 without rebuilding the mesh): the textures here are 2 x 2 with a left column and a right column, the quads sample u 0 to 0.4. */
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
    static const float base[6][11] = {
        {-0.5f, -0.5f, 0, 0, 0, 1, 1, 0, 1, 1, 1}, {0.5f, -0.5f, 0, 0.4f, 0, 1, 1, 0, 1, 1, 1}, {0.5f, 0.5f, 0, 0.4f, 0.4f, 1, 1, 0, 1, 1, 1},
        {-0.5f, -0.5f, 0, 0, 0, 1, 1, 0, 1, 1, 1}, {0.5f, 0.5f, 0, 0.4f, 0.4f, 1, 1, 0, 1, 1, 1}, {-0.5f, 0.5f, 0, 0, 0.4f, 1, 1, 0, 1, 1, 1},
    };
    for (int i = 0; i < 6; i++) {
        memcpy(out + i * 11, base[i], sizeof base[i]);
        out[i * 11 + 2] = z;
    }
}

/* One frame: the opaque quad (z 0.5), then the glint quad at depth z with the given texture; the centre pixel. */
static void frame(float z, int tex, char out[9]) {
    float glint[6 * 11];
    quad(z, glint);
    cc_vk_mesh(2, glint, 6);
    const float clear[4] = {0, 0, 0, 1};
    cc_vk_frame_begin(clear);
    cc_vk_draw(1, CC_PIPE_OPAQUE, CC_TEX_BLOCKS, IDENTITY);
    cc_vk_draw(2, CC_PIPE_GLINT, tex, IDENTITY);
    cc_vk_submit();
    centre_pixel(out);
    cc_vk_present();
}

int main(void) {
    cc_win_open(320, 240, "test_cc_vk_glint", 0);
    cc_vk_init();
    tl_int("test cc_vk swapchain format is 8-bit UNORM (pixel values are compared exactly)", 1,
           S.format.format == VK_FORMAT_B8G8R8A8_UNORM || S.format.format == VK_FORMAT_R8G8B8A8_UNORM);
    static const uint8_t ground[2 * 2 * 4] = {100, 200, 50, 255, 10, 20, 30, 255, 100, 200, 50, 255, 10, 20, 30, 255};
    static const uint8_t shine[2 * 2 * 4] = {128, 128, 128, 255, 0, 0, 0, 255, 128, 128, 128, 255, 0, 0, 0, 255};
    float opaque[6 * 11];
    quad(0.5f, opaque);
    cc_vk_mesh(1, opaque, 6);
    cc_vk_texture(CC_TEX_BLOCKS, 2, 2, ground);
    cc_vk_texture(CC_TEX_ENTITIES, 2, 2, shine);
    char pixel[9];
    frame(0.5f, CC_TEX_ENTITIES, pixel);
    tl_str("test cc_vk glint quad at the same depth adds src x src (128 -> +64: 164, 255, 114)", "A4FF72FF", pixel);
    frame(0.9f, CC_TEX_ENTITIES, pixel);
    tl_str("test cc_vk glint quad behind the opaque quad fails the depth test (pixel stays)", "64C832FF", pixel);
    cc_vk_texture_wrap(CC_TEX_GLINT, CC_WRAP_REPEAT);
    cc_vk_texture(CC_TEX_GLINT, 2, 2, shine);
    frame(0.5f, CC_TEX_GLINT, pixel);
    tl_str("test cc_vk the glint texture id CC_TEX_GLINT draws like any texture", "A4FF72FF", pixel);
    cc_vk_texture_wrap(CC_TEX_GLINT_ARMOR, CC_WRAP_REPEAT);
    cc_vk_texture(CC_TEX_GLINT_ARMOR, 2, 2, shine);
    frame(0.5f, CC_TEX_GLINT_ARMOR, pixel);
    tl_str("test cc_vk the armour glint texture id CC_TEX_GLINT_ARMOR draws like any texture", "A4FF72FF", pixel);
    float off[2] = {0.5f, 0};
    cc_vk_glint_offset(off);
    frame(0.5f, CC_TEX_GLINT, pixel);
    tl_str("test cc_vk glint offset 0.5 moves the sample to the dark column (no addition) and leaves the opaque pipeline unshifted", "64C832FF", pixel);
    off[0] = 1.0f;
    cc_vk_glint_offset(off);
    frame(0.5f, CC_TEX_GLINT, pixel);
    tl_str("test cc_vk glint offset 1.0 wraps (repeat) back to the bright column", "A4FF72FF", pixel);
    off[0] = 0;
    cc_vk_glint_offset(off);
    frame(0.5f, CC_TEX_GLINT, pixel);
    tl_str("test cc_vk glint offset 0 again restores the unshifted sample", "A4FF72FF", pixel);
    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
