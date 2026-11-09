# Residual mob questions, part 2: spawner blocks, trial spawners, custom spawners, spawn lists and structure spawns

| Item | Value |
|---|---|
| Covers | Round RS26, part 2. The spawner block (`BaseSpawner`: tick, spawn data, delay arithmetic, spawn eggs on spawners); the trial spawner (states, configuration, ominous variant); the spawn egg item components; the five custom spawners and their gating; how a spawn list is picked (`WeightedList`, duplicate entries); how the biome attribute `natural_mob_spawns` is combined (`overlay`); structure `spawn_overrides` and the "piece" versus "full" bounding-box rule for all 52 structures; spawns placed by structure pieces and templates (mineshaft, fortress, stronghold, mansion, bastion, villages, igloo, pillager outpost, trial chambers); the contents of the spawn tags; the ocelot-in-the-monster-list consequence (`jungle` and `bamboo_jungle` only); cross-references for the Turtle, Slime and Animal predicates. Closes 18 Open questions 4 and 17, 19 Open questions 4, 5, 6 and 35, 20 Open question 12, 21 Open questions 2, 3, 6 and 22. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the JSON and structure NBT data inside the jar, with no execution. A statement is read from the artifact unless it is marked "(inferred)" or names an open question. Each fact was read in this round; no item is marked "(recalled, not verified)". The items marked "(inferred)" are the odds arithmetic of 10.5, the statement in 10.9 that structure-block markers are filtered by the template's ignore setting, and the block names attributed to the `isValidSpawn` lambdas in 11. |
| Status | Written by the reader for the story "all the standard mobs exist and have their standard behavior" (`tickets/CC-0001-client-polish.md`) and the gaps GAP-31 and GAP-18 of `docs/design/README.md` Part 5 |

Class names in backticks say where a fact was read; they are not the design. Following the operator's data-versus-code
rule, data rows (the 28 trial spawner config files, the 67 biome spawn tables, the 1511 structure templates, loot tables,
tags) are not tabulated: the schema, the semantics and the engines that read them are. The two exceptions are small
tables that the engines depend on and that the earlier documents asked for: the structure `spawn_overrides` of all 52
structures (§8) and the spawn tags (§11). "18 §N" cites
`18-mob-framework.md`. The villager, POI, siege, cat and iron golem details are in
[44-residual-mob-questions-3-villagers-poi-raids.md](44-residual-mob-questions-3-villagers-poi-raids.md), cited here
as "44-3".

## Contents

1. Scope, closed questions and what is cross-referenced
2. Spawner block (`BaseSpawner`), including the spawn reasons (2.5)
3. Spawn data (`SpawnData`) and custom spawn rules
4. Trial spawner
5. Spawn egg components and spawner targets
6. Custom spawners: the list, the order and the gating
7. Picking from a spawn list: `WeightedList`, duplicates, `overlay`
8. Structure `spawn_overrides` and `mobsAt`
9. The ocelot in the monster list (19 Open question 35)
10. Mobs placed by structure pieces and templates
11. Spawn tags
12. Spawn predicates owned elsewhere (Turtle, Slime, Animal)
13. Villages: the spawn rules that depend on the village test
14. Worked examples
15. Validation
16. Open questions

## 1. Scope, closed questions and what is cross-referenced

| Question | Answer in |
|---|---|
| 18 OQ 4: trial spawner states, configuration, ominous variant | 4 |
| 18 OQ 4: spawn egg item components beyond 18 §6.12 | 5 |
| 18 OQ 4: custom spawners `tickCustomSpawners` (phantom, patrol, trader, cat, siege) | 6 (the rules themselves are in 20 §12 phantom, 20 §14.1 patrol, 19 §23 trader, 44-3 §§1.6 and 1.7 cat and siege; this document adds the list, the order and the gating) |
| 18 OQ 17: `spawn_overrides` replacement rule, "piece" versus "full", all structures | 8 |
| 21 OQ 2: biome `overlay` modifier combination | 7.3 |
| 21 OQ 3: bastion and Nether fortress spawners and preplaced mobs (spawn semantics only) | 10 |
| 21 OQ 6: Turtle, Slime and Animal predicates | 12 |
| 21 OQ 22: hoglin and zoglin weights in structures | 8.4, 10.5 |
| 20 OQ 12: mineshaft cave-spider spawner blocks, mansion evoker and vindicator | 10.1, 10.4 |
| Spawner block tick, spawn data and delay arithmetic | 2, 3 |
| 19 OQ 4: contents of `axolotls_spawnable_on` and `valid_spawn` (the latter has no consumer) | 11 |
| `EntitySpawnReason` values and helper predicates | 2.5 |
| 19 OQ 5 and 35: ocelot in the `monster` lists (two biomes, `jungle` and `bamboo_jungle`) | 9 |
| 19 OQ 6: duplicate biome entries (all five) | 7.1, 7.2 |

Piece geometry of every structure belongs to the structure documents (RS20); here only the spawn behaviour of pieces
is described. The raid-side logic of villages (raids, bells, villager brain) is in 44-3 and 20 §14.

## 2. Spawner block (`BaseSpawner`)

`BaseSpawner` is the engine of the mob spawner block (`SpawnerBlockEntity`, block entity type `mob_spawner`) and of the
spawner minecart. 18 §6.12 (spawn eggs, spawner blocks and trial spawners) gives the attempt
steps; this section adds every field, default, saved name and the parts that section did not give. All values were
re-read in this round and agree with 18 §6.12.

### 2.1 Fields, defaults and saved names

| Field | Saved name (NBT) | Default | Meaning |
|---|---|---|---|
| `spawnDelay` | `Delay` | 20 | ticks until the next attempt round; -1 means "roll a delay now" |
| `minSpawnDelay` | `MinSpawnDelay` | 200 | lower bound of a rolled delay |
| `maxSpawnDelay` | `MaxSpawnDelay` | 800 | upper bound (exclusive of the draw, see 2.3) |
| `spawnCount` | `SpawnCount` | 4 | attempts per round |
| `maxNearbyEntities` | `MaxNearbyEntities` | 6 | cap on same-class entities in the count box |
| `requiredPlayerRange` | `RequiredPlayerRange` | 16 | a player must be within this distance of the block centre |
| `spawnRange` | `SpawnRange` | 4 | half-width of the random spawn area and the count-box inflation |
| `nextSpawnData` | `SpawnData` | unset (the constructor does not set it) | the entity that the next round creates |
| `spawnPotentials` | `SpawnPotentials` | an empty weighted list | weighted choices for the next spawn data |

Number types: all seven numeric keys (`Delay`, `MinSpawnDelay`, `MaxSpawnDelay`, `SpawnCount`, `MaxNearbyEntities`, `RequiredPlayerRange`, `SpawnRange`) are **saved as shorts** (`putShort`). On load `Delay` is read as a short (`getShortOr`) and the other six are read as ints (`getIntOr`), so a hand-written file may use int tags for those six.

A new block entity starts with the defaults above (`spawnDelay` 20, an empty potentials list, no next spawn data). On load: every missing key takes the default; only when the `SpawnPotentials` key is missing does the potentials list fall back to a single entry equal to the loaded `SpawnData` (that one-entry list exists only on this load path, not in a fresh block entity). `setEntityId(type)` (used by
generators, spawn eggs and `/setblock` data tools) takes the current next spawn data (creating the empty one when
there is none) and writes only the key `id` of its entity tag; custom rules, equipment and extra entity keys are left
as they were. A spawner whose entity tag has no `id` cannot spawn: every round ends in step 1 of the attempt below
with a delay roll.

### 2.2 Server tick (confirmation and additions)

Per server tick, with the block centre `c = block + 0.5` on each axis:

1. Stop unless a living (not spectator) player is within `requiredPlayerRange` of `c` (`Level.hasNearbyAlivePlayer`)
   and the game rule `spawner_blocks_work` is true (`ServerLevel.isSpawnerBlockEnabled`).
2. If `spawnDelay` is -1: roll a delay (2.3) and fall through to step 3 with the new value.
3. If `spawnDelay > 0`: decrement it and stop. (A delay of `d` therefore means `d` ticks of counting and the attempt
   round on the following tick, and the counter only runs while step 1 passes.)
4. Otherwise run `spawnCount` attempts (18 §6.12 steps 1 to 7). The first spawn data is
   `nextSpawnData` (or the weighted pick when none is set, which also stores the pick). An attempt that fails the
   collision, spawn-rule or position test only ends that attempt; an unknown entity type, a failed load, a reached
   `maxNearbyEntities` or a failed add rolls a delay and stops the round at once (18 §6.12 states which).
5. After the loop, if at least one attempt created an entity, roll a delay.

The attempt's random-position rule is as in 18 §6.12 step 1: `Pos` from the entity tag when present, otherwise
`x = bx + (nextDouble - nextDouble) * spawnRange + 0.5`, `y = by + nextInt(3) - 1`, `z = bz + (nextDouble -
nextDouble) * spawnRange + 0.5` (two `nextDouble` draws per horizontal axis, x then z, `y` drawn between them in the
order x, y, z). The loaded entity is given a random yaw `nextFloat * 360` and pitch 0. The count in step 5 of the
attempt is of entities of exactly the loaded class in the box from the block corner to corner + 1 inflated by
`spawnRange` on all three axes, excluding spectators.

### 2.3 Delay arithmetic

`delay`: if `maxSpawnDelay <= minSpawnDelay` then `spawnDelay = minSpawnDelay`, else `spawnDelay = minSpawnDelay +
nextInt(maxSpawnDelay - minSpawnDelay)`, so the range is `[min, max - 1]` (200 to 799 by default). Then the weighted
pick of the next spawn data is made from `spawnPotentials` (`WeightedList.getRandom`, §7.1; an empty list
changes nothing) and stored as `nextSpawnData`, and the block event 1 is broadcast to clients (`broadcastEvent`, which for
the spawner block is `blockEvent(pos, spawner, 1, 0)`). The random source for the roll is the level's.

### 2.4 Client side

`triggerEvent(1)` on a client sets the client's `spawnDelay` to `minSpawnDelay`. The client tick runs only while a
player is within `requiredPlayerRange` (otherwise it only copies `spin` to `oSpin`): if it has a display entity it adds
one smoke and one flame particle at `(bx + nextDouble, by + nextDouble, bz + nextDouble)`, decrements its own
`spawnDelay` while above 0 and advances `spin = (spin + 1000 / (spawnDelay + 200)) mod 360` (floats as read: the
numerator `1000.0f`, the addend `200.0f`). The display entity is a client-side copy of the next spawn data's entity
(for the render of the spinning mob). The block update packet omits `SpawnPotentials` (`getUpdateTag` removes it).

### 2.5 Spawn reasons (`EntitySpawnReason`) and the helper predicates

The enum has 19 values, in ordinal order: `NATURAL`, `CHUNK_GENERATION`, `SPAWNER`, `STRUCTURE`, `BREEDING`,
`MOB_SUMMONED`, `JOCKEY`, `EVENT`, `CONVERSION`, `REINFORCEMENT`, `TRIGGERED`, `BUCKET`, `SPAWN_ITEM_USE`, `COMMAND`,
`DISPENSER`, `PATROL`, `TRIAL_SPAWNER`, `LOAD`, `DIMENSION_TRAVEL`.

