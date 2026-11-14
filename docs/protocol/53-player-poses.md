# 53. Player movement poses: standing, crouching, swimming (crawling), sprinting

| Item | Value |
|---|---|
| Covers | The player's movement poses (standing, crouching/sneaking, swimming and its on-land form crawling, sprinting as a state): the Pose enum and its wire form, dimensions and eye heights, the per-tick pose choice, the swimming flag, the sneak edge clamp, sneak and crawl speed, camera eye-height smoothing, the sprint field-of-view effect, swim movement, and what the server does with these states. Elytra (fall flying) and the spin attack are out of scope and appear only where a table needs them. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `Pose`, `Entity`, `EntityDimensions`, `LivingEntity`, `Avatar`, `Player`, `ServerPlayer`, `ServerGamePacketListenerImpl`, `LocalPlayer`, `AbstractClientPlayer`, `Camera`, `KeyboardInput`, `ByteBufCodecs`, `ServerEntity`, `ScaffoldingBlock`, `CollisionGetter`. |
| Extends | 13 §1 (movement, sprint), 12 §7 (model pose offsets), 18 §1.3, §1.4 and §4.3 (attributes, metadata, flags, visibility), 17 §4.9 (exhaustion), 46 §12.2 (Pose ids). It repeats nothing those documents say except as a cross-check; where this document disagrees with 13, it says so (§3.3, §6.1 and §9.3 corrections). |

All numbers are Java `float` unless stated; `1e-7` means `1.0E-7`. "Client" is the local player simulation (`LocalPlayer`),
"server" is `ServerPlayer`. Both run the same `Player.tick`, each on its own copy of the state.

---

## 1. The Pose enum (question 1)

`Pose` has 18 constants. The id is the explicit second constructor argument (it equals the ordinal here). Read from the
class initialiser.

| Id | Constant | Id | Constant |
|---|---|---|---|
| 0 | STANDING | 9 | USING_TONGUE |
| 1 | FALL_FLYING | 10 | SITTING |
| 2 | SLEEPING | 11 | ROARING |
| 3 | SWIMMING | 12 | SNIFFING |
| 4 | SPIN_ATTACK | 13 | EMERGING |
| 5 | CROUCHING | 14 | DIGGING |
| 6 | LONG_JUMPING | 15 | SLIDING |
| 7 | DYING | 16 | SHOOTING |
| 8 | CROAKING | 17 | INHALING |

(This agrees with the list in 46 §12.2.) The string names used by the data-driven codec are the lower-case constant names
(`standing`, `fall_flying`, ...).

**Wire form.** Entity metadata slot **6** of every entity (`Entity.DATA_POSE`), serializer **POSE** (id 20 in the table of
00 §13.2), default STANDING. The value is written as a single **VarInt** holding the id (`ByteBufCodecs.idMapper`, which
writes `VarInt.write(id)`). On reading, an id outside 0 to 17 decodes as id 0 (STANDING): the id map uses the strategy
`ZERO` (out-of-bounds gives the first element). A player only ever uses ids 0 (STANDING), 1 (FALL_FLYING), 2 (SLEEPING),
3 (SWIMMING), 4 (SPIN_ATTACK), 5 (CROUCHING) and 7 (DYING, set by `LivingEntity.die` after the death Entity Event 3, see
Open question 4).

Setting a different pose value marks the slot dirty on the server (sent with Set Entity Data, 18 §9.3, to the trackers and
to the player itself: `sendDirtyEntityData` uses "tracking players and self"). Whenever the value of slot 6 changes on an
entity (set locally or assigned from a packet), `onSyncedDataUpdated` calls `refreshDimensions` immediately (§2.3).

Shared-flag bits of slot 0 that this document uses (18 §1.4 has the whole list): bit 1 shift key down (crouching), bit 3
sprinting, bit 4 swimming. Their meaning is not the same as the pose (§3.4).

---

## 2. Dimensions and eye height (question 2)

### 2.1 Table

`Avatar.POSES` (a pose-to-dimensions map; an unlisted pose falls back to the STANDING entry) plus the sleeping entry
inherited from `LivingEntity`. Width and height are the bounding box; eye height is measured up from the feet position
(`Entity.position()`, the bottom centre of the box).

| Pose | Width | Height | Eye height | Scaled by the `scale` attribute | Notes |
|---|---|---|---|---|---|
| STANDING | 0.6 | 1.8 | 1.62 | yes | vehicle attachment point (0, 0.6, 0) |
| CROUCHING | 0.6 | 1.5 | 1.27 | yes | same vehicle attachment (0, 0.6, 0) |
| SWIMMING | 0.6 | 0.6 | 0.4 | yes | used by swimming and by crawling |
| FALL_FLYING | 0.6 | 0.6 | 0.4 | yes | out of scope, listed for completeness |
| SPIN_ATTACK | 0.6 | 0.6 | 0.4 | yes | out of scope |
| SLEEPING | 0.2 | 0.2 | 0.2 | no (fixed) | `LivingEntity.getDimensions` returns this entry before the scale is applied |
| DYING | 0.2 | 0.2 | 1.62 | no (fixed) | the `fixed` flag on the entry |

### 2.2 The scale attribute

`LivingEntity.getDimensions(pose)` = the entry of the table above, multiplied by `getScale()` (the `scale` attribute value,
1.0 when the entity has no attribute map), for every entry that is not "fixed": width, height, eye height and the
attachment points are all multiplied by the scale (width and height by the same factor). Scale 1.0 returns the entry
unchanged. SLEEPING is special-cased before the multiplication; DYING is fixed by its `fixed` flag.

Worked: scale 0.5, standing: 0.3 wide, 0.9 high, eye 0.81; crouching: 0.3 x 0.75, eye 0.635; swimming: 0.3 x 0.3, eye 0.2.
Scale 2.0, standing: 1.2 x 3.6, eye 3.24.

### 2.3 Bounding box construction and refresh

