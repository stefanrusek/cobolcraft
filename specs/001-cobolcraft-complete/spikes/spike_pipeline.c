/* spike (throwaway): the renderer feature set the plan relies on, on MoltenVK, offscreen (no window):
   graphics pipeline from build-time SPIR-V, vertex buffer (pos3+uv2), push-constant mat4, combined image
   sampler with NEAREST filtering (16x16 RGBA texture), depth buffer D32_SFLOAT with test, alpha blending,
   triangle list, render to an image and copy back to host memory. Prints the centre pixel. */
#include <vulkan/vulkan.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CK(x) do { VkResult r_ = (x); if (r_ != VK_SUCCESS) { printf("FAIL %s -> %d\n", #x, r_); exit(1); } } while (0)
static VkDevice dev; static VkPhysicalDevice pd;
static uint32_t memtype(uint32_t bits, VkMemoryPropertyFlags f) { VkPhysicalDeviceMemoryProperties m; vkGetPhysicalDeviceMemoryProperties(pd, &m);
  for (uint32_t i = 0; i < m.memoryTypeCount; i++) if ((bits & (1u << i)) && (m.memoryTypes[i].propertyFlags & f) == f) return i; printf("FAIL memtype\n"); exit(1); }
static void *readfile(const char *p, size_t *n) { FILE *f = fopen(p, "rb"); if (!f) { printf("FAIL open %s\n", p); exit(1); } fseek(f, 0, SEEK_END); *n = (size_t)ftell(f); rewind(f); void *b = malloc(*n); fread(b, 1, *n, f); fclose(f); return b; }
static VkShaderModule shader(const char *p) { size_t n; void *code = readfile(p, &n); VkShaderModuleCreateInfo ci = { .sType = VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO, .codeSize = n, .pCode = code }; VkShaderModule m; CK(vkCreateShaderModule(dev, &ci, NULL, &m)); return m; }
static void image(uint32_t w, uint32_t h, VkFormat fmt, VkImageUsageFlags u, VkImage *img, VkDeviceMemory *mem) {
  VkImageCreateInfo ci = { .sType = VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO, .imageType = VK_IMAGE_TYPE_2D, .format = fmt, .extent = { w, h, 1 }, .mipLevels = 1, .arrayLayers = 1, .samples = VK_SAMPLE_COUNT_1_BIT, .tiling = VK_IMAGE_TILING_OPTIMAL, .usage = u };
  CK(vkCreateImage(dev, &ci, NULL, img)); VkMemoryRequirements r; vkGetImageMemoryRequirements(dev, *img, &r);
  VkMemoryAllocateInfo ai = { .sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = r.size, .memoryTypeIndex = memtype(r.memoryTypeBits, VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT) };
  CK(vkAllocateMemory(dev, &ai, NULL, mem)); CK(vkBindImageMemory(dev, *img, *mem, 0)); }
static void buffer(VkDeviceSize n, VkBufferUsageFlags u, VkBuffer *b, VkDeviceMemory *m, void **map) {
  VkBufferCreateInfo ci = { .sType = VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO, .size = n, .usage = u }; CK(vkCreateBuffer(dev, &ci, NULL, b));
  VkMemoryRequirements r; vkGetBufferMemoryRequirements(dev, *b, &r);
  VkMemoryAllocateInfo ai = { .sType = VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO, .allocationSize = r.size, .memoryTypeIndex = memtype(r.memoryTypeBits, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT) };
  CK(vkAllocateMemory(dev, &ai, NULL, m)); CK(vkBindBufferMemory(dev, *b, *m, 0)); CK(vkMapMemory(dev, *m, 0, n, 0, map)); }
static VkImageView view(VkImage i, VkFormat f, VkImageAspectFlags a) { VkImageViewCreateInfo ci = { .sType = VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO, .image = i, .viewType = VK_IMAGE_VIEW_TYPE_2D, .format = f, .subresourceRange = { a, 0, 1, 0, 1 } }; VkImageView v; CK(vkCreateImageView(dev, &ci, NULL, &v)); return v; }
static void barrier(VkCommandBuffer cb, VkImage i, VkImageAspectFlags a, VkImageLayout o, VkImageLayout n) {
  VkImageMemoryBarrier b = { .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER, .oldLayout = o, .newLayout = n, .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED, .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED, .image = i, .subresourceRange = { a, 0, 1, 0, 1 }, .srcAccessMask = VK_ACCESS_MEMORY_WRITE_BIT, .dstAccessMask = VK_ACCESS_MEMORY_READ_BIT | VK_ACCESS_MEMORY_WRITE_BIT };
  vkCmdPipelineBarrier(cb, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, VK_PIPELINE_STAGE_ALL_COMMANDS_BIT, 0, 0, NULL, 0, NULL, 1, &b); }