| Predicate | True for |
|---|---|
| `isSpawner` | `SPAWNER` and `TRIAL_SPAWNER` |
| `ignoresLightRequirements` | `TRIAL_SPAWNER` only |

Where they bite (read): `Mob.checkMobSpawnRules` skips the block test (`BlockState.isValidSpawn` on the block below)
entirely when `isSpawner` is true, and otherwise requires it (§11); the monster light rules use
`ignoresLightRequirements` (18 §6.8), so a normal mob spawner still obeys the light rule and only the trial
spawner does not. The reasons that skip the Peaceful test or other gates are owned by the per-mob predicates (18 §6.8,
19 and 20); this document lists only the two helpers. The full table of the 19 reasons (producers, which reasons run
`checkSpawnRules` and `checkSpawnObstruction`, and the reason-specific branches inside `finalizeSpawn` and the per-mob
predicates) is in 44-1 RQ-1.18 and is not repeated here. The reasons that bear on this document are `SPAWNER` and
`TRIAL_SPAWNER` (both gates run, 2.2 and 4.7), `STRUCTURE` (code and template placement, §10, no gate run) and
`NATURAL` (the spawn lists of §§7 to 9).

### 2.6 Spawner minecart (`MinecartSpawner`, closed)

The cart owns a `BaseSpawner` whose only override is the broadcast: `broadcastEvent(level, pos, id)` calls
`Level.broadcastEntityEvent(cart, (byte) id)` (an entity event to the trackers of the cart) instead of the block event of the
block entity spawner. The cart's `handleEntityEvent` passes the id to `BaseSpawner.onEventTriggered` (the client-side
reset of the display entity and the delay). The server tick (the ticker lambda) and the client tick both run the
`BaseSpawner` with `blockPosition()` of the cart as the spawner position, so the player range test (`isNearPlayer`, 16
blocks in the default), the random-position box of 18 §6.12 step 1, the nearby count box and everything else in
§2 are unchanged and use that block position. The block-entity-only paths (`triggerEvent(1)` and the block update
with flags 3) do not apply to the cart.

## 3. Spawn data (`SpawnData`) and custom spawn rules

`SpawnData` is a record of three fields, in this codec form:

| Key | Type | Required | Meaning |
|---|---|---|---|
| `entity` | compound | yes | the entity NBT; `id` is the entity type (the codec reads the key `id`) |
| `custom_spawn_rules` | object | no | `block_light_limit` and `sky_light_limit`, each an inclusive integer range (below) |
| `equipment` | object | no | an equipment table (`EquipmentTable`): `loot_table` (required, a loot table key) and `slot_drop_chances` (optional, a map from equipment slot name to float); applied to a spawned `Mob` after creation |

`custom_spawn_rules` keys (both optional, read leniently with `lenientOptionalFieldOf`):

| Key | Required | Default | Form |
|---|---|---|---|
| `block_light_limit` | no | 0 to 15 | object `{ min_inclusive, max_inclusive }` (an `InclusiveRange` of ints) |
| `sky_light_limit` | no | 0 to 15 | same form |

