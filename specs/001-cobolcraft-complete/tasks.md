---

description: "Task list for CobolCraft, complete (game client and game server)"
---

# Tasks: CobolCraft, complete (game client and game server)

**Input**: Design documents from `specs/001-cobolcraft-complete/` — [plan.md](plan.md), [spec.md](spec.md),
[research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md);
constitution `.specify/memory/constitution.md` (project v1.2.0, SDD amendment v6.3.0).

**Prerequisites**: plan.md and spec.md (required); research R1 to R16, data-model.md and all eight contracts
are binding inputs. Tasks gate (constitution 1.3): `grep -rn "NEEDS CLARIFICATION" specs/ docs/` found no
marker on 2026-11-05; generation proceeded.

**Tests**: REQUIRED. Constitution 4.1 makes test-first development, acceptance tests for every acceptance
scenario, contract tests for both sides of every seam and 100 % production coverage (4.2) mandatory. Each test
task precedes the implementation task it defines (constitution 5.1 rule 3: test and implementation are separate
tasks). No test doubles exist anywhere (plan "Test strategy"); E2E inventory is empty (research R16), so no
`.feature` files, step definitions or E2E runs are generated.

**Execution mode**: **package-parallel** (plan "Execution mode"; constitution 3.6, 5.2). Shape: Setup →
Foundational (docs-first, contract materialization, shared test infrastructure) → PARALLEL GROUP with lanes
`shim`, `proto`, `core`, `server`, `client` → Convergence → Polish. Workspace bootstrap command: `make bootstrap`.

## Format: `- [ ] [ID] [P?] [Story?] Description`

- **[P]**: can run in parallel with the other [P] tasks next to it (different files, no dependency on an
  incomplete task).
- **[Story]**: `[US1]` in Setup (US1 is realised by Setup, plan "Execution mode"); composite lane tags
  `[US<n>-<package>]` in the parallel group (constitution 5.2: a split story's slices never carry the bare
  tag); bare `[US<n>]` in Convergence; no tag in Foundational and Polish.
- **Gate:** tasks are verification-only (effective size 0, constitution 5.1 rule 1); every other task is one
  independently verifiable change (effective size 1).

## Conventions every task inherits

- COBOL: GnuCOBOL 3.2, free format (`-free`), `-std=default`, `-debug` in every build, comments `*>`; calls to C
  with `CALL STATIC` per research R2; shared shapes only from `contract/copy/*.cpy` (never redefined locally).
- C (shim only): C11, glue only, no game or protocol logic (constitution Principle I; contracts/shim-abi.md).
- Test files: `acc_<story>_<topic>` (acceptance; case names contain `acceptance US<n>-<scenario>` and
  Given/When/Then), `contract_<seam>_<side>` (contract), `test_<unit>` (implementation); one output line per case
  (`TEST <case> PASS` / `TEST <case> FAIL expected=<x> observed=<y>`, contracts/test-harness.md §3), using
  `tools/testlib/`.
- "Implementation test … to 100 % coverage" tasks cover every line of the named production file that the
  acceptance and contract tests of the same phase leave unexecuted (constitution 4.2; `make coverage` lists them).
- Failure handling: only the outcomes of FR-012 and research R14; non-fatal = one `ERROR <what>: <detail>`
  console line and continue; fatal = `CALL STATIC "cc_fatal"`; nothing else (constitution 5.5, 5.6).
- Content values (ids, numbers, names, texts) are never invented in code: they are transcribed from
  `docs/design/standin-content.md` as extended in Phase 2, and protocol facts from `docs/protocol/`.
- A commit is made at every phase boundary after its Gate passes (constitution 5.3).

---

## Phase 1: Setup — User Story 1, build and test (Priority: P1) 🎯 MVP

**Goal**: A Contributor can bootstrap, build, test, lint and measure coverage from the terminal (US1), with the
test infrastructure every later phase uses (plan "Infrastructure setup"; contracts/test-harness.md).

**Independent Test**: `make gate-tools` exits 0; `tools/tests/acc_us1_test_command.py` and
`tools/tests/acc_us1_failing_test.py` pass (US1-2, US1-3). US1-1 (both binaries produced) is verified in
Convergence once the programs exist.

- [ ] T001 [US1] Create `.gitignore` at the repository root ignoring `build/`, `*.gcda`, `*.gcno`, `*.gcov` and `__pycache__/`
- [ ] T002 [P] [US1] Create the COBOL assertion library: copybook `tools/testlib/TESTLIB.cpy` (case name, expected, observed fields) and program `TEST-ASSERT` in `tools/testlib/testassert.cob` that prints exactly `TEST <case> PASS` or `TEST <case> FAIL expected=<x> observed=<y>` for text and numeric comparisons (contracts/test-harness.md §3, research R9)
- [ ] T003 [P] [US1] Create the C assertion header `tools/testlib/testlib.h` printing the same two line forms for integer, byte-buffer and string comparisons (contracts/test-harness.md §3)
- [ ] T004 [P] [US1] Write acceptance test `tools/tests/acc_us1_test_command.py` (stdlib `unittest`): case "acceptance US1-2 given a built checkout when make test runs then both packages' tests run and the output states passed and failed counts" — copies the repository to a scratch directory, adds one passing COBOL test program to `proto/tests/` and one passing C test program to `shim/tests/`, runs `make test`, asserts the final line `passed 2 failed 0` and exit status 0
- [ ] T005 [P] [US1] Write acceptance test `tools/tests/acc_us1_failing_test.py`: case "acceptance US1-3 given a failing test when make test finishes then it names the case with expected and observed and exits unsuccessfully" — scratch copy with one failing case, asserts the `FAIL <case> expected=… observed=…` line, `failed 1` and non-zero exit; second case: a test program that crashes is counted as one failure named after the program
- [ ] T006 [P] [US1] Write implementation test `tools/tests/test_runtests.py` for the runner: line parsing, package selection, a `<test>.stdin` file next to a test source is fed as standard input, a `<test>.expect` file (expected exit status and a stderr substring) turns a fatal-path test program into one case
- [ ] T007 [US1] Implement the test runner `tools/runtests.py` (stdlib Python): for the selected packages build tests through each package Makefile `tests` target, run every test program, parse `TEST` lines, honour `.stdin` and `.expect` sibling files, print every failing case with expected and observed, print `passed <n> failed <m>`, exit 1 if any case failed or any program crashed (research R9; contracts/test-harness.md §1, §3)
- [ ] T008 [P] [US1] Write implementation test `tools/tests/test_coverage.py` with hand-written gcov fixture files: a `#####` line in a production source fails and is listed as `file:line`; lines under `*/tests/**`, `tools/**`, `specs/**` are ignored
- [ ] T009 [US1] Implement `tools/coverage.py`: runs gcov (`llvm-cov gcov`) over every production source (`shim/src/*.c`, `proto/src/*.cob`, `core/src/*.cob`, `core/copy/*.cpy`, `server/src/*.cob`, `client/src/**/*.cob`) of the selected packages after an instrumented test run (`cobc --coverage`, `clang --coverage`), fails listing `file:line` for every never-executed line (research R9; constitution 4.2)
- [ ] T010 [P] [US1] Write implementation test `tools/tests/test_lint.py` with small good and bad COBOL, C, GLSL and Python fixtures under `tools/tests/fixtures/lint/`
- [ ] T011 [US1] Implement `tools/lint.py`: COBOL `cobc -fsyntax-only -free -Wall -Werror` (with `-I contract/copy` and the package copy directory), C `clang -fsyntax-only -std=c11 -Wall -Wextra -Werror`, GLSL `glslangValidator -V` then `spirv-val`, Python `python3 -m py_compile` (research R9, including the recorded `-Wall` over `-Wextra` decision for COBOL)
- [ ] T012 [P] [US1] Write implementation test `tools/tests/test_contract_check.py` with good and bad `.hex` fixtures (comment stripping, two-hex-digit tokens, empty file rejected)
- [ ] T013 [US1] Implement `tools/contract_check.py`: every `contract/fixtures/wire/*.hex` file parses (`#` comments stripped, whitespace-separated two-digit hex tokens, at least one byte) (contracts/proto-api.md §3; used by `make gate-contract`)
- [ ] T014 [P] [US1] Write implementation test `tools/tests/test_bootstrap.py`: with a `PATH` lacking one prerequisite the script names it, prints the `brew install` line and exits 1; with all present it exits 0 and creates the `build/` tree
- [ ] T015 [US1] Implement `tools/bootstrap.sh` (contracts/test-harness.md §1 `make bootstrap`): check every research R1 prerequisite (`cobc` 3.2, `clang`, GLFW ≥ 3.4 via `pkg-config`, Vulkan loader and headers, MoltenVK ICD, `glslangValidator`, `spirv-val`, OpenSSL 3 through `PKG_CONFIG_PATH=$(brew --prefix openssl@3)/lib/pkgconfig`, `python3`, `gcov`), create `build/bin`, `build/shaders`, `build/<pkg>/obj`, `build/<pkg>/tests`, and compile every `shim/shaders/*.vert|*.frag` to `build/shaders/*.spv`; start no shared infrastructure
- [ ] T016 [US1] Create `tools/Makefile` with targets `tests` (runs `tools/tests/test_*.py` and `tools/tests/acc_us1_test_command.py`, `tools/tests/acc_us1_failing_test.py`) and `lint` (tools Python sources)
- [ ] T017 [US1] Create the root `Makefile` with targets `bootstrap`, `build` (default), `test`, `lint`, `coverage`, `gate`, `gate-shim`, `gate-proto`, `gate-core`, `gate-server`, `gate-client`, `gate-tools`, `gate-contract` (runs `tools/contract_check.py`, the contract probe programs once they exist, and lint of `contract/`), `clean`, delegating to package Makefiles and writing only under `build/` (contracts/test-harness.md §1, §2; OpenSSL pin research R1)
- [ ] T018 [P] [US1] Create `shim/Makefile` skeleton: `lib` → `build/shim/libccshim.a` from `SRC` (empty list builds an empty archive), `tests` from `TESTS`, `lint`, `-I contract/include`, `--coverage` when `COVERAGE=1` (contracts/test-harness.md §2)
- [ ] T019 [P] [US1] Create `proto/Makefile` skeleton: `lib` → `build/proto/libproto.a` from COBOL `SRC` (`cobc -c -free -debug -std=default -I contract/copy`), `tests` linking `build/shim/libccshim.a`, `lint`, coverage flag
- [ ] T020 [P] [US1] Create `core/Makefile` skeleton: `lib` → `build/core/libcore.a` (`-I core/copy -I contract/copy`), `tests` linking proto and shim libraries and OpenSSL `libcrypto` (pinned 3.x), `lint`, coverage flag
- [ ] T021 [P] [US1] Create `server/Makefile` skeleton: `bin` → `build/bin/cobolcraft-server` from `SRC` when `server/src/main.cob` exists (linking core, proto, shim, libcob, libcrypto, zlib), `tests`, `lint`, coverage flag
- [ ] T022 [P] [US1] Create `client/Makefile` skeleton: `bin` → `build/bin/cobolcraft` from `SRC` when `client/src/main.cob` exists (linking core, proto, shim, GLFW, Vulkan loader, libcrypto, libssl, zlib), `-I client/copy -I contract/copy`, `tests`, `lint`, coverage flag
- [ ] T023 [US1] Write `README.md` (Contributor documentation): supported platform (FR-011), prerequisites and the one `brew install` line (research R1, quickstart §0), `make bootstrap`, `make`, `make test`, `make lint`, `make coverage`, `make gate`, how to read failing test output, where outputs go
- [ ] T024 [US1] Review `README.md` against US1 scenarios 1 to 3, research R1 and contracts/test-harness.md (verification-only review task, constitution 4.1)
- [ ] T025 Gate: run `make gate-tools` (root `Makefile`) and record the command and its real output; exit status 0 required (constitution 5.4)

**Checkpoint**: US1-2 and US1-3 pass; every later phase has its runner, coverage, lint, bootstrap and Makefiles.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Narrow Foundational (constitution 5.2): (A) docs-first content and protocol additions (FR-005,
FR-015, constitution Principle II; research R8, R12, R13) — document deliverables verified by review tasks;
(B) materialization of the frozen contract surface in `contract/`; (C) one hand-written wire fixture per packet
of contracts/wire-profile.md §3; (D) shared test infrastructure used by more than one lane.

**⚠️ CRITICAL**: No lane phase begins until this phase's Gate passes. Lanes read `contract/` and `docs/`; they
never write them.

### A. Docs first (all content original, `cobolcraft:` namespace, nothing copied from Minecraft or any other game's names, values or lists; textures, models and effects described procedurally like standin-content §1.4 — FR-015)

- [ ] T026 Make every procedural recipe in `docs/design/standin-content.md` §1.4 and §2 pixel-exact (FR-002 "identical on every machine", SC-004): define the exact noise hash (integer formula over x, y and the texture name bytes, and how its value selects each listed colour by percentage), the line rasterisation rule for multi-pixel lines (pry bar) and the triangle fill rule (trowel), so two independent implementations produce identical RGBA
- [ ] T027 Review the §1.4/§2 pixel-exactness edit in `docs/design/standin-content.md` checking that each recipe admits exactly one RGBA output (verification-only)
- [ ] T028 Rewrite `docs/design/standin-content.md` §1.3 so a survival break leaves the block's item on the ground as a `loose_item` (FR-002) and §3 so `cobolcraft:loose_item` is required (remove "Optional" and the first-milestone wording; plan debt survey tier 2)
- [ ] T029 Add section `## 9. Ground items` to `docs/design/standin-content.md`: pickup range, pickup delay after a throw, thrown-item initial motion, gravity and resting rule, despawn time, the "near a player" distance within which the despawn timer runs, whether identical nearby ground items merge (and the merge range if so), exactly-once and partial pickup order (data-model.md §5) (FR-015 ground-item rules)
- [ ] T030 Add section `## 10. Health and death` to `docs/design/standin-content.md`: player maximum health; safe fall height and fall damage formula; damage of each hostile mob attack; attack damage of every item against players and mobs (bare hand included); starvation damage and interval; weather damage if any; recovery rate and the food level it requires; inventory on death (kept, or dropped as ground items); death message per cause and respawn text; and add the `damage_type` entries these causes use to §4.7 (FR-015 health and death rules)
- [ ] T031 Add section `## 11. Hunger and food` to `docs/design/standin-content.md`: maximum food level; exhaustion per tick of time and per walk, run, jump, attack and block break and the exhaustion that removes one food point; eating time; the food items (append them to the §2 item registry with ids, keys, stack sizes and procedural icon recipes), each food value, and how each is obtained (FR-015 hunger rules)
- [ ] T032 Add section `## 12. Mobs` to `docs/design/standin-content.md`: at least one passive and one hostile mob type appended to the §3 entity type table (id, key, width × height, eye height); per type health, movement speed and wander behaviour, and for hostile types notice range, attack reach, attack damage and attack cooldown; spawning per dimension (where, light/time conditions, how many, the exact deterministic pseudo-random rule); yield on defeat; and procedural appearance (box geometry in entity-texture pixels and a texture recipe) (FR-015 mobs)
- [ ] T033 Add section `## 13. Recipes` to `docs/design/standin-content.md`: every recipe (ingredient items and counts, result item and count) in a numbered list whose index is the recipe display id (data-model.md §8), any new items appended to §2 with icon recipes, and for each ingredient how it is obtained in survival (SC-008) (FR-015 recipes)
- [ ] T034 Add section `## 14. Weather` to `docs/design/standin-content.md`: the weather kinds with original names and `cobolcraft:` keys; each kind's fixed (rain level, thunder level) pair for Game Event 7/8 (contracts/wire-profile.md §3.3); dimensions and biomes where each applies; frequency and duration (exact deterministic selection rule); how each is drawn (sky tint and weather geometry, environment texture recipe); gameplay effect of each on players and mobs; and update §4.3 biome `has_precipitation` values to match (FR-015 weather)
- [ ] T035 Add section `## 15. Extra dimensions` to `docs/design/standin-content.md`: at least one dimension besides `cobolcraft:main` with an original level key; its `dimension_type` entry appended to §4.6 (height range, ambient light, sky, `default_clock`); its biome entries appended to §4.3; its exact terrain generator formula and spawn/arrival point; its light policy; whether it has weather; its mob spawning; the means of travel (a block or structure, its item and recipe or source, and whether the trigger is Use Item On or walking into it, contracts/wire-profile.md §3.3); the arrival-point rule on each side; and update §5.1's Login dimension names (FR-015 extra dimensions)
- [ ] T036 Add section `## 16. Command set` to `docs/design/standin-content.md`: for every FR-016 capability an original command name, argument syntax expressed with the command-tree parsers of contracts/wire-profile.md §3.3, who may use it (everyone, operator status, console), its exact effect, its confirmation text and every error text; plus the shared texts for unknown command, not permitted, invalid or missing argument with the help hint, player not online, dimension not found, operator status granted/revoked notices (US14-3 to US14-5, US14 and US15 edge cases)
- [ ] T037 Add section `## 17. System messages` to `docs/design/standin-content.md`: disconnect and refusal texts — banned, not on the allow-list, name in use by the host (US17 edge case), logged in from another location (US2 edge case), server is stopping (US15-2), host closed the world (US17-4), server requires its pack (US18-7) — and the chat line form `<name> message` (§4.4, FR-013)
- [ ] T038 Add section `## 18. Bitmap font` to `docs/design/standin-content.md`: an original 8 × 8 glyph for every ASCII code 32 to 126 as eight hex row bytes each, the glyph advance width rule, and the missing-glyph rule (research R13)
- [ ] T039 Update `docs/design/standin-content.md` §4.2 summary counts, §7 checklist and §8 Open questions for everything the extension changed (close or restate entries touched, e.g. `world_clock`; plan debt survey tier 2)
- [ ] T040 Review the standin-content extension (§1.3, §3, §4.2 to §4.7, §9 to §18) against FR-002, FR-015 and FR-016 item by item, including originality and that SC-008 obtainability holds from the §2 starting inventory (verification-only)
- [ ] T041 Update `docs/protocol/08-resource-packs.md` §8: the font row becomes required (remove the "later"/"minimal" milestone wording); add to §10 the font files `assets/cobolcraft/font/default.json` (one `bitmap` provider) and `assets/cobolcraft/textures/font/ascii.png` built from standin-content §18 (research R13)
- [ ] T042 Extend `docs/protocol/08-resource-packs.md` §10.3 to §10.7 with every texture, model, block state file and item definition the extension adds: new block textures and models (travel block), item icons (food, recipe items), entity textures `textures/entity/operator.png` and `textures/entity/<mob>.png`, environment textures `textures/environment/<weather kind>.png`, and update §10.9 file count
- [ ] T043 Add a section to `docs/protocol/08-resource-packs.md` §10 describing how the client draws entities in our namespace: the box geometry of each entity type from standin-content §3/§12, the entity-texture UV layout per box face, ground items as billboards of the item icon, and weather geometry with environment textures (research R13, handoff item 10)
- [ ] T044 Extend `docs/protocol/08-resource-packs.md` §10.8 with `en_us` lang keys for every new item, mob, weather kind and dimension name, every client screen label and HUD text named in data-model.md §13, and every message of standin-content §10, §16 and §17 the client shows
- [ ] T045 Answer `docs/protocol/08-resource-packs.md` Open question 4 with CobolCraft's own element rotation rule (composition order and handedness of `x`/`y`/`z` element rotation) that the renderer implements (research R13)
- [ ] T046 Answer `docs/protocol/08-resource-packs.md` Open question 6 with CobolCraft's own default face UV formula derived from element bounds (research R13)
- [ ] T047 Review all `docs/protocol/08-resource-packs.md` changes against FR-003, SC-004, SC-005 and US18-3 (verification-only)
- [ ] T048 Add section `## 9. CobolCraft world folder` to `docs/protocol/07-nbt-and-anvil.md`, transcribing contracts/world-folder.md §1 to §5 (layout, `level.dat`, `access.dat`, `players/<uuid>.dat`, entity storage, chunk storage values, behaviour) (FR-004, FR-014, research R8); in the behaviour paragraph state that a save also writes the file of every player who left since the previous save (contracts/world-folder.md §5 names only online players, but the US13 independent test requires a player who left before the stop to find their state) and that `GameMode` applies to new players when the world is hosted as single-player (core-host-api `CS-HOST-KIND` 1 or 2)
- [ ] T049 Review `docs/protocol/07-nbt-and-anvil.md` §9 against contracts/world-folder.md and FR-014 (verification-only)
- [ ] T050 Create `docs/protocol/09-cobolcraft-profile.md` transcribing contracts/wire-profile.md §1 to §4 with every content reference resolved to the extended standin-content (concrete weather pairs, mob type ids, travel trigger, Player Action status numbers from 05c) (FR-001, FR-005, research R12)
- [ ] T051 Add `09-cobolcraft-profile.md` and the new 07 §9 to the index in `docs/protocol/README.md`
- [ ] T052 Review `docs/protocol/09-cobolcraft-profile.md` against 02, 03, 04, 05a, 05b, 05c and contracts/wire-profile.md (verification-only)

### B. Contract materialization (constitution 3.3; produced from the contract documents, never edited by lanes)

- [ ] T053 [P] Create `contract/include/ccshim.h`: every prototype, outcome constant (`CC_AGAIN` 1, `CC_ADDR_IN_USE` 2, `CC_UNRESOLVED` 3, `CC_CLOSED` 4, `CC_SMALL` 5, `CC_BADDATA` 6, `CC_NOTFOUND` 7), zlib modes, pipeline ids, texture ids and the 24-byte event record of contracts/shim-abi.md §1 to §9
- [ ] T054 [P] Create `contract/copy/CCSHIM.cpy`: the same constants as COBOL level-78 items, the 24-byte event record layout, the 28-byte vertex layout, and named GLFW key-code constants for every key of contracts/client-surface.md §3 (contracts/shim-abi.md §8)
- [ ] T055 [P] Create `contract/copy/PROTO.cpy`: `PB-BUFFER` and the value records of contracts/proto-api.md §1 and §2, including the item-stack, text, entity-metadata entry, recipe-display/slot-display (plan: proto US10 slice) and command-node (plan: proto US14 slice) records
- [ ] T056 [P] Create `contract/copy/COREAPI.cpy`: `CORE-SETTINGS`, `CORE-BUFFER`, `CORE-STATUS` and the connection-kind constants exactly as contracts/core-host-api.md §1
- [ ] T057 Create contract probe programs `tools/probe/probe_contract.c` (includes `ccshim.h`, asserts `sizeof` of the event record is 24) and `tools/probe/probe_contract.cob` (copies `CCSHIM.cpy`, `PROTO.cpy`, `COREAPI.cpy`, asserts `FUNCTION LENGTH` of each record), compiled and run by `make gate-contract`

