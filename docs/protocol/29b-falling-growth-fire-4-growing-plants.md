# 29b. Falling blocks, growth, fire and similar block behaviours, part 4: growing plants (plant columns, hanging and aquatic plants, small plants)

| | |
|---|---|
| Covers | The `GrowingPlantBlock` family (`GrowingPlantHeadBlock` and `GrowingPlantBodyBlock`: kelp, weeping vines, twisting vines, cave vines and glow berries, `NetherVines`); `SugarCaneBlock`; `CactusBlock` and `CactusFlowerBlock`; `BambooStalkBlock`, `BambooSaplingBlock` and the `leaves` enum; `VineBlock` (re-verified, the full text is 24 part 4 section 6.7); `ChorusPlantBlock` and `ChorusFlowerBlock`; `SeagrassBlock`, `TallSeagrassBlock` and the `DoublePlantBlock` base; `TallGrassBlock`, `TallFlowerBlock`; `FlowerBlock`, `WitherRoseBlock`, `EyeblossomBlock`, `FlowerBedBlock`; `BushBlock` and `VegetationBlock` (the survival base); `DryVegetationBlock`, `ShortDryGrassBlock`, `TallDryGrassBlock`; `FireflyBushBlock`; `SeaPickleBlock`; `LilyPadBlock`; `BigDripleafBlock`, `BigDripleafStemBlock`, `SmallDripleafBlock`; `HangingRootsBlock`; `SporeBlossomBlock`; `HangingMossBlock` (pale hanging moss); `MangroveRootsBlock`. Per block: survival (`canSurvive`), shape updates, scheduled and random ticks, bone meal, placement rules that change state, and the server-visible state changes of use and entity contact. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the tag and timeline JSON files named below, with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS11 (GAP-10b of `../design/README.md` Part 5), part 4 |
| Data versus code | Tags (`supports_vegetation`, `supports_sugar_cane`, `supports_sugar_cane_adjacently` (block and fluid), `supports_cactus`, `support_override_cactus_flower`, `supports_bamboo`, `cannot_support_kelp`, `cannot_support_seagrass`, `supports_chorus_plant`, `supports_chorus_flower`, `supports_dry_vegetation`, `supports_wither_rose`, `supports_lily_pad` (block and fluid), `supports_small_dripleaf`, `supports_big_dripleaf`, `coral_blocks`, `pale_oak_logs`), the environment timeline tracks (`eyeblossom_open`, `firefly_bush_sounds`) and the loot tables (glow berry harvest, plant drops, shears and silk touch rules) are DATA (22, 23, 26, 33). Their members are listed once in 2.4 so that the examples can be followed; the engines read the tags, they do not hard-code the members. Everything else here (ages, probabilities, offsets, orderings, counts, random draws, state conversions) is code and is specified completely. |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions. Block names are registry names (24 parts 1 to 8). The behaviour record, trigger kinds (RT, ST, PL, NU, SU, EV), flag vocabulary, probability notation (`1/N`, `P(p)`, `U(a,b)`) and predicate vocabulary are those of `29b-falling-growth-fire-1-model-gravity-bonemeal.md` section 2 ("29b-1" below); the bone meal item flow and the `BonemealableBlock` contract are 29b-1 section 5; the sibling parts are cited as 29b-2 (crops, stems, propagule, azalea), 29b-3 (spread, leaves, snow, ice) and 29b-5 (fungi, moss, copper). Registry rows (ids, states, hardness, sounds, map colours, outline shapes) are 24 and are not repeated except where a value is needed to follow a rule.

## 0. Reader's map

| Question | Section |
|---|---|
| What this document owns, what other documents own, which block uses which class | 1 |
| The `VegetationBlock` and `BushBlock` base, water helpers, tags, flags, random helpers | 2 |
| Kelp, weeping vines, twisting vines, cave vines, glow berries (the head and body engine) | 3 |
| Sugar cane | 4 |
| Cactus and cactus flower | 5 |
| Bamboo stalk, bamboo sapling | 6 |
| Vines | 7 |
| Chorus plant and chorus flower | 8 |
| Seagrass, tall seagrass, double plants, short grass and ferns, tall flowers | 9 |
| Flowers, wither rose, eyeblossom, flower beds, bush, dry vegetation, firefly bush | 10 |
| Sea pickle and lily pad | 11 |
| Big dripleaf, its stem, small dripleaf | 12 |
| Hanging roots, spore blossom, pale hanging moss, mangrove roots | 13 |
| Can-survive, random tick and bone meal rules in one table each | 14 |
| Client-side behaviour that does not change state | 15 |
| Worked examples | 16 |
| Validation | 17 |
| Open questions | 18 |

## 1. Scope, ownership and class table

### 1.1 What is owned elsewhere

| Topic | Owner |
|---|---|
| Vine placement, support, random tick spread, rotate and mirror (complete text) | 24 part 4 section 6.7. Section 7 below restates the numbers that were re-read in this round and records agreement |
| `mangrove_propagule` (hanging growth and survival), `azalea` and `flowering_azalea` bone meal, sweet berry bush, torchflower crop, pitcher crop (a `DoublePlantBlock` subclass; this part owns the base class rules of 9.1) | 29b-2 sections 4, 8 and 11 |
| Saplings, `TreeGrower` | 29b-1 section 7 |
| Grass block, leaves, leaf litter, snow, ice | 29b-3 |
| Mushrooms, nether fungi, moss block, moss carpet, copper | 29b-5 |
| `glow_lichen` and `resin_clump` (`MultifaceBlock`), the shared `canAttachTo` | 24 part 4 section 6.8; 35 part 4 section 8.1 |
| `ChorusFlowerBlock.generatePlant` and `growTreeRecursive` (world generation of chorus trees) | 35 part 7 section 9 (the rules read here were not duplicated) |
| Seagrass spread by bone meal in water (`BoneMealItem.growWaterPlant`) | 17 section 3.4 |
| Water fluid ticks, waterlogging, `scheduleTick` for fluids | 29a (water tick delay 5, the value read there) |
| Shapes with offsets (`offsetType`), `Block.column`, support shapes (`isFaceSturdy`, `canSupportCenter`) | 24 part 1 sections 4.4, 5 and 6.5 |
| Bee behaviour (`BonemealSource.MOB`; `Bee.attractsBees` is read in 10.3 step 5) | 19 and 44 (`MOB` not read here, Open question 1) |
| Particle shapes and block ambient sounds | 42 part 6 |

### 1.2 Registry names and classes (read from the lambdas of `Blocks`)

Spot-checked in this round by resolving the registration lambdas: `golden_dandelion` is a `FlowerBlock` (constructed with the saturation effect and the float 0.35, as for 10.1), `pitcher_plant` is a `DoublePlantBlock` (offset type XZ), `firefly_bush` is a `FireflyBushBlock` with a constant light level of 2. The other rows, the 14-flower list, the `bush` / `red_shrub` height 13 and the `pink_petals` / `wildflowers` height 3 were read earlier and not re-resolved in this round (marked, not re-read).

"RT" is the registry random-tick flag (`randomTicks()`); a head or flower may switch it off per state (stated in the section). Light values and sounds are 24.

| Registry name | Class | RT flag | Section |
|---|---|---|---|
| `kelp` (head), `kelp_plant` (body) | `KelpBlock`, `KelpPlantBlock` | head yes, body no | 3.3 |
| `weeping_vines`, `weeping_vines_plant` | `WeepingVinesBlock`, `WeepingVinesPlantBlock` | head yes, body no | 3.4 |
| `twisting_vines`, `twisting_vines_plant` | `TwistingVinesBlock`, `TwistingVinesPlantBlock` | head yes, body no | 3.4 |
| `cave_vines` (item `glow_berries`), `cave_vines_plant` | `CaveVinesBlock`, `CaveVinesPlantBlock` | head yes, body no | 3.5 |
| `sugar_cane` | `SugarCaneBlock` | yes | 4 |
| `cactus` | `CactusBlock` | yes | 5.1 |
| `cactus_flower` | `CactusFlowerBlock` (a `VegetationBlock`) | no | 5.2 |
| `bamboo`, `bamboo_sapling` | `BambooStalkBlock`, `BambooSaplingBlock` | yes (stalk: only while `stage == 0`), yes | 6 |
| `vine` | `VineBlock` | yes | 7 |
| `chorus_plant`, `chorus_flower` | `ChorusPlantBlock` (a `PipeBlock`), `ChorusFlowerBlock` | plant no, flower yes (only while `age < 5`) | 8 |
| `seagrass` | `SeagrassBlock` | no | 9.2 |
| `tall_seagrass` | `TallSeagrassBlock` (a `DoublePlantBlock`) | no | 9.3 |
| `short_grass`, `fern` | `TallGrassBlock` | no | 9.5 |
| `tall_grass`, `large_fern`, `pitcher_plant` | `DoublePlantBlock` itself (plain; `pitcher_plant` is not the crop) | no | 9.1 |
| `sunflower`, `lilac`, `rose_bush`, `peony` | `TallFlowerBlock` | no | 9.6 |
| 14 small flowers (`dandelion`, `golden_dandelion`, `torchflower`, `poppy`, `blue_orchid`, `allium`, `azure_bluet`, `red_tulip`, `orange_tulip`, `white_tulip`, `pink_tulip`, `oxeye_daisy`, `cornflower`, `lily_of_the_valley`) | `FlowerBlock` | no | 10.1 |
| `wither_rose` | `WitherRoseBlock` | no | 10.2 |
| `open_eyeblossom`, `closed_eyeblossom` | `EyeblossomBlock` | yes (both) | 10.3 |
| `pink_petals`, `wildflowers` | `FlowerBedBlock` (shape height 3 for both) | no | 10.4 |
| `bush`, `red_shrub` | `BushBlock` (shape height 13) | no | 10.5 |
| `dead_bush` | `DryVegetationBlock` | no | 10.6 |
| `short_dry_grass`, `tall_dry_grass` | `ShortDryGrassBlock`, `TallDryGrassBlock` | no | 10.6 |
| `firefly_bush` | `FireflyBushBlock` | no | 10.7 |
| `sea_pickle` | `SeaPickleBlock` | no | 11.1 |
| `lily_pad` | `LilyPadBlock` | no | 11.2 |
| `big_dripleaf`, `big_dripleaf_stem`, `small_dripleaf` | `BigDripleafBlock`, `BigDripleafStemBlock`, `SmallDripleafBlock` | no | 12 |
| `hanging_roots` | `HangingRootsBlock` | no | 13.1 |
| `spore_blossom` | `SporeBlossomBlock` | no | 13.2 |
| `pale_hanging_moss` | `HangingMossBlock` | no | 13.3 |
| `mangrove_roots`, `muddy_mangrove_roots` | `MangroveRootsBlock` (the muddy variant is a plain block) | no | 13.4 |

Blocks of 24 that were re-read here and agree with that document: kelp, nether vines (24 part 6 and part 7), bamboo and chorus flower (24 part 6), cactus and sugar cane (24 part 3 sections 7.10.1 and 7.10.2), vine (24 part 4 section 6.7). Where this text restates them it is to make the part self-contained.

## 2. Shared base, helpers and vocabulary

### 2.1 `VegetationBlock` (base of most small plants)

Read in `VegetationBlock`:

| Method | Rule |
|---|---|
| `mayPlaceOn(state, level, pos)` | the state is in tag `supports_vegetation`. Subclasses override it (the table of 14.1 lists every override) |
| `canSurvive(state, level, pos)` | `mayPlaceOn(state at pos.below(), level, pos.below())` |
| `updateShape(...)` (SU) | when `canSurvive` is false the result is air; otherwise the default shape update (the state unchanged). There is no scheduled tick: the second ground check is the neighbour update itself, for every changed direction |
| `propagatesSkylightDown` | the state's fluid state is empty |
| `isPathfindable` | for path type AIR and no collision: true; otherwise the default |

A block that returns air from `updateShape` is removed by the shape-update machinery with drops (29 section 3.2: `Block.updateOrDestroy` calls `destroyBlock` with drops unless flag 32).

### 2.2 `BushBlock`

`BushBlock extends VegetationBlock implements BonemealableBlock`. The shape is `Block.column(16, 0, h)` with `h` = 13 unless the constructor passes another height (`bush` and `red_shrub` use 13). Bone meal is the neighbour-spreader helper of 29b-1 section 5.4 with the block's own default state: `isValidBonemealTarget` = `hasSpreadableNeighbourPos(level, pos, state)`, success always, `performBonemeal` = `findSpreadableNeighbourPos` then `setBlockAndUpdate(thatPos, defaultBlockState())` (flags 3). `getType` is not overridden, so the type is `GROWER` and the particle position is `pos` (read: none of the classes of this part overrides `getType`).

Correction to 29b-1 section 5.4, whose title says "flowers, bushes": `FlowerBlock` extends `VegetationBlock` directly in this version, not `BushBlock` (read in the class header), so the 14 flowers, `wither_rose` and the eyeblossoms are **not** `BonemealableBlock`s. Only `bush` and `red_shrub` use the generic spreader in 2.2 (`TallGrassBlock`, `FireflyBushBlock` and the dry grasses declare the interface on their own). See Open question 3.

### 2.3 Helpers and facts used by several sections

| Item | Definition (read) |
|---|---|
| water tick | `ScheduledTickAccess.scheduleTick(pos, Fluids.WATER, Fluids.WATER.getTickDelay(level))` (a fluid tick; delay 5 as read in 29a). Waterlogged and always-water blocks issue it from `updateShape` |
| `isWaterAt(pos)` | the fluid state at `pos` is in fluid tag `water` (`LevelReader.isWaterAt`; the tag contains `water` and `flowing_water`) |
| `FluidState.is(Fluids.WATER)` | the fluid **type object** equals `Fluids.WATER`. `Fluids` has separate `WATER` (still) and `FLOWING_WATER` objects, so this test is true only for water **source** states; it is what the placement rules of sea pickle, hanging roots, mangrove roots and seagrass-like blocks call "water" |
| `FluidState.is(FluidTags.WATER)` | tag test, true for source and flowing water |
| `FluidState.isSourceOfType(f)` | type is `f` and the state is a source |
| `FluidState.isFull()` | `getAmount() == 8` |
| `LiquidBlockContainer` (kelp, kelp plant, seagrass, tall seagrass) | `canPlaceLiquid` and `placeLiquid` both return false: other fluids cannot flow into the block. The block reports `Fluids.WATER.getSource(false)` as its fluid state, always |
| `copyWaterloggedFrom(level, pos, state)` (`DoublePlantBlock`) | when the state has the property `waterlogged`: set it to `isWaterAt(pos)`; otherwise unchanged |
| horizontal order | `Direction.Plane.HORIZONTAL` = NORTH, EAST, SOUTH, WEST; `Plane.getRandomDirection(random)` = `HORIZONTAL[random.nextInt(4)]` (one draw) |
| vertical order | `Plane.VERTICAL` = UP, DOWN |
| `Direction.getRandom(random)` | one `nextInt(6)` over `values()` in the order DOWN, UP, NORTH, SOUTH, WEST, EAST |
| clockwise (horizontal) | `getClockWise`: NORTH to EAST, EAST to SOUTH, SOUTH to WEST, WEST to NORTH; `getCounterClockWise` is the inverse (read in the two lookup tables) |
| `Mth.nextInt(r, a, b)` | `a` when `a >= b`, else `r.nextInt(b - a + 1) + a` |
| `Mth.randomBetween(r, a, b)` | `r.nextFloat() * (b - a) + a` (one draw) |
| `RandomSource.nextDouble() < p` and `nextFloat() < p` | one draw each; where the code converts a float to double before comparing (vine 0.05) this is noted |

