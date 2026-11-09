# 32 — Light engine

| Field | Value |
|---|---|
| Covers | The block-light and sky-light engines of the 26.3 client jar: the per-cell level rules, the queue entry format, the increase and decrease propagation, sky-light sources per column, section storage and its states, the order in which the engine is fed (chunk arrival, block changes, section emptiness, chunk unload), the batching of updates on the client and the server, and the block-state inputs (emission, dampening, occlusion). The wire layout of light data is in 06 section 7 and is not repeated. The lightmap and smooth lighting that read these levels are in 12 section 1. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution |
| Classes read | `LightEngine`, `LightEngine$QueueEntry`, `BlockLightEngine`, `SkyLightEngine`, `ChunkSkyLightSources`, `LayerLightSectionStorage` (and `$SectionState`, `$SectionType`), `BlockLightSectionStorage`, `SkyLightSectionStorage`, `DataLayerStorageMap`, `LevelLightEngine`, `DataLayer`, `ThreadedLevelLightEngine`, `ChunkStatusTasks`, `ChunkAccess`, `LevelChunk`, `ProtoChunk` (call sites only), `ClientPacketListener`, `ClientLevel`, `ClientChunkCache`, `BlockBehaviour` and `$BlockStateBase`, the block classes listed in section 7, and for section 1.1 and 1.2 `SkyLightEngine$1`, `ChunkSkyLightSources`, `BlockScanUtils`, `Level`, `LevelReader`, `BlockAndLightGetter`, `EntitySpawnReason`, `Minecraft` (call site of `ClientLevel.update`), `SectionPos`, `DimensionType`, `ChunkMap`, `Monster`, `CropBlock`, `DaylightDetectorBlock`, `PhantomSpawner`, `SerializableChunkData`, `LightBlock`, `Blocks`, and for the 2nd-pass additions `Lightmap` (static `getBrightness` only), `EntityRenderer`, `LevelExtractor`, `Hud`, `Animal`, `Bat`, `Slime`, `LightPredicate`, `SaplingBlock`, `FireflyBushBlock`, `SpreadingSnowyBlock`, `FrostedIceBlock`, `Giant`, `Enderman`, `Blaze`, `Guardian`, `Vex`, `SulfurCube`, `Spider$SpiderAttackGoal`, `Spider$SpiderTargetGoal`, `BlockBehaviour`, and `data/minecraft/dimension_type/*.json` |

Every statement below was read from the artifact unless it carries "(inferred)" or "(recalled, not verified)".

## 1. Overview and constants

Two independent engines run over one set of rules: a block-light engine (`BlockLightEngine`) and a sky-light engine (`SkyLightEngine`), both subclasses of `LightEngine`. `LevelLightEngine` owns one of each, either may be absent (a dimension without sky light has no sky engine, `LevelLightEngine(chunkGetter, blockEnabled, skyEnabled)`), and forwards every call to both. A missing layer reads as level 0 (`getRawBrightness`; the layer listener of a missing engine is a dummy that reports 0). Which engines exist is decided by the dimension, see 1.1.

| Constant | Value |
|---|---|
| Maximum level | 15 (`MAX_LEVEL`) |
| Minimum opacity of any cell | 1 (`MIN_OPACITY`) |
| Light section padding | 1 section below the lowest block section and 1 above (`LIGHT_SECTION_PADDING`) |
| Light section count | block section count + 2; minimum light section Y = minimum section Y − 1; maximum light section = minimum + count (exclusive end) |
| Section array | 2048 bytes, 4096 nibbles; index `(y << 8) | (z << 4) | x`, byte `index >> 1`, low nibble for even index (06 section 7.1 gives the same layout) |
| Directions | The six directions in `Direction` declaration order: ordinal 0 DOWN, 1 UP, 2 NORTH, 3 SOUTH, 4 WEST, 5 EAST. Propagation visits them in this order (`PROPAGATION_DIRECTIONS` is the `values()` array) |

Raw brightness at a position (`LevelLightEngine.getRawBrightness(pos, darken)`) is `max(blockLight(pos), skyLight(pos) − darken)`; a missing engine contributes 0. How `darken` is computed is 33 section 3.5.

### 1.1 Dimension rules: which engines exist

| Fact | Value |
|---|---|
| Block-light engine | Always created, on the client (`ClientChunkCache`), on the server (`ChunkMap` building `ThreadedLevelLightEngine`) and in both constructors' first flag. |
| Sky-light engine | Created only when the dimension type's `has_skylight` is true (client and server both pass `DimensionType.hasSkyLight`). A dimension with `has_skylight` false has no sky layer: sky brightness reads 0 everywhere, `canSeeSky` is false everywhere, no sky source tables are consulted. |
| `has_skylight` also gates | Loading stored sky layers (8.4), weather, and the phantom spawner's sky checks (1.2). `Level.canHaveWeather` is `has_skylight` AND NOT `has_ceiling` AND the dimension key is not the End key (read). `isThundering` is `canHaveWeather` and thunder level (partial tick 1) `> 0.9`; `isRaining` is `canHaveWeather` and rain level `> 0.2` (read). Owning document for weather: 33. |
| `ambient_light` (dimension type float; values in the table below) | Used by the engines not at all. Two read consumers: `LevelReader.getLightLevelDependentMagicValue` (1.2) and the static `Lightmap.getBrightness(dimensionType, level)`, which applies the same curve to an integer level `L`: `r = L / 15`, `f = r / (4 - 3r)`, result `f + ambient_light * (1 - f)` (read; same formula as 1.2). Callers of the latter are in 1.2. The lightmap shader's inputs are in 12 section 1 (that document records that the renderer reads the `ambient_light_color` attribute, not this float, for the lightmap colour). |
| `sky_light_level` attribute (`gameplay/sky_light_level`) | Not an engine input. The Nether dimension type carries it as 4.0 although the Nether has no sky layer. It only produces `skyDarken` (33 section 3.5); the stored sky light levels never depend on time of day or weather. `skyDarken` is subtracted by the readers in 1.2. |

Per-dimension values read from `data/minecraft/dimension_type/*.json`:

| Dimension type | `has_skylight` | `has_ceiling` | `ambient_light` | `monster_spawn_block_light_limit` | `monster_spawn_light_level` |
|---|---|---|---|---|---|
| `overworld` | true | false | 0.0 | 0 | uniform 0 to 7 inclusive |
| `overworld_caves` | true | true | 0.0 | 0 | uniform 0 to 7 inclusive |
| `the_nether` | **false** | true | 0.1 | 15 | constant 7 |
| `the_end` | true | false | 0.25 | 0 | constant 15 |

Only the Nether lacks a sky engine. Fixed-time flags and other fields are in 04 and not repeated. Weather (`canHaveWeather`) is therefore possible only in `overworld` (the caves type has a ceiling, the Nether has no sky light, the End is excluded by key).

### 1.2 Consumers and the brightness query each one calls

