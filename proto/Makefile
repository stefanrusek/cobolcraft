# Package proto: COBOL protocol codec → build/proto/libproto.a (contracts/test-harness.md §2).
# Shared rules: tools/package.mk.
PKG      := proto
LIBNAME  := libproto.a
SRC      := $(wildcard src/*.cob)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES :=
DEPLIBS   = $(BUILD)/shim/libccshim.a
LDLIBS   :=

include ../tools/package.mk
