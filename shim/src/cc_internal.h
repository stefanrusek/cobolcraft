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
/* Frames the CPU may record and submit before the GPU has finished the oldest one (CC_VK_INFLIGHT=1 picks one). */
#define CC_VK_FRAMES 2
/* Entries of the CC_GPU_STATS phase table (ccshim.h CC_PHASE_*, 1 to 10; 0 unused). */
#define CC_PHASES 11

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

/* A resource waiting for the GPU to finish with it (any field may be VK_NULL_HANDLE). `stamp` is set by
 * discard(): the resource is destroyed once `frames_completed` has reached it (the frame recorded or
 * next recorded when it was discarded has completed, and with it every submission before that frame). */
typedef struct {
    VkBuffer buffer;
    VkImage image;
    VkImageView view;
    VkDeviceMemory memory;
    VkDescriptorSet set;
    uint64_t stamp;
} garbage_t;

/* All Vulkan objects of cc_vk (up to CC_VK_FRAMES frames in flight, each with its own command buffer,
 * acquire semaphore and fence). */
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
    VkPipeline pipelines[6];
    float daylight;           /* cc_vk_daylight: pushed with every draw (default 1) */
    float fog[13];            /* cc_vk_fog: colour rgb, strength, start, end, p00, p11, up xyz, render-distance start, end (strength 0, p00 = p11 = 1, up (0, 1, 0), start 1e9 until set) */
    float glint_uv[2];        /* cc_vk_glint_offset: pushed with the CC_PIPE_GLINT draws (0 for the others) */
    VkSampler sampler;        /* clamp-to-edge */
    VkSampler repeat_sampler; /* repeat (cc_vk_texture_wrap) */
    VkSampler mip_sampler;        /* linear through the mip chain, clamp-to-edge */
    VkSampler mip_repeat_sampler; /* the same with repeat */
    int32_t wrap[7];          /* per texture id: CC_WRAP_CLAMP or CC_WRAP_REPEAT */
    VkCommandPool commands;
    VkCommandBuffer cmd[CC_VK_FRAMES]; /* frame n records into slot n % in_flight */
    VkSemaphore acquired[CC_VK_FRAMES];
    VkFence done[CC_VK_FRAMES];        /* created signalled: signalled by the frame's submission, waited for by frame_begin of the slot's next use */
    uint32_t in_flight;                /* 1 or CC_VK_FRAMES (CC_VK_INFLIGHT) */
    uint64_t frames_submitted;         /* frames handed to the queue; also the index of the frame being recorded */
    uint64_t frames_completed;         /* frames 0 .. frames_completed - 1 are known to have finished on the GPU */
    VkPresentModeKHR present_mode;     /* chosen for the swapchain (CC_VK_PRESENT, FIFO unless the surface offers the one asked for) */
    VkQueryPool queries;               /* two timestamps per slot while CC_GPU_STATS is set and the queue supports them, else VK_NULL_HANDLE */
    float timestamp_period;            /* nanoseconds per timestamp tick */
    uint32_t image_index;
    int stale;
    texture_t textures[7];
    mesh_t meshes[CC_MESH_SLOT_MAX + 1];
    garbage_t *garbage;
    size_t garbage_count, garbage_cap;
};
extern struct cc_vk_state cc_vk_state;

/* The two halves of cc_vk_frame_end: end recording and submit the frame's commands; then present the
 * frame's image. cc_vk_frame_end does not wait for the GPU (the next frames are recorded while it
 * draws); cc_vk_submit, which the shim's own tests call, waits until the GPU has finished the frame,
 * so that the image can be read between the two: rendered and still owned by the application. */
void cc_vk_submit(void);
void cc_vk_present(void);

/* CC_GPU_STATS=1: prints the counters gathered since the last report (one line on standard error, only
 * when a frame was presented) and starts a new window. cc_vk_frame_end does it once a second and
 * cc_vk_shutdown at the end; exposed for the shim's tests. */
void cc_vk_stats_flush(void);

/* Staging uploads of batched texture updates still waiting for the GPU (exposed for the shim's tests). */
int cc_vk_uploads_pending(void);

#endif
