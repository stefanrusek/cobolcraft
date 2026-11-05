# Implementation Plan: CobolCraft, complete (game client and game server)

**Branch**: `001-cobolcraft-complete` | **Date**: 2026-11-05 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-cobolcraft-complete/spec.md`; constitution
`.specify/memory/constitution.md` (project v1.2.0 with SDD amendment v6.3.0); personas
`.specify/memory/personas.md`.

**Companion artifacts**: [research.md](research.md) (decisions R1 to R16, spike evidence, handoff
verification), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md),
[spikes/](spikes/).

## Operator decisions (recorded)

The plan phase raised three questions; the operator answered them in constitution v1.2.0 (commit `a2fbe0e`).
No clarification marker remains in this feature's artifacts.

1. **C boundary (constitution Principle I, v1.2.0).** COBOL MAY call any C library directly; a thin C glue
   layer is allowed wherever a call cannot be expressed cleanly from COBOL (callbacks, platform struct
   layouts, variadic functions or macros, ABI mismatches), with no fixed subsystem list, and the glue contains
   no game or protocol logic. This plan therefore puts in the `shim` package only the calls that need glue,
   each justified in `contracts/shim-abi.md` §1 table: window, input (keyboard, mouse buttons, cursor,
   scroll wheel, layout-aware Unicode text through GLFW's character callback, so non-US layouts work), Vulkan
   submission, sockets with readiness polling, non-blocking console input, local network addresses, directory
   listing, zlib streams and TLS. Everything COBOL can call cleanly it calls directly; at present that is
   OpenSSL's one-shot `EVP_Digest` with `EVP_sha1`/`EVP_md5` (`spikes/spike_direct_openssl.out.txt`), plus
   GnuCOBOL's own `CBL_*` file routines and `DISPLAY` for console output (research R5).
2. **Workspace bootstrap command (constitution Development Workflow, SDD 5.2):** `make bootstrap`
   (`contracts/test-harness.md` §1). Package-parallel mode is kept.
3. **Deferred-work tracker (constitution Development Workflow, SDD 1.4):** Spile tickets in `tickets/`,
   prefix `CC`, one `CC-NNNN-slug.md` file per item in `draft` status, the directory created with the first
   deferred item (research R15). Nothing is deferred by this plan.

No external-dependency risk is open: every probe in research R1 to R11 succeeded.

## Summary

Build the CobolCraft game client and game server in GnuCOBOL 3.2, calling C libraries directly from COBOL with a thin C glue layer where needed, playing the original
stand-in content over protocol 777, rendering only with Vulkan (MoltenVK on macOS arm64), with single-player,
open-to-others, health, hunger, ground items, mobs, crafting, weather, extra dimensions, a full command set,
persistence and resource packs.

Technical approach (research R2 to R13): five code packages plus test tooling. `shim` (C) is the thin glue layer for
the library calls COBOL cannot express cleanly (callbacks, struct layouts, macros); COBOL calls every other C
function directly. `proto` (COBOL) encodes and decodes the protocol's
data types, frames, NBT and chunks. `core` (COBOL) is the whole game: world, rules, persistence, commands and
the server side of the protocol, operating on byte streams. `server` (COBOL) is a thin program hosting `core`
on TCP with a configuration file and console. `client` (COBOL) is the game window: menus, input, the client
side of the protocol, resource packs, meshing and the render list, plus an in-process host that runs `core`
for single-player and opens it to others. Missing content and protocol facts are written into `docs/` first
(FR-005, FR-015). Everything is tested at the lowest layer that can express it, with 100 % line coverage of
COBOL and C measured by gcov.

## Technical Context

**Language/Version**: GnuCOBOL 3.2 (free format, `-std=default`, `-debug`) for all game logic; C11 (Apple
clang) for the shim; GLSL 450 compiled to SPIR-V at build time; Python 3 (stdlib only) for test and build
tooling.

**Primary Dependencies**: GLFW ≥ 3.4 (3.5.1 probed), Vulkan loader 1.4 + MoltenVK 1.4 (API 1.2 with
portability enumeration/subset), glslang 16, zlib (macOS SDK), OpenSSL 3 (`openssl@3`, pinned over
`openssl@4`). Research R1.

**Storage**: files only: world folders (NBT + Anvil region files, `contracts/world-folder.md`), the server
configuration file (`contracts/operator-surface.md`), the client's game directory
(`contracts/client-surface.md`), the pack download cache (08 §9.4).

**Testing**: COBOL and C test programs with a shared assertion library and output protocol, Python runner,
gcov line coverage for COBOL (`cobc --coverage`) and C (`clang --coverage`), lint with `cobc -Wall -Werror`,
`clang -Wall -Wextra -Werror`, `spirv-val`. Research R9, `contracts/test-harness.md`.

**Target Platform**: macOS on Apple silicon (arm64) only (FR-011); every platform call isolated in `shim`.

**Project Type**: two desktop programs (a GUI game client and a console game server) sharing libraries, in
one repository with independently buildable and testable packages.

**Performance Goals**: none (spec Assumptions; constitution 2.7). Game-content timings (tick rate 20 per
second, break times, day length, hunger rates, despawn times, weather durations) are content, not targets.

**Constraints**: COBOL for all program logic; C only as logic-free glue where a call cannot be expressed cleanly (Principle I); implementation works
only from `docs/protocol/` and `docs/design/` (Principle II); offline identity only (FR-010); failures handled
only as FR-012 and research R14 state; single-threaded programs (research R6).

**Scale/Scope**: 18 user stories; 16 block states plus extension content; one world per process; view
distance up to 32 chunks.

## Constitution Check

*GATE: evaluated before Phase 0 and re-evaluated after Phase 1.*

| Principle | Status | Evidence |
|---|---|---|
| I. COBOL-first, thin C glue (v1.2.0) | Pass | All program logic in `proto`/`core`/`server`/`client` (COBOL): protocol, world, rules, geometry, UI layout. `shim` contains only adaptation code, and every module is justified by a reason Principle I names (`contracts/shim-abi.md` §1). Clean calls (OpenSSL digests, `CBL_*`, `DISPLAY`) are made from COBOL without glue. The Vulkan module submits COBOL-built geometry and decides nothing (R4). |
| II. Spec is the source of truth | Pass | Every protocol, storage and content gap is written into `docs/` in the Foundational phase before code uses it (R8, R12, R13); contracts that touch the wire or disk are transcribed into `docs/protocol/` (07 §9, new 09). No implementer reads the jar. |
| 1.1 Artifact completeness | Pass | This plan and its companions carry every decision; nothing depends on session context. |
| 1.3 Clarification markers | Pass | All three plan questions decided by the operator (constitution v1.2.0); none remain. |
| 1.4 Deferred work | Pass | Mechanism: Spile tickets in `tickets/`, prefix `CC` (constitution Development Workflow); no deferral made (R15). |
| 2.5 Dependency-aware sequencing | Pass | Lane phases follow the spec's story order US1 → US18. |
| 2.6 Handoff consumed | Pass | All 16 handoff items recorded confirmed/refuted/superseded (research "Plan-Phase Handoff verification record"). |
| 3.1 External dependencies probed | Pass | GnuCOBOL, GLFW, Vulkan loader, MoltenVK, glslang, zlib, OpenSSL (hashes, TLS, trust override), BSD sockets: `spikes/`, research R1 to R11. |
| 3.2 Gap analysis | Pass | "Empirical gap analysis" below. |
| 3.3 Package boundaries and contracts | Pass | "Package boundary declaration" below; eight contracts in `contracts/`, materialized in Foundational before any consumer task. |
| 3.4 Test infrastructure | Pass (gap documented) | Nothing exists; setup tasks precede all feature tasks ("Infrastructure setup"). |
| 3.5 Sequence diagrams | Pass | One per story below. |
| 3.6 Execution mode | Pass | Package-parallel; workspace bootstrap command `make bootstrap` is defined in the constitution. |
| 3.8 Debt survey | Pass | "Technical debt survey" below. |
| 4.1 Test-first, ladder, BDD/CDD, doubles | Pass | "Test strategy" below. No test doubles: every external dependency is used for real in tests. |
| 4.2 Coverage | Pass | gcov 100 % for COBOL and C production sources (R9); exclusions only tests, tools, specs. |
| 4.3 E2E | Pass | Inventory empty, none proposed (R16). |
| 5.6 Error handling | Pass | Only defined outcomes are handled; everything else fatal or non-fatal per FR-012 and R14, with `-debug` loud failure. |

Post-design re-check (after Phase 1 artifacts): unchanged after the v1.2.0 revision. Every `shim` function
is glue for a call COBOL cannot express cleanly, with its reason recorded, and the design adds no behaviour without an acceptance criterion: the console line formats,
configuration keys, game directory layout and controls are the plan's realisation of FR-009, US13, US15,
US2-1, US16-1, US18-2 and the stories' controls.

## Project Structure

### Documentation (this feature)

```text
specs/001-cobolcraft-complete/
├── spec.md
├── plan.md                 # this file
├── research.md             # Phase 0
├── data-model.md           # Phase 1
├── quickstart.md           # Phase 1
├── contracts/              # Phase 1: shim-abi, proto-api, core-host-api, wire-profile, world-folder,
│                           #          operator-surface, client-surface, test-harness
├── spikes/                 # Phase 0 probes (spike_*), evidence (*.out.txt), spike_run.sh
├── checklists/requirements.md
└── tasks.md                # Phase 2 (/speckit-tasks), not created here
```

### Source code (repository root)

```text
Makefile                    # top-level commands of contracts/test-harness.md
README.md                   # Contributor documentation (US1): prerequisites, build, test, run
contract/                   # frozen shared contract surface (Foundational only; lanes read, never write)
├── include/ccshim.h
├── copy/CCSHIM.cpy  COREAPI.cpy  PROTO.cpy
└── fixtures/wire/*.hex
shim/                       # package: thin C glue (Principle I) → build/shim/libccshim.a
├── src/cc_fatal.c cc_net.c cc_con.c cc_zlib.c cc_tls.c cc_fs.c cc_win.c cc_vk.c
├── shaders/world.vert world.frag ui.vert ui.frag
└── tests/
proto/                      # package: COBOL protocol codec → build/proto/libproto.a
├── src/  (buffer, scalars, composites, nbt, nbtfile (gzip NBT files shared by core and client), frame, chunk)
└── tests/
core/                       # package: COBOL game core → build/core/libcore.a
├── copy/                   # content tables from docs/design/standin-content.md (as extended)
├── src/  (api, session, status, login, config-phase, registries, play, world, worldgen, light,
│          chunks-stream, players, movement, entities, inventory, blocks, ground-items, chat, health,
│          hunger, mobs, rng, crafting, weather, dimensions, commands, access, console, region,
│          persistence)
└── tests/
server/                     # package: COBOL server program → build/server/libserver.a (callable programs) + build/bin/cobolcraft-server
├── src/  (main, loop (SV-START, SV-ITERATE, SV-SHUTDOWN), config-file, console, tcp-host)
└── tests/
client/                     # package: COBOL client program → build/client/libclient.a (callable programs) + build/bin/cobolcraft
├── copy/  (CLSTATE: per-instance client state passed BY REFERENCE; CLCONST)
├── src/  (main, args, loop (CL-STEP, CL-RUN), submit, input, controls, screens/*, net-client,
│          protocol-client, world-replica, inventory-replica, entities-replica, physics, raycast, sky,
│          weather-render, packs/*, json, png, zip, http, atlas, models, mesher, entities-render,
│          ui-render, render-list, sp-host, game-dir)
└── tests/  (fixtures/gen_textures.py → fixtures/textures/*.rgba: reference RGBA from an independent
             Python implementation of the recipes; test infrastructure)
tools/                      # test and build infrastructure (excluded from coverage)
├── runtests.py coverage.py lint.py bootstrap.sh
├── testlib/TESTLIB.cpy testassert.cob testlib.h
├── testsrv/                # loopback HTTP/HTTPS server + throwaway test CA
├── probe/                  # contract probe programs (make gate-contract)
└── tests/                  # acc_us1_* (build and test command behaviour)
tests/convergence/          # cross-package in-process acceptance tests (Convergence phase only)
docs/protocol/  docs/design/  # extended in Foundational (FR-005, FR-015)
```

**Structure decision**: packages `shim`, `proto`, `core`, `server`, `client`, `tools` are each built and tested
by their own `Makefile` (independently buildable/testable units, constitution 3.3). Dependencies:
`proto` → `shim`; `core` → `proto`, `shim`; `server` → `core`, `proto`, `shim`; `client` → `core`, `proto`,
`shim`. Packages link each other's library outputs and compile only against `contract/` for shared shapes.

## Package boundary declaration (constitution 3.3)

| Story | Packages touched | Kind |
|---|---|---|
| US1 Build and test | tools, shim, proto, core, server, client (per-package Makefile skeletons), root Makefile, README | multi (realised in Setup) |
| US2 Join | shim (fatal, net, zlib, win, vk), proto, core (direct `EVP_md5`), server, client | multi |
| US3 Move, stream | proto (movement/entity packets), core, client | multi |
| US4 Break/place | core, client | multi |
| US5 Ground items | core, client | multi |
| US6 Chat | core, client | multi |
| US7 Health | core, client | multi |
| US8 Hunger | core, client | multi |
| US9 Mobs | core, client | multi |
| US10 Crafting | proto (recipe display composites), core, client | multi |
| US11 Weather | core, client | multi |
| US12 Dimensions | core, client | multi |
| US13 Persistence, server lifecycle | core, server | multi |
| US14 Chat commands | proto (command tree nodes), core, client | multi |
| US15 Console commands | shim (con), core, server | multi |
| US16 Single-player | shim (fs), client | multi |
| US17 Open to others | shim (local addresses), core, client | multi |
| US18 Resource packs | shim (tls, fs), core (pack offer), server (pack config keys), client | multi |

**Contracts** (all in [contracts/](contracts/); fixed before any task that consumes them):

| Contract | Seam (provider → consumers) | Materialized as |
|---|---|---|
| `shim-abi.md` | shim → proto, core, server, client | `contract/include/ccshim.h`, `contract/copy/CCSHIM.cpy` |
| `proto-api.md` | proto → core, client | `contract/copy/PROTO.cpy`, `contract/fixtures/wire/frame-*.hex` |
| `core-host-api.md` | core → server, client | `contract/copy/COREAPI.cpy` |
| `wire-profile.md` | core (server side) ↔ client (client side) | `docs/protocol/09-cobolcraft-profile.md`, `contract/fixtures/wire/*.hex` |
| `world-folder.md` | core (writer/reader) ↔ Server operator / Player (copying folders) | `docs/protocol/07-nbt-and-anvil.md` §9 |
| `operator-surface.md` | server ↔ Server operator | `server` implementation only (no shared artifact) |
| `client-surface.md` | client ↔ Player, Pack creator | `client` implementation only |
| `test-harness.md` | tools ↔ every package, Contributor | root and per-package `Makefile`s (Setup) |

## Execution mode (constitution 3.6)

**Declared: package-parallel.** Workspace bootstrap command: `make bootstrap` (constitution Development
Workflow). Justification: all 17 feature stories after US1 cross package
boundaries, and the per-package work is large and disjoint (core and client each carry every gameplay story;
shim, proto and server carry several), so concurrent lanes repay their overhead; the frozen contracts above
license the split. Fast pass is excluded (contracts, far more than three files); standard would serialize
hundreds of disjoint package tasks.

Shape for the tasks phase (constitution 5.2):

| Phase | Content | Gate command |
|---|---|---|
| Setup | US1: `tools/` (runner, coverage, lint, testlib, bootstrap), root `Makefile`, every package's `Makefile` skeleton, `README.md`, `acc_us1_*` tests | `make gate-tools` |
| Foundational | (1) docs-first: FR-015 extension of `docs/design/standin-content.md` (sections listed in research R13, including the bitmap font), 08 additions, 07 §9, new 09; (2) contract materialization: `contract/include/ccshim.h`, `contract/copy/*.cpy`, every wire fixture; (3) shared test infrastructure: `tools/testsrv/` (the texture reference generator is client-only and lives in the client lane, `client/tests/fixtures/`). Documents are verified by review tasks (constitution 4.1). | `make gate-contract` (compiles every copybook and header in a probe program, checks every fixture parses as hex; lint) |
| PARALLEL GROUP | Lanes `shim`, `proto`, `core`, `server`, `client`; each lane runs its stories' slices in spec order; story tags `US<n>-<pkg>` | `make gate-<pkg>` per lane phase |
| Convergence | `tests/convergence/acc_us<n>_*.cob`: each story's acceptance scenarios that need more than one package, run in-process through the client's single-player host (client + core over a memory connection) and, for network-only behaviour, the core TCP host on loopback; no E2E (empty inventory) | `make gate` |
| Polish | README completion, quickstart walk-through review, final debt check of touched files | `make gate` |

Lane notes: the `shim` lane's US2 slice delivers every module except `cc_con` (US15), `cc_fs` (US16/US18),
local addresses (US17) and `cc_tls` (US18). SHA-1 for packs is a direct COBOL call to OpenSSL in the
`client` lane. The `server` lane has slices for US2, US13, US15, US18.
The `proto` lane has slices for US2, US3, US10, US14.

## Infrastructure setup (constitution 3.4)

Detected (research R16): no build system, no test framework, no coverage or lint tooling, no CI, no
remote. Critical infrastructure is missing, so these setup tasks precede every feature task (Setup and
Foundational phases above): the runner and output protocol, the COBOL and C assertion libraries, coverage and
lint drivers, `make bootstrap`, per-package Makefiles, the loopback HTTP/HTTPS test server with a test CA
(used through the standard `SSL_CERT_FILE`, no shipped test hook), the texture reference fixtures. CI is not
set up: the spec's verification surface is the Contributor's local terminal (US1, SC-001), and no remote
exists. Contract-test conventions: `contract_<seam>_<side>` files in each package's `tests/`, verified
in-process against `contract/` artifacts by every lane gate.

## Test strategy (constitution 4.1, 4.2, 4.3)

- **Test-first**: every implementation task is preceded by the test task that defines it; the tasks phase
  orders test before implementation within each lane phase.
- **Acceptance tests** (`acc_` prefix, case names with "acceptance" and Given/When/Then, research R9): one or
  more cases per acceptance scenario of spec.md. Placement rule:
  - Outcome observable from one package's surface → that package's lane (for example US13-2 configuration
    file in `server`; US2-1 server list persistence in `client`; US4-3 break timing and ground-item creation
    in `core`, driven through `CORE-*` entry points with fixture packets).
  - Outcome that needs client and core together (for example US4-7 "the other Player sees the same change",
    US16-2, US17-2) → `tests/convergence/` in the Convergence phase, two in-process clients against one core.
  - US1 → `tools/tests/acc_us1_*.py` (they run the real `make` targets in a scratch copy of the repository).
  - Client outcomes are asserted on the screen model and render list (data-model §13); texture outcomes on
    atlas bytes against `client/tests/fixtures/textures/`; GPU submission is covered by shim tests against the real
    GPU.
- **Contract tests**: both sides of every contract in the table above (`contract_*` files named in each
  contract document), lane-resident.
- **Implementation tests** (`test_` prefix): everything acceptance tests leave uncovered, to 100 % line
  coverage of `shim/src`, `proto/src`, `core/src`, `core/copy`, `server/src`, `client/src`.
- **Test doubles**: none. Real MoltenVK, real hidden GLFW windows, real loopback sockets, real zlib and
  OpenSSL, real local HTTP/HTTPS server. No operator decision needed.
- **E2E**: existing inventory empty; no journey proposed (research R16). Convergence and terminal gates run
  no E2E environment.
- **Document deliverables** (docs extensions, README): verified by review tasks, not tests.

## Empirical gap analysis (constitution 3.2)

**Package pass** (each declared package read as it exists on 2026-11-05):

| # | Package | Finding | Impact | Evidence weight |
|---|---|---|---|---|
| P1 | shim, proto, core, server, client, tools | Package does not exist; everything is new work. | HIGH | Confirmed by reading: repository tree is `.claude/`, `.specify/`, `docs/`, `specs/` only (`ls -a` at root). |
| P2 | shim | GLFW cannot find Homebrew's Vulkan loader without `glfwInitVulkanLoader`. | HIGH | Confirmed by reading `spikes/spike_vulkan_glfw.out.txt` ("without handoff": `vulkanSupported=0`, surface `-3`). Resolved: shim-abi §8. |
| P3 | shim | `pkg-config openssl` picks OpenSSL 4 when both are installed. | MEDIUM | Confirmed by reading the spike build warning (`openssl@4/4.1.0/include`, R1). Resolved: pin. |
| P4 | shim/client | Framebuffer size differs from window size on Retina. | MEDIUM | Confirmed by `spike_vulkan_glfw.out.txt` (`extent=640x480` for a 320 x 240 window). Resolved: `cc_win_size`. |
| P5 | core/client (COBOL) | No directory listing in GnuCOBOL 3.2. | HIGH | Confirmed by `spikes/spike_fileio.out.txt` (`C$LIST-DIRECTORY NOT AVAILABLE`). Resolved: glue `cc_fs_list` (constitution v1.2.0 Principle I). |
| P6 | core/client (COBOL) | Fixed-format column-72 limit breaks long statements. | LOW | Confirmed by the `spike_fileio.cob` compile error (R2). Resolved: free format. |
| P7 | docs (consumed by core, client) | standin-content lacks every FR-015 section; §1.3 and §3 conflict with FR-002's ground-item rule. | CRITICAL | Confirmed by reading `docs/design/standin-content.md` §1.3 ("No drops in the stand-in"), §3 (`loose_item` "Optional"), headings §0 to §8. Resolved: Foundational docs tasks (R13). |
| P8 | docs | 08 marks fonts "later" and has no entity, weather or font assets; Open questions 4 and 6 unresolved. | HIGH | Confirmed by reading 08 §8 table and "Open questions". Resolved: R13. |
| P9 | docs | 07 defines no `level.dat`, player, access or entity NBT, nor per-dimension folders. | HIGH | Confirmed by reading 07 §6 to §8 headings and §8 text. Resolved: R8, `world-folder.md`. |
| P10 | docs | No document states CobolCraft's protocol choices (compression threshold, which packets carry weather, crafting, etc.). | HIGH | Confirmed by reading `docs/protocol/README.md` index (00 to 08 only). Resolved: `wire-profile.md` → 09. |

**Seam pass** (one check per declared contract):

| Contract | Producer behaviour vs consumer assumption | Finding |
|---|---|---|
| shim-abi | Consumers assume non-blocking sockets, `EAGAIN` as "nothing now", 0-byte recv as closed, poll readiness. | Matches: `spike_libs.out.txt` (`nb-connect ... in progress`, `recv-empty ... Resource temporarily unavailable`, `recv-after-peer-close=0`). |
| shim-abi (vk) | Client assumes a textured, depth-tested, blended triangle-list pipeline with a mat4 push constant. | Matches: `spike_pipeline.out.txt`. |
| proto-api | core/client assume zlib-wrapped compression for frames and gzip for files. | Matches: `spike_libs.out.txt` (`header=789c`, `magic=1f8b`). |
| core-host-api | Hosts assume the core runs single-threaded on bytes; R7 assumes memory connections skip compression. | Matches 02 Offline mode text. |
| wire-profile | Client assumes unsigned chat accepted; crafting and weather fit existing packets. | Matches 05c "Signed chat", 05c 0x27, 05b 0x4B, 05a 0x27 tables (research R12). |
| world-folder | Server and single-player assume one shared format. | By construction (one core). |
| operator-surface, client-surface, test-harness | Single-sided contracts (person ↔ package). | No producer/consumer mismatch possible beyond the package's own tests. |

**Rollup**: P1 (HIGH, structural: all new), P7 (CRITICAL, resolved by Foundational docs), P2/P3/P4/P6
(resolved in contracts/research), P5 (resolved by `cc_fs_list`), P8/P9/P10 (resolved by Foundational docs). No suspected
finding remains unconfirmed.

**Coverage critic**: every declared package (shim, proto, core, server, client, tools) has at least one
package-pass row (P1 covers all); every contract has a seam-pass row.

**Routing**: P5 was routed to the operator and decided (constitution v1.2.0); all others fixed in this plan.

## Technical debt survey (constitution 3.8)

The repository holds no code, so tiers 1 and 3 have nothing to find in code. Admitted files are the documents
the feature touches:

| Tier | File | Finding | Planned removal |
|---|---|---|---|
| 1 | — | No suppression directives exist (no code). | — |
| 2 | `docs/design/standin-content.md` §1.3, §3 | Stale "first milestone" wording ("No drops in the stand-in", `loose_item` "Optional. Not needed for the first milestone") contradicting FR-002. | Rewritten by the Foundational FR-015 tasks. |
| 2 | `docs/protocol/08-resource-packs.md` §8 | "Minimal"/"later" column describes a superseded milestone (font now required). | Updated in Foundational (R13). |
| 2 | `docs/protocol/08-resource-packs.md` Open questions 4, 6 | Open questions the renderer depends on. | Answered in Foundational (R13). |
| 2 | `docs/design/standin-content.md` §8 "Open questions" | Entries touched by the extension (for example `world_clock`) must be closed or restated when the extension edits those sections. | Same Foundational tasks. |
| 3 | — | No existing architecture to reuse; the plan's structural choice (one core used by both hosts, one protocol path for single-player and network) removes a second game implementation and a second client protocol path entirely. | Built in from the start. |

Spikes are throwaway and excluded from build, lint and coverage.

## Sequence diagrams (constitution 3.5)

Participants: `P` Player / `O` Server operator / `C` Contributor; `CL` client; `SH` shim; `PR` proto;
`CO` core; `SV` server program.

### US1 — Build and test

```mermaid
sequenceDiagram
    actor C as Contributor
    participant MK as make (root Makefile)
    participant PK as package Makefiles
    participant RT as tools/runtests.py
    C->>MK: make
    MK->>PK: build shim, proto, core, server, client
    PK-->>MK: build/bin/cobolcraft, build/bin/cobolcraft-server
    C->>MK: make test
    MK->>PK: build test programs
    MK->>RT: run all test programs
    RT->>RT: parse "TEST <case> PASS|FAIL expected= observed="
    RT-->>C: failing cases, "passed n failed m", exit 0 or 1
```

### US2 — Start, connect, enter the world

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant SH as shim
    participant SV as server
    participant CO as core
    P->>CL: cobolcraft --name P
    CL->>SH: cc_win_open, cc_vk_init
    CL->>CL: load built-in + enabled packs, stitch atlas, bake models
    CL->>SH: cc_vk_texture(atlas)
    P->>CL: server list: add entry (saved to servers.dat)
    CL->>SH: cc_net_connect; send Intention(status), Status Request
    SH->>SV: bytes
    SV->>CO: CORE-CONN-INPUT
    CO-->>SV: Status Response (description, online)
    SV-->>CL: bytes
    CL-->>P: entry shows description and players online
    P->>CL: Join
    CL->>SV: Intention(login), Hello(name)
    SV->>CO: CORE-CONN-INPUT
    CO-->>CL: Set Compression, Login Finished (offline UUID)
    CL->>CO: Login Acknowledged, brand, Client Information
    CO-->>CL: brand, features, Select Known Packs, Registry Data..., Update Tags, Finish Configuration
    CL->>CO: Select Known Packs, Finish Configuration
    CO-->>CL: Login(play), Player Position, chunks (batch), Set Time, inventory
    CL->>CO: Accept Teleportation, Chunk Batch Received, Player Loaded
    CL->>CL: decode chunks, mesh sections (culling, shading, light)
    CL->>SH: cc_vk_mesh, frame_begin, draw, frame_end
    CL-->>P: world at spawn, facing east, pillar ahead
    P->>CL: disconnect control
    CL-->>P: server list
```

### US3 — Move, look, stream terrain, see others, day and night

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    P->>CL: keys and mouse (cc_win_poll events)
    CL->>CL: physics: walk, jump, collide, fall, fly (creative)
    CL->>CO: Move Player Pos/Rot, Player Abilities (flying)
    CO->>CO: validate against collision; update chunk centre
    CO-->>CL: Set Chunk Cache Center, new chunks, Forget Level Chunk
    CO-->>CL: other players: Add Entity, Move Entity, Rotate Head, Remove Entities
    CO-->>CL: Set Time each second
    CL->>CL: re-mesh loaded sections, drop forgotten ones, sky colour from time
    CL-->>P: terrain to view distance, other players as operator figures, day/night sky
```

### US4 — Break, place, toggle, inventory

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    participant CL2 as other client
    P->>CL: aim
    CL->>CL: ray-cast target, highlight in render list
    P->>CL: place (right button)
    CL->>CO: Use Item On(pos, face, seq)
    CO->>CO: rules: void target, height range, no entity overlap, default state / cardstack axis, use-up (survival)
    CO-->>CL: Block Update, Block Changed Ack, inventory slot
    CO-->>CL2: Block Update (same dimension, in view)
    P->>CL: break (hold)
    CL->>CO: Player Action START / STOP
    CO->>CO: break time (tool quarter), baseplate refuses, light recompute
    CO-->>CL: Block Update, ground item spawned (US5)
    CO-->>CL2: Block Update
    P->>CL: E / scroll / 1-9
    CL->>CO: Set Carried Item, Container Click
    CO-->>CL: Container Set Slot
```

### US5 — Ground items

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    CO->>CO: yield / throw creates loose_item (motion, age, pickup delay)
    CO-->>CL: Add Entity(loose_item), Set Entity Data(item stack)
    loop each tick
        CO->>CO: gravity, rest on block; age only near players; despawn at limit
        CO-->>CL: Teleport/Move Entity or Remove Entities (despawn)
    end
    P->>CL: walk near item
    CO->>CO: pickup in player order, partial if inventory nearly full
    CO-->>CL: Take Item Entity, Remove Entities (or Set Entity Data with reduced count), inventory slots
    P->>CL: Q / Ctrl+Q
    CL->>CO: Player Action DROP_ITEM / DROP_ALL_ITEMS
    CO-->>CL: inventory slot, Add Entity(thrown item)
```

### US6 — Chat

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    participant SV as server
    P->>CL: T, type, Enter
    CL->>CO: Chat(message, unsigned)
    CO->>CO: append in arrival order
    CO-->>CL: System Chat "<name> message" to every player, every dimension
    CO-->>SV: console line via CORE-CONSOLE-DRAIN
    CL-->>P: chat area, scroll-back when open
```

### US7 — Health, damage, death, respawn

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    CO->>CO: damage sources: fall beyond safe height, hostile mob, player attack (if combat on), starvation
    CO-->>CL: Set Health, Damage Event / Hurt Animation
    CL-->>P: health display, hurt feedback
    CO->>CO: recovery while fed (extension rate)
    P->>CL: attack (left button on entity)
    CL->>CO: Attack(entity id)
    CO->>CO: held item damage to target
    CO->>CO: health 0: death message, inventory per extension
    CO-->>CL: Player Combat Kill(cause), System Chat death message to all
    P->>CL: Respawn
    CL->>CO: Client Command PERFORM_RESPAWN
    CO-->>CL: Respawn(main dimension), Player Position(world spawn), Set Health(full)
```

### US8 — Hunger and eating

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    CO->>CO: exhaustion from time, walking, running, jumping, attacking, breaking
    CO-->>CL: Set Health(food)
    P->>CL: hold right button with food
    CL->>CO: Use Item
    alt held for the eating time and food below max
        CO->>CO: remove one food, add food value
        CO-->>CL: Entity Event(finished), Set Health, slot
    else released early or food full
        CL->>CO: Player Action RELEASE_USE_ITEM
        CO->>CO: nothing eaten
    end
    CO->>CO: food 0: starvation damage (US7)
```

### US9 — Mobs

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    participant CL2 as other client
    CO->>CO: spawn per dimension rules (hostile only if enabled)
    CO-->>CL: Add Entity(mob type)
    CO-->>CL2: Add Entity(mob type)
    loop each tick
        CO->>CO: wander / notice survival player in range / pursue / attack in reach
        CO-->>CL: Move Entity, Rotate Head
        CO-->>CL2: Move Entity, Rotate Head
    end
    CO-->>CL: Set Health, Hurt Animation (attacked)
    P->>CL: attack mob
    CL->>CO: Attack(mob id)
    CO->>CO: health 0: remove, spawn yield ground items
    CO-->>CL: Remove Entities, Add Entity(loose_item)
    CO-->>CL2: Remove Entities, Add Entity(loose_item)
    CL->>CL: mob geometry + pack entity texture
```

### US10 — Crafting

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    CO-->>CL: Recipe Book Add(all recipes, craftable flags) on join and on inventory change
    P->>CL: C (crafting screen)
    CL-->>P: every recipe with ingredients, result, craftable mark
    P->>CL: craft recipe
    CL->>CO: Place Recipe(0, display id, false)
    alt ingredients present and result fits
        CO->>CO: remove ingredients, add result (atomic)
        CO-->>CL: Container Set Slot(s), Recipe Book Add(updated flags)
    else
        CO->>CO: nothing changes
    end
```

### US11 — Weather

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    participant CL2 as other client (same dimension)
    loop each tick per dimension with weather
        CO->>CO: remaining--; at 0 choose next kind and duration (if weather changes on)
    end
    CO-->>CL: Game Event START/STOP_RAINING, RAIN_LEVEL, THUNDER_LEVEL (kind pair)
    CO-->>CL2: same
    CO->>CO: apply kind's gameplay effect to players and mobs in applicable biomes
    CL->>CL: kind from pair; sky tint and weather geometry where biome allows
    CL-->>P: weather shown
```

### US12 — Dimensions

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    P->>CL: use the means of travel
    CL->>CO: (interaction packet the extension defines)
    alt extra dimensions enabled
        CO->>CO: move player to target dimension arrival point; mobs and items stay
        CO-->>CL: Respawn(target spawn info), Player Position, chunks, weather pair, Set Health, inventory
        CL->>CL: drop old dimension replica, new sky/light/weather
    else disabled
        CO->>CO: player stays
    end
```

### US13 — Server lifecycle and persistence

```mermaid
sequenceDiagram
    actor O as Server operator
    participant SV as server
    participant CO as core
    participant FS as world folder
    O->>SV: cobolcraft-server
    SV->>SV: read or write cobolcraft-server.conf (fatal on invalid)
    SV->>CO: CORE-WORLD-OPEN(./world, settings)
    CO->>FS: read level.dat, access.dat (or create new world)
    SV->>SV: cc_net_listen(port)
    SV-->>O: "Ready: accepting players on 0.0.0.0:port"
    loop event loop
        SV->>CO: CORE-CONN-*, CORE-TICK per 50 ms
        CO->>FS: load player file on join, chunks on demand
        SV->>CO: CORE-CONSOLE-DRAIN
        SV-->>O: join / leave / death / dimension / chat lines
    end
    O->>SV: stop (US15)
    SV->>CO: CORE-STOP("server is stopping")
    CO->>FS: save chunks, entities, players, level.dat, access.dat
    SV-->>O: "Stopped", exit 0
```

### US14 — Chat commands

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant CO as core
    CO-->>CL: Commands(tree filtered by permission) on join and on operator change
    P->>CL: type "/" and text
    CL->>CO: Command Suggestion(text)
    CO-->>CL: Command Suggestions(players, dimensions, ...)
    P->>CL: Enter
    CL->>CO: Chat Command(text)
    alt permitted and valid
        CO->>CO: execute (players, inventory, health, mobs, items, time, weather, dimensions, spawn, save, stop)
        CO-->>CL: System Chat confirmation
    else not permitted / unknown / bad arguments
        CO-->>CL: System Chat error with help hint
    end
```

### US15 — Console commands

```mermaid
sequenceDiagram
    actor O as Server operator
    participant SH as shim
    participant SV as server
    participant CO as core
    SV->>SH: cc_net_poll(include console)
    SH-->>SV: console ready
    SV->>SH: cc_con_readline
    SV->>CO: CORE-CONSOLE(line) with operator permission
    SV->>CO: CORE-CONSOLE-DRAIN
    SV-->>O: result or error text
    opt stop command
        CO-->>SV: run state 1
        SV->>CO: CORE-STOP
        CO-->>SV: run state 2, disconnect bytes queued
        SV-->>O: Stopped; exit
    end
```

### US16 — Single-player

```mermaid
sequenceDiagram
    actor P as Player
    participant CL as client
    participant SH as shim
    participant CO as core (in-process)
    P->>CL: Single-player
    CL->>SH: cc_fs_list(gamedir/saves)
    CL-->>P: worlds (name, folder)
    P->>CL: Create (name, mode) or Open
    CL->>CO: CORE-WORLD-OPEN(saves/folder, settings: host kind 1, host name, mode)
    CL->>CO: CORE-CONN-OPEN(memory)
    loop frame
        CL->>CO: CORE-CONN-INPUT / CORE-CONN-OUTPUT (same protocol, no compression)
        alt not paused or opened to others
            CL->>CO: CORE-TICK per 50 ms
        end
    end
    P->>CL: Quit to menu
    CL->>CO: CORE-STOP
    CO->>CO: save world folder
    P->>CL: Delete world (confirmed)
    CL->>SH: cc_fs_list for recursive delete (CBL_DELETE_FILE / CBL_DELETE_DIR)
```

### US17 — Open to others

```mermaid
sequenceDiagram
    actor P as Host Player
    participant CL as host client
    participant SH as shim
    participant CO as core (in-process)
    participant G as guest client
    P->>CL: Pause → Open to others (guest mode, guest operator)
    CL->>CO: CORE-OPEN-TO-OTHERS
    CL->>SH: cc_net_listen(0), cc_net_local_addresses
    CL-->>P: "address:port" shown; pause no longer pauses
    G->>CL: TCP connect (as to a server)
    CL->>CO: CORE-CONN-OPEN(network), bytes both ways
    CO->>CO: refuse name equal to host; stored guest state restored
    P->>CL: Quit world
    CL->>CO: CORE-STOP("host closed the world")
    CO-->>G: Disconnect; world saved
```

### US18 — Resource packs

```mermaid
sequenceDiagram
    actor P as Pack creator / Player
    participant CL as client
    participant SH as shim
    participant CO as core
    P->>CL: Pack selection screen
    CL->>SH: cc_fs_list(resourcepacks)
    CL->>CL: read pack.mcmeta (zip via cc_inflate raw / folder), compatibility, icon
    P->>CL: enable, order (confirm if incompatible)
    CL->>CL: save options.dat; reload: stack, resolve files, errors named, stripes for unresolved
    CO-->>CL: Resource Pack Push (configuration, when offered)
    CL->>CL: policy prompt / always / never (servers.dat)
    CL->>CO: Resource Pack Response 3 accepted
    alt cached under downloads/uuid/sha1
        CL->>CL: cache hit
    else
        CL->>SH: cc_net_connect / cc_tls_connect, HTTP GET; EVP_Digest(sha1) direct
    end
    CL->>CO: 4 downloaded, then 0 successfully loaded (or 2 / 6 / 7)
    alt required and declined
        CL->>CL: disconnect with required-pack message
    end
```

## Risks

| Risk | Impact | Mitigation |
|---|---|---|
| Content authoring volume in Foundational (mobs, recipes, weather, dimensions, commands, font) is large and blocks every lane. | Schedule | Each FR-015 section is its own document task with its own review; lanes start only after all are reviewed (constitution 5.2 narrow Foundational). |
| GPU tests need a logged-in macOS session; no CI. | Verification only runs locally | Matches the spec's verification surface (US1, SC-001); recorded in R16. |
| COBOL code size for JSON, PNG, zip, HTTP and meshing in the client. | Effort | Each is a separate client module with its own implementation tests; no performance target. |
| Text input on non-US keyboard layouts. | Chat and command entry | GLFW's character callback delivers layout-resolved Unicode code points; `cc_win` queues them as kind-3 events (`shim-abi.md` §8); client tests feed such events. |

## Deferred work

None. Every discovery of this phase is incorporated (gap analysis routing). Mechanism for later phases:
Spile tickets in `tickets/`, prefix `CC` (constitution Development Workflow).

## Complexity Tracking

No constitution violation is planned.
