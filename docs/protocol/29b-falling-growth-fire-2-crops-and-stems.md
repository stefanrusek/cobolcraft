# 29b. Falling blocks, growth, fire and similar block behaviours, part 2: crops, stems, berries, farmland, saplings (variants) and soil blocks

| | |
|---|---|
| Covers | Behaviour of the `CropBlock` family (wheat, carrots, potatoes, beetroots, torchflower crop, pitcher crop with its double-block rules), `StemBlock` and `AttachedStemBlock`, `NetherWartBlock`, `CocoaBlock`, `SweetBerryBushBlock`, `FarmlandBlock`, `PathBlock`, `MudBlock`, `RootedDirtBlock`, the sapling variants (`MangrovePropaguleBlock`, `AzaleaBlock`; `SaplingBlock` itself is in part 1 §7), `PumpkinBlock` and the plain `melon`; the can-survive rule of each block and the bone meal behaviour of each. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data files named below, with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS11 (GAP-10b of `../design/README.md` Part 5), part 2 |
| Data versus code | Tags (`supports_crops`, `grows_crops`, `supports_vegetation`, `supports_azalea`, `supports_cocoa`, `supports_nether_wart`, `supports_pumpkin_stem`, `supports_pumpkin_stem_fruit`, `supports_melon_stem`, `supports_melon_stem_fruit`, `maintains_farmland`, `supports_mangrove_propagule`, `supports_hanging_mangrove_propagule`), loot tables (crop drops, stem seed counts, berry harvest, carved pumpkin) and the tree features are DATA (22, 23, 26, 35). The members of the tags are listed once in 2.2 only so that worked examples can be followed; the engine below reads the tags, it does not hard-code them. Everything else here (ages, probabilities, shapes of the double plant, orderings, constants) is code and is specified completely. |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions.

Related documents. The behaviour record, trigger kinds, probability notation (`1/N`, `P(p)`, `U(a,b)`) and predicate vocabulary are those of 29b part 1 §2 and are not repeated. The `CropBlock` base (predicates, random tick, `getGrowthSpeed`, base bone meal) is 29b part 1 §6; the bone meal item flow and the `BonemealableBlock` contract are 29b part 1 §5; the sapling block, `TreeGrower` queries, `growTree` and the grower table are 29b part 1 §7. Block registry rows (ids, properties, state counts, map colours, sounds, outline shapes) are 24 (stems 24 part 4 §6.6 and §6.15, §6.23; sweet berry bush 24 part 7 §11.6; mud, rooted dirt and azalea 24 part 8; mangrove propagule 24 part 1). Light values (`getRawBrightness`, `getMaxLocalRawBrightness`) are 32 §1.2; `isRainingAt` and spawn protection are 33 §3 and §6.5; update flags and `setBlock` are 29 §1 to §3; `isSolid` is 24 part 1 §5.2; fall damage is 17 and 18. The hoe and shovel conversions that create farmland and paths are 17 (tool use table).

## 0. Reader's map

| Question | Section |
|---|---|
| Tags the rules read, and what is in them as shipped | 2 |
| Wheat, carrots, potatoes, beetroots, torchflower: what differs from `CropBlock` | 3 |
| Pitcher crop (two blocks tall) | 4 |
| Pumpkin and melon stems, fruit placement, attached stems, pumpkin and melon blocks | 5 |
| Nether wart | 6 |
| Cocoa | 7 |
| Sweet berry bush | 8 |
| Farmland | 9 |
| Dirt path, mud, rooted dirt | 10 |
| Mangrove propagule, azalea, flowering azalea, sapling recap | 11 |
| Can-survive rules in one table | 12 |
| Bone meal rules in one table | 13 |
| Worked examples | 14 |
| Validation | 15 |
| Open questions | 16 |

## 1. Registry names covered

| Registry name | Class (read) | Section |
|---|---|---|
| `wheat` | `CropBlock` itself (constructor reference in the registration) | 3 |
| `carrots` | `CarrotBlock extends CropBlock` | 3 |
| `potatoes` | `PotatoBlock extends CropBlock` | 3 |
| `beetroots` | `BeetrootBlock extends CropBlock` | 3.3 |
| `torchflower_crop` | `TorchflowerCropBlock extends CropBlock` | 3.4 |
| `pitcher_crop` | `PitcherCropBlock extends DoublePlantBlock` | 4 |
| `pumpkin_stem`, `melon_stem` | `StemBlock` | 5.1, 5.2 |
| `attached_pumpkin_stem`, `attached_melon_stem` | `AttachedStemBlock` | 5.3 |
| `pumpkin` (`PumpkinBlock`), `melon` (plain `Block`) | | 5.4 |
| `nether_wart` | `NetherWartBlock` (a `VegetationBlock`, NOT a `BushBlock`, no bone meal) | 6 |
| `cocoa` | `CocoaBlock extends HorizontalDirectionalBlock` | 7 |
| `sweet_berry_bush` | `SweetBerryBushBlock` | 8 |
| `farmland` | `FarmlandBlock` (base block `dirt`) | 9 |
| `dirt_path` | `PathBlock` (base block `dirt`; there is no class named `DirtPathBlock`) | 10.1 |
| `mud`, `rooted_dirt` | `MudBlock`, `RootedDirtBlock` | 10.2, 10.3 |
| `oak_sapling`, `spruce_sapling`, `birch_sapling`, `jungle_sapling`, `acacia_sapling`, `cherry_sapling`, `dark_oak_sapling`, `pale_oak_sapling`, `poplar_sapling` | `SaplingBlock` with `TreeGrower` OAK, SPRUCE, BIRCH, JUNGLE, ACACIA, CHERRY, DARK_OAK, PALE_OAK, POPLAR (read in the nine registration lambdas) | part 1 §7, here 11.3 |
| `mangrove_propagule` | `MangrovePropaguleBlock extends SaplingBlock`, `TreeGrower.MANGROVE` | 11.1 |
| `azalea`, `flowering_azalea` | `AzaleaBlock` (one class, two registrations) | 11.2 |

