# Contract: world folder (`core` writes and reads; server and single-player share it)

**Status**: frozen at plan time. **Docs-first**: transcribed in the Foundational phase into a new
`docs/protocol/07-nbt-and-anvil.md` §9 "CobolCraft world folder" (FR-004, FR-005); the doc is then the source of
truth. One format for server and single-player worlds (FR-004, US16-6, SC-010); the folder is copied as a unit
(US13-5).

## 1. Layout

```text
<world>/
  level.dat
  access.dat
  players/<offline-uuid>.dat              one per player who has been in the world
  dimensions/<namespace>/<path>/
    region/r.<rx>.<rz>.mca                chunks (07 §6 region files, 07 §7 chunk NBT)
    entities/r.<rx>.<rz>.mca              mobs and ground items (07 §6 region files, §3 below)
```

`<offline-uuid>` is the hyphenated lower-case UUID of 02 Offline mode. `<namespace>/<path>` is the dimension
key (`cobolcraft/main` and each extra dimension of the extension). All `.dat` files are gzip-compressed NBT
files (07 §5.1) with an unnamed root compound. Every root carries `DataVersion` (Int) = 5023.

## 2. NBT schemas

`level.dat`:

| Key | Type | Meaning |
|---|---|---|
| `LevelName` | String | World name (single-player list, US16-1) |
| `GameMode` | Int | Single-player chosen mode (US16-1). It is the game mode of new players when the world is hosted by the client (core-host-api `CS-HOST-KIND` 1, and 2 for the host; guests get the guest mode chosen when opening, US17-1); a dedicated server (`CS-HOST-KIND` 0) ignores it and uses `default-game-mode` |
| `Time` | Long | Time of day in ticks (US13-4) |
| `Spawn` | Compound | `Dimension` String, `X` `Y` `Z` Double, `Yaw` Float (US13-4, set by command) |
| `Weather` | Compound | One entry per dimension key: Compound `Kind` String (weather kind key), `Remaining` Int ticks (FR-014) |

Network entity ids are assigned per run and are not stored.

`access.dat`: `Operators`, `Bans`, `AllowList`: each a List of Compound `{Name: String, UUID: IntArray(4)}`
(FR-010 offline identity, FR-016, US13-4); and `AllowListEnforced` (Byte, 0 or 1): whether the allow-list is
enforced in this world. A new world takes it from the `allow-list` configuration setting (server) or off
(single-player); afterwards only the allow-list on/off commands change it and the setting no longer applies
(operator decision A2). Single-player worlds behave the same way.

`players/<uuid>.dat`:

| Key | Type | Meaning |
|---|---|---|
| `Name` | String | Offline name |
| `Dimension` | String | Dimension key |
| `Pos` | List of 3 Double | Feet position |
| `Rotation` | List of 2 Float | Yaw, pitch |
| `GameMode` | Int | 0 survival, 1 creative |
| `Health` | Float | Current health |
| `Food` | Int | Food level |
| `Inventory` | List of Compound | `{Slot: Byte, id: String, count: Int}`, only non-empty slots (slot numbering of data-model.md "Inventory") |
| `HeldSlot` | Int | Selected hotbar slot 0 to 8 |

## 3. Entity storage (`entities/` region files)

Each chunk payload (07 §6.3, zlib) is a compound `{DataVersion: Int, Position: IntArray(2) [cx, cz],
Entities: List of Compound}`. Entity compound:

| Key | Type | Applies to | Meaning |
|---|---|---|---|
| `id` | String | all | Entity type key (`cobolcraft:loose_item` or a mob type key) |
| `Pos` | List of 3 Double | all | Position |
| `Motion` | List of 3 Double | all | Velocity |
| `Rotation` | List of 2 Float | all | Yaw, pitch |
| `Health` | Float | mobs | Current health |
| `Item` | Compound `{id: String, count: Int}` | ground items | The stack |
| `Age` | Int | ground items | Ticks the despawn timer has run (remaining time = despawn time − Age; the timer runs only near players, US5 edge case) |

## 4. Chunk storage

07 §7 as written, with these CobolCraft values: `Status` = `minecraft:full`; block-state palette entries use
the block keys and properties of standin-content §1 (as extended); biome palette entries use the biome keys
of standin-content §4.3 (as extended); no block entities; `LastUpdate` = world time at save.

## 5. Behaviour

- A world folder without `level.dat` is created new (US13-1) with all enabled dimensions; chunks are
  generated on first use and saved when changed or when an entity is in them at save.
- Save writes every changed chunk, every chunk holding entities, the file of every online player and of every
  player who left since the previous save (US13 independent test), `level.dat`
  and `access.dat`.
