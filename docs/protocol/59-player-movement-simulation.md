# 59. Player movement simulation

| Item | Value |
|---|---|
| Covers | The movement of the local player, tick by tick: the order of everything that changes its input, flags and velocity; the input vector; walking, air, climbing, water, lava, ledge assist and flight; the collision follow-up (bounce, block speed factor); the block effect pass and its cell order; every block behaviour that changes a player's movement; the movement behaviour of Speed, Slowness, Jump Boost, Levitation, Slow Falling, Dolphin's Grace, Blindness, Soul Speed, Depth Strider and Swift Sneak with the attribute and effect updates the server sends; fall distance and fall damage; pushes (Set Entity Motion, Explode, entity pushing) and the velocity the server puts in them; teleports (Player Position) on the client and on the server with their confirmation; the lift of a player by a growing block |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (version 26.3), the artifact recorded in [README.md](README.md) |
| Method | Static reading of the shipped bytecode (`javap`), with no execution; the data files named in a row were read from the same jar. Classes read include `LocalPlayer`, `KeyboardInput`, `ClientInput`, `Minecraft` (tick order), `ClientPacketListener`, `Entity`, `LivingEntity`, `Player`, `ServerPlayer`, `ServerEntity`, `ServerGamePacketListenerImpl`, `ServerLevel`, `ServerExplosion`, `EntityFluidInteraction`, `BlockGetter`, `BlockPos`, `CollisionGetter`, `Blocks` and the block classes named in section 10, `MobEffect`, `MobEffects`, `MobEffectInstance`, `AttributeInstance`, `EnchantmentHelper`, `Enchantment`; for 13.2 and 13.6 also `Block` (`pushEntitiesUp`), `Relative`, `PositionMoveRotation`, `ClientboundPlayerPositionPacket`, `Shapes`, `VoxelShape`, `AABB`, `EntityGetter`, `Level`, `MultiPlayerGameMode`, `BlockStatePredictionHandler` |
| Extends | 13 section 1 points here. 53 (poses, sneak edge, sneak speed, swimming steering, server validation), 51 section 6.1 (collision and step-up), 29a (fluids), 30 part 8 section 14.1 (the `move` pipeline and the supporting block), 39 section 2.2a (the block effect pass), 17 (damage, knockback), 28 (enchantment engine) |

Conventions. A **tick** is 1/20 s. Velocity is in blocks per tick, per axis `(x, y, z)`, y up. Yaw is in degrees; yaw 0
looks toward +z. Positions are the feet position (bottom centre of the box). `f32(v)` means the value is rounded to IEEE
single precision at that point; a product written `f32(a x b)` is computed in single precision. Unless marked `f32`,
velocity and position arithmetic is double precision. `sin` and `cos` in this document are the table functions of 10
section 16 (65536 float entries, argument a double), called with `f32(yaw x 0.017453292f)` unless a rule says otherwise.
`sqrt32(v)` = `f32(sqrt((double)v))`. "Client" means the local player simulated in the client; "server" means the
server's `ServerPlayer`. Class names in backticks say where a fact was read. "(inferred)" marks a value deduced rather
than read. Worked examples are computed from the rules of this document with the precision stated (no game was run); they
assume the player's `movement_speed` base 0.1, no effects and no enchantments, yaw 0, flat full blocks of friction 0.6
and centred in a cell column on x, unless the example says otherwise. Values are printed to 7 decimals; an
implementation meets them to far better than 0.001 blocks.

---

## 1. State the simulation keeps

| State | Type | Start value | Meaning |
|---|---|---|---|
| position | double x 3 | from the server | feet position |
| velocity `v` | double x 3 | (0, 0, 0) | the stored velocity ("delta movement"). A write whose vector has a non-finite component is ignored as a whole (`Entity.setDeltaMovement`) |
| `onGround` | boolean | false | set by the move step (section 8) |
| `horizontalCollision`, `minorHorizontalCollision`, `verticalCollision` | boolean | false | results of the latest move |
| supporting block | block position or none | none | 30 part 8 section 14.1.3 |
| `fallDistance` | double | 0 | section 12 |
| stuck multiplier | double x 3 | (0, 0, 0) | set by cobweb and the like, consumed by the next move |
| keys now | 7 booleans | all false | forward, backward, left, right, jump, shift, sprint |
| `jumping` | boolean | false | copy of the jump key taken in the input step |
| `noJumpDelay` | int | 0 | ticks before the next ground jump |
| `jumpTriggerTime` | int | 0 | flight double-tap window |
| `sprintTriggerTime` | int | 0 | sprint double-tap window |
| `crouching` | boolean | false | the client's slow-down flag (53 section 3.3) |
| pose, swimming flag | see 53 | standing, false | pose chosen at the end of each tick |
| fluid state | per fluid: height (double), eyes inside (boolean) | none | 29a section 8 |
| in powder snow now / last tick | boolean x 2 | false | section 7.3 |
| abilities | `flying`, `mayfly`, `flyingSpeed` (f32, default 0.05) | from Player Abilities | 05a, 05c |
| active effects | effect id to (amplifier, duration) | none | section 11 |
| attributes | base value and modifiers | 18 section 1.3, player movement speed base 0.10000000149011612 | section 11 |

---

## 2. Order of the client frame and of the player's tick

### 2.1 The frame (`Minecraft.runTick`, `Minecraft.tick`)

1. **Queued packets** are handled once, before any tick of the frame: Set Entity Motion, Explode, Player Position,
   Teleport Entity, Player Info Update (own game mode), Update Attributes, mob effects, abilities, entity data, entity
   events (sections 2.4 and 13). They are applied in arrival order.
   Then 0 or more client ticks run (the number due, at most 10).
2. In each tick, in this order: the interaction manager's tick; **key bindings** (`handleKeybinds`: attacks and item use,
   which can change the player's velocity, section 2.4); then **all client entities tick**, the local player among them;
   then **block entities tick** (moving pistons, shulker boxes, sulfur geysers can move or push the player here, section
   10); then the local player **sends its packets** (`sendChanges`: Player Input when the key record changed, Player
   Command for a sprint change, Move Player).

Client entities are iterated in the order of an insertion-ordered map (`EntityTickList`). Whether the local player is
ticked before or after a given mob therefore depends on when each was added; a push from a mob ticked after the player
changes the velocity used by the player's next tick, a push from a mob ticked before it is used in the same tick
(inferred from the map type; Open question 4).

### 2.2 One tick of the local player

Packet-phase writers (2.4) have already acted when the tick starts. The player's tick is skipped entirely until the
client has reported itself loaded (`LocalPlayer.tick`). Steps in order.
"Old keys" are the key record as it was at the end of the previous tick; "new keys" are the record read in step 12.

| # | Step | Keys read | Detail |
|---|---|---|---|
| 1 | save old position, `tickCount + 1` | | `Entity.commonTick`; the old position is used by section 9 |
| 2 | spectator sets no-physics; a spectator or passenger gets `onGround` false | | `Player.tick` |
| 3 | "under water" for this tick = the eyes were in water in the latest fluid update | | `updateIsUnderwater`; used by sprint (section 5) and swimming |
| 4 | the cached "block at my feet" is dropped; "in powder snow last tick" takes the value of "in powder snow now", which is cleared | | `Entity.baseTick` |
| 5 | **fluid update**: fluid heights and eyes; every update that finds the player in water resets `fallDistance`; **water and lava currents add to the velocity** (not while flying) | | 29a section 8 |
| 6 | swimming flag update (uses the sprint state left by the previous tick) | | 53 section 4 |
| 7 | in lava: `fallDistance x 0.5` | | `Entity.baseTick` |
| 8 | remaining effect durations count down | | section 11.1 |
| 9 | `sprintTriggerTime - 1` if above 0 | | `LocalPlayer.aiStep` from here to step 29 |
| 10 | remember old jump, old shift, old "forward impulse" | old | |
| 11 | `crouching` = not flying and not swimming and not a passenger and the crouching box fits and (shift, or (not sleeping and the standing box does not fit)) | **old** shift | 53 sections 2.4, 3.3 |
| 12 | **read the keys** (`ClientInput.tick`); the new move vector is formed (section 3.1) | new | |
| 13 | auto-jump: if its counter is above 0, subtract 1 and force the jump key on | | the trigger is not specified (Open question 1); the option `autoJump` is off by default (13 section 7.2) |
| 14 | **push out of suffocating blocks** (not no-physics, not a passenger): sets `vx` or `vz` | | section 4.4 |
| 15 | clear `sprintTriggerTime` if old shift, or the used item forbids sprinting and the player is not a passenger, or backward is held | old shift, new backward | section 5 |
| 16 | sprint start, then sprint stop | new keys, old forward impulse | section 5 |
| 17 | flight toggle (may call a ground jump) | old and new jump | section 7.8 |
| 18 | elytra start (out of scope) | new jump | |
| 19 | in water, shift held, affected by fluids: `vy = vy - 0.03999999910593033` | **new** shift | section 6.3 |
| 20 | flying and the player is the camera: flight vertical input is added to `vy` | **new** jump, shift | section 6.4 |
| 21 | `jumpTriggerTime - 1` if above 0; a flying non-passenger gets `fallDistance` 0 | | `Player.aiStep` |
| 22 | `noJumpDelay - 1` if above 0 | | `LivingEntity.aiStep` from here |
| 23 | **velocity clean-up** | | section 4.3 |
| 24 | **input applied**: strafe and forward impulses from the move vector, `jumping` = jump key; a dead or sleeping player then gets zero impulses and `jumping` false | new | section 3 |
| 25 | **jump** decision | `jumping` | section 6.1 |
| 26 | Slow Falling or Levitation present: `fallDistance` 0 | | section 12 |
| 27 | **travel** (includes the move, collision, block speed factor, gravity and drag) | live shift for the edge rule, ladder hold, bounce | sections 7 and 8 |
| 28 | **block effect pass**: step-on, then blocks and fluids touched | live shift | section 9 |
| 29 | landed while flying and not spectator: `flying` = false, send Player Abilities | | `LocalPlayer.aiStep` |
| 30 | end of the entity tick: attribute changes are processed, the post-impulse grace counter counts down | | |
| 31 | position clamped to +-2.9999999E7 on x and z | | `Player.tick` |
| 32 | **pose update** | **new** shift | 53 section 3 |

`LivingEntity.aiStep` ends with an entity-pushing call after step 28. For the local player it finds no target
(the client-side pushable test accepts only the local player, and an entity never pushes itself); the player is pushed
by **other** client entities running that call (section 13.4).

### 2.3 Which tick's sneak and shift value each rule uses

| Rule | Value | Effect of a key change on tick T |
|---|---|---|
| input slow-down by `sneaking_speed` (`crouching` flag, step 11) | **old** shift | starts and ends on tick T + 1 |
| sprint blocked because "moving slowly" (step 16) | the same flag, or crawling pose of the previous tick | T + 1 |
| `sprintTriggerTime` cleared (step 15) | old shift | T + 1 |
| sneak sink in water, flight descent (steps 19, 20) | new shift | T |
| edge back-off (53 section 5), ladder hold, no bounce, no slime step-on slow-down, powder snow and scaffolding "descending" | new shift (the live key) | T |
| pose at the end of the tick, camera, box for the next tick | new shift | T |

Worked (walking steadily, stored `vz` 0.1178591; shift pressed on tick T, forward held):

| Tick | slow flag | acceleration | z displacement |
|---|---|---|---|
| T (edge rule already active, pose becomes crouching at the end) | false | 0.098 | 0.2158591 |
| T + 1 | true | 0.0294 | 0.1472591 |
| T + 2 | true | 0.0294 | 0.1098035 |
| T + 3 | true | 0.0294 | 0.0893527 |
| steady | true | 0.0294 | 0.0647577 (1.295 blocks/s) |

On the tick shift is released the acceleration is still 0.0294; the next tick it is 0.098 again.

### 2.4 Every change to the local player's velocity

This is the list of writers found for the local player outside riding, gliding and item abilities (the ones left out are
named in Open question 2).

| When | Writer | Change |
|---|---|---|
| packet phase | Set Entity Motion for itself | replaces all three components (13.1) |
| packet phase | Explode with knockback | adds the vector (13.1) |
| packet phase | Player Position | sets velocity from the packet (13.2) |
| packet phase | Teleport Entity naming the local player, or its just-removed vehicle | sets velocity (and position) by the rules of 13.2 |
| packet phase | Player Info Update that changes the player's own game mode to spectator (`LocalPlayer.onGameModeChanged`) | `vy = 0` |
| packet phase | Entity Event 31 from a fishing hook that has hooked the player | adds `(owner - hook position) x 0.1` (13.1) |
| key bindings | the player's own attack that predicts a knockback | `vx x 0.6`, `vz x 0.6`, sprint ends (13.3) |
| step 5 and again inside the move | fluid current | adds (29a section 8.3; the second application in lava is section 7.5) |
| step 14 | push out of blocks | sets `vx` or `vz` to +-0.1 |
| steps 17, 25 | ground jump | sets `vy`, adds the sprint boost |
| step 25 | swim up | `vy + 0.04` |
| steps 19, 20 | sneak sink, flight vertical | adds to `vy` |
| step 23 | clean-up | zeroes small components |
| travel | swimming steering (53 section 9.1), acceleration, climbing clamp, climb-up, fluid drag, gravity, Levitation, air drag, ledge assist, flight `vy x 0.6` | section 7 |
| move | stuck multiplier zeroes velocity; collision restitution; block speed factor | section 8 |
| block effect pass | slime step-on, bubble column, honey slide | section 10 |
| entity ticks | entity push | adds `(x, z)` (13.4) |
| block entity ticks | geyser adds to `vy`; a slime block moved by a piston sets one component | section 10.5 |
| block entity ticks | inside a piston or shulker move: collision restitution, block speed factor, a pending stuck multiplier (velocity zeroed) | section 10.5 |
| block entity ticks | the block effect pass run at once by a piston move (slime step-on, bubble column, honey slide) | sections 9.2, 10 |

---

## 3. Input

### 3.1 The move vector (`KeyboardInput.tick`)

`mx` = +1 if left only, -1 if right only, else 0. `mz` = +1 if forward only, -1 if backward only, else 0. The pair is
normalised in single precision: `l = sqrt32(f32(mx x mx + mz x mz))`; if `l < 1.0E-4f` the vector is (0, 0), else
`(f32(mx / l), f32(mz / l))`. **Forward impulse** = the vector's `z` is above 1.0E-5f.

### 3.2 The modifiers (`LocalPlayer.modifyInput`, step 24; only while the player is the camera entity)

All in single precision, in this order. A zero vector passes unchanged.

1. Multiply by 0.98f.
2. If an item is being used and the player is not a passenger: multiply by the item's `use_effects.speed_multiplier`
   (default 0.2f).
3. If **moving slowly** (the `crouching` flag, or the swimming pose outside water): multiply by
   `f32(sneaking_speed attribute)` (default 0.3).
4. **Square correction**: let `l` be the length (`sqrt32`). If `l <= 0`, stop. `u = vector x f32(1 / l)`. **Distance to
   unit square** of `u`: with `ax = |u.x|`, `az = |u.z|`, `r = ax / az` if `az > ax` else `az / ax`;
   `D = sqrt32(f32(1 + f32(r x r)))`. `m = min(f32(l x D), 1.0f)`. Result = `u x m`.

`D` is the distance from the origin to the edge of the square `[-1, 1] x [-1, 1]` in the direction of `u`: 1 along an
axis, 1.4142135 on a diagonal, 1.118034 for the direction (1, 0.5).