Registration builder flags for the crop-like blocks (read in `Blocks`): wheat, carrots, potatoes, beetroots, torchflower crop and pitcher crop: map colour `PLANT`, no collision, random ticks, instabreak, sound `CROP`, push reaction `POPPED`. Pumpkin and melon stems: the same with sound `HARD_CROP`. Attached stems: map colour `PLANT`, no collision, instabreak, sound `WOOD`, `POPPED`, and NO random ticks flag. Nether wart: map colour `COLOR_RED`, no collision, random ticks, sound `NETHER_WART`, `POPPED` (no instabreak: it has the default hardness, see 24 part 4). Cocoa: strength 0.2 / 3.0, sound `WOOD`, `noOcclusion`, random ticks, `POPPED`. Sweet berry bush: random ticks, no collision, sound `SWEET_BERRY_BUSH`, `POPPED`. Farmland: map colour `DIRT`, random ticks, strength 0.6, sound `GRAVEL`, `isSuffocating` always true. Dirt path: map colour `DIRT`, strength 0.65, sound `GRASS`, `isSuffocating` always true, NO random ticks flag. Saplings and the mangrove propagule: no collision, random ticks, instabreak, push reaction `POPPED` (propagule additionally horizontal offset type XZ). Azalea blocks: force-solid-off, instabreak, `noOcclusion`, `POPPED`, no random ticks flag. The `isRandomlyTicking` override of each class is stated in its section.

## 2. Tags and shared vocabulary

### 2.1 Vocabulary

| Term | Meaning |
|---|---|
| `rawBrightness(pos, 0)` | `max(blockLight, skyLight)` at `pos` with no sky darkening (32 §1.2; `getRawBrightness(pos, 0)`) |
| `maxLocalRawBrightness(pos)` | 32 §1.2, the sky term darkened by the current sky darkening |
| `level random` | `Level.getRandom()`; bone meal methods draw from it, not from the `random` parameter (29b part 1 §5.3) |
| `isAir` (state) | the block state is an air block (`BlockState.isAir`); this differs from `LevelReader.isEmptyBlock` only by name in the places read, both mean "air" |
| `solid` | `BlockState.isSolid()`, the cached legacy solid flag (24 part 1 §5.2) |
| Update flags written | `2` (clients only) for every growth write below unless stated; `3` where "and update" is written (`setBlockAndUpdate`) |

### 2.2 Tag members as shipped (DATA, illustration only)

| Tag | Members read in `data/minecraft/tags/block` |
|---|---|
| `supports_crops`, `grows_crops` | `farmland` |
| `supports_vegetation` | `#substrate_overworld`, `farmland` |
| `substrate_overworld` | `#dirt`, `#mud`, `#moss_blocks`, `#grass_blocks` |
| `supports_azalea`, `supports_mangrove_propagule` | `#supports_vegetation`, `clay` |
| `supports_cocoa` | `#jungle_logs` |
| `supports_nether_wart` | `soul_sand` |
| `supports_pumpkin_stem`, `supports_melon_stem` | `#supports_stem_crops` which is `#supports_crops` (so farmland) |
| `supports_pumpkin_stem_fruit`, `supports_melon_stem_fruit` | `#supports_stem_fruit` which is `#supports_vegetation` |
| `maintains_farmland` | `pumpkin_stem`, `attached_pumpkin_stem`, `melon_stem`, `attached_melon_stem`, `beetroots`, `carrots`, `potatoes`, `torchflower_crop`, `torchflower`, `pitcher_crop`, `wheat`, `moving_piston`, `#fence_gates` |
| `supports_hanging_mangrove_propagule` | `mangrove_leaves` |

## 3. The `CropBlock` family

The base behaviour (age property, `isMaxAge`, random-tick growth, growth speed, light and ground rules, Ravager trampling `entityInside`, bone meal `growCrops`) is 29b part 1 §6. The hooks the subclasses override are `getAgeProperty`, `getMaxAge`, `getBaseSeedId`, `getBonemealAgeIncrease`, `getStateForAge`, `randomTick`, `getShape`.

### 3.1 Class table

| Block | Age property | `getMaxAge` | Pick-block item (`getBaseSeedId`) | Outline shape for age `a` (a column of the stated half-width, from y 0) | Own `randomTick` |
|---|---|---|---|---|---|
| `wheat` | `AGE_7` (0..7) | 7 | `wheat_seeds` | width 16, height `2 + 2a` (2, 4, ..., 16) | no |
| `carrots` | `AGE_7` | 7 | `carrot` | width 16, height `2 + a` (2, 3, ..., 9) | no |
| `potatoes` | `AGE_7` | 7 | `potato` | width 16, height `2 + a` (2, 3, ..., 9) | no |
| `beetroots` | `AGE_3` (0..3) | 3 | `beetroot_seeds` | width 16, height `2 + 2a` (2, 4, 6, 8) | yes, 3.3 |
| `torchflower_crop` | `AGE_1` (0..1) | **2** | `torchflower_seeds` | width 6, height `6 + 4a` (6, 10) | yes, 3.4 |

Shapes: `column(width, 0, height)` is the box of x and z extent `width` centred in the block (24 part 1 §6). Wheat uses the base shape of `CropBlock` (part 1 §6 says the heights are `2 x (age + 1)`, which holds for wheat and beetroots only: carrots and potatoes use `2 + age`, read in their static initializer lambdas). The shapes are the outline (and, with no collision, the only) shape.

### 3.2 Rules inherited unchanged (restated as the numbers an implementation needs)

- Random tick (`isRandomlyTicking` is true while `age < getMaxAge()`): `rawBrightness(pos, 0) >= 9`, `age < max`, `speed = getGrowthSpeed`, then `1/(int(25.0f / speed) + 1)`; success writes `getStateForAge(age + 1)` with flags 2. The `nextInt` draw is made only when the first two conditions held. Draws come from the `random` argument of the tick.
- Survive: `rawBrightness(pos, 0) >= 8` AND the block below is in `supports_crops`. Any neighbour update re-checks it (`VegetationBlock.updateShape`): a failing crop becomes air (the replacement is a shape-update write, 29 §3.2).
- Bone meal: valid while not max age; always succeeds; new age `min(max, age + inc)`, `inc` = `U(2, 5)` from the level random (`nextInt(4) + 2`) unless overridden; write flags 2; no random tick afterwards.
- `entityInside`: on a server level a `Ravager` with `mob_griefing` true destroys the block with drops (`destroyBlock(pos, true, entity)`); this is also true of the pitcher crop (4.5). Nothing else happens on contact.

### 3.3 Beetroots

