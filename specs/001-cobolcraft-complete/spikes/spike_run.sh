#!/bin/sh
# Re-runs every spike of this feature and rewrites the *.out.txt evidence files.
# Prerequisites: see ../research.md R1 (Homebrew: gnucobol glfw molten-vk vulkan-loader
# vulkan-headers glslang openssl@3; Xcode command line tools; lcov).
set -u
cd "$(dirname "$0")"
T=$(mktemp -d)
export PKG_CONFIG_PATH=/opt/homebrew/opt/openssl@3/lib/pkgconfig
{ cobc --version | head -1; cobc -x -Wall -o "$T/i" spike_interop.cob spike_interop_shim.c && "$T/i"; } > spike_interop.out.txt 2>&1
( cp spike_coverage.cob "$T/"; cd "$T" && cobc -x --coverage -o c spike_coverage.cob && ./c && gcov spike_coverage >/dev/null 2>&1; cat spike_coverage.cob.gcov ) > spike_coverage.out.txt 2>&1
{ echo "-Wall -Werror:"; cobc -fsyntax-only -Wall -Werror spike_lint_truncate.cob; echo "exit=$?";
  echo "-Wall -Wextra -Werror:"; cobc -fsyntax-only -Wall -Wextra -Werror spike_lint_truncate.cob; echo "exit=$?"; } > spike_lint.out.txt 2>&1
{ cobc -x -O2 -Wall -o "$T/m" spike_modules_main.cob spike_modules_count.cob && /usr/bin/time -p "$T/m"; } > spike_modules.out.txt 2>&1
{ clang -std=c11 -Wall -Wextra -o "$T/v" spike_vulkan_glfw.c $(pkg-config --cflags --libs glfw3 vulkan) && "$T/v";
  echo "--- without loader handoff:"; SPIKE_NO_LOADER_HANDOFF=1 "$T/v"; } > spike_vulkan_glfw.out.txt 2>&1
{ glslangValidator --version | head -1; glslangValidator -V spike_shader.vert -o "$T/v.spv" && spirv-val "$T/v.spv" && echo "SPIR-V valid"; } > spike_shader.out.txt 2>&1
{ clang -std=c11 -Wall -o "$T/l" spike_libs.c -lz $(pkg-config --cflags --libs openssl) && "$T/l"; } > spike_libs.out.txt 2>&1
rm -rf "$T"
# TLS trust-store override used by the client's download tests (research R10)
T2=$(mktemp -d); clang -std=c11 -o "$T2/l" spike_libs.c -lz $(pkg-config --cflags --libs openssl) 2>/dev/null
{ printf '\n# SSL_CERT_FILE=/dev/null (OpenSSL env override of the default trust store):\n'; SSL_CERT_FILE=/dev/null "$T2/l" 2>&1 | grep -E 'tls|http'; } >> spike_libs.out.txt
( cd "$T2" && cobc -x -Wall -o f "$OLDPWD/spike_fileio.cob" && ./f ) > spike_fileio.out.txt 2>&1
rm -rf "$T2"
# Offscreen pipeline: SPIR-V shaders, texture sampling, depth, blending, push constants, readback (research R3/R4)
T3=$(mktemp -d)
{ glslangValidator -V spike_pipeline.vert -o "$T3/v.spv" && glslangValidator -V spike_pipeline.frag -o "$T3/f.spv" &&
  clang -std=c11 -Wall -o "$T3/p" spike_pipeline.c $(pkg-config --cflags --libs vulkan) && "$T3/p" "$T3/v.spv" "$T3/f.spv"; } > spike_pipeline.out.txt 2>&1
rm -rf "$T3"
# COBOL calling libcrypto directly, no glue (research R11, constitution v1.2.0)
T4=$(mktemp -d)
{ cobc -x -Wall -o "$T4/d" spike_direct_openssl.cob $(pkg-config --libs openssl) && "$T4/d"; } > spike_direct_openssl.out.txt 2>&1
rm -rf "$T4"
