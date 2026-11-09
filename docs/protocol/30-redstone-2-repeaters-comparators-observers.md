# 30-2 Redstone: repeaters, comparators, observers and analog output

| Item | Value |
|---|---|
| Covers | The diode family (`DiodeBlock`, `RepeaterBlock`, `ComparatorBlock` with `ComparatorBlockEntity` and `ComparatorMode`), the analog-output rules of every block that has one (`hasAnalogOutputSignal` / `getAnalogOutputSignal`, the container fullness formula), the comparator input rules (container, analog block, item frame), and `ObserverBlock`. State properties, placement, survival, use, update and tick behaviour, the signal API these blocks call, scheduling priorities, worked examples with tick timelines |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited only to say where a fact was read |
| Siblings | Part 1 of this family (shared signal model, redstone wire, torches, power sources), part 3 (pistons), part 4 (dispensing), and parts 5 to 8 (switches, plates, sensors and notes; rails; doors, lamps, bulbs and TNT; tripwire, sculk, bells and vibration), which own the detector rail, sculk sensor and copper bulb rows summarised in 5.3. This part restates only the signal-API facts it needs (section 1) so it can be read alone; where part 1 owns a rule (wire connection, torch signals, `Orientation`) it is named |
| Data versus code | Block registry rows (ids, hardness, sounds, state-id layout) are in 24 and are not repeated; per-song `comparator_output` values and the sculk event frequencies are data or live in 31-4 and 31-8. This document specifies engines and code-defined constants |
| Cross references | 24-3 section 7.9 (repeater registry row, states), 24-5 section 7.5 (comparator row, shapes), 29 (setBlock pipeline, flags, update orders, tick queues, priorities), 31-1 section 9.5 and 31-2 sections 7 and 8 (container signal, crafter signal, comparator entity), 31-4 (jukebox, lectern, beehive), 31-6 (command block success count), 31-8 (sculk sensor), 44-5 (creaking heart), 45-9 (item frame NBT), 24-4 section 4 and 25-2 section 5.4 (`Direction.orderedByNearest`), 42 (particles) |

All times are game ticks (20 per second). "Redstone tick" in game text means 2 game ticks; this document uses game ticks only. Directions: `N`, `E`, `S`, `W` horizontal, `U`, `D` vertical; `opp(d)` is the opposite direction; `cw(d)` and `ccw(d)` are the clockwise and counter-clockwise horizontal neighbours of `d` seen from above (`cw(N) = E`).

## Contents

| Section | Topic |
|---|---|
| 1 | The signal API and update primitives these blocks use |
| 2 | Diode base logic (`DiodeBlock`) |
| 3 | Repeater |
| 4 | Comparator, its block entity and mode |
| 5 | Analog output signal of every block that has one |
| 6 | Observer |
| 7 | Worked examples |
| 8 | Validation |
| | Open questions |

## 1. The signal API and update primitives these blocks use

### 1.1 Reading signals (`SignalGetter`)

Direction convention: `getSignal(P, d)` asks "how strong a signal does the block at `P` emit towards the block that lies at `P - d`" (the asker stands behind `P` as seen along `d`). Loops over neighbours call it with `getSignal(asker + d, d)`.

| Function | Result |
|---|---|
| `getDirectSignal(P, d)` | the block state's own `getDirectSignal(level, P, d)` (default 0; "direct" is the strong form that can power a conductor block) |
| `getDirectSignalTo(P)` | the maximum of `getDirectSignal` over the six neighbours `Q` of `P`, asked as `getDirectSignal(Q, direction from P to Q)`, visited in the order D, U, N, S, W, E, returning early on 15 |
| `getSignal(P, d)` | `s = state(P).getSignal(level, P, d)` (default 0); if `state(P)` is a redstone conductor (`isRedstoneConductor`, 24-1: the collision shape is a full block, subject to the per-block predicate), the result is `max(s, getDirectSignalTo(P))`, else `s` |
| `hasNeighborSignal(P)` | true when `getSignal(P + d, d) > 0` for any of the six `d`, tested in the order D, U, N, S, W, E |
| `getBestNeighborSignal(P)` | the maximum of `getSignal(P + d, d)` over the six `d`, returning 15 as soon as a value reaches 15. The loop iterates the static `DIRECTIONS` array, which is filled from `Direction.values()` (read), so the order is D, U, N, S, W, E |
| `hasSignal(P, d)` | true when `getSignal(P, d) > 0` |
| `getBestOwnOrNeighbourSignal(P)` | the maximum of `getBestNeighborSignal(P)` and, when the state at `P` is a signal source (`isSignalSource`), that state's own signal (`getOwnSignal(level, P)`); otherwise just the neighbour value. Not called by the blocks of this part |
| `getControlInputSignal(P, d, diodesOnly)` | with `diodesOnly`: if the state at `P` is a diode (any `DiodeBlock`: repeater or comparator) then `getDirectSignal(P, d)` else 0. Without it: 15 for a redstone block; the wire's `power` for redstone wire (regardless of which side it is read from); `getDirectSignal(P, d)` for any other state with `isSignalSource` true; else 0 |