- `randomTick`: first one draw `nextInt(3)`; if it is 0 the tick ends (no growth attempt, and no light or growth-speed draw); otherwise the full `CropBlock` random tick of 3.2 runs. The growth chance per tick is therefore `2/3` of the base chance.
- Bone meal increase: `U(2, 5) / 3` with integer division: draws 2, 3, 4, 5 give 0, 1, 1, 1. One quarter of bone meal uses add nothing (the item is still consumed, 29b part 1 §5.3).
- Max age 3: `isMaxAge` at age 3.

### 3.4 Torchflower crop

- `getMaxAge` is 2 although the `age` property only has the values 0 and 1. Consequently `isMaxAge` is never true for the crop block, it keeps random ticking, and it is always a valid bone meal target.
- `getStateForAge(2)` returns the default state of the block `torchflower` (the fully grown flower, a plain plant block outside this document); every other age gives the crop state of that age. So growing from age 1 replaces the crop with the flower.
- `randomTick`: one draw `nextInt(3)`; 0 ends the tick; otherwise the `CropBlock` random tick of 3.2 (with `max` = 2, so the light test and the speed test run; the growth-speed "same block" halving compares against `torchflower_crop`).
- Bone meal increase: constant 1, so `growCrops` writes `getStateForAge(min(2, age + 1))`. No random draw is made for the increase.

## 4. Pitcher crop (`PitcherCropBlock extends DoublePlantBlock`)

State: `age` 0..4 (`AGE_4`) and `half` (`upper` or `lower`, enum order UPPER, LOWER; default state is `lower` age 0). Max age 4. The block is one block tall for ages 0 to 2 and two blocks tall (lower plus upper) for ages 3 and 4: `isDouble(age)` is `age >= 3`.

### 4.1 Placement and survival

| Rule | Behaviour |
|---|---|
| Placement state | `getStateForPlacement` returns the default state (lower, age 0) with no height test; `setPlacedBy` does nothing, so no upper half is created on placement (the generic `DoublePlantBlock` versions, which test `y < maxY` and a replaceable block above and create the upper half, are overridden) |
| `canBeReplaced` | always false |
| `mayPlaceOn` | block below in `supports_crops` |
| `canSurvive(state)` | if the state is the LOWER half of this block: needs `rawBrightness(pos, 0) >= 8`, else false; then `DoublePlantBlock.canSurvive`: for an UPPER half, the block below must be this block in its lower half (and nothing else is tested); for any other state the `VegetationBlock` rule (block below in `supports_crops`). The upper half is never tested for light |
| `updateShape` (any direction) | if `isDouble(age)`: the `DoublePlantBlock` rule, in this order. (a) If the direction is on the Y axis and `(half == LOWER) == (direction == UP)` (the neighbour in that direction is where the partner half should be) and the neighbour state is not this block or has the same `half` as this state: the result is air. (b) Else if the state is LOWER, the direction is DOWN and the state cannot survive: air. (c) Else the `VegetationBlock` rule (air when it cannot survive). If the age is below 3 (single block): the state itself when `canSurvive`, else air, from every direction |

### 4.2 Shapes

For age `a` (0..4), width `w = 6` if `a == 0` else 10; `h = (a == 0 ? 4 : 6) + T[a]` with `T = {0, 9, 11, 22, 26}`; so `h` = 4, 15, 17, 28, 32.

| Half | Outline shape (`column(width, y0, y1)`, pixels) |
|---|---|
| LOWER | `column(w, -1, min(16, h - 1))`: heights to y 3, 14, 16, 16, 16 |
| UPPER | `column(w, 0, max(h - 17, 0))`: y1 = 0, 0, 0, 11, 15 (ages 0 to 2 never have an upper half) |

Collision shape: LOWER: `column(6, -1, 3)` at age 0, `column(10, -1, 5)` at any other age; UPPER: empty. (The two box constants are `SHAPE_BULB` and `SHAPE_CROP`, read.)

### 4.3 Random tick and growth

- `isRandomlyTicking`: the state is the LOWER half and `age < 4`.
- `randomTick`: `speed = getGrowthSpeed(this, level, pos)` (part 1 §6.3 with this block as the "same block"); one draw `nextInt(int(25.0f / speed) + 1)`; when it is 0, `grow(level, state, pos, 1)`. There is no light test in the tick itself (the light test is inside `canGrow`, below).
- `canGrow(level, pos, state, newAge)` (`pos` is the lower half): true when all hold: `age(state) < 4`; `rawBrightness(pos, 0) >= 8`; `pos.above()` is inside the build height; and, if `isDouble(newAge)`, `canGrowInto(pos.above())`: the block above is air (`isAir`) or is `pitcher_crop`.
- `grow(level, lowerState, lowerPos, inc)`: `newAge = min(age + inc, 4)`; if `canGrow(..., newAge)` is false do nothing. Otherwise (1) write the lower position with the same state but `age = newAge`, flags 2; (2) if `isDouble(newAge)`, write `lowerPos.above()` with that same state but `half = upper`, using `setBlockAndUpdate` (flags 3).
- `entityInside`: same as 3.2 (Ravager with `mob_griefing`: `destroyBlock(pos, true, entity)` on the half that was entered).

### 4.4 Bone meal (`BonemealableBlock`, type GROWER)

| Method | Rule |
|---|---|
| lower half lookup (`getLowerHalf`) | if the clicked state is LOWER: itself; else the block below, when it is a lower-half pitcher crop (its state is read), else none |
| `isValidBonemealTarget` | lower half found and `canGrow(level, lowerPos, lowerState, lowerAge + 1)` |
| `isBonemealSuccess` | true |
| `performBonemeal` | lower half found: `grow(level, lowerState, lowerPos, 1)`; else nothing |

The age step is exactly 1 (not `U(2, 5)`). Growing from age 2 to 3 requires an air (or pitcher crop) cell above; from 3 to 4 the cell above is the existing upper half (a pitcher crop) so `canGrowInto` holds.

### 4.5 Breaking

`DoublePlantBlock.playerWillDestroy` (server): when the player prevents drops (creative, `preventsBlockDrops`) the lower half is removed instead through `preventDropFromBottomPart`: if the broken state is the UPPER half and the block below is the same block in its LOWER half, the lower half is replaced by water (when its fluid state is water) or air with flags 35 (1 + 2 + 32: no drops from the shape update) and level event 2001 (block break effect) with the old state id is sent; otherwise (survival) `dropResources` is called for the broken state with the tool. `playerDestroy` runs the generic destroy with the state treated as air. The loot of a pitcher crop is data (26).

