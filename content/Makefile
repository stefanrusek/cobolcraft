# Package content: content registries and the pack loader → build/content/libcontent.a
# (contracts/test-harness-delta.md). Shared rules: tools/package.mk. copy/gen/ holds the generated registry
# copybooks (tools/gen/gen_tables.py; excluded from coverage). Skeleton: SRC and TESTS fill in with the lane.
PKG      := content
LIBNAME  := libcontent.a
SRC      :=
TESTS    :=
INCLUDES := -I copy -I copy/gen
DEPLIBS   = $(BUILD)/formats/libformats.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
LDLIBS    = -lz

include ../tools/package.mk
