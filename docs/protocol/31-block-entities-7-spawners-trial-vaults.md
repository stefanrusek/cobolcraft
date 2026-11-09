# 31-7 Block entities, part 7: mob spawner, trial spawner and vault

| Item | Value |
|---|---|
| Covers | The three block entity types of the spawner family as block entities: `mob_spawner` (`SpawnerBlockEntity`, engine `BaseSpawner`), `trial_spawner` (`TrialSpawnerBlockEntity`, engine package `trialspawner`: `TrialSpawner`, `TrialSpawnerConfig`, `TrialSpawnerState`, `TrialSpawnerStateData`, `PlayerDetector`) and `vault` (package `entity.vault`: `VaultBlockEntity`, `VaultConfig`, `VaultServerData`, `VaultSharedData`, `VaultClientData`, `VaultState`). Per type: registration, saved NBT (every key, type, default and write rule), update tag and client synchronisation, tickers, block events and level events, the state machines, key checking and reward ejection (vault), loot ejection (trial spawner), and the schema of the `trial_spawner` registry (data) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for lambda targets), of the jar's `data/minecraft/trial_spawner/*.json`, `data/minecraft/loot_table/**` and `data/minecraft/structure/trial_chambers/**/*.nbt` (decoded with a throwaway script kept outside the repository), with no execution. Every value was read in this round; anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions |
| Siblings | 31-1 (base model: save, load, update tag and packet, chunk storage, tickers; the numeric type ids), 31-2 (`DefaultDispenseItemBehavior.spawnItem`, section 6.5). The other siblings do not touch these types |
| Related | 44-2 sections 2 to 4 (the spawner and trial spawner engines, written from the same classes in an earlier round: this part re-read them and agrees, with the additions in section 4.4), 45-8 section 4.5 (the same `BaseSpawner` for the spawner minecart), 42-6 sections 4.2 to 4.4 and the level event table (every particle), 26 section 11.9 (loot calls), 18 (mob framework: `checkSpawnRules`, `finalizeSpawn`), 24 part 8 (block states, light levels), 23 (registry loading: the `trial_spawner` registry row), 25 part 8 (trial keys, ominous bottle items) |

Class and method names appear in backticks only to say where a fact was read. Particles, sounds and level event effects are in 42-6 and are only referenced here.

## 1. Scope and decisions

The operator decisions of CC-0001 apply: standard content is the target; the data rows (the 28 trial spawner configurations, loot tables, structure templates) are not tabulated here, only their schema and the engines that read them. Everything that is code (the three state machines, the key rule, the delay and count formulas, the NBT layouts) is specified in full.

Reading guide: section 2 is the registration facts of all three types; section 3 the mob spawner; section 4 the trial spawner; section 5 the vault; section 6 persistence and synchronisation seen from the chunk; sections 7 and 8 worked examples and validation.

## 2. Registration, blocks, tickers

| Type key | Numeric id (`block_entity_type`, 46 section 5.4) | Valid block | Class | Block class |
|---|---|---|---|---|
| `minecraft:mob_spawner` | 9 | `spawner` | `SpawnerBlockEntity` | `SpawnerBlock` |
| `minecraft:trial_spawner` | 43 | `trial_spawner` | `TrialSpawnerBlockEntity` | `TrialSpawnerBlock` |
| `minecraft:vault` | 44 | `vault` | `VaultBlockEntity` | `VaultBlock` |

The numeric ids are the registration order of `BlockEntityTypes` (the 49 static fields are assigned in sequence; `MOB_SPAWNER` is the 10th, `TRIAL_SPAWNER` the 44th, `VAULT` the 45th, so ids 9, 43, 44 counting from 0), and agree with the table at 46 section 5.4 (rows 9, 43, 44). The string keys are in `BlockEntityTypeIds` (`mob_spawner`, `trial_spawner`, `vault`).

Each type has exactly one valid block (the registration passes one block). Each block creates its entity in `newBlockEntity` with the position and state. 31-1 section 3.2 lists `mob_spawner` and `trial_spawner` among the six operator-only types: an item carrying `block_entity_data` for them is honoured only for operators; the vault is not operator-only.