The result's `x` becomes the strafe impulse `xxa`, `z` the forward impulse `zza`; the vertical impulse of a player is 0.
When the player is not the camera entity, instead the old impulses are multiplied by 0.98.

| Keys | Result (x, z) | Steady walk on friction 0.6 (blocks/tick) |
|---|---|---|
| forward | (0, 0.98) | 0.2158591 (4.317 blocks/s) |
| forward + left | (0.7071067, 0.7071067), length 1.0 | 0.2202643 (4.405 blocks/s; sprinting 5.727) (computed) |
| forward, sneaking | (0, 0.294) | 0.0647577 |
| forward + left, sneaking | (0.294, 0.294) | per axis as straight sneaking |
| forward, using a default item | (0, 0.196) | 0.0431718 (computed) |
| forward + left, using a default item | (0.196, 0.196) | as above per axis |

### 3.3 Turning the input into velocity (`Entity.moveRelative`, `getInputVector`)

Given the impulse vector `i = (xxa, 0, zza)` (widened to double) and an acceleration `a` (f32): if `|i|^2 < 1.0E-7`
nothing is added; if `|i|^2 > 1` normalise `i`; multiply by `a` (widened); then with `s = sin(yaw)`, `c = cos(yaw)`
(table values widened) add `(i.x x c - i.z x s, i.y, i.z x c + i.x x s)` to `v`. The pitch never enters.

Worked: yaw 90, forward on ordinary ground: `a = 0.1`, `i = (0, 0, 0.098)`: the velocity gains (-0.098, 0, 0) to
within the table's precision (computed).

---

## 4. Speeds, clean-up, push-out

### 4.1 The three accelerations

| Value | Rule |
|---|---|
| **speed** (`Player.getSpeed`) | `f32(movement_speed attribute value)`, read at the moment of use, so a sprint or attribute change made earlier in the same tick already counts. Walk 0.10000000149, sprint 0.13000001013 |
| **flying speed** (`Player.getFlyingSpeed`), the air acceleration | flying and not a passenger: `flyingSpeed` (x 2.0 when sprinting). Otherwise 0.025999999f when sprinting, else 0.02f. No attribute and no effect changes it |
| **ground acceleration** (`getFrictionInfluencedSpeed(F)`) | not on ground: flying speed. On ground with `(double)F > 0.6`: `f32(speed x f32(0.21600002f / f32(f32(F x F) x F)))`. On ground with `(double)F <= 0.6`: `speed` unchanged |

`(double)0.6f` is greater than 0.6, so ordinary ground uses the formula; its result equals `speed` to the last float.
Values for walking: ice, packed ice, frosted ice 0.0229496; blue ice 0.0223288; slime 0.0421875.

### 4.2 Friction and drag factors

Read in `LivingEntity.travelInAir`, `computeModifiedFriction`, `getAirDrag` and `Entity.getBlockPosBelowThatAffectsMyMovement`.

`mod(b, m) = clamp(f32(1 - f32(f32(1 - b) x m)), 0, 1)`.

* Ground friction `F` = `mod(block friction, f32(friction_modifier))`, with the block at the "below that affects
  movement" cell (30 part 8 section 14.1.3; 44 part 1 section 4.4), when `onGround`; else exactly 1.0. Both `onGround`
  and the cell are those left by the **previous** move, read before this tick's move.
* Horizontal drag = `f32(F x mod(0.91f, f32(air_drag_modifier)))`. Vertical drag = `mod(0.98f, f32(air_drag_modifier))`.
  With the default attributes: ordinary 0.5460001, ice 0.8918, blue ice 0.89999, slime 0.728, air 0.91; vertical 0.98f
  (0.9800000190734863).

Worked (the branch below 0.6): ordinary ground with `friction_modifier` 2: `F = mod(0.6f, 2) = 0.2000000`, acceleration
= speed (0.1) unchanged, horizontal drag 0.1820001; walking from rest displaces 0.098, 0.1158360, 0.1190822, toward
0.1198044 (computed).

### 4.3 Velocity clean-up (step 23)

For a player: if `vx^2 + vz^2 < 9.0E-6`, both `vx` and `vz` become 0 (they are judged together). If `|vy| < 0.003`,
`vy` becomes 0. Comparisons are strict.

Worked: (0.0029, -0.0029, 0) becomes (0, 0, 0). (0.0025, 0.003, 0.0025) is unchanged (sum of squares 1.25E-5).

### 4.4 Push out of suffocating blocks (`LocalPlayer.moveTowardsClosestSpace`, step 14)

Four probe points, in this order, with `w = (double)box width x 0.35` (0.21 for a width of 0.6):
`(x - w, z + w)`, `(x - w, z - w)`, `(x + w, z - w)`, `(x + w, z + w)`. For each probe:

1. `cell` = the block containing (probe x, feet y, probe z). A cell **suffocates** the player when the column of that
   cell's x and z, from the box's bottom to its top, shrunk by 1.0E-7, collides with a suffocating block (the
   per-block predicate of 24). If the cell does not suffocate, nothing happens for this probe.
2. Among WEST, EAST, NORTH, SOUTH, in that order, take the sides whose neighbour cell does not suffocate. The distance
   to a side is the probe's offset inside the cell on that axis, or `1 - offset` for EAST and SOUTH. The strictly smallest
   wins (the earlier side wins a tie).
3. If a side was found, the velocity component on its axis is **set** to `0.1 x step` (-0.1 for WEST and NORTH, +0.1
   for EAST and SOUTH); the other two components are kept. If none, nothing changes.

Later probes overwrite earlier ones on the same axis. The clean-up and travel follow in the same tick.

Worked: player at x = 10.9, z = 5.5; the column x = 11 is a suffocating block, x = 10 is free. Probes at x 11.11 are
in the suffocating cell; the nearest free side is WEST (offset 0.11), so `vx = -0.1`. Probes at x 10.69 do nothing.

---

## 5. Sprint (`LocalPlayer.aiStep`)

### 5.1 Conditions

* **Sprint possible(f)** = no Blindness effect, and (passenger: the vehicle allows it; otherwise: food level above 6.0
  or `mayfly`), and (`f` or not in shallow water). **Shallow water** = in water (latest fluid update) and not "under
  water" (step 3).
* **May start** = not sprinting, and forward impulse, and sprint possible(`flying`), and the used item does not forbid
  sprinting (`use_effects.can_sprint` false is the default while using any item), and (not gliding or under water), and
  (not moving slowly or under water).

### 5.2 Start (step 16, first half)

If may start: when the forward impulse was **absent** before the keys were read (old value): sprint if
`sprintTriggerTime > 0`, else set `sprintTriggerTime` to the option `sprintWindow` (default 7). Then, independently,
sprint if the sprint key is held.

### 5.3 Stop (step 16, second half, evaluated also for a sprint just started)

* Not swimming: stop if not sprint possible(`flying`), or no forward impulse, or (`horizontalCollision` and not
  `minorHorizontalCollision`). The two flags come from the previous tick's last move.
* Swimming: stop if not sprint possible(true), or not in water, or (no forward impulse and not on ground and shift not
  held).

Starting or stopping adds or removes the modifier `minecraft:sprinting` (+0.30000001192092896, multiply total) on
`movement_speed` at once on the client; the server learns it from Player Command (53 section 10.1).

Worked: standing on ground, forward and sprint pressed on tick T: sprint starts in step 16 and the travel of tick T
uses speed 0.13: displacement 0.1274000 on tick T. Walking steadily (stored `vz` 0.1178591) then pressing sprint:
displacements 0.2452591, 0.2613115, 0.2700761, steady 0.2806168. Double tap with window 7: forward pressed on tick 10
(timer set to 7, counting down at the start of each later tick), released, pressed again on tick 16 (timer 1):
sprint starts; pressed again on tick 17 (timer 0): it only restarts the window. Blindness arriving before tick T:
sprint ends in step 16 of tick T and the displacement of T uses the walk acceleration.

### 5.4 Minor horizontal collision (`LocalPlayer.isHorizontalCollisionMinor`)

Computed by the move step when `horizontalCollision` is true, from the **collided movement** `m` of that move and the
current impulses:

1. `d = (xxa x cos - zza x sin, zza x cos + xxa x sin)` (double arithmetic on the float impulses and table values).
2. If `|d|^2 < 9.999999747378752E-6`, or `m.x^2 + m.z^2 < 9.999999747378752E-6`: not minor.
3. `angle = acos((d.x x m.x + d.z x m.z) / sqrt(|d|^2 x (m.x^2 + m.z^2)))`. Minor when `angle < 0.13962633907794952`
   radians (8 degrees). A quotient above 1 gives NaN, which counts as not minor.

Worked: a wall on the +x side, collided movement (0, 0.2) along +z, forward held. Yaw -5 degrees: angle 4.999 degrees,
minor, sprint continues. Yaw -7.9: minor. Yaw -8.1: not minor. Yaw -30: not minor, sprint stops on the next tick.

---

## 6. Jumping and the vertical keys

### 6.1 The jump decision (step 25, `LivingEntity.aiStep`)

If `jumping` is false, **or** the player is not affected by fluids (that is, flying): set `noJumpDelay = 0` and do
nothing else. Otherwise let `h` = the lava height if in lava, else the water height (29a); `W` = in water and `h > 0`;
`T` = the jump threshold: 0.4, or 0 when the eye height is below 0.4 (the swimming pose's 0.4 is not below, so players
always have 0.4 at scale 1). First matching branch:

1. `W` and (not on ground or `h > T`): swim up in water.
2. In lava and (not on ground or `h > T`): swim up in lava.
3. (On ground, or (`W` and `h <= T`)) and `noJumpDelay = 0`: ground jump, then `noJumpDelay = 10`.
4. Otherwise nothing.

| Situation (jump held) | Result |
|---|---|
| on dry ground, delay 0 | ground jump |
| standing in a source block of water 1 deep (height 0.888889) | `vy + 0.04` |
| standing in water of height 0.333 on the floor | ground jump |
| standing in lava of height 0.333 | ground jump |
| in water, off the ground, any height | `vy + 0.04` |
| flying | nothing; delay cleared |

### 6.2 Ground jump (`LivingEntity.jumpFromGround`)

Power `p = f32(f32(f32(jump_strength) x 1.0f x blockJumpFactor) + boost)`, with `blockJumpFactor` of section 8.4 and
`boost = f32(0.1f x f32(amplifier + 1))` with Jump Boost, else 0. If `p <= 1.0E-5f` nothing happens. Else
`vy = max((double)p, vy)`; if sprinting add `(-sin(yaw) x 0.2, 0, cos(yaw) x 0.2)`.

The jump runs before travel, so the same tick moves by the new velocity, and that tick still uses the ground friction
(`onGround` is still true).

### 6.3 Swim up and sink

`jumpInLiquid`: `vy + 0.03999999910593033`. `goDownInWater` (step 19): `vy - 0.03999999910593033`; in water only, not
in lava.

### 6.4 Flight vertical input (step 20)

`n = (1 if jump) - (1 if shift)`. If `n != 0`: `vy = vy + (double)f32(f32((float)n x flyingSpeed) x 3.0f)`
(0.15000000596046448 with 0.05). Sprinting does not change it.

---

## 7. Travel

### 7.1 Which branch

1. `Player.travel`: a passenger goes straight to the living-entity rule. Otherwise: when swimming, the pitch steering of
   53 section 9.1; then, when flying, the wrapper of 7.8 around the living-entity rule.
2. Living-entity rule: if in water or lava **and** affected by fluids (not flying) the **fluid** branch (water if in
   water, else lava); else gliding (out of scope); else the **air** branch. The fluid state of the block at the feet
   position is not required.

### 7.2 Air and ground (`travelInAir`)

Read in `LivingEntity.travelInAir`, `handleRelativeFrictionAndCalculateMovement`, `handleOnClimbable`, `getEffectiveGravity` and `Entity.moveRelative`.

1. `F` (4.2).
2. `moveRelative(ground acceleration(F), input)` (3.3, 4.1).
3. **Climbing clamp** when on a climbable (7.3): `fallDistance = 0`; `vx` and `vz` clamped to
   +-0.15000000596046448; `vy = max(vy, -0.15000000596046448)`; then, if `vy < 0`, shift is held (and not flying), and
   the block at the feet is not scaffolding, `vy = 0`.
4. **Move** with `v` (section 8).
5. **Climb up**: if (`horizontalCollision` or `jumping`) and (on a climbable at the new position, or in powder snow
   last tick with leather boots), `vy = 0.2`.
6. **Vertical**. Two vertical values exist here. The **working** value `w` is the velocity after the move with the
   0.2 of step 5 written into it when that step applied; the **stored** velocity `vy` is still what the move left
   (restitution and block speed factor applied, no 0.2). With Levitation, `w = w + (0.05 x (amplifier + 1) - w) x 0.2`.
   Otherwise `w = w - g`, where `g` is the effective gravity: the `gravity` attribute (0.08), or `min(gravity, 0.01)`
   when Slow Falling is present and the **stored** `vy` is <= 0 (`LivingEntity.getEffectiveGravity` reads the stored
   velocity). Client guard: if the chunk of the below-affecting cell **taken before the move** (the cell step 1 read) is
   not loaded, `w` is instead -0.1 when the player's y after the move is above the world's minimum y, else 0 (this
   replaces gravity only, not Levitation).
7. **Drag** and store: the velocity becomes (`vx` x horizontal drag, `w` x vertical drag, `vz` x horizontal drag)
   (4.2).

Worked (Slow Falling against a ladder): on the floor with Slow Falling already active, the stored value is
`vy = (0 - 0.01) x 0.98f = -0.0098` (-0.0784 only on the tick the effect arrives; the rest of the example is the same).
The player pushes into a ladder wall. The move is stopped and restitution leaves the stored `vy` 0; step 5 sets
`w = 0.2`; the stored value is not above 0, so `g = 0.01`; the tick ends with `vy = (0.2 - 0.01) x 0.98f = 0.1862000`. The next tick
moves up 0.1862, the stored value is then positive, so `g = 0.08` and it ends with `(0.2 - 0.08) x 0.98f = 0.1176000`.

Worked (unloaded chunk guard): airborne above the minimum y with the chunk below not loaded, the move uses the old
`vy`, then `vy = -0.1 x 0.98f = -0.0980000` each tick.

#### Worked: start, stop, sprint on ordinary ground

From rest, forward held: displacement per tick 0.0980000, 0.1515080, 0.1807234, 0.1966750, 0.2053846, 0.2101400,
0.2127364, 0.2141541, then toward 0.2158591 (4.317 blocks/s). Stored `vz` after each tick: 0.0535080, 0.0827234,
0.0986750, 0.1073846, 0.1121400, 0.1147364, 0.1161541, 0.1169282, toward 0.1178591.

Release from steady: displacement 0.1178591, 0.0643511, 0.0351357, 0.0191841, 0.0104745, 0.0057191, 0.0031226, then 0
(the stored 0.0017050 is cleared); **total 0.2558461 blocks**. Sprint steady: 0.2806168 (5.612 blocks/s), stored
0.1532168; release without pressing anything: 0.1532168, 0.0836564, 0.0456764, 0.0249393, 0.0136169, 0.0074348,
0.0040594, then 0; total 0.3325999.

On the ground each tick ends with `vy = (0 - 0.08) x 0.98f = -0.0784000015`; the next move requests it, collides, and
restitution sets 0 before gravity runs again.

#### Worked: from ordinary ground onto ice, and releasing on ice

