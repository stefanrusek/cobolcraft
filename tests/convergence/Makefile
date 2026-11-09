# Convergence tests (plan "Execution mode", Convergence; contracts/test-harness.md §2): the
# cross-package acceptance tests tests/convergence/acc_*.cob, each linked with the harness
# (convharness.cob, CONVH.cpy: test infrastructure), build/client/libclient.a,
# build/server/libserver.a (the callable-program lib targets), core, proto and shim, and run in
# process: client instances against one core, through the client's single-player host or the
# server program's TCP host on loopback.
#
# The tests target also builds the two programs as $(OUT)/bin/cobolcraft and
# $(OUT)/bin/cobolcraft-server from each package's src/main.cob (compiled in the package directory,
# so gcov resolves the source; the objects live under $(OUT)/obj/<pkg>, which tools/coverage.py
# reads, and never in the package's own obj, which a package gate does not run). acc_binaries runs
# them. Variables from the caller: BUILD (output root) and COVERAGE (1 = instrumented).
REPO     := $(abspath $(CURDIR)/../..)
BUILD    ?= $(REPO)/build
COVERAGE ?= 0

OUT     := $(BUILD)/convergence
TOUT    := $(OUT)/tests
TESTLIB := $(REPO)/tools/testlib
TESTS   := $(wildcard acc_*.cob)

PKG_CONFIG := PKG_CONFIG_PATH=$(shell brew --prefix)/opt/openssl@3/lib/pkgconfig pkg-config
INCLUDES   := -I $(REPO)/contract/copy -I $(REPO)/client/copy -I $(REPO)/server/copy \
              -I $(REPO)/core/copy -I $(TESTLIB) -I $(CURDIR)
COBFLAGS   := -free -debug -std=default -fstatic-call $(INCLUDES)
ifeq ($(COVERAGE),1)
COBFLAGS += --coverage
endif

LIBS   := $(BUILD)/client/libclient.a $(BUILD)/server/libserver.a $(BUILD)/core/libcore.a \
          $(BUILD)/formats/libformats.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a
LDLIBS  = $(shell $(PKG_CONFIG) --libs glfw3 vulkan libssl libcrypto) -lz

HARNESS    := $(TOUT)/convharness.o
TESTASSERT := $(TOUT)/testassert.o
PROGRAMS   := $(patsubst %.cob,$(TOUT)/%,$(TESTS))
BINS       := $(OUT)/bin/cobolcraft $(OUT)/bin/cobolcraft-server
COPYBOOKS  := $(wildcard $(REPO)/contract/copy/*.cpy $(REPO)/client/copy/*.cpy $(REPO)/server/copy/*.cpy *.cpy)

.PHONY: lib tests lint
.DEFAULT_GOAL := tests

# Nothing of its own to archive: the packages' libraries are built by their own Makefiles.
lib:

tests: $(BINS) $(PROGRAMS)

lint:
	python3 $(REPO)/tools/lint.py $(INCLUDES) convharness.cob $(TESTS)

$(TESTASSERT): $(TESTLIB)/testassert.cob $(TESTLIB)/TESTLIB.cpy
	@mkdir -p $(dir $@)
	cobc -c $(COBFLAGS) -o $@ $<

$(HARNESS): convharness.cob $(COPYBOOKS)
	@mkdir -p $(dir $@)
	cobc -c $(COBFLAGS) -o $@ $<

$(TOUT)/%: %.cob $(HARNESS) $(TESTASSERT) $(LIBS) $(COPYBOOKS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -o $@ $< $(HARNESS) $(TESTASSERT) $(LIBS) $(LDLIBS)

$(OUT)/obj/%/main.o: $(REPO)/%/src/main.cob
	@mkdir -p $(dir $@)
	cd $(REPO)/$* && cobc -c -x $(COBFLAGS) -o $@ src/main.cob

$(OUT)/bin/cobolcraft: $(OUT)/obj/client/main.o $(LIBS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -o $@ $< $(BUILD)/client/libclient.a $(BUILD)/core/libcore.a \
	    $(BUILD)/formats/libformats.a $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a $(LDLIBS)

$(OUT)/bin/cobolcraft-server: $(OUT)/obj/server/main.o $(LIBS)
	@mkdir -p $(dir $@)
	cobc -x $(COBFLAGS) -o $@ $< $(BUILD)/server/libserver.a $(BUILD)/core/libcore.a \
	    $(BUILD)/proto/libproto.a $(BUILD)/shim/libccshim.a $(LDLIBS)
