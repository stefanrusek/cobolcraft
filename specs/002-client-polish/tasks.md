---
description: "Task list for Client polish: visuals, controls and missing gameplay"
---

# Tasks: Client polish: visuals, controls and missing gameplay

**Input**: Design documents from `specs/002-client-polish/` — [plan.md](plan.md), [spec.md](spec.md),
[research.md](research.md) (R1 to R16), [data-model.md](data-model.md), [contracts/](contracts/),
[quickstart.md](quickstart.md), [spikes/](spikes/); constitution `.specify/memory/constitution.md` (project
Principles I and II with SDD amendment v6.3.0); personas `.specify/memory/personas.md`.

**Prerequisites**: plan.md and spec.md (required); research, data-model and all eight contracts are binding
inputs. **Tasks gate (constitution 1.3)**: the mechanical grep for the clarification-marker token (constitution 1.3) over `specs/002-client-polish`, `docs/`
and `.specify/memory` found no marker on 2026-11-09. The plan's two
open decisions are recorded: Q-1 (the operator accepted a recorded manual run of a vanilla client as the
verification of SC-013, plus automated byte-level conformance tests) and Q-2 (the operator sanctioned the
Open Pack Folder test double: the client state names the opener program, production sets `/usr/bin/open`, tests
set `/usr/bin/true`). Both are inherited knowingly; see US4 and the Convergence phase.

**Tests**: REQUIRED. Constitution 4.1 makes test-first development, acceptance tests for every acceptance
scenario, contract tests for both sides of every seam and 100 % production coverage (4.2) mandatory. Each test
task precedes the implementation task it defines (constitution 5.1 rule 3). The only test double is the Q-2
opener; E2E inventory is empty (plan "E2E inventory"), so no `.feature` files, step definitions or E2E runs
exist. Document deliverables (clean-room rounds, design records, README) are verified by review tasks (4.1).

**Execution mode**: **package-parallel** (plan "Execution mode"; constitution 3.6, 5.2). Shape: Setup →
Foundational (docs-first rounds, contract materialization, generator, move of the shared readers) → PARALLEL
GROUP with lanes `shim`, `formats`, `proto`, `content`, `extract`, `core`, `server`, `client` → Convergence →
Polish. Workspace bootstrap command: `make bootstrap`. Executed strictly sequentially the lane order is the
plan's: `shim`, `formats`, `proto`, `content`, `extract`, `core`, `server`, `client`.

## Format: `- [ ] [ID] [P?] [Story?] Description`

- **[P]**: can run in parallel with the other [P] tasks next to it (different files, no dependency on an
  incomplete task).
