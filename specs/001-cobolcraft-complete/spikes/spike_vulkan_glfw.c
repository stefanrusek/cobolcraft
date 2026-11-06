/* spike (throwaway): GLFW window + MoltenVK via the Vulkan loader on macOS arm64.
   Validates: loader finds MoltenVK ICD, portability enumeration is needed, GLFW creates a
   Vulkan surface, a swapchain can be created, one frame can be cleared and presented,
   and GLFW exposes key/char/scroll/cursor callbacks. */
#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define CK(x) do { VkResult r_ = (x); if (r_ != VK_SUCCESS) { printf("FAIL %s -> %d\n", #x, r_); return 1; } } while (0)
static void onkey(GLFWwindow *w, int k, int s, int a, int m) { (void)w;(void)k;(void)s;(void)a;(void)m; }
static void onchar(GLFWwindow *w, unsigned int c) { (void)w;(void)c; }
static void onscroll(GLFWwindow *w, double x, double y) { (void)w;(void)x;(void)y; }
int main(void) {
  /* GLFW dlopens libvulkan from default dyld paths only; Homebrew's loader is in /opt/homebrew/lib,
     so hand GLFW the linked loader entry point (GLFW >= 3.4). */
  if (getenv("SPIKE_NO_LOADER_HANDOFF") == NULL) glfwInitVulkanLoader(vkGetInstanceProcAddr);
  if (!glfwInit()) { printf("FAIL glfwInit\n"); return 1; }
  printf("glfw %s vulkanSupported=%d\n", glfwGetVersionString(), glfwVulkanSupported());
  uint32_t n = 0; const char **req = glfwGetRequiredInstanceExtensions(&n);
  const char *exts[16]; for (uint32_t i = 0; i < n; i++) { exts[i] = req[i]; printf("glfw-required-ext %s\n", req[i]); }
  exts[n++] = VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME;
  VkApplicationInfo ai = { .sType = VK_STRUCTURE_TYPE_APPLICATION_INFO, .apiVersion = VK_API_VERSION_1_2 };
  VkInstanceCreateInfo ici = { .sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO, .pApplicationInfo = &ai,
    .enabledExtensionCount = n, .ppEnabledExtensionNames = exts };
  VkInstance inst;
  VkResult without = vkCreateInstance(&ici, NULL, &inst);
  printf("createInstance without portability flag -> %d\n", without);
  if (without == VK_SUCCESS) { uint32_t c=0; vkEnumeratePhysicalDevices(inst,&c,NULL); printf("  devices without flag=%u\n", c); vkDestroyInstance(inst,NULL); }
  ici.flags = VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
  CK(vkCreateInstance(&ici, NULL, &inst));
  uint32_t dc = 0; vkEnumeratePhysicalDevices(inst, &dc, NULL);
  VkPhysicalDevice pd[4]; vkEnumeratePhysicalDevices(inst, &dc, pd);
  VkPhysicalDeviceProperties pp; vkGetPhysicalDeviceProperties(pd[0], &pp);
  printf("device %s api %u.%u.%u\n", pp.deviceName, VK_API_VERSION_MAJOR(pp.apiVersion), VK_API_VERSION_MINOR(pp.apiVersion), VK_API_VERSION_PATCH(pp.apiVersion));
  uint32_t ec = 0; vkEnumerateDeviceExtensionProperties(pd[0], NULL, &ec, NULL);
  VkExtensionProperties *ep = calloc(ec, sizeof *ep); vkEnumerateDeviceExtensionProperties(pd[0], NULL, &ec, ep);
  int hasSubset = 0; for (uint32_t i = 0; i < ec; i++) if (!strcmp(ep[i].extensionName, "VK_KHR_portability_subset")) hasSubset = 1;
  printf("device has VK_KHR_portability_subset=%d\n", hasSubset);
  glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
  glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
  GLFWwindow *win = glfwCreateWindow(320, 240, "spike", NULL, NULL);
  if (!win) { printf("FAIL glfwCreateWindow\n"); return 1; }
  glfwSetKeyCallback(win, onkey); glfwSetCharCallback(win, onchar); glfwSetScrollCallback(win, onscroll);
  VkSurfaceKHR surf; CK(glfwCreateWindowSurface(inst, win, NULL, &surf));
  printf("surface created\n");
  uint32_t qc = 0; vkGetPhysicalDeviceQueueFamilyProperties(pd[0], &qc, NULL);
  VkQueueFamilyProperties qf[8]; vkGetPhysicalDeviceQueueFamilyProperties(pd[0], &qc, qf);
  uint32_t q = 0; VkBool32 pres = 0; vkGetPhysicalDeviceSurfaceSupportKHR(pd[0], q, surf, &pres);
  printf("queue0 graphics=%d present=%d\n", !!(qf[0].queueFlags & VK_QUEUE_GRAPHICS_BIT), pres);
  float prio = 1.0f;
  VkDeviceQueueCreateInfo qci = { .sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO, .queueFamilyIndex = q, .queueCount = 1, .pQueuePriorities = &prio };
  const char *dext[2] = { VK_KHR_SWAPCHAIN_EXTENSION_NAME, "VK_KHR_portability_subset" };
  VkDeviceCreateInfo dci = { .sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO, .queueCreateInfoCount = 1, .pQueueCreateInfos = &qci,
    .enabledExtensionCount = hasSubset ? 2 : 1, .ppEnabledExtensionNames = dext };
  VkDevice dev; CK(vkCreateDevice(pd[0], &dci, NULL, &dev));
  VkSurfaceCapabilitiesKHR caps; CK(vkGetPhysicalDeviceSurfaceCapabilitiesKHR(pd[0], surf, &caps));
  uint32_t fc = 0; vkGetPhysicalDeviceSurfaceFormatsKHR(pd[0], surf, &fc, NULL);
  VkSurfaceFormatKHR fm[32]; if (fc > 32) fc = 32; vkGetPhysicalDeviceSurfaceFormatsKHR(pd[0], surf, &fc, fm);
  printf("surface format0=%d minImages=%u extent=%ux%u\n", fm[0].format, caps.minImageCount, caps.currentExtent.width, caps.currentExtent.height);
  VkSwapchainCreateInfoKHR sci = { .sType = VK_STRUCTURE_TYPE_SWAPCHAIN_CREATE_INFO_KHR, .surface = surf, .minImageCount = caps.minImageCount,
    .imageFormat = fm[0].format, .imageColorSpace = fm[0].colorSpace, .imageExtent = caps.currentExtent, .imageArrayLayers = 1,
    .imageUsage = VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT, .preTransform = caps.currentTransform,
    .compositeAlpha = VK_COMPOSITE_ALPHA_OPAQUE_BIT_KHR, .presentMode = VK_PRESENT_MODE_FIFO_KHR, .clipped = VK_TRUE };
  VkSwapchainKHR sc; CK(vkCreateSwapchainKHR(dev, &sci, NULL, &sc));
  uint32_t ic = 0; vkGetSwapchainImagesKHR(dev, sc, &ic, NULL); VkImage imgs[8]; vkGetSwapchainImagesKHR(dev, sc, &ic, imgs);
  printf("swapchain images=%u\n", ic);
  VkQueue queue; vkGetDeviceQueue(dev, q, 0, &queue);
  VkCommandPoolCreateInfo pci = { .sType = VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO, .queueFamilyIndex = q };
  VkCommandPool pool; CK(vkCreateCommandPool(dev, &pci, NULL, &pool));
  VkCommandBufferAllocateInfo cai = { .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO, .commandPool = pool, .level = VK_COMMAND_BUFFER_LEVEL_PRIMARY, .commandBufferCount = 1 };
  VkCommandBuffer cb; CK(vkAllocateCommandBuffers(dev, &cai, &cb));
  VkSemaphoreCreateInfo semi = { .sType = VK_STRUCTURE_TYPE_SEMAPHORE_CREATE_INFO };
  VkSemaphore acq, done; CK(vkCreateSemaphore(dev, &semi, NULL, &acq)); CK(vkCreateSemaphore(dev, &semi, NULL, &done));
  uint32_t idx; CK(vkAcquireNextImageKHR(dev, sc, UINT64_MAX, acq, VK_NULL_HANDLE, &idx));
  VkCommandBufferBeginInfo bi = { .sType = VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO };
  CK(vkBeginCommandBuffer(cb, &bi));
  VkImageSubresourceRange rng = { VK_IMAGE_ASPECT_COLOR_BIT, 0, 1, 0, 1 };
  VkImageMemoryBarrier b1 = { .sType = VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER, .oldLayout = VK_IMAGE_LAYOUT_UNDEFINED, .newLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL,
    .srcQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED, .dstQueueFamilyIndex = VK_QUEUE_FAMILY_IGNORED, .image = imgs[idx], .subresourceRange = rng, .dstAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT };
  vkCmdPipelineBarrier(cb, VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT, VK_PIPELINE_STAGE_TRANSFER_BIT, 0, 0, NULL, 0, NULL, 1, &b1);
  VkClearColorValue col = { .float32 = { 0.3f, 0.5f, 0.9f, 1.0f } };
  vkCmdClearColorImage(cb, imgs[idx], VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL, &col, 1, &rng);
  VkImageMemoryBarrier b2 = b1; b2.oldLayout = VK_IMAGE_LAYOUT_TRANSFER_DST_OPTIMAL; b2.newLayout = VK_IMAGE_LAYOUT_PRESENT_SRC_KHR; b2.srcAccessMask = VK_ACCESS_TRANSFER_WRITE_BIT; b2.dstAccessMask = 0;
  vkCmdPipelineBarrier(cb, VK_PIPELINE_STAGE_TRANSFER_BIT, VK_PIPELINE_STAGE_BOTTOM_OF_PIPE_BIT, 0, 0, NULL, 0, NULL, 1, &b2);
  CK(vkEndCommandBuffer(cb));
  VkPipelineStageFlags ws = VK_PIPELINE_STAGE_TRANSFER_BIT;
  VkSubmitInfo si = { .sType = VK_STRUCTURE_TYPE_SUBMIT_INFO, .waitSemaphoreCount = 1, .pWaitSemaphores = &acq, .pWaitDstStageMask = &ws,
    .commandBufferCount = 1, .pCommandBuffers = &cb, .signalSemaphoreCount = 1, .pSignalSemaphores = &done };
  CK(vkQueueSubmit(queue, 1, &si, VK_NULL_HANDLE));
  VkPresentInfoKHR pi = { .sType = VK_STRUCTURE_TYPE_PRESENT_INFO_KHR, .waitSemaphoreCount = 1, .pWaitSemaphores = &done, .swapchainCount = 1, .pSwapchains = &sc, .pImageIndices = &idx };
  VkResult pr = vkQueuePresentKHR(queue, &pi);
  printf("present -> %d\n", pr);
  vkDeviceWaitIdle(dev);
  printf("OK frame cleared and presented\n");
  return 0;
}