Decoding of a range fails when `min_inclusive` is greater than `max_inclusive` (message "min_inclusive must be less
than or equal to max_inclusive"), and each of the two ranges is validated to lie within the light range [0, 15].
The check is `isValueInRange` on the block light (`LightLayer.BLOCK`) and on the effective sky brightness below.

A list of spawn data is `{ data: <SpawnData>, weight: <int> }` entries (`WeightedList` codec), used for
`SpawnPotentials` and for the trial spawner `spawn_potentials`.

`custom_spawn_rules.isValidPosition(pos, level)` is true when the block light at `pos` (`LightLayer.BLOCK` brightness)
lies in `block_light_limit` and `ServerLevel.getEffectiveSkyBrightness(pos)` (the sky light reduced by the time of day
or by thunder) lies in `sky_light_limit`. The spawner applies custom rules instead of `SpawnPlacements.checkSpawnRules`
(18 §6.12 step 3), so a spawner with custom rules also ignores the entity type's placement and its light
predicate; it keeps only the Peaceful test for non-friendly categories. The trial spawner applies the same record
(§4.4 step 5) but always runs `SpawnPlacements.checkSpawnRules` for the reason `TRIAL_SPAWNER` first.

## 4. Trial spawner

The trial spawner block (`TrialSpawnerBlock`, block entity `trial_spawner`, class `TrialSpawner` holding the engine)
spawns waves of mobs for the players it detects, then ejects rewards. Its numbers come from a registry
`trial_spawner_config` (one data file per config; 28 files in the jar, 14 normal and ominous pairs under
`trial_spawner/trial_chamber/`) plus the block entity's own saved data.

### 4.1 Block state

| Property | Values | Default |
|---|---|---|
| `trial_spawner_state` (`STATE`) | `inactive`, `waiting_for_players`, `active`, `waiting_for_reward_ejection`, `ejecting_reward`, `cooldown` (the serialized names of the six states) | `inactive` |
| `ominous` | boolean | false |

The state table (`TrialSpawnerState`), in ordinal order:

| Ordinal | State | Light level | Spinning-mob speed | Capable of spawning | Client particles |
|---|---|---|---|---|---|
| 0 | `inactive` | 0 | -1 (no spinning mob) | no | none |
| 1 | `waiting_for_players` | 4 | 200 | yes | small flames: with probability 1/2 per client tick one `small_flame` particle (`soul_fire_flame` when ominous) at the block centre offset randomly by 0.9 |
| 2 | `active` | 8 | 1000 | yes | flames and smoke: one `smoke` and one `flame` (`soul_fire_flame` when ominous) per tick at a random offset of 1.0 |
| 3 | `waiting_for_reward_ejection` | 8 | -1 | no | small flames as above |
| 4 | `ejecting_reward` | 8 | -1 | no | small flames as above |
| 5 | `cooldown` | 0 | -1 | no | smoke inside and on the top face: a `smoke` particle with probability 1/3 per tick (offset 0.9), and once every 20 game ticks (`gameTime mod 20 == 0`) `20 + nextInt(4)` smoke particles at the top centre `(+0, +0.5, +0)` |

A "spinning mob" state (speed above or equal to 0) shows the display entity of the next spawn data, whose `spin`
advances each client tick by `speed / (max(0, nextMobSpawnsAt - gameTime) + 200)` modulo 360 (doubles). In a state
that is capable of spawning, each client tick plays the ambient sound with probability 0.02 (`nextFloat <= 0.02`):
`trial_spawner.ambient` (`ambient_ominous` when ominous), volume `nextFloat * 0.25 + 0.75`, pitch `nextFloat + 0.5`.
Particles and sounds are cosmetic and are listed for the client round only.

### 4.2 Configuration (`TrialSpawnerConfig` and `TrialSpawner$FullConfig`)

`FullConfig` (the block entity's saved `normal_config`, `ominous_config`, `target_cooldown_length`,
`required_player_range`):

| Key | Type and range | Default |
|---|---|---|
| `normal_config` | a config (registry key or inline) | the default config below |
| `ominous_config` | a config | the default config below |
| `target_cooldown_length` | non-negative int, ticks | 36000 |
| `required_player_range` | int 1 to 128 | 14 |

`TrialSpawnerConfig` keys (all optional):

| Key | Type and range | Default |
|---|---|---|
| `spawn_range` | int 1 to 128 | 4 |
| `total_mobs` | float, at least 0 | 6.0 |
| `simultaneous_mobs` | float, at least 0 | 2.0 |
| `total_mobs_added_per_player` | float, at least 0 | 2.0 |
| `simultaneous_mobs_added_per_player` | float, at least 0 | 1.0 |
| `ticks_between_spawn` | int, at least 0 | 40 |
| `spawn_potentials` | weighted list of `SpawnData` | empty |
| `loot_tables_to_eject` | weighted list of loot table keys | `spawners/trial_chamber/consumables` and `spawners/trial_chamber/key`, weight 1 each |
| `items_to_drop_when_ominous` | loot table key | `spawners/trial_chamber/items_to_drop_when_ominous` |

Derived values, with `extra` = the number of additional players (§4.3):

- `targetTotalMobs(extra) = floor(total_mobs + total_mobs_added_per_player * extra)`;
- `targetSimultaneousMobs(extra) = floor(simultaneous_mobs + simultaneous_mobs_added_per_player * extra)`;
- `ticksBetweenItemSpawners = 160`: a constant returned by every config; it has no data key and is unrelated to the ominous config's `ticks_between_spawn` (20 or 160 in the data).

How the data uses these (read from the 28 files, no rows listed): every config sets `spawn_potentials` with one or
two entities; `ticks_between_spawn` is 20 in 22 of the 28 files and 160 in 6 (the three `slow_ranged` variants skeleton, poison_skeleton and stray, each in its normal and ominous file); the normal and ominous file of a pair differ in
`loot_tables_to_eject` in all 14 pairs, because only the ominous file sets it: a weighted list of the two ominous loot
tables (`spawners/ominous/trial_chamber/key` weight 3, `.../consumables` weight 7). The totals differ in only 5 of the 14
pairs. In `breeze` the normal file has `total_mobs` 2.0 and `simultaneous_mobs` 1.0 and the ominous file has `total_mobs`
4.0 and no `simultaneous_mobs` (the default 2.0). In `melee/spider`, `small_melee/cave_spider`, `small_melee/silverfish` and
`small_melee/slime` the normal file sets `simultaneous_mobs` 3.0 and no `total_mobs` (the default 6.0) and the ominous file
has `total_mobs` 12.0 and `simultaneous_mobs` 4.0; `simultaneous_mobs_added_per_player` 0.5 is set in both files of those
pairs (not only the ominous one). The other 9 pairs have identical totals. The ominous file also carries an `equipment`
loot table on its spawn data in 9 pairs (`melee/husk`, `melee/zombie`, the three `ranged`, the three `slow_ranged` and
`small_melee/baby_zombie`; for example `equipment/trial_chamber_melee` with `slot_drop_chances` 0.0; keys as in §3);
no normal file has one. No file at all, normal or ominous, sets `spawn_range` (all 28 use the default 4) or `items_to_drop_when_ominous`. Only the ominous files carry `loot_tables_to_eject`. `simultaneous_mobs` is set in 13 of the 14 normal files and 12 of the 14 ominous files (the `breeze` ominous file and the `small_melee/baby_zombie` ominous file leave the default 2.0; the `baby_zombie` normal file also omits it and is the one normal file without it, so both `baby_zombie` files use the default 2.0). Both files of each of the three `slow_ranged` mobs set `simultaneous_mobs` 4.0 and `simultaneous_mobs_added_per_player` 2.0 (default 1.0). Both `breeze` files set `total_mobs_added_per_player` 1.0 and `simultaneous_mobs_added_per_player` 0.5 (14.2 uses these). A spawn data entity may carry
extra keys such as `Size` for a slime. The structure templates of the trial chambers reference the configs by the
block entity keys `normal_config` and `ominous_config`; 14 spawners exist across the templates, one per config pair,
and the two vault blocks carry their own loot table and key item (not part of this section).

### 4.3 Saved state (`TrialSpawnerStateData`)

Fields saved with the block entity (the packed codec's keys, all optional on read): `registered_players` (the
detected players, a set of UUIDs; the engine field is `detectedPlayers`), `current_mobs` (set of UUIDs),
`cooldown_ends_at`, `next_mob_spawns_at`, `total_mobs_spawned`, `spawn_data` (the next spawn data) and
`ejecting_loot_table`. The count of additional players is `max(0, detected - 1)`.

### 4.4 The tick

`tickServer(level, pos, ominousFlag)` runs each server tick with the block's `ominous` property:

1. Set the engine's `isOminous` to the property.
2. Remove from `current_mobs` every mob that is dead, in another dimension, or farther than 47 blocks from the block
   (`squared distance > 47^2 = 2209`, block position of the mob versus the spawner block position, `distSqr`); if at
   least one was removed, `next_mob_spawns_at = gameTime + ticks_between_spawn` of the active config (the pause that
   follows a lost mob).
3. Compute the next state (`tickAndGetNext`, below). If it differs from the current one, store it in the block state.

The active config is the ominous config when `isOminous`, else the normal config. `canSpawnInLevel`: the game rule
`spawner_blocks_work` is true, and (the Peaceful override is set, or the difficulty is not Peaceful and the rule
`spawn_mobs` is true). `hasMobToSpawn`: the next spawn data (taken, or chosen and stored, from the active
`spawn_potentials`) has an entity `id`, or the active potentials list is non-empty.

State transitions (the current state selects the row; each row is the whole behaviour of one tick in that state):

| State | Behaviour | Next |
|---|---|---|
| `inactive` | try to build the display entity for `waiting_for_players` (needs an entity `id` in the next spawn data, reason `TRIAL_SPAWNER`) | `waiting_for_players` if it exists, else `inactive` |
| `waiting_for_players` | if `canSpawnInLevel` is false: reset statistics (clear detected players, `total_mobs_spawned` 0, `next_mob_spawns_at` 0, `cooldown_ends_at` 0) and stay. Else if there is no mob to spawn: `inactive`. Else run player detection (4.5); stay if no player was detected | `active` when at least one player is detected |
| `active` | (a) `canSpawnInLevel` false: reset statistics, go to `waiting_for_players`. (b) no mob to spawn: `inactive`. (c) `extra` = additional players; run player detection; if ominous, run the ominous item spawner (4.6). (d) if `total_mobs_spawned >= targetTotalMobs(extra)`: if `current_mobs` is empty set `cooldown_ends_at = gameTime + target_cooldown_length`, `total_mobs_spawned = 0`, `next_mob_spawns_at = 0` and go to `waiting_for_reward_ejection`; else stay. (e) else if `gameTime >= next_mob_spawns_at` and `|current_mobs| < targetSimultaneousMobs(extra)`: spawn one mob (4.7); on success add its UUID to `current_mobs`, `total_mobs_spawned += 1`, `next_mob_spawns_at = gameTime + ticks_between_spawn`, and store a fresh random pick of the active `spawn_potentials` as the next spawn data | stays `active` except as in (a), (b), (d) |
| `waiting_for_reward_ejection` | let `start = cooldown_ends_at - target_cooldown_length`; when `gameTime >= start + 40` (40 ticks after the last mob died) play `trial_spawner.open_shutter` | `ejecting_reward` at that tick, else stay |
| `ejecting_reward` | act only on ticks with `(gameTime - start) mod 30 == 0` (floats; 30 is `floor(30.0)`). On such a tick: if no detected player is left, play `close_shutter`, clear `ejecting_loot_table`, go to `cooldown`. Else, if `ejecting_loot_table` is empty, pick one from `loot_tables_to_eject` (weighted, once per ejection run and kept until the run ends); eject that table (4.8); then remove one detected player (the first of the set's iteration order) | `cooldown` when no player is left on a 30-tick tick |
| `cooldown` | run player detection (4.5); if any player is now detected: `total_mobs_spawned` 0, `next_mob_spawns_at` 0 and go to `active`. Else if `gameTime >= cooldown_ends_at`: remove the ominous state (block property false, `isOminous` false), reset everything (clear `current_mobs`, next spawn data and the statistics) and go to `waiting_for_players` | `active` or `waiting_for_players` |

Because the 30-tick rule uses `start` (the moment `waiting_for_reward_ejection` was entered), the first ejection
comes on the first tick after the 40-tick wait whose `gameTime - start` is a multiple of 30, which is `start + 60`
(the shutter opens at `start + 40`, `ejecting_reward` is first evaluated at `start + 41`).

Float arithmetic in this tick, with its consequences:

- The shutter-open test converts the absolute game time and the start tick to float: it is `(float)gameTime >= (float)start + 40.0f`. A float has a 24-bit mantissa, so once game time passes 2^24 = 16,777,216 ticks (about 9.7 days of continuous ticking) the conversion rounds to even values or coarser, and the 40-tick wait can come early or late by a few ticks.
- The 30-tick ejection test subtracts in long first (`gameTime - start`) and only the difference is compared as a float, so it stays exact at any game time.

### 4.5 Player detection (`tryDetectPlayers`, `PlayerDetector.NO_CREATIVE_PLAYERS`)

The block entity uses the detector `NO_CREATIVE_PLAYERS` with the selector `SELECT_FROM_LEVEL` (all players of the
level). Detection runs only on ticks where `(blockPos.asLong() + gameTime) mod 20 == 0` (so each spawner scans once per
20 ticks, staggered by its position). A detected player is a player whose block position is closer than
`required_player_range` to the spawner's block position (integer-vector squared distance below the range squared), who
is not in creative and not a spectator, and, when line of sight is required, whose eye position has an unobstructed
visual ray to the block centre (`ClipContext` with `VISUAL` blocks and no fluids; the ray counts as clear when it
misses or ends at the block). Steps:

1. If the state is `cooldown` and the spawner is ominous: stop (no detection at all).
2. `new1` = detection with line of sight required.
3. `ominousApplied` is false when the spawner is already ominous or `new1` is empty. Otherwise choose from `new1`
   (the players that are still online): the first player holding the effect Trial Omen wins at once; else the last
   player holding Bad Omen. If one is chosen: if the effect is Bad Omen, convert it to Trial Omen with duration
   `(amplifier + 1) * 18000` ticks (amplifier 0, no other flags); play level event 3020 at the player's eye block with
   data 0; make the spawner ominous (`applyOminous`: block property `ominous` true, level event 3020 at the block with
   data 1, then `resetAfterBecomingOminous`, 4.6). `ominousApplied` is true when a player was chosen.
4. If the state is `cooldown` and `ominousApplied` is false: stop.
5. If `detected_players` was empty before this call use `new1`; else run a second detection without the line of sight
   requirement (players already inside keep being tracked through walls).
6. Add the result to `detected_players`. If it added anyone: `next_mob_spawns_at = max(next_mob_spawns_at, gameTime +
   40)` (a 40-tick delay after new players arrive), and, if `ominousApplied` is false, emit level event 3019 (ominous)
   or 3013 (normal) at the block with data = the detected-set size (client particle burst).

### 4.6 Ominous variant

`resetAfterBecomingOminous`: every mob in `current_mobs` is discarded (level event 3012 with the normal flame at its
block, equipment dropped through `dropPreservedEquipment` for a `Mob`, removal reason DISCARDED); if the ominous
config's potentials are non-empty the stored next spawn data is cleared; `total_mobs_spawned = 0`; `current_mobs`
cleared; `next_mob_spawns_at = gameTime + ominous.ticks_between_spawn` (the ominous config's key, 20 or 160); `cooldown_ends_at = gameTime + 160` (the item-spawner constant). The
ominous state ends only through the `cooldown` branch above.

While ominous and `active`, each tick `spawnOminousItemSpawner` runs (only if the ominous config's
`items_to_drop_when_ominous` table yields a non-empty list): the loot table is rolled once with an empty loot context
and a seed `level.getSeed() + asLong(floor(x / 30), floor(y / 20), floor(z / 30))` of the spawner position (so the
same stacks are rolled for spawners in one 30 x 20 x 30 cell; the division is float division, `floor(float(x) / 30.0f)`, `floor(float(y) / 20.0f)`, `floor(float(z) / 30.0f)`, not integer division, so a coordinate far from the origin, where the int-to-float conversion rounds, can land in a different cell than exact division would give), every rolled stack is split into single items weighted
by its count, and the list is cached on the engine. When `gameTime >= cooldown_ends_at` (the field is reused as the
item timer): choose a target (alive, non-creative, non-spectator detected players within `required_player_range`
of the block centre, squared distance at most range squared; one `nextBoolean` draw chooses the candidate list: when
true the candidates are the current mobs that are alive and within `required_player_range` of the block centre, when
false they are those qualifying players; an empty list gives no item this tick; a single candidate wins, else
`Util.getRandom` picks uniformly), position `target.position + up (bbHeight + 2 + nextInt(4))`, clip
upward with a visual ray, step one block down and require the block there to have an empty collision shape; create an
`ominous_item_spawner` entity carrying one weighted-chosen item at that position, play `trial_spawner.spawn_item_begin`
at volume 1 and pitch `(nextFloat - nextFloat) * 0.2 + 1`, and set `cooldown_ends_at = gameTime + 160`.

The `OminousItemSpawner` entity: it lives a random 60 to 120 ticks (`spawn_item_after_ticks`, stored as a tick count),
36 ticks before the end it plays `trial_spawner.about_to_spawn_item`, and at the end it spawns its item: a projectile
item (`ProjectileItem`) is launched downward with the dispense config's power and uncertainty and the owner set, any
other item becomes an `ItemEntity` at the spawner; it then emits level event 3021, the `entity_place` game event, and
kills itself.

### 4.7 Spawning one mob (`TrialSpawner.spawnMob`)

1. Take the next spawn data (`getOrCreateNextSpawnData`). Read its entity type; fail (no spawn, nothing counted) when
   it has no valid `id`.
2. Position: the entity tag's `Pos` when present, else `(bx + (nextDouble - nextDouble) * spawn_range + 0.5, by +
   nextInt(3) - 1, bz + (nextDouble - nextDouble) * spawn_range + 0.5)` (order x, y, z, as 2.2).
3. Fail unless the type's spawn box at that point has no collisions.
4. Fail unless a visual ray from the block centre reaches the spawn block (`inLineOfSight`, same rule as 4.5).
5. Fail unless `SpawnPlacements.checkSpawnRules(type, level, TRIAL_SPAWNER, pos, RS)` passes (only the trial spawner
   reason ignores the light rule of monsters, 18 §6.8), and, when the spawn data has custom rules, they pass.
6. Load the entity from the tag with reason `TRIAL_SPAWNER`, moving it to the position with a random yaw
   `nextFloat * 360` and pitch 0. For a `Mob`: fail unless `checkSpawnObstruction` passes; when the entity tag is only
   an `id` (size 1) finalise it with reason `TRIAL_SPAWNER` and no group data; mark it persistent
   (`setPersistenceRequired`); apply the spawn data's equipment table if present.
7. Add with passengers; fail if the add fails. Emit level events 3011 and 3012 at the block with the flame code
   (normal or ominous), the `entity_place` game event, and return the entity's UUID.

### 4.8 Ejecting a reward

`ejectReward(table)`: roll the loot table with an empty context (`LootContextParamSets.EMPTY`, no seed); for each stack
spawn an item with `DefaultDispenseItemBehavior.spawnItem` at the bottom centre of the spawner block moved 1.2 blocks
up (direction UP, speed value 2); then level event 3014 (data 0), emitted only when the rolled list is non-empty.

## 5. Spawn egg components and spawner targets

- A spawn egg item has exactly one egg-specific default component: `entity_data` with the entity type and an empty
  tag (`Item.Properties.spawnEgg`), plus the entity type's required feature flags. The egg's type is read from that
  component (`SpawnEggItem.getType`, `spawnsEntity`); the reverse lookup `byId` finds the item whose `entity_data` type
  matches. There is no separate colour component in the item registry: the egg tint belongs to the client item
  definitions (resource pack).
- Spawning from an egg (use on a block, or on a water source block): `EntityType.spawn(level, stack, player, pos,
  SPAWN_ITEM_USE, alignPosition, invertY)`. The creation steps are: create the entity; position it at
  `(x + 0.5, y + offset, z + 0.5)` of the block with a random yaw `wrapDegrees(nextFloat * 360)` and pitch 0, where the
  offset is 0 when the position is not aligned and otherwise `getYOffset(level, pos, invertY, box)` (read: the
  unit block box at the position is expanded 1 block downward when `invertY` is set; the collisions inside that
  expanded box are collected; the offset is `1.0 + Shapes.collide(Y, box, collisions, limit)`, where `box` is the
  spawned type's own box passed in, `limit` is -1.0 normally and -2.0 when inverted, and `collide` returns the signed
  (non-positive) free downward distance of `box` against those collisions. The offset therefore lies in [0, 1]
  normally and in [-1, 1] when inverted); for a `Mob` set head and
  body rotation to the yaw and call `finalizeSpawn(difficulty at the block, SPAWN_ITEM_USE, no group data)`; then the
  post-spawn processors: `applyComponentsFromItemStack` and the stack's `entity_data`; `addFreshEntityWithPassengers`;
  a `Mob` plays its ambient sound. The egg is consumed with `ItemStack.consume(1, player)` and the `entity_place` game
  event is fired. Using it on a liquid source block (`use`) only passes when the target is a liquid block, the player
  may interact there and place the item (`mayInteract`, `mayUseItemAt`), and then spawns at that block; the item-used
  statistic is awarded on success.
- `Entity.applyComponentsFromItemStack(stack)` applies two components to any entity: `custom_name` (sets the custom
  name) and `custom_data` (stored as the entity's custom data). The 26 entity classes below override `Entity.applyImplicitComponents`/`applyImplicitComponent` in addition to the base class `Entity` (read per class); the next table lists the components each applies. The variant-bearing mobs take their variant, collar colour or sound variant from the item; `Projectile` reads `can_break`, not a variant.

| Class | Components read |
|---|---|
| `Entity` (base) | `custom_name`, `custom_data` |
| `AreaEffectCloud` | `potion_contents`, `potion_duration_scale` |
| `Mannequin` | `profile` |
| `Cushion` | `cushion_color` |
| `Painting` | `painting_variant` |
| `Projectile` | `can_break` |
| `Pig` | `pig_variant`, `pig_sound_variant` |
| `Fox` | `fox_variant` |
| `ZombieNautilus` | `zombie_nautilus_variant` |
| `Sheep` | `sheep_color` |
| `Horse` | `horse_variant` |
| `Llama` | `llama_variant` |
| `Cat` | `cat_variant`, `cat_collar`, `cat_sound_variant` |
| `Wolf` | `wolf_variant`, `wolf_collar`, `wolf_sound_variant` |
| `Parrot` | `parrot_variant` |
| `Chicken` | `chicken_variant`, `chicken_sound_variant` |
| `Rabbit` | `rabbit_variant` |
| `Frog` | `frog_variant` |
| `Salmon` | `salmon_size` |
| `TropicalFish` | `tropical_fish_base_color`, `tropical_fish_pattern`, `tropical_fish_pattern_color` |
| `Axolotl` | `axolotl_variant` |
| `Cow` | `cow_variant`, `cow_sound_variant` |
| `MushroomCow` | `mooshroom_variant` |
| `Villager`, `ZombieVillager` | `villager_variant` |
| `Shulker` | `shulker_color` |
| `SulfurCube` | `sulfur_cube_content` |

The block entity classes that also override a method of this name are not entity spawning and are not listed.

- `entity_data` of the stack is loaded into the new entity (`updateCustomEntityTag`) only when the server exists, the
  stack's type equals the entity's type, and (for the types in `OP_ONLY_CUSTOM_DATA` = {`falling_block`,
  `command_block_minecart`, `spawner_minecart`}) the user is an operator player; a non-operator's egg for those types
  keeps only the type. `SpawnEggItem.shouldPrintOpWarning`: the player has the game-master permission, the stack has
  `entity_data` and its type is in that set.
- **On a spawner** (a block entity that implements `Spawner`: the mob spawner and the trial spawner): the spawn egg
  does nothing and fails, with the message `advMode.notEnabled.spawner` to a server player, when
  `spawner_blocks_work` is false. Otherwise: if the stack has `entity_data` and the player is an operator,
  `setEntityData(entity_data)`; else `setEntityId(type)`. Then the block update is sent (flags 3), the
  `block_change` game event fires and `shrink(1)` is applied to the stack. `ItemStack.shrink` is a plain `grow(-1)` with no infinite-materials test; the creative exemption lives only in `ItemStack.consume(int, LivingEntity)`, which checks `hasInfiniteMaterials`. So on a spawner a creative player's egg stack is reduced (the block-placement path above uses `consume` and is exempt).
  - Mob spawner: `setEntityId` as in 2.1; `setEntityData` replaces the whole spawn data entity with the component's
    data.
  - Trial spawner: `overrideEntityToSpawn`: reset the saved state (`current_mobs`, next spawn data and the
    statistics), replace both configs of the full config with a copy whose `spawn_potentials` is a single entry of
    the given entity (type only, or the type with the component's data), set the block state to `inactive` and mark the
    block entity changed.
- Spawn eggs used on an ageable mob of the same type (`spawnOffspringFromSpawnEgg`) are in 18 §6.12; the new
  baby also receives `applyComponentsFromItemStack`.

## 6. Custom spawners: the list, the order and the gating

`MinecraftServer.createLevels` builds the list once and gives it only to the **Overworld**; the Nether, the End and any
other dimension get an empty list.

| Order | Class | Gate (besides the rules of its own section) | Rules |
|---|---|---|---|
| 1 | `PhantomSpawner` | the call flag (below) and the game rule `spawn_phantoms` | 20 §12 |
| 2 | `PatrolSpawner` | the call flag and `spawn_patrols` | 20 §14.1 |
| 3 | `CatSpawner` | none of its own (no game rule and no flag test) | 44-3 §1.6 |
| 4 | `VillageSiege` | the call flag (false resets the siege) | 44-3 §1.7 |
| 5 | `WanderingTraderSpawner` | the game rule `spawn_wandering_traders` (no flag test) | 19 §23, 44-3 §9 |

`ServerChunkCache.tickChunks` calls `tickCustomSpawners(spawnEnemies)` once per tick, after the block random ticks,
passing the chunk cache's `spawnEnemies` field (18 §6.1 step 2: `spawn_mobs && spawn_monsters`), and only when a
local boolean is true that is stored directly from the `GameRules.SPAWN_MOBS` read of the same method, so it is exactly the `spawn_mobs` value. Every spawner of the list is ticked in the order above, each with its own counters (`nextTick`
fields), so the spawners run in lockstep with the server tick and not with the 400-tick friendly cycle. The cat
spawner and the siege spawner do not read the game rules themselves.

Re-read checks against the earlier documents (all agree): phantom `nextTick += (60 + nextInt(60)) * 20`, sky-darken
below 5 with skylight returns, `nextInt(clamp(timeSinceRest, 1, max)) >= 72000`, position `up 20 + nextInt(15)`,
`east -10 + nextInt(21)`, `south -10 + nextInt(21)`, count `1 + nextInt(difficultyId + 1)`; patrol `nextTick += 12000 +
nextInt(1200)`, bright outside, `nextInt(5) == 0`, offsets `(24 + nextInt(24))` with a random sign, `ceil(effective
difficulty) + 1` members with the leader spawned first and the rest after `x += nextInt(5) - nextInt(5)`; trader
`tickDelay` 1200, spawn delay 24000, chance 25 to 75 in steps of 25. Two details of the patrol and trader spawners that
the earlier documents do not state:

- Patrol member placement: `PatrollingMonster.checkPatrollingMonsterSpawnRules` fails when the block light at the
  position is above 8, otherwise it is the any-light monster rule (18 §6.8). A patrol member created with the
  reason `PATROL` is given a random patrol target 500 blocks around (`x` and `z` offset `nextInt(1000) - 500`, y offset
  0) only for the leader (`findPatrolTarget`); `finalizeSpawn` makes any pillager that is not `PATROL`, `EVENT` or
  `STRUCTURE` a leader with probability 0.06 (`nextFloat < 0.06`), gives a leader the ominous banner in the head slot
  with drop chance 2.0 and sets `patrolling` for the reason `PATROL`.
- Trader: the chance test is `nextInt(100) <= chance` using the chance value before it is raised by 25 (the stored
  chance is first set to `clamp(chance + 25, 25, 75)`), the spawner uses its own unseeded `RandomSource`, the wandering
  trader is spawned with the reason `EVENT` and the two trader llamas with `EVENT` through `EntityType.spawn`, the
  trader gets despawn delay 48000, wander target the chosen position and home (radius 16); the biome tag
  `without_wandering_trader_spawns` is `the_void`.

## 7. Picking from a spawn list

### 7.1 `WeightedList`

A weighted list stores its entries as given (a list of value and integer weight) and never merges equal values. Its
total is the sum of the weights. `getRandom(rs)`: an empty list (total 0) returns nothing and consumes no random
number; otherwise it draws **one** `nextInt(total)` and returns the first entry (in list order) whose cumulative
weight exceeds the roll (the walk subtracts each weight from the roll and stops when the result is negative). Lists
with a total below 64 are held as a flat table (index to value), larger ones as an array walked in order; both give
the same result. `contains(value)` is true when any entry's value is equal to the argument (`equals`; a
`SpawnerData` is equal when entity type and count provider are equal).

### 7.2 Duplicate biome entries (19 Open question 6)

Duplicate entries are two list items, so their weights add: the chance of the duplicated mob is `(w1 + w2) / total`.
The complete set of duplicate entries in the 67 biomes is five: the `creature` chicken twice in `jungle`, `bamboo_jungle` and `sparse_jungle` (weight 10, count 4 each, effective weight 20), and the `monster` slime twice in `swamp` and `mangrove_swamp` (first copy weight 100, count 4; second copy weight 1, count 1; effective weight 101). The slime copies are not identical: the count of the pack comes from the entry the roll chose (18 §6.5 step 3), so a slime pack has a maximum of 4 with probability 100/101 and 1 with probability 1/101 in those two biomes (given the slime is the entry chosen), and the membership test still passes for either copy. The pack-entry membership test of 18 §6.5 step 4 (`canSpawnMobAt`) uses `contains`, so a
mob drawn from either copy passes. The count of the second copy is also read from the entry chosen by the roll (18
§6.5 step 3 replaces `maxPack` with a sample of the chosen entry's count); the identical chicken duplicates make the choice
irrelevant. Worked example in 14.4.

### 7.3 The biome attribute and the `overlay` modifier (21 Open question 2)

`natural_mob_spawns` is an environment attribute of type "mob spawn settings" (`MobSpawnSettings`: a map category to
weighted `SpawnerData` list, plus a map of spawn costs). All 67 biome files carry it, every one with the modifier
`overlay`; no dimension type, timeline or other data file in the jar sets it. `MobSpawnSettings.EMPTY` (no category
defined, no costs) is the base. A category that the settings list explicitly but with no entries (as in the deep
dark biome, shown in 18 appendix A as empty lists) is "defined and empty"; a category that is not mentioned is "not
defined". `getMobsToSpawn(category)` returns the list or the empty list; `getMobsInCategory` returns null when not
defined.

`overlay(base, top)` (the layered value is `top` laid over `base`; `top` is the later layer):

1. if `base` defines no category and has no costs: the result is `top`;
2. else if `top` defines no category and has no costs: the result is `base`;
3. else if `top` defines every category and every cost key that `base` defines: the result is `top`;
4. otherwise build a new settings object: for each of the 8 mob categories (all `MobCategory` values in table order),
   the list of `top` when `top` defines the category, else the list of `base` when it defines it (a **replacement per
   category, never a merge of lists**); the costs map is `base`'s costs with `top`'s costs put over them (a cost for
   the same entity type from `top` wins).

In this jar there is one layer that carries the attribute at a position (the biome at the position), over the empty
base, so rule 1 gives exactly the biome's own data; the combination rules matter only for packs that add a second
layer (a data pack dimension type or a modded timeline). The attribute is read at the position of each use:
`getMobsAt` (8.1) for the list and `SpawnState.canSpawn` and `afterSpawn` for spawn costs (18 §6.7: the cost
and the charge are taken from the attribute value at the mob's block position, not from a stored biome object; the
numbers are the same).

## 8. Structure `spawn_overrides` and `mobsAt`

### 8.1 The lookup (`NaturalSpawner.mobsAt` and `ChunkGenerator.getMobsAt`)

For a candidate position `P` and a category `C` (the category of the list being drawn from, 18 §6.5):

1. **Fortress rule** (`isInNetherFortressBounds`): if `C` is `MONSTER`, the block below `P` is nether bricks, and the
   fortress structure (`BuiltinStructures.FORTRESS`) has a valid start whose **whole bounding box** contains `P`
   (`StructureManager.getStructureAt`), the list is the fixed fortress list `FORTRESS_ENEMIES` and nothing else is
   consulted. Its entries are the same five entries and weights as the fortress structure's data override (8.4:
   blaze 10 with count 2 to 3, zombified piglin 5 with count 4, wither skeleton 8 with count 5, skeleton 2 with count
   5, magma cube 3 with count 4).
2. Otherwise `ChunkGenerator.getMobsAt(level, structureManager, C, P)`:
   a. `getAllStructuresAt(P)`: the structure references stored in the chunk of `P` (the map from structure to the set
      of chunk positions of its starts that reach this chunk; status `STRUCTURE_REFERENCES`);
   b. for each entry in that map's iteration order: read the structure's `spawn_overrides` entry for `C`; skip the
      structure if it has none; otherwise load each referenced start (`STRUCTURE_STARTS` status; only valid starts
      count) and test it: with `bounding_box` = `piece`, the start qualifies when **any of its pieces' bounding boxes**
      contains the block position (`structureHasPieceAt`, inclusive box test); with `bounding_box` = `full`, when the
      **start's overall bounding box** contains it (`BoundingBox.isInside`). The first qualifying structure in the
      iteration returns **that override's spawn list** as the result; the biome list is **replaced**, not added to;
   c. if no structure qualifies, the result is `getMobsToSpawn(C)` of the `natural_mob_spawns` value at `P` (7.3).
3. The caller (`getRandomSpawnMobAt`) first applies, for `C = WATER_AMBIENT` in a biome in the tag
   `reduce_water_ambient_spawns` (contents: `#minecraft:is_river`; read next to `without_wandering_trader_spawns` = `the_void`, §6, and `without_zombie_sieges` = `mushroom_fields`, §13), a 0.98 chance of returning nothing (`nextFloat < 0.98`), then draws one entry
   from the list (7.1). `canSpawnMobAt` is `contains` on the same list.

An override whose spawn list is **empty** (8.3) therefore removes all natural spawns of that category inside the
qualifying box: the list is empty, the draw returns nothing and the pack ends (18 §6.5 step 3).

### 8.2 Semantics of the two box types

| Type | Test | Effect |
|---|---|---|
| `piece` | the position lies inside at least one piece's box | only the built parts count: rooms, corridors, houses; gaps and the surroundings inside the overall box do not |
| `full` | the position lies inside the structure start's single overall box | the whole axis-aligned region counts, including air around the structure |

Both tests are inclusive (`BoundingBox.isInside`). The start's overall box is the union of its pieces' boxes
(`StructureStart.getBoundingBox`), so `full` is never smaller than `piece`.

### 8.3 All 52 structures

Read from `data/minecraft/worldgen/structure/*.json` (52 files; every file contains the key `spawn_overrides`; 46 have the empty object `{}`, namely the 18 `abandoned_camp_*` variants and 28 others, and six structures carry a non-empty override: fortress, monument, pillager_outpost, swamp_hut, ancient_city and trial_chambers). A
structure not listed has an empty `spawn_overrides` and does not alter any list. The table has 8 rows because monument and swamp_hut appear twice (two categories each). Entries are `type, weight, count`.

| Structure | Category | Box | Result inside the box |
|---|---|---|---|
| `fortress` | `monster` | piece | blaze 10 (count 2 to 3), zombified piglin 5 (4), wither skeleton 8 (5), skeleton 2 (5), magma cube 3 (4) |
| `monument` | `monster` | full | guardian 1 (count 2 to 4) |
| `monument` | `axolotls`, `underground_water_creature` | full | empty (no spawns) |
| `pillager_outpost` | `monster` | full | pillager 1 (count 1) |
| `swamp_hut` | `monster` | piece | witch 1 (count 1) |
| `swamp_hut` | `creature` | piece | cat 1 (count 1) |
| `ancient_city` | all eight categories (`ambient`, `axolotls`, `creature`, `misc`, `monster`, `underground_water_creature`, `water_ambient`, `water_creature`) | full | empty: no natural spawns at all inside the overall box |
| `trial_chambers` | the same eight categories | piece | empty: no natural spawns inside any built piece |

Every other structure (the temples, the villages, the mineshafts, the stronghold, the bastion remnant, the end city,
the ruined portals, the shipwrecks, the ocean ruins, the igloo, the mansion, the trail ruins, the nether fossil,
buried treasure and the five village types) has an empty override. The mansion and the bastion in particular rely only on
spawns placed by pieces (§10), not on lists.

Notes: the swamp hut's creature entry is a cat, but the cat's placement predicate (`Animal.checkAnimalSpawnRules`,
18 §6.8) requires grass below, and the hut floor is a box of spruce planks at local y 1 (read in
`SwampHutPiece.postProcess`: x 1 to 5, z 1 to 7), which is not grass. So the list does not produce a cat on the floor.
The hut also places its own witch and its own cat at generation, which do not use any override (10.7), and the cat
spawner (44-3 §1.6, hut case) is the source of later cats.

### 8.4 Fortress: the hardcoded list and the data override compared (21 Open questions 3 and 22)

The two sources hold the same list. They differ in where they apply: the hardcoded rule applies on nether bricks
anywhere in the fortress's **whole** box; the data override (`piece`) applies on any block of a **piece** box. Where
neither matches, the biome list applies (the Nether biomes' own tables in 18 appendix A: for example nether wastes
and crimson forest). Hoglin and zoglin weights in structures: neither the fortress nor any other structure lists
hoglins or zoglins in `spawn_overrides`; the bastion remnant has no override; the only preplaced hoglin is the one
entity of the template `bastion/mobs/hoglin` (10.5).

## 9. The ocelot in the monster list (19 Open questions 5 and 35)

Exactly two biome tables list the ocelot under `monster`: `jungle` (weight 2, count uniform 1 to 3) and `bamboo_jungle` (weight 2, count 1). `sparse_jungle` has no ocelot in `monster`; all other ocelot entries in the 67 biome files are in `creature` (all 67 files were parsed; 18 appendix A shows `ocelot:w2:n1` and `ocelot:w2:n1-3`). Whether that is intended cannot be decided from the artifact (the data is as it
is). What the engine does with it, read from `NaturalSpawner`:

- The **list** a pack is drawn from is chosen by the category being processed in the cycle: the ocelot is a candidate
  only in the `MONSTER` pass, which runs every tick (not every 400 ticks) and is gated by the monster cap and by
  `spawn_monsters`.
- Everything that uses the **entity type's own category** (`EntityType.getCategory`, `creature` for the ocelot, 19
  §5.2) ignores the list category: `isValidSpawnPostitionForType` rejects only a type whose own category is
  `MISC`; the despawn-distance test (when the type cannot spawn far from the player) uses the type category's despawn
  distance (128); and `afterSpawn` increments the counters of the type's category. So a monster-pass ocelot is counted
  as a `creature` (global and local `creature` caps, 10 per player in the standard setup) and never raises the
  `monster` count.
- The placement is the type's own registration (`Ocelot.checkOcelotSpawnRules`, 19 §5.2: placement ON_GROUND,
  heightmap `MOTION_BLOCKING`, and a predicate that is only `nextInt(3) != 0`). The registered predicate has no light
  test and no `isValidSpawn` floor test, so a monster-list ocelot does not need darkness. The block rule is not in the
  registration: it lives in `Ocelot.checkSpawnObstruction`, which natural spawning step 7 (18 §6.5) and spawners call.
  It requires: the box unobstructed, no liquid in the box, the feet y at or above the sea level, and the block below
  either `grass_block` or in the `leaves` block tag. A monster-pass ocelot can therefore stand on leaves.