| Query (name in the jar) | Result |
|---|---|
| `getBrightness(layer, pos)` | The published level of one layer (6.7); 0 when the layer's engine is missing. |
| `getRawBrightness(pos, darken)` | `max(block, sky - darken)` as above; the sky term is 0, not `-darken`, when the sky engine is missing. |
| `getMaxLocalRawBrightness(pos, darken)` | 15 when x or z is outside ±30 000 000 (x < -30 000 000, z < -30 000 000, x >= 30 000 000 or z >= 30 000 000); else `getRawBrightness(pos, darken)`. The one-argument form uses `darken = skyDarken` (33 section 3.5). |
| `getEffectiveSkyBrightness(pos)` | `max(0, sky(pos) - skyDarken)`. |
| `canSeeSky(pos)` | `sky(pos) >= 15`. |
| `getLightLevelDependentMagicValue(pos)` | Let `r = getMaxLocalRawBrightness(pos) / 15`, `f = r / (4 - 3r)`; the result is `f + ambient_light * (1 - f)` (the interpolation helper is read as `lerp(delta, start, end) = start + delta * (end - start)`, called with delta `ambient_light`, start `f`, end 1.0; 18 section 6.8 states the same formula for `Monster`). `getPathfindingCostFromLightLevels` is that value minus 0.5. Callers read for the call only (the threshold each applies is not read, Open question 6): `Giant`, `Enderman`, `Blaze`, `Guardian`, `Vex`, `SulfurCube`, `Spider$SpiderAttackGoal` (compares the value with 0.5; the follow-up branch is not read) and `Spider$SpiderTargetGoal`. Callers located by constant-pool search and not read: `Entity`, `Mob`, `Animal`, `Monster`, `Turtle`, `MushroomCow`, `MagmaCube`, `EyeOfEnder`, `ShulkerBullet`, `AbstractHurtingProjectile`. The integer-level variant `Lightmap.getBrightness(dimension, level)` is described in 1.1. |

| Consumer | What it calls and the thresholds read | Owning document |
|---|---|---|
| Monster spawn light test (`Monster.isDarkEnoughToSpawn`) | Reject when sky layer at the position `> nextInt(32)`. If the dimension's `monster_spawn_block_light_limit` is below 15, reject when the block layer `>` the limit. Then `m = getMaxLocalRawBrightness(pos, 10)` when the level is thundering, else with the default darken; accept when `m <=` one sample of the dimension's `monster_spawn_light_level` provider. | 18 section 6.8 (do not repeat), 04 section 1 for the dimension fields |
| Crop growth (`CropBlock.randomTick`) | Grow only when `getRawBrightness(pos, 0) >= 9` and age below maximum. | 29b part 1 section 6 (`CropBlock` base) and 29b part 2 section 3.2 (thresholds 9 and 8, matching this jar) |
| Crop survival (`CropBlock.canSurvive`) | `getRawBrightness(pos, 0) >= 8` and the vegetation ground rule. | 29b part 2 section 3.2 |
| Daylight detector (`DaylightDetectorBlock.updateSignalStrength`) | Starts from `getEffectiveSkyBrightness`. Inverted: `15 - s`. Not inverted and `s > 0`: take the `sun_angle` attribute `a` (degrees to radians with 0.017453292), move it 20 percent of the way to 0 when `a < pi`, else to 2 pi, and output `round(s * cos(a))`. Clamp to 0..15 and write the `power` property when it changed. Scheduling: the block entity ticker exists only on the server and only in a dimension with sky light, and recomputes only when game time mod 20 == 0. Using the block (player may build, server side) cycles the `inverted` property (set with flags 2, a block-change game event) and recomputes at once; the client side only returns success. | not found in the existing documents (Open question 8) |
| Phantom spawner (`PhantomSpawner.tick`) | Two light-derived gates. (1) Whole-tick gate: after the tick flag, the `spawnPhantoms` rule and the next-tick countdown (which is already rewritten by then, so the delay is consumed), when `skyDarken < 5` **and** the dimension has sky light the whole tick returns before any player is examined. (2) Per player (spectators skipped): when the dimension has sky light, the player must be at or above the sea level and `canSeeSky(playerPos)`; dimensions without sky light skip both tests. The remaining gates (difficulty roll, time since rest, offsets) are not light and are in 20. | 20 section 12; insomnia in 20 section 20.5 |
| Client users of `Lightmap.getBrightness(dimension, level)` | `EntityRenderer` (entity shadow strength: `0.5 x strength x getBrightness(dimension, light)`, clamped to 0..1; the constant 0.5 and clamp read, the surrounding strength computation not), `LevelExtractor` and `Hud`, the last two passing `getMaxLocalRawBrightness` of the camera block. | 12 section 1 (not repeated) |
| Light level debug line | Combined raw brightness at the camera block with its sky and block parts. | 13 (`light_levels` debug entry, line 747 of the document) |
| Client lightmap and smooth lighting | Reads the published layers (`RenderSectionRegion` references the light engine; not read, inferred). | 12 section 1 (the lightmap input packing was not re-read here, Open question 7) |

Further consumers read in the second pass (spawn, predicate and block users of the queries; thresholds read from the call sites):

| Consumer | Rule |
|---|---|
| `Animal.isBrightEnoughToSpawn` | `getRawBrightness(pos, 0) > 8`; the rule is in 18 section 6.8. |
| `Bat.checkBatSpawnRules` (light part only) | Reject when `getMaxLocalRawBrightness(pos) > nextInt(4)`. The other conditions (position against the surface height, a boolean roll, the `BATS_SPAWNABLE_ON` tag below, `checkMobSpawnRules`) are not light rules and were read only by call name. |
| `Slime.checkSlimeSpawnRules` | Not peaceful; for a spawner reason `checkMobSpawnRules` applies directly. Surface branch: biome in tag `ALLOWS_SURFACE_SLIME_SPAWNS`, `50 < y < 70`, `nextFloat` below the `SURFACE_SLIME_SPAWN_CHANCE` environment attribute at the position, and `getMaxLocalRawBrightness(pos) <= nextInt(8)`, then `checkMobSpawnRules`. The remaining branch (swamp and slime-chunk rule) is not light and not re-read. |
| `LightPredicate.matches` (advancement and loot predicate) | `getMaxLocalRawBrightness(pos)` on the server level tested against an integer range. Grammar and owner: 26. |
| `SaplingBlock`, `FireflyBushBlock`, `SpreadingSnowyBlock`, `FrostedIceBlock` | Each calls `getMaxLocalRawBrightness` (`FrostedIceBlock` also `getBrightness(layer, pos)`). Thresholds not read (Open question 9). Owner: 29b. |
| Other `getLightLevelDependentMagicValue` callers | Listed in the first table of this section. |

Further consumers read in the first pass (not light engine rules, but they call the queries above):

| Consumer | Rule |
|---|---|
| `LevelReader.canSeeSkyFromBelowWater(pos)` | At or above the sea level: `canSeeSky(pos)`. Below it: the cell at (x, sea level, z) must pass `canSeeSky`; then every cell from sea level − 1 down to `pos.y + 1` (inclusive; `pos` itself and the sea level cell are not tested) must have dampening 0 or be a liquid (`BlockState.liquid`); any other cell gives false; otherwise true. |
| `Monster.checkMonsterSpawnRules` | `(spawn reason ignores light requirements or isDarkEnoughToSpawn) and checkMobSpawnRules` (the last not read here). `EntitySpawnReason.ignoresLightRequirements` is true only for `TRIAL_SPAWNER`. |
| `Monster.checkSurfaceMonstersSpawnRules` | `checkMonsterSpawnRules and (reason is a spawner or canSeeSky(pos))`; `EntitySpawnReason.isSpawner` is true for `SPAWNER` and `TRIAL_SPAWNER`. |
| `Monster.checkAnyLightMonsterSpawnRules` | `checkMobSpawnRules` only; no light test. |
| `CropBlock.hasSufficientLight` | `getRawBrightness(pos, 0) >= 8`; the helper behind the survival threshold above (`canSurvive` is this and the vegetation ground rule). |

