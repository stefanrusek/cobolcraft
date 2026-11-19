/* cc_vk: Vulkan submission (contracts/shim-abi.md §9; research R3, R4). Glue only: every Vulkan call
 * takes nested platform structs. The module decides nothing about what is drawn: it uploads the
 * COBOL-built atlases and vertex buffers and submits draws of them in four fixed pipelines.
 *
 * Instance with VK_KHR_portability_enumeration (MoltenVK), surface on the cc_win window, device with
 * VK_KHR_swapchain (+ VK_KHR_portability_subset when reported), swapchain (FIFO unless CC_VK_PRESENT asks
 * for another mode the surface offers, at least 3 images) on the surface's first format at framebuffer
 * extent, D32_SFLOAT depth, two frames in flight (CC_VK_INFLIGHT=1: one). A frame is submitted and
 * presented without waiting for the GPU; the wait for a frame's fence comes when its slot is next used
 * (cc_vk_frame_begin), so the CPU records frame n + 1 while the GPU draws frame n. Resources replaced or
 * freed while the GPU may still use them are destroyed once the frame that could use them has completed.
 * Batched texture updates are submitted without waiting; their staging buffers are freed likewise.
 * CC_GPU_STATS=1 prints a line of counters to standard error once a second (see stats_report). */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "spirv.h"

struct cc_vk_state cc_vk_state;

static void check(VkResult result, const char *what) {
    if (result != VK_SUCCESS) cc_fatal(what);
}

/* ---- CC_GPU_STATS ----------------------------------------------------------------------------- */

/* Counters of the current one-second window. CPU times are wall-clock milliseconds spent inside the shim call named, summed over
 * the window and printed per frame: `app` is the time between a frame's presentation and the next cc_vk_frame_begin (everything the
 * COBOL program does: simulation, meshing, building the render list, the uploads), `fence` the wait for the GPU to finish the frame
 * that used the slot before, `acquire` vkAcquireNextImageKHR, `record` the cc_vk_draw calls and the other commands recorded
 * between begin and end, `submit` vkQueueSubmit (MoltenVK encodes the Metal commands here, on the calling thread, and waits for a
 * drawable here), `present` vkQueuePresentKHR, `idle` the waits for an idle queue (one-shot uploads, screenshots), `upload` the
 * cc_vk_mesh and cc_vk_texture_update calls. `gpu` is the GPU time of the frame's render pass from two timestamp queries. */
typedef struct {
    uint64_t frames, draws, verts, tex_updates, tex_full, meshes, mesh_verts, idle_waits, gpu_n;
    double app, fence, acquire, record, submit, present, idle, upload, gpu, gpu_max;
} stats_window_t;

static struct {
    int on;
    double report_t, last_end, record_from;
    int queried[CC_VK_FRAMES]; /* the slot's last frame wrote its timestamps */
    stats_window_t w;
} stats;

static double monotonic_ms(void) {
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return (double)t.tv_sec * 1e3 + (double)t.tv_nsec / 1e6;
}

/* The clock while CC_GPU_STATS is set, else 0 (so that the hooks need no branch of their own). */
static double stat_now(void) {
    return stats.on ? monotonic_ms() : 0.0;
}

/* One line, once a second (cc_vk_frame_end) and at shutdown: frames per second and, per frame, the CPU time in each part of the frame
 * loop, the GPU time of the render pass, the draw calls and vertices, the uploads and one-shot waits, then the swapchain's image count,
 * present mode (VkPresentModeKHR: 0 immediate, 1 mailbox, 2 fifo) and the frames in flight. */
void cc_vk_stats_flush(void) {
    stats_window_t *w = &stats.w;
    double now = stat_now(), secs = (now - stats.report_t) / 1e3, n = w->frames ? (double)w->frames : 1.0;
    if (w->frames == 0 || secs <= 0) return;
    double gpu_n = w->gpu_n ? (double)w->gpu_n : 1.0;
    fprintf(stderr,
            "cc_gpu: fps=%.1f frames=%llu | cpu ms/frame: app=%.2f fence=%.2f acquire=%.2f record=%.2f submit=%.2f present=%.2f idle=%.2f upload=%.2f"
            " | gpu ms/frame=%.2f max=%.2f n=%llu | per frame: draws=%.0f verts=%.0f tex_updates=%.2f tex_full=%.2f meshes=%.2f mesh_verts=%.0f idle_waits=%.2f"
            " | images=%u present_mode=%d in_flight=%u\n",
            (double)w->frames / secs, (unsigned long long)w->frames, w->app / n, w->fence / n, w->acquire / n, w->record / n, w->submit / n,
            w->present / n, w->idle / n, w->upload / n, w->gpu / gpu_n, w->gpu_max, (unsigned long long)w->gpu_n, (double)w->draws / n,
            (double)w->verts / n, (double)w->tex_updates / n, (double)w->tex_full / n, (double)w->meshes / n, (double)w->mesh_verts / n,
            (double)w->idle_waits / n, cc_vk_state.image_count, (int)cc_vk_state.present_mode, cc_vk_state.in_flight);
    fflush(stderr);
    memset(w, 0, sizeof *w);
    stats.report_t = now;
}

/* The GPU time of the render pass of the frame that last used `slot`, once its fence has been seen signalled. */
static void stats_gpu_time(uint32_t slot) {
    uint64_t ticks[2];
    if (!stats.on || cc_vk_state.queries == VK_NULL_HANDLE || !stats.queried[slot]) return;
    stats.queried[slot] = 0;
    VkResult got = vkGetQueryPoolResults(cc_vk_state.device, cc_vk_state.queries, slot * 2, 2, sizeof ticks, ticks, sizeof ticks[0], VK_QUERY_RESULT_64_BIT);
    if (got != VK_SUCCESS || ticks[1] < ticks[0]) return;
    double ms = (double)(ticks[1] - ticks[0]) * (double)cc_vk_state.timestamp_period / 1e6;
    stats.w.gpu += ms;
    stats.w.gpu_n++;
    if (ms > stats.w.gpu_max) stats.w.gpu_max = ms;
}

/* ---- memory, buffers, images ------------------------------------------------------------------ */

static uint32_t memory_type(uint32_t bits, VkMemoryPropertyFlags want) {
    uint32_t i = 0;
    while (i < cc_vk_state.memory_properties.memoryTypeCount &&
           !((bits >> i & 1u) && (cc_vk_state.memory_properties.memoryTypes[i].propertyFlags & want) == want)) i++;
    if (i == cc_vk_state.memory_properties.memoryTypeCount) cc_fatal("cc_vk: no suitable memory type");
    return i;
}

static VkDeviceMemory allocate(VkMemoryRequirements need, VkMemoryPropertyFlags want) {
    VkMemoryAllocateInfo info = {
        .sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize = need.size,
        .memoryTypeIndex = memory_type(need.memoryTypeBits, want),
    };
    VkDeviceMemory memory;
    check(vkAllocateMemory(cc_vk_state.device, &info, NULL, &memory), "cc_vk: vkAllocateMemory failed");
    return memory;
}

/* A host-visible, coherent buffer holding a copy of `data`. */
static VkBuffer host_buffer(VkBufferUsageFlags usage, const void *data, VkDeviceSize size, VkDeviceMemory *memory) {
    VkBufferCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size = size,
        .usage = usage,
        .sharingMode = VK_SHARING_MODE_EXCLUSIVE,
    };
    VkBuffer buffer;
    check(vkCreateBuffer(cc_vk_state.device, &info, NULL, &buffer), "cc_vk: vkCreateBuffer failed");
    VkMemoryRequirements need;
    vkGetBufferMemoryRequirements(cc_vk_state.device, buffer, &need);
    *memory = allocate(need, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
    check(vkBindBufferMemory(cc_vk_state.device, buffer, *memory, 0), "cc_vk: vkBindBufferMemory failed");
    void *mapped;
    check(vkMapMemory(cc_vk_state.device, *memory, 0, size, 0, &mapped), "cc_vk: vkMapMemory failed");
    memcpy(mapped, data, (size_t)size);
    vkUnmapMemory(cc_vk_state.device, *memory);
    return buffer;
}

static VkImage device_image(VkFormat format, uint32_t w, uint32_t h, uint32_t mips, VkImageUsageFlags usage, VkDeviceMemory *memory) {
    VkImageCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .imageType = VK_IMAGE_TYPE_2D,
        .format = format,
        .extent = {w, h, 1},
        .mipLevels = mips,
        .arrayLayers = 1,
        .samples = VK_SAMPLE_COUNT_1_BIT,
        .tiling = VK_IMAGE_TILING_OPTIMAL,
        .usage = usage,
        .sharingMode = VK_SHARING_MODE_EXCLUSIVE,
        .initialLayout = VK_IMAGE_LAYOUT_UNDEFINED,
    };
    VkImage image;
    check(vkCreateImage(cc_vk_state.device, &info, NULL, &image), "cc_vk: vkCreateImage failed");
    VkMemoryRequirements need;
    vkGetImageMemoryRequirements(cc_vk_state.device, image, &need);
    *memory = allocate(need, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT);
    check(vkBindImageMemory(cc_vk_state.device, image, *memory, 0), "cc_vk: vkBindImageMemory failed");
    return image;
}

static VkImageView image_view(VkImage image, VkFormat format, VkImageAspectFlags aspect, uint32_t mips) {
    VkImageViewCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        .image = image,
        .viewType = VK_IMAGE_VIEW_TYPE_2D,
        .format = format,
        .subresourceRange = {aspect, 0, mips, 0, 1},
    };
    VkImageView view;
    check(vkCreateImageView(cc_vk_state.device, &info, NULL, &view), "cc_vk: vkCreateImageView failed");
    return view;
}

