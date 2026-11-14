# Research: Client polish: visuals, controls and missing gameplay

**Feature**: `002-client-polish` | **Plan**: [plan.md](plan.md) | **Spikes**: [spikes/](spikes/)

The plan phase works from the spec, `docs/protocol/` and `docs/design/` for behaviour values (constitution
Principle II) and from the existing code and the real toolchain for everything that is not behaviour. This record
holds the decisions (R1 to R16), the empirical evidence behind them (each spike names its output file), the
external-dependency validation (constitution 3.1) and the handoff verification of the spec's assumptions.
Nothing here introduces a game value: every number below is either a measurement of the toolchain or a pointer
into a document.

## External dependencies and what was probed (constitution 3.1)

| Dependency | Assumption the plan relies on | Probe | Observed result |
|---|---|---|---|
| GnuCOBOL 3.2 file routines (`CBL_*`) | The extraction tool needs no glue: it reads a 41 MB file at byte offsets, hashes it incrementally, creates, renames and deletes directories (22 §7.2). | `spikes/spike_jar_digest.cob` against `tmp/minecraft-26.3-client.jar`; output `spike_jar_digest.out.txt`. | `CBL_READ_FILE` at 64 KiB blocks and offsets works; whole run 0.33 s; incremental SHA-256 by direct OpenSSL `EVP_DigestInit_ex/Update/Final_ex` returns `4508d006...9a2d` (equals the value recorded in `docs/protocol/README.md` and `shasum -a 256`); FIPS vector `abc` gives `ba7816bf...15ad`; the end record read at `size - 22` is `504B0506...` with 34,227 entries (`0x85B3`, equals 22 §12 T1); `CBL_CREATE_DIR`, `CBL_RENAME_FILE` (a directory), `CBL_DELETE_DIR` all return 0. |
| The user's two inputs (`tmp/` folder) | The jar and the Faithful pack are in the operator's git-ignored `tmp/` and match the recorded facts. | `spikes/spike_pack_facts.py` (zip metadata and PNG headers only; output `spike_pack_facts.out.txt`). | Jar: 34,227 records, 32,878 files, all method 8 (matches 22 §12 T1). Faithful: 5,300 records, 5,066 files, methods 8 (3,075) and 0 (1,991), 1,297 block textures of which 1,197 are 32x32 and 45 are 64x64, 105 block `.mcmeta` (the jar has the same 105). So the user-pack zip reader must handle methods 0 and 8 (22 §8.4) and the atlas must take non-16 sprite sizes. |
| Vulkan loader and MoltenVK | A 32x pack's block atlas and the entity and GUI atlases fit one texture each. | `spikes/spike_vk_limits.c`; output `spike_vk_limits.out.txt`. | Apple M4 Pro: `maxImageDimension2D` 16384, `maxImageArrayLayers` 2048, RGBA8 sampled 2D up to 16384 x 16384 with 15 mip levels. About 1,300 block sprites at 32x32 need roughly 1,100 x 1,100 pixels; there is room for 64x packs and for mipmaps. |
| GnuCOBOL 3.2 compile of registry-sized tables | The block, state and item tables (documents 24 and 25: about 1,200 blocks, 30,000 states, 1,500 items) can be generated into copybooks. | `spikes/spike_gen_table.py` and `spike_gen_table.cob`; output `spike_gen_table.out.txt`. | One `FILLER VALUE` per column (the style of `core/copy/BLOCKS.cpy`) at 140,402 lines: cobc did not finish in over 4 minutes. One text row per record at 31,202 lines: 36 s per compile. 400-character literal rows (the same 940 KB in 2,163 lines): 0.25 s, start-up 0.00 s. A free-format source line is limited to 512 bytes. Decision R3. |
| GnuCOBOL 3.2 arithmetic speed (terrain noise, documents 10 and 11) | A standard chunk can be generated in a playable time with IEEE double results. | `spikes/spike_noise_speed.cob`, `spike_float_ops.cob`, `spike_fma_calls.cob`, `spike_f64.c` + `spike_f64.cob`; outputs `*.out.txt`. | `COMPUTE` on `FLOAT-LONG` or `COMP-2`: 1.17 microseconds per statement; one improved-noise sample (35 statements) 31 s per million samples (32,000 per second), identical at `-O2` and `-debug`. The same code in `BINARY-DOUBLE` integers: 330,000 samples per second (not IEEE, so not bit-exact). A by-reference glue (`cc_f64_mul`, `cc_f64_add` over libm `fma(a,b,0)` and `fma(a,1,b)`): 2,000,000 multiply-adds (4,000,000 calls) in 0.01 s, and `0.1 + 0.2` gives the IEEE bytes `343333333333D33F`, equal to Python's. Calling `fma` directly with `RETURNING` fails (a C double return is read as an int: result 0), so the glue is a genuine ABI mismatch (Principle I). A decimal literal loaded into a `FLOAT-LONG` is not always the nearest double (`VALUE 0.1` plus `0.2` gave `333333333333D33F`), so constants are loaded from bit patterns or through a parsing call. Decision R5. |
| Java 21 and a vanilla client | A vanilla client can be driven against our server by a test. | `java -version`: OpenJDK 21.0.3 (Zulu) present; `~/.minecraft` absent. | The jar alone is not runnable (a launcher supplies its libraries and natives), so no automated vanilla-client run can be probed in the plan. Risk R-V (plan Risks) and marker Q-1. |
| macOS `open` | The Open Pack Folder button can call `/usr/bin/open`. | `command -v open`: `/usr/bin/open`. | Present on every macOS; calling it in a test opens a real Finder window, which is the test-double question Q-2. |
| OpenSSL | SHA-256 and CRC-32 need no glue. | Spike above (`EVP_sha256` direct); CRC-32 is a table in COBOL (22 §7.2 gives the check value `cbf43926`). | Pass. |

