# Package core: COBOL game core → build/core/libcore.a (contracts/test-harness.md §2).
# Shared rules: tools/package.mk.
PKG      := core
LIBNAME  := libcore.a
SRC      := $(wildcard src/*.cob)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I copy
DEPLIBS   = $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
LDLIBS    = $(shell $(PKG_CONFIG) --libs libcrypto)

include ../tools/package.mk
