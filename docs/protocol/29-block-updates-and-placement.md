# 29. Block updates, ticking, block placement and block breaking

| | |
|---|---|
| Covers | The machinery that changes blocks and reacts to changes: update flags; the `setBlock` pipeline (chunk write, callbacks, client sync, neighbour and shape updates); the neighbour updater (order, depth-first propagation, limits); scheduled block ticks (`LevelTicks`); random-tick bookkeeping; block events; how block changes reach clients (section change sets, single and multi block packets, acknowledgements, level events); the use-item-on-block pipeline (packet checks, interaction order, `UseOnContext`, `BlockPlaceContext`, replaceable rules, `BlockItem` placement, sound); the block break pipeline (progress, creative and adventure rules, drops, tool damage, experience); how block entities attach to block changes. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. |
| Round | RS9 (GAP-10a and GAP-30 of `../design/README.md` Part 5) |
| Data versus code | Loot tables (block drops), tags (`replaceable`, `mineable/*`, `guarded_by_piglins`) and block registry columns are DATA or registry rows (22, 24, 26). This document specifies the engines that read them. Per-block overrides of `neighborChanged`, `updateShape`, `onPlace`, `tick`, `randomTick`, `useItemOn`, `useWithoutItem`, `getStateForPlacement`, `canSurvive` and `spawnAfterBreak` belong to the family documents (24 for placement and `canSurvive` columns, 30 and 31 for redstone and block entities, later documents for fluids, falling blocks, fire and growth); this document gives the hooks, their defaults and the order in which the engine calls them. |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each such item is repeated in the Open questions.

Related documents: wire formats of the packets named here are in 05a (Block Changed Ack, Block Destruction, Block Entity Data, Block Event, Block Update, Level Event), 05b (Section Blocks Update) and 05c (Player Action, Use Item On, Use Item). The tick order of a level, `random_tick_speed` and `randomBlockPos` are in 33 §2 and §2.4. Break speed (`getDestroyProgress`) and the client side of block breaking are in 13 §2. Tools, `hurtAndBreak` and the `tool` component are in 17. Item entities (drops) are in 41. Spawn protection and the world border test are in 33 §6.5 and §7. Section state counts and chunk encodings are in 06.

## 0. Reader's map

| Question | Section |
|---|---|
| The update flag bits and the depth limit | 1 |
| What exactly happens when a block is set | 2 |
| In which order neighbours are told, how deep, and the chained-update limit | 3 |
| Scheduled ticks: queues, ordering, priorities, delays, limits | 4 |
| Random-tick bookkeeping | 5 |
| Block events | 6 |
| How clients learn about block changes | 7 |
| Interaction result types | 8 |
| Using an item on a block, `BlockPlaceContext`, `BlockItem` | 9 |
| Breaking a block, drops, experience, tool damage | 10 |
| Game mode rules in one table | 11 |
| Block entities and block changes | 12 |
| Worked examples | 13 |
| Validation | 14 |
| Open questions | 15 |

## 1. Update flags and limits

`setBlock` takes a bit set of flags (`Block` constants, all read) and, in its four-argument form, a recursion budget.

| Bit | Value | Name | Meaning in this document |
|---|---|---|---|
| 0 | 1 | `UPDATE_NEIGHBORS` | after the change, send a neighbour-changed notification to the six neighbours (2.3, 3.1) |
| 1 | 2 | `UPDATE_CLIENTS` | after the change, queue the position for broadcast to clients (2.2, 7) |
| 2 | 4 | `UPDATE_INVISIBLE` | on a client level: suppress the redraw request. On a server level the bit has no effect on the broadcast test (2.2) |
| 3 | 8 | `UPDATE_IMMEDIATE` | client only: redraw immediately (no server consumer was read) |
| 4 | 16 | `UPDATE_KNOWN_SHAPE` | skip the shape updates of 3.2 |
| 5 | 32 | `UPDATE_SUPPRESS_DROPS` | when a shape update turns a neighbour into air, that neighbour drops nothing (3.2) |
| 6 | 64 | `UPDATE_MOVE_BY_PISTON` | the change is a piston move: `onPlace` and removal callbacks receive `movedByPiston = true` (2.1) |
| 7 | 128 | `UPDATE_SKIP_SHAPE_UPDATE_ON_WIRE` | during shape updates, a receiver that is redstone wire is skipped (3.2) |
| 8 | 256 | `UPDATE_SKIP_BLOCK_ENTITY_SIDEEFFECTS` | do not run the old block entity's `preRemoveSideEffects` (2.1) |
| 9 | 512 | `UPDATE_SKIP_ON_PLACE` | do not run the new state's `onPlace` (2.1) |

Combined constants (read): `UPDATE_NONE` 260 (4 + 256), `UPDATE_ALL` 3, `UPDATE_ALL_IMMEDIATE` 11, `UPDATE_SKIP_ALL_SIDEEFFECTS` 816 (512 + 256 + 32 + 16).

**Recursion budget.** `Block.UPDATE_LIMIT` is 512. `setBlock(pos, state, flags)` calls the four-argument form with 512; `destroyBlock(pos, drop, entity)` likewise with 512; `updateNeighbourShapes` and `updateIndirectNeighbourShapes` without an explicit budget use 512. Each nested shape-update pass hands `budget - 1` to its writes, and the shape updates of 3.2 run only while the budget is above 0, so the shape-update chain is at most 512 levels deep.

**World bounds.** `Level.isInValidBounds(pos)` is true when `y` is inside the build height (`minY <= y <= maxY` of the dimension type, `LevelHeightAccessor.isInsideBuildHeight`) and the chunk coordinates of `x` and `z` pass `ChunkPos.isValid` (the larger of the two absolute chunk coordinates is at most `ChunkPyramid.MAX_CHUNK_COORDINATE_VALUE`). That constant is computed in the class's static initializer (read) as `blockToSectionCoord(BlockPos.MAX_HORIZONTAL_COORDINATE) - SAFETY_MARGIN_CHUNKS` (`blockToSectionCoord` is an arithmetic shift right by 4, read), where `SAFETY_MARGIN_CHUNKS = (32 + n + 1) * 2` and `n` is `accumulatedDependencies().size()` of the FULL step of the generation pyramid (read: `ChunkPyramid.GENERATION_PYRAMID.getStepTo(FULL)`).

Numbers, all read this round. `BlockPos.PACKED_HORIZONTAL_LENGTH = 1 + Mth.log2(Mth.smallestEncompassingPowerOfTwo(30000000))`. The power-of-two step is a bit-smearing round-up (`v = 30000000 - 1`, OR-ed with itself shifted right by 1, 2, 4, 8, 16, then plus 1), which gives 2^25 = 33,554,432 (2^24 = 16,777,216 is below 30,000,000). `Mth.log2(v)` is `ceillog2(v)` minus 0 when `v` is a power of two (minus 1 otherwise); `ceillog2` of a power of two is a multiply-by-125613361, shift-right-27, mask-31 lookup into a 32-entry table, and the table entry at index 12 (the index for 2^25) is 25 (table read). So the log is 25 and `PACKED_HORIZONTAL_LENGTH = 26`. `MAX_HORIZONTAL_COORDINATE = (1 << 26) / 2 - 1 = 33,554,431` (the bytecode computes `(1 << L) / 2 - 1`, the same value as `(1 << (L - 1)) - 1`), so its section coordinate is `33,554,431 >> 4 = 2,097,151`.

The generation pyramid (read from its static initializer and the ten step lambdas) has these requirements: EMPTY, STRUCTURE_STARTS, INITIALIZE_LIGHT and FULL none; STRUCTURE_REFERENCES and BIOMES require STRUCTURE_STARTS at radius 8; TERRAIN requires STRUCTURE_STARTS at radius 8 and BIOMES at radius 1 (block-state write radius 0); FEATURES requires STRUCTURE_STARTS at radius 8 and TERRAIN at radius 1 (write radius 1); LIGHT requires INITIALIZE_LIGHT at radius 1; SPAWN requires BIOMES at radius 1. Each step's dependency list always begins with its parent step at radius 0; a requirement at radius `r` fills radii 0 to `r` with at least that status. The accumulated list of a step has length `max(rp + A(parent), D)`, where `D` is the length of the step's own list and `rp` is the highest radius whose entry is the parent status or later. Worked through in step order: A(EMPTY) = 0; STRUCTURE_STARTS 1; STRUCTURE_REFERENCES `max(8 + 1, 9)` = 9; BIOMES `max(0 + 9, 9)` = 9; TERRAIN `max(1 + 9, 9)` = 10; FEATURES `max(1 + 10, 9)` = 11; INITIALIZE_LIGHT `max(0 + 11, 1)` = 11; LIGHT `max(1 + 11, 2)` = 12; SPAWN `max(0 + 12, 2)` = 12; FULL `max(0 + 12, 1)` = 12. So `n = 12` (this derivation is by hand from the read rules, not an executed value), `SAFETY_MARGIN_CHUNKS = (32 + 12 + 1) * 2 = 90`, and `MAX_CHUNK_COORDINATE_VALUE = 2,097,151 - 90 = 2,097,061`. `ChunkPos.isValid(x, z)` is true when `Mth.absMax(x, z) <= 2,097,061` (`absMax` is the larger of the two absolute values; read). A block x or z is therefore chunk-valid up to 33,552,991 on the positive side (inferred: 2,097,061 * 16 + 15), far looser than the 30,000,000 test, so the world border and `isInWorldBounds` are what bind in practice. `isInWorldBounds` is the same shape of test with horizontal block limits of -30,000,000 to 29,999,999: `x` and `z` must be at least `-30000000` and strictly below `30000000` (read; the upper comparison is strict). `isInValidBounds` is therefore "inside build height" and `ChunkPos.isValid` (absolute maximum of the chunk x and z is at most 2,097,061). Entities may spawn between `y` -20,000,000 and 20,000,000.

## 2. The `setBlock` pipeline

### 2.1 `LevelChunk.setBlockState(pos, newState, flags)` (the chunk write)

Returns the old state, or "no change" (null), in which case `setBlock` returns false and does nothing else.

1. Let `section` be the chunk section containing `y`; remember whether it holds only air.
2. If the section holds only air and the new state is air: return "no change".
3. Write the state into the section (palette write, 06 §5). If the previous state is the same object as the new state: return "no change".
4. Update the four heightmaps (`MOTION_BLOCKING`, `MOTION_BLOCKING_NO_LEAVES`, `OCEAN_FLOOR`, `WORLD_SURFACE`) for this column with the new state.
5. If the section's only-air status flipped, tell the light engine (`updateSectionStatus`) and the chunk source (`onSectionEmptinessChanged`).
6. If the old and new states have different light properties (`LightEngine.hasDifferentLightProperties`): update the column's sky-light sources and queue a light check at the position (`checkBlock`). Light itself is a separate document.
7. Let `blockChanged` = old block is a different block from the new block. Let `moved` = flag 64. Let `runSideEffects` = flag 256 is **not** set.
8. If `blockChanged` and the old state has a block entity and the new state does not keep it (`shouldChangedStateKeepBlockEntity`, a per-block hook, default: keep only when the block is the same): on a server level, if `runSideEffects`, call the block entity's `preRemoveSideEffects(pos, oldState)` (this is where containers spill contents); then remove the block entity (12).
9. If `blockChanged`, or the new block is a rail (`BaseRailBlock`): on a server level, when flag 1 is set or the change is a piston move, call the **old** state's `affectNeighborsAfterRemoval(level, pos, moved)`. This is the hook by which a removed power source, rail, or similar block tells its neighbours.
10. If the section no longer holds the new block at this position (a callback replaced it): return "no change".
11. If this is a server level and flag 512 is not set: call the **new** state's `onPlace(level, pos, oldState, moved)`. This is where blocks schedule their first tick, react to neighbours, and so on.
12. If the new state has a block entity and the section still holds that block: take the existing block entity (without creating one); if it exists but does not accept the new state (`isValidBlockState`), log a warning and remove it; if none exists, create one from the block (`EntityBlock.newBlockEntity`) and register it (12); if one exists and is valid, store the new state on it and refresh its ticker (12).
13. Mark the chunk unsaved and return the old state.