Every probe that could run succeeded; the two that could not (a real vanilla client, a real Finder window under
test) are the decisions Q-1 and Q-2, both recorded by the operator. No spike mutated external state.

## Decisions

### R1. New packages `formats`, `content` and `extract` (structural debt, constitution 3.8 tier 3)

- **Decision.** Add three packages. `formats` (COBOL library over `shim`) holds the file-format readers that three
  programs now need: the JSON, ZIP, PNG and regular-expression programs that live in `client/src` today
  (`json.cob`, `zip.cob`, `png.cob`, `regex.cob` and their copybooks), moved unchanged with their tests, plus
  CRC-32, SHA-256 and the strict JSON of 23 §3.2. `content` (COBOL library) holds the registry model shared by
  the server side and the client: the static registries generated from documents 24, 25 and 46, the registry
  layers, holders and tags of 23, the data pack and pack-directory loaders, the pack-validity check of 22 §8.2,
  and the world-type content sets. `extract` is the program `cobolcraft-extract` (22). Dependencies:
  `formats -> shim`; `content -> formats, proto, shim`; `core -> content, formats, proto, shim`;
  `server -> core, content, formats, proto, shim`; `client -> core, content, formats, proto, shim`;
  `extract -> content, formats, proto, shim`.
- **Rationale.** Today the client owns the only zip, JSON, PNG and regex code (read: `client/src/zip.cob` has
  `ZIP-OPEN/CLOSE/COUNT/NAME/FIND/SIZE/READ`, `client/src/json.cob` has `JSON-PARSE` and friends), while the
  extraction tool, the server (data packs, 22 §8.3, §8.4) and the client all need them. Leaving them in `client`
  would make `core`, `server` and `extract` depend on the client or duplicate the code. Moving them removes the
  duplication before it exists. The static registries (block states, items, entity types, 46 ids) are needed by
  both `core` (rules, persistence, chunks) and `client` (block state to model, item to texture), so a package
  below both is the only place for them.
- **Alternatives.** (a) Put everything in `core` and make the client link it: the client already links `core` for
  single-player, but `extract` would then link the whole game. (b) Duplicate the readers: two zip readers drifting
  apart, a CRITICAL maintenance cost at this feature's size. (c) One `content` package holding formats too:
  `extract` would link the registry model for no reason and `formats` could not be reused by `proto`.

### R2. The jar's data is read by programs, never tabulated; the code registries are tabulated from the documents

- **Decision.** Documents 24, 25 and 46 (block registry, item registry, static registry ids) are tables of
  *code* values that are not in the jar's data files (22 §1, 24 §1 "Data versus code"). A build-time generator
  `tools/gen/gen_tables.py` (Python, stdlib only; build tooling may use any language, constitution Technology
  Constraints) parses those tables and writes copybooks under `content/copy/gen/`. The generated files are
  committed, marked generated (constitution 4.2 exclusion), and `make gate-tools` regenerates into a scratch
  directory and fails on any difference (the drift gate of 3.4). The data the jar does carry (models, block
  states JSON, recipes, loot, tags, worldgen JSON, structure NBT) is never tabulated: the extraction tool copies
  it and the loaders read it (README C2, C8).
