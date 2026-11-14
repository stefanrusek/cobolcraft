/* spike (throwaway): the GPU limits the 32x pack's atlases depend on (texture size, array layers).
 * Real Vulkan through the loader and MoltenVK, portability enumeration as in the shim. */
#include <stdio.h>
#include <vulkan/vulkan.h>
#include <vulkan/vulkan_beta.h>
int main(void) {
    const char *ext[] = {VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME};
    VkInstanceCreateInfo ci = {VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO};
    ci.flags = VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
    ci.enabledExtensionCount = 1; ci.ppEnabledExtensionNames = ext;
    VkInstance inst;
    if (vkCreateInstance(&ci, NULL, &inst) != VK_SUCCESS) { puts("no instance"); return 1; }
    uint32_t n = 1; VkPhysicalDevice pd;
    vkEnumeratePhysicalDevices(inst, &n, &pd);
    VkPhysicalDeviceProperties p; vkGetPhysicalDeviceProperties(pd, &p);
    printf("device=%s\nmaxImageDimension2D=%u\nmaxImageArrayLayers=%u\nmaxPushConstantsSize=%u\n",
           p.deviceName, p.limits.maxImageDimension2D, p.limits.maxImageArrayLayers,
           p.limits.maxPushConstantsSize);
    VkImageFormatProperties f;
    VkResult r = vkGetPhysicalDeviceImageFormatProperties(pd, VK_FORMAT_R8G8B8A8_UNORM, VK_IMAGE_TYPE_2D,
        VK_IMAGE_TILING_OPTIMAL, VK_IMAGE_USAGE_SAMPLED_BIT | VK_IMAGE_USAGE_TRANSFER_DST_BIT, 0, &f);
    printf("RGBA8 sampled 2D: result=%d maxExtent=%ux%u maxMipLevels=%u maxArrayLayers=%u\n", r,
           f.maxExtent.width, f.maxExtent.height, f.maxMipLevels, f.maxArrayLayers);
    vkDestroyInstance(inst, NULL);
    return 0;
}
