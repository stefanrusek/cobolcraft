# World generation features, part 5: water, ice, disks, blobs, corals and surface features

This document specifies the world-generation feature classes of Java Edition 26.3 that shape water, ice and the ground surface:
lava and sulfur-water lakes, fluid springs, disks, forest rocks, replacement blobs, the snow and ice top layer, icebergs, blue
ice, the flat-world layer filler, block piles, seagrass, sea pickles, kelp columns, corals, underwater magma, ice spikes, the desert well
and the bonus chest. It is written in prose, tables and formulas only. The data (configured features, placed features, tags) is
extracted from the user's jar by the extraction tool (22, 23) and is **not** tabulated here except where a value of that data fixes an
engine behaviour or a worked example; this document specifies the schema, the semantics and the engines.

| Item | Value |
|---|---|
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data JSON under `data/minecraft/worldgen/`, `data/minecraft/tags/block/` and `data/minecraft/structure/` in the jar, with no execution. Class names are not obfuscated. |
| Scope | The classes `LakeFeature`, `SpringFeature`, `DiskFeature`, `BlockBlobFeature`, `ReplaceBlobsFeature`, `SnowAndFreezeFeature`, `IcebergFeature`, `BlueIceFeature`, `FillLayerFeature`, `BlockPileFeature`, `CoralTreeFeature`, `CoralClawFeature`, `UnderwaterMagmaFeature`, `SpikeFeature` (ice spikes), `BonusChestFeature`, plus the data-driven compositions that make seagrass, sea pickles, kelp, coral decoration and the desert well (§2.2). |
| Operator decision | Standard Minecraft content is the target (ticket CC-0001); a COBOL tool extracts the vanilla data pack, so data rows are not listed here. |
| Siblings | The other parts of the 35 family: 35-worldgen-features-1-model-and-placement (feature model, placement modifiers, `FeaturePlacer`, generic composition features), -2-predicates-and-providers, -3-tree-placers, -4-decorators-and-vegetation (which also holds `WaterloggedVegetationPatchFeature`, section 9), -6-underground and -7-nether-end-misc. This document cites them as "35-N section S" (for example 35-1 section 8) and never repeats them; where it needs a fact from them for a worked example it states the fact it read itself and says so. Structure templates and their processors are in the structure documents of the 35 family and 36 onward, cited by topic. |

Conventions. "Float" is IEEE single precision, "double" is IEEE double precision; every formula says which one is used, because the
iceberg and block-pile formulas mix both. `nextInt(n)`, `nextFloat()`, `nextDouble()`, `nextBoolean()` are the operations of the
feature's random source, which is the decoration `WorldgenRandom` described in 11 section 4 and 11 section 6.3 (the Java-LCG definitions on
top of a Xoroshiro-wrapped source); a draw order stated here is the order of the calls in the artifact. A "draw" is one call. Coordinates
are `(x, y, z)`; `pos` is the position the feature is placed at (the output of the last placement modifier; with no modifier, the decoration origin
`(16 cx, -64, 16 cz)` of 11 section 6.1). Values marked "(inferred)" were deduced and are repeated in Open questions; "(recalled, not verified)" marks a
statement not read in this round. Worked examples marked "(computed)" were calculated by applying the rules of this document, not observed.

## 1. Shared facts used by the features

### 1.1 Block-write flags and helpers