static void discard(garbage_t item) {
    if (item.memory == VK_NULL_HANDLE) return; /* nothing was allocated */
    if (cc_vk_state.garbage_count == cc_vk_state.garbage_cap) {
        cc_vk_state.garbage_cap = cc_vk_state.garbage_cap * 2 + 16;
        cc_vk_state.garbage = realloc(cc_vk_state.garbage, cc_vk_state.garbage_cap * sizeof *cc_vk_state.garbage);
        if (cc_vk_state.garbage == NULL) cc_fatal("cc_vk: out of memory");
    }
    /* The frame being recorded (index frames_submitted) may draw with it, or the next one will, and a submission made after the last
     * frame (a texture update) may touch it: the frame with that index completing covers all of them (the queue runs in order). */
    item.stamp = cc_vk_state.frames_submitted + 1;
    cc_vk_state.garbage[cc_vk_state.garbage_count++] = item;
}

/* Destroys the discarded resources the GPU has finished with (every one with `all`: it has finished every submitted command). */
static void collect_garbage(int all) {
    size_t kept = 0;
    for (size_t i = 0; i < cc_vk_state.garbage_count; i++) {
        garbage_t *g = &cc_vk_state.garbage[i];
        if (!all && g->stamp > cc_vk_state.frames_completed) {
            cc_vk_state.garbage[kept++] = *g;
            continue;
        }
        vkDestroyBuffer(cc_vk_state.device, g->buffer, NULL);
        vkDestroyImageView(cc_vk_state.device, g->view, NULL);
        vkDestroyImage(cc_vk_state.device, g->image, NULL);
        vkFreeMemory(cc_vk_state.device, g->memory, NULL);
        if (g->set != VK_NULL_HANDLE) vkFreeDescriptorSets(cc_vk_state.device, cc_vk_state.pool, 1, &g->set);
    }
    cc_vk_state.garbage_count = kept;
}

/* ---- one-shot commands ------------------------------------------------------------------------ */

static VkCommandBuffer command_buffer(void) {
    VkCommandBufferAllocateInfo info = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = cc_vk_state.commands,
        .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY,
        .commandBufferCount = 1,
    };
    VkCommandBuffer cmd;
    check(vkAllocateCommandBuffers(cc_vk_state.device, &info, &cmd), "cc_vk: vkAllocateCommandBuffers failed");
    return cmd;
}

static void begin(VkCommandBuffer cmd) {
    VkCommandBufferBeginInfo info = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO,
        .flags = VK_COMMAND_BUFFER_USAGE_ONE_TIME_SUBMIT_BIT,
    };
    check(vkBeginCommandBuffer(cmd, &info), "cc_vk: vkBeginCommandBuffer failed");
}

/* A barrier over mip levels [base, base + count) of a colour image. */
static void barrier_levels(VkCommandBuffer cmd, VkImage image, VkImageLayout from, VkImageLayout to,
                           VkAccessFlags src_access, VkAccessFlags dst_access, VkPipelineStageFlags src_stage,
                           VkPipelineStageFlags dst_stage, uint32_t base, uint32_t count) {
    VkImageMemoryBarrier b = {
        .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
        .srcAccessMask = src_access,
        .dstAccessMask = dst_access,
        .oldLayout = from,
        .newLayout = to,
        .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
        .image = image,
        .subresourceRange = {VK_IMAGE_ASPECT_COLOR_BIT, base, count, 0, 1},
    };
    vkCmdPipelineBarrier(cmd, src_stage, dst_stage, 0, 0, NULL, 0, NULL, 1, &b);
}

/* ---- initialisation --------------------------------------------------------------------------- */

static void create_instance(void) {
    uint32_t glfw_count;
    const char **glfw_extensions = glfwGetRequiredInstanceExtensions(&glfw_count);
    if (glfw_extensions == NULL) cc_fatal("cc_vk_init: Vulkan is not supported by the window system");
    const char *extensions[16];
    if (glfw_count > 15) cc_fatal("cc_vk_init: too many instance extensions");
    memcpy(extensions, glfw_extensions, glfw_count * sizeof *extensions);
    extensions[glfw_count] = VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME;
    VkApplicationInfo app = {
        .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName = "CobolCraft",
        .apiVersion = VK_API_VERSION_1_2,
    };
    VkInstanceCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .flags = VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR,
        .pApplicationInfo = &app,
        .enabledExtensionCount = glfw_count + 1,
        .ppEnabledExtensionNames = extensions,
    };
    check(vkCreateInstance(&info, NULL, &cc_vk_state.instance), "cc_vk_init: vkCreateInstance failed");
    check(glfwCreateWindowSurface(cc_vk_state.instance, cc_win_window, NULL, &cc_vk_state.surface), "cc_vk_init: glfwCreateWindowSurface failed");
}

/* The lowest-numbered queue family of `gpu` with graphics and presentation to the surface, or UINT32_MAX. */
static uint32_t usable_family(VkPhysicalDevice gpu) {
    uint32_t count;
    VkQueueFamilyProperties families[16];
    vkGetPhysicalDeviceQueueFamilyProperties(gpu, &count, NULL);
    count = count < 16 ? count : 16;
    vkGetPhysicalDeviceQueueFamilyProperties(gpu, &count, families);
    uint32_t found = UINT32_MAX;
    for (uint32_t i = count; i-- > 0;) {
        VkBool32 present = VK_FALSE;
        check(vkGetPhysicalDeviceSurfaceSupportKHR(gpu, i, cc_vk_state.surface, &present), "cc_vk_init: surface support query failed");
        if (present && (families[i].queueFlags & VK_QUEUE_GRAPHICS_BIT)) found = i;
    }
    return found;
}

static int has_extension(VkPhysicalDevice gpu, const char *name) {
    uint32_t count;
    check(vkEnumerateDeviceExtensionProperties(gpu, NULL, &count, NULL), "cc_vk_init: extension query failed");
    VkExtensionProperties *properties = calloc(count, sizeof *properties);
    if (properties == NULL) cc_fatal("cc_vk_init: out of memory");
    check(vkEnumerateDeviceExtensionProperties(gpu, NULL, &count, properties), "cc_vk_init: extension query failed");
    int found = 0;
    for (uint32_t i = 0; i < count; i++) found |= strcmp(properties[i].extensionName, name) == 0;
    free(properties);
    return found;
}

static void create_device(void) {
    uint32_t count = 8;
    VkPhysicalDevice gpus[8];
    VkResult listed = vkEnumeratePhysicalDevices(cc_vk_state.instance, &count, gpus);
    if (listed != VK_SUCCESS && listed != VK_INCOMPLETE) cc_fatal("cc_vk_init: vkEnumeratePhysicalDevices failed");
    uint32_t i = 0;
    cc_vk_state.family = UINT32_MAX;
    while (i < count && (cc_vk_state.family = usable_family(gpus[i])) == UINT32_MAX) i++;
    if (i == count) cc_fatal("cc_vk_init: no GPU can present to the window");
    cc_vk_state.gpu = gpus[i];
    vkGetPhysicalDeviceMemoryProperties(cc_vk_state.gpu, &cc_vk_state.memory_properties);
    const char *extensions[] = {VK_KHR_SWAPCHAIN_EXTENSION_NAME, "VK_KHR_portability_subset"};
    float priority = 1.0f;
    VkDeviceQueueCreateInfo queue = {
        .sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = cc_vk_state.family,
        .queueCount = 1,
        .pQueuePriorities = &priority,
    };
    VkDeviceCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .queueCreateInfoCount = 1,
        .pQueueCreateInfos = &queue,
        .enabledExtensionCount = has_extension(cc_vk_state.gpu, extensions[1]) ? 2 : 1,
        .ppEnabledExtensionNames = extensions,
    };
    check(vkCreateDevice(cc_vk_state.gpu, &info, NULL, &cc_vk_state.device), "cc_vk_init: vkCreateDevice failed");
    vkGetDeviceQueue(cc_vk_state.device, cc_vk_state.family, 0, &cc_vk_state.queue);
}

static void create_render_pass(void) {
    uint32_t count = 1;
    VkResult listed = vkGetPhysicalDeviceSurfaceFormatsKHR(cc_vk_state.gpu, cc_vk_state.surface, &count, &cc_vk_state.format);
    if ((listed != VK_SUCCESS && listed != VK_INCOMPLETE) || count == 0) cc_fatal("cc_vk_init: no surface format");
    VkAttachmentDescription attachments[2] = {
        {
            .format = cc_vk_state.format.format,
            .samples = VK_SAMPLE_COUNT_1_BIT,
            .loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR,
            .storeOp = VK_ATTACHMENT_STORE_OP_STORE,
            .stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE,
            .stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE,
            .initialLayout = VK_IMAGE_LAYOUT_UNDEFINED,
            .finalLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
        },
        {
            .format = VK_FORMAT_D32_SFLOAT,
            .samples = VK_SAMPLE_COUNT_1_BIT,
            .loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR,
            .storeOp = VK_ATTACHMENT_STORE_OP_DONT_CARE,
            .stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE,
            .stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE,
            .initialLayout = VK_IMAGE_LAYOUT_UNDEFINED,
            .finalLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
        },
    };
    VkAttachmentReference colour = {0, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL};
    VkAttachmentReference depth = {1, VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL};
    VkSubpassDescription subpass = {
        .pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS,
        .colorAttachmentCount = 1,
        .pColorAttachments = &colour,
        .pDepthStencilAttachment = &depth,
    };
    /* The one depth image is shared by the frames in flight: this frame's depth clear and writes wait for the previous frame's
     * (late fragment tests included) and the colour attachment for the previous use of the swapchain image. */
    VkSubpassDependency dependency = {
        .srcSubpass = VK_SUBPASS_EXTERNAL,
        .dstSubpass = 0,
        .srcStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT | VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT | VK_PIPELINE_STAGE_LATE_FRAGMENT_TESTS_BIT,
        .dstStageMask = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT | VK_PIPELINE_STAGE_EARLY_FRAGMENT_TESTS_BIT,
        .srcAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT | VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT,
        .dstAccessMask = VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT | VK_ACCESS_DEPTH_STENCIL_ATTACHMENT_WRITE_BIT,
    };
    VkRenderPassCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
        .attachmentCount = 2,
        .pAttachments = attachments,
        .subpassCount = 1,
        .pSubpasses = &subpass,
        .dependencyCount = 1,
        .pDependencies = &dependency,
    };
    check(vkCreateRenderPass(cc_vk_state.device, &info, NULL, &cc_vk_state.render_pass), "cc_vk_init: vkCreateRenderPass failed");
}

