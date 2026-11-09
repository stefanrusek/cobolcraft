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

- [ ] T001 Add `generated/` to `.gitignore` at the repository root (SC-012: no generated or jar file is ever committed)
- [ ] T002 Write implementation test cases in `tools/tests/test_runtests.py` expecting `PACKAGES` and `DEPENDENCIES` of `tools/runtests.py` to contain `formats`, `content`, `extract` in dependency order (`shim, formats, proto, content, core, server, client, extract`; extract depends on shim, proto, formats, content)
- [ ] T003 Extend `PACKAGES` and `DEPENDENCIES` in `tools/runtests.py` with `formats`, `content`, `extract` so the test of the previous task passes
- [ ] T004 Write acceptance test `tools/tests/acc_f2us1_gate_targets.py` asserting `make -n gate-formats gate-content gate-extract gate-tables` resolves each target and that `make -n build` names `build/bin/cobolcraft-extract` (contracts/test-harness-delta.md)
- [ ] T005 Extend the root `Makefile`: `PKGS := shim formats proto content core server client extract`, `DEPS_` and `TARGETS_` per package (`DEPS_formats := shim`; `DEPS_content := shim proto formats`; `DEPS_extract := shim proto formats content` because extract reads the accepted-jar table and `CONTENT-PACKS-CHECK` from content; `TARGETS_extract := lib bin`), `gate-<pkg>` for the new packages and a `gate-tables` target running `python3 tools/gen/gen_tables.py --check`, and make `gate-tools` and `gate-contract` depend on `gate-tables`
- [ ] T006 [P] Create `formats/Makefile` including `tools/package.mk` with `PKG := formats`, `LIBNAME := libformats.a` and empty `SRC` and `TESTS` lists, and the directories `formats/src`, `formats/tests`, `formats/copy` (skeleton; `make gate-formats` exits 0 on the empty package)
- [ ] T007 [P] Create `content/Makefile` including `tools/package.mk` with `PKG := content`, `LIBNAME := libcontent.a`, empty `SRC` and `TESTS` lists, `INCLUDES` of `content/copy` and `content/copy/gen`, and the directories `content/src`, `content/tests`, `content/copy`, `content/copy/gen`
- [ ] T008 [P] Create `extract/Makefile` including `tools/package.mk` with `PKG := extract`, `LIBNAME := libextract.a`, `TARGETS lib bin` producing `build/bin/cobolcraft-extract` from `src/main.cob`, empty `SRC` and `TESTS` lists, and the directories `extract/src`, `extract/tests`
- [ ] T009 Exclude `content/copy/gen/` (generated data, constitution 4.2) from the production set in `tools/coverage.py` and write the matching case in `tools/tests/test_coverage.py` first
- [ ] T010 Write acceptance test `tools/tests/acc_f2us1_gen_cli.py`: `python3 tools/gen/gen_tables.py --check` exits 0 on an empty table set and exits 1 naming the file when a generated file differs by one byte (drift gate, contracts/test-harness-delta.md)
- [ ] T011 Create `tools/gen/gen_tables.py` skeleton with `--check` (regenerate into a scratch directory, compare byte for byte with `content/copy/gen/`) and `--write`, no tables yet
- [ ] T012 Write implementation test `tools/tests/test_inputs.py` for the real-input convention: a COBOL test helper `TEST-INPUT-PATH` returns `$COBOLCRAFT_INPUTS/<name>` when the variable is set, else `tmp/<name>`, and a missing file makes the calling test print `TEST <case> FAIL expected=file observed=missing <path>` and exit non-zero (contracts/test-harness-delta.md "Test inputs")
- [ ] T013 Create program `TEST-INPUT-PATH` in `tools/testlib/testinput.cob` (path resolution and the loud failure) satisfying the previous test
- [ ] T014 Write acceptance test case in `tools/tests/test_bootstrap.py` expecting `sh tools/bootstrap.sh` to create `build/generated-test/` and to list `formats content extract` in its package list
- [ ] T015 Update `tools/bootstrap.sh` (package list, creation of `build/generated-test/`) so the previous test passes
- [ ] T016 Gate: run `make gate-tools` from the repository root and record the command and its real output (exit 0)

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

- [ ] T017 [P] Round OPT, reader: options screen texts, option names, ranges and key labels (`docs/design/builtin-ui-art.md` Open question 13; `docs/protocol/13-client-gameplay-and-controls.md` §7) so US16 can be built from the document
- [ ] T018 Round OPT, reviewer: contamination and completeness review of the OPT documents; every option on the Options screen has name, default, range, persisted key and text
- [ ] T019 [P] Round GUI, reader: built-in GUI art and layout values not yet read in `docs/design/builtin-ui-art.md` (sprite sizes and sheet regions the slices use, tooltip frame, recipe-book tabs and toasts, minimum window size, contrast values)
- [ ] T020 Round GUI, reviewer: contamination and completeness review of the GUI document changes
- [ ] T021 [P] Round TINT, reader: per-biome grass tint values and the 43 tint sources as `docs/design/faithful-pack-mapping.md` and `docs/protocol/43-tint-sources.md` need them
- [ ] T022 Round TINT, reviewer: contamination and completeness review
- [ ] T023 [P] Round SAVE, reader: the save layout question between `docs/protocol/07-nbt-and-anvil.md` and `docs/protocol/33-world-simulation.md` (`docs/design/world-types.md` Open question 12), then transcribe the answer into `docs/protocol/07-nbt-and-anvil.md` §9 as the world-folder contract (three dimension folders, `WorldType`, `Seed`, `ContentJar`, block states by key in palettes, WT-23)
- [ ] T024 Round SAVE, reviewer: contamination and completeness review of `07` §9 against `contracts/core-host-delta.md` §3
- [ ] T025 [P] Round SEED, reader: the seed text to seed rule (`docs/protocol/11-world-generation-caves-and-ores.md` Open question; fixes `CS-SEED-TEXT`) with worked examples
- [ ] T026 Round SEED, reviewer: contamination and completeness review (the worked examples are checked against the artifact)
- [ ] T027 [P] Round SPOPEN, reader: the single-player world opened to others (`docs/design/world-types.md` §10) so the host keeps world type and shared rules
- [ ] T028 Round SPOPEN, reviewer: contamination and completeness review
- [ ] T029 [P] Round TIBE, reader: `TestInstanceBlockEditScreen` (`docs/protocol/40-menus-9-block-editor-screens.md` Open question 1)
- [ ] T030 Round TIBE, reviewer: contamination and completeness review
- [ ] T031 [P] Round PNG, reader: the PNG kinds (colour types, bit depths, interlace, ancillary chunks) the jar and Faithful use, closing `docs/protocol/22-extraction-tool.md` Open question 7
- [ ] T032 Round PNG, reviewer: contamination and completeness review
- [ ] T033 [P] Round LIBM, reader: every `libm` function and rounding rule that documents 10, 11, 15 and 18 call for in bit-exact arithmetic, recorded as a table in `docs/protocol/10-world-generation-terrain.md` (list that fixes the `cc_f64_*` function set of `contracts/shim-delta.md`)
- [ ] T034 Round LIBM, reviewer: contamination and completeness review; the function list covers every arithmetic step in 10, 11, 15 and 18 that is not add, sub, mul, div, floor, sqrt or text conversion
- [ ] T035 [P] Write `docs/design/world-types.md` §8: the recorded behaviour of a vanilla client against a cobolcraft-type server (passes configuration only, `docs/protocol/04-registry-sync.md` §5; the WT-16 behaviour, no new design) closing Open question 8
- [ ] T036 [P] Write the design records of FR-027 in `docs/design/cobolcraft-standard-core.md`: any cobolcraft-type content the shared rules need beyond `cobolcraft:crafting_bench` (block, item, recipe, texture, tags), each with its values, before the content slice
- [ ] T037 [P] Update `docs/protocol/09-cobolcraft-profile.md` per `contracts/wire-delta.md` §2: a row per packet whose use changes (standard chat types, command tree, permission levels, Player Abilities, 46-slot inventory and crafting menus, recipe book, Block Destruction, Set Held Item, Player Action swap, entity spawn and metadata, three-dimension Login and Respawn, 24-section chunk data), written from `05a`, `05b`, `05c`
- [ ] T038 Review `docs/protocol/09-cobolcraft-profile.md` rows against `contracts/wire-delta.md` §2: every listed packet has a row with a field table and a fixture name
- [ ] T039 [P] Review task (FR-012, US5-2): every cobolcraft block, item and mob has its texture path written in `docs/design/faithful-pack-mapping.md`; write any missing row from `docs/design/standin-content.md` and `cobolcraft-standard-core.md`; an unmapped one is listed as showing the missing-texture look
- [ ] T040 Review task: `docs/design/README.md` Part 8 open items that bear on this feature are each closed by a task above or recorded as out of scope with the spec reason (sounds FR-043, unknown jar Part 7 decision 11, cobolcraft skin FR-006); update the Part 8 status lines

### 2b. Contract materialization (frozen shared surface; lanes read, never write)