### 2.4 Tags as shipped (DATA, illustration only)

| Tag | Members in the jar |
|---|---|
| block `supports_vegetation` | `#substrate_overworld`, `farmland` |
| block `substrate_overworld` | `#dirt`, `#mud`, `#moss_blocks`, `#grass_blocks` |
| block `dirt` | `dirt`, `coarse_dirt`, `rooted_dirt` |
| block `sand` (file read) | `sand`, `red_sand`, `suspicious_sand` |
| block `supports_sugar_cane` | `#substrate_overworld`, `#sand` |
| block `supports_sugar_cane_adjacently` | `frosted_ice` |
| fluid `supports_sugar_cane_adjacently` | `#water` (fluid tag `water`: `water`, `flowing_water`) |
| block `supports_cactus` | `#sand` |
| block `support_override_cactus_flower` | `cactus`, `farmland` |
| block `supports_bamboo` | `#sand`, `#substrate_overworld`, `bamboo`, `bamboo_sapling`, `gravel`, `suspicious_gravel` |
| block `cannot_support_kelp`, `cannot_support_seagrass` | `magma_block` |
| block `supports_chorus_plant`, `supports_chorus_flower` (files read) | `end_stone` |
| block `supports_dry_vegetation` | `#sand`, `#terracotta`, `#supports_vegetation` |
| block `terracotta` (file read) | the 17 plain and dyed terracotta blocks (`terracotta` and the 16 colours, not glazed terracotta) |
| block `supports_wither_rose` | `#supports_vegetation`, `netherrack`, `soul_sand`, `soul_soil` |
| block `supports_lily_pad` | `ice`, `frosted_ice` |
| fluid `supports_lily_pad` | `water` (the still fluid only) |
| block `supports_small_dripleaf` | `clay`, `moss_block` |
| block `supports_big_dripleaf` | `#supports_small_dripleaf`, `dirt`, `grass_block`, `podzol`, `coarse_dirt`, `mycelium`, `rooted_dirt`, `moss_block`, `mud`, `muddy_mangrove_roots`, `farmland` |
| block `coral_blocks` | the five living coral blocks: `tube_coral_block`, `brain_coral_block`, `bubble_coral_block`, `fire_coral_block`, `horn_coral_block` |
| block `pale_oak_logs` | `pale_oak_log`, `pale_oak_wood`, `stripped_pale_oak_log`, `stripped_pale_oak_wood` |

### 2.5 Flags and events used

| Value | Meaning here |
|---|---|
| flags 2 | write, clients only (bone meal and random tick writes of the bamboo-less plants) |
| flags 3 | `setBlockAndUpdate`: neighbours and clients |
| flags 18 (2 + 16) | clients, and no shape updates of the write (small dripleaf clearing the upper half) |
| flags 35 (1 + 2 + 32) | creative-mode removal of the lower half (`DoublePlantBlock.preventDropFromBottomPart`) |
| flags 260 (4 + 256) | sugar cane and cactus age writes (29b-1 section 2.3) |
| level event 1033 / 1034 | chorus flower grew / chorus flower died: the client plays `CHORUS_FLOWER_GROW` / `CHORUS_FLOWER_DEATH`, source BLOCKS, volume 1.0, pitch 1.0, at the position (read in `LevelEventHandler`; constants `SOUND_CHORUS_GROW`, `SOUND_CHORUS_DEATH`) |
| level event 2001 | block destroy effect with data `Block.getId(state)` (29 section 7.4) |
| game event `BLOCK_CHANGE` | sent by glow berry harvest, dripleaf tilt changes and eyeblossom change |

## 3. The growing plant family (head and body)

### 3.1 Constructor data

`GrowingPlantBlock(properties, growthDirection, shape, scheduleFluidTicks)`; the head adds `growPerTickProbability`. The `age` property of heads is `AGE_25` (0 to 25, default 0).

| Block | Class | Growth direction | `scheduleFluidTicks` | Head probability | `canGrowInto(state)` | `canAttachTo(state)` | Blocks per bone meal | Shape (24) |
|---|---|---|---|---|---|---|---|---|
| `kelp` | `KelpBlock` | UP | true | 0.14 | the state is block `water` (any level) | state not in `cannot_support_kelp` | 1 | `column(16, 0, 9)` |
| `kelp_plant` | `KelpPlantBlock` | UP | true | | | the head's rule | | `Shapes.block()` |
| `weeping_vines` | `WeepingVinesBlock` | DOWN | false | 0.1 | air (`NetherVines.isValidGrowthState`) | always true | `NetherVines` count (3.4) | `column(8, 9, 16)` |
| `weeping_vines_plant` | | DOWN | false | | | true | | `column(14, 0, 16)` |
| `twisting_vines` | `TwistingVinesBlock` | UP | false | 0.1 | air | true | `NetherVines` count | `column(8, 0, 15)` |
| `twisting_vines_plant` | | UP | false | | | true | | `column(8, 0, 16)` |
| `cave_vines` | `CaveVinesBlock` | DOWN | false | 0.1 | air | true | 1 (not used, see 3.5) | `column(14, 0, 16)` |
| `cave_vines_plant` | | DOWN | false | | | true | | `column(14, 0, 16)` |

### 3.2 Rules of the engine

`GrowingPlantBlock` (shared):

1. **Support test** `canSurvive`: let `S` be the state at `pos + opposite(growthDirection)` (below for kelp and twisting vines, above for weeping and cave vines). False when `canAttachTo(S)` is false. Otherwise true when `S` is the head block or the body block of this family, or when `S.isFaceSturdy(level, posOfS, growthDirection)` (the support face of `S` pointing toward the plant, support type FULL, 24 part 1 section 6.5).
2. **Scheduled tick** `tick`: when `!canSurvive`, `destroyBlock(pos, drops = true)`.
3. **Placement** `getStateForPlacement(context)`: let `N` be the state at `clickedPos + growthDirection`. When `N` is the head block or the body block: the body block's default state. Otherwise the head block's `getStateForPlacement(random)` with the level's random, which is the default head state with `age = nextInt(25)` (0 to 24, one draw). Kelp refines the first step: null unless the fluid at the clicked position is in tag `water` and `isFull`; cave vines and the nether vines use the shared rule.
4. **Shape** and `getHeadBlock` / `getBodyBlock` are constants of the subclass.

`GrowingPlantHeadBlock` (heads):