## 5. Stems, fruit, attached stems, pumpkin and melon

24 part 4 §6.6 already records the property, shape, survive and bone meal rules of the stems. This section adds the exact tick order, the fruit search, and the registration constants, and it agrees with that text.

### 5.1 Stem constants

`StemBlock(fruitKey, attachedStemKey, seedKey, stemSupportTag, fruitSupportTag, properties)`:

| Block | fruit | attached stem | seed item | stem support tag | fruit support tag |
|---|---|---|---|---|---|
| `pumpkin_stem` | `pumpkin` | `attached_pumpkin_stem` | `pumpkin_seeds` | `supports_pumpkin_stem` | `supports_pumpkin_stem_fruit` |
| `melon_stem` | `melon` | `attached_melon_stem` | `melon_seeds` | `supports_melon_stem` | `supports_melon_stem_fruit` |

Age property `AGE_7`, default 0. `isRandomlyTicking` is not overridden: every state random-ticks (registration flag). Shape `column(2, 0, 2 + 2a)`. Survive: `mayPlaceOn` = block below in the stem support tag; there is NO light test in `canSurvive`.

### 5.2 Random tick (order of tests and draws)

1. If `rawBrightness(pos, 0) < 9`: stop (no draw).
2. `speed = CropBlock.getGrowthSpeed(this, level, pos)` (part 1 §6.3; the "same block" tests compare with this stem block, so a melon stem does not halve the speed of a pumpkin stem).
3. Draw `nextInt(int(25.0f / speed) + 1)`; if not 0: stop.
4. `age = state.age`. If `age < 7`: write `age + 1` with flags 2 and stop.
5. Otherwise (age 7, mature): draw a random horizontal direction `d` (`Plane.HORIZONTAL.getRandomDirection`: `nextInt(4)` into the list NORTH, EAST, SOUTH, WEST; 24 part 4 §2.1). `target = pos + d`; `soil = state at target.below()`.
6. Conditions: the state at `target` is air (`isAir`), `soil` is in the fruit support tag, and both the fruit block and the attached stem block exist in the block registry. No other test is made: in particular an existing fruit elsewhere next to the stem, light at the target, or the stem's own survival are not checked.
7. Effects, in order: `setBlockAndUpdate(target, fruit.defaultBlockState())`; then `setBlockAndUpdate(pos, attachedStem.defaultBlockState().setValue(facing, d))`.

### 5.3 Attached stems

- `facing` (default NORTH). No random ticks. Shape `rotateHorizontal(boxZ(4, 0, 10, 0, 10))` (24 part 4 §6.6).
- `mayPlaceOn`: block below in `supports_pumpkin_stem` (pumpkin) or `supports_melon_stem` (melon); the generic `VegetationBlock` update turns the block into air when it fails.
- `updateShape(direction, neighbourState)`: when the neighbour at `direction` is NOT the fruit block and `direction == facing`, and the stem block exists: the new state is the stem's default state with `age` set to 7 (`trySetValue`). Otherwise `VegetationBlock.updateShape`.
- Constructor order (read): `AttachedStemBlock(stemKey, fruitKey, seedKey, supportTag, properties)`.
- Pick-block item: the seed item. Seeds that drop are a loot table (26); for the stems the shipped table uses a binomial count with `n = 3` and a probability that rises with age (data).

### 5.4 `pumpkin` and `melon`

`melon` is a plain `Block` (strength 1.0, sound `WOOD`, `POPPED`). `pumpkin` is `PumpkinBlock` (map colour `COLOR_ORANGE`, instrument `DIDGERIDOO`, strength 1.0, sound `WOOD`, `POPPED`). Neither has plant support rules: the fruit is placed only by 5.2 (the support condition is on the soil under the fruit cell) and, once placed, it is an ordinary block whose survival is not re-tested. Breaking a fruit makes the attached stem revert (5.3). `PumpkinBlock.useItemOn` with shears (carving) is specified in 24 part 4 §6.5; this document adds nothing to it except confirming the same numbers: result `carved_pumpkin` with flags 11, one durability, game event `shear`, item-used stat for shears, item entity at (x + 0.5 + 0.65 stepX, y + 0.1, z + 0.5 + 0.65 stepZ) with delta (0.05 stepX + 0.02 r1, 0.05, 0.05 stepZ + 0.02 r2) where r1 is drawn before r2 (`nextDouble` each), loot table `carve_pumpkin` as a block-interact table (data).

## 6. Nether wart (`NetherWartBlock`)

| Item | Rule |
|---|---|
| Properties | `age` 0..3, default 0; shape `column(16, 0, 5 + 3a)` (5, 8, 11, 14) |
| Survive | `mayPlaceOn`: block below in `supports_nether_wart`; no light test |
| `isRandomlyTicking` | `age < 3` |
| Random tick | if `age < 3` and `nextInt(10) == 0`: write `age + 1`, flags 2. One draw, no light or biome test (the class has no dimension condition) |
| Bone meal | none: `NetherWartBlock` does not implement `BonemealableBlock` (it extends `VegetationBlock`, not `BushBlock`) |
| Pick-block | `nether_wart` |

## 7. Cocoa (`CocoaBlock`)

| Item | Rule |
|---|---|
| Properties | `facing` (default NORTH) and `age` 0..2 (default 0); the block is attached to the block in the `facing` direction |
| Survive | the state at `pos.relative(facing)` is in `supports_cocoa` (no light test); not pathfindable |
| Placement | walk `getNearestLookingDirections`; for each horizontal direction `d`, set `facing = d`; the first state that `canSurvive` at the clicked position is the result; none gives null |
| `updateShape` | when the direction equals `facing` and the state cannot survive: air; else the horizontal block default |
| `isRandomlyTicking` | `age < 2` |
| Random tick | one draw `nextInt(5)` on the level's own random; if 0 and `age < 2`: write `age + 1`, flags 2. No light test |
| Bone meal | valid while `age < 2`; always succeeds; write `age + 1`, flags 2; type GROWER |
| Shape | per 24 part 4 §6.23 (age 0: x 6..10, z 1..5, y 7..12 for facing north, rotating with `facing`) |

## 8. Sweet berry bush (`SweetBerryBushBlock`)