### C. Wire fixtures (`contract/fixtures/wire/`, format contracts/proto-api.md §3: one packet body per file, packet id first, `#` comment naming each field, written by hand from `docs/protocol/` and `docs/protocol/09-cobolcraft-profile.md`, never from our encoder)

- [ ] T058 [P] Write `contract/fixtures/wire/frame-uncompressed.hex` (01 §2 frame of a short packet, no compression)
- [ ] T059 [P] Write `contract/fixtures/wire/frame-compressed.hex` (01 §3 frame of a body of at least 256 bytes, zlib-wrapped, threshold 256)
- [ ] T060 [P] Write `contract/fixtures/wire/frame-below-threshold.hex` (01 §3 compressed-mode frame of a short body, data length 0)
- [ ] T061 [P] Write `contract/fixtures/wire/handshake-c2s-00-intention-{status,login,other-protocol}.hex` (02 Intention variants: protocol 777 status, protocol 777 login, a different protocol)
- [ ] T062 [P] Write `contract/fixtures/wire/status-c2s-00-status-request.hex` (02)
- [ ] T063 [P] Write `contract/fixtures/wire/status-c2s-01-ping-request.hex` (02)
- [ ] T064 [P] Write `contract/fixtures/wire/status-s2c-00-status-response.hex` (JSON per contracts/wire-profile.md §2: version name `CobolCraft`, protocol 777, max 20, online 0, description `A CobolCraft server`, no favicon)
- [ ] T065 [P] Write `contract/fixtures/wire/status-s2c-01-pong-response.hex` (02)
- [ ] T066 [P] Write `contract/fixtures/wire/login-c2s-00-hello.hex` (name `Alice` and her offline UUID, 02)
- [ ] T067 [P] Write `contract/fixtures/wire/login-c2s-03-login-acknowledged.hex` (02)
- [ ] T068 [P] Write `contract/fixtures/wire/login-s2c-03-set-compression.hex` (threshold 256, contracts/wire-profile.md §2)
- [ ] T069 [P] Write `contract/fixtures/wire/login-s2c-02-login-finished.hex` (offline UUID of `Alice` per 02 Offline mode, no properties)
- [ ] T070 [P] Write `contract/fixtures/wire/login-s2c-00-login-disconnect-{banned,not-allow-listed,name-in-use,protocol-mismatch}.hex` (texts from standin-content §17 and 02)
- [ ] T071 [P] Write `contract/fixtures/wire/config-s2c-01-custom-payload-brand.hex` (`minecraft:brand` = `cobolcraft`)
- [ ] T072 [P] Write `contract/fixtures/wire/config-c2s-02-custom-payload-brand.hex` (`minecraft:brand` = `cobolcraft`)
- [ ] T073 [P] Write `contract/fixtures/wire/config-s2c-0d-update-enabled-features.hex` (`minecraft:vanilla` only, standin-content §4.1)
- [ ] T074 [P] Write `contract/fixtures/wire/config-s2c-0f-select-known-packs.hex` (empty list)
- [ ] T075 [P] Write `contract/fixtures/wire/config-c2s-07-select-known-packs.hex` (empty list)
- [ ] T076 [P] Write `contract/fixtures/wire/config-s2c-07-registry-data-<registry>.hex` (the 13 MV registries of standin-content §4.5, one file each with its single `cobolcraft:placeholder` entry; uniform layout, constitution 5.1 rule 2)
- [ ] T077 [P] Write `contract/fixtures/wire/config-s2c-07-registry-data-worldgen-biome.hex` (every biome of the extended §4.3)
- [ ] T078 [P] Write `contract/fixtures/wire/config-s2c-07-registry-data-chat-type.hex` (§4.4)
- [ ] T079 [P] Write `contract/fixtures/wire/config-s2c-07-registry-data-dimension-type.hex` (every entry of the extended §4.6)
- [ ] T080 [P] Write `contract/fixtures/wire/config-s2c-07-registry-data-damage-type.hex` (the 25 compat keys and every NJ entry of the extended §4.7)
- [ ] T081 [P] Write `contract/fixtures/wire/config-s2c-07-registry-data-world-clock.hex` (§4.8)
- [ ] T082 [P] Write `contract/fixtures/wire/config-s2c-0e-update-tags.hex` (zero registries, standin-content §6)
- [ ] T083 [P] Write `contract/fixtures/wire/config-s2c-09-resource-pack-push-{optional,required-prompt}.hex` (03, 08 §9)
- [ ] T084 [P] Write `contract/fixtures/wire/config-c2s-06-resource-pack-response-{0,1,2,3,4,5,6,7}.hex` (one per action of 03's response table)
- [ ] T085 [P] Write `contract/fixtures/wire/config-s2c-03-finish-configuration.hex` (03)
- [ ] T086 [P] Write `contract/fixtures/wire/config-c2s-03-finish-configuration.hex` (03)
- [ ] T087 [P] Write `contract/fixtures/wire/config-s2c-04-keep-alive.hex` (03)
- [ ] T088 [P] Write `contract/fixtures/wire/config-c2s-04-keep-alive.hex` (03)
- [ ] T089 [P] Write `contract/fixtures/wire/config-c2s-00-client-information.hex` (03)
- [ ] T090 [P] Write `contract/fixtures/wire/config-s2c-02-disconnect-pack-required.hex` (standin-content §17 text, 08 §9.7)
- [ ] T091 [P] Write `contract/fixtures/wire/play-s2c-32-login.hex` (dimension names of every enabled dimension, `cobolcraft:main` spawn info, view and simulation distance 8, show death screen true, limited crafting false, enforces secure chat false; contracts/wire-profile.md §3.2)
- [ ] T092 [P] Write `contract/fixtures/wire/play-s2c-27-game-event-{13-wait-chunks,03-game-mode,01-start-raining,02-stop-raining,07-rain-level,08-thunder-level}.hex` (05a 0x27)
- [ ] T093 [P] Write `contract/fixtures/wire/play-s2c-60-set-chunk-cache-center.hex` (05b)
- [ ] T094 [P] Write `contract/fixtures/wire/play-s2c-0c-chunk-batch-start.hex` (05a)
- [ ] T095 [P] Write `contract/fixtures/wire/play-s2c-0b-chunk-batch-finished.hex` (05a)
- [ ] T096 [P] Write `contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex` (the full payload of generated chunk (0, 0) of `cobolcraft:main`: standin-content §5.2 terrain, marker pillar, biomes, heightmaps and light, computed by hand from 06 and §5.2)
- [ ] T097 [P] Write `contract/fixtures/wire/play-s2c-26-forget-level-chunk.hex` (05a)
- [ ] T098 [P] Write `contract/fixtures/wire/play-s2c-31-light-update.hex` (light of the spawn chunk after its marker glowtube is toggled off)
- [ ] T099 [P] Write `contract/fixtures/wire/play-s2c-49-player-position.hex` (spawn feet 4.5, 54.0, 8.5 facing east, standin-content §5.2)
- [ ] T100 [P] Write `contract/fixtures/wire/play-s2c-41-player-abilities-{creative,survival}.hex` (05a)
- [ ] T101 [P] Write `contract/fixtures/wire/play-s2c-63-set-default-spawn-position.hex` (05b)
- [ ] T102 [P] Write `contract/fixtures/wire/play-s2c-73-set-time.hex` (`cobolcraft:daylight` clock, 05b)
- [ ] T103 [P] Write `contract/fixtures/wire/play-s2c-6b-set-held-slot.hex` (05b)
- [ ] T104 [P] Write `contract/fixtures/wire/play-s2c-6e-set-player-inventory.hex` (05b)
- [ ] T105 [P] Write `contract/fixtures/wire/play-s2c-12-container-set-content-{empty,starting-items}.hex` (36 slots; standin-content §2 starting inventory)
- [ ] T106 [P] Write `contract/fixtures/wire/play-s2c-14-container-set-slot.hex` (05a)
- [ ] T107 [P] Write `contract/fixtures/wire/play-s2c-08-block-update.hex` (05a)
- [ ] T108 [P] Write `contract/fixtures/wire/play-s2c-56-section-blocks-update.hex` (05b)
- [ ] T109 [P] Write `contract/fixtures/wire/play-s2c-04-block-changed-ack.hex` (05a)
- [ ] T110 [P] Write `contract/fixtures/wire/play-s2c-05-block-destruction.hex` (05a)
- [ ] T111 [P] Write `contract/fixtures/wire/play-s2c-47-player-info-update.hex` (05a)
- [ ] T112 [P] Write `contract/fixtures/wire/play-s2c-46-player-info-remove.hex` (05a)
- [ ] T113 [P] Write `contract/fixtures/wire/play-s2c-01-add-entity-{operator,loose-item,<each mob key>}.hex` (entity type ids from the extended standin-content §3)
- [ ] T114 [P] Write `contract/fixtures/wire/play-s2c-36-move-entity-pos.hex` (05a)
- [ ] T115 [P] Write `contract/fixtures/wire/play-s2c-37-move-entity-pos-rot.hex` (05a)
- [ ] T116 [P] Write `contract/fixtures/wire/play-s2c-39-move-entity-rot.hex` (05a)
- [ ] T117 [P] Write `contract/fixtures/wire/play-s2c-55-rotate-head.hex` (05b)
- [ ] T118 [P] Write `contract/fixtures/wire/play-s2c-80-teleport-entity.hex` (05b)
- [ ] T119 [P] Write `contract/fixtures/wire/play-s2c-4e-remove-entities.hex` (05b)
- [ ] T120 [P] Write `contract/fixtures/wire/play-s2c-7c-system-chat-{chat,command-feedback}.hex` (05b)
- [ ] T121 [P] Write `contract/fixtures/wire/play-s2c-20-disconnect-{stopping,host-closed,duplicate-login,kicked}.hex` (standin-content §16, §17 texts)
- [ ] T122 [P] Write `contract/fixtures/wire/play-s2c-2d-keep-alive.hex` (05a)
- [ ] T123 [P] Write `contract/fixtures/wire/play-s2c-65-set-entity-data-item.hex` (loose_item item-stack metadata entry, 00 §12)
- [ ] T124 [P] Write `contract/fixtures/wire/play-s2c-67-set-entity-motion.hex` (05b)
- [ ] T125 [P] Write `contract/fixtures/wire/play-s2c-7f-take-item-entity.hex` (05b)
- [ ] T126 [P] Write `contract/fixtures/wire/play-s2c-6a-set-health.hex` (health, food, saturation 0)
- [ ] T127 [P] Write `contract/fixtures/wire/play-s2c-19-damage-event.hex` (05a)
- [ ] T128 [P] Write `contract/fixtures/wire/play-s2c-2b-hurt-animation.hex` (05a)
- [ ] T129 [P] Write `contract/fixtures/wire/play-s2c-45-player-combat-kill.hex` (death message text)
- [ ] T130 [P] Write `contract/fixtures/wire/play-s2c-54-respawn-{main,<each extra dimension>}.hex` (data to keep 0x03 for travel, 05b)
- [ ] T131 [P] Write `contract/fixtures/wire/play-s2c-22-entity-event-eating-finished.hex` (05a)
- [ ] T132 [P] Write `contract/fixtures/wire/play-s2c-4b-recipe-book-add.hex` (every recipe of standin-content §13, replace = true, one craftable flag set)
- [ ] T133 [P] Write `contract/fixtures/wire/play-s2c-10-commands-{everyone,operator}.hex` (command trees of standin-content §16 per permission level; parsers 2, 3, 5, 7 and `minecraft:ask_server` suggestions)
- [ ] T134 [P] Write `contract/fixtures/wire/play-s2c-0f-command-suggestions.hex` (05a)
- [ ] T135 [P] Write `contract/fixtures/wire/play-s2c-52-resource-pack-push.hex` (05b)
- [ ] T136 [P] Write `contract/fixtures/wire/play-c2s-00-accept-teleportation.hex` (05c)
- [ ] T137 [P] Write `contract/fixtures/wire/play-c2s-0b-chunk-batch-received.hex` (05c)
- [ ] T138 [P] Write `contract/fixtures/wire/play-c2s-2c-player-loaded.hex` (05c)
- [ ] T139 [P] Write `contract/fixtures/wire/play-c2s-0d-client-tick-end.hex` (05c)
- [ ] T140 [P] Write `contract/fixtures/wire/play-c2s-1c-keep-alive.hex` (05c)
- [ ] T141 [P] Write `contract/fixtures/wire/play-c2s-1e-move-player-pos.hex` (05c)
- [ ] T142 [P] Write `contract/fixtures/wire/play-c2s-1f-move-player-pos-rot.hex` (05c)
- [ ] T143 [P] Write `contract/fixtures/wire/play-c2s-20-move-player-rot.hex` (05c)
- [ ] T144 [P] Write `contract/fixtures/wire/play-c2s-21-move-player-status-only.hex` (05c)
- [ ] T145 [P] Write `contract/fixtures/wire/play-c2s-28-player-abilities.hex` (flying flag, 05c)
- [ ] T146 [P] Write `contract/fixtures/wire/play-c2s-29-player-action-{start-destroy,abort-destroy,stop-destroy,drop-all-items,drop-item,release-use-item}.hex` (status values from 05c 0x29)
- [ ] T147 [P] Write `contract/fixtures/wire/play-c2s-42-use-item-on.hex` (05c)
- [ ] T148 [P] Write `contract/fixtures/wire/play-c2s-43-use-item.hex` (05c)
- [ ] T149 [P] Write `contract/fixtures/wire/play-c2s-36-set-carried-item.hex` (05c)
- [ ] T150 [P] Write `contract/fixtures/wire/play-c2s-12-container-click.hex` (05c)
- [ ] T151 [P] Write `contract/fixtures/wire/play-c2s-39-set-creative-mode-slot.hex` (05c)
- [ ] T152 [P] Write `contract/fixtures/wire/play-c2s-09-chat.hex` (no signature, contracts/wire-profile.md §1)
- [ ] T153 [P] Write `contract/fixtures/wire/play-c2s-07-chat-command.hex` (unsigned form, 05c)
- [ ] T154 [P] Write `contract/fixtures/wire/play-c2s-01-attack.hex` (05c)
- [ ] T155 [P] Write `contract/fixtures/wire/play-c2s-0c-client-command-respawn.hex` (action 0, 05c)
- [ ] T156 [P] Write `contract/fixtures/wire/play-c2s-27-place-recipe.hex` (container 0, display id 0, use max items false)
- [ ] T157 [P] Write `contract/fixtures/wire/play-c2s-0f-command-suggestion.hex` (05c)
- [ ] T158 [P] Write `contract/fixtures/wire/play-c2s-32-resource-pack-response.hex` (05c)
- [ ] T159 Review every fixture in `contract/fixtures/wire/` against `docs/protocol/09-cobolcraft-profile.md` §3 so each row of the packet inventory has its fixture and each field comment matches the doc (verification-only)

### D. Shared test infrastructure (used by more than one lane; excluded from coverage)

- [ ] T160 [P] Create `tools/testsrv/make-ca.sh` generating a throwaway test CA and a `localhost`/`127.0.0.1` server certificate under `build/testsrv/` with the `openssl` CLI (research R9)
- [ ] T161 [P] Create `tools/testsrv/testsrv.py` (stdlib): loopback HTTP and HTTPS server serving a given directory on given ports, with options to answer a status code, chunked transfer encoding or an oversize body, used by the shim TLS tests and the client download tests through `SSL_CERT_FILE` (research R9, R10)
- [ ] T162 Create `tools/fixtures/textures/gen_textures.py`: an independent stdlib-Python implementation of every procedural recipe of the extended standin-content (§1.4, §2, §11 to §15 icons and textures, §18 font atlas) writing `tools/fixtures/textures/<name>.rgba`; add its target to `tools/Makefile` so `make bootstrap` regenerates them (research R9)
- [ ] T163 Gate: run `make gate-contract gate-tools` (root `Makefile`) and record the command and its real output; exit status 0 required

**Checkpoint**: docs extended and reviewed; `contract/` complete and frozen; lanes may start.

---
## PARALLEL GROUP — lanes shim, proto, core, server, client

Lanes run concurrently; phases inside a lane run in order (spec story order, constitution 2.5). Each lane
writes only under its own package directory (`shim/`, `proto/`, `core/`, `server/`, `client/`); no lane writes
`contract/`, `docs/`, `tools/`, the root `Makefile` or `tests/convergence/` (disjointness, constitution 5.2).
Each lane phase ends with its package gate (`make gate-<pkg>`); the aggregate `make gate` is used only by
Convergence and Polish.

**Link order between lanes** (plan "Structure decision": `proto` → `shim`; `core` → `proto`, `shim`; `server`,
`client` → `core`, `proto`, `shim`). Writing code and tests never waits on another lane, but a lane phase's
**Gate** links sibling libraries, so it may be run only after every package it links has passed its own phase
for the same or an earlier story: a `proto` USn gate after `shim` US2; a `core` USn gate after `proto`'s latest
phase ≤ USn and `shim`'s latest phase ≤ USn; a `server` or `client` USn gate after `core` USn (when that phase
exists), `proto` and `shim` likewise. Executed strictly sequentially, the order below already satisfies this
when lanes are taken shim → proto → core → server → client.

### Lane: shim

#### Phase 3: US2-shim — glue for the game window, Vulkan submission, sockets, compression and fatal exit

**Goal**: every `shim-abi.md` function needed to join a server, except `cc_con` (US15), `cc_fs` (US16),
`cc_net_local_addresses` (US17) and `cc_tls` (US18) (plan lane notes).

**Independent Test**: `make gate-shim` — `shim/tests/contract_shim_provider.c` passes against the real
libraries (loopback sockets, hidden GLFW window, MoltenVK), 100 % line coverage of `shim/src`.

- [ ] T164 [P] [US2-shim] Write `contract_shim_provider.c` cases for `cc_fatal` as a fatal-path test program `shim/tests/contract_shim_fatal.c` with `shim/tests/contract_shim_fatal.expect` (exit status 1, stderr `FATAL probe: detail`) (shim-abi §1, §2)
- [ ] T165 [US2-shim] Implement `cc_fatal` in `shim/src/cc_fatal.c` (write `FATAL <what>: <detail>` to standard error, exit 1) and add it to `SRC` in `shim/Makefile`
- [ ] T166 [P] [US2-shim] Write cases in `shim/tests/contract_shim_provider.c` for `cc_net_listen` (port 0 returns actual port; second listen on the same port returns `CC_ADDR_IN_USE`), `cc_net_accept` (`CC_AGAIN` with no pending client), `cc_net_connect` (`CC_UNRESOLVED` for an unresolvable host), `cc_net_status`, `cc_net_send`, `cc_net_recv` (`CC_AGAIN`, data, `CC_CLOSED` after peer close), `cc_net_close` and `cc_net_poll` readiness over loopback (shim-abi §3)
- [ ] T167 [US2-shim] Implement `cc_net_listen`, `cc_net_accept`, `cc_net_connect`, `cc_net_status`, `cc_net_send`, `cc_net_recv`, `cc_net_close` and `cc_net_poll` (handles only; `include_console` is added in US15) in `shim/src/cc_net.c`: non-blocking sockets, `TCP_NODELAY`, outcome mapping exactly as shim-abi §3, every other failure through `cc_fatal`
- [ ] T168 [P] [US2-shim] Write cases in `shim/tests/contract_shim_provider.c` for `cc_deflate`/`cc_inflate` in modes `CC_ZLIB` (header `789c`), `CC_GZIP` (magic `1f8b`), `CC_RAW` round trips, `CC_SMALL` on a short output buffer, `CC_BADDATA` on corrupt input (shim-abi §5)
- [ ] T169 [US2-shim] Implement `cc_deflate` and `cc_inflate` (level 6, three wrapper modes) in `shim/src/cc_zlib.c`
- [ ] T170 [P] [US2-shim] Write cases in `shim/tests/contract_shim_provider.c` for `cc_win_open` (hidden window), `cc_win_size` (framebuffer ≥ window size), `cc_win_capture_cursor`, `cc_win_poll` (returns 0 events or well-formed 24-byte records) and `cc_win_close` (shim-abi §8)
- [ ] T171 [US2-shim] Implement `shim/src/cc_win.c`: `glfwInitVulkanLoader(vkGetInstanceProcAddr)` before `glfwInit` (research R3), no-client-API window, GLFW key, character, mouse button, cursor (position or accumulated delta when captured), scroll, resize and close callbacks queued as the 24-byte event records of shim-abi §8, `cc_win_poll`, `cc_win_size`, `cc_win_capture_cursor`, `cc_win_close`
- [ ] T172 [P] [US2-shim] Write implementation test `shim/tests/test_cc_win_events.c` that injects events through the registered GLFW callbacks and asserts each record kind 1 to 9 of shim-abi §8, including a non-ASCII code point for kind 3
- [ ] T173 [P] [US2-shim] Write the world shaders `shim/shaders/world.vert` and `shim/shaders/world.frag` (vertex x, y, z, u, v, brightness, alpha; mat4 push constant; NEAREST-sampled atlas; output = texel × brightness, alpha × multiplier) (research R4)
- [ ] T174 [P] [US2-shim] Write the UI shaders `shim/shaders/ui.vert` and `shim/shaders/ui.frag` (same vertex layout, orthographic matrix, no depth)
- [ ] T175 [US2-shim] Add to `shim/Makefile` the generation of `build/shim/gen/spirv.h` (byte arrays of the four `build/shaders/*.spv`, generated code excluded from coverage) and shader lint
- [ ] T176 [P] [US2-shim] Write cases in `shim/tests/contract_shim_provider.c` for `cc_vk_init` on a hidden window, `cc_vk_texture` for ids 0 to 3, `cc_vk_mesh` create, replace and free, `cc_vk_frame_begin`/`cc_vk_draw`/`cc_vk_frame_end` for each of the three pipelines, and `cc_vk_shutdown` (shim-abi §9)
- [ ] T177 [US2-shim] Implement `cc_vk_init` in `shim/src/cc_vk.c`: instance with `VK_KHR_portability_enumeration` and the portability flag, surface on the `cc_win` window, device with `VK_KHR_swapchain` and `VK_KHR_portability_subset` when reported, API 1.2, FIFO swapchain on the first surface format at framebuffer extent, `D32_SFLOAT` depth, pipelines opaque, translucent and UI from `spirv.h` (research R3, R4)
- [ ] T178 [US2-shim] Implement `cc_vk_texture` (RGBA8, NEAREST, clamp-to-edge, texture ids 0 to 3) in `shim/src/cc_vk.c`
- [ ] T179 [US2-shim] Implement `cc_vk_mesh` (create, replace, free vertex buffer slots 1 to 65535, 28-byte vertices) in `shim/src/cc_vk.c`
- [ ] T180 [US2-shim] Implement `cc_vk_frame_begin` (acquire, swapchain recreation after resize, `CC_AGAIN` when minimised), `cc_vk_draw` (push-constant matrix, column-major) and `cc_vk_frame_end` (submit, FIFO present) in `shim/src/cc_vk.c`
- [ ] T181 [US2-shim] Implement `cc_vk_shutdown` (wait idle, destroy everything) in `shim/src/cc_vk.c`
- [ ] T182 [P] [US2-shim] Write implementation test `shim/tests/test_cc_vk_pixels.c`: draws one textured quad with each pipeline into a hidden window, reads back the image and asserts the centre texel colour and the clear colour (as `spikes/spike_pipeline.c` did)
- [ ] T183 [US2-shim] Write implementation tests `shim/tests/test_cc_net.c`, `shim/tests/test_cc_zlib.c` and `shim/tests/test_cc_vk_resize.c` covering every line of `shim/src` the contract tests leave unexecuted (partial sends, swapchain recreation, `CC_SMALL` retries), and add every test program to `TESTS` in `shim/Makefile`
- [ ] T184 Gate: run `make gate-shim` (root `Makefile`) and record the command and its real output (lint incl. GLSL, build, tests, 100 % coverage of `shim/src`)

