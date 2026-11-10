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
#   make contract-wire   generated contract tests of the wire seams only (intermediate: no coverage, never a gate)
#   make contract-play   generated contract tests of the play to core hooks (intermediate, as contract-wire)
#   make contract-content   generated contract tests of the content to core recipes seam (intermediate)
#   make contract-affected   the seams whose paths changed against BASE (default HEAD) and untracked files
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
DEPS_core   := shim proto formats content
DEPS_server := shim formats proto content core
DEPS_client := shim formats proto content core
TARGETS_shim   := lib
TARGETS_formats := lib
TARGETS_proto  := lib
TARGETS_content := lib
TARGETS_extract := lib bin
TARGETS_core   := lib
TARGETS_server := lib bin
TARGETS_client := lib bin

.PHONY: build bootstrap test lint coverage gate gate-tools gate-contract gate-tables clean contract-wire contract-play contract-content contract-affected $(addprefix gate-,$(PKGS))
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
	$(PYTHON) tools/gen/gen_contract.py --check

# Scoped contract runs (contract/cases/README.md). They run the generated contract programs of a seam
# group through runtests.py --only, so they build only those programs and their libraries, and they skip
# tools/coverage.py: a subset run would report false gaps. The full gates stay the terminal check.
# A new seam group is one more target like contract-wire (its table name prefix after --only-args).
contract-wire:
	$(PYTHON) tools/gen/gen_contract.py --check
	$(PYTHON) tools/runtests.py --build $(BUILD) $(shell $(PYTHON) tools/gen/gen_contract.py --only-args wire)

contract-play:
	$(PYTHON) tools/gen/gen_contract.py --check
	$(PYTHON) tools/runtests.py --build $(BUILD) $(shell $(PYTHON) tools/gen/gen_contract.py --only-args play)

contract-content:
	$(PYTHON) tools/gen/gen_contract.py --check
	$(PYTHON) tools/runtests.py --build $(BUILD) $(shell $(PYTHON) tools/gen/gen_contract.py --only-args content)

BASE ?= HEAD
AFFECTED_ARGS = $(shell $(PYTHON) tools/gen/gen_contract.py --affected-args --base $(BASE))
contract-affected:
	$(PYTHON) tools/gen/gen_contract.py --check
	$(if $(AFFECTED_ARGS),$(PYTHON) tools/runtests.py --build $(BUILD) $(AFFECTED_ARGS),@echo "contract-affected: no seam affected by the changes against $(BASE)")

# Foundational gate: every wire fixture parses, every contract header and copybook compiles in a
# probe program (tools/probe, once it exists), and the contract headers lint.
gate-contract: gate-tables
	$(PYTHON) tools/contract_check.py
	$(if $(wildcard tools/probe/Makefile),$(MAKE) -C tools/probe run BUILD=$(BUILD))
	$(PYTHON) tools/lint.py $(wildcard contract/include/*.h)

clean:
	rm -rf $(CURDIR)/build