## 2. Inputs read from block states

| Input | Meaning |
|---|---|
| `getLightEmission` | Emission 0–15 of the state (24 section 5.2). |
| `getLightDampening` | How much light the cell removes, 0–15. Default rule and overrides in section 7. |
| `canOcclude` | Block property, default true, false after `noOcclusion()` (24). |
| `useShapeForLightOcclusion` | Default false; overrides in section 7. |
| Occlusion shape and its six face shapes | 24 section 5.2. |
| `isEmptyShape(state)` | The engine's own predicate: true when `canOcclude` is false **or** `useShapeForLightOcclusion` is false. Despite the name it is true for every ordinary full block. It means "the cell's own shape plays no part in occlusion between faces". |
| `getOpacity(state)` | `max(1, getLightDampening)`. |
| `hasDifferentLightProperties(a, b)` | False when `a` and `b` are the same state object; true when their dampening differs, or their emission differs, or either has `useShapeForLightOcclusion`; else false. |

### 2.1 Occlusion between two cells (`shapeOccludes`)

For a cell `S` (source) and a neighbour `N` in direction `d`:
- the face of `S` is `getOcclusionShape(S, d)` and the face of `N` is `getOcclusionShape(N, opposite(d))`;
- `getOcclusionShape(state, face)` is the empty shape when `isEmptyShape(state)`, else the state's face occlusion shape for that face;
- light is blocked when `Shapes.faceShapeOccludes(faceS, faceN)` is true.

When both are empty shapes this is always false (no blocking by shape); opacity alone then applies. `LightEngine.getLightDampeningInto(from, to, dir, defaultValue)` is a static helper not used by the two engines below (informational only). It returns the default when both states' whole occlusion shapes are empty, 16 when `Shapes.mergedFaceOccludes` of the two whole occlusion shapes (not the per-face shapes of `shapeOccludes`) is true, else the default.

### 2.2 State of an unloaded cell

`getState(pos)` reads the chunk through the chunk getter (a two-entry last-used cache of chunks is kept per engine and cleared at the end of every `runLightUpdates`). When the chunk is not available the state is `minecraft:bedrock`'s default state, which is opaque.

## 3. Queue entries

The engines queue pairs of longs (position as a packed block position, then an entry). Two FIFO queues exist: increase and decrease. An entry (`QueueEntry`) packs:

| Bits | Content |
|---|---|
| 0–3 | "from level" (0–15) |
| 4–9 | one bit per direction, bit `4 + ordinal`: propagate in that direction (mask 1008) |
| 10 | flag "from empty shape" (value 1024) |
| 11 | flag "increase from emission" (value 2048) |

Constructors, by name:

| Name | Level | Direction bits | Flags |
|---|---|---|---|
| `decreaseAllDirections(l)` | l | all six | none |
| `decreaseSkipOneDirection(l, d)` | l | all except d | none |
| `increaseLightFromEmission(l, emptyShape)` | l | all six | emission; plus from-empty-shape when `emptyShape` |
| `increaseSkipOneDirection(l, emptyShape, d)` | l | all except d | from-empty-shape when `emptyShape` |
| `increaseOnlyOneDirection(l, emptyShape, d)` | l | only d | from-empty-shape when `emptyShape` |
| `increaseSkySourceInDirections(down, north, south, west, east)` | 15 | the true ones among DOWN, NORTH, SOUTH, WEST, EAST (never UP) | none |

`PULL_LIGHT_IN_ENTRY` is `decreaseAllDirections(1)`. The sky engine has three constants: `REMOVE_TOP_SKY_SOURCE_ENTRY` = decreaseAllDirections(15); `REMOVE_SKY_SOURCE_ENTRY` = decreaseSkipOneDirection(15, UP); `ADD_SKY_SOURCE_ENTRY` = increaseSkipOneDirection(15, false, UP).

## 4. The update cycle (`LightEngine`)

External calls only record work:
- `checkBlock(pos)` adds the packed position to the set `blockNodesToCheck`.
- `queueSectionData`, `retainData`, `updateSectionStatus`, `setLightEnabled` act on the storage (section 6).
- `hasLightWork()` is true when the storage has inconsistencies, the check set is non-empty, or either queue is non-empty.

`runLightUpdates()` does, in order:
1. For every position in `blockNodesToCheck` call the engine's `checkNode` (section 5.1 or 5.2), then clear the set (and trim it to capacity 512).
2. Drain the **decrease** queue (`propagateDecrease` per pair). Each pair counts as one unit of work.
3. Drain the **increase** queue (`propagateIncrease` per pair).
4. Clear the chunk cache; `markNewInconsistencies` (section 6.3); `swapSectionMap` (section 6.4).
5. Return the number of pairs processed.

Decreases always run completely before increases, so removed light is cleared first and the increase queue then refills it from the boundary.

## 5. Propagation rules

### 5.1 Block light (`BlockLightEngine`)

**Emission of a cell** (`getEmission`) is the state's emission when it is > 0 **and** the section's chunk column has light enabled (section 6.5); else 0.

**`checkNode(pos)`** (used for a changed block):
1. Do nothing when the section of `pos` stores no light (layer presence, 6.1).
2. `e` = emission of the cell; `s` = stored level.
3. If `e < s`: store 0 at `pos` and queue a decrease `decreaseAllDirections(s)`. Otherwise queue a decrease with `PULL_LIGHT_IN_ENTRY` (level 1, all directions): this makes each neighbour re-offer its light to `pos`.
4. If `e > 0`: queue an increase `increaseLightFromEmission(e, isEmptyShape(state))`.

**`propagateIncrease(pos, entry, level)`**, `level` being the stored level of `pos` at dequeue (for an emission entry the stored level is first raised to the entry's from-level when lower; the entry is processed only if the stored level then equals the entry's from-level). For each direction with its entry bit set:
1. `n` = neighbour position. Skip when its section stores no light.
2. `ns` = neighbour stored level. Skip when `level − 1 ≤ ns`.
3. `nstate` = neighbour state; `newLevel = level − opacity(nstate)`. Skip when `newLevel ≤ ns`.
4. The source state is `minecraft:air`'s default state when the entry has the from-empty-shape flag, else the state at `pos` (fetched once per entry, lazily).
5. Skip when `shapeOccludes(source, nstate, direction)` (2.1).
6. Store `newLevel` at `n`. When `newLevel > 1`, queue an increase `increaseSkipOneDirection(newLevel, isEmptyShape(nstate), opposite(direction))`.

**`propagateDecrease(pos, entry)`**, `from` = the entry's from-level. For each direction with its bit set:
1. Skip when the neighbour's section stores no light, or its stored level `ns` is 0.
2. If `ns ≤ from − 1` (the neighbour was lit from here): read its emission `e`; store 0 at `n`; if `e < ns` queue a decrease `decreaseSkipOneDirection(ns, opposite(direction))`; if `e > 0` queue an increase `increaseLightFromEmission(e, isEmptyShape(nstate))`.
3. Otherwise (the neighbour is at least as bright as this cell could have given it, so it has another source): queue an increase `increaseOnlyOneDirection(ns, false, opposite(direction))`, which re-spreads the neighbour's light back toward `pos` only.