#### Phase 4: US15-shim — console input

**Goal**: non-blocking console lines for the server console (US15). **Independent Test**: `make gate-shim`.

- [ ] T185 [P] [US15-shim] Write cases in `shim/tests/contract_shim_provider.c` for `cc_net_poll` with `include_console` = 1 setting `ready_out[count]`, and a test program `shim/tests/contract_shim_console.c` with `shim/tests/contract_shim_console.stdin` (two lines, then end of input) asserting `cc_con_readline` returns each line without newline, then `CC_CLOSED` (shim-abi §3, §4)
- [ ] T186 [US15-shim] Add console readiness (`include_console`) to `cc_net_poll` in `shim/src/cc_net.c`
- [ ] T187 [US15-shim] Implement `cc_con_readline` (non-blocking read of standard input, line assembly across partial reads, `CC_AGAIN`, `CC_CLOSED`) in `shim/src/cc_con.c` and add it to `shim/Makefile`
- [ ] T188 [US15-shim] Write implementation test `shim/tests/test_cc_con.c` (partial line across reads, line longer than one read) to 100 % coverage of `shim/src/cc_con.c`
- [ ] T189 Gate: run `make gate-shim` and record the command and its real output

#### Phase 5: US16-shim — directory listing

**Goal**: `cc_fs_list` for the single-player world list and pack folders. **Independent Test**: `make gate-shim`.

- [ ] T190 [P] [US16-shim] Write cases in `shim/tests/contract_shim_provider.c` for `cc_fs_list`: files and directories as `F<name>\n`/`D<name>\n`, `.` and `..` excluded, byte-order sorting, `CC_SMALL`, `CC_NOTFOUND` (shim-abi §7)
- [ ] T191 [US16-shim] Implement `cc_fs_list` in `shim/src/cc_fs.c` and add it to `shim/Makefile`
- [ ] T192 Gate: run `make gate-shim` and record the command and its real output

#### Phase 6: US17-shim — local network addresses

**Goal**: the addresses a host shows when opening a world (US17-1). **Independent Test**: `make gate-shim`.

- [ ] T193 [P] [US17-shim] Write cases in `shim/tests/contract_shim_provider.c` for `cc_net_local_addresses`: returns the count, every entry is a dotted IPv4 string, `127.0.0.1` is never listed (shim-abi §3)
- [ ] T194 [US17-shim] Implement `cc_net_local_addresses` (`getifaddrs`, non-loopback IPv4, `\n`-separated) in `shim/src/cc_net.c`
- [ ] T195 Gate: run `make gate-shim` and record the command and its real output

#### Phase 7: US18-shim — TLS

**Goal**: HTTPS transport for server pack downloads (research R10). **Independent Test**: `make gate-shim` with
`tools/testsrv/testsrv.py` serving HTTPS and `SSL_CERT_FILE` pointing at the test CA.

- [ ] T196 [P] [US18-shim] Write cases in `shim/tests/contract_shim_provider.c` for `cc_tls_connect`, `cc_tls_status` (ready with the test CA; `CC_CLOSED` with `SSL_CERT_FILE=/dev/null` and on host-name mismatch), `cc_tls_send`, `cc_tls_recv`, `cc_tls_close`, `cc_net_poll` accepting TLS handles, and `CC_UNRESOLVED` (shim-abi §6)
- [ ] T197 [US18-shim] Implement `shim/src/cc_tls.c` (OpenSSL 3 pinned; default verify paths, TLS 1.2 minimum, SNI and host-name verification, non-blocking handshake via `SSL_get_error` mapping) and link `libssl` in `shim/Makefile`
- [ ] T198 [US18-shim] Make `cc_net_poll` in `shim/src/cc_net.c` accept TLS handles (pending decrypted bytes count as readable)
- [ ] T199 [US18-shim] Write implementation test `shim/tests/test_cc_tls.c` (partial reads, peer close mid-stream) to 100 % coverage of `shim/src/cc_tls.c`
- [ ] T200 Gate: run `make gate-shim` and record the command and its real output

### Lane: proto

#### Phase 8: US2-proto — buffers, scalars, text, item stacks, NBT, framing and chunks

**Goal**: every codec entry point of contracts/proto-api.md §2 needed to join and stream terrain.

**Independent Test**: `make gate-proto` — `proto/tests/contract_proto_primitives.cob` passes against the 00, 01,
06 and 07 examples and the framing fixtures; 100 % coverage of `proto/src`.

- [ ] T201 [P] [US2-proto] Write implementation test `proto/tests/test_buffer.cob`: `PB-INIT` capacity, `PB-APPEND-BYTES` growth beyond capacity, `PB-RESET`, `PB-FREE`, read past `PB-LENGTH` sets `PB-ERROR` and leaves `PB-POS` (proto-api §1)
- [ ] T202 [US2-proto] Implement `PB-INIT`, `PB-FREE`, `PB-RESET`, `PB-APPEND-BYTES` in `proto/src/buffer.cob` and add it to `SRC` in `proto/Makefile`
- [ ] T203 [P] [US2-proto] Write `proto/tests/contract_proto_primitives.cob` cases for `BOOL`, `BYTE`, `UBYTE`, `SHORT`, `USHORT`, `INT`, `LONG` put/get against the 00 §1 to §3 examples (big-endian, sign handling)
- [ ] T204 [US2-proto] Implement the fixed-width integer and boolean `PB-PUT-*`/`PB-GET-*` programs in `proto/src/scalars.cob`
- [ ] T205 [P] [US2-proto] Write `contract_proto_primitives.cob` cases for `FLOAT` and `DOUBLE` (IEEE big-endian via `REDEFINES` and byte reversal, research R2)
- [ ] T206 [US2-proto] Implement `PB-PUT-FLOAT`, `PB-GET-FLOAT`, `PB-PUT-DOUBLE`, `PB-GET-DOUBLE` in `proto/src/scalars.cob`
- [ ] T207 [P] [US2-proto] Write `contract_proto_primitives.cob` cases for `VARINT` and `VARLONG` against every 00 example, including the over-long encoding that sets `PB-ERROR`
- [ ] T208 [US2-proto] Implement `PB-PUT-VARINT`, `PB-GET-VARINT`, `PB-PUT-VARLONG`, `PB-GET-VARLONG` in `proto/src/scalars.cob`
- [ ] T209 [P] [US2-proto] Write `contract_proto_primitives.cob` cases for `STRING` and `IDENTIFIER` with maximum lengths (UTF-8 byte and code-unit limits of 00), over-length setting `PB-ERROR`
- [ ] T210 [US2-proto] Implement `PB-PUT-STRING`, `PB-GET-STRING`, `PB-PUT-IDENTIFIER`, `PB-GET-IDENTIFIER` in `proto/src/scalars.cob`
- [ ] T211 [P] [US2-proto] Write `contract_proto_primitives.cob` cases for `UUID`, `POSITION` (00 packing of x, y, z, sign extension), `BITSET` and `FIXED-BITSET`
- [ ] T212 [US2-proto] Implement `PB-PUT-`/`PB-GET-` `UUID`, `POSITION`, `BITSET`, `FIXED-BITSET` in `proto/src/scalars.cob`
- [ ] T213 [P] [US2-proto] Write `contract_proto_primitives.cob` cases for NBT writing: every tag type, compound and list begin/end, network root (nameless) and file root (named empty) framing, against 07 §1 to §3 examples
- [ ] T214 [US2-proto] Implement the `NBT-WRITE-*` programs in `proto/src/nbt.cob`
- [ ] T215 [P] [US2-proto] Write `contract_proto_primitives.cob` cases for NBT reading: tree walk, path lookup (`a.b[2].c`), every tag type, malformed input sets `PB-ERROR`
- [ ] T216 [US2-proto] Implement the `NBT-READ-*` programs in `proto/src/nbt.cob`
- [ ] T217 [P] [US2-proto] Write `contract_proto_primitives.cob` cases for `TEXT` (plain string, `{"text":…}`, `{"translate":…,"with":[…]}` as network NBT, 00 §7) and `ITEMSTACK` (empty, non-empty with AddedCount 0 and RemovedCount 0, standin-content §2)
- [ ] T218 [US2-proto] Implement `PB-PUT-TEXT`, `PB-GET-TEXT`, `PB-PUT-ITEMSTACK`, `PB-GET-ITEMSTACK` in `proto/src/composites.cob`
- [ ] T219 [P] [US2-proto] Write `contract_proto_primitives.cob` cases for `PB-FRAME-ENCODE` and `PB-FRAME-DECODE` against `contract/fixtures/wire/frame-uncompressed.hex`, `frame-compressed.hex` and `frame-below-threshold.hex`, and decoding a stream split at every byte boundary ("need more")
- [ ] T220 [US2-proto] Implement `PB-FRAME-ENCODE` and `PB-FRAME-DECODE` (length prefix, compression via `cc_deflate`/`cc_inflate` mode `CC_ZLIB` when threshold ≥ 0 and body ≥ threshold, accumulating decoder) in `proto/src/frame.cob`
- [ ] T221 [P] [US2-proto] Write `contract_proto_primitives.cob` cases for `CHUNK-SECTION-ENCODE`/`-DECODE` (single-value and 4-bit linear block palettes, 1-bit biome palette, non-empty count) and `LIGHT-ENCODE`/`-DECODE` (masks, empty masks, 2048-byte arrays) against 06 examples and the sections of `contract/fixtures/wire/play-s2c-2e-level-chunk-with-light-spawn.hex`
- [ ] T222 [US2-proto] Implement `CHUNK-SECTION-ENCODE`, `CHUNK-SECTION-DECODE`, `LIGHT-ENCODE`, `LIGHT-DECODE` in `proto/src/chunk.cob` (all palette kinds of 06 §5 including hash map and global for decoding)
- [ ] T223 [P] [US2-proto] Write `proto/tests/contract_shim_consumer.cob`: the `CCSHIM.cpy` constants `proto` uses have the values of shim-abi §1 and §5, and `cc_deflate`/`cc_inflate` link and return 0 on a minimal valid call
- [ ] T224 [US2-proto] Write implementation tests `proto/tests/test_scalars.cob`, `proto/tests/test_nbt.cob`, `proto/tests/test_frame.cob` and `proto/tests/test_chunk.cob` to 100 % coverage of `proto/src`, and list every test program in `TESTS` of `proto/Makefile`
- [ ] T225 Gate: run `make gate-proto` (root `Makefile`) and record the command and its real output

#### Phase 9: US3-proto — angles, motion vectors and entity metadata

**Goal**: codecs for entity movement and metadata packets (US3, US5). **Independent Test**: `make gate-proto`.

- [ ] T226 [P] [US3-proto] Write `contract_proto_primitives.cob` cases for `ANGLE` (1/256 turn) and `LPVEC3` (00 low-precision vector examples, zero vector form)
- [ ] T227 [US3-proto] Implement `PB-PUT-`/`PB-GET-` `ANGLE` and `LPVEC3` in `proto/src/scalars.cob`
- [ ] T228 [P] [US3-proto] Write `contract_proto_primitives.cob` cases for `ENTITY-METADATA` entries used by `docs/protocol/09-cobolcraft-profile.md` (item-stack entry of `loose_item`, terminator 0xFF) against `contract/fixtures/wire/play-s2c-65-set-entity-data-item.hex`
- [ ] T229 [US3-proto] Implement `PB-PUT-ENTITY-METADATA` and `PB-GET-ENTITY-METADATA` in `proto/src/composites.cob`
- [ ] T230 [US3-proto] Extend `proto/tests/test_scalars.cob` and add `proto/tests/test_composites.cob` to 100 % coverage of the new code
- [ ] T231 Gate: run `make gate-proto` and record the command and its real output

#### Phase 10: US10-proto — recipe displays

**Goal**: codecs for the recipe display and slot display composites of Recipe Book Add (05b 0x4B).
**Independent Test**: `make gate-proto`.

- [ ] T232 [P] [US10-proto] Write `contract_proto_primitives.cob` cases for `RECIPE-DISPLAY` and `SLOT-DISPLAY` (the display kinds the 09 profile uses for "ingredients and result") against the recipe entries of `contract/fixtures/wire/play-s2c-4b-recipe-book-add.hex`
- [ ] T233 [US10-proto] Implement `PB-PUT-RECIPE-DISPLAY`, `PB-GET-RECIPE-DISPLAY`, `PB-PUT-SLOT-DISPLAY`, `PB-GET-SLOT-DISPLAY` in `proto/src/composites.cob`
- [ ] T234 [US10-proto] Extend `proto/tests/test_composites.cob` to 100 % coverage of the recipe display code
- [ ] T235 Gate: run `make gate-proto` and record the command and its real output

#### Phase 11: US14-proto — command tree nodes

**Goal**: codecs for the Commands packet node graph (05a 0x10). **Independent Test**: `make gate-proto`.

- [ ] T236 [P] [US14-proto] Write `contract_proto_primitives.cob` cases for `COMMAND-NODE` encode and decode (root, literal and argument nodes, flags, children, redirect, parsers `brigadier:double` (2), `brigadier:integer` (3) with bounds, `brigadier:string` (5) single word and greedy, `game_profile` (7), suggestions type `minecraft:ask_server`) against `contract/fixtures/wire/play-s2c-10-commands-operator.hex`
- [ ] T237 [US14-proto] Implement `PB-PUT-COMMAND-NODE` and `PB-GET-COMMAND-NODE` in `proto/src/composites.cob`
- [ ] T238 [US14-proto] Extend `proto/tests/test_composites.cob` to 100 % coverage of the command node code
- [ ] T239 Gate: run `make gate-proto` and record the command and its real output

### Lane: core

All core state lives in `EXTERNAL` records of `core/copy/CORESTATE.cpy` (one world per process,
core-host-api.md). Content values are transcribed into `core/copy/*.cpy` from the extended standin-content;
the core never calls `cc_net_*`, `cc_win_*` or `cc_vk_*` (core-host-api §3). Core acceptance tests drive the
core through `CORE-*` entry points over memory connections with fixture packets and assert on the clientbound
bytes (plan "Test strategy" placement rule); outcomes that need a client as well are in Convergence.

#### Phase 12: US2-core — world creation, connection phases, configuration and the join sequence

**Goal**: the server side of handshake, status, login, configuration and play join, with the generated main
dimension and its light, so a player lands at the spawn point facing the marker pillar.

**Independent Test**: `make gate-core` — `core/tests/contract_coreapi_provider.cob` (US2 entry points) and the
US2 cases of `core/tests/contract_wire_server.cob` pass; a memory connection fed the handshake, login,
configuration and play fixtures receives Login, Player Position at (4.5, 54.0, 8.5) facing east and the spawn
chunk byte-equal to `play-s2c-2e-level-chunk-with-light-spawn.hex`.

- [ ] T240 [P] [US2-core] Write `core/tests/contract_shim_consumer.cob`: every `CCSHIM.cpy` constant the core uses (outcomes, `CC_ZLIB`, `CC_GZIP`) has the shim-abi value, and `cc_deflate`, `cc_inflate` and `cc_fatal` (fatal case as `core/tests/contract_shim_consumer_fatal.cob` with a `.expect` file) link and behave per shim-abi §2, §5
- [ ] T241 [P] [US2-core] Write implementation test `core/tests/test_content_tables.cob` asserting the content copybooks equal the extended standin-content: block ids, keys, properties, solid/opaque flags, light, hand break time, hard/soft class, state-id ranges and default states (§1.1, §1.2: cardstack default state 9, glowtube default 13); item ids, keys, placed states, stack sizes, tool classes, food values, attack damage (§2, §10, §11, §13); entity type ids, keys, sizes and eye heights (§3, §12); every registry entry of §4
- [ ] T242 [US2-core] Create `core/copy/BLOCKS.cpy` (block and block-state tables of standin-content §1.1, §1.2 and every block the extension adds)
- [ ] T243 [US2-core] Create `core/copy/ITEMS.cpy` (item table of standin-content §2 as extended: placed state, max stack, tool class, food value, attack damage per §10)
- [ ] T244 [US2-core] Create `core/copy/ENTITYTYPES.cpy` (entity type table of standin-content §3 as extended: id, key, width, height, eye height)
- [ ] T245 [US2-core] Create `core/copy/REGISTRY.cpy` (entry data of every Registry Data packet of standin-content §4.2 as extended, in id order: biomes, chat type, MV placeholders, dimension types, damage types, world clock)
- [ ] T246 [US2-core] Create `core/copy/CORESTATE.cpy`: `EXTERNAL` records for settings, connection table (id, kind, phase, inbound accumulator, outbound queue, compression on, close flag, keep-alive id and deadline), player table (data-model §6 fields), world (time, spawn, dimension list) and per-dimension chunk cache (data-model §1 to §3)
- [ ] T247 [P] [US2-core] Write `core/tests/contract_coreapi_provider.cob` cases for `CORE-WORLD-OPEN` (new world in a temporary folder, created flag 1), `CORE-CONN-OPEN` (memory kind returns an id), `CORE-CONN-INPUT` with the handshake and login fixtures, `CORE-CONN-OUTPUT` containing Login Finished bytes, `CORE-CONN-CLOSED`, `CORE-TICK`, `CORE-CONSOLE-DRAIN` and `CORE-STATUS-GET` (record layouts from `COREAPI.cpy`, core-host-api §2, §4)
- [ ] T248 [US2-core] Implement entry points `CORE-WORLD-OPEN` (settings stored; a folder without `level.dat` becomes a new in-memory world with every enabled dimension, spawn point and time 0 per standin-content §5, §15), `CORE-CONN-OPEN`, `CORE-CONN-INPUT`, `CORE-CONN-OUTPUT`, `CORE-CONN-CLOSED`, `CORE-TICK`, `CORE-CONSOLE-DRAIN` and `CORE-STATUS-GET` in `core/src/api.cob`, delegating to the session and world modules, and add the core sources to `SRC` in `core/Makefile`
- [ ] T249 [P] [US2-core] Write implementation test `core/tests/test_session.cob`: inbound bytes split at arbitrary boundaries assemble into packets, packets dispatch by phase, a packet the receiver cannot decode is handled as 01 defines, outbound frames are compressed only on network connections after Set Compression, the close flag is raised after a disconnect packet, connection ids are reused only after close (core-host-api §2, §3)
- [ ] T250 [US2-core] Implement the connection table, phase dispatcher, inbound frame accumulation (`PB-FRAME-DECODE`) and outbound queue (`PB-FRAME-ENCODE`) in `core/src/session.cob`
- [ ] T251 [P] [US2-core] Write implementation test `core/tests/test_keepalive.cob`: Keep Alive every 15 s (300 ticks) in configuration and play, echo accepted, timeout disconnect as 01 §7.5 defines (contracts/wire-profile.md §2)
- [ ] T252 [US2-core] Implement keep-alive sending and timeout disconnect in `core/src/session.cob`
- [ ] T253 [P] [US2-core] Write `core/tests/contract_wire_server.cob` status cases: Intention fixtures decode; Status Response for default settings equals `status-s2c-00-status-response.hex` (online count from the player table); Ping Request answered by `status-s2c-01-pong-response.hex`
- [ ] T254 [US2-core] Implement the status phase (Status Response JSON per contracts/wire-profile.md §2, Pong, close after pong) in `core/src/status.cob`
- [ ] T255 [P] [US2-core] Write acceptance test `core/tests/acc_us2_protocol_mismatch.cob`: case "acceptance US2 edge given a client with a different protocol version when it pings and when it logs in then status is answered and login ends with the 02 disconnect behaviour" (fixture `handshake-c2s-00-intention-other-protocol.hex`, expected `login-s2c-00-login-disconnect-protocol-mismatch.hex`)
- [ ] T256 [US2-core] Implement the protocol-version check of 02 for login intentions in `core/src/login.cob`
- [ ] T257 [P] [US2-core] Write `contract_wire_server.cob` login cases: Hello decodes name and UUID; Set Compression (network only), Login Finished and Login Acknowledged match their fixtures; and implementation test `core/tests/test_login.cob`: offline UUID of `Notch` is `b50ad385-829d-3141-a216-7e7d7539ba7f` and of `Alice` matches the fixture (02 Offline mode, research R11)
- [ ] T258 [US2-core] Implement login in `core/src/login.cob`: offline UUID by a direct `CALL STATIC "EVP_Digest"` with `EVP_md5` over `OfflinePlayer:<name>` then version-3/variant bits (research R11), Set Compression threshold 256 on network connections only, Login Finished without properties, transition to configuration on Login Acknowledged (contracts/wire-profile.md §1, §2)
- [ ] T259 [P] [US2-core] Write acceptance test `core/tests/acc_us2_duplicate_name.cob`: case "acceptance US2 edge given a player online when a second login uses the same name then the first connection is disconnected and the new one joins" (fixture `play-s2c-20-disconnect-duplicate-login.hex`)
- [ ] T260 [US2-core] Implement duplicate-name handling (disconnect the earlier connection with the standin-content §17 text, 02 Login sequence) in `core/src/login.cob`
- [ ] T261 [P] [US2-core] Write `contract_wire_server.cob` registry cases: every `config-s2c-07-registry-data-*.hex` fixture equals the core's Registry Data for that registry
- [ ] T262 [US2-core] Implement Registry Data builders for every registry of `REGISTRY.cpy` in `core/src/registries.cob` (network NBT entries, 04 §3, §4; no packet for empty registries)
- [ ] T263 [P] [US2-core] Write `contract_wire_server.cob` configuration cases: brand, Update Enabled Features, Select Known Packs, Update Tags, Finish Configuration and configuration Keep Alive equal their fixtures; serverbound brand, Client Information, Select Known Packs and Finish Configuration decode
- [ ] T264 [US2-core] Implement the configuration sequence in `core/src/config-phase.cob` in the order of 03 "Configuration sequence" (brand, features, known packs, Registry Data ×n, Update Tags, Finish Configuration; no code of conduct, no server links), moving to play on the client's Finish Configuration
- [ ] T265 [P] [US2-core] Write implementation test `core/tests/test_worldgen.cob`: surface height of sample columns (4, 8) = 53 and extremes 46 to 58, column layers, marker pillar states at chunk (0, 0) local (8, 8), biome per 4 × 4 × 4 cell (standin-content §5.2)
- [ ] T266 [US2-core] Implement the `cobolcraft:main` generator in `core/src/worldgen.cob` (standin-content §5.2, `FUNCTION SIN`/`COS`, research R2)
- [ ] T267 [P] [US2-core] Write implementation test `core/tests/test_light.cob`: sky light column drop, block light from a lit glowtube decreasing by taxicab distance through non-opaque cells, recompute of affected sections on change (standin-content §5.2 light policy)
- [ ] T268 [US2-core] Implement the stand-in light policy in `core/src/light.cob`
- [ ] T269 [P] [US2-core] Write implementation test `core/tests/test_world.cob`: chunk cache generates on first access, block get/set by position, height-range check, changed flag set on set (data-model §3)
- [ ] T270 [US2-core] Implement the per-dimension chunk cache and block access in `core/src/world.cob`
- [ ] T271 [P] [US2-core] Write `contract_wire_server.cob` chunk cases: the core's Level Chunk With Light for chunk (0, 0) equals `play-s2c-2e-level-chunk-with-light-spawn.hex`; Chunk Batch Start/Finished and Set Chunk Cache Center equal their fixtures; Chunk Batch Received decodes
- [ ] T272 [US2-core] Implement chunk payload building (sections via `CHUNK-SECTION-ENCODE`, heightmaps, light via `LIGHT-ENCODE`) and the initial batch of every chunk within view distance in `core/src/chunks-stream.cob` (06; contracts/wire-profile.md §3.2)
- [ ] T273 [P] [US2-core] Write implementation test `core/tests/test_players.cob`: a new player record has the offline identity, the configured default game mode (FR-007, FR-009), the world spawn point and yaw facing east, full health and food per standin-content §10, §11
- [ ] T274 [US2-core] Implement the player table and new-player creation in `core/src/players.cob`
- [ ] T275 [P] [US2-core] Write `contract_wire_server.cob` play-join cases: Login (play), Game Event 13, Player Position, Player Abilities (creative and survival), Set Default Spawn Position, Set Time, Set Held Slot, Set Player Inventory and Container Set Content (empty) equal their fixtures; Accept Teleportation, Player Loaded, Client Tick End and play Keep Alive decode
- [ ] T276 [P] [US2-core] Write implementation test `core/tests/test_play_join.cob`: over a memory connection fed every serverbound join fixture, the clientbound sequence is Login, abilities, spawn position, time, inventory, Player Position at the spawn, chunk batch with the spawn chunk, and the player becomes Alive after Player Loaded (data-model §6, plan US2 sequence diagram)
- [ ] T277 [US2-core] Implement the play join sequence and the handling of Accept Teleportation, Chunk Batch Received, Player Loaded, Client Tick End and Client Information in `core/src/play.cob`
- [ ] T278 [US2-core] Write implementation tests `core/tests/test_api.cob`, `core/tests/test_status.cob`, `core/tests/test_registries.cob` and `core/tests/test_chunks_stream.cob` to 100 % coverage of the US2 core sources and `core/copy`, and list every test program in `TESTS` of `core/Makefile`
- [ ] T279 Gate: run `make gate-core` (root `Makefile`) and record the command and its real output