Cells with z < 10 are stone (0.6), cells with z >= 10 are ice (0.98), same height. The player walks toward +z steadily:
stored `vz` 0.1178591, z = 9.5 before tick 1. The supporting cell is the one under the box nearest the player's centre,
so it changes when the centre crosses z = 10, and the **next** tick's travel reads the new friction.

| Tick | F used | acceleration added | z displacement | blocks/s | z after | stored `vz` after |
|---|---|---|---|---|---|---|
| 1 | 0.6 | 0.0980000 | 0.2158591 | 4.317 | 9.7158591 | 0.1178591 |
| 2 | 0.6 | 0.0980000 | 0.2158591 | 4.317 | 9.9317181 | 0.1178591 |
| 3 | 0.6 | 0.0980000 | 0.2158591 | 4.317 | 10.1475772 | 0.1178591 (stone drag, although now over ice) |
| 4 | 0.98 | 0.0224906 | 0.1403497 | 2.807 | 10.2879269 | 0.1251639 |
| 5 | 0.98 | 0.0224906 | 0.1476545 | 2.953 | 10.4355814 | 0.1316783 |
| 6 | 0.98 | 0.0224906 | 0.1541689 | 3.083 | 10.5897503 | 0.1374878 |
| 7 | 0.98 | 0.0224906 | 0.1599785 | 3.200 | 10.7497288 | 0.1426688 |
| 8 | 0.98 | 0.0224906 | 0.1651594 | 3.303 | 10.9148882 | 0.1472892 |
| 9 | 0.98 | 0.0224906 | 0.1697798 | 3.396 | 11.0846680 | 0.1514097 |
| 10 | 0.98 | 0.0224906 | 0.1739003 | 3.478 | 11.2585683 | 0.1550843 |
| 11 | 0.98 | 0.0224906 | 0.1775749 | 3.551 | 11.4361432 | 0.1583613 |
| 12 | 0.98 | 0.0224906 | 0.1808519 | 3.617 | 11.6169952 | 0.1612838 |
| 22 | 0.98 | 0.0224906 | 0.1992677 | 3.985 | 13.5438269 | 0.1777070 |
| 23 | 0.98 | 0.0224906 | 0.2001976 | 4.004 | 13.7440245 | 0.1785362 |
| 45 | 0.98 | 0.0224906 | 0.2072446 | 4.145 | 18.2588996 | 0.1848208 |
| steady | 0.98 | 0.0224906 | 0.2078617 | 4.157 | | 0.1853711 |

The dip is a single step to 2.807 blocks/s on the first tick that uses ice friction; the speed is above 4 blocks/s
again on tick 23, the 20th tick on ice.

Release while walking steadily on ice: displacement 0.1853711, 0.1653140, 0.1474270, 0.1314754, 0.1172498, 0.1045633,
0.0932496, 0.0831600, 0.0741621, 0.0661378, 0.0589817, 0.0525998, ... the 35th to 37th are 0.0037769, 0.0033682,
0.0030038; the stored 0.0026788 is then cleared. **Total 1.6884693 blocks in 37 ticks.**

Release during the transition (forward released on tick 12 of the table): tick 12 displaces 0.1583613, then 0.1412266,
0.1259459, 0.1123186, 0.1001657; from tick 12 on the slide totals 1.4370047.

**Back onto ordinary ground** (from steady ice speed, ice for z < 1, stone after, z = 0.5 before tick 1): ticks 1 to 3
displace 0.2078617 (tick 3 ends at z = 1.1235852); tick 4 adds the full 0.098 to the retained 0.1853711 and displaces
**0.2833711 (5.667 blocks/s)**; then 0.2527206, 0.2359855, 0.2268481, 0.2218591, 0.2191351, 0.2176478, toward
0.2158591. The speed first rises and then falls back over a few ticks.

#### Worked: jumps

Plain jump from rest. Tick: y displacement, height after, stored `vy` after.

| Tick | dy | height | `vy` |
|---|---|---|---|
| 1 | 0.4200000 | 0.4200000 | 0.3332000 |
| 2 | 0.3332000 | 0.7532000 | 0.2481360 |
| 3 | 0.2481360 | 1.0013360 | 0.1647733 |
| 4 | 0.1647733 | 1.1661093 | 0.0830778 |
| 5 | 0.0830778 | 1.2491871 | 0.0030163 |
| 6 | 0.0030163 | **1.2522033** | -0.0754441 |
| 7 | -0.0754441 | 1.1767593 | -0.1523352 |
| 8 | -0.1523352 | 1.0244241 | -0.2276885 |
| 9 | -0.2276885 | 0.7967356 | -0.3015347 |
| 10 | -0.3015347 | 0.4952009 | -0.3739040 |
| 11 | -0.3739040 | 0.1212968 | -0.4448260 |
| 12 | -0.1212968 (stopped by the ground) | 0 | -0.0784000 |

The third value of tick 5, 0.0030163, survives the clean-up (not below 0.003). With jump held, tick 13 jumps again
(`noJumpDelay` set to 10 on tick 1 has reached 0).

Sprint jump from steady sprint (stored `vz` 0.1532168): tick 1 displaces 0.4806168 (0.1532168 + 0.2 boost + 0.1274),
stored 0.2624168; ticks 2 to 12 (air, accel `0.98 x 0.026`) displace 0.2878968, 0.2874661, 0.2870742, 0.2867175,
0.2863929, 0.2860976, 0.2858288, 0.2855842, 0.2853616, 0.2851591, 0.2849748; total 3.6291704, stored after landing tick
0.2593271 (air drag, because the landing tick started airborne).

Walking jump (stored 0.1178591): displacements 0.2158591, 0.1374591, 0.1446878, 0.1512659, 0.1572519, 0.1626993,
0.1676563, 0.1721673, 0.1762722, 0.1800077, 0.1834070, 0.1865004; total 2.0352341.

#### Worked: air control and free fall

Airborne from horizontal rest, forward held: displacement 0.0196000, 0.0374360, 0.0536668, 0.0684368. Airborne with
stored 0.25 and no keys: 0.25, 0.2275, 0.2070250, 0.1883928 (momentum is kept; only drag 0.91 acts).

Free fall from `vy = 0`: displacements 0, -0.0784, -0.155232, -0.2305274, -0.3043168, -0.3766305, -0.4474979,
-0.5169479, -0.5850090, -0.6517088; terminal -3.92.

### 7.3 Climbing

Read in `LivingEntity.onClimbable`, `trapdoorUsableAsLadder`, `handleOnClimbable`, `Player.onClimbable`, `PowderSnowBlock.canEntityWalkOnPowderSnow` and the tag file `climbable`.

**On a climbable** (`LivingEntity.onClimbable`, `Player.onClimbable`): false for a spectator, for a flying player, and
for a gliding player whose feet block is in tag `can_glide_through`. Otherwise test **one cell: the block containing the
feet position**. True when its state is in block tag `climbable` (`ladder`, `vine`, `scaffolding`, `weeping_vines`,
`weeping_vines_plant`, `twisting_vines`, `twisting_vines_plant`, `cave_vines`, `cave_vines_plant`), or when it is a
**trapdoor** (any trapdoor block class) that is **open**, the block directly below is the block `ladder` (no other
climbable counts), and the ladder's `facing` equals the trapdoor's `facing`.

**Powder snow** is not climbable. It gives only the climb-up of 7.2 step 5: the player was in powder snow in the previous
tick's block effect pass (section 10.2) and wears `leather_boots` on the feet, and presses jump or collides
horizontally. It applies no clamp, no sneak hold and no fall reset of its own.

Horizontal limit: |vx|, |vz| at most 0.15 per tick on a climbable, before the move.

Worked (ladder, pushing into the wall, starting at the floor with `vy` -0.0784): tick 1 moves up 0 and ends with
`vy = (0.2 - 0.08) x 0.98f = 0.1176000`; each later tick moves up **0.1176000** (2.352 blocks/s). Jump held on a ladder
gives the same 0.1176. No keys, falling: each tick moves **-0.1500000** (stored -0.2254000, clamped again next tick).
Shift held: moves 0 each tick (stored -0.0784). A horizontal velocity 0.28 entering the cell is clamped to 0.15.
Open trapdoor facing north above a north-facing ladder: climbable; facing south above it: not.

Worked (powder snow, leather boots, jump held, inside the snow): the stuck multiplier makes the move 1.5 x the stored
`vy` and zeroes the velocity; step 5 sets 0.2; stored `vy` = 0.1176000; the next tick rises 0.1176 x 1.5 =
**0.1764000**.

### 7.4 Water (`travelInFluid`, `travelInWater`)

Read in `LivingEntity.travelInFluid`, `travelInWater`, `getFluidFallingAdjustedMovement` and `getEffectiveGravity`.

At entry remember `falling` = (`vy <= 0`), `startY` = y, and `g` = the effective gravity (0.08; 0.01 with Slow Falling
while `vy <= 0`). Then:

1. `d` = 0.9f if sprinting, else 0.8f. `a` = 0.02f.
2. `e = f32(water_movement_efficiency)`; if not on ground `e = f32(e x 0.5f)`. If `e > 0`:
   `d = f32(d + f32(f32(0.54600006f - d) x e))`, `a = f32(a + f32(f32(speed - a) x e))`.
3. With Dolphin's Grace `d` = 0.96f (replaces the value from 1 and 2; `a` keeps the value from 2).
4. `moveRelative(a, input)`.
5. Move (section 8).
6. If `horizontalCollision` and on a climbable: `vy = 0.2`.
7. `v = (vx x d, vy x 0.800000011920929, vz x d)`.
8. **Fluid falling adjustment**: only when `g != 0` and not sprinting. If `falling` and `|vy - 0.005| >= 0.003` and
   `|vy - g/16| < 0.003`, then `vy = -0.003`; else `vy = vy - g/16`. (With `g` = 0.08 the two tests exclude each other,
   so the -0.003 case occurs only with a smaller gravity such as Slow Falling's.)
9. Ledge assist (7.6).

Levitation and the air drag factors do not act in water.

| Case (from rest) | Displacements, first ticks | Steady per tick |
|---|---|---|
| wading on the floor, forward, no sprint (z) | 0.0196, 0.03528, 0.047824 | 0.098 (1.96 blocks/s) |
| swimming with sprint, level look (z) | 0.0196, 0.03724, 0.053116 | 0.196 (3.92 blocks/s) |
| Dolphin's Grace, sprinting (z) | 0.0196, 0.038416, 0.0564794 | 0.4899997 (9.80 blocks/s) |
| sinking, no keys (y) | 0, -0.005, -0.009, -0.0122, -0.01476 | -0.025 (0.5 blocks/s) |
| jump held, deep water (y) | 0.04, 0.067, 0.0886, 0.10588, 0.119704 | 0.175 (3.5 blocks/s) |
| shift held, not swimming (y) | -0.04, -0.077, -0.1066, -0.13028, -0.149224 | -0.225 (4.5 blocks/s) |
| Slow Falling, sinking (y) | 0, -0.003, -0.003025, -0.003045, -0.003061 | -0.003125 |

Wading on the floor: the move requests `vy = -0.005`, is stopped, restitution zeroes it, and step 8 sets -0.005 again.

Worked (water climb-up): not sprinting, in water, pushing into the wall of a waterlogged ladder, `vy = -0.005`, with
water above so that the ledge assist is not free. Step 6 sets 0.2, step 7 gives 0.16, step 8 (the entry flag is
`falling`) gives 0.155: stored `vy = 0.1550000`. The next tick moves up 0.155 and ends at 0.155 again (3.1 blocks/s).

### 7.5 Lava (`travelInLava`)

Read in `LivingEntity.travelInLava`, `isInShallowFluid`, `checkFallDamage`, `Entity.updateFluidInteraction` and `EntityFluidInteraction`.

1. `moveRelative(0.02f, input)`; move.
2. If the lava height is at most the jump threshold (shallow): `v = v x (0.5, 0.800000011920929, 0.5)`, then the fluid
   falling adjustment of 7.4 step 8, **including its sprint exception**. Otherwise `v = v x 0.5` on all axes (no
   adjustment).
3. If `g != 0`: `vy = vy - g/4`.
4. Ledge assist.

Depth Strider, Dolphin's Grace and the sprint drag do not apply. A climbable gives no 0.2 in lava.

The lava current is applied twice per tick to a player standing or moving in lava: in step 5 of the tick and again
inside the move, because the fall handling of a move (section 12.1) first re-runs the fluid update whenever the player
was not in **water**; that second update also refreshes the lava height that step 2 reads. A player who was in water at
the start of the move gets no second update.

Worked (fluid current; `EntityFluidInteraction`, 29a section 8.3). Flow average (1, 0, 0), fluid height on the player at
least 0.4, no keys, player at horizontal rest.

* Water, strength 0.014, applied once per tick (step 5), then travel multiplies by 0.8: x displacements 0.014, 0.0252000,
  0.0341600, 0.0413280, toward 0.07 per tick (stored toward 0.056).
* Lava outside a fast-lava dimension, strength 0.0023333333333333335, applied twice. Tick 1: step 5 finds `|vx|` below
  0.003 and the push below 0.0045, so it adds 0.0045; the move displaces **0.0045**; the second application adds
  0.0023333 (no minimum now, `|vx|` is 0.0045); travel halves: stored 0.0034167. Tick 2: step 5 gives 0.0057500 (the
  displacement), the second application 0.0080833, stored 0.0040417. Displacements 0.0045, 0.0057500, 0.0063750,
  0.0066875, toward 0.007 per tick (stored toward 0.0046667).
* Fast lava (0.007): displacements 0.007, 0.014, 0.0175, toward 0.021 (stored toward 0.014).

| Case (deep lava, from rest) | Displacements | Steady |
|---|---|---|
| forward (z) | 0.0196, 0.0294, 0.0343 | 0.0392 (0.784 blocks/s) |
| no keys (y) | 0, -0.02, -0.03, -0.035 | -0.04 |
| jump held (y) | 0.04, 0.04, 0.04 (stored 0 each tick) | 0.04 |
| shift held (y) | 0, as no keys (sneak sink is water only) | -0.04 |
| shallow lava, falling free, no keys (y) | 0, -0.025, -0.045, -0.061 | -0.125 |
| shallow lava on the floor, forward (z) | 0.0196, 0.0294, 0.0343 | 0.0392 |

### 7.6 Ledge assist (`jumpOutOfFluid`), water and lava

Read in `LivingEntity.jumpOutOfFluid`, `Entity.isFree` and `LevelReader.containsAnyLiquid`.

If `horizontalCollision`, form the player's **current** box moved by
`(vx, vy + 0.6000000238418579 - y + startY, vz)` with the velocity as it stands now. Its bottom is therefore at
`startY + 0.6000000238418579 + vy`. The box is **free** when it collides with no block shape, no collidable entity and
not the world border, **and** every block cell it touches, from `floor(min)` to `floor(max)` on each axis, has an empty
fluid state (any fluid in such a cell, however low, blocks it, including a waterlogged block). If free,
`vy = 0.30000001192092896`.

The blocked axis was zeroed by the collision, so the box is not pushed into the wall by the test.

Worked: water in the cells y = 62 and below, air from y = 63; pushing against a bank whose top is y = 63; `vy = -0.005`.
With `startY = 62.45` the box bottom is 63.045: free, `vy = 0.3`. With `startY = 62.30` the bottom is 62.895: cell 62
holds water, not free (although the surface is at about 62.889).

### 7.7 Swimming steering

The pitch steering applied before travel while swimming is 53 section 9.1; the steady speeds are 53 section 9.2.

### 7.8 Flight

**Toggle** (step 17, only with `mayfly`). A spectator who is not flying starts flying at once. Otherwise, on a rising
edge of jump (old false, new true) in a tick where auto-jump did not force the key: if `jumpTriggerTime = 0` set it to 7;
else, if not swimming, and either not riding or riding a vehicle that can jump: toggle `flying`; if it became true and
the player is on the ground, do a ground jump; send Player Abilities; set `jumpTriggerTime = 0`. The window is described
in 13 section 1.4.

**Travel while flying**: remember `vy`, run the normal living-entity travel (which is the air branch; its acceleration
is the flying speed when the tick starts off the ground; a flying tick that starts with `onGround` true, such as one in
which flight was toggled on from the ground, uses ground friction and the ground formula of 4.1 with the speed
attribute), then set `vy = remembered x 0.6`. Whatever travel did to `vy` (collision, bounce, gravity,
Levitation) is overwritten; the block effect pass runs afterwards and can still change it.

| Behaviour while flying | Applies? |
|---|---|
| ground jump | only the toggle's jump (it uses the block jump factor); the jump key otherwise does nothing but move vertically |
| climbing (clamp, hold, climb up on climbables) | no: never "on a climbable". Powder snow climb-up is not gated by flight |
| water and lava travel, currents, sneak sink, swimming | no (shift means descend) |
| stuck blocks (cobweb, berry bush, powder snow) | no: the multiplier is not set and the fall distance is not reset by them |
| bubble columns | no |
| honey slide | the rule has no flight test: it applies when its conditions hold |
| block speed factor | no (factor 1) |
| bounce | the restitution step runs; the vertical result is overwritten by the 0.6 rule; horizontal results use the `bounciness` attribute (0) |
| step-on (slime) | yes, on the landing tick if shift is not held (horizontal factor) |
| edge back-off | no |
| landing | step 29 ends the flight |
| geyser | no launch (10.5) |
| fall distance | reset every tick (step 21) |

Worked (vertical): jump held from `vy = 0`: displacements 0.15, 0.24, 0.294, 0.3264, 0.34584, 0.357504, toward 0.375
(7.5 blocks/s). Horizontal forward from rest: 0.049, 0.09359, 0.1341669, 0.1710919, toward 0.5444446 (10.89 blocks/s;
1.0888892, 21.78 blocks/s sprinting). Release all keys from `vz` stored 0.4954446 and `vy` stored 0.225: z moves
0.4954446, then each tick x 0.91, total 5.4742 blocks over 55 ticks; y moves 0.225, 0.135, 0.081, 0.0486, ..., total
0.5568 over 9 ticks. Each axis ends when the clean-up of 4.3 zeroes it.

Worked (flight ends on landing, step 29): creative, flying 0.2 above a floor with stored `vy = -0.225`, shift held.
Step 20 makes `vy = -0.375`; the move goes down 0.2 and lands (`onGround` true); the flight rule stores -0.225; step 29
clears `flying` and sends Player Abilities. The next tick is an ordinary one: it requests -0.225, is stopped, and ends
with `vy = -0.0784`; because shift was held on the previous tick the player is already slowed (step 11).

Worked (a flying tick that starts on the ground): creative, forward and jump held, stored velocity
(0, -0.0784, 0.1178591) on stone, and the second tap of the toggle lands on a tick on which `onGround` is true. Step 17
turns flight on and jumps (`vy = 0.42`); step 20 adds 0.15 (`vy = 0.57`). Travel starts with `onGround` true: the
acceleration is the ground value 0.098 and the drag 0.546: displacement (y 0.57, z 0.2158591), stored
(y 0.342, z 0.1178591). The next tick is airborne: `vy = 0.342 + 0.15 = 0.492`, acceleration 0.049: displacement
(y 0.492, z 0.1668591), stored (y 0.2952, z 0.1518418).

Worked (double tap while already jumping, creative): first tap on tick 1 (ground jump, window 7), key up on tick 2,
second tap on tick 3: flight on, then step 20 adds 0.15 to the stored 0.2481360: the tick moves up 0.3981360 and ends
with `vy = 0.3981360 x 0.6 = 0.2388816`.

---

## 8. The move step, as it affects velocity

### 8.1 Order (`Entity.move`)

30 part 8 section 14.1.1 gives the whole pipeline; these are the parts that matter to a player.

1. No-physics (spectator): add the movement to the position, clear all collision flags, stop.
2. A piston movement is first limited (30 part 3 section 8.3).
3. If the stuck multiplier's squared length is above 1.0E-7: multiply the requested movement by it (not for a piston
   movement), clear the multiplier, and **set the velocity to (0, 0, 0)**.