The box of a pose at feet position (x, y, z): x from x - w/2 to x + w/2, y from y to y + h, z from z - w/2 to z + w/2
(`EntityDimensions.makeBoundingBox`). So the box grows upward from the feet and is centred horizontally on the position.

`Entity.refreshDimensions` runs when the pose slot changes and when the scale changes: it stores the new dimensions,
copies the eye height into `Entity.eyeHeight` (instantly, no interpolation), and re-derives the box from the position.
There is **no animation of the hitbox**: the box and `Entity.eyeHeight` jump in the same tick the pose is set. (The only
smoothing is the client camera, §7.) For a Player the "push the entity out of blocks after growing" step is skipped
(`refreshDimensions` calls it only for non-players); the fit test of §3 is what prevents a player from growing into blocks.

Worked, scale 1, feet position (10.5, 64.0, 10.5):

| Pose | Box (min to max) |
|---|---|
| STANDING | (10.2, 64.0, 10.2) to (10.8, 65.8, 10.8) |
| CROUCHING | (10.2, 64.0, 10.2) to (10.8, 65.5, 10.8) |
| SWIMMING | (10.2, 64.0, 10.2) to (10.8, 64.6, 10.8) |

Eye position = feet position + (0, eye height, 0): 65.62 standing, 65.27 crouching, 64.4 swimming.

### 2.4 The fit test

`Player.canPlayerFitWithinBlocksAndEntitiesWhen(pose)`: build the box of `getDimensions(pose)` at the current position,
shrink it by **1e-7 on every side** (`AABB.deflate(1e-7)`), and ask `Level.noCollision(player, box)`. That call is true
only when all three hold: no block collision shape intersects the box (shapes are those the player collides with), no
collidable entity intersects it, and the box does not collide with the world border (`noBlockCollision`,
`noEntityCollision`, `noBorderCollision`). Touching is not colliding, which is what the 1e-7 is for.

---

## 3. Which pose a player has each tick (question 3)

### 3.1 Where it runs

`Player.updatePlayerPose` is the **last step of `Player.tick`**, after the entity tick (`baseTick`, `aiStep`, `travel`,
collision) of the same tick. It runs on the client for the local player and on the server for every `ServerPlayer`; each
side decides on its own. Consequences: the pose chosen in tick t is first used by the movement and collision of tick t+1,
and the swimming flag (§4) it reads was set at the start of tick t.

Order of one tick for the pieces this document covers: `Player.tick` start (eyes-in-water bookkeeping), `Entity.baseTick`
(fluid state, `updateSwimming`), `LivingEntity.aiStep` (on the client: key read, sprint start/stop, jump, `travel`),
packet sending (client), `updatePlayerPose`.

### 3.2 The choice

Inputs: the shift state (`isShiftKeyDown`: on the **server** the shared flag bit 1, on the **client** the live key state
of the sneak key, `LocalPlayer.isShiftKeyDown`), the swimming flag, sleeping, fall flying, spin attack, the Abilities
`flying` bit, spectator, passenger.

1. **Gate.** If the SWIMMING box does not fit (§2.4), nothing is changed this tick and the previous pose stays.
2. **Desired pose**, first match wins:

   | Order | Condition | Pose |
   |---|---|---|
   | 1 | sleeping | SLEEPING |
   | 2 | `isSwimming()` (§4: flag bit 4 and not Abilities-flying and not spectator) | SWIMMING |
   | 3 | fall flying | FALL_FLYING |
   | 4 | auto spin attack | SPIN_ATTACK |
   | 5 | shift down and Abilities `flying` false | CROUCHING |
   | 6 | otherwise | STANDING |

   There is no test for "can the player crouch under a ceiling" in the desired pose; shift alone gives CROUCHING.
3. **Fit fallback.** If the player is a spectator or a passenger, the desired pose is used as it is. Otherwise, if the
   desired pose fits (§2.4) it is used. If it does not fit: CROUCHING when the crouching box fits, else SWIMMING.
4. The result is stored with `setPose` (slot 6), which triggers `refreshDimensions` when the value differs.

The fallback applies to every desired pose that does not fit, including SLEEPING and CROUCHING itself; for a desired
CROUCHING that does not fit it tries CROUCHING again (no change) and then SWIMMING.

Consequences, with the default dimensions:

| Situation (gap height above the feet) | Desired | Result |
|---|---|---|
| 2.0 or more, no shift | STANDING | STANDING (1.8 fits) |
| 2.0 or more, shift | CROUCHING | CROUCHING |
| 1.5 up to less than 1.8, no shift | STANDING (does not fit) | **CROUCHING** (forced crouch; the shift flag stays false) |
| 1.5 up to less than 1.8, shift | CROUCHING | CROUCHING |
| 0.6 up to less than 1.5, any shift state | STANDING or CROUCHING (neither fits) | **SWIMMING** (crawling on land) |
| less than 0.6 | gate fails | pose unchanged (the player cannot enter) |
| Abilities flying, shift held | STANDING (rule 5 needs not flying) | STANDING |
| spectator inside blocks, 1.0 gap | desired pose, no fit check | desired pose (gate in step 1 still applies, Open question 3) |
| passenger of a vehicle, shift held | CROUCHING | CROUCHING (no fit check; shift also dismounts via `wantsToStopRiding`) |

Worked (trapdoor ceiling 1.5 above the feet, grounded player, no keys): standing box height 1.8 would reach into the
trapdoor, `noCollision` false; crouching box 1.5 fits (the shrink of 1e-7 makes a ceiling at exactly 1.5 not collide), so
CROUCHING. Release the shift key under a 1.0 ceiling: SWIMMING pose, box 0.6 high.

### 3.3 Forced crouch and crawl are visible through the pose, not through the shift flag

`Entity.isCrouching()` is "the pose is CROUCHING"; `Entity.isVisuallySwimming()` is "the pose is SWIMMING";
`Entity.isVisuallyCrawling()` is "the pose is SWIMMING and the entity is **not** in water" (`isInWater` false). So in a
1-high tunnel on land the player is visually crawling; the same pose in water (swimming through a 1-high water channel
without sprint) is visually swimming but not crawling. The model offsets for crouching are in 12 §7.5; the swimming and
crawling model poses are Open question 5 of 12 and remain open here (§12 Open question 6).