#### Phase 13: US3-core — movement, chunk streaming, other players, day and night

**Goal**: server-validated movement, streaming by view distance, other players' entities and the time of day.
**Independent Test**: `make gate-core` with `core/tests/acc_us3_streaming.cob` passing.

- [ ] T280 [P] [US3-core] Write `contract_wire_server.cob` cases: Move Player Pos/PosRot/Rot/Status Only and serverbound Player Abilities decode; Add Entity (operator), Player Info Update, Player Info Remove, Move Entity Pos/PosRot/Rot, Rotate Head, Teleport Entity, Remove Entities and Forget Level Chunk equal their fixtures
- [ ] T281 [P] [US3-core] Write implementation test `core/tests/test_movement.cob`: a move into open space is accepted; a move whose player box (0.7 × 1.75, standin-content §3) would intersect a solid block is answered with Player Position at the last valid position; on-ground and the fall start height are tracked; serverbound flying is accepted only in creative (US3-2, US3-3, data-model §6)
- [ ] T282 [US3-core] Implement movement validation, on-ground and fall tracking and the flying flag in `core/src/movement.cob`
- [ ] T283 [P] [US3-core] Write acceptance test `core/tests/acc_us3_streaming.cob`: case "acceptance US3-4 given a player walking across chunk borders when they move then Set Chunk Cache Center and every newly in-range chunk are sent and chunks beyond the view distance are forgotten"
- [ ] T284 [US3-core] Implement view-distance streaming on movement (centre update, new chunks in batches, Forget Level Chunk) in `core/src/chunks-stream.cob`
- [ ] T285 [P] [US3-core] Write implementation test `core/tests/test_entities.cob`: network entity ids are unique per run; a player sees an entity iff same dimension and within view distance; entering, moving (small deltas as Move Entity, large as Teleport Entity, head rotation as Rotate Head) and leaving visibility produce the right packets (US3-5)
- [ ] T286 [US3-core] Implement entity id allocation and per-player entity visibility tracking in `core/src/entities.cob`
- [ ] T287 [P] [US3-core] Write implementation test `core/tests/test_other_players.cob`: when B joins near A, A receives Player Info Update and Add Entity `cobolcraft:operator` at B's position and facing; B's moves reach A; B's disconnect or moving out of view sends Remove Entities and (on disconnect) Player Info Remove
- [ ] T288 [US3-core] Implement other-player presence (Player Info Update/Remove, operator entities) using the entity tracker in `core/src/play.cob`
- [ ] T289 [P] [US3-core] Write implementation test `core/tests/test_time.cob`: time of day advances 1 per tick and wraps at the day length of standin-content §4.8; Set Time is sent once per second (US3-6)
- [ ] T290 [US3-core] Implement time of day and the Set Time cadence in `core/src/world.cob`
- [ ] T291 [US3-core] Extend the core implementation tests to 100 % coverage of the US3 changes
- [ ] T292 Gate: run `make gate-core` and record the command and its real output

#### Phase 14: US4-core — placing, breaking, glowtube toggling, inventory

**Goal**: the server rules of standin-content §1.3 and data-model §3, §4. **Independent Test**: `make gate-core`
with every `core/tests/acc_us4_*.cob` passing.

- [ ] T293 [P] [US4-core] Write `contract_wire_server.cob` cases: Use Item On, Player Action start/abort/stop destroy, Set Carried Item, Container Click and Set Creative Mode Slot decode; Block Update, Section Blocks Update, Block Changed Ack, Block Destruction, Container Set Slot, Set Held Slot and Light Update equal their fixtures
- [ ] T294 [P] [US4-core] Write implementation test `core/tests/test_inventory.cob`: 36 slots (0–8 hotbar, 9–35 main), add fills matching stacks then empty slots in slot order and returns the part that did not fit, remove, move and swap, held slot 0–8 (data-model §4)
- [ ] T295 [US4-core] Implement the inventory model in `core/src/inventory.cob`
- [ ] T296 [P] [US4-core] Write acceptance test `core/tests/acc_us4_place.cob`: case "acceptance US4-2 given a held block item when place is used on a face then the block appears in the adjacent void position in its default state" plus one case per cardstack face axis (§1.3)
- [ ] T297 [P] [US4-core] Write acceptance test `core/tests/acc_us4_place_refusals.cob`: cases for the US4 edge cases: target not void, outside the dimension height range, overlapping a player — nothing placed, Block Changed Ack sent, in survival the item is not used up
- [ ] T298 [P] [US4-core] Write acceptance test `core/tests/acc_us4_use_up.cob`: cases "given survival when a block is placed then one item leaves the held stack" and "given creative when a block is placed then the stack is unchanged" (US4 edge case, FR-007)
- [ ] T299 [US4-core] Implement placement (Use Item On with a block item: default state or cardstack axis from the face, void-only, height range, no overlap with any player or mob box, survival use-up, Block Update to every player in the same dimension within view distance, Block Changed Ack) in `core/src/blocks.cob`
- [ ] T300 [P] [US4-core] Write acceptance test `core/tests/acc_us4_break_survival.cob`: case "acceptance US4-3 given survival when a block is broken then it takes the §1.1 hand break time, a quarter with the matching tool of §2, and becomes void"; case "a finish before the break time leaves the block"; case "the baseplate is never broken" (US4 edge)
- [ ] T301 [P] [US4-core] Write acceptance test `core/tests/acc_us4_break_creative.cob`: case "acceptance US4-4 given creative when a block is broken then it breaks at once and no item appears"; baseplate case
- [ ] T302 [US4-core] Implement breaking (Player Action start/abort/stop with tick timing per data-model §3, tool quarter, creative instant on start, baseplate refusal, void result, broadcast, ack) in `core/src/blocks.cob`
- [ ] T303 [P] [US4-core] Write acceptance test `core/tests/acc_us4_glowtube.cob`: case "acceptance US4-5 given no held block item when place is used on a glowtube then lit toggles and the light around it is recomputed and sent" (Block Update plus Light Update)
- [ ] T304 [US4-core] Implement glowtube toggling and section light recomputation with Light Update on place, break and toggle in `core/src/blocks.cob`
- [ ] T305 [P] [US4-core] Write implementation test `core/tests/test_block_broadcast.cob`: two connections in the same dimension within view distance both receive each change; a third outside view distance does not; two changes to one block in one tick leave both players with the final state (US4-7 server half, US4 edge)
- [ ] T306 [US4-core] Implement the dimension- and distance-scoped block change broadcast used by place, break and toggle in `core/src/blocks.cob`
- [ ] T307 [P] [US4-core] Write acceptance test `core/tests/acc_us4_inventory.cob`: case "acceptance US4-6 given an inventory when the held slot is changed and items are moved between slots then the server's slots and held slot match and Container Set Slot echoes"; creative Set Creative Mode Slot case
- [ ] T308 [US4-core] Implement Set Carried Item, Container Click (player inventory window 0 modes of 05c) and creative Set Creative Mode Slot handling in `core/src/inventory.cob`
- [ ] T309 [P] [US4-core] Write acceptance test `core/tests/acc_us4_starting_items.cob`: case "acceptance US4-8 given a first-time survival player when they join then their inventory holds the §2 starting items"; case "a returning player is not given them again"
- [ ] T310 [US4-core] Implement the one-time survival starting inventory in `core/src/players.cob`
- [ ] T311 [US4-core] Extend the core implementation tests to 100 % coverage of the US4 changes
- [ ] T312 Gate: run `make gate-core` and record the command and its real output

#### Phase 15: US5-core — ground items

**Goal**: the `loose_item` rules of standin-content §9 and data-model §5. **Independent Test**: `make gate-core`.

- [ ] T313 [US5-core] Create `core/copy/RULES.cpy` with the ground-item constants of standin-content §9 and extend `core/tests/test_content_tables.cob` to assert them
- [ ] T314 [P] [US5-core] Write `contract_wire_server.cob` cases: Add Entity (loose_item), Set Entity Data (item), Set Entity Motion and Take Item Entity equal their fixtures; Player Action drop item and drop all items decode
- [ ] T315 [P] [US5-core] Write acceptance test `core/tests/acc_us5_break_drop.cob`: case "acceptance US5-1 given survival when a block is broken then a loose_item with the block's item appears where the block was, falls and rests on a block, and every player in the same dimension within view distance is sent it" (also the ground-item half of US4-3)
- [ ] T316 [US5-core] Implement ground-item spawning (Add Entity plus item metadata to viewers) and its hook from survival breaking in `core/src/ground-items.cob` and `core/src/blocks.cob`
- [ ] T317 [P] [US5-core] Write implementation test `core/tests/test_ground_item_physics.cob`: gravity per §9, resting on a solid block, falling again when the block below is removed, motion and position updates to viewers (data-model §5 state machine)
- [ ] T318 [US5-core] Implement ground-item physics per tick in `core/src/ground-items.cob`
- [ ] T319 [P] [US5-core] Write acceptance test `core/tests/acc_us5_pickup.cob`: case "acceptance US5-2 given a ground item when a survival or creative player comes within pickup range then it leaves the ground (Take Item Entity, Remove Entities) and is added to their inventory"
- [ ] T320 [P] [US5-core] Write acceptance test `core/tests/acc_us5_pickup_edges.cob`: cases for the US5 edge cases — two players reach it in the same tick and exactly one gets it; a player with room for part of the stack takes what fits and the rest stays (Set Entity Data with the reduced count); a full inventory leaves it on the ground (SC-011)
- [ ] T321 [US5-core] Implement pickup resolution inside the tick in player order with partial pickup and pickup delay in `core/src/ground-items.cob` (data-model §5 exactly-once rule)
- [ ] T322 [P] [US5-core] Write acceptance test `core/tests/acc_us5_throw.cob`: case "acceptance US5-3 given a held item when throw is used then one item (whole stack with the modifier) leaves the inventory and lands in front of the player" with §9's initial motion and the thrower's pickup delay
- [ ] T323 [US5-core] Implement throwing (Player Action drop item / drop all items) in `core/src/ground-items.cob`
- [ ] T324 [P] [US5-core] Write acceptance test `core/tests/acc_us5_despawn.cob`: case "acceptance US5-4 given a ground item when it has aged the despawn time then it disappears for everyone"; case "its age does not advance while no player is within the §9 near distance" (US5 edge)
- [ ] T325 [US5-core] Implement ageing near players and despawn in `core/src/ground-items.cob`
- [ ] T326 [P] [US5-core] Write implementation test `core/tests/test_ground_item_merge.cob` for the merge rule of standin-content §9 (merge within range, or — if §9 states items never merge — two identical items stay separate)
- [ ] T327 [US5-core] Implement the standin-content §9 merge rule in `core/src/ground-items.cob`
- [ ] T328 [US5-core] Extend the core implementation tests to 100 % coverage of the US5 changes
- [ ] T329 Gate: run `make gate-core` and record the command and its real output

#### Phase 16: US6-core — chat

**Goal**: FR-013 chat delivery. **Independent Test**: `make gate-core` with `acc_us6_chat_broadcast.cob` passing.

- [ ] T330 [P] [US6-core] Write `contract_wire_server.cob` cases: Chat (unsigned) decodes; System Chat (chat line) equals `play-s2c-7c-system-chat-chat.hex`
- [ ] T331 [P] [US6-core] Write acceptance test `core/tests/acc_us6_chat_broadcast.cob`: case "acceptance US6-1 given players in different dimensions when one sends a message then every connected player including the sender receives `<name> message` as System Chat, in the order the server received the messages" (FR-013, SC-006 server half)
- [ ] T332 [US6-core] Implement chat handling and broadcast in `core/src/chat.cob` (message length limits of 05c)
- [ ] T333 [US6-core] Extend the core implementation tests to 100 % coverage of `core/src/chat.cob`
- [ ] T334 Gate: run `make gate-core` and record the command and its real output

#### Phase 17: US7-core — health, damage, death and respawn

**Goal**: the standin-content §10 rules. **Independent Test**: `make gate-core` with every `acc_us7_*.cob` passing.

- [ ] T335 [US7-core] Add the health and death constants of standin-content §10 to `core/copy/RULES.cpy` and the death messages to a new `core/copy/MESSAGES.cpy`; extend `core/tests/test_content_tables.cob`
- [ ] T336 [P] [US7-core] Write `contract_wire_server.cob` cases: Set Health, Damage Event, Hurt Animation, Player Combat Kill and Respawn (main) equal their fixtures; Attack and Client Command (respawn) decode
- [ ] T337 [P] [US7-core] Write acceptance test `core/tests/acc_us7_fall_damage.cob`: case "acceptance US7-2 given a survival player when they land after falling farther than the safe height then they lose the §10 fall damage and are sent Set Health and the hurt packets"
- [ ] T338 [US7-core] Implement damage application (health decrease, Set Health, Damage Event, Hurt Animation to viewers, damage type) and fall damage on landing in `core/src/health.cob` and `core/src/movement.cob`
- [ ] T339 [P] [US7-core] Write acceptance test `core/tests/acc_us7_attack.cob`: case "acceptance US7-5 given a player aiming at another player within reach when they attack then the target takes the §10 damage of the held item"; case "acceptance US7-2 the hit survival player loses that health"; case "US7 edge given player combat disabled then no damage"
- [ ] T340 [US7-core] Implement the Attack packet (reach check, held-item damage, player combat setting) in `core/src/health.cob`
- [ ] T341 [P] [US7-core] Write acceptance test `core/tests/acc_us7_recovery.cob`: case "acceptance US7-3 given a hurt survival player with the §10 required food level when time passes without damage then health recovers at the §10 rate up to the maximum"; case "below the required food level it does not"
- [ ] T342 [US7-core] Implement health recovery in `core/src/health.cob`
- [ ] T343 [P] [US7-core] Write acceptance test `core/tests/acc_us7_death_respawn.cob`: case "acceptance US7-4 given health reaches zero then Player Combat Kill carries the cause, every player receives the §10 death message, the inventory follows the §10 death rule, and after respawn the player is in the main dimension at the world spawn with full health and food"; case "a player who disconnects while dead is stored dead and sees the death screen on rejoin" (data-model §6)
- [ ] T344 [US7-core] Implement death and respawn (Client Command action 0, Respawn, Player Position, Set Health) in `core/src/health.cob`
- [ ] T345 [P] [US7-core] Write acceptance test `core/tests/acc_us7_creative.cob`: case "acceptance US7-6 given creative when anything would damage them then no damage is taken"; case "US7 edge switching from survival while hurt keeps the stored health and restores it when switching back"
- [ ] T346 [US7-core] Implement creative immunity across every damage cause in `core/src/health.cob`
- [ ] T347 [US7-core] Extend the core implementation tests to 100 % coverage of the US7 changes
- [ ] T348 Gate: run `make gate-core` and record the command and its real output

#### Phase 18: US8-core — hunger and eating

**Goal**: the standin-content §11 rules. **Independent Test**: `make gate-core` with every `acc_us8_*.cob` passing.

- [ ] T349 [US8-core] Add the hunger constants of standin-content §11 to `core/copy/RULES.cpy` and extend `core/tests/test_content_tables.cob`
- [ ] T350 [P] [US8-core] Write `contract_wire_server.cob` cases: Entity Event (eating finished) equals its fixture; Use Item and Player Action release-use-item decode
- [ ] T351 [P] [US8-core] Write acceptance test `core/tests/acc_us8_food_falls.cob`: case "acceptance US8-2 given a survival player when time passes and they walk, run, jump, attack or break blocks then their food level falls at the §11 rates" (one case per activity)
- [ ] T352 [US8-core] Implement exhaustion accumulation and food decrease in `core/src/hunger.cob` with hooks from movement, attack and breaking
- [ ] T353 [P] [US8-core] Write acceptance test `core/tests/acc_us8_eat.cob`: case "acceptance US8-3 given food below full and a held food item when eat is held for the eating time then one item is used and food rises by its value up to the maximum"; case "acceptance US8-4 given full food then nothing is eaten"; case "US8 edge released before the eating time then nothing is eaten"
- [ ] T354 [US8-core] Implement eating (Use Item start, completion after the eating time, release cancels, full-food refusal, Entity Event, Set Health, slot update) in `core/src/hunger.cob`
- [ ] T355 [P] [US8-core] Write acceptance test `core/tests/acc_us8_starvation.cob`: case "acceptance US8-5 given food at zero when time passes then starvation damage of §10/§11 is taken" (also the starvation cause of US7-2)
- [ ] T356 [US8-core] Implement starvation damage through the damage path in `core/src/hunger.cob`
- [ ] T357 [P] [US8-core] Write acceptance test `core/tests/acc_us8_creative.cob`: case "acceptance US8-6 given creative when time passes then food does not change"
- [ ] T358 [US8-core] Implement the creative hunger exemption in `core/src/hunger.cob`
- [ ] T359 [US8-core] Extend the core implementation tests to 100 % coverage of the US8 changes
- [ ] T360 Gate: run `make gate-core` and record the command and its real output

#### Phase 19: US9-core — mobs

