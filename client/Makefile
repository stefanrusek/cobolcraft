# Package client: COBOL client program → build/client/libclient.a (every SRC source except
# src/main.cob: callable programs, no main) and build/bin/cobolcraft (src/main.cob)
# (contracts/test-harness.md §2). Shared rules: tools/package.mk.
PKG      := client
LIBNAME  := libclient.a
SRC      := $(shell find src -name '*.cob' 2>/dev/null | sort)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I copy
DEPLIBS   = $(BUILD)/core/libcore.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
LDLIBS    = $(shell $(PKG_CONFIG) --libs glfw3 vulkan libssl libcrypto) -lz

include ../tools/package.mk

PROGRAM := $(BUILD)/bin/cobolcraft

.PHONY: bin
bin: $(if $(wildcard src/main.cob),$(PROGRAM))

$(OBJ)/main.o: src/main.cob $(COPYBOOKS)
	@mkdir -p $(dir $@)
	cobc -c -x $(COBFLAGS) -o $@ $<

$(PROGRAM): $(OBJ)/main.o $(LIB) $(DEPLIBS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -o $@ $(OBJ)/main.o $(LIB) $(DEPLIBS) $(LDLIBS)