### 2.2 `Level.setBlock(pos, newState, flags, budget)`

1. If `pos` is not in valid bounds, return false. If this is a server level in a debug world, return false.
2. `old` = result of the chunk write (2.1). If "no change", return false.
3. `now` = the state at `pos` after the chunk write. If `now` is not the object that was written (an `onPlace` or other callback already replaced it), skip steps 4 to 8 and return true.
4. If `old` and `now` differ, call `setBlocksDirty` (a client-level redraw hook; a no-op on the server).
5. **Client broadcast.** If flag 2 is set, and (on a client level: flag 4 is not set), and (on a server level: the chunk has a full-status that is at least `BLOCK_TICKING`): call `sendBlockUpdated(pos, old, now, flags)`. On a server level this queues the position in the chunk holder's change set (7). A chunk that is not yet block-ticking is therefore not broadcast; it reaches clients through the chunk packet.
6. **Neighbours.** If flag 1 is set: call `updateNeighborsAt(pos, old.getBlock())` (3.1; note the source block is the **old** block); then, on a server level, if the new state `hasAnalogOutputSignal`, call `updateNeighbourForOutputSignal(pos, newBlock)` (3.4).
7. **Shape updates.** If flag 16 is not set and `budget > 0`: let `f = flags & ~(1 | 32)` (bits 0 and 5 cleared; the read constant is -34). In this order: `old.updateIndirectNeighbourShapes(level, pos, f, budget - 1)`, `new.updateNeighbourShapes(level, pos, f, budget - 1)`, `new.updateIndirectNeighbourShapes(level, pos, f, budget - 1)`. The default of `updateIndirectNeighbourShapes` is empty; redstone wire and rails override it (30).
8. `updatePOIOnBlockStateChange(pos, old, new)` (server: the villager point-of-interest bookkeeping, 44 §3; client: no-op).
9. Return true.