4. Edge back-off while sneaking (53 section 5) changes the **requested movement only**, not the velocity.
5. Collision with step-up (51 section 6.1) gives the **collided movement** `m`.
6. Fall-distance clip (12.3).
7. Position update and movement record (condition: 30 part 8 section 14.1.1 step 2).
8. `horizontalCollision`: requested and collided x, or z, differ by 9.999999747378752E-6 or more (a smaller
   difference counts as equal). Vertical flags and `onGround`: always updated for the local player (it is the authoritative instance, so also
   when the requested y is 0): `verticalCollision` = requested y differs from collided y exactly;
   `verticalCollisionBelow` = that and requested y < 0; `onGround` = `verticalCollisionBelow`; supporting block updated.
9. `minorHorizontalCollision` (5.4), false without a horizontal collision.
10. Fall handling (12.1), on the client too.
11. **Restitution** (8.2), when (requested y != 0 and `verticalCollision`) or `horizontalCollision`.
12. Step sounds and game events (30 part 8 section 14.1).
13. **Block speed factor** (8.3): `vx x f`, `vz x f`.

### 8.2 Restitution (collision response)

Read in `Entity.restituteMovementAfterCollisions`, `getBlockBounciness` and `LivingEntity.getEntityBounciness`.

Let `b` = 0 if shift is held, else the `bounciness` attribute (player default 0). A collided x (z) axis gets
`vx = -vx x b` (`vz = -vz x b`). If `verticalCollision`:

* from above (not `verticalCollisionBelow`): `e = b`;
* from below: `e = 0` if `-vy <= effective gravity`, or shift is held, or the block at the legacy cell (`getOnPosLegacy`,
  30 part 8 section 14.1.3) is in tag `suppresses_bounce` (`honey_block`); else
  `e = max(b, block bounce restitution)`.
* If `e > 0`: `q = m.y / vy`, `G = q x g`, `L = 1 + q x ((double)verticalDrag - 1)`; else `G = 0`, `L = 1`.
* `vy = (G - vy) x L x e`.

`g` is the effective gravity at that moment. `v` is the stored velocity before this step (not the requested movement).
With no bounce the blocked components become 0: running into a wall removes the speed into the wall and keeps the speed
along it.

Worked: moving diagonally with `v = (0.2, -0.0784, 0.15)` on the ground into a wall on +x: after restitution
`v = (0, 0, 0.15)`, then gravity and drag.

### 8.3 Block speed factor

Read in `Entity.getBlockSpeedFactor`, `LivingEntity.getBlockSpeedFactor` and `Player.getBlockSpeedFactor`.

Not applied (factor 1) while flying or gliding. Otherwise take the speed factor of the block containing the feet
position **after** the move. If that block is `water` or `bubble_column`, use its factor. Else if it is exactly 1.0, use
the factor of the below-affecting cell. Then `f = base + e x (1 - base)` in single precision, `e` = the
`movement_efficiency` attribute. Only `vx` and `vz` are multiplied, before gravity and drag of the same tick.

### 8.4 Block jump factor

Read in `Entity.getBlockJumpFactor`.

Factor of the block containing the feet position; if exactly 1.0, that of the below-affecting cell. No water
exception, no attribute, no flight test.

| Worked (walking, forward held) | Result |
|---|---|
| soul sand (feet inside its cell at height 0.875; `f` = 0.4) | displacements 0.098, 0.1194032, 0.1240777, 0.1250986, toward 0.1253838 (2.508 blocks/s) |
| honey block (`f` = 0.4) | the same numbers |
| soul sand with `movement_efficiency` 0.5 | `f` = 0.7 |
| feet in a water cell above soul sand | `f` = 1.0 (water's factor) |
| jump from soul sand | factor 1.0: power 0.42 |
| jump from honey | power 0.21: heights 0.2100, 0.3374, 0.3838520 (peak), 0.3509749, 0.2403554, 0.0535483, lands on tick 7 |

Worked (edge back-off keeps velocity): sneaking toward a ledge, stored `vx` 0.0353577, acceleration 0.0294: the
requested move 0.0647577 is cut by the edge rule to 0.0147577 (one 0.05 step of 53 section 5.3, for a box in the
position of 53 section 5.4 with `minX` 0.94); the move reports no horizontal collision, so the stored velocity stays
0.0647577 and ends the tick at 0.0353577.

---

## 9. The block effect pass

### 9.1 When it runs

Read in `LivingEntity.aiStep` and `Entity.applyEffectsFromBlocks`.

For the local player, **on the client, every tick**, right after travel (step 28), and on the server for each player in
its own tick (39 section 2.2a, 30 part 8 section 14.1.11). Not for a spectator. Two parts:

1. If `onGround`: the **step-on** hook of the block at the legacy cell. No sneak or flight test in the dispatcher.
2. The **inside pass** over the tick's movement records.

### 9.2 Movement records

Read in `Entity.move`, `addMovementThisTick`, `applyEffectsFromBlocks` and `removeLatestMovementRecording`.

Each move that updated the position adds a record (start, end, requested movement). At the pass: if there is no record,
use one record from the position at the start of the tick to the current position, without a requested movement; else if
the current position is more than 1.0E-5 from the last record's end (squared distance above 9.999999439624929E-11),
append one more such record. All records are consumed. A player standing still has no record (a fully blocked move is not
recorded), so one zero-length record is tested.

Block entity moves happen after the player's pass (`PistonMovingBlockEntity.moveEntityByPiston`,
`ShulkerBoxBlockEntity.moveCollidedEntities`):

* A **shulker** move is recorded like any move and is processed by the next tick's pass.
* A **piston** move is processed **at once**: right after the move, the whole pass of 9.1 (step-on if `onGround`, then
  the inside pass) runs over one record from the old position to the new one, with no requested movement, and then the
  latest stored movement record is dropped (30 part 3 section 8.3). The record dropped is normally the one this move
  added; if the move added none (limited to zero or fully blocked), the latest earlier record, if any, is dropped.

Worked (an earlier record dropped; a constructed case): in one block entity phase a shulker box lid first moves the
player (record A is stored), then a moving piston block pushes the player toward a wall the player already touches. The
piston move is fully blocked and adds no record; the immediate pass runs over a zero-length record at the player's
position; then record A, now the latest, is dropped. No later pass walks the shulker move: the next tick's pass sees
only that tick's own records (or, with none, the one built from the start-of-tick position).

Worked: a player who walks one tick on flat ground has one record with requested movement (0, -0.0784, 0.2158591) and
displacement (0, 0, 0.2158591): one leg along z. A player standing still has no record; the pass tests one zero-length
record at its position.

### 9.3 Cell order

Read in `Entity.checkInsideBlocks`, `Direction.axisStepOrder`, `BlockGetter.forEachBlockIntersectedBetween` and `BlockPos.betweenClosed`, `betweenCornersInDirection`.

A record with a requested movement and a non-zero displacement is cut into up to three straight legs, one per non-zero
component of the displacement, in the axis order of the requested movement: y first; then z before x if
`|x| < |z|`, else x before z. Other records are one leg. Each record has a budget of 16 steps shared by its legs; if it
is used up, the cells of the box at the record's end are tested once more.

For one leg with vector `d`, let `E` = the player's box at the leg's end, shrunk by 9.999999747378752E-6 on every side,
and `S` = `E` moved by `-d`. **Directional order** of a block of cells: three nested loops, outermost y, middle x if
`|d.x| >= |d.z|` else z, innermost the remaining axis; each axis runs upward when that component of `d` is >= 0, else
downward.

* **Short leg** (`|d|^2 < (1.0E-5f)^2`): the cells from `floor(min E)` to `floor(max E)`, x changing fastest, then y,
  then z. All at step 0.
* **Otherwise**: (a) the cells of `S`, directional order, step 0; (b) the corner walk; (c) the cells of `E` not listed in
  (a) or (b), directional order, with step = last walk step + 1.

**Corner walk** (`BlockGetter.addCollisionsAlongTravel`, `getFurthestCorner`). It follows one corner of the moving box
through the grid.

*Which corner.* Let `sx, sy, sz` be +1 for a component of `d` that is >= 0 and -1 otherwise. The corner vector `c`
depends on which component of `d` is smallest in absolute value; on equal sizes x counts as smallest before y, and y
before z.

| Smallest of `d` | Corner vector `c` |
|---|---|
| x | `(-sx, -sz, sy)` |
| y | `(sz, -sy, -sx)` |
| z | `(-sy, sx, -sz)` |

*The segment.* `p1` = centre of `E` plus, per axis, half the size of `E` times `c`; `p0 = p1 - d`.

*The grid walk.* It starts in the cell containing `p0`. Each axis has a step `sign(d)` (-1, 0 or 1), an increment
`step / d` (the largest double when the step is 0) and a parameter that starts at the increment times the distance to
the next boundary in cell units (`1 - frac(p0)` for a positive step, `frac(p0)` otherwise). Rules:

* each advance moves one cell along the axis with the smallest parameter and adds that axis's increment to it; on a tie
  z wins over y and y wins over x;
* cells are tested only **after** an advance: the new cell is the one tested. The starting cell (the one containing
  `p0`) is never tested, never counts and never takes a step number;
* no further advance is made once all three parameters exceed 1;
* only a tested cell that the segment `p0`-`p1` intersects counts. Each counting cell takes the next step number,
  starting at 1.

*Cells listed for a counting cell.* Take the point where the segment enters the cell and clamp each coordinate to
`[cell + 1.0E-5, cell + 1 - 1.0E-5]` (the float constant). The opposite cell is `floor(point - size of E x c)`, per axis.
All cells of the block spanned by the counting cell and the opposite cell are listed in directional order, leaving out
cells already listed in this leg, all with that step number.

**Budget** (`Entity.checkInsideBlocks`). A cell whose step number is at or above the budget left for the record ends the
leg's traversal. A leg then **consumes the highest step number it accepted plus 1**, so a short leg consumes 1, and a leg
whose end cells were the last listed consumes the last walk step plus 2.

Worked (long fall): one leg `d = (0, -2, 0)` ending with feet at (10.5, 64.0, 10.5), standing box. Signs (+1, -1, +1),
corner vector (-1, -1, -1). Order: the start box's cells y 67 then 66 (step 0); the walk enters cell 65 (step 1) and
cell 64 (step 2); the end box's cells are already listed. With a budget of 16 nothing is cut, and the leg consumes 3.

### 9.4 What is done per listed cell

The per-cell rules are 39 section 2.2a ("block visitor"): skip air; the block counts as touched when its entity-inside
shape is the whole cell (the default) or the player's swept box overlaps that shape along the leg; the fluid is tested
the same way; a touched cell is processed once per pass (a set shared by all legs and records; untouched cells are not
remembered). The block's inside hook receives a flag **precise** = the leg is longer than 0.99999 (squared length above
the square of 0.9999900000002526) or `E` intersects the cell. Hooks take effect **immediately and in this order**, so:

* each velocity change builds on the one before;
* a stuck multiplier is **assigned**, so the last stuck block listed wins;
* "in powder snow now" is set after the whole pass.

