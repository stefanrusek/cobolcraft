/* Shared by test_cc_vk_texture_ex.c and test_cc_vk_texture_update.c: reads one mip level of a texture
 * of cc_vk_state back to host memory on the real device. Include after cc_internal.h. */
#ifndef VK_READBACK_H
#define VK_READBACK_H

#include <stdint.h>
#include <string.h>

#include "cc_internal.h"

static inline uint32_t rb_host_memory_type(uint32_t bits) {
    VkMemoryPropertyFlags want = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    uint32_t i = 0;
    while (!((bits >> i & 1u) && (cc_vk_state.memory_properties.memoryTypes[i].propertyFlags & want) == want)) i++;
    return i;
}

static inline void rb_barrier(VkCommandBuffer cmd, VkImage image, VkImageLayout from, VkImageLayout to) {
    VkImageMemoryBarrier b = {
        .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
        .srcAccessMask = VK_ACCESS_MEMORY_WRITE_BIT,
        .dstAccessMask = VK_ACCESS_MEMORY_READ_BIT,
        .oldLayout = from,
        .newLayout = to,
        .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
        .image = image,
        .subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, 0, VK_REMAINING_MIP_LEVELS, 0, 1},
    };
    vkCmdPipelineBarrier(cmd, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, 0, 0, NULL, 0, NULL, 1, &b);
}

/* Writes the w x h RGBA pixels of mip level `level` of texture `tex_id` to out (w * h * 4 bytes). */
static inline void read_level(int32_t tex_id, uint32_t level, uint32_t w, uint32_t h, uint8_t *out) {
    VkDeviceSize size = (VkDeviceSize)w * h * 4;
    VkBufferCreateInfo info = {.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .size = size, .usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT};
    VkBuffer buffer;
    vkCreateBuffer(cc_vk_state.device, &info, NULL, &buffer);
    VkMemoryRequirements need;
    vkGetBufferMemoryRequirements(cc_vk_state.device, buffer, &need);
    VkMemoryAllocateInfo alloc = {
        .sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = need.size,
        .memoryTypeIndex = rb_host_memory_type(need.memoryTypeBits),
    };
    VkDeviceMemory memory;
    vkAllocateMemory(cc_vk_state.device, &alloc, NULL, &memory);
    vkBindBufferMemory(cc_vk_state.device, buffer, memory, 0);
    VkCommandBufferAllocateInfo cmd_info = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = cc_vk_state.commands,
        .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = 1,
    };
    VkCommandBuffer cmd;
    vkAllocateCommandBuffers(cc_vk_state.device, &cmd_info, &cmd);
    VkCommandBufferBeginInfo begin = {.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO};
    vkBeginCommandBuffer(cmd, &begin);
    VkImage image = cc_vk_state.textures[tex_id].image;
    rb_barrier(cmd, image, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL);
    VkBufferImageCopy region = {.imageSubresource = {VK_IMAGE_ASPECT_COLOR_BIT, level, 0, 1}, .imageExtent = {w, h, 1}};
    vkCmdCopyImageToBuffer(cmd, image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, buffer, 1, &region);
    rb_barrier(cmd, image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
    vkEndCommandBuffer(cmd);
    VkSubmitInfo submit = {.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = &cmd};
    vkQueueSubmit(cc_vk_state.queue, 1, &submit, VK_NULL_HANDLE);
    vkQueueWaitIdle(cc_vk_state.queue);
    void *mapped;
    vkMapMemory(cc_vk_state.device, memory, 0, size, 0, &mapped);
    memcpy(out, mapped, (size_t)size);
    vkUnmapMemory(cc_vk_state.device, memory);
    vkFreeCommandBuffers(cc_vk_state.device, cc_vk_state.commands, 1, &cmd);
    vkDestroyBuffer(cc_vk_state.device, buffer, NULL);
    vkFreeMemory(cc_vk_state.device, memory, NULL);
}

#endif
