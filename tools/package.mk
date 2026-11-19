# Shared rules of the package Makefiles (contracts/test-harness.md §2). A package Makefile sets
# PKG, LIBNAME, SRC (production sources, the coverage set), TESTS (test program sources), INCLUDES,
# DEPLIBS (the dependency packages' lib outputs, dependents first) and LDLIBS, then includes this.
#
# Targets: lib (archive of every SRC object except src/main.cob), shlib (the same objects as a shared
# library, linked against the dependency packages' shared libraries), tests (one program per TESTS
# source), lint. Variables from the caller: BUILD (output root, default <repo>/build) and COVERAGE
# (1 = instrument with --coverage). Recipes run with the package directory as working directory, so
# gcov resolves the relative source paths from there (tools/coverage.py).
#
# The programs (bin) link the archives. The test programs link the shared libraries: a test program
# then holds only its own code, and a changed production source rebuilds its object and the shared
# library, never the test programs.
#
# Dependencies: every compile writes a dependency file next to its output (cobc -MF, clang -MMD) that
# names the copybooks or headers it read, in any package; the files are included below. A source is
# rebuilt when it or one of those files changed.

REPO     := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))..)
BUILD    ?= $(REPO)/build
COVERAGE ?= 0
# RELEASE=1 (non-debug build, make build RELEASE=1): -O2 in place of -debug, never with COVERAGE.
RELEASE  ?= 0
ifeq ($(RELEASE)$(COVERAGE),10)
DEBUGFLAG := -O2
else
DEBUGFLAG := -debug
endif

OUT  := $(BUILD)/$(PKG)
OBJ  := $(OUT)/obj
TOUT := $(OUT)/tests
LIB  := $(OUT)/$(LIBNAME)

# OpenSSL is pinned to 3.x (research R1): pkg-config otherwise resolves openssl@4.
PKG_CONFIG := PKG_CONFIG_PATH=$(shell brew --prefix)/opt/openssl@3/lib/pkgconfig pkg-config

