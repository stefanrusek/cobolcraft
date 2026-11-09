# 29a. Fluids: flow, states, waterlogging, buckets, bubble columns, entity interaction

| | |
|---|---|
| Covers | The fluid engine of Java Edition 26.3: the five fluids and their states (amount, falling, source), the legacy liquid blocks and their ids, the fluid tick (new level from neighbours, source conversion, falling, sideways spread, slope finding toward holes, per-dimension delays and distances), the water and lava interaction (obsidian, cobblestone, stone, basalt, evaporation), lava's random tick (fire) and entity effects, the liquid-container interfaces (waterlogging, kelp, seagrass, sponge), bubble column entity effects, buckets (water, lava, powder snow, mobs, dispenser), the entity fluid interaction (heights, eye in fluid, flow vectors, pushing, swimming flags, splash, inside-block effects), fluid tags and their gameplay use, and the fluid mesh parameters of the client renderer (heights, corner averaging, sprites, tint, light, overlay). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the jar's data files (`tags/fluid`, `tags/block`, `dimension_type`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS10 (GAP-9 of `../design/README.md` Part 5) |
| Data versus code | Tag contents, dimension attributes and block registry rows are DATA (tags 04 §3, registry 24, dimension types 04 §6). This document specifies the engines that read them and quotes the few tag members that gameplay rules name (section 9). The block ids of water, lava and the bubble column are registry rows (24 part 1 section 15, 24 part 7 section 5.2) and are repeated here only as ids. |
| Out of scope | Item entities in fluid, cauldrons (Open question 13), powder snow bucket pickup (10), boats (7, 44 part 8) and the Strider (12, 44 part 6). |
| Reads | 29 (update flags, scheduled ticks, `setBlock` pipeline), 33 §2.4 (random ticks), 24 (liquid block row, bubble column), 13 §1.3 and 18 (movement in fluids, drowning, fire), 43 §2.1 (water tint), 12 (fog), 42 (drip particles). |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions. Heights and levels are in blocks; one tick is 1/20 s.

## 0. Reader's map

| Section | Subject |
|---|---|
| 1 | Fluids, fluid states, amounts, heights, the legacy liquid block and its ids |
| 2 | The fluid tick: scheduling, new level, source conversion, falling, spread, slopes, delays |
| 3 | Water and lava interaction |
| 4 | Lava specifics: random tick, entity effects, client ambience |
| 5 | Liquid containers: waterlogging, kelp and seagrass, sponge |
| 6 | Bubble columns: entity effects (the block is in 24 part 7 section 5.2) |
| 7 | Buckets and dispensers |
| 8 | Entity fluid interaction |
| 9 | Fluid tags, block tags and attributes that the rules use |
| 10 | Client fluid mesh |
| 11 | Worked examples |
| 12 | Validation |
| 13 | Open questions |

## 1. Fluids and fluid states

### 1.1 The five fluids

Registry ids (46 §5.3): 0 `empty`, 1 `flowing_water`, 2 `water`, 3 `flowing_lava`, 4 `lava`. `Fluids` registers them in that order. Water and lava each have a flowing form and a source form that are different registry entries; a rule that says "the same fluid" uses `isSame`, which for water accepts both `water` and `flowing_water` (likewise lava), and is false for everything else.

| Fluid | Properties | States | Amount | `isSource` | Bucket item | Explosion resistance |
|---|---|---|---|---|---|---|
| `empty` | none | 1 | 0 | no | none (`air`) | 0 |
| `flowing_water`, `flowing_lava` | `falling` (boolean), `level` (integer 1 to 8, `LEVEL_FLOWING`) | 16 | the `level` value | no | water bucket, lava bucket | 100.0 |
| `water`, `lava` | `falling` (boolean) | 2 | 8 | yes | water bucket, lava bucket | 100.0 |

`FlowingFluid.getFlowing(amount, falling)` is the flowing fluid's state with `level` = amount and `falling`; `getSource(falling)` is the source state. Every fluid state the engine creates is one of those two forms; the code that creates sources always passes `falling` = false (read at every call site: conversion, liquid block, bubble column, waterlogged blocks). A `FluidState` is `full` when its amount is 8 (every source and the flowing level 8). `AMOUNT_MAX` is 9 and `AMOUNT_FULL` is 8: the value 9 never occurs in this version, because no state has amount 9 (the shape code tests for it, section 1.3).

The fluid-state registry (`Fluid.FLUID_STATE_REGISTRY`, an id mapper filled in fluid registry order and, within a fluid, in the state definition's order) holds 1 + 16 + 2 + 16 + 2 = 37 states. It is an internal table: no packet in 05 carries a fluid state id (chunk sections carry only a fluid **count**, 06 §4). The order of the 16 flowing states inside a fluid was not read (Open question 1).

### 1.2 The legacy liquid blocks (`LiquidBlock`)

Water is block id 37 with 16 states (state ids 89 to 104, `level` 0 to 15, default `level` 0), lava is block id 38 with 16 states (ids 105 to 120). `level` is `BlockStateProperties.LEVEL` (0 to 15), not the flowing-fluid property. The bubble column is block 886 (24 part 7 section 5.2): state id 18651 is `drag` = true (default) and 18652 is `drag` = false.

**Block state to fluid state** (`LiquidBlock.getFluidState`): index = min(level, 8); index 0 is the source; indexes 1 to 7 are the flowing fluid with amount 8 - index and `falling` false; index 8 is the flowing fluid with amount 8 and `falling` true. So block levels 8 to 15 all mean "falling, amount 8".

**Fluid state to block state** (`createLegacyBlock`, `FlowingFluid.getLegacyLevel`): source gives level 0; a flowing state gives (8 - min(amount, 8)) + (8 if falling). The engine never produces a flowing state with amount 8 and `falling` false (a neighbour source gives at most 8 - dropOff and "fluid above" gives amount 8 with `falling` true), so the one collision of that formula with level 0 is unreachable. The empty fluid's legacy block is `air`.

| Fluid state | Legacy block level | Block state id (water) | Block state id (lava) |
|---|---|---|---|
| source | 0 | 89 | 105 |
| flowing amount 7 | 1 | 90 | 106 |
| flowing amount 6 | 2 | 91 | 107 |
| flowing amount 5 | 3 | 92 | 108 |
| flowing amount 4 | 4 | 93 | 109 |
| flowing amount 3 | 5 | 94 | 110 |
| flowing amount 2 | 6 | 95 | 111 |
| flowing amount 1 | 7 | 96 | 112 |
| flowing amount 8, falling | 8 | 97 | 113 |
| (levels 9 to 15, never produced by the engine, read as the same falling state) | 9 to 15 | 98 to 104 | 114 to 120 |

Block-level facts (24 part 1 section 14 holds the rest): render shape invisible, `getShape` empty, `propagatesSkylightDown` false, `getDrops` empty, replaceable, no collision flag, `liquid()` flag; pathfinding is allowed unless the fluid is in the `lava` tag.

Collision shape (`LiquidBlock.getCollisionShape`), in order: (1) the full cube when the context says `alwaysCollideWithFluid`; (2) the empty shape when `level` is not 0; (3) when the context is an entity context whose entity is a living entity, the entity's `getLiquidCollisionShape()` (empty by default, a half-height column for the Strider) if that context says the entity is above the shape (`isAbove(shape, pos, true)`) and `canStandOnFluid(fluid above, this fluid)` is true; otherwise empty. `LivingEntity.canStandOnFluid` is false by default and the Strider overrides it to "the fluid is in the `lava` tag". So only the source (level 0) lava block can be walked on, and only by a Strider.

### 1.3 Heights and shapes

| Quantity | Value |
|---|---|
| own height (`getOwnHeight`) | amount / 9 (so source 0.8888889, flowing 1/9 to 8/9; empty 0) |
| height (`getHeight(level, pos)`) | 1.0 when the block above holds the same fluid (`isSame`), otherwise the own height |
| shape (`getShape`) | the box (0,0,0) to (1, height, 1); the full block when amount is 9 and the same fluid is above (never occurs); the empty shape for the empty fluid |
| box in world (`getAABB`) | (x, y, z) to (x+1, y + height, z+1); none for the empty fluid |
| camera height (`getHeightForCamera`) | 1.0 when the state is a source and the block above has a sturdy DOWN face; otherwise the height |

`FlowingFluid.getShape` caches one box per fluid state keyed by identity; because the height depends on the block above, the lambda captures the position that first requested the state (a quirk, not relied on: the only case where the cache could mix two heights is a state that is also full-height from above, and that is answered before the cache is consulted).

### 1.4 Flow vector (`FlowingFluid.getFlow`)

The flow vector of a flowing fluid state at a position is a unit-or-zero vector used by entities (section 8) and by the renderer (section 10). Algorithm:

1. `sum` = (0, 0). For each horizontal direction d (iteration order `Direction.Plane.HORIZONTAL`) with neighbour position n:
   1. Let `N` = the fluid state at n. If `N` is neither empty nor the same fluid, skip this direction (`affectsFlow`).
   2. `h` = `N.getOwnHeight()` (0 for empty). `delta` = 0.
   3. If `h` = 0: when the block at n is **not** in block tag `blocks_fluid_flow`, look at the fluid state `B` at n below: if `B` is empty or the same fluid and `B.getOwnHeight()` = `hb` > 0, `delta` = own height of this state - (`hb` - 0.8888889).
   4. Else if `h` > 0: `delta` = own height of this state - `h`.
   5. If `delta` is not 0: `sum.x += stepX(d) x delta`, `sum.z += stepZ(d) x delta`.
2. `result` = (sum.x, 0, sum.z).
3. If this state has `falling` true: for each horizontal direction d with neighbour n, if `isSolidFace(n, d)` or `isSolidFace(n above, d)`, then `result` = normalize(`result`) + (0, -6, 0) and stop looking.
4. Return normalize(`result`) (the zero vector stays zero).

`isSolidFace(p, d)`: false when the fluid at p is the same fluid; true when d is UP; false when the block at p is an `IceBlock` instance; otherwise the block's `isFaceSturdy(p, d)`. (In step 3 the face tested is the one on the neighbour's side facing the falling column's direction of travel `d`, exactly as the arguments are passed: neighbour position and the same direction.) The empty fluid's flow is the zero vector. A source fluid uses the same algorithm (its flow points away from higher neighbours; a lone source has flow zero).

## 2. The fluid tick

### 2.1 Where fluid ticks are scheduled

A fluid tick is a scheduled tick whose type is a fluid (29 §4: queue keyed by type and position; delay from now; the consumer of 29 §4.3 calls `Fluid.tick` only if the fluid at the position is still that fluid). The sources of fluid ticks:

| Trigger | Condition | Delay | Reference |
|---|---|---|---|
| `LiquidBlock.onPlace` and `LiquidBlock.neighborChanged` | `shouldSpreadLiquid` true (section 3.1; always true for water) | the fluid's `getTickDelay` | the fluid at the position, not necessarily `this.fluid` |
| `LiquidBlock.updateShape` | this state or the changing neighbour's state holds a **source** | `getTickDelay` of this block's fluid | uses `ScheduledTickAccess` (29 §3) |
| waterlogged blocks' `updateShape` | `waterlogged` true | water's tick delay (5) | per block (section 5.1) |
| kelp, seagrass, tall seagrass, bubble column `updateShape` | always for the bubble column; seagrass: when the **neighbour state is not air** (read: `isAir` negated); kelp heads and plants: through the growing-plant base (not re-read) | water's tick delay | sections 5.2, 6 |
| `FlowingFluid.tick` after changing the state | the new state is non-empty and different from the old | `getSpreadDelay` | section 2.2 |
| `SimpleWaterloggedBlock.placeLiquid` | after setting `waterlogged` | the placed fluid's tick delay | section 5.1 |
| chunk generation | aquifer or carver fluid cells flagged for post-processing | (10 §9) | not repeated |

Every fluid state placed by `FlowingFluid.spreadTo` is written with `setBlockAndUpdate` (flags 3), so the new `LiquidBlock.onPlace` schedules the next tick; spreading never schedules directly.

**Tick delays** (`getTickDelay`, from the dimension's environment attribute `gameplay/fast_lava`, a non-positional boolean, default false; the jar's `the_nether` dimension type sets it true, the overworld, overworld caves and end leave the default):

| Fluid | Delay | Slope find distance | Drop-off per step |
|---|---|---|---|
| water (both forms) | 5 | 4 | 1 |
| lava, `fast_lava` false | 30 | 2 | 2 |
| lava, `fast_lava` true | 10 | 4 | 1 |

`getSpreadDelay(level, pos, current, new)` is the tick delay, except for lava: when both states are non-empty, neither is falling, the height of `new` at the position is greater than the height of `current`, and `level.random.nextInt(4)` is not 0 (3 chances in 4), the delay is multiplied by 4 (120 or 40 ticks). The level random is the world's `random` (33). Water always uses the plain delay.

### 2.2 `FlowingFluid.tick(level, pos, blockState, fluidState)`

1. If `fluidState` is not a source:
   1. `new` = `getNewLiquid(level, pos, level.getBlockState(pos))` (section 2.3). `delay` = `getSpreadDelay(level, pos, fluidState, new)`.
   2. If `new` is empty: set the block to `air` with `setBlockAndUpdate`.
   3. Else if `new` is not the same state object as `fluidState` (state identity, i.e. a different amount or falling flag): set the block to `new.createLegacyBlock()` with `setBlockAndUpdate`, and schedule a fluid tick at `pos` for `new`'s fluid with `delay`.
   4. In either case, the local `fluidState` and `blockState` used by step 2 are the new ones.
2. Call `spread(level, pos, blockState, fluidState)` (section 2.4). This happens for sources too and also when the state did not change.

So an unchanged flowing cell reschedules nothing: it ticks again only when a neighbour or shape update schedules it.

### 2.3 `getNewLiquid(level, pos, state)`: the state a cell should have

Inputs: the cell position and its block state. Only the four horizontal neighbours and the cells above and below are read.

1. `maxAmount` = 0, `sources` = 0. For each horizontal neighbour n with block state `S` and fluid `F`: if `F` is not the same fluid as this one, skip. If `canPassThroughWall(d, level, pos, state, n, S)` (section 2.6): if `F` is a source, `sources += 1`; `maxAmount = max(maxAmount, F.getAmount())`.
2. **Source conversion.** If `sources >= 2` and `canConvertToSource(level)`: let `B` be the block state below. If `B.isSolid()` (the cached solid flag of the state) or the fluid of `B` is a source of this fluid, return the **source** state (`falling` false).
3. **Fluid above.** Let `A` be the state above with fluid `FA`. If `FA` is non-empty and the same fluid and `canPassThroughWall(UP, level, pos, state, above, A)`, return the flowing state with amount 8 and `falling` true.
4. `amount` = `maxAmount` - `dropOff`. If `amount` <= 0 return the empty state; otherwise the flowing state with `amount` and `falling` false.

`canConvertToSource`: water reads the game rule `water_source_conversion` (default **true**), lava reads `lava_source_conversion` (default **false**) (read in `GameRules`; 16 §4.10 table). The sources counted in step 1 include only sources reached through `canPassThroughWall`. Both rules sit in the category UPDATES.

### 2.4 `spread(level, pos, blockState, fluidState)`

1. If `fluidState` is empty, return.
2. Let `below` = pos below with state `Bs` and fluid `Bf`.
3. If `canMaybePassThrough(level, pos, blockState, DOWN, below, Bs, Bf)` (section 2.6):
   1. `new` = `getNewLiquid(level, below, Bs)`; `type` = its fluid.
   2. If `Bf.canBeReplacedWith(level, below, type, DOWN)` (section 2.7) and `canHoldSpecificFluid(level, below, Bs, type)` (section 2.6): `spreadTo(level, below, Bs, DOWN, new)` (section 2.8); then, if the number of horizontal neighbours that are sources of this fluid (`sourceNeighborCount`) is **3 or more**, also `spreadToSides(...)`. Return in every case that entered step 3.2's `if`.
   3. (If the `if` of 3.2 fails, execution continues with step 4.)
4. Otherwise: if `fluidState` is a source, or the cell is **not** a water hole (`isWaterHole(level, pos, blockState, below, Bs)`, section 2.5), call `spreadToSides`. A flowing cell that is a hole does not spread sideways.

A cell above a source of the same fluid fails 3's `canMaybePassThrough` (a source of this type cannot be passed into) and, being a hole by 2.5, spreads nowhere: flowing water on a source stays put.

### 2.5 Holes and slope finding

`isWaterHole(level, pos, state, belowPos, belowState)`: false unless `canPassThroughWall(DOWN, level, pos, state, belowPos, belowState)`; then true when the fluid at `belowPos` is the same fluid, else `canHoldFluid(level, belowPos, belowState, flowing fluid)` (section 2.6). In words: a hole is a cell the fluid can fall into (open below) or already falls into.

`spreadToSides(level, pos, fluidState, blockState)`:

1. `amount` = `fluidState.amount - dropOff`; if `fluidState` is falling, `amount` = 7. If `amount` <= 0, return (a falling cell always tries; a flowing cell stops when its amount is not above the drop-off).
2. `map` = `getSpread(level, pos, blockState)`. For each (direction, new state) in `map`, `spreadTo(level, pos.relative(direction), the block state there, direction, new state)`.

`getSpread(level, pos, state)` returns a map direction to fluid state:

1. `minDist` = 1000; `map` empty; the slope context (`SpreadContext`: a cache of block states and hole flags keyed by the horizontal offset from `pos`, offset + 128 in each axis, in one short) is created lazily.
2. For each horizontal direction d (order `HORIZONTAL`) with neighbour n, block state `S`, fluid `F`:
   1. Skip unless `canMaybePassThrough(level, pos, state, d, n, S, F)`.
   2. `new` = `getNewLiquid(level, n, S)`. Skip unless `canHoldSpecificFluid(level, n, S, new's fluid)`.
   3. `dist` = 0 if `isHole(n)` (the cached `isWaterHole` for n and the cell below it), otherwise `getSlopeDistance(level, n, 1, opposite(d), S, context)`.
   4. If `dist < minDist`, clear `map`. If `dist <= minDist`: if `F.canBeReplacedWith(level, n, new's fluid, d)` (section 2.7), `map[d] = new`; and set `minDist = dist`.
3. Return `map`.

So the cell spreads only to the horizontal directions that share the smallest distance to a hole; when no hole is found within the find distance, every direction has distance 1000 and all open directions get the fluid.

`getSlopeDistance(level, p, dist, from, state, context)` (a recursive search that never doubles back through `from`):

1. `best` = 1000.
2. For each horizontal direction d other than `from` with neighbour np, state `S`, fluid `F` (block state through the context cache): if `canPassThrough(level, flowing fluid, p, state, d, np, S, F)` (= `canMaybePassThrough` and `canHoldSpecificFluid` for the flowing fluid): if `isHole(np)`, return `dist`; else if `dist < slopeFindDistance`, `d2` = `getSlopeDistance(level, np, dist + 1, opposite(d), S, context)`; `best = min(best, d2)`.
3. Return `best`.

The recursion explores at most `slopeFindDistance` cells in each branch (4 for water, 2 or 4 for lava, section 2.1). The first hole found along any branch returns immediately from that call with the current `dist` (shallowest first within the call; there is no global breadth-first order).

### 2.6 Passing rules

| Rule | Definition |
|---|---|
| `canPassThroughWall(d, level, from, fromState, to, toState)` | false when the debug flags `DEBUG_DISABLE_LIQUID_SPREADING` or (half-world debug and `to.z < 0`) are set (both false in a normal run). Let `Cto` = collision shape of `toState` at `to`, `Cfrom` = that of `fromState` at `from`. False if `Cto` is the full block shape; false if `Cfrom` is the full block shape; true if both are the empty shape. Otherwise true unless the two shapes occlude each other across the face `d`: `!Shapes.mergedFaceOccludes(Cfrom, Cto, d)`. The result is cached in a per-thread LRU keyed by the pair (fromState, toState) and `d` with 200 entries, unless either block has a dynamic shape (then it is recomputed). Collision shapes here are the block's own shapes with no entity context. |
| `canHoldAnyFluid(state)` | the block is a `LiquidBlockContainer`, or the state is in block tag `washed_away_by_fluids` (section 9) |
| `canHoldSpecificFluid(level, pos, state, fluid)` | for a `LiquidBlockContainer`, its `canPlaceLiquid(null, level, pos, state, fluid)`; otherwise true |
| `canHoldFluid(level, pos, state, fluid)` | `canHoldAnyFluid` and `canHoldSpecificFluid` |
| `canMaybePassThrough(level, pos, state, d, n, nState, nFluid)` | `nFluid` is **not** a source of this fluid, and `canHoldAnyFluid(nState)`, and `canPassThroughWall(d, level, pos, state, n, nState)` |
| `canPassThrough(level, fluid, pos, state, d, n, nState, nFluid)` | `canMaybePassThrough` and `canHoldSpecificFluid(level, n, nState, fluid)` |

`washed_away_by_fluids` includes `air`, the plants, torches, rails, carpets, buttons, snow layers, webs, `water` and `lava` themselves, and many more (full list in the jar tag; section 9 gives the family names): any block in it is destroyed (with drops for water, section 2.8) when fluid flows into it. Blocks not in the tag and not liquid containers (stone, doors, slabs that are not containers, fences) block flow. A full-block collision shape also blocks passage through walls, so a source next to a wall of full blocks never passes into the wall; slabs, stairs and fences may pass or block depending on mutual face occlusion.

### 2.7 `canBeReplacedWith(fluidState, level, pos, incomingFluid, direction)`

Asked of the fluid **already in** the target cell:

| Existing fluid | Replaced when |
|---|---|
| empty | always |
| water (either form) | `direction` is DOWN and the incoming fluid is **not** in fluid tag `water` (so only lava falling onto water replaces a water cell; water never replaces water) |
| lava (either form) | the existing lava state's height at the position is at least 0.44444445 and the incoming fluid is in fluid tag `water` (lava height at least 4/9, so amounts 4 and above; `LavaFluid.MIN_LEVEL_CUTOFF`) |

### 2.8 `spreadTo(level, pos, blockState, direction, newState)`

Default (`FlowingFluid.spreadTo`): if the block is a `LiquidBlockContainer`, call `placeLiquid(level, pos, blockState, newState)`; otherwise, if the block state is not air, call `beforeDestroyingBlock(level, pos, blockState)`; then `setBlockAndUpdate(pos, newState.createLegacyBlock())`.

- Water `beforeDestroyingBlock`: drops the block's resources as if broken with no tool (`Block.dropResources` with the block entity when the state has one).
- Lava `beforeDestroyingBlock`: level event 1501 (section 3.3) and **no drops**.
- Lava `spreadTo` override: when `direction` is DOWN and the existing fluid at `pos` is in tag `water` and `this` is lava: if the block at `pos` is a `LiquidBlock`, set `stone` (`setBlockAndUpdate`) and play event 1501 at `pos`, then return without the default. Otherwise default.

## 3. Water and lava interaction

### 3.1 `LiquidBlock.shouldSpreadLiquid(level, pos, state)` (called from `onPlace` and `neighborChanged`)

Water: always true. Lava (fluid in tag `lava`): let `soulSoilBelow` = the block below `pos` is `soul_soil`. For each of the directions DOWN, SOUTH, NORTH, EAST, WEST (the constant `POSSIBLE_FLOW_DIRECTIONS`, in this order), take the **opposite** neighbour `m = pos + opposite(direction)` (that is UP, NORTH, SOUTH, WEST, EAST: the cell **above** and the four horizontal neighbours; never the cell below):

1. If the fluid at `m` is in tag `water`: replace `pos` with `obsidian` when the lava at `pos` is a source (level 0), else `cobblestone`, using `setBlockAndUpdate`; play level event 1501 at `pos`; return **false** (no tick is scheduled).
2. Else if `soulSoilBelow` and the block at `m` is `blue_ice`: replace `pos` with `basalt`; play event 1501; return false.

If no neighbour reacts, return true and the caller schedules the normal fluid tick (and the bubble column check, section 6). The test runs on every `onPlace` and every neighbour update at a lava block, so water placed next to lava converts the lava cell at once, before any water tick; the converted lava never "flows".

### 3.2 Other results

| Situation | Result |
|---|---|
| lava flowing DOWN into a cell holding water (the `LiquidBlock`) | that cell becomes `stone`, event 1501 (2.8) |
| water entering a lava cell through `spread` | possible only when the lava's height is at least 4/9 (2.7); the cell is replaced with the water state with no special effect. Because 3.1 converts lava as soon as water is adjacent, this path is rarely reached (inferred) |
| `water_evaporates` dimension attribute true and a water bucket is emptied | no water is placed (7.2) |
| sponge | absorbs water (24 part 2 section 7.6) |

### 3.3 Level event 1501 (lava fizz)

Server: `levelEvent(1501, pos, 0)`. Client (`LevelEventHandler`): plays `lava.extinguish` at the block, category blocks, volume 0.5, pitch `2.6 + (r1 - r2) x 0.8` with two `nextFloat` draws, no distance delay flag; then 8 times spawns a `large_smoke` particle at `(x + nextDouble, y + 1.2, z + nextDouble)` with zero velocity (the x draw first, then the z draw, one pair per particle).

## 4. Lava specifics

### 4.1 Random tick (fire)

Lava is a random-ticking fluid (`isRandomlyTicking` true; the lava block carries the `randomTicks` flag, 24); water is not. `LiquidBlock.randomTick` calls the fluid's `randomTick` (33 §2.4, 29 §4.6 describe how often). `LavaFluid.randomTick(level, pos, fluidState, random)`:

1. If `level.canSpreadFireAround(pos)` is false, return. That is true when the game rule `fire_spread_radius_around_player` (default 128, minimum -1) is -1 or some player is within that distance of `pos` (`ChunkMap.anyPlayerCloseEnoughTo`).
2. `n` = `random.nextInt(3)`.
3. If `n` > 0: `p` = `pos`. Repeat `n` times: `p = p + (random.nextInt(3) - 1, 1, random.nextInt(3) - 1)` (the x draw first, then the z draw; the offset is cumulative, so each step rises one more block). If `p` is not loaded, return. Let `S` = the block state at `p`. If `S` is air: if any of the six neighbours of `p` is flammable-by-lava (`isFlammable`: the neighbour's builder flag `ignitedByLava`, and when its Y is inside the build height its chunk must be loaded), set fire at `p` with `BaseFireBlock.getState(level, p)` (soul fire when `SoulFireBlock.canSurviveOnBlock` holds for the block below, otherwise the fire block's placement state; 29b fire) and return; if not, continue. In this branch both the flammability test and the soul-fire test use the six-neighbour rule and `p` itself: `getState` receives `p` (the air cell where the fire is placed). Else if `S` is in block tag `blocks_lava_fire_spread` (= `blocks_motion`, so any block with collision), return.
4. If `n` = 0: three times: `p = pos + (random.nextInt(3) - 1, 0, random.nextInt(3) - 1)`; if `p` is not loaded, return; if the cell above `p` is an empty block and `p` is flammable-by-lava, the check order is: the cell `p.above()` is an empty block, then `p` itself is flammable-by-lava (`isFlammable`; this branch does **not** use the six-neighbour test `hasFlammableNeighbours`, only the n > 0 branch does). If both hold, the fire is placed (`setBlockAndUpdate`) at **`p.above()`**, but its state comes from `BaseFireBlock.getState(level, p)` with **`p`** (not the cell above), so the soul-fire test looks at the block below `p`, i.e. the flammable block itself, not at the block below the fire cell.

Block ticks happen through the level's random-tick loop; the level random draws are the ones of that loop (33 §2.4).

### 4.2 Entity effects

Fluid `entityInside` (called from the inside-block pass of 8.6):

- **Lava**: applies `CLEAR_FREEZE` and `LAVA_IGNITE` effects, and registers `lavaHurt` to run after `LAVA_IGNITE`.
- **Water**: applies `EXTINGUISH`.
- `lavaIgnite`: nothing for a fire-immune entity; otherwise `igniteForSeconds(15)`, which raises `remainingFireTicks` to at least 300 (`igniteForTicks(floor(15 x 20))`; 18 §4.4 describes fire ticks).
- `lavaHurt`: nothing for a fire-immune entity; on the server, `lava` damage of **4.0**, and when that damage was applied and the entity is not silent and `shouldPlayLavaHurtSound` (true by default), plays `generic.burn` (source: the entity's sound source, volume 0.4, pitch `2.0 + nextFloat x 0.4`) at the entity.
- `clearFire` (the `EXTINGUISH` effect) clears the entity's fire; `clearFreeze` is the `CLEAR_FREEZE` effect.

The collector (`InsideBlockEffectApplier.StepBasedCollector`) orders effects within one step by the enum order **FREEZE, CLEAR_FREEZE, FIRE_IGNITE, LAVA_IGNITE, EXTINGUISH**: for each type in that order, first its "before" actions, then the effect itself if it was requested, then its "after" actions. An entity standing in water and lava in the same step therefore ignites (LAVA_IGNITE, then `lavaHurt`) and then is extinguished. The pass stops applying effects once the entity is not alive.

Entity base tick effects of lava (`Entity.baseTick`, 18 §2.5): while `isInLava()` (section 8.5) the fall distance is multiplied by 0.5 each tick, and the periodic 1.0 `on_fire` damage of burning entities is skipped. Minecarts additionally call `lavaIgnite` and `lavaHurt` every tick while in lava.

### 4.3 Client ambience (`animateTick`)

- **Lava**, when the block above is air and not a solid render block: with probability 1/100 per tick a `lava` particle at `(x + nextDouble, y + 1, z + nextDouble)` (zero velocity) and a `lava.pop` sound there (category ambient, volume `0.2 + nextFloat x 0.2`, pitch `0.9 + nextFloat x 0.15`); independently with probability 1/200 a `lava.ambient` sound at the raw integer block coordinates `(x, y, z)` (no offset added, in contrast to the `lava.pop` sound, which is at `(x + nextDouble, y + 1, z + nextDouble)`, the same position as its particle), with the same volume and pitch formulas.
- **Water**: for a flowing, non-falling state: with probability 1/64 the sound `ambient.water` at `(x + 0.5, y + 0.5, z + 0.5)` (category ambient, volume `nextFloat x 0.25 + 0.75`, pitch `nextFloat + 0.5`); for a source or a falling state: with probability 1/10 an `underwater` particle at `(x + nextDouble, y + nextDouble, z + nextDouble)` with zero velocity.
- Drip particles: water uses `dripping_water`, lava `dripping_lava` (42 part 3 holds the emitter rules).
- Pickup sounds: `bucket.fill` (water), `bucket.fill_lava` (lava).

## 5. Liquid containers

### 5.1 The interfaces

`LiquidBlockContainer` has `canPlaceLiquid(entity, level, pos, state, fluid)` and `placeLiquid(level, pos, state, fluidState)`. `BucketPickup` has `pickupBlock(entity, level, pos, state)` returning a bucket stack (empty when nothing is picked up) and `getPickupSound`.

`SimpleWaterloggedBlock` (extends both; implemented by the `waterlogged` block families: slabs, stairs, walls, fences, trapdoors, chains, lanterns, ladders, signs, chests, candles, leaves, corals, conduits, scaffolding, sea pickles, dripleaf, lightning rods, amethyst clusters, rails, and others; the property is `waterlogged`, boolean, default false) has these default behaviours:

| Method | Behaviour |
|---|---|
| `canPlaceLiquid` | true exactly when the fluid is `Fluids.WATER` (the source fluid object; flowing water is not accepted) |
| `placeLiquid` | when `waterlogged` is false and the incoming state's fluid is `Fluids.WATER` (the source form): on the server set `waterlogged` true (`setBlockAndUpdate`) and schedule a fluid tick for water with water's tick delay (5); return true. Otherwise return false (the client side returns true without changing anything) |
| `pickupBlock` | when `waterlogged` is true: set it false (`setBlockAndUpdate`); if the state can no longer survive (`canSurvive`), destroy the block with drops (`destroyBlock(pos, true)`); return a water bucket. Otherwise the empty stack |
| `getPickupSound` | `bucket.fill` |

A waterlogged block reports the water **source** state from `getFluidState` (so waterlogged blocks hold a source, `falling` false) and its `updateShape` schedules a water fluid tick (delay 5) when `waterlogged` is true, then runs the block's own shape update. Per-block variations (read for slabs): `canPlaceLiquid` and `placeLiquid` return false for the `double` slab type; placement sets `waterlogged` to "the fluid at the clicked position is the water source" (`FluidState.is(Fluids.WATER)`: flowing water does not waterlog on placement, only a source); a placement that merges into a double slab sets `waterlogged` false. Leaves, mangrove roots and the mangrove propagule do the same (24 part 1 section 5.2).

### 5.2 Kelp, seagrass, tall seagrass

`KelpBlock` (head), `KelpPlantBlock`, `SeagrassBlock` and `TallSeagrassBlock` implement `LiquidBlockContainer` with both methods **always returning false**, and `getFluidState` always returns the water source. Consequences: fluid can never flow into them or replace them through `placeLiquid` (but they are in `washed_away_by_fluids`, so `canHoldAnyFluid` is true and `canHoldSpecificFluid` is **false** for them: flow stops at them); a bucket cannot place water into them; they cannot be picked up (they are not `BucketPickup`).

| Block | Fluid-related rule |
|---|---|
| kelp head | placement requires the fluid at the clicked position in tag `water` and `isFull`; may grow into `water` blocks only (`canGrowInto`: the block is `Blocks.WATER`); attaches unless the support is in `cannot_support_kelp`; grows with probability 0.14 per random tick (the growing-plant base, 29b) and by one block per bone meal |
| kelp plant | no placement rule of its own |
| seagrass | placement requires the clicked fluid in tag `water` and `isFull`; supports: top face sturdy and not in `cannot_support_seagrass`; `updateShape` schedules a water tick when the neighbour state is not air; valid bone meal target when the block above is `Blocks.WATER`; bone meal always succeeds and places a tall seagrass (lower at the position, upper above) |
| tall seagrass | placement additionally requires the cell above to be full water; `canSurvive`: the upper half needs the lower half below, the lower half needs the normal plant support and a full water fluid at its position |

### 5.3 Sponge

Covered in 24 part 2 section 7.6 (breadth first, 6 steps, 65 cells, `wet_sponge`, `sponge_absorb`); it uses `BucketPickup.pickupBlock` on every `BucketPickup` water cell it finds (source water blocks, waterlogged blocks, bubble columns), clears `LiquidBlock` cells to air (so flowing water is removed without a bucket) and drops and clears kelp and seagrass.

## 6. Bubble columns

The block, its states, scheduling and column propagation are in **24 part 7 section 5.2** and are not repeated. What this document adds:

1. **Creation.** A water `LiquidBlock` whose state is a full source (`shouldBubbleColumnOccupy`: fluid in fluid tag `bubble_column_can_occupy` (= `water`), source, amount 8) schedules a **block** tick on itself 20 ticks after `onPlace` or `neighborChanged` when the block below is in `enables_bubble_column_drag_down` (= `magma_block`) or `enables_bubble_column_push_up` (= `soul_sand`) (`tryScheduleBubbleBlockColumn`, constant `BUBBLE_COLUMN_CHECK_DELAY` 20), and when the cell's `updateShape` sees a change from DOWN with `shouldBubbleColumnOccupy` true. `LiquidBlock.tick` then calls `BubbleColumnBlock.updateColumn` with the block below.
2. **Column state.** Below `soul_sand`: `drag` = false (the column pushes up); below `magma_block`: `drag` = true; below another bubble column: copy of that column state. A bubble column over any other block reverts to plain water.
3. **Entity effect** (`BubbleColumnBlock.entityInside` with the "precise" flag true): if the cell above has an empty collision shape and no fluid (the entity is at the top of the column), `onAboveBubbleColumn(drag, pos)`; otherwise `onInsideBubbleColumn(drag)`. The velocity change of both acts only when `canSimulateMovement()` (the side that owns the entity's movement) is true; the **fall-distance reset** of the inside case (`Entity.handleOnInsideBubbleColumn`) is **not** gated: it runs after the gate on every side.

| Entity | Above the column (surface) | Inside the column |
|---|---|---|
| default (`Entity`, enderpearl) | drag: `vy = max(-0.9, vy - 0.03)`; push up: `vy = min(1.8, vy + 0.1)`; then (server) 2 rounds of particles at `(x + nextDouble, y + 1, z + nextDouble)` of the block: `splash` (count 1, speed 1) and `bubble` (count 1, delta (0, 0.01, 0), speed 0.2) | drag: `vy = max(-0.3, vy - 0.03)`; push up: `vy = min(0.7, vy + 0.06)`; then fall distance reset |
| player | as default, skipped entirely while the abilities `flying` flag is set | same skip |
| projectiles (not arrows in the ground) | `vy += -0.03` (drag) or `+0.1` (push up) with the same two-round particles | `vy += -0.03` or `+0.06`; no cap; the inside case also resets fall distance (`Projectile.onInsideBubbleColumn`; the above case has no cap and no reset; the thrown ender pearl's overrides only forward to the `Entity` helpers, so the default column applies to it) |
| boats | handled by the boat's own override (bubble time counter, passenger ejection): **not read** (Open question 7) | |

The numbers are applied to the entity's delta movement before the tick's physics step (8.6).

## 7. Buckets

### 7.1 Item classes and fluids

`BucketItem(content)`: `bucket` (content `empty`), `water_bucket`, `lava_bucket` (25 part 5 rows 848 to 850). `MobBucketItem` (7 items, content water): its `getFluidContext` is `NONE`; `emptyContents` first spawns the mob (below) and plays the mob's empty sound (category neutral, volume and pitch 1), then (when the content is not empty) the plain water placement. `SolidBucketItem`: `powder_snow_bucket`, a block item (`useOn` = block placement; the result becomes the empty bucket unless the player has infinite materials).

`BucketItem.getFluidContext`: `SOURCE_ONLY` when the bucket is empty (the ray hits only fluid **source** states), otherwise `NONE` (fluids are ignored by the ray). The target is chosen by `Item.getPlayerPOVHitResult(level, player, context)` (the ordinary block ray with the fluid mode; reach in 17).

### 7.2 `BucketItem.use(level, player, hand)`

1. Cast the ray with the fluid context. MISS: PASS. If the hit is not a block: PASS.
2. Let `pos` = the hit block, `face` = the hit face, `placePos` = `pos.relative(face)`. If `!level.mayInteract(player, pos)` or `!player.mayUseItemAt(placePos, face, stack)`: FAIL (29 §9 describes both).
3. Let `state` = the block at `pos`. The **target position** is `pos` when the block is a `LiquidBlockContainer` **and** the bucket content is water; otherwise `placePos`.
4. `emptyContents(player, level, target, hit)` (7.3). If it returns true: `checkExtraContent` (mob buckets spawn here, 7.4), for a server player and a non-empty content the `placed_block` advancement trigger at `target`, award `item_used` for this item, and the held item becomes the **empty success item** (an empty `bucket`; creative players, who have infinite materials, keep the stack), result SUCCESS.
5. Else, when the content is empty (an empty bucket): if the block at `pos` is a `BucketPickup`, call `pickupBlock`. When the returned stack is not empty: award `item_used`, play the block's pickup sound to the player (volume 1, pitch 1), game event `FLUID_PICKUP`, the held item becomes the filled stack (`ItemUtils.createFilledResult`), on a server the `filled_bucket` trigger fires; SUCCESS.
6. Otherwise FAIL.

`LiquidBlock.pickupBlock` works only on the source (level 0): the block becomes air with update flags 11 and the fluid's bucket is returned; a flowing block returns the empty stack. The bubble column's pickup sets air (flags 11) and returns a water bucket. Waterlogged blocks use 5.1. `PowderSnowBlock` and `SpongeBlock` also appear among the `BucketPickup` implementers (powder snow's pickup is not in this document).

### 7.3 `BucketItem.emptyContents(entity, level, pos, hit)`

Only for flowing fluids (water, lava): any other content returns false. Let `state` = the block at `pos`, `replaceable` = `state.canBeReplaced(content fluid)` (24 part 1 section 10.1), `shift` = the entity is not null and `isShiftKeyDown`.

1. `canContain` = `replaceable` or (the block is a `LiquidBlockContainer` and `canPlaceLiquid(entity, level, pos, state, content)`).
2. `canPlace` = `state` is air, or (`canContain` and (not `shift` or `hit` is null)).
3. If not `canPlace`: when `hit` is not null, retry once with the position `hit.pos.relative(hit.face)` and `hit` = null and return its result; else false.
4. **Evaporation.** If the environment attribute `gameplay/water_evaporates` is true at `pos` (positional, default false; the jar's `the_nether` dimension type sets it true) and the content is in tag `water`: play `fire.extinguish` at `pos` (category blocks, volume 0.5, pitch `2.6 + (r1 - r2) x 0.8`, two `nextFloat`), on a server spawn 8 `large_smoke` particles at the block corner `(x, y, z)` with deltas (1, 1, 1) and speed 0 in the "alternative" randomisation mode; return true (the bucket is spent, nothing placed).
5. Else if the block is a `LiquidBlockContainer` and the content is water: `placeLiquid(level, pos, state, water source)`, then `playEmptySound`, return true (the result of `placeLiquid` is not checked).
6. Else: on a server, when `replaceable` and the block is not a liquid (`state.liquid()` false), destroy it with drops (`destroyBlock(pos, true)`). Then `setBlock(pos, content.defaultFluidState().createLegacyBlock(), 11)` (the source block, flags 11). If that changed the block, or the state previously held a fluid **source**, play the empty sound and return true; else false.

`playEmptySound`: `bucket.empty_lava` when the content is in tag `lava`, otherwise `bucket.empty`, at the position, category blocks, volume 1, pitch 1, plus game event `FLUID_PLACE` (mob buckets use the mob's own sound, category neutral). The empty-bucket pickup sound, the empty success item, and the advancement triggers are server bookkeeping.

### 7.4 Mob buckets

`checkExtraContent` (server only): create the mob of the bucket's entity type at the target position (spawn reason `BUCKET`, with the bucket's item components applied through the standard post-spawn config), and when the mob is `Bucketable` load its `bucket_entity_data` custom data (`loadFromBucketTag`) and `setFromBucket(true)`; add it with its passengers and play its ambient sound; game event `ENTITY_PLACE`. The data tags are in 45; the mob rules in 44 part 7.

### 7.5 `SolidBucketItem.emptyContents`

True when the position is inside the world border bounds and holds an empty block (air): on a server place the item's block (`powder_snow`) with `setBlockAndUpdate`, game event `FLUID_PLACE`, play the placement sound of the item (category blocks, volume 1, pitch 1); false otherwise.

### 7.6 Dispenser

A dispenser holding a filled bucket (`DispensibleContainerItem`) calls `emptyContents(null, level, pos in front, null)` (no entity, no hit: `shift` is false and the retry of step 3 never happens). On success it runs `checkExtraContent` and replaces the stack with an empty `bucket` (`consumeWithRemainder`); on failure it dispenses the item as an ordinary item. 

A dispenser holding an **empty** `bucket` (`DispenseItemBehavior$4`) takes the block in front (the dispenser's `FACING`). If that block is a `BucketPickup`, it calls `pickupBlock(null, level, pos, state)`. If the block is not a `BucketPickup`, or the returned stack is empty, the item is dispensed by the default behaviour. Otherwise it fires game event `FLUID_PICKUP` at the position and the dispensed bucket is replaced by the returned filled item (a new stack of that item), through `consumeWithRemainder`, which leaves the filled bucket in the dispenser slot when it held one bucket and otherwise adds it elsewhere or ejects it. No pickup sound is played by this path. The filled-bucket behaviour above is `DispenseItemBehavior$3`.

## 8. Entity fluid interaction

### 8.1 State kept per entity

Every `Entity` owns an `EntityFluidInteraction` tracking the two fluid tags **water** and **lava** (`FLUIDS_WITH_CURRENT`). Per fluid **type** it keeps a `Tracker` (`height`, `eyesInside`); per **tag** it keeps a `CurrentAccumulator` (`height`, summed flow, count). Queries:

- `getFluidHeight(tag)` = the maximum `height` over the trackers whose fluid is in the tag (0 when none).
- `isInFluid(tag)` = `getFluidHeight(tag) > 0`; `isEyeInFluid(tag)` = some tracker in the tag with `eyesInside`.
- `isInWater()` is the stored flag `wasTouchingWater` (the water result of the previous update); `isInLava()` is `!firstTick` and `isInFluid(lava)`; `isInLiquid()` = in water or in lava; `isUnderWater()` = `wasEyeInWater` and `isInWater()` (`wasEyeInWater` is the eye-in-water result remembered at the start of this tick, before the update); `isInShallowWater()` = in water and not under water; `isInFloatableFluid()` = `isInFluid(entity_floatable)` (= tag `water`).

### 8.2 Per-tick update (`Entity.updateFluidInteraction`, called from `baseTick`)

Order inside `Entity.baseTick` (18 §2.5 lists the surrounding steps): speed bookkeeping, vehicle and portal handling, remember `isInPowderSnow`, **remember `wasEyeInWater` = `isEyeInFluid(water)`**, **`updateFluidInteraction`**, **`updateSwimming`**, fire handling (server), lava fall-distance halving, below-world check, `firstTick` = false.

`EntityFluidInteraction.update(entity, noCurrent)` with `noCurrent` = `!entity.isPushedByFluid()`:

1. Remove every tracker that was already idle (height 0 and not eyes-inside before this call: `Tracker.reset()` returns true exactly then); reset the others to height 0 and eyes-inside false. Reset every accumulator (height 0, flow zero, count 0).
2. `box` = `entity.getFluidInteractionBox()` = the bounding box deflated by 0.001 on every side, possibly adjusted by the vehicle (`modifyPassengerFluidInteractionBox`: the boat family returns nothing, i.e. no box, or restricts the passenger's box, when the boat is not under water: reading in Open question 7). When there is no box, return false.
3. Cell range: x from floor(`box.minX`) to ceil(`box.maxX`) - 1, y from floor(`box.minY`) to ceil(`box.maxY`) - 1, z likewise.
4. **Early out.** If no chunk section covering the block range (x0 - 1 to x1 + 1, y0 to y1, z0 - 1 to z1 + 1) has `hasFluid()` true, or any needed chunk is not loaded at status FULL, return false (all trackers stay reset).
5. Remember `entityMinY` = the entity's bounding box `minY` (not the deflated box), `eyeY`, and the entity's block X and Z.
6. For every cell (x outermost, then y, then z) in the range, with fluid state `F` (skip if empty): `top` = cell `y` + `F.getHeight(level, pos)`. If `top < box.minY` skip. Select the tracker of `F`'s fluid type (create on first use) and, unless `noCurrent`, the accumulator of the tag containing that type. Then:
   - if the cell's x and z equal the entity's block x and z, and `eyeY >= y`, and `eyeY <= y + F.getHeightForCamera(level, pos)`: `tracker.eyesInside = true`;
   - `tracker.height = max(tracker.height, top - entityMinY)`;
   - if an accumulator is in use: `flow` = `F.getFlow(level, pos)`; `acc.height = max(tracker.height, acc.height)`; if `acc.height < 0.4`, `flow` = `flow x acc.height`; add `flow` to the accumulated vector and increment the count.
7. Return true when at least one qualifying cell was found.

### 8.3 Flags and pushing (`Entity.updateFluidInteraction`)

After `update` (the result `touching` is also returned to the caller):

1. `inWater` = `isInFluid(water)`, `inLava` = `isInFluid(lava)`.
2. If `inWater`: `resetFallDistance()`; and when `wasTouchingWater` was false and this is not the first tick, `doWaterSplashEffect()` (8.7).
3. `wasTouchingWater` = `inWater`.
4. If the entity `isPushedByFluid()`:
   - in water: `applyCurrentTo(water, entity, 0.014)`;
   - in lava: `applyCurrentTo(lava, entity, s)` with `s` = 0.007 when the **dimension** value of `gameplay/fast_lava` is true, else 0.0023333333333333335 (0.007 / 3).

`applyCurrentTo(tag, entity, strength)`: nothing when the accumulator has count 0 or the squared length of the accumulated flow is below 9.999999747378752E-6. Otherwise: `current` = the accumulated flow **averaged** (`x (1 / count)`) when the entity is a `Player`, else the accumulated flow **normalised**; `current = current x strength`; if `|vx| < 0.003` and `|vz| < 0.003` (the entity's current delta movement) and `|current| < 0.0045000000000000005`, then `current` = normalise(current) x 0.0045000000000000005; add `current` to the entity's delta movement.

`isPushedByFluid()` is true by default and false for: the turtle, water animals (fish and the water-creature base classes, `AgeableWaterCreature`, `WaterAnimal`), the frog, the axolotl, the nautilus family, a **drowned while swimming**, an arrow that is stuck in the ground (true while in flight), and a **player whose abilities `flying` flag is set**. For these `noCurrent` is true, so no accumulation happens at all (heights and the eye flag are still tracked).

### 8.4 Swimming flag (`Entity.updateSwimming`)

If the entity `isSwimming()`: it stays swimming exactly while it is sprinting, in water (`isInWater()`) and not a passenger. Otherwise it becomes swimming exactly when it is sprinting, **under water** (`isUnderWater()`: eyes in water and in water), not a passenger, and the fluid at its block position is in tag `water`. The swimming **pose**, the sprint-swim input and `travelInWater` are in 13 §1.3 and 18 §3.2 (movement numbers); this document does not repeat them.

### 8.5 Fluid height queries used by other rules

| Consumer | Use |
|---|---|
| jump handling (13 §1.3 step 3, 18 §2.6 item 6) | `getFluidHeight(water or lava)` against `getFluidJumpThreshold()` = 0.0 when the eye height is below 0.4, else 0.4; the jump-in-fluid push (+0.04) |
| `FloatGoal`, `Swim` behaviour (18) | deeper than the jump threshold (or in lava) requests jumps |
| drowning | the eye in water (`isEyeInFluid(water)`) feeds the air supply (18 §2.5 item 4) |
| fishing hook | water fluid height at the hook (17, fishing hook physics) |
| `LivingEntity.shouldTravelInFluid` | `isInLiquid()` and `isAffectedByFluids()` and the entity cannot stand on that fluid; `isAffectedByFluids` is true except a flying player (13 §1.4) |
| sprint particles | not spawned while in water or lava |
| fog | camera in fluid: the lava and water fog environments (12 §3.3) |

`LivingEntity.canStandOnFluid(fluidState)` is false; the Strider returns true for fluids in the `lava` tag and, in its tick, when it is not above lava it sets on-ground and when it is above lava the velocity is scaled by 0.5 plus 0.05 upward (read, brief; the full Strider behaviour is 44 part 6).

### 8.6 Inside-block pass (where fluid `entityInside` runs)

`Entity.checkInsideBlocks` walks the blocks intersected by the entity's box (deflated by 0.001) along the movement from the previous to the current position. For each visited position that is not air (or whose fluid is non-empty), it tests two things independently: the block's `entityInsideCollisionShape` (the full block counts as always colliding) against the swept box, and the fluid state's world box (`FluidState.getAABB`, 1.1) against the swept box (`collidedWithFluid`). Each position is processed at most once per pass (a set of packed positions). When the block test passes, `BlockState.entityInside` runs (this is where bubble columns act, section 6); when the fluid test passes, `FluidState.entityInside` runs (4.2). Effects collected in the applier are applied at the end of the pass, in the order of 4.2.

### 8.7 Splash (`doWaterSplashEffect`)

On entering water (the transition in 8.3 step 2) the entity (or its controlling passenger, if any, which uses the factor 0.9 instead of 0.2) computes `v = min(1.0, sqrt(0.2 x vx^2 + vy^2 + 0.2 x vz^2) x k)`, where `k` = 0.2 when the entity is its own controller and 0.9 otherwise. If `v < 0.25` it plays the entity's swim-splash sound, else its high-speed splash sound, with volume `v` and pitch `1 + (r1 - r2) x 0.4`. Then it spawns `1 + width x 20` `bubble` particles and as many `splash` particles at `(x + (nextDouble x 2 - 1) x width, floor(y) + 1, z + (nextDouble x 2 - 1) x width)`; the bubbles have velocity `(vx, vy - nextDouble x 0.2, vz)`, the splashes `(vx, vy, vz)`; then game event `SPLASH`. `width` is the entity's hitbox width.

## 9. Tags, attributes and game rules the rules read

| Name | Kind | Members or value | Used by |
|---|---|---|---|
| `water` | fluid tag | `water`, `flowing_water` | evaporation, swimming, lava replacement, kelp, fish, sponge, tint |
| `lava` | fluid tag | `lava`, `flowing_lava` | pathfinding malus, lava effects, strider |
| `bubble_column_can_occupy` | fluid tag | `water` | bubble column (6) |
| `entity_floatable` | fluid tag | `#water` | `isInFloatableFluid`, float goals |
| `supports_lily_pad`, `supports_frogspawn` | fluid tag | `water` | placement rules (29b, 35) |
| `supports_sugar_cane_adjacently` | fluid tag | `#water` | sugar cane (29b) |
| `axolotl_tries_to_find`, `dolphin_tries_to_find`, `frog_tries_to_find_land_near` | fluid tag | `water` | mob goals (44) |
| `blocks_fluid_flow` | block tag | `#blocks_motion`, `#all_signs` | flow vector step 1.4.3 |
| `washed_away_by_fluids` | block tag | fire, saplings, corals and wall corals, air, flower pots, buttons, wool carpets, candles, rails, skulls, copper golem statues, `water`, `lava`, tall seagrass, wall torches, attached stems, kelp plant, the vines plants, big dripleaf stem, wall skulls and heads, bamboo sapling, cobweb, snow, end rod, chorus plant and flower, big dripleaf, scaffolding, powder snow, grass and ferns and dry grass, dead bush, bush, seagrass, all small flowers, mushrooms, torches, redstone wire, wheat, lever, redstone torch, stems, vine, glow lichen, resin clump, nether wart, tripwire and hook, carrots, potatoes, light, the tall flowers and grasses, torchflower and pitcher crops, beetroots, kelp, sweet berry bush, nether fungi and roots and vines, spore blossom, pink petals and wildflowers, leaf litter, small dripleaf, hanging roots, frogspawn, pale hanging moss, eyeblossoms, firefly bush, repeater, lily pad, cocoa, comparator, sea pickle, the moss carpets, heavy core, red shrub, shelf mushroom, straw bed (the jar's file lists each by key; the engine only tests membership) | `canHoldAnyFluid` (2.6) |
| `blocks_lava_fire_spread` | block tag | `#blocks_motion` | lava random tick (4.1) |
| `enables_bubble_column_drag_down` / `enables_bubble_column_push_up` | block tag | `magma_block` / `soul_sand` | bubble columns (6) |
| `cannot_support_kelp`, `cannot_support_seagrass` | block tags | (data) | 5.2 |
| `lava_pool_stone_cannot_replace` | block tag | `#features_cannot_replace`, `#leaves`, `#logs` | worldgen lava pools (35) |
| `gameplay/fast_lava` | environment attribute | boolean, default false, not positional, synced | lava delay, distance, drop-off, push strength |
| `gameplay/water_evaporates` | environment attribute | boolean, default false, positional, synced | bucket placement of water |
| `water_source_conversion` | game rule | boolean, default true | 2.3 |
| `lava_source_conversion` | game rule | boolean, default false | 2.3 |
| `fire_spread_radius_around_player` | game rule | integer, default 128, -1 means everywhere | 4.1 |

## 10. Client fluid mesh (`FluidRenderer.tesselate`)

The renderer meshes the fluid of every cell whose fluid state is non-empty. Inputs: the fluid model (`FluidStateModelSet`): water and flowing water use sprites `block/water_still` (still), `block/water_flow` (flowing) and `block/water_overlay` (overlay) and the water tint source (43 §2.1); lava and flowing lava use `block/lava_still` and `block/lava_flow`, no overlay and no tint (colour -1). The chunk layer of each model is chosen from the transparency of its sprites (`ChunkSectionLayer.byTransparency`; which layer water and lava end up in is not read: Open question 9).

### 10.1 Face selection

Let `U`, `D`, `N`, `S`, `W`, `E` be the neighbour fluid states.

- `sameFluid(a, b)` = the types are `isSame`.
- The **top face** is a candidate when the fluid above is not the same fluid.
- A **side or bottom** face for direction `d` is drawn when `shouldRenderFace`: the neighbour in `d` is not the same fluid **and** this cell's own block state does not occlude its face `d` with a full-height box (`isFaceOccludedBySelf`; matters for waterlogged blocks).
- Occlusion by a neighbour block (`isFaceOccludedByState(d, height, state)`): the neighbour's occlusion shape on its opposite face; empty means not occluded; a full block face occludes unless `d` is UP and `height` is not 1; any other shape occludes when `Shapes.blockOccludes(box (0,0,0)-(1,height,1), neighbour shape, d)`. Side faces test with the higher of the two corner heights, the bottom face with 0.8888889, the top face with the lowest corner height.
- If no face qualifies, nothing is drawn.

### 10.2 Corner heights

`h` (centre) = `getHeight(fluid, pos)` using the rendering rule: same fluid above gives 1.0, else own height. If `h >= 1`, all four corner heights are 1. Otherwise the four orthogonal neighbours `hN, hS, hE, hW` are read with the same rule but for another fluid: a neighbour with a non-solid, non-fluid block counts as 0.0 and a solid neighbour as -1.0 (ignored).

Corner heights (`NE`, `NW`, `SE`, `SW`; x grows eastward, z southward; `NE` is the corner at x = 1, z = 0):

| Corner | Computed from |
|---|---|
| NE | `average(h, hN, hE, diagonal NE)` |
| NW | `average(h, hN, hW, diagonal NW)` |
| SE | `average(h, hS, hE, diagonal SE)` |
| SW | `average(h, hS, hW, diagonal SW)` |

`average(center, a, b, diagonalPos)`: if `a >= 1` or `b >= 1` the result is 1. Otherwise accumulate (sum, weight) over this list of heights: the diagonal cell's height when `a > 0` or `b > 0` (if it is >= 1 return 1); then `center`, then `b`, then `a`. Each height `v` adds `(v x 10, 10)` when `v >= 0.8`, adds `(v, 1)` when `0 <= v < 0.8`, and nothing when `v < 0`. The result is sum / weight.

### 10.3 Geometry

All positions are relative to the block origin `(bx, by, bz)` (`pos & 15` per axis in the vertex coordinates). Let `e` = 0.001 (z-fight offset).

- **Top face** (when drawn): the four corner heights are each reduced by `e`; the vertices in order are `(0, hNW, 0)`, `(0, hSW, 1)`, `(1, hSE, 1)`, `(1, hNE, 0)`. When the flow vector (1.4) is zero the still sprite is used with the whole sprite (u0 v0, u0 v1, u1 v1, u1 v0). Otherwise the flowing sprite is used with `angle = atan2(flow.z, flow.x) - pi / 2`, `s = sin(angle) x 0.25`, `c = cos(angle) x 0.25` and the four (u, v) fractions of the sprite `(0.5 - c - s, 0.5 - c + s)`, `(0.5 - c + s, 0.5 + c + s)`, `(0.5 + c + s, 0.5 + c - s)`, `(0.5 + c - s, 0.5 - c - s)`. A second, reverse-winding copy is drawn when `shouldRenderBackwardUpFace` holds (any cell in the 3 x 3 horizontal neighbourhood of the **cell above**, at that height, is neither the same fluid nor a solid render block): that is how the surface is visible from below.
- **Bottom face** (when drawn): the unit square at height `e` (when the bottom face is drawn, else 0) using the still sprite; single-sided.
- **Side faces** (N, S, W, E, each when drawn and not occluded): a quad from the bottom (`e` when the bottom face is drawn, else 0) up to the two corner heights of that side (N: NW and NE; S: SE and SW; W: SW and NW; E: NE and SE), inset by `e` along its normal. The sprite is the flowing sprite with `u` from 0 to 0.5 and `v` from `(1 - cornerHeight) x 0.5` down to 0.5. When the model has an overlay sprite and the neighbouring block is a `HalfTransparentBlock` or a leaves block, the overlay sprite replaces the flowing sprite on that side face and the face is single sided; otherwise the face is drawn on both sides.

### 10.4 Colour and light

- Tint: the fluid model's tint source evaluated at the block (water: the biome water colour, 43 §2.1), or -1 (white) for lava; the same value for every face of the cell.
- Brightness scale applied to the tint: top face the `up` factor of the level's cardinal lighting (12 §4), bottom face the `down` factor; a side face the `north` factor when it lies on the Z axis (N and S faces) or the `west` factor when it lies on the X axis (W and E faces), **multiplied by the `up` factor** (the product `up x side`; the operand order is read, the factor values are in 12 §4).
- Light coordinates: the maximum, per channel, of the light at the cell and at the cell above (`LightCoordsUtil.max`); the same value for all faces of the cell (the top face does not use the neighbour's light).

## 11. Worked examples

**E1. Water spreading on a flat floor.** A water source `S` at (0, 64, 0) over solid stone, open air around. Its tick: `spread` step 3 fails (the stone cell below cannot hold a fluid), `S` is a source so `spreadToSides`. `amount` = 8 - 1 = 7 > 0. `getSpread`: each horizontal neighbour is air (`washed_away_by_fluids`, both collision shapes empty, passable); `getNewLiquid(neighbour)` sees the source at the centre: `maxAmount` 8, one source, no fluid above, so amount 8 - 1 = 7. The cell below each neighbour is stone, so no neighbour is a hole and `getSlopeDistance` finds no hole in 4 steps: all four distances are 1000, none is cleared, all four directions get the amount-7 state (legacy block level 1, water block state id 90). If the source was placed at game time `T`, ring 1 appears at `T + 5`, ring 2 at `T + 10` (each new `LiquidBlock.onPlace` schedules a tick 5 later), and so on until ring 7 with amount 1 (level 7, state id 96); the cell at amount 1 computes 1 - 1 = 0 and does not spread. The water reaches Manhattan distance 7 from the source.

**E2. Flowing toward a hole.** The same source at (0, 64, 0); the floor is solid except the cell below (3, 64, 0) is air. East neighbour (1, 64, 0): `isHole`? No (stone below). `getSlopeDistance((1,64,0), 1, from WEST)`: tries EAST np = (2, 64, 0): passable, not a hole, 1 < 4 so recurse with distance 2 from WEST: EAST np = (3, 64, 0) is a hole (the cell below can hold water): return 2. So east has distance 2. The other three directions have no hole within 4: 1000. `minDist` starts 1000: the first direction processed (the order is `HORIZONTAL`) sets entries; when east (2) arrives, 2 < `minDist` clears the map; later directions at 1000 > 2 are skipped; if a direction with 1000 was processed first it was cleared. Result: only east receives water. Directly adjacent hole (a hole at (1, 64, 0) itself) gives distance 0.

**E3. A waterfall.** Water at the lip, air below. `spread` step 3: below is air, `getNewLiquid(below)` finds the water above (same fluid, passable) and returns amount 8 with `falling`: `spreadTo(DOWN, ...)`, block level 8 (state id 97). The column continues one cell per 5 ticks. At the floor the bottom falling cell fails step 3, is not a source, and is not a hole (stone below), so `spreadToSides` runs with `amount` forced to 7: each neighbour's `getNewLiquid` takes the falling cell's amount 8 as `maxAmount`, giving 7 (level 1). The pool spreads like E1 as if from a source.

**E4. Source conversion.** A flowing water cell with solid floor and two horizontal source neighbours: `getNewLiquid` counts 2 sources, `water_source_conversion` is true (default), the block below is solid: result is the source state; the cell becomes block level 0 (state id 89). With the same layout in lava, `lava_source_conversion` is false (default) so the result falls through to the amount rule (8 - 2 = 6).

**E5. Lava distances.** Overworld lava source (amount 8, drop-off 2, delay 30): ring 1 amount 6 (level 2, state id 107), ring 2 amount 4 (level 4, id 109), ring 3 amount 2 (level 6, id 111), ring 4: 2 - 2 = 0, stop: three blocks. Each ring appears 30 ticks after the previous, and with probability 3/4 each newly higher state takes 120 ticks instead (`getSpreadDelay`). In the Nether (`fast_lava` true): delay 10, drop-off 1, slope distance 4: amounts 7 down to 1, seven blocks.

**E6. Obsidian and cobblestone.** A lava source at P; the player places water at P + UP. The water block's placement updates P: `neighborChanged` at P (lava) runs `shouldSpreadLiquid`: the direction DOWN's opposite is UP, water is there, the lava at P is a source, so P becomes obsidian, event 1501, no tick scheduled. If P were flowing lava (level 1 to 15) it becomes cobblestone. Water at P + DOWN does not convert P (the cell below is never checked). Lava flowing DOWN into a water source cell becomes stone at the target.

**E7. Basalt.** Lava (any level) at P with `soul_soil` at P below and a `blue_ice` block at P + EAST: when P is placed or any neighbour changes, step 2 of `shouldSpreadLiquid` turns P into `basalt` with event 1501.

**E8. Flow vector.** A flowing cell C of amount 7 at (1, 64, 0) with a source (amount 8) to the west and a flowing amount-6 cell to the east, N and S air over solid floor. Own height 7/9. West: `delta` = 7/9 - 8/9 = -1/9; contribution `x += (-1) x (-1/9)` = +1/9. East: `delta` = 7/9 - 6/9 = 1/9; `x += (+1) x (1/9)` = +1/9. N and S: neighbour height 0, the neighbour block (air) is not in `blocks_fluid_flow`, the fluid below the neighbour is empty (own height 0, not above 0): 0. `sum` = (2/9, 0, 0), not falling, normalise: (1, 0, 0): the current points east, away from the source.

**E9. Pushing a player.** A player at rest standing in that cell (box minY = 64.0, top of fluid 64 + 7/9 = 64.778): tracker height 0.778, accumulator height 0.778 (not below 0.4, so the flow is not scaled), count 1. Player: `current` = flow x 1/1 = (1, 0, 0); x 0.014 = (0.014, 0, 0). The velocity is below 0.003 in x and z but `|current|` = 0.014 is not below 0.0045, so no boost; delta movement becomes (0.014, 0, 0). A non-player gets the normalised sum (also (1, 0, 0)) and the same result. In non-fast lava: strength 0.00233..., `|current|` = 0.0023 < 0.0045 and the entity at rest: `current` = (0.0045, 0, 0) instead.

**E10. Rendering corner heights.** An isolated source (air on all sides, floor of stone): `h` = 0.8889 (8/9); `hN = hS = hE = hW` = 0 (air counts 0); each corner: `a` and `b` are 0, so no diagonal; `center` 0.8889 >= 0.8 adds (8.889, 10); `b` = 0 adds (0, 1); `a` = 0 adds (0, 1): 8.889 / 12 = 0.7407 for every corner (the vertices carry 0.7407 - 0.001). A source in the middle of a flat pool: all neighbours have 0.8889 each; the average is (4 x 8.889) / 40 = 0.8889.

**E11. Bucket on a slab.** A water bucket used on the top face of a bottom `oak_slab` that is not waterlogged: the clicked block is a `LiquidBlockContainer` and the content is water, so the target is the slab's own position. `emptyContents`: `canContain` true (`canPlaceLiquid` true for a non-double slab), `canPlace` true (the block is not air; `canContain` and not shifting), no evaporation in the overworld, step 5: `placeLiquid` sets `waterlogged` true, schedules a water tick (delay 5), `bucket.empty` plays; the stack becomes an empty bucket (unless the player has infinite materials). In the Nether the same click plays `fire.extinguish` and 8 `large_smoke` and the stack is still spent.

**E12. Bubble column over soul sand.** A water source with `soul_sand` below: after `onPlace` the water block schedules a block tick in 20 ticks; at that tick `updateColumn` sets the cell and every further cell upward that is a full water source to the bubble column with `drag` = false (state id 18652), flags 2, stopping at the first non-water cell. A player standing in the column (inside): `vy = min(0.7, vy + 0.06)` each tick; at the surface cell (the cell above has no collision and no fluid): `vy = min(1.8, vy + 0.1)`. Over `magma_block`: `drag` = true (id 18651), inside `vy = max(-0.3, vy - 0.03)`.

## 12. Validation

An implementation satisfies this document when the following hold (each is derived above):

| # | Check | Expected |
|---|---|---|
| V1 | Place a water source on flat stone, tick the world, record the ring radii and the game time of each ring | rings at +5 ticks each, final amount 1 at Manhattan distance 7; block state ids 90 to 96 for amounts 7 to 1 |
| V2 | Same with lava in the overworld and in the Nether | overworld: 3 rings (state ids 107, 109, 111) at 30 ticks (or 120 when the 3/4 branch fires); Nether: 7 rings at 10 |
| V3 | Remove the block below a source, observe the cell below | block level 8 (falling) at the cell below; falling column one cell per tick delay; at the floor the spread behaves as amount 7 |
| V4 | Two sources diagonal-adjacent (not orthogonal) around a flowing cell | no conversion: only orthogonal sources count |
| V5 | Flowing water between two sources with a solid floor | becomes source when `water_source_conversion` is true; stays flowing when false; the lava version never converts with default rules |
| V6 | A hole at distance 3 east of a source, 1 block deep, no hole elsewhere | only east spreads (E2); a hole at distance 5 is not seen: all directions spread |
| V7 | Place water above lava source, beside lava source, beneath lava source | above and beside: obsidian; beneath: no conversion of the lava |
| V8 | Flowing lava onto water | stone at the water cell, event 1501 (sound and 8 smoke particles) |
| V9 | Lava above `soul_soil` next to `blue_ice` | basalt |
| V10 | Water bucket on a non-waterlogged slab, on a waterlogged slab, on a double slab, in the Nether | waterlogged; no change (the second click targets the neighbour); not waterlogged, water placed beside; evaporation, bucket spent |
| V11 | Empty bucket on a flowing water cell, on a source, on a waterlogged block | nothing; bucket fills, cell becomes air with flags 11; `waterlogged` becomes false, bucket fills |
| V12 | Kelp and seagrass in a river that is flowing | water does not replace them and does not flow through them; a bucket cannot be emptied into them |
| V13 | Bubble column: soul sand then water above (source) | after 20 ticks the whole full-water column above is a bubble column with `drag` = false; replace the sand with air: it reverts to water |
| V14 | Player standing in the E8 cell | delta movement gains (0.014, 0, 0) per tick; a turtle and a fish gain nothing; a flying creative player gains nothing |
| V15 | Entity enters water from above at 1 block per tick | fall distance reset; one splash effect with `v = min(1, sqrt(0.2 x 0 + 1 + 0) x 0.2)` = 0.2 for a non-ridden entity (below 0.25: the normal splash sound) |
| V16 | Lava contact | a non-fire-immune entity gets `igniteForSeconds(15)` and 4.0 `lava` damage per applier pass; in water+lava the order is lava ignite, lava hurt, extinguish |
| V17 | Corner heights E10 | 0.7407 (isolated source) and 0.8889 (pool source) |

## 13. Open questions

1. The order of the 16 flowing states inside the fluid state registry (which of `falling` and `level` varies fastest) and hence the numeric fluid state ids were not read. They are internal (no packet carries them, 06 §4 carries a count only); a compatible server needs only the amount and falling flag.
2. `FlowingFluid.getShape` keys its cache by fluid state and captures the position that first built the box; the effect on bounding boxes of the same state at different heights (above-fluid case) was not analysed beyond the note in 1.3.
3. The kelp head and kelp plant `updateShape` (growing-plant base, `GrowingPlantHeadBlock` and `GrowingPlantBodyBlock`) and their scheduled water ticks were not read here; 29b (growth) owns them.
4. The `Shapes.mergedFaceOccludes` and `Shapes.blockOccludes` geometry (voxel-shape face comparison) is described by name only; the shape engine is the voxel-shape model of 24 part 1 section 12.
5. `FluidRenderer`: the chunk layer assigned to water and lava (the transparency rule of `ChunkSectionLayer.byTransparency` over the sprite set) was not read, and the cardinal-lighting factor values are those of 12 §4 (not repeated). The side-face brightness is `up x side` by the multiplication in the bytecode; the individual factor values were not re-read (12 §4).
6. The under-fluid fog and the in-fluid screen overlay were not re-read (12 §3.3, 14).
7. Boat and vehicle fluid handling (`modifyPassengerFluidInteractionBox`, boat `onAboveBubbleColumn` and `onInsideBubbleColumn` overrides with bubble time and ejection) was read only as signatures and the first lines; 44 part 8 owns them.
8. (Resolved in this revision: the empty-bucket dispenser behaviour is section 7.6. The exact slot placement of `consumeWithRemainder` was not re-read.)
9. The effect of `DEBUG_DISABLE_LIQUID_SPREADING` and the half-world debug flag was read as constants that are false in a release run (inferred from the flag names).
10. Powder snow bucket pickup (`PowderSnowBlock.pickupBlock`) and `WetSpongeBlock` drying are outside the fluid engine and not read here.
11. The 3 x 3 neighbourhood test of `shouldRenderBackwardUpFace` was read in outline (the offsets and the two predicates); the exact predicate order is not material to a faithful render and was not re-checked.
12. The `Strider` fluid rules were summarised from the signatures of `canStandOnFluid`, `getLiquidCollisionShape` and the lava-contact tick; 44 part 6 is the owner.
13. Not covered here, not read (out of scope of this document): (a) item-entity fluid handling (buoyancy, drag, burning in lava; `ItemEntity` overrides), (b) cauldron fluid interaction and pickup (`LayeredCauldronBlock`, `LavaCauldronBlock`, `CauldronInteraction`), (c) the `Fluid.getPickupSound` of the empty fluid and `FluidState.isSourceOfType`/`isFull` beyond the uses cited. They belong to the entity and block-entity documents (33, 34 series, 31) when those rounds cover them; this document only searched for them by class name. The `Fluid.isRandomlyTicking` dispatch is described for lava only (4.1), because water and the empty fluid were not found to override it (inferred).
14. Recalled, not verified: none. Every number of this document was read from the jar in this round; statements that were deduced are marked (inferred) in place.
