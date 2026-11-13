/* Shared state between the shim's own modules (not part of the contract surface, never included by
 * other packages). cc_vk creates its Vulkan surface on the window cc_win owns; cc_vk keeps its Vulkan
 * objects in one state record, and frame submission is split in two steps that cc_vk_frame_end runs
 * in order (the shim's own tests read a rendered image between them). cc_tls runs TLS over cc_net
 * connections and tells cc_net_poll what its sockets wait for. */
#ifndef COBOLCRAFT_CC_INTERNAL_H
#define COBOLCRAFT_CC_INTERNAL_H

#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>
#include <stdint.h>

#include "ccshim.h"

/* cc_net handles are a socket's file descriptor plus 1, for descriptors below this bound. */
#define CC_NET_MAX_FD 4096

/* Set by cc_tls when it opens its first TLS connection (so a program that never calls cc_tls does
 * not link OpenSSL). cc_net_poll asks it, for each listed socket, which poll events the socket's
 * TLS layer waits for (0 for a socket without TLS, or while its TCP connect is still running: cc_net
 * then decides), and whether decrypted bytes are already buffered, which make the handle ready
 * without the socket being readable (shim-abi.md §6). */
extern short (*cc_net_tls_events)(int fd, int *buffered);

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
    uint32_t mips;
    int32_t width, height;
    uint8_t *pixels; /* the whole mip chain on the host (RGBA, level 0 first); an update recomputes only the changed rectangle */
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
    VkPipeline pipelines[4];
    float daylight;           /* cc_vk_daylight: pushed with every draw (default 1) */
    float fog[8];             /* cc_vk_fog: colour rgb, strength, start, end, p00, p11 (strength 0 and p00 = p11 = 1 until set) */
    VkSampler sampler;        /* clamp-to-edge */
    VkSampler repeat_sampler; /* repeat (cc_vk_texture_wrap) */
    VkSampler mip_sampler;        /* linear through the mip chain, clamp-to-edge */
    VkSampler mip_repeat_sampler; /* the same with repeat */
    int32_t wrap[4];          /* per texture id: CC_WRAP_CLAMP or CC_WRAP_REPEAT */
    VkCommandPool commands;
    VkCommandBuffer cmd;
    VkSemaphore acquired;
    VkFence done;
    uint32_t image_index;
    int stale;
    texture_t textures[5];
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