static void destroy_swapchain_images(void) {
    for (uint32_t i = 0; i < cc_vk_state.image_count; i++) {
        vkDestroyFramebuffer(cc_vk_state.device, cc_vk_state.framebuffers[i], NULL);
        vkDestroyImageView(cc_vk_state.device, cc_vk_state.views[i], NULL);
        vkDestroySemaphore(cc_vk_state.device, cc_vk_state.rendered[i], NULL);
    }
    vkDestroyImageView(cc_vk_state.device, cc_vk_state.depth_view, NULL);
    vkDestroyImage(cc_vk_state.device, cc_vk_state.depth, NULL);
    vkFreeMemory(cc_vk_state.device, cc_vk_state.depth_memory, NULL);
}

/* The present mode: FIFO (vsync, always offered) unless CC_VK_PRESENT is "mailbox" or "immediate" and the surface offers it (MoltenVK
 * offers FIFO and IMMEDIATE: IMMEDIATE turns the layer's display sync off, so a frame is shown without waiting for the display and
 * the drawable of the next frame is rarely waited for, at the price of tearing). */
static VkPresentModeKHR choose_present_mode(void) {
    const char *want = getenv("CC_VK_PRESENT");
    VkPresentModeKHR mode = VK_PRESENT_MODE_FIFO_KHR;
    if (want != NULL && strcmp(want, "mailbox") == 0) mode = VK_PRESENT_MODE_MAILBOX_KHR;
    if (want != NULL && strcmp(want, "immediate") == 0) mode = VK_PRESENT_MODE_IMMEDIATE_KHR;
    uint32_t count = 16;
    VkPresentModeKHR modes[16];
    VkResult listed = vkGetPhysicalDeviceSurfacePresentModesKHR(cc_vk_state.gpu, cc_vk_state.surface, &count, modes);
    if (listed != VK_SUCCESS && listed != VK_INCOMPLETE) cc_fatal("cc_vk: present mode query failed");
    int offered = 0;
    for (uint32_t i = 0; i < count; i++) offered |= modes[i] == mode;
    return offered ? mode : VK_PRESENT_MODE_FIFO_KHR;
}

/* (Re)creates the swapchain at the framebuffer's current extent, its views, the depth buffer and
 * the framebuffers. Images allow transfer reads so a rendered frame can be copied out. */
static void create_swapchain(void) {
    VkSurfaceCapabilitiesKHR caps;
    check(vkGetPhysicalDeviceSurfaceCapabilitiesKHR(cc_vk_state.gpu, cc_vk_state.surface, &caps), "cc_vk: surface capabilities query failed");
    glfwGetFramebufferSize(cc_win_window, &cc_vk_state.fb_w, &cc_vk_state.fb_h);
    VkExtent2D extent = caps.currentExtent;
    if (extent.width == UINT32_MAX) extent = (VkExtent2D){(uint32_t)cc_vk_state.fb_w, (uint32_t)cc_vk_state.fb_h};
    uint32_t images = caps.minImageCount + 1;
    if (images < 3) images = 3; /* with two frames in flight and one image on the display, a third is free to acquire */
    if (caps.maxImageCount != 0 && images > caps.maxImageCount) images = caps.maxImageCount;
    VkSwapchainKHR old = cc_vk_state.swapchain;
    cc_vk_state.present_mode = choose_present_mode();
    VkSwapchainCreateInfoKHR info = {
        .sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR,
        .surface = cc_vk_state.surface,
        .minImageCount = images,
        .imageFormat = cc_vk_state.format.format,
        .imageColorSpace = cc_vk_state.format.colorSpace,
        .imageExtent = extent,
        .imageArrayLayers = 1,
        .imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT,
        .imageSharingMode = VK_SHARING_MODE_EXCLUSIVE,
        .preTransform = caps.currentTransform,
        .compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = cc_vk_state.present_mode,
        .clipped = VK_TRUE,
        .oldSwapchain = old,
    };
    check(vkCreateSwapchainKHR(cc_vk_state.device, &info, NULL, &cc_vk_state.swapchain), "cc_vk: vkCreateSwapchainKHR failed");
    vkDestroySwapchainKHR(cc_vk_state.device, old, NULL);
    cc_vk_state.extent = extent;
    cc_vk_state.image_count = CC_VK_MAX_IMAGES;
    check(vkGetSwapchainImagesKHR(cc_vk_state.device, cc_vk_state.swapchain, &cc_vk_state.image_count, cc_vk_state.images), "cc_vk: vkGetSwapchainImagesKHR failed");
    cc_vk_state.depth = device_image(VK_FORMAT_D32_SFLOAT, extent.width, extent.height, 1, VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT, &cc_vk_state.depth_memory);
    cc_vk_state.depth_view = image_view(cc_vk_state.depth, VK_FORMAT_D32_SFLOAT, VK_IMAGE_ASPECT_DEPTH_BIT, 1);
    VkSemaphoreCreateInfo semaphore = {.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO};
    for (uint32_t i = 0; i < cc_vk_state.image_count; i++) {
        cc_vk_state.views[i] = image_view(cc_vk_state.images[i], cc_vk_state.format.format, VK_IMAGE_ASPECT_COLOR_BIT, 1);
        VkImageView attachments[2] = {cc_vk_state.views[i], cc_vk_state.depth_view};
        VkFramebufferCreateInfo fb = {
            .sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
            .renderPass = cc_vk_state.render_pass,
            .attachmentCount = 2,
            .pAttachments = attachments,
            .width = extent.width,
            .height = extent.height,
            .layers = 1,
        };
        check(vkCreateFramebuffer(cc_vk_state.device, &fb, NULL, &cc_vk_state.framebuffers[i]), "cc_vk: vkCreateFramebuffer failed");
        check(vkCreateSemaphore(cc_vk_state.device, &semaphore, NULL, &cc_vk_state.rendered[i]), "cc_vk: vkCreateSemaphore failed");
    }
    cc_vk_state.stale = 0;
}

static void all_complete(void);

static void recreate_swapchain(void) {
    check(vkDeviceWaitIdle(cc_vk_state.device), "cc_vk: vkDeviceWaitIdle failed");
    all_complete();
    destroy_swapchain_images();
    create_swapchain();
}

static VkShaderModule shader(const unsigned char *code, size_t size) {
    VkShaderModuleCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .codeSize = size,
        .pCode = (const uint32_t *)(const void *)code,
    };
    VkShaderModule module;
    check(vkCreateShaderModule(cc_vk_state.device, &info, NULL, &module), "cc_vk_init: vkCreateShaderModule failed");
    return module;
}

static void create_layouts(void) {
    VkDescriptorSetLayoutBinding binding = {
        .binding = 0,
        .descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
        .descriptorCount = 1,
        .stageFlags = VK_SHADER_STAGE_FRAGMENT_BIT,
    };
    VkDescriptorSetLayoutCreateInfo set_info = {
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
        .bindingCount = 1,
        .pBindings = &binding,
    };
    check(vkCreateDescriptorSetLayout(cc_vk_state.device, &set_info, NULL, &cc_vk_state.set_layout), "cc_vk_init: vkCreateDescriptorSetLayout failed");
    VkPushConstantRange push = {VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT, 0, 32 * sizeof(float)}; /* matrix, daylight, the 13 floats of the fog, the glint offset */
    VkPipelineLayoutCreateInfo layout_info = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
        .setLayoutCount = 1,
        .pSetLayouts = &cc_vk_state.set_layout,
        .pushConstantRangeCount = 1,
        .pPushConstantRanges = &push,
    };
    check(vkCreatePipelineLayout(cc_vk_state.device, &layout_info, NULL, &cc_vk_state.layout), "cc_vk_init: vkCreatePipelineLayout failed");
    VkDescriptorPoolSize size = {VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, CC_VK_MAX_SETS};
    VkDescriptorPoolCreateInfo pool_info = {
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO,
        .flags = VK_DESCRIPTOR_POOL_CREATE_FREE_DESCRIPTOR_SET_BIT,
        .maxSets = CC_VK_MAX_SETS,
        .poolSizeCount = 1,
        .pPoolSizes = &size,
    };
    check(vkCreateDescriptorPool(cc_vk_state.device, &pool_info, NULL, &cc_vk_state.pool), "cc_vk_init: vkCreateDescriptorPool failed");
    VkSamplerCreateInfo sampler = {
        .sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO,
        .magFilter = VK_FILTER_NEAREST,
        .minFilter = VK_FILTER_NEAREST,
        .mipmapMode = VK_SAMPLER_MIPMAP_MODE_NEAREST,
        .addressModeU = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
        .addressModeV = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
        .addressModeW = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE,
    };
    check(vkCreateSampler(cc_vk_state.device, &sampler, NULL, &cc_vk_state.sampler), "cc_vk_init: vkCreateSampler failed");
    sampler.addressModeU = sampler.addressModeV = sampler.addressModeW = VK_SAMPLER_ADDRESS_MODE_REPEAT;
    check(vkCreateSampler(cc_vk_state.device, &sampler, NULL, &cc_vk_state.repeat_sampler), "cc_vk_init: vkCreateSampler failed");
    /* The sampler of textures with mip levels (12 §2.4): linear filtering through the whole chain. */
    sampler.minFilter = VK_FILTER_LINEAR;
    sampler.magFilter = VK_FILTER_NEAREST; /* a texel larger than a pixel stays crisp (12 section 2.4): the held item's extruded pixels */
    sampler.mipmapMode = VK_SAMPLER_MIPMAP_MODE_LINEAR;
    sampler.maxLod = VK_LOD_CLAMP_NONE;
    check(vkCreateSampler(cc_vk_state.device, &sampler, NULL, &cc_vk_state.mip_repeat_sampler), "cc_vk_init: vkCreateSampler failed");
    sampler.addressModeU = sampler.addressModeV = sampler.addressModeW = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE;
    check(vkCreateSampler(cc_vk_state.device, &sampler, NULL, &cc_vk_state.mip_sampler), "cc_vk_init: vkCreateSampler failed");
}