int main(int argc, char **argv) {
  if (argc < 3) { printf("usage: spike_pipeline vert.spv frag.spv\n"); return 1; }
  const char *ie[] = { VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME };
  VkApplicationInfo app = { .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO, .apiVersion = VK_API_VERSION_1_2 };
  VkInstanceCreateInfo ici = { .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, .flags = VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR, .pApplicationInfo = &app, .enabledExtensionCount = 1, .ppEnabledExtensionNames = ie };
  VkInstance inst; CK(vkCreateInstance(&ici, NULL, &inst)); uint32_t c = 1; vkEnumeratePhysicalDevices(inst, &c, &pd);
  VkPhysicalDeviceProperties pp; vkGetPhysicalDeviceProperties(pd, &pp); printf("maxPushConstantsSize=%u\n", pp.limits.maxPushConstantsSize);
  float prio = 1; VkDeviceQueueCreateInfo q = { .sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO, .queueCount = 1, .pQueuePriorities = &prio };
  const char *de[] = { "VK_KHR_portability_subset" };
  VkDeviceCreateInfo dci = { .sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO, .queueCreateInfoCount = 1, .pQueueCreateInfos = &q, .enabledExtensionCount = 1, .ppEnabledExtensionNames = de };
  CK(vkCreateDevice(pd, &dci, NULL, &dev)); VkQueue queue; vkGetDeviceQueue(dev, 0, 0, &queue);
  const uint32_t W = 64, H = 64; VkFormat CF = VK_FORMAT_R8G8B8A8_UNORM, DF = VK_FORMAT_D32_SFLOAT;
  VkImage col, dep, tex; VkDeviceMemory colm, depm, texm;
  image(W, H, CF, VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_SRC_BIT, &col, &colm);
  image(W, H, DF, VK_IMAGE_USAGE_DEPTH_STENCIL_ATTACHMENT_BIT, &dep, &depm);
  image(16, 16, CF, VK_IMAGE_USAGE_SAMPLED_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT, &tex, &texm);
  VkImageView colv = view(col, CF, VK_IMAGE_ASPECT_COLOR_BIT), depv = view(dep, DF, VK_IMAGE_ASPECT_DEPTH_BIT), texv = view(tex, CF, VK_IMAGE_ASPECT_COLOR_BIT);
  VkBuffer stg, vb, rb; VkDeviceMemory stgm, vbm, rbm; void *stgp, *vbp, *rbp;
  buffer(16 * 16 * 4, VK_BUFFER_USAGE_TRANSFER_SRC_BIT, &stg, &stgm, &stgp);
  uint8_t *px = stgp; for (int i = 0; i < 256; i++) { px[i*4] = 0x7D; px[i*4+1] = 0x7F; px[i*4+2] = 0x86; px[i*4+3] = 0xFF; } /* greystone fill */
  float verts[] = { -0.8f, -0.8f, 0.5f, 0, 0,   0.8f, -0.8f, 0.5f, 1, 0,   0.0f, 0.8f, 0.5f, 0.5f, 1 };
  buffer(sizeof verts, VK_BUFFER_USAGE_VERTEX_BUFFER_BIT, &vb, &vbm, &vbp); memcpy(vbp, verts, sizeof verts);
  buffer(W * H * 4, VK_BUFFER_USAGE_TRANSFER_DST_BIT, &rb, &rbm, &rbp);
  VkAttachmentDescription at[2] = {
    { .format = CF, .samples = 1, .loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR, .storeOp = VK_ATTACHMENT_STORE_OP_STORE, .stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE, .stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE, .initialLayout = VK_IMAGE_LAYOUT_UNDEFINED, .finalLayout = VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL },
    { .format = DF, .samples = 1, .loadOp = VK_ATTACHMENT_LOAD_OP_CLEAR, .storeOp = VK_ATTACHMENT_STORE_OP_DONT_CARE, .stencilLoadOp = VK_ATTACHMENT_LOAD_OP_DONT_CARE, .stencilStoreOp = VK_ATTACHMENT_STORE_OP_DONT_CARE, .initialLayout = VK_IMAGE_LAYOUT_UNDEFINED, .finalLayout = VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL } };
  VkAttachmentReference cr = { 0, VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL }, dr = { 1, VK_IMAGE_LAYOUT_DEPTH_STENCIL_ATTACHMENT_OPTIMAL };
  VkSubpassDescription sp = { .pipelineBindPoint = VK_PIPELINE_BIND_POINT_GRAPHICS, .colorAttachmentCount = 1, .pColorAttachments = &cr, .pDepthStencilAttachment = &dr };
  VkRenderPassCreateInfo rpci = { .sType = VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO, .attachmentCount = 2, .pAttachments = at, .subpassCount = 1, .pSubpasses = &sp };
  VkRenderPass rp; CK(vkCreateRenderPass(dev, &rpci, NULL, &rp));
  VkImageView fbv[2] = { colv, depv }; VkFramebufferCreateInfo fci = { .sType = VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO, .renderPass = rp, .attachmentCount = 2, .pAttachments = fbv, .width = W, .height = H, .layers = 1 };
  VkFramebuffer fb; CK(vkCreateFramebuffer(dev, &fci, NULL, &fb));
  VkSamplerCreateInfo sci = { .sType = VK_STRUCTURE_TYPE_SAMPLER_CREATE_INFO, .magFilter = VK_FILTER_NEAREST, .minFilter = VK_FILTER_NEAREST, .addressModeU = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE, .addressModeV = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE, .addressModeW = VK_SAMPLER_ADDRESS_MODE_CLAMP_TO_EDGE };
  VkSampler smp; CK(vkCreateSampler(dev, &sci, NULL, &smp));
  VkDescriptorSetLayoutBinding bnd = { 0, VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 1, VK_SHADER_STAGE_FRAGMENT_BIT, NULL };
  VkDescriptorSetLayoutCreateInfo dsl = { .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_LAYOUT_CREATE_INFO, .bindingCount = 1, .pBindings = &bnd };
  VkDescriptorSetLayout dsLayout; CK(vkCreateDescriptorSetLayout(dev, &dsl, NULL, &dsLayout));
  VkDescriptorPoolSize ps = { VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, 1 }; VkDescriptorPoolCreateInfo dpci = { .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_POOL_CREATE_INFO, .maxSets = 1, .poolSizeCount = 1, .pPoolSizes = &ps };
  VkDescriptorPool dp; CK(vkCreateDescriptorPool(dev, &dpci, NULL, &dp));
  VkDescriptorSetAllocateInfo dai = { .sType = VK_STRUCTURE_TYPE_DESCRIPTOR_SET_ALLOCATE_INFO, .descriptorPool = dp, .descriptorSetCount = 1, .pSetLayouts = &dsLayout };
  VkDescriptorSet ds; CK(vkAllocateDescriptorSets(dev, &dai, &ds));
  VkDescriptorImageInfo dii = { smp, texv, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL };
  VkWriteDescriptorSet wds = { .sType = VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET, .dstSet = ds, .descriptorCount = 1, .descriptorType = VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER, .pImageInfo = &dii };
  vkUpdateDescriptorSets(dev, 1, &wds, 0, NULL);
  VkPushConstantRange pcr = { VK_SHADER_STAGE_VERTEX_BIT, 0, 64 };
  VkPipelineLayoutCreateInfo plci = { .sType = VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO, .setLayoutCount = 1, .pSetLayouts = &dsLayout, .pushConstantRangeCount = 1, .pPushConstantRanges = &pcr };
  VkPipelineLayout pl; CK(vkCreatePipelineLayout(dev, &plci, NULL, &pl));
  VkPipelineShaderStageCreateInfo st[2] = { { .sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO, .stage = VK_SHADER_STAGE_VERTEX_BIT, .module = shader(argv[1]), .pName = "main" },
    { .sType = VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO, .stage = VK_SHADER_STAGE_FRAGMENT_BIT, .module = shader(argv[2]), .pName = "main" } };
  VkVertexInputBindingDescription vbd = { 0, 20, VK_VERTEX_INPUT_RATE_VERTEX };
  VkVertexInputAttributeDescription vad[2] = { { 0, 0, VK_FORMAT_R32G32B32_SFLOAT, 0 }, { 1, 0, VK_FORMAT_R32G32_SFLOAT, 12 } };
  VkPipelineVertexInputStateCreateInfo vi = { .sType = VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO, .vertexBindingDescriptionCount = 1, .pVertexBindingDescriptions = &vbd, .vertexAttributeDescriptionCount = 2, .pVertexAttributeDescriptions = vad };
  VkPipelineInputAssemblyStateCreateInfo ia = { .sType = VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO, .topology = VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST };
  VkViewport vp = { 0, 0, W, H, 0, 1 }; VkRect2D sc = { { 0, 0 }, { W, H } };
  VkPipelineViewportStateCreateInfo vs = { .sType = VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO, .viewportCount = 1, .pViewports = &vp, .scissorCount = 1, .pScissors = &sc };
  VkPipelineRasterizationStateCreateInfo rs = { .sType = VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO, .polygonMode = VK_POLYGON_MODE_FILL, .cullMode = VK_CULL_MODE_NONE, .lineWidth = 1 };
  VkPipelineMultisampleStateCreateInfo ms = { .sType = VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO, .rasterizationSamples = VK_SAMPLE_COUNT_1_BIT };
  VkPipelineDepthStencilStateCreateInfo dss = { .sType = VK_STRUCTURE_TYPE_PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO, .depthTestEnable = 1, .depthWriteEnable = 1, .depthCompareOp = VK_COMPARE_OP_LESS };
  VkPipelineColorBlendAttachmentState cba = { .blendEnable = 1, .srcColorBlendFactor = VK_BLEND_FACTOR_SRC_ALPHA, .dstColorBlendFactor = VK_BLEND_FACTOR_ONE_MINUS_SRC_ALPHA, .colorBlendOp = VK_BLEND_OP_ADD, .srcAlphaBlendFactor = VK_BLEND_FACTOR_ONE, .dstAlphaBlendFactor = VK_BLEND_FACTOR_ZERO, .alphaBlendOp = VK_BLEND_OP_ADD, .colorWriteMask = 0xF };
  VkPipelineColorBlendStateCreateInfo cb = { .sType = VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO, .attachmentCount = 1, .pAttachments = &cba };
  VkGraphicsPipelineCreateInfo gp = { .sType = VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO, .stageCount = 2, .pStages = st, .pVertexInputState = &vi, .pInputAssemblyState = &ia, .pViewportState = &vs, .pRasterizationState = &rs, .pMultisampleState = &ms, .pDepthStencilState = &dss, .pColorBlendState = &cb, .layout = pl, .renderPass = rp };
  VkPipeline pipe; CK(vkCreateGraphicsPipelines(dev, VK_NULL_HANDLE, 1, &gp, NULL, &pipe)); printf("pipeline created\n");
  VkCommandPoolCreateInfo cpci = { .sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO }; VkCommandPool pool; CK(vkCreateCommandPool(dev, &cpci, NULL, &pool));
  VkCommandBufferAllocateInfo cai = { .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, .commandPool = pool, .commandBufferCount = 1 }; VkCommandBuffer cmd; CK(vkAllocateCommandBuffers(dev, &cai, &cmd));
  VkCommandBufferBeginInfo bi = { .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO }; CK(vkBeginCommandBuffer(cmd, &bi));
  barrier(cmd, tex, VK_IMAGE_ASPECT_COLOR_BIT, VK_IMAGE_LAYOUT_UNDEFINED, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL);
  VkBufferImageCopy bic = { .imageSubresource = { VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1 }, .imageExtent = { 16, 16, 1 } };
  vkCmdCopyBufferToImage(cmd, stg, tex, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, 1, &bic);
  barrier(cmd, tex, VK_IMAGE_ASPECT_COLOR_BIT, VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL);
  VkClearValue cv[2] = { { .color = { { 0, 0, 0, 1 } } }, { .depthStencil = { 1, 0 } } };
  VkRenderPassBeginInfo rbi = { .sType = VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO, .renderPass = rp, .framebuffer = fb, .renderArea = sc, .clearValueCount = 2, .pClearValues = cv };
  vkCmdBeginRenderPass(cmd, &rbi, VK_SUBPASS_CONTENTS_INLINE); vkCmdBindPipeline(cmd, VK_PIPELINE_BIND_POINT_GRAPHICS, pipe);
  vkCmdBindDescriptorSets(cmd, VK_PIPELINE_BIND_POINT_GRAPHICS, pl, 0, 1, &ds, 0, NULL);
  float ident[16] = { 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 }; vkCmdPushConstants(cmd, pl, VK_SHADER_STAGE_VERTEX_BIT, 0, 64, ident);
  VkDeviceSize off = 0; vkCmdBindVertexBuffers(cmd, 0, 1, &vb, &off); vkCmdDraw(cmd, 3, 1, 0, 0); vkCmdEndRenderPass(cmd);
  VkBufferImageCopy back = { .imageSubresource = { VK_IMAGE_ASPECT_COLOR_BIT, 0, 0, 1 }, .imageExtent = { W, H, 1 } };
  vkCmdCopyImageToBuffer(cmd, col, VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, rb, 1, &back); CK(vkEndCommandBuffer(cmd));
  VkSubmitInfo si = { .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .commandBufferCount = 1, .pCommandBuffers = &cmd }; CK(vkQueueSubmit(queue, 1, &si, VK_NULL_HANDLE)); CK(vkQueueWaitIdle(queue));
  uint8_t *o = rbp; uint8_t *ctr = o + ((H / 2) * W + W / 2) * 4, *corner = o;
  printf("centre pixel=%02X%02X%02X%02X corner pixel=%02X%02X%02X%02X\n", ctr[0], ctr[1], ctr[2], ctr[3], corner[0], corner[1], corner[2], corner[3]);
  printf("%s\n", (ctr[0] == 0x7D && ctr[1] == 0x7F && ctr[2] == 0x86 && corner[0] == 0) ? "OK textured triangle rendered and read back" : "MISMATCH");
  return 0;
}