- Persistence and despawn are the ocelot's own (Animal-based, 19 §5.2).

Consequence: ocelots appear at monster-pass frequency, in daylight and darkness, without competing with the monster
cap, and compete with other creatures for the creature cap. An implementer who wants the standard behaviour treats
this as the specified behaviour; moving the ocelot to the `creature` list would change the pass, the frequency and the
cap used.

## 10. Mobs placed by structure pieces and templates

These spawns happen once, when the piece or template is placed during generation (reason `STRUCTURE`, or a spawner
block that later spawns with `SPAWNER`); they do not use the spawn lists of §8. Piece geometry is in the
structure documents. The sections are: 10.1 to 10.4 spawner blocks and the mansion markers, 10.5 template entities, 10.6
trial chambers, 10.7 the swamp hut, 10.8 the ocean monument, 10.9 the end city and ocean ruin markers, 10.10 the dungeon
spawner, 10.11 the end spike crystals.

### 10.1 Mineshaft cave-spider spawner (`MineShaftCorridor`, 20 Open question 12)

- At corridor creation: `hasRails = nextInt(3) == 0`; `spiderCorridor = !hasRails && nextInt(23) == 0` (the second
  draw happens only when `hasRails` is false); `hasPlacedSpider` starts false; `numSections` is the corridor's
  length span divided by 5 (integer division).