/* Pipeline `p`: opaque (depth test + write, no blend), translucent (depth test, no write, alpha blend)
 * or UI (no depth, alpha blend) (shim-abi §9). */
static void create_pipeline(int p, VkShaderModule vert, VkShaderModule frag) {
    VkPipelineShaderStageCreateInfo stages[2] = {
        {.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO, .stage = VK_SHADER_STAGE_VERTEX_BIT, .module = vert, .pName = "main"},
        {.sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO, .stage = VK_SHADER_STAGE_FRAGMENT_BIT, .module = frag, .pName = "main"},
    };
    VkVertexInputBindingDescription binding = {0, sizeof(cc_vertex), VK_VERTEX_INPUT_RATE_VERTEX};
    VkVertexInputAttributeDescription attributes[6] = {
        {0, 0, VK_FORMAT_R32G32B32_SFLOAT, 0},
        {1, 0, VK_FORMAT_R32G32_SFLOAT, 12},
        {2, 0, VK_FORMAT_R32_SFLOAT, 20},
        {3, 0, VK_FORMAT_R32_SFLOAT, 24},
        {4, 0, VK_FORMAT_R32_SFLOAT, 28},
        {5, 0, VK_FORMAT_R32G32B32_SFLOAT, 32},
    };
    VkPipelineVertexInputStateCreateInfo input = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        .vertexBindingDescriptionCount = 1,
        .pVertexBindingDescriptions = &binding,
        .vertexAttributeDescriptionCount = 6,
        .pVertexAttributeDescriptions = attributes,
    };
    VkPipelineInputAssemblyStateCreateInfo assembly = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        .topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST,
    };
    VkPipelineViewportStateCreateInfo viewport = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        .viewportCount = 1,
        .scissorCount = 1,
    };
    VkPipelineRasterizationStateCreateInfo raster = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        .polygonMode = VK_POLYGON_MODE_FILL,
        .cullMode = p == CC_PIPE_TRANSLUCENT_CULL ? VK_CULL_MODE_BACK_BIT : VK_CULL_MODE_NONE,
        .frontFace = VK_FRONT_FACE_CLOCKWISE,
        .depthBiasEnable = p == CC_PIPE_CRUMBLING || p == CC_PIPE_GLINT,
        .depthBiasConstantFactor = -10.0f,
        .depthBiasSlopeFactor = -1.0f,
        .lineWidth = 1.0f,
    };
    VkPipelineMultisampleStateCreateInfo multisample = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        .rasterizationSamples = VK_SAMPLE_COUNT_1_BIT,
    };
    VkPipelineDepthStencilStateCreateInfo depth = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
        .depthTestEnable = p != CC_PIPE_UI,
        .depthWriteEnable = p == CC_PIPE_OPAQUE,
        .depthCompareOp = p == CC_PIPE_CRUMBLING || p == CC_PIPE_OPAQUE || p == CC_PIPE_GLINT ? VK_COMPARE_OP_LESS_OR_EQUAL : VK_COMPARE_OP_LESS, /* the solid layers pass equal depth: a block's overlay element lies in the plane of its base */
    };
    VkPipelineColorBlendAttachmentState blend = {
        .blendEnable = p != CC_PIPE_OPAQUE,
        .srcColorBlendFactor = p == CC_PIPE_CRUMBLING ? VK_BLEND_FACTOR_DST_COLOR : p == CC_PIPE_GLINT ? VK_BLEND_FACTOR_SRC_COLOR : VK_BLEND_FACTOR_SRC_ALPHA,
        .dstColorBlendFactor = p == CC_PIPE_CRUMBLING ? VK_BLEND_FACTOR_SRC_COLOR : p == CC_PIPE_GLINT ? VK_BLEND_FACTOR_ONE : VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
        .colorBlendOp = VK_BLEND_OP_ADD,
        .srcAlphaBlendFactor = p == CC_PIPE_GLINT ? VK_BLEND_FACTOR_ZERO : VK_BLEND_FACTOR_ONE,
        .dstAlphaBlendFactor = p == CC_PIPE_CRUMBLING ? VK_BLEND_FACTOR_ZERO : p == CC_PIPE_GLINT ? VK_BLEND_FACTOR_ONE : VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA,
        .alphaBlendOp = VK_BLEND_OP_ADD,
        .colorWriteMask = VK_COLOR_COMPONENT_R_BIT | VK_COLOR_COMPONENT_G_BIT | VK_COLOR_COMPONENT_B_BIT | VK_COLOR_COMPONENT_A_BIT,
    };
    VkPipelineColorBlendStateCreateInfo colour = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        .attachmentCount = 1,
        .pAttachments = &blend,
    };
    VkDynamicState dynamic_states[2] = {VK_DYNAMIC_STATE_VIEWPORT, VK_DYNAMIC_STATE_SCISSOR};
    VkPipelineDynamicStateCreateInfo dynamic = {
        .sType = VK_STRUCTURE_TYPE_PIPELINE_DYNAMIC_STATE_CREATE_INFO,
        .dynamicStateCount = 2,
        .pDynamicStates = dynamic_states,
    };
    VkGraphicsPipelineCreateInfo info = {
        .sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO,
        .stageCount = 2,
        .pStages = stages,
        .pVertexInputState = &input,
        .pInputAssemblyState = &assembly,
        .pViewportState = &viewport,
        .pRasterizationState = &raster,
        .pMultisampleState = &multisample,
        .pDepthStencilState = &depth,
        .pColorBlendState = &colour,
        .pDynamicState = &dynamic,
        .layout = cc_vk_state.layout,
        .renderPass = cc_vk_state.render_pass,
    };
    check(vkCreateGraphicsPipelines(cc_vk_state.device, VK_NULL_HANDLE, 1, &info, NULL, &cc_vk_state.pipelines[p]), "cc_vk_init: vkCreateGraphicsPipelines failed");
}

static void create_pipelines(void) {
    VkShaderModule world_vert = shader(spv_world_vert, sizeof spv_world_vert);
    VkShaderModule world_frag = shader(spv_world_frag, sizeof spv_world_frag);
    VkShaderModule crumble_frag = shader(spv_crumble_frag, sizeof spv_crumble_frag);
    VkShaderModule ui_vert = shader(spv_ui_vert, sizeof spv_ui_vert);
    VkShaderModule ui_frag = shader(spv_ui_frag, sizeof spv_ui_frag);
    create_pipeline(CC_PIPE_OPAQUE, world_vert, world_frag);
    create_pipeline(CC_PIPE_TRANSLUCENT, world_vert, world_frag);
    create_pipeline(CC_PIPE_UI, ui_vert, ui_frag);
    create_pipeline(CC_PIPE_TRANSLUCENT_CULL, world_vert, world_frag);
    create_pipeline(CC_PIPE_CRUMBLING, world_vert, crumble_frag);
    create_pipeline(CC_PIPE_GLINT, world_vert, world_frag);
    vkDestroyShaderModule(cc_vk_state.device, crumble_frag, NULL);
    vkDestroyShaderModule(cc_vk_state.device, world_vert, NULL);
    vkDestroyShaderModule(cc_vk_state.device, world_frag, NULL);
    vkDestroyShaderModule(cc_vk_state.device, ui_vert, NULL);
    vkDestroyShaderModule(cc_vk_state.device, ui_frag, NULL);
}

static void create_frame_objects(void) {
    VkCommandPoolCreateInfo pool = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .flags = VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,
        .queueFamilyIndex = cc_vk_state.family,
    };
    check(vkCreateCommandPool(cc_vk_state.device, &pool, NULL, &cc_vk_state.commands), "cc_vk_init: vkCreateCommandPool failed");
    VkSemaphoreCreateInfo semaphore = {.sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO};
    VkFenceCreateInfo fence = {.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO, .flags = VK_FENCE_CREATE_SIGNALED_BIT};
    for (uint32_t i = 0; i < CC_VK_FRAMES; i++) {
        cc_vk_state.cmd[i] = command_buffer();
        check(vkCreateSemaphore(cc_vk_state.device, &semaphore, NULL, &cc_vk_state.acquired[i]), "cc_vk_init: vkCreateSemaphore failed");
        check(vkCreateFence(cc_vk_state.device, &fence, NULL, &cc_vk_state.done[i]), "cc_vk_init: vkCreateFence failed");
    }
    /* CC_GPU_STATS: two timestamps (render pass start and end) per slot, when the queue family can write them. */
    VkPhysicalDeviceProperties properties;
    VkQueueFamilyProperties families[16];
    uint32_t family_count = 16;
    vkGetPhysicalDeviceProperties(cc_vk_state.gpu, &properties);
    vkGetPhysicalDeviceQueueFamilyProperties(cc_vk_state.gpu, &family_count, families);
    cc_vk_state.timestamp_period = properties.limits.timestampPeriod;
    VkQueryPoolCreateInfo queries = {.sType = VK_STRUCTURE_TYPE_QUERY_POOL_CREATE_INFO, .queryType = VK_QUERY_TYPE_TIMESTAMP, .queryCount = 2 * CC_VK_FRAMES};
    int timestamps = stats.on && families[cc_vk_state.family].timestampValidBits > 0 && properties.limits.timestampPeriod > 0;
    if (timestamps && vkCreateQueryPool(cc_vk_state.device, &queries, NULL, &cc_vk_state.queries) != VK_SUCCESS) cc_vk_state.queries = VK_NULL_HANDLE;
}