**Goal**: the standin-content §12 mobs. **Independent Test**: `make gate-core` with every `acc_us9_*.cob` passing.

- [ ] T361 [US9-core] Create `core/copy/MOBS.cpy` (per mob type of standin-content §12: health, speed, behaviour, notice range, reach, damage, cooldown, spawning per dimension, yield) and extend `core/tests/test_content_tables.cob`
- [ ] T362 [P] [US9-core] Write implementation test `core/tests/test_rng.cob` for the deterministic pseudo-random rule of standin-content §12 (and §14) with reference values computed from the doc
- [ ] T363 [US9-core] Implement the deterministic pseudo-random source in `core/src/rng.cob`
- [ ] T364 [P] [US9-core] Write `contract_wire_server.cob` cases: Add Entity for each mob type equals its fixture
- [ ] T365 [P] [US9-core] Write acceptance test `core/tests/acc_us9_spawning.cob`: case "acceptance US9-1 given a dimension when ticks pass then mobs of each §12 type spawn where, when and as many as its rules allow and viewers are sent them" (one case per dimension)
- [ ] T366 [US9-core] Implement mob spawning per dimension in `core/src/mobs.cob`
- [ ] T367 [P] [US9-core] Write implementation test `core/tests/test_mob_movement.cob`: wandering per §12 speed, collision with blocks, movement and head rotation sent to viewers
- [ ] T368 [US9-core] Implement mob movement and collision in `core/src/mobs.cob`
- [ ] T369 [P] [US9-core] Write acceptance test `core/tests/acc_us9_hostile.cob`: case "acceptance US9-2 given a hostile mob and a survival player within notice range then it moves toward them and attacks in reach for its §12 damage"; case "acceptance US9-3 given a passive mob when the player approaches then it never attacks"
- [ ] T370 [US9-core] Implement hostile noticing, pursuit, attack with cooldown through the damage path in `core/src/mobs.cob`
- [ ] T371 [P] [US9-core] Write acceptance test `core/tests/acc_us9_target_drop.cob`: cases for the US9 edge case — the target switches to creative, disconnects, dies or changes dimension and the mob stops pursuing
- [ ] T372 [US9-core] Implement target dropping in `core/src/mobs.cob`
- [ ] T373 [P] [US9-core] Write acceptance test `core/tests/acc_us9_defeat.cob`: case "acceptance US9-4 given a player attacks a mob when its health reaches zero then it is removed and its §12 yield lies on the ground where it was"; Hurt Animation on each hit
- [ ] T374 [US9-core] Implement mob health, damage from attacks and defeat with yield ground items in `core/src/mobs.cob` and `core/src/health.cob`
- [ ] T375 [P] [US9-core] Write acceptance test `core/tests/acc_us9_hostile_off.cob`: case "acceptance US9-6 given hostile-mobs off then no hostile mob spawns and existing hostile mobs are removed"
- [ ] T376 [US9-core] Implement the hostile-mobs setting in `core/src/mobs.cob`
- [ ] T377 [US9-core] Extend the core implementation tests to 100 % coverage of the US9 changes
- [ ] T378 Gate: run `make gate-core` and record the command and its real output

#### Phase 20: US10-core — crafting

**Goal**: the standin-content §13 recipes and data-model §8. **Independent Test**: `make gate-core`.

- [ ] T379 [US10-core] Create `core/copy/RECIPES.cpy` (recipes of standin-content §13 in display-id order) and extend `core/tests/test_content_tables.cob`
- [ ] T380 [P] [US10-core] Write acceptance test `core/tests/acc_us10_obtainable.cob`: case "SC-008 every recipe result and every food item is obtainable in survival from the §2 starting inventory, block yields, mob yields and other recipes" (closure over the content tables)
- [ ] T381 [P] [US10-core] Write `contract_wire_server.cob` cases: Recipe Book Add equals `play-s2c-4b-recipe-book-add.hex` for the fixture's inventory; Place Recipe decodes
- [ ] T382 [P] [US10-core] Write acceptance test `core/tests/acc_us10_recipe_book.cob`: case "acceptance US10-1 given a joining player then every recipe is sent with its ingredients and result and craftable marked from their inventory"; case "the flags are re-sent when the inventory changes"
- [ ] T383 [US10-core] Implement the recipe book (Recipe Book Add on join and on inventory change, craftable = ingredients present and result fits after removal) in `core/src/crafting.cob`
- [ ] T384 [P] [US10-core] Write acceptance test `core/tests/acc_us10_craft.cob`: case "acceptance US10-2 given the ingredients when crafted then they are removed and the result added"; case "acceptance US10-3 given missing ingredients then nothing changes"; case "acceptance US10-4 given no room for the result then nothing changes"
- [ ] T385 [US10-core] Implement Place Recipe as an atomic craft-one in `core/src/crafting.cob`
- [ ] T386 [US10-core] Extend the core implementation tests to 100 % coverage of `core/src/crafting.cob`
- [ ] T387 Gate: run `make gate-core` and record the command and its real output

#### Phase 21: US11-core — weather

**Goal**: the standin-content §14 weather per dimension. **Independent Test**: `make gate-core`.

- [ ] T388 [US11-core] Create `core/copy/WEATHER.cpy` (kinds, wire pairs, applicability, frequency and duration, effects of standin-content §14) and extend `core/tests/test_content_tables.cob`
- [ ] T389 [P] [US11-core] Write `contract_wire_server.cob` cases: Game Event 1, 2, 7, 8 equal their fixtures
- [ ] T390 [P] [US11-core] Write acceptance test `core/tests/acc_us11_cycle.cob`: case "acceptance US11-1 given a dimension with weather when its remaining time ends then the next kind and duration follow §14 and every player in that dimension is sent the kind's pair"; case "acceptance US11-2 two players in the same dimension receive the same pair at the same tick"; the pair is also sent on join
- [ ] T391 [US11-core] Implement per-dimension weather state, change selection and the Game Event pair broadcast in `core/src/weather.cob`
- [ ] T392 [P] [US11-core] Write acceptance test `core/tests/acc_us11_effect.cob`: case "acceptance US11-3 given a kind with a §14 gameplay effect when it is active then it applies to players and mobs in the biomes where it applies"
- [ ] T393 [US11-core] Implement weather gameplay effects in `core/src/weather.cob`
- [ ] T394 [P] [US11-core] Write acceptance test `core/tests/acc_us11_changes_off.cob`: case "acceptance US11-4 given weather-changes off when time passes then the weather stays as it is"
- [ ] T395 [US11-core] Implement the weather-changes setting in `core/src/weather.cob`
- [ ] T396 [P] [US11-core] Write acceptance test `core/tests/acc_us11_no_weather.cob`: case "US11 edge given a dimension without weather then its players are always sent STOP_RAINING whatever the weather elsewhere"
- [ ] T397 [US11-core] Implement the no-weather dimension rule in `core/src/weather.cob`
- [ ] T398 [US11-core] Extend the core implementation tests to 100 % coverage of `core/src/weather.cob`
- [ ] T399 Gate: run `make gate-core` and record the command and its real output

#### Phase 22: US12-core — extra dimensions and travel

**Goal**: the standin-content §15 dimensions. **Independent Test**: `make gate-core`.

- [ ] T400 [US12-core] Create `core/copy/DIMENSIONS.cpy` (keys, dimension types, generators, light policies, weather flag, spawning, travel trigger and arrival rules of standin-content §5, §15) and extend `core/tests/test_content_tables.cob`
- [ ] T401 [P] [US12-core] Write implementation test `core/tests/test_worldgen_extra.cob`: sample columns of every extra dimension's §15 generator
- [ ] T402 [US12-core] Implement the §15 generator(s) in `core/src/worldgen.cob`, selected by dimension
- [ ] T403 [P] [US12-core] Write implementation test `core/tests/test_light_extra.cob`: the §15 light policy of every extra dimension
- [ ] T404 [US12-core] Implement per-dimension light policy selection in `core/src/light.cob`
- [ ] T405 [P] [US12-core] Write `contract_wire_server.cob` cases: Respawn for every extra dimension equals its fixture; Login lists every enabled dimension
- [ ] T406 [P] [US12-core] Write acceptance test `core/tests/acc_us12_travel.cob`: case "acceptance US12-1 given the §15 means of travel when used then the player is at the §15 arrival point of the target dimension with the same inventory, health, food and game mode, and receives Respawn, Player Position, that dimension's chunks and weather pair" (each direction)
- [ ] T407 [US12-core] Implement travel (§15 trigger on Use Item On or movement, arrival point rule, Respawn with data to keep 0x03, re-run of the join stream for the new dimension, console line) in `core/src/dimensions.cob`
- [ ] T408 [P] [US12-core] Write acceptance test `core/tests/acc_us12_isolation.cob`: case "acceptance US12-2 given players in different dimensions when either changes the world then the other is not sent the change until they are in that dimension"; case "US12 edge mobs and ground items near a traveller stay in their dimension"
- [ ] T409 [US12-core] Implement dimension scoping of chunks, entities and block broadcasts in `core/src/dimensions.cob` and `core/src/entities.cob`
- [ ] T410 [P] [US12-core] Write acceptance test `core/tests/acc_us12_rejoin.cob`: case "acceptance US12-3 given a player in an extra dimension when they disconnect and rejoin then they are in that dimension at the position they left"
- [ ] T411 [US12-core] Implement stored-dimension restore on join in `core/src/players.cob`
- [ ] T412 [P] [US12-core] Write acceptance test `core/tests/acc_us12_disabled.cob`: case "acceptance US12-4 given extra-dimensions off when a player tries to travel then they stay"; case "a player stored in a disabled dimension joins at the world spawn in the main dimension"; Login lists only enabled dimensions
- [ ] T413 [US12-core] Implement the extra-dimensions setting in `core/src/dimensions.cob`
- [ ] T414 [US12-core] Extend the core implementation tests to 100 % coverage of the US12 changes
- [ ] T415 Gate: run `make gate-core` and record the command and its real output

#### Phase 23: US13-core — persistence and console lines

**Goal**: the world folder of `docs/protocol/07-nbt-and-anvil.md` §9 and the console lines of operator-surface
§3. **Independent Test**: `make gate-core` with `acc_us13_restore.cob` passing.

