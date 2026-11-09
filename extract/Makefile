# Package extract: asset extraction tool → build/extract/libextract.a (every SRC source except
# src/main.cob) and build/bin/cobolcraft-extract (src/main.cob) (contracts/test-harness-delta.md).
# Shared rules: tools/package.mk. Skeleton: SRC and TESTS fill in with the lane.
PKG      := extract
LIBNAME  := libextract.a
SRC      :=
TESTS    :=
INCLUDES := -I $(REPO)/content/copy -I $(REPO)/content/copy/gen -I $(REPO)/formats/copy
DEPLIBS   = $(BUILD)/content/libcontent.a $(BUILD)/formats/libformats.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
LDLIBS    = -lz

include ../tools/package.mk

PROGRAM := $(BUILD)/bin/cobolcraft-extract

# Until src/main.cob exists the program is only named, so `make build` stays green on the skeleton.
.PHONY: bin
bin: $(if $(wildcard src/main.cob),$(PROGRAM))
	$(if $(wildcard src/main.cob),@true,@echo "extract: $(PROGRAM) is built once src/main.cob exists")

$(OBJ)/main.o: src/main.cob $(COPYBOOKS)
	@mkdir -p $(dir $@)
	cobc -c -x $(COBFLAGS) -o $@ $<

$(PROGRAM): $(OBJ)/main.o $(LIB) $(DEPLIBS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -o $@ $(OBJ)/main.o $(LIB) $(DEPLIBS) $(LDLIBS)