State `age` 0..3 (default 0); outline shapes and the survive rule are in 24 part 7 §11.6 (the class does not override `canSurvive`, so the ground is the `supports_vegetation` rule of `VegetationBlock`: no light test). Pick-block item `sweet_berries`.

| Trigger | Rule |
|---|---|
| `isRandomlyTicking` | `age < 3` |
| Random tick | if `age < 3` and `nextInt(5) == 0` and `rawBrightness(pos.above(), 0) >= 9` (the draw is made first, the light test only after a 0): write `age + 1`, flags 2, then game event `block_change` with the new state at `pos`. |
| Entity contact (`entityInside`) | skip entirely when the entity is not a `LivingEntity`, or is a fox or a bee. Otherwise: (1) `makeStuckInBlock(state, (0.800000011920929, 0.75, 0.800000011920929))` (the first and third are the float 0.8 widened; the vector is the stuck-speed multiplier, 18 §2.6). (2) Server only, and only when `age > 0`: let `v` = the entity's `getKnownMovement()` when it is client-authoritative (players), else `oldPosition - position`. If the horizontal squared length of `v` is above 0 and (`|v.x| >= 0.003` or `|v.z| >= 0.003`; the constant is the float 0.003 widened, 0.003000000026077032), the entity takes 1.0 damage of source `sweetBerryBush` through `hurtServer`. A standing entity (zero movement) is slowed but not hurt, and an age-0 bush slows but never hurts |
| `useItemOn` | when `age != 3` and the held stack is bone meal: PASS (the interaction falls through so that the item use, bone meal, proceeds, never the harvest); in every other case the generic `useItemOn` (which passes to `useWithoutItem`) |
| `useWithoutItem` (harvest) | if `age > 1`: on a server level: (1) drop the loot of the block-interact table `harvest/sweet_berry_bush` (data) with each stack popped at the block (`popResource`); (2) play `sweet_berry_bush_pick_berries` (blocks category, volume 1.0, pitch `0.8 + level random float x 0.4`, no source entity) at the position; (3) write `age = 1`, flags 2; (4) game event `block_change` with the player as source; return SUCCESS (also on the client). If `age <= 1`: the generic default (PASS) |
| Bone meal | valid while `age < 3`; always succeeds; write `min(3, age + 1)`, flags 2 |

So bone meal can take a bush from 0 to 3 in three uses and never changes the harvest rule. The shipped harvest table gives one berry (only at age 3) plus 1 to 2 berries, so an age-3 bush yields 2 to 3 and an age-2 bush yields 1 to 2 (data, illustration).

## 9. Farmland (`FarmlandBlock`)

State `moisture` 0..7 (`MAX_MOISTURE` 7), default 0; the constructor takes the base block (`dirt` in the registration). Shape `column(16, 0, 15)`; `useShapeForLightOcclusion` true; not pathfindable.

### 9.1 Survive and block-above rule

`canSurvive(state)` is true when the block above is NOT `solid` (24 part 1 §5.2: air, plants, most partial blocks) OR the block above is in `maintains_farmland` (2.2). Equivalently a solid, non-listed block above makes farmland unable to survive.

| Trigger | Rule |
|---|---|
| `updateShape` | when the direction is UP and the state cannot survive: `scheduleTick(pos, farmland, 1)` (one tick); the state itself is returned unchanged by the shape update |
| scheduled tick | if the state cannot survive: `turnToBaseBlock(null, state, level, pos)` (9.4) |
| `getStateForPlacement` | the default state if it can survive at the clicked position; otherwise the base block's default state (a farmland placed under a solid block is placed as dirt) |

### 9.2 Random tick (moisture)

Let `m` be the current moisture.

1. `wet` = any block in the box from `pos + (-4, 0, -4)` to `pos + (4, 1, 4)` (inclusive corners, 9 x 2 x 9 cells) has a fluid state in the fluid tag `water` (this includes waterlogged blocks and flowing water), OR `level.isRainingAt(pos.above())` (33 §3).
2. If `wet`: if `m < 7` write `moisture = 7`, flags 2 (it jumps to 7, not by steps). Nothing else.
3. Otherwise (not wet): if `m > 0` write `moisture = m - 1`, flags 2. Otherwise (`m == 0`): if the block above is NOT in `maintains_farmland`, call `turnToBaseBlock(null, state, level, pos)`; if it is in the tag, nothing happens.

No random draw is made by the block itself (the random-tick selection of 33 §2.4 is the only randomness). Farmland always random-ticks (registration flag).

### 9.3 Trampling (`fallOn`)

Called when an entity lands on the block with its accumulated fall distance `d` (the call site is `Entity.checkFallDamage`, which calls `Block.fallOn(level, state, pos, entity, d)` when `d > 0`; call site details: Open question 1). On a server level farmland turns to dirt when ALL hold, tested in this order:

1. one draw `nextFloat()` from the level random is less than `d - 0.5` (so no trample at `d <= 0.5`; at `d >= 1.5` it is certain);
2. the entity is a `LivingEntity` (items, minecarts, arrows never trample);
3. permission: for a `Player`, the position is not under spawn protection (33 §6.5, `isUnderSpawnProtection(level, pos, player)`); for any other living entity, the game rule `mob_griefing` is true;
4. the entity's bounding box satisfies `width x width x height > 0.512` (a float compare; a player 0.6 x 1.8 gives 0.648, a zombie 0.6 x 1.95 gives 0.702, a chicken 0.4 x 0.7 gives 0.112). This test applies to players as well as mobs.

When all hold: `turnToBaseBlock(entity, state, level, pos)`. After that (whether or not it trampled) the generic fall damage runs: `Block.fallOn`, i.e. `Entity.causeFallDamage(d x (1 - fallDistanceReduction), 1.0, fall source)` with the original `d` (the default `fallOn` row of 24 part 5). The draw in step 1 is made first and only on a server level.

### 9.4 `turnToBaseBlock(entity, farmlandState, level, pos)`

1. `newState = Block.pushEntitiesUp(farmlandState, baseBlock.defaultBlockState(), level, pos)` (9.5).
2. `setBlockAndUpdate(pos, newState)`.
3. Game event `block_change` at `pos` with the entity (may be null) and `newState`.

### 9.5 `Block.pushEntitiesUp(oldState, newState, level, pos)`