Worked 1 (standing still, feet at y = 64.0, a sweet berry bush in cell 64 and a cobweb in cell 65 of the same column):
short leg, y ascending: berry then cobweb; the multiplier is the cobweb's (0.25, 0.05, 0.25).
Worked 2 (the same cells, falling from y = 64.5 to 64.2): directional order with `d.y < 0` lists the start box from the
top: cell 66, 65, 64: cobweb then berry; the multiplier is the berry's (0.8, 0.75, 0.8).
Worked 3 (a bubble column whose top cell has air above, rising): the lower cell is processed first, the surface cell
last; see 10.2.

---

## 10. Every block behaviour that changes a player's movement

The list is closed for the artifact in this sense: it was built from every block class that overrides one of the hooks
`entityInside`, `stepOn`, `fallOn`, `bounceOn`, the friction, speed, jump or restitution getters or the entity-inside
shape; every collision shape that reads the entity's height or sneak state; every `Blocks` property call for friction,
speed, jump, restitution or fall reduction; every block or tag tested by name in the movement code of `Entity`,
`LivingEntity` and `Player`; and every block or block-entity class that calls a velocity or move method on an entity.
Overrides of `entityInside` or `stepOn` not listed (fire, cactus, campfire, magma, plates, buttons, rails, portals,
cauldrons, crops, tripwire, sculk and similar) make no velocity or fall-distance change to a player.

### 10.1 The list

