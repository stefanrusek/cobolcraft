# Shared rules of the package Makefiles (contracts/test-harness.md §2). A package Makefile sets
# PKG, LIBNAME, SRC (production sources, the coverage set), TESTS (test program sources), INCLUDES,
# DEPLIBS (the dependency packages' lib outputs, dependents first) and LDLIBS, then includes this.
#
# Targets: lib (archive of every SRC object except src/main.cob), tests (one program per TESTS
# source), lint. Variables from the caller: BUILD (output root, default <repo>/build) and COVERAGE
# (1 = instrument with --coverage). Recipes run with the package directory as working directory, so
# gcov resolves the relative source paths from there (tools/coverage.py).

REPO     := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))..)
BUILD    ?= $(REPO)/build
COVERAGE ?= 0

OUT  := $(BUILD)/$(PKG)
OBJ  := $(OUT)/obj
TOUT := $(OUT)/tests
LIB  := $(OUT)/$(LIBNAME)

# OpenSSL is pinned to 3.x (research R1): pkg-config otherwise resolves openssl@4.
PKG_CONFIG := PKG_CONFIG_PATH=$(shell brew --prefix)/opt/openssl@3/lib/pkgconfig pkg-config

TESTLIB  := $(REPO)/tools/testlib
COBFLAGS := -free -debug -std=default -fstatic-call -I $(REPO)/contract/copy $(INCLUDES)
CFLAGS   := -std=c11 -Wall -Wextra -I $(REPO)/contract/include $(INCLUDES)
ifeq ($(COVERAGE),1)
COBFLAGS += --coverage
CFLAGS   += --coverage
LDCOV    := --coverage
endif

LINT_FILES  ?= $(SRC) $(TESTS)
LIB_SRC     := $(filter-out src/main.cob,$(SRC))
OBJS        := $(patsubst src/%,$(OBJ)/%.o,$(basename $(LIB_SRC)))
TEST_PROGS  := $(patsubst tests/%,$(TOUT)/%,$(basename $(TESTS)))
TESTASSERT  := $(TOUT)/testassert.o
COPYBOOKS   := $(wildcard $(REPO)/contract/copy/*.cpy copy/*.cpy)
HEADERS     := $(wildcard $(REPO)/contract/include/*.h)

.PHONY: lib tests lint
.DEFAULT_GOAL := lib

lib: $(LIB)

tests: $(LIB) $(TEST_PROGS)

lint:
	python3 $(REPO)/tools/lint.py -I $(TESTLIB) $(addprefix -I ,$(filter-out -I,$(INCLUDES))) $(LINT_FILES)

# An empty SRC builds a valid empty archive.
$(LIB): $(OBJS)
	@mkdir -p $(dir $@)
	rm -f $@
	$(if $(OBJS),ar rcs $@ $(OBJS),printf '!<arch>\n' > $@)

$(OBJ)/%.o: src/%.cob $(COPYBOOKS)
	@mkdir -p $(dir $@)
	cobc -c $(COBFLAGS) -o $@ $<

$(OBJ)/%.o: src/%.c $(HEADERS)
	@mkdir -p $(dir $@)
	clang -c $(CFLAGS) -o $@ $<

$(TESTASSERT): $(TESTLIB)/testassert.cob $(TESTLIB)/TESTLIB.cpy
	@mkdir -p $(dir $@)
	cobc -c $(COBFLAGS) -I $(TESTLIB) -o $@ $<

$(TOUT)/%: tests/%.cob $(TESTASSERT) $(LIB) $(DEPLIBS) $(COPYBOOKS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -I $(TESTLIB) -o $@ $< $(TESTASSERT) $(LIB) $(DEPLIBS) $(LDLIBS)

$(TOUT)/%: tests/%.c $(TESTLIB)/testlib.h $(LIB) $(DEPLIBS) $(HEADERS)
	@mkdir -p $(dir $@)
	clang $(CFLAGS) -I $(TESTLIB) -o $@ $< $(LIB) $(DEPLIBS) $(LDLIBS) $(LDCOV)