Inputs: the old and new states at the position. Let `delta` = the part of `newState`'s collision shape that is not in `oldState`'s collision shape (boolean op ONLY_SECOND), moved to `pos`. If `delta` is empty return `newState`. Otherwise for every entity (any entity, `getEntities(null, bounds(delta))`) whose box intersects `bounds(delta)`: compute `dy` = the Y-axis collision distance of that entity's bounding box moved up by 1.0 against `delta`, limited to -1.0; then teleport the entity relatively by `(0, 1 + dy, 0)`. Return `newState`. For farmland to dirt, `delta` is the top 1 pixel (y 15 to 16), so entities that overlap that layer are lifted by their penetration depth (at most 1/16) onto the dirt surface.

## 10. Dirt path, mud, rooted dirt

### 10.1 `dirt_path` (`PathBlock`)

Base block `dirt`. Shape `column(16, 0, 15)`; `useShapeForLightOcclusion` true; not pathfindable. No random ticks.

| Trigger | Rule |
|---|---|
| `canSurvive` | the block above is not `solid`, or it is a `FenceGateBlock` (a class test, which covers every fence gate block) |
| `getStateForPlacement` | the default state if it can survive at the clicked position; else `pushEntitiesUp(defaultState, dirtDefaultState, level, pos)` (which returns the dirt state) |
| `updateShape` | direction UP and the state cannot survive: `scheduleTick(pos, dirt_path, 1)`; then the default shape update |
| scheduled tick | `turnToBaseBlock(null, state, level, pos)`: unconditional (the tick is only scheduled when it should not survive): `pushEntitiesUp(pathState, dirt, ...)` , `setBlockAndUpdate`, game event `block_change` (as 9.4) |

### 10.2 `mud` (`MudBlock`)

No state, no ticks, no growth. Collision shape `column(16, 0, 14)`; support shape and visual shape full block; shade brightness 0.2; not pathfindable (24 part 8). It is a member of tag `substrate_overworld`, so it supports vegetation.

### 10.3 `rooted_dirt` (`RootedDirtBlock`, a `BonemealableBlock`)

No ticks. Bone meal: valid when the block below is air and `pos.below()` is inside the build height; always succeeds; `performBonemeal` writes `hanging_roots` (default state) at `pos.below()` with `setBlockAndUpdate`. `getParticlePos` is `pos.below()` (so the growth particles appear below the block); the bone meal type is the default `GROWER`.

## 11. Mangrove propagule, azalea, saplings

### 11.1 `mangrove_propagule` (`MangrovePropaguleBlock extends SaplingBlock`)

State: `age` 0..4, `hanging`, `stage` 0..1 (inherited), `waterlogged`; default age 0, stage 0, not waterlogged, not hanging (24 part 1). Offset type XZ. Outline: `column(2, SHAPE_MIN_Y[i], 16)` with `SHAPE_MIN_Y = {13, 10, 7, 3, 0}` where `i` is `age` when hanging and 4 when standing.

| Rule | Behaviour |
|---|---|
| Survive | standing: block below in `supports_mangrove_propagule`; hanging: block above in `supports_hanging_mangrove_propagule` |
| Placement | the sapling placement state, `waterlogged` = fluid at the clicked position is water, `age` = 4, `hanging` false |
| `updateShape` | when waterlogged, schedule a water tick (fluid tick delay of water); when the direction is UP and the state cannot survive: air; otherwise the sapling shape update |
| Random tick | standing (not hanging): one draw `nextInt(7)`; 0: `advanceTree` (part 1 §7.1; no light test, unlike the plain sapling). Hanging: if not fully grown (`age != 4`): write `age + 1` (`cycle(age)`), flags 2 |
| Bone meal valid | hanging and fully grown: false; every other state: true (a standing propagule is always a valid target: the `canGrow` test of the sapling is not applied) |
| Bone meal success | hanging: true when not fully grown; standing: the sapling test, level random float below 0.45 |
| Bone meal effect | hanging and not fully grown: write `age + 1`, flags 2; otherwise `advanceTree` (stage 0 to 1, or `growTree` with `TreeGrower.MANGROVE`) |
| `createNewHangingPropagule(age)` | the default propagule state with `hanging` true and the given age (0 by default); used by the mangrove tree feature (35) |

### 11.2 `azalea` and `flowering_azalea` (`AzaleaBlock`)

No state properties; no random ticks; shape `column(16, 8, 16)` united with `column(4, 0, 8)` (24 part 8); not pathfindable.

| Rule | Behaviour |
|---|---|
| Survive | block below in `supports_azalea` |
| Bone meal valid | server level only; with `minH` = `TreeGrower.AZALEA.getMinimumHeight(level)` (the trunk placer base height of `azalea_tree`, 0 if unavailable): `pos.above(minH + 2)` is inside the build height AND the fluid state at `pos.above()` is empty |
| Bone meal success | level random `nextFloat() < 0.45` |
| Bone meal effect | `TreeGrower.AZALEA.growTree(level, chunkGenerator, pos, state, random)`, ignoring the result. This is the part 1 §7.3 algorithm: the grower has no mega trees and no flower variants, so one draw selects `azalea_tree` (single entry), the block is replaced by the fluid block (flags 818), the feature is placed at the block, and on failure the original block state is restored (flags 260). No stage is involved (azalea has no `stage`). |

### 11.3 Plain saplings (recap of the facts needed here)

The nine saplings share part 1 §7.1: stage 0 to 1 with flags 260, tree growth at stage 1 on a passing random tick (`maxLocalRawBrightness(pos.above()) >= 9`, then `nextInt(7) == 0`), bone meal success `P(0.45)` from the level random, bone meal valid only on a server level with `canGrow` and `pos.above(minHeight)` inside the build height. `dark_oak` and `pale_oak` saplings grow only as 2 x 2 groups (part 1 §7.4). Their constructor argument (grower) per registration was read in `Blocks`: oak, spruce, birch, jungle, acacia, cherry, dark oak, pale oak and poplar use the growers of the same names, the poplar sapling registration being the last of the series (the lambda-to-block order is (inferred), Open question 3). Shape `column(12, 0, 12)`.

## 12. Can-survive rules in one table

`updateShape` of a `VegetationBlock` turns the block into air when `canSurvive` fails after any neighbour change (the second ground check is the neighbour update; there is no scheduled tick).

