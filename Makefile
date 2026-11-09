# Top-level commands (contracts/test-harness.md §1). Every output goes under build/.
#   make bootstrap       check prerequisites, create build/, compile shaders
#   make / make build    build/bin/cobolcraft and build/bin/cobolcraft-server
#   make test            build and run every package's test programs, then the Convergence tests
#                        (tests/convergence: cross-package acceptance tests)
#   make lint            lint every package
#   make coverage        instrumented test run, then fail on any never-executed production line
#   make gate            lint + build + coverage (with the Convergence tests), plus the tools package's tests
#   make gate-<pkg>      the same scoped to shim, formats, proto, content, extract, core, server, client or tools
#   make gate-tables     generated registry copybooks match the generator (tools/gen/gen_tables.py --check)
#   make gate-contract   wire fixtures parse, contract probes, lint of contract/
#   make clean           remove build/

PYTHON   := python3
BUILD    := $(CURDIR)/build
COVBUILD := $(BUILD)/coverage
PKGS     := shim formats proto content extract core server client

# Packages each package links against, and each package's build targets.
DEPS_shim   :=
DEPS_formats := shim
DEPS_proto  := shim
DEPS_content := shim proto formats
DEPS_extract := shim proto formats content
DEPS_core   := shim proto
DEPS_server := shim proto core
DEPS_client := shim proto core
TARGETS_shim   := lib
TARGETS_formats := lib
TARGETS_proto  := lib
TARGETS_content := lib
TARGETS_extract := lib bin
TARGETS_core   := lib
TARGETS_server := lib bin
TARGETS_client := lib bin

.PHONY: build bootstrap test lint coverage gate gate-tools gate-contract gate-tables clean $(addprefix gate-,$(PKGS))
.DEFAULT_GOAL := build

build:
	$(foreach p,$(PKGS),$(MAKE) -C $(p) $(TARGETS_$(p)) BUILD=$(BUILD) &&) true

bootstrap:
	sh tools/bootstrap.sh

test:
	$(PYTHON) tools/runtests.py --build $(BUILD) $(PKGS) convergence

lint:
	status=0; $(foreach p,$(PKGS) tools tests/convergence,$(MAKE) -C $(p) lint || status=1;) exit $$status

# The Convergence tests run with the packages' instrumented libraries, so their lines count too;
# they also run the instrumented programs (whose src/main.cob objects live under
# $(COVBUILD)/convergence/obj).
# An instrumented test program also writes its own .gcda into the package folder it ran from; a stale
# one makes the forked children of a changed test print gcov merge errors, so both are cleared.
coverage:
	if [ -d $(COVBUILD) ]; then find $(COVBUILD) -name '*.gcda' -delete; fi
	find $(PKGS) tests/convergence -maxdepth 1 -name '*.gcda' -delete
	$(PYTHON) tools/runtests.py --coverage --build $(COVBUILD) $(PKGS) convergence
	$(PYTHON) tools/coverage.py --build $(COVBUILD) $(PKGS)

gate:
	$(MAKE) lint
	$(MAKE) build
	$(MAKE) coverage
	$(MAKE) -C tools tests

# gate-<pkg>: lint, build (the dependencies' libraries, then the package), instrumented tests,
# coverage of the package's production sources.
define GATE_RULE
gate-$(1):
	$$(MAKE) -C $(1) lint
	$$(foreach d,$$(DEPS_$(1)),$$(MAKE) -C $$(d) lib BUILD=$$(BUILD) &&) true
	$$(MAKE) -C $(1) $$(TARGETS_$(1)) BUILD=$$(BUILD)
	if [ -d $$(COVBUILD)/$(1) ]; then find $$(COVBUILD)/$(1) -name '*.gcda' -delete; fi
	find $(1) -maxdepth 1 -name '*.gcda' -delete
	$$(PYTHON) tools/runtests.py --coverage --build $$(COVBUILD) $(1)
	$$(PYTHON) tools/coverage.py --build $$(COVBUILD) $(1)
endef
$(foreach p,$(PKGS),$(eval $(call GATE_RULE,$(p))))

# The tools package is excluded from coverage and compiles nothing: its gate is lint and tests.
gate-tools: gate-tables
	$(MAKE) -C tools lint
	$(MAKE) -C tools tests

# The generated registry copybooks under content/copy/gen/ equal a fresh regeneration (drift gate).
gate-tables:
	$(PYTHON) tools/gen/gen_tables.py --check

# Foundational gate: every wire fixture parses, every contract header and copybook compiles in a
# probe program (tools/probe, once it exists), and the contract headers lint.
gate-contract: gate-tables
	$(PYTHON) tools/contract_check.py
	$(if $(wildcard tools/probe/Makefile),$(MAKE) -C tools/probe run BUILD=$(BUILD))
	$(PYTHON) tools/lint.py $(wildcard contract/include/*.h)

clean:
	rm -rf $(CURDIR)/build