int32_t cc_vk_init(void) {
    cc_vk_state.daylight = 1.0f;
    memset(cc_vk_state.fog, 0, sizeof cc_vk_state.fog);
    cc_vk_state.fog[6] = cc_vk_state.fog[7] = 1.0f;
    cc_vk_state.fog[9] = 1.0f;
    cc_vk_state.fog[11] = 1e9f;
    cc_vk_state.fog[12] = 2e9f;
    cc_vk_state.fog[4] = 1e9f;
    cc_vk_state.fog[5] = 2e9f;
    cc_vk_state.glint_uv[0] = cc_vk_state.glint_uv[1] = 0.0f;
    const char *stats_env = getenv("CC_GPU_STATS"), *inflight_env = getenv("CC_VK_INFLIGHT");
    memset(&stats, 0, sizeof stats);
    stats.on = stats_env != NULL && strcmp(stats_env, "1") == 0;
    stats.report_t = stat_now();
    cc_vk_state.in_flight = inflight_env != NULL && strcmp(inflight_env, "1") == 0 ? 1 : CC_VK_FRAMES;
    create_instance();
    create_device();
    create_render_pass();
    cc_vk_state.swapchain = VK_NULL_HANDLE;
    create_swapchain();
    create_layouts();
    create_pipelines();
    create_frame_objects();
    return 0;
}

/* ---- textures and meshes ---------------------------------------------------------------------- */

/* Batched texture updates are submitted without waiting for the queue (cc_vk_texture_update_end): each submission keeps its command
 * buffer and staging buffers here, with a fence, until the frame after it has completed (the stamp, as for garbage) or the ring slot
 * is needed again. */
#define CC_UPDATE_BATCH_MAX 256
typedef struct {
    VkFence fence;
    VkCommandBuffer cmd;
    int pending;
    uint64_t stamp;
    int count;
    VkBuffer buffer[CC_UPDATE_BATCH_MAX];
    VkDeviceMemory memory[CC_UPDATE_BATCH_MAX];
} upload_t;
#define CC_VK_UPLOADS 8
static upload_t uploads[CC_VK_UPLOADS];
static uint32_t upload_next;

/* Waits for the upload's fence, then frees what it held. */
static void upload_retire(upload_t *u) {
    if (!u->pending) return;
    check(vkWaitForFences(cc_vk_state.device, 1, &u->fence, VK_TRUE, UINT64_MAX), "cc_vk_texture_update_end: vkWaitForFences failed");
    check(vkResetFences(cc_vk_state.device, 1, &u->fence), "cc_vk_texture_update_end: vkResetFences failed");
    for (int i = 0; i < u->count; i++) {
        vkDestroyBuffer(cc_vk_state.device, u->buffer[i], NULL);
        vkFreeMemory(cc_vk_state.device, u->memory[i], NULL);
    }
    vkFreeCommandBuffers(cc_vk_state.device, cc_vk_state.commands, 1, &u->cmd);
    u->pending = 0;
}

/* Every submitted command has finished (the queue or the device was waited for idle): the frames and the uploads are complete. */
static void all_complete(void) {
    cc_vk_state.frames_completed = cc_vk_state.frames_submitted;
    for (int i = 0; i < CC_VK_UPLOADS; i++) upload_retire(&uploads[i]);
}

int cc_vk_uploads_pending(void) {
    int pending = 0;
    for (int i = 0; i < CC_VK_UPLOADS; i++) pending += uploads[i].pending;
    return pending;
}

/* Submits and waits for a one-shot command buffer, then frees it. */
static void submit_wait(VkCommandBuffer cmd, const char *what) {
    double t = stat_now();
    char message[64];
    snprintf(message, sizeof message, "%s: vkEndCommandBuffer failed", what);
    check(vkEndCommandBuffer(cmd), message);
    VkSubmitInfo submit = {.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = &cmd};
    snprintf(message, sizeof message, "%s: vkQueueSubmit failed", what);
    check(vkQueueSubmit(cc_vk_state.queue, 1, &submit, VK_NULL_HANDLE), message);
    snprintf(message, sizeof message, "%s: vkQueueWaitIdle failed", what);
    check(vkQueueWaitIdle(cc_vk_state.queue), message);
    vkFreeCommandBuffers(cc_vk_state.device, cc_vk_state.commands, 1, &cmd);
    all_complete();
    stats.w.idle += stat_now() - t;
    stats.w.idle_waits++;
}

/* sRGB transfer function of 12 §2.3 (ARGB.meanLinear): 8-bit sRGB channel to linear light and back. */
static double srgb_to_linear(int c) {
    double v = c / 255.0;
    return v <= 0.04045 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4);
}

static uint8_t linear_to_srgb(double x) {
    double v = x <= 0.0031308 ? 12.92 * x : 1.055 * pow(x, 1.0 / 2.4) - 0.055;
    int c = (int)(v * 255.0 + 0.5);
    return (uint8_t)(c < 0 ? 0 : c > 255 ? 255 : c);
}

static double srgb_lut[256];
static int srgb_lut_ready;

static void init_lut(void) {
    if (srgb_lut_ready) return;
    for (int i = 0; i < 256; i++) srgb_lut[i] = srgb_to_linear(i);
    srgb_lut_ready = 1;
}

/* One pixel (x, y) of the next level (nw wide) from the lw x lh level `src` (12 §2.3). */
static void mip_pixel(const uint8_t *src, int32_t lw, int32_t lh, int32_t nw, int32_t x, int32_t y, uint8_t *dst) {
    int32_t x1 = 2 * x + 1 < lw ? 2 * x + 1 : lw - 1, y1 = 2 * y + 1 < lh ? 2 * y + 1 : lh - 1;
    const uint8_t *p[4] = {src + (2 * y * lw + 2 * x) * 4, src + (2 * y * lw + x1) * 4, src + (y1 * lw + 2 * x) * 4, src + (y1 * lw + x1) * 4};
    uint8_t *o = dst + (y * nw + x) * 4;
    for (int c = 0; c < 3; c++) o[c] = linear_to_srgb((srgb_lut[p[0][c]] + srgb_lut[p[1][c]] + srgb_lut[p[2][c]] + srgb_lut[p[3][c]]) / 4.0);
    o[3] = (uint8_t)((p[0][3] + p[1][3] + p[2][3] + p[3][3]) / 4);
}

/* Builds every mip level of a w x h RGBA image on the host, level after level, into one allocation (levels
 * follow each other, level 0 first). Each pixel is the mean of a 2 x 2 block of the previous level (12 §2.3):
 * colour channels averaged in linear light, alpha the integer mean (sum / 4). */
static uint8_t *build_chain(const uint8_t *base, int32_t w, int32_t h, uint32_t mips, VkDeviceSize *total) {
    init_lut();
    VkDeviceSize size = 0;
    for (int32_t lw = w, lh = h, i = 0; i < (int32_t)mips; i++, lw = lw > 1 ? lw / 2 : 1, lh = lh > 1 ? lh / 2 : 1)
        size += (VkDeviceSize)lw * (VkDeviceSize)lh * 4;
    uint8_t *chain = malloc((size_t)size);
    if (chain == NULL) cc_fatal("cc_vk_texture: out of memory");
    memcpy(chain, base, (size_t)w * (size_t)h * 4);
    const uint8_t *src = chain;
    uint8_t *dst = chain + (size_t)w * (size_t)h * 4;
    int32_t lw = w, lh = h;
    for (uint32_t i = 1; i < mips; i++) {
        int32_t nw = lw > 1 ? lw / 2 : 1, nh = lh > 1 ? lh / 2 : 1;
        for (int32_t y = 0; y < nh; y++)
            for (int32_t x = 0; x < nw; x++) mip_pixel(src, lw, lh, nw, x, y, dst);
        src = dst;
        dst += (size_t)nw * (size_t)nh * 4;
        lw = nw;
        lh = nh;
    }
    *total = size;
    return chain;
}

/* Uploads every level of the chain (from build_chain) of a w x h image whose levels are all in
 * TRANSFER_DST_OPTIMAL, then leaves every level readable by shaders. */
static void upload_chain(VkCommandBuffer cmd, VkBuffer staging, VkImage image, int32_t w, int32_t h, uint32_t mips) {
    VkBufferImageCopy regions[32];
    VkDeviceSize offset = 0;
    int32_t lw = w, lh = h;
    for (uint32_t i = 0; i < mips; i++) {
        regions[i] = (VkBufferImageCopy){
            .bufferOffset = offset,
            .imageSubresource = {VK_IMAGE_ASPECT_COLOR_BIT, i, 0, 1},
            .imageExtent = {(uint32_t)lw, (uint32_t)lh, 1},
        };
        offset += (VkDeviceSize)lw * (VkDeviceSize)lh * 4;
        lw = lw > 1 ? lw / 2 : 1;
        lh = lh > 1 ? lh / 2 : 1;
    }
    vkCmdCopyBufferToImage(cmd, staging, image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, mips, regions);
    barrier_levels(cmd, image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_ACCESS_TRANSFER_WRITE_BIT,
                   VK_ACCESS_SHADER_READ_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, mips);
}

int32_t cc_vk_texture(int32_t tex_id, int32_t w, int32_t h, const uint8_t *rgba) {
    return cc_vk_texture_ex(tex_id, w, h, rgba, 1);
}

