# 29b. Falling blocks, growth, fire and similar block behaviours, part 5: fungi, moss and weathering copper

| | |
|---|---|
| Covers | `MushroomBlock` (brown and red mushroom: random spread, light and support rules, bone meal to the huge mushroom), `HugeMushroomBlock` (face connection state), `ShelfMushroomBlock`, `NetherFungusBlock` (crimson and warped fungus), `NetherRootsBlock` and `NetherSproutsBlock` (no bone meal), `BonemealableFeaturePlacerBlock` (moss block, pale moss block), the `MossyCarpetBlock` bone meal entry points, the `ChangeOverTimeBlock` oxidation engine, `WeatheringCopper` (state ladder, next/previous/first, chance modifier), `WeatheringCopperCollection` and the table of the 15 copper families, the per-class oxidation hooks (door, chest, golem statue and the rest), the wax-on map (`HoneycombItem`), scrape and wax-off (`BlockTransformer` engine and `axe` data), the honeycomb dispenser, and lightning de-oxidation (`LightningBolt`, `LightningRodBlock`) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data file `data/minecraft/block_transformer/axe.json`, with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS11 (GAP-10b of `../design/README.md` Part 5), part 5 |
| Data versus code | The tags (`overrides_mushroom_light_requirement`, `supports_crimson_fungus`, `supports_warped_fungus`, `supports_crimson_roots`, `supports_warped_roots`, `supports_nether_sprouts`, `axes`), the configured features (`huge_red_mushroom`, `huge_brown_mushroom`, `crimson_fungus_planted`, `warped_fungus_planted`, `moss_patch_bonemeal`, `pale_moss_patch_bonemeal`) and `axe.json` are DATA, read from the extracted packs (22, 23, 35). This document specifies the engines and the code-defined constants. |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each is repeated in the Open questions. The record notation, probability notation (`1/N`, `P(p)`, `U(a,b)`) and the predicate vocabulary are those of `29b-falling-growth-fire-1-model-gravity-bonemeal.md` section 2 (called "29b-1" below); the bone meal item flow is 29b-1 section 5.3. Block names are registry names (24).

## 0. Reader's map

| Question | Section |
|---|---|
| Mushroom spread, survival, bone meal | 1 |
| Huge mushroom block faces, shelf mushroom | 2 |
| Nether fungus, roots, sprouts, moss blocks | 3 |
| The oxidation engine (`changeOverTime`) | 4 |
| The ladder, the families, the id table | 5 |
| Per-class hooks (door, chest, statue and others) | 6 |
| Wax on, scrape, wax off, dispenser | 7 |
| Lightning | 8 |
| Worked examples, validation, open questions | 9, 10, 11 |

## 1. `MushroomBlock` (`brown_mushroom`, `red_mushroom`)

Class `MushroomBlock extends VegetationBlock`, implements `BonemealableBlock`. Constants read: `SEARCH_RADIUS` 4, `MAX_NEIGHBORS_TO_GROW` 4. Shape: `Block.column(6, 0, 6)` (a 6 x 6 footprint, height 6). Field `feature`: the huge mushroom feature key: `TreeFeatures.HUGE_BROWN_MUSHROOM` for brown, `TreeFeatures.HUGE_RED_MUSHROOM` for red (read from the constructor lambdas; 24 part 1 gives the registry rows). Brown is the one with light emission 1 (24).

### 1.1 Survival

| Rule | Value |
|---|---|
| `mayPlaceOn(below)` | the block below `isSolidRender()` (a full opaque cube, 24 part 1 §6) |
| `canSurvive(state, level, pos)` | true when the state below is in block tag `overrides_mushroom_light_requirement` (any light level); else true when `rawBrightness(pos, 0) < 13` AND `mayPlaceOn(below)` |

`rawBrightness(pos, 0)` is the 29b-1 §2.5 predicate with darken 0 (block light and sky light combined as `max`). Note the inverted light rule: mushrooms need it dark (below 13), unless the support is in the override tag.

### 1.2 Random tick (spread)

Trigger RT, flags 2 (clients only; no neighbour update).

1. One draw `nextInt(25)`; continue only when it is 0 (chance 1/25). Otherwise stop with no further draws.
2. `canSpread`: count the blocks equal to this block (the same block, any state; the plant has no properties) in the box from (x-4, y-1, z-4) to (x+4, y+1, z+4) around `pos`. The count includes the mushroom itself. Spread is allowed when the count is at most 4 (the engine tests `not atLeastMatched(5)`). When it fails, stop.
3. Draw a first target: `T = pos + (nextInt(3) - 1, nextInt(2) - nextInt(2), nextInt(3) - 1)`. The draws are made in the order dx, dy-first, dy-second, dz (four draws; the y offset is in -1..1 with the triangular weights 1:2:1).
4. Repeat 4 times: if `isEmptyBlock(T)` (air) and this block's state `canSurvive(level, T)`, then the walking position `pos` becomes `T`. Then, whether or not it moved, draw a new target `T = pos + (...)` with the same four draws as step 3 (from the possibly moved `pos`). So the loop makes 4 x 4 = 16 draws.
5. After the loop: if `isEmptyBlock(T)` and the state `canSurvive(T)`, set `T` to the original state of the mushroom with flags 2.

