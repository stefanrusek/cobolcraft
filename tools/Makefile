# Package tools: test and build infrastructure (excluded from coverage; research R9).
# tests: implementation tests of the tools and the US1 acceptance tests; lint: the tools' Python
# and the test library sources.
.PHONY: tests lint

tests:
	python3 -m unittest discover -s tests -p 'test_*.py'
	python3 -m unittest discover -s tests -p 'acc_us1_*.py'

lint:
	python3 lint.py -I testlib $(wildcard *.py tests/*.py) testlib/testassert.cob testlib/testlib.h