- While the corridor is post-processed (per chunk, it can run in several chunk passes): for each section index `i`
  from 0 to `numSections - 1` with section base `z0 = 2 + 5 * i`, and only when `spiderCorridor` and not
  `hasPlacedSpider`: `z = z0 - 1 + nextInt(3)` (so `5i + 1` to `5i + 3`); the local position is `(x 1, y 0, z)`. If its
  world position lies inside the bounding box currently being generated and the position is an interior block of the
  corridor (`isInterior`), set `hasPlacedSpider`, place the `spawner` block (flag 2) and, if the block entity is a
  spawner, `setEntityId(cave_spider)`. If the position is outside the current chunk's box nothing is placed and the
  flag stays false, so a later chunk pass can place it; at most one spawner per corridor.
- The spawner is created in code, so it has all defaults of 2.1 (delay 20, 200 to 799, count 4, max nearby 6, range 16 for the player, spawn
  range 4) and the spawn data `{ id: cave_spider }` only: it uses `SpawnPlacements.checkSpawnRules(cave_spider,
  SPAWNER)` (the monster light rule applies, 18 §6.8) and the mob's own `checkSpawnRules`, and is finalised
  because the tag is only an `id`.
- Cobwebs are not limited to spider corridors. Only the filled cobweb box (probability 0.6) is inside the
  `spiderCorridor` branch. In the per-section loop of every corridor, post-processing makes four `maybePlaceCobWeb`
  attempts at probability 0.1 and four at 0.05 (each needs an interior block, a sturdy neighbour and a `nextFloat` below
  the probability), places the supports, then makes two `nextInt(100) == 0` chest checks (loot table
  `abandoned_mineshaft`). The geometry and the rest belong to the mineshaft document.