The state written is the state of the ticking block (it has no properties). The survival check uses the light rule of 1.1 at the target, so a spread into a bright cell fails silently.

### 1.3 Bone meal (to the huge mushroom)

| Method | Rule |
|---|---|
| `isValidBonemealTarget` | only on a server level. Looks up the configured feature `feature` in the feature registry; valid when it exists, is an `AbstractHugeMushroomFeature`, and `isInsideBuildHeight(pos.above(4 + foliageRadius))`, where `foliageRadius()` is a value of the huge mushroom feature's configuration (data, 35 part 4 gives the two features) |
| `isBonemealSuccess` | one `nextFloat()` draw; success when `< 0.4` (40%) |
| `performBonemeal` | `growMushroom(level, pos, state, random)` |

`growMushroom`: when the feature is absent return false (nothing changes). Otherwise remove the mushroom block with `removeBlock(pos, false)`, then run the feature's `place` at `pos` with the chunk generator of the level and the random source; on success return true. On failure restore the original state with `setBlockAndUpdate(pos, state)` and return false. The huge mushroom shape is worldgen (35 part 4); the return value of `performBonemeal` is ignored by the item flow (29b-1 §5.3), so a failed growth still consumes the bone meal item when the 40% test passed or not (the stack shrinks on every valid target).

## 2. `HugeMushroomBlock` and `ShelfMushroomBlock`

### 2.1 `HugeMushroomBlock` (`brown_mushroom_block`, `red_mushroom_block`, `mushroom_stem`)

Properties: six booleans `north`, `east`, `south`, `west`, `up`, `down`; default state all true (64 states, 24 part 4 §3). A true face means the cap or stem texture shows on that face; false means the inner pore texture (assets are data, 12/14).

| Trigger | Rule |
|---|---|
| Placement state | each face is true when the block in that direction is NOT the same block as this one, false when it is (looked up from the placement position; `BlockState.is(this)`) |
| SU | when the neighbour state in the direction of the update is the same block, the face of that direction is set false; otherwise the state is returned by the generic shape update unchanged (a face is never set back to true by a shape update) |
| Rotation | the face property of the rotated direction takes the value of the original direction, for the six directions (up and down map to themselves under the horizontal rotations) |
| Mirror | the same permutation with the mirror applied to the direction (the `mirror` body was read to exist, its use of `Mirror.mirror` for the horizontal directions is (inferred)) |

Worldgen of huge mushrooms writes the face states directly (35 part 4); the placement rule above applies only to the block item and commands.

### 2.2 `ShelfMushroomBlock` (`shelf_mushroom`)

Registry row: 24 part 4 §6.24 (properties `facing`, `age` 0..1, default north and age 0). Rules read:

| Item | Value |
|---|---|
| Survival | the block on the side opposite to `facing` (at `pos.relative(facing.getOpposite())`) has a sturdy face towards `facing` (`isFaceSturdy(level, thatPos, facing)`) |
| Placement | the first of the player's nearest looking directions (`getNearestLookingDirections`, in order) that is horizontal and gives a state (with `facing` = the opposite of that direction) which `canSurvive`; if none, no placement (null) |
| SU | when the update direction is the opposite of `facing` and the state cannot survive, the result is air; otherwise the horizontal-directional default |
| Bone meal | valid while `age < 1` (age 0 only); the test always succeeds; `performBonemeal` sets `age + 1` with flags 2. Type default `GROWER`. The item flow of 29b-1 §5.3 applies |
| Pathfinding | not pathfindable (`isPathfindable` false) |
| `bounceOn(level, state, pos, entity, speed)` | plays the sound `shelf_mushroom_bounce` (BLOCKS, volume 1, pitch 1, no source entity) unless the entity is an item entity or a primed TNT; the bounce velocity itself is applied by the entity code using the registry restitution 0.75 (24 part 4, 41 §3) |
| Shape | two boxes depending on `age`, rotated per facing; the geometry was read as arithmetic in the block's shape lambda and is given in 24 part 4 §6.24 (not repeated) |

## 3. Nether fungi, roots, sprouts and the moss blocks

### 3.1 `NetherFungusBlock` (`crimson_fungus`, `warped_fungus`)

Class `NetherFungusBlock extends VegetationBlock` implements `BonemealableBlock`. Constructor arguments (from the constructor lambdas): feature key, required block, support tag.

| Block | Feature | `requiredBlock` | Support tag (`mayPlaceOn`) |
|---|---|---|---|
| `crimson_fungus` | `TreeFeatures.CRIMSON_FUNGUS_PLANTED` | `crimson_nylium` | `supports_crimson_fungus` |
| `warped_fungus` | `TreeFeatures.WARPED_FUNGUS_PLANTED` | `warped_nylium` | `supports_warped_fungus` |

