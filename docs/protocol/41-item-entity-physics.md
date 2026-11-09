# 41. Item entity physics, drops and pickup

| | |
|---|---|
| Covers | The item entity (`ItemEntity`): spawning from block drops, entity drops, player throws, inventory death drops and dispensers; the per-tick physics (gravity, drag, friction, fluids, fire); merging; pickup by players (delay, owner, box, inventory transfer, creative, stats); the Take Item Entity packet and the client side of it; despawn, lifetime, damage and explosion rules; persistence. Extends 21 section 8.1 (which stays valid; this document adds what 21 says "was not read"). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `ItemEntity`, `Entity` (gravity, drag, fluid interaction, fire, supporting block), `EntityFluidInteraction`, `LivingEntity` (`createItemStackToDrop`, `drop`, `take`, `onItemPickup`), `Player` (`aiStep`, `touch`), `ServerPlayer` (`drop`, `take`, `onItemPickup`), `Inventory`, `Container`, `Block` (`popResource`, `popResourceFromFace`, `dropResources`, `popExperience`), `DefaultDispenseItemBehavior`, `ItemStack.canBeHurtBy`, `DamageResistant`, `EntityTypes` (item registration), `Blocks` (friction, bounce restitution), `Items` (`fireResistant`, nether star), `Item$Properties.fireResistant`, `BlockSource`, `DispenserBlock.getDispensePosition`, `AABB.intersects`, `ServerGamePacketListenerImpl` (`handlePlayerAction`, `handleSetCreativeModeSlot`, `dropSpamThrottler`), `TickThrottler`, `ClientPacketListener.handleTakeItemEntity`, `ItemPickupParticle`, `ItemEntityRenderer`, `LavaFluid`, `InsideBlockEffectType`; data files `data/minecraft/tags/damage_type/{is_fire,is_explosion,is_fall,bypasses_invulnerability}.json`. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001, design README Parts 0, 1, 4; GAP-26). Loot tables and block-to-item tables are data (extracted by the tool) and are not tabulated; this document is the engine that turns a rolled stack into an entity and a pickup. The stand-in rules `standin-content.md` section 9 (S50: delay 6 or 30, drag 0.97, gravity 0.035, no merge, lifetime 4800, pickup box +0.75/+0.25, pickup is "tried in entering order") are superseded by this document for both world types. |

Conventions: "tick" is one server tick (20 per second). Vectors are (x, y, z) with y up. `f32` marks a value that the artifact computes in single precision (multiply and add in float, widen to double when stored); a reimplementation in doubles differs only in the last digits. Names in backticks say where a fact was read.

## 1. The entity

Registration (`EntityTypes.ITEM`, also 21 section 8.1): category MISC, bounding box 0.25 wide and 0.25 high, eye height 0.2125, `clientTrackingRange` 6, update interval 20 ticks, no loot table. Synced metadata: `ItemEntity.defineSynchedData` defines exactly one entry, `DATA_ITEM` (serializer ITEM_STACK, default empty stack). Its index is **8** (inferred: the base `Entity` defines eight entries, read as eight `define` calls, so the first subclass entry follows them; the index number itself was not read; 21 section 8.1 states "Metadata 8" without a mark and the two documents agree). Add Entity (05a 0x01) carries the initial velocity.

