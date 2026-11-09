# Data model: Client polish: visuals, controls and missing gameplay

**Feature**: `002-client-polish` | **Plan**: [plan.md](plan.md) | **Spec Key Entities**: spec.md "Key Entities"

Shapes only; every value comes from the document named in each row (FR-042). Feature 001's model
(`specs/001-cobolcraft-complete/data-model.md`) stays valid except where a row below says "changes". Names of
COBOL items are the plan's proposal for the contracts; the owning package fixes them in `contract/copy/` during
Foundational.

## 1. World type and content set (US2; owner `content`, read by `core`, `server`, `client`)

| Entity | Fields | Rules |
|---|---|---|
| World type | `standard` or `cobolcraft`; stored in `level.dat` as `WorldType` with `Seed` and `ContentJar` (world-types.md §2.1) | Chosen at creation, never changed (WT-4). Default `standard` when the generated packs are valid (README Part 7 decision 2). |
| Content set | the type, its blocks, items, entity types, registries, tags, recipes, loot, dimensions | Standard: static registries generated from 24, 25, 46 plus the generated data pack through the loaders of 23. Cobolcraft: the built-in layer (`cobolcraft-standard-core.md`, `standin-content.md`). The two share no rows (WT-25). |
| Debug world (hidden test tool) | type `debug`, `WorldType = debug` in `level.dat` | A flat grid of every block state of the standard set in state-id order (`docs/design/debug-world.md`), no terrain, no ticks; selected only by Ctrl-clicking the type button; needs valid packs. |
| Packs status | one of `ok`, `absent`, `incomplete`, `stale`, `damaged` | The check of 22 §8.2, run at start-up, at reload and before a standard world is created or opened. Drives the title banner, the Create refusal text (FR-003) and the server refusal (FR-004). |
| Accepted jar row | version id, size, SHA-256, world and protocol versions, pack formats | One row today (22 §4.1). Compiled into `content`; `extract` and the check both read it from `content`'s generated table, never a second copy. |

State transitions of a standard world's availability: `valid packs` -> `packs becomes stale/damaged` -> world not
opened (explanation shown) -> tool rerun -> `valid packs` (22 §8.6). A cobolcraft world has no transition.

## 2. Generated registry tables (R2, R3; owner `content`, generator `tools/gen/gen_tables.py`)

| Table | Source | Row (fixed width, text, in 400-character literal rows) |
|---|---|---|
| Block | 24 parts 1 to 8, section "The rows" | id, key, class, property list, state count, first state id, default state id, hardness, blast resistance, tool required, light, map colour, sound type, push reaction, instrument, flags |
| Block property | 24 part 1 §13 and later parts | name, value list |
| Block state | derived by the state id rule (24 part 1 §3) at load, not stored | state id -> (block, property values) |
| Item | 25 parts 1 to 8 and x1 | id, key, default components summary, block link, stack size, max damage, flags |
| Static registry id | 46 | registry, key, id |
| Entity type | 21 §2, 46 §11 | id, key, size, category |
| Tag names read by code | 24 part 1 §12 | tag key |

Quantities that bound the tables are read from the documents at generation time (about 1,200 blocks, 30,000
states, 1,500 items); the generator prints the counts and `make gate-tools` fails when they differ from the counts
the documents state in their validation sections (24 §17, 25, 46 §16), so a lost row is a gate failure.

## 3. Pack stack and generated packs (US1 to US4; owners `extract`, `content`, `client`)

