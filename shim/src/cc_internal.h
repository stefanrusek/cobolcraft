/* Shared state between the shim's own modules (not part of the contract surface, never included by
 * other packages). cc_vk creates its Vulkan surface on the window cc_win owns; cc_vk keeps its Vulkan
 * objects in one state record, and frame submission is split in two steps that cc_vk_frame_end runs
 * in order (the shim's own tests read a rendered image between them). */
#ifndef COBOLCRAFT_CC_INTERNAL_H
#define COBOLCRAFT_CC_INTERNAL_H

#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>
#include <stdint.h>

#include "ccshim.h"

/* The window opened by cc_win_open; NULL while none is open. */
extern GLFWwindow *cc_win_window;

#define CC_VK_MAX_IMAGES 8
#define CC_VK_MAX_SETS 256

typedef struct {
    VkBuffer buffer;
    VkDeviceMemory memory;
    uint32_t count;
} mesh_t;

typedef struct {
    VkImage image;
    VkDeviceMemory memory;
    VkImageView view;
    VkDescriptorSet set;
} texture_t;

/* A resource waiting for the GPU to finish with it (any field may be VK_NULL_HANDLE). */
typedef struct {
    VkBuffer buffer;
    VkImage image;
    VkImageView view;
    VkDeviceMemory memory;
    VkDescriptorSet set;
} garbage_t;

/* All Vulkan objects of cc_vk (one frame in flight). */
struct cc_vk_state {
    VkInstance instance;
    VkSurfaceKHR surface;
    VkPhysicalDevice gpu;
    VkPhysicalDeviceMemoryProperties memory_properties;
    uint32_t family;
    VkDevice device;
    VkQueue queue;
    VkSurfaceFormatKHR format;
    VkRenderPass render_pass;
    VkSwapchainKHR swapchain;
    VkExtent2D extent;
    int fb_w, fb_h;
    uint32_t image_count;
    VkImage images[CC_VK_MAX_IMAGES];
    VkImageView views[CC_VK_MAX_IMAGES];
    VkFramebuffer framebuffers[CC_VK_MAX_IMAGES];
    VkSemaphore rendered[CC_VK_MAX_IMAGES];
    VkImage depth;
    VkDeviceMemory depth_memory;
    VkImageView depth_view;
    VkDescriptorSetLayout set_layout;
    VkDescriptorPool pool;
    VkPipelineLayout layout;
    VkPipeline pipelines[3];
    VkSampler sampler;
    VkCommandPool commands;
    VkCommandBuffer cmd;
    VkSemaphore acquired;
    VkFence done;
    uint32_t image_index;
    int stale;
    texture_t textures[4];
    mesh_t meshes[CC_MESH_SLOT_MAX + 1];
    garbage_t *garbage;
    size_t garbage_count, garbage_cap;
};
extern struct cc_vk_state cc_vk_state;

/* The two halves of cc_vk_frame_end: end recording and submit the frame's commands, waiting until
 * the GPU has finished them; then present the frame's image. Between the two the image is rendered
 * and still owned by the application. */
void cc_vk_submit(void);
void cc_vk_present(void);

#endif