- [ ] T041 Write contract test cases in `tools/tests/test_contract_check.py` expecting `tools/contract_check.py` to compile `CONTENT.cpy`, `FORMATS.cpy` and `CELLS.cpy` in the probe program, to parse every new wire fixture, and to fail on a copybook that does not compile
- [ ] T042 Extend `tools/contract_check.py` and the probe under `tools/probe/` so `make gate-contract` compiles the new copybooks and parses `contract/fixtures/wire/*.hex` including the new ones
- [ ] T043 [P] Add to `contract/include/ccshim.h`: `cc_f64_add`, `cc_f64_sub`, `cc_f64_mul`, `cc_f64_div`, `cc_f64_floor`, `cc_f64_sqrt`, `cc_f64_from_text` and the libm wrappers named by Round LIBM (all operands and results by reference, return void), `cc_vk_texture_ex(tex_id, w, h, rgba, mip_levels)`, `cc_vk_texture_update(tex_id, x, y, w, h, rgba)`, `cc_vk_clear_depth(void)`, `cc_open_path(opener, path)` (`contracts/shim-delta.md`)
- [ ] T044 [P] Add to `contract/copy/CCSHIM.cpy` the matching COBOL `CALL` shapes and the key codes `CC-KEY-F` (70), `CC-KEY-F3` (292), `CC-KEY-F5` (294) and every other key code `docs/protocol/13-client-gameplay-and-controls.md` §5.1 and §7.3 name
- [ ] T045 [P] Add to `contract/copy/COREAPI.cpy` the settings `CS-WORLD-TYPE` PIC X(10) (`standard` or `cobolcraft`), `CS-GENERATED-DIR` PIC X(1024), `CS-SEED-TEXT` PIC X(64) (empty means random), `CS-GAME-DIR` PIC X(1024), the new `CORE-WORLD-OPEN` status words (packs not ok, dimensions without level.dat, standard folders without WorldType) and the re-derived `CORE-SETTINGS-SIZE`
- [ ] T046 [P] Add to `contract/copy/PROTO.cpy` the composite records of `contracts/wire-delta.md` §3: item stack with components, entity metadata entries, chunk palette containers, command nodes, recipe book entries
- [ ] T047 [P] Create `contract/copy/CONTENT.cpy` per `contracts/content-api.md` §1: `CT-SET` (type, packs status `ok|absent|incomplete|stale|damaged`, generated directory, registry counts; EXTERNAL), `CT-BLOCK-ROW`, `CT-ITEM-ROW`, `CT-ENTITY-ROW`, `CT-STATIC-ID-ROW`, `CT-REGISTRY`, `CT-ENTRY`, `CT-TAG`, and the status-word constants
- [ ] T048 [P] Create `contract/copy/FORMATS.cpy` per `contracts/formats-api.md`: constants and record shapes (`FMZIP` handle, `FMSHA` context, `FMREGEX`, file and directory status words, `JSON-STRICT` reason codes)
- [ ] T049 [P] Create `contract/copy/CELLS.cpy`: the one cell and chunk layout replacing core `CHUNKMEM.cpy` and client `CLCELLS.cpy` (2-byte block state, 4-bit sky and block light, sections from the dimension's `min_y` and `height`, 3 dimensions, biome containers; `docs/protocol/06-chunk-format.md`, data-model §4); copybook only, adopted by core and client in their lanes
- [ ] T050 [P] Create `contract/copy/JSONDOC.cpy` by moving `client/copy/JSONDOC.cpy` there unchanged (shared by formats, content, client)
- [ ] T051 [P] Create fixtures under `contract/fixtures/formats/`: small hand-made zip (stored and deflated entries, a bad CRC, a zip64 marker, an encrypted entry), strict-JSON accept and reject files (comments, trailing comma, duplicate key), PNG files of every kind Round PNG lists
- [ ] T052 [P] Create fixtures under `contract/fixtures/content/`: a small valid generated directory tree (manifest, sentinels, `vanilla-data` with a handful of registries, tags, recipes and worldgen files), a stale tree (tampered manifest) and a damaged tree (removed sentinel) (`docs/protocol/22-extraction-tool.md` §8.2)
- [ ] T053 [P] Create fixtures under `contract/fixtures/extract/`: hand-made reject archives for 22 §4.2 C1 to C5 and the T-series reject cases of 22 §12 (not a zip, wrong digest, missing entries)
- [ ] T054 [P] Create fixtures under `contract/fixtures/client/`: `options-default.txt`, `options-full.txt`, `options-corrupt.txt`, `options-out-of-range.txt` per `docs/protocol/13-client-gameplay-and-controls.md` §7.1 and a legacy `options.dat`
- [ ] T055 Create `tools/wire_fixtures.py`, the independent Python encoder used for wire fixtures not taken from a document worked example, with a self-test in `tools/tests/test_wire_fixtures.py` written first
- [ ] T056 [P] Create wire fixtures `contract/fixtures/wire/*.hex` for chunk data (24 sections, single-value, indirect and direct palettes, biome containers, 26 light entries; 06 worked examples) and registry data and Update Tags (04 worked examples)
- [ ] T057 [P] Create wire fixtures for Block Destruction, Player Action (start, abort, finish, swap with sequence ids) and Block Update (13 §2.3, §2.4)
- [ ] T058 [P] Create wire fixtures for Container Set Slot, Container Set Content, Container Click, Set Cursor Item, Open Screen with data components, Place Recipe, Recipe Book Add, Remove, Settings and Seen (00, 27, 40)
- [ ] T059 [P] Create wire fixtures for Commands (full node tree with every parser kind), Command Suggestions request and response, Chat Command, Player Chat and Disguised Chat with standard chat types (15, 15a)
- [ ] T060 [P] Create wire fixtures for Spawn Entity, Set Entity Data (every serializer of 46 §12), Entity Event, Update Attributes, Update Mob Effect, Level Event, Level Particles, Login and Respawn for three dimensions (18, 21, 42, 39, 46)
- [ ] T061 Gate: run `make gate-contract` and record the command and real output (all new copybooks compile, all fixtures parse)

### 2c. Table generator and drift gate (R2, R3; `tools/gen/gen_tables.py`)

- [ ] T062 Write acceptance test `tools/tests/acc_f2us2_gen_blocks.py`: generating the block table from `docs/protocol/24-block-registry-1-...` to `-8-...` yields the counts the documents state in their validation sections (24 §17; about 1,200 blocks, 30,000 states) and the worked examples of 24 §16, and the row layout is the 400-character literal rows of data-model §2
- [ ] T063 Implement the block and block-property tables in `tools/gen/gen_tables.py` (rows of data-model §2 "Block", "Block property"; output `content/copy/gen/blocks.cpy` and `blockprops.cpy`) so the previous test passes
- [ ] T064 Write acceptance test `tools/tests/acc_f2us2_gen_items.py` against `docs/protocol/25-item-registry-1-...` to `-8-...` and `25-item-registry-x1-continuation.md` (counts and worked examples; about 1,500 items)
- [ ] T065 Implement the item table (`content/copy/gen/items.cpy`) in `tools/gen/gen_tables.py`
- [ ] T066 Write acceptance test `tools/tests/acc_f2us2_gen_static_ids.py` against `docs/protocol/46-registry-ids.md` (counts of 46 §16, worked examples of 46 §15) for the static registry id table, the entity type table (21 §2, 46 §11) and the list of tag names the code reads (24 part 1 §12)
- [ ] T067 Implement the static registry id, entity type and tag name tables (`content/copy/gen/staticids.cpy`, `entities.cpy`, `tagnames.cpy`) in `tools/gen/gen_tables.py`
- [ ] T068 Write acceptance test `tools/tests/acc_f2us1_gen_jar_row.py`: the accepted-jar row (version id, size, SHA-256, world and protocol versions, pack formats) generated from `docs/protocol/README.md` equals the single recorded row (22 §4.1)
- [ ] T069 Implement the accepted-jar table (`content/copy/gen/acceptedjar.cpy`) in `tools/gen/gen_tables.py`
- [ ] T070 Write acceptance test `tools/tests/acc_f2us2_gen_drift.py`: `--check` fails when a document count changes by one row (loses a block) and when a generated file is edited by hand
- [ ] T071 Run `python3 tools/gen/gen_tables.py --write` and add the generated files under `content/copy/gen/` (data, not hand-edited); `make gate-tables` exits 0
- [ ] T072 Gate: run `make gate-tables && make gate-tools` and record the command and real output

### 2d. Move of the shared readers to `formats` (R1, behaviour-preserving)

- [ ] T073 Move `client/src/json.cob` and `client/tests/test_json.cob` to `formats/src/json.cob` and `formats/tests/test_json.cob`; register them in `formats/Makefile` (`SRC`, `TESTS`) and remove them from `client/Makefile`; no `CALL` changes
- [ ] T074 Move `client/src/zip.cob`, `client/tests/test_zip.cob` and `client/copy/CLZIP.cpy` (renamed `FMZIP.cpy`, in `contract/copy/`) to `formats/`; update the `COPY` statements in every client program
- [ ] T075 Move `client/src/png.cob` and `client/tests/test_png.cob` to `formats/`
- [ ] T076 Move `client/src/regex.cob`, `client/tests/test_regex.cob` and `client/copy/CLREGEX.cpy` (renamed `FMREGEX.cpy`, in `contract/copy/`) to `formats/`; update the `COPY` statements
- [ ] T077 Move `FILE-READ-ALL` from `client/src/packs/source.cob` into `formats/src/files.cob` with a `formats/tests/test_files.cob` covering it; `source.cob` calls it from the library
- [ ] T078 Re-link `client/Makefile` against `build/formats/libformats.a` (`DEPS_client` gains `formats`) and delete the stale client copies
- [ ] T079 Write contract test `formats/tests/contract_formats_provider.cob` for the programs that exist after the move (`JSON-*`, `ZIP-*`, `PNG-DECODE`, `REGEX-*`, `FILE-READ-ALL`) against `contract/fixtures/formats/`
- [ ] T080 Write consumer test `client/tests/contract_formats_consumer.cob` calling the moved programs the way the client does (`contracts/formats-api.md` "Contract tests")
- [ ] T081 Gate: run `make gate-formats` and record the command and real output
- [ ] T082 Gate: run `make gate-client` and record the command and real output (the move must leave the client's tests green; behaviour preserved)

### 2e. Foundational gate

- [ ] T083 Gate: run `make gate-contract && make gate-tools && make gate-formats && make gate-client` and record the command and real output; confirm each document deliverable of 2a has its review task done

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

- [ ] T084 [P] [US3-shim] Write test `shim/tests/test_cc_vk_texture_ex.c`: a texture uploaded with `cc_vk_texture_ex(..., mip_levels = 1)` reads back identical to its RGBA input and `cc_vk_texture` still behaves as before
- [ ] T085 [P] [US3-shim] Write test `shim/tests/test_cc_vk_texture_update.c`: after `cc_vk_texture_update` of a rectangle only that rectangle reads back changed
- [ ] T086 [US3-shim] Extend `shim/tests/contract_shim_provider.c` with the new texture entry points' return values and argument shapes
- [ ] T087 [US3-shim] Implement `cc_vk_texture_ex` in `shim/src/cc_vk.c` (`cc_vk_texture` calls it with 1 level)
- [ ] T088 [US3-shim] Implement `cc_vk_texture_update` in `shim/src/cc_vk.c` (staging buffer and copy command)
- [ ] T089 [US3-shim] Gate: run `make gate-shim` and record the command and real output

#### Phase 4: US4-shim — path opener

**Goal**: the client can start the system file browser on a folder (Q-2). **Independent Test**: `shim/tests/test_cc_open.c`.

- [ ] T090 [US4-shim] Write test `shim/tests/test_cc_open.c`: `cc_open_path("/usr/bin/true", dir)` returns 0 at once; a missing opener path returns `CC-NOTFOUND`; the call does not wait for the child
- [ ] T091 [US4-shim] Implement `cc_open_path` with `posix_spawn` in `shim/src/cc_open.c` and register it in `shim/Makefile`
- [ ] T092 [US4-shim] Extend `shim/tests/contract_shim_provider.c` with the `cc_open_path` shape
- [ ] T093 [US4-shim] Gate: run `make gate-shim` and record the command and real output

#### Phase 5: US5-shim — mip chain and sampler

**Goal**: textures do not shimmer or bleed at any distance (FR-011). **Independent Test**: readback of mip level 1 and the sampler state.

- [ ] T094 [P] [US5-shim] Write test `shim/tests/test_cc_vk_mips.c`: with `mip_levels` 4 a known 8x8 pattern reads back a box-filtered level 1 and level 2 (`docs/protocol/12-client-rendering.md` §2.4)
- [ ] T095 [P] [US5-shim] Write test `shim/tests/test_cc_vk_mip_update.c`: `cc_vk_texture_update` on a multi-level texture regenerates the touched mip levels
- [ ] T096 [US5-shim] Implement the box-filter mip chain generation in `shim/src/cc_vk.c`
- [ ] T097 [US5-shim] Implement the sampler of 12 §2.4 (filter and mipmap mode, replacing the `NEAREST` filters at `cc_vk.c:413-415`) and mip regeneration in `cc_vk_texture_update`
- [ ] T098 [US5-shim] Gate: run `make gate-shim` and record the command and real output

#### Phase 6: US11-shim — IEEE double arithmetic by reference

**Goal**: bit-exact terrain arithmetic at affordable speed (R5, Risk R-P). **Independent Test**: `test_cc_f64.c` against independently computed IEEE vectors.

- [ ] T099 [US11-shim] Create `shim/tests/gen_f64_vectors.py` (stdlib `struct`) writing `shim/tests/f64_vectors.txt` with operand/result pairs for every `cc_f64_*` function, computed independently of the C code
- [ ] T100 [US11-shim] Write test `shim/tests/test_cc_f64_arith.c` for add, sub, mul, div, floor, sqrt over the vectors (`0.1 + 0.2` gives `343333333333D33F`)
- [ ] T101 [US11-shim] Write test `shim/tests/test_cc_f64_text.c` for `cc_f64_from_text` (nearest double of a decimal text, `strtod`)
- [ ] T102 [US11-shim] Write test `shim/tests/test_cc_f64_libm.c` for each libm wrapper Round LIBM named
- [ ] T103 [US11-shim] Implement add, sub, mul, div, floor, sqrt (`fma`-based add and mul) in `shim/src/cc_f64.c`
- [ ] T104 [US11-shim] Implement `cc_f64_from_text` in `shim/src/cc_f64.c`
- [ ] T105 [US11-shim] Implement the libm wrappers in `shim/src/cc_f64.c` and register the file in `shim/Makefile`
- [ ] T106 [US11-shim] Extend `shim/tests/contract_shim_provider.c` with the `cc_f64_*` entry points
- [ ] T107 [US11-shim] Gate: run `make gate-shim` and record the command and real output

#### Phase 7: US20-shim — depth clear for the hand pass

**Goal**: the first-person hand draws over the world (12 §6). **Independent Test**: `test_cc_vk_clear_depth.c`.

- [ ] T108 [US20-shim] Write test `shim/tests/test_cc_vk_clear_depth.c`: a near and a far quad drawn, depth cleared, a second quad behind the first draws over it (readback)
- [ ] T109 [US20-shim] Implement `cc_vk_clear_depth` in `shim/src/cc_vk.c`
- [ ] T110 [US20-shim] Gate: run `make gate-shim` and record the command and real output

### Lane: formats

#### Phase 8: US1-formats — strict JSON, ZIP index and CRC, hashes, files

**Goal**: the readers the extraction tool and the loaders need (22 §7, 23 §3.2). **Independent Test**: `formats/tests/contract_formats_provider.cob` returns the documented values for the vectors of 22 §12 T2, T3, T15.

- [ ] T111 [US1-formats] Write contract test cases in `formats/tests/contract_formats_provider.cob` for `CRC32` (`123456789` gives `cbf43926`, 22 §7.2), `SHA256-*` (`abc` gives `ba7816bf...15ad`) and the 22 §12 T2, T3, T15 vectors
- [ ] T112 [P] [US1-formats] Write test `formats/tests/test_crc32.cob` (running value across buffers, empty buffer)
- [ ] T113 [US1-formats] Implement `CRC32` in `formats/src/crc32.cob`
- [ ] T114 [P] [US1-formats] Write test `formats/tests/test_sha256.cob` (init/update/final in pieces, 32-byte output, `abc`, the empty string)
- [ ] T115 [US1-formats] Implement `SHA256-INIT`, `SHA256-UPDATE`, `SHA256-FINAL` in `formats/src/sha256.cob` with direct OpenSSL `EVP_MD_CTX_*` calls (`FMSHA` context; link `-lcrypto` in `formats/Makefile`)
- [ ] T116 [P] [US1-formats] Write test `formats/tests/test_json_strict.cob`: accept valid documents, reject comments, trailing commas and duplicate keys, return the error offset and reason code (23 §3.2)
- [ ] T117 [US1-formats] Implement `JSON-STRICT` in `formats/src/json-strict.cob`
- [ ] T118 [P] [US1-formats] Write test `formats/tests/test_zip_index.cob`: name lookup through a hash index over a 10,000-entry central directory without scanning (22 §8.4 last paragraph)
- [ ] T119 [US1-formats] Add the name hash index to `ZIP-FIND` in `formats/src/zip.cob`
- [ ] T120 [P] [US1-formats] Write test `formats/tests/test_zip_crc_range.cob`: `ZIP-CRC-CHECK` accepts a good entry and rejects the bad-CRC fixture; `ZIP-READ-RANGE` inflates one entry into a caller buffer; zip64, several disks and encryption are rejected with a reason (22 §8.4)
- [ ] T121 [US1-formats] Implement `ZIP-CRC-CHECK` and `ZIP-READ-RANGE` and the rejections in `formats/src/zip.cob`
- [ ] T122 [P] [US1-formats] Write test `formats/tests/test_files_io.cob` for `FILE-READ-AT`, `FILE-WRITE`, `FILE-EXISTS` with status words (a missing file, an unwritable folder)
- [ ] T123 [US1-formats] Implement `FILE-READ-AT`, `FILE-WRITE`, `FILE-EXISTS` in `formats/src/files.cob` over `CBL_OPEN_FILE`, `CBL_READ_FILE`, `CBL_WRITE_FILE`, `CBL_CHECK_FILE_EXIST`
- [ ] T124 [P] [US1-formats] Write test `formats/tests/test_dirs.cob` for `DIR-ENSURE` (nested), `DIR-RENAME` (atomic swap of a directory), `DIR-REMOVE-TREE` (tree walk through `cc_fs_list`)
- [ ] T125 [US1-formats] Implement `DIR-ENSURE`, `DIR-RENAME`, `DIR-REMOVE-TREE` in `formats/src/dirs.cob`
- [ ] T126 [P] [US1-formats] Write test `formats/tests/test_png_kinds.cob`: `PNG-DECODE` decodes every kind Round PNG lists, using the `contract/fixtures/formats/` PNGs
- [ ] T127 [US1-formats] Extend `PNG-DECODE` in `formats/src/png.cob` for the kinds Round PNG lists
- [ ] T128 [US1-formats] Write implementation tests in `formats/tests/test_formats_cover.cob` for any line of `formats/src` the tests above leave unexecuted (`make coverage` lists them)
- [ ] T129 [US1-formats] Gate: run `make gate-formats` and record the command and real output

#### Phase 9: US3-formats — user pack archives

**Goal**: user resource packs (zip methods 0 and 8, thousands of entries) read correctly (FR-007). **Independent Test**: `acc_f2us3_user_zip` against the real Faithful zip.

- [ ] T130 [US3-formats] Write acceptance test `formats/tests/acc_f2us3_user_zip.cob`: given `tmp/Faithful 32x - 26.3.zip` (real input, fails loudly when absent) and the stored and deflated fixtures, every entry lists, resolves by name and reads with a matching CRC, and a name lookup does not scan
- [ ] T131 [US3-formats] Make `acc_f2us3_user_zip` pass in `formats/src/zip.cob`; if the test already passes when written, record that evidence and mark this task done
- [ ] T132 [US3-formats] Gate: run `make gate-formats` and record the command and real output

### Lane: proto

#### Phase 10: US8-proto — block destruction and player action

**Goal**: encode and decode the break stage and the dig actions with sequence ids (13 §2.3, §2.4).

- [ ] T133 [US8-proto] Extend `proto/tests/contract_wire_provider.cob` with the Block Destruction and Player Action fixtures (decode to fields, re-encode to the same bytes)
- [ ] T134 [US8-proto] Write test cases in `proto/tests/test_composites.cob` for `PB-PUT-BLOCK-DESTRUCTION` and `PB-GET-PLAYER-ACTION` (status, position, face, sequence)
- [ ] T135 [US8-proto] Implement the Block Destruction encoder and Player Action decoder in `proto/src/composites.cob`
- [ ] T136 [US8-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 11: US9-proto — item stack with components, containers, recipe book

**Goal**: the inventory, crafting and recipe-book packets (00, 27, 40).

- [ ] T137 [US9-proto] Extend `proto/tests/contract_wire_provider.cob` with the container and recipe-book fixtures
- [ ] T138 [US9-proto] Write tests in `proto/tests/test_item_stack.cob` for the item stack with a non-empty data component patch (add and remove lists, 00), replacing the empty patch at `proto/src/composites.cob:123`
- [ ] T139 [US9-proto] Implement `PB-PUT-ITEM-STACK` and `PB-GET-ITEM-STACK` with components in `proto/src/item-stack.cob`
- [ ] T140 [US9-proto] Write tests in `proto/tests/test_containers.cob` for Container Set Slot, Content, Click (changed slots, cursor), Set Cursor Item, Open Screen, Container Close
- [ ] T141 [US9-proto] Implement the container packet encoders and decoders in `proto/src/containers.cob`
- [ ] T142 [US9-proto] Write tests in `proto/tests/test_recipe_book.cob` for Place Recipe and Recipe Book Add, Remove, Settings, Seen (27)
- [ ] T143 [US9-proto] Implement the recipe-book encoders and decoders in `proto/src/recipe-book.cob`
- [ ] T144 [US9-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 12: US11-proto — 24-section chunks, registries and tags

**Goal**: the chunk codec for 16-bit states and 24 sections, and the configuration packets of the standard world (04, 06).

- [ ] T145 [US11-proto] Extend `proto/tests/contract_wire_provider.cob` with the chunk, Registry Data and Update Tags fixtures
- [ ] T146 [US11-proto] Write tests in `proto/tests/test_chunk_palette.cob` for paletted containers: single value, indirect, direct, with bits per entry from the 06 rules, for blocks (4096 cells) and biomes (64 cells)
- [ ] T147 [US11-proto] Implement the paletted container encoder and decoder in `proto/src/chunk-palette.cob` (additive: the 001 chunk functions in `proto/src/chunk.cob` stay until Polish)
- [ ] T148 [US11-proto] Write tests in `proto/tests/test_chunk24.cob` for a 24-section chunk packet with 26 light indices, heightmaps and block entities (06 worked examples)
- [ ] T149 [US11-proto] Implement `PB-PUT-CHUNK-24` and `PB-GET-CHUNK-24` in `proto/src/chunk24.cob`
- [ ] T150 [US11-proto] Write tests in `proto/tests/test_registry_tags.cob` for Registry Data entries (with and without inline data) and Update Tags (04 worked examples)
- [ ] T151 [US11-proto] Implement the Registry Data and Update Tags encoders and decoders in `proto/src/registry-tags.cob`
- [ ] T152 [US11-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 13: US12-proto — level events, particles, three-dimension login

- [ ] T153 [US12-proto] Extend `proto/tests/contract_wire_provider.cob` with the Level Event, Level Particles, Login and Respawn (three dimensions), Block Event and Block Entity Data fixtures
- [ ] T154 [US12-proto] Write tests in `proto/tests/test_level_events.cob` for those packets (42, 39, 31)
- [ ] T155 [US12-proto] Implement their encoders and decoders in `proto/src/level-events.cob`
- [ ] T156 [US12-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 14: US13-proto — command nodes and suggestions

- [ ] T157 [US13-proto] Extend `proto/tests/contract_wire_provider.cob` with the Commands, Command Suggestions, Chat Command, Player Chat and Disguised Chat fixtures
- [ ] T158 [US13-proto] Write tests in `proto/tests/test_command_nodes.cob` for every parser kind with its properties and the redirect and suggestion-type fields (15, 15a)
- [ ] T159 [US13-proto] Implement the full command node tree encoder and decoder in `proto/src/command-nodes.cob`
- [ ] T160 [US13-proto] Write tests in `proto/tests/test_chat_commands.cob` for Command Suggestions request and response, Chat Command, Player Chat and Disguised Chat with the standard chat types
- [ ] T161 [US13-proto] Implement those packets in `proto/src/chat-commands.cob`
- [ ] T162 [US13-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 15: US14-proto — attributes and effects

- [ ] T163 [US14-proto] Extend `proto/tests/contract_wire_provider.cob` with the Update Attributes and Update Mob Effect fixtures
- [ ] T164 [US14-proto] Write tests in `proto/tests/test_attributes.cob` for attribute modifiers and mob effects (17, 28)
- [ ] T165 [US14-proto] Implement the Update Attributes and Update Mob Effect codecs in `proto/src/attributes.cob`
- [ ] T166 [US14-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 16: US15-proto — entity spawn and metadata

- [ ] T167 [US15-proto] Extend `proto/tests/contract_wire_provider.cob` with the Spawn Entity, Set Entity Data and Entity Event fixtures
- [ ] T168 [US15-proto] Write tests in `proto/tests/test_entity_metadata.cob` for every serializer of `docs/protocol/46-registry-ids.md` §12
- [ ] T169 [US15-proto] Implement the entity metadata entry codecs in `proto/src/entity-metadata.cob`
- [ ] T170 [US15-proto] Write tests in `proto/tests/test_entity_packets.cob` for Spawn Entity and Entity Event (18, 21)
- [ ] T171 [US15-proto] Implement the Spawn Entity and Entity Event codecs in `proto/src/entity-packets.cob`
- [ ] T172 [US15-proto] Gate: run `make gate-proto` and record the command and real output

#### Phase 17: US19-proto — swap action

- [ ] T173 [US19-proto] Extend `proto/tests/contract_wire_provider.cob` with the swap-with-off-hand Player Action fixture
- [ ] T174 [US19-proto] Write a test case in `proto/tests/test_composites.cob` for the swap action status and its decoding (13 §4)
- [ ] T175 [US19-proto] Extend the Player Action decoder in `proto/src/composites.cob` with the swap status
- [ ] T176 [US19-proto] Gate: run `make gate-proto` and record the command and real output

### Lane: content

#### Phase 18: US1-content — packs check and accepted jar

**Goal**: the game can tell whether valid generated packs exist and why not (22 §8.2, FR-003, FR-004). **Independent Test**: `CONTENT-PACKS-CHECK` over the fixture trees returns `ok`, `stale`, `damaged`, `absent`, `incomplete`.

- [ ] T177 [US1-content] Write test `content/tests/test_accepted_jar.cob`: the accepted-jar accessor returns the one row of the generated table `content/copy/gen/acceptedjar.cpy` (size, SHA-256, versions, pack formats)
- [ ] T178 [US1-content] Implement the accepted-jar accessor program `CONTENT-ACCEPTED-JAR` in `content/src/accepted-jar.cob`
- [ ] T179 [US1-content] Write acceptance test `content/tests/acc_f2us1_packs_check.cob`: over `contract/fixtures/content/` a valid tree gives `ok`, a missing directory `absent`, a missing sentinel `damaged`, a tampered manifest `stale`, a manifest listing missing parts `incomplete` (22 §8.2); the check reads no jar and hashes nothing
- [ ] T180 [US1-content] Implement `CONTENT-PACKS-CHECK` (status word and reason text) in `content/src/packs-check.cob`
- [ ] T181 [US1-content] Write consumer test `content/tests/contract_formats_consumer.cob` calling `JSON-STRICT`, `ZIP-*` and `FILE-*` the way `content` does
- [ ] T182 [US1-content] Write implementation tests `content/tests/test_packs_check_paths.cob` for the check's remaining branches (unreadable manifest, short manifest line)
- [ ] T183 [US1-content] Gate: run `make gate-content` and record the command and real output

#### Phase 19: US2-content — content sets, registries, tags, built-in layer

**Goal**: both world types answer the same lookups with the same record shapes (R6). **Independent Test**: `contract_content_provider.cob` returns the worked examples of 24 §16, 46 §15, 23 §3.4 and §6.7.

- [ ] T184 [US2-content] Write contract test `content/tests/contract_content_provider.cob`: block, item, entity and static-id lookups of the standard set return the worked examples (24 §16, 25, 46 §15); unknown keys and ids return row 0 / "not found" (content-api §3)
- [ ] T185 [US2-content] Write test `content/tests/test_content_blocks.cob` for `CONTENT-BLOCK-BY-KEY`, `CONTENT-BLOCK-OF-STATE`, `CONTENT-STATE-PROPS`, `CONTENT-STATE-DEFAULT` (state id rule of 24 part 1 §3, no stored state rows)
- [ ] T186 [US2-content] Implement the block and state lookups in `content/src/blocks.cob` over the generated block tables
- [ ] T187 [US2-content] Write test `content/tests/test_content_items.cob` for `CONTENT-ITEM-BY-KEY`, `CONTENT-ITEM-BY-ID`, `CONTENT-ITEM-COMPONENT`
- [ ] T188 [US2-content] Implement the item lookups in `content/src/items.cob`
- [ ] T189 [US2-content] Write test `content/tests/test_content_entities.cob` for `CONTENT-ENTITY-BY-KEY` and `CONTENT-STATIC-ID`
- [ ] T190 [US2-content] Implement them in `content/src/entities.cob`
- [ ] T191 [US2-content] Write test `content/tests/test_registry_load.cob` for the 23 §3 loading sequence over a fixture `vanilla-data` tree: strict JSON, ids in order, freeze, validate, mandatory keys (04 §3.2); `CONTENT-REGISTRY-ENTRY` and `CONTENT-REGISTRY-COUNT`
- [ ] T192 [US2-content] Implement the registry loader in `content/src/registry.cob`
- [ ] T193 [US2-content] Write test `content/tests/test_tags.cob` for tag resolution (23 §6, worked examples §6.7), `CONTENT-TAG-HAS`, `CONTENT-TAG-MEMBERS`
- [ ] T194 [US2-content] Implement tag loading and resolution in `content/src/tags.cob`
- [ ] T195 [US2-content] Write acceptance test `content/tests/acc_f2us2_content_open.cob`: `CONTENT-OPEN` of the standard type is refused unless the packs check is `ok`; the cobolcraft type opens with an empty generated directory and never reads the generated data pack; the two sets share no rows (WT-25)
- [ ] T196 [US2-content] Implement `CONTENT-OPEN` and `CONTENT-CLOSE` (`CT-SET`) in `content/src/content-open.cob`
- [ ] T197 [US2-content] Write test `content/tests/test_builtin_blocks.cob`: the cobolcraft layer answers the same block lookups with the 12 blocks and 18 states of `docs/design/standin-content.md` and `cobolcraft-standard-core.md` (state ids 0 to 17)
- [ ] T198 [US2-content] Implement the built-in block layer in `content/src/builtin-blocks.cob`
- [ ] T199 [US2-content] Write test `content/tests/test_builtin_items.cob`: the 18 items, with their components and tags, as the same record shapes the standard set returns
- [ ] T200 [US2-content] Implement the built-in item layer in `content/src/builtin-items.cob`
- [ ] T201 [US2-content] Write test `content/tests/test_builtin_entities.cob`: the cobolcraft mobs expressed as entity rows, components and tags
- [ ] T202 [US2-content] Implement the built-in entity layer in `content/src/builtin-entities.cob`
- [ ] T203 [US2-content] Write test `content/tests/test_client_registry.cob` for `CONTENT-CLIENT-REGISTRY-ADD` and `CONTENT-CLIENT-FINISH`, including the WT-16 decision of the world type from `minecraft:dimension_type` at Finish Configuration (`docs/design/world-types.md`)
- [ ] T204 [US2-content] Implement the client registry load in `content/src/client-registry.cob`
- [ ] T205 [US2-content] Write implementation tests in `content/tests/test_content_cover.cob` for lines of `content/src` left unexecuted
- [ ] T206 [US2-content] Gate: run `make gate-content` and record the command and real output

#### Phase 20: US9-content — recipes

- [ ] T207 [US9-content] Write test `content/tests/test_recipes_load.cob`: recipes of every type in `docs/protocol/27-recipes-and-unlocks.md` load through the loaders from a fixture data tree (shaped, shapeless, smelting family, stonecutting, smithing, special) with their unlock conditions
- [ ] T208 [US9-content] Implement the recipe loader in `content/src/recipes.cob`
- [ ] T209 [US9-content] Write test `content/tests/test_builtin_recipes.cob`: the cobolcraft recipes (`cobolcraft-standard-core.md`) are rows of the same recipe shapes
- [ ] T210 [US9-content] Implement the built-in recipes in `content/src/builtin-recipes.cob`
- [ ] T211 [US9-content] Gate: run `make gate-content` and record the command and real output

#### Phase 21: US10-content — crafting bench content

- [ ] T212 [US10-content] Write test `content/tests/test_builtin_bench.cob`: `cobolcraft:crafting_bench` exists as block and item in the cobolcraft set, with its recipe and tags, and does not exist in the standard set (`cobolcraft-standard-core.md` §5, FR-027, FR-005)
- [ ] T213 [US10-content] Add the bench block, item and recipe, and any further content the FR-027 design records name, to the built-in layer files in `content/src/`
- [ ] T214 [US10-content] Gate: run `make gate-content` and record the command and real output

#### Phase 22: US11-content — worldgen registries

- [ ] T215 [US11-content] Write test `content/tests/test_worldgen_noise.cob`: noise parameters and density function loaders over a fixture tree, with the shapes of `docs/protocol/10-world-generation-terrain.md` (the by-reference doubles of `cc_f64_from_text`)
- [ ] T216 [US11-content] Implement the noise and density function loaders in `content/src/worldgen-density.cob`
- [ ] T217 [US11-content] Write test `content/tests/test_worldgen_biomes.cob`: biome and multi-noise biome source loaders (10, 37 part 3, 43 tint inputs)
- [ ] T218 [US11-content] Implement the biome loaders in `content/src/worldgen-biomes.cob`
- [ ] T219 [US11-content] Write test `content/tests/test_worldgen_settings.cob`: noise settings, surface rules, carver configurations and ore feature parameters (10, 11, 37 parts 2 and 4)
- [ ] T220 [US11-content] Implement the noise settings, surface rule and carver loaders in `content/src/worldgen-settings.cob`
- [ ] T221 [US11-content] Write test `content/tests/test_dimension_types.cob`: `dimension_type` rows (min_y -64, height 384, sea level 63 for the overworld; 04 §6, 23 §7.3.3) and the three dimension definitions
- [ ] T222 [US11-content] Implement the dimension loaders in `content/src/dimensions.cob`
- [ ] T223 [US11-content] Gate: run `make gate-content` and record the command and real output

#### Phase 23: US12-content — features, structures, templates, processors

- [ ] T224 [US12-content] Write test `content/tests/test_features_load.cob`: configured and placed feature loaders over a fixture tree, including the predicate and provider forms of `docs/protocol/35-worldgen-features-2-predicates-and-providers.md`
- [ ] T225 [US12-content] Implement the feature loaders in `content/src/features.cob`
- [ ] T226 [US12-content] Write test `content/tests/test_structures_load.cob`: structure, structure set, template pool and jigsaw loaders (36 parts 1 to 3)
- [ ] T227 [US12-content] Implement the structure loaders in `content/src/structures.cob`
- [ ] T228 [US12-content] Write test `content/tests/test_templates_load.cob`: structure template NBT files and processor lists (36 part 2)
- [ ] T229 [US12-content] Implement the template and processor loaders in `content/src/templates.cob`
- [ ] T230 [US12-content] Gate: run `make gate-content` and record the command and real output

#### Phase 24: US13-content — registries the commands name

- [ ] T231 [US13-content] Write test `content/tests/test_command_sources.cob`: every registry the argument types of `docs/protocol/16-commands-catalog.md` complete against (items, blocks, entity types, enchantments, effects, biomes, structures, particle types, game rules, ...) enumerates through `CONTENT-REGISTRY-ENTRY` in id order for both sets
- [ ] T232 [US13-content] Fill the missing registry sources in `content/src/registry.cob` so the test passes
- [ ] T233 [US13-content] Gate: run `make gate-content` and record the command and real output

#### Phase 25: US14-content — item components

- [ ] T234 [US14-content] Write test `content/tests/test_item_components.cob`: `CONTENT-ITEM-COMPONENT` returns tool rules, weapon damage, armor, durability, enchantable and attribute components for the tools and armors of `docs/protocol/17-tools-weapons-and-combat.md` §1 (standard set) and for the cobolcraft items
- [ ] T235 [US14-content] Implement the component defaults in `content/src/item-components.cob`
- [ ] T236 [US14-content] Write test `content/tests/test_enchantment_load.cob`: enchantment, damage type and equipment registries load (28)
- [ ] T237 [US14-content] Implement the enchantment and damage type loaders in `content/src/enchantments.cob`
- [ ] T238 [US14-content] Gate: run `make gate-content` and record the command and real output

#### Phase 26: US15-content — entity types, loot, spawn data

- [ ] T239 [US15-content] Write test `content/tests/test_loot_load.cob`: loot tables, conditions and functions load from a fixture tree (26)
- [ ] T240 [US15-content] Implement the loot loaders in `content/src/loot.cob`
- [ ] T241 [US15-content] Write test `content/tests/test_spawn_data.cob`: biome spawner lists and spawn costs (44 part 2), mob variants and `CT-ENTITY-ROW` size and category (21 §2)
- [ ] T242 [US15-content] Implement the spawn data loaders in `content/src/spawn-data.cob`
- [ ] T243 [US15-content] Gate: run `make gate-content` and record the command and real output

### Lane: extract

#### Phase 27: US1-extract — the extraction tool (`docs/protocol/22-extraction-tool.md`)

**Goal**: `cobolcraft-extract` writes the vanilla resource pack and data pack from the user's jar (FR-001). **Independent Test**: the 22 §12 T-series against `tmp/minecraft-26.3-client.jar`; `CONTENT-PACKS-CHECK` returns `ok` on the output.

- [ ] T244 [US1-extract] Write test `extract/tests/test_ex_args.cob` for `EX-ARGS`: `--jar --game-dir --generated-dir --force --verify --dry-run --quiet`, defaults (`<game dir>/generated`), unknown option gives CCX-001 and exit 1 (22 §7.1)
- [ ] T245 [US1-extract] Implement `EX-ARGS` in `extract/src/args.cob`
- [ ] T246 [US1-extract] Write test `extract/tests/test_ex_jar_find.cob` for `EX-JAR-FIND`: the search order of 22 §4.3 over a scratch game directory
- [ ] T247 [US1-extract] Implement `EX-JAR-FIND` in `extract/src/jar-find.cob`
- [ ] T248 [US1-extract] Write test `extract/tests/test_ex_check.cob` for `EX-CHECK` C1 to C5 (22 §4.2) over `contract/fixtures/extract/` reject archives: not a zip, wrong SHA-256, missing entries, each with its CCX code
- [ ] T249 [US1-extract] Implement `EX-CHECK` in `extract/src/check.cob` (SHA-256 with `SHA256-*`, accepted row from `CONTENT-ACCEPTED-JAR`)
- [ ] T250 [US1-extract] Write test `extract/tests/test_ex_plan.cob` for `EX-PLAN` (22 §6.3): the payload entry list, the counts, the destination paths
- [ ] T251 [US1-extract] Implement `EX-PLAN` in `extract/src/plan.cob`
- [ ] T252 [US1-extract] Write test `extract/tests/test_ex_walk.cob` for `EX-WALK` (22 §7.3 step 7): each planned entry reads with `ZIP-READ-RANGE`, passes its CRC check and is written under `<generated>.partial`
- [ ] T253 [US1-extract] Implement `EX-WALK` in `extract/src/walk.cob`
- [ ] T254 [US1-extract] Write test `extract/tests/test_ex_manifest.cob` for `EX-WRITE-MANIFEST` (22 §6.4) and `EX-WRITE-INDEX` (22 §6.5): byte format, sentinel `.cobolcraft-generated`
- [ ] T255 [US1-extract] Implement `EX-WRITE-MANIFEST` and `EX-WRITE-INDEX` in `extract/src/manifest.cob`
- [ ] T256 [US1-extract] Write test `extract/tests/test_ex_verify.cob` for `EX-VERIFY` (22 §7.6): full integrity check passes on a good tree and names the damaged file
- [ ] T257 [US1-extract] Implement `EX-VERIFY` in `extract/src/verify.cob`
- [ ] T258 [US1-extract] Write test `extract/tests/test_ex_main.cob` for `EX-MAIN`: idempotence (CCX-100, nothing rebuilt), `--force`, `--dry-run` writes nothing, the atomic swap `<generated>.partial` to `<generated>` (22 §7.5), exit statuses of 22 §7.4
- [ ] T259 [US1-extract] Implement `EX-MAIN` in `extract/src/ex-main.cob` and the one-`CALL` `extract/src/main.cob`
- [ ] T260 [US1-extract] Write acceptance test `extract/tests/acc_f2us1_real_jar.cob` (real input, fails loudly without the jar): scenarios US1-1 (the vanilla resource pack and data pack exist in the layout of 22 §5.2 with the T5 counts: 11,605 resource files, 9,779 data files, 106 feature files), US1-2 second run does nothing, an unrecognised jar is rejected (CCX-030 or CCX-031, nothing written)
- [ ] T261 [US1-extract] Write acceptance test `extract/tests/acc_f2us1_git_clean.cob`: after a real run `git ls-files` lists no jar and no generated file (SC-012)
- [ ] T262 [US1-extract] Write contract test `extract/tests/contract_extract_provider.cob`: output tree and manifest against 22 §5.2, §6.4, §6.5 with the real jar
- [ ] T263 [US1-extract] Write consumer-side test `extract/tests/contract_extract_content_consumer.cob` (the contract names it `contract_content_consumer_extract` in the content package; it lives in this lane so lanes stay disjoint): the tool's real output passes `CONTENT-PACKS-CHECK`; a tampered manifest gives `stale`, a removed sentinel `damaged`
- [ ] T264 [US1-extract] Write consumer test `extract/tests/contract_formats_consumer.cob` calling `ZIP-*`, `CRC32`, `SHA256-*`, `FILE-*`, `DIR-*` the way the tool does
- [ ] T265 [US1-extract] Write implementation tests in `extract/tests/test_extract_cover.cob` for lines of `extract/src` left unexecuted
- [ ] T266 [US1-extract] Gate: run `make gate-extract` and record the command and real output

### Lane: core

#### Phase 28: US1-core — packs status

- [ ] T267 [US1-core] Write test `core/tests/test_packs_status.cob` for `CORE-PACKS-STATUS`: it delegates to `CONTENT-PACKS-CHECK` and returns the status word and the English console reason of `docs/protocol/22-extraction-tool.md` §9.2 for each of the five statuses over `contract/fixtures/content/`
- [ ] T268 [US1-core] Implement `CORE-PACKS-STATUS` in `core/src/packs-status.cob`
- [ ] T269 [US1-core] Write consumer test `core/tests/contract_content_consumer.cob`: open a set through a fixture generated directory and assert the status words and one block lookup (`contracts/content-api.md` §4)
- [ ] T270 [US1-core] Gate: run `make gate-core` and record the command and real output

#### Phase 29: US2-core — content re-base, world types, shared rules

**Goal**: one set of rule engines fed by either content set; the type stored in the world (FR-002 to FR-005, FR-037, FR-040, FR-041). **Independent Test**: `acc_f2us2_*` in core: type recorded and refused correctly; health 20, food 20, day 24,000, hurt window and fall damage from the shared rules.

- [ ] T271 [US2-core] Write test `core/tests/test_cells.cob` for the `CELLS.cpy` layout: 2-byte state get and set, 4-bit light packing, sections derived from the dimension's `min_y` and `height` (24 in the overworld), three dimensions (`core/copy/CORESTATE.cpy` `CORE-MAX-DIMS` 3)
- [ ] T272 [US2-core] Replace `core/copy/CHUNKMEM.cpy` by `contract/copy/CELLS.cpy` in `core/src/world.cob` and `core/copy/CORESTATE.cpy` (cell width, section count, `CORE-MAX-DIMS` 3)
- [ ] T273 [US2-core] Write test `core/tests/test_chunks_stream24.cob`: the chunk packet the core builds for a case equals the 24-section fixture and loads through `PB-GET-CHUNK-24`
- [ ] T274 [US2-core] Switch `core/src/chunks-stream.cob` to `PB-PUT-CHUNK-24`
- [ ] T275 [US2-core] Write test `core/tests/test_block_lookup.cob`: world, blocks and worldgen code resolves block states only through `CONTENT-BLOCK-*` for both sets (no `ST-` or `BLK-` constants)
- [ ] T276 [US2-core] Replace the `ST-` references in `core/src/blocks.cob`, `core/src/world.cob`, `core/src/worldgen.cob`, `core/src/chunks-stream.cob` by `CONTENT-*` lookups and delete `core/copy/BLOCKS.cpy`
- [ ] T277 [US2-core] Replace the `ST-`/item/recipe/mob constants in `core/src/registries.cob`, `core/src/login.cob`, `core/src/config-phase.cob` by registries from `CONTENT-REGISTRY-*` and delete `core/copy/REGISTRY.cpy`, `ITEMS.cpy`, `RECIPES.cpy`, `MOBS.cpy`, `ENTITYTYPES.cpy` (the cobolcraft values now live in the content package's built-in layer)
- [ ] T278 [US2-core] Replace the `ST-` references in `core/src/movement.cob`, `core/src/health.cob`, `core/src/hunger.cob`, `core/src/mobs.cob`, `core/src/players.cob`, `core/src/session.cob` by `CONTENT-*` lookups
- [ ] T279 [US2-core] Replace the `ST-` references in `core/src/access.cob`, `core/src/api.cob`, `core/src/commands.cob` by `CONTENT-*` lookups
- [ ] T280 [US2-core] Write test `core/tests/test_persistence_split.cob` for the folder layout of `docs/protocol/07-nbt-and-anvil.md` §9: `level.dat` with `WorldType`, `Seed`, `ContentJar`; up to three dimension folders; block states by key in palettes (WT-23: a foreign key is a defined outcome)
- [ ] T281 [US2-core] Split `core/src/persistence.cob` (1,984 lines) into `core/src/level-data.cob` (level.dat), `core/src/player-data.cob`, `core/src/entity-data.cob` and `core/src/chunk-data.cob`, writing and reading blocks by key and covering all three dimensions
- [ ] T282 [US2-core] Write contract tests (extended) `core/tests/contract_world_folder_provider.cob` and `core/tests/contract_coreapi_provider.cob` for the new keys, the three dimensions, the new settings and the re-derived `CORE-SETTINGS-SIZE`
- [ ] T283 [US2-core] Write acceptance test `core/tests/acc_f2us2_world_type.cob`: scenarios US2-1/US2-3 (new world records its type; reopening yields the same type; a standard world with packs not `ok` is refused with the status word, FR-004; an old 001 world with no `WorldType` and no `dimensions/minecraft/` folder opens as cobolcraft; a folder with `dimensions/` and no `level.dat`, or standard folders and no `WorldType`, is refused, `docs/design/world-types.md` §2.1 rules 2 and 3, WT-24)
- [ ] T284 [US2-core] Implement `CORE-WORLD-OPEN` type handling, the new statuses and `CS-WORLD-TYPE`, `CS-GENERATED-DIR`, `CS-GAME-DIR` in `core/src/api.cob` and `core/src/level-data.cob`
- [ ] T285 [US2-core] Write test `core/tests/test_seed_text.cob` for `CS-SEED-TEXT` to seed with the worked examples of Round SEED (empty text gives a random seed)
- [ ] T286 [US2-core] Implement the seed text rule in `core/src/seed-text.cob`
- [ ] T287 [US2-core] Write acceptance test `core/tests/acc_f2us2_shared_rules.cob` (US2-4): max health 20, food 20, the hit window and hurt cooldown, fall damage and exhaustion of `docs/protocol/13`/`17`/`18` apply in both types; day length 24,000 ticks (33)
- [ ] T288 [US2-core] Make `acc_f2us2_shared_rules` pass: delete the stand-in constants in `core/copy/RULES.cpy`, the `CW-TIME` range in `core/copy/CORESTATE.cpy` and the stand-in branches of `core/src/health.cob`, `core/src/hunger.cob`, `core/src/movement.cob`, `core/src/world.cob`
- [ ] T289 [US2-core] Write test `core/tests/test_time_rebase.cob`: an old world's `level.dat` time values re-base onto the standard timeline of 33 when it opens (data-model §6)
- [ ] T290 [US2-core] Implement the time re-base in `core/src/level-data.cob`
- [ ] T291 [US2-core] Write test `core/tests/test_ground_items_shared.cob`: ground items follow `docs/protocol/41-item-entity-physics.md` (pickup delay, merging, despawn, physics) in both types
- [ ] T292 [US2-core] Make the ground item engine follow 41 in `core/src/ground-items.cob`
- [ ] T293 [US2-core] Write test `core/tests/test_weather_shared.cob`: the weather mechanism of 33 for both types (`CS-WEATHER-CHANGES` maps to the gamerule)
- [ ] T294 [US2-core] Make the weather engine follow 33 in `core/src/weather.cob`
- [ ] T295 [US2-core] Write implementation tests in `core/tests/test_us2_cover.cob` for the lines of the files above that the tests leave unexecuted
- [ ] T296 [US2-core] Gate: run `make gate-core` and record the command and real output

#### Phase 30: US7-core — survival abilities

- [ ] T297 [US7-core] Write acceptance test `core/tests/acc_f2us7_abilities.cob` (US7-2): `PLAY-ABILITIES-BUILD` grants the flight flags only in creative and spectator and never in survival or adventure (`docs/protocol/13` §1.4); a client request to start flying in survival is ignored and the next Player Abilities states not flying. If the client lane's US7 reproduction finds a core cause of the survival climb (P-client-5) this phase escalates to multi-package: stop and return to the orchestrator
- [ ] T298 [US7-core] Gate: run `make gate-core` and record the command and real output

#### Phase 31: US8-core — break progress and stages

- [ ] T299 [US8-core] Write test `core/tests/test_break_progress.cob`: progress per tick from the formula of `docs/protocol/13` §2.1 (hardness, tool speed, tier, effects, on-ground, in-water) with the worked examples of §9
- [ ] T300 [US8-core] Implement the progress formula in `core/src/breaking.cob`
- [ ] T301 [US8-core] Write test `core/tests/test_break_sequence.cob`: Player Action start, abort and finish handling with sequence ids and acknowledgements (13 §2.3), a changed held item or target aborts
- [ ] T302 [US8-core] Implement the sequence handling in `core/src/breaking.cob`
- [ ] T303 [US8-core] Write acceptance test `core/tests/acc_f2us8_destroy_stage.cob` (US8-1 to US8-3): Block Destruction stage 0 to 9 goes to the breaker and to other players who can see the block; abort and finish send stage -1; a block broken by another player ends the progress (13 §2.4)
- [ ] T304 [US8-core] Implement the stage broadcast in `core/src/breaking.cob`
- [ ] T305 [US8-core] Write contract tests in `core/tests/contract_wire_server.cob` for the Block Destruction fixture
- [ ] T306 [US8-core] Gate: run `make gate-core` and record the command and real output

#### Phase 32: US9-core — inventory menu, crafting, recipe book

- [ ] T307 [US9-core] Write test `core/tests/test_inventory_menu.cob`: the 46-slot inventory menu (2x2 grid, result, armor, off-hand slot 45; `docs/protocol/40-menus-1-model-and-containers.md`, 12 §5.6a) with Container Click modes (pickup, quick move, swap, throw, drag, double click)
- [ ] T308 [US9-core] Implement the inventory menu in `core/src/menu-inventory.cob` and the shared menu model in `core/src/menus.cob`, replacing the stand-in logic of `core/src/inventory.cob`
- [ ] T309 [US9-core] Write test `core/tests/test_crafting_match.cob`: shaped (mirror, trimmed), shapeless and special matching and the result slot over a 2x2 and a 3x3 grid (13 §3.2, §3.3) with the recipes from `CONTENT` for both sets
- [ ] T310 [US9-core] Implement crafting matching in `core/src/crafting-match.cob`
- [ ] T311 [US9-core] Write acceptance test `core/tests/acc_f2us9_take_result.cob` (US9-1): taking the result consumes one of each ingredient, shift-click crafts repeatedly, leftover items (13 §3.6)
- [ ] T312 [US9-core] Implement result taking in `core/src/crafting-match.cob`
- [ ] T313 [US9-core] Write test `core/tests/test_recipe_unlock.cob`: recipe unlocks by ingredient pickup and advancement-free conditions (27) and Recipe Book Add/Remove/Settings/Seen handling
- [ ] T314 [US9-core] Implement recipe unlocks in `core/src/recipe-unlock.cob`
- [ ] T315 [US9-core] Write test `core/tests/test_place_recipe.cob`: Place Recipe fills the grid from the inventory with the choice of ingredients of 13 §3.8, replacing what is in the grid (US9-2)
- [ ] T316 [US9-core] Implement Place Recipe in `core/src/recipe-unlock.cob`
- [ ] T317 [US9-core] Write test `core/tests/test_creative_throw.cob` (CC-0006): in creative a stack carried by the cursor and clicked outside the window becomes a ground item through Set Creative Mode Slot with the drop flag
- [ ] T318 [US9-core] Make the creative cursor throw work in `core/src/inventory.cob` (CC-0006)
- [ ] T319 [US9-core] Remove the 001 crafting module programs `CRAFT-TRY`, `CRAFT-BOOK-BUILD`, `CRAFT-BOOK-SEND`, `CRAFT-PLACE` from `core/src/crafting.cob` and their tests (FR-028), keeping nothing the new modules do not use
- [ ] T320 [US9-core] Write contract tests in `core/tests/contract_wire_server.cob` for the container and recipe-book fixtures
- [ ] T321 [US9-core] Gate: run `make gate-core` and record the command and real output

#### Phase 33: US10-core — crafting bench menu

- [ ] T322 [US10-core] Write test `core/tests/test_bench_menu.cob`: Use Item On a placed bench opens the 3x3 menu (12 §5.6b, 13 §3.5); a recipe that needs the large grid matches only in the bench menu (US10-3); the bench block places as an item
- [ ] T323 [US10-core] Implement the bench menu and block interaction in `core/src/menu-bench.cob`
- [ ] T324 [US10-core] Gate: run `make gate-core` and record the command and real output

#### Phase 34: US11-core (a) — chunk generation queue and the cost measurement

- [ ] T325 [US11-core] Write test `core/tests/test_gen_queue.cob`: the chunk generation queue orders wanted chunks nearest first and obeys the per-tick budget (R12)
- [ ] T326 [US11-core] Implement the generation queue in `core/src/gen-queue.cob` and run it from `CORE-TICK` in `core/src/api.cob`
- [ ] T327 [US11-core] Measure one generated chunk with the `cc_f64` noise path (Risk R-P, first US11 task): add `core/tests/test_gen_cost.cob` that prints the elapsed time of one chunk and fails when it exceeds the per-tick budget recorded in `specs/002-client-polish/research.md` R12 (a result above the budget goes back to the plan, not to a hack)
- [ ] T328 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 35: US11-core (b) — random sources, noise, climate, biome source

- [ ] T329 [US11-core] Write test `core/tests/test_random_sources.cob`: positional random splitters and seed forks of `docs/protocol/10-world-generation-terrain.md` with the worked examples (extends `core/src/rng.cob`)
- [ ] T330 [US11-core] Implement them in `core/src/rng.cob`
- [ ] T331 [US11-core] Write test `core/tests/test_noise.cob`: improved/perlin noise, octave and normal noise via `cc_f64_*` match the worked examples bit for bit (10)
- [ ] T332 [US11-core] Implement the noises in `core/src/noise.cob`
- [ ] T333 [US11-core] Write test `core/tests/test_climate.cob`: the six climate parameters at sample points and the multi-noise biome lookup (10, 37 part 3)
- [ ] T334 [US11-core] Implement climate and the biome source in `core/src/climate.cob`
- [ ] T335 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 36: US11-core (c) — density, aquifers, surface

- [ ] T336 [US11-core] Write test `core/tests/test_density.cob`: the density function graph evaluation, cell interpolation and final density at sample points (10, 37 part 2)
- [ ] T337 [US11-core] Implement density evaluation in `core/src/density.cob`
- [ ] T338 [US11-core] Write test `core/tests/test_terrain_fill.cob`: the stone/water/air fill of a chunk from final density with the worked example columns
- [ ] T339 [US11-core] Implement the terrain fill in `core/src/terrain.cob`
- [ ] T340 [US11-core] Write test `core/tests/test_aquifer.cob`: aquifer fluid level and barrier decisions (10)
- [ ] T341 [US11-core] Implement aquifers in `core/src/aquifer.cob`
- [ ] T342 [US11-core] Write test `core/tests/test_surface_rules.cob`: the surface rule evaluation for badlands, desert, ocean floors and the default (10, 37 part 4)
- [ ] T343 [US11-core] Implement surface rules in `core/src/surface.cob`
- [ ] T344 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 37: US11-core (d) — carvers and caves

- [ ] T345 [US11-core] Write test `core/tests/test_carvers.cob`: the cave and canyon carvers over the documented seed and chunk with the worked examples (11)
- [ ] T346 [US11-core] Implement the carvers in `core/src/carvers.cob`
- [ ] T347 [US11-core] Write test `core/tests/test_noise_caves.cob`: the large cavern, long tunnel and thin noodle passages from the density router (US11-1; 11)
- [ ] T348 [US11-core] Implement the noise caves in `core/src/noise-caves.cob`
- [ ] T349 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 38: US11-core (e) — ores and ore drops

- [ ] T350 [US11-core] Write acceptance test `core/tests/acc_f2us11_ores.cob` (US11-2): each ore's height distribution (uniform or triangle), vein size and count per chunk, depth and biome limits (11)
- [ ] T351 [US11-core] Implement ore placement in `core/src/ores.cob`
- [ ] T352 [US11-core] Write test `core/tests/test_ore_veins.cob`: the large ore vein and the copper/iron vein noise of 11
- [ ] T353 [US11-core] Implement the large veins in `core/src/ores.cob`
- [ ] T354 [US11-core] Write acceptance test `core/tests/acc_f2us11_ore_drops.cob` (US11-3): ore blocks broken in survival drop their items through the loot tables (11 §9, 26)
- [ ] T355 [US11-core] Implement the loot engine of 26 (conditions, functions, rolls) in `core/src/loot.cob`
- [ ] T356 [US11-core] Implement block drops from loot tables in `core/src/block-drops.cob`
- [ ] T357 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 39: US11-core (f) — generation pipeline and the 24-section stream

- [ ] T358 [US11-core] Write acceptance test `core/tests/acc_f2us11_world.cob` (US11-1): a fixed-seed standard world generates a chunk whose columns equal the worked examples of 10 and 11, including the status order and neighbour requirements
- [ ] T359 [US11-core] Implement the generation pipeline that calls biome, density, aquifer, surface, carver and ore stages in `core/src/worldgen-standard.cob`, selected by world type (the cobolcraft type keeps `core/src/worldgen.cob`, FR-033)
- [ ] T360 [US11-core] Write contract tests `core/tests/contract_vanilla_chunk.cob`: the chunk data of a standard world equals the bytes of the 06 worked examples (the automated half of Q-1)
- [ ] T361 [US11-core] Make the generated chunk stream pass `contract_vanilla_chunk` in `core/src/chunks-stream.cob`
- [ ] T362 [US11-core] Gate: run `make gate-core` and record the command and real output

#### Phase 40: US12-core (a) — block updates and fluids

- [ ] T363 [US12-core] Write test `core/tests/test_block_updates.cob`: placement rules, neighbour updates, scheduled ticks and their order (`docs/protocol/29-block-updates-and-placement.md`)
- [ ] T364 [US12-core] Implement block updates in `core/src/block-updates.cob`
- [ ] T365 [US12-core] Write test `core/tests/test_fluids.cob`: water and lava flow, sources, falling, mixing, drain (`29a-fluids.md`)
- [ ] T366 [US12-core] Implement fluids in `core/src/fluids.cob`
- [ ] T367 [US12-core] Write test `core/tests/test_world_tick_order.cob`: the tick order of 33 (updates, fluids, growth, redstone)
- [ ] T368 [US12-core] Implement the ordered world tick in `core/src/world-tick.cob`
- [ ] T369 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 41: US12-core (b) — falling blocks, growth, fire

- [ ] T370 [US12-core] Write test `core/tests/test_falling_gravity.cob`: falling blocks, gravity, bonemeal (`29b-falling-growth-fire-1-model-gravity-bonemeal.md`)
- [ ] T371 [US12-core] Implement them in `core/src/falling.cob`
- [ ] T372 [US12-core] Write test `core/tests/test_growth_crops.cob`: crops and stems (29b part 2) and growing plants (part 4), including the light dependency of D-light (`32-light-engine.md`)
- [ ] T373 [US12-core] Implement crop and plant growth in `core/src/growth.cob`
- [ ] T374 [US12-core] Write test `core/tests/test_spread_decay.cob`: spread, decay, snow and ice (29b part 3)
- [ ] T375 [US12-core] Implement spread and decay in `core/src/spread.cob`
- [ ] T376 [US12-core] Write test `core/tests/test_special_growth.cob`: fungi, moss, copper (part 5), sculk, amethyst, dripstone (part 6), aquatic eggs, honey, cauldron (part 7)
- [ ] T377 [US12-core] Implement them in `core/src/growth-special.cob`
- [ ] T378 [US12-core] Write test `core/tests/test_fire_tnt.cob`: fire spread and burn-out, TNT and the residual rules (29b part 8)
- [ ] T379 [US12-core] Implement fire and TNT in `core/src/fire.cob`
- [ ] T380 [US12-core] Write test `core/tests/test_light_engine.cob`: the server light engine as far as gameplay and the chunk packets need it (`32-light-engine.md`, D-light)
- [ ] T381 [US12-core] Replace `core/src/light.cob` with the engine of 32
- [ ] T382 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 42: US12-core (c) — redstone

- [ ] T383 [US12-core] Write test `core/tests/test_redstone_wire.cob`: signal model and wire (`30-redstone-1-model-signal-and-wire.md`)
- [ ] T384 [US12-core] Implement them in `core/src/redstone-wire.cob`
- [ ] T385 [US12-core] Write test `core/tests/test_redstone_logic.cob`: repeaters, comparators, observers (30 part 2)
- [ ] T386 [US12-core] Implement them in `core/src/redstone-logic.cob`
- [ ] T387 [US12-core] Write test `core/tests/test_pistons.cob`: pistons and slime/honey pushing, push reactions (30 part 3)
- [ ] T388 [US12-core] Implement pistons in `core/src/pistons.cob`
- [ ] T389 [US12-core] Write test `core/tests/test_redstone_devices.cob`: dispensers, droppers, hoppers, crafters (30 part 4)
- [ ] T390 [US12-core] Implement them in `core/src/redstone-devices.cob`
- [ ] T391 [US12-core] Write test `core/tests/test_redstone_inputs.cob`: switches, plates, sensors, note blocks (30 part 5)
- [ ] T392 [US12-core] Implement them in `core/src/redstone-inputs.cob`
- [ ] T393 [US12-core] Write test `core/tests/test_rails.cob`: rails and minecart-related rules (30 part 6)
- [ ] T394 [US12-core] Implement rails in `core/src/rails.cob`
- [ ] T395 [US12-core] Write test `core/tests/test_redstone_blocks.cob`: doors, lamps, bulbs, TNT activation (30 part 7), tripwire, sculk sensors, bells, vibration (part 8)
- [ ] T396 [US12-core] Implement them in `core/src/redstone-blocks.cob`
- [ ] T397 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 43: US12-core (d) — block entities and menus

- [ ] T398 [US12-core] Write test `core/tests/test_block_entities_model.cob`: shared block entity model, containers and their NBT (`31-block-entities-1-shared-model-and-containers.md`)
- [ ] T399 [US12-core] Implement it in `core/src/block-entities.cob`
- [ ] T400 [US12-core] Write test `core/tests/test_furnaces.cob`: processing and redstone containers (31 part 2): furnaces, brewing, crafter
- [ ] T401 [US12-core] Implement them in `core/src/be-processing.cob`
- [ ] T402 [US12-core] Write test `core/tests/test_be_signs.cob`: signs, banners, skulls, pots, shelves (31 part 3)
- [ ] T403 [US12-core] Implement them in `core/src/be-decor.cob`
- [ ] T404 [US12-core] Write test `core/tests/test_be_interactive.cob`: jukebox, lectern, bell, campfire, brushable, beehive (31 part 4)
- [ ] T405 [US12-core] Implement them in `core/src/be-interactive.cob`
- [ ] T406 [US12-core] Write test `core/tests/test_be_world.cob`: beacon, conduit, end piston, creaking (31 part 5), command, structure, jigsaw, test blocks (part 6) with `TestInstanceBlockEditScreen` per Round TIBE
- [ ] T407 [US12-core] Implement them in `core/src/be-world.cob`
- [ ] T408 [US12-core] Write test `core/tests/test_be_spawners.cob`: spawners, trial spawners, vaults (31 part 7), sculk and remaining types (part 8)
- [ ] T409 [US12-core] Implement them in `core/src/be-spawners.cob`
- [ ] T410 [US12-core] Write test `core/tests/test_menus_machines.cob`: furnace, brewing, crafter, anvil, grindstone, smithing menus (`40-menus-2-furnaces-brewing-crafter.md`, `40-menus-3-anvil-grindstone-smithing.md`)
- [ ] T411 [US12-core] Implement them in `core/src/menu-machines.cob`
- [ ] T412 [US12-core] Write test `core/tests/test_menus_other.cob`: enchanting, loom, stonecutter, cartography (40 part 4), merchant, beacon, lectern (part 5), mount inventories (part 6), creative inventory (part 7), book and sign editors (part 8), continuation (x1)
- [ ] T413 [US12-core] Implement them in `core/src/menu-other.cob`
- [ ] T414 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 44: US12-core (e) — features and structures

- [ ] T415 [US12-core] Write test `core/tests/test_features_model.cob`: feature model, placement modifiers, predicates and providers (`35-worldgen-features-1-model-and-placement.md`, `-2-predicates-and-providers.md`)
- [ ] T416 [US12-core] Implement them in `core/src/features.cob`
- [ ] T417 [US12-core] Write test `core/tests/test_tree_placers.cob`: tree placers (35 part 3) with the documented trees
- [ ] T418 [US12-core] Implement tree placers in `core/src/trees.cob`
- [ ] T419 [US12-core] Write test `core/tests/test_vegetation_lakes.cob`: decorators and vegetation (35 part 4), water and surface features including lakes (part 5)
- [ ] T420 [US12-core] Implement them in `core/src/vegetation.cob`
- [ ] T421 [US12-core] Write test `core/tests/test_underground_features.cob`: underground features (35 part 6) and Nether/End misc features (part 7)
- [ ] T422 [US12-core] Implement them in `core/src/features-underground.cob`
- [ ] T423 [US12-core] Write acceptance test `core/tests/acc_f2us12_features.cob` (US12-1): a generated overworld area contains trees, vegetation and lakes placed by the decoration order
- [ ] T424 [US12-core] Wire the decoration stage into the pipeline in `core/src/worldgen-standard.cob`
- [ ] T425 [US12-core] Write test `core/tests/test_structure_starts.cob`: structure model, placement, starts (`36-structures-1-model-placement-starts.md`, `44-residual-mob-questions-2-spawning-structures.md`)
- [ ] T426 [US12-core] Implement structure starts in `core/src/structure-starts.cob`
- [ ] T427 [US12-core] Write test `core/tests/test_templates_jigsaw.cob`: templates and processors (36 part 2), jigsaw assembly (part 3)
- [ ] T428 [US12-core] Implement templates and jigsaw in `core/src/jigsaw.cob`
- [ ] T429 [US12-core] Write test `core/tests/test_structures_small.cob`: scattered and small structures (36 part 4), mineshaft and stronghold (part 5)
- [ ] T430 [US12-core] Implement them in `core/src/structures-small.cob`
- [ ] T431 [US12-core] Write test `core/tests/test_structures_big.cob`: ocean (36 part 6), woodland mansion (part 7), villages and outposts (part 9), ancient city, trial chambers, trail ruins (part 10)
- [ ] T432 [US12-core] Implement them in `core/src/structures-big.cob`
- [ ] T433 [US12-core] Write acceptance test `core/tests/acc_f2us12_structures.cob` (US12-2): a fixed-seed standard world places a village or other documented structure at the documented position
- [ ] T434 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 45: US12-core (f) — Nether, End and portals

- [ ] T435 [US12-core] Write test `core/tests/test_nether_rules.cob`: dimension rules, noise settings and density, biome source and climate (`37-nether-1-...` to `-3-...`)
- [ ] T436 [US12-core] Implement the Nether terrain in `core/src/nether.cob`
- [ ] T437 [US12-core] Write test `core/tests/test_nether_decor.cob`: surface rules, carvers, features and decoration, structures, spawns and hooks (37 parts 4 to 6)
- [ ] T438 [US12-core] Implement them in `core/src/nether-decor.cob`
- [ ] T439 [US12-core] Write test `core/tests/test_end.cob`: the End islands, outer islands, dragon fight and crystals (`38-end.md`)
- [ ] T440 [US12-core] Implement the End in `core/src/end.cob`
- [ ] T441 [US12-core] Write acceptance test `core/tests/acc_f2us12_portals.cob` (US12-3): Nether portal frame detection, linking and travel with coordinate scaling, End portal and exit (`39-portals.md`), Respawn/Login packets per dimension
- [ ] T442 [US12-core] Implement portals and dimension travel in `core/src/portals.cob`
- [ ] T443 [US12-core] Write acceptance test `core/tests/acc_f2us12_redstone.cob` (US12-4): a documented redstone circuit behaves as in its worked example
- [ ] T444 [US12-core] Write contract tests `core/tests/contract_wire_server.cob` additions for the level event, particle and three-dimension login fixtures
- [ ] T445 [US12-core] Gate: run `make gate-core` and record the command and real output

#### Phase 46: US13-core — command framework and catalog

- [ ] T446 [US13-core] Write test `core/tests/test_cmd_parse.cob`: tokenising and parsing of `docs/protocol/15a-brigadier-command-library.md` and 15 §4, coordinates (§8)
- [ ] T447 [US13-core] Create `core/src/cmd-parse.cob` (split from `core/src/commands.cob`) implementing it
- [ ] T448 [US13-core] Write test `core/tests/test_cmd_tree.cob`: the command tree with permission-level filtering (levels 0 to 4, README Part 7 decision 8) and the Commands packet nodes (15 §2, §3)
- [ ] T449 [US13-core] Create `core/src/cmd-tree.cob` implementing it
- [ ] T450 [US13-core] Write test `core/tests/test_cmd_args.cob`: argument types (15 §6), blocks, items, text, NBT (§9)
- [ ] T451 [US13-core] Create `core/src/cmd-args.cob` implementing them
- [ ] T452 [US13-core] Write test `core/tests/test_selectors.cob`: entity selectors (15 §7)
- [ ] T453 [US13-core] Create `core/src/selectors.cob` implementing them
- [ ] T454 [US13-core] Write test `core/tests/test_cmd_execute.cob`: execution, result values and the `execute` grammar (15 §10, §11), functions (§12)
- [ ] T455 [US13-core] Create `core/src/cmd-exec.cob` implementing them
- [ ] T456 [US13-core] Write test `core/tests/test_cmd_suggest.cob`: suggestions and completion (15 §14) for both sets
- [ ] T457 [US13-core] Create `core/src/cmd-suggest.cob` implementing them
- [ ] T458 [US13-core] Write test `core/tests/test_cmd_messages.cob`: framework translation keys and failure messages (15 §5)
- [ ] T459 [US13-core] Create `core/src/cmd-messages.cob` implementing them
- [ ] T460 [US13-core] Write test `core/tests/test_cmds_state.cob`: the commands of `docs/protocol/16-commands-catalog.md` §4 (player and game state) with the §14a results and §15 worked examples
- [ ] T461 [US13-core] Create `core/src/cmds-state.cob` implementing them
- [ ] T462 [US13-core] Write test `core/tests/test_cmds_entities.cob`: catalog §5 (entities and movement)
- [ ] T463 [US13-core] Create `core/src/cmds-entities.cob` implementing them
- [ ] T464 [US13-core] Write test `core/tests/test_cmds_items.cob`: catalog §6 (items and inventory)
- [ ] T465 [US13-core] Create `core/src/cmds-items.cob` implementing them
- [ ] T466 [US13-core] Write test `core/tests/test_cmds_world.cob`: catalog §7 (world editing)
- [ ] T467 [US13-core] Create `core/src/cmds-world.cob` implementing them
- [ ] T468 [US13-core] Write test `core/tests/test_cmds_chat.cob`: catalog §8 (chat and display) with standard chat types
- [ ] T469 [US13-core] Create `core/src/cmds-chat.cob` implementing them
- [ ] T470 [US13-core] Write test `core/tests/test_cmds_scoreboard.cob`: catalog §9 (scoreboard and teams)
- [ ] T471 [US13-core] Create `core/src/cmds-scoreboard.cob` implementing them
- [ ] T472 [US13-core] Write test `core/tests/test_cmds_data.cob`: catalog §10 (data, functions and flow)
- [ ] T473 [US13-core] Create `core/src/cmds-data.cob` implementing them
- [ ] T474 [US13-core] Write test `core/tests/test_cmds_admin.cob`: catalog §11 (server administration), §12 (dev and debug), the gamerule table (§13) and aliases (§14)
- [ ] T475 [US13-core] Create `core/src/cmds-admin.cob` implementing them
- [ ] T476 [US13-core] Write acceptance test `core/tests/acc_f2us13_levels.cob` (US13-3, US13-4): a level-0 player is refused a level-2 command with the standard message; a bare name means `minecraft:` and in a cobolcraft world commands run against cobolcraft registries
- [ ] T477 [US13-core] Remove the 001 command set: delete `core/src/commands.cob` and `core/copy/COMMANDS.cpy`, `core/copy/CMDPARSE.cpy` once nothing calls them, and re-point `core/src/api.cob`
- [ ] T478 [US13-core] Write contract tests `core/tests/contract_wire_server.cob` additions for the Commands, suggestion and chat fixtures
- [ ] T479 [US13-core] Gate: run `make gate-core` and record the command and real output

#### Phase 47: US14-core — tools, weapons, armor, enchantments

- [ ] T480 [US14-core] Write test `core/tests/test_tool_speed.cob`: break speed and tier, correct tool for drops, tag rules (`docs/protocol/17-tools-weapons-and-combat.md` §1, §2, Appendix A) feeding the US8 formula
- [ ] T481 [US14-core] Implement tool speed and tiers in `core/src/tools.cob`
- [ ] T482 [US14-core] Write test `core/tests/test_special_uses.cob`: special uses (17 §3): axe stripping, hoe tilling, shovel paths, shears, buckets, flint and steel, bows
- [ ] T483 [US14-core] Implement special uses in `core/src/tool-uses.cob`
- [ ] T484 [US14-core] Write test `core/tests/test_combat.cob`: damage, critical hits, sweep, hit window, knockback, shield, armor reduction (17 §4) with the worked examples of §8
- [ ] T485 [US14-core] Implement combat in `core/src/combat.cob`
- [ ] T486 [US14-core] Write test `core/tests/test_durability.cob`: durability, Unbreaking, Mending, repair (17 §5) and the Set Slot damage update
- [ ] T487 [US14-core] Implement durability in `core/src/durability.cob`
- [ ] T488 [US14-core] Write test `core/tests/test_enchantments.cob`: enchantment effects (17 §6, `28-enchantment-effects.md`), attributes and mob effects packets
- [ ] T489 [US14-core] Implement enchantments and effects in `core/src/enchantments.cob`
- [ ] T490 [US14-core] Gate: run `make gate-core` and record the command and real output

#### Phase 48: US15-core — mobs

- [ ] T491 [US15-core] Write test `core/tests/test_mob_framework.cob`: per-tick update order, entity physics beyond the player (`docs/protocol/18-mob-framework.md` §2, §3)
- [ ] T492 [US15-core] Replace `core/src/mobs.cob` and `core/src/entities.cob` logic by the framework in `core/src/mob-framework.cob`
- [ ] T493 [US15-core] Write test `core/tests/test_mob_ai.cob`: the goal/AI system (18 §4)
- [ ] T494 [US15-core] Implement the AI system in `core/src/mob-ai.cob`
- [ ] T495 [US15-core] Write test `core/tests/test_pathfinding.cob`: pathfinding (18 §5)
- [ ] T496 [US15-core] Implement pathfinding in `core/src/pathfinding.cob`
- [ ] T497 [US15-core] Write test `core/tests/test_spawning.cob`: natural spawning per chunk, light and biome data (18 §6, Appendix A, `44-residual-mob-questions-2-spawning-structures.md`)
- [ ] T498 [US15-core] Implement natural spawning in `core/src/spawning.cob`
- [ ] T499 [US15-core] Write test `core/tests/test_mob_damage.cob`: damage, knockback, death, drops and experience (18 §7)
- [ ] T500 [US15-core] Implement them in `core/src/mob-damage.cob`
- [ ] T501 [US15-core] Write test `core/tests/test_breeding_taming.cob`: breeding, ageing, taming, leashing, riding (18 §8)
- [ ] T502 [US15-core] Implement them in `core/src/mob-social.cob`
- [ ] T503 [US15-core] Write test `core/tests/test_entity_tracking.cob`: server-side tracking and sending, Spawn Entity, Set Entity Data, Update Attributes (18 §9)
- [ ] T504 [US15-core] Implement entity tracking in `core/src/entity-tracking.cob`
- [ ] T505 [US15-core] Write test `core/tests/test_mobs_land.cob`: land friendly and neutral mobs (`19-mobs-land-friendly-and-neutral.md`, `44-residual-mob-questions-4-land-animals.md`)
- [ ] T506 [US15-core] Implement them in `core/src/mobs-land.cob`
- [ ] T507 [US15-core] Write test `core/tests/test_mobs_hostile.cob`: overworld hostile mobs (`20-mobs-overworld-hostile.md`, 44 part 5)
- [ ] T508 [US15-core] Implement them in `core/src/mobs-hostile.cob`
- [ ] T509 [US15-core] Write test `core/tests/test_mobs_aquatic_nether.cob`: aquatic, Nether, End mobs and bosses, vehicles and projectiles (`21-...`, 44 parts 6, 7, 8, 9)
- [ ] T510 [US15-core] Implement them in `core/src/mobs-other.cob`
- [ ] T511 [US15-core] Write test `core/tests/test_villagers.cob`: villagers, points of interest, raids (44 part 3)
- [ ] T512 [US15-core] Implement them in `core/src/villagers.cob`
- [ ] T513 [US15-core] Write test `core/tests/test_entity_nbt.cob`: entity NBT read and write for every mob family (`45-entity-nbt-1-...` to `-9-...`) through `core/src/entity-data.cob`
- [ ] T514 [US15-core] Complete entity NBT in `core/src/entity-data.cob`
- [ ] T515 [US15-core] Write acceptance test `core/tests/acc_f2us15_mob_rules.cob` (US15-2): where a standard rule and a stand-in value differ, the standard wins in both types
- [ ] T516 [US15-core] Gate: run `make gate-core` and record the command and real output

#### Phase 49: US19-core — off-hand swap

- [ ] T517 [US19-core] Write test `core/tests/test_offhand_swap.cob`: the Player Action swap exchanges the held hotbar item with slot 45 and sends Set Slot for both; Container Click swap with the off-hand slot in the inventory menu (13 §4, US19-1, US19-2)
- [ ] T518 [US19-core] Implement the swap in `core/src/menu-inventory.cob` and the Player Action handler
- [ ] T519 [US19-core] Gate: run `make gate-core` and record the command and real output

#### Phase 50: US21-core — vanilla configuration conformance (automated half of Q-1)

- [ ] T520 [US21-core] Write contract test `core/tests/contract_vanilla_config.cob`: the configuration packet stream of a standard world (Known Packs, 51 Registry Data, Update Tags, Finish Configuration, then Login) equals the bytes of the 04 worked examples and the 46 id tables (US21-1)
- [ ] T521 [US21-core] Make the configuration phase of `core/src/config-phase.cob` pass `contract_vanilla_config` for the standard set and send only the cobolcraft registries for the cobolcraft set (WT-16, US21-2)
- [ ] T522 [US21-core] Gate: run `make gate-core` and record the command and real output

### Lane: server

#### Phase 51: US1-server — generated-dir key and console texts

- [ ] T523 [US1-server] Write test `server/tests/test_config_generated_dir.cob`: the `generated-dir` key of `server.properties` (default `<game dir>/generated`) fills `CS-GENERATED-DIR`
- [ ] T524 [US1-server] Implement the key in `server/src/config-file.cob`
- [ ] T525 [US1-server] Write acceptance test `server/tests/acc_f2us1_startup_packs.cob` (US1-3, US1-4): at start-up the server prints the packs status line of `docs/protocol/22-extraction-tool.md` §9.2 for each of the five statuses and the cobolcraft type still starts
- [ ] T526 [US1-server] Implement the start-up check and console texts in `server/src/main.cob` and `server/src/console.cob`
- [ ] T527 [US1-server] Write contract tests (extended) `server/tests/contract_coreapi_consumer.cob` for the new settings fields and statuses
- [ ] T528 [US1-server] Free-port test fix (CC-0005): make `server/tests/` tests that listen on the default port 25565 choose a free port at run time and check the configured default value without binding; add `server/tests/test_default_port_free.cob`
- [ ] T529 [US1-server] Gate: run `make gate-server` and record the command and real output, including a run while a listener holds port 25565

#### Phase 52: US2-server — world-type key

- [ ] T530 [US2-server] Write test `server/tests/test_config_world_type.cob`: key `world-type` accepts `standard` and `cobolcraft`, default `standard`, rejects other values with the documented message; an existing world's recorded type wins
- [ ] T531 [US2-server] Implement the key in `server/src/config-file.cob`
- [ ] T532 [US2-server] Write acceptance test `server/tests/acc_f2us2_refusal.cob`: a standard world with packs not `ok`, or a foreign folder, makes the server stop with exit code 10 and the reason on the console (core-host-delta §2, world-types.md §2.1)
- [ ] T533 [US2-server] Implement the refusal exit in `server/src/main.cob`
- [ ] T534 [US2-server] Gate: run `make gate-server` and record the command and real output

#### Phase 53: US21-server — start-up log lines for the manual run

- [ ] T535 [US21-server] Write test `server/tests/test_startup_lines.cob`: the server prints the world type, the generated directory, the registry counts and "Done" lines that the manual run of `quickstart.md` §9 records
- [ ] T536 [US21-server] Implement the lines in `server/src/console.cob`
- [ ] T537 [US21-server] Gate: run `make gate-server` and record the command and real output

### Lane: client

#### Phase 54: US11-client (a) — replica, mesher and cell model re-base (scheduled first in this lane)

**Goal**: the client holds 16-bit states, any number of sections per dimension and three dimensions, decoding both the 001 and the 24-section chunk forms, so no later client gate sees a form it cannot read (lane note). **Independent Test**: `test_world_replica`, `test_mesher` over the 24-section fixture.

- [ ] T538 [US11-client] Write consumer test `client/tests/contract_content_consumer.cob`: opens a set through a `contract/fixtures/content/` tree, asserts status words and one block lookup
- [ ] T539 [US11-client] Write test cases in `client/tests/test_world_replica.cob` for a 24-section chunk through `PB-GET-CHUNK-24` (16-bit states, 4-bit light, biome containers, rows sized from the dimension's `min_y` and `height`) and for the 001 form
- [ ] T540 [US11-client] Re-base `client/src/world-replica.cob` on `contract/copy/CELLS.cpy` and delete `client/copy/CLCELLS.cpy`; size the replica from the dimension and the content set, no cap smaller than the standard content (`CL-MAX-SECTIONS`, `CL-MAX-STATES`, `CL-MAX-BIOMES` in `client/copy/CLCONST.cpy`)
- [ ] T541 [US11-client] Write test cases in `client/tests/test_mesher.cob` for a 24-section column: per-state opacity and cull tables built once at load from `CONTENT-*`, states above 255 mesh correctly, section height is the dimension's
- [ ] T542 [US11-client] Re-base `client/src/mesher.cob` on the new cell model and the per-state tables (rewrite of the "16-high section" assumption)
- [ ] T543 [US11-client] Update `client/src/protocol-client.cob` chunk handling to decode both forms and split the file by packet family into `client/src/protocol-world.cob`, `protocol-play.cob`, `protocol-config.cob` as it is touched (1,646 lines)
- [ ] T544 [US11-client] Write contract test cases in `client/tests/contract_wire_client.cob` for the chunk, registry and tags fixtures it receives
- [ ] T545 [US11-client] Update `client/src/sp-host.cob` for the new core API (settings, three dimensions) and its tests `client/tests/test_sp_host.cob`
- [ ] T546 [US11-client] Gate: run `make gate-client` and record the command and real output

#### Phase 55: US1-client — start-up check and banner

- [ ] T547 [US1-client] Write test `client/tests/test_args.cob` cases for `--generated-dir` (22 §5.1) and the default `<game dir>/generated`
- [ ] T548 [US1-client] Add `--generated-dir` to `client/src/args.cob` and `client/copy/CLARGS.cpy`
- [ ] T549 [US1-client] Write acceptance test `client/tests/acc_f2us1_banner.cob` (US1-3): with no valid packs the title screen shows the built-in-language banner `cobolcraft.packs.*` (`docs/protocol/22-extraction-tool.md` §9.2) stating the status and how to build the packs; with valid packs the banner is absent; the cobolcraft type is unaffected
- [ ] T550 [US1-client] Implement the start-up `CORE-PACKS-STATUS` call, the banner state and the title screen banner in `client/src/main.cob` and `client/src/screens/title.cob`
- [ ] T551 [US1-client] Write acceptance test `client/tests/acc_f2us1_loaders.cob` (US1-4, real input): after a real extraction into `build/generated-test/` the client's content open of the standard set reports no loader error
- [ ] T552 [US1-client] Gate: run `make gate-client` and record the command and real output

#### Phase 56: US2-client — world type choice, remembered type, refusal

- [ ] T553 [US2-client] Write acceptance test `client/tests/acc_f2us2_create_screen.cob` (US2-1, US2-2, FR-003): with valid packs both types are offered and standard is the default; with packs not `ok` the standard choice stays selectable and Create is refused with the explanation text `cobolcraft.world_type.*` of how to build the packs, and nothing is created; the cobolcraft type creates
- [ ] T554 [US2-client] Add the type choice, the refusal text and the settings fill (`CS-WORLD-TYPE`, `CS-SEED-TEXT`) to `client/src/screens/create-world.cob`
- [ ] T555 [US2-client] Write acceptance test `client/tests/acc_f2us2_world_list.cob` (US2-3): the world list shows each world's type; opening a standard world with packs not `ok` is refused with the reason (`docs/design/world-types.md` §8.2)
- [ ] T556 [US2-client] Implement the type column and the refusal in `client/src/screens/world-list.cob` and `client/src/game-dir.cob`
- [ ] T557 [US2-client] Write test `client/tests/test_wt16.cob`: on a multiplayer join the client decides the world type from `minecraft:dimension_type` at Finish Configuration (WT-16) and opens the matching content set
- [ ] T558 [US2-client] Implement the WT-16 decision in `client/src/net-client.cob`
- [ ] T559 [US2-client] Add built-in-language entries `cobolcraft.packs.*` and `cobolcraft.world_type.*` to `client/src/packs/builtin.cob` (texts from `docs/design/builtin-ui-art.md` §7.2) with their test cases in `client/tests/test_builtin_files.cob`
- [ ] T560 [US2-client] Gate: run `make gate-client` and record the command and real output

#### Phase 57: US3-client — pack stack and user packs

- [ ] T561 [US3-client] Write acceptance test `client/tests/acc_f2us3_pack_stack.cob` (US3-5, US3-6): stack order built-in, generated vanilla, the user's packs in the user's order, server packs; the top-most pack that has a path wins (08 §3.2); `minecraft:` anywhere a vanilla equivalent exists; a pack's `minecraft:` textures do not touch `cobolcraft:` content unless the optional skin is on (FR-006)
- [ ] T562 [US3-client] Extend `client/src/packs/stack.cob` with the generated vanilla level (level 2) and by-path override across levels 1 to 4; add the optional skin switch to the stack state
- [ ] T563 [US3-client] Write acceptance test `client/tests/acc_f2us3_user_pack.cob` (US3-1, US3-4, real input): the real Faithful zip lists on the pack screen, enables, moves and survives a restart; disabling returns the generated look
- [ ] T564 [US3-client] Make user packs from `resourcepacks/` load by zip or folder in `client/src/packs/local.cob`
- [ ] T565 [US3-client] Write test `client/tests/test_atlas.cob` cases for a generic sprite size (16 and 32 pixels from the packs, not a constant) and more than 128 sprites (1,297 block sprites for Faithful)
- [ ] T566 [US3-client] Rewrite `client/src/atlas.cob` stitching for any sprite size and count (`CL-MAX-SPRITES` sized from the packs)
- [ ] T567 [US3-client] Write test `client/tests/test_animation.cob`: `.mcmeta` animation files (frame order, frame time, interpolate) schedule frame updates per cell (14, FR-010); a malformed animation file falls back to the pack below
- [ ] T568 [US3-client] Implement animation timers in `client/src/packs/mcmeta.cob` and the per-frame `cc_vk_texture_update` calls in `client/src/render-list.cob`
- [ ] T569 [US3-client] Write test `client/tests/test_connected_ignored.cob`: connected-texture rules the client does not support are ignored without error and an undecodable texture falls back to the pack below (edge cases)
- [ ] T570 [US3-client] Make unsupported rules and bad textures non-fatal in `client/src/packs/source.cob`
- [ ] T571 [US3-client] Write acceptance test `client/tests/acc_f2us3_pack_screen.cob` (US3-1): the pack screen lists, enables, disables and reorders; a pack zip removed while enabled falls back and the screen says so; two packs with the same path let the higher win
- [ ] T572 [US3-client] Update `client/src/screens/pack-select.cob` for the new states
- [ ] T573 [US3-client] Write acceptance test `client/tests/acc_f2us3_coverage_walk.cob` (US3-2, SC-001): with the real Faithful zip, a checklist walk resolves blocks, items, mobs, GUI sprites, particles, weather and font from the pack and no resolved sprite is the missing-texture stripe where the pack covers it (FR-015 keeps the stripes elsewhere)
- [ ] T574 [US3-client] Make the walk pass: add the resolution paths for GUI, particle, weather and font sprites in `client/src/packs/stack.cob`, `client/src/ui-render.cob`, `client/src/weather-render.cob`
- [ ] T575 [US3-client] Gate: run `make gate-client` and record the command and real output

#### Phase 58: US4-client — Open Pack Folder

- [ ] T576 [US4-client] Write acceptance test `client/tests/acc_f2us4_open_folder.cob` (US4-1, US4-2, Q-2): the client state names the opener program; the test sets `/usr/bin/true`, presses Open Pack Folder, `resourcepacks/` is created if missing and the opener received the folder; a pack copied in is listed after refresh without a restart; one run line names the opener substituted
- [ ] T577 [US4-client] Write contract test `client/tests/contract_opener_production.cob`: a fresh client state names exactly `/usr/bin/open`, and a missing opener gives the `CC-NOTFOUND` path shown on the screen without a crash
- [ ] T578 [US4-client] Implement the opener state, the button and `PACK-FOLDER-SCAN` refresh in `client/src/screens/pack-select.cob` and `client/copy/CLSTATE.cpy`
- [ ] T579 [US4-client] Gate: run `make gate-client` and record the command and real output

#### Phase 59: US5-client — seamless textures

- [ ] T580 [US5-client] Write acceptance test `client/tests/acc_f2us5_seams.cob` (US5-1, SC-002): atlas readback shows padding around each cell per 12 §2.2 and §2.3 so a mip level of any cell never contains a neighbour's colour (fixtures with distinct cell colours at 16 and 32 pixels)
- [ ] T581 [US5-client] Implement padded stitching and the mip level count in `client/src/atlas.cob` and the `cc_vk_texture_ex` call in `client/src/render-list.cob`
- [ ] T582 [US5-client] Write test `client/tests/test_weather_atlas.cob` (CC-0003): rain and snow images of co-prime heights (17 and 19) produce a bounded weather atlas
- [ ] T583 [US5-client] Bound the weather atlas in `client/src/weather-render.cob` and `client/src/atlas.cob`
- [ ] T584 [US5-client] Gate: run `make gate-client` and record the command and real output

#### Phase 60: US6-client — HUD and screens

- [ ] T585 [US6-client] Write acceptance test `client/tests/acc_f2us6_layout.cob` (US6-1, SC-003): the HUD, inventory and menus at GUI scales 1 to the maximum and at and below the smallest supported window size have no overlapping or clipped element (render list bounds)
- [ ] T586 [US6-client] Implement the layout rules (alignment, spacing, GUI scale, minimum window size from Round GUI) in `client/src/ui-render.cob`
- [ ] T587 [US6-client] Write acceptance test `client/tests/acc_f2us6_counts.cob` (US6-2, FR-014): a slot with 1 item shows no count; 2, 64 and a count too wide for the slot show it aligned
- [ ] T588 [US6-client] Implement the count rule in `client/src/ui-render.cob`
- [ ] T589 [US6-client] Write acceptance test `client/tests/acc_f2us6_nine_slice.cob` (US6-3): with the Faithful fixture the screens' sprites, nine-slice scaling and font follow the pack's GUI textures (12 §5, 14 §6)
- [ ] T590 [US6-client] Implement nine-slice drawing and pack font use in `client/src/ui-render.cob` and `client/src/packs/font.cob`
- [ ] T591 [US6-client] Write acceptance test `client/tests/acc_f2us6_builtin_art.cob` (US6-4): in a cobolcraft world with no pack the screens use the built-in art, font and language and nothing is blank (`docs/design/builtin-ui-art.md`)
- [ ] T592 [US6-client] Complete the built-in UI art, glyphs and language in `client/src/packs/builtin.cob`, `client/copy/CLGLYPHS.cpy`, `client/copy/CLBUILTIN.cpy`
- [ ] T593 [US6-client] Restyle the HUD in `client/src/screens/hud.cob` and the title, pause, world list, create-world screens (`client/src/screens/*.cob`) to the layout rules
- [ ] T594 [US6-client] Gate: run `make gate-client` and record the command and real output

#### Phase 61: US7-client — flight only in creative

- [ ] T595 [US7-client] Write acceptance test `client/tests/acc_f2us7_survival_climb.cob` first, reproducing the first run's survival climb (P-client-5): in survival, double Space in the air and Space held in the air never rises above one jump height from the ground and never starts flying; record the failing observation
- [ ] T596 [US7-client] Write acceptance test `client/tests/acc_f2us7_creative_flight.cob` (US7-1, SC-004): in creative double Space toggles flying 20 of 20 times; in survival 0 of 20; spectator follows `docs/protocol/13` §1.4
- [ ] T597 [US7-client] Fix the jump and flight rules in `client/src/physics.cob` (jump only while on ground; flight toggle only when the abilities grant it) so both tests pass. If the cause is a core acceptance of `on-ground`, stop and escalate to multi-package
- [ ] T598 [US7-client] Write test case in `client/tests/test_physics.cob` for held Space on the ground in survival: repeats jumps as before, never exceeds one jump height in the air (edge case)
- [ ] T599 [US7-client] Gate: run `make gate-client` and record the command and real output

#### Phase 62: US8-client — break overlay

- [ ] T600 [US8-client] Write acceptance test `client/tests/acc_f2us8_overlay.cob` (US8-1 to US8-4): Block Destruction stages 0 to 9 draw the crack overlay on the block, stage -1 and a released button remove it, another player's stage draws too, and the overlay uses the pack's break-stage textures (12 §4, `faithful-pack-mapping.md`)
- [ ] T601 [US8-client] Implement the break overlay in `client/src/break-overlay.cob` and its draw in `client/src/render-list.cob`
- [ ] T602 [US8-client] Write test `client/tests/test_dig_actions.cob`: the client sends Player Action start, abort and finish with sequence ids (13 §2.3) and aborts on a held item change
- [ ] T603 [US8-client] Implement the dig action sending in `client/src/controls.cob`
- [ ] T604 [US8-client] Gate: run `make gate-client` and record the command and real output

#### Phase 63: US9-client — inventory screen and recipe book

- [ ] T605 [US9-client] Write acceptance test `client/tests/acc_f2us9_inventory.cob` (US9-1, US9-3): the inventory screen is the 46-slot menu with the 2x2 grid, result slot and off-hand slot, laid out per 12 §5.6a; clicks send Container Click
- [ ] T606 [US9-client] Rewrite `client/src/screens/inventory.cob` and `client/src/inventory-replica.cob` for the 46-slot menu and item stacks with components
- [ ] T607 [US9-client] Write acceptance test `client/tests/acc_f2us9_recipe_book.cob` (US9-2, SC-005): known recipes listed with makeable ones marked, tabs and toasts per Round GUI, choosing one sends Place Recipe and the grid fills (13 §3.8, §3.9)
- [ ] T608 [US9-client] Implement the recipe book panel in `client/src/screens/recipe-book.cob`
- [ ] T609 [US9-client] Write acceptance test `client/tests/acc_f2us9_creative_throw.cob` (CC-0006): in creative a cursor stack released outside the window sends the drop
- [ ] T610 [US9-client] Implement the creative throw in `client/src/screens/inventory.cob`
- [ ] T611 [US9-client] Remove the 001 crafting screen and the C key (FR-028, US9-4): delete `client/src/screens/crafting.cob`, `client/tests/acc_us10_crafting_screen.cob`, `client/tests/test_crafting.cob`, the C key binding in `client/src/screens/common.cob`, and the 16-recipe client table (`CL-MAX-RECIPES`)
- [ ] T612 [US9-client] Write contract test cases in `client/tests/contract_wire_client.cob` for the container and recipe-book fixtures
- [ ] T613 [US9-client] Gate: run `make gate-client` and record the command and real output

#### Phase 64: US10-client — crafting bench screen

- [ ] T614 [US10-client] Write acceptance test `client/tests/acc_f2us10_bench_screen.cob` (US10-2): Open Screen for the bench menu shows the 3x3 grid, result slot and recipe book (12 §5.6b); the bench block and item draw from their texture paths
- [ ] T615 [US10-client] Implement the bench screen in `client/src/screens/bench.cob`
- [ ] T616 [US10-client] Gate: run `make gate-client` and record the command and real output

#### Phase 65: US11-client (b) — biome tint

- [ ] T617 [US11-client] Write test `client/tests/test_biome_tint.cob`: grass, foliage and water tints per biome and colour map (43 and Round TINT) applied by the mesher to tinted faces
- [ ] T618 [US11-client] Implement biome tinting in `client/src/mesher.cob` and the tint tables load in `client/src/models.cob`
- [ ] T619 [US11-client] Gate: run `make gate-client` and record the command and real output

#### Phase 66: US12-client — particles, dimensions, container screens

- [ ] T620 [US12-client] Write test `client/tests/test_particles.cob`: the particle engine of `docs/protocol/42-particles-1-shared-model-engine.md` and the effects, fluid-drip, block/item/dust, sculk and emitter families of parts 2 to 7 from Level Particles and Level Event
- [ ] T621 [US12-client] Implement particles in `client/src/particles.cob`
- [ ] T622 [US12-client] Write acceptance test `client/tests/acc_f2us12_dimension_travel.cob` (US12-3): Respawn/Login for the Nether and the End swaps the replica, the dimension's tints and sky-less look, and a portal overlay screen shows during the change
- [ ] T623 [US12-client] Implement dimension change handling in `client/src/world-replica.cob` and `client/src/screens/connecting.cob` plus a portal overlay in `client/src/screens/portal.cob`
- [ ] T624 [US12-client] Write test `client/tests/test_container_screens.cob`: the container screens of 40 (furnace, brewing, anvil, grindstone, smithing, enchanting, loom, stonecutter, cartography, merchant, beacon, lectern, hopper, dispenser, horse, creative inventory, book and sign editors) lay out their slots per the menu layouts
- [ ] T625 [US12-client] Implement the container screens in `client/src/screens/containers.cob`
- [ ] T626 [US12-client] Gate: run `make gate-client` and record the command and real output

#### Phase 67: US13-client — suggestions and completions

- [ ] T627 [US13-client] Write acceptance test `client/tests/acc_f2us13_suggestions.cob` (US13-1): the received command tree drives Tab completion and the chat suggestions list including the server's Command Suggestions responses (15 §14)
- [ ] T628 [US13-client] Update `client/src/screens/chat.cob` and `client/src/net-client.cob` for the full node tree and suggestion responses
- [ ] T629 [US13-client] Gate: run `make gate-client` and record the command and real output

#### Phase 68: US14-client — durability bars and effects

- [ ] T630 [US14-client] Write test `client/tests/test_item_bars.cob`: the damage bar of a tool at fractions of durability and the effects HUD of Update Mob Effect (17 §1, §5)
- [ ] T631 [US14-client] Implement the bars and effects HUD in `client/src/ui-render.cob` and `client/src/screens/hud.cob`
- [ ] T632 [US14-client] Gate: run `make gate-client` and record the command and real output

#### Phase 69: US15-client — entity models

- [ ] T633 [US15-client] Write test `client/tests/test_entity_models.cob`: model, texture and animation per family from `docs/protocol/34-entity-models-1-shared-model-and-framework.md` with the humanoid, farm animal, wild animal, hostile, nether and end, aquatic and non-living parts as fixtures
- [ ] T634 [US15-client] Implement the entity model engine in `client/src/entity-models.cob` and update `client/src/entities-render.cob`
- [ ] T635 [US15-client] Write test `client/tests/test_default_skin.cob`: the default skin and the player model (`47-default-skin.md`)
- [ ] T636 [US15-client] Implement the player model and default skin in `client/src/player-model.cob`
- [ ] T637 [US15-client] Write test `client/tests/test_entity_replica.cob`: Spawn Entity, Set Entity Data (every serializer) and Update Attributes populate the entity replica
- [ ] T638 [US15-client] Update `client/src/entities-replica.cob` for the full entity packet set
- [ ] T639 [US15-client] Gate: run `make gate-client` and record the command and real output

#### Phase 70: US16-client — Options and `options.txt`

- [ ] T640 [US16-client] Write contract test `client/tests/contract_client_surface.cob`: the documented key to action table (13 §7.3) and the `options.txt` round trip against `contract/fixtures/client/options-*.txt`
- [ ] T641 [US16-client] Write test `client/tests/test_options_file.cob`: read and write of `options.txt` (13 §7.1) for every option; a missing, unreadable, corrupt or out-of-range file yields defaults and the game starts
- [ ] T642 [US16-client] Implement `options.txt` load and save in `client/src/options.cob` and replace `OPTIONS-LOAD` and `OPTIONS-SAVE` in `client/src/game-dir.cob`
- [ ] T643 [US16-client] Write test `client/tests/test_options_migration.cob`: with no `options.txt`, the legacy `options.dat` `EnabledPacks` list is read once and never written again (R8)
- [ ] T644 [US16-client] Implement the read-only migration in `client/src/options.cob`
- [ ] T645 [US16-client] Write acceptance test `client/tests/acc_f2us16_options_screen.cob` (US16-1, US16-2, SC-009): Options opens from the title screen and the pause menu; view distance, sensitivity, FOV, GUI scale and every other option of 13 §7.2 and Round OPT change, apply at once and persist across a restart
- [ ] T646 [US16-client] Implement the Options screens in `client/src/screens/options.cob` and wire the buttons in `client/src/screens/title.cob` and `client/src/screens/pause.cob`
- [ ] T647 [US16-client] Write test `client/tests/test_key_bindings.cob`: the default key table of 13 §7.3 and rebinding persisted in `options.txt`
- [ ] T648 [US16-client] Implement the key table in `client/src/controls.cob`
- [ ] T649 [US16-client] Gate: run `make gate-client` and record the command and real output

#### Phase 71: US17-client — F3 overlay

- [ ] T650 [US17-client] Write acceptance test `client/tests/acc_f2us17_f3.cob` (US17-1, US17-2): F3 shows position, block, chunk, facing, dimension, frame rate and the other entries of 13 §5 from the replica and physics state; F3 again hides it
- [ ] T651 [US17-client] Implement the overlay in `client/src/debug-overlay.cob` and the F3 binding in `client/src/controls.cob`
- [ ] T652 [US17-client] Gate: run `make gate-client` and record the command and real output

#### Phase 72: US18-client — F5 camera

- [ ] T653 [US18-client] Write acceptance test `client/tests/acc_f2us18_f5.cob` (US18-1): repeated F5 cycles first person, behind, in front, first person (13 §6)
- [ ] T654 [US18-client] Write test `client/tests/test_camera_clip.cob` (US18-2): the third-person camera raycasts against blocks and shortens in tight space (12 §7)
- [ ] T655 [US18-client] Implement the camera modes and clipping in `client/src/camera.cob` and `client/src/raycast.cob`
- [ ] T656 [US18-client] Write test `client/tests/test_self_model.cob`: the Player's own model is drawn in third person and not in first person
- [ ] T657 [US18-client] Draw the own player model in `client/src/entities-render.cob`
- [ ] T658 [US18-client] Gate: run `make gate-client` and record the command and real output

#### Phase 73: US19-client — off-hand swap

- [ ] T659 [US19-client] Write acceptance test `client/tests/acc_f2us19_swap.cob` (US19-1 to US19-3): F with no screen sends the swap action; F over a hovered slot in the inventory screen sends a Container Click swap with slot 45; the off-hand slot draws beside the hotbar
- [ ] T660 [US19-client] Implement the F key and the off-hand HUD in `client/src/controls.cob` and `client/src/screens/hud.cob`, and the hovered-slot swap in `client/src/screens/inventory.cob`
- [ ] T661 [US19-client] Gate: run `make gate-client` and record the command and real output

#### Phase 74: US20-client — hand and held item

- [ ] T662 [US20-client] Write acceptance test `client/tests/acc_f2us20_hand.cob` (US20-1, US20-2): in first person the hand is in the render list at the lower right holding the selected item or block as a small 3D model after a depth clear, and breaking, placing or attacking plays the swing (12 §6)
- [ ] T663 [US20-client] Implement the hand pass in `client/src/hand.cob` and its submit order in `client/src/submit.cob` with `cc_vk_clear_depth`
- [ ] T664 [US20-client] Gate: run `make gate-client` and record the command and real output

---

## Phase 75: Convergence (cross-package tests, aggregate gate, manual vanilla run)

**Purpose**: scenarios that need more than one package, run in-process through the client's single-player host and the core TCP host on loopback (`tests/convergence/`), the updates the supersessions force on 001's Convergence tests, and the recorded manual verification of Q-1. No E2E (inventory empty).

- [ ] T665 [US1] Write `tests/convergence/acc_f2us1_start_check.cob` (real jar): extract to `build/generated-test/`, then the client and the server both report packs `ok` and load the packs with no loader error; a tampered manifest is reported `stale` by both
- [ ] T666 [US2] Write `tests/convergence/acc_f2us2_world_type.cob`: create one world of each type through the client host, restart, each reopens as its type and behaves by the shared rules; the standard world with the generated directory removed is refused with the reason
- [ ] T667 [US8] Write `tests/convergence/acc_f2us8_second_player_crack.cob`: two clients on loopback, one holds break, the other sees the stages 0 to 9 and the removal
- [ ] T668 [US9] Write `tests/convergence/acc_f2us9_inventory_craft.cob`: through the inventory screen model place ingredients, take the result, ingredients consumed; recipe book Place Recipe fills the grid
- [ ] T669 [US10] Write `tests/convergence/acc_f2us10_bench.cob`: craft, place and use the bench, make a 3x3 recipe; replaces `tests/convergence/acc_us10_crafting.cob`
- [ ] T670 [US13] Write `tests/convergence/acc_f2us13_commands.cob`: a level-0 and a level-4 client receive different command trees; `/give` runs with completions end to end
- [ ] T671 [US19] Write `tests/convergence/acc_f2us19_swap.cob`: F swap and hovered-slot swap end to end with the Set Slot updates
- [ ] T672 [US12] Write `tests/convergence/acc_f2us12_dimensions.cob`: a portal trip to the Nether and back through the client and server, the replica swapping dimensions
- [ ] T673 [US2] Update the 001 Convergence tests that the supersessions change, one task per file: delete `tests/convergence/acc_us10_crafting.cob`
- [ ] T674 [US2] Update `tests/convergence/acc_us12_dimensions.cob` for three dimensions and the standard timeline
- [ ] T675 [US2] Update `tests/convergence/acc_us4_controls_to_world.cob` for the new controls and the 46-slot menu
- [ ] T676 [US2] Update `tests/convergence/acc_us5_inventory_throw.cob` for the creative throw (CC-0006) and the retired stand-in values
- [ ] T677 [US2] Update `tests/convergence/acc_us16_single_player.cob` and `acc_us17_open.cob` for world types and the `options.txt` file
- [ ] T678 Gate: run `make gate` (lint, build, instrumented coverage over every package and the Convergence tests, `gate-tools`) and record the command and real output
- [ ] T679 Q-1 manual run, once, after the aggregate gate passes (`quickstart.md` §9; the operator's launcher with a 26.3 profile): start `build/bin/cobolcraft-server` with `world-type=standard` and the generated packs, connect the vanilla client offline to `localhost`, confirm configuration completes with no registry, tag or known-packs error and the spawn chunks render, then connect to a cobolcraft-type server and confirm configuration only; write `specs/002-client-polish/vanilla-client-evidence.md` from the real server console lines and the observed client state (SC-013)
- [ ] T680 Review task: re-read the evidence file against `quickstart.md` §9 and confirm every expected outcome is stated with real output

---

## Phase 76: Polish and cross-cutting concerns

- [ ] T681 Delete the 001 chunk codec functions `PB-PUT-CHUNK` and `PB-GET-CHUNK` kept additive in `proto/src/chunk.cob` with their tests in `proto/tests/test_chunk.cob`, after confirming with `grep` that no caller remains in `core`, `client`, `server`, `tests/convergence`
- [ ] T682 Final debt check of the files this feature touched (constitution 5.7, plan "Technical debt survey"): `grep -in "TODO\|FIXME\|HACK\|GCOV_EXCL\|nolint"` over `shim`, `formats`, `proto`, `content`, `extract`, `core`, `server`, `client`, `tools`, `Makefile` returns nothing, and no file the plan named as sprawled (`core/src/commands.cob`, `core/src/persistence.cob`, `client/src/protocol-client.cob`) remains
- [ ] T683 Complete `README.md`: how to build the packs (`cobolcraft-extract`), world types, resource packs and Open Pack Folder, options, controls (F3, F5, F), the test inputs in `tmp/`, no jar or generated file committed
- [ ] T684 Review task: walk `specs/002-client-polish/quickstart.md` sections 0 to 8 against the built binaries and confirm each stated expectation; record deviations as findings
- [ ] T685 Judge CC-0002 (chunk meshing performance) against the measured `acc_us3_streaming` and gate times; keep the ticket open or update it with the figures (Spile skill `.claude/skills/spile/SKILL.md`)
- [ ] T686 Close CC-0003, CC-0005 and CC-0006 (`tickets/`) with the spile skill, citing the tasks that fixed them (weather atlas, free-port server tests, creative throw)
- [ ] T687 Update the feature's own record `tickets/CC-0001-client-polish.md` (status, implementation, resolution) and regenerate `tickets/views/cobolcraft-view.md` with `python3 .claude/skills/spile/scripts/view.py tickets`
- [ ] T688 Update `.claude/skills/cobolcraft-cobol/SKILL.md` with the pitfalls found in this feature (GnuCOBOL by-reference double arithmetic, generated copybook rows, new package Makefiles)
- [ ] T689 Gate: run `make gate` and record the command and real output (terminal aggregate; no E2E)

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (1)**: none. **Foundational (2)**: after Setup; blocks everything. Its docs rounds (2a) precede the lanes so lanes stay independent.
- **Parallel group (3 to 74)**: starts after the Foundational Gate; lanes are mutually independent except the edges listed under the group heading; within a lane phases run in order.
- **Convergence (75)**: after every lane gate. **Polish (76)**: after Convergence.

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
