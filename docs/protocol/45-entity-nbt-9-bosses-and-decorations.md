# 45. Entity NBT, part 9: bosses, decorations, boss-bar and dragon-fight saved data, and the all-entities index

| Item | Value |
|---|---|
| Covers | Round RS27 part 9: save and load keys, defaults and load behaviour of `ender_dragon` (with its phase manager state), `wither`, `end_crystal` (cross-reference only), `armor_stand`, `item_frame`, `glow_item_frame`, `painting`, `leash_knot`, `mannequin` and `cushion`; the shared `BlockAttachedEntity` and `HangingEntity` bases and their survival re-check after load; the two saved-data files that hold boss state (`ender_dragon_fight.dat`, `custom_boss_events.dat`) with their placement; and a closing index that maps every one of the 161 entity type keys to the documents that specify its NBT. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in [README.md](README.md); protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `EnderDragon`, `EnderDragonPart`, `EnderDragonPhase`, `EnderDragonPhaseManager`, the eleven `Dragon*Phase` classes (fields, `begin`, start of `doServerTick`), `EndCrystal`, `EnderDragonFight`, `DragonRespawnStage`, `WitherBoss`, `ServerBossEvent` users, `CustomBossEvents`, `CustomBossEvent` and `CustomBossEvent$Packed`, `BossEvent$BossBarColor`, `BossEvent$BossBarOverlay`, `ArmorStand`, `ArmorStand$ArmorStandPose`, `Rotations`, `BlockAttachedEntity`, `HangingEntity`, `ItemFrame`, `GlowItemFrame`, `Painting`, `VariantUtils`, `LeashFenceKnotEntity`, `Cushion`, `Mannequin`, `PlayerModelPart`, `Pose`, `HumanoidArm`, `DyeColor`, `ResolvableProfile` (+ `Partial`), `PlayerSkin$Patch`, `ExtraCodecs`, `Direction`, `EntityEquipment`, `EquipmentSlot`, `ItemStack`, `UUIDUtil`, `EntityReference`, `SavedDataStorage`, `SavedDataType` users, `ServerLevel`, `ServerChunkCache`, `MinecraftServer`, `DimensionType`, `LevelResource`, `PlayerList`, `EntityTypeIds`, `EntityTypes`. |
| Evidence rule | Every key, type, default, constant and ordering below was read in this round. "(inferred)" marks a deduction from the shape of code; "(recalled, not verified)" marks a statement not read. Each is repeated in Open questions. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001; design README Parts 0, 1, 4; GAP-8). Data rows (painting variants, loot tables, tags, dimension types) are not tabulated; schemas and engines are. |
| Siblings | 45-1 shared model and `Entity` base (keys, UUID and position forms, ItemStack compound, `Passengers`); 45-2 `LivingEntity` and `Mob` keys, equipment and drop chances; 45-3 player (also lists the mannequin keys, section 10); 45-4 to 45-7 mobs; 45-8 non-living entities (it is the authority for `end_crystal`). Behaviour: 21 sections 6 to 8, 44 part 9 sections 1 and 4 to 8. |

Notation as in 45-1: booleans are stored as Byte 0 or 1; "default" is the value used when a key is absent, has the wrong type, or fails its codec (the field then keeps its constructed value). Class names in backticks say where a fact was read. They are not the design.

## Contents

1. Placement and framing of the two saved-data files
2. Ender dragon entity
3. Ender dragon fight saved data (`ender_dragon_fight`)
4. Wither and end crystal
5. Custom boss events saved data (`custom_boss_events`)
6. Direction codecs, `BlockAttachedEntity` and `HangingEntity`: keys, load order, survival re-check
7. Item frame and glow item frame
8. Painting
9. Leash knot
10. Cushion
11. Armor stand
12. Mannequin
13. All-entities index
14. Worked examples
15. Validation
16. Open questions

---

## 1. Placement and framing of the two saved-data files

Both boss files are `SavedData` types written by `SavedDataStorage`. Framing is exactly as 45-6 section 12.3 states: gzip NBT (`NbtIo.writeCompressed`), root Compound `{data: <codec encoding>, DataVersion: Int 5023}`; on read a leading `1F 8B` selects gzip, otherwise plain NBT is accepted; only types marked dirty are written at a save; a file that exists but fails to decode is logged and the type falls back to its default value; a missing file also gives the default.

The file path is `<storage folder>/<namespace>/<path>.dat` (`Identifier.withSuffix(".dat")`, `resolveAgainst`). The storage folder is now read, which settles the "inferred" placement of 45-6 and 33:

| Type id | Owner object | Storage folder (read) | File |
|---|---|---|---|
| `minecraft:ender_dragon_fight` | one per dimension whose dimension type has `has_ender_dragon_fight` (`ServerLevel` constructor calls `computeIfAbsent` on its own storage, then `init`) | `ServerChunkCache` builds it as `<dimension folder>/data`, the dimension folder being `<world>/dimensions/<namespace>/<path>` (`DimensionType.getStorageFolder`: `<world>/dimensions` then `resolveAgainst` the dimension key) | `<world>/dimensions/minecraft/the_end/data/minecraft/ender_dragon_fight.dat` for the standard End |
| `minecraft:custom_boss_events` | the server (`MinecraftServer.customBossEvents`) | `<world>/data` (`LevelResource.DATA`, the string constant `data`) | `<world>/data/minecraft/custom_boss_events.dat` |

Edit for 07 section 9.1 (layout table): add `data/minecraft/<id>.dat` at the world root and `data/minecraft/<id>.dat` inside each `dimensions/<ns>/<path>/` folder, both with the section 9.1 `.dat` framing. The fight file exists only for a dimension with the fight flag.

---

## 2. Ender dragon entity (`minecraft:ender_dragon`, class `EnderDragon`, chain `Mob`)

Not marked no-save: it is stored in `entities/` like any mob. `checkDespawn` does nothing (never despawns). Its eight body parts (`EnderDragonPart`: head, neck, body, three tails, two wings) return `shouldBeSaved() = false` and are rebuilt by the constructor; they never appear in a compound.

### 2.1 Keys written after the `Mob` chain (45-1 section 5, 45-2)

