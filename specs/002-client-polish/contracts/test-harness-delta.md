# Contract: build and test commands, additions (`tools` <-> every package, and <-> Contributor)

**Status**: frozen at plan time; amends `specs/001-cobolcraft-complete/contracts/test-harness.md`.

| Command | Addition |
|---|---|
| `make` / `make build` | also builds `build/bin/cobolcraft-extract` and the libraries of `formats`, `content`, `extract`. `PKGS` becomes `shim formats proto content extract core server client`; `DEPS_` and `TARGETS_` per plan "Project structure". |
| `make gate-<pkg>` | exists for `formats`, `content` and `extract` too (same recipe as every package: lint, dependencies' libs, build, instrumented tests, coverage of the package's production sources). |
| `make gate-tables` | `python3 tools/gen/gen_tables.py --check`: regenerate the registry copybooks into a scratch directory, fail on any byte difference with `content/copy/gen/`, and fail when a generated count differs from the count the documents state (data-model §2). Part of `make gate-tools` and `make gate-contract`. |
| `make gate-contract` | also compiles the new contract copybooks (`CONTENT.cpy`, `FORMATS.cpy`) in the probe program and parses every new wire fixture. |
| `make gate` | lint + build + coverage + `gate-tools` as today; coverage excludes `content/copy/gen/` (generated, constitution 4.2) and nothing else new. |
| `tools/runtests.py` | `PACKAGES` and `DEPENDENCIES` gain the new packages in dependency order; tests named `acc_`, `contract_`, `test_` as today. |
| Test inputs | `tmp/minecraft-26.3-client.jar` and `tmp/Faithful 32x - 26.3.zip` (git-ignored, the operator's inputs). A test that needs one and does not find it FAILS with the path in its message; no test skips (constitution 4.1). `COBOLCRAFT_INPUTS` may point at another folder holding both files. |
| `make bootstrap` | also creates `build/generated-test/`, the scratch space of tests that run the extraction tool. No new prerequisite is installed or checked. |
