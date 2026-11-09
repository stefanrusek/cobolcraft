# Package proto: COBOL protocol codec → build/proto/libproto.a (contracts/test-harness.md §2).
# Shared rules: tools/package.mk. tests/ is an include directory for the test helper copybook
# PROTOTEST.cpy (test infrastructure); copy/ holds PBLEVEL.cpy and PBCHAT.cpy, the records of
# src/level-events.cob and src/chat-commands.cob.
PKG      := proto
LIBNAME  := libproto.a
SRC      := $(wildcard src/*.cob)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I copy -I tests
DEPLIBS   = $(BUILD)/shim/libccshim.a
LDLIBS   := -lz

include ../tools/package.mk
