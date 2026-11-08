# 29b. Falling blocks, growth, fire and similar block behaviours, part 1: shared model, gravity, bone meal framework, tree growth trigger

| | |
|---|---|
| Covers | The shared model for the block-behaviour documents 29b parts 1 to 7 (record schema, trigger kinds, probability notation, predicate vocabulary, id assignment, sibling index and block-to-part table); the falling-block family (`FallingBlock`, `Fallable`, sand, red sand, gravel, concrete powder, suspicious sand and gravel, anvils, dragon egg, scaffolding collapse) and the falling block entity (tick, landing, drops, damage, persistence); the `BonemealableBlock` framework and the generic bone-meal flow; the shared crop growth helpers (`CropBlock`); the sapling growth trigger and `TreeGrower` selection and rollback |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS11 (GAP-10b of `../design/README.md` Part 5), part 1 |
| Data versus code | Tags (`fire`, `anvil`, `supports_crops`, `grows_crops`, `supports_vegetation`, `flowers`, `wall_corals`, `underwater_bonemeals`), loot tables, recipes and the configured tree features are DATA, read from the extracted data pack (22, 23, 26, 35). This document specifies the engines that interpret them and the code-defined rules (constants, formulas, orderings, the `TreeGrower` table). |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions. Block names are registry names (24 parts 1 to 8); "05a 0xNN" is a packet of `05a-play-clientbound-00-71.md`.

## 0. Reader's map

| Question | Section |
|---|---|
| What is in this document and what is not; the sibling parts; which block belongs to which part | 1 |
| The record every block-behaviour row uses; trigger kinds; flags; probability notation; predicate vocabulary; id assignment | 2 |
| The falling block rules per block, `isFree` | 3 |
| The falling block entity: spawn, tick, landing, drops, damage, persistence, wire | 4 |
| The bone meal interface, the item flow, the neighbour spreader default | 5 |
| Crop growth helpers (`getGrowthSpeed`, random tick, bone meal age step) | 6 |
| Saplings, `TreeGrower`, the growth trigger and rollback | 7 |
| Worked examples | 8 |
| Validation | 9 |
| Open questions | 10 |

## 1. Scope, siblings, cross-reference

### 1.1 What this document covers and what it does not

Covered here: sections 3 to 7. Not covered here, with the owner:

| Topic | Owner |
|---|---|
| Fire spread and burn constants, flint and steel, fire charge | 17 §3.3, §3.3a (not repeated; the fire block's own tick belongs to a sibling part of 29b only where 17 leaves it open) |
| Fluids (flow, source conversion, lava and water interaction, `FluidState` rules) | a fluids round (not in 29b part 1); aquifer fluids 10 §9 |
| Redstone components | a redstone round |
| Tree shapes (trunk, foliage, root placers), the `Feature.place` algorithm | 35 parts 1 to 7 (`35 ...-3-tree-placers`) |
| Brush use, the brush item, `BrushableBlockEntity` brushing steps | 17 §3.5 |
| Dispenser, piston and other callers of `setBlock` | 29 §3.5, the piston round |
| Entity movement (`Entity.move`, collision, `onGround`, friction) | 13 §1, 18 §3, 41 §3 |
| Wire formats of the packets named here | 05a, 05b, 05c |
| Block registry rows (ids, properties, shapes, light) | 24 parts 1 to 8; the registry ids in 46 |
| Loot of blocks | 26 |
| Level event to sound mapping, particle shapes | 42 part 7 §8.3 (bone meal particles); 29 §7.4 (events used by block breaking) |

### 1.2 Sibling index (proposed split; each sibling states its own scope)

| Part | File name (proposed) | Contents (proposed) |
|---|---|---|
| 1 | `29b-falling-growth-fire-1-model-gravity-bonemeal.md` | this document |
| 2 | `29b-falling-growth-fire-2-crops-and-stems.md` | crop blocks (wheat, carrots, potatoes, beetroots, torchflower crop, pitcher crop), stems and fruit, cocoa, sweet berry bush, nether wart, mushrooms |
| 3 | `29b-falling-growth-fire-3-growing-plants.md` | `GrowingPlantHeadBlock` / `GrowingPlantBodyBlock` (kelp, vines of the nether, cave vines), bamboo, cactus, sugar cane, chorus, sea pickle, seagrass |
| 4 | `29b-falling-growth-fire-4-spreading-and-decay.md` | grass and mycelium spread, nylium, snow layer, ice, farmland, leaves decay, vines |
| 5 | `29b-falling-growth-fire-5-weathering-sculk-misc.md` | copper weathering, sculk family, amethyst, moss, azalea, dripleaf, hanging moss |
| 6 | `29b-falling-growth-fire-6-fire-and-burning.md` | the fire block tick beyond 17 §3.3a, soul fire, campfire, tnt ignition, lava ignition |
| 7 | `29b-falling-growth-fire-7-residual.md` | blocks that no other part took |

The proposed split is the orchestrator's guess from the round's scope text (Open question 1); sibling parts overrule it. This part owns the shared model (section 2) and cites nothing from the siblings except through the table of 1.3.

### 1.3 Block name to part (blocks whose behaviour this part specifies)

Rows are the registry names and ids of 24. "Class" is the class read in the artifact.

| Registry block (24 id) | Class | Section |
|---|---|---|
| `sand` (39), `red_sand` (41) | `SandBlock extends ColoredFallingBlock` | 3.2 |
| `gravel` (42) | `ColoredFallingBlock` | 3.2 |
| `suspicious_sand` (40), `suspicious_gravel` (43) | `BrushableBlock` (a `BaseEntityBlock` and `Fallable`; not a `FallingBlock` subclass) | 3.5 |
| the 16 `<colour>_concrete_powder` (24 part 6, field 577) | `ConcretePowderBlock extends FallingBlock` | 3.3 |
| `anvil` (431), `chipped_anvil` (432), `damaged_anvil` (433) | `AnvilBlock extends FallingBlock` | 3.4 |
| `dragon_egg` (355) | `DragonEggBlock extends FallingBlock` | 3.6 |
| `scaffolding` (673 field, registry id 927) | `ScaffoldingBlock` (not a `FallingBlock`; spawns the entity itself) | 3.7 |
| `pointed_dripstone` (848), `sulfur_spike` (849) | `SpeleothemBlock` (a `Fallable` that spawns the entity itself; its behaviour is not specified here) | 3.8 |
| `oak_sapling` (26), `spruce_sapling` (27), `birch_sapling` (28), `jungle_sapling` (29), `acacia_sapling` (30), `cherry_sapling` (31), `dark_oak_sapling` (32), `pale_oak_sapling` (33), `poplar_sapling` (35) | `SaplingBlock(TreeGrower, ...)` | 7 |
| `mangrove_propagule` (34) | `MangrovePropaguleBlock` with `TreeGrower.MANGROVE` (its hanging and growth rules belong to sibling part 3 or 7; the grower table is in 7.4) | 7.4 |
| all `CropBlock` subclasses | `CropBlock` | 6 |
| every other `BonemealableBlock` | see the implementer list in 5.2 | 5 |

## 2. The shared model

### 2.1 The behaviour record

Every block behaviour in 29b is a row of this record. Documents of the 29b family use the same columns, in this order, so rows can be merged.

| Column | Meaning |
|---|---|
| Block | registry block name(s) from 24 (key); a class name when the row applies to every block of a class (list the names in the class table) |
| Trigger | one of the trigger kinds of 2.2 |
| Source | the class and method where the rule was read |
| Condition | the predicate that must hold, written in the vocabulary of 2.5 |
| Probability | the notation of 2.4, or "always" |
| Effect | the state written, the entity spawned, the event sent, in order |
| Flags | the `setBlock` flag value (29 §1, §3.5) when a state is written; "and update" is flags 3 |
| Events | level events, game events and sounds with their data |
| Notes | quirks, order of random draws |

### 2.2 Trigger kinds

| Kind | Code | When it runs | Reference |
|---|---|---|---|
| Random tick | RT | a random-ticking state is chosen by the chunk's random tick draw (`randomTick`) | 29 §5, 33 §2.4 |
| Scheduled tick | ST | a tick scheduled with `scheduleTick(pos, block, delay)` fires (`tick`) | 29 §4 |
| Place | PL | `onPlace`, after a state is written without `UPDATE_SKIP_ON_PLACE` | 29 §2.1 |
| Neighbour update | NU | `neighborChanged`: a neighbour was changed with the neighbours flag | 29 §3.1 |
| Shape update | SU | `updateShape`: a direct-neighbour shape notification; may return a replacement state and may schedule ticks through the tick accessor | 29 §3.2 |
| Entity or use event | EV | `entityInside`, `useWithoutItem`, `useItemOn`, `attack`, `fallOn`, or an item flow such as bone meal | 29 §8, §9 |
| Entity tick | ET | a per-tick method of an entity that changes blocks (falling block entity) | section 4 |

`isRandomlyTicking(state)` is the state-level switch that decides whether RT exists at all; it is a registry column (24 part 1 §4, the `randomTicks` builder flag), except that some blocks override the state test (for example `CropBlock`: random-ticking only while the age is below the maximum, 6.2).

### 2.3 Flags and sides

`setBlock` flag vocabulary is 29 §1. The values that this document's rows use: 2 (clients only), 3 (`setBlockAndUpdate`: neighbours and clients), 260 (4 + 256: no neighbour update, no client broadcast of redraw, skip block entity side effects), 818 (512 + 256 + 32 + 16 + 2: skip on-place, skip block-entity side effects, suppress drops, skip shape updates, clients). All are read in 7 and 6.

### 2.4 Probability notation

| Notation | Meaning |
|---|---|
| `1/N` | the effect happens when `RandomSource.nextInt(N) == 0`; one draw is consumed |
| `P(p)` | the effect happens when `nextFloat() < p` (compare as the artifact does; `nextFloat` is the 24-bit float of the random source); one draw |
| `U(a,b)` | `Mth.nextInt(random, a, b)`: returns `a` when `a >= b`, else `nextInt(b - a + 1) + a` (read); both ends inclusive |
| draw order | rows list every draw in the order made; a short-circuit that skips a draw is stated |

Random-tick rate. 33 §2.4 draws `random_tick_speed` positions per section per game tick (default 3), each uniform over the 4096 cells of the section (the draw is `randomBlockPos`, 33 §2.4). A block that is random-ticking therefore receives on average `speed / 4096` random ticks per game tick, and an effect with probability `1/N` per random tick happens on average `speed / (4096 N)` times per game tick (inferred arithmetic). With `random_tick_speed` 0 no random tick happens at all. Scheduled ticks are not affected by the rule.

### 2.5 Predicate vocabulary

| Predicate | Definition | Source |
|---|---|---|
| `rawBrightness(pos, darken)` | `max(blockLight(pos), skyLight(pos) - darken)`, the sky term 0 when the dimension has no sky engine | 32 §1.2, `LevelReader.getRawBrightness` |
| `maxLocalRawBrightness(pos)` | 15 when x or z is outside +-30,000,000, else `rawBrightness(pos, skyDarken)`; the two-argument form takes `darken` explicitly | 32 §1.2, `LevelReader.getMaxLocalRawBrightness` |
| `isEmptyBlock(pos)` | the block at `pos` is air (`isEmptyBlock` used by the spreader helper, 5.4) | read |
| `canSurvive(state, level, pos)` | the block's survival test (24 part 1 §10.2); for `VegetationBlock` it is `mayPlaceOn(state below)`, for `CropBlock` additionally `rawBrightness(pos, 0) >= 8` | `VegetationBlock.canSurvive`, `CropBlock.canSurvive` |
| `mayPlaceOn` | `VegetationBlock`: the block below is in tag `supports_vegetation`; `CropBlock` overrides: tag `supports_crops` | read |
| `isFree(state)` | air, in tag `fire`, a liquid state, or `canBeReplaced()` (the replaceable flag); 3.1 | `FallingBlock.isFree` |
| moisture | the farmland state property `moisture`; `getValueOrElse(moisture, 0)` is used so any other block reads 0 | `CropBlock.getGrowthSpeed` |
| `isFaceSturdy(level, pos, dir)` | 24 part 1 §6.5 | read |
| `isInsideBuildHeight(pos)` | `minY <= y <= maxY` of the dimension | 29 §1 |
| horizontal order | `Direction.Plane.HORIZONTAL` lists north, east, south, west (read); `shuffledCopy(random)` is a random permutation of that list | `Direction$Plane` |
| in water | the fluid state is in fluid tag `water` | read |

### 2.6 Id assignment for behaviour rows

Rows are keyed by registry block name (the `Blocks` field name lowercased, 24 part 1 §2). A numeric block id or state id is never the key; both come from 24 and 46 §2. A row that applies to a class lists the block names in a table with their 24 ids, as 1.3 does. Tags used by a row are written by tag name (`minecraft:` namespace implied) and resolved by the loader of 23.

## 3. Falling block rules

### 3.1 `FallingBlock` (shared by sand, gravel, concrete powder, anvils, dragon egg)

| Trigger | Rule | Source |
|---|---|---|
| PL | schedule a block tick at the block's own position after `getDelayAfterPlace()` ticks (default 2; dragon egg 5) | `onPlace` |
| SU | for every shape update (any direction) schedule the same tick, then run the default shape update (the state is returned unchanged by `FallingBlock`; `ConcretePowderBlock` overrides, 3.3) | `updateShape` |
| ST | (a) if the state at `pos.below()` is not free (`isFree`) or `pos.y < minY` (the level's minimum y): do nothing. (b) otherwise call `FallingBlockEntity.fall(level, pos, state)` (4.1), then call the block's `falling(entity)` hook (default does nothing; the anvil sets its damage, 3.4) | `tick` |

`isFree(state)` is true when at least one of: the state is air; it is in block tag `fire`; the state is a liquid (`liquid()`); the state is replaceable (`canBeReplaced()`, the registry replaceable flag, 24 part 1 §10.1).

The `y` test is `pos.y >= minY`: a block at the lowest layer of the dimension never falls (the tick returns), and a block can fall from there only when the cell below exists.

Client-only: `animateTick`: with probability `1/16` (one `nextInt(16)` draw, effect when 0), if the cell below is free, a `falling_dust` particle (data: the block state) is spawned below the block (`ParticleUtils.spawnParticleBelow`; its geometry belongs to 42, not read here). `SandBlock` additionally calls the ambient desert sand sound player (not read).

Each `FallingBlock` subclass gives a dust colour (client particle tint): sand 14406560, red sand 11098145, gravel -8356741 (24 part 1 §14), dragon egg -16777216, concrete powder and anvils the block's map colour (`MapColor.col`) (read).

### 3.2 Sand, red sand, gravel

`SandBlock`, `ColoredFallingBlock`: no behaviour beyond 3.1 and the dust colour. They have no properties (1 state each). The tick delay is 2.

### 3.3 `ConcretePowderBlock` (16 blocks)

Fields: `concrete` (the same-colour concrete block). Rules (read; the same rules are described from the registry side in 24 part 6 under field 577, with the full `touchesLiquid` walk):

| Trigger | Rule |
|---|---|
| Placement state (`getStateForPlacement`) | if `shouldSolidify(level, clickedPos, state at clickedPos)` the placed state is `concrete.defaultBlockState()`; otherwise the `FallingBlock` placement (the default state) |
| SU | if `touchesLiquid(level, pos)` the new state is `concrete.defaultBlockState()` (the powder becomes concrete in place); else the `FallingBlock` shape update, which schedules the fall tick |
| `onLand(level, pos, landedState, replacedState, entity)` | if `shouldSolidify(level, pos, replacedState)` then `setBlockAndUpdate(pos, concrete default state)` |
| `shouldSolidify(level, pos, state)` | `canSolidify(state) or touchesLiquid(level, pos)` |
| `canSolidify(state)` | the state's fluid is in fluid tag `water` |
| `touchesLiquid(level, pos)` | see 24 part 6, field 577: six directions in the order of `Direction.values()` (down, up, north, south, west, east); a water neighbour whose face towards the powder is not sturdy makes it true; the cell below is examined only when the powder's own cell is already water (a read quirk of that method) |
| Dust colour | the map colour's `col` |

`replacedState` is the state that stood in the cell when the falling entity landed (4.3 step 5: the entity passes the state read just before placement). Concrete powder entities also have a water test in the entity tick (4.2 step 6), so a falling powder block that reaches water solidifies when it enters the water, not only when it lands.

### 3.4 Anvils (`AnvilBlock extends FallingBlock`)

Registry rows, shape, placement and menu are in 24 part 5 §7.2. The falling rules (read this round):

| Item | Value |
|---|---|
| `falling(entity)` hook (called by 3.1 ST) | `entity.setHurtsEntities(2.0f, 40)`: fall damage per fallen block 2.0, maximum 40 |
| `onLand(level, pos, ...)` | unless the entity is silent: level event **1031** at `pos`, data 0 |
| `onBrokenAfterFall(level, pos, entity)` | unless the entity is silent: level event **1029** at `pos`, data 0 |
| `getFallDamageSource(entity)` | damage type `anvil` (17 §4 damage types); other `Fallable` blocks use `falling_block` |
| `damage(state)` | `anvil` becomes `chipped_anvil`, `chipped_anvil` becomes `damaged_anvil`, both with the old `facing`; any other state (the damaged anvil) returns null |

The falling entity reads the `anvil` block tag, not the class, to decide whether it is an anvil (4.5 and 4.6).

### 3.5 Suspicious sand and suspicious gravel (`BrushableBlock`)

`BrushableBlock extends BaseEntityBlock implements Fallable` with property `dusted` (0 to 3, default 0). It is not a `FallingBlock`; it repeats the same pattern with its own constants.

| Trigger | Rule |
|---|---|
| PL | schedule a tick at its own position after 2 ticks |
| SU | schedule a tick after 2 ticks, then the default shape update |
| ST | (1) if the block entity at `pos` is a `BrushableBlockEntity`, call `checkReset(level)` on it (17 §3.5: the 40-tick progress reset). (2) If the cell below is not free (`FallingBlock.isFree`) or `pos.y < minY`: stop. (3) Otherwise `FallingBlockEntity.fall(level, pos, state)` and call `disableDrop()` on the entity (`cancelDrop = true`) |
| `onBrokenAfterFall` | level event **2001** at the block position containing the entity's bounding-box centre, data = global block state id of the entity's state; game event `block_destroy` at that centre |
| Client `animateTick` | `1/16`: if the cell below is free, add a `falling_dust` particle at `(x + nextDouble, y - 0.05, z + nextDouble)` with zero velocity |

Consequence read from 4.3 step 3: because `cancelDrop` is true the falling suspicious block never places itself; on landing it is discarded and `onBrokenAfterFall` runs (the 2001 break effect), and no item is dropped. The entity's `blockData` is null (`fall` does not copy block entity data), so the stored loot item is lost (inferred from `fall`, which reads no block entity). The expiry drop of 4.4 does not depend on `cancelDrop`: a suspicious block entity that times out drops one item of the block (4.4).

### 3.6 Dragon egg (`DragonEggBlock`)

Registry row: 24 part 4 §6.21 (shape, light, push reaction). Falling: tick delay **5**. Teleport (read): triggered by `useWithoutItem` (returns SUCCESS) and by `attack` (a left click), server side only. Constants `HORIZONTAL_TELEPORT_RADIUS` 16 and `VERTICAL_TELEPORT_RADIUS` 8. Up to **1000** attempts; each attempt draws, in this order, `nextInt(16)`, `nextInt(16)`, `nextInt(8)`, `nextInt(8)`, `nextInt(16)`, `nextInt(16)` from the level random (all six draws are made on every attempt) and forms the offset `(a1 - a2, b1 - b2, c1 - c2)` (x from draws 1 and 2, y from 3 and 4, z from 5 and 6). The candidate is accepted when: the block there is air, the block below it is not air, the position is inside the world border, and inside the build height. On acceptance: level event **2015** at the old position with data `BlockUtil.packDifferenceInPosition(old, new, 16, 8, 16)`; `setBlock(new, state, 2)`; `removeBlock(old, false)`; stop. When no attempt succeeds nothing happens. The egg also falls (3.1) with the entity's default drops (its item, `dropItem` true).

### 3.7 Scaffolding (`ScaffoldingBlock`)

Properties `distance` (0 to 7; this is `STABILITY_DISTANCE`, default 7), `bottom` (default false), `waterlogged` (default false); `STABILITY_MAX_DISTANCE` 7, tick delay 1. Registry row: 24 part 7 (field 673).

| Item | Rule |
|---|---|
| `getDistance(level, pos)` | `d = 7`. Let `B` = the state at `pos.below()`. If `B` is scaffolding then `d = B.distance`; else if `B.isFaceSturdy(level, pos.below(), up)` the result is **0** (returns immediately). Then for each horizontal direction in the order north, east, south, west: let `S` = the state at the neighbour; skip it if it is not scaffolding; `d = min(d, S.distance + 1)`; if `d == 1` stop the loop. The result is `d` |
| `isBottom(level, pos, d)` | `d > 0` and the state below is not scaffolding |
| Placement state | `waterlogged` = the fluid at the clicked position is water; `distance = getDistance(level, clickedPos)`; `bottom = isBottom(level, clickedPos, distance)` |
| `canBeReplaced(state, context)` | true when the held item is the scaffolding item (so scaffolding can be stacked onto scaffolding) |
| PL | on the server schedule a tick (delay 1) |
| SU | when waterlogged schedule a water tick (`Fluids.WATER.getTickDelay(level)`); on the server schedule a block tick (delay 1); the state is returned unchanged |
| `canSurvive` | `getDistance(level, pos) < 7` |
| ST | `d = getDistance(level, pos)`; `new = state with distance = d and bottom = isBottom(level, pos, d)`. If `new.distance == 7`: when the old `distance` was also 7, spawn a falling block (`FallingBlockEntity.fall(level, pos, new)`, entity default `dropItem` true, no hook, no hurting); otherwise (old distance below 7) `destroyBlock(pos, true)` (drops through the loot table). Otherwise, when `new != state`, `setBlockAndUpdate(pos, new)` |
| Selection | collision depends on the context; shapes are in 24 part 7 |

The two-stage collapse is therefore: a scaffolding block that loses all support first breaks and drops (on its first tick at distance 7, when it was previously supported), and one that already stored distance 7 falls. A scaffolding that was placed already unsupported (it stores 7) falls on its first tick. Because `fall` removes the block, the entity lands as a placed scaffolding if the landing cell can hold it (4.3).

### 3.8 Other users of the falling entity

`SpeleothemBlock` (pointed dripstone, sulfur spike) calls `FallingBlockEntity.fall` for stalactites and then `setHurtsEntities(scale, 40)` with a scale derived from the height of the column it came from; it also overrides `onBrokenAfterFall` (a landing sound event). `PowderSnowBlock` reads `instanceof FallingBlockEntity` in its collision shape rule (a falling block does not sink). Their own rules belong to the dripstone and snow documents (Open question 6).

## 4. The falling block entity (`FallingBlockEntity`)

Entity type `falling_block` (21 §8.4: 0.98 x 0.98, tracking range 10, update interval 20). 21 §8.4 summarises the entity; this section is the authoritative, complete description.

### 4.1 Fields, constants, spawn (`fall`)

| Field | Initial value | Notes |
|---|---|---|
| `blockState` | sand default state | wire: Add Entity `Data` = global state id |
| `time` | 0 | ticks lived |
| `dropItem` | true | |
| `cancelDrop` | false | `disableDrop()` sets true; anvil damage can set it (4.6) |
| `hurtEntities` | false | `setHurtsEntities` sets true |
| `fallDamagePerDistance` | 0.0 | |
| `fallDamageMax` | 40 | |
| `blockData` | null | `TileEntityData`; only from NBT (4.7) |
| `forceTickAfterTeleportToDuplicate` | false | 4.8 |
| metadata index 8 | `startPos` (BlockPos, default 0,0,0) | set to the block position of the spawn |

Entity default gravity is **0.04** per tick (`getDefaultGravity`); the air drag factor is **0.98** (`Entity.getAirDrag`, f32). Movement emission: none (no step sounds). `isAttackable` false; `isPickable` while not removed; `hurtServer` only marks the entity hurt (if not invulnerable to the base source) and returns false (the entity is damage-proof). `displayFireAnimation` false. `getMoveSimulationType`: SERVER_AND_CLIENT (the client simulates the same movement).

`FallingBlockEntity.fall(level, pos, state)` (static):
1. The entity's state is `state`, with `waterlogged` set to false when the state has that property.
2. The entity is created at `(pos.x + 0.5, pos.y, pos.z + 0.5)` with zero velocity; `xo, yo, zo` equal the position; `blocksBuilding` true; `startPos` = its block position.
3. The block at `pos` is replaced (`setBlockAndUpdate`, flags 3) by the legacy block of the fluid state of the old state (water for a waterlogged block, else air).
4. The entity is added with `addFreshEntity` and returned (the caller then runs the `falling` hook).

### 4.2 Tick (server, steps in order)

0. If the entity's state is air: discard and return.
1. `time += 1`.
2. `applyGravity` (velocity y -= 0.04), then `move(SELF, velocity)` (collision as 13 §1, 41 §3.3), then block effects and portal handling.
3. Everything below runs only on a server level, and only when the entity is alive (or `forceTickAfterTeleportToDuplicate`); on a client the tick ends after step 2 and step 9.
4. `pos` = the entity's block position. `isConcrete` = the state's block is a `ConcretePowderBlock`. `inWater` = `isConcrete and` the fluid at `pos` is in tag `water`.
5. `speedSq` = the squared length of the velocity (after the move). **Concrete powder reaching water:** if `isConcrete and speedSq > 1.0`: ray-clip from `(xo, yo, zo)` to the current position with block mode COLLIDER and fluid mode SOURCE_ONLY; if the clip hits a block and the fluid at the hit block position is in tag `water`, then `pos` = the hit block position and `inWater = true`.
6. **Landing test:** if `onGround` or `inWater`: go to 4.3. Otherwise go to 4.4 (expiry).
7. (the 4.3 and 4.4 results then fall through to 8)
8. (After the landing or expiry code, reached by every path on the server.) Velocity is multiplied by `getAirDrag()` (0.98) on all three axes. (The landing code of 4.3 has already multiplied by (0.7, -0.5, 0.7).)
9. `setRequiresPrecisePosition(horizontalCollision or verticalCollision)`.

### 4.3 Landing (when on the ground or in water, server)

1. `replaced` = the state at `pos`. Velocity is multiplied by `(0.7, -0.5, 0.7)`.
2. If `replaced` is `moving_piston`: stop (nothing else happens in this tick; the entity stays).
3. If `cancelDrop` is true: discard the entity, call `onBrokenAfterFall(level, pos, entity)` of the block (if it is `Fallable`), stop. (No item.)
4. Otherwise compute:
   - `canReplace` = `replaced.canBeReplaced(context)` where the context is a `DirectionalPlaceContext(level, pos, DOWN, empty stack, UP)` (29 §9.5: the default rule is the replaceable flag and an empty held stack, so any replaceable block qualifies; blocks with their own override decide for themselves);
   - `belowFree` = `isFree(state at pos.below()) and (not isConcrete or not inWater)`;
   - `canPlace` = `entityState.canSurvive(level, pos) and not belowFree`.
5. If `canReplace and canPlace` (**the block is placed**):
   a. If the entity state has `waterlogged` and the fluid at `pos` is the water source (`Fluids.WATER`): set `waterlogged = true` in the entity state.
   b. `setBlockAndUpdate(pos, entityState)` (flags 3). If it succeeded: send **Block Update** (05a 0x08, the position and the state now at `pos`) and then **Add Transient Block** (05a 0x25, position and state) to the players tracking the entity (`ChunkMap.sendToTrackingPlayers`); discard the entity; if the block is `Fallable`: call `onLand(level, pos, entityState, replaced, entity)`. Then block entity data: if `blockData != null` and the state has a block entity and there is a block entity at `pos`: the block entity is saved to a tag, every key of `blockData` is copied over the same key of the saved tag (replacing it), and the block entity is loaded from the merged tag; on an exception log "Failed to load block entity from falling block", and call `setChanged`. (`blockData` is not used for any natural fall, 4.7.)
   c. If `setBlockAndUpdate` returned false and `dropItem` is true and the game rule `entity_drops` is true: discard the entity, call the block's `onBrokenAfterFall`, spawn the block's item (4.5). If `dropItem` or the rule is false the entity is left in the world and is retried on the next tick.
6. Otherwise (**cannot be placed**): discard the entity; if `dropItem` and `entity_drops`: call `onBrokenAfterFall`, spawn the block's item (4.5). When `dropItem` or `entity_drops` is false: nothing else.

Placement therefore needs a replaceable cell, a surviving block, and a solid cell below it; a flying landing onto a slab corner, a torch or a fence is judged by the replace test and the "not free below" test.

### 4.4 Expiry (not on the ground and not in water)

If `time > 100` and the block y of `pos` is at or below the level's minimum y or above its maximum y (`getMinY`, `getMaxY`), or `time > 600`: if `dropItem` and `entity_drops` then spawn the block's item (4.5); then discard. (This path does not call `onBrokenAfterFall`.)

### 4.5 The item drop

`spawnAtLocation(level, blockAsItem)` spawns one item stack of the block's item at the entity's position with offset 0 (41 §2.0, first table row; the stack is the block's own item, not its loot table). The game rule `entity_drops` (33 §5) gates it. The item entity then follows 41.

### 4.6 Damage (`causeFallDamage`) and anvil damage

Called through the entity fall pipeline: `Entity.checkFallDamage` accumulates `fallDistance` (increase by the downward movement each tick when not in water), and when the entity moves onto the ground with `fallDistance > 0` it calls the landed-on block's `fallOn(level, state, pos, entity, fallDistance)`; `Block.fallOn` scales the distance by `(1 - block.getFallDistanceReduction())` (the reduction is a block property, 0 by default in 24 part 1; hay, beds and similar blocks set their own) and calls the entity's `causeFallDamage(distance, 1.0, fallDamageSource)` (read).

`FallingBlockEntity.causeFallDamage(distance, multiplier, source)`:
1. If `hurtEntities` is false return false.
2. `n = ceil(distance - 1)`. If `n < 0` return false.
3. The damage source is `Fallable.getFallDamageSource(entity)` of the block when it is `Fallable` (anvil: `anvil`), else damage type `falling_block` (entity as causing entity).
4. `damage = min(floor(n x fallDamagePerDistance), fallDamageMax)` as a float.
5. Every entity in the entity's bounding box (the entity itself excluded) that is a living entity, still alive, and not in creative or spectator mode receives `hurt(source, damage)` (also when the damage is 0).
6. If the entity state is in block tag `anvil` and `damage > 0` and `nextFloat() < 0.05 + n x 0.05` (float arithmetic, one `nextFloat` draw only when the first two tests pass): `damaged = AnvilBlock.damage(state)`; if it is null set `cancelDrop = true`, else the entity's state becomes `damaged` (so the anvil lands chipped or damaged).
7. Return false.

Damage reductions (helmets: `damages_helmet` for `falling_block` and `falling_anvil`, 17 Appendix on damage tags) are the damage pipeline's, not repeated.

### 4.7 Persistence (NBT) and Add Entity data

| Key | Type | Written | Read default |
|---|---|---|---|
| `BlockState` | block state codec (compound `Name`, `Properties`) | always | sand default state |
| `Time` | int | always | 0 |
| `DropItem` | byte (boolean) | always | true |
| `HurtEntities` | byte | always | true when the stored state is in tag `anvil`, else false |
| `FallHurtAmount` | float | always | 0.0 |
| `FallHurtMax` | int | always | 40 |
| `TileEntityData` | compound | only when `blockData != null` | absent (null) |
| `CancelDrop` | byte | always | false |

(Entity base keys: 45 part 1.) Wire: Add Entity (05a 0x01) with `Data` = `Block.getId(state)`; the client's `recreateFromPacket` reads the state with `Block.stateById(data)`, sets `blocksBuilding`, the position and `startPos`. The synchronised data (metadata index 8, BlockPos) carries the start position. The display name key is `entity.minecraft.falling_block_type` with the block's name as argument.

### 4.8 Teleport between dimensions

`teleport(transition)`: `forceTickAfterTeleportToDuplicate` is set true when the teleport produced a duplicate entity and exactly one of the source and target dimensions is the End (the test is "source is End xor target is End"); the tick of 4.2 then runs for the duplicate even though it is not alive. Used only for the End platform and gateway cases.

## 5. The bone meal framework

### 5.1 The interface (`BonemealableBlock`) and the source (`BonemealSource`)

`BonemealSource` is an enum with two values: `INTERACTION` (the bone meal item) and `MOB` (a bee growing a crop, `Bee$BeeGrowCropGoal`; not read in detail, Open question 7). `BonemealableBlock.Type` has two values: `NEIGHBOR_SPREADER` and `GROWER` (the default is `GROWER`).

| Method | Contract |
|---|---|
| `isValidBonemealTarget(level, pos, state, source)` | whether bone meal has an effect here (read-only) |
| `isBonemealSuccess(level, random, pos, state, source)` | a random test; whether `performBonemeal` runs. Most blocks return true |
| `performBonemeal(serverLevel, random, pos, state, source)` | apply the growth |
| `getType()` | `GROWER` by default |
| `getParticlePos(pos)` | for `NEIGHBOR_SPREADER`: `pos.above()`; for `GROWER`: `pos` (read: the particle position of the growth effect, 42 part 7 §8.3) |

### 5.2 Implementers (every class that declares the interface or inherits it; read as the classes whose constant pool names `BonemealableBlock`)

`AzaleaBlock`, `BambooSaplingBlock`, `BambooStalkBlock`, `BigDripleafBlock`, `BigDripleafStemBlock`, `BonemealableFeaturePlacerBlock`, `BushBlock` (the default, 5.4), `CocoaBlock`, `CropBlock` (6), `FireflyBushBlock`, `FlowerBedBlock`, `GlowLichenBlock`, `GrassBlock`, `GrowingPlantBodyBlock`, `GrowingPlantHeadBlock` (and with them kelp, weeping vines and the cave vines), `HangingMossBlock`, `MangroveLeavesBlock`, `MangrovePropaguleBlock` (uses `BonemealSource`), `MossyCarpetBlock`, `MushroomBlock`, `NetherFungusBlock`, `NetherrackBlock`, `NyliumBlock`, `PitcherCropBlock`, `RootedDirtBlock`, `SaplingBlock` (7), `SeagrassBlock`, `SeaPickleBlock`, `ShelfMushroomBlock`, `ShortDryGrassBlock`, `SmallDripleafBlock`, `StemBlock`, `SweetBerryBushBlock`, `TallDryGrassBlock`, `TallFlowerBlock`, `TallGrassBlock`. Their `performBonemeal` bodies belong to the sibling parts (1.2), except those of 5.4, 6 and 7.

### 5.3 The item flow (`BoneMealItem.useOn`; complements 17 §3.4)

1. `pos` = the clicked block position, `adjacent` = `pos.relative(clickedFace)`.
2. `growCrop(stack, level, pos)`: on the **clicked** block. If its block is a `BonemealableBlock` and `isValidBonemealTarget(level, pos, state, INTERACTION)`: on a server level, if `isBonemealSuccess(level, level.random, pos, state, INTERACTION)` then `performBonemeal(level, level.random, pos, state, INTERACTION)`; then (server only, on every valid target, whether or not the test passed) `stack.shrink(1)`. The function returns true for a valid target on both sides (the client returns without shrinking or growing). A creative-mode stack shrink is the stack's own rule (29 §9).
3. If step 2 returned true: on the server, send the use vibration (game event `item_interact_finish`) and level event **1505** at `pos`, data **15**; return SUCCESS_SERVER (client: SUCCESS).
4. Otherwise, if `isFaceSturdy(level, pos, clickedFace)` for the clicked block: `growWaterPlant(stack, level, adjacent, clickedFace)` (17 §3.4 gives its 128-attempt algorithm); if it returned true the server sends the vibration and event 1505 (data 15) and the item returns SUCCESS.
5. Otherwise PASS.

The `performBonemeal` and `isBonemealSuccess` random source is the **level's** random (`Level.getRandom`), the one shared with ticks (29 §5).

### 5.4 The default for `BushBlock` (flowers, bushes) and the spreader helpers

`BushBlock` (the base of many small plants; shape height 13 by default) implements the interface with the spreader helpers below (its `getType` was not overridden in the class read, so it reports the default `GROWER`):

| Method | Rule |
|---|---|
| `isValidBonemealTarget` | `hasSpreadableNeighbourPos(level, pos, state)`: some horizontal neighbour (north, east, south, west order) is air (`isEmptyBlock`) and the plant's state `canSurvive` there |
| `isBonemealSuccess` | always true |
| `performBonemeal` | `findSpreadableNeighbourPos(level, pos, state)`: the horizontal directions are put in a random permutation (`shuffledCopy`, the level's random) and the first neighbour that is air and where the state can survive is chosen; if one exists, `setBlockAndUpdate(thatPos, thisBlock.defaultBlockState())` |

The random permutation uses the level random once per `shuffledCopy`; the spread does not cost the bone meal item beyond the common step in 5.3.

## 6. Crop growth helpers (`CropBlock`)

`CropBlock extends VegetationBlock implements BonemealableBlock`; property `age` (default `AGE_7`, 0 to 7; `getAgeProperty()` and `getMaxAge()` are overridable and return 7); shape = a box column of height `2 x (age + 1)` (`SHAPES`, boxes of height 2 per age step: 2, 4, ... 16); `mayPlaceOn` = tag `supports_crops`; base seed `wheat_seeds` (`getBaseSeedId`, the pick-block item).

### 6.1 Predicates

| Predicate | Rule |
|---|---|
| `isMaxAge(state)` | `age >= getMaxAge()` |
| `isRandomlyTicking(state)` | `not isMaxAge(state)` |
| `hasSufficientLight(level, pos)` | `rawBrightness(pos, 0) >= 8` |
| `canSurvive(state, level, pos)` | `hasSufficientLight` and the `VegetationBlock` ground rule (`mayPlaceOn(state below)`) |
| `entityInside` | on a server level, a `Ravager` with the rule `mob_griefing` true destroys the block (`destroyBlock(pos, true, entity)`); otherwise the vegetation default |

### 6.2 Random tick

Conditions, all required: `rawBrightness(pos, 0) >= 9` and `age < getMaxAge()`. Then `speed = getGrowthSpeed(block, level, pos)` (6.3) and the crop advances when `nextInt(int(25.0f / speed) + 1) == 0`, where `int(...)` truncates toward zero and the division is float. On success `setBlock(pos, getStateForAge(age + 1), 2)`. Exactly one `nextInt` draw is made, and only when the two conditions held.

### 6.3 `getGrowthSpeed(block, level, pos)` (float)

Let `f = 1.0` and `below = pos.below()`.
1. For `dx` in -1, 0, 1 (outer) and `dz` in -1, 0, 1 (inner), the cell `c = below + (dx, 0, dz)`: `s = 0`; if the state at `c` is in tag `grows_crops` then `s = 1` and, if its `moisture` (read with default 0) is above 0, `s = 3`; if `dx != 0 or dz != 0` then `s = s / 4`; `f = f + s`.
2. Let `west`, `east`, `north`, `south` be the four horizontal neighbours of `pos`. `alongX` = the state at `west` or at `east` is the **same block** as `block`; `alongZ` = the state at `north` or at `south` is the same block.
3. If `alongX and alongZ`: `f = f / 2`. Otherwise, if any of the four diagonal cells (`west + north`, `east + north`, `east + south`, `west + south`) holds the same block: `f = f / 2`. The halving happens at most once.
4. Return `f`.

Values: the cell below only (nothing else around): `f = 1 + 1 = 2` for dry growing ground (`s = 1`); `f = 1 + 3 = 4` for hydrated ground; a full 3 x 3 of hydrated ground gives `1 + 3 + 8 x 0.75 = 10`; a full 3 x 3 of dry ground gives `1 + 1 + 8 x 0.25 = 4`. A crop row along one axis only (neighbours on `west` or `east` but none on `north`, `south` or the diagonals) is **not** halved.

### 6.4 Bone meal

| Method | Rule |
|---|---|
| `isValidBonemealTarget` | `not isMaxAge(state)` |
| `isBonemealSuccess` | always true |
| `performBonemeal` -> `growCrops(level, pos, state)` | `newAge = min(getMaxAge(), age + U(2, 5))`, one `nextInt(4)` draw (the level random); `setBlock(pos, getStateForAge(newAge), 2)` |

Subclasses may override `getBonemealAgeIncrease` (the age step), `getAgeProperty`, `getMaxAge` (siblings, part 2).

## 7. Saplings and the tree growth trigger

### 7.1 `SaplingBlock`

Property `stage` (0 or 1, default 0); shape 12 x 12 column of height 12; fields `treeGrower`. Constants `BRIGHTNESS_FOR_SAPLING_GROWTH` 9, `TICK_CHANCE_FOR_SAPLING_GROWTH` 7. It is a `VegetationBlock` (ground rule: tag `supports_vegetation`).

| Trigger | Rule |
|---|---|
| RT | if `maxLocalRawBrightness(pos.above()) >= 9` and `nextInt(7) == 0`: `advanceTree(level, pos, state, random)`. Light uses the one-argument form (sky darkening of the current time) |
| `advanceTree` | if `stage == 0`: `setBlock(pos, state.cycle(stage), 260)` (stage 1, no neighbour update, no client send); else `treeGrower.growTree(level, chunkGenerator, pos, state, random)` (7.3) |
| `isValidBonemealTarget` | requires a server level; `treeGrower.canGrow(level, pos, state)` (7.2); and `pos.above(minHeight)` is inside the build height, where `minHeight` = `treeGrower.getMinimumHeight(level)` (7.2), 0 when empty |
| `isBonemealSuccess` | `level.getRandom().nextFloat() < 0.45` (a double compare against 0.45; one draw from the level random, not the parameter) |
| `performBonemeal` | `advanceTree` (so one successful bone meal advances stage 0 to 1, and a second one grows the tree) |

Registered saplings use the growers `OAK`, `SPRUCE`, `BIRCH`, `JUNGLE`, `ACACIA`, `CHERRY`, `DARK_OAK`, `PALE_OAK`, `POPLAR` (1.3); `mangrove_propagule` and `azalea` use `MANGROVE` and `AZALEA` through their own classes.

### 7.2 `TreeGrower` data and queries

A grower has: a name; `trees` (a weighted list of configured feature keys); `megaTrees` (the 2 x 2 variants); `flowerTrees` (the variants used when flowers are near); `shortestTreeType` (a feature key or null). The table is in 7.4.

| Query | Rule |
|---|---|
| `getConfiguredFeature(random, flowers)` | if `flowers` and `flowerTrees` is not empty: one weighted draw from `flowerTrees`; otherwise one weighted draw from `trees` (an empty list yields null and consumes no draw) |
| `getConfiguredMegaFeature(random)` | one weighted draw from `megaTrees` (null when empty, no draw) |
| weighted draw (`WeightedList.getRandom`) | empty list: no draw; otherwise one `nextInt(totalWeight)` draw and the entry whose cumulative weight range (in list order) contains the value (cumulative order inferred from the helper, Open question 2). A single-entry list still consumes one `nextInt(weight)` draw |
| `hasFlowers(level, pos)` | any block in the box `pos + (-2, -1, -2)` to `pos + (2, 1, 2)` (inclusive corners, 5 x 3 x 5 cells) whose state is in block tag `flowers` |
| `getMinimumHeight(level)` | if `shortestTreeType` is null: empty (0 for the caller). Else the registered feature: if it is a `TreeFeature` then its `trunkPlacer.getBaseHeight()`; otherwise empty |
| `canGrow(level, pos, state)` | draws `normal = getConfiguredFeature(level.getRandom(), hasFlowers(level, pos))` and **then** `mega = getConfiguredMegaFeature(level.getRandom())` (both draws are made, in that order, from the level random, every time the bone meal target test runs); if `normal == null and mega != null`: the result is whether a 2 x 2 group of the same sapling exists (7.3); otherwise true |
| `findTwoByTwoSaplingPos(level, state, pos)` | for `dx` in 0 then -1 (outer) and `dz` in 0 then -1 (inner): the four cells `(dx, dz)`, `(dx + 1, dz)`, `(dx, dz + 1)`, `(dx + 1, dz + 1)` relative to `pos` (at the same y); the first `(dx, dz)` for which all four hold the same block as `state` is the result: offsets `(dx, dz)`; order of tries: (0, 0), (0, -1), (-1, 0), (-1, -1) |

### 7.3 `growTree(level, generator, pos, state, random)` (trigger and rollback)

1. `mega = getConfiguredMegaFeature(random)` (one draw when `megaTrees` is not empty). If `mega` is not null **and** it is registered in the feature registry **and** `findTwoByTwoSaplingPos` finds a group: let `(ox, oz)` be its offsets and `group` the four (state, position) pairs read before any change.
   a. Remove the four saplings (each: `setBlock(p, legacy block of the fluid at p, 818)`), then run the feature's `place(level, generator, random, pos + (ox, 0, oz))`.
   b. If it returned true: the result is true. Otherwise restore all four saplings (`setBlock(p, savedState, 260)` each) and return false. (There is no fallback to the one-sapling tree in this branch.)
2. Otherwise (no mega feature, not registered, or no 2 x 2 group): `key = getConfiguredFeature(random, hasFlowers(level, pos))` (7.2). If it is null: return false. If it is not registered: return false.
3. Remove the single sapling (`setBlock(pos, legacy block of the fluid, 818)`), run `place(level, generator, random, pos)`. If true: return true. Otherwise `setBlock(pos, savedState, 260)` (the sapling returns with its old stage, 1) and return false.

`place` is the configured tree feature (35 part 1: placement and rollback inside the feature; the tree shapes 35 parts 3 and 4). A failed attempt therefore leaves the sapling at stage 1; the next random tick that passes the light test and the 1-in-7 draw tries again.

### 7.4 The grower table (code constants of `TreeGrower`; the feature keys are the configured features of the data pack, `data/worldgen`)

| Grower | `trees` (weights) | `megaTrees` | `flowerTrees` | `shortestTreeType` |
|---|---|---|---|---|
| `OAK` | `oak` 9, `fancy_oak` 1 | none | `oak_bees_005` 9, `fancy_oak_bees_005` 1 | `oak` |
| `SPRUCE` | `spruce` | `mega_spruce` 1, `mega_pine` 1 | none | `spruce` |
| `MANGROVE` | `mangrove` 15, `tall_mangrove` 85 | none | none | `mangrove` |
| `AZALEA` | `azalea_tree` | none | none | `azalea_tree` |
| `BIRCH` | `birch` | none | `birch_bees_005` | `birch` |
| `JUNGLE` | `jungle_tree_no_vine` | `mega_jungle_tree` | none | `jungle_tree_no_vine` |
| `ACACIA` | `acacia` | none | none | `acacia` |
| `CHERRY` | `cherry` | none | `cherry_bees_005` | `cherry` |
| `DARK_OAK` | none | `dark_oak` | none | null |
| `PALE_OAK` | none | `pale_oak_bonemeal` | none | null |
| `POPLAR` | `red_poplar` 1, `orange_poplar` 1, `yellow_poplar` 1 | none | none | `red_poplar` |

A weight is shown where the list has more than one entry; a single-entry list has weight 1 (the artifact builds it with `WeightedList.of(key)`). Entries are listed in construction order (the order that decides the cumulative ranges). The names are the `TreeFeatures` keys (`OAK`, `FANCY_OAK`, `OAK_BEES_005`, ...) lower-cased: the registry path is the lower-case field name (inferred from the key naming, Open question 3). `dark_oak` and `pale_oak` have no 1 x 1 tree: a lone sapling can never be a bone meal target (7.2, `canGrow` needs the 2 x 2 group) and never grows by random tick (7.3 returns false at step 2). Growers are also registered by name in a map used by the codec (`oak`, `spruce`, `mangrove`, `azalea`, `birch`, `jungle`, `acacia`, `cherry`, `dark_oak`, `pale_oak`, `poplar`).

## 8. Worked examples

**8.1 Sand falling two blocks.** Sand at (10, 66, 10); air at (10, 65, 10) and (10, 64, 10); stone at (10, 63, 10). A neighbour update at game tick T schedules a tick for T + 2. At T + 2 the cell below is air (free) and 66 >= minY: `fall` sets (10, 66, 10) to air, creates an entity at (10.5, 66.0, 10.5) with `startPos` (10, 66, 10). Per tick the velocity y becomes `v - 0.04` before the move, and `x 0.98` after: the fall distance after each tick is 0.04, 0.1192, 0.236816, 0.39208, 0.584238, 0.812553, 1.076302, 1.374776, 1.707281, 2.073135 (ticks 1 to 10). In tick 10 the move is clamped at 2.0 and the entity is on the ground: `pos` = block position (10, 64, 10); it is air (replaceable), `sand.canSurvive` is true, the cell below (stone) is not free: sand is placed at (10, 64, 10) with flags 3, Block Update and Add Transient Block go to tracking players, the entity is discarded. Velocity was multiplied by (0.7, -0.5, 0.7) first.

**8.2 Anvil on a player.** An anvil falls 2.0 blocks onto a player standing in the landing cell: when the entity reaches the ground, `fallDistance` = 2.0, `fallOn` calls `causeFallDamage(2.0, 1.0, fall)`: `n = ceil(2.0 - 1) = 1`; `damage = min(floor(1 x 2.0), 40) = 2.0`; the player takes 2.0 `anvil` damage; the chip test: `nextFloat() < 0.05 + 1 x 0.05 = 0.10`. A fall of 4.0 blocks: `n = 3`, damage 6.0, chip chance 0.20. A fall of 21 blocks: `n = 20`, `floor(40.0) = 40`; at 22 blocks `floor(42) = 42` is capped at 40.

**8.3 Chip chain.** Anvil lands, chip roll succeeds: state becomes `chipped_anvil` (same facing), placed on landing, event 1031. Next fall: `damaged_anvil`. Next success: `damage()` returns null, `cancelDrop = true`: on landing the entity is discarded with no block placed and no item, `onBrokenAfterFall` plays event 1029.

**8.4 Concrete powder in water.** Powder falls into a still water column (the water cell is the landing cell): the entity lands when its position is in water (4.2 step 4 `inWater`): `replaced` = water (replaceable); `canPlace` = survives and `belowFree` is evaluated with `not (isConcrete and inWater)` = false, so below is "not free" for placement purposes whatever is under the water: the powder is placed (flags 3), then `onLand` sees `replaced` = water: `shouldSolidify` is true: the cell becomes concrete.

**8.5 Crop growth speed and chance.** Wheat on hydrated farmland with a 3 x 3 of hydrated farmland and no wheat beside it at light 15: `f = 10`; `int(25 / 10) + 1 = 3`; each random tick grows it with chance 1/3; with `random_tick_speed` 3 the expected random ticks per game tick for that block are 3 / 4096 (2.3). A wheat row east-west (neighbours west and east are wheat, none north or south, none diagonal): the row test is false for `alongZ`, so `alongX and alongZ` is false; the diagonals include `west + north` etc. which are not wheat, so no halving: `f` stays 10. With an additional wheat at the north cell: both axes: `f = 5`; `int(25 / 5) + 1 = 6`: chance 1/6.

**8.6 Bone meal on wheat.** Age 2, bone meal: valid (age < 7); success true; `growCrops` draws `nextInt(4)`: value 3 gives `U(2,5) = 5`; new age = `min(7, 2 + 5) = 7`; the stack shrinks by 1; event 1505 data 15 at the crop position.

**8.7 Sapling.** Oak sapling stage 0 at light 12: random tick passes the 1-in-7 draw: stage 1 (flags 260). Next passing tick: `growTree`: `oak` has no mega list so the draw in step 1 does nothing; `hasFlowers`: a dandelion within the 5 x 3 x 5 box selects `flowerTrees`: one `nextInt(10)` draw: values 0 to 8 `oak_bees_005`, 9 `fancy_oak_bees_005`. The sapling is replaced by air (flags 818), the feature places the tree; on failure the stage-1 sapling is restored (flags 260).

## 9. Validation

| # | Check | Expected |
|---|---|---|
| V1 | Sand placed over air: tick delay and result | tick at +2; entity created; cell becomes air; entity at (x + 0.5, y, z + 0.5) |
| V2 | Falling distance table in 8.1 | matches the ten values |
| V3 | A fall into a cell whose block is not replaceable (any block without the replaceable flag) | `canReplace` false: item dropped, no block placed (4.3 step 6) |
| V4 | A fall into a cell with snow layers or grass | replaceable: the block replaces it (flags 3) |
| V5 | `entity_drops` false, block cannot be placed | the entity is discarded with no item; with `dropItem` false the entity persists |
| V6 | `time = 101` at y below the world: not on the ground | item drop and discard |
| V7 | `time = 601` anywhere in the air | item drop and discard |
| V8 | Anvil fall damage table of 8.2 | 2.0, 6.0, 40 |
| V9 | Damaged anvil chip roll success | no placement, no item |
| V10 | Suspicious sand falls | discarded on landing, event 2001, no item |
| V11 | Dragon egg click with air at the 1000th attempt only | teleports after 1000 attempts' draws (6000 draws) |
| V12 | Scaffolding with stored distance 7 and no support | falls as entity on its first tick |
| V13 | Scaffolding with stored distance 3 that loses support | computes 7: `destroyBlock(pos, true)` drops items |
| V14 | `getGrowthSpeed` table in 6.3 | 2, 4, 10, 4 |
| V15 | Bone meal on max-age crop | not a valid target: no shrink, no event |
| V16 | Bone meal on a sapling whose 45% test fails | stack still shrinks by 1, event 1505 still sent |
| V17 | Dark oak sapling alone, bone meal | invalid (no 2 x 2) |
| V18 | Dark oak 2 x 2 at stage 1, fully lit | tree attempt; saplings removed with flags 818, restored with 260 on failure |
| V19 | `canGrow` random draws | two draws on the level random before each target check (normal pick, then mega pick) |
| V20 | Flower near an oak sapling | 5 x 3 x 5 box centred horizontally on the sapling, y from -1 to +1 |

## 10. Open questions

1. The sibling split of 1.2 is a proposal; the real files and numbering of parts 2 to 7 may differ, and the table of 1.3 must then be extended by the owners of those parts.
2. `WeightedList.getRandom` was read as "draw `nextInt(totalWeight)` then `Selector.get(value)`"; the selector's internal ordering (cumulative in list order) was not read and is (inferred) from `WeightedRandom.getWeightedItem`.
3. The feature keys of 7.4 are the field names of `TreeFeatures` lower-cased (inferred); their registry paths were not read from the data pack, which the extraction tool provides (22, 23).
4. The default value of `Block.getFallDistanceReduction` was not read (it is a builder-supplied field); only the formula is read (4.6).
5. `Entity.move`, `onGround`, `horizontalCollision` and the clip of 4.2 step 5 follow 13, 41 and 18; the `ClipContext` COLLIDER/SOURCE_ONLY semantics were not read here.
6. `SpeleothemBlock` (pointed dripstone, sulfur spike), `PowderSnowBlock` and the sound mapping of level events 1029, 1031, 2015 were not specified here beyond the calls named in 3.8, 3.4 and 3.6.
7. The `MOB` bone meal source (`Bee$BeeGrowCropGoal`) and the implementer-specific uses of `BonemealSource` were not read.
8. Client rendering of the falling block entity (the model, interpolation, dust particle geometry `ParticleUtils.spawnParticleBelow`) was not read.
9. The ambient sand sound player called by `SandBlock.animateTick` was not read.
10. The block entity restore path (4.3 step 5b) was read from the bytecode; its only producer of `blockData` is NBT (`TileEntityData`), for example `/summon` or a data pack; no other producer was found among the classes that reference the entity (the list of referencing classes was: `AnvilBlock`, `ConcretePowderBlock`, `SpeleothemBlock`, `BrushableBlock`, `Fallable`, `ScaffoldingBlock`, `FallingBlock`, `PowderSnowBlock`, `EntityTypes`).
11. The brushable falling case: whether the block entity's stored loot item is intentionally dropped is not stated by the artifact; the section 3.5 consequence is read from `disableDrop` plus the landing code.
12. The mangrove propagule and azalea sapling-like paths (`MangrovePropaguleBlock`, `AzaleaBlock`) use `TreeGrower.MANGROVE` and `AZALEA` through own bone meal rules not read here.
