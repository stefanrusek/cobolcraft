# 30-3 Redstone: pistons

| Item | Value |
|---|---|
| Covers | The piston family: `PistonBaseBlock` (normal and sticky), `PistonHeadBlock`, `MovingPistonBlock` and `PistonMovingBlockEntity`; `PistonStructureResolver` (push limit, push, destroy and ignore lists, slime and honey stickiness); `PistonMath`; the neighbour-signal check with quasi-connectivity; the block event ids and the two-phase trigger/event design; the retract, drop and cancel rules of sticky pistons; update ordering and suppression flags; the `SignalGetter` calls it makes (the signal model itself is in 30 part 1); entity pushing; shapes; sounds; NBT of the moving block entity; the push reaction model (`PushReaction`) and its values for every block |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited only to say where a fact was read; they are not a design. The block push-reaction column of section 5.4 was derived by a script-assisted reading of the `Blocks` static initializer (see Open question 1) |
| Round | RS12, part 3 of the redstone family (GAP-10c of `../design/README.md` Part 5) |
| Siblings | Part 1 = [30-redstone-1-model-signal-and-wire.md](30-redstone-1-model-signal-and-wire.md) (shared signal model, `SignalGetter`, wire, torches, power sources; the per-block `getSignal` and `getDirectSignal` rules and the census are in 30 part 1 §2.1 and §2.5; §2.2 there explains the direction argument), part 2 = [30-redstone-2-repeaters-comparators-observers.md](30-redstone-2-repeaters-comparators-observers.md) (observers that trigger pistons), part 4 = [30-redstone-4-dispensing-hoppers-crafters.md](30-redstone-4-dispensing-hoppers-crafters.md), part 5 = [30-redstone-5-switches-plates-sensors-notes.md](30-redstone-5-switches-plates-sensors-notes.md) (levers, buttons, plates), part 6 = [30-redstone-6-rails.md](30-redstone-6-rails.md), part 7 = [30-redstone-7-doors-lamps-bulbs-tnt.md](30-redstone-7-doors-lamps-bulbs-tnt.md), part 8 = [30-redstone-8-tripwire-sculk-bells-vibration.md](30-redstone-8-tripwire-sculk-bells-vibration.md). Where a signal rule belongs to another part it is named, not repeated |
| Data versus code | Block models and blockstate JSON of the piston blocks, textures, the two sounds' `sounds.json` entries (no `sounds.json` is present in this artifact, Open question 4), the loot tables (`piston`, `sticky_piston`; the head and the moving block have none) and the recipes are DATA in the resource and data packs and are not tabulated (blockstate and model files for the piston blocks were confirmed present in the jar under `assets/minecraft/`). Everything below is code-defined and is complete |
| Cross references | Form used in this document: a sibling is cited as "30 part N" and its section as "30 part N §x" (as 30 part 1 fixes it); other documents as NN §x. 29 (update flags, `setBlock`, neighbour updater, block events and their packet, destroy and drops), 24 (block registry rows, state-id layout), 31-8 (the `piston` block entity row), 05a (Block Event packet, Block Entity Data), 26 (loot), 33 (tick order) |

"Read" means read in the artifact this round. "(inferred)" marks a value deduced from what was read. "(recalled, not verified)" marks something not read; each is repeated in the Open questions.

Directions: the vanilla order of `Direction.values()` is DOWN, UP, NORTH, SOUTH, WEST, EAST (data values 0 to 5, read). NORTH is -z, SOUTH is +z, WEST is -x, EAST is +x, DOWN is -y, UP is +y. `opp(d)` is the opposite direction. `pos + d` is the neighbour in direction `d`. `from3D(n)` maps a data value `n` to a direction using index `|n mod 6|` (so 6 means DOWN and 7 means UP).

## 0. Reader's map

| Question | Section |
|---|---|
| What blocks and states exist, their properties and defaults | 1 |
| What starts a piston, and the exact power check including the cell above | 2 |
| The block event ids and what each does | 3 |
| Which blocks move, break or block; the 12-block limit; slime and honey | 4, 5 |
| What `moveBlocks` does, in order, including which flags and updates | 6 |
| The moving block, progress per tick, finishing, NBT, collision | 7 |
| Pushing entities | 8 |
| Head and base shapes, survival, breaking | 9 |
| Other code that reacts to `moving_piston` (falling blocks, collisions, shulker, tags) | 7.7 |
| Client behaviour and rendering numbers | 10 |
| Short pulses, 0-tick behaviour, update suppression summary | 11 |
| Worked examples | 12 |
| Validation | 13 |

## 1. Blocks and states

| Block (registry name) | Class | Properties, in state-definition order | Default state | Notes |
|---|---|---|---|---|
| `piston` | `PistonBaseBlock(sticky=false)` | `facing` (6 values), `extended` (bool) | `facing=north`, `extended=false` | |
| `sticky_piston` | `PistonBaseBlock(sticky=true)` | same | same | |
| `piston_head` | `PistonHeadBlock` | `facing` (6), `type` (`normal` or `sticky`), `short` (bool) | `facing=north`, `type=normal`, `short=false` | no loot table; `type` is the serialized name of `PistonType` (`DEFAULT` = `normal`, `STICKY` = `sticky`, read) |
| `moving_piston` | `MovingPistonBlock` | `facing` (6), `type` (`normal` or `sticky`) | `facing=north`, `type=normal` | no loot table; has a block entity (`piston`) made only by code, never by `newBlockEntity` (which returns null) |

Block-property rows (read from `Blocks` and `pistonProperties`):

- `piston` and `sticky_piston`: map colour STONE, strength 1.5 (hardness and resistance), push reaction IMMOVEABLE (but see 5.1: the push rules treat pistons specially), `isRedstoneConductor` always false, `isSuffocating` true only when `extended=false`. The extended state is treated as not suffocating. `useShapeForLightOcclusion` is true exactly when `extended=true`. Not pathfindable.
- `piston_head`: map colour STONE, strength 1.5, no loot table, push reaction IMMOVEABLE. `useShapeForLightOcclusion` always true. Not pathfindable.
- `moving_piston`: map colour STONE, force-solid-on, strength -1.0 (unbreakable), dynamic shape, no loot table, no occlusion, `isValidSpawn` is the shared never-spawn function (`Blocks.never`, so nothing can spawn on a moving piston), `isRedstoneConductor` and `isSuffocating` use the shared constant-false predicate (always false), push reaction IMMOVEABLE. Render shape INVISIBLE; clone item is the empty stack; not pathfindable. Its `getShape` is the empty shape; its collision shape comes from the block entity (7.5).
- Registered factories: `piston` is `PistonBaseBlock` with `sticky=false`, `sticky_piston` with `sticky=true` (read from the two registration lambdas).

Placement (`PistonBaseBlock.getStateForPlacement`): `facing` = opposite of the player's nearest looking direction (so the piston's face points at the player, as `BlockPlaceContext.getNearestLookingDirection` is the look direction, read); `extended=false`. Rotation rotates `facing`; mirror applies the mirror's rotation to `facing`. The same holds for the head and the moving block.

Ids, state numbering and delays (the per-block row required by 30 part 1 §4.2; values from 24 part 8, cross-checked with the id tables of 24 part 2):

| Block | Block id | State count | First state id (absolute) |
|---|---|---|---|
| `sticky_piston` | 138 | 12 | 2350 |
| `piston` | 149 | 12 | 2373 |
| `piston_head` | 150 | 24 | 2385 |
| `moving_piston` | 199 | 12 | 3801 |

State numbering in 24 sorts the properties by name, not in the order of the table above: for `piston` and `sticky_piston` the index is `extended*6 + facing` (listed there as `ex*6 + f`, properties `extended`, `facing`); for `piston_head` the index is `facing*4 + short*2 + type`; for `moving_piston` it is `facing*2 + type` (24 part 2 state-layout rows). The "state-definition order" used in this document's property table (`facing`, `type`, `short`) is the order the properties are declared, which differs from the numbering order, so an implementation must index head states with the 24 formula, not with declaration order. The numeric value orders inside each property (for example which of true or false is index 0) are given by the 24 rows and are not repeated here.

Delay and priority row (30 part 1 §4.4): the piston family schedules **no block ticks** (no scheduled tick, so no delay and no priority). Only the block-event queue is used (section 3 and 29 §6), and the extension timeline is 2 ticks of movement (`TICKS_TO_EXTEND = 2`, section 7.1) followed by the placement on the third tick (7.2). The sounds are in 3.2.

NBT/ids: the block-entity type is `piston` (id 11 in the 31-1 table; see 31-8 row 11), valid only on `moving_piston`.

## 2. Triggering a piston

### 2.1 When the check runs

`PistonBaseBlock.checkIfExtend(level, pos, state)` runs on the **server only** (nothing happens on a client level) in three places:

1. `setPlacedBy` (the item was placed by a living entity).
2. `neighborChanged` (any neighbour update; the source block, orientation and moved flag are ignored).
3. `onPlace`, only if the old state at the position is not the same block (a mere state change does not re-run it), and only if there is **no block entity** at the position at that moment. The finishing moving block removes its own entity before it places the base, so a base that comes back from a retraction does run this check.

Also: `PistonHeadBlock.neighborChanged` forwards to the base. If the head state `canSurvive` (9.3), it sends `Level.neighborChanged(pos + opp(facing), headBlock, orientation)` to the cell behind the head, so any update next to the head makes the base re-check its power.

### 2.2 `getNeighborSignal(level, pos, facing)` (the power test)

Returns true if any of these holds, tested in this order (`SignalGetter.hasSignal(p, d)` is `getSignal(p, d) > 0`):

1. For each direction `d` in DOWN, UP, NORTH, SOUTH, WEST, EAST **except `facing`**: `hasSignal(pos + d, d)`.
2. `hasSignal(pos, DOWN)`. The queried cell is the piston itself; `SignalGetter.getSignal` reads the piston state's own signal (a piston emits none) and a conductor boost only for redstone conductors (a piston is not one, section 1), so this term is always false for a piston (inferred from those two facts).
3. Quasi-connectivity: let `above = pos + UP`. For each direction `d` in DOWN, UP, NORTH, SOUTH, WEST, EAST **except DOWN**: `hasSignal(above + d, d)`. These are the neighbours of the cell above the piston: the cell two above, and the four horizontal neighbours of the cell above, but not the piston itself. The piston therefore reacts to power that would reach it only if it were one cell higher, whatever block is in `above`, even air. The facing direction is **not** excluded here (a neighbour of the cell above may lie in front of the piston's column and still count).

`SignalGetter.getSignal(p, d)` (30 part 1 §2.3): let `s` be the state at `p`; `v = s.getSignal(level, p, d)`; if `s` is a redstone conductor, return `max(v, getDirectSignalTo(p))` (the strongest direct signal from the six cells around `p`, with early exit at 15), otherwise `v`. The per-block `getSignal` and `getDirectSignal` rules belong to 30 part 1 §2.1 and §2.5. So the piston is powered by:

- a signal source adjacent to it (any side but the front) that reports a positive `getSignal` toward the piston, and
- a conductor block adjacent (any side but the front) that is strongly powered, and
- the same two situations for the cell above (any side except below it).

Note the facing side is excluded from term 1 only, so a power source directly in front of the piston (where the head would go) does not power it, but a source in front of the cell above does.

### 2.3 Decision (`checkIfExtend`)

Let `powered = getNeighborSignal(...)`, `facing = state.facing`.

| Case | Action |
|---|---|
| `powered` and `extended=false` | Create a `PistonStructureResolver(level, pos, facing, extending=true)` and run `resolve()`. If it succeeds, queue the block event `(pos, this block, type 0, data = facing.get3DDataValue())`. If it fails, nothing happens (the piston stays retracted and no sound plays) |
| not `powered` and `extended=true` | Compute `type`: start with 1 (retract). Look at the cell `two = pos + 2*facing`. If its state is `moving_piston` with `facing` equal to the piston's facing, and its block entity is a `PistonMovingBlockEntity` that is **extending**, then `type` becomes **2** (drop) when **any** of: its progress read at partial tick 0 (that is `progressO`) is below 0.5; or the current game time equals that entity's `lastTicked`; or the server level is currently inside its tick (`isHandlingTick()` true). `type` stays 1 only when progress is at least 0.5 **and** the game time differs from `lastTicked` **and** the level is not handling a tick. Queue the block event `(pos, this block, type, data)` |
| otherwise (powered and extended, or unpowered and retracted) | nothing |

Block-event data value: the facing's data value (DOWN 0, UP 1, NORTH 2, SOUTH 3, WEST 4, EAST 5). Event ids are listed in 3.1. Events go through the queue of 29 §6 (duplicate-suppressing set, run once per level tick after the chunk-source tick, broadcast to players within 64 blocks when `triggerEvent` returns true).

## 3. The block event

### 3.1 Constants

| Id | Name | Use |
|---|---|---|
| 0 | `TRIGGER_EXTEND` | extend |
| 1 | `TRIGGER_CONTRACT` | retract; a sticky piston also pulls the block it can |
| 2 | `TRIGGER_DROP` | retract without pulling anything (the sticky piston "drops" the block) |
| (data) | `get3DDataValue` of the facing | low three bits are read as the facing (`data & 7`, via `from3D`) |

`PLATFORM_THICKNESS` is 4 (sixteenths). The same event runs on every client within range: the server sends the Block Event packet (05a) carrying `(pos, block id, type, data)` when `triggerEvent` returned true; the client calls the same method on its client level (10.1).

### 3.2 `triggerEvent(state, level, pos, type, data)` in full

Let `facing = state.facing` (read from the state, not from `data`) and `extendedState = state with extended=true`.

**Server-side gate** (skipped on a client level): recompute `powered = getNeighborSignal(level, pos, facing)` now, at event time.

- If `powered` and `type` is 1 or 2: the retraction is cancelled. `setBlock(pos, extendedState, 2)` (clients only, flag 2) and return **false** (no packet, no sound).
- If not `powered` and `type` is 0: the extension is cancelled. Return **false**.
- Otherwise continue. (Powered with type 0, or unpowered with type 1 or 2, continues.)

Then the random source used for the sound pitch is `level.getRandom()` (one `nextFloat`).

**Type 0 (extend).**
1. Run `moveBlocks(level, pos, facing, extending=true)` (section 6). If it returns false, return **false** (nothing was changed, no packet).
2. `setBlock(pos, extendedState, 67)` (flags 1 + 2 + 64: neighbours, clients, moved-by-piston).
3. Play sound `block.piston.extend` (`SoundEvents.PISTON_EXTEND`), source BLOCKS, volume 0.5, pitch `nextFloat() * 0.25 + 0.6`, at the piston position, no excluded player.
4. Game event `BLOCK_ACTIVATE` at `pos` with context = `extendedState`.
5. Return true.

**Types 1 and 2 (contract).**
1. Let `be = blockEntity(pos + facing)`. If it is a `PistonMovingBlockEntity` (the half-built head of an extension in progress), call its `finalTick()` now (7.4: it completes at once; for the head, which is a source entity, the result is **air**).
2. Let `movingState = moving_piston with facing = facing and type = (sticky ? sticky : normal)`. `setBlock(pos, movingState, 276)` (flags 4 + 16 + 256: invisible, known shape, skip block-entity side effects). Then set at `pos` a new moving block entity with `movedState = this piston block's default state with facing = from3D(data & 7)` (so retracted, `extended=false`), `direction = facing`, `extending = false`, `isSourcePiston = true`.
3. `level.updateNeighborsAt(pos, movingState.block)`, then `movingState.updateNeighbourShapes(level, pos, 2)`.
4. If the piston is **sticky**:
   1. `two = pos + 2*facing`; `s2 = state at two`; `foundMoving = false`.
   2. If `s2` is `moving_piston` and its entity is a `PistonMovingBlockEntity` with `direction == facing` and `extending == true`: call `finalTick()` on it (the block being pushed out completes at once) and set `foundMoving = true`.
   3. If `foundMoving` is false:
      - if `type == 1` and `s2` is not air and `isPushable(s2, level, two, opp(facing), allowDestroy=false, facing)` is true and (`s2`'s push reaction is `PUSH_PULL` **or** `s2` is a `piston` or `sticky_piston`): run `moveBlocks(level, pos, facing, extending=false)` (it pulls the block; the result is ignored);
      - otherwise: `level.removeBlock(pos + facing, false)` (remove the head; the cell at `two` keeps whatever it holds).
   4. If `foundMoving` is true: nothing more (the head was already removed in step 1 above).
5. If the piston is **not** sticky: `level.removeBlock(pos + facing, false)` (the head).
6. Play `block.piston.contract` (`SoundEvents.PISTON_CONTRACT`), BLOCKS, volume 0.5, pitch `nextFloat() * 0.15 + 0.6`; game event `BLOCK_DEACTIVATE` at `pos` with context = `movingState`.
7. Return true.

Any other `type` value falls through to return true without doing anything. `level.removeBlock(pos, movedByPiston=false)` writes the position's fluid state as a block with flags 3 (1 + 2).

When a sticky piston pulls (type 1 and the block qualifies), the pulled block is moved through the resolver in **retract** mode (4.1). A type 2 event, the cancelled-extension case and non-qualifying blocks (no `PUSH_PULL`, a block entity, immovable) leave the block at `two` where it was.

## 4. `PistonStructureResolver`

Constant `MAX_PUSH_DEPTH` = 12 (the push limit).

### 4.1 Construction

Inputs: `level`, `pistonPos`, `pistonDirection` (the piston's facing), `extending`.

| | extending | retracting |
|---|---|---|
| `pushDirection` (the direction blocks move) | `pistonDirection` | `opp(pistonDirection)` |
| `startPos` (first cell examined) | `pistonPos + pistonDirection` | `pistonPos + 2*pistonDirection` |

Outputs: `toPush` (ordered list of positions), `toDestroy` (list), `pushDirection`.

### 4.2 `resolve()`

1. Clear both lists. `s = state at startPos`.
2. If `isPushable(s, level, startPos, pushDirection, allowDestroy=false, pistonDirection)` is false: if `extending` and `s`'s push reaction is `POPPED`, add `startPos` to `toDestroy` and return **true**; otherwise return **false**.
3. `addBlockLine(startPos, pushDirection)`; if it returns false, return false.
4. For each index `i` from 0 while `i < toPush.size()` (the size is re-read, list grows during the loop): if the state at `toPush[i]` is sticky (slime block or honey block, 4.5), `addBranchingBlocks(toPush[i])`; if that returns false, return false.
5. Return true.

A retraction with air at `startPos` resolves to an empty result and returns true (air is pushable).

### 4.3 `addBlockLine(pos, dir)` (returns false only when the structure is blocked)

`dir` is the direction in which this line was entered. For the first call it equals `pushDirection`; for branches it is the side direction.

1. `s = state at pos`. If `s` is air, return true.
2. If `isPushable(s, level, pos, pushDirection, false, dir)` is false, return **true** (an immovable cell next to a branch is ignored, not a failure).
3. If `pos == pistonPos`, return true. If `toPush` already contains `pos`, return true.
4. `lineLen = 1`. If `lineLen + toPush.size() > 12`, return **false**.
5. **Backward chain** (only when `s` is sticky): walk from `pos` toward the piston, one cell at a time, in the direction `opp(pushDirection)`. A cell joins the chain only if it is not air, the previous cell and it `canStickToEachOther`, it passes `isPushable(..., pushDirection, false, opp(pushDirection))` and it is not the piston cell. The walk ends silently at the first cell that fails one of these. Each cell that joins increases `lineLen`; if `lineLen + toPush.size()` exceeds 12 at any point the whole call returns **false**.
6. **Append order.** The chain is appended to `toPush` farthest-from-the-piston-end first, that is from the cell `lineLen - 1` steps behind `pos` forward to `pos` itself (so `pos` is the last of the chain). `count` is the number of cells appended by this call.
7. **Forward scan.** Starting at the cell just beyond `pos` in `pushDirection` and moving one cell at a time, examine each cell `p`:
   1. If `p` is already in `toPush` at index `idx` (two branches meeting): reorder per 4.4 with `count` and `idx`; then every entry of `toPush` from index 0 through `idx + count` inclusive that is sticky has `addBranchingBlocks` run on it, in list order, and any false result returns false; otherwise return true.
   2. If `p` is air: return true.
   3. If `p` fails `isPushable(..., pushDirection, true, pushDirection)` or is the piston cell: return **false** (a solid obstacle blocks the whole push).
   4. If `p`'s push reaction is `POPPED`: add `p` to `toDestroy` and return true (the line ends at a block that will break).
   5. If `toPush` already holds 12 entries: return **false**. Otherwise append `p`, add 1 to `count`, and continue to the next cell.

Note `isPushable` is called with `allowDestroy = true` in the forward scan (so `POPPED` blocks pass and are then routed to `toDestroy`) and with `false` for the start cell and the back chain (a `POPPED` block that is directly behind a sticky chain, or a `POPPED` start cell of a retraction, is not pushed).

### 4.4 `reorderListAtCollision(count, idx)`

Let `A = toPush[0 .. idx)`, `B` = the last `count` entries (the ones appended by the current call), `C = toPush[idx .. size - count)`. The new `toPush` is `A, B, C`. Effect: the newly found line is moved in front of the part it collided with. Example: list `[A1, A2, A3, N1, N2]` with `count = 2` (`N1`, `N2` new) and a collision at `idx = 1` becomes `[A1, N1, N2, A2, A3]`.

### 4.5 `addBranchingBlocks(pos)` and stickiness

`addBranchingBlocks(pos)`: `s = state at pos`. For each direction `d` in DOWN, UP, NORTH, SOUTH, WEST, EAST whose **axis differs from the axis of `pushDirection`** (the two directions on the push axis are skipped): `np = pos + d`; `ns = state at np`; if `canStickToEachOther(ns, s)` is false, skip; otherwise `addBlockLine(np, d)`, and if it returns false the whole call returns false. Return true.

Sticky blocks: `isSticky(s)` is true for `slime_block` and `honey_block` only.

`canStickToEachOther(a, b)`:
1. false if `a` is honey and `b` is slime;
2. false if `a` is slime and `b` is honey;
3. otherwise true if `isSticky(a)` or `isSticky(b)`, else false.

Consequences: a slime or honey block drags **every** adjacent block on the sides (including ordinary stone) but not slime to honey or honey to slime; a non-sticky block does not drag anything by itself; the two sticky blocks on either side of a normal block do not link through it.

## 5. What can be pushed

### 5.1 `PistonBaseBlock.isPushable(state, level, pos, direction, allowDestroy, pistonFacing)`

Evaluated in this order; the first rule that applies decides:

1. If `pos.y < level.minY` or `pos.y > level.maxY` or the position is not within the world border: **false**.
2. Air: **true**.
3. `direction == DOWN` and `pos.y == minY`: **false**. `direction == UP` and `pos.y == maxY`: **false**.
4. The block is `piston` or `sticky_piston`: if `extended=true` return **false**; otherwise skip rules 5 and 6 and go to rule 7.
5. If the state's destroy speed at the position is exactly -1.0 (unbreakable): **false**.
6. By push reaction:

| `PushReaction` | Result |
|---|---|
| `IMMOVEABLE` | false |
| `POPPED` | `allowDestroy` |
| `PUSH` | `direction == pistonFacing` (can be pushed in the piston's own direction only; never pulled and never dragged sideways) |
| `PUSH_PULL`, `IGNORE_ENTITY` | continue to rule 7 |

7. Result: the state has **no block entity** (`!hasBlockEntity`).

So an unextended piston can be pushed (it is `IMMOVEABLE` in its properties but rule 4 comes first), chests, furnaces, hoppers, spawners and every other block with a block entity cannot, bedrock and other blocks of destroy speed -1 cannot, and extended pistons cannot.

### 5.2 Meaning of the push reactions

| Value | Effect on pistons | Effect on entities (via `Entity.getPistonPushReaction`) |
|---|---|---|
| `PUSH_PULL` (default for blocks and entities) | can be pushed and pulled (sticky/slime); the default | entity is pushed |
| `PUSH` | pushed only along the piston's facing direction | not used for entities |
| `POPPED` | breaks (drops as an item, section 6 step 5) when a push reaches it, but never moves | not used |
| `IMMOVEABLE` | blocks | not used |
| `IGNORE_ENTITY` | treated like `PUSH_PULL` by `isPushable` | the entity is skipped by the piston entirely (8.1) |

Entities that return `IGNORE_ENTITY`: `AreaEffectCloud`, `Interaction`, `OminousItemSpawner`, `Marker`, the `Display` entities, and an `ArmorStand` that is a marker (read from each class's override; every other entity class returns the default `PUSH_PULL`).

### 5.3 What breaks and what stops

- A block with reaction `POPPED` is destroyed when it is reached by the forward scan, or when it is the start cell of an **extension** (4.2 step 2). It is never destroyed by a retraction (the start cell test uses `allowDestroy=false`).
- Anything for which rule 1, 3 or 5 or 6 returns false in the forward scan, including an extended piston, blocks the whole movement: the piston does not extend.
- Rule 2 of `addBlockLine` means that unmovable blocks beside a slime branch do not block; they stay put.

### 5.4 Push reaction per block (code-defined; per-row copies live in 24)

Read by walking the `Blocks` static initializer: default is `PUSH_PULL`; `pushReaction(...)` overrides, and the `ofFullCopy`/`ofLegacyCopy` property builders copy the reaction of the block they copy from.

- **`IMMOVEABLE` (17):** `piston`, `sticky_piston`, `piston_head`, `moving_piston`, `obsidian`, `nether_portal`, `end_portal`, `anvil`, `chipped_anvil`, `damaged_anvil`, `barrier`, `end_gateway`, `grindstone`, `crying_obsidian`, `respawn_anchor`, `lodestone`, `reinforced_deepslate`.
- **`PUSH` (16):** the sixteen `*_glazed_terracotta` blocks (one dye-colour lambda; the collection `GLAZED_TERRACOTTA`).
- **`PUSH_PULL` set explicitly:** `heavy_core` (it also appears in the `pushReaction` calls with the default value).
- **`POPPED`:** the block fields named below (no total is claimed: a count of 279 in an earlier draft could not be reproduced; an independent parse of the `Blocks` initializer found 206 fields with an explicit `POPPED` call, the rest coming through helpers and lambdas), plus the dye collections whose property lambdas or helpers set it: `BED` (all 16 beds), `DYED_SHULKER_BOX`, `DYED_CANDLE` and `DYED_CANDLE_CAKE` (through the candle helper), `COPPER_LANTERN` family, `COPPER_DOOR` family, `COPPER_GOLEM_STATUE` family. Blocks (registry names, lower-case): saplings (`oak`, `spruce`, `birch`, `jungle`, `acacia`, `cherry`, `dark_oak`, `pale_oak`, `poplar`), `mangrove_propagule`, `water`, `lava`, `suspicious_sand`, `suspicious_gravel`, all leaves (`oak`, `spruce`, `birch`, `jungle`, `acacia`, `cherry`, `dark_oak`, `pale_oak`, `mangrove`, `red_poplar`, `orange_poplar`, `yellow_poplar`, `azalea`, `flowering_azalea`), `straw_bed`, `cobweb`, `short_grass`, `fern`, `dead_bush`, `bush`, `red_shrub`, `short_dry_grass`, `tall_dry_grass`, `seagrass`, `tall_seagrass`, small flowers (`dandelion`, `golden_dandelion`, `torchflower`, `poppy`, `blue_orchid`, `allium`, `azure_bluet`, four tulips, `oxeye_daisy`, `cornflower`, `wither_rose`, `lily_of_the_valley`), `brown_mushroom`, `red_mushroom`, all torches (`torch`, `wall_torch`, `soul_torch`, `soul_wall_torch`, `copper_torch`, `copper_wall_torch`, `redstone_torch`, `redstone_wall_torch`), `fire`, `soul_fire`, `redstone_wire`, `wheat`, `carrots`, `potatoes`, `beetroots`, `torchflower_crop`, `pitcher_crop`, `pitcher_plant`, wooden doors of every wood (`oak`, `spruce`, `birch`, `jungle`, `acacia`, `cherry`, `dark_oak`, `pale_oak`, `mangrove`, `poplar`, `bamboo`, `crimson`, `warped`) and `iron_door`, `ladder`, `lever`, every button (wooden ones, `stone_button`, `polished_blackstone_button`, `crimson_button`, `warped_button`), every pressure plate (all woods, `stone_pressure_plate`, `polished_blackstone_pressure_plate`, `light_weighted_pressure_plate`, `heavy_weighted_pressure_plate`, `crimson_pressure_plate`, `warped_pressure_plate`), `snow` (the layer), `cactus`, `cactus_flower`, `sugar_cane`, `carved_pumpkin`, `jack_o_lantern`, `cake`, `repeater`, `comparator`, `pumpkin`, `melon`, the four stems, `vine`, `glow_lichen`, `resin_clump`, `lily_pad`, `nether_wart`, `dragon_egg`, `cocoa`, `shelf_mushroom`, `tripwire_hook`, `tripwire`, `flower_pot` and every `potted_*` block, all skulls and heads (floor and wall), `sunflower`, `lilac`, `rose_bush`, `peony`, `tall_grass`, `large_fern`, `chorus_plant`, `chorus_flower`, `structure_void`, `shulker_box` (undyed), `kelp`, `kelp_plant`, `turtle_egg`, the five living corals, coral fans and wall fans (dead ones are not listed: they are `PUSH_PULL`), `sea_pickle`, `bamboo_sapling`, `bamboo`, `bubble_column`, `scaffolding`, `bell`, `lantern`, `soul_lantern`, `sweet_berry_bush`, `warped_fungus`, `crimson_fungus`, `warped_roots`, `crimson_roots`, `nether_sprouts`, `weeping_vines`, `weeping_vines_plant`, `twisting_vines`, `twisting_vines_plant`, `candle`, `candle_cake`, `budding_amethyst`, `amethyst_cluster` and the three buds, `sculk_vein`, `pointed_dripstone`, `sulfur_spike`, `cave_vines`, `cave_vines_plant`, `spore_blossom`, `azalea`, `flowering_azalea`, `moss_carpet`, `pink_petals`, `wildflowers`, `leaf_litter`, `moss_block`, `big_dripleaf`, `big_dripleaf_stem`, `small_dripleaf`, `hanging_roots`, `frogspawn`, `decorated_pot`, `pale_moss_block`, `pale_moss_carpet`, `pale_hanging_moss`, `open_eyeblossom`, `closed_eyeblossom`, `firefly_bush`.
- **All other blocks:** `PUSH_PULL`. So slime and honey blocks, `tnt`, bookshelves, stairs, slabs, walls, fences, gates, trapdoors, glass, carpets (the `CARPET` collection has no override), rails, `redstone_block`, `redstone_lamp`, `observer`, `target` and the dead corals are pushed and pulled normally. `dispenser`, `dropper`, `hopper`, chests, furnaces and every other block with a block entity are `PUSH_PULL` by reaction but still cannot move, because rule 7 of 5.1 rejects block entities.

Entities: see 5.2.

## 6. `moveBlocks(level, pos, facing, extending)` in order

`headPos = pos + facing`. The block returns true if it changed the world, false when the resolver fails.

1. If **not extending** and the block at `headPos` is `piston_head`: `setBlock(headPos, air, 276)`.
2. Build `PistonStructureResolver(level, pos, facing, extending)`; `resolve()`; if false return **false**.
3. Snapshot the states of all `toPush` cells before any write (list `states` in `toPush` order, plus a set `oldAt` of those positions, used later to find vacated cells).
4. `moveDir` is `facing` when extending, else `opp(facing)`. A list `saved` collects the removed states in this order: the destroyed ones first, then the pushed ones (each group in the order it is processed below).
5. **Destroy.** Process `toDestroy` from its last entry to its first. Each block drops its standard loot (26, 29 §10.5), is written as air with flags 18, raises game event `BLOCK_DESTROY`, and its state is added to `saved`. On a **client** level only, a block-break level event (2001, state id) is played unless the block is tagged `fire`; the server never sends it from here.
6. **Push.** Process `toPush` from its last entry to its first (the block farthest from the piston moves first). Each block's destination cell (`p + moveDir`) is removed from `oldAt` and receives a `moving_piston` (`facing = facing`, `type` default `normal`) written with flags 324, plus a moving block entity (`movedState` = the snapshot of step 3, `direction = facing`, `extending = extending`, `isSourcePiston = false`). The pre-move state is added to `saved`.
7. **Head** (extending only). `headPos` is removed from `oldAt` and receives a `moving_piston` (`facing`, `type` = sticky or normal as the piston) written with flags 324, plus a moving block entity whose `movedState` is `piston_head` (`facing`, same `type`, `short=false`), `direction = facing`, `extending = true`, `isSourcePiston = true`.
8. **Vacated cells.** Every position still in `oldAt` (a pushed cell nobody moved into) is written as air with flags 82. The iteration order is the order of a `java.util.HashMap` keyed by position (`oldAt` is created with `Maps.newHashMap`); the key hash is read (6.1 below) and the bucket order is partly not read (Open question 3).
9. **Shape updates around vacated cells**, in the same map order: for each such cell the old state's indirect neighbour shape updates, then the air state's neighbour shape updates and indirect neighbour shape updates, all with budget argument 2.
10. `orientation` = `ExperimentalRedstoneUtils.initialOrientation(level, resolver.pushDirection, none)` (only meaningful with the redstone-experiments feature flag, 29 §3; otherwise null).
11. **Notification order.** All notifications come after every write, walking `saved` from its first entry. First the destroyed cells, last-destroyed index first (matching the order of `saved`): on a server level `affectNeighborsAfterRemoval(level, pos, false)`, then indirect neighbour shape updates (budget 2), then `updateNeighborsAt(pos, removedBlock, orientation)`. Then the pushed cells, again last index first: `updateNeighborsAt(oldPos, oldBlock, orientation)` (old position, old block).
12. If extending: `updateNeighborsAt(headPos, piston_head, orientation)` last.
13. Return true.

So the resulting orders are: destroy and push writes run far end first; shape updates for vacated cells follow the map order; neighbour notifications run destroyed cells first, then pushed cells far end first, then the head.

Flag consequences (29 §1 and §2): none of these writes carries flag 1, so **no neighbour notification** happens at write time; every notification is the explicit step 11 and 12 batch after the blocks are all in place. Flags 16 skip shape updates at write time (done by steps 9 and 11 instead). Flag 4 hides redraws on a client level. Flag 256 stops the old block entity's `preRemoveSideEffects` from finishing a moving block at once when the position is overwritten; flag 64 tells `onPlace` and removal callbacks `movedByPiston = true`.

The head's moving block is written **after** the pushed blocks, and the pushed blocks are written front to back, so a block never moves into a cell that has not already been emptied logically (the `oldAt` removal in step 6 protects destination cells from step 8).

### 6.1 The position hash used by the vacated-cell map

`BlockPos` does not override `hashCode`; the one used is `Vec3i.hashCode`: `(y + z * 31) * 31 + x`, in 32-bit signed integer arithmetic with wraparound (read). Example: position (1, 0, 0) hashes to 1; (0, 0, 1) hashes to `(0 + 1*31)*31 + 0 = 961`; (0, 1, 0) hashes to `(1 + 0)*31 + 0 = 31`. How `java.util.HashMap` spreads that hash into buckets (an XOR of the high 16 bits into the low 16 bits), its initial table size (16), its growth, and the iteration order that follows (bucket index ascending, insertion order inside a bucket) are JDK behaviour, **not read from this artifact** (recalled, not verified). An implementation that needs the exact vacated-cell order must reproduce the JDK map; otherwise treat the order as undefined.

## 7. The moving block and its block entity

### 7.1 Fields and constants

`PistonMovingBlockEntity(pos, state, movedState, direction, extending, isSourcePiston)`; state of the entity:

| Field | Meaning |
|---|---|
| `movedState` | the block state being carried (a pushed block, the head, or the retracting base) |
| `direction` | the **piston's facing**; the same for every entity created by one move |
| `extending` | true when the move is an extension |
| `isSourcePiston` | true for the entity that represents the piston itself (the head while extending, the base while retracting) |
| `progress`, `progressO` | floats in [0, 1]; `progressO` is the value at the start of the current tick |
| `lastTicked` | game time of the last `tick` (long) |
| `deathTicks` | client only, counts up to 5 |

Constants: `TICKS_TO_EXTEND = 2`, `PUSH_OFFSET = 0.01`, `TICK_MOVEMENT = 0.51`, default progress 0.0, default `movedState` air.

Movement direction: `extending ? direction : opp(direction)` (also used as `getPushDirection`).

Offsets: `extendedProgress(p) = extending ? p - 1 : 1 - p`; the entity's offset vector from its cell is `step(direction) * extendedProgress(progress)`. At `progress = 0` an extending block sits one cell **behind** its cell (at its old position) and a retracting block sits one cell ahead (`direction` side); at `progress = 1` both sit exactly in the cell.

`getProgress(partial) = lerp(min(partial, 1), progressO, progress)`.

### 7.2 `tick` (every game tick, server and client)

1. `lastTicked = level game time`; `progressO = progress`.
2. If `progressO >= 1`:
   - client level: if `deathTicks < 5`, add 1 and stop (the entity lingers for five more ticks); otherwise continue below;
   - remove the block entity from the level and mark it removed;
   - if the block at `pos` is still `moving_piston`:
     1. `newState = Block.updateFromNeighbourShapes(movedState, level, pos)` (apply `updateShape` of `movedState` for each neighbour in order WEST, EAST, NORTH, SOUTH, DOWN, UP, using the actual neighbour states; the order is the `UPDATE_SHAPE_ORDER` array of `BlockBehaviour`, read);
     2. if `newState` is air: `setBlock(pos, movedState, 340)` (flags 4 + 16 + 64 + 256) then `Block.updateOrDestroy(movedState, newState, level, pos, 3)` (the 5-argument overload, which calls the 6-argument form with a maximum update depth of 512; it destroys the block with drops, because the shape update says it cannot exist: when the new state is air and the level is a server level, `destroyBlock(pos, drops = flag 32 clear)`; when the state differs and is not air, `setBlock(pos, newState, flags & ~32)`);
     3. else: if `newState` has `waterlogged = true`, set it to false (a moved block never keeps water); `setBlock(pos, newState, 67)`; `level.neighborChanged(pos, newState.block, orientation)` where the orientation is `initialOrientation(level, pushDirection, none)`.
   - stop.
3. Otherwise (still moving): `np = progress + 0.5`; `moveCollidedEntities(level, pos, np, this)`; `moveStuckEntities(level, pos, np, this)`; `progress = np`; if `progress >= 1`, `progress = 1`.

So progress goes 0, 0.5, 1.0 in two ticks and the entity places the block on the **third** tick it runs (`progressO` is 1 at the start of that tick). Timeline (read): `ServerLevel.tick` runs block ticks, fluid ticks, raids, the chunk source tick, `runBlockEvents`, then clears its handling-tick flag, then the entity tick list, then `tickBlockEntities` (33 §2). A moving block entity set in the event phase goes through `LevelChunk.setBlockEntity`, which updates the chunk's ticker and adds it to the level's **pending** ticker list; `Level.tickBlockEntities` first moves the pending list into the active list and then iterates, so the entity ticks in the same game tick. Extend event at tick `t` gives progress 0.5 at `t`, 1.0 at `t+1`, and the block placed at `t+2`.

`MovingPistonBlock.getTicker` returns the tick function only when the requested block entity type is `piston` (read); any other type gets no ticker. The client-sync path uses the same compound as the save (7.6); nothing else is added to it.

### 7.3 Placement of the finished state

The placed state is the moved state after neighbour shape updates (step 2.1). For the extending head the moved state is `piston_head` (`short=false`); for the retracting base it is the base piston with `extended=false`, which then runs its own `onPlace` check (2.1 item 3). For an ordinary pushed block it is the block as it was, which then receives `onPlace` with `movedByPiston = true` (flag 64) and one `neighborChanged`.

### 7.4 `finalTick()` (forced completion)

Used from `triggerEvent` (3.2) and from `preRemoveSideEffects`, which calls it whenever the moving block's cell is overwritten without flag 256:

The whole body is **one nested condition**: it runs only when the entity has a level **and** (`progressO < 1` **or** the level is a client level). If `progressO >= 1` on a server level (or there is no level), nothing at all happens: no removal, no write and no `neighborChanged`. Inside that condition, in order:

1. Set `progress = progressO = 1`; remove the entity from the level; mark it removed.
2. If the block at `pos` is still `moving_piston`: the new state is **air** when `isSourcePiston`, else `updateFromNeighbourShapes(movedState)`; then `setBlockAndUpdate(pos, newState)` (flags 3), then `level.neighborChanged(pos, newState.block, orientation)`. If the block at `pos` is no longer `moving_piston`, steps 2 and onward are skipped (the removal of step 1 has still happened).

So a forced finish of a half-built head removes it (air), and a forced finish of a pushed block places it.

### 7.5 Collision shape (`getCollisionShape(level, pos)`)

Used by `MovingPistonBlock.getCollisionShape` (the context argument is ignored):

1. `base`: if the entity is **not extending**, is a **source**, and `movedState` is a piston base: the collision shape of `movedState` with `extended=true` (the retracting piston's base slab, 9.1). Otherwise the empty shape.
2. Read the thread-local `NOCLIP` direction (set while the piston is moving an entity, 8.3). If `progress < 1.0` and `NOCLIP` equals the entity's movement direction, return `base` only (entities being pushed along the push direction do not collide with the moving block).
3. Pick the state to measure: if `isSourcePiston`, a `piston_head` with `facing = direction` and `short = (extending != ((1 - progress) < 0.25))`; otherwise `movedState`. (Extending: short while `progress <= 0.75`; retracting: short once `progress > 0.75`. Read: `short` equals the comparison `extending` is not equal to `1 - progress < 0.25`.) The head's `type` stays at its default `normal` in this computation (only the shape is used and it is the same for both types).
4. Shift that state's collision shape by `step(direction) * extendedProgress(progress)` along each axis (floats), and return `base ∪ shifted shape`.

For entity pushing a second state is used, `getCollisionRelatedBlockState`: when not extending, a source, and `movedState` is a piston base, a `piston_head` with `short = (progress > 0.25)`, `type = (movedState is sticky_piston ? sticky : normal)` and `facing = movedState.facing`; otherwise `movedState`.

### 7.6 NBT (block entity `piston`, saved with `saveCustomOnly`; the update tag is the same compound)

| Key | Type | Content | Default when absent |
|---|---|---|---|
| `blockState` | compound | the block state codec (`Name` and `Properties` as in 07) of `movedState` | air |
| `facing` | byte | `direction` as its 3D data value (`DOWN` 0 … `EAST` 5); the codec (`Direction.LEGACY_ID_CODEC`) is the byte codec mapped through `get3DDataValue` on save and `from3DDataValue` on load (read); `from3DDataValue(n)` indexes the six directions with `abs(n mod 6)`, so out-of-range values wrap as stated in the header | DOWN |
| `progress` | float | on save the value of **`progressO`**; on load `progress` and `progressO` are both set to it | 0.0 |
| `extending` | byte (boolean) | | false |
| `source` | byte (boolean) | `isSourcePiston` | false |

`setLevel`: if the registry no longer holds the moved block, `movedState` becomes air.

### 7.7 Other code that depends on `moving_piston` (read)

- **Falling blocks.** When a `FallingBlockEntity` lands on a cell whose state is `moving_piston`, it multiplies its delta movement by (0.7, -0.5, 0.7) and then does **not** place its block or drop an item (the placement and drop branch is skipped for that cell); the entity continues.
- **Block collisions.** `BlockCollisions` (the iterator behind `Level.noCollision` and collision queries) has an integer mode with three values seen: 0 considers every cell, 1 skips states without a large collision shape, and 2 considers **only `moving_piston` states**. In every mode a cell whose collision shape is the shared full-cube shape counts when the query box intersects the unit cell, and any other non-empty shape counts when it intersects the entity shape (AND of the two). Which callers use mode 2 was not traced (Open question 7).
- **Shulker.** The shulker's position test (`isPositionBlocked`, used by `canStayAt`) treats a non-air cell as blocked unless the cell is `moving_piston` **and** is the shulker's own block position; air is never blocked.
- **Block tags** (data files under `data/minecraft/tags/block/`, read): `moving_piston` is in `dragon_immune`, `wither_immune` and `maintains_farmland`; `piston`, `sticky_piston` and `piston_head` are in `mineable/pickaxe`; all four blocks (`piston`, `sticky_piston`, `piston_head`, `moving_piston`) are in `blocks_motion_no_leaves`. No other block tag file contains a piston block.
- **Not read:** `SculkVeinBlock$SculkVeinSpreaderConfig` and `JungleTemplePiece` reference piston blocks; they were not opened (Open question 8).

## 8. Entities

### 8.1 `moveCollidedEntities(level, pos, newProgress, be)` (called before `progress` is updated)

Inputs: `dir` = the entity's movement direction; `delta = newProgress - progress` (0.5 for a normal tick, double precision of the float difference).

1. `shape` = collision shape of `getCollisionRelatedBlockState()` at `pos`; if empty, stop.
2. `bounds = shape.bounds()` shifted to the world cell and by the entity's current offset (`pos` plus `step(direction) * extendedProgress(progress)`), using the **current** progress.
3. Entities to consider: the result of `Level.getEntities(null, box)` (no entity excluded explicitly). That overload (`EntityGetter.getEntities(Entity, AABB)`) adds the `EntitySelector.NO_SPECTATORS` predicate, so **spectator entities are excluded**; every other entity intersecting `PistonMath.getMovementArea(bounds, dir, delta)` united (min and max) with `bounds` is considered. (`moveStuckEntities`, 8.2, uses the predicate form of `getEntities` with only its own sticky test, so it has no spectator filter of its own.)
4. `aabbs = shape.toAabbs()`; `isSlime = movedState is slime_block`.
5. For each entity:
   1. Skip it if `getPistonPushReaction()` is `IGNORE_ENTITY`.
   2. If `isSlime` and the entity `canSimulateMovement()`: set its delta movement so that the component along the axis of `dir` equals `step(dir)` exactly (1.0 or -1.0), the other two components unchanged.
   3. `maxPush = 0`. For each `aabb` of `aabbs`: `area = getMovementArea(aabb moved by the current offset, dir, delta)`; if `area` does not intersect the entity's bounding box, continue; `maxPush = max(maxPush, getMovement(area, dir, entityBox))`; if `maxPush >= delta`, stop looping.
   4. If `maxPush <= 0`, skip this entity.
   5. `push = min(maxPush, delta) + 0.01`. Call `moveEntityByPiston(dir, entity, push, dir)` (8.3).
   6. If the entity is not extending and is a source: `fixEntityWithinPistonBase(pos, entity, dir, delta)` (8.4).

`PistonMath.getMovementArea(box, dir, d)`: let `m = d * step(dir.axisDirection)`, `lo = min(m, 0)`, `hi = max(m, 0)`. The result is `box` replaced, on the axis of `dir`, by the slab: WEST `[minX + lo, minX + hi]`, EAST `[maxX + lo, maxX + hi]`, DOWN `[minY + lo, minY + hi]`, UP `[maxY + lo, maxY + hi]`, NORTH `[minZ + lo, minZ + hi]`, SOUTH `[maxZ + lo, maxZ + hi]`; the other two axes keep the box's extents.

`getMovement(area, dir, entityBox)`: the overlap depth along `dir`: EAST `area.maxX - e.minX`; WEST `e.maxX - area.minX`; UP `area.maxY - e.minY`; DOWN `e.maxY - area.minY`; SOUTH `area.maxZ - e.minZ`; NORTH `e.maxZ - area.minZ` (read from the six-way switch of `PistonMovingBlockEntity.getMovement`; the area is the first argument, the entity box the third).

### 8.2 `moveStuckEntities` (honey)

Only when `movedState` is a `honey_block` and the movement direction is **horizontal**. Let `top = movedState collision shape max Y`. The probe box is the unit-width cell box `(0, top, 0)` to `(1, 1.500001, 1)` shifted by the current offset. `delta = newProgress - progress`. Every entity in that box that satisfies the sticky test is moved by `delta` along the movement direction (through `moveEntityByPiston`). Sticky test (`matchesStickyCritera(area, entity, pos)`): the entity's push reaction is `PUSH_PULL`, it is on the ground, and either it is supported by the block at `pos` (`isSupportedBy`) or its x lies in `[area.minX, area.maxX]` and its z lies in `[area.minZ, area.maxZ]`.

### 8.3 `moveEntityByPiston(noclipDir, entity, amount, dir)`

1. Set the thread-local `NOCLIP` to `noclipDir`.
2. Remember the entity's position; `entity.move(MoverType.PISTON, (amount * step(dir)).xyz)`; apply the block-effects check between the old and new positions; remove the latest movement recording.
3. Clear `NOCLIP`.

`Entity.move` with `MoverType.PISTON` first runs `limitPistonMovement`: if the squared length of the movement is at most 1e-7 return it unchanged; keep per-entity accumulators `pistonDeltas[3]` (X, Y, Z) that reset to zero when the game time differs from the stored one; take the **first non-zero axis in the order X, Y, Z**; the new accumulator is `clamp(accumulator + movement, -0.51, +0.51)`; the allowed movement is the change of the accumulator; if its absolute value is at most 9.999999747378752e-6 the movement becomes zero (and `move` returns without moving), else the allowed vector has that single axis only. So an entity moves at most 0.51 blocks per axis per game tick by pistons.

Two further facts about `Entity.move` with `MoverType.PISTON` (read): (a) when the entity's `stuckSpeedMultiplier` has squared length above 1e-7, the multiplier is **not applied** to a piston movement (it is applied for every other mover), but it is still reset to zero and the entity's delta movement is cleared; (b) the piston movement then goes through `maybeBackOffFromEdge` and `collide` like any other mover, so a pushed entity still collides with the world's blocks and is stopped by them.

### 8.4 `fixEntityWithinPistonBase(pos, entity, dir, delta)` (retracting source only)

`cell` = the unit box at `pos`. If the entity box intersects `cell`: `back = opp(dir)`; `d1 = getMovement(cell, back, entityBox) + 0.01`; `d2 = getMovement(cell, back, entityBox ∩ cell) + 0.01` (`getMovement` per 8.1 with the direction `back`); if `|d1 - d2| < 0.01`: `d = min(d1, delta) + 0.01` and `moveEntityByPiston(dir, entity, d, back)` (move the entity along `back`, with `NOCLIP = dir`).

## 9. Shapes, survival and breaking

All lengths in sixteenths of a block; a box is `(x0..x1, y0..y1, z0..z1)`.

### 9.1 Base

`extended=false`: full cube. `extended=true`: a 16 x 16 box 12 thick, flush against the **back** of the cell: facing NORTH `z 4..16`; SOUTH `z 0..12`; WEST `x 4..16`; EAST `x 0..12`; DOWN `y 4..16`; UP `y 0..12` (the model is `boxZ(16, 4, 16)` for NORTH and `rotateAll` for the others: EAST = Y-rotation 90, SOUTH 180, WEST 270, DOWN and UP the X-rotations). Collision shape equals the shape.

### 9.2 Head

Two boxes unioned; platform and arm for facing NORTH, then rotated like the base:

| Part | NORTH | other facings (rotate) |
|---|---|---|
| platform | `x 0..16, y 0..16, z 0..4` | thin slab on the facing side: SOUTH `z 12..16`, WEST `x 0..4`, EAST `x 12..16`, DOWN `y 0..4`, UP `y 12..16` |
| arm, `short=false` | `x 6..10, y 6..10, z 4..20` | extends back 16: SOUTH `z -4..12`, WEST `x 4..20`, EAST `x -4..12`, DOWN `y 4..20`, UP `y -4..12`, centred 4 x 4 on the other axes |
| arm, `short=true` | `x 6..10, y 6..10, z 4..16` | extends back 12: SOUTH `z 0..12`, WEST `x 4..16`, EAST `x 0..12`, DOWN `y 4..16`, UP `y 0..12` |

The long arm overlaps 4/16 into the base cell, so the head's shape extends outside its cell on the back side (the box `boxZ(4, 4, 20)` is read). Collision shape equals the shape.

### 9.3 Head survival and breaking

- `canSurvive(headState, level, pos)`: the state behind the head (`pos + opp(facing)`) is the matching extended base (`isFittingBase`: block is `piston` when the head type is `normal`, `sticky_piston` when `sticky`; `extended=true`; same `facing`), **or** it is `moving_piston` with the same `facing`.
- `updateShape`: when the neighbour direction `d` satisfies `opp(d) == facing`, that is the neighbour behind the head, and the state cannot survive, the head becomes **air**. Other directions defer to the default.
- `playerWillDestroy(level, pos, state, player)`: on a server level, if the player `preventsBlockDrops` (creative) and the block behind is a fitting base, destroy that base cell **without drops** (`destroyBlock(pos + opp(facing), false)`), then the default behaviour for the head.
- `affectNeighborsAfterRemoval(head, level, pos, moved)`: if the block behind is a fitting base, `destroyBlock(base, true)` (drops the piston item). (When the base is a `moving_piston`, nothing is destroyed.)
- Clone item (pick block): the `piston` item for type `normal`, the `sticky_piston` item for `sticky`.
- `MovingPistonBlock.destroy(level, pos, state)`: look at `pos + opp(facing)`; if it is a piston base with `extended=true`, `removeBlock(thatPos, false)`.
- `MovingPistonBlock.useWithoutItem` (right click): on a server, if there is no block entity at the position, remove the block (flags 3) and consume the use; otherwise pass. `getDrops`: the drops of `movedState` (loot with the moving block's context) when the entity is present, else none.

## 10. Client

### 10.1 What the client does

- Block Event packet: `ClientLevel.blockEvent(pos, block, a, b)` calls the same `triggerEvent` on the client level. Client branch: the power re-check and both cancel rules are **skipped**; `moveBlocks` runs with the client's own copy of the world (creating the same moving entities, with item drops and the break effect played client side); the sounds play locally (volume, pitch as 3.2).
- Moving blocks tick on the client with the same arithmetic (7.2); at `progressO >= 1` the entity lingers 5 more ticks before it removes itself and places its block locally.
- Entity pushing runs on the client for the local player and any entity it simulates (`canSimulateMovement`), identical to 8.

### 10.2 Rendering numbers (`PistonHeadRenderer`)

The renderer translates by the entity offsets `getXOff/YOff/ZOff(partialTick)` (7.1) and draws:

- a pushed block or the extending head: `movedState` (for `piston_head`, with `short = progress(partial) <= 0.5`; the guard "progress <= 4.0" is always true);
- a retracting source: a head `piston_head` with `type` from the moved base (`sticky` if it is a sticky piston), `facing` from the base state, `short = progress(partial) >= 0.5`, translated by the offset; and, **without** offset, the base `piston` state with `extended=true`;
- nothing when `movedState` is air.

Positions used by the renderer: for every moving-block render state it builds, `PistonHeadRenderer.extractRenderState` reads the **biome** at a block position (`ClientLevel.getBiome`) and passes that position, the state and the biome to `createMovingBlock` (the render state for one moved block). For the pushed block or extending head the position is `pos.relative(opposite of the movement direction)` (the cell the block started from). For the retracting source, the head uses `pos.relative(opposite of the movement direction)` and the extended base uses `pos.relative(movement direction)`; the base is drawn without the movement offset, but its sampling position is not the cell itself. Biome sampling for tint is read; that the same position also feeds light sampling is (inferred, not read: `createMovingBlock` was not opened).

View distance of the renderer: 68 (blocks). Models, blockstates and textures are pack data: `blockstates/piston.json`, `piston_head.json`, `sticky_piston.json`, `moving_piston.json`, `models/block/piston*.json`, `template_piston*.json` (read as present, content not tabulated).

## 11. Update ordering, pulses and suppression: summary

1. A power change reaches the piston through `neighborChanged`. `checkIfExtend` only **queues** a block event; the world is not changed in that call.
2. The event is run in the block-event phase of the server level tick (after block ticks, fluid ticks, raids and the chunk source tick, before entities and block entities; 33 §2.1). All piston state changes happen there, in the order of section 3.2 and section 6.
3. A pulse shorter than the queue delay: the piston re-checks power in `triggerEvent`. If power returned (types 1 and 2) the retraction is cancelled and the piston is just marked extended (flag 2). If power vanished before extending (type 0) the extension is cancelled. Hence a 0-tick pulse (power on and off within one tick, both `neighborChanged` queue calls in the same phase) leaves the piston extend-queued then cancelled: `extend` event runs unpowered, return false, no movement.
4. A sticky piston asked to retract soon after extending: the "drop" decision (2.3) drops the block (type 2) if the moving block it is pushing is under half-way (`progressO < 0.5`), or was ticked this very game tick, or the retraction request occurs while the level is handling a tick; only a retraction request from outside the tick (for example from a player action or a packet) with the push at least half-done pulls the block back. In particular the common "sticky piston clock" case (retraction triggered by redstone inside a tick) leaves the block behind.
5. Write flags used by the piston code: 18 (destroyed blocks), 67 (extended base placed, finished block), 276 (head removal, moving base, extended-state helper), 324 (moving blocks), 82 (vacated cells), 340 (placement when the shape update turns the block into air), 2 (cancelled retraction marker). No write uses flag 1 except 67 and the entity's finishing writes; all the neighbour notifications that matter are explicit calls (6 steps 11 and 12).
6. Shape-update suppression: flag 16 is set on nearly all writes (18, 82, 276, 324, 340), so the writes themselves never cascade shape updates; instead steps 9 and 11 of section 6 call the shape updates of the old and new neighbours with the budget argument 2 (so a piston move never recurses deeply).
7. The order of vacated-cell notification (section 6 step 9) follows the iteration order of a hash map whose key hash is given in 6.1; the bucket spreading and table sizing are not in the artifact (Open question 3).

## 12. Worked examples

Directions use the data values of the section 3.1 table.

**12.1 Simple extension.** Piston P at (0,64,0), facing EAST (data 5), `extended=false`; stone at (1,64,0); air at (2,64,0); a redstone block at (-1,64,0) (a power source on the back side; `PoweredBlock` reports 15 in every direction: `isSignalSource` true, `ownSignal` 15, and the default `getSignal` returns it; 30 part 1 §6, read). `neighborChanged` → `getNeighborSignal`: term 1 tests `pos + WEST` = (-1,64,0) with direction WEST: powered. Not extended → resolver (extending): `startPos = (1,64,0)`; `isPushable(stone, ... EAST, false, EAST)`: in range, not air, not a piston, destroy speed 1.5 (not -1), reaction `PUSH_PULL` so rule 7: no block entity: true. `addBlockLine((1,64,0), EAST)`: `lineLen=1`, not sticky, append (1,64,0), `count=1`; forward scan: (2,64,0) is air: return true. `toPush = [(1,64,0)]`, `toDestroy = []`. Event `(P, type 0, data 5)` queued. In the event phase: still powered; `moveBlocks`: no destroy; push: `np = (2,64,0)`, moving block with stone entity (`extending`, not source); head at (1,64,0): moving block with head entity (`extending`, source); (1,64,0) is removed from `oldAt` (the head moving block lives there), so the vacated-map is empty; `updateNeighborsAt((1,64,0), stone)`, `updateNeighborsAt((1,64,0), piston_head)`. Back in `triggerEvent`: P becomes `extended=true` (flags 67), sound `block.piston.extend`. Ticks: event tick `t`: progress 0.5; `t+1`: 1.0; `t+2`: stone placed at (2,64,0), head placed at (1,64,0) (`short=false`).

**12.2 Push limit.** Piston facing EAST with 12 stone blocks at x = 1..12 and air at x = 13: the forward scan appends x=1 (start line), then x=2..12; when appending x=12 the list already holds 11 entries (11 < 12), so it is added (12 entries); the next cell x=13 is air: returns true. Result: pushes 12. With a 13th stone at x=13: the scan reaches x=13 with `toPush.size() = 12`: `size >= 12` → return false; the piston does not extend and no event is queued. Check from the start cell too: `lineLen + toPush.size() > 12` is tested with `lineLen = 1`.

**12.3 Obsidian and torch.** Obsidian at the start cell: `isPushable` false (`IMMOVEABLE`); not `POPPED` → resolver false → no event. A torch at the start cell: `isPushable(.., allowDestroy=false)` is false for `POPPED`; extending and `POPPED` → `toDestroy = [start]`, resolver returns true; `moveBlocks` drops the torch as an item (flags 18 write), then the head moves in; nothing is pushed.

**12.4 Slime branch.** Piston EAST at (0,0,0); slime at (1,0,0); stone at (1,0,1) (SOUTH of the slime); stone at (1,1,0) (UP); everything else air. `addBlockLine((1,0,0), EAST)`: slime is sticky; the backward chain step probes `pos + WEST*1 = (0,0,0)` which is the piston: `canStickToEachOther(slime, piston)` is true and the piston at `extended=false` passes `isPushable`, but `p == pistonPos` ends the chain; `lineLen = 1`; append (1,0,0); forward scan: (2,0,0) air. Then `addBranchingBlocks((1,0,0))`: skip WEST/EAST; DOWN: air (`canStick(air, slime)` is true because the slime is sticky, `addBlockLine` on air returns true); UP: `addBlockLine((1,1,0), UP)` appends (1,1,0); NORTH (z-1): air; SOUTH: `addBlockLine((1,0,1), SOUTH)` appends (1,0,1). Final `toPush = [(1,0,0), (1,1,0), (1,0,1)]`. Replace the stone at (1,0,1) by honey: `canStickToEachOther(honey, slime)` is false: it is not dragged.

**12.5 Sticky retraction and the drop rule.** Sticky piston at (0,0,0) facing EAST, extended, head at (1,0,0), stone at (2,0,0); power removed from a player action (outside the tick). `checkIfExtend`: unpowered and extended; (2,0,0) is stone, not a moving block, so `type = 1`. Event: `getNeighborSignal` false; type 1 continues. `be(1,0,0)` is null (head fully placed). `setBlock((0,0,0), moving_piston[east, sticky], 276)`; entity: `movedState = sticky_piston[east, extended=false]`, `direction = EAST`, `extending=false`, `source=true`. Sticky: `two` = stone; not moving; `type==1`, not air, `isPushable(stone, two, WEST, false, EAST)` true and reaction `PUSH_PULL` → `moveBlocks(..., extending=false)`: head cell is `piston_head` → air (276); resolver (retract): `startPos = (2,0,0)`, `pushDirection = WEST`; one block (2,0,0) pushed; `moveDir = WEST`; moving block at (1,0,0) with `direction = EAST`, `extending=false`; (2,0,0) is vacated → air (82). Offsets: at progress 0 the stone sits at +1 of its cell (that is back at x=2). Sound `block.piston.contract`. The stone is placed at (1,0,0) at tick `t+2` and the base placed at (0,0,0) (`extended=false`), after which `onPlace` runs `checkIfExtend` again (still unpowered: nothing).

Same situation but the retraction request is made from inside a tick (a repeater output during block ticks) and the extension began less than half done at the time of the request: `type = 2`: the head is removed, the cell at `two` is left as it was.

**12.6 Quasi-connectivity.** Piston at (0,0,0) facing NORTH, unpowered otherwise, with a redstone block at (0,2,0) (two cells above). Term 3: `above = (0,1,0)`; direction UP: `hasSignal((0,2,0), UP)`: the redstone block's signal toward the query is 15 (30 part 1 §6, read) → powered. Move the redstone block to (1,1,0) (east of the cell above, direction EAST): `hasSignal((1,1,0), EAST)` also true. Place it at (0,0,0)'s own east (1,0,0): term 1 (EAST is not the facing NORTH) is true. Place it directly in front at (0,0,-1): term 1 excludes NORTH, term 3 tests `above + NORTH = (0,1,-1)` not (0,0,-1): not powered.

**12.7 Entity push.** A player standing on stone that is extended EAST by a piston: each tick `delta = 0.5`; for the stone's collision box (1 cube) shifted by its offset, `getMovementArea` is the slab `[maxX + 0, maxX + 0.5]`; a player box whose `minX` is inside that slab has `getMovement = area.maxX - e.minX` (EAST), which is the depth the entity must be pushed and is at most 0.5 here because the slab is 0.5 deep and the entity's `minX` lies inside it; `push = min(maxPush, 0.5) + 0.01`; `Entity.move(PISTON, …)` clamps accumulated movement to ±0.51 on that axis within the tick.

**12.8 Cancelled extension.** A lever switched on then off within the same tick before the event phase: two `neighborChanged` calls: first queues type 0, second changes nothing (the piston is not `extended`, not powered: no case). In the event phase: unpowered and type 0: return false: nothing happens.

## 13. Validation

1. Resolver: for all push lines, `toPush.size() <= 12` at every successful `resolve`; with 13 stone blocks in a row the piston never extends, with 12 it does (12.2).
2. Order of `toPush`: back-to-front chain, then forward blocks, with the collision reorder of 4.4; moving blocks are written in reverse list order.
3. `isPushable`: air true; extended piston false; unextended piston true; chest, furnace, hopper false; bedrock false; obsidian false; `POPPED` false unless `allowDestroy`; glazed terracotta pushable only with `direction == pistonFacing`.
4. Power check: a source at the cell above-and-beside powers the piston; a source in front of the piston does not; a source in front of the cell above does.
5. Event gating: queue a type 0 event, remove power before the event runs: no movement and no packet; queue a type 1 event, restore power: the base becomes `extended=true` with no moving blocks.
6. Timeline: moving blocks reach `progress` 0.5 then 1.0 and finish on the third tick (12.1).
7. Retraction of a non-sticky piston removes the head only; a sticky piston with a movable `PUSH_PULL` block at `two` pulls it, one with a `PUSH_PULL` block with a block entity or a `POPPED`/`IMMOVEABLE` block leaves it.
8. NBT: save and load round-trips `progress` as `progressO`; absent keys use the defaults of 7.6.
9. Slime and honey: honey never links to slime; slime drags adjacent stone; an immovable block beside a slime block does not block the push.

## 14. Open questions

1. **Per-block push reaction table (5.4).** The `Blocks` initializer was re-checked: the 17 `IMMOVEABLE` entries (15 explicit calls, which already include `piston_head` and `moving_piston`, plus `piston` and `sticky_piston` through `pistonProperties`), the 16 `PUSH` entries, `heavy_core` and the names of the explicit `POPPED` fields match section 5.4. The explicit `POPPED` call count is 206; 215 fields are reached when the helper-based blocks are included. Still **unresolved** (not verified by that check): the `COPPER_LANTERN`, `COPPER_DOOR` and `COPPER_GOLEM_STATUE` families, the claim that the `CARPET` collection has no override, and the helper-built candle, shulker box and potted blocks (`candleProperties`, `shulkerBoxProperties`, `flowerPotProperties`). The 24 documents hold the registry rows and should be cross-checked row by row.
2. **`getNeighborSignal` term 2.** `hasSignal(pos, DOWN)` on the piston's own cell is concluded to be always false; not exercised with a hypothetical state of a piston that is also a signal source (none exists in the registry read).
3. **Order of vacated-cell updates.** Steps 8 and 9 of section 6 iterate a `java.util.HashMap` keyed by `BlockPos`. The key hash is now read (`Vec3i.hashCode` = `(y + z*31)*31 + x`, 6.1). Still not in the artifact: the JDK's bucket spreading, initial table size, resize policy and iteration order (recalled, not verified). Implementations needing bit-exact ordering must reproduce those JDK rules; otherwise treat the order as undefined.
4. **Sound and loot data.** No `sounds.json` is present in this artifact (a listing of the jar's non-directory entries contains no file of that name and no `assets/minecraft/sounds*` entries; the only matches are block-tag files whose names contain `sounds`), so the `block.piston.extend` and `block.piston.contract` event definitions could not be read. Loot tables `piston` and `sticky_piston` were not opened (their presence was confirmed through the data tree only for blockstates and models). The sound names, volumes and pitch formulas in 3.2 are read from the code.
5. **Orientation with the experiments flag.** `ExperimentalRedstoneUtils.initialOrientation` and `withFront` were not read; the values are only meaningful when the redstone-experiments feature flag is on (29 §3).
6. **Closed.** The `getEntities(null, box)` filter was read: it excludes spectators (8.1 step 3). The remaining filter internals of `Level.getEntities(Entity, AABB, Predicate)` (dead or removed entities, the entity-section lookup) were not traced; the piston code adds no filter besides `IGNORE_ENTITY`.
7. **`BlockCollisions` mode 2.** Which callers pass the mode that considers only `moving_piston` states (7.7) was not traced; a search was made only inside `BlockCollisions` itself.
8. **Sculk vein and jungle temple.** `SculkVeinBlock$SculkVeinSpreaderConfig` and `JungleTemplePiece` reference piston blocks and were not opened; the first is covered by 30 part 8 if it matters, the second is worldgen.
9. **Render sampling position.** That the `createMovingBlock` position also drives light sampling was not read (10.2).