| Blocks | Movement behaviour | Rule |
|---|---|---|
| every block | collision shape | 51 (mud and soul sand 14/16 high, honey 15/16 high and 14/16 wide, and so on) |
| `ice`, `packed_ice`, `frosted_ice` | friction 0.98 | 4.2 |
| `blue_ice` | friction 0.989 | 4.2 |
| `slime_block` | friction 0.8; restitution 1.0; step-on slow-down; no fall damage | 8.2, 10.3, 12 |
| 16 dyed beds | restitution 0.75; fall distance halved | 8.2, 12 (the straw bed has neither) |
| `shelf_mushroom` | restitution 0.75; fall distance halved; its bounce hook only plays a sound | 8.2, 12 |
| `soul_sand` | speed factor 0.4 | 8.3 |
| `honey_block` | speed 0.4, jump 0.5; side slide; suppresses bounce; fall damage x 0.2 | 8, 10.4, 12 |
| `mud` | **no movement rule beyond its shape**: no speed, jump or friction property and no hook (`MudBlock` declares only shapes, pathfinding and shade) | 51 |
| `cobweb` | stuck (0.25, 0.05, 0.25) | 10.2 |
| `sweet_berry_bush` (any age) | stuck (0.8, 0.75, 0.8) | 10.2 |
| `powder_snow` | stuck (0.9, 1.5, 0.9); shape depends on boots, height, fall distance and sneak; climb-up with boots; no fall damage | 7.3, 10.2, 10.6 |
| `bubble_column` | pushes up or down | 10.2 |
| tag `climbable`, open trapdoor over a ladder | climbing | 7.3 |
| `scaffolding` | shape depends on height and sneak; no sneak hold | 10.6, 7.2 |
| `hay_block`, upward `pointed_dripstone` tip | change fall damage | 12.4 |
| `water`, `lava`, waterlogged blocks | fluid travel and currents | 7.4, 7.5, 29a |
| `moving_piston` | pushes and carries entities; slime sets velocity; honey carries | 10.5 |
| shulker boxes | the opening lid pushes | 10.5 |
| `potent_sulfur` (erupting or continuous geyser) | launches upward | 10.5 |
| suffocating blocks | push the player sideways out | 4.4 |
| dirt path, farmland, mud-to-clay and the other callers of `pushEntitiesUp` (closed list) | when the block grows taller, the server moves the entities in the new volume up; a player gets a fully relative teleport, so the client keeps its velocity (the server's own velocity is replaced) | 29b part 2 section 9.5; 13.6 |

### 10.2 Inside hooks

Read in `WebBlock.entityInside`, `SweetBerryBushBlock.entityInside`, `PowderSnowBlock.entityInside`, `InsideBlockEffectType`, `BubbleColumnBlock.entityInside`, `Entity.handleOnInsideBubbleColumn`, `handleOnAboveBubbleColumn`, and `Player.makeStuckInBlock`, `onInsideBubbleColumn`, `onAboveBubbleColumn`.

**Cobweb, sweet berry bush.** The hook sets the stuck multiplier (above) and `fallDistance = 0`; nothing happens to a
flying player. The next move uses it (8.1 step 3). (An effect, Weaving, changes the cobweb values; Open question 2.)
Foxes and bees are exempt from the bush; players are not.

**Powder snow.** For a living entity the stuck part acts only when the block containing the **feet** is powder snow:
multiplier (0.8999999761581421, 1.5, 0.8999999761581421), `fallDistance = 0`, not while flying. Whether or not that
test passes, touching the cell sets "in powder snow now" after the pass (also when flying).

**Bubble column** (acts only when **precise**; not for a flying player). `down` is the block's `drag` property. The cell
is a **surface** cell when the block above has an empty collision shape and an empty fluid.

| Cell | Rule on `vy` | Fall distance |
|---|---|---|
| inside, up | `min(0.7, vy + 0.06)` | reset |
| inside, down | `max(-0.3, vy - 0.03)` | reset |
| surface, up | `min(1.8, vy + 0.1)` | unchanged |
| surface, down | `max(-0.9, vy - 0.03)` | unchanged |

The rule runs once **per touched column cell** per tick, so a player overlapping three cells gets it three times.

**Honey block** slide: see 10.4.

Worked, stuck blocks (walking on ground, forward held, inside from the second tick on): each tick the move is
`(stored + acceleration) x multiplier` and the stored velocity is zeroed, so after the first affected tick the horizontal
displacement is constant: cobweb 0.0245 (0.49 blocks/s), berry bush 0.0784 (1.568), powder snow 0.0882 (1.764). Falling
(stored -0.0784 each tick): cobweb -0.00392, berry -0.0588, powder snow -0.1176 per tick. A ground jump inside a cobweb
rises 0.42 x 0.05 = 0.021 on that tick.

Worked, bubble column (entering with `vy = -0.005`, no keys, not sprinting; each tick water travel of 7.4, then the
column rule):

| Column | displacements ticks 1 to 5 | steady |
|---|---|---|
| up, 3 cells inside | -0.005, 0.171, 0.3118, 0.42444, 0.514552 | 0.7 |
| up, 2 cells inside | -0.005, 0.111, 0.2038, 0.27804, 0.337432 | 0.575 |
| down, 3 cells | -0.005, -0.099, -0.1742, -0.23436, -0.282488 | -0.3 |

Order matters (start `vy = 0.65`, rising out of the top): travel gives 0.515; cells in the order inside, inside, surface
give `0.575, 0.635, 0.735`; the order surface, inside, inside would give `0.615, 0.675, 0.7`.

### 10.3 Slime block step-on

Read in `SlimeBlock.stepOn`.

When `|vy| < 0.1` and shift is not held: `vx` and `vz` are multiplied by `0.4 + |vy| x 0.2`; `vy` is unchanged. This
runs after travel, so for a player on the ground `|vy|` is 0.0784 and the factor 0.41568.

Worked, walking on slime: displacements 0.0413438, 0.0538550, 0.0576411, 0.0587868, toward 0.0592840 (1.186 blocks/s).
Without the step-on factor (not the case when walking upright) the steady value would be 0.1519991.

Worked, bounce (drop from 3 blocks onto slime, starting `vy = 0`, no keys): tick 10 requests -0.6517088, moves
-0.3054385, restitution gives +0.6827425, stored after gravity and drag +0.5906876; peak after the bounce 2.30 blocks
above the block on tick 17. The same drop on a bed: +0.5120569, stored +0.4234157, peak 1.27 on tick 16. Standing on
slime does not bounce (`0.0784 <= 0.08`). With shift held, no bounce.

### 10.4 Honey slide (`HoneyBlock.isSlidingDown`, `doSlideMovement`)

Define `old(vy) = vy / 0.9800000190734863 + 0.08` and `new(w) = (w - 0.08) x 0.9800000190734863`. The player slides
when all hold, tested inside the honey cell at `(X, Y, Z)`: not on ground; feet `y <= Y + 0.9375 - 1.0E-7`;
`old(vy) < -0.08`; and `|X + 0.5 - x| + 1.0E-7 > 0.4375 + width/2` or the same on z (the centre is outside the block's
footprint by more than that, 0.7375 for a player). Then: if `old(vy) < -0.13`, let `k = -0.05 / old(vy)` and set
`v = (vx x k, new(-0.05), vz x k)`; else set `vy = new(-0.05)`. `fallDistance = 0`. `new(-0.05)` = -0.1274000.

Worked (falling beside a honey wall from `vy = -0.0784`): tick 1 travel leaves -0.155232 (`old` = -0.0784, no slide);
tick 2 moves -0.155232, travel leaves -0.2305274, slide: `vy = -0.1274`; from tick 3 every tick moves **-0.1274**
(2.548 blocks/s). Entering with `vy = -0.5` after travel: `old` = -0.4302041, `k` = 0.1162239.

### 10.5 Block entities (client block entity phase, after the entity tick)

* **Moving piston** (`PistonMovingBlockEntity`): 30 part 3 sections 7.2 and 8. A player is moved with a piston-type
  move. A moved slime block first **sets** the velocity component on its axis to exactly +-1.0 (for every collected
  entity, before the push distance is computed). A horizontally moving honey block carries a player who is on the ground
  on it, by the progress step (0.5) without the 0.01 margin. Each piston move is followed at once by the block effect
  pass (9.2).
* **Shulker box** (`ShulkerBoxBlockEntity`): while opening, a player in the lid's swept slab is moved by
  `(slab size + 0.01)` along the facing, per tick (31 part 1, shulker box section; slab: 51 section 3.8.8).
* **Geyser** (`PotentSulfurBlockEntity`): 31 part 8 section 9.6, which runs on both sides. For the player: when
  `deltaMovement.y > -0.5` and `fallDistance > 1`, `fallDistance = 1`; then unless flying or riding, if
  `vy < 0.30000001192092896 + h x 0.1` (`h` = the water column height) add 0.20000000298023224 to `vy`.

**Piston and shulker moves are ordinary `Entity.move` calls** with their own mover types, so 8.1 applies except for the
edge back-off (not for these types): a collision runs restitution; the block speed factor multiplies `vx` and `vz`
again; fall handling runs on the client (the distance grows on a downward move and a landing is processed); the ground
and collision flags are recomputed, so on the client an unobstructed horizontal push leaves `onGround` **false** (and
clears the supporting block) until the player's next move. A pending stuck multiplier is consumed: a shulker move is
scaled by it, a piston move is not scaled, and both zero the velocity.

Worked (piston push over soul sand): stored velocity (0, -0.0784, 0.0273809), on ground, the player's box touching the
front face of a piston-moved block; the first tick of its move east gives a push of `0.5 + 0.01 = 0.51`. The player moves +0.51 on x; no collision; the block speed factor 0.4
applies: velocity (0, -0.0784, 0.0109524); `onGround` false, so the immediate pass runs no step-on, only the inside
pass.
Worked (slime piston upward): the player stands on the moving slime, velocity (0, -0.0784, 0.1178591). The piston sets
`vy = 1.0` and moves the player up 0.51. With forward held, the next player tick moves (y 1.0, z 0.1374591) (air
acceleration, because `onGround` is false) and ends with `vy = 0.9016000`, `vz = 0.1250878`.
Worked (honey carry): a player on the ground on top of a honey block that a piston starts moving east: the block entity
phase moves the player +0.5 on x; velocity unchanged on ordinary factors; `onGround` false until the player's own tick
lands on the moving shape again. If it has by the second piston tick, the player is carried another 0.5 (inferred for
the geometry).
Worked (shulker lid): a player standing on a shulker box that faces up, first opening tick (progress 0 to 0.1f), is
moved up `0.1100000` (slab height 0.1f plus 0.01); velocity unchanged, `onGround` false. If a cobweb multiplier
(0.25, 0.05, 0.25) is pending from the player's own pass, the move is `0.0055000` up and the velocity becomes (0, 0, 0).
Worked (geyser, `h` = 3, so the limit is 0.6; the player floating in the water column with `vy = -0.005`, no keys): the
block entity phase makes `vy = 0.195`; the next ticks move up 0.195, 0.351, 0.4758000, 0.5756400 (water travel leaves
0.151, 0.2758, 0.3756400, 0.4555120, each time below 0.6, and the geyser adds 0.2).

### 10.6 Shapes that depend on the player

**Powder snow** (`PowderSnowBlock.getCollisionShape`), evaluated at each collision query with the player's current state:

1. `fallDistance > 2.5`: the box (0, 0, 0) to (1, 0.9, 1) of the cell.
2. Else, if the player wears `leather_boots`, the feet are above the cell's top (`y > cell y + 1 - 1.0E-5`) and shift is
   not held: the full cube.
3. Else empty.

**Scaffolding** (`ScaffoldingBlock.getCollisionShape`): if `y > cell y + 1 - 1.0E-5` and shift is not held, the stable
shape (top slab and posts); else, if the block's `distance` is not 0, `bottom` is true and `y > cell y - 1.0E-5`, the
bottom plate (0 to 2/16); else empty (51 sections 3.8.5 and 5).

Worked: a player without boots falls 4 blocks onto powder snow: during the landing move `fallDistance` is above 2.5,
so the snow is a 0.9 high box; the player lands on it (no damage, 12.4) and `fallDistance` resets; on the next tick the
shape is empty and the player sinks with the stuck multiplier. With leather boots and standing: stays on top; pressing
shift: sinks.

Worked (scaffolding): standing on top of a scaffolding with `distance` 0 without shift: the stable shape holds the
player (`onGround`). Press shift: the same tick's collision queries get the empty shape and the player starts to fall
through it (`vy` -0.0784 on that tick; inside the cell the climbable limit of 0.15 per tick applies and shift does not
hold, because the feet block is scaffolding).

---

## 11. Effects and enchantments

### 11.1 Who computes what

The **client** computes all movement. It reads some effects directly (Jump Boost power, Levitation, Slow Falling,
Dolphin's Grace, Blindness) from its effect list, and reads attributes (speed, sneak factor, water efficiency, movement
efficiency) from its attribute map. The **server** owns the attribute modifiers of effects and enchantments; the client
never adds them itself (the effect hooks that add modifiers return at once on a client), and the only movement modifier
the client adds on its own is `minecraft:sprinting`.

A client effect instance counts its remaining ticks down but is **not** removed at 0; it applies until Remove Mob Effect
arrives (or a new Update Mob Effect replaces it). Duration -1 is infinite.

A packet applied before a tick (2.1) affects that tick completely.

Worked (an effect runs out): the client receives Levitation I with duration 3 while standing (`vy = -0.0784`), and
Remove Mob Effect is handled only before its sixth tick. The count reaches 0 on tick 3 and the effect still acts on
ticks 4 and 5: displacements 0 (blocked), 0.0098, 0.0174832, 0.0235068, 0.0282294; tick 6, without the effect, moves
0.0319318 and ends with `vy = -0.0471068`; tick 7 moves -0.0471068.

### 11.2 Amounts

`L` = amplifier + 1 for effects, the level for enchantments.

| Source | Where it acts | Rule | Ends |
|---|---|---|---|
| Speed | attribute `movement_speed`, id `minecraft:effect.speed` | +0.20000000298023224 x L, multiply total | modifier removed with the effect |
| Slowness | attribute `movement_speed`, id `minecraft:effect.slowness` | -0.15000000596046448 x L, multiply total | same |
| Jump Boost | jump power (6.2), client; attribute `safe_fall_distance`, id `minecraft:effect.jump_boost`, server | +0.1f x L to the jump power; +1.0 x L (add) safe fall distance | same |
| Levitation | air travel only (7.2 step 6); fall distance reset each tick (both sides) | `vy += (0.05 x L - vy) x 0.2` then vertical drag | on removal gravity returns |
| Slow Falling | effective gravity (air, water, lava, restitution); fall distance reset each tick (both sides) | `min(g, 0.01)` while the stored `vy <= 0` at the moment it is read (7.2 step 6) | on removal |
| Dolphin's Grace | water drag 0.96 (7.4 step 3) | amplifier has no effect | |
| Blindness | sprint not possible (5.1) | no speed change; amplifier has no effect | |
| Depth Strider | attribute `water_movement_efficiency`, id `minecraft:enchantment.depth_strider/feet` | add `f32(0.33333334f + 0.33333334f x (L - 1))`; the attribute clamps to 0..1 | when the boots leave the slot |
| Swift Sneak | attribute `sneaking_speed`, id `minecraft:enchantment.swift_sneak/legs` | add `f32(0.15f + 0.15f x (L - 1))`; clamp 0..1 | when the leggings leave the slot |
| Soul Speed | attributes `movement_speed` (add `f32(0.0405f + 0.0105f x (L - 1))`) and `movement_efficiency` (add 1.0), both id `minecraft:enchantment.soul_speed/feet` | transient modifiers, 11.4 | 11.4 |

### 11.3 Stacking

Attribute value = `(base + all add_value) ` = B; plus `B x amount` for each multiply-base; then multiplied by
`(1 + amount)` for each multiply-total; then clamped (`movement_speed` 0 to 1024). Speed, Slowness and sprinting have
different ids, so they multiply each other. There is one instance per effect type; how a second application of the same
effect replaces or hides the first is `MobEffectInstance.update`: a higher amplifier takes over (the old one is kept
hidden if it lasts longer); the same amplifier with a longer duration extends it; a lower amplifier with a longer
duration is kept hidden and returns when the stronger one ends. The order in which several modifiers of one operation
are applied is a hash order, which can only change the last bit of the double (Open question 5).

Worked (hidden effect): Speed I (amplifier 0) has 500 ticks left when Speed II (amplifier 1) for 100 ticks arrives. The
new one is higher and shorter, so the effect becomes amplifier 1 with 100 ticks, and Speed I with 500 ticks is kept
hidden. Each effect tick takes 1 from both durations (an infinite one stays infinite). On the 100th tick the visible
duration reaches 0 with the hidden one at 400, which takes over in the same tick: amplifier 0, 400 ticks. The steady
walk goes from 0.3022027 to about 0.259031 per tick, and Speed ends on the tick on which Speed I alone would have ended.
In the other order (Speed I for 600 ticks arriving while Speed II has 100 left and nothing hidden) the visible effect
stays Speed II; Speed I is stored hidden and takes over after those 100 ticks with 500 left. Speed II for 600 ticks
arriving on Speed I with 500 left replaces it, and nothing new is hidden.

Worked (`speed` = the float used by movement; steady walk = `speed x 0.98 / 0.454`):

| Condition | attribute value | steady displacement (blocks/s) |
|---|---|---|
| Speed I | 0.1200000 | 5.181 (computed) |
| Speed II | 0.1400000 | 0.3022027 (6.044) |
| Speed II, sprinting | 0.1820000 | 0.3928635 (7.857) |
| Slowness I | 0.0850000 | 0.1834802 (3.670) |
| Slowness VI | 0.0099999 | 0.43 blocks/s (computed) |
| Slowness VII and higher | clamped to 0 | cannot walk on the ground (air acceleration is unchanged) |
| Soul Speed III on soul sand | 0.1615000, efficiency 1 | 0.3486124 (6.972); level I 0.303282, level II 0.3259472 |
| Soul Speed III + Speed II + sprint | (0.1 + 0.0615) x 1.4 x 1.3 = 0.29393 | |
| Swift Sneak I, II, III sneaking | factor 0.45, 0.6, 0.75 | 0.0971366, 0.1295155, 0.1618943 (1.94, 2.59, 3.24) |
| Depth Strider I, II, III wading on the floor | d 0.7153333, 0.6306667, 0.5460001; a 0.0466667, 0.0733333, 0.1 | 0.1606557, 0.1945849, 0.2158591 |
| Depth Strider I, II, III off the ground | e halved: d 0.7576667, 0.7153333, 0.6730000; a 0.0333333, 0.0466667, 0.06 | 0.1348006, 0.1606557, 0.1798165 |

Worked, Jump Boost: powers 0.52, 0.62, 0.72, 0.82 for I to IV. Jump Boost II from flat ground: heights 0.6200, 1.1492,
1.5894160, 1.9424278, 2.2099792, 2.3937797, 2.4955041, 2.5167941 (peak, tick 8), ..., lands on tick 16.

Worked, Levitation I standing on the ground (`vy = -0.0784`): displacements 0 (blocked), 0.0098, 0.0174832, 0.0235068,
0.0282294, toward 0.0453704 (0.907 blocks/s). Level II: 0, 0.0196, 0.0349664, 0.0470137, toward 0.0907407.

Worked, Slow Falling: the jump rises as the plain jump to tick 6 (gravity 0.08 while rising; tick 6 ends with
`vy = -0.0754441`), then tick 7 moves -0.0754441 and ends -0.0837352, then -0.0837352, -0.0918605, -0.0998233, ...;
lands on tick 17. Free fall from rest: 0, -0.0098, -0.019404, -0.0288159, toward -0.49.

Worked, Dolphin's Grace: 7.4 table. Worked, Blindness: sprinting on tick T-1, effect packet before tick T: sprint
ends in step 16 of T; stored velocity is kept, so the displacements decay from 0.28 toward the walk value.

### 11.4 Soul Speed activation (server)

The two attribute modifiers belong to one location-based effect of the enchantment (engine: 28 section 10; data file
`soul_speed.json`). Its condition, with `block` = the block at the centre of the below-affecting cell
(`movement_affected_by`, 26) being in tag `soul_speed_blocks` (`soul_sand`, `soul_soil`), and "flying" meaning gliding
or ability flight:

| State of the modifiers | Condition evaluated |
|---|---|
| inactive | they are **added** when: not riding, not flying, and `block` |
| active | they **stay** while: not riding, not flying, and (`block`, or not on ground); otherwise removed |

It is re-evaluated only: in the server's base tick when the player's block position differs from the last one seen; when
the server's fall handling lands the player with `fallDistance > 0`; when the item in the feet slot changes; and at game
mode changes (28 section 10). So an active player keeps the bonus through a jump, and loses it at the first block change
or landing on ground that is not a soul block. The server's `onGround` and position come from the client's packets.

Worked: walking from soul sand onto stone: on the server tick that sees the new block position with the cell below stone
and the player on ground, both modifiers are removed; the client receives Update Attributes and walks at 0.1 from the
next tick it is applied. Jumping from soul sand over stone: active while airborne; removed on landing on stone. Landing
back on soul soil: stays.

### 11.5 What the server sends, and when

Wire forms: Update Mob Effect (05b 0x87: entity, effect id, amplifier, duration, flags 0x01 ambient, 0x02 visible, 0x04
icon, 0x08 blend), Remove Mob Effect (05b 0x4F), Update Attributes (05b 0x86). Registry ids (46): effects `speed` 0, `slowness` 1,
`jump_boost` 7, `blindness` 14, `levitation` 24, `slow_falling` 27, `dolphins_grace` 29; attributes
`movement_efficiency` 25, `movement_speed` 26, `safe_fall_distance` 29, `sneaking_speed` 31,
`water_movement_efficiency` 37.

| Packet to the player about itself | Sent when | Notes |
|---|---|---|
| Update Mob Effect, blend set | at once when an effect is added | |
| Update Mob Effect, blend clear | at once when an existing instance changes (replaced, hidden effect takes over), and when the remaining duration is a multiple of 600 after a tick (17 section 4.9a) | |
| Update Mob Effect, blend clear, one per active effect | join, respawn, change of dimension | |
| Remove Mob Effect | at once when an effect expires (server tick) or is removed | |
| Update Attributes | at the next time the entity tracker processes the player after a syncable attribute changed: when the player needs a sync, its update interval (2 ticks) is due, or its entity data is dirty (18 section 9.2) | one packet with every changed attribute, each as base value plus **all** its current modifiers (including transient ones and sprinting) |

The client, on Update Attributes, sets each listed attribute's base value, **removes all its modifiers**, and adds the
listed ones. A snapshot built before the server processed the client's sprint command therefore removes the client's
sprint modifier; the client does not re-add it while it remains sprinting, and the next server update (which includes it)
restores it (consequence computed from the two rules).

Worked: walking steadily (stored `vz` 0.1178591) the player starts sprinting on tick T: displacement 0.2452591. Before
tick T+1 an Update Attributes for `movement_speed` built without the sprint modifier arrives (base 0.1): ticks T+1 and
T+2 use speed 0.1 and displace 0.2319115 and 0.2246237, although the client still counts itself sprinting. Before tick
T+3 the update with the modifier arrives: ticks T+3 and T+4 use 0.13 and displace 0.2500446 and 0.2639244.

No explicit attribute packet is sent at join or respawn; changed attributes reach the player through the tracker rule
(inferred: the only builders of the packet found are the tracker's). Equipment changes are detected once per server tick
before the player's own movement tick; effect expiry removes modifiers in the server's base tick.

Worked: the server adds Speed II to a sprinting player: Update Mob Effect (id 0, amplifier 1, flags 0x0E); then Update
Attributes with attribute 26, base 0.10000000149011612, modifiers `minecraft:sprinting` 0.30000001192092896 op 2 and
`minecraft:effect.speed` 0.4000000059604645 op 2. The client's speed becomes 0.18200001f.

---

## 12. Fall distance and fall damage

### 12.1 Accumulation and landing (`checkFallDamage`)

For the local player this runs **on the client**, inside every move (8.1 step 10):

1. If not in water, re-run the fluid update (which resets `fallDistance` if now in water).
2. If not in water and `m.y < 0`: `fallDistance = fallDistance - (double)(float)m.y`.
3. If `onGround`: if `fallDistance > 0`, the **fall-on** hook of the block at the legacy cell runs; then
   `fallDistance = 0`.

The client deals no damage (sounds and block reactions only). Its fall distance is used by the powder snow shape (10.6),
the edge back-off (53 section 5.1), the critical-hit test and the smash attack.

On the **server** the same three steps run once per position packet, after the replayed move, with the vertical
displacement of the accepted packet and the packet's ground flag (30 part 8 section 14.1.7); then, if the packet moved
upward (`dy > 0`), `fallDistance` is reset (server only). The server's own movement tick does not accumulate but does
apply the resets of 12.2 at the player's position. On the client a new player object (join, respawn, dimension change)
starts at 0, and a Player Position packet does not reset its value. On the server a joining player takes the saved
`fall_distance` of its player data (`Entity.load`; 0 when absent).

Worked: a drop of exactly 10 blocks from rest (`vy = 0` on tick 1). Fall distance after ticks 1 to 6: 0, 0.0784000,
0.2336320, 0.4641594, 0.7684762, 1.1451067; after tick 17: 9.6670672; tick 18 moves the last 0.3329328, giving 10.0, the
fall-on hook runs with 10.0 and the distance returns to 0.

### 12.2 Resets and reductions of the distance

Read in `Entity.updateFluidInteraction`, `baseTick`, `makeStuckInBlock`, `move`, `handleOnInsideBubbleColumn`, `checkFallDistanceAccumulation`, `LivingEntity.handleOnClimbable`, `aiStep`, `rideTick`, `Player.aiStep`, `HoneyBlock.doSlideMovement`, `ServerGamePacketListenerImpl.handlePlayerPositionChange`, `ThrownEnderpearl`, `TeleportRandomlyConsumeEffect` and `MaceItem.postHurtEnemy`.

| Situation | Effect on `fallDistance` | Sides |
|---|---|---|
| touching water (fluid update) | 0 | both |
| in lava | x 0.5 in each base tick | both |
| on a climbable, during air travel | 0 each tick | both |
| inside hook of cobweb, sweet berry bush, powder snow at the feet | 0 (not while flying) | both |
| bubble column inside cell (not the surface cell) | 0 (not while flying) | both |
| honey slide | 0 | both |
| Slow Falling or Levitation present | 0 each tick before travel | both |
| ability flight | 0 each tick | both |
| a long move crossing a resetting block (12.3) | 0 before the move is added | both (every `move`) |
| geyser | at most 1 while `vy > -0.5` | both |
| packet moving upward | 0 | server |
| ender pearl arrival, random-teleport food, mace smash | 0 | server |
| riding | 0 | both (out of scope) |
| landing | 0 after the fall-on hook | both |

No call that resets it was found in the plain teleport path.

Worked: distance 10 on entering lava: the next base tick makes it 5, a downward move of 0.04 that tick makes it 5.04,
the next base tick 2.52. Distance 8 in an erupting geyser column with `vy = -0.4`: set to 1. Distance 20 entering water:
0 in the same move. Slow Falling: 0 before every travel, so the distance at the fall-on hook is only the last move.

### 12.3 The clip reset

Read in `Entity.move` and `ClipContext.Block.FALLDAMAGE_RESETTING`.

In `move`, before the position changes: if `fallDistance != 0` and `|m|^2 >= 1`, cast a ray from the position along `m`
of length `min(|m|, 8.0)`, hitting blocks in tag `fall_damage_resetting` (the `climbable` tag, `sweet_berry_bush`,
`cobweb`) as full cubes, and water fluid shapes; for players also `end_portal` and `end_gateway`, and on the server
`nether_portal` when the game rule `players_nether_portal_default_delay` is 0. A hit sets `fallDistance = 0`.

Worked: `fallDistance` 20, a move of (0, -1.2, 0) whose ray crosses a cobweb: reset, then step 2 adds 1.2: distance 1.2;
a landing in that same move does no damage.

### 12.4 Landing: damage (server)

Read in `Block.fallOn` and the overrides of `HayBlock`, `HoneyBlock`, `SlimeBlock`, `PowderSnowBlock` and `PointedDripstoneBlock`, and `FarmlandBlock`, `TurtleEggBlock`.

Default fall-on: `causeFallDamage(distance x f32(1 - fallDistanceReduction), 1.0)` (the product widens the float
factor to double).

| Landing on (legacy cell) | Call |
|---|---|
| ordinary block, farmland, turtle egg, non-tip dripstone | distance, multiplier 1.0 |
| bed, shelf mushroom | distance x 0.5, multiplier 1.0 |
| hay bale, honey block | distance, multiplier 0.2f |
| slime block | shift not held: multiplier 0; shift held: no call. **No damage either way** |
| powder snow | never a call (no damage); a sound from distance 4 |
| pointed dripstone, upward tip | distance + 2.5, multiplier 2.0, damage type `stalagmite` |

The legacy cell is 0.2 below the feet (or the fence-like supporting block), so a carpet on a hay bale or on slime gives
the block below the carpet.

`causeFallDamage(d, mult)` for a player (`Player.causeFallDamage`, `LivingEntity.causeFallDamage`,
`calculateFallDamage`): nothing at all if `mayfly`. Otherwise, in order:

1. If an impulse impact position is stored: `d = min(d, impactY - y)`. If that is `<= 0` the impulse state is cleared at
   once; if it is above 0 the **grace-gated clear** is tried.
2. Damage = `floor((d + 1.0E-6 - safe_fall_distance) x (double)mult x fall_damage_multiplier)`. If above 0, the impulse
   state is cleared at once and the damage applied (`safe_fall_distance` default 3).

**Impulse state** = a stored impact position and a grace counter in ticks. A wind charge's explosion hitting the player
stores the player's position and raises the counter to at least 40; a mace smash (17 section 4.8) does the same with its
**impact position**, which is the already stored position when one exists and its y is at or below the attacker's current
y, and the attacker's current position otherwise (`ServerPlayer.onExplosionHit`, `MaceItem.hurtEnemy`,
`MaceItem.calculateImpactPosition`). An explosion not from a wind charge sets the counter to 0 and
leaves the position. The impulse enchantment effect raises the counter to at least 10 without storing a position
(`ApplyEntityImpulse`). The counter counts down by 1 at the end of each living-entity tick (`LivingEntity.tick`) while
above 0. The grace-gated clear removes the state only when the counter is 0; it is tried by step 1, by
`Player.makeStuckInBlock`, and by the server's position handler when the packet says on ground, or the server player has
landed in a liquid (stored `vy` below 9.999999747378752E-6 and in water or lava), is on a climbable, is a spectator, is
gliding or is in a spin attack. The state is also cleared at once by ender pearl arrival, the random-teleport food and a
change to creative mode. Game rule `fall_damage`, armour rules and Feather Falling and Protection are in 17.

Worked (impulse state): a wind charge hits a player at y = 64: that position is stored and the counter is 40. About 30
ticks later, with the counter at 10, the player lands at y = 63 with fall distance 6. Step 1: `d = min(6, 64 - 63) = 1`;
it is above 0, so the grace-gated clear is tried and fails (counter 10). Step 2: `floor(1 + 1.0E-6 - 3)` is negative: no
damage. The position handler's try for the on-ground packet fails too, so the state is kept. The player jumps at once and
comes down one block lower, at y = 62, after the counter has reached 0, with fall distance 2.25 (no packet on the way
carries the ground flag). Step 1: `d = min(2.25, 64 - 62) = 2`; the grace-gated clear now succeeds, and this landing
still uses the limited `d`: no damage. A later 10-block fall onto stone costs the full 7. (Staying on the ground at
y = 63 instead, the first on-ground position packet after the counter reaches 0 clears the state, with no landing
needed.) Had the first landing been at y = 64 or higher, `d <= 0` would have cleared the state at once, whatever the
counter.

Worked (distance exactly 10 unless said; summed from a 10-block drop the 17 moves give 10.0 and landing on tick 18):

| Case | Damage |
|---|---|
| stone | floor(7.000001) = 7 |
| hay bale or honey block | floor(7.000001 x 0.2f) = 1 |
| bed or shelf mushroom | distance 5: 2 |
| slime, powder snow, water | 0 |
| cobweb passed on the way (slow enough for the inside pass to catch it) | distance restarts at the cobweb |
| upward dripstone tip | floor(9.500001 x 2) = 19 |
| stone with Jump Boost II | safe distance 5: 5 |
| distance 3 / 4 / 5 on stone | 0 / 1 / 2 |
| wind charge impact at y = 64, landing at y = 60 after falling 10 | distance 4: 1 |

---

## 13. Pushes and the server's velocity

### 13.1 What the client does with a push

| Event | Effect on the local player | Components |
|---|---|---|
| Set Entity Motion (05b 0x67) naming itself | velocity := packet velocity | replaces x, y and z |
| Explode (05a 0x24) with the knockback field | velocity := velocity + knockback | adds x, y and z |
| Entity Event 31 on a fishing hook whose hooked entity is the player | velocity += (owner position - hook position) x 0.1 | adds |

Nothing else changes: not `onGround`, sprint or fall distance. They apply in the packet phase before the next tick
(2.1). That tick then does the clean-up, adds input acceleration and moves; if the player was on the ground, that tick
still uses ground friction for acceleration and drag.

Worked: client velocity (0, -0.0784, 0.2158591). Set Entity Motion (0.4, 0.4, 0): velocity (0.4, 0.4, 0). Explode
knockback (0.4, 0.4, 0) instead: (0.4, 0.3216, 0.2158591). A fishing hook event with the owner 10 blocks east of the
hook adds (1.0, 0, 0): (1.0, -0.0784, 0.2158591).

### 13.2 Teleports (Player Position)

Read in `PositionMoveRotation.of` and `calculateAbsolute`, `ClientPacketListener.handleMovePlayer` and
`setValuesFromPositionPacket`, `ServerGamePacketListenerImpl.teleport`, `Entity.teleportSetPosition` and
`ServerPlayer.getKnownMovement`.

New position, per axis: the packet's value, plus the old position when that axis's flag (`X`, `Y`, `Z`) is set. New yaw:
the packet's yaw, plus the old yaw with `Y_ROT`. New pitch: the packet's pitch, plus the old pitch with `X_ROT`, then
clamped to -90 to 90.

New velocity, per axis: the packet's delta, plus the old velocity when that axis's `DELTA_*` flag is set. With
`ROTATE_DELTA` the old velocity is first rotated: about x by `radians(old pitch - new pitch)`, then about y by
`radians(old yaw - new yaw)` (float radians, table sine and cosine: x-rotation `y' = y c + z s`, `z' = z c - y s`;
y-rotation `x' = x c + z s`, `z' = z c - x s`). When neither yaw nor pitch changes, both rotations are exactly the
identity. A passenger ignores the packet's change. A respawn builds a new player;
it copies the old velocity only when the Respawn packet's "keep entity data" bit (0x02) is set, else it is zero. The
attribute map is copied with all modifiers when bit 0x01 is set; otherwise only the base values are copied.

**What else the client does with a Player Position**, in the packet phase, in this order:

1. Unless it is a passenger: position (the box is rebuilt, no collision test), velocity and rotation are set as above.
   The previous-tick position and rotation (used to interpolate the drawn frame) are put through the same position and
   rotation rules, starting from the old previous-tick values, so the drawn frame does not glide across a relative
   teleport. `onGround`, fall distance and sprint are not written.
2. Always: it sends Accept Teleportation (05c 0x00) with the id and the position and rotation the player now has. It sends
   no Move Player packet here; the next tick's position send compares with the **last sent** position, which the
   teleport did not change.
3. Always: block-change prediction records the teleport (a predicted block change made earlier no longer moves the player
   back when the server's answer reverts it), and a block break in progress is stopped (Player Action with the abort
   status is sent, progress returns to 0 and the attack strength ticker is reset).

**What the server does with its own record** when it sends one (`ServerGamePacketListenerImpl.teleport`): it applies the
same position, velocity and rotation rules to its player, with the current position and rotation as the old values and
the **known movement** as the old velocity. The server's own velocity (13.5) is not an input. The known movement is the
displacement of the last accepted movement packet (the player's position after the packet minus the position before it;
zero for a packet without a position change), reset to zero when a Client Tick End arrives with no accepted movement
packet since the previous one, and zero for a new player. (A passenger that does not control its vehicle uses the
vehicle's known movement instead.) The server also sets head yaw to the new yaw, sets the previous-tick
position and rotation to the new ones and clears this tick's movement records (9.2); `onGround`, the collision flags and
fall distance are not written. Then it adds 1 to the teleport id (a result of 2147483647 becomes 0), remembers the new
position as the awaited position and sends the packet, carrying the change and flags **as given**, not the resolved
values.

**While a teleport is unacknowledged** (05c, minimum required serverbound traffic), an arriving Move Player changes only
the server's rotation, its position and ground flag being discarded; a Move Vehicle is dropped; and Use Item On does not
use the item or the block (29 section 9.1, steps 9 to 11). If a Move Player or Move Vehicle arrives strictly more than
20 server ticks after the teleport was sent or last re-sent, the server sends a new teleport with a new id: absolute (no
flags), to the awaited position with the server's current yaw and pitch, **zero delta**, which stops the client. Nothing
is re-sent while neither packet arrives. Only an Accept Teleportation with the newest id counts; an older id is ignored,
and a second answer with the newest id, or one with non-finite values, disconnects the player
(`multiplayer.disconnect.invalid_player_movement`). On a match the server puts the player at the awaited position, makes
it the last accepted position, and then handles the packet's position and rotation as a movement packet (53 section 10.3
and the checks there) with the on-ground and horizontal-collision flags **false**.

**A second teleport before the answer** (for example a second lift) gets its own new id, and the awaited position
becomes the server's position after it; relative changes build on the already changed server record. The client applies
both in order and answers each. The server ignores the answer with the older id and confirms only on the newest one.

**Teleport Entity** (05b 0x80; `ClientPacketListener.handleTeleportEntity`) acts on the local player in two cases. When
it names an entity the client no longer has and that was the player's just-removed vehicle, the same position, velocity
and rotation rules are applied to the player at once. When it names the local player itself, the velocity rules apply at
once (the player counts as a ticking entity here (inferred)), `onGround` takes the packet's flag, and, if the target is within 64 blocks, position and rotation are handed to the
client's stepped interpolation (step count = the player type's update interval, 2) instead of being set at once; farther
targets are set at once. No teleport acknowledgement is sent (Open question 11).