Shape: `Block.column(8, 0, 9)`. `mayPlaceOn(state)`: the state below is in the support tag.

| Method | Rule |
|---|---|
| `isValidBonemealTarget` | the block directly below IS `requiredBlock` (the nylium itself, not the tag) and `isInsideBuildHeight(pos.above())` |
| `isBonemealSuccess` | one `nextFloat()` draw, success when `< 0.4` |
| `performBonemeal` | look up the feature; if present, run `place` at `pos` with the chunk generator and the random source. The fungus block is NOT removed first and no state is restored on failure (the feature itself replaces it when it places the stem; the planted feature variants are configured in data, 35 part 4 `huge_fungus`) |

So bone meal on a fungus over netherrack or soil in the support tag (not the required nylium) is not a valid target.

### 3.2 `NetherRootsBlock` and `NetherSproutsBlock`

| Block | Class | Shape | `mayPlaceOn` |
|---|---|---|---|
| `crimson_roots` | `NetherRootsBlock` | `column(12, 0, 13)` | tag `supports_crimson_roots` |
| `warped_roots` | `NetherRootsBlock` | `column(12, 0, 13)` | tag `supports_warped_roots` |
| `nether_sprouts` | `NetherSproutsBlock` | `column(12, 0, 3)` | tag `supports_nether_sprouts` |

Both extend `VegetationBlock` and not `BushBlock`; neither declares `BonemealableBlock` (the class list of 29b-1 §5.2 does not contain them). Bone meal on them is not a valid target and does nothing (the item is not consumed: 29b-1 §5.3 step 2 fails the interface test and step 4 may still try water plants, which require sturdy support and a water cell, 17 §3.4). The nylium bone meal that grows these plants on nylium belongs to part 3 of 29b (`NyliumBlock`; registry rows 24 part 7 §12.2).

### 3.3 `BonemealableFeaturePlacerBlock` (`moss_block`, `pale_moss_block`)

| Block | Feature key |
|---|---|
| `moss_block` | `CaveFeatures.MOSS_PATCH_BONEMEAL` |
| `pale_moss_block` | `VegetationFeatures.PALE_MOSS_PATCH_BONEMEAL` |

