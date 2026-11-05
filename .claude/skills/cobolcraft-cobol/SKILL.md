---
name: cobolcraft-cobol
description: CobolCraft's GnuCOBOL conventions and known compiler/coverage pitfalls. Use whenever writing, editing, reviewing or debugging COBOL (.cob, .cpy) or package Makefiles in this repository — proto, core, server, client, tools/testlib or contract/copy — including speckit-implement phases, test programs and coverage fixes.
---

# CobolCraft COBOL conventions

Apply these to every COBOL source and test in this repo. They come from the constitution (v1.2.0),
`specs/001-cobolcraft-complete/tasks.md` "Conventions every task inherits", and pitfalls found while
implementing. If this file and tasks.md disagree, tasks.md and the constitution win; fix this file.

## Language and build

- GnuCOBOL 3.2, **free format**. Every build uses `-free -debug -std=default -fstatic-call`
  (`tools/package.mk`). Comments are `*>`.
- `-fstatic-call` is required: without it a `CALL "X"` does not pull program X out of a package `.a`.
- Calls to C use `CALL STATIC` (research R2). COBOL may call any C library directly; C glue
  (`shim/`) exists only where a call can't be expressed cleanly (callbacks, struct layouts, variadics),
  and contains no game or protocol logic (constitution Principle I).
- Shared record shapes come only from `contract/copy/*.cpy` (`PROTO`, `COREAPI`, `CCSHIM`, …). Never
  redefine them locally. Package-private copybooks live in `<pkg>/copy/`.
- Package Makefiles only set `PKG`, `LIBNAME`, `SRC`, `TESTS`, `INCLUDES`, `DEPLIBS`, `LDLIBS` and include
  `tools/package.mk`. `src/main.cob` is a single `CALL` into a library entry point and is kept out of the
  library.
- Any package that links proto frame or NBT-file code must link `-lz`.

## Program structure (coverage-driven)

- 100 % line coverage is a gate (constitution 4.2). Generated code and test infrastructure are the only
  exclusions.
- **Keep production logic inline.** Trailing performed paragraphs make gcov report the `END PROGRAM`
  line as uncovered. Prefer several small programs (one `PROGRAM-ID` each) to paragraphs.
- Write a failure branch on its own line(s), so coverage actually shows whether it ran.
- Several programs may share one source file (`END PROGRAM` after each). Under `-Wall`, calls between
  programs in one file are size-checked: the argument sizes must match.

## GnuCOBOL pitfalls

- **LINKAGE size under `-debug`:** a LINKAGE item longer than the caller's argument aborts at run time.
  For caller areas of variable size, declare a one-byte `PIC X` LINKAGE item and read it through a
  `BASED` view (see `proto/src/buffer.cob`).
- **64-bit literal arithmetic:** constant expressions overflow silently (`2 ** 64` is 0). Put large
  constants in `VALUE` clauses.
- **High-byte hex literals:** `X"…"` with bytes ≥ 0x80 makes clang warn; build such bytes another way
  (e.g. `FUNCTION CHAR`, or a `VALUE` in a binary field).
- **BY REFERENCE aliasing:** a caller may pass a field the callee itself changes (for example
  `PLAYER-LEAVE USING CN-PLAYER(id)`, which zeroes `CN-PLAYER`). Copy such LINKAGE arguments into
  WORKING-STORAGE before changing shared state.
- **`-Wall` size checks between programs of one file** only see programs defined *earlier* in the
  file; put a program that takes a one-byte `PIC X` area after its callers.
- **`FUNCTION SIN`/`COS` are slow** (about 90 µs a call): remember results that repeat (worldgen).
- **Shifting a large buffer byte by byte is quadratic**: keep a read offset (`PB-POS`) instead of
  moving the rest to the front after every partial read.
- **Core state** is the EXTERNAL records of `core/copy/CORESTATE.cpy`; PB-BUFFERs are kept there as
  their raw 21 bytes and moved into a local `PB-BUFFER` to use them.
- **No `C$LIST-DIRECTORY`** in GnuCOBOL 3.2: use `cc_fs_list` (contracts/shim-abi.md §7).
- **Reserved words as paragraph names** (`MOVE`, `SEPARATE`, …) fail with "unexpected PERFORM"
  far from the cause: give test paragraphs verb-noun names (`DO-MOVE`, `ADD-SPACE`).
- **Nested subscripts with arithmetic inside an intrinsic's arguments** can be miscompiled:
  `FUNCTION MIN(C(R, F), MX(I(R, T) + 1) - C(R, T))` yields a wrong value with no warning. Move the
  inner subscript or the difference into a field first, then call the function.