Worked: old velocity (0, -0.0784, 0.2), yaw 0. Packet with zero delta and no flags: (0, 0, 0). With `DELTA_X`,
`DELTA_Y`, `DELTA_Z` and zero delta: unchanged. With those three and `ROTATE_DELTA` and a new yaw of 90 (pitch
unchanged): (-0.2, -0.0784, 0.0000) to within the sine table's precision.

### 13.3 The player's own attack

When the client's attack call reports a hit on its side (remote players and the other targets that accept a client-side
hit; mobs do not) and the knockback strength `K` (`attack_knockback / 2`, plus 0.5 if sprinting with the attack
strength scale at 0.5 ticks ahead above 0.9, 17 section 4.2) is above 0: the client multiplies its own `vx` and `vz` by 0.6 and stops sprinting (17 sections 4.2 and 4.6).

The **client's** `K` does not include the Knockback enchantment: `LivingEntity.getKnockback` applies the enchantment
only on a server level, so on the client it is the attribute alone (the `(attribute + Knockback bonus) / 2` of 17
sections 4.2 and 4.6 is the server's value). A hit that is not a sprint knockback hit, made with a Knockback sword and
`attack_knockback` 0, therefore does not slow the attacker's client or stop its sprint.

Worked: a sprinting player with `v = (0, -0.0784, 0.1532168)` makes a full-strength sprint hit on another player:
`v = (0, -0.0784, 0.0919301)`, sprint off, before this tick's player update.

### 13.4 Entity pushing

`LivingEntity.pushEntities`, `doPush`, `Entity.push`, `RemotePlayer.aiStep`. Living entities ticked on the client,
remote players included, run a pushing step each tick, and one that overlaps the local player pushes it. Exceptions:
bats never push; armour stands push only rideable minecarts; parrots skip players; the ender dragon's own tick does not
run the step. Boats and minecarts are not covered (Open question 3).

The player must be alive, not a spectator, not sleeping and **not on a climbable**, and the team collision rule of
`EntitySelector.pushableBy` (57 part 5) must allow it. A vehicle with passengers is not moved (18 section 3.3).

With `d = player - other` on x and z and `n = max(|d.x|, |d.z|)`: when `n >= 0.009999999776482582` the player's velocity
gains, once per such entity per tick,

`push = (d / sqrt(n)) x min(1 / sqrt(n), 1) x 0.05000000074505806`

on x and z; below that threshold nothing.

Worked: player 0.5 east of a mob, same z: `vx + 0.0353553`. Offset (0.2, 0.1): `+(0.0223607, 0.0111803)`. Offset
(0.005, 0.005): nothing.

### 13.5 The server's velocity for a player

Read in `ServerPlayer.doTick`, `ServerGamePacketListenerImpl.tickPlayer` and `handlePlayerPositionChange`, `Entity.markHurt`, `LivingEntity.hurtServer`, `knockback`, `dealDefaultKnockback`, `ServerEntity.sendChanges`, `Player.attack`, `causeExtraKnockback`, `ServerExplosion.hurtEntities`, `ServerLevel` (the explosion packet), and `MinecraftServer.processPacketsAndTick`, `tickChildren`; the other writers of the mark are `Ravager` and `HoglinBase`; the impulse enchantment effect (`ApplyEntityImpulse`) adds its vector and sends Set Entity Motion to a player at once.

The server keeps its **own** velocity for each player and ordinary movement packets never copy the client's movement
into it: each server tick the player
runs the same living-entity tick with **zero input** (clean-up, travel, drag, block effects), after which the position is
reset to the client's (30 part 8 section 14.1.1, "Players, the server's own tick"). **Teleports do write it** (13.2):
each flagged `DELTA_*` axis becomes the client's known movement (rotated if `ROTATE_DELTA`) plus the packet's delta, and
each unflagged axis becomes the packet's delta (corrected in the feature 003 round against the jar). It is also changed
by: knockback and
explosions; pushes by server entities; fluid currents; block effects; a server-side ground jump (with the 0.2 sprint
boost) when a position packet leaves the ground upward; and the collision response and block speed factor of the replayed
packet moves. For a player standing still on ordinary ground it is **(0, -0.0784000015, 0)**.

**When Set Entity Motion is sent to the player itself:** only for the "velocity changed by an impact" mark, which is set
by every accepted full hit (not a difference-only hit inside the invulnerability window) whose damage type is not in
`no_impact` (only `drown`) and which was not fully blocked, **even for types that give no knockback** (fall, fire,
cactus, explosions, berry bush and the rest of `no_knockback`), and by a few special pushes (17, mobs). The tracker sends
the server velocity **as it is when the tracker next processes the player** (18 section 9.2 step 7) and clears the mark.
Packet velocity is the LpVec3 form (00 section 4.6), so it is quantised.

The server's tick order is: queued packets, then each level (entity tracker sends, then entity ticks, then block
entities), then each player's own movement tick.

| Hit | Velocity in the packet |
|---|---|
| attack by a player, a full hit | sent **immediately** while the attack packet is handled: the server velocity after the default knockback and the attack knockback (17 section 4.6). The server then **restores** its velocity to the value before the attack |
| attack by a player that only adds the difference inside the invulnerability window | no default knockback and no new mark; the attack knockback, if above 0, is still applied to the server velocity, with **no immediate send and no restore** (it travels with whatever next sends that velocity; if a mark from an earlier event is still pending at that moment, the send and restore of the row above happen) |
| mob, projectile or other hit during the level's entity phase of server tick N | sent in tick N+1: the knocked-back velocity **after** the player's own server movement of tick N (one move, drag and gravity), plus whatever tick N+1's packets changed |
| explosion | Explode (immediately, to players within 64 blocks) carries the knockback vector; if the player was also damaged, Set Entity Motion follows with the server velocity (which includes the knockback) as of the next tracker pass; the client therefore adds the knockback and is **then overwritten** |
| fall, fire and other damage without knockback | the server velocity: horizontal usually zero or a small remainder (the server has no walking input) |

Spectators and flying creative players get no knockback field. An explosion's knockback is
`direction x (1 - dist / (2 r)) x seen fraction x calculator multiplier x (1 - explosion_knockback_resistance)`, with
`direction` the normalised vector from the centre to the player's eyes and `dist` the distance from the centre to the
player's position (17 section 4.11; seen fraction 20 section 6.2); the server adds it to its velocity.