| Entity | Fields | Rules |
|---|---|---|
| Generated directory | `<game directory>/generated` by default; marker `.cobolcraft-generated`, `manifest.txt`, `index.txt`, `vanilla-resources/`, `vanilla-data/`, `featurepacks/` | Layout and algorithm 22 §5 to §7; written to `<generated>.partial` and swapped in (22 §7.5). Git-ignored. |
| Extraction run | inputs (jar, game dir, generated dir, flags), outcome code `CCX-nnn`, counts | 22 §7.4 codes and exit statuses; idempotent (CCX-100). |
| Pack stack (client) | level 1 `cobolcraft` (built-in, fixed), level 2 `vanilla` (generated, fixed), level 3 user packs in `options.txt` order, level 4 server packs | 22 §8.1, README C7. A path resolves to the top-most pack that has it (08 §3.2); a pack's failure is a pack error, never a crash. |
| Pack stack (server, standard world) | level 1 `vanilla-data`, level 3 world `datapacks/` | 22 §8.3; feature packs not loaded. Cobolcraft world: empty. |
| User pack | zip (methods 0 and 8) or folder in `resourcepacks/`; id `file/<name>`; enabled flag and order | 08 §1.1 to §3, 22 §8.4; never enabled automatically. |
| Atlas (blocks and items) | sprite size from the packs (not a constant), cells stitched with padding, mip levels, animated cells with frame timers | 12 §2.2 and §2.3, 14; changes the 001 atlas (fixed 128 pixels wide, 128 sprites). |

## 4. Chunk, section and cell (changes 001 data-model §3; owners `core`, `client`, `proto` encoders)

| Field | 001 | Now |
|---|---|---|
| Cell | 1 byte block state id (0 to 17) | 2 bytes (state ids to about 30,000) |
| Sections per chunk | 16 (y 0 to 255) | the dimension's: from its dimension type `min_y` and `height` (04 §6, 23 §7.3.3): 24 in the overworld |
| Light | 1 byte per cell for sky and block | 4 bits per cell for each |
| Dimensions per world | at most 2 | 3 (overworld, Nether, End) |
| Chunk wire encoding | direct palette of 5 bits | paletted containers per 06 (single value, indirect, direct) with biome containers |

## 5. Player-facing records

| Entity | Fields | Rules | Owner |
|---|---|---|---|
| Option | name, default, range, current value | 13 §7.2 names, defaults and ranges; persisted in `options.txt` (13 §7.1); a missing, unreadable or out-of-range file yields defaults and the game starts (edge case). | `client` |
| Camera mode | first person, back, front | cycles on F5 (13 §6); not persisted. | `client` |
| Off-hand slot | one slot (slot 45 of the 46-slot inventory menu) | swap with the main hand on F (13 §4). | `core` (menu), `client` (view) |
| Break progress | per block and per player, stage 0 to 9 | The server computes progress per 13 §2.1 and broadcasts the destroy stage (13 §2.4, Block Destruction packet); the client draws the overlay with the pack's break-stage textures. | `core`, `client` |
| Crafting grid | 2x2 in the inventory menu, 3x3 in the bench menu, one result slot | matching per 13 §3.2 and §3.3; taking the result consumes ingredients (13 §3.6). | `core` |
| Recipe book | known recipes per player, craftable flags, filled-grid placement | unlocks per 27; client panel per 13 §3.9; placement per 13 §3.8. | `core`, `client` |
| Crafting bench (cobolcraft type) | block and item `cobolcraft:crafting_bench` | `cobolcraft-standard-core.md` §5, FR-027. | `content` (cobolcraft layer) |
| Crack overlay stage textures | ten stages | pack texture paths in `faithful-pack-mapping.md`; stage from progress 12 §4.2. | `client` |

## 6. Compatibility and migration

- `options.dat` (gzip NBT with `EnabledPacks`) is read once when `options.txt` is absent and never written again
  (R8). The world folder keeps CobolCraft's schemas (07 §9, README Part 7 decision 9); `level.dat` gains `WorldType`,
  `Seed`, `ContentJar` and an existing 001 world (no `WorldType`) opens as `cobolcraft` when it has no `dimensions/minecraft/` folder
  (world-types.md §2.1 rule 2; a folder with one is refused, rule 3 and exit code 10).
- The stand-in constants that FR-041 retires (health 30, food 24, day length 30,000, hurt cooldown, fall damage)
  have no migration: shared rules replace them in both types, and `level.dat` time values are re-based by the
  standard timeline (33) when an old world opens.