Other `ItemEntity` facts (all read): `getSoundSource` is AMBIENT; `getMovementEmission` is NONE (the entity's own movement produces no step, swim or splash movement events); `getSlot(0)` exposes the stack as a slot (get and set the stack, used by item-replace style access; any other index falls through to the base entity); `getName` is the custom name when set, else the stack's item name; `isAttackable` is false.

Fields and constants (all read in `ItemEntity`):

| Field | Meaning | Default | Persisted (NBT key) |
|---|---|---|---|
| `age` | ticks lived; values -32768 (never ages) and below 0 (extended) are special | 0 | `Age` (short) |
| `pickupDelay` | ticks until pickup; 32767 = never | 0 (a plain constructed entity has delay 0) | `PickupDelay` (short) |
| `health` | hit points, 5 | 5 | `Health` (short) |
| `thrower` | entity reference of the thrower | none | `Thrower` (entity reference) |
| `target` | UUID of the only player allowed to pick it up ("owner") | none | `Owner` (UUID, omitted when none) |
| `bobOffs` | random phase for the visual bob, `nextFloat() * pi * 2` (f32) | set at construction | not saved |
| item stack | the stack | empty | `Item` (item stack codec, omitted when empty) |

Constants: `LIFETIME` 6000, `INFINITE_PICKUP_DELAY` 32767, `INFINITE_LIFETIME` -32768, `DEFAULT_HEALTH` 5, `FLOAT_HEIGHT` 0.1 (visual), `EYE_HEIGHT` 0.2125. Saved shorts are read back with defaults health 5, age 0, delay 0. After loading, an empty stack discards the entity. Note the stand-in claim "pickup delay not saved" (S50 9.4) is wrong for the standard: it is saved.

Construction (every variant): the base entity gives a random yaw `nextFloat() * 360` (preceded by drawing `bobOffs`, both from the item entity's own random source); the constructors then are:

- `(level, x, y, z, stack)`: position, stack, and a **random motion** `(nextDouble() * 0.2 - 0.1, 0.2, nextDouble() * 0.2 - 0.1)` (x draw first, then z).
- `(level, x, y, z, stack, vx, vy, vz)`: position, stack, explicit motion, no random draws for the motion.

Owner, transfer and vibration entries (all read in `ItemEntity`):

- `getOwner` resolves the `thrower` entity reference through the level (it returns the live entity or nothing). The advancement triggers of 4.2 step 5 use this owner, not the `target` field.
- `restoreFrom(old)` (entity transfer, for example through a portal): the base `Entity.restoreFrom` saves the old entity to its persisted form (the NBT keys of the table above: `Age`, `PickupDelay`, `Health`, `Owner`, `Item`, `Thrower`) and loads it into the new one; the item override then copies the `thrower` reference directly. The result is that thrower, target, age, delay, health and stack carry over.
- `dampensVibrations` is true when the stack is in item tag `dampens_vibrations` (tag contents are data).

Setters: `setDefaultPickUpDelay` = 10; `setNoPickUpDelay` = 0; `setNeverPickUp` = 32767; `setPickUpDelay(n)`; `setUnlimitedLifetime` = age -32768; `setExtendedLifetime` = age -6000 (lives 12000 ticks); `makeFakeItem` = never pickup plus age 5999 (dies after 1 more tick; used for display items). `hasPickUpDelay` is `pickupDelay > 0` (so 32767 counts as delayed).

## 2. Spawning

Every spawn path ends in adding a fresh entity to the level (Add Entity packet to trackers). The paths differ in position, motion, delay, thrower and stats.

| Path | Position | Motion | Pickup delay | Thrower | Notes |
|---|---|---|---|---|---|
| Entity drop `Entity.spawnAtLocation(level, stack[, yOffset])` (mobs' loot, shearing, cow-like products, etc.) | entity position + `(0, yOffset, 0)`; the overloads taking an `ItemLike` or a stack use offset 0; a `Vec3` overload adds the vector | the constructor's random motion (section 1) | default 10 | none | an empty stack returns null and spawns nothing. No game rule is read here. |
| Block drop `Block.popResource(level, pos, stack)` | see 2.1 | constructor random motion | default 10 | none | server only; not for an empty stack; skipped when game rule `block_drops` is false |
| Block drop from a face `Block.popResourceFromFace(level, pos, face, stack)` | see 2.2 | see 2.2 | default 10 | none | same server and game rule checks; used where a block ejects an item from a side |
| Player throw (drop key, drop-all key; not for spectators) | see 2.3 | directional | **40** | the player | `ServerPlayer.drop` also awards stats |
| Creative inventory drop (Set Creative Mode Slot with a negative slot number) | like 2.3 | directional | **40** | the player | throttled, see 2.3.1 |
| Death drop of a player's inventory (`Inventory.dropAll`) | like 2.3 position | random circle, see 2.4 | **40** | none | equipment slots are dropped by `EntityEquipment.dropAll` (the call is read, its per-slot rules are not) |
| Item that does not fit (`ServerPlayer.handleExtraItemsCreatedOnUse`, for example the empty bucket result) | like 2.3 | directional | 40 | none | `Inventory.add` is tried first; only the remainder is dropped |
| Dispenser default behaviour | see 2.5 | see 2.5 | **0** (no delay set) | none | |

Game rules read: `block_drops` (popResource, popResourceFromFace and `popExperience`), `mob_griefing` (section 6). The "entity_drops" rule named in 21 section 8.4 for falling blocks is not read here.

### 2.1 `popResource`

Let `h = 0.25 / 2 = 0.125` (the item type height divided by 2, from the registration). With `r(a, b) = a + nextDouble() * (b - a)` (`Mth.nextDouble`, returns `a` when `a >= b`) drawn from the level's random source in the order x, y, z:

- `x = pos.x + 0.5 + r(-0.25, 0.25)`
- `y = pos.y + 0.5 + r(-0.25, 0.25) - 0.125`
- `z = pos.z + 0.5 + r(-0.25, 0.25)`

**Draw order and the gate.** The three draws above happen **unconditionally and first**, on every call. Only afterwards does the shared helper check its gate: the level is a server level, the stack is non-empty and game rule `block_drops` is true. If the gate fails nothing is spawned but the three random numbers have already been consumed (so a client, an empty stack or `block_drops = false` still advances the level's random source by three draws). The entity itself, with its own constructor draws, is built lazily, only after the gate passes.

The entity is built with the five-argument constructor (so its motion is the random `(+-0.1, 0.2, +-0.1)` of section 1), `setDefaultPickUpDelay` (10) is called, and it is added. The y range is therefore pos.y + 0.125 to pos.y + 0.625 for the entity position (its feet).

### 2.2 `popResourceFromFace`

Let `(sx, sy, sz)` be the face's unit step, `w = 0.25 / 2 = 0.125`, `h = 0.125`. Per axis, the position component is:

- axis with step 0: `base + r(-0.25, 0.25)`, where base is `pos + 0.5` (and for y additionally `- h` at the end);
- axis with step != 0: `base + step * (0.5 + w)` for x and z, `base + step * (0.5 + h)` for y.

(y is `pos.y + 0.5 + (that offset) - h`.) The motion per axis is:

- x: `r(-0.1, 0.1)` when `sx == 0`, else `sx * 0.1`;
- y: `r(0, 0.1)` when `sy == 0`, else `sy * 0.1 + 0.1`;
- z: `r(-0.1, 0.1)` when `sz == 0`, else `sz * 0.1`.

Draw order: position x, y, z, then motion x, y, z; a draw only happens for the axes with step 0. As in 2.1, **all six computations (and their draws) precede the gate** (server level, non-empty stack, `block_drops` true), so they are consumed even when nothing is spawned; the entity is built only after the gate. Delay 10; the entity uses the eight-argument constructor (no constructor draws for motion).

### 2.3 Player throw (`LivingEntity.createItemStackToDrop(stack, randomly = false, setThrower = thrown)`)

Called with `thrown = true` from the drop key and `false` for the "extra items" case. Steps:

1. Empty stack: nothing.
2. Position `(player.x, player.eyeY - 0.30000001192092896, player.z)` (eye Y minus the f32 value of 0.3). The f32 constants used in step 4 are stored as `0.3f` = 0.30000001192092896, `0.1f` = 0.10000000149011612, `0.02f` = 0.019999999552965164, `0.017453292f` and `6.2831855f`.
3. Create the entity with the five-argument constructor, then `setPickUpDelay(40)`, then (when `setThrower`) `setThrower(player)`.
4. Motion (the constructor's random motion is overwritten). Let `P = xRot * 0.017453292` and `Y = yRot * 0.017453292` (both f32, degrees to radians), `sinP, cosP, sinY, cosY` from the game's table-driven `Mth.sin/cos` (table-driven functions, defined in 11 trigonometry paragraph: `sin(x) = TABLE[(long)(x * 10430.378350470453) & 65535]`, `cos(x)` the same with 16384.0 added to the scaled value before the cast, a table of 65536 floats; the same formulas are in 21), then draw in this order `a = nextFloat() * 6.2831855` (f32), `b = 0.02 * nextFloat()` (f32); then

   - `vx = -sinY * cosP * 0.3 + cos(a) * b` (the first product `-sinY * cosP * 0.3f` is computed in f32 and widened; `cos(a) * b` is a double product with `b` widened; the sum is a double)
   - `vy = -sinP * 0.3 + 0.1 + (nextFloat() - nextFloat()) * 0.1` (the two draws in this order; the whole expression is f32 arithmetic with the f32 constants above, widened once when stored)
   - `vz = cosY * cosP * 0.3 + sin(a) * b` (same precision pattern as `vx`)

   `cos(a)` and `sin(a)` here are the ordinary double-precision functions of the runtime (`Math.cos/Math.sin`), not the table versions. The three results are stored as the motion.
5. The caller (`LivingEntity.drop`) first plays the main-hand swing (hand MAIN_HAND, default swing), returns null on a client, and adds the entity on the server.

`ServerPlayer.drop(boolean entireStack)` (the drop packet, 05c Player Action drop actions): removes one item (or the whole selected stack when `entireStack`) from the selected hotbar slot (`Inventory.removeFromSelected`), updates the matching menu slot, stops using the held item if the use item is now empty, then drops with `thrown = true`, then resets the attack strength ticker. `ServerPlayer.drop(stack, thrown, prediction)` runs the common drop (above) and keeps the returned entity (null for an empty stack, and null on a client). Only when `thrown` is true does it then read the returned entity's stack (the empty stack when the entity is null); **only if that stack is non-empty** it awards stat `item_dropped` for that stack's item with the count of the stack **passed in** (the `stack` argument, normally equal to the entity's count), and the custom stat `drop` by 1. With `thrown = false`, or a null or empty result, no stat is awarded.

Drop key actions (`ServerGamePacketListenerImpl.handlePlayerAction`, 05c Player Action): the drop-one action and the drop-all-stack action each do nothing when the player is a spectator (`isSpectator`), and otherwise call `ServerPlayer.drop(false)` and `ServerPlayer.drop(true)` respectively (above). Drops from the open inventory screen with the cursor (click outside the window, or drop keys over a slot) were **not traced**; they are handled by container-click code that was not read here (Open question 18). Only the creative path below was read.

#### 2.3.1 Creative inventory drop (`handleSetCreativeModeSlot`)

For a player with infinite materials (creative) the Set Creative Mode Slot packet (05c) with a **negative slot number**, and a stack that is empty or whose count is not above its item's maximum stack size (and whose item is enabled by the world's feature flags; a disabled item returns at once), drops the packet's stack through `ServerPlayer.drop(stack, true, PREDICTED)`, so it is a thrown drop (section 2.3 steps 1 to 5, delay 40, thrower set, stats awarded). It is rate-limited by `dropSpamThrottler`, a `TickThrottler` with **increment step 20** and **threshold 1480**:

| Element | Rule |
|---|---|
| Allowed | a drop is allowed only while `count < 1480` (a threshold of 0 or less would always allow) |
| On an allowed drop | `count += 20`, then the drop happens |
| Each server tick | `count -= 1` while `count > 0` (the throttler tick is called in the connection's tick) |
| Over the limit | the drop is ignored (the stack is lost, nothing spawns) and a warning naming the player is logged (the text is not needed) |

Consequence (derived): about 74 back-to-back drops are possible (74 * 20 = 1480) before the limit bites, and then one more drop is allowed per 20 ticks on average. Slot numbers 1 to 45 (with a stack that is empty or within its maximum, and an enabled item) instead set that inventory menu slot (and its remote copy) and broadcast the menu changes; that is not a drop. Slot 0 and slots above 45 (non-negative, outside 1 to 45) match neither branch: nothing happens, no drop and no slot change. A negative slot with an over-sized stack also does nothing.

### 2.4 Death drops (`Inventory.dropAll`)

For each of the main inventory's `items` slots that is not empty: `createItemStackToDrop(stack, randomly = true, setThrower = false)`, add the entity, then clear the slot. In this variant (steps 1 to 3 of 2.3 apply, delay 40, no thrower):

- draws in order: `f = nextFloat() * 0.5`, `g = nextFloat() * 6.2831855` (f32);
- motion `(-sin(g) * f, 0.2, cos(g) * f)` using the table-driven `Mth.sin/cos`. The x and z products are f32 (`-sin(g) * f` and `cos(g) * f` computed in float, then widened); the y component is the **f32 constant 0.2** widened to double, stored value **0.20000000298023224**, not the double 0.2. The constants `0.5f` (exact) and `6.2831855f` are f32 too.

(The motion draws come from the dying player's own random source.) Whether keep-inventory skips this is decided by the caller (not read here; see 17 and Open question 8).

### 2.5 Dispenser (`DefaultDispenseItemBehavior`)

`execute` only splits **1** item off the dispensed stack and calls `spawnItem(level, stack, accuracy = 6, facing, position)`. The two level events are played by the final `dispense` method after `execute` returns: level event **1000** with data **0** at the dispenser position (the dispense sound), then level event **2000** with data equal to the facing's 3D data value (`Direction.get3DDataValue`, the dispense animation). `addToInventoryOrDispense` (the fallback below) plays the same two events itself after its own spawn. `position` is the dispenser block centre (`BlockSource.center()` returns the centre of the block, `Vec3.atCenterOf(pos)`, which is +0.5 on each axis; read) plus `facing.step * 0.7` plus a zero vector (`DispenserBlock.getDispensePosition(source)` calls the three-argument form with distance 0.7 and extra offset `Vec3.ZERO`; read). In `spawnItem`:

1. `y` is lowered by **0.125** when the facing axis is vertical and by **0.15625** otherwise.
2. The entity is built with the five-argument constructor and **no pickup delay is set** (delay 0, so it can be picked up at once).
3. `speed = nextDouble() * 0.1 + 0.2`; spread `s = 0.0172275 * accuracy = 0.103365`; motion `x = triangle(stepX * speed, s)`, `y = triangle(0.2, s)`, `z = triangle(stepZ * speed, s)` drawn in that order, where `triangle(c, d) = c + d * (nextDouble() - nextDouble())` (two draws, first minus second).

Other dispenser behaviours (projectiles, bucket, and so on) belong to 17. The default behaviour is also the fallback of `addToInventoryOrDispense` (inserts into the dispenser's own container first; the spawn above happens only when it does not fit).

### 2.6 Experience orbs

`Block.popExperience` (block break XP) awards experience at `Vec3.atCenterOf(pos)` only when `block_drops` is true. The orb entity rules are in 21 section 8.2 and 41 does not repeat them. The player's pickup box test (section 4.1) also finds XP orbs but handles them differently (4.1 step 3).

## 3. Tick behaviour (`ItemEntity.tick`)

The merge cadence below (2 or 40 ticks) supersedes 21 section 8.1's "merge every 40 ticks". The tick runs on both sides (client prediction uses the same movement; `getMoveSimulationType` is SERVER_AND_CLIENT) except where marked server only. Constants in the table are the ones to implement.

| Quantity | Value | Where |
|---|---|---|
| Gravity (per tick, subtracted from vy before moving) | **0.04** (`getDefaultGravity`); 0 when the entity's no-gravity flag is set | `ItemEntity`, `Entity.applyGravity` |
| Air drag factor | **0.98** (f32; `Entity.getAirDrag`) applied to x, y, z after moving | `Entity` |
| Ground friction factor `f` | `0.98 * blockFriction` (f32 product), where `blockFriction` is the friction of the block returned by `ItemEntity.getBlockPosBelowThatAffectsMyMovement` (an override that calls `getOnPos(0.999999)`, see "Block below and friction"); applied to x and z only | `ItemEntity` |
| Ground rebound rule | when on the ground and vy < 0 after the friction step: vy *= **-0.5** (this is a backstop: after the restitution step of 3.3 a resting item has vy = 0 and the rule does not fire on an ordinary block) | `ItemEntity` |
| Restitution after a collision | see 3.3 (vertical, and horizontal zeroing); block `bounceRestitution` 0 by default, slime block 1.0, 0.75 for beds and shelf mushroom, times 0.8 for non-living entities | `Entity.move`, `restituteMovementAfterCollisions` |
| Underwater (fluid height above 0.1 in water) | x and z *= **0.99** (f32 0.99f = 0.9900000095367432); vy is not multiplied, it gets **+5.0E-4f** (f32, widened to 0.0005000000237487257; written 0.0005 below) when vy < **0.05999999865889549** (f32 0.06f), else +0; no gravity that tick | `setUnderwaterMovement` |
| In lava (fluid height above 0.1 in lava) | x and z *= **0.949999988079071** (f32 0.95f); vy: same rule (+0.0005f when vy < 0.05999999865889549); no gravity | `setUnderLavaMovement` |
| Fluid threshold | height compared against 0.10000000149011612 (the f32 value of 0.1) | `tick` |
| Motion skip threshold | horizontal speed squared compared against 9.999999747378752E-6 (the f32 value of 1e-5) | `tick` |
| Move cadence when resting | every 4th tick: `(tickCount + entityId) % 4 == 0` | `tick` |
| Merge cadence | every **2** ticks when the item changed block cell this tick (any of floor x, y, z differs from the cell at tick start), else every **40** | `tick` |
| Lifetime | discard (server) when `age >= 6000` | `tick` |
| Sync threshold | squared velocity change over the tick > **0.01** sets the needs-sync flag | `tick` |

Per-tick order (steps 1 to 12; the exact order matters for results):

1. If the stack is empty: discard and stop.
2. Base entity tick (`Entity.tick`, includes fire handling, section 5.3, and `tickCount += 1`).
3. If `pickupDelay > 0` and it is not 32767: decrement it.
4. Remember the position as the previous position (`xo, yo, zo`), and remember the velocity at this point (`v0`) for step 12.
5. Movement force, one of: if in water (`isInWater`, the water flag) and the water fluid height > 0.1: underwater movement; else if in lava and lava height > 0.1: lava movement; else apply gravity (`vy -= 0.04`).
6. Inside blocks: on a client `noPhysics` is cleared. On the server `noPhysics = not (level has no collision for this entity's box deflated by 1e-7)`. When `noPhysics` is set the item is pushed toward the closest free space: `moveTowardsClosestSpace(x, (minY + maxY) / 2, z)` (section 3.4).
7. Move test: the item moves this tick when it is **not on the ground**, or its horizontal speed squared is **above** 1e-5, or `(tickCount + entityId) % 4 == 0`. If it moves: do the collision move (`move(SELF, velocity)`), apply block-inside effects, then the **friction step**: `drag = 0.98`; `f = drag`; if on the ground (after the move) `f = drag * friction(block below)` (block lookup in "Block below and friction" below); velocity := `(vx * f, vy * drag, vz * f)`; then, if still on the ground and `vy < 0`: `vy *= -0.5`. If it does not move: only the block-inside effects of the last movements are re-applied (no friction, no gravity effect on position this tick; note gravity was still added to vy in step 5, and the on-ground collision resets it at the next move).
8. Cell-change test: `changed = floor(xo) != floor(x) or floor(yo) != floor(y) or floor(zo) != floor(z)`.
9. Merge: period = 2 if `changed` else 40; when `tickCount % period == 0`, on the server, and the item is mergeable (4.2): `mergeWithNeighbours`.
10. Age: if `age != -32768` then `age += 1`.
11. Fluid interaction update (water and lava heights and current pushing, 3.2) is called each tick and its result is OR-ed into the needs-sync flag.
12. Server: if `|v - v0|^2 > 0.01` (v the current velocity) set needs-sync. Then, server only, `age >= 6000` discards the item (a negative `age` such as -6000 therefore lasts 12000 ticks; -32768 never).

Block below and friction: the item entity **overrides** `getBlockPosBelowThatAffectsMyMovement` with offset 0.999999 (f32 constant `0.999999f`), and its friction step (step 7) calls that override. (The base `Entity.getBlockPosBelowThatAffectsMyMovement` uses 0.500001 instead; that value is used by other entities and is not used by items.) The shared lookup `getOnPos(offset)` works as follows with `offset = 0.999999`: the `mainSupportingBlockPos` Optional is what is consulted when it is present. When it is present, the result is that supporting block position moved to Y `floor(y - offset)`, **unless** the supporting block is in the walls tag or is a fence gate, in which case the supporting position itself is used. The fence tag only counts when the offset is 0.5 or less, so it does not apply to items. (An offset at or below 1e-5 always returns the supporting position unchanged; not relevant here.) Without a supporting block the result is `(floor x, floor(y - offset), floor z)`. The supporting block is found by `Level.findSupportingBlock` with a box 1e-6 below the feet (the choice among several candidate blocks is the shared entity movement code; for a 0.25 wide item at a corner it is the candidate nearest to the entity, inferred; Open question 5).

Block friction values (code-defined; `BlockBehaviour.Properties` default is **0.6**; `friction(...)` is called for exactly five blocks in `Blocks`):

| Block | Friction | Horizontal factor per tick on it (0.98 * friction) |
|---|---|---|
| any other block, including air when "on ground" by some other support | 0.6 | 0.588 |
| `ice` | 0.98 | 0.9604 |
| `packed_ice` | 0.98 | 0.9604 |
| `frosted_ice` | 0.98 | 0.9604 |
| `slime_block` | 0.8 | 0.784 |
| `blue_ice` | 0.989 | 0.96922 |

(Properties copied from another block with a full copy inherit its friction; no full copy of the five blocks was found.)

### 3.1 Vertical motion worked example (no fluid, falling from rest in air)

With gravity applied before the move and drag after it, `v_n` the velocity at the start of tick n, displacement `d_n = v_n - 0.04` (the move uses the velocity after gravity), and `v_{n+1} = (v_n - 0.04) * 0.98` (f32 factor 0.9800000190734863):

| tick | `v` at start | displacement this tick | `v` at end |
|---|---|---|---|
| 1 | 0 | -0.04 | -0.0392 |
| 2 | -0.0392 | -0.0792 | -0.077616 |
| 3 | -0.077616 | -0.117616 | -0.11526368 |

Terminal velocity (fixed point of the recurrence) is `-0.04 * 0.98 / 0.02 = -1.96` blocks per tick of velocity before the move; the move uses `-2.0`.

A resting item on a normal block (restitution 0): the collision move cancels the downward step at the contact height (on ground stays true), and the restitution step of 3.3 then sets vy to exactly 0 (bounciness 0 on the vertical axis), so the friction step leaves vy at 0, which is not below 0 and the -0.5 backstop does not fire. Because the "move" test is false on most ticks (horizontal speed 0, `(tickCount + id) % 4 != 0`) the item only actually moves one tick in four; on the ticks that do not move, gravity is still added to vy (step 5) but the position and the friction step are skipped, so vy keeps growing more negative until the next move tick, where the collision and the restitution step zero it again. On a block with restitution above 0 this matters (3.3).

### 3.3 Restitution after a collision (`Entity.move` end, `restituteMovementAfterCollisions`)

After the collision move (step 7), the shared entity code runs the restitution step only if `canSimulateMovement` is true and either (`|requested movement.y| > 0` and a vertical collision occurred) or a horizontal collision occurred. The flags are computed in `Entity.move` as follows: the x collision flag is true when requested x and collided x differ under `Mth.equal` (a small tolerance, not an exact comparison), likewise the z flag; `horizontalCollision` is the OR of the two; `verticalCollision` is true when requested y and collided y differ **exactly**; `verticalCollisionBelow` is `verticalCollision` and requested y < 0. Inputs: `v` = the velocity at that moment (the velocity used for the move, that is after this tick's gravity, **not** yet zeroed by the collision), `m` = the collided distance actually moved this move, `state` = the block state at the entity's legacy on-position (`getOnPosLegacy`, a different lookup from the friction block of section 3, "Block below and friction"), and the two horizontal collision flags (x and z, separately). Steps:

1. `b0` = 0 when the entity is suppressing bounce (`isSuppressingBounce`, which for the base entity is "shift key down"), else `getEntityBounciness`, which is **0 for item entities**. So `b = 0` for items unless a block supplies more (step 4).
2. Horizontal: if the x collision flag is set, `vx = -vx * b`; if the z flag is set, `vz = -vz * b`. With `b = 0` this sets the velocity component to 0 on the axis that was blocked: **an item that hits a wall loses that horizontal component entirely.**
3. A pending "bounced" flag is set when `b > 0` and a horizontal flag was set (never true for items at this point).
4. If a vertical collision occurred:
   a. If it was a downward collision (`verticalCollisionBelow`): `b` becomes 0 when `-vy <= effective gravity` (0.04 for items; a slow landing does not bounce), or the entity is suppressing bounce, or `state` is in block tag `suppresses_bounce`; otherwise `b = max(b, blockBounciness)`, where `blockBounciness = block.bounceRestitution` (f32), multiplied by f32 **0.8** when the entity is not a living entity (so items get 0.8 of the block value). An upward collision (head hit) keeps `b` as it was (0 for items).
   b. If `b > 0`: `ratio = m.y / v.y` (the fraction of the intended move that completed, in 0 to 1), `gravityTerm = ratio * effectiveGravity`, `dragLerp = 1 + ratio * (airDrag - 1)` (f32 airDrag 0.98), and the bounced flag is set. Otherwise `gravityTerm = 0` and `dragLerp = 1`.
   c. `vy = (gravityTerm - vy) * dragLerp * b`. With `b = 0` this is 0, so a vertical collision always zeroes vy for items on ordinary blocks.
5. If the bounced flag is set: call `Block.bounceOn(level, state, pos below, entity, fallDistance)` (the base implementation does nothing), emit game event BOUNCE from the entity, and set the entity's position-sync flag.
6. Store the velocity.

Block restitution values (code-defined, `BlockBehaviour.Properties.bounceRestitution`, default 0): `slime_block` **1.0** (with friction 0.8); a bed properties lambda (taking a dye colour and the bed part, so it is the bed blocks; the registration of the individual blocks was not traced) and `shelf_mushroom`, both **0.75** with `fallDistanceReduction` 0.5. Only these three `bounceRestitution` call sites exist in `Blocks`. For an item: slime 0.8, bed and shelf mushroom 0.6 (0.75 * 0.8 in f32).

Worked example (item landing on a slime block): `v.y = -0.5` after gravity, the block stops the move after `m.y = -0.3`. Then `-vy = 0.5 > 0.04`, so `b = 0.8`; `ratio = 0.6`, `gravityTerm = 0.024`, `dragLerp = 0.9880000114` (f32 0.98); `vy = (0.024 + 0.5) * 0.988 * 0.8 = 0.4141696`. The friction step (section 3 step 7) then multiplies by 0.98 to 0.40589 and, being positive, the -0.5 backstop does not apply. The item leaves the slime block upward. A resting item on a slime block (derived from 3.1: vy builds to -0.16 over four ticks, then a move tick) re-bounces whenever the build-up exceeds 0.04 (inferred from the rules above; no run was made), and a landing slower than 0.04 does not bounce.

### 3.4 Push out of blocks (`Entity.moveTowardsClosestSpace(x, y, z)`)

Inputs: the point `(x, y, z)` (for an item, its x, the vertical middle of its box and its z). Steps:

1. Reference cell `c = BlockPos.containing(x, y, z)`; local offset `o = (x, y, z) - c` (the position minus the cell corner, each component in 0 to 1).
2. Start with best direction UP and best distance `+infinity` (the double maximum).
3. Try candidates in this order: NORTH, SOUTH, WEST, EAST, UP. For each, look at the block at `c + step`: skip the candidate when that block's collision shape is a full block (`isCollisionShapeFullBlock`). Otherwise its distance is the component of `o` on the candidate's axis, replaced by `1.0 - component` when the candidate's axis direction is positive (SOUTH, EAST, UP). If the distance is **strictly** smaller than the best so far, it becomes the best (so an earlier candidate wins ties). If every candidate is skipped the result stays UP.
4. Draw `s = nextFloat() * 0.2 + 0.1` from the entity's own random source (f32: `0.2f`, `0.1f`) and let `k` be the chosen direction's axis step (+1 or -1, as a float); the push speed is `k * s`.
5. New velocity: the old velocity multiplied by **0.75**, then the component on the chosen axis replaced by `k * s` (widened to double). The other two components keep their scaled values.

Worked example: item centre at local offset `o = (0.5, 0.3, 0.9)` inside a solid block whose neighbours are all passable except SOUTH and UP: NORTH distance 0.9 (z axis, negative direction, `o.z`), WEST 0.5, EAST `1 - 0.5 = 0.5` (not strictly smaller than WEST's 0.5, so WEST stays); best is WEST; with a draw giving `s = 0.2`, `k = -1` and old velocity `(0.4, 0, 0)` the new velocity is `(-0.2, 0, 0)`. (The neighbours chosen for this example are illustrative; the rule above is what was read.)

### 3.2 Fluid interaction and current

`Entity.updateFluidInteraction` (called by item every tick, step 11) maintains per-fluid heights through `EntityFluidInteraction.update` and then applies currents when `isPushedByFluid` is true (it is true for item entities, no override):

- In water: `applyCurrentTo(water, 0.014)`.
- In lava: `applyCurrentTo(lava, 0.007)` when the dimension's `fast_lava` environment attribute is true (the Nether), else `0.0023333333333333335` (= 0.007 / 3).
- `applyTo(entity, scale)`: does nothing when no current cell was counted or the accumulated current vector has squared length below 9.999999747378752E-6. For non-players the accumulated vector is normalised; (players use the average, not relevant here). The vector is then multiplied by `scale`. A special floor: if `|vx| < 0.003` and `|vz| < 0.003` and the scaled vector's length is below 0.0045 (0.0045000000000000005), the vector is normalised and scaled to 0.0045 so slow items are still pushed. The result is **added** to the velocity (`addDeltaMovement`).
- Reset and pre-check (`EntityFluidInteraction.update`, read): the update first prunes the fluid trackers with `removeIf` using the tracker's `reset`: `reset` clears the tracker's height and `eyesInside` flag and returns true (the tracker is dropped from the list) **only if** both were already clear (height 0 and `eyesInside` false); otherwise it clears them and returns false (the tracker is kept). Then, before any cell is scanned, the update tests the region covered by the interaction box (below) widened by **one cell on x and z on both sides** (the cell range is `floor(min) - 1` to `ceil(max)`, in x and z; the y range is **not** widened, it is `floor(minY)` to `ceil(maxY) - 1`). Every chunk column overlapping that region must be loaded at status FULL (a missing column makes the test fail at once), and at least one chunk section in the region's vertical range must contain fluid (`LevelChunkSection.hasFluid`). If the test fails, all heights stay 0 and the update returns false with no scan.
- Scan (`EntityFluidInteraction.update`, all read): at the start of each update the accumulators are reset (height 0, vector zero, count 0). The scan box is the entity bounding box deflated by **0.001** on every side (`Entity.getFluidInteractionBox`; a vehicle may modify it, not relevant to items). Cells run from `floor(min)` to `ceil(max) - 1` on each axis of that box. A cell is skipped when its fluid state is empty, or when `cellY + fluidHeight` (the fluid surface, with `fluidHeight` the f32 `FluidState.getHeight`) is **below the interaction box minY**. For every other cell the tracker for that fluid type stores `max(previous, cellY + fluidHeight - entityMinY)`, where `entityMinY` is the minY of the **undeflated** bounding box, not of the interaction box. Then, only when accumulators exist (they are used only when `isPushedByFluid` is true; the update is told to skip them otherwise), the accumulator height becomes `max(tracker height after this cell, accumulator height)`; the cell flow vector (`FluidState.getFlow`) is multiplied by that accumulator height when it is **below 0.4**; the vector is added to the sum and the count is incremented by one. The update returns true when at least one fluid cell counted.
- `applyTo` detail: the 0.003 test uses the entity's **current velocity** x and z (read before the push is added), while the 0.0045 test uses the length of the **scaled** push vector (after multiplication by `scale`). `getFluidHeight(tag)` is the tracker height for the fluid with that tag, `isInFluid` = height > 0. `isInWater` is the **previous-tick** flag `wasTouchingWater` (set when the water height was > 0), while `isInLava` is "not the first tick and lava height > 0".

Water splash effects (`doWaterSplashEffect`) run when an entity enters water; their sound and particle values are not item specific and were not traced.

## 4. Pickup

### 4.1 Which player touches which item (`Player.aiStep`, server and client)

Each player tick, **if** `health > 0` and the player is not a spectator:

1. Pickup box: the player's bounding box inflated by **1.0 horizontally (each of x and z, on both sides) and 0.5 vertically (both sides)**. A passenger whose vehicle is alive instead uses the union of its own box and the vehicle box inflated by (1.0, 0.0, 1.0).
2. All entities of any type intersecting the box, excluding the player itself and **excluding spectator-mode entities**, are enumerated (the call is `Level.getEntities(entity, box)`, whose default filter is `EntitySelector.NO_SPECTATORS`, so a spectator is never enumerated and never gets `playerTouch`)  (order: the level's entity lookup order, not specified; Open question 7). Experience orbs are collected into a list; every other entity that is not removed gets `playerTouch(player)` called immediately.
3. After the loop, if the XP list is not empty, **one randomly chosen** orb of the list (uniform pick with the player's random source) gets `playerTouch`. Only one XP orb is processed per tick (21 section 8.2 for its pickup effect).

Examples of reach: the player box is 0.6 wide, so an item (0.25 wide) is touched when its box overlaps the region `[px - 0.3 - 1.0, px + 0.3 + 1.0]` in x (and likewise z), and `[py - 0.5, py + 1.8 + 0.5]` in y (where `py` is the player's feet y). Intersection is read in `AABB.intersects(minX..maxZ)`: strict comparisons on every axis (this.min < other.max and this.max > other.min for x, y and z), so boxes that only share a face do not intersect.

Clients also run this loop but `ItemEntity.playerTouch` returns at once on a client, so only the server picks up.

### 4.2 `ItemEntity.playerTouch(player)` (server only)

Let `stack` be the entity's stack, `n = stack.count` before the transfer, `item = stack.item`.

1. Proceed only if `pickupDelay == 0` **and** (`target` is unset **or** `target == player.uuid`) **and** `player.inventory.add(stack)` returns true. (The `add` call is the transfer itself, with side effects; it is only attempted when the first two conditions hold.) Otherwise do nothing; the item stays.
2. `player.take(entity, n)`: sends the Take Item Entity packet (section 4.5) and (server player) broadcasts the container menu changes. Because `Inventory.add` returns true in survival only when the stack ended up empty (4.3), `n` is always the full count that fitted; a partial transfer never reaches this step.
3. The stack is now empty (survival) or was consumed (creative): discard the entity, then restore `stack.count = n` on the (discarded) stack object (so later reads of it, for example by advancement triggers, see the original count).
4. Award stat `item_picked_up` for `item` with amount `n`.
5. `player.onItemPickup(entity)`: `LivingEntity.onItemPickup` fires the "thrown item picked up by entity" advancement trigger when `getOwner` (the entity resolved from the `thrower` reference, section 1) is a server player; `ServerPlayer.onItemPickup` additionally fires "thrown item picked up by player" when `getOwner` resolves to an entity. Both triggers get the entity's stack (count restored in step 3).

The pickup test uses the **owner** (`target`) field, not the thrower: a thrown item has a thrower but no target, so the thrower can pick it up again as soon as the delay (40 ticks) expires; nothing in the vanilla throw path sets `target`. Only the entity API (commands, data tags, `Owner` NBT) sets it. With `target` set to another player's UUID, the item is skipped by everyone else for as long as it lives, and it also does not merge with items of a different target (4.4).

Partial transfers (survival): when the inventory can take only part of the stack, `Inventory.add` returns **false** (4.3). The items that already moved stay in the inventory and the entity keeps the remainder (its stack is shrunk in place), but there is **no** Take Item Entity packet, no `item_picked_up` stat, no advancement trigger, no entity discard and no client pickup sound for that attempt. The next player tick that touches the entity tries again.

### 4.3 `Inventory.add(stack)` (and the creative rule)

`add(slot = -1, stack)`:

1. Empty stack: return false.
2. **Damaged stacks** (`isDamaged`, durability used) never stack: take `slot` or, when `-1`, the first free slot (`getFreeSlot`, lowest index among the 36 main `items` that is empty); if found, move the whole stack into it (`copyAndClear`, which leaves the source empty), set that stack's pop time to 5, return true. If none: if the player has infinite materials (creative) set the source count to 0 and return true; else return false.
3. Otherwise repeat the following iteration: read `count0 = stack.count` **at the start of every iteration**, call `addResource` (below) and set its result as the new count of the source stack. Repeat while the stack is non-empty and the count fell during that iteration. The loop therefore ends either with an empty stack or with a **stalled** iteration (count equal to that iteration's `count0`, nothing moved in the last pass). After the loop, `count0` still holds the value read in the last iteration.
4. If the stack is non-empty after the loop (so the count equals the last `count0`) and the player has infinite materials: set count 0 and return true. **A creative player consumes the whole stack when the last iteration stalled, including when part of it already fitted in earlier iterations** (the remainder is discarded, not only when nothing fitted).
5. Otherwise return `stack.count < count0`: in survival this is true only when the stack ended up empty (the last iteration moved something and emptied the stack); a partial transfer ends with a stalled iteration and returns **false**, with the moved items kept in the inventory and the remainder left on the source stack.

`addResource(stack)`: pick the slot with `getSlotWithRemainingSpace(stack)`, else the first free slot (`getFreeSlot`); if none, the whole count is returned unchanged. `getSlotWithRemainingSpace` checks, in order: the **selected hotbar slot**, then the **off-hand** (slot index 40), then the main items in index order 0, 1, 2, ...; the first slot that `hasRemainingSpaceForItem(slotStack, stack)` wins: the slot stack is non-empty, `isSameItemSameComponents(slotStack, stack)`, the item is stackable, and `slotStack.count < inventory.getMaxStackSize(slotStack)` where `Inventory.getMaxStackSize(stack) = min(99, item max stack size)` (the `Container` default of 99 is not overridden). The per-slot add: if the slot is empty a zero-count copy is placed first; `room = maxStackSize(slotStack) - slotStack.count`; `moved = min(count, room)`; if `moved == 0` return the count unchanged; else the slot grows by `moved`, its pop time is set to 5 (the inventory slot "pop" animation counter) and `count - moved` is returned.

Armor slots (36 to 39) and the container screen's slots are not touched by pickup. Whether items go into a bundle or shulker box is not part of this path (open container interactions are in 13).

Creative pickup, summarised: the player in creative (infinite materials) still picks items up normally when they fit; a full inventory does not block the pickup and the entity is consumed; no creative-specific range, delay or owner check exists in `ItemEntity.playerTouch`. Spectators and dead players are excluded earlier (4.1).

### 4.4 Merging

`mergeable` (`isMergable`): the entity is alive, `pickupDelay != 32767`, `age != -32768`, `age < 6000`, and `stack.count < stack.maxStackSize`.

`mergeWithNeighbours` (called per the cadence in section 3, server only, when this entity is mergeable): the candidate set is every item entity (other than this) whose box intersects this entity's box **inflated by (0.5, 0, 0.5)** and which is itself mergeable. Candidates are visited in the level's lookup order (Open question 7). For each, if it is mergeable, `tryToMerge(other)` runs; the loop stops as soon as this entity is removed.

`tryToMerge(other)`:

1. Both entities' `target` values must be equal (both unset, or equal UUIDs; `Objects.equals`), and `areMergable(a, b)` must hold: `a.count + b.count <= b.maxStackSize` and `isSameItemSameComponents(a, b)` (same item and equal data components). Otherwise nothing happens.
2. **Direction**: if `other.count < this.count`, `this` absorbs `other`: `this` is the receiver. Otherwise (other has an equal or larger count) `other` absorbs `this`.
3. `merge(receiver, receiverStack, donor, donorStack)`: `moved = min(min(receiverStack.maxStackSize, 64) - receiverCount, donorCount)`; the receiver gets a stack copy of count `receiverCount + moved`, the donor stack shrinks by `moved`. Then the receiver's `pickupDelay` becomes `max(receiver.delay, donor.delay)` and its `age` becomes `min(receiver.age, donor.age)`. If the donor's stack is empty the donor entity is discarded.

(The 64 literal is the limit used by the entity merge; `areMergable` already bounds the total by the item's own maximum, so for stacks capped below 64 the item maximum wins, and for a 99-stack item the total is bounded by `areMergable` to the item max while `merge` also caps at 64 per call, see Open question 11.)

Teleporting an item entity (portal) calls `mergeWithNeighbours` on the arriving entity. Age is not reset by merging and delay becomes the larger of the two.

### 4.5 Take Item Entity packet

`LivingEntity.take(entity, count)` (server, called through `Player.take` by pickup; also by arrows and XP orbs): if the entity is not removed, the level is not a client level, and the entity is an item entity, an abstract arrow, or an experience orb, send **Take Item Entity** (05b 0x7F: collected id, collector id, amount) to **the players tracking the collected entity** (`ServerChunkCache.sendToTrackingPlayers(entity, packet)`; it is sent before the item is discarded, so the Remove Entities for the item follows). Fields: collected entity id = the item's id, collector id = the player's id, amount = `n` of 4.2. No sound packet is sent by the server for pickup; the client makes the sound (4.6). For `ServerPlayer.take` the open container menu then runs `broadcastChanges`, which is what updates the player's inventory slots (Set Container Slot or Content packets, 05a/05b).

### 4.6 Client handling (`ClientPacketListener.handleTakeItemEntity`)

Given the collected entity (looked up by id; nothing happens if missing) and the collector (cast to a living entity):

1. If the collected entity is not silent: play a local sound at the **collected entity's position**, source PLAYERS, not distance-delayed:
   - XP orb: event `experience_orb.pickup`, volume **0.1**, pitch `(nextFloat() - nextFloat()) * 0.35 + 0.9` (f32; the first draw minus the second);
   - anything else: event `item.pickup`, volume **0.2**, pitch `(nextFloat() - nextFloat()) * 1.4 + 2.0` (f32).
   The random source is the client's own.
2. Extract the collected entity's render state with **partial tick 1.0** (`EntityRenderDispatcher.extractEntity(entity, 1.0)`) and, if the collector exists, add an **item pickup particle** built from (the level, that render state, the collector, the collected entity's **current velocity**). Read in `ItemPickupParticle`: the particle starts at the render state's position with the velocity as its motion (base `Particle` constructor arguments); its render state outline colour is set to 0; `LIFE_TIME` is 3; each tick increments `life`, removes the particle when `life` reaches 3, then saves the old target position and refreshes the target position as `(collector.x, (collector.y + collector.eyeY) / 2.0, collector.z)` (the middle of the collector's body). (The class has six fields, `targetX/Y/Z` and `targetXOld/YOld/ZOld`, and `updatePosition` fills all three from the collector. The constructor also calls `updatePosition` then `saveOldPosition` once, so old equals new at creation. The tick order is: life + 1, remove at life 3, save old, update.) What the renderer does with the stored old and new target positions to draw the 3-tick flight (the interpolation formula, and `ParticleRenderType.ITEM_PICKUP` drawing) was **not traced** (Open question 12).
3. For an item entity: take its stack, if not empty shrink it by `amount` (the packet's amount); if it is now empty the entity is removed (reason DISCARDED).
4. For anything that is neither an item entity nor an XP orb (arrows) the entity is removed at once. XP orbs are not removed here (the server's remove packet does it).

## 5. Lifetime, damage, fire, explosions

### 5.1 Despawn and lifetime

Age counts every tick regardless of players (there is **no player-distance condition** and no chunk-loaded condition other than the entity being ticked; the stand-in "age counts only near a player" is not the standard). Discard when `age >= 6000` (5 minutes of ticks). Special ages: -6000 (extended: 12000 ticks), -32768 (never). `age` is saved, so a world that is unloaded and reloaded continues counting from the saved value; ticks while the chunk is unloaded do not count. A merge takes the smaller age (so merging with a fresh item gives the pile the fresh age and prolongs it).

### 5.2 Hurt rules (`hurtServer`, `hurtClient`)

Order of checks in `hurtServer(level, source, amount)`:

1. `isInvulnerableToBase(source)` (shared entity rules) returns **true** (meaning "immune to this hit", and `hurtServer` then returns false and ignores it) when any of these holds: the entity is removed; or the entity is invulnerable (`Entity.isInvulnerable` = permanent flag, or `invulnerableTime > 0`) and the source is not in tag `bypasses_invulnerability` and not from a creative-mode player; or the source is in tag `is_fire` and the entity is fire immune; or the source is in tag `is_fall` and the entity type is in `fall_damage_immune`. Otherwise it returns false and the checks continue. The tag contents are data.
2. If game rule `mob_griefing` is false and the damage source's causing entity is a `Mob`: ignored.
3. If the stack's `damage_resistant` component lists the source's damage type (`ItemStack.canBeHurtBy` is false): ignored. `damage_resistant` is the item component (17 section 2 table, component 27). Read in `Items`: the helper `Item$Properties.fireResistant` builds a resistance to damage type tag **`is_fire`** and is called for 16 items: `ancient_debris`, `netherite_block`, `netherite_ingot`, `netherite_scrap`, and the netherite sword, shovel, pickaxe, axe, hoe, spear, helmet, chestplate, leggings, boots, horse armor and nautilus armor (item names read from the `putstatic` that follows each of the 16 `Item$Properties.fireResistant` call sites in `Items`; the count is exactly 16). The nether star has a separate resistance to tag **`is_explosion`** (not fire; `DamageTypeTags.IS_EXPLOSION` is referenced once in `Items`). No other item registration sets the component in `Items`.

Tag contents (data, read from `data/minecraft/tags/damage_type/`): `is_fire` = in_fire, campfire, on_fire, lava, hot_floor, sulfur_cube_hot, unattributed_fireball, fireball; `is_explosion` = fireworks, explosion, player_explosion, bad_respawn_point; `is_fall` = fall, ender_pearl, stalagmite; `bypasses_invulnerability` = out_of_world, generic_kill. So a netherite item survives lava, fire and fireballs, and a nether star survives explosions and fireworks but burns.
4. Otherwise: mark hurt, `health = (int)(health - amount)` (the subtraction is done in float and truncated to int), fire game event `entity_damage` with the damaging entity; when `health <= 0`: `ItemStack.onDestroyed(entity)` (item-specific hook, for example a bundle spilling its contents; not read) and discard; return true.

The `invulnerableTime` counter does take part in step 1 (through `Entity.isInvulnerable`, above): a positive value (set only from outside, for example by command or entity data) blocks hits unless the source bypasses invulnerability or comes from a creative-mode player. The item's own `hurtServer` never sets it, so in normal play it stays 0 and a damaging source that touches every tick damages every tick: lava (4.0 per hit through `Entity.lavaHurt` after `LAVA_IGNITE`, applied whenever the entity is inside a lava fluid cell by `LavaFluid.entityInside`; inferred to run each tick the item box overlaps lava) kills a 5 health item in **2 hits** (5 - 4 = 1, then 1 - 4 <= 0). `hurtClient` only reports whether the hit would be accepted (not invulnerable, and `canBeHurtBy`). `isAttackable` is false, so players and mobs cannot hit-attack an item entity (attack packets to it are not damage; 17 for the attack handler).

### 5.3 Fire

`ItemEntity.fireImmune()` = the stack is **not** hurt by `in_fire` damage (`canBeHurtBy(inFire)` is false, meaning the stack's `damage_resistant` lists in-fire) **or** the base entity rule says immune (base: from the entity type's fire immunity; items are not fire immune by type). So fire immunity is exactly "the stack carries `damage_resistant` for fire", which in `Items` means the 16 netherite-family items of 5.2 (the nether star is explosion-resistant only and burns).

Base tick fire rules (server): while `remainingFireTicks > 0`: if fire immune, clear fire; else every tick that `remainingFireTicks % 20 == 0` and the entity is not in lava, hurt with `on_fire` damage **1.0**; then decrement. `LAVA_IGNITE` (from `LavaFluid.entityInside`) does `igniteForSeconds(15)` unless fire immune, and the lava hurt is **4.0** (damage type `lava`) through `lavaHurt` (skipped when fire immune). A burning (non-immune) item without further lava therefore takes 1.0 damage at tick boundaries and dies after five such hits if it stays on fire. Fire blocks use `FIRE_IGNITE` (`BaseFireBlock.fireIgnite`, values not read here). Lava hurt sound: `generic.burn` at the entity, volume 0.4, pitch `2.0 + nextFloat() * 0.4` (f32), played only when the hit was accepted, `shouldPlayLavaHurtSound` allows it and the entity is not silent; for items `shouldPlayLavaHurtSound` is true when `health <= 0` or `tickCount % 10 == 0`.

### 5.4 Explosions

`ItemEntity.ignoreExplosion(explosion)`: when the explosion's `shouldAffectBlocklikeEntities()` is true, the base entity rule decides, and `Entity.ignoreExplosion` always returns false; when it is false the item **ignores** the explosion. `Explosion$BlockInteraction.shouldAffectBlocklikeEntities` is false for KEEP and TRIGGER_BLOCK and true for DESTROY and DESTROY_WITH_DECAY (read in the enum's static initialiser). So an item ignores an explosion only for KEEP and TRIGGER_BLOCK interactions and is otherwise subject to damage.

Damage path (read in `ServerExplosion.hurtEntities`): entities in the blast box are skipped when `ignoreExplosion` is true; otherwise, for each, when the damage calculator allows damaging it (and the explosion's source entity, if any, passes `doTeamsAllowDamage`), the entity's `hurtServer` is called with the explosion's damage source and the amount from the calculator's `getEntityDamageAmount(explosion, entity, seenPercent)`. This is the `hurtServer` of 5.2, so `damage_resistant` for `is_explosion` (nether star) makes the item survive. The numeric damage formula and the claim that a nearby blast usually exceeds 5 health were not traced (recalled, not verified; Open question 1).

## 6. Where items come from at death and break (references only)

Block drops come from the block's loot table rolled with the break context (17 section 3.16, GAP-4) and then each rolled stack goes through `Block.popResource` (2.1) (or `popResourceFromFace`); `Block.dropResources` also calls the state's `spawnAfterBreak` afterwards (for the XP and specials). Mob drops (18 section 7.6, Entity loot tables) spawn through `Entity.spawnAtLocation` (2.0 table row 1): rolled stacks are already split to the item's max stack size. A thrown `loose` item in the stand-in is replaced by this entity.

## 7. Rendering facts needed on the client

Visual bobbing (`ItemEntityRenderer`, client only, not simulated). `ageInTicks` here is the render state's value, `Entity.tickCount + partialTick` (`EntityRenderer.extractRenderState`), **not** the item's `age` field; `bobOffs` is the entity's random phase. Translate Y (f32 arithmetic) = `(sin(ageInTicks / 10 + bobOffs) * 0.1 + 0.1) + (-modelBoundingBox.minY + 0.0625)`, using the table `Mth.sin`; the 0.0625 is added (it is `ITEM_MIN_HOVER_HEIGHT`, not a minimum). Then the model is rotated about the vertical axis by `ageInTicks / 20 + bobOffs` radians (`ItemEntity.getSpin`). `getVisualRotationYInDegrees` (the only user of `getAge()`) = `180 - ((age + 0.5) / 20 + bobOffs) / (2 * pi) * 360` degrees. Shadow radius 0.15, strength 0.75.

Copies for a stack (`ItemClusterRenderState`, `ItemEntityRenderer.submitMultipleFromCount`): rendered amount from count `n`: 1 when `n <= 1`, 2 when `n <= 16`, 3 when `n <= 32`, 4 when `n <= 48`, else 5. The random source is seeded with the item's registry id plus its damage value (187 for an empty stack). Let `depth` be the Z size of the model bounding box. If `depth > 0.0625` ("thick" models): the first copy is drawn unmoved; each further copy is drawn offset by `((nextFloat() * 2 - 1) * 0.15)` on each of **x, y and z** (three draws, in that order). Otherwise ("flat" models): spacing `d = depth * 1.5`; the whole group is shifted by `-d * (amount - 1) / 2` along z, the first copy is drawn, and each further copy is drawn after advancing z by `d`, with x and y offsets `(nextFloat() * 2 - 1) * 0.15 * 0.5` (two draws, x then y). (Only the flat branch offsets x and y alone.) These do not affect the server.

## 8. Differences from the stand-in rules

| Rule | Stand-in (S50) | Standard (this document) |
|---|---|---|
| Pickup delay on block break / mob death | 6 | 10 |
| Pickup delay on throw / inventory drop / death | 30 | 40 |
| Dispenser | not specified | 0 |
| Gravity | 0.035 | 0.04 |
| Drag | 0.97 | 0.98 (air); ground factor 0.98 * block friction; water 0.99; lava 0.95 |
| Throw velocity | `(-sinY cosP 0.25, -sinP 0.25 + 0.12, ...)` | section 2.3 (0.3 scale plus random circle and +0.1) |
| Lifetime | 4800, counts only with a player within 32 | 6000, always counts |
| Merging | never | section 4.4 |
| Pickup box | player box + 0.75 / 0.25 | player box + 1.0 horizontal, + 0.5 vertical, every non-spectator living player, one pass per tick |
| Owner / thrower | not modelled | `target` restricts pickup; thrower does not |
| Pickup stats and advancement | none | `item_picked_up`, `item_dropped`, `drop`, thrown-item triggers |
| Landing | not specified | restitution step (3.3): zero vertical velocity, 0.8 * block value on slime |

## 9. Validation (test cases from the text above)

1. Constants: lifetime 6000; default delay 10; thrown/death delay 40; dispenser delay 0; gravity 0.04; health 5.
2. Fall from rest in air: velocities and displacements of 3.1 over three ticks (displacement -0.04, -0.0792, -0.117616).
3. Landing on stone (friction 0.6): horizontal velocity 0.2 decays by 0.588 per ticks it moves (0.2, 0.1176, 0.0691...); on blue ice by 0.96922 per move tick.
4. Underwater: item with vy = -0.5 entering water of height above 0.1: no gravity, vx and vz * 0.99, vy = -0.5 + 0.0005 (then * 0.98 by the common drag step) -> -0.48951.
5. Throw with yaw 0 and pitch 0 and draws in order `r1 = 0.25`, `r2 = 0.5`, `r3 = 0.5`, `r4 = 0.5`: `a = 0.25 * 2 pi = pi/2`, `b = 0.02 * 0.5 = 0.01`, `vx = 0 + cos(pi/2) * 0.01 = ~0`, `vy = 0.1 + (0.5 - 0.5) * 0.1 = 0.1`, `vz = 0.3 + sin(pi/2) * 0.01 = 0.31`. Spawn height: player eye 1.62 above feet at y = 64 gives y = 64 + 1.62 - 0.3 = 65.32 (eye height value of the player from 13).
6. Block pop at (10, 64, 10): x in `[10.25, 10.75]`, y in `[64.125, 64.625]` (64 + 0.5 + [-0.25, 0.25] - 0.125), z in `[10.25, 10.75]`; motion x and z in `[-0.1, 0.1]`, y 0.2; delay 10.
7. Pickup box: player at feet (0, 64, 0), item at (1.2, 64.0, 0) is touched (1.2 - 0.125 = 1.075 is below 0.3 + 1.0 = 1.3); item at (1.5, 64, 0) is not (1.375 above 1.3).
8. Delay: an item spawned with delay 10 is not picked up on ticks 1 to 10 after spawn when the player stands on it (the entity decrements the delay in its own tick before the player's touch in the same tick order; the exact tick on which it first transfers depends on tick order between entity and player, Open question 15).
9. Merge: two stacks of 20 and 30 of an item with maximum 64, within 0.5 horizontally, equal `target`. When the 30-entity runs the pass (`this` = 30, `other` = 20, other smaller) `this` absorbs: 50 remains, the 20-entity is discarded, delay = max of the two, age = min of the two. When the 20-entity runs the pass, `other` (30) is not smaller, so `other` absorbs `this`: same result. Stacks of 40 and 30 (sum 70 above 64): no merge.
10. Merge cadence: an item that changes block cell tries every 2 ticks; a settled item every 40 ticks (tickCount modulo).
11. Inventory add: selected slot holds 60 of the same item (max 64), picking up 10: iteration 1 moves 4 (slot becomes 64, source 6), iteration 2 moves the 6 into the next slot with room (off-hand next, then slots 0 up) or the first free slot and empties the stack; `add` returns true; Take Item Entity amount 10; `item_picked_up` +10; the entity is discarded. If instead no other slot has room, iteration 2 stalls: `add` returns false, the selected slot stays at 64, the entity keeps 6, no packet, no stat.
12. Full inventory in survival: add returns false, the item remains. Creative with a full inventory: the item is consumed and nothing is added. Creative with room for only part of the stack (say 3 of 5): the 3 are added and the whole remaining stack is consumed (count set to 0), `add` returns true, packet amount 5. Survival with room for only 3 of 5: the 3 are added, `add` returns false, the entity keeps 2, no packet, no stat.
13. Damage: lava deals 4.0, two hits destroy a normal item; a netherite item (`damage_resistant` fire tag) ignores lava and fire, and `fireImmune()` is true; a nether star is destroyed by lava but ignores an explosion.
14. `target` set to player A: player B touching the item never picks it up; the item does not merge with items whose `target` differs.
15. Take packet: collected id = item entity id, collector = player id, amount = the full count that fitted. It is sent only when `add` returned true; a 5-item stack of which 3 fit in survival sends no packet at all (the entity keeps 2), and a creative player's partial fit sends amount 5.
16. Restitution: item landing on stone with post-gravity vy -0.5: vy = 0 afterwards. Landing on a slime block with the numbers of 3.3: vy = +0.4141696 after restitution, 0.40589 after the friction step. Falling at -0.03 onto slime: no bounce (not above gravity 0.04), vy = 0. Hitting a wall: that horizontal component becomes 0.
17. Creative drop throttling: 74 immediate creative drops are allowed (count reaches 1480 after the 74th), the 75th in the same tick is ignored with a warning; the count drops by 1 per tick.
18. Draw order: `popResource` at a position consumes three level-random draws even when `block_drops` is false.

## Open questions

1. The explosion damage values applied to items (`ExplosionDamageCalculator.getEntityDamageAmount` and the seen-percent exposure) are not part of this document (explosion documents). The statement that a close explosion usually destroys a 5-health item is (recalled, not verified).
2. Which items carry `damage_resistant` was read only from the `Items` registration code (5.2: 16 fire-resistant items, nether star explosion-resistant). Items whose component could be added by data (item component patches, commands) or by other registration helpers outside `Items` were not searched. The 16 fire-resistant item names themselves were read by name (5.2).
3. Closed: `Mth.sin` and `Mth.cos` are documented in 11 (trigonometry paragraph) and referenced in 2.3 and 2.4.
4. Closed: `moveTowardsClosestSpace` is specified in section 3.4.
5. `Level.findSupportingBlock` tie-breaking for an item straddling several blocks (the choice of friction block) was not read; the nearest-to-centre rule is (inferred). The `getOnPos` use of the `mainSupportingBlockPos` Optional when present was read.
6. Closed: the accumulator weighting and the tracker pruning predicate (`Tracker.reset`) are read in section 3.2.
7. The order of entities returned by the level's entity lookup for the pickup loop and for `mergeWithNeighbours` is not specified here; implementations may choose any order, which changes which neighbour merges first.
8. Whether and when the death drop happens depends on the `keep_inventory` rule and the death handler; only `Inventory.dropAll` was read (equipment slots are dropped through `EntityEquipment.dropAll`, whose per-slot rules were not read).
9. Closed: the dispenser level events are 1000 (data 0) and 2000 (data = facing 3D data value), played by `dispense` after `execute` (section 2.5); `BlockSource.center` is `Vec3.atCenterOf(pos)` (read).
10. Moot: a partial survival transfer returns false and sends no Take Item Entity packet (4.2, 4.3). What remains untraced is how the remaining stack count is re-synced to clients after an in-place shrink (entity data tracking and `needsSync` handling in the server entity tracker).
11. `ItemEntity.merge` uses a literal 64 as the cap in one place and `areMergable` uses the item's own maximum; for items with a maximum above 64 (none are assumed) the interaction is unclear, and the exact "moved" count expression was read as `min(min(max, 64) - receiverCount, donorCount)`.
12. The pickup particle's drawing path is untraced: the particle class stores old and new target positions (new target Y is the midpoint of collector Y and eye Y, section 4.6) but the renderer that interpolates the item's flight from them was not read, so the flight path is not specified here.
13. Closed: base `Entity.ignoreExplosion` is false and the block-interaction values are read (5.4).
14. Closed: the renderer's vertical offset, copy counts, seed and copy offsets are read (section 7). Not read: the model bounding box values of individual items (data), and how `ItemStackRenderState.submit` draws a model.
15. The relative order of the item entity tick and the player tick within a server tick (decides on which tick the first pickup after the delay can happen) is determined by the level's entity tick order, which this document does not cover.
16. The `Entity.spawnAtLocation` callers for animals, shearing and similar are in 17 to 21 and were not enumerated here; each passes a y offset not listed in this document.
17. `Block.dropResources` ordering relative to `spawnAfterBreak` and the tool-specific loot context is in the loot engine documents (GAP-4), not here.
18. Drops from the open inventory screen (click outside, drop keys over a slot) go through container-click code in `AbstractContainerMenu` and related classes that was not read; whether they reach `ServerPlayer.drop(stack, true, ...)` with the same stats is inferred, not verified. The `drop` key in `handlePlayerAction` and the creative path (2.3.1) were read.
19. Block restitution call sites: the bed lambda's blocks were not enumerated by name; `BlockBehaviour.bounceOn` overrides in subclasses (a block that reacts to a bounce) were not searched. `Block.bounceOn` base does nothing.
20. The mob pickup path (`pickUpItem`, `canPickUpLoot`, villagers, allays, foxes) uses `playerTouch` equivalents and was not read here (see 18 and 19 for what exists); it also decrements stacks differently from `Inventory.add`.