**The client's own "crouching" flag differs from the pose.** `LocalPlayer.isCrouching()` returns a private flag
recomputed at the start of `LocalPlayer.aiStep` from the key state of the *previous* tick (it is read before
`ClientInput.tick` refreshes the keys): true when the Abilities `flying` bit is false, the player is not swimming (flag),
not a passenger, the crouching box fits, **and** (shift was down, or (not sleeping and the standing box does not fit)).
`LocalPlayer.isMovingSlowly()` = this flag or `isVisuallyCrawling`. That is what slows the player (§6) and what blocks
sprinting (13 §1.5 "moving slowly"). Other code (server, other clients, model, visibility) uses the pose-based
`isCrouching`. Correction for 13 §1.1: the `sneaking_speed` factor is applied while *moving slowly* (the flag above or
visual crawling), not simply "while the sneak key is down".

---

## 4. The swimming flag lifecycle (question 3)

Flag = shared flag bit 4 (`Entity.setSwimming`). `Player.isSwimming()` reads it **and** requires Abilities `flying` false
and not spectator; everything below that says "swimming" for a player means that combined test (the pose rule 2 uses it too).

`Entity.updateSwimming` runs inside `Entity.baseTick` every tick, on client and server, before `aiStep`
(`Player.updateSwimming` first clears the flag if Abilities `flying` is true and does nothing else in that case):

| Current state | Rule |
|---|---|
| swimming | stays set while: **sprinting** and `isInWater` (any water touching the box) and not a passenger. Otherwise cleared. |
| not swimming | becomes set when: **sprinting** and `isUnderWater` and not a passenger and the fluid at the entity's block position (the block containing the feet position) is water. Otherwise stays clear. |

`isUnderWater`: on the client (`LocalPlayer`) "the eyes are in water" as computed by `Player.updateIsUnderwater` at the start
of `Player.tick`; on the server `Entity.isUnderWater` = "the eyes were in water at this tick's start (`wasEyeInWater`)
and `isInWater`". So there is hysteresis: entering needs sprint + eyes under water + feet block containing water; staying
needs only sprint + touching water. Sprinting in water is itself gated by the client sprint rules (13 §1.5): on foot, sprint
cannot start in shallow water (in water, head not under), and a swimming sprint stops when no longer in water.

Timing: `baseTick` runs before `aiStep`, so a sprint started or stopped in tick t changes the swimming flag in tick t+1
and the pose at the end of tick t+1.

Leaving the state: the flag clears in the first tick where sprint is off or the player left the water (or became a
passenger or started flying). At the end of that tick the pose rules of §3.2 run again: with shift it becomes CROUCHING,
otherwise STANDING, or the fit fallback (CROUCHING, then SWIMMING) when the taller box does not fit. Coming out of water
into a 1-high opening therefore leaves the pose SWIMMING with the flag clear: crawling.

Worked: a sprinting player walks into water 2 blocks deep. Tick 1: eyes below the surface, sprint set, feet block
water: flag set at the start of tick 2, pose SWIMMING at the end of tick 2 (box 0.6 high, eye 0.4). The player stops
sprinting (key released, or `shouldStopSwimSprinting`): flag clear next tick, pose STANDING at the end of that tick if
1.8 fits. A sprinting player in water only 1 block deep cannot start swimming: the eyes are not under water.

---

## 5. Sneak edge safety (question 4)

The rule is `Player.maybeBackOffFromEdge(delta, moverType)`, called by `Entity.move` just before collision resolution for
every move (the base `Entity` version returns the delta unchanged).

### 5.1 When it applies

All of the following:

- Abilities `flying` is false;
- the requested delta's y component is **at most 0** (not rising);
- the move type is `SELF` (a normal `travel` move) or `PLAYER` (the server's replay of a Move Player packet, §9.4); pistons, shulker boxes and others are never clamped;
- `isStayingOnGroundSurface()` is true; for a Player this is `isShiftKeyDown()` (client: live key; server: flag bit 1);
- the player is **above ground**: `onGround` is true, **or** (fall distance < step height H and the player could *not* fall at least `H - fallDistance` straight down, tested with the probe of §5.2 at zero horizontal offset).

H is `maxUpStep()`: the `step_height` attribute (0.6 for a player, 13 §1.2). It is raised to at least 1.0 only when the
entity's controlling passenger is a Player, which does not apply to the player itself. So the clamp is also active for a
sneaking player a little above the ground (jumping, or standing in shallow water on a block), as long as ground lies within
H below. Nothing else (water, ladders) disables it.

### 5.2 The probe `canFallAtLeast(dx, dz, h)`

Take the player's current bounding box (the pose's box, not inflated). Build a probe box:

- x from `minX + 1e-7 + dx` to `maxX - 1e-7 + dx`; z from `minZ + 1e-7 + dz` to `maxZ - 1e-7 + dz` (shrunk by 1e-7 horizontally, shifted by the offset);
- y from `minY - h - 1e-7` up to `minY` (a slab of thickness about h directly under the feet, whose top is exactly the feet level).

The result is `Level.noCollision(player, probe)`: **true means nothing solid is in the slab**, i.e. the shifted player would
be able to fall at least h. Blocks, collidable entities (for example a boat) and the world border all count as "solid"
(§2.4), so a sneaking player is also held at a world border or on top of a boat. h is H (0.6) in the clamp.

### 5.3 The reduction

Let (x, z) be the delta's horizontal components, with x and z unchanged in y. Constants: step **0.05**, one step per axis
direction `signum(component) * 0.05`.

1. **X alone.** While x is not 0 and `canFallAtLeast(x, 0, H)`: if |x| <= 0.05 then x = 0, else x = x - signum(x) * 0.05.
2. **Z alone.** While z is not 0 and `canFallAtLeast(0, z, H)`: the same with z. (The probe uses the *original* x as 0, not the reduced x, and this step uses the z the step 1 did not change.)
3. **Both.** While x is not 0, z is not 0 and `canFallAtLeast(x, z, H)`: reduce x by one step as in step 1 (to 0 when |x| <= 0.05), and then z by one step likewise; repeat.

