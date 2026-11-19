/* Implementation test of the frame loop of shim/src/cc_vk.c on the real device (contracts/shim-delta.md, "Frames in flight"):
 * two frames in flight (a frame submitted by cc_vk_frame_end is not waited for), at least three swapchain images when the surface
 * allows them, the present mode CC_VK_PRESENT asks for (FIFO unless the surface offers it), texture updates and mesh replacements made
 * between frames that are still running (the last frame shows the last update), staging buffers and replaced resources freed once the
 * frames that could use them have completed, and the CC_GPU_STATS line on standard error. */
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "cc_internal.h"
#include "ccshim.h"
#include "testlib.h"

#define S cc_vk_state

/* The quad covers clip space [-0.5, 0.5]. */
static const float QUAD[6 * 11] = {
    -0.5f, -0.5f, 0.5f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, -0.5f, 0.5f, 1, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.5f, 1, 1, 1, 1, 0, 1, 1, 1,
    -0.5f, -0.5f, 0.5f, 0, 0, 1, 1, 0, 1, 1, 1,  0.5f, 0.5f, 0.5f, 1, 1, 1, 1, 0, 1, 1, 1,  -0.5f, 0.5f, 0.5f, 0, 1, 1, 1, 0, 1, 1, 1,
};
static const float IDENTITY[16] = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1};
static const float CLEAR[4] = {0, 0, 0, 1};

