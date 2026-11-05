# CobolCraft

A block-building game client and game server written in COBOL, with a thin C layer for the
operating system, windowing, Vulkan graphics, networking and compression.

This document is for Contributors: how to build both programs and run their tests from a terminal.

## Supported platform

macOS on Apple silicon (arm64). This is the only platform the programs are built and tested on for
now; Linux, Windows and Android are follow-up platforms.

## Prerequisites

Install the Xcode command line tools (for `clang` and `gcov`) and [Homebrew](https://brew.sh), then
the rest with one command:

```sh
xcode-select --install
brew install gnucobol glfw molten-vk vulkan-loader vulkan-headers glslang openssl@3 pkg-config
```

| Tool | Used for |
|---|---|
| GnuCOBOL 3.2 (`cobc`) | All game code |
| Apple clang | The C layer, and the C compiler `cobc` drives |
| GLFW 3.4 or later | Window and input |
| Vulkan loader and headers, MoltenVK | Graphics (MoltenVK runs Vulkan over Metal) |
| glslang (`glslangValidator`, `spirv-val`) | Compiling and checking the shaders |
| OpenSSL 3 (`openssl@3`) | SHA-1, MD5 and HTTPS. The build uses OpenSSL 3 even when a newer OpenSSL is also installed. |
| zlib (part of macOS) | Compression |
| Python 3 | Test runner, coverage and lint drivers (standard library only) |
| gcov (part of the command line tools) | Line coverage |

## Commands

Run every command from the repository root.

| Command | What it does |
|---|---|
| `make bootstrap` | Checks every prerequisite above. If one is missing it names it, prints the install line and exits 1. Otherwise it creates `build/` and compiles the shaders. Run it once after cloning. |
| `make` | Builds the client `build/bin/cobolcraft` and the server `build/bin/cobolcraft-server`. |
| `make test` | Builds and runs the tests of every package, then prints the counts of passed and failed cases. |
| `make lint` | Checks every COBOL, C, shader and Python source. |
| `make coverage` | Runs the tests with coverage instrumentation, then fails if any line of production code was never executed. |
| `make gate` | `make lint`, `make`, `make coverage` and the tests of the build tools. Run it before you commit. |
| `make gate-<package>` | The same for one package: `shim`, `proto`, `core`, `server`, `client` or `tools`. |
| `make gate-contract` | Checks the shared interface definitions in `contract/`: every wire fixture parses, every header and copybook compiles, and they lint. |
| `make clean` | Removes `build/`. |

A fresh checkout goes:

```sh
make bootstrap
make
make test
```

## Reading test output

`make test` prints one line for every failing test case and ends with the totals:

```text
FAIL acceptance US4-2 given a held block when place on a face then block appears expected=12 observed=0
passed 341 failed 1
```

Each `FAIL` line names the case, then what the test expected and what it observed. A test program
that crashes counts as one failure named after the program (for example
`FAIL core/tests/test_world expected=exit 0 observed=signal 11`), followed by its error output.
The command exits 0 only when nothing failed.

`make coverage` prints one `UNCOVERED <file>:<line>` line for every production line no test
executed. Production code is everything under `shim/src`, `proto/src`, `core/src`, `core/copy`,
`server/src` and `client/src`; tests, `tools/` and `specs/` are not counted.

## Repository layout

| Directory | Contents |
|---|---|
| `shim/` | The C layer, built into `build/shim/libccshim.a`; shaders in `shim/shaders/` |
| `proto/` | The network protocol codec (COBOL), `build/proto/libproto.a` |
| `core/` | The game itself (COBOL), shared by server and client, `build/core/libcore.a` |
| `server/` | The server program |
| `client/` | The client program |
| `contract/` | Shared interface definitions: C header, COBOL copybooks, wire fixtures |
| `tools/` | Build and test tooling: test runner, coverage, lint, bootstrap, test libraries |
| `docs/` | Protocol and game design documents |

Every package has its own `Makefile` with the targets `lib`, `tests` and `lint` (and `bin` for
`server` and `client`), and its tests in `<package>/tests/`.

## Writing tests

A test is a program in `<package>/tests/` named `acc_<story>_<topic>` (acceptance test),
`contract_<seam>_<side>` (contract test) or `test_<unit>` (implementation test), with `.cob` or, in
`shim/`, `.c`. Each case prints one line, `TEST <case> PASS` or
`TEST <case> FAIL expected=<x> observed=<y>`:

- COBOL: `COPY TESTLIB.` in working storage, fill `TL-CASE`, set `TL-TEXT` or `TL-NUMBER`, fill
  `TL-EXPECTED`/`TL-OBSERVED` (text) or `TL-EXPECTED-N`/`TL-OBSERVED-N` (numbers), then
  `CALL "TEST-ASSERT" USING TESTLIB-ASSERT` (`tools/testlib/TESTLIB.cpy`).
- C: `#include "testlib.h"` and call `tl_int`, `tl_str` or `tl_bytes` (`tools/testlib/testlib.h`).

Test programs run from the repository root. A file `<test>.stdin` next to a test source is fed to it
as standard input. A file `<test>.expect` turns the program into one case that passes when the
program exits with the status on its first line and, if there is a second line, its error output
contains that text.

## Where outputs go

Everything the build writes is under `build/`: the programs in `build/bin/`, compiled shaders in
`build/shaders/`, each package's objects and library in `build/<package>/` and its test programs in
`build/<package>/tests/`. The coverage build is kept apart in `build/coverage/`.
