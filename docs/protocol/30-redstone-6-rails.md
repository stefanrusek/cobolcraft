# 30 Redstone, part 6: rails

| Item | Value |
|---|---|
| Covers | `BaseRailBlock`, `RailBlock`, `PoweredRailBlock` (powered rail and activator rail), `DetectorRailBlock`, `RailState`, `RailShape`; the redstone-facing hooks in the minecart classes (boost, brake, activator effects) |
| Round | RS12, part 6 (rails). Sibling parts: 30 §1 (shared signal model and wire), 30 §5 (plates and sensors), 30-redstone-2 §5.2 (container fullness, used by the detector rail comparator output). 30 §4 defers the hopper cart to 44 §4.6 and to this part |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution |
| Scope limits | Models and recipes are not tabulated (the `rails` tag and the loot tables are, in 2.1). General minecart movement (collision, passengers, slowdown) belongs to the entity documents; only the parts that depend on rail shape or rail power are here |
| Relation to 44 | 44-residual-mob-questions-8 (44 §4, minecart entities) is the owner of the minecart numbers: the old movement (44 §4.4, `moveAlongTrack`, `railPoint`, `comeOffTrack`, natural slowdown), the experimental movement (44 §4.5, `calculateTrackSpeed`) and the activator and hopper cart handling (44 §4.6). Section 8 here restates the rail-dependent parts so this document reads on its own. Where the two differ, 44 §4 wins and the difference is a defect to report. The constants compared when this part was revised agreed |

Class and method names in backticks say where a fact was read. They are not the design.

## 1. The ten rail shapes (`RailShape`)

`RailShape` is an enum with ten values, serialized by the lowercase names below. The numeric order is the declaration order, which matters for state-id assignment (see 04 §4 and 24 §3).

| Ordinal | Serialized name | Class | Connections (see 1.2) |
|---|---|---|---|
| 0 | `north_south` | flat straight | north, south |
| 1 | `east_west` | flat straight | west, east |
| 2 | `ascending_east` | slope, high end east | west, east (one up) |
| 3 | `ascending_west` | slope, high end west | west (one up), east |
| 4 | `ascending_north` | slope, high end north | north (one up), south |
| 5 | `ascending_south` | slope, high end south | north, south (one up) |
| 6 | `south_east` | flat curve | south, east |
| 7 | `south_west` | flat curve | south, west |
| 8 | `north_west` | flat curve | north, west |
| 9 | `north_east` | flat curve | north, east |

`isSlope()` is true exactly for ordinals 2 to 5.

Two block properties use this enum, both named `shape`:

| Property constant | Allowed values | Used by |
|---|---|---|
| `RAIL_SHAPE` | all ten | plain rail |
| `RAIL_SHAPE_STRAIGHT` | all except the four curves (ordinals 0 to 5, a predicate excluding `north_east`, `north_west`, `south_east`, `south_west`) | powered, activator and detector rail |

### 1.1 Block states

| Block | Class | Properties (registration order) | Default state | `isStraight` |
|---|---|---|---|---|
| `rail` | `RailBlock` | `shape` (10), `waterlogged` | `north_south`, not waterlogged | false |
| `powered_rail` | `PoweredRailBlock` | `shape` (6), `powered`, `waterlogged` | `north_south`, unpowered, dry | true |
| `activator_rail` | `PoweredRailBlock` (same class and constructor as the powered rail) | `shape` (6), `powered`, `waterlogged` | same | true |
| `detector_rail` | `DetectorRailBlock` | `shape` (6), `powered`, `waterlogged` | same | true |

State counts: rail 20, the other three 24 each. The four blocks are registered with the same settings: no collision, strength 0.7, sound type METAL; no push-reaction override (default applies). The activator rail has no behavioural difference at block level; what distinguishes it from the powered rail is in the minecart code (8.2).

### 1.2 Connection list of a shape (`RailState.updateConnections`)