**Chunk start** (`propagateLightSources(chunkPos)`): enable light for the column (set light enabled, 6.5), then for every block in the chunk whose state has emission ≠ 0 (`findBlockLightSources`, the predicate is `getLightEmission != 0`) queue `increaseLightFromEmission(emission, isEmptyShape(state))`. `findBlocks` visits the chunk's sections from the lowest section Y to the highest (skipping a section whose palette cannot contain a match), and inside a section Y ascending outermost, then Z ascending, then X ascending innermost (so the order equals the storage index order of 1). Every emitting cell is queued in that order. Emission of the `minecraft:light` block is its `level` property (0 to 15): `Blocks.LIGHT` is registered with a light-level function that returns that property, so a level-0 light block is not a source and does not match the predicate.

### 5.2 Sky light (`SkyLightEngine`)

Sky light 15 is a **source level**: `isSourceLevel(l)` is `l == 15`.

**Sky sources per column** (`ChunkSkyLightSources`, section 5.3) give for each (x, z) the **lowest source Y**: every cell of the column at or above that Y is a sky source (level 15), every cell below is lit only by spreading. The engine reads it with `getLowestSourceY(x, z, default)`: the value from the chunk's sources, `default` when the chunk is unavailable.

**`checkNode(pos)`:**
1. `lowest` = lowest source Y of the column when the section's column has light enabled, else `Integer.MAX_VALUE` (no sources).
2. When `lowest ≠ MAX_VALUE`, call `updateSourcesInColumn(x, z, lowest)` (below).
3. Do nothing more when the section stores no light.
4. If `y ≥ lowest` (the cell is a source): queue a decrease `REMOVE_SKY_SOURCE_ENTRY` and an increase `ADD_SKY_SOURCE_ENTRY` at `pos`.
5. Otherwise: with stored level `s`, if `s > 0` store 0 and queue decrease `decreaseAllDirections(s)`; else queue the decrease `PULL_LIGHT_IN_ENTRY`.

**`updateSourcesInColumn(x, z, lowest)`** keeps the stored levels of one column consistent with a changed lowest-source Y. `bottom` is the block Y of the lowest section the storage knows (`getBottomSectionY`). It always runs the removal step and then the addition step, for the same `lowest`.

*Removal step* (cells below the new lowest source that still hold a source level):
- Inputs: column (x, z), `lowest`, `bottom`. Nothing happens when `lowest <= bottom`.
- Candidate cells are those at Y = `lowest - 1` and below, scanned downward, but only inside sections that store light; a section is entered only while the storage reports light data at or below it, and a section that does not store light is skipped.
- A candidate whose stored level is not 15 ends the whole step (the old source column ended there).
- Each candidate at level 15 is set to 0 and a decrease is queued: the entry `REMOVE_TOP_SKY_SOURCE_ENTRY` (level 15, all six directions, so light can also be pulled back from above) for the cell at Y = `lowest - 1`, and `REMOVE_SKY_SOURCE_ENTRY` (level 15, all but UP) for every cell below it.
- Example: the lowest source rises from 64 to 70 (a block placed at 69). Cells 69, 68, ..., 64 hold 15 and the cell at 63 holds 14, so the step clears 69 (all-direction entry) and 68..64 (skip-UP entries) and stops at 63.

*Addition step* (cells at and above the new lowest source that do not yet hold 15):
- Inputs: column (x, z), `lowest`, `bottom`, and `nbrLowest` = the maximum of the lowest source Y of the four horizontal neighbour columns (x-1, x+1, z-1, z+1; a column whose chunk is unavailable counts as `Integer.MIN_VALUE`). Start Y = `max(lowest, bottom)`.
- Scan upward from the start Y, one section at a time, in sections that store light, until the storage reports the section as above all data.
- The first cell that already holds 15 ends the whole step.
- Every other cell is set to 15. An increase entry `ADD_SKY_SOURCE_ENTRY` (level 15, all but UP, not from empty shape) is queued for it only when `Y < nbrLowest` (some neighbour column has no source at that height, so light must spread sideways) or `Y == lowest` (the lowest source cell also spreads down). Cells where every neighbour column already has a source at that height are written without a queue entry.
- Example: the lowest source drops from 70 to 64 in a column whose neighbours all have lowest source 64. Cells 64 to 69 are set to 15; the scan ends at 70 (already 15). Only cell 64 (`Y == lowest`) is queued, since `64 < 64` is false for every cell.

**`propagateIncrease` and `propagateDecrease`** are the block-light rules of 5.1 with the same constants, with these differences:
- no emission handling (no `getEmission`, no emission flag in entries), and a decrease that clears a neighbour queues only the decrease, no re-increase;
- every cell lit, or cleared, from a source cell at a section bottom edge may need the **empty sections below** to follow (`propagateFromEmptySections`): see below.

**Empty sections below a column edge.** Two positions are involved and they must not be mixed up.

- *Source cell* `P`: the cell dequeued from the queue. `countEmptySectionsBelowIfAtBorder(P)` returns 0 unless `P`'s Y is a section bottom (`Y & 15 == 0`) **and** `P` is on its section's x or z edge (local x or local z equal to 0 or 15). Otherwise it counts `k`, the number of consecutive sections directly below `P`'s section (in `P`'s own section column) that do **not** store light but still have light data at or below them (`hasLightDataAtOrBelow`). `k` is computed once per dequeued entry.
- *Neighbour cell* `N`: the cell in direction `d` from `P` that was just lit (increase) or cleared (decrease). After storing the new value at `N`, both `propagateIncrease` and `propagateDecrease` call `propagateFromEmptySections(N, d, level, increase, k)`. `level` is `newLevel` (the value just stored at `N`) on increase, and `N`'s old stored level on decrease.

`propagateFromEmptySections(N, d, level, increase, k)`:
1. Return when `k == 0`.
2. Compute `crossedSectionEdge(d, local x of N, local z of N)`; return when false. The test uses the **neighbour's** local coordinates, because `N` is the cell that fell into the next section column:

| Direction `d` | True when `N` has |
|---|---|
| NORTH | local z == 15 |
| SOUTH | local z == 0 |
| WEST | local x == 15 |
| EAST | local x == 0 |
| UP, DOWN | never (always false) |

(Read from `SkyLightEngine$1`.) A step from `P` to the north has z decreasing, so `N` lands on local z 15 of the neighbouring section.
3. The column written is the column of `N` (its block x and z). The Y range starts at the section index `blockToSection(N.y) - 1` and goes down `k` sections (section indices from `blockToSection(N.y) - 1` down to `blockToSection(N.y) - k`). Sections in that range that do not store light **in `N`'s section column** are skipped (these differ from the sections counted for `P`: the sections below `P` do not store light, but those of the neighbouring section column normally do).
4. In each such section all 16 Y values (top to bottom): on increase store `level` and, when `level > 1`, queue `increaseSkipOneDirection(level, from-empty-shape true, opposite(d))`; on decrease store 0 and queue `decreaseSkipOneDirection(level, opposite(d))`.

Worked example: `P` = block (0, 32, 5) (section Y 2, local x 0, local y 0), WEST step, `k = 1` (section Y 1 below `P` stores no light but light data exists lower). `N` = (-1, 32, 5), local x 15, so WEST crosses. The range is section index `2 - 1 = 1` down 1 section, that is section 1 only; if section (-1, 1, 0) stores light, the cells (-1, 31..16, 5) all receive `level` (increase) or 0 (decrease).

