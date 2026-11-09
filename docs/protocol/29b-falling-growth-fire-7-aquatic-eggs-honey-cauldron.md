# 29b. Falling blocks, growth, fire and similar block behaviours, part 7: corals, eggs, frogspawn, honey, beehive, cauldrons, candles and cakes

| | |
|---|---|
| Covers | Coral blocks, plants, fans and wall fans (alive and dead: dying out of water, the scheduled die tick, placement, support, waterlogging, shapes); the turtle egg block (stages, trampling, random tick, breaking, hatching); the sniffer egg block (hatch time, moss boost, hatching); frogspawn (survival, hatch delay, tadpoles); the honey block (slide, landing, wall sliding hook); the beehive and bee nest block-side rules (honey level, harvest with shears or bottle, smoke, anger, drops); the cauldron family (`AbstractCauldronBlock`, `CauldronBlock`, `LayeredCauldronBlock`, `LavaCauldronBlock`, the `CauldronInteractions` tables, precipitation fill, stalactite fill, extinguishing entities, shapes, comparator output); candles, candle cakes and cakes (lighting, extinguishing, candle count, bites); soul sand and magma block (hooks read); the lightning rod tick (pointer to 29b part 3) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS11 (GAP-10b of `../design/README.md` Part 5), part 7 |
| Data versus code | Block loot tables (`harvest_beehive`, candle, candle cake, cake drops), the block tags (`sand`, `sniffer_egg_hatch_boost`, `supports_frogspawn`, `candles`, `candle_cakes`, `impermeable`), the fluid tags (`water`, `supports_frogspawn`), the item tags (`candles`, `cauldron_can_remove_dye`), the enchantment tag `prevents_bee_spawns_when_mining`, the environment attribute `turtle_egg_hatch_chance` and the registry rows (ids, properties, light, sounds, map colours) are DATA or registry rows (22, 23, 24, 26). This document specifies the engines that interpret them and every code-defined rule. |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions. Block names are registry names (24 parts 1 to 8). The record vocabulary (trigger kinds PL, ST, RT, NC, US and so on, probability notation, flags) is that of 29b part 1 section 2; this part writes behaviour as short tables and numbered steps in the same terms. A random draw written `nextInt(n)` is uniform in [0, n); `nextInt(a, b)` is `a + nextInt(b - a)` (read in `RandomSource.nextInt(II)`).

## 0. Reader's map

| Question | Section |
|---|---|
| What belongs here, what is elsewhere, flags | 1 |
| Corals (40 blocks), die rule, scheduled tick, support, shapes | 2 |
| Turtle egg | 3 |
| Sniffer egg | 4 |
| Frogspawn | 5 |
| Honey block | 6 |
| Beehive and bee nest, block side | 7 |
| Cauldrons, interactions, precipitation, drip fill | 8 |
| Candles, candle cakes, cake | 9 |
| Soul sand, magma, lightning rod | 10 |
| Worked examples | 11 |
| Validation | 12 |
| Open questions | 13 |

## 1. Scope and cross-references

### 1.1 Not repeated here (owners)

| Topic | Owner |
|---|---|
| Registry rows: ids, state ids, light, sounds, map colours, hardness | 24 (coral blocks in part 8, turtle egg and sniffer egg in part 6, cake and cauldron in parts 3 and 4, honey, candles and beehive in parts 5, 7 and 8) |
| Shape helper definitions (`column`, `box`, `boxZ`, `rotateHorizontal`) | 24 part 1 section 6 |
| `BeehiveBlockEntity` (occupants, release, `emptyAllLivingFromHive` internals, the bee AI) | 31 part 4 |
| The level-tick precipitation step that calls `handlePrecipitation` (column draw, biome precipitation) | 33 section 4 (it already lists the two fill chances read again in 8.7) |
| Fluid ticks, `placeLiquid` callers, `SimpleWaterloggedBlock`, bucket pickup | 29a, 25 part 5 |
| `InsideBlockEffectApplier` ordering and the `EXTINGUISH`, `CLEAR_FREEZE`, `LAVA_IGNITE` effect types | 29a, 44 part 1 section 4.3 (RQ-1.8 entry 'Fire extinguishing and block effects') |
| Block speed factor and jump factor of honey and soul sand | 44 part 1 RQ-1.9, 13 |
| Honey block slide formulas (read again here, agree) | 44 part x1 section 2.1 |
| Turtle and sniffer mob rules, egg laying goals | 44 part 4, 19 |
| Bubble columns over soul sand and magma | 44 part x1 section 2.3 |
| Flint and steel and fire charge lighting of candles and candle cakes | 17 section 3.3 (the Flint and steel bullet; 17 section 3.3a is the flammability table and fire tick constants) |
| Magma block damage and lightning rod strike, power and spark | 29b part 3 section 10.3 and section 9.2 (re-read here, section 10) |
| Pointed dripstone growth, its own random tick, `findTip`, `findRootBlock` | 29b part 6 section 7 (fluid, cauldron, mud, damage) and section 8 (the cauldron side); 8.6 restates only what the cauldron needs and agrees with it (0.17578125 water, 0.05859375 lava, search length 11, delay 50 plus the fall height, level events 1504, 1046, 1047, mud to clay) |
| Weathering copper variants of the lightning rod | 29b part 5 |
| Particles and sounds (names only here) | 42, 21 |
| Advancement triggers and statistics named in the tables | the advancement round; only the names are given |

### 1.2 Flags and helpers used

| Name | Meaning |
|---|---|
| `setBlock(pos, state, 2)` | flags 2: send to clients, no neighbour update (29 section 1) |
| `setBlockAndUpdate` | flags 3 |
| `setLit` | `setBlock(pos, state with lit, 11)` |
| `removeBlock(pos, false)` | remove with the "moved by piston" argument false, no drop |
| `destroyBlock(pos, false)` | remove with the block-destroy effect (level event 2001 and the drop path of 29 section 7); the boolean is "drop items" and is false everywhere in this part |
| `scheduleTick(pos, block, d)` | block tick `d` ticks from now |
| scheduled fluid tick | `scheduleTick(pos, WATER, WATER.getTickDelay(level))`; the delay is 5 (29a) |
| `canSupportCenter(level, pos, UP)`, `isFaceSturdy` | the support tests of 24 part 1 section 6 |

### 1.3 Block to section

| Registry blocks | Class (read) | Section |
|---|---|---|
| `tube_coral_block`, `brain_coral_block`, `bubble_coral_block`, `fire_coral_block`, `horn_coral_block` | `CoralBlock` | 2.3 |
| `<kind>_coral` (5) | `CoralPlantBlock` | 2.4 |
| `<kind>_coral_fan` (5) | `CoralFanBlock` | 2.5 |
| `<kind>_coral_wall_fan` (5) | `CoralWallFanBlock` | 2.6 |
| `dead_<kind>_coral_block` (5) | plain `Block` (no behaviour) | 2.2 |
| `dead_<kind>_coral` (5) | `BaseCoralPlantBlock` | 2.4 |
| `dead_<kind>_coral_fan` (5) | `BaseCoralFanBlock` | 2.5 |
| `dead_<kind>_coral_wall_fan` (5) | `BaseCoralWallFanBlock` | 2.6 |
| `turtle_egg` | `TurtleEggBlock` | 3 |
| `sniffer_egg` | `SnifferEggBlock` | 4 |
| `frogspawn` | `FrogspawnBlock` | 5 |
| `honey_block` | `HoneyBlock extends HalfTransparentBlock` | 6 |
| `beehive`, `bee_nest` | `BeehiveBlock extends BaseEntityBlock` (same class, different properties) | 7 |
| `cauldron` | `CauldronBlock` | 8.2 |
| `water_cauldron`, `powder_snow_cauldron` | `LayeredCauldronBlock` | 8.3 |
| `lava_cauldron` | `LavaCauldronBlock` | 8.4 |
| the 16 `<colour>_candle` and `candle` | `CandleBlock` | 9.2 |
| the `<colour>_candle_cake` and `candle_cake` | `CandleCakeBlock` | 9.3 |
| `cake` | `CakeBlock` | 9.4 |
| `soul_sand` | `SoulSandBlock` | 10.1 |
| `magma_block` | `MagmaBlock` | 10.2 |
| `lightning_rod` and waxed | `LightningRodBlock` | 10.3 |

The request text speaks of "14 coral types by dead/alive"; the artifact has 5 species (tube, brain, bubble, fire, horn) times 4 forms (block, plant, fan, wall fan) times 2 states (alive, dead) = 40 registry blocks. Every alive block is built with its dead counterpart of the same species and form as a constructor argument (read in the `Blocks` lambdas: the alive `X` takes `dead_X`).