- **[Story]**: none in Setup, Foundational and Polish; composite lane tags `[US<n>-<package>]` in the parallel
  group (constitution 5.2: a split story's slices never carry the bare tag); bare `[US<n>]` in Convergence.
- **Gate:** tasks are verification-only (effective size 0, constitution 5.1 rule 1); every other task is one
  independently verifiable change (effective size 1). Every phase ends with one `Gate:` task whose evidence is
  the real command output captured at run time (constitution 5.4).

## Conventions every task inherits

- COBOL: GnuCOBOL 3.2, free format, `-std=default`, `-debug`, comments `*>`; calls to C with `CALL STATIC`;
  shared shapes only from `contract/copy/*.cpy`, never redefined locally. Read `.claude/skills/cobolcraft-cobol/SKILL.md`
  before writing COBOL or a package Makefile, and keep it in sync with new pitfalls found.
- C (shim only): C11, glue only, no game or protocol logic (Principle I; `contracts/shim-delta.md`).
- Test names: `acc_f2us<N>_<slug>` (acceptance; case names contain `acceptance US<n>-<scenario>` and
  Given/When/Then), `contract_<seam>_<side>`, `test_<unit>`; one output line per case through `tools/testlib/`.
  "Implementation test ... to 100 % coverage" tasks cover every line of the named production file that the
  acceptance and contract tests of the same phase leave unexecuted (constitution 4.2; `make coverage` lists them).
  No coverage-ignore, lint-disable or skipped test is ever added (5.4).
- Behaviour values (ids, numbers, texts, formulas) are never invented in code: they are read from the document
  each task cites (`docs/protocol/` or `docs/design/`, Principle II, FR-042). A value a document lacks stops that
  slice: record the gap in the phase's evidence and return to the orchestrator for a clean-room round; lanes never
  edit `docs/`, `contract/` or `specs/` (they read the contracts; constitution 5.2).
- Real-input tests (extraction tool, pack loader against the real Faithful zip) read `tmp/minecraft-26.3-client.jar`
  and `tmp/Faithful 32x - 26.3.zip` (or `COBOLCRAFT_INPUTS`) and FAIL loudly with the path when absent. No skips.
- Failure handling: only the defined outcomes of plan "Error handling" (CCX codes of 22 §7.4, packs status words,
  pack errors of 08, the WT-23 foreign-key case, options defaults); everything else stays fatal under `-debug`.
- Test-first inside every phase; effective size 1 per task; a commit is made at every phase boundary after its
  Gate passes (constitution 5.3). Tasks in a lane name only files under that lane's package directory
  (`shim/`, `formats/`, `proto/`, `content/`, `extract/`, `core/`, `server/`, `client/`) as targets.
- Sources that grow past what an engineer tolerates are split by concern while being rewritten (plan "Technical debt
  survey"); a new program lives in its own source file named after the concern.

---

## Phase 1: Setup (shared infrastructure)

**Purpose**: Makefile, runner, generator skeleton and test-input convention so every later phase can gate its
package. **Gate**: `make gate-tools`.

- [ ] T0001 Add `generated/` to `.gitignore` at the repository root (SC-012: no generated or jar file is ever committed)
- [ ] T0002 Write implementation test cases in `tools/tests/test_runtests.py` expecting `PACKAGES` and `DEPENDENCIES` of `tools/runtests.py` to contain `formats`, `content`, `extract` in the one canonical order `shim, formats, proto, content, extract, core, server, client` (extract depends on shim, proto, formats and content, so it follows content)
- [ ] T0003 Extend `PACKAGES` and `DEPENDENCIES` in `tools/runtests.py` with `formats`, `content`, `extract` so the test of the previous task passes
- [ ] T0004 Write acceptance test `tools/tests/acc_f2us1_gate_targets.py` asserting `make -n gate-formats gate-content gate-extract gate-tables` resolves each target and that `make -n build` names `build/bin/cobolcraft-extract` (contracts/test-harness-delta.md)
- [ ] T0005 Extend the root `Makefile`: `PKGS := shim formats proto content extract core server client`, `DEPS_` and `TARGETS_` per package (`DEPS_formats := shim`; `DEPS_content := shim proto formats`; `DEPS_extract := shim proto formats content` because extract reads the accepted-jar table and `CONTENT-PACKS-CHECK` from content; `TARGETS_extract := lib bin`), `gate-<pkg>` for the new packages and a `gate-tables` target running `python3 tools/gen/gen_tables.py --check`, and make `gate-tools` and `gate-contract` depend on `gate-tables`
- [ ] T0006 [P] Create `formats/Makefile` including `tools/package.mk` with `PKG := formats`, `LIBNAME := libformats.a` and empty `SRC` and `TESTS` lists, and the directories `formats/src`, `formats/tests`, `formats/copy` (skeleton; `make gate-formats` exits 0 on the empty package)
- [ ] T0007 [P] Create `content/Makefile` including `tools/package.mk` with `PKG := content`, `LIBNAME := libcontent.a`, empty `SRC` and `TESTS` lists, `INCLUDES` of `content/copy` and `content/copy/gen`, and the directories `content/src`, `content/tests`, `content/copy`, `content/copy/gen`
- [ ] T0008 [P] Create `extract/Makefile` including `tools/package.mk` with `PKG := extract`, `LIBNAME := libextract.a`, `TARGETS lib bin` producing `build/bin/cobolcraft-extract` from `src/main.cob`, empty `SRC` and `TESTS` lists, and the directories `extract/src`, `extract/tests`
- [ ] T0009 Exclude `content/copy/gen/` (generated data, constitution 4.2) from the production set in `tools/coverage.py` and write the matching case in `tools/tests/test_coverage.py` first
- [ ] T0010 Write acceptance test `tools/tests/acc_f2us1_gen_cli.py`: `python3 tools/gen/gen_tables.py --check` exits 0 on an empty table set and exits 1 naming the file when a generated file differs by one byte (drift gate, contracts/test-harness-delta.md)
- [ ] T0011 Create `tools/gen/gen_tables.py` skeleton with `--check` (regenerate into a scratch directory, compare byte for byte with `content/copy/gen/`) and `--write`, no tables yet
- [ ] T0012 Write implementation test `tools/tests/test_inputs.py` for the real-input convention: a COBOL test helper `TEST-INPUT-PATH` returns `$COBOLCRAFT_INPUTS/<name>` when the variable is set, else `tmp/<name>`, and a missing file makes the calling test print `TEST <case> FAIL expected=file observed=missing <path>` and exit non-zero (contracts/test-harness-delta.md "Test inputs")
- [ ] T0013 Create program `TEST-INPUT-PATH` in `tools/testlib/testinput.cob` (path resolution and the loud failure) satisfying the previous test
- [ ] T0014 Write acceptance test case in `tools/tests/test_bootstrap.py` expecting `sh tools/bootstrap.sh` to create `build/generated-test/` and to list `formats content extract` in its package list
- [ ] T0015 Update `tools/bootstrap.sh` (package list, creation of `build/generated-test/`) so the previous test passes
- [ ] T0016 Gate: run `make gate-tools` from the repository root and record the command and its real output (exit 0)

**Checkpoint**: every package has a Makefile and a gate target; the generator drift gate exists.

---

## Phase 2: Foundational (blocking prerequisites)

**Purpose**: the cross-package work no lane can own: the documentation rounds that close open questions before
any lane starts (Principle II), the frozen contract surface, the generated tables, the move of the shared readers.
**No lane phase begins until this phase's Gate passes.**

### 2a. Docs-first: clean-room rounds and design records (plan "Docs-first obligations")

> Each round is run by the orchestrator with the `clean-room` skill: one reader task (a fresh subagent that reads
> the operator's jar `tmp/minecraft-26.3-client.jar`, static reading only, and writes prose and tables to the named
> document) and one separate reviewer task (a different fresh subagent; contamination, recall and completeness
> check; report only). Implementers never read the jar. A reviewer finding sends the document back to a new reader
> task of the same round.

- [ ] T0017 [P] Round OPT, reader: options screen texts, option names, ranges and key labels (`docs/design/builtin-ui-art.md` Open question 13; `docs/protocol/13-client-gameplay-and-controls.md` §7) so US16 can be built from the document
- [ ] T0018 Round OPT, reviewer: contamination and completeness review of the OPT documents; every option on the Options screen has name, default, range, persisted key and text
- [ ] T0019 [P] Round GUI, reader: built-in GUI art and layout values not yet read in `docs/design/builtin-ui-art.md` (sprite sizes and sheet regions the slices use, tooltip frame, recipe-book tabs and toasts, minimum window size, contrast values)
- [ ] T0020 Round GUI, reviewer: contamination and completeness review of the GUI document changes
- [ ] T0021 [P] Round TINT, reader: per-biome grass tint values and the 43 tint sources as `docs/design/faithful-pack-mapping.md` and `docs/protocol/43-tint-sources.md` need them
- [ ] T0022 Round TINT, reviewer: contamination and completeness review
- [ ] T0023 [P] Round SAVE, reader: the save layout question between `docs/protocol/07-nbt-and-anvil.md` and `docs/protocol/33-world-simulation.md` (`docs/design/world-types.md` Open question 12), then transcribe the answer into `docs/protocol/07-nbt-and-anvil.md` §9 as the world-folder contract (three dimension folders, `WorldType`, `Seed`, `ContentJar`, block states by key in palettes, WT-23)
- [ ] T0024 Round SAVE, reviewer: contamination and completeness review of `07` §9 against `contracts/core-host-delta.md` §3
- [ ] T0025 [P] Round SEED, reader: the seed text to seed rule (`docs/protocol/11-world-generation-caves-and-ores.md` Open question; fixes `CS-SEED-TEXT`) with worked examples
- [ ] T0026 Round SEED, reviewer: contamination and completeness review (the worked examples are checked against the artifact)
- [ ] T0027 [P] Round SPOPEN, reader: the single-player world opened to others (`docs/design/world-types.md` §10) so the host keeps world type and shared rules
- [ ] T0028 Round SPOPEN, reviewer: contamination and completeness review
- [ ] T0029 [P] Round TIBE, reader: `TestInstanceBlockEditScreen` (`docs/protocol/40-menus-9-block-editor-screens.md` Open question 1)
- [ ] T0030 Round TIBE, reviewer: contamination and completeness review
- [ ] T0031 [P] Round PNG, reader: the PNG kinds (colour types, bit depths, interlace, ancillary chunks) the jar and Faithful use, closing `docs/protocol/22-extraction-tool.md` Open question 7
- [ ] T0032 Round PNG, reviewer: contamination and completeness review
- [ ] T0033 [P] Round LIBM, reader: every `libm` function and rounding rule that documents 10, 11, 15 and 18 call for in bit-exact arithmetic, recorded as a table in `docs/protocol/10-world-generation-terrain.md` (list that fixes the `cc_f64_*` function set of `contracts/shim-delta.md`)
- [ ] T0034 Round LIBM, reviewer: contamination and completeness review; the function list covers every arithmetic step in 10, 11, 15 and 18 that is not add, sub, mul, div, floor, sqrt or text conversion
- [ ] T0035 [P] Write the design record of the optional Faithful skin (FR-006, `docs/design/README.md` Part 7 decision 10) in `docs/design/faithful-pack-mapping.md`, closing Open question 11: the skin pack's pack id and title, that it is off by default, that it sits at level 2 of the pack stack between the built-in pack and the generated vanilla pack (§9.1), that it covers blocks and items only and leaves the `turf` models and the entity strips alone, and that its on/off toggle is a row on the resource pack screen shown only while a cobolcraft-type world is being created or opened (`docs/protocol/13-client-gameplay-and-controls.md` §8 gets one line pointing at it)
- [ ] T0036 Review `docs/design/faithful-pack-mapping.md` skin record: every statement above is present, and no value is invented (the texture ids come from sections 3 and 4 of that document)
- [ ] T0037 [P] Write `docs/design/world-types.md` §8: the recorded behaviour of a vanilla client against a cobolcraft-type server (passes configuration only, `docs/protocol/04-registry-sync.md` §5; the WT-16 behaviour, no new design) closing Open question 8
- [ ] T0038 [P] Write the design records of FR-027 in `docs/design/cobolcraft-standard-core.md`: any cobolcraft-type content the shared rules need beyond `cobolcraft:crafting_bench` (block, item, recipe, texture, tags), each with its values, before the content slice
- [ ] T0039 [P] Update `docs/protocol/09-cobolcraft-profile.md` per `contracts/wire-delta.md` §2: a row per packet whose use changes (standard chat types, command tree, permission levels, Player Abilities, 46-slot inventory and crafting menus, recipe book, Block Destruction, Set Held Item, Player Action swap, entity spawn and metadata, three-dimension Login and Respawn, 24-section chunk data), written from `05a`, `05b`, `05c`
- [ ] T0040 Review `docs/protocol/09-cobolcraft-profile.md` rows against `contracts/wire-delta.md` §2: every listed packet has a row with a field table and a fixture name
- [ ] T0041 [P] Review task (FR-012, US5-2): every cobolcraft block, item and mob has its texture path written in `docs/design/faithful-pack-mapping.md`; write any missing row from `docs/design/standin-content.md` and `cobolcraft-standard-core.md`; an unmapped one is listed as showing the missing-texture look
- [ ] T0042 Review task: `docs/design/README.md` Part 8 open items that bear on this feature are each closed by a task above or recorded as out of scope with the spec reason (sounds FR-043, unknown jar Part 7 decision 11, cobolcraft skin FR-006); update the Part 8 status lines

### 2b. Contract materialization (frozen shared surface; lanes read, never write)

- [ ] T0043 Write contract test cases in `tools/tests/test_contract_check.py` expecting `tools/contract_check.py` to compile `CONTENT.cpy`, `FORMATS.cpy` and `CELLS.cpy` in the probe program, to parse every new wire fixture, and to fail on a copybook that does not compile
- [ ] T0044 Extend `tools/contract_check.py` and the probe under `tools/probe/` so `make gate-contract` compiles the new copybooks and parses `contract/fixtures/wire/*.hex` including the new ones
- [ ] T0045 [P] Add to `contract/include/ccshim.h`: `cc_f64_add`, `cc_f64_sub`, `cc_f64_mul`, `cc_f64_div`, `cc_f64_floor`, `cc_f64_sqrt`, `cc_f64_from_text` and the libm wrappers named by Round LIBM (all operands and results by reference, return void), `cc_vk_texture_ex(tex_id, w, h, rgba, mip_levels)`, `cc_vk_texture_update(tex_id, x, y, w, h, rgba)`, `cc_vk_clear_depth(void)`, `cc_open_path(opener, path)` (`contracts/shim-delta.md`)
- [ ] T0046 [P] Add to `contract/copy/CCSHIM.cpy` the matching COBOL `CALL` shapes and the key codes `CC-KEY-F` (70), `CC-KEY-F3` (292), `CC-KEY-F5` (294) and every other key code `docs/protocol/13-client-gameplay-and-controls.md` §5.1 and §7.3 name
- [ ] T0047 [P] Add to `contract/copy/COREAPI.cpy` the settings `CS-WORLD-TYPE` PIC X(10) (`standard` or `cobolcraft`), `CS-GENERATED-DIR` PIC X(1024), `CS-SEED-TEXT` PIC X(64) (empty means random), `CS-GAME-DIR` PIC X(1024), the new `CORE-WORLD-OPEN` status words (packs not ok, dimensions without level.dat, standard folders without WorldType) and the re-derived `CORE-SETTINGS-SIZE`
- [ ] T0048 [P] Add to `contract/copy/PROTO.cpy` the composite records of `contracts/wire-delta.md` §3: item stack with components, entity metadata entries, chunk palette containers, command nodes, recipe book entries
- [ ] T0049 [P] Create `contract/copy/CONTENT.cpy` per `contracts/content-api.md` §1: `CT-SET` (type, packs status `ok|absent|incomplete|stale|damaged`, generated directory, registry counts; EXTERNAL), `CT-BLOCK-ROW`, `CT-ITEM-ROW`, `CT-ENTITY-ROW`, `CT-STATIC-ID-ROW`, `CT-REGISTRY`, `CT-ENTRY`, `CT-TAG`, and the status-word constants
- [ ] T0050 [P] Create `contract/copy/FORMATS.cpy` per `contracts/formats-api.md`: constants and record shapes (`FMZIP` handle, `FMSHA` context, `FMREGEX`, file and directory status words, `JSON-STRICT` reason codes)
- [ ] T0051 [P] Create `contract/copy/CELLS.cpy`: the one cell and chunk layout replacing core `CHUNKMEM.cpy` and client `CLCELLS.cpy` (2-byte block state, 4-bit sky and block light, sections from the dimension's `min_y` and `height`, 3 dimensions, biome containers; `docs/protocol/06-chunk-format.md`, data-model §4); copybook only, adopted by core and client in their lanes
- [ ] T0052 [P] Create `contract/copy/JSONDOC.cpy` by moving `client/copy/JSONDOC.cpy` there unchanged (shared by formats, content, client)
- [ ] T0053 [P] Create fixtures under `contract/fixtures/formats/`: small hand-made zip (stored and deflated entries, a bad CRC, a zip64 marker, an encrypted entry), strict-JSON accept and reject files (comments, trailing comma, duplicate key), PNG files of every kind Round PNG lists
- [ ] T0054 [P] Create fixtures under `contract/fixtures/content/`: a small valid generated directory tree (manifest, sentinels, `vanilla-data` with a handful of registries, tags, recipes and worldgen files), a stale tree (tampered manifest) and a damaged tree (removed sentinel) (`docs/protocol/22-extraction-tool.md` §8.2)
- [ ] T0055 [P] Create fixtures under `contract/fixtures/extract/`: hand-made reject archives for 22 §4.2 C1 to C5 and the T-series reject cases of 22 §12 (not a zip, wrong digest, missing entries)
- [ ] T0056 [P] Create fixtures under `contract/fixtures/client/`: `options-default.txt`, `options-full.txt`, `options-corrupt.txt`, `options-out-of-range.txt` per `docs/protocol/13-client-gameplay-and-controls.md` §7.1 and a legacy `options.dat`
- [ ] T0057 Create `tools/wire_fixtures.py`, the independent Python encoder used for wire fixtures not taken from a document worked example, with a self-test in `tools/tests/test_wire_fixtures.py` written first
- [ ] T0058 [P] Create wire fixtures `contract/fixtures/wire/*.hex` for chunk data (24 sections, single-value, indirect and direct palettes, biome containers, 26 light entries; 06 worked examples) and registry data and Update Tags (04 worked examples)
- [ ] T0059 [P] Create wire fixtures for Block Destruction, Player Action (start, abort, finish, swap with sequence ids) and Block Update (13 §2.3, §2.4)
- [ ] T0060 [P] Create wire fixtures for Container Set Slot, Container Set Content, Container Click, Set Cursor Item, Open Screen with data components, Place Recipe, Recipe Book Add, Remove, Settings and Seen (00, 27, 40)
- [ ] T0061 [P] Create wire fixtures for Commands (full node tree with every parser kind), Command Suggestions request and response, Chat Command, Player Chat and Disguised Chat with standard chat types (15, 15a)
- [ ] T0062 [P] Create wire fixtures for Spawn Entity, Set Entity Data (every serializer of 46 §12), Entity Event, Update Attributes, Update Mob Effect, Level Event, Level Particles, Login and Respawn for three dimensions (18, 21, 42, 39, 46)
- [ ] T0063 Gate: run `make gate-contract` and record the command and real output (all new copybooks compile, all fixtures parse)

### 2c. Table generator and drift gate (R2, R3; `tools/gen/gen_tables.py`)

- [ ] T0064 Write acceptance test `tools/tests/acc_f2us2_gen_blocks.py`: generating the block table from `docs/protocol/24-block-registry-1-...` to `-8-...` yields the counts the documents state in their validation sections (24 §17; about 1,200 blocks, 30,000 states) and the worked examples of 24 §16, and the row layout is the 400-character literal rows of data-model §2
- [ ] T0065 Implement the block and block-property tables in `tools/gen/gen_tables.py` (rows of data-model §2 "Block", "Block property"; output `content/copy/gen/blocks.cpy` and `blockprops.cpy`) so the previous test passes
- [ ] T0066 Write acceptance test `tools/tests/acc_f2us2_gen_items.py` against `docs/protocol/25-item-registry-1-...` to `-8-...` and `25-item-registry-x1-continuation.md` (counts and worked examples; about 1,500 items)
- [ ] T0067 Implement the item table (`content/copy/gen/items.cpy`) in `tools/gen/gen_tables.py`
- [ ] T0068 Write acceptance test `tools/tests/acc_f2us2_gen_static_ids.py` against `docs/protocol/46-registry-ids.md` (counts of 46 §16, worked examples of 46 §15) for the static registry id table, the entity type table (21 §2, 46 §11) and the list of tag names the code reads (24 part 1 §12)
- [ ] T0069 Implement the static registry id, entity type and tag name tables (`content/copy/gen/staticids.cpy`, `entities.cpy`, `tagnames.cpy`) in `tools/gen/gen_tables.py`
- [ ] T0070 Write acceptance test `tools/tests/acc_f2us1_gen_jar_row.py`: the accepted-jar row (version id, size, SHA-256, world and protocol versions, pack formats) generated from `docs/protocol/README.md` equals the single recorded row (22 §4.1)
- [ ] T0071 Implement the accepted-jar table (`content/copy/gen/acceptedjar.cpy`) in `tools/gen/gen_tables.py`
- [ ] T0072 Write acceptance test `tools/tests/acc_f2us2_gen_drift.py`: `--check` fails when a document count changes by one row (loses a block) and when a generated file is edited by hand
- [ ] T0073 Run `python3 tools/gen/gen_tables.py --write` and add the generated files under `content/copy/gen/` (data, not hand-edited); `make gate-tables` exits 0
- [ ] T0074 Gate: run `make gate-tables && make gate-tools` and record the command and real output

### 2d. Move of the shared readers to `formats` (R1, behaviour-preserving)

- [ ] T0075 Move `client/src/json.cob` and `client/tests/test_json.cob` to `formats/src/json.cob` and `formats/tests/test_json.cob`; register them in `formats/Makefile` (`SRC`, `TESTS`) and remove them from `client/Makefile`; no `CALL` changes
- [ ] T0076 Move `client/src/zip.cob`, `client/tests/test_zip.cob` and `client/copy/CLZIP.cpy` (renamed `FMZIP.cpy`, in `contract/copy/`) to `formats/`; update the `COPY` statements in every client program
- [ ] T0077 Move `client/src/png.cob` and `client/tests/test_png.cob` to `formats/`
- [ ] T0078 Move `client/src/regex.cob`, `client/tests/test_regex.cob` and `client/copy/CLREGEX.cpy` (renamed `FMREGEX.cpy`, in `contract/copy/`) to `formats/`; update the `COPY` statements
- [ ] T0079 Move `FILE-READ-ALL` from `client/src/packs/source.cob` into `formats/src/files.cob` with a `formats/tests/test_files.cob` covering it; `source.cob` calls it from the library
- [ ] T0080 Re-link `client/Makefile` against `build/formats/libformats.a` (`DEPS_client` gains `formats`) and delete the stale client copies
- [ ] T0081 Write contract test `formats/tests/contract_formats_provider.cob` for the programs that exist after the move (`JSON-*`, `ZIP-*`, `PNG-DECODE`, `REGEX-*`, `FILE-READ-ALL`) against `contract/fixtures/formats/`
- [ ] T0082 Write consumer test `client/tests/contract_formats_consumer.cob` calling the moved programs the way the client does (`contracts/formats-api.md` "Contract tests")
- [ ] T0083 Gate: run `make gate-formats` and record the command and real output
- [ ] T0084 Gate: run `make gate-client` and record the command and real output (the move must leave the client's tests green; behaviour preserved)

### 2e. Foundational gate

- [ ] T0085 Gate: run `make gate-contract && make gate-tools && make gate-formats && make gate-client` and record the command and real output; confirm each document deliverable of 2a has its review task done

**Checkpoint**: contracts frozen, documents closed, generated tables in place, shared readers moved. Lanes may start.

---

## PARALLEL GROUP — package lanes

> Lanes read `contract/` and `docs/`; they never write them. Cross-lane edges (constitution 2.5, plan "Lane notes"):
> `content` needs `formats` US1 and the generated tables; `extract` needs `formats` US1 and `content` US1; `core` US2
> needs `content` US2, core US11 needs `shim` US11 and `content` US11; `client` US3 to US5 need `formats` and
> `shim` US3/US5; `client` US8 to US10 need `proto` US8/US9 and the `core` slices; the `client` replica and mesher
> re-base (its first phase) needs the `proto` chunk codec (US11-proto) and the core chunk encoding. Because the
> core and the client keep a separate chunk copy linked only by the wire, the `proto` chunk codec is additive (the
> old encoder and decoder remain until Polish removes them), the client decodes both forms in its first phase, and
> the core switches to the new form in its US11 phase; no client gate sees a form it cannot decode. A consumer
> slice starts only after its provider slice has passed its own gate.

### Lane: shim

#### Phase 3: US3-shim — texture upload with mip levels and sub-rectangle update

**Goal**: the client can upload a pack-resolution atlas and update animated cells (FR-010). **Independent Test**: `shim/tests/test_cc_vk_texture_ex.c` and `test_cc_vk_texture_update.c` read back the uploaded and updated pixels from the real MoltenVK device.

- [ ] T0086 [P] [US3-shim] Write test `shim/tests/test_cc_vk_texture_ex.c`: a texture uploaded with `cc_vk_texture_ex(..., mip_levels = 1)` reads back identical to its RGBA input and `cc_vk_texture` still behaves as before
- [ ] T0087 [P] [US3-shim] Write test `shim/tests/test_cc_vk_texture_update.c`: after `cc_vk_texture_update` of a rectangle only that rectangle reads back changed
- [ ] T0088 [US3-shim] Extend `shim/tests/contract_shim_provider.c` with the new texture entry points' return values and argument shapes
- [ ] T0089 [US3-shim] Implement `cc_vk_texture_ex` in `shim/src/cc_vk.c` (`cc_vk_texture` calls it with 1 level)
- [ ] T0090 [US3-shim] Implement `cc_vk_texture_update` in `shim/src/cc_vk.c` (staging buffer and copy command)
- [ ] T0091 [US3-shim] Gate: run `make gate-shim` and record the command and real output

#### Phase 4: US4-shim — path opener

**Goal**: the client can start the system file browser on a folder (Q-2). **Independent Test**: `shim/tests/test_cc_open.c`.

- [ ] T0092 [US4-shim] Write test `shim/tests/test_cc_open.c`: `cc_open_path("/usr/bin/true", dir)` returns 0 at once; a missing opener path returns `CC-NOTFOUND`; the call does not wait for the child
- [ ] T0093 [US4-shim] Implement `cc_open_path` with `posix_spawn` in `shim/src/cc_open.c` and register it in `shim/Makefile`
- [ ] T0094 [US4-shim] Extend `shim/tests/contract_shim_provider.c` with the `cc_open_path` shape
- [ ] T0095 [US4-shim] Gate: run `make gate-shim` and record the command and real output

#### Phase 5: US5-shim — mip chain and sampler

**Goal**: textures do not shimmer or bleed at any distance (FR-011). **Independent Test**: readback of mip level 1 and the sampler state.

- [ ] T0096 [P] [US5-shim] Write test `shim/tests/test_cc_vk_mips.c`: with `mip_levels` 4 a known 8x8 pattern reads back a box-filtered level 1 and level 2 (`docs/protocol/12-client-rendering.md` §2.4)
- [ ] T0097 [P] [US5-shim] Write test `shim/tests/test_cc_vk_mip_update.c`: `cc_vk_texture_update` on a multi-level texture regenerates the touched mip levels
- [ ] T0098 [US5-shim] Implement the box-filter mip chain generation in `shim/src/cc_vk.c`
- [ ] T0099 [US5-shim] Implement the sampler of 12 §2.4 (filter and mipmap mode, replacing the `NEAREST` filters at `cc_vk.c:413-415`) and mip regeneration in `cc_vk_texture_update`
- [ ] T0100 [US5-shim] Gate: run `make gate-shim` and record the command and real output

#### Phase 6: US11-shim — IEEE double arithmetic by reference

**Goal**: bit-exact terrain arithmetic at affordable speed (R5, Risk R-P). **Independent Test**: `test_cc_f64.c` against independently computed IEEE vectors.

- [ ] T0101 [US11-shim] Create `shim/tests/gen_f64_vectors.py` (stdlib `struct`) writing `shim/tests/f64_vectors.txt` with operand/result pairs for every `cc_f64_*` function, computed independently of the C code
- [ ] T0102 [US11-shim] Write test `shim/tests/test_cc_f64_arith.c` for add, sub, mul, div, floor, sqrt over the vectors (`0.1 + 0.2` gives `343333333333D33F`)
- [ ] T0103 [US11-shim] Write test `shim/tests/test_cc_f64_text.c` for `cc_f64_from_text` (nearest double of a decimal text, `strtod`)
- [ ] T0104 [US11-shim] Write test `shim/tests/test_cc_f64_libm.c` for each libm wrapper Round LIBM named
- [ ] T0105 [US11-shim] Implement add, sub, mul, div, floor, sqrt (`fma`-based add and mul) in `shim/src/cc_f64.c`
- [ ] T0106 [US11-shim] Implement `cc_f64_from_text` in `shim/src/cc_f64.c`
- [ ] T0107 [US11-shim] Implement the libm wrappers in `shim/src/cc_f64.c` and register the file in `shim/Makefile`
- [ ] T0108 [US11-shim] Extend `shim/tests/contract_shim_provider.c` with the `cc_f64_*` entry points
- [ ] T0109 [US11-shim] Gate: run `make gate-shim` and record the command and real output

#### Phase 7: US20-shim — depth clear for the hand pass

**Goal**: the first-person hand draws over the world (12 §6). **Independent Test**: `test_cc_vk_clear_depth.c`.

- [ ] T0110 [US20-shim] Write test `shim/tests/test_cc_vk_clear_depth.c`: a near and a far quad drawn, depth cleared, a second quad behind the first draws over it (readback)
- [ ] T0111 [US20-shim] Implement `cc_vk_clear_depth` in `shim/src/cc_vk.c`
- [ ] T0112 [US20-shim] Gate: run `make gate-shim` and record the command and real output

### Lane: formats

#### Phase 8: US1-formats — strict JSON, ZIP index and CRC, hashes, files

**Goal**: the readers the extraction tool and the loaders need (22 §7, 23 §3.2). **Independent Test**: `formats/tests/contract_formats_provider.cob` returns the documented values for the vectors of 22 §12 T2, T3, T15.

- [ ] T0113 [US1-formats] Write contract test cases in `formats/tests/contract_formats_provider.cob` for `CRC32` (`123456789` gives `cbf43926`, 22 §7.2), `SHA256-*` (`abc` gives `ba7816bf...15ad`) and the 22 §12 T2, T3, T15 vectors
- [ ] T0114 [P] [US1-formats] Write test `formats/tests/test_crc32.cob` (running value across buffers, empty buffer)
- [ ] T0115 [US1-formats] Implement `CRC32` in `formats/src/crc32.cob`
- [ ] T0116 [P] [US1-formats] Write test `formats/tests/test_sha256.cob` (init/update/final in pieces, 32-byte output, `abc`, the empty string)
- [ ] T0117 [US1-formats] Implement `SHA256-INIT`, `SHA256-UPDATE`, `SHA256-FINAL` in `formats/src/sha256.cob` with direct OpenSSL `EVP_MD_CTX_*` calls (`FMSHA` context; link `-lcrypto` in `formats/Makefile`)
- [ ] T0118 [P] [US1-formats] Write test `formats/tests/test_json_strict.cob`: accept valid documents, reject comments, trailing commas and duplicate keys, return the error offset and reason code (23 §3.2)
- [ ] T0119 [US1-formats] Implement `JSON-STRICT` in `formats/src/json-strict.cob`
- [ ] T0120 [P] [US1-formats] Write test `formats/tests/test_zip_index.cob`: name lookup through a hash index over a 10,000-entry central directory without scanning (22 §8.4 last paragraph)
- [ ] T0121 [US1-formats] Add the name hash index to `ZIP-FIND` in `formats/src/zip.cob`
- [ ] T0122 [P] [US1-formats] Write test `formats/tests/test_zip_crc_range.cob`: `ZIP-CRC-CHECK` accepts a good entry and rejects the bad-CRC fixture; `ZIP-READ-RANGE` inflates one entry into a caller buffer; zip64, several disks and encryption are rejected with a reason (22 §8.4)
- [ ] T0123 [US1-formats] Implement `ZIP-CRC-CHECK` and `ZIP-READ-RANGE` and the rejections in `formats/src/zip.cob`
- [ ] T0124 [P] [US1-formats] Write test `formats/tests/test_files_io.cob` for `FILE-READ-AT`, `FILE-WRITE`, `FILE-EXISTS` with status words (a missing file, an unwritable folder)
- [ ] T0125 [US1-formats] Implement `FILE-READ-AT`, `FILE-WRITE`, `FILE-EXISTS` in `formats/src/files.cob` over `CBL_OPEN_FILE`, `CBL_READ_FILE`, `CBL_WRITE_FILE`, `CBL_CHECK_FILE_EXIST`
- [ ] T0126 [P] [US1-formats] Write test `formats/tests/test_dirs.cob` for `DIR-ENSURE` (nested), `DIR-RENAME` (atomic swap of a directory), `DIR-REMOVE-TREE` (tree walk through `cc_fs_list`)
- [ ] T0127 [US1-formats] Implement `DIR-ENSURE`, `DIR-RENAME`, `DIR-REMOVE-TREE` in `formats/src/dirs.cob`
- [ ] T0128 [P] [US1-formats] Write test `formats/tests/test_png_kinds.cob`: `PNG-DECODE` decodes every kind Round PNG lists, using the `contract/fixtures/formats/` PNGs
- [ ] T0129 [US1-formats] Extend `PNG-DECODE` in `formats/src/png.cob` for the kinds Round PNG lists
- [ ] T0130 [US1-formats] Write implementation tests in `formats/tests/test_formats_cover.cob` for any line of `formats/src` the tests above leave unexecuted (`make coverage` lists them)
- [ ] T0131 [US1-formats] Gate: run `make gate-formats` and record the command and real output

#### Phase 9: US3-formats — user pack archives

**Goal**: user resource packs (zip methods 0 and 8, thousands of entries) read correctly (FR-007). **Independent Test**: `acc_f2us3_user_zip` against the real Faithful zip.

- [ ] T0132 [US3-formats] Write acceptance test `formats/tests/acc_f2us3_user_zip.cob`: given `tmp/Faithful 32x - 26.3.zip` (real input, fails loudly when absent) and the stored and deflated fixtures, every entry lists, resolves by name and reads with a matching CRC, and a name lookup does not scan [FR-007, FR-008, FR-009, FR-010; SC-001]
- [ ] T0133 [US3-formats] Make `acc_f2us3_user_zip` pass in `formats/src/zip.cob`; if the test already passes when written, record that evidence and mark this task done
- [ ] T0134 [US3-formats] Gate: run `make gate-formats` and record the command and real output

### Lane: proto

#### Phase 10: US8-proto — block destruction and player action

**Goal**: encode and decode the break stage and the dig actions with sequence ids (13 §2.3, §2.4).

- [ ] T0135 [US8-proto] Extend `proto/tests/contract_wire_provider.cob` with the Block Destruction and Player Action fixtures (decode to fields, re-encode to the same bytes)
- [ ] T0136 [US8-proto] Write test cases in `proto/tests/test_composites.cob` for `PB-PUT-BLOCK-DESTRUCTION` and `PB-GET-PLAYER-ACTION` (status, position, face, sequence)
- [ ] T0137 [US8-proto] Implement the Block Destruction encoder and Player Action decoder in `proto/src/composites.cob`
- [ ] T0138 [US8-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 11: US9-proto — item stack with components, containers, recipe book

**Goal**: the inventory, crafting and recipe-book packets (00, 27, 40).

- [ ] T0139 [US9-proto] Extend `proto/tests/contract_wire_provider.cob` with the container and recipe-book fixtures
- [ ] T0140 [US9-proto] Write tests in `proto/tests/test_item_stack.cob` for the item stack with a non-empty data component patch (add and remove lists, 00), replacing the empty patch at `proto/src/composites.cob:123`
- [ ] T0141 [US9-proto] Implement `PB-PUT-ITEM-STACK` and `PB-GET-ITEM-STACK` with components in `proto/src/item-stack.cob`
- [ ] T0142 [US9-proto] Write tests in `proto/tests/test_containers.cob` for Container Set Slot, Content, Click (changed slots, cursor), Set Cursor Item, Open Screen, Container Close
- [ ] T0143 [US9-proto] Implement the container packet encoders and decoders in `proto/src/containers.cob`
- [ ] T0144 [US9-proto] Write tests in `proto/tests/test_recipe_book.cob` for Place Recipe and Recipe Book Add, Remove, Settings, Seen (27)
- [ ] T0145 [US9-proto] Implement the recipe-book encoders and decoders in `proto/src/recipe-book.cob`
- [ ] T0146 [US9-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 12: US11-proto — 24-section chunks, registries and tags

**Goal**: the chunk codec for 16-bit states and 24 sections, and the configuration packets of the standard world (04, 06).

- [ ] T0147 [US11-proto] Extend `proto/tests/contract_wire_provider.cob` with the chunk, Registry Data and Update Tags fixtures
- [ ] T0148 [US11-proto] Write tests in `proto/tests/test_chunk_palette.cob` for paletted containers: single value, indirect, direct, with bits per entry from the 06 rules, for blocks (4096 cells) and biomes (64 cells)
- [ ] T0149 [US11-proto] Implement the paletted container encoder and decoder in `proto/src/chunk-palette.cob` (additive: the 001 chunk functions in `proto/src/chunk.cob` stay until Polish)
- [ ] T0150 [US11-proto] Write tests in `proto/tests/test_chunk24.cob` for a 24-section chunk packet with 26 light indices, heightmaps and block entities (06 worked examples)
- [ ] T0151 [US11-proto] Implement `PB-PUT-CHUNK-24` and `PB-GET-CHUNK-24` in `proto/src/chunk24.cob`
- [ ] T0152 [US11-proto] Write tests in `proto/tests/test_registry_tags.cob` for Registry Data entries (with and without inline data) and Update Tags (04 worked examples)
- [ ] T0153 [US11-proto] Implement the Registry Data and Update Tags encoders and decoders in `proto/src/registry-tags.cob`
- [ ] T0154 [US11-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 13: US12-proto — level events, particles, three-dimension login

- [ ] T0155 [US12-proto] Extend `proto/tests/contract_wire_provider.cob` with the Level Event, Level Particles, Login and Respawn (three dimensions), Block Event and Block Entity Data fixtures
- [ ] T0156 [US12-proto] Write tests in `proto/tests/test_level_events.cob` for those packets (42, 39, 31)
- [ ] T0157 [US12-proto] Implement their encoders and decoders in `proto/src/level-events.cob`
- [ ] T0158 [US12-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 14: US13-proto — command nodes and suggestions

- [ ] T0159 [US13-proto] Extend `proto/tests/contract_wire_provider.cob` with the Commands, Command Suggestions, Chat Command, Player Chat and Disguised Chat fixtures
- [ ] T0160 [US13-proto] Write tests in `proto/tests/test_command_nodes.cob` for every parser kind with its properties and the redirect and suggestion-type fields (15, 15a)
- [ ] T0161 [US13-proto] Implement the full command node tree encoder and decoder in `proto/src/command-nodes.cob`
- [ ] T0162 [US13-proto] Write tests in `proto/tests/test_chat_commands.cob` for Command Suggestions request and response, Chat Command, Player Chat and Disguised Chat with the standard chat types
- [ ] T0163 [US13-proto] Implement those packets in `proto/src/chat-commands.cob`
- [ ] T0164 [US13-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 15: US14-proto — attributes and effects

- [ ] T0165 [US14-proto] Extend `proto/tests/contract_wire_provider.cob` with the Update Attributes and Update Mob Effect fixtures
- [ ] T0166 [US14-proto] Write tests in `proto/tests/test_attributes.cob` for attribute modifiers and mob effects (17, 28)
- [ ] T0167 [US14-proto] Implement the Update Attributes and Update Mob Effect codecs in `proto/src/attributes.cob`
- [ ] T0168 [US14-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 16: US15-proto — entity spawn and metadata

- [ ] T0169 [US15-proto] Extend `proto/tests/contract_wire_provider.cob` with the Spawn Entity, Set Entity Data and Entity Event fixtures
- [ ] T0170 [US15-proto] Write tests in `proto/tests/test_entity_metadata.cob` for every serializer of `docs/protocol/46-registry-ids.md` §12
- [ ] T0171 [US15-proto] Implement the entity metadata entry codecs in `proto/src/entity-metadata.cob`
- [ ] T0172 [US15-proto] Write tests in `proto/tests/test_entity_packets.cob` for Spawn Entity and Entity Event (18, 21)
- [ ] T0173 [US15-proto] Implement the Spawn Entity and Entity Event codecs in `proto/src/entity-packets.cob`
- [ ] T0174 [US15-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 17: US19-proto — swap action

- [ ] T0175 [US19-proto] Extend `proto/tests/contract_wire_provider.cob` with the swap-with-off-hand Player Action fixture
- [ ] T0176 [US19-proto] Write a test case in `proto/tests/test_composites.cob` for the swap action status and its decoding (13 §4)
- [ ] T0177 [US19-proto] Extend the Player Action decoder in `proto/src/composites.cob` with the swap status
- [ ] T0178 [US19-proto] Gate: run `make gate-proto` and record the command and real output

### Lane: content

#### Phase 18: US1-content — packs check and accepted jar

**Goal**: the game can tell whether valid generated packs exist and why not (22 §8.2, FR-003, FR-004). **Independent Test**: `CONTENT-PACKS-CHECK` over the fixture trees returns `ok`, `stale`, `damaged`, `absent`, `incomplete`.

- [ ] T0179 [US1-content] Write test `content/tests/test_accepted_jar.cob`: the accepted-jar accessor returns the one row of the generated table `content/copy/gen/acceptedjar.cpy` (size, SHA-256, versions, pack formats)
- [ ] T0180 [US1-content] Implement the accepted-jar accessor program `CONTENT-ACCEPTED-JAR` in `content/src/accepted-jar.cob`
- [ ] T0181 [US1-content] Write acceptance test `content/tests/acc_f2us1_packs_check.cob`: over `contract/fixtures/content/` a valid tree gives `ok`, a missing directory `absent`, a missing sentinel `damaged`, a tampered manifest `stale`, a manifest listing missing parts `incomplete` (22 §8.2); the check reads no jar and hashes nothing [FR-001, FR-002; SC-012]
- [ ] T0182 [US1-content] Write edge-case test `content/tests/test_packs_partial.cob` (spec edge case "the jar changes between runs"): a leftover `<generated>.partial` alone gives `absent`; a valid tree beside a stale `.partial` gives `ok` and the check never reads the `.partial`, so loaders cannot read half-written output (22 §7.5)
- [ ] T0183 [US1-content] Implement `CONTENT-PACKS-CHECK` (status word and reason text) in `content/src/packs-check.cob`
- [ ] T0184 [US1-content] Write consumer test `content/tests/contract_formats_consumer.cob` calling `JSON-STRICT`, `ZIP-*` and `FILE-*` the way `content` does
- [ ] T0185 [US1-content] Write implementation tests `content/tests/test_packs_check_paths.cob` for the check's remaining branches (unreadable manifest, short manifest line)
- [ ] T0186 [US1-content] Gate: run `make gate-content` and record the command and real output

#### Phase 19: US2-content — content sets, registries, tags, built-in layer

**Goal**: both world types answer the same lookups with the same record shapes (R6). **Independent Test**: `contract_content_provider.cob` returns the worked examples of 24 §16, 46 §15, 23 §3.4 and §6.7.

- [ ] T0187 [US2-content] Write contract test `content/tests/contract_content_provider.cob`: block, item, entity and static-id lookups of the standard set return the worked examples (24 §16, 25, 46 §15); unknown keys and ids return row 0 / "not found" (content-api §3)
- [ ] T0188 [US2-content] Write test `content/tests/test_content_blocks.cob` for `CONTENT-BLOCK-BY-KEY`, `CONTENT-BLOCK-OF-STATE`, `CONTENT-STATE-PROPS`, `CONTENT-STATE-DEFAULT` (state id rule of 24 part 1 §3, no stored state rows)
- [ ] T0189 [US2-content] Implement the block and state lookups in `content/src/blocks.cob` over the generated block tables
- [ ] T0190 [US2-content] Write test `content/tests/test_content_items.cob` for `CONTENT-ITEM-BY-KEY`, `CONTENT-ITEM-BY-ID`, `CONTENT-ITEM-COMPONENT`
- [ ] T0191 [US2-content] Implement the item lookups in `content/src/items.cob`
- [ ] T0192 [US2-content] Write test `content/tests/test_content_entities.cob` for `CONTENT-ENTITY-BY-KEY` and `CONTENT-STATIC-ID`
- [ ] T0193 [US2-content] Implement them in `content/src/entities.cob`
- [ ] T0194 [US2-content] Write test `content/tests/test_registry_load.cob` for the 23 §3 loading sequence over a fixture `vanilla-data` tree: strict JSON, ids in order, freeze, validate, mandatory keys (04 §3.2); `CONTENT-REGISTRY-ENTRY` and `CONTENT-REGISTRY-COUNT`
- [ ] T0195 [US2-content] Implement the registry loader in `content/src/registry.cob`
- [ ] T0196 [US2-content] Write test `content/tests/test_tags.cob` for tag resolution (23 §6, worked examples §6.7), `CONTENT-TAG-HAS`, `CONTENT-TAG-MEMBERS`
- [ ] T0197 [US2-content] Implement tag loading and resolution in `content/src/tags.cob`
- [ ] T0198 [US2-content] Write acceptance test `content/tests/acc_f2us2_content_open.cob`: `CONTENT-OPEN` of the standard type is refused unless the packs check is `ok`; the cobolcraft type opens with an empty generated directory and never reads the generated data pack; the two sets share no rows (WT-25) [FR-003, FR-004, FR-005, FR-037; SC-011]
- [ ] T0199 [US2-content] Implement `CONTENT-OPEN` and `CONTENT-CLOSE` (`CT-SET`) in `content/src/content-open.cob`
- [ ] T0200 [US2-content] Write test `content/tests/test_builtin_blocks.cob`: the cobolcraft layer answers the same block lookups with the 12 blocks and 18 states of `docs/design/standin-content.md` and `cobolcraft-standard-core.md` (state ids 0 to 17)
- [ ] T0201 [US2-content] Implement the built-in block layer in `content/src/builtin-blocks.cob`
- [ ] T0202 [US2-content] Write test `content/tests/test_builtin_items.cob`: the 18 items, with their components and tags, as the same record shapes the standard set returns
- [ ] T0203 [US2-content] Implement the built-in item layer in `content/src/builtin-items.cob`
- [ ] T0204 [US2-content] Write test `content/tests/test_builtin_entities.cob`: the cobolcraft mobs expressed as entity rows, components and tags
- [ ] T0205 [US2-content] Implement the built-in entity layer in `content/src/builtin-entities.cob`
- [ ] T0206 [US2-content] Write test `content/tests/test_client_registry.cob` for `CONTENT-CLIENT-REGISTRY-ADD` and `CONTENT-CLIENT-FINISH`, including the WT-16 decision of the world type from `minecraft:dimension_type` at Finish Configuration (`docs/design/world-types.md`)
- [ ] T0207 [US2-content] Implement the client registry load in `content/src/client-registry.cob`
- [ ] T0208 [US2-content] Write implementation tests in `content/tests/test_content_cover.cob` for lines of `content/src` left unexecuted
- [ ] T0209 [US2-content] Gate: run `make gate-content` and record the command and real output

#### Phase 20: US9-content — recipes

- [ ] T0210 [US9-content] Write test `content/tests/test_recipes_load.cob`: recipes of every type in `docs/protocol/27-recipes-and-unlocks.md` load through the loaders from a fixture data tree (shaped, shapeless, smelting family, stonecutting, smithing, special) with their unlock conditions
- [ ] T0211 [US9-content] Implement the recipe loader in `content/src/recipes.cob`
- [ ] T0212 [US9-content] Write test `content/tests/test_builtin_recipes.cob`: the cobolcraft recipes (`cobolcraft-standard-core.md`) are rows of the same recipe shapes
- [ ] T0213 [US9-content] Implement the built-in recipes in `content/src/builtin-recipes.cob`
- [ ] T0214 [US9-content] Gate: run `make gate-content` and record the command and real output

#### Phase 21: US10-content — crafting bench content

- [ ] T0215 [US10-content] Write test `content/tests/test_builtin_bench.cob`: `cobolcraft:crafting_bench` exists as block and item in the cobolcraft set, with its recipe and tags, and does not exist in the standard set (`cobolcraft-standard-core.md` §5, FR-027, FR-005)
- [ ] T0216 [US10-content] Add the bench block, item and recipe, and any further content the FR-027 design records name, to the built-in layer files in `content/src/`
- [ ] T0217 [US10-content] Gate: run `make gate-content` and record the command and real output

#### Phase 22: US11-content — worldgen registries

- [ ] T0218 [US11-content] Write test `content/tests/test_worldgen_noise.cob`: noise parameters and density function loaders over a fixture tree, with the shapes of `docs/protocol/10-world-generation-terrain.md` (the by-reference doubles of `cc_f64_from_text`)
- [ ] T0219 [US11-content] Implement the noise and density function loaders in `content/src/worldgen-density.cob`
- [ ] T0220 [US11-content] Write test `content/tests/test_worldgen_biomes.cob`: biome and multi-noise biome source loaders (10, 37 part 3, 43 tint inputs)
- [ ] T0221 [US11-content] Implement the biome loaders in `content/src/worldgen-biomes.cob`
- [ ] T0222 [US11-content] Write test `content/tests/test_worldgen_settings.cob`: noise settings, surface rules, carver configurations and ore feature parameters (10, 11, 37 parts 2 and 4)
- [ ] T0223 [US11-content] Implement the noise settings, surface rule and carver loaders in `content/src/worldgen-settings.cob`
- [ ] T0224 [US11-content] Write test `content/tests/test_dimension_types.cob`: `dimension_type` rows (min_y -64, height 384, sea level 63 for the overworld; 04 §6, 23 §7.3.3) and the three dimension definitions
- [ ] T0225 [US11-content] Implement the dimension loaders in `content/src/dimensions.cob`
- [ ] T0226 [US11-content] Gate: run `make gate-content` and record the command and real output

#### Phase 23: US12-content — features, structures, templates, processors

- [ ] T0227 [US12-content] Write test `content/tests/test_features_load.cob`: configured and placed feature loaders over a fixture tree, including the predicate and provider forms of `docs/protocol/35-worldgen-features-2-predicates-and-providers.md`
- [ ] T0228 [US12-content] Implement the feature loaders in `content/src/features.cob`
- [ ] T0229 [US12-content] Write test `content/tests/test_structures_load.cob`: structure, structure set, template pool and jigsaw loaders (36 parts 1 to 3)
- [ ] T0230 [US12-content] Implement the structure loaders in `content/src/structures.cob`
- [ ] T0231 [US12-content] Write test `content/tests/test_templates_load.cob`: structure template NBT files and processor lists (36 part 2)
- [ ] T0232 [US12-content] Implement the template and processor loaders in `content/src/templates.cob`
- [ ] T0233 [US12-content] Gate: run `make gate-content` and record the command and real output

#### Phase 24: US13-content — registries the commands name

- [ ] T0234 [US13-content] Write test `content/tests/test_command_sources.cob`: every registry the argument types of `docs/protocol/16-commands-catalog.md` complete against (items, blocks, entity types, enchantments, effects, biomes, structures, particle types, game rules, ...) enumerates through `CONTENT-REGISTRY-ENTRY` in id order for both sets
- [ ] T0235 [US13-content] Fill the missing registry sources in `content/src/registry.cob` so the test passes
- [ ] T0236 [US13-content] Gate: run `make gate-content` and record the command and real output

#### Phase 25: US14-content — item components

- [ ] T0237 [US14-content] Write test `content/tests/test_item_components.cob`: `CONTENT-ITEM-COMPONENT` returns tool rules, weapon damage, armor, durability, enchantable and attribute components for the tools and armors of `docs/protocol/17-tools-weapons-and-combat.md` §1 (standard set) and for the cobolcraft items
- [ ] T0238 [US14-content] Implement the component defaults in `content/src/item-components.cob`
- [ ] T0239 [US14-content] Write test `content/tests/test_enchantment_load.cob`: enchantment, damage type and equipment registries load (28)
- [ ] T0240 [US14-content] Implement the enchantment and damage type loaders in `content/src/enchantments.cob`
- [ ] T0241 [US14-content] Gate: run `make gate-content` and record the command and real output

#### Phase 26: US15-content — entity types, loot, spawn data

- [ ] T0242 [US15-content] Write test `content/tests/test_loot_load.cob`: loot tables, conditions and functions load from a fixture tree (26)
- [ ] T0243 [US15-content] Implement the loot loaders in `content/src/loot.cob`
- [ ] T0244 [US15-content] Write test `content/tests/test_spawn_data.cob`: biome spawner lists and spawn costs (44 part 2), mob variants and `CT-ENTITY-ROW` size and category (21 §2)
- [ ] T0245 [US15-content] Implement the spawn data loaders in `content/src/spawn-data.cob`
- [ ] T0246 [US15-content] Gate: run `make gate-content` and record the command and real output

### Lane: extract

#### Phase 27: US1-extract — the extraction tool (`docs/protocol/22-extraction-tool.md`)

**Goal**: `cobolcraft-extract` writes the vanilla resource pack and data pack from the user's jar (FR-001). **Independent Test**: the 22 §12 T-series against `tmp/minecraft-26.3-client.jar`; `CONTENT-PACKS-CHECK` returns `ok` on the output.

- [ ] T0247 [US1-extract] Write test `extract/tests/test_ex_args.cob` for `EX-ARGS`: `--jar --game-dir --generated-dir --force --verify --dry-run --quiet`, defaults (`<game dir>/generated`), unknown option gives CCX-001 and exit 1 (22 §7.1)
- [ ] T0248 [US1-extract] Implement `EX-ARGS` in `extract/src/args.cob`
- [ ] T0249 [US1-extract] Write test `extract/tests/test_ex_jar_find.cob` for `EX-JAR-FIND`: the search order of 22 §4.3 over a scratch game directory
- [ ] T0250 [US1-extract] Implement `EX-JAR-FIND` in `extract/src/jar-find.cob`
- [ ] T0251 [US1-extract] Write test `extract/tests/test_ex_check.cob` for `EX-CHECK` C1 to C5 (22 §4.2) over `contract/fixtures/extract/` reject archives: not a zip, wrong SHA-256, missing entries, each with its CCX code
- [ ] T0252 [US1-extract] Implement `EX-CHECK` in `extract/src/check.cob` (SHA-256 with `SHA256-*`, accepted row from `CONTENT-ACCEPTED-JAR`)
- [ ] T0253 [US1-extract] Write test `extract/tests/test_ex_plan.cob` for `EX-PLAN` (22 §6.3): the payload entry list, the counts, the destination paths
- [ ] T0254 [US1-extract] Implement `EX-PLAN` in `extract/src/plan.cob`
- [ ] T0255 [US1-extract] Write test `extract/tests/test_ex_walk.cob` for `EX-WALK` (22 §7.3 step 7): each planned entry reads with `ZIP-READ-RANGE`, passes its CRC check and is written under `<generated>.partial`
- [ ] T0256 [US1-extract] Implement `EX-WALK` in `extract/src/walk.cob`
- [ ] T0257 [US1-extract] Write test `extract/tests/test_ex_manifest.cob` for `EX-WRITE-MANIFEST` (22 §6.4) and `EX-WRITE-INDEX` (22 §6.5): byte format, sentinel `.cobolcraft-generated`
- [ ] T0258 [US1-extract] Implement `EX-WRITE-MANIFEST` and `EX-WRITE-INDEX` in `extract/src/manifest.cob`
- [ ] T0259 [US1-extract] Write test `extract/tests/test_ex_verify.cob` for `EX-VERIFY` (22 §7.6): full integrity check passes on a good tree and names the damaged file
- [ ] T0260 [US1-extract] Implement `EX-VERIFY` in `extract/src/verify.cob`
- [ ] T0261 [US1-extract] Write test `extract/tests/test_ex_main.cob` for `EX-MAIN`: idempotence (CCX-100, nothing rebuilt), `--force`, `--dry-run` writes nothing, the atomic swap `<generated>.partial` to `<generated>` (22 §7.5), exit statuses of 22 §7.4
- [ ] T0262 [US1-extract] Implement `EX-MAIN` in `extract/src/ex-main.cob` and the one-`CALL` `extract/src/main.cob`
- [ ] T0263 [US1-extract] Write acceptance test `extract/tests/acc_f2us1_real_jar.cob` (real input, fails loudly without the jar): scenarios US1-1 (the vanilla resource pack and data pack exist in the layout of 22 §5.2 with the T5 counts: 11,605 resource files, 9,779 data files, 106 feature files), US1-2 second run does nothing, an unrecognised jar is rejected (CCX-030 or CCX-031, nothing written) [FR-001, FR-002; SC-012]
- [ ] T0264 [US1-extract] Write edge-case test `extract/tests/test_ex_partial.cob` (spec edge case "the jar changes between runs"): a `.partial` left by an interrupted run is removed and rebuilt by the next run, a jar whose SHA-256 differs from the manifest's is rejected before anything is written, and `<generated>` is never half-written (22 §7.5)
- [ ] T0265 [US1-extract] Write acceptance test `extract/tests/acc_f2us1_git_clean.cob`: after a real run `git ls-files` lists no jar and no generated file (SC-012) [FR-001, FR-002]
- [ ] T0266 [US1-extract] Write contract test `extract/tests/contract_extract_provider.cob`: output tree and manifest against 22 §5.2, §6.4, §6.5 with the real jar
- [ ] T0267 [US1-extract] Write consumer-side test `extract/tests/contract_extract_content_consumer.cob` (the contract names it `contract_content_consumer_extract` in the content package; it lives in this lane so lanes stay disjoint): the tool's real output passes `CONTENT-PACKS-CHECK`; a tampered manifest gives `stale`, a removed sentinel `damaged`
- [ ] T0268 [US1-extract] Write consumer test `extract/tests/contract_formats_consumer.cob` calling `ZIP-*`, `CRC32`, `SHA256-*`, `FILE-*`, `DIR-*` the way the tool does
- [ ] T0269 [US1-extract] Write implementation tests in `extract/tests/test_extract_cover.cob` for lines of `extract/src` left unexecuted
- [ ] T0270 [US1-extract] Gate: run `make gate-extract` and record the command and real output

### Lane: core

#### Phase 28: US1-core — packs status

- [ ] T0271 [US1-core] Write test `core/tests/test_packs_status.cob` for `CORE-PACKS-STATUS`: it delegates to `CONTENT-PACKS-CHECK` and returns the status word and the English console reason of `docs/protocol/22-extraction-tool.md` §9.2 for each of the five statuses over `contract/fixtures/content/`
- [ ] T0272 [US1-core] Implement `CORE-PACKS-STATUS` in `core/src/packs-status.cob`
- [ ] T0273 [US1-core] Write consumer test `core/tests/contract_content_consumer.cob`: open a set through a fixture generated directory and assert the status words and one block lookup (`contracts/content-api.md` §4)
- [ ] T0274 [US1-core] Gate: run `make gate-core` and record the command and real output

#### Phase 29: US2-core — content re-base, world types, shared rules

**Goal**: one set of rule engines fed by either content set; the type stored in the world (FR-002 to FR-005, FR-037, FR-040, FR-041). **Independent Test**: `acc_f2us2_*` in core: type recorded and refused correctly; health 20, food 20, day 24,000, hurt window and fall damage from the shared rules.

- [ ] T0275 [US2-core] Write test `core/tests/test_cells.cob` for the `CELLS.cpy` layout: 2-byte state get and set, 4-bit light packing, sections derived from the dimension's `min_y` and `height` (24 in the overworld), three dimensions (`core/copy/CORESTATE.cpy` `CORE-MAX-DIMS` 3)
- [ ] T0276 [US2-core] Replace `core/copy/CHUNKMEM.cpy` by `contract/copy/CELLS.cpy` in `core/src/world.cob` and `core/copy/CORESTATE.cpy` (cell width, section count, `CORE-MAX-DIMS` 3)
- [ ] T0277 [US2-core] Write test `core/tests/test_chunks_stream24.cob`: the chunk packet the core builds for a case equals the 24-section fixture and loads through `PB-GET-CHUNK-24`
- [ ] T0278 [US2-core] Switch `core/src/chunks-stream.cob` to `PB-PUT-CHUNK-24`
- [ ] T0279 [US2-core] Write test `core/tests/test_block_lookup.cob`: world, blocks and worldgen code resolves block states only through `CONTENT-BLOCK-*` for both sets (no `ST-` or `BLK-` constants)
- [ ] T0280 [US2-core] Replace the `ST-` references in `core/src/blocks.cob`, `core/src/world.cob`, `core/src/worldgen.cob`, `core/src/chunks-stream.cob` by `CONTENT-*` lookups and delete `core/copy/BLOCKS.cpy`
- [ ] T0281 [US2-core] Replace the `ST-`/item/recipe/mob constants in `core/src/registries.cob`, `core/src/login.cob`, `core/src/config-phase.cob` by registries from `CONTENT-REGISTRY-*` and delete `core/copy/REGISTRY.cpy`, `ITEMS.cpy`, `RECIPES.cpy`, `MOBS.cpy`, `ENTITYTYPES.cpy` (the cobolcraft values now live in the content package's built-in layer)
- [ ] T0282 [US2-core] Replace the `ST-` references in `core/src/movement.cob`, `core/src/health.cob`, `core/src/hunger.cob`, `core/src/mobs.cob`, `core/src/players.cob`, `core/src/session.cob` by `CONTENT-*` lookups
- [ ] T0283 [US2-core] Replace the `ST-` references in `core/src/access.cob`, `core/src/api.cob`, `core/src/commands.cob` by `CONTENT-*` lookups
- [ ] T0284 [US2-core] Write test `core/tests/test_persistence_split.cob` for the folder layout of `docs/protocol/07-nbt-and-anvil.md` §9: `level.dat` with `WorldType`, `Seed`, `ContentJar`; up to three dimension folders; block states by key in palettes (WT-23: a foreign key is a defined outcome)
- [ ] T0285 [US2-core] Split `core/src/persistence.cob` (1,984 lines) into `core/src/level-data.cob` (level.dat), `core/src/player-data.cob`, `core/src/entity-data.cob` and `core/src/chunk-data.cob`, writing and reading blocks by key and covering all three dimensions
- [ ] T0286 [US2-core] Write contract tests (extended) `core/tests/contract_world_folder_provider.cob` and `core/tests/contract_coreapi_provider.cob` for the new keys, the three dimensions, the new settings and the re-derived `CORE-SETTINGS-SIZE`
- [ ] T0287 [US2-core] Write acceptance test `core/tests/acc_f2us2_world_type.cob`: scenarios US2-1/US2-3 (new world records its type; reopening yields the same type; a standard world with packs not `ok` is refused with the status word, FR-004; an old 001 world with no `WorldType` and no `dimensions/minecraft/` folder opens as cobolcraft; a folder with `dimensions/` and no `level.dat`, or standard folders and no `WorldType`, is refused, `docs/design/world-types.md` §2.1 rules 2 and 3, WT-24) [SC-011]
- [ ] T0288 [US2-core] Implement `CORE-WORLD-OPEN` type handling, the new statuses and `CS-WORLD-TYPE`, `CS-GENERATED-DIR`, `CS-GAME-DIR` in `core/src/api.cob` and `core/src/level-data.cob`
- [ ] T0289 [US2-core] Write edge-case test `core/tests/acc_f2us2_packs_changed.cob` (spec edge case, `docs/design/world-types.md` WT-6, WT-24): a standard world opened after the generated packs were deleted is refused with the reason; opened after they were rebuilt from the accepted jar it opens, and `ContentJar` is informational (no refusal) [FR-003, FR-004, FR-005, FR-037; SC-011]
- [ ] T0290 [US2-core] Write test `core/tests/test_seed_text.cob` for `CS-SEED-TEXT` to seed with the worked examples of Round SEED (empty text gives a random seed)
- [ ] T0291 [US2-core] Implement the seed text rule in `core/src/seed-text.cob`
- [ ] T0292 [US2-core] Write acceptance test `core/tests/acc_f2us2_shared_rules.cob` (US2-4): max health 20, food 20, the hit window and hurt cooldown, fall damage and exhaustion of `docs/protocol/13`/`17`/`18` apply in both types; day length 24,000 ticks (33) [FR-003, FR-004, FR-005, FR-037; SC-011]
- [ ] T0293 [US2-core] Make `acc_f2us2_shared_rules` pass: delete the stand-in constants in `core/copy/RULES.cpy`, the `CW-TIME` range in `core/copy/CORESTATE.cpy` and the stand-in branches of `core/src/health.cob`, `core/src/hunger.cob`, `core/src/movement.cob`, `core/src/world.cob`
- [ ] T0294 [US2-core] Write test `core/tests/test_time_rebase.cob`: an old world's `level.dat` time values re-base onto the standard timeline of 33 when it opens (data-model §6)
- [ ] T0295 [US2-core] Implement the time re-base in `core/src/level-data.cob`
- [ ] T0296 [US2-core] Write test `core/tests/test_ground_items_shared.cob`: ground items follow `docs/protocol/41-item-entity-physics.md` (pickup delay, merging, despawn, physics) in both types
- [ ] T0297 [US2-core] Make the ground item engine follow 41 in `core/src/ground-items.cob`
- [ ] T0298 [US2-core] Write test `core/tests/test_weather_shared.cob`: the weather mechanism of 33 for both types (`CS-WEATHER-CHANGES` maps to the gamerule)
- [ ] T0299 [US2-core] Make the weather engine follow 33 in `core/src/weather.cob`
- [ ] T0300 [US2-core] Write implementation tests in `core/tests/test_us2_cover.cob` for the lines of the files above that the tests leave unexecuted
- [ ] T0301 [US2-core] Gate: run `make gate-core` and record the command and real output

#### Phase 30: US7-core — survival abilities

- [ ] T0302 [US7-core] Write acceptance test `core/tests/acc_f2us7_abilities.cob` (US7-2): `PLAY-ABILITIES-BUILD` grants the flight flags only in creative and spectator and never in survival or adventure (`docs/protocol/13` §1.4); a client request to start flying in survival is ignored and the next Player Abilities states not flying. If the client lane's US7 reproduction finds a core cause of the survival climb (P-client-5) this phase escalates to multi-package: stop and return to the orchestrator [FR-016, FR-017; SC-004]
- [ ] T0303 [US7-core] Gate: run `make gate-core` and record the command and real output

#### Phase 31: US8-core — break progress and stages

- [ ] T0304 [US8-core] Write test `core/tests/test_break_progress.cob`: progress per tick from the formula of `docs/protocol/13` §2.1 (hardness, tool speed, tier, effects, on-ground, in-water) with the worked examples of §9
- [ ] T0305 [US8-core] Implement the progress formula in `core/src/breaking.cob`
- [ ] T0306 [US8-core] Write edge-case test `core/tests/test_break_interrupted.cob` (spec edge case): break progress resets and sends stage -1 when the held item changes, when the target block changes, and when another player breaks the block first (13 §2.4)
- [ ] T0307 [US8-core] Write edge-case test `core/tests/test_break_many.cob` (spec edge case): several players break different blocks at once and each stage goes only to the players who can see that block, per block
- [ ] T0308 [US8-core] Write test `core/tests/test_break_sequence.cob`: Player Action start, abort and finish handling with sequence ids and acknowledgements (13 §2.3), a changed held item or target aborts
- [ ] T0309 [US8-core] Implement the sequence handling in `core/src/breaking.cob`
- [ ] T0310 [US8-core] Write acceptance test `core/tests/acc_f2us8_destroy_stage.cob` (US8-1 to US8-3): Block Destruction stage 0 to 9 goes to the breaker and to other players who can see the block; abort and finish send stage -1; a block broken by another player ends the progress (13 §2.4) [FR-023; SC-006]
- [ ] T0311 [US8-core] Implement the stage broadcast in `core/src/breaking.cob`
- [ ] T0312 [US8-core] Write contract tests in `core/tests/contract_wire_server.cob` for the Block Destruction fixture
- [ ] T0313 [US8-core] Gate: run `make gate-core` and record the command and real output

#### Phase 32: US9-core — inventory menu, crafting, recipe book

- [ ] T0314 [US9-core] Write test `core/tests/test_inventory_menu.cob`: the 46-slot inventory menu (2x2 grid, result, armor, off-hand slot 45; `docs/protocol/40-menus-1-model-and-containers.md`, 12 §5.6a) with Container Click modes (pickup, quick move, swap, throw, drag, double click)
- [ ] T0315 [US9-core] Implement the inventory menu in `core/src/menu-inventory.cob` and the shared menu model in `core/src/menus.cob`, replacing the stand-in logic of `core/src/inventory.cob`
- [ ] T0316 [US9-core] Write test `core/tests/test_crafting_match.cob`: shaped (mirror, trimmed), shapeless and special matching and the result slot over a 2x2 and a 3x3 grid (13 §3.2, §3.3) with the recipes from `CONTENT` for both sets
- [ ] T0317 [US9-core] Implement crafting matching in `core/src/crafting-match.cob`
- [ ] T0318 [US9-core] Write acceptance test `core/tests/acc_f2us9_take_result.cob` (US9-1): taking the result consumes one of each ingredient, shift-click crafts repeatedly, leftover items (13 §3.6) [FR-024, FR-025, FR-028; SC-005]
- [ ] T0319 [US9-core] Implement result taking in `core/src/crafting-match.cob`
- [ ] T0320 [US9-core] Write test `core/tests/test_recipe_unlock.cob`: recipe unlocks by ingredient pickup and advancement-free conditions (27) and Recipe Book Add/Remove/Settings/Seen handling
- [ ] T0321 [US9-core] Implement recipe unlocks in `core/src/recipe-unlock.cob`
- [ ] T0322 [US9-core] Write test `core/tests/test_place_recipe.cob`: Place Recipe fills the grid from the inventory with the choice of ingredients of 13 §3.8, replacing what is in the grid (US9-2)
- [ ] T0323 [US9-core] Implement Place Recipe in `core/src/recipe-unlock.cob`
- [ ] T0324 [US9-core] Write edge-case test `core/tests/test_recipe_book_edges.cob` (spec edge case): a recipe book with no known recipes lists none; a bench-only recipe opened in the 2x2 inventory is shown unavailable; Place Recipe with a full inventory returns what the grid held without losing items and reports the failure per 13 §3.8
- [ ] T0325 [US9-core] Write test `core/tests/test_creative_throw.cob` (CC-0006): in creative a stack carried by the cursor and clicked outside the window becomes a ground item through Set Creative Mode Slot with the drop flag
- [ ] T0326 [US9-core] Make the creative cursor throw work in `core/src/inventory.cob` (CC-0006)
- [ ] T0327 [US9-core] Remove the 001 crafting module programs `CRAFT-TRY`, `CRAFT-BOOK-BUILD`, `CRAFT-BOOK-SEND`, `CRAFT-PLACE` from `core/src/crafting.cob` and their tests (FR-028), keeping nothing the new modules do not use
- [ ] T0328 [US9-core] Write contract tests in `core/tests/contract_wire_server.cob` for the container and recipe-book fixtures
- [ ] T0329 [US9-core] Gate: run `make gate-core` and record the command and real output

#### Phase 33: US10-core — crafting bench menu

- [ ] T0330 [US10-core] Write test `core/tests/test_bench_menu.cob`: Use Item On a placed bench opens the 3x3 menu (12 §5.6b, 13 §3.5); a recipe that needs the large grid matches only in the bench menu (US10-3); the bench block places as an item
- [ ] T0331 [US10-core] Implement the bench menu and block interaction in `core/src/menu-bench.cob`
- [ ] T0332 [US10-core] Gate: run `make gate-core` and record the command and real output

#### Phase 34: US11-core (a) — chunk generation queue and the cost measurement

- [ ] T0333 [US11-core] Write test `core/tests/test_gen_queue.cob`: the chunk generation queue orders wanted chunks nearest first and obeys the per-tick budget (R12)
- [ ] T0334 [US11-core] Implement the generation queue in `core/src/gen-queue.cob` and run it from `CORE-TICK` in `core/src/api.cob`
- [ ] T0335 [US11-core] Measure one generated chunk with the `cc_f64` noise path (Risk R-P, first US11 task): add `core/tests/test_gen_cost.cob` that prints the elapsed time of one chunk and fails when it exceeds the per-tick budget recorded in `specs/002-client-polish/research.md` R12 (a result above the budget goes back to the plan, not to a hack)
- [ ] T0336 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 35: US11-core (b) — random sources, noise, climate, biome source

- [ ] T0337 [US11-core] Write test `core/tests/test_random_sources.cob`: positional random splitters and seed forks of `docs/protocol/10-world-generation-terrain.md` with the worked examples (extends `core/src/rng.cob`)
- [ ] T0338 [US11-core] Implement them in `core/src/rng.cob`
- [ ] T0339 [US11-core] Write test `core/tests/test_noise.cob`: improved/perlin noise, octave and normal noise via `cc_f64_*` match the worked examples bit for bit (10)
- [ ] T0340 [US11-core] Implement the noises in `core/src/noise.cob`
- [ ] T0341 [US11-core] Write test `core/tests/test_climate.cob`: the six climate parameters at sample points and the multi-noise biome lookup (10, 37 part 3)
- [ ] T0342 [US11-core] Implement climate and the biome source in `core/src/climate.cob`
- [ ] T0343 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 36: US11-core (c) — density, aquifers, surface

- [ ] T0344 [US11-core] Write test `core/tests/test_density.cob`: the density function graph evaluation, cell interpolation and final density at sample points (10, 37 part 2)
- [ ] T0345 [US11-core] Implement density evaluation in `core/src/density.cob`
- [ ] T0346 [US11-core] Write test `core/tests/test_terrain_fill.cob`: the stone/water/air fill of a chunk from final density with the worked example columns
- [ ] T0347 [US11-core] Implement the terrain fill in `core/src/terrain.cob`
- [ ] T0348 [US11-core] Write test `core/tests/test_aquifer.cob`: aquifer fluid level and barrier decisions (10)
- [ ] T0349 [US11-core] Implement aquifers in `core/src/aquifer.cob`
- [ ] T0350 [US11-core] Write test `core/tests/test_surface_rules.cob`: the surface rule evaluation for badlands, desert, ocean floors and the default (10, 37 part 4)
- [ ] T0351 [US11-core] Implement surface rules in `core/src/surface.cob`
- [ ] T0352 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 37: US11-core (d) — carvers and caves

- [ ] T0353 [US11-core] Write test `core/tests/test_carvers.cob`: the cave and canyon carvers over the documented seed and chunk with the worked examples (11)
- [ ] T0354 [US11-core] Implement the carvers in `core/src/carvers.cob`
- [ ] T0355 [US11-core] Write test `core/tests/test_noise_caves.cob`: the large cavern, long tunnel and thin noodle passages from the density router (US11-1; 11)
- [ ] T0356 [US11-core] Implement the noise caves in `core/src/noise-caves.cob`
- [ ] T0357 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 38: US11-core (e) — ores and ore drops

- [ ] T0358 [US11-core] Write acceptance test `core/tests/acc_f2us11_ores.cob` (US11-2): each ore's height distribution (uniform or triangle), vein size and count per chunk, depth and biome limits (11) [FR-029, FR-030; SC-007]
- [ ] T0359 [US11-core] Implement ore placement in `core/src/ores.cob`
- [ ] T0360 [US11-core] Write edge-case test `core/tests/test_ore_edges.cob` (spec edge case): an ore exposed in a cave or aquifer keeps its exposure rule (11), and a vein crossing a chunk border is placed identically from either chunk
- [ ] T0361 [US11-core] Write test `core/tests/test_ore_veins.cob`: the large ore vein and the copper/iron vein noise of 11
- [ ] T0362 [US11-core] Implement the large veins in `core/src/ores.cob`
- [ ] T0363 [US11-core] Write acceptance test `core/tests/acc_f2us11_ore_drops.cob` (US11-3): ore blocks broken in survival drop their items through the loot tables (11 §9, 26) [FR-029, FR-030; SC-007]
- [ ] T0364 [US11-core] Implement the loot engine of 26 (conditions, functions, rolls) in `core/src/loot.cob`
- [ ] T0365 [US11-core] Implement block drops from loot tables in `core/src/block-drops.cob`
- [ ] T0366 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 39: US11-core (f) — generation pipeline and the 24-section stream

- [ ] T0367 [US11-core] Write acceptance test `core/tests/acc_f2us11_world.cob` (US11-1): a fixed-seed standard world generates a chunk whose columns equal the worked examples of 10 and 11, including the status order and neighbour requirements [FR-029, FR-030; SC-007]
- [ ] T0368 [US11-core] Implement the generation pipeline that calls biome, density, aquifer, surface, carver and ore stages in `core/src/worldgen-standard.cob`, selected by world type (the cobolcraft type keeps `core/src/worldgen.cob`, FR-033)
- [ ] T0369 [US11-core] Write contract tests `core/tests/contract_vanilla_chunk.cob`: the chunk data of a standard world equals the bytes of the 06 worked examples (the automated half of Q-1)
- [ ] T0370 [US11-core] Make the generated chunk stream pass `contract_vanilla_chunk` in `core/src/chunks-stream.cob`
- [ ] T0371 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 40: US12-core (a) — block updates and fluids

- [ ] T0372 [US12-core] Write test `core/tests/test_block_updates.cob`: placement rules, neighbour updates, scheduled ticks and their order (`docs/protocol/29-block-updates-and-placement.md`)
- [ ] T0373 [US12-core] Implement block updates in `core/src/block-updates.cob`
- [ ] T0374 [US12-core] Write test `core/tests/test_fluids.cob`: water and lava flow, sources, falling, mixing, drain (`29a-fluids.md`)
- [ ] T0375 [US12-core] Implement fluids in `core/src/fluids.cob`
- [ ] T0376 [US12-core] Write test `core/tests/test_world_tick_order.cob`: the tick order of 33 (updates, fluids, growth, redstone)
- [ ] T0377 [US12-core] Implement the ordered world tick in `core/src/world-tick.cob`
- [ ] T0378 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 41: US12-core (b) — falling blocks, growth, fire

- [ ] T0379 [US12-core] Write test `core/tests/test_falling_gravity.cob`: falling blocks, gravity, bonemeal (`29b-falling-growth-fire-1-model-gravity-bonemeal.md`)
- [ ] T0380 [US12-core] Implement them in `core/src/falling.cob`
- [ ] T0381 [US12-core] Write test `core/tests/test_growth_crops.cob`: crops and stems (29b part 2) and growing plants (part 4), including the light dependency of D-light (`32-light-engine.md`)
- [ ] T0382 [US12-core] Implement crop and plant growth in `core/src/growth.cob`
- [ ] T0383 [US12-core] Write test `core/tests/test_spread_decay.cob`: spread, decay, snow and ice (29b part 3)
- [ ] T0384 [US12-core] Implement spread and decay in `core/src/spread.cob`
- [ ] T0385 [US12-core] Write test `core/tests/test_special_growth.cob`: fungi, moss, copper (part 5), sculk, amethyst, dripstone (part 6), aquatic eggs, honey, cauldron (part 7)
- [ ] T0386 [US12-core] Implement them in `core/src/growth-special.cob`
- [ ] T0387 [US12-core] Write test `core/tests/test_fire_tnt.cob`: fire spread and burn-out, TNT and the residual rules (29b part 8)
- [ ] T0388 [US12-core] Implement fire and TNT in `core/src/fire.cob`
- [ ] T0389 [US12-core] Write test `core/tests/test_light_engine.cob`: the server light engine as far as gameplay and the chunk packets need it (`32-light-engine.md`, D-light)
- [ ] T0390 [US12-core] Replace `core/src/light.cob` with the engine of 32
- [ ] T0391 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 42: US12-core (c) — redstone

- [ ] T0392 [US12-core] Write test `core/tests/test_redstone_wire.cob`: signal model and wire (`30-redstone-1-model-signal-and-wire.md`)
- [ ] T0393 [US12-core] Implement them in `core/src/redstone-wire.cob`
- [ ] T0394 [US12-core] Write test `core/tests/test_redstone_logic.cob`: repeaters, comparators, observers (30 part 2)
- [ ] T0395 [US12-core] Implement them in `core/src/redstone-logic.cob`
- [ ] T0396 [US12-core] Write test `core/tests/test_pistons.cob`: pistons and slime/honey pushing, push reactions (30 part 3)
- [ ] T0397 [US12-core] Implement pistons in `core/src/pistons.cob`
- [ ] T0398 [US12-core] Write test `core/tests/test_redstone_devices.cob`: dispensers, droppers, hoppers, crafters (30 part 4)
- [ ] T0399 [US12-core] Implement them in `core/src/redstone-devices.cob`
- [ ] T0400 [US12-core] Write test `core/tests/test_redstone_inputs.cob`: switches, plates, sensors, note blocks (30 part 5)
- [ ] T0401 [US12-core] Implement them in `core/src/redstone-inputs.cob`
- [ ] T0402 [US12-core] Write test `core/tests/test_rails.cob`: rails and minecart-related rules (30 part 6)
- [ ] T0403 [US12-core] Implement rails in `core/src/rails.cob`
- [ ] T0404 [US12-core] Write test `core/tests/test_redstone_blocks.cob`: doors, lamps, bulbs, TNT activation (30 part 7), tripwire, sculk sensors, bells, vibration (part 8)
- [ ] T0405 [US12-core] Implement them in `core/src/redstone-blocks.cob`
- [ ] T0406 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 43: US12-core (d) — block entities and menus

- [ ] T0407 [US12-core] Write test `core/tests/test_block_entities_model.cob`: shared block entity model, containers and their NBT (`31-block-entities-1-shared-model-and-containers.md`)
- [ ] T0408 [US12-core] Implement it in `core/src/block-entities.cob`
- [ ] T0409 [US12-core] Write test `core/tests/test_furnaces.cob`: processing and redstone containers (31 part 2): furnaces, brewing, crafter
- [ ] T0410 [US12-core] Implement them in `core/src/be-processing.cob`
- [ ] T0411 [US12-core] Write test `core/tests/test_be_signs.cob`: signs, banners, skulls, pots, shelves (31 part 3)
- [ ] T0412 [US12-core] Implement them in `core/src/be-decor.cob`
- [ ] T0413 [US12-core] Write test `core/tests/test_be_interactive.cob`: jukebox, lectern, bell, campfire, brushable, beehive (31 part 4)
- [ ] T0414 [US12-core] Implement them in `core/src/be-interactive.cob`
- [ ] T0415 [US12-core] Write test `core/tests/test_be_world.cob`: beacon, conduit, end piston, creaking (31 part 5), command, structure, jigsaw, test blocks (part 6) with `TestInstanceBlockEditScreen` per Round TIBE
- [ ] T0416 [US12-core] Implement them in `core/src/be-world.cob`
- [ ] T0417 [US12-core] Write test `core/tests/test_be_spawners.cob`: spawners, trial spawners, vaults (31 part 7), sculk and remaining types (part 8)
- [ ] T0418 [US12-core] Implement them in `core/src/be-spawners.cob`
- [ ] T0419 [US12-core] Write test `core/tests/test_menus_machines.cob`: furnace, brewing, crafter, anvil, grindstone, smithing menus (`40-menus-2-furnaces-brewing-crafter.md`, `40-menus-3-anvil-grindstone-smithing.md`)
- [ ] T0420 [US12-core] Implement them in `core/src/menu-machines.cob`
- [ ] T0421 [US12-core] Write test `core/tests/test_menus_other.cob`: enchanting, loom, stonecutter, cartography (40 part 4), merchant, beacon, lectern (part 5), mount inventories (part 6), creative inventory (part 7), book and sign editors (part 8), continuation (x1)
- [ ] T0422 [US12-core] Implement them in `core/src/menu-other.cob`
- [ ] T0423 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 44: US12-core (e) — features and structures

- [ ] T0424 [US12-core] Write test `core/tests/test_features_model.cob`: feature model, placement modifiers, predicates and providers (`35-worldgen-features-1-model-and-placement.md`, `-2-predicates-and-providers.md`)
- [ ] T0425 [US12-core] Implement them in `core/src/features.cob`
- [ ] T0426 [US12-core] Write test `core/tests/test_tree_placers.cob`: tree placers (35 part 3) with the documented trees
- [ ] T0427 [US12-core] Implement tree placers in `core/src/trees.cob`
- [ ] T0428 [US12-core] Write test `core/tests/test_vegetation_lakes.cob`: decorators and vegetation (35 part 4), water and surface features including lakes (part 5)
- [ ] T0429 [US12-core] Implement them in `core/src/vegetation.cob`
- [ ] T0430 [US12-core] Write test `core/tests/test_underground_features.cob`: underground features (35 part 6) and Nether/End misc features (part 7)
- [ ] T0431 [US12-core] Implement them in `core/src/features-underground.cob`
- [ ] T0432 [US12-core] Write acceptance test `core/tests/acc_f2us12_features.cob` (US12-1): a generated overworld area contains trees, vegetation and lakes placed by the decoration order [FR-031, FR-032, FR-038]
- [ ] T0433 [US12-core] Wire the decoration stage into the pipeline in `core/src/worldgen-standard.cob`
- [ ] T0434 [US12-core] Write test `core/tests/test_structure_starts.cob`: structure model, placement, starts (`36-structures-1-model-placement-starts.md`, `44-residual-mob-questions-2-spawning-structures.md`)
- [ ] T0435 [US12-core] Implement structure starts in `core/src/structure-starts.cob`
- [ ] T0436 [US12-core] Write test `core/tests/test_templates_jigsaw.cob`: templates and processors (36 part 2), jigsaw assembly (part 3)
- [ ] T0437 [US12-core] Implement templates and jigsaw in `core/src/jigsaw.cob`
- [ ] T0438 [US12-core] Write test `core/tests/test_structures_small.cob`: scattered and small structures (36 part 4), mineshaft and stronghold (part 5)
- [ ] T0439 [US12-core] Implement them in `core/src/structures-small.cob`
- [ ] T0440 [US12-core] Write test `core/tests/test_structures_big.cob`: ocean (36 part 6), woodland mansion (part 7), villages and outposts (part 9), ancient city, trial chambers, trail ruins (part 10)
- [ ] T0441 [US12-core] Implement them in `core/src/structures-big.cob`
- [ ] T0442 [US12-core] Write acceptance test `core/tests/acc_f2us12_structures.cob` (US12-2): a fixed-seed standard world places a village or other documented structure at the documented position [FR-031, FR-032, FR-038]
- [ ] T0443 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 45: US12-core (f) — Nether, End and portals

- [ ] T0444 [US12-core] Write test `core/tests/test_nether_rules.cob`: dimension rules, noise settings and density, biome source and climate (`37-nether-1-...` to `-3-...`)
- [ ] T0445 [US12-core] Implement the Nether terrain in `core/src/nether.cob`
- [ ] T0446 [US12-core] Write test `core/tests/test_nether_decor.cob`: surface rules, carvers, features and decoration, structures, spawns and hooks (37 parts 4 to 6)
- [ ] T0447 [US12-core] Implement them in `core/src/nether-decor.cob`
- [ ] T0448 [US12-core] Write test `core/tests/test_end.cob`: the End islands, outer islands, dragon fight and crystals (`38-end.md`)
- [ ] T0449 [US12-core] Implement the End in `core/src/end.cob`
- [ ] T0450 [US12-core] Write acceptance test `core/tests/acc_f2us12_portals.cob` (US12-3): Nether portal frame detection, linking and travel with coordinate scaling, End portal and exit (`39-portals.md`), Respawn/Login packets per dimension [FR-031, FR-032, FR-038]
- [ ] T0451 [US12-core] Implement portals and dimension travel in `core/src/portals.cob`
- [ ] T0452 [US12-core] Write acceptance test `core/tests/acc_f2us12_redstone.cob` (US12-4): a documented redstone circuit behaves as in its worked example [FR-031, FR-032, FR-038]
- [ ] T0453 [US12-core] Write contract tests `core/tests/contract_wire_server.cob` additions for the level event, particle and three-dimension login fixtures
- [ ] T0454 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 46: US13-core — command framework and catalog

- [ ] T0455 [US13-core] Write test `core/tests/test_cmd_parse.cob`: tokenising and parsing of `docs/protocol/15a-brigadier-command-library.md` and 15 §4, coordinates (§8)
- [ ] T0456 [US13-core] Create `core/src/cmd-parse.cob` (split from `core/src/commands.cob`) implementing it
- [ ] T0457 [US13-core] Write test `core/tests/test_cmd_tree.cob`: the command tree with permission-level filtering (levels 0 to 4, README Part 7 decision 8) and the Commands packet nodes (15 §2, §3)
- [ ] T0458 [US13-core] Create `core/src/cmd-tree.cob` implementing it
- [ ] T0459 [US13-core] Write test `core/tests/test_cmd_args.cob`: argument types (15 §6), blocks, items, text, NBT (§9)
- [ ] T0460 [US13-core] Create `core/src/cmd-args.cob` implementing them
- [ ] T0461 [US13-core] Write test `core/tests/test_selectors.cob`: entity selectors (15 §7)
- [ ] T0462 [US13-core] Create `core/src/selectors.cob` implementing them
- [ ] T0463 [US13-core] Write test `core/tests/test_cmd_execute.cob`: execution, result values and the `execute` grammar (15 §10, §11), functions (§12)
- [ ] T0464 [US13-core] Create `core/src/cmd-exec.cob` implementing them
- [ ] T0465 [US13-core] Write test `core/tests/test_cmd_suggest.cob`: suggestions and completion (15 §14) for both sets
- [ ] T0466 [US13-core] Create `core/src/cmd-suggest.cob` implementing them
- [ ] T0467 [US13-core] Write test `core/tests/test_cmd_messages.cob`: framework translation keys and failure messages (15 §5)
- [ ] T0468 [US13-core] Create `core/src/cmd-messages.cob` implementing them
- [ ] T0469 [US13-core] Write test `core/tests/test_cmd_advancement.cob` for `/advancement` (`docs/protocol/16-commands-catalog.md` §6.6, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /advancement ` (FR-034, SC-008)
- [ ] T0470 [US13-core] Implement `/advancement` in `core/src/cmds-items.cob` so its test passes (create the file with the first command of its group)
- [ ] T0471 [US13-core] Write test `core/tests/test_cmd_attribute.cob` for `/attribute` (`docs/protocol/16-commands-catalog.md` §5.12, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /attribute ` (FR-034, SC-008)
- [ ] T0472 [US13-core] Implement `/attribute` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0473 [US13-core] Write test `core/tests/test_cmd_ban.cob` for `/ban` (`docs/protocol/16-commands-catalog.md` §11.3, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /ban ` (FR-034, SC-008)
- [ ] T0474 [US13-core] Implement `/ban` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0475 [US13-core] Write test `core/tests/test_cmd_ban_ip.cob` for `/ban-ip` (`docs/protocol/16-commands-catalog.md` §11.4, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /ban-ip ` (FR-034, SC-008)
- [ ] T0476 [US13-core] Implement `/ban-ip` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0477 [US13-core] Write test `core/tests/test_cmd_banlist.cob` for `/banlist` (`docs/protocol/16-commands-catalog.md` §11.7, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /banlist ` (FR-034, SC-008)
- [ ] T0478 [US13-core] Implement `/banlist` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0479 [US13-core] Write test `core/tests/test_cmd_bossbar.cob` for `/bossbar` (`docs/protocol/16-commands-catalog.md` §8.7, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /bossbar ` (FR-034, SC-008)
- [ ] T0480 [US13-core] Implement `/bossbar` in `core/src/cmds-chat.cob` so its test passes (create the file with the first command of its group)
- [ ] T0481 [US13-core] Write test `core/tests/test_cmd_chase.cob` for `/chase` (`docs/protocol/16-commands-catalog.md` §12, permission level 0 (dev, `DEBUG_CHASE_COMMAND`)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /chase ` (FR-034, SC-008)
- [ ] T0482 [US13-core] Implement `/chase` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0483 [US13-core] Write test `core/tests/test_cmd_clear.cob` for `/clear` (`docs/protocol/16-commands-catalog.md` §6.2, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /clear ` (FR-034, SC-008)
- [ ] T0484 [US13-core] Implement `/clear` in `core/src/cmds-items.cob` so its test passes (create the file with the first command of its group)
- [ ] T0485 [US13-core] Write test `core/tests/test_cmd_clone.cob` for `/clone` (`docs/protocol/16-commands-catalog.md` §7.4, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /clone ` (FR-034, SC-008)
- [ ] T0486 [US13-core] Implement `/clone` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0487 [US13-core] Write test `core/tests/test_cmd_compute.cob` for `/compute` (`docs/protocol/16-commands-catalog.md` §10.9, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /compute ` (FR-034, SC-008)
- [ ] T0488 [US13-core] Implement `/compute` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0489 [US13-core] Write test `core/tests/test_cmd_damage.cob` for `/damage` (`docs/protocol/16-commands-catalog.md` §5.7, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /damage ` (FR-034, SC-008)
- [ ] T0490 [US13-core] Implement `/damage` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0491 [US13-core] Write test `core/tests/test_cmd_data.cob` for `/data` (`docs/protocol/16-commands-catalog.md` §10.1, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /data ` (FR-034, SC-008)
- [ ] T0492 [US13-core] Implement `/data` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0493 [US13-core] Write test `core/tests/test_cmd_datapack.cob` for `/datapack` (`docs/protocol/16-commands-catalog.md` §10.11, permission level 2 (`create`: 4)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /datapack ` (FR-034, SC-008)
- [ ] T0494 [US13-core] Implement `/datapack` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0495 [US13-core] Write test `core/tests/test_cmd_debug.cob` for `/debug` (`docs/protocol/16-commands-catalog.md` §11.19, permission level 3): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /debug ` (FR-034, SC-008)
- [ ] T0496 [US13-core] Implement `/debug` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0497 [US13-core] Write test `core/tests/test_cmd_debugconfig.cob` for `/debugconfig` (`docs/protocol/16-commands-catalog.md` §12, permission level 3 (dev, dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /debugconfig ` (FR-034, SC-008)
- [ ] T0498 [US13-core] Implement `/debugconfig` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0499 [US13-core] Write test `core/tests/test_cmd_debugmobspawning.cob` for `/debugmobspawning` (`docs/protocol/16-commands-catalog.md` §12, permission level 2 (dev)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /debugmobspawning ` (FR-034, SC-008)
- [ ] T0500 [US13-core] Implement `/debugmobspawning` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0501 [US13-core] Write test `core/tests/test_cmd_debugpath.cob` for `/debugpath` (`docs/protocol/16-commands-catalog.md` §12, permission level 2 (dev)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /debugpath ` (FR-034, SC-008)
- [ ] T0502 [US13-core] Implement `/debugpath` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0503 [US13-core] Write test `core/tests/test_cmd_defaultgamemode.cob` for `/defaultgamemode` (`docs/protocol/16-commands-catalog.md` §4.2, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /defaultgamemode ` (FR-034, SC-008)
- [ ] T0504 [US13-core] Implement `/defaultgamemode` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0505 [US13-core] Write test `core/tests/test_cmd_deop.cob` for `/deop` (`docs/protocol/16-commands-catalog.md` §11.2, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /deop ` (FR-034, SC-008)
- [ ] T0506 [US13-core] Implement `/deop` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0507 [US13-core] Write test `core/tests/test_cmd_dialog.cob` for `/dialog` (`docs/protocol/16-commands-catalog.md` §8.10, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /dialog ` (FR-034, SC-008)
- [ ] T0508 [US13-core] Implement `/dialog` in `core/src/cmds-chat.cob` so its test passes (create the file with the first command of its group)
- [ ] T0509 [US13-core] Write test `core/tests/test_cmd_difficulty.cob` for `/difficulty` (`docs/protocol/16-commands-catalog.md` §4.3, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /difficulty ` (FR-034, SC-008)
- [ ] T0510 [US13-core] Implement `/difficulty` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0511 [US13-core] Write test `core/tests/test_cmd_effect.cob` for `/effect` (`docs/protocol/16-commands-catalog.md` §5.10, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /effect ` (FR-034, SC-008)
- [ ] T0512 [US13-core] Implement `/effect` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0513 [US13-core] Write test `core/tests/test_cmd_enchant.cob` for `/enchant` (`docs/protocol/16-commands-catalog.md` §5.11, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /enchant ` (FR-034, SC-008)
- [ ] T0514 [US13-core] Implement `/enchant` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0515 [US13-core] Write test `core/tests/test_cmd_execute.cob` for `/execute` (`docs/protocol/16-commands-catalog.md` §10.2, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /execute ` (FR-034, SC-008)
- [ ] T0516 [US13-core] Implement `/execute` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0517 [US13-core] Write test `core/tests/test_cmd_fetchprofile.cob` for `/fetchprofile` (`docs/protocol/16-commands-catalog.md` §11.20, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /fetchprofile ` (FR-034, SC-008)
- [ ] T0518 [US13-core] Implement `/fetchprofile` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0519 [US13-core] Write test `core/tests/test_cmd_fill.cob` for `/fill` (`docs/protocol/16-commands-catalog.md` §7.2, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /fill ` (FR-034, SC-008)
- [ ] T0520 [US13-core] Implement `/fill` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0521 [US13-core] Write test `core/tests/test_cmd_fillbiome.cob` for `/fillbiome` (`docs/protocol/16-commands-catalog.md` §7.3, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /fillbiome ` (FR-034, SC-008)
- [ ] T0522 [US13-core] Implement `/fillbiome` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0523 [US13-core] Write test `core/tests/test_cmd_forceload.cob` for `/forceload` (`docs/protocol/16-commands-catalog.md` §7.6, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /forceload ` (FR-034, SC-008)
- [ ] T0524 [US13-core] Implement `/forceload` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0525 [US13-core] Write test `core/tests/test_cmd_function.cob` for `/function` (`docs/protocol/16-commands-catalog.md` §10.3, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /function ` (FR-034, SC-008)
- [ ] T0526 [US13-core] Implement `/function` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0527 [US13-core] Write test `core/tests/test_cmd_gamemode.cob` for `/gamemode` (`docs/protocol/16-commands-catalog.md` §4.1, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /gamemode ` (FR-034, SC-008)
- [ ] T0528 [US13-core] Implement `/gamemode` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0529 [US13-core] Write test `core/tests/test_cmd_gamerule.cob` for `/gamerule` (`docs/protocol/16-commands-catalog.md` §4.4 / 13, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /gamerule ` (FR-034, SC-008)
- [ ] T0530 [US13-core] Implement `/gamerule` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0531 [US13-core] Write test `core/tests/test_cmd_give.cob` for `/give` (`docs/protocol/16-commands-catalog.md` §6.1, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /give ` (FR-034, SC-008)
- [ ] T0532 [US13-core] Implement `/give` in `core/src/cmds-items.cob` so its test passes (create the file with the first command of its group)
- [ ] T0533 [US13-core] Write test `core/tests/test_cmd_help.cob` for `/help` (`docs/protocol/16-commands-catalog.md` §8.6, permission level 0): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /help ` (FR-034, SC-008)
- [ ] T0534 [US13-core] Implement `/help` in `core/src/cmds-chat.cob` so its test passes (create the file with the first command of its group)
- [ ] T0535 [US13-core] Write test `core/tests/test_cmd_item.cob` for `/item` (`docs/protocol/16-commands-catalog.md` §6.3, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /item ` (FR-034, SC-008)
- [ ] T0536 [US13-core] Implement `/item` in `core/src/cmds-items.cob` so its test passes (create the file with the first command of its group)
- [ ] T0537 [US13-core] Write test `core/tests/test_cmd_jfr.cob` for `/jfr` (`docs/protocol/16-commands-catalog.md` §11.18, permission level 4 (if JFR available)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /jfr ` (FR-034, SC-008)
- [ ] T0538 [US13-core] Implement `/jfr` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0539 [US13-core] Write test `core/tests/test_cmd_kick.cob` for `/kick` (`docs/protocol/16-commands-catalog.md` §11.8, permission level 3): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /kick ` (FR-034, SC-008)
- [ ] T0540 [US13-core] Implement `/kick` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0541 [US13-core] Write test `core/tests/test_cmd_kill.cob` for `/kill` (`docs/protocol/16-commands-catalog.md` §5.1, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /kill ` (FR-034, SC-008)
- [ ] T0542 [US13-core] Implement `/kill` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0543 [US13-core] Write test `core/tests/test_cmd_list.cob` for `/list` (`docs/protocol/16-commands-catalog.md` §8.5, permission level 0): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /list ` (FR-034, SC-008)
- [ ] T0544 [US13-core] Implement `/list` in `core/src/cmds-chat.cob` so its test passes (create the file with the first command of its group)
- [ ] T0545 [US13-core] Write test `core/tests/test_cmd_locate.cob` for `/locate` (`docs/protocol/16-commands-catalog.md` §7.7, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /locate ` (FR-034, SC-008)
- [ ] T0546 [US13-core] Implement `/locate` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0547 [US13-core] Write test `core/tests/test_cmd_loot.cob` for `/loot` (`docs/protocol/16-commands-catalog.md` §6.4, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /loot ` (FR-034, SC-008)
- [ ] T0548 [US13-core] Implement `/loot` in `core/src/cmds-items.cob` so its test passes (create the file with the first command of its group)
- [ ] T0549 [US13-core] Write test `core/tests/test_cmd_me.cob` for `/me` (`docs/protocol/16-commands-catalog.md` §8.2, permission level 0): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /me ` (FR-034, SC-008)
- [ ] T0550 [US13-core] Implement `/me` in `core/src/cmds-chat.cob` so its test passes (create the file with the first command of its group)
- [ ] T0551 [US13-core] Write test `core/tests/test_cmd_op.cob` for `/op` (`docs/protocol/16-commands-catalog.md` §11.1, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /op ` (FR-034, SC-008)
- [ ] T0552 [US13-core] Implement `/op` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0553 [US13-core] Write test `core/tests/test_cmd_pardon.cob` for `/pardon` (`docs/protocol/16-commands-catalog.md` §11.5, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /pardon ` (FR-034, SC-008)
- [ ] T0554 [US13-core] Implement `/pardon` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0555 [US13-core] Write test `core/tests/test_cmd_pardon_ip.cob` for `/pardon-ip` (`docs/protocol/16-commands-catalog.md` §11.6, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /pardon-ip ` (FR-034, SC-008)
- [ ] T0556 [US13-core] Implement `/pardon-ip` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0557 [US13-core] Write test `core/tests/test_cmd_particle.cob` for `/particle` (`docs/protocol/16-commands-catalog.md` §7.8, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /particle ` (FR-034, SC-008)
- [ ] T0558 [US13-core] Implement `/particle` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0559 [US13-core] Write test `core/tests/test_cmd_perf.cob` for `/perf` (`docs/protocol/16-commands-catalog.md` §11.17, permission level 4 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /perf ` (FR-034, SC-008)
- [ ] T0560 [US13-core] Implement `/perf` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0561 [US13-core] Write test `core/tests/test_cmd_place.cob` for `/place` (`docs/protocol/16-commands-catalog.md` §7.5, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /place ` (FR-034, SC-008)
- [ ] T0562 [US13-core] Implement `/place` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0563 [US13-core] Write test `core/tests/test_cmd_playsound.cob` for `/playsound` (`docs/protocol/16-commands-catalog.md` §7.9, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /playsound ` (FR-034, SC-008)
- [ ] T0564 [US13-core] Implement `/playsound` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0565 [US13-core] Write test `core/tests/test_cmd_posteffect.cob` for `/posteffect` (`docs/protocol/16-commands-catalog.md` §8.11, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /posteffect ` (FR-034, SC-008)
- [ ] T0566 [US13-core] Implement `/posteffect` in `core/src/cmds-chat.cob` so its test passes (create the file with the first command of its group)
- [ ] T0567 [US13-core] Write test `core/tests/test_cmd_publish.cob` for `/publish` (`docs/protocol/16-commands-catalog.md` §11.15, permission level 4 (integrated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /publish ` (FR-034, SC-008)
- [ ] T0568 [US13-core] Implement `/publish` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0569 [US13-core] Write test `core/tests/test_cmd_unpublish.cob` for `/unpublish` (`docs/protocol/16-commands-catalog.md` §11.16, permission level 4 (integrated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /unpublish ` (FR-034, SC-008)
- [ ] T0570 [US13-core] Implement `/unpublish` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0571 [US13-core] Write test `core/tests/test_cmd_raid.cob` for `/raid` (`docs/protocol/16-commands-catalog.md` §12, permission level 3 (dev)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /raid ` (FR-034, SC-008)
- [ ] T0572 [US13-core] Implement `/raid` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0573 [US13-core] Write test `core/tests/test_cmd_random.cob` for `/random` (`docs/protocol/16-commands-catalog.md` §10.8, permission level 0 (`reset`: 2)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /random ` (FR-034, SC-008)
- [ ] T0574 [US13-core] Implement `/random` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0575 [US13-core] Write test `core/tests/test_cmd_recipe.cob` for `/recipe` (`docs/protocol/16-commands-catalog.md` §6.5, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /recipe ` (FR-034, SC-008)
- [ ] T0576 [US13-core] Implement `/recipe` in `core/src/cmds-items.cob` so its test passes (create the file with the first command of its group)
- [ ] T0577 [US13-core] Write test `core/tests/test_cmd_reload.cob` for `/reload` (`docs/protocol/16-commands-catalog.md` §10.12, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /reload ` (FR-034, SC-008)
- [ ] T0578 [US13-core] Implement `/reload` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0579 [US13-core] Write test `core/tests/test_cmd_return.cob` for `/return` (`docs/protocol/16-commands-catalog.md` §10.6, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /return ` (FR-034, SC-008)
- [ ] T0580 [US13-core] Implement `/return` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0581 [US13-core] Write test `core/tests/test_cmd_ride.cob` for `/ride` (`docs/protocol/16-commands-catalog.md` §5.6, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /ride ` (FR-034, SC-008)
- [ ] T0582 [US13-core] Implement `/ride` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0583 [US13-core] Write test `core/tests/test_cmd_rotate.cob` for `/rotate` (`docs/protocol/16-commands-catalog.md` §5.5, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /rotate ` (FR-034, SC-008)
- [ ] T0584 [US13-core] Implement `/rotate` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0585 [US13-core] Write test `core/tests/test_cmd_save_all.cob` for `/save-all` (`docs/protocol/16-commands-catalog.md` §11.9, permission level 4 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /save-all ` (FR-034, SC-008)
- [ ] T0586 [US13-core] Implement `/save-all` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0587 [US13-core] Write test `core/tests/test_cmd_save_off.cob` for `/save-off` (`docs/protocol/16-commands-catalog.md` §11.11, permission level 4 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /save-off ` (FR-034, SC-008)
- [ ] T0588 [US13-core] Implement `/save-off` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0589 [US13-core] Write test `core/tests/test_cmd_save_on.cob` for `/save-on` (`docs/protocol/16-commands-catalog.md` §11.10, permission level 4 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /save-on ` (FR-034, SC-008)
- [ ] T0590 [US13-core] Implement `/save-on` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0591 [US13-core] Write test `core/tests/test_cmd_say.cob` for `/say` (`docs/protocol/16-commands-catalog.md` §8.1, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /say ` (FR-034, SC-008)
- [ ] T0592 [US13-core] Implement `/say` in `core/src/cmds-chat.cob` so its test passes (create the file with the first command of its group)
- [ ] T0593 [US13-core] Write test `core/tests/test_cmd_schedule.cob` for `/schedule` (`docs/protocol/16-commands-catalog.md` §10.4, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /schedule ` (FR-034, SC-008)
- [ ] T0594 [US13-core] Implement `/schedule` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0595 [US13-core] Write test `core/tests/test_cmd_scoreboard.cob` for `/scoreboard` (`docs/protocol/16-commands-catalog.md` §9.1, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /scoreboard ` (FR-034, SC-008)
- [ ] T0596 [US13-core] Implement `/scoreboard` in `core/src/cmds-scoreboard.cob` so its test passes (create the file with the first command of its group)
- [ ] T0597 [US13-core] Write test `core/tests/test_cmd_seed.cob` for `/seed` (`docs/protocol/16-commands-catalog.md` §4.6, permission level 2 (0 in integrated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /seed ` (FR-034, SC-008)
- [ ] T0598 [US13-core] Implement `/seed` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0599 [US13-core] Write test `core/tests/test_cmd_serverpack.cob` for `/serverpack` (`docs/protocol/16-commands-catalog.md` §11.21, permission level 2 (dev)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /serverpack ` (FR-034, SC-008)
- [ ] T0600 [US13-core] Implement `/serverpack` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0601 [US13-core] Write test `core/tests/test_cmd_setblock.cob` for `/setblock` (`docs/protocol/16-commands-catalog.md` §7.1, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /setblock ` (FR-034, SC-008)
- [ ] T0602 [US13-core] Implement `/setblock` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0603 [US13-core] Write test `core/tests/test_cmd_setidletimeout.cob` for `/setidletimeout` (`docs/protocol/16-commands-catalog.md` §11.14, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /setidletimeout ` (FR-034, SC-008)
- [ ] T0604 [US13-core] Implement `/setidletimeout` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0605 [US13-core] Write test `core/tests/test_cmd_setworldspawn.cob` for `/setworldspawn` (`docs/protocol/16-commands-catalog.md` §4.7, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /setworldspawn ` (FR-034, SC-008)
- [ ] T0606 [US13-core] Implement `/setworldspawn` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0607 [US13-core] Write test `core/tests/test_cmd_spawnpoint.cob` for `/spawnpoint` (`docs/protocol/16-commands-catalog.md` §4.8, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /spawnpoint ` (FR-034, SC-008)
- [ ] T0608 [US13-core] Implement `/spawnpoint` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0609 [US13-core] Write test `core/tests/test_cmd_spectate.cob` for `/spectate` (`docs/protocol/16-commands-catalog.md` §5.4, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /spectate ` (FR-034, SC-008)
- [ ] T0610 [US13-core] Implement `/spectate` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0611 [US13-core] Write test `core/tests/test_cmd_spreadplayers.cob` for `/spreadplayers` (`docs/protocol/16-commands-catalog.md` §5.3, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /spreadplayers ` (FR-034, SC-008)
- [ ] T0612 [US13-core] Implement `/spreadplayers` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0613 [US13-core] Write test `core/tests/test_cmd_stop.cob` for `/stop` (`docs/protocol/16-commands-catalog.md` §11.12, permission level 4 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /stop ` (FR-034, SC-008)
- [ ] T0614 [US13-core] Implement `/stop` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0615 [US13-core] Write test `core/tests/test_cmd_stopsound.cob` for `/stopsound` (`docs/protocol/16-commands-catalog.md` §7.10, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /stopsound ` (FR-034, SC-008)
- [ ] T0616 [US13-core] Implement `/stopsound` in `core/src/cmds-world.cob` so its test passes (create the file with the first command of its group)
- [ ] T0617 [US13-core] Write test `core/tests/test_cmd_stopwatch.cob` for `/stopwatch` (`docs/protocol/16-commands-catalog.md` §10.10, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /stopwatch ` (FR-034, SC-008)
- [ ] T0618 [US13-core] Implement `/stopwatch` in `core/src/cmds-data.cob` so its test passes (create the file with the first command of its group)
- [ ] T0619 [US13-core] Write test `core/tests/test_cmd_summon.cob` for `/summon` (`docs/protocol/16-commands-catalog.md` §5.8, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /summon ` (FR-034, SC-008)
- [ ] T0620 [US13-core] Implement `/summon` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0621 [US13-core] Write test `core/tests/test_cmd_swing.cob` for `/swing` (`docs/protocol/16-commands-catalog.md` §5.14, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /swing ` (FR-034, SC-008)
- [ ] T0622 [US13-core] Implement `/swing` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0623 [US13-core] Write test `core/tests/test_cmd_tag.cob` for `/tag` (`docs/protocol/16-commands-catalog.md` §5.9, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /tag ` (FR-034, SC-008)
- [ ] T0624 [US13-core] Implement `/tag` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0625 [US13-core] Write test `core/tests/test_cmd_team.cob` for `/team` (`docs/protocol/16-commands-catalog.md` §9.2, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /team ` (FR-034, SC-008)
- [ ] T0626 [US13-core] Implement `/team` in `core/src/cmds-scoreboard.cob` so its test passes (create the file with the first command of its group)
- [ ] T0627 [US13-core] Write test `core/tests/test_cmd_tellraw.cob` for `/tellraw` (`docs/protocol/16-commands-catalog.md` §8.8, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /tellraw ` (FR-034, SC-008)
- [ ] T0628 [US13-core] Implement `/tellraw` in `core/src/cmds-chat.cob` so its test passes (create the file with the first command of its group)
- [ ] T0629 [US13-core] Write test `core/tests/test_cmd_test.cob` for `/test` (`docs/protocol/16-commands-catalog.md` §12, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /test ` (FR-034, SC-008)
- [ ] T0630 [US13-core] Implement `/test` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0631 [US13-core] Write test `core/tests/test_cmd_tick.cob` for `/tick` (`docs/protocol/16-commands-catalog.md` §4.9, permission level 3): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /tick ` (FR-034, SC-008)
- [ ] T0632 [US13-core] Implement `/tick` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0633 [US13-core] Write test `core/tests/test_cmd_time.cob` for `/time` (`docs/protocol/16-commands-catalog.md` §4.5, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /time ` (FR-034, SC-008)
- [ ] T0634 [US13-core] Implement `/time` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0635 [US13-core] Write test `core/tests/test_cmd_title.cob` for `/title` (`docs/protocol/16-commands-catalog.md` §8.9, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /title ` (FR-034, SC-008)
- [ ] T0636 [US13-core] Implement `/title` in `core/src/cmds-chat.cob` so its test passes (create the file with the first command of its group)
- [ ] T0637 [US13-core] Write test `core/tests/test_cmd_transfer.cob` for `/transfer` (`docs/protocol/16-commands-catalog.md` §11.13, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /transfer ` (FR-034, SC-008)
- [ ] T0638 [US13-core] Implement `/transfer` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0639 [US13-core] Write test `core/tests/test_cmd_trigger.cob` for `/trigger` (`docs/protocol/16-commands-catalog.md` §9.3, permission level 0): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /trigger ` (FR-034, SC-008)
- [ ] T0640 [US13-core] Implement `/trigger` in `core/src/cmds-scoreboard.cob` so its test passes (create the file with the first command of its group)
- [ ] T0641 [US13-core] Write test `core/tests/test_cmd_version.cob` for `/version` (`docs/protocol/16-commands-catalog.md` §4.6, permission level 2 (0 in integrated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /version ` (FR-034, SC-008)
- [ ] T0642 [US13-core] Implement `/version` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0643 [US13-core] Write test `core/tests/test_cmd_waypoint.cob` for `/waypoint` (`docs/protocol/16-commands-catalog.md` §5.15, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /waypoint ` (FR-034, SC-008)
- [ ] T0644 [US13-core] Implement `/waypoint` in `core/src/cmds-entities.cob` so its test passes (create the file with the first command of its group)
- [ ] T0645 [US13-core] Write test `core/tests/test_cmd_weather.cob` for `/weather` (`docs/protocol/16-commands-catalog.md` §4.10, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /weather ` (FR-034, SC-008)
- [ ] T0646 [US13-core] Implement `/weather` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0647 [US13-core] Write test `core/tests/test_cmd_whitelist.cob` for `/whitelist` (`docs/protocol/16-commands-catalog.md` §11.22, permission level 3 (dedicated)): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /whitelist ` (FR-034, SC-008)
- [ ] T0648 [US13-core] Implement `/whitelist` in `core/src/cmds-admin.cob` so its test passes (create the file with the first command of its group)
- [ ] T0649 [US13-core] Write test `core/tests/test_cmd_worldborder.cob` for `/worldborder` (`docs/protocol/16-commands-catalog.md` §4.11, permission level 2): every argument form, completion, success and failure message and result value of that section and of §14a, plus the §15 worked example where one exists; case names start `acceptance US13 /worldborder ` (FR-034, SC-008)
- [ ] T0650 [US13-core] Implement `/worldborder` in `core/src/cmds-state.cob` so its test passes (create the file with the first command of its group)
- [ ] T0651 [US13-core] Write test `core/tests/test_cmd_gamerules.cob` for the gamerule table (`docs/protocol/16-commands-catalog.md` §13, one case per rule: name, type, default, range) and the aliases of §14 (FR-034, SC-008)
- [ ] T0652 [US13-core] Implement the gamerule table and the aliases in `core/src/cmds-admin.cob`
- [ ] T0653 [US13-core] Review task (mechanical, SC-008): run `sed -n '/^## 3\. Index/,/^## 4\./p' docs/protocol/16-commands-catalog.md | awk -F'|' 'NR>3 && $2 ~ /[a-z]/ {gsub(/ /,"",$2); print $2}' | while read c; do grep -q "acceptance US13 /$c " core/tests/test_cmd_*.cob || echo "MISSING $c"; done` and record that it prints nothing, and that the loop covered 91 commands
- [ ] T0654 [US13-core] Write edge-case test `core/tests/test_cmd_namespaces.cob` (spec edge case): a command argument with an unknown namespace fails with the standard message, and a standard item name (a bare name means `minecraft:`) inside a cobolcraft world fails because the cobolcraft registries do not hold it (`docs/design/world-types.md` §6.3, WT-13)
- [ ] T0655 [US13-core] Write acceptance test `core/tests/acc_f2us13_levels.cob` (US13-3, US13-4): a level-0 player is refused a level-2 command with the standard message; a bare name means `minecraft:` and in a cobolcraft world commands run against cobolcraft registries [FR-034; SC-008]
- [ ] T0656 [US13-core] Remove the 001 command set: delete `core/src/commands.cob` and `core/copy/COMMANDS.cpy`, `core/copy/CMDPARSE.cpy` once nothing calls them, and re-point `core/src/api.cob`
- [ ] T0657 [US13-core] Write contract tests `core/tests/contract_wire_server.cob` additions for the Commands, suggestion and chat fixtures
- [ ] T0658 [US13-core] Gate: run `make gate-core` and record the command and real output

#### Phase 47: US14-core — tools, weapons, armor, enchantments

**Goal**: every standard tool, weapon, armor material and enchantment works (FR-035); SC-008 is checkable per item by the mechanical review task at the end of the phase.

- [ ] T0659 [US14-core] Write test `core/tests/test_tool_speed.cob` for break speed and tier, correct tool for drops and tag rules (`docs/protocol/17-tools-weapons-and-combat.md` §1, Appendix A) feeding the US8 formula (FR-035)
- [ ] T0660 [US14-core] Implement tool speed and tiers in `core/src/tools.cob`
- [ ] T0661 [US14-core] Write test `core/tests/test_tool_materials.cob` for the tool materials (`docs/protocol/17-tools-weapons-and-combat.md` §2.1): durability, mining speed, attack bonus, enchantability, repair tag and the denies-drops tag of every material (wooden, stone, copper, iron, golden, diamond, netherite); case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0662 [US14-core] Implement the tool materials in `core/src/tools-materials.cob` so the test passes
- [ ] T0663 [US14-core] Write test `core/tests/test_tool_swords.cob` for the swords (`docs/protocol/17-tools-weapons-and-combat.md` §2.2, §1.4): every row for `wooden_sword`, `stone_sword`, `copper_sword`, `iron_sword`, `golden_sword`, `diamond_sword`, `netherite_sword`: durability, damage, speed, cooldown ticks; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0664 [US14-core] Implement the swords in `core/src/tools-swords.cob` so the test passes
- [ ] T0665 [US14-core] Write test `core/tests/test_tool_pickaxes.cob` for the pickaxes (`docs/protocol/17-tools-weapons-and-combat.md` §2.3 and the `mineable` tags of Appendix A): every row for `wooden_pickaxe`, `stone_pickaxe`, `copper_pickaxe`, `iron_pickaxe`, `golden_pickaxe`, `diamond_pickaxe`, `netherite_pickaxe`: durability, damage, speed, cooldown, mining speed on their tag, tier gating; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0666 [US14-core] Implement the pickaxes in `core/src/tools-pickaxes.cob` so the test passes
- [ ] T0667 [US14-core] Write test `core/tests/test_tool_axes.cob` for the axes (`docs/protocol/17-tools-weapons-and-combat.md` §2.3 and the `mineable` tags of Appendix A): every row for `wooden_axe`, `stone_axe`, `copper_axe`, `iron_axe`, `golden_axe`, `diamond_axe`, `netherite_axe`: durability, damage, speed, cooldown, mining speed on their tag, tier gating; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0668 [US14-core] Implement the axes in `core/src/tools-axes.cob` so the test passes
- [ ] T0669 [US14-core] Write test `core/tests/test_tool_shovels.cob` for the shovels (`docs/protocol/17-tools-weapons-and-combat.md` §2.3 and the `mineable` tags of Appendix A): every row for `wooden_shovel`, `stone_shovel`, `copper_shovel`, `iron_shovel`, `golden_shovel`, `diamond_shovel`, `netherite_shovel`: durability, damage, speed, cooldown, mining speed on their tag, tier gating; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0670 [US14-core] Implement the shovels in `core/src/tools-shovels.cob` so the test passes
- [ ] T0671 [US14-core] Write test `core/tests/test_tool_hoes.cob` for the hoes (`docs/protocol/17-tools-weapons-and-combat.md` §2.3 and the `mineable` tags of Appendix A): every row for `wooden_hoe`, `stone_hoe`, `copper_hoe`, `iron_hoe`, `golden_hoe`, `diamond_hoe`, `netherite_hoe`: durability, damage, speed, cooldown, mining speed on their tag, tier gating; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0672 [US14-core] Implement the hoes in `core/src/tools-hoes.cob` so the test passes
- [ ] T0673 [US14-core] Write test `core/tests/test_tool_spears.cob` for the spears (`docs/protocol/17-tools-weapons-and-combat.md` §2.4, §3.12): every row for `wooden_spear`, `stone_spear`, `copper_spear`, `iron_spear`, `golden_spear`, `diamond_spear`, `netherite_spear` and the jab; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0674 [US14-core] Implement the spears in `core/src/tools-spears.cob` so the test passes
- [ ] T0675 [US14-core] Write test `core/tests/test_tool_armor_leather.cob` for the armor material `leather` (`docs/protocol/17-tools-weapons-and-combat.md` §2.5, §4.4): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair tag of `leather`, and the armor attribute and damage reduction with a piece worn; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0676 [US14-core] Implement the armor material `leather` in `core/src/tools-armor.cob` so the test passes
- [ ] T0677 [US14-core] Write test `core/tests/test_tool_armor_copper.cob` for the armor material `copper` (`docs/protocol/17-tools-weapons-and-combat.md` §2.5, §4.4): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair tag of `copper`, and the armor attribute and damage reduction with a piece worn; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0678 [US14-core] Implement the armor material `copper` in `core/src/tools-armor.cob` so the test passes
- [ ] T0679 [US14-core] Write test `core/tests/test_tool_armor_chainmail.cob` for the armor material `chainmail` (`docs/protocol/17-tools-weapons-and-combat.md` §2.5, §4.4): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair tag of `chainmail`, and the armor attribute and damage reduction with a piece worn; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0680 [US14-core] Implement the armor material `chainmail` in `core/src/tools-armor.cob` so the test passes
- [ ] T0681 [US14-core] Write test `core/tests/test_tool_armor_iron.cob` for the armor material `iron` (`docs/protocol/17-tools-weapons-and-combat.md` §2.5, §4.4): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair tag of `iron`, and the armor attribute and damage reduction with a piece worn; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0682 [US14-core] Implement the armor material `iron` in `core/src/tools-armor.cob` so the test passes
- [ ] T0683 [US14-core] Write test `core/tests/test_tool_armor_golden.cob` for the armor material `golden` (`docs/protocol/17-tools-weapons-and-combat.md` §2.5, §4.4): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair tag of `golden`, and the armor attribute and damage reduction with a piece worn; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0684 [US14-core] Implement the armor material `golden` in `core/src/tools-armor.cob` so the test passes
- [ ] T0685 [US14-core] Write test `core/tests/test_tool_armor_diamond.cob` for the armor material `diamond` (`docs/protocol/17-tools-weapons-and-combat.md` §2.5, §4.4): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair tag of `diamond`, and the armor attribute and damage reduction with a piece worn; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0686 [US14-core] Implement the armor material `diamond` in `core/src/tools-armor.cob` so the test passes
- [ ] T0687 [US14-core] Write test `core/tests/test_tool_armor_netherite.cob` for the armor material `netherite` (`docs/protocol/17-tools-weapons-and-combat.md` §2.5, §4.4): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair tag of `netherite`, and the armor attribute and damage reduction with a piece worn; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0688 [US14-core] Implement the armor material `netherite` in `core/src/tools-armor.cob` so the test passes
- [ ] T0689 [US14-core] Write test `core/tests/test_tool_armor_turtle_scute.cob` for the armor material `turtle_scute` (`docs/protocol/17-tools-weapons-and-combat.md` §2.5, §4.4): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair tag of `turtle_scute`, and the armor attribute and damage reduction with a piece worn; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0690 [US14-core] Implement the armor material `turtle_scute` in `core/src/tools-armor.cob` so the test passes
- [ ] T0691 [US14-core] Write test `core/tests/test_tool_armor_wolf_armor_armadillo_scute.cob` for the armor material `wolf armor (armadillo_scute)` (`docs/protocol/17-tools-weapons-and-combat.md` §2.5, §4.4): the durability multiplier, defense per slot, toughness, knockback resistance, enchantability and repair tag of `wolf armor (armadillo_scute)`, and the armor attribute and damage reduction with a piece worn; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0692 [US14-core] Implement the armor material `wolf armor (armadillo_scute)` in `core/src/tools-armor.cob` so the test passes
- [ ] T0693 [US14-core] Write test `core/tests/test_tool_special_mace.cob` for the special item `mace` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0694 [US14-core] Implement the special item `mace` in `core/src/tools-special.cob` so the test passes
- [ ] T0695 [US14-core] Write test `core/tests/test_tool_special_trident.cob` for the special item `trident` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0696 [US14-core] Implement the special item `trident` in `core/src/tools-special.cob` so the test passes
- [ ] T0697 [US14-core] Write test `core/tests/test_tool_special_bow.cob` for the special item `bow` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0698 [US14-core] Implement the special item `bow` in `core/src/tools-special.cob` so the test passes
- [ ] T0699 [US14-core] Write test `core/tests/test_tool_special_crossbow.cob` for the special item `crossbow` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0700 [US14-core] Implement the special item `crossbow` in `core/src/tools-special.cob` so the test passes
- [ ] T0701 [US14-core] Write test `core/tests/test_tool_special_shield.cob` for the special item `shield` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0702 [US14-core] Implement the special item `shield` in `core/src/tools-special.cob` so the test passes
- [ ] T0703 [US14-core] Write test `core/tests/test_tool_special_shears.cob` for the special item `shears` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0704 [US14-core] Implement the special item `shears` in `core/src/tools-special.cob` so the test passes
- [ ] T0705 [US14-core] Write test `core/tests/test_tool_special_flint_and_steel.cob` for the special item `flint_and_steel` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0706 [US14-core] Implement the special item `flint_and_steel` in `core/src/tools-special.cob` so the test passes
- [ ] T0707 [US14-core] Write test `core/tests/test_tool_special_fishing_rod.cob` for the special item `fishing_rod` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0708 [US14-core] Implement the special item `fishing_rod` in `core/src/tools-special.cob` so the test passes
- [ ] T0709 [US14-core] Write test `core/tests/test_tool_special_carrot_on_a_stick.cob` for the special item `carrot_on_a_stick` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0710 [US14-core] Implement the special item `carrot_on_a_stick` in `core/src/tools-special.cob` so the test passes
- [ ] T0711 [US14-core] Write test `core/tests/test_tool_special_warped_fungus_on_a_stick.cob` for the special item `warped_fungus_on_a_stick` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0712 [US14-core] Implement the special item `warped_fungus_on_a_stick` in `core/src/tools-special.cob` so the test passes
- [ ] T0713 [US14-core] Write test `core/tests/test_tool_special_brush.cob` for the special item `brush` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0714 [US14-core] Implement the special item `brush` in `core/src/tools-special.cob` so the test passes
- [ ] T0715 [US14-core] Write test `core/tests/test_tool_special_spyglass.cob` for the special item `spyglass` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0716 [US14-core] Implement the special item `spyglass` in `core/src/tools-special.cob` so the test passes
- [ ] T0717 [US14-core] Write test `core/tests/test_tool_special_compass.cob` for the special item `compass` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0718 [US14-core] Implement the special item `compass` in `core/src/tools-special.cob` so the test passes
- [ ] T0719 [US14-core] Write test `core/tests/test_tool_special_recovery_compass.cob` for the special item `recovery_compass` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0720 [US14-core] Implement the special item `recovery_compass` in `core/src/tools-special.cob` so the test passes
- [ ] T0721 [US14-core] Write test `core/tests/test_tool_special_clock.cob` for the special item `clock` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0722 [US14-core] Implement the special item `clock` in `core/src/tools-special.cob` so the test passes
- [ ] T0723 [US14-core] Write test `core/tests/test_tool_special_lead.cob` for the special item `lead` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0724 [US14-core] Implement the special item `lead` in `core/src/tools-special.cob` so the test passes
- [ ] T0725 [US14-core] Write test `core/tests/test_tool_special_name_tag.cob` for the special item `name_tag` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0726 [US14-core] Implement the special item `name_tag` in `core/src/tools-special.cob` so the test passes
- [ ] T0727 [US14-core] Write test `core/tests/test_tool_special_saddle.cob` for the special item `saddle` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0728 [US14-core] Implement the special item `saddle` in `core/src/tools-special.cob` so the test passes
- [ ] T0729 [US14-core] Write test `core/tests/test_tool_special_elytra.cob` for the special item `elytra` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0730 [US14-core] Implement the special item `elytra` in `core/src/tools-special.cob` so the test passes
- [ ] T0731 [US14-core] Write test `core/tests/test_tool_special_bucket.cob` for the special item `bucket` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0732 [US14-core] Implement the special item `bucket` in `core/src/tools-special.cob` so the test passes
- [ ] T0733 [US14-core] Write test `core/tests/test_tool_special_ender_pearl.cob` for the special item `ender_pearl` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0734 [US14-core] Implement the special item `ender_pearl` in `core/src/tools-special.cob` so the test passes
- [ ] T0735 [US14-core] Write test `core/tests/test_tool_special_wind_charge.cob` for the special item `wind_charge` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0736 [US14-core] Implement the special item `wind_charge` in `core/src/tools-special.cob` so the test passes
- [ ] T0737 [US14-core] Write test `core/tests/test_tool_special_firework_rocket.cob` for the special item `firework_rocket` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0738 [US14-core] Implement the special item `firework_rocket` in `core/src/tools-special.cob` so the test passes
- [ ] T0739 [US14-core] Write test `core/tests/test_tool_special_fire_charge.cob` for the special item `fire_charge` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0740 [US14-core] Implement the special item `fire_charge` in `core/src/tools-special.cob` so the test passes
- [ ] T0741 [US14-core] Write test `core/tests/test_tool_special_bone_meal.cob` for the special item `bone_meal` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0742 [US14-core] Implement the special item `bone_meal` in `core/src/tools-special.cob` so the test passes
- [ ] T0743 [US14-core] Write test `core/tests/test_tool_special_totem_of_undying.cob` for the special item `totem_of_undying` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0744 [US14-core] Implement the special item `totem_of_undying` in `core/src/tools-special.cob` so the test passes
- [ ] T0745 [US14-core] Write test `core/tests/test_tool_special_experience_bottle.cob` for the special item `experience_bottle` (`docs/protocol/17-tools-weapons-and-combat.md` §2.6): its stack size, durability, enchantability, repair ingredient and listed components and stats; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0746 [US14-core] Implement the special item `experience_bottle` in `core/src/tools-special.cob` so the test passes
- [ ] T0747 [US14-core] Write test `core/tests/test_tool_use_3_1.cob` for special use §3.1 (Block transformers: axe, shovel, hoe) (`docs/protocol/17-tools-weapons-and-combat.md` §3.1): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0748 [US14-core] Implement special use §3.1 (Block transformers: axe, shovel, hoe) in `core/src/tools-use.cob` so the test passes
- [ ] T0749 [US14-core] Write test `core/tests/test_tool_use_3_2.cob` for special use §3.2 (Shears) (`docs/protocol/17-tools-weapons-and-combat.md` §3.2): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0750 [US14-core] Implement special use §3.2 (Shears) in `core/src/tools-use.cob` so the test passes
- [ ] T0751 [US14-core] Write test `core/tests/test_tool_use_3_3.cob` for special use §3.3 (Flint and steel, fire charge) (`docs/protocol/17-tools-weapons-and-combat.md` §3.3): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0752 [US14-core] Implement special use §3.3 (Flint and steel, fire charge) in `core/src/tools-use.cob` so the test passes
- [ ] T0753 [US14-core] Write test `core/tests/test_tool_use_3_4.cob` for special use §3.4 (Bone meal) (`docs/protocol/17-tools-weapons-and-combat.md` §3.4): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0754 [US14-core] Implement special use §3.4 (Bone meal) in `core/src/tools-use.cob` so the test passes
- [ ] T0755 [US14-core] Write test `core/tests/test_tool_use_3_5.cob` for special use §3.5 (Brush) (`docs/protocol/17-tools-weapons-and-combat.md` §3.5): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0756 [US14-core] Implement special use §3.5 (Brush) in `core/src/tools-use.cob` so the test passes
- [ ] T0757 [US14-core] Write test `core/tests/test_tool_use_3_6.cob` for special use §3.6 (Shield and blocking) (`docs/protocol/17-tools-weapons-and-combat.md` §3.6): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0758 [US14-core] Implement special use §3.6 (Shield and blocking) in `core/src/tools-use.cob` so the test passes
- [ ] T0759 [US14-core] Write test `core/tests/test_tool_use_3_7.cob` for special use §3.7 (Lead, name tag, saddle) (`docs/protocol/17-tools-weapons-and-combat.md` §3.7): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0760 [US14-core] Implement special use §3.7 (Lead, name tag, saddle) in `core/src/tools-use.cob` so the test passes
- [ ] T0761 [US14-core] Write test `core/tests/test_tool_use_3_8.cob` for special use §3.8 (Buckets) (`docs/protocol/17-tools-weapons-and-combat.md` §3.8): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0762 [US14-core] Implement special use §3.8 (Buckets) in `core/src/tools-use.cob` so the test passes
- [ ] T0763 [US14-core] Write test `core/tests/test_tool_use_3_9.cob` for special use §3.9 (Bow and crossbow) (`docs/protocol/17-tools-weapons-and-combat.md` §3.9): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0764 [US14-core] Implement special use §3.9 (Bow and crossbow) in `core/src/tools-use.cob` so the test passes
- [ ] T0765 [US14-core] Write test `core/tests/test_tool_use_3_10.cob` for special use §3.10 (Trident) (`docs/protocol/17-tools-weapons-and-combat.md` §3.10): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0766 [US14-core] Implement special use §3.10 (Trident) in `core/src/tools-use.cob` so the test passes
- [ ] T0767 [US14-core] Write test `core/tests/test_tool_use_3_11.cob` for special use §3.11 (Fishing rod) (`docs/protocol/17-tools-weapons-and-combat.md` §3.11): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0768 [US14-core] Implement special use §3.11 (Fishing rod) in `core/src/tools-use.cob` so the test passes
- [ ] T0769 [US14-core] Write test `core/tests/test_tool_use_3_12.cob` for special use §3.12 (Spears) (`docs/protocol/17-tools-weapons-and-combat.md` §3.12): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0770 [US14-core] Implement special use §3.12 (Spears) in `core/src/tools-use.cob` so the test passes
- [ ] T0771 [US14-core] Write test `core/tests/test_tool_use_3_13.cob` for special use §3.13 (Elytra and fireworks) (`docs/protocol/17-tools-weapons-and-combat.md` §3.13): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0772 [US14-core] Implement special use §3.13 (Elytra and fireworks) in `core/src/tools-use.cob` so the test passes
- [ ] T0773 [US14-core] Write test `core/tests/test_tool_use_3_14.cob` for special use §3.14 (Compass types and the spyglass) (`docs/protocol/17-tools-weapons-and-combat.md` §3.14): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0774 [US14-core] Implement special use §3.14 (Compass types and the spyglass) in `core/src/tools-use.cob` so the test passes
- [ ] T0775 [US14-core] Write test `core/tests/test_tool_use_3_15.cob` for special use §3.15 (Ender pearl, snowball, egg, wind charge, thrown potions) (`docs/protocol/17-tools-weapons-and-combat.md` §3.15): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0776 [US14-core] Implement special use §3.15 (Ender pearl, snowball, egg, wind charge, thrown potions) in `core/src/tools-use.cob` so the test passes
- [ ] T0777 [US14-core] Write test `core/tests/test_tool_use_3_16.cob` for special use §3.16 (Block loot and tools) (`docs/protocol/17-tools-weapons-and-combat.md` §3.16): every rule, ordering and worked case of the section; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0778 [US14-core] Implement special use §3.16 (Block loot and tools) in `core/src/tools-use.cob` so the test passes
- [ ] T0779 [US14-core] Write test `core/tests/test_tool_fire_flammability.cob` for flammability and the fire tick constants (`docs/protocol/17-tools-weapons-and-combat.md` §3.3a): the flammability table and tick constants; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0780 [US14-core] Implement flammability and the fire tick constants in `core/src/tools-fire.cob` so the test passes
- [ ] T0781 [US14-core] Write test `core/tests/test_tool_combat.cob` for combat (`docs/protocol/17-tools-weapons-and-combat.md` §4, §8): damage, critical hits, sweep, hit window, knockback, shield, armor reduction and the worked examples of §8; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0782 [US14-core] Implement combat in `core/src/tools-combat.cob` so the test passes
- [ ] T0783 [US14-core] Write test `core/tests/test_tool_durability.cob` for durability, Unbreaking, Mending and repair (`docs/protocol/17-tools-weapons-and-combat.md` §5): the formulas of the section and the Set Slot damage update; case names start `acceptance US14 ` followed by the item name (FR-035, SC-008)
- [ ] T0784 [US14-core] Implement durability, Unbreaking, Mending and repair in `core/src/tools-durability.cob` so the test passes
- [ ] T0785 [US14-core] Write test `core/tests/test_ench_2.cob` for the effect component map (`docs/protocol/28-enchantment-effects.md` §2): every type, formula and worked example of the chapter; case names start `acceptance US14 28.2 ` (FR-035, SC-008)
- [ ] T0786 [US14-core] Implement the effect component map in `core/src/ench-2.cob` so the test passes
- [ ] T0787 [US14-core] Write test `core/tests/test_ench_4.cob` for level-based values (`docs/protocol/28-enchantment-effects.md` §4): every type, formula and worked example of the chapter; case names start `acceptance US14 28.4 ` (FR-035, SC-008)
- [ ] T0788 [US14-core] Implement level-based values in `core/src/ench-4.cob` so the test passes
- [ ] T0789 [US14-core] Write test `core/tests/test_ench_5.cob` for value effects (`docs/protocol/28-enchantment-effects.md` §5): every type, formula and worked example of the chapter; case names start `acceptance US14 28.5 ` (FR-035, SC-008)
- [ ] T0790 [US14-core] Implement value effects in `core/src/ench-5.cob` so the test passes
- [ ] T0791 [US14-core] Write test `core/tests/test_ench_6.cob` for entity and location effects (`docs/protocol/28-enchantment-effects.md` §6): every type, formula and worked example of the chapter; case names start `acceptance US14 28.6 ` (FR-035, SC-008)
- [ ] T0792 [US14-core] Implement entity and location effects in `core/src/ench-6.cob` so the test passes
- [ ] T0793 [US14-core] Write test `core/tests/test_ench_7.cob` for requirements and loot contexts (`docs/protocol/28-enchantment-effects.md` §7): every type, formula and worked example of the chapter; case names start `acceptance US14 28.7 ` (FR-035, SC-008)
- [ ] T0794 [US14-core] Implement requirements and loot contexts in `core/src/ench-7.cob` so the test passes
- [ ] T0795 [US14-core] Write test `core/tests/test_ench_8.cob` for the enchantment engine (levels, iteration, combining) (`docs/protocol/28-enchantment-effects.md` §8): every type, formula and worked example of the chapter; case names start `acceptance US14 28.8 ` (FR-035, SC-008)
- [ ] T0796 [US14-core] Implement the enchantment engine (levels, iteration, combining) in `core/src/ench-8.cob` so the test passes
- [ ] T0797 [US14-core] Review task (mechanical, SC-008): run `sed -n '/^### 2\.2/,/^## 3\./p' docs/protocol/17-tools-weapons-and-combat.md | grep -o '^| `[a-z_]*`' | tr -d '|` ' | while read i; do grep -q "$i" core/tests/test_tool_*.cob || echo "MISSING $i"; done` and record that it prints nothing
- [ ] T0798 [US14-core] Gate: run `make gate-core` and record the command and real output

#### Phase 48: US15-core — mobs

- [ ] T0799 [US15-core] Write test `core/tests/test_mob_framework.cob`: per-tick update order, entity physics beyond the player (`docs/protocol/18-mob-framework.md` §2, §3)
- [ ] T0800 [US15-core] Replace `core/src/mobs.cob` and `core/src/entities.cob` logic by the framework in `core/src/mob-framework.cob`
- [ ] T0801 [US15-core] Write test `core/tests/test_mob_ai.cob`: the goal/AI system (18 §4)
- [ ] T0802 [US15-core] Implement the AI system in `core/src/mob-ai.cob`
- [ ] T0803 [US15-core] Write test `core/tests/test_pathfinding.cob`: pathfinding (18 §5)
- [ ] T0804 [US15-core] Implement pathfinding in `core/src/pathfinding.cob`
- [ ] T0805 [US15-core] Write test `core/tests/test_spawning.cob`: natural spawning per chunk, light and biome data (18 §6, Appendix A, `44-residual-mob-questions-2-spawning-structures.md`)
- [ ] T0806 [US15-core] Implement natural spawning in `core/src/spawning.cob`
- [ ] T0807 [US15-core] Write test `core/tests/test_mob_damage.cob`: damage, knockback, death, drops and experience (18 §7)
- [ ] T0808 [US15-core] Implement them in `core/src/mob-damage.cob`
- [ ] T0809 [US15-core] Write test `core/tests/test_breeding_taming.cob`: breeding, ageing, taming, leashing, riding (18 §8)
- [ ] T0810 [US15-core] Implement them in `core/src/mob-social.cob`
- [ ] T0811 [US15-core] Write test `core/tests/test_entity_tracking.cob`: server-side tracking and sending, Spawn Entity, Set Entity Data, Update Attributes (18 §9)
- [ ] T0812 [US15-core] Implement entity tracking in `core/src/entity-tracking.cob`
- [ ] T0813 [US15-core] Write test `core/tests/test_mob_19_2_1.cob` for Pig (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §2.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:pig`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§2.1 Pig` cases (FR-036, SC-008)
- [ ] T0814 [US15-core] Implement Pig (§2.1 of document 19) in `core/src/mob-19-2.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0815 [US15-core] Write test `core/tests/test_mob_19_2_2.cob` for Cow (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §2.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:cow`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§2.2 Cow` cases (FR-036, SC-008)
- [ ] T0816 [US15-core] Implement Cow (§2.2 of document 19) in `core/src/mob-19-2.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0817 [US15-core] Write test `core/tests/test_mob_19_2_3.cob` for Mooshroom (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §2.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:mooshroom`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§2.3 Mooshroom` cases (FR-036, SC-008)
- [ ] T0818 [US15-core] Implement Mooshroom (§2.3 of document 19) in `core/src/mob-19-2.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0819 [US15-core] Write test `core/tests/test_mob_19_2_4.cob` for Sheep (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §2.4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:sheep`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§2.4 Sheep` cases (FR-036, SC-008)
- [ ] T0820 [US15-core] Implement Sheep (§2.4 of document 19) in `core/src/mob-19-2.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0821 [US15-core] Write test `core/tests/test_mob_19_2_5.cob` for Chicken (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §2.5): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:chicken`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§2.5 Chicken` cases (FR-036, SC-008)
- [ ] T0822 [US15-core] Implement Chicken (§2.5 of document 19) in `core/src/mob-19-2.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0823 [US15-core] Write test `core/tests/test_mob_19_3_3.cob` for Horse (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §3.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:horse`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§3.3 Horse` cases (FR-036, SC-008)
- [ ] T0824 [US15-core] Implement Horse (§3.3 of document 19) in `core/src/mob-19-3.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0825 [US15-core] Write test `core/tests/test_mob_19_3_6.cob` for Donkey, mule, skeleton horse, zombie horse (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §3.6): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:donkey`, `minecraft:mule`, `minecraft:skeleton_horse`, `minecraft:zombie_horse`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§3.6 Donkey, mule, skeleton horse, zombie horse` cases (FR-036, SC-008)
- [ ] T0826 [US15-core] Implement Donkey, mule, skeleton horse, zombie horse (§3.6 of document 19) in `core/src/mob-19-3.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0827 [US15-core] Write test `core/tests/test_mob_19_3_7.cob` for Llama and trader llama (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §3.7): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:llama`, `minecraft:trader_llama`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§3.7 Llama and trader llama` cases (FR-036, SC-008)
- [ ] T0828 [US15-core] Implement Llama and trader llama (§3.7 of document 19) in `core/src/mob-19-3.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0829 [US15-core] Write test `core/tests/test_mob_19_3_8.cob` for Camel and camel husk (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §3.8): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:camel`, `minecraft:camel_husk`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§3.8 Camel and camel husk` cases (FR-036, SC-008)
- [ ] T0830 [US15-core] Implement Camel and camel husk (§3.8 of document 19) in `core/src/mob-19-3.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0831 [US15-core] Write test `core/tests/test_mob_19_4.cob` for Rabbit (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:rabbit`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§4 Rabbit` cases (FR-036, SC-008)
- [ ] T0832 [US15-core] Implement Rabbit (§4 of document 19) in `core/src/mob-19-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0833 [US15-core] Write test `core/tests/test_mob_19_5_1.cob` for Cat (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §5.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:cat`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§5.1 Cat` cases (FR-036, SC-008)
- [ ] T0834 [US15-core] Implement Cat (§5.1 of document 19) in `core/src/mob-19-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0835 [US15-core] Write test `core/tests/test_mob_19_5_2.cob` for Ocelot (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §5.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:ocelot`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§5.2 Ocelot` cases (FR-036, SC-008)
- [ ] T0836 [US15-core] Implement Ocelot (§5.2 of document 19) in `core/src/mob-19-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0837 [US15-core] Write test `core/tests/test_mob_19_6_1.cob` for Wolf (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §6.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§6.1 Wolf` cases (FR-036, SC-008)
- [ ] T0838 [US15-core] Implement Wolf (§6.1 of document 19) in `core/src/mob-19-6.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0839 [US15-core] Write test `core/tests/test_mob_19_7.cob` for Fox (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §7): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:fox`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§7 Fox` cases (FR-036, SC-008)
- [ ] T0840 [US15-core] Implement Fox (§7 of document 19) in `core/src/mob-19-7.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0841 [US15-core] Write test `core/tests/test_mob_19_8.cob` for Panda (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §8): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:panda`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§8 Panda` cases (FR-036, SC-008)
- [ ] T0842 [US15-core] Implement Panda (§8 of document 19) in `core/src/mob-19-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0843 [US15-core] Write test `core/tests/test_mob_19_9.cob` for Polar bear (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §9): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:polar_bear`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§9 Polar bear` cases (FR-036, SC-008)
- [ ] T0844 [US15-core] Implement Polar bear (§9 of document 19) in `core/src/mob-19-9.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0845 [US15-core] Write test `core/tests/test_mob_19_10.cob` for Goat (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §10): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:goat`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§10 Goat` cases (FR-036, SC-008)
- [ ] T0846 [US15-core] Implement Goat (§10 of document 19) in `core/src/mob-19-10.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0847 [US15-core] Write test `core/tests/test_mob_19_11_1.cob` for Frog (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §11.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:frog`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§11.1 Frog` cases (FR-036, SC-008)
- [ ] T0848 [US15-core] Implement Frog (§11.1 of document 19) in `core/src/mob-19-11.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0849 [US15-core] Write test `core/tests/test_mob_19_11_2.cob` for Tadpole (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §11.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:tadpole`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§11.2 Tadpole` cases (FR-036, SC-008)
- [ ] T0850 [US15-core] Implement Tadpole (§11.2 of document 19) in `core/src/mob-19-11.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0851 [US15-core] Write test `core/tests/test_mob_19_12.cob` for Turtle (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §12): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:turtle`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§12 Turtle` cases (FR-036, SC-008)
- [ ] T0852 [US15-core] Implement Turtle (§12 of document 19) in `core/src/mob-19-12.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0853 [US15-core] Write test `core/tests/test_mob_19_13.cob` for Armadillo (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §13): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:armadillo`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§13 Armadillo` cases (FR-036, SC-008)
- [ ] T0854 [US15-core] Implement Armadillo (§13 of document 19) in `core/src/mob-19-13.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0855 [US15-core] Write test `core/tests/test_mob_19_14.cob` for Sniffer (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §14): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:sniffer`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§14 Sniffer` cases (FR-036, SC-008)
- [ ] T0856 [US15-core] Implement Sniffer (§14 of document 19) in `core/src/mob-19-14.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0857 [US15-core] Write test `core/tests/test_mob_19_15.cob` for Allay (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §15): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:allay`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§15 Allay` cases (FR-036, SC-008)
- [ ] T0858 [US15-core] Implement Allay (§15 of document 19) in `core/src/mob-19-15.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0859 [US15-core] Write test `core/tests/test_mob_19_16.cob` for Bee (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §16): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:bee`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§16 Bee` cases (FR-036, SC-008)
- [ ] T0860 [US15-core] Implement Bee (§16 of document 19) in `core/src/mob-19-16.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0861 [US15-core] Write test `core/tests/test_mob_19_17.cob` for Parrot (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §17): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:parrot`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§17 Parrot` cases (FR-036, SC-008)
- [ ] T0862 [US15-core] Implement Parrot (§17 of document 19) in `core/src/mob-19-17.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0863 [US15-core] Write test `core/tests/test_mob_19_18.cob` for Axolotl (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §18): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:axolotl`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§18 Axolotl` cases (FR-036, SC-008)
- [ ] T0864 [US15-core] Implement Axolotl (§18 of document 19) in `core/src/mob-19-18.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0865 [US15-core] Write test `core/tests/test_mob_19_19.cob` for Iron golem (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §19): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:iron_golem`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§19 Iron golem` cases (FR-036, SC-008)
- [ ] T0866 [US15-core] Implement Iron golem (§19 of document 19) in `core/src/mob-19-19.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0867 [US15-core] Write test `core/tests/test_mob_19_20.cob` for Snow golem (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §20): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:snow_golem`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§20 Snow golem` cases (FR-036, SC-008)
- [ ] T0868 [US15-core] Implement Snow golem (§20 of document 19) in `core/src/mob-19-20.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0869 [US15-core] Write test `core/tests/test_mob_19_21.cob` for Copper golem (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §21): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:copper_golem`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§21 Copper golem` cases (FR-036, SC-008)
- [ ] T0870 [US15-core] Implement Copper golem (§21 of document 19) in `core/src/mob-19-21.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0871 [US15-core] Write test `core/tests/test_mob_19_22_1.cob` for Identity, attributes, metadata (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.1 Identity, attributes, metadata` cases (FR-036, SC-008)
- [ ] T0872 [US15-core] Implement Identity, attributes, metadata (§22.1 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0873 [US15-core] Write test `core/tests/test_mob_19_22_2.cob` for Professions, workstations and levels (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.2 Professions, workstations and levels` cases (FR-036, SC-008)
- [ ] T0874 [US15-core] Implement Professions, workstations and levels (§22.2 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0875 [US15-core] Write test `core/tests/test_mob_19_22_3.cob` for Brain (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.3 Brain` cases (FR-036, SC-008)
- [ ] T0876 [US15-core] Implement Brain (§22.3 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0877 [US15-core] Write test `core/tests/test_mob_19_22_4.cob` for Trade offers, selection and the price formula (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.4 Trade offers, selection and the price formula` cases (FR-036, SC-008)
- [ ] T0878 [US15-core] Implement Trade offers, selection and the price formula (§22.4 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0879 [US15-core] Write test `core/tests/test_mob_19_22_5.cob` for Gossip and reputation (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.5): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.5 Gossip and reputation` cases (FR-036, SC-008)
- [ ] T0880 [US15-core] Implement Gossip and reputation (§22.5 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0881 [US15-core] Write test `core/tests/test_mob_19_22_6.cob` for Food, breeding and children (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.6): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.6 Food, breeding and children` cases (FR-036, SC-008)
- [ ] T0882 [US15-core] Implement Food, breeding and children (§22.6 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0883 [US15-core] Write test `core/tests/test_mob_19_22_7.cob` for Job acquisition and profession change (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.7): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.7 Job acquisition and profession change` cases (FR-036, SC-008)
- [ ] T0884 [US15-core] Implement Job acquisition and profession change (§22.7 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0885 [US15-core] Write test `core/tests/test_mob_19_22_8.cob` for Sleeping and waking (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.8): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.8 Sleeping and waking` cases (FR-036, SC-008)
- [ ] T0886 [US15-core] Implement Sleeping and waking (§22.8 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0887 [US15-core] Write test `core/tests/test_mob_19_22_9.cob` for Hero of the Village gifts (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.9): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.9 Hero of the Village gifts` cases (FR-036, SC-008)
- [ ] T0888 [US15-core] Implement Hero of the Village gifts (§22.9 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0889 [US15-core] Write test `core/tests/test_mob_19_22_10.cob` for Iron golem summoning by villagers (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.10): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.10 Iron golem summoning by villagers` cases (FR-036, SC-008)
- [ ] T0890 [US15-core] Implement Iron golem summoning by villagers (§22.10 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0891 [US15-core] Write test `core/tests/test_mob_19_22_11.cob` for Raids, curing and zombie conversion (`docs/protocol/19-mobs-land-friendly-and-neutral.md` §22.11): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 19§22.11 Raids, curing and zombie conversion` cases (FR-036, SC-008)
- [ ] T0892 [US15-core] Implement Raids, curing and zombie conversion (§22.11 of document 19) in `core/src/mob-19-22.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0893 [US15-core] Write test `core/tests/test_mob_20_4_1.cob` for Zombie (`docs/protocol/20-mobs-overworld-hostile.md` §4.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:zombie`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§4.1 Zombie` cases (FR-036, SC-008)
- [ ] T0894 [US15-core] Implement Zombie (§4.1 of document 20) in `core/src/mob-20-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0895 [US15-core] Write test `core/tests/test_mob_20_4_2.cob` for Zombie villager (`docs/protocol/20-mobs-overworld-hostile.md` §4.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:zombie_villager`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§4.2 Zombie villager` cases (FR-036, SC-008)
- [ ] T0896 [US15-core] Implement Zombie villager (§4.2 of document 20) in `core/src/mob-20-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0897 [US15-core] Write test `core/tests/test_mob_20_4_3.cob` for Husk (`docs/protocol/20-mobs-overworld-hostile.md` §4.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:husk`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§4.3 Husk` cases (FR-036, SC-008)
- [ ] T0898 [US15-core] Implement Husk (§4.3 of document 20) in `core/src/mob-20-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0899 [US15-core] Write test `core/tests/test_mob_20_4_4.cob` for Camel husk (`docs/protocol/20-mobs-overworld-hostile.md` §4.4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:camel_husk`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§4.4 Camel husk` cases (FR-036, SC-008)
- [ ] T0900 [US15-core] Implement Camel husk (§4.4 of document 20) in `core/src/mob-20-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0901 [US15-core] Write test `core/tests/test_mob_20_4_5.cob` for Drowned (`docs/protocol/20-mobs-overworld-hostile.md` §4.5): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:drowned`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§4.5 Drowned` cases (FR-036, SC-008)
- [ ] T0902 [US15-core] Implement Drowned (§4.5 of document 20) in `core/src/mob-20-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0903 [US15-core] Write test `core/tests/test_mob_20_5.cob` for Skeleton family (`docs/protocol/20-mobs-overworld-hostile.md` §5): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:bogged`, `minecraft:parched`, `minecraft:skeleton`, `minecraft:stray`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§5 Skeleton family` cases (FR-036, SC-008)
- [ ] T0904 [US15-core] Implement Skeleton family (§5 of document 20) in `core/src/mob-20-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0905 [US15-core] Write test `core/tests/test_mob_20_6_1.cob` for Creeper (`docs/protocol/20-mobs-overworld-hostile.md` §6.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§6.1 Creeper` cases (FR-036, SC-008)
- [ ] T0906 [US15-core] Implement Creeper (§6.1 of document 20) in `core/src/mob-20-6.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0907 [US15-core] Write test `core/tests/test_mob_20_6_2.cob` for Explosion algorithm (`docs/protocol/20-mobs-overworld-hostile.md` §6.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§6.2 Explosion algorithm` cases (FR-036, SC-008)
- [ ] T0908 [US15-core] Implement Explosion algorithm (§6.2 of document 20) in `core/src/mob-20-6.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0909 [US15-core] Write test `core/tests/test_mob_20_7_1.cob` for Spider (`docs/protocol/20-mobs-overworld-hostile.md` §7.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§7.1 Spider` cases (FR-036, SC-008)
- [ ] T0910 [US15-core] Implement Spider (§7.1 of document 20) in `core/src/mob-20-7.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0911 [US15-core] Write test `core/tests/test_mob_20_7_2.cob` for Cave spider (`docs/protocol/20-mobs-overworld-hostile.md` §7.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§7.2 Cave spider` cases (FR-036, SC-008)
- [ ] T0912 [US15-core] Implement Cave spider (§7.2 of document 20) in `core/src/mob-20-7.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0913 [US15-core] Write test `core/tests/test_mob_20_8_1.cob` for Enderman (`docs/protocol/20-mobs-overworld-hostile.md` §8.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:enderman`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§8.1 Enderman` cases (FR-036, SC-008)
- [ ] T0914 [US15-core] Implement Enderman (§8.1 of document 20) in `core/src/mob-20-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0915 [US15-core] Write test `core/tests/test_mob_20_8_2.cob` for Endermite (`docs/protocol/20-mobs-overworld-hostile.md` §8.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:endermite`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§8.2 Endermite` cases (FR-036, SC-008)
- [ ] T0916 [US15-core] Implement Endermite (§8.2 of document 20) in `core/src/mob-20-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0917 [US15-core] Write test `core/tests/test_mob_20_9_1.cob` for Silverfish (`docs/protocol/20-mobs-overworld-hostile.md` §9.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§9.1 Silverfish` cases (FR-036, SC-008)
- [ ] T0918 [US15-core] Implement Silverfish (§9.1 of document 20) in `core/src/mob-20-9.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0919 [US15-core] Write test `core/tests/test_mob_20_9_2.cob` for Infested blocks (`docs/protocol/20-mobs-overworld-hostile.md` §9.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§9.2 Infested blocks` cases (FR-036, SC-008)
- [ ] T0920 [US15-core] Implement Infested blocks (§9.2 of document 20) in `core/src/mob-20-9.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0921 [US15-core] Write test `core/tests/test_mob_20_10.cob` for Slime (`docs/protocol/20-mobs-overworld-hostile.md` §10): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:slime`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§10 Slime` cases (FR-036, SC-008)
- [ ] T0922 [US15-core] Implement Slime (§10 of document 20) in `core/src/mob-20-10.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0923 [US15-core] Write test `core/tests/test_mob_20_11.cob` for Witch (`docs/protocol/20-mobs-overworld-hostile.md` §11): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:witch`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§11 Witch` cases (FR-036, SC-008)
- [ ] T0924 [US15-core] Implement Witch (§11 of document 20) in `core/src/mob-20-11.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0925 [US15-core] Write test `core/tests/test_mob_20_12.cob` for Phantom (`docs/protocol/20-mobs-overworld-hostile.md` §12): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:phantom`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§12 Phantom` cases (FR-036, SC-008)
- [ ] T0926 [US15-core] Implement Phantom (§12 of document 20) in `core/src/mob-20-12.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0927 [US15-core] Write test `core/tests/test_mob_20_13_1.cob` for Vindicator (`docs/protocol/20-mobs-overworld-hostile.md` §13.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:vindicator`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§13.1 Vindicator` cases (FR-036, SC-008)
- [ ] T0928 [US15-core] Implement Vindicator (§13.1 of document 20) in `core/src/mob-20-13.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0929 [US15-core] Write test `core/tests/test_mob_20_13_2.cob` for Pillager (`docs/protocol/20-mobs-overworld-hostile.md` §13.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:pillager`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§13.2 Pillager` cases (FR-036, SC-008)
- [ ] T0930 [US15-core] Implement Pillager (§13.2 of document 20) in `core/src/mob-20-13.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0931 [US15-core] Write test `core/tests/test_mob_20_13_3.cob` for Evoker (`docs/protocol/20-mobs-overworld-hostile.md` §13.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:evoker`, `minecraft:evoker_fangs`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§13.3 Evoker` cases (FR-036, SC-008)
- [ ] T0932 [US15-core] Implement Evoker (§13.3 of document 20) in `core/src/mob-20-13.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0933 [US15-core] Write test `core/tests/test_mob_20_13_4.cob` for Vex (`docs/protocol/20-mobs-overworld-hostile.md` §13.4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:vex`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§13.4 Vex` cases (FR-036, SC-008)
- [ ] T0934 [US15-core] Implement Vex (§13.4 of document 20) in `core/src/mob-20-13.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0935 [US15-core] Write test `core/tests/test_mob_20_13_5.cob` for Illusioner (`docs/protocol/20-mobs-overworld-hostile.md` §13.5): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:illusioner`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§13.5 Illusioner` cases (FR-036, SC-008)
- [ ] T0936 [US15-core] Implement Illusioner (§13.5 of document 20) in `core/src/mob-20-13.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0937 [US15-core] Write test `core/tests/test_mob_20_13_6.cob` for Ravager (`docs/protocol/20-mobs-overworld-hostile.md` §13.6): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:ravager`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§13.6 Ravager` cases (FR-036, SC-008)
- [ ] T0938 [US15-core] Implement Ravager (§13.6 of document 20) in `core/src/mob-20-13.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0939 [US15-core] Write test `core/tests/test_mob_20_14_1.cob` for Patrols (`docs/protocol/20-mobs-overworld-hostile.md` §14.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§14.1 Patrols` cases (FR-036, SC-008)
- [ ] T0940 [US15-core] Implement Patrols (§14.1 of document 20) in `core/src/mob-20-14.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0941 [US15-core] Write test `core/tests/test_mob_20_14_2.cob` for Raid lifecycle (`docs/protocol/20-mobs-overworld-hostile.md` §14.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§14.2 Raid lifecycle` cases (FR-036, SC-008)
- [ ] T0942 [US15-core] Implement Raid lifecycle (§14.2 of document 20) in `core/src/mob-20-14.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0943 [US15-core] Write test `core/tests/test_mob_20_14_3.cob` for Wave composition (`docs/protocol/20-mobs-overworld-hostile.md` §14.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§14.3 Wave composition` cases (FR-036, SC-008)
- [ ] T0944 [US15-core] Implement Wave composition (§14.3 of document 20) in `core/src/mob-20-14.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0945 [US15-core] Write test `core/tests/test_mob_20_15.cob` for Warden (`docs/protocol/20-mobs-overworld-hostile.md` §15): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:warden`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§15 Warden` cases (FR-036, SC-008)
- [ ] T0946 [US15-core] Implement Warden (§15 of document 20) in `core/src/mob-20-15.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0947 [US15-core] Write test `core/tests/test_mob_20_16.cob` for Breeze (`docs/protocol/20-mobs-overworld-hostile.md` §16): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:breeze`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§16 Breeze` cases (FR-036, SC-008)
- [ ] T0948 [US15-core] Implement Breeze (§16 of document 20) in `core/src/mob-20-16.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0949 [US15-core] Write test `core/tests/test_mob_20_17.cob` for Creaking (`docs/protocol/20-mobs-overworld-hostile.md` §17): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:creaking`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§17 Creaking` cases (FR-036, SC-008)
- [ ] T0950 [US15-core] Implement Creaking (§17 of document 20) in `core/src/mob-20-17.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0951 [US15-core] Write test `core/tests/test_mob_20_18_1.cob` for Giant (`docs/protocol/20-mobs-overworld-hostile.md` §18.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:giant`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§18.1 Giant` cases (FR-036, SC-008)
- [ ] T0952 [US15-core] Implement Giant (§18.1 of document 20) in `core/src/mob-20-18.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0953 [US15-core] Write test `core/tests/test_mob_20_18_2.cob` for Sulfur cube (`docs/protocol/20-mobs-overworld-hostile.md` §18.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers for `minecraft:sulfur_cube`, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 20§18.2 Sulfur cube` cases (FR-036, SC-008)
- [ ] T0954 [US15-core] Implement Sulfur cube (§18.2 of document 20) in `core/src/mob-20-18.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0955 [US15-core] Write test `core/tests/test_mob_21_4_2.cob` for Cod, salmon, pufferfish, tropical fish (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §4.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§4.2 Cod, salmon, pufferfish, tropical fish` cases (FR-036, SC-008)
- [ ] T0956 [US15-core] Implement Cod, salmon, pufferfish, tropical fish (§4.2 of document 21) in `core/src/mob-21-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0957 [US15-core] Write test `core/tests/test_mob_21_4_3.cob` for Pufferfish inflation (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §4.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§4.3 Pufferfish inflation` cases (FR-036, SC-008)
- [ ] T0958 [US15-core] Implement Pufferfish inflation (§4.3 of document 21) in `core/src/mob-21-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0959 [US15-core] Write test `core/tests/test_mob_21_4_4.cob` for Tropical fish variants (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §4.4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§4.4 Tropical fish variants` cases (FR-036, SC-008)
- [ ] T0960 [US15-core] Implement Tropical fish variants (§4.4 of document 21) in `core/src/mob-21-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0961 [US15-core] Write test `core/tests/test_mob_21_4_5.cob` for Squid and glow squid (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §4.5): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§4.5 Squid and glow squid` cases (FR-036, SC-008)
- [ ] T0962 [US15-core] Implement Squid and glow squid (§4.5 of document 21) in `core/src/mob-21-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0963 [US15-core] Write test `core/tests/test_mob_21_4_6.cob` for Dolphin (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §4.6): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§4.6 Dolphin` cases (FR-036, SC-008)
- [ ] T0964 [US15-core] Implement Dolphin (§4.6 of document 21) in `core/src/mob-21-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0965 [US15-core] Write test `core/tests/test_mob_21_4_7.cob` for Axolotl (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §4.7): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§4.7 Axolotl` cases (FR-036, SC-008)
- [ ] T0966 [US15-core] Implement Axolotl (§4.7 of document 21) in `core/src/mob-21-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0967 [US15-core] Write test `core/tests/test_mob_21_4_8.cob` for Guardian and elder guardian (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §4.8): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§4.8 Guardian and elder guardian` cases (FR-036, SC-008)
- [ ] T0968 [US15-core] Implement Guardian and elder guardian (§4.8 of document 21) in `core/src/mob-21-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0969 [US15-core] Write test `core/tests/test_mob_21_4_10.cob` for Nautilus and zombie nautilus (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §4.10): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§4.10 Nautilus and zombie nautilus` cases (FR-036, SC-008)
- [ ] T0970 [US15-core] Implement Nautilus and zombie nautilus (§4.10 of document 21) in `core/src/mob-21-4.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0971 [US15-core] Write test `core/tests/test_mob_21_5_1.cob` for Ghast (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §5.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§5.1 Ghast` cases (FR-036, SC-008)
- [ ] T0972 [US15-core] Implement Ghast (§5.1 of document 21) in `core/src/mob-21-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0973 [US15-core] Write test `core/tests/test_mob_21_5_2.cob` for Blaze and small fireball (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §5.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§5.2 Blaze and small fireball` cases (FR-036, SC-008)
- [ ] T0974 [US15-core] Implement Blaze and small fireball (§5.2 of document 21) in `core/src/mob-21-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0975 [US15-core] Write test `core/tests/test_mob_21_5_3.cob` for Magma cube and the cube-mob family (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §5.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§5.3 Magma cube and the cube-mob family` cases (FR-036, SC-008)
- [ ] T0976 [US15-core] Implement Magma cube and the cube-mob family (§5.3 of document 21) in `core/src/mob-21-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0977 [US15-core] Write test `core/tests/test_mob_21_5_4.cob` for Wither skeleton (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §5.4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§5.4 Wither skeleton` cases (FR-036, SC-008)
- [ ] T0978 [US15-core] Implement Wither skeleton (§5.4 of document 21) in `core/src/mob-21-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0979 [US15-core] Write test `core/tests/test_mob_21_5_5.cob` for Piglin family (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §5.5): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§5.5 Piglin family` cases (FR-036, SC-008)
- [ ] T0980 [US15-core] Implement Piglin family (§5.5 of document 21) in `core/src/mob-21-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0981 [US15-core] Write test `core/tests/test_mob_21_5_6.cob` for Hoglin and zoglin (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §5.6): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§5.6 Hoglin and zoglin` cases (FR-036, SC-008)
- [ ] T0982 [US15-core] Implement Hoglin and zoglin (§5.6 of document 21) in `core/src/mob-21-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0983 [US15-core] Write test `core/tests/test_mob_21_5_7.cob` for Strider (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §5.7): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§5.7 Strider` cases (FR-036, SC-008)
- [ ] T0984 [US15-core] Implement Strider (§5.7 of document 21) in `core/src/mob-21-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0985 [US15-core] Write test `core/tests/test_mob_21_5_8.cob` for Skeleton variants in the Nether (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §5.8): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§5.8 Skeleton variants in the Nether` cases (FR-036, SC-008)
- [ ] T0986 [US15-core] Implement Skeleton variants in the Nether (§5.8 of document 21) in `core/src/mob-21-5.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0987 [US15-core] Write test `core/tests/test_mob_21_6_2.cob` for Shulker and shulker bullet (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §6.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§6.2 Shulker and shulker bullet` cases (FR-036, SC-008)
- [ ] T0988 [US15-core] Implement Shulker and shulker bullet (§6.2 of document 21) in `core/src/mob-21-6.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0989 [US15-core] Write test `core/tests/test_mob_21_6_3.cob` for End crystal (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §6.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§6.3 End crystal` cases (FR-036, SC-008)
- [ ] T0990 [US15-core] Implement End crystal (§6.3 of document 21) in `core/src/mob-21-6.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0991 [US15-core] Write test `core/tests/test_mob_21_6_4.cob` for The Ender Dragon (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §6.4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§6.4 The Ender Dragon` cases (FR-036, SC-008)
- [ ] T0992 [US15-core] Implement The Ender Dragon (§6.4 of document 21) in `core/src/mob-21-6.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0993 [US15-core] Write test `core/tests/test_mob_21_7_1.cob` for Build pattern (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §7.1): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§7.1 Build pattern` cases (FR-036, SC-008)
- [ ] T0994 [US15-core] Implement Build pattern (§7.1 of document 21) in `core/src/mob-21-7.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0995 [US15-core] Write test `core/tests/test_mob_21_7_2.cob` for The Wither (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §7.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§7.2 The Wither` cases (FR-036, SC-008)
- [ ] T0996 [US15-core] Implement The Wither (§7.2 of document 21) in `core/src/mob-21-7.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0997 [US15-core] Write test `core/tests/test_mob_21_7_3.cob` for Boss bars (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §7.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§7.3 Boss bars` cases (FR-036, SC-008)
- [ ] T0998 [US15-core] Implement Boss bars (§7.3 of document 21) in `core/src/mob-21-7.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T0999 [US15-core] Write test `core/tests/test_mob_21_7_4.cob` for Nether Star (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §7.4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§7.4 Nether Star` cases (FR-036, SC-008)
- [ ] T1000 [US15-core] Implement Nether Star (§7.4 of document 21) in `core/src/mob-21-7.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1001 [US15-core] Write test `core/tests/test_mob_21_8_2.cob` for Experience orb (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.2): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.2 Experience orb` cases (FR-036, SC-008)
- [ ] T1002 [US15-core] Implement Experience orb (§8.2 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1003 [US15-core] Write test `core/tests/test_mob_21_8_3.cob` for Primed TNT (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.3): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.3 Primed TNT` cases (FR-036, SC-008)
- [ ] T1004 [US15-core] Implement Primed TNT (§8.3 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1005 [US15-core] Write test `core/tests/test_mob_21_8_4.cob` for Falling block (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.4): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.4 Falling block` cases (FR-036, SC-008)
- [ ] T1006 [US15-core] Implement Falling block (§8.4 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1007 [US15-core] Write test `core/tests/test_mob_21_8_5.cob` for Area effect cloud (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.5): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.5 Area effect cloud` cases (FR-036, SC-008)
- [ ] T1008 [US15-core] Implement Area effect cloud (§8.5 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1009 [US15-core] Write test `core/tests/test_mob_21_8_6.cob` for Lightning bolt (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.6): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.6 Lightning bolt` cases (FR-036, SC-008)
- [ ] T1010 [US15-core] Implement Lightning bolt (§8.6 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1011 [US15-core] Write test `core/tests/test_mob_21_8_7.cob` for Firework rocket (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.7): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.7 Firework rocket` cases (FR-036, SC-008)
- [ ] T1012 [US15-core] Implement Firework rocket (§8.7 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1013 [US15-core] Write test `core/tests/test_mob_21_8_8.cob` for Boats and minecarts (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.8): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.8 Boats and minecarts` cases (FR-036, SC-008)
- [ ] T1014 [US15-core] Implement Boats and minecarts (§8.8 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1015 [US15-core] Write test `core/tests/test_mob_21_8_9.cob` for Other non-mob entities (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.9): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.9 Other non-mob entities` cases (FR-036, SC-008)
- [ ] T1016 [US15-core] Implement Other non-mob entities (§8.9 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1017 [US15-core] Write test `core/tests/test_mob_21_8_10.cob` for Bat (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.10): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.10 Bat` cases (FR-036, SC-008)
- [ ] T1018 [US15-core] Implement Bat (§8.10 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1019 [US15-core] Write test `core/tests/test_mob_21_8_11.cob` for Happy ghast (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.11): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.11 Happy ghast` cases (FR-036, SC-008)
- [ ] T1020 [US15-core] Implement Happy ghast (§8.11 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1021 [US15-core] Write test `core/tests/test_mob_21_8_12.cob` for Eye of ender (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.12): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.12 Eye of ender` cases (FR-036, SC-008)
- [ ] T1022 [US15-core] Implement Eye of ender (§8.12 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1023 [US15-core] Write test `core/tests/test_mob_21_8_13.cob` for Thrown experience bottle (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.13): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.13 Thrown experience bottle` cases (FR-036, SC-008)
- [ ] T1024 [US15-core] Implement Thrown experience bottle (§8.13 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1025 [US15-core] Write test `core/tests/test_mob_21_8_14.cob` for Llama spit (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.14): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.14 Llama spit` cases (FR-036, SC-008)
- [ ] T1026 [US15-core] Implement Llama spit (§8.14 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1027 [US15-core] Write test `core/tests/test_mob_21_8_15.cob` for Leash knot (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.15): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.15 Leash knot` cases (FR-036, SC-008)
- [ ] T1028 [US15-core] Implement Leash knot (§8.15 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1029 [US15-core] Write test `core/tests/test_mob_21_8_16.cob` for Cushion and mannequin (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.16): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.16 Cushion and mannequin` cases (FR-036, SC-008)
- [ ] T1030 [US15-core] Implement Cushion and mannequin (§8.16 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1031 [US15-core] Write test `core/tests/test_mob_21_8_17.cob` for Ominous item spawner (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.17): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.17 Ominous item spawner` cases (FR-036, SC-008)
- [ ] T1032 [US15-core] Implement Ominous item spawner (§8.17 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1033 [US15-core] Write test `core/tests/test_mob_21_8_18.cob` for Breeze wind charge (`docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` §8.18): identity and attributes, metadata, behaviour and goals, damage, drops from its loot table, spawn rules and the worked examples the section gives; one case per entity key the section covers, named `acceptance US15 minecraft:<key> ...`, plus `acceptance US15 21§8.18 Breeze wind charge` cases (FR-036, SC-008)
- [ ] T1034 [US15-core] Implement Breeze wind charge (§8.18 of document 21) in `core/src/mob-21-8.cob` so the test passes (create the file with the first section of its chapter)
- [ ] T1035 [US15-core] Write test `core/tests/test_entity_nbt_1.cob`: read and write of the NBT of shared model and entity base (`docs/protocol/45-entity-nbt-1-shared-model-and-entity-base.md`): every field, default and worked example, through the entity save and load path (FR-036, FR-038)
- [ ] T1036 [US15-core] Implement the entity NBT of shared model and entity base in `core/src/entity-nbt-1.cob` so the test passes
- [ ] T1037 [US15-core] Write test `core/tests/test_entity_nbt_2.cob`: read and write of the NBT of living entity, mob and animal (`docs/protocol/45-entity-nbt-2-living-entity-mob-animal.md`): every field, default and worked example, through the entity save and load path (FR-036, FR-038)
- [ ] T1038 [US15-core] Implement the entity NBT of living entity, mob and animal in `core/src/entity-nbt-2.cob` so the test passes
- [ ] T1039 [US15-core] Write test `core/tests/test_entity_nbt_3.cob`: read and write of the NBT of player and player data (`docs/protocol/45-entity-nbt-3-player-and-player-data.md`): every field, default and worked example, through the entity save and load path (FR-036, FR-038)
- [ ] T1040 [US15-core] Implement the entity NBT of player and player data in `core/src/entity-nbt-3.cob` so the test passes
- [ ] T1041 [US15-core] Write test `core/tests/test_entity_nbt_4.cob`: read and write of the NBT of land animals (`docs/protocol/45-entity-nbt-4-land-animals.md`): every field, default and worked example, through the entity save and load path (FR-036, FR-038)
- [ ] T1042 [US15-core] Implement the entity NBT of land animals in `core/src/entity-nbt-4.cob` so the test passes
- [ ] T1043 [US15-core] Write test `core/tests/test_entity_nbt_5.cob`: read and write of the NBT of hostile mobs (`docs/protocol/45-entity-nbt-5-hostile-mobs.md`): every field, default and worked example, through the entity save and load path (FR-036, FR-038)
- [ ] T1044 [US15-core] Implement the entity NBT of hostile mobs in `core/src/entity-nbt-5.cob` so the test passes
- [ ] T1045 [US15-core] Write test `core/tests/test_entity_nbt_6.cob`: read and write of the NBT of villagers, illagers and piglins (`docs/protocol/45-entity-nbt-6-villagers-illagers-piglins.md`): every field, default and worked example, through the entity save and load path (FR-036, FR-038)
- [ ] T1046 [US15-core] Implement the entity NBT of villagers, illagers and piglins in `core/src/entity-nbt-6.cob` so the test passes
- [ ] T1047 [US15-core] Write test `core/tests/test_entity_nbt_7.cob`: read and write of the NBT of aquatic and miscellaneous mobs (`docs/protocol/45-entity-nbt-7-aquatic-and-misc-mobs.md`): every field, default and worked example, through the entity save and load path (FR-036, FR-038)
- [ ] T1048 [US15-core] Implement the entity NBT of aquatic and miscellaneous mobs in `core/src/entity-nbt-7.cob` so the test passes
- [ ] T1049 [US15-core] Write test `core/tests/test_entity_nbt_8.cob`: read and write of the NBT of vehicles, projectiles and items (`docs/protocol/45-entity-nbt-8-vehicles-projectiles-items.md`): every field, default and worked example, through the entity save and load path (FR-036, FR-038)
- [ ] T1050 [US15-core] Implement the entity NBT of vehicles, projectiles and items in `core/src/entity-nbt-8.cob` so the test passes
- [ ] T1051 [US15-core] Write test `core/tests/test_entity_nbt_9.cob`: read and write of the NBT of bosses and decorations (`docs/protocol/45-entity-nbt-9-bosses-and-decorations.md`): every field, default and worked example, through the entity save and load path (FR-036, FR-038)
- [ ] T1052 [US15-core] Implement the entity NBT of bosses and decorations in `core/src/entity-nbt-9.cob` so the test passes
- [ ] T1053 [US15-core] Review task (mechanical, SC-008): for each key in the entity-type columns of `docs/protocol/19-mobs-land-friendly-and-neutral.md` (Index) and `docs/protocol/20-mobs-overworld-hostile.md` (§2 Index) run `grep -o '`minecraft:[a-z_]*`' <doc> | sort -u | tr -d '`' | while read k; do grep -q "$k" core/tests/test_mob_*.cob || echo "MISSING $k"; done`, and for every entity of the §2 cross-check table of `docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md` whose coverage column starts `21 full` or `21 §` do the same; record that no key is missing, or add the missing case to the section's test task and re-run
- [ ] T1054 [US15-core] Write acceptance test `core/tests/acc_f2us15_mob_rules.cob` (US15-2): where a standard rule and a stand-in value differ, the standard wins in both types (FR-041) [SC-008]
- [ ] T1055 [US15-core] Gate: run `make gate-core` and record the command and real output

#### Phase 49: US19-core — off-hand swap

- [ ] T1056 [US19-core] Write test `core/tests/test_offhand_swap.cob`: the Player Action swap exchanges the held hotbar item with slot 45 and sends Set Slot for both; Container Click swap with the off-hand slot in the inventory menu (13 §4, US19-1, US19-2)
- [ ] T1057 [US19-core] Write edge-case test `core/tests/test_offhand_empty.cob` (spec edge case): swap with an empty hand and a full off hand, a full hand and an empty off hand, and both empty (nothing changes, no packet error)
- [ ] T1058 [US19-core] Implement the swap in `core/src/menu-inventory.cob` and the Player Action handler
- [ ] T1059 [US19-core] Gate: run `make gate-core` and record the command and real output

#### Phase 50: US21-core — vanilla configuration conformance (automated half of Q-1)

- [ ] T1060 [US21-core] Write contract test `core/tests/contract_vanilla_config.cob`: the configuration packet stream of a standard world (Known Packs, 51 Registry Data, Update Tags, Finish Configuration, then Login) equals the bytes of the 04 worked examples and the 46 id tables (US21-1)
- [ ] T1061 [US21-core] Make the configuration phase of `core/src/config-phase.cob` pass `contract_vanilla_config` for the standard set and send only the cobolcraft registries for the cobolcraft set (WT-16, US21-2)
- [ ] T1062 [US21-core] Gate: run `make gate-core` and record the command and real output

### Lane: server

#### Phase 51: US1-server — generated-dir key and console texts

- [ ] T1063 [US1-server] Write test `server/tests/test_config_generated_dir.cob`: the `generated-dir` key of `server.properties` (default `<game dir>/generated`) fills `CS-GENERATED-DIR`
- [ ] T1064 [US1-server] Implement the key in `server/src/config-file.cob`
- [ ] T1065 [US1-server] Write acceptance test `server/tests/acc_f2us1_startup_packs.cob` (US1-3, US1-4): at start-up the server prints the packs status line of `docs/protocol/22-extraction-tool.md` §9.2 for each of the five statuses and the cobolcraft type still starts [FR-001, FR-002; SC-012]
- [ ] T1066 [US1-server] Implement the start-up check and console texts in `server/src/main.cob` and `server/src/console.cob`
- [ ] T1067 [US1-server] Write contract tests (extended) `server/tests/contract_coreapi_consumer.cob` for the new settings fields and statuses
- [ ] T1068 [US1-server] Free-port test fix (CC-0005): make `server/tests/` tests that listen on the default port 25565 choose a free port at run time and check the configured default value without binding; add `server/tests/test_default_port_free.cob`
- [ ] T1069 [US1-server] Gate: run `make gate-server` and record the command and real output, including a run while a listener holds port 25565

#### Phase 52: US2-server — world-type key

- [ ] T1070 [US2-server] Write test `server/tests/test_config_world_type.cob`: key `world-type` accepts `standard` and `cobolcraft`, default `standard`, rejects other values with the documented message; an existing world's recorded type wins
- [ ] T1071 [US2-server] Implement the key in `server/src/config-file.cob`
- [ ] T1072 [US2-server] Write acceptance test `server/tests/acc_f2us2_refusal.cob`: a standard world with packs not `ok`, or a foreign folder, makes the server stop with exit code 10 and the reason on the console (core-host-delta §2, world-types.md §2.1) [FR-003, FR-004, FR-005, FR-037; SC-011]
- [ ] T1073 [US2-server] Implement the refusal exit in `server/src/main.cob`
- [ ] T1074 [US2-server] Gate: run `make gate-server` and record the command and real output

#### Phase 53: US21-server — start-up log lines for the manual run

- [ ] T1075 [US21-server] Write test `server/tests/test_startup_lines.cob`: the server prints the world type, the generated directory, the registry counts and "Done" lines that the manual run of `quickstart.md` §9 records
- [ ] T1076 [US21-server] Implement the lines in `server/src/console.cob`
- [ ] T1077 [US21-server] Gate: run `make gate-server` and record the command and real output

### Lane: client

#### Phase 54: US11-client (a) — replica, mesher and cell model re-base (scheduled first in this lane)

**Goal**: the client holds 16-bit states, any number of sections per dimension and three dimensions, decoding both the 001 and the 24-section chunk forms, so no later client gate sees a form it cannot read (lane note). **Independent Test**: `test_world_replica`, `test_mesher` over the 24-section fixture.

- [ ] T1078 [US11-client] Write consumer test `client/tests/contract_content_consumer.cob`: opens a set through a `contract/fixtures/content/` tree, asserts status words and one block lookup
- [ ] T1079 [US11-client] Write test cases in `client/tests/test_world_replica.cob` for a 24-section chunk through `PB-GET-CHUNK-24` (16-bit states, 4-bit light, biome containers, rows sized from the dimension's `min_y` and `height`) and for the 001 form
- [ ] T1080 [US11-client] Re-base `client/src/world-replica.cob` on `contract/copy/CELLS.cpy` and delete `client/copy/CLCELLS.cpy`; size the replica from the dimension and the content set, no cap smaller than the standard content (`CL-MAX-SECTIONS`, `CL-MAX-STATES`, `CL-MAX-BIOMES` in `client/copy/CLCONST.cpy`)
- [ ] T1081 [US11-client] Write test cases in `client/tests/test_mesher.cob` for a 24-section column: per-state opacity and cull tables built once at load from `CONTENT-*`, states above 255 mesh correctly, section height is the dimension's
- [ ] T1082 [US11-client] Re-base `client/src/mesher.cob` on the new cell model and the per-state tables (rewrite of the "16-high section" assumption)
- [ ] T1083 [US11-client] Update `client/src/protocol-client.cob` chunk handling to decode both forms and split the file by packet family into `client/src/protocol-world.cob`, `protocol-play.cob`, `protocol-config.cob` as it is touched (1,646 lines)
- [ ] T1084 [US11-client] Write contract test cases in `client/tests/contract_wire_client.cob` for the chunk, registry and tags fixtures it receives
- [ ] T1085 [US11-client] Update `client/src/sp-host.cob` for the new core API (settings, three dimensions) and its tests `client/tests/test_sp_host.cob`
- [ ] T1086 [US11-client] Gate: run `make gate-client` and record the command and real output

#### Phase 55: US1-client — start-up check and banner

- [ ] T1087 [US1-client] Write test `client/tests/test_args.cob` cases for `--generated-dir` (22 §5.1) and the default `<game dir>/generated`
- [ ] T1088 [US1-client] Add `--generated-dir` to `client/src/args.cob` and `client/copy/CLARGS.cpy`
- [ ] T1089 [US1-client] Write acceptance test `client/tests/acc_f2us1_banner.cob` (US1-3): with no valid packs the title screen shows the built-in-language banner `cobolcraft.packs.*` (`docs/protocol/22-extraction-tool.md` §9.2) stating the status and how to build the packs; with valid packs the banner is absent; the cobolcraft type is unaffected [FR-001, FR-002; SC-012]
- [ ] T1090 [US1-client] Implement the start-up `CORE-PACKS-STATUS` call, the banner state and the title screen banner in `client/src/main.cob` and `client/src/screens/title.cob`
- [ ] T1091 [US1-client] Write acceptance test `client/tests/acc_f2us1_loaders.cob` (US1-4, real input): after a real extraction into `build/generated-test/` the client's content open of the standard set reports no loader error [FR-001, FR-002; SC-012]
- [ ] T1092 [US1-client] Gate: run `make gate-client` and record the command and real output

#### Phase 56: US2-client — world type choice, remembered type, refusal

- [ ] T1093 [US2-client] Write acceptance test `client/tests/acc_f2us2_create_screen.cob` (US2-1, US2-2, FR-003): with valid packs both types are offered and standard is the default; with packs not `ok` the standard choice stays selectable and Create is refused with the explanation text `cobolcraft.world_type.*` of how to build the packs, and nothing is created; the cobolcraft type creates [SC-011]
- [ ] T1094 [US2-client] Add the type choice, the refusal text and the settings fill (`CS-WORLD-TYPE`, `CS-SEED-TEXT`) to `client/src/screens/create-world.cob`
- [ ] T1095 [US2-client] Write acceptance test `client/tests/acc_f2us2_world_list.cob` (US2-3): the world list shows each world's type; opening a standard world with packs not `ok` is refused with the reason (`docs/design/world-types.md` §8.2) [FR-003, FR-004, FR-005, FR-037; SC-011]
- [ ] T1096 [US2-client] Implement the type column and the refusal in `client/src/screens/world-list.cob` and `client/src/game-dir.cob`
- [ ] T1097 [US2-client] Write test `client/tests/test_wt16.cob`: on a multiplayer join the client decides the world type from `minecraft:dimension_type` at Finish Configuration (WT-16) and opens the matching content set
- [ ] T1098 [US2-client] Implement the WT-16 decision in `client/src/net-client.cob`
- [ ] T1099 [US2-client] Add built-in-language entries `cobolcraft.packs.*` and `cobolcraft.world_type.*` to `client/src/packs/builtin.cob` (texts from `docs/design/builtin-ui-art.md` §7.2) with their test cases in `client/tests/test_builtin_files.cob`
- [ ] T1100 [US2-client] Gate: run `make gate-client` and record the command and real output

#### Phase 57: US3-client — pack stack and user packs

- [ ] T1101 [US3-client] Write acceptance test `client/tests/acc_f2us3_pack_stack.cob` (US3-5, US3-6): stack order of `docs/design/faithful-pack-mapping.md` §9.1 bottom to top: built-in (1), optional skin (2, absent unless enabled), generated vanilla (3), the user's packs in the user's order (4), server packs (5); the top-most pack that has a path wins (08 §3.2); `minecraft:` anywhere a vanilla equivalent exists; a pack's `minecraft:` textures do not touch `cobolcraft:` content unless the optional skin is on (FR-006) [SC-001]
- [ ] T1102 [US3-client] Extend `client/src/packs/stack.cob` with the five levels of §9.1 (generated vanilla at level 3, a slot for the skin at level 2) and by-path override across them
- [ ] T1103 [US3-client] Write acceptance test `client/tests/acc_f2us3_user_pack.cob` (US3-1, US3-4, real input): the real Faithful zip lists on the pack screen, enables, moves and survives a restart; disabling returns the generated look [FR-007, FR-008, FR-009, FR-010; SC-001]
- [ ] T1104 [US3-client] Make user packs from `resourcepacks/` load by zip or folder in `client/src/packs/local.cob`
- [ ] T1105 [US3-client] Write test `client/tests/test_atlas.cob` cases for a generic sprite size (16 and 32 pixels from the packs, not a constant) and more than 128 sprites (1,297 block sprites for Faithful)
- [ ] T1106 [US3-client] Rewrite `client/src/atlas.cob` stitching for any sprite size and count (`CL-MAX-SPRITES` sized from the packs)
- [ ] T1107 [US3-client] Write test `client/tests/test_animation.cob`: `.mcmeta` animation files (frame order, frame time, interpolate) schedule frame updates per cell (14, FR-010); a malformed animation file falls back to the pack below
- [ ] T1108 [US3-client] Implement animation timers in `client/src/packs/mcmeta.cob` and the per-frame `cc_vk_texture_update` calls in `client/src/render-list.cob`
- [ ] T1109 [US3-client] Write edge-case test `client/tests/test_pack_bad_texture.cob` (spec edge case): a texture the client cannot decode makes that sprite fall back to the pack below it, the rest of the pack loads, nothing crashes
- [ ] T1110 [US3-client] Write edge-case test `client/tests/test_pack_bad_animation.cob` (spec edge case): a malformed animation file leaves the sprite static from the pack below and the rest of the pack loads
- [ ] T1111 [US3-client] Write edge-case test `client/tests/test_connected_ignored.cob` (spec edge case, FR-010): a connected-texture rule the client does not support is ignored without error
- [ ] T1112 [US3-client] Make unsupported rules, undecodable textures and malformed animations non-fatal with fallback to the pack below in `client/src/packs/source.cob` and `client/src/packs/mcmeta.cob`
- [ ] T1113 [US3-client] Write edge-case test `client/tests/test_pack_removed.cob` (spec edge case): a pack zip removed or renamed while enabled makes the stack fall back and the pack screen says so
- [ ] T1114 [US3-client] Write edge-case test `client/tests/test_pack_same_path.cob` (spec edge case): two packs supplying the same path, the higher pack in the stack wins
- [ ] T1115 [US3-client] Write acceptance test `client/tests/acc_f2us3_pack_screen.cob` (US3-1): the pack screen lists, enables, disables and reorders, and the removed-zip and same-path edge cases above show on it [FR-007, FR-008, FR-009, FR-010; SC-001]
- [ ] T1116 [US3-client] Update `client/src/screens/pack-select.cob` for the new states
- [ ] T1117 [US3-client] Write acceptance test `client/tests/acc_f2us3_skin.cob` (FR-006, FR-005): the optional Faithful skin is off by default; enabling it on the resource pack screen of a cobolcraft-type world inserts it at level 2; with it on, the cobolcraft blocks and items resolve the `minecraft:` texture ids of `docs/design/faithful-pack-mapping.md` §3 and §4 from the Faithful zip, while the `turf` models and the entity strips keep the built-in art; with it off, or in a standard world, `cobolcraft:` content is untouched; the choice persists across a restart [SC-001]
- [ ] T1118 [US3-client] Implement the skin pack in `client/src/packs/builtin.cob` (the model overrides of §9.3, no texture shipped) and `client/src/packs/stack.cob` (level 2, off by default) and its toggle row in `client/src/screens/pack-select.cob`, persisted with the enabled packs
- [ ] T1119 [US3-client] Write acceptance test `client/tests/acc_f2us3_coverage_walk.cob` (US3-2, SC-001): with the real Faithful zip, a checklist walk resolves blocks, items, mobs, GUI sprites, particles, weather and font from the pack and no resolved sprite is the missing-texture stripe where the pack covers it (FR-015 keeps the stripes elsewhere)
- [ ] T1120 [US3-client] Make the walk pass: add the resolution paths for GUI, particle, weather and font sprites in `client/src/packs/stack.cob`, `client/src/ui-render.cob`, `client/src/weather-render.cob`
- [ ] T1121 [US3-client] Gate: run `make gate-client` and record the command and real output

#### Phase 58: US4-client — Open Pack Folder

- [ ] T1122 [US4-client] Write acceptance test `client/tests/acc_f2us4_open_folder.cob` (US4-1, US4-2, Q-2): the client state names the opener program; the test sets `/usr/bin/true`, presses Open Pack Folder, `resourcepacks/` is created if missing and the opener received the folder; a pack copied in is listed after refresh without a restart; one run line names the opener substituted [FR-008; SC-010]
- [ ] T1123 [US4-client] Write contract test `client/tests/contract_opener_production.cob`: a fresh client state names exactly `/usr/bin/open`, and a missing opener gives the `CC-NOTFOUND` path shown on the screen without a crash
- [ ] T1124 [US4-client] Implement the opener state, the button and `PACK-FOLDER-SCAN` refresh in `client/src/screens/pack-select.cob` and `client/copy/CLSTATE.cpy`
- [ ] T1125 [US4-client] Gate: run `make gate-client` and record the command and real output

#### Phase 59: US5-client — seamless textures

- [ ] T1126 [US5-client] Write acceptance test `client/tests/acc_f2us5_seams.cob` (US5-1, SC-002): atlas readback shows padding around each cell per 12 §2.2 and §2.3 so a mip level of any cell never contains a neighbour's colour (fixtures with distinct cell colours at 16 and 32 pixels) [FR-011]
- [ ] T1127 [US5-client] Implement padded stitching and the mip level count in `client/src/atlas.cob` and the `cc_vk_texture_ex` call in `client/src/render-list.cob`
- [ ] T1128 [US5-client] Write test `client/tests/test_weather_atlas.cob` (CC-0003): rain and snow images of co-prime heights (17 and 19) produce a bounded weather atlas
- [ ] T1129 [US5-client] Bound the weather atlas in `client/src/weather-render.cob` and `client/src/atlas.cob`
- [ ] T1130 [US5-client] Gate: run `make gate-client` and record the command and real output

#### Phase 60: US6-client — HUD and screens

- [ ] T1131 [US6-client] Write acceptance test `client/tests/acc_f2us6_layout.cob` (US6-1, SC-003): the HUD, inventory and menus at every GUI scale from 1 to the maximum, at the smallest supported window size and below it (edge case) have no overlapping or clipped element (render list bounds) [FR-013, FR-014, FR-015]
- [ ] T1132 [US6-client] Implement the layout rules (alignment, spacing, GUI scale, minimum window size from Round GUI) in `client/src/ui-render.cob`
- [ ] T1133 [US6-client] Write acceptance test `client/tests/acc_f2us6_counts.cob` (US6-2, FR-014): edge cases: a slot with 1 item shows no count, and the cases 2, 64 and a count too wide for the slot each show it aligned and unclipped (four named cases) [SC-003]
- [ ] T1134 [US6-client] Implement the count rule in `client/src/ui-render.cob`
- [ ] T1135 [US6-client] Write acceptance test `client/tests/acc_f2us6_nine_slice.cob` (US6-3): with the Faithful fixture the screens' sprites, nine-slice scaling and font follow the pack's GUI textures (12 §5, 14 §6) [FR-013, FR-014, FR-015; SC-003]
- [ ] T1136 [US6-client] Implement nine-slice drawing and pack font use in `client/src/ui-render.cob` and `client/src/packs/font.cob`
- [ ] T1137 [US6-client] Write acceptance test `client/tests/acc_f2us6_builtin_art.cob` (US6-4): in a cobolcraft world with no pack the screens use the built-in art, font and language and nothing is blank (`docs/design/builtin-ui-art.md`) [FR-013, FR-014, FR-015; SC-003]
- [ ] T1138 [US6-client] Complete the built-in UI art, glyphs and language in `client/src/packs/builtin.cob`, `client/copy/CLGLYPHS.cpy`, `client/copy/CLBUILTIN.cpy`
- [ ] T1139 [US6-client] Restyle the HUD in `client/src/screens/hud.cob` and the title, pause, world list, create-world screens (`client/src/screens/*.cob`) to the layout rules
- [ ] T1140 [US6-client] Gate: run `make gate-client` and record the command and real output

#### Phase 61: US7-client — flight only in creative

- [ ] T1141 [US7-client] Write acceptance test `client/tests/acc_f2us7_survival_climb.cob` first, reproducing the first run's survival climb (P-client-5): in survival, double Space in the air and Space held in the air never rises above one jump height from the ground and never starts flying; record the failing observation [FR-016, FR-017; SC-004]
- [ ] T1142 [US7-client] Write acceptance test `client/tests/acc_f2us7_creative_flight.cob` (US7-1, SC-004): in creative double Space toggles flying 20 of 20 times; in survival 0 of 20; spectator follows `docs/protocol/13` §1.4 [FR-016, FR-017]
- [ ] T1143 [US7-client] Fix the jump and flight rules in `client/src/physics.cob` (jump only while on ground; flight toggle only when the abilities grant it) so both tests pass. If the cause is a core acceptance of `on-ground`, stop and escalate to multi-package
- [ ] T1144 [US7-client] Write test case in `client/tests/test_physics.cob` for held Space on the ground in survival: repeats jumps as before, never exceeds one jump height in the air (edge case)
- [ ] T1145 [US7-client] Gate: run `make gate-client` and record the command and real output

#### Phase 62: US8-client — break overlay

- [ ] T1146 [US8-client] Write acceptance test `client/tests/acc_f2us8_overlay.cob` (US8-1 to US8-4): Block Destruction stages 0 to 9 draw the crack overlay on the block, stage -1 and a released button remove it, another player's stage draws too, and the overlay uses the pack's break-stage textures (12 §4, `faithful-pack-mapping.md`) [FR-023; SC-006]
- [ ] T1147 [US8-client] Implement the break overlay in `client/src/break-overlay.cob` and its draw in `client/src/render-list.cob`
- [ ] T1148 [US8-client] Write edge-case test `client/tests/test_overlay_many.cob` (spec edge cases): several players break different blocks at once and each block shows its own stage; progress interrupted by a held-item change, a changed target or another player's break removes the overlay
- [ ] T1149 [US8-client] Write test `client/tests/test_dig_actions.cob`: the client sends Player Action start, abort and finish with sequence ids (13 §2.3) and aborts on a held item change
- [ ] T1150 [US8-client] Implement the dig action sending in `client/src/controls.cob`
- [ ] T1151 [US8-client] Gate: run `make gate-client` and record the command and real output

#### Phase 63: US9-client — inventory screen and recipe book

- [ ] T1152 [US9-client] Write acceptance test `client/tests/acc_f2us9_inventory.cob` (US9-1, US9-3): the inventory screen is the 46-slot menu with the 2x2 grid, result slot and off-hand slot, laid out per 12 §5.6a; clicks send Container Click [FR-024, FR-025, FR-028; SC-005]
- [ ] T1153 [US9-client] Rewrite `client/src/screens/inventory.cob` and `client/src/inventory-replica.cob` for the 46-slot menu and item stacks with components
- [ ] T1154 [US9-client] Write acceptance test `client/tests/acc_f2us9_recipe_book.cob` (US9-2, SC-005): known recipes listed with makeable ones marked, tabs and toasts per Round GUI, choosing one sends Place Recipe and the grid fills (13 §3.8, §3.9) [FR-024, FR-025, FR-028]
- [ ] T1155 [US9-client] Implement the recipe book panel in `client/src/screens/recipe-book.cob`
- [ ] T1156 [US9-client] Write edge-case test `client/tests/test_recipe_book_edges.cob` (spec edge case): the recipe book with no known recipes shows the empty state; a bench-only recipe in the inventory screen is shown unavailable; a failed fill with a full inventory leaves the grid and shows nothing broken
- [ ] T1157 [US9-client] Write acceptance test `client/tests/acc_f2us9_creative_throw.cob` (CC-0006): in creative a cursor stack released outside the window sends the drop [FR-024, FR-025, FR-028; SC-005]
- [ ] T1158 [US9-client] Implement the creative throw in `client/src/screens/inventory.cob`
- [ ] T1159 [US9-client] Remove the 001 crafting screen and the C key (FR-028, US9-4): delete `client/src/screens/crafting.cob`, `client/tests/acc_us10_crafting_screen.cob`, `client/tests/test_crafting.cob`, the C key binding in `client/src/screens/common.cob`, and the 16-recipe client table (`CL-MAX-RECIPES`)
- [ ] T1160 [US9-client] Write contract test cases in `client/tests/contract_wire_client.cob` for the container and recipe-book fixtures
- [ ] T1161 [US9-client] Gate: run `make gate-client` and record the command and real output

#### Phase 64: US10-client — crafting bench screen

- [ ] T1162 [US10-client] Write acceptance test `client/tests/acc_f2us10_bench_screen.cob` (US10-2): Open Screen for the bench menu shows the 3x3 grid, result slot and recipe book (12 §5.6b); the bench block and item draw from their texture paths [FR-026, FR-027; SC-005]
- [ ] T1163 [US10-client] Implement the bench screen in `client/src/screens/bench.cob`
- [ ] T1164 [US10-client] Gate: run `make gate-client` and record the command and real output

#### Phase 65: US11-client (b) — biome tint

- [ ] T1165 [US11-client] Write test `client/tests/test_biome_tint.cob`: grass, foliage and water tints per biome and colour map (43 and Round TINT) applied by the mesher to tinted faces
- [ ] T1166 [US11-client] Implement biome tinting in `client/src/mesher.cob` and the tint tables load in `client/src/models.cob`
- [ ] T1167 [US11-client] Gate: run `make gate-client` and record the command and real output

#### Phase 66: US12-client — particles, dimensions, container screens

- [ ] T1168 [US12-client] Write test `client/tests/test_particles.cob`: the particle engine of `docs/protocol/42-particles-1-shared-model-engine.md` and the effects, fluid-drip, block/item/dust, sculk and emitter families of parts 2 to 7 from Level Particles and Level Event
- [ ] T1169 [US12-client] Implement particles in `client/src/particles.cob`
- [ ] T1170 [US12-client] Write acceptance test `client/tests/acc_f2us12_dimension_travel.cob` (US12-3): Respawn/Login for the Nether and the End swaps the replica, the dimension's tints and sky-less look, and a portal overlay screen shows during the change [FR-031, FR-032, FR-038]
- [ ] T1171 [US12-client] Implement dimension change handling in `client/src/world-replica.cob` and `client/src/screens/connecting.cob` plus a portal overlay in `client/src/screens/portal.cob`
- [ ] T1172 [US12-client] Write test `client/tests/test_container_screens.cob`: the container screens of 40 (furnace, brewing, anvil, grindstone, smithing, enchanting, loom, stonecutter, cartography, merchant, beacon, lectern, hopper, dispenser, horse, creative inventory, book and sign editors) lay out their slots per the menu layouts
- [ ] T1173 [US12-client] Implement the container screens in `client/src/screens/containers.cob`
- [ ] T1174 [US12-client] Gate: run `make gate-client` and record the command and real output

#### Phase 67: US13-client — suggestions and completions

- [ ] T1175 [US13-client] Write acceptance test `client/tests/acc_f2us13_suggestions.cob` (US13-1): the received command tree drives Tab completion and the chat suggestions list including the server's Command Suggestions responses (15 §14) [FR-034; SC-008]
- [ ] T1176 [US13-client] Update `client/src/screens/chat.cob` and `client/src/net-client.cob` for the full node tree and suggestion responses
- [ ] T1177 [US13-client] Gate: run `make gate-client` and record the command and real output

#### Phase 68: US14-client — durability bars and effects

- [ ] T1178 [US14-client] Write test `client/tests/test_item_bars.cob`: the damage bar of a tool at fractions of durability and the effects HUD of Update Mob Effect (17 §1, §5)
- [ ] T1179 [US14-client] Implement the bars and effects HUD in `client/src/ui-render.cob` and `client/src/screens/hud.cob`
- [ ] T1180 [US14-client] Gate: run `make gate-client` and record the command and real output

#### Phase 69: US15-client — entity models

- [ ] T1181 [US15-client] Write test `client/tests/test_entity_models.cob`: model, texture and animation per family from `docs/protocol/34-entity-models-1-shared-model-and-framework.md` with the humanoid, farm animal, wild animal, hostile, nether and end, aquatic and non-living parts as fixtures
- [ ] T1182 [US15-client] Implement the entity model engine in `client/src/entity-models.cob` and update `client/src/entities-render.cob`
- [ ] T1183 [US15-client] Write test `client/tests/test_default_skin.cob`: the default skin and the player model (`47-default-skin.md`)
- [ ] T1184 [US15-client] Implement the player model and default skin in `client/src/player-model.cob`
- [ ] T1185 [US15-client] Write test `client/tests/test_entity_replica.cob`: Spawn Entity, Set Entity Data (every serializer) and Update Attributes populate the entity replica
- [ ] T1186 [US15-client] Update `client/src/entities-replica.cob` for the full entity packet set
- [ ] T1187 [US15-client] Gate: run `make gate-client` and record the command and real output

#### Phase 70: US16-client — Options and `options.txt`

- [ ] T1188 [US16-client] Write contract test `client/tests/contract_client_surface.cob`: the documented key to action table (13 §7.3) and the `options.txt` round trip against `contract/fixtures/client/options-*.txt`
- [ ] T1189 [US16-client] Write test `client/tests/test_options_file.cob`: read and write of `options.txt` (13 §7.1) for every option (SC-009)
- [ ] T1190 [US16-client] Write edge-case test `client/tests/test_options_missing.cob` (spec edge case): a missing `options.txt` yields defaults and the game starts
- [ ] T1191 [US16-client] Write edge-case test `client/tests/test_options_unreadable.cob` (spec edge case): an unreadable or corrupt `options.txt` yields defaults and the game starts
- [ ] T1192 [US16-client] Write edge-case test `client/tests/test_options_range.cob` (spec edge case): an out-of-range value yields that option's default and the others keep their values
- [ ] T1193 [US16-client] Implement `options.txt` load and save in `client/src/options.cob` and replace `OPTIONS-LOAD` and `OPTIONS-SAVE` in `client/src/game-dir.cob`
- [ ] T1194 [US16-client] Write test `client/tests/test_options_migration.cob`: with no `options.txt`, the legacy `options.dat` `EnabledPacks` list is read once and never written again (R8)
- [ ] T1195 [US16-client] Implement the read-only migration in `client/src/options.cob`
- [ ] T1196 [US16-client] Write acceptance test `client/tests/acc_f2us16_options_screen.cob` (US16-1, US16-2, SC-009): Options opens from the title screen and the pause menu; view distance, sensitivity, FOV, GUI scale and every other option of 13 §7.2 and Round OPT change, apply at once and persist across a restart [FR-022]
- [ ] T1197 [US16-client] Implement the Options screens in `client/src/screens/options.cob` and wire the buttons in `client/src/screens/title.cob` and `client/src/screens/pause.cob`
- [ ] T1198 [US16-client] Write test `client/tests/test_key_bindings.cob`: the default key table of 13 §7.3 and rebinding persisted in `options.txt`
- [ ] T1199 [US16-client] Implement the key table in `client/src/controls.cob`
- [ ] T1200 [US16-client] Gate: run `make gate-client` and record the command and real output

#### Phase 71: US17-client — F3 overlay

- [ ] T1201 [US17-client] Write acceptance test `client/tests/acc_f2us17_f3.cob` (US17-1, US17-2): F3 shows position, block, chunk, facing, dimension, frame rate and the other entries of 13 §5 from the replica and physics state; F3 again hides it [FR-018]
- [ ] T1202 [US17-client] Implement the overlay in `client/src/debug-overlay.cob` and the F3 binding in `client/src/controls.cob`
- [ ] T1203 [US17-client] Gate: run `make gate-client` and record the command and real output

#### Phase 72: US18-client — F5 camera

- [ ] T1204 [US18-client] Write acceptance test `client/tests/acc_f2us18_f5.cob` (US18-1): repeated F5 cycles first person, behind, in front, first person (13 §6) [FR-019]
- [ ] T1205 [US18-client] Write test `client/tests/test_camera_clip.cob` (US18-2, spec edge case): the third-person camera raycasts against blocks, and inside a one-block-high space it shortens rather than passing through blocks (12 §7)
- [ ] T1206 [US18-client] Implement the camera modes and clipping in `client/src/camera.cob` and `client/src/raycast.cob`
- [ ] T1207 [US18-client] Write test `client/tests/test_self_model.cob`: the Player's own model is drawn in third person and not in first person
- [ ] T1208 [US18-client] Draw the own player model in `client/src/entities-render.cob`
- [ ] T1209 [US18-client] Gate: run `make gate-client` and record the command and real output

#### Phase 73: US19-client — off-hand swap

- [ ] T1210 [US19-client] Write acceptance test `client/tests/acc_f2us19_swap.cob` (US19-1 to US19-3): F with no screen sends the swap action; F over a hovered slot in the inventory screen sends a Container Click swap with slot 45; the off-hand slot draws beside the hotbar [FR-020]
- [ ] T1211 [US19-client] Write edge-case test `client/tests/test_swap_empty.cob` (spec edge case): F with an empty hand, an empty off hand, or both sends the swap and the screen shows no stale stack
- [ ] T1212 [US19-client] Implement the F key and the off-hand HUD in `client/src/controls.cob` and `client/src/screens/hud.cob`, and the hovered-slot swap in `client/src/screens/inventory.cob`
- [ ] T1213 [US19-client] Gate: run `make gate-client` and record the command and real output

#### Phase 74: US20-client — hand and held item

- [ ] T1214 [US20-client] Write acceptance test `client/tests/acc_f2us20_hand.cob` (US20-1, US20-2): in first person the hand is in the render list at the lower right holding the selected item or block as a small 3D model after a depth clear, and breaking, placing or attacking plays the swing (12 §6) [FR-021]
- [ ] T1215 [US20-client] Implement the hand pass in `client/src/hand.cob` and its submit order in `client/src/submit.cob` with `cc_vk_clear_depth`
- [ ] T1216 [US20-client] Gate: run `make gate-client` and record the command and real output

---

## Phase 75: Convergence (cross-package tests, aggregate gate, manual vanilla run)

**Purpose**: scenarios that need more than one package, run in-process through the client's single-player host and the core TCP host on loopback (`tests/convergence/`), the updates the supersessions force on 001's Convergence tests, and the recorded manual verification of Q-1. No E2E (inventory empty).

- [ ] T1217 [US1] Write `tests/convergence/acc_f2us1_start_check.cob` (real jar): extract to `build/generated-test/`, then the client and the server both report packs `ok` and load the packs with no loader error; a tampered manifest is reported `stale` by both [FR-001, FR-002; SC-012]
- [ ] T1218 [US2] Write `tests/convergence/acc_f2us2_no_jar.cob` (SC-011, FR-005, quickstart §8): with no jar, no `generated/` directory and no `resourcepacks/*` present, a cobolcraft world is created, played (move, place, break, craft at the bench) and reopened, every texture, glyph and text coming from the built-in pack, and the standard type is selectable but Create is refused with the explanation (FR-003)
- [ ] T1219 [US2] Write `tests/convergence/acc_f2us2_world_type.cob` (US2-1 to US2-4, FR-002 to FR-004, SC-011): create one world of each type through the client host, restart, each reopens as its type and behaves by the shared rules; the standard world with the generated directory removed is refused with the reason
- [ ] T1220 [US8] Write `tests/convergence/acc_f2us8_second_player_crack.cob`: two clients on loopback, one holds break, the other sees the stages 0 to 9 and the removal [FR-023; SC-006]
- [ ] T1221 [US9] Write `tests/convergence/acc_f2us9_inventory_craft.cob`: through the inventory screen model place ingredients, take the result, ingredients consumed; recipe book Place Recipe fills the grid [FR-024, FR-025, FR-028; SC-005]
- [ ] T1222 [US10] Write `tests/convergence/acc_f2us10_bench.cob`: craft, place and use the bench, make a 3x3 recipe; replaces `tests/convergence/acc_us10_crafting.cob` [FR-026, FR-027; SC-005]
- [ ] T1223 [US13] Write `tests/convergence/acc_f2us13_commands.cob`: a level-0 and a level-4 client receive different command trees; `/give` runs with completions end to end [FR-034; SC-008]
- [ ] T1224 [US19] Write `tests/convergence/acc_f2us19_swap.cob`: F swap and hovered-slot swap end to end with the Set Slot updates [FR-020]
- [ ] T1225 [US12] Write `tests/convergence/acc_f2us12_dimensions.cob`: a portal trip to the Nether and back through the client and server, the replica swapping dimensions [FR-031, FR-032, FR-038]
- [ ] T1226 [US2] Update the 001 Convergence tests that the supersessions change, one task per file: delete `tests/convergence/acc_us10_crafting.cob`
- [ ] T1227 [US2] Update `tests/convergence/acc_us12_dimensions.cob` for three dimensions and the standard timeline
- [ ] T1228 [US2] Update `tests/convergence/acc_us4_controls_to_world.cob` for the new controls and the 46-slot menu
- [ ] T1229 [US2] Update `tests/convergence/acc_us5_inventory_throw.cob` for the creative throw (CC-0006) and the retired stand-in values
- [ ] T1230 [US2] Update `tests/convergence/acc_us16_single_player.cob` and `acc_us17_open.cob` for world types and the `options.txt` file
- [ ] T1231 Gate: run `make gate` (lint, build, instrumented coverage over every package and the Convergence tests, `gate-tools`) and record the command and real output
- [ ] T1232 Write the operator instructions for the Q-1 manual run (`quickstart.md` §9) into `specs/002-client-polish/vanilla-client-evidence.md` with the status line `Status: pending operator` and the steps (start `build/bin/cobolcraft-server` with `world-type=standard` and the generated packs; connect the operator's vanilla 26.3 client offline to `localhost`; expected: configuration completes with no registry, tag or known-packs error and the spawn chunks render; then a cobolcraft-type server and configuration only), plus an empty section for the real server console lines and the observed client state (SC-013)
- [ ] T1233 OPERATOR-BLOCKING (Q-1, SC-013, FR-039; does not block Polish or any Gate): the operator runs the vanilla client against the server as the instructions say and replaces `Status: pending operator` with `Status: done` after pasting the real console lines and the observed state. An automated implementation run stops its work on this task here, leaves the file as `pending operator`, and continues with Polish; the project's terminal `make gate` and the Polish Gate do not read this file

---

## Phase 76: Polish and cross-cutting concerns

- [ ] T1234 Delete the 001 chunk codec functions `PB-PUT-CHUNK` and `PB-GET-CHUNK` kept additive in `proto/src/chunk.cob` with their tests in `proto/tests/test_chunk.cob`, after confirming with `grep` that no caller remains in `core`, `client`, `server`, `tests/convergence`
- [ ] T1235 Final debt check of the files this feature touched (constitution 5.7, plan "Technical debt survey"): `grep -in "TODO\|FIXME\|HACK\|GCOV_EXCL\|nolint"` over `shim`, `formats`, `proto`, `content`, `extract`, `core`, `server`, `client`, `tools`, `Makefile` returns nothing, and no file the plan named as sprawled (`core/src/commands.cob`, `core/src/persistence.cob`, `client/src/protocol-client.cob`) remains
- [ ] T1236 Complete `README.md`: how to build the packs (`cobolcraft-extract`), world types, resource packs and Open Pack Folder, options, controls (F3, F5, F), the test inputs in `tmp/`, no jar or generated file committed
- [ ] T1237 Review task: walk `specs/002-client-polish/quickstart.md` sections 0 to 8 against the built binaries and confirm each stated expectation; record deviations as findings
- [ ] T1238 Judge CC-0002 (chunk meshing performance) against the measured `acc_us3_streaming` and gate times; keep the ticket open or update it with the figures (Spile skill `.claude/skills/spile/SKILL.md`)
- [ ] T1239 Close CC-0003, CC-0005 and CC-0006 (`tickets/`) with the spile skill, citing the tasks that fixed them (weather atlas, free-port server tests, creative throw)
- [ ] T1240 Update the feature's own record `tickets/CC-0001-client-polish.md` (status, implementation, resolution) and regenerate `tickets/views/cobolcraft-view.md` with `python3 .claude/skills/spile/scripts/view.py tickets`
- [ ] T1241 Update `.claude/skills/cobolcraft-cobol/SKILL.md` with the pitfalls found in this feature (GnuCOBOL by-reference double arithmetic, generated copybook rows, new package Makefiles)
- [ ] T1242 Gate: run `make gate` and record the command and real output (terminal aggregate; no E2E; independent of the operator-blocking Q-1 evidence, which may still read `pending operator`)

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (1)**: none. **Foundational (2)**: after Setup; blocks everything. Its docs rounds (2a) precede the lanes so lanes stay independent.
- **Parallel group (3 to 74)**: starts after the Foundational Gate; lanes are mutually independent except the edges listed under the group heading; within a lane phases run in order.
- **Convergence (75)**: after every lane gate. **Polish (76)**: after the Convergence aggregate Gate; it does not wait for the operator-blocking Q-1 run.

### Story dependencies (lane edges)

- US1: formats US1 -> content US1 -> extract US1 -> core/server/client US1.
- US2: content US2 -> core US2 -> server/client US2; client US11 (a) runs first in the client lane (needs proto US11).
- US3 to US5: shim US3/US5, formats US3 -> client US3 to US5. US4: shim US4 -> client US4.
- US8 to US10: proto US8/US9, content US9/US10, core US8 to US10 -> client US8 to US10.
- US11 to US15: shim US11, proto US11/US12/US13/US14/US15, content US11 to US15 -> core -> client. US16 to US18, US20: client (US20 needs shim US20). US19: proto US19 -> core US19 -> client US19. US21: core and server only; manual run in Convergence.

### Parallel opportunities

- Setup: skeleton Makefiles, then generator tests. Foundational: every `[P]` clean-room round (reader tasks of different rounds are independent), the copybook and fixture tasks.
- Lanes: `shim`, `formats`, `proto` run concurrently from the start; `content` follows `formats` US1; `core`, `server`, `client` follow their provider slices; `extract` follows `content` US1.
- Within a phase, `[P]` tests run together; implementation tasks follow their tests.

### Disjointness check (constitution 5.2)

Each lane task names targets only under its own package directory; shared inputs (`contract/`, `docs/`, `specs/`, `tools/`, `Makefile`) are written only in Setup, Foundational, Polish. Two deliberate placements: the extraction tool's consumer test lives in `extract/tests/` (not `content/tests/`), and the generator tables live under `content/copy/gen/` but are produced by Foundational. Verified mechanically at generation time (see the report).

## Implementation Strategy

### MVP first

1. Setup and Foundational (docs rounds, contracts, generator, formats move).
2. Lanes for US1 and US2 (extraction tool, content sets, world types), then US3 to US6 (the look), then US7 (flight): the first demonstrably better build, with the cobolcraft world type playable with no jar.
3. Stop and validate at each lane gate; run Convergence for the stories finished.

### Incremental delivery

US7 to US10 and US16 to US20 (controls and screens) next; US11 to US15 (the standard world, commands, tools, mobs) are the largest and are cut one document family per phase, each ending in `make gate-core`; US21 closes with the manual run. Each story adds value without breaking earlier ones because both world types run on the same engines.

## Notes

- `[P]` = different files, no dependency on an incomplete task. Commit at every phase boundary after its Gate (constitution 5.3).
- A task that discovers a missing document value stops its slice; the orchestrator runs a clean-room round and the slice resumes (plan "Docs-first obligations").
- Q-1 and Q-2 are recorded operator decisions (see header); neither is reopened by tasks.