Tickers (`getTicker`, 31-1 section 7; the helper returns a ticker only for the block's own type):

| Block | Server ticker | Client ticker |
|---|---|---|
| `spawner` | `BaseSpawner.serverTick(level, pos)` (the level cast to the server level) | `BaseSpawner.clientTick(level, pos)` |
| `trial_spawner` | only when the level is a server level: `TrialSpawner.tickServer(level, pos, ominousFlag)` | otherwise (client level): `TrialSpawner.tickClient(level, pos, ominousFlag)` |
| `vault` | only when the level is a server level: `VaultBlockEntity.Server.tick(level, pos, state, config, serverData, sharedData)` | otherwise: `VaultBlockEntity.Client.tick(level, pos, state, clientData, sharedData)` |

`ominousFlag` is the block state's `ominous` property read with default false when the property is absent (`getOptionalValue`). The three block entities tick while their chunk is ticking (31-1 section 7, 33 section 2.1 step 11).

Block states (full tables in 24 part 8 rows 900 and 901, and the property table at its line 226 to 228): `trial_spawner` has `trial_spawner_state` (`inactive` default, `waiting_for_players`, `active`, `waiting_for_reward_ejection`, `ejecting_reward`, `cooldown`) and `ominous` (false); `vault` has `facing` (horizontal, default north; placement sets it to the opposite of the placer's horizontal facing; it rotates and mirrors as the other horizontal blocks), `vault_state` (`inactive` default, `active`, `unlocking`, `ejecting`) and `ominous` (false). Light levels by state: trial spawner 0, 4, 8, 8, 8, 0 in the order of the six states; vault: `inactive` uses the light level constant `HALF_LIT` = 6, and `active`, `unlocking`, `ejecting` use `LIT` = 12 (assignment read in the `VaultState` constants).

None of the three blocks has a loot table that drops anything: `data/minecraft/loot_table/blocks/spawner.json`, `.../trial_spawner.json` and `.../vault.json` are each `{type: block, random_sequence: ...}` with no pools (read), so breaking drops nothing by loot; the spawner pays experience (section 3.5).

## 3. Mob spawner (`mob_spawner`)

The block entity holds one `BaseSpawner` (its anonymous subclass supplies `broadcastEvent` and `setNextSpawnData`). The fields, defaults, delay arithmetic, the attempt loop, the crowd check, the client animation and the spawn data schema are in **44-2 section 2** (fields, delay, client), **44-2 section 3** (`SpawnData`, custom spawn rules, equipment) and **45-8 section 4.5** (the numbered engine). This section re-states only what a block entity implementation needs, plus facts read in this round that those sections do not give.

### 3.1 Saved NBT

`saveAdditional` calls `BaseSpawner.save`; `loadAdditional` calls `BaseSpawner.load(level, pos, input)`. The base class contributes only `components` (31-1 section 2.2). The chunk file entry is therefore: `id` = `minecraft:mob_spawner`, `x`, `y`, `z`, `components`, and the keys below.

| Key | NBT type on write | Read as | Default when absent | Notes |
|---|---|---|---|---|
| `Delay` | Short | Short (`getShortOr`) | 20 | the int is narrowed to a short on write, so a value above 32767 wraps |
| `MinSpawnDelay` | Short | Int (`getIntOr`) | 200 | |
| `MaxSpawnDelay` | Short | Int | 800 | |
| `SpawnCount` | Short | Int | 4 | attempts per round |
| `MaxNearbyEntities` | Short | Int | 6 | |
| `RequiredPlayerRange` | Short | Int | 16 | |
| `SpawnRange` | Short | Int | 4 | |
| `SpawnData` | compound (spawn data) | spawn data codec | none | written only when a next spawn data exists (`storeNullable`); read: if present it becomes the next spawn data |
| `SpawnPotentials` | list of `{data: spawn data, weight: Int}` | the same list codec | a one-entry list: the current next spawn data (or an empty spawn data when there is none) with weight 1 | always written |

Write order: `Delay`, `MinSpawnDelay`, `MaxSpawnDelay`, `SpawnCount`, `MaxNearbyEntities`, `RequiredPlayerRange`, `SpawnRange`, `SpawnData`, `SpawnPotentials`. Load order: `Delay`, `SpawnData`, `SpawnPotentials`, then the six integers; the client display entity is reset to none at the end of every load.

Spawn data compound (`SpawnData.CODEC`): `entity` (required compound), `custom_spawn_rules` (optional: `block_light_limit` and `sky_light_limit`, each an inclusive int range written as `{min_inclusive, max_inclusive}` (44-2 section 3), lenient, default 0 to 15, rejected when outside 0 to 15), `equipment` (optional equipment table, 44-2 section 3). On construction the entity compound's `id` is read as an identifier and re-stored in its canonical `namespace:path` form; an `id` that is not a valid identifier is removed. The default spawn data is an empty entity compound and cannot spawn anything. A list entry is `{data, weight}`: `data` is required, `weight` is **required** (a non-negative Int; `fieldOf`, no default; a negative weight is rejected, a zero weight is accepted silently in the release; the class logs a "found 0 weight" warning only when the IDE-run constant `SharedConstants.IS_RUNNING_IN_IDE` is true).

Weighted pick (`WeightedList.getRandom`, used by the spawner and the trial spawner): with total weight `W` (sum, int): an empty list or `W == 0` gives no result; otherwise draw `r = nextInt(W)`, then walk the entries in list order subtracting each weight from `r` and take the first entry where the result is below 0. (The class keeps two internal forms, a flat array when `W < 64` and the walk otherwise; both give the same result for the same `r`.) One draw per pick.

### 3.2 Update tag, packets and events

- `getUpdatePacket()` returns `ClientboundBlockEntityDataPacket.create(this)`. `getUpdateTag` = `saveCustomOnly` (the keys of the table above, no `id`, no `components`, no position) with the key `SpawnPotentials` removed (31-1 section 5.2). The client therefore holds only the current `SpawnData`; when it loads the tag the potentials list absent branch applies (a one-entry list with the current next spawn data).
- `SpawnerBlockEntity.triggerEvent(id, _)` (a block event) asks the spawner (`onEventTriggered`): for id 1 it reports the event handled, and **on the client only** sets `spawnDelay = MinSpawnDelay` (on the server it handled the event without effect); any other id falls back to the base class (not handled). The server raises it from `delay()` through `broadcastEvent`, which is `Level.blockEvent(pos, spawner block, 1, 0)` (the data argument is 0).
- Whenever the spawner stores a new next spawn data through `setNextSpawnData` (the weighted pick in `delay`, the first lazy pick, a load, an edit) and the spawner has a level, it calls `Level.sendBlockUpdated(pos, state, state, 260)`: the position is queued for the next chunk broadcast, which sends the block entity update (29 section 7.2; the flag value is not used by anything that decides what is sent, section 6). So a client learns each new `SpawnData` within the tick of the pick.
- Level event 2004 (spawn particles) is sent by the engine for every successful spawn (42-6 table).

### 3.3 Edits that change the spawned entity

`SpawnerBlockEntity.setEntityId(type, random)` and `setEntityData(typedEntityData, random)` (the `Spawner` interface used by spawn eggs and by placing a spawner item; 44-2 section 5) forward to `BaseSpawner.setEntityId` and `setEntityData`, then call `setChanged`. `setEntityId` takes the current next spawn data (creating one through the weighted pick or the empty default when none), and writes only the key `id` of its entity compound, the registry key of the type as a string; custom rules and other entity keys are untouched. `setEntityData` loads the typed entity data into the same spawn data (`loadInto` with the entity type registry). Because the next spawn data and the single list entry created on load are the same object (the load builds the default potentials list from the loaded spawn data), an edit of a freshly loaded spawner changes both; with an explicit multi-entry `SpawnPotentials` the next `delay()` can replace the edited spawn data by another entry (inferred from the object sharing; not exercised).

### 3.4 Engine summary (pointer)

Per server tick: stop unless a living, non-spectator player is within `RequiredPlayerRange` of the block centre and the game rule `spawner_blocks_work` is true; handle `Delay` of -1; count down; run `SpawnCount` attempts; roll the delay. The exact steps, order of random draws and failure rules are 44-2 section 2.2 and 45-8 section 4.5 (re-read this round: the position lambda draws `nextDouble`, `nextDouble`, then `nextInt(3)`, then `nextDouble`, `nextDouble`; the count box is the block's unit box inflated by `SpawnRange`; the check order is: the spawn box of the entity type at the `Pos` (or the default position) must be free of collisions (`noCollision`), then, **with custom rules**, a non-friendly category on Peaceful difficulty is refused and `isValidPosition` must hold, or, **without custom rules**, `SpawnPlacements.checkSpawnRules(type, level, SPAWNER, pos, random)` must hold, all before the entity is created; after creation and the random yaw (`nextFloat * 360`), a `Mob` additionally runs `Mob.checkSpawnRules(SPAWNER)` only when no custom rules are present, then `checkSpawnObstruction`; the finalisation applies only when the entity compound has exactly one key, a String `id`; events 2004 and the game event `entity_place` follow a successful add). Additional read facts:

1. "Living player nearby" is `Level.hasNearbyAlivePlayer(x, y, z, range)`: some player that passes the non-spectator filter (`NO_SPECTATORS`: not `isSpectator`) and the still-alive filter (`LIVING_ENTITY_STILL_ALIVE`: `isAlive` and a living entity; lambda-to-field mapping by declaration order, inferred) has `distanceToSqr(x, y, z) < range * range`, or the range is negative (then any such player counts).
2. The custom-rule test is: block light at the position (`LightLayer.BLOCK` brightness) inside `block_light_limit` and the effective sky brightness at the position inside `sky_light_limit`; a mob category that is not friendly additionally fails when the difficulty is Peaceful. (The light computations are 32.)
3. On a client the spawner never spawns; its tick only decrements the client `spawnDelay` while above 0 and spins the display (44-2 section 2.4).

### 3.5 Block behaviour

`SpawnerBlock.spawnAfterBreak(state, level, pos, tool, dropExperience)`: after the base behaviour, when `dropExperience` is true, `popExperience(level, pos, 15 + nextInt(15) + nextInt(15))`, so 15 to 43 points (draws in that order, `level.getRandom()`). There is no other drop (section 2).

## 4. Trial spawner (`trial_spawner`)

### 4.1 Saved NBT

`TrialSpawnerBlockEntity.saveAdditional` calls `TrialSpawner.store`, which writes two map codecs into the same compound, in this order: the state data (`TrialSpawnerStateData$Packed.MAP_CODEC`), then the full configuration (`TrialSpawner$FullConfig.MAP_CODEC`). `loadAdditional` calls `TrialSpawner.load`, which reads the packed state data (when the codec yields a value, it replaces the engine's state data through `apply`) and reads the full configuration, **falling back to the built-in default configuration when the read fails or the keys are all absent**; then, when the entity has a level, it calls `markUpdated` (section 4.5).

State data keys (all lenient: an absent or undecodable key takes the default):

| Key | NBT type | Default | Meaning |
|---|---|---|---|
| `registered_players` | list of int arrays (each `[I; 4]`, a UUID as four ints) | empty | the detected players (`detectedPlayers`) |
| `current_mobs` | list of UUID int arrays | empty | mobs this spawner spawned that are still tracked |
| `cooldown_ends_at` | Long (game time) | 0 | end of the cooldown; reused as the next item-spawner time while ominous (44-2 section 4.6) |
| `next_mob_spawns_at` | Long (game time) | 0 | earliest game time of the next spawn |
| `total_mobs_spawned` | Int, 0 to 2147483647 | 0 | mobs spawned in the current wave |
| `spawn_data` | spawn data compound | absent | the next spawn data (`nextSpawnData`) |
| `ejecting_loot_table` | String (loot table key) | absent | the table chosen for the current ejection run |

The two sets are encoded as lists of UUIDs (`UUIDUtil.CODEC_SET`): each element is an int array of four ints (the standard four-int UUID form used elsewhere in these documents, 45 section 1; the order is most significant word first: `[msb >> 32, msb low 32, lsb >> 32, lsb low 32]`, read in `UUIDUtil.uuidToIntArray` and `uuidFromIntArray`). Applying a packed value **clears and refills** both sets and overwrites every field, so a tag that lacks keys resets those fields to their defaults.

Full configuration keys (`FullConfig`):

| Key | Type | Default | Range |
|---|---|---|---|
| `normal_config` | a trial spawner config, as a registry reference (String `namespace:path` of an element of the `trial_spawner` registry) or an inline compound (section 4.2) | the built-in default config (section 4.2) | |
| `ominous_config` | same | the built-in default config | |
| `target_cooldown_length` | Int | 36000 | 0 or more |
| `required_player_range` | Int | 14 | 1 to 128 |

**All-or-nothing read:** unlike the state data, the four keys are read with the non-lenient optional-field form (the two ints with their ranges 0 or more and 1 to 128). A key that is absent takes its default, but a key that is present and undecodable or out of range makes the **whole** `FullConfig` read fail, and `load` then replaces **all four** values with the built-in default (36000 and 14 included), not only the bad key. A freshly created trial spawner block entity uses the built-in default for all four. Structure templates set only the two config references (section 7.5). Whether the writer omits keys equal to their defaults was not readable (the codec library is not in the artifact, Open question 1); a reader must accept both forms.

The entries of the chunk file are the 31-1 form (`id`, `x`, `y`, `z`, `components`) plus these keys.

### 4.2 The `trial_spawner` registry and the config schema

The registry `trial_spawner` (path `trial_spawner`, key class `Registries.TRIAL_SPAWNER_CONFIG`) is not synchronised to clients (23 section 3 row 19: Sync no, Validator none). The jar holds 28 files `data/minecraft/trial_spawner/trial_chamber/<family>/<mob>/{normal,ominous}.json`: 14 pairs, families `breeze` (1 pair), `melee` (`husk`, `spider`, `zombie`), `ranged` (`poison_skeleton`, `skeleton`, `stray`), `slow_ranged` (the same three) and `small_melee` (`baby_zombie`, `cave_spider`, `silverfish`, `slime`). They are data; the registry key of an element is `minecraft:trial_chamber/<family>/<mob>/<normal|ominous>`. 44-2 section 4.2 summarises what the 28 files set. The code also contains a bootstrap (`TrialSpawnerConfigs`) that registers the same 14 key pairs under the same names (the key names read: `trial_chamber/breeze`, `.../melee/{husk,spider,zombie}`, `.../ranged/...`, `.../slow_ranged/...`, `.../small_melee/...`, each with `/normal` and `/ominous`); with the data pack extracted from the jar the bootstrap is not needed.

One config (`TrialSpawnerConfig.DIRECT_CODEC`; every key optional):

| Key | Type and range | Default (`TrialSpawnerConfig.DEFAULT`, built by `Builder`) |
|---|---|---|
| `spawn_range` | int 1 to 128 | 4 |
| `total_mobs` | float, 0 to the largest float | 6.0 |
| `simultaneous_mobs` | float, 0 to the largest float | 2.0 |
| `total_mobs_added_per_player` | float, same range | 2.0 |
| `simultaneous_mobs_added_per_player` | float, same range | 1.0 |
| `ticks_between_spawn` | int 0 to 2147483647 | 40 |
| `spawn_potentials` | list of `{data: spawn data, weight}` (the plain list codec: an empty list is allowed) | empty |
| `loot_tables_to_eject` | list of `{data: loot table key, weight}` | two entries, weight 1 each: `minecraft:spawners/trial_chamber/consumables`, then `minecraft:spawners/trial_chamber/key` (key names read from `BuiltInLootTables`) |
| `items_to_drop_when_ominous` | loot table key | `minecraft:spawners/trial_chamber/items_to_drop_when_ominous` |

The ominous files override the eject table and their weights are not all 1: `breeze/ominous.json` sets `loot_tables_to_eject` to `minecraft:spawners/ominous/trial_chamber/key` with weight 3 and `minecraft:spawners/ominous/trial_chamber/consumables` with weight 7, so the weighted pick (section 3.1) chooses the key table with probability 3/10. The normal files use the default list of two weight-1 entries (44-2 section 4.2).

Derived values (floats, then `floor`, then converted to int; `extra` is the number of additional players, section 4.4):

- `targetTotalMobs(extra) = floor(total_mobs + total_mobs_added_per_player * extra)`;
- `targetSimultaneousMobs(extra) = floor(simultaneous_mobs + simultaneous_mobs_added_per_player * extra)`;
- `ticksBetweenItemSpawners = 160`, a constant of the class, not a key.

The element reference in `normal_config` and `ominous_config` is the standard registry-or-inline holder form (04 section 6 and 23 section 3.6 describe element loading). `overrideEntity(type)` (a spawn egg used on the block) replaces **both** configs by inline copies whose `spawn_potentials` is one entry `{entity: {id: <type key>}}` with weight 1, keeping every other key; `overrideEntityData(typedEntityData)` does the same with the entity compound loaded from the typed data. Both first call `reset()` on the state data (clear `current_mobs`, clear `spawn_data`, reset the statistics) and set the block state to `inactive` (section 4.3).

### 4.3 State machine, detection and ejection

The engine is specified in **44-2 section 4** (4.1 state table with light, spin and particle mode; 4.3 saved state; 4.4 the tick and the six-row transition table; 4.5 detection; 4.6 the ominous variant and item spawner; 4.7 spawning one mob; 4.8 ejecting a reward). This round re-read `TrialSpawner`, `TrialSpawnerState`, `TrialSpawnerStateData` and `PlayerDetector` and found them in agreement. The block-entity-level facts below are the ones an implementation needs in addition, in the order they matter.

1. **Per server tick** (`tickServer(level, pos, ominousFlag)`): `isOminous = ominousFlag`; remove from `current_mobs` every tracked mob for which the untracked rule holds; if any was removed, `next_mob_spawns_at = gameTime + activeConfig.ticks_between_spawn`; compute `next = state.tickAndGetNext(pos, spawner, level)`; if `next` differs from the current state, `setState` (below).
2. **The untracked rule** (`shouldMobBeUntracked`): the mob is untracked when `level.getEntity(uuid)` finds nothing (also an unloaded or removed entity), or the entity is not alive, or its level's dimension differs from the spawner level's dimension, or `distSqr(mob block position, spawner position) > 47 * 47 = 2209` (strictly greater; integer block positions). 44-2 section 4.4 step 2 lists dead, other dimension and distance; the not-found case is the addition.
3. **State change** (`TrialSpawnerBlockEntity.setState(level, state)`): `setChanged()`, then `Level.setBlockAndUpdate(pos, currentState with trial_spawner_state = state)`. The block update sends the new state and, through the usual broadcast, the block entity update packet (section 4.5). `getState()` reads the property and returns `inactive` when the block state has no such property.
4. **Active config**: the ominous config when `isOminous`, otherwise the normal one. `applyOminous(level, pos)` sets the block property `ominous` true (`setBlockAndUpdate`), sends level event 3020 with data 1 at the block, sets `isOminous` and runs `resetAfterBecomingOminous` (44-2 section 4.6); `removeOminous` sets the property false and `isOminous` false.
5. **`canSpawnInLevel`**: false when the game rule `spawner_blocks_work` is false; true when the internal override flag `overridePeacefulAndMobSpawnRule` is set; otherwise false on Peaceful difficulty, otherwise the value of the game rule `spawn_mobs`. The override flag is set by a method of the class (`overridePeacefulAndMobSpawnRule()`) whose callers were not found in the packages read (Open question 3); a normally created trial spawner never has it set.
6. **Detection throttle**: `tryDetectPlayers` returns at once unless `(pos.asLong() + gameTime) mod 20 == 0` (`BlockPos.asLong` is the packed position, 07 and 29 section on packed positions). A second early return follows the throttle: when the current state is `cooldown` **and** the spawner is ominous, it returns without detecting (so an ominous spawner in cooldown never detects players and its detected set is not refreshed). Otherwise detection runs in two steps. Step 1 is always a detection **with** line of sight required (the argument is a constant true in `tryDetectPlayers`). Its list is used in two ways. (a) On a non-ominous spawner, when the list is non-empty, the first listed player that has the `trial_omen` effect (`findPlayerWithOminousEffect`) makes the spawner ominous (`applyOminous`, item 4); that outcome is remembered as a flag. (b) If the state is `cooldown` and that flag is not set, the function returns here, so in `cooldown` the detected set is never refreshed except through that omen path (an ominous spawner in `cooldown` already returned at the second early return). Step 2: when the stored detected set is empty, the step 1 list is the candidate list (initial acquisition, line of sight needed); when the stored set is already non-empty, a second detection runs **without** line of sight and its list is the candidate list (players already acquired are kept through walls). The candidates are added to the stored set; if that added anyone, `next_mob_spawns_at = max(gameTime + 40, next_mob_spawns_at)` and, unless the omen flag is set, level event 3019 (ominous) or 3013 (normal) is sent at the block (42-6; 44-2 section 4.5). So line of sight is required for every detection that can add a player to an empty set, and only the refresh of an already non-empty set ignores it.
7. **Player filter** (`PlayerDetector.NO_CREATIVE_PLAYERS`, the detector of a trial spawner; `selector` = every player of the level): a player is detected when `distSqr(player block position, spawner position) < required_player_range^2` (`BlockPos.closerThan`: strict, the range is converted to a double and squared), the player is not in creative and not a spectator, and, when the detection asks for line of sight, a visual ray from the player's eye position to the block centre hits the spawner block itself or misses (`ClipContext` with `Block.VISUAL`, `Fluid.NONE`, empty collision context; clear when the hit block position equals the block containing the block centre, or the result type is a miss). The result list holds the UUIDs of the players that pass. (`INCLUDING_CREATIVE_PLAYERS` is the same without the creative test; it is the vault's detector. A third detector, `SHEEP`, is selected by a debug constant that is false in the release and counts sheep as players.)
8. **Mob spawn** (4.7 of 44-2): the position default is read from the active config's `spawn_range`; the mob gets `setPersistenceRequired`, so it does not despawn; both events 3011 (spawn flame, data `FlameParticle.encode()` = 0 normal, 1 ominous) and 3012 follow a successful add (the second also carries the flame code, 44-2 section 4.7 step 7); the spawner then adds the UUID to `current_mobs`, increments `total_mobs_spawned`, sets `next_mob_spawns_at = gameTime + ticks_between_spawn` and, through a weighted pick of the active `spawn_potentials`, stores the next `spawn_data` and calls `markUpdated`.
9. **`getOrCreateNextSpawnData`**: if `spawn_data` is present return it; otherwise take a weighted pick of the active config's `spawn_potentials` when that list is non-empty, else the (empty) stored value; if that yields nothing use an empty spawn data; store it as `spawn_data`, call `markUpdated`, return it. `hasMobToSpawn` is true when the resulting entity compound has an `id`, or the potentials list is non-empty.
10. **Ejection** (`ejectReward(level, pos, tableKey)`): load the table from the server's reloadable registries, roll it with `LootContextParamSets.EMPTY` and no parameters, and for each stack call the default dispense `spawnItem(level, stack, 2, UP, bottomCenter(pos) moved 1.2 up)` (31-2 section 6.5 gives the formula: `y -= 0.125`, `speed = nextDouble * 0.1 + 0.2`, `vx = triangle(0, 0.0172275 * 2)`, `vy = triangle(0.2, 0.0172275 * 2)`, `vz = triangle(0, 0.0172275 * 2)`); then, only when the roll produced at least one stack, level event 3014 with data 0. State `ejecting_reward` ejects once per detected player: each ejection happens on a tick with `(gameTime - (cooldown_ends_at - target_cooldown_length)) mod 30 == 0` (the divisor is the class constant `TrialSpawnerState.TIME_BETWEEN_EACH_EJECTION`, initialised in the static initialiser as `Mth.floor` of the float constant 30.0, so 30; read there, not in `TrialSpawner`, whose only literal 30 is the detection particle count), one detected player is then removed from the set (the first in iteration order of the hash set, so with several players which one is removed is not defined by the data), and the table chosen at the first ejection of the run (`ejecting_loot_table`, a weighted pick of `loot_tables_to_eject`) is reused until the run ends in `cooldown`.
11. **Ominous item spawner** (`spawnOminousOminousItemSpawner`, active and ominous only): the cached item list (`dispensing`) is built once from `items_to_drop_when_ominous` with `LootContextParamSets.EMPTY` and the loot seed `level.getSeed() + BlockPos(floor(x / 30.0f), floor(y / 20.0f), floor(z / 30.0f)).asLong()` of the spawner position (float division, `Mth.floor`), each rolled stack split into a single item whose weight is the stack's count; the entity spawned is an `ominous_item_spawner` (21 section 8.17, 45-8 section 3.5). Position selection: the `nextBoolean` draw picks mobs (true) or players (false); a single candidate wins, otherwise `Util.getRandom(list, random)`, which is exactly `list.get(random.nextInt(list.size()))` (one draw; read); the position is the candidate's position moved up by `bbHeight + 2 + nextInt(4)` blocks (float arithmetic), a visual ray clip upward (`Block.VISUAL`, `Fluid.NONE`) is taken, the point one block below the centre of the hit block is the candidate position (inferred: the bytecode computes it and tests it; which vector the success branch returns is hidden behind a load), and the spawn is refused unless the block there has an empty collision shape. The sound `trial_spawner.spawn_item_begin` is played with volume 1 and pitch `(nextFloat - nextFloat) * 0.2 + 1`, and `cooldown_ends_at = gameTime + 160`.

### 4.4 Differences from, and additions to, 44-2 section 4

| Topic | 44-2 | This round |
|---|---|---|
| Untracked mobs | dead, other dimension, too far | also a mob that cannot be found by UUID |
| Registry and file layout | counts and what the files set | adds the full key list with ranges and the default builder, the holder form, the inline form produced by `overrideEntity` |
| Saved keys | key names | adds types (UUID sets as lists of int arrays), defaults, the apply-resets-everything rule, the fallback of the full config to the default |
| Update tag | not described | section 4.5 |
| Everything else read | state machine, detection, ominous, spawn, eject | agrees (the state order `inactive`, `waiting_for_players`, `active`, `waiting_for_reward_ejection`, `ejecting_reward`, `cooldown` is the ordinal order, which drives the transition table) |

### 4.5 Update tag, `markUpdated` and the client

- `TrialSpawnerBlockEntity.getUpdateTag` = `TrialSpawnerStateData.getUpdateTag(state)` with the block's current `trial_spawner_state`: a new compound; when the state is `active` it holds the Long `next_mob_spawns_at`; when a next spawn data exists it holds `spawn_data` (spawn data codec). Nothing else (not the config, not the sets, not `cooldown_ends_at`). `getUpdatePacket` is `ClientboundBlockEntityDataPacket.create(this)`.
- `markUpdated()` is `setChanged()` followed by `Level.sendBlockUpdated(pos, state, state, 3)` when a level exists; it is called by the engine when the next spawn data changes, by `getOrCreateNextSpawnData`, by `resetAfterBecomingOminous`, and at the end of every `loadAdditional` that has a level.
- On the client the tag goes through `loadWithComponents` (31-1 section 5.4), so `TrialSpawner.load` runs on it: the packed state is **applied with defaults for every key the update tag lacks** (the client's detected players, current mobs, cooldown and total spawned become empty or 0), and the full config falls back to the built-in default. The client uses only `next_mob_spawns_at` (spin speed), `spawn_data` (the display mob) and the block state.
- Client tick (`tickClient(level, pos, ominousFlag)`): emit the state's particles (42-6 section 4.2); if the state has a spinning mob (speed 0 or more: `waiting_for_players` 200, `active` 1000; other states -1), `oSpin = spin`, `spin = (spin + speed / (max(0, next_mob_spawns_at - gameTime) + 200)) mod 360` in doubles; if the state is capable of spawning (`waiting_for_players`, `active`) and `nextFloat() <= 0.02`, play `trial_spawner.ambient` (`ambient_ominous` when ominous) locally at volume `nextFloat * 0.25 + 0.75` and pitch `nextFloat + 0.5`. The display entity is created lazily from the next spawn data's entity compound, only when the state has a spinning mob and the compound has an `id`, with the creation processor that sets the entity id to -1.
- Level events of this type: 3011, 3012, 3013, 3014, 3019, 3020 (42-6); 3021 comes from the item spawner entity.

## 5. Vault (`vault`)

### 5.1 Parts of the block entity

| Part | Class | Holds | Side |
|---|---|---|---|
| config | `VaultConfig` | loot table, ranges, key item, display override | both (client always holds the default, section 5.4) |
| shared data | `VaultSharedData` | display item, connected players, particle range | synchronised to the client |
| server data | `VaultServerData` | rewarded players, state timer, items waiting to eject, insert-failure time, ejection total | server only (`getServerData` returns nothing on a client level) |
| client data | `VaultClientData` | the display spin | client only |

A new vault block entity starts with the default config, empty server and shared data and a zero spin.

### 5.2 Config (`VaultConfig`)

Saved under the key `config`; the codec is validated: the record is rejected when `activation_range > deactivation_range`.

| Key | Type | Default (`VaultConfig.DEFAULT`) |
|---|---|---|
| `loot_table` | String (loot table key), lenient | `minecraft:chests/trial_chambers/reward` (`BuiltInLootTables.TRIAL_CHAMBERS_REWARD`) |
| `activation_range` | Double, lenient | 4.0 |
| `deactivation_range` | Double, lenient | 4.5 |
| `key_item` | item stack compound (`id`, `count`, optional `components`), lenient | `minecraft:trial_key`, count 1 (see below for absent) |
| `override_loot_table_to_display` | String (loot table key), lenient, optional | absent |

`key_item` is read with the lenient single-field form: an absent or undecodable value becomes the **empty stack**, and an empty stack is not written. With an empty key item the vault can never be opened (section 5.5). The two other fields of the record, `playerDetector` and `entitySelector`, are not saved: the detector is `PlayerDetector.INCLUDING_CREATIVE_PLAYERS` (players in range that are not spectators; creative players count) and the selector `SELECT_FROM_LEVEL`, both from `DEFAULT`, with the debug sheep detector used instead when a debug constant is set (false in the release). The chunk template of the trial chamber vault stores only `{key_item: {id: trial_key, count: 1}, loot_table: "minecraft:chests/trial_chambers/reward"}`; the ominous vault template stores `{key_item: {id: ominous_trial_key, count: 1}, loot_table: "minecraft:chests/trial_chambers/reward_ominous"}` and the block property `ominous` true (both read from `data/minecraft/structure/trial_chambers/reward/{vault,ominous_vault}.nbt`). The ominous template was re-read in the fixer round: its vault block entity has `key_item` with `minecraft:ominous_trial_key` and a `count` entry, and `loot_table` `minecraft:chests/trial_chambers/reward_ominous`; its palette holds a `minecraft:vault` entry with an `ominous` property (facing north, `vault_state` inactive). The ominous template's `key_item` `count` was decoded: one NBT Int (tag 3) with value 1.

### 5.3 Saved NBT of the entity

`saveAdditional`: base, then `config` (the codec above), `shared_data`, `server_data`. `loadAdditional`: `server_data` (when present: copied into the entity's server data through `set`), then `config` (default when absent or undecodable), then `shared_data` (when present, `set`).

`shared_data` (`VaultSharedData.CODEC`, lenient keys):

| Key | Type | Default |
|---|---|---|
| `display_item` | item stack compound | the empty stack (not written when empty) |
| `connected_players` | list of UUID int arrays | empty (read as an insertion-ordered set) |
| `connected_particles_range` | Double | `VaultConfig.DEFAULT.deactivation_range` = 4.5 |

`server_data` (`VaultServerData.CODEC`, lenient keys):

| Key | Type | Default | Meaning |
|---|---|---|---|
| `rewarded_players` | list of UUID int arrays | empty | players that already took a reward; an insertion-ordered set capped at 128 |
| `state_updating_resumes_at` | Long (game time) | 0 | the state machine does nothing before this game time |
| `items_to_eject` | list of item stack compounds | empty | the rolled reward not yet ejected |
| `total_ejections_needed` | Int | 0 | size of the rolled reward, for the ejection progress |

Quirks of the load, read from `VaultServerData.set`: it copies `state_updating_resumes_at`, `items_to_eject` and `rewarded_players` **but not `total_ejections_needed`**, and `lastInsertFailTimestamp` is not saved at all. After a reload in the middle of an ejection the in-memory total is 0, which changes the ejection progress used for the sound pitch (section 5.5, Example 7.8). The `connected_particles_range` is only ever read from the tag or defaulted; the engine never writes it from the config (`updateConnectedPlayersWithinRange` takes the range as an argument and does not store it).

### 5.4 Update tag and synchronisation

`getUpdateTag` is a compound with the single key `shared_data` (the shared data codec, encoded with the registry-aware NBT operations because the display item may carry components). `getUpdatePacket` is `ClientboundBlockEntityDataPacket.create(this)`. On the client `loadAdditional` runs with this tag: `server_data` is absent (nothing), `config` is absent so **the client's config becomes the default config**, and the shared data is copied. The client therefore knows the display item, the connected players and the particle range, and nothing else.

When the server tick finds `isDirty` on the server data or the shared data (set by any change to them), it calls `setChanged(level, pos, state)` (a static form: marks the chunk unsaved) and, if the **shared data** is dirty, `sendBlockUpdated(pos, state, newState, 2)`; then clears both dirty flags. So a change of only the server data (a timer, the rewarded set) is saved but not sent; a change of the display item or the connected set is sent.

### 5.5 Server tick and state machine

`Server.tick(level, pos, state, config, serverData, sharedData)`, once per server tick:

1. `s` = the block's `vault_state`.
2. If `gameTime mod 20 == 0` and `s` is `active`: `cycleDisplayItemFromLootTable` (5.7).
3. If `gameTime >= serverData.state_updating_resumes_at`: `next = s.tickAndGetNext(level, pos, config, serverData, sharedData)`; the new block state has `vault_state = next`; if the block state object changed (the state differs), `setVaultState`: `setBlockAndUpdate(pos, newState)`, then `oldState.onTransition(level, pos, newState, config, sharedData, ominousFlag)` which runs `old.onExit` then `new.onEnter` (below), where `ominousFlag` is the block's `ominous` property.
4. If server data or shared data is dirty: the synchronisation of section 5.4.

`VaultState.tickAndGetNext` (ordinal order inactive 0, active 1, unlocking 2, ejecting 3), with `updateStateForConnectedPlayers(range)` defined after the table:

| State | Behaviour | Next |
|---|---|---|
| `inactive` | `updateStateForConnectedPlayers(activation_range)` | its result |
| `active` | `updateStateForConnectedPlayers(deactivation_range)` | its result |
| `unlocking` | `state_updating_resumes_at = gameTime + 20` | `ejecting` |
| `ejecting` | if `items_to_eject` is empty: `total_ejections_needed = 0` (`markEjectionFinished`) then `updateStateForConnectedPlayers(deactivation_range)`. Otherwise: `progress = ejectionProgress()` (before popping); pop the last item of the list; `ejectResultItem(level, pos, item, progress)`; `display item = the new last item of the list (the empty stack when none)`; `state_updating_resumes_at = gameTime + 20` (resume 20 ticks later whether or not items remain) | `ejecting` (when items remained, or after the last pop), or the result of `updateStateForConnectedPlayers` when the list was already empty |

`updateStateForConnectedPlayers(range)`: `sharedData.updateConnectedPlayersWithinRange(level, pos, serverData, config, range)`; `state_updating_resumes_at = gameTime + 20`; result `active` when the shared data has any connected player, else `inactive`.

`updateConnectedPlayersWithinRange` (shared data): `players = detector.detect(level, selector, pos, range, false)` (no line of sight), keep only the UUIDs that are **not** in `rewarded_players`, collect them into a set; if that set is not equal to the stored `connected_players`, replace it and mark the shared data dirty. A rewarded player therefore never keeps a vault active. The detector test is `distSqr(player block position, vault position) < range^2` and not a spectator (section 4.3 item 7).

Enter and exit hooks (`onTransition` calls `old.onExit(level, pos, config, sharedData)` and then `new.onEnter(level, pos, config, sharedData, ominous)`); every hook not listed does nothing:

| Hook | Effect |
|---|---|
| `inactive.onEnter` | `display item = empty`; level event 3016 at the block with data 1 when ominous, else 0 (deactivation particles) |
| `active.onEnter` | if the shared data has no display item, run the display cycle (5.7); level event 3015 with data 1 when ominous, else 0 (activation particles) |
| `unlocking.onEnter` | play `vault.insert_item` (blocks, default volume and pitch) at the block |
| `ejecting.onEnter` | play `vault.open_shutter` |
| `ejecting.onExit` | play `vault.close_shutter` |

Sounds in `playSound(null, pos, sound, BLOCKS)` form use the default volume 1 and pitch 1.

### 5.6 Key insertion

`VaultBlock.useItemOn(stack, state, level, pos, player, hand, hit)`:

1. If the held stack is empty, or `vault_state` is not `active`: return "try with empty hand" (nothing happens).
2. On a server level: get the block entity; if it is not a vault entity return "try with empty hand"; call `Server.tryInsertKey(level, pos, state, config, serverData, sharedData, player, stack)`. Both sides return `SUCCESS_SERVER` after this point (so the client swing is accepted and the server does the work).

`tryInsertKey(...)`:

1. `canEjectReward`: the config's key item is non-empty and the state is not `inactive`. If false: return.
2. `isValidToInsert`: the held stack is the same item with the same components as the key item (`isSameItemSameComponents`) and its count is at least the key item's count. If false: play `vault.insert_item_fail` (with the throttle below) and return.
3. If `rewarded_players` contains the player's UUID: play `vault.reject_rewarded_player` (throttled) and return.
4. Roll the reward: `loot_table` from the server's reloadable registries, parameters `origin` = block centre, `luck` = the player's luck, `this_entity` = the player, `tool` = the held stack, parameter set `vault` (26 section 11.9, the set's keys at its line 140), `getRandomItems(params)` (the table's own random sequence). If the rolled list is empty: return (the key is **not** consumed and the player is not marked).
5. Award the statistic `item_used` for the held item to the player.
6. `heldStack.consume(keyItem.count, player)`: shrinks the held stack by the key's count unless the player has infinite materials (creative: nothing is consumed).
7. `unlock`: `items_to_eject = rolled list` (also sets `total_ejections_needed = list size`, marks dirty); `display item = last item of the list`; `state_updating_resumes_at = gameTime + 14`; set the block state to `unlocking` (through `setVaultState`, so `onExit(active)` and `onEnter(unlocking)` run).
8. Add the player to `rewarded_players` (an insertion-ordered set; when the size exceeds 128 the **first** (oldest) element is removed; marks dirty).
9. `updateConnectedPlayersWithinRange(level, pos, serverData, config, deactivation_range)`: the player just rewarded drops out of the connected set.

The insert-failure throttle (`playInsertFailSound`): the sound plays only when `gameTime >= lastInsertFailTimestamp + 15`, and then `lastInsertFailTimestamp = gameTime`. The two failure sounds share the one timestamp. The timestamp is in memory only.

### 5.7 Display item and ejection

Display cycle (`cycleDisplayItemFromLootTable(level, state, config, sharedData, pos)`): if `canEjectReward(config, state)` is false the display item becomes the empty stack; otherwise the table is `override_loot_table_to_display` when present, else `loot_table`; roll it with `origin` = block centre, parameter set `vault`, **no** luck, entity or tool, and **the level's random source** passed explicitly (`getRandomItems(params, random)`); an empty roll gives the empty stack; otherwise a uniform pick of one stack of the roll (`Util.getRandom`); `setDisplayItem(stack)`: no change when the stack equals the current display item (`ItemStack.matches`, count included), otherwise store a copy and mark the shared data dirty.

`ejectResultItem(level, pos, stack, progress)`: spawn the item with the default dispense `spawnItem(level, stack, 2, UP, bottomCenter(pos) moved 1.2 up)` (as in section 4.3 item 10); level event 3017 (eject, data 0); play `vault.eject_item` at volume 1.0 and pitch `0.8 + 0.4 * progress` (floats).

`ejectionProgress()`: `1.0` when `total_ejections_needed == 1`; otherwise `1 - inverseLerp(itemsLeft, 1, total)` with `inverseLerp(v, a, b) = (v - a) / (b - a)` in floats, so with `total = N >= 2` and `k` items left before the pop the value is `1 - (k - 1) / (N - 1)`: 0 for the first item, 1 for the last. With `total = 0` (after a reload, section 5.3) and `k` items left it is `1 + (k - 1)`, which is above 1 for `k >= 2`.

The reward items leave the list from its **end**: the last element of the rolled list is ejected first and is the first display item.

### 5.8 Client tick and level events

`Client.tick(level, pos, state, clientData, sharedData)`: `clientData.updateDisplayItemSpin()` (`previousSpin = currentSpin`, `currentSpin = wrapDegrees(currentSpin + 10)`, the 10 being `ROTATION_SPEED`); every 20th game tick (`gameTime mod 20 == 0`) emit connection particles for each connected player in range; then idle particles with the flame `soul_fire_flame` when the block is ominous, else `small_flame`; then the ambient sound (`playIdleSounds`, only while the shared data has a display item: probability 0.02 per tick of `vault.ambient` at volume `nextFloat * 0.25 + 0.75` and pitch `nextFloat + 0.5`). All particle formulas, the keyhole position, the cage positions and the activation and deactivation bursts are 42-6 section 4.4. Level events used: 3015 (activate), 3016 (deactivate), 3017 (eject item). A connected player counts for the connection particles when `distSqr(player block position, vault position) <= connected_particles_range^2` (the client test is `<=`).

## 6. Persistence and synchronisation seen from the chunk

- The chunk file stores, for each of these entities, the 31-1 section 2.2 "with full metadata" compound plus `keepPacked` (31-1 section 6) with the keys of sections 3.1, 4.1 and 5.3. An entity that was never promoted from its pending compound is saved back verbatim.
- The chunk packet carries, for each live entity, the type id and `getUpdateTag` of this part (31-1 section 5.3). After a block change at the position the broadcast sends the block update and the entity's update packet (29 section 7.2); `sendBlockUpdated` only marks the position as changed (the code calls the chunk source's change recorder first; the integer flag, 260 for the spawner, 3 for the trial spawner's `markUpdated`, 2 for the vault, is not used for the choice of packets, read in `ServerLevel.sendBlockUpdated`).
- The spawner, trial spawner and vault never send a packet outside this mechanism; the only block event is the spawner's event 1.

## 7. Worked examples

Numbers are computed from the rules above.

**7.1 Spawner position draws.** Spawner at block `(10, 64, -3)`, `SpawnRange` 4, no `Pos` in the entity compound. Draws in order: `nextDouble` 0.75, `nextDouble` 0.25, `nextInt(3)` 2, `nextDouble` 0.10, `nextDouble` 0.60. `x = 10 + (0.75 - 0.25) * 4 + 0.5 = 12.5`; `y = 64 + 2 - 1 = 65`; `z = -3 + (0.10 - 0.60) * 4 + 0.5 = -4.5`. The crowd count box is `[10, 64, -3]` to `[11, 65, -2]` inflated by 4: `[6, 60, -7]` to `[15, 69, 2]`.

**7.2 Spawner delay.** `MinSpawnDelay` 200, `MaxSpawnDelay` 800: a rolled delay is `200 + nextInt(600)`, so 200 to 799. With `MinSpawnDelay` 500 and `MaxSpawnDelay` 300 the delay is exactly 500 (max not above min). A spawner whose NBT has `Delay` 0 attempts a round on its first server tick with a player in range (the delay is not above 0).

**7.3 Spawner NBT from a command.** Setting a block entity with `{SpawnData: {entity: {id: "zombie"}}}`: the spawn data compound is normalised to `{entity: {id: "minecraft:zombie"}}`; the keys not given take their defaults; `SpawnPotentials` becomes one entry `{data: {entity: {id: "minecraft:zombie"}}, weight: 1}`; the entity compound has exactly one key `id`, so each spawned zombie is finalised. The update tag sent to clients holds `Delay`, the five other numbers as shorts and `SpawnData`, and not `SpawnPotentials`.

**7.4 Trial spawner mob totals.** Default config (`total_mobs` 6.0, 2.0 per extra player; `simultaneous_mobs` 2.0, 1.0 per extra): one player (`extra` 0): total 6, simultaneous 2; three players (`extra` 2): total `floor(6 + 4) = 10`, simultaneous `floor(2 + 2) = 4`. Breeze normal file (`total_mobs` 2.0, 1.0 per extra; `simultaneous_mobs` 1.0, 0.5 per extra): one player: 2 and 1; two players: `floor(2 + 1) = 3` and `floor(1 + 0.5) = 1`; three players: 4 and `floor(1 + 1) = 2`. Breeze ominous file (`total_mobs` 4.0, no `simultaneous_mobs` so 2.0, 0.5 per extra): three players: `floor(4 + 2) = 6` and `floor(2 + 1) = 3`. The same ominous file also overrides the eject table (weights 3 and 7, section 4.2), so a reward from an ominous breeze spawner comes from the key table in 3 of 10 picks on average.

**7.5 Trial spawner placed by a template.** The `melee/zombie` spawner template holds a block `trial_spawner` with `ominous` false, `trial_spawner_state` `waiting_for_players` and the block entity `{id: "minecraft:trial_spawner", normal_config: "minecraft:trial_chamber/melee/zombie/normal", ominous_config: "minecraft:trial_chamber/melee/zombie/ominous"}` (read from `data/minecraft/structure/trial_chambers/spawner/melee/zombie.nbt`; the `breeze` template has the same shape with the breeze keys). The other three keys take their defaults (cooldown 36000, range 14, all state data empty). The normal file there is `{simultaneous_mobs: 3.0, simultaneous_mobs_added_per_player: 0.5, spawn_potentials: [{data: {entity: {id: "minecraft:zombie"}}, weight: 1}], ticks_between_spawn: 20}`; `total_mobs` is the default 6.0.

**7.6 Trial spawner reward timeline.** Wave finished at game time `T` (the tick the `active` row sets `cooldown_ends_at = T + 36000`). State `waiting_for_reward_ejection` from `T + 1`; `gameTime >= T + 40` holds first at `T + 40`, which plays `trial_spawner.open_shutter` and gives `ejecting_reward`. With two detected players: at `T + 60` (`(60) mod 30 = 0`) the first reward is rolled from the chosen table and one player is removed; at `T + 90` the second reward and the second player; at `T + 120` the set is empty, so the shutter close sound plays, `ejecting_loot_table` is cleared and the state is `cooldown`. In `cooldown`, `tryDetectPlayers` is called first (every 20 ticks, position-staggered) but returns before refreshing the set unless a detected player carries the `trial_omen` effect on a non-ominous spawner (item 6 of section 4.3), so the set is normally still empty here. Then: if the detected set is **non-empty**, `total_mobs_spawned = 0`, `next_mob_spawns_at = 0` and the state goes directly to `active`, without waiting for `cooldown_ends_at`; only when the set is empty and `gameTime >= T + 36000` is the ominous property cleared, the state data reset and the state set to `waiting_for_players`; otherwise it stays in `cooldown`. (Read in `TrialSpawnerState.tickAndGetNext`.)

**7.7 Detection range.** Trial spawner at `(0, 70, 0)`, range 14 (`196` squared): a player at block `(10, 70, 9)` has `distSqr = 100 + 81 = 181`, below 196: detected. At `(14, 70, 0)` the value is 196, not below: not detected.

**7.8 Vault ejection and sound pitch.** Vault active, key accepted at game time `G = 1000` with a rolled list `[a, b, c]` (3 items). `unlock`: list stored, `total = 3`, display `c`, `state_updating_resumes_at = 1014`, state `unlocking` (insert sound). At 1014: `resumes_at = 1034`, state `ejecting` (open shutter). At 1034: `k = 3`: progress `1 - 2/2 = 0`, pitch `0.8`; eject `c`; display `b`; `resumes_at = 1054`. At 1054: `k = 2`: progress `1 - 1/2 = 0.5`, pitch `1.0`; eject `b`; display `a`. At 1074: `k = 1`: progress `1 - 0/2 = 1`, pitch `1.2`; eject `a`; display empty; list empty; `resumes_at = 1094`. At 1094: list empty: `total = 0`; connected players updated; `resumes_at = 1114`; state `active` (a player still within 4.5 blocks and not rewarded) or `inactive`. A single-item reward (`total = 1`) ejects at pitch `0.8 + 0.4 = 1.2`. After a reload between 1034 and 1054 the in-memory `total` is 0, so at 1054 (`k = 2`) the progress is `1 - (2 - 1) / (0 - 1) = 2`, pitch `1.6`.

**7.9 Vault key rules.** Config key item `minecraft:trial_key` count 1: a stack of 3 trial keys is valid and 1 is consumed; an `ominous_trial_key` is not the same item: insert-fail sound, nothing consumed. A creative player's insertion is accepted and consumes nothing. A second insertion by the same player after the reward: `vault.reject_rewarded_player`, at most one failure sound per 15 ticks across both failure kinds. A vault with `key_item` absent from its config (empty stack): `canEjectReward` is false, the display item is always empty, and a key use does nothing.

**7.10 Vault ranges.** Defaults: activation 4.0, deactivation 4.5. Player block at `(3, 0, 2)` from the vault: `distSqr = 13 < 16`: connects (the vault becomes `active`). After connecting, the player stays connected while `distSqr < 20.25`: block offset `(4, 0, 1)` gives 17: still active; `(4, 0, 2)` gives 20: still active; `(4, 0, 3)` gives 25: disconnects at the next 20-tick update.

## 8. Validation

An implementation is correct when all of the following hold.

1. The three types have ids 9, 43, 44 with `spawner`, `trial_spawner`, `vault` as their only valid blocks, and the two spawners are operator-only for `block_entity_data` items.
2. Spawner save: the seven numbers are shorts; load accepts shorts or ints for the six, a short for `Delay`; defaults 20, 200, 800, 4, 6, 16, 4; `SpawnPotentials` falls back to one entry of weight 1.
3. Spawner list entries require `weight`; a missing `weight` fails the entry's decode.
4. The spawner update tag lacks `SpawnPotentials`, `id` and `components`; the block event 1 resets the client delay to the minimum; the data argument of the event is 0.
5. Weighted pick draws exactly one `nextInt(total)` and walks entries in order; empty or zero-total lists give nothing and draw nothing.
6. Spawner break pays 15 to 43 experience only when the experience flag is set, and drops nothing else.
7. Trial spawner load applies the packed state with defaults (a tag with only `next_mob_spawns_at` empties the sets) and falls back to the default full config when the config keys are absent.
8. The trial spawner update tag holds `next_mob_spawns_at` only in state `active`, and `spawn_data` when present, nothing else.
9. The default config has 6.0, 2.0, 2.0, 1.0, 40, empty potentials, the two default eject tables (weight 1 each) and the 160-tick item spawner constant; the derived totals use floor of a float.
10. The untracked rule removes a mob that is missing, dead, in another dimension or beyond squared distance 2209.
11. Detection runs only when `(asLong + gameTime) mod 20 == 0`, uses strict squared distance, excludes creative and spectators, and requires line of sight for the first detection step and so for the initial acquisition, and drops it only for the refresh of an already non-empty set (item 6 of section 4.3; 44-2 section 4.5).
12. Ejection acts when `(gameTime - (cooldown_ends_at - target_cooldown_length)) mod 30 == 0` in `ejecting_reward`, ejecting once per detected player, and level event 3014 is sent only for a non-empty roll.
13. Vault: `vault_state` order inactive, active, unlocking, ejecting; light 6, 12, 12, 12; default config values; `activation_range > deactivation_range` rejects the config; absent `key_item` is the empty stack.
14. Vault tick order: display cycle (every 20th tick, only `active`), then the state tick when `gameTime >= state_updating_resumes_at`, then dirty handling; only the shared data is sent to clients; the client config is always the default.
15. The state tick delays: connected-player update 20 ticks; unlocking 14 ticks after the key (set by `unlock`) and then 20 more before the first ejection; 20 ticks between ejections and after the last.
16. Key insertion order of checks: can-eject, valid key, already rewarded, loot roll non-empty, statistic, consume, unlock, mark rewarded, update connected players; the key count is the config's, creative consumes nothing.
17. The rewarded set is insertion-ordered and drops its oldest member beyond 128.
18. Ejection pops from the end of the list; the progress formula and pitch `0.8 + 0.4 * progress`; `total_ejections_needed` is saved but not restored on load (the documented quirk), and `lastInsertFailTimestamp` is not saved.
19. `spawnItem` for ejected items uses accuracy 2 and the 1.2-block offset above the block bottom centre.
20. Particles, sounds and level events 2004, 3011 to 3017, 3019, 3020 follow 42-6; this part only fixes when they are sent.

## Open questions

1. **Write side of defaults.** Whether the codecs write a field equal to its default (for example the trial spawner `target_cooldown_length`, the vault `activation_range`) or omit it was not readable: the serialization library is not in the artifact. This document gives full read tolerance; a writer may write every key. Round-trip tests should compare by reading, not by byte equality.
2. **Order of the hash sets.** `registered_players`, `current_mobs` and the vault `connected_players` are hash sets in memory (`HashSet`, and `Set.copyOf` when saved); the order of the saved lists and the choice of "the first" player removed per ejection are not defined by the data. The rewarded set is insertion-ordered.
3. **`overridePeacefulAndMobSpawnRule`.** The setter exists on `TrialSpawner`; no caller was found in the packages read (it is probably a test hook). Treated as never set.
4. **How a vault becomes ominous.** The `ominous` property of a vault is set by the structure template (section 5.2) and by commands; no code in the vault package changes it. Other callers (outside the packages read) were not searched.
5. (Resolved: `Util.getRandom` is one `nextInt(size)` draw and an index, read.)
6. **`getOrCreateDisplayEntity`** of the spawner and of the trial spawner: after loading the display entity the code inspects the entity compound size and entity type (a branch that handles a mob display with only an `id`); the body of that branch was not decoded. It affects only the client display.
7. **Spawner entity checks** The call order is in section 3.4; the bodies of `EntityType.getSpawnAABB`, `SpawnPlacements.checkSpawnRules`, `Mob.checkSpawnRules`, `checkSpawnObstruction` and `finalizeSpawn` are described in 18 and 44; this part only calls them.
8. **`LIVING_ENTITY_STILL_ALIVE` and `NO_SPECTATORS`**: bodies read in `EntitySelector` (alive and living; not spectator); which lambda belongs to which field was inferred from declaration order; what `isAlive` tests inside the entity class was not read.
9. **Structure templates other than the three read** (the 14 trial spawner templates were checked by pattern: the zombie and breeze files were decoded, the other twelve follow the same file naming; the dungeon spawner and the other structure spawners are 44-2 section 10). The vault templates read are the two in section 5.2.
10. **Spawn egg and spawner item flows** (placing a spawner item with `block_entity_data`, `/data merge` on these entities) use 44-2 section 5 and 29 section 9.6; this part only gives the entity side.
11. **Trial spawner `Pos` default for the display entity.** The client display entity uses the entity compound as stored, with no `Pos` processing; whether the spawner's visible spin position uses the block centre is a rendering matter (client rendering rounds).
12. (Resolved: UUID int order read, section 4.1.)