| Key | Type | Written | Default on load | Meaning |
|---|---|---|---|---|
| `DragonPhase` | Int | always: the current phase's id | key absent: the phase stays what the constructor set (HOVERING, section 2.2). Present: `EnderDragonPhase.getById(v)`; a value below 0 or at least 11 gives HOLDING_PATTERN | current phase (table 2.2) |
| `DragonDeathTime` | Int | always | 0 | the `dragonDeathTime` counter of the death animation (21 section 6.4.4), not reset on load |
| `sitting_damage_received` | Float | always | 0.0 | health lost while in a sitting phase since the last take-off; at more than `0.25 * maxHealth` the dragon switches to TAKEOFF and resets it to 0 (read in `hurt`) |

Not saved: the flight history (`DragonFlightHistory`), growl timer (reset to 100), flap time, `fightOrigin` (constructed as `(0,0,0)`; the fight sets it only on a dragon it creates), the beam of crystals, and the `dragonFight` reference (re-linked, 2.4). Health, `DeathTime`, `HurtTime` and the rest come from 45-2.

### 2.2 Phase ids (`EnderDragonPhase`, id = creation order) and the manager

| Id | Phase | Id | Phase |
|---|---|---|---|
| 0 | HoldingPattern | 6 | SittingScanning |
| 1 | StrafePlayer | 7 | SittingAttacking |
| 2 | LandingApproach | 8 | ChargingPlayer |
| 3 | Landing | 9 | Dying |
| 4 | Takeoff | 10 | Hover (HOVERING) |
| 5 | SittingFlaming | | |

`EnderDragonPhaseManager`: one lazily created, cached instance per phase id; the constructor sets HOVERING; the synched phase default (`defineSynchedData`) is also HOVERING's id. `setPhase(p)` returns at once when `p` is the current phase; otherwise it calls `end()` on the old instance, switches, writes the id to the synched value on the server, and calls `begin()` on the new instance. **Correction to 21 section 6.4.3:** a dragon made by the constructor (for example a bare summon) starts in HOVERING, not HOLDING_PATTERN; HOLDING_PATTERN is set only by the fight's `createNewDragon` and by the fallbacks below.

### 2.3 Transient phase state: reset by load

Only the phase id is persisted. Loading calls `setPhase`, so `begin()` of the loaded phase runs (except HOVERING, which is already current) and all instance fields start at their constructed values:

| Phase | Fields lost on load | Behaviour after load (read) |
|---|---|---|
| HoldingPattern, LandingApproach | path, target | `begin` clears both; the first tick has no target and picks a new one |
| StrafePlayer | attack target, path, fireball charge, direction | no attack target: logs the string "Skipping player strafe phase because no player was found" and sets HOLDING_PATTERN |
| Landing, Hover | target | `begin` clears the target; re-picked in the tick |
| Takeoff | first-tick flag, path, target | `begin` sets first tick again and clears path and target; a new path is found |
| SittingFlaming | `flameTicks`, `flameCount` | `begin` sets `flameTicks = 0` and increments `flameCount` (constructed 0, so it restarts at 1; the phase ends after its attack count, constant 4, then TAKEOFF or SITTING_SCANNING per 44-9) |
| SittingScanning, SittingAttacking | `scanningTime`, `attackingTicks` | `begin` sets 0 (idle 100, roar 40 ticks run again) |
| ChargingPlayer | target, `timeSinceCharge` | no target: logs the string "Aborting charge player as no target was set." and sets HOLDING_PATTERN |
| Dying | target, `time` | `begin` clears both; the target (podium surface, `MOTION_BLOCKING`) is recomputed in the tick |

Consequence: a saved fight resumes in the same phase family but loses in-flight targets; strafe and charge fall back to HOLDING_PATTERN.

### 2.4 Re-linking to the fight

Each `aiStep`, when the entity's `dragonFight` field is null and the level is a server level whose `getDragonFight()` is non-null and whose `dragonUUID()` equals the entity's UUID, the field is set. A dragon whose UUID does not match runs without a fight: no boss bar updates and no death hooks (`updateDragon` is skipped in `tickDeath` when the field is null). The fight itself adopts a living dragon at its first scan (3.3).

---

## 3. Ender dragon fight saved data (`minecraft:ender_dragon_fight`)

Controller behaviour (constants, stages, portal, gateways, boss bar) is in 21 section 6.4.5. This section is the persisted form.

### 3.1 Schema (`EnderDragonFight.CODEC`, a record)

| Key | Type | Default on load | Written | Field |
|---|---|---|---|---|
| `needs_state_scanning` | Byte | **true** (1) | always | first-tick legacy scan pending |
| `dragon_killed` | Byte | false | always | `dragonKilled` |
| `previously_killed` | Byte | false | always | `hasPreviouslyKilledDragon` |
| `respawn_stage` | String | absent (no sequence) | only while a sequence runs | `start`, `preparing_to_summon_pillars`, `summoning_pillars`, `summoning_dragon`, `end` |
| `respawn_time` | Int | 0 | always | ticks into the current respawn sequence |
| `dragon_uuid` | Int Array(4) | absent | only when known | UUID of the fight's dragon (`UUIDUtil.CODEC`, lenient: a malformed value is treated as absent) |
| `exit_portal_location` | Int Array(3) | absent | only when known | block position (lenient) |
| `gateways` | List<Int> | empty | read: `lenientOptionalFieldOf(name, default)`; whether a default-equal value is omitted on write is not read (inferred: written; see Open question 12) | remaining gateway indexes, in pop order (lenient) |
| `respawn_crystals` | List<Int Array(4)> | empty | read: `optionalFieldOf(name, default)` (not lenient); default-equal omission on write not read (inferred: written; Open question 12) | `EntityReference` UUIDs of the crystals used by a respawn |

Only `needs_state_scanning`, `dragon_killed`, `previously_killed` and `respawn_time` use `ExtraCodecs.optionalAlwaysPresentFieldOf` (read), whose name states that the key is always written. The Mojang serialization library (`com.mojang.serialization`) is not in the jar, so the write rule of the plain `optionalFieldOf(name, default)` and `lenientOptionalFieldOf(name, default)` fields is unread; a decoder must accept both presence and absence, and a writer that always writes them is safe either way. My recollection is that the library omits default-equal values (recalled, not verified).