Consequence (computed from these rules, not observed): a walking player who takes fall damage or other velocity-marking
damage has its horizontal velocity replaced by the server's, which is normally near zero, one round trip after the hit.

#### Worked: fall damage while walking

A client walking at stored `vz` 0.1178591 takes 1 damage from a fall; the server velocity at the next tracker pass is
(0, y, 0) with `y` the server's own vertical value (-0.0784 when it already rests on the ground). The client's next tick
after the packet starts from (0, y, 0): with forward held it moves 0.098 along z (as from rest) instead of 0.2158591.

The default knockback strength is the double 0.4000000059604645 (`LivingEntity.dealDefaultKnockback`, the float 0.4
widened); the cap on the upward result is the double 0.4.

#### Worked: mob hit (default knockback from the east) on a standing player

Server velocity before (0, -0.0784000, 0). Default knockback (17 section 4.6), on ground:
(-0.4000000, 0.3608000, 0). Same tick, the player's server movement (ground friction 0.6) leaves
(-0.2184000, 0.2751840, 0). Packet (after quantisation): (-0.2183971, 0.2751633, 0). The client replaces its velocity;
with no keys the next client tick moves by exactly that and stores
(-0.1192448, 0.1912600, 0) (computed).

#### Worked: sprint hit by a player on the same target

The attacker stands 1 block east of the target at the same y and z, yaw 90 (facing west, toward it), sprinting with a
full charge and `attack_knockback` 0.

Default knockback gives (-0.4, 0.3608, 0); the sprint knockback 0.5 gives (-0.7, 0.4, 0). Packet:
(-0.6999939, 0.3999878, 0). Server velocity afterwards: (0, -0.0784, 0). Without the sprint part:
(-0.3999878, 0.3608008, 0).

#### Worked: explosion

Radius 4, centre at the origin level with the feet, player feet at (4, 0, 0), eye 1.62, seen fraction 1, no resistance:
knockback (0.4634350, 0.1876912, 0). A walking client with (0, -0.0784, 0.2158591) becomes
(0.4634350, 0.1092912, 0.2158591) before its next tick. The server's velocity (0.4634350, 0.1092912, 0), after its own
movement tick, is (0.2530355, 0.0287054, 0); the following Set Entity Motion (when the explosion happened in the entity
phase) carries it quantised, (0.2530062, 0.0286883, 0), and replaces the client's velocity.

### 13.6 Lift by a growing block

Read in `Block.pushEntitiesUp`, `ServerPlayer.teleportRelative`, `Relative` (`ALL`), `ClientboundPlayerPositionPacket`,
and the classes of 13.2. Which block changes lift, which entities are chosen and how the lift amount is computed are in
29b part 2 section 9.5.

#### The packet

The lifted player is sent exactly one packet by the lift itself: **Player Position** (05b 0x49), sent at once, while the
block change is still being processed. No Set Entity Motion or entity teleport packet to that player is part of it.

| Field | Value |
|---|---|
| Teleport id | the connection's next teleport id (13.2) |
| X, Y, Z | 0.0, `lift`, 0.0 (`lift` as computed by 29b part 2 section 9.5.1 from the **server's** box; it can be 0.0) |
| Velocity X, Y, Z | 0.0, 0.0, 0.0 |
| Yaw, pitch | 0.0, 0.0 |
| Relative flags | all nine: `X`, `Y`, `Z`, `Y_ROT`, `X_ROT`, `DELTA_X`, `DELTA_Y`, `DELTA_Z`, `ROTATE_DELTA`; Int value 0x000001FF (511) |

It is confirmed like every teleport: the client answers with Accept Teleportation and the server ignores the client's
movement until the answer arrives (13.2).

#### What the client makes of it

By 13.2: position `(x, y + lift, z)` from **its own** position at the time of receipt, which for a moving player is not
the server's; velocity unchanged on all three axes (the rotation change is zero, so `ROTATE_DELTA` has no effect, and
adding a zero delta changes nothing); yaw and pitch unchanged. The previous-tick position rises by the same amount.
`onGround`, fall distance and sprint are unchanged. A block break in progress is stopped.

#### What the server changes

At the lift:

| Server record | Change |
|---|---|
| position | `(x + 0.0, y + lift, z + 0.0)`; box rebuilt; previous-tick position set to it |
| velocity | **replaced** on all three axes by the known movement (13.2): zero for a player who is standing still, otherwise the displacement of the last accepted movement packet. The server's previous velocity is lost |
| yaw, pitch, head yaw | yaw and pitch unchanged; head yaw set to the yaw |
| fall distance, `onGround`, collision flags, supporting block | unchanged |
| this tick's movement records (9.2) | cleared |
| teleport state | id advanced; awaited position := the new position |

When the Accept Teleportation arrives, the server puts the player at the awaited position and handles the answer's
position `P` as a movement packet with the ground flag false (13.2). With `v = P - awaited position`:

| Server record | Change |
|---|---|
| position | `v` is replayed and checked as for any movement packet (53 section 10.3); accepted: `P` |
| `onGround`, horizontal collision | set to **false** (until the next movement packet, or the server's own movement tick, sets them); the supporting block is cleared |
| fall distance | `v.y < 0`: grows by `-v.y` (12.1, no landing); `v.y > 0`: reset to 0; `v.y = 0`: unchanged |
| server-side jump | if the server's `onGround` was still true and `v.y > 0`, the server runs the ground jump of 13.5 (server velocity, jump exhaustion, statistic) before the replay |
| known movement | `v` (zero for a standing player) |

The lift itself deals no damage and does not end a fall.

#### Order against the block change

Lifts from scheduled block ticks, random ticks and precipitation happen before the level tick's block-change broadcast
(33 section 2.1 steps 6 and 8, section 2.2), and packet flushing is suspended for the whole server tick (33 section
1.2), so the client gets Player Position and then the block change (Block Update or Section Blocks Update) of the same
tick together. A lift made during packet handling, outside that suspension (rows 3 and 4 of 29b part 2 section 9.5.3,
and trampling by a player), is sent before that tick's broadcast (for rows 3 and 4 the Use Item On handler also sends
Block Update packets right after, 29 section 9.1 step 11). One made after the broadcast step of its level tick (for
example trampling by a mob, in the entity phase) is sent ahead of the block change, which waits for the next tick's
broadcast. In both of these cases the two packets can leave in different flushes (Open question 12). Which group a
`/place feature` lift (row 7) belongs to is not traced: the typed command's packet handler does not run it but hands it
to the server's task queue (`MinecraftServer.execute`), and when that task runs relative to the tick phases was not
read.

#### Worked (computed): farmland turns to dirt under a standing player

Farmland at block (10, 63, 20), turned to dirt by a random tick. Server and client: feet (10.5, 63.9375, 20.5), yaw and
pitch any; client velocity (0, -0.0784000, 0), `onGround` true.

1. Server, lift: `m = 63.9375`, `T = 64.0`, `d = 64.0 - 64.9375 = -0.9375`, `lift = 0.0625`. Position
   (10.5, 64.0, 20.5). Velocity := the known movement (0, 0, 0). Player Position: change (0, 0.0625, 0), delta (0, 0, 0),
   rotation (0, 0), flags 0x1FF. The block is then written.
2. The server's own movement tick, later in the same server tick, turns its velocity back into (0, -0.0784000, 0)
   (computed).
3. Client, packet phase: position (10.5, 64.0, 20.5), velocity still (0, -0.0784000, 0), `onGround` still true. It sends
   Accept Teleportation (id, 10.5, 64.0, 20.5, yaw, pitch). The Block Update makes the cell dirt.
4. Server, on the answer: `v = (0, 0, 0)`; `onGround` false; fall distance unchanged.
5. Client, next tick (computed): the move requests y -0.0784000, the dirt top stops it: no movement, `onGround` true,
   stored velocity (0, -0.0784000, 0). Because the position differs by more than 0.0002 from the last one it sent, it
   sends Move Player Pos (10.5, 64.0, 20.5) with the ground flag true (the send step of 2.1; its rule is in 05c, after
   Serverbound Move Player Status Only). The server accepts it and its `onGround` is true again.

A player whose feet are at y 64.0 on a full block next to the farmland, with the box reaching over the farmland cell, is
not a candidate: nothing is sent.

#### Worked (computed): farmland turns to dirt under a walking player

The same block. The player walks toward +z steadily, yaw 0: stored client velocity (0, -0.0784000, 0.1178591),
0.2158591 per tick (unrounded 0.215859068; the z values below are 20.5 plus one or two unrounded steps, rounded
afterwards, so the second is 20.9317181 although adding the rounded figures gives a last digit of 2). The server's last accepted position is (10.5, 63.9375, 20.5), reached by a movement of
(0, 0, 0.2158591). By the time the packet arrives the client has run one more tick, to z = 20.7158591; its movement packet
for that tick reaches the server after the lift and is discarded except for rotation.

Server, lift: as above, position (10.5, 64.0, 20.5); velocity := (0, 0, 0.2158591), which its own movement tick that
follows reduces to (0, -0.0784000, 0.1178591) if its `onGround` is true (computed). The packet is the same as for the
standing player.

| | A: the next cell (10, 63, 21) is farmland | B: the next cell is a full block, top y 64.0 |
|---|---|---|
| client before the packet (computed) | (10.5, 63.9375, 20.7158591) | (10.5, 64.0, 20.7158591): the box passed z = 21 and stepped up |
| client after the packet | (10.5, 64.0, 20.7158591) | (10.5, 64.0625, 20.7158591) |
| client velocity | unchanged (0, -0.0784000, 0.1178591) | unchanged |
| Accept Teleportation position | as after the packet | as after the packet |
| server `v` | (0, 0, 0.2158591) | (0, 0.0625, 0.2158591) |
| server on the answer | accepted; `onGround` false until the next movement packet | the same, and, `v.y` being above 0, fall distance reset and a server-side ground jump if its `onGround` was still true (inferred that it was; Open question 14) |
| client next tick (computed; sends Move Player Pos by the rule in 05c, 2.1 send step) | (10.5, 64.0, 20.9317181): the box still overlaps the new dirt, `onGround` true | moves down 0.0625 and forward: (10.5, 64.0, 20.9317181), `onGround` true |

In both cases the horizontal momentum is kept. In B the player was no longer standing on the changed block on its own
side, and is still raised, because the change is relative and the server chose it by the older position.

#### Lift by the player's own landing (trampling)

Trampling (29b part 2 section 9.3) runs inside the server's handling of the movement packet that lands. At that moment the
server position is the landing position, and the known movement is still that of the **previous** accepted packet, so
that becomes the server velocity. The fall damage of this landing and the reset of the fall distance follow the lift.
The handler then stores this packet's displacement (without the lift) as the known movement and takes the lifted
position as the last accepted one. If the landing hurts, the Set Entity Motion of 13.5 carries the server velocity as it
is when the tracker next processes the player, so it can contain this downward velocity (computed).

---

## 14. Where each gap is answered

| Gap | Section |
|---|---|
| DG-1 tick order, key values, all velocity changes, distance to unit square | 2, 3.2, 4 |
| DG-2 block speed factor, jump factor, climbing, bounce, step-on while flying | 8, 7.8 |
| DG-3 climbable and trapdoor, powder snow | 7.3 |
| DG-4 fall distance on the client | 12.1, 12.2 |
| DG-5 block effect pass on the client, cell order | 9 |
| DG-6 minor horizontal collision | 5.4 |
| DG-7 pushes and server velocity | 13 |
| DG-8 leaving a fluid, lava adjustment and sprint | 7.5, 7.6 |
| DG-9 closed list of block behaviours, mud, ice and slime friction | 10 |
| DG-10 effects and enchantments, updates sent | 11 |
| DG-11 lift by a growing block: packet, client resolution, server record, block changes, examples | 13.6, 13.2; 29b part 2 section 9.5 |
| Fall damage | 12 |

---

## Open questions

1. **Auto-jump.** The rule that arms the auto-jump counter (`LocalPlayer.updateAutoJump`, run after each of the local
   player's moves) was not read. Only its consumption (step 13) and its default (off) are stated.
2. **Other things that change a player's movement, found and not specified**: the Weaving effect (cobweb multiplier);
   Wind Charged (a burst on death); the freezing speed modifier of powder snow (`minecraft:powder_snow` on
   `movement_speed`, out of scope); the enchantments Frost Walker (creates ice), Riptide (a push on release), Lunge (a
   server impulse), Wind Burst (an explosion push); the mace smash and its shockwave (17 section 4.8); spears' kinetic
   attacks; elytra gliding, fireworks and riding; the item component `use_effects` (its multiplier is applied in 3.2,
   item values are not listed here); and the attributes `gravity`, `step_height`, `scale`, `jump_strength`,
   `friction_modifier`, `air_drag_modifier`, `bounciness`, `movement_efficiency`, `water_movement_efficiency`,
   `knockback_resistance`, `explosion_knockback_resistance`, `attack_knockback`, `safe_fall_distance` and
   `fall_damage_multiplier`, whose formulas appear above but whose sources (items, mobs, commands) are not listed.
3. **Pushes by non-living entities** (boats, minecarts) and entity collision shapes (boats, shulkers) that stop a
   player were not read.
4. **Entity tick order on the client** relative to the local player: only that the list is insertion ordered was read.
5. **Modifier order** within one operation is the iteration order of a hash map and was not reproduced; the effect is at
   most the last bit of a double before it is narrowed to float.
6. **Server tick consequences.** The velocities of 13.5 and the loss of momentum on damage follow from the read tick
   order; they were computed, not observed. How often the client's position packets for a given tick are handled before
   or after a particular server phase depends on timing (30 part 8, open question on packet handling order).
7. **Server replay and stuck blocks.** The server's replay of a position packet runs through the same move step, so a
   stuck multiplier left by the server's own block effect pass also scales the replayed movement. Its consequence for
   the "moved wrongly" check (53 section 10.3) was not analysed.
8. **`collidesWithSuffocatingBlock`** internals (4.4) and the cell enumeration of the collision queries (42 part 1
   section 4.4) are cited, not re-read.
9. **Voxel corner walk** (9.3) is described from the bytecode and was not exercised; its first-parameter behaviour when a
   step is 0 and the fraction is exactly 0 (the parameter starts at 0 and the first advance on that axis moves nowhere)
   was not traced further. It only matters when a leg crosses more than a cell or two in one tick.
10. **Flying on the ground**: a flying tick that starts with `onGround` true uses the ground acceleration formula with
    the speed attribute (7.8, with a worked example). Read from the branch conditions; not observed.
11. **Teleport Entity naming the local player** (13.2): the step arithmetic of the client's interpolation, and how the
    player's own movement during it is folded into the target, were not specified; whether a 26.3 server ever sends this
    packet to a player about itself was not traced.
12. **A client tick between a lift and its Block Update** (13.6): possible when the lift and the block-change broadcast
    leave the server in different flushes. The client would then simulate the raised position against the old block, and
    could fall back or end inside the new block when it arrives. Neither the timing nor the outcome was analysed or
    observed.
13. **Lift of a riding player** (13.6): the client of a passenger ignores the change and still answers (13.2), while the
    server's record is moved; what follows for the vehicle and the passenger was not traced.
14. **The server-side ground jump of walking case B** (13.6): it needs the server's `onGround` to be true when the answer
    arrives. That it still is, after the player's last movement packet and the server's own movement tick, is inferred;
    the packet and tick timing was not traced or observed.
