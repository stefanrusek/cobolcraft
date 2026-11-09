# Package extract: asset extraction tool → build/extract/libextract.a (every SRC source except
# src/main.cob) and build/bin/cobolcraft-extract (src/main.cob) (contracts/test-harness-delta.md).
# Shared rules: tools/package.mk. Skeleton: SRC and TESTS fill in with the lane.
PKG      := extract
LIBNAME  := libextract.a
SRC      := $(wildcard src/*.cob)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I copy -I tests -I ../content/copy -I ../content/copy/gen -I ../formats/copy
DEPLIBS   = $(BUILD)/content/libcontent.a $(BUILD)/formats/libformats.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
LDLIBS    = $(shell $(PKG_CONFIG) --libs libcrypto) -lz

include ../tools/package.mk

PROGRAM := $(BUILD)/bin/cobolcraft-extract

# The recipe only names the program, so `make -n build` always shows build/bin/cobolcraft-extract
# (tools/tests/acc_f2us1_gate_targets.py), also when it is up to date.
.PHONY: bin
bin: $(PROGRAM)
	@echo "extract: $(PROGRAM)"

$(OBJ)/main.o: src/main.cob $(COPYBOOKS)
	@mkdir -p $(dir $@)
	cobc -c -x $(COBFLAGS) -o $@ $<

$(PROGRAM): $(OBJ)/main.o $(LIB) $(DEPLIBS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -o $@ $(OBJ)/main.o $(LIB) $(DEPLIBS) $(LDLIBS)