### 10.2 Nether fortress blaze spawner (`NetherFortressPieces$MonsterThrone`, 21 Open question 3)

The fortress throne room piece has a flag `hasPlacedSpawner`. During post-processing, if the flag is false and the
world position of local `(3, 5, 5)` lies inside the generating bounding box: set the flag, place the `spawner` block
(flag 2) and `setEntityId(blaze)`. Created in code with the defaults of 2.1 and the same spawn rule as 10.1 (blaze uses `checkAnyLightMonsterSpawnRules`,
18 §6.8, so light does not matter). Other fortress pieces carry no spawners; the fortress's natural mobs are
§8.1 and 8.4. In the Nether the spawner needs a player within 16 blocks and the entity box free.

### 10.3 Stronghold silverfish spawner (`StrongholdPieces$PortalRoom`)

The portal room has `hasPlacedSpawner`. After the room is built, if the flag is false and the world position of local
`(5, 3, 6)` lies inside the generating box: set the flag, place a `spawner` block (flag 2) and `setEntityId(silverfish)`.
(The silverfish spawner is thus placed once per portal room, created in code with the defaults of 2.1.)

### 10.4 Woodland mansion data markers (`WoodlandMansionPieces$WoodlandMansionPiece.handleDataMarker`, 20 Open question 12)

The mansion templates contain structure blocks in data mode whose metadata is a marker name. Handling per marker:

| Marker | Effect |
|---|---|
| `ChestWest`, `ChestEast`, `ChestSouth`, `ChestNorth` (any name starting with `Chest`) | a chest facing the named direction rotated by the piece's rotation, with the loot table `chests/woodland_mansion` |
| `Mage` | one `evoker` |
| `Warrior` | one `vindicator` |
| `Group of Allays` | `1 + nextInt(3)` allays, drawn from the level accessor's own `getRandom()`, not from the `RandomSource` parameter the handler receives |

