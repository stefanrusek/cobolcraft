# 39 Portals and dimension travel: nether portals, end portals, gateways, the teleport transition and the player's dimension change

| Item | Value |
|---|---|
| Covers | The entity-side portal state machine (inside-portal flag, portal time, cooldowns, per-class rules); the nether portal frame engine (`PortalShape`: detection, size limits, activation by fire, destruction); the nether portal block's travel rules (destination level, coordinate scaling, exit search, largest-rectangle search, relative position and orientation, piglin spawn); `PortalForcer` (search by point of interest, creation of a new portal and of the fallback platform); the teleport transition model (`TeleportTransition`, `Relative`, `PositionMoveRotation`, post-teleport actions, same-dimension and cross-dimension entity teleport, passengers, collision-free placement); end portal frames, eyes of ender in frames, end portal entering and returning, end gateway transitions; the end credits path and the respawn after the dragon; the play-phase packets and the player state that a dimension change sends, keeps and resets; the client's handling of Respawn and Player Position. |
| Does not cover | Block shapes, hardness and registry rows of the portal blocks (24); the eye of ender entity flight (25-5 section 6.3a); the end gateway block entity state, tick and exit-position search (31-5 section 4); End generation, the platform feature and the dragon fight (38, 21 section 6.4.5 and 6.4.6); the POI manager and the POI block-change hook (44 section 1.3 and 1.4a); respawn blocks (bed, anchor) and the first-spawn search (17 section 4.10, 33 section 6); the world border (33 section 7); the game rules (33 section 8); mob behaviour near portals (piglin conversion, 20, 21, 44); ender pearl teleports (17); particle emitters (42); chunk encoding (06). The structure data and loot of ruined portals and stronghold portal rooms are data and generator topics (36, 37-6). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the classes named in each section and of the JSON under `data/minecraft/` in the jar (`unzip -p`), with no execution. Examples marked "(computed)" were produced by applying this document's text with a throwaway reference script written for the round; they are not read from the artifact. |
| Round | RS23 (GAP-13c of [../design/README.md](../design/README.md) Part 5) |
| Operator decisions | Standard Minecraft content is the target; the extraction tool (22) builds the data pack, and this document specifies the engines that interpret it. The code-defined algorithms are specified completely. |
| Data versus code | DATA (extracted by the tool, not tabulated here): the dimension types and their `coordinate_scale`, `min_y`, `height`, `logical_height` and attributes; the block tags `nether_portal_frame` (one entry in this jar: `obsidian`), `portals`, `fire`, `dragon_immune`; the loot table of the nether portal block; the structure NBT of ruined portals. CODE (specified here): every algorithm and constant of sections 2 to 9. |

Class names in backticks say where a fact was read and are not the design. "(inferred)" marks a deduction; "(recalled, not verified)" marks text that was not read (there is none in this document except where stated). "Read" means read in the artifact this round. Section references: "05b 0x54" means document 05b, the packet with that id; "33 section 6.5" means document 33, section 6.5.

## 0. Reader's map

| Question | Section |
|---|---|
| Every constant, tag, rule and level event used by portals | 1 |
| When does an entity start, finish or lose a portal transit; cooldowns | 2 |
| How a nether portal frame is found, sized, lit and broken | 3 |
| Where a nether portal leads; scaling; orientation; velocity | 4 |
| How the destination portal is found or built | 5 |
| The transition object, relative flags, passengers, cross-dimension entity copy | 6 |
| End portal frames, eyes, the end portal, the return, the credits, gateways | 7 |
| What the server sends and keeps when a player changes dimension; what the client does | 8 |
| Client presentation (overlay, sounds) | 9 |
| Worked examples | 10 |
| Validation | 11 |
| Open questions | 12 |

## 1. Constants, data inputs and cross-document hooks

### 1.1 Constants read

| Name | Value | Read in |
|---|---|---|
| Nether portal interior width, min and max | 2 and 21 | `PortalShape` (`MIN_WIDTH`, `MAX_WIDTH`) |
| Nether portal interior height, min and max | 3 and 21 | `PortalShape` (`MIN_HEIGHT`, `MAX_HEIGHT`) |
| Search reach when walking down from a start cell to the portal floor | 21 below, bounded by the level's minimum y | `PortalShape.calculateBottomLeft` |
| Block placement flags used for portal interior blocks | 18 (bits 2 `UPDATE_CLIENTS` and 16 `UPDATE_KNOWN_SHAPE`, 29 section 1) | `PortalShape.createPortalBlocks`, `PortalForcer.createPortal` |
| Portal destination search radius | 16 when the destination is the Nether, 128 when the destination is not | `PortalForcer.findClosestPortalPosition` (`NETHER_PORTAL_RADIUS`, `OVERWORLD_PORTAL_RADIUS`) |
| Portal creation spiral radius | 16 (33 x 33 = 1089 columns) | `PortalForcer.createPortal` |
| Created portal frame | 4 wide, 5 tall, interior 2 x 3 | `PortalForcer` (`FRAME_WIDTH` 4, `FRAME_HEIGHT` 5) |
| Fallback creation y range | lower `max(minY + 1, 70)`, upper `top - 9` | `PortalForcer.createPortal` |
| Chunk ticket for a portal arrival | type `portal`, timeout 300 ticks, flags 15 (persist 1 + loading 2 + simulation 4 + keep-dimension-active 8), radius 3 | `Entity.placePortalTicket`, `TicketType` (`PORTAL`), `PortalForcer.TICKET_RADIUS` |
| Entity portal cooldown after a transit (`getDimensionChangingDelay`) | `Entity` default 300; first passenger a `ServerPlayer` gives that passenger's value; `Player` 10; `VehicleEntity` 10; `Projectile` 2 | `Entity`, `Player`, `VehicleEntity`, `Projectile` |
| Portal time decay when not inside | 4 per tick, floor 0 | `PortalProcessor.decayTick` |
| Nether portal transit time | players: `max(0, rule)` where the rule is `players_nether_portal_creative_delay` if the player's `invulnerable` ability is true, else `players_nether_portal_default_delay`; every other entity: 0 | `NetherPortalBlock.getPortalTransitionTime` |
| End portal and end gateway transit time | 0 (the `Portal` interface default) | `Portal`, `EndPortalBlock`, `EndGatewayBlock` |
| End spawn point | block (100, 50, 0) | `ServerLevel.END_SPAWN_POINT` |
| Piglin spawn chance at a nether portal random tick | `nextInt(2000) < difficulty id` | `NetherPortalBlock.randomTick` |
| Level events | 1032 portal travel sound (to one player), 1038 end portal opened (global), 1503 eye placed in a frame | `LevelEvent`, `TeleportTransition.playPortalSound`, `EnderEyeItem` |
| Game events | 0 `NO_RESPAWN_BLOCK_AVAILABLE`, 4 `WIN_GAME`, 13 `LEVEL_CHUNKS_LOAD_START` (values 0.0) | `ClientboundGameEventPacket` (ids in 05a) |
| Respawn packet data-to-keep bits | 1 keep attribute modifiers, 2 keep entity data, 3 both | `ClientboundRespawnPacket` |
| Relative flag bits | X 0, Y 1, Z 2, Y_ROT 3, X_ROT 4, DELTA_X 5, DELTA_Y 6, DELTA_Z 7, ROTATE_DELTA 8 | `Relative` (the wire form is in 05b, TeleportFlags) |
| Standard relative sets | `DELTA` = {DELTA_X, DELTA_Y, DELTA_Z, ROTATE_DELTA}; `ROTATION` = {X_ROT, Y_ROT}; `ALL` = all nine | `Relative` static initialiser |

### 1.2 Data inputs (extracted by the tool)

| Input | Value read in this jar | Used by |
|---|---|---|
| Dimension type `coordinate_scale` | `overworld` 1.0, `overworld_caves` 1.0, `the_nether` 8.0, `the_end` 1.0 | section 4.1 |
| Dimension type `min_y`, `height`, `logical_height` | overworld -64, 384, 384; nether 0, 256, 128; end 0, 256, 256 | section 5.2 (`top`) |
| Dimension attribute `minecraft:gameplay/nether_portal_spawns_piglin` | true in `overworld` and `overworld_caves`; absent in `the_nether` and `the_end` | section 3.5 |
| Tag `minecraft:nether_portal_frame` | `["minecraft:obsidian"]` | section 3 (`PortalShape.FRAME`) |
| Tag `minecraft:fire` | the fire blocks (`fire`, `soul_fire`) (not tabulated) | section 3 (`isEmpty`) |
| POI type `nether_portal` | covers every block state of `nether_portal`; 0 tickets; search distance 1 (44 section 1.2) | section 5.1 |
| Game rules | `players_nether_portal_default_delay` (default 80), `players_nether_portal_creative_delay` (default 0), `allow_entering_nether_using_portals` (default true; false blocks only travel into the Nether) (16 section for the rule table, 33 section 8) | sections 2.4, 2.5 |

No `allow-nether` property string exists in the classes of `net/minecraft` of this jar (searched); the rule `allow_entering_nether_using_portals` is the only gate.

### 1.3 Other documents' statements corrected or confirmed here

* 37 section 6.3 says the nether portal block has no destination "otherwise" (when the source is neither Overworld nor Nether). The bytecode reads: destination = Overworld when the current level is the Nether, otherwise the Nether. A nether portal block in the End therefore leads to the Nether (37-6 section 10 states it correctly). Such a block can only come from commands or data, because fire creates portals only in the Overworld and the Nether (section 3.3). TASK for the orchestrator: document 37 section 6.3 needs this one-line correction in a later round (this round may edit only this document); the correct statement is the one in this bullet.
* 31-5 section 4.1 left open the "portal travel engine" and the transition of the end portal; they are sections 2, 6 and 7 here. The conditions "between the dimension test and `showEndCredits`" are in section 7.3.
* 38 sections 9.1 and 9.2 describe the end portal arrival and return; this document adds the transit time, the cooldown, the player-only respawn call result shape and the credits path (section 7).

## 2. The entity-side portal state machine

### 2.1 State

Every entity has: `portalCooldown` (int ticks, saved under the key `PortalCooldown` in entity NBT, see 45), and `portalProcess` (absent or a `PortalProcessor`: the portal block it is inside, the entry position, `portalTime` int, and `insidePortalThisTick` boolean). A fresh process starts with `portalTime` 0 and `insidePortalThisTick` true. A player additionally has `isChangingDimension` (section 8.2).

### 2.2 When the flag is set (`Entity.setAsInsidePortal(portal, pos)`)

