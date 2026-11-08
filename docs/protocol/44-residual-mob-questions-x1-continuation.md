# 44 — Residual mob questions, continuation x1 (round RS26)

| Item | Value |
|---|---|
| Covers | A partial continuation over the residual open questions of 18 to 21 and 44-1 to 44-9. It does not answer the full scope: the items it leaves open are listed by document and number in Open question 1. It (a) records which listed items were already closed by an earlier document (so nobody re-reads them), (b) answers the per-block entity effects of 44-1 Open question 2 (honey block, powder snow, bubble column, campfire), (c) records the `Mob.finalizeSpawn` defaults, (d) specifies `PatrollingMonster` and its long-distance patrol goal, (e) specifies the sensors `AdultSensorAnyType` and `IsInWaterSensor` and the goal `NearestHealableRaiderTargetGoal`, and (f) adds the vex movement control and copy-owner goal and the witch cooldown call site that 20 left open |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) with no execution. A statement is read from the artifact unless it is marked "(inferred)" or "(recalled, not verified)", or names an open question. Nothing here is marked recalled. |
| Data versus code | Per the operator decisions (design README Part 0, rule R7), data (tags, loot tables, structure NBT, JSON) is not tabulated. The tag names that the engines below read are named, not listed. Block behaviours, goals and sensors are code and are specified here. |
| Related | Mob framework [18](18-mob-framework.md) (section 4.3 already contains the full `TargetingConditions.test` order); hostile mobs [20](20-mobs-overworld-hostile.md) (zombie 20 section 4, witch 20 section 11, phantom 20 section 12, vex 20 section 13.4, raiders 20 section 13); [44-1](44-residual-mob-questions-1-shared-model-framework.md) (inside-block effect engine 44-1 section 4.3, block data 44-1 section 4.4, RQ-1.9, RQ-1.30); [44-3](44-residual-mob-questions-3-villagers-poi-raids.md) (village siege 44-3 section 1.7); block registry [24-7](24-block-registry-7-stairs-slabs-walls-workstations.md) (bubble column 24-7 section 5.2); [44-5](44-residual-mob-questions-5-overworld-hostile.md). Nothing from those is repeated except where this document corrects or sharpens it. |

## 1. Dispositions of items that the scope names

This section states, for every scope item that was checked, whether it is closed elsewhere. Items not covered by this document are listed in Open question 1.

| Item | Disposition |
|---|---|
| `TargetingConditions.test` clause list (44-6 Open q1, 44-7 Open q3) | Already complete in 18 section 4.3 (seven rules, in order). Re-read here against `TargetingConditions.test`: the order and constants (2.0 minimum range, `canBeSeenByAnyone`, `canBeSeenAsEnemy`, difficulty Peaceful test, `canAttack`/`isAlliedTo`, range times visibility, line of sight for `Mob` attackers) agree. Closed. The only position question that remains is where a caller places it relative to its own filters, which is per caller. |
| `Zombie.handleAttributes` bonus rolls (44-1 Open q4) | Already complete in 20 section 4.1 step 7. Re-read: it agrees. The reinforcement charge modifiers are also already in 20 section 4.1 (section 4 of this document is only a pointer). Closed. |
| `Creeper` swell goal | Already in 20 (creeper table and the swell goal paragraph). Re-read: agrees. |
| Phantom attack strategy, sweep, circle goals | Already in 20 section 12, including the full `PhantomMoveControl.tick` (20 section 12, Move control) (marked closed there). Re-read: agrees with every constant. Section 6.1 only adds the attack-player goal `canContinueToUse`. |
| Vex charge, random move, copy-owner goals | Charge and random move are in 20 section 13.4. Section 6.2 adds the move control and the copy-owner goal. |
| `VillageSiege` and `roll_village_siege` period | Already in 44-3 section 1.7 (marker at tick 18000 of a 24000-tick timeline, one in ten, 10 setup attempts, 32 blocks, 20 zombies, spawn interval 2). Re-read: the bytecode agrees. Closed. |
| `GossipContainer`, `ReputationEventType` rules (44-3 Open q20) | Already in 19 section 22.5 (44-3 only did not re-read them). Not re-read here. |
| `AdultSensorAnyType`, `DummySensor`, `IsInWaterSensor`, `NearestHealableRaiderTargetGoal` | `nearest_adult_any_type` and `is_in_water`: section 5.1. `dummy`: already in 44-1 RQ-1.30 (cont.). `nearest_adult`: 18 section 4.12. `NearestHealableRaiderTargetGoal` and the witch cooldown call site: section 5.2. |
| Per-block entity effects: honey, powder snow, bubble column, campfire (44-1 Open q2) | Answered: section 2 (portals and soul sand: section 2.5). |
| Quick Charge arithmetic (20 Open q10) | Already closed in 17 section 3.9 (Charge time bullet) and 17 section 6.3 (25, 20, 15, 10 ticks for levels 0 to 3: 1.25 s base minus 0.25 s per level, `floor(20 x duration)`). Not repeated. |