int32_t cc_vk_texture_ex(int32_t tex_id, int32_t w, int32_t h, const uint8_t *rgba, int32_t mip_levels) {
    if (tex_id < CC_TEX_BLOCKS || tex_id > CC_TEX_GLINT_ARMOR || w <= 0 || h <= 0) cc_fatal("cc_vk_texture: invalid texture");
    int32_t longest = w > h ? w : h, most = 1;
    while ((longest >> most) > 0) most++;
    if (mip_levels < 1 || mip_levels > most) cc_fatal("cc_vk_texture_ex: invalid mip level count");
    stats.w.tex_full++;
    uint32_t mips = (uint32_t)mip_levels;
    VkDeviceSize size;
    uint8_t *chain = build_chain(rgba, w, h, mips, &size);
    VkDeviceMemory staging_memory;
    VkBuffer staging = host_buffer(VK_BUFFER_USAGE_TRANSFER_SRC_BIT, chain, size, &staging_memory);
    texture_t t;
    t.pixels = chain; /* kept: every level on the host, so an update recomputes only the changed rectangle */
    t.mips = mips;
    t.width = w;
    t.height = h;
    t.image = device_image(VK_FORMAT_R8G8B8A8_UNORM, (uint32_t)w, (uint32_t)h, mips,
                           VK_IMAGE_USAGE_TRANSFER_DST_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT | VK_IMAGE_USAGE_SAMPLED_BIT, &t.memory);
    t.view = image_view(t.image, VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_ASPECT_COLOR_BIT, mips);

    VkCommandBuffer cmd = command_buffer();
    begin(cmd);
    barrier_levels(cmd, t.image, VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 0, VK_ACCESS_TRANSFER_WRITE_BIT,
                   VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, mips);
    upload_chain(cmd, staging, t.image, w, h, mips);
    submit_wait(cmd, "cc_vk_texture");
    vkDestroyBuffer(cc_vk_state.device, staging, NULL);
    vkFreeMemory(cc_vk_state.device, staging_memory, NULL);

    VkDescriptorSetAllocateInfo alloc = {
        .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO,
        .descriptorPool = cc_vk_state.pool,
        .descriptorSetCount = 1,
        .pSetLayouts = &cc_vk_state.set_layout,
    };
    check(vkAllocateDescriptorSets(cc_vk_state.device, &alloc, &t.set), "cc_vk_texture: vkAllocateDescriptorSets failed");
    int repeat = cc_vk_state.wrap[tex_id] == CC_WRAP_REPEAT;
    VkSampler s = mips > 1 ? (repeat ? cc_vk_state.mip_repeat_sampler : cc_vk_state.mip_sampler)
                           : (repeat ? cc_vk_state.repeat_sampler : cc_vk_state.sampler);
    VkDescriptorImageInfo image = {s, t.view, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL};
    VkWriteDescriptorSet write = {
        .sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET,
        .dstSet = t.set,
        .descriptorCount = 1,
        .descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER,
        .pImageInfo = &image,
    };
    vkUpdateDescriptorSets(cc_vk_state.device, 1, &write, 0, NULL);

    texture_t *old = &cc_vk_state.textures[tex_id];
    free(old->pixels);
    discard((garbage_t){VK_NULL_HANDLE, old->image, old->view, old->memory, old->set, 0});
    *old = t;
    return 0;
}

/* Replaces the rectangle (x, y, w, h) of the base level and regenerates the mip levels (12 §2.3): only the pixels of
 * each level that depend on the rectangle are recomputed (a pixel of level n + 1 reads a 2 x 2 block of level n) and
 * only those rectangles are uploaded; the result equals a rebuild of the whole chain. */
/* A batch of texture updates (cc_vk_texture_update_begin / _end): the updates between them are recorded into one command buffer and
 * submitted, and waited for, once at the end instead of once each. */
static VkCommandBuffer update_batch_cmd = VK_NULL_HANDLE;
static int update_batching = 0;
static int update_batch_count = 0;
static VkBuffer update_batch_buffer[CC_UPDATE_BATCH_MAX];
static VkDeviceMemory update_batch_memory[CC_UPDATE_BATCH_MAX];

/* Submits the batch's command buffer without waiting: the queue runs it in order, before the next frame, and the staging buffers go
 * to an upload ring slot (waiting for the slot's older submission only when all CC_VK_UPLOADS slots are busy). */
static void update_batch_flush(void) {
    if (update_batch_cmd == VK_NULL_HANDLE) return;
    upload_t *u = &uploads[upload_next++ % CC_VK_UPLOADS];
    upload_retire(u);
    if (u->fence == VK_NULL_HANDLE) {
        VkFenceCreateInfo fence = {.sType = VK_STRUCTURE_TYPE_FENCE_CREATE_INFO};
        check(vkCreateFence(cc_vk_state.device, &fence, NULL, &u->fence), "cc_vk_texture_update_end: vkCreateFence failed");
    }
    check(vkEndCommandBuffer(update_batch_cmd), "cc_vk_texture_update_end: vkEndCommandBuffer failed");
    VkSubmitInfo submit = {.sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = &update_batch_cmd};
    check(vkQueueSubmit(cc_vk_state.queue, 1, &submit, u->fence), "cc_vk_texture_update_end: vkQueueSubmit failed");
    u->cmd = update_batch_cmd;
    u->pending = 1;
    u->stamp = cc_vk_state.frames_submitted + 1;
    u->count = update_batch_count;
    memcpy(u->buffer, update_batch_buffer, (size_t)update_batch_count * sizeof *u->buffer);
    memcpy(u->memory, update_batch_memory, (size_t)update_batch_count * sizeof *u->memory);
    update_batch_cmd = VK_NULL_HANDLE;
    update_batch_count = 0;
}

void cc_vk_texture_update_begin(void) {
    update_batching = 1;
}

void cc_vk_texture_update_end(void) {
    double started = stat_now();
    update_batching = 0;
    update_batch_flush();
    stats.w.upload += stat_now() - started;
}

int32_t cc_vk_texture_update(int32_t tex_id, int32_t x, int32_t y, int32_t w, int32_t h, const uint8_t *rgba) {
    if (tex_id < CC_TEX_BLOCKS || tex_id > CC_TEX_GLINT_ARMOR || cc_vk_state.textures[tex_id].set == VK_NULL_HANDLE) cc_fatal("cc_vk_texture_update: invalid texture");
    texture_t *t = &cc_vk_state.textures[tex_id];
    if (x < 0 || y < 0 || w <= 0 || h <= 0 || x + w > t->width || y + h > t->height) cc_fatal("cc_vk_texture_update: invalid rectangle");
    double started = stat_now();
    stats.w.tex_updates++;
    init_lut();
    for (int32_t row = 0; row < h; row++) memcpy(t->pixels + ((size_t)(y + row) * (size_t)t->width + (size_t)x) * 4, rgba + (size_t)row * (size_t)w * 4, (size_t)w * 4);
    int32_t lw[32], lh[32], x0[32], y0[32], x1[32], y1[32]; /* level size and the inclusive changed rectangle */
    size_t base[32], stage[32], staged = 0, off = 0;
    lw[0] = t->width; lh[0] = t->height;
    x0[0] = x; y0[0] = y; x1[0] = x + w - 1; y1[0] = y + h - 1;
    for (uint32_t i = 0; i < t->mips; i++) {
        base[i] = off;
        off += (size_t)lw[i] * (size_t)lh[i] * 4;
        if (i + 1 < t->mips) {
            lw[i + 1] = lw[i] > 1 ? lw[i] / 2 : 1;
            lh[i + 1] = lh[i] > 1 ? lh[i] / 2 : 1;
            x0[i + 1] = x0[i] / 2; y0[i + 1] = y0[i] / 2;
            x1[i + 1] = x1[i] / 2 < lw[i + 1] ? x1[i] / 2 : lw[i + 1] - 1;
            y1[i + 1] = y1[i] / 2 < lh[i + 1] ? y1[i] / 2 : lh[i + 1] - 1;
        }
        stage[i] = staged;
        staged += (size_t)(x1[i] - x0[i] + 1) * (size_t)(y1[i] - y0[i] + 1) * 4;
    }
    uint8_t *packed = malloc(staged);
    if (packed == NULL) cc_fatal("cc_vk_texture_update: out of memory");
    for (uint32_t i = 0; i < t->mips; i++) {
        if (i > 0)
            for (int32_t py = y0[i]; py <= y1[i]; py++)
                for (int32_t px = x0[i]; px <= x1[i]; px++) mip_pixel(t->pixels + base[i - 1], lw[i - 1], lh[i - 1], lw[i], px, py, t->pixels + base[i]);
        size_t rowbytes = (size_t)(x1[i] - x0[i] + 1) * 4;
        for (int32_t py = y0[i]; py <= y1[i]; py++)
            memcpy(packed + stage[i] + (size_t)(py - y0[i]) * rowbytes, t->pixels + base[i] + ((size_t)py * (size_t)lw[i] + (size_t)x0[i]) * 4, rowbytes);
    }
    VkDeviceMemory staging_memory;
    VkBuffer staging = host_buffer(VK_BUFFER_USAGE_TRANSFER_SRC_BIT, packed, staged, &staging_memory);
    free(packed);
    VkBufferImageCopy regions[32];
    for (uint32_t i = 0; i < t->mips; i++)
        regions[i] = (VkBufferImageCopy){
            .bufferOffset = stage[i],
            .imageSubresource = {VK_IMAGE_ASPECT_COLOR_BIT, i, 0, 1},
            .imageOffset = {x0[i], y0[i], 0},
            .imageExtent = {(uint32_t)(x1[i] - x0[i] + 1), (uint32_t)(y1[i] - y0[i] + 1), 1},
        };
    if (update_batching && update_batch_count == CC_UPDATE_BATCH_MAX) update_batch_flush();
    VkCommandBuffer cmd;
    if (update_batching && update_batch_cmd != VK_NULL_HANDLE) {
        cmd = update_batch_cmd;
    } else {
        cmd = command_buffer();
        begin(cmd);
        if (update_batching) update_batch_cmd = cmd;
    }
    barrier_levels(cmd, t->image, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_ACCESS_SHADER_READ_BIT,
                   VK_ACCESS_TRANSFER_WRITE_BIT, VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, t->mips);
    vkCmdCopyBufferToImage(cmd, staging, t->image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, t->mips, regions);
    barrier_levels(cmd, t->image, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL, VK_ACCESS_TRANSFER_WRITE_BIT,
                   VK_ACCESS_SHADER_READ_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_FRAGMENT_SHADER_BIT, 0, t->mips);
    if (update_batching) {
        update_batch_buffer[update_batch_count] = staging;
        update_batch_memory[update_batch_count] = staging_memory;
        update_batch_count++;
        stats.w.upload += stat_now() - started;
        return 0;
    }
    submit_wait(cmd, "cc_vk_texture_update");
    vkDestroyBuffer(cc_vk_state.device, staging, NULL);
    vkFreeMemory(cc_vk_state.device, staging_memory, NULL);
    return 0;
}

