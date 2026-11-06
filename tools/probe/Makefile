# Contract probes (make gate-contract; T076, T077). Test infrastructure, excluded from coverage.
# run: builds probe_contract.c against contract/include and probe_contract.cob against contract/copy
# (with the test library), runs both, and fails if a probe exits non-zero, prints no TEST line, or
# prints a FAIL line. Outputs go under $(BUILD)/probe/.

REPO    := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))../..)
BUILD   ?= $(REPO)/build
OUT     := $(BUILD)/probe
TESTLIB := $(REPO)/tools/testlib

COBFLAGS := -free -debug -std=default -fstatic-call -Wall -I $(REPO)/contract/copy -I $(TESTLIB)
CFLAGS   := -std=c11 -Wall -Wextra -Werror -I $(REPO)/contract/include -I $(TESTLIB)

PROBES := $(OUT)/probe_contract_c $(OUT)/probe_contract_cob

.PHONY: run
.DEFAULT_GOAL := run

run: $(PROBES)
	@status=0; \
	for probe in $(PROBES); do \
	    "$$probe" > "$$probe.out" 2>&1 || { echo "ERROR $$probe exited non-zero"; status=1; }; \
	    cat "$$probe.out"; \
	    grep -q '^TEST ' "$$probe.out" || { echo "ERROR $$probe printed no TEST line"; status=1; }; \
	    if grep -q '^TEST .* FAIL' "$$probe.out"; then status=1; fi; \
	done; \
	echo "probe: passed $$(cat $(addsuffix .out,$(PROBES)) | grep -c '^TEST .* PASS$$')" \
	     "failed $$(cat $(addsuffix .out,$(PROBES)) | grep -c '^TEST .* FAIL')"; \
	exit $$status

$(OUT)/probe_contract_c: probe_contract.c $(wildcard $(REPO)/contract/include/*.h) $(TESTLIB)/testlib.h
	@mkdir -p $(OUT)
	clang $(CFLAGS) -o $@ probe_contract.c

$(OUT)/probe_contract_cob: probe_contract.cob $(wildcard $(REPO)/contract/copy/*.cpy) $(TESTLIB)/TESTLIB.cpy $(TESTLIB)/testassert.cob
	@mkdir -p $(OUT)
	cobc -x $(COBFLAGS) -o $@ probe_contract.cob $(TESTLIB)/testassert.cob