## 2. Corals

### 2.1 Shared rules

Dying: an alive coral block, plant, fan or wall fan turns into its dead counterpart when it has no water around it. The water test and the timer are shared (`BaseCoralPlantTypeBlock`, `CoralBlock`).

| Quantity | Value (read) |
|---|---|
| Die tick delay | `60 + nextInt(40)`, so 60 to 99 ticks, a block tick of the coral block itself |
| Replacement write | `setBlock(pos, dead state, 2)` (flags 2) |
| Water test, plant types (`BaseCoralPlantTypeBlock.scanForWater(state, level, pos)`) | true when `waterlogged` is true, or when the fluid at any of the 6 neighbours is in the fluid tag `water` |
| Water test, coral block (`CoralBlock.scanForWater(level, pos)`) | true when the fluid at any of the 6 neighbours is in the fluid tag `water` (the coral block has no waterlogged property) |
| Die schedule rule (`tryScheduleDieTick`) | if the water test is false, `scheduleTick(pos, this block, 60 + nextInt(40))`; if true nothing is scheduled. Called with the level's own random source of the call site (the placing level's random in PL, the update's random in ST) |
| Duplicate scheduling | the engine de-duplicates a scheduled tick of the same block at the same position (29 section 3); repeated ST calls therefore do not stack |

The tick itself re-tests the water: if the water test is now true nothing happens (no reschedule: the coral stays alive until the next ST call finds it dry again); otherwise the dead state is written.

### 2.2 Dead coral blocks and registry properties

`dead_<kind>_coral_block` is a plain block with no ticks, registered (read in `Blocks`) with map colour gray, `forceSolidOn`, the BASEDRUM note block instrument, `requiresCorrectToolForDrops` and strength 1.5 / 6.0 (hardness / resistance). The alive coral blocks use the coral block sound, `requiresCorrectToolForDrops` and the same strength, without `forceSolidOn` (24 part 8 holds the rows). Dead plants, fans and wall fans have no tick and no die rule; they keep `waterlogged` and (wall fan) `facing`. A dead wall fan has the same shape, support and update rules as the alive one without the die schedule (2.6). Registry rows, map colours (alive: tube blue, brain pink, bubble purple, fire red, horn yellow; dead: gray) and sounds (coral block sound for blocks, wet grass for plants and fans) are in 24 part 8.

### 2.3 `CoralBlock` (5 alive blocks)