TESTLIB  := $(REPO)/tools/testlib
COBFLAGS := -free $(DEBUGFLAG) -std=default -fstatic-call -I $(REPO)/contract/copy $(INCLUDES)
# FPFAST=1 (the default): the C that cobc generates for a COBOL program calls the shim's ccfp_decimal_* in place of
# libcob's cob_decimal_*, and ccfp_intr_* in place of cob_intr_sin, cos, sqrt, mod, binop, tan, atan, integer, integer_part, abs and pi, and ccfp_* in place of
# cob_cmp_llint, cob_cmp, cob_numeric_cmp, cob_get_int, cob_get_llint and cob_move (shim/src/cc_fpfast.c:
# arithmetic on FLOAT-LONG and FLOAT-SHORT fields in IEEE double, every other case passed on to libcob). FPFAST=0 compiles the same sources without the defines: libcob alone. The two
# settings share build/, so a change of the setting recompiles every COBOL object ($(FPFAST_STAMP)).
FPFAST   ?= 1
FPFAST_NAMES := set_field get_field add sub mul div pow cmp align
FPFAST_INTRINSICS := sin cos sqrt mod binop tan atan integer integer_part abs pi
FPFAST_PLAIN := cmp_llint cmp numeric_cmp get_int get_llint move
ifeq ($(FPFAST),1)
COBFLAGS += -A "$(foreach n,$(FPFAST_NAMES),-Dcob_decimal_$(n)=ccfp_decimal_$(n)) $(foreach n,$(FPFAST_INTRINSICS),-Dcob_intr_$(n)=ccfp_intr_$(n)) $(foreach n,$(FPFAST_PLAIN),-Dcob_$(n)=ccfp_$(n))"
endif
# The shim's cc_fpfast.c calls GMP itself (every COBOL program links libcob, which links GMP).
LDLIBS   += -L$(shell brew --prefix gmp)/lib -lgmp
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
# Generated contract tests (tools/gen/gen_contract.py, written by tools/runtests.py) are built like TESTS.
GENDIR      := $(BUILD)/gen/$(PKG)/tests
GEN_PROGS   := $(patsubst $(GENDIR)/%,$(TOUT)/%,$(basename $(wildcard $(GENDIR)/*.cob)))
TESTASSERT  := $(TOUT)/testassert.o
FPFAST_STAMP := $(OUT)/fpfast-$(FPFAST)-$(words $(FPFAST_NAMES) $(FPFAST_INTRINSICS) $(FPFAST_PLAIN)).stamp
# The shared library of the package and those of the packages it links (DEPLIBS, dependents first).
SHLIB       := $(LIB:.a=.dylib)
DEPSHLIBS    = $(DEPLIBS:.a=.dylib)
COBLIBS     := $(shell cob-config --libs)

.PHONY: lib shlib tests lint
.DEFAULT_GOAL := lib

lib: $(LIB)

shlib: $(SHLIB)

tests: $(SHLIB) $(TEST_PROGS) $(GEN_PROGS)

lint:
	python3 $(REPO)/tools/lint.py -I $(TESTLIB) $(addprefix -I ,$(filter-out -I,$(INCLUDES))) $(LINT_FILES)

# An empty SRC builds a valid empty archive.
$(LIB): $(OBJS)
	@mkdir -p $(dir $@)
	rm -f $@
	$(if $(OBJS),ar rcs $@ $(OBJS),printf '!<arch>\n' > $@)

# Every object, with the dependency packages' shared libraries; its install name is its own path, so a
# test program finds it without any environment. The dependency libraries are order-only: a changed
# one is found again when the program starts.
# -flat_namespace and -interposable keep what linking the archive gives a test program that defines a
# program name of the library itself (a test seam such as core/tests/JIGSEAM.cpy): the library's own
# calls of that name reach the test program's definition.
$(SHLIB): $(OBJS) | $(DEPSHLIBS)
	@mkdir -p $(dir $@)
	clang -dynamiclib -Wl,-flat_namespace -Wl,-interposable -install_name $@ -o $@ $(OBJS) $(DEPSHLIBS) $(LDLIBS) $(COBLIBS) $(LDCOV)

# The stamp of the FPFAST setting the COBOL objects of this build were compiled with: making the one of the
# current setting removes the other, so a change of the setting makes every COBOL object older than its stamp.
$(FPFAST_STAMP):
	@mkdir -p $(dir $@)
	@rm -f $(OUT)/fpfast-*.stamp
	@touch $@

# A new object makes the counts of its earlier runs (.gcda) unreadable: they go with it.
$(OBJ)/%.o: src/%.cob $(FPFAST_STAMP)
	@mkdir -p $(dir $@)
	@rm -f $(@:.o=.gcda)
	cobc -c $(COBFLAGS) -MF $(@:.o=.d) -MT $@ -o $@ $<

$(OBJ)/%.o: src/%.c
	@mkdir -p $(dir $@)
	@rm -f $(@:.o=.gcda)
	clang -c $(CFLAGS) -MMD -MF $(@:.o=.d) -o $@ $<

$(TESTASSERT): $(TESTLIB)/testassert.cob $(FPFAST_STAMP)
	@mkdir -p $(dir $@)
	cobc -c $(COBFLAGS) -I $(TESTLIB) -MF $(@:.o=.d) -MT $@ -o $@ $<

$(TOUT)/%: tests/%.cob $(TESTASSERT) $(FPFAST_STAMP) | $(SHLIB) $(DEPSHLIBS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -I $(TESTLIB) -MF $@.d -MT $@ -o $@ $< $(TESTASSERT) $(SHLIB) $(DEPSHLIBS) $(LDLIBS)

$(TOUT)/%: $(GENDIR)/%.cob $(TESTASSERT) $(FPFAST_STAMP) | $(SHLIB) $(DEPSHLIBS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -I $(TESTLIB) -MF $@.d -MT $@ -o $@ $< $(TESTASSERT) $(SHLIB) $(DEPSHLIBS) $(LDLIBS)

$(TOUT)/%: tests/%.c | $(SHLIB) $(DEPSHLIBS)
	@mkdir -p $(dir $@)
	clang $(CFLAGS) -I $(TESTLIB) -MMD -MF $@.d -o $@ $< $(SHLIB) $(DEPSHLIBS) $(LDLIBS) $(LDCOV)

# The dependency files of earlier compiles. A copybook or header that was deleted since is no error:
# the source that named it is rebuilt (and fails there if it still names it).
-include $(OBJS:.o=.d) $(TESTASSERT:.o=.d) $(addsuffix .d,$(TEST_PROGS) $(GEN_PROGS))
%.cpy: ;
%.CPY: ;
%.h: ;