- [ ] T416 [P] [US13-core] Write implementation test `core/tests/test_datfile.cob`: gzip NBT file write then read round trip with `CBL_*` routines and `cc_deflate`/`cc_inflate` mode `CC_GZIP` (07 §5.1)
- [ ] T417 [US13-core] Implement gzip NBT file read and write in `core/src/datfile.cob`
- [ ] T418 [P] [US13-core] Write implementation test `core/tests/test_region.cob`: region file header, sector allocation, zlib chunk payloads, rewrite of a grown chunk, reading an absent chunk (07 §6)
- [ ] T419 [US13-core] Implement region file read and write in `core/src/region.cob`
- [ ] T420 [P] [US13-core] Write implementation test `core/tests/test_chunk_nbt.cob`: chunk NBT per 07 §7 with the 07 §9 values (status, block-state and biome palettes with keys and properties, no block entities, `LastUpdate`) round-trips
- [ ] T421 [US13-core] Implement chunk NBT save and load in `core/src/persistence.cob`
- [ ] T422 [P] [US13-core] Write implementation test `core/tests/test_entity_nbt.cob`: entity chunk payloads (`DataVersion`, `Position`, `Entities` with mob and ground-item keys of 07 §9) round-trip including remaining despawn age
- [ ] T423 [US13-core] Implement entity storage save and load in `core/src/persistence.cob`
- [ ] T424 [P] [US13-core] Write implementation test `core/tests/test_level_dat.cob`: `level.dat` keys of 07 §9 round-trip (name, game mode, time, spawn, per-dimension weather); `GameMode` applies to new players only for host kinds 1 and 2
- [ ] T425 [US13-core] Implement `level.dat` save and load in `core/src/persistence.cob`
- [ ] T426 [P] [US13-core] Write implementation test `core/tests/test_access_dat.cob`: `access.dat` operators, bans and allow-list round-trip as offline identities
- [ ] T427 [US13-core] Implement the in-memory operator, ban and allow lists in `core/src/access.cob` and `access.dat` save and load in `core/src/persistence.cob`
- [ ] T428 [P] [US13-core] Write implementation test `core/tests/test_player_dat.cob`: `players/<uuid>.dat` round-trip of dimension, position, rotation, game mode, health, food, inventory and held slot; files of players who left since the last save are written (07 §9)
- [ ] T429 [US13-core] Implement player file save and load (load on join) in `core/src/persistence.cob`
- [ ] T430 [P] [US13-core] Write `core/tests/contract_coreapi_provider.cob` cases for `CORE-SAVE` and for `CORE-WORLD-OPEN` of an existing folder (created flag 0)
- [ ] T431 [US13-core] Implement `CORE-SAVE` (every changed chunk, every chunk holding entities, player files, `level.dat`, `access.dat`) and loading an existing world in `CORE-WORLD-OPEN` in `core/src/api.cob` and `core/src/persistence.cob`
- [ ] T432 [P] [US13-core] Write fatal-path test `core/tests/test_world_unreadable.cob` with `core/tests/test_world_unreadable.expect`: an unreadable `level.dat` makes `CORE-WORLD-OPEN` exit through `cc_fatal` naming the file (research R14); and `core/tests/test_save_write_fails.cob` with its `.expect` for a failing write during save
- [ ] T433 [US13-core] Route unreadable world files and failed save writes to `cc_fatal` in `core/src/persistence.cob`
- [ ] T434 [P] [US13-core] Write acceptance test `core/tests/acc_us13_new_world.cob`: case "acceptance US13-1 given no world folder when the world is opened then a new world folder is created and the created flag is 1" (core half; the console lines are the server's)
- [ ] T435 [P] [US13-core] Write acceptance test `core/tests/acc_us13_restore.cob`: case "acceptance US13-4 given a world with block changes, mobs, ground items, weather, time, spawn and access lists in every dimension and players who left in different dimensions when saved and reopened then every one of them is as it was" (FR-014, SC-003 core half)
- [ ] T436 [P] [US13-core] Write acceptance test `core/tests/acc_us13_copy_folder.cob`: case "acceptance US13-5 given a world folder copied to another path when opened there then every dimension, block, player record, mob and ground item is the same"
- [ ] T437 [P] [US13-core] Write acceptance test `core/tests/acc_us13_changed_settings.cob`: case "US13 edge given an existing world and changed settings when opened then the world is kept and the new settings apply"
- [ ] T438 [P] [US13-core] Write acceptance test `core/tests/acc_us13_console_lines.cob`: case "acceptance US13-3 given a running world when a player joins, leaves, dies or changes dimension or chats then `CORE-CONSOLE-DRAIN` yields `<name> joined`, `<name> left`, the death message, `<name> went to <dimension key>` and `<name> message`" (operator-surface §3)
- [ ] T439 [US13-core] Implement the console line queue and the join, leave, death, dimension and chat lines in `core/src/console.cob` with calls from the modules that raise them
- [ ] T440 [US13-core] Extend the core implementation tests to 100 % coverage of the US13 changes
- [ ] T441 Gate: run `make gate-core` and record the command and its real output

#### Phase 24: US14-core — commands

**Goal**: the standin-content §16 command set (FR-016) with permissions, the command tree and suggestions.
**Independent Test**: `make gate-core` with every `acc_us14_*.cob` passing.

- [ ] T442 [US14-core] Create `core/copy/COMMANDS.cpy` (every command of standin-content §16: name, syntax tree, permission, texts) and extend `core/copy/MESSAGES.cpy` with the §16 and §17 texts; extend `core/tests/test_content_tables.cob`
- [ ] T443 [P] [US14-core] Write implementation test `core/tests/test_command_parser.cob`: tokenising a command line and parsing arguments of each parser (integer with bounds, double, single word, greedy phrase, player name), with the §16 error for each malformed argument
- [ ] T444 [US14-core] Implement the command line parser in `core/src/commands.cob`
- [ ] T445 [P] [US14-core] Write implementation test `core/tests/test_command_permission.cob`: console always permitted; chat permitted for everyone-commands, and for operator commands iff the sender holds operator status; host of kinds 1 and 2 holds operator status; guests hold it only when `CS-GUEST-OPERATOR` = 1 (FR-016, data-model §10)
- [ ] T446 [US14-core] Implement permission checking and host operator status in `core/src/commands.cob` and `core/src/access.cob`
- [ ] T447 [P] [US14-core] Write `contract_wire_server.cob` cases: Commands for everyone and for an operator equal `play-s2c-10-commands-everyone.hex` and `-operator.hex`; Command Suggestion and Chat Command decode; Command Suggestions equals its fixture
- [ ] T448 [P] [US14-core] Write acceptance test `core/tests/acc_us14_suggestions.cob`: case "acceptance US14-1 given a player typing the command prefix then the command tree they are sent holds only commands they may use, and argument suggestions offer online player names, dimension names, mob types and item keys"
- [ ] T449 [US14-core] Implement the filtered command tree (sent on join) and Command Suggestion answers in `core/src/commands.cob`
- [ ] T450 [P] [US14-core] Write acceptance test `core/tests/acc_us14_not_permitted.cob`: case "acceptance US14-3 given an operator command and a player without operator status when they run it then nothing happens except the §16 not-permitted message"
- [ ] T451 [P] [US14-core] Write acceptance test `core/tests/acc_us14_errors.cob`: case "acceptance US14-4 unknown command, missing argument and invalid argument each change nothing and send the §16 error with the help hint"; case "US14 edge a named player not online or a dimension that does not exist is reported as not found"
- [ ] T452 [US14-core] Implement Chat Command dispatch with the not-permitted, unknown, invalid-argument and not-found replies in `core/src/commands.cob`
- [ ] T453 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_help.cob`: "acceptance US14-2 the help command lists the commands the sender may use with their usage"
- [ ] T454 [US14-core] Implement the help command in `core/src/commands.cob`
- [ ] T455 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_list.cob`: "acceptance US14-2 the player-list command lists online players"
- [ ] T456 [US14-core] Implement the player-list command in `core/src/commands.cob`
- [ ] T457 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_message.cob`: "acceptance US14-2 the private-message command delivers the text to the named player only and confirms to the sender"
- [ ] T458 [US14-core] Implement the private-message command in `core/src/commands.cob`
- [ ] T459 [P] [US14-core] Write acceptance test `core/tests/acc_us14_op_change.cob`: case "acceptance US14-5 when operator status is granted or revoked the player is told and is sent a new command tree at once"; case "US14/US15 edge an operator revoking their own status, or the last operator losing it, takes effect and the console keeps operator permission"
- [ ] T460 [US14-core] Implement the grant-operator and revoke-operator commands (notice and tree re-send) in `core/src/commands.cob`
- [ ] T461 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_kick.cob`: "acceptance US14-2 the kick command disconnects the named player with the given reason"
- [ ] T462 [US14-core] Implement the kick command in `core/src/commands.cob`
- [ ] T463 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_ban.cob`: cases for ban (disconnects and records), unban and ban list
- [ ] T464 [US14-core] Implement the ban, unban and ban-list commands in `core/src/commands.cob`
- [ ] T465 [P] [US14-core] Write acceptance test `core/tests/acc_us14_ban_login.cob`: case "US2/US14 edge given a banned player when they try to join then Login Disconnect carries the §17 banned text"
- [ ] T466 [US14-core] Implement the banned-login refusal in `core/src/login.cob`
- [ ] T467 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_allowlist.cob`: cases for allow-list on, off, add, remove and list
- [ ] T468 [US14-core] Implement the allow-list commands in `core/src/commands.cob`
- [ ] T469 [P] [US14-core] Write acceptance test `core/tests/acc_us14_allowlist_login.cob`: case "US2/US14 edge given the allow-list enforced (setting or command) when a player not on it joins then Login Disconnect carries the §17 text"
- [ ] T470 [US14-core] Implement the allow-list login refusal in `core/src/login.cob`
- [ ] T471 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_gamemode.cob`: "the game-mode command sets the named player's mode (Game Event 3, abilities, health and food display rules follow)"
- [ ] T472 [US14-core] Implement the game-mode command in `core/src/commands.cob`
- [ ] T473 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_teleport.cob`: cases "to a position in any dimension (Respawn when the dimension changes)" and "to another player"
- [ ] T474 [US14-core] Implement the teleport command (position with dimension, or player) in `core/src/commands.cob`
- [ ] T475 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_give.cob`: "the give command adds the item and count to the named player's inventory"
- [ ] T476 [US14-core] Implement the give command in `core/src/commands.cob`
- [ ] T477 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_clear.cob`: "the clear command empties the named player's inventory"
- [ ] T478 [US14-core] Implement the clear-inventory command in `core/src/commands.cob`
- [ ] T479 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_health.cob`: cases for setting health to a value, to full and to zero (death follows US7-4)
- [ ] T480 [US14-core] Implement the set-health command in `core/src/commands.cob`
- [ ] T481 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_food.cob`: cases for setting food to a value, to full and to zero
- [ ] T482 [US14-core] Implement the set-food command in `core/src/commands.cob`
- [ ] T483 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_spawn_mob.cob`: "the spawn-mob command creates a mob of the given type at the given position and viewers are sent it"
- [ ] T484 [US14-core] Implement the spawn-mob command in `core/src/commands.cob`
- [ ] T485 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_remove.cob`: cases for removing mobs and ground items in an area and of a type
- [ ] T486 [US14-core] Implement the remove-entities command in `core/src/commands.cob`
- [ ] T487 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_time.cob`: "the time command sets the time of day and players are sent Set Time"
- [ ] T488 [US14-core] Implement the time command in `core/src/commands.cob`
- [ ] T489 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_weather.cob`: cases "set a dimension's weather for a duration" and "until changed" (no countdown, US11-4 interplay)
- [ ] T490 [US14-core] Implement the weather command in `core/src/commands.cob`
- [ ] T491 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_setspawn.cob`: "the set-spawn command moves the world spawn point (Set Default Spawn Position to players)"
- [ ] T492 [US14-core] Implement the set-spawn command in `core/src/commands.cob`
- [ ] T493 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_say.cob`: "the server-message command sends the text to every player as the server"
- [ ] T494 [US14-core] Implement the server-message command in `core/src/commands.cob`
- [ ] T495 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_save.cob`: "the save command writes the world now (the files of 07 §9 exist and reload equal)"
- [ ] T496 [US14-core] Implement the save command (calling the `CORE-SAVE` path) in `core/src/commands.cob`
- [ ] T497 [P] [US14-core] Write acceptance test `core/tests/acc_us14_cmd_stop.cob`: "the stop command sets run state 1 (`CORE-STATUS-GET`)"
- [ ] T498 [US14-core] Implement the stop command in `core/src/commands.cob`
- [ ] T499 [US14-core] Extend the core implementation tests to 100 % coverage of the US14 changes
- [ ] T500 Gate: run `make gate-core` and record the command and its real output

#### Phase 25: US15-core — console commands and stopping

**Goal**: `CORE-CONSOLE` and `CORE-STOP` (core-host-api §2). **Independent Test**: `make gate-core`.

- [ ] T501 [P] [US15-core] Write `core/tests/contract_coreapi_provider.cob` cases for `CORE-CONSOLE`, `CORE-STOP` and `CORE-STATUS-GET` run states 0, 1, 2
- [ ] T502 [P] [US15-core] Write acceptance test `core/tests/acc_us15_console.cob`: case "acceptance US15-1 given a running world when a command line is passed to `CORE-CONSOLE` then it runs with operator permission and its result is drained as console lines"; case "acceptance US15-3 an unknown command or bad arguments drains the §16 error and help hint"
- [ ] T503 [US15-core] Implement `CORE-CONSOLE` (console sender, results to the console queue) in `core/src/api.cob` and `core/src/console.cob`
- [ ] T504 [P] [US15-core] Write acceptance test `core/tests/acc_us15_stop.cob`: case "acceptance US15-2 given players and changes when `CORE-STOP` is called with the stopping text then the world is saved, every connection is queued a Disconnect with that text and the run state becomes 2"
- [ ] T505 [US15-core] Implement `CORE-STOP` in `core/src/api.cob`
- [ ] T506 [US15-core] Extend the core implementation tests to 100 % coverage of the US15 changes
- [ ] T507 Gate: run `make gate-core` and record the command and its real output

#### Phase 26: US17-core — opening a single-player world to others

**Goal**: host kind 2 behaviour (FR-016, FR-017). **Independent Test**: `make gate-core`.

- [ ] T508 [P] [US17-core] Write `core/tests/contract_coreapi_provider.cob` case for `CORE-OPEN-TO-OTHERS` (host kind becomes 2; network connections accepted)
- [ ] T509 [P] [US17-core] Write acceptance test `core/tests/acc_us17_guests.cob`: case "acceptance US17-1/US17-2 given a world opened with a guest mode and guest-operator choice when a guest joins over a network connection then they get that mode, the host holds operator status and the guest holds it only if allowed"
- [ ] T510 [US17-core] Implement `CORE-OPEN-TO-OTHERS` and guest mode in `core/src/api.cob` and `core/src/players.cob`
- [ ] T511 [P] [US17-core] Write acceptance test `core/tests/acc_us17_host_name.cob`: case "US17 edge given a guest with the host's name when they log in then Login Disconnect carries the §17 name-in-use text and the host stays"
- [ ] T512 [US17-core] Implement the host-name refusal in `core/src/login.cob`
- [ ] T513 [P] [US17-core] Write acceptance test `core/tests/acc_us17_host_quit.cob`: case "acceptance US17-4 given guests when `CORE-STOP` is called with the host-closed text then the world is saved and every guest is sent that Disconnect"; case "acceptance US17-5 a guest who rejoins after reopening finds position, dimension, inventory, health and food as left"
- [ ] T514 [US17-core] Extend the core implementation tests to 100 % coverage of the US17 changes
- [ ] T515 Gate: run `make gate-core` and record the command and its real output

#### Phase 27: US18-core — server pack offer

**Goal**: Resource Pack Push and the response handling of 08 §9.7. **Independent Test**: `make gate-core`.

- [ ] T516 [P] [US18-core] Write `contract_wire_server.cob` cases: configuration Resource Pack Push (optional and required with prompt) equals its fixtures from settings; every configuration Resource Pack Response decodes; the pack-required configuration Disconnect equals its fixture
- [ ] T517 [P] [US18-core] Write acceptance test `core/tests/acc_us18_offer.cob`: case "acceptance US18-6 given a configured pack when a player configures then Resource Pack Push carries the URL, hash, id, required flag and prompt, and configuration continues after a terminal response"
- [ ] T518 [US18-core] Implement the pack offer and response wait in `core/src/config-phase.cob`
- [ ] T519 [P] [US18-core] Write acceptance test `core/tests/acc_us18_required_declined.cob`: case "acceptance US18-7 given a required pack when the player declines then they are disconnected with the §17 required-pack text"
- [ ] T520 [US18-core] Implement the required-pack disconnect in `core/src/config-phase.cob`
- [ ] T521 [US18-core] Extend the core implementation tests to 100 % coverage of the US18 changes
- [ ] T522 Gate: run `make gate-core` and record the command and its real output

### Lane: server

The server program is split into callable programs so its tests drive it in-process: `SV-START` (configuration,
world open, listen), `SV-ITERATE` (one loop iteration: poll, accept, pump, due ticks, console, drain) and
`SV-SHUTDOWN`; `server/src/main.cob` (`cobolcraft-server`) only calls them (research R6). Console input in
tests comes from a `<test>.stdin` file (runner feature, Phase 1).

#### Phase 28: US2-server — hosting the core on TCP

**Goal**: a server that accepts players with default settings and runs ticks at 20 per second.
**Independent Test**: `make gate-server` — a loopback client connected through `cc_net_*` completes status and
login against `SV-START`/`SV-ITERATE`.

- [ ] T523 [P] [US2-server] Write `server/tests/contract_coreapi_consumer.cob`: `CORE-SETTINGS`, `CORE-BUFFER`, `CORE-STATUS` lengths and constants from `COREAPI.cpy` match core-host-api §1; the host's start sequence (`CORE-WORLD-OPEN` then listen), per-connection pump (`CORE-CONN-OPEN` network, `-INPUT`, `-OUTPUT`, close flag, `-CLOSED`) and tick cadence (one `CORE-TICK` per elapsed 50 ms) follow core-host-api §2
- [ ] T524 [P] [US2-server] Write `server/tests/contract_shim_consumer.cob`: every `CCSHIM.cpy` constant the server uses has its shim-abi value and each `cc_net_*` call links and returns a defined outcome on a minimal loopback call
- [ ] T525 [P] [US2-server] Write implementation test `server/tests/test_tcp_host.cob`: accepted loopback connections are registered as network connections; received bytes reach `CORE-CONN-INPUT`; `CORE-CONN-OUTPUT` bytes are sent including partial sends; the transport closes after a close-flag hand-back is flushed; a peer close calls `CORE-CONN-CLOSED`; a socket error on one connection logs `ERROR connection: <detail>` and serving continues (research R14)
- [ ] T526 [US2-server] Implement the TCP host (listener, connection table, pumps) in `server/src/tcp-host.cob` and add the server sources to `SRC` in `server/Makefile`
- [ ] T527 [P] [US2-server] Write implementation test `server/tests/test_main_loop.cob`: `SV-START` with default `CORE-SETTINGS` (operator-surface §2 defaults) opens `./world` in a scratch directory and listens on the port; `SV-ITERATE` waits on `cc_net_poll` no longer than the time to the next tick, runs every due tick and displays drained console lines
- [ ] T528 [US2-server] Implement `SV-START`, `SV-ITERATE`, `SV-SHUTDOWN` in `server/src/loop.cob` and the `cobolcraft-server` program in `server/src/main.cob`
- [ ] T529 [US2-server] Extend the server implementation tests to 100 % coverage of `server/src` and list every test in `TESTS` of `server/Makefile`
- [ ] T530 Gate: run `make gate-server` (root `Makefile`) and record the command and its real output

#### Phase 29: US13-server — configuration file, ready line, console format

**Goal**: operator-surface §2 and §3. **Independent Test**: `make gate-server` with `acc_us13_*.cob` passing.

- [ ] T531 [P] [US13-server] Write acceptance test `server/tests/acc_us13_config.cob`: case "acceptance US13-2 given a configuration file when the server starts then it uses its settings"; case "given none then it writes `cobolcraft-server.conf` with every non-pack key's default, each preceded by a one-line comment, and uses them"; case "a missing key takes its default"; comment and blank lines ignored
- [ ] T532 [P] [US13-server] Write fatal-path tests `server/tests/test_config_unknown_key.cob` and `server/tests/test_config_bad_value.cob` with `.expect` files: `FATAL configuration: <key>: <problem>`, exit status 1 (operator-surface §2, research R14), one bad-value fixture per key type (port range, game mode, text length, view distance 2–32, booleans)
- [ ] T533 [US13-server] Implement configuration reading, validation and default-file writing for `port`, `default-game-mode`, `description`, `view-distance`, `player-combat`, `hostile-mobs`, `weather-changes`, `extra-dimensions`, `allow-list` into `CORE-SETTINGS` in `server/src/config-file.cob`
- [ ] T534 [P] [US13-server] Write acceptance test `server/tests/acc_us13_ready.cob`: case "acceptance US13-1 given no world folder when the server starts then the console shows `Created new world in ./world` and `Ready: accepting players on 0.0.0.0:<port>`"
- [ ] T535 [US13-server] Implement the created-world and ready lines in `server/src/loop.cob`
- [ ] T536 [P] [US13-server] Write acceptance test `server/tests/acc_us13_console_format.cob`: case "acceptance US13-3 drained console lines are printed with the `[HH:MM:SS] ` prefix"
- [ ] T537 [US13-server] Implement the time-stamped console printing in `server/src/loop.cob`
- [ ] T538 [US13-server] Extend the server implementation tests to 100 % coverage of the US13 changes
- [ ] T539 Gate: run `make gate-server` and record the command and its real output

#### Phase 30: US15-server — console commands and stop

**Goal**: operator-surface §4 and the stop sequence. **Independent Test**: `make gate-server`.

- [ ] T540 [P] [US15-server] Write acceptance test `server/tests/acc_us15_console.cob` with `server/tests/acc_us15_console.stdin` (the §16 player-list command, an unknown command, then end of input): case "acceptance US15-1 a typed command runs with operator permission and its result is printed"; case "acceptance US15-3 an unknown command prints the error and help hint"; case "end of input has no effect on the running server"
- [ ] T541 [US15-server] Implement console input (`cc_con_readline` when `cc_net_poll` reports the console ready, line passed to `CORE-CONSOLE`) in `server/src/console.cob`
- [ ] T542 [P] [US15-server] Write acceptance test `server/tests/acc_us15_stop.cob` with `server/tests/acc_us15_stop.stdin` (the §16 stop command): case "acceptance US15-2 given a connected loopback player when stop is typed then the console shows `Stopping: saving world and disconnecting players`, the player receives the stopping Disconnect, the world files exist, `Stopped` is printed and the loop ends with exit status 0"; and extend `server/tests/contract_coreapi_consumer.cob` with the stop handling of core-host-api §2 (run state 1 → `CORE-STOP` → flush → exit after run state 2)
- [ ] T543 [US15-server] Implement the stop sequence in `server/src/loop.cob`
- [ ] T544 [US15-server] Extend the server implementation tests to 100 % coverage of the US15 changes
- [ ] T545 Gate: run `make gate-server` and record the command and its real output

#### Phase 31: US18-server — pack offer configuration

**Goal**: the `pack-*` keys of operator-surface §2. **Independent Test**: `make gate-server`.

- [ ] T546 [P] [US18-server] Write acceptance test `server/tests/acc_us18_pack_config.cob`: case "acceptance US18-6 given `pack-url`, `pack-sha1`, `pack-id`, `pack-required` and `pack-prompt` when the server starts then `CORE-SETTINGS` offers that pack"; case "an empty `pack-url` means no offer"; the default file now lists the pack keys; and fatal `.expect` tests `server/tests/test_config_bad_pack.cob` for a non-http(s) URL, a hash that is not 40 hex digits and an invalid UUID
- [ ] T547 [US18-server] Implement the pack keys and their validation in `server/src/config-file.cob`
- [ ] T548 [US18-server] Extend the server implementation tests to 100 % coverage of the US18 changes
- [ ] T549 Gate: run `make gate-server` and record the command and its real output

### Lane: client

All client state is one record `CLIENT-STATE` in `client/copy/CLSTATE.cpy` passed `BY REFERENCE` to every client
program (no `EXTERNAL` data), so the Convergence harness can run two client instances in one process (plan
"Test strategy"). `CL-STEP` (`client/src/loop.cob`) advances one frame from a list of input event records and an
elapsed time and produces the screen model and render list (data-model §13); tests call it directly and assert
on those, never on the GPU (research R9). `client/src/main.cob` and `client/src/submit.cob` connect `CL-STEP` to
`cc_win_*` and `cc_vk_*`. Wire behaviour is tested by feeding fixture bytes to the client's protocol code.

#### Phase 32: US2-client — start, server list, join, built-in pack, world rendering

**Goal**: the Player starts the game, manages the server list, joins, and sees the world drawn from the
built-in pack with shading, transparency and light. **Independent Test**: `make gate-client` with
`acc_us2_server_list.cob`, `acc_us2_render.cob` and `acc_us2_textures.cob` passing.

- [ ] T550 [US2-client] Create `client/copy/CLSTATE.cpy` (screen model, input state, connection state, world replica, local player, packs, atlases, render list, per data-model §13) and `client/copy/CLCONST.cpy` (screen ids, pipeline and texture ids used by the client)
- [ ] T551 [P] [US2-client] Write `client/tests/contract_shim_consumer.cob`: every `CCSHIM.cpy` constant, the 24-byte event record and the 28-byte vertex have their shim-abi values and lengths; `cc_net_*`, `cc_deflate`, `cc_inflate` link and return defined outcomes on minimal calls (window and Vulkan calls are covered by `client/tests/test_submit.cob`)
- [ ] T552 [P] [US2-client] Write implementation test `client/tests/test_args.cob` for `--name` and `--gamedir` (default `$HOME/.cobolcraft`), and fatal-path tests `client/tests/test_args_missing.cob`/`test_args_invalid.cob` with `.expect` files (`FATAL arguments: …`, exit 1) (client-surface §1, research R14)
- [ ] T553 [US2-client] Implement argument parsing in `client/src/args.cob` and add the client sources to `SRC` in `client/Makefile`
- [ ] T554 [P] [US2-client] Write implementation test `client/tests/test_game_dir.cob`: the game directory and `resourcepacks/`, `saves/`, `downloads/` are created when absent (client-surface §2)
- [ ] T555 [US2-client] Implement game directory set-up in `client/src/game-dir.cob`
- [ ] T556 [P] [US2-client] Write implementation test `client/tests/test_datfile.cob`: gzip NBT file write and read round trip; an unreadable data file is fatal (`.expect` test `client/tests/test_datfile_unreadable.cob`, research R14)
- [ ] T557 [US2-client] Implement gzip NBT file read and write in `client/src/datfile.cob`
- [ ] T558 [P] [US2-client] Write implementation test `client/tests/test_servers_dat.cob`: `servers.dat` `Servers` list of `{Name, Address, PackPolicy}` round-trips (client-surface §2)
- [ ] T559 [US2-client] Implement `servers.dat` load and save in `client/src/game-dir.cob`
- [ ] T560 [P] [US2-client] Write implementation test `client/tests/test_input.cob`: event records of every kind 1 to 9 update the input state (keys held, text code points including non-ASCII, buttons, cursor delta while captured, scroll, resize, close)
- [ ] T561 [US2-client] Implement input decoding in `client/src/input.cob`
- [ ] T562 [P] [US2-client] Write implementation test `client/tests/test_json.cob`: objects, arrays, strings with escapes and `\u` (surrogate pairs), numbers, booleans, null, path lookup, malformed input reported as an error value
- [ ] T563 [US2-client] Implement the JSON parser in `client/src/json.cob`
- [ ] T564 [P] [US2-client] Write acceptance test `client/tests/acc_us2_textures.cob`: case "SC-004 every built-in block texture and the font atlas equal `tools/fixtures/textures/<name>.rgba` pixel for pixel"
- [ ] T565 [US2-client] Implement the built-in block texture generator (standin-content §1.4 recipes with the exact noise hash) in `client/src/packs/builtin.cob`
- [ ] T566 [US2-client] Implement the built-in font atlas (standin-content §18 glyphs) in `client/src/packs/builtin.cob`
- [ ] T567 [P] [US2-client] Write implementation test `client/tests/test_builtin_files.cob`: the built-in pack serves `pack.mcmeta`, the atlas definitions, template and block models, block state files, `font/default.json` and `lang/en_us.json` with the contents of 08 §10
- [ ] T568 [US2-client] Implement the built-in pack's JSON files (08 §10.1, §10.2, §10.4 to §10.6, font, lang) in `client/src/packs/builtin.cob`
- [ ] T569 [P] [US2-client] Write implementation test `client/tests/test_pack_stack.cob`: a path is resolved from the top-most pack that has it; with only the built-in pack every built-in path resolves and an absent path is "missing"
- [ ] T570 [US2-client] Implement the pack source abstraction in `client/src/packs/source.cob` and stack resolution in `client/src/packs/stack.cob`
- [ ] T571 [P] [US2-client] Write implementation test `client/tests/test_lang.cob`: lang keys resolve to `en_us` text; a missing key shows the key itself as 08 §10.8 states
- [ ] T572 [US2-client] Implement language loading in `client/src/packs/lang.cob`
- [ ] T573 [P] [US2-client] Write implementation test `client/tests/test_font.cob`: the `bitmap` provider maps code points 32–126 to glyph cells and advances; other code points use the §18 missing-glyph rule
- [ ] T574 [US2-client] Implement the bitmap font provider in `client/src/packs/font.cob`
- [ ] T575 [P] [US2-client] Write implementation test `client/tests/test_blockstates.cob`: variant keys and multipart cases of 08 §4 select models and rotations for every block state of standin-content §1.2
- [ ] T576 [US2-client] Implement block state file resolution in `client/src/packs/blockstates.cob`
- [ ] T577 [P] [US2-client] Write implementation test `client/tests/test_models.cob`: parent resolution (08 §5.2), `#` texture references (§5.3), elements and faces (§5.4, §5.5), the element rotation rule and default UV formula of 08's answered Open questions 4 and 6, baked into quads per block state
- [ ] T578 [US2-client] Implement model loading and baking in `client/src/models.cob`
- [ ] T579 [P] [US2-client] Write implementation test `client/tests/test_atlas.cob`: sprites are stitched into the block atlas with UV lookup by sprite id; the missing-texture stripes sprite is generated by the client (standin-content §1.4) and used for every unresolved sprite
- [ ] T580 [US2-client] Implement atlas stitching and the missing-texture sprite in `client/src/atlas.cob`
- [ ] T581 [P] [US2-client] Write `client/tests/contract_wire_client.cob` status and login cases: Intention, Status Request, Ping Request, Hello and Login Acknowledged encode equal to their fixtures; Status Response, Pong, Set Compression, Login Finished and Login Disconnect decode to the stated values
- [ ] T582 [US2-client] Implement the client status ping and login in `client/src/protocol-client.cob` (name from `--name`, compression after Set Compression)
- [ ] T583 [P] [US2-client] Write `contract_wire_client.cob` configuration cases: brand, Client Information, Select Known Packs, Finish Configuration and Keep Alive encode equal to their fixtures; every configuration clientbound fixture including each Registry Data decodes
- [ ] T584 [US2-client] Implement configuration handling (registry storage, known packs answer, tags, keep-alive echo, finish) in `client/src/protocol-client.cob`
- [ ] T585 [P] [US2-client] Write `contract_wire_client.cob` play-join cases: Accept Teleportation, Chunk Batch Received, Player Loaded, Client Tick End and Keep Alive encode equal to their fixtures; Login, Game Event 13, Player Position, Player Abilities, spawn position, Set Time, held slot, inventory, chunk batch and Level Chunk With Light decode
- [ ] T586 [US2-client] Implement the play join handling in `client/src/protocol-client.cob` (teleport accept, batch acknowledgement, Player Loaded, Client Tick End each tick, disconnect packets returning to the server list with their message)
- [ ] T587 [P] [US2-client] Write implementation test `client/tests/test_net_client.cob` against a loopback listener opened by the test with `cc_net_*` that serves fixture bytes: address parsing (`host`, `host:port`, default 25565), non-blocking connect and pump, a refused connection or unresolved host logs `ERROR connection: <detail>` and returns to the server list (research R14)
- [ ] T588 [US2-client] Implement the network connection in `client/src/net-client.cob`
- [ ] T589 [P] [US2-client] Write implementation test `client/tests/test_world_replica.cob`: chunks decoded with `CHUNK-SECTION-DECODE`/`LIGHT-DECODE` are stored per position; block and light lookup; unknown state ids decode as void (standin-content §1.2)
- [ ] T590 [US2-client] Implement the world replica in `client/src/world-replica.cob`
- [ ] T591 [P] [US2-client] Write implementation test `client/tests/test_mesher.cob`: faces against opaque neighbours are culled; lucite–lucite faces culled and lucite against opaque drawn on the lucite side only (standin-content §1.1); per-face brightness top 1.0, north/south 0.8, east/west 0.6, bottom 0.5 × max(sky × daylight, block light)/15 with floor 0.1 (data-model §13); translucent faces in a separate mesh
- [ ] T592 [US2-client] Implement section meshing in `client/src/mesher.cob`
- [ ] T593 [P] [US2-client] Write implementation test `client/tests/test_sky.cob`: sky colour and daylight factor as a function of the time of day over the §4.8 day length (as the extension or 08 states)
- [ ] T594 [US2-client] Implement sky colour and daylight factor in `client/src/sky.cob`
- [ ] T595 [P] [US2-client] Write implementation test `client/tests/test_render_list.cob`: perspective and view matrices from the local player's position, yaw and pitch; opaque draws then translucent draws back to front by section; changed meshes listed as uploads; UI draws last; clear colour from the sky
- [ ] T596 [US2-client] Implement the render list builder in `client/src/render-list.cob`
- [ ] T597 [P] [US2-client] Write implementation test `client/tests/test_ui_render.cob`: text from the pack font and lang, buttons, text fields and lists of the screen model become UI-pipeline vertices on texture 2
- [ ] T598 [US2-client] Implement the 2-D UI renderer in `client/src/ui-render.cob`
- [ ] T599 [P] [US2-client] Write acceptance test `client/tests/acc_us2_server_list.cob`: case "acceptance US2-1 given the client started when the Player adds, edits and removes server entries then the list shows them and after a restart (new `CLIENT-STATE`, same game directory) the entries are still there"
- [ ] T600 [US2-client] Implement the title screen (multiplayer and quit) in `client/src/screens/title.cob`
- [ ] T601 [US2-client] Implement the server list and edit-server screens (add, edit, remove, join, last disconnect message, status ping per entry showing description, online count and incompatible protocol) in `client/src/screens/server-list.cob` and `client/src/screens/edit-server.cob`
- [ ] T602 [US2-client] Implement the connecting screen in `client/src/screens/connecting.cob`
- [ ] T603 [P] [US2-client] Write acceptance test `client/tests/acc_us2_render.cob`: given the replica holds `play-s2c-2e-level-chunk-with-light-spawn.hex` and the player at the spawn: case "acceptance US2-4 every visible block face is drawn with its built-in sprite and per-face shading"; case "lucite faces are in the translucent draw and blocks behind it are drawn"; case "faces near the lit glowtube are brighter than the same faces far from it"
- [ ] T604 [P] [US2-client] Write implementation test `client/tests/test_pause.cob`: Escape in the world opens the pause menu; its disconnect control closes the connection and returns to the server list (US2-5 client half)
- [ ] T605 [US2-client] Implement the pause menu with the disconnect control in `client/src/screens/pause.cob`
- [ ] T606 [P] [US2-client] Write implementation test `client/tests/test_loop.cob`: `CL-STEP` routes events to the current screen or to world controls, pumps the connection without waiting, re-meshes changed sections and produces the screen model and render list each frame
- [ ] T607 [US2-client] Implement `CL-STEP` and `CL-RUN` in `client/src/loop.cob`
- [ ] T608 [P] [US2-client] Write implementation test `client/tests/test_submit.cob` against the real window and MoltenVK (no test double, research R9): atlases uploaded through `cc_vk_texture`, meshes through `cc_vk_mesh`, draws in render-list order, and a run of `CL-RUN` ending through the window's close-requested event
- [ ] T609 [US2-client] Implement render-list submission in `client/src/submit.cob` and the `cobolcraft` program (arguments, game directory, window, Vulkan, `CL-RUN`) in `client/src/main.cob`
- [ ] T610 [US2-client] Extend the client implementation tests to 100 % coverage of the US2 client sources and list every test in `TESTS` of `client/Makefile`
- [ ] T611 Gate: run `make gate-client` (root `Makefile`) and record the command and its real output

#### Phase 33: US3-client — moving, looking, streaming, other players, day and night

**Goal**: controls and physics of client-surface §3, chunk loading and forgetting, other players as operator
figures, the day cycle. **Independent Test**: `make gate-client` with every `acc_us3_*.cob` passing.

- [ ] T612 [P] [US3-client] Write `contract_wire_client.cob` cases: Move Player Pos/PosRot/Rot/Status Only and Player Abilities encode equal to their fixtures; Add Entity (operator), Player Info Update/Remove, Move Entity Pos/PosRot/Rot, Rotate Head, Teleport Entity, Remove Entities, Forget Level Chunk and Set Chunk Cache Center decode
- [ ] T613 [P] [US3-client] Write acceptance test `client/tests/acc_us3_movement.cob`: case "acceptance US3-1 given the Player in the world when W, S, A, D, mouse movement and Space are used then they walk forward, back and sideways, turn, look up and down and jump"
- [ ] T614 [US3-client] Implement walking, looking and jumping in `client/src/physics.cob`
- [ ] T615 [P] [US3-client] Write acceptance test `client/tests/acc_us3_collision.cob`: case "acceptance US3-2 given a solid block ahead when walking into it then the Player does not pass through"; case "with no block beneath then they fall until they land"
- [ ] T616 [US3-client] Implement collision against the replica and gravity in `client/src/physics.cob`
- [ ] T617 [P] [US3-client] Write acceptance test `client/tests/acc_us3_fly.cob`: case "acceptance US3-3 given creative when Space is pressed twice within 0.3 s then they fly, Space rises, Left Shift descends, and the same double press stops flying" (Player Abilities sent)
- [ ] T618 [US3-client] Implement flying in `client/src/physics.cob`
- [ ] T619 [P] [US3-client] Write implementation test `client/tests/test_movement_packets.cob`: each tick the client sends the Move Player variant matching what changed, and applies server Player Position corrections with Accept Teleportation
- [ ] T620 [US3-client] Implement movement packet sending and corrections in `client/src/protocol-client.cob`
- [ ] T621 [P] [US3-client] Write acceptance test `client/tests/acc_us3_view_distance.cob`: case "acceptance US3-4 client half: chunks received are meshed and drawn and chunks forgotten are no longer drawn and their mesh slots are freed"
- [ ] T622 [US3-client] Implement chunk forgetting and mesh slot release in `client/src/world-replica.cob` and `client/src/render-list.cob`
- [ ] T623 [P] [US3-client] Write implementation test `client/tests/test_entities_replica.cob`: add, move (delta and teleport), rotate head and remove of entities; player names from Player Info
- [ ] T624 [US3-client] Implement the entity replica in `client/src/entities-replica.cob`
- [ ] T625 [P] [US3-client] Write acceptance test `client/tests/acc_us3_other_players.cob`: case "acceptance US3-5 client half: an added operator entity is drawn as the standin-content §3 figure at its position facing its yaw, follows moves, and disappears when removed"; and the operator texture equals `tools/fixtures/textures/operator.rgba` (SC-004)
- [ ] T626 [US3-client] Implement the built-in operator entity texture in `client/src/packs/builtin.cob` and entity drawing of the operator figure on texture 1 (08 §10 entity section) in `client/src/entities-render.cob`
- [ ] T627 [P] [US3-client] Write acceptance test `client/tests/acc_us3_sky.cob`: case "acceptance US3-6 given Set Time over a full §4.8 day length then the sky goes through day and night and the daylight factor follows"
- [ ] T628 [US3-client] Extend the client implementation tests to 100 % coverage of the US3 changes
- [ ] T629 Gate: run `make gate-client` and record the command and its real output

#### Phase 34: US4-client — aiming, placing, breaking, hotbar and inventory

**Goal**: the US4 controls, block updates and the inventory screen. **Independent Test**: `make gate-client`.

- [ ] T630 [P] [US4-client] Write `contract_wire_client.cob` cases: Player Action start/abort/stop destroy, Use Item On, Set Carried Item, Container Click and Set Creative Mode Slot encode equal to their fixtures; Block Update, Section Blocks Update, Block Changed Ack, Block Destruction, Container Set Content, Container Set Slot, Set Player Inventory, Set Held Slot and Light Update decode
- [ ] T631 [P] [US4-client] Write acceptance test `client/tests/acc_us4_highlight.cob`: case "acceptance US4-1 given the Player looks at a block within reach then that block is highlighted in the render list and the targeted face is known"
- [ ] T632 [US4-client] Implement block ray-casting in `client/src/raycast.cob` and the target highlight draw in `client/src/render-list.cob`
- [ ] T633 [P] [US4-client] Write acceptance test `client/tests/acc_us4_controls.cob`: case "US4-2 client half: right button on a face with a block item sends Use Item On with that face"; case "US4-3/US4-4 client half: holding the left button sends start destroy and, in survival, stop destroy after the break time (abort when released early)"; case "US4-5 client half: right button on a glowtube without a block item sends Use Item On"
- [ ] T634 [US4-client] Implement the break, place and use controls in `client/src/controls.cob`
- [ ] T635 [P] [US4-client] Write acceptance test `client/tests/acc_us4_block_updates.cob`: case "US4-7 client half: Block Update, Section Blocks Update and Light Update change the replica and the affected sections are re-meshed"
- [ ] T636 [US4-client] Implement block and light updates in `client/src/world-replica.cob`
- [ ] T637 [P] [US4-client] Write implementation test `client/tests/test_inventory_replica.cob`: Container Set Content, Container Set Slot, Set Player Inventory and Set Held Slot keep the 36 slots and the held slot
- [ ] T638 [US4-client] Implement the inventory replica in `client/src/inventory-replica.cob`
- [ ] T639 [P] [US4-client] Write implementation test `client/tests/test_itemdefs.cob`: item model definitions of 08 §6 and the generated item model of 08 §5.7 give each item its icon sprite; block items use the block texture of standin-content §2
- [ ] T640 [US4-client] Implement item definitions and the item atlas in `client/src/packs/itemdefs.cob`
- [ ] T641 [P] [US4-client] Write acceptance test `client/tests/acc_us4_item_icons.cob`: case "SC-004 every built-in item icon equals `tools/fixtures/textures/item_<name>.rgba`"
- [ ] T642 [US4-client] Implement the built-in item icons (standin-content §2, §11, §13, §15 recipes) and item definitions (08 §10.7) in `client/src/packs/builtin.cob`
- [ ] T643 [P] [US4-client] Write acceptance test `client/tests/acc_us4_inventory_screen.cob`: case "acceptance US4-6 given an inventory when E opens the inventory screen then items and counts are shown; keys 1–9 and the scroll wheel choose the held hotbar slot (Set Carried Item); clicking slots moves items (Container Click)"
- [ ] T644 [US4-client] Implement the hotbar HUD and crosshair in `client/src/screens/hud.cob` and the inventory screen in `client/src/screens/inventory.cob`
- [ ] T645 [US4-client] Extend the client implementation tests to 100 % coverage of the US4 changes
- [ ] T646 Gate: run `make gate-client` and record the command and its real output

#### Phase 35: US5-client — ground items and throwing

**Goal**: ground items drawn as item icons; the throw controls. **Independent Test**: `make gate-client`.

- [ ] T647 [P] [US5-client] Write `contract_wire_client.cob` cases: Player Action drop item and drop all items encode equal to their fixtures; Add Entity (loose_item), Set Entity Data (item), Set Entity Motion and Take Item Entity decode
- [ ] T648 [P] [US5-client] Write acceptance test `client/tests/acc_us5_ground_item.cob`: case "acceptance US5-1 client half: a loose_item is drawn as its item's icon billboard at its position and follows its motion until it rests; Take Item Entity and Remove Entities remove it"
- [ ] T649 [US5-client] Implement ground items in `client/src/entities-replica.cob` and their billboard drawing in `client/src/entities-render.cob`
- [ ] T650 [P] [US5-client] Write acceptance test `client/tests/acc_us5_throw.cob`: case "acceptance US5-3 client half: Q sends drop item and Ctrl+Q sends drop all items for the held slot"
- [ ] T651 [US5-client] Implement the throw controls in `client/src/controls.cob`
- [ ] T652 [US5-client] Extend the client implementation tests to 100 % coverage of the US5 changes
- [ ] T653 Gate: run `make gate-client` and record the command and its real output

#### Phase 36: US6-client — chat

**Goal**: typing and reading chat (US6). **Independent Test**: `make gate-client`.

- [ ] T654 [P] [US6-client] Write `contract_wire_client.cob` cases: Chat encodes equal to `play-c2s-09-chat.hex` (no signature); System Chat decodes
- [ ] T655 [P] [US6-client] Write acceptance test `client/tests/acc_us6_chat_send.cob`: case "acceptance US6-1 client half: T opens chat, typed characters (kind 3 events, including a non-ASCII letter) build the line, Enter sends Chat and closes chat"
- [ ] T656 [US6-client] Implement the chat input screen in `client/src/screens/chat.cob`
- [ ] T657 [P] [US6-client] Write acceptance test `client/tests/acc_us6_chat_area.cob`: case "acceptance US6-2 given received messages then the chat area shows recent ones in order and, with chat open, the Player scrolls back through earlier ones"
- [ ] T658 [US6-client] Implement the chat area and scroll-back in `client/src/screens/hud.cob` and `client/src/screens/chat.cob`
- [ ] T659 [US6-client] Extend the client implementation tests to 100 % coverage of the US6 changes
- [ ] T660 Gate: run `make gate-client` and record the command and its real output

#### Phase 37: US7-client — health display, hurt feedback, death screen, attacking

**Goal**: the Player's side of US7. **Independent Test**: `make gate-client`.

- [ ] T661 [P] [US7-client] Write `contract_wire_client.cob` cases: Attack and Client Command (respawn) encode equal to their fixtures; Set Health, Damage Event, Hurt Animation, Player Combat Kill and Respawn decode
- [ ] T662 [P] [US7-client] Write acceptance test `client/tests/acc_us7_health_hud.cob`: case "acceptance US7-1 given survival then current and maximum health are shown"; case "acceptance US7-6 given creative then no health is shown"
- [ ] T663 [US7-client] Implement the health display in `client/src/screens/hud.cob`
- [ ] T664 [P] [US7-client] Write acceptance test `client/tests/acc_us7_hurt.cob`: case "acceptance US7-2 client half: Damage Event or Hurt Animation for the local player shows the hurt indication in the screen model"
- [ ] T665 [US7-client] Implement the hurt indication in `client/src/screens/hud.cob`
- [ ] T666 [P] [US7-client] Write acceptance test `client/tests/acc_us7_death_screen.cob`: case "acceptance US7-4 client half: Player Combat Kill opens the death screen with the cause; the respawn control sends Client Command action 0; Respawn returns to the world"
- [ ] T667 [US7-client] Implement the death screen in `client/src/screens/death.cob` and Respawn handling in `client/src/protocol-client.cob`
- [ ] T668 [P] [US7-client] Write acceptance test `client/tests/acc_us7_attack.cob`: case "acceptance US7-5 client half: the left button aimed at a player or mob entity within reach sends Attack with its entity id"
- [ ] T669 [US7-client] Implement entity ray-casting in `client/src/raycast.cob` and the attack control in `client/src/controls.cob`
- [ ] T670 [US7-client] Extend the client implementation tests to 100 % coverage of the US7 changes
- [ ] T671 Gate: run `make gate-client` and record the command and its real output

#### Phase 38: US8-client — food display and eating

**Goal**: the Player's side of US8. **Independent Test**: `make gate-client`.

- [ ] T672 [P] [US8-client] Write `contract_wire_client.cob` cases: Use Item and Player Action release-use-item encode equal to their fixtures; Entity Event decodes
- [ ] T673 [P] [US8-client] Write acceptance test `client/tests/acc_us8_food_hud.cob`: case "acceptance US8-1 given survival then the food level is shown beside health"; case "acceptance US8-6 given creative then it is not shown"
- [ ] T674 [US8-client] Implement the food display in `client/src/screens/hud.cob`
- [ ] T675 [P] [US8-client] Write acceptance test `client/tests/acc_us8_eat_control.cob`: case "acceptance US8-3 client half: holding the right button with a food item sends Use Item"; case "US8 edge releasing early sends release-use-item"
- [ ] T676 [US8-client] Implement the eat control in `client/src/controls.cob`
- [ ] T677 [US8-client] Extend the client implementation tests to 100 % coverage of the US8 changes
- [ ] T678 Gate: run `make gate-client` and record the command and its real output

#### Phase 39: US9-client — mobs

**Goal**: mobs drawn from the pack. **Independent Test**: `make gate-client`.

- [ ] T679 [P] [US9-client] Write `contract_wire_client.cob` cases: Add Entity for each mob type decodes to its entity type
- [ ] T680 [P] [US9-client] Write acceptance test `client/tests/acc_us9_mob_render.cob`: case "acceptance US9-1 client half: each mob type is drawn with its standin-content §12 box geometry and the active pack's `textures/entity/<mob>.png`, at its position and facing, following moves"; case "SC-004 each built-in mob texture equals its `tools/fixtures/textures/` reference"
- [ ] T681 [US9-client] Implement the built-in mob textures in `client/src/packs/builtin.cob`
- [ ] T682 [US9-client] Implement mob geometry and drawing in `client/src/entities-render.cob`
- [ ] T683 [US9-client] Extend the client implementation tests to 100 % coverage of the US9 changes
- [ ] T684 Gate: run `make gate-client` and record the command and its real output

#### Phase 40: US10-client — crafting screen

**Goal**: the Player's side of US10. **Independent Test**: `make gate-client`.

- [ ] T685 [P] [US10-client] Write `contract_wire_client.cob` cases: Place Recipe encodes equal to its fixture; Recipe Book Add decodes every recipe with its craftable flag
- [ ] T686 [P] [US10-client] Write acceptance test `client/tests/acc_us10_crafting_screen.cob`: case "acceptance US10-1 client half: C opens the crafting screen listing every recipe with ingredients and result, craftable ones marked"; case "US10-2 client half: choosing a craftable recipe sends Place Recipe with its display id"
- [ ] T687 [US10-client] Implement the recipe book replica in `client/src/protocol-client.cob` and the crafting screen in `client/src/screens/crafting.cob`
- [ ] T688 [US10-client] Extend the client implementation tests to 100 % coverage of the US10 changes
- [ ] T689 Gate: run `make gate-client` and record the command and its real output

#### Phase 41: US11-client — weather drawing

**Goal**: the Player's side of US11. **Independent Test**: `make gate-client`.

- [ ] T690 [P] [US11-client] Write `contract_wire_client.cob` cases: Game Event 1, 2, 7, 8 decode to the weather kind of each §14 pair
- [ ] T691 [P] [US11-client] Write acceptance test `client/tests/acc_us11_weather_render.cob`: case "acceptance US11-1 client half: each kind is drawn as §14 describes (sky tint and weather geometry with its environment texture) only in biomes where it applies"; case "US11 edge in a dimension without weather nothing is drawn"; case "SC-004 each built-in environment texture equals its reference"
- [ ] T692 [US11-client] Implement the built-in environment textures in `client/src/packs/builtin.cob`
- [ ] T693 [US11-client] Implement weather state from the Game Event pair and weather drawing on texture 3 in `client/src/weather-render.cob`
- [ ] T694 [US11-client] Extend the client implementation tests to 100 % coverage of the US11 changes
- [ ] T695 Gate: run `make gate-client` and record the command and its real output

#### Phase 42: US12-client — changing dimension

**Goal**: the Player's side of US12. **Independent Test**: `make gate-client`.

- [ ] T696 [P] [US12-client] Write `contract_wire_client.cob` cases: Respawn for every extra dimension decodes with its dimension type
- [ ] T697 [P] [US12-client] Write acceptance test `client/tests/acc_us12_dimension_change.cob`: case "acceptance US12-1 client half: Respawn into another dimension drops the old replica and its meshes, adopts the new dimension type's height range, light and sky, and keeps inventory, health, food and mode on screen"
- [ ] T698 [US12-client] Implement dimension change handling in `client/src/protocol-client.cob` and `client/src/world-replica.cob`
- [ ] T699 [US12-client] Extend the client implementation tests to 100 % coverage of the US12 changes
- [ ] T700 Gate: run `make gate-client` and record the command and its real output

#### Phase 43: US14-client — commands from the chat line

**Goal**: the Player's side of US14. **Independent Test**: `make gate-client`.

- [ ] T701 [P] [US14-client] Write `contract_wire_client.cob` cases: Command Suggestion and Chat Command encode equal to their fixtures; Commands and Command Suggestions decode
- [ ] T702 [P] [US14-client] Write acceptance test `client/tests/acc_us14_suggestions.cob`: case "acceptance US14-1 client half: `/` opens chat with `/` typed; command names matching the typed prefix are suggested from the received command tree; for an `ask_server` argument the client sends Command Suggestion and shows the answers"
- [ ] T703 [US14-client] Implement the command tree replica and suggestion display in `client/src/screens/chat.cob`
- [ ] T704 [P] [US14-client] Write acceptance test `client/tests/acc_us14_command_send.cob`: case "Enter on a line starting with `/` sends Chat Command without the slash and the System Chat reply appears in the chat area"
- [ ] T705 [US14-client] Implement command sending in `client/src/screens/chat.cob`
- [ ] T706 [US14-client] Extend the client implementation tests to 100 % coverage of the US14 changes
- [ ] T707 Gate: run `make gate-client` and record the command and its real output

#### Phase 44: US16-client — single-player worlds

**Goal**: the world list, the in-process host and pausing (R7). **Independent Test**: `make gate-client`.

- [ ] T708 [P] [US16-client] Write `client/tests/contract_coreapi_consumer.cob`: `COREAPI.cpy` record lengths and constants match core-host-api §1; the single-player host's call sequence (`CORE-WORLD-OPEN` with host kind 1, host name and mode; `CORE-CONN-OPEN` memory; input/output pumping; `CORE-TICK` per elapsed 50 ms; `CORE-STOP` on quit) follows core-host-api §2
- [ ] T709 [P] [US16-client] Write implementation test `client/tests/test_sp_host.cob`: opening a world runs the in-process core over a memory connection without compression; ticks run once per elapsed 50 ms; no ticks while the pause menu is open and the world is not opened to others; quitting calls `CORE-STOP` and returns to the menu
- [ ] T710 [US16-client] Implement the single-player host in `client/src/sp-host.cob` and the memory-connection path in `client/src/net-client.cob`
- [ ] T711 [P] [US16-client] Write acceptance test `client/tests/acc_us16_folder_naming.cob`: case "US16 edge given a world named like an existing one when created then a new folder with ` (2)` (then ` (3)`) is used and both appear in the list"; characters outside `A-Z a-z 0-9 _ - space` become `_` (client-surface §2)
- [ ] T712 [US16-client] Implement world folder naming in `client/src/game-dir.cob`
- [ ] T713 [P] [US16-client] Write implementation test `client/tests/test_world_list.cob`: `saves/` is listed with `cc_fs_list`, each entry shows `LevelName` from `level.dat` and the folder name; create (name and mode), open and delete-after-confirm controls lead to the right screens and calls
- [ ] T714 [US16-client] Implement the single-player button on the title screen and the world list, create-world and confirm-delete screens in `client/src/screens/title.cob`, `client/src/screens/world-list.cob`, `client/src/screens/create-world.cob` and `client/src/screens/confirm-delete.cob`
- [ ] T715 [P] [US16-client] Write implementation test `client/tests/test_delete_world.cob`: recursive deletion of a world folder with `cc_fs_list`, `CBL_DELETE_FILE` and `CBL_DELETE_DIR`
- [ ] T716 [US16-client] Implement recursive world deletion in `client/src/game-dir.cob`
- [ ] T717 [US16-client] Add the quit-world control (save through `CORE-STOP`, back to the menu) to `client/src/screens/pause.cob`
- [ ] T718 [US16-client] Extend the client implementation tests to 100 % coverage of the US16 changes
- [ ] T719 Gate: run `make gate-client` and record the command and its real output

#### Phase 45: US17-client — opening the world to others

**Goal**: the host's side of US17. **Independent Test**: `make gate-client`.

- [ ] T720 [P] [US17-client] Write implementation test `client/tests/test_open_to_others.cob`: the pause menu's open-to-others screen takes the guest game mode and guest-operator choice, calls `CORE-OPEN-TO-OTHERS`, listens with `cc_net_listen(0)` and shows `<address>:<port>` for each address of `cc_net_local_addresses`; afterwards the pause menu no longer stops ticks
- [ ] T721 [US17-client] Implement the open-to-others screen in `client/src/screens/open-to-others.cob` and the pause rule change in `client/src/sp-host.cob`
- [ ] T722 [P] [US17-client] Write implementation test `client/tests/test_host_network.cob`: guest TCP connections are accepted, registered as network connections and pumped every frame; closing them calls `CORE-CONN-CLOSED`; quitting calls `CORE-STOP` with the §17 host-closed text and closes every guest after flushing
- [ ] T723 [US17-client] Implement guest connection hosting in `client/src/sp-host.cob`
- [ ] T724 [US17-client] Extend the client implementation tests to 100 % coverage of the US17 changes
- [ ] T725 Gate: run `make gate-client` and record the command and its real output

#### Phase 46: US18-client — resource packs

**Goal**: local packs (08 §1 to §7), the pack screen and server-pushed packs (08 §9). **Independent Test**:
`make gate-client` with every `acc_us18_*.cob` passing (downloads against `tools/testsrv/testsrv.py`, HTTPS with
`SSL_CERT_FILE` set to the test CA).

- [ ] T726 [P] [US18-client] Write implementation test `client/tests/test_zip.cob`: central directory reading, stored and deflated entries (`cc_inflate` mode `CC_RAW`), a corrupt archive reported as unreadable (08 §1.1)
- [ ] T727 [US18-client] Implement zip reading in `client/src/zip.cob`
- [ ] T728 [P] [US18-client] Write implementation test `client/tests/test_png.cob`: decoding of every PNG colour type and bit depth 08 §7.1 accepts, all five filter types, interlacing as 08 states, and rejection of an unreadable file
- [ ] T729 [US18-client] Implement PNG decoding in `client/src/png.cob`
- [ ] T730 [P] [US18-client] Write implementation test `client/tests/test_mcmeta.cob`: `pack.mcmeta` `pack` section, version compatibility (compatible, too old, too new, unknown; 08 §2.1 to §2.3), overlays (§1.5, §2.4), `filter` (§3.3), `language` (§2.5), `features` (§2.6)
- [ ] T731 [US18-client] Implement `pack.mcmeta` parsing and compatibility in `client/src/packs/mcmeta.cob`
- [ ] T732 [P] [US18-client] Write implementation test `client/tests/test_local_packs.cob`: `resourcepacks/` zips and folders listed with id `file/<name>`; folder and zip sources serve their files; `options.dat` `EnabledPacks` round-trips
- [ ] T733 [US18-client] Implement local pack discovery and folder/zip sources in `client/src/packs/local.cob` and `client/src/packs/source.cob`, and `options.dat` load and save in `client/src/game-dir.cob`
- [ ] T734 [P] [US18-client] Write acceptance test `client/tests/acc_us18_pack_list.cob`: case "acceptance US18-1 given packs in the packs folder when the pack screen opens then each is listed with description, icon if present, and compatible, too old, too new or unknown"
- [ ] T735 [US18-client] Implement the pack selection screen listing in `client/src/screens/pack-select.cob` and its title-screen entry in `client/src/screens/title.cob`
- [ ] T736 [P] [US18-client] Write acceptance test `client/tests/acc_us18_pack_order.cob`: case "acceptance US18-2 given several enabled packs in an order then a higher pack's file wins, the built-in pack stays at the bottom, and the choice and order are kept after a restart"; case "US18 edge a pack with only some files falls through to the packs below for the rest"
- [ ] T737 [US18-client] Implement enabling and ordering in `client/src/screens/pack-select.cob` and stack ordering with overlays and filters in `client/src/packs/stack.cob`
- [ ] T738 [P] [US18-client] Write acceptance test `client/tests/acc_us18_override.cob`: case "acceptance US18-3 given a pack replacing one block state file, model, item definition, texture or lang entry then only what that file affects changes"; case "SC-005 replacing exactly one texture changes exactly the blocks, items, mobs or weather that use it"
- [ ] T739 [US18-client] Implement full reload (atlases, models, item definitions, entity and environment textures, font, lang) when the stack changes in `client/src/packs/stack.cob`
- [ ] T740 [P] [US18-client] Write acceptance test `client/tests/acc_us18_incompatible.cob`: case "acceptance US18-4 enabling a too old, too new or unknown pack asks for confirmation and enables it on confirm"
- [ ] T741 [US18-client] Implement the confirmation screen in `client/src/screens/pack-confirm.cob`
- [ ] T742 [P] [US18-client] Write acceptance test `client/tests/acc_us18_invalid.cob`: case "acceptance US18-5 a pack with invalid metadata or an unreadable file shows an error naming the pack and the problem, and anything unresolvable is drawn with the missing-texture stripes"
- [ ] T743 [US18-client] Implement pack error reporting (08 §2.3 validation) in `client/src/packs/stack.cob` and its display in `client/src/screens/pack-select.cob`
- [ ] T744 [P] [US18-client] Write implementation test `client/tests/test_http.cob` against `tools/testsrv/testsrv.py`: GET over `cc_net_*` (http) and `cc_tls_*` (https), the request headers of 08 §9.3, `Content-Length` and chunked bodies, non-200 as failure, the size limit by header and while streaming (research R10)
- [ ] T745 [US18-client] Implement the non-blocking HTTP/1.1 client in `client/src/http.cob`
- [ ] T746 [P] [US18-client] Write `contract_wire_client.cob` cases: Resource Pack Response (configuration and play) encodes equal to its fixtures for every action; Resource Pack Push (configuration and play) decodes
- [ ] T747 [P] [US18-client] Write acceptance test `client/tests/acc_us18_server_pack.cob`: case "acceptance US18-6 client half: a pushed pack prompts (unless the entry's policy is always or never), on accept is downloaded, its SHA-1 checked (direct `EVP_Digest` with `EVP_sha1`), responses accepted, downloaded, successfully loaded are sent in order, and it is on top of local packs until disconnect"; case "US18 edge two pushed packs: the last offered is on top"; cases for failed download, failed hash and failed reload sending the 08 §9.2 responses and not applying the pack
- [ ] T748 [US18-client] Implement the pack prompt screen with the always/never choice saved in `servers.dat` in `client/src/screens/pack-prompt.cob`
- [ ] T749 [US18-client] Implement server pack download, hash check, responses, stacking and removal on disconnect in `client/src/packs/download.cob`
- [ ] T750 [P] [US18-client] Write acceptance test `client/tests/acc_us18_required_decline.cob`: case "acceptance US18-7 client half: declining a required pack sends declined and returns to the server list with the §17 required-pack message"
- [ ] T751 [US18-client] Implement required-pack decline handling in `client/src/packs/download.cob`
- [ ] T752 [P] [US18-client] Write acceptance test `client/tests/acc_us18_cache.cob`: case "acceptance US18-8 an unchanged pack offered again is applied from `downloads/` without a second download" (08 §9.4)
- [ ] T753 [US18-client] Implement the download cache in `client/src/packs/cache.cob`
- [ ] T754 [US18-client] Extend the client implementation tests to 100 % coverage of the US18 changes
- [ ] T755 Gate: run `make gate-client` and record the command and its real output

---

## Phase 47: Convergence

**Purpose** (constitution 5.2): (1) tasks touching more than one package — the in-process cross-package
acceptance tests of every scenario whose outcome needs client and core together (plan "Test strategy"
placement rule), run through the client's single-player host (two `CLIENT-STATE` instances against one core
over memory connections) and, for network-only behaviour, the server program's TCP host on loopback;
(2) no E2E obligation (inventory empty, research R16); (3) the aggregate Gate. A Convergence acceptance test that
fails is repaired by a task inserted directly after it, in whichever package is wrong (constitution 5.7); the
contract is never edited here except by escalation (constitution 3.6).

