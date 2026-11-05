# Top-level commands (contracts/test-harness.md §1). Every output goes under build/.
#   make bootstrap       check prerequisites, create build/, compile shaders
#   make / make build    build/bin/cobolcraft and build/bin/cobolcraft-server
#   make test            build and run every package's test programs
#   make lint            lint every package
#   make coverage        instrumented test run, then fail on any never-executed production line
#   make gate            lint + build + coverage, plus the tools package's tests
#   make gate-<pkg>      the same scoped to shim, proto, core, server, client or tools
#   make gate-contract   wire fixtures parse, contract probes, lint of contract/
#   make clean           remove build/

PYTHON   := python3
BUILD    := $(CURDIR)/build
COVBUILD := $(BUILD)/coverage
PKGS     := shim proto core server client

# Packages each package links against, and each package's build targets.
DEPS_shim   :=
DEPS_proto  := shim
DEPS_core   := shim proto
DEPS_server := shim proto core
DEPS_client := shim proto core
TARGETS_shim   := lib
TARGETS_proto  := lib
TARGETS_core   := lib
TARGETS_server := lib bin
TARGETS_client := lib bin

.PHONY: build bootstrap test lint coverage gate gate-tools gate-contract clean $(addprefix gate-,$(PKGS))
.DEFAULT_GOAL := build

build:
	$(foreach p,$(PKGS),$(MAKE) -C $(p) $(TARGETS_$(p)) BUILD=$(BUILD) &&) true

bootstrap:
	sh tools/bootstrap.sh

test:
	$(PYTHON) tools/runtests.py --build $(BUILD) $(PKGS)

lint:
	status=0; $(foreach p,$(PKGS) tools,$(MAKE) -C $(p) lint || status=1;) exit $$status

coverage:
	if [ -d $(COVBUILD) ]; then find $(COVBUILD) -name '*.gcda' -delete; fi
	$(PYTHON) tools/runtests.py --coverage --build $(COVBUILD) $(PKGS)
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
	$$(PYTHON) tools/runtests.py --coverage --build $$(COVBUILD) $(1)
	$$(PYTHON) tools/coverage.py --build $$(COVBUILD) $(1)
endef
$(foreach p,$(PKGS),$(eval $(call GATE_RULE,$(p))))

# The tools package is excluded from coverage and compiles nothing: its gate is lint and tests.
gate-tools:
	$(MAKE) -C tools lint
	$(MAKE) -C tools tests

# Foundational gate: every wire fixture parses, every contract header and copybook compiles in a
# probe program (tools/probe, once it exists), and the contract headers lint.
gate-contract:
	$(PYTHON) tools/contract_check.py
	$(if $(wildcard tools/probe/Makefile),$(MAKE) -C tools/probe run BUILD=$(BUILD))
	$(PYTHON) tools/lint.py $(wildcard contract/include/*.h)

clean:
	rm -rf $(CURDIR)/build
