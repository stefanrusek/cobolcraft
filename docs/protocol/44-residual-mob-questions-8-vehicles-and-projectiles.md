# Residual mob questions, part 8: vehicles and projectiles

| Item | Value |
|---|---|
| Covers | Boats, rafts and chest boats (status, buoyancy, steering, passenger seats, bubble columns, damage); minecarts (the two movement behaviours and how one is chosen, rail physics, slope handling, every kind: plain, chest, hopper, furnace, TNT, spawner, command block); passenger attachment points of the player, the mannequin, boats, minecarts and the camel; the projectile framework (ownership, shooting, hit detection, deflection, gravity and drag orders), arrows (piercing, knockback, pickup, despawn), wind charges, fireball motion, thrown-item physics, lingering potion clouds, and the cross-reference of every mob ranged attack |
| Closes | 21 Open question 14 (boats and minecarts); 18 Open question 1 (seats: boats, rafts, chest boats, player, mannequin, camel); 18 Open question 12 (projectiles) |
| Not here | `thunderHit` effects, item pickup and throw delays (21 Open question 13: other rounds); the area effect cloud application loop and decorations (part 9); explosion internals (20 section 12 and later rounds) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.entity.vehicle.*`, `net.minecraft.world.entity.projectile.*`, `Entity`, `EntityTypes`, `Avatar`, `Camel`, `GameRules`, `FeatureFlags`, `DismountHelper`, `HopperBlockEntity`, `MinecartHopper`, `ThrownTrident`, `BoatItem`, `MinecartItem`, `ArrowItem`, `TridentItem` and `AbstractContainerMenu`, and a listing of `data/minecraft/datapacks/`, with no execution. Every value was read in this round; nothing was taken from memory without a read. Where a statement is an inference it says "(inferred)" |
| Status | Written by the reader for the gameplay story "all the standard mobs exist and have their standard behavior" in `tickets/CC-0001-client-polish.md`; GAP-31 of `docs/design/README.md` (RS26) |

Class names in backticks say where a fact was read; they are not the design. Tick = 1/20 s, distances in blocks, velocities in
blocks per tick unless stated. "Move" means the standard entity move with collision (`Entity.move`, 18 section 3). Angles in the
formulas are degrees unless written "rad". Tags and rules cited by name (`rails`, `can_turn_in_boats`, `deflects_projectiles`,
`redirectable_projectile`, `furnace_minecart_fuel`, `blocks_wind_charge_explosions`, game rules) are data or rule names: their
members come from the data pack (04 section 1, 21 section 3).

Nothing in this document is marked "(recalled, not verified)": values that were not read were left out and listed in the Open questions.

## Contents

1. [Cross-references and corrections to earlier documents](#1-cross-references-and-corrections-to-earlier-documents)
2. [The shared vehicle base](#2-the-shared-vehicle-base)
3. [Boats, rafts and chest boats](#3-boats-rafts-and-chest-boats)
4. [Minecarts](#4-minecarts)
5. [Passenger seats and attachment points](#5-passenger-seats-and-attachment-points)
6. [The projectile framework](#6-the-projectile-framework)
7. [Arrows (supplement to 17 section 3.9)](#7-arrows)
8. [Wind charges](#8-wind-charges)
9. [Fireballs and skulls: motion model](#9-fireballs-and-skulls-motion-model)
10. [Thrown items: physics, ender pearl, lingering potion](#10-thrown-items)
11. [Mob ranged attacks: where each one is specified](#11-mob-ranged-attacks)
12. [Worked examples](#12-worked-examples)
13. [Validation](#13-validation)
14. [Open questions](#14-open-questions)

## 1. Cross-references and corrections to earlier documents

What other documents already specify and is not repeated here:

| Topic | Where |
|---|---|
| Entity sizes, tracking ranges, metadata indexes of boats, minecarts and projectiles | 18 section 1.1, 21 section 2 and Appendix A, 21 section 8.8 and 8.9 |
| Bow, crossbow, trident, fishing hook, ender pearl, snowball, egg, splash potion, firework rocket, spear, elytra | 17 sections 3.9 to 3.13, 3.15 |
| Eye of ender, experience bottle, llama spit, ominous item spawner, breeze wind charge explosion | 21 sections 8.12, 8.13, 8.14, 8.17, 8.18 |
| Ghast, blaze, shulker bullet, dragon fireball, wither skull behaviours | 21 sections 5.1, 5.2, 6.2, 6.4 (dragon fireball), 7.2 |
| Skeleton family bow goal and shot, pillager and piglin crossbow, drowned trident, witch potion, snow golem snowball, llama spit | 20 sections on those mobs, 19 (snow golem, llama) |
| Knockback arithmetic of `LivingEntity` (`knockback` function) and the projectile knockback direction | 18 section 7 (4.6 of 17) |
| Entity tracking packets (Add Entity, Set Entity Motion, Teleport) | 18 section 6, 05a, 05b |

Corrections and clarifications to earlier text, read in this round:

1. **Arrow knockback** (`AbstractArrow.doKnockback`, read): 17 section 3.9 says the vertical component is added "when the horizontal
   speed is tiny". It is **always** 0.1. The rule is in section 7.4 below. Use this one.
2. **Piercing** (`AbstractArrow.onHitEntity` and `stepMoveAndHit`, read): the arrow is discarded on the **next** hit attempt after the
   ignore set holds `pierce + 1` entities, not at the moment the set fills (section 7.3). A pierce level of N therefore damages N + 1
   entities, and a further entity on the line discards the arrow without damage.
3. **A blocked arrow** (the hurt call returns false, for example a shield or invulnerability) bounces: it is deflected with
   `REVERSE` and a vector of 0.2 on each axis, the target's previous fire ticks are restored, and a nearly stopped arrow drops its
   item and disappears (section 7.3 step 9). 17 does not state this.
4. **Wither skull** (21 section 7.2): the inertia when not dangerous is 0.95 (the base value, read in `AbstractHurtingProjectile.getInertia`),
   the skull's hit explosion has radius 1.0, no fire, interaction MOB, after which the skull is discarded, and `isOnFire` is always false.

## 2. The shared vehicle base

`VehicleEntity` is the base of boats and minecarts. Fields: hurt time (metadata 8, int, default 0), hurt direction (metadata 9, int,
default 1), damage (metadata 10, float, default 0.0); the defaults 0, 1, 0.0 were read in `VehicleEntity.defineSynchedData`.

**Hurt on the client** (`hurtClient`): always returns true (the swing is accepted; nothing else happens).

**Hurt on the server** (`hurtServer(level, source, amount)`), in order:

1. If the entity is removed: return true. If it is invulnerable to the source (base invulnerability test, 18 section 7): return false.
2. `hurtDir = -hurtDir`; `hurtTime = 10`; mark the entity hurt (it is re-sent).
3. `damage += amount x 10`.
4. Game event `ENTITY_DAMAGE` with the attacking entity as the source.
5. `creative` = the attacker is a player with infinite materials (`abilities.instabuild`).
6. If (not `creative` and `damage > 40`) or `shouldSourceDestroy(source)` (false for every boat and minecart, read as the base
   implementation, never overridden here): **destroy**. Otherwise, if `creative`: discard immediately (no drop).
7. Return true.

So a non-creative player destroys a boat or minecart when the accumulated damage exceeds 40: that is amounts summing past 4.0
(each hit adds 10 x amount), for example one hit of 5 or more, or two of 2.1 or more. `damage` decays by 1 per tick and `hurtTime` by 1 per tick (sections 3.2 and 4.2).

**Destroy** (`destroy(level, damageSource)` calls `destroy(level, dropItem)`): `kill(level)`; if the game rule `entity_drops` is false stop;
otherwise spawn the drop item (one item, named after the vehicle's custom name if it has one) at the vehicle's position. Container
variants additionally scatter their contents (sections 3.9 and 4.6). Boats drop the item their type supplies (the matching boat, raft, chest boat
or chest raft item); plain, spawner and (for `MinecartSpawner`) minecart kinds drop `minecart`; the other kinds drop their own item
(`chest_minecart`, `furnace_minecart`, `hopper_minecart`, `tnt_minecart`, `command_block_minecart`: read in each `getDropItem`).

**Explosions**: `ignoreExplosion(explosion)` is true when the explosion's indirect source is a `Mob` and the rule `mob_griefing` is false.

**`animateHurt(yaw)`** (client, run when the client is told the entity was hurt): `hurtDir = -hurtDir`, `hurtTime = 10`; boats then multiply `damage` by 11; minecarts do `damage += damage x 10`
(that is x 11 too).

`isPickable` is true while the entity is not removed (boats and minecarts alike). `getDimensionChangingDelay` is the base value.

## 3. Boats, rafts and chest boats

### 3.1 Constants and facts

| Item | Value |
|---|---|
| Classes | `Boat` and `ChestBoat` (wooden), `Raft` and `ChestRaft` (bamboo); the 22 entity types of 21 Appendix A. Chest variants extend `AbstractChestBoat` |
| Size | 1.375 x 0.5625, tracking range 10, update interval 3 (18 section 1.1) |
| Collision | `canBeCollidedWith` true, `isPushable` true; `canCollideWith(other)` (`canVehicleCollide`): true when the other entity is collidable or pushable and is not a passenger of the same vehicle |
| `blocksBuilding` | true |
| Passenger limit | `getMaxPassengers`: 2 for boats and rafts, 1 for chest boats and chest rafts |
| `canAddPassenger(e)` | passengers < max passengers **and** the boat's own eye position is not inside water (`isEyeInFluid(water)` false, tested on the boat) |
| Time to eject | `TIME_TO_EJECT` = 60 (ticks under water, see 3.3) |
| Paddle step | `PADDLE_SPEED` = 0.3926991 rad per tick (pi / 8); paddle sound crossing at 0.7853982 rad |
| Bubble time | 60 |
| Default gravity | `getDefaultGravity` = 0.04. The effective gravity `Entity.getGravity()` is final: 0 when the entity is marked no-gravity, else `getDefaultGravity()` (read) |
| Status enum order | `IN_WATER` (0), `UNDER_WATER` (1), `UNDER_FLOWING_WATER` (2), `ON_LAND` (3), `IN_AIR` (4) |
| Metadata | 21 Appendix A (hurt, hurt direction, damage, paddle left, paddle right, bubble time) |
| Persistence | the boat saves its leash data; chest boats also save the 27 slots and the optional loot table key with its seed |

### 3.2 Per-tick order (`AbstractBoat.tick`)

1. `oldStatus = status`; `status = getStatus()` (3.3).
2. If `status` is `UNDER_WATER` or `UNDER_FLOWING_WATER`: `outOfControlTicks += 1`; otherwise `outOfControlTicks = 0`.
3. On the server, if `outOfControlTicks >= 60`: eject all passengers.
4. `hurtTime` decreases by 1 while > 0; `damage` decreases by 1 while > 0.
5. Base vehicle tick (entity tick, effects, lerp).
6. If the local instance is **authoritative** (`isLocalInstanceAuthoritative`: on the server, true unless the controlling passenger's client is authoritative, that is, a player is steering; on the client, true for the steering player's own client):
   a. If the first passenger is not a player: `setPaddleState(false, false)`.
   b. `floatBoat()` (3.4).
   c. On the client: `controlBoat()` (3.5), then send Paddle Boat (05c, `ServerboundPaddleBoat`) with the two paddle booleans.
   d. `move(SELF, velocity)`.
   Otherwise (not authoritative): velocity = 0 and `deltaRotation = 0`.
7. Block effects (`applyEffectsFromBlocks()`, read as called twice in a row; harmless).
8. `tickBubbleColumn()` (3.7).
9. Paddle animation (cosmetic, no gameplay effect): per side, while that paddle state is true the phase `paddlePositions[i]` advances by 0.3926991 per tick (reset to 0 when the state is false); when the phase crosses 0.7853982 (mod 2 pi) a paddle sound plays (`boat paddle water` for status ordinals 0 to 2, `boat paddle land` for `ON_LAND`, none for `IN_AIR`) at the boat position offset 1 block sideways along the view vector (side 0 and side 1 opposite), volume 1.0, pitch `0.8 + 0.4 x nextFloat`.
10. **Pushing and loading**: entities in the box of the boat inflated by (0.2, -0.01, 0.2) that satisfy `EntitySelector.pushableBy(boat)` are processed in list order. `canLoad` = server side and the controlling passenger is not a player. For each entity that is not already a passenger of the boat: if `canLoad` and the boat has fewer passengers than its maximum and the entity is not a passenger of something, and its width is less than the boat's width (`hasEnoughSpaceFor`: entity width < 1.375) and it is a `LivingEntity` and not in tag `cannot_be_pushed_onto_boats`: it **starts riding** the boat; otherwise the boat is pushed (`push(entity)`, below).

**Boat push rule** (`AbstractBoat.push(other)`): if `other` is itself a boat, the base push (18 section 3, entity-versus-entity push) happens only when `other.minY < boat.maxY`; for any other entity only when `other.minY <= boat.minY`. So entities standing above the boat's bottom do not push a boat.

### 3.3 Status (`getStatus`, `isUnderwater`, `checkInWater`, `getGroundFriction`)

Evaluated in this order; the first rule that applies wins.

1. **Under water** (`isUnderwater`): let `top = box.maxY + 0.001`. For every block cell in x floor(minX)..ceil(maxX) - 1, y floor(maxY)..ceil(top) - 1, z floor(minZ)..ceil(maxZ) - 1 that holds water (fluid tag `water`) and for which `top < cellY + fluidHeight`: if the fluid is a **source**, remember "under water"; if it is **flowing**, return `UNDER_FLOWING_WATER` immediately. After the scan, "under water" gives `UNDER_WATER`. If a status is returned here, `waterLevel = box.maxY`.
2. **In water** (`checkInWater`): scan the cells x floor(minX)..ceil(maxX) - 1, y floor(minY)..ceil(minY + 0.001) - 1, z likewise; for each water cell, `waterLevel = max(waterLevel, cellY + fluidHeight)` (starting from the negative largest double, -1.7976931348623157E308, read as the constant), and "in water" is set when `box.minY < cellY + fluidHeight`. If in water: `IN_WATER`.
3. **On land**: `friction = getGroundFriction()` (below). If `friction > 0`: `landFriction = friction`, status `ON_LAND`.
4. Otherwise `IN_AIR`.

**Ground friction** (average block friction under the boat): a thin slab `(minX, minY - 0.001, minZ) to (maxX, minY, maxZ)`. Iterate x from floor(minX) - 1 to ceil(maxX) (inclusive of the +1 margin: the loop bound is exclusive at `ceil(maxX) + 1`), z likewise, y from floor(minY) - 1 to ceil(maxY) (exclusive bound `ceil(maxY) + 1`). Let `edges` = (x is the first or last column ? 1 : 0) + (z is the first or last row ? 1 : 0). Skip the corner columns (`edges == 2`). When `edges > 0` also skip the lowest and highest y layers. For every remaining cell whose block is not a lily pad and whose collision shape, moved to the cell, intersects the slab: add the block's friction (`Block.getFriction`, block registry data) to a sum and count 1. The result is `sum / count` (an empty count gives NaN, which fails `> 0`, so the status is `IN_AIR`).

**`getWaterLevelAbove`** (used by 3.4): scan columns over x floor(minX)..ceil(maxX) - 1, z likewise, and y from floor(maxY) to ceil(maxY - lastYd) - 1; at each y take the largest water fluid height among the columns (`f`, starting from 0); the first y where `f < 1` returns `y + f`; if none, return `ceil(maxY - lastYd)`... plus 1 (read as `ceil(...) + 1`). `lastYd` is the vertical velocity recorded in `checkFallDamage` (3.8).

### 3.4 Buoyancy and drag (`floatBoat`)

Local values at the start: `gravityTerm = -gravity` (that is -0.04), `buoyancy = 0`, `drag = 0.05`.

1. **Re-entry**: if `oldStatus == IN_AIR` and `status` is neither `IN_AIR` nor `ON_LAND` (the boat has just touched water from the air): `waterLevel = top y of the box (getY(1.0))`; compute `y' = getWaterLevelAbove() - height + 0.101`; if the boat's box moved to `y'` (x and z unchanged) has no collision, set the position to `y'`, multiply the velocity by (1, 0, 1) and set `lastYd = 0`. In both cases of the collision test the status is then set to `IN_WATER`. The branch then ends `floatBoat` (read: the jump from the end of the branch goes straight to the return). On a re-entry tick therefore **no drag, no gravity term and no buoyancy are applied**: steps 2 to 4 do not run, the initial locals (including the 0.05 drag) are never used, and the only velocity change is the (1, 0, 1) multiply when the repositioned box is collision-free (the vertical velocity becomes 0 in that case; if the box collides, the velocity is untouched).
2. Otherwise (no re-entry) select by status:

| Status | `buoyancy` | `drag` | `gravityTerm` |
|---|---|---|---|
| `IN_WATER` | `(waterLevel - y) / height` | 0.9 | -0.04 |
| `UNDER_FLOWING_WATER` | 0 | 0.9 | -0.0007 |
| `UNDER_WATER` | 0.01 | 0.45 | -0.04 |
| `IN_AIR` | 0 | 0.9 | -0.04 |
| `ON_LAND` | 0 | `landFriction` | -0.04 |

   (For `ON_LAND` with a player steering, the field `landFriction` is halved **after** the drag was taken, so it does not change this tick's drag.)
3. Apply: `velocity = (vx x drag, vy + gravityTerm, vz x drag)`; `deltaRotation = deltaRotation x drag`.
4. If `buoyancy > 0`: `vy = (vy + buoyancy x (defaultGravity / 0.65)) x 0.75`, where `defaultGravity / 0.65 = 0.0615385`.

Consequences: in plain water the boat settles where `buoyancy = 0.65`, that is when the waterline is 0.65 x 0.5625 = 0.365625 above the boat's origin; fully submerged (`UNDER_WATER`) it rises by `0.01 x 0.0615385 = 0.000615` minus gravity 0.04, so it sinks slowly with drag 0.45 (and is ejected after 60 ticks); in air it falls with drag 0.9 on x and z.

### 3.5 Steering (`controlBoat`, runs on the steering player's client; the result reaches the server by Move Vehicle (05c))

Inputs `left`, `right`, `up`, `down` come from the steering player's input (`setInput`). If the boat has no passenger the method does nothing.

1. `f = 0`. If `left`: `deltaRotation -= 1`. If `right`: `deltaRotation += 1`.
2. If exactly one of `left`, `right` is held and neither `up` nor `down` is held: `f += 0.005` (turning on the spot nudges forward).
3. `yRot += deltaRotation`.
4. If `up`: `f += 0.04`. If `down`: `f -= 0.005`.
5. `velocity += (sin(-yRot x pi/180) x f, 0, cos(yRot x pi/180) x f)`.
6. Paddle state: left paddle = (`right` and not `left`) or `up`; right paddle = (`left` and not `right`) or `up` (read: `setPaddleState(left paddle, right paddle)` is called with exactly these two values; the animation is cosmetic).

The controlling passenger (`getControllingPassenger`) is the first passenger when it is a player; for any other first passenger the boat has no controller (the base rule).

### 3.6 Seats, rotation of passengers

**Attachment point** (`getPassengerAttachmentPoint`): the point is `Vec3(0, rideHeight, zOffset)` rotated about the vertical axis by `-yRot` (so a positive z offset is towards the bow). `zOffset` starts as `getSinglePassengerXOffset()`: 0.0 for boats and rafts, 0.15 for chest boats and chest rafts. If the boat has more than one passenger: the first passenger (index 0 in the passenger list) gets `+0.2`, the other gets `-0.6`; a passenger that is an `Animal` adds a further `+0.2`, but **only inside that same more-than-one-passenger branch** (read: the Animal test sits in the same branch as the seat offsets). With a single passenger there is no Animal bonus: a lone Animal sits at z = 0.0 on a boat or raft (0.15 on a chest boat or chest raft).

`rideHeight` (`rideHeight(dimensions)`): wooden boats and chest boats `height / 3` = 0.1875; rafts and chest rafts `height x 0.8888889` = 0.5.

**Passenger rotation** (`positionRider`, `clampRotation`, `onPassengerTurned`): passengers of an entity type in tag `can_turn_in_boats` are left alone. For the others, when the passenger's instance is authoritative each tick: passenger yaw and head yaw increase by the boat's `deltaRotation`; then `clampRotation(passenger)`:

1. `bodyYaw = boat.yRot`, except that an `Animal` passenger when the boat is full (passengers == max) gets `boat.yRot + 90` when its entity id is even and `+ 270` when odd (sitting sideways).
2. The passenger's body yaw is set to `bodyYaw`. A `Mob` passenger also gets its yaw set to `bodyYaw` and its head clamped to the body, and the method returns `wrapDegrees(bodyYaw - passenger.yRot)`.
3. Any other passenger (a player): `delta = wrapDegrees(passenger.yRot - bodyYaw)`, clamped to -105..105; the passenger's yaw becomes `passenger.yRot + clamped - delta`; the method returns `clamped - delta`.

`onPassengerTurned(e)` adds the returned value to `e.yRotO` (so the camera does not jump).

### 3.7 Bubble columns

`onAboveBubbleColumn(down, pos)` (called by the bubble column block, server only): sets `isAboveBubbleColumn = true`, remembers the direction (`down` true for a drag column), and if `bubbleTime` is 0 sets it to 60. If the boat is not under water, with probability 1/100 (`nextInt(100) == 0`) a swim splash sound (volume 1.0, pitch `0.8 + 0.4 x nextFloat`), a splash particle at `(x + nextFloat, y + 0.7, z + nextFloat)` and a `SPLASH` game event (source = the controlling passenger) are produced.

`tickBubbleColumn` each tick:
- **Client**: if `bubbleTime > 0`, `bubbleMultiplier += 0.05`, else `-= 0.1`; clamp to 0..1; `bubbleAngleO = bubbleAngle`; `bubbleAngle = 10 x sin(0.5 x tickCount) x bubbleMultiplier` (rendering only).
- **Server**: if not `isAboveBubbleColumn`: `bubbleTime = 0`. Else if `bubbleTime > 0`: decrement it; with `k = 60 - bubbleTime - 1` (computed after the decrement): when `k > 0` and `bubbleTime == 0` the column acts: `bubbleTime = 0`; if the column drags (down): eject all passengers and broadcast Entity Event 71; otherwise broadcast Entity Event 72; then `handleBubbleColumnEffect(down)`. Finally `isAboveBubbleColumn = false`.
- `handleBubbleColumnEffect(down)` (also run by clients on events 71 and 72 when the client simulates the boat): velocity `+= (0, -0.7, 0)` when down, else `vy = 0.6` (x and z kept).

So a boat above a bubble column waits 60 ticks (about 3 s) and is then launched upward (vy = 0.6) or pulled down with its passengers ejected.

### 3.8 Fall damage and fluids

`checkFallDamage(dy, onGround, state, pos)`: records `lastYd = velocity.y`; a boat that is a passenger does nothing else; on the ground the fall distance is reset; otherwise if the block below the boat's block position holds no water and `dy < 0`, the fall distance is reduced by `dy` (grows). (Boats take no fall damage by themselves in this class; the base class handles what a landing does, 18.)
`modifyPassengerFluidInteractionBox(box)` (passenger inside fluid test): when the boat is under water the passenger's box is unchanged; else if the boat's top is not below the passenger box's top the box is dropped (null); otherwise the box is clipped to start at `max(box.minY, boat.maxY)`.

### 3.9 Interaction, leash, chest boats

- **`interact(player, hand, hit)`**: first the base vehicle interaction (leash handling); if it returns anything but PASS that is the result. Otherwise: when the player is not using secondary use and `outOfControlTicks < 60`: on the server `player.startRiding(boat)` decides success (SUCCESS); on the client SUCCESS is returned optimistically. Else PASS.
- **Chest boats** (`AbstractChestBoat.interact`): base interaction first; then if the boat can take a passenger and the player is **not** using secondary use, the result is PASS and the base riding rule applies (the player boards); otherwise `interactWithContainerVehicle(player)` opens the 27-slot chest menu (3 rows of 9, menu type `generic_9x3`; menu layout is GAP-19, 13 and later documents) and, if it consumed the action on the server, the `CONTAINER_OPEN` game event is emitted and nearby piglins are angered (`PiglinAi.angerNearbyPiglins`, 21 Open question 4). Container size 27.
- **Destroy of a chest boat**: `destroy` drops the boat item then calls `chestVehicleDestroyed` (the contents scatter; with a loot table key set and not yet generated the loot is generated first, as for the player-opened chest). `remove(reason)`: on the server, when the removal reason destroys, the contents are dropped (`Containers.dropContents`). A leashed boat drops its leash on removal.
- **Dismount** (`getDismountLocationForPassenger(passenger)`): let `escape = collisionHorizontalEscapeVector(boat.width x sqrt(2), passenger.width, passenger.yRot)`; candidate x = `boat.x + escape.x`, z = `boat.z + escape.z`. If the block position `(x, boat.maxY, z)` holds no water: collect up to two candidate heights (the floor height of the block, then of the block below, kept when `isBlockFloorValid`); for each dismount pose of the passenger in order (`getDismountPoses`) and each candidate: if `DismountHelper.canDismountTo` accepts the point, the passenger takes that pose and that location. If nothing fits (or the cell holds water) the base vehicle location is used.

### 3.10 Items and spawning

**Boat item** (`BoatItem.use`): a fluid-including pick ray from the player's eye (`ClipContext.Fluid.ANY`); a miss gives PASS. Any pickable entity (selector `CAN_BE_PICKED`) in the player's box expanded 5 blocks along the view vector and inflated by 1 whose box (inflated by its pick radius) contains the eye position makes it PASS. On a block hit: create the boat of the item's type at the hit location (`SPAWN_ITEM_USE`, default stack configuration applied), set its yaw to the player's yaw; FAIL if the boat's box collides with anything; on the server add the entity, emit `ENTITY_PLACE` at the hit location, and consume 1 item (survival); award the item-used statistic; SUCCESS. Other hit types give PASS. Villager boat trades are in 19 section 24. The dispenser behaviour (`BoatDispenseItemBehavior`) was not read (Open question 11).

**Minecart item** (`MinecartItem.useOn`): the clicked block must be in tag `rails` (else FAIL). The cart is created at `(x + 0.5, y + 0.0625 + 0.5 if the rail shape is a slope else 0, z + 0.5)` of the clicked block (for a `BaseRailBlock` its shape; other rail-tag blocks count as `north_south`). With the experimental minecart behaviour active the placement fails (FAIL) if any minecart already overlaps the new cart's box. On the server the cart is added, `ENTITY_PLACE` is emitted at the rail position (context: the player and the block below), and 1 item is consumed; SUCCESS.

## 4. Minecarts

### 4.1 Kinds and shared constants

| Kind (entity) | Class | Drop item | Default display block | Notes |
|---|---|---|---|---|
| `minecart` | `Minecart` | `minecart` | per item (none) | rideable |
| `chest_minecart` | `MinecartChest` | `chest_minecart` | chest | 27 slots |
| `hopper_minecart` | `MinecartHopper` | `hopper_minecart` | hopper, display offset 1 | 5 slots |
| `furnace_minecart` | `MinecartFurnace` | `furnace_minecart` | furnace facing north, `lit` = has fuel | pushes |
| `tnt_minecart` | `MinecartTNT` | `tnt_minecart` | `tnt` | explodes |
| `spawner_minecart` | `MinecartSpawner` | `minecart` | `spawner` | `BaseSpawner` |
| `command_block_minecart` | `MinecartCommandBlock` | `command_block_minecart` | command block | |

Shared (`AbstractMinecart`): size 0.98 x 0.7, tracking range 8, update interval 3, `blocksBuilding` true, `isPushable` true, `isPickable` while not removed;
`isRideable` is true only for the plain minecart. Metadata: 21 Appendix A (custom display block, display offset, plus kind fields). NBT: the custom display block state and display offset, and `flipped` (default false).
Water slowdown factor 0.95 (`WATER_SLOWDOWN_FACTOR`). Gravity `getDefaultGravity` = 0.005 when in water, else 0.04.
Block speed factor (`getBlockSpeedFactor`): 1.0 while the block at the cart is in tag `rails`, else the base entity value (soul sand and honey apply off the rails).
The cart's **air drag** when off the rails and not on the ground is 0.95 (`getAirDrag`).

### 4.2 Per-tick order (`AbstractMinecart.tick`)

1. `hurtTime` and `damage` decay by 1 per tick while > 0 (as boats).
2. `checkBelowWorld`, `computeSpeed` (the speed estimate used by `getKnownMovement`), `handlePortal`.
3. `behavior.tick()` (4.4 for the old behaviour, 4.5 for the new).
4. `updateFluidInteraction()` (the base fluid push).
5. If in lava: `lavaIgnite()`, `lavaHurt()` (18 section 2.5) and `fallDistance x= 0.5`.
6. `firstTick = false`.

### 4.3 Which behaviour runs: `MinecartBehavior` selection

`AbstractMinecart.useExperimentalMovement(level)` is true when the level's enabled feature flags contain `minecart_improvements`
(`FeatureFlags.MINECART_IMPROVEMENTS`). The constructor creates `NewMinecartBehavior` in that case and `OldMinecartBehavior` otherwise.

- The **default feature set** is the `vanilla` flag only (`FeatureFlags.DEFAULT_FLAGS`); `minecart_improvements` is a separate flag whose data pack is the built-in experimental pack `data/minecraft/datapacks/minecart_improvements` (the artifact ships only its `pack.mcmeta`; the flag, not data files, switches the code).
  **The standard world type therefore runs `OldMinecartBehavior`** unless a world enables that experimental pack.
- `NewMinecartBehavior` is gated by the same flag; the game rule `max_minecart_speed` (integer, default **8**, minimum 1, maximum 1000, category MISC) exists only when the flag is enabled.
- Interpolation: with the old behaviour the entity uses the linear interpolation handler (client lerp); with the new behaviour no entity-level interpolation is used (the new behaviour interpolates itself over 3 ticks, `POS_ROT_LERP_TICKS`).
- The two behaviours share `AbstractMinecart` (tick, kinds, push). They differ in how a cart is moved along a rail (4.4 and 4.5).

An implementation for the standard world type needs 4.4 only; 4.5 is specified for completeness of the experimental pack (and as the target if a later decision enables it).

### 4.4 `OldMinecartBehavior` (the default)

Constants: `MINECART_RIDABLE_THRESHOLD` 0.01; `MAX_SPEED_ON_LAND` 0.4; `MAX_SPEED_IN_WATER` 0.2; `ABSOLUTE_MAX_SPEED` 0.4; slope acceleration base 1/128 = 0.0078125; powered-rail boost 0.06; start-from-rest push 0.02; stationary nudge 0.001; brake 0.5 with stop below 0.03.

**Per server tick** (`OldMinecartBehavior.tick`; the client only advances rotations and interpolation):

1. `applyGravity()` (the entity gravity of 4.1, applied to vy).
2. `blockPos = getCurrentBlockPosOrRailBelow()`: the cart's block, or the block below it when the cart's block is not a rail and the one below is in tag `rails`; (the experimental variant of this function uses y - 0.1 - 1e-5, 4.5).
3. `onRails = BaseRailBlock.isRail(state at blockPos)`.
4. If `onRails`: `moveAlongTrack` (below); if the rail is an **activator rail**: `activateMinecart(level, x, y, z, powered)` (kind specific, 4.6).
   Else: `comeOffTrack` (below).
5. `applyEffectsFromBlocks()`; `xRot = 0`.
6. **Yaw**: `dx = xo - x`, `dz = zo - z` (previous position minus current). If `dx^2 + dz^2 > 0.001`: `yRot = atan2(dz, dx) x 180 / pi`, plus 180 when `flipped`. Then `d = wrapDegrees(yRot - yRotO)`: if `d < -170` or `d >= 170` (the cart reversed direction): `yRot += 180` and `flipped = not flipped`. `xRot` and `yRot` are reduced mod 360.
7. `pushAndPickupEntities()` (4.4.3).

**`comeOffTrack`** (not on a rail): `m = maxSpeed(level)` (0.4, or 0.2 in water); `vx` and `vz` are clamped to `[-m, m]`; if on the ground `velocity x= 0.5`; `move(SELF, velocity)`; if not on the ground `velocity x= airDrag` (0.95). So a derailed cart slides with friction 0.5 per tick on the ground.

#### 4.4.1 `moveAlongTrack` (on a rail)

Inputs: the rail block state at `blockPos`, the cart position `(px, py, pz)`.

1. `fallDistance = 0`. `oldRailPos = railPoint(px, py, pz)` (4.4.2, may be null). Set `y = blockPos.y`.
2. `powered` = the rail is a `powered_rail` with `powered = true`; `brake` = the rail is a `powered_rail` with `powered = false`. (Plain rails, detector rails, activator rails: neither.)
3. `slope = 0.0078125`, times 0.2 when the cart is in water.
4. **Slope pull**: for the four ascending shapes, the cart accelerates down the slope and `y` is raised by 1: `ascending_east`: `vx -= slope`; `ascending_west`: `vx += slope`; `ascending_north`: `vz += slope`; `ascending_south`: `vz -= slope`. Other shapes: no change, `y` unchanged.
5. **Align velocity with the rail**: the two exits of the shape (table 4.4.4) give `(dx, dz) = second - first` (horizontal parts), `len = sqrt(dx^2 + dz^2)`. If `vx x dx + vz x dz < 0` the pair is negated. `speed = min(2.0, horizontalSpeed)`. The velocity becomes `(speed x dx / len, vy, speed x dz / len)` (the cart keeps its speed but follows the rail direction; going into a bend it takes the rail's direction).
6. **Player input start**: if the first passenger is a `ServerPlayer` whose last client move intent vector (`getLastClientMoveIntent`, the movement input, not normalised) has non-zero length, and the cart's horizontal speed squared is below 0.01: `velocity += (intent.x x 0.001, 0, intent.z x 0.001)` and `brake = false` (the cart does not brake and can be nudged from rest by the rider pressing movement keys).
7. **Brake**: if `brake`: with `h` = horizontal speed: if `h < 0.03` the velocity becomes zero, else `velocity x= (0.5, 0, 0.5)`.
8. **Snap to the rail**: let `p1 = (blockX + 0.5 + first.x x 0.5, blockZ + 0.5 + first.z x 0.5)` and `p2` likewise with `second`; `(ex, ez) = p2 - p1`. The parameter `t`: if `ex == 0`: `t = pz - blockZ`; else if `ez == 0`: `t = px - blockX`; else `t = ((px - p1x) x ex + (pz - p1z) x ez) x 2`. New `px = p1x + ex x t`, `pz = p1z + ez x t` (the cart is projected onto the rail line). `setPos(px, y, pz)`.
9. **Move**: `f = 0.75` if the cart has a passenger else `1.0`; `m = maxSpeed`. `move(SELF, (clamp(f x vx, -m, m), 0, clamp(f x vz, -m, m)))` where `v` is the velocity read after step 7 (a loaded cart moves at 0.75 of its stored speed).
10. **Slope Y correction**: if `first.y != 0` and the cart's block offset from `blockPos` equals `(first.x, first.z)` (it is in the block just beyond the low end), `setPos(x, y + first.y, z)` (so y - 1 at the foot of the slope); else if `second.y != 0` and the offset equals `(second.x, second.z)`, `setPos(x, y + second.y, z)`.
11. **Natural slowdown**: `velocity = applyNaturalSlowdown(velocity)` (kind specific; base: `velocity x (factor, 1, factor)` with `factor` 0.997 when the cart carries a passenger, else 0.96, then `x 0.95` more when in water; 4.6 for the kinds).
12. **Height along the rail**: `newRailPos = railPoint(x, y, z)`. If both it and `oldRailPos` exist: `dy = (oldRailPos.y - newRailPos.y) x 0.05`; with `h` = horizontal speed > 0: `velocity x= ((h + dy) / h, 1, (h + dy) / h)` (going up a slope loses speed, down gains). Then `setPos(x, newRailPos.y, z)`.
13. **Next-block redirect**: if `floor(x) != blockX` or `floor(z) != blockZ` (the cart crossed into the next block): with `h` = horizontal speed, `velocity = (h x (floor(x) - blockX), vy, h x (floor(z) - blockZ))` (all horizontal speed is redirected along the axis of the step).
14. **Powered rail push**: if `powered`: `h` = horizontal speed; if `h > 0.01`: `velocity += (vx / h x 0.06, 0, vz / h x 0.06)`. Else (nearly stopped): take `(vx, vz)`; for an `east_west` rail: if the block to the west is a redstone conductor (`isRedstoneConductor`) `vx = 0.02`, else if the block to the east is `vx = -0.02`; for a `north_south` rail: north conductor `vz = 0.02`, else south conductor `vz = -0.02`; other shapes: stop the method here; finally `velocity = (vx, vy, vz)`. (So a stopped cart on a powered rail starts away from an adjacent solid block.)

The stored velocity is **not** clamped by the move limit of step 9; with a powered rail the stored speed can rise above the move limit (step 5 caps it at 2.0). Worked example 12.4.

#### 4.4.2 `railPoint(x, y, z)` (`getPos`)

Used for the height along a rail. `(bx, by, bz)` = floor of the arguments; if the block `(bx, by - 1, bz)` is in tag `rails`, `by -= 1`. If the block at `(bx, by, bz)` is a rail: with the shape's exits `first`, `second`: `p1 = (bx + 0.5 + first.x x 0.5, by + 0.0625 + first.y x 0.5, bz + 0.5 + first.z x 0.5)` and `p2` likewise; `(ex, ey, ez) = (p2.x - p1.x, (p2.y - p1.y) x 2, p2.z - p1.z)`; `t` as in step 8 of 4.4.1 (`ex == 0`: `z - bz`; `ez == 0`: `x - bx`; else the dot product form x 2). The result is `(p1.x + ex x t, p1.y + ey x t, p1.z + ez x t)`, then `+1` to y when `ey < 0` and `+0.5` when `ey > 0`. Rails sit 0.0625 above the block's floor. If the cell is not a rail the result is null.

#### 4.4.3 Pushing and picking up (`pushAndPickupEntities`)

Box = the cart's box inflated by (0.2, 0, 0.2).
- If the cart `isRideable` (plain minecart) and its horizontal speed squared >= 0.01: for every entity in the box accepted by `EntitySelector.pushableBy(cart)`: if the entity is **not** a player, **not** an iron golem, **not** a minecart, and the cart has no passenger and the entity is not riding: it **boards** the cart (`startRiding`). Otherwise the entity is pushed (`entity.push(cart)`).
- Otherwise (not rideable, or slow): every entity in the box (any entity) that is not already a passenger of the cart, is pushable and is a minecart is pushed by the cart.
- The function returns false (it is only used by the new behaviour's logic).

#### 4.4.4 Rail shapes: exits and slopes

Each shape has two **exits**, vectors from the block centre: `W (-1, 0, 0)`, `E (1, 0, 0)`, `N (0, 0, -1)`, `S (0, 0, 1)`, and `x-below` meaning the same vector with y = -1 (the low end of a slope).

| Shape | First exit | Second exit | Slope pull in 4.4.1 step 4 |
|---|---|---|---|
| `north_south` | N | S | none |
| `east_west` | W | E | none |
| `ascending_east` | W below | E | `vx -= 1/128` |
| `ascending_west` | W | E below | `vx += 1/128` |
| `ascending_north` | N | S below | `vz += 1/128` |
| `ascending_south` | N below | S | `vz -= 1/128` |
| `south_east` | S | E | none |
| `south_west` | S | W | none |
| `north_west` | N | W | none |
| `north_east` | N | E | none |

Because the lower end of an `ascending_*` shape is the one named by "below" (the high end is the direction in the name), the pull points away from the named direction (down the hill).

#### 4.4.5 Redstone helper

`getRedstoneDirection(pos)` (used by the new behaviour's boost, 4.5): zero vector unless the block is a powered `powered_rail`; for `east_west`: `(+1, 0, 0)` when the west neighbour is a redstone conductor, `(-1, 0, 0)` when the east one is; for `north_south`: `(0, 0, +1)` for north, `(0, 0, -1)` for south; otherwise zero.

### 4.5 `NewMinecartBehavior` (experimental pack only)

Constants: `POS_ROT_LERP_TICKS` 3; `ON_RAIL_Y_OFFSET` 0.1; `OPPOSING_SLOPES_REST_AT_SPEED_THRESHOLD` 0.005.

- **Max speed**: `max_minecart_speed` (default 8) x (0.5 in water, else 1) / 20, that is 0.4 per tick by default, 0.2 in water.
- **Slowdown factor** (`getSlowdownFactor`): 0.997 with a passenger, **0.975** without (old: 0.96).
- **Rail position**: the cart's `getCurrentBlockPosOrRailBelow` samples the block at `y - 0.1 - 1e-5`; if that block is in `rails`, the cart is on that rail.
- **`moveAlongTrack`** loops while the iteration says to continue and the cart is alive. Each iteration: take the block and rail shape at the cart; if the on-rail flag changed, set it and `adjustToRails`. If on a rail: reset the fall distance, record the old position and rotation; activator rail callbacks as in the old behaviour; compute the new velocity with `calculateTrackSpeed` (below); update `movementLeft` (in the first iteration `movementLeft` = horizontal speed of the new velocity; later it adds `new horizontal speed - old horizontal speed`); then `movementLeft = stepAlongTrack(blockPos, shape, movementLeft)`. If not on a rail: `comeOffTrack` and `movementLeft = 0`. After the loop the position delta sets the rotation (yaw from the horizontal movement `180 - atan2(dz, dx)` in degrees, plus 180 when flipped; pitch `90 - atan2(horizontalDistance, dy)` degrees, times -1 when flipped; 0 while on the ground and off rails; when the horizontal movement is below 1e-5 and not on rails the pitch relaxes towards 0 by factor 0.2) and a movement step (position, velocity, rotations, `min(length, maxSpeed)`) is recorded for interpolation.
- **`calculateTrackSpeed`** (applied in order, each at most once per `moveAlongTrack` call except the slowdown which is first iteration only):
  1. **Slope** (once): acceleration `a = max(0.0078125, horizontalSpeed x 0.02)`, x 0.2 in water; for `ascending_east`: `vx -= a`; `ascending_west`: `vx += a`; `ascending_north`: `vz += a`; `ascending_south`: `vz -= a`.
  2. **Player input** (first iteration): as step 6 of 4.4.1 but the intent is normalised and the nudge is `normalize((ix, 0, iz)) x 0.001`, added when the cart's horizontal speed squared is below 0.01.
  3. **Halt**: on a `powered_rail` that is **not** powered: speed below 0.03 gives zero, else `velocity x 0.5`. (Any other block returns the velocity unchanged.)
  4. **Slowdown** (first iteration): `velocity = applyNaturalSlowdown(velocity)`; if its length is above zero it is rescaled to `min(length, maxSpeed)`.
  5. **Boost** (once): only on a **powered** `powered_rail`: if the speed is above 0.01 the speed is increased by 0.06 (same direction); else, from rest, `redstoneDirection x (speed + 0.2)` (zero direction: unchanged).
- **`stepAlongTrack(pos, shape, movementLeft)`**: returns 0 when `movementLeft < 1e-5` (the unused distance otherwise). It chooses the exit that the horizontal velocity points towards (the exit whose half-vector has the larger dot product with the velocity), makes the target point `blockBottomCentre + exit x 0.5 (horizontal) + (0, 0.1, 0) + normalise(exit) x 1e-5`, adds `+1` in y for a slope exit when the cart is not descending, rescales the velocity so that its horizontal part matches the direction to the target, advances up to `movementLeft` (the step length is multiplied by sqrt(2) when the rail's two exits differ in height (`first.y != second.y`, a slope; the factor is `Mth.SQRT_OF_TWO`), see Open question 1) and moves the cart with `move(SELF, delta)`. After the move it checks the block entered: on a slope, if the cart came to rest at a V shape (`restAtVShape`: speed squared below 0.005, the new rail is a slope the cart is not descending while the old one descended) the velocity is zeroed and 0 is returned; the cart is lifted to the slope surface when it sank below it; and if the cart barely moved (distance below 1e-5 while the intended distance was larger) the velocity becomes zero and 0 is returned.
- **Pushing** (`pushAndPickupEntities`): `pickupEntities(box inflated (0.2, 0, 0.2))` (boarding rule of 4.4.3 for a rideable cart without a passenger; returns true when an entity boarded); if the cart had a horizontal or vertical collision this tick, `pushEntities(box inflated by 1e-7)` (pushes players, golems, passengers and non-rider entities; for non-rideable carts pushes other minecarts). The result is `pickedUp and not pushed`.
- **Cart-versus-cart push** (`pushOtherMinecart`) uses the cart's own velocity instead of the position difference: see 4.6.

### 4.6 Entity collisions, kinds and activator rails

**Entity versus cart push** (`AbstractMinecart.push(entity)`, server only; returns at once on the client, when either entity has `noPhysics`, or when the cart is a vehicle of that entity):

1. `(dx, dz)` = entity position minus cart position (horizontal). `d2 = dx^2 + dz^2`. If `d2 < 0.0001` nothing happens.
2. `d = sqrt(d2)`; `dx /= d`; `dz /= d`; `s = min(1 / d, 1)`; `dx x= s`, `dz x= s`; then `dx x= 0.1`, `dz x= 0.1` and `dx x= 0.5`, `dz x= 0.5` (total factor 0.05 x s).
3. If the entity is a minecart: `pushOtherMinecart(other, dx, dz)` (below). Otherwise: the cart gets `push(-dx, 0, -dz)` and the entity gets `push(dx / 4, 0, dz / 4)`.

**`pushOtherMinecart(other, dx, dz)`** (called on the cart that is being pushed): `a = (old behaviour) (other.x - x, other.z - z)` or `(new behaviour) this cart's own horizontal velocity`; `n = normalize((a.x, 0, a.z))`; `r = normalize((cos(yRot), 0, sin(yRot)))`; `align = |n . r|`. If `align < 0.8` and the old behaviour is active: return (carts at an angle do not interact). Let `mine` = this cart's velocity and `theirs` = the other cart's velocity:
- other is a furnace cart and this is not: `mine x= (0.2, 1, 0.2)`; `this.push(theirs.x - dx, 0, theirs.z - dz)`; `theirs x= (0.95, 1, 0.95)`.
- this is a furnace cart and the other is not: `theirs x= (0.2, 1, 0.2)`; `other.push(mine.x + dx, 0, mine.z + dz)`; `mine x= (0.95, 1, 0.95)`.
- otherwise: `avg = ((theirs.x + mine.x) / 2, (theirs.z + mine.z) / 2)`; `mine x= (0.2, 1, 0.2)`; `this.push(avg.x - dx, 0, avg.z - dz)`; `theirs x= (0.2, 1, 0.2)`; `other.push(avg.x + dx, 0, avg.z + dz)`.

**Activator rail**: `activateMinecart(level, x, y, z, powered)`: base does nothing. Per kind:
- `minecart` (plain): when powered: eject passengers if any; if `hurtTime == 0`: `hurtDir = -hurtDir`, `hurtTime = 10`, `damage = 50`, mark hurt (this shakes a cart without damaging it; damage 50 will exceed 40 on the next hit and break it).
- `hopper_minecart`: `enabled = not powered` (an activator rail that is **powered** disables the hopper).
- `tnt_minecart`: when powered and `fuse < 0`: `primeFuse(null)`.
- `command_block_minecart`: when powered and `tickCount - lastActivated >= 4`: run the command block (`performCommand`), `lastActivated = tickCount` (read: `lastActivated = tickCount` is stored immediately after `performCommand`; the guard is `tickCount - lastActivated >= 4` and the command runs only when powered).
- others: nothing.

**Plain minecart** (`Minecart.interact(player)`): if the player is not using secondary use and the cart has no passenger: `playerRotationOffset = rotationOffset`; on the server `player.startRiding(cart)` gives SUCCESS_SERVER, otherwise CONSUME (client prediction); else PASS. `Minecart.tick` (client only) accumulates `rotationOffset` for the rider's camera when the cart moved more than 0.01 (`rotationOffset += (yaw change mod 360)`, kept below 360); with the new behaviour a rider that rotates with minecarts (client option) has its yaw adjusted by the lerped offset difference.

**Chest minecart and hopper minecart** (`AbstractMinecartContainer`): container with item list; the constructor allocates 36 entries, the sizes are **27 (chest)** and **5 (hopper)** (`getContainerSize` in the subclasses; the list length 36 of the abstract base is larger than any use, (inferred) it only matters for save format: save/read use the container size). `interact` = `interactWithContainerVehicle` (opens the menu: `generic_9x3` for the chest, the hopper menu (5 slots) for the hopper; the hopper menu is `HopperMenu`); destroy scatters the contents (and a loot table key, when set and ungenerated, is rolled as for chests); `remove` with a destroying reason drops the contents.
- **Slowdown of container carts**: `f = 0.98`; when no loot table is set (the cart is not an unopened loot cart), `f += (15 - redstoneSignal) x 0.001` where `redstoneSignal` is the comparator output of the container (`AbstractContainerMenu.getRedstoneSignalFromContainer`, 17 and the container rules); when in water `f x= 0.95`; the velocity is multiplied by `(f, 0, f)` (this replaces the base factors 0.96 and 0.997). `getRedstoneSignalFromContainer(container)` (read): 0 for a null container; otherwise the sum over non-empty slots of `count / container max stack size for that stack`, divided by the container size, mapped to 0..15 with `Mth.lerpDiscrete(f, 0, 15)` (the rounding rule of that helper was not read, so intermediate fill levels are (inferred) to round down; an empty container is 0 and a completely full one is 15). A full cart (signal 15) therefore slows at 0.98 per tick and an empty one at 0.995.
- **Hopper minecart** `tick`: `consumedItemThisFrame = false`; base tick; `tryConsumeItems`. `makeStepAlongTrack` also calls `tryConsumeItems` after each step. `tryConsumeItems` (server, alive, enabled, not yet consumed this frame): `suckInItems()`: first `HopperBlockEntity.suckInItems(level, cart)` (rules below; the cart is not grid aligned and its hopper position is `(x, y + 0.5, z)`), and if that did nothing, the first `ItemEntity` that is alive in the cart's box inflated by (0.25, 0, 0.25) and accepted by `HopperBlockEntity.addItem(container, item)`. On success `consumedItemThisFrame = true` and `setChanged()`. Saved field `Enabled` (default true). 
**Hopper pull rules** (`HopperBlockEntity.suckInItems`, `addItem`, read; the block entity's own tick, cooldown 8 and pushing are not part of this document):

1. Source cell = the block containing `(levelX, levelY + 1, levelZ)`. A container is the block's `WorldlyContainerHolder` container, else its block entity when that is a container (a chest block joins double chests), else, when the block gives none, a random one of the container entities (selector `CONTAINER_ENTITY_SELECTOR`) in the 1 x 1 x 1 box centred on that point.
2. If a container exists: for each slot of the source (the face `DOWN` slot list for a sided container, else all slots in order), `tryTakeInItemFromSlot`: skip empty slots and slots the source refuses (`canTakeItem` and, for sided containers, `canTakeItemThroughFace`); remove **one** item and try to insert it into the hopper; on full success the source is marked changed and the pull succeeds (stop); otherwise the item is put back (when the slot had exactly 1 item the original stack is set back). One item moves per call.
3. If no container exists: when the hopper is grid aligned and the source cell has a full-block collision shape and is not in tag `does_not_block_hoppers`, nothing is taken (not the case for the cart); otherwise every living `ItemEntity` in the pickup box is tried in list order with `addItem(container, entity)`. The pickup box is `SUCK_AABB` (a column of width 1 spanning heights 11/16 to 2 above its base, i.e. x and z 1 wide, y from 0.6875 to 2.0) moved so its base corner is at `(levelX - 0.5, levelY - 0.5, levelZ - 0.5)`.
4. `addItem(container, entity)`: copy the entity stack, insert it with no source and no face; if nothing is left the entity's stack is emptied and it is discarded (return true), else the entity keeps the remainder (return false).
5. Insertion (`addItem(source, dest, stack, face)`): iterate the destination slots (the face's slot list for a sided container, else 0 to size - 1) while the stack is non-empty, calling `tryMoveInItem`: the slot must accept the item (`canPlaceItem` and, for sided containers, `canPlaceItemThroughFace`); an empty slot takes the whole stack; a non-empty slot merges when its count is <= its max stack size and the two stacks have the same item and components, moving `min(max - count, stack count)`.

**Furnace minecart**: fuel ticks `fuel` (int, saved as short `Fuel`), vector `push` (saved as `PushX`, `PushZ`, default zero); constants `FUEL_TICKS_PER_ITEM` 3600, `MAX_FUEL_TICKS` 32000.
- `interact(player, hand)`: `addFuel(player.position, held stack)`; if it returned true the stack shrinks by 1 (survival); the result is always SUCCESS.
- `addFuel(playerPos, stack)`: the stack must be in the item tag `furnace_minecart_fuel` (data) and `fuel + 3600 <= 32000`; then `fuel += 3600`. If `fuel > 0` afterwards, `push = horizontal(cart position - playerPos)` (the cart is pushed away from the player). Returns true when fuel was added (false leaves everything unchanged and the stack is kept).
- `tick` (server): if `fuel > 0`: `fuel -= 1`; if `fuel <= 0`: `push = 0`; the synced flag `hasFuel` (metadata 13) is `fuel > 0`; a client smoke particle with probability 1/4 per tick while it has fuel.
- `getMaxSpeed`: `base x 0.5` on land, `base x 0.75` in water, where `base` is the behaviour's max speed (0.4 / 0.2 for the old behaviour: 0.2 on land, 0.15 in water).
- `applyNaturalSlowdown(v)`: if `push.lengthSqr > 1e-7`: `push = newPushAlong(v)` and `w = v x (0.8, 0, 0.8) + push`, then `w x= 0.1` when in water; else (no push) `w = v x (0.98, 0, 0.98)`; the result then goes through the base slowdown. `newPushAlong(v)`: if `push.horizontalSqr > 1e-4` and `v.horizontalSqr > 1e-3`: `normalize(projectionOf push onto v) x |push|`; else `push` unchanged. The cart therefore pulls itself along the rail in the direction it was pushed, losing nothing to friction while fuelled.

**TNT minecart**: fields `fuse` (-1 = not primed), `explosionPowerBase` (4.0, NBT `explosion_power`), `explosionSpeedFactor` (1.0, NBT `explosion_speed_factor`), `ignitionSource`.
- `tick`: if `fuse > 0`: `fuse -= 1` and a smoke particle at `(x, y + 0.5, z)`; else if `fuse == 0`: `explode(ignitionSource, horizontalSpeedSqr)`. Independently: with a horizontal collision and horizontal speed squared `>= 0.01`: `explode(ignitionSource, horizontalSpeedSqr)`.
- `primeFuse(source)`: if the `tnt_explodes` rule is false, nothing. Else `fuse = 80`; the broadcast of Entity Event 70 (clients prime on it, `handleEntityEvent(70)`) follow. Read in full: after `fuse = 80`, on the server, when a source is given and `ignitionSource` is still null, `ignitionSource` becomes an explosion damage source built from (the cart, the source's entity); then Entity Event 70 is broadcast; then, if the cart is not silent, the `tnt_primed` sound plays with the blocks sound source, volume 1.0, pitch 1.0 at the cart position.
- `hurtServer`: if the direct entity of the damage is an `AbstractArrow` that is on fire: `explode(explosion source (the attacker), arrowVelocity.lengthSqr)`; then the base hurt.
- `destroy(level, source)` (breaking by damage): if the source ignites TNT (`damageSourceIgnitesTnt`: a burning projectile, a fire damage type, or an explosion damage type, read from the tag and projectile tests) **or** the cart's horizontal speed squared is `>= 0.01`: when `fuse < 0` prime it and set `fuse = nextInt(20) + nextInt(20)` (a short random fuse, 0 to 38); the cart is not destroyed. Otherwise the cart is destroyed and drops `tnt_minecart` normally.
- `causeFallDamage(distance, ...)`: if `distance >= 3.0`: `v = distance / 10`; `explode(ignitionSource, v x v)`; then the base fall damage.
- `explode(source, speedSqr)` (server, only when `tnt_explodes` is true): `s = min(sqrt(speedSqr), 5.0)`; radius `= explosionPowerBase + explosionSpeedFactor x nextDouble() x 1.5 x s`; explosion at the cart's position, no fire, interaction `TNT`, damage source `source`; then the cart is discarded. When `tnt_explodes` is false the cart is only discarded if it is primed.

**Spawner minecart**: owns a `BaseSpawner` (the block spawner's logic); the server ticks it each tick (`serverTick`), clients tick the particles (`clientTick`); Entity Events are forwarded to the spawner (`onEventTriggered`); NBT is the spawner's. Display block `spawner`. Its spawn logic is the spawner block's (Open question 12).

**Command block minecart**: its command block data (`Command`, `LastOutput`, `TrackOutput`, `SuccessCount` in the command block base) is stored in metadata 13 and 14 (21 Appendix A). Interaction: a player that cannot use game master blocks gets PASS; otherwise on the client the command block screen opens (`openMinecartCommandBlock`) and SUCCESS is returned. Execution: only by an activator rail (above).

**Dismount** (`AbstractMinecart.getDismountLocationForPassenger`, read):

1. `direction` = the cart's motion direction. If its axis is vertical, use the base vehicle dismount location and stop.
2. Otherwise take the side offsets `DismountHelper.offsetsForDirection(direction)` (the table is in **DismountHelper** below) around the cart's block position.
3. For each dismount pose of the passenger in order (`getDismountPoses`): `halfWidth = min(pose width, 1) / 2`. For each pose height in order (`POSE_DISMOUNT_HEIGHTS`: standing and crouching 0, 1, -1; swimming 0, 1) and for each offset: the cell is the cart's block plus (dx, height, dz); `floor` = the block floor height of that cell (`getBlockFloorHeight` over `nonClimbableShape`); skip when `isBlockFloorValid(floor)` is false. Otherwise the passenger box (x and z from -halfWidth to +halfWidth, y from 0 to the pose height) is moved to `upFromBottomCenterOf(cell, floor)`; if `canDismountTo` accepts it, the passenger takes that pose and the point is returned.
4. If nothing fits: the point (block x, cart box maxY, block z) is used to choose a pose only: for each pose in order, `ceiling = findCeilingFrom(pos, ceil(maxY - posY + pose height))`; the first pose with `maxY + pose height <= ceiling` is set. The returned location is then the base vehicle dismount location.

**DismountHelper** (read this round, `DismountHelper`):

- `offsetsForDirection(d)`: let `a` = `d` turned clockwise, `b` = the opposite of `a`, `c` = the opposite of `d`; the eight (dx, dz) offsets, in this order, are `a`, `b`, `c + a`, `c + b`, `d + a`, `d + b`, `c`, `d` (each term is the horizontal unit step of that direction; sums add components).
- `isBlockFloorValid(h)`: true when `h` is finite and `h < 1`.
- `canDismountTo(world, entity, box)`: true when every block collision shape intersecting the box is empty and the box is inside the world border. The overload taking a point and a pose moves the entity's local box for that pose to the point first.
- `nonClimbableShape(pos)`: an empty shape when the block is in tag `climbable` or is an open trapdoor, else the block's collision shape.
- `findCeilingFrom(pos, n, shapeAt)`: for k = 0 to n - 1 going up from `pos`, the first cell whose shape is non-empty returns `pos.y + k + shape minimum y`; if none, positive infinity.
- `findSafeDismountLocation(type, world, pos, checkDangerous)` (used by other vehicles): null if `checkDangerous` and the block is dangerous for the type; the floor height is read over the shape of the block below (`nonClimbableShape`); null when `isBlockFloorValid` fails, or when `checkDangerous` and the floor height is <= 0 and the block below is dangerous; the point is `upFromBottomCenterOf(pos, floor)`; null if the type's box there collides; for the `player` type null when the block or the block above is in tag `invalid_spawn_inside`; null outside the world border; else the point.

**Hurt and drops**: section 2. A minecart with a passenger being hurt behaves the same.

## 5. Passenger seats and attachment points

An entity's seat on a vehicle is the vehicle's **passenger attachment point** for it (`getPassengerAttachmentPoint(passenger, dimensions, ageScale)`) combined with the passenger's **vehicle attachment** (`vehicleAttachment` of the passenger's entity type, a point relative to the passenger's feet that is put on the seat). The passenger's feet therefore sit at `vehiclePosition + seat - passengerVehicleAttachment` (18 section 1.1.1 gives the formula and the table for types that declare attachments).

| Entity | Read value |
|---|---|
| Player (`player` type) | `vehicleAttachment` = `Avatar.DEFAULT_VEHICLE_ATTACHMENT` = `(0, 0.6, 0)`. Standing dimensions 0.6 x 1.8, eye height 1.62 |
| Mannequin | the same `Avatar.DEFAULT_VEHICLE_ATTACHMENT` = `(0, 0.6, 0)`, dimensions 0.6 x 1.8, eye 1.62 |
| Boat, raft (2 seats) | section 3.6: `(0, 0.1875 or 0.5, +0.2 first / -0.6 second; with two passengers an Animal gets +0.2 more; a lone passenger sits at 0.0, no Animal bonus)` rotated by -yRot |
| Chest boat, chest raft (1 seat) | `(0, 0.1875 or 0.5, 0.15)` rotated by -yRot (never an Animal bonus: at most one passenger) |
| Minecart (all kinds) | the builder's passenger attachment (18 section 1.1.1: y 0.1875 for the minecart kinds), except that a `Villager` or `WanderingTrader` passenger uses the **lowered** attachment `(0, 0, 0)` (`LOWERED_PASSENGER_ATTACHMENT`) |
| Camel and camel husk | computed per seat, below (Animal +0.2 applies to both seats when there are two or more passengers). The entity type declares no passenger attachments; maximum passengers: `canAddPassenger` allows a passenger while `passengers.size() <= 2` (read), that is up to **3** passengers (the seat code gives index 0 the front seat and every index above 0 the rear seat; no separate max-passenger override exists in `Camel`, and `CamelHusk` overrides none of these, read) |

**Camel seat** (`Camel.getPassengerAttachmentPoint`): `index = max(0, passengers.indexOf(passenger))`; `first = (index == 0)`; `z = 0.5`; when there is more than one passenger: if not `first`, `z = -0.7`; then, for **either** seat, if the passenger is an `Animal`, `z += 0.2` (the Animal test follows the first/non-first choice inside the same more-than-one-passenger branch; read in bytecode). So with two or more passengers an Animal in the front seat sits at 0.7 and an Animal in a rear seat at -0.5; a non-Animal sits at 0.5 or -0.7; a single passenger (Animal or not) sits at 0.5 with no bonus. The point is `(0, y, z x ageScale)` rotated by `-yRot`. `y` = 0.01 when the camel is removed, else `bodyAnchorY(first, 0.0, dimensions, ageScale)` (read in `getBodyAnchorAnimationYOffset`), defined with `scale = ageScale` (baby 0.6, adult 1.0) by:

- `h = dimensions.height - (baby ? 0.09375 : 0.375)` (the dimensions are those of the current pose, so they are lower while sitting); `s = 1.43 x scale`; `d1 = s - 0.2 x scale`; `d2 = s - d1 = 0.2 x scale`.
- Not in a pose transition: `y = h`, plus `d2` when the camel is sitting.
- In a pose transition (`LAST_POSE_CHANGE_TICK` within 40 ticks of sitting down or 52 ticks of standing up): total `T = 40` (sitting down) or `52` (standing up); split point `P` and fraction `k` depend on the seat: sitting down: `P = 28`, `k = 0.5` (front seat) or `0.1` (rear seat); standing up: `P = 24` (front) or `32` (rear), `k = 0.6` (front) or `0.35` (rear). Let `t = clamp(poseTime + partialTick, 0, T)`, `firstPhase = t < P`, `u = firstPhase ? t / P : (t - P) / (T - P)`, `mid = s - k x d1`. Sitting down: `y = h + lerp(u, firstPhase ? s : mid, firstPhase ? mid : d2)`. Standing up: `y = h + lerp(u, firstPhase ? (d2 - s) : (d2 - mid), firstPhase ? (d2 - mid) : 0)`.

The seat height thus animates by up to 1.43 blocks during sitting and standing (`SITTING_HEIGHT_DIFFERENCE` 1.43; `SITDOWN_DURATION_TICKS` 40, `STANDUP_DURATION_TICKS` 52). The server uses partialTick 0.

**Camel leash offset** (`Camel.getLeashOffset(partialTick)`): the point `(0, bodyAnchorY(first = true, partialTick, current-pose dimensions, ageScale) - 0.2 x ageScale, width x 0.56)` with the current-pose width; it is not rotated here.

**Camel pose clock** (`Camel`, read): metadata `LAST_POSE_CHANGE_TICK` (long, saved `LastPoseTick`, default 0). Sitting is the sign: the camel `isCamelSitting` when the value is negative. `poseTime = gameTime - |value|`. `isInPoseTransition` = `poseTime < 40` while sitting, `< 52` while standing. `sitDown()` (no-op if already sitting): sit sound, pose SITTING, `ENTITY_ACTION` game event, value = `-gameTime`. `standUp()` (no-op if standing): stand sound, pose STANDING, game event, value = `+gameTime`. `standUpInstantly()` and finalizeSpawn set STANDING and the value `max(0, gameTime - 52 - 1)` (a finished stand). Reading a saved negative value also sets the SITTING pose. `tick`: dashing ends when `dashCooldown < 50` and the camel is on the ground, in liquid or a passenger; `dashCooldown` counts down by 1 and plays the dash-ready sound at 0; while refusing to move the head is clamped to the body; a sitting camel in water stands up instantly.

**Camel travel** (`Camel.travel`, `tickRidden`, read; the base horse travel is not repeated): `refuseToMove` = sitting or in a pose transition. `travel`: if `refuseToMove` and on the ground, the velocity x and z are zeroed (y kept) and the input x and z are zeroed, then the horse travel runs. While refusing to move the ridden input is zero and the ridden rotation is the camel's own. After the base ridden tick, a rider whose forward input is positive makes a sitting camel not in transition stand up. Ridden speed = movement speed attribute (0.09 base for the camel) + 0.1 while the rider sprints and the jump cooldown is 0. `canSprint` true; `canJump` false while refusing to move; `onPlayerJump` is ignored unless saddled, `dashCooldown <= 0` and on the ground. Attributes read: max health 32, movement speed 0.09, jump strength 0.42, step height 1.5.

**Camel dash** (`executeRidersJump(power, input)`, `Camel`): `horizontal = normalize(look x (1, 0, 1)) x 22.2222 x power x movementSpeed x blockSpeedFactor`; `vertical = 1.4285 x power x jumpPower` where `jumpPower` is the camel's jump strength; `velocity += (horizontal.x, vertical, horizontal.z)`; `dashCooldown = 55`; `dashing = true`; sync. Other constants: `RUNNING_SPEED_BONUS` 0.1, `DASH_MINIMUM_DURATION_TICKS` 5, `IDLE_MINIMAL_DURATION_TICKS` 80, `MAX_HEAD_Y_ROT` 30, baby scale 0.6. The camel's brain, travel and sit/stand state machine are in 19 and 18 section 4.7 (travel: above).

## 6. The projectile framework

### 6.1 `Projectile` base

Fields: `owner` (an entity reference stored by UUID, saved as `Owner`), `leftOwner` (saved `LeftOwner`), `hasBeenShot` (saved `HasBeenShot`), `leftOwnerChecked`, `lastDeflectedBy`. `isPickable` is true only for entity types in tag `redirectable_projectile`; `getPickRadius` = 1.0 when pickable else 0. `getDimensionChangingDelay` = 2. `getMoveSimulationType` = server and client both simulate. `hurtServer` of a plain projectile marks it hurt (unless invulnerable) and returns false.

**Tick** (`Projectile.tick`, called at the end of each subclass tick): if `hasBeenShot` is false: game event `PROJECTILE_SHOOT` (source = owner) and `hasBeenShot = true`. Then `checkLeftOwner`, then the base entity tick, then `leftOwnerChecked = false`.
**`checkLeftOwner`**: while `leftOwner` is false and not yet checked this tick: `leftOwner = isOutsideOwnerCollisionRange()`; mark checked. `isOutsideOwnerCollisionRange`: true when there is no owner; else build the box `projectile.box expandTowards velocity, inflated by 1`; the owner's whole vehicle tree (root vehicle and all its passengers) is tested: the projectile has left the owner's range when **none** of those entities that can be picked (`EntitySelector.CAN_BE_PICKED`) has a box intersecting it. This is what lets a projectile spawn inside its shooter without hitting it.
**`canHitEntity(e)`**: false unless `e.canBeHitByProjectile()` (the entity is alive and pickable); when the projectile still has an owner that has **not** left (`!leftOwner`) the owner's vehicle companions are excluded: `e` is hit-able only if it is not a passenger of the same vehicle as the owner (`isPassengerOfSameVehicle`); true otherwise.
**`mayInteract` / `mayBreak(level, pos)`**: server checks used by blocks hit by projectiles (the owner's permission test); `canBreakBlockInAdventureMode` per the owner.

**Shooting** (`getMovementToShoot(dx, dy, dz, power, uncertainty)`): `v = normalize((dx, dy, dz)) + (triangle(0, 0.0172275 x uncertainty), triangle(0, ...), triangle(0, ...))` (three independent draws, in x, y, z order, `RandomSource.triangle(centre 0, spread)`), then `x power`. `shoot(...)`: velocity = that vector; `needsSync = true`; `yRot = atan2(vx, vz) x 57.2957763671875`, `xRot = atan2(vy, horizontalLength) x 57.2957763671875`; `yRotO = yRot`, `xRotO = xRot`. (The arrow's `shoot` additionally resets `life = 0`.)
**`shootFromRotation(shooter, xRot, yRot, zRot, power, uncertainty)`**: direction `(-sin(yRot) x cos(xRot), -sin(xRot + zRot), cos(yRot) x cos(xRot))` (angles in radians; `zRot` is the extra pitch offset), `shoot` with it, then the shooter's known movement `(mx, my, mz)` is added to the velocity with `my` replaced by 0 when the shooter is on the ground (17 section 3.9 states the same rule).

**Spawn helpers** (`spawnProjectileFromRotation`, `spawnProjectileUsingShoot`, `spawnProjectile`): create the entity at the shooter (the owner, with the owner set and `applyOnProjectileSpawned` for weapon enchantment effects such as Flame), add it to the level.

### 6.2 Hit detection (`ProjectileUtil.getHitResultOnMoveVector`)

Used by every projectile except the arrow (the arrow's own steps are in 7.2). Inputs: the entity's position `P`, velocity `V`, a predicate (`canHitEntity`), clip type (default `COLLIDER`), and `margin = computeMargin(entity) = max(0, min(0.3, (tickCount - 2) / 20))` (it grows from 0 at tick 2 to 0.3 at tick 8, so a freshly shot projectile does not hit things that are barely touching it).

1. `end = P + V`. Block clip: `clipIncludingBorder` from `P` to `end` with the clip type and no fluids (the world border counts as a hit). If it hits, `end` = the hit location.
2. Entity search: candidates in the projectile's box expanded towards `V` and inflated by 1, filtered by the predicate. For each, its box inflated by `margin` is clipped against the segment `P` to `end`; the candidate with the smallest squared distance from `P` wins. (The other overload used by arrows also inflates by the entity's `getPickRadius()`; if the segment starts inside the box the entity counts only when `canBePickedFromInside`.)
3. If an entity was found it is the result; otherwise the block result (or a miss).

### 6.3 Deflection (`ProjectileDeflection`)

`deflect(deflection, deflector, newOwner, byAttack, vector)` on the server: runs the deflection function (`deflection.deflect(projectile, deflector, random, vector)`), sets the owner to `newOwner`, and calls `onDeflection(byAttack)`. Four deflections:

| Name | Effect (`vector` = s) |
|---|---|
| `NONE` | nothing |
| `REVERSE` | `velocity x= (-0.5 x s.x, -0.5 x s.y, -0.5 x s.z)` componentwise; `yRot += 170 + nextFloat x 20` (a turn of 170 to 190 degrees), `yRotO += the same`; `needsSync` |
| `AIM_DEFLECT` | if a deflector exists: `velocity = deflector.lookAngle x s` (componentwise); `needsSync` |
| `MOMENTUM_DEFLECT` | if a deflector exists: `velocity = normalize(deflector.knownSpeed) x s`; `needsSync` |

With the usual `s = (1, 1, 1)` `REVERSE` halves the speed and reverses it. A trident uses `s = (0.02, 0.2, 0.02)` (17 section 3.10): speed x 0.01 per horizontal axis and x 0.1 vertical, so it drops and stops.

`hitTargetOrDeflectSelf(hit)`:
- Entity hit: `deflection = entity.deflection(projectile)`: the default entity returns `REVERSE` when its type is in tag `deflects_projectiles`, else `NONE`; the **breeze** overrides: wind charges (`wind_charge`, `breeze_wind_charge`) are not deflected (`NONE`), other projectiles get the breeze's own deflection when it is in the tag. If the deflection is not `NONE` and the entity is not `lastDeflectedBy` the projectile's current deflector: `deflect(deflection, entity, owner, false, 1.0)`; on success `lastDeflectedBy = entity`. Return the deflection (the hit is **not** processed when it is not `NONE`).
- Block hit: if it is a world border hit and the projectile `shouldBounceOnWorldBorder` (arrows only): `REVERSE` with s = 0.2. If it is a block hit and the block is air, `NONE` (no hit: this guards border and chunk glitches).
- Otherwise `onHit(hit)` runs and `NONE` is returned.

**`onHit(hit)`** (base): for an entity hit: if the entity's type is in tag `redirectable_projectile` and it is a `Projectile` (fireball, wind charge): `onRedirectProjectile(thatProjectile)` (it is `AIM_DEFLECT`ed onto the shooter's aim: `deflect(AIM_DEFLECT, this.getOwner(), this.owner, byAttack = true, 1.0)`), then `onHitEntity`, then game event `PROJECTILE_LAND` at the hit location. For a block hit: `onHitBlock` (the block's `onProjectileHit` callback: used by target blocks, bells, chorus flower, and similar, which are block behaviour, 28 in the design map), then `PROJECTILE_LAND` at the block.

### 6.4 `AbstractHurtingProjectile` (fireballs, wind charges, skulls): constant-thrust motion

Field `accelerationPower` (double, saved as `acceleration_power`, default **0.1** when the field is absent; wind charges set 0).

- **Construction with a direction** (`new X(level, owner, movement, ...)`, the ghast, blaze, dragon, wither and player constructors): position = the owner's position, owner set, rotation = the owner's rotation; then `velocity = normalize(movement) x accelerationPower`. The fireball therefore **starts slowly** (0.1 per tick) and speeds up; mob code sets the final position afterwards (21 sections 5.1, 5.2, 7.2).
- **Tick order** (`AbstractHurtingProjectile.tick`): (1) `applyInertia()`; (2) server: discard the projectile if its owner is removed or the chunk at its position is not loaded (`hasChunkAt` false) (an ownerless projectile only checks the chunk); (3) hit test `getHitResultOnMoveVector` with the clip type `COLLIDER` (the velocity read **after** step 1); (4) `end` = hit location when something was hit, else `P + V`; (5) `rotateTowardsMovement(0.2)` (yaw and pitch ease towards the velocity direction by factor 0.2: yaw = `atan2(vz, vx) x 57.2958 + 90`, pitch = `atan2(horizontalSpeed, vy) x 57.2958 - 90`, with the previous angles first unwrapped into +-180 of the current ones); (6) `setPos(end)`; (7) `applyEffectsFromBlocks()`; (8) `Projectile.tick()` (shoot event, left-owner check, entity tick); (9) if `shouldBurn()` (default true): `igniteForSeconds(1)` (the fireball burns, which lights the entity it hits only through its own `onHit`); (10) if the hit was not a miss and the projectile is alive: `hitTargetOrDeflectSelf(hit)`; (11) a client-side trail particle (cosmetic).
- **`applyInertia`**: `v = (v + normalize(v) x accelerationPower) x inertia`, where `inertia` = 0.95 normally and **0.8** when the projectile is in water (`getLiquidInertia`; while in water 4 bubble particles per tick appear along the path). The terminal speed is `accelerationPower x inertia / (1 - inertia)` = 1.9 in air and 0.4 in water for the default 0.1.
- **Collision rules**: `canHitEntity` = the base rule and the target must not have `noPhysics`. `hurtServer` returns false (fireballs cannot be damaged through the hurt path: the player's attack redirects them via `redirectable_projectile` pickability, 6.3).
- **`onDeflection(byAttack)`**: `accelerationPower = 0.1` when the deflection came from an attack, else `accelerationPower x= 0.5`.
- Rendering distance: 64 x the box size x 4 (units of squared distance: `(size x 4 x 64)^2`; a NaN size counts as 4).

### 6.5 `ThrowableProjectile` (snowball, egg, ender pearl, potions, experience bottle)

- Gravity default 0.03 per tick (`getDefaultGravity`); potions 0.05; experience bottle 0.07 (21 section 8.13); air drag 0.99 (`getAirDrag`), water drag 0.8 (with 4 bubble particles at `position - velocity x 0.25`).
- **Tick order**: (1) on the first tick, bubble columns the projectile starts inside are applied (`handleFirstTickBubbleColumn`: the column's `onInsideBubbleColumn` for every bubble-column cell the box overlaps); (2) `applyGravity()` (`vy -= gravity`); (3) `applyInertia()` (velocity x drag); (4) the hit test `getHitResultOnMoveVector` (velocity read after steps 2 and 3); (5) `setPos(hit location or P + V)`; (6) `updateRotation()` (`lerpRotation(old, atan2(...) x 57.2958)` with factor 0.2); (7) `applyEffectsFromBlocks()`; (8) `Projectile.tick()`; (9) if the hit is not a miss and the projectile is alive: `hitTargetOrDeflectSelf`.
- `canUsePortal(true)`: thrown projectiles pass through portals. Rendering: not rendered within 3.5 blocks of the camera in its first ticks (`MIN_CAMERA_DISTANCE_SQUARED` 12.25).
- `ThrowableItemProjectile` holds the item in metadata 8 (copied with count 1) and spawns at `(x, eyeY - 0.1, z)` of the thrower with the thrower as owner.

### 6.6 Bubble columns for projectiles

`Projectile.onAboveBubbleColumn(down, pos)`: `vy += (down ? -0.03 : 0.1)` and bubble particles; `onInsideBubbleColumn(down)`: `vy += (down ? -0.03 : 0.06)` and the fall distance resets. (Arrows override both, read in `AbstractArrow`: while the arrow is in the ground each does nothing; otherwise each calls the base projectile version above, so the arrow values are exactly these: above a column `vy += -0.03` (down) or `+0.1` (up) plus bubble particles; inside a column `vy += -0.03` (down) or `+0.06` (up) plus the fall-distance reset.)

## 7. Arrows

This supplements 17 section 3.9 (damage formula, crit, tipped and spectral effects, pickup modes). Everything below was read in `AbstractArrow`, `Arrow` and `SpectralArrow`.

### 7.1 State and constants

| Item | Value |
|---|---|
| `ARROW_BASE_DAMAGE` | 2.0 (field `baseDamage`, saved `damage`) |
| Gravity (`getDefaultGravity`) | 0.05 |
| Drag | air 0.99 (`getAirDrag`, applied after the move when not in water); water 0.6 for `arrow`/`spectral_arrow` (`getWaterInertia`) and 0.99 for the trident; the water drag is applied **before** the move |
| `SHAKE_TIME` | 7 ticks (cosmetic wobble after sticking) |
| Despawn | `life` increments each tick while stuck and the arrow is discarded at **1200** |
| Metadata | 8 flags (bit 1 critical, bit 2 no physics), 9 pierce level (byte), 10 in ground; tipped arrow 11 effect colour (int, -1 for none) (21 Appendix A) |
| Saved fields | `life`, `shake`, `inGround`, `crit`, `pierce_level`, `damage`, the owner, the pickup mode, the stack, the weapon stack, `inGroundTime`, the in-ground block state, the sound event (read in `addAdditionalSaveData`; key names are in 07's NBT notes for entities, not repeated) |
| `isAttackable` | false; `isPickable` while it is not in the ground; `shouldBounceOnWorldBorder` true |

**Spawning**: constructed at `(x, eyeY - 0.1, z)` of the shooter (the shooter is the owner); the pickup stack is a copy of the ammo item; item components are applied (`applyComponentsFromItemStack`); an `intangible_projectile` component on the stack (17 component table) removes it and sets the pickup mode to `CREATIVE_ONLY`; if a weapon stack is given (it must be non-empty) it is copied into `firedFromWeapon` and the pierce level is set from `EnchantmentHelper.getPiercingCount` when it is positive (17 section 6.3, Piercing).

**`setBaseDamageFromMob(power)`** (skeletons and similar, 20 bow goal): `baseDamage = power x 2.0 + triangle(difficultyId x 0.11, 0.57425)` where `difficultyId` is peaceful 0, easy 1, normal 2, hard 3.

### 7.2 Tick (`AbstractArrow.tick`)

`physics = not noPhysics`.

1. **Embedded spawn check**: if the block at the arrow's block position is not air and `physics`, and its collision shape is not empty: for each box of the shape moved into the cell: if the box contains the arrow's position, the velocity becomes zero and `inGround = true`.
2. `shakeTime` decreases by 1 while > 0. If in water or rain: `clearFire`.
3. **In the ground and physics**: server: if the stored block state `lastState` differs from the current block state at the position and `shouldFall()` then `startFalling()`; else `tickDespawn()` (life + 1; discard at 1200). `inGroundTime += 1`. If alive, `applyEffectsFromBlocks()`. On the server the shared on-fire flag is synced to `remainingFireTicks > 0`. The tick ends here (no motion).
   - `shouldFall()` = in the ground and the box point at the position inflated by 0.06 has no collision (the block it was stuck in is gone).
   - `startFalling()`: `inGround = false`; `velocity x= (nextFloat x 0.2, nextFloat x 0.2, nextFloat x 0.2)` (independent draws, x then y then z); `life = 0`.
4. Not in the ground: `inGroundTime = 0`. If in water: `velocity x= waterInertia` and bubbles appear.
5. Particles (critical, bubbles) are cosmetic and omitted.
6. **Rotation** from the velocity: `yRot = atan2(vx, vz)` (or `atan2(-vx, -vz)` when `noPhysics`) and `xRot = atan2(vy, horizontalSpeed)` (degrees), each eased with `lerpRotation` (0.2 towards the target after unwrapping).
7. `checkLeftOwner()`.
8. **Movement**: if physics: `hit = clipIncludingBorder(P, P + V, COLLIDER, no fluid)`; `stepMoveAndHit(hit)` (7.3). Else `setPos(P + V)` and `applyEffectsFromBlocks()`.
9. If not in water: `velocity x= airDrag` (0.99).
10. If physics and not in the ground: `applyGravity()` (`vy -= 0.05`).
11. `Projectile.tick()`.

So the order for a flying arrow in air is: move (full velocity), then drag 0.99, then gravity 0.05.

### 7.3 `stepMoveAndHit` and hitting entities

Loop (restarts only for piercing arrows, see step 8):

1. If the arrow is not alive, stop.
2. `hits` = all entities along the segment from the current position to the block hit location (or the end of the move when there was no block hit), found by `getManyEntityHitResult` with the arrow's `canHitEntity` filter, in the box `arrow.box expandTowards velocity, inflated by 1`, with no margin (margin 0, inflate 0); sorted by squared distance from the position.
3. Take the first (nearest) hit, or none. The new position is the nearest entity hit location if there is one, else the block hit location (or the end of the move).
4. `setPos(newPosition)`; `applyEffectsFromBlocks(from, to)`; handle a portal the arrow passes (`handlePortal` when inside a portal this tick).
5. If `hits` is empty: if the arrow is alive and the block result is not a miss: `hitTargetOrDeflectSelf(blockHit)` (6.3; the arrow's `onHitBlock` runs, 7.5) and `needsSync = true`; stop.
6. Otherwise (entities hit), if alive and not `noPhysics`: `hitTargetsOrDeflectSelf(hits)`: for each hit in order: `hitTargetOrDeflectSelf(hit)` (6.3: a deflecting entity such as a breeze returns its deflection and the arrow turns; otherwise `onHitEntity` runs); stop iterating when the arrow is no longer alive or a deflection other than `NONE` happened. `needsSync = true`.
7. If the pierce level is 0 stop.
8. If the arrow pierces and the result was `NONE` (no deflection) loop again from step 1 with the position updated (the next entities along the line, excluding those already in the ignore set); a deflection ends the loop.

`canHitEntity(e)` for arrows (adds to the base rule of 6.1): a **player** target is not hit when the shooter is a player who may not harm that player (`canHarmPlayer`: team and pvp rules, 18); entities whose id is in the **ignore set** (`piercingIgnoreEntityIds`, a set that exists only for piercing arrows) are skipped.

**`onHitEntity(hit)`** (server side steps; numbered in order):

1. `speed = |velocity|` (blocks per tick, as a float). `base = baseDamage`; the damage source is `arrow(owner)` (the arrow's own source when ownerless). If the arrow has a weapon stack and the level is a server level: `base = EnchantmentHelper.modifyDamage(level, weapon, target, source, base)` (Power and the like, 17 section 6.3).
2. `damage = ceil(clamp(speed x base, 0, 2147483647))` as an int.
3. **Piercing** (`pierceLevel > 0`): lazily create the ignore set (capacity 5) and the "pierced and killed" list. If `ignoreSet.size < pierceLevel + 1` add the target's id; **otherwise discard the arrow and stop** (no damage). So a level-N arrow damages N + 1 entities and is discarded by the following hit attempt.
4. **Critical**: if the arrow is critical: `damage = min(damage + nextInt(damage / 2 + 2), 2147483647)` (integer division, `RandomSource.nextInt(bound)`, exclusive bound; added as a long and capped).
5. If the shooter is a living entity: its `lastHurtMob` = the target. Remember the target's `remainingFireTicks`. If the arrow is on fire: `target.igniteForSeconds(5)` (only if not fire immune: `igniteForSeconds` applies that rule).
6. `target.hurtOrSimulate(source, damage)`.
7. **If the hurt succeeded and the target is a `LivingEntity`**: on the server, for non-piercing arrows (pierce level 0), the target's stuck-arrow count (`arrowCount`, shown as arrows in the model) increases by 1; `doKnockback(target, source)` (7.4); on the server the post-attack enchantment effects run (`doPostAttackEffectsWithItemSource`); `doPostHurtEffects(target)` (tipped: the potion effects with the arrow's duration scale and the arrow as the effect source; spectral: Glowing, 17 section 3.9); if the target is a `Player` and the shooter is a `ServerPlayer` that is not the target and the arrow is not silent: send the shooter Game Event `play_arrow_hit_sound` (0x27, value 0.0, 05b). If the target died and the arrow pierces, add it to the "pierced and killed" list. On the server, if the shooter is a `ServerPlayer`: the `killed_by_arrow` criterion triggers with the list of killed entities and the weapon (for a piercing arrow with a list; for a plain arrow with the target when it is no longer alive).
8. Play the arrow's hit sound (`entity.arrow.hit` by default, the trident sets its own) at volume 1.0, pitch `1.2 / (nextFloat x 0.2 + 0.9)`. If the arrow does not pierce (`pierceLevel <= 0`): discard it.
9. **If the hurt failed** (shield, invulnerability, immune entity): if the target `projectileReceivesSideEffectsOnHit(false)`: restore its previous `remainingFireTicks`; deflect the arrow with `REVERSE` and s = 0.2 (`deflect(REVERSE, target, owner, false, 0.2)`, so the arrow flies back at about 10 percent of its speed and turns around); on the server, if the arrow's velocity squared is below 1e-7 (it has nearly stopped): when the pickup mode is `ALLOWED` drop the pickup item at the arrow's position with an offset of 0.1, then discard the arrow.

### 7.4 Knockback (`doKnockback`)

`k` = the weapon's knockback: `EnchantmentHelper.modifyKnockback(level, weapon, target, source, 0)` when the arrow has a weapon stack on a server level (Punch adds per level, 17 section 6.3), else 0. If `k > 0`: `resist = max(0, 1 - target.knockback_resistance)`; `dir = normalize(velocity x (1, 0, 1)) x k x 0.6 x resist`; if `dir.lengthSqr > 0`: `target.push(dir.x, 0.1, dir.z)` (an impulse added to the target's velocity: x and z from `dir`, **y + 0.1**). With no Punch no extra knockback is applied by the arrow itself (the normal hurt knockback of `LivingEntity.hurtServer`, 18 section 7, already applied when the damage landed).

### 7.5 Hitting a block and bubble columns

`onHitBlock(hit)`:

1. `lastState = the block state at the hit`; the base `onHitBlock` (the block's `onProjectileHit`).
2. On the server, if the arrow has a weapon: enchantment on-hit-block effects with the position clamped inside the block and the shooter (17 section 6.3).
3. `step = signum(velocity)` (each component -1, 0 or 1) scaled by 0.05; `position -= step` (the arrow is pulled back 0.05 along its direction so it does not sit inside the block).
4. `velocity = 0`.
5. Sound: the arrow's hit-ground sound (`entity.arrow.hit` by default; the trident has `item.trident.hit_ground`), volume 1.0, pitch `1.2 / (nextFloat x 0.2 + 0.9)`.
6. `inGround = true`; `shakeTime = 7`; `crit = false`; `pierceLevel = 0`; the sound event is reset to `entity.arrow.hit`; the ignore set and the pierced list are cleared.

`onAboveBubbleColumn(down, pos)` / `onInsideBubbleColumn(down)` on an arrow do nothing while it is in the ground and otherwise use the base projectile values of 6.6 (read). `isPushedByFluid` is true only while not in the ground. `move(...)`: any move that is not the arrow's own (`MoverType.SELF`) and leaves it in the air above no collision calls `startFalling` (for example a piston moving the block it is stuck in).

### 7.6 Pickup (`playerTouch`, `tryPickup`)

Server only. The arrow can be picked up when it is in the ground or `noPhysics`, and `shakeTime <= 0`. Then `tryPickup(player)`: mode `DISALLOWED`: false; `ALLOWED`: `player.getInventory().add(copy of pickup stack)` (true when the whole stack fits); `CREATIVE_ONLY`: true only if the player has infinite materials. On success: `player.take(arrow, 1)` (Take Item Entity animation, 05b 0x7F) and the arrow is discarded. **Mode assignment** (read this round): the arrow constructor sets `DISALLOWED`; an `intangible_projectile` component on the stack sets `CREATIVE_ONLY` (7.1). `setOwner` then chooses by owner type: a `Player` owner while the mode is still `DISALLOWED` gives `ALLOWED`; an `OminousItemSpawner` owner gives `DISALLOWED`; any other owner, and any mode that is already not `DISALLOWED` (for example `CREATIVE_ONLY`), keeps the current mode. The weapon items' projectile creation (`ArrowItem.createArrow`, bow, crossbow) does not touch the mode. Only the dispenser path (`asProjectile` of `ArrowItem`, `SpectralArrowItem`, `TridentItem`) sets `ALLOWED` explicitly; `TridentItem.releaseUsing` sets `CREATIVE_ONLY` after spawning when the thrower has infinite materials (a survival thrower gets `ALLOWED` from `setOwner`). Mob-owned arrows therefore stay `DISALLOWED`.

### 7.7 Tipped and spectral arrows

- **Tipped** (`Arrow`): the potion contents (component `potion_contents`) set the metadata colour (`getColor` of the contents, or -1 when empty); a client particle (colour = the potion colour) is emitted every tick while flying (2 particles) and every 5 ticks while in the ground (1). When the tipped arrow has been in the ground for **600 ticks** (`EXPOSED_POTION_DECAY_TIME`) and its contents are not empty, it loses the potion: Entity Event 0 (a puff of particles) is broadcast and the pickup stack becomes a plain `arrow` item (the entity then behaves as a plain arrow, no effects). `doPostHurtEffects` applies each effect of the contents with the arrow's `potion_duration_scale` component (0.125 for a tipped arrow item, 17 section 3.9; the effect source is the arrow's effect source).
- **Spectral**: Glowing for `duration` ticks, default **200** (`DEFAULT_DURATION`), saved as `Duration`.

## 8. Wind charges

Classes `AbstractWindCharge` (base), `WindCharge` (player item and dispenser), `BreezeWindCharge`. Both are `AbstractHurtingProjectile` with `accelerationPower = 0` and inertia **1.0** in air and water (no drag, no gravity: they fly straight at constant speed; 17 section 3.15 gives the player speed 1.5 and the dispense speed). They do not burn (`shouldBurn` false) and have no trail particle.

| Item | `WindCharge` | `BreezeWindCharge` |
|---|---|---|
| Radius | 1.2 | 3.0 |
| Knockback multiplier of the explosion calculator | 1.22 | none (default) |
| Spawn | at `(x, eyeY - 0.1, z)`-style position given by the thrower code, player item (17), or the dispenser (21) | `(breeze x, breeze.getFiringYPosition(), breeze z)` with the breeze as owner (20) |
| Explosion burst sound | `wind_charge.wind_burst` | `breeze_wind_charge.wind_burst` |
| No-deflect window | `noDeflectTicks = 5` after creation: `deflect` is refused while it is above 0; it decrements each tick | none |

- **Bounding box** (`makeBoundingBox`): the type size is 0.3125 x 0.3125; the box is centred horizontally (half width 0.15625) and its **bottom is 0.15 below the entity position** (`y - 0.15 .. y - 0.15 + 0.3125`), not centred on the position.
- **Collisions**: wind charges never collide with other wind charges (`canCollideWith`, `canHitEntity` return false for `AbstractWindCharge`), and never hit an end crystal (`canHitEntity` false for `end_crystal`); otherwise the hurting-projectile rule (target must be pickable and have physics).
- **Tick**: on the server, a wind charge whose block y is above `level.maxY + 30` explodes at its position and is discarded; otherwise the normal tick of 6.4 runs (and `WindCharge` decrements `noDeflectTicks`).
- **Entity hit**: server only. If the owner is a living entity, `owner.lastHurtMob = target`. `target.hurtServer(windCharge(source = this, owner) damage source, 1.0)`; if the hurt landed and the target is living: post-attack enchantment effects. Then **in every case** `explode(this.position)`. The generic `onHit` then discards the projectile (server).
- **Block hit**: server only. `explode(hitLocation + faceNormal x 0.25)` where `faceNormal` is the unit vector of the face that was hit (so the burst is centred 0.25 outside the face), then discard.
- **`explode(centre)`**: `Level.explode(source entity = the charge itself (`this`), explicit damage source = none (null), the shared damage calculator, x, y, z, radius, fire = false, interaction TRIGGER, small particle `gust_emitter_small`, large particle `gust_emitter_large`, weighted sound list empty, the burst sound)`. The calculator (`SimpleExplosionDamageCalculator(destroyBlocks true, damageEntities false, knockbackMultiplier (1.22 for the player charge, none for the breeze), immune blocks = block tag `blocks_wind_charge_explosions`)`) means: no entity damage from the explosion itself, entity knockback only, blocks are only triggered (doors, buttons, levers, trapdoors, candles and the like react) and never destroyed; tag members are immune to the trigger. The explosion engine (rays, knockback arithmetic) is specified with 20 section 12 and later rounds; this document gives only the parameters.
- **Redirection**: wind charges are in `redirectable_projectile` (pickable by attack: a player attack on the charge redirects it, `AIM_DEFLECT` in the attacker's look direction with the attacker as the new owner) and in `impact_projectiles`. A charge flying into another **redirectable** projectile (fireball) calls `onRedirectProjectile` on it.
- `push(x, y, z)` is ignored (the charge cannot be pushed by fluids or explosions). It has no item (`getItem` returns the empty stack).

## 9. Fireballs and skulls: motion model

Per-mob launch and impact rules are in 21; this section supplies the common motion from 6.4 and the numbers not given there.

| Projectile | Class | Constants read here |
|---|---|---|
| Large fireball (`fireball`) | `LargeFireball` | field `explosionPower` (byte, saved `ExplosionPower`, default **1**); entity hit: `fireball(source, owner)` damage **6.0** then post-attack effects; on any hit (entity or block) on the server: `Level.explode(x, y, z, radius = explosionPower, fire = mob_griefing, interaction MOB)` then discard (the game rule `mob_griefing` gives both the fire flag and block destruction) |
| Small fireball | `SmallFireball` | entity hit 5.0 fire damage after igniting for 5 s (21 section 5.2); not detailed here |
| Dragon fireball | `DragonFireball` | splash range 4.0, box (4, 2, 4), cloud parameters in 21 section 6 (the area effect cloud itself is part 9) |
| Wither skull | `WitherSkull` | metadata 8 dangerous; block explosion resistance (`getBlockExplosionResistance`): when the skull is dangerous and `WitherBoss.canDestroy(state)` is true, `min(0.8, base resistance)`, otherwise the base resistance; inertia 0.73 when dangerous, **0.95** otherwise (section 1, item 4); entity hit with a living owner: 8.0 `wither_skull` damage, and if the target survives post-attack effects, else the owner heals 5.0; without a living owner: 5.0 `magic`; on a hit that damaged a living target: Wither effect `20 x seconds` ticks with seconds 10 on Normal and 40 on Hard (none on Easy and Peaceful), amplifier 1 (`MobEffectInstance(wither, 20 x seconds, 1)`: the third argument, 1, is the amplifier, so Wither II, as 21 section 7.2 states); on any hit: server explosion radius 1.0, no fire, interaction MOB, then discard |
| Wind charges | section 8 | |

`Fireball` items (`fireball`, `small_fireball`) hold their stack in metadata 8 for rendering (default `fire_charge`, saved `Item`).

**Velocity series of a default fireball** (accelerationPower 0.1): launched with speed 0.1; per tick `v' = (v + 0.1) x 0.95`: 0.19, 0.2755, 0.356725, 0.4388..., approaching 1.9 (worked example 12.6).

## 10. Thrown items

Common physics: 6.5. Item-specific rules are in 17 section 3.15 (impacts, damage, cooldowns) and 21 sections 8.13; the residual read here:

- **Ender pearl** (`ThrownEnderpearl`): while the owner is an offline-dead player: each server tick it looks up its owner by UUID including a dead player (`findOwnerIncludingDeadPlayer`); if the owner is a `ServerPlayer` that is not alive, has not `wonGame`, and the game rule `ender_pearls_vanish_on_death` is true, the pearl is discarded instead of ticking. The pearl keeps its chunk loaded for the owner: a `ticketTimer` counts down; when it is not positive or the pearl entered another chunk (section coordinates change), the owner's `registerAndUpdateEnderPearlTicket()` refreshes the chunk ticket (the ticket mechanics are the chunk engine's). The pearl is registered with and deregistered from the owner's pearl list when its owner changes or it is removed (except removal with reason `UNLOADED_WITH_PLAYER`). `canTeleport(from, to)`: a pearl may not carry its owner from the End to the Overworld through the End portal unless the owner has `seenCredits` (the base dimension check also applies). `onInsideBlock`: an `END_GATEWAY` block calls the owner's `onInsideBlock` (the pearl travels through a gateway: gateway logic is part of the End, 21 section 6). Landing teleport rules: 17 section 3.15.
- **Lingering potion** (`ThrownLingeringPotion.onHitAsPotion`): creates an `AreaEffectCloud` at the **hit entity's position** when it hit an entity and at the projectile's position otherwise; owner = the thrower when it is a living entity; **radius 3.0, `radiusOnUse` -0.5, duration 600, wait time 10, `radiusPerTick = -radius / duration = -0.005`**, components copied from the potion stack (the potion contents determine the cloud's effects and colour); the cloud is added to the level. The cloud's tick loop (application, shrinking, fusing) is part 9.
- **Thrown trident** (`ThrownTrident`, read): an arrow subclass; metadata loyalty (byte, 0 to 127, from the stack's return-to-owner enchantment effect, clamped) and foil; saved `DealtDamage` (default false). Base hit damage **8.0**, modified by the weapon's damage enchantment effects, damage source `trident(trident, owner)`. Water drag 0.99. Despawn: the generic arrow despawn only when the pickup mode is `ALLOWED` and loyalty <= 0. `findHitEntity` returns nothing once `dealtDamage` is true.
  - `onHitEntity`: set `dealtDamage`; hurt the target; if the hurt landed: on the server the post-attack effects (an enchantment effect may kill the trident), and for a living target `doKnockback` and `doPostHurtEffects` (7.3 step 7 rules); if the target receives projectile side effects: play `trident hit` (volume 1.0, pitch 1.0) and deflect with `REVERSE`, owner kept, vector `(0.02, 0.2, 0.02)`. The trident is **not** discarded by a hit.
  - `tick`: `dealtDamage` becomes true once `inGroundTime > 4`. If loyalty > 0 and (`dealtDamage` or no-physics) and an owner exists: if the owner is not acceptable (dead, or a spectating server player): on the server, with pickup `ALLOWED`, drop the pickup item at the trident (offset 0.1), then discard; otherwise: if the owner is **not** a player and the trident is within `owner.width + 1` of the owner's eye, discard; else set no-physics; with `d` = owner eye position minus trident position: `y += d.y x 0.015 x loyalty` (x and z unchanged), and `velocity = 0.95 x velocity + normalize(d) x 0.05 x loyalty`; the return sound plays (volume 10.0) on its first returning tick. Then the arrow tick runs.
  - Pickup: `tryPickup` = the arrow rule, or (no-physics and owned by that player and inventory accepts the pickup item). `playerTouch` only acts for the owner or an ownerless trident.
- **Splash potions and bottles**: gravity 0.05; the effect application arithmetic is in 17 section 3.15.
- **Experience bottle**: gravity 0.07 (21 section 8.13).

## 11. Mob ranged attacks

Which document specifies each `performRangedAttack` (all read in previous rounds; this table closes 18 Open question 12 by pointing to the numbers):

| Shooter | Projectile | Specified in | Launch parameters there |
|---|---|---|---|
| Skeleton, stray, bogged, parched (bow) | arrow (`getMobArrow`: held ammo or a plain arrow; stray adds Slowness, bogged Poison, parched its effect) | 20 bow goal and shot; base damage rule 7.1 here | aim and speed in 20; damage `power x 2 + triangle(difficulty x 0.11, 0.57425)` (7.1) |
| Pillager, piglin, illusioner with crossbow | arrow or firework rocket | 20 (crossbow goals), 18 section 4.5 `RangedCrossbowAttackGoal`, 17 section 3.9 | speed 1.6 / 3.15 as read there |
| Drowned (trident) | `ThrownTrident` | 20 drowned section | speed 1.6, inaccuracy from `rangedAttackUncertainty` |
| Snow golem | `Snowball` | 19 snow golem section | speed 1.6, arc term `sqrt(dx^2+dz^2) x 0.2` |
| Witch | splash potion | 20 witch section | aim at the target plus its velocity |
| Llama, trader llama | `LlamaSpit` | 19 llama row, 21 section 8.14 | velocity 1.5; spit gravity 0.06 |
| Ghast | `LargeFireball` | 21 section 5.1, 9 here | `explosionPower`, start speed 0.1 |
| Blaze | `SmallFireball` x3 | 21 section 5.2 | |
| Wither | `WitherSkull` | 21 section 7.2 | |
| Ender dragon | `DragonFireball` | 21 section 6 | |
| Breeze | `BreezeWindCharge` | 20 breeze section, section 8 here | |
| Shulker | `ShulkerBullet` | 21 section 6.2 | speed 0.15, homing |
| Evoker | evoker fangs (not a projectile entity of this round) | 20 | |
| Player items | arrows, trident, pearl, snowball, egg, potions, xp bottle, wind charge, fishing hook, firework | 17 sections 3.9 to 3.15 | |

The shared helper of all mob shots (`Projectile.spawnProjectileUsingShoot` with `shoot(dx, dy, dz, power, uncertainty)`) is 6.1 here; where a shot reads "speed 1.6" it means `power` in 6.1 (the velocity is `(normalised direction + triangle noise) x power`). The `rangedAttackUncertainty` field used as the `uncertainty` argument is a mob field read in 19 and 20 as cited in the table; its value was not re-read in this round.

## 12. Worked examples

### 12.1 Boat in still water: where it floats and how fast it can go

Boat 1.375 x 0.5625 sitting in `IN_WATER` with waterline `waterLevel - y = 0.28125` (half the height): `buoyancy = 0.28125 / 0.5625 = 0.5`. Start `vy = 0`: step 3: `vy = 0 + (-0.04) = -0.04`; step 4: `vy = (-0.04 + 0.5 x 0.0615385) x 0.75 = (-0.04 + 0.0307692) x 0.75 = -0.0069231`. The boat sinks until `buoyancy = 0.65`, because then `vy = 0` is a fixed point: `(-0.04 + 0.65 x 0.0615385) x 0.75 = 0`. That is a waterline of `0.65 x 0.5625 = 0.365625` above the boat origin.

Steering forward on the water: per tick the order is `floatBoat` (velocity x 0.9) then `controlBoat` (adds 0.04 along the heading) then `move`. `v' = 0.9 v + 0.04`, fixed point `0.04 / 0.1 = 0.4` blocks per tick = 8 blocks per second. After 10 ticks from rest: `v10 = 0.4 x (1 - 0.9^10) = 0.4 x 0.6513 = 0.2605`.
Turning (right held only): `f = 0.005`; `deltaRotation` goes 0.9 x d + 1 each tick (`floatBoat` first multiplies `deltaRotation` by the drag, 0.9 in water): fixed point 10 degrees per tick (200 degrees per second).
Heading yaw 90 degrees: `(sin(-90 deg) x f, 0, cos(90 deg) x f) = (-0.04, 0, ~0)`: the boat moves towards -x for yaw 90 (west), consistent with Minecraft's yaw convention 18.

### 12.2 Old behaviour minecart on level track

Empty cart on an `east_west` rail at block (10, 64, 10), position (10.5, 64.0625, 10.5), velocity (0.4, 0, 0), no powered rail.
- Step 4: no slope. Step 5: `first = W (-1,0,0)`, `second = E (1,0,0)`: `(dx, dz) = (2, 0)`, `len = 2`, `dot = 0.8 > 0` (no flip), `speed = min(2, 0.4) = 0.4`, `v = (0.4, 0, 0)`.
- Step 8: `p1 = (10, 10.5)`, `p2 = (11, 10.5)`, `ez = 0`, so `t = px - blockX = 0.5`: `px = 10 + 1 x 0.5 = 10.5`.
- Step 9: `f = 1`, move by `(clamp(0.4, -0.4, 0.4), 0, 0)`: the cart is at x = 10.9.
- Step 11: slowdown 0.96: `v = (0.384, 0, 0)`. Step 12: flat rail, `dy = 0`. Step 13: the cart is still in block 10. Stored speeds on later ticks: 0.36864, 0.35389...
With a rider the factor is 0.997 and the move uses `f = 0.75`: the cart moves 0.75 x 0.4 = 0.3 per tick while the stored speed is 0.3988.

### 12.3 Slope

An empty cart at rest on an `ascending_east` rail (high end east): step 4 gives `vx = -0.0078125` and `y = blockY + 1`; step 5: `first = W below (-1,-1,0)`, `second = E (1,0,0)`: `(dx, dz) = (2, 0)`, `dot = -0.0156 < 0` so `(dx, dz) = (-2, 0)`; `v = (-0.0078125, 0, 0)`: the cart rolls west (downhill) and keeps accelerating by 0.0078125 per tick (minus the 0.96 factor): fixed point `v = 0.96 (v + 0.0078125)`: `v = 0.1875` blocks per tick at most on a long slope.

### 12.4 Powered rail

Empty cart moving at stored speed 0.384 on a powered `powered_rail`: slowdown 0.96 gives 0.36864; step 14 adds 0.06: 0.42864. Next tick: the move is clamped to 0.4 (`m`), the stored speed is 0.42864, slowdown 0.41149, boost 0.47149, ... the stored speed converges to `0.06 / (1 - 0.96) = 1.5` while the cart moves 0.4 per tick; the align step (step 5) caps the stored speed at 2.0. A cart reaching an unpowered powered rail (`brake`): speed 1.5 becomes 0.75, 0.375, ... each tick (x 0.5) and stops below 0.03.
A cart stopped on a powered, powered-on `east_west` rail with a solid block to its west gets `vx = 0.02` and starts moving east.

### 12.5 Arrow piercing and knockback

A level-2 piercing crossbow arrow (speed 3.15 is the launch speed; the example assumes every hit on the first tick, since the speed falls by a factor of 0.99 per tick in air (7.2 step 9), for example about 3.0 after 5 ticks, which would give `ceil(3.0 x 2.0) = 6`; base 2.0, crit) flies along a line through three zombies A, B, C and then reaches D in one flight. Per entity: `damage = ceil(3.15 x 2.0) = ceil(6.3) = 7`, crit adds `nextInt(7 / 2 + 2) = nextInt(5)` (0 to 4): 7 to 11. Hit A: ignore set size 0 < 3 add (size 1), damage; B: 1 < 3 add (2), damage; C: 2 < 3 add (3), damage; the arrow still lives (pierce > 0); D: size 3 >= 3: the arrow is **discarded with no damage**. With Punch giving `k = 1.0` (17 section 6.3 for the level mapping) against a zombie with knockback resistance 0 moving the arrow along +x: `dir = (1, 0, 0) x 1.0 x 0.6 x 1 = (0.6, 0, 0)`; `push(0.6, 0.1, 0)`. Against resistance 0.5: `dir = 0.3`, `push(0.3, 0.1, 0)`.
A shield-blocked arrow: speed 3.0 becomes (reverse 0.2 vector `(-0.1 x ...)`): `velocity x (-0.1, -0.1, -0.1)`: 0.3 per tick, rotated 170 to 190 degrees; it continues to fly (falls) unless its speed squared is below 1e-7.

### 12.6 Ghast fireball

Direction 1,0,0; `accelerationPower 0.1`. Velocity after ticks (applyInertia first, then the hit test uses the new velocity): tick 1: `(0.1 + 0.1) x 0.95 = 0.19`; tick 2: `(0.19 + 0.1) x 0.95 = 0.2755`; tick 3: `(0.2755 + 0.1) x 0.95 = 0.356725`; tick 4: 0.43489; tick 5: 0.50815; limit 1.9. Position after tick 3 relative to the launch point: 0.19 + 0.2755 + 0.356725 = 0.822 blocks.
In water: inertia 0.8: `v' = (v + 0.1) x 0.8`: limit 0.4.

### 12.7 Wind charge

Fired at speed 1.5 straight east from (0, 65, 0): constant velocity (1.5, 0, 0) (inertia 1, power 0), 10 ticks later at x = 15 (the first tick `applyInertia`: `(1.5, 0, 0) + normalize x 0 = 1.5`). Hitting the top face of a block at (15.3, 64, 3.2): the burst centre is `(15.3, 64.25, 3.2)`, radius 1.2, TRIGGER interaction. A cow in the burst takes knockback only (the 1.0 damage of a direct hit applies only when the charge hits the entity).

### 12.8 Camel seat

Adult camel, height of its standing dimensions 2.375, one passenger, not sitting, no transition: `h = 2.375 - 0.375 = 2.0`; `z = 0.5 x 1.0`; seat `(0, 2.0, 0.5)` rotated by -yaw. Two passengers: the first at z = 0.5, the second at z = -0.7, and an Animal in either seat adds 0.2 (0.7 and -0.5). Sitting (not in transition): `y = h' + 0.2` where `h'` uses the sitting dimensions. Baby camel (scale 0.6): `h = height - 0.09375`, `z` scaled by 0.6.

## 13. Validation

Checks an implementation can run against the text above.

| # | Check | Expected |
|---|---|---|
| V1 | Boat in `IN_WATER` with `buoyancy = 0.65` and `vy = 0` | `vy` stays 0 after one tick (12.1) |
| V2 | Boat held forward in water from rest, 1 tick | speed 0.04 along the heading; 100 ticks: 0.4 within 1e-4 |
| V3 | Boat `UNDER_WATER` for 60 ticks | passengers ejected at the 60th tick |
| V4 | Boat hurt with amounts summing to 4.1 (damage > 40) | destroyed; at 4.0 exactly not (`damage > 40` is strict) |
| V5 | Two passengers on a boat (a player first, a cow second) | seat z offsets 0.2 and -0.6 + 0.2 = -0.4 |
| V6 | Old minecart on a flat rail at stored speed 0.4, empty | position advances 0.4 per tick, stored speed x 0.96 per tick |
| V7 | Same with a rider | movement is 0.75 x the stored speed, stored x 0.997 |
| V8 | Cart at rest on `ascending_east` | `vx = -0.0078125` after the first tick's pull |
| V9 | Cart on a powered, unpowered powered rail at speed 0.5 | x 0.5 per tick, zero below 0.03 |
| V10 | Furnace minecart given fuel at 31000 ticks | not accepted (31000 + 3600 > 32000), item kept |
| V11 | TNT minecart falling 4 blocks | `explode(source, (4 / 10)^2)`; radius `4.0 + nextDouble x 1.5 x 0.4` |
| V12 | Piercing level 1 arrow through three mobs | damages the first two, discarded by the third hit attempt |
| V13 | Arrow knockback with `k = 1`, resistance 0 | `push(0.6 nx, 0.1, 0.6 nz)` |
| V14 | Fireball launched from rest with default power | velocities 0.19, 0.2755, 0.356725 over the first 3 ticks |
| V15 | Wind charge hits top face of a block | burst 0.25 above the hit point; the block is not destroyed |
| V16 | Lingering potion hit on a block | cloud radius 3.0, duration 600, wait 10, radius per tick -0.005 |
| V17 | Arrow stuck for 1200 ticks | discarded |
| V18 | Camel seat of a single adult passenger, standing | `(0, 2.0, 0.5)` before the yaw rotation |

## 14. Open questions

1. **`NewMinecartBehavior`**: `stepAlongTrack` is described in 4.5 and the factor `Mth.SQRT_OF_TWO` is read there for slope exits; the interpolation (`lerpSteps`, `getCurrentLerpStep`, `adjustToRails`) and client rotation lerps were not expanded. It only runs when the experimental pack is enabled.
2. Closed: `DismountHelper` read (offsets, `isBlockFloorValid`, `canDismountTo`, `findCeilingFrom`; 4.6). The block-floor-height query of the world (`getBlockFloorHeight`) was not read.
3. **`Entity.move` collision, `EntitySelector.pushableBy`, `Entity.push`** and the server's move-vehicle validation belong to the entity framework and packet documents.
4. **Boat bubble-column triggers**: the block side (`BubbleColumnBlock` calling `onAboveBubbleColumn`) is block behaviour.
5. Closed: `Entity.getGravity()` read (3.1).
6. Closed: arrow bubble-column behaviour read (6.6, 7.5).
7. Closed: arrow pickup mode per shooter read (7.6).
8. Closed: effect constructor arguments (section 9).
9. Closed: the hopper pull and insert rules and the container comparator signal were read (4.6). Not read: the hopper block's own tick, cooldown and push logic, and the rounding of `Mth.lerpDiscrete` (signal values between 0 and 15 are inferred).
10. **Chest vehicle containers**: `interactWithContainerVehicle`, loot generation on first open, `chestVehicleDestroyed` details and `isChestVehicleStillValid` were read only as call names (searched: `AbstractChestBoat`, `AbstractMinecartContainer`). The menu layout is GAP-19.
11. **Dispensers**: `BoatDispenseItemBehavior`, the minecart dispenser behaviour and rail-placement checks of the dispenser were not read (the item `use` paths are read, 3.10). Arrow dispensing sets pickup `ALLOWED` (7.6), other dispenser projectile behaviour is not read.
12. **Spawner minecart**: the `BaseSpawner` logic is the spawner block's and was not read.
13. Closed: up to 3 camel riders (section 5).
14. Closed in part: camel pose clock, travel and seat are read (section 5). Not read: the base `AbstractHorse.travel` and `tickRidden` that the camel calls, and `CamelAi`.
15. **`Entity.deflection` overrides**: only the base rule and the breeze's were read (searched: `ProjectileDeflection` references in the projectile package); other overrides were not enumerated.
16. **Not re-read in this round**: `FishingHook`, `FireworkRocketEntity`, `ShulkerBullet`, `LlamaSpit`, `Snowball`, `ThrownEgg`, `AbstractThrownPotion.onHit`, `ThrownSplashPotion` (the classes exist in the jar; their numbers are those of 17 and 21 and are assumed correct). `ThrownTrident` was read (section 10).
17. **`ServerboundPaddleBoat` handling and the player-input to `setInput` mapping** are in 05c and 13; not re-read.
18. **Vehicle interpolation handlers** (`createInterpolationHandler` of boats and minecarts) were not read; 18 section 6 covers tracking in general.
19. **Explosion engine parameters** for `TRIGGER` and `TNT` interactions and the `SimpleExplosionDamageCalculator` boolean meanings are inferred from the argument order `(true, false, knockbackMultiplier, immuneBlocks)`; the engine is in 20 section 12 and later rounds.
20. Closed: armor stand, item frame, painting, display entities, interaction and marker, and the area effect cloud loop are covered by the part-9 file `44-residual-mob-questions-9-end-bosses-decorations.md` (its header Covers row confirmed by reading it).
