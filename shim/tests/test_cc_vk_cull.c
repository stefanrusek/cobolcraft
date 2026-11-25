/* Implementation test of CC_PIPE_TRANSLUCENT_CULL (bug-sweep T10401: translucent blocks showed their back faces) against the real GPU. A quad
 * whose corners run clockwise on the screen (the winding of the block meshes, seen from outside) is drawn with the pipeline: its texel (alpha
 * 190) is blended over the clear colour; the same quad with the corners reversed (seen from behind) is culled and leaves the clear colour; the
 * pipeline without the culling (CC_PIPE_TRANSLUCENT) draws both.
 * Also (bug-sweep T10404: the grass block's tinted side overlay was never seen): of two opaque quads at the same depth the one drawn second wins
 * (depth test less or equal, as the renderer's solid layers have it).
 * CC_PIPE_OPAQUE_CULL (CC-0013: a face between two leaf blocks is two coplanar quads that face opposite ways, and without the culling they fought for the
 * pixel while the camera moved) is the opaque pipeline with the back faces culled: the front quad is drawn opaque (no blend), the reversed one is dropped,
 * it writes depth (a nearer quad hides a farther one drawn after it) and, like the opaque pipeline, it passes equal depth (of two quads at the same depth the
 * second wins). */
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



/* A quad (two triangles) with the corners 1 2 3 4 at (-.5,-.5) (.5,-.5) (.5,.5) (-.5,.5), or in the reverse order, at depth z. */
static void quad_z(int reverse, float z, float *out) {
    static const float c[4][2] = {{-0.5f, -0.5f}, {0.5f, -0.5f}, {0.5f, 0.5f}, {-0.5f, 0.5f}};
    static const float uv[4][2] = {{0, 0}, {1, 0}, {1, 1}, {0, 1}};
    static const int fwd[6] = {0, 1, 2, 0, 2, 3};
    static const int rev[6] = {0, 2, 1, 0, 3, 2};
    for (int i = 0; i < 6; i++) {
        int k = reverse ? rev[i] : fwd[i];
        float v[11] = {c[k][0], c[k][1], z, uv[k][0], uv[k][1], 1, 1, 0, 1, 1, 1};
        memcpy(out + i * 11, v, sizeof v);
    }
}

static void quad(int reverse, float *out) {
    quad_z(reverse, 0.5f, out);
}

static void frame(int reverse, int pipeline, char out[9]) {
    float mesh[6 * 11];
    quad(reverse, mesh);
    cc_vk_mesh(1, mesh, 6);
    const float clear[4] = {0, 0, 0, 1};
    cc_vk_frame_begin(clear);
    cc_vk_draw(1, pipeline, CC_TEX_BLOCKS, IDENTITY);
    cc_vk_submit();
    centre_pixel(out);
    cc_vk_present();
}

static float mesh_first[6 * 11];

int main(void) {
    cc_win_open(320, 240, "test_cc_vk_cull", 0);
    cc_vk_init();
    tl_int("test cc_vk swapchain format is 8-bit UNORM (pixel values are compared exactly)", 1,
           S.format.format == VK_FORMAT_B8G8R8A8_UNORM || S.format.format == VK_FORMAT_R8G8B8A8_UNORM);
    static const uint8_t texel[2 * 2 * 4] = {200, 100, 50, 255, 200, 100, 50, 255, 200, 100, 50, 255, 200, 100, 50, 255};
    cc_vk_texture(CC_TEX_BLOCKS, 2, 2, texel);
    char front[9], back[9];
    frame(0, CC_PIPE_TRANSLUCENT_CULL, front);
    frame(1, CC_PIPE_TRANSLUCENT_CULL, back);
    tl_str("test cc_vk the translucent pipeline with culling draws a quad seen from the front", "C86432FF", front);
    tl_str("test cc_vk the translucent pipeline with culling drops a quad seen from behind", "000000FF", back);
    frame(1, CC_PIPE_TRANSLUCENT, back);
    tl_str("test cc_vk the translucent pipeline without culling draws a quad seen from behind", "C86432FF", back);
    frame(0, CC_PIPE_OPAQUE_CULL, front);
    frame(1, CC_PIPE_OPAQUE_CULL, back);
    tl_str("test cc_vk the opaque pipeline with culling draws a quad seen from the front, opaque", "C86432FF", front);
    tl_str("test cc_vk the opaque pipeline with culling drops a quad seen from behind", "000000FF", back);
    frame(1, CC_PIPE_OPAQUE, back);
    tl_str("test cc_vk the opaque pipeline without culling draws a quad seen from behind", "C86432FF", back);
    static const uint8_t other[2 * 2 * 4] = {10, 220, 30, 255, 10, 220, 30, 255, 10, 220, 30, 255, 10, 220, 30, 255};
    cc_vk_texture(CC_TEX_ENTITIES, 2, 2, other);
    float second[6 * 11];
    quad(0, second);
    cc_vk_mesh(2, second, 6);
    quad(0, mesh_first);
    cc_vk_mesh(1, mesh_first, 6);
    const float clear[4] = {0, 0, 0, 1};
    cc_vk_frame_begin(clear);
    cc_vk_draw(1, CC_PIPE_OPAQUE, CC_TEX_BLOCKS, IDENTITY);
    cc_vk_draw(2, CC_PIPE_OPAQUE, CC_TEX_ENTITIES, IDENTITY);
    cc_vk_submit();
    centre_pixel(back);
    cc_vk_present();
    tl_str("test cc_vk of two opaque quads at the same depth the second wins", "0ADC1EFF", back);
    cc_vk_mesh(1, mesh_first, 6);
    cc_vk_mesh(2, second, 6);
    cc_vk_frame_begin(clear);
    cc_vk_draw(1, CC_PIPE_OPAQUE_CULL, CC_TEX_BLOCKS, IDENTITY);
    cc_vk_draw(2, CC_PIPE_OPAQUE_CULL, CC_TEX_ENTITIES, IDENTITY);
    cc_vk_submit();
    centre_pixel(back);
    cc_vk_present();
    tl_str("test cc_vk of two culling opaque quads at the same depth the second wins (depth test less or equal)", "0ADC1EFF", back);
    float near_quad[6 * 11], far_quad[6 * 11];
    quad_z(0, 0.3f, near_quad);
    quad_z(0, 0.7f, far_quad);
    cc_vk_mesh(1, near_quad, 6);
    cc_vk_mesh(2, far_quad, 6);
    cc_vk_frame_begin(clear);
    cc_vk_draw(1, CC_PIPE_OPAQUE_CULL, CC_TEX_BLOCKS, IDENTITY);
    cc_vk_draw(2, CC_PIPE_OPAQUE, CC_TEX_ENTITIES, IDENTITY);
    cc_vk_submit();
    centre_pixel(back);
    cc_vk_present();
    tl_str("test cc_vk the culling opaque pipeline writes depth: a farther quad drawn after it is hidden", "C86432FF", back);
    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