- **`PERFORM VARYING … FROM a - b`** is a syntax error: compute the start into a field first.
- **The same item twice in one `CALL … USING`** warns under `-Wall` (`-Werror` in lint): pass
  distinct fields (e.g. three zero fields for a zero vector).
- **Float edges**: `x + 0.35` is not exact; compare cell faces with a small tolerance (movement.cob
  uses 1e-7) so that touching faces do not count as overlaps.
- **MOVE of a float to a numeric-edited item truncates** (100.215 shows as 100.21499): use
  `COMPUTE edited ROUNDED = float` when a test prints a float.
- **OCCURS is not allowed at level 01**: wrap a table in a 01 group (`01 WS-ORDERS. 05 WS-ORDER
  ... OCCURS n TIMES.`).
- **Fixed format breaks past column 72**, which is why the project is free format. Don't switch.

## Interfaces

- C layer: `specs/001-cobolcraft-complete/contracts/shim-abi.md`, including recorded edge behaviour of
  `cc_con_readline`, `cc_fs_list` and `cc_net_local_addresses`.
- Protocol codec: `contracts/proto-api.md`, with entry-point parameters and conventions in **§5**:
  - A failed read leaves `PB-POS` unchanged, and `PB-ERROR` stays set until `PB-RESET`.
  - NBT writer name length: ≥ 0 named tag, −1 list element, −2 network root.
- Protocol facts come only from `docs/protocol/` (Principle II), plus `09-cobolcraft-profile.md`. Never
  read the shipped jar. Content values (ids, numbers, names, texts) are transcribed from
  `docs/design/standin-content.md`, never invented in code.

## Tests

- Test files follow these patterns:
  - `acc_<story>_<topic>` for acceptance tests. Case names contain `acceptance US<n>-<scenario>` and Given/When/Then.
  - `contract_<seam>_<side>` for contract tests.
  - `test_<unit>` for implementation tests.
- Tests are written before the code they test (constitution 4.1), and use no test doubles: real sockets, GPU, window and zlib.
- Use `tools/testlib/` (`COPY TESTLIB.`, set `TL-CASE`, `TL-EXPECTED`/`TL-OBSERVED` or the `-N`
  numeric forms with `TL-MODE "N"`, then `CALL "TEST-ASSERT" USING TESTLIB-ASSERT`). One output line per
  case: `TEST <case> PASS` / `TEST <case> FAIL expected=<x> observed=<y>`.
- Tests run from the repository root, so open fixtures as `contract/fixtures/wire/<name>.hex`.
- `<test>.stdin` feeds standard input. `<test>.expect` holds the expected exit status on line 1, and
  optionally on line 2 text that stderr must contain.
- Core test helpers live in `core/tests/CORETEST.cpy` (COPY it after the test program):
  `TEST-JOIN` (a memory connection that logs in, configures and loads), `TEST-MOVE`,
  `TEST-ACCEPT-TELEPORT`, `TEST-DRAIN-IDS` (packet ids as `<id>x<n>` runs), `TEST-USE-ON`,
  `TEST-ACTION`, `TEST-HELD`, `TEST-CLICK`, `TEST-TICKS`, `TEST-DRAIN-BLOCKS` (block, ack, slot and
  light packets with their fields; Set Time left out), `TEST-BLOCK-AT`, `TEST-CHAT` (feeds unsigned
  Chat), `TEST-DRAIN-CHAT` (System Chat texts, `|`-separated), `TEST-ATTACK`, `TEST-CLIENT-COMMAND`,
  `TEST-DRAIN-HEALTH` (Set Health, Damage Event, Hurt Animation, Player Combat Kill, System Chat,
  Respawn and Player Position, `|`-separated), fixture loading and
  comparison. Test copybooks are not make dependencies: touch the test or delete
  `build/coverage/core` after changing one.
- Coverage fixtures are named `*.gcov.txt` (`*.gcov` is gitignored).

## Failure handling (FR-012)

- A non-fatal failure prints one `ERROR <what>: <detail>` console line and processing continues.
- A fatal failure does `CALL STATIC "cc_fatal"` with `"<what>: <detail>"`, which prints `FATAL <what>: <detail>` and exits.
- Nothing else: no retries, dialogs or extra recovery (constitution 5.5, 5.6).

## Gates

- Each package has a gate: `make gate-<pkg>` (shim, proto, core, server, client), `make gate-contract` and
  `make gate-tools`, plus `make gate` for everything. A gate runs lint, the tests and coverage.
- Check a command's exit status directly, not through a pipe.