- **Rationale.** The registry docs total 1.9 MB of regular Markdown tables (row example: `| 1 | stone | Block | -
  | 1 | 1 | 1 | 1.5 | 6.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | - |`, 24 part 1 §15). Transcribing
  by hand is neither reviewable nor repeatable; a generator with a drift gate keeps docs the single source
  (Principle II) and mirrors how `contract/` artifacts are kept from drifting.
- **Alternatives.** Hand transcription (the 001 style for 12 blocks; infeasible for 30,000 states). Reading the
  documents at run time (the game would depend on the docs folder). A binary data file shipped beside the
  binary (needs an install path the project does not have).

### R3. Generated table style: 400-character literal rows

- **Decision.** Generated copybooks hold the table bytes as `PIC X(<=400) VALUE "..."` rows, one fixed-width
  record layout per table, read through offset arithmetic by small accessor programs in `content/src` (which are
  hand-written and covered). Hand-authored small tables (the cobolcraft standard core) keep the one-FILLER-per-
  column style until they exceed about 2,000 lines.
- **Evidence.** Spike table above: 0.25 s against more than 4 minutes and 36 s. This also removes the
  per-package rebuild cost: every program that COPYs a table recompiles it.

### R4. Chunk and section model of the standard world

- **Decision.** Core and client cells become 16-bit block state ids (the standard registry has about 30,000
  states, so the 1-byte cell of `core/copy/CHUNKMEM.cpy` cannot hold them), the world height becomes the
  dimension's (overworld 384 blocks = 24 sections from y -64, Nether and End from their dimension types, 04 §6),
  light is stored as nibbles, and the maximum number of dimensions rises from 2 to 3. The cobolcraft type uses
  the same cell model with its 18 state ids. Memory is allocated per cached chunk as today (`CK-ADDR` pointer
  rows), so unused capacity costs nothing.
- **Rationale.** Evidence in the gap analysis (P-core-1 to P-core-4, P-client-1). The cobolcraft type is
  re-expressed in the shared model (README C3, decision 4) instead of keeping a second chunk layout.
- **Memory note.** One 24-section chunk is 98,304 cells x 2 bytes of state, plus nibble light of 2 x 49,152 bytes,
  about 295 KB; a view distance of 8 is 289 chunks per player (85 MB). The cache cap stays a constant of
  `CORESTATE.cpy` and is a tuning value of the plan, not a behaviour.

### R5. IEEE double arithmetic through `cc_f64` glue

- **Decision.** The `shim` package gains a module `cc_f64` of by-reference binary64 operations (add, subtract,
  multiply, divide, floor, square root, parse from text, and the libm functions documents 10 and 11 call for)
  and the engines that need bit-exact doubles (noise, density functions, climate, features, mob physics) call it.
  Engines whose results need not be bit-exact (movement already in `physics.cob`) keep `COMPUTE`.
  Constants that must be the nearest double are loaded by `cc_f64_parse` from their decimal text.
- **Rationale.** Evidence above: `COMPUTE` on doubles costs 1.17 microseconds per statement, so one chunk of
  terrain (an estimated 200,000 noise octave samples at 35 statements each) would take about 4 minutes; through
  the glue the same work is about 1 second. The glue passes values by reference and returns nothing, which is the
  ABI mismatch Principle I names (COBOL cannot receive a C double return). It contains no game logic: it adds,
  multiplies and calls libm.
- **Alternatives.** Fixed-point `BINARY-DOUBLE` (fast, 330,000 samples per second, but not IEEE, so the worked
  examples of 10 and 11 that SC-007 requires could not match). Accept the slow path (a 9 x 9 chunk start area
  would take minutes). A noise kernel in C (that would be game logic, which Principle I forbids).
- **Limit.** The estimate of 200,000 samples per chunk is the plan's own and is not measured; Risk R-P
  schedules a measurement in the first US11 slice and a per-tick chunk-generation budget.

### R6. Content sets and layers

- **Decision.** A *content set* is what a world type selects (world-types.md §1). `content` exposes one program
  family (`CONTENT-OPEN type`, then lookups for blocks, items, entity types, registries, tags, recipes, loot) over
  the four registry layers of 23 §2. The standard set reads the generated data pack through the loaders; the
  cobolcraft set is the hand-authored core of `cobolcraft-standard-core.md` and `standin-content.md` held in the
  same table shapes (the built-in layer), so the shared engines (break formula, recipes, loot, tags) run on
  both. The rules (movement, health, hunger, commands, crafting screens) are code shared by both sets.