For each created mob: `setPersistenceRequired`, `snapTo(marker block, yaw 0, pitch 0)`, `finalizeSpawn(difficulty at
its block, STRUCTURE, no group data)`, `addFreshEntityWithPassengers`; then, for the three mob markers only (`Mage`, `Warrior`, `Group of Allays`), the marker block is replaced by air
(flag 2); the `Chest` markers do not do this. Counts of markers in the templates (for sizing, per template family): `woodland_mansion` has 20
`Warrior`, 4 `Mage`, 4 `Group of Allays` and 10 chest markers (`ChestSouth` 5, `ChestWest` 3, `ChestNorth` 2; no template holds a `ChestEast`, which exists only in the code's name list) across all room templates (which rooms are used is the
mansion layout's, RS20). One room template, `1x1_as2`, contains a spawner block whose stored NBT is not the code defaults of 2.1: `Delay` 0 (not 20, so the first round runs on the first tick a player is in range), `MinSpawnDelay` 200, `MaxSpawnDelay` 800, `SpawnCount` 4, `MaxNearbyEntities` 6, `RequiredPlayerRange` 16, `SpawnRange` 4, `SpawnData` = entity `{ id: spider }` and one `SpawnPotentials` entry of weight 1 with the same entity (it uses `checkSpawnRules(spider, SPAWNER)`). The mansion structure itself has no
`spawn_overrides`, so evokers and vindicators do not respawn naturally.

### 10.5 Template entities (bastion, villages, igloo, pillager outpost) and the jigsaw settings

A `SinglePoolElement` places its template with settings: entities not ignored (`ignoreEntities` false), **finalize
entities** true, known shape true and a block-ignore processor for structure blocks. `StructureTemplate.placeEntities`
(read): for each stored entity, transform its block position and its position (mirror, rotation, pivot, offset), skip it
when a bounding box is given and the transformed block is outside it (so an entity is created only by the chunk pass
whose box contains it), copy its tag, replace `Pos`, remove `UUID`, create it with the reason `STRUCTURE`, rotate and
mirror its yaw, set body and head rotation to that yaw, and, when finalising is on and the entity is a `Mob`, call
`finalizeSpawn(difficulty at its block, STRUCTURE, no group data)`; then `addFreshEntityWithPassengers`. When the stored
tag contains the key `block_pos` (hanging entities such as item frames), the transformed block position is stored back
under that key as well. The same `SinglePoolElement` settings also set the liquid settings (the element's own, with a
default when absent) and add the processors of the element's processor list followed by the processors of the pool's
projection (`rigid` has none for entities); these do not change spawn semantics. The stored tags
carry the persistence flag, so the template decides whether the mob can despawn.

Entities stored in the templates of this jar (read from the structure NBT; counts are entities across all templates of
the family, not per structure):

| Family | Entity (count, `PersistenceRequired`) |
|---|---|
| `bastion/mobs` | `piglin` 2 (persistent, picks up loot), `piglin_brute` 2 (persistent, picks up loot), `hoglin` 1 (persistent, does not pick up loot). The folder holds 6 template files (counted with `unzip -Z1 | grep -v '/$'`): `crossbow_piglin`, `sword_piglin`, `melee_piglin`, `melee_piglin_always`, `hoglin` and `empty` (no mob); each mob template is a single-mob piece placed through the three pools below. `melee_piglin` and `melee_piglin_always` store a `piglin_brute`, as counted in this row. The bastion `treasure/bases/lava_basin` template holds one `spawner` block (a magma cube spawner whose stored NBT has the same values as the mansion spider spawner above: `Delay` 0, 200, 800, 4, 6, 16, 4, entity `{ id: magma_cube }`, one potential of weight 1) |
| `village` | `villager` 15 (the `baby`, `nitwit` and `unemployed` templates; `PersistenceRequired` 0, `CanPickUpLoot` 1; the `VillagerData` type is the biome type, profession `none` or `nitwit`, level 1), `zombie_villager` 10 (persistent), `cat` 10 (ten coat templates, persistent), `horse` 7 (untamed, persistent, fixed `Variant` per template), `sheep` 4, `cow` 2, `pig` 2 (all persistent), `iron_golem` 1 (persistent), `camel` 1 (the `desert/camel_spawn` template, no flags), `armor_stand` 2 (taiga armorer) |
| `igloo` | `villager` 1 (cleric, plains, persistent) and `zombie_villager` 1 (cleric, plains, persistent) in `bottom` |
| `pillager_outpost` | `iron_golem` 1 (not persistent; `feature_cage1`), `allay` 2 (persistent; `feature_cage_with_allays`) |
| `abandoned_camp` | 224 `cushion` entities (decorative; not mobs) |

Nothing else in the jar's structure templates stores a mob: no hoglin or zoglin outside the one bastion hoglin
template, and the fortress, stronghold, mineshaft and end city store none. The underwater ruin templates carry 51
`drowned` data markers and 47 `chest` markers, and the end city 13 `Sentry` (shulker), 5 `Chest` and 1 `Elytra` markers;
the marker handling is in 10.9.

The three pools (`template_pool/bastion/mobs/*`; every element is a `single_pool_element` with empty processors,
projection `rigid`, and the pool fallback is `minecraft:empty`):

| Pool | Elements (weight) |
|---|---|
| `bastion/mobs/piglin` | `melee_piglin` 1, `sword_piglin` 4, `crossbow_piglin` 4, `mobs/empty` 1 |
| `bastion/mobs/piglin_melee` | `melee_piglin_always` 1, `melee_piglin` 5, `sword_piglin` 1 |
| `bastion/mobs/hoglin` | `hoglin` 2, `mobs/empty` 1 |

Which structures reference these pools: the references are `jigsaw` block entities in the bastion structure NBT, with the pool name in the block entity key `pool` (counted as occurrences of the pool name string in every file under `structure/bastion/**`):

| Pool | References | By family (`bridge`, `hoglin_stable`, `treasure`, `units`) |
|---|---|---|
| `bastion/mobs/piglin` | 98 | 29, 27, 22, 20 |
| `bastion/mobs/piglin_melee` | 34 | 4, 6, 18, 6 |
| `bastion/mobs/hoglin` | 12 | 2 (the entrance piece), 10, 0, 0 |

The `blocks` family references none. The placement odds follow from the pool weights above (inferred arithmetic): in the `piglin` pool a brute is 1/10 (via `melee_piglin`, which stores a `piglin_brute`), a sword or crossbow piglin 8/10 and no mob 1/10; in the `piglin_melee` pool a brute is 6/7 (`melee_piglin_always` 1 plus `melee_piglin` 5) and a sword piglin 1/7; in the `hoglin` pool a hoglin is 2/3 and no mob 1/3. So the `piglin` pool can also produce brutes.

Zombified piglins, piglins and hoglins are therefore present in a bastion only through these template mobs and the
spawn lists of the biome (18 appendix A: crimson forest and nether wastes), because the bastion has no override.

### 10.6 Trial chambers

The trial chambers structure has `spawn_overrides` that empty every category inside its pieces (8.3). Its mobs come
from the 14 trial spawner blocks in the templates (§4) and from other pieces' vault and chest blocks; the
templates store the config keys as strings.

### 10.7 Swamp hut witch and cat (`SwampHutPiece.postProcess`, closed)

The piece has two flags, `spawnedWitch` and `spawnedCat`, both false at creation. During post-processing, after the
blocks are placed:

1. If `spawnedWitch` is false and the world position of local `(2, 2, 5)` lies inside the generating box: set the flag and
   create one `witch` (reason `STRUCTURE`), `setPersistenceRequired`, `snapTo(x + 0.5, y, z + 0.5, yaw 0.0, pitch 0.0)` of that block position (order: create, `setPersistenceRequired`, `snapTo`,
   `finalizeSpawn(difficulty at its block, STRUCTURE, no group data)`, `addFreshEntityWithPassengers`).
2. Then `spawnCat` runs on every pass, whether or not a witch was created: if `spawnedCat` is false and the same local position `(2, 2, 5)` is
   inside the box, set the flag and create one `cat` the same way (`STRUCTURE`, persistent, `snapTo` at the same centre with yaw 0.0 and pitch 0.0, finalised, added with
   passengers).

So a hut gets one persistent witch and one persistent cat at generation; the `spawn_overrides` of 8.3 (witch weight 1 and
cat weight 1 on the hut's piece boxes) are separate and concern later natural spawns.

### 10.8 Ocean monument elder guardians (`OceanMonumentPiece.spawnElder`)

`spawnElder(box, x, y, z)` takes a local position. If its world position is inside the generating box: create an
`elder_guardian` (reason `STRUCTURE`), heal it by its maximum health, `snapTo` `(world x + 0.5, world y, world z + 0.5)` with
yaw 0 and pitch 0, `finalizeSpawn(difficulty at its block, STRUCTURE, no group data)` and `addFreshEntityWithPassengers`. No
`setPersistenceRequired` call is made in this method. Callers: the penthouse at local `(6, 1, 6)`; each wing room at local
`(11, 2, 16)` when its `mainDesign` is 0 and at local `(11, 5, 13)` when `mainDesign` is 1 (other designs do not call it).
There is no per-piece placed flag: the call is made on each post-processing pass whose box contains the position, so a
chunk pass that does not contain the position creates nothing and one that contains it creates one (the position is a
single block, so one pass). `MonumentBuilding` creates exactly two wing rooms, with consecutive seeds `r` and `r + 1` from one `nextInt()` draw,
and the wing room constructor sets `mainDesign = seed & 1`, so one wing room has design 0 and the other design 1; both
designs call `spawnElder`. Every monument therefore gets exactly 3 elder guardians (penthouse, design 0, design 1),
provided each of the three positions falls inside a generating box.

### 10.9 End city and ocean ruin data markers

`EndCityPieces$EndCityPiece.handleDataMarker(marker, pos, ...)` (13 `Sentry`, 5 `Chest` and 1 `Elytra` markers in the
templates):

| Marker (prefix test) | Effect |
|---|---|
| `Chest...` | if the block position below the marker is inside the generating box, set the loot table `END_CITY_TREASURE` (`chests/end_city_treasure`) on the block entity there (random source of the generation); this test comes first and uses the block below the marker |
| `Sentry...` | if the marker position is inside the box and inside the spawnable world bounds: create one `shulker` (reason `STRUCTURE`), `setPos(x + 0.5, y, z + 0.5)` and `addFreshEntity` (no `finalizeSpawn` and no persistence call are made) |
| `Elytra...` | under the same position tests: create an `ItemFrame` constructed at the marker position, facing the piece's rotation applied to south, holding one elytra (`setItem(stack, false)`), added with `addFreshEntity` |

`OceanRuinPieces$OceanRuinPiece.handleDataMarker` (51 `drowned` and 47 `chest` markers): `chest` places a chest at the
marker position with `waterlogged` set to whether the fluid there is water, flag 2, and sets the loot table
`UNDERWATER_RUIN_BIG` when the piece's `isLarge` flag is set and `UNDERWATER_RUIN_SMALL` otherwise, with a seed from
`nextLong` of the generation random source (resource paths `chests/underwater_ruin_big` and `chests/underwater_ruin_small`; the three loot files, with `chests/end_city_treasure`, exist in the jar);
`drowned` creates one `drowned` (reason `STRUCTURE`), `setPersistenceRequired`, `snapTo` the marker block with yaw 0 and
pitch 0, `finalizeSpawn(difficulty, STRUCTURE, no group data)`, `addFreshEntityWithPassengers`, and then replaces the marker
block with air when its y is above the sea level and with water otherwise (flag 2). `EndCityPiece.handleDataMarker` contains no `setBlock` or `removeBlock` call, so it never replaces the marker block (the marker blocks are not placed in the first place when the template's structure-block ignore setting of 10.5 filters them; that part is inferred). `Sentry` and `Elytra` are both gated by (marker position inside the generating box) and `Level.isInSpawnableBounds`.

### 10.10 Dungeon spawner (`MonsterRoomFeature`, closed)

The room's spawner block takes its mob from `randomEntityId`: one `nextInt(4)` draw (`Util.getRandom` on a 4-entry
array) indexing, in this order, `skeleton`, `zombie`, `zombie`, `spider`. Zombie therefore has probability 1/2, skeleton
and spider 1/4 each. The result goes to `SpawnerBlockEntity.setEntityId(type, random)` with the defaults of 2.1. The chest and
room geometry draws are the feature round's.

### 10.11 End spike crystals

`EndSpikeFeature.placeSpike` creates its end crystals with reason `STRUCTURE` (the geometry and the feature's draws are the feature round's).

## 11. Spawn tags

All are block tags of the jar (`data/minecraft/tags/block/`); the tag engine is 04. `#name` is a tag reference.

| Tag | Values (read) | Used for |
|---|---|---|
| `axolotls_spawnable_on` | `clay` | `Axolotl.checkAxolotlSpawnRules`: the block below must be in the tag (together with the water and light rules in 21) |
| `animals_spawnable_on` | `grass_block` | `Animal.checkAnimalSpawnRules` (18 §6.8) |
| `valid_spawn` | `grass_block`, `podzol` | **no consumer**: the only classes that reference `BlockTags.VALID_SPAWN` are `BlockTags` itself and the data generator `VanillaBlockTagsProvider`; no gameplay class reads it, so it is dead data in this jar |
| `armadillo_spawnable_on` | `#animals_spawnable_on`, `#badlands_terracotta`, `red_sand`, `coarse_dirt` | armadillo placement |
| `bats_spawnable_on` | `#base_stone_overworld` | bat placement |
| `camels_spawnable_on` | `#sand` | camel placement |
| `foxes_spawnable_on` | `grass_block`, `snow`, `snow_block`, `podzol`, `coarse_dirt` | fox placement |
| `frogs_spawnable_on` | `grass_block`, `mud`, `mangrove_roots`, `muddy_mangrove_roots` | frog placement |
| `goats_spawnable_on` | `#animals_spawnable_on`, `stone`, `snow`, `snow_block`, `packed_ice`, `gravel` | goat placement |
| `mooshrooms_spawnable_on` | `mycelium` | mooshroom placement |
| `parrots_spawnable_on` | `grass_block`, `air`, `#leaves`, `#logs` | parrot placement |
| `polar_bears_spawnable_on_alternate` | `ice` | polar bear placement (alternative floor) |
| `rabbits_spawnable_on` | `grass_block`, `snow`, `snow_block`, `sand` | rabbit placement |
| `wolves_spawnable_on` | `grass_block`, `snow`, `snow_block`, `coarse_dirt`, `podzol` | wolf placement |
| `invalid_spawn_inside` | `end_portal`, `end_gateway` | read only by `DismountHelper.findSafeDismountLocation`, and only when the dismounting entity type is the player: a candidate dismount position is rejected when the block at the position, or the block above it, is in the tag. It is not a mob spawn rule |
| `supports_frogspawn` | empty (no values in this jar's data) | has consumers: `FrogspawnBlock` and `TryLaySpawnOnFluidNearLand` read it, so a datapack could fill it; with empty data nothing qualifies |
| `prevent_mob_spawning_inside` | `#rails` | read by `NaturalSpawner` (the spawn-position test rejects a position whose block is in the tag) |

The per-mob tags are named here so an implementer has the contents; which predicate reads which tag is owned by the
animal documents (19) and was confirmed here only for the axolotl and the animal rule.

**What decides the generic floor test.** `Mob.checkMobSpawnRules` returns true at once when the spawn reason is a
spawner reason (`EntitySpawnReason.isSpawner`, 2.5). Otherwise it calls `BlockState.isValidSpawn(level, pos below,
type)`, which uses the per-block predicate set through `BlockBehaviour.Properties.isValidSpawn`. The default predicate
is: the top face of the block below is sturdy and its light emission is below 14. The `Blocks` class has 35 call sites of
`Properties.isValidSpawn`; some sit inside shared helpers (the leaves property helper and the shulker box lambdas), so
more than 35 blocks are affected. The 35 sites use six predicates: `never` at 24 sites, `always` at 5, `ocelotOrParrot` at 3, and three one-off lambdas. By name adjacency in the class (a read-order attribution, **(inferred)**: the block names were not read from each call site) the one-off lambdas belong to ice, frosted ice and magma block, and the `always` sites to soul sand, carved pumpkin, jack o'lantern, redstone lamp and mud. The tag `valid_spawn` plays no part, and the villager,
wandering trader, iron golem and snow golem do not use it.

## 12. Spawn predicates owned elsewhere

| Predicate | Owner | Summary (for the cross-check only) |
|---|---|---|
| `Animal.checkAnimalSpawnRules` | 19 §1.4 (the `checkAnimalSpawnRules` row) and 18 §6.8 | block below in `animals_spawnable_on` and light above 8 unless the reason ignores light |
| `Turtle.checkTurtleSpawnRules` | 19 §1.4 (the rule) and the turtle section of 19 (beach, weight 5, group 2 to 5) | owned by 19; 21 Open question 6 is answered by that reference |
| `Slime.checkSlimeSpawnRules` | 20 §10 (slime) and 20 §3.4 | surface alternative (swamp tag, `50 < y < 70`, moon-scaled chance) or the slime-chunk alternative, spawner reasons go to the standable-block test |
| `Ocelot.checkOcelotSpawnRules` | 19 §5.2 | passes with probability 2/3, then ground rules |

No predicate in this table was re-derived in this round; they are cited so that 21 Open question 6 can be closed by
reference.

## 13. Villages: the spawn rules that depend on the village test

The village mechanics (POI types, tickets, the section distance field, bells, raids, villager behaviours) are
specified in 44-3 §§1 to 10 and in 20 §14; the villager-side golem spawn is 19 §22.10. This
section collects, for the planner, every spawn rule in this part that depends on `isVillage` or `isCloseToVillage`,
and adds what was read here.

| Rule | Test | Where |
|---|---|---|
| Pillager patrol | the chosen player must **not** be `isCloseToVillage(pos, 2)` (two sections of the nearest village centre, Chebyshev) | 20 §14.1 |
| Zombie siege | the player must be in `isVillage` (one section), the biome must not be in `without_zombie_sieges` (`mushroom_fields`), roll at the overworld clock marker `roll_village_siege` (tick 18000), 1 in 10; 20 zombies from a ring 32 blocks out | 44-3 §1.7 |
| Cat spawner | village case `isCloseToVillage(pos, 2)`; more than 4 occupied `home` POIs within 48; fewer than 5 cats in the (48, 8, 48) box | 44-3 §1.6 |
| Wandering trader | the spawn reference position is the nearest `meeting` POI within 48 of a random player (any occupancy), else the player; no village test | 19 §23 |
| Villager golem | villagers that slept within 24000 ticks and have no recent golem sensor memory; placement search with the legacy strategy (below) | 19 §22.10 |
| Raid centre validity | `isVillage` at the centre, search radius 2 sections | 20 §14.2 |

Added detail for the golem placement strategy (`SpawnUtil.trySpawnMob(iron_golem, MOB_SUMMONED, level, villagerPos,
attempts 10, horizontal 8, vertical 6, LEGACY_IRON_GOLEM, collision check false)`, read): each attempt picks `dx` and
`dz` uniformly in `[-8, 8]`, forms the start `(x + dx, y + 6, z + dz)`, requires it inside the world border, then scans
downward from that start for up to 13 steps (vertical range from +6 to -6): at each step the candidate floor block is
the block just below the cursor and the "above" block is the one the cursor came from; the strategy accepts when the
above block is air or a liquid and the floor block is solid (`isSolid`) or powder snow, and the floor block is **not**
one of cobweb, cactus, glass pane, any stained glass pane, any stained glass block, any leaves block, conduit, ice,
TNT, glowstone, beacon, sea lantern, frosted ice, tinted glass or glass. On acceptance the spawn position is the
above block's position. The mob is created at the block centre with a random yaw, must pass its own
`checkSpawnRules(MOB_SUMMONED)` and `checkSpawnObstruction` (the iron golem's: the block below can hold it, the
two blocks above the position are valid empty spawn blocks, the position itself is empty and unobstructed), else it
is discarded and the next attempt runs; the first accepted attempt adds it with passengers and plays its ambient sound.
The `golem_detected_recently` sensor value is 599 ticks (`GolemSensor`, scan rate 200), matching 19 §22.10.

Village templates place **villagers and animals directly** as template entities (10.5): the `baby`, `nitwit` and
`unemployed` villager templates (not persistent, so they can despawn like any mob far from players unless a rule makes
them persistent), zombie villagers, cats, horses, cows, sheep, pigs, an iron golem and one camel. No spawn list or
custom spawner places villagers; villager breeding and conversion are in 19.

## 14. Worked examples

### 14.1 Spawner delay and rounds

A mob spawner with defaults, entity `zombie`, a player standing 5 blocks away. Fresh spawner: `spawnDelay = 20`.
Ticks 1 to 20 each decrement (20 to 0); tick 21 runs the round. The round makes 4 attempts; suppose 3 succeed (one box
blocked). Then `delay`: `minSpawnDelay + nextInt(600)`; with `nextInt(600) = 123` the delay is 323 and the next round
runs on tick 21 + 324 = 345 (323 decrement ticks, then the round tick), provided a player is within 16 blocks the
whole time (the counter pauses otherwise). If the round had found 6 or more zombies in the count box (the box from the block corner to the corner plus 1, inflated by
`spawnRange` 4, so the continuous range `[bx - 4, bx + 5]` on x and z and `[by - 4, by + 5]` on y: 9 units long on each axis
and covering 9 block cells, bx - 4 to bx + 4; an entity is counted when its bounding box intersects the box), it would roll
a delay at once and stop without spawning any more of that round.

### 14.2 Trial spawner, one and three players

Default config (total 6, simultaneous 2, +2 and +1 per extra player). One player: target total 6, 2 at a time. Three
players (`extra = 2`): total `floor(6 + 2*2) = 10`, simultaneous `floor(2 + 1*2) = 4`. The `melee/zombie` normal config
(`simultaneous_mobs` 3, `simultaneous_mobs_added_per_player` 0.5, `ticks_between_spawn` 20, total from the defaults 6
and 2): one player: 6 total, 3 at once; two players (`extra = 1`): total 8, simultaneous `floor(3.5) = 3`; three
players: total 10, simultaneous `floor(3 + 0.5*2) = 4`. The `breeze` normal config (total 2 and +1, simultaneous 1
and +0.5, 20 ticks): one player 2 and 1; two players `floor(3) = 3` and `floor(1.5) = 1`.

Timeline, two players, default cooldown: at game time `T` a scan tick finds player 1 (detected set `{A}`):
`next_mob_spawns_at = max(.., T + 40)`, state becomes `active` on the same tick's return. Player B arrives and is added
at a later scan (each spawner scans once per 20 ticks), pushing `next_mob_spawns_at` to at least `now + 40` again. The
last mob dies at `T0`: `cooldown_ends_at = T0 + 36000`, state `waiting_for_reward_ejection`; at `T0 + 40` the shutter
opens (`ejecting_reward`); the first tick with `(now - T0) mod 30 == 0` after that is `T0 + 60`: roll the table (say
the key table), eject, remove player A; at `T0 + 90` eject again (the same table: the pick is kept for the run) and
remove B; at `T0 + 120` the set is empty: close shutter, `cooldown`. At `T0 + 36000` the cooldown ends, the spawner
resets to `waiting_for_players` (and loses the ominous state if it had it).

### 14.3 Ominous conversion

A player with Bad Omen amplifier 2 enters a normal spawner's range and the scan tick runs: Bad Omen is converted to
Trial Omen of duration `(2 + 1) * 18000 = 54000` ticks, the spawner becomes ominous (block property true, current
mobs discarded, `total_mobs_spawned` 0, `next_mob_spawns_at = now + ominous.ticks_between_spawn`, `cooldown_ends_at =
now + 160`), and from then on the `active` state also spawns an ominous item every 160 ticks.

### 14.4 Duplicate entries

`bamboo_jungle` creature list in order: sheep 12, pig 10, chicken 10, cow 8, chicken 10, parrot 40, panda 80 (total
170). Rolls and results: 0 to 11 sheep, 12 to 21 pig, 22 to 31 chicken, 32 to 39 cow, 40 to 49 chicken (the second
copy), 50 to 89 parrot, 90 to 169 panda. The chicken chance is 20/170 = 11.76 percent, not 10/170. A roll of 45 gives
chicken with the count of that entry (4); `contains(chicken entry)` is true.

### 14.5 `mobsAt` cases

1. Swamp hut piece box: a witch is the only entry of the `monster` list for any position in a hut piece box, so a
   zombie is not drawn there; a position in the empty space of the hut's overall box but outside every piece box uses
   the swamp biome's monster list. A `creature` pass in a hut piece offers only the cat.
2. Ocean monument: any position in the monument's overall box, for `monster`, draws only guardian (count 2 to 4); for
   `underground_water_creature` and `axolotls` the list is empty, so those passes end at once there; for
   `water_creature` and `ambient` the biome lists apply (no override for them).
3. Nether fortress at a nether-bricks floor: `FORTRESS_ENEMIES`; on a non-brick floor (for example soul sand) inside a
   piece box: the same five entries by the data override; on soul sand in an overall box but outside every piece box:
   the Nether biome's monster list (for crimson forest, zombified piglin, hoglin and piglin).
4. Ancient city overall box: every category empty: no natural spawns at all inside the box.

### 14.6 Overlay

Base `{ monster: [zombie 1] }` and top `{ creature: [pig 1] }` (no costs): rules 1 and 2 do not apply; rule 3 fails
(top does not define `monster`); rule 4 gives `{ monster: [zombie 1], creature: [pig 1] }`. Base `{ monster: [zombie 1],
creature: [cow 1] }` and top `{ creature: [pig 1] }`: result `{ monster: [zombie 1], creature: [pig 1] }` (the cow
list is replaced, not merged). Base `{ creature: [cow 1] }` and top `{ creature: [], monster: [] }` (explicitly empty):
rule 3 holds (top defines every category of base): the result is top, so creature and monster are empty.

### 14.7 Ocelot

Jungle or bamboo jungle, night, monster pass on a clearing: the ocelot is drawn with weight 2 of the monster
list; it passes the type's own rule 2 times in 3, then `checkSpawnObstruction` (grass block or leaves below, no liquid, at or above sea level); the cap tested for the monster pass is the monster cap, but the
count increased afterwards is the creature count.

## 15. Validation

What was checked and how.

| Check | Method | Result |
|---|---|---|
| `BaseSpawner` constants and the attempt order of 18 §6.12 | re-read `serverTick`, `delay`, `load` constants | agree; added fields, saved names and the empty default spawn data |
| Delay formula `min + nextInt(max - min)`, `min` when `max <= min` | `delay` | as stated |
| Trial spawner tick, transitions, timings (40, 30, 160, 36000, 14, 47, 20, 18000) | read `TrialSpawner`, `TrialSpawnerState`, `TrialSpawnerStateData`, `TrialSpawnerConfig`, `FullConfig`, `PlayerDetector` | transcribed as numbered rules; the 30-tick cadence and 40-tick delay verified on the `float` arithmetic |
| The 28 trial spawner config files | counted with `unzip -Z1 ... | grep -v '/$'` (28 = 14 pairs); four sampled (breeze, zombie, slime, ominous) | defaults and per-file overrides as described |
| Structure `spawn_overrides` | parsed all 52 structure JSON files | table 8.3 is complete: six structures carry a non-empty override (the table has 8 rows because monument and swamp_hut appear twice); the other 46 files have `{}`; counts and weights as shown |
| Fortress list parity | compared `FORTRESS_ENEMIES` static initialiser with the fortress JSON | identical entries |
| Biome `natural_mob_spawns` | parsed 67 biome files (counted by prefix) | all 67 carry the attribute with modifier `overlay`; no other data file mentions it |
| Spawner structure pieces | read `MineShaftCorridor`, `MonsterThrone`, `PortalRoom`, `WoodlandMansionPiece.handleDataMarker` | rules and coordinates as stated |
| Template mobs | parsed all 1511 structure NBT files (gzip NBT reader written for this round, outside the repository) | counts in 10.5 are exact for this jar |
| Custom spawner values vs 20 and 19 | compared phantom, patrol and trader constants | agree (6) |
| Cross-check with 18 §6 | compared the spawn cost, cap and category semantics | 18 §6.5 step 4 and §6.7 are refined by 7.3, 8.1 and 9 (type category versus list category; spawn costs read from the attribute at the position) |
| Trial spawner pairs | parsed all 14 normal and ominous file pairs | 4.2 states which keys differ per pair (5 pairs differ in totals; both files of a pair set `simultaneous_mobs_added_per_player` where it is set) |
| Components per class | read every class overriding `applyImplicitComponent(s)` and the components it names | table in §5 |
| Structure piece spawns | read `SwampHutPiece`, `OceanMonumentPiece.spawnElder` and its callers, `EndCityPiece.handleDataMarker`, `OceanRuinPiece.handleDataMarker`, `MonsterRoomFeature`, `MinecartSpawner`, `DismountHelper` | 2.6, 10.7 to 10.11, §11 |

No test vectors beyond §14 could be generated without execution. The numbers of 14.1 and 14.2 follow directly
from the formulas of 2.3 and 4.2 and the tick order of 4.4.

## 16. Open questions

18 OQ 4 and 17, 19 OQ 4, 5, 6 and 35, 20 OQ 12 and 21 OQ 2, 3, 6 and 22 are answered by this document and can be closed by citing it.

1. **Client effects.** The level events 3011 to 3014, 3019, 3020, 3021 and 2004 and their particle and sound outputs
   are named, not specified; the client round owns them. The particle numbers in 4.1 are the ones read.
2. **Ocelot intent.** Whether the ocelot in the `monster` lists is intended cannot be determined from the artifact; the
   behaviour in section 9 follows from the engine as read.
3. **Recall and inference.** Nothing in this document is taken from memory. Items marked "(inferred)": the bastion
   placement odds (10.5, arithmetic on read weights), the filtering of end city marker blocks by the template ignore
   setting (10.9), and the attribution of the `isValidSpawn` lambdas to named blocks (11, by adjacency in `Blocks`).
4. **Editor actions outside this document.** 18 §6.5 step 4 lists structure overrides only for swamp huts, ocean
   monuments and pillager outposts; the full set is fortress (piece), monument, pillager outpost, swamp hut, ancient
   city and trial chambers (see 8.3), and 18 OQ 17 should not say step 4 uses the fortress case only. 18 §6.12 (trial
   spawner bullet) and 18 OQ 4 should point to 44-2 sections 4 to 6.