/* The wrap mode of texture `tex_id` for its next cc_vk_texture upload (§9). */
int32_t cc_vk_texture_wrap(int32_t tex_id, int32_t wrap) {
    if (tex_id < CC_TEX_BLOCKS || tex_id > CC_TEX_GLINT_ARMOR || wrap < CC_WRAP_CLAMP || wrap > CC_WRAP_REPEAT) cc_fatal("cc_vk_texture_wrap: invalid texture or mode");
    cc_vk_state.wrap[tex_id] = wrap;
    return 0;
}

int32_t cc_vk_mesh(int32_t slot, const float *verts, int32_t vertex_count) {
    if (slot < CC_MESH_SLOT_MIN || slot > CC_MESH_SLOT_MAX || vertex_count < 0) cc_fatal("cc_vk_mesh: invalid slot or count");
    double started = stat_now();
    mesh_t *m = &cc_vk_state.meshes[slot];
    discard((garbage_t){m->buffer, VK_NULL_HANDLE, VK_NULL_HANDLE, m->memory, VK_NULL_HANDLE, 0});
    *m = (mesh_t){VK_NULL_HANDLE, VK_NULL_HANDLE, (uint32_t)vertex_count};
    if (vertex_count > 0) m->buffer = host_buffer(VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, verts, (VkDeviceSize)vertex_count * sizeof(cc_vertex), &m->memory);
    stats.w.meshes++;
    stats.w.mesh_verts += (uint64_t)vertex_count;
    stats.w.upload += stat_now() - started;
    return 0;
}

/* ---- frames ----------------------------------------------------------------------------------- */

/* The command buffer of the frame being recorded: slot (frames_submitted mod frames in flight). */
#define FRAME_SLOT (cc_vk_state.frames_submitted % cc_vk_state.in_flight)
#define FRAME_CMD (cc_vk_state.cmd[FRAME_SLOT])

/* What is bound in the frame being recorded (reset by cc_vk_frame_begin): a draw rebinds only what changed. */
static int bound_pipeline;
static VkDescriptorSet bound_set;

int32_t cc_vk_frame_begin(const float clear_rgba[4]) {
    double t0 = stat_now();
    int w, h;
    glfwGetFramebufferSize(cc_win_window, &w, &h);
    if (w == 0 || h == 0 || glfwGetWindowAttrib(cc_win_window, GLFW_ICONIFIED)) return CC_AGAIN;
    if (stats.last_end > 0) stats.w.app += t0 - stats.last_end;
    if (cc_vk_state.stale || w != cc_vk_state.fb_w || h != cc_vk_state.fb_h) recreate_swapchain();
    uint32_t slot = (uint32_t)FRAME_SLOT;
    /* The frame that used this slot before (frames_submitted - in_flight) must have finished: its command buffer is reused, and its
     * semaphore and fence. This is the one place the CPU waits for the GPU, and only when the GPU is that far behind. */
    check(vkWaitForFences(cc_vk_state.device, 1, &cc_vk_state.done[slot], VK_TRUE, UINT64_MAX), "cc_vk_frame_begin: vkWaitForFences failed");
    double t1 = stat_now();
    stats.w.fence += t1 - t0;
    uint64_t finished = cc_vk_state.frames_submitted + 1 > cc_vk_state.in_flight ? cc_vk_state.frames_submitted + 1 - cc_vk_state.in_flight : 0;
    if (cc_vk_state.frames_completed < finished) cc_vk_state.frames_completed = finished;
    stats_gpu_time(slot);
    collect_garbage(0);
    for (int i = 0; i < CC_VK_UPLOADS; i++)
        if (uploads[i].pending && uploads[i].stamp <= cc_vk_state.frames_completed) upload_retire(&uploads[i]);
    double t2 = stat_now();
    VkResult acquired = vkAcquireNextImageKHR(cc_vk_state.device, cc_vk_state.swapchain, UINT64_MAX, cc_vk_state.acquired[slot], VK_NULL_HANDLE, &cc_vk_state.image_index);
    stats.w.acquire += stat_now() - t2;
    if (acquired == VK_ERROR_OUT_OF_DATE_KHR) return cc_vk_state.stale = 1, CC_AGAIN;
    if (acquired != VK_SUBOPTIMAL_KHR) check(acquired, "cc_vk_frame_begin: vkAcquireNextImageKHR failed");
    VkCommandBuffer cmd = cc_vk_state.cmd[slot];
    check(vkResetCommandBuffer(cmd, 0), "cc_vk_frame_begin: vkResetCommandBuffer failed");
    begin(cmd);
    if (stats.on && cc_vk_state.queries != VK_NULL_HANDLE) {
        vkCmdResetQueryPool(cmd, cc_vk_state.queries, slot * 2, 2);
        vkCmdWriteTimestamp(cmd, VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, cc_vk_state.queries, slot * 2);
    }
    VkClearValue clear[2];
    memcpy(clear[0].color.float32, clear_rgba, 4 * sizeof(float));
    clear[1].depthStencil = (VkClearDepthStencilValue){1.0f, 0};
    VkRenderPassBeginInfo pass = {
        .sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
        .renderPass = cc_vk_state.render_pass,
        .framebuffer = cc_vk_state.framebuffers[cc_vk_state.image_index],
        .renderArea = {{0, 0}, cc_vk_state.extent},
        .clearValueCount = 2,
        .pClearValues = clear,
    };
    vkCmdBeginRenderPass(cmd, &pass, VK_SUBPASS_CONTENTS_INLINE);
    VkViewport viewport = {0, 0, (float)cc_vk_state.extent.width, (float)cc_vk_state.extent.height, 0, 1};
    VkRect2D scissor = {{0, 0}, cc_vk_state.extent};
    vkCmdSetViewport(cmd, 0, 1, &viewport);
    vkCmdSetScissor(cmd, 0, 1, &scissor);
    bound_pipeline = -1;
    bound_set = VK_NULL_HANDLE;
    stats.record_from = stat_now();
    return 0;
}

void cc_vk_draw(int32_t slot, int32_t pipeline, int32_t tex_id, const float matrix[16]) {
    if (slot < CC_MESH_SLOT_MIN || slot > CC_MESH_SLOT_MAX || pipeline < CC_PIPE_OPAQUE || pipeline > CC_PIPE_TRANSLUCENT_CULL ||
        tex_id < CC_TEX_BLOCKS || tex_id > CC_TEX_GLINT_ARMOR || cc_vk_state.textures[tex_id].set == VK_NULL_HANDLE) cc_fatal("cc_vk_draw: invalid slot, pipeline or texture");
    mesh_t *m = &cc_vk_state.meshes[slot];
    if (m->count == 0) return;
    stats.w.draws++;
    stats.w.verts += m->count;
    VkCommandBuffer cmd = FRAME_CMD;
    VkDeviceSize offset = 0;
    if (bound_pipeline != pipeline) vkCmdBindPipeline(cmd, VK_PIPELINE_BIND_POINT_GRAPHICS, cc_vk_state.pipelines[pipeline]);
    bound_pipeline = pipeline;
    if (bound_set != cc_vk_state.textures[tex_id].set) vkCmdBindDescriptorSets(cmd, VK_PIPELINE_BIND_POINT_GRAPHICS, cc_vk_state.layout, 0, 1, &cc_vk_state.textures[tex_id].set, 0, NULL);
    bound_set = cc_vk_state.textures[tex_id].set;
    vkCmdBindVertexBuffers(cmd, 0, 1, &m->buffer, &offset);
    /* The whole push constant block in one command: matrix (16 floats), daylight, the 13 fog floats, the glint offset (0 for the other pipelines). */
    float push[32];
    memcpy(push, matrix, 16 * sizeof(float));
    push[16] = cc_vk_state.daylight;
    memcpy(push + 17, cc_vk_state.fog, 13 * sizeof(float));
    push[30] = pipeline == CC_PIPE_GLINT ? cc_vk_state.glint_uv[0] : 0.0f;
    push[31] = pipeline == CC_PIPE_GLINT ? cc_vk_state.glint_uv[1] : 0.0f;
    vkCmdPushConstants(cmd, cc_vk_state.layout, VK_SHADER_STAGE_VERTEX_BIT | VK_SHADER_STAGE_FRAGMENT_BIT, 0, sizeof push, push);
    vkCmdDraw(cmd, m->count, 1, 0, 0);
}

/* The daylight factor of the draws that follow (shim-abi §9). */
void cc_vk_daylight(const float *daylight) {
    cc_vk_state.daylight = *daylight;
}

/* The fog of the draws that follow (shim-abi §9). */
void cc_vk_fog(const float *fog) {
    memcpy(cc_vk_state.fog, fog, sizeof cc_vk_state.fog);
}

/* The texture coordinate offset of the glint draws that follow (shim-abi §9). */
void cc_vk_glint_offset(const float *uv) {
    memcpy(cc_vk_state.glint_uv, uv, sizeof cc_vk_state.glint_uv);
}

