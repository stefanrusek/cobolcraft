# Package shim: thin C glue (constitution Principle I) → build/shim/libccshim.a
# (contracts/test-harness.md §2). Shared rules: tools/package.mk.
PKG      := shim
LIBNAME  := libccshim.a
SRC      := $(wildcard src/*.c)
TESTS    := $(wildcard tests/acc_*.c tests/contract_*.c tests/test_*.c)
INCLUDES :=
DEPLIBS  :=
LDLIBS   :=
LINT_FILES = $(SRC) $(TESTS) $(wildcard shaders/*.vert shaders/*.frag)

include ../tools/package.mk