Default object (`createDefault`, used when no file exists): needs scan true, killed false, previously killed false, no stage, time 0, no UUID, no portal, empty lists. The type's constructor sets the player-scan counter to 21 (so the first tick scans players) and the origin is `(0,0,0)` (`ServerLevel` passes `BlockPos.ZERO`).

### 3.2 `init` (every load of the End level)

Builds the boss event (random UUID, title `entity.minecraft.ender_dragon`, PINK, PROGRESS, play-music and fog on, darken off; not persisted) and the valid-player test. If `gateways` is empty it is filled with 0..19 shuffled with a thread-local generator seeded with the level seed (`RandomSource.createThreadLocalInstance(seed)`, `Util.shuffle`) and marked dirty. So an existing file with a non-empty list keeps its order; a new world gets a seed-determined order.

### 3.3 First tick after load

The tick runs only while the boss event has players (otherwise the arena ticket is removed). With players present and the arena loaded (chunks -8..8 around the origin at FULL status and block ticking), when `needs_state_scanning` is true `scanState` runs, the flag is cleared and the data marked dirty:

1. If an active exit portal exists: `previously_killed = true`; otherwise `previously_killed = false` and, if no portal pattern is found, an inactive portal is built.
2. Living dragons of the level (`ServerLevel.getDragons`: entities of type `ender_dragon` passing a predicate): none gives `dragon_killed = true`; otherwise the first one's UUID becomes `dragon_uuid`, `dragon_killed = false`, and if the portal had to be built (no portal) that dragon is discarded and the UUID cleared.
3. If not previously killed and `dragon_killed` is true, `dragon_killed` is reset to false.

Tick order (read from `EnderDragonFight.tick`):