/* Clears the depth attachment inside the open render pass (the hand pass of 12 §6 draws over the world). */
void cc_vk_clear_depth(void) {
    VkClearAttachment depth = {
        .aspectMask = VK_IMAGE_ASPECT_DEPTH_BIT,
        .colorAttachment = 0,
        .clearValue.depthStencil = {1.0f, 0},
    };
    VkClearRect area = {.rect = {{0, 0}, cc_vk_state.extent}, .baseArrayLayer = 0, .layerCount = 1};
    vkCmdClearAttachments(FRAME_CMD, 1, &depth, 1, &area);
}

/* Ends the frame's recording and hands it to the queue (signalling the slot's fence); the next frame goes to the other slot. */
static void record_submit(void) {
    double t0 = stat_now();
    uint32_t slot = (uint32_t)FRAME_SLOT;
    VkCommandBuffer cmd = cc_vk_state.cmd[slot];
    stats.w.record += t0 - stats.record_from;
    vkCmdEndRenderPass(cmd);
    if (stats.on && cc_vk_state.queries != VK_NULL_HANDLE) {
        vkCmdWriteTimestamp(cmd, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, cc_vk_state.queries, slot * 2 + 1);
        stats.queried[slot] = 1;
    }
    check(vkEndCommandBuffer(cmd), "cc_vk_frame_end: vkEndCommandBuffer failed");
    VkPipelineStageFlags wait_stage = VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT;
    VkSubmitInfo submit = {
        .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO,
        .waitSemaphoreCount = 1,
        .pWaitSemaphores = &cc_vk_state.acquired[slot],
        .pWaitDstStageMask = &wait_stage,
        .commandBufferCount = 1,
        .pCommandBuffers = &cmd,
        .signalSemaphoreCount = 1,
        .pSignalSemaphores = &cc_vk_state.rendered[cc_vk_state.image_index],
    };
    check(vkResetFences(cc_vk_state.device, 1, &cc_vk_state.done[slot]), "cc_vk_frame_end: vkResetFences failed");
    check(vkQueueSubmit(cc_vk_state.queue, 1, &submit, cc_vk_state.done[slot]), "cc_vk_frame_end: vkQueueSubmit failed");
    cc_vk_state.frames_submitted++;
    stats.w.submit += stat_now() - t0;
}

/* The shim's tests read the rendered image between the two halves: this one also waits for the GPU to finish the frame. */
void cc_vk_submit(void) {
    record_submit();
    check(vkWaitForFences(cc_vk_state.device, 1, &cc_vk_state.done[(cc_vk_state.frames_submitted - 1) % cc_vk_state.in_flight], VK_TRUE, UINT64_MAX), "cc_vk_frame_end: vkWaitForFences failed");
    cc_vk_state.frames_completed = cc_vk_state.frames_submitted;
}

/* ---- screenshot (shim-delta §14) ---------------------------------------------------------------- */

static char shot_path[1024];
static int shot_state; /* 0 none, or served and written; 1 waiting for a frame; 2 served and failed */

int32_t cc_vk_screenshot(const char *path) {
    if (shot_state == 1) return CC_AGAIN;
    if (strlen(path) >= sizeof shot_path) cc_fatal("cc_vk_screenshot: path too long");
    strcpy(shot_path, path);
    shot_state = 1;
    return 0;
}

int32_t cc_vk_screenshot_result(void) {
    return shot_state == 1 ? CC_AGAIN : shot_state == 2 ? CC_FAILED : 0;
}

/* Copies the image of the frame just submitted (in PRESENT_SRC layout, still owned by the application) to the host and
 * writes it as a PNG in RGBA order. */
static void capture_frame(void) {
    VkExtent2D e = cc_vk_state.extent;
    size_t size = (size_t)e.width * e.height * 4;
    uint8_t *zero = calloc(1, size);
    if (zero == NULL) cc_fatal("cc_vk_screenshot: out of memory");
    VkDeviceMemory memory;
    VkBuffer buffer = host_buffer(VK_BUFFER_USAGE_TRANSFER_DST_BIT, zero, size, &memory);
    free(zero);
    VkImage image = cc_vk_state.images[cc_vk_state.image_index];
    VkCommandBuffer cmd = command_buffer();
    begin(cmd);
    barrier_levels(cmd, image, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_ACCESS_MEMORY_WRITE_BIT,
                   VK_ACCESS_TRANSFER_READ_BIT, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 1);
    VkBufferImageCopy region = {.imageSubresource = {VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1}, .imageExtent = {e.width, e.height, 1}};
    vkCmdCopyImageToBuffer(cmd, image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, buffer, 1, &region);
    barrier_levels(cmd, image, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, VK_IMAGE_LAYOUT_PRESENT_SRC_KHR, VK_ACCESS_TRANSFER_READ_BIT,
                   VK_ACCESS_MEMORY_READ_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, 0, 1);
    submit_wait(cmd, "cc_vk_screenshot");
    uint8_t *pixels;
    check(vkMapMemory(cc_vk_state.device, memory, 0, size, 0, (void **)&pixels), "cc_vk_screenshot: vkMapMemory failed");
    VkFormat f = cc_vk_state.format.format;
    int bgra = f == VK_FORMAT_B8G8R8A8_UNORM || f == VK_FORMAT_B8G8R8A8_SRGB;
    if (bgra) {
        for (size_t i = 0; i < size; i += 4) {
            uint8_t t = pixels[i];
            pixels[i] = pixels[i + 2];
            pixels[i + 2] = t;
        }
    }
    for (size_t i = 3; i < size; i += 4) pixels[i] = 255; /* a screenshot is opaque, as the window shows it */
    shot_state = cc_png_write(shot_path, (int32_t)e.width, (int32_t)e.height, pixels) == 0 ? 0 : 2;
    vkUnmapMemory(cc_vk_state.device, memory);
    vkDestroyBuffer(cc_vk_state.device, buffer, NULL);
    vkFreeMemory(cc_vk_state.device, memory, NULL);
}

void cc_vk_present(void) {
    if (shot_state == 1) capture_frame();
    double t0 = stat_now();
    VkPresentInfoKHR present = {
        .sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR,
        .waitSemaphoreCount = 1,
        .pWaitSemaphores = &cc_vk_state.rendered[cc_vk_state.image_index],
        .swapchainCount = 1,
        .pSwapchains = &cc_vk_state.swapchain,
        .pImageIndices = &cc_vk_state.image_index,
    };
    VkResult presented = vkQueuePresentKHR(cc_vk_state.queue, &present);
    if (presented == VK_ERROR_OUT_OF_DATE_KHR || presented == VK_SUBOPTIMAL_KHR) cc_vk_state.stale = 1;
    else check(presented, "cc_vk_frame_end: vkQueuePresentKHR failed");
    stats.w.present += stat_now() - t0;
}

/* Submits and presents without waiting for the GPU (the frame's fence is waited for when its slot is used again). */
void cc_vk_frame_end(void) {
    record_submit();
    cc_vk_present();
    double t = stat_now();
    stats.w.frames++;
    stats.last_end = t;
    if (t - stats.report_t >= 1000.0) cc_vk_stats_flush();
}

void cc_vk_shutdown(void) {
    check(vkDeviceWaitIdle(cc_vk_state.device), "cc_vk_shutdown: vkDeviceWaitIdle failed");
    cc_vk_stats_flush();
    all_complete();
    for (int i = 0; i < CC_VK_UPLOADS; i++) {
        vkDestroyFence(cc_vk_state.device, uploads[i].fence, NULL);
        uploads[i].fence = VK_NULL_HANDLE;
    }
    upload_next = 0;
    for (int32_t slot = CC_MESH_SLOT_MIN; slot <= CC_MESH_SLOT_MAX; slot++) cc_vk_mesh(slot, NULL, 0);
    for (int i = CC_TEX_BLOCKS; i <= CC_TEX_GLINT_ARMOR; i++) {
        texture_t *t = &cc_vk_state.textures[i];
        discard((garbage_t){VK_NULL_HANDLE, t->image, t->view, t->memory, t->set, 0});
        free(t->pixels);
        t->pixels = NULL;
    }
    collect_garbage(1);
    free(cc_vk_state.garbage);
    destroy_swapchain_images();
    vkDestroySwapchainKHR(cc_vk_state.device, cc_vk_state.swapchain, NULL);
    for (int p = CC_PIPE_OPAQUE; p <= CC_PIPE_TRANSLUCENT_CULL; p++) vkDestroyPipeline(cc_vk_state.device, cc_vk_state.pipelines[p], NULL);
    vkDestroyPipelineLayout(cc_vk_state.device, cc_vk_state.layout, NULL);
    vkDestroyDescriptorPool(cc_vk_state.device, cc_vk_state.pool, NULL);
    vkDestroyDescriptorSetLayout(cc_vk_state.device, cc_vk_state.set_layout, NULL);
    vkDestroySampler(cc_vk_state.device, cc_vk_state.sampler, NULL);
    vkDestroySampler(cc_vk_state.device, cc_vk_state.repeat_sampler, NULL);
    vkDestroySampler(cc_vk_state.device, cc_vk_state.mip_sampler, NULL);
    vkDestroySampler(cc_vk_state.device, cc_vk_state.mip_repeat_sampler, NULL);
    for (uint32_t i = 0; i < CC_VK_FRAMES; i++) {
        vkDestroySemaphore(cc_vk_state.device, cc_vk_state.acquired[i], NULL);
        vkDestroyFence(cc_vk_state.device, cc_vk_state.done[i], NULL);
    }
    vkDestroyQueryPool(cc_vk_state.device, cc_vk_state.queries, NULL);
    vkDestroyCommandPool(cc_vk_state.device, cc_vk_state.commands, NULL);
    vkDestroyRenderPass(cc_vk_state.device, cc_vk_state.render_pass, NULL);
    vkDestroyDevice(cc_vk_state.device, NULL);
    vkDestroySurfaceKHR(cc_vk_state.instance, cc_vk_state.surface, NULL);
    vkDestroyInstance(cc_vk_state.instance, NULL);
    memset(&cc_vk_state, 0, sizeof cc_vk_state);
}
