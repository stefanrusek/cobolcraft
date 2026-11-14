#!/bin/sh
# Workspace bootstrap (`make bootstrap`; contracts/test-harness.md §1, research R1).
# 1. Checks every prerequisite; names the missing ones, prints the install line and exits 1.
# 2. Creates the build/ tree (including build/generated-test/, the scratch space of tests that run the
#    extraction tool).
# 3. Compiles shim/shaders/*.vert and *.frag to build/shaders/<file>.spv.
# It starts no shared infrastructure.
set -u
REPO=$(cd "$(dirname "$0")/.." && pwd)
PACKAGES="shim formats proto content extract core server client"
BREW_LINE="brew install gnucobol glfw molten-vk vulkan-loader vulkan-headers glslang openssl@3 pkg-config"

missing=""
need() {
    missing="$missing
  $1"
}
have() {
    command -v "$1" >/dev/null 2>&1
}

if have brew; then
    HOMEBREW=$(brew --prefix)
else
    HOMEBREW=/nonexistent
    need "brew (Homebrew, https://brew.sh)"
fi
if have cobc; then
    cobc --version | head -n 1 | grep -q ' 3\.2' || need "cobc 3.2 (gnucobol)"
else
    need "cobc 3.2 (gnucobol)"
fi
have clang || need "clang (xcode-select --install)"
have gcov || need "gcov (xcode-select --install)"
have python3 || need "python3"
have glslangValidator || need "glslangValidator (glslang)"
have spirv-val || need "spirv-val (glslang)"
if have pkg-config; then
    pkg-config --atleast-version=3.4 glfw3 || need "GLFW 3.4 or later (glfw)"
    pkg-config --exists vulkan || need "Vulkan loader (vulkan-loader)"
    case $(PKG_CONFIG_PATH="$HOMEBREW/opt/openssl@3/lib/pkgconfig" pkg-config --modversion openssl 2>/dev/null) in
        3.*) ;;
        *) need "OpenSSL 3 (openssl@3)" ;;
    esac
else
    need "pkg-config (pkg-config)"
fi
[ -f "$HOMEBREW/opt/vulkan-headers/include/vulkan/vulkan.h" ] || need "Vulkan headers (vulkan-headers)"
[ -f "$HOMEBREW/opt/molten-vk/etc/vulkan/icd.d/MoltenVK_icd.json" ] || need "MoltenVK ICD (molten-vk)"

if [ -n "$missing" ]; then
    echo "Missing prerequisites:$missing"
    echo "Install them with:"
    echo "  xcode-select --install   (only for clang or gcov)"
    echo "  $BREW_LINE"
    exit 1
fi

mkdir -p "$REPO/build/bin" "$REPO/build/shaders" "$REPO/build/generated-test" || exit 1
for package in $PACKAGES; do
    mkdir -p "$REPO/build/$package/obj" "$REPO/build/$package/tests" || exit 1
done

for shader in "$REPO"/shim/shaders/*.vert "$REPO"/shim/shaders/*.frag; do
    [ -f "$shader" ] || continue
    glslangValidator -V "$shader" -o "$REPO/build/shaders/$(basename "$shader").spv" || exit 1
done
echo "bootstrap: all prerequisites present; build/ ready"