**Chunk start** (`propagateLightSources(chunkPos)`, server only, 8.3). Inputs: the column's `top` (`getTopSectionY` of the column; by definition (6.8) it is the highest section Y that stores light, **plus 1**), the storage's bottom section Y `bottomSec`, the lowest-source tables of this chunk and of its four horizontal neighbours (an unavailable neighbour uses an empty table in which every column reads `Integer.MIN_VALUE`, i.e. "sources reach below the world"). Output: sky layers filled with 15 at and above each column's lowest source, plus the boundary queue entries.
1. Enable light for the column (6.5).
2. Process light sections from `top - 1` (the highest storing section) downward to `bottomSec` (6.8). Sections at and above `top` are not written here; they read as 15 through the top-section table (6.7).
3. For one section with Y range `[secBottom, secTop]` (`secTop = secBottom + 15`): if the storage cannot give a writable layer for it, go on to the next section down (this case never ends the loop). Otherwise, for each of the 256 columns `(x, z)` with lowest source `ls`:
   - a column with `ls > secTop` is ignored (no source reaches this section);
   - otherwise let `lsN, lsS, lsW, lsE` be the lowest source of the neighbour columns at z-1, z+1, x-1, x+1 (taken from the neighbouring chunk's table when the column is on that chunk edge: z == 0 reads the north chunk's z 15, z == 15 reads the south chunk's z 0, x == 0 reads the west chunk's x 15, x == 15 reads the east chunk's x 0), and `maxN = max(lsN, lsS, lsW, lsE)`;
   - for every Y from `secTop` down to `max(secBottom, ls)`: set the cell to 15; and when `Y == ls` or `Y < maxN`, queue at (chunk origin x + x, Y, chunk origin z + z) the entry `increaseSkySourceInDirections(down = (Y == ls), north = Y < lsN, south = Y < lsS, west = Y < lsW, east = Y < lsE)` (level 15, never UP, only the true directions);
   - if `ls < secBottom` (the source column continues below this section; `Integer.MIN_VALUE` counts as below) remember that the next section down must be processed.
4. After a section with a writable layer: continue to the next section down only if some column set the "continues below" mark in step 3, else stop. The mark is per section, not carried over.

Worked example. Level min Y 0, light sections -1 to 2: blocks Y 0..31 hold data (sections 0 and 1), and section -1 and section 2 store light because each neighbours a section with data. The highest storing section is 2, so `top = 2 + 1 = 3` and processing starts at section 2. Every column has `ls = 20` except column (5, 5) with `ls = 3`; the four neighbour chunks are assumed to have the same table as this chunk, so chunk-edge columns behave like interior ones.
- Section 2 (Y 32..47): every column has `ls <= 47` and is processed: 15 is written at Y 47..32 for all 256 columns (for (5, 5), `max(32, 3) = 32`). No entry is queued: `Y == ls` never holds (ls is 20 or 3, below 32) and `Y < maxN` is false for Y >= 32 (`maxN` is 20). Mark: every column has `ls < 32`, so section 1 follows.
- Section 1 (Y 16..31): every column except (5, 5) gets 15 at Y 31..20. For them `maxN` is 20 (the largest neighbour value), so `Y < maxN` is false for all Y >= 20 and the only entry is at `Y == 20` with only `down` true. Column (5, 5): `ls = 3`, so 15 is written at Y 31..16; its neighbours have `ls = 20`, so entries are queued for Y 19..16 (`Y < 20`) with north, south, west and east true and `down` false. Mark: only column (5, 5) has `ls = 3 < 16`, so section 0 is processed next.
- Section 0 (Y 0..15): the 255 other columns have `ls = 20 > 15` and are ignored. Column (5, 5) gets 15 at Y 15..3; entries for every Y in 15..3 with the four horizontal flags true, and `down` true only at Y == 3. Mark: `ls = 3` is not below 0, so the loop stops here. Section -1 is not touched.
- Total for column (5, 5): 4 + 13 = 17 entries; the increase queue then spreads light sideways into the dark cells under the surrounding surface and downward from Y == 3.

`setLightEnabled(chunkPos, true)` on the sky engine additionally fills with 15 every writable layer that is currently all zero, scanning sections from `top - 1` (`top` = the column's top-table value, highest storing section + 1, 6.8) downward to `max(bottomSec, S)`, where `S = blockToSection(H - 1) + 1` and `H` is the highest lowest-source Y of the chunk (`getHighestLowestSourceY`; the minimum-value rule of 5.3 applies). Sections that do not have a writable layer are skipped.

### 5.3 `ChunkSkyLightSources`

One table per chunk: 256 entries indexed `x + 16·z` (local x and z), storing "lowest source Y − (min Y − 1)" in a bit storage of `ceillog2(maxY + 1 − (minY − 1) + 1)` bits (`SimpleBitStorage`, 256 entries). Let `minY` below be the level min Y minus 1. The accessor `getLowestSourceY(x, z)` returns the stored value plus `minY`, except that the value `minY` itself is reported as `Integer.MIN_VALUE` ("sources reach the bottom of the world and below"). `getHighestLowestSourceY()` is the maximum stored value plus `minY` with the same rule.

**Edge occlusion** `isEdgeOccluded(above, below)`: true when `below`'s dampening is non-zero; otherwise `Shapes.faceShapeOccludes(getOcclusionShape(above, DOWN), getOcclusionShape(below, UP))`. Water (dampening 1) therefore ends a sky source column.

**Fill from a chunk** (`fillFrom`, called when a chunk is created or received, 5.4): if the chunk has no non-air section (`getHighestFilledSectionIndex == −1`), every entry becomes `minY` (no ground). Otherwise for each column: scan down from the top of the highest non-air section (the cell just above it counts as air above); sections that are only air are skipped in one step; for every block state from top to bottom, at the first position where `isEdgeOccluded(stateAbove, stateHere)` the lowest source Y is the Y of the cell above (the first cell with full sky light); if none is found it is `minY`. The stored value is `max(found, minY)`.

**Update on block change** (`update(chunk, x, y, z)` with local x, z and world y, returns whether the table changed): `ny = y + 1`; when `ny < current` return false. Test the edge between the cell above `(x, y+1, z)` and the changed cell: if occluded and `y+1 > current`, set the entry to `y+1`, return true; if not occluded and `y+1 == current`, set the entry to `findLowestSourceBelow(changed cell)` (walk down from the changed cell until an occluded edge; the result is the Y of the cell above that edge, or `minY`), return true. Then test the edge between the changed cell and the cell below `(x, y−1, z)` the same way, with the changed cell as "above". (The walk and the edge test may read the cell at level min Y - 1, below the world. `LevelChunk.getBlockState` returns plain air for a Y whose section index is out of range; `ProtoChunk.getBlockState` returns `minecraft:void_air` for a Y outside the build height. Neither occludes: void air is the air-class block, its dampening and shapes being assumed equal to air's (inferred).)

### 5.4 Worked examples

1. **Torch in open air** (emission 14, all neighbours air, dampening 0, `isEmptyShape` true for all): the torch cell stores 14; each of the six neighbours stores 13 (`14 − 1`), each of their further neighbours 12, and so on to 1 at distance 13; level at Manhattan distance `d` is `14 − d` while positive.
2. **Removing it**: `checkNode` finds `e = 0 < s = 14`: stores 0 and queues a decrease at level 14; each neighbour with level ≤ 13 is cleared and queued, and so on; any neighbour whose level is ≥ the decreasing wave is instead queued as an `increaseOnlyOneDirection` back toward the cleared cell, which re-fills the hole from a second source.
3. **Stone cell** (dampening 15) next to a level-14 cell: `newLevel = 14 − 15 < 0` so it is not stored; light does not enter.
4. **Leaves** (dampening 1, opacity 1): a level-14 cell next to leaves gives the leaves 13 like air (`getOpacity = max(1, 1)`), but leaves are a sky-source terminator (dampening ≠ 0, 5.3).
5. **Sky column**: open ground with lowest source Y = 64: cells at Y ≥ 64 read 15; the cell at Y = 63 below a stone block at 63 is not lit directly; cells beside a source column at the same Y receive 14, and so on.

## 6. Section storage (`LayerLightSectionStorage`)

### 6.1 State per section

A byte per section position in `sectionStates`: bit 5 (32) = "has data" (the section is a non-air block section), bits 0–4 = number of neighbouring sections (of the 26 around it) that have data, 0 to 26. A section **stores light** (`storingLightForSection`, the test both engines call) when the **working map holds a layer for it** (`getDataLayer(pos, true) != null`), not when the state byte is non-zero. The layer is created at initialise (6.2) and removed in `markNewInconsistencies` (6.3). In steady state the two agree (a non-zero state byte means data in the section or one of its 26 neighbours). Between `updateSectionStatus` and the end of the next `runLightUpdates` they can disagree: a section whose byte went to 0 keeps its layer until the pending-removal set is processed. Wherever this document says "stores light" it means layer presence in the working map. `SectionType` labels: EMPTY (state 0), LIGHT_ONLY (neighbours only), LIGHT_AND_DATA (debug names "2", "1", "0").

### 6.2 `updateSectionStatus(sectionPos, sectionIsEmpty)`

1. `hasData = !sectionIsEmpty`; compute the new state byte with that bit. If unchanged, stop.
2. Store the new byte (removing the entry when it is 0). If an entry appeared where there was none, **initialise** the section (below); if an entry was removed, **remove** it (below).
3. Add `−1` (section became empty) or `+1` (became non-empty) to the neighbour count of each of the 26 neighbouring sections (their state bytes are created or updated through the same step 2 logic).

**Initialise** (unless the section was in the pending-removal set, in which case it is just taken out of that set): create its layer (6.6), mark it changed, call the engine's node-added hook (sky: updates the top-section table), mark the section and its 26 neighbours as affected (6.4), set `hasInconsistencies`.
**Remove**: add it to the pending-removal set and set `hasInconsistencies`.

### 6.3 Pending data and inconsistencies (`markNewInconsistencies`)

Runs at the end of `runLightUpdates` when `hasInconsistencies` is set (and clears it):
1. For each section in the pending-removal set: take any queued layer for it out of the queue, remove its layer from the working map; if the section's column is marked "retain" (6.5), put the queued layer (or, if none, the removed layer) back in the queue.
2. For each pending-removal section call the node-removed hook (sky: only when the column's table value equals the removed section Y + 1, that is the removed section was the highest storing one: starting at the removed section walk down one section at a time while the section does not store light and `hasLightDataAtOrBelow` holds; if the section reached stores light, the table value becomes its Y + 1, else the column entry is dropped; see 6.8) and mark it changed; clear the set.
3. For each queued layer whose section stores light: if the working map's layer is not that object, install it and mark the section changed; remove it from the queue either way. A queued layer for a section that does not store light stays queued.

`queueSectionData(pos, layer)`: a non-null layer is stored in the queue and sets `hasInconsistencies`; a null layer removes the queued entry.

### 6.4 Double buffering and notification

The storage keeps a working map (`updatingSectionData`) and a published map (`visibleSectionData`, read by `getLightValue`-style queries without the update flag). `swapSectionMap` (end of every `runLightUpdates`): if any section changed, publish a copy of the working map (copy-on-write, a layer is copied the first time it is written, `getDataLayerToWrite` / `setStoredLevel`) and clear the changed set; then, for every section in the "affected by light updates" set, call the chunk source's `onLightUpdate(layer, sectionPos)` and clear the set. On the client `onLightUpdate` marks that render section dirty (12). Membership of the affected set has two sources. (a) `setStoredLevel` (every written level) adds, through `SectionPos.aroundAndAtBlockPos`, the section containing the cell plus the sections containing the cells at offsets of -1 and +1 on each axis (a section is added once): an interior cell marks only its own section; a cell on a section face also marks the one section across that face, on an edge the three sections around it, on a corner the seven. (b) Only initialising a section (6.2) marks the full 3x3x3 block of 27 sections (`markSectionAndNeighborsAsAffected`). The client's render-dirty marking therefore follows (a) and (b), not "26 neighbours of every write".

### 6.5 Column flags

- **Light enabled** (`setLightEnabled(columnZeroNode, flag)`) is a per-column set `columnsWithSources`. Emission is ignored (block) and sky sources are ignored (sky) for a section whose column is not enabled; `LevelLightEngine.lightOnInColumn` has three cases, in this order: (1) the block engine is absent: true, whatever the sky engine says; (2) the block engine is present and its column is not enabled: false, even when the sky engine is absent; (3) otherwise true when the sky engine is absent or has the column enabled, else false.
- **Retain data** (`retainData(columnZeroNode, flag)`): while set, queued data for sections of that column survives removal (6.3 step 1).

### 6.6 Creating a layer

- Block light: the queued layer for the section when one exists, else an all-zero layer.
- Sky light: the queued layer when one exists. Else, with `top` = the column's top stored section Y (`top` is the table value of 6.8, highest storing section + 1; the table default is `currentLowestY`, meaning "no entry"): if there is no entry or the section is at or above `top`, an all-15 layer when the column has light enabled, else all-zero; otherwise find the first section above that has a layer and take its first Y row (the first 128 bytes, which are 256 nibbles for the (x, z) pairs of Y row 0) and repeat it 16 times (16 copies of 128 bytes) to fill the new 2048-byte layer, so every Y row equals that row; a source layer that is definitely homogeneous is copied as it is.

### 6.7 Reading a level

- Block light `getLightValue(pos)`: the published layer's nibble, 0 when the section has no layer.
- Sky light `getLightValue(pos)`: let `top` be the column's top section from the published table. If there is no entry or the section Y is at or above `top`: 15 (when queried through the working map's variant, 15 only when the column has light enabled, else 0). Otherwise the section's layer nibble; when the section has no layer, move up one section at a time until a layer is found (reading the bottom Y row, x and z unchanged) and return 15 if the position passes `top` first.
- The engines' internal `getStoredLevel` always reads the working map.

### 6.8 Sky storage predicates (top table and lowest section)

All three are on the working map and are read by the sky engine (5.2, 6.3).

| Name | Definition |
|---|---|
| `currentLowestY` (`getBottomSectionY`) | The lowest section Y ever initialised in the sky storage. Starts at `Integer.MAX_VALUE`; `onNodeAdded(section)` lowers it to the section's Y when that is lower, and at the same time sets it as the default return value of the top table. It is never raised when a section is removed. |
| top table value (`getTopSectionY(column)`) | (highest section Y of the column that stores light) + 1. `onNodeAdded(section Y = y)` raises the column's value to `y + 1` when it is lower (a column without entry reads `currentLowestY`, which is always lower). `onNodeRemoved` rewrites it as described in 6.3 step 2. "No entry" is recognised as value == `currentLowestY`. Reads at or above the value give 15 (6.7). |
| `hasLightDataAtOrBelow(y)` | `y >= currentLowestY`. |
| `isAboveData(section)` | True when the column has no entry (value == `currentLowestY`) or the section Y >= the value. |

Worked example: sections 1 and 2 initialise in an empty storage: `currentLowestY` = 1, the column value is 3 after the second. Removing section 2 (nothing at 2 stores light afterwards, section 1 does) rewrites the value to 2; removing section 1 as well walks down while `y >= currentLowestY`, finds nothing storing light and drops the entry, while `currentLowestY` stays 1.

## 7. Block-state overrides

`getLightDampening` default (24 section 5.2): 15 when `solidRender` is true, else 0 when `propagatesSkylightDown`, else 1. `solidRender` is whether the state's **occlusion shape** is a full block, and the occlusion shape is the empty shape when `canOcclude` is false (`noOcclusion()`). A non-occluding block with a full collision shape therefore gets dampening 0 or 1, never 15. `propagatesSkylightDown` default tests a different shape: the block's `getShape` evaluated against an empty block getter at position zero (not the occlusion shape) must not be a full block, and the fluid state must be empty. `useShapeForLightOcclusion` default: false.

| Class | Override |
|---|---|
| `LeavesBlock` | dampening 1 |
| `TintedGlassBlock` | dampening 15, propagatesSkylightDown false |
| `LiquidBlock`, `PipeBlock`, `ShulkerBoxBlock` | propagatesSkylightDown false |
| `BambooStalkBlock`, `HangingMossBlock`, `MossyCarpetBlock`, `TransparentBlock`, `VineBlock` | propagatesSkylightDown true |
| `BarrierBlock`, `GlowLichenBlock`, `LightBlock`, `VegetationBlock` | propagatesSkylightDown = the fluid is empty |
| `CrossCollisionBlock`, `WallBlock` | propagatesSkylightDown = not waterlogged |
| `SlabBlock` | useShapeForLightOcclusion = type is not DOUBLE |
| `StairBlock`, `SnowLayerBlock`, `DaylightDetectorBlock`, `EnchantingTableBlock`, `EndPortalFrameBlock`, `FarmlandBlock`, `LecternBlock`, `PathBlock`, `SculkSensorBlock`, `SculkShriekerBlock`, `ShelfBlock`, `StonecutterBlock`, `PistonHeadBlock` | useShapeForLightOcclusion true |
| `PistonBaseBlock` | useShapeForLightOcclusion = the `extended` property |

## 8. When the engine is fed

### 8.1 Block changes (`LevelChunk.setBlockState`, `ProtoChunk.setBlockState`)

Order inside `LevelChunk.setBlockState`, after the section accepted the new state (29 section 2 holds the rest of the method): (a) update the four heightmaps; (b) if the section's only-air status changed, `updateSectionStatus(pos, nowOnlyAir)` on the light engine and tell the chunk source `onSectionEmptinessChanged(sectionX, sectionY, sectionZ, nowOnlyAir)`; (c) if `hasDifferentLightProperties(old, new)`: `ChunkSkyLightSources.update(chunk, localX, y, localZ)` then `checkBlock(pos)` on the light engine. `ProtoChunk.setBlockState` (read in full) differs: it returns early for a Y outside the build height (returning void air) and for an air write into an all-air section; after the section accepted the state it does the light work only when the chunk's status is at or after `INITIALIZE_LIGHT`, calling in this order (a) `updateSectionStatus(pos, nowOnlyAir)` when the section's only-air status changed, (b) when `hasDifferentLightProperties(old, new)`: `ChunkSkyLightSources.update` then `checkBlock(pos)`; there is no null test on the light engine; the heightmaps are updated **after** the light calls, the reverse of `LevelChunk`, and there is no `onSectionEmptinessChanged` call. A block change that does not alter light properties does not touch the engine. A write of air into an all-air section, and a write of the identical state, return before any of this.

### 8.2 Client

- **Chunk with light packet** (`handleLevelChunkWithLight`): the chunk is built first (its sky sources are filled with `fillFrom` at the end of `replaceWithPacketData`), then a task is **queued** that (1) applies the light data (below) with the "mark dirty" flag false, (2) looks up the chunk and, if present, runs `enableChunkLight`: `updateSectionStatus(sectionPos, section.hasOnlyAir())` for every block section, then marks the section range around the chunk dirty for rendering.
- **Light update packet** (`handleLightUpdatePacket`): the same apply step with the mark-dirty flag true (each updated section and its neighbours are marked dirty).
- **Apply light data**: sky layer list first, then block layer list. For each light section index `i` from 0 to count − 1 (section Y = min light section + i): if bit `i` of the mask is set, queue a `DataLayer` built from a clone of the next array; else if bit `i` of the empty mask is set, queue an all-zero `DataLayer`; else nothing. When all lists are read, `setLightEnabled(chunk, true)`. The queued data are consumed by `markNewInconsistencies` (6.3) at the next engine run.
- **Forget chunk** (`handleForgetLevelChunk`): the chunk is dropped from the cache and a task is queued: `setLightEnabled(false)`, queue `null` data for every light section of both layers (this clears queued data), and `updateSectionStatus(sectionPos, true)` for every block section (all marked empty).
- **Chunk unload** (`ClientLevel.unload`): `setLightEnabled(chunkPos, false)`.
- **Task queue**: `ClientLevel.queueLightUpdate` appends to a deque; `ClientLevel.update` (no arguments) calls `pollLightUpdates` and then `runLightUpdates` on the chunk source's light engine. It is called from `Minecraft.renderFrame`, once per rendered frame, only when the game load is finished, the method's boolean argument is true and a level exists; it is not tied to the game tick. `pollLightUpdates` itself only runs queued tasks and does not run the engine: with `n` queued, it runs `max(10, n / 10)` tasks when `n < 1000`, else all `n` (stopping early when the deque empties). Any lag in game ticks between a packet and its light work is not read (inferred to depend on the frame rate).
- The client does not call `propagateLightSources`: light for a chunk comes from the packet; the engine only repairs it after block changes (8.1) and, for neighbouring changes, through `checkBlock`.

### 8.3 Server (`ThreadedLevelLightEngine`)

Every call (`checkBlock`, `updateSectionStatus`, `setLightEnabled`, `propagateLightSources`, `queueSectionData`, `retainData`, `updateChunkStatus`) becomes a **PRE_UPDATE** task submitted through the chunk task dispatcher at the chunk's queue level; the position is copied first (`BlockPos.immutable`). `tryScheduleUpdate` schedules `runUpdate` when tasks are pending or `hasLightWork` and no run is scheduled. `runUpdate` processes at most **1000** tasks (`DEFAULT_BATCH_SIZE`): (1) run those PRE_UPDATE tasks, (2) `LevelLightEngine.runLightUpdates` once, (3) run the POST_UPDATE tasks of the same batch and remove all processed tasks. `runLightUpdates` called directly throws (it is run on its own thread).

Chunk generation stages (`ChunkStatusTasks`, statuses `INITIALIZE_LIGHT` then `LIGHT`):
- `initializeLight(chunk)`: `initializeLightSources` (fill the chunk's sky source table), attach the engine to the proto chunk, `lighted` = (the chunk's **persisted** status (`getPersistedStatus`) is at or after `LIGHT` and `isLightCorrect`); then a PRE_UPDATE task runs `updateSectionStatus(pos, false)` for every non-air section, and a POST_UPDATE task (result of the future) runs `setLightEnabled(chunkPos, lighted)` and `retainData(chunkPos, false)`.
- `light(chunk)`: `lighted` as above. `lightChunk`: `setLightCorrect(false)` first; PRE_UPDATE task: `propagateLightSources(chunkPos)` **only when not `lighted`** (an already lit chunk keeps its stored levels); POST_UPDATE task: `setLightCorrect(true)`.
- `updateChunkStatus(chunkPos)` (chunk leaving the lighting stage): `retainData(false)`, `setLightEnabled(false)`, queue null data for every light section of both layers, `updateSectionStatus(sectionPos, true)` for every block section.

### 8.4 Loading stored light (`SerializableChunkData`)

When a chunk's saved sections are turned back into a chunk, the loader walks the saved sections. For each it checks whether a block-light layer is stored and whether a sky-light layer is stored **and the dimension has sky light** (a stored sky layer in a dimension without `has_skylight` is ignored). For a section with at least one of the two: on the first such section of the chunk it calls `retainData(chunkPos, true)` once, then it calls `queueSectionData(BLOCK, sectionPos, layer)` and/or `queueSectionData(SKY, sectionPos, layer)` for the layers present. The queued layers are installed by `markNewInconsistencies` (6.3 step 3) once `updateSectionStatus` has made the section store light; the retain flag is cleared in the generation stage of 8.3 (`initializeLight`, POST_UPDATE `retainData(chunkPos, false)`). Whether the chunk then counts as lit is the `isLightOn` flag of 07 section 5.

The server's packaging of light into packets (which sections, masks and empty bits) is 06 section 7, the changed-section tracking and the Light Update broadcast are 29 section 2.3 and the passage on `blockChanged`.

## 9. Summary for an implementer

1. Keep, per chunk column, a sky-source table (5.3), and per layer a section store (6) with the neighbour-count rule.
2. Block change: apply the section emptiness and light-property hooks of 8.1; run the check, the decrease queue, then the increase queue (4).
3. Block light at a cell is the maximum over sources of `emission − Σ opacity` along a path, never below 0, with face-shape occlusion applied where shapes are in use; sky light is 15 at and above the column's lowest source and spreads like block light below it.
4. Send light as in 06 section 7: a layer with all 4096 values 0 uses the empty mask, anything else the 2048-byte array.

## 10. Validation

Checks an implementation can run against sections 5 to 8 (each follows from the rules above, not from running the artifact):

| # | Setup | Expected |
|---|---|---|
| 1 | Torch (emission 14) in open air, nothing else | Level `14 - d` at Manhattan distance `d` for `d` from 0 to 13; 0 beyond (5.4 example 1). |
| 2 | Same, then remove the torch | Every cell returns to 0 after one decrease pass and one increase pass; no stale level remains (5.4 example 2). |
| 3 | Two torches 4 cells apart, remove one | Cells between them settle at the remaining torch's `14 - d`; none keep the removed torch's value. |
| 4 | Level-14 cell beside a dampening-15 block | The block cell stays 0 (5.4 example 3). |
| 5 | Open column with lowest source Y = 64, no block change | Cells at Y >= 64 in the column read 15; `canSeeSky` is true exactly there. |
| 6 | Place an opaque block at the top of a sky column, then break it | Source Y rises to the block's Y + 1, cells below fall off by the spreading rule, and after breaking the table and levels equal the original. |
| 7 | Dimension with `has_skylight` false | No sky layer: sky reads 0, `canSeeSky` false, sky arrays absent from packets (06 section 7). |
| 8 | Chunk packet with light, then a block change next to the chunk edge | The edge cells of the unloaded neighbour are treated as in 2.2 and the engine does not crash on missing sections. |
| 9 | Layer with all 4096 values 0 | Sent through the empty mask, not as a 2048-byte array (9 item 4). |

## Open questions

1. **Callers' choice of `darken` for `getRawBrightness`.** The one-argument `getMaxLocalRawBrightness` uses `skyDarken` (33 section 3.5) and `CropBlock` uses 0 (1.2); the many other callers of the two-argument forms were not enumerated. Searched: `LevelReader`, `BlockAndLightGetter`, `Monster`, `CropBlock`.
2. **Dampening and shapes of `minecraft:void_air`.** Assumed equal to air's (5.3, inferred); the `VoidAir` block class was not read.
3. **Disk side of light.** How `isLightOn` is written and how the saved layers are produced is in 07 section 5 (not re-read here); 8.4 covers only the load path into the engine.
4. **`LeveledPriorityQueue`, `DynamicGraphMinFixedPoint`, `SpatialLongSet`** exist in the jar and were not read; the engines read use only the two FIFO queues and a hash set.
5. **Block-state emission and occlusion values per block** are in 24 and 25 (registry documents); this document does not repeat them.
6. **Thresholds of the callers of `getLightLevelDependentMagicValue` / `getPathfindingCostFromLightLevels`.** Calls confirmed in `Giant`, `Enderman`, `Blaze`, `Guardian`, `Vex`, `SulfurCube`, `Spider$SpiderAttackGoal` and `Spider$SpiderTargetGoal` (the comparison was read only for the attack goal, against 0.5); `Entity`, `Mob`, `Animal`, `Monster`, `Turtle`, `MushroomCow`, `MagmaCube`, `EyeOfEnder`, `ShulkerBullet`, `AbstractHurtingProjectile` were located by constant-pool search but not read. Owning document for the mob ones: 18 (walk-target scoring); for the projectile and entity ones: the entity documents (41, 44).
7. **Client lightmap input packing** (how sky and block levels are combined into the lightmap lookup, `LightCoordsUtil`, `LightmapRenderStateExtractor`) is the subject of 12 section 1 and was not re-read; this document gives only the engine side.
8. **Daylight detector and redstone block behaviour** (1.2) was read only for its light inputs; the owning document for redstone components was not found among 00 to 47.
9. **Thresholds of the block users beyond `CropBlock`**: `SaplingBlock`, `FireflyBushBlock`, `SpreadingSnowyBlock` and `FrostedIceBlock` were confirmed to call the brightness queries (1.2) but their comparison values were not read; stems, fire and other light-dependent random ticks were not enumerated. Per-block behaviour: 29b.
10. (Closed.) `Level.canHaveWeather` was read in the second pass (1.1).
11. (Closed.) The cross-references now resolve: 18 section 6.8, 20 sections 12 and 20.5, 13 `light_levels`, 29b parts 1 and 2 (each cited with the document number and section).
12. **`checkMobSpawnRules`** (called by every `Monster` spawn rule in 1.2) and the sets of entity types using each of the three monster rules were not read here.
13. **Entity shadow strength and `DebugScreenOverlay`.** `EntityRenderer`'s shadow strength inputs other than the `0.5` factor and the clamp were not read, and `DebugScreenOverlay` showed no direct brightness call in the pass; the light debug entry is in 13. Also not read: the non-light conditions of `Bat` and `Slime` spawn rules (the swamp branch of the latter).
