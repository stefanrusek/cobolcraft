# 44-9. Residual mob questions, part 9: End bosses, decoration entities, display entities, happy ghast

| Item | Value |
|---|---|
| Covers | Round RS26 part 9. Answers the open questions that 21 left for: the Ender Dragon phase hooks and the strafe path (21 Open question 12); lightning `thunderHit` effects, the area effect cloud application loop, armor stand interaction and pose rules, item frame, glow item frame and painting survival and placement, display entities (block, item, text), `interaction` and `marker` entities (21 Open question 13); the cushion survival check and mannequin rules (21 Open question 17); the happy ghast spawn path, feeding growth, harness identity, `HappyGhastFloatGoal` and `BabyFlyingPathNavigation` (21 Open question 19); the End mob items of 21 section 6 (shulker, shulker bullet, End city placement, End crystal item, enderman and endermite hand-off) and the Wither boss bar items of 21 section 7. Item pickup and throw delays are answered by 41 (section 13 below only points there). **Not covered by this part:** the "behaviour not read" rows and Open questions of 18, 19 and 20 are answered by other parts of 44 (the owners are named in section 12), so folding this part into 18 to 21 does not touch those rows. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of JSON data files inside the jar (tags, painting variants, loot tables), with no execution. Every value was read in this round. Values or statements that were not read are marked "(inferred)" or "(recalled, not verified)" and are listed in the Open questions. File counts use `unzip -Z1 <jar> \| grep -v "/$" \| grep -E <pattern> \| wc -l` (directory entries excluded). |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001; design README Parts 0, 1, 4; GAP-31). Data rows (tag members, painting variant sizes, loot tables, structure NBT) are not tabulated: the schema, the semantics and the engines that read them are given. Code-defined values (constants, shapes, algorithms) are complete. |
| Siblings | 18 mob framework; 20 and 21 (this document extends 21 sections 6, 7 and 8, and corrects one statement of 21 in section 11.2); 41 item entity; 44-3 villagers, POI, raids; 44-4 land animals; 44-5 overworld hostile, crossbow and warden; 44-6 piglin, hoglin, strider, ghast (`GhastMoveControl`); 44-7 aquatic and nautilus; 44-8 vehicles and projectiles (shulker bullet flight is given here because 21 section 6.2 owns the bullet). |

Class names in backticks say where a fact was read. They are not the design. Tick = 1/20 s. "21 section X" and "18 framework: X" refer to the existing documents. `f32` marks a float32 operation.

## Contents

