# Contract: core host API additions and world folder (`core` -> `server`, `client`; `core` <-> Server operator)

**Status**: frozen at plan time; amends `specs/001-cobolcraft-complete/contracts/core-host-api.md` and
`world-folder.md`. Materialized as `contract/copy/COREAPI.cpy` additions and, for the folder, a transcription into
`docs/protocol/07-nbt-and-anvil.md` §9 by the Foundational docs round.

## 1. `CORE-SETTINGS` additions

| Field | Meaning |
|---|---|
| `CS-WORLD-TYPE` PIC X(10) | `standard`, `cobolcraft`, or `debug` (the hidden test-tool type of plan "Operator addition: debug world"; it uses the standard content set); used only when a world is created, ignored for an existing world (its `level.dat` decides, WT-4). |
| `CS-GENERATED-DIR` PIC X(1024) | the generated directory (22 §5.1), default `<game directory>/generated`. |
| `CS-SEED-TEXT` PIC X(64) | creation seed text; empty means a random seed. The text-to-seed rule is the clean-room answer to seed text hash (11 Open question; a Foundational docs round). |
| `CS-GAME-DIR` PIC X(1024) | game directory (for `datapacks`-independent lookups and messages). |

`CS-HOSTILE-MOBS`, `CS-WEATHER-CHANGES`, `CS-EXTRA-DIMENSIONS`, `CS-PLAYER-COMBAT` stay and map to the gamerules
of README Part 7 decision 16.

## 2. Entry points

| Program | Parameters | Behaviour |
|---|---|---|
| `CORE-PACKS-STATUS` | generated directory, OUT status word, OUT reason text (English, the console wording of 22 §9.2) | Delegates to `CONTENT-PACKS-CHECK`; the host prints it (dedicated server) or the client shows the built-in-language text (title banner, Create refusal, world list row). |
| `CORE-WORLD-OPEN` | as before | New outcomes (each a defined status, not a crash): standard world and packs not `ok` -> refused with the status word (FR-004); a folder with `dimensions/` and no `level.dat`, or standard dimension folders and no `WorldType` -> refused (world-types.md §2.1 rules 3 and WT-24; exit code 10 on the server). New world: writes `WorldType`, `Seed`, `ContentJar`. **Status return (core lane, T0334):** the created flag carries it: 1 created, 0 opened, or minus a `CORE-WO-*` word (-1 packs not ok, -2 world data but no `level.dat`, -3 no or an unknown `WorldType`); a refused world is not open. |
| `CORE-TICK` | - | Also runs the chunk generation queue within its per-tick budget (R12) and the shared rule engines in the order of 33. |
| All other entry points | unchanged | The connection, input, output, closed and console entry points keep their shapes; the packets change (wire-delta). |

## 3. World folder additions (`level.dat`, region data)

`level.dat`: `WorldType`, `Seed`, `ContentJar` as flat root keys (world-types.md §2.1, 07 §9.7). Dimensions under
`dimensions/`: a standard world has three folders (overworld, Nether, End); a cobolcraft world has the two
`cobolcraft/` folders (07 §9.1, §9.7), selected by `WorldType`. Chunks store block states by key in palettes (07 §7.3,
WT-23). The save layout question between 07 and 33 (world-types.md Open question 12) is answered in 07 §9.7. An old
001 world opens as `cobolcraft` (data-model §6).

## 4. Contract tests

`core/tests/contract_coreapi_provider.cob` (extended: the new settings and outcomes), `server/tests/contract_coreapi_consumer.cob`
and `client/tests/contract_coreapi_consumer.cob` (extended: the new fields are filled and the new statuses are
handled), `core/tests/contract_world_folder_provider.cob` and `client/tests/contract_world_folder_client.cob`
(extended for the new keys and the three dimensions).