1. The boss event visibility is set to `not dragon_killed`. The player-scan counter is incremented; at 20 or more `updatePlayers` runs and the counter resets (constructed 21, so the first tick scans).
2. If the boss event has no players: the `DRAGON` ticket of radius 9 at chunk (0,0) is removed and the tick ends. Otherwise that ticket is added (every tick).
3. If the arena is not loaded (`isArenaLoaded`) the tick returns here, before `scanState`.
4. `needs_state_scanning` scan as above.
5. If a respawn stage exists: the `respawn_crystals` resolve through `EntityReference` against the level and unresolved ones drop out; if none remain the sequence aborts and the tick returns (the step 6 block does not run); otherwise the stage ticks with the value `respawn_time` had BEFORE this tick (the field is post-incremented: the old value is passed to the stage, the stored field becomes old + 1; read in the bytecode as a duplicate of the field, an increment and a store that leaves the old value as the argument) and the data is marked dirty. By contrast the player-scan and other counters in this method are pre-incremented. Execution then continues to step 6 in the same tick; the stage tick and step 6 are not exclusive.
6. If `dragon_killed` is false: with `dragon_uuid` null `findOrCreateDragon` runs this tick and `ticksSinceDragonSeen` is reset to 0 (read: the null branch jumps straight to the call); with a UUID the counter is incremented and the call (and reset) happens when the incremented value reaches 1200. Then `ticksSinceCrystalsScanned` is incremented and at 100 `updateCrystalCount` runs and the counter resets. `updateDragon` (called by the dragon's tick) resets the dragon-seen counter.

`findOrCreateDragon` adopts the first living dragon or calls `createNewDragon` (type `ender_dragon`, reason EVENT, `setDragonFight`, `setFightOrigin`, phase HOLDING_PATTERN, placed at `(origin.x, 128 + origin.y, origin.z)` with yaw `nextFloat() * 360`, pitch 0, UUID stored, dirty).

`setDirty` is called by: `init` (gateways), scan, first-tick flag, stage ticks, `findOrCreateDragon`, `setRespawnStage`, portal finding and spawning, `setDragonKilled`, gateway spawn and removal, `createNewDragon`, abort and start of a respawn. Counters `ticksSinceDragonSeen`, `ticksSinceCrystalsScanned`, `aliveCrystals` and the player-scan counter are not saved.

---

## 4. Wither and end crystal

### 4.1 `minecraft:wither` (`WitherBoss`, chain `Monster`, `Mob`)

| Key | Type | Written | Default | Meaning |
|---|---|---|---|---|
| `Invul` | Int | always | 0 | `getInvulnerableTicks()`: remaining spawn-invulnerability ticks (starts at 220 in `makeInvulnerable`) |

After the base keys are read, a custom name (`CustomName`, 45-1) is copied to the boss bar. `setCustomName` also updates the bar title.

Boss bar: a `ServerBossEvent` created in the constructor with a random UUID, the display name, PURPLE, PROGRESS, darken-screen on. **Nothing of it is saved.** Rebuilt state: title from the custom name; progress each server tick: while `Invul > 0` it is `1 - Invul / 220` (the counter decrements first), otherwise `health / maxHealth`; players are added and removed by `startSeenByPlayer` and `stopSeenByPlayer` (tracking). Also not saved: head target ids, per-head timers, block-destroy timer. A loaded Wither with `Invul > 0` runs only this branch in `customServerAiStep` (the base AI step and head logic are skipped): the counter is decremented, progress set, and when the new value is 0 or less the Wither explodes at its eye height (`ExplosionInteraction.MOB`, power 7.0, no fire) and, unless silent, plays global level event 1023 at its block position; the counter is stored, and when `tickCount % 10 == 0` it heals 10.0 (during the whole charge-up). `hurtServer` refuses damage that `isInvulnerableTo` refuses, damage in tag `WITHER_IMMUNE_TO`, damage whose entity is another Wither, and, while `Invul > 0`, damage not in `bypasses_invulnerability`. `makeInvulnerable()` (build) sets `Invul = 220`, progress 0 and health to one third of the maximum. In `Peaceful` difficulty a Wither whose type is not allowed in peaceful is discarded in `checkDespawn`; otherwise it never despawns.

### 4.2 `minecraft:end_crystal` (cross-reference)

Keys `beam_target` (Int Array(3), omitted when null) and `ShowBottom` (Byte, always written, default **true**) are specified in 45-8 and confirmed here. The beam target is absolute. The fight stores respawn crystals only as UUIDs (3.1); their beams persist because each crystal saves its own `beam_target`. A crystal ticking in a dimension with a fight places fire at its block when that block is air.

---

## 5. Custom boss events saved data (`minecraft:custom_boss_events`)

Created by commands (`/bossbar`, 16) and held by the server. Dragon and Wither bars are not in this file (sections 3 and 4).

### 5.1 Schema

`data` is a map from event id (Identifier string key, `namespace:path`) to a record (`CustomBossEvent$Packed`):

| Key | Type | Default | Notes |
|---|---|---|---|
| `Name` | text component | required | title |
| `Visible` | Byte | false | |
| `Value` | Int | 0 | |
| `Max` | Int | 100 | |
| `Color` | String | `white` | `pink`, `blue`, `red`, `green`, `yellow`, `purple`, `white` |
| `Overlay` | String | `progress` | `progress`, `notched_6`, `notched_10`, `notched_12`, `notched_20` |
| `DarkenScreen` | Byte | false | |
| `PlayBossMusic` | Byte | false | |
| `CreateWorldFog` | Byte | false | |
| `Players` | List<Int Array(4)> | empty | UUIDs of players assigned (`UUIDUtil.CODEC_SET`) |

Read: every optional key uses `optionalFieldOf(name, default)` (the numbers and flags through the primitive codecs). Whether a default-equal value is omitted on write is not read (inferred: written; Open question 12). The event's own UUID (for the Boss Event packet) is random per run and not saved.

### 5.2 Load and runtime

`CustomBossEvent.load` sets visibility, `Value` (progress = clamp(value / max) with the max still 100), then `Max` (progress recomputed), colour, overlay, the three flags, and copies the UUID set. A new event starts at value 0, max 100, white, progress, empty players, progress 0. `setValue` and `setMax` set progress to `clamp(value / max, 0, 1)` as a float and mark the file dirty. The title shown to players is the name wrapped in square brackets. Only online players hold the bar: the `Players` set is UUIDs; `PlayerList.placeNewPlayer` calls `onPlayerConnect` (adds the player when their UUID is in the set), `remove` calls `onPlayerDisconnect` (removes the connection but keeps the UUID). Wire: Boss Event 05a 0x09.

---

## 6. Direction codecs, `BlockAttachedEntity` and `HangingEntity`

### 6.1 Legacy direction ids (`Direction.LEGACY_ID_CODEC`, `LEGACY_ID_CODEC_2D`)

Both are `Byte` on disk. 3D id: DOWN 0, UP 1, NORTH 2, SOUTH 3, WEST 4, EAST 5; decode is `from3DDataValue(v)` = element `abs(v % 6)`. 2D id: SOUTH 0, WEST 1, NORTH 2, EAST 3 (vertical directions have no 2D id); decode `from2DDataValue(v)` = element `abs(v % 4)`. So out-of-range bytes wrap rather than fail. The stored byte is the direction's `data3d` value (3D codec) or `data2d` value (2D codec) narrowed with `i2b`. The vertical directions carry `data2d` = -1 (read in their constructor arguments) and the 2D codec has no vertical filter, so a vertical direction has no valid 2D id: it would be written as byte -1, which decodes to `abs(-1 % 4)` = 1 = WEST; writers must therefore never pass a vertical direction to the 2D codec (the horizontal-only callers are not enumerated here).

### 6.2 Keys

| Key | Type | Written | Load |
|---|---|---|---|
| `block_pos` | Int Array(3) | always (every `BlockAttachedEntity` that is saved) | present and within 16.0 of the entity's block position: becomes `pos`. Otherwise "Block-attached entity at invalid position" is logged and `pos` keeps the value `Entity.load` gave it (`setPos(Pos)` makes `pos = floor(Pos)`) |

`HangingEntity` adds no keys; its direction is saved by the concrete class (7, 8). Default direction before any read: SOUTH.

### 6.3 Load order and effect on `Pos`

1. `Entity.load` applies `Pos`; `BlockAttachedEntity.setPos` sets `pos = BlockPos.containing(Pos)` and recomputes the box (for a hanging entity the position is then moved to the box centre).
2. `readAdditionalSaveData` of the concrete class (7.2, 8.2). `block_pos` replaces `pos`.
3. `setDirection(d)` (hanging classes) sets yaw and recomputes the box from `pos`, direction and (painting) variant; the entity position becomes the new box centre.

So the saved `Pos` is only a fallback: the final position is always derived from `block_pos`, direction and size. This matters because the box centre of an even-sized painting lies on a block boundary (see example 14.3).

### 6.4 Survival re-check (read)

There is no check at load. On the server each tick: `checkBelowWorld`, then `ticksSinceLastCheck += 1`; at 100 it resets to 0, runs `tickAtCheckInterval` (empty; the cushion overrides it) and, if the entity is not removed and `survives()` is false, calls `discard()` and `dropItem(level, null)`. `ticksSinceLastCheck` is not saved, so the first check is 100 ticking ticks after load (entities in non-ticking chunks do not count). Survival rules and drops are in 44 part 9 sections 5 and 8; the leash knot is in 9. `survives` per class: item frame (fixed always true), painting and base (collision and support box), knot (block at `pos` is in block tag `fences`), cushion (anchor below and not buried).

---

## 7. Item frame and glow item frame (`ItemFrame`, `GlowItemFrame`)

`glow_item_frame` has no save or read override: same keys and defaults.

### 7.1 Keys

| Key | Type | Written | Default on load |
|---|---|---|---|
| `block_pos` | Int Array(3) | always | 6.2 |
| `Item` | Compound (`ItemStack.CODEC`, 45-1 section 8) | only when the stack is non-empty | absent or undecodable: empty |
| `ItemRotation` | Byte | always | 0 |
| `ItemDropChance` | Float | always | 1.0 |
| `Facing` | Byte, 3D legacy id | always | DOWN (id 0) |
| `Invisible` | Byte | always | false |
| `Fixed` | Byte | always | false |

### 7.2 Read order and effects

Order: parent (`block_pos`), `Item`, `ItemRotation`, `ItemDropChance`, `Facing`, `Invisible`, `Fixed`. `Item` (default empty) is installed as follows: if the frame already holds a non-empty item that does not match the loaded stack (`ItemStack.matches`), `removeFramedMap` is called on the old stack first (a filled map removes this frame's position and entity id from its saved map data); then `setItem(stack, false)` runs: count forced to 1 for a non-empty stack, and the add-item sound (`ITEM_FRAME_ADD_ITEM`, volume 1, pitch 1) is played whenever the stack is non-empty, even on load. The boolean suppresses only the comparator update (`updateNeighbourForOutputSignal`). Rotation is stored as `value % 8` using the Java remainder, so a negative byte stays negative (inferred from the single remainder instruction). `Facing` goes through `setDirection`: horizontal frames get pitch 0 and yaw `2D id * 90`; vertical frames get yaw 0 and pitch `-90` times the axis step (UP -90, DOWN +90); then the box is rebuilt (0.75 square, 1.0 with a map). A frame whose `Fixed` is true always survives.

---

## 8. Painting (`Painting`)

### 8.1 Keys

| Key | Type | Written | Default |
|---|---|---|---|
| `facing` | Byte, 2D legacy id | first (before the parent) | SOUTH |
| `block_pos` | Int Array(3) | by the parent | 6.2 |
| `variant` | String, painting-variant id | when the holder has a registry key | absent, unknown id or unregistered: the synched default, which is `VariantUtils.getAny` = the registry entry with the lowest network id (`MappedRegistry.getAny` returns `byId.getFirst()`); empty registry throws |

Read order: `facing` read first, then the parent (`block_pos`), then `setDirection(facing)` (must be horizontal), then the variant (`setVariant`, which changes the box). Variant data (`width`, `height`, `asset_id`, optional `title`, `author`) is data-pack content (44 part 9 section 5.4); only the id is stored.

---

## 9. Leash knot (`minecraft:leash_knot`, `LeashFenceKnotEntity`)

Registered `noSave` (45-1 section 4.3): never written to a chunk, and both `addAdditionalSaveData` and `readAdditionalSaveData` are empty, so it has no `block_pos`. Persistence is carried by each leashed mob's `leash` data (a block position for a fence leash, 45-1 section 10.1); on load `getOrCreateKnot(level, pos)` looks for a knot among `LeashFenceKnotEntity` entities in the box `pos - 1` to `pos + 1` whose block position equals `pos`, and otherwise creates one (constructed with `setPos(x, y, z)` of the integer block coordinates; the box centre is the block position plus `(0.5, 0.375, 0.5)`) and adds it. The knot discards itself when its last leashee is removed (`notifyLeasheeRemoved`, 21 section 8.15).

---

## 10. Cushion (`minecraft:cushion`, `Cushion`, chain `BlockAttachedEntity`)

| Key | Type | Written | Default |
|---|---|---|---|
| `block_pos` | Int Array(3) | always | 6.2 |
| `color` | String, dye name | always | `white` |

Dye names (ordinal order): white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black. Bounding box is the type's own size at the entity position (`recalculateBoundingBox` uses `makeBoundingBox`, and `setPos` sets the raw position first), so unlike frames the saved `Pos` is meaningful. Every 100 ticks `tickAtCheckInterval` applies fluid and fire effects (44 part 9 section 8.1) and the survival check of 6.4 follows.

---

## 11. Armor stand (`minecraft:armor_stand`, `ArmorStand`, chain `LivingEntity`)

### 11.1 Keys written after the `LivingEntity` chain (equipment is a `LivingEntity` key, below)

| Key | Type | Written | Default |
|---|---|---|---|
| `Invisible` | Byte | always | false |
| `Small` | Byte | always | false |
| `ShowArms` | Byte | always | false |
| `DisabledSlots` | Int | always | 0 |
| `NoBasePlate` | Byte | always (`not showBasePlate`) | false |
| `Marker` | Byte | only when true | false |
| `Pose` | Compound | always (read: stored after the `Marker` branch with no condition around it) | see 11.2 |

Bit meaning of `DisabledSlots` and the slot ids: 44 part 9 section 4.1 (bit `id` blocks the slot, `id + 8` blocks taking, `id + 16` blocks putting). Reading `Marker` also sets `noPhysics = !hasPhysics()`.

### 11.2 `Pose` (`ArmorStandPose.CODEC`)

Compound with optional keys `Head`, `Body`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg`, each a `List<Float>` of exactly 3 (`Rotations.CODEC`: a list of another length fails decoding of that field; the fields use `optionalFieldOf(name, default)`, not lenient, so whether the failure drops only that limb or the whole `Pose` is (inferred: whole `Pose`; Open question 12)). Defaults in degrees: Head (0,0,0), Body (0,0,0), LeftArm (-10,0,-10), RightArm (-15,0,10), LeftLeg (-1,0,-1), RightLeg (1,0,1) (44 part 9 section 4.1). Each decoded `Rotations` is normalised (non-finite becomes 0, then `% 360`). Whether default-equal limbs are written is not read (inferred: written; Open question 12).

### 11.3 Equipment

The `equipment` compound (`EntityEquipment.CODEC`, 45-2): a map from slot name to `ItemStack.CODEC`, with empty stacks omitted on write. Slot names: `mainhand`, `offhand`, `feet`, `legs`, `chest`, `head`, `body`, `saddle`. An armor stand also writes `Health`, `HurtTime`, `DeathTime` and the other `LivingEntity` keys (45-2).

---

## 12. Mannequin (`minecraft:mannequin`, `Mannequin`, chain `Avatar`)

Keys are tabulated in 45-3 section 10. This section settles its open question on the codecs.

| Key | Form | Written | Default on load |
|---|---|---|---|
| `profile` | `ResolvableProfile.CODEC` (12.1) | always | keeps the empty static profile |
| `hidden_layers` | List<String> of hidden model parts (12.2) | always | all seven layers shown (byte 127) |
| `main_hand` | String `left` or `right` | always | `right` (`Avatar.DEFAULT_MAIN_HAND`) |
| `pose` | String (12.3) | always | `standing` |
| `immovable` | Byte | always | false |
| `description` | text component | only when a description exists and differs from the default (`entity.minecraft.mannequin.label` translatable) | the default description |
| `hide_description` | Byte | written true only when the description is null | false |

Write order is as the table; read order is `profile`, `hidden_layers`, `main_hand`, `pose`, `immovable`, `hide_description`, `description`.

### 12.1 `ResolvableProfile.CODEC`

Either a bare String (a player name, 0 to 16 characters, validated by `ExtraCodecs.PLAYER_NAME`; it becomes a name-only dynamic profile), or a Compound (`FULL_CODEC`) made of two merged parts. Profile part, one of: the stored game profile (`id` Int Array(4), `name` String 0..16 (`PLAYER_NAME`), optional `properties`), or the partial profile (optional `name`, optional `id`, optional `properties`, default empty). Skin patch part, all optional: `texture`, `cape`, `elytra` (Identifier strings), `model` (`StringRepresentable.fromEnum` on `PlayerModelType`; the serialized name is the `id` field: `slim` or `wide`, read. `default` is only the separate `legacyServicesId` of WIDE and is not accepted by this NBT codec). `properties` is either a map String to List<String> or a list of at most 16 property records (`PROPERTY_MAP`) with fields `name` and `value` (strings) and `signature` (String, `optionalFieldOf` without default, so optional; read). `PLAYER_NAME` is a string of length 0 to 16 additionally validated by `StringUtil.isValidPlayerName`: length at most 16 and every char code strictly between 32 and 127 (33 to 126). The server never resolves a dynamic profile (44 part 9 section 8.2), so it stores and forwards what it read.

### 12.2 `hidden_layers`

`PlayerModelPart` names and bits (mask = `1 << bit`): `cape` 0, `jacket` 1, `left_sleeve` 2, `right_sleeve` 3, `left_pants_leg` 4, `right_pants_leg` 5, `hat` 6. Decode: start from 127 and clear the bit of each listed part; encode: list every part whose bit is clear, in the order above. An unknown name makes the list invalid, giving the default 127.

### 12.3 `pose`

Pose names are `standing`, `fall_flying`, `sleeping`, `swimming`, `spin_attack`, `crouching`, `long_jumping`, `dying`, `croaking`, `using_tongue`, `sitting`, `roaring`, `sniffing`, `emerging`, `digging`, `sliding`, `shooting`, `inhaling`. The mannequin accepts only `standing`, `crouching`, `swimming`, `fall_flying`, `sleeping`; any other pose is a decode error and the load keeps `standing`.

---

## 13. All-entities index

Verification performed on the artifact: `EntityTypeIds` holds 161 distinct key strings (constant pool of its static initialiser) and `EntityTypes.<clinit>` makes 161 references to them. The key set equals the key set of the 161 rows of 21 section 2 (set difference empty) and equals the 161 keys of the 45-1 section 12 table (set difference empty). The table below assigns each key its **primary** document by what each sibling's Covers line states as written (not by the planning table of 45-1 section 12), and lists other documents that also describe it. Primary owner counts: part 3: 1; part 4: 34; part 5: 32; part 6: 10; part 7: 12; part 8: 63; part 9: 9. Total 161, each key once. `end_crystal` is primary in part 8 (its Covers line lists it, and part 8 states it is the authority); this part confirms its keys in 4.2.

Reconciliation with the sweep in 45-7 section 10: that sweep assumed owners before its siblings existed. Differences now known: (a) guardian, elder_guardian, giant and sulfur_cube are documented in 45-5 as primary and again in 45-7 section 11; (b) item, experience_orb, falling_block, tnt, lightning_bolt, area_effect_cloud, interaction, marker, the three displays and ominous_item_spawner are in 45-8 as primary and again in 45-7 section 11; (c) mannequin is in 45-3 section 10, 45-7 section 11 and here; cushion in 45-7 section 11 and here; (d) hoglin and vex are in both 45-5 and 45-6; evoker_fangs in 45-6 and 45-8; zombie_villager in 45-5 with shared helpers in 45-6; (e) hoglin, piglin, piglin_brute, blaze, ghast, magma_cube, phantom, wither_skeleton, zoglin, zombified_piglin sit in 45-1's part 7 row but are documented in 45-5 or 45-6. No key is undocumented. Where two documents give the same key, the primary document wins (45-8 states it is the authority for its entities); keys read for the duplicate rows agree where compared (cushion, mannequin, end_crystal, vex, evoker_fangs).

| Key | Primary document | Also described in |
|---|---|---|
| `acacia_boat` | 45-8 |  |
| `acacia_chest_boat` | 45-8 |  |
| `allay` | 45-4 |  |
| `area_effect_cloud` | 45-8 | 45-7 section 11 |
| `armadillo` | 45-4 |  |
| `armor_stand` | 45-9 |  |
| `arrow` | 45-8 |  |
| `axolotl` | 45-7 |  |
| `bamboo_chest_raft` | 45-8 |  |
| `bamboo_raft` | 45-8 |  |
| `bat` | 45-4 |  |
| `bee` | 45-4 |  |
| `birch_boat` | 45-8 |  |
| `birch_chest_boat` | 45-8 |  |
| `blaze` | 45-5 |  |
| `block_display` | 45-8 | 45-7 section 11 |
| `bogged` | 45-5 |  |
| `breeze` | 45-5 |  |
| `breeze_wind_charge` | 45-8 |  |
| `camel` | 45-4 |  |
| `camel_husk` | 45-4 |  |
| `cat` | 45-4 |  |
| `cave_spider` | 45-5 |  |
| `cherry_boat` | 45-8 |  |
| `cherry_chest_boat` | 45-8 |  |
| `chest_minecart` | 45-8 |  |
| `chicken` | 45-4 |  |
| `cod` | 45-7 |  |
| `command_block_minecart` | 45-8 |  |
| `copper_golem` | 45-4 |  |
| `cow` | 45-4 |  |
| `creaking` | 45-5 |  |
| `creeper` | 45-5 |  |
| `cushion` | 45-9 | 45-7 section 11 |
| `dark_oak_boat` | 45-8 |  |
| `dark_oak_chest_boat` | 45-8 |  |
| `dolphin` | 45-7 |  |
| `donkey` | 45-4 |  |
| `dragon_fireball` | 45-8 |  |
| `drowned` | 45-5 |  |
| `egg` | 45-8 |  |
| `elder_guardian` | 45-5 | 45-7 section 11 |
| `end_crystal` | 45-8 | 45-9 section 4.2 |
| `ender_dragon` | 45-9 |  |
| `ender_pearl` | 45-8 |  |
| `enderman` | 45-5 |  |
| `endermite` | 45-5 |  |
| `evoker` | 45-6 |  |
| `evoker_fangs` | 45-8 | 45-6 |
| `experience_bottle` | 45-8 |  |
| `experience_orb` | 45-8 | 45-7 section 11 |
| `eye_of_ender` | 45-8 |  |
| `falling_block` | 45-8 | 45-7 section 11 |
| `fireball` | 45-8 |  |
| `firework_rocket` | 45-8 |  |
| `fishing_bobber` | 45-8 |  |
| `fox` | 45-4 |  |
| `frog` | 45-4 |  |
| `furnace_minecart` | 45-8 |  |
| `ghast` | 45-5 |  |
| `giant` | 45-5 | 45-7 section 11 |
| `glow_item_frame` | 45-9 |  |
| `glow_squid` | 45-7 |  |
| `goat` | 45-4 |  |
| `guardian` | 45-5 | 45-7 section 11 |
| `happy_ghast` | 45-4 |  |
| `hoglin` | 45-6 | 45-5 |
| `hopper_minecart` | 45-8 |  |
| `horse` | 45-4 |  |
| `husk` | 45-5 |  |
| `illusioner` | 45-6 |  |
| `interaction` | 45-8 | 45-7 section 11 |
| `iron_golem` | 45-4 |  |
| `item` | 45-8 | 45-7 section 11 |
| `item_display` | 45-8 | 45-7 section 11 |
| `item_frame` | 45-9 |  |
| `jungle_boat` | 45-8 |  |
| `jungle_chest_boat` | 45-8 |  |
| `leash_knot` | 45-9 |  |
| `lightning_bolt` | 45-8 | 45-7 section 11 |
| `lingering_potion` | 45-8 |  |
| `llama` | 45-4 |  |
| `llama_spit` | 45-8 |  |
| `magma_cube` | 45-5 |  |
| `mangrove_boat` | 45-8 |  |
| `mangrove_chest_boat` | 45-8 |  |
| `mannequin` | 45-9 | 45-3 section 10, 45-7 section 11 |
| `marker` | 45-8 | 45-7 section 11 |
| `minecart` | 45-8 |  |
| `mooshroom` | 45-4 |  |
| `mule` | 45-4 |  |
| `nautilus` | 45-7 |  |
| `oak_boat` | 45-8 |  |
| `oak_chest_boat` | 45-8 |  |
| `ocelot` | 45-4 |  |
| `ominous_item_spawner` | 45-8 | 45-7 section 11 |
| `painting` | 45-9 |  |
| `pale_oak_boat` | 45-8 |  |
| `pale_oak_chest_boat` | 45-8 |  |
| `panda` | 45-4 |  |
| `parched` | 45-5 |  |
| `parrot` | 45-4 |  |
| `phantom` | 45-5 |  |
| `pig` | 45-4 |  |
| `piglin` | 45-6 |  |
| `piglin_brute` | 45-6 |  |
| `pillager` | 45-6 |  |
| `player` | 45-3 |  |
| `polar_bear` | 45-4 |  |
| `poplar_boat` | 45-8 |  |
| `poplar_chest_boat` | 45-8 |  |
| `pufferfish` | 45-7 |  |
| `rabbit` | 45-4 |  |
| `ravager` | 45-5 |  |
| `salmon` | 45-7 |  |
| `sheep` | 45-4 |  |
| `shulker` | 45-5 |  |
| `shulker_bullet` | 45-8 |  |
| `silverfish` | 45-5 |  |
| `skeleton` | 45-5 |  |
| `skeleton_horse` | 45-4 |  |
| `slime` | 45-5 |  |
| `small_fireball` | 45-8 |  |
| `sniffer` | 45-4 |  |
| `snow_golem` | 45-4 |  |
| `snowball` | 45-8 |  |
| `spawner_minecart` | 45-8 |  |
| `spectral_arrow` | 45-8 |  |
| `spider` | 45-5 |  |
| `splash_potion` | 45-8 |  |
| `spruce_boat` | 45-8 |  |
| `spruce_chest_boat` | 45-8 |  |
| `squid` | 45-7 |  |
| `stray` | 45-5 |  |
| `strider` | 45-7 |  |
| `sulfur_cube` | 45-5 | 45-7 section 11 |
| `tadpole` | 45-7 |  |
| `text_display` | 45-8 | 45-7 section 11 |
| `tnt` | 45-8 | 45-7 section 11 |
| `tnt_minecart` | 45-8 |  |
| `trader_llama` | 45-4 |  |
| `trident` | 45-8 |  |
| `tropical_fish` | 45-7 |  |
| `turtle` | 45-4 |  |
| `vex` | 45-6 | 45-5 |
| `villager` | 45-6 |  |
| `vindicator` | 45-6 |  |
| `wandering_trader` | 45-6 |  |
| `warden` | 45-5 |  |
| `wind_charge` | 45-8 |  |
| `witch` | 45-5 |  |
| `wither` | 45-9 |  |
| `wither_skeleton` | 45-5 |  |
| `wither_skull` | 45-8 |  |
| `wolf` | 45-4 |  |
| `zoglin` | 45-5 |  |
| `zombie` | 45-5 |  |
| `zombie_horse` | 45-4 |  |
| `zombie_nautilus` | 45-7 |  |
| `zombie_villager` | 45-5 | 45-6 (helpers) |
| `zombified_piglin` | 45-5 |  |

---

## 14. Worked examples

### 14.1 A saved ender dragon in its landing run

`{id: "minecraft:ender_dragon", Pos: [0.5d, 66.0d, 0.5d], Motion: [0d,0d,0d], Rotation: [90f, 0f], ..., Health: 140f, DragonPhase: 3, DragonDeathTime: 0, sitting_damage_received: 0f}`. After load: the phase manager is HOVERING; `getById(3)` is Landing, `setPhase` ends Hover and calls Landing `begin`, clearing its target; the first tick recomputes the podium target. If the compound said `DragonPhase: 99` the phase would be HOLDING_PATTERN; with the key absent it would stay HOVERING.

### 14.2 `ender_dragon_fight.dat` mid-respawn

Root: `{DataVersion: 5023, data: {needs_state_scanning: 0b, dragon_killed: 1b, previously_killed: 1b, respawn_stage: "summoning_pillars", respawn_time: 120, exit_portal_location: [I; 0, 63, 0], gateways: [7, 2, 15], respawn_crystals: [[I; a,b,c,d], ...], dragon_uuid` absent`}}`. On the next tick with players present the crystals are resolved by UUID; the stage ticks with the pre-increment value 120 (pillar index 3, 120 / 40) and `respawn_time` is then stored as 121; if no crystal resolves, the sequence aborts. A brand-new End has no file: default object, scan true, gateways filled 0..19 shuffled from the seed.

### 14.3 A 2-wide painting and `block_pos`

Painting facing SOUTH at block (10, 64, 20), width 2, height 1 (variant data). The box centre is moved 0.46875 against the facing and by half a block along the horizontal axis perpendicular to the facing (44 part 9 section 5.4), so the saved position is exactly `Pos: [11.0, 64.5, 20.03125]`. Derivation: the box centre starts at the block centre (10.5, 64.5, 20.5); it moves 0.46875 against the facing (z becomes 20.03125); it then moves by the size offset (0.5 for an even size, 0 for an odd size, so 0.5 for width 2 and 0 for height 1) along the counter-clockwise neighbour of SOUTH, which is EAST (x becomes 11.0, y stays 64.5). The entity position is the centre of the resulting box. `floor(Pos.x)` = 11 therefore differs from `block_pos` x = 10, which is why `block_pos` is authoritative. The compound therefore stores `block_pos: [I; 10, 64, 20]`, `facing: 0b`, `variant: "minecraft:..."`. On load `Pos` gives a provisional `pos`; `block_pos` (within 16 of it) corrects it; `setDirection(SOUTH)` and the variant rebuild the box and the final position.

### 14.4 An item frame

`{id:"minecraft:item_frame", block_pos:[I;5,70,5], Item:{id:"minecraft:compass", count:1}, ItemRotation:3b, ItemDropChance:1.0f, Facing:3b, Invisible:0b, Fixed:0b}` is a frame facing SOUTH (3D id 3) with the item turned 3 steps (comparator output 4). `Facing:9b` decodes as id `9 % 6 = 3`, also SOUTH. A saved `count: 5` loads as 1. A frame with no `Facing` loads facing DOWN.

### 14.5 A custom boss bar

`custom_boss_events.dat`: `data: {"minecraft:raid_timer": {Name:"Raid", Visible:1b, Value:25, Max:50, Color:"red", Overlay:"notched_10", DarkenScreen:0b, PlayBossMusic:0b, CreateWorldFog:0b, Players:[[I;...]]}}` loads with progress 0.5; a listed player who joins is added to the bar at connect.

### 14.6 Armor stand locks

`DisabledSlots: 524289` = bit 0 (main hand fully blocked) plus bit 19 (`3 + 16`: putting onto the chest slot blocked).

---

## 15. Validation

1. Every key table above is complete for its class: the `addAdditionalSaveData` of `EnderDragon`, `WitherBoss`, `ArmorStand`, `ItemFrame`, `Painting`, `Cushion`, `Mannequin`, `EndCrystal`, `BlockAttachedEntity` writes exactly the keys listed (and `LeashFenceKnotEntity`, `GlowItemFrame` write none).
2. Round trip: saving and reloading a frame, painting, cushion or stand yields the same key values (the item frame count normalises to 1; frame and painting positions are derived).
3. A saved fight reloaded with `needs_state_scanning: 0b` must not rescan; a file lacking the key rescans (default true).
4. `DragonPhase` outside 0 to 10 loads HOLDING_PATTERN; key absent keeps HOVERING.
5. A hanging entity whose `block_pos` is missing or more than 16 from its position keeps the floor of `Pos`; it is removed 100 ticking ticks later if it does not survive.
6. Count check (repeatable): `javap -c` of `EntityTypeIds` yields 161 distinct strings; the index of section 13 has 161 rows and no key twice as a primary.
7. Unit checks for the codecs: legacy direction wrap (`9b` 3D gives SOUTH, `5b` 2D gives WEST), `hidden_layers: []` gives byte 127, `hidden_layers: ["hat"]` gives 63, `Pose` with a 2-element list is rejected.

---

## 16. Open questions

1. `DataFixer` upgrades of older entity and fight data are code not specified here (45-1 Open question 1).
2. Resolved: `PLAYER_NAME` validation read (12.1). Whether the validate lambda passed to `PLAYER_NAME` is `isValidPlayerName` was taken from the single `validate` call, not traced further.
3. Resolved: skin `model` names are `slim` and `wide` (12.1).
4. Resolved: property record fields read (12.1); only the optionality of `name` and `value` (required, no optional call) is by absence of an optional call.
5. Whether the Java remainder in `setRotation` can receive negative values from other paths is (inferred) from the single `irem`.
6. Resolved: `findOrCreateDragon` runs every tick while `dragon_uuid` is null (read, 3.3 step 6).
7. The meaning of the `ServerLevel` flag that gates `EnderDragonFight.tick` (a local boolean) was not traced.
8. Which painting variant has the lowest network id depends on registry load order (23); not tabulated.
9. EquipmentSlot ids used in the `DisabledSlots` example are taken from 44 part 9 section 4.1, not re-read.
10. 21 section 6.4.3 should be corrected for the initial phase of a constructed dragon (2.2); the edit belongs to the orchestrator.
11. Whether 07 section 9.1 should place world-level saved data exactly as in section 1 is a design decision for the orchestrator.
12. Write rules for `optionalFieldOf(name, default)` and `lenientOptionalFieldOf(name, default)` fields (`gateways`, `respawn_crystals`, the six `Pose` limbs, the `CustomBossEvent$Packed` optionals) are not read: the `com.mojang.serialization` library is not in the jar (0 entries searched). Recollection that default-equal values are omitted is (recalled, not verified). Also whether a bad `Pose` limb list fails the whole `Pose` or only that limb is (inferred).