Called by `NetherPortalBlock.entityInside`, `EndPortalBlock.entityInside` and `EndGatewayBlock.entityInside` while an entity overlaps the block (the overlap test is the inside-block sweep of section 2.2a). Steps:

1. If the entity is on portal cooldown (`portalCooldown > 0`): set `portalCooldown` back to the full value `getDimensionChangingDelay()` and stop. (Standing inside a portal after a transit keeps the cooldown full; it counts down only after the entity leaves.)
2. Else if there is no process, or the existing process belongs to a different portal block type: replace it by a new process (portal time 0, flag true, entry position = this block's position).
3. Else (same portal type): if the process's flag is not already true, set the entry position to this block's position and set the flag true.

### 2.2a The inside-block sweep (`Entity.applyEffectsFromBlocks`, `checkInsideBlocks`)

This decides on which ticks `entityInside` is called for the three portal blocks (read this round).

**When it runs.** For a `LivingEntity` (players and mobs) once per tick at the END of `aiStep`, which is after `baseTick` (`LivingEntity.tick` calls the base tick, which runs `handlePortal`, and calls `aiStep` later in the same tick). So a flag set by the sweep of tick `t` is consumed by `handlePortal` at the start of tick `t + 1` (section 2.3). Other classes call the same routine from their own tick (read by name: `ItemEntity`, `ExperienceOrb`, `PrimedTnt`, `FallingBlockEntity`, boats, minecarts, `EndCrystal`, `EnderDragon`, `FireworkRocketEntity`, the projectile classes `ShulkerBullet`, `ThrowableProjectile`, `FishingHook`, `AbstractHurtingProjectile`, `AbstractArrow`); their position in the tick relative to `handlePortal` is (inferred) the same order and was not decoded per class. An entity that is removed or has `noPhysics` set is not swept.

**Which movements.** Every `Entity.move` call records one movement (from-position, to-position) for the tick (at most 100 are kept; when full the two oldest merge into one spanning them). For a `ServerPlayer` the accepted client move goes through `ServerPlayer.move`, so it is recorded; a client move that the server rejects removes its record again. The sweep takes the records accumulated since the previous sweep and clears them. If there are none, one record from the entity's previous-tick position (`oldPosition`) to its current position is used; if the last record ends more than about 1e-5 blocks (squared distance above 1e-10) from the current position, one more record from that end to the current position is appended. So a stationary entity is still tested every tick at its current position.

**Per movement `(from, to)`.** A movement whose per-axis breakdown is known (`axisDependentOriginalMovement`) is split into up to three straight legs, one per axis with a nonzero component, taken in the order `Direction.axisStepOrder` of the original movement; otherwise it is a single leg. Each leg is processed by the block visitor below with a shared budget of 16 block-steps per movement (each leg consumes the steps it used). After all legs, if the budget is used up (at or below 0), one extra zero-length pass tests the cells of the box at `to`. A set of visited block positions (`visitedBlocks`) is shared by all legs of the tick so a cell is visited once per sweep.

**Block visitor for one leg.** The tested box is the entity's bounding box at the leg's end position, shrunk by 9.999999747378752E-6 on every side. The visited cells are the cells that box touches at the end, the cells it touched at the start, and the cells it passes through while sliding from start to end (a voxel walk of the box's leading corner; the visiting order inside one leg does not matter for the portal blocks, which only set a flag). For a leg shorter than 1e-5 only the cells of the box are visited. Per cell, in this order:

1. If the entity is no longer alive, stop the sweep.
2. Skip air.
3. The block's entity-inside shape: the whole cell (`Shapes.block()`) is the default (`getEntityInsideCollisionShape`), used by the nether portal block and the end gateway; the end portal block overrides it with its own shape (x and z full, y from 6/16 to 12/16). A whole-cell shape counts as "touched" without a further test. Any other shape is tested with `collidedWithShapeMovingFrom(from, to, boxes)` (below).
4. The cell's fluid state is also tested the same way against the fluid's own box.
5. If neither the block shape nor the fluid was touched, or the cell was already visited in this sweep, skip it.
6. If the block shape was touched, call the block's `entityInside(state, level, pos, entity, effectApplier, precise)` where `precise` is true when the leg is longer than 0.99999 blocks or the tested box intersects the cell. The three portal blocks ignore `precise`.

**`collidedWithShapeMovingFrom(from, to, boxes)`.** Let `c0` = the centre of the entity's bounding box when placed at `from`, `c1 = c0 + (to - from)`, and `(sx, sy, sz)` the entity's box sizes. A shape box `B` (already moved to the block's position) is first inflated by `sx/2 - 1e-7`, `sy/2 - 1e-7`, `sz/2 - 1e-7` on its two sides of each axis. The shape is touched when `c1` or `c0` lies inside an inflated box, or the segment `c0` to `c1` crosses it (a box clip). In words: the entity's box overlaps the shape box at the start, at the end, or anywhere along the straight move (shrunk by 1e-7 per side).

Consequences (computed from the above): a player standing still inside a nether portal cell is flagged every tick; a player walking through is flagged on the tick whose movement touches the cell. For the end portal (a slab 6/16 tall, y +0.375 to +0.75 inside the cell) an entity must overlap that slab: an entity whose feet are at the cell's top (y +1.0) does not overlap it, a player falling through it does, and a thin slab is also caught when the fall step is long because the move is a swept segment, not a point test. The gateway has a 40-tick cooldown of its own (section 7.6) and `isCoolingDown` blocks the flag.

### 2.3 Each tick (`Entity.handlePortal`, called from `Entity.baseTick`, after the boarding cooldown and before sprint particles; server levels only; the classes below call it elsewhere)

Several entity classes override `tick` without `baseTick` and call `handlePortal` directly: `PrimedTnt` (the first call in `tick`), `FallingBlockEntity` (after the block-effect application), `AbstractMinecart` (after the speed computation), `EndCrystal` (after the block-effect application), and `ShulkerBullet` and `AbstractArrow`, which call it only while the process exists and its `insidePortalThisTick` flag is true. The step list below is the same in every case.

1. If `portalCooldown > 0`, decrement it by 1. For a `ServerPlayer` this decrement is skipped while `isChangingDimension` is true.
2. If there is no process: stop.
3. Ask the process to advance (`processPortalTeleportation(level, entity, canUse)` with `canUse = entity.canUsePortal(false)`):
   * if the flag is true: set it false; if `canUse`: let `old = portalTime`, set `portalTime = old + 1`, and the result is `old >= transitTime` (compare with the value BEFORE the increment; `transitTime` is the block's `getPortalTransitionTime(level, entity)`); if not `canUse` the result is false and `portalTime` is unchanged;
   * if the flag is false: `portalTime = max(portalTime - 4, 0)` and the result is false.
4. If the result is true: set `portalCooldown = getDimensionChangingDelay()` (BEFORE the destination is computed, so a failed destination still starts the cooldown), ask the portal block for the destination (`getPortalDestination(level, entity, entryPosition)`), and if it is not null call `teleportToPortalDestination` (section 2.5).
5. If the result is false and the process has expired (`portalTime <= 0`): drop the process.

Consequence (computed): with transit time T the entity teleports on the (T + 1)th `baseTick` after the tick whose end-of-tick sweep (2.2a) first set the flag; T = 80 (default player) is the 81st tick, T = 0 (creative player, every non-player, end portal, gateway) is the first tick. Leaving the portal for k ticks removes 4k ticks of progress.

### 2.4 Who may use a portal (`canUsePortal(allowPassengers)`)

Base rule (`Entity`): `(allowPassengers || !isPassenger) && isAlive`. All three portal blocks call it with `false`, so a riding entity never enters a portal by itself (its vehicle does). Overrides:

| Class | Rule |
|---|---|
| `LivingEntity` | the base rule and not sleeping |
| `WitherBoss`, `EnderDragon`, `FishingHook` | always false |
| `ThrowableProjectile` | always true (even as a passenger) |
| `Creaking` | not heart-bound and the `Monster` rule |
| everything else | the base rule |

### 2.5 The gates and the transfer (`Entity.teleportToPortalDestination(level, transition)`)

The transfer happens only when `ServerLevel.isAllowedToEnterPortal(destination level)` holds (false only when the destination is the Nether and the rule `allow_entering_nether_using_portals` is false) AND (the destination dimension equals the current one, or `Entity.canTeleport(current level, destination level)`). `canTeleport` refuses only the move from the End to the Overworld, and only when some player among the entity's direct passengers has not seen the credits (`seenCredits` false). A player entity itself is never refused here: the End portal sends such a player to the credits instead (section 7.5). When the gates pass, `Entity.teleport(transition)` runs (section 6.5 to 6.7; for a `ServerPlayer` section 8.1).

### 2.6 Other users of the cooldown

`NetherPortalBlock.randomTick` gives a freshly spawned portal piglin and its vehicle the full cooldown (section 3.5). `ConversionType.convertCommon` copies the portal cooldown from the old mob to the converted one. `ThrownEnderpearl.onHit` sets the pearl owner's cooldown (17).

Two explosion rules read the portal state. `PrimedTnt.teleport` (an override that calls the base teleport and then, when the result is a `PrimedTnt`, sets its `usedPortal` flag to true; whether the flag is saved to NBT was not read, 45). When the primed TNT explodes with `usedPortal` true it passes `USED_PORTAL_DAMAGE_CALCULATOR` to the explosion, otherwise the default calculator. That calculator differs from the default in two answers only: for a `nether_portal` block `shouldBlockExplode` is false (the block is never destroyed by the explosion) and the block explosion resistance is empty (no resistance value, so it does not absorb ray strength); every other block defers to the default. `SulfurCube` uses the same calculator in its explosion when its portal cooldown (`getPortalCooldown`) is above 0, otherwise the default. The other sulfur cube behaviour is outside this document (20, 21).

## 3. The nether portal frame (`PortalShape`)

### 3.1 Vocabulary

* **Frame block**: a block state in the tag `nether_portal_frame` (`PortalShape.FRAME`).
* **Empty cell**: air, a block in the tag `fire`, or a `nether_portal` block (`isEmpty`).
* **Axis** is X or Z (the horizontal axis along which the portal plane extends). For axis X the portal block's plane is x by y at one z; for Z it is z by y at one x. `rightDir` is WEST for X and SOUTH for Z; the left direction is its opposite. The shape is symmetric, so which end is called "left" is not observable.
* A **shape** is (axis, count of portal blocks found in the interior, bottom-left interior cell, width, height). Width counts interior cells along the axis; height counts interior rows.

### 3.2 Finding the shape at a cell (`PortalShape.findAnyShape(level, pos, axis)`)

1. **Bottom-left.** Let `limit = max(minY, pos.y - 21)`. Starting at `pos`, move down while the current y is above `limit` and the block below is an empty cell. Then take the distance `d` from `getDistanceUntilEdgeAboveFrame(start, left direction)` and let `n = d - 1`. If `n < 0` there is no shape (all counts 0). Otherwise bottom-left = the start moved `n` blocks in the left direction.
2. `getDistanceUntilEdgeAboveFrame(start, direction)`: for `i` from 0 to 21 inclusive, look at the cell `start + direction * i`. If it is not an empty cell: return `i` when it is a frame block, else return 0. If it is an empty cell: the block directly below it must be a frame block, else return 0. If the loop ends, return 0. (So the interior cells must all sit on frame blocks, and the first non-empty cell must be a frame block.)
3. **Width.** `w = getDistanceUntilEdgeAboveFrame(bottomLeft, rightDir)`; the width is `w` when `2 <= w <= 21`, else 0 (no shape).
4. **Height.** `getDistanceUntilTop(bottomLeft, rightDir, width, counter)`: for `h` from 0 to 20: the cell one step left of the interior column at row `h` (that is `bottomLeft + up*h + rightDir*(-1)`) and the cell one step right (`rightDir*width`) must both be frame blocks, else return `h`; then every interior cell of the row (`rightDir*0` to `rightDir*(width-1)`) must be an empty cell, else return `h`; each interior cell that is a `nether_portal` block increments `counter`. If the loop ends return 21. The height is that value when `3 <= h <= 21` and the top row (`bottomLeft + up*h + rightDir*w` for `w` in 0 to width-1) is all frame blocks; else 0 (no shape). The corner cells of the frame are never examined. A row that fails after some of its cells were counted leaves those counts in `counter`.
5. The shape's `numPortalBlocks` is the counter value.

`isValid`: width 2 to 21 and height 3 to 21. `isComplete`: valid and `numPortalBlocks == width * height`.

`findPortalShape(level, pos, predicate, axis)`: find the shape for `axis`; if it satisfies the predicate return it; else find the shape for the other horizontal axis and return it if it satisfies the predicate. `findEmptyPortalShape(level, pos, axis)` uses the predicate "valid and no portal block counted".

### 3.3 Activation by fire (`BaseFireBlock`)

* `BaseFireBlock.onPlace` (any fire block placed, the old state not the same block): if the level is the Overworld or the Nether (`inPortalDimension`), call `findEmptyPortalShape(level, pos, X)` (which also tries Z); if a shape is present, `createPortalBlocks` and stop (the fire block is replaced); otherwise, if the fire cannot survive there, remove it. In any other dimension the portal engine is not consulted.
* `createPortalBlocks`: fill every interior cell (the box from the bottom-left to the cell `up*(height-1)` and `rightDir*(width-1)` away) with `nether_portal` of the shape's axis, with flags 18 (no shape updates, so the new blocks do not undo themselves).
* Placing fire is allowed next to a frame (`BaseFireBlock.canBePlacedAt`, used by flint and steel, fire charge and the dispenser, 17 and 30-4): the target must be air and (the fire state can survive, or `isPortal` holds). `isPortal(level, pos, direction)`: false outside the Overworld and the Nether; otherwise look at the six neighbours in `Direction` order; at the FIRST neighbour that is a frame block decide and return: the axis is `direction.getCounterClockWise().getAxis()` when `direction` is horizontal, else a random horizontal axis from the level random; return whether `findEmptyPortalShape(level, pos, axis)` is present.

### 3.4 Destruction (`NetherPortalBlock.updateShape`)

When a neighbour of a portal block changes, with the changed side's axis `a` and the block's own axis `p`:

1. If `p != a` and `a` is horizontal (a change across the portal plane), keep the block unchanged.
2. Else if the new neighbour state is a `nether_portal` block (any axis), keep the block unchanged.
3. Else if `findAnyShape(level, pos, p)` is complete, keep the block unchanged.
4. Otherwise the block becomes air (and its own neighbours then update in turn).

### 3.5 Piglin spawn (`NetherPortalBlock.randomTick`; the condition summary is also in 33 section 9)

On a random tick of a portal block at `pos`: all of these must hold: the level spawns monsters, the difficulty is not Peaceful, the dimension attribute `nether_portal_spawns_piglin` at `pos` is true, `nextInt(2000)` is below the difficulty id (Easy 1, Normal 2, Hard 3), and a player is close enough for spawning (18 section 6.2). Then move `pos` down while the block at it is a portal block; if the block there allows a spawn of a `zombified_piglin` (`BlockState.isValidSpawn`), spawn one at `pos.above()` with reason `STRUCTURE`; if that returned an entity, set its portal cooldown (full value, 300 for a piglin) and the portal cooldown of its vehicle if it has one.

## 4. Nether portal travel (`NetherPortalBlock`)

### 4.1 Destination level and origin

`getPortalDestination(level, entity, entryPos)`:

1. Destination dimension: the Overworld if the current level is the Nether, otherwise the Nether (so the End goes to the Nether). If the server has no such level: no destination.
2. `scale = source.coordinate_scale / destination.coordinate_scale` (double division): Overworld to Nether 1/8, Nether to Overworld 8, Overworld to Overworld-like 1.
3. `origin = destination.border.clampToBounds(entity.x * scale, entity.y, entity.z * scale)`: x and z are clamped to `[minX, maxX - 9.999999747378752E-6]` (33 section 7.4) and the result is the block position containing that point (floor of each coordinate; y is not scaled).
4. `isNetherDestination` = (destination is the Nether). Continue with 4.2 using the destination level, the entity, the entry position, the origin, the flag and the destination border.

### 4.2 Find or create (`getExitPortal`)

1. Ask `PortalForcer.findClosestPortalPosition(origin, isNetherDestination, border)` (section 5.1).
2. **Found** (`p`): read the portal block state at `p`; take its axis; compute the largest rectangle of identical portal blocks around `p` (4.3) with `maxWidth = 21` along that axis and `maxHeight = 21` along Y; the post-teleport action is "play portal sound" then "place a portal ticket at `p`".
3. **Not found**: if the entity is a spectator, no destination (null). Otherwise the new portal's axis is the axis of the portal block at the entry position `entryPos` in the entity's current level (default X when that block has no axis); call `PortalForcer.createPortal(origin, axis)` (section 5.2). If it produced nothing (no room, or the target is outside the border), log the error "Unable to create a portal, likely target out of worldborder" and return no destination. Else the rectangle is the created portal (its bottom-left interior cell, width 2, height 3) and the post action is "play portal sound" then "place a portal ticket at the entity's position after arrival".
4. Build the transition from the exit rectangle (4.4).

### 4.3 The largest rectangle (`BlockUtil.getLargestRectangleAround(pos, axis1, max1, axis2, max2, predicate)`)

Used with `axis1` = the portal's axis, `max1 = 21`, `axis2` = Y, `max2 = 21`, and the predicate "the block state at this position is exactly the state of the reference portal block" (same axis). Result: a rectangle (`minCorner`, `axis1Size`, `axis2Size`). Steps:

1. `limit(from, direction, max)` counts how many consecutive cells starting one step from `from` in `direction` satisfy the predicate, at most `max`.
2. Let `neg` and `pos` be `limit(pos, negative axis1 direction, max1)` and `limit(pos, positive axis1 direction, max1)`. There is one column per offset `-neg .. +pos` along axis1 (call the column index `c`, with `c0 = neg` the centre column).
3. For each column store the extent (`down`, `up`) along axis2 measured from the row of `pos`: the centre column uses `limit(pos, -axis2, max2)` and `limit(pos, +axis2, max2)`; moving outward one column at a time (first the negative side, then the positive side), a column's extents are `limit(columnPos, -axis2, previous column's down)` and `limit(columnPos, +axis2, previous column's up)`, where `previous` is the column one step nearer the centre. So every column's interval contains the row of `pos`, and extents never grow outward.
4. Let `down0` = the centre column's `down`. For each candidate bottom row `v` from `down0` down to 0 (rows are numbered from the lowest row of the centre column's interval, so the row of `pos` is `down0`): for each column the "height" is `(down0 + up) + 1 - v` when `down0 - down <= v <= down0 + up`, else 0.
5. Run the largest-rectangle-in-a-histogram step on these heights (below), obtaining the column range `[lo, hi]` and the height `h`; the area is `(hi - lo + 1) * h`. Keep the candidate when its area is STRICTLY greater than the best so far (so on ties the first candidate, which is the one with the highest bottom row, and within a row the first found, stays).
6. Result: `minCorner = pos` moved `(lo - c0)` along axis1 and `(bestBottomRow - down0)` along axis2; `axis1Size` = the best width; `axis2Size` = the best height.

Histogram step (`getMaxRectangleLocation(heights)`): given the column heights, return the column range `[lo, hi]` and height `h` of the rectangle of the largest area `h * (hi - lo + 1)` that fits under the histogram (every column in the range has height at least `h`). Candidates are the maximal rectangles: for each bar, the widest run of columns around it that are at least as tall as it. Tie rule (the only place where the exact order matters): when two candidates have the same area, the winner is the one that a left-to-right sweep closes first, where a candidate closes at the column just past its right end, and candidates closing at the same column close tallest first; a later candidate must be strictly larger to replace it. A zero-height column never wins. Worked example: heights `[2, 3, 3, 1]`: candidates are height 3 on columns 1..2 (area 6, closes at 3), height 2 on columns 0..2 (area 6, closes at 3, after the taller one), height 1 on columns 0..3 (area 4, closes at 4) and height 3 on column 2 alone (area 3): the result is columns 1..2, height 3. Heights `[3, 3]` gives columns 0..1, height 3; `[1, 4, 1]` gives column 1 alone, height 4 (area 4) against height 1 on 0..2 (area 3).

Because every interval contains the row of `pos`, the returned rectangle always contains `pos`'s row, and a rectangle of identical portal blocks that does not contain `pos`'s row is never returned. A lone extra portal block next to a rectangle does not change the result (examples in section 10).

### 4.4 Relative position and the exit transition

**Relative position of the entity in the entry portal** (`Entity.getRelativePortalPosition` -> `PortalShape.getRelativePosition(entryRect, axis, entityPos, entityDimensions)`; the entry rectangle is the largest rectangle (4.3) around the entry position in the entity's CURRENT level, using the portal block state at the entry position; when that block is not a portal block the axis is X and the relative position is (0.5, 0, 0)). With `ew`, `eh` the entity's width and height in its current pose, `W = rect.axis1Size`, `H = rect.axis2Size`:

* `slackW = W - ew`, `slackH = H - eh`.
* `rx`: if `slackW > 0`: `clamp((entity.axis - (rect.minCorner.axis + ew / 2)) / slackW, 0, 1)`, else 0.5.
* `ry`: if `slackH > 0`: `clamp((entity.y - rect.minCorner.y) / slackH, 0, 1)`, else 0.
* `rz`: the entity's coordinate on the OTHER horizontal axis minus (the rectangle's `minCorner` coordinate on that axis + 0.5); not clamped, so it can be negative (the entity is on one side of the plane) or large.
* The relative position is (`rx`, `ry`, `rz`).

**Exit position** (`createDimensionTransition(level, exitRect, entryAxis, relative, entity, post)`): let `exitAxis` be the axis of the portal block at `exitRect.minCorner` in the destination (default X), `W`, `H` the exit rectangle's sizes.

* `px = ew / 2 + (W - ew) * rx`, `py = (H - eh) * ry`, `pz = 0.5 + rz`.
* If `exitAxis` is X: position = (`minCorner.x + px`, `minCorner.y + py`, `minCorner.z + pz`). If Z: (`minCorner.x + pz`, `minCorner.y + py`, `minCorner.z + px`).
* The position is then made collision-free (6.8).
* `yawChange` = 0 if `entryAxis == exitAxis`, else 90 (degrees).
* The transition: destination level, the adjusted position, velocity `ZERO`, yaw `yawChange`, pitch 0, relative flags `DELTA` and `ROTATION`, and the post action of 4.2. With these flags (6.3) the entity's yaw gains `yawChange`, its pitch is unchanged, and its velocity is kept but rotated about Y by the angle `oldYaw - newYaw` (that is `-yawChange` degrees).

The entity's dimensions here are those of its current pose (`getDimensions(getPose())`), for both the relative position and the exit position.

## 5. `PortalForcer`

### 5.1 Finding an existing portal (`findClosestPortalPosition(pos, destinationIsNether, border)`)

1. `r = 16` if `destinationIsNether` else `128`.
2. Make the POI sections within `floorDiv(r, 16)` chunks of the position's chunk (all heights) loaded and valid (`ensureLoadedAndValid`, 44 section 1.3; the chunks are fetched at the lowest generation status).
3. Collect the POI records of type `nether_portal` (occupancy ANY) in the square `|dx| <= r`, `|dz| <= r` around `pos` (`getInSquare`; y ignored; 44 section 1.3). Every portal block has such a record (44 section 1.4a), not only the bottom one.
4. Keep the positions that are inside the destination border (block-position test, 33 section 7.4) and whose current block state has the horizontal-axis property.
5. Choose the minimum by `distSqr(pos, candidate)` (3D, double), ties broken by the LOWER y; if still tied the first in stream order stays (the iteration order of the POI stream was not decoded, Open question 1). No result: empty.

### 5.2 Creating a portal (`createPortal(origin, axis)`)

Inputs: the destination level (its border, minimum y, maximum y and `logical_height`), `origin` (4.1), `axis`. Derived: `dir` = the positive direction of `axis` (EAST for X, SOUTH for Z); `cw` = `dir` turned clockwise (SOUTH for EAST, WEST for SOUTH); `top = min(level.maxY, level.minY + logical_height - 1)` (Nether: 127; Overworld: 319; End: 255).

**Phase A: candidate scan.** Visit the 1089 columns of the square spiral of radius 16 around `origin` (first direction EAST, second direction SOUTH: the visiting order is exactly the spiral of 33 section 6.2 step 4: (0,0), (1,0), (1,1), (0,1), (-1,1), (-1,0), (-1,-1), (0,-1), (1,-1), (2,-1), (2,0), ..., ending at (16,-16); every offset of the 33 x 33 square once; computed). For each column `(x, z)`:

1. Skip the column unless the border contains the column and also the column moved one block along `dir`.
2. `start = min(top, MOTION_BLOCKING height at (x, z))` (the first y above the highest motion-blocking block, 06 heightmaps).
3. Scan `y` downward from `start` to `minY` inclusive. A cell is **replaceable** when its state's replaceable flag (`canBeReplaced`, a block-registry property, 24) is true and its fluid state is empty. Skip cells that are not replaceable. At a replaceable cell at `y`, find the bottom of its replaceable run: `yb` = the lowest `y' <= y` such that every cell from `y'` to `y` is replaceable (stopping at `minY`). Then (the scan resumes at `yb - 1` in every case):
   * skip the run if `yb + 4 > top`;
   * skip the run if `0 < (y - yb) < 3` (a run whose height difference is 1 or 2 is rejected; a single cell, difference 0, and a run with difference 3 or more are accepted);
   * let the candidate position be `(x, yb, z)`; the candidate must pass `host(0)`, else nothing is recorded;
   * `d = distSqr(origin, candidate)` (double);
   * if the candidate also passes `host(-1)` and `host(+1)` it is a **full** candidate: it replaces the best full candidate when there is none or `d` is strictly smaller;
   * if there is still no full candidate at this point, the candidate competes for the **fallback**: it replaces the fallback when there is none or `d` is strictly smaller (once any full candidate exists the fallback is no longer updated).
4. After the scan: if there is no full candidate and there is a fallback, the fallback becomes the chosen position.

`host(k)` ("the frame slab shifted by `k` blocks along `cw` can be built at the candidate"): for `i` in -1..2 along `dir` and `j` in -1..3 in y, relative to the candidate shifted by `k * cw`: every cell with `j = -1` must be solid (`BlockState.isSolid`); every cell with `j` in 0..3 must be replaceable (as defined above). (Offsets -1 and +1 require the slab in front of and behind the portal plane to be free too.)

**Phase B: no position at all.** If nothing was chosen: `lower = max(minY + 1, 70)`, `upper = top - 9`. If `upper < lower`, creation fails (empty result). Otherwise `centre = (origin.x - dir.stepX, clamp(origin.y, lower, upper), origin.z - dir.stepZ)`, moved into the border by `WorldBorder.clampToBounds(BlockPos)` (33 section 7.4). Build a platform with normal block updates (`setBlockAndUpdate`, no drops): for `a` in -1..1 along `cw`, `b` in 0..1 along `dir`, `c` in -1..2 in y, relative to `centre`: obsidian when `c = -1`, air when `c` is 0, 1 or 2. (3 x 2 obsidian floor, a 3 x 2 x 3 cleared volume.)

**Phase C: frame and interior (both when a position was chosen and after phase B; `P` = the chosen position or the centre).** Set to obsidian (normal block update) every cell `P + i*dir + (0, j, 0)` with `i` in -1..2 and `j` in -1..3 for which `i` is -1 or 2, or `j` is -1 or 3 (14 cells). Then set the 2 x 3 interior cells `P + i*dir + (0, j, 0)`, `i` in 0..1, `j` in 0..2, to `nether_portal` with the given `axis`, with flags 18. Result: the rectangle (`P`, width 2, height 3).

Note the frame is built after the chosen position's slab was only CHECKED to be replaceable: existing blocks are overwritten without drops.

## 6. The teleport transition model

### 6.1 `TeleportTransition`

A record of: `newLevel`, `position` (Vec3), `deltaMovement` (Vec3), `yRot`, `xRot` (floats), `missingRespawnBlock` (bool), `asPassenger` (bool), `relatives` (a set of `Relative`), `postTeleportTransition` (an action taking the arriving entity). Short constructors fill `missingRespawnBlock = false` and `asPassenger = false`, and an empty relative set when none is given.

Producers read in this round:

| Producer | New level | Position | Delta | Yaw, pitch | Relatives | Post action |
|---|---|---|---|---|---|---|
| Nether portal (4.4) | destination | exit position (4.4) | ZERO | `yawChange`, 0 | `DELTA` + `ROTATION` | sound then portal ticket |
| End portal, source not End (7.3) | End | (100.5, 50.0, 0.5), minus 1.0 in y for a player | ZERO | 90 (WEST), 0 | `DELTA` + {X_ROT} | sound then portal ticket |
| End portal, source End, non-player (7.4) | the respawn data's dimension | `adjustSpawnLocation(level, respawn pos)` at its bottom centre | ZERO | respawn yaw and pitch | `DELTA` + `ROTATION` | sound then portal ticket |
| End portal, source End, player (7.4) | from `findRespawnPositionAndUseSpawnBlock(false, do-nothing)` | personal respawn or world spawn | ZERO | its own | EMPTY (all absolute) | do nothing |
| End gateway, other entities (7.6) | the gateway's level | exit position of the gateway block entity | ZERO | 0, 0 | `DELTA` + `ROTATION` | portal ticket only |
| End gateway, `ThrownEnderpearl` (7.6) | same | same | ZERO | 0, 0 | EMPTY | portal ticket only |
| `TeleportTransition.createDefault(player, post)` | `findRespawnDimension()` (the dimension of the overworld level data's respawn data, else the Overworld) | `adjustSpawnLocation` of that level's respawn position at its bottom centre | ZERO | respawn yaw and pitch | EMPTY | the given action |
| `TeleportTransition.missingRespawnBlock(player, post)` | same | same | ZERO | same | EMPTY | the given action; `missingRespawnBlock = true` |
| `Entity.teleportTo(level, x, y, z, relatives, yaw, pitch, camera)` (commands such as `/tp`; the ServerPlayer override only handles sleeping and the camera first) | the given level | the given | ZERO | the given | the given | do nothing |
| `ServerPlayer.teleportTo(x, y, z)` (same level) | not a transition: sends Player Position with `DELTA` + `ROTATION` relative and rotation 0 | | | | | |

`withRotation`, `withPosition` and `transitionAsPassenger` build copies with the one component replaced (the last also sets `asPassenger`).

### 6.2 `Relative` flags and the three standard sets

See 1.1. A flag set means "relative to the entity's current value".

### 6.3 Resolving a transition against the entity's state (`PositionMoveRotation.calculateAbsolute(base, change, relatives)`)

`base` is `PositionMoveRotation.of(entity)`: position, yaw and pitch from `Entity.getClientPositionAndRotation`, velocity from `Entity.getKnownMovement`. `change` is the transition's (position, delta, yaw, pitch).

**The base values (read this round).**

* Position and rotation: the entity's interpolation target when one is pending, else the entity's live position, yaw and pitch. On the server `LivingEntity` has an interpolation handler but a server-side entity has no client lerp in progress, so for a `ServerPlayer` and every server mob the base is the live position, yaw and pitch (inferred from the absence of any server call that starts an interpolation; the handler's `target()` returns nothing when none is active). Entities of other classes use a no-op handler: always live values.
* Velocity (`getKnownMovement`): for a `ServerPlayer`, if it is riding a vehicle that it does not control, the vehicle's known movement; otherwise `lastKnownClientMovement`, which is NOT the server's `deltaMovement`. It is set by the movement vector the server computed for the last accepted client move packet (the same displacement vector used for the fall-damage check, in `handlePlayerPositionChange`; `handleMoveVehicle` sets it as well) and is reset to the zero vector at the end of any client tick (`handleClientTickEnd`) in which no movement packet arrived. For a non-player entity: if its controlling passenger is a living player, that player's known movement; else its own `deltaMovement`. So a player teleported by a portal has its velocity rotated from the displacement of its last client move, not from the server's physics velocity (which for a player is typically zero or stale).

The result:

1. `position.x = (X in relatives ? base.x : 0) + change.x`, likewise y with Y and z with Z.
2. `yaw = (Y_ROT in relatives ? base.yaw : 0) + change.yaw` (no wrapping); `pitch = clamp((X_ROT in relatives ? base.pitch : 0) + change.pitch, -90, 90)`.
3. `delta` starts as `base.delta`. If ROTATE_DELTA is in `relatives`: let `dy = base.yaw - result.yaw` and `dx = base.pitch - result.pitch` (32-bit float subtraction, degrees); rotate the vector first about X by `dx` and then about Y by `dy`, where the angle passed to `xRot`/`yRot` is `(float) toRadians((double) d)` (the double product `d * pi/180`, then rounded to float). With `a` that float angle, `c = cosT(a)` and `s = sinT(a)` (the table functions below, each returning a float that is widened to double for the products): `xRot`: `y' = y*c + z*s`, `z' = z*c - y*s`, `x` unchanged; `yRot`: `x' = x*c + z*s`, `z' = z*c - x*s`, `y` unchanged (all in double). Then each component: `delta.c = (DELTA_c in relatives ? rotated.c : 0) + change.delta.c` (when not relative, only the change value; the rotated value is dropped).

**The sine and cosine tables (`Mth.sin`, `Mth.cos`; read this round).** A table of 65536 floats, `SIN[i] = (float) sin(i / 10430.378350470453)` for `i` in 0..65535 (double `Math.sin` of the double quotient, rounded to float; 10430.378350470453 is 65536 / 2pi). Lookups take a double angle `x` in radians: `sinT(x) = SIN[ (int)((long)(x * 10430.378350470453) & 65535) ]` and `cosT(x) = SIN[ (int)((long)(x * 10430.378350470453 + 16384.0) & 65535) ]`. The conversion `(long)` truncates toward zero, and the mask makes negative values wrap (two's complement), so the angle quantum is 2pi/65536 (about 0.0000959 rad, 0.00549 degrees) and an angle is rounded toward zero in table steps before the lookup. Worked values (computed by applying this rule with a throwaway script; the angles are the float results of `toRadians` of the degree value): for 90 degrees the float angle is 1.5707964 (slightly above pi/2), so the product is just above 16384 and `sinT` = `SIN[16384]` = 1.0 exactly, while `cosT` = `SIN[32768]` = 1.2246468e-16 (the float of `sin(pi)`, not 0); for -90 degrees: `sinT` = -1.0 and `cosT` = `SIN[0]` = 0.0 exactly (so the example E4 gives exactly (-0.1, 0, 0.2)); for 45 degrees (0.7853982 as float): `sinT` = `cosT` = 0.7071067690849304 (exact `cos` of the float angle would be 0.7071067657, exact `sin` 0.7071067966). An implementation must use this table, or reproduce it with a double `sin` rounded to float, to match the client and server in the last digits; the differences from exact trigonometry are about 1e-8 relative, so a tolerance of 1e-6 is a safe comparison bound for tests (inferred from the values above).

So for a nether portal (`DELTA` + `ROTATION`, change delta ZERO): the new velocity is the old velocity rotated by `-yawChange` degrees; the new yaw is `oldYaw + yawChange`; the pitch is unchanged. For the end portal entry (`DELTA` + X_ROT, yaw 90 absolute): the velocity is rotated by `oldYaw - 90` degrees about Y; the yaw becomes 90; the pitch is kept (clamped).

The server applies this to the entity and the Player Position packet carries the UNRESOLVED change plus the flags; the client resolves it against its own state with the same rule (`ClientPacketListener.handleMovePlayer` -> `setValuesFromPositionPacket`) and answers with Accept Teleportation carrying the position and rotation it ended up with (05c).

### 6.4 Post-teleport actions

An action is `Entity -> void`; `a.then(b)` runs `a` then `b`. The named ones:

* `DO_NOTHING`.
* `PLAY_PORTAL_SOUND`: if the arriving entity is a `ServerPlayer`, send it Level Event (05a 0x2F) with event 1032, position (0, 0, 0), data 0, not global. (The client plays `SoundEvents.PORTAL_TRAVEL` locally with volume 0.25 and pitch `random * 0.4 + 0.8`, section 9.)
* `PLACE_PORTAL_TICKET`: `placePortalTicket(blockPosition of the entity's position)`; `Entity.placePortalTicket(pos)` adds, on a server level, the chunk ticket of type `portal` for `ChunkPos.containing(pos)` with radius 3 (type values in 1.1; the meaning of radius 3 is in the next paragraph).

**What ticket radius 3 means (read this round).** `addTicketWithRadius(type, chunk, r)` creates a ticket whose level is `33 - r` (33 = `ChunkLevel.byStatus(FULL)`), so radius 3 gives level 30 on the arrival chunk. The distance manager's trackers spread a ticket's level to the 8 neighbours of a chunk with a cost of +1 per step, so the level at chunk-distance `d` (Chebyshev, square rings) is `30 + d`. Level meanings (`ChunkLevel`): 31 or less is entity-ticking, 32 or less block-ticking, 33 or less fully loaded (accessible, not ticking), above 33 a partially generated "border" status that is loaded but not accessible. Result for the arrival chunk and its square neighbourhood: distance 0 and 1 (the 3 x 3 chunks) entity-ticking, distance 2 (the 5 x 5 ring) block-ticking, distance 3 (the 7 x 7 ring) full; further out partial chunks exist for the generation dependencies only (their extent is `ChunkLevel.RADIUS_AROUND_FULL_CHUNK`, derived from the generation pyramid and not read). The flags 15 mean the ticket counts for both the loading tracker and the simulation tracker (bits 2 and 4), is saved (bit 1) and keeps the dimension active (bit 8); it expires 300 ticks after creation (timeout of the type). The tickets are what makes the arrival area load and simulate even when no other ticket covers it; the player's own tracking view (8.1 step 11) separately decides which chunks are sent.
* The nether portal's found-portal action calls `placePortalTicket(p)` for the portal block position `p` instead.

### 6.5 `Entity.teleport(transition)`

Returns the entity now in the new level, or null when the entity is not on a server level or already removed. If the new level differs from the current: when the transition is not `asPassenger` the entity first stops riding; then the cross-dimension path (6.6). Otherwise the same-dimension path:

1. Teleport every passenger with its own transition (6.7).
2. Apply `calculateAbsolute(PositionMoveRotation.of(entity), PositionMoveRotation.of(transition), relatives)` to the entity: set the raw position, yaw, head yaw (= yaw), pitch, re-apply the position, set the old position and rotation to the new ones, set the velocity, and clear the movement-this-tick record (`teleportSetPosition`).
3. If the transition is not `asPassenger`, send Teleport Entity (05b 0x80) to the players: to a player who is the entity's controlling passenger (or the entity itself) the packet carries the transition's change and its relative flags with the entity's `onGround`; to every other player among the entity and its passengers, the entity's own resulting position-move-rotation with an empty flag set; and, when the entity type has an update interval or is not client-simulated, to the tracking players via the chunk source, excluding those already sent to.
4. Run the post action on the entity.

### 6.6 Cross-dimension teleport of a non-player (`teleportCrossDimension`)

1. Remember the passengers, eject them all, teleport each with its passenger transition (6.7) and collect those that were returned (they now live in the new level).
2. Create a new entity of the same type in the new level with spawn reason `DIMENSION_TRAVEL` (null result: abort, returns null).
3. `restoreFrom(old)`: save the old entity to NBT (without its id) and load it into the new entity, then copy `portalCooldown` and `portalProcess` (the object itself) from the old entity.
4. Remove the old entity (`removeAfterChangingDimensions`: removal reason `CHANGED_DIMENSION`; a leashable entity loses its leash; a waypoint transmitter is untracked).
5. Apply `calculateAbsolute(PositionMoveRotation.of(old entity), PositionMoveRotation.of(transition), relatives)` to the new entity (6.5 step 2), add it to the new level (`addDuringTeleport`), and make the collected passengers ride it (forced, no teleport checks).
6. Reset the new level's empty-time counter, run the post action on the NEW entity, then move every player of the old level whose camera is this entity: that player is teleported with the same transition and the camera cleared (`teleportSpectators`).

### 6.7 Passengers

For a passenger `p` of vehicle `v` the transition becomes (`calculatePassengerTransition`, then `transitionAsPassenger`): yaw = `t.yaw + (Y_ROT in t.relatives ? 0 : p.yaw - v.yaw)`; pitch = `t.pitch + (X_ROT in t.relatives ? 0 : p.pitch - v.pitch)`; position = `t.position + (c in t.relatives ? 0 : p.c - v.c)` for each of x, y, z; delta, relatives, new level and post action unchanged; `asPassenger` true (no stop-riding, no Teleport Entity broadcast). Passengers are teleported before their vehicle is moved or copied.

### 6.8 Collision-free placement (`PortalShape.findCollisionFreePosition(position, level, entity, dimensions)`)

1. If the entity's width or height is greater than 4.0, return `position` unchanged.
2. `half = height / 2`. `centre = position + (0, half, 0)`. The probe shape is the box of size (`width`, 0, `width`) around `centre`, extended upward by 1 and inflated by 1.0E-6 (a thin slab).
3. `level.findFreePosition(entity, probe, centre, width, height, width)`: take the bounds of the probe inflated by (`width`, `height`, `width`); collect the block collision shapes in that box that lie inside the level's border (a shape counts when its bounds are within the border, 33 section 7.4 box rule); turn each shape into its boxes, inflate every box by (`width / 2`, `height / 2`, `width / 2`), union them; subtract that union from the probe; of what remains choose the point nearest to `centre`: for each remaining box, clamp `centre` into the box and keep that point if it is STRICTLY nearer (squared distance) than the best so far. No remaining region: empty.
4. The result is the found point minus (0, `half`, 0); when none was found the original `position`.

The union and shape-construction lambdas of step 3 were read as a map-then-reduce over the boxes; the box iteration order is Open question 2.

## 7. The End: frames, eyes, the end portal, the return, credits, gateways

### 7.1 The end portal frame block

`end_portal_frame` (`EndPortalFrameBlock`): properties `facing` (horizontal, default north) and `eye` (boolean, default false); placement state: `facing` = the opposite of the placer's horizontal direction, `eye` false (so a placed frame faces the player). Shape: empty frame = x and z full, y 0 to 13/16; with an eye the shape adds a column x and z from 4/16 to 12/16 (width 8/16 centred), y 13/16 to 1 (24 holds the table). Comparator output: 15 when `eye` is true, else 0. Rotation and mirror rotate `facing`; `useShapeForLightOcclusion` true; not pathfindable.

### 7.2 Placing an eye and opening the portal (`EnderEyeItem.useOn`; the use-in-air throw is 25-5 section 6.3)

1. If the clicked block is not an `end_portal_frame` or already has an eye: PASS. On a client level: SUCCESS.
2. On the server: set `eye` true (flags 2) after pushing entities up (`Block.pushEntitiesUp`); update comparators; shrink the held stack by 1 (always, creative included); send Level Event 1503 at the block (the client plays `END_PORTAL_FRAME_FILL`, 16 smoke particles, 42).
3. Search the pattern (`EndPortalFrameBlock.getOrCreatePortalShape().find(level, clickedPos)`).
4. If it matched: `corner = match.frontTopLeft + (-3, 0, -3)`; for the 3 x 3 cells `corner + (a, 0, b)`, `a` and `b` in 0..2: destroy the block with drops, then set `end_portal` (flags 2). Then send the GLOBAL Level Event 1038 at `corner + (1, 0, 1)` (the client plays `END_PORTAL_SPAWN`, source hostile, volume 1, pitch 1). Result SUCCESS.

**The pattern.** One layer of 5 columns by 5 rows, written as rows `?vvv?`, `>???<`, `>???<`, `>???<`, `?^^^?`. `?` matches anything (corners and the 3 x 3 centre, even air). `v` = an `end_portal_frame` with `eye` true and `facing` NORTH; `^` = same with `facing` SOUTH; `>` = same with `facing` WEST; `<` = same with `facing` EAST. Because the facings are fixed absolute directions, the pattern matches exactly one placement of a ring in the world: a horizontal ring of 12 frames with all eyes, where each side's three frames face inward.

**The search** (`BlockPattern.find(level, pos)`): let `m = max(5, 5, 1) = 5`. Candidate "front top left" cells are all cells of the box from `pos` to `pos + (4, 4, 4)`; for each candidate, for each `forwards` in `Direction` order (down, up, north, south, west, east) and each `up` in that order that is neither `forwards` nor its opposite, test the whole pattern; the first success is returned. The pattern cell (column `i`, row `j`, layer `k`) is tested at `candidate + up * (-j) + (forwards x up) * i + forwards * k`, with `x` the integer cross product. For this pattern the only combination that can match a ring is `forwards` = down, `up` = south, with the candidate at the ring's maximum-x, maximum-z corner (computed by testing every combination: a ring at x 0..4, z 0..4 matches only at the candidate (4, y, 4), whichever frame was clicked; the result does not depend on the iteration order of the box). The fill corner `frontTopLeft + (-3, 0, -3)` is therefore the ring's inner minimum corner.

### 7.3 Entering an end portal block (`EndPortalBlock.entityInside` and `getPortalDestination`)

`entityInside` (any entity inside the block, the block's entity-inside shape as in 2.2), when `entity.canUsePortal(false)`:

1. If the level is a server level, in the End dimension, the entity is a `ServerPlayer`, and its `seenCredits` is false: call `showEndCredits()` (7.5) and do NOT call `setAsInsidePortal`.
2. Otherwise `setAsInsidePortal(block, pos)` (2.2). The transit time is 0 (2.3).

`getPortalDestination(level, entity, pos)` with `R` = the level's respawn data (33 section 6.5) and `isEnd` = (the level is the End):

* **Destination**: if `isEnd` the dimension and position of `R`, else the End at `END_SPAWN_POINT`. If that server level does not exist: no destination.
* **Entering the End** (`isEnd` false): the target point is the bottom centre of `END_SPAWN_POINT`, (100.5, 50.0, 0.5). The obsidian platform is rebuilt first with `EndPlatformFeature.createEndPlatform(endLevel, (100, 49, 0), dropBlocks = true)` (a 5 x 5 obsidian floor at y 48, air at y 49 to 51 above it, each differing block destroyed with drops first; 38 section 9.1) on EVERY entry. Yaw 90 (`Direction.WEST.toYRot()`), pitch 0; relatives `DELTA` + {X_ROT}. For a `ServerPlayer` the position is lowered by 1.0 in y to (100.5, 49.0, 0.5); other entities arrive at (100.5, 50.0, 0.5) with no height-map adjustment. Post action: sound then portal ticket.
* **Leaving the End** (`isEnd` true): see 7.4.

### 7.4 Leaving the End by the exit portal

Yaw and pitch are those of `R`; relatives are `DELTA` + `ROTATION` for the non-player branch.

* A `ServerPlayer`: the transition is the result of `findRespawnPositionAndUseSpawnBlock(false, DO_NOTHING)` (17 section 4.10, 33 section 6.5): the player's own respawn point (bed or anchor; `false` means a respawn anchor's charge is NOT consumed), else the default respawn data; a missing respawn block yields the `missingRespawnBlock` transition (the player is told with Game Event 0 when the transition is applied, 8.1 step 1). That transition has an empty relative set (position and rotation absolute) and the post action `DO_NOTHING` (no sound, no ticket).
* Another entity: the dimension and position of `R` (`adjustSpawnLocation(level, R.pos)` at its bottom centre), yaw and pitch of `R`, relatives `DELTA` + `ROTATION`, post action sound then portal ticket.

A player who has not yet seen the credits does not reach this code (7.3 step 1); a rider whose vehicle enters is blocked by `canTeleport` when a player passenger has not seen the credits (2.5).

### 7.5 The credits and the respawn after the dragon

`ServerPlayer.showEndCredits()`:

1. `unRide`; remove the player from its level immediately with removal reason `CHANGED_DIMENSION` (the player stays in the player list).
2. If `wonGame` is false: set `wonGame` true, send Game Event 4 `WIN_GAME` (value 0.0), and set `seenCredits` true. (If `wonGame` is already true nothing more is sent.)

The vanilla client opens the credits screen on `WIN_GAME`; when the player closes it the client sends Client Command `PERFORM_RESPAWN` (05c) and clears its screen. The server (`ServerGamePacketListenerImpl.handleClientCommand`, action `PERFORM_RESPAWN`): if `wonGame` is true: set it false; call `PlayerList.respawn(player, keepAllPlayerData = true, CHANGED_DIMENSION)` and use the returned NEW `ServerPlayer` as the connection's player; reset the position tracking; restart the client-loaded timer (05c "Player Loaded", 60 ticks); fire the `changed_dimension` trigger (End to Overworld). (If `wonGame` is false the same action means the death respawn, only when health is 0 or less: `respawn(player, false, KILLED)`, 17 section 4.10.)

`PlayerList.respawn(old, keepAll, reason)` in order (the death path differs by `keepAll` false):

1. `transition = old.findRespawnPositionAndUseSpawnBlock(!keepAll, DO_NOTHING)`: with `keepAll` true the spawn block is not consumed.
2. Remove `old` from the player list and its level (reason as given); create a NEW `ServerPlayer` for the destination level of the transition with the same game profile and client information; give it the old connection.
3. `restoreFrom(old, keepAll)` (section 8.3): this includes `onUpdateAbilities`, which already SENDS a Player Abilities packet through the connection (before the Respawn packet). With `keepAll` true the same call also copies each active effect with `addEffect`; the new player already holds the old connection, so `ServerPlayer.onEffectAdded` sends one Update Mob Effect per effect with the blend flag TRUE, after the Abilities packet and before the Respawn packet. These are separate from the effect packets of step 7, which use blend false. With `keepAll` false no effect is copied and none is sent here.
4. Same entity id, same main arm; if the transition is not `missingRespawnBlock`, copy the respawn point to the new player; copy entity tags and post effects.
5. `snapTo` the transition position and rotation; if `missingRespawnBlock`, send Game Event 0 now.
6. Send Respawn: spawn info of the new level, data-to-keep = 1 when `keepAll` else 0 (so after the credits only the attribute modifiers are kept by the client).
7. Send a Player Position packet (teleport id incremented, no relative flags) for the snapped position; Set Default Spawn Position (effective world respawn data); Change Difficulty; Set Experience (progress, total, level); every active effect as Update Mob Effect; the post effects; `sendLevelInfo` (8.1 step 15); the permission level.
8. Add the player to the level (`addRespawnedPlayer`), to the player list and the by-UUID map; initialise the inventory menu; set the health again (flags a resend). When `keepAll` is false and the respawn point is a respawn anchor the anchor depletion sound is sent; with `keepAll` true it is not.

### 7.5a `TheEndPortalBlockEntity`

The end portal block entity has one behaviour: `shouldRenderFace(direction)` is true exactly when the face's axis is Y (the top and bottom faces) and false for the four side faces. It stores no state. The drawing itself is client rendering (12).

### 7.6 The end gateway transition (`EndGatewayBlock`; the block entity is 31-5 section 4)

`entityInside`: when `canUsePortal(false)`, on the server, with the block entity present and not cooling down: `setAsInsidePortal(block, pos)` and then `triggerCooldown` (31-5 section 4.3: the gateway's own 40-tick cooldown). The transit time is 0, so the entity transfers at the next `baseTick` (the entity's own portal cooldown then is 10 for a player, 300 for most others, 2 for a projectile).

`getPortalDestination`: the block entity at `pos` (not a gateway: no destination); `target = getPortalPosition(level, pos)` (31-5 section 4.4; null: no destination); a `ThrownEnderpearl` gets a transition at `target` in the same level with velocity ZERO, yaw and pitch 0, NO relatives, and the post action portal ticket only; every other entity gets velocity ZERO, yaw and pitch 0 with `DELTA` + `ROTATION` relative, the portal ticket only (no sound). The destination level is the same level, so the transfer is the same-dimension path of 6.5.

## 8. A player changes dimension

### 8.1 `ServerPlayer.teleport(transition)` when the new level differs (the ONLY path that sends Respawn on a portal)

Returns null when the player is removed. Steps in the order read:

1. If `missingRespawnBlock`: Game Event 0 `NO_RESPAWN_BLOCK_AVAILABLE` (value 0.0).
2. If the transition is not `asPassenger`: dismount the vehicle (`removeVehicle`).
3. **Same dimension**: send Player Position for the transition (step 10 below) and reset the position tracking, run the post action, return. No Respawn is sent and no level data is resent.
4. Set `isChangingDimension` true.
5. Send **Respawn** (05b 0x54): the spawn info of the NEW level (`createCommonSpawnInfo`: the new level's dimension type and key, the hashed seed, the player's game mode and previous game mode, debug flag, flat flag, last death location, the player's CURRENT portal cooldown, sea level) and data-to-keep 3 (attribute modifiers and entity data both kept).
6. Send **Change Difficulty** (the new level's difficulty and its locked flag) and the player's permission level (`sendPlayerPermissionLevel`: the entity-event form of 05a).
7. Remove the player from the old level immediately (reason `CHANGED_DIMENSION`); then un-remove it. When the player is removed the old level's chunk map untracks it with an empty tracking view; while the player is still associated with the old level this sends Forget Level Chunk packets for the old view (inferred from `ChunkMap.applyChunkTrackingView`, which returns without sending only when the player's level is another level; Open question 3). The vanilla client, having just processed Respawn, discards such packets, so a server MAY omit them: nothing observable depends on them (the client has already replaced its level).
8. If the old dimension is the Overworld and the new one the Nether, remember the current position as `enteredNetherPosition`.
9. Switch the player (and its game-mode object) to the new level (`setServerLevel`).
10. `connection.teleport(PositionMoveRotation.of(transition), relatives)`: set the awaiting-teleport time to the current tick; increment the teleport id, and if the result equals 2147483647 set it to 0 (so 2147483647 is never sent and the highest id on the wire is 2147483646); apply the transition to the player (6.3); remember the resulting position as the position awaited from the client; send **Player Position** (05b 0x49) with that id, the transition's change and its relative flags. Then reset the position tracking.
11. Add the player to the new level (`addDuringTeleport` -> `addPlayer`: the player is registered as an entity; the chunk map starts the player's chunk tracking from an EMPTY view and recomputes it, so the client receives Set Chunk Cache Center and the chunks of its view from scratch, with the usual batches and Chunk Batch Finished handshake of 05c, 06).
12. Fire the advancement triggers (8.5).
13. Stop using the held item.
14. Send **Player Abilities** (05a).
15. `sendLevelInfo(player, newLevel)`: **Initialize Border** (the new level's border), **Set Time** (full clock sync, 33 section 3), **Set Default Spawn Position** (the effective respawn data), and, only if it is raining in the new level: Game Event 1 `START_RAINING`, Game Event 7 `RAIN_LEVEL_CHANGE` (value = rain level), Game Event 8 `THUNDER_LEVEL_CHANGE` (value = thunder level); then Game Event 13 `LEVEL_CHUNKS_LOAD_START`; then the tick-rate state for a joining player (the freeze state).
16. `sendAllPlayerInfo`: send the whole player-inventory menu to the client (all slots, 05a container content), mark the player's last-sent health as unknown, send **Set Held Slot** with the selected slot.
17. Send every active effect as **Update Mob Effect** (blend flag false), then the post-effects packet.
18. Run the transition's post action (for the nether and end portals: step 5's sound event 1032 to this player and the chunk ticket).
19. Reset the "last sent" experience, health and food so that the next player tick re-sends **Set Experience** and **Set Health** (health, food, saturation) (`doTick` compares the live values with the last sent ones).
20. Teleport the spectators that were watching this player (`teleportSpectators`).

The player's inventory, XP, health, food, abilities (re-sent), effects (re-sent), game mode, selected slot, score and all other state stay with the same `ServerPlayer` object; nothing is copied or lost. The portal process and portal cooldown stay; the cooldown does not tick while `isChangingDimension` is true (2.3 step 1).

### 8.2 The acknowledgement

Accept Teleportation (05c) with the awaited id: the server snaps the player to the awaited position, clears `isChangingDimension` (`hasChangedDimension`) and the awaited position, and handles the client-reported position and rotation as a normal move (`handlePlayerPositionChange` with those values). From then on the 10-tick player cooldown counts down. The server does NOT restart the "client loaded" timer after a portal change (that is done only by the credits and death respawn, 7.5); the vanilla client nevertheless sends Player Loaded again after its new level loads (05c).

### 8.3 `restoreFrom(old, keepAll)` (the respawn paths of 7.5; the portal path never calls it)

Always copied: the warden spawn tracker, the chat session, the game mode and previous game mode (re-applied, then `onUpdateAbilities` sends Player Abilities), attribute base values, the enchantment seed, the ender chest container, the player-model customisation byte, the recipe book data, `seenCredits`, `enteredNetherPosition`, the explosion impact position and cause, the chunk tracking view, the debug subscriptions, both shoulder entities, the last death location and the waypoint icon; `lastSentExp`, health and food are reset to "unknown". With `keepAll` true also: permanent attribute modifiers, the health, the food data object, every active effect (copied), the inventory, experience level, total and progress, the score, and the portal process. With `keepAll` false: health = max health; the inventory, experience and score are copied only when the rule `keep_inventory` is true or the old player was a spectator.

### 8.4 What the vanilla client does with Respawn (`ClientPacketListener.handleRespawn`)

1. If the dimension key differs from the current level's: create a new empty client level (keeping the map data), clear the camera, close an open container, and stop the music; the level-loading screen reason is NETHER_PORTAL when the player is not dying and either dimension is the Nether, END_PORTAL when either is the End (and not the Nether), else OTHER.
2. Create a new local player in it (keeping statistics and recipe book; with data-to-keep bit 2 also keeping the last-sent input, sprint state and item activation). The client-loaded flag is cleared (the client sends Player Loaded when ready).
3. With bit 2: copy the non-default entity data, the velocity and the rotation to the new player; without it the position is reset and the yaw is -180.
4. With bit 1: copy all attribute values (including modifiers); without it only the base values.
5. Add the player, copy the reduced-debug and death-screen settings, set the last death location from the packet, set the portal cooldown from the packet's `portalCooldown`, copy the portal overlay intensity, close a death screen, and set the game mode (and previous game mode) from the packet.

### 8.5 Triggers (`triggerDimensionChangeTriggers`)

After a cross-dimension teleport: the `changed_dimension` criterion trigger with (from, to); and when from is the Nether and to is the Overworld and an `enteredNetherPosition` is remembered, the `nether_travel` distance trigger with that position; `enteredNetherPosition` is cleared whenever the new dimension is not the Nether. The advancement engine is outside this document.

## 9. Client presentation

* The client runs its own portal process for the local player (`LocalPlayer`, from the block's local transition: the nether portal block reports CONFUSION, the others NONE): while the process says "inside this tick", the portal overlay intensity rises by 0.0125 per tick (clamped to 0..1) and the `PORTAL_TRIGGER` sound is played when it starts from 0 (volume 0.25, pitch `random * 0.4 + 0.8`); otherwise it falls by 0.05 per tick. An open screen that is not allowed in a portal is closed (a container is closed first). The overlay and the wobble use the intensity (rendering, 12).
* Level event 1032 on the client: `PORTAL_TRAVEL` local ambient sound, volume 0.25, pitch `random * 0.4 + 0.8`. Level event 1038: `END_PORTAL_SPAWN`, source hostile, volume 1, pitch 1. Level event 1503: `END_PORTAL_FRAME_FILL` at the block plus 16 smoke particles (42). The nether portal block plays `PORTAL_AMBIENT` locally with chance 1/100 per animate tick (volume 0.5, pitch `random * 0.4 + 0.8`) and spawns 4 `portal` particles per animate tick; the end portal block spawns one `smoke` particle per animate tick at `(x + r, y + 0.8, z + r)` (42 holds the emitters).

## 10. Worked examples

**E1. A standard frame (computed).** Obsidian frame blocks at x 0..3, y 64..68, z 0 (all 14 ring cells; the four corners may be missing), air inside. Fire is placed at (1, 65, 0). `findEmptyPortalShape(level, (1,65,0), X)`: start (1,65,0); nothing below to walk; the left direction for X is EAST; `getDistanceUntilEdgeAboveFrame` visits (1,65,0) fire (empty, obsidian below), (2,65,0) air (obsidian below), (3,65,0) obsidian: returns 2, so `n = 1` and the bottom-left is (2,65,0). Width: from (2,65,0) towards WEST: (2,65,0), (1,65,0) empty with obsidian below, (0,65,0) obsidian: 2. Height: rows 65, 66, 67 have obsidian posts at x 3 and x 0 and empty interiors; row y 68 has the post at (3,68,0) and the right post (0,68,0), but its interior (2,68,0) is obsidian, not empty: the distance is 3, within 3..21, and the top row (2,68,0), (1,68,0) is obsidian: height 3. No portal blocks were counted: the shape is empty and valid; the six cells x 1..2, y 65..67 become `nether_portal` axis X with flags 18.

**E2. Rejections.** A frame with interior height 2 (top row at y 67): the height is 2, below the minimum 3, no shape. An interior width of 1: no shape. A frame whose bottom row lacks the obsidian under the left interior cell: `getDistanceUntilEdgeAboveFrame` returns 0 at that cell, no shape. A frame whose top row has a gap: `hasTopFrame` fails, no shape. A frame of width 22: the width is 0.

**E3. Coordinates (computed).** Overworld entity at (-300.5, 70.0, 1000.2) enters a portal: `scale = 1.0 / 8.0 = 0.125`; `x * scale = -37.5625`, `z * scale = 125.025`; the origin is the block (-38, 70, 125) (floor; y unscaled). Nether entity at (12.5, 70.0, -3.2): `scale = 8.0`; (100.0, -25.6): origin (100, 70, -26).

**E4. Relative position and exit (computed).** Entity (width 0.6, height 1.8) at (10.9, 64.5, 20.3) inside a portal rectangle of axis X with `minCorner` (10, 64, 20), `axis1Size` 2, `axis2Size` 3. `slackW = 1.4`, `slackH = 1.2`; `rx = (10.9 - (10 + 0.3)) / 1.4 = 0.428571`; `ry = (64.5 - 64) / 1.2 = 0.416667`; `rz = 20.3 - (20 + 0.5) = -0.2`. Exit rectangle of axis Z, `minCorner` (100, 70, -5), sizes 2 and 3: `px = 0.3 + 1.4 * 0.428571 = 0.9`, `py = 1.2 * 0.416667 = 0.5`, `pz = 0.5 - 0.2 = 0.3`; because the exit axis is Z the position is (100 + 0.3, 70 + 0.5, -5 + 0.9) = (100.3, 70.5, -4.1). The axes differ, so `yawChange = 90`: the yaw becomes `oldYaw + 90`, and a velocity (0.2, 0, 0.1) is rotated by -90 degrees about Y with the `yRot` formula: `x' = 0.2 * cos(-90) + 0.1 * sin(-90) = -0.1`, `z' = 0.1 * cos(-90) - 0.2 * sin(-90) = 0.2`: (-0.1, 0, 0.2).

**E5. Creating a portal (computed layout).** `P = (200, 70, 300)`, axis X (`dir` EAST, `cw` SOUTH): frame cells x 199..202 and y 69..73 with the ring rule (14 obsidian cells: x 199 and 202 at y 69..73, plus x 200 and 201 at y 69 and y 73), interior x 200..201, y 70..72, z 300. Axis Z (`dir` SOUTH, `cw` WEST): frame cells z 299..302 at x 200, interior z 300..301. The `host` slab checks for offset +1 on axis X look at z 301, for -1 at z 299 (cells x 199..202, y 69..73). Fallback platform (axis X, centre `C`): obsidian at x `C.x` and `C.x+1`, z `C.z-1`, `C.z`, `C.z+1`, y `C.y-1`; air at those x and z for y `C.y` to `C.y+2`.

**E6. The search order.** Radius-16 spiral from the origin: 1089 columns; the first ten offsets (east, south) are (0,0), (1,0), (1,1), (0,1), (-1,1), (-1,0), (-1,-1), (0,-1), (1,-1), (2,-1) (computed, agrees with 33 section 6.2). Two portal blocks at equal `distSqr` from the origin and at y 70 and y 65: the one at y 65 is chosen.

**E7. Timing (computed).** A default-rule survival player stands in a portal: process created on tick 0 (flag true, time 0); `baseTick` 1: old 0, time 1, 0 >= 80 false; ... `baseTick` 81: old 80 >= 80 true: the cooldown 10 is set and the transfer starts. Leaving after 30 ticks: time 30 decays by 4 per tick: gone after 8 ticks (`30 - 32 < 0`). A creative player (rule value 0) transfers on `baseTick` 1.

**E8. The eight-eye ring (computed).** Frames in a ring spanning x 10..14, z 20..24 at y 64 (corners absent or anything), each side's three frames facing inward with eyes. Whichever frame receives the last eye, `find` returns the front-top-left candidate (14, 64, 24) with forwards = down and up = south; `corner = (14, 64, 24) + (-3, 0, -3) = (11, 64, 21)`; the cells x 11..13, z 21..23 at y 64 become `end_portal` (any block there is destroyed with drops first); global event 1038 at (12, 64, 22).

**E9. Largest rectangle (computed).** Portal blocks of one axis at x 10..11, y 65..67 and a stray portal block at (12, 65), `pos` = (11, 66): the horizontal limit from `pos`'s row stops at x 11 on the right (the cell (12, 66) is not a portal block) and at x 10 on the left, so the stray block is never part of a column; the result is `minCorner` (10, 65), 2 by 3 (area 6), with and without the stray block.

**E10. End entry (computed arithmetic).** A player at yaw 135 and pitch 20 with velocity (0.3, 0, 0) enters an end portal in the Overworld: arrival position (100.5, 49.0, 0.5); yaw 90 (absolute); pitch 20 + 0 = 20 (relative, clamped); velocity rotated about Y by `135 - 90 = 45` degrees: `x' = 0.3 cos 45 = 0.2121`, `z' = -0.3 sin 45 = -0.2121`; the platform at x 98..102, z -2..2 is rebuilt first.

## 11. Validation

| # | Check | Expected |
|---|---|---|
| V1 | `PortalShape` on E1 | valid, width 2, height 3, empty; 6 portal blocks created, axis X, flags 18 |
| V2 | Interior sizes 1 x 3, 2 x 2, 22 x 3, 2 x 22 | no shape in each case |
| V3 | Frame corners removed | still a shape (corners are not examined) |
| V4 | Frame with a non-obsidian block replaced in the top row | no shape; with the tag changed by a data pack the new member works |
| V5 | A portal block's neighbour changes across the plane (perpendicular horizontal axis) | the block stays |
| V6 | Remove one frame block of a lit portal | blocks adjacent in the plane become air one after another (each update fails `isComplete`), the rest of the plane follows |
| V7 | Fire placed in the End, or in any dimension other than Overworld and Nether, inside a frame | no portal |
| V8 | Survival player in a portal with the default delay | transfer on the 81st `baseTick`; creative player on the 1st |
| V9 | Player stays in the portal after arriving | no second transfer while the entity keeps touching the portal (cooldown re-armed to 10 each tick, 2.2 step 1) and none for 10 ticks after leaving |
| V10 | Non-player entities (items, mobs) | transfer on the first tick, cooldown 300; a projectile 2; a boat 10 |
| V11 | Rule `allow_entering_nether_using_portals` false | portal entry into the Nether does nothing (cooldown is still set), exit from the Nether works |
| V12 | Coordinates E3 | origins (-38, 70, 125) and (100, 70, -26) |
| V13 | Existing portal 5 blocks away in the destination | found (radius 16 for the Nether destination, 128 for the Overworld one); the closest by `distSqr`, ties to the lower y |
| V14 | No portal within the radius, open ground | a 4 x 5 frame is created with the 2 x 3 interior, at the nearest spiral column with a free slab and solid floor; platform only in the no-position case |
| V15 | Destination border excludes every column | creation fails, logs the error, the entity stays, cooldown set |
| V16 | Axis change X to Z (E4) | position (100.3, 70.5, -4.1), yaw + 90, velocity rotated by -90 degrees |
| V17 | Spectator with no destination portal | no portal is created |
| V18 | Cross-dimension player teleport | the packet order of 8.1: Respawn (keep 3), Change Difficulty, permission, Player Position (new id, relative flags as the transition), chunk stream, Abilities, Initialize Border, Set Time, Set Default Spawn Position, [weather], Game Event 13, container content, Held Slot, effects, post effects, Level Event 1032 (portals), then Set Experience and Set Health on the next tick |
| V19 | Items, XP, health, hunger, effects, abilities, game mode of a player after a portal trip | unchanged; no new ServerPlayer object |
| V20 | First end portal use after the dragon with `seenCredits` false | player removed, Game Event 4; on Client Command PERFORM_RESPAWN a respawn with keepAll: anchor charge unchanged, Respawn data-to-keep 1, health, food, XP, effects kept; order on the wire: Player Abilities, one Update Mob Effect per effect with blend true, Respawn, Player Position, ..., Update Mob Effect per effect with blend false |
| V21 | Second end portal use in the End | player arrives at its respawn point with absolute rotation, no sound, no ticket |
| V22 | End portal entry | platform rebuilt every time; player at (100.5, 49.0, 0.5), yaw 90; others at (100.5, 50.0, 0.5) |
| V23 | Eye in the last frame of a ring (E8) | 3 x 3 end portal blocks, global event 1038 |
| V24 | Eye in a frame of an incomplete ring | frame filled (eye true, event 1503), no portal |
| V25 | A rider enters a portal | only the vehicle enters; the passengers are carried with relative offsets; a rider whose vehicle goes End to Overworld with a player who has not seen the credits blocks the transfer |
| V26 | Gateway use | same-level move, no sound, ticket only, gateway cooldown 40; a pearl gets absolute zero rotation |

## 12. Open questions

1. **POI iteration order for exact ties.** `Stream.min` keeps the first of equal elements (distance squared and y equal); the order of the POI stream (chunk iteration of `ChunkPos.rangeClosed` and per-section record order) was not decoded.
2. **Box order in `findFreePosition`.** The lambdas that turn the inflated boxes into shapes and union them were read as map and reduce; the box iteration order of `VoxelShape.forAllBoxes` (which decides the winner among equally near boxes in `closestPointTo`, strict `<`) was not decoded.
3. **Forget Level Chunk after Respawn.** Whether the vanilla server really sends Forget Level Chunk packets for the old view after the Respawn packet (from `applyChunkTrackingView` being called with the old level while removing the player) was derived from the call order, not observed; a server may omit them because the client has discarded its old level.
4. **Credits runnable.** The client's `WinScreen` callback (send `PERFORM_RESPAWN`, clear the screen) was identified as the only method in the class that builds that packet; the `WinScreen` flags (the boolean passed) and the credits text are client presentation not read.
5. **Sound event names.** `PORTAL_TRAVEL`, `PORTAL_TRIGGER`, `PORTAL_AMBIENT`, `END_PORTAL_SPAWN`, `END_PORTAL_FRAME_FILL` are field names of `SoundEvents`; their registry strings are data (the sound registry and the resource pack, 08).
6. **`BlockState.isSolid` and `canBeReplaced`.** Both are block-registry properties (24); the per-block values are data of the registry round, not tabulated here.
7. **Overlay rendering.** The client portal overlay drawing and the nausea-wobble (`tickSpinningEffect`) numbers beyond the intensity update of section 9 were not read.
8. **37 section 6.3 wording** (section 1.3 here) disagrees with the bytecode for sources other than the Overworld and the Nether; 37 needs the one-line correction.
9. **Spawn-time portal state of freshly created entities.** `EntityType.create` with `DIMENSION_TRAVEL` followed by `restoreFrom` is read as in 6.6; the per-entity-type `load` overrides (what an entity type refuses to keep) belong to the NBT round (45).
10. **Ender pearl, chorus fruit and command teleports** share the transition model (6.1) but their own constraints are in 17 and 16; only the portal-related checks (`canUsePortal` on the owner, the pearl cooldown) were noted here.
11. **Voxel-walk order of the inside-block sweep.** Section 2.2a gives the set of cells and the touch tests; the exact visiting order of the voxel walk inside one leg (`BlockGetter.forEachBlockIntersectedBetween`, `addCollisionsAlongTravel`) was read only as far as its structure (cells at the start, along the travel, at the end; at most 16 steps) and is irrelevant to the portal blocks, which only set a flag, but it could matter for other block effects.
12. **Server-side interpolation target.** Section 6.3 says that a server entity's `getClientPositionAndRotation` returns the live values because no server code starts an interpolation. This was inferred from the absence of such a call in `ServerPlayer` and `LivingEntity`, not from decoding every caller of `InterpolationHandler.interpolateTo`.
13. **Sweep position of non-living entities.** The classes that call `applyEffectsFromBlocks` besides `LivingEntity` are listed in 2.2a by name; their order against `handlePortal` inside each `tick` override was not decoded.
14. **Chunk ring beyond the full ring.** `ChunkLevel.RADIUS_AROUND_FULL_CHUNK` (the partial-status ring around a ticket) was not computed from the generation pyramid (searched `ChunkLevel`, `ChunkDependencies`; the value comes from `ChunkPyramid`).