The result is the delta with the reduced x and z and the original y; collision resolution continues with it. The loop
stops at the first offset whose footprint still overlaps something solid in the slab. The player's final footprint
therefore always has at least a sliver over solid ground.

### 5.4 Worked examples (a full block, top at y = 64, occupying x 0 to 1, z 0 to 1; player feet y = 64, width 0.6, H = 0.6)

Player box minX = 0.6 (centre x = 0.9); z centre 0.5 (over the block); sneaking, on ground.

| Case | Delta in | Steps | Delta out |
|---|---|---|---|
| Toward +x, large: dx = +0.5 | 0.5 | probe minX shifted to 1.1: no overlap, can fall; reduce 0.45 (1.05), 0.40 (1.0, still no overlap because the 1e-7 shrink puts minX at 1.0000001), 0.35 (0.95 overlaps the block) stop | dx = 0.35 (box ends minX 0.95, x 0.95 to 1.55: 0.05 of it on the block) |
| Not beyond the edge: dx = +0.2 | 0.2 | probe minX 0.8 overlaps the block | unchanged 0.2 |
| Slow approach, per-tick dx = +0.065 (about the sneak speed, §6), starting minX = 0.94 | 0.065 | probe 1.005: can fall; |0.065| > 0.05 so dx = 0.015; probe 0.955 overlaps | 0.015 |
| Same, starting minX = 0.985 | 0.065 | probe 1.05: can fall; 0.065 reduces to 0.015; probe 1.0 plus 1e-7 does not overlap: can fall; |0.015| <= 0.05 so dx = 0 | 0 (the player stops with 0.015 of its width over the block) |
| Toward -x symmetric | the maxX side is used | by symmetry | mirrored |
| Corner, dx = dz = +0.5, player box min (0.6, 0.6), single block | 0.5, 0.5 | X alone gives 0.35; Z alone gives 0.35; third loop: probe (0.35, 0.35) overlaps the block corner, so it does not run | (0.35, 0.35) |
| L-shaped floor: blocks at cells (0,0), (1,0), (0,1), none at (1,1); player box min (0.8, 0.8); delta (0.4, 0.4) | 0.4, 0.4 | X alone: probe overlaps cell (1,0), no change; Z alone: overlaps cell (0,1), no change; third loop: probe (0.4,0.4) lies wholly over the missing cell: reduce both to 0.35, 0.30, 0.25, 0.20 (0.8 + 0.2 + 1e-7 no overlap), 0.15 (minX 0.95 overlaps cell (1,0)): stop | (0.15, 0.15) |

Drop heights (player feet y = 64, probe slab y from 63.3999999 to 64):

| Ground next to the edge | Probe result | Clamp |
|---|---|---|
| A full block one lower (top 63.0): drop 1.0 | slab clear (63.0 is below 63.3999999) | clamps |
| A bottom slab (top 63.5): drop 0.5 | top 63.5 is inside the slab: collision | no clamp, the player walks off down onto the slab |
| A carpet (height 0.0625) lying on a block whose top is 63.0 (carpet top 63.0625): drop 0.9375 | clear | clamps (the carpet does not count as ground that far down) |
| A carpet on a block whose top is 64.0 (carpet top 64.0625, same level cell) | the block under it overlaps the slab | no clamp (also a step up of 0.0625, within 0.6) |
| A drop of exactly 0.6 (top 63.4) | 63.4 is above the slab bottom 63.3999999: collision | no clamp |
| A drop of 0.65 (top 63.35) | slab bottom 63.3999999 is above 63.35: clear | clamps |

### 5.5 Client and server

The clamp is part of `Entity.move`, which both sides run. On the **client** it applies every tick to the local player's
`travel` move with the live key state (the shift key read by `LocalPlayer.isShiftKeyDown` is the post-`ClientInput.tick`
state, so it works in the very tick the key goes down, one tick before the "moving slowly" slow-down of §6 starts).
The **server** has no input of its own: it replays each Move Player packet as `move(PLAYER, claimed - lastGood)` (§9.4),
so it applies the same clamp with the shift flag it holds (from Player Input). But the position the server accepts is the
claimed one: after the replay it compares the replayed position with the claimed position, and only a squared error above
0.0625 (and other conditions, §9.4) makes it teleport the player back. A client that does not clamp therefore gets pulled
back only if its claimed move differs from the clamped replay by more than 0.25 blocks; smaller differences are accepted.
The clamp does not run for non-player entities (the base method is the identity) and not for mobs.

### 5.6 Related sneak effects (question 4, question 11)

| Effect | Rule | Read in |
|---|---|---|
| Ladder / vine hold | in `handleOnClimbable` (applies to any climbable block): after clamping the vertical velocity to at least -0.15, if it is below 0, the entity is a Player, `isSuppressingSlidingDownLadder` (shift held; for the local player also requires Abilities `flying` false) and the block the entity is in is **not** scaffolding, then the vertical velocity becomes 0. So a sneaking player stays on a ladder instead of sliding down at 0.15 | `LivingEntity.handleOnClimbable`, `LocalPlayer`, `Entity` |
| Scaffolding | the block's collision shape is chosen with the entity's "descending" flag (`CollisionContext.isDescending`, which is the shift key for a player): standing above it and descending lets the player pass through the stable shape (24 part 7 §11.4 describes the shapes) | `ScaffoldingBlock.getCollisionShape` |
| Slime bounce | `isSuppressingBounce` = shift: no bounce on a slime block | `SlimeBlock` |
| Magma, etc. | `isSteppingCarefully` = shift (17 §4.11, magma block) | `Entity` |
| Step sounds and vibrations | `Player.getMovementEmission` is NONE while Abilities `flying` or (`onGround` and `isDiscrete`, which is shift); otherwise ALL | `Player` |
| Riding | `wantsToStopRiding` = shift (the shift key dismounts) | `Player` |
| Secondary use | `isSecondaryUseActive` = shift (17 §4: using an item or block versus sneak-place) | `Player` |
| Locator-bar range | while the pose is CROUCHING (`isCrouching`), `updatePlayerAttributes` adds the transient modifier `waypoint_transmit_range_crouch` (-1.0 as ADD_MULTIPLIED_TOTAL) to the player's `waypoint_transmit_range`, which makes the range 0 | `ServerPlayer` |
| Statistic | each tick `isDiscrete` (shift) awards the statistic `crouch_time` | `ServerPlayer.doTick` |

