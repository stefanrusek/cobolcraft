# Package content: content registries and the pack loader → build/content/libcontent.a
# (contracts/test-harness-delta.md). Shared rules: tools/package.mk. copy/gen/ holds the generated registry
# copybooks (tools/gen/gen_tables.py; excluded from coverage). Skeleton: SRC and TESTS fill in with the lane.
PKG      := content
LIBNAME  := libcontent.a
SRC      := $(shell find src -name '*.cob' 2>/dev/null | sort)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I copy -I copy/gen
DEPLIBS   = $(BUILD)/formats/libformats.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
LDLIBS    = $(shell $(PKG_CONFIG) --libs libcrypto) -lz

include ../tools/package.mk
