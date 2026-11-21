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

- [x] T0017 [P] Round OPT, reader: options screen texts, option names, ranges and key labels (`docs/design/builtin-ui-art.md` Open question 13; `docs/protocol/13-client-gameplay-and-controls.md` §7) so US16 can be built from the document
- [x] T0018 Round OPT, reviewer: contamination and completeness review of the OPT documents; every option on the Options screen has name, default, range, persisted key and text
- [x] T0019 [P] Round GUI, reader: built-in GUI art and layout values not yet read in `docs/design/builtin-ui-art.md` (sprite sizes and sheet regions the slices use, tooltip frame, recipe-book tabs and toasts, minimum window size, contrast values)
- [x] T0020 Round GUI, reviewer: contamination and completeness review of the GUI document changes
- [x] T0021 [P] Round TINT, reader: per-biome grass tint values and the 43 tint sources as `docs/design/faithful-pack-mapping.md` and `docs/protocol/43-tint-sources.md` need them
- [x] T0022 Round TINT, reviewer: contamination and completeness review
- [x] T0023 [P] Round SAVE, reader: the save layout question between `docs/protocol/07-nbt-and-anvil.md` and `docs/protocol/33-world-simulation.md` (`docs/design/world-types.md` Open question 12), then transcribe the answer into `docs/protocol/07-nbt-and-anvil.md` §9 as the world-folder contract (three dimension folders, `WorldType`, `Seed`, `ContentJar`, block states by key in palettes, WT-23)
- [x] T0024 Round SAVE, reviewer: contamination and completeness review of `07` §9 against `contracts/core-host-delta.md` §3
- [x] T0025 [P] Round SEED, reader: the seed text to seed rule (`docs/protocol/11-world-generation-caves-and-ores.md` Open question; fixes `CS-SEED-TEXT`) with worked examples
- [x] T0026 Round SEED, reviewer: contamination and completeness review (the worked examples are checked against the artifact)
- [x] T0027 [P] Round SKIN, reader: settle the optional Faithful skin's pack id, title, stack level and toggle placement for the cobolcraft type (`docs/design/faithful-pack-mapping.md` Open question 11, FR-006, `docs/design/README.md` Part 7 decision 10); record the answer in `docs/design/faithful-pack-mapping.md` §9 and one line in `docs/protocol/13-client-gameplay-and-controls.md` §8 (adopted default if the round finds nothing better: off by default, level 2 of the stack, a toggle row on the resource pack screen while a cobolcraft-type world is created or opened)
- [x] T0028 Round SKIN, reviewer: contamination and completeness review; nothing is a guess and the texture ids come from sections 3 and 4 of the document
- [x] T0029 [P] Round SPOPEN, reader: the single-player world opened to others (`docs/design/world-types.md` §10) so the host keeps world type and shared rules
- [x] T0030 Round SPOPEN, reviewer: contamination and completeness review
- [x] T0031 [P] Round TIBE, reader: `TestInstanceBlockEditScreen` (`docs/protocol/40-menus-9-block-editor-screens.md` Open question 1)
- [x] T0032 Round TIBE, reviewer: contamination and completeness review
- [x] T0033 [P] Round PNG, reader: the PNG kinds (colour types, bit depths, interlace, ancillary chunks) the jar and Faithful use, closing `docs/protocol/22-extraction-tool.md` Open question 7
- [x] T0034 Round PNG, reviewer: contamination and completeness review
- [x] T0035 [P] Round LIBM, reader: every `libm` function and rounding rule that documents 10, 11, 15 and 18 call for in bit-exact arithmetic, recorded as a table in `docs/protocol/10-world-generation-terrain.md` (list that fixes the `cc_f64_*` function set of `contracts/shim-delta.md`)
- [x] T0036 Round LIBM, reviewer: contamination and completeness review; the function list covers every arithmetic step in 10, 11, 15 and 18 that is not add, sub, mul, div, floor, sqrt or text conversion
- [x] T0037 [P] Write the design record `docs/design/debug-world.md` (operator addition, plan "Operator addition: debug world"), our own work with no vanilla artifact read or committed: the hidden `debug` world type; a flat grid of every block state from documents 24 and 46 in state-id order, with the cell position as an explicit function of the state id (grid width, spacing, y level, origin), the floor, the spawn point, the dimension (the standard overworld type), light and biome, that nothing ticks and nothing generates, and that the type uses the standard content set
- [x] T0038 Review `docs/design/debug-world.md`: the position of every state is computable from the record alone, the totals equal the counts of 24 §17 and 46, and it names no Mojang artifact content
- [x] T0039 [P] Write `docs/design/world-types.md` §8: the recorded behaviour of a vanilla client against a cobolcraft-type server (passes configuration only, `docs/protocol/04-registry-sync.md` §5; the WT-16 behaviour, no new design) closing Open question 8
- [x] T0040 [P] Write the design records of FR-027 in `docs/design/cobolcraft-standard-core.md`: any cobolcraft-type content the shared rules need beyond `cobolcraft:crafting_bench` (block, item, recipe, texture, tags), each with its values, before the content slice
- [x] T0041 [P] Update `docs/protocol/09-cobolcraft-profile.md` per `contracts/wire-delta.md` §2: a row per packet whose use changes (standard chat types, command tree, permission levels, Player Abilities, 46-slot inventory and crafting menus, recipe book, Block Destruction, Set Held Item, Player Action swap, entity spawn and metadata, three-dimension Login and Respawn, 24-section chunk data), written from `05a`, `05b`, `05c`
- [x] T0042 Review `docs/protocol/09-cobolcraft-profile.md` rows against `contracts/wire-delta.md` §2: every listed packet has a row with a field table and a fixture name
- [x] T0043 [P] Review task (FR-012, US5-2): every cobolcraft block, item and mob has its texture path written in `docs/design/faithful-pack-mapping.md`; write any missing row from `docs/design/standin-content.md` and `cobolcraft-standard-core.md`; an unmapped one is listed as showing the missing-texture look
- [x] T0044 Review task: `docs/design/README.md` Part 8 open items that bear on this feature are each closed by a task above or recorded as out of scope with the spec reason (sounds FR-043, unknown jar Part 7 decision 11, cobolcraft skin FR-006); update the Part 8 status lines

