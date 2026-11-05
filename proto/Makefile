# Package proto: COBOL protocol codec → build/proto/libproto.a (contracts/test-harness.md §2).
# Shared rules: tools/package.mk. tests/ is an include directory for the test helper copybook
# PROTOTEST.cpy (test infrastructure).
PKG      := proto
LIBNAME  := libproto.a
SRC      := $(wildcard src/*.cob)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I tests
DEPLIBS   = $(BUILD)/shim/libccshim.a
LDLIBS   := -lz

include ../tools/package.mk