/* The colour of the centre pixel of the frame's rendered image (between cc_vk_submit and cc_vk_present) as "RRGGBBAA". */
static void centre_pixel(char out[9]) {
    VkMemoryPropertyFlags want = VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT;
    VkExtent2D e = S.extent;
    VkDeviceSize size = (VkDeviceSize)e.width * e.height * 4;
    VkBufferCreateInfo info = {.sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .size = size, .usage = VK_BUFFER_USAGE_TRANSFER_DST_BIT};
    VkBuffer buffer;
    vkCreateBuffer(S.device, &info, NULL, &buffer);
    VkMemoryRequirements need;
    vkGetBufferMemoryRequirements(S.device, buffer, &need);
    uint32_t type = 0;
    while (!((need.memoryTypeBits >> type & 1u) && (S.memory_properties.memoryTypes[type].propertyFlags & want) == want)) type++;
    VkMemoryAllocateInfo alloc = {.sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = need.size, .memoryTypeIndex = type};
    VkDeviceMemory memory;
    vkAllocateMemory(S.device, &alloc, NULL, &memory);
    vkBindBufferMemory(S.device, buffer, memory, 0);
    VkCommandBufferAllocateInfo cmd_info = {
        .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, .commandPool = S.commands, .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY, .commandBufferCount = 1};
    VkCommandBuffer cmd;
    vkAllocateCommandBuffers(S.device, &cmd_info, &cmd);
    VkCommandBufferBeginInfo begin = {.sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO};
    vkBeginCommandBuffer(cmd, &begin);
    VkImage image = S.images[S.image_index];
    VkImageMemoryBarrier b = {
        .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
        .srcAccessMask = VK_ACCESS_MEMORY_WRITE_BIT,
        .dstAccessMask = VK_ACCESS_MEMORY_READ_BIT,
        .oldLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR,
        .newLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
        .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED,
        .image = image,
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
    const uint8_t *p = pixels + ((size_t)(e.height / 2) * e.width + e.width / 2) * 4;
    int bgra = S.format.format == VK_FORMAT_B8G8R8A8_UNORM || S.format.format == VK_FORMAT_B8G8R8A8_SRGB;
    snprintf(out, 9, "%02X%02X%02X%02X", p[bgra ? 2 : 0], p[1], p[bgra ? 0 : 2], p[3]);
    vkUnmapMemory(S.device, memory);
    vkFreeCommandBuffers(S.device, S.commands, 1, &cmd);
    vkDestroyBuffer(S.device, buffer, NULL);
    vkFreeMemory(S.device, memory, NULL);
}

static int offered(VkPresentModeKHR mode) {
    uint32_t count = 16;
    VkPresentModeKHR modes[16];
    vkGetPhysicalDeviceSurfacePresentModesKHR(S.gpu, S.surface, &count, modes);
    int found = 0;
    for (uint32_t i = 0; i < count; i++) found |= modes[i] == mode;
    return found;
}

int main(void) {
    setenv("CC_VK_INFLIGHT", "2", 1);
    setenv("CC_GPU_STATS", "1", 1);
    setenv("CC_VK_PRESENT", "mailbox", 1);
    cc_win_open(320, 240, "test_cc_vk_frames", 0);
    cc_vk_init();

    VkSurfaceCapabilitiesKHR caps;
    vkGetPhysicalDeviceSurfaceCapabilitiesKHR(S.gpu, S.surface, &caps);
    tl_int("test cc_vk swapchain has at least 3 images when the surface allows them", 1,
           S.image_count >= 3 || (caps.maxImageCount != 0 && caps.maxImageCount < 3));
    tl_int("test cc_vk present mode is the one CC_VK_PRESENT asks for when the surface offers it, else FIFO",
           offered(VK_PRESENT_MODE_MAILBOX_KHR) ? VK_PRESENT_MODE_MAILBOX_KHR : VK_PRESENT_MODE_FIFO_KHR, S.present_mode);
    tl_int("test cc_vk runs two frames in flight", 2, S.in_flight);

    uint8_t texel[2 * 2 * 4];
    for (int i = 0; i < 4; i++) memcpy(texel + 4 * i, "\x7d\x7f\x86\xff", 4);
    cc_vk_texture(CC_TEX_BLOCKS, 2, 2, texel);
    cc_vk_mesh(1, QUAD, 6);
    tl_int("test cc_vk_uploads_pending is 0 before any batched update", 0, cc_vk_uploads_pending());

    /* Eight frames submitted without waiting; before each, the texture is recoloured through a batched update and the mesh replaced
     * (the previous frame is still running or was just handed over): the queue runs them in order, so the last frame shows the last
     * colour. */
    uint8_t last[4];
    for (int i = 0; i < 8; i++) {
        last[0] = (uint8_t)(16 * i + 16);
        last[1] = (uint8_t)(255 - 16 * i);
        last[2] = (uint8_t)(i * 3);
        last[3] = 255;
        for (int k = 0; k < 4; k++) memcpy(texel + 4 * k, last, 4);
        cc_vk_texture_update_begin();
        cc_vk_texture_update(CC_TEX_BLOCKS, 0, 0, 2, 2, texel);
        cc_vk_texture_update_end();
        cc_vk_mesh(1, QUAD, 6);
        cc_vk_frame_begin(CLEAR);
        cc_vk_draw(1, CC_PIPE_OPAQUE, CC_TEX_BLOCKS, IDENTITY);
        if (i < 7) cc_vk_frame_end();
    }
    tl_int("test cc_vk batched updates are submitted without waiting: their staging is held until the frames after them complete", 1, cc_vk_uploads_pending() > 0);
    cc_vk_submit(); /* the eighth frame, waiting for it */
    char pixel[9], want[9];
    centre_pixel(pixel);
    snprintf(want, sizeof want, "%02X%02X%02X%02X", last[0], last[1], last[2], last[3]);
    tl_str("test cc_vk the last of eight frames in flight shows the last texture update", want, pixel);
    cc_vk_present();

    /* Standard error goes to a file from here: the statistics line of the eight frames, then three more frames (every earlier frame has
     * completed by the time two more have begun: the replaced meshes and the staging of the updates are freed) and their line. One draw
     * of six vertices a frame. */
    char path[] = "/tmp/test_cc_vk_frames_XXXXXX";
    int fd = mkstemp(path);
    fflush(stderr);
    int saved = dup(2);
    dup2(fd, 2);
    cc_vk_stats_flush();
    for (int i = 0; i < 3; i++) {
        cc_stat_phase(CC_PHASE_INPUT);
        cc_stat_phase(CC_PHASE_CORE_TICK);
        cc_stat_phase(99); /* not a phase: ignored, the core tick goes on */
        cc_stat_phase(-1);
        cc_vk_frame_begin(CLEAR); /* ends the phase running */
        cc_vk_draw(1, CC_PIPE_OPAQUE, CC_TEX_BLOCKS, IDENTITY);
        cc_vk_frame_end();
    }
    cc_vk_stats_flush();
    cc_vk_stats_flush(); /* nothing new since the last line: prints nothing */
    fflush(stderr);
    dup2(saved, 2);
    close(saved);
    close(fd);
    tl_int("test cc_vk staging of batched updates is freed once the frames after them have completed", 0, cc_vk_uploads_pending());
    tl_int("test cc_vk replaced meshes are freed once the frames that could draw them have completed", 1, S.garbage_count <= 1);
    char text[4096] = {0};
    FILE *f = fopen(path, "r");
    size_t n = fread(text, 1, sizeof text - 1, f);
    fclose(f);
    unlink(path);
    text[n] = 0;
    tl_int("test cc_gpu stats line starts with the frame rate", 1, strncmp(text, "cc_gpu: fps=", 12) == 0);
    tl_int("test cc_gpu stats line counts one draw of six vertices a frame", 1, strstr(text, "draws=1 verts=6 ") != NULL);
    tl_int("test cc_gpu stats line reports the frames in flight", 1, strstr(text, "in_flight=2") != NULL);
    tl_int("test cc_gpu phase line names the phases the program entered with the entries per frame", 1,
           strstr(text, "cc_gpu: phases ms/frame (entries/frame): input=") != NULL && strstr(text, "coretick=") != NULL && strstr(text, "(x1.0)") != NULL);
    tl_int("test cc_gpu phase line leaves out the phases never entered", 1, strstr(text, "ui=") == NULL);
    tl_int("test cc_gpu stats line has the GPU time of the render pass", 1, strstr(text, "gpu ms/frame=") != NULL);

    cc_vk_shutdown();
    cc_win_close();
    return 0;
}