## 2. Per-block entity effects

These blocks request effects through the engine of 44-1 section 4.3 (`entityInside`, `fallOn`, collision shape). The callers in this section are all server and client symmetric unless said otherwise. "Delta" is the entity's velocity (`getDeltaMovement`). **(B)** marks values read from the named class.

### 2.1 Honey block (`HoneyBlock`)

The block shape (`HoneyBlock.SHAPE`, also its collision shape) is a column with a 14 x 14 footprint (inset 1/16 on each side) and a height of 15/16. That is why the sliding test below uses 0.9375 (15/16) and 0.4375 (7/16, half of 14/16). 44-1 section 4.4 (RQ-1.9) gives friction 0.6, speed factor 0.4, jump factor 0.5.

Two helper functions convert a vertical velocity between "before gravity and drag of this tick" and "after":

| Name | Formula (constants read) |
|---|---|
| `oldDeltaY(v)` | `v / 0.98 + 0.08` (0.98 is stored as the float-widened 0.9800000190734863) |
| `newDeltaY(v)` | `(v - 0.08) * 0.98` |

**Is sliding** (`isSlidingDown(pos, entity)`), all of the following must hold:
1. the entity is not on the ground;
2. `entity.y <= pos.y + 0.9375 - 1.0E-7` (the entity's feet are below the top 1/16 of the block, i.e. it is against the side, not on top);
3. `oldDeltaY(delta.y) >= -0.08` is **false**, that is `oldDeltaY(delta.y) < -0.08` (the entity is really falling, not hovering);
4. at least one horizontal offset is large: with `dx = |pos.x + 0.5 - entity.x|`, `dz = |pos.z + 0.5 - entity.z|` and `limit = 0.4375 + width / 2` (`getBbWidth`), either `dx + 1.0E-7 > limit` or `dz + 1.0E-7 > limit` (the entity overlaps the block's cell only by the edge).

**Effect per tick when inside the block** (`entityInside`): if sliding: (a) when the entity is a server player and `gameTime % 20 == 0`, fire the advancement trigger `honey_block_slide` with the block state; (b) slide movement; (c) slide effects. The base `HalfTransparentBlock.entityInside` is then called (no extra effect is added by this class).

**Slide movement** (`doSlideMovement`): let `o = oldDeltaY(delta.y)`.
- if `o < -0.13`: `k = -0.05 / o`; the new delta is `(delta.x * k, newDeltaY(-0.05), delta.z * k)`, which slows the horizontal velocity by the same ratio as the vertical one is clamped;
- otherwise the new delta is `(delta.x, newDeltaY(-0.05), delta.z)`.
Then `resetFallDistance`. `newDeltaY(-0.05) = (-0.05 - 0.08) * 0.98 = -0.1274` (computed).

**Slide effects** (`maybeDoSlideEffects`), only for entities that are a `LivingEntity`, an `AbstractMinecart`, a `PrimedTnt` or an `AbstractBoat`: with probability 1/5 (`nextInt(5) == 0`) play `honey_block_slide` (volume 1, pitch 1) on the entity; on the server, a second independent 1/5 draw broadcasts entity event 53 (client: slide particles, 5 honey block particles, via `showSlideParticles`). Jump particles (10 particles) use the same helper with count 10 (`showJumpParticles`; entity event 54 is the landing one).

**Landing** (`fallOn(level, state, pos, entity, fallDistance)`): play `honey_block_slide` (volume 1, pitch 1) on the entity; on the server broadcast entity event 54 (10 particles); call `causeFallDamage(fallDistance, 0.2, fall damage source)` (damage multiplier 0.2); if that returned true (damage was applied) also play the block's sound-type fall sound at volume `soundType.volume * 0.5` and pitch `soundType.pitch * 0.75`.

Worked examples:
1. An entity (delta.y = -0.5) hugging the side of a honey block: `o = -0.5/0.98 + 0.08 = -0.4302`; it is below -0.13, so `k = -0.05 / -0.4302 = 0.1162`; horizontal velocity is multiplied by 0.1162 and `delta.y` becomes -0.1274.
2. delta.y = -0.2: `o = -0.1241`; sliding requires `o < -0.08` (true) and the clamp branch does not apply (`o >= -0.13`): `delta.y` becomes -0.1274 and horizontal velocity is unchanged.
3. delta.y = -0.05: `o = 0.0290`, not below -0.08: no slide.

### 2.2 Powder snow (`PowderSnowBlock`)

| Behaviour | Rule (read) |
|---|---|
| Stuck | `entityInside`: the stuck branch runs when the entity is **not** a `LivingEntity`, **or** when it is a `LivingEntity` whose in-block state is this block (only a living entity whose in-block state is something else skips it): `makeStuckInBlock(state, (0.9, 1.5, 0.9))`, where 0.9 is the double 0.8999999761581421 (float 0.9 widened). The `FREEZE` and `EXTINGUISH` effects (row Effects) run after the branch in every case. (`makeStuckInBlock` resets the fall distance and stores a velocity multiplier; `Entity.move` multiplies the movement vector componentwise by it once and then zeroes the stored multiplier and the delta, unless the move type is PISTON; the multiplier is only applied when its squared length exceeds 1.0E-7.) The multiplier 1.5 on y is the climbing speed: an upward movement is 1.5 times, a falling one is also 1.5 times. |
| Particles (server only) | In the same branch on a `ServerLevel`: with a 50 percent draw (`nextBoolean`) and when the entity's known movement has a non-zero x or z: send 1 `snowflake` particle at `(entity.x, pos.y + 1, entity.z)` with the speed spread `randomBetween(-1, 1) * 0.083333336` on x and z and 0.05000000074505806 (float 0.05 widened) on y (`ALTERNATIVE` randomization). |
| Effects | Always (after the stuck branch): register a "before EXTINGUISH" callback, then request `FREEZE` and `EXTINGUISH` (44-1 section 4.3). The callback: on a `ServerLevel`, if the entity is on fire **and** (game rule `mob_griefing` is true **or** the entity is a `Player`) **and** `entity.mayInteract(level, pos)`: destroy the powder snow block without drops (`destroyBlock(pos, false)`). |
| Landing | `fallOn(..., fallDistance)`: nothing when `fallDistance < 4.0` or the entity is not living; otherwise play the living entity's fall sound `small` when `fallDistance < 7.0`, else `big` (volume 1, pitch 1). `fallOn` does not call the superclass method and never calls `causeFallDamage`, so the block itself never deals fall damage. Non-living entities never reach the sound path. |
| Collision | `getCollisionShape(context)`: for an entity context (not placement) with a non-null entity: **if `entity.fallDistance > 2.5`**: the "falling" shape, a box `(0,0,0)-(1,0.9,1)`; **else if** the entity is a `FallingBlockEntity`, or `canEntityWalkOnPowderSnow(entity)` **and** the context says the entity is above a full-block shape at this position (`isAbove(Shapes.block(), pos, false)`) **and** the entity is not descending (not sneaking down): the block's normal collision shape; **otherwise the empty shape** (the entity sinks in). Placement contexts and entity-less contexts get the empty shape. |
| Who can walk on it | `canEntityWalkOnPowderSnow(entity)`: true when the entity type is in tag `powder_snow_walkable_mobs`; else, for a `LivingEntity`, true exactly when its FEET slot item is `leather_boots`; else false. |
| Inside-block box | `getEntityInsideCollisionShape`: the entity-context collision shape (row Collision) when it is not empty, else the full block `Shapes.block()`; so for a sinking entity the inside-block effect box is the whole cell. |
| Other | `getVisualShape` is empty; `isPathfindable` is true; `skipRendering` is true when the neighbour is the same block (else the base rule); the pickup sound is `BUCKET_FILL_POWDER_SNOW`. |
| Pickup | `pickupBlock`: set the block to air (flags 11), on the server broadcast level event 2001 (block break) with the old block state id, return one `powder_snow_bucket`. |

Frozen-tick handling itself (`FREEZE`, `CLEAR_FREEZE`, thaw rate) is the 44-1 section 4.3 and 18 section 2.5 text; it is not repeated.

### 2.3 Bubble column (`BubbleColumnBlock`)

The block has the boolean property `drag_down`, holds the water source fluid (`getFluidState` returns the full water source) and is a column that sits on top of a "source" block.

| Item | Rule (read) |
|---|---|
| Source blocks | Block tags `enables_bubble_column_push_up` (column pushes up: `drag_down = false`) and `enables_bubble_column_drag_down` (`drag_down = true`). `canSurvive`: the block below is a bubble column, or in either tag. |
| `canOccupy(block)` | A position can hold a column when its block state is already a bubble column, **or** its fluid is in fluid tag `bubble_column_can_occupy` **and** the block is a `LiquidBlock` **and** the fluid is a source with amount >= 8 (a full water source cell; waterlogged blocks do not qualify). |
| `getColumnState(block, below, current)` | Branches in order: (1) `below` is already a bubble column: return `below`; (2) `below` is in tag `enables_bubble_column_push_up`: the column with `drag_down = false`; (3) `below` is in tag `enables_bubble_column_drag_down`: the column with `drag_down = true`; (4) `current` (the state at the position being updated) is a bubble column: the plain water default state; (5) otherwise `current` is returned unchanged. The default state of the block has `drag_down = true` (constructor). This agrees with 24-7 section 5.2 and closes 24-7 Open question 2 (argument order). |
| `updateColumn(block, level, pos, current, below)` | Calls `canOccupy` on `current` (stop if false), then `getColumnState(block, below, current)`. Places that state at `pos` with flag 2, then walk upward cell by cell: while the cell above can be occupied, place the same state there with flag 2; stop at the first cell that cannot be occupied or when a `setBlock` fails. |
| Tick | `tick` calls `updateColumn` with `(state, state of the cell below)`. |
| Shape updates | `updateShape`: always schedules a water fluid tick (delay = water tick delay). If the block cannot survive, or the update comes from DOWN, or the update comes from UP and the neighbour is not already a bubble column and could be occupied: schedule a block tick in **5** ticks. |
| Entity effect | `entityInside` has a sixth parameter, a boolean, and the whole effect is skipped when it is false (both calls below are inside this guard). When true: let `aboveFree` = the block above has an empty collision shape **and** an empty fluid state (air-like). If `aboveFree`: `entity.onAboveBubbleColumn(dragDown, pos)`; else `entity.onInsideBubbleColumn(dragDown)`. Both entity handlers act only when `canSimulateMovement()` (client for the player, server for others). |
| Above the column (`handleOnAboveBubbleColumn`) | `delta.y = dragDown ? max(-0.9, delta.y - 0.03) : min(1.8, delta.y + 0.1)`; x and z unchanged; then bubble-column surface particles. |
| Inside the column (`handleOnInsideBubbleColumn`) | `delta.y = dragDown ? max(-0.3, delta.y - 0.03) : min(0.7, delta.y + 0.06)`; x and z unchanged; then `resetFallDistance`. |

Worked examples (velocity arithmetic only; they ignore the per-tick gravity and drag that are applied around these steps, so real tick counts are larger): an item or mob inside an upward column starting at `delta.y = 0` gains 0.06 per tick and reaches the 0.7 cap on the 12th tick (12 x 0.06 = 0.72, capped); above an upward column it gains 0.1 per tick and reaches 1.8 on the 18th tick. In a downward column it loses 0.03 per tick and reaches -0.3 on the 10th tick; above the column it reaches -0.9 on the 30th tick.

### 2.4 Campfire (`CampfireBlock`)

`new CampfireBlock(spawnParticles, fireDamage, properties)`: the registry (`Blocks`) builds `campfire` with `(true, 1)` and `soul_campfire` with `(false, 2)` (the lambdas `lambda$static$329` (true, 1) and `$330` (false, 2) are read; assigning 329 to `campfire` and 330 to `soul_campfire` rests on bootstrap-method order, not on a name string (inferred)). Effect: `entityInside`, when `lit` is true and the entity is a `LivingEntity`: `entity.hurt(campfire damage source, fireDamage)` (1.0 for a normal campfire, 2.0 for a soul campfire), every tick the entity is in the cell; then the base class effect. No fire-immunity check was found in this method (damage types may still be immune through the damage-type tags, 18 section 2.5). Ambient (client only): when lit, a 1/10 draw plays `campfire_crackle` (volume `0.5 + nextFloat`, pitch `0.6 + nextFloat * 0.7`); when the block spawns particles, a 1/5 draw spawns 1 `lava` particle (the count is `nextInt(1) + 1`, always 1); particle detail is client rendering.

Other fire-damage constants (magma block 1.0 `hot_floor` on `stepOn` unless sneaking; cactus 1.0; sweet berry bush 1.0 with the 0.003 movement threshold and stuck multiplier `(0.8, 0.75, 0.8)` except for foxes and bees; cobweb stuck `(0.25, 0.05, 0.25)` and `(0.5, 0.25, 0.5)` for an entity with the `weaving` effect) were re-read and agree with 18 section 3.3; the web value for weaving is: **the cobweb multiplier is `(0.5, 0.25, 0.5)` when the living entity has the Weaving effect** (read from `WebBlock.entityInside`). Soul sand has no `entityInside` override (section 2.5).

### 2.5 Portals and soul sand (44-1 Open question 2, remainder)

| Block | Rule (read) |
|---|---|
| `NetherPortalBlock.entityInside` | If `entity.canUsePortal(false)`: `entity.setAsInsidePortal(this, pos)`. Nothing else. |
| `EndPortalBlock.entityInside` | If `entity.canUsePortal(false)`: when the level is the server (not client), its dimension is the End and the entity is a `ServerPlayer` whose `seenCredits` is false: `showEndCredits()`; in every other case `entity.setAsInsidePortal(this, pos)`. |
| `SoulSandBlock` | No `entityInside`. Collision shape `column(16, 0, 14)` (full footprint, height 14/16); `getBlockSupportShape` and `getVisualShape` return the full block; `isPathfindable` is false; `getShadeBrightness` is 0.2; speed factor 0.4 comes from block properties (44-1 section 4.4). |

## 3. `Mob.finalizeSpawn` defaults

Every `Mob` subclass that calls `super.finalizeSpawn` gets these two steps (read in `Mob.finalizeSpawn`):
1. If the entity's `follow_range` attribute does not yet have the modifier `random_spawn_bonus`, add it permanently as an `ADD_MULTIPLIED_BASE` modifier whose amount is `random.triangle(0.0, 0.11485000000000001)` (triangle distribution: mean 0, half-width 0.11485).
2. `setLeftHanded(random.nextFloat() < 0.05)`.
The `RANDOM_SPAWN_BONUS_ID` identifier is also used by `Zombie.handleAttributes` (a different attribute and operation: knockback resistance, `ADD_VALUE`, 20 section 4.1 step 7).

## 4. Zombie finalize details

Nothing here is additional to 20 section 4.1. Steps 1 to 7 of 20 section 4.1 already give the loot-pickup chance `0.55 x multiplier`, the baby chance 0.05, the chicken jockey, the baby speed modifier (+0.5, `ADD_MULTIPLIED_BASE`), door breaking `0.1 x multiplier`, the Hard 0.05 / 0.01 equipment roll with `nextInt(6)` (sword, spear, shovel) and the Halloween pumpkin; its Reinforcements paragraph gives `reinforcement_caller_charge`, `reinforcement_callee_charge` (0.05 steps) and the 50-attempt position search. Two re-reads sharpen it:
- Jockey structure (read from the branch layout): the jockey branch also requires the group data to be a baby and its `canSpawnJockey` flag. A first draw `< 0.05` (float compared as double with 0.05) searches for an un-ridden `Chicken` in the box inflated by (5, 3, 5); if the list is non-empty the first chicken becomes a chicken jockey and the zombie rides it; if the list is empty **nothing further happens** (no second draw). Only when the first draw is `>= 0.05` is a second independent draw taken; if it is `< 0.05` a new chicken is created with spawn reason JOCKEY, placed at the zombie's x, y, z and yaw with pitch 0, finalized with reason JOCKEY and no group data, marked chicken jockey, ridden by the zombie (`startRiding(chicken, false, false)`) and added to the world. This agrees with 20 section 4.1 step 2.
- Precision: the callee modifier amount is the float `-0.05f` widened to a double, -0.05000000074505806; the zombie knockback bonus factor in `handleAttributes` is likewise 0.05000000074505806.

## 5. Sensors and goals not yet described

### 5.1 Sensors

All sensors run `doTick` every `scanRate` ticks (default 20, 18 section 4.12). `nearest_adult` is in 18 section 4.12 and `dummy` is in 44-1 RQ-1.30 (cont.); neither is repeated.

| Sensor | Requires memories | Behaviour |
|---|---|---|
| `AdultSensorAnyType` (`nearest_adult_any_type`) | same as `AdultSensor`: `nearest_visible_adult`, `nearest_visible_living_entities` | The class extends `AdultSensor` and inherits its requires set and its `doTick`; it overrides only the match. It therefore writes `nearest_visible_adult`, not a separate memory, even though the registry name is `nearest_adult_any_type`. The match is "entity is in entity type tag `followable_friendly_mobs` and is not a baby" (any species in the tag qualifies), taking the closest such entity (`NearestVisibleLivingEntities.findClosest`); the memory is set to the result (empty when none). |
| `IsInWaterSensor` (`is_in_water`) | `is_in_water` | Each scan: if `entity.isInWater()` set memory `is_in_water` to the unit value; else erase it. |

### 5.2 `NearestHealableRaiderTargetGoal` (witch)

Extends `NearestAttackableTargetGoal` with random interval **500**, must-see as passed by the witch, must-reach false and the supplied selector. `Witch.registerGoals` passes the target class `Raider`, must-see **true** (read as the constant 1 in the constructor call; agrees with 20 section 11) and a selector that accepts an entity only when the witch has an active raid and the entity is not a witch. It adds a `cooldown` counter (starts 0).

| Method | Rule |
|---|---|
| `canUse` | `false` when `cooldown > 0` (the counter is decremented by `decrementCooldown()` from `Witch.aiStep`, below) or when `random.nextBoolean()` is false; `false` when the owner (a `Raider`) has no active raid; otherwise run `findTarget()` (nearest entity of the configured class within the search box, filtered by the goal's conditions) and return true when a target was found. |
| `start` | `cooldown = reducedTickDelay(200)` (200 ticks in normal speed), then the base `start` (set the target). |

**Witch tick call site** (`Witch.aiStep`, only when not client-side and the witch is alive): every tick it calls `healRaidersGoal.decrementCooldown()`, then sets the player-target goal's `canAttack` (`NearestAttackableWitchTargetGoal.setCanAttack`) to true when the cooldown is 0 or less and to false when it is above 0. The cooldown therefore gates the player-target goal as well as the raider-heal goal (20 section 11 states the same).

Notes: the randomness is a coin flip per evaluation, so the effective check rate is half the goal selector's rate; the 500 random interval of the base class is bypassed because `canUse` is overridden.

## 6. Movement controls that earlier parts left open

### 6.1 Phantom

| Item | Rule (read) |
|---|---|
| Attack-player target goal (`PhantomAttackPlayerTargetGoal`) | Targeting condition: `forCombat().range(64.0)`. Scan timer `nextScanTick` starts at `reducedTickDelay(20)`. `canUse`: while the timer is above 0, decrement it and return false. Otherwise reset the timer to `reducedTickDelay(60)`, list the nearby players (targeting conditions above, within the phantom's box inflated by `(16, 64, 16)`), sort them by **Y descending** (`Comparator.comparing(Entity::getY).reversed()`), and take the first one that passes `phantom.canAttack(level, player, TargetingConditions.DEFAULT)`: set it as the target and return true. |
| Move target base (`PhantomMoveTargetGoal`) | Flag MOVE. `touchingTarget()` = squared distance from the phantom to `moveTargetPoint` is below **4.0**. |
| Move control | The whole of `PhantomMoveControl.tick` (initial speed 0.1, the turn, the 3.0-degree speed branch, the vertical compression and the velocity assembly) is in 20 section 12, Move control; re-read here and it agrees. Read here: the 1.8 / 0.2 branch tests `degreesDifferenceAbs(yaw before the turn, yaw after the turn) < 3.0`, and 0.7 is the float 0.7f widened (0.699999988079071). |
| Attack-player target goal, `canContinueToUse` | `canAttack(target, TargetingConditions.DEFAULT)` on the current target; false when there is no target. |

### 6.2 Vex

`VexMoveControl.tick` (only when the operation is MOVE_TO): let `v = wanted - position` and `len = |v|`.
- if `len < boundingBox.getSize()` (the mean edge length of its box): operation becomes WAIT and the velocity is multiplied by **0.5**;
- else: `delta += v / len * (speedModifier * 0.05)`; then, with no target, the yaw is set to `-atan2(delta.x, delta.z) * 57.295776` (the facing follows the velocity); with a target, the yaw is `-atan2(target.x - x, target.z - z) * 57.295776` (the facing follows the target); in both cases `yBodyRot = yRot`.
`VexCopyOwnerTargetGoal` (a `TargetGoal` built with must-see false): `copyOwnerTargeting = TargetingConditions.forNonCombat().ignoreLineOfSight().ignoreInvisibilityTesting()`. `canUse` is true when the owner is a `Targeting` with a non-null target and `canAttack(target, copyOwnerTargeting)` holds; `start` sets the vex's target to the owner's target (null when the owner is not a `Targeting`) and then runs `TargetGoal.start`. The conditions are evaluated by 18 section 4.3.

### 6.3 Patrol goal of raiders and patrol groups (`PatrollingMonster`)

State saved by name: `patrol_target` (a block position, stored nullable), `PatrolLeader`, `Patrolling` (booleans, default false). Runtime: `patrolLeader`, `patrolling`, `patrolTarget`.

| Item | Rule (read) |
|---|---|
| Goal | priority 4 `LongDistancePatrolGoal(mob, speedModifier = 0.7, leaderSpeedModifier = 0.595)`, flag MOVE. Cooldown `cooldownUntil` starts -1. |
| `canUse` | `gameTime >= cooldownUntil` (a time compare against the cooldown), and the mob is patrolling, has no target, has no controlling passenger, and has a patrol target. |
| `finalizeSpawn` | Unless the reason is PATROL, EVENT or STRUCTURE: `nextFloat < 0.06` and `canBeLeader()` makes it the patrol leader. A leader wears the **ominous banner** on the head (`Raid.getOminousBannerInstance` built from the banner pattern registry) with a head drop chance of **2.0**. With reason PATROL the mob is `patrolling = true`. Then the base spawn. |
| `canJoinPatrol`, `canBeLeader` | `PatrollingMonster.canJoinPatrol` is true; `Raider` overrides it to `!hasActiveRaid()` (pillagers and the illagers do not override it again). `canBeLeader` defaults to true; `Witch` and `Ravager` override it to false. |
| `removeWhenFarAway(d2)` | `!patrolling || d2 > 16384.0` (128 blocks). |
| `findPatrolTarget` | `patrolTarget = blockPosition + (-500 + nextInt(1000), 0, -500 + nextInt(1000))` and `patrolling = true`. |
| `setPatrolTarget(pos)` and `setPatrolLeader(b)` | both also set `patrolling = true`. |
| Spawn rules | `checkPatrollingMonsterSpawnRules`: false when the block light at the position is above **8**; otherwise the any-light monster rule. |
| `start`, `stop` | Both do nothing. |
| `findPatrolCompanions` | All `PatrollingMonster`s with `canJoinPatrol` true, other than the mob itself, in the mob's bounding box inflated by 16. |
| Tick (every `tick` of the goal) | Runs only when the navigation is done. `leader = isPatrolLeader`; `companions` as above. (1) If `patrolling` and there are no companions: `patrolling = false`, stop. (2) If the mob is the leader and the patrol target is within 10.0 of its position (`closerToCenterThan`): `findPatrolTarget()` and stop. (3) Otherwise: let `tc` = the bottom centre of the patrol target block (x + 0.5, y, z + 0.5), `pos` the mob position and `d = pos - tc`. Then `tc2 = tc + 0.4 x yRot(d, 90.0)`, where `Vec3.yRot` takes **radians** (it feeds `Mth.cos` and `Mth.sin`, whose double argument is scaled by 10430.378...), so the angle is 90 radians, about 116.62 degrees after reduction (cos about -0.448, sin about +0.894), not 90 degrees; the rotation is `x' = x cos + z sin`, `z' = z cos - x sin`, y unchanged. The aim point is `pos + 10 x normalize(tc2 - pos)`; its block (`BlockPos.containing`) is moved to the `MOTION_BLOCKING_NO_LEAVES` heightmap position `aimBlock`. (4) `moveTo(aimBlock, leader ? leaderSpeedModifier : speedModifier)`. (5) If `moveTo` fails: pick a random point `(-8 + nextInt(16), 0, -8 + nextInt(16))` away from the mob's block, projected to the heightmap, walk there at `speedModifier`, and set `cooldownUntil = gameTime + 200`. (6) If `moveTo` succeeded and the mob is the leader: **every companion** gets `setPatrolTarget(aimBlock)` (which also sets its `patrolling` true): followers receive the rolling waypoint about 10 blocks ahead, not the leader's final patrol target. |

Worked example (computed with exact `cos`/`sin` of 90 radians; the table-based `Mth` functions differ in the last digits): a patrol leader at (0, 64, 0) with patrol target block (400, 64, 0). `tc = (400.5, 64, 0.5)`, `d = (-400.5, 0, -0.5)`; `yRot(d)` is about (179.0, 0, 358.3); `0.4 x` that is (71.6, 0, 143.3); `tc2` is about (472.1, 64, 143.8); `normalize(tc2 - pos)` is about (0.9566, 0, 0.2914); the aim point is about (9.57, 64, 2.91), block (9, y, 2) after the heightmap projection. The leader walks there at 0.595; companions within 16 blocks receive a patrol target near (9, y, 2), not (400, y, 0), and follow at 0.7. When the leader gets within 10 of its patrol target block it draws a new target within +/-500 on x and z.

## 7. Validation

| Check | Method | Result |
|---|---|---|
| Every constant in sections 2 to 6 | Re-read from the named class (patrol goal, zombie finalize, bubble column, honey, powder snow, portals, soul sand, vex goal, witch, sensors) | Read |
| Honey block formulas | Recomputed `newDeltaY(-0.05) = -0.1274` and the example ratios by hand | Consistent |
| Campfire constructor arguments | Matched bootstrap method 496 (campfire) to `lambda$static$329` (true, 1) and 497 (soul campfire) to `lambda$static$330` (false, 2) | Lambda arguments read; block-to-lambda assignment inferred from order |
| 20 section 4.1 step 7 (zombie attributes) | Compared with `Zombie.handleAttributes` | Agree |
| 20 phantom section and 44-3 section 1.7 (siege) | Compared with the bytecode | Agree |
| 18 section 4.3 (`TargetingConditions`) | Compared with `TargetingConditions.test` | Agree |
| Test vectors an implementer can use | Section 2.1 examples (ratios 0.1162 and -0.1274), section 2.3 (12, 18, 10 and 30 ticks, velocity arithmetic only), section 6.3 (aim point about (9.57, 64, 2.91)) | Given in text |

## Open questions

1. **Scope items not answered by this document.** Still open under their original numbers, by document and number: 18 Open q11 (spawn reasons and gates), q12 (projectiles: arrows, fireballs, wind charges), q17 (structure `spawn_overrides` replacement and piece-versus-full box semantics), q18 (`GateBehavior`, `TriggerGate`), q19 (`TryFindLand` and similar); 19 Open q11 (fox goals), q20 (sniffer), q22 (bee), q24 (iron golem `DefendVillageTarget`), q27 to q29 (villager `AcquirePoi`, `YieldJobSite`, `PoiCompetitorScan`, `ReactToBell`, `SocializeAtBell`, `TradeWithVillager`, `SetRaidStatus`; wandering trader `UseItem` and `WanderToPosition`); 20 Open q12 (structure spawns), q22 (warden `TryToSniff`, Digging, Emerging), q24 (sulfur cube attributes); 21 Open q4 (piglin `ChargeAttack`, `RamTarget`), q10 (nautilus `ChargeAttack`, tame bits), q11 (strider), q12 (dragon phases), q13 (area effect cloud `serverTick`, armor stand, item frame, painting, display, interaction, marker), q14 (boat and minecart physics), q19 (happy ghast: `HappyGhastFloatGoal`, `BabyFlyingPathNavigation`, growth, harness). Also open: 44-1 Open q10, q11, q12, q15, q17; 44-2 Open q2, q4, q14; 44-3 Open q2, q13, q15, q17, q21, q24 to q26, q28, q29; 44-4 Open q1, q6, q12, q16, q17 and the nested goal classes of sheep, cow, pig, chicken, mooshroom, ocelot, rabbit, cat, horse, camel, fox, panda, bee, allay, wolf, turtle, frog, tadpole and sniffer; 44-5 Open q3, q7, q15 and the warden, creaking and breeze pieces; 44-6 Open q2 to q12; 44-7 Open q1, q2, q5, q7 to q9; 44-8 Open q1, q2, q9 to q11, q14 to q19; 44-9 Open q1 to q5, q7. These need further rounds. Also still open and neither answered nor listed before: 18 Open q4 (trial spawner and custom spawners), q5 (tier-to-item equipment table), q6 (`ItemEntity` motion and merge), q7 (`extinguishFire` callers), q9 (per-block remainder such as `isValidSpawn` overrides), q10, q13 to q16; 19 Open q3, q27 to q29; 20 Open q27. Not covered at all: villager, raid, POI and wandering trader Brain classes, LongJump behaviours, dragon phases, boats, minecarts, area effect cloud, armor stand, item frame, painting, display, interaction, marker, happy ghast items. This round does not close the scope. Searched in this pass: only the classes named in sections 2 to 6.
2. **Campfire particle details.** The ambient particle loop count and velocities were read at the constant level only and are client rendering.
3. **Out of scope and still open** (as in the round statement): sound events and pitches (19 Open q3) and the entity-id check against a captured registry sync (needs a run).
