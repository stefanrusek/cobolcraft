## Phase 1: Setup (shared infrastructure)

**Purpose**: Makefile, runner, generator skeleton and test-input convention so every later phase can gate its
package. **Gate**: `make gate-tools`.

- [x] T0001 Add `generated/` to `.gitignore` at the repository root (SC-012: no generated or jar file is ever committed)
- [x] T0002 Write implementation test cases in `tools/tests/test_runtests.py` expecting `PACKAGES` and `DEPENDENCIES` of `tools/runtests.py` to contain `formats`, `content`, `extract` in the one canonical order `shim, formats, proto, content, extract, core, server, client` (extract depends on shim, proto, formats and content, so it follows content)
- [x] T0003 Extend `PACKAGES` and `DEPENDENCIES` in `tools/runtests.py` with `formats`, `content`, `extract` so the test of the previous task passes
- [x] T0004 Write acceptance test `tools/tests/acc_f2us1_gate_targets.py` asserting `make -n gate-formats gate-content gate-extract gate-tables` resolves each target and that `make -n build` names `build/bin/cobolcraft-extract` (contracts/test-harness-delta.md)
- [x] T0005 Extend the root `Makefile`: `PKGS := shim formats proto content extract core server client`, `DEPS_` and `TARGETS_` per package (`DEPS_formats := shim`; `DEPS_content := shim proto formats`; `DEPS_extract := shim proto formats content` because extract reads the accepted-jar table and `CONTENT-PACKS-CHECK` from content; `TARGETS_extract := lib bin`), `gate-<pkg>` for the new packages and a `gate-tables` target running `python3 tools/gen/gen_tables.py --check`, and make `gate-tools` and `gate-contract` depend on `gate-tables`
- [x] T0006 [P] Create `formats/Makefile` including `tools/package.mk` with `PKG := formats`, `LIBNAME := libformats.a` and empty `SRC` and `TESTS` lists, and the directories `formats/src`, `formats/tests`, `formats/copy` (skeleton; `make gate-formats` exits 0 on the empty package)
- [x] T0007 [P] Create `content/Makefile` including `tools/package.mk` with `PKG := content`, `LIBNAME := libcontent.a`, empty `SRC` and `TESTS` lists, `INCLUDES` of `content/copy` and `content/copy/gen`, and the directories `content/src`, `content/tests`, `content/copy`, `content/copy/gen`
- [x] T0008 [P] Create `extract/Makefile` including `tools/package.mk` with `PKG := extract`, `LIBNAME := libextract.a`, `TARGETS lib bin` producing `build/bin/cobolcraft-extract` from `src/main.cob`, empty `SRC` and `TESTS` lists, and the directories `extract/src`, `extract/tests`
- [x] T0009 Exclude `content/copy/gen/` (generated data, constitution 4.2) from the production set in `tools/coverage.py` and write the matching case in `tools/tests/test_coverage.py` first
- [x] T0010 Write acceptance test `tools/tests/acc_f2us1_gen_cli.py`: `python3 tools/gen/gen_tables.py --check` exits 0 on an empty table set and exits 1 naming the file when a generated file differs by one byte (drift gate, contracts/test-harness-delta.md)
- [x] T0011 Create `tools/gen/gen_tables.py` skeleton with `--check` (regenerate into a scratch directory, compare byte for byte with `content/copy/gen/`) and `--write`, no tables yet
- [x] T0012 Write implementation test `tools/tests/test_inputs.py` for the real-input convention: a COBOL test helper `TEST-INPUT-PATH` returns `$COBOLCRAFT_INPUTS/<name>` when the variable is set, else `tmp/<name>`, and a missing file makes the calling test print `TEST <case> FAIL expected=file observed=missing <path>` and exit non-zero (contracts/test-harness-delta.md "Test inputs")
- [x] T0013 Create program `TEST-INPUT-PATH` in `tools/testlib/testinput.cob` (path resolution and the loud failure) satisfying the previous test
- [x] T0014 Write acceptance test case in `tools/tests/test_bootstrap.py` expecting `sh tools/bootstrap.sh` to create `build/generated-test/` and to list `formats content extract` in its package list
- [x] T0015 Update `tools/bootstrap.sh` (package list, creation of `build/generated-test/`) so the previous test passes
- [x] T0016 Gate: run `make gate-tools` from the repository root and record the command and its real output (exit 0)

**Checkpoint**: every package has a Makefile and a gate target; the generator drift gate exists.

---
