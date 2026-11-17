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

**Layout**: this file is the index. Each phase is a file under [tasks/](tasks/), linked where the phase
stood; each lane's own list is a file under [tasks/lanes/](tasks/lanes/) (`tools/tasks.py`). Read the index
and the files of the phases you work on, not the whole list.

## Format: `- [ ] [ID] [P?] [Story?] Description`

- **[P]**: can run in parallel with the other [P] tasks next to it (different files, no dependency on an
  incomplete task).
- **[Story]**: none in Setup, Foundational and Polish; composite lane tags `[US<n>-<package>]` in the parallel
  group (constitution 5.2: a split story's slices never carry the bare tag); bare `[US<n>]` in Convergence.
- **Phase numbers** follow file order only; lane phases of different lanes run concurrently inside the parallel group, so a higher number is not a later start. Heading levels are pinned: `##` for phases outside the group and the group itself, `###` lanes, `####` lane phases.
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

- [Phase 1: Setup (shared infrastructure)](tasks/phase-1.md)

- [Phase 2: Foundational (blocking prerequisites)](tasks/phase-2.md)

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

- [Phase 3: US3-shim — texture upload with mip levels and sub-rectangle update](tasks/shim/phase-3.md)

- [Phase 4: US4-shim — path opener](tasks/shim/phase-4.md)

- [Phase 5: US5-shim — mip chain and sampler](tasks/shim/phase-5.md)

- [Phase 6: US11-shim — IEEE double arithmetic by reference](tasks/shim/phase-6.md)

- [Phase 7: US20-shim — depth clear for the hand pass](tasks/shim/phase-7.md)

### Lane: formats

- [Phase 8: US1-formats — strict JSON, ZIP index and CRC, hashes, files](tasks/formats/phase-8.md)

- [Phase 9: US3-formats — user pack archives](tasks/formats/phase-9.md)

### Lane: proto

- [Phase 10: US8-proto — block destruction and player action](tasks/proto/phase-10.md)

- [Phase 11: US9-proto — item stack with components, containers, recipe book](tasks/proto/phase-11.md)

- [Phase 12: US11-proto — 24-section chunks, registries and tags](tasks/proto/phase-12.md)

- [Phase 13: US12-proto — level events, particles, three-dimension login](tasks/proto/phase-13.md)

- [Phase 14: US13-proto — command nodes and suggestions](tasks/proto/phase-14.md)

- [Phase 15: US14-proto — attributes and effects](tasks/proto/phase-15.md)

- [Phase 16: US15-proto — entity spawn and metadata](tasks/proto/phase-16.md)

- [Phase 17: US19-proto — swap action](tasks/proto/phase-17.md)

### Lane: content

- [Phase 18: US1-content — packs check and accepted jar](tasks/content/phase-18.md)

- [Phase 19: US2-content — content sets, registries, tags, built-in layer](tasks/content/phase-19.md)

- [Phase 20: US9-content — recipes](tasks/content/phase-20.md)

- [Phase 21: US10-content — crafting bench content](tasks/content/phase-21.md)

- [Phase 22: US11-content — worldgen registries](tasks/content/phase-22.md)

- [Phase 23: US12-content — loaders per document part (35, 36, 37, 38, 39)](tasks/content/phase-23.md)

- [Phase 24: US13-content — registries the commands name](tasks/content/phase-24.md)

- [Phase 25: US14-content — item components](tasks/content/phase-25.md)

- [Phase 26: US15-content — entity types, loot, spawn data](tasks/content/phase-26.md)

### Lane: extract

- [Phase 27: US1-extract — the extraction tool (`docs/protocol/22-extraction-tool.md`)](tasks/extract/phase-27.md)

### Lane: core

- [Phase 28: US1-core — packs status](tasks/core/phase-28.md)

- [Phase 29: US2-core — content re-base, world types, shared rules](tasks/core/phase-29.md)

- [Phase 30: US7-core — survival abilities](tasks/core/phase-30.md)

- [Phase 31: US8-core — break progress and stages](tasks/core/phase-31.md)

- [Phase 32: US9-core — inventory menu, crafting, recipe book](tasks/core/phase-32.md)

- [Phase 33: US10-core — crafting bench menu](tasks/core/phase-33.md)

- [Phase 32b: US9-core (c) — component item stacks, Place Ghost Recipe and the recipe gaps (play lane, ids T3650 to T3669)](tasks/core/phase-32b.md)

- [Phase 34: US11-core (a) — chunk generation queue and the cost measurement](tasks/core/phase-34.md)

- [Phase 35: US11-core (b) — random sources, noise, climate, biome source](tasks/core/phase-35.md)

- [Phase 36: US11-core (c) — density, aquifers, surface](tasks/core/phase-36.md)

- [Phase 37: US11-core (d) — carvers and caves](tasks/core/phase-37.md)

- [Phase 38: US11-core (e) — ores and ore drops](tasks/core/phase-38.md)

- [Phase 39: US11-core (f) — generation pipeline and the 24-section stream](tasks/core/phase-39.md)

- [Phase 40: US11-core (g) — debug world generator (test tool, plan "Operator addition: debug world")](tasks/core/phase-40.md)

- [Phase 41: US12-core (a) — block updates, fluids, world simulation](tasks/core/phase-41.md)

- [Phase 42a: US12-core (b) — falling blocks, growth, fire, light](tasks/core/phase-42a.md)

- [Phase 42b: US12-core (b) — falling blocks, growth, fire, light (continued, doc 29b)](tasks/core/phase-42b.md)

- [Phase 42c: US12-core (b) — falling blocks, growth, fire, light (continued, doc 29b)](tasks/core/phase-42c.md)

- [Phase 43a: US12-core (c) — redstone](tasks/core/phase-43a.md)

- [Phase 43b: US12-core (c) — redstone (continued, doc 30)](tasks/core/phase-43b.md)

- [Phase 44a: US12-core (d) — block entities and menus](tasks/core/phase-44a.md)

- [Phase 44b: US12-core (d) — block entities and menus (continued, doc 31)](tasks/core/phase-44b.md)

- [Phase 44c: US12-core (d) — block entities and menus (continued, doc 31)](tasks/core/phase-44c.md)

- [Phase 44d: US12-core (d) — block entities and menus (continued, doc 40)](tasks/core/phase-44d.md)

- [Phase 44e: US12-core (d) — block entities and menus (continued, doc 40)](tasks/core/phase-44e.md)

- [Phase 45a: US12-core (e) — features and structures](tasks/core/phase-45a.md)

- [Phase 45b: US12-core (e) — features and structures (continued, doc 35)](tasks/core/phase-45b.md)

- [Phase 45c: US12-core (e) — features and structures (continued, doc 35)](tasks/core/phase-45c.md)

- [Phase 45d: US12-core (e) — features and structures (continued, doc 36)](tasks/core/phase-45d.md)

- [Phase 45e: US12-core (e) — features and structures (continued, doc 36)](tasks/core/phase-45e.md)

- [Phase 45f: US12-core (e) — features and structures (continued, doc 36)](tasks/core/phase-45f.md)

- [Phase 45g: US12-core (e) — features and structures (continued, doc 36)](tasks/core/phase-45g.md)

- [Phase 46a: US12-core (f) — Nether, End and portals](tasks/core/phase-46a.md)

- [Phase 46b: US12-core (f) — Nether, End and portals (continued, doc 37)](tasks/core/phase-46b.md)

- [Phase 47a: US13-core — command framework and catalog](tasks/core/phase-47a.md)

- [Phase 47b: US13-core — command framework and catalog (continued, doc 16)](tasks/core/phase-47b.md)

- [Phase 47c: US13-core — command framework and catalog (continued, doc 16)](tasks/core/phase-47c.md)

- [Phase 47d: US13-core — command framework and catalog (continued, doc 16)](tasks/core/phase-47d.md)

- [Phase 48a: US14-core — tools, weapons, armor, enchantments](tasks/core/phase-48a.md)

- [Phase 48b: US14-core — tools, weapons, armor, enchantments (continued, doc 17)](tasks/core/phase-48b.md)

- [Phase 48c: US14-core — tools, weapons, armor, enchantments (continued, doc 17)](tasks/core/phase-48c.md)

- [Phase 49a: US15-core — mobs](tasks/core/phase-49a.md)

- [Phase 49b: US15-core — mobs (continued, doc 18)](tasks/core/phase-49b.md)

- [Phase 49c: US15-core — mobs (continued, doc 19)](tasks/core/phase-49c.md)

- [Phase 49d: US15-core — mobs (continued, doc 19)](tasks/core/phase-49d.md)

- [Phase 49e: US15-core — mobs (continued, doc 20)](tasks/core/phase-49e.md)

- [Phase 49f: US15-core — mobs (continued, doc 21)](tasks/core/phase-49f.md)

- [Phase 49g: US15-core — mobs (continued, doc 21)](tasks/core/phase-49g.md)

- [Phase 49h: US15-core — mobs (continued, doc 19)](tasks/core/phase-49h.md)

- [Phase 49i: US15-core — mobs (continued, doc 44)](tasks/core/phase-49i.md)

- [Phase 49j: US15-core — mobs (continued, doc 44)](tasks/core/phase-49j.md)

- [Phase 49k: US15-core — mobs (continued, doc 45)](tasks/core/phase-49k.md)

- [Phase 50: US19-core — off-hand swap](tasks/core/phase-50.md)

- [Phase 51: US21-core — vanilla configuration conformance (automated half of Q-1)](tasks/core/phase-51.md)

### Lane: server

- [Phase 52: US1-server — generated-dir key and console texts](tasks/server/phase-52.md)

- [Phase 53: US2-server — world-type key](tasks/server/phase-53.md)

- [Phase 54: US21-server — start-up log lines for the manual run](tasks/server/phase-54.md)

### Lane: client

- [Phase 55: US11-client (a) — replica, mesher and cell model re-base (scheduled first in this lane)](tasks/client/phase-55.md)

- [Phase 56: US1-client — start-up check and banner](tasks/client/phase-56.md)

- [Phase 57: US2-client — world type choice, remembered type, refusal](tasks/client/phase-57.md)

- [Phase 58: US3-client — pack stack and user packs](tasks/client/phase-58.md)

- [Phase 59: US4-client — Open Pack Folder](tasks/client/phase-59.md)

- [Phase 60: US5-client — seamless textures](tasks/client/phase-60.md)

- [Phase 61: US6-client — HUD and screens](tasks/client/phase-61.md)

- [Phase 62: US7-client — flight only in creative](tasks/client/phase-62.md)

- [Phase 63: US8-client — break overlay](tasks/client/phase-63.md)

- [Phase 64: US9-client — inventory screen and recipe book](tasks/client/phase-64.md)

- [Phase 65: US10-client — crafting bench screen](tasks/client/phase-65.md)

- [Phase 66: US11-client (b) — biome tint](tasks/client/phase-66.md)

- [Phase 67a: US12-client — particles, dimensions, container screens](tasks/client/phase-67a.md)

- [Phase 67b: US12-client — particles, dimensions, container screens (continued, doc 42)](tasks/client/phase-67b.md)

- [Phase 67c: US12-client — particles, dimensions, container screens (continued, doc 40)](tasks/client/phase-67c.md)

- [Phase 67d: US12-client — particles, dimensions, container screens (continued, doc 40)](tasks/client/phase-67d.md)

- [Phase 67e: US12-client — particles, dimensions, container screens (continued, doc 42)](tasks/client/phase-67e.md)

- [Phase 67f: US12-client — particles, dimensions, container screens (continued, doc 42)](tasks/client/phase-67f.md)

- [Phase 67g: US12-client — particles, dimensions, container screens (continued, doc 40)](tasks/client/phase-67g.md)

- [Phase 67h: US12-client — particles, dimensions, container screens (continued, doc 40)](tasks/client/phase-67h.md)

- [Phase 68: US13-client — suggestions and completions](tasks/client/phase-68.md)

- [Phase 69: US14-client — durability bars and effects](tasks/client/phase-69.md)

- [Phase 70a: US15-client — entity models](tasks/client/phase-70a.md)

- [Phase 70b: US15-client — entity models (continued, doc 34)](tasks/client/phase-70b.md)

- [Phase 70c: US15-client — entity models (continued, doc 34)](tasks/client/phase-70c.md)

- [Phase 71: US16-client — Options and `options.txt`](tasks/client/phase-71.md)

- [Phase 72: US17-client — F3 overlay](tasks/client/phase-72.md)

- [Phase 73: US18-client — F5 camera](tasks/client/phase-73.md)

- [Phase 74: US19-client — off-hand swap](tasks/client/phase-74.md)

- [Phase 75: US20-client — hand and held item](tasks/client/phase-75.md)

- [Phase 75a: US12-client — fluids (water and lava in the client)](tasks/client/phase-75a.md)

- [Phase 76: Convergence (cross-package tests, aggregate gate, manual vanilla run)](tasks/phase-76.md)

- [Phase 77: Polish and cross-cutting concerns](tasks/phase-77.md)

- [Phase 78: Vanilla world format (lane vanfmt, operator request: open a real 26.3 save and save it back without loss)](tasks/phase-78.md)

## Dependencies & Execution Order

### Phase dependencies

- **Setup (1)**: none. **Foundational (2)**: after Setup; blocks everything. Its docs rounds (2a) precede the lanes so lanes stay independent.
- **Parallel group (the lane phases between Foundational and Convergence)**: starts after the Foundational Gate; lanes are mutually independent except the edges listed under the group heading; within a lane phases run in order.
- **Convergence**: after every lane gate. **Polish**: after the Convergence aggregate Gate; it does not wait for the operator-blocking Q-1 run.

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

Each lane task names targets only under its own package directory; shared inputs (`contract/`, `docs/`, `specs/`, `tools/`, `Makefile`) are written only in Setup, Foundational, Polish. Two deliberate placements: the extraction tool's consumer test lives in `extract/tests/` (not `content/tests/`), and the generator tables live under `content/copy/gen/` but are produced by Foundational. The generator checked mechanically that every path a lane task names as a target lies under that lane's own package directory; `contract/`, `docs/`, `specs/`, `tools/`, `Makefile` and `tests/convergence/` are written only in Setup, Foundational, Convergence and Polish.

## Implementation Strategy

### MVP first

1. Setup and Foundational (docs rounds, contracts, generator, formats move).
2. Lanes for US1 and US2 (extraction tool, content sets, world types), then US3 to US6 (the look), then US7 (flight): the first demonstrably better build, with the cobolcraft world type playable with no jar.
3. Stop and validate at each lane gate; run Convergence for the stories finished.

### Incremental delivery

US7 to US10 and US16 to US20 (controls and screens) next; US11 to US15 (the standard world, commands, tools, mobs) are the largest and are cut one document family per phase, each ending in `make gate-core`; US21 closes with the manual run. Each story adds value without breaking earlier ones because both world types run on the same engines.

- [Phase 90: convergence gate repair (lane 002-lane-sdd)](tasks/shared/phase-90.md)

## Notes

- `[P]` = different files, no dependency on an incomplete task. Commit at every phase boundary after its Gate (constitution 5.3).
- A task that discovers a missing document value stops its slice; the orchestrator runs a clean-room round and the slice resumes (plan "Docs-first obligations").
- Q-1 and Q-2 are recorded operator decisions (see header); neither is reopened by tasks.

























- [Phase 96: item components (lane itemcomp, ids T9600 to T9699)](tasks/shared/phase-96.md)
- [Phase 101: item components continued (lane itemcomp2, ids T10100 to T10199)](tasks/shared/phase-101.md)

## Lane lists

Every file in [tasks/lanes/](tasks/lanes/) is one lane's own task list. A new lane adds its own file there
and changes no other file. `python3 tools/tasks.py status <this folder>` counts the open and done tasks of
every file; `python3 tools/tasks.py join <this folder>` prints the whole list as one document.