**Independent Test**: `make gate` exits 0.

- [ ] T756 Create `tests/convergence/Makefile` (build and run `tests/convergence/acc_*.cob` linking client, server, core, proto and shim) and include it in the `test`, `coverage` and `gate` targets of the root `Makefile`
- [ ] T757 Create the convergence harness `tests/convergence/CONVH.cpy` and `tests/convergence/convharness.cob` (test infrastructure): start a single-player host world in a scratch game directory, attach further client instances over additional memory connections, start `SV-START` on a loopback port for network cases, step every client and the core frame by frame, and read each client's screen model and render list
- [ ] T758 [P] [US1] Write acceptance test `tools/tests/acc_us1_build.py` and add it to `tools/Makefile` `tests`: case "acceptance US1-1 given a fresh checkout with the prerequisites when `make` runs then `build/bin/cobolcraft` and `build/bin/cobolcraft-server` are produced and each runs (the client without `--name` prints its `FATAL arguments` line and exits 1; the server in a scratch directory prints its ready line)"
- [ ] T759 [P] [US2] Write `tests/convergence/acc_us2_server_list_status.cob`: case "acceptance US2-2 given a running server in the list then the entry shows its description and players online"; case "US2 edge a server of another protocol version is shown as incompatible"
- [ ] T760 [P] [US2] Write `tests/convergence/acc_us2_join.cob`: case "acceptance US2-3 given a first-time Player when they join then they stand on turf at the world spawn in the main dimension facing east with the marker pillar four blocks ahead" (camera and replica of the client)
- [ ] T761 [P] [US2] Write `tests/convergence/acc_us2_disconnect.cob`: case "acceptance US2-5 given the Player in the world when they press the disconnect control then they return to the server list"; case "US2 edge a second login with the same name disconnects the first Player, who sees the message"
- [ ] T762 [P] [US3] Write `tests/convergence/acc_us3_streaming.cob`: case "acceptance US3-4 given the Player walks several hundred blocks and turns around then terrain is present to the view distance in every direction and areas left behind are no longer shown"; case "SC-007 walking 1,000 blocks in each compass direction from the arrival point in every dimension finds terrain to the view distance at every point"
- [ ] T763 [P] [US3] Write `tests/convergence/acc_us3_other_players.cob`: case "acceptance US3-5 given two Players in the same dimension within view distance then each sees the other as the operator figure at their position and facing, and it disappears on disconnect, dimension change or moving out of view"
- [ ] T764 [P] [US4] Write `tests/convergence/acc_us4_shared_changes.cob`: case "acceptance US4-7 given two Players when one breaks, places or toggles a block in view then the other sees the same change"; case "US4 edge simultaneous changes to one block end the same for both"; SC-002 block changes
- [ ] T765 [P] [US4] Write `tests/convergence/acc_us4_controls_to_world.cob`: cases US4-2, US4-3, US4-4, US4-5, US4-6 and US4-8 driven through the client's controls against the in-process core (place in default state, survival break time and void, creative instant, glowtube light change, hotbar and inventory moves, starting items)
- [ ] T766 [P] [US5] Write `tests/convergence/acc_us5_ground_items.cob`: cases US5-1 to US5-4 through two clients (both see the falling and resting item at the same position; walking over it adds it to the inventory; throwing; despawn for everyone); SC-011 a sequence of drops and pickups by two players conserves every item
- [ ] T767 [P] [US6] Write `tests/convergence/acc_us6_chat.cob`: case "acceptance US6-1 two Players exchange messages and each sees both as `<name> message`"; case "SC-006 every message is seen by every connected player in the same order"
- [ ] T768 [P] [US7] Write `tests/convergence/acc_us7_health.cob`: cases US7-1 to US7-6 through the client (fall from a pillar, being hit by the other player with combat enabled, recovery, death screen with cause and death message seen by the other Player, respawn at the world spawn, creative immunity)
- [ ] T769 [P] [US8] Write `tests/convergence/acc_us8_hunger.cob`: cases US8-1 to US8-6 through the client (food bar falls with activity, eating raises it, full food eats nothing, starvation hurts, creative unchanged)
- [ ] T770 [P] [US9] Write `tests/convergence/acc_us9_mobs.cob`: case "acceptance US9-5 two Players near the same mob see the same movement, attacks and defeat"; US9-1 to US9-4 through the client; SC-002 mob outcomes
- [ ] T771 [P] [US10] Write `tests/convergence/acc_us10_crafting.cob`: cases US10-1 to US10-4 through the crafting screen against the in-process core
- [ ] T772 [P] [US11] Write `tests/convergence/acc_us11_weather.cob`: case "acceptance US11-2 two Players in the same dimension see the same weather kind at the same time" (forced by the weather command); US11-1 and US11-4 through the client; SC-002 weather changes
- [ ] T773 [P] [US12] Write `tests/convergence/acc_us12_dimensions.cob`: cases US12-1 to US12-4 through the client; SC-012 travel to every extra dimension and back keeps inventory, health, food and mode
- [ ] T774 [P] [US13] Write `tests/convergence/acc_us13_restart.cob` (server program on loopback): case "acceptance US13-4/SC-003 a Player builds, is hurt, gets hungry, leaves ground items, travels to another dimension and leaves; the server stops and restarts; the Player rejoins in the same dimension and spot with the same inventory, health and food and everything else as it was"
- [ ] T775 [P] [US14] Write `tests/convergence/acc_us14_command_surfaces.cob`: case "SC-009 every command of standin-content §16 produces its defined effect from each surface it is permitted on (chat with operator status, chat without it, console, single-player host, opened-world host and guest) and is refused for every sender not permitted"; US14-1 suggestions shown in the client
- [ ] T776 [P] [US15] Write `tests/convergence/acc_us15_stop.cob` (server program on loopback): case "acceptance US15-2 the stop command disconnects connected Players, who return to the server list with the stopping message"
- [ ] T777 [P] [US16] Write `tests/convergence/acc_us16_single_player.cob`: case US16-1 create (name, survival or creative), open and delete after confirming; case US16-2 the same game as a default-settings server without a separate server; case US16-3 commands available to the host; case US16-4 the pause menu pauses; case US16-5 quitting and reopening finds the world as left
- [ ] T778 [P] [US16] Write `tests/convergence/acc_us16_folder_interchange.cob`: case "acceptance US16-6/SC-010 a single-player world folder served by the server program, and a server world folder opened in single-player, show every dimension, block, player record, mob and ground item unchanged"
- [ ] T779 [P] [US17] Write `tests/convergence/acc_us17_open.cob` (host client plus a guest client over loopback TCP): cases US17-1 (mode and operator choice, address shown), US17-2 and SC-013 (the guest joins using only the shown address; both see each other's block changes), US17-3 (pause does not pause), US17-4 (host quits: saved, guest disconnected with the host-closed message), US17-5 (guest rejoins after reopening with stored state), and the US17 edge (guest with the host's name refused)
- [ ] T780 [P] [US18] Write `tests/convergence/acc_us18_server_pack.cob` (server program offering a pack served by `tools/testsrv/testsrv.py`): cases US18-6 (prompt, accept, applied above local packs until disconnect), US18-7 (required pack declined: disconnected with the message) and US18-8 (rejoin applies the cached pack without downloading)
- [ ] T781 Gate: run `make gate` (root `Makefile`: lint, build, every package's tests, convergence tests, 100 % coverage) and record the command and its real output

---

## Phase 48: Polish & Cross-Cutting Concerns

**Purpose**: documentation completion, the quickstart walk-through, the terminal debt check and the terminal
gate.

- [ ] T782 Complete `README.md`: running the server (operator-surface §1 to §4), running the client (client-surface §1 to §3, controls table), single-player and opening to others, resource packs folder, failure lines (FR-012) and a pointer to `specs/001-cobolcraft-complete/quickstart.md`
- [ ] T783 Review `README.md` against SC-001, operator-surface.md and client-surface.md (verification-only)
- [ ] T784 Verify SC-001: in a fresh clone in a scratch directory, follow only `README.md` (`make bootstrap`, `make`, `make test`) and record the commands and real output (verification-only)
- [ ] T785 Walk through `specs/001-cobolcraft-complete/quickstart.md` §0 to §8 on the supported platform and record what was observed per section (verification-only, research R16: documentation, not a test)
- [ ] T786 Debt check of every file this feature touched (`git diff --name-only main...HEAD`): no suppression directive, no skipped or focused test, no uncovered line, no behaviour without an acceptance criterion, no deferred item without a `tickets/CC-NNNN-*.md` record (constitution 1.4, 3.8, 5.4, 5.7); fix anything found in this task's evidence record
- [ ] T787 Gate: run `make gate` (root `Makefile`) and record the command and its real output (terminal gate)

---

## Dependencies & Execution Order

### Phase dependencies

- **Phase 1 Setup (US1)**: none; blocks everything.
- **Phase 2 Foundational**: after Setup; blocks every lane. Inside it, A (docs) precedes C (fixtures need the
  extended content and 09); B (contract files) is independent of A; D's texture generator needs A's §1.4 and
  §11 to §18 recipes.
- **PARALLEL GROUP (Phases 3 to 46)**: all lanes start after Foundational's Gate. Phases inside one lane run in
  the order listed. Gates follow the link order stated at the top of the group.
- **Phase 47 Convergence**: after every lane phase has passed its Gate.
- **Phase 48 Polish**: after Convergence's Gate.

### Lane structure and story slices

| Story | Lane phases | Then |
|---|---|---|
| US1 | Phase 1 | Convergence `acc_us1_build.py` |
| US2 | shim 3, proto 8, core 12, server 28, client 32 | Convergence |
| US3 | proto 9, core 13, client 33 | Convergence |
| US4 | core 14, client 34 | Convergence |
| US5 | core 15, client 35 | Convergence |
| US6 | core 16, client 36 | Convergence |
| US7 | core 17, client 37 | Convergence |
| US8 | core 18, client 38 | Convergence |
| US9 | core 19, client 39 | Convergence |
| US10 | proto 10, core 20, client 40 | Convergence |
| US11 | core 21, client 41 | Convergence |
| US12 | core 22, client 42 | Convergence |
| US13 | core 23, server 29 | Convergence |
| US14 | proto 11, core 24, client 43 | Convergence |
| US15 | shim 4, core 25, server 30 | Convergence |
| US16 | shim 5, client 44 | Convergence |
| US17 | shim 6, core 26, client 45 | Convergence |
| US18 | shim 7, core 27, server 31, client 46 | Convergence |

A story is complete when all its `US<n>-*` phases and its Convergence tests have passed.

### Within each phase

- A test task (contract, acceptance or implementation test) precedes the implementation task(s) it defines.
- Copybooks of content precede the code that reads them; a phase's last task before its Gate raises coverage to
  100 % for that phase's code.

### Disjointness (constitution 5.2)

Lane file sets: `shim/**` (shim), `proto/**` (proto), `core/**` (core), `server/**` (server), `client/**`
(client). They are pairwise disjoint and disjoint from `contract/**`, `docs/**`, `tools/**`, the root
`Makefile`, `README.md` and `tests/convergence/**`, which only Setup, Foundational, Convergence and Polish
write. Checked mechanically over the file paths named in every lane task when this file was generated.

---

## Parallel Examples

```text
# Lanes after Foundational (five concurrent workers, one per package):
Lane shim:   Phase 3 → 4 → 5 → 6 → 7
Lane proto:  Phase 8 → 9 → 10 → 11
Lane core:   Phase 12 → 13 → … → 27
Lane server: Phase 28 → 29 → 30 → 31
Lane client: Phase 32 → 33 → … → 46

# Foundational wire fixtures: every "Write contract/fixtures/wire/…" task is [P] (one file each).

# Inside Phase 12 (US2-core), the opening [P] tests together:
"Write core/tests/contract_shim_consumer.cob …"
"Write implementation test core/tests/test_content_tables.cob …"

# Inside Phase 24 (US14-core), each acc_us14_cmd_*.cob test is [P]; each executor then lands in
# core/src/commands.cob one after another.

# Convergence: every tests/convergence/acc_*.cob task is [P] (one file each) once the harness exists.
```

---

## Implementation Strategy

### MVP first (User Story 1)

1. Phase 1 Setup delivers US1's runner, coverage, lint, bootstrap and Makefiles; its Gate proves US1-2 and US1-3.
2. **Stop and validate** the Contributor experience; US1-1 completes once the programs exist (Convergence).

### First playable increment (US2 and US3)

1. Phase 2 Foundational (docs, contract, fixtures, shared test infrastructure).
2. Lanes up to their US2 and US3 phases: shim 3, proto 8–9, core 12–13, server 28, client 32–33.
3. Run the US2 and US3 Convergence tests early (they only need those phases) to demonstrate joining and
   walking; the formal Convergence Gate still runs after every lane.

### Incremental delivery

Each further story adds its lane slices in spec order (US4 → US18); the lane gates keep every package at 100 %
coverage after every slice, so the game stays shippable at each lane boundary.

### Parallel team strategy

One worker per lane (shim, proto, core, server, client); `core` and `client` are the long lanes. Workers on
`server` and `client` write their tests and code at once and run their Gates as the link order allows.

---

## Notes

- Effective size: every non-Gate, non-review task is one independently verifiable change (constitution 5.1);
  verification-only tasks (Gate, Review, Verify, Walk through, Debt check) have size 0.
- Every Gate task records the exact command and its real output at the moment it runs (constitution 5.4
  evidence); any later change to verified code invalidates it.
- Commit at every phase boundary (constitution 5.3).
- Nothing is deferred by this task list; a discovery during implementation that falls under constitution 1.4's
  two cases is recorded as a Spile ticket in `tickets/` (prefix `CC`, `draft` status); everything else is fixed
  in place.
