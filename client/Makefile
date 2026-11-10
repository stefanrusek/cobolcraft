# Package client: COBOL client program → build/client/libclient.a (every SRC source except
# src/main.cob: callable programs, no main) and build/bin/cobolcraft (src/main.cob)
# (contracts/test-harness.md §2). Shared rules: tools/package.mk. copy/ holds the client state
# CLSTATE.cpy and constants CLCONST.cpy; tests/ is an include directory for the test helper
# copybook CLTEST.cpy. The tests need the reference textures of tests/fixtures/textures, written by
# the independent generator tests/fixtures/gen_textures.py (test infrastructure, research R9), the
# zip archives of tests/fixtures/zips (gen_zips.py), the PNG files of tests/fixtures/png
# (gen_png.py) and the resource packs of tests/fixtures/packs (gen_packs.py, US18).
PKG      := client
LIBNAME  := libclient.a
SRC      := $(shell find src -name '*.cob' 2>/dev/null | sort)
TESTS    := $(wildcard tests/acc_*.cob tests/contract_*.cob tests/test_*.cob)
INCLUDES := -I copy -I tests -I ../proto/copy
DEPLIBS   = $(BUILD)/core/libcore.a $(BUILD)/content/libcontent.a $(BUILD)/formats/libformats.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
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

.PHONY: fixtures
tests: fixtures
fixtures:
	python3 tests/fixtures/gen_textures.py
	python3 tests/fixtures/gen_zips.py
	python3 tests/fixtures/gen_png.py
	python3 tests/fixtures/gen_packs.py