`getSignal(P, d)` of a diode and of an observer is the same function as its `getDirectSignal(P, d)` (both read the block's own output, section 2.5 and 6.4).

### 1.2 Update primitives

| Call | Meaning (29 section 3) |
|---|---|
| `neighborChanged(P, block, orientation)` on the level | runs the `neighborChanged` hook of the state at `P` with `block` as the source |
| `updateNeighborsAt(P, block)` | `neighborChanged` to the six neighbours of `P` in the order W, E, D, U, N, S (confirmed against `NeighborUpdater.UPDATE_ORDER`) |
| `updateNeighborsAtExceptFromFacing(P, block, d)` | the same, skipping the neighbour at `P + d` |
| `updateNeighbourForOutputSignal(P, block)` | section 5.1 |
| `scheduleTick(P, block, delay[, priority])` | queue a block tick at game time `now + delay`; default priority `NORMAL`; a tick that is already pending for the same block at the same position is ignored and the first schedule keeps its time (29 section 4.1) |
| `willTickThisTick(P, block)` | a tick of this block at `P` is in the batch of ticks due now that has not run yet |
| `hasScheduledTick(P, block)` | a tick of this block at `P` is pending in any form |

Tick priorities, lowest value runs first (29 section 4.1): `EXTREMELY_HIGH` -3, `VERY_HIGH` -2, `HIGH` -1, `NORMAL` 0.

The `orientation` argument that `neighborChanged` receives is produced by `ExperimentalRedstoneUtils.initialOrientation(level, frontDirection, up)`. None of the blocks of this document reads it (the diode and observer `neighborChanged` ignore the argument), so it can be passed as "none" unless part 1 or 29 Open question 2 decides that the experimental redstone behaviour is on.

### 1.3 `updateNeighborsInFront` (diodes and observers)

Both families notify only their output side. With `f` = the block's `facing` (for diodes `f` points to the input side; for observers `f` is the observed side):

1. `O = pos + opp(f)` is the output cell.
2. `neighborChanged(O, thisBlock, orientation)` on the level, so the output block itself is told.
3. `updateNeighborsAtExceptFromFacing(O, thisBlock, f, orientation)`: the six neighbours of `O` except the one at `O + f`, which is the diode or observer itself, are told.

Diodes build the orientation from `(opp(f), UP)`; the observer from `(opp(f), none)`.

## 2. Diode base logic (`DiodeBlock`, extends `HorizontalDirectionalBlock`)

### 2.1 Shared definitions

| Item | Value |
|---|---|
| Properties | `facing` (N, E, S, W) and `powered` (boolean); subclasses add more |
| Shape (collision and outline) | the box `(0,0,0)-(16,2,16)` in 1/16 units, the same for every state |
| `isSignalSource` | true |
| Survival (`canSurvive`) | the block below has its UP face sturdy with support type `RIGID` (24-1) |
| Placement (`getStateForPlacement`) | `facing = opp(player horizontal direction)`; `powered` stays at the default (false). The repeater adds `locked` (2.4 and 3.3) |
| `isDiode(state)` | true when the block is any `DiodeBlock` (repeater or comparator) |

The input side is `pos + facing`; the output side is `pos + opp(facing)`.

### 2.2 Input and side signals

1. `getInputSignal(level, pos, state)` (the "rear" input): `P = pos + facing`; `s = level.getSignal(P, facing)`. If `s >= 15` the result is `s`. Otherwise the result is `max(s, wirePower)` where `wirePower` is the `power` of the state at `P` when it is redstone wire and 0 otherwise. (The explicit wire read is needed because wire reports its signal only for the directions it points at; any wire next to the input side powers a diode.)
2. `getAlternateSignal(level, pos, state)` (the "side" input): `A = cw(facing)`, `B = ccw(facing)`; the result is `max( getControlInputSignal(pos + A, A, sideInputDiodesOnly), getControlInputSignal(pos + B, B, sideInputDiodesOnly) )`. `sideInputDiodesOnly` is true for the repeater and false for the comparator.
3. `shouldTurnOn(level, pos, state)` = `getInputSignal > 0`. The comparator overrides it (4.3).
4. `getOutputSignal(...)` = 15. The comparator overrides it (4.4).
5. `ownSignal(state, ...)` = `getOutputSignal` when `powered`, else 0. `getSignal(state, ..., d)` and `getDirectSignal(state, ..., d)` return `ownSignal` when `d == facing` and 0 otherwise (the block emits through its back, towards `opp(facing)`).
6. `shouldPrioritize(level, pos, state)`: let `n = opp(facing)` and `N` the state at `pos + n`. True exactly when `N` is a diode and `N.facing != n`. Written out: the output-side block is a diode that does not itself face away from this block, which covers a diode that this block feeds from behind (`N.facing == facing`) and a diode that takes it as a side input.
7. `isLocked(level, pos, state)` is false in the base class; the repeater overrides it (3.4).

### 2.3 Scheduling on a neighbour change

`neighborChanged(state, level, pos, sourceBlock, orientation, moved)`:

1. If the state now at `pos` is not this block, stop.
2. If `state.canSurvive(level, pos)`: run `checkTickOnNeighbor` (below) and stop.
3. Otherwise the block cannot stay: drop its item resources (with the block entity when it has one), `removeBlock(pos, false)`, then `updateNeighborsAt(pos + d, thisBlock)` for each of the six `d` in the order D, U, N, S, W, E.

`checkTickOnNeighbor(level, pos, state)` (repeater and the default; the comparator replaces it, 4.5):

1. If `isLocked(level, pos, state)`, stop.
2. `on = state.powered`; `want = shouldTurnOn`.
3. If `on == want`, stop. If `willTickThisTick(pos, thisBlock)`, stop.
4. Priority: `EXTREMELY_HIGH` when `shouldPrioritize`; otherwise `VERY_HIGH` when `on` is true; otherwise `HIGH`.
5. `scheduleTick(pos, thisBlock, getDelay(state), priority)`.

Placement hook `setPlacedBy`: if `shouldTurnOn` is true, `scheduleTick(pos, thisBlock, 1)` with the default priority (a delay of one tick whatever the repeater's `delay`).

### 2.4 The scheduled tick (`DiodeBlock.tick`)

1. If `isLocked`, stop.
2. `on = state.powered`, `want = shouldTurnOn`.
3. If `on` and not `want`: set `powered = false` with flags 2.
4. Else if not `on`: set `powered = true` with flags 2; and if `want` is false, also `scheduleTick(pos, thisBlock, getDelay(state), VERY_HIGH)` (the pulse then ends by itself after one more delay).
5. If `on` and `want` nothing happens.

Every state change goes through `setBlock`, which calls `onPlace` on the new state (29 section 2.1 step 11); the diode's `onPlace` is `updateNeighborsInFront` (1.3), so the output side is told on each change of `powered`, `locked` or `delay`.

### 2.5 Other hooks

| Hook | Behaviour |
|---|---|
| `onPlace(state, level, pos, old, moved)` | `updateNeighborsInFront` |
| `affectNeighborsAfterRemoval(state, level, pos, moved)` | `updateNeighborsInFront` unless `moved` (a piston move) |
| `getDirectSignal`, `getSignal` | 2.2 item 5 |
| `animateTick` | repeater only (3.6) |

The diode base class has no `updateShape` override. The DOWN support check lives only in the repeater (3.5) and the comparator (4.1), each of which implements it itself and then falls through to the inherited default, which returns the state unchanged.

## 3. Repeater (`RepeaterBlock`)

### 3.1 State

| Property | Values | Default |
|---|---|---|
| `facing` | N, E, S, W | N |
| `delay` | 1 to 4 (`IntegerProperty`) | 1 |
| `locked` | boolean | false |
| `powered` | boolean | false |

64 states; property order for the state definition is `facing`, `delay`, `locked`, `powered` (24-3 gives the state-id weights). The default state is `facing=N, delay=1, locked=false, powered=false`.

### 3.2 Timing

`getDelay(state) = delay * 2` game ticks, so 2, 4, 6 or 8. Output strength when powered is 15.

### 3.3 Placement

`facing = opp(horizontal direction of the player)`, so the input side faces the player and the output side faces away. `locked` is set to `isLocked(level, clickedPos, state)` at placement. Then `setPlacedBy` (2.3) and `onPlace` (2.4) run as for every diode.

### 3.4 Locking

`sideInputDiodesOnly = true`, so `getAlternateSignal` only counts repeaters and comparators standing on the two side cells (`cw(facing)` and `ccw(facing)`), through `getDirectSignal(sideCell, sideDirection)`. A side diode contributes exactly when its own `facing` equals the direction from this repeater to it (so its back, its output side, touches this repeater) and it is `powered`; the contributed value is its `getOutputSignal` (15 for a repeater, the stored output for a comparator). Wire, torches, levers and redstone blocks never lock a repeater.

`isLocked = getAlternateSignal > 0`.

A locked repeater ignores `neighborChanged` scheduling and scheduled ticks (2.3 step 1, 2.4 step 1): its `powered` value is frozen. When a lock ends nothing is scheduled by the lock itself; the next `neighborChanged` or the ordinary check in a later tick re-evaluates the input.

### 3.5 Shape update and the `locked` property

`updateShape(state, level, scheduledTicks, pos, direction, neighbourPos, neighbourState, random)`:

1. If `direction == D` and the block below can no longer support the repeater (`canSurviveOn` false, 2.1): the result is air (the repeater breaks and drops; the generic removal path of 29 section 3.2 applies).
2. Else, on a server level only, if the axis of `direction` differs from the axis of `facing` (a side neighbour changed): the result is the state with `locked = isLocked(level, pos, state)`.
3. Otherwise the state is returned unchanged.

Here `direction` is the direction from this repeater towards the neighbour that changed (29 section 3.2). The lock bit therefore follows the side diodes through shape updates, not through `neighborChanged`.

### 3.6 Use and client effect

`useWithoutItem`: if the player's abilities do not allow building (`mayBuild` false) the result is `PASS`. Otherwise the state is cycled to the next `delay` (1, 2, 3, 4, then 1) and written with `setBlockAndUpdate` (flags 3); the result is `SUCCESS`. No sound is played and nothing is scheduled directly (the state change runs `onPlace`, 2.4).

`shouldRedstoneWireConnectTo(state, level, pos, direction)`: true when `direction` is `facing` or `opp(facing)`; the call convention and the rest of the wire connection rules are part 1.

Client `animateTick` (only while `powered`; the random source is the client's, 42 has the particle): one dust particle `REDSTONE` per call at

- `x = pos.x + 0.5 + (r1 - 0.5) * 0.2`, `y = pos.y + 0.4 + (r2 - 0.5) * 0.2`, `z = pos.z + 0.5 + (r3 - 0.5) * 0.2`, with `r1`, `r2`, `r3` three successive `nextDouble()` calls in that order;
- then `offset = -5` pixels; a fourth call `nextBoolean()` that returns true replaces it with `delay * 2 - 1` pixels; the offset is divided by 16 and added to `x` and `z` along `facing` (`dx = offset * stepX(facing)`, `dz = offset * stepZ(facing)`); velocity (0, 0, 0).

So particles sit near the torch pair: a true boolean puts them toward the input side by `(2 * delay - 1)/16` of a block, otherwise 5/16 toward the output side.

## 4. Comparator (`ComparatorBlock`, `ComparatorBlockEntity`, `ComparatorMode`)

### 4.1 State and block entity

| Item | Value |
|---|---|
| Properties | `facing` (N, E, S, W), `mode` (`compare` or `subtract`, in that order; `ComparatorMode` serialized names `compare`, `subtract`), `powered` |
| Default state | `facing=N`, `powered=false`, `mode=compare` (16 states) |
| Delay (`getDelay`) | 2 game ticks for every state |
| Block entity | type `comparator`, created for every comparator (`EntityBlock.newBlockEntity`) |
| Entity data | one int `output`, default 0, saved as the int key `OutputSignal` (31-2 section 8) |
| Shape, survival, placement | as the diode base (2.1). `updateShape` returns air when `direction == D` and the block below can no longer support it (`canSurviveOn` false), otherwise the base result (state unchanged); unlike the repeater it has no `locked` property to maintain |

`getOutputSignal(...)` returns the entity's `output`, or 0 when the block entity is missing. The comparator therefore emits `powered ? output : 0` (2.2 item 5), with `output` possibly different from the strength that `input` and `side` would give right now: it is the value stored at the last refresh (4.5).

### 4.2 Input signal (`getInputSignal`)

1. `input = DiodeBlock.getInputSignal(...)` (2.2 item 1).
2. `P = pos + facing`, `S = state(P)`.
3. If `S` has an analog output (`hasAnalogOutputSignal`, section 5): `input = S.getAnalogOutputSignal(level, P, opp(facing))`. This replaces the value of step 1 even when it is lower. Stop.
4. Else, if `input < 15` and `S` is a redstone conductor: let `P2 = P + facing`, `S2 = state(P2)`.
   - `frame`: among all `ItemFrame` entities (this includes glow item frames, which extend it) whose bounding box overlaps the unit cube of cell `P2` and whose `getDirection()` equals `facing`; if exactly one such entity exists it is the frame, in every other case (none or several) there is no frame.
   - `a = frame ? frame.getAnalogOutput() : MIN`, where `MIN` is the minimum 32-bit integer used as "absent".
   - `b = S2.hasAnalogOutputSignal ? S2.getAnalogOutputSignal(level, P2, opp(facing)) : MIN`.
   - `m = max(a, b)`. If `m != MIN`, `input = m`; this too replaces the earlier value even when lower.
5. Result `input`.

The item frame's analog output (`ItemFrame.getAnalogOutput`): 0 when the frame is empty, otherwise `(rotation mod 8) + 1`, from 1 to 8 (the rotation is the stored `ItemRotation`, 45-9). A frame therefore reads through exactly one conductor block, and only a frame that faces the same way as the comparator (the frame hangs on the far side of the conductor).

### 4.3 Output and powered rules

Let `side = getAlternateSignal` (2.2 item 2, side inputs accept redstone blocks, wire, and any signal source; `sideInputDiodesOnly` false) and `input` as in 4.2.

| Quantity | Rule |
|---|---|
| `calculateOutputSignal` | if `input == 0` then 0; else if `side > input` then 0; else in `subtract` mode `input - side`, in `compare` mode `input` |
| `shouldTurnOn` | if `input == 0` then false; else if `input > side` then true; else (`input <= side`) true only when `input == side` and the mode is `compare` |

So `powered` in compare mode means `input >= side` and `input > 0`; in subtract mode it means `input > side`. The side value is never subtracted in compare mode.

### 4.4 Tick scheduling on a neighbour change (`checkTickOnNeighbor`)

This replaces the diode version (2.3):

1. If `willTickThisTick(pos, thisBlock)`, stop.
2. `new = calculateOutputSignal`; `old` = the entity's `output` (0 when the entity is missing).
3. Schedule a tick when `new != old` OR `powered != shouldTurnOn`. The delay is 2 and the priority is `HIGH` when `shouldPrioritize` (2.2 item 6), otherwise `NORMAL`. (There is no lock, and no `VERY_HIGH` case.) The usual identity rule applies: a tick already pending keeps its time.

Notifications to the comparator come from three places: its ordinary `neighborChanged` (2.3, which calls this method after the survival check), `updateNeighbourForOutputSignal` (5.1) when a container or analog block next to it changes, and `onPlace` through the setBlock pipeline.

### 4.5 The scheduled tick (`tick` = `refreshOutputState`)

The comparator does not use the base diode `tick`; its `tick` is `refreshOutputState`:

1. `new = calculateOutputSignal`.
2. `old` = the entity's `output` (0 when the entity is missing); when the entity exists, store `output = new`.
3. If `old == new` and the mode is `subtract`, stop here (no powered update, no notification).
4. `want = shouldTurnOn`; `on = state.powered`.
5. If `on` and not `want`: write `powered = false` with flags 2. Else if not `on` and `want`: write `powered = true` with flags 2.
6. `updateNeighborsInFront` (1.3).

Consequences: in compare mode the powered bit is re-evaluated and the front is notified at every scheduled tick even when the value did not change; in subtract mode a tick with an unchanged value does nothing. `setBlock` also runs `onPlace` (a second `updateNeighborsInFront`) when the state really changed.

`setPlacedBy`: if `shouldTurnOn` is true at placement, `scheduleTick(pos, thisBlock, 1)` (default priority), which runs `refreshOutputState` and so stores the first `output`.

### 4.6 Use

`useWithoutItem`: if `mayBuild` is false, `PASS`. Otherwise:

1. Cycle `mode` (compare to subtract to compare).
2. Play `COMPARATOR_CLICK` (sound source `BLOCKS`, no player excluded, position `pos`) at volume 0.3 and pitch 0.55 when the new mode is `subtract`, 0.5 when it is `compare`.
3. `setBlock(pos, newState, 2)`.
4. If the state at `pos` is still a comparator, run `refreshOutputState` (4.5) immediately (not scheduled). Result `SUCCESS`.

`triggerEvent` forwards to the base and then to the block entity's own `triggerEvent` (the entity defines none, so the result is false unless the base handles it).

### 4.7 Persistence

The entity's `output` is saved (`OutputSignal`), so a comparator emits its stored value after a restart even before its input chunk is loaded, until the next refresh.

## 5. Analog output signal of every block that has one

### 5.1 The mechanism

`BlockBehaviour.hasAnalogOutputSignal(state)` is false and `getAnalogOutputSignal(state, level, pos, direction)` is 0 by default. A block that overrides them is listed in 5.3. `direction` is the direction from the block towards the reader (a comparator passes `opp(facing)`); only the shelf (5.3) reads it.

`Level.updateNeighbourForOutputSignal(P, block)` is the call a block makes when its analog output may have changed (a container's `setChanged`, `Containers.updateNeighboursAfterDestroy`, a state change that alters the value, 31-1). It visits `d` in the order N, E, S, W (read from `Direction$Plane.HORIZONTAL`, which the jar fills as NORTH, EAST, SOUTH, WEST; the loop tests chunk loading first):

1. `Q = P + d`; skip it when the chunk is not loaded.
2. If the state at `Q` is a comparator: call its `neighborChanged(Q, block, none, false)`.
3. Else if the state at `Q` is a redstone conductor: let `R = Q + d`; if the state at `R` is a comparator, call its `neighborChanged(R, block, none, false)`.

Only horizontal neighbours are visited, and a comparator two blocks away is reached only through a conductor between. The notification is not guarded by the comparator's facing.

### 5.2 Container fullness (`AbstractContainerMenu.getRedstoneSignalFromContainer`)

Inputs: a `Container`. Output: 0 to 15.

1. If there is no container, the result is 0.
2. `sum` is a float, initially 0. For every slot `i` from 0 to `containerSize - 1`: if the stack is not empty, `sum = sum + count / max(i)` in float arithmetic, with `limit(i) = Container.getMaxStackSize(ItemStack)`, the stack-aware overload called with that slot's stack. Its default body is `min(container.getMaxStackSize(), stack.getMaxStackSize())`, where the zero-argument default is 99 (read in this round); a container that overrides either overload changes the result, and `limit(i)` is a per-slot limit, not a maximum over slots.
3. `f = sum / containerSize` (float).
4. Result `floor(f * 14) + (f > 0 ? 1 : 0)`, which is `Mth.lerpDiscrete(f, 0, 15)`: the float `f` is multiplied by `(15 - 0 - 1) = 14` in float, floored through a double (verified: `Mth.floor(float)` goes through `Math.floor` on a double), and 1 is added when `f` is strictly positive.

So the range is 0 (empty, `f = 0`) and 1 to 15 (`f` just above 0 gives 1; `f = 1` gives 15). `getRedstoneSignalFromBlockEntity(be)` is this value when the entity is a `Container` and 0 otherwise.

### 5.3 The catalog

Rows are read from the `getAnalogOutputSignal` / `hasAnalogOutputSignal` overrides in the jar. "Container signal" is 5.2. The reader (a comparator) gets the value on the server and on a client level alike unless the row says so.

| Block (class) | `hasAnalogOutputSignal` | Value |
|---|---|---|
| chest, trapped chest (`ChestBlock`) | true | container signal of the chest's container taken with blocking ignored off (`getContainer(..., false)`): a single chest reads its 27 slots, a double chest the merged 54 slots, and a chest that cannot be opened (a conductor above, a sitting cat) reads no container, giving 0 (31-1 section 9.5) |
| barrel (`BarrelBlock`) | true | container signal of its block entity (27 slots) |
| shulker boxes (`ShulkerBoxBlock`, all colours) | true | container signal of its block entity (27 slots) |
| furnace, smoker, blast furnace (`AbstractFurnaceBlock`) | true | container signal of its block entity (3 slots) |
| brewing stand (`BrewingStandBlock`) | true | container signal of its block entity (5 slots) |
| hopper (`HopperBlock`) | true | container signal of its block entity (5 slots) |
| dispenser and dropper (`DispenserBlock`, shared by `DropperBlock`) | true | container signal of its block entity (9 slots) |
| decorated pot (`DecoratedPotBlock`) | true | container signal of its block entity (a one-slot container, so `f = count / limit(i)`) |
| crafter (`CrafterBlock`) | true | the entity's `getRedstoneSignal`: the number of the 9 slots that are non-empty or disabled (0 to 9); 0 when the entity is missing (31-2 section 7.2) |
| chiseled bookshelf (`ChiseledBookShelfBlock`) | true | 0 on a client level; on a server level the entity's `lastInteractedSlot + 1` (0 when the entity is missing; an untouched shelf, whose last slot is -1, gives 0; slots 0 to 5 give 1 to 6) (31-2) |
| jukebox (`JukeboxBlock`) | true | the entity's `getComparatorOutput`: the `comparator_output` field of the song of the stored disc, 0 when the stored item has no song (31-4 section 2); it does not depend on whether the song is playing |
| lectern (`LecternBlock`) | true | when `has_book` is true and the entity is a lectern: `floor(t * 14) + (hasBook ? 1 : 0)`, computed in `LecternBlockEntity.getRedstoneSignal`, with `t = page / (pageCount - 1)` in float (`t = 1` when `pageCount <= 1`); otherwise 0. The block gates only on the `has_book` property and on the entity being a lectern; the `+1` comes from the entity's own `hasBook()`, not from the block state, so the two flags could differ (31-4 section 3.3) |
| command block, repeating and chain (`CommandBlock`) | true | the entity's `BaseCommandBlock.successCount`; 0 when the entity is missing or is not a command block entity (31-6) |
| composter (`ComposterBlock`) | true | the `level` property, 0 to 8 |
| layered cauldron, water and powder snow (`LayeredCauldronBlock`) | true (from `AbstractCauldronBlock`) | the `level` property, 1 to 3 |
| lava cauldron (`LavaCauldronBlock`) | true (from `AbstractCauldronBlock`) | 3 |
| empty cauldron (`CauldronBlock`) | true (from `AbstractCauldronBlock`) | 0 (no override: the base value) |
| cake (`CakeBlock`) | true | `(7 - bites) * 2` for `bites` 0 to 6: 14, 12, 10, 8, 6, 4, 2 |
| candle cakes (`CandleCakeBlock`) | true | the constant `FULL_CAKE_SIGNAL`, which is the cake value at 0 bites, 14 |
| beehive and bee nest (`BeehiveBlock`) | true | the `honey_level` property, 0 to 5 |
| end portal frame (`EndPortalFrameBlock`) | true | 15 when `has_eye` is true, else 0 |
| respawn anchor (`RespawnAnchorBlock`) | true | `floor( (charges - 0) / 4.0 * 15 )` with float arithmetic and `charges` 0 to 4: 0, 3, 7, 11, 15 |
| copper bulb (`CopperBulbBlock`, all oxidation and waxing variants) | true | 15 when `lit` is true, else 0 (the state is read again from the level at the position) |
| copper golem statue (`CopperGolemStatueBlock`) | true | `ordinal(pose) + 1` with the pose order `standing, sitting, running, star`: 1, 2, 3, 4 |
| detector rail (`DetectorRailBlock`) | true | when `powered` is true: the success count of the first command block minecart found (the first query is for `MinecartCommandBlock` with a predicate that accepts every entity; the container selector is tried second; both read in this round) in the rail's search box (in list order), else the container signal of the first container minecart found there (`EntitySelector.CONTAINER_ENTITY_SELECTOR`); 0 if neither exists or `powered` is false. The search box (read: the class's box builder uses the constant 0.2 six times and no 0.8) is the rail cell inset by 0.2 on x, z and the top: `(x + 0.2, y, z + 0.2)` to `(x + 1 - 0.2, y + 1 - 0.2, z + 1 - 0.2)`, i.e. upper corner 0.8 on each axis (0.8 is derived, inferred from the inset form). The rail's `PRESSED_CHECK_PERIOD` constant is 20 (read; its use belongs to 30-6) |
| sculk sensor and calibrated sculk sensor (`SculkSensorBlock`) | true | the entity's `lastVibrationFrequency` (0 to 15, 31-8) when the `sculk_sensor_phase` is `active`, else 0; 0 when the entity is missing |
| creaking heart (`CreakingHeartBlock`) | true | 0 when the `creaking_heart_state` is `uprooted`; otherwise the entity's cached `outputSignal` (0 when the entity is missing), which the entity recomputes in its server tick and announces with `updateNeighbourForOutputSignal` when it changes (44-5: 15 at distance 0, 0 at distance 32 or more) |
| shelf (`ShelfBlock`) | true | 0 on a client level; 0 unless the direction passed by the reader equals `opp(state.facing)`; otherwise, with the entity a shelf, a 3-bit value `b0 + 2 * b1 + 4 * b2` where `bi` is 1 when slot `i` of the shelf holds a non-empty stack (0 to 7); 0 when the entity is missing |

Blocks not in the table have no analog output. The comparator reading them sees only their direct or wire signal (4.2).

Notes:

- The `comparator_output` of a song, the sculk frequencies, the lectern page count, the creaking distance rule and the command block success count are values owned by the entities named; this document only gives how they map to the reading.
- A comparator reads the shelf from the side whose direction equals `opp(shelf.facing)`: with a comparator at `C` facing `F` (reading the cell `C + F`), the shelf must have `facing == F`. Whether this means "the comparator stands behind the shelf" depends on the facing convention of 31-3 (Open question 6).

## 6. Observer (`ObserverBlock`, extends `DirectionalBlock`)

### 6.1 State and placement

| Item | Value |
|---|---|
| Properties | `facing` (all six directions), `powered` (boolean); 12 states |
| Default state | `facing = S`, `powered = false` |
| Placement | `facing = opp(opp(nearestLookingDirection))`, which is `nearestLookingDirection` itself. The source is `BlockPlaceContext.getNearestLookingDirection()`, read as the first element of `Direction.orderedByNearest(player)` (24-4 section 4; at yaw 0, pitch 0 it is S). Both `getOpposite` calls are in the bytecode; the result is the look direction (see Open question 4 for the model orientation) |
| `rotate` / `mirror` | `facing` is rotated by the rotation; a mirror is applied as the rotation `Mirror.getRotation(facing)` |
| `isSignalSource` | true |
| Watched side | the cell `pos + facing` |
| Output side | the cell `pos + opp(facing)` |
| Survival | no `canSurvive` override: an observer needs no support |

### 6.2 Output

`ownSignal` = 15 when `powered`, else 0. `getSignal(state, ..., d)` returns `ownSignal` when `d == facing`, else 0; `getDirectSignal` is the same function. So the output is a strong signal of 15 towards the block at `pos + opp(facing)` (it can power a conductor block or a diode that stands there), and nothing to the other five sides. For the convention of 1.1: the block at the back, asking `getSignal(pos, facing)`, receives it.

`shouldRedstoneWireConnectTo(state, level, pos, direction)` is true exactly when `direction == facing` (wire call convention in part 1).

### 6.3 Detection (`updateShape`)

Only shape updates trigger an observer; its `neighborChanged` is not overridden. `updateShape(state, level, scheduledTicks, pos, direction, ...)` is called with `direction` = the direction from the observer to the neighbour that changed (29 section 3.2: the receiver sees the direction towards the changed block).

1. If `direction == facing` and `powered` is false: `startSignal`: when the level is not a client level and no tick of this block is pending at `pos` (`hasScheduledTick`), `scheduleTick(pos, thisBlock, 2)` (default priority).
2. The result is the base `updateShape` (the state unchanged).

A shape update is produced whenever the state at the neighbouring cell changes through `setBlock` without flag 16 (placing, breaking, state changes such as crop growth, a door opening, a piston moving a block), and by the neighbour's own `updateShape` result being written. A change of block entity data alone does not call it. A change while `powered` is true, or while a tick is already pending, schedules nothing.

### 6.4 The pulse (`tick`)

1. If `powered`: write `powered = false` with flags 2.
2. Else: write `powered = true` with flags 2, then `scheduleTick(pos, thisBlock, 2)`.
3. In both cases, `updateNeighborsInFront` (1.3).

Timeline from a detected change at game time `T`: tick at `T + 2` turns the observer on and notifies the back; tick at `T + 4` turns it off and notifies the back again. The output is on during game ticks `T + 2` and `T + 3` (a 2-tick pulse). A new detection is accepted again once `powered` is false and no tick is pending, so a change at `T + 4` (during the off tick, after it has run) starts a new cycle.

Writing `powered` also runs `onPlace` (section 6.5): the guard in that hook skips it for a state change of the same block, so the explicit `updateNeighborsInFront` in the tick is the only notification.

### 6.5 Other hooks

| Hook | Behaviour |
|---|---|
| `onPlace(state, level, pos, old, moved)` | if `old` is the same block, stop (state changes do nothing). On a server level, when `powered` is true and no tick of this block is pending: write `powered = false` with flags 18 (client update and skip shape updates), then `updateNeighborsInFront`. A powered observer that is placed fresh (moved by a piston, cloned, loaded from a structure) is thus reset |
| `affectNeighborsAfterRemoval(state, level, pos, moved)` | if `powered` and a tick is pending at `pos`: `updateNeighborsInFront` with the state as `powered = false`, so the back does not stay powered after removal. Unlike diodes this is not skipped for piston moves |

## 7. Worked examples

Times are game ticks; `T` is the time of the event.

**E1. Repeater, delay 2 (D = 4), input switches on and off.** Repeater `facing = N` at `(0, 64, 0)`, input at `(0, 64, -1)` (the N neighbour).
- At `T`, the input becomes 15 and the repeater gets `neighborChanged`. Unlocked, `powered = false`, `want = true`, no due tick: priority `HIGH` (the output cell `(0, 64, 1)` holds no diode and `powered` is false), tick at `T + 4`.
- At `T + 4` the tick sets `powered = true` (flags 2) and `onPlace` notifies `(0, 64, 1)` and its neighbours except the repeater. `want` is true, nothing else is scheduled.
- At `T2` the input drops to 0: `on = true`, `want = false`, priority `VERY_HIGH` (powered), tick at `T2 + 4`, which sets `powered = false`.

**E2. A 1-tick input pulse through a delay-1 repeater (D = 2).** Input rises at `T`, falls at `T + 1`.
- `T`: tick scheduled for `T + 2` (priority `HIGH`).
- `T + 1`: `want` is false and `powered` is false: equal, nothing.
- `T + 2`: tick: not powered, so `powered = true`; `want` is false, so a tick is scheduled at `T + 4` with `VERY_HIGH`.
- `T + 4`: `powered` and not `want`: `powered = false`.
The output pulse lasts 2 ticks regardless of how short the input was (a pulse shorter than the delay is stretched to the delay).

**E3. Prioritized scheduling.** A repeater feeds a second repeater that is placed on its output side with the same `facing`: `shouldPrioritize` is true (`N.facing = facing != opp(facing)`), so the first repeater's tick uses `EXTREMELY_HIGH` (-3) and runs before any other tick due in that game tick, for example before another chain with `HIGH`.

**E4. Locking.** Repeater `R` with `facing = N` at `P`. At `P + E` a repeater `X` with `facing = E` that is powered. `getDirectSignal(P + E, E)` is non-zero for `X` (its back, towards `W`, touches `R`), so `isLocked` is true. When `X` becomes powered, `X`'s `setBlock` runs a shape update on `R` with `direction = W` (axis X differs from `R`'s axis Z), the `locked` bit becomes true and `R` ignores every further tick: if `R` is on it stays on while the input falls, if it is off it stays off while the input rises. A repeater `Y` at `P + E` with `facing = W` does not lock `R` (its back is to the E).

**E5. Comparator modes with the same inputs.** Rear input 8, side 5: compare gives output 8, powered; subtract gives output 3, powered. Side 8: compare gives 8 and powered (`input == side` in compare mode); subtract gives 0 and `powered = false` (`input == side` but the mode is subtract). Side 9: both give 0, unpowered. Rear input 0: 0 whatever the side.

**E6. Comparator timeline.** A chest behind a comparator (compare mode, stored `output = 0`, `powered = false`) receives an item at `T`. The chest's `setChanged` calls `updateNeighbourForOutputSignal`; the comparator's `neighborChanged` runs `checkTickOnNeighbor`: `new = 1`, `old = 0`: schedule at `T + 2` with `NORMAL` (the output cell holds no diode). At `T + 2`: `output := 1`, `want` is true, `powered := true`, `updateNeighborsInFront`. Removing the item at `T3` repeats it with `new = 0`: `output := 0`, `want` false, `powered := false`.

**E7. Comparator in compare mode refreshes without a value change.** The stored output is 5 and the input stays 5 while the side input changes from 0 to 3. `new = 5 = old` and `powered = want = true` (5 >= 3), so no tick is scheduled in the neighbour check. But a tick that is already pending (for example from the earlier input change) runs `refreshOutputState`: in compare mode steps 4 to 6 run and the front is notified even though nothing changed; in subtract mode the same tick would stop at step 3.

**E8. Item frame reading and replacing.** A comparator facing `N` at `C`, a stone block at `C + N`, an item frame on the far face of the stone (cell `C + 2N`, `getDirection() = N`) holding a map rotated by 3: the reading is `3 mod 8 + 1 = 4`. If the stone is strongly powered to 10 (`input = 10` from step 1 of 4.2, below 15, and stone is a conductor) the frame's 4 replaces the 10, so `input = 4`. If the input were 15 (a powered repeater into the stone), the frame is ignored and `input = 15`. An empty frame gives `a = 0`, not "absent": it still replaces the redstone value with 0.

**E9. Observer pulse.** An observer with `facing = N` at `O`. At `T` a seed is planted at `O + N`: the shape update arrives with `direction = N`, `powered = false`, no tick pending: tick at `T + 2`. At `T + 2`: `powered = true`, tick scheduled for `T + 4`, back cell `O + S` notified. At `T + 3` the crop grows again: the shape update finds `powered = true`, nothing is scheduled. At `T + 4`: `powered = false`, back notified. Output 15 was present during `T + 2` and `T + 3`. A change at `O + E` never matters (`direction = E` is not `facing`).

**E10. Container fullness.** Hopper (5 slots) with one 64-stack item in each slot: `f = 5 * (64/64) / 5 = 1`, result `floor(14) + 1 = 15`. Five slots each holding one item that stacks to 64: `f = 5 * (1/64) / 5 = 0.015625`, `floor(0.21875) + 1 = 1`. Two of five slots hold a tool (stack size 1, one item): `f = 2 / 5 = 0.4`, `floor(5.6) + 1 = 6`. A single chest with 14 full stacks of 64: `f = 14 / 27 = 0.5185`, `floor(7.26) + 1 = 8` (31-1 example 3). An empty container: 0.

**E11. Fixed formulas.** Cake with 3 bites: `(7 - 3) * 2 = 8`; respawn anchor with 3 charges: `floor(0.75 * 15) = floor(11.25) = 11`; lectern with a 5-page book at page index 2 (pages 0 to 4): `t = 2 / 4 = 0.5`, `floor(7) + 1 = 8`; at page 4: `floor(14) + 1 = 15`; composter at level 5: 5; copper golem statue in the `star` pose: 4; detector rail, powered, with a container minecart holding one 64-stack in a 27-slot container: `f = 1/27`, `floor(0.5185) + 1 = 1`.

**E12. Placement orientation.** A player at yaw 0 looks towards S, so the horizontal direction is S. A repeater placed by that player gets `facing = N`: the input cell is `pos + N` (the near side, behind the player) and the output is `pos + S` (away from the player). An observer placed by the same player, looking level, gets `facing = S` (the look direction): the watched cell is `pos + S` and the output is at `pos + N`. A player looking straight down gets an observer with `facing = D`.

## 8. Validation

An implementation matches this document when all of the following hold.

1. State counts: repeater 64 (`facing`, `delay` 1 to 4, `locked`, `powered`), comparator 16 (`facing`, `mode`, `powered`), observer 12 (`facing` six-way, `powered`); defaults as in 3.1, 4.1 and 6.1.
2. Repeater delay is `2 * delay` ticks; `useWithoutItem` cycles 1, 2, 3, 4, 1 with flags 3 and no sound; with `mayBuild` false it passes.
3. Diode scheduling: priority is `EXTREMELY_HIGH` when `shouldPrioritize` holds, `VERY_HIGH` when powered, `HIGH` otherwise; a locked repeater schedules and runs nothing; a due tick for the same block suppresses the check; a turn-on with no input schedules the turn-off at `delay * 2` with `VERY_HIGH`.
4. `setPlacedBy` schedules one tick after 1 game tick (default priority) when the block would turn on, for repeaters and comparators.
5. `getInputSignal` returns the signal at the input cell with the direction `facing`, the wire `power` when it is below 15, and returns early at 15; `getAlternateSignal` uses `cw(facing)` and `ccw(facing)`, diodes only for repeaters; redstone block 15, wire power, signal sources by direct signal for comparators.
6. The comparator formulas of 4.3 give the table of E5; `calculateOutputSignal` never yields a negative value.
7. A comparator's `checkTickOnNeighbor` uses delay 2, `HIGH` or `NORMAL`, and only schedules when the stored output or the powered flag would change; its `tick` stores the output before comparing and notifies the front as in 4.5 (including the compare-mode rule of E7).
8. The comparator entity saves exactly the int `OutputSignal` and reloads it with default 0.
9. Comparator input: the analog output of the block behind replaces the redstone input; through a conductor, the item-frame and block values replace it only when the redstone input is below 15, even when lower; exactly one frame of matching direction counts.
10. Container fullness gives 0 for empty, 1 for any non-empty content, 15 for completely full, and the values of E10; cakes 14 to 2, respawn anchors 0, 3, 7, 11, 15; lectern as in E11; shelf 0 to 7 only from the matching direction on the server.
11. `updateNeighbourForOutputSignal` notifies a comparator at each horizontal neighbour and one behind each horizontal conductor, in the order N, E, S, W, only in loaded chunks.
12. Observer: pulse of 2 ticks starting 2 ticks after a detection on the watched side, no new detection while powered or while a tick is pending, output only to `pos + opp(facing)`, `onPlace` resets a fresh powered observer, removal while a tick is pending releases the back.
13. Output notifications go to `pos + opp(facing)` and its neighbours except the source, never to the other neighbours of the source (1.3).

## Open questions

1. `ItemFrame` selection overlap: the box of the cell is tested with `Level.getEntitiesOfClass`, so the exact overlap rule (strict or inclusive at the boundary) is that of the entity query (29 or the entity documents); it was not re-read here. A frame in the neighbouring cell never overlaps in practice because the item frame's bounding box is thin and inside its own cell (inferred).
2. The experimental redstone `Orientation` argument is built and passed on by the diodes and the observer, and the blocks of this document never read it. If a later round enables the experimental redstone behaviour (29 Open question 2), the observer, diode and comparator calls of 1.3 must pass real orientations and the consumers (wire, part 1) must be read again.
3. `ExperimentalRedstoneUtils.initialOrientation` was not read; only its arguments are recorded.
4. Observer placement is `opp(opp(look))` in the bytecode, that is the look direction. Which model face (the one with the "eye") is the watched side, and whether the shipped blockstate maps `facing` to the face the player sees, is data (asset) and was not read in this round. The behaviour rule (watched side = `facing`, output at the back) is read directly.
5. The wire connection predicate (`shouldRedstoneWireConnectTo`) is recorded for the repeater (axis match) and the observer (direction equals `facing`); the meaning of the `direction` argument and the comparator's connection (it has no override of its own) are in part 1.
6. Shelf analog output is read as "direction passed equals `opp(facing)`"; the geometric reading (a comparator behind or in front of the shelf) depends on the shelf `facing` convention in 31-3, which was not re-read, and the shelf's own side-chain redstone behaviour (powered chain, `getMaxChainLength`) is not covered by this part (31-3 Open question 12 remains).
7. Detector rail: only its analog output and search box are recorded; its power logic (the re-check at the `PRESSED_CHECK_PERIOD` of 20, which was read as a constant, and `updatePowerToConnected`) belongs to the rail document (30-6 section on rails). The 0.8 upper bounds of the search box are derived from the read 0.2 inset, not read as constants.
8. The song `comparator_output` field (jukebox), the sculk frequency table, the creaking heart distance rule and the command block success count semantics are cited from 31-4, 31-8, 44-5 and 31-6; their values were not re-read here.
9. Which block entities override either `Container.getMaxStackSize` overload (for example the decorated pot) is in 31 and must be checked per block entity; it was not re-read here. (The defaults, 99 and the minimum with the stack's own maximum, and `Mth.lerpDiscrete` are read.)
10. The client-side `animateTick` of the repeater was read for positions and the offset; the colour and scale of the `REDSTONE` dust particle are in 42 (the constant `DustParticleOptions.REDSTONE`).
