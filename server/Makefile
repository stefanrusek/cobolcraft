# Package server: COBOL server program → build/server/libserver.a (every SRC source except
# src/main.cob: callable programs, no main) and build/bin/cobolcraft-server (src/main.cob)
# (contracts/test-harness.md §2). Shared rules: tools/package.mk. copy/ holds the host state
# SVSTATE.cpy; tests/ is an include directory for the test helper copybook SVTEST.cpy.
PKG      := server
LIBNAME  := libserver.a
SRC      := $(wildcard src/*.cob)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I copy -I tests
DEPLIBS   = $(BUILD)/core/libcore.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
LDLIBS    = $(shell $(PKG_CONFIG) --libs libcrypto) -lz

include ../tools/package.mk

PROGRAM := $(BUILD)/bin/cobolcraft-server

.PHONY: bin
bin: $(if $(wildcard src/main.cob),$(PROGRAM))

$(OBJ)/main.o: src/main.cob $(COPYBOOKS)
	@mkdir -p $(dir $@)
	cobc -c -x $(COBFLAGS) -o $@ $<

$(PROGRAM): $(OBJ)/main.o $(LIB) $(DEPLIBS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -o $@ $(OBJ)/main.o $(LIB) $(DEPLIBS) $(LDLIBS)