5. `isRandomlyTicking(state)` = `age < 25`.
6. **Random tick** (RT): when `age < 25` and `random.nextDouble() < growPerTickProbability` (the draw is only made when `age < 25`; one `nextDouble`): let `p = pos + growthDirection`; when `canGrowInto(state at p)`, `setBlockAndUpdate(p, getGrowIntoState(state, level.getRandom()))` (flags 3). `getGrowIntoState` is the state with `age` cycled by one (`age + 1`; never wraps because `age < 25`), and cave vines add one more draw (3.5). The random tick makes no light test and no build height test (Open question 6).
7. **Shape update** (SU) of a head, in order: (a) when the changed direction is `opposite(growthDirection)`: if `!canSurvive` schedule a block tick (delay 1, `scheduleTick(pos, thisBlock, 1)`); else if the state at `pos + growthDirection` is the head block or the body block, the result is `updateBodyAfterConvertedFromHead(state, bodyDefaultState)` (the body default state; cave vines copy `berries` from the head, 3.5); (b) when the changed direction is `growthDirection` and the changed neighbour state is the head block or the body block, the same conversion to the body; (c) when `scheduleFluidTicks` is set (kelp) a water tick is scheduled; then the default shape update. In short: a head that has a head or body in its growth direction becomes a body, whether the change that told it came from the growth side or from the anchor side.
8. **Bone meal** (type `GROWER`): valid when `canGrowInto(state at pos + growthDirection)` and that position is inside the build height; success always. Effect: `n = getBlocksToGrowWhenBonemealed(random)`, `a = min(age + 1, 25)`, `p = pos + growthDirection`; repeat up to `n` times while `canGrowInto(state at p)` and `p` is inside the build height: `setBlockAndUpdate(p, state.setValue(age, a))` (the clicked head's own state is the template, so cave vine heads keep their `berries` value), then `p = p + growthDirection`, `a = min(a + 1, 25)`. The write at `p` triggers the shape updates of 7, which turn the old top into body; the loop does not write bodies itself.
9. `getMaxAgeState`, `isMaxAge(state)` (`age == 25`): helpers of the class, not used by the rules above.

`GrowingPlantBodyBlock` (bodies):

10. **Shape update** (SU), in order: (a) when the changed direction is `opposite(growthDirection)` and `!canSurvive`: schedule a block tick (delay 1); (b) when the changed direction is `growthDirection` and the neighbour is neither this body block nor the head block: the result is `updateHeadAfterConvertedFromBody(state, headBlock.getStateForPlacement(random))`, i.e. the top body block becomes a head with a random `age` (`nextInt(25)`, one draw from the `RandomSource` the shape update was given; cave vines copy `berries`); (c) when `scheduleFluidTicks` a water tick; then the default.
11. **Bone meal**: find the head: walk from `pos` one cell at a time in `growthDirection` over the cells that hold this body block (`pos` itself is not tested, only the cells after it); the first cell that does not hold the body block must hold the head block, else there is no head. Valid when a head was found, `canGrowInto(state at head + growthDirection)` and that position is inside the build height; success always. Effect: run the head's `performBonemeal` at the head position with the head's state (8).
12. `getCloneItemStack`: the head block's item (cave vines: `glow_berries`, both blocks). `canBeReplaced(state, context)`: the default result, except false when the item in hand is the head's item (a body is not replaced by placing its own head item).

### 3.2.1 Timing of a destroy against the scheduled tick and the random tick

**Question.** When the support or a neighbour of a plant piece is removed, is the piece destroyed at once (reading 1: the shape update itself removes it), or does the shape update only arrange a later check (reading 2: it schedules a block tick with delay 1 and that tick destroys the piece)? And what happens when the piece's scheduled tick and its random tick fall in the same server tick? **Answer: reading 2 is the artifact's for every piece of the head and body family of 3.2** (kelp, weeping vines, twisting vines, cave vines), and also for `sugar_cane`, `cactus` and `bamboo` (`updateShape` calls `canSurvive`, and when it is false only calls `scheduleTick`; `tick` calls `canSurvive` again and only then `destroyBlock(pos, drops)`; read in `SugarCaneBlock`, `CactusBlock`, `BambooStalkBlock`). Reading 1 is the artifact's for the `VegetationBlock` users and `bamboo_sapling` (their `updateShape` returns air, which `Block.updateOrDestroy` turns into `destroyBlock` inside the same shape-update pass, 29 section 3.2 step 4); the full split is 14.1. For the family of 3.2 the facts that fix the order are:

**Vocabulary.** A *server tick* is one run of `MinecraftServer.tickServer`; the game time (a long counter, 33 section 3.1) is increased **once per server tick, in step 5 of the overworld's level tick**, so inside one server tick some code runs before the increment and some after. *Server tick `g`* below is the server tick whose step 5 sets the game time to `g`. The *value read* by a removal is the game time as the code `getGameTime()` sees it at that moment: `g - 1` before step 5 of server tick `g`, `g` from step 5 of server tick `g` until just before step 5 of server tick `g + 1`. (29 section 4.4 speaks of "game tick `T`" for that value.)

1. **Order inside and between server ticks** (read in `MinecraftServer.runServer`, `processPacketsAndTick`, `tickServer`, `tickChildren`, `ServerLevel.tick`, `ServerLevel.tickTime`; 33 sections 1 and 2.1 agree). In execution order:
   - *Packet phase.* `processPacketsAndTick` first runs `PacketProcessor.processQueuedPackets`, **before** `tickServer`: the packets whose handler starts with `PacketUtils.ensureRunningOnSameThread` (read in `handlePlayerAction` and `handleUseItemOn`: block breaking, block use and placement) were queued by the network threads and are handled here. Which other handlers queue was not enumerated.
   - *Function phase.* `tickServer` runs `tickChildren`, whose step 2 is `ServerFunctionManager.tick`: the functions of the `tick.json` function tag (33 section 1.2 step 2). `ServerFunctionManager.tick` returns at once when the game is frozen (`runsNormally` false); then no function runs, and neither step 5 nor step 6 below runs (16 section 4.9).
   - `tickChildren` steps 3 to 5 (clocks, time heartbeat, effective respawn data): no block change.
   - *Level ticks* (`tickChildren` step 6; the overworld first, then the other levels, each running the steps of 33 section 2.1). Steps 2 to 4: world border, weather, sleep check, sky light. `advanceWeatherCycle` was read to touch only the weather data and to send packets, so none of steps 2 to 4 removes a support. **Step 5: game time + 1** (`ServerLevel.tickTime`, which acts only on the overworld, the level whose `tickTime` flag is set) and **then** the timer queue (`TimerQueue.tick`: functions started with `/schedule`), which therefore already reads the new value. Step 6: the block ticks that are due, then the fluid ticks. Step 7: raids. Step 8: chunk source tick, whose random ticks read the state at the sampled position when each is called (33 section 2.4). Step 9: block events. Step 11: entities, then block entities. Steps 10 and 12: bookkeeping. The Nether and the End tick after the whole overworld tick and read the overworld's game time through their derived level data (33 section 1.2 note), so all of their steps count as "after the increment".
   - *After the level ticks* (`tickChildren` steps 7 to 12, 33 section 1.2): the network connection tick (step 7), then in the same step the console commands (`DedicatedServer.tickConnection` calls `MinecraftServer.tickConnection` and then `handleConsoleInputs`, which runs, in arrival order, the lines that the console thread queued with `handleConsoleInput`; read), the player list tick, debug subscribers and game tests, the registered tickables, chunk sending and the activity monitor. A console command therefore runs **after** the level ticks of the server tick it falls in, and the value it reads is `g` (row 5 of the table below). Commands of `rcon` are different: `DedicatedServer.runCommand` calls `executeBlocking`, which off the server thread queues the command as a task and waits for it, so it runs between server ticks like a chat command (read; row 1).
   - *Between two server ticks* `runServer` calls `waitUntilNextTick`, which runs `runAllTasks`: the tasks queued with `MinecraftServer.execute`. A player's chat command is such a task (`handleChatCommand` calls `tryHandleChat`, which queues the command with `MinecraftServer.execute`; `waitUntilNextTick` is the only caller of `runAllTasks` in `MinecraftServer`; read), so it is run **between** server ticks, after the increment of the one before and ahead of the packet phase of the next.
2. **The shape update schedules, it never destroys** (3.2 items 7 and 10; read in `GrowingPlantHeadBlock.updateShape` and `GrowingPlantBodyBlock.updateShape`). The update that matters arrives from the anchor side (the changed direction is the opposite of the growth direction) and carries the **new** state of the anchor, so `canSurvive` already sees the removal. When it is false the piece calls `scheduleTick(pos, thisBlock, 1)` (the block argument is the piece's own block, the head block for a head and the body block for a body). For this anchor-side update neither piece goes on to a conversion: the head's branch (a) (the test of the cell beyond it) is an `else` of the schedule and runs only when `canSurvive` is true, its branch (b) needs the changed direction to be the growth direction, and the body's branch (b) needs the same; both pieces continue only to the water tick (kelp: `scheduleFluidTicks`) and the default shape update, which returns the state unchanged (3.2 items 7 and 10). A tick that is already pending for the same block at the same position is not scheduled twice (29 section 4.1).
3. **The scheduled tick re-tests** (`GrowingPlantBlock.tick`): `ServerLevel.tickBlock(pos, block)` runs the state's `tick` only when the cell still holds that **block** (the state may differ); otherwise the tick is dropped silently (29 section 4.3). `GrowingPlantBlock.tick` then calls `canSurvive` again with the world as it is now and calls `destroyBlock(pos, drops = true)` only when it is false (29 section 2.2: effects, drops, then the cell becomes the fluid's legacy block, so water for kelp and air elsewhere; flags 3, so the neighbours are told). A support that has come back in between saves the piece.
4. **The delay.** `LevelAccessor.createTick` sets `triggerTick = getGameTime() + delay` with the value read at the moment of the call (read). `LevelTicks.tick` first **collects** every tick whose `triggerTick` is not above the game time (29 section 4.3 steps 1 to 3) and only then runs the collected ones, so a tick scheduled while step 6 runs (delay 1, due the value read plus 1) is not in that collection. Hence a delay-1 tick scheduled when the value read is `v` runs in **step 6 of the server tick whose step 5 sets the game time to `v + 1`**, whatever phase scheduled it. That is the next server tick for a removal made from step 5 of a server tick on (and for a chat command run between ticks), and the **same** server tick for a removal made in the packet phase or the function phase, which precede the increment.
5. **The random tick never tests survival** (3.2 item 6, read in `GrowingPlantHeadBlock.randomTick`): a head with `age < 25` draws `nextDouble`, and on success grows into the cell beyond it when `canGrowInto`; no `canSurvive` call. Bodies are not randomly ticking. `SugarCaneBlock.randomTick` and `BambooStalkBlock.randomTick` also make no `canSurvive` call on the ticked piece (they test the cell above; the cactus tests the survival of the cell it would grow into, 5.1).
6. **The cascade.** A destroy runs in step 6 for a chunk inside the block-ticking range, otherwise it waits (29 section 4.3 step 1); it reads the value `w` of that server tick, writes a new state into the cell, and the neighbour in the growth direction receives a shape update from the anchor side (item 2), so it schedules its own destroy tick, due `w + 1`. A column of `n` pieces above a removed support therefore disappears **one piece per server tick, lowest first**; the lowest piece goes in step 6 of the server tick of item 4.

**Where a removal falls.** One server tick `N` (value `g` after its step 5), in time order; the "value read" is the one of item 4:

| Removal made in (steps of the piece's own level tick) | Value read | Destroy runs in step 6 of | A random tick of the still standing piece can come first |
|---|---|---|---|
| (1) The packet phase of `N`, the function phase of `N`, the overworld's steps 2 to 4 of `N`, and any chat command run between `N - 1` and `N` | `g - 1` | server tick `N` (the **same** server tick) | no: the destroy runs before step 8 of `N`, and step 8 of `N - 1` is past |
| (2) Step 5 of `N` (timer queue, `/schedule`d functions), step 6 of `N` (block and fluid ticks), step 7 of `N` | `g` | server tick `N + 1` | yes, once: step 8 of `N` of the piece's own level |
| (3) Step 8 of `N` | `g` | server tick `N + 1` | only when the pass samples the piece's cell later than the removal (the order of the chunks and sections inside the pass is Open question 1 of 33) |
| (4) Steps 9 and 11 of `N` (block events; entities and block entities) | `g` | server tick `N + 1` | no: the piece's own step 8 of `N` is past |
| (5) After the level ticks: `tickChildren` steps 7 to 12 of `N` (console commands, connection and player-list ticks, game tests, chunk sending) | `g` | server tick `N + 1` | no: step 8 of `N` is past in every level, and the destroy of `N + 1` runs in step 6, before step 8 of `N + 1` |

For a piece in the Nether or the End the rows describe that level's own steps; everything the overworld does in server tick `N` (any of its steps) happens before that level's step 8 of `N`, so such a piece still gets its random tick of `N` after a removal made by the overworld in any of its steps. Frozen game (`runsNormally` false): the function phase, step 5 and step 6 do not run, the value does not change and a pending destroy tick simply waits.

**Order of the steps for one piece whose anchor is removed** (value read `v`; `N` is the server tick of the removal: it is the server tick that sets `v` for the rows (2) to (5), and the one that sets `v + 1` for row (1)):

| Step | When | What happens |
|---|---|---|
| 1 | at the removal | the shape update reaches the piece above the removal: `canSurvive` is false, `scheduleTick(pos, ownBlock, 1)` (due `v + 1`); the piece keeps its state |
| 2 | step 8 of server tick `N`, for the rows (2) and (3) of the table only | a random tick that samples the piece's cell still finds it standing. A head with `age < 25` can grow now, with the usual draws and without any survival test; a body is not ticked |
| 3 | step 6 of the server tick that sets the value `v + 1` (the table's column 3) | the scheduled tick runs (if the cell still holds the same block): `canSurvive` false, `destroyBlock(pos, drops = true)`; the cell becomes water or air; the shape update of the next piece schedules its destroy tick (due `v + 2`) |
| 4 | step 8 of that same server tick | a random tick sampling the cell reads the new state (water or air, not random ticking for kelp heads) and does nothing for the plant |
| 5 | step 6 of the server ticks that set `v + 2`, `v + 3`, ... | the cascade of item 6 |

So the destroy is **due one game-time value after the value the removal read, and it runs in step 6 of the server tick that sets that value**: never at the value that the removal read, but in the **same server tick** as the removal when the removal precedes the increment (row 1). In every case the scheduled destroy runs **before the random ticks of that server tick** (step 6 before step 8): when a scheduled destroy tick and a random tick of the same piece are due in the same server tick the scheduled one runs first, and a destroyed piece is no longer random ticked (the random tick reads the state at the sampled position when it is called). Only a head is randomly ticking (bodies are not), so a random tick can reach a standing piece only through a head. For the piece directly above the removed support it is the random tick of step 8 of the server tick of the removal, and only for rows (2) and (3). In a cascade (item 6) every later piece has its anchor destroyed in step 6, so the head at the top of the column gets the same exposure again, in step 8 of the server tick in which its anchor is destroyed. A standing head can also grow in any server tick as in normal growth (kelp: about 0.0001 per server tick at `random_tick_speed` 3, computed in the third example below). The piece counts below therefore hold only when no random tick samples a head of the column, for example with `random_tick_speed` 0.

**Worked examples** (kelp growth direction UP; water fills the cells above the sand; `age` values are arbitrary; each count is computed by hand from the table above, not observed; the first two assume that no random tick samples a head of the column, for example `random_tick_speed` 0, and then need no random draw):

- *Column cascade.* Sand at y = 10, `kelp_plant` at y = 11 and y = 12, `kelp` head (age 5) at y = 13, water above. (a) The sand is removed in step 11 of server tick `g` (row 4; value read `g`; the cell becomes water; step 8 of server tick `g` is already past, so no random tick comes before the destroy). The `kelp_plant` at y = 11 receives the shape update with `DOWN`, `canSurvive` is false (the cell below is water, which is neither head nor body nor sturdy) and it schedules its tick (due `g + 1`); nothing else changes, all three pieces still stand at the end of server tick `g`. Server tick `g + 1`, step 6: y = 11 is destroyed (it drops the kelp item that the loot table `blocks/kelp_plant` gives, one `minecraft:kelp`, pool with `rolls` 1 and the condition `survives_explosion`, read in `data/minecraft/loot_table/blocks/kelp_plant.json`; document 26 holds the rules, not this table: the key `blocks/<id path>` is 26 section 11.1, the always-true `survives_explosion` without an explosion is its example E1, so there is no random draw; the cell becomes water); the piece at y = 12 receives the update from below and schedules (due `g + 2`). Server tick `g + 2`: y = 12 destroyed; the head at y = 13 schedules (due `g + 3`). Server tick `g + 3`: the head is destroyed. Pieces standing at the end of server tick `g`: 3; of `g + 1`: 2 (y = 12 and 13); of `g + 2`: 1 (y = 13); of `g + 3`: 0. (b) The same column, but the sand is removed by a function of `tick.json` in the function phase of server tick `g` (row 1; value read `g - 1`): the tick at y = 11 is due `g` and runs in step 6 of the **same** server tick `g` (the destroy reads `g`, so y = 12 is due `g + 1`). Pieces standing at the end of server tick `g`: 2 (y = 12 and 13); of `g + 1`: 1 (y = 13); of `g + 2`: 0.
- *Support restored in time.* The same column; the sand is removed in step 11 of server tick `g` (due `g + 1`) and a sand block is put back at y = 10 **before step 6 of server tick `g + 1`**: by a chat command run between the two server ticks, or by a function of `tick.json` in the function phase of server tick `g + 1` (the packet phase and the function phase precede step 5, so they also precede step 6). The tick at y = 11 runs in step 6, `canSurvive` is true (the cell below is sturdy sand), nothing is destroyed, and no further tick is scheduled; the column stays. The same holds when one function removes and restores the sand in the function phase of server tick `g` (value read `g - 1`, due `g`): the tick runs in step 6 of server tick `g` and finds the support.
- *Random tick in the tick of the removal (derived from the code read, not observed).* A lone `kelp` head at y = 11 (age 5) on sand at y = 10, water above. The sand is removed in step 5 of server tick `g` by a function run by `/schedule` (row 2; value read `g`: the timer queue runs after the increment); the head schedules a tick of block `kelp` due `g + 1`, and step 6 of server tick `g` does not collect it. In step 8 of server tick `g` the head's cell can be sampled (probability `1 - (1 - 1/4096)^3`, about 0.000732 per tick at `random_tick_speed` 3, treating the picks as independent and uniform; the real generator is the per-level `randValue` sequence of 33 section 2.4; computed) and then its random tick succeeds with probability 0.14 (`nextDouble < 0.14`, 0.0001025 per server tick in all, computed): a head with `age` 6 is written at y = 12, and the shape update from that write turns the head at y = 11 into `kelp_plant`. In server tick `g + 1` the scheduled tick finds a `kelp_plant` where it expected `kelp`, so it is dropped, and nothing in these classes schedules a new check for the converted piece: it and the new head above stay standing without support (the new head's own survival test passes because its anchor is now a body block of the family) until some later update from the anchor side reaches the piece at y = 11. With the removal in the function phase of server tick `g` instead (row 1), the tick is due `g` and runs in step 6 of server tick `g`, before step 8: the head is simply gone and nothing can grow, so this narrow case exists only for removals of rows (2) and (3).

### 3.3 Kelp

`kelp` and `kelp_plant`: the engine of 3.2 with growth UP, probability 0.14, `canGrowInto` = water block, `canAttachTo` = not `magma_block`, `scheduleFluidTicks` true. Both always report a water source as their fluid state. Bone meal grows one block (`getBlocksToGrowWhenBonemealed` returns 1). Registry flags and sounds are 24 part 6.

Expected growth time (inferred arithmetic, section 2.4 of 29b-1): with `random_tick_speed` 3 a given head receives `3 / 4096` random ticks per game tick, each succeeds with 0.14 when water is above, so about 0.0001025 growths per game tick, one growth per 9,752 game ticks (8.1 minutes) on average.

### 3.4 Weeping and twisting vines (`NetherVines`)

Constants of `NetherVines`: `GROW_PER_TICK_PROBABILITY` 0.1, `BONEMEAL_GROW_PROBABILITY_DECREASE_RATE` 0.826. `isValidGrowthState(state)` = the state is air. `getBlocksToGrowWhenBonemealed(random)`:

1. `threshold = 1.0`, `count = 0`.
2. Draw `nextDouble()`; when it is below `threshold`: `threshold = threshold * 0.826`, `count + 1`, repeat step 2. Otherwise stop and return `count`.

The first draw is below 1.0 always (`nextDouble` is below 1), so `count >= 1`. `P(count >= k) = 0.826^(k (k - 1) / 2)`: 1, 0.826, 0.5636, 0.3176, 0.1478, 0.0568 for `k` = 1 to 6, mean 2.94. Weeping vines grow DOWN from a head under a block, twisting vines grow UP from a head on a block; both are the plain engine otherwise (no light, no water, bodies without fluid ticks). Survival of the head and body is rule 1 of 3.2 with `canAttachTo` always true: the anchor block must have the face toward the vine sturdy, or be a head or body of the same family.

### 3.5 Cave vines and glow berries (`cave_vines`, `cave_vines_plant`)

Both blocks add the boolean property `berries` (default false) to the engine; the registry gives them light 14 when `berries` (`CaveVines.emission(14)`, 24 part 8). Rules:

1. **Growth** (head random tick 3.2 step 6, direction DOWN, probability 0.1, air only): `getGrowIntoState` = the age-cycled state with `berries` set from one extra draw: `berries = random.nextFloat() < 0.11` (constant `CHANCE_OF_BERRIES_ON_GROWTH`). Draw order of one growth: `nextDouble` (the 0.1 test), then `nextFloat`.
2. **Placement** (head): `age = nextInt(25)`; `berries` false (default).
3. **Conversions**: head to body copies `berries` (`updateBodyAfterConvertedFromHead`), body to head copies `berries` onto the new random-age head (`updateHeadAfterConvertedFromBody`).
4. **Bone meal** (both blocks, overriding the engine): valid when `berries` is false; success always; effect: `setBlock(pos, state with berries = true, flags 2)` on the clicked block only. The head's engine bone meal (3.2 step 8) and the body's redirect to the head (3.2 step 11) are both overridden and unused: cave vines never grow longer by bone meal in this version.
5. **Harvest** (`CaveVines.use`, called by `useWithoutItem` of both blocks, so any hand or item use without an item handler): when `berries` is false the result is PASS. Otherwise, on a client level the result is SUCCESS with no other effect; on a server level, in this order: (a) the loot table `harvest_cave_vine` (a `BuiltInLootTables` key; DATA) is rolled with the block interaction context (position, state, block entity if any, no tool, `this_entity` the user) and every stack is dropped with `Block.popResource(level, pos, stack)` (the context's `this_entity` is the user, inferred from the argument order); (b) `pitch = Mth.randomBetween(level.random, 0.8, 1.2)` and the sound `CAVE_VINES_PICK_BERRIES` (source BLOCKS, volume 1.0, pitch `pitch`) is played at `pos` for everyone (no excluded player); (c) `setBlock(pos, state with berries = false, flags 2)`; (d) game event `BLOCK_CHANGE` at `pos` with context (the user, the new state); result SUCCESS.
6. Shapes and sounds are 24 part 8; both have `noCollision`, `instabreak` and no `occlusion` flags.

## 4. Sugar cane (`SugarCaneBlock`)

State: `age` 0 to 15 (`AGE_15`), default 0, no other property. Shape `column(12, 0, 16)`. Registry flags: `noCollision`, `randomTicks`, `instabreak`, `pushReaction(POPPED)`.

1. **Survival** `canSurvive`: let `B` be the state below. True when `B` is sugar cane. Otherwise, when `B` is in tag `supports_sugar_cane`: for each horizontal direction `d` in the order NORTH, EAST, SOUTH, WEST, look at `posBelow + d`: true as soon as the fluid state there is in the fluid tag `supports_sugar_cane_adjacently` (as shipped: water) **or** the block state there is in the block tag `supports_sugar_cane_adjacently` (as shipped: `frosted_ice`). Otherwise false. (The neighbour test is made around the block **below**, so the soil block must touch water at its own level.)
2. **Shape update** (SU): when `!canSurvive` schedule a block tick (delay 1); then the default. `tick`: when `!canSurvive`, `destroyBlock(pos, drops = true)`.
3. **Random tick** (RT), draw-free: only when the cell above is air (`isEmptyBlock`): `h` = 1, then for as long as the state at `pos.below(h)` is sugar cane, `h = h + 1`. When `h < 3`: with `a` = this block's age: if `a == 15`, `setBlockAndUpdate(pos.above(), defaultState)` (a new cane, age 0, flags 3), then `setBlock(pos, age 0, flags 260)`; else `setBlock(pos, age a + 1, flags 260)`. When `h >= 3` nothing happens (the age does not advance).
4. No bone meal. The sugar cane tint is the grass colour (24 part 1 section 9.3).

Growth time (inferred): 16 random ticks per new block, so with random tick speed 3 about `16 * 4096 / 3 = 21,845` game ticks (18.2 minutes) per growth step.

## 5. Cactus and cactus flower

### 5.1 `cactus` (`CactusBlock`)

State `age` 0 to 15, default 0. Strength 0.4 (24), sound `WOOL`, `randomTicks`, `pushReaction(POPPED)`. Constants: `MAX_CACTUS_GROWING_HEIGHT` 3, `ATTEMPT_GROW_CACTUS_FLOWER_AGE` 8, flower chances 0.1 (column shorter than 3) and 0.25 (column of 3 or more). Selection shape `column(14, 0, 16)`, collision shape `column(14, 0, 15)`; `isPathfindable` is false.

1. **Survival**: for each horizontal direction (NORTH, EAST, SOUTH, WEST): false when the neighbouring block state `isSolid()` or the neighbouring fluid is in fluid tag `lava`. Then true when the block below is a cactus or in tag `supports_cactus` (sand blocks as shipped) **and** the state above is not a liquid (`BlockState.liquid()`); else false.
2. **Shape update** (SU): `!canSurvive` schedules a block tick (delay 1); `tick`: `destroyBlock(pos, drops)` when `!canSurvive`.
3. **Entity inside** (EV, `entityInside`): `entity.hurt(damageSources.cactus(), 1.0)` for every entity inside (no side test; the call frequency is 18).
4. **Random tick** (RT, draw order as listed): let `above = pos.above()`, `a` the age.
   1. When `above` is not air: stop.
   2. `h` = 1; while the state at `pos.below(h)` is a cactus: `h = h + 1`, and when `h == 3` and `a == 15` stop with no effect. (After the loop `h` is one plus the number of cacti directly below; a column already 3 high refuses to grow at age 15.)
   3. When `a == 8` and `canSurvive(default cactus state, level, above)` (the cactus survival rule evaluated at `above`: neighbours of `above` not solid and not lava, below is this cactus, the cell above `above` not liquid): `chance = 0.25` when `h >= 3`, else `0.1`; draw `nextDouble()`; when it is `<= chance` (not above the chance), `setBlockAndUpdate(above, cactus_flower default)`. The age still advances (step 5) whether or not the draw succeeded.
   4. Otherwise (the conditions of step 3 did not hold), when `a == 15` and `h < 3`: `setBlockAndUpdate(above, cactus default state)` (age 0), `setBlock(pos, age 0, flags 260)`, then a neighbour-changed notification is sent to the new cactus (no observable effect, 29 section 3.1). The age is not advanced afterwards (`a == 15`).
   5. When `a < 15` (also after step 3): `setBlock(pos, age a + 1, flags 260)`.

   No random draw is made except in step 3.

### 5.2 `cactus_flower` (`CactusFlowerBlock extends VegetationBlock`)

No properties, no ticks. Shape `column(14, 0, 12)`; registry: `noCollision`, `instabreak`, `pushReaction(POPPED)`. `mayPlaceOn(state below)`: the block below is in tag `support_override_cactus_flower` (`cactus`, `farmland`) **or** `isFaceSturdy(level, below, UP, SupportType.CENTER)`. `canSurvive` and `updateShape` are the `VegetationBlock` rules (2.1). Placement and bone meal: none beyond the base.

## 6. Bamboo

### 6.1 States and constants

`bamboo` (`BambooStalkBlock`): `age` 0 to 1 (`AGE_1`: 0 thin, 1 thick), `leaves` (`none`, `small`, `large`, enum `BambooLeaves`, serialized names read: `none`, `small`, `large`), `stage` 0 to 1 (0 growing, 1 done growing); default age 0, leaves none, stage 0. `MAX_HEIGHT` 16. `isRandomlyTicking` = `stage == 0`. Shapes (24 part 6): selection `column(10, 0, 16)` when `leaves == large` else `column(6, 0, 16)`, collision `column(3, 0, 16)`, all moved by the XZ offset of the position; `isPathfindable` false; `propagatesSkylightDown` true; registry strength 1.0, `forceSolidOn`, `dynamicShape`, `offsetType(XZ)`.

`bamboo_sapling` (`BambooSaplingBlock`): no properties; shape `column(8, 0, 12)` moved by the XZ offset; registry `randomTicks`, `noCollision`, `offsetType(XZ)`, strength 1.0, `instabreak`.

Support: `canSurvive` for both = the block below is in tag `supports_bamboo`.

### 6.2 Rules of the stalk

1. **Placement** (`getStateForPlacement`): null when the fluid at the clicked position is not empty or the block below is not in `supports_bamboo`. Let `B` = the state below. `B` is `bamboo_sapling`: the default stalk with `age = 0`. `B` is `bamboo`: the default stalk with `age = 1` when `B.age > 0`, else 0. Otherwise let `A` = the state above: `A` is `bamboo`: the default stalk with `age = A.age`; else the default **`bamboo_sapling`** state (placing the item on soil plants a sapling).
2. **Shape update** (SU): `!canSurvive` schedules a block tick (delay 1). When the changed direction is UP, the neighbour is `bamboo` and `neighbour.age > age`, the result is the state with `age` cycled (0 becomes 1); otherwise default. Because a changed neighbour starts a new shape update chain (29 section 2.2 step 7), a stalk that turns thick makes every thinner stalk below it thick, one after the other.
3. `tick`: `destroyBlock(pos, drops)` when `!canSurvive`.
4. **Random tick** (RT, only `stage == 0`): the tick does nothing when `random.nextInt(3) != 0` (1/3 of random ticks continue; this draw is first). Then require `pos.above()` is air and `getRawBrightness(pos.above(), 0) >= 9`; let `h = getHeightBelowUpToMax(level, pos) + 1` (`getHeightBelowUpToMax` counts contiguous bamboo blocks below `pos`, stopping at 16); when `h < 16`, `growBamboo(state, level, pos, random, h)`. The ticked stalk is the top of the column because the cell above is air.
5. **`growBamboo(state, level, pos, random, h)`** writes the new top stalk at `pos.above()` (flags 3). `B1` = the state at `pos.below()`, `B2` = the state at `pos.below(2)`, `leaves = none`:
   1. When `h >= 1` (always true on the callers read): if `B1` is not bamboo or `B1.leaves == none`: `leaves = small`. Otherwise (`B1` is bamboo with leaves): `leaves = large`; and when `B2` is bamboo, `setBlockAndUpdate(pos.below(), B1 with leaves small)` then `setBlockAndUpdate(pos.below(2), B2 with leaves none)` (flags 3, in that order).
   2. `thick = (state.age == 1) or (B2 is bamboo)`: the new stalk's `age` is 1 when `thick`, else 0.
   3. `done = (h >= 11 and random.nextFloat() < 0.25) or (h == 15)`: the new stalk's `stage` is 1 when `done`, else 0. The `nextFloat` is drawn only when `h >= 11` (before the `h == 15` test).
   4. `setBlockAndUpdate(pos.above(), defaultState with age, leaves, stage)`.
6. **Bone meal**: let `a` = the number of contiguous bamboo blocks above `pos` (`getHeightAboveUpToMax`, at most 16), `b` the number below, `top = pos.above(a)`, `p = pos.above(a + 1)`. Valid when `a + b + 1 < 16`, the state at `top` has `stage != 1`, `p` is inside the build height and `p` is air; success always. Effect: `total = a + b + 1`, `n = 1 + nextInt(2)` (1 or 2, one draw); repeat `n` times: `S` = the state at `top`, `p = top.above()`; stop when `total >= 16`, or `S.stage == 1`, or `p` is not air, or `p` is outside the build height; else `growBamboo(S, level, top, random, total)`, `top = top.above()`, `total = total + 1`. (`growBamboo` makes its `nextFloat` draw only when `total >= 11`.)
7. `getCloneItemStack` of a sapling is the `bamboo` item.

### 6.3 Rules of the sapling

1. **Random tick** (RT): when `random.nextInt(3) == 0`, `pos.above()` is air and `getRawBrightness(pos.above(), 0) >= 9`: `growBamboo(level, pos)`: `setBlockAndUpdate(pos.above(), bamboo default state with leaves small)` (age 0, stage 0).
2. **Shape update** (SU): when `!canSurvive` the result is air; when the changed direction is UP and the neighbour is `bamboo` the result is the **default `bamboo` state** (leaves none, age 0, stage 0): the sapling is replaced by a stalk the moment the first stalk appears above it.
3. **Bone meal**: valid when `pos.above()` is air and inside the build height; success always; effect `growBamboo(level, pos)` as in step 1.

Growth pattern (worked example, 16.1): after the sapling conversion the column is [none, small]; the leaves pattern then keeps the top two stalks large, the third from the top small and every lower stalk none, and from the fourth stalk on all stalks are thick.

## 7. Vines (`VineBlock`)

The complete text is 24 part 4 section 6.7 (properties `up`, `north`, `east`, `south`, `west`, shape, support rules, placement, rotate and mirror, and the draw-ordered random tick). This section records what was re-read in the artifact and found to agree, and the details that the other text leaves open.

| Item | Read value |
|---|---|
| Random tick gate | the game rule `spread_vines` (key `spread_vines`, category `UPDATES`, default true) and `nextInt(4) == 0` |
| Crowding test `canSpread` | the box from `pos + (-4, -1, -4)` to `pos + (4, 1, 4)` (`BlockPos.offset`) is scanned with `findBlocksIn(...).filterState(is this block).atMostMatched(4)`: true when at most 4 vine blocks lie inside (the vine itself included). The box is the set between the two corners by their minimum and maximum coordinates (`BlockScanUtils.findBlocks`, read; `BoxBlockMatcher` only delegates to it). The scan is section based and clamps each section's last index to the maximum corner itself (not corner + 1), so both corners are inclusive (a 9 x 3 x 9 volume); the innermost per-cell loop `findBlocksInSection` was not read (Open question 5) |
| Direction draw | `Direction.getRandom` (2.3) |
| Wrap-over chance | `nextFloat()` converted to double compared below 0.05, drawn only when the four earlier branches of the horizontal case failed |
| Copy of faces to the block above (UP case) | for each of NORTH, EAST, SOUTH, WEST: `nextBoolean()` first; the face survives only when the draw is false **and** `isAcceptableNeighbour(level, above + d, d)`; four draws always |
| Face copy downwards (`copyRandomFaces`) | for each of NORTH, EAST, SOUTH, WEST: `nextBoolean()` first, and when true and the source vine has that face, the target gets it; four draws always |
| `hasHorizontalConnection` | any of the four horizontal faces is true |
| Flags | every write of the random tick uses flags 2 |
| Re-check of the `up` face (`getUpdatedState`) | uses `isAcceptableNeighbour(level, pos.above(), Direction.DOWN)`: `MultifaceBlock.canAttachTo(level, DOWN, above, stateAbove)` tests that the state above has a full face toward `opposite(DOWN)` = UP, i.e. its **top** face, in contrast to the random tick UP branch and placement, which pass UP and so test the **bottom** face of the block above. This is what the bytecode does (read); see Open question 4 |
| `canBeReplaced` | a vine is replaced while it has fewer than 5 faces; the face-property map has 5 entries (no `down`) |
| `updateShape` | for a change from below (DOWN) the default; otherwise the recomputed state of `getUpdatedState`, or air when it has no face |

## 8. Chorus plant and chorus flower

### 8.1 `chorus_plant` (`ChorusPlantBlock extends PipeBlock`, size 10)

Six boolean properties `north`, `east`, `south`, `west`, `up`, `down`, all default false. Strength 0.4, sound `WOOD`, `noOcclusion`, `forceSolidOff` (24). The arm shapes are the `PipeBlock` shapes of apothem size 10 (24 part 6). `isPathfindable` false.

1. **`getStateWithConnections(level, pos, state)`**: for each direction the property is set by `trySetValue` to: for DOWN: the block below is a chorus plant, a chorus flower, **or** in tag `supports_chorus_plant`; for UP, NORTH, EAST, SOUTH, WEST: the neighbour at that side is a chorus plant or a chorus flower. Placement (`getStateForPlacement`) is this function on the default state.
2. **Shape update** (SU): when `!canSurvive` schedule a block tick (delay 1) and return the default `PipeBlock` update. Otherwise the property of the changed direction is set to `connected`: the changed neighbour is a chorus plant or flower, or (the changed direction is DOWN and the neighbour is in `supports_chorus_plant`).
3. `tick`: `destroyBlock(pos, drops)` when `!canSurvive`.
4. **Survival** `canSurvive`: let `B` = the state below and `A` = the state above, `both` = neither is air. For each horizontal direction: let `N` be the neighbour at that side; when `N` is a chorus plant: false when `both`; otherwise look at the block below `N`: when it is a chorus plant or in `supports_chorus_plant`, the result is **true** at once. After the loop: true when `B` is a chorus plant or in `supports_chorus_plant`, else false.

### 8.2 `chorus_flower` (`ChorusFlowerBlock`)

State `age` 0 to 5 (`AGE_5`), default 0; 5 is dead (`DEAD_AGE`). The constructor argument is the plant block (`chorus_plant`). `isRandomlyTicking` = `age < 5`. Block support shape `column(14, 0, 15)` (the selection shape is the default). Strength 0.4, sound `WOOD`.

1. **Survival** `canSurvive`, with `B` = the state below: true when `B` is the chorus plant or in `supports_chorus_flower`. False when `B` is not air. With air below: `found = false`; for each horizontal direction, `N` = the neighbour: when `N` is a chorus plant: false if `found` is already true, else `found = true`; else when `N` is not air: false. The result is `found` (exactly one horizontal plant neighbour and all other horizontal neighbours air).
2. **Shape update** (SU): for any changed direction other than UP, when `!canSurvive`: schedule a block tick (delay 1); then the default. `tick`: `destroyBlock(pos, drops)` when `!canSurvive`.
3. **Projectile hit** (`onProjectileHit`): on a server level, when `projectile.mayInteract(level, pos)` and `projectile.mayBreak(level)`: `destroyBlock(pos, drops = true, projectile)`.
4. **Random tick** (RT). Let `above = pos.above()`; do nothing when `above` is not air or `above.y > level.getMaxY()`, or `age >= 5`. Then:
   1. `grow = false`, `endBelow = false`; `B` = the state below.
   2. When `B` is in `supports_chorus_flower`: `grow = true`.
   3. Else when `B` is the chorus plant: `h = 1`; then look at up to 3 further cells downward, one at a time, starting 2 below `pos`: each cell that is the chorus plant adds 1 to `h`; the first cell that is not the plant ends the look, and when that cell is in `supports_chorus_flower` (end stone), `endBelow = true` (when all 3 are plant, the look ends with `h = 4` and `endBelow` false). Then `grow = (h < 2)` or `(h <= nextInt(endBelow ? 5 : 4))`; the draw is made only when `h >= 2`.
   4. Else when `B` is air: `grow = true`. (Any other block below leaves `grow` false.)
   5. **Growing up**: when `grow` and `allNeighborsEmpty(level, above, none)` and `pos.above(2)` is air: `setBlock(pos, chorus_plant with connections (getStateWithConnections on the plant default), flags 2)`, then `placeGrownFlower(above, age)`: `setBlock(above, flower with the same age, flags 2)` and level event 1033 at `above`.
   6. **Else, branching** when `age < 4`: `n = nextInt(4)`, plus one when `endBelow`; `grew = false`; repeat `n` times: `d = Plane.HORIZONTAL.getRandomDirection(random)` (one `nextInt(4)`), `q = pos + d`; when `q` is air **and** `q.below()` is air **and** `allNeighborsEmpty(level, q, opposite(d))`: `placeGrownFlower(q, age + 1)` and `grew = true`. Afterwards: when `grew`, `setBlock(pos, chorus_plant with connections, flags 2)`; else `placeDeadFlower(pos)`.
   7. **Else** (`age == 4`, and step 5 did not apply): `placeDeadFlower(pos)`: `setBlock(pos, flower with age 5, flags 2)` and level event 1034 at `pos`. Step 6 also ends in `placeDeadFlower(pos)` when no branch was placed.
5. **`allNeighborsEmpty(level, pos, exceptDirection)`**: for each horizontal direction other than `exceptDirection` (the argument may be none): the neighbour at that side must be air (`isEmptyBlock`); the result is false at the first non-air. The cells above and below are not tested.
6. A flower of age 5 is no longer random-ticked (`isRandomlyTicking`).

## 9. Seagrass, tall seagrass, double plants, short grass and ferns, tall flowers

### 9.1 `DoublePlantBlock` (base of `tall_grass`, `large_fern`, `pitcher_plant`, `tall_seagrass`, tall flowers, `small_dripleaf`, `pitcher_crop`)

Property `half` (`DoubleBlockHalf`: `lower`, `upper`), default `lower`. It is **not** a `BonemealableBlock`: `tall_grass`, `large_fern` and `pitcher_plant` have no bone meal.

1. **Placement** `getStateForPlacement`: when `clickedPos.y < level.getMaxY()` and the state at `clickedPos.above()` `canBeReplaced(context)`: the default (lower) state; else null.
2. **`setPlacedBy`**: `setBlockAndUpdate(pos.above(), default state with half upper and waterlogged copied (copyWaterloggedFrom))` (flags 3). (Small dripleaf overrides it, 12.4.)
3. **Survival** `canSurvive`: for the upper half: the state below is this block and its half is lower. For the lower half: the `VegetationBlock` rule (`mayPlaceOn(below)`).
4. **Shape update** (SU): let `h` be this state's half and `d` the changed direction. (a) When `d` is vertical and `(h == lower) == (d == UP)` (the changed neighbour is the partner cell): when the neighbour is not this block, or has the **same** half as this state, the result is air. (b) Otherwise when `h == lower`, `d == DOWN` and `!canSurvive`: air. (c) Otherwise the `VegetationBlock` update (air when `!canSurvive`, else the state).
5. **`placeAt(level, lowerState, pos, flags)`**: `setBlock(pos, lowerState with half lower and waterlogged copied, flags)`, then `setBlock(pos.above(), lowerState with half upper and waterlogged copied, flags)`.
6. **Breaking by a player** (EV): on a server, in `playerWillDestroy`: when the player `preventsBlockDrops` (creative), `preventDropFromBottomPart`: when this state is the upper half and the state below is the same block with half lower: set the lower position to the default water state when its fluid is water (`FluidState.is(Fluids.WATER)`) else to the default air state, flags 35, and level event 2001 at the lower position with data `Block.getId(lowerState)`, sent to everyone except the breaking player; otherwise (not creative) `dropResources(state, level, pos, no block entity, player, main hand item)`. Then the `VegetationBlock` default. `playerDestroy` runs the default with the **air** state as the destroyed state, so the break itself drops nothing (the drops come from `playerWillDestroy`).
7. **Render offset seed** (`getSeed`): `Mth.getSeed(pos.x, (lower ? pos : pos.below()).y, pos.z)`: both halves use the lower half's position, so they share the offset (client).

### 9.2 `seagrass` (`SeagrassBlock extends VegetationBlock implements BonemealableBlock, LiquidBlockContainer`)

Shape `column(12, 0, 12)`. Registry: `replaceable`, `noCollision`, `instabreak`.

1. `mayPlaceOn(below)`: `below.isFaceSturdy(level, belowPos, UP)` and below not in `cannot_support_seagrass` (`magma_block`). Survival is the `VegetationBlock` rule; **water is only required at placement**.
2. **Placement**: null unless the fluid at the clicked position is in tag `water` and full; otherwise the default state.
3. **Shape update**: the `VegetationBlock` update; when the result is not air, a water tick is scheduled.
4. Fluid state: always the water source. `LiquidBlockContainer`: no liquid can be placed in it.
5. **Bone meal** (valid): the block at `pos.above()` is block `water` (any level). Success always. Effect: `setBlock(pos, tall_seagrass default (lower), flags 2)` and `setBlock(pos.above(), tall_seagrass upper, flags 2)`. (The use of bone meal on the sea floor that scatters seagrass is `growWaterPlant`, 17 section 3.4.)

### 9.3 `tall_seagrass` (`TallSeagrassBlock extends DoublePlantBlock`)

Shape `column(12, 0, 16)`. `mayPlaceOn` as seagrass (9.2 step 1). Survival: upper half as 9.1; lower half: the `DoublePlantBlock` rule **and** the fluid at `pos` is in tag `water` and full. Placement: the `DoublePlantBlock` placement, and null unless the fluid at `clickedPos.above()` is in tag `water` and full. The fluid state is the water source; no liquid can be placed. `getCloneItemStack` is the `seagrass` item. Not bonemealable.

### 9.4 Summary of what is not bonemealable

`DoublePlantBlock` itself, `tall_seagrass`, the flowers (10.1), `wither_rose`, `eyeblossom`, `sugar_cane`, `cactus`, `cactus_flower`, `kelp` bodies without a head, `vine`, `lily_pad`, `hanging_roots`, `spore_blossom`, `mangrove_roots`, `dead_bush`.

### 9.5 `short_grass` and `fern` (`TallGrassBlock extends VegetationBlock implements BonemealableBlock`)

Shape `column(12, 0, 13)`, offset XYZ (24). Registry: `replaceable`, `noCollision`, `instabreak`.

1. **Bone meal**: `grown` = `large_fern` when this block is `fern`, else `tall_grass`. Valid when `grown`'s default (lower) state `canSurvive` at `pos`, `pos.above()` is air and `pos.above()` is inside the build height. Success always. Effect: `DoublePlantBlock.placeAt(level, grown default state, pos, flags 2)` (9.1 step 5): the lower half replaces the clicked block, the upper half goes above, both with `waterlogged` copied if they have the property (they do not).

### 9.6 `sunflower`, `lilac`, `rose_bush`, `peony` (`TallFlowerBlock extends DoublePlantBlock implements BonemealableBlock`)

Bone meal is always valid and always succeeds; the effect is `Block.popResource(level, pos, new ItemStack(thisBlock))`: the block drops its item (9.1 does not grow it). The usual item cost applies (29b-1 section 5.3 step 2).

## 10. Small plants

### 10.1 `FlowerBlock` (14 blocks)

`FlowerBlock extends VegetationBlock implements SuspiciousEffectHolder`. Shape `column(6, 0, 10)` moved by the block offset (XZ). The constructor takes a mob effect and a duration in seconds and stores the suspicious stew effect entry `(effect, floor(seconds * 20))` (read in `makeEffectList`); the per-flower values (effect, seconds) are registration constants and are tabulated in 24 part 2. `getBeeInteractionEffect` is null. Survival is the `VegetationBlock` rule (below in `supports_vegetation`). No tick, no bone meal (2.2), no entity effect.

### 10.2 `wither_rose` (`WitherRoseBlock extends FlowerBlock`)

1. `mayPlaceOn(below)`: below in tag `supports_wither_rose` (`#supports_vegetation`, `netherrack`, `soul_sand`, `soul_soil`).
2. **Entity inside** (EV): on a server level, difficulty not peaceful, the entity is a `LivingEntity` and **not** `isInvulnerableTo(level, damageSources.wither())`: `entity.addEffect(wither, 40 ticks, amplifier 0)` (`getBeeInteractionEffect` is that instance; the constructor was called with the effect and the duration only, so the amplifier is the constructor default, 0, inferred).
3. Client: smoke particles (15).

### 10.3 `open_eyeblossom`, `closed_eyeblossom` (`EyeblossomBlock extends FlowerBlock`)

The block has a `Type` enum `OPEN` (open true, effect `blindness` 11 s, long sound `EYEBLOSSOM_OPEN_LONG`, short sound `EYEBLOSSOM_OPEN`, particle colour 16545810) and `CLOSED` (open false, effect `nausea` 7 s, `EYEBLOSSOM_CLOSE_LONG`, `EYEBLOSSOM_CLOSE`, colour 6250335). `transform()` is the other type; `block()` and `state()` give the open or closed block and its default state. Both blocks have the random tick flag, no properties, shape of flowers (24), survival as `VegetationBlock`.

1. **`tryChangingState(state, level, pos, random)`**: `want` = the value of the environment attribute `gameplay/eyeblossom_open` at `pos`, turned into a boolean with the block's own `open` as the default for the `default` state of the tri-state (`TriState.toBoolean(open)`). When `want == type.open`: return false (nothing changes). Otherwise: `setBlockAndUpdate(pos, type.transform().state())` (flags 3); game event `BLOCK_CHANGE` at `pos` with context (no entity, the **old** state); `type.transform().spawnTransformParticle(level, pos, random)` (the trail particle, 42 part 5 section 3.11); then scan the box from `pos + (-3, -2, -3)` to `pos + (3, 2, 3)` for blocks whose state is **identical** to the old `state` (reference equality): for each such neighbour `q` (the changed block itself is no longer one): `dist = sqrt(distSqr(pos, q))`, `delay = random.nextIntBetweenInclusive((int)(dist * 5), (int)(dist * 10))`, `scheduleTick(q, q's block, delay)` (a block tick). Return true.
2. **Random tick** (RT): when `tryChangingState` returned true, play the sound `type.transform().longSwitchSound` (source BLOCKS, volume 1.0, pitch 1.0, at `pos`, no excluded player); then the `FlowerBlock` default (nothing).
3. **Scheduled tick** (ST): the same, but the sound is `type.transform().shortSwitchSound`. So the change spreads through a patch with a delay proportional to distance (5 to 10 ticks per block), each flower using the short sound.
4. **The attribute**: as shipped, the overworld timeline `day` has the track `gameplay/eyeblossom_open` with the boolean keyframes (12600 ticks: true) and (23401 ticks: false) of the 24000-tick day (33; DATA read from `data/minecraft/timeline/day.json`); dimensions without the track return the tri-state default, which makes `want == open` and so no change.
5. **Entity inside** (EV): on a server, difficulty not peaceful, the entity is a `Bee` with `Bee.attractsBees(state)` and not already poisoned: `bee.addEffect(poison, 25 ticks)` (`getBeeInteractionEffect`; amplifier 0 as for the wither rose, inferred). `Bee.attractsBees(state)` (read): true when the state is in block tag `bee_attractive` **and** its `waterlogged` property, if the block has one, is false; for `sunflower` it is then true only for the upper half (`half == upper`); every other member of the tag is true. As shipped (file read in this round) the tag holds exactly 29 entries: `dandelion`, `open_eyeblossom`, `poppy`, `blue_orchid`, `allium`, `azure_bluet`, the four tulips, `oxeye_daisy`, `cornflower`, `lily_of_the_valley`, `wither_rose`, `torchflower`, `sunflower`, `lilac`, `peony`, `rose_bush`, `pitcher_plant`, `flowering_azalea_leaves`, `flowering_azalea`, `mangrove_propagule`, `cherry_leaves`, `pink_petals`, `wildflowers`, `chorus_flower`, `spore_blossom` and `cactus_flower`. `golden_dandelion` and `closed_eyeblossom` are NOT members (so the tag does not hold all 14 small flowers of 1.2), while `wither_rose` and `pitcher_plant` are. So only a bee inside an **open** eyeblossom is poisoned (DATA, `tags/block/bee_attractive.json`).
6. Client: a sound `EYEBLOSSOM_IDLE` (15).

### 10.4 `pink_petals`, `wildflowers` (`FlowerBedBlock`)

Properties `facing` (`HORIZONTAL_FACING`, default NORTH) and `flower_amount` (1 to 4, default 1). `FlowerBedBlock implements BonemealableBlock, SegmentableBlock` (the segment property is `flower_amount` here; the default interface property `segment_amount` 1 to 4 is used by other blocks). Shape height 3 pixels for both (constructor argument); the shape is the union of `amount` quarter-pads, rotating counter-clockwise from `facing` (`SegmentableBlock.getShapeCalculator`), enclosed to a single box (24). (Round R1, read in `SegmentableBlock`, `FlowerBedBlock` and `Blocks`: the pad height is `getShapeHeight()`; `FlowerBedBlock` returns its constructor argument 3 for both blocks, while `LeafLitterBlock` does not override the interface default, which is **1.0**, so `leaf_litter` uses the same quarter-pad construction with height 1 pixel, not 3; 51 rule R-F38.)

1. **Placement** (`SegmentableBlock.getStateForPlacement`): when the state at the clicked position is this block, the same state with `flower_amount = min(4, amount + 1)`; otherwise the default state with `facing = opposite(placer horizontal direction)` (`context.getHorizontalDirection().getOpposite()`).
2. **`canBeReplaced(state, context)`**: true when `!context.isSecondaryUseActive()`, the item in hand is this block's item and `amount < 4`; otherwise the `VegetationBlock` default.
3. Survival: the `VegetationBlock` rule.
4. **Bone meal**: valid always, success always. Effect: when `amount < 4`: `setBlock(pos, amount + 1, flags 2)`; otherwise `popResource(level, pos, new ItemStack(thisBlock))`.
5. Rotate and mirror act on `facing`.

### 10.5 `bush`, `red_shrub` (`BushBlock`)

Survival `VegetationBlock`; shape `column(16, 0, 13)`; bone meal the neighbour spreader of 2.2. Registry: `replaceable`, `noCollision`, `instabreak`, `ignitedByLava`.

### 10.6 Dry vegetation

`DryVegetationBlock` (`dead_bush`): `mayPlaceOn(below)` = below in `supports_dry_vegetation` (`#sand`, `#terracotta`, `#supports_vegetation` as shipped); shape `column(12, 0, 13)`; no bone meal.

`ShortDryGrassBlock` (`short_dry_grass`, extends `DryVegetationBlock implements BonemealableBlock`): shape `column(12, 0, 10)`, offset XYZ. Bone meal valid always, success always, effect `setBlockAndUpdate(pos, tall_dry_grass default)` (flags 3): it grows **in place** into `tall_dry_grass` (a single block).

`TallDryGrassBlock` (`tall_dry_grass`): shape `column(14, 0, 16)`, offset XYZ. Bone meal: valid when `hasSpreadableNeighbourPos(level, pos, short_dry_grass default state)` (a horizontal neighbour is air and `short_dry_grass` can survive there, 29b-1 section 5.4 helper with that state); success always; effect `findSpreadableNeighbourPos(level, pos, short_dry_grass default)` then `setBlockAndUpdate(thatPos, short_dry_grass default)`: it **spreads short dry grass** to one random neighbour, the tall grass itself stays.

### 10.7 `firefly_bush` (`FireflyBushBlock extends VegetationBlock implements BonemealableBlock`)

No properties; registry light 2 (24), `noCollision`, `instabreak`, sound `SWEET_BERRY_BUSH`. Survival: the `VegetationBlock` rule. Bone meal: valid when `hasSpreadableNeighbourPos(level, pos, state)`, success always, effect: the neighbour spreader with the block's own default state (`setBlockAndUpdate`, flags 3), as 2.2. Client behaviour: 15.

## 11. Sea pickle and lily pad

### 11.1 `sea_pickle` (`SeaPickleBlock extends VegetationBlock implements SimpleWaterloggedBlock, BonemealableBlock`)

Properties `pickles` (1 to 4, default 1) and `waterlogged` (default **true**). Light level: 0 when dead (`isDead(state)` = `!waterlogged`), else `3 + 3 * pickles` (read in the registration lambda). Shapes: `column(4, 0, 6)` for 1, `column(10, 0, 6)` for 2, `column(12, 0, 6)` for 3, `column(12, 0, 7)` for 4. `isPathfindable` false.

1. **`mayPlaceOn(below)`**: the below block's collision shape has a **non-empty** face toward UP, **or** `below.isFaceSturdy(level, belowPos, UP)`. `canSurvive` = that rule on the block below (it replaces the vegetation tag rule).
2. **Placement**: when the state at the clicked position is this block: that state with `pickles = min(4, pickles + 1)` (all else kept). Otherwise the default state with `waterlogged` = `FluidState.is(Fluids.WATER)` at the clicked position (a water **source**, 2.3).
3. **`canBeReplaced(state, context)`**: true when `!isSecondaryUseActive()`, the item in hand is this block's item and `pickles < 4`; otherwise the default.
4. **Shape update** (SU): when `!canSurvive` the result is air. When `waterlogged` a water tick is scheduled. Then the `VegetationBlock` update. The fluid state is the water source when waterlogged, else the default.
5. **Bone meal**: valid when the pickle is **not dead** (waterlogged) and the block below is in tag `coral_blocks`; success always. Effect (the growth of a pickle patch), with `pos` the clicked pickle and the level's random:
   1. The scanned cells are the columns of this table (relative to `pos`), each taken at the two heights `y - 1` and `y`: x offset -2: z offset 0; x -1: z -1 to 1; x 0: z -2 to 2; x +1: z -1 to 1; x +2: z 0. Order: x ascending, then z ascending, then the lower height before the upper. Let `c` be the cell.
   2. When `c` equals `pos`: skip (no draw). Otherwise draw `nextInt(6)`; only when it is 0 **and** the state at `c` is block `water` (any level) **and** the state below `c` is in `coral_blocks`: draw one `nextInt(4)` and use that draw plus 1 as the pickle count: `setBlockAndUpdate(c, sea_pickle default state with pickles = draw + 1)` (the default has waterlogged true; flags 3). There is exactly one `nextInt(4)` draw per placed pickle.
   3. After the scan: `setBlock(pos, state with pickles = 4, flags 2)`.
   There are 25 cells that draw `nextInt(6)` (13 columns of 2 cells, minus `pos`), plus one `nextInt(4)` per placed pickle.

### 11.2 `lily_pad` (`LilyPadBlock extends VegetationBlock`)

No properties; shape `column(14, 0, 1.5)`. `mayPlaceOn(below)`: (the fluid at `below` is in fluid tag `supports_lily_pad` (still `water` as shipped) **or** the state `below` is in block tag `supports_lily_pad` (`ice`, `frosted_ice`)) **and** the fluid at the lily pad's own position is `Fluids.EMPTY` (no water in the cell itself). **Entity inside** (EV): on a server level, when the entity is an `AbstractBoat`: `destroyBlock(pos, drops = true, entity)`. Placement on water (`PlaceOnWaterBlockItem`) is 25.

## 12. Dripleaf

### 12.1 `big_dripleaf` (`BigDripleafBlock extends HorizontalDirectionalBlock implements SimpleWaterloggedBlock, BonemealableBlock`)

Properties `facing` (default NORTH), `waterlogged` (default false), `tilt` (`Tilt`: `none`, `unstable`, `partial`, `full`; `causesVibration`: none true, unstable false, partial true, full true; default `none`). Collision shape by tilt: `none` and `unstable` `column(16, 11, 15)` (box x 0 to 16, y 11 to 15, z 0 to 16), `partial` `column(16, 11, 13)`, `full` empty. The selection shape is the union of that leaf shape with a stem box `column(6, 0, 13)` moved by (0, 0, 0.25) and then rotated by `facing` (`Shapes.rotateHorizontal`, 24).

Constants: `NO_TICK` -1; delays until the next tilt step (`DELAY_UNTIL_NEXT_TILT_STATE`): `unstable` 10 ticks, `partial` 10 ticks, `full` 100 ticks, `none` -1 (no tick). Maximum generation height 5 (`MAX_GEN_HEIGHT`, used by 12.3).

1. **Survival** `canSurvive`: the state below is `big_dripleaf`, `big_dripleaf_stem`, or in tag `supports_big_dripleaf`.
2. **Placement**: the below state is `big_dripleaf` or `big_dripleaf_stem`: `facing` = that state's `facing`; else `facing` = `opposite(placer horizontal direction)`; `waterlogged` = the fluid at the clicked position `isSourceOfType(Fluids.WATER)`.
3. **Shape update** (SU): when the changed direction is DOWN and `!canSurvive`: air. When `waterlogged`: a water tick. When the changed direction is UP and the neighbour is `big_dripleaf`: the result is a `big_dripleaf_stem` with the **same properties** as this state (`Block.withPropertiesOf`: `facing` and `waterlogged` carry over; the stem has no `tilt`). Otherwise the default.
4. **`canGrowInto(level, pos)`** = `pos` is inside the build height and the state there is air, block `water` (any level) or `small_dripleaf` (`canReplace`). `canPlaceAt` is the same test.
5. **`place(level, pos, fluidState, facing)`**: `setBlockAndUpdate(pos, big_dripleaf default with waterlogged = fluidState.isSourceOfType(Fluids.WATER) and facing)` (flags 3).
6. **Bone meal**: valid when `canGrowInto(pos.above())`; success always. Effect: when `canPlaceAt(pos.above())`: `facing` = this state's facing; `BigDripleafStemBlock.place(level, pos, state.getFluidState(), facing)` (this block becomes a stem) then `BigDripleafBlock.place(level, pos.above(), level.getBlockState(pos.above()).getFluidState(), facing)` (a new head above).
7. **Tilt (EV and ticks)**, server only:
   1. `entityInside`: on a client nothing. When `tilt == none` and `canEntityTilt(pos, entity)` and `!level.hasNeighborSignal(pos)`: `setTiltAndScheduleTick(state, level, pos, unstable, no sound)`. `canEntityTilt` = the entity is on the ground **and** `entity.y > (float)pos.y + 0.6875f` (the float sum converted to double, compared with a strict greater).
   2. `setTiltAndScheduleTick(state, level, pos, tilt, sound)`: `setTilt` (below); when `sound` is not none, `playTiltSound`; then `delay` = the table above for `tilt`; when `delay != -1`: `level.scheduleTick(pos, thisBlock, delay)`.
   3. `setTilt(state, level, pos, tilt)`: remember the old tilt; `setBlock(pos, state with tilt, flags 2)`; when `tilt.causesVibration()` and `tilt != old`: game event `BLOCK_CHANGE` at `pos` (no entity).
   4. `resetTilt(state, level, pos)`: `setTilt(.., none)`; when the **given** state's tilt was not `none`: play `BIG_DRIPLEAF_TILT_UP`.
   5. `playTiltSound(level, pos, sound)`: `pitch = Mth.randomBetween(level.random, 0.8, 1.2)`, `level.playSound(null, pos, sound, BLOCKS, 1.0, pitch)`.
   6. **`tick`**: when `level.hasNeighborSignal(pos)`: `resetTilt` and stop. Otherwise by the current tilt: `unstable` to `partial` (sound `BIG_DRIPLEAF_TILT_DOWN`); `partial` to `full` (sound `BIG_DRIPLEAF_TILT_DOWN`); `full`: `resetTilt` (back to `none` with the tilt-up sound); `none`: nothing. The delays above give the sequence: stand (unstable, 10 ticks), partial (10 ticks), full (100 ticks, no collision), reset.
   7. **Neighbour change**: when the cell receives a redstone signal (`level.hasNeighborSignal(pos)`), the tilt is reset to none.
   8. **`onProjectileHit`**: `setTiltAndScheduleTick(state, level, hitPos, full, BIG_DRIPLEAF_TILT_DOWN)`: a projectile makes the leaf drop at once and reset 100 ticks later.

### 12.2 `big_dripleaf_stem` (`BigDripleafStemBlock`)

Properties `facing`, `waterlogged`. Collision: none (24). Selection shape `column(6, 0, 16)` moved by (0, 0, 0.25) and rotated by `facing`.

1. **Survival**: the state below is `big_dripleaf_stem` or in `supports_big_dripleaf`, **and** the state above is `big_dripleaf_stem` or `big_dripleaf`.
2. **Shape update** (SU): when the changed direction is DOWN or UP and `!canSurvive`: schedule a block tick (delay 1); when `waterlogged` a water tick; then the default. `tick`: `destroyBlock(pos, drops)` when `!canSurvive`.
3. **`place(level, pos, fluidState, facing)`**: `setBlockAndUpdate(pos, stem default with waterlogged = fluidState.isSourceOfType(Fluids.WATER) and facing)`.
4. **Bone meal**: `top` = the top connected block: from `pos` move UP while the state is `big_dripleaf_stem`, the first other cell must be `big_dripleaf` (3.2 step 11 rule). Valid when found and `canPlaceAt(top.above())`; success always. Effect: with `top` and `above = top.above()` and `facing` = this state's facing: `BigDripleafStemBlock.place(level, top, level.getFluidState(top), facing)` (the head becomes a stem), `BigDripleafBlock.place(level, above, level.getBlockState(above).getFluidState(), facing)` (a new head). The effect grows the **whole stalk's top**, whichever stem is clicked.
5. `getCloneItemStack`: the `big_dripleaf` item.

### 12.3 `placeWithRandomHeight(level, random, pos, facing)`

Used by small dripleaf bone meal (12.4) and by the world generation features (35). Steps:

1. `n = Mth.nextInt(random, 2, 5)` (one draw, 2 to 5).
2. `i = 0`; `m` starts at `pos`; while `i < n` and `canPlaceAt(level, m)`: `i = i + 1`, `m = m + UP`.
3. `topY = pos.y + i - 1`; `m.y = pos.y`.
4. While `m.y < topY`: `BigDripleafStemBlock.place(level, m, level.getFluidState(m), facing)`; `m = m + UP`.
5. `BigDripleafBlock.place(level, m, level.getFluidState(m), facing)`.

So `i` cells are used, `i - 1` stems under one head; `i` can be less than `n` when something blocks the column, and 0 only when `pos` itself cannot be replaced (then the head is placed at `pos`).

### 12.4 `small_dripleaf` (`SmallDripleafBlock extends DoublePlantBlock implements SimpleWaterloggedBlock, BonemealableBlock`)

Properties `half` (default lower), `waterlogged` (default false), `facing` (default NORTH). Shape `column(12, 0, 13)`, max vertical offset 0.1 (offset XYZ, 24).

1. **`mayPlaceOn(state, level, belowPos)`**: the supporting state is in tag `supports_small_dripleaf` (`clay`, `moss_block`), **or** both the fluid at `belowPos.above()` (the lower half's own cell) `isSourceOfType(Fluids.WATER)` and the supporting state is in `supports_vegetation` (the inherited rule). In words: dirt-like blocks need a water source in the plant's own cell; clay and moss need nothing.
2. **Survival**: the upper half uses the `DoublePlantBlock` rule (below is the lower half); the lower half: `mayPlaceOn` of the block below.
3. **Placement**: the `DoublePlantBlock` placement, with `facing = opposite(placer horizontal direction)` and `waterlogged` copied (`isWaterAt(pos)`).
4. **`setPlacedBy`**: on a server only: `setBlockAndUpdate(pos.above(), default with half upper, facing from the placed state, waterlogged copied)`.
5. Shape update: when `waterlogged` a water tick, then the `DoublePlantBlock` update (9.1 step 4).
6. **Bone meal**: valid always, success always. Effect: when this state is the **lower** half: `above = pos.above()`; `setBlock(above, the legacy block state of the fluid at above (water block when it is water, air otherwise), flags 18)`; then `BigDripleafBlock.placeWithRandomHeight(level, random, pos, state.facing)` (12.3): a big dripleaf column replaces the small one, starting at the lower half's position. When this state is the **upper** half: the same bone meal on the lower half's position and state.

## 13. Hanging and root blocks

### 13.1 `hanging_roots` (`HangingRootsBlock`)

Property `waterlogged` (default false). Shape `column(12, 10, 16)`, offset XZ. Registry: `replaceable`, `noCollision`, `instabreak`, `ignitedByLava`.

1. **Survival**: `isFaceSturdy(level, pos.above(), DOWN)` of the state above.
2. **Shape update** (SU): when the changed direction is UP and `!canSurvive`: air. When `waterlogged` a water tick. Then the default.
3. **Placement**: the default state with `waterlogged` = `FluidState.is(Fluids.WATER)` (source) at the clicked position.
4. No bone meal on the block itself; `rooted_dirt` bone meal writes `hanging_roots` (29b-2 section 10.3).

### 13.2 `spore_blossom` (`SporeBlossomBlock`)

No properties; shape `column(12, 13, 16)`. **Survival**: `Block.canSupportCenter(level, pos.above(), DOWN)` (24 part 1 section 6.5) **and** `!level.isWaterAt(pos)`. **Shape update** (SU): when the changed direction is UP and `!canSurvive`: air; otherwise the default. Client: particles (15).

### 13.3 `pale_hanging_moss` (`HangingMossBlock implements BonemealableBlock`)

Property `tip` (boolean, default **true**). Shapes: the base `column(14, 0, 16)`, the tip `column(14, 2, 16)`. Registry: `noCollision`, sound `MOSS_CARPET`, `ignitedByLava`, `pushReaction(POPPED)`; `propagatesSkylightDown` is true.

1. **`canStayAtPosition(level, pos)`**: the state above `A`: `MultifaceBlock.canAttachTo(level, UP, above, A)` (the block above has a full bottom face by support or collision shape, 35 part 4 section 8.1) **or** `A` is `pale_hanging_moss`. `canSurvive` is this test.
2. **Shape update** (SU): when `!canStayAtPosition` schedule a block tick (delay 1). The result is the state with `tip = !(the state below is pale_hanging_moss)`, for every changed direction. `tick`: `destroyBlock(pos, drops)` when `!canStayAtPosition`.
3. **`getTip(level, pos)`**: starting at `pos` move DOWN while the state is `pale_hanging_moss`; return the last moss position (the cell above the first non-moss cell).
4. **Bone meal**: valid when the cell below `getTip(level, pos)` is air (`canGrowInto`) and inside the build height; success always. Effect: when the cell below the tip is air: `setBlockAndUpdate(thatCell, the given state with tip = true)` (flags 3); the old tip becomes a non-tip by rule 2.
5. Client: sound (15).

### 13.4 `mangrove_roots` (`MangroveRootsBlock implements SimpleWaterloggedBlock`) and `muddy_mangrove_roots`

`mangrove_roots` has the property `waterlogged` (default false) and no other behaviour: placement sets `waterlogged` = `FluidState.is(Fluids.WATER)` (source) at the clicked position; the shape update schedules a water tick when waterlogged; the fluid state is the water source when waterlogged. `skipRendering(state, neighbour, dir)` is true when the neighbour is `mangrove_roots` and the direction's axis is Y (client face culling). `muddy_mangrove_roots` is a plain block (24). The roots have no `isSuffocating` exemption beyond the registry flags (24 part 8).

The hanging growth of the `mangrove_propagule` and the roots' role as support (`supports_hanging_mangrove_propagule`) are 29b-2 section 11.1.

## 14. The rules in one table each

### 14.1 Can-survive (`canSurvive`) and shape-update removal

All `VegetationBlock` users remove themselves by the **shape update** (instantly, flag-less) when the ground test fails; the other blocks schedule a tick (delay 1) from the shape update and are destroyed by `tick`.

| Block | `canSurvive` | Removal path |
|---|---|---|
| `bush`, `red_shrub`, 14 flowers, `eyeblossom`s, `firefly_bush`, `short_grass`, `fern`, `seagrass` (ground part), `cactus_flower` base | below in `supports_vegetation`; seagrass additionally needs `isFaceSturdy(UP)` and not `cannot_support_seagrass` in place of the tag; cactus flower uses the override tag or a CENTER-sturdy top face | shape update gives air |
| `wither_rose` | below in `supports_wither_rose` | shape update |
| `dead_bush`, `short_dry_grass`, `tall_dry_grass` | below in `supports_dry_vegetation` | shape update |
| `lily_pad` | 11.2 | shape update |
| `sea_pickle` | the collision top face is non-empty or the top face is sturdy | shape update (air) |
| `tall_grass`, `large_fern`, `pitcher_plant` | lower: `supports_vegetation`; upper: below is the lower half | shape update (9.1) |
| `tall_seagrass` | lower: seagrass ground rule and full water in the cell; upper: below is the lower half | shape update |
| `sunflower`, `lilac`, `rose_bush`, `peony` | lower: `supports_vegetation`; upper: lower half below | shape update |
| `small_dripleaf` | 12.4 | shape update |
| `pink_petals`, `wildflowers` | `supports_vegetation` | shape update |
| `sugar_cane` | 4 step 1 | tick (delay 1) |
| `cactus` | 5.1 step 1 | tick |
| `bamboo` | below in `supports_bamboo` | tick |
| `bamboo_sapling` | below in `supports_bamboo` | shape update gives air |
| `vine` | at least one face after `getUpdatedState` | shape update gives air |
| `chorus_plant` | 8.1 step 4 | tick |
| `chorus_flower` | 8.2 step 1 | tick |
| `kelp`, `kelp_plant` | 3.2 step 1 with `canAttachTo` = not `magma_block` | tick |
| `weeping_vines`, `weeping_vines_plant`, `twisting_vines`, `twisting_vines_plant`, `cave_vines`, `cave_vines_plant` | 3.2 step 1 | tick |
| `big_dripleaf` | below is dripleaf, stem or `supports_big_dripleaf` | shape update (air when DOWN) |
| `big_dripleaf_stem` | 12.2 step 1 | tick |
| `hanging_roots` | the block above has a sturdy bottom face | shape update (UP only) |
| `spore_blossom` | 13.2 | shape update (UP only) |
| `pale_hanging_moss` | 13.3 step 1 | tick |
| `mangrove_roots`, `muddy_mangrove_roots` | none | |

### 14.2 Random ticks

| Block | Gate | Draws (in order) | Effect |
|---|---|---|---|
| kelp head | `age < 25` | `nextDouble < 0.14` | grow one block (3.2 step 6) |
| weeping, twisting head | `age < 25` | `nextDouble < 0.1` | grow into air |
| cave vines head | `age < 25` | `nextDouble < 0.1`, then `nextFloat < 0.11` (berries of the new head) | grow into air |
| sugar cane | cell above is air, column height below 3 | none | age + 1, or a new cane at age 15 (flags 260 on the age) |
| cactus | cell above is air | `nextDouble` only at age 8 | flower, new cactus, or age + 1 (5.1) |
| bamboo stalk | `stage == 0` | `nextInt(3) == 0`; then in `growBamboo` `nextFloat` when `h >= 11` | grow a stalk |
| bamboo sapling | none | `nextInt(3) == 0` | the first stalk |
| vine | game rule `spread_vines` | `nextInt(4)`, `nextInt(6)`, then the case draws (24 part 4 6.7) | spread |
| chorus flower | `age < 5`, above air and in height | `nextInt(5 or 4)` (when `h >= 2`), `nextInt(4)`, `nextInt(4)` per branch | grow, branch, die |
| open or closed eyeblossom | none | `nextIntBetweenInclusive` per neighbour | open or close with the timeline |

### 14.3 Bone meal

| Block | Valid | Success | Effect |
|---|---|---|---|
| kelp, weeping vines, twisting vines (head) | next cell grows and in height | always | 1 (kelp) or `NetherVines` count (3.4) new heads; ages increase by 1 each, max 25 |
| the bodies of those | a head exists above or below and the cell beyond it is free | always | the head's effect |
| cave vines head and body | `berries` false | always | `berries` true, flags 2, no growth |
| `bamboo` | 6.2 step 6 | always | 1 or 2 stalks |
| `bamboo_sapling` | above is air and in height | always | the first stalk |
| `seagrass` | `pos.above()` is block `water` | always | `tall_seagrass` |
| `short_grass`, `fern` | the tall plant can survive, above air and in height | always | `tall_grass` / `large_fern` (flags 2) |
| the four `TallFlowerBlock`s | always | always | drops the item |
| `pink_petals`, `wildflowers` | always | always | `flower_amount + 1`, or drops the item at 4 |
| `bush`, `red_shrub`, `firefly_bush` | a horizontal neighbour is air and the plant can survive there | always | spreads one copy to a random such neighbour |
| `short_dry_grass` | always | always | becomes `tall_dry_grass` |
| `tall_dry_grass` | a horizontal neighbour can take `short_dry_grass` | always | spreads `short_dry_grass` |
| `sea_pickle` | not dead and coral block below | always | the diamond scan of 11.1 step 5 |
| `big_dripleaf` | `canGrowInto(above)` | always | stem plus head above |
| `big_dripleaf_stem` | a head exists and `canPlaceAt(head.above())` | always | stem plus head above the top |
| `small_dripleaf` | always | always | a big dripleaf column of height 2 to 5 |
| `pale_hanging_moss` | the cell below the tip is air | always | one more moss block |
| `vine`, `cactus`, `sugar_cane`, `cactus_flower`, `chorus_*`, `lily_pad`, `hanging_roots`, `spore_blossom`, `mangrove_roots`, `dead_bush`, flowers, eyeblossom, `tall_seagrass`, `tall_grass`, `large_fern`, `pitcher_plant` | not a bone meal target | | |

`isBonemealSuccess` is true for every row; the random-success blocks of 29b-1 and 29b-2 (sapling 0.45, azalea 0.45) are not in this part.

## 15. Client-side behaviour that does not change state

These are `animateTick` and similar client-only methods; the exact particle and sound registries are 42 part 6.

| Block | Behaviour (read) |
|---|---|
| `firefly_bush` | each client tick: with probability 1/30 (`nextInt(30) == 0`), when the environment attribute `audio/firefly_bush_sounds` is true at the position and the position is not below the `MOTION_BLOCKING_NO_LEAVES` height at its column (`level.getHeight(...) <= pos.y`, i.e. the block is at or above the surface), play the local sound `FIREFLY_BUSH_IDLE` (AMBIENT, volume 1, pitch 1, no distance delay). Then, when `getMaxLocalRawBrightness(pos) <= 13` and `nextDouble() <= 0.7`: add the particle `firefly` at `(x + nextDouble * 10 - 5, y + nextDouble * 5, z + nextDouble * 10 - 5)` with zero velocity (draw order: x, y, z). The attribute is the timeline track `audio/firefly_bush_sounds` (true from 12600 to 23401 ticks as shipped) |
| `spore_blossom` | each tick: the particle `falling_spore_blossom` at `(x + nextDouble, y + 0.7, z + nextDouble)`; then 14 attempts: `p = (x + Mth.nextInt(-10, 10), y - nextInt(10), z + Mth.nextInt(-10, 10))`; when the state at `p` does not have a full-block collision shape, the particle `spore_blossom_air` at `(p.x + nextDouble, p.y + nextDouble, p.z + nextDouble)` |
| `wither_rose` | three iterations: when `nextBoolean()`: the particle `smoke` at `(x + shapeCentre.x + nextDouble / 5, y + 0.5 - nextDouble, z + shapeCentre.z + nextDouble / 5)` with zero velocity (the centre of the outline shape's bounds) |
| `pale_hanging_moss` | `nextInt(500) == 0` and the block above is in `pale_oak_logs` or is `pale_oak_leaves`: sound `PALE_HANGING_MOSS_IDLE` (AMBIENT) |
| `open_eyeblossom` | `nextInt(700) == 0` and the block below is `pale_moss_block`: sound `EYEBLOSSOM_IDLE` (AMBIENT); only the open type plays it (`emitSounds`) |
| `short_dry_grass`, `tall_dry_grass` | `AmbientDesertBlockSoundsPlayer.playAmbientDryGrassSounds` (read): one `nextInt(200)` draw; when it is 0 **and** `shouldPlayDesertDryVegetationBlockSounds(pos.below())` holds: sound `DRY_GRASS` (source AMBIENT, volume 1, pitch 1) through `playPlayerSound` (the player's own position, not the block's). That check is true when the state at its argument **and** the state one below it are both in block tag `triggers_ambient_desert_dry_vegetation_block_sounds`; so the plant's block below and the block two below must be in the tag (as shipped: tag `terracotta`, `sand`, `red_sand`; DATA) |
| `dead_bush` | `playAmbientDeadBushSounds` (read): draw `nextInt(130)`; when it is 0: when the block below is `red_sand` or in tag `terracotta`, a second draw `nextInt(3)` is made and the whole call ends unless it is 0 (so 1/390 there, 1/130 elsewhere); then, when the same two-block tag check on `pos.below()` holds, the local sound `DEAD_BUSH_IDLE` (AMBIENT, volume 1, pitch 1, no distance delay) at the block position through `playLocalSound` |
| `mangrove_roots` | face culling (13.4) |

## 16. Worked examples

1. **Kelp growth.** A kelp head `K` (age 3) at (0, 10, 0) with water at (0, 11, 0), `random_tick_speed` 3. A random tick: `age < 25`, `nextDouble` = 0.10 (below 0.14): `canGrowInto` (water block) holds, so `setBlockAndUpdate((0,11,0), kelp age 4)`. The write's shape updates reach `K` with direction UP and a head above: `K` becomes `kelp_plant` (3.2 step 7). If `nextDouble` were 0.20 nothing happens.
2. **Nether vine bone meal.** A weeping vine head `H` (age 20) with air for 4 cells below. Draws: 0.99 (below 1.0, threshold 0.826, count 1), 0.70 (below 0.826, threshold 0.682, count 2), 0.90 (not below 0.682, stop): `n` = 2. Heads are written below with ages 21 and 22 (`a = min(20 + 1, 25)` then 22); `H` becomes body when its neighbour changes. Probability of `n >= 4` is 0.3176.
3. **Cave vines.** A cave vine head with air below and `random` draws 0.05 (below 0.1), 0.08 (below 0.11): a new head is written below with `age + 1` and `berries` true; the old head becomes a body with the same `berries` as it had. Clicking a berry-bearing body with an empty hand drops the glow berries of the harvest table, plays the pick sound with pitch `0.8 + 0.4 * nextFloat`, and sets `berries` false (flags 2).
4. **Sugar cane.** Cane at height 1 (age 15) on sand with water beside the sand, air above: `h = 1`, `h < 3`, age 15: a new cane above, this age 0. The column of 3 never grows: `h = 3` stops before any age change.
5. **Cactus flower.** Cactus column height 2 whose top has age 8, air above, no solid neighbour of the cell above: `h = 2`, so the chance is 0.1. A draw of 0.07 places `cactus_flower` above; a draw of 0.5 does not; either way the top becomes age 9.
6. **Bamboo column.** Sapling plus first stalk gives [none, small]. Each growth: the new stalk's `leaves` and the retrofits of the two stalks below follow 6.2 step 5. Result table (`l` leaves, `a` age): 2: [none/0, small/0]; 3: [none/0, small/0, small/0]; 4: [none/1, small/1, small/1, large/1] (the new stalk is thick because `B2` is bamboo, and the thin stalks below turn thick through the shape updates); 5: [none, none, small, large, large] all age 1; 6: [none, none, none, small, large, large]; at `h >= 11` each growth draws one `nextFloat` and a value below 0.25 ends growth (stage 1); height 16 is the maximum.
7. **Chorus flower.** A flower (age 0) on end stone with air above and air at `pos.above(2)`: `grow` is true; the flower is replaced by a plant and a new age-0 flower appears above (sound event 1033). On a plant column of height 3 standing on end stone (`endBelow`), `h = 3`: `grow = (3 <= nextInt(5))`: true for draws 3 and 4 (probability 2/5). When not growing up and `age < 4`, `n = nextInt(4) + 1` side attempts: each picks a horizontal direction; the first valid cell receives an age + 1 flower. A flower at age 4 that cannot grow up dies (event 1034).
8. **Sea pickle patch.** A pickle with 2 pickles on a living coral block in water: the 25 cells of the diamond are tested with `nextInt(6)`; each hit with water at the cell and a coral block below places a new pickle (1 to 4 pickles); the original ends with 4 pickles.
9. **Short grass.** Bone meal on `short_grass` at `p` with air above: `tall_grass` lower at `p` and upper at `p + (0, 1, 0)`, flags 2. On `fern`: `large_fern`. On `tall_grass` itself: nothing happens (not a bone meal target).
10. **Small dripleaf.** Bone meal on a small dripleaf at `y` with free water above: the upper half is replaced by water (flags 18); `placeWithRandomHeight` draws `n` = 4 (`Mth.nextInt(2, 5)`): `i` counts 4 free cells (the lower half's cell counts because small dripleaf is replaceable), so stems at `y`, `y + 1`, `y + 2` and a head at `y + 3`, all with the small dripleaf's `facing`.
11. **Big dripleaf tilt.** A player lands on a big dripleaf leaf (entity on ground, `y > leafY + 0.6875`) without redstone power: `unstable` and a tick in 10 ticks; then `partial` (sound down) and a tick in 10; then `full` (no collision, sound down) and a tick in 100; then `none` (sound up). A neighbouring redstone signal at any moment resets it at once.
12. **Pale hanging moss.** A moss stalk of 3 under a pale oak log with air below: bone meal places a fourth block below with `tip = true`; the former tip's shape update sets its `tip` false.
13. **Eyeblossom.** At 12600 day ticks a closed eyeblossom is random-ticked: the attribute is true (open), `want != false`: it becomes an open eyeblossom, sends the trail particle, and every other closed eyeblossom within 3 x 2 x 3 blocks gets a scheduled tick after `nextIntBetweenInclusive(int(5d), int(10d))` ticks for its distance `d` (a neighbour at distance 1.0 gets a delay between 5 and 10).
14. **Flower bed.** `flower_amount` 3 plus another petal item (not sneaking) gives 4; bone meal on a bed with 4 drops one item, on one with 2 sets 3.
15. **Double plant removal.** Breaking the lower half of a `lilac` with a tool: the lower half goes (the upper half's shape update, partner missing, gives air). Creative breaking of the upper half removes the lower half with flags 35 and no drops, plus level event 2001.

## 17. Validation

A test suite for this part can check, each derived from the text above:

1. Head and body engine: random tick probabilities 0.14 (kelp) and 0.1 (the others), no draw at age 25, `age + 1` on growth, conversion of the old head to a body through the shape update, and conversion of the top body to a head with `nextInt(25)` age when the cell beyond is removed.
2. Survival of heads and bodies: anchored by the sturdy face toward the plant or by the same family; the tick (delay 1) destroys with drops; kelp refuses `magma_block` and requires a full water cell at placement.
3. `NetherVines` count: the draw loop, `P(n >= k) = 0.826^(k(k-1)/2)`, and the age ladder of bone meal.
4. Cave vines: `berries` 0.11 on growth, copy through conversions, bone meal sets `berries` only, harvest result (PASS without berries, SUCCESS with), sound pitch range 0.8 to 1.2, flags 2.
5. Sugar cane: `h < 3`, age 15 growth, no growth when the column is 3, survival needs the soil block's horizontal neighbour water or `frosted_ice`; flags 260 on age writes.
6. Cactus: age ladder, flower only at age 8 with chances 0.1 or 0.25 (inclusive compare), new cactus only at age 15 and `h < 3`, `h == 3` and age 15 returns before any change, survival (solid or lava neighbour kills), entity damage 1.0.
7. Bamboo: `nextInt(3)`, brightness 9 at the cell above, `h < 16`, the leaves ladder and the retrofit of two lower stalks, `age`, `stage` (`nextFloat` only at `h >= 11`, 0.25, forced at `h == 15`), bone meal `1 + nextInt(2)`, the sapling's conversion by shape update.
8. Chorus flower and plant: survival rules, the random tick order of draws and tests, `allNeighborsEmpty` ignoring up and down, events 1033 and 1034, projectile break.
9. Seagrass and double plants: partner-cell shape updates, creative removal with flags 35, `placeAt`, `getSeed` shared offset, tall seagrass needs full water in both cells.
10. Flowers: `FlowerBlock` is not a bone meal target; `bush` and `red_shrub` spread; wither rose effect `wither` 40 ticks; eyeblossom change, neighbour delays `nextIntBetweenInclusive(int(5d), int(10d))` and the two sound variants.
11. Flower beds: amount ladder and drop at 4, placement facing, replacement rules.
12. Dry vegetation: `short_dry_grass` becomes `tall_dry_grass`, `tall_dry_grass` spreads `short_dry_grass`.
13. Sea pickle: placement, light `3 + 3 * pickles` (0 when dead), diamond scan of 25 cells with the exact draw order, bone meal validity (not dead, coral block below).
14. Lily pad: support by water source or `ice` with an empty fluid at its own cell; destroyed by boats.
15. Dripleaf: tilt delays 10, 10, 100; entity landing rule; redstone reset; stem and head conversion by shape update; `placeWithRandomHeight`; bone meal of all three blocks; survival of stem and head; small dripleaf support rule.
16. Hanging blocks: hanging roots survival, spore blossom survival (center support and no water), pale hanging moss tip handling and growth, mangrove roots waterlogging.
17. Vines: crowding box and at most 4, the draw orders and the `up` re-check quirk (7).

## 18. Open questions

0. Registry rows of 1.2 other than `golden_dandelion`, `pitcher_plant` and `firefly_bush` were not re-resolved when this part was corrected; the `bush` / `red_shrub` and `pink_petals` / `wildflowers` shape heights in particular are unverified. The members of tag `terracotta` were read (17 entries), listed only as an example in 2.4.

1. `BonemealSource.MOB` (bees growing plants) was not read (`Bee.attractsBees` is now read, 10.3 step 5). The bone meal rules above are written for the player source and the classes of this part make no test of the source. (Part 1 Open question 7 is the same item.)
2. `Direction.Plane.shuffledCopy` (used by the spreader helper behind `bush`, `red_shrub`, `firefly_bush`, `tall_dry_grass`) was only read as "a random permutation of the horizontal list drawn from the level random" in 29b-1 section 5.4; its permutation algorithm and its draw count were not read here, so the neighbour chosen for a given random state is not specified.
3. 29b-1 section 5.4 says the `BushBlock` bone meal default covers "flowers, bushes". In this version `FlowerBlock`, `WitherRoseBlock` and `EyeblossomBlock` extend `VegetationBlock`, not `BushBlock`; only the registry names `bush` and `red_shrub` are `BushBlock`. That sentence of part 1 should be corrected by its owner.
4. The `up` face of a vine is re-checked with `isAcceptableNeighbour(level, pos.above(), DOWN)`, which tests the **top** face of the block above, while placement and the random tick pass UP and test its bottom face. The bytecode was read twice and is as stated; whether the vanilla behaviour is intentional is unknown, and an implementation must copy it.
5. The vine crowding box (7): `BoxBlockMatcher` delegates to `BlockScanUtils.findBlocks`, whose section-based scan clamps to the maximum corner (inclusive); the innermost loop of `findBlocksInSection` and `OrderedBlockMatcher` were not read, so the 9 x 3 x 9 volume is still partly inferred.
6. The head random tick writes into the cell beyond the head without a build-height test (only bone meal tests it). What `setBlockAndUpdate` does at a position outside the world is 29 section 2 and was not re-read.
7. Closed: `AmbientDesertBlockSoundsPlayer` was read for dry grass and dead bush (section 15). Not read: the sand variant (`playAmbientSandSounds`, not used by a block of this part) and which client method calls these with which random source (42 part 6).
8. Loot tables of every block here (vine, glow berry harvest, plant drops, shears, silk touch, fortune) are DATA and were not read; `harvest_cave_vine` is a `BuiltInLootTables` key (26).
9. The default replacement rules (`Block.canBeReplaced(state, context)`) used when a tall plant or flower bed is placed over a replaceable block belong to 29 section 9 and were not re-read.
10. The dependence of `Level.hasNeighborSignal` (big dripleaf) on the redstone model is 30; it was assumed to be "any signal from any neighbour" and not read here.
11. The interpolation of boolean timeline keyframes (`eyeblossom_open`, `firefly_bush_sounds`) between 12600 and 23401 ticks and the sampling position of `EnvironmentAttributeSystem.getValue(attribute, pos)` are 33 section 2 and 23; this part used only the keyframe values read from `day.json`.
12. The exact vanilla damage and sound ids for the cactus (`damageSources.cactus`) and the sound events of the plants are registry data (24, 25); only their use was read.
13. The third worked example of 3.2.1 (a head that grows in the tick of its support's removal and keeps a converted, unsupported body piece) is derived from the code read (`tickBlock` drops a tick whose block no longer matches; the classes of 3.2 have no `onPlace`; the conversion comes from a shape update) and was not observed; which packet handlers queue to the packet phase (read only for `handlePlayerAction`, `handleUseItemOn`; `handleChatCommand` queues with `MinecraftServer.execute`) and the phase of every other source of a removal were not enumerated. Console commands run in the connection step after the level ticks (row 5; read in `DedicatedServer.tickConnection` and `handleConsoleInputs`) and `rcon` commands are queued with `executeBlocking` like a chat command (read in `DedicatedServer.runCommand`); the commands of the management protocol (`net.minecraft.server.jsonrpc`) were not read, and tasks queued with `MinecraftServer.execute` also run whenever the server thread blocks in `managedBlock` outside `waitUntilNextTick` (read in `reloadResources`; the phase of such a nested run was not enumerated). The tables of 3.2.1 hold for any source once its phase is known.