| Block | Rule |
|---|---|
| wheat, carrots, potatoes, beetroots, torchflower_crop | `rawBrightness(pos, 0) >= 8` and below in `supports_crops` |
| pitcher_crop lower | `rawBrightness(pos, 0) >= 8` and below in `supports_crops`; upper: below is the lower half of this block |
| pumpkin_stem, melon_stem, attached stems | below in the block's stem support tag (farmland as shipped); no light test |
| nether_wart | below in `supports_nether_wart` (soul sand as shipped) |
| cocoa | `pos.relative(facing)` in `supports_cocoa` |
| sweet_berry_bush | below in `supports_vegetation` |
| saplings | below in `supports_vegetation` |
| mangrove_propagule | standing: below in `supports_mangrove_propagule`; hanging: above in `supports_hanging_mangrove_propagule` |
| azalea, flowering_azalea | below in `supports_azalea` |
| farmland | above not solid, or above in `maintains_farmland` |
| dirt_path | above not solid, or above a fence gate |
| mud, rooted_dirt | none (plain blocks) |

## 13. Bone meal in one table

All values are for `INTERACTION` (the player). Rows list `isValidBonemealTarget`, `isBonemealSuccess` and the effect; all random draws come from the level random.

| Block | Valid | Success | Effect |
|---|---|---|---|
| wheat, carrots, potatoes | not max age | always | age + `U(2, 5)`, capped at 7 |
| beetroots | not max age (3) | always | age + `U(2, 5) / 3`, capped at 3 (0 or 1) |
| torchflower_crop | always (age is never max) | always | age + 1; at age 1 it becomes `torchflower` |
| pitcher_crop | `canGrow` for age + 1 on the lower half | always | age + 1 (3.4 and 4.4 rules); the upper half appears at age 3 |
| pumpkin_stem, melon_stem | age != 7 | always | age + `U(2, 5)` capped at 7; when the result is 7, immediately one random tick of the new state (5.2 including its light test, growth chance draw and fruit attempt) |
| attached stems, nether wart, farmland, path, mud, pumpkin, melon | not a bone meal target | | |
| cocoa | age < 2 | always | age + 1 |
| sweet_berry_bush | age < 3 | always | age + 1 |
| rooted_dirt | air below and in build height | always | `hanging_roots` below |
| sapling | part 1 §7.1 | `P(0.45)` | `advanceTree` |
| mangrove_propagule | 11.1 | 11.1 | 11.1 |
| azalea, flowering_azalea | 11.2 | `P(0.45)` | azalea tree |

## 14. Worked examples

**14.1 Growth chance (wheat).** Wheat with hydrated farmland (moisture > 0) under it and under all eight neighbours, no wheat beside it: speed = 1 + 3 + 8 x (3 / 4) = 10.0; `int(25.0f / 10.0f) + 1` = 3; the plant advances with probability 1/3 per random tick that passes the light test (`rawBrightness(pos, 0) >= 9`). Dry farmland under the centre only (moisture 0): speed = 1 + 1 = 2.0; `int(12.5) + 1` = 13: 1/13. Hydrated centre only: speed 4.0, `int(6.25) + 1` = 7: 1/7. The 3 x 3 hydrated case with wheat to the west and to the north (so the row test `alongX` and `alongZ` both hold): speed 10.0 / 2 = 5.0, `int(5.0) + 1` = 6: 1/6. A beetroot in the 3 x 3 hydrated case: first `nextInt(3)` must be nonzero (2/3), then 1/3: overall 2/9 per random tick, at age 0 to 2.

**14.2 Beetroot bone meal.** Age 1: the draw `U(2, 5)` gives 2, 3, 4 or 5 with equal probability 1/4; divided by 3 gives 0, 1, 1, 1; so the new age is 1 (probability 1/4) or 2 (3/4). At age 2 a result of 1 gives age 3 (mature).

**14.3 Pitcher crop.** A lower half age 2 at P with `rawBrightness >= 8` and air at P + 1: bone meal is valid (`canGrow` for age 3: not max age, light ok, P + 1 inside the build height, `canGrowInto(P + 1)` air). Effect: lower becomes age 3 (flags 2), P + 1 becomes pitcher crop age 3 `upper` with flags 3. Shape: lower `column(10, -1, 16)`, upper `column(10, 0, 11)`; collision lower `column(10, -1, 5)`, upper empty. Bone meal clicked on the upper half (age 3): `getLowerHalf` goes to P; `canGrow` for age 4 with `canGrowInto(P + 1)` true because the cell is already the pitcher crop; both halves become age 4. Bone meal on a block at P + 1 that is not air and not a pitcher crop (for example a stone block) at age 2: not valid, the item is not consumed.

**14.4 Stem fruit.** Mature pumpkin stem (age 7) at S, light 12 at S, farmland all around. A tick passes the growth draw. `nextInt(4)` returns 2 (SOUTH). Target T = S + (0, 0, 1); T is air and the block below T is grass (in `supports_stem_fruit`, which is `supports_vegetation`, which includes grass blocks): a pumpkin is placed at T (flags 3) and the stem becomes `attached_pumpkin_stem` with `facing = south` (flags 3). If T were stone instead, nothing happens, and the next qualifying tick tries again with a new random direction. Bone meal on an age-5 stem with `U(2, 5)` = 3: age becomes 7 (min(7, 8)); because the result is 7 a random tick of the age-7 state runs now: light (>= 9), the growth chance draw (the same `1/(int(25/speed)+1)`), and only then the fruit attempt, so the immediate tick may place nothing.

**14.5 Attached stem reverts.** A pumpkin at T south of an attached stem facing south is broken. The neighbour update arrives at the stem from direction SOUTH; the new neighbour state is air (not the fruit) and the direction equals `facing`: the stem's `updateShape` returns `pumpkin_stem` with `age` 7. Breaking a different neighbour (north side) leaves it unchanged.

**14.6 Farmland.** Moisture 3, no water within 4 blocks (box of 9 x 2 x 9), not raining, a wheat crop above: random tick sets moisture 2, then 1, then 0 over three ticks; at 0 the next tick does nothing, because wheat is in `maintains_farmland`. If the crop is removed (air above): the next tick at moisture 0 turns the farmland to dirt (`pushEntitiesUp`, flags 3, `block_change`). With water 4 blocks away horizontally at the same Y or one above: the first tick sets moisture 7. If a stone block is placed above the farmland: the neighbour update at direction UP schedules a tick after 1 game tick, the tick finds `canSurvive` false and turns it to dirt.