`removeBlock(pos, moved)` sets `fluidState.createLegacyBlock()` (the fluid's block, or air when there is no fluid) with flags `3 | (moved ? 64 : 0)`. `setBlockAndUpdate` is flags 3.

`destroyBlock(pos, drop, entity, budget)`: if the state is air, return false. Otherwise: spawn the destroy effect (level event 2001 with data = the old state's global id; the entity argument is passed, null here), then if `drop`: take the block entity if any and run `Block.dropResources(state, level, pos, blockEntity, entity, ItemStack.EMPTY)` (10.4); then `setBlock(pos, fluid legacy block, 3, budget)`; if that succeeded, emit game event `BLOCK_DESTROY` with the entity and old state.

### 2.3 What the server level adds

`ServerLevel` implements `updateNeighborsAt(pos, block)`, `updateNeighborsAtExceptFromFacing`, `neighborChanged` (both forms) and `neighborShapeChanged` by handing them to the level's neighbour updater (3). `ServerLevel.updateNeighboursOnBlockSet(pos, oldState)` is a helper used by the `setblock`, `fill` and `clone` commands (the three callers in the jar): it calls the old state's `affectNeighborsAfterRemoval(level, pos, false)` only when the block type differs from the new block, then `updateNeighborsAt(pos, newBlock)` and, if the state has an analog output, `updateNeighbourForOutputSignal`.

`ServerLevel.sendBlockUpdated(pos, old, new, flags)`: marks the position changed in the chunk source (7); invalidates the path-type cache at `pos`; computes the old and new collision shapes; if they differ (`NOT_SAME` join is not empty), every mob that is navigating and whose path `shouldRecomputePath(pos)` has its path recomputed (a re-entrant call is logged as an error).

`ServerLevel.levelEvent(entity, id, pos, data)` (the server form used by 2001, 2019 and 2020): builds a Level Event packet (05a) with the global flag false and hands it to `PlayerList.broadcast` with the excluded player (the entity argument when it is a player, otherwise none), the position's integer coordinates `x, y, z` as doubles (the block corner, not its centre), a range of **64.0**, and this level's dimension. Everyone in that range receives it except the excluded player (so the breaker's own client, which already predicted the effect, is skipped for 2001). Whether 64.0 is a distance or a squared distance is Open question 15.

`ServerLevel.mayInteract(entity, pos)`: false when the entity is a player and the position is under spawn protection (33 §6.5), or when the position is outside the world border (33 §7); true otherwise.

## 3. Neighbour updates and shape updates

### 3.1 Two kinds of notification

| Kind | Method on the receiver | Meaning | Default |
|---|---|---|---|
| Neighbour changed | `neighborChanged(state, level, pos, sourceBlock, orientation, movedByPiston)` | "something next to you changed; the source is block X" | no effect |
| Shape update | `updateShape(state, level, scheduledTickAccess, pos, direction, neighbourPos, neighbourState, random)` returns a new state | "your neighbour in `direction` now has this state; return what you should become" | returns the state unchanged |

The two orders are different constants (all read):

| Name | Order |
|---|---|
| `NeighborUpdater.UPDATE_ORDER` (neighbour-changed) | west, east, down, up, north, south |
| `BlockBehaviour.UPDATE_SHAPE_ORDER` (shape updates) | west, east, north, south, down, up |

`updateNeighborsAt(pos, block)` is `updateNeighborsAtExceptFromFacing(pos, block, none)`. The "except" form skips one direction: it is used by blocks that must not notify the neighbour they are attached to (30). Each neighbour at `pos + d`, for `d` in `UPDATE_ORDER` except the skipped direction, receives `neighborChanged` with the source block given.

### 3.2 Shape updates (`BlockState.updateNeighbourShapes`)

For `d` in `UPDATE_SHAPE_ORDER`: let `r = pos + d` (the receiver). Queue a shape update on the receiver with direction `opposite(d)` (the direction from the receiver towards the changed block), neighbour position `pos`, neighbour state = the state on which `updateNeighbourShapes` was called, with the flags and budget of 2.2 step 7.

When the queued shape update runs (`NeighborUpdater.executeShapeUpdate`):

1. Read the receiver's current state at `r`.
2. If flag 128 is set and the receiver is redstone wire: do nothing.
3. `newState = receiver.updateShape(level, level, r, direction, pos, neighbourState, level.random)`.
4. `Block.updateOrDestroy(receiverState, newState, level, r, flags, budget)`: if `newState` is the same object as the receiver state: nothing. Else if `newState` is air: only when the level is **not** client side, `level.destroyBlock(r, drops = (flag 32 not set), null, budget)` (a client level skips the destroy and does nothing). Else `level.setBlock(r, newState, flags & -33, budget)` (bit 5 cleared; this nests: the write sends its own neighbour and shape updates, with the budget one lower, see 2.2 step 7). The three-argument form of `updateOrDestroy` (no budget) uses 512.

An exception thrown by an `updateShape` is reported as a crash with the block details (not a gameplay rule).

`Block.updateFromNeighbourShapes(state, level, pos)` (used when a state is created outside `setBlock`, for example by structure placement and by block placement of some families): for `d` in `UPDATE_SHAPE_ORDER`, `state = state.updateShape(level, level, pos, d, pos + d, level.getBlockState(pos + d), level.random)`, and return the final state. Note the direction passed here is `d` itself (the direction towards the neighbour), unlike 3.2 where the receiver's view is passed.

### 3.3 The neighbour updater (`CollectingNeighborUpdater`)

Every neighbour or shape notification is an entry in a queue structure with two lists: a stack of "layers" and the entries added during the current layer. The updater has a counter `count`, and the limit `maxChained` (the server property `max-chained-neighbor-updates`, default 1,000,000 (read in `DedicatedServerProperties`; a negative value means unlimited; the single-player server returns 1,000,000)).

Entry kinds: a **multi** neighbour update (one source position and block, notifies the six neighbours one per step in `UPDATE_ORDER`, skipping one direction); a **simple** one (one position and source block; reads the state at the position at the moment it runs, always with `movedByPiston = false`; finishes in one step); a **full** one (carries the receiver state, position, source block and the moved-by-piston flag; uses the carried state, not a re-read; finishes in one step); a **shape** update (3.2; `runNext` performs the update and always returns false, one step). The multi update notifies one direction per `runNext` and then advances its index past the skipped direction, if any. The Instant neighbour updater (`InstantNeighborUpdater`, which runs every notification at once with no queue, no count and no limit) exists in the jar but no other class in the jar references it; every level here constructs the collecting updater (read in the `Level` constructor with the limit argument).

Algorithm for adding an entry (`addAndRun`):

1. `nested = count > 0` (an update is already running). `overLimit = maxChained >= 0 and count >= maxChained`.
2. `count = count + 1`.
3. If not over the limit: if nested, append the entry to `addedThisLayer`; otherwise push it on the stack. If over the limit: when `count - 1 == maxChained`, log "Too many chained neighbor updates. Skipping the rest" with the first skipped position; the entry is dropped.
4. If the call was not nested: run `runUpdates`.

`runUpdates` loops while the stack or `addedThisLayer` is non-empty: (a) push the entries of `addedThisLayer` onto the stack in **reverse** order (so that the one added first is on top), clear `addedThisLayer`; (b) look at the top entry; (c) call its `runNext`; keep calling while `addedThisLayer` is empty and `runNext` returns true; (d) when `runNext` returns false the entry is popped unconditionally; the "nothing was added" test only gates the inner keep-calling loop of (c) (it continues only while `addedThisLayer` is empty and `runNext` returned true). Entries added during that final `runNext` are pushed on the next outer iteration, after the pop. When both are empty, clear the stack and `addedThisLayer` and reset `count` to 0. On an exception the same cleanup runs.

Consequences (these are the rules that matter for behaviour):

- Propagation is **depth first, in order of addition**. When a neighbour's `neighborChanged` itself changes blocks, the notifications it produces run before the parent's next neighbour is notified.
- A multi update runs one neighbour per `runNext`, reading each neighbour's state at the moment of its turn.
- The count includes every entry of one top-level cascade, not just the nesting depth. The limit is therefore on the cascade's total number of notifications.
- Shape updates and neighbour changes share the queue and the counter.

`NeighborUpdater.executeUpdate(level, state, pos, sourceBlock, orientation, movedByPiston)` calls `state.handleNeighborChanged`, which calls the block's `neighborChanged`. `orientation` is only populated when the feature flag `REDSTONE_EXPERIMENTS` is enabled; with it off, the argument is null (Open question 2).

### 3.4 `updateNeighbourForOutputSignal(pos, block)`

For `d` in north, east, south, west (the horizontal plane order): let `p = pos + d`; if the chunk at `p` is not loaded, skip. If the state at `p` is a comparator: send it `neighborChanged` (with `movedByPiston = false`, no orientation) directly through the updater. Otherwise, if that state is a redstone conductor (`isRedstoneConductor`) and the state at `p + d` is a comparator: send that comparator `neighborChanged`. (A comparator reads a container through one solid block.)

### 3.5 What `setBlock` flags the common callers use

| Caller | Flags | Effect |
|---|---|---|
| `BlockItem.placeBlock` | 11 (1 + 2 + 8) | neighbours, clients, immediate |
| `removeBlock`, `destroyBlock` | 3 (+ 64 for piston removal) | neighbours, clients |
| `Block.updateOrDestroy` write | caller flags with bit 5 cleared | |
| `BlockItem.updateBlockStateFromTag` | 2 | clients only: a state tweak that does not tell neighbours |

## 4. Scheduled ticks

### 4.1 Data

A scheduled tick (`ScheduledTick<T>`, `T` is a block or a fluid) has: the type, the position (immutable copy), `triggerTick` (absolute game time), a priority, and `subTickOrder` (a per-level counter value).

Priorities (`TickPriority`, read: seven enum constants with ordinals 0 to 6 in the order below; the number is the constant's value, which the saved form carries; the two drain comparators order priorities by `Enum.compareTo`, that is by ordinal, which gives the same order as the numeric value):

| Name | Value |
|---|---|
| `EXTREMELY_HIGH` | -3 |
| `VERY_HIGH` | -2 |
| `HIGH` | -1 |
| `NORMAL` | 0 |
| `LOW` | 1 |
| `VERY_LOW` | 2 |
| `EXTREMELY_LOW` | 3 |

Lower values (earlier ordinals) run first. `ScheduledTick` created without a priority gets `NORMAL`.

Identity: two scheduled ticks are the same when they have the same **type and position** (`UNIQUE_TICK_HASH`: hash from position and type; equality on type identity and position). Trigger time and priority do not take part. Scheduling a tick that is already pending for the same block at the same position is therefore ignored: the first schedule wins and its time is kept.

`Level.nextSubTickCount()` returns the level's `subTickCount` and then increments it (the field is a plain field with the default initial value 0; the read of the getter-then-increment is direct, the 0 start is inferred from the absence of an initializer in what was read). `LevelAccessor.createTick(pos, type, delay, priority)` makes a tick with `triggerTick = gameTime + delay` and `subTickOrder = nextSubTickCount()`. `scheduleTick(pos, block, delay[, priority])` creates the tick and hands it to the block tick queue; the fluid form uses the fluid queue. There is no cap on delay and no minimum (a delay of 0 is allowed; see 4.4).

**`ScheduledTickAccess`** (read, an interface) is the scheduling hook that shape updates receive: the second argument of `updateShape` (3.1) is a `ScheduledTickAccess`, and every call site of this document passes the level itself (3.2). It declares `createTick(pos, type, delay[, priority])`, `getBlockTicks()` and `getFluidTicks()`, and four default methods: `scheduleTick(pos, block, delay[, priority])` and `scheduleTick(pos, fluid, delay[, priority])`, each of which creates the tick through `createTick` (4.1 above) and hands it to `getBlockTicks().schedule(...)` or `getFluidTicks().schedule(...)`. A shape update that wants a later re-check therefore schedules on the same queues, with the same identity rule, as any other caller. The world-generation implementors of this interface are in 4.5.

### 4.2 Per-chunk queue (`LevelChunkTicks`)

Each chunk has a priority queue of its ticks ordered by `DRAIN_ORDER`: `triggerTick` ascending, then priority ascending, then `subTickOrder` ascending. It also has the set of pending identities. `schedule` adds the tick only when its identity is not in the set; adding notifies the level queue (4.3) so it can update the chunk's next-due time. `poll` removes the head and its identity. `hasScheduledTick(pos, type)` tests the identity set. `removeIf` removes matching ticks (used by area clearing). `pack(gameTime)` produces the saved list sorted by `subTickOrder`; each saved tick is `{type, pos, delay = triggerTick - gameTime, priority}`. `unpack(gameTime)` turns the pending saved list back into ticks with `triggerTick = gameTime + delay` and sub-tick orders `-size, -size + 1, ..., -1` in list order, so reloaded ticks sort before every tick scheduled later at the same time and priority.

Saved form (`SavedTick`, read in full). A saved tick is a record of type, position, delay (int) and priority; its codec is an object with six fields: `x`, `y`, `z` (plain ints, the absolute block position), `i` (the type, encoded with the codec handed in by the caller: the block or fluid registry id), `t` (a plain int: the **delay** in ticks, which `pack` writes as `triggerTick - gameTime` and `unpack` adds back to the game time), and `p` (the priority). `p` is declared as a required field (not optional): its codec is the int codec mapped through `TickPriority.byValue` on read and `getValue` on write, so it carries the priority's numeric value (-3 to 3, table above). Field order in the codec group is `i`, `t`, `p` after the position fields; NBT compounds are keyed by name, so order does not matter on disk. The saved delay is an int and the level's absolute game time is not stored with the tick. The persistent layout of the lists (`block_ticks`, `fluid_ticks`) is in 4.5; 07 §9 holds the chunk layout.

### 4.3 Level queue (`LevelTicks`) and one call to `tick(gameTime, maxTicks, consumer)`

State: `allContainers` (chunk position to chunk queue), `nextTickForContainer` (chunk position to the earliest trigger time of that chunk; the map's default return value is set in the constructor, its value was not read), `containersToTick` (a priority queue of chunk queues ordered by comparing their **head** ticks with `INTRA_TICK_DRAIN_ORDER`: priority ascending, then `subTickOrder` ascending; trigger time is ignored because everything considered is already due), `toRunThisTick` (a FIFO), `alreadyRunThisTick`, `toRunThisTickSet`.

Calling it (server level step 6 of 33 §2.1: blocks first with `maxTicks = 65,536`, then fluids with the same limit):

1. **Select containers.** For each entry of `nextTickForContainer`: if its time is greater than `gameTime`, skip. Remove the entry if the chunk queue is gone or empty. If the chunk's head tick is later than `gameTime`, correct the entry to the head's time. Otherwise, if the chunk passes the tick check (the level's `shouldTickBlocksAt(chunkPos)`: the chunk is inside the block-ticking range of the distance manager), remove the entry from the map and add the chunk queue to `containersToTick`. Chunks that are due but outside the ticking range keep their entry and wait.
2. **Drain.** While fewer than `maxTicks` are in `toRunThisTick`: take the container with the smallest head (by priority, then sub-tick order). Poll its head into `toRunThisTick`. The first poll from a container is unconditional: every container in `containersToTick` was put there because its head was due, so it is not re-tested. Then keep draining that container (this container is no longer in `containersToTick`, so "the next container" is the head of what remains there, or none): stop at once if no more room; otherwise, while room remains and the container's head exists and is due (`triggerTick <= gameTime`), stop if a next container exists and this head would sort after the next container's head under `INTRA_TICK_DRAIN_ORDER`; otherwise poll it into `toRunThisTick`. Only these later polls test due-ness and the comparison against the next container. After the container is drained for now, look at its new head: if there is none (the container is empty), **nothing is recorded** (a stale `nextTickForContainer` entry, if any, is removed in the next select pass, step 1, because the container is empty there); if the head is due and room remains, put the container back into `containersToTick`; otherwise (the head is not due, or the cap was reached) store the head's trigger time in `nextTickForContainer` for that chunk, replacing any earlier value.
3. Containers still in `containersToTick` after the limit was hit get their head's trigger time recorded in `nextTickForContainer` (read: `rescheduleLeftoverContainers` peeks each one; a container with a head is recorded).
4. **Run.** Poll `toRunThisTick` in FIFO order. Each tick is removed from the "will tick this tick" set when that set has been built, added to `alreadyRunThisTick`, and passed to the consumer (position, type).
5. **Clean up** the four collections.

So the run order within a game tick is a merge of the chunk queues by (priority, sub-tick order) with the constraint that each chunk's ticks are already ordered by (trigger time, priority, sub-tick order). Order between chunks that have equal priority and sub-tick values cannot occur because sub-tick orders are unique per level, except for reloaded ticks, whose negative orders are only unique per chunk (ties are then broken by the container priority queue; the order is unspecified, Open question 12).

The consumer for blocks is `ServerLevel.tickBlock(pos, block)`: if the block at `pos` is still that block, call its state's `tick(level, pos, level.random)`; otherwise the tick is silently dropped. For fluids (`tickFluid`): if the fluid at `pos` is still that fluid, call the fluid's `tick(level, pos, state)`. The level random is the level's `random` source (33).

`willTickThisTick(pos, type)` is true while the tick is in the collected list that has not run yet (it builds the set lazily from `toRunThisTick`). `hasScheduledTick(pos, type)` asks the chunk queue. `count()` sums all queues. `clearArea(box)` removes ticks inside a bounding box; `copyArea(box, offset)` copies them with their remaining delays (used by structure placement and `clone`).

### 4.4 Delay semantics (what a delay of N means)

A tick scheduled during game tick `T` with delay `N` has `triggerTick = T + N`. The tick queues are drained before entities and chunks tick (33 §2.1 step 6), so:

- a tick scheduled with delay 0 or 1 *during block ticking* is not seen by the collection that already happened; it runs in the next game tick's drain when `T + N <= T + 1`, so delay 0 and delay 1 behave the same when scheduled from inside the drain (inferred from the order: collection precedes running, and `triggerTick = T` is still due at the next collection);
- a tick scheduled from entity, chunk or player code during game tick `T` with delay `N >= 1` runs in game tick `T + N`'s drain.

### 4.5 Tick containers while a chunk is generated, loaded and saved

Read this round in `ProtoChunkTicks`, `WorldGenTickAccess`, `BlackholeTickAccess`, `ChunkAccess.PackedTicks`, `SerializableChunkData` and `LevelChunk`.

- **Proto chunk queue (`ProtoChunkTicks`).** A chunk that is not yet a full chunk keeps its ticks as a plain list of saved ticks plus an identity set (same type-and-position identity as 4.1). `schedule(tick)` converts the tick to a saved tick with **delay 0** (the trigger time and the sub-tick order are dropped; only type, position and priority are kept) and appends it only when the identity is not already present. `hasScheduledTick` tests the identity set; `count` is the list size; `pack(gameTime)` returns the list as it is (the game time is ignored, because every delay is 0 or a delay loaded from disk).
- **Level-shaped view for generation (`WorldGenTickAccess`).** Worldgen code that needs a level-like tick queue gets a view that routes `schedule` and `hasScheduledTick` to the container of the chunk that holds the tick's position (a function from position to container). `willTickThisTick` is always false and `count` is 0.
- **Black hole (`BlackholeTickAccess`).** Two shared do-nothing queues, one container form and one level form: `schedule` does nothing, `hasScheduledTick` and `willTickThisTick` are false, `count` is 0. They are the queues for contexts where scheduling must have no effect.
- **Saving.** A chunk produces a `PackedTicks` record (a list of block saved ticks and a list of fluid saved ticks) from `getTicksForSerialization(gameTime)`: a full chunk packs its two per-chunk queues with the level's game time (4.2: delay = trigger minus game time, sorted by sub-tick order); a proto chunk returns the list in 4.5's first point. The chunk writer stores the two lists as the tags `block_ticks` and `fluid_ticks` using the list codec of the saved-tick codec (4.2).
- **Loading.** The chunk reader reads `block_ticks` and `fluid_ticks`; an absent tag is an empty list; each list is **filtered to the ticks whose position lies in the chunk being read** (`filterTickListForChunk`: compare the packed chunk position of the tick with the chunk's). For a chunk whose saved status has the full-chunk type, the two lists are handed to the per-chunk queue constructor (which unpacks them with the negative sub-tick orders of 4.2 once the game time is known); for any other status they are loaded into proto queues (`ProtoChunkTicks.load` schedules each saved tick, so the delay is kept as stored but identity duplicates are dropped). A proto chunk promoted to a full chunk converts its proto queues to per-chunk queues (`unpackBlockTicks`, `unpackFluidTicks`).
- Which call hands a loaded chunk's queues to the level queue (`addContainer`, with the chunk's position) and removes them on unload (`removeContainer`) was not traced in the chunk-source classes (Open question 20).

## 5. Random ticks

`random_tick_speed` (rule, default 3, minimum 0) and the selection of positions per chunk section are in 33 §2.4: for every ticking chunk and every section that contains random-ticking blocks, `speed` positions are drawn with `randomBlockPos`; the block at the position is random-ticked if its state is random-ticking, then the fluid if it is.

What this document adds: how "contains random-ticking blocks" is kept. Each `LevelChunkSection` has `tickingBlockCount` and `tickingFluidCount` (and `nonEmptyBlockCount`, `fluidCount`). When a state is written (2.1 step 3): the previous state decrements the counts for which it qualified (not air; its `isRandomlyTicking` flag; non-empty fluid; fluid `isRandomlyTicking`), the new state increments them. A state is random-ticking when its block's `randomTicks` property was set in the builder (24 §4); `BlockStateBase.isRandomlyTicking()` returns that cached flag. The section is visited when either count is above 0 (the section's `isRandomlyTickingBlocks` and fluids test; the level loop of 33 §2.4 reads the flag).

The random tick call is `state.randomTick(level, pos, level.random)`; default empty. The random source is the level's `random`, the same source that `tickBlock` uses, so random ticks and scheduled ticks interleave on one sequence.

## 6. Block events

A block event is `(pos, block, paramA, paramB)`: used for sounds and animations that need server and client to agree (pistons, note blocks, chests, bells and similar).

- `ServerLevel.blockEvent(pos, block, a, b)` adds the event to `blockEvents`, an insertion-ordered **set**: an event equal in all four fields to a pending one is dropped.
- The queue is run once per level tick, after the chunk source tick (33 §2.1 step 9), by `runBlockEvents`: clear the reschedule list; while the set is not empty: remove the first event; if `shouldTickBlocksAt(pos)` (the chunk is in the block-ticking range): call `doBlockEvent`; when it returns true, broadcast a Block Event packet (05a, id 7) to every player of this dimension within **64.0** of the position (`PlayerList.broadcast(null, x, y, z, 64.0, dimension, packet)`; the distance test is the player list's, Open question 15); if the chunk is not ticking, put the event in the reschedule list. After the loop, append the reschedule list to the set (those events wait for a later tick).
- Events added while the loop runs (a block event handler may trigger more) are appended to the set and run in the same loop.
- `doBlockEvent`: if the block at the position is still the event's block, return `state.triggerEvent(level, pos, a, b)` (default false, per-block hook); otherwise false (the event is dropped silently, no packet).
- `clearBlockEvents(box)` removes pending events inside a box (structure placement).

The wire packet carries the block's registry id (not a state id) and two unsigned bytes (05a).

## 7. How clients learn about block changes

### 7.1 Change tracking per chunk holder

`sendBlockUpdated` (2.3) calls `ServerChunkCache.blockChanged(pos)`, which asks the chunk holder: if the holder has no ticking chunk, return false (no record). Otherwise: find the section index of `y`; if the holder had no changed sections set `hasChangedSections`; create the section's set of changed positions on first use (a set of 12-bit section-relative positions); add `sectionRelativePos(pos)`. Light changes are tracked separately in two bit sets (sky and block, per section).

### 7.2 Broadcast (`ChunkHolder.broadcastChanges`, called from the chunk source tick for every holder, 33 §2.2)

1. If there are light changes and at least one player tracks the chunk (the player provider `getPlayers(pos, boolean)` is asked with `true` in this light branch and with `false` in the block-change branch of step 2; the boolean is the provider's "bounds-only" argument, read as passed, its meaning not traced): send a Light Update packet for the chunk carrying the changed sections; clear both bit sets. (Light packet layout: 06.)
2. If there are changed block sections: get the tracking players. For each section index with a non-empty set (in index order, bottom to top):
   - **one changed position:** send a Block Update packet (position and the **current** state, read from the level, 05a id 8) to every tracking player; then if the state has a block entity, send that block entity's update packet (`getUpdatePacket`, a Block Entity Data packet, 05a id 6) when it provides one;
   - **two or more:** send one Section Blocks Update packet (05b id 86), built from the chunk **section** itself (`ClientboundSectionBlocksUpdatePacket(sectionPos, changedPositionSet, section)`, so each state id is read from the section at send time and is the **current** one), then, per changed position whose state has a block entity, send that entity's update packet.
   Clear the sets.

Consequences: several changes to one position within a tick are sent once, with the final state; the packet kind depends only on how many distinct positions of one section changed in the tick; clients may receive Block Entity Data after the block update.

### 7.3 Acknowledgement of client predictions

Player Action (05c id 41), Use Item On (id 66) and Use Item (id 67) carry a sequence number. The handler first calls `ackBlockChangesUpTo(sequence)`, which stores the maximum sequence seen (a negative value is rejected as an error). At the **start** of `ServerGamePacketListenerImpl.tick` (offset 0, before `tickPlayer` and every other per-tick step), if the stored value is above -1, the server sends a Block Changed Ack packet (05a id 4) with it and resets the stored value to -1. An ack for a sequence received between two connection ticks is therefore sent at the beginning of the connection's next tick. The relative order of that ack and the block packets of 7.2 within one game tick follows 33 §2 (not re-derived here); the client discards its predictions on receiving the ack. The client uses this to discard its predicted block states; the authoritative states arrive through 7.2 in the same game tick or earlier than the ack is sent (the ack goes out at the start of the next connection tick).

When the server rejects or alters a client action it re-sends the authoritative state **directly**, not through the change set: a Block Update packet built from the level state at the position (the packet constructor reads the current state).

### 7.4 Level events used by these pipelines

| Event id | Data | Sent when |
|---|---|---|
| 2001 | the destroyed state's global id (`Block.getId`) | block destroyed: the real site is `Block.spawnDestroyByEntityParticles(level, entity, pos, state)`; `Block.spawnDestroyParticles` (used by `Level.destroyBlock`) passes a null entity, `Block.playerWillDestroy` passes the player (who is then excluded from the broadcast) |
| 2019 | the hit face's direction ordinal | break progress ticks 1, 2, 3 of each group of 4 (see 10.2), while a player is mining |
| 2020 | the hit face's direction ordinal | break progress tick 0 of each group of 4 |

Block Destruction (05a id 5) carries the breaking entity's id, the position, and the stage 0 to 9; a value outside 0 to 9 clears the overlay. The server sends -1 to clear. All three events go through `ServerLevel.levelEvent` (2.3): recipients are the players within 64.0 of the block corner in the same dimension, minus the excluded player (2001 from `playerWillDestroy`: the breaker; 2019 and 2020 from `ServerPlayerGameMode.tick` pass a null entity, read at the call, so everyone in range including the miner receives them). The client effects of 2019 and 2020 were not read in this round (Open question 5).

## 8. Interaction results (`InteractionResult`)

| Value | Kind | `consumesAction` | Swings the arm (`shouldSwing`) |
|---|---|---|---|
| `SUCCESS` | Success, swing source `PREDICTED` | true | yes: the client already predicted the swing, the server swings without a duplicate for the acting player's client (the swing call receives `false` for "send to self" only when the source is `PREDICTED`: see 9.2 step 11) |
| `SUCCESS_SERVER` | Success, swing source `SERVER_ONLY` | true | yes, and the acting player's client is told too |
| `CONSUME` | Success, swing source `NONE` | true | no |
| `FAIL` | Fail | false | no |
| `PASS` | Pass | false | no |
| `TRY_WITH_EMPTY_HAND` | TryEmptyHandInteraction | false | no |

A Success also carries an item context: `wasItemInteraction` (the default is true; the `NONE` context is false) and an optional replacement for the held item (`heldItemTransformedTo`). `withoutItem()` returns the same Success with the `NONE` item context. `shouldSwing` is true unless the swing source is `NONE`.

## 9. Using an item on a block

### 9.1 Packet-level checks (`ServerGamePacketListenerImpl.handleUseItemOn`)

The packet carries the hand, the hit result (block position, face, exact location, "inside" flag, "world border hit" flag) and the sequence number (05c).

1. Ignore the packet while the client has not finished loading (`hasClientLoaded` false).
2. `ackBlockChangesUpTo(sequence)` (7.3).
3. Take the stack in the packet's hand. If the item is not enabled by the level's feature flags: return (no answer beyond the ack).
4. Range: if `!player.isWithinBlockInteractionRange(clickedPos, 1.0)`, return. The test: let `r = blockInteractionRange + 1.0` where the attribute `block_interaction_range` is registered as a ranged attribute with **default 4.5, minimum 0 and maximum 64**, marked syncable to the client (read in the attribute registry; `Player.DEFAULT_BLOCK_INTERACTION_RANGE` is the same 4.5); true when the squared distance from the eye position to the block's unit box is less than `r * r`. The test reads the player's current attribute value (`blockInteractionRange()`), so 4.5 + 1.0 holds only while no modifier changes the attribute (the modifier sources were not enumerated here).
5. Location sanity: let `v = hitLocation - centre of clickedPos`. If any of `|v.x|`, `|v.y|`, `|v.z|` is not less than 1.0000001, log "Location ... too far away from hit block" and return.
6. `player.resetLastActionTime()`.
7. Build limit: let `maxY = level.getMaxY()` and `minY = level.getMinY()` (the highest and lowest valid block y; both are locals held for the rest of the method). If `clickedPos.y > maxY`: show the overlay message `build.tooHigh` (argument `maxY`) and return. If `clickedPos.y < minY`: `build.tooLow` (argument `minY`) and return. The overlay is built by `ServerPlayer.sendBuildLimitMessage(isHigh, y)` (read): a **translatable component** whose key is `build.tooHigh` when `isHigh` is true and `build.tooLow` when it is false, with the integer `y` as its single argument, **styled red** (`ChatFormatting.RED`), sent to the player as an overlay message (`sendOverlayMessage`). The English strings are "The height limit for building is %s" and "The minimum height for building is %s" (`en_us` language file, read). The same method serves every `build.tooHigh` and `build.tooLow` message in this document (steps 9 and 10, chains 1 and 2).
8. If the position is under spawn protection (33 §6.5): send the overlay message `build.spawn_protection` (argument the position; English text "%s is under spawn protection", read in the language file; its style and exact argument form were not re-read this round) and skip to step 11.
9. Else, if the server is not waiting for a position acknowledgement from the client (`awaitingPositionFromClient` is null) and `level.mayInteract(player, pos)` (2.3): run `ServerPlayerGameMode.useItemOn` (9.2). If the result consumes the action, fire the `ANY_BLOCK_USE` advancement trigger. Then:
   Two chains then run **in sequence** (read in the bytecode: the second is not an `else` of the first; control always continues from chain 1 to chain 2):
   - **Chain 1:** if the face was UP, the action was not consumed, `clickedPos.y >= maxY` and the stack is a block placement attempt (9.4): show `build.tooHigh`; otherwise, if the result is a Success that should swing: `swingAndResetAttackStrength(hand, swingAnimation, sendToSelf)` where `sendToSelf` is false only when the swing source is `PREDICTED`.
   - **Chain 2:** if the action was not consumed and it was a block placement attempt: face UP and `y >= maxY` shows `build.tooHigh`; else face DOWN and `y <= minY` shows `build.tooLow` (`sendBuildLimitMessage(false, minY)`); otherwise, if the result is a Success that should swing, swing as above. Only chain 2 handles DOWN.
   Consequences: a consumed Success that swings calls `swingAndResetAttackStrength` **twice** (once per chain); an UP click at the top limit with a placement attempt that was not consumed shows `build.tooHigh` twice.
10. Else (the server was awaiting the client position, or `mayInteract` refused): call `sendBuildLimitMessage(true, maxY)` where the integer argument is the local that holds `level.getMaxY()` (read: slot 12, the value stored in step 7). The overlay is therefore the red `build.tooHigh` message with the dimension's maximum Y as its argument, whatever the actual reason for the refusal (it is not a message specific to the refusal).
11. **Always** (after steps 8 to 10): send a Block Update packet for the clicked position and another for `clickedPos + face` built from the current level states, so that the client's prediction of both is corrected.

### 9.2 `ServerPlayerGameMode.useItemOn(player, level, stack, hand, hit)`

1. If the clicked block is not enabled by the level's feature flags: `FAIL`.
2. **Spectator:** if the block has a menu provider (`getMenuProvider`: chests, crafting tables and the like), open it for the player and return `CONSUME`. Else, if the block is a portal (the `Portal` interface): compute the portal destination for the player at the position; if there is one, set the camera back to the player when it was elsewhere and teleport the player; otherwise send the overlay message `spectator.cannot_teleport` (a translatable component without arguments, styled red; English text "Unable to teleport. The other side is not generated yet.", read); return `CONSUME`. Any other block: `PASS`.
3. **Other modes.** Let `hasItem = !mainHand.isEmpty() || !offHand.isEmpty()` (both hands). Let `suppressBlock = player.isSecondaryUseActive() && hasItem` (the player is sneaking with something in either hand: the block's own interaction is skipped).
4. If `!suppressBlock`:
   1. `result = state.useItemOn(stackInHand, level, player, hand, hit)` (block hook with the item; default `TRY_WITH_EMPTY_HAND`). If the result consumes the action: fire `ITEM_USED_ON_BLOCK` for the position and the stack; return the result.
   2. If the result is `TRY_WITH_EMPTY_HAND` and the hand is the **main hand**: `result2 = state.useWithoutItem(level, player, hit)` (block hook for a bare interaction, default `PASS`: doors, buttons, beds, containers, lecterns). If it consumes: fire the `DEFAULT_BLOCK_USE` trigger and return it.
5. If the stack is empty or on cooldown (`ItemCooldowns.isOnCooldown`): `PASS`.
6. Build `UseOnContext(player, hand, hit)`.
7. If the player has infinite materials (creative): remember the stack count, call `stack.useOn(context)`, then restore the count (creative placement does not consume). Otherwise call `stack.useOn(context)`.
8. If the result is a Success and carries a replacement held item that differs from the stack, put the replacement in the hand (the default replacement is "the stack as it is now").
9. If the result consumes the action: fire `ITEM_USED_ON_BLOCK` (the trigger's item argument is the stack as it was before use).
10. Return the result.

So with the main hand used and a block-interacting block (such as a door): a normal right click first offers the **item** to the block (`useItemOn`), then, if the block says "try without item" and the hand is the main hand, the bare interaction; and a sneaking player holding anything skips both and places or uses the item. The off-hand packet is processed the same way but never reaches `useWithoutItem` (only the main-hand packet does).

### 9.3 `ItemStack.useOn(context)` and `Item.useOn`

1. If the player exists and cannot build (`abilities.mayBuild` false, the adventure rule) and the stack does not allow placing on this block (`canPlaceOnBlockInAdventureMode`: the `can_place_on` component holds an `AdventureModePredicate` that must match the block at the **clicked** position; a missing component never matches): return `PASS`.
2. Call `item.useOn(context)`. `Item.useOn` default: if the stack has a `block_transformer` component, run it (axes, shovels, hoes, the data of 17); else `PASS`. `BlockItem` overrides it (9.5).
3. If the result is a Success that was an item interaction: award the item-used statistic. Apply the after-use component side effects (`applyAfterUseComponentSideEffects`, 17) to the replacement stack; return the Success with the resulting replacement.
4. Other results are returned unchanged.

`UseOnContext` exposes: player, hand, item in hand, level, the hit result, the clicked position and face, the exact click location, the "inside" flag, `getHorizontalDirection()` (the player's facing, `Direction` of the yaw), `isSecondaryUseActive()` and `getRotation()` (the player's yaw `getYRot`).

### 9.4 What counts as a block placement attempt

`wasBlockPlacementAttempt(player, stack)`: the stack is not empty and its item is a `BlockItem`, or a `BucketItem` whose content fluid is not empty (a filled bucket), and the item is not on cooldown for the player. Used only for the build-limit overlay of 9.1.

### 9.5 `BlockPlaceContext`

`BlockPlaceContext` extends `UseOnContext` with one flag, `replaceClicked`, and one derived position `relativePos = clickedPos + face`.

**Construction.** The constructor from a `UseOnContext` copies level, player, hand, stack and hit. It first sets `replaceClicked` true and computes `relativePos`, then sets `replaceClicked = clickedState.canBeReplaced(thisContext)` (while the flag still reads true during that call; this matters for hooks that look at `getClickedPos`).

| Query | Result |
|---|---|
| `getClickedPos()` | the clicked position when `replaceClicked`; otherwise `relativePos` (the neighbour on the clicked face) |
| `canPlace()` | true when `replaceClicked` is true; otherwise `canBeReplaced(context)` of the state at `getClickedPos()` (which is then the relative position) |
| `replacingClickedOnBlock()` | `replaceClicked` |
| `getNearestLookingDirection()` | the first of `Direction.orderedByNearest(player)` |
| `getNearestLookingVerticalDirection()` | the player's facing along the Y axis (`getFacingAxis(player, Y)`) |
| `getNearestLookingDirections()` | `orderedByNearest(player)`; when not `replaceClicked`, the opposite of the clicked face is moved to the front (the array is rotated so that the opposite face is first, shifting those before it by one) |
| `at(context, pos, face)` | a new context at another position (same level, player, hand and stack): the hit location is, per axis, `pos + 0.5 + 0.5 * faceStep` (the centre of the given face of `pos`), the hit block position is `pos`, the "inside" flag false |

**The facing rules (read in `Direction`).** Let `pitch = viewXRot(1.0)` and `yaw = viewYRot(1.0)` of the player (the view angles at partial tick 1.0, in degrees; `getViewXRot` and `getViewYRot` were not themselves read), both converted with the single-precision constant 0.017453292 (degrees to radians); `Mth.sin` and `Mth.cos` take a double and return a float.

*`getFacingAxis(entity, axis)`* (read): for X it returns EAST when `-sin(yaw) > 0`, otherwise WEST; for Z it returns SOUTH when `cos(yaw) > 0`, otherwise NORTH; for Y it returns UP when `pitch < 0`, otherwise DOWN. (The X and Z tests are `Direction.isFacingAngle(yaw)` called on EAST and SOUTH: the dot product of the direction's horizontal normal with `(-sin(yaw), cos(yaw))` is greater than 0.) A pitch of exactly 0 therefore gives DOWN, and exact ties on a horizontal axis give WEST or NORTH.

*`orderedByNearest(entity)`* (read): with `s = sin(-yaw)` (the yaw is negated first), `c = cos(-yaw)`, `sp = sin(pitch)`, `cp = cos(pitch)`: the horizontal candidates are `X = EAST` if `s > 0` else `WEST`, `Y = UP` if `sp < 0` else `DOWN`, `Z = SOUTH` if `c > 0` else `NORTH`. The magnitudes are `ax = |s|`, `ay = |sp|`, `az = |c|`, `bx = ax * cp`, `bz = az * cp`. The three candidates are ordered by this decision list (strict greater-than tests, evaluated in this order):

| Test | Order of the first three candidates |
|---|---|
| `ax > az` and `ay > bx` | Y, X, Z |
| `ax > az`, not `ay > bx`, and `bz > ay` | X, Z, Y |
| `ax > az`, not `ay > bx`, not `bz > ay` | X, Y, Z |
| not `ax > az` and `ay > bz` | Y, Z, X |
| not `ax > az`, not `ay > bz`, and `bx > ay` | Z, X, Y |
| otherwise | Z, Y, X |

The returned six-entry array is `[first, second, third, opposite(third), opposite(second), opposite(first)]`. `getNearestLookingDirection()` is its first entry and `getNearestLookingDirections()` of 9.5's table starts from it. At pitch exactly 0, `ay = 0` fails both `ay >` tests, so Y is never first there, and `Y` is DOWN (the `sp < 0` test is false). The tests compare single-precision values, so a level view is decided by the float results of `Mth.sin` and `Mth.cos` (Open question 21).

**`DirectionalPlaceContext(level, pos, facing, stack, placementUp)`** (read; used by dispensers' shulker box behaviour and by falling block landing, the only classes of the jar that construct it; for non-player placement): a `BlockPlaceContext` with no player, main hand, and a hit result at the bottom centre of `pos` (`Vec3.atBottomCenterOf`), face `placementUp` (the last constructor argument), hit block `pos`, inside flag false. Overrides: `getClickedPos()` is always the hit block position `pos` (no relative shift); `canPlace()` is whether the state at `pos` `canBeReplaced(context)`; `replacingClickedOnBlock()` returns `canPlace()`; `getNearestLookingDirection()` is always DOWN; `getNearestLookingDirections()` is a fixed 6-entry ordering chosen by the `facing` constructor argument (DOWN first for the default and for the first case; the per-direction tables were not copied here, Open question 18); `getHorizontalDirection()` is NORTH when `facing` is vertical, otherwise `facing`; `isSecondaryUseActive()` is false; `getRotation()` is `facing.get2DDataValue() * 90` as a float.

So: clicking a block that can be replaced (grass, snow layers that accept the item, water with the right item) places **into** the clicked block; clicking any other block places into the neighbour on the clicked face.

**`BlockBehaviour.canBeReplaced(state, context)`** (default): `state.canBeReplaced()` (the `replaceable` builder flag, 24 §10.1) and (the stack is empty or **is not** the item of this block). A replaceable block is therefore not replaced by an item of its own type (a snow-layer item does not replace a snow layer through this default; snow layers override the hook). **`canBeReplaced(state, fluid)`**: the replaceable flag, or the state is not solid.

### 9.6 `BlockItem.useOn` and `place` (the placement algorithm)

`BlockItem.useOn(context)`:
1. `result = place(BlockPlaceContext(context))`. If it consumes: return it.
2. Else `result = Item.useOn(context)` (block transformer). If it consumes: return it.
3. If the stack has the `consumable` component (an edible block item such as a food block): return `Item.use(level, player, hand)` (starts eating).
4. Else return the first `place` result.

`BlockItem.place(context)`:
1. If the block is not enabled by the level's feature flags: `FAIL`.
2. If `!context.canPlace()` (the target is not replaceable): `FAIL`.
3. `context = updatePlacementContext(context)` (the default returns the context; an item may return null for `FAIL`, or a redirected context, for example scaffolding and similar, see the family documents).
4. `state = getPlacementState(context)` = `block.getStateForPlacement(context)` (24 §10.3 for the common ones; default the block's default state) and then the **survival and collision check** `canPlace(context, state)`; if either fails: null, then `FAIL`.
5. `placeBlock(context, state)` = `level.setBlock(getClickedPos(), state, 11)` (flags 1 + 2 + 8, budget 512; 2.2). If it returns false: `FAIL`.
6. Let `placed = level.getBlockState(pos)` after the write. If it is the same block as `state`:
   1. `placed = updateBlockStateFromTag(pos, level, stack, placed)`: when the stack has the `block_state` component and applying its properties changes the state, write it with flags 2.
   2. `updateCustomBlockEntityTag(level, player, pos, stack)` (its boolean result is discarded; steps 3 and 4 always run when the state is the same block): server only; if the stack has the `block_entity_data` component and a block entity exists at the position whose type equals the component's type: if the type is "only operators can set NBT" and the player does not pass `canUseGameMasterBlocks` (true only for a player with `abilities.instabuild`, i.e. creative mode, who also holds the permission `COMMANDS_GAMEMASTER`; read in `Player.canUseGameMasterBlocks`) return false (nothing loaded); else load the component into the block entity; true when loaded.
   3. `updateBlockEntityComponents`: if a block entity exists, apply the stack's data components to it (`applyComponentsFromItemStack`) and mark it changed.
   4. `block.setPlacedBy(level, pos, placed, player, stack)` (the hook that lets double blocks place their second half, beds their head, skulls their rotation, and so on; default empty).
   5. For a server player: fire the `PLACED_BLOCK` trigger.
7. **Sound.** `getPlaceSound(placed)` is an overridable per-item hook (`BlockItem.getPlaceSound(state)`); its default returns the placed state's `SoundType.getPlaceSound()`. Play that sound at the position in the `BLOCKS` category, volume `(soundType.volume + 1) / 2`, pitch `soundType.pitch * 0.8f` (single precision), excluding the placing player from the broadcast (the sound call's first argument is the player: the client plays its own prediction). Sound types and their volume and pitch are in 24 §8.4.
8. Game event `BLOCK_PLACE` at the position with the player and the placed state as context.
9. `stack.consume(1, player)` (nothing is removed when the player has infinite materials).
10. Return `SUCCESS`.

**`canPlace(context, state)`** (`BlockItem`): true when (the player is null, or `mustSurvive()` is false, or `state.canSurvive(level, pos)`) **and** `level.isUnobstructed(state, pos, CollisionContext.placementContext(player))`. `mustSurvive()` is true for `BlockItem` (some subclasses return false). `canSurvive` is the block hook (default true; examples in 24 §10.2). `CollisionContext.placementContext(player)` (read) builds an entity collision context with: `descending` = the player's `isDescending()` (false when the player is null), the placement flag **true**, `entityBottom` = the player's current Y (the most negative double, `-Double.MAX_VALUE`, when the player is null), `heldItem` = the player's **main-hand** item (the empty stack when the player is null), `alwaysCollideWithFluid` false, and no entity reference (the entity field is null). The context answers `isHoldingItem(item)` from the main-hand stack, `isDescending()`, `isAbove(shape, pos, ...)` by comparing `entityBottom` with the shape's top at `pos.y`, and `isPlacement()` true. Which block shapes depend on these answers (scaffolding, powder snow, rails, fluids) was not enumerated (Open question 7).

**`Level.isUnobstructed(state, pos, context)`**: let `shape = state.getCollisionShape(level, pos, context)`; true when the shape is empty, or when no blocking entity intersects the shape moved to `pos` (next paragraph). Note the context: the placement context lets blocks vary their collision shape for the placer (scaffolding is solid unless the placer is above it).

**Entity obstruction (`EntityGetter.isUnobstructed(entity, shape)`)**: take the entities (spectators excluded) in the shape's bounds; the placement is obstructed when any entity that is not removed, has `blocksBuilding` true, is not a passenger of the same vehicle as the given entity (none is given here), and whose bounding box intersects the shape (`BooleanOp.AND`) exists. `blocksBuilding` is true for: living entities (all), boats, minecarts, end crystals, primed TNT, falling block entities, striders and armor stands (`ArmorStand` sets it to `!isMarker()` in `onSyncedDataUpdated`; the initial true comes from the `LivingEntity` constructor). These are all the classes that write the field (read); `Entity` declares it as a public field with default false; it is false for the base `Entity`, so item entities, arrows, experience orbs and similar never block.

### 9.7 `Item.use` (the "use in air" path, `handleUseItem`)

`ServerGamePacketListenerImpl.handleUseItem`: ack the sequence; take the stack in the hand; reset last action time; return if the stack is empty or not enabled; compute the interact animation; wrap the packet's yaw and pitch with `Mth.wrapDegrees` and, if either differs from the player's rotation, snap the player to it (`absSnapRotationTo`); call `ServerPlayerGameMode.useItem`; if a Success should swing, swing as in 9.1.

`ServerPlayerGameMode.useItem(player, level, stack, hand)`: spectators get `PASS`; an item on cooldown gets `PASS`. Remember the count and damage value; `result = stack.use(level, player, hand)`; the held item after use is the replacement of a Success or the hand item. If the new stack is the same object with the same count, no use duration (`getUseDuration <= 0`) and the same damage, return the result without further work; if the result is a `Fail` and the stack has a use duration and the player is not already using an item, return it; otherwise store the new stack in the hand if it differs, store the empty stack when it is empty, and when the player is not using an item resend the whole inventory menu (`sendAllDataToRemote`). `Item.use` default handles the consumable, equippable and similar components (17).

## 10. Breaking a block

### 10.1 Packet handling (`handlePlayerAction` and `ServerPlayerGameMode.handleBlockBreakAction`)

`handlePlayerAction` ignores the packet until the client has loaded, resets the last-action time and switches on the action. The three block actions (`START_DESTROY_BLOCK`, `ABORT_DESTROY_BLOCK`, `STOP_DESTROY_BLOCK`) call `handleBlockBreakAction(pos, action, face, maxY = level.getMaxY(), sequence)` and then `ackBlockChangesUpTo(sequence)`. (The other actions are item drops, swap hands, release use item and the like; their order of tests is in 05c and 13.)

`handleBlockBreakAction(pos, action, face, maxY, sequence)`:

1. If `!player.isWithinBlockInteractionRange(pos, 1.0)` (9.1 step 4): when the player is currently destroying and the action is `ABORT`, abort first (10.3); then only `debugLogging` (a log call, "too far") runs and the method returns. **No Block Update is re-sent in this case** (read). `debugLogging` in `ServerPlayerGameMode` is log-only.
2. If `pos.y > maxY`: re-send the block state at `pos` (Block Update from the level) and return.
3. **`START_DESTROY_BLOCK`:**
   1. If the position is under spawn protection (33 §6.5): send `build.spawn_protection` and return (the message only; no state is re-sent).
   2. If `!level.mayInteract(player, pos)`: re-send the state and return.
   3. If the player is creative (`abilities.instabuild`): `destroyAndAck(pos, sequence)` and return.
   4. If `player.blockActionRestricted(level, pos, gameMode)` (11): re-send the state and return.
   5. `destroyProgressStart = gameTicks` (the player's game-mode tick counter, incremented at the start of every `ServerPlayerGameMode.tick`). Let `progress = 1.0`.
   6. If the block is not air: run the enchantment effects of the held item for hitting a block (`EnchantmentHelper.onHitBlock`, 28; the consumer breaks the item when the effect destroys it); call `state.attack(level, pos, player)` (block hook for a punch: note blocks play, and similar; default empty); then `progress = state.getDestroyProgress(player, level, pos)` (13 §2.5: per-tick progress).
   7. If the block is not air and `progress >= 1.0`: `destroyAndAck(pos, sequence)` (instant break).
   8. Otherwise: if the player was already destroying a block (a client "insta-mine" the server disagreed with), re-send the state at the previous `destroyPos`. Then `isDestroyingBlock = true`, `destroyPos = pos`, `destroyDirection = face`, send Block Destruction for stage `(int)(progress * 10)` (float multiplication then truncation) with the player's entity id, and remember it as `lastSentState`.
4. **`CHANGE_DESTROY_DIRECTION`:** store `destroyDirection = face` (used for the particle event ids, 7.4).
5. **`STOP_DESTROY_BLOCK`:** if `pos` equals `destroyPos`: let `ticks = gameTicks - destroyProgressStart` and `state` = the block at `pos`; if it is not air: let `p = state.getDestroyProgress(player, level, pos) * (ticks + 1)`. If `p >= 0.7`: stop destroying, send Block Destruction -1, and `destroyAndAck(pos, sequence)`; return. Otherwise, if no delayed destroy is pending: stop destroying, start a **delayed destroy**: `hasDelayedDestroy = true`, `delayedDestroyPos = pos`, `delayedTickStart = destroyProgressStart`. (The server accepts a client that believes it has finished when it is at 70% of the server-computed progress or more; otherwise it keeps counting for the client in `tick`, 10.2.)
6. **`ABORT_DESTROY_BLOCK`:** `abortDestroyBlock(pos, sequence)`.

`destroyAndAck(pos, sequence)`: `destroyBlock(pos)` (10.4); if it returned false, send a Block Update for the position (the client's predicted removal is undone).

### 10.2 Per-tick progress (`ServerPlayerGameMode.tick`)

1. `gameTicks = gameTicks + 1`.
2. If a delayed destroy is pending: if the block at its position is air, cancel it. Else compute `incrementDestroyProgress(state, pos, delayedTickStart)`; when it returns at least 1.0, cancel the delay and `destroyBlock(pos)`.
3. Else if the player is destroying a block: if the block at `destroyPos` is now air, send Block Destruction -1, `lastSentState = -1`, stop destroying. Otherwise let `ticks = gameTicks - destroyProgressStart`; call `incrementDestroyProgress(state, destroyPos, destroyProgressStart)` (it ignores the return value here); then send a level event to everyone near the block: id **2020** when `ticks mod 4 == 0`, otherwise **2019**, with data the ordinal of `destroyDirection` (the hit-effect sound and particles).

`incrementDestroyProgress(state, pos, startTick)`: `progress = state.getDestroyProgress(player, level, pos) * ((gameTicks - startTick) + 1)` (the tick count includes the current tick); `stage = (int)(progress * 10.0f)`; when `stage != lastSentState`, send Block Destruction (player id, pos, stage) and store it; return `progress`.

### 10.3 `abortDestroyBlock(pos, sequence)`

Steps in the order read:

1. Clear `isDestroyingBlock` (this is the **first** step, read; it happens before any test).
2. Compare `pos` with the stored `destroyPos` using a null-safe equality test (`Objects.equals`). If they are **not** equal: log a warning ("Mismatch in destroy block pos", both positions) and send Block Destruction stage -1 for the stored `destroyPos` (with the player's entity id). Then a debug-log call (log only).
3. Always: send Block Destruction stage -1 for `pos` (with the player's entity id), then a debug-log call.

The method itself sends no acknowledgement and no Block Update. The caller (`handlePlayerAction`, 10.1) calls `ackBlockChangesUpTo(sequence)` after it returns. The other fields of the digging state (`destroyPos`, `destroyProgressStart`, the delayed-destroy fields, `lastSentState`) are not touched here.

### 10.4 `ServerPlayerGameMode.destroyBlock(pos)` (the authoritative break)

Returns whether the block was removed.

1. `state = level.getBlockState(pos)`; `blockEntity = level.getBlockEntity(pos)` (null when the state has none).
2. If `!mainHand.canDestroyBlock(state, level, pos, player)` return false. (`Item.canDestroyBlock`: when the item has the `tool` component and that component does **not** allow destroying blocks in creative, the answer is "the player is not creative"; otherwise true. This is how swords cannot break blocks in creative.)
3. If the block is a game-master block (command blocks, structure blocks, jigsaw blocks, `GameMasterBlock`) and `!player.canUseGameMasterBlocks()` (creative mode and the game-master command permission, both required; the exact permission level number behind `COMMANDS_GAMEMASTER` is in the permissions document, not read here): send the block-updated notification to clients with flags 3 (the position is queued, 7.1) and return false.
4. If `player.blockActionRestricted(level, pos, gameMode)` (11): return false.
5. `state = block.playerWillDestroy(level, pos, state, player)`. Default: spawn the destroy effect (level event 2001 with `Block.getId(state)`, the player as the excluded entity); if the block is in the tag `guarded_by_piglins` and the level is a server level, anger nearby piglins (`PiglinAi.angerNearbyPiglins`, 20 and 44); game event `BLOCK_DESTROY` with the player and the state; return the state (blocks such as doors, beds and tall plants override this to remove their other half first).
6. `removed = level.removeBlock(pos, false)` (2.2: the position becomes the fluid's block or air, flags 3).
7. If `removed`: call `block.destroy(level, pos, state)` (hook, default empty).
8. If `player.preventsBlockDrops()` (creative: `abilities.instabuild`): return true. No drops, no tool damage, no experience in creative.
9. `tool = mainHand`, `toolCopy = copy of tool`, `correct = player.hasCorrectToolForDrops(state)` (true when the block does not require a correct tool, or the held item is the correct tool for drops, 17).
10. `tool.mineBlock(level, state, pos, player)`: `Item.mineBlock` for an item with the `tool` component, on a server level, when the block's destroy time (hardness) is not 0 and the tool's `damagePerBlock > 0`: `hurtAndBreak(damagePerBlock, player, MAINHAND)` (17 §4 for durability). It returns true for such items and the used statistic is awarded; items without a `tool` component do nothing.
11. If `removed` and `correct`: `block.playerDestroy(level, player, pos, state, blockEntity, toolCopy)`. Default: award the "block mined" statistic for the block; add food exhaustion **0.005**; call `Block.dropResources(state, level, pos, blockEntity, player, toolCopy)`.
12. Return true.

Note the order: the block is removed **before** the tool is damaged and before the drops are computed; the drops use the state, the block entity and the tool as they were before removal (the tool is the copy made before damage).

### 10.5 Drops (`Block.dropResources` and related)

`dropResources(state, level, pos, blockEntity, entity, tool)` (server level only):
1. `drops = Block.getDrops(state, level, pos, blockEntity, entity, tool)`: build loot parameters `origin = centre of pos`, `tool`, optional `this_entity`, optional `block_entity`; the state's `getDrops(params)` (default: when the block has no loot table, no drops; else add the `block_state` parameter and roll the block's loot table with the context set `BLOCK`, 26). Tag `mineable/*` and the correct tool are inputs to the loot conditions through the tool parameter (26, 17).
2. For each stack: `popResource(level, pos, stack)`.
3. `state.spawnAfterBreak(level, pos, tool, dropExperience = true)`.

Variants without an entity use `ItemStack.EMPTY` as the tool and no entity (this is what `destroyBlock(pos, true)` and piston, fluid and shape-update breaks do); `getDrops` also has a form without an entity.

**The random draws come first.** In both functions the level-random draws happen **before** any check, on a client level as well as a server level, and the item entity is built only afterwards, through a deferred constructor that the common routine runs once its checks pass. The common routine (`popResource(level, entity supplier, stack)`) does this, in order: (1) if the level is not a server level, return; (2) if the stack is empty, return; (3) if the rule `block_drops` (33 §8) is false, return; (4) run the supplier to build the item entity, give it its default pickup delay (41), and add it to the level. So when the stack is empty, the rule is off, or the level is a client level, **no entity is created but the random sequence has still advanced** by the draws below, and an implementation that skips the draws in those cases desynchronises the level random.

`popResource(level, pos, stack)`: let `h = itemEntityHeight / 2` (the item entity type's height, 41). Draw, from the level random and in this order, `a = nextDouble(-0.25, 0.25)` for x, then for y, then for z (three draws, always). The entity position is `x = pos.x + 0.5 + a_x`, `y = pos.y + 0.5 + a_y - h`, `z = pos.z + 0.5 + a_z`. The entity is built at that position with the stack, and handed to the common routine.

`popResourceFromFace(level, pos, face, stack)` (used by dispensing and by blocks that eject sideways): with `(sx, sy, sz)` the face step and `w = itemEntityWidth / 2`, `h = itemEntityHeight / 2`: `x = pos.x + 0.5 + (sx == 0 ? nextDouble(-0.25, 0.25) : sx * (0.5 + w))`, `y = pos.y + 0.5 + (sy == 0 ? nextDouble(-0.25, 0.25) : sy * (0.5 + h)) - h`, `z` like `x` with `sz` and `w`; velocity `vx = sx == 0 ? nextDouble(-0.1, 0.1) : sx * 0.1`, `vy = sy == 0 ? nextDouble(0.0, 0.1) : sy * 0.1 + 0.1`, `vz = sz == 0 ? nextDouble(-0.1, 0.1) : sz * 0.1`. Random draws happen in the order x, y, z (each only when its step is 0), then vx, vy, vz (each only when its step is 0), all before the checks of the common routine. For a face with one non-zero step component, two of the three position draws and two of the three velocity draws happen (four draws in all). The item entity is created with that velocity. (`nextDouble(min, max)` is `Mth.nextDouble(random, min, max)`, read: it returns `min` when `min >= max`, otherwise `random.nextDouble() * (max - min) + min`; the argument order at the call sites is read.)

`spawnAfterBreak(state, level, pos, tool, dropExperience)`: block hook, default empty. Ore-like blocks (24 `DropExperienceBlock`) override it to call `tryDropExperience(level, pos, tool, intProvider)`: sample the provider from the level random, pass the result through the enchantment engine (`EnchantmentHelper.processBlockExperience`, 28; silk touch style effects reduce it to 0), and when the amount is positive call `popExperience(level, pos, amount)`: nothing when the rule `block_drops` is false, otherwise `ExperienceOrb.award(level, centre of pos, amount)` (orb splitting is in the experience orb document, 41 and 45).

### 10.6 Non-player breaking

`Level.destroyBlock(pos, drop, entity, budget)` (2.2) is the entity-agnostic break used by explosions, fluids, pistons, shape updates (`updateOrDestroy`), commands (`setblock ... destroy`, `fill ... destroy`) and mobs. It does not call `playerWillDestroy`, does not damage tools and does not honour creative rules; drops use an empty tool and `entity` as `this_entity`.

## 11. Game mode and permission rules in one table

| Situation | Survival | Creative | Adventure | Spectator |
|---|---|---|---|---|
| `abilities.mayBuild` | true | true | false | false |
| `abilities.instabuild` | false | true | false | false |
| Start digging (10.1) | progress rules | instant `destroyAndAck` (still subject to `canDestroyBlock`, so a sword fails) | `blockActionRestricted` unless the held item's `can_break` component matches the target block | no digging (spectator's attack action returns at the top of `handlePlayerAction`) |
| `blockActionRestricted(level, pos, mode)` | false | false | false when `mayBuild` (never for adventure); true when the main hand is empty or `can_break` does not match | true |
| `useItemOn` at the block (9.2) | full | full | block interaction allowed; placing needs `can_place_on` to match the **clicked** block (`ItemStack.useOn`) | menus and portals only (9.2 step 2) |
| Drops, tool damage | yes | none | yes (when breaking is allowed) | n/a |
| Place consumes the item | yes | no (count restored) | yes | n/a |

`mayBuild` is computed from the mode: `GameType.updatePlayerAbilities` sets `mayBuild = !isBlockPlacingRestricted()`, and the restricted modes are adventure and spectator (read). Survival and creative never reach the `can_break` check. `Player.mayUseItemAt(pos, face, stack)` (used by other item code such as buckets and flint) is true when `mayBuild` (its callers were not enumerated, Open question 19); otherwise it asks the stack's `can_place_on` against the block at `pos + opposite(face)`.

`isWithinBlockInteractionRange` and `mayInteract` apply to every mode. A player in spectator mode is also excluded from entity obstruction (9.6) because spectators are filtered from the entity query.

## 12. Block entities and block changes

- A block state has a block entity when its block is an `EntityBlock`; `hasBlockEntity` is a per-state test.
- **Creation at placement.** In 2.1 step 12 a new block entity is created by `EntityBlock.newBlockEntity(pos, state)` and `addAndRegisterBlockEntity`: it is stored in the chunk's block entity map, and, when the chunk is in the level, the level is told (`onBlockEntityAdded`), a game-event listener is registered if the entity listens for game events, and `updateBlockEntityTicker` runs.
- **Lazy creation.** `LevelChunk.getBlockEntity(pos, type)`: return the stored entity; if none and a pending saved tag exists for the position (loaded from disk), promote it (create, load, register); if still none and the creation type is `IMMEDIATE`, create and register one from the block; a stored entity that was marked removed is dropped from the map and null is returned.
- **State change keeps or replaces.** `shouldChangedStateKeepBlockEntity(newState)`: per-block hook; the default keeps the entity only when the block type is unchanged. When the entity is kept and the state changes, the entity gets the new state and the ticker is refreshed.
- **Removal.** `LevelChunk.removeBlockEntity(pos)`: remove from the map, unregister the game-event listener, drop the debug sync, mark the entity removed, remove its ticker. `preRemoveSideEffects` runs first when flag 256 is not set and the level is a server level.
- **Tickers.** `updateBlockEntityTicker(entity)`: `state.getTicker(level, type)` returns the per-type tick function (null when the block does not tick this type); null removes the ticker for the position, otherwise a ticker is stored for the position. `Level.addBlockEntityTicker` appends to the pending list while tickers are being run, otherwise to the active list.
- **Ticking** (`Level.tickBlockEntities`, step 11.3 of 33 §2.1, only while the level has not been idle for 300 ticks): move pending tickers into the active list; for each ticker: remove it if it is marked removed; otherwise, when the tick rate manager allows normal running and `shouldTickBlocksAt(pos)` is true (the chunk is block-ticking), tick it. The ticker wrapper additionally requires `LevelChunk.isTicking(pos)`: the position is inside the world border and (on a server) the chunk's full status is at least `BLOCK_TICKING` and the entities of the chunk are loaded.
- **Client data.** A block entity may supply an update packet (`getUpdatePacket`); the packets sent after block changes are in 7.2. On chunk load the block entity data is part of the chunk packet (06).
- **Item placement.** The `block_entity_data` component of the placed stack is loaded into the entity after placement (9.6 step 6.2); the other components are applied by `applyComponentsFromItemStack` (9.6 step 6.3).
- Block entity types, their NBT and their menus are in 31 (when written).

## 13. Worked examples

**13.1 Placing a stone block in survival on the top face of a dirt block at D = (10, 63, 10).**
1. Client sends Use Item On: hand main, block D, face UP, sequence 7. Range and location checks pass. `y = 63` is inside the build limits.
2. `useItemOn`: dirt's `useItemOn` returns `TRY_WITH_EMPTY_HAND`; hand is main, so `useWithoutItem` is asked (`PASS` for dirt); step 5: the stack is not empty; `UseOnContext`; `stack.useOn`.
3. `BlockPlaceContext`: `replaceClicked` is false (dirt is not replaceable), `getClickedPos()` = (10, 64, 10). `canPlace()` asks whether the block at (10, 64, 10) can be replaced: air is replaceable, true.
4. `getStateForPlacement` returns stone's default state. `canPlace`: `canSurvive` true; collision shape is a full block; no blocking entity in the box: ok.
5. `setBlock((10, 64, 10), stone, 11)`: chunk write, `onPlace` (default empty), then flag 2: queued for broadcast; flag 1: the six neighbours receive `neighborChanged` with the **old** block (air) as source in the order W, E, D, U, N, S; shape updates: each neighbour gets `updateShape` in the order W, E, N, S, D, U, with `direction` from the receiver's point of view (the west neighbour sees direction EAST).
6. Sound: stone's place sound at volume `(vol + 1) / 2`, pitch `pitch * 0.8`; stack count decreases by 1.
7. Server sends Block Changed Ack(7) at the **start** of the connection's next tick (7.3); during the chunk broadcast: one changed position in the section, so a Block Update packet (not a section packet). The client gets a corrective Block Update for D and for the placed position at the end of `handleUseItemOn` (9.1 step 11).

**13.2 Shape-update propagation order.** A torch at (0, 5, 0) is attached to the block at (0, 4, 0). The block at (0, 4, 0) is removed with `removeBlock`. Flags 3, budget 512. After the write: neighbours notified W, E, D, U, N, S. Shape updates (the removed block is air): receivers in order W (-1,4,0), E (1,4,0), N (0,4,-1), S (0,4,1), D (0,3,0), U (0,5,0). The torch at U gets `updateShape` with direction DOWN; it checks `canSurvive` and returns air; `updateOrDestroy` calls `destroyBlock((0,5,0), drops = true, ...)`, which drops the torch item and writes air with flags 3 and budget 511 (since the budget was decremented), which in turn runs the same cascade for the torch's neighbours before the original cascade continues with the next receiver (here none remain). If the removal had used flag 32 in the flags (suppress drops), no torch item would drop.

**13.3 Tick ordering.** Chunk X has ticks `a` (trigger 100, `NORMAL`, order 40) and `b` (trigger 100, `HIGH`, order 41), `c` (trigger 99, `LOW`, order 10). Chunk Y has `d` (trigger 100, `EXTREMELY_HIGH`, order 55). At game time 100, all due; both chunks in range. Containers: X's head is `c` (trigger 99 first), Y's head is `d`. The queue of containers is ordered by (priority, order): `d` (-3) before `c` (1). Drain Y first: `d` runs first. Then X: `c` (earliest trigger), then `b` and `a`? Within X the per-chunk order is (trigger, priority, order): `c` (99), then `b` (100, HIGH), then `a` (100, NORMAL). Run order: `d, c, b, a`. (X is drained as one block because after `c` the next container `Y` is empty.)

**13.4 Duplicate scheduling.** `scheduleTick(P, stone-like block B, 5)` at game time 200, then `scheduleTick(P, B, 2)` the same tick: the second is ignored (same type and position); the tick runs at 205. After it runs, scheduling again is accepted.

**13.5 Break progress.** Per-tick progress `s = 0.04`. START at `gameTicks = 100`: `progress = 0.04`; stage `(int)(0.4) = 0` sent. At `gameTicks = 101`: `ticks = 1`, `progress = 0.04 * 2 = 0.08`, stage 0 (not re-sent, equal to the stored value). At `gameTicks = 103`: `ticks = 3`, `progress = 0.16`, stage 1 sent. Level event 2020 at `ticks` 0, 4, 8, ... and 2019 at the others. If the client sends STOP at `gameTicks = 117`: `ticks = 17`, `p = 0.04 * 18 = 0.72 >= 0.7`: accepted and broken. If it sends STOP at 116: `ticks = 16`, `p = 0.68 < 0.7`: not accepted; the server starts the delayed destroy and breaks the block in its own tick when `incrementDestroyProgress` reaches 1.0, which is at `ticks + 1 = 25`, that is at `gameTicks = 124`. (The float arithmetic of the artifact is single precision, so `0.04f * 18` should be computed in single precision to confirm the boundary cases.)

**13.6 Drop position.** Block at (10, 64, 10) broken, item entity height `H`: three `nextDouble` draws `a, b, c` in [-0.25, 0.25] (in that order, from the level random) are made first, **whether or not an entity is spawned**; when the stack is non-empty, `block_drops` is true and the level is a server level, the item spawns at `(10.5 + a, 64.5 + b - H/2, 10.5 + c)`. With an empty stack or `block_drops` false, the three draws are still consumed and nothing spawns.

**13.7 Sneak placement against a chest.** The chest's `useItemOn` is not reached because a sneaking player with a block in hand has `suppressBlock = true`; the block item is placed against the chest (the chest is not replaceable, so `getClickedPos()` is the neighbour on the clicked face). Without sneaking, the chest opens (its `useWithoutItem` returns a consuming result) and no block is placed.

## 14. Validation

| # | Check | Expected |
|---|---|---|
| 1 | Flag values | 1, 2, 4, 8, 16, 32, 64, 128, 256, 512; `UPDATE_ALL` 3; `UPDATE_ALL_IMMEDIATE` 11; `UPDATE_NONE` 260; `UPDATE_SKIP_ALL_SIDEEFFECTS` 816; `UPDATE_LIMIT` 512 |
| 2 | Neighbour order | W, E, D, U, N, S |
| 3 | Shape-update order | W, E, N, S, D, U; receiver direction is the opposite of the step |
| 4 | Source block of `updateNeighborsAt` in `setBlock` | the old block |
| 5 | Shape updates skipped | flag 16 set or budget 0 |
| 6 | Flags passed to shape-update writes | caller flags with bits 0 and 5 cleared (`& ~33`); `updateOrDestroy`'s write also clears bit 5 |
| 7 | Chained update limit | default 1,000,000 per cascade; negative unlimited |
| 8 | Cascade order | depth first, in order of addition |
| 9 | Duplicate tick | same type and position are ignored |
| 10 | Tick order | per chunk: trigger, priority, sub-tick order; across chunks: priority, sub-tick order |
| 11 | Tick limit per call | 65,536 for blocks and again for fluids |
| 12 | Tick consumer | dropped if the block at the position changed |
| 13 | Block events | set semantics, 64.0 broadcast radius, rescheduled when the chunk does not tick |
| 14 | Block change packets | one position per section per tick: Block Update; two or more: Section Blocks Update; block entity data follows |
| 15 | Ack | max sequence per tick, sent at the start of the connection's tick, before `tickPlayer` |
| 16 | Use item on checks | range (4.5 + 1.0), hit location 1.0000001, build limits, spawn protection, `mayInteract` |
| 17 | Sneak rule | `isSecondaryUseActive` and an item in either hand skips block interaction |
| 18 | Placement sound | volume `(v + 1) / 2`, pitch `p * 0.8` |
| 19 | Placement flags | 11 |
| 20 | Break acceptance | stop accepted at 0.7 of server progress |
| 21 | Break exhaustion | 0.005 per block with `playerDestroy` |
| 22 | Creative break | no drops, no tool damage, `canDestroyBlock` still applies |
| 23 | Level events | 2001 on destroy, 2019 and 2020 while mining |
| 24 | Adventure | `can_break` and `can_place_on` components are required |
| 25 | Drop random draws | three draws (x, y, z) per `popResource` before any check; the entity is built only for a non-empty stack, `block_drops` true, server level |
| 26 | `abortDestroyBlock` order | clear flag, then mismatch warning and -1 for the stored position, then -1 for `pos`; no ack inside |
| 27 | Saved tick | `i` type, `t` int delay, `p` required priority value, `x`, `y`, `z` ints |
| 28 | Chunk coordinate limit | `ChunkPos.isValid`: larger absolute chunk coordinate at most 2,097,061 |

## 15. Open questions

1. (Resolved: `MAX_CHUNK_COORDINATE_VALUE` is 2,097,061, section 1; the generation-pyramid dependency count was derived by hand from the read step requirements (n = 12) and not executed. Number kept.)
2. The `orientation` argument of `neighborChanged` (the experimental redstone orientation) is only populated with the `REDSTONE_EXPERIMENTS` feature flag; the flag's default (assumed off) and the orientation logic were not specified (belongs to 30).
3. (Resolved: the two chains of 9.1 step 9 run in sequence. Number kept so later references stay valid.)
4. (Resolved: `canUseGameMasterBlocks` is creative mode plus the `COMMANDS_GAMEMASTER` permission, 9.6 and 10.4. Still open: the numeric permission level behind `COMMANDS_GAMEMASTER`, which belongs to the permissions document. Number kept.)
5. The client effects of level events 2019 and 2020 (block-hit sound, particles, crack) were read as ids only. 12 and 13 describe the client's own crack logic.
6. `AdventureModePredicate` matching (block predicate list, `can_break` and `can_place_on` JSON schema, the optional tooltip flag) was not read. It is data-component content and belongs with 17's component model.
7. `CollisionContext.placementContext(player)` was read (9.6: descending flag, main-hand item, player Y, placement flag true). Still open: the `Block.getCollisionShape(state, level, pos, context)` overrides that depend on these answers (scaffolding, powder snow, fluids and others).
8. (Resolved: the `SavedTick` codec is read, 4.2: `i` type, `t` int delay, `p` required priority value. Number kept.)
9. (Resolved: `orderedByNearest` and `getFacingAxis` are read, 9.5. Still open: `Entity.getViewXRot(1.0)` and `getViewYRot(1.0)` and the `Mth.sin` and `Mth.cos` tables, items 20 and 21 below. Number kept.)
10. The initial value of the level's `subTickCount` is inferred to be 0 (default field value; the increment-after-read is read). (The `ArmorStand.blocksBuilding` question is resolved: 9.6.)
11. `Item.use` per-component behaviours (consumable, equippable and others) and `applyAfterUseComponentSideEffects` are in 17 only partly.
12. Order of ticks from different chunks that were reloaded (negative sub-tick orders are unique only per chunk) was not specified; the container priority queue breaks the tie in an unspecified way.
13. `ServerLevel.updateNeighboursOnBlockSet` callers (`setblock`, `fill`, `clone`) and the flags those commands use were not read in detail (16 covers the command semantics).
14. Which blocks override `neighborChanged`, `updateShape`, `onPlace`, `affectNeighborsAfterRemoval`, `tick`, `randomTick`, `useItemOn`, `useWithoutItem`, `playerWillDestroy`, `spawnAfterBreak`, `triggerEvent` and `setPlacedBy` is not enumerated here (family documents).
15. `PlayerList.broadcast(player, x, y, z, 64.0, dimension, packet)`: whether 64.0 is compared as a distance or as a squared distance, and the measure (player position to block centre) was not read.
16. (Resolved: `Mth.nextDouble` read, 10.5. Number kept.)
17. The fallback behaviour of `popResource` for a full world (item entity spawn refused) and the item entity's initial velocity (41) were not rechecked here.
18. `DirectionalPlaceContext.getNearestLookingDirections()` returns one of six fixed 6-entry direction orderings selected by the `facing` argument; only the first entry of the default case (DOWN, then NORTH, EAST, SOUTH, WEST, UP as read for the first table) was noted; the other five tables were not transcribed. Dispenser behaviour that depends on them belongs to a later document.
19. The callers of `Player.mayUseItemAt` and whether the single-player server's `max-chained-neighbor-updates` return value (1,000,000) and the `DedicatedServerProperties` default were read are not independently confirmed in this round (3.3 keeps the earlier statement). `Level.sendBlockUpdated` guard conditions for the client level and the effects of the client-only `UPDATE_IMMEDIATE` consumer were not read.
20. How a loaded or generated chunk's per-chunk tick queues are registered with and removed from the level queue (`LevelTicks.addContainer`, `removeContainer`), and which chunk-source call does it, was not traced (4.5). Searched: `LevelTicks`, `LevelChunk`, `SerializableChunkData`, `ProtoChunk`.
21. `Mth.sin` and `Mth.cos` (the lookup table `SIN` is a float array built in the `Mth` static initializer; its size and angle scaling were not read) and `Entity.getViewXRot(1.0)`, `getViewYRot(1.0)` (assumed to be the entity's current pitch and yaw at partial tick 1.0, recalled, not verified) decide the float tie cases of the facing rules in 9.5.
22. `ServerPlayer.sendOverlayMessage` was read only as a call; its wire form (which packet carries an overlay message) was not looked up in this round. The style of `build.spawn_protection` and the form of its argument (9.1 step 8) were not re-read.
23. The constructor arguments of the item entity in `popResource` and `popResourceFromFace` (the deferred supplier lambdas) were not read; they are assumed to be level, position, stack and, for the face form, velocity (inferred).