- **Rationale.** README "The model in one paragraph": gameplay rules are shared, only content differs. A second,
  parallel engine for the cobolcraft type would double the code and break R2.
- **Consequence for 001's tables.** `core/copy/BLOCKS.cpy`, `ITEMS.cpy`, `RECIPES.cpy`, `MOBS.cpy` and the
  stand-in parts of `REGISTRY.cpy` and `RULES.cpy` are re-expressed as the cobolcraft layer (R6 gap rows
  P-core-2, P-core-6) and the stand-in rule constants (day length 30,000, hurt cooldown, fall damage) are deleted
  in favour of the shared rules (FR-041).

### R7. Pack stack and resources

- **Decision.** The client's pack stack becomes: built-in `cobolcraft` pack (level 1, fixed), generated `vanilla`
  pack when valid (level 2, fixed), user packs from `resourcepacks/` in the order of `options.txt`, server packs
  (22 §8.1, README C7). The atlas builder takes its sprite size from the packs (no fixed 128-pixel width and 128
  sprite cap: the Faithful pack alone has 1,297 block sprites), builds the padding and mip chain of 12 §2.2 and §2.3 to remove seams
  (US5), and animated sprites update their atlas cell each frame from the `.mcmeta` timing
  (14, FR-010). The shim's texture call gains mip levels and a sub-rectangle update (animation without
  re-uploading the atlas).
- **Evidence.** Gap rows P-client-2, P-client-3, P-shim-1; spike `spike_vk_limits` (16384 limit).

### R8. Options: `options.txt`

- **Decision.** Options persist in `options.txt` in the format of 13 §7.1 (`key:value` lines, the pack list as
  `resourcePacks:[...]`), replacing the gzip NBT `options.dat` that holds only `EnabledPacks` today
  (`client/src/game-dir.cob` OPTIONS-LOAD/SAVE). The old file is read once as a migration source and never
  written; this is the one place the plan keeps a legacy reader, and it is covered by an acceptance test
  (a Player's enabled packs survive the upgrade).
- **Rationale.** 13 §7.1 is the spec of the format; US16 and FR-022 require every listed option to persist.

### R9. Crafting, recipe book and menus

- **Decision.** The server owns the inventory menu (46 slots with the off-hand, 12 §5.6a), the crafting bench menu
  (3x3, 12 §5.6b) and the recipe-book state (27 §recipe unlocks, 13 §3.8, §3.9); the client renders what the
  menu packets say. The cobolcraft type adds `cobolcraft:crafting_bench` (operator-confirmed, FR-027) as
  content in the built-in layer; additional cobolcraft content needed to run under shared rules is added
  to the design documents first (FR-027). The 001 crafting screen (`client/src/screens/crafting.cob`, the C key
  handler in `screens/common.cob`) is deleted with its tests (FR-028).

### R10. Vanilla-client validation scope (US21, FR-039, SC-013)

- **Decision (the plan's, per the spec's Assumptions).** Two layers. (1) Automated, in the lanes:
  `contract_vanilla_*` tests of `core` and `content` assert, byte for byte against fixtures transcribed from
  documents 03, 04, 05, 06 and 46, that the standard-type server's configuration phase (registry data, tags,
  feature flags, known packs), Login packet and chunk encodings are those documents' bytes, and that ids and
  registry contents equal vanilla's tables (R8, C1, C14). (2) Manual, recorded: a real vanilla 26.3 client
  connects to a standard-type server in offline mode, passes configuration, enters play and decodes the spawn
  chunks; the evidence (the server console log lines, the client's reached state) is recorded in
  `quickstart.md` §9 once, at the terminal phase. Gameplay beyond joining and decoding is not in the scope.
- **Why not automated.** No vanilla client can be launched by a test (Dependency table; the launcher's libraries
  are not in the repository and the jar alone is not runnable). Whether to accept manual evidence for SC-013 is
  operator decision Q-1 (manual run accepted).

### R11. Server and single-player host

- **Decision.** The core still operates on byte streams (001 R7). The new settings are carried in `CORE-SETTINGS`
  (`world-type`, `generated-dir`, `seed` text) and one new entry point reports the packs check, so the server
  program and the client's host print the same reasons (22 §9.2). The server's configuration file gets the keys
  `world-type` and `generated-dir` (README Part 7 decision 2, 9, 16; `server.properties` stays out of scope).

### R12. Chunk generation scheduling

- **Decision.** The core generates chunks from a queue with a per-tick budget (a count of chunks per tick, a
  constant of `CORESTATE.cpy`), nearest to a player first, so a slow generation never blocks the 50 ms tick and
  the Player sees terrain arrive (the streaming of 001 US3 already works from the chunk cache). This is a
  hosting mechanism, not game behaviour: it changes when a chunk exists, not what it contains.

### R13. The F-key, off-hand and hand rendering control set

- **Decision.** `contract/copy/CCSHIM.cpy` gains the key codes F (70), F3 (292), F5 (294), plus the other key codes
  13 §5.1 and §7.3 list (all GLFW values), used through the existing event path
  (`CC-EV-KEY-DOWN`). The hand and third-person model use the existing entity renderer with a depth-clear
  between world and hand passes (`cc_vk_clear_depth`, one new shim call).

### R14. Open Pack Folder

- **Decision.** A shim call `cc_open_path(opener, path)` starts the opener (production passes `/usr/bin/open`) with
  the folder as its single argument and returns without waiting; the client creates `resourcepacks/` first
  (FR-008). How it is exercised by a test is decision Q-2 (the sanctioned opener double).

### R15. Deferred work and existing tickets (constitution 1.4)

- **Mechanism.** Spile tickets in `tickets/`, prefix `CC` (constitution Development Workflow); no convention gap.
- **Existing tickets in this feature's files.** CC-0003 (weather atlas bounded for any pack height), CC-0005
  (tests listen on the default port) and CC-0006 (creative cursor throws) name defects in files this feature
  rewrites (`weather-render`/`atlas`, server tests, the inventory screen and menu code) and change no specified
  behaviour, so the plan incorporates them (tasks in the lanes) and the tickets close when done. CC-0002 (chunk
  meshing performance) and CC-0004 (shutdown disconnect delivery) stay recorded: CC-0002 is profiling-driven
  and this feature's mesher rewrite is judged against it in Risk R-M; CC-0004 is server shutdown flow this
  feature does not touch. CC-0007 (lighting, sky, fog, clouds) is out of scope (FR-043).
- **Discoveries made by this plan.** None is deferred: every gap found is inside a package the feature touches
  and leaves specified behaviour unchanged. The spec's own inconsistencies are recorded in plan "Spec
  observations" and need no deferral.

### R16. E2E inventory

- **Decision.** The repository's E2E inventory is empty (001 R16: no E2E environment exists; Convergence tests
  run in-process through the single-player host and the TCP host on loopback) and this feature proposes no
  journey. Every acceptance scenario of the spec is observable below the top of the verification ladder: on the
  screen model and render list, on packets through the core's entry points, or in the extraction tool's own
  command line, so Principle 4.3's admission test (behaviour observable only through a real public entry point)
  is not met by any of them. The vanilla-client run (R10) is observable only through a real public entry point,
  but it cannot be automated, so it is a recorded manual verification and not an E2E scenario. See plan
  "E2E inventory".