**14.7 Trampling.** A player falls 1.0 block onto farmland outside spawn protection: the draw `nextFloat()` must be below 0.5: 50 percent. A fall of 0.4: never trampled but takes the normal fall damage rules. A sheep (0.9 x 0.9 x 1.3 = 1.053 > 0.512) falling 2.0 with `mob_griefing` true: `nextFloat() < 1.5` always, trampled; with `mob_griefing` false: never.

**14.8 Sweet berry bush.** A player walks through an age-3 bush at 0.2 blocks per tick horizontal: each time `entityInside` runs on the server: slowed by (0.8, 0.75, 0.8) and hurt for 1.0 (|v.x| >= 0.003). Standing still: slowed only. A fox: nothing at all. Right-click on the bush at age 2 with an empty hand: loot is dropped (data: 1 to 2 berries), the pick sound plays, the age becomes 1; at age 1 right-click does nothing (PASS); at age 3 with bone meal in hand: `useItemOn` does not return PASS (the age is 3), so the default applies and the click reaches `useWithoutItem`, which harvests; at age 2 with bone meal in hand: `useItemOn` returns PASS, the bone meal item is used (age 2 to 3) and no harvest happens.

**14.9 Torchflower.** `torchflower_crop` age 1 with a passing growth draw: `getStateForAge(2)` yields `torchflower`, so the crop block is replaced by the flower block with flags 2 (no neighbour update). Bone meal on an age-0 crop: age 1; on age 1: the flower.

## 15. Validation

A test suite for this part can check the following, each derived from the text above:

1. `getGrowthSpeed` values: centre-only dry 2.0, centre-only hydrated 4.0, full 3 x 3 hydrated 10.0, full 3 x 3 dry 4.0, halved by a neighbouring crop on both axes or on a diagonal; chance `1/(int(25/speed) + 1)` = 1/13, 1/7, 1/3, 1/7 (for speed 4.0 on the dry full square: `int(6.25) + 1` = 7) respectively.
2. Crop ages and shapes: wheat 8 shapes of height 2..16 step 2; carrots and potatoes 8 shapes of height 2..9 step 1; beetroots 4 shapes 2..8 step 2; torchflower 2 shapes 6 and 10 with width 6; pitcher shapes of 4.2.
3. Beetroot and torchflower: the first `nextInt(3)` draw gates the tick (value 0 skips); beetroot bone meal increments from `{0, 1, 1, 1}`; torchflower age 1 grows into `torchflower`.
4. Pitcher: no upper half for age < 3; `canGrow` conditions; lower and upper `age` equal after growth; creative breaking of the upper half removes the lower half with flags 35.
5. Stem tick order: light < 9 stops without draw; the growth draw; age below 7 increments; age 7 uses `nextInt(4)` index into NORTH, EAST, SOUTH, WEST; the fruit and the attached stem are written in that order with flags 3.
6. Attached stem becomes `age 7` stem when the neighbour at `facing` is changed to a non-fruit.
7. Nether wart: 1/10 per tick, no growth at age 3, never random-ticks at age 3, soul sand only (as shipped), no bone meal.
8. Cocoa: 1/5 per tick, no light test, `supports_cocoa` at `facing`.
9. Sweet berry: 1/5 then light >= 9 at `pos.above()`; harvest at age >= 2 sets age 1; damage only when horizontal movement component >= 0.003 and age > 0; fox and bee exempt.
10. Farmland: 9 x 2 x 9 water box; rain test at `pos.above()`; jump to 7; decrement by 1; dehydrated farmland with no listed block above turns to dirt; solid unlisted block above turns it to dirt after a 1-tick scheduled tick; trample probability `nextFloat() < d - 0.5`.
11. Path: tick always converts to dirt; survive rule with fence gates; placement under a solid block gives dirt.
12. Rooted dirt bone meal places `hanging_roots` only into air below.
13. Azalea: bone meal needs height `minH + 2` inside the build height and empty fluid above; success 0.45.
14. Mangrove propagule: standing tick `1/7` with no light test; hanging tick advances age to 4 and stops; bone meal always valid unless hanging and age 4.

## 16. Open questions

1. `Entity.checkFallDamage` calls `Block.fallOn` with the fall distance when the distance is above 0 (inferred from the instruction pattern read: a double compare against zero before the call); the accumulation of the fall distance and the call context (which position is passed for a feet-on-block landing) belong to 18 and were not read here.
2. `Entity.makeStuckInBlock` (the slowdown vector application and its reset) and the frequency with which `entityInside` is called per tick are specified (or not) in 18 §2.6; only the arguments were read here.
3. The mapping of the sapling registrations to growers was read from the lambda bodies in `Blocks` and their position in the registration series; the poplar sapling is registered after the mangrove propagule and uses the last lambda of the series (inferred by order, not by a named link).
4. The loot tables cited (stem seed counts, wheat, nether wart, sweet berry harvest, carved pumpkin) are DATA and were read only to illustrate (26); their exact conditions are the data pack's.
5. The behaviour of `torchflower` (the fully grown flower) and of `hanging_roots`, the blocks the engines write, is outside this document.
6. The placement path of the pitcher pod item and of seeds (which `BlockItem` subclass and which `getStateForPlacement` call, including the `canSurvive` check) is in 29 §9 and 25; it was not re-read.
7. The `BonemealSource.MOB` path (bees) was not read: the crop rules above are written for `INTERACTION`, and the classes read take no branch on the source, except that `MangrovePropaguleBlock` receives it (its methods read in this round make no source test) (part 1 Open question 7).
8. Which sounds and events accompany growth (the bone meal level event 1505) is 29b part 1 §5.3 and 42; plant block sounds are 24 registry columns.
9. The "otherwise" row of the `isSolid` cascade (24 part 1 Open question 16) decides whether farmland and paths survive under partial blocks; the value is inferred false there.
10. `DoublePlantBlock.getSeed` (the rendering-offset seed helper, both halves hash the lower position) was read; whether the pitcher crop uses it depends on an offset type the registration does not set, so it is (inferred) unused here.
11. `Block.pushEntitiesUp` was read to the extent given in 9.5 (the collide-up and relative teleport); the exact collision routine (`Shapes.collide`) is a physics helper not read here.
12. Part 1 §6 lists one shape formula for all crops and the 33 table row for `FarmlandBlock.fallOn` ("non-player entities") states the volume test applies to non-player entities only; this document records that the volume test applies to players too (9.3 step 4); those statements should be reconciled when the documents are next revised.
