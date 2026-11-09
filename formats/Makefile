# Package formats: shared file-format readers → build/formats/libformats.a
# (contracts/test-harness-delta.md). Shared rules: tools/package.mk. Skeleton: SRC and TESTS fill in as
# the lane's tasks add sources.
PKG      := formats
LIBNAME  := libformats.a
SRC      := $(shell find src -name '*.cob' 2>/dev/null | sort)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I copy -I tests
DEPLIBS   = $(BUILD)/shim/libccshim.a
LDLIBS    = -lz

include ../tools/package.mk