A `RailState` keeps a list of exactly two connection positions derived from the shape (a slope's high end is one block up).

| Shape | Connection list (in order) |
|---|---|
| `north_south` | north, south |
| `east_west` | west, east |
| `ascending_east` | west, east+up |
| `ascending_west` | west+up, east |
| `ascending_north` | north+up, south |
| `ascending_south` | north, south+up |
| `south_east` | east, south |
| `south_west` | west, south |
| `north_west` | west, north |
| `north_east` | east, north |

### 1.3 Rotation and mirror (`BaseRailBlock.rotate`, `mirror`)

| Shape | CW 90 | CW 180 | CCW 90 | Mirror left-right | Mirror front-back |
|---|---|---|---|---|---|
| `north_south` | `east_west` | same | `east_west` | same | same |
| `east_west` | `north_south` | same | `north_south` | same | same |
| `ascending_east` | `ascending_south` | `ascending_west` | `ascending_north` | same | `ascending_west` |
| `ascending_west` | `ascending_north` | `ascending_east` | `ascending_south` | same | `ascending_east` |
| `ascending_north` | `ascending_east` | `ascending_south` | `ascending_west` | `ascending_south` | same |
| `ascending_south` | `ascending_west` | `ascending_north` | `ascending_east` | `ascending_north` | same |
| `south_east` | `south_west` | `north_west` | `north_east` | `north_east` | `south_west` |
| `south_west` | `north_west` | `north_east` | `south_east` | `north_west` | `south_east` |
| `north_west` | `north_east` | `south_east` | `south_west` | `south_west` | `north_east` |
| `north_east` | `south_east` | `south_west` | `north_west` | `south_east` | `north_west` |

Rotation `none` leaves every shape unchanged. Mirror left-right swaps north and south; mirror front-back swaps east and west. `powered` and `waterlogged` are untouched.

## 2. Shared behaviour of all rail blocks (`BaseRailBlock`)

### 2.1 What counts as a rail

`BaseRailBlock.isRail(state)` is true when the state is in the block tag `rails` AND the block is an instance of `BaseRailBlock`. The tag is data; the class test is code. Read from `data/minecraft/tags/block/rails.json`: the tag lists exactly four blocks, `rail`, `powered_rail`, `detector_rail`, `activator_rail`. Loot tables exist at `data/minecraft/loot_table/blocks/{rail,powered_rail,detector_rail,activator_rail}.json`; the two read (`rail`, `powered_rail`) hold one pool, one roll, condition `survives_explosion`, one entry that is the block's own item, and the other two are present with the same names (their contents were not opened).

### 2.2 Outline, support, water, placement

* Selection shape: full width in x and z; height 2/16 for non-slope shapes (ordinals 0, 1, 6 to 9) and 8/16 for slopes. No collision.
* `canSurvive`: `Block.canSupportRigidBlock(level, pos.below())`, that is the state below has a sturdy UP face of support type RIGID (the support types are defined in 24-block-registry-1 §6.6).
* Waterlogging: `getFluidState` is the water source when `waterlogged`; `updateShape` schedules a water tick when waterlogged, with the tick delay of water (5 ticks; the delay table and the waterlogging interfaces are in 29a §5.1), and otherwise falls through to the `Block.updateShape` default (rails never remove themselves in `updateShape`).
* `getStateForPlacement`: `waterlogged` = fluid at the clicked position is water; shape = `east_west` if the placer's horizontal facing is east or west, else `north_south`. `onPlace` then resolves the real shape.

### 2.3 Placement and neighbour-driven updates

1. `onPlace(state, level, pos, oldState, movedByPiston)`: if the old state is the same block (property change only) return. Else `updateState(state, level, pos, movedByPiston)` (four-argument form).
2. `updateState(state, level, pos, movedByPiston)`: `newState = updateDir(level, pos, state, forceUpdate = true)`. If the block `isStraight`, call `level.neighborChanged(newState, pos, thisBlock, no orientation, movedByPiston)`, which re-enters this block's own `neighborChanged` (step 3). Returns `newState`.
3. `neighborChanged(state, level, pos, sourceBlock, orientation, movedByPiston)`: server only, and only if the block at `pos` is still this block. If `shouldBeRemoved` (step 4): `dropResources` then `removeBlock(pos, movedByPiston)`. Otherwise call the per-class three-argument `updateState(state, level, pos, sourceBlock)`: plain rail 3.1, powered and activator rail 5.2, detector rail none (default does nothing).
4. `shouldBeRemoved(pos, level, shape)`: true if the block below has no rigid top face; for the four slopes also true if the neighbour on the high side (`ascending_east` east, `ascending_west` west, `ascending_north` north, `ascending_south` south, at the rail's own height) has no rigid top face (`canSupportRigidBlock(level, pos.relative(side))`). False otherwise.
5. `updateDir(level, pos, state, forceUpdate)`: client side returns the state unchanged. Server side: `RailState.place(powered = level.hasNeighborSignal(pos), forceUpdate, oldShape)` and returns its state (section 4).
6. `affectNeighborsAfterRemoval(state, level, pos, movedByPiston)`: nothing if `movedByPiston`. Else: if the shape is a slope, `updateNeighborsAt(pos.above(), thisBlock)`; if `isStraight`, `updateNeighborsAt(pos, thisBlock)` and `updateNeighborsAt(pos.below(), thisBlock)`. The two tests are independent.

`Level.hasNeighborSignal(pos)` (read in `SignalGetter`) is true when, for any of the six directions `d` in the order down, up, north, south, west, east, `getSignal(pos.relative(d), d) > 0`. `getSignal(p, d)` is the neighbour's own `getSignal` (for most blocks its `ownSignal`), raised to the strong signal reaching `p` when that block is a redstone conductor.

### 2.4 Redstone relevance

Only the detector rail is a signal source (6.1). Verified: `DetectorRailBlock`, `PoweredRailBlock`, `RailBlock` and `BaseRailBlock` declare no `shouldRedstoneWireConnectTo` override, so the `BlockBehaviour` default applies to all four. That default returns true exactly when the state is a signal source and the direction argument is non-null. Of the rails, redstone wire therefore connects to the detector rail only (wire side: 30 §1).

## 3. Plain rail (`RailBlock`)

State: `shape` (10 values) and `waterlogged`. Shape is resolved only by `RailState.place` (section 4).

**Reaction to a signal-source neighbour (3.1).** `RailBlock.updateState(state, level, pos, sourceBlock)` runs on every neighbour change. It acts only when BOTH: the default state of `sourceBlock` has `isSignalSource` true, AND `new RailState(level, pos, state).countPotentialConnections() == 3`. Then it calls `updateDir(level, pos, state, forceUpdate = false)`, re-resolving the shape with the current `hasNeighborSignal(pos)`. This is the "T-junction curve flips when powered" behaviour (4.5).

`countPotentialConnections()` counts the four horizontal directions `d` for which `hasRail(pos.relative(d))` is true. `hasRail(p)` is true when a rail (2.1) is at `p`, `p.above()` or `p.below()`.

## 4. Shape resolution (`RailState`)

`RailState` is built from (level, position, state); it holds the block's `isStraight` flag and the connection list of the current shape (1.2). Whether two rails are connected is tested on x and z only.

### 4.1 Helpers

| Helper | Definition |
|---|---|
| `getRail(p)` | Rail at `p`; if none, at `p.above()`; if none, at `p.below()` (this order). Returns a `RailState` for it, or nothing. |
| `connectsTo(other)` | this list contains a position with the same x and z as `other`'s position |
| `canConnectTo(other)` | `connectsTo(other)` is false OR the list does not have exactly 2 entries, that is: already linked, or has a free slot |
| `removeSoftConnections()` | For each list entry in order: `r = getRail(entry)`. If none, or `r` does not `connectsTo(this)`, drop the entry. Otherwise replace the entry with `r`'s real position (this corrects the stored y). |
| `hasNeighborRail(p)` | `r = getRail(p)`; false if none; else `r.removeSoftConnections()` and return `r.canConnectTo(this)`. The side effect on `r`'s list matters. |
| `connectTo(other)` | Append `other`'s position to this list, recompute this rail's own shape by 4.3, write it with `setBlockAndUpdate`. |

### 4.2 `place(powered, forceUpdate, oldShape)`

Let `n`, `s`, `w`, `e` be `hasNeighborRail` of the north, south, west, east positions, evaluated in that order. `NSaxis = n or s`, `EWaxis = w or e`. Curve flags: `SE = s and e`, `SW = s and w`, `NE = n and e`, `NW = n and w`.

1. `shape` starts undefined.
2. `NSaxis` and not `EWaxis`: `north_south`. `EWaxis` and not `NSaxis`: `east_west`.
3. Exclusive curves, only for a non-straight rail (plain rail), applied when no curve flag has an opposing neighbour:

| Curve | Condition | Excluded neighbours (must be absent) |
|---|---|---|
| `south_east` | `SE` | `n`, `w` |
| `south_west` | `SW` | `n`, `e` |
| `north_west` | `NW` | `s`, `e` |
| `north_east` | `NE` | `s`, `w` |

   At most one row can hold at once.
4. If `shape` is still undefined, the base is `oldShape` when both axes are set, `north_south` when only `NSaxis`, `east_west` when only `EWaxis`. For a non-straight rail a curve then overrides the base when its flag holds, resolved by this priority (first match wins):

| Rank | Powered | Unpowered |
|---|---|---|
| 1 | `north_west` (`NW`) | `south_east` (`SE`) |
| 2 | `north_east` (`NE`) | `south_west` (`SW`) |
| 3 | `south_west` (`SW`) | `north_east` (`NE`) |
| 4 | `south_east` (`SE`) | `north_west` (`NW`) |

5. Slopes: if `shape` is `north_south`: a rail (`BaseRailBlock.isRail` on that exact position) at `north.above()` gives `ascending_north`; then a rail at `south.above()` gives `ascending_south` (south wins if both). If `shape` is `east_west`: a rail at `east.above()` gives `ascending_east`; then `west.above()` gives `ascending_west` (west wins).
6. If `shape` is still undefined it becomes `oldShape`.
7. The connection list is rebuilt from the final shape and the state's `shape` property set. For the straight blocks the value is always one of ordinals 0 to 5, because steps 3 and the curve part of 4 are skipped (`oldShape` is a straight value for them).
8. If `forceUpdate` is true OR the level's current state at the position is not the identical new state: `setBlockAndUpdate(pos, newState)`, then for each position in the connection list: `r = getRail(position)`; skip if none; `r.removeSoftConnections()`; if `r.canConnectTo(this)` then `r.connectTo(this)`. This is how existing rails turn to join a new one.

`forceUpdate` is true on the `onPlace` path and false from 3.1.

### 4.3 The simple rule of `connectTo`

After appending the link, from the four neighbour columns (`hasConnection`, x and z test): `north_south` if north or south is linked; `east_west` if west or east is linked (the later assignment wins). If not straight: `south_east` if (south and east) and not north and not west; `south_west` if (south and west) and not north and not east; `north_west` if (north and west) and not south and not east; `north_east` if (north and east) and not south and not west. Then the slope step of 4.2 step 5. If still undefined, `north_south`. No second propagation pass happens, so neighbours of neighbours are not re-resolved.

### 4.4 Worked examples

1. Plain rail with free rails at east and south only (n and w false): step 3 gives `south_east`.
2. T-junction, neighbours at north, south and east, all with free slots, unpowered: both axes, no exclusive curve (each curve flag has an excluded neighbour present). Step 4: `shape = oldShape`, then not powered, order NW (no), NE (set), SW (no), SE (set): `south_east`. Powered: order SE (set), SW, NE (set), NW: `north_east`.
3. Free rails at west and east and a rail at `east.above()`: step 2 gives `east_west`, step 5 gives `ascending_east`.
4. Powered rail with neighbours at north and east only: curve rules are skipped; both axes, so `shape = oldShape` (for example `north_south`); it stays straight.
5. A neighbour rail that is already linked on both of its slots to other rails and does not link to the new one: `canConnectTo` is false, so `hasNeighborRail` is false and the new rail ignores it.

### 4.5 Why a junction flips on power

A plain rail with exactly three horizontal potential neighbours is a junction whose curve priority depends on `powered` (4.2 step 4). When a block whose default state is a signal source (lever, redstone block, torch and so on) changes next to it, 3.1 re-runs the resolution. The test uses the default state of the changed block, not whether it currently emits.

## 5. Powered rail and activator rail (`PoweredRailBlock`)

Same class; direction rules, propagation and the `powered` property are identical. Only the minecart reaction differs (section 8).

### 5.1 Signal status

Not signal sources (no override of `isSignalSource`, `ownSignal` or `getDirectSignal`). The `powered` property conducts only to rails of the same block through the search below.

### 5.2 Powering decision

On every neighbour change (2.3 step 3): `shouldBePowered = level.hasNeighborSignal(pos) OR findPoweredRailSignal(level, pos, state, forward = true, 0) OR findPoweredRailSignal(level, pos, state, forward = false, 0)`. If it differs from the current `powered`: `setBlockAndUpdate(pos, state with powered = shouldBePowered)`; `updateNeighborsAt(pos.below(), thisBlock)`; and if the shape is a slope, `updateNeighborsAt(pos.above(), thisBlock)`. If equal nothing happens. The `setBlockAndUpdate` already notifies the face neighbours, which is how the next rail in the line is updated.

### 5.3 The search

`findPoweredRailSignal(level, pos, state, forward, count)`:

1. `count >= 8`: return false. Chain distance `d` from the rail being decided is examined with `count = d - 1`, so rails up to 8 steps away can be reached.
2. Start from `(x, y, z)`, `checkBelow = true`. Move according to the state's shape:

| Shape | `forward = true` | `forward = false` | Axis shape passed on |
|---|---|---|---|
| `north_south` | z+1 | z-1 | `north_south` |
| `east_west` | x-1 | x+1 | `east_west` |
| `ascending_east` | x-1 | x+1, y+1, `checkBelow = false` | `east_west` |
| `ascending_west` | x-1, y+1, `checkBelow = false` | x+1 | `east_west` |
| `ascending_north` | z+1 | z-1, y+1, `checkBelow = false` | `north_south` |
| `ascending_south` | z+1, y+1, `checkBelow = false` | z-1 | `north_south` |

   (Forward is toward west on the east-west axis and toward south on the north-south axis; the caller tries both values.)
3. If `isSameRailWithPower(level, (x, y, z), forward, count, axis)`: true.
4. Else if `checkBelow` and `isSameRailWithPower(level, (x, y-1, z), forward, count, axis)`: true.
5. Else false.

`isSameRailWithPower(level, pos, forward, count, axis)`:

1. The block at `pos` must be the same block as the caller (powered rail links only to powered rail, activator only to activator). Else false.
2. With `axis = east_west`, a neighbour shape of `north_south`, `ascending_north` or `ascending_south` gives false. With `axis = north_south`, a neighbour shape of `east_west`, `ascending_east` or `ascending_west` gives false.
3. If the neighbour's `powered` is false: false.
4. If `level.hasNeighborSignal(pos)`: true.
5. Else `findPoweredRailSignal(level, pos, neighbourState, forward, count + 1)`.

Result: a rail that has a direct neighbour signal can power rails up to 8 steps away along a straight chain of rails that are already `powered = true`. A source at rail 0 powers rails 0 to 8 (nine rails). The spread takes one rail per neighbour-update step, and the same holds when the source disappears.

### 5.4 Worked examples

1. Five rails east-west at x = 0..4, a lever block touching rail 2. Rail 2 powers (direct). Rail 3: no direct signal; forward goes west to rail 2, same block, powered, direct signal: true. Rail 4 likewise through rail 3. Rail 1: forward looks at rail 0 (unpowered) then beyond: false; backward looks east at rail 2: true.
2. Lever removed: rail 2 finds no source in either direction (the chain ends in air or in powered rails without a direct signal), so it unpowers and notifies rails 1 and 3, which unpower in turn, then 4 and 0.
3. Sixteen rails x = 0..15, source touching rail 0. Rail 8 reaches rail 0 at count 7: powered. Rail 9 would need count 8: `findPoweredRailSignal` returns false first. Rails 0 to 8 are powered.
4. Uphill: rails `ascending_east` at x = 5 and at x = 6, y+1. Rail 5 backward moves to x+1, y+1 with axis `east_west`, finds rail 6 (shape `ascending_east` is not excluded by the axis test).
5. A powered line next to an activator line on the same axis never conducts between them (step 1).

## 6. Detector rail (`DetectorRailBlock`)

### 6.1 Signal output

Signal source in every state.

| Query | Result |
|---|---|
| `ownSignal` (so `getSignal` for every direction) | 15 when `powered`, else 0 |
| `getDirectSignal(…, direction)` | 0 when unpowered; when powered 15 if `direction` is UP, else 0 |

`getDirectSignalTo(p)` asks each neighbour `n` of `p` for `getDirectSignal(n, d)` with `d` pointing from `p` to `n`. UP therefore comes from the block directly below the rail: a powered detector rail strongly powers only the block it sits on, while every neighbour reading `getSignal` sees 15 (this is also how an adjacent powered rail is powered through `hasNeighborSignal`).

### 6.2 Detection box

`getSearchBB(pos)`: minimum corner `(x + 0.2, y, z + 0.2)`, maximum corner `(x + 1 - 0.2, y + 1 - 0.2, z + 1 - 0.2)` (0.6 by 0.8 by 0.6, from the block floor). Entities are collected with `level.getEntitiesOfClass(class, box, predicate)`.

| Use | Class | Predicate |
|---|---|---|
| Pressed check | `AbstractMinecart` | always true |
| Comparator, command block cart | `MinecartCommandBlock` | always true |
| Comparator, container cart | `AbstractMinecart` | `EntitySelector.CONTAINER_ENTITY_SELECTOR`: true when the entity implements `Container` and is alive (read, `lambda$static$2`, bootstrap entry 6) |

### 6.3 Press cycle (`checkPressed`) and the 20-tick refresh

Triggers: `entityInside` (server side, only when the rail is not powered yet); `tick` (only when powered); `onPlace` after the base logic (with the state returned by `updateState`).

`checkPressed(level, pos, state)`:

1. Return if the rail cannot survive (2.2) or the block at `pos` is not this block.
2. `wasPowered` = `powered`; `anyMinecart` = the `AbstractMinecart` list is non-empty.
3. `anyMinecart` and not `wasPowered`: `setBlockAndUpdate` with `powered = true`; `updatePowerToConnected`; `updateNeighborsAt(pos)`; `updateNeighborsAt(pos.below())`; `setBlocksDirty`.
4. Not `anyMinecart` and `wasPowered`: the same with `powered = false`.
5. If `anyMinecart`: `scheduleTick(pos, thisBlock, 20)` (`PRESSED_CHECK_PERIOD = 20`). A rail with a cart re-checks every 20 game ticks; unpowering happens at the first check that finds no cart. No tick is scheduled while empty.
6. Always: `level.updateNeighbourForOutputSignal(pos, thisBlock)`.

`updatePowerToConnected`: builds a `RailState` and for each position in its connection list calls `level.neighborChanged(thatState, thatPos, thatBlock, no orientation, false)`, so rails linked to the detector update even though no block changed there.

### 6.4 Comparator output

`hasAnalogOutputSignal` is true. `getAnalogOutputSignal`: 0 if unpowered. Else if a `MinecartCommandBlock` is in the box: the command block's `getSuccessCount()` of the first one in the result list. Else if a container cart matching the selector is in the box: `AbstractContainerMenu.getRedstoneSignalFromContainer` of the first one (defined in 30-redstone-2 §5.2, container fullness). Else 0.

### 6.5 Worked examples

1. A cart rolls onto an unpowered detector rail: `entityInside` runs `checkPressed`; the rail powers, notifies, schedules a tick 20 ticks ahead. Own signal 15 on all faces; the block below receives a direct 15.
2. The cart stands still: at +20 ticks `tick` finds the cart (powered, cart present): no state change, reschedules, refreshes comparators.
3. The cart leaves: the next scheduled check finds none, sets `powered = false`, notifies, schedules nothing.
4. Command block cart in the box with success count 3 and the rail powered: comparator reads 3; with an empty plain cart: 0.

## 7. Summary of reactions

| Event | Handler | Effect |
|---|---|---|
| Block placed | `onPlace`, `updateState` | `place` with `forceUpdate`; straight rails then run their own `neighborChanged` (powered rails compute `powered`; detector rail runs `checkPressed`) |
| Any neighbour update | `neighborChanged` | remove with drops if unsupported; else plain rail 3.1, powered and activator rail 5.2, detector rail nothing |
| Removed (not by piston) | `affectNeighborsAfterRemoval` | neighbour updates at above (slopes), at and below (straight) |
| Rotation, mirror | `rotate`, `mirror` | table 1.3 |

## 8. Minecart hooks that depend on rail shape and power

The minecart picks its movement implementation at construction: `AbstractMinecart.useExperimentalMovement(level)` is true when the level's enabled features contain `minecart_improvements`. That flag is NOT part of the `vanilla` flag: `FeatureFlags` registers `minecart_improvements` as its own flag, next to `trade_rebalance` and `redstone_experiments`, apart from `vanilla`, and `DEFAULT_FLAGS` is the `vanilla` set only. A default level therefore uses the old movement (`OldMinecartBehavior`). The flag is switched on only by the opt-in data pack `data/minecraft/datapacks/minecart_improvements/pack.mcmeta`, whose `features.enabled` is `[minecraft:minecart_improvements]` and whose `min_format` and `max_format` are both 121. The experimental movement is in 8.6. The pack file format is in 08 §2. Minecart numbers are owned by 44 §4 (see the header).

### 8.1 Which rail a cart is on (`getCurrentBlockPosOrRailBelow`)

Two variants, chosen by `useExperimentalMovement`. In both, the result is then tested with `isRail`: if it holds, the cart is on rails and runs the track step; else it runs `comeOffTrack` (8.3, step 7).

| Movement | Rail position |
|---|---|
| Old (default) | block `(floor x, floor y, floor z)` of the cart; if the block at `y - 1` is in the `rails` tag, use `y - 1` |
| Experimental (8.6) | probe height `py = y - 0.1 - 1e-5` (the float 1e-5, 9.999999747378752E-6) with the cart's floor x and floor z. If the block at `(floor x, py, floor z)` is in the `rails` tag, the rail y is `floor(py)`; otherwise the cart's own `floor y` is used, with no `y - 1` test. 44 §4.5 says the same |

### 8.2 Activator rail hook

Each tick in which the cart is on a rail, after the track step, if the state is exactly the `activator_rail` block, `cart.activateMinecart(level, x, y, z, poweredProperty)` is called with the rail's `powered` (true and false both, every tick). The experimental movement makes the same call before its track step. The default does nothing; overrides:

| Cart class | `powered` true | `powered` false |
|---|---|---|
| Rideable minecart (`Minecart`) | If it has passengers: `ejectPassengers`. Then if its hurt time is 0: hurt direction negated, hurt time 10, damage 50.0, `markHurt` (shaking, no destruction) | nothing |
| TNT minecart | If the fuse is below 0: `primeFuse(none)`. `primeFuse` returns at once when the game rule `tnt_explodes` is false; else sets fuse 80 | nothing |
| Hopper minecart | `enabled = not powered` (setter called only on change): powered disables | enables |
| Command block minecart | If `tickCount - lastActivated >= 4`: run the command block (`performCommand`) once and set `lastActivated = tickCount` | nothing |
| Chest, furnace, spawner carts | no override | nothing |

For the hopper cart's use of `enabled` see 44 §4.6 (44-residual-mob-questions-8); 30 §4 defers the hopper cart to that document and to this part.

**TNT minecart `primeFuse(source)`, in order** (read in `MinecartTNT.primeFuse`): (1) on a server level, return if the game rule `tnt_explodes` is false; (2) fuse becomes 80; (3) on the server only: if `source` is non-null and the cart has no ignition source yet, the ignition source becomes an explosion damage source built with this cart as the direct entity and `source`'s causing entity as the owner (argument order read, role names inferred); the activator rail passes no source, so none is recorded; (4) broadcast entity event 70 to tracking clients; (5) unless the cart is silent, play the `TNT_PRIMED` sound at the cart's position in the `BLOCKS` sound source, volume 1.0, pitch 1.0. The event 70 handling on the client belongs to the entity documents (44 §4.6 lists `primeFuse`).

### 8.3 Powered rail brake and boost (old movement, `moveAlongTrack`)

Only the `powered_rail` block has these (an activator rail neither boosts nor brakes). `poweredFlag` = block is `powered_rail` and `powered`; `brakeFlag` = block is `powered_rail` and not `powered`.

1. Slope pull: `d = 0.0078125`, times 0.2 in water. `ascending_east`: x velocity `-d`; `ascending_west`: x `+d`; `ascending_north`: z `+d`; `ascending_south`: z `-d` (added to the velocity). The base y is raised by 1 for slopes.
2. Alignment: horizontal velocity is projected on the exit pair (8.5), sign chosen to keep travel sense, magnitude `min(2.0, horizontal speed)`.
3. Player nudge: the intent is the first passenger's last client move intent when that passenger is a `ServerPlayer`, else zero. Conditions: the first passenger is a `Player`, the intent has non-zero length, and the cart's horizontal speed squared is below 0.01 (no lower bound is tested). Effect: add 0.001 times the RAW intent x and z (the intent is normalized only to test that its length is non-zero; the normalized vector is not the one scaled), and clear `brakeFlag`. The experimental path does normalize (8.6).
4. Brake: if `brakeFlag`: horizontal speed below 0.03 sets the velocity to zero; otherwise x and z are multiplied by 0.5.
5. Move: position set from the rail geometry, then `move` with x and z clamped to the max speed (`getMaxSpeed`; 0.4, or 0.2 in water, for the old movement as read in this part; the experimental movement uses the game rule, 8.6) after a factor of 0.75 with a passenger or 1.0 without; then natural slowdown (step 5a). The positional corrections that follow the move are in steps 5b to 5e, and the boost is step 6.
5a. **Natural slowdown (`applyNaturalSlowdown`, base class)**: with `f = getSlowdownFactor()`, the velocity is multiplied by `(f, 0, f)`, so the vertical velocity is zeroed; then, if the cart is in water, the whole vector is multiplied by the float 0.95 (0.949999988079071). `f` by movement: old 0.997 with a passenger, 0.96 without; experimental 0.997 with a passenger, 0.975 without (the old document value 0.96 is not the experimental one). Container carts override `applyNaturalSlowdown`; 44 §4.6 gives `f = 0.98` plus a signal-dependent term for them, and the other overrides, so this table is for the base case. Order inside a tick: move (5), exit-block drop (5b), slowdown (5a), height correction (5c), redirect (5d), boost (6).
5b. **Exit-block drop** (after the move, before the slowdown): for the first exit and then, only if that did not apply, the second exit (8.5): if the exit's y is non-zero and `floor x - railX` equals the exit's x and `floor z - railZ` equals the exit's z (the cart now stands in the block just beyond that end of the rail), the cart's y is increased by the exit's y (that is, lowered by one for the low end of a slope).
5c. **Height along the rail**: with `p0` the rail-surface point under the position before the move and `p1` the rail-surface point under the position after the move (`railPoint`, 44 §4.4.2; the step is skipped when either is absent), `dy = (p0.y - p1.y) * 0.05`. With `h` the horizontal speed after slowdown: when `h > 0`, x and z velocity are multiplied by `(h + dy) / h` (y unchanged). Then y is set to `p1.y` (x and z kept).
5d. **Redirect on block change**: if `floor x` or `floor z` of the cart differs from the rail block's, the velocity becomes `(h * (floor x - railX), vy, h * (floor z - railZ))` with `h` the horizontal speed (so travel continues along the axis of the step it just took).
5e. Projecting the position onto the rail line (step 5's "position set from the rail geometry"): the cart's x and z are replaced by the point of the line through the two half-exit end points (rail centre plus half of each exit, 8.5) that is nearest the cart, using the dot product along the line; y comes from the line's end points interpolated by the same fraction, plus the cart's base y (raised by 1 for slopes, 8.3 step 1). Read at instruction level (the long arithmetic around constants 0.5 and 2.0); the interpolation form is inferred (Open question 7).
6. Boost (after the move and the slope height correction), if `poweredFlag`: if horizontal speed `h > 0.01`, add `0.06 * (vx / h, 0, vz / h)`. Otherwise by shape: `east_west`: west neighbour of the rail position conducting (`isRedstoneConductor`) sets x to `+0.02`, else east neighbour conducting sets x to `-0.02`; `north_south`: north conducting sets z to `+0.02`, else south conducting sets z to `-0.02`; other shapes nothing. Only the named axis is set.
7. **Off the rails** (`comeOffTrack`, base class, both movements): `m = getMaxSpeed`; x and z velocity are each clamped to `[-m, +m]` (y unchanged); if on the ground, the whole velocity is multiplied by 0.5; `move` by the velocity (mover type SELF); if not on the ground afterwards, the velocity is multiplied by the air drag, the float 0.95 (`getAirDrag`). Subclasses may override the drag.

### 8.4 Other rails

Plain and detector rails apply only the slope pull (8.3 step 1). The activator rail only calls `activateMinecart`.

### 8.5 Exit vectors (`AbstractMinecart.exits`)

| Shape | First exit | Second exit |
|---|---|---|
| `north_south` | (0, 0, -1) | (0, 0, +1) |
| `east_west` | (-1, 0, 0) | (+1, 0, 0) |
| `ascending_east` | (-1, -1, 0) | (+1, 0, 0) |
| `ascending_west` | (-1, 0, 0) | (+1, -1, 0) |
| `ascending_north` | (0, 0, -1) | (0, -1, +1) |
| `ascending_south` | (0, -1, -1) | (0, 0, +1) |
| `south_east` | (0, 0, +1) | (+1, 0, 0) |
| `south_west` | (0, 0, +1) | (-1, 0, 0) |
| `north_west` | (0, 0, -1) | (-1, 0, 0) |
| `north_east` | (0, 0, -1) | (+1, 0, 0) |

Rule: for every slope shape the exit with `y = -1` is the low end, the horizontal neighbour direction opposite the high side, one block down; the other exit points toward the high side at `y = 0`. With the base raised by 1 for slopes this is consistent in all four rows (east: west exit down; west: east exit down; north: south exit down; south: north exit down). Which exit is listed first follows the flat pair order (north before south, west before east), not the slope.

### 8.6 Experimental movement (flag `minecart_improvements`)

Not default. Same activator call, made before the track step each iteration while the cart is on a rail.

**Per-step iteration (`moveAlongTrack`).** One cart tick runs a loop that continues while it is the first iteration or `movementLeft` exceeds 1e-5 (and the cart is alive). A `TrackIteration` object persists for the whole tick and holds `movementLeft`, `firstIteration` and three flags, `hasGainedSlopeSpeed`, `hasHalted`, `hasBoosted`, all initially false. Each iteration:

1. Read the current velocity and the rail position (8.1, experimental row). The on-rails flag is updated if it differs from the rail test, calling `adjustToRails` on a change.
2. On a rail: reset fall distance, record old position and rotation, activator call (8.2), read the shape, run `calculateTrackSpeed` on the horizontal part of the velocity (y zeroed), store the result.
3. `movementLeft` = horizontal length of the result on the first iteration; on later ones, `movementLeft` plus (new horizontal length minus old horizontal length).
4. `makeStepAlongTrack(rail, shape, movementLeft)` advances the cart along the rail and returns the remaining distance. Its geometry (below) is rail-shape dependent.
5. Off a rail: `comeOffTrack` and `movementLeft = 0`.
6. `firstIteration` becomes false.

**Transforms in `calculateTrackSpeed`**, each iteration, in this order:

| Order | Transform | Runs when | Flag |
|---|---|---|---|
| 1 | Slope pull | `hasGainedSlopeSpeed` is false | sets `hasGainedSlopeSpeed` when horizontal speed squared changed |
| 2 | Player nudge | first iteration only | sets `hasHalted` when horizontal speed squared changed |
| 3 | Halt | `hasHalted` is false | sets `hasHalted` when horizontal speed squared changed |
| 4 | Natural slowdown, then clamp | first iteration only; the clamp only if the slowed speed is above zero | none |
| 5 | Boost | `hasBoosted` is false | sets `hasBoosted` when horizontal speed squared changed |

Because the flags live in the persistent object, the slope pull stops after the first iteration in which it changed the speed, halt applies at most once per tick, and boost at most once per tick. The slope pull does not set `hasHalted`; only the nudge and halt itself do.

* Slope pull: `d = max(0.0078125, horizontal speed * 0.02)`, times 0.2 when the cart is in water. Direction as in 8.3 step 1 (`ascending_east` x `-d`, `ascending_west` x `+d`, `ascending_north` z `+d`, `ascending_south` z `-d`). Other shapes: unchanged. This replaces the old fixed constant 0.0078125.
* Player nudge: only when the first passenger is a `ServerPlayer`. With the last move intent normalized (length zero: no effect) and the cart's horizontal speed squared below 0.01, add 0.001 times the unit vector of the intent's x and z (y dropped, renormalized). The old path does not normalize (8.3 step 3).
* Halt (unpowered `powered_rail` only): speed below 0.03 gives zero velocity, else all components halved. No effect on any other block, or on a powered powered rail.
* Max speed (`getMaxSpeed`): the integer game rule `max_minecart_speed` (default 8, range 1 to 1000, gated by the `minecart_improvements` feature) times 0.5 in water or 1.0 otherwise, divided by 20. At the default of 8 this is 0.4 on land and 0.2 in water, the old fixed values. The same value caps the speed stored in each lerp step (minimum of the step's displacement and the max speed). Slowdown factor: 0.997 with a passenger, 0.975 without (8.3 step 5a).
* Boost (powered `powered_rail` only): if speed exceeds 0.01, new speed = old speed + 0.06 along the same direction. Otherwise `getRedstoneDirection(pos)`: for `east_west` west conducting gives (+1, 0, 0), else east conducting (-1, 0, 0); for `north_south` north conducting (0, 0, +1), else south conducting (0, 0, -1); anything else zero (no change). Non-zero: velocity = that unit vector scaled by (current speed + 0.2).

**Step along the track (`stepAlongTrack`, rail-shape dependent, summary only).** Inputs: rail position, shape, `movementLeft`. Returns 0 and zeroes the velocity when `movementLeft` is below 1e-5 or the horizontal velocity is below 1e-5. The two exit vectors of the shape (8.5) halved give two end points: the bottom centre of the rail block plus the half exit, plus `(0, 0.1, 0)`, plus the unit vector of the half exit times 1e-5 (the float 9.999999747378752E-6) as a nudge; the one whose half exit has the larger dot product with the horizontal velocity is the target. A rail whose exits differ in y (slope) gets the vertical correction: the target is raised 1 block unless the cart is descending, and the velocity is rescaled so its horizontal part is preserved (factor total length over horizontal length). Two candidate positions are compared by squared distance to the target and the nearer one is used for the move; a slope step scales the velocity direction by the square root of two. After the move, a cart that came to rest at the bottom of a V (squared speed below 0.005, a slope under it, descending into the next, not descending from it) is stopped. The exact arithmetic of the candidate positions was not transcribed to implementation precision (Open question 6); an implementer should treat experimental movement as out of scope for the first implementation and use the old movement of 8.3. The old movement is complete for the rail-dependent parts only together with steps 5a to 5e and 7 of 8.3; those were read at summary level (Open question 7), and 44 §4.4.1 is the fuller description.

## 9. Validation

1. Shape enum order, `isSlope` for 2 to 5, straight property values 0 to 5.
2. Rotation CW 90 four times is the identity; CW 180 is CW 90 twice; both mirrors are involutions (table 1.3).
3. A plain rail placed facing east with no neighbours is `east_west`; facing north, `north_south`.
4. Section 4.4 examples 1 to 3 as unit tests of `place`; powered versus unpowered junction priority.
5. Support: removing the block under a rail breaks it with drops on the next neighbour update; removing the high-side block of a slope breaks the slope.
6. Powered rail range: 16-rail line, source at rail 0: rails 0 to 8 powered, 9 to 15 not. A powered rail line and an activator line never conduct to each other.
7. Detector: powered at once on entry; unpowered at the first check after exit (at most 20 ticks); direct 15 only to the block below; comparator reads the command block success count.
8. Activator effects per 8.2, including the 4-tick command block limit and hopper enable inversion.
9. Brake and boost per 8.3 (old movement), tested as single steps, not as a speed sequence over several ticks (natural slowdown 5a runs between the move and the boost and changes the speed each tick): the brake step on an unpowered `powered_rail` halves the horizontal speed (0.2 gives 0.1) and zeroes it below 0.03; the boost step on a powered `powered_rail` adds 0.06 along the travel direction when the speed is above 0.01; stationary beside a wall end the boost sets 0.02 away from the wall. Natural slowdown: velocity times `(0.96, 0, 0.96)` for an empty old-movement cart, `(0.975, 0, 0.975)` experimental, 0.997 with a passenger, then 0.95 in water.

## Open questions

1. `getRedstoneSignalFromContainer` is not repeated here; it is owned by 30-redstone-2 §5.2.
2. Closed: the `rails` tag and the loot tables were read (2.1). The loot tables of `detector_rail` and `activator_rail` were listed but not opened (assumed to have the same shape as the two read).
3. Closed: `DEFAULT_FLAGS` is the `vanilla` set only and `minecart_improvements` is a separate flag enabled only by the opt-in pack (8 introduction). Whether a world-creation screen or server property can enable the pack by default was not searched.
4. Notification order and the orientation parameter of `neighborChanged` and `updateNeighborsAt` belong to 30 §1 and 29 §3; the rail logic here only needs all six face neighbours notified.
5. `MinecartHopper` item consumption was not read here (44 §4.6). The client handling of entity event 70 was not read here. The role names of the two arguments to the explosion damage source in `primeFuse` are inferred from argument order.
6. The arithmetic of the experimental `stepAlongTrack` (candidate positions, slope correction, V-shape rest) is summarised in 8.6 with the constants read (0.1, 1e-5, the square root of two, 0.005) but not transcribed to the precision needed to reproduce experimental movement.
7. The old-movement `moveAlongTrack` position projection (8.3 step 5e) and the details of `railPoint` and `adjustToRails` were summarised, not transcribed; see 44 §4.4.1 and 44 §4.4.2. The slowdown of container carts and other overrides is in 44 §4.6, not re-read here.
8. The magnitude range of the last client move intent used by the old-movement nudge (8.3 step 3, scaled raw) was not searched; it is produced by the player-input documents.
9. `isRedstoneConductor` (used by the wall push in 8.3 and 8.6) is a shared block-state property and is not repeated here.
10. The README Documents-table row and the RS12 scope sentence for the 30-redstone-* documents are missing (a search for "30-redstone" in `README.md` finds nothing). The reader may not edit `README.md`, so the orchestrator must add them when the round is merged.