| Name | Value / behaviour | Source |
|---|---|---|
| `setBlock(pos, state, 2)` | write with flag 2 (`UPDATE_CLIENTS`); the flag every feature of this document uses except as noted | `Block.UPDATE_CLIENTS = 2` |
| `Feature.setBlock(level, pos, state)` (the default helper, used by iceberg, spike, blob features) | `setBlockAndUpdate`, which is `setBlock(pos, state, 3)` (`UPDATE_ALL = 3`) | `LevelWriter.setBlockAndUpdate` |
| flag 260 (`UPDATE_NONE`) | `UPDATE_INVISIBLE (4)` plus `UPDATE_SKIP_BLOCK_ENTITY_SIDEEFFECTS (256)`; used by block piles | `Block.UPDATE_NONE = 260` |
| `scheduleTick(pos, block_or_fluid, delay)` | queues a block or fluid tick | used by lake, spring, simple block |
| `markAboveForPostProcessing(level, pos)` | for `i = 0, 1`: move up one block; if the block there is air, stop; otherwise ask the chunk of that position to mark the position for post-processing (the chunk's post-processing list, 29 and 33). At most two blocks above `pos` are marked, and the walk stops at the first air block | `Feature.markAboveForPostProcessing` |
| block-write window | writes outside the 3 x 3 chunk window around the chunk being decorated are refused (11 section 6.5); a refused write is a skipped block | 11 section 6.5 |

### 1.2 Iteration orders and random helpers

| Helper | Definition |
|---|---|
| `betweenClosed(a, b)` | all positions of the box with corners `a`, `b` (min and max taken per axis), **x varies fastest, then y, then z slowest**, both ends inclusive (`BlockPos$4`: the running index modulo the width gives x, then modulo the height gives y, the rest z) |
| `betweenClosedStream(box)` | same order, as a sequential, lazily evaluated stream: each element passes through every `filter` and `map` stage before the next element is produced, so a block written for element k is visible to the checks of element k+1 |
| `withinBoxByManhattanDistance(c, rx, ry, rz)` | the positions `p` with `abs(dx) <= rx`, `abs(dy) <= ry`, `abs(dz) <= rz` (offsets from `c`) and Manhattan distance at most `rx + ry + rz`, enumerated in non-decreasing Manhattan distance (`BlockPos$3`: an outer counter `currentDepth` from 0 up) |
| `Direction` enum order | DOWN, UP, NORTH, SOUTH, WEST, EAST (the order of the constants in the static initialiser; `Direction.values()` follows it). NORTH is `(0, 0, -1)`, SOUTH `(0, 0, +1)`, WEST `(-1, 0, 0)`, EAST `(+1, 0, 0)` (all read from the `Direction` static initialiser, as are DOWN `(0, -1, 0)` and UP `(0, 1, 0)`) |
| `Direction.Plane.HORIZONTAL` | the list NORTH, EAST, SOUTH, WEST (the array in the plane's static initialiser; `Plane.iterator()` returns `Iterators.forArray(faces)`, so iteration follows that array order; read) |
| `getClockWise` / `getCounterClockWise` (horizontal) | read from the two ordinal tables: clockwise NORTH to EAST, EAST to SOUTH, SOUTH to WEST, WEST to NORTH; counter-clockwise NORTH to WEST, WEST to SOUTH, SOUTH to EAST, EAST to NORTH |
| `Util.getRandom(list or array)` | `list[nextInt(size)]` |
| `Direction.Plane.getRandomDirection(r)` | `Util.getRandom` over the plane's array: `HORIZONTAL[nextInt(4)]` (N, E, S, W order) |
| `Direction.getRandom(r)` | `Util.getRandom` over all six directions in enum order (`nextInt(6)`) |
| `Util.shuffle(list, r)` (also `shuffledCopy`, `toShuffledList`, `Plane.shuffledCopy`) | for `i = size` down to `2`: `j = nextInt(i)`; swap the elements at `i - 1` and `j`. The `IntStream` version used by the bonus chest does the same on ints. One draw per step, `size - 1` draws in all |
| `WeightedList.getRandom(r)` (and `getRandomOrThrow`) | `v = nextInt(totalWeight)`; walk the entries in list order subtracting each weight; the entry at which the running value first becomes negative is chosen (the flat selector for total weight below 64 and the compact selector implement the same rule). A list with total weight 0 gives no choice and no draw |
| `HolderSet.getRandomElement(r)` for a tag | `Util.getRandomSafe(contents, r)`: `contents[nextInt(size)]`, `contents` being the tag's element list in resolution order (tag expansion: 14.3); an empty list gives no choice and no draw |
| `IntProvider` `uniform` / `trapezoid` | `uniform`: 11 section 4. `trapezoid(min, max, plateau)` with `plateau == 0` and `max == -min` is `nextInt(max + 1) - nextInt(max + 1)` (two draws, in that order; read in `TrapezoidInt.sample`). With `max == 0` these are two `nextInt(1)` calls returning 0; each `nextInt(1)` consumes exactly one `next(31)` step (read: the default `nextInt(int)` of `BitRandomSource` takes the power-of-two branch for a bound of 1 and returns the bound times `next(31)` shifted right by 31; it throws for a bound of 0 or less; the `next(31)` step is the 48-bit LCG of multiplier 25214903917, increment 11, mask 2^48-1, because `WorldgenRandom` overrides only `next(int)`) |
| `Mth.ceil(f)` | `(int) Math.ceil((double) f)` |
| `Mth.clamp(v, lo, hi)` (float) | `v < lo ? lo : min(v, hi)` |

### 1.3 How composed features are executed

| Construct | Behaviour (read) |
|---|---|
| `PlacedFeature.place(level, generator, r, pos)` | runs the placed feature's modifier list from `pos` (in this version the position-stack engine is `net.minecraft.world.level.levelgen.placement.FeaturePlacer`; `PlacedFeature.place` only builds one and delegates to `FeaturePlacer.place`; the algorithm, including the empty-modifier-list case, is 35-1 section 8, and the depth-first order and the draw order of 11 section 6.4 agree with it). The result is the OR of the results of every `place` call made |
| `overlay` (`OverlayFeature`) | creates one `FeaturePlacer` for all its members (35-1 section 8) and runs each listed placed feature in order from the same `pos` with the same random source and returns the OR of the results; a failing member does not stop the others |
| `sequence` (`SequenceFeature`) | runs each listed placed feature in order; returns `false` at the first one that fails (later ones are not run), `true` if all succeed |
| `simple_random_selector` | `i = nextInt(n)` over the `n` listed placed features; runs entry `i` and returns its result |
| `weighted_random_selector` | `WeightedList.getRandom` over the entries (each entry is an inline placed feature); runs it with `PlacedFeature.place`; returns its result, `false` if the list is empty |
| `no_op` | returns `true` and does nothing (no draw) |
| `simple_block` (`SimpleBlockFeature`) | see §13.1 of this document |
| `random_selector` (`RandomSelectorFeature`), `random_boolean_selector` (`RandomBooleanSelectorFeature`), `weighted_placed_feature` (`WeightedPlacedFeature`, the entry type of the weighted selectors) | registered in `FeatureTypes` beside the rows above; none is used by the data files of this document. Their behaviour is specified in 35-1: `random_selector` section 9.2, `random_boolean_selector` section 9.4, `weighted_placed_feature` section 9.7 |

## 2. Feature types of this document

### 2.1 Class table

`FeatureTypes` registers each feature type under a snake-case id; the ids that belong to this document, their class and their configuration
fields are below. Defaults are the `optionalFieldOf` defaults read from each codec; value ranges are the `Codec.intRange` / `floatRange` limits read from each codec (bounds inclusive), and data outside them is rejected at load. `DimensionType.Y_SIZE` is the build-height span constant of 10.

| Type id | Class | Config fields (default) |
|---|---|---|
| `lake` | `LakeFeature` | `fluid` (state provider), `barrier` (state provider), `can_place_feature`, `can_replace_with_air_or_fluid`, `can_replace_with_barrier` (block predicates) |
| `spring_feature` | `SpringFeature` | `state` (fluid state), `valid_blocks` (block set), `requires_block_below` (true), `rock_count` (4), `hole_count` (1) |
| `disk` | `DiskFeature` | `state_provider`, `target` (block predicate), `radius` (int provider, limited to 0..8), `half_height` (int, 0..4) |
| `block_blob` | `BlockBlobFeature` | `state` (block state), `can_place_on` (block predicate) |
| `netherrack_replace_blobs` | `ReplaceBlobsFeature` | `target` (block state), `state` (block state), `radius` (int provider, limited to 0..12) |
| `freeze_top_layer` | `SnowAndFreezeFeature` | none |
| `iceberg` | `IcebergFeature` | `state` (block state) |
| `blue_ice` | `BlueIceFeature` | none |
| `fill_layer` | `FillLayerFeature` | `height` (int, 0..`DimensionType.Y_SIZE`), `state` (block state) |
| `block_pile` | `BlockPileFeature` | `state_provider` |
| `coral_tree` | `CoralTreeFeature` | `feature` (a placed feature, applied at each coral block) |
| `coral_claw` | `CoralClawFeature` | `feature` (a placed feature) |
| `underwater_magma` | `UnderwaterMagmaFeature` | `floor_search_range` (int, 0..512), `placement_probability_per_valid_position` (float, 0..1), `placement_radius_around_floor` (int, 0..64) |
| `spike` | `SpikeFeature` | `state` (block state), `can_place_on`, `can_replace` (block predicates) |
| `bonus_chest` | `BonusChestFeature` | none |
| `overlay`, `sequence`, `simple_random_selector`, `weighted_random_selector`, `simple_block`, `block_column`, `template`, `no_op` | composition classes, see sections 1.3, 13 and 17 of this document; the three further composition types are listed in §1.3 | as in the data |

### 2.2 Which gameplay names are classes and which are data (resolved from the artifact)

| Gameplay name | Resolution in 26.3 |
|---|---|
| Seagrass | No class. The configured features `seagrass_short`, `seagrass_slightly_less_short`, `seagrass_mid`, `seagrass_tall` are `weighted_random_selector` of two inline placed features: a `simple_block` of `tall_seagrass[half=lower]` guarded by "the block above is water", and a `simple_block` of `seagrass` (no guard). §13.1 |
| Sea pickle | No class. `sea_pickle` is a `simple_block` whose state is a `randomized_int` provider on property `pickles` (uniform 1 to 4) over `sea_pickle[pickles=1, waterlogged=true]`. §13.2 |
| Kelp | No class of its own: `kelp` is a `block_column`. §13.3 |
| Coral tree, coral claw | The classes `CoralTreeFeature` and `CoralClawFeature`; each calls a nested placed feature at every coral block it lays out. §14 |
| Coral mushroom, coral common base | **Not present in this artifact.** The feature type list has no coral-mushroom type and there is no shared coral base class; the coral block and its decoration are data (`coral/<kind>_block`, `coral/block_decoration`, §14.3). |
| Ice spikes | The class `SpikeFeature`, feature type `spike`; the data file `ice_spike` configures it with packed ice. §16 |
| Desert well | No class. `desert_well` is an `overlay` of three `template` features placed with offsets, and `template` is `TemplateFeature`. §17 |
| Forest rock | `BlockBlobFeature` (`block_blob`) with mossy cobblestone. §6 |
| Basalt and blackstone blobs | `ReplaceBlobsFeature` (type id `netherrack_replace_blobs`). §7 |
| Underwater magma | `UnderwaterMagmaFeature`. §15 |
| Block piles (melon, pumpkin, hay, snow, ice) | `BlockPileFeature` (`block_pile`). The five data files exist and no biome lists their placed features: they are referenced only from village template pools (`decor`, 10 files). §12 |
| Fill layer | `FillLayerFeature` (`fill_layer`). No data file of the jar uses it (the string `fill_layer` occurs in no JSON under `data/`, counted over `unzip -p jar 'data/*.json'`). §11 |
| Bonus chest | `BonusChestFeature`. It is in no biome: the server calls it once at world creation. §18 |

## 3. Lake (`LakeFeature`)

A lake carves one lumpy pool into the ground, fills the upper layers with cave air and the lower layers with the fluid, lines the walls with a
barrier block, and for a water lake freezes the surface where the biome is cold.

### 3.1 Configuration in the artifact

| Data file | `fluid` | `barrier` | `can_place_feature` | `can_replace_with_air_or_fluid` | `can_replace_with_barrier` |
|---|---|---|---|---|---|
| `lake_lava` | `lava[level=0]` | `stone` | always true | not in tag `features_cannot_replace` | not in tag `lava_pool_stone_cannot_replace` |
| `sulfur_pool` (a `sequence`, first member) | `water[level=0]` | `sulfur` | not `sulfur_spike` | not in tag `features_cannot_replace` | not in tag `lava_pool_stone_cannot_replace` |

Tags (read): `features_cannot_replace` = bedrock, spawner, chest, end_portal_frame, reinforced_deepslate, trial_spawner, vault.
`lava_pool_stone_cannot_replace` = that tag, plus the tags `leaves` and `logs`. The second member of `sulfur_pool` is a `simple_block`
of `potent_sulfur[potent_sulfur_state=wet]` placed by an `environment_scan` (direction down, at most 4 steps, target: a solid block whose
block above holds water); it belongs to the underground family (35-6) and is not specified here.

### 3.2 Algorithm

Inputs: `pos`. Output: boolean. Let `minY` be the level's minimum build height.

1. If `pos.y <= minY + 4` return false.
2. `origin = pos + (-8, -4, -8)`. Create a mask of 2048 booleans indexed `((x * 16) + z) * 8 + y` for `x, z` in `0..15`, `y` in `0..7`.
3. `blobs = nextInt(4) + 4` (4 to 7). For each blob, draw six doubles in this order and compute
   - `a = nextDouble() * 6 + 3`, `b = nextDouble() * 4 + 2`, `c = nextDouble() * 6 + 3` (the three diameters);
   - `cx = nextDouble() * (16 - a - 2) + 1 + a / 2`, `cy = nextDouble() * (8 - b - 4) + 2 + b / 2`, `cz = nextDouble() * (16 - c - 2) + 1 + c / 2`.
   Then for `x = 1..14`, `z = 1..14`, `y = 1..6` (x outermost, y innermost): `nx = (x - cx) / (a / 2)`, `ny = (y - cy) / (b / 2)`,
   `nz = (z - cz) / (c / 2)`; if `nx*nx + ny*ny + nz*nz < 1` (strictly) set the mask cell. All arithmetic is double. Blobs only add cells.
4. `fluidState = fluid.getState(level, r, origin)` (once; the fluid provider is a plain state in the data, so no draw).
5. **Validity pass.** For `x, z` in `0..15`, `y` in `0..7` (x outermost, z middle, y innermost): a cell is a **border cell** when it is not in the
   mask and at least one of its six neighbours inside `0..15, 0..15, 0..7` is in the mask. For each border cell at `p = origin + (x, y, z)` with block `s`:
   1. if `y >= 4` and `s` is a liquid block (`BlockState.liquid()`, 24 section 5.2), return false;
   2. if `y < 4` and `s` is not solid (`isSolid`, 24 section 5.2) and `s` is not exactly `fluidState` (state equality), return false;
   3. if `can_place_feature.test(level, p)` is false, return false.
   Nothing has been written when this pass returns false.
6. **Fill pass.** For every mask cell (same order): `p = origin + (x, y, z)`; skip it if `can_replace_with_air_or_fluid.test(level, p)` is false;
   write `cave_air` if `y >= 4`, else `fluidState`, with flag 2. The result of the write is discarded. Only for the air layers (`y >= 4`), and whether or not the write was accepted (for example refused outside the 3x3 chunk window), schedule a tick of the `cave_air` block at `p` with delay 0 and call
   `markAboveForPostProcessing(p)`; the fluid layers (`y < 4`) get neither the tick nor the mark (read in `LakeFeature.place`).
7. **Barrier pass.** `barrierState = barrier.getState(level, r, origin)`. If it is not air: for `x`, `z`, `y` as in step 5 (x outermost), for every border cell:
   if `y >= 4` draw `nextInt(2)` and skip the cell when it is 0 (no draw for `y < 4`); then if the block at `p` is solid and `can_replace_with_barrier.test(level, p)`,
   write `barrierState` with flag 2 and call `markAboveForPostProcessing(p)`.
8. **Freeze pass.** If `fluidState`'s fluid is in the fluid tag `water`: for `x = 0..15` (outer), `z = 0..15`: `p = origin + (x, 4, z)`; if
   `biome(p).shouldFreeze(level, p, false)` (section 8 of this document, 33 section 4.4 and 33 section 4.5) and `can_replace_with_air_or_fluid.test(level, p)`, write `ice` with flag 2.
   The biome is `level.getBiome(p)`.
9. Return true.

Notes. The mask layers sit at world heights `pos.y - 4 + y`, so the fluid surface layer is `y = 3` (world `pos.y - 1`) and the first air layer is `y = 4`
(world `pos.y`). The random source is consumed only in steps 3 and 7.

### 3.3 Worked example (computed)

Draws for one blob: six doubles all `0.5`. Then `a = 6`, `b = 4`, `c = 6`, `cx = 0.5 * 8 + 1 + 3 = 8`, `cy = 0.5 * 0 + 2 + 2 = 4`,
`cz = 8`. Cell `(8, 4, 8)`: all three normalised offsets are 0, inside. `(10, 4, 8)`: `nx = 2/3`, sum `0.444`, inside. `(11, 4, 8)`: `nx = 1`, sum 1, **outside**
(strict). `(8, 5, 8)`: `ny = 0.5`, inside; `(8, 6, 8)`: `ny = 1`, outside; `(8, 2, 8)`: `ny = -1`, outside. For `b = 4` the vertical half-diameter is 2, so at `y = 3` and `y = 5` the normalised offset is `+-0.5` and its square is `0.25`. The corner `(10, 5, 10)`: `0.444 + 0.25 + 0.444 = 1.139`, outside (strict). The corner `(10, 4, 10)`: `0.444 + 0 + 0.444 = 0.889`, inside.
So the blob is not the full box: layer `y = 4` has all 25 cells of `x, z` in `6..10`; layers `y = 3` and `y = 5` each lose their four corner cells (21 each, the edge cell `(10, 3, 9)` gives `0.444 + 0.25 + 0.111 = 0.805`, inside). Total 25 + 21 + 21 = 67 cells. With `origin = pos - (8, 4, 8)` the layer `y = 3` is fluid, `y = 4` and `y = 5` are cave air.

## 4. Spring (`SpringFeature`)

A spring replaces one block in a rock wall with a fluid source block that flows out of an opening.

Inputs: `pos`. Let `valid(s)` mean "`s` is in `valid_blocks`".

1. If the block at `pos.above()` is not valid, return false.
2. If `requires_block_below` and the block at `pos.below()` is not valid, return false.
3. If the block at `pos` is neither air nor valid, return false.
4. `rocks` = the number of the five blocks at `pos.west()`, `pos.east()`, `pos.north()`, `pos.south()`, `pos.below()` that are valid; `holes` = the number
   of those same five positions where the level reports an empty block (`isEmptyBlock`, air).
5. If `rocks == rock_count` and `holes == hole_count`: write `state.createLegacyBlock()` at `pos` with flag 2, schedule a fluid tick of the state's fluid at
   `pos` with delay 0, and count one placement. (The configured states are source fluids with `falling=true`; the legacy block of a source is level 0, read in
   `FlowingFluid.getLegacyLevel`: a source gives 0.)
6. Return true only when a block was placed.

There is no random use. The block above is never counted among the five and must be valid (the overhead rock).

| Configured feature | State | `valid_blocks` | Other |
|---|---|---|---|
| `spring_water` | water, falling | stone, granite, diorite, andesite, deepslate, tuff, calcite, dirt, snow_block, powder_snow, packed_ice | defaults (`rock_count` 4, `hole_count` 1, below required) |
| `spring_lava_overworld` | lava, falling | stone, granite, diorite, andesite, deepslate, tuff, calcite, dirt | defaults |
| `spring_lava_frozen` | lava, falling | snow_block, powder_snow, packed_ice | defaults |
| `spring_lava_nether` | lava, falling | netherrack, soul_sand, gravel, magma_block, blackstone | defaults |
| `spring_nether_open` | lava, falling | netherrack | `requires_block_below` false |
| `spring_nether_closed` | lava, falling | netherrack | `requires_block_below` false, `hole_count` 0, `rock_count` 5 |

Worked example (computed): a stone wall with the target stone block at `pos`, stone above and below, stone to the north, south and east, and air to the west:
`valid(above)` yes, `valid(below)` yes, the block at `pos` is valid; `rocks = 4` (E, N, S, below), `holes = 1` (W): placed. If the west block were also stone, `rocks = 5`,
`holes = 0`, and `spring_water` does not place (4 and 1 are required), while `spring_nether_closed` (5 and 0) would.

## 5. Disk (`DiskFeature`)

A disk replaces a flat circular patch of blocks in a short vertical range.

Inputs: `pos`. Let `h = half_height`.

1. `top = pos.y + h`, `bottom = pos.y - h - 1` (exclusive lower bound), `radius = radius.sample(r)` (one draw for `uniform`, 11 section 4).
2. For every `(x, z)` of the square `betweenClosed(pos + (-radius, 0, -radius), pos + (radius, 0, radius))` (order 1.2), with `dx = pos.x - x`, `dz = pos.z - z`:
   skip when `dx*dx + dz*dz > radius*radius` (integer arithmetic; the circle includes its rim). Otherwise run the column below and OR its result.
3. **Column.** `placedBefore = false`. For `y` from `top` down to `bottom + 1` (that is `pos.y + h` down to `pos.y - h`, both inclusive):
   1. `p = (x, y, z)`. If `target.test(level, p)`: `s = state_provider.getOptionalState(level, r, p)`; if `s` is non-null write it with flag 2, call `markAboveForPostProcessing(p)`
      **only if the previous cell of this column did not write** (`placedBefore` false), set the column result true and `placedBefore = true`.
   2. If `target.test` is false, set `placedBefore = false`. (When the provider returns null the flag is left unchanged.)
4. Return true when any column wrote a block.

A `rule_based` state provider (35-2 section 4; read) evaluates its rules in order: the first rule whose predicate holds at `p` **and** whose provider returns a non-null state wins; otherwise
the fallback provider (possibly absent, giving null). The block predicates in a rule use offsets relative to `p`.

| Configured feature | `radius` | `half_height` | `target` | State |
|---|---|---|---|---|
| `disk_clay` | uniform 2 to 3 | 1 | dirt, clay | clay |
| `disk_gravel` | uniform 2 to 5 | 2 | dirt, grass_block | gravel |
| `disk_sand` | uniform 2 to 6 | 2 | dirt, grass_block | rules: if the block below (offset 0,-1,0) is air then sandstone; fallback sand |
| `disk_grass` | uniform 2 to 6 | 2 | dirt, mud | rules: if not (block above solid or water above) then `grass_block[snowy=false]`; fallback dirt |
| `ice_patch` | uniform 2 to 3 | 1 | dirt, grass_block, podzol, coarse_dirt, mycelium, snow_block, ice | packed_ice |

Worked example (computed): `disk_sand` with radius 3 covers `dx*dx + dz*dz <= 9`: row `dz = 0` has `dx` in `-3..3` (7 columns); rows `dz = +-1` have `dx*dx <= 8`, so `-2..2` (5 each);
rows `dz = +-2` have `dx*dx <= 5`, so `-2..2` (5 each); rows `dz = +-3` have `dx = 0` (1 each): `7 + 10 + 10 + 2 = 29` columns (13 for radius 2). With `half_height` 2 each column is
examined over the 5 heights `pos.y + 2` down to `pos.y - 2`.

## 6. Forest rock (`BlockBlobFeature`)

Inputs: `pos`. Output: boolean.

1. While `pos.y > minY + 3`: if `can_place_on.test(level, pos.below())` stop, else `pos = pos.below()`. (The search walks down to the first position whose block below
   satisfies `can_place_on`.)
2. If `pos.y <= minY + 3` return false.
3. Repeat three times: `rx = nextInt(2)`, `ry = nextInt(2)`, `rz = nextInt(2)` (draws in that order); `f = (rx + ry + rz) * 0.333f + 0.5f` (float).
   For every `p` of `betweenClosed(pos - (rx, ry, rz), pos + (rx, ry, rz))` with `distSqr(p, pos) <= (double)(f * f)` (squared Euclidean distance of block coordinates;
   the product `f * f` is a float, then widened), write `state` with `setBlockAndUpdate`. Then move: `pos = pos + (-1 + nextInt(2), -nextInt(2), -1 + nextInt(2))`
   (draws in the order x, y, z).
4. Return true.

Data: `forest_rock` uses `mossy_cobblestone`, `can_place_on` = block tag `forest_rock_can_place_on` (`#substrate_overworld` and `#base_stone_overworld`). Placed `count 2`, `in_square`,
`heightmap MOTION_BLOCKING`, `biome`; listed by two biomes (`old_growth_pine_taiga`, `old_growth_spruce_taiga`) in step 2 (`LOCAL_MODIFICATIONS`).

Worked example (computed): `rx = ry = rz = 1` gives `f = 3 * 0.333 + 0.5 = 1.499` (float), `f*f = 2.247`: of the `3 x 3 x 3` box the cells with squared distance
at most 2.247 stay: the centre (0), six face neighbours (1), twelve edge neighbours (2), not the eight corners (3): 19 cells. `rx = ry = rz = 0` gives `f = 0.5`,
`f*f = 0.25`: one cell.

## 7. Replace blobs (`ReplaceBlobsFeature`, type `netherrack_replace_blobs`)

Inputs: `pos`. `targetBlock` is the block of the `target` state (property values are ignored: the test is `state.is(block)`).

1. `c = pos` with its y clamped into `[minY + 1, maxY]` (`MutableBlockPos.clamp(Y, minY + 1, maxY)`).
2. **Find the target:** while `c.y > minY + 1`: if the block at `c` is `targetBlock` stop with `c`; else `c = c.below()`. If the loop ends without a hit return false.
   (The cell at `y = minY + 1` itself is never tested.)
3. `rx = radius.sample(r)`, `ry = radius.sample(r)`, `rz = radius.sample(r)` (three draws in this order), `m = max(rx, ry, rz)`.
4. For every `p` of `withinBoxByManhattanDistance(c, rx, ry, rz)` in its non-decreasing order, stopping at the first `p` with `distManhattan(p, c) > m`: if the block at `p` is `targetBlock`,
   write `state` there with `setBlockAndUpdate` and note success. Return whether any block was written. (So the shape is the box clipped to a Manhattan ball of radius `m`.)

Data: `basalt_blobs` (target `netherrack`, state `basalt`) and `blackstone_blobs` (state `blackstone`), both `radius` uniform 3 to 7. Placed: `count 75` (basalt) and `count 25` (blackstone),
`in_square`, `height_range uniform` over the whole build height (`above_bottom 0` to `below_top 0`), `biome`; only the biome `basalt_deltas` lists them, in step 7 (`UNDERGROUND_DECORATION`).

Worked example (computed): `rx = 3, ry = 7, rz = 3` gives `m = 7`; the box is `7 x 15 x 7` but only the cells with `|dx| + |dy| + |dz| <= 7` are examined: the corners of the box are cut away and the
blob is a tall, diamond-like volume.

## 8. Snow and ice top layer (`SnowAndFreezeFeature`, `freeze_top_layer`)

Inputs: `pos`, which for this placed feature (modifier `biome` only) is the decoration origin `(16 cx, -64, 16 cz)` (11 section 6.1); only its x and z are used. No random use.

For `dx = 0..15` (outer), `dz = 0..15`:

1. `x = pos.x + dx`, `z = pos.z + dz`; `y = level.getHeight(MOTION_BLOCKING, x, z)` (the first free block above the highest motion-blocking block, 06 heightmap table);
   `top = (x, y, z)`, `below = (x, y - 1, z)`; `biome = level.getBiome(top)`.
2. If `biome.shouldFreeze(level, below, false)`: write `ice` at `below` with flag 2.
3. If `biome.shouldSnow(level, top)`: write `snow` (the default state, one layer) at `top` with flag 2; then read the block at `below`: if it has the property `snowy`, write it
   back with `snowy = true` (flag 2).
4. Return true.

`shouldFreeze(level, p, mustBeAtEdge)` (read in `Biome`): false when the biome is warm enough for rain at `p` (33 section 4.5; the float constant 0.15 is read in `Biome.warmEnoughToRain` and the int constant 17 in `Biome.getHeightAdjustedTemperature`; how 17 combines with the sea level is taken from 33 section 4.5, Open question 2); else true when `p` is inside the build
height, the block light at `p` is below 10, the fluid at `p` is source water **and** the block there is a `LiquidBlock`, and (only when `mustBeAtEdge` is true) not all four horizontal
neighbours are water. The worldgen call passes `mustBeAtEdge = false`, so a lone water source qualifies; the running-game call of 33 section 4.4 passes true. `shouldSnow(level, p)` requires the precipitation at `p` to be SNOW (33 section 4.5),
`p` inside the build height, block light at `p` below 10, the block at `p` air or snow, and the default snow state able to survive at `p`.
The block-light limit 10 is read as the int constant in both `shouldFreeze` and `shouldSnow`. Whether block light exists while features run (the lighting stage is later) is Open question 1; with no light data the value is 0 and the light tests pass (inferred).

The placed feature is listed by 56 of the 67 biomes in the jar in step 10 (`TOP_LAYER_MODIFICATION`), the last step, so it sees the final surface.

Worked example (computed): a column whose motion-blocking top is a grass block at `y = 80` in a biome whose temperature at `y = 81` is below 0.15: `top.y = 81`, `below.y = 80`; no ice (the
block at `below` is not water); `shouldSnow` holds if `(x, 81, z)` is air and snow can survive on grass (its top face is a full collision face): one `snow` layer is written at `y = 81` and the grass becomes `snowy=true`.
A pond column whose top is a water source at `y = 62` with air above: `top.y = 63`, `below.y = 62`; if cold, `ice` replaces the source at `y = 62`, and no snow layer is added at `y = 63`: `shouldSnow` fails its survival test because `SnowLayerBlock.canSurvive` returns false when the block below is in the block tag `cannot_support_snow_layer` (read: `ice`, `packed_ice`, `barrier`). The same holds for `packed_ice` laid by `ice_patch`. Survival rule (read): false if the block below is in `cannot_support_snow_layer`; true if it is in `support_override_snow_layer` (read: `honey_block`, `soul_sand`, `mud`), whatever its shape; otherwise true when the collision shape of the block below has a full UP face, or the block below is a snow layer with 8 layers.

## 9. Iceberg (`IcebergFeature`)

The iceberg is a stack of shaped layers around the sea level: an above-water body (round or elliptical), a below-water taper, a smoothing pass that removes
overhangs, and optionally a cut-out channel. `state` is `packed_ice` (`iceberg_packed`) or `blue_ice` (`iceberg_blue`). The radius helpers are float arithmetic, the
distances are double.

### 9.1 Parameter draws

Let `S = ChunkGenerator.getSeaLevel()` (63 for the overworld noise settings, 10 section 5). Inputs: `pos`; `origin = (pos.x, S, pos.z)` (the y of `pos` is discarded).

| # | Name | Draw and formula | Range |
|---|---|---|---|
| 1 | `snowOnTop` | `nextDouble() > 0.7` | boolean |
| 2 | `angle` | `nextDouble() * 2.0 * PI` (double: the product with 2.0 first, then PI) | `[0, 2 PI)` |
| 3 | `A` | `11 - nextInt(5)` | 7 to 11 |
| 4 | `B` | `3 + nextInt(3)` | 3 to 5 |
| 5 | `ell` | `nextDouble() > 0.7` (the iceberg is elliptical) | boolean |
| 6 | `H` (height above sea level) | if `ell`: `nextInt(6) + 6`; else `nextInt(15) + 3` and then, only when not `ell`, `nextDouble() > 0.9` and, if true, `H = H + nextInt(19) + 7` (the `nextInt(19)` only in that case) | ell: 6 to 11; round: 3 to 17, or 10 to 42 (the rare branch adds 7 to 25) |
| 7 | `D` (depth below sea level) | `min(H + nextInt(11), 18)` | up to 18 |
| 8 | `E` (base radius parameter) | `min(H + nextInt(7) - nextInt(5), 11)` (draw order: the 7, then the 5) | up to 11 |
| 9 | `W` (half width of the layer loops) | `ell ? A : 11` | 7 to 11, or 11 |

(`IcebergFeature.place` also stores the constant 11 in an unused local; it has no effect.)

### 9.2 Phases

1. **Above water.** For `x = -W..W-1` (outer), `z = -W..W-1` (middle), `y = 0..H-1` (inner): `R = ell ? ellRadius(y, H, E) : roundRadius(r, y, H, E)` (the round version draws random numbers on every call, so
   the iteration order is part of the result). If `ell` or `x < R`, call `placeBlock(height = H, x, y, z, radius = R, width = W)` (9.4).
2. **Smooth.** `smooth(origin, E, H, ell, A)` (9.5).
3. **Below water.** For `x = -W..W-1` (outer), `z = -W..W-1` (middle), `y = -1` down to `-(D - 1)` (loop while `y > -D`; inner): `Wy = ell ? ceil(W * (1.0f - (float)(y*y) / ((float) D * 8.0f))) : W` (float; `y*y` is
   computed with `Math.pow(y, 2)` in double and narrowed to float), `Rs = steepRadius(r, -y, D, E)`. If `x < Rs` (no `ell` exemption here), call `placeBlock(height = D, x, y, z, radius = Rs, width = Wy)`.
4. **Cut-out.** `cut = ell ? nextDouble() > 0.1 : nextDouble() > 0.7`. If `cut`, `cutOut(E, H, origin, ell, A, angle, B)` (9.6). Return true.

### 9.3 Radius helpers (read)

All of these return `ceil(f / 2)` (float `f`, `Mth.ceil`).

| Helper | Draws | Formula |
|---|---|---|
| `ellRadius(y, H, E)` | none | `f = (1.0f - (float)(y*y) / ((float)H * 1.0f)) * (float) E` |
| `roundRadius(r, y, H, E)` | 1 `nextFloat`, then `nextInt(5)`, then (only when the test below holds) `nextInt(6)` | `u = 3.5f - nextFloat()`; `f = (1.0f - (float)(y*y) / ((float)H * u)) * (float) E`. Then `if H > 15 + nextInt(5)`: `y2 = (y < 3 + nextInt(6)) ? y / 2 : y` (integer division) and `f = (1.0f - (float) y2 / ((float)H * u * 0.4f)) * (float) E`. The `nextInt(5)` is drawn on every call; the `nextInt(6)` only when `H > 15 + draw` |
| `steepRadius(r, y, D, E)` | 1 `nextFloat` | `u = 1.0f + nextFloat() / 2.0f`; `f = (1.0f - (float) y / ((float) D * u)) * (float) E` |
| `ellipseC(y, H, B)` | none | `c = B`; if `y > 0` and `H - y <= 3` then `c = B - (4 - (H - y))`; return `c` (an integer) |

### 9.4 `placeBlock` and `setIcebergBlock`

`placeBlock(height, x, y, z, radius, width)`:

1. `dist = ell ? ellipseDist(x, z, (0,0), width, ellipseC(y, height, B), angle) : circleDist(x, z, (0,0), radius, r)` (9.4.1; the circle version draws one `nextFloat`).
2. If `dist < 0`: `p = origin + (x, y, z)`; `limit = ell ? -0.5 : (-6 - nextInt(3))` (the `nextInt(3)` is drawn when not `ell`, whenever `dist < 0`); if `dist > limit` and `nextDouble() > 0.9`
   stop (the `nextDouble` is drawn only when `dist > limit`); otherwise `setIcebergBlock(p, height - y, height)`.

`setIcebergBlock(p, remaining, height)` (`s` is the block now at `p`):

1. Do nothing unless `s` is air, `snow_block`, `ice` or `water`.
2. `ok = !ell || nextDouble() > 0.05` (the draw only when `ell`). `div = ell ? 3 : 2`.
3. If `snowOnTop` and `s` is not water, draw `t = nextInt(max(1, height / div))`; and if `(double) remaining <= t + height * 0.6` and `ok`, write `snow_block` (`setBlockAndUpdate`) at `p` and finish.
   (The `nextInt` is drawn whenever `snowOnTop` holds and `s` is not water, even if `ok` is false.)
4. Otherwise write the iceberg `state` at `p`.

#### 9.4.1 Signed distances

| Function | Draws | Formula |
|---|---|---|
| `circleDist(x, z, c, radius, r)` | one `nextFloat` | `k = 10.0f * clamp(nextFloat(), 0.2f, 0.8f) / (float) radius` (float); result `(double) k + (x - c.x)^2 + (z - c.z)^2 - radius^2` (double) |
| `ellipseDist(x, z, c, a, b, angle)` | none | `((dx cos(angle) - dz sin(angle)) / a)^2 + ((dx sin(angle) + dz cos(angle)) / b)^2 - 1`, with `dx = x - c.x`, `dz = z - c.z`, `Math.cos` / `Math.sin` in double |

In `placeBlock` the centre is `(0, 0)` (the origin offset is applied only when writing). A negative distance is inside.

### 9.5 `smooth(origin, E, H, ell, A)`

`rad = ell ? A : E / 2` (integer division). For `x = -rad..rad` (outer), `z = -rad..rad`, `y = 0..H` (inclusive, inner), `p = origin + (x, y, z)`, `s` the block at `p`:
if `s` is `packed_ice`, `snow_block` or `blue_ice` (the three "iceberg" blocks) **or** `snow` (the layer), then:
- if the block below `p` is air: write air at `p` and at `p.above()` (both `setBlockAndUpdate`);
- else if `s` is an iceberg block: count how many of the west, east, north, south neighbours are **not** iceberg blocks; if the count is at least 3, write air at `p`.
Writes are visible to later cells of the same pass. No random use.

### 9.6 Cut-out

`cutOut(E, H, origin, ell, A, angle, B)` carves a channel through the berg:

1. `sx = nextBoolean() ? -1 : 1`; `sz = nextBoolean() ? -1 : 1` (two draws, x then z).
2. `ox = nextInt(max(E / 2 - 2, 1))`; then `nextBoolean()`, and when true `ox = E / 2 + 1 - nextInt(max(E - E / 2 - 1, 1))`. Then `oz` the same way (a fresh `nextInt(max(E/2 - 2, 1))`, a `nextBoolean`, and when true
   the second form). Draw order: `ox` first draw, boolean, optional second draw; then `oz` first draw, boolean, optional second draw.
3. If `ell`: `ox = oz = nextInt(max(A - 5, 1))` (one draw, replacing both).
4. `cutPos = (sx * ox, 0, sz * oz)`.
5. `angle2 = ell ? angle + PI/2 : nextDouble() * 2.0 * PI`.
6. For `y = 0 .. H - 4` (that is `y < H - 3`): `R = roundRadius(r, y, H, E)`; `carve(R, y, toWater = false)`.
7. For `y = -1` downward while `y > -H + nextInt(5)` (the `nextInt(5)` is drawn at every loop test): `R = steepRadius(r, -y, H, E)`; `carve(R, y, toWater = true)`.

`carve(radius, yOff, toWater)`: `w = radius + 1 + A / 3`, `c = min(radius - 3, 3) + B / 2 - 1`. For `x = -w..w-1` (outer), `z = -w..w-1`: `d = ellipseDist(x, z, cutPos, w, c, angle2)`; if `d < 0`, `p = origin + (x, yOff, z)`; if the
block at `p` is an iceberg block or `snow_block`: if `toWater` write `water` at `p`, else write air at `p` and then, if the block at `p.above()` is a `snow` layer, replace it by air. All writes are
`setBlockAndUpdate`.

### 9.7 Data and placement

`iceberg_packed`: `rarity_filter 16`, `in_square`, `biome`; `iceberg_blue`: `rarity_filter 200`, `in_square`, `biome`; both in step 2 and listed by `frozen_ocean` and `deep_frozen_ocean` only. There is no height modifier:
the feature's own `origin.y` is the sea level.

### 9.8 Worked examples (computed)

Radius helpers: `ellRadius(0, 8, 6)` = `ceil((1 - 0) * 6 / 2)` = 3; `ellRadius(2, 8, 6)` = `ceil((1 - 4/8) * 6 / 2)` = `ceil(1.5)` = 2; `ellRadius(4, 8, 6)` = `ceil((1 - 16/8) * 6 / 2)` = `ceil(-3)` = -3 (negative: no block).
`steepRadius` with `nextFloat() = 0.5` (`u = 1.25`), `y = 1`, `D = 10`, `E = 8`: `f = (1 - 1/12.5) * 8 = 7.36`, `ceil(3.68)` = 4. `ellipseC(y = 6, H = 8, B = 4)`: `H - y = 2 <= 3`, so `c = 4 - (4 - 2) = 2`; `ellipseC(0, 8, 4)` = 4.
Ellipse distance with `angle = 0`, `a = 9`, `b = 4`: `(x/9)^2 + (z/4)^2 - 1`; `(9, 0)` gives 0 (not inside), `(8, 0)` gives `-0.21` (inside), `(0, 4)` gives 0, `(0, 3)` gives `-0.44`.
Snow cap: a round berg with `snowOnTop`, `H = 10`: `div = 2`, `height / div = 5`, `t` in `0..4`, the test is `remaining <= t + 6.0`. At `y = 9` (`remaining = 1`) it always holds; at `y = 3` (`remaining = 7`) it holds when `t >= 1`, probability 4/5; at `y = 0` (`remaining = 10`) it needs `t >= 4`, probability 1/5.

## 10. Blue ice (`BlueIceFeature`)

Inputs: `pos`.

1. If `pos.y > seaLevel - 1` return false (`WorldGenLevel.getSeaLevel`).
2. If the block at `pos` is not `water` **and** the block below is not `water`, return false.
3. Look at the neighbours of `pos` in the five directions of `Direction.values()` other than DOWN (UP, NORTH, SOUTH, WEST, EAST): if any is `packed_ice` continue; if none, return false.
4. Write `blue_ice` at `pos` (flag 2).
5. Repeat 200 times: `dy = nextInt(5) - nextInt(6)` (the 5 first, then the 6); `spread = 3`; if `dy < 2` then `spread = spread + dy / 2` (integer division truncating toward zero); if `spread < 1` go to the next repetition.
   `q = pos + (nextInt(spread) - nextInt(spread), dy, nextInt(spread) - nextInt(spread))` (four draws: the x pair, then the z pair). If the block at `q` is air, water, `packed_ice` or `ice`: for each of the six directions of `Direction.values()`
   (DOWN, UP, NORTH, SOUTH, WEST, EAST): if the neighbour of `q` is `blue_ice`, write `blue_ice` at `q` (flag 2) and stop checking directions.
6. Return true.

Data: `blue_ice` placed `count uniform 0..19`, `in_square`, `height_range uniform` absolute 30 to 61, `biome`; step 4 (`SURFACE_STRUCTURES`); biomes `frozen_ocean`, `deep_frozen_ocean`.

Worked example (computed): `dy` ranges over `-5..4`. The spread by `dy`: `-5` and `-4` give `3 + (-2) = 1`; `-3` and `-2` give `3 + (-1) = 2`; `-1`, `0` and `1` give `3 + 0 = 3`; `2` to `4` skip the adjustment and give 3.
With `spread = 1` the offsets are two `nextInt(1)` pairs (always 0): the candidate is directly below or above `pos` by `dy`.

## 11. Fill layer (`FillLayerFeature`)

Inputs: `pos` (a chunk corner). For `dx = 0..15` (outer), `dz = 0..15`: `p = (pos.x + dx, minY + height, pos.z + dz)`; if the block at `p` is air, write `state` there with flag 2. Return true. There is no random use, and no data file of the
jar uses the type (§2.2). The layer is at `minY + height`, an absolute offset from the world bottom, not from `pos.y`.

## 12. Block pile (`BlockPileFeature`)

Inputs: `pos`.

1. If `pos.y < minY + 5` return false.
2. `a = 2 + nextInt(2)`, `b = 2 + nextInt(2)` (x extent, then z extent; 2 to 3 each).
3. For every `p` of `betweenClosed(pos + (-a, 0, -b), pos + (a, 1, b))` (order 1.2; two layers `y` and `y + 1`): `d = (pos.x - p.x)^2 + (pos.z - p.z)^2` (integer); `t = nextFloat() * 10.0f - nextFloat() * 6.0f`
   (two draws, the 10 factor first); if `(float) d <= t`, call `tryPlace(p)`; otherwise draw `nextFloat()` and if it is `< 0.031` (double compare) call `tryPlace(p)`. (The third draw is made only when the first test fails.)
4. Return true.

`tryPlace(p)`: if the block at `p` is air and `mayPlaceOn(p)`, write `state_provider.getState(level, r, p)` at `p` with flag 260 (no update). `mayPlaceOn`: let `b` be the block at `p.below()`; if `b` is `dirt_path`, the result is `nextBoolean()`;
otherwise it is `b.isFaceSturdy(level, below, UP)` (24 section 5.2). The provider is called with the random source.

| Configured feature | Provider |
|---|---|
| `pile_melon` | `melon` |
| `pile_pumpkin` | weighted: `pumpkin` 19, `jack_o_lantern` 1 (`WeightedList.getRandom`, 1.2) |
| `pile_hay` | `rotated` over `hay_block[axis=y]` with no fixed direction: a random direction (`Direction.getRandom`, `nextInt(6)`) is drawn per call; `axis` is set to the direction's axis, `facing` is set if the block has it, `horizontal_facing` is set when the direction is horizontal (`trySetValue`: properties the block lacks are left alone) |
| `pile_snow` | `snow[layers=1]` |
| `pile_ice` | weighted: `blue_ice` 1, `packed_ice` 5 |

Worked example (computed): the centre cell `d = 0` is placed when `10u - 6v >= 0` for uniform `u, v`: `P = integral over v in [0,1] of (1 - 0.6 v) = 0.7`. A cell with `d = 4` needs `10u - 6v >= 4`:
`P = integral over v in [0,1] of (0.6 - 0.6 v) = 0.3`, plus the fallback `0.7 * 0.031 = 0.022` on the rest: about 0.322 (floats aside).

## 13. Ocean vegetation

### 13.1 Seagrass (data over `weighted_random_selector` and `simple_block`)

| Feature | Weight of the tall entry | Weight of the single entry | Used by (placed feature, `count`) |
|---|---|---|---|
| `seagrass_short` | 30 | 70 | `seagrass_cold` (32), `seagrass_normal` (48), `seagrass_warm` (80) |
| `seagrass_slightly_less_short` | 40 | 60 | `seagrass_river` (48) |
| `seagrass_mid` | 60 | 40 | `seagrass_swamp` (64) |
| `seagrass_tall` | 80 | 20 | `seagrass_deep` (48), `seagrass_deep_cold` (40), `seagrass_deep_warm` (80) |

The tall entry is `simple_block(tall_seagrass[half=lower])` with the placement `[block_predicate_filter: water at offset (0, 1, 0)]`; the single entry is `simple_block(seagrass)` with no placement. The seagrass placed features all have the modifiers
`in_square`, `count N`, `offset (trapezoid -7..7, trapezoid 0..0, trapezoid -7..7)`, `heightmap OCEAN_FLOOR`, `block_predicate_filter (block at pos is water)`, `biome`, in that order. Per placed feature the draws are: `nextInt(16)` x and z (`in_square`, once), then for each of the `N` repeats the offset draws
(`nextInt(8) - nextInt(8)` for x, two `nextInt(1)` for y, `nextInt(8) - nextInt(8)` for z; 1.2), then the heightmap lookup (the OCEAN_FLOOR position is the first position above the highest block that blocks motion, ignoring fluids, so for a flooded floor it is the lowest water block directly above the solid floor. Read in `Heightmap$Types`: `OCEAN_FLOOR` (usage LIVE_WORLD) and `OCEAN_FLOOR_WG` (usage WORLDGEN) both use the predicate `MATERIAL_MOTION_BLOCKING`, which is membership in the block tag `blocks_motion_in_heightmap`, whose value is the tag `#blocks_motion`; fluids are not counted. `MOTION_BLOCKING` and `MOTION_BLOCKING_NO_LEAVES` use their own tags (`blocks_motion_in_heightmap`, `blocks_motion_in_heightmap_no_leaves` = `#blocks_motion_no_leaves`) or a non-empty fluid state), the water filter, the biome filter, and
then the feature: one `nextInt(total weight)`, and for the tall entry its water-above filter (no draw) and the block placement.

`simple_block` (`SimpleBlockFeature`, config `to_place` provider, `schedule_tick` default false):

1. `s = to_place.getOptionalState(level, r, pos)`; null returns false.
2. If `s.canSurvive(level, pos)` is false return false.
3. If the block of `s` is a double plant (`DoublePlantBlock`; `tall_seagrass` is one): let `u` be the block at `pos.above()`; it must be air, or have the same fluid state as `s` **and** be replaceable (`canBeReplaced`); otherwise return false. Then `DoublePlantBlock.placeAt(level, s, pos, 2)`: write the lower half at `pos`
   and the upper half at `pos.above()` (`half` set to LOWER and UPPER; `waterlogged` set from "is there water at that position" when the block has that property), flag 2 each.
4. Else if the block is a mossy carpet, `MossyCarpetBlock.placeAt(level, pos, level.random, 2)` (outside this document); else `setBlock(pos, s, 2)`.
5. If `schedule_tick`, schedule a block tick at `pos` with delay 1. Return true.

Survival rules read for these blocks: `seagrass` (a vegetation block) survives when the block below `mayPlaceOn`: its **top face is sturdy and it is not in tag `cannot_support_seagrass`** (the tag holds `magma_block`). `tall_seagrass`: the lower half also needs that of the block below,
**and** the fluid at `pos` must be water and a full fluid block (`isFull`); the upper half survives when the block below is a `tall_seagrass` lower half.

Worked example (computed): `seagrass_short` at a water position over sand, water above: one `nextInt(100)`; a value `0..29` chooses the tall entry (30), `30..99` the single seagrass (70). Tall: the filter (water above) passes, `canSurvive` needs a full water block at `pos` (yes) and a sturdy top face of sand (yes): the two halves are written. A value `>= 30` writes `seagrass` at `pos` (replacing the water block).

### 13.2 Sea pickle (data over `simple_block` and `randomized_int`)

`sea_pickle` (configured) is a `simple_block` whose provider is `randomized_int(property pickles, values uniform 1..4)` over `sea_pickle[pickles=1, waterlogged=true]`: the provider draws `nextInt(4) + 1` and sets the property when the state has it (the property object is found by name on first use).
Survival: the sea pickle block survives when the block below satisfies `mayPlaceOn`: its collision shape's UP face is non-empty **or** its UP face is sturdy (read: `!getFaceShape(UP).isEmpty() || isFaceSturdy(UP)`).
Placed `sea_pickle` (listed by `warm_ocean`, step 9): `rarity_filter 16`, `in_square`, `count 20`, `offset (trapezoid -7..7, trapezoid 0..0, trapezoid -7..7)`, `heightmap OCEAN_FLOOR`, `block_predicate_filter (water at pos)`, `biome`. The coral decoration (14.3) places pickles through the same configured feature.

### 13.3 Kelp (`block_column`)

`block_column` (`BlockColumnFeature`; fields `layers` (a list of `{height int provider, provider}`), `direction`, `allowed_placement` (block predicate), `prioritize_tip`):

1. Sample each layer's height in layer order (one draw per `uniform` layer); `total` = their sum; if 0 return false.
2. Starting at `pos + direction`, test `allowed_placement` at consecutive positions along `direction`, up to `total` times; at the first failure at index `i`, call `truncate(heights, total, i, prioritize_tip)` and stop testing.
   `truncate` removes `total - i` blocks from the layers: with `prioritize_tip` it walks the layers from index 0 upward, subtracting `min(layerHeight, remaining)` from each (so the tip layer, listed last, is kept); without it, from the last layer backward.
3. Place layer by layer starting at `pos` itself (not `pos + direction`) along `direction`: for each remaining block of the layer write `provider.getState(level, r, cursor)` with flag 2, then step.
4. Return true.

`kelp` data: `direction up`, `allowed_placement` = water at the tested position and water above it, `prioritize_tip` true, layers: `kelp_plant` with height uniform 0 to 9, then one `kelp[age = uniform 20..23]` (a `randomized_int` provider on `age`, source `kelp[age=0]`). Total height 1 to 10 (the tested positions begin one above `pos`, so
a column needs water at `pos + 1` and the position above the tip).
Placed: `kelp_cold` (`noise_based_count`: `noise_factor 80.0`, `noise_to_count_ratio 120`; biomes `cold_ocean`, `deep_cold_ocean`, `ocean`, `deep_ocean`), `kelp_warm` (ratio 80; `lukewarm_ocean`, `deep_lukewarm_ocean`); then `in_square`, `heightmap OCEAN_FLOOR`, a filter (water at `pos`, water above, the block below has a sturdy UP face and is not in tag `cannot_support_kelp` = `magma_block`), `biome`.
`noise_based_count` computes `ceil((BIOME_INFO_NOISE(x / factor, z / factor) + noise_offset) * ratio)` with `noise_offset` default 0 (read) and `BIOME_INFO_NOISE` the fixed-seed simplex noise of 10 section 15 item 8; it draws no random number.

## 14. Corals

The coral features of 26.3 are driven by data: a coral kind is a placed feature (the "coral block") that the tree and claw classes call at each block of their layout.

### 14.1 `CoralTreeFeature` (`coral_tree`)

Config: `feature` (placed feature `F`). Inputs: `pos`. Let `place(c)` mean `F.place(level, generator, r, c)`.

1. `cursor = pos`. `stem = nextInt(3) + 1` (1 to 3).
2. For `i = 0 .. stem - 1`: if `place(cursor)` is false, **return true** (read: the method returns true here, so an early stop is reported as success); else move `cursor` up one.
3. `top = cursor` (the position above the last stem block). `branches = nextInt(3) + 2` (2 to 4). `dirs = shuffledCopy(HORIZONTAL, r)` (N, E, S, W shuffled with `Util.shuffle`, 1.2: 3 draws); take the first `branches` entries.
4. For each direction `d` in that order: `cursor = top` then one step in `d`; `len = nextInt(5) + 2` (2 to 6); `placed = 0`. For `j = 0 .. len - 1`: if `place(cursor)` is false, stop this branch; else `placed = placed + 1`, move up one, and then if `j == 0` or (`placed >= 2` and `nextFloat() < 0.25f`) move one step in `d` and set `placed = 0`.
   (The `nextFloat` is drawn only when `j != 0` and `placed >= 2`.)
5. Return true.

### 14.2 `CoralClawFeature` (`coral_claw`)

Config: `feature` (placed feature `F`). Inputs: `pos`.

1. If `place(pos)` is false return false.
2. `d0 = HORIZONTAL[nextInt(4)]`. `claws = nextInt(2) + 2` (2 or 3). `dirs = toShuffledList([d0, d0.clockwise, d0.counterClockwise])` (`Util.shuffle`, 1.2: 2 draws); take the first `claws`.
3. For each `d` in that order: `cursor = pos`; `len1 = nextInt(2) + 1` (1 or 2); one step in `d`;
   - if `d == d0`: `dir2 = d0`, `len2 = nextInt(3) + 2` (2 to 4);
   - else: one step up, `dir2 = [d, UP][nextInt(2)]` (`Util.getRandom` over the two-element array), `len2 = nextInt(3) + 3` (3 to 5).
   Then: for `i = 0 .. len1 - 1`: if `place(cursor)` is false stop; else one step in `dir2`. Then one step in `dir2.opposite` and one step up. Then for `i = 0 .. len2 - 1`: one step in `d0`; if `place(cursor)` is false stop; else if `nextFloat() < 0.25f` one step up.
4. Return true.

(Draw order within a claw: `len1`, then for a non-`d0` claw the `dir2` choice, then `len2`.)

### 14.3 The coral block and its decoration (data)

`warm_ocean_vegetation` is a `simple_random_selector` of 15 placed features (one `nextInt(15)` draw): for each coral kind in the order tube, brain, bubble, fire, horn, three entries in this order: a `coral_tree`, a `coral_claw`, and a bare coral-block placement.

- **Coral tree and claw entries** use `feature = coral/<kind>_block` with the placement `[block_predicate_filter: (water **or** a block in tag corals) at pos, and water at pos + (0,1,0)]`.
- **The bare entry** is `coral/<kind>_block` with the placement `[offset (0, uniform -3..-1, 0), cuboid, random_chance 0.9, block_predicate_filter (same predicate)]`.
- **`coral/<kind>_block`** is an `overlay` of two members: a `simple_block` of `<kind>_coral_block`, then `coral/block_decoration` (no placement).
- **`coral/block_decoration`** is an `overlay` of five members, in this order:
  1. a `weighted_random_selector` placed at `pos + (0, 1, 0)`: weight 20 a `simple_block` of a random block from tag `corals`; weight 3 the `sea_pickle` feature (13.2); weight 57 `no_op` (total 80, one `nextInt(80)` draw);
  2. to 5. four wall-fan members in the order north, east, south, west: each is `[random_chance 0.2, offset to the neighbour (north (0,0,-1), east (+1,0,0), south (0,0,+1), west (-1,0,0)), block_predicate_filter (water at pos)]` and a `simple_block` whose provider is a `rotated` provider with the direction set to that member's direction over a `random_block` of tag `wall_corals`
     (a fixed direction draws nothing; the provider sets `facing` and `horizontal_facing` of the chosen wall fan to that direction).
  Each member runs from the same `pos` (the coral block position), so a wall fan on the neighbour cell faces away from the coral block. The `random_chance` is drawn first (`nextFloat() < 0.2f`).
- Tags (read): `corals` = the tag `coral_plants` followed by `tube_coral_fan`, `brain_coral_fan`, `bubble_coral_fan`, `fire_coral_fan`, `horn_coral_fan`; `coral_plants` = `tube_coral`, `brain_coral`, `bubble_coral`, `fire_coral`, `horn_coral`; `wall_corals` = the five wall fans in the order tube, brain, bubble, fire, horn. A `random_block` over a tag picks `contents[nextInt(size)]` and uses the block's default state; with the nested tag expanded in place, `corals` has exactly these 10 entries in this order (duplicates would be dropped; the order is the tag file's value order, because `TagLoader.tryBuildTag` collects entries into an insertion-ordered `LinkedHashSet` and `TagEntry.build` expands a nested `#tag` entry in place; the same holds for every block set used by `matching_blocks`, 35-2).
- **Survival** (read): a coral plant or fan survives when the block below has a sturdy UP face; a wall fan survives when the block behind it (opposite its facing) has a sturdy face towards the facing direction; coral blocks have no survival rule. The default state of plants, fans and wall fans is `waterlogged = true`, so the placed blocks hold water (the feature does not change `waterlogged`).
- **Cuboid placement modifier** (`net.minecraft.world.level.levelgen.feature.CuboidPlacement`, registered id `cuboid`; it is in the feature package, not in `levelgen.placement` with the other modifiers; fields `xz_size`, `y_size` int providers, `include_edges`, `include_interior`): for each input position `P`, draw `sy = y_size.sample`, then `sx = xz_size.sample`, then `sz = xz_size.sample` (in that order); for `x = 0..sx`, `y = 0..sy`, `z = 0..sz` (x outermost, z innermost), the output position is `P + (x, y, z)`
  (the box extends from `P` in the positive directions). With `include_edges` false, positions with at least two of the three coordinates at an extreme (0 or the size on that axis) are dropped; with `include_interior` false, positions with none of the three at an extreme are dropped. The coral data uses both false (sizes `xz_size` uniform 3..5, `y_size` uniform 3..5), leaving the face cells with exactly one extreme coordinate.
  The number of face cells for sizes `(sx, sy, sz)` is `2 * ((sx-1)(sy-1) + (sx-1)(sz-1) + (sy-1)(sz-1))`.

### 14.4 Worked examples (computed)

Cuboid shell: `sx = sy = sz = 3` gives `4 x 4 x 4 = 64` positions: 8 interior (`1..2` on each axis), 32 with two or more extreme coordinates (8 corners plus 12 edges of 2 inner cells), and 24 face cells; the shell emits 24 positions (`2 * (2*2 + 2*2 + 2*2) = 24`). For `sx = 5, sy = 3, sz = 4`: `2 * (4*2 + 4*3 + 2*3) = 52`.
Each emitted position then passes `random_chance 0.9` (one `nextFloat` each, in emission order) and the water filter before the coral block and its decoration are placed.
Coral tree with draws `stem = 2`, `branches = 3` and a first branch `d = EAST`, `len = 4`: the stem occupies `pos` and `pos + (0,1,0)`; `top = pos + (0,2,0)`; the branch starts at `top + EAST`; after its first block (`j = 0`) it moves one east and resets `placed`, and afterwards it rises and steps east each time the count reaches 2 and `nextFloat() < 0.25f`.

## 15. Underwater magma (`UnderwaterMagmaFeature`)

Config: `floor_search_range` (5 in the data), `placement_probability_per_valid_position` (0.5), `placement_radius_around_floor` (1).

1. **Floor.** `Column.scan(level, pos, floor_search_range, allowed = block is water, target = block is not water)`: if the block at `pos` is not water return false. Scan **down**: the cursor starts at `pos.y`, `i = 1`; while `i < range` and the block at the cursor is water,
   move the cursor down one and `i = i + 1`; then if the block at the cursor is not water the floor is the cursor's y, else there is no floor (return false). With `range = 5` the floor is between 1 and 4 blocks below `pos` (the starting block is water, so `pos.y` itself is never the floor). (The upward scan of `Column.scan` does not affect the floor: `getFloor` is empty only when the downward scan fails.)
2. `centre = pos with y = floor`; the box is `centre +- placement_radius_around_floor` on each axis (27 cells for radius 1).
3. Walk the box with `betweenClosedStream` (order 1.2, lazy): for each position `p` draw `nextFloat()` and keep `p` if it is `< placement_probability_per_valid_position`; then keep it if `isValidPlacement(p)`; then write `magma_block` (flag 2) and count it. Because the stream is lazy, a written magma block
   is visible to the checks of the following positions.
4. Return true when at least one block was placed.

`isValidPlacement(p)`: false if the block at `p` is water or air; false if the block **below** `p` presents a visible UP face (`isVisibleFromOutside(p.below(), UP)`); false if, for any horizontal direction `d` (N, E, S, W), the block at `p + d` presents a visible face towards `-d` (`isVisibleFromOutside(p.relative(d), d.opposite)`); otherwise true.
`isVisibleFromOutside(q, dir)`: let `shape` be the block's face occlusion shape for `dir` (24 section 5.2); visible when `shape` is the empty shape **or** is not a full block face. So magma only replaces blocks whose lower and four side neighbours present full opaque faces towards it; the block above is not examined.

Placed: `count uniform 44..52`, `in_square`, `height_range uniform` from `above_bottom 0` to absolute 256, `surface_relative_threshold_filter(OCEAN_FLOOR_WG, max_inclusive -2)` (pass when the position's y is at most the OCEAN_FLOOR_WG height minus 2 or more below it: read as `heightmap + min <= y <= heightmap + max`; the minimum is unbounded in the data; 35-1 section 7.7), `biome`. Listed by 56 biomes in step 6 (`UNDERGROUND_ORES`; 11 section 6.2 puts `underwater_magma` before `disk_sand`).

Worked example (computed): `pos` is water with water below and a stone block two below: the cursor starts at `pos.y` (water, `i = 1`), moves to `pos.y - 1` (water, `i = 2`), moves to `pos.y - 2` (stone) and the loop ends because the block is not water: floor = `pos.y - 2`; the 27-cell box is centred on that stone block.
If the first non-water block were 5 below, the loop stops at `i = 5` with the cursor 4 below on a water block, so there is no floor and the feature returns false.

## 16. Ice spike (`SpikeFeature`, type `spike`)

Config: `state` (`packed_ice`), `can_place_on` (block is `snow_block`), `can_replace` (block in tag `ice_spike_replaceable` = tag `substrate_overworld`, `snow_block`, `ice`). Inputs: `pos`.

1. **Find the ground.** While the block at `pos` is air (`isEmptyBlock`) and `pos.y > minY + 2`, `pos = pos.below()`.
2. If `can_place_on.test(level, pos)` is false return false.
3. `pos = pos.above(nextInt(4))` (0 to 3 blocks above the ground block).
4. `H = nextInt(4) + 7` (7 to 10). `Wd = H / 4 + nextInt(2)` (integer division, then add 0 or 1; 1 to 3).
5. If `Wd > 1` and `nextInt(60) == 0` (the `nextInt(60)` only when `Wd > 1`): `pos = pos.above(10 + nextInt(30))` (the second draw only on that branch: a rare tall spike).
6. **The spike body.** For `y = 0 .. H - 1`: `f = (1.0f - (float) y / (float) H) * (float) Wd` (float), `rad = ceil(f)`. For `x = -rad..rad` (outer), `z = -rad..rad`: let `fx = (float)|x| - 0.25f`, `fz = (float)|z| - 0.25f`. Skip the cell unless it is the axis cell `(0, 0)` or `fx*fx + fz*fz <= f*f`. If the cell is on the square's
   rim (`x` or `z` equal to `-rad` or `+rad`) and `nextFloat() > 0.75f`, skip it (the draw only for rim cells that passed the distance test). Otherwise `p = pos + (x, y, z)`: if the block at `p` is air or satisfies `can_replace`, write `state` (`setBlockAndUpdate`).
   Then, if `y != 0` and `rad > 1`, the mirrored cell `pos + (x, -y, z)` (downward) gets the same air-or-replace test and write (no further draw).
7. **The pillar base.** `t = Wd - 1`, clamped to `0..1`. For `x = -t..t` (outer), `z = -t..t`: `q = pos + (x, -1, z)`; `n = 50`; if `|x| == 1` and `|z| == 1`, `n = nextInt(5)`. While `q.y > 50` (a fixed absolute y): let `s` be the block at `q`; if `s` is air, or `can_replace.test(q)`, or `s` equals `state` exactly: write `state` at `q`, `q = q.below()`, `n = n - 1`, and if `n <= 0`: `q = q.below(nextInt(5) + 1)`
   and `n = nextInt(5)` (two draws, in that order); otherwise stop this column.
8. Return true.

Data: placed `ice_spike`: `count 3`, `in_square`, `heightmap MOTION_BLOCKING`, `biome`; only the `ice_spikes` biome lists it, step 4. `ice_patch` (a disk, §5) is listed by the same biome in the same step.

Worked example (computed): `H = 8`: `H / 4 = 2`, `Wd` is 2 or 3. For `Wd = 2`: layer `y = 0` has `f = 2.0`, `rad = 2`, a 5 x 5 square clipped by `fx*fx + fz*fz <= 4` (cell `(2, 2)`: `1.75^2 + 1.75^2 = 6.125 > 4`, dropped; `(2, 0)`: `3.0625 + 0.0625 = 3.125 <= 4`, kept); layer `y = 4` has `f = 1.0`, `rad = 1`: a 3 x 3 square (`(1, 1)`: `0.5625 + 0.5625 = 1.125 > 1`, dropped; the cross kept); layer `y = 7` has `f = 0.25`, `rad = 1`:
only the axis cell survives (`(1, 0)`: `0.5625 + 0.0625 = 0.625 > 0.0625`). The pillar: `t = 1`, so a 3 x 3 pillar of columns going down from `pos - 1`; the four corner columns use a random countdown `nextInt(5)` before skipping down 1 to 5 blocks.

## 17. Desert well (`overlay` of `template` features)

There is no desert-well class. `desert_well` (configured) is an `overlay` of three placed `template` features, run from the same `pos` in this order:

| # | Template | Placement | Processor |
|---|---|---|---|
| 1 | `desert_well/well` (weight 1) | `offset (0, -2, 0)` | none |
| 2 | `desert_well/suspicious_sand` (weight 1) | `randomly_selected` over the five offsets `(0,-1,0)`, `(-1,-1,0)`, `(0,-1,+1)`, `(+1,-1,0)`, `(0,-1,-1)` (one `Util.getRandom`, `nextInt(5)`) | a `rule` processor: a block matching `suspicious_sand` becomes `suspicious_sand` with the block-entity modifier `append_loot` of the loot table `archaeology/desert_well` |
| 3 | `desert_well/suspicious_sand` | `randomly_selected` over the same five offsets with `y = -2` | the same processor |

`TemplateFeature` (`templates` weighted list of `{id, rotations}` with `rotations` defaulting to the four rotations NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90 in that order; optional `processors` list):

1. `entry = templates.getRandomOrThrow(r)` (one `nextInt(totalWeight)` draw); `rotation = rotations[nextInt(size)]`.
2. `template = StructureTemplateManager.getOrCreate(entry.id)`; let `size` be its size (x, y, z).
3. `offX = unit(rotate(WEST, rotation)) * (size.x / 2)` and `offZ = unit(rotate(NORTH, rotation)) * (size.z / 2)` (integer division; the negative direction of axis X is WEST and of axis Z is NORTH). `origin = pos + offX + offZ`.
4. Placement settings: the rotation, the random source, and the processors of the list in order. Call `placeInWorld(level, origin, origin, settings, r, 3)` and return its result. The template placement engine, processor rules and block-entity modifiers belong to the structure documents (structure documents); the NBT files are data and are not tabulated here.

Template sizes (read from the first bytes of the NBT, the `size` list): `desert_well/well` `(5, 7, 5)`, `desert_well/suspicious_sand` `(1, 1, 1)`. For rotation NONE: `offX = (-1, 0, 0) * 2` and `offZ = (0, 0, -1) * 2`, so the well's corner is `pos + (-2, 0, -2)` before the placed feature's y offset; the 1 x 1 x 1 templates have offsets of 0 (`1 / 2 = 0`).

Placed `desert_well`: `rarity_filter 1000`, `in_square`, `heightmap MOTION_BLOCKING`, `offset (0, -1, 0)`, a filter requiring the block at `pos` to be `sand` **and** `volume_match` (every cell of the box `pos + (-2, -2, -2)` to `pos + (2, -1, 2)` satisfies "not in the tag `air`", read in `VolumeMatchPredicate`: x outermost, then z, then y, stopping at the first failure; the box covers y `-2..-1` relative to `pos`, a 5 x 5 pad two blocks deep directly below it), `biome`. Listed by the `desert` biome only, step 4.

Worked example (computed): sand surface at `y = 70` (the topmost sand block): `MOTION_BLOCKING` gives 71, the offset gives 70; the filter checks that block and the 5 x 5 x 2 volume at `y = 68..69`; the well template (height 7) is placed with its origin at `y = 68` (`70 - 2`), so its bottom two layers are buried.

## 18. Bonus chest (`BonusChestFeature`)

Inputs: `pos`. The feature is in no biome. The server calls it once when a new world is initialised with the world option "bonus chest" (`WorldOptions.generateBonusChest`) and the spawn has been chosen normally (not in the two debug cases of `MinecraftServer.setInitialSpawn`); the call is `Feature.place(level, generator, level.getRandom(), respawnData.pos())`, made after the world spawn is set
(spawn finding itself is not specified here).

1. `chunk = ChunkPos.containing(pos)`. `xs = shuffle([minBlockX .. maxBlockX])` (16 values, `Util.shuffle` over ints, 15 draws), then `zs = shuffle([minBlockZ .. maxBlockZ])` (15 more draws).
2. For `x` in `xs` (outer), for `z` in `zs` (inner): `h = level.getHeightmapPos(MOTION_BLOCKING_NO_LEAVES, (x, 0, z))`. If the block at `h` is air or its collision shape is empty:
   1. write a `chest` (default state) at `h` with flag 2;
   2. `RandomizableContainer.setBlockEntityLootTable(level, r, h, SPAWN_BONUS_CHEST)`: when the block entity at `h` is a randomizable container, set its loot table to `chests/spawn_bonus_chest` with the seed `r.nextLong()` (one draw);
   3. for each `d` in HORIZONTAL (N, E, S, W): `t = h + d`; if the default `torch` state `canSurvive` at `t`, write it with flag 2;
   4. return true.
3. If no position qualified return false.

Data: the loot table `chests/spawn_bonus_chest` (extracted as data).

Worked example (computed): chunk `(0, 0)`: `xs` is a permutation of `0..15` (15 draws), `zs` another (15 draws); the first `(x, z)` in permutation order whose heightmap cell is free receives the chest, and torches go on those of its four horizontal neighbours where a torch can survive (a sturdy block below, 29).

## 19. Where these features run (decoration steps, from the biome data)

Counted from the 67 biome JSON files (`features` is an array of 11 lists, steps 0 to 10, 11 section 6.2); "biomes" counts biomes that list the placed feature in that step. Placed-feature modifier lists are data and are not repeated beyond sections 3 to 18.

| Placed feature | Step (name) | Biomes |
|---|---|---|
| `lake_lava_underground`, `lake_lava_surface` | 1 (LAKES) | 55 (overworld-style) |
| `sulfur_pool` | 1 | `sulfur_caves` |
| `forest_rock` | 2 (LOCAL_MODIFICATIONS) | `old_growth_pine_taiga`, `old_growth_spruce_taiga` |
| `iceberg_packed`, `iceberg_blue` | 2 | `frozen_ocean`, `deep_frozen_ocean` |
| `blue_ice` | 4 (SURFACE_STRUCTURES) | `frozen_ocean`, `deep_frozen_ocean` |
| `ice_spike`, `ice_patch` | 4 | `ice_spikes` |
| `desert_well` | 4 | `desert` |
| `disk_clay`, `disk_sand`, `disk_gravel`, `underwater_magma` | 6 (UNDERGROUND_ORES) | 54 to 56 each |
| `disk_grass` | 6 | `mangrove_swamp` |
| `spring_open`, `spring_closed` (springs with `spring_nether_open` / `spring_nether_closed`) | 7 (UNDERGROUND_DECORATION) | `crimson_forest`, `nether_wastes`, `soul_sand_valley`, `warped_forest` |
| `spring_delta` (`spring_lava_nether`), `basalt_blobs`, `blackstone_blobs` | 7 | `basalt_deltas` |
| `spring_water`, `spring_lava` | 8 (FLUID_SPRINGS) | 55 |
| `spring_lava_frozen` | 8 | `frozen_peaks`, `grove`, `jagged_peaks`, `snowy_slopes` |
| `spring_lava` (again) | 9 (VEGETAL_DECORATION) | `crimson_forest`, `nether_wastes`, `soul_sand_valley`, `warped_forest` (read: `spring_lava_overworld` lists valid blocks stone, granite, diorite, andesite, deepslate, tuff, calcite and dirt, no netherrack, so step 1 of §4 fails inside netherrack; stone-type blocks in those biomes' terrain could still host a spring) |
| `warm_ocean_vegetation`, `sea_pickle` | 9 | `warm_ocean` |
| `seagrass_*` | 9 | `cold_ocean`, `ocean`, `deep_ocean`, `deep_cold_ocean`, `deep_lukewarm_ocean`, `lukewarm_ocean`, `warm_ocean`, `river`, `swamp`, `mangrove_swamp` |
| `kelp_cold`, `kelp_warm` | 9 | see §13.3 of this document |
| `freeze_top_layer` | 10 (TOP_LAYER_MODIFICATION) | 56 |
| `pile_*`, `bonus_chest`, `fill_layer` | none | in no biome (2.2) |

## 20. Validation: checkable facts

1. The jar's `data/minecraft/worldgen/feature/` holds 240 files and `placed_feature/` 273 (counted with `unzip -Z1 | grep -v '/$'`); six of the 240 are under `coral/` (`block_decoration` and five `*_block`).
2. Feature types used by data files: counted as top-level files of `data/minecraft/worldgen/feature/` by `type`: `lake` 1 (`lake_lava`; a second `lake` occurs once nested inside the `sulfur_pool` sequence, so 2 occurrences in all), `spring_feature` 6, `disk` 5, `block_blob` 1, `netherrack_replace_blobs` 2, `freeze_top_layer` 1, `iceberg` 2, `blue_ice` 1, `block_pile` 5, `underwater_magma` 1, `spike` 1, `bonus_chest` 1, `fill_layer` 0. Occurrence counts, not files: `coral_tree` and `coral_claw` 5 uses each, nested inside `warm_ocean_vegetation`.
3. `warm_ocean_vegetation` has 15 entries: 5 `coral_tree`, 5 `coral_claw`, 5 plain coral-block references.
4. `coral/block_decoration` weights 20, 3, 57 (total 80); the four wall-fan members use `random_chance 0.2`.
5. Lake blob example (3.3): layer `y = 4` 25 cells, layers `y = 3` and `y = 5` 21 cells each (corners excluded), 67 cells in all.
6. Disk radius 3 has 29 columns and radius 2 has 13 (§5).
7. `FlowingFluid.getLegacyLevel` of a source is 0; the springs therefore write level-0 source blocks.
8. `Direction` enum order DOWN, UP, NORTH, SOUTH, WEST, EAST; `Plane.HORIZONTAL` array NORTH, EAST, SOUTH, WEST.
9. Block-flag constants: `UPDATE_CLIENTS = 2`, `UPDATE_ALL = 3`, `UPDATE_NONE = 260`.
10. Iceberg helper values of §9.8: `ellRadius(0, 8, 6) = 3`, `ellRadius(2, 8, 6) = 2`, `ellRadius(4, 8, 6) = -3`, `ellipseC(6, 8, 4) = 2`, `steepRadius` example 4.
11. Cuboid example: sizes `(3, 3, 3)` emit 24 positions; `(5, 3, 4)` emit 52.
12. `desert_well/well` template size `(5, 7, 5)`, `suspicious_sand` `(1, 1, 1)` (the `size` list at the start of each NBT).
13. The ice-spike pillar threshold `y > 50` and the block-pile minimum `pos.y >= minY + 5` are absolute constants of the code.
14. `shuffle` consumes `size - 1` draws: 15 for the 16 ints of the bonus chest, 3 for the four horizontal directions of the coral tree, 2 for the three directions of the claw.
15. Placement counts: `seagrass_warm` 80, `seagrass_deep_warm` 80, `sea_pickle` 20 after `rarity_filter 16`; `underwater_magma` count uniform 44 to 52.

## Open questions

1. **Block light at feature time.** `shouldFreeze` and `shouldSnow` read the block-light level (below 10 required, `getBrightness(BLOCK, pos) < 10`; read). `WorldGenRegion.getLightEngine()` returns the `ServerLevel` light engine (read), so the test reads the live level's light storage, not a region-local copy. Whether a chunk that has not been lit yet reports 0 was not traced; this document assumes 0 (inferred), so the light test passes. 33 section 4.4 describes the same predicates for the running game.
2. **Height adjustment of the freeze test.** The constants 0.15f (`warmEnoughToRain`) and 17 (`getHeightAdjustedTemperature`) are read, but the full formula of the height-adjusted temperature (the sea-level base, the noise terms with 8.0f, 0.05f and 40.0f) was not re-read in this document; it is taken from 33 section 4.5.
3. **Template placement.** `StructureTemplate.placeInWorld` (flags 3), the `rule` processor and the `append_loot` block-entity modifier used by the desert well are only named here; they belong to the structure documents.
4. **`MossyCarpetBlock.placeAt`** (a `simple_block` branch for mossy carpets) was not read; it is to be confirmed in 35-4 (searched: this document's classes only).
5. **Spawn wiring of the bonus chest.** Only the feature is specified; which worlds enable it (`WorldOptions.generateBonusChest`) and how the spawn position is found come from server-side world creation (not in scope).
6. **Fill layer usage.** No data file of the jar uses `fill_layer`; flat-world generation of the artifact (`flat_level_generator_preset`, 9 files) was not traced to the code that fills layers, so whether flat worlds use this feature or a separate path is unknown.
7. **`isSolid` "otherwise" row.** The lake validity test relies on `BlockState.isSolid`; 24 section 5.2 records one row of its derivation as inferred (24 Open questions, item 16).
8. **Float versus double.** The iceberg radius helpers and the block-pile test are float arithmetic with `Math.pow` narrowed from double; the rounding of intermediate products was reproduced from the operand types in the bytecode but not verified by running, so a bit-exact port should be compared against a vanilla iceberg.
9. **`spring_lava` in the nether biomes.** Four nether biomes list the overworld `spring_lava` in step 9; it places nothing in netherrack (read: the valid-block list of `spring_lava_overworld` has no netherrack, so section 4 step 1 fails); only stone-type blocks in those biomes' terrain could host one (not traced).
10. **Position passed to `freeze_top_layer`.** The decoration origin `(16 cx, -64, 16 cz)` of 11 section 6.1 is assumed to be what reaches `SnowAndFreezeFeature` (only x and z matter); the call site in `ChunkGenerator` was not re-read.