| Method | Rule |
|---|---|
| `getType` | `NEIGHBOR_SPREADER`, so the bone meal particle is shown at `pos.above()` (29b-1 §5.1) |
| `isValidBonemealTarget` | the block at `pos.above()` is air (`isAir`, the state's own air test: air, cave air, void air) |
| `isBonemealSuccess` | always true |
| `performBonemeal` | look up the feature in the feature registry (a lookup that may be absent); if present, run `place` at `pos.above()` with the level's chunk generator and the random source. The result is ignored |

The vegetation patch shape (the `moss_patch_bonemeal` configuration: radius, vegetation chance, replaceable tag) is data and the `vegetation_patch` engine of 35 part 4 (not repeated).

### 3.4 `MossyCarpetBlock` (`pale_moss_carpet`) bone meal entry

Properties: `base` (boolean) and four wall-side enums `north`, `east`, `south`, `west` (24 part 8). Read:

| Method | Rule |
|---|---|
| `isValidBonemealTarget` | `base` is true AND the "topper" test is not air: the helper `createTopperWithSideChance(level, pos, supplier)` computed for the cell above is non-air |
| `isBonemealSuccess` | always true |
| `performBonemeal` | compute the same helper with the side-chance supplier answering true; when the result is not air, `setBlockAndUpdate(pos.above(), result)` |

The helper returns air when the cell above holds a pale moss carpet whose `base` is true, or holds a non-replaceable block that is not itself a carpet to extend; the exact construction of the topper state (which sides are filled) was not read in full (Open question 6). `isValidBonemealTarget` and `performBonemeal` both pass a supplier that returns true (the two lambdas return the constant true, read), so no random draw is made in these two methods.

## 4. The oxidation engine (`ChangeOverTimeBlock`)

### 4.1 Constants and entry point

| Item | Value (read) |
|---|---|
| `SCAN_DISTANCE` | 4 |
| Random tick gate | `0.05688889f` (a float constant; written in the bytecode as `0.05688889f`) |
| Chance modifier of a block (`WeatheringCopper.getChanceModifier`) | `0.75f` when its own weather state is `UNAFFECTED`, otherwise `1.0f` |

`changeOverTime(state, level, pos, random)` (the RT body of every weathering copper block, with the per-class conditions of section 6):

1. Draw `nextFloat()`. When the value is not less than 0.05688889, stop (exactly one draw consumed).
2. Otherwise compute the next state (4.2). When it exists, `setBlockAndUpdate(pos, nextState)` (flags 3: neighbours and clients; shape updates run).

### 4.2 Neighbour scan and probability (`getNextState`)

Let `a` be the ordinal of the block's own weather state (unaffected 0, exposed 1, weathered 2, oxidized 3).

1. Scan every position within Manhattan distance 4 of `pos`, excluding `pos` itself (the position filter `p != pos`). The scan region is `BlockPos.withinManhattan(pos, 4)`: all offsets with `|dx| + |dy| + |dz| <= 4`, which is 129 positions including the centre, so 128 are examined (count computed; the iteration runs by increasing Manhattan depth, read as the iterator's `currentDepth` field; the order does not affect the outcome, see step 3).
2. A scanned block counts only when it is a `ChangeOverTimeBlock` whose age enum is the same class as this block's age enum (all weathering copper blocks share `WeatheringCopper.WeatherState`). Waxed blocks are plain classes (`Block`, `SlabBlock`, `StairBlock`, `DoorBlock`, ...), do not implement the interface, and are not counted. A position above or below the world's section range, or in a chunk section that has no matching block, counts nothing; a chunk that is not yet in memory is fetched through `LevelReader.getChunk(x, z)` (it may load or generate a chunk, Open question 2).
3. For each counted neighbour with ordinal `b`:
   - `b < a`: abort. The result is "no change" (empty); the scan stops and no second random draw is made.
   - `b > a`: increment `H` (the "higher" count).
   - `b == a`: increment `S` (the "same" count).
4. If not aborted: `f = (H + 1) / (H + S + 1)` computed in single-precision floating point (`float`), and `p = f * f * chanceModifier`.
5. Draw `nextFloat()`; when it is less than `p`, the result is the next state (`getNext`, 5.1), else empty (second draw consumed only when not aborted).

So a block never ages while a younger neighbour exists within the radius, and a block that is the youngest in its neighbourhood ages with higher probability when more older blocks are near: the oldest-neighbour weighting is `H + 1` over `H + S + 1`.

Per random tick the chance of advancing a block that is not aborted is `0.05688889 * p`. For the whole-game rate see 29b-1 §2.4.

### 4.3 `isRandomlyTicking`

For the weathering classes the state test is: the block has a next block (`WeatheringCopper.getNext(block)` is present). Therefore the oxidized blocks (no next) and every waxed block (not in the map) are not random-ticking at all, and cost no ticks.

## 5. The ladder, the families and the tables

### 5.1 `WeatheringCopper`

| Item | Value |
|---|---|
| `WeatherState` | enum with serialized names `unaffected` (0), `exposed` (1), `weathered` (2), `oxidized` (3); `next()` and `previous()` use ordinal plus or minus one with clamping at the ends (a continuous id map with the clamp strategy); the stream codec is the id |
| `NEXT_BY_BLOCK` | a one-to-one map (bimap) built from `WeatheringCopperCollection.weathering` of 15 collections by `progressMapping`: unaffected to exposed, exposed to weathered, weathered to oxidized. No entry has the oxidized block as key |
| `PREVIOUS_BY_BLOCK` | the inverse bimap |
| `getNext(block)` / `getPrevious(block)` | map lookups (empty when absent) |
| `getFirst(block)` | follows `PREVIOUS_BY_BLOCK` repeatedly until no entry exists: the fully unaffected block of the family |
| state-level `getNext` / `getPrevious` / `getFirst` | the target block's `withPropertiesOf(state)`: the new block keeps every property the old state has (same names) |

The order of the 15 collections in the map is: copper block, cut copper, chiseled copper, cut copper slab, cut copper stairs, copper door, copper trapdoor, copper bars, copper grate, copper bulb, copper lantern, copper chest, copper golem statue, lightning rod, copper chain (the order has no effect on lookup).

### 5.2 `WeatheringCopperCollection` and the name table

A collection is a record of two four-entry groups: `weathering` (unaffected, exposed, weathered, oxidized) and `waxed` (the same four states). The name prefixes are read: weathering `""`, `exposed_`, `weathered_`, `oxidized_`; waxed `waxed_`, `waxed_exposed_`, `waxed_weathered_`, `waxed_oxidized_`. The base `copper_block` is special: `copper_block`, `exposed_copper`, `weathered_copper`, `oxidized_copper`, `waxed_copper_block`, `waxed_exposed_copper`, `waxed_weathered_copper`, `waxed_oxidized_copper` (24 part 8 §2.3). Registered order inside one family is the eight names above, so block id = first id + offset (0 to 7).

The wax-on map is `HoneycombItem.WAXABLES` = for each of the same 15 collections, `weathering[i]` to `waxed[i]` (i = 0..3); wax-off `WAX_OFF_BY_BLOCK` is its inverse. There are 15 x 4 = 60 wax pairs and 15 x 3 = 45 oxidation steps.

| # | Family (collection field) | Unaffected name (first id) | Weathering class | Waxed class | Notes |
|---|---|---|---|---|---|
| 1 | `COPPER_BLOCK` | `copper_block` (1124) | `WeatheringCopperFullBlock` | `Block` | other names per above |
| 2 | `CUT_COPPER` | `cut_copper` (1134) | `WeatheringCopperFullBlock` | `Block` | |
| 3 | `CHISELED_COPPER` | `chiseled_copper` (1142) | `WeatheringCopperFullBlock` | `Block` | |
| 4 | `CUT_COPPER_STAIRS` | `cut_copper_stairs` (1150) | `WeatheringCopperStairBlock` | `StairBlock` | |
| 5 | `CUT_COPPER_SLAB` | `cut_copper_slab` (1158) | `WeatheringCopperSlabBlock` | `SlabBlock` | |
| 6 | `COPPER_DOOR` | `copper_door` (1166) | `WeatheringCopperDoorBlock` | `DoorBlock` | lower half only ticks (6.1) |
| 7 | `COPPER_TRAPDOOR` | `copper_trapdoor` (1174) | `WeatheringCopperTrapDoorBlock` | `TrapDoorBlock` | |
| 8 | `COPPER_GRATE` | `copper_grate` (1182) | `WeatheringCopperGrateBlock` | `WaterloggedTransparentBlock` | |
| 9 | `COPPER_BULB` | `copper_bulb` (1190) | `WeatheringCopperBulbBlock` | `CopperBulbBlock` | light 15, 12, 8, 4 when lit (24 part 8) |
| 10 | `COPPER_CHEST` | `copper_chest` (1198) | `WeatheringCopperChestBlock` | `CopperChestBlock` | 6.2 |
| 11 | `COPPER_GOLEM_STATUE` | `copper_golem_statue` (1206) | `WeatheringCopperGolemStatueBlock` | `CopperGolemStatueBlock` | 6.3 |
| 12 | `LIGHTNING_ROD` | `lightning_rod` (1214) | `WeatheringLightningRodBlock` | `LightningRodBlock` | |
| 13 | `COPPER_BARS` | `copper_bars` (392) | `WeatheringCopperBarsBlock` | `IronBarsBlock` | |
| 14 | `COPPER_CHAIN` | `copper_chain` (401) | `WeatheringCopperChainBlock` | `ChainBlock` | |
| 15 | `COPPER_LANTERN` | `copper_lantern` (941) | `WeatheringLanternBlock` | `LanternBlock` (inferred from the weathering class's superclass; the waxed factory was not read) | |

Ids are the block ids of 24 parts 1, 4 and 8 (the first of the eight consecutive ids); 46 is the id list. Every class listed adds no block property to its plain superclass (24 part 8 §2.3). Ores (`copper_ore`, `deepslate_copper_ore`), raw copper and the exposed-copper items are not weathering blocks.

A block's `getAge()` is the stored weather state (for the chest `getState()`, for the statue `getWeatheringState()`).

## 6. Per-class hooks

Every weathering class's random tick calls `changeOverTime` (4.1) after the class condition below; every class's `isRandomlyTicking` is 4.3.

### 6.1 Door

`WeatheringCopperDoorBlock.randomTick`: only when `half` is `lower`. The upper half never ticks the engine. After the lower half is replaced (flags 3 via `setBlockAndUpdate`), the vertical shape update reaches the upper half; the `DoorBlock` shape rule says: for an update coming from the other half's direction, when the neighbour block is any `DoorBlock` whose `half` differs, the new state of this half is the neighbour's state with `half` set to this half. So the upper half becomes the same new block with the lower half's other properties (facing, hinge, open, powered). A scan of the world counts both halves as separate blocks of the family, but only the lower half ticks.

### 6.2 Chest

`WeatheringCopperChestBlock.randomTick`: runs the engine only when the `type` is not `right` AND the block entity at `pos` is a chest block entity AND no entity currently has its container open (`getEntitiesWithContainerOpen()` is empty). So a left half or single chest ages, a right half never ticks, and an open chest does not age. The partner half of a double chest is made consistent by the chest's own shape update, which uses the least oxidized state of the connected chests (`getLeastOxidizedChestOfConnectedBlocks`, 24 part 8 placement rule) and `unwaxBlock` (read to exist; its exact partner-update flow was not read, Open question 3). The chest block keeps its block entity across weathering changes (`shouldChangedStateKeepBlockEntity`).

### 6.3 Golem statue

`WeatheringCopperGolemStatueBlock`: `randomTick` calls the engine unconditionally. `useItemOn(stack, state, level, pos, ...)`, when the block entity at `pos` is the statue entity:

1. If the stack is in item tag `axes`: when the statue's state is `unaffected`, call `removeStatue(state)` on the block entity, damage the held axe by 1 (`hurtAndBreak` in the used hand's slot), when an entity was produced add it to the level (`addFreshEntity`), remove the block (`removeBlock(pos, false)`) and return SUCCESS; when the state is not unaffected return PASS (so the generic axe scrape of section 7 applies).
2. Else if the stack is honeycomb: PASS (the honeycomb item's own wax-on runs).
3. Else: change the pose with `updatePose(level, state, pos, player)` and return SUCCESS.

What `removeStatue` builds (the copper golem entity and its data) is entity content (21, 44 part 9) and was not read here.

### 6.4 The remaining classes

`WeatheringCopperFullBlock`, `Stair`, `Slab`, `TrapDoor`, `Bars`, `Chain`, `Grate`, `Bulb`, `WeatheringLanternBlock` and `WeatheringLightningRodBlock` call the engine unconditionally. A lit bulb keeps its `lit` and `powered` state across the step (state-preserving next, 5.1); its light level changes with the new weather state through the registry table (24 part 8).

## 7. Waxing, scraping, wax-off

### 7.1 Honeycomb on a block (`HoneycombItem.useOn`, wax on)

1. `getWaxed(state)`: the waxed block of the clicked block from `WAXABLES`, with `withPropertiesOf(state)`. If none exists: PASS (then sign waxing and other uses are tried by the item system, 17).
2. For a server player: advancement trigger `item_used_on_block` (29 §9) at the position with the stack.
3. `stack.shrink(1)` (no creative-mode test in this method; Open question 4).
4. `setBlock(pos, waxedState, 11)` (flags 1 + 2 + 8: neighbours, clients, and the 8 flag of 29 §1).
5. Game event `block_change` at `pos` with the player and the new state.
6. Level event **3003** at `pos`, data 0, with the player as the excluded source.
7. Sound `item.honeycomb.wax_on`, source BLOCKS, volume 1, pitch 1, at `pos` with the player as excluded source.
8. When the block is a chest block and its `type` is not `single`: for the connected half position (`ChestBlock.getConnectedBlockPos`): game event `block_change`, level event 3003 and the same sound there. The connected half's state is not written here; it is updated by the chest's shape update (6.2).
9. Return SUCCESS.

A sign (`tryApplyToSign`) sets its waxed flag with level event 3003 and the same sound; see 31 part 3.

### 7.2 Dispenser (honeycomb)

The honeycomb dispense behaviour (`DispenseItemBehavior$12`, an optional behaviour): the target is the cell in front of the dispenser. When `getWaxed(state)` exists: `setBlockAndUpdate(target, waxed)` (flags 3), level event 3003 at the target data 0, sound `item.honeycomb.wax_on` (BLOCKS, 1, 1), shrink the stack by 1 and mark success. Otherwise the default optional behaviour (item dispensed as an item entity, 29 §3.5).

### 7.3 Axe scrape and wax-off (`BlockTransformer` engine, `axe.json`)

The axe is a data component: item tag `axes` items carry a `block_transformer` component pointing at the registry entry `minecraft:axe` (`data/minecraft/block_transformer/axe.json`, an ordered list of 7 transformations). The code builds the same list (`BlockTransformers.bootstrap`): 

| Index | Content | Sound | Particle | Extra |
|---|---|---|---|---|
| 0 | strippable logs, woods, stems, hyphae and bamboo block (25 rules, 17 §3 lists them) | `item.axe.strip` | none | |
| 1 | scrape: every `PREVIOUS_BY_BLOCK` pair except chest and door (39 rules = 13 families x 3 steps) | `item.axe.scrape` | `scrape` | |
| 2 | scrape, copper chest (3 rules) | `item.axe.scrape` | `scrape` | `transform_type` `copper_chest`, `update_from_neighbors` false |
| 3 | scrape, copper door (3 rules) | `item.axe.scrape` | `scrape` | `update_from_neighbors` false |
| 4 | wax-off: every `WAX_OFF_BY_BLOCK` pair except chest and door (52 rules = 13 x 4) | `item.axe.wax_off` | `wax_off` | |
| 5 | wax-off, copper chest (4 rules) | `item.axe.wax_off` | `wax_off` | `transform_type` `copper_chest`, `update_from_neighbors` false |
| 6 | wax-off, copper door (4 rules) | `item.axe.wax_off` | `wax_off` | `update_from_neighbors` false |

(Order and counts read from `axe.json` and confirmed against the `axe` helper: a block type switch sends copper chest blocks to the chest builder, door blocks to the door builder, everything else to the default builder.) Each rule is "if the clicked block is exactly block X, then the state of block Y with the properties of the current state copied onto it" (the `copy_properties` state provider: the source state's property values are overwritten by the clicked state's values for every property both blocks have). The `properties` objects shown in the data for chests and doors are the template values of the source and are overwritten by the copy.

`BlockTransformer.transformBlock(context)` (any item with the component, 29 §9 for the use hook):

1. If the used hand is the main hand and the player's off-hand item has the `blocks_attacks` component (a shield) and the player is not using secondary use (not sneaking): return PASS.
2. Walk the transformations in list order and use the first that applies: skip a transformation whose `disallowed_faces` contains the clicked face (none for the axe), then ask its state provider for the new state at the clicked position using the level's random source (`getOptionalState`; a provider with no matching rule gives none and the transformation is skipped). The wax-off and scrape providers use no random draw.
3. When `update_from_neighbors` is true (the default; false for entries 2, 3, 5, 6) the new state is passed through `Block.updateFromNeighbourShapes`, so it already reflects neighbour shape rules; when false it is used as is.
4. Server player: advancement `item_used_on_block`.
5. On a server level, when the transformation has a loot table (the axe has none) the loot is dropped with the old state.
6. Item cost: when the item stack is stackable, consume `consumeOnUse ? 1 : 0` (default consume 1); otherwise damage the item by `item_damage_per_use` (the axe data: 1) using the used hand's slot (`hurtAndBreak`).
7. `setBlock(pos, newState, 11)`.
8. Play the transformation's sound at `pos` (BLOCKS, volume 1, pitch 1, the player as excluded source).
9. Particle event: for a non-`none` particle send level event with the particle's event id, data 0, with the player as excluded source: `scrape` **3005**, `wax_on` **3003**, `wax_off` **3004** (client particle effects are 42 part 7).
10. Game event `block_change` at `pos` with the player and the new state.
11. When the transformation's type is `copper_chest` and the new block is a copper chest whose `type` is not `single`: send the game event and the particle event at the connected half position too (no sound there). The other half's state is changed by the shape update caused by step 7.
12. Return SUCCESS. When no transformation applied: PASS.

Scrape order of effects matters for gameplay: the `axe` first tries the strip entry (index 0), so a block cannot be both; scrape and wax-off entries cannot overlap because waxed blocks have no previous entry.

## 8. Lightning

`LightningBolt` (entity, 33 and 18 for the entity): when `life` equals 2 during the server-side tick (the strike frame), after the optional fire spawning (difficulty normal or hard: `spawnFire(4)`) the bolt calls, in this order: `powerLightningRod()`, then `clearCopperOnLightningStrike(level, strikePos)`, then the game event `lightning_strike`.

| Item | Value |
|---|---|
| Strike position | `BlockPos.containing(x, y - 1.0E-6, z)` of the bolt: the block just under the bolt's feet (so a rod top is the strike block) |
| `powerLightningRod` | when the strike block is a `LightningRodBlock`, call its `onLightningStrike(state, level, pos)`: sets `powered` true (`setBlockAndUpdate`, flags 3), updates neighbours of the rod and of the block it is attached to, schedules a block tick after **8** ticks (`ACTIVATION_TICKS`), and sends level event **3002** (electric spark) at the position with the rod's facing as data; the scheduled tick sets `powered` false and updates neighbours again. A powered rod outputs signal 15 (own and direct towards its facing) |
| `RANGE` | 128 (the lightning rod's targeting range constant; the code that picks a rod for a bolt is in the weather/spawning code, Open question 5) |

`clearCopperOnLightningStrike(level, pos)`:

1. Let `state` be the block at `pos`. `waxed` = the block is a key in `WAX_OFF_BY_BLOCK` (it is a waxed copper block); `weathering` = the block is a `WeatheringCopper`. When neither, stop (no draw).
2. When `weathering`: `setBlockAndUpdate(pos, WeatheringCopper.getFirst(state))`: the whole ladder resets to the unaffected block of the family with the properties kept (flags 3). A waxed block is NOT changed at the strike position (it is not a `WeatheringCopper`), but step 3 still runs for it.
3. Draw `n = nextInt(3) + 3` (3 to 5 walks) from the level's random. Repeat `n` times: draw `m = nextInt(8) + 1` (1 to 8 steps), then perform a random walk of up to `m` steps from the strike position:
   - A step picks the first position of `BlockPos.randomInCube(random, 10, current, 1)` whose block is a `WeatheringCopper`. This iterator makes up to 10 attempts; each attempt draws three `nextInt(3)` values in the order x, y, z and adds `value - 1` (so the cube of side 3 centred on the current position, the current position itself being possible). The first attempt that hits a weathering copper block wins and the rest are not drawn.
   - On a hit: set that position to `WeatheringCopper.getPrevious(state)` (one step back on the ladder, properties kept; `setBlockAndUpdate`, flags 3; a block already unaffected has no previous and is left unchanged but is still the walker's new position), send level event **3002** at it with data **-1**, and continue the walk from it.
   - On no hit in 10 attempts the walk ends.

The walk position restarts at the strike position for each of the `n` walks. Waxed blocks are never selected by the walk (they are not `WeatheringCopper`), so a wax coat protects a block from the lightning scrub and from oxidation, and blocks walks from passing through it.

## 9. Worked examples

**9.1 Isolated copper block.** An unaffected `copper_block` with no other copper within 4 blocks: `H = S = 0`, `f = 1`, `p = 1 x 1 x 0.75 = 0.75`. Per random tick the chance to become `exposed_copper` is `0.05688889 x 0.75 = 0.04266667`. The expected wait is about 23.4 random ticks.

**9.2 Crowded copper.** An `exposed_copper` (a = 1, modifier 1.0) with three other exposed blocks and one weathered block in the radius, no unaffected block: `H = 1`, `S = 3`, `f = 2/5 = 0.4`, `p = 0.16`; per random tick `0.05688889 x 0.16 = 0.0091022`. If an unaffected block is in the radius, the tick makes the first draw and then the scan aborts: no second draw, no change.

**9.3 Oxidizing door.** A `copper_door` upper half never ticks. When the lower half becomes `exposed_copper_door` the upper half is rewritten by its shape update to `exposed_copper_door` with `half = upper` and the lower half's other properties.

**9.4 Mushroom.** Brown mushroom at (10, 64, 10) in the dark with 3 other brown mushrooms in the 9 x 3 x 9 box (count 4 including itself): spread allowed (4 is at most 4). With 4 others (count 5) no spread. A chosen target that is not air, or has light 13 or more and a support outside the override tag, fails the 5th step.

**9.5 Lightning.** A bolt strikes a `weathered_cut_copper_stairs` (facing east, half bottom). The block becomes `cut_copper_stairs` (facing east, half bottom, other properties unchanged). Then 3 to 5 walks start at that cell; each hit steps one block of any copper family back one ladder level, with spark events at each.

**9.6 Wax then scrape.** Honeycomb on `oxidized_copper_door` (lower half, closed): becomes `waxed_oxidized_copper_door`, 1 honeycomb consumed, event 3003 and the wax-on sound. An axe on it: transformation 6 matches, the new block is `oxidized_copper_door` with the clicked state's properties copied, `update_from_neighbors` false; 1 durability, sound `item.axe.wax_off`, event 3004.

## 10. Validation

| # | Check | Expected |
|---|---|---|
| V1 | `changeOverTime` first draw | exactly one `nextFloat` consumed; no further draw when it is `>= 0.05688889` |
| V2 | A younger copper block within Manhattan 4 | no change and no second draw |
| V3 | Manhattan region size | 129 offsets including the centre; 128 examined |
| V4 | Waxed neighbours | not counted in `H` or `S` and never abort |
| V5 | Unaffected modifier | 0.75; every other state 1.0 |
| V6 | `isRandomlyTicking` of oxidized and of waxed blocks | false |
| V7 | Door upper half and chest right half | never run the engine; open chest does not age |
| V8 | Wax pairs count | 60; scrape pairs 45; axe.json lists 7 transformations (25, 39, 3, 3, 52, 4, 4 rules) |
| V9 | Honeycomb on `waxed_*` block | PASS (no waxed entry) |
| V10 | Axe with shield in off-hand, not sneaking | PASS, nothing changes |
| V11 | Mushroom spread draws | 1 (1/25) + 4 + 16 draws when the gate passes and spread is allowed |
| V12 | Mushroom spread count rule | count of the same block in the 9 x 3 x 9 box including itself at most 4 |
| V13 | Mushroom bone meal | 40% (`nextFloat() < 0.4`); a failed growth restores the block |
| V14 | Nether fungus bone meal | valid only over its own nylium; no restore on failure |
| V15 | Moss block bone meal | valid when the cell above is air; the result is ignored; particle at `pos.above()` |
| V16 | Lightning | strike cell reset to the first ladder block (when not waxed); 3 to 5 walks of 1 to 8 steps; waxed untouched |
| V17 | Huge mushroom block placement faces | true for each side whose neighbour is not the same block |
| V18 | Roots and sprouts bone meal | not valid targets |

## 11. Open questions

1. `MossyCarpetBlock.createTopperWithSideChance`: the construction of the topper state (which sides are filled and how the random supplier is used) was read only as far as the air conditions of 3.4; the rest is not specified here.
2. The scan uses `LevelReader.getChunk(x, z)` (and so can load or generate a chunk) through `FilteredSectionCache.getOrLoad`; the chunk status requested and the behaviour for unloaded chunks were not read.
3. The copper chest partner update (`CopperChestBlock.updateShape`, `unwaxBlock`, `getLeastOxidizedChestOfConnectedBlocks`) was identified by name; its flow on wax-on, scrape and oxidation of a double chest was not read.
4. `HoneycombItem` uses `ItemStack.shrink(1)` directly; whether creative-mode players keep the item depends on the stack or player abilities (29 §9) and was not read here.
5. The code that chooses a lightning rod as the strike target (using `RANGE` 128) is not in the classes read; it belongs to the weather and lightning spawn round (33).
6. `CopperGolemStatueBlockEntity.removeStatue`, the statue pose update and the oxidation of the `CopperGolem` mob (`CopperGolemOxidationLevels`) were not read.
7. `HugeMushroomBlock.mirror` was read to exist; its direction mapping is (inferred) to mirror the horizontal faces.
8. The waxed lantern class (`LanternBlock`) of 5.2 row 15 is inferred from the weathering class's superclass.
9. Client-side effects of level events 3002 to 3005 (the particle shapes) are 42 part 7 and were not read here; `HugeMushroomBlock` textures, `ShelfMushroomBlock` bounce velocity (41 §3) and the moss feature shapes (35 part 4) were not read here.
10. Moss and mushroom feature configuration values (`foliageRadius` of the huge mushroom features, the patch radius) are data of the extracted packs and are not tabulated here.