| Trigger | Rule |
|---|---|
| PL via `getStateForPlacement` | if the water test (2.1) is false: `scheduleTick(pos, this, 60 + nextInt(40))` using the level's random; result is the default state. Note the schedule happens in the placement query, not in `onPlace` |
| ST (`updateShape`) | if the water test at `pos` is false: `scheduleTick(pos, this, 60 + nextInt(40))` (random = the update's random); then the default `Block.updateShape` (no change of state) |
| BT (`tick`) | if the water test is false: `setBlock(pos, dead_<kind>_coral_block default state, 2)` |

### 2.4 `CoralPlantBlock` and `BaseCoralPlantBlock` (property `waterlogged`, default true)

Common to all plant-type blocks (`BaseCoralPlantTypeBlock`, base of plants, fans and wall fans):

| Item | Rule |
|---|---|
| Properties | `waterlogged` (default true) |
| Placement state (`getStateForPlacement`) | default state with `waterlogged` = (fluid at the clicked position is in tag `water` and `isFull()`); no die schedule here (the alive blocks schedule in `onPlace`) |
| Fluid state | `WATER.getSource(false)` when waterlogged, else the default |
| Support (`canSurvive`) | the block below `pos` has a sturdy UP face (`isFaceSturdy(level, pos.below(), UP)`) |
| Shape | `Block.column(12, 0, 4)` for fans (see 2.5), `column(12, 0, 15)` for plants |

`CoralPlantBlock` (alive plant):

| Trigger | Rule |
|---|---|
| PL (`onPlace`) | `tryScheduleDieTick(state, level, level, random, pos)` |
| ST (`updateShape`), in order | (1) if `direction == DOWN` and `!canSurvive`: return air; (2) `tryScheduleDieTick`; (3) if waterlogged: schedule a fluid tick; (4) the base `BaseCoralPlantTypeBlock.updateShape`, which repeats the DOWN survive test and the waterlogged fluid tick (a second identical fluid tick request, which the scheduler ignores) |
| BT | if the plant water test (2.1) is false: write the dead plant's default state with `waterlogged = false` (flags 2). (Dry means not waterlogged and no adjacent water, so `false` is the state the test already implies.) |

`BaseCoralPlantBlock` (dead plant): the base rules only (placement, support, fluid, ST: waterlogged fluid tick, DOWN survive test).

### 2.5 `CoralFanBlock` and `BaseCoralFanBlock` (floor fans)

Same as 2.4 with the fan shape and the dead-state write of `CoralFanBlock.tick` (the dead fan default state with `waterlogged = false`). `CoralFanBlock.updateShape` runs the same four steps as `CoralPlantBlock`. Shape (`BaseCoralFanBlock.SHAPE`): `column(12, 0, 4)`, a 12 by 12 footprint 4 high (read; the fan's visual height is the model's business).

### 2.6 `CoralWallFanBlock` and `BaseCoralWallFanBlock`

| Item | Rule |
|---|---|
| Properties | `facing` (horizontal, default north) and `waterlogged` (default true) |
| Shape | for the north orientation `boxZ(16, 8, 5, 16)`, which by the helper definition (24 part 1 section 6: 5-argument form `box(8 - a/2, y0, z0, 8 + a/2, y1, z1)`, with the 4-argument form centring y) is the box x 0 to 16, y 4 to 12, z 5 to 16 in pixels; the other three orientations are `Shapes.rotateHorizontal` of it (south is z 0 to 11; east and west rotate x and z) |
| Support (`canSurvive`) | the block at `pos.relative(facing.opposite)` has a sturdy face toward `facing` |
| Placement | start from the plant-type placement (waterlogged by fluid); then iterate `getNearestLookingDirections()` in order, skipping vertical directions: take `facing = lookDirection.opposite`; the first candidate for which `canSurvive` is true is the result; if none, no placement (null) |
| `rotate`, `mirror` | `facing` rotated by the rotation; mirror = rotation of the mirror's rotation of `facing` |
| ST (`updateShape`), alive | in order: if `direction.opposite == facing` and `!canSurvive`: return air; if waterlogged: schedule a fluid tick; `tryScheduleDieTick`; then the base update (which repeats the fluid tick and the survive test) |
| ST, dead (`BaseCoralWallFanBlock`) | the same without the die schedule: fluid tick when waterlogged, then air when `direction.opposite == facing` and `!canSurvive` |
| PL, BT (alive) | as 2.4. The dead state written keeps the same `facing`, with `waterlogged = false` (flags 2) |

## 3. Turtle egg (`TurtleEggBlock`)

Properties `hatch` (0 to 2, default 0) and `eggs` (1 to 4, default 1). Registry: random ticks enabled, `pushReaction` POPPED, `noOcclusion` (24 part 6). Shape: `eggs == 1`: `box(3, 0, 3, 12, 7, 12)`; `eggs > 1`: `column(14, 0, 7)`.

### 3.1 Rules

| Trigger | Rule |
|---|---|
| PL (`onPlace`) | if the block below is in the block tag `sand` and the level is the server: level event **2012** at `pos` with data 15 (bone-meal-style particles, 42) |
| RT (`randomTick`) | see 3.2 |
| Placement (`getStateForPlacement`) | if the clicked position already holds a turtle egg: that state with `eggs = min(4, eggs + 1)`; otherwise the default |
| Replaceable (`canBeReplaced`) | true when the placer is not using secondary use, the held item is the turtle egg item, and `eggs < 4`; else the default rule |
| Walked on (`stepOn`) | if the entity is not stepping carefully (`isSteppingCarefully`, i.e. sneaking): `destroyEgg(chance 100)`; then the default |
| Landed on (`fallOn`) | if the entity is not a `Zombie`: `destroyEgg(chance 3)`; then the default (fall damage as usual) |
| Mined by a player (`playerDestroy`) | the default (drops, 26), then `decreaseEggs` (3.3) |

### 3.2 Random tick

1. Draw the hatch gate: read the environment attribute `turtle_egg_hatch_chance` (float, range [0,1], default 0.002, read in `EnvironmentAttributes`) at `pos` (23, data). The day timeline `day.json` entry `gameplay/turtle_egg_hatch_chance` has ease `constant` and modifier `maximum`, so the effective value is max(0.002, track value); the track repeats with the day period: 0.002 before tick 21062, 1.0 from 21062 to 21904, 0.002 from 21905 on (read; 19 section 12 also says maximum; see also 33 section 3.4; the value 0 does not occur in that track). `gate` is true when the value `c > 0` and `random.nextFloat() < c` (the float is drawn only when `c > 0`; the level random is used).
2. Continue only if `gate` and the block below is in the tag `sand` (the gate is evaluated first, so the random draw happens even when the egg is not on sand).
3. If `hatch < 2`: play `turtle_egg_crack` (BLOCKS, volume 0.7, pitch `0.9 + random.nextFloat() * 0.2`), `setBlock(pos, hatch + 1, 2)`, game event `block_change` (context: the old state).
4. Else (`hatch == 2`): play `turtle_egg_hatch` (volume 0.7, same pitch rule), `removeBlock(pos, false)`, game event `block_destroy`; then for `i = 0 .. eggs - 1`: level event 2001 at `pos` with the block state id; create a `turtle` (spawn reason BREEDING); set age `-24000`; set its home to `pos`; place it at `(x + 0.3 + i * 0.2, y, z + 0.3)` with yaw 0 and pitch 0; add it to the level.

Re-run of `onPlace` (read in `LevelChunk.setBlockState`): the chunk calls `BlockState.onPlace` whenever the level is not the client and the flags do not contain 512, even when the old and the new state belong to the same block. Flags 2 therefore re-run it. Consequence: every `hatch` change (step 3) re-runs `TurtleEggBlock.onPlace`, so level event 2012 (data 15) fires again at each crack stage when the block below is sand.

The pitch random call comes after the volume constant in the argument order; the level uses a single random for step 1, the sound pitches and none else (the spawn positions use no random).

### 3.3 `destroyEgg(entity, chance)` and `decreaseEggs`

`destroyEgg`: proceeds only when the state is a turtle egg and the level is the server and `canDestroyEgg` is true and `random.nextInt(chance) == 0` (the level's random; for `chance` 100 that is 1 in 100 per call of `stepOn`, for 3 it is 1 in 3).

`canDestroyEgg(entity)`, in order: a `Turtle` or a `Bat` returns false; a `Player` returns `!server.isUnderSpawnProtection(level, pos, player)`; any other `LivingEntity` returns the game rule `mob_griefing`; any other entity returns false.

`decreaseEggs(pos, state)`: play `turtle_egg_break` (BLOCKS, 0.7, `0.9 + nextFloat * 0.2`); if `eggs <= 1`: `destroyBlock(pos, false)`; else `setBlock(pos, eggs - 1, 2)`, game event `block_destroy`, level event 2001 with the state id (of the old state).

This agrees with 24 part 6 (turtle egg paragraph) and 44 part 4; the point of this section is the complete list.

## 4. Sniffer egg (`SnifferEggBlock`)

Property `hatch` 0 to 2 (default 0). Shape `column(14, 12, 0, 16)` as written in the artifact: 14 wide in x, 12 in z, 0 to 16 high (read: four arguments 14, 12, 0, 16). Not pathfindable. Registry: no random ticks (the egg uses scheduled ticks only). Constants: `REGULAR_HATCH_TIME_TICKS` 24000, `BOOSTED_HATCH_TIME_TICKS` 12000, `RANDOM_HATCH_OFFSET_TICKS` 300.

| Trigger | Rule |
|---|---|
| PL (`onPlace`) | `boost` = the block below is in tag `sniffer_egg_hatch_boost` (moss block). On the server and `boost`: level event **3009** at `pos`, data 0. `total = boost ? 12000 : 24000`; `stage = total / 3` (integer: 4000 or 8000); game event `block_place`; `scheduleTick(pos, this, stage + nextInt(300))` |
| BT (`tick`) | if `hatch != 2` (not ready): play `sniffer_egg_crack` (BLOCKS, 0.7, `0.9 + nextFloat * 0.2`), `setBlock(pos, hatch + 1, 2)` (the next stage tick is **not** scheduled here: see below). Else: play `sniffer_egg_hatch`, `destroyBlock(pos, false)`, create a `sniffer` (BREEDING), `setBaby(true)`, `snapTo(centre of pos, yaw = wrapDegrees(nextFloat * 360), pitch 0)`, add it |

The bytecode of the tick writes the new `hatch` and returns; the continuing schedule comes from the `setBlock` itself: the block's state changed to the same block, which re-runs `onPlace` (read in `LevelChunk.setBlockState`: `onPlace` is called on a non-client level whenever the flags lack 512, also for the same block; see 3.2) and therefore re-schedules the next stage with the same formula. Consequence read from the same fact: every stage change also re-runs the level event 3009 (when on moss) and the `block_place` game event of `onPlace`.

Timing: moss: three stages of `4000 + nextInt(300)` ticks each (hatch 0 to 1, 1 to 2, then the hatch tick), 12000 to 12897 ticks in all; otherwise 8000 + nextInt(300) per stage. 44 part 4 reaches the same numbers.

## 5. Frogspawn (`FrogspawnBlock`)

No properties. Shape `column(16, 0, 1.5)` (a 1.5 pixel high film). Registry: instabreak, no collision, `noOcclusion`, POPPED, frogspawn sound. Constants: default hatch delay 3600 to 12000, tadpoles 2 to 5.

| Trigger | Rule |
|---|---|
| Support (`canSurvive`, `mayPlaceOn(level, pos.below())`) | true when (the fluid at `pos.below()` is in fluid tag `supports_frogspawn` (water) **or** the block at `pos.below()` is in block tag `supports_frogspawn`) **and** the fluid at `pos.above()` is empty |
| PL (`onPlace`) | `scheduleTick(pos, this, nextInt(minHatchDelay, maxHatchDelay))` = `3600 + nextInt(8400)`, 3600 to 11999 |
| ST (`updateShape`) | if `!canSurvive`: air; else default |
| BT (`tick`) | if `!canSurvive`: `destroyBlock(pos, false)`; else `hatchFrogspawn` |
| Entity inside (`entityInside`) | if the entity is a falling block entity: `destroyBlock(pos, false)` |

`hatchFrogspawn`: `destroyBlock(pos, false)`; play `frogspawn_hatch` (BLOCKS, 1.0, 1.0); `spawnTadpoles`. `spawnTadpoles`: `n = nextInt(2, 6)` (2 to 5); for each of `n`: create a `tadpole` (BREEDING); `x = pos.x + offset`, `z = pos.z + offset` (two separate draws, x first), `yaw = nextInt(1, 361)` (1 to 360, drawn after both offsets), `y = pos.y - 0.5`; `snapTo(x, y, z, yaw, 0)`; `setPersistenceRequired`; add. `offset = clamp(nextDouble(), 0.2, 0.8)` (the constant 0.2 is the float 0.2 widened, 0.20000000298023224, read; 0.8 is 0.7999999970197678, read).

The hatch delay values are static fields changed only by `setHatchDelay` and reset by `setDefaultHatchDelay` (used by the game-test harness; no gameplay caller is in the block class).

## 6. Honey block (`HoneyBlock`)

Registry (24): speed factor 0.4, jump factor 0.5, `noOcclusion`, honey block sound; map colour orange. Collision shape `column(14, 0, 15)`; the outline and support shape is the default full block (the class overrides only the collision shape; read), as for soul sand in 10.1. The friction of the block is the default; the speed and jump factors are applied by the entity engine (44 part 1 RQ-1.9). Constants read: slide starts when vertical speed is at least 0.13, minimum fall speed to count as sliding 0.08, throttled slide speed 0.05, achievement check every 20 ticks.

### 6.1 Which entities slide (`doesEntityDoHoneyBlockSlideEffects`)

A `LivingEntity`, an `AbstractMinecart`, a `PrimedTnt` or an `AbstractBoat`.

### 6.2 Sliding test (`isSlidingDown(pos, entity)`)

All must hold (any failure: not sliding):

1. the entity is not on the ground;
2. `entity.y <= pos.y + 0.9375 - 1.0E-7`;
3. `oldDeltaY(vy) < -0.08` where `oldDeltaY(v) = v / 0.98 + 0.08` (the divisor is the double 0.9800000190734863, the float 0.98 widened; 0.08 is the double 0.08; read) and `vy` is the entity's current vertical velocity;
4. `dx = |pos.x + 0.5 - entity.x|`, `dz = |pos.z + 0.5 - entity.z|`, `w = 0.4375 + entity.bbWidth / 2`: `dx + 1.0E-7 > w` **or** `dz + 1.0E-7 > w` (the entity hangs outside the centre column, i.e. against a side).

### 6.3 `entityInside`

If sliding: (a) if the entity is a server player and `level.gameTime % 20 == 0`, trigger the advancement criterion `honey_block_slide` with the block state at the entity's position; (b) slide movement; (c) slide effects. Then the base `entityInside`.

Slide movement (`doSlideMovement`): let `v` be the velocity and `o = oldDeltaY(v.y)`. If `o < -0.13`: `f = -0.05 / o`; new velocity `(v.x * f, newDeltaY(-0.05), v.z * f)`. Otherwise `(v.x, newDeltaY(-0.05), v.z)`. Then reset the fall distance. `newDeltaY(u) = (u - 0.08) * 0.98` (multiplier again the double 0.9800000190734863; the constants -0.05 and -0.13 are doubles; implement bit-exact with these doubles), so `newDeltaY(-0.05) = -0.1274`.

Slide effects (`maybeDoSlideEffects`, only for entities of 6.1): with `random.nextInt(5) == 0` play `honey_block_slide` (volume 1, pitch 1) on the entity (both sides); on the server only, with an independent `nextInt(5) == 0`, broadcast entity event **53** (5 honey block particles at the entity, client, 42).

### 6.4 Landing (`fallOn`)

Play `honey_block_slide` (1, 1) on the entity; on the server broadcast entity event **54** (10 particles); call `causeFallDamage(fallDistance, damageMultiplier 0.2, fall damage source)`; if that returns true (damage was dealt) play the block sound type's fall sound on the entity with volume `soundType.volume * 0.5` and pitch `soundType.pitch * 0.75`.

## 7. Beehive and bee nest (`BeehiveBlock`, block side)

Properties `facing` (horizontal, default north) and `honey_level` (0 to 5, default 0); `MAX_HONEY_LEVELS` 5. Block entity `BeehiveBlockEntity` (31 part 4), ticked on the server only. Analog output: `honey_level`. Placement: `facing` = the opposite of the placer's horizontal direction. Registry: `bee_nest` hardness 0.3, `beehive` 0.6, both wood sound, ignited by lava (24 part 7).

### 7.1 Interactions with an item (`useItemOn`)

Let `lvl = honey_level`, `done = false`. If `lvl >= 5`:

| Held item | Effect |
|---|---|
| shears (server only) | `dropHoneycomb(level, stack, state, blockEntity, player, pos)`: roll the block-interact loot table `harvest_beehive` at `pos` (26; 3 `honeycomb`); play `beehive_shear` (BLOCKS, 1.0, 1.0) at the player position; `stack.hurtAndBreak(1, player, hand slot)`; game event `shear` (context: the player and the state); `done = true` |
| glass bottle (both sides) | `stack.shrink(1)`; play `bottle_fill` at the player position (BLOCKS, 1.0, 1.0); if the stack is now empty put a `honey_bottle` in that hand, else `inventory.add(honey_bottle)` and when that fails `player.drop(honey_bottle, false, predicted)` (a third argument, a prediction marker, exists); game event `fluid_pickup`; `done = true` |

If `!client` and `done`: award the stat `item_used` for the used item. Then if `done`:

1. if `CampfireBlock.isSmokeyPos(level, pos)` is **false**: if `hiveContainsBees` (the block entity exists and is not empty) then `angerNearbyBees`; then `releaseBeesAndResetHoneyLevel(... EMERGENCY)` (reset `honey_level` to 0 by `setBlockAndUpdate`, then `emptyAllLivingFromHive(player, state, EMERGENCY)` when the block entity exists);
2. else (smoky): only `resetHoneyLevel` (no bees leave, nobody is angered);
3. return SUCCESS.

If `done` is false the call falls through to the base `useItemOn`. `isSmokeyPos` is the campfire rule of 31 part 4 section 5.9 (a lit campfire 1 to 5 blocks below, with no solid cover between).

### 7.2 Other block-side rules

| Trigger | Rule |
|---|---|
| Destroyed by a player (`playerDestroy`), after the base | if the block entity is a beehive: if the tool does not carry the enchantment tag `prevents_bee_spawns_when_mining` (Silk Touch, 28): `emptyAllLivingFromHive(player, state, EMERGENCY)`, `Containers.updateNeighboursAfterDestroy`, `angerNearbyBees`. The criterion `bee_nest_destroyed` (state, tool, occupant count) is triggered inside the same "block entity is a beehive" branch, whatever the enchantment test gave |
| Neighbour shape update (`updateShape`) | if the block at the changed neighbour position (the `neighbourPos` argument) is a `FireBlock` and the block entity at `pos` is a beehive: `emptyAllLivingFromHive(null, state, EMERGENCY)` (no player). Then the base `BaseEntityBlock.updateShape` runs and its result is returned. So bees leave when fire is placed or spreads next to the hive (read in `BeehiveBlock.updateShape`) |
| `rotate`, `mirror` | `facing` rotated by the rotation; mirror is the rotation of the mirror's rotation of `facing` |
| `playerWillDestroy` (server) | applies only when the level is the server, `player.preventsBlockDrops()` is **true** (the creative-mode case, where the normal drop is suppressed), the game rule `block_drops` is true and the block entity is a beehive. Then `hasBees = !blockEntity.isEmpty()`; if `hasBees` or `honey_level > 0`: make a stack of this block, apply the block entity's components (`collectComponents`), set its `block_state` component to `honey_level = lvl`, spawn it as an item entity at `(pos.x, pos.y, pos.z)` (integer corner, as read) with the default pickup delay (so a creative-mode break keeps the bees and the honey level in the item). In every case the base `playerWillDestroy` follows |
| Explosion hit (`onExplosionHit`) | after the base: `angerNearbyBees` |
| Drops (`getDrops`) | if the breaking entity (loot parameter `this_entity`) is a `PrimedTnt`, `Creeper`, `WitherSkull`, `WitherBoss` or `MinecartTNT` and the loot block entity is a beehive: `emptyAllLivingFromHive(null, state, EMERGENCY)`; then the base drops |
| Pick block (`getCloneItemStack(level, pos, state, includeData)`) | the base stack; when the `includeData` argument is true (the pick-block-with-data key), the stack also gets the `block_state` component `honey_level` set to the current level |

`angerNearbyBees(level, pos)`: let `box = AABB(pos).inflate(8, 6, 8)`; collect the `Bee` entities in `box`; if that list is not empty, collect the `Player`s in the same box; if that list is not empty then for each bee (list order) with no target set `target = random element of the player list` (`Util.getRandom(players, level.random)`).

### 7.3 Client animation (names only)

`animateTick` (client only): while `honey_level >= 5`, one attempt per tick to spawn a `dripping_honey` particle, with probability 0.3 when the block holds no fluid; the particle appears under the block's collision shape (or under the block below when this one does not hide the underside) at a random x and z over the shape extent, 0.05 below the surface. The shape tests and positions are visual only and are specified in 42 part 6.

## 8. Cauldrons

### 8.1 Family model

| Class | Blocks | Fluid kind | Dispatcher |
|---|---|---|---|
| `CauldronBlock` | `cauldron` | none (empty) | `EMPTY` |
| `LayeredCauldronBlock(RAIN, WATER)` | `water_cauldron` | water, `level` 1 to 3 | `WATER` |
| `LayeredCauldronBlock(SNOW, POWDER_SNOW)` | `powder_snow_cauldron` | powder snow, `level` 1 to 3 | `POWDER_SNOW` |
| `LavaCauldronBlock` | `lava_cauldron` | lava, full | `LAVA` |

All four share `AbstractCauldronBlock`:

| Item | Rule |
|---|---|
| Property | none in the base; `LayeredCauldronBlock` adds `level` (the block-state property `LEVEL_CAULDRON`, 1 to 3, default 1) |
| Item use (`useItemOn`) | `interaction = dispatcher.get(stack)`; return `interaction.interact(state, level, pos, player, hand, stack)` |
| Dispatcher lookup (`Dispatcher.get(stack)`) | first, the tag-keyed entries in map iteration order: the first `TagKey` the stack `is` wins; then the item-keyed entries (`getOrDefault(item, DEFAULT)`); `DEFAULT` returns `TRY_WITH_EMPTY_HAND` (the item does nothing, the empty-hand path runs). Only one tag entry exists per dispatcher (`cauldron_can_remove_dye` in `WATER`), so the order cannot matter |
| Shape (`SHAPE`) | the full block minus the union of `column(16, 8, 0, 3)` (x 0 to 16, z 4 to 12, y 0 to 3), `column(8, 16, 0, 3)` (x 4 to 12, z 0 to 16, y 0 to 3), `column(12, 0, 3)` (x 2 to 14, z 2 to 14, y 0 to 3) and `SHAPE_INSIDE` = `column(12, 4, 16)` (x and z 2 to 14, y 4 to 16): the four legs and the walls, a basin with floor top at y = 4 pixels (`FLOOR_LEVEL` 4) |
| Interaction shape | `SHAPE_INSIDE` |
| Pathfinding | not pathfindable |
| Comparator | has an analog output; `AbstractCauldronBlock` has no override of its own except through the subclasses (empty: the base value 0; layered: `level`; lava: 3) |
| `getContentHeight` | 0 (empty), `(6 + 3 * level) / 16` (layered, i.e. 9, 12, 15 pixels over 16), 0.9375 (lava) |
| Stalactite drip (`tick`, see 8.6) | find the stalactite tip above; get the fill fluid; if the fluid is not empty and `canReceiveStalactiteDrip(fluid)` then `receiveStalactiteDrip` |
| `isFull` | empty: false; layered: `level == 3`; lava: true |

### 8.2 Empty cauldron (`CauldronBlock`)

| Rule | Value (read) |
|---|---|
| `RAIN_FILL_CHANCE`, `POWDER_SNOW_FILL_CHANCE` | 0.05, 0.1 |
| `shouldHandlePrecipitation(level, p)` | for `p == RAIN`: `random.nextFloat() < 0.05`; for `p == SNOW`: `random.nextFloat() < 0.1`; any other `p`: false with no draw. One draw only, from the level random |
| `handlePrecipitation(state, level, pos, p)` | if `shouldHandlePrecipitation` is false: nothing. RAIN: `setBlockAndUpdate(pos, water_cauldron default state)` (level 1), game event `block_change`. SNOW: `setBlockAndUpdate(pos, powder_snow_cauldron default state)` (level 1), game event `block_change` |
| Drip: `canReceiveStalactiteDrip(fluid)` | true |
| Drip: `receiveStalactiteDrip(fluid)` | water: `setBlockAndUpdate(pos, water_cauldron default)`, game event `block_change`, level event **1047** (data 0); lava: `setBlockAndUpdate(pos, lava_cauldron)`, game event `block_change`, level event **1046**; other fluids: nothing |

### 8.3 Layered cauldron (`LayeredCauldronBlock`)

| Rule | Value (read) |
|---|---|
| Constants | `MIN_FILL_LEVEL` 1, `MAX_FILL_LEVEL` 3, `BASE_CONTENT_HEIGHT` 6, `HEIGHT_PER_LEVEL` 3.0 pixels |
| Entity-inside collision shape | `SHAPE` plus `column(12, 4, 6 + 3 * level)`, index `level - 1` of `FILLED_SHAPES` |
| `handlePrecipitation(state, level, pos, p)` | if `shouldHandlePrecipitation(level, p)` (the same draw as 8.2) and `level != 3` and `p == this.precipitationType`: `setBlockAndUpdate(pos, state.cycle(level))` (1 to 2 to 3), game event `block_change`. A water cauldron therefore rises only in rain, a powder snow cauldron only in snow, and a draw is consumed in either case |
| `canReceiveStalactiteDrip(fluid)` | true only when `fluid` is water **and** `precipitationType` is RAIN (a powder snow cauldron never takes drips) |
| `receiveStalactiteDrip` | if not `isFull`: `setBlockAndUpdate(pos, level + 1)`, game event `block_change`, level event 1047 |
| `lowerFillLevel(state, level, pos)` (public static, used by the interactions) | `newLevel = level - 1`; the new state is the empty `cauldron` when `newLevel == 0`, else the same block with `level = newLevel`; `setBlockAndUpdate`; game event `block_change` |
| Entity inside (`entityInside`, server only for the callback) | on the server register, for the effect type `EXTINGUISH`, a "before" callback: if the entity is on fire and `entity.mayInteract(level, pos)` then `handleEntityOnFireInside(state, level, pos)`; then on every call (both sides) request the `EXTINGUISH` effect |
| `handleEntityOnFireInside` | for a snow cauldron: the state becomes the `water_cauldron` with the same `level` (the powder snow melts) and then `lowerFillLevel` of that state; for a water cauldron: `lowerFillLevel(state)`. So an entity on fire standing in a level-N water cauldron lowers it by one and is extinguished |
| Comparator | `level` |

The effect order and the actual extinguishing (clearing fire, sound) are 29a and 44 part 1.

### 8.4 Lava cauldron (`LavaCauldronBlock`)

Shape of the interior for entities: `SHAPE` plus `column(12, 4, 15)` (the lava fills to 15 pixels). Content height 0.9375, `isFull` true, comparator 3. Light and sounds in 24 part 4. `entityInside`: request `CLEAR_FREEZE` and `LAVA_IGNITE`, and register an after-`LAVA_IGNITE` callback (the lava hurt of 18 section 2.5), exactly as a lava fluid does (44 part 1). It has no precipitation handler (the base `handlePrecipitation` default does nothing).

### 8.5 The interaction tables (`CauldronInteractions`)

Four dispatchers, named `empty`, `water`, `lava`, `powder_snow` (the names are codec ids, e.g. for data that names a dispatcher). `bootStrap` fills them. In every row "result" is the `InteractionResult`; `TRY_WITH_EMPTY_HAND` means "this item does not interact here".

**Default entries, put into all four dispatchers:**

| Held item | Rule |
|---|---|
| `lava_bucket` | `fillLavaInteraction`: if the fluid at `pos.above()` is in tag `water` return CONSUME with no change; else `emptyBucket(... lava_cauldron default state, sound bucket_empty_lava)` |
| `water_bucket` | `emptyBucket(... water_cauldron with level 3, sound bucket_empty)` (no under-water test) |
| `powder_snow_bucket` | if the fluid at `pos.above()` is in tag `water` return CONSUME; else `emptyBucket(... powder_snow_cauldron with level 3, sound bucket_empty_powder_snow)` |

So a lava, water or powder snow cauldron of any level is overwritten by the bucket's own fluid at full level; the buckets always replace the contents.

**`emptyBucket(level, pos, player, hand, stack, newState, sound)`** (server only; the client just returns SUCCESS): `player.setItemInHand(hand, ItemUtils.createFilledResult(stack, player, new bucket))`; award the custom stat `fill_cauldron` and `item_used` for the item; `setBlockAndUpdate(pos, newState)`; play `sound` at `pos` (BLOCKS, 1.0, 1.0, no source entity); game event `fluid_place`; SUCCESS.

**`fillBucket(state, level, pos, player, hand, stack, filledStack, canFill predicate, sound)`**: if the predicate on the state is false return `TRY_WITH_EMPTY_HAND`; on the server: `setItemInHand(hand, createFilledResult(stack, player, filledStack))`; stats `use_cauldron` and `item_used` for the item; `setBlockAndUpdate(pos, empty cauldron)`; play `sound`; game event `fluid_pickup`; return SUCCESS.

**`ItemUtils.createFilledResult(stack, player, filled[, limitToOneItem = true])`**: if the player has infinite materials (creative) and `limitToOneItem`: add `filled` to the inventory only if the inventory does not already contain it, and return `stack` unchanged; else `stack.consume(1, player)`; if the stack is now empty return `filled` (it replaces the held stack); else try `inventory.add(filled)` and when that fails `player.drop(filled, false)`; return `stack`. The 4-argument form with `false` (banners and shulker boxes) never takes the creative shortcut.

**Per dispatcher extra entries:**

| Dispatcher | Held item | Rule |
|---|---|---|
| `empty` | `potion` | if the stack's `potion_contents` is absent or is not the plain `water` potion: `TRY_WITH_EMPTY_HAND`. Server: `setItemInHand(createFilledResult(stack, player, glass_bottle))`, stats `use_cauldron` and `item_used`, `setBlockAndUpdate(pos, water_cauldron default)` (level 1), play `bottle_empty` (BLOCKS, 1.0, 1.0), game event `fluid_place`. SUCCESS |
| `water` | `bucket` | `fillBucket(water_bucket, level == 3, sound bucket_fill)`: only a full water cauldron gives water back |
| `water` | `glass_bottle` | server: `setItemInHand(createFilledResult(stack, player, potion with plain water))`, stats `use_cauldron`, `item_used`, `lowerFillLevel`, play `bottle_fill`, game event `fluid_pickup`. SUCCESS (works at any level) |
| `water` | `potion` | if `level == 3` or the potion is not plain water: `TRY_WITH_EMPTY_HAND`. Server: glass bottle result, stats, `setBlockAndUpdate(pos, state.cycle(level))` (level + 1), play `bottle_empty`, game event `fluid_place`. SUCCESS |
| `water` | any item in item tag `cauldron_can_remove_dye` | `dyedItemIteration`: if the stack has no `dyed_color` component: `TRY_WITH_EMPTY_HAND`; server: remove the `dyed_color` component from the held stack (in place, the stack is not split), award stat `clean_armor`, `lowerFillLevel`; SUCCESS |
| `water` | each banner colour | `bannerInteraction`: if the stack's `banner_patterns` layers are empty: `TRY_WITH_EMPTY_HAND`; server: copy one banner (`copyWithCount(1)`), set its patterns to `removeLast()` (the top layer is removed), `setItemInHand(createFilledResult(stack, player, copy, false))`, stat `clean_banner`, `lowerFillLevel`; SUCCESS |
| `water` | each dyed shulker box colour | `shulkerBoxInteraction`: if `Block.byItem(item)` is not a `ShulkerBoxBlock`: `TRY_WITH_EMPTY_HAND`; server: `transmuteCopy` to the undyed `shulker_box` (count 1, components kept), `setItemInHand(createFilledResult(stack, player, copy, false))`, stat `clean_shulker_box`, `lowerFillLevel`; SUCCESS (the plain shulker box has no entry: it is not cleaned) |
| `lava` | `bucket` | `fillBucket(lava_bucket, always true, sound bucket_fill_lava)` |
| `powder_snow` | `bucket` | `fillBucket(powder_snow_bucket, level == 3, sound bucket_fill_powder_snow)` |

The client side of every row (`level.isClientSide`) performs none of the effects and returns SUCCESS (or the `TRY_WITH_EMPTY_HAND` / CONSUME result shown) so that the hand animation plays; the server is authoritative.

**Dye and potion interactions the cauldron owns:** only the "remove dye from an item in the `cauldron_can_remove_dye` tag" (leather armour, wolf armour and similar members: DATA, 22) and banner and shulker cleaning above. Dyeing an item by a cauldron of dyed water does not exist in this artifact; tipped arrows and potion item changes are not cauldron rules.

### 8.6 Drip fill from a stalactite

`AbstractCauldronBlock.tick` (server): `tip = PointedDripstoneBlock.findStalactiteTipAboveCauldron(level, pos)`; if null return; `fluid = PointedDripstoneBlock.getCauldronFillFluidType(level, tip)`; if `fluid != EMPTY` and `this.canReceiveStalactiteDrip(fluid)`: `receiveStalactiteDrip(state, level, pos, fluid)`.

What the cauldron needs from the dripstone side (read in `PointedDripstoneBlock`; the dripstone's own growth and particle rules belong to its own part):

| Item | Rule |
|---|---|
| `canFillCauldron(fluid)` | true for water and lava only |
| Drip random tick (`PointedDripstoneBlock.randomTick` calls `maybeTransferFluid(state, level, pos, r)` with `r = random.nextFloat()`) | (1) if `r > 0.17578125` (45/256) and `r > 0.05859375` (15/256): stop. (2) the block must be a stalactite start position (`isStalactiteStartPos`: a stalactite whose block above is not itself the same block). (3) `getFluidAboveStalactite` (an optional `(pos, fluid, sourceState)` record found with `findRootBlock(level, pos, state, 11)`): none: stop. (4) threshold = 0.17578125 for water, 0.05859375 for lava, other fluids stop; if `r >= threshold` stop. (5) `findTip(state, level, pos, 11, false)` null: stop. (6) if the source block (the block above the root) is `mud` and the fluid is water: replace the source position with `clay` (`pushEntitiesUp`), game event `block_change`, level event **1504** (0), stop. (7) otherwise `findFillableCauldronBelowStalactiteTip(level, tip, fluid)`: none: stop; (8) level event 1504 at the tip and `scheduleTick(cauldronPos, cauldron block, (tip.y - cauldron.y) + 50)` |
| `getFluidAboveStalactite` fluid | the block above the root: if it is `mud` and the environment attribute `water_evaporates` at the position is false: water; otherwise the fluid state type at that position (water, lava or empty) |
| `getCauldronFillFluidType(level, tipPos)` | `getFluidAboveStalactite(...)` mapped to its fluid and filtered by `canFillCauldron`; else `EMPTY` |
| `findStalactiteTipAboveCauldron(level, pos)` | search upward from the cauldron with `findBlockVertical(... UP, canTraverse = canDripThrough, stop = isFreeHangingStalactite (method reference read in `PointedDripstoneBlock`; defined in 29b part 6 section 7), 11)`, empty result gives null |
| `findFillableCauldronBelowStalactiteTip(level, tip, fluid)` | search downward from the tip with `findBlockVertical(... DOWN, canTraverse = canDripThrough, stop = state is an `AbstractCauldronBlock` that `canReceiveStalactiteDrip(fluid)`, 11)` |
| `findBlockVertical(level, start, direction, canTraverse, stop, maxSteps)` | step the position one block in the direction `maxSteps - 1` times at most (read in `SpeleothemBlock.findBlockVertical`: the loop index starts at 1 and the loop exits when it reaches `maxSteps`, so exactly 10 steps for 11); at each new position the stop predicate is tested first and its position returned; otherwise if the position is outside the build height or `!canTraverse(pos, state)` return empty |
| `canDripThrough(level, pos, state)` | air: true; a block with solid render: false; a block with a non-empty fluid state: false; otherwise true exactly when the block's collision shape does not intersect `column(4, 0, 16)` (a 4 by 4 pixel vertical shaft in the middle) |

Water drips only into a **water** (rain-type) layered cauldron or an empty cauldron; lava only into an empty cauldron (the lava cauldron and the powder snow cauldron refuse every drip). A drip into a water cauldron raises it one level (1047 sound effect), into the empty cauldron it makes a level-1 water cauldron. The scheduled tick lands `(tip.y - cauldron.y) + 50` ticks after the random tick that started it (the fall time).

### 8.7 Precipitation fill (summary)

33 section 4 calls `handlePrecipitation(state, level, pos, p)` for the block at `below` the top of a random column when the biome's precipitation there is `p`. The rules are in 8.2 (empty cauldron: 1/20 for rain makes a level-1 water cauldron; 1/10 for snow a level-1 powder snow cauldron) and 8.3 (a layered cauldron of the same kind gains one level with the same chance per call until level 3). There is no evaporation and no overflow rule in these classes.

## 9. Candles, candle cakes and cakes

### 9.1 Shared rules (`AbstractCandleBlock`)

| Item | Rule |
|---|---|
| `LIT` | boolean property `lit` (default false) |
| `LIGHT_PER_CANDLE` | 3 |
| `isLit(state)` | the state has `lit`, is in tag `candles` or `candle_cakes`, and `lit` is true |
| `canBeLit(state)` | `!lit` |
| `setLit(level, state, pos, lit)` | `setBlock(pos, state with lit, 11)` |
| `extinguish(player, state, level, pos)` | `setLit(false)`; for every particle offset of the block (`getParticleOffsets`) spawn a `smoke` particle at `pos + offset` with velocity (0, 0.1, 0) (server effect for the level accessor); play `candle_extinguish` (BLOCKS, 1.0, 1.0, no source entity) at `pos`; game event `block_change` with the player as source |
| Explosion hit (`onExplosionHit`) | if `explosion.canTriggerBlocks()` and `lit`: `extinguish(null, state, level, pos)`; then the base |
| Projectile hit (`onProjectileHit`) | on the server, if the projectile is on fire and `canBeLit`: `setLit(level, state, hitBlockPos, true)` |
| Client (`animateTick`, visual only) | if lit, per particle offset one float `f` is drawn: `f < 0.3` spawns a `smoke` particle (velocity 0); inside that branch `f < 0.17` (the same `f`, so probability 0.17 per offset per tick, not 0.3 times 0.17) also plays `candle_ambient` locally at the offset + (0.5, 0.5, 0.5) (BLOCKS, volume `1 + nextFloat`, pitch `nextFloat * 0.7 + 0.3`, the only two further draws, in that order). A `small_flame` particle is then spawned at the offset unconditionally, once per offset (42) |

Lighting by flint and steel, fire charge and similar items is `FlintAndSteelItem` / `FireChargeItem` (17 section 3.3, Flint and steel bullet), which use `CandleBlock.canLight` and `CandleCakeBlock.canLight` (below).

### 9.2 `CandleBlock` (17 blocks)

Properties: `candles` (1 to 4, default 1), `lit` (default false), `waterlogged` (default false). Light emission (`LIGHT_EMISSION`): `lit ? 3 * candles : 0`, so 3, 6, 9, 12 when lit (24).

| Item | Rule |
|---|---|
| Shape (pixels, index `candles - 1`, all read) | 1: `column(2, 0, 6)` (x and z 7 to 9, y 0 to 6); 2: `box(5, 0, 6, 11, 6, 9)`; 3: `box(5, 0, 6, 10, 6, 11)`; 4: `box(5, 0, 5, 11, 6, 10)` |
| Support | `Block.canSupportCenter(level, pos.below(), UP)` (placement only: there is no `updateShape` survive test in this class, read; 12) |
| Placement | if the clicked position holds the same candle block: that state with `candles` cycled (the caller is guarded by `canBeReplaced`, so 1 to 3 become 2 to 4); else the default placement state; `waterlogged` = the fluid at the position is water |
| Replaceable | true when not secondary use, the held item is this block's item and `candles < 4`; else the default |
| Use with an item (`useItemOn`) | an **empty** hand with `abilities.mayBuild` and `lit` true: `extinguish(player, state, level, pos)`, SUCCESS; anything else: the base |
| `canBeLit` | `!waterlogged` and `!lit` |
| ST | if waterlogged: schedule a fluid tick; the base update |
| Fluid | water source when waterlogged |
| `placeLiquid(level, pos, state, fluidState)` | only when not waterlogged and the fluid is water: new state = waterlogged true; if `lit`: `extinguish(null, newState, level, pos)` (which also writes the unlit state, flags 11); else `setBlockAndUpdate(pos, newState)`; then schedule a fluid tick for the fluid; return true |
| `CandleBlock.canLight(state)` (static) | the state is in tag `candles` **and** has both `lit` and `waterlogged`, and `!lit` and `!waterlogged` |
| Particle offsets (pixel / 16, centre x 8 y 8 z 8 scale 0.0625) | 1 candle: (8, 8, 8); 2: (6, 7, 8), (10, 8, 7); 3: (8, 5, 10), (6, 7, 8), (9, 8, 7); 4: (7, 5, 9), (10, 7, 9), (6, 7, 6), (9, 8, 6) (all times 0.0625) |


### 9.3 `CandleCakeBlock` (17 blocks: one per candle block, built with it)

Property `lit` (default false). Built from a candle block (`BY_CANDLE` maps each `CandleBlock` to its cake variant; a non-candle argument throws at startup). Shape: `column(2, 8, 14)` (x and z 7 to 9, y 8 to 14, the candle) united with `column(14, 0, 8)` (the cake body). Particle offset: one, (8, 16, 8) times 0.0625. Comparator output: the full cake signal (14). Not pathfindable.

| Trigger | Rule |
|---|---|
| Use with an item (`useItemOn`) | if the item is flint and steel or a fire charge: PASS (the item's own `useOn` lights it). Else if `candleHit(hit)` (the hit location's y minus the block y is greater than 0.5, i.e. the candle part was clicked), the stack is empty and `lit`: `extinguish(player, state, level, pos)`, SUCCESS. Else the base |
| Use without an item (`useWithoutItem`) | `result = CakeBlock.eat(level, pos, cake default state (bites 0), player)`; if that consumes the action: `dropResources(state, level, pos)` (the candle item, loot table of the candle cake); return the result. (`eat` replaces the block by the cake with `bites` 1.) |
| ST | `direction == DOWN` and `!canSurvive`: air; else the base |
| Support (`canSurvive`) | the block below `isSolid()` |
| Pick block | a `cake` item |
| `CandleCakeBlock.canLight(state)` (static) | the state is in tag `candle_cakes`, has `lit`, and `!lit` |

### 9.4 `CakeBlock` (`cake`)

Property `bites` (0 to 6, default 0; `MAX_BITES` 6). Shapes: `box(1 + 2 * bites, 0, 1, 15, 8, 15)` for `bites` 0 to 6 (pixels). Support: the block below `isSolid()`; ST: `DOWN` and `!canSurvive` gives air. Not pathfindable. Comparator output `(7 - bites) * 2` (14, 12, 10, 8, 6, 4, 2; `FULL_CAKE_SIGNAL` = 14).

| Trigger | Rule |
|---|---|
| Use with an item (`useItemOn`) | if the held item is in item tag `candles` and `bites == 0` and `Block.byItem` is a `CandleBlock`: consume one item (`consume(1, player)`), play `cake_add_candle` (BLOCKS, 1.0, 1.0), `setBlockAndUpdate(pos, CandleCakeBlock.byCandle(candle).defaultBlockState())` (unlit), game event `block_change`, award `item_used`, SUCCESS. Otherwise `TRY_WITH_EMPTY_HAND` |
| Use without an item (`useWithoutItem`) | client: `result = eat(...)` ; if it consumes the action return SUCCESS; else if the main hand is empty return CONSUME; if neither, fall through to the server path. Server: return `eat(...)` |
| `eat(level, pos, state, player)` | if `!player.canEat(false)` return PASS. Else award the custom stat `eat_cake_slice`; `foodData.eat(2, 0.1f)` (2 food points, saturation modifier 0.1); read `b = bites`; game event `eat`; if `b < 6`: `setBlockAndUpdate(pos, bites = b + 1)` else `removeBlock(pos, false)` and game event `block_destroy`; return SUCCESS. A cake therefore gives 7 slices (bites 0 to 6) |

## 10. Soul sand, magma block, lightning rod

### 10.1 Soul sand (`SoulSandBlock`)

The class has no tick, `updateShape` or bubble column hook. Read: collision shape `column(16, 0, 14)` (14 pixels high), support shape and visual shape a full block, not pathfindable, shade brightness 0.2. Speed factor 0.4 and the `valid_spawn` and redstone-conductor predicates are registry data (24, 44 part 1 RQ-1.9). The bubble column that appears above it is made by the `BubbleColumnBlock` and fluid code (44 part x1 section 2.3), not by this class; so the request's "bubble columns tick hooks" for soul sand and magma are absent in these two classes.

### 10.2 Magma block (`MagmaBlock`)

Only `stepOn`: if the entity is not stepping carefully and is a `LivingEntity`: `entity.hurt(hot_floor damage source, 1.0)`; then the default. Same as 29b part 3 section 10.3 (the amount 1.0 is read again here). The class has no other behaviour; light, postProcess and emissive rendering are registry data (24).

### 10.3 Lightning rod (`LightningRodBlock`)

Read again in full; all rules are in 29b part 3 section 9.2 and agree (strike sets `powered`, schedules a tick with delay 8, level event 3002 with the axis ordinal; the tick unpowers and updates the neighbour at `pos.relative(facing.opposite)`; PL reschedules when powered and no tick is pending; removal updates neighbours when powered; signal 15, direct signal 15 toward `facing`; `animateTick` sparks). Delta read here: placement sets `facing` to the clicked face and `waterlogged` from the fluid; ST schedules a water fluid tick when waterlogged (then `RodBlock.updateShape`).

## 11. Worked examples

1. **Coral out of water.** A `tube_coral` is placed at `(0, 64, 0)` with no water and `waterlogged` false. PL schedules a block tick with delay `60 + nextInt(40)`; with the draw 17 the tick runs 77 ticks later; the water test is still false, so `dead_tube_coral` with `waterlogged = false` replaces it (flags 2, no neighbour update). If a neighbour block became water at tick 50 and the next `updateShape` of the coral did not schedule again (water found), the existing tick at 77 still runs, finds water, and does nothing; the coral stays alive and no new tick is scheduled.
2. **Wall fan placement.** A player looking north-east-down places a `brain_coral_wall_fan` on the west face of a stone block at `(5, 64, 5)` (the stone lies east of the fan). `getNearestLookingDirections` yields, say, `east, north, down, ...`; `east` is horizontal, `facing = west`; the block at `pos.relative(east)` is the stone with a sturdy west face, so `canSurvive` is true and the state is `facing = west`. Its shape is the north shape rotated to west.
3. **Turtle egg walked on.** A zombie walking over a 3-egg block calls `stepOn` (a zombie is a living entity, so with `mob_griefing` true `canDestroyEgg` is true); with chance 100 one call in 100 on average destroys an egg, giving `eggs = 2` plus the break sound. A zombie falling onto it gets `fallOn` skipped (zombies are excluded), a player landing on it has a 1 in 3 chance per landing. A turtle never breaks it.
4. **Turtle egg hatch.** `eggs = 2`, `hatch = 2`, sand below, attribute 0.002 at that time; each random tick has a 1 in 500 chance of passing the gate (this holds only in the 0.002 window of the day track; from day tick 21062 to 21904 the attribute is 1.0 and the draw `nextFloat < 1.0` always passes; 3.2). When passed: hatch sound, block removed, two events 2001, baby turtles at `x + 0.3`, `z + 0.3` and `x + 0.5`, `z + 0.3`, age `-24000`, home at the block.
5. **Sniffer egg on moss.** Placed on a moss block: total 12000, stage 4000, the first tick at `4000 + nextInt(300)`; with a draw of 123 the crack happens at tick 4123 and `hatch` becomes 1. The hatch tick (when `hatch == 2`) removes the block and spawns a baby sniffer at the block centre with a random yaw `wrapDegrees(nextFloat * 360)`.
6. **Frogspawn.** Placed on water with air above: hatch delay `3600 + nextInt(8400)`. At the tick, `nextInt(2, 6)` = 4 tadpoles spawn, each at `(x + clamp(nextDouble, 0.2, 0.8), y - 0.5, z + clamp(nextDouble, 0.2, 0.8))` with yaw 1 to 360. If the water below was drained before the tick the block is destroyed instead (no tadpoles).
7. **Honey block slide.** A player at `(0.9, 64.9, 0.5)` against the side of a honey block at (0, 64, 0) with `vy = -0.5`: not on the ground; `y = 64.9 <= 64 + 0.9375 - 1e-7`; `oldDeltaY = -0.5/0.98 + 0.08 = -0.4302 < -0.08`; `dx = |0.5 - 0.9| = 0.4`, `w = 0.4375 + 0.6/2 = 0.7375`; `0.4 + 1e-7 > 0.7375` is false, `dz = 0`; so not sliding in the centre column. At `x = 1.25` `dx = 0.75 > 0.7375`: sliding, and the player's box (x 0.95 to 1.55) overlaps the block (x 0 to 1), so `entityInside` is called. (At `x = 1.3` the box starts at 1.0 and only touches the block: `isSlidingDown` passes, but `entityInside` never runs. `isSlidingDown` alone does not guarantee an `entityInside` call.) `o < -0.13`: `f = -0.05 / -0.4302 = 0.1162`; horizontal speed times 0.1162, `vy = -0.1274`.
8. **Beehive harvest.** `honey_level = 5`, shears, no campfire below: 3 honeycomb drop (loot table), shears lose 1 durability, `honey_level` 0, the bees inside leave in emergency status and the bees within 8 by 6 by 8 around the block target a random player in that box. With a lit campfire two blocks below: the honey level resets but no bee leaves and nobody is angered.
9. **Cauldron.** An empty cauldron, rain, `nextFloat` 0.03 (< 0.05): becomes `water_cauldron level 1`. The player right-clicks with a water bucket: `level 3` and an empty bucket in hand (creative: the stack is unchanged if the inventory already holds a bucket). With a glass bottle: `level 2`, a water potion in hand and `bottle_fill`. With a water potion at level 3: `TRY_WITH_EMPTY_HAND` (nothing). A player on fire inside a level-2 water cauldron: the effect callback runs, the level drops to 1 and the fire is put out.
10. **Candle on cake.** An unlit `white_candle` item used on a fresh cake: the candle item is consumed, `cake_add_candle` plays, the block becomes `white_candle_cake` (unlit). Flint and steel then lights it. Clicking the candle part (hit y above 0.5) with an empty hand extinguishes it; clicking the cake body with an empty hand eats a slice: the block becomes `cake` with `bites = 1` and the candle item drops.
11. **Cake signal.** `bites` 0 to 6 give comparator output 14, 12, 10, 8, 6, 4, 2; the seventh eat (at `bites = 6`) removes the block.

## 12. Validation

| Check | How to test |
|---|---|
| Coral die delay | collect 1000 draws; all die ticks fall in 60 to 99; both bounds occur |
| Coral wet/dry | a coral block with water on any one of six sides never dies; with none dies at its tick |
| Wall fan placement | all four horizontal directions with a sturdy and a non-sturdy support; a non-sturdy support returns no state |
| Turtle egg | 100000 `stepOn` calls by a player: about 1000 breakages; sneaking: none; turtle or bat: none; spawn-protected player: none |
| Turtle egg hatch | unit test of the gate with a stubbed attribute: at 0 no stage advances and no float is drawn; at 1.0 every random tick on sand advances; at 0.002 about 1 in 500; on non-sand none advances, but the random draw is still consumed. (The real day track only holds 1.0 and 0.002, 3.2) |
| Sniffer egg | stage delay 4000 to 4299 on moss and 8000 to 8299 otherwise; level event 3009 only on moss |
| Frogspawn | hatch delay 3600 to 11999; tadpole count 2 to 5; offsets in [0.2, 0.8]; the block above must be non-fluid |
| Honey | the worked example 7 numbers: `f` = 0.1162, `vy` = -0.1274 |
| Beehive | with shears at level 5 on both sides of a campfire test; bottle gives `honey_bottle` and level 0; below level 5 nothing happens |
| Cauldron | the interaction table of 8.5 row by row with creative and survival players; every bucket row overwrites the contents; the potion row at level 3 is a no-op |
| Precipitation | 100000 calls with RAIN on an empty cauldron: about 5000 become level 1; on a water cauldron at level 3: none |
| Drip | a stalactite over an empty cauldron fills it after a delay `(tip.y - cauldron.y) + 50` from the draw; over a powder snow cauldron nothing |
| Candle | light emission 3, 6, 9, 12 lit; waterlogging a lit candle extinguishes it |
| Cake | the signal list of 11.11 and the removal at the seventh slice |

## 13. Open questions

1. The step between the die rule's second call (from `updateShape`) and its dedupe: the claim that a repeated schedule of the same block at the same position does not stack is taken from 29 section 3 and was not re-read in the scheduler for this part.
2. `CoralBlock` schedules its die tick in `getStateForPlacement`, not in `onPlace`; blocks placed by world generation or commands therefore get their first die tick only from the next `updateShape` call. Not traced further.
3. (Closed: the sniffer egg re-schedule through `onPlace` after a flags-2 state change is read in `LevelChunk.setBlockState`, see 3.2 and 4.)
4. (Closed: `Player.preventsBlockDrops()` returns `abilities.instabuild`, the creative-mode flag, read; the `getCloneItemStack` guard is its boolean `includeData` argument.)
5. (Closed: the stop predicate is `isFreeHangingStalactite` and the loop bound is 10 steps, both read, 8.6.) The internals of `findRootBlock`, `findTip` and the growth rules of pointed dripstone are in 29b part 6 sections 4, 5 and 7, not repeated here.
6. Candles have no `updateShape` survive test in this artifact (only the placement check). Whether another mechanism removes a candle whose support disappears was not looked for beyond `BlockBehaviour.updateShape` (the base returns the state unchanged).
7. (Closed: the track, its `maximum` modifier and the 0.002 default are read, see 3.2.) Other timelines or modifiers that may also set this attribute were not searched.
8. The honey block wall-slide `isSlidingDown` conditions were read here and in 44 part x1 section 2.1; this part does not re-derive the entity-side jump and speed factor use (44 part 1 RQ-1.9).
9. Level events 2012, 3002, 1046, 1047 and the entity events 53 and 54 are named; their client effects (particle shapes, sounds) are in 42 part 7 or are not specified yet (3009 and 1504 are cross-referenced in question 13).
10. The statistics and advancement triggers named in the tables (`use_cauldron`, `fill_cauldron`, `clean_armor`, `clean_banner`, `clean_shulker_box`, `eat_cake_slice`, `honey_block_slide`, `bee_nest_destroyed`) are named only; their definitions belong to the advancement and statistics rounds.
11. (Closed: `BlockBehaviour.getAnalogOutputSignal` returns 0, read, so the empty cauldron outputs 0.)
12. `docs/protocol/README.md` has no Documents-table row for this document yet; the README step must still be done before commit (add the row and keep the scope sentence consistent). This fixer may not edit the README.
13. Level events on the client: 42 part 7 section 6 lists 1504 (pointed dripstone drip, `spawnDripParticle`), 2011 and 2012 (`spawnParticleInBlock` with `happy_villager`) and 3009 (`egg_crack` particles, 3 to 6 per face). 42 labels 3009 'turtle egg cracked', whereas this part (4) uses it for the sniffer egg placed on moss; the label needs reconciling in 42 (the artifact's use here is the `onPlace` call of the sniffer egg block; whether the turtle egg also fires it was not searched).