Honey blocks, bubble columns and stairs showed no sneak test in the classes listed in the header (`HoneyBlock`,
`BubbleColumnBlock`); other blocks were not scanned (Open question 7).

---

## 6. Sneak, crawl and sprint speed (question 5)

### 6.1 Where the factor is applied

Only on the **client**, in `LocalPlayer.modifyInput`, on the 2D move vector before it becomes the forward and strafe
impulses (13 §1.1 order): normalised keyboard vector, times 0.98, times the item-use factor when using an item and not
riding, times the **`sneaking_speed` attribute value** when `isMovingSlowly` (§3.3: crouching flag or visual crawling),
then the square-movement correction. The attribute (default 0.3, range 0 to 1, 18 §1.3; Swift Sneak adds 0.15 per level,
17 attribute table and the `swift_sneak` entry) is **not** a modifier on the movement-speed attribute, so it does not change the field of view (§8). The server
never reads it.

It applies in water too: a player who holds shift while wading (not swimming) has the crouching flag true if the
crouching box fits, and is slowed; shift in water additionally adds -0.04 to the vertical velocity each tick
(`goDownInWater`, client only, requires in water and affected by fluids) (13 §1.3). While the swimming flag is set the
crouching flag is false and `isVisuallyCrawling` is false (the pose is SWIMMING but the player is in water), so no
sneak slow-down.

On land with the SWIMMING pose (crawling) `isVisuallyCrawling` is true, so crawling uses exactly the sneaking factor.

### 6.2 Numbers