### 2b. Contract materialization (frozen shared surface; lanes read, never write)

- [x] T0045 Write contract test cases in `tools/tests/test_contract_check.py` expecting `tools/contract_check.py` to compile `CONTENT.cpy`, `FORMATS.cpy` and `CELLS.cpy` in the probe program, to parse every new wire fixture, and to fail on a copybook that does not compile
- [x] T0046 Extend `tools/contract_check.py` and the probe under `tools/probe/` so `make gate-contract` compiles the new copybooks and parses `contract/fixtures/wire/*.hex` including the new ones
- [x] T0047 [P] Add to `contract/include/ccshim.h`: `cc_f64_add`, `cc_f64_sub`, `cc_f64_mul`, `cc_f64_div`, `cc_f64_floor`, `cc_f64_sqrt`, `cc_f64_from_text` and the libm wrappers named by Round LIBM (all operands and results by reference, return void), `cc_vk_texture_ex(tex_id, w, h, rgba, mip_levels)`, `cc_vk_texture_update(tex_id, x, y, w, h, rgba)`, `cc_vk_clear_depth(void)`, `cc_open_path(opener, path)` (`contracts/shim-delta.md`)
- [x] T0048 [P] Add to `contract/copy/CCSHIM.cpy` the matching COBOL `CALL` shapes and the key codes `CC-KEY-F` (70), `CC-KEY-F3` (292), `CC-KEY-F5` (294) and every other key code `docs/protocol/13-client-gameplay-and-controls.md` §5.1 and §7.3 name
- [x] T0049 [P] Add to `contract/copy/COREAPI.cpy` the settings `CS-WORLD-TYPE` PIC X(10) (`standard`, `cobolcraft` or the hidden `debug`), `CS-GENERATED-DIR` PIC X(1024), `CS-SEED-TEXT` PIC X(64) (empty means random), `CS-GAME-DIR` PIC X(1024), the new `CORE-WORLD-OPEN` status words (packs not ok, dimensions without level.dat, standard folders without WorldType) and the re-derived `CORE-SETTINGS-SIZE`
- [x] T0050 [P] Add to `contract/copy/PROTO.cpy` the composite records of `contracts/wire-delta.md` §3: item stack with components, entity metadata entries, chunk palette containers, command nodes, recipe book entries
- [x] T0051 [P] Create `contract/copy/CONTENT.cpy` per `contracts/content-api.md` §1: `CT-SET` (type, packs status `ok|absent|incomplete|stale|damaged`, generated directory, registry counts; EXTERNAL), `CT-BLOCK-ROW`, `CT-ITEM-ROW`, `CT-ENTITY-ROW`, `CT-STATIC-ID-ROW`, `CT-REGISTRY`, `CT-ENTRY`, `CT-TAG`, and the status-word constants
- [x] T0052 [P] Create `contract/copy/FORMATS.cpy` per `contracts/formats-api.md`: constants and record shapes (`FMZIP` handle, `FMSHA` context, `FMREGEX`, file and directory status words, `JSON-STRICT` reason codes)
- [x] T0053 [P] Create `contract/copy/CELLS.cpy`: the one cell and chunk layout replacing core `CHUNKMEM.cpy` and client `CLCELLS.cpy` (2-byte block state, 4-bit sky and block light, sections from the dimension's `min_y` and `height`, 3 dimensions, biome containers; `docs/protocol/06-chunk-format.md`, data-model §4); copybook only, adopted by core and client in their lanes
- [x] T0054 [P] Create `contract/copy/JSONDOC.cpy` by moving `client/copy/JSONDOC.cpy` there unchanged (shared by formats, content, client)
- [x] T0055 [P] Create fixtures under `contract/fixtures/formats/`: small hand-made zip (stored and deflated entries, a bad CRC, a zip64 marker, an encrypted entry), strict-JSON accept and reject files (comments, trailing comma, duplicate key), PNG files of every kind Round PNG lists
- [x] T0056 [P] Create fixtures under `contract/fixtures/content/`: a small valid generated directory tree (manifest, sentinels, `vanilla-data` with a handful of registries, tags, recipes and worldgen files), a stale tree (tampered manifest) and a damaged tree (removed sentinel) (`docs/protocol/22-extraction-tool.md` §8.2)
- [x] T0057 [P] Create fixtures under `contract/fixtures/extract/`: hand-made reject archives for 22 §4.2 C1 to C5 and the T-series reject cases of 22 §12 (not a zip, wrong digest, missing entries)
- [x] T0058 [P] Create fixtures under `contract/fixtures/client/`: `options-default.txt`, `options-full.txt`, `options-corrupt.txt`, `options-out-of-range.txt` per `docs/protocol/13-client-gameplay-and-controls.md` §7.1 and a legacy `options.dat`
- [x] T0059 Create `tools/wire_fixtures.py`, the independent Python encoder used for wire fixtures not taken from a document worked example, with a self-test in `tools/tests/test_wire_fixtures.py` written first
- [x] T0060 [P] Create wire fixtures `contract/fixtures/wire/*.hex` for chunk data (24 sections, single-value, indirect and direct palettes, biome containers, 26 light entries; 06 worked examples) and registry data and Update Tags (04 worked examples)
- [x] T0061 [P] Create wire fixtures for Block Destruction, Player Action (start, abort, finish, swap with sequence ids) and Block Update (13 §2.3, §2.4)
- [x] T0062 [P] Create wire fixtures for Container Set Slot, Container Set Content, Container Click, Set Cursor Item, Open Screen with data components, Place Recipe, Recipe Book Add, Remove, Settings and Seen (00, 27, 40)
- [x] T0063 [P] Create wire fixtures for Commands (full node tree with every parser kind), Command Suggestions request and response, Chat Command, Player Chat and Disguised Chat with standard chat types (15, 15a)
- [x] T0064 [P] Create wire fixtures for Spawn Entity, Set Entity Data (every serializer of 46 §12), Entity Event, Update Attributes, Update Mob Effect, Level Event, Level Particles, Login and Respawn for three dimensions (18, 21, 42, 39, 46)
- [x] T0065 Gate: run `make gate-contract` and record the command and real output (all new copybooks compile, all fixtures parse)

### 2c. Table generator and drift gate (R2, R3; `tools/gen/gen_tables.py`)

- [x] T0066 Write acceptance test `tools/tests/acc_f2us2_gen_blocks.py`: generating the block table from `docs/protocol/24-block-registry-1-...` to `-8-...` yields the counts the documents state in their validation sections (24 §17; about 1,200 blocks, 30,000 states) and the worked examples of 24 §16, and the row layout is the 400-character literal rows of data-model §2
- [x] T0067 Implement the block and block-property tables in `tools/gen/gen_tables.py` (rows of data-model §2 "Block", "Block property"; output `content/copy/gen/blocks.cpy` and `blockprops.cpy`) so the previous test passes
- [x] T0068 Write acceptance test `tools/tests/acc_f2us2_gen_items.py` against `docs/protocol/25-item-registry-1-...` to `-8-...` and `25-item-registry-x1-continuation.md` (counts and worked examples; about 1,500 items)
- [x] T0069 Implement the item table (`content/copy/gen/items.cpy`) in `tools/gen/gen_tables.py`
- [x] T0070 Write acceptance test `tools/tests/acc_f2us2_gen_static_ids.py` against `docs/protocol/46-registry-ids.md` (counts of 46 §16, worked examples of 46 §15) for the static registry id table, the entity type table (21 §2, 46 §11) and the list of tag names the code reads (24 part 1 §12)
- [x] T0071 Implement the static registry id, entity type and tag name tables (`content/copy/gen/staticids.cpy`, `entities.cpy`, `tagnames.cpy`) in `tools/gen/gen_tables.py`
- [x] T0072 Write acceptance test `tools/tests/acc_f2us1_gen_jar_row.py`: the accepted-jar row (version id, size, SHA-256, world and protocol versions, pack formats) generated from `docs/protocol/README.md` equals the single recorded row (22 §4.1)
- [x] T0073 Implement the accepted-jar table (`content/copy/gen/acceptedjar.cpy`) in `tools/gen/gen_tables.py`
- [x] T0074 Write acceptance test `tools/tests/acc_f2us2_gen_drift.py`: `--check` fails when a document count changes by one row (loses a block) and when a generated file is edited by hand
- [x] T0075 Run `python3 tools/gen/gen_tables.py --write` and add the generated files under `content/copy/gen/` (data, not hand-edited); `make gate-tables` exits 0
- [x] T0076 Gate: run `make gate-tables && make gate-tools` and record the command and real output

### 2d. Move of the shared readers to `formats` (R1, behaviour-preserving)

- [x] T0077 Move `client/src/json.cob` and `client/tests/test_json.cob` to `formats/src/json.cob` and `formats/tests/test_json.cob`; register them in `formats/Makefile` (`SRC`, `TESTS`) and remove them from `client/Makefile`; no `CALL` changes
- [x] T0078 Move `client/src/zip.cob`, `client/tests/test_zip.cob` and `client/copy/CLZIP.cpy` (renamed `FMZIP.cpy`, in `contract/copy/`) to `formats/`; update the `COPY` statements in every client program
- [x] T0079 Move `client/src/png.cob` and `client/tests/test_png.cob` to `formats/`
- [x] T0080 Move `client/src/regex.cob`, `client/tests/test_regex.cob` and `client/copy/CLREGEX.cpy` (renamed `FMREGEX.cpy`, in `contract/copy/`) to `formats/`; update the `COPY` statements
- [x] T0081 Move `FILE-READ-ALL` from `client/src/packs/source.cob` into `formats/src/files.cob` with a `formats/tests/test_files.cob` covering it; `source.cob` calls it from the library
- [x] T0082 Re-link `client/Makefile` against `build/formats/libformats.a` (`DEPS_client` gains `formats`) and delete the stale client copies
- [x] T0083 Write contract test `formats/tests/contract_formats_provider.cob` for the programs that exist after the move (`JSON-*`, `ZIP-*`, `PNG-DECODE`, `REGEX-*`, `FILE-READ-ALL`) against `contract/fixtures/formats/`
- [x] T0084 Write consumer test `client/tests/contract_formats_consumer.cob` calling the moved programs the way the client does (`contracts/formats-api.md` "Contract tests")
- [x] T0085 Gate: run `make gate-formats` and record the command and real output
- [x] T0086 Gate: run `make gate-client` and record the command and real output (the move must leave the client's tests green; behaviour preserved)

### 2e. Foundational gate

- [x] T0087 Gate: run `make gate-contract && make gate-tools && make gate-formats && make gate-client` and record the command and real output; confirm each document deliverable of 2a has its review task done

**Checkpoint**: contracts frozen, documents closed, generated tables in place, shared readers moved. Lanes may start.

---
