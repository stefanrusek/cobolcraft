# Package formats: shared file-format readers → build/formats/libformats.a
# (contracts/test-harness-delta.md). Shared rules: tools/package.mk. Skeleton: SRC and TESTS fill in as
# the lane's tasks add sources.
PKG      := formats
LIBNAME  := libformats.a
SRC      :=
TESTS    :=
INCLUDES := -I copy
DEPLIBS   = $(BUILD)/shim/libccshim.a
LDLIBS    = -lz

include ../tools/package.mk
