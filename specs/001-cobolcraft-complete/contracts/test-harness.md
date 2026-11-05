# Contract: build and test commands (`tools` ↔ every package, and ↔ Contributor)

**Status**: frozen at plan time. This is the Contributor's vantage (US1) and the interface every package's
build must offer to the top-level commands.

## 1. Top-level commands (repository root)

| Command | Effect |
|---|---|
| `make bootstrap` | Checks every prerequisite of research R1 is installed (prints the missing ones and the `brew install` line, exit 1), then creates the `build/` directories and compiles the GLSL shaders to SPIR-V. It starts no shared test infrastructure. This is the constitution's workspace bootstrap command (Development Workflow; SDD 5.2). |
| `make` / `make build` | Builds `build/bin/cobolcraft` (client) and `build/bin/cobolcraft-server` (US1-1). |
| `make test` | Builds and runs every test program of every package; prints failing cases with expected and observed values and `passed <n> failed <m>`; exit 0 only if `m` = 0 and every test program exited 0 (US1-2, US1-3). |
| `make lint` | Lint of research R9 over every package. |
| `make coverage` | `make test` with coverage instrumentation, then fails on any never-executed production line, listing `file:line`. |
| `make gate` | lint + build + coverage (which includes the tests): the terminal and Convergence aggregate gate. |
| `make gate-<pkg>` | The same, scoped to one package (`shim`, `proto`, `core`, `server`, `client`, `tools`): the lane-phase gate. `make gate-contract` compiles every `contract/` header and copybook in a probe program, checks every wire fixture parses, and lints them (Foundational gate). |
| `make clean` | Removes `build/`. |

All outputs go under `build/` (`build/<pkg>/obj`, `build/<pkg>/tests`, `build/bin`, `build/shaders`).

## 2. Per-package build interface

Each package directory has a `Makefile` with targets `lib` (or `bin`), `tests`, `lint`, and variables
`SRC` (production sources, the coverage set) and `TESTS` (test programs). Top-level targets call them; a
package never builds another package's sources, it links the other package's `lib` output.

## 3. Test program output protocol

One line per test case on standard output, nothing else on lines starting with `TEST `:

```text
TEST <case name> PASS
TEST <case name> FAIL expected=<value> observed=<value>
```

Test programs exit 0 when they ran to the end (even with failed cases) and non-zero only on a crash; the
runner counts a crash as one failure named after the test program. Case names: see research R9.
