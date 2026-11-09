# 36 Structures, part 4: scattered and small overworld structures (desert pyramid, jungle temple, swamp hut, igloo, buried treasure, ruined portal, nether fossil)

| Item | Value |
|---|---|
| Covers | The seven code-defined single-piece or small-piece structures of the overworld family and the one Nether structure that belongs with them: `desert_pyramid` (`DesertPyramidStructure`, `DesertPyramidPiece`: geometry, the four trap chests, the cellar, the collapsed roof, the suspicious sand and its archaeology loot), `jungle_temple` (registered as `jungle_pyramid`; `JungleTempleStructure`, `JungleTemplePiece`: geometry, moss selector, the two dispenser traps, the lever puzzle, both chests), `swamp_hut` (`SwampHutStructure`, `SwampHutPiece`: geometry, witch and cat), `igloo` (`IglooStructure`, `IglooPieces`, `IglooPiece`: top, optional basement with ladder shaft, chest marker), `buried_treasure` (`BuriedTreasureStructure`, `BuriedTreasurePieces`: the column search and the chest), `ruined_portal` (`RuinedPortalStructure`, `RuinedPortalPiece`: setups, the vertical placements, `findSuitableY`, processors, mossiness, lava and gold replacement, netherrack spread, drip columns, vines and leaves, blackstone replacement), `nether_fossil` (`NetherFossilStructure`, `NetherFossilPieces`: point search, template pick, dried ghast). Loot table ids and seeds of every chest, dispenser and brushable block of these structures. The shared machinery these structures use and that no earlier document specifies: the `ScatteredFeaturePiece` frame (orientation, world coordinate mapping, `placeBlock`, the box fillers, `fillColumnDown`, chest and dispenser creation, `reorient`, the two ground-height adjusters), the template piece frame (`TemplateStructurePiece`, `StructureTemplate` placement order, transform, bounding box, entity placement), and the processors and rule tests these pieces use (`BlockIgnoreProcessor`, `RuleProcessor`, `BlockAgeProcessor`, `ProtectedBlockProcessor`, `LavaSubmergedBlockProcessor`, `BlackstoneReplaceProcessor`, `RandomBlockMatchTest`, `BlockMatchTest`). |
| Does not cover | Data rows: the structure JSON (`worldgen/structure/*.json`: biomes tag, step, spawn overrides, terrain adaptation, ruined portal setups), the structure sets (`worldgen/structure_set/*.json`), the loot tables, the tags, the structure NBT (`structure/igloo/*`, `structure/ruined_portal/*`, `structure/nether_fossils/*`); the extraction tool copies them (22, 23). Only the few numbers an engine needs to be tested are quoted, marked as data. The general structure engine: the structure registry, `StructureStart` bookkeeping, references, the biome check beyond what these structures call, the jigsaw expander, pools, the beardifier (the sibling parts of document 36: 36-1 model, placement and starts; 36-2 templates and processors; 36-3 jigsaw assembly; this document states only what the seven structures add and points to those parts for the shared machinery, sections 2.3 to 2.8). The other structures (villages, mineshafts, strongholds, monuments, mansions, ocean ruins, shipwrecks, ancient cities, trial chambers, outposts, end cities, nether fortress and bastion: other parts of 36 and 37 section 6). The overworld `fossil` feature (a placed feature, not a structure: 35-6 section 10). Block, item and entity behaviour of the blocks the pieces place (24, 29, 30, 31, 45). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.level.levelgen.structure.structures.*` (the 7 structures, 7 piece classes: `DesertPyramidPiece`, `JungleTemplePiece`, `SwampHutPiece`, `IglooPieces$IglooPiece`, `BuriedTreasurePieces$BuriedTreasurePiece`, `RuinedPortalPiece`, `NetherFossilPieces$NetherFossilPiece`, plus their nested helpers `MossStoneSelector`, `RuinedPortalPiece$Properties`, `$VerticalPlacement`, `RuinedPortalStructure$Setup`, which are not pieces), `StructurePiece`, `ScatteredFeaturePiece`, `TemplateStructurePiece`, `Structure`, `Structure$GenerationContext`, `StructureStart`, `SinglePieceStructure`, `BoundingBox`, `templatesystem.StructureTemplate`, `StructurePlaceSettings`, the processor and rule-test classes named above, `placement.AbstractSpreadingStructurePlacement` and `RandomSpreadStructurePlacement`, `WorldgenRandom`, `Mth`, `BlockPos`, `Direction`, `Rotation`, `Mirror`, `Util`, `Heightmap$Types`, `LevelReader.getHeightmapPos`, `BuiltInLootTables`, `BrushableBlockEntity`, `ChunkGenerator.applyBiomeDecoration`, and of the JSON data and structure NBT (headers only: size, palette size, block entities, entities) under `data/minecraft/` in the jar. To read the long block-placement methods a throwaway stack-summarising script turned the bytecode into one line per call; the script is not kept. No execution of the artifact. A value is read from the artifact unless marked "(inferred)", "(computed)" or "(recalled, not verified)"; every such mark is listed in the Open questions. "(computed)" values come from a scratch implementation of this document's own rules (a Java-LCG and `Mth.getSeed` reimplementation, checked against `Mth.getSeed(1, 2, 3) = -33674130277896` of 10 section 2.4); they are test vectors, not artifact output. |
| Round | RS20 (GAP-12b, GAP-18 of [../design/README.md](../design/README.md), Part 6 row RS20), part 4 |
| Operator decisions | Standard Minecraft content is the target; a COBOL tool extracts the vanilla resource pack and data pack from the user's jar, so data rows are not tabulated and this document specifies the engines and the code-defined geometry completely (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"). |

Class names in backticks say where a fact was read; they are not the design. References use "NN section M" for other documents
and "section M" for this one. Coordinates are block coordinates, `y` is vertical (overworld `minY = -64`, sea level 63, 10 section 5).
"Local" coordinates `(x, y, z)` are the piece frame of section 3 (before the world mapping). Block names are those of 24; a state
property in brackets (`stairs[facing=north]`) is set on the default state. All Java-style integer division truncates toward zero
unless said otherwise (every operand in these structures is non-negative where it matters). `nextInt(n)` is the exclusive-bound
draw of the random source named at that point; `rbi(a, b)` is `Mth.randomBetweenInclusive` = `nextInt(b - a + 1) + a`.

---

## 1. Map of the family

Everything in the first table except the second column was read from code; the "Data" columns are data rows quoted only so that the
code can be tested (the tool extracts them).

| Structure id (registry) | Structure class | Piece class (piece id) | Start point rule | Step (data) | Structure set: spacing / separation / salt (data) |
|---|---|---|---|---|---|
| `desert_pyramid` | `DesertPyramidStructure` (a `SinglePieceStructure`, 21 x 21) | `DesertPyramidPiece` (`TeDP`) | section 3.1 | `surface_structures` | `desert_pyramids`: 32 / 8 / 14357617 |
| `jungle_pyramid` (type `jungle_temple`) | `JungleTempleStructure` (`SinglePieceStructure`, 12 x 15) | `JungleTemplePiece` (`TeJP`) | section 3.1 | `surface_structures` | `jungle_temples`: 32 / 8 / 14357619 |
| `swamp_hut` | `SwampHutStructure` | `SwampHutPiece` (`TeSH`) | section 5.1 | `surface_structures` | `swamp_huts`: 32 / 8 / 14357620 |
| `igloo` | `IglooStructure` | `IglooPieces$IglooPiece` (`Iglu`), 1 piece or 5 to 12 pieces | section 6.1 | `surface_structures` | `igloos`: 32 / 8 / 14357618 |
| `buried_treasure` | `BuriedTreasureStructure` | `BuriedTreasurePieces$BuriedTreasurePiece` (`BTP`) | section 7.1 | `underground_structures` | `buried_treasures`: 1 / 0 / 0, frequency 0.01, method `legacy_type_2`, locate offset (9, 0, 9) |
| `ruined_portal` and six variants (`_desert`, `_jungle`, `_swamp`, `_mountain`, `_ocean`, `_nether`) | `RuinedPortalStructure` | `RuinedPortalPiece` (`RUPO`) | section 8.2 | `surface_structures` | `ruined_portals`: 40 / 15 / 34222645, the seven structures with weight 1 each |
| `nether_fossil` | `NetherFossilStructure` | `NetherFossilPieces$NetherFossilPiece` (`NeFos`) | section 9.1 | `underground_decoration`, terrain adaptation `beard_thin` | `nether_fossils`: 2 / 1 / 14357921 |

Notes. (a) The jungle temple's registry key is `jungle_pyramid` but its structure type is `jungle_temple` (`worldgen/structure/jungle_pyramid.json`
has `"type": "minecraft:jungle_temple"`); the loot tables keep the name `jungle_temple`. (b) The piece ids are the keys of the registry `structure_piece`
(46); they appear in saved pieces (`id`). (c) The overworld `fossil` is a feature (35-6 section 10) and is not part of this document.
(d) `swamp_hut` carries `spawn_overrides` (data: monster `witch`, creature `cat`, both with bounding box `piece`); their semantics
are 44-2 section 8, the one-shot spawns at generation are section 5.4. (e) A data pack `datapacks/trade_rebalance` inside the jar has a `pack.mcmeta` that enables the feature flag `minecraft:trade_rebalance` (pack format 121) and overrides five loot tables: `chests/abandoned_mineshaft`, `chests/ancient_city`, `chests/desert_pyramid`, `chests/jungle_temple` and `chests/pillager_outpost` (it also holds villager_trade and enchantment trade tags). The overrides apply only in worlds where that feature flag is on; the tables of this document are the base ones (Open question 3).

---

## 2. Shared machinery

### 2.1 Random sources used

| Source | Definition | Used by |
|---|---|---|
| The start random | `WorldgenRandom` over a Java-LCG (`LegacyRandomSource`, 10 section 2.6), seeded by `setLargeFeatureSeed(worldSeed, chunkX, chunkZ)` (`setSeed(s)`; `a = nextLong()`; `b = nextLong()`; `setSeed(chunkX * a xor chunkZ * b xor s)`, 64-bit products, 11 section 7 for the same formula) of the **start chunk** (`Structure$GenerationContext.makeRandom`) | all `findGenerationPoint` and piece constructors (sections 3.1, 5.1, 6.1, 8.2, 9.1) |
| The piece random | the `RandomSource` argument of `postProcess`: the decoration `WorldgenRandom` (a Xoroshiro-backed `WorldgenRandom` seeded by `setFeatureSeed(decorationSeed, structureIndexInStep, step)` = `seed = decorationSeed + index + 10000 * step`; `ChunkGenerator.applyBiomeDecoration`), re-seeded before each structure of each step. `decorationSeed` is the value of `setDecorationSeed(worldSeed, chunkOriginX, chunkOriginZ)` of the chunk being decorated; `index` is the position of the structure within its step and increments for every structure of the step whether or not it has a start in this chunk; the structures are grouped by the ordinal of their step. How the within-step order comes about (registry listing order as 36-1 section 8 states it; id order or data-load order is not traced here) is Open question 16. The same random object is passed to every piece of one start in turn | `postProcess` (sections 3.2, 4, 6.2, 7.2, 8.4, 9.2) |
| The level random | `WorldGenLevel.getRandom()` (the world-generation region's random) | desert cellar (section 3.4) |
| The derived position random | `RandomSource.createThreadLocalInstance(worldSeed)` is a Java-LCG (`SingleThreadedRandomSource`, same LCG as 10 section 2.6); `.forkPositional()` draws **one** `nextLong()` `S` from it and builds a legacy positional factory; `.at(pos)` is a new Java-LCG source seeded with `Mth.getSeed(pos.x, pos.y, pos.z) xor S` (the seed then goes through the usual LCG scrambling `(seed xor 0x5DEECE66D) and (2^48 - 1)`; 10 section 2.4 for `getSeed`). `S` depends only on the world seed, so the result is a pure function of `(worldSeed, pos)` | desert roof position and suspicious sand pick (section 3.5), nether fossil dried ghast (section 9.3) |
| The rule-processor random | `RandomSource.create(Mth.getSeed(worldPos))`: a new Java-LCG source seeded from the block's world position, one per block per `RuleProcessor` (`RandomSource.create(long)` is a `LegacyRandomSource`) | `RuleProcessor` (section 2.7) |
| The block-age random | `StructurePlaceSettings.getRandom(worldPos)`: the settings' own random when set, else `RandomSource.create(Mth.getSeed(worldPos))` (the first branch, a null position, uses the clock; not reached by these pieces). The settings of these pieces never set a random | `BlockAgeProcessor` (section 2.7) |

Seeds stored in block entities: a chest or dispenser that receives a loot table gets the seed `piece random .nextLong()` (one draw per container actually created);
a container inside a template (section 2.6) gets `nextLong()` of the same piece random during template placement; suspicious sand gets `BlockPos.asLong()` of its position
(the packed long of 31 `BlockPos` encoding, read from the static initialiser: `y` at offset 0 in 12 bits, `z` at offset 12 in 26 bits, `x` at offset 12 + 26 = 38 in 26 bits, each masked to its field width; `PACKED_HORIZONTAL_LENGTH` = 1 + 25 = 26, `PACKED_Y_LENGTH` = 64 - 2 * 26 = 12).

### 2.2 Life of a structure start (what these structures rely on)

1. `Structure.generate` builds a `GenerationContext` (start random of 2.1, chunk position, the chunk generator, the biome resolver and the
   structure's biome predicate) and calls `findValidGenerationPoint` = the structure's `findGenerationPoint` filtered by the biome check
   (`isValidBiome`: the noise biome at `QuartPos.fromBlock` of the stub position, tested against the structure's `biomes` holder set). A start
   is created only when the stub exists, the biome passes, and the piece builder holds at least one piece.
2. `Structure.onTopOfChunkCenter(ctx, heightmap, builder)`: if `couldValidBiomeExistOnTopOfChunkCenter` is false (no cell of the chunk
   centre's column, from `minY - 1` to `maxY`, has a valid noise biome) the result is empty; otherwise
   `onTopOfChunkCenterWithoutBiomeCheck` takes the chunk centre column `(minBlockX + 8, minBlockZ + 8)` (`getMiddleBlockX/Z`) and the stub
   position `(x, firstOccupiedHeight, z)`, where `firstOccupiedHeight = getBaseHeight(x, z, heightmap) - 1` of the noise generator (the y of the top block
   that the heightmap's predicate accepts in the base terrain, 10); the supplied consumer adds the pieces. The stub position is used only for the biome
   check and by the caller; the pieces do not use it unless stated.
3. `getLowestY(ctx, width, depth)`: the minimum of `getFirstOccupiedHeight(WORLD_SURFACE_WG)` at the four corners `(minBlockX, minBlockZ)`,
   `(minBlockX, minBlockZ + depth)`, `(minBlockX + width, minBlockZ)`, `(minBlockX + width, minBlockZ + depth)` (offsets are the full width and depth, not width - 1).
4. `StructureStart.placeInChunk(level, structureManager, generator, random, writeBox, chunkPos)` (called by `applyBiomeDecoration`, once for every
   chunk that is decorated and that the structure reaches; `writeBox` = the chunk's writable area): `pivot` = `(centerX of the first piece's box, minY of that box, centerZ)`;
   for every piece **in piece order** whose box intersects `writeBox`, call `postProcess(level, structureManager, generator, random, writeBox, chunkPos, pivot)`;
   then call `Structure.afterPlace(level, structureManager, generator, random, writeBox, chunkPos, piecesContainer)` (empty in the base class; the desert pyramid overrides it, section 3.5).
   So a piece is post-processed once per decorated chunk its box touches, and **each call regenerates the whole piece clipped to `writeBox`**; this is why
   every piece keeps "already placed" flags for its containers.
5. `getCenter()` of a `BoundingBox` is `(minX + (maxX - minX + 1) / 2, minY + (maxY - minY + 1) / 2, minZ + (maxZ - minZ + 1) / 2)`; `isInside` is inclusive on all six
   faces; `intersects` is the closed-interval overlap test; `getXSpan = maxX - minX + 1` (likewise Y, Z); `encapsulate(b)` mutates the box to the union and returns it;
   `fromCorners(a, b)` takes the per-axis min and max; `BoundingBox(BlockPos)` is the one-block box.
6. `SinglePieceStructure(constructor, width, depth)` (desert pyramid and jungle temple): `findGenerationPoint` is empty when `couldValidBiomeExistOnTopOfChunkCenter` is false, or
   when `getLowestY(ctx, width, depth) < seaLevel` (63); otherwise `onTopOfChunkCenterWithoutBiomeCheck(ctx, WORLD_SURFACE_WG, ...)` whose consumer adds **one** piece
   `constructor(startRandom, chunk.minBlockX, chunk.minBlockZ)`.
7. Placement (which chunks hold a start; data parameters in section 1): `random_spread` with `spacing`, `separation`, `salt`, `spread_type` (default `linear`), `frequency` (default 1.0),
   `frequency_reduction_method` (default `default`), `locate_offset` (default 0, 0, 0). Potential start chunk of region `(rx, rz) = (floorDiv(cx, spacing), floorDiv(cz, spacing))`:
   a Java-LCG `WorldgenRandom` with `setLargeFeatureWithSalt(worldSeed, rx, rz, salt)` (`seed = rx * 341873128712 + rz * 132897987541 + worldSeed + salt`, 64-bit),
   `d = spacing - separation`, then two draws (`linear`: `nextInt(d)` twice, first for x, then z; `triangular`: `(nextInt(d) + nextInt(d)) / 2` each, four draws in all), candidate `(rx * spacing + dx, rz * spacing + dz)`.
   A chunk is a structure chunk when it equals the candidate and, if `frequency < 1.0`, the reducer accepts it. The reducer of `legacy_type_2` (the method of the buried treasure; the
   mapping of the four method names to the four reducer functions is read from the enum's static initialiser, where each name string is passed with its own invokedynamic index: `default` #0 `probabilityReducer`, `legacy_type_1` #1 `legacyPillagerOutpostReducer`, `legacy_type_2` #2 `legacyArbitrarySaltProbabilityReducer`, `legacy_type_3` #3 `legacyProbabilityReducerWithDouble`; 36-1 section 4.4) is: Java-LCG `WorldgenRandom`, `setLargeFeatureWithSalt(worldSeed, chunkX, chunkZ, 10387320)`,
   accept when `nextFloat() < frequency`. (The reducer of `default` uses `setLargeFeatureWithSalt(worldSeed, chunkX, chunkZ, salt)`; `legacy_type_1` is the pillager outpost's.) These are the
   hooks of the structure engine; the engine belongs to a sibling part.

### 2.3 The `ScatteredFeaturePiece` frame (desert pyramid, jungle temple, swamp hut)

A scattered piece is created from `(pieceType, x, y, z, width, height, depth, direction)` (`ScatteredFeaturePiece`): `boundingBox = makeBoundingBox(x, y, z, direction, width, height, depth)`,
`heightPosition = -1`, orientation set to `direction`. `makeBoundingBox`: if the direction's axis is Z (north, south):
box `(x, y, z)` to `(x + width - 1, y + height - 1, z + depth - 1)`; otherwise (west, east): `(x, y, z)` to `(x + depth - 1, y + height - 1, z + width - 1)` (width and depth swap).
The three pieces are created at `(minBlockX, 64, minBlockZ)` of the start chunk with a direction from `getRandomHorizontalDirection(random)` = `Direction.Plane.HORIZONTAL`
element `nextInt(4)` of the order north, east, south, west (the swamp hut and the desert pyramid and jungle temple draw it first, from the start random).

**Orientation to rotation and mirror** (`StructurePiece.setOrientation`; also applied by `placeBlock` to every block state):

| Orientation | Mirror | Rotation |
|---|---|---|
| north (and null) | none | none |
| south | left_right | none |
| west | left_right | clockwise_90 |
| east | none | clockwise_90 |

**Local to world** (`getWorldX(x, z)`, `getWorldY(y)`, `getWorldZ(x, z)`, with `box` the piece's current box; null orientation maps identity):

| Orientation | world X | world Z |
|---|---|---|
| north | `box.minX + x` | `box.maxZ - z` |
| south | `box.minX + x` | `box.minZ + z` |
| west | `box.maxX - z` | `box.minZ + x` |
| east | `box.minX + z` | `box.minZ + x` |

`world Y = box.minY + y`. The box moves in Y when the ground adjuster runs (below), so `box.minY` is the *current* minY.

**`placeBlock(level, state, x, y, z, writeBox)`**: `pos = getWorldPos(x, y, z)`; do nothing if `writeBox` does not contain `pos`; do nothing if `canBeReplaced(...)` (always true for these pieces);
apply `state.mirror(mirror)` if the mirror is not none and then `state.rotate(rotation)` if the rotation is not none (property mapping of stairs, levers, vines, tripwire hooks, redstone wire,
pistons, repeaters, dispensers: 24, 29, 30); `setBlock(pos, state, 2)`; if the placed block has a non-empty fluid state schedule a fluid tick at delay 0; if the block is one of
`nether_brick_fence, torch, wall_torch, oak/spruce/dark_oak/pale_oak/acacia/birch/jungle fence, ladder, iron_bars` the position is marked for chunk post-processing
(`markPosForPostProcessing`, the 12 "shape-check" blocks `SHAPE_CHECK_BLOCKS`). `getBlock(level, x, y, z, writeBox)` returns air outside the box, else the level's state at the world position.

**Fillers** (`generateBox`, `generateAirBox`, `generateMaybeBox`, `maybeGenerateBlock`, `fillColumnDown`, `isReplaceableByStructures`): 36-1 section 6.5 (loops run `y` outermost, then `x`, then `z`; `placeBlock` clips to the write box).

**Containers.** `createChest`, `createDispenser` and the shape-check blocks: 36-1 section 6.5 (the loot seed is `random.nextLong()` once per container actually created; the placed chest is single and no `type` property is changed). `createDispenser` goes through `placeBlock`, so the piece's rotation and mirror apply to the dispenser's `facing`.

`reorient` (36-1 section 6.5) has an early exit that matters here: the loop over north, east, south, west checks each neighbour for a chest first (a chest ends the loop and returns the state unchanged), then for a solid-render neighbour. On finding a **second** solid-render neighbour it discards the wall and leaves the loop at once, so a chest lying later in that order is never seen and the state is not returned unchanged. In the fallback (no wall or two walls) only the first two walls found matter, because the scan stops at the second.

**Ground adjusters** (the piece's vertical position is decided at post-process time, not at creation):

* `updateAverageGroundHeight(level, writeBox, offset)` (jungle temple, swamp hut): if `heightPosition >= 0` return true. Otherwise over every column `(x, z)` of the piece's box (z outer, x inner), if the world position `(x, 64, z)` lies in `writeBox`, add
  `level.getHeightmapPos(MOTION_BLOCKING_NO_LEAVES, pos).y` (= `getHeight(...)`, the first free y, 35-1 section 4.2) and count it; if the count is 0 return false (the piece is skipped for this call); else
  `heightPosition = sum / count` (integer division) and `box.move(0, heightPosition - box.minY + offset, 0)`; return true. Because only columns inside the current `writeBox` count, the average is taken from the
  first decorated chunk that has columns and is then fixed (and saved).
* `updateHeightPositionToLowestGroundHeight(level, offset)` (desert pyramid): if `heightPosition >= 0` return true. Otherwise `minHeight = level.maxY + 1`; over every column of the **whole** box (no `writeBox` test) take
  `min(minHeight, getHeightmapPos(MOTION_BLOCKING_NO_LEAVES, (x, 0, z)).y)`; if no column was visited return false; `heightPosition = minHeight` and `box.move(0, heightPosition - box.minY + offset, 0)`; return true.

After the first successful call the box has been moved so that `box.minY = heightPosition + offset` (average or lowest ground height) and `heightPosition` is saved (`HPos`); later calls return true without moving.

### 2.4 Piece persistence

Every piece is saved with `id` (the `structure_piece` key), `BB` (an int array `[minX, minY, minZ, maxX, maxY, maxZ]`), `O` (orientation as `get2DDataValue`: south 0, west 1, north 2, east 3; -1 for none) and `GD` (generation depth, 0 here), plus the keys of
the table in section 10. A scattered piece adds `Width`, `Height`, `Depth`, `HPos`. A template piece adds `Template` (the template id string, `minecraft:...`), `TPX`, `TPY`, `TPZ` (the template position).

### 2.5 Template pieces (igloo, ruined portal, nether fossil)
`TemplateStructurePiece` (construction, bounding box, `postProcess` with its four steps, data markers, `final_state` of jigsaw blocks): 36-2 section 6. The pivot passed to `placeInWorld` is the structure pivot given to `postProcess` (section 2.2 item 4); the rotation pivot used for the transform is `placeSettings.getRotationPivot()`.

### 2.6 `StructureTemplate` placement, as used here
Block list order and palettes: 36-2 section 1.3. Block and entity transform, bounding box and the zero position: 36-2 sections 3.1 to 3.3 (worked example 36-2 section 11.1). `StructurePlaceSettings` defaults and `getRandom(pos)`: 36-2 sections 4.1 and 4.2. `placeInWorld` (early exits, processing, placing, loot seeds of template containers, waterlogging, shape updates, entities): 36-2 section 5. All templates read for this document have exactly one palette (key `palette`).

Facts this document relies on: a container inside a template receives `nbt.putLong("LootTableSeed", random.nextLong())` of the piece random during `placeInWorld` (one draw per randomizable container with NBT, in placement order); the settings of every piece here use flags 2 and the `apply_waterlogging` default.

### 2.7 Processors and rule tests used by these pieces
Framework (`processBlockInfos` order, null drops, `finalizeProcessing`): 36-2 section 7.4. The processors these pieces use, and where each is specified:

| Processor or test | Used by | Specified in |
|---|---|---|
| `BlockIgnoreProcessor` (`STRUCTURE_BLOCK` = `{structure_block}`; `STRUCTURE_AND_AIR` = `{air, structure_block}`, plain `air` only) | ruined portal (section 8.4), nether fossil (section 9.2); the igloo uses `STRUCTURE_BLOCK` (section 6.2) | 36-2 section 9.1 |
| `RuleProcessor`, `ProcessorRule`, `BlockMatchTest`, `RandomBlockMatchTest`, `AlwaysTrueTest` (per-block random `RandomSource.create(Mth.getSeed(info.pos))`; the default of `testAgainstWorldState(level, pos, random)` is exactly `test(level.getBlockState(pos), pos, random)`, read) | ruined portal | 36-2 sections 8.1 to 8.3 |
| `ProtectedBlockProcessor` (tag `features_cannot_replace`) | ruined portal | 36-2 section 9.3 |
| `LavaSubmergedBlockProcessor` | ruined portal | 36-2 section 9.7 |
| `BlackstoneReplaceProcessor` (23 from-block entries) | ruined portal, only when the setup has `replace_with_blackstone` (section 8.4) | 36-2 section 9.8 |
| `BlockAgeProcessor(mossiness)` (block-age random of section 2.1) | ruined portal | 36-2 section 9.9 |


### 2.8 Template entities

`placeEntities` is specified in 36-2 section 5.6 and the entity transform in 36-2 section 3.2; this document adds only the facts it needs. For the block coordinate to world mapping of an entity position, the entity variant of `transform` first mirrors (`left_right`: `z' = 1 - z`; `front_back`: `x' = 1 - x`; `y` unchanged), then rotates about the pivot `(px, pz)` (the 1 is added once, only to the sum-type terms; the difference terms are unchanged):

| Rotation | `x'` | `z'` |
|---|---|---|
| clockwise_90 | `px + pz + 1 - z` | `pz - px + x` |
| clockwise_180 | `2 * px + 1 - x` | `2 * pz + 1 - z` |
| counterclockwise_90 | `px - pz + z` | `px + pz + 1 - x` |

(Read from the `Vec3` overload of `StructureTemplate.transform`; `y` is unchanged. The igloo basement entities depend on these formulas.) The igloo's basement entities are placed with `finalizeEntities` off (section 6.3).
---

## 3. Desert pyramid

### 3.1 Start

`DesertPyramidStructure` is a `SinglePieceStructure` with width 21 and depth 21 (section 2.2 item 6): no start when the lowest corner height is below sea level (63) or no valid biome could exist at the chunk centre; one piece `DesertPyramidPiece(startRandom, chunk.minBlockX, chunk.minBlockZ)`:
`ScatteredFeaturePiece` with `y = 64`, `width = 21`, `height = 15`, `depth = 21`, direction `nextInt(4)` of (north, east, south, west) from the start random (the only start-random draw). The piece also holds `hasPlacedChest[4]` (all false), the transient list `potentialSuspiciousSandWorldPositions` (empty) and the transient `randomCollapsedRoofPos` (`(0, 0, 0)`).
Structure data: biome tag `has_structure/desert_pyramid`, step `surface_structures`, no spawn overrides.

### 3.2 `postProcess`

1. `adjust = -random.nextInt(3)` is drawn **every call** (value 0, -1 or -2), then `updateHeightPositionToLowestGroundHeight(level, adjust)`; if it returns false the call ends. (Because the draw is evaluated before the call, the random advances even when the height was already fixed.)
2. Place the operations of section 3.3 in order, then the four chests and `addCellar` (3.4). `W = 21`, `D = 21` below; `box(x0,y0,z0 - x1,y1,z1)` is `generateBox` with `skipAir = false` (every cell is placed). Stairs: `SSN`, `SSS`, `SSE`, `SSW` are `sandstone_stairs` with facing north, south, east, west.

### 3.3 Geometry of the pyramid (local coordinates; order matters)

| # | Operation |
|---|---|
| 1 | `box(0,-4,0 - W-1,0,D-1)` edge = fill = `sandstone` |
| 2 | for `i = 1 .. 9`: `box(i,i,i - W-1-i,i,D-1-i)` `sandstone`; then `box(i+1,i,i+1 - W-2-i,i,D-2-i)` `air` (a stepped pyramid: layer `i` is a ring with an air interior) |
| 3 | for every `x = 0..W-1`, `z = 0..D-1` (x outer): `fillColumnDown(sandstone, x, -5, z)` |
| 4 | `box(0,0,0 - 4,9,4)` edge `sandstone`, fill `air` (corner tower, hollow); `box(1,10,1 - 3,10,3)` `sandstone`; put `SSN` (2,10,0), `SSS` (2,10,4), `SSE` (0,10,2), `SSW` (4,10,2) |
| 5 | the mirror tower: `box(W-5,0,0 - W-1,9,4)` edge `sandstone`, fill `air`; `box(W-4,10,1 - W-2,10,3)` `sandstone`; put `SSN` (W-3,10,0), `SSS` (W-3,10,4), `SSE` (W-5,10,2), `SSW` (W-1,10,2) |
| 6 | entrance hall: `box(8,0,0 - 12,4,4)` edge `sandstone`, fill `air`; `box(9,1,0 - 11,3,4)` `air`; put `cut_sandstone` at (9,1,1) (9,2,1) (9,3,1) (10,3,1) (11,3,1) (11,2,1) (11,1,1) |
| 7 | side passages: `box(4,1,1 - 8,3,3)` edge `sandstone`, fill `air`; `box(4,1,2 - 8,2,2)` `air`; `box(12,1,1 - 16,3,3)` edge `sandstone`, fill `air`; `box(12,1,2 - 16,2,2)` `air` |
| 8 | `box(5,4,5 - W-6,4,D-6)` `sandstone`; `box(9,4,9 - 11,4,11)` `air`; `box(8,1,8 - 8,3,8)`, `box(12,1,8 - 12,3,8)`, `box(8,1,12 - 8,3,12)`, `box(12,1,12 - 12,3,12)` `cut_sandstone` (four pillars) |
| 9 | `box(1,1,5 - 4,4,11)` and `box(W-5,1,5 - W-2,4,11)` `sandstone`; `box(6,7,9 - 6,7,11)` and `box(W-7,7,9 - W-7,7,11)` `sandstone`; `box(5,5,9 - 5,7,11)` and `box(W-6,5,9 - W-6,7,11)` `cut_sandstone` |
| 10 | put `air` at (5,5,10) (5,6,10) (6,6,10) (W-6,5,10) (W-6,6,10) (W-7,6,10); `box(2,4,4 - 2,6,4)` and `box(W-3,4,4 - W-3,6,4)` `air`; put `SSN` at (2,4,5) (2,3,4) (W-3,4,5) (W-3,3,4) |
| 11 | `box(1,1,3 - 2,2,3)` and `box(W-3,1,3 - W-2,2,3)` `sandstone`; put `sandstone` (1,1,2) (W-2,1,2); `sandstone_slab` (1,2,2) (W-2,2,2); `SSW` (2,1,2); `SSE` (W-3,1,2) |
| 12 | `box(4,3,5 - 4,3,17)` and `box(W-5,3,5 - W-5,3,17)` `sandstone`; `box(3,1,5 - 4,2,16)` and `box(W-6,1,5 - W-5,2,16)` `air` |
| 13 | for `z = 5, 7, 9, 11, 13, 15, 17`: put `cut_sandstone` (4,1,z) and `chiseled_sandstone` (4,2,z), `cut_sandstone` (W-5,1,z) and `chiseled_sandstone` (W-5,2,z) |
| 14 | floor mosaic, `orange_terracotta` at (10,0,7) (10,0,8) (9,0,9) (11,0,9) (8,0,10) (12,0,10) (7,0,10) (13,0,10) (9,0,11) (11,0,11) (10,0,12) (10,0,13); `blue_terracotta` at (10,0,10) (via `Blocks.DYED_TERRACOTTA.orange()` and `.blue()` of 24) |
| 15 | end-wall bands: for `x` = 0, then `x` = `W-1` (the loop starts at 0 and adds `W-1`, so two iterations), 21 puts in this order, `y` from 2 to 8 and, inside each `y`, `z` = 1, 2, 3: `y=2`: `cut_sandstone`, `orange_terracotta`, `cut_sandstone`; `y=3`: `cut_sandstone`, `orange_terracotta`, `cut_sandstone`; `y=4`: `orange_terracotta`, `chiseled_sandstone`, `orange_terracotta`; `y=5`: `cut_sandstone`, `orange_terracotta`, `cut_sandstone`; `y=6`: `orange_terracotta`, `chiseled_sandstone`, `orange_terracotta`; `y=7`: `orange_terracotta` x3; `y=8`: `cut_sandstone` x3 |
| 16 | front-wall bands: for `x` = 2, then `x` = `W-3` = 18 (the loop starts at 2 and adds `(W-3) - 2 = 16`, so the values are 2 and 18), 21 puts at `z = 0`, `y` from 2 to 8 and, inside each `y`, the three columns `x-1`, `x`, `x+1`, with exactly the same pattern per `y` as step 15 (`y=2`: `cut`, `orange`, `cut`; `y=3`: `cut`, `orange`, `cut`; `y=4`: `orange`, `chiseled`, `orange`; `y=5`: `cut`, `orange`, `cut`; `y=6`: `orange`, `chiseled`, `orange`; `y=7`: `orange` x3; `y=8`: `cut` x3) |
| 17 | `box(8,4,0 - 12,6,0)` `cut_sandstone`; put `air` (8,6,0) (12,6,0); `orange_terracotta` (9,5,0) (11,5,0); `chiseled_sandstone` (10,5,0) |
| 18 | the trap shaft: `box(8,-14,8 - 12,-11,12)` `cut_sandstone`; `box(8,-10,8 - 12,-10,12)` `chiseled_sandstone`; `box(8,-9,8 - 12,-9,12)` `cut_sandstone`; `box(8,-8,8 - 12,-1,12)` `sandstone`; `box(9,-11,9 - 11,-1,11)` `air` |
| 19 | put `stone_pressure_plate` (10,-11,10); `box(9,-13,9 - 11,-13,11)` edge `tnt`, fill `air` (a single layer: every cell is an edge cell, so nine `tnt`) |
| 20 | the four chest niches: put `air` (8,-11,10) (8,-10,10), `chiseled_sandstone` (7,-10,10), `cut_sandstone` (7,-11,10); `air` (12,-11,10) (12,-10,10), `chiseled_sandstone` (13,-10,10), `cut_sandstone` (13,-11,10); `air` (10,-11,8) (10,-10,8), `chiseled_sandstone` (10,-10,7), `cut_sandstone` (10,-11,7); `air` (10,-11,12) (10,-10,12), `chiseled_sandstone` (10,-10,13), `cut_sandstone` (10,-11,13) |

The loops of steps 15 and 16 have two iterations each (`x` = 0 and 20; `x` = 2 and 18).

### 3.4 Chests, cellar and the level random

*Chests* (after step 20): for the horizontal directions in the order north, east, south, west: if `hasPlacedChest[direction.get2DDataValue()]` is false, `hasPlacedChest[...] = createChest(level, box, random, 10 + 2 * stepX, -11, 10 + 2 * stepZ, loot table)`; the positions are north (10,-11,8), east (12,-11,10), south (10,-11,12) and west (8,-11,10).
Loot table `minecraft:chests/desert_pyramid` (data); seed `random.nextLong()` per chest created (so up to four draws, in this order). The flags are saved as `hasPlacedChest0..3` indexed by the 2D data value (south 0, west 1, north 2, east 3).

*Cellar* (`addCellar`, after the chests): `pos = (16, -4, 13)` local; `X, Y, Z` below are its components. Steps in order:

| # | Operation |
|---|---|
| C1 | put `sandstone_stairs` rotated counterclockwise 90 (default facing north becomes west) at (13,-1,17) (14,-2,17) (15,-3,17) |
| C2 | `b = level.getRandom().nextBoolean()` (the level random, one draw); put `sand` at (X-4..X, Y+4, Z+4) (five blocks); `sand` (X-2,Y+3,Z+4); (X-1,Y+3,Z+4) = `b ? sand : sandstone`; (X,Y+3,Z+4) = `b ? sandstone : sand`; `sand` (X-1,Y+2,Z+4); `sandstone` (X,Y+2,Z+4); `sand` (X,Y+1,Z+4) |
| C3 | with `skipAir = true`: `cut_sandstone` boxes at `y = Y+1`: `(X-3,Y+1,Z-3 - X-3,Y+1,Z+2)`, `(X+3,Y+1,Z-3 - X+3,Y+1,Z+2)`, `(X-3,Y+1,Z-3 - X+3,Y+1,Z-2)`, `(X-3,Y+1,Z+3 - X+3,Y+1,Z+3)`; `chiseled_sandstone` the same four boxes at `y = Y+2`; `cut_sandstone` the same four boxes at the literal `y = -1` (= `Y+3`) |
| C4 | record (no block placed) the 75 sand candidates of the box `(X-2,Y+1,Z-2 - X+2,Y+3,Z+2)` (loop `y`, `x`, `z`); then `placeCollapsedRoof(box = (X-2,Y+4,Z-2) - (X+2, ., Z+2))` (section 3.5) |
| C5 | put `blue_terracotta` (X,Y,Z); `orange_terracotta` at (X+1,Y,Z-1) (X+1,Y,Z+1) (X-1,Y,Z-1) (X-1,Y,Z+1) (X+2,Y,Z) (X-2,Y,Z) (X,Y,Z+2) (X,Y,Z-2); then arm by arm: east: `orange` (X+3,Y,Z), candidates (X+3,Y+1,Z) (X+3,Y+2,Z), `cut` (X+4,Y+1,Z), `chiseled` (X+4,Y+2,Z); west: `orange` (X-3,Y,Z), candidates (X-3,Y+1,Z) (X-3,Y+2,Z), `cut` (X-4,Y+1,Z), `chiseled` (X-4,Y+2,Z); south: `orange` (X,Y,Z+3), candidates (X,Y+1,Z+3) (X,Y+2,Z+3); north: `orange` (X,Y,Z-3), candidates (X,Y+1,Z-3) (X,Y+2,Z-3), `cut` (X,Y+1,Z-4), `chiseled` (X,-2,Z-4) |

The candidate list therefore has `75 + 8 = 83` distinct world positions (the east, west, south and north arms contribute two each, outside the 5 x 3 x 5 box).

### 3.5 The collapsed roof and `afterPlace` (suspicious sand)

*`placeCollapsedRoof`*: for `x = X-2 .. X+2` (outer) and `z = Z-2 .. Z+2` (inner), at the local `y = Y+4 = 0` (the floor layer of the pyramid): `level.getRandom().nextFloat() < 0.33` places `sandstone` there, otherwise `sand` (two states, one level-random draw per cell,
25 draws). Then `rnd = createThreadLocalInstance(worldSeed).forkPositional().at(worldPos(X-2, 0, Z-2))` (section 2.1), `rx = rnd.nextIntBetweenInclusive(X-2, X+2)`, `rz = rnd.nextIntBetweenInclusive(Z-2, Z+2)` (that order), and
`randomCollapsedRoofPos = world position of local (rx, 0, rz)` (via `getWorldX/Y/Z`, so rotation and the current box apply). Both fields are rebuilt on every `postProcess` call (they are not saved).

*`DesertPyramidStructure.afterPlace(level, ..., random, writeBox, chunkPos, pieces)`* (once per decorated chunk, after the pieces):

1. For each `DesertPyramidPiece` in the container: add its `potentialSuspiciousSandWorldPositions` to a sorted set ordered by `Vec3i.compareTo` (`y`, then `z`, then `x`, ascending; duplicates collapse); then `placeSuspiciousSand(writeBox, level, piece.randomCollapsedRoofPos)`.
2. `list` = the set in that order; `rnd = createThreadLocalInstance(worldSeed).forkPositional().at(center of the box that encapsulates all pieces)`; `Util.shuffle(list, rnd)` (Fisher-Yates from the end: for `i = size` down to 2, `j = rnd.nextInt(i)`, swap `list[i-1]` and `list[j]`); `n = min(set size, rnd.nextInt(5, 8))` (= `5 + nextInt(3)`, i.e. 5 to 7); `rnd` is used in this order, so the shuffle's draws come first.
3. For each position of the shuffled list in order: if `n > 0`: `n--`, `placeSuspiciousSand(writeBox, level, pos)`; else if `writeBox` contains `pos`: `setBlock(pos, sand, 2)`.

`placeSuspiciousSand(box, level, pos)`: if `box` contains `pos`: `setBlock(pos, suspicious_sand, 2)`; the block entity (`brushable_block`), if present, gets `setLootTable(archaeology/desert_pyramid, pos.asLong())` (a table id `minecraft:archaeology/desert_pyramid`, data; its use on brushing: 31-4).
Because the shuffle and `n` depend only on the world seed and the (fixed) set, every chunk pass picks the same positions; each pass writes those inside its `writeBox`. The whole cellar volume ends as sand with 5 to 7 suspicious blocks plus the roof one. The position lists are rebuilt by each `postProcess` call, so the result does not depend on a reload.

### 3.6 Loot and seeds, summary

Chests: 4 at most, `chests/desert_pyramid`, seeds from the piece random in the order north, east, south, west. Brushable blocks: `archaeology/desert_pyramid`, seed = packed position. TNT trap: 9 `tnt` at local y -13 under a `stone_pressure_plate` at (10,-11,10) on cut sandstone (no loot).

---

## 4. Jungle temple

### 4.1 Start and piece

`JungleTempleStructure` is a `SinglePieceStructure` with width 12 and depth 15 (section 2.2 item 6); the piece is `JungleTemplePiece(startRandom, minBlockX, minBlockZ)`: `ScatteredFeaturePiece` with `y = 64`, `width = 12`, `height = 10`, `depth = 15` and a random horizontal direction (first start-random draw); flags `placedMainChest`, `placedHiddenChest`, `placedTrap1`, `placedTrap2` (all false, saved under those names).
Data: structure id `jungle_pyramid`, biome tag `has_structure/jungle_temple`, step `surface_structures`.

### 4.2 `postProcess`

1. `updateAverageGroundHeight(level, writeBox, 0)`; if false the call ends.
2. The operations of 4.3 in order. `R(x0,y0,z0 - x1,y1,z1)` is `generateBox(..., skipAir = false, random, MossStoneSelector)`: one selector call per cell (loop `y`, `x`, `z`), and the selector ignores the position and the edge flag: **`random.nextFloat() < 0.4f` gives `cobblestone`, else `mossy_cobblestone`**. `A(...)` is `generateAirBox`. Stairs `CE`, `CW`, `CS`, `CN` are `cobblestone_stairs` facing east, west, south, north. `WNS` is `redstone_wire[north=side, south=side]`.
3. The containers (4.4) are created inline at the positions shown, each only when its flag is false.

### 4.3 Geometry (local coordinates, W = 12, D = 15)

| # | Operation |
|---|---|
| 1 | `R(0,-4,0 - W-1,0,D-1)` |
| 2 | `R(2,1,2 - 9,2,2)`, `R(2,1,12 - 9,2,12)`, `R(2,1,3 - 2,2,11)`, `R(9,1,3 - 9,2,11)`, `R(1,3,1 - 10,6,1)`, `R(1,3,13 - 10,6,13)`, `R(1,3,2 - 1,6,12)`, `R(10,3,2 - 10,6,12)`, `R(2,3,2 - 9,3,12)`, `R(2,6,2 - 9,6,12)`, `R(3,7,3 - 8,7,11)`, `R(4,8,4 - 7,8,10)` |
| 3 | `A(3,1,3 - 8,2,11)`, `A(4,3,6 - 7,3,9)`, `A(2,4,2 - 9,5,12)`, `A(4,6,5 - 7,6,9)`, `A(5,7,6 - 6,7,8)`, `A(5,1,2 - 6,2,2)`, `A(5,2,12 - 6,2,12)`, `A(5,5,1 - 6,5,1)`, `A(5,5,13 - 6,5,13)`; put `air` at (1,5,5) (10,5,5) (1,5,9) (10,5,9) |
| 4 | for `z` in `{0, 14}`: `R(2,4,z - 2,5,z)`, `R(4,4,z - 4,5,z)`, `R(7,4,z - 7,5,z)`, `R(9,4,z - 9,5,z)`; then `R(5,6,0 - 6,6,0)` |
| 5 | for `x` in `{0, 11}`: for `z = 2, 4, 6, 8, 10, 12`: `R(x,4,z - x,5,z)`; then `R(x,6,5 - x,6,5)`, `R(x,6,9 - x,6,9)` |
| 6 | `R(2,7,2 - 2,9,2)`, `R(9,7,2 - 9,9,2)`, `R(2,7,12 - 2,9,12)`, `R(9,7,12 - 9,9,12)`, `R(4,9,4 - 4,9,4)`, `R(7,9,4 - 7,9,4)`, `R(4,9,10 - 4,9,10)`, `R(7,9,10 - 7,9,10)`, `R(5,9,7 - 6,9,7)` |
| 7 | put `CN` (5,9,6) (6,9,6); `CS` (5,9,8) (6,9,8); `CN` (4,0,0) (5,0,0) (6,0,0) (7,0,0); `CN` (4,1,8) (4,2,9) (4,3,10); `CN` (7,1,8) (7,2,9) (7,3,10) |
| 8 | `R(4,1,9 - 4,1,9)`, `R(7,1,9 - 7,1,9)`, `R(4,1,10 - 7,2,10)`, `R(5,4,5 - 6,4,5)`; put `CE` (4,4,5), `CW` (7,4,5) |
| 9 | for `i = 0 .. 3`: put `CS` at (5,-i,6+i) and (6,-i,6+i); `A(5,-i,7+i - 6,-i,9+i)` (the stair shaft down into the basement) |
| 10 | `A(1,-3,12 - 10,-1,13)`, `A(1,-3,1 - 3,-1,13)`, `A(1,-3,1 - 9,-1,5)`; for `z = 1, 3, 5, 7, 9, 11, 13`: `R(1,-3,z - 1,-2,z)`; for `z = 2, 4, 6, 8, 10, 12`: `R(1,-1,z - 3,-1,z)`; `R(2,-2,1 - 5,-2,1)`, `R(7,-2,1 - 9,-2,1)`, `R(6,-3,1 - 6,-3,1)`, `R(6,-1,1 - 6,-1,1)` |

### 4.4 The trap corridor, chests and the lever puzzle (continued, same order)

| # | Operation |
|---|---|
| 11 | `tripwire_hook[facing=east, attached=true]` (1,-3,8); `tripwire_hook[facing=west, attached=true]` (4,-3,8); `tripwire[east=true, west=true, attached=true]` (2,-3,8) (3,-3,8) |
| 12 | `WNS` at (5,-3,7) (5,-3,6) (5,-3,5) (5,-3,4) (5,-3,3) (5,-3,2); `redstone_wire[north=side, west=side]` (5,-3,1); `redstone_wire[east=side, west=side]` (4,-3,1); `mossy_cobblestone` (3,-3,1) |
| 13 | if `!placedTrap1`: `placedTrap1 = createDispenser(3,-2,1, facing north, loot chests/jungle_temple_dispenser)`; put `vine[south=true]` (3,-2,2) |
| 14 | `tripwire_hook[facing=north, attached=true]` (7,-3,1); `tripwire_hook[facing=south, attached=true]` (7,-3,5); `tripwire[north=true, south=true, attached=true]` (7,-3,2) (7,-3,3) (7,-3,4) |
| 15 | `redstone_wire[east=side, west=side]` (8,-3,6); `redstone_wire[west=side, south=side]` (9,-3,6); `redstone_wire[north=side, south=up]` (9,-3,5); `mossy_cobblestone` (9,-3,4); `WNS` (9,-2,4) |
| 16 | if `!placedTrap2`: `placedTrap2 = createDispenser(9,-2,3, facing west, loot chests/jungle_temple_dispenser)`; put `vine[east=true]` (8,-1,3) and (8,-2,3) |
| 17 | if `!placedMainChest`: `placedMainChest = createChest(8,-3,3, loot chests/jungle_temple)` |
| 18 | put `mossy_cobblestone` at (9,-3,2) (8,-3,1) (4,-3,5) (5,-2,5) (5,-1,5) (6,-3,5) (7,-2,5) (7,-1,5) (8,-3,5); `R(9,-1,1 - 9,-1,5)`; `A(8,-3,8 - 10,-1,10)` |
| 19 | put `chiseled_stone_bricks` (8,-2,11) (9,-2,11) (10,-2,11); `lever[facing=north, face=wall]` (8,-2,12) (9,-2,12) (10,-2,12); `R(8,-3,8 - 8,-3,10)`, `R(10,-3,8 - 10,-3,10)`; `mossy_cobblestone` (10,-2,9); `WNS` (8,-2,9) (8,-2,10) |
| 20 | `redstone_wire[north=side, south=side, east=side, west=side]` (10,-1,9); `sticky_piston[facing=up]` (9,-2,8); `sticky_piston[facing=west]` (10,-2,8) and (10,-1,8); `repeater[facing=north]` (10,-2,10) |
| 21 | if `!placedHiddenChest`: `placedHiddenChest = createChest(9,-3,10, loot chests/jungle_temple)` |

Seeds: each `createChest` / `createDispenser` that places draws `random.nextLong()` once, in the order trap 1, trap 2, main chest, hidden chest (and the 15-block `R` boxes draw a float per cell before any of these). Loot tables (data): `minecraft:chests/jungle_temple` (both chests, 4.4 steps 17 and 21), `minecraft:chests/jungle_temple_dispenser` (both dispensers). The block states are applied through `placeBlock`, so orientation rotation and mirror apply to `facing`, `north..west` and the lever (and a lever placed this way has its default `powered=false`). The trap and the puzzle work by the redstone rules of 30 (the tripwire hooks and strings of steps 11 and 14, the repeater and sticky pistons of step 20); no behaviour is added by the piece.

---

## 5. Swamp hut

### 5.1 Start and piece

`SwampHutStructure.findGenerationPoint` is `onTopOfChunkCenter(ctx, WORLD_SURFACE_WG, builder -> addPiece(SwampHutPiece(startRandom, chunk.minBlockX, chunk.minBlockZ)))` (the biome check of section 2.2 item 2 applies; there is no sea-level test).
`SwampHutPiece`: `y = 64`, `width = 7`, `height = 7`, `depth = 9`, direction from `getRandomHorizontalDirection(startRandom)`; flags `spawnedWitch`, `spawnedCat` (saved as `Witch` and `Cat`). Data: biome tag `has_structure/swamp_hut`, step `surface_structures`, spawn overrides monster witch and creature cat with bounding box `piece`.

### 5.2 `postProcess`

`updateAverageGroundHeight(level, writeBox, 0)`; if false the call ends. Then (`SS` = `spruce_planks`, `OL` = `oak_log`, `OF` = `oak_fence`; stairs `PN`, `PE`, `PW`, `PS` = `spruce_stairs` facing north, east, west, south; all boxes `skipAir = false`, edge = fill):

| # | Operation |
|---|---|
| 1 | `box(1,1,1 - 5,1,7)` `SS`; `box(1,4,2 - 5,4,7)` `SS`; `box(2,1,0 - 4,1,0)` `SS`; `box(2,2,2 - 3,3,2)` `SS`; `box(1,2,3 - 1,3,6)` `SS`; `box(5,2,3 - 5,3,6)` `SS`; `box(2,2,7 - 4,3,7)` `SS` |
| 2 | `box(1,0,2 - 1,3,2)`, `box(5,0,2 - 5,3,2)`, `box(1,0,7 - 1,3,7)`, `box(5,0,7 - 5,3,7)` `OL` |
| 3 | put `OF` (2,3,2) (3,3,7); `air` (1,3,4) (5,3,4) (5,3,5); `potted_red_mushroom` (1,3,5); `crafting_table` (3,2,6); `cauldron` (4,2,6); `OF` (1,2,1) (5,2,1) |
| 4 | `box(0,4,1 - 6,4,1)` `PN`; `box(0,4,2 - 0,4,7)` `PE`; `box(6,4,2 - 6,4,7)` `PW`; `box(0,4,8 - 6,4,8)` `PS`; put `PN[shape=outer_right]` (0,4,1); `PN[shape=outer_left]` (6,4,1); `PS[shape=outer_left]` (0,4,8); `PS[shape=outer_right]` (6,4,8) |
| 5 | for `z` in `{2, 7}` and `x` in `{1, 5}` (z outer): `fillColumnDown(oak_log, x, -1, z)` (the four legs reach the ground or the swamp water) |
| 6 | witch (5.4), then `spawnCat` (5.4) |

### 5.3 Notes

The hut has no random draw of its own; the only random is the start random's direction. The potted red mushroom, cauldron and crafting table are plain default states.

### 5.4 Witch and cat

(Confirms 44-2 section 10.7.) After the blocks: if `!spawnedWitch` and the world position `p` of local (2,2,5) lies in `writeBox`: `spawnedWitch = true`; create a `witch` (reason `STRUCTURE`); if it was created: `setPersistenceRequired()`, `snapTo(p.x + 0.5, p.y, p.z + 0.5, 0, 0)`, `finalizeSpawn(level, difficulty at p, STRUCTURE, no group data)`, `addFreshEntityWithPassengers`.
Then `spawnCat` (on every call): the same with `cat` and the flag `spawnedCat`, at the same position. A flag is set before the entity creation and so stays set even if creation returns nothing. The cat's variant comes from the entity's own default and `finalizeSpawn` (45; Open question 2).

---

## 6. Igloo

### 6.1 Start

`IglooStructure.findGenerationPoint = onTopOfChunkCenter(ctx, WORLD_SURFACE_WG, builder -> ...)`; the builder step: `pos = (chunk.minBlockX, 90, chunk.minBlockZ)`, `rotation = Rotation.getRandom(startRandom)` (`nextInt(4)` over none, clockwise_90, clockwise_180, counterclockwise_90), then `IglooPieces.addPieces(manager, pos, rotation, builder, startRandom)`.

`addPieces`:

1. `r = startRandom.nextDouble()`; if `r < 0.5` the igloo has a basement: `n = startRandom.nextInt(8) + 4` (4 to 11); add the laboratory piece (`igloo/bottom`) with depth offset `n * 3`; then for `i = 0 .. n - 2` add a ladder piece (`igloo/middle`) with depth offset `i * 3`.
2. In both cases add the top piece (`igloo/top`) with depth offset 0, last.

So the piece order is: laboratory, ladders `i = 0 ..`, top. With a basement the structure has `1 + (n - 1) + 1 = n + 1` pieces (5 to 12); without, one piece. Piece ids `Iglu`.

### 6.2 `IglooPiece` creation and constants

Template ids (namespace `minecraft`): `igloo/top` (size 7 x 5 x 8), `igloo/middle` (3 x 3 x 3), `igloo/bottom` (7 x 6 x 9) (data, read from the NBT headers).

| Template | Rotation pivot `(x, y, z)` | Position offset `(x, y, z)` (added to `pos` before the depth) |
|---|---|---|
| `igloo/top` | (3, 5, 5) | (0, 0, 0) |
| `igloo/middle` | (1, 3, 1) | (2, -3, 4) |
| `igloo/bottom` | (3, 6, 7) | (0, -3, -2) |

`templatePosition = pos + offset(template) - (0, depthOffset, 0)`; the offsets are **not** rotated (they are world-axis offsets); the rotation acts through the settings' pivot. Settings (`makeSettings(rotation, template)`): rotation as drawn, mirror none, rotation pivot from the table, processor `BlockIgnoreProcessor.STRUCTURE_BLOCK`,
liquid settings `ignore_waterlogging` (the template's waterlogged states are placed as stated, no fluid propagation). Entities not ignored, `finalizeEntities` false. The saved extras: `Rot` (the rotation, `Rotation.LEGACY_CODEC`).

### 6.3 `postProcess` (per piece)

Let `loc` be the piece's template id, `settings` the piece's own `makeSettings(its rotation, loc)`, `offset = OFFSETS[loc]`, `saved = templatePosition`.

1. Reference point `ref = templatePosition + transform(settings, (3 - offset.x, 0, -offset.z))` (`calculateRelativePosition`: mirror none, rotation and pivot of the settings).
2. `h = level.getHeight(WORLD_SURFACE_WG, ref.x, ref.z)` (first free y of the world-surface map, 35-1 section 4.2).
3. `templatePosition = templatePosition + (0, (h - 90) - 1, 0)`. (The 90 is the construction y, so the piece moves by `h - 91`: its construction y becomes `h - 1`.)
4. Run the template piece post-process (section 2.5): place the template, then handle data markers. The **only** marker is `chest` (see below).
5. If `loc` is `igloo/top`: `q = templatePosition + transform(settings, (3, 0, 5))`; if the block **below** `q` is neither air nor a ladder, `setBlockAndUpdate(q, snow_block)`.
6. `templatePosition = saved`.

Because the shift is re-derived at every call and then undone, the piece's saved `TPY` stays the construction value while its box (recomputed in step 4) is the shifted one until the next call. Each piece uses its own `ref`, so the shaft pieces follow the surface height at their own column.

`handleDataMarker("chest", pos, ...)`: set `pos` to air (`setBlockAndUpdate`), then if the block entity at `pos.below()` is a chest: `setLootTable(chests/igloo_chest, random.nextLong())`. (The template's `igloo/bottom` has a `chest` block entity at local (1,1,6), a `structure_block` data marker with metadata `chest` at (1,2,6), a sign, a furnace in `igloo/top`, a brewing stand; data.)
The seed draws of one pass: first one per randomizable-container block entity of the template (section 2.6 step 2: the chest of `igloo/bottom` has NBT, as does the furnace of `igloo/top`, which is not randomizable), then the marker's draw.
Entities: `igloo/bottom` stores two entities (a `villager` and a `zombie_villager`, both invulnerable and persistent, data); they are created by section 2.8 with `finalizeEntities` off, only by the chunk pass whose `writeBox` contains their transformed block position.
Loot table `minecraft:chests/igloo_chest` (data).

---

## 7. Buried treasure

### 7.1 Start

`BuriedTreasureStructure.findGenerationPoint = onTopOfChunkCenter(ctx, OCEAN_FLOOR_WG, builder -> addPiece(BuriedTreasurePiece(pos)))` with `pos = (chunk.getBlockX(9), 90, chunk.getBlockZ(9))` = `(minBlockX + 9, 90, minBlockZ + 9)`; no random is drawn. The piece box is the single block `pos` (`BoundingBox(BlockPos)`); the piece saves no extra keys.
Placement (data, quoted in section 1): every chunk is a candidate (`spacing 1`, `separation 0`: `d = 1`, both offset draws are `nextInt(1) = 0`) and the legacy reducer accepts with probability 0.01 (section 2.2 item 7). Step `underground_structures`.

### 7.2 `postProcess`

The piece is post-processed in the chunk whose `writeBox` contains `(minBlockX + 9, 90, minBlockZ + 9)`'s column (the box is one block at y 90, so the intersect test is by column and y 90 must be within the write box's y range: always true).

1. `h = level.getHeight(OCEAN_FLOOR_WG, box.minX, box.minZ)` (first free y of the ocean-floor map); `pos = (box.minX, h, box.minZ)`.
2. While `pos.y > level.minY`: `cur = state(pos)`, `below = state(pos - 1)`. If `below` is one of `sandstone`, `stone`, `andesite`, `granite`, `diorite` (the block types, any state):
   a. `fill = (cur is air or a liquid (water or lava)) ? sand : cur`;
   b. for each direction of `Direction.values()` in the order down, up, north, south, west, east: `n = pos.relative(d)`; if `state(n)` is air or liquid: `bn = state(n.below())`; if `bn` is air or liquid **and** `d` is not up: `setBlockAndUpdate(n, below)` (the support block's state); else `setBlockAndUpdate(n, fill)`;
   c. the piece box becomes `BoundingBox(pos)`;
   d. `createChest(level, writeBox, random, pos, chests/buried_treasure, state = null)` (section 2.3: it needs `writeBox` to contain `pos`, uses `reorient` for the facing and a seed `random.nextLong()`), and **return** (whether or not the chest was created).
   Otherwise `pos.y -= 1` and repeat.
3. If the loop ends at `minY` nothing is placed.

Effects: the chest sits in the first cell, scanning down from the ocean floor, whose block below is one of the five stones; that cell is replaced by the chest; the neighbouring air or water cells (not above) are filled with sand or, when they would hang over a void, with the stone; i.e. the treasure is buried under the beach sand layer. Loot table `minecraft:chests/buried_treasure` (data).
(There is no separate "map" logic in the piece; the treasure map's locate uses the structure set's locate offset (9, 0, 9), 44 and 17.)

---

## 8. Ruined portal

### 8.1 Data schema (the tool copies it; the engine fields are named here)

`RuinedPortalStructure` has the standard structure settings plus `setups`, a non-empty list of `Setup` records:

| Field | Type | Meaning |
|---|---|---|
| `placement` | `on_land_surface`, `partly_buried`, `on_ocean_floor`, `in_mountain`, `underground`, `in_nether` (the `VerticalPlacement` enum in this order) | vertical placement rule (8.3) |
| `air_pocket_probability` | float 0 to 1 | chance of an air pocket (8.2 step 3) |
| `mossiness` | float 0 to 1 | `BlockAgeProcessor` input |
| `overgrown` | bool | leaves above netherrack |
| `vines` | bool | vines on exposed blocks |
| `can_be_cold` | bool | the piece may be "cold" (8.2 step 9) |
| `replace_with_blackstone` | bool | adds `BlackstoneReplaceProcessor` |
| `weight` | float | relative weight when there are several setups |

The seven structure definitions (data): `ruined_portal` has two setups (weight 0.5 each): `underground` with air pocket probability 1.0 and `on_land_surface` with 0.0 (both mossiness 0.2, can be cold); `ruined_portal_desert`: `partly_buried`, mossiness 0, not cold; `ruined_portal_jungle`: `on_land_surface`, mossiness 0.8, overgrown, vines, not cold;
`ruined_portal_swamp`: `on_ocean_floor`, mossiness 0.5, vines, not cold; `ruined_portal_mountain`: `in_mountain` (air pocket 1.0) and `on_land_surface` (0.0), weight 0.5 each, mossiness 0.2, can be cold; `ruined_portal_ocean`: `on_ocean_floor`, mossiness 0.8, can be cold; `ruined_portal_nether`: `in_nether`, no mossiness, replace with blackstone. All have step `surface_structures` and no spawn overrides.

### 8.2 `findGenerationPoint` (random order, all from the start random)

1. **Setup.** One setup: no draw. Several: `total = sum of weights`; `r = nextFloat()`; for each setup in order `r = r - weight / total`, the first setup with `r < 0` is chosen (exactly one draw).
2. (The chosen setup `S` is used below.)
3. **Air pocket.** `sample(random, S.air_pocket_probability)`: false at probability 0 and true at probability 1 with **no draw**; otherwise `nextFloat() < p`.
4. **Template.** `nextFloat() < 0.05`: one of the three giant portals `ruined_portal/giant_portal_1..3`, index `nextInt(3)`; else one of the ten `ruined_portal/portal_1..10`, index `nextInt(10)`. (The draw order is the `nextFloat` first, then the `nextInt`.) Sizes (data, from the NBT headers): giant 1 11 x 17 x 16, giant 2 11 x 16 x 16, giant 3 16 x 16 x 16; the ten normal portals span, per axis, x 5 to 14, y 7 to 12 and z 6 to 10 (`portal_2` is 9 x 12 x 9, `portal_10` is 12 x 8 x 10, `portal_1` is 6 x 10 x 6, `portal_6` is 5 x 7 x 7, `portal_8` is 14 x 9 x 9, `portal_5` is 10 x 10 x 7).
5. **Rotation and mirror.** `Rotation = Util.getRandom(Rotation.values(), random)` (`nextInt(4)` over none, clockwise_90, clockwise_180, counterclockwise_90); then `nextFloat() < 0.5` gives mirror `none`, else `front_back`.
6. **Pivot.** `(sizeX / 2, 0, sizeZ / 2)` of the unrotated template (integer division).
7. **Box and column.** `origin = (chunk.minBlockX, 0, chunk.minBlockZ)`; `box = template.getBoundingBox(origin, rotation, pivot, mirror)` (section 2.6); `c = box.getCenter()`; `surface = noiseGenerator.getBaseHeight(c.x, c.z, heightmap(S.placement)) - 1` with `heightmap = OCEAN_FLOOR_WG` for `on_ocean_floor` and `WORLD_SURFACE_WG` for every other placement (the y of the top block of the base terrain, 10).
8. **`y = findSuitableY(random, generator, placement, airPocket, surface, ySpan = box.getYSpan(), box, ...)`** (8.3).
9. **Piece.** `pos = (chunk.minBlockX, y, chunk.minBlockZ)` is both the stub position (used for the biome check) and the piece's `templatePosition`. `cold = S.can_be_cold && biome(noise biome at QuartPos of pos).coldEnoughToSnow(pos, seaLevel)` (33 section 4.5; the `can_be_cold` test short-circuits so no biome lookup otherwise). `Properties(cold, S.mossiness, airPocket, S.overgrown, S.vines, S.replace_with_blackstone)`.
   The piece is `RuinedPortalPiece(registryAccess, manager, pos, S.placement, properties, templateId, template, rotation, mirror, pivot)`.

### 8.3 `findSuitableY`

`minY` below is the level's min y (-64 overworld, 0 Nether); `limit = minY + 15`.

| Placement | Candidate `y` (before the lowering loop) |
|---|---|
| `in_nether` | air pocket true: `rbi(32, 100)`; false: `nextFloat() < 0.5` then `rbi(27, 29)`, else `rbi(29, 100)` |
| `in_mountain` | `v = surface - ySpan`; `getRandomWithinInterval(70, v)`: `rbi(70, v)` when `70 < v`, else `v` (no draw) |
| `underground` | `v = surface - ySpan`; `getRandomWithinInterval(limit, v)`: `rbi(limit, v)` when `limit < v`, else `v` |
| `partly_buried` | `(surface - ySpan) + rbi(2, 8)` |
| `on_land_surface`, `on_ocean_floor` | `surface` (no draw) |

Then the **lowering loop**: four columns are fetched from the generator's base columns (`getBaseColumn`, 10) at the corners `(box.minX, box.minZ)`, `(box.maxX, box.minZ)`, `(box.minX, box.maxZ)`, `(box.maxX, box.maxZ)`; the opacity test is the heightmap predicate of `OCEAN_FLOOR_WG` for `on_ocean_floor` and `WORLD_SURFACE_WG` otherwise (35-1 section 4.2: `OCEAN_FLOOR_WG` = block in tag `blocks_motion_in_heightmap`;
`WORLD_SURFACE_WG` = not air). Starting at the candidate, **while `y > limit`**: count the columns whose block at `y` passes the test; if the count reaches exactly 3 stop and return this `y`; else `y -= 1`. The result is the `y` where the loop stopped or `y <= limit`.
(When the candidate is already `<= limit` it is returned unchanged.) All draws are from the start random; `in_nether` ignores the surface and the loop uses the Nether's `minY = 0`, so `limit = 15`.
Worked consequence for the Nether setup: with the air pocket false (setup `in_nether`, probability 0.0) the candidate `y` is uniform on 27 to 29 with probability 0.5 (each 0.5/3) and uniform on 29 to 100 otherwise (72 values, each 0.5/72), before lowering (agrees with 37-6 section 6).

### 8.4 The piece

`RuinedPortalPiece` extends `TemplateStructurePiece`; extras saved: `Rotation`, `Mirror` (the legacy string codecs, Open question 5), `VerticalPlacement` (the enum's serialized name, lower case), `Properties` (a compound `cold`, `mossiness`, `air_pocket`, `overgrown`, `vines`, `replace_with_blackstone`).
A piece restored from NBT rebuilds its pivot as `(sizeX / 2, 0, sizeZ / 2)` and its settings with the same function as a new one.

**Place settings** (`makeSettings(mirror, rotation, verticalPlacement, pivot, properties)`), processors in order:

1. `BlockIgnoreProcessor`: `STRUCTURE_BLOCK` when `airPocket` is true (so the template's air is placed and carves a pocket), else `STRUCTURE_AND_AIR` (air is not placed).
2. `RuleProcessor` with the rules, in this order:
   a. `gold_block` to `air`: `RandomBlockMatchTest(gold_block, 0.3)`;
   b. the lava rule: `on_ocean_floor`: `lava` to `magma_block` (`BlockMatchTest`, always); else `cold`: `lava` to `netherrack` (always); else `RandomBlockMatchTest(lava, 0.2)` to `magma_block`;
   c. only when `cold` is false: `RandomBlockMatchTest(netherrack, 0.07)` to `magma_block`.
   All rules use `AlwaysTrueTest` as the location predicate and no position predicate.
3. `BlockAgeProcessor(mossiness)` (2.7; 36-2 section 9.9).
4. `ProtectedBlockProcessor(tag features_cannot_replace)`.
5. `LavaSubmergedBlockProcessor`.
6. `BlackstoneReplaceProcessor` only when `replaceWithBlackstone`.
Rotation and mirror as drawn, pivot as above; liquid settings default (`apply_waterlogging`); entities not ignored (the templates have none); known shape false; flags 2.
Template jigsaw blocks (for example `portal_1` has one with `final_state minecraft:netherrack`) are replaced by their `final_state` after the template (section 2.5 step 4); a template chest carries `LootTable: minecraft:chests/ruined_portal` in its NBT (data, read in `portal_1` and `giant_portal_1`), so the chest's seed is the `LootTableSeed` of section 2.6 step 2.

**`postProcess`** (the ruined portal does not use the frame's generic call; in this order):

1. `b = template.getBoundingBox(placeSettings, templatePosition)`. **If `writeBox` does not contain `b.getCenter()` the call ends**: the portal and everything below is generated only in the chunk pass whose write box contains the centre of the portal's box.
2. `writeBox.encapsulate(b)` (the write box now includes the whole portal for this call).
3. The template piece post-process (2.5): placement, markers, jigsaw replacement.
4. `spreadNetherrack(random, level)` (8.5).
5. `addNetherrackDripColumnsBelowPortal(random, level)` (8.6).
6. If `vines` or `overgrown`: for every position of the piece's box in `BlockPos.betweenClosed` order (`x` fastest, then `y`, then `z`): if `vines` then `maybeAddVines(random, level, pos)`; if `overgrown` then `maybeAddLeavesAbove(random, level, pos)` (both for the same position, vines first).

### 8.5 `spreadNetherrack`

Inputs: `flag = (placement is on_land_surface or on_ocean_floor)`; `(cx, cz)` = the piece box's centre column; the table `P[0..13]` = `1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.9, 0.9, 0.8, 0.7, 0.6, 0.4, 0.2` (14 entries); `R = 14` (its length).

1. `avg = (box.xSpan + box.zSpan) / 2`; `offset = random.nextInt(max(1, 8 - avg / 2))` (one draw).
2. For `x = cx - 14 .. cx + 14` (outer), `z = cz - 14 .. cz + 14` (inner):
   a. `d = |x - cx| + |z - cz|`; `k = max(0, d + offset)`; if `k >= 14` skip the column (no draw);
   b. `random.nextDouble() < (double) P[k]` else skip;
   c. `sy = level.getHeight(heightmap(placement), x, z) - 1` (`OCEAN_FLOOR_WG` for `on_ocean_floor`, else `WORLD_SURFACE_WG`; section 2.1 of 35-1, the top block y);
   d. `y = flag ? sy : min(box.minY, sy)`; position `(x, y, z)`; skip when `|y - box.minY| > 3`;
   e. skip unless `canBlockBeReplacedByNetherrackOrMagma(state at the position)`;
   f. `placeNetherrackOrMagma(position)`; if `overgrown`: `maybeAddLeavesAbove(position)`; then `addNetherrackDripColumn(position.below())`.

`canBlockBeReplacedByNetherrackOrMagma(state)`: false for `air` (only the block `air`), `obsidian`, any block in the tag `features_cannot_replace`, and (unless the placement is `in_nether`) `lava`; true otherwise.
`placeNetherrackOrMagma(random, level, pos)`: if the state at `pos` passes the test above: when `cold` is false and `nextFloat() < 0.07` place `magma_block`, else `netherrack` (`setBlockAndUpdate`; the `nextFloat` is drawn only when `cold` is false).

### 8.6 Drip columns, vines, leaves

`addNetherrackDripColumn(random, level, pos)`: `cur = pos`; `placeNetherrackOrMagma(cur)`; `n = 8`; while `n > 0` and `nextFloat() < 0.5`: move `cur` down one, `n -= 1`, `placeNetherrackOrMagma(cur)` (so at most nine cells).
`addNetherrackDripColumnsBelowPortal`: for `x` from `box.minX + 1` up to but excluding `box.maxX` (outer) and `z` from `box.minZ + 1` up to but excluding `box.maxZ` (inner): `p = (x, box.minY, z)`; if the state at `p` is `netherrack`: `addNetherrackDripColumn(p.below())`.
`maybeAddLeavesAbove(random, level, pos)`: `nextFloat() < 0.5` (first) and the state at `pos` is `netherrack` and the state above is air: set `jungle_leaves[persistent=true]` above (`setBlockAndUpdate`).
`maybeAddVines(random, level, pos)`: let `s` = state at `pos`; if `s` is air or `vine` return; `d` = random horizontal direction (`nextInt(4)` over north, east, south, west); `q = pos + d`; if the state at `q` is not air return; if `Block.isFaceFull(s.getCollisionShape(level, pos), d)` is false return; set `vine` at `q` with the property of face `opposite(d)` true (`setBlockAndUpdate`).
(The draw order inside `maybeAddVines`: the direction is drawn only after the air/vine test; the leaves draw is the first action of `maybeAddLeavesAbove`.)

### 8.7 Nether specifics

The Nether structure (`ruined_portal_nether`) is selected only where its biome tag matches (37 section 6): setup `in_nether`, air pocket probability 0.0 (the sampling consumes no random), blackstone replacement on, lava not replaceable by netherrack/magma in the spread (`in_nether` test of 8.5), the `y` of 8.3, `cold` false, `mossiness` 0.0 (so the mossy branches never trigger, but `BlockAgeProcessor` still changes stone, stone bricks and chiseled stone bricks to cracked stone bricks or stone-brick stairs with probability 0.5, stairs to stone or stone brick slabs with probability 0.5 and obsidian to crying obsidian with probability 0.15: those branches do not depend on `mossiness`).
This resolves 37-6 Open questions 5 and 12 (the spread and the swap table) and the processor order of its section 6.

---

## 9. Nether fossil

### 9.1 `NetherFossilStructure.findGenerationPoint` (start random)

Structure data: field `height` (a height provider, 23 section 7; the vanilla value is `uniform` from `absolute 32` to `below_top 2`), step `underground_decoration`, terrain adaptation `beard_thin`, biome tag `has_structure/nether_fossil` (soul sand valley).

1. `x = chunk.minBlockX + nextInt(16)`, then `z = chunk.minBlockZ + nextInt(16)`.
2. `seaLevel = generator.getSeaLevel()` (32 in the Nether); `y = height.sample(random, WorldGenerationContext(generator, heightAccessor))` (draws as the provider does: 23 section 7).
3. `column = generator.getBaseColumn(x, z, heightAccessor, randomState)`.
4. While `y > seaLevel`: `a = column.getBlock(y)`; `y -= 1`; `b = column.getBlock(y)`; if `a` is air and (`b` is `soul_sand` or `b.isFaceSturdy(empty getter, (x, y, z), up)`) stop (`y` is now the support block's y); else continue.
5. If `y <= seaLevel` there is no start. Otherwise the stub position is `(x, y, z)` (the y of the solid block under the air cell), and the piece builder runs `NetherFossilPieces.addPieces(manager, builder, random, (x, y, z))`: `rotation = Rotation.getRandom(random)` (`nextInt(4)`), then `template = FOSSILS[nextInt(14)]` (`nether_fossils/fossil_1 .. fossil_14` in that order), then one `NetherFossilPiece(template, pos, rotation)`.
(Resolves 37-6 section 7: rotation draw first, then template; confirmed.)

### 9.2 The piece

`NetherFossilPiece` (id `NeFos`) is a template piece; saved extra `Rot`. Settings: the rotation, mirror none, default pivot (0, 0, 0), processor `BlockIgnoreProcessor.STRUCTURE_AND_AIR`, default liquid settings; the template's air is not placed, so the fossil does not carve. Template sizes (data): the fourteen fossils span, per axis, x 2 to 7, y 1 to 7 and z 1 to 7 (`fossil_5` is 2 x 5 x 1, `fossil_14` is 7 x 7 x 6, `fossil_11` is 5 x 5 x 7); each has a palette of 3 entries and no entities.
`handleDataMarker` does nothing.

`postProcess(level, sm, gen, random, writeBox, chunkPos, pivot)`:

1. `b = template.getBoundingBox(placeSettings, templatePosition)`; `writeBox.encapsulate(b)` (so the whole fossil is written in every pass that reaches it, **not** clipped to the chunk: resolves 37-6 Open question 14: the dried ghast bound is the template box, which is inside the encapsulated write box);
2. the template piece post-process (2.5);
3. `placeDriedGhast(level, random, b, writeBox)`.

### 9.3 Dried ghast

`rnd = createThreadLocalInstance(worldSeed).forkPositional().at(b.getCenter())` (2.1; the piece `random` argument is not used). **50 percent gate:** `nextFloat() < 0.5` is a gate, not a position draw. If the float is `>= 0.5` the method returns at once: nothing is placed and none of the following draws happen. Otherwise, in this order: `x = b.minX + nextInt(b.xSpan)`, `y = b.minY`, `z = b.minZ + nextInt(b.zSpan)` (in that order, then the air and write-box test); if the state at `(x, y, z)` is air and `writeBox` contains it, the `Rotation.getRandom(rnd)` draw is taken as the block is set:
`setBlock(pos, dried_ghast.rotate(Rotation.getRandom(rnd)), 2)` (the default state of `dried_ghast` facing north rotated by a random one of the four rotations: 24, 29b). Because `rnd` depends only on the world seed and the box centre, every pass computes the same position.

### 9.4 The overworld fossils

The overworld `fossil_upper` and `fossil_lower` are placed features (`fossil` feature type, templates under `structure/fossil/*`, 8 skulls and 8 spines in a plain and a coal variant): 35-6 section 10. They are not structure starts and do not appear in a structure set.

---

## 10. Saved piece data

| Piece (id) | Keys beyond `id`, `BB`, `O`, `GD` |
|---|---|
| `TeDP` desert pyramid | `Width`, `Height`, `Depth`, `HPos`, `hasPlacedChest0`, `hasPlacedChest1`, `hasPlacedChest2`, `hasPlacedChest3` (booleans). The sand positions and the roof position are not saved |
| `TeJP` jungle temple | `Width`, `Height`, `Depth`, `HPos`, `placedMainChest`, `placedHiddenChest`, `placedTrap1`, `placedTrap2` |
| `TeSH` swamp hut | `Width`, `Height`, `Depth`, `HPos`, `Witch`, `Cat` |
| `Iglu` | `Template` (`minecraft:igloo/top`, `.../middle`, `.../bottom`), `TPX`, `TPY`, `TPZ`, `Rot` |
| `BTP` buried treasure | none |
| `RUPO` ruined portal | `Template`, `TPX`, `TPY`, `TPZ`, `Rotation`, `Mirror`, `VerticalPlacement`, `Properties` |
| `NeFos` nether fossil | `Template` (`minecraft:nether_fossils/fossil_N`), `TPX`, `TPY`, `TPZ`, `Rot` |

For all, a missing integer reads as 0 and a missing boolean as false; `O` -1 reads as no orientation.

---

## 11. Loot placement summary

| Container | Where | Table (data) | Seed |
|---|---|---|---|
| Desert pyramid chests (up to 4) | (10,-11,8), (12,-11,10), (10,-11,12), (8,-11,10) local, in that order | `chests/desert_pyramid` | `random.nextLong()` each, at creation |
| Desert pyramid suspicious sand (5 to 7 in the cellar plus 1 on the roof) | section 3.5 | `archaeology/desert_pyramid` | `pos.asLong()` |
| Jungle temple main chest | (8,-3,3) | `chests/jungle_temple` | `random.nextLong()` |
| Jungle temple hidden chest | (9,-3,10) | `chests/jungle_temple` | `random.nextLong()` |
| Jungle temple dispensers | (3,-2,1) facing north; (9,-2,3) facing west | `chests/jungle_temple_dispenser` | `random.nextLong()` each |
| Swamp hut | no container | none | none |
| Igloo basement chest | template chest at local (1,1,6) of `igloo/bottom`, marker at (1,2,6) | `chests/igloo_chest` | `random.nextLong()` of the marker (after the template-placement draws) |
| Buried treasure chest | section 7.2 | `chests/buried_treasure` | `random.nextLong()` |
| Ruined portal chest | the chest of the template (NBT `LootTable`) | `chests/ruined_portal` | `LootTableSeed = random.nextLong()` at template placement |
| Nether fossil | no container | none | none |

`random` is the piece random of section 2.1 in every row. The tables are rolled when the container is opened or brushed (26, 31).

---

## 12. Worked examples

1. **World mapping of a scattered piece.** A desert pyramid box after the height move is `(100, 70, 200) - (120, 84, 220)` (21 x 15 x 21). Local `(2, 10, 4)`: north: world `(100 + 2, 70 + 10, 220 - 4) = (102, 80, 216)`; south: `(102, 80, 200 + 4) = (102, 80, 204)`; west: `(120 - 4, 80, 200 + 2) = (116, 80, 202)`; east: `(100 + 4, 80, 202) = (104, 80, 202)`.
   For a jungle temple (12 x 15) at chunk origin `(160, 96)` facing west the box is `(160, 64, 96) - (174, 73, 107)` (x runs the 15-block depth); local `(1, 0, 0)` maps to `(174 - 0, 64, 96 + 1) = (174, 64, 97)`. The `stairs[facing=north]` placed there is turned by mirror left_right then rotation clockwise_90 (section 2.3 table) before it is stored.
2. **Start direction (computed).** World seed 12345, start chunk (1, 0): `setLargeFeatureSeed` gives the LCG seed 6674089274190693128; the first `nextInt(4)` is 0, so the direction is north (index 0 of north, east, south, west). Start chunk (0, 0): the seed is 12345 itself (both products are 0) and the first `nextInt(4)` is 1: east. Start chunk (-3, 5): seed 4618952514148168460, first `nextInt(4)` is 2: south.
3. **Template transform.** `portal_5` has size (10, 10, 7); pivot `(5, 0, 3)`; rotation clockwise_90, mirror none: `transform((0,0,0)) = (5 + 3 - 0, 0, 3 - 5 + 0) = (8, 0, -2)`; `transform((9, 9, 6)) = (8 - 6, 9, -2 + 9) = (2, 9, 7)`; the box is x 2..8, y 0..9, z -2..7 (span 7 x 10 x 10: the horizontal sizes swapped), then moved by the template position. Counterclockwise_90 of local `(0, 0, 0)`: `(5 - 3 + 0, 0, 5 + 3 - 0) = (2, 0, 8)`.
4. **Igloo basement positions.** Chunk origin `(160, 96)`, `pos = (160, 90, 96)`, `n = 6` (so `nextInt(8) = 2`): laboratory depth offset 18: `templatePosition = (160, 90 - 3 - 18, 96 - 2) = (160, 69, 94)`; ladders `i = 0 .. 4` (five pieces) at `(160 + 2, 90 - 3 - 3i, 96 + 4) = (162, 87, 100), (162, 84, 100), (162, 81, 100), (162, 78, 100), (162, 75, 100)`; top at `(160, 90, 96)`. Order of pieces: laboratory, five ladders, top (7 pieces = `n + 1`).
5. **Fisher-Yates in the suspicious sand pick.** List `[a, b, c, d]`, draws `nextInt(4) = 1`, `nextInt(3) = 0`, `nextInt(2) = 1`: `i = 4, j = 1`: swap positions 3 and 1: `[a, d, c, b]`; `i = 3, j = 0`: swap positions 2 and 0: `[c, d, a, b]`; `i = 2, j = 1`: swap positions 1 and 1: unchanged. Result `[c, d, a, b]`. With 83 candidates and a `nextInt(5, 8)` draw of 1, the count is `5 + 1 = 6`: the first six entries of the shuffled list become suspicious sand and the other 77 plain sand.
6. **Buried treasure chunk test (computed).** World seed 0, chunk (1, 0): `setLargeFeatureWithSalt(0, 1, 0, 10387320)` = `1 * 341873128712 + 0 + 0 + 10387320 = 341883516032`; the first `nextFloat()` of a Java LCG seeded with it is 0.9613574 (computed) which is not below 0.01: no treasure. Chunk (0, 0): seed 10387320, `nextFloat() = 0.7193757` (computed): no. The start position for chunk (3, -2) (if accepted) is `(3 * 16 + 9, 90, -2 * 16 + 9) = (57, 90, -23)`.
7. **Ruined portal netherrack spread table.** Portal box 6 x 6 in X and Z: `avg = 6`; `nextInt(max(1, 8 - 3)) = nextInt(5)`, say 2. A column with `|dx| + |dz| = 5` has `k = 7` and `P[7] = 0.9`: `nextDouble() < 0.9` places; a column at distance 12 has `k = 14 >= 14` and is skipped without a draw.
8. **Ruined portal Y.** Setup `underground`, `surface = 70`, `ySpan = 10`, `minY = -64`: `limit = -49`, `v = 60`; the candidate is `rbi(-49, 60)`; if the candidate is 20 and only two corner columns have a solid block at y = 20 the loop moves down to the first `y` where three of four columns do.

---

## 13. Validation

| # | Item | How checked | Expected |
|---|---|---|---|
| V1 | Piece ids | read `StructurePieceType` static initialiser | `TeDP`, `TeJP`, `TeSH`, `Iglu`, `BTP`, `RUPO`, `NeFos` |
| V2 | Loot ids | `BuiltInLootTables` strings | `chests/desert_pyramid`, `chests/jungle_temple`, `chests/jungle_temple_dispenser`, `chests/igloo_chest`, `chests/buried_treasure`, `chests/ruined_portal`, `archaeology/desert_pyramid` |
| V3 | Piece sizes | `ScatteredFeaturePiece` constructor arguments | desert 21 x 15 x 21, jungle 12 x 10 x 15, swamp 7 x 7 x 9, all at y 64 |
| V4 | Struct counts | `unzip -Z1 jar \| grep -v '/$' \| grep 'structure/nether_fossils/' \| wc -l`; `.../ruined_portal/`; `.../igloo/` | 14; 13 (10 normal + 3 giant); 3 |
| V5 | World mapping | place a probe block at local `(1, 0, 2)` for all four orientations on a known box and compare with the table of 2.3 and example 1 | table values |
| V6 | Stair mirror | placed stairs facing north on a south-oriented piece face south (mirror left_right) | south |
| V7 | Desert cellar | after generation the cellar room volume (5 x 3 x 5 plus 8) holds only sand and suspicious sand, the suspicious count in it is 5 to 7 (plus the roof block) | counts |
| V8 | Jungle moss | over 10000 `R` cells the mossy fraction is 0.6 (0.4 cobble) | ~0.6 |
| V9 | Ruined portal gate | a portal whose box centre is outside every decorated chunk's write box in a pass is not generated in that pass | no blocks |
| V10 | Spread table | the probability table has 14 entries and ends at 0.2 | as 8.5 |
| V11 | Fossil height rule | with `y` starting at 40 and an air cell over soul sand at y 35 the start `y` is the soul sand's y | 35 |
| V12 | Buried treasure | a chest exists whose block below was one of the five stones; the six neighbour cells are filled | structure |
| V13 | Start random | seed 12345, chunk (1, 0): first `nextInt(4)` is 0 | example 2 |

---

## Open questions

1. Closed. The pairing of the four `frequency_reduction_method` names with the reducer functions is read directly from the enum's static initialiser (section 2.2 item 7); `legacy_type_2` uses `setLargeFeatureWithSalt(.., 10387320)` and accepts when `nextFloat() < frequency`. 36-1 section 4.4 states the same.
2. The default `variant` of an entity created with `EntityType.create` and `finalizeSpawn(STRUCTURE)` for the swamp hut's cat (which variant is chosen), and whether `finalizeSpawn` of a `Witch` or `Cat` draws randoms: the entity documents (45, 19) should answer; not read here.
3. The data pack `datapacks/trade_rebalance` is read (pack.mcmeta enables feature flag `minecraft:trade_rebalance`; five loot-table overrides listed in section 1 note (e)). Whether that flag is on by default was not read (searched the pack's `pack.mcmeta` and file list only); the feature-flag document should answer.
4. Closed. `BlockPos.asLong` packing read from the static initialiser (section 2.1).
5. `Rotation.LEGACY_CODEC`, `Mirror.LEGACY_CODEC` and `StringRepresentable` codecs of the saved `Rot`, `Rotation`, `Mirror`, `VerticalPlacement` keys were not read (their string spellings are inferred to be the enum names in lower or upper case).
6. Closed. `RuleTest.testAgainstWorldState(level, pos, random)` is exactly `test(level.getBlockState(pos), pos, random)` (read; section 2.7).
7. `NoiseColumn` contents of `getBaseColumn` (used by the ruined portal's lowering loop and by the nether fossil): the noise generator's base column is the unmodified noise terrain without carvers, features or surface rules (10); not re-read here.
8. The rules for writes that fall outside the world-generation region's write window (the ruined portal's spread reaches up to 14 blocks beyond a box that can be 16 wide, the igloo shaft, the nether fossil): 35-1 section 4.1 is relied on; the effective clipping for each of these pieces was not measured.
9. Closed. The `StructureTemplateManager` loading path, the NBT handling and the template palettes are 36-2 sections 1 and 2; the chunk-status timing of `placeInChunk` and the references are 36-1 sections 7 and 8.
10. The behaviour of the pieces' blocks on rotation or mirror (`rotate`, `mirror` of stairs shape, tripwire hook, redstone wire sides, piston, repeater, lever, vine, dispenser) is in 24, 29 and 30 and was not re-read; the geometry tables list the states exactly as constructed (pre-orientation).
11. The jungle temple puzzle's intended solution (which lever opens the hidden chest) follows from the redstone and piston rules and the states in section 4.4; it was not simulated.
12. Steps 15 and 16 of section 3.3 are transcribed from the order of the `placeBlock` calls; the grouping into three cells per `y` row is a reading aid and the call order is the one stated.
13. Partly closed. `StructureStart.placeInChunk` iterates the stored piece list in order (36-1 section 8), so the order is fixed; the claim that the desert pyramid's output does not depend on reload still relies on `postProcess` recomputing the candidate list each call and on `hasPlacedChest` being the only persisted state (both read).
14. The data tags `features_cannot_replace` (and the tag contents of `blocks_motion_in_heightmap`) are data, taken from the tool; their members were not listed here.
15. `Mth.getSeed` of a position in the processor random uses the world position of the processed block (the processed info's position); the jar was read for `RuleProcessor` and `BlockAgeProcessor` only; the same positional-random convention in other processors (jigsaw, capped) is not covered.
16. The within-step order of structures used for `structureIndexInStep` (section 2.1) is stated by 36-1 section 8 as the registry listing order of `worldgen/structure`; whether that is id order, the order of the data-pack load or another order, and hence the exact index of each of these structures, was not traced here (36-1 Open question 5 records the same gap for reference maps).
17. Structure-set selection among the seven `ruined_portal` structures that share one structure set (weights, biome filtering, exclusion zones) is not described here; it belongs to 36-1 sections 3.2 and 4. The block-entity and loot behaviour of the template chest, brewing stand and furnace is deferred to 31.
