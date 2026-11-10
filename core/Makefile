# Package core: COBOL game core → build/core/libcore.a (contracts/test-harness.md §2).
# Shared rules: tools/package.mk. tests/ is an include directory for the test helper copybook
# CORETEST.cpy (test infrastructure). The core links proto frame and NBT-file code, hence -lz.
PKG      := core
LIBNAME  := libcore.a
SRC      := $(wildcard src/*.cob)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I copy -I tests
DEPLIBS   = $(BUILD)/content/libcontent.a $(BUILD)/formats/libformats.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
LDLIBS    = $(shell $(PKG_CONFIG) --libs libcrypto) -lz

include ../tools/package.mk