Flat ground, friction 0.6 (13 §1.3: acceleration = input x speed, drag 0.546 horizontally): per tick the velocity gains
`0.1 x 0.98 x 0.3 = 0.0294` forward and then keeps 0.546 of it; steady state 0.0294 / 0.454 = **0.0648 blocks/tick =
1.295 blocks/s**, against 4.32 walking (13 §1.3). With the square correction, a diagonal input gets a larger vector
(the unit-length diagonal times 0.294 has length 0.294 and the correction scales it by sqrt(2) up to a maximum of 1, so
each component reaches 0.294, the same as a straight key). Swift Sneak III: factor 0.3 + 0.45 = 0.75: 0.0735 per tick of
input, steady 0.1619 blocks/tick = **3.24 blocks/s**. Crawling on land equals sneaking: 1.295 blocks/s, 3.24 with Swift
Sneak III (the attribute is the player's).

Jumping is allowed in the crouching and crawling poses: `LivingEntity.aiStep`'s jump handling and `jumpFromGround` have no
pose test; the jump power is the usual 0.42 (13 §1.2). A jump under a low ceiling is simply stopped by the ceiling (the
box is 0.6 high while crawling).

Sprint rules (13 §1.5 has them): moving slowly stops sprint start unless under water; the sneak key cancels
`sprintTriggerTime`. Sprint on a crawling or crouching player therefore cannot start on land.

---

## 7. The camera (question 6)

`Camera.tick` (client tick, only when a level and a camera entity exist) keeps two floats `eyeHeightOld` and `eyeHeight`.
Each tick: `eyeHeightOld = eyeHeight`; then `eyeHeight += (entity.getEyeHeight() - eyeHeight) x 0.5`, where
`entity.getEyeHeight()` is the instant `Entity.eyeHeight` of §2.3. So the camera eye height moves **half of the remaining
distance each tick**: after n ticks the remaining gap is 0.5^n of the initial gap. Rendering uses
`lerp(partialTick, eyeHeightOld, eyeHeight)` as the eye height added to the interpolated entity position (first and third
person; for a minecart passenger the same value is used).

Targets: standing 1.62, crouching 1.27, swimming and crawling 0.4 (for scale 1). Worked, standing to crouching: the
entity eye height is 1.27 from the tick of the pose change. Camera eyeHeight: 1.62, then 1.445, 1.3575, 1.31375, 1.291875,
... (gap 0.35, 0.175, 0.0875, ...). Standing to swimming: gap 1.22: 1.62, 1.01, 0.705, 0.5525, ...

Neither field is initialised (both start at 0) and `Camera.reset` does not reset them: after the first join the camera eye
rises from 0 to 1.62 over the first ticks (0.81, 1.215, 1.4175, ...). The entity's own `eyeHeight` is not smoothed and is
what the server and the picking ray use.

---

## 8. Sprint field of view (question 7)

### 8.1 The modifier for the camera player (`AbstractClientPlayer.getFieldOfViewModifier(firstPerson, effectScale)`)

Start with factor f = 1.

1. If the Abilities `flying` bit is set: f = f x 1.1.
2. Let w = the Abilities walking speed (0.1). If w is not 0: r = (value of the `movement_speed` attribute) / w, and f = f x (r + 1) / 2.
3. If an item is in use:
   - a bow: t = min(ticks used / 20, 1); f = f x (1 - 0.15 x t x t);
   - else if first person and the player is scoping (spyglass): return **0.1** immediately (the effect scale is not applied).
4. Return `lerp(effectScale, 1, f)` = 1 + effectScale x (f - 1).

`effectScale` is the option `fovEffectScale` (13 §7.2, stored squared; 1.0 default; 0 disables every effect above except the
scoping 0.1).

The `movement_speed` attribute includes the transient sprint modifier (13 §1.2: base 0.1 becomes 0.13 while sprinting),
and any speed-effect modifiers. **Sneaking and swimming do not change the attribute** (sneaking is the input scaling of §6,
swimming is the sprint modifier already counted), so they have no FOV effect of their own; sprint-swimming widens the FOV
exactly like sprinting on land.

Worked: normal walking, r = 1.0, f = 1.0. Sprinting, attribute 0.13: r = 1.3, f = (1.3 + 1)/2 = **1.15**. A creative player who is flying and has the attribute at 0.13: f = 1.1 x 1.15 = 1.265. A drawn bow
for 20 ticks while walking: f = 1 - 0.15 = 0.85. With `fovEffectScale` 0.5, sprinting: 1 + 0.5 x 0.15 = 1.075.

### 8.2 Smoothing, clamp and use

`Camera.tickFov` (each client tick): the modifier m_target above is computed for the camera entity when it is an
`AbstractClientPlayer` (else 1.0); `oldFovModifier = fovModifier`; `fovModifier += (m_target - fovModifier) x 0.5`; then
`fovModifier` is clamped to [**0.1**, **1.5**]. The initial value is 0 (no initialiser, Open question 8), so the first ticks
after the first join read 0.5, 0.75, 0.875, ... heading to 1.

The rendered vertical FOV in degrees = `options.fov` (30 to 110, 13 §7.2, default 70) x `lerp(partialTick, old, current)`,
then:

- if the camera entity is a living entity that is dead or dying: divided by `(1 - 500 / (t + 500)) x 2 + 1` where `t = min(deathTime + partialTick, 20)`;
- if the camera is in water or lava (`getFluidInCamera`): multiplied by `lerp(fovEffectScale, 1, 0.85714287)` (that is 1 - 0.142857 x fovEffectScale, up to about 14 percent narrower).

The hand/HUD projection uses 70 degrees with the same death and fluid adjustments. Worked: option fov 70, sprint steady
state (modifier 1.15): 80.5 degrees; sprinting underwater with effect scale 1: 80.5 x 0.85714287 = 69.0.

Panoramic mode uses 90 degrees. The culling frustum uses the larger of the computed FOV and the option FOV.

---

## 9. Swimming movement (question 8)

13 §1.3 has the water summary. The complete order for one tick of a player in water (the swimming flag set or not), as
read from `Player.travel` and `LivingEntity.travel/travelInFluid/travelInWater`:

### 9.1 The pose-specific pitch steering (`Player.travel`, only when `isSwimming()`)

Let L = the unit look vector (from yaw and pitch), `Ly` its y component, `v` the current velocity.

1. Factor k = 0.085 if Ly < -0.2, else 0.06.
2. The steering is **skipped** exactly when all of: Ly > 0, the jump key is not held (`jumping` false), and the fluid
   at the position (x, y + 1 - 0.1, z) (that is 0.9 above the feet) is empty. Otherwise it applies. (13 §1.3 describes the
   condition in the opposite sense; this is the read behaviour: looking down or level always steers, looking up steers while
   the head-height point is in fluid or while Space is held, and looking up at the surface without Space does not steer, so
   the player stops climbing out of the water.)
3. When it applies: `v.y = v.y + (Ly - v.y) x k` (x and z of the velocity unchanged).

Then the normal travel runs (below). When the player is a passenger, `Player.travel` skips all of this. When Abilities
`flying`, the flight handling of 13 §1.4 applies instead.

### 9.2 In-fluid travel

`LivingEntity.travel` picks the fluid branch when the entity's block holds fluid (the fluid at `blockPosition`), the entity
is in a liquid, is affected by fluids (a flying player is not), and cannot stand on the fluid. Otherwise: fall flying, else
air. A player that is crawling on land (flag clear) therefore uses air travel (13 §1.3 ground rules with the 0.3 input
factor); a swimming-pose player in water uses the water branch below even when the flag is clear.

`travelInWater(input, gravityEffective, falling, startY)`, with `y` of the body:

1. Drag d = 0.9 if sprinting, else 0.8 (`getWaterSlowDown`). Acceleration a = 0.02.
2. Efficiency e = `water_movement_efficiency` attribute value, **halved when not on the ground**. If e > 0: d = d + (0.54600006 - d) x e; a = a + (movement speed attribute - a) x e. The movement speed is the player's value (0.13 when sprinting).
3. Dolphin's Grace: d = 0.96 (replaces the value above).
4. `moveRelative(a, input)`: the input vector (strafe, 0, forward; the player's `yya` is 0) is scaled to length at most 1, then to a, rotated by the **yaw only** and added to the velocity. The pitch does not enter the horizontal push.
5. Move with the current velocity (collision, `MoverType.SELF`, the sneak clamp of §5 applies).
6. If horizontally blocked and on a climbable, y velocity becomes 0.2.
7. Drag: x and z multiplied by d, y multiplied by 0.8 (the `multiply(d, 0.8, d)`).
8. Fluid falling adjustment (`getFluidFallingAdjustedMovement`), applied only when the effective gravity is not 0 **and the entity is not sprinting** (so a swimming player gets none): if the entity was falling (y velocity <= 0) and |vy - 0.005| >= 0.003 and |vy - g/16| < 0.003 then vy = -0.003, else vy = vy - g/16, with g the effective gravity (0.08, so g/16 = 0.005).
9. Jump out of fluid: if horizontally collided and the box shifted to (vx, vy + 0.6 - (current y - startY), vz) is free of collisions, then vy = 0.3 (the swim-up assist against a ledge).

Swim-up and sink keys: Space adds +0.04 vertical velocity per tick while in water and (not on the ground, or the fluid is deeper than the jump threshold; the threshold is 0 when the eye height is below 0.4, else 0.4) (`jumpInLiquid`, 13 §1.3 step 3); Shift adds -0.04 (`goDownInWater`, client). Both are applied in `aiStep` before `travel`.

Horizontal speed per tick at steady state (input 0.98 x a, forward only, no efficiency; displacement = (v_after_drag + a)):
the velocity after drag satisfies v = d x (v + a), so displacement = a / (1 - d).

| Case | d | a (per tick, with the 0.98 input) | Displacement per tick | blocks/s |
|---|---|---|---|---|
| Swimming (sprint) | 0.9 | 0.0196 | 0.196 | 3.92 |
| Wading, not sprinting | 0.8 | 0.0196 | 0.098 | 1.96 |
| Swimming with Dolphin's Grace | 0.96 | 0.0196 | 0.49 | 9.8 |

(The first-tick displacement is smaller: it builds up as 0.0196, then 0.0196 x 1.9, ...)

Vertical (inferred from the formulas above, not read as constants): each tick of steering followed by the 0.8 vertical drag
gives v_next = 0.8 x (v + k x (Ly - v)), whose fixed point is v = 0.8 k Ly / (1 - 0.8 (1 - k)). Looking straight up
(Ly = 1, k = 0.06): v = 0.048 / 0.248 = 0.1935 blocks/tick (3.9 blocks/s) after drag. Looking straight down (Ly = -1,
k = 0.085): v = -0.068 / 0.268 = -0.2537 blocks/tick (5.1 blocks/s). Level look (Ly = 0): v tends to 0.

### 9.3 Entering, leaving and the land transition

Entering: §4 (sprint plus eyes under water and water in the feet block). The pose is SWIMMING from the end of the
following tick (the box becomes 0.6 high; the eye 0.4; the fit gate of §3.2 step 1 always tests that box first, so a
player in a 1-high gap at the surface can still enter). Leaving: §4. At the waterline in front of a 1-block ledge the
steering of 9.1 step 2 and the ledge assist of 9.2 step 9 push the player up; the pose returns to STANDING once the
sprint stops. On land with the SWIMMING pose and the flag clear the player is crawling (§3.3, §6).

Corrections to 13 §1.3: the swimming-pose steering is not "only while looking up and not holding Space with fluid above";
see the exact skip rule in 9.1. The fluid-falling adjustment does not apply while sprinting.

---

## 10. Server side (question 9, question 10)

### 10.1 Which packet carries sneak and sprint

| State | Packet | Server handling |
|---|---|---|
| Sneak (shift) | Player Input, serverbound 0x2B (05c): a byte of 7 flags, shift is 0x20. The client sends it from `LocalPlayer.tick` whenever the key-state record differs from the last one sent (before the position packet of the same tick; no repeat otherwise). | `handlePlayerInput`: stores the whole record as the last client input; and **if the client has loaded**, resets the idle timer and calls `setShiftKeyDown(input.shift)`, which writes shared flag bit 1. |
| Sneak (alternative) | Interact (05c, field "Using secondary action") | `handleInteract` also calls `setShiftKeyDown(usingSecondaryAction)` before processing the interaction, so an entity interaction carries the sneak state. |
| Sprint | Player Command, serverbound 0x2A (05c), actions 1 `START_SPRINTING`, 2 `STOP_SPRINTING` (sent by `sendIsSprintingIfNeeded` when `isSprinting` changes, right before the position packet) | `handlePlayerCommand`: `setSprinting(true)` or `(false)` (only when the client has loaded; the packet resets the idle timer). `LivingEntity.setSprinting` writes shared flag bit 3 and removes or adds the sprint modifier on the `movement_speed` attribute. |
| Swimming | none: the server computes it (§4) from its sprint flag and water state | `Entity.updateSwimming` in the server's `baseTick`. |

Server pose: `updatePlayerPose` at the end of every server tick (§3), using the server's flag bit 1.

### 10.2 What others see

Everything is metadata. Each change of the flags byte (slot 0: crouching bit 1 = 0x02, sprinting bit 3 = 0x08, swimming bit 4 = 0x10)
or of the pose (slot 6) makes the slot dirty; the next `sendChanges` of the player's `ServerEntity` sends one Set Entity
Data (0x65) with only the dirty slots to the trackers **and to the player itself** (`sendToTrackingPlayersAndSelf`). The
client assigns the values with no special case for the local player (`handleSetEntityData`), so the server's pose and flags
overwrite the local copy; the local tick recomputes them at its end (Open question 9). A viewer sees: pose CROUCHING with
the model offsets of 12 §7.5; pose SWIMMING with the model rotated to prone (12 §7, Open question 6 here); the name tag is
hidden for a sneaking entity farther than 32 blocks (distance squared at least 1024, `Entity` discrete rule in 34-1 §7.2, including the worked example V15 there); mobs' detection uses `getVisibilityPercent` (18 §4.3: crouching x 0.8, invisibility,
armour cover, ...); the locator-bar range is 0 while crouching (§5.6).

### 10.3 Movement validation

`ServerGamePacketListenerImpl.handleMovePlayer` (05c Move Player) validates each packet; the pose, the sneak, sprint,
swim and crawl states take **no part** in the checks (read: the method tests only passenger, sleeping, fall flying,
creative, spectator, auto spin attack, the dimension change, the post-impulse grace time, `allowFlight`, `mayfly`,
levitation, and block contact). The rules:

1. **Invalid values** (NaN or infinite position or rotation): disconnect `multiplayer.disconnect.invalid_player_movement`; a second position packet in the same tick: the same disconnect.
2. Coordinates are clamped to +-3.0E7 horizontally and +-2.0E7 vertically before use.
3. Passenger: the packet only updates rotation and snaps to the vehicle; no speed check.
4. **Sleeping**: if the squared distance from the tick-start position exceeds 1.0 the player is teleported back.
5. **Too fast** (`moved too quickly`): let `moved` = squared distance from the position at the start of the tick (`firstGood`) to the claimed position, `known` = squared length of the server's own delta movement of the player, and n = the number of move packets received since the previous tick (if n > 5 it is taken as 1). Only when `shouldCheckPlayerMovement` (not the singleplayer owner, not changing dimension, game rule `player_movement_check` true, and when fall flying also game rule `elytra_movement_check`): if `moved - known` > T x n, with T = **100** (**300** when fall flying), the player is teleported back to its server position and the packet is dropped. The pose never changes T. T = 100 is a squared distance, that is 10 blocks in one tick; swimming (0.196) or sprinting (0.28 blocks/tick) is far below it.
6. **Replay and "moved wrongly"**: if not rejected, the server replays the move: it computes the delta from the last good position, and, when the server has the player on the ground, the packet claims not on ground and the move goes up, the server runs `jumpFromGround` (which charges the jump exhaustion); then `move(PLAYER, delta)`, which includes the sneak clamp (§5.1, with the server's shift flag), collision and step height. The replayed position is compared with the claimed one (a vertical error of at most 0.5 is ignored): if the squared error is above **0.0625** and the player is not changing dimension, sleeping, in creative or spectator, or in post-impulse grace time, the move is flagged "moved wrongly".
7. **Rejection by collision**: if not noPhysics and not sleeping, and ((flagged wrongly **and** the player's old box (before the replay) has no collision) **or** the new box collides with something the old box did not), the player is teleported back to its last position. Otherwise the player's position is set to the **claimed** position (not the replayed one), the floating check runs (`clientIsFloating` when not on ground, not falling faster than -0.03125 per tick, not spectator, not allowed to fly, no levitation, no fall flying and no block within the check) and the movement statistics are recorded.

### 10.4 Exhaustion and statistics (`ServerPlayer.checkMovementStatistics`, 17 §4.9)

Called for each accepted move with the delta (new minus old position). Nothing happens for a passenger or when the player did
not move (`didNotMove`). The distance in centimetres is c = `round(100 x sqrt(...))`, with the dimensions stated; if c is 0
nothing is awarded. The branches, **first match wins**, in this order:

| Order | Condition | Distance | Statistic | Exhaustion added |
|---|---|---|---|---|
| 1 | swimming (flag, `isSwimming`) | 3D (x, y, z) | `swim_one_cm` | 0.01 x c x 0.01 (0.01 per metre) |
| 2 | eyes in water | 3D | `walk_under_water_one_cm` | 0.01 per metre |
| 3 | in water | horizontal | `walk_on_water_one_cm` | 0.01 per metre |
| 4 | on a climbable | vertical only, when moving up | `climb_one_cm` | none |
| 5 | on ground | horizontal | sprinting: `sprint_one_cm`; else crouching pose: `crouch_one_cm`; else `walk_one_cm` | sprinting **0.1 per metre**; crouching 0; walking 0 |
| 6 | fall flying | 3D | `aviate_one_cm` | none |
| 7 | otherwise (in the air, not climbing) | horizontal | `fly_one_cm` only when c > 25 | none |

Note that sprinting in the air (a sprint jump) charges nothing per metre; the jump charges 0.2 (17 §4.9). The exhaustion
is `Player.causeFoodExhaustion`, which ignores creative and spectator. Worked: sprinting 100 m on the ground: c totals 10000;
exhaustion 0.1 x 10000 x 0.01 = 10.0, that is 2.5 food points (4.0 exhaustion per point, 17 §4.9). Swimming 100 m: 1.0.
Walking or crouching 100 m: 0.0.

---

## 11. Quick reference

| Question | Answer in |
|---|---|
| Pose ids, wire form | §1 |
| Dimensions, eye heights, scale | §2 |
| Pose per tick, forced crouch, crawl | §3 |
| Swimming flag | §4 |
| Edge clamp, examples | §5 |
| Sneak and crawl speed, jump | §6 |
| Camera eye height | §7 |
| Sprint FOV | §8 |
| Swim movement | §9 |
| Server packets, validation, exhaustion | §10 |
| Ladder, scaffolding, bounce | §5.6 |

## 12. Open questions

1. **Fit test: entity part.** `noEntityCollision` was named but the definition of which entities block the fit test (boats, shulkers, other) was not traced; §5.2 and §2.4 inherit that gap.
2. **Border part of `noCollision`.** That the world border counts as a blocking surface for the sneak probe is read from the method call `noBorderCollision`; its exact test (whether a box merely touching the border blocks) was not read.
3. **Spectator pose.** Whether a spectator whose box does not fit the SWIMMING box keeps its previous pose forever (step 1 gate) was not checked against the spectator collision context.
4. **DYING.** `LivingEntity.die` sets DYING after Entity Event 3; whether the next `updatePlayerPose` (which runs every tick in `Player.tick`) overwrites it for a dead player was not traced.
5. **Block-side `isDescending` uses.** Which other blocks read the descending flag besides scaffolding was not scanned (powder snow, honey, bubble columns showed none in the classes listed).
6. **Swimming and crawling model poses, and the swim-amount animation.** Not traced: `LivingEntity.updateSwimAmount` and the player model's swimming/crawling transforms (12 Open question 6/7 remain open).
7. **Other sneak consumers.** The list of §5.6 is the set found in the classes read (`Player`, `LivingEntity`, `Entity`, `LocalPlayer`, `ServerPlayer`, `ScaffoldingBlock`, `SlimeBlock`); other uses of `isShiftKeyDown`, `isDiscrete`, `isCrouching` across the jar were not enumerated.
8. **Initial camera state.** `Camera.eyeHeight` and `fovModifier` have no initialiser in the constructor listing (so they start at 0), and no other write besides `tick`/`tickFov` was found; whether another class resets them on join (so the first-join ramp of §7 and §8.2 is not visible) was not searched.
9. **Local pose versus server echo.** The server echoes the player's own pose and flags back to it (§10.2) and the client applies them without a filter; the client then recomputes at the end of its tick. The visible effect (one-tick pose flicker or none) was not traced.
10. **`getFluidFallingAdjustedMovement` call arguments.** The effective gravity argument is the gravity effective at the start of the tick; its exact derivation for a swimming player was not traced beyond 0.08 (13 §1.2).
11. **Recalled, not verified:** nothing in this document is taken from recall; all constants were read in this round. The only values that are derived rather than read are the steady-state speeds and the worked examples (marked "inferred" in §9.2 and computed from the read constants).