1. [Ender Dragon phase hooks and strafe path](#1-ender-dragon-phase-hooks-and-strafe-path)
2. [Lightning: `thunderHit` effects](#2-lightning-thunderhit-effects)
3. [Area effect cloud application loop](#3-area-effect-cloud-application-loop)
4. [Armor stand](#4-armor-stand)
5. [Block-attached entities: item frame, glow item frame, painting](#5-block-attached-entities)
6. [Display entities](#6-display-entities)
7. [Interaction and marker entities](#7-interaction-and-marker-entities)
8. [Cushion and mannequin](#8-cushion-and-mannequin)
9. [Happy ghast](#9-happy-ghast)
10. [Wither boss bar items](#10-wither-boss-bar-items)
11. [End mob items: shulker, bullet, End city, End crystal, enderman, endermite](#11-end-mob-items)
12. [Appendix gaps of 21 section 8](#12-appendix-gaps-of-21-section-8)
13. [Item pickup and throw delays](#13-item-pickup-and-throw-delays)
14. [Worked examples](#14-worked-examples)
15. [Validation](#15-validation)
16. [Open questions](#16-open-questions)

## 1. Ender Dragon phase hooks and strafe path

### 1.1 The crystal-destroyed hook (`EnderDragon.onCrystalDestroyed`)

21 section 6.4 says "the hooks of the phases were not expanded". Read result: the abstract phase base class defines an empty `onCrystalDestroyed(crystal, pos, source, player)`; across all eleven phase classes **only HOLDING_PATTERN overrides it**. Every other phase (STRAFE_PLAYER, LANDING_APPROACH, LANDING, TAKEOFF, SITTING_FLAMING, SITTING_SCANNING, SITTING_ATTACKING, CHARGING_PLAYER, DYING, HOVERING) does nothing when a crystal dies.

Order inside `EnderDragon.onCrystalDestroyed(level, crystal, pos, source)`:

1. `player` = the damage source's entity when that is a `Player`; otherwise the nearest player to `pos` under `CRYSTAL_DESTROY_TARGETING` = combat targeting conditions (`forCombat`) with `range(64.0)` (so line of sight is required, and the usual combat filters apply: attackable, not creative or spectator).
2. If `crystal` is the dragon's remembered nearest crystal: `hurt(level, head, explosion(crystal, player), 10.0)` (the head part is hit, so full damage, no body divisor).
3. The current phase's hook is called with `(crystal, pos, source, player)`.

HOLDING_PATTERN hook: when `player` is not null and `dragon.canAttack(player)` (= `player.canBeSeenAsEnemy()`), call `strafePlayer(player)`; otherwise nothing. `strafePlayer(player)` sets the phase to STRAFE_PLAYER (`setPhase`, so `begin` of the strafe phase runs and clears its state) and then calls the strafe phase's `setTarget(player)`.

Net effect: destroying a crystal while the dragon circles makes it immediately dive at the player who did it (or the nearest one within 64 blocks); in any other phase the crystal's only effect is the 10 damage and the fight bookkeeping of 21 section 6.4.5.

### 1.2 Strafe target and path creation (`DragonStrafePlayerPhase.setTarget`)

Inputs: the player `P` (living entity). Steps:

1. `attackTarget = P`.
2. `startNode = findClosestNode()` (no arguments: nearest node to the dragon, 21 section 6.4.2 including the rule `s = 0` with a living crystal and `s = 12` without).
3. `goalNode = findClosestNode(P.x, P.y, P.z)` (nearest node to the player under the same `s`).
4. `bx = P.blockX`, `bz = P.blockZ`, `dist = sqrt((bx - dragon.x)^2 + (bz - dragon.z)^2)` (block coordinates of the player against the dragon's exact position).
5. `yOffset = min(0.4 + dist / 80 - 1, 10)` where `0.4` is the double `0.4000000059604645` (it is the float 0.4 widened).
6. `extra = Node(bx, floor(P.y + yOffset), bz)`.
7. `currentPath = findPath(startNode, goalNode, extra)` (A* of 21 section 6.4.2: the extra node is appended as the final goal). If the path is not null it is advanced once (`advance()`), then `navigateToNextPathNode()`.

`navigateToNextPathNode` (strafe version, identical in shape to the holding pattern's): if the path exists and is not done: take the next node position `(nx, ny, nz)`, advance the path, and set `targetLocation = (nx, ny + nextFloat * 20.0f, nz)` (one `nextFloat` per node; the pattern repeats until the sampled height is not below `ny`, which always holds on the first sample, so exactly one sample is taken). If the path is null or done the target location is left unchanged.

### 1.3 Strafe tick (`doServerTick`), complete order

1. If `attackTarget` is null: log, set the phase to HOLDING_PATTERN, return (this is the "no player" exit that 21 describes).
2. If `currentPath` is not null and `isDone()`: `targetLocation = (P.x, P.y + yOffset', P.z)` with `yOffset' = min(0.4 + h / 80 - 1, 10)` and `h` = the horizontal distance from the dragon to the player (exact coordinates this time).
3. `d2` = squared distance from the dragon to `targetLocation` (0 when `targetLocation` is null). If `d2 < 100` **or** `d2 > 22500`: `findNewTarget()`. Unlike the holding pattern there is **no collision test** in this condition.
4. Fireball logic with range constant `64.0` (squared: `4096`): if the player is within squared distance 4096 of the dragon:
   - if the dragon has line of sight to the player: `fireballCharge += 1`; `v1` = normalized `(P.x - dragon.x, 0, P.z - dragon.z)`; `v2` = normalized `(sin(yRot * 0.017453292f), 0, -cos(yRot * 0.017453292f))` using the table trigonometry of 21 section 6.4.2; `angle = acos(v2.v1) * 57.2957763671875 + 0.5` (the dot product narrowed to float, `acos` of the double); when `fireballCharge >= 5` and `0 <= angle < 10`: launch (below), then `fireballCharge = 0`, then the remaining path is skipped (`advance()` until done) and the phase becomes HOLDING_PATTERN.
   - no line of sight: `fireballCharge` decreases by 1 when positive.
   - farther than 64: `fireballCharge` decreases by 1 when positive.
   Launch: head position `H` = the head part position minus `1.0 * view` in x and z (view = `getViewVector(1.0)`), `H.y = head.getY(0.5) + 0.5`; direction vector = player `(x, getY(0.5), z)` minus `H`; world event 1017 at the dragon's block position unless silent; a `DragonFireball(level, dragon, normalized direction)` is placed at `H` with rotation (0, 0) and added to the level.

`findNewTarget` (strafe): if the path is null or done: `closest = findClosestNode()`; `n = closest`; with probability 1/8 (`nextInt(8) == 0`) toggle the phase's own `holdingPatternClockwise` flag and `n += 6`; then `n += 1` if clockwise else `n -= 1`; if the fight is null or has no living crystal: `n = ((n - 12) & 7) + 12`; else `n = n mod 12` (made non-negative by adding 12). `currentPath = findPath(closest, n, null)`; if not null `advance()`; `navigateToNextPathNode()`. If the path exists and is not done, `findNewTarget` does nothing beyond `navigateToNextPathNode`. The strafe phase's `holdingPatternClockwise` is a separate field from the holding pattern's; it starts false (phase instances are created once per dragon and `begin` does not reset the flag).

`begin` of the strafe phase clears `fireballCharge`, `targetLocation`, `currentPath` and `attackTarget`. `getFlyTargetLocation` returns `targetLocation` (the dragon's steering of 21 section 6.4.1 is unchanged). 21 section 6.4.3 already matches steps 1 to 4 in prose; this section adds the `setTarget` path, the node math and the unconditional re-pathing test.

## 2. Lightning: `thunderHit` effects

21 section 8.6 gives the bolt (every entity in the box gets `thunderHit(level, bolt)`). The method exists on `Entity` and is overridden by exactly these classes (found by scanning every class under the entity, block and item trees for the method):

| Class | Effect of `thunderHit(level, bolt)` |
|---|---|
| `Entity` (default, all entities without an override) | The fire rule of 2.1: `remainingFireTicks += 1`; if the new value is exactly 0, `igniteForSeconds(8.0)`; then `hurtServer(level, lightningBolt damage, 5.0)`. For an ordinary entity the bolt therefore gives a counter of 1 (no 8 second ignition) and the 5.0 damage |
| `ArmorStand`, `BlockAttachedEntity` (item frame, glow item frame, painting) | nothing |
| `Cushion` | when not removed: `kill`, then `dropItem(level, bolt)` (the drop gets 20 ticks of invulnerability because the cause is a lightning bolt, section 8.1) |
| `Creeper` | the `Monster`/`Entity` default above, then metadata `DATA_IS_POWERED` = true (index in 20 section 6) |
| `Pig` | when the difficulty is not Peaceful: convert to `zombified_piglin` (`convertTo`, `ConversionParams.single(mob, keepEquipment = false, preserveCanPickUpLoot = true)`); the converted mob gets `populateDefaultEquipmentSlots(random, difficulty at its position)` and `setPersistenceRequired()`. The `Animal` default (the `Entity` default above) runs only when the difficulty is Peaceful or when `convertTo` returns null; a successful conversion jumps over the super call, so the converted pig takes no 5.0 damage and no counter increment (read in `Pig.thunderHit`) |
| `Villager` | when the difficulty is not Peaceful: log "Villager {} was struck by lightning {}", convert to `witch` (`ConversionParams.single(mob, false, false)`); the witch gets `finalizeSpawn(level, difficulty at its position, CONVERSION, null)`, `setPersistenceRequired()`, and the villager releases all its points of interest (`releaseAllPois`). The `AbstractVillager` default runs only when the difficulty is Peaceful or when `convertTo` returns null; a successful conversion skips it (read in `Villager.thunderHit`) |
| `Turtle` | `hurtServer(level, lightningBolt damage, 3.4028235E38 (float max))`: instant death |
| `CopperGolem` | the `AbstractGolem` default, then: when the bolt's UUID differs from `lastLightningBoltUUID`, remember it; if the golem's weather state is not UNAFFECTED, set `nextWeatheringTick = -1` and set the weather state to the previous (less oxidised) state (one step per bolt, sync flag true) |
| `MushroomCow` | when the bolt's UUID differs from `lastLightningBoltUUID`: swap the variant (RED becomes BROWN, otherwise RED), remember the UUID, play `MOOSHROOM_CONVERT` (volume 2.0, pitch 1.0). No damage and no fire |

Damage type `lightning_bolt` (data): exhaustion 0.1, message id `lightningBolt`, scaling `when_caused_by_living_non_player`. `Creeper`, `CopperGolem`, and the `Pig` and `Villager` that were not converted (Peaceful, or conversion returned null) take the `Entity` default, hence the 5.0 damage; a converted pig or villager takes none. (`MushroomCow` does not call the default, as its row says.)

### 2.1 Fire counter semantics (`Entity.remainingFireTicks`)

Read in `Entity`; this is the one place the rule is stated, for folding into 18 framework once.

| Item | Rule |
|---|---|
| Resting value | 0 |
| Burning test | an entity burns only while the counter is above 0 |
| Per-tick (`baseTick`) | while burning: on-fire damage when `counter % 20 == 0` and the entity is not in lava, then the counter decreases by 1; otherwise `clearFire` runs |
| `clearFire` | sets the counter to `min(0, current)`, so a negative value survives |
| `igniteForSeconds(x)` | `igniteForTicks(floor(x * 20))`; `igniteForTicks(t)` only raises the counter (when it is below `t`) and clears freezing |
| `getFireImmuneTicks()` | 0 in `Entity`; `Player` overrides it |
| `thunderHit` default | counter += 1; ignition (`igniteForSeconds(8.0)`) only when the incremented value is 0, which needs a counter of -1 before the bolt; then 5.0 damage |

Example: a cow at counter 0 struck by a bolt gets counter 1 and takes 5.0; one burn tick later `counter % 20 != 0` so no fire damage, the counter drops to 0. Only an entity at counter -1 gets the 160-tick ignition.

## 3. Area effect cloud application loop

Class `AreaEffectCloud`, method `serverTick`, run once per server tick (the entity is `noPhysics`; `tick` calls `Entity.tick` then `serverTick` on the server). State: `duration` (default -1 = infinite), `waitTime` (default 20), `reapplicationDelay` (default 20), `durationOnUse` (default 0), `radiusOnUse` (default 0.0), `radiusPerTick` (default 0.0), `potionContents`, `potionDurationScale` (default 1.0), `victims` (map entity to expiry tick), `owner` (living entity reference). Bounding box: width `2 * radius`, height 0.5 (`getDimensions`). Steps, in order:

1. **Expiry.** If `duration != -1` and `tickCount - waitTime >= duration`: discard, stop.
2. **Waiting.** `waiting = tickCount < waitTime`. When this differs from the synced flag, update metadata index 9. If waiting: stop (no radius change, no application).
3. **Radius per tick.** `r = radius`. If `radiusPerTick != 0`: `r += radiusPerTick`; if `r < 0.5` discard and stop; else `setRadius(r)`.
4. **Application tick** only when `tickCount % 5 == 0` (`TIME_BETWEEN_APPLICATIONS`):
   a. Remove every `victims` entry whose expiry `value <= tickCount` (the predicate is `tickCount >= value`).
   b. If the potion contents have no effects: clear `victims` and stop this step.
   c. Build the effect list from the contents with `potionDurationScale` applied to each effect's duration (`forEachEffect(consumer, scale)`).
   d. `candidates` = living entities (`LivingEntity`) whose box intersects the cloud's bounding box. If the list is empty, stop.
   e. For each candidate in list order: skip when it is already in `victims`; skip when `isAffectedByPotions()` is false; skip when **none** of the listed effects can affect it (`canBeAffected(effect)`). Compute `dx, dz` from the cloud centre to the entity position (horizontal only; the vertical limit is the box); if `dx*dx + dz*dz > r*r` (with the current local `r`, float squared widened) skip. Otherwise:
      - `victims[entity] = tickCount + reapplicationDelay`.
      - For each effect in the list: if the effect is instantaneous: `applyInstantaneousEffect(level, cloud, owner, victim, amplifier, 0.5)`; else `victim.addEffect(copy of the effect, cause = cloud)` (a fresh copy, so durations are per application).
      - If `radiusOnUse != 0`: `r += radiusOnUse`; if `r < 0.5` discard and stop; else `setRadius(r)`. (The shrinking therefore applies per victim hit and changes the range test of later candidates in the same pass.)
      - If `durationOnUse != 0` and `duration != -1`: `duration += durationOnUse`; if `duration <= 0` discard and stop.

Instant effect arithmetic (`HealOrHarmMobEffect.applyInstantaneousEffect`, used by `instant_damage` and `instant_health`; `scale` = the 0.5 passed above): let `harm` be the effect's own kind and `inverted = victim.isInvertedHealAndHarm()` (undead).
- If `harm == inverted` (healing a normal mob with instant health, or harming-effect on an inverted mob): heal `int(scale * (4 << amplifier) + 0.5)`.
- Otherwise: damage `int(scale * (6 << amplifier) + 0.5)` with damage source `indirectMagic(cloud, owner)`. The null test in `applyInstantaneousEffect` is on the direct source argument (the cloud): a null cloud would give plain `magic` damage; otherwise `indirectMagic(cloud, owner)` is used and `owner` itself may be null. The cloud is always passed here, so `indirectMagic` is always used.
With scale 0.5: amplifier 0 harm = `int(3.5)` = 3, amplifier 1 harm = `int(6.5)` = 6; amplifier 0 heal = `int(2.5)` = 2, amplifier 1 heal = `int(4.5)` = 4. (The non-scaled `applyEffectTick` path used for ordinary potion drinking is `6 << amplifier` damage and `max(4 << amplifier, 0)` heal; it is not used by clouds.)

Users: the dragon's breath cloud (21 section 6.4.3): radius 5, duration 200, scale 0.25, instant damage amplifier 0 and default duration; with the 20-tick wait and the 20-tick reapplication delay a player standing in it takes 3 damage at `tickCount % 5 == 0` ticks spaced 20 apart, from `tickCount = 20` to `tickCount < 220`: 10 applications at most. The dragon fireball cloud (`DragonFireball.onHit`, read in this round; the fireball is ignored when the entity it hit is its owner): on the server, the living entities in the fireball's box inflated by (4, 2, 4) are collected; a cloud is created at the fireball position with the fireball's owner (when a living entity) as owner, custom particle `dragon_breath` (power 1.0), radius 3.0, duration 600, `radiusPerTick = (7.0 - radius) / duration` (= 4/600 per tick, so the radius grows after the 20-tick wait), `potionDurationScale` 0.25 and one `instant_damage` effect with duration 1 and amplifier 1 (6 damage per hit, 20 ticks apart). Then, for the first collected entity (list order) whose squared distance to the fireball is below 16.0, the cloud is moved to that entity's position and the search stops. World event 2006 is sent at the fireball's block position (data -1 when the fireball is silent, else 1), the cloud is added to the level and the fireball is discarded. The dragon's breath cloud and the other cloud users (lingering potion, tipped arrow) are owned by 21 section 6.4.3 and 44-8 respectively.

## 4. Armor stand

### 4.1 Constants and metadata

Type `armor_stand` 0.5 x 1.975 (eye 1.7775), range 10, builder constants of 21 section 8.9; attributes `createLivingAttributes()` plus `STEP_HEIGHT = 0` (living defaults: 18 framework). Metadata index 15 = client flags: bit 1 small, bit 4 show arms, bit 8 no base plate, bit 16 marker; 16 head pose, 17 body, 18 left arm, 19 right arm, 20 left leg, 21 right leg (Rotations, three float32 per pose; 00 section 13). Defaults: head (0, 0, 0), body (0, 0, 0), left arm (-10, 0, -10), right arm (-15, 0, 10), left leg (-1, 0, -1), right leg (1, 0, 1) (degrees) (read: the six `DEFAULT_*_POSE` constants built in the `ArmorStand` static initialiser, each as three float constants x, y, z). A `Rotations` value is normalised on construction: each component that is NaN or infinite becomes 0, then each is reduced with the float remainder `% 360.0` (the sign is kept, so -370 becomes -10 and 365 becomes 5).

Dimensions: `getDefaultDimensions`: marker = fixed 0 x 0; small (`isBaby() = isSmall`) = the type dimensions scaled by 0.5 with eye height 0.9875; otherwise the type dimensions. `disabledSlots` (int, default 0): bit `id` disables the slot completely, bit `id + 8` disables taking, bit `id + 16` disables putting, where the slot ids are MAINHAND 0, FEET 1, LEGS 2, CHEST 3, HEAD 4, OFFHAND 5, BODY 6, SADDLE 7 (`EquipmentSlot.getFilterBit(offset) = id + offset`).

NBT: `Invisible`, `Small`, `ShowArms`, `NoBasePlate`, `Marker` (booleans, default false), `DisabledSlots` (int, default 0), `Pose` (compound with `Head`, `Body`, `LeftArm`, `RightArm`, `LeftLeg`, `RightLeg`, each a list of 3 floats). Reading `Marker` also sets `noPhysics = marker`.

Physics and flags: `hasPhysics = !marker && !noGravity`; the stand only travels (`travel`) and runs effective AI when it has physics. Not pushable, `doPush` does nothing; each tick `pushEntities` pushes every entity of the "ridable minecart" predicate (minecart entities that can be ridden) in its box when the squared distance is at most 0.2. `attackable()` is false. `isPickable` = living default and not marker. `getPistonPushReaction` = IGNORE_ENTITY for a marker. Marker also ignores block triggers (`isIgnoringBlockTriggers`). Main arm is RIGHT. `canUseSlot(slot)` is true unless the slot is BODY, SADDLE or disabled (disabled = bit `id` set, or a hand slot while arms are hidden). `ignoreExplosion(explosion)`: if the explosion affects block-like entities, the stand is ignored only while invisible; otherwise always ignored. `thunderHit`: nothing. Body and head rotation are slaved to the entity yaw (`tickHeadTurn`, `setYBodyRot` and `setYHeadRot` copy it).

### 4.2 Placement (`ArmorStandItem.useOn`)

1. Clicked face DOWN: FAIL.
2. `pos` = the placement position of `BlockPlaceContext` (the clicked block when it is replaceable, otherwise the neighbour on the clicked face). `box` = armor stand type dimensions' box at the bottom centre of `pos`.
3. `level.noCollision(null, box)` must hold and no entity may intersect `box`, else FAIL.
4. On the server: create the entity with the item's data components and `SPAWN_ITEM_USE`; yaw = `floor((wrapDegrees(playerYaw - 180) + 22.5) / 45) * 45` (a multiple of 45 degrees, floats), pitch 0, snap to the entity position; add with passengers; play `ARMOR_STAND_PLACE` (BLOCKS, volume 0.75, pitch 0.8); `ENTITY_PLACE` game event; consume 1 item; SUCCESS.

### 4.3 Interaction (`ArmorStand.interact(player, hand, hitVec)`)

`hitVec` is the click point relative to the entity position. Let `held` = the item in `hand`.

1. If the stand is a marker or `held` is a name tag: the `LivingEntity` default interaction (leashes, name tags: 18 framework).
2. Spectator: SUCCESS (no change). Client side: SUCCESS_SERVER (the server decides).
3. `itemSlot = getEquipmentSlotForItem(held)`: the slot of the held item's `equippable` component if the stand can use that slot, otherwise (inferred) main hand.
4. **Empty hand:** `clicked = getClickedSlot(hitVec)`; `slot = isDisabled(clicked) ? itemSlot : clicked` (for an empty hand `itemSlot` is main hand). If the stand has an item in `slot` and `swapItem(player, slot, held, hand)` succeeds: SUCCESS_SERVER.
5. **Non-empty hand:** if `isDisabled(itemSlot)`: FAIL. If `itemSlot` is a hand slot and the stand does not show arms: FAIL. If `swapItem(player, itemSlot, held, hand)` succeeds: SUCCESS_SERVER.
6. Otherwise the `LivingEntity` default interaction.

`isDisabled(slot)`: bit `id` of `disabledSlots` is set, or the slot is a hand slot and `showArms` is false.

`getClickedSlot(hitVec)`: `y = hitVec.y / (getScale() * getAgeScale())` (age scale 0.5 when small, else 1). `small` = the stand's small flag. Candidate order, first match wins, default MAINHAND:

| Order | Slot | Test (`y` bounds, and the stand must hold an item in the slot) |
|---|---|---|
| 1 | FEET | `y >= 0.1` and `y < 0.1 + (small ? 0.8 : 0.45)` |
| 2 | CHEST | `y >= 0.9 + (small ? 0.3 : 0)` and `y < 0.9 + (small ? 1.0 : 0.7)` |
| 3 | LEGS | `y >= 0.4` and `y < 0.4 + (small ? 1.0 : 0.8)` |
| 4 | HEAD | `y >= 1.6` |
| 5 | (fallback) | MAINHAND; but when the main hand is empty and the offhand holds an item: OFFHAND |

`swapItem(player, slot, stack, hand)` (the item currently in the slot is `cur`):

1. If `cur` is not empty and bit `slot.id + 8` (taking) is set: false.
2. If `cur` is empty and bit `slot.id + 16` (putting) is set: false.
3. If the player has infinite materials and `cur` is empty and `stack` is not empty: put a copy of count 1 of `stack` in the slot; true (nothing is consumed).
4. If `stack` is not empty and its count is above 1: if `cur` is not empty return false; else split one item off `stack` into the slot; true.
5. Otherwise put `stack` (whole, count at most 1 here) into the slot and give the player `cur` in `hand` (a swap, also when `stack` is empty: the player takes the item); true.

### 4.4 Damage and breaking (`hurtServer`, in order)

1. Removed: false.
2. When the `mob_griefing` rule is false and the attacker is a `Mob`: false.
3. Damage type in tag `bypasses_invulnerability`: `kill(attacker)`; false.
4. Invulnerable to the source, or invisible, or marker: false.
5. Tag `is_explosion`: `brokenByAnything`, `kill`; false.
6. Tag `ignites_armor_stands`: if already on fire `causeDamage(0.15)` else `igniteForSeconds(5.0)`; false.
7. Tag `burns_armor_stands` and `health > 0.5`: `causeDamage(4.0)`; false.
8. `canBreak` = tag `can_break_armor_stand`; `alwaysKills` = tag `always_kills_armor_stands`. Neither: false.
9. Attacker is a `Player` whose abilities forbid building (`mayBuild` false): false.
10. Creative-player source: break sound, break particles, `kill`; true (no item drops).
11. Let `diff = gameTime - lastHit`. If `diff <= 5` or `alwaysKills`: `brokenByPlayer`, particles, `kill`; true. Otherwise broadcast entity event 32 (wobble; the client uses `WOBBLE_TIME` 5), `ENTITY_DAMAGE` game event, `lastHit = gameTime`; true. So a normal stand breaks on the second hit that comes within 5 ticks of the first.

`causeDamage(amount)`: `h = health - amount`; if `h <= 0.5`: `brokenByAnything`, `kill`; else `setHealth(h)` and an `ENTITY_DAMAGE` game event.

`brokenByPlayer`: pop a new `armor_stand` item (carrying the entity's custom name as the item's `custom_name` component) at the stand's block position (`Block.popResource`), then `brokenByAnything`. `brokenByAnything`: break sound (`ARMOR_STAND_BREAK`, volume 1, pitch 1); `dropAllDeathLoot` (the entity loot table `entities/armor_stand` has no pools; `LivingEntity.dropEquipment` is empty here); then for every equipment slot: remove the stack and, when it is non-empty and not enchanted with `prevent_equipment_drop`, pop it at the block position one above. The enchantment effect `prevent_equipment_drop` is carried (in data) only by `vanishing_curse`; the code that consults it is `ArmorStand` (here), `Mob.dropCustomDeathLoot`, `Allay.dropEquipment`, `AbstractHorse.dropEquipment` and `Player.destroyVanishingCursedItems` (found by searching every class of the jar for the constant, and every data file for the string). `kill` removes the entity with reason KILLED and fires the `ENTITY_DIE` game event.

## 5. Block-attached entities

### 5.1 `BlockAttachedEntity` (base of `HangingEntity`, which is the base of the item frame types and the painting; `LeashFenceKnotEntity` is a sibling, 21 section 8.15)

- NBT `block_pos` (a block position; on load it is accepted only when within 16 blocks of the entity's block position, otherwise an error is logged and the stored position is kept as constructed).
- **Check interval:** on the server every tick `ticksSinceLastCheck += 1` (and `checkBelowWorld`); at 100 it resets to 0, `tickAtCheckInterval()` runs (empty for hanging entities; the cushion overrides it, section 8) and then, if the entity is not removed and `survives()` is false: `discard` and `dropItem(level, null)`.
- `move(type, delta)`: on the server, if the entity is not removed and `delta.lengthSqr() > 0`: `kill` and `dropItem(level, null)`. `push(x, y, z)`: same test on the squared magnitude. (Item frames that are `fixed` ignore both.)
- `hurtServer`: invulnerable to base: false; `mob_griefing` false and the attacker is a `Mob`: false; when not removed: `kill(attacker)`, `markHurt`, `dropItem(level, attacker)`; return true. `hurtClient` = not invulnerable.
- `ignoreExplosion(explosion)`: true when the explosion's direct source entity is in water; else when the explosion affects block-like entities the entity default applies; else true.
- `skipAttackInteraction(entity)`: for a player: true when the level forbids the player to interact at `pos`, otherwise it attacks with `playerAttack` damage amount 0 and returns that result; non-player: false.
- `thunderHit` and `refreshDimensions`: nothing. `setPos` recomputes `pos = BlockPos.containing(x, y, z)` and the box. `isPickable` true.

### 5.2 `HangingEntity`

Metadata index 8 = direction (Direction; default SOUTH). `setDirection(d)` requires a horizontal axis (the base class), sets metadata and yaw `d.get2DDataValue() * 90`. `recalculateBoundingBox`: box = `calculateBoundingBox(pos, direction)`; the position is set to the box centre.

**Survival (`survives`, base rule used by the painting):** all of
1. `hasLevelCollision(popBox)` is false (`popBox` = the bounding box; true when `noBlockCollision` or `noBorderCollision` fails);
2. every block in the *support box* satisfies `isSupportingBlock` = `isSolid()` or a diode (repeater or comparator); the support box = the bounding box moved by `-0.5 * directionStep` and deflated by `1.0E-7`;
3. `canCoexist(false)`: no other `HangingEntity` in the pop box conflicts. A conflict is another entity `e` (not `this`) with `(type(e) == type(this) and the parameter ignoreType is false) or direction(e) == direction(this)`.

`spawnAtLocation(stack, yOffset)` for drops: an item entity at `x + stepX * 0.15`, `y + yOffset`, `z + stepZ * 0.15` with the default pickup delay (10, 41 section 2), added to the level. `mirror(mirror)` (read): `rotate(mirror.getRotation(direction))` (the mirror is converted to the rotation of the current direction and the result is the yaw returned by `rotate`). `rotate(rotation)` (structure placement and `/` rotation): for horizontal directions turns the direction (180: opposite, 90 counter-clockwise: counter-clockwise, 270: clockwise) and returns the yaw plus 180, 90 or 270 respectively.

### 5.3 Item frame and glow item frame (`ItemFrame`, `GlowItemFrame`)

Constants: depth `0.0625`, size `0.75` (1.0 while it holds a map), 8 rotations, edge constant `0.46875`, default drop chance 1.0. Metadata 8 direction (inherited), 9 item stack, 10 rotation (VarInt, stored `value % 8`). NBT: `Item` (stack), `ItemRotation` (byte, default 0), `ItemDropChance` (float, default 1.0), `Facing` (legacy direction id, 0 to 5), `Invisible` (default false), `Fixed` (default false). A new frame has `invisible = false` and `dropChance = 1.0`. The glow frame differs only in its sounds, its item stack and its name (`glow_item_frame`).

**Direction:** vertical directions are allowed for frames: yaw 0 and pitch `-90 * axisDirectionStep` (up frames face up with pitch -90, down frames pitch +90); horizontal: pitch 0, yaw `get2DDataValue * 90`.

**Box (`createBoundingBox(pos, d, withMap)`):** centre = block centre moved `-0.46875` along `d`; `w` and `h` = 1.0 when `withMap`, else 0.75; the box sizes are `(depth on the axis of d, else w for x or z and h for y)`, precisely: size X = 0.0625 if the axis is X else `w`; size Y = 0.0625 if the axis is Y else `h`; size Z = 0.0625 if the axis is Z else `w`. The pop box is the same box with `withMap = false`.

**Survival:** a `fixed` frame always survives. Otherwise: no level collision in the pop box; the block behind (`pos` moved by the opposite of the direction) is solid, or the direction is horizontal and that block is a diode; and `canCoexist(true)` (only same-direction hanging entities conflict, the type rule is skipped). Placement (`HangingEntityItem.useOn`): `target = clickedPos.relative(clickedFace)`; `mayPlace` requires the clicked face not to be vertical (so the item places frames and paintings only on side faces; the entity class itself accepts up and down for commands and structures) and `player.mayUseItemAt(target, face, stack)`, else FAIL. The entity is created with direction = clicked face (a painting through `Painting.create`, 5.4; for a painting that returns empty the result is CONSUME), the item's data components are applied, and it is added only when `survives()` holds (else CONSUME with no change); on success the placement sound plays, `ENTITY_PLACE` fires at the entity position, 1 item is consumed, SUCCESS.

**Interaction:** let `a` = the frame holds an item, `b` = the player's hand holds an item. `fixed`: PASS. Client: SUCCESS when `a or b`, else PASS. Server: if not `a`: when `b` and the frame is not removed: if the held item is a filled map whose saved data tracks 256 or more players (`isTrackedCountOverLimit(256)`): FAIL; else `setItem(held copy)` (stored with count 1, add-item sound, comparators updated), `BLOCK_CHANGE` game event, consume 1 from the hand, SUCCESS; otherwise PASS. If `a`: play the rotate sound, `setRotation(rotation + 1)` (mod 8, comparators updated), `BLOCK_CHANGE`, SUCCESS (the item is not taken by a use click; it is dropped by hitting).

**Damage (`hurtServer`):** `fixed`: only damage in tag `bypasses_invulnerability` or from a creative player is passed to the base damage (then true); otherwise false. Not fixed: invulnerable to base: false; if the damage is not an explosion and the frame holds an item: `dropItem(level, attacker, dropSelf = false)` (the item only), `BLOCK_CHANGE` game event, play the remove-item sound, true; else the base rule of 5.1 (kill and drop). `dropItem(level, entity, dropSelf)`: fixed: return; take the item and empty the frame; if the `entity_drops` rule is false: only when `entity == null` forget the map and return (otherwise nothing); a creative-mode attacker (infinite materials) only forgets the map; else when `dropSelf`: spawn the frame item (with its data components) at `spawnAtLocation`; if the taken item is non-empty: copy it, forget the framed map, and spawn it when `nextFloat() < dropChance`. Break (`kill`/`dropItem(level, entity)`): play the break sound, `dropItem(…, true)`, `BLOCK_CHANGE` game event.

**Redstone:** the comparator output of a frame is 0 when empty, else `(rotation % 8) + 1` (1 to 8).

**Rendered item yaw (client only; for 12 client rendering).** `getVisualRotationYInDegrees` returns, as a float, the integer `wrapDegrees(180 + 90 * d2 + 45 * rotation + v)` where `d2` is the direction's 2D data value (SOUTH 0, WEST 1, NORTH 2, EAST 3, UP and DOWN -1), `v` is 0 for horizontal frames and `90 * axisStep` for vertical ones (UP +1, DOWN -1), and `wrapDegrees` reduces the integer remainder by 360 into the range -180 to 179 (a value of 180 or more has 360 subtracted). Values for rotation 0 (add 45 per rotation step, then wrap):

| Direction | Sum before wrap | Yaw |
|---|---|---|
| SOUTH | 180 | -180 |
| WEST | 270 | -90 |
| NORTH | 360 | 0 |
| EAST | 450 | 90 |
| UP | 180 - 90 + 90 = 180 | -180 |
| DOWN | 180 - 90 - 90 = 0 | 0 |

Example: a SOUTH frame at rotation 3 gives `180 + 135 = 315`, wrapped to -45.

### 5.4 Painting (`Painting`)

Type `painting`, 0.5 x 0.5 builder, range 10. Metadata 8 direction (inherited), 9 variant (Holder of a painting variant, 00 section 10.2). NBT: `facing` (legacy 2D id, default SOUTH), `block_pos`, and the variant (written/read through the variant helper under the key of the registry's variant field: `variant`, a registry key). Data schema of a variant file (`data/minecraft/painting_variant/*.json`, 51 files in this jar): `asset_id`, `width` (blocks), `height` (blocks), optional `title` and `author` text components; the engine uses `area = width * height`. The tag `painting_variant/placeable` (47 entries in this jar) lists the variants chosen on placement.

**Placement (`Painting.create(level, pos, direction)`):** candidates = all variants in the placeable tag (tag order). If none: empty (the item action then returns CONSUME). Create the entity, set its direction, then repeat: keep only variants for which `setVariant(v)` makes `survives()` true (each candidate is installed in turn on the entity, the box and the pop box change with it); if none: empty. `maxArea` = the largest `area` among the survivors; remove survivors with `area < maxArea`; pick one uniformly at random (`Util.getRandomSafe(list, entity.random)`, so `nextInt(size)` of the painting's own random source); set the variant, set the direction again, return it. Order in `HangingEntityItem.useOn` for a painting (read): (1) `Painting.create(level, pos, face)` always runs first, including the placeable-tag and `survives()` filtering above; if it returns empty the result is CONSUME **even when the item carries a `PAINTING_VARIANT` component**; (2) only then is `createDefaultStackConfig` applied to the created entity, which is where the item's variant overrides the random pick; (3) `survives()` is checked again and the entity is added only when it holds (else CONSUME). Survivors are tried with the *placement direction already set*, which matters because the box depends on the direction.

**Box (`calculateBoundingBox`):** `w = variant.width`, `h = variant.height`; `offW = (w % 2 == 0) ? 0.5 : 0` and `offH = (h % 2 == 0) ? 0.5 : 0`; centre = block centre moved `-0.46875` along the direction, then moved by `offW` along the **counter-clockwise** direction (`d.getCounterClockWise()`) and by `offH` upward; box size = (X: `0.0625` if the axis is X else `w`, Y: `h`, Z: `0.0625` if the axis is Z else `w`). `trackingPosition` = the lower corner of `pos`. `snapTo` = `setPos` (rotation ignored).

**Survival:** the `HangingEntity` rule of 5.2 on this box (so every block behind the whole painting area must be solid or a diode, and the area must be free of collisions and of other hanging entities of the same type or direction).

**Drop:** `dropItem`: nothing when `entity_drops` is false; break sound; a creative attacker gets nothing; else a `painting` item with the entity's custom name is spawned (the variant is not stored in the dropped item). `getPickResult` = a `painting` item.

## 6. Display entities

Types `block_display`, `item_display`, `text_display` (21 section 8.9 and Appendix A list the indices; this section gives defaults, rules and the interpolation engine).

### 6.1 Common fields (class `Display`)

| Index | Field | Serializer | Default | NBT key | Notes |
|---|---|---|---|---|---|
| 8 | transformation interpolation start delta ticks | VarInt | 0 | `start_interpolation` | ticks to wait after a data change before the interpolation starts |
| 9 | transformation interpolation duration | VarInt | 0 | `interpolation_duration` | ticks the interpolation takes; 0 = immediate |
| 10 | position and rotation interpolation duration | VarInt | 0 | `teleport_duration` | read back clamped to 0 to 59; drives the entity's position interpolation (`LinearInterpolationHandler.setInterpolationLength`) |
| 11 | translation | Vector3 | (0, 0, 0) | inside `transformation` | |
| 12 | scale | Vector3 | (1, 1, 1) | inside `transformation` | |
| 13 | left rotation | Quaternion | identity | inside `transformation` | |
| 14 | right rotation | Quaternion | identity | inside `transformation` | |
| 15 | billboard constraints | Byte | 0 | `billboard` | ids: 0 `fixed`, 1 `vertical`, 2 `horizontal`, 3 `center` |
| 16 | brightness override | VarInt (packed) | -1 | `brightness` | -1 = none |
| 17 | view range | Float | 1.0 | `view_range` | |
| 18 | shadow radius | Float | 0.0 | `shadow_radius` | |
| 19 | shadow strength | Float | 1.0 | `shadow_strength` | |
| 20 | width | Float | 0.0 | `width` | culling box width |
| 21 | height | Float | 0.0 | `height` | culling box height |
| 22 | glow colour override | VarInt | -1 | `glow_color_override` | -1 = none; when set it replaces the team colour |

The metadata ids follow the order of the static declarations (the order used in Appendix A). The `transformation` NBT (a codec for a 4x4-equivalent `Transformation` with `translation`, `left_rotation`, `scale`, `right_rotation`) is decomposed into the four metadata fields on load (`setTransformation`); the entity shows `translation`, then `left_rotation`, then `scale`, then `right_rotation` composed as one affine transform in that order (the `Transformation` constructor argument order). `hurtServer` always returns false (displays cannot be damaged). Piston reaction IGNORE_ENTITY and `isIgnoringBlockTriggers` true (read). The entity is `noLootTable`, range 10, update interval 1.

**Tracking and culling:** the renderer shows the entity only when the squared distance is below `(viewRange * 64 * viewScale)^2` (`shouldRenderAtSqrDistance`; `viewScale` is the client's entity distance scaling option). Culling box (`updateCulling`, re-run on width, height or position changes): `noCulling = (width == 0 or height == 0)`; otherwise box from `(x - w/2, y, z - w/2)` to `(x + w/2, y + h, z + w/2)`. The interpolated box for rendering is that box shifted by `lerp(partial, old, current) - current` per axis (it is returned unshifted when the entity did not move this tick).

### 6.2 Interpolation (client engine; the server only stores the fields)

Client state: `interpolationStartClientTick`, `interpolationDuration`, `lastProgress`, `renderState` (the current interpolated state). Rules (`Display.tick` on the client, in this order each tick):

1. If the start-delta field changed since the last tick: `interpolationStartClientTick = tickCount + startDelta` (read now).
2. If the duration field changed: `interpolationDuration = duration` (read now).
3. If any render-state field changed (the set `RENDER_STATE_IDS` holds the metadata ids of translation, scale, left rotation, right rotation, billboard, brightness override, shadow radius and shadow strength; the start delta, duration, view range, width, height and glow colour fields are not in it): when a render state exists and `interpolationDuration != 0`, a new state is created *from the current interpolated state at `lastProgress`* (translation and rotations by `Transformation.slerp`, shadow radius and strength linearly) as `previous`, with the new field values as `current`; with a zero duration (or no previous state) a fresh state with constant values is made. Then `updateRenderSubState(interpolating, lastProgress)` lets the subtype refresh its own state (the text display has its own id set `TEXT_RENDER_STATE_IDS`, see 6.3).

Progress for rendering at partial tick `pt` (`calculateInterpolationProgress`): if `interpolationDuration <= 0` then 1.0; else `p = clamp((tickCount - interpolationStartClientTick + pt) / interpolationDuration, 0, 1)` (`inverseLerp(x, 0, duration)` then clamp), stored as `lastProgress`.

### 6.2.1 Position and rotation interpolation (`teleport_duration`)

Client only (the server-side interpolation handler is a no-op: `LinearInterpolationHandler.create` returns the no-op handler on a server level). The display entity creates a `LinearInterpolationHandler` with an initial length of 0; whenever metadata 10 changes, `setInterpolationLength(teleport_duration)` is applied (0 to 59 after the NBT clamp). Steps for a received target position and rotation (`interpolateTo(path, yaw, pitch)`, read):

1. If the length is 0: `snapTo(target position, yaw, pitch)` at once and cancel any interpolation.
2. If an interpolation is already active and its stored target equals the new target (position, yaw and pitch): nothing.
3. Otherwise store the target and set `remainingSteps = length`.
Each client tick while `remainingSteps > 0`: `t = 1.0 / remainingSteps` (double), the entity's position becomes `lerp(current position, target position, t)`, yaw `rotLerp(t, current yaw, target yaw)` (shortest-arc), pitch `lerp(t, current pitch, target pitch)`; then `remainingSteps` decreases by 1. When it reaches 0 the entity sits exactly on the target (at the last step `t = 1`). Movement deltas that arrive during an interpolation shift the stored target (`adjustInterpolationTargetFromDeltas`, applied when the entity moved by more than `9.999999747378752E-6` squared blocks since the previous tick). The default handler step count for entities that do not set it is 3 (`DEFAULT_INTERPOLATION_STEPS`); the shulker uses the no-op handler on both sides (11.2).

Example: `teleport_duration` 4, entity at x = 0, target x = 8: tick 1 `t = 1/4`: x = 2; tick 2 `t = 1/3`: x = 2 + 6/3 = 4; tick 3 `t = 1/2`: x = 6; tick 4 `t = 1`: x = 8.

Blend functions: `Transformation.slerp(other, t)`: translation and scale by vector lerp, left and right rotation by quaternion slerp (four independent parts, not a matrix interpolation). Floats by `Mth.lerp`; integers by `Mth.lerpInt` (text opacity); colours by `ARGB.srgbLerp` (text background). Constant interpolators ignore the progress.

### 6.3 Subtypes

- `block_display`: metadata 23 block state (default air), NBT `block_state` (block state compound); render state holds the state; changing it replaces the state at once (no interpolation of the state itself).
- `item_display`: metadata 23 item stack (default empty), 24 item display context byte, NBT `item` and `item_display`. Context ids: 0 `none`, 1 `thirdperson_lefthand`, 2 `thirdperson_righthand`, 3 `firstperson_lefthand`, 4 `firstperson_righthand`, 5 `head`, 6 `gui`, 7 `ground`, 8 `fixed`, 9 `on_shelf`. The item display also exposes slot 0 to commands (`SlotAccess`).
- `text_display`: metadata 23 text component (default empty), 24 line width (VarInt, default 200), 25 background colour (VarInt ARGB, default 1073741824 = 0x40000000), 26 text opacity (Byte, default -1 = 255), 27 style flags (Byte, default 0): bit 1 shadow, bit 2 see-through, bit 4 default background, bit 8 align left, bit 16 align right (neither = centre; `getAlign` tests bit 8 first, then 16). NBT: `text`, `line_width`, `text_opacity` (byte), `background` (int), `shadow`, `see_through`, `default_background` (booleans), `alignment` (`left`, `right`, `center`). The `text` is **resolved on the server at load** (`ComponentUtils.resolve` with a command source of the entity's position at permission level game-master-equivalent `Permissions`; selectors and scores are replaced by text); a parse failure logs "Failed to parse display entity text {}" and stores the empty text. Text opacity and background interpolate (`LinearIntInterpolator`, `ColorInterpolator`); text and line width do not. `TEXT_RENDER_STATE_IDS` (read) = the metadata ids of the text, the line width, the background colour, the text opacity and the style flags (five ids); a change to any of them sets the update-render-state flag (the common `RENDER_STATE_IDS` of 6.2 are handled by `Display`). The fresh text render state is built from the text, the line width, a constant opacity interpolator, a constant background interpolator and the style flags byte; the interpolated one blends background (`srgbLerp`) and opacity (`lerpInt`) only. Splitting into lines (`cacheDisplay` with a `LineSplitter(text, lineWidth)`, an interface the client renderer supplies) is client-only: the cache is created on first use from the current render state (an empty list with width 0 when there is no render state) and is dropped whenever the render state is rebuilt.

## 7. Interaction and marker entities

**`interaction`** (class `Interaction`): metadata 8 width (Float, default 1.0), 9 height (Float, default 1.0), 10 response (Boolean, default false). Dimensions: `EntityDimensions.scalable(width, height)` (so the box is `width` wide and `height` tall from the feet; changes to width or height refresh the dimensions). NBT: `width`, `height`, `response`, and two optional records `attack` and `interaction`, each `{player: UUID, timestamp: long}` (the last player to attack or interact and the game time).

Behaviour: `isPickable` true; `canBeHitByProjectile` false; `getPistonPushReaction` IGNORE_ENTITY; ignores block triggers; `hurtServer` always false; `tick` nothing; `getLastAttacker` and `getTarget` resolve the stored player UUIDs to online players (so `execute` selectors can read them).
- **Attack** (`skipAttackInteraction(attacker)`): for a player: `attack = {uuid, level game time}`; for a server player the `player_hurt_entity` advancement trigger fires with the generic damage source, amount dealt 1.0, amount taken 1.0, not blocked; the method returns `!response` (true = the normal attack is skipped when `response` is false; when `response` is true the attack proceeds as an attack on an unresponsive entity). A non-player attacker: false.
- **Use** (`interact`): client: SUCCESS when `response` else CONSUME; server: `interaction = {uuid, game time}`; CONSUME.

**`marker`** (class `Marker`): no metadata of its own, tracking range 0 (21 section 8.9); `tick` is empty; never sent to clients (building its add packet throws "Markers should never be sent"); `canAddPassenger` false and `addPassenger` throws; `hurtServer` false; piston reaction IGNORE_ENTITY; ignores block triggers; NBT reads and writes nothing beyond the base entity (the free-form `data` of commands is the generic entity NBT merge, 15/16). Size 0 x 0.

## 8. Cushion and mannequin

### 8.1 Cushion

`Cushion` is a `BlockAttachedEntity` (section 5.1) with metadata 8 = colour (dye; default WHITE), NBT `color` (the dye's string name) plus `block_pos`. Size 1.0 x 0.25 (21 section 8.16); `recalculateBoundingBox` = the plain `makeBoundingBox` from the type dimensions at the entity position. `setPos` sets the raw position and then the base logic.

**Survival check.** `survives()` = `wouldSurviveAt(level, box)` where `box` is the entity's bounding box. `wouldSurviveAt(level, box)` = `hasAnchorBelow(level, box)` **and not** `isCoveredBySuffocatingBlocks(level, box)`.
- `hasAnchorBelow`: the probe box is `(minX, minY - 0.015625, minZ)` to `(nextDown(maxX), minY, nextDown(maxZ))` expanded by `(0, -0.125, 0)` (extended 0.125 downward in addition); true when some block position in it has a non-empty collision shape whose bounds (moved to the block) intersect the probe box (the first intersecting block ends the search with success).
- `isCoveredBySuffocatingBlocks`: the box deflated by the "next" epsilon (`nextDeflated`); true when **every** block position in it (`BlockPos.betweenClosed`) is a suffocating block (`isSuffocating(level, pos)`); false as soon as one is not.
`canBePlacedAt(level, box)` (placement) = `wouldSurviveAt(level, box)` and **not** `isAnchorBuried(level, box)`: `isAnchorBuried` builds the box `(minX, minY, minZ)` to `(maxX, minY + 0.015625, maxZ)` (a 1/64 slab at the base), deflated; it is true when some block collision shape inside that slab leaves **no** part of the slab uncovered (`Shapes.join(slab, shape, ONLY_FIRST)` is empty), i.e. the base would sit inside a full block.

**`tickAtCheckInterval`** (every 100 ticks, server): read the fluid state at the entity's block position; when `collidedWithFluid(fluidState, pos, previousPosition, position)` the fluid's `entityInside` effect is applied to the cushion (through the inside-block-effect collector, applied and cleared at once); then `destroyIfInFire(level)`. `destroyIfInFire`: unless removed, find blocks in the box (`nextDeflated`) whose state is in block tag `fire`; for the first such block (the iteration stops after one) `hurtServer(level, in_fire damage, 1.0)` (which kills it through the base rule).

**Placement (`CushionItem.useOn`):** only the UP face (else FAIL); `pos` = the placement position; the spawn box = `EntityType.getSpawnAABB(Vec3.atCenterOfWithY(pos, clickLocation.y))` (centre of the block in x and z, the exact click height); `canBePlacedAt` must hold; on the server no other `Cushion` may be in that box (else FAIL); create (reason `SPAWN_ITEM_USE`, item components applied), `snapTo(position, Direction.fromYRot(playerYaw).toYRot(), 0)` (the yaw is snapped to the nearest of 4 directions), add, `destroyIfInFire`, play `CUSHION_PLACE` (volume 0.75, pitch 0.8), `ENTITY_PLACE`, consume 1; SUCCESS. The spawn box is `getSpawnAABB(x, y, z)`: half width `spawnDimensionsScale * width / 2` (scale 1.0 for the cushion, so 0.5) around x and z, from `y` up to `y + scale * height` (0.25): a 1.0 x 0.25 x 1.0 box. If `create` returns null the result is FAIL. The cushion type is registered with no loot table, tracking range 10, update interval 2147483647 and no delta tracking (read in `EntityTypes`).

**Special collision shapes (`recalculateContextForSpecialCollisionShapes`, read).** Before anything else the use context is rebuilt when all of these hold: the player is not null, and the clicked block is in block tag `cushion_uses_collision_shape` (members: block tag `cauldrons`, `hopper`, `composter`). Steps: `eye` = the player's eye position; `dir` = click location minus `eye`; `end` = click location plus `normalize(dir) * 0.001`; clip the block's collision shape (not the outline) with the segment `eye` to `end`; if it hits nothing the original context is kept, otherwise a new context is made with the same player and hand and the hit result of the clip. The effect is that the click height used for the spawn box is the height of the collision surface (for example the inner floor of a cauldron), not of the outline.

**Hit and use:** `hurtServer`/`hurtClient`: false when the attacking entity is a player who may not build (`mayBuild`), and on the server also when `level.mayInteract(player, pos)` is false; else the base rule (kill and drop). `dropItem`: break sound, particles, nothing more when `entity_drops` is false or the breaker has infinite materials; else a cushion item of the entity's colour **with its data** (`getCushionItemStackWithData`) is dropped, and when the cause is a `LightningBolt` the item gets 20 ticks of invulnerability (`setInvulnerableTime(20)`). Use: not for secondary-use players, not while someone already rides it: the server calls `player.startRiding(cushion)`; success plays `CUSHION_SIT` and returns SUCCESS_SERVER, else CONSUME; otherwise PASS. When a passenger leaves, if the entity has no removal reason the server plays `CUSHION_GET_UP` (volume 1, pitch 1). Pick result: the cushion item of the colour (`ColorCollection.pick(colour)`).

### 8.2 Mannequin

Class `Mannequin` extends `Avatar` (a living avatar with `getProfile`, `getMainArm`, `isModelPartShown`). Constructor defaults: description = the translation `entity.minecraft.mannequin.label`, `hideDescription = false`, model customisation = all layers set (127). Metadata 15 main hand (Avatar), 16 model customisation (Byte), 17 profile, 18 immovable, 19 description (optional component). `updateDescription`: metadata 19 = empty when `hideDescription` else the description component (re-evaluated whenever either changes).

**There is no `interact` override: right clicks, hits and breaking follow the generic `LivingEntity` rules** (name tags and leashes: 18 framework; damage and death: 18 framework, with the entity's loot table). The only rule specific to the mannequin: `isImmobile` and `isEffectiveAi` consult `immovable`: when `immovable` is true the mannequin is immobile (no movement from physics or knockback processing, and its effective-AI test is false), otherwise the `Avatar` defaults apply. NBT: `profile` (resolvable profile), `hidden_layers` (list of hidden model parts), `main_hand` (`left` or `right`), `pose` (one of standing, crouching, swimming, fall_flying, sleeping; others are rejected with an error result), `immovable` (boolean), `description` (text), `hide_description` (boolean). Valid pose set (`VALID_POSES`, read): standing, crouching, swimming, fall_flying, sleeping. A data loot table `loot_table/entities/mannequin.json` exists and has no pools (only a random sequence), so a mannequin drops nothing. Dimensions by pose (`Avatar` static initialiser, read): standing 0.6 x 1.8, eye height 1.62, with a vehicle attachment; sleeping 0.2 x 0.2, eye 0.2 (`LivingEntity` constant); fall_flying, swimming and spin_attack 0.6 x 0.6, eye 0.4; crouching 0.6 x 1.5 (`CROUCH_BB_HEIGHT`), eye 1.27. Unlisted poses use the standing dimensions.

**Profile (`ResolvableProfile`, read).** Metadata 17 holds a `ResolvableProfile`, default `ResolvableProfile.Static.EMPTY` (the `Mannequin.DEFAULT_PROFILE`). Two kinds exist: `Static` (a complete game profile, optionally with a skin patch) and `Dynamic` (only a name or only a UUID, plus a skin patch). `Dynamic.resolveProfile(resolver)` runs `ProfileResolver.fetchByNameOrId(name or UUID)` on the non-critical I/O pool and falls back to the partial profile when the lookup returns nothing; the lookup itself is an external account-service query and is not game logic. A search of every class in the jar for the method name finds callers only in the client skin render cache (`PlayerSkinRenderCache`), not in `Mannequin`, so a mannequin never resolves its profile on the server; the client resolves it for rendering. A server therefore stores the profile as given (name, UUID or full profile) and sends it unchanged.

## 9. Happy ghast

Extends 21 section 8.11 (constants, modes, tempt predicates, baby brain are there).

### 9.1 Natural spawning path

There is no biome spawn entry (21 section 3.4) and the entity type's spawn placement is not used by the natural spawner for it. The happy ghast comes from the **dried ghast block** (crafted or bartered, below) (`DriedGhastBlock`, code-defined):
- Block states: `facing` (horizontal, default north), `hydration_level` (integer 0 to 3, default 0), `waterlogged` (default false). Shape (static initialiser, read): `Block.column(10.0, 10.0, 0.0, 10.0)`, which centres the two horizontal sizes around 8.0: x 3 to 13, z 3 to 13, y 0 to 10 (sixteenths), a 10 x 10 footprint 10 high. Loot: the block itself (`survives_explosion`, data file `loot_table/blocks/dried_ghast.json`). Client ambience (`animateTick`): when the block below is in block tag `triggers_ambient_dried_ghast_block_sounds` a random chance plays `DRIED_GHAST_AMBIENT` (BLOCKS) at the block centre, and a random chance spawns `white_smoke` particles (speed 0.02); a waterlogged state uses `DRIED_GHAST_AMBIENT_WATER`; the exact rules (`animateTick`, read) are in 9.1.1.
- Placement: `waterlogged` = the clicked position holds water; `facing` = the opposite of the player's horizontal direction. `setPlacedBy` plays `DRIED_GHAST_PLACE_IN_WATER` when waterlogged else `DRIED_GHAST_PLACE`. It can be waterlogged by water (`placeLiquid`, the water tick is scheduled and `DRIED_GHAST_PLACE_IN_WATER` plays).
- **Schedule:** `randomTick`: when the block is waterlogged **or** `hydration_level > 0`, and no block tick is already scheduled at the position, schedule a block tick in **5000** ticks (`HYDRATION_TICK_DELAY`).
- **Block tick:** if not waterlogged: when `hydration_level > 0`, decrease it by 1 (`setBlock` with flags 2; `BLOCK_CHANGE` game event). If waterlogged (`tickWaterlogged`): when `hydration_level != 3`: play `DRIED_GHAST_TRANSITION` (BLOCKS, 1, 1) and increase it by 1 (flags 2, game event); when it is 3: **hatch** (`spawnGhastling`).
- **Hatch:** remove the block (no drops); create a `happy_ghast` with reason `BREEDING`; `setBaby(true)`; the head and body yaw are the block's `facing` yaw (`Direction.getYRot(facing)`); `snapTo` the block's bottom centre with that yaw and pitch 0; add the entity; play `GHASTLING_SPAWN` from the entity. The baby starts at the framework's baby age (18 framework: -24000).
- Timing: each stage needs one scheduled tick, and each schedule is only created by a random tick of the block, so a block needs at least four scheduled ticks (3 hydration increases and the hatching tick) and therefore **at least 20000 ticks** from the first schedule. Sources of the block (read): the shaped crafting recipe `dried_ghast` (eight `ghast_tear` around one `soul_sand`, pattern `###/#X#/###`, group `dry_ghast`), the `piglin_bartering` loot table (item `dried_ghast`, weight 10, `set_count` 1), and the block's own loot table. No worldgen JSON file mentions `dried_ghast`, and none of the 1511 structure NBT files in the jar contains it. Method: the files are listed with `unzip -Z1 <jar> | grep -v "/$" | grep -E '^data/minecraft/structure/.*\.nbt$' | wc -l` (1511; the same count results for every `.nbt` in the jar), and each is read with `unzip -p`, decompressed with `gunzip -c` and searched for the string `dried_ghast` (0 hits); every other data file was searched as plain text (hits: the recipe, the block loot table, `piglin_bartering`, the harness and dried ghast recipe advancements, the advancement `place_dried_ghast_in_water`, and the tag below); the only tag file that names it is `tags/block/blocks_motion_no_leaves`. So the block is not generated by world generation in this jar.

### 9.1.1 Dried ghast client ambience (`DriedGhastBlock.animateTick`)

Client only, once per animate tick, with `c` = the block centre `(x + 0.5, y + 0.5, z + 0.5)`:

| State | Sound | Particle |
|---|---|---|
| not waterlogged | with chance 1/40 (`nextInt(40) == 0`) and only when the block below is in block tag `triggers_ambient_dried_ghast_block_sounds` (members: `soul_sand`, `soul_soil`): `DRIED_GHAST_AMBIENT` (BLOCKS, volume 1, pitch 1, local, at `c`) | with chance 1/6 (`nextInt(6) == 0`): one `white_smoke` at `c` with velocity (0, 0.02, 0) |
| waterlogged | with chance 1/40: `DRIED_GHAST_AMBIENT_WATER` (BLOCKS, 1, 1, at `c`), no block-below condition | with chance 1/6: one `happy_villager` at `(c.x + (nextFloat * 2 - 1) / 3, c.y + 0.4, c.z + (nextFloat * 2 - 1) / 3)` with velocity (0, nextFloat, 0) |

The constants 3.0 and 0.4 are therefore the horizontal divisor (offset within about 0.33 of the centre) and the 0.4 block vertical offset of the waterlogged particle.

### 9.2 Growth by feeding

`isFood(stack)` = item tag `happy_ghast_food` (member `snowball`, data). `Animal.mobInteract` for a baby (`HappyGhast.mobInteract` calls it for babies) only *calls* the two age helpers; both are defined in `AgeableMob` (`getSpeedUpSecondsWhenFeeding(int)` is a static there, `ageUp(int, boolean)` an instance method). When the stack is food and the animal is a baby and not age-locked (`canAgeUp` = `isBaby && !isAgeLocked`): consume one item (`usePlayerItem`), then `ageUp(seconds, forced = true)` with `seconds = getSpeedUpSecondsWhenFeeding(-age)` and `getSpeedUpSecondsWhenFeeding(a) = (int)((float)(a / 20) * 0.1f)` (integer division by 20 first); `AgeableMob.ageUp(seconds, forced)`: `newAge = min(age + seconds * 20, 0)`; set it; when forced add `(newAge - oldAge)` to `forcedAge` and, if `forcedAgeTimer` is 0, set it to 40; when the resulting age is exactly 0, `setAge(forcedAge)`. Eating sound plays; SUCCESS. The love branch is skipped because `canFallInLove` is false. The baby boundary: `ageBoundaryReached` (age reaching 0) calls `adultGhastSetup` (the adult move control, look control, navigation and goals; the brain is stopped and its memories cleared) and for a baby `babyGhastSetup` (flying move control `FlyingMoveControl(180, true)`, plain look control, `BabyFlyingPathNavigation`, still timeout reset, adult goals removed). Body scale: 0.2375 baby, 1.0 adult (21 section 8.11). Example in section 14.

### 9.3 Harness identity

`canUseSlot(BODY)` is true only while the ghast is alive and **not a baby**; other slots follow `Animal`. A dispenser may equip the BODY slot (`canDispenserEquipIntoSlot`). An adult ghast right-clicked: first the held item's own `interactLivingEntity` (equipping a harness is the item's `equippable` behaviour: `equip_on_interact`); then, when it wears body armor and the player is not using secondary use, the player starts riding it (`startRiding`) and the action returns SUCCESS; otherwise `Animal.mobInteract`. The ride call is `doPlayerRide(player)` (private; on the server only it calls `player.startRiding(ghast)` and ignores the result; on the client it does nothing). A baby goes straight to `Animal.mobInteract`; for an adult an empty hand skips the item step. Riding is in 9.7. Class constants read: baby scale 0.2375, restriction radii 32 and 64 with buffer 16, heal periods 20 and 600, `MAX_PASSANGERS` 4, still-timeout grace 60 and max 10, panic speed multiplier 2.0.

The harness items are the sixteen `<dye>_harness` items (`white_harness`, `orange_harness`, `magenta_harness`, `light_blue_harness`, `yellow_harness`, `lime_harness`, `pink_harness`, `gray_harness`, `light_gray_harness`, `cyan_harness`, `purple_harness`, `blue_harness`, `brown_harness`, `green_harness`, `red_harness`, `black_harness`), members of item tag `harnesses`. Each is registered with: stack size 1 and the `equippable` component: slot BODY, equip sound `HARNESS_EQUIP`, asset = the colour's harness equipment asset (`happy_ghast_body/<colour>_harness`), allowed entities = entity type tag `can_equip_harness` (member `happy_ghast`), `equip_on_interact` true, `can_be_sheared` true with shearing sound `HARNESS_UNEQUIP`. The tag `happy_ghast_tempt_items` = `happy_ghast_food` plus `harnesses` (21 section 8.11).

### 9.4 `HappyGhastFloatGoal`

Registered at priority 3 on adults (21 section 8.11). It extends `FloatGoal` (flag JUMP; 18 framework: jump on 80% of ticks when deeper than the fluid jump threshold in the floatable fluid tag, or in lava). The only change: `canUse` = `!isOnStillTimeout() && FloatGoal.canUse()`.

`isOnStillTimeout()` = `staysStill()` (metadata 19) **or** `serverStillTimeout > 0`. The server `tick` (adults and babies, server only): `leashHolderTime` counts down 1 per tick while positive and drives metadata 18 (`isLeashHolder = leashHolderTime > 0`); `serverStillTimeout` counts down 1 per tick once `tickCount > 60` and is re-applied through `setServerStillTimeout` (when it changes from 0 to a positive value the entity's position is force-synced to its trackers with an Entity Position Sync packet and the stay-still flag is refreshed); `scanPlayerAboveGhast()` true sets the timeout to 10. `scanPlayerAboveGhast`: the box `(minX - 1, maxY - 1.0E-5 (9.999999747378752E-6), minZ - 1)` to `(maxX + 1, maxY + ySize / 2, maxZ + 1)` of the ghast's own box; true when some non-spectator player whose root vehicle is not a `HappyGhast` has that **root vehicle's position** (for a player on foot, its own position) inside the box (a player standing on the ghast keeps it still; the box reaches 1 block beyond the ghast on x and z, starts 0.00001 below its top and extends half its height above it). `aiStep` (server) sets `requiresPrecisePosition = isOnStillTimeout()`.

### 9.5 `BabyFlyingPathNavigation`

`FlyingPathNavigation` (18 framework: navigation) with: cannot open doors, can float, **required path length 48.0**, and `canMoveDirectly(from, to)` = `isClearForMovementBetween(mob, from, to, false)` (the straight-line clearance test of 18 framework: navigation with the "allow liquids" argument false).

### 9.6 Other server rules read here

`customServerAiStep`: a baby runs `brain.tick` and `HappyGhastAi.updateActivity`; then `checkRestriction()` and `Animal.customServerAiStep`. `getHappyGhastRestrictionRadius()` = 64 for an adult with an empty BODY slot, else 32. `checkRestriction`: unless leashed or carrying a passenger: if the ghast already has a home within `radius + 16` distance (closer-than test against its block position) and the home radius equals the computed radius, nothing; else `setHomeTo(blockPosition, radius)`. `continuousHeal` (server): when alive, `deathTime == 0` and health below max: `inClouds = isInClouds() or precipitationAt(pos) != NONE`; `period = inClouds ? 20 : 600` (wait: the heal period is 20 when in clouds or rain, else 600); when `tickCount % period == 0`: `heal(1.0)`. `isInClouds()` (`Entity`): the cloud-colour environment attribute's alpha at the position is not 0, **and** `y + bbHeight >= cloudHeight` **and** `y <= cloudHeight + 4.0` (`cloudHeight` = the cloud-height attribute at the position). Riding, rider input and the controls are in 9.7 and 9.8.

### 9.7 Riding and controls (read in `HappyGhast`)

- **Seats:** `canAddPassenger` while fewer than 4 passengers (`MAX_PASSANGERS`). `addPassenger`: when the ghast had no passenger, play `HARNESS_GOGGLES_DOWN`; add; on the server, if `scanPlayerAboveGhast()` is false set the still timeout to 0, else cap a timeout above 10 to 10. `removePassenger`: remove; on the server set the still timeout to 10; when no passenger remains, `clearHome()` and play `HARNESS_GOGGLES_UP`.
- **Controller:** the first passenger, when it is a player, the ghast wears body armor and is not on a still timeout; otherwise the `Animal` default. `isFlyingVehicle` = not a baby. The dismount position is `(x, boundingBox.maxY, z)` (on top of the ghast).
- **Collision (`canBeCollidedWith(other)`):** false for a baby or a dead ghast; on the client, true for a player whose y is at or above the ghast's top (so a player can stand on it); true when the ghast has passengers and `other` is a `HappyGhast`; otherwise `isOnStillTimeout()`. So an idle (still) ghast is solid; a flying one is not.
- **Rider input (`getRiddenInput(player, travel)`):** strafe `s = player.xxa`; forward `f = 0`, vertical `v = 0`. When `player.zza != 0`: `f = cos(pitch * 0.017453292f)`, `v = -sin(pitch * 0.017453292f)` (the player's pitch, `Mth` tables); when `zza < 0` both are multiplied by -0.5. When the player is jumping, `v += 0.5`. Result = `(s, v, f) * (3.9000000953674316 * FLYING_SPEED attribute)`.
- **Rider rotation (`getRiddenRotation`, `tickRidden`):** target = (pitch `rider.xRot * 0.5`, yaw `rider.yRot`). Each ridden tick the ghast yaw moves toward the rider yaw by `wrapDegrees(riderYaw - yaw) * 0.08` (a 8 percent step), its pitch is set to the target pitch, and the previous yaw, head yaw and body yaw are all set to the new yaw.
- **Travel:** `travel(input)` calls the flying travel with `speed = FLYING_SPEED * 5 / 3` (float) used for all three speed arguments. Attributes (`createAttributes`): max health 20, tempt range 16, flying speed 0.05, movement speed 0.05, follow range 16, camera distance 8.
- **Move control (adult):** `GhastMoveControl` (44-6 section 9.1 gives its tick) constructed with `careful = true` and the stop supplier `isOnStillTimeout()`: when the supplier is true the operation is cleared and the mob stops in place each tick. With `careful` true, `canReach` first requires every block of the target box inflated by 1 to be traversable by the simple test (air passes; a block in block tag `happy_ghast_avoids` blocks; a non-empty fluid blocks unless it is water and the ghast is in water or lava and the ghast is in lava; otherwise the collision shape must be empty), and then runs the swept test as for the ghast with the same extra rules. Tag `happy_ghast_avoids` = `sweet_berry_bush`, `cactus`, `wither_rose`, `magma_block`, `fire`, and tag `speleothems`.
- **Look control (adult, `HappyGhastLookControl.tick`):** on a still timeout: `delta = wrapDegrees90(yaw)` (the remainder by 90 degrees, folded into -45 to +45 degrees), yaw is reduced by `delta` (snapped to a multiple of 90) and the head yaw is set to it. Otherwise, while `lookAtCooldown > 0`: decrement it, yaw = `-atan2(wantedX - x, wantedZ - z)` in degrees (float constant 57.295776), body yaw and head yaw copy it. Otherwise `Ghast.faceMovementDirection` (44-6 section 9.1).
- **Body rotation (`HappyGhastBodyRotationControl.clientTick`):** on the client, while the ghast has passengers, head yaw and body yaw are set to the entity yaw before the default control runs.
- **Baby brain (`HappyGhastAi`):** core activity: `Swim(0.8)`, `AnimalPanic` (panic multiplier 2.0), `LookAtTargetSink(45, 90)`, `MoveToTargetSink`, a `CountDownCooldownTicks` for the temptation cooldown memory; idle activity (priority order): `FollowTemptation` (speed multiplier 1.25, (inferred) pairing), `BabyFollowAdult` toward the nearest visible player (range uniform integer 3 to 16, multiplier 1.1) then toward the nearest visible adult (same range and multiplier, close-enough distance 3.0), then a `RunOne` of `RandomStroll.fly(1.0)` and `SetWalkTargetFromLookTarget(1.0, 3)` each weight 1; a panic activity runs while the `IS_PANICKING` memory is present. Sensors: nearest living entities, hurt by, food temptations, nearest adult (any type), nearest players. Activity updates choose PANIC over IDLE (`updateActivity`).

### 9.8 Leash (read in `HappyGhast`)

A happy ghast is a quad-leash holder (`supportQuadLeashAsHolder` true). `getLeashOffset` = (0, 0, 0). `getQuadLeashHolderOffsets` = `Leashable.createQuadLeashOffsets(ghast, -0.03125, 0.4375, 0.46875, 0.03125)`, which with `w` = bounding width and `h` = bounding height yields four attachment points (entity-local; rotation by yaw not read): with `A = -0.03125 w`, `B = 0.4375 w`, `C = 0.46875 w`, `D = 0.03125 h`: `(-C, D, B + A)`, `(-C, D, -B + A)`, `(C, D, -B + A)`, `(C, D, B + A)`. `leashElasticDistance` = 10.0 and `leashSnapDistance` = 16.0. `onElasticLeashPull`: the `Animal` behaviour, then the move control is set to WAIT (the ghast stops steering). `notifyLeashHolder(leashed)`: when the leashed entity supports quad leashes, `leashHolderTime = 5`; the server tick decreases it by 1 per tick and publishes `leashHolderTime > 0` as metadata 18. The restriction radius is in 9.6. The leash pull force itself belongs to the generic `Leashable` code (18 framework).

## 10. Wither boss bar items

21 section 7.3 (colour, overlay, flags, progress) is confirmed. Added from `WitherBoss` and `ServerBossEvent`:

- The bar's UUID is `Mth.createInsecureUUID(random)` of the wither's own random source at construction (different for every wither); title `getDisplayName()` (custom name or the type name); colour PURPLE, overlay PROGRESS; one extra initialiser call `setDarkenScreen(true)`. `setPlayBossMusic` and `setCreateWorldFog` stay false.
- `setCustomName(name)` also calls `bossEvent.setName(getDisplayName())`; loading NBT with a custom name does the same; `readAdditionalSaveData` reads `Invul` (int, default 0) into `invulnerableTicks`.
- `startSeenByPlayer(player)` = `addPlayer(player)`; `stopSeenByPlayer` = `removePlayer`. (The dragon's bar uses the fight's 20-tick player scan instead, 21 section 6.4.5.)
- `makeInvulnerable()` (the spawn trigger): `invulnerableTicks = 220`, `bossEvent.setProgress(0.0)`, health = `maxHealth / 3.0f`.
- `ServerBossEvent` semantics (all setters broadcast only on change): `setProgress`, `setColor`, `setOverlay`, `setDarkenScreen`, `setPlayBossMusic`, `setCreateWorldFog`, `setName` compare the new value with the stored one and do nothing when equal; otherwise they store it, mark the event dirty and broadcast (to the player set, only while `visible`) the matching operation: progress -> UPDATE_PROGRESS (operation 2), name -> UPDATE_NAME (3), colour and overlay -> UPDATE_STYLE (4), the three booleans -> UPDATE_PROPERTIES (5) (read: the `ServerBossEvent` bootstrap methods are `createUpdateProgressPacket`, `createUpdateStylePacket` shared by colour and overlay, `createUpdatePropertiesPacket` shared by the three flags, and `createUpdateNamePacket`; `OperationType` declaration order ADD 0, REMOVE 1, UPDATE_PROGRESS 2, UPDATE_NAME 3, UPDATE_STYLE 4, UPDATE_PROPERTIES 5). `addPlayer`: if newly added and visible, send ADD (operation 0, full state); `removePlayer`: if it was present and visible, send REMOVE (operation 1, the UUID only); `removeAllPlayers` removes each player in turn; `setVisible(v)`: when it changes, every player receives ADD (visible) or REMOVE (hidden). The event starts visible with an empty player set. The wire layout of the packet is in 05a 0x09.

## 11. End mob items

### 11.1 End crystal item (`EndCrystalItem.useOn`)

1. The clicked block must be obsidian or bedrock, else FAIL.
2. `above = clickedPos.above()` must be an empty (air) block, else FAIL.
3. No entity may intersect the box from `(above.x, above.y, above.z)` to `(above.x + 1, above.y + 2, above.z + 1)`, else FAIL.
4. Server: create `EndCrystal(level, above.x + 0.5, above.y, above.z + 0.5)`, `setShowBottom(false)`, add it, fire `ENTITY_PLACE` (source = the player), and when the level has a dragon fight call `EnderDragonFight.tryRespawn()` (21 section 6.4.5). Consume 1 item; SUCCESS.
The crystal entity itself, its fire placement and its destruction are in 21 section 6.3.

### 11.2 Shulker (`Shulker`) additions and one correction

**Correction to 21 section 6.2 (split rule).** `hitByShulkerBullet` is called from `hurtServer` when the damage is a projectile and the direct entity is a `shulker_bullet`. It returns without effect when the shulker **is closed** (raw peek 0) **or** `teleportSomewhere()` fails; i.e. a split needs the shulker to be **open and able to teleport**. (21 wrote "when it is not closed or it can teleport away".) After a successful teleport: count `n` = shulkers (type `shulker`) in the box inflated by 8 around the **old** bounding box (including itself, the old position's box is taken before teleporting); `p = (n - 1) / 5.0f`; if `nextFloat() < p` a new shulker (reason BREEDING) of the same colour is placed at the old position (`snapTo(oldPosition)`) and added. Damage order in `hurtServer`: closed and the direct entity is an arrow: false; then the `AbstractGolem` damage; if it was applied (true): when `health < maxHealth * 0.5` **and** `nextInt(4) == 0`: `teleportSomewhere()`; **else** the bullet test above; return true. (Not applied: false.)

**Attachment engine.**
- `canStayAt(pos, face)`: false when `isPositionBlocked(pos)`; `opposite = face.getOpposite()`; false unless `level.loadedAndEntityCanStandOnFace(pos.relative(face), this, opposite)` (false when `pos` is out of valid bounds or its chunk is not loaded at FULL status; otherwise the chunk's block state `entityCanStandOnFace(level, pos, entity, face)`); finally `level.noCollision(this, box)` where `box` = `getProgressAabb(scale, opposite, 1.0, bottomCenter(pos)).deflate(1.0E-6)` (the lid fully open: the maximum extension).
- `isPositionBlocked(pos)`: the block at `pos` is not air **and** it is not (a `moving_piston` block at the shulker's own block position).
- `findAttachableSurface(pos)`: the first direction in the enum order `DOWN, UP, NORTH, SOUTH, WEST, EAST` (the `Direction` enum declaration order, read) with `canStayAt(pos, d)`, or null.
- Server `tick`: when not a passenger and `!canStayAt(blockPosition, attachFace)`: `findNewAttachment` (the first surface from `findAttachableSurface(blockPosition)` becomes the attach face, else `teleportSomewhere()`); then `updatePeekAmount()` and, when it changed, `onPeekAmountChange` (box update and pushing, 21 section 6.2). Client: teleport interpolation counters.
- `getProgressAabb(scale, direction, progress, origin)` = `getProgressDeltaAabb(scale, direction, -1.0, progress, origin)`; the delta function builds the base cube `(-s/2, 0, -s/2)` to `(s/2, s, s/2)` with `s = scale`, extends it by `direction.step * max(from, to) * s`, contracts it by `-direction.step * (1 + min(from, to)) * s` and moves it to `origin`. With `from = -1`: the box is the cube extended along `direction` by `progress * s`. The entity's box (`makeBoundingBox`) = `getProgressAabb(scale, attachFace.opposite, physicalPeek(currentPeek), position)` with `physicalPeek(p) = 0.5 - sin((0.5 + p) * pi) * 0.5` (`Mth.sin`, 0 at p = 0, 1 at p = 1). Default dimensions: while attached to the floor (face DOWN) and the peek is above 0, the height is scaled by `1 + peek`.
- `updatePeekAmount`: logical target `raw * 0.01`; the current peek moves 0.05 per tick (down: `clamp(cur - 0.05, target, 1.0)`; up: `clamp(cur + 0.05, 0, target)`); returns whether it changed.
- NBT: `AttachFace` (legacy direction id, default DOWN), `Peek` (byte, default 0), `Color` (byte, default 16). `finalizeSpawn` sets yaw 0 and head yaw equal, then the `AbstractGolem` result. The loot table (data): `shulker_shell`, chance 0.5 unenchanted, `0.5625 + 0.0625 * (level - 1)` with looting (matches 21).

**Shulker bullet flight (`ShulkerBullet`, speed constant `0.15`).** State: `finalTarget` (entity reference), `currentMoveDirection` (Direction or none), `flightSteps`, `targetDeltaX/Y/Z`. Per server tick (`Projectile.tick` first):
1. If the target entity is gone, clear the reference. If the target is alive and is not a spectating player: for each of `targetDelta` x, y and z: `d = clamp(d * 1.025, -1, 1)`; `velocity += ((targetDelta - velocity) * 0.2)` per axis (the velocity moves a fifth of the way to the target delta each tick). Otherwise: normal gravity (`applyGravity`).
2. Hit test along the movement (`getHitResultOnMoveVector` with the bullet's can-hit predicate), move by the velocity, apply block effects and portal handling, then if the hit result is not MISS: `hitTargetOrDeflectSelf`. `rotateTowardsMovement(0.5)`.
3. Server only, with a target: if `flightSteps > 0`: decrement it; when it reaches 0: `selectNextMoveDirection(axisOf(currentMoveDirection) or null, target)`. Then, when a move direction exists: let `bp` = the bullet's block position and `ax` = the axis of the move direction: if the cell `bp.relative(moveDirection)` can be stood on by the entity (`loadedAndEntityCanStandOn`: the same test with face UP, so false for unloaded or out-of-bounds cells; it is blocked): `selectNextMoveDirection(ax, target)` immediately; else if the bullet is already in the target's block row on axis `ax` (the target's block coordinate on that axis equals `bp`'s): `selectNextMoveDirection(ax, target)`.
4. Client: an `end_rod` particle at the previous position offset by +0.15 in y.

`selectNextMoveDirection(axis, target)`: `yOff = 0.5` (or `target.bbHeight * 0.5` for a target); `T` = the target's block (target position plus `yOff` in y, as a block position; with no target, the block below the bullet) with the point `P = (T.x + 0.5, T.y + yOff, T.z + 0.5)` where `T.y + yOff` uses the same `yOff`. If `T`'s centre is **not** within 2.0 of the bullet position (`closerToCenterThan(position, 2.0)` false): `bp` = the bullet's block position; candidates = for each of the three axes other than `axis`, in the order X, Y, Z: if `bp.coord < T.coord` and the cell one step in the positive direction is empty (air): add the positive direction (EAST, UP, SOUTH); else if `bp.coord > T.coord` and the negative-direction cell is empty: add the negative direction (WEST, DOWN, NORTH). Then **one `Direction.getRandom(random)` draw is always made** as `dir`; if the candidate list is empty: up to 5 times, while the cell `bp.relative(dir)` is not empty and tries remain, redraw `dir = Direction.getRandom(random)`; otherwise `dir = candidates[random.nextInt(candidates.size())]`. The aim point becomes the bullet's own position plus the step of `dir` (x, y, z). When `T` is within 2.0 the direction stays none and the aim point is `P`. Finally: `currentMoveDirection = dir`; `targetDelta = (aim - position) / |aim - position| * 0.15` (all zero when the distance is 0); `needsSync = true`; `flightSteps = 10 + nextInt(5) * 10` (10, 20, 30, 40 or 50). `Direction.getRandom(random)` is read: it picks `array[random.nextInt(6)]` from the six directions in the enum order DOWN, UP, NORTH, SOUTH, WEST, EAST, one `nextInt` per call. **Shulker teleport (`teleportSomewhere`, read).** Fails (returns false) when the shulker has no AI or is dead. Otherwise up to 5 tries; each try picks `target` = the shulker's block position offset by three independent `randomBetweenInclusive(-8, 8)` draws (x, y, z, in that order, from the shulker's own random source; `MAX_TELEPORT_DISTANCE` 8). A try is rejected unless all hold: `target.y` is above the level minimum; `target` is an empty (air) block; `target` is inside the world border; `noCollision(shulker, box)` for the 1x1x1 block box at `target` deflated by 1.0E-6; `findAttachableSurface(target)` returns a face `d` (the order of 11.2); and the block at `target.relative(d)` is not in block tag `shulker_does_not_teleport_to` (members: `bedrock`). On the first accepted try: stop riding (`unRide`), set the attach face to `d`, play `SHULKER_TELEPORT` (volume 1, pitch 1), `setPos(target.x + 0.5, target.y, target.z + 0.5)`, game event `TELEPORT` at the old block position, level event 2016 at the old position with data `BlockUtil.packDifferenceInPosition(old, new, 8, 8, 8)` (the client effect of the event was not read), set the peek metadata to 0, clear the target, return true. If all 5 tries fail the result is false and nothing changes. Client interpolation: when the client sees the block position change on a non-passenger shulker (`setPos`), it stores the old attach position and sets `clientSideTeleportInterpolation = TELEPORT_STEPS = 6`; it decreases by 1 per client tick, and when it is 0 the stored old position is cleared. The shulker's entity interpolation handler is the no-op handler.

Hit effects and the 4.0 damage and 200-tick levitation of the bullet are in 21 section 6.2.

### 11.3 End city placement (`EndCityPieces.EndCityPiece.handleDataMarker`)

The End city template pieces carry data markers (structure-block data markers, 07 section 6): `handleDataMarker(name, pos, level, random, chunkBox)` (read in this round, class `EndCityPieces$EndCityPiece`):
- Name starts with `Chest`: when `pos.below()` is inside the chunk's bounding box, set the loot table of the chest block entity below the marker to `end_city_treasure` (seeded from the random source).
- Otherwise, only when the marker position is inside the chunk box and `Level.isInSpawnableBounds(pos)`:
  - name starts with `Sentry`: create a `shulker` (reason `STRUCTURE`) at `(pos.x + 0.5, pos.y, pos.z + 0.5)` (the position is set; no `finalizeSpawn` call here) and add it to the level;
  - name starts with `Elytra`: create an `ItemFrame` at `pos` with direction `rotation.rotate(SOUTH)`, where `rotation` is the rotation of the piece's placement settings (the `Rotation.rotate(Direction)` of the structure placement applied to SOUTH), set its item to one `elytra` with `setItem(stack, updateNeighbours = false)` and add it.
Pieces are placed with `ignoreEntities = true`, the structure-and-air block-ignore processor (the structure void/air entries do not overwrite) and the piece's rotation. Which template files contain how many markers is structure NBT data (RS20 documents the structure engine).

### 11.4 Enderman hand-off and endermite

The enderman (variants, gaze, teleport, block carrying) is fully described in 20 section 8.1 and its End spawn weights in 21 section 3.4 (End biomes: `enderman` weight 10, group 4; nether wastes weight 1, group 4); the endermite in 20 section 8.2 (spawned only by the thrown ender pearl, 17). The remaining statements of 21 section 6 point there and need nothing further from this round; the End-specific facts are: the End has no hostile natural list other than the enderman, shulkers appear only through End city markers (11.3) and bullet splits (11.2), and the dragon fight owns the crystals (21 section 6.4).

## 12. Appendix gaps of 21 section 8

The "behaviour not read" rows of 21 section 8.9 that this document closes: armor stand (section 4), item frame and glow item frame (5.3), painting (5.4), interaction (7), marker (7), block, item and text display (6), cushion and mannequin (8), area effect cloud (3), lightning (2). Rows that remain out of this document, with the section that owns each:

| Topic | Owner |
|---|---|
| boats, rafts, chest boats, minecarts of every kind, passenger attachment points | 44-8 vehicles and projectiles |
| projectile entities (arrows, fireballs, wind charges, thrown items) and their behaviour, lingering potion clouds, tipped arrow clouds and every other area effect cloud user except the dragon's own clouds (section 3) | 44-8 |
| villager brain, villages, raids, points of interest | 44-3 |
| warden, crossbow quick charge and multishot arithmetic | 44-5 |
| piglin tasks, hoglin, strider, ghast base class | 44-6 |
| nautilus family | 44-7 |
| spawn reasons (`EntitySpawnReason` matrix) | 44-1; spawn lists and structure spawns 44-2 |
| land animals (love, breeding, ageing helpers other than the happy ghast) | 44-4 |
| `leash_knot`, `ominous_item_spawner`, `sulfur_cube` | already described in 21 and 20 |

Appendix A of 21 needs no index changes: the armor stand's own fields start at 15 (living base 14), item frame and painting start at 8, displays at 8, interaction at 8, the cushion at 8 (matches the tables above).

## 13. Item pickup and throw delays

Answered in full by 41: default pickup delay 10 for spawned drops (41 section 2.1), 40 for player throws (41 section 2.3), 0 for dispenser drops (41 section 2.5), pickup box and rules (41 section 4). The frame and painting drops of sections 4 and 5 use the 10-tick default through `spawnAtLocation` (5.2), and the armor stand's `Block.popResource` drops use 41 section 2.1.

## 14. Worked examples

**E1 Strafe y offset.** Player 48 blocks away horizontally: `0.4 + 48/80 - 1 = 0.0000000059604645` (the float 0.4 is `0.4000000059604645`), so the target Y is about the player's feet Y. 160 blocks: `0.4 + 2.0 - 1 = 1.4`. 1000 blocks: `0.4 + 12.5 - 1 = 11.9`, capped to 10.

**E2 Crystal destroyed in each phase.** Dragon in HOLDING_PATTERN, a player shoots a crystal with an arrow: `player` = the shooter (the arrow's owner), the dragon takes 10 to the head if that crystal was its nearest crystal, then `strafePlayer(player)`: phase STRAFE_PLAYER, `setTarget` builds `findPath(closest, goalNode, extra)`. Dragon in SITTING_SCANNING when the crystal dies: only the 10 damage (if nearest) and the fight bookkeeping.

**E3 Dragon breath cloud.** A cloud at `tickCount` 0 with `waitTime` 20 and `duration` 200: no application for ticks 0 to 19; the first application tick is 20 (`20 % 5 == 0`, the map is empty); a player inside radius 5 takes 3 damage (`int(0.5 * 6 + 0.5)`); the entry expires at 40 (`tickCount >= value`), so the next hit is at 40, 60, ...; the cloud is discarded at `tickCount = 220` (`220 - 20 >= 200`), after the last hit at 200: 10 hits, 30 damage in total.

**E4 Armor stand click slot.** Normal stand holding feet, chest and head items; click y 0.5: FEET (`0.1 <= 0.5 < 0.55`). Without a feet item and with legs: `0.5 >= 0.4 and < 1.2` and chest test first fails (`0.5 < 0.9`): LEGS. Click y 1.0: chest range 0.9 to 1.6: CHEST. Click y 1.7: HEAD. Click y 0.05: no test passes: MAINHAND (OFFHAND if the main hand is empty and the offhand is not). Small stand: `y = hit / 0.5`, so a hit at 0.25 above the feet tests as 0.5.

**E5 Armor stand two hits.** Hit at game time 100 by a player (not creative): `diff = 100 - lastHit` large and not always-kill: wobble (event 32), `lastHit = 100`. Hit at 103: `diff = 3 <= 5`: break; the stand item pops, the equipment pops one block up. An arrow (`always_kills_armor_stands`) breaks it on the first hit.

**E6 Painting choice.** A wall spot that is 2 blocks wide and 1 tall with a free, solid-backed area: every placeable variant of width at most 2 and height 1 survives; the largest area (2) is kept; one of the area-2 variants is chosen with `nextInt(count)`. A 1 x 1 spot yields a random area-1 variant.

**E7 Item frame comparator.** Empty: output 0. An item with rotation 3: 4. After 5 more right-clicks (rotation 8 stored as 0): output 1.

**E8 Feeding a baby happy ghast.** Age -24000 (a freshly hatched baby): `a = 24000`, `a / 20 = 1200`, `1200 * 0.1f = 120.00000447...` truncated to 120 seconds, `newAge = min(-24000 + 2400, 0) = -21600`. At age -100: `(-(-100)) / 20 = 5`, `5 * 0.1f = 0.5` truncated to 0 seconds: the item is consumed and the age does not change.

**E9 Dried ghast.** Block placed in water at tick 0 with hydration 0: a random tick schedules a block tick at +5000; at that tick hydration becomes 1 (waterlogged, `!= 3`); the next random tick schedules the next; the tick that finds hydration 3 removes the block and spawns a baby facing the block's `facing`. Out of water the same cadence decreases the level to 0.

**E10 Display interpolation.** `interpolation_duration` 20, `start_interpolation` 0, data changed at client tick 100: `interpolationStartClientTick = 100`; at tick 110 with partial 0.5: `(110 - 100 + 0.5) / 20 = 0.525`; the rendered translation is `lerp(0.525, previous, current)`, rotation `slerp(previous, current, 0.525)`. At tick 120 progress 1.0.

**E11 Lightning on a villager (Normal difficulty).** `thunderHit`: a witch replaces the villager (persistent, finalizeSpawn CONVERSION), the villager's POIs are released, and the `AbstractVillager` default does **not** run, so the old villager takes no lightning damage. On Peaceful (or if the conversion returns null) the default runs: the villager survives and takes the 5.0 damage.

**E12 Shulker bullet.** Bullet at block (10, 64, 10), target block (14, 64, 10), `axis = null`: the bullet is 4 away so it is not within 2.0 of `T`'s centre: candidates: X axis: `10 < 14` and east cell empty: EAST; Y: equal: none; Z: equal: none. One random direction is drawn anyway; the list is not empty so `EAST` is selected through `nextInt(1)`. The aim point = position + (1, 0, 0), `targetDelta = (0.15, 0, 0)`, `flightSteps = 10 + 10 * nextInt(5)`.

**E13 Happy ghast rider input.** Rider pitch 0, `zza > 0`, not jumping, FLYING_SPEED 0.05: `f = 1`, `v = -0`, scale `3.9000000953674316 * 0.05 = 0.19500000476837158`: input `(strafe * 0.195, 0, 0.195)`. Looking down 30 degrees with `zza < 0` and jumping: `f = cos(30 deg) * -0.5 = -0.433`, `v = (-sin(30 deg)) * -0.5 + 0.5 = 0.75`.

**E14 Cushion spawn box.** Click on the top of a hopper at click y = 65.5625 over block (4, 64, 7): spawn box x 4.0 to 5.0 and z 7.0 to 8.0 (block centre 4.5 and 7.5, half width 0.5), y 65.5625 to 65.8125; the hopper is in `cushion_uses_collision_shape`, so the click point is first re-clipped against the hopper's collision shape.

## 15. Validation

Assertions a test suite can make from this document:
1. Only the HOLDING_PATTERN phase reacts to `onCrystalDestroyed`; every other phase leaves the phase unchanged (section 1.1). After the hook the phase id is 1 only if the destroyer is a valid combat target.
2. `setTarget` returns a path whose last node is `(playerBlockX, floor(playerY + yOffset), playerBlockZ)`; `yOffset` values of E1.
3. Instant damage by a cloud: amplifier 0 = 3, amplifier 1 = 6 (healing 2 and 4); dragon breath total damage per full-lifetime visitor 30 (E3).
4. The armor stand click table (E4), the disabled-slot bit offsets 8 and 16 and the break timing (E5).
5. A pig struck on Peaceful is not converted; on Easy, Normal or Hard it becomes a zombified piglin; a turtle always dies; a mooshroom flips variant once per bolt UUID.
6. Item frame comparator values 0 and `rotation % 8 + 1`; painting survivors are filtered by `survives` before the largest-area filter.
7. A baby happy ghast fed once at -24000 reaches -21600; `canAgeUp` is false for an age-locked baby.
8. Dried ghast: hatch needs hydration 3 plus one more scheduled tick; block ticks are 5000 apart.
9. A shulker split only happens when the shulker is open and the teleport succeeded (the correction in 11.2).
10. Boss bar: the wither's bar flags 0x01 and colour PURPLE (05a 0x09), UUID per wither, setters send nothing when the value is unchanged.
11. Happy ghast: a 4th passenger is accepted, a 5th is not; a still-timeout ghast is solid and a flying one is not; the dismount point is the top centre (section 9.7).
12. Shulker teleport: at most 5 tries, offsets in -8 to 8, a target whose attachment block is bedrock is rejected (11.2).
13. Counts read in this round: painting variant files 51, placeable tag entries 47; harness items 16; display common metadata indices 8 to 22.

## 16. Open questions

Closed items are not listed here; they are answered in their sections (fire counter: 2.1; armor stand breaks: 4.4; dried ghast shape and ambience: 9.1 and 9.1.1; mannequin dimensions, loot and profile: 8.2; display piston reaction: 6.1; boss event operations: 10; happy ghast riding: 9.7 and 9.8; shulker teleport: 11.2; cushion context and spawn box: 8.1; tag members and `prevent_equipment_drop` carriers: 9.1.1, 11.2, 4.4).

1. **Display text rendering (client).** The `LineSplitter` implementation (wrap width, line measuring), the text opacity cut-off, shadow and see-through rendering and the item display context transforms. Searched: `Display$TextDisplay` (read completely for its fields and render-state ids; `LineSplitter` is only an interface there). The client renderer classes were not read; the owner is 12 client rendering.
2. **Level event 2016 (shulker teleport) and 2006 (dragon fireball cloud) client effects.** Only the sending side was read.
3. **Happy ghast leash pull and rider movement integration.** The generic `Leashable` elastic pull force and snap logic, the rotation of the four quad-leash offsets by yaw, and the generic controlled-vehicle travel path that calls `getRiddenInput` and `tickRidden` (ordering with the movement packets from the player) were not read; the owner is 18 framework.
4. **`HappyGhastAi` pairing of constants.** The mapping of the lambda constants 1.25 and 1.1 to `FollowTemptation` and the two `BabyFollowAdult` entries is (inferred) from the constants and their order; the behaviour classes' own arithmetic is generic (18 framework).
5. **Armor stand held-item slot.** The slot chosen for a held item without a usable `equippable` component (section 4.3 step 3) is (inferred) as the main hand.
6. **Server-side mannequin profile resolution.** No server caller of `ResolvableProfile.resolveProfile` exists in this jar (section 8.2); whether another build resolves it on the server is not determinable here.
7. **Generic entity-tick rules** beyond the fire counter (`clearFreeze`, other `baseTick` effects) belong to a generic entity-tick document (41 section 5.3 covers items only).
8. **Recall.** Every value in this document was read from the artifact in this round, including the previously unverified items (armor stand default poses, the scan box, the dragon fireball cloud numbers, the End city Elytra rotation and the structure NBT count, each with its trace above). Statements marked "(inferred)" (section 4.3 step 3, section 9.7 `FollowTemptation` pairing) are listed in questions 4 and 5; nothing is marked "(recalled, not verified)".
