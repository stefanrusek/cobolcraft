# Package tools: test and build infrastructure (excluded from coverage; research R9).
# tests: implementation tests of the tools and the US1 acceptance tests; lint: the tools' Python,
# the test library sources, the contract probes (probe/) and the test server (testsrv/).
.PHONY: tests lint

tests:
	python3 -m unittest discover -s tests -p 'test_*.py'
	python3 -m unittest discover -s tests -p 'acc_us1_*.py'
	python3 -m unittest discover -s tests -p 'acc_f2us1_*.py'

lint:
	python3 lint.py -I testlib $(wildcard *.py gen/*.py tests/*.py testsrv/*.py) testlib/testassert.cob testlib/testinput.cob testlib/testlib.h \
	    probe/probe_contract.c probe/probe_contract.cob