## Handoff verification record (spec assumptions and clarifications)

| Spec statement | Verified against | Result |
|---|---|---|
| The jar and Faithful pack are in `tmp/` and git-ignored. | `ls tmp`; `.gitignore` has `/tmp/`. | Confirmed (both files present, sizes 41,483,720 and 13,116,019 bytes). |
| Generated packs live in a git-ignored folder under the game directory. | `.gitignore` (read) lists `build/`, `/tmp/`, test fixtures; no `generated/`. | The game directory default is `<game directory>/generated`; a Setup task adds `generated/` to `.gitignore` (22 Open question 8). |
| Documents 10 to 47 are complete for implementation, with open items in design README Part 8. | Read README Part 8. | Confirmed: 8.1 lists them; the plan maps each to the story that needs it (plan "Docs-first obligations"). |
| Standard choice stays selectable; Create refused with an explanation (Clarification 1). | `builtin-ui-art.md` §7.2 (cited by FR-003). | Plan: `create-world` screen change in `client`, message texts from the built-in language. |
| Bench is `cobolcraft:crafting_bench`; further cobolcraft content may be added (Clarification 2). | `cobolcraft-standard-core.md` §5 (cited by FR-027). | Plan: recorded in design documents before implementation (Foundational docs task). |
| Invented content stays in `cobolcraft:`; the two types share no content (Clarification 3). | `world-types.md` WT-25. | Plan: two content sets, no shared rows (R6). |
| Feature 001 stays valid except FR-040's supersessions. | `specs/001-cobolcraft-complete/spec.md` FR numbers. | Plan lists the superseded code (P-core-6, P-client-6). |
