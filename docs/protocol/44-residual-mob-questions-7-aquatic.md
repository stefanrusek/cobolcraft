# Residual mob questions, part 7: aquatic mobs, nautilus family, amphibian sensors

| Item | Value |
|---|---|
| Covers | The residual open questions of the aquatic mobs: fish flop spacing, the dolphin on-ground hop guard, the player filter of the elder guardian's effect helper, squid and dolphin experience and breeding, the axolotl (play-dead damage test, rare variant, air refill, hunting sensor, supporting effects), the whole nautilus family (idle behaviours, ride and dash control, tame-state bits, armor, the charge attack, the temptation sensor, the zombie nautilus brain), the frog attack sensor, the dolphin jump goal, the water movement and look controls and the swim navigation as used by each aquatic mob, and pointers for 19 Open questions 1 and 2 |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the small JSON tag and variant files inside the jar, with no execution. Every value was read in this round. Nothing was taken from memory; where something could not be read it is marked "(inferred)" and listed in the Open questions. |
| Status | Round RS26, part 7. It answers questions left open by [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) (Open questions 7 to 10), by [18](18-mob-framework.md) (Open question 3, amphibian side) and by [19](19-mobs-land-friendly-and-neutral.md) (Open questions 1 and 2). Where this document disagrees with 21 section 4, this document is the later reading and wins (section 3 lists each correction). |

Class names in backticks (`Axolotl`, `ChargeAttack`) say where a fact was read; they are not the design. "NN section N" forms such as "18 section 4.3" and "21 section 4.7" are cross-references to the exact section of an existing document; their content is not repeated. A bare document number
("05c", "17") is never used as a reference: it always carries a section or packet name. Data files (loot tables, recipes, tag lists, the
two zombie nautilus variant files) are extracted by the data tool; this document gives the engine that interprets them and quotes a tag
or variant file only where the engine's behaviour cannot be understood without its few entries. Tick = 1/20 s; distances are
blocks; "uniform(a, b)" is the inclusive integer range.

## Contents

1. [Scope map](#1-scope-map)
2. [Shared building blocks read here](#2-shared-building-blocks-read-here)
3. [Corrections to 21 section 4](#3-corrections-to-21-section-4)
4. [Fish flop and dolphin hop](#4-fish-flop-and-dolphin-hop)
5. [Elder guardian: the effect helper](#5-elder-guardian-the-effect-helper)
6. [Squid, glow squid and dolphin: experience, breeding, babies, feeding](#6-squid-glow-squid-and-dolphin-experience-breeding-babies-feeding)
7. [Dolphin jump goal](#7-dolphin-jump-goal)
8. [Axolotl](#8-axolotl)
9. [Sensors: axolotl_attackables, frog_attackables, nautilus_temptations](#9-sensors)
10. [Nautilus and zombie nautilus](#10-nautilus-and-zombie-nautilus)
11. [Water movement controls, look controls and swim navigation per mob](#11-water-movement-controls-look-controls-and-swim-navigation-per-mob)
12. [Pointers for 19 Open questions 1 and 2](#12-pointers-for-19-open-questions-1-and-2)
13. [Worked examples](#13-worked-examples)
14. [Validation](#14-validation)
15. [Open questions](#15-open-questions)

## 1. Scope map

| Question | Answered in |
|---|---|
| 21 Open question 7: fish flop spacing | 4.1 |
| 21 Open question 7: dolphin on-ground hop guard | 4.2 |
| 21 Open question 7: `MobEffectUtil.addEffectToPlayersAround` filter | 5 |
| 21 Open question 8: squid XP reward | 6.1 |
| 21 Open question 8: breeding foods of squid and dolphin | 6.2 to 6.4 |
| 21 Open question 9: axolotl play-dead damage test | 8.3 |
| 21 Open question 9: where `useRareVariant` is applied | 8.2 |
| 21 Open question 9: use of `REHYDRATE_AIR_SUPPLY` | 8.4 |
| 18 Open question 3 and 21 Open question 9: `axolotl_attackables` sensor | 9.1 |
| 18 Open question 3: `frog_attackables` sensor | 9.2 |
| 21 Open question 10: nautilus idle behaviours | 10.5 |
| 21 Open question 10: ride and dash control | 10.4 |
| 21 Open question 10: tame-state bits | 10.2 |
| 21 Open question 10: armor | 10.3 |
| 21 Open question 10: `ChargeAttack` internals | 10.6 |
| 21 Open question 10: `NAUTILUS_TEMPTATIONS` sensor | 9.3 |
| 21 Open question 10: `ZombieNautilusAi` | 10.8 |
| Pool and water movement controls, swim navigation (not read in 21 section 4) | 11 |
| Aquatic not-traced items (dolphin jump goal, dolphin travel, squid group data) | 6.3, 7, 11 |
| Former Open question 7 of this document (21 section 4.6): `DolphinSwimToTreasureGoal`, `DolphinSwimWithPlayerGoal` | 7.2 |
| Generic `TargetingConditions.test` order; order of the nearest-entity list | 2.7, 2.8 |
| Equip, shear and dispenser dispatch for BODY and SADDLE items | 10.3.1 |
| Server validation of a ridden vehicle's reported position; nautilus bubble rule | 10.4.1, 10.4.2 |
| Fish, schooling, pufferfish and tadpole (not re-read here) | 1.1 |
| 19 Open questions 1 and 2 | 12 |

### 1.1 Aquatic siblings covered elsewhere

This document does not re-read the fish and tadpole classes; it makes no claim about them beyond these pointers.

| Mob or rule | Where it is specified |
|---|---|
| Fish goal list (panic, avoid player, random swim, schooling), `FishMoveControl`, schooling leader and follower rules, `AbstractFish` spawn cluster | 21 section 4.1 and 44-1 RQ-1.14 (cluster and school size) |
| Cod, salmon, pufferfish, tropical fish data | 21 section 4.2 |
| Pufferfish inflation (puff) | 21 section 4.3 |
| Tropical fish variants | 21 section 4.4 |
| Fish flop and air rules | corrected and completed here: 4.1 and 2.6 |
| Tadpole (growth into a frog, brain) | 19 section 11.2; its conversion use in 44-1 |
| Squid, glow squid, dolphin | 21 sections 4.5 and 4.6, completed here in 6, 7 and 11 |
| Guardian and elder guardian | 21 section 4.8, helper in 5 here |
| Turtle | 21 section 4.12 |

## 2. Shared building blocks read here

These are used by several sections below. They are engine rules, not mob data.

### 2.1 Ageable mob spawn group data (`AgeableMob`, `AgeableMobGroupData`)

A spawn group data object has three fields: `shouldSpawnBaby` (boolean), `babySpawnChance` (float) and a group size (starts at 0).
Constructors: `(boolean)` uses chance **0.05**; `(float)` sets `shouldSpawnBaby = true` with that chance; `(boolean, float)` sets both.

`AgeableMob.finalizeSpawn(level, difficulty, reason, groupData)`:

1. If `groupData` is null, create one with `(true)`, that is chance 0.05.
2. If `shouldSpawnBaby` is true **and the group size is greater than 0** and `nextFloat() <= babySpawnChance` (drawn from the level's random source),
   the mob becomes a baby: `age = getBabyStartAge()` = **-24000** (`BABY_START_AGE`).
3. The group size is increased by 1.
4. The superclass `finalizeSpawn` runs.

So the first mob of a group is never a baby from this rule; each later member is a baby with the group's chance. When the natural spawner
reuses one group data object for all members of a pack (18 section 6.5), the chance applies to the second member onward.

### 2.2 Golden dandelion (age lock)

`AgeableMob.mobInteract`: a player holding a golden dandelion on a **baby** whose `ageLockParticleTimer` is 0 and whose entity type is not in tag
`cannot_be_age_locked` (zombie horse, skeleton horse, villager) toggles the age lock (`setAgeLocked`) and the result is SUCCESS; otherwise the
interaction continues with `PathfinderMob.mobInteract`. The toggle is, in this order (`setAgeLockedData`, then the static `setAgeLocked`):

1. the locked flag is flipped;
2. the age is set to the baby start age, **-24000**;
3. `ageLockParticleTimer` is set to **40**;
4. one golden dandelion is consumed from the player's stack;
5. if the flag is now "locked", persistence is required (`setPersistenceRequired`);
6. a sound is played at the mob's block position with no excluded player, in the PLAYERS source, volume 1 and pitch 1: `golden_dandelion_use` when the mob is now locked, `golden_dandelion_unuse` when it is now unlocked.

So unlocking also resets the age to -24000 and also costs a dandelion. Squid, glow squid, dolphin, axolotl and the nautilus are all age-lockable by this rule.

### 2.3 `NearestVisibleLivingEntitySensor` (base of the axolotl and frog hunting sensors)

A sensor with a memory to set (here `NEAREST_ATTACKABLE`) and a per-entity predicate `isMatchingEntity(level, self, other)`. Each sensor tick it takes
the memory `NEAREST_VISIBLE_LIVING_ENTITIES` (the entities that the `NEAREST_LIVING_ENTITIES` sensor found and that are visible, 18 section 4.6, shared sensors), asks `NearestVisibleLivingEntities.findClosest(predicate)` for the closest entity that matches, and stores the result (an empty optional
clears the memory). It requires both memories (its target memory and `NEAREST_VISIBLE_LIVING_ENTITIES`).
`NearestLivingEntitySensor` stores `NEAREST_LIVING_ENTITIES` already sorted by `Entity.distanceToSqr` (squared distance, ascending, a `comparingDouble` sort), and `findClosest(predicate)` walks that list **in
order** and returns the first entity that passes both the given predicate and the stored line-of-sight test (`lineOfSightTest`, `Sensor.isEntityTargetable`, cached per entity). So "closest" means smallest squared distance; ties keep the list order (the order in which the
level returned the entities, as the sort is stable; that order is read in 2.8).

### 2.4 `Sensor.isEntityAttackable`

`isEntityAttackable(level, self, other)` evaluates `TargetingConditions` (18 section 4.3; the generic test order is in 2.7): the combat conditions with range 16. If the Brain's `ATTACK_TARGET`
memory already equals `other`, the variant that **ignores the invisibility test** is used; otherwise the plain combat conditions. The variant
`isEntityAttackableIgnoringLineOfSight` uses the same two forms with line of sight ignored (and for the current target, invisibility ignored too).
The six static condition objects of `Sensor` are: non-combat range 16, non-combat range 16 without invisibility test (used by other sensors), combat range 16, combat range 16 without invisibility test, combat
range 16 without line of sight, and combat range 16 without line of sight and without invisibility test (all with range 16).

### 2.5 `TemptingSensor`

`TemptingSensor` has one public constructor, one static factory and one private constructor that stores a `BiPredicate(mob, stack)`: the public `TemptingSensor(itemPredicate)` wraps the item predicate so that the mob argument is ignored, and the factory `forAnimal()` stores a test that
holds when the mob is an `Animal` and `mob.isFood(stack)`. It writes memory `TEMPTING_PLAYER`. Every sensor tick (server): among all players of the mob's level that are not
spectators (`NO_SPECTATORS`), keep those that pass non-combat `TargetingConditions` with line of sight ignored and range = the mob's `tempt_range` attribute
(18 section 4.2, `TemptGoal`, default 10), that hold a matching item in the main hand or the off hand (`itemPredicate`), and that are **not a passenger of the
mob**; sort ascending by `Entity.distanceToSqr(mob)` (squared distance, a `comparingDouble` sort); the first becomes `TEMPTING_PLAYER`, and if there is none the memory is erased. `FOOD_TEMPTATIONS` is the `forAnimal()` form (the mob's own `isFood`);
`FROG_TEMPTATIONS` and `NAUTILUS_TEMPTATIONS` give their own item predicates.

### 2.6 Air supply defaults

`LivingEntity.shouldTakeDrowningDamage` is true when the air supply is **<= -20**. `Entity.isInWaterOrRain` is `isInWater` or `isInRain`. The
`WaterAnimal`, `AgeableWaterCreature`, `Axolotl` and `Nautilus` air handlers all follow the pattern: while alive and not in water (axolotl: not in water or rain) the air
falls by 1 per tick, and when it is at or below -20 it is reset to **0** and the mob takes 2 damage (`dryOut` for axolotl and nautilus, `drown` for
`WaterAnimal`/`AgeableWaterCreature`); in water the air is set to the mob's maximum. Because the reset is to 0, repeated damage then comes every 20 ticks.
Per-mob maxima: fish and squid 300 (the value set in the handler), axolotl 6000, nautilus 300, dolphin 4800 (and its handler does nothing).

### 2.7 `TargetingConditions.test(level, attacker, target)`: the generic order

`attacker` may be null (a level query with no mob); `target` is the entity being tested. The object carries five fields set by its builders: `isCombat`, `range` (a value of 0 or less means no range limit), `checkLineOfSight`, `testInvisible` and an optional `selector` (`(entity, level) -> boolean`); the factory defaults are in 18 section 4.3. The test is, in this order, each step returning false when it fails:

1. `target` is the same entity as `attacker`: false.
2. `target.canBeSeenByAnyone()` is false: false.
3. A selector is set and `selector(target, level)` is false: false.
4. **`attacker` is null**: if the conditions are non-combat the result is **true at once** (range and line of sight are not tested). If they are combat, the result is true only when `target.canBeSeenAsEnemy()` holds **and** the level's difficulty is not PEACEFUL; steps 5 to 7 are skipped.
5. **`attacker` present, combat conditions**: false when `attacker.canAttack(target)` is false or `attacker.isAlliedTo(target)` is true.
6. **Range**, only when `range > 0`: `visibility` = `target.getVisibilityPercent(attacker)` when `testInvisible` is set, otherwise 1.0; `r` = `max(range x visibility, 2.0)`; false when the squared distance from the attacker to the target's position is greater than `r x r` (equality passes). The formula of `getVisibilityPercent` was not read (Open question 5).
7. **Line of sight**, only when `checkLineOfSight` is set **and the attacker is a `Mob`**: false when `mob.getSensing().hasLineOfSight(target)` is false. A non-mob attacker never fails this step.
8. Otherwise true.

Worked example: combat conditions with range 16 and invisibility testing, attacker a mob, target a player for whom `getVisibilityPercent` returns 0.5 (an assumed input): `r` = max(8, 2) = 8, so a target 9 blocks away fails at step 6 and a target 8 blocks away passes it. With the same conditions and visibility 0.05 the floor applies: `r` = 2.

### 2.8 Order of the nearest-entity list (closing the tie question of 2.3)

`NearestLivingEntitySensor` (read) asks `ServerLevel.getEntitiesOfClass(LivingEntity, box, predicate)` where `box` is the mob's bounding box inflated by its `follow_range` attribute value on all three axes and the predicate accepts every living entity that is not the mob itself and is alive; the list is then sorted by squared distance with `List.sort` (stable by the standard library's contract, (inferred), not read). That the level call reaches `EntitySectionStorage` unchanged is (inferred); the storage was read:

1. `EntitySectionStorage.forEachAccessibleNonEmptySection` visits the **section columns by section x ascending**, from the section of the box's minimum x to that of its maximum x.
2. For each x it takes the sorted set of section keys between the key `(x, y 0, z 0)` and the key `(x, y -1, z -1)` and walks it in ascending order as a **signed 64-bit** number, skipping sections whose y or z lie outside the box, empty or inaccessible ones. The key is `(x & 0x3FFFFF) << 42 | (z & 0x3FFFFF) << 20 | (y & 0xFFFFF)` (masks and shifts read in `SectionPos.asLong`). Within one x the walk is therefore **z first, then y**; and because the masked two's-complement fields of negative values are larger than those of non-negative values, **z values from 0 upward come first in ascending order, followed by the negative z values in ascending order**; for equal z, y behaves the same way (0 and up, then negative y; in the overworld this puts the sections below y 0 last). (This sign ordering is derived from the mask constants read; (inferred) as arithmetic, not observed.)
3. Inside a section the entities come from `EntitySection.getEntities(typeTest, box, consumer)`, which walks `ClassInstanceMultiMap.find(class)`, a per-class array list, and keeps those whose bounding box intersects the query box. The list order is the order in which entities were added to the section ((inferred): the structure holds `ArrayList`s; the add order itself was not traced).

Ties in squared distance therefore keep this traversal order. The dispenser's "first entity" rule (10.3.1) uses the same level call.

## 3. Corrections to 21 section 4

"Replaces" names the exact place in 21 (or 18 and 19) that an editor folding this part into 18 to 21 should rewrite, and "Removes" the Open question of that document that this reading closes.

| 21 section | Statement in 21 | Reading in this round | Replaces | Removes |
|---|---|---|---|---|
| 4.1, "Out of water" | the further conditions that space the flops were not read | there are none: the flop happens on every tick on which the fish is not in water, on the ground, and has a vertical collision (4.1) | 21 section 4.1, the "Out of water" sentence | 21 Open question 7 (flop spacing part) |
| 4.5, Ageable row | squid and glow squid "breed into their own type" | no food, no love mode and no breeding goal exists for squid or glow squid; the offspring method is reachable only through the spawn egg used on a mob of the same type, which makes a baby (6.2; 18 section 6.12) | 21 section 4.5, the "Ageable" row | 21 Open question 8 (breeding part) |
| 4.5, XP row | XP "not read" | `1 + nextInt(3)`, i.e. 1 to 3, from `AgeableWaterCreature.getBaseExperienceReward` (6.1) | 21 section 4.5, the "XP" row | 21 Open question 8 (XP part) |
| 4.6, moisture rule | hop "surrounding guard conditions displayed only partially" | the hop is guarded only by "not in water or rain" and "on ground" (4.2) | 21 section 4.6, the "Moisture" bullet under "Rules" | 21 Open question 7 (hop part) |
| 4.6, Dolphin | the dolphin has no breeding food | correct: no breeding; the fish tag only speeds up a baby or sets `gotFish` (6.3) | 21 section 4.6, the "Feeding" bullet (add the baby age-up rule of 6.4) | none |
| 4.6, Treasure goal | fallback targets "distance 8 with 90 degrees and then 8 with height 5"; "every `1/80` tick sample" | three position tries with vertical reaches 1, 4 and 5 (the third only when the earlier try is missing or its block is not water-pathable), and one event-38 broadcast per goal evaluation with probability 1/40 (7.2) | 21 section 4.6, the "Treasure goal" bullet | none in 21; this document's former Open question 7 is closed by 7.2 |
| 4.6, Swim with player | description | agrees; adds that the goal has flags MOVE and LOOK, that the nearest-player query uses non-combat conditions with range 10 and no line of sight, and the exact tick order (7.2) | 21 section 4.6, the "Swim with player" bullet | none |
| 4.7, Variants | `useRareVariant` use unknown | only inside the axolotl's `getBreedOffspring`, which has two callers: breeding and the spawn egg used on an axolotl (8.2) | 21 section 4.7, the "Variants" paragraph | 21 Open question 9 (rare variant part) |
| 4.7, Air | `REHYDRATE_AIR_SUPPLY` use not traced | a splashed or lingering water potion refills 1800 (8.4) | 21 section 4.7, the "Air" paragraph, last sentence | 21 Open question 9 (rehydrate part) |
| 4.7, Play dead | branch structure "read from bytecode order" | the exact test is given in 8.3 | 21 section 4.7, the "Play dead (`hurtServer`)" paragraph, last sentence | 21 Open question 9 (play-dead part) |
| 4.7, Supporting effect | "`extra` inferred from the branch" | read: whole Regeneration grant is gated; Mining Fatigue is always removed (8.5) | 21 section 4.7, the "Supporting effect" paragraph | 21 Open question 9 (supporting part) |
| 4.7, IDLE row | "two conditional movers" | they are two predicate-only triggers, in water and on ground (8.6) | 21 section 4.7, the IDLE row of the activity table (its priority 4 entry) | none (also completes 18 Open question 3 for the axolotl IDLE row) |
| 4.7, Variants (group data) | the group data picks the variant | confirmed and completed by 8.1 (two variants per pack, baby rule from group size 2) | 21 section 4.7, the "Variants" paragraph, group-data sentences | none |
| 4.8, Elder guardian | "Game Event packet 10 with value 1 ... unless silent" | the packet is sent to every returned player; its value is 0 when the elder is silent and 1 otherwise (5) | 21 section 4.8, the elder guardian effect sentence (and the matching clause of 21 section 4.8 beside the Game Event list in 21 section 1) | 21 Open question 7 (filter part) |
| 4.10 | `ChargeAttack(80, ..., 0.6, 2, 12.0, 11.0, ...)` | argument roles are given in 10.6 (distance 12.0 is the maximum charge distance, 11.0 the maximum target detection distance) | 21 section 4.10, the `ChargeAttack` sentence in the Nautilus brain paragraph | 21 Open question 10 (`ChargeAttack` part; the idle, ride, tame, armor, temptation and zombie brain parts are closed by 10.2 to 10.8) |

## 4. Fish flop and dolphin hop

### 4.1 Fish flop (`AbstractFish.aiStep`)

Every tick, on both the server and the client side (there is no side guard), before the ordinary `WaterAnimal.aiStep`: when the fish is **not in water**,
`onGround()` is true and `verticalCollision` is true, then:

1. velocity += `(x, 0.4000000059604645, z)` with `x = (nextFloat() * 2 - 1) * 0.05` and `z = (nextFloat() * 2 - 1) * 0.05`, the first draw for x
   and the second for z (the mob's own random source);
2. `onGround` is set to false;
3. `needsSync` is set to true;
4. the fish's flop sound (`getFlopSound`, a per-species sound event) is made.

There is no random chance and no cooldown. The spacing of flops comes from physics: step 2 clears the ground flag, so the next flop needs the fish to
fall back to the ground and register a vertical collision again. A fish resting on a block with the collision flag unset does not flop.

### 4.2 Dolphin hop (`Dolphin.tick`, after `AgeableWaterCreature.tick`)

1. If `isNoAi`: set the air supply to the maximum (4800) and stop.
2. If `isInWaterOrRain`: moistness = 2400.
3. Otherwise: moistness = moistness - 1; if the new moistness is <= 0, `hurt(dryOut, 1)` is called (on every tick; see the hurt-window note below); then, **if `onGround()`** (this test is made in the same branch,
   whether or not the moistness is zero): velocity += `((nextFloat()*2-1) * 0.2, 0.5, (nextFloat()*2-1) * 0.2)` (x drawn first), yaw = `nextFloat() * 360`,
   `onGround` = false, `needsSync` = true.

The `hurt(dryOut, 1)` call is made every tick, but damage lands only about every 10 ticks: per 18 (section on `hurt`, step 6), while `invulnerableTime > 10` a hit with `amount <= lastHurt` is rejected unless the source is in `bypasses_cooldown`, and that tag is empty in this jar. The first hit sets `invulnerableTime` to 20 and `lastHurt` to 1; the next 9 calls are rejected (the value falls from 20 to 11) and a hit lands again once it reaches 10 (see 13.2).

So a dry dolphin on the ground hops on every tick on which it stands on the ground; only the "dry" condition (not in water or rain) and the ground flag guard it.
Client-only: while in water with velocity squared length above 0.03, two `DOLPHIN` particles per tick are added behind the dolphin (not specified further).

`Dolphin.finalizeSpawn` first sets the air supply to the maximum (4800) and `xRot` to 0, and only then supplies the default `AgeableMobGroupData(0.1f)` (6.3) when none is given and calls the `AgeableWaterCreature` superclass.

Other dolphin routines read here: `canAttack` is false for a baby; `increaseAirSupply` returns the maximum (4800); `handleAirSupply` does nothing;
max head turn is 1 on both axes (`getMaxHeadXRot`, `getMaxHeadYRot`); `travelInWater` is: accelerate with `moveRelative(speed)`, move, multiply velocity by
0.9, and subtract 0.005 from vertical velocity when there is no attack target (this is **not** the whole vertical story: the dolphin's `SmoothSwimmingMoveControl` has `applyGravity` true (section 11), and that control's `tick` adds 0.005 to the vertical velocity on every tick on which the dolphin is in water (constant 0.005 read in `SmoothSwimmingMoveControl.tick`; 18 section 4.4), so for an idle dolphin the two cancel and the net vertical drift is 0; with an attack target only the +0.005 remains); `closeToNextPos` is true when the navigation target position is within 12 blocks
of the dolphin (distance to the block centre); a dolphin picks up one item at a time into the main hand (`pickUpItem`, 21 section 4.6).

## 5. Elder guardian: the effect helper

`ElderGuardian.customServerAiStep`, server side: after the ordinary guardian step, when `(tickCount + entityId) % 1200 == 0`, the elder builds the effect
instance Mining Fatigue, duration **6000**, amplifier **2**, and calls `MobEffectUtil.addEffectToPlayersAround(level, source = the elder, centre = the elder's position, radius 50.0, effect, displayLimit 1200)`.

Separately, and outside that periodic branch (it is tested on **every** server AI step): if the elder has no home, `setHomeTo(blockPosition, 16)`.

`addEffectToPlayersAround` builds the list of **all players of that level** (`ServerLevel.getPlayers`, so other dimensions are excluded) that pass **all** of:

| Order | Test |
|---|---|
| 1 | the player's game mode is survival or adventure (`ServerPlayerGameMode.isSurvival`, which delegates to `GameType.isSurvival`: SURVIVAL or ADVENTURE; creative and spectator are excluded) |
| 2 | the source entity is null **or** it is not allied to the player (`Entity.isAlliedTo`, the team test; 18 section 4.3 states the same team rule for target goals) |
| 3 | the centre is closer than the radius: `distanceSqr(player position, centre) < radius^2` (here 2500; a player exactly 50 away is excluded) |
| 4 | the player does not have the effect, **or** the player's current instance has a **lower amplifier** than the new instance, **or** the current instance is finite and `duration <= displayLimit - 1` (here <= 1199 ticks left; an infinite duration never qualifies) |

Every player in the list receives `addEffect(copy of the instance, source = the elder)` (effect application rules: no section of 17 or 18 specifies `addEffect` itself, see Open question 9; the attack-speed modifier of Mining Fatigue is in 17 section 4.1). The helper returns the
same list; the elder then sends each returned player a Game Event packet of type "guardian elder effect" (05a section 0x27 Clientbound Game Event) whose value is **0 if the elder is
silent, otherwise 1** (the packet is sent either way; the value is the sound/curse-overlay switch). Players that failed the filter, for example those
that still have more than 1199 ticks of Mining Fatigue III, get neither the effect nor the packet.

## 6. Squid, glow squid and dolphin: experience, breeding, babies, feeding

### 6.1 Experience

`AgeableWaterCreature` overrides `getBaseExperienceReward` to `1 + nextInt(3)`, that is **1, 2 or 3** with equal probability. Neither `Squid`,
`GlowSquid` nor `Dolphin` overrides it. This override replaces the generic `Mob` rule of 18 section 7.6, so the equipment bonus of that rule does not apply to them.
It applies as 18 section 7.5 (death) and 7.6 (experience) describe for the killed-by-player condition. (`WaterAnimal`, the fish base, has the same formula; the guardians set their own field, 21 section 4.8.)

### 6.2 No breeding, but spawn-egg babies

`Squid`, `GlowSquid` and `Dolphin` extend `AgeableWaterCreature` (an `AgeableMob`), not `Animal`. They register no breed goal, no `AnimalMakeLove` behaviour,
no food items and no love-mode state. Consequently there is **no breeding food** for squid, glow squid or dolphin. (Searched: the squid goals are only `SquidRandomMovementGoal` and
`SquidFleeGoal`; the dolphin goal list is in 21 section 4.6.) Their `getBreedOffspring` methods (create a squid, glow squid or dolphin with reason BREEDING) are nevertheless **reachable** through the spawn egg
(`SpawnEggItem.spawnOffspringFromSpawnEgg`, 18 section 6.12), which calls `getBreedOffspring(level, mob)` with the **clicked mob as both parents** for any `AgeableMob` when the egg's entity type equals the mob's type:

1. the child is created by `getBreedOffspring`; a null result (the zombie nautilus) ends the use with nothing spawned and no egg consumed; (for a non-ageable mob the egg's type is created instead with reason `SPAWN_ITEM_USE`);
2. `setBaby(true)` is applied; if the child is still not a baby afterwards, the result is empty and nothing is spawned;
3. otherwise the child is placed at the given position with rotation 0, the item components are applied, it is added to the level with its passengers, and one egg is consumed.

So a squid, glow squid or dolphin egg used on a squid, glow squid or dolphin of the same type creates a baby of that type. An axolotl child made this way also goes through the 1/1200 blue roll (8.2), and a nautilus child copies the owner and the tame flag from the
clicked nautilus (10.1). `getBreedOffspring` therefore has two callers in total, breeding (animals only) and the spawn egg.

### 6.3 Babies

| Mob | Group data when none is supplied | Baby size |
|---|---|---|
| Squid | `AgeableMobGroupData(0.05f)` | 21 section 4.5 |
| Glow squid | same as squid (inherited) | same |
| Dolphin | `AgeableMobGroupData(0.1f)`; before this, `finalizeSpawn` sets air supply 4800 and `xRot` 0 (4.2) | scale 0.65, 21 section 4.6 |

Rule 2.1 applies: the first mob of a spawned group is never a baby; each later member is a baby with the chance above. A baby has age -24000 and grows
up as an `AgeableMob` does (its age counts up each tick; `ageBoundaryReached`; 18 section 8.1). A baby squid or dolphin can be age-locked (2.2).

### 6.4 Feeding a dolphin

`Dolphin.mobInteract`: holding an item in item tag `fishes` (cod, cooked cod, salmon, cooked salmon, pufferfish, tropical fish): on the server
the eating sound plays; if `canAgeUp()` (it is a baby that is not age-locked) the item is consumed (1) and the baby ages up by
`getSpeedUpSecondsWhenFeeding(-age)` seconds (forced); otherwise `gotFish` is set true and one item is consumed. The result is SUCCESS in both cases. Without a fish the
interaction goes to `AgeableMob.mobInteract` (2.2). Squid have no feeding interaction apart from 2.2.

## 7. Dolphin jump goal

`DolphinJumpGoal(dolphin, interval = 10)`; it is registered at priority 5 and extends `JumpGoal`, whose flags are MOVE and JUMP. The stored `interval` is
`reducedTickDelay(10)` = **5** (18 section 4.1, tick-delay scaling). The goal is **not interruptible**.

Constant `STEPS_TO_CHECK` = six entries, read element by element: **0, 1, 4, 5, 6, 7**.

`canUse`: it passes only with probability `1 / interval` (`nextInt(5) == 0` on an evaluation). It then takes the dolphin's horizontal facing direction
(`getMotionDirection` = the horizontal `Direction` nearest the yaw, `Direction.fromYRot`; step vector `(dx, dz)`) and the dolphin's block position `p`. For **each**
`s` in `STEPS_TO_CHECK`, in that order, both of these must hold, and the first step for which one fails makes `canUse` false:

1. `waterIsClear(s)`: the block `p + (dx*s, 0, dz*s)` has a water fluid state **and** its block state is not in block tag `blocks_dolphin_jump` (this tag is read as `#blocks_motion`);
2. `surfaceIsClear(s)`: both blocks `p + (dx*s, 1, dz*s)` and `p + (dx*s, 2, dz*s)` are air.

If all six steps pass, `canUse` is true. In words: the dolphin needs open water in front of it at the offsets 0, 1, 4, 5, 6 and 7 blocks, with two blocks of air above the water at each of those offsets.

`canContinueToUse` is true while the dolphin is **not on the ground**, and not (`vy^2 < 0.03` and `xRot != 0` and `|xRot| < 10` and in water). In plain terms: the jump ends
when the dolphin touches the ground, or when it has re-entered the water with a nearly level velocity and a small, nonzero pitch.

`start`: velocity += `(dx * 0.6, 0.7, dz * 0.6)` (horizontal direction as above), then stop the navigation. `stop`: `xRot = 0`.

`tick`:

1. Remember the old `breached` flag. If it was false, set it to "the dolphin's block has a water fluid state". If it is now true and was false, play the `DOLPHIN_JUMP` sound (volume 1, pitch 1).
   (The flag is set only here and is **never reset** by `start` or `stop`, so the sound plays at most once per goal instance, that is once per dolphin until it is reloaded.)
2. Pitch: if `vy^2 < 0.03` and `xRot != 0`, then `xRot = rotLerp(0.2, xRot, 0)` (move 20% of the way to level); otherwise, if the velocity length exceeds 1.0E-5,
   `xRot = atan2(-vy, horizontalSpeed)` converted to degrees by multiplying with the constant **57.2957763671875** (read in `DolphinJumpGoal.tick`; `SmoothSwimmingMoveControl` uses the same constant; it differs from 180/pi in the 7th digit), where `horizontalSpeed` is `Vec3.horizontalDistance` of the velocity (nose along the velocity).

### 7.1 Dolphin item goals (`MoveToItemGoal`, `PlayWithItemsGoal`, `ItemGoal`)

The dolphin's goal list as registered (priority, goal): 0 `BreathAirGoal`; 0 `TryFindLiquidGoal` (fluid tag `dolphin_tries_to_find`); 1 `DolphinSwimToTreasureGoal` (7.2); 2 `DolphinSwimWithPlayerGoal(4.0)` (7.2); 4 `RandomSwimmingGoal(speed 1.0, interval 10)`;
4 `RandomLookAroundGoal`; 5 `LookAtPlayerGoal(Player, 6.0)`; 5 `DolphinJumpGoal(10)`; 6 `MeleeAttackGoal(speed 1.2000000476837158, true)`; 7 `MoveToItemGoal`; 8 `PlayWithItemsGoal`; 8 `FollowPlayerRiddenEntityGoal(AbstractBoat)`; 8 `FollowPlayerRiddenEntityGoal(AbstractNautilus)`;
9 `AvoidEntityGoal(Guardian, 8.0, 1.0, 1.0)`; target selector priority 1 `HurtByTargetGoal` constructed with the class list {Guardian} and `setAlertOthers` called with an empty class list (the meaning of the two lists is by 18 section 4.3, `HurtByTargetGoal`; not re-derived here). Goal internals other than those below are in 18 section 4.2.

- **Allowed items** (`ALLOWED_ITEMS`, for an `ItemEntity`): it has **no pickup delay**, is alive and is **in water**.
- **Pickup** (`pickUpItem`): only when the main hand is empty and `canHoldItem(stack)` holds; the dolphin takes the whole stack into the main hand, marks the main hand as a guaranteed drop, the item entity is taken (pickup animation) and discarded.
- **`MoveToItemGoal`** (priority 7, flag MOVE). It keeps a `cooldown` (a game-tick count, starting at 0). `canUse`: `cooldown <= tickCount` **and** at least one allowed item entity lies in the dolphin's bounding box inflated by 8.0 in all three axes.
  `start`: if such an item exists, navigate to the **first** one in the returned list at speed **1.2000000476837158** and play `DOLPHIN_PLAY` (volume 1, pitch 1); then `cooldown = 0`. `tick`: if an allowed item exists in the same box, keep navigating to the first one at the same speed.
  `stop`: runs `dropItem`; if something was dropped, `cooldown = tickCount + nextInt(100)`.
- **`PlayWithItemsGoal`** (priority 8, no flags set): `canUse` is "the main hand is not empty". `stop` and `tick` each call `dropItem`. `dropItem` returns false when the main hand is empty; otherwise it drops the held stack and empties the hand (returning true). The dropped item entity
  starts at the dolphin's x and z and at eye height - 0.3 (constant 0.30000001192092896), gets pickup delay **40** and the dolphin as thrower. Its velocity (`ItemGoal.drop`, read) uses two draws from the dolphin's own random source, in this order:
  `angle = nextFloat() x 6.2831855`, then `spread = 0.02 x nextFloat()`. With `yaw` = the dolphin's `yRot` and `pitch` = its `xRot`, both converted to radians by multiplying by 0.017453292:

  | Component | Value |
  |---|---|
  | vx | `0.3 x (-sin(yaw)) x cos(pitch) + cos(angle) x spread` |
  | vy | `0.3 x sin(pitch) x 1.5` (no random term) |
  | vz | `0.3 x cos(yaw) x cos(pitch) + sin(angle) x spread` |

  Worked example: a level dolphin (pitch 0) with yaw 0 and draws giving `angle` = 0 and `spread` = 0.01 throws with velocity (0.01, 0, 0.3).
  Since `tick` calls `dropItem` immediately, a dolphin that holds an item and runs this goal gets rid of it on the first tick (the pickup delay then stops it from picking the item up straight away).

The two remaining goals, `DolphinSwimToTreasureGoal` (priority 1) and `DolphinSwimWithPlayerGoal(4.0)` (priority 2), are read in 7.2.

### 7.2 `DolphinSwimToTreasureGoal` and `DolphinSwimWithPlayerGoal` (read in this round)

Both goals have flags MOVE and LOOK. Head-turn limits used below: `getMaxHeadYRot` + 20 = 1 + 20 = **21** (yaw) and `getMaxHeadXRot` = **1** (pitch), by the dolphin's values in 4.2.

**`DolphinSwimToTreasureGoal`** (priority 1, **not interruptible**). State: the dolphin's field `treasurePos` (a block position, absent until a search succeeds and **never cleared by this goal**) and the goal's boolean `stuck`.

| Routine | Behaviour |
|---|---|
| `canUse` | `gotFish` (metadata 18, set by feeding, 6.4) is true **and** the air supply is at least **100** |
| `canContinueToUse` | `treasurePos` is present, **and** the dolphin is **not** within 4.0 of the centre of the block `(treasure x, floor(dolphin y), treasure z)` (the treasure column taken at the dolphin's own height; `BlockPos.closerToCenterThan(dolphin position, 4.0)`, a strict "closer than"), **and** `stuck` is false, **and** the air supply is at least 100 |
| `start` (server side only; on a client nothing happens) | `stuck` = false; stop the navigation; search `ServerLevel.findNearestMapStructure(structure tag dolphin_located, the dolphin's block position, 50, false)`; the tag is {`#ocean_ruin`, `#shipwreck`} (read from `data/minecraft/tags/worldgen/structure/dolphin_located.json`) and the last argument is false (known structures are not skipped). When none is found: `stuck` = true and the routine ends. When found: `treasurePos` = the result and entity event **38** is broadcast to the trackers of the dolphin. The unit of the 50 is not read (Open question 4) |
| `tick` | does nothing while `treasurePos` is absent. Otherwise it acts **only on ticks on which `closeToNextPos` holds (the navigation target is within 12 blocks, 4.2) or the navigation is done**. Then: (1) `target` = centre of the treasure block; (2) try A: `DefaultRandomPos.getPosTowards(dolphin, horizontal 16, vertical 1, target, 0.39269909262657166 rad)` (that is pi/8; semantics in 18 section 4.2); (3) when A is null, try B: `getPosTowards(dolphin, 8, 4, target, 1.5707963705062866 rad)` (pi/2); (4) when a candidate exists, take its block: if that block does **not** have a water fluid state **or** its block state is **not** path-computable for the WATER type (`isPathfindable(WATER)`), the candidate is **replaced** by try C: `getPosTowards(dolphin, 8, 5, target, pi/2)` (which may be null); (5) when no candidate remains, `stuck` = true and the tick ends; (6) otherwise the look control looks at the candidate with limits (21, 1), the navigation moves to the candidate at speed modifier **1.3**, and with probability `1 / adjustedTickDelay(80)` = **1/40** per goal evaluation (18 section 4.1; the goal does not require an update every tick) entity event 38 is broadcast again |
| `stop` | `gotFish` is cleared (set false) when `treasurePos` is absent, **or** the dolphin is within 4.0 of the treasure block centre (as in `canContinueToUse`), **or** `stuck` is true. In any other case, for example when the air fell below 100 on the way, `gotFish` stays true |

The goal therefore stops, and the next `canUse` fails once `gotFish` is false. A dolphin whose first search failed has `stuck` true until the next `start` resets it. Entity event 38 (client side, `Dolphin.handleEntityEvent` then `addParticlesAroundSelf`, read): 7 `happy_villager` particles, each with velocity = three `nextGaussian` draws x 0.01 (x, y, z in that order) at position `(getRandomX(1.0), getRandomY() + 0.2, getRandomZ(1.0))`.

**`DolphinSwimWithPlayerGoal(dolphin, speedModifier = 4.0)`** (priority 2, interruptible by default: no override). State: the `player`.

| Routine | Behaviour |
|---|---|
| `canUse` | `player` = the nearest player to the dolphin under `SWIM_WITH_PLAYER_TARGETING` = **non-combat** conditions, **range 10.0**, **line of sight ignored** (read in the `Dolphin` static initialiser; `ServerLevel.getNearestPlayer(conditions, dolphin)`, applied in the order of 2.7); false when none; otherwise true when `player.isSwimming()` **and** the dolphin's attack target is **not** that player |
| `canContinueToUse` | the player is still set, `isSwimming()` is true and the squared distance to the dolphin is below **256.0** (16 blocks) |
| `start` | the player gets Dolphin's Grace for **100** ticks (`MobEffectInstance(DOLPHINS_GRACE, 100)`, so amplifier 0), source = the dolphin |
| `tick` | look at the player with limits (21, 1); when the squared distance to the player is below **6.25** (2.5 blocks) stop the navigation, otherwise navigate to the player at speed modifier **4.0**; then, while the player is swimming and `nextInt(6) == 0` (drawn from the **player's** level random source, so one draw per tick only while the player swims), the player is given Dolphin's Grace for 100 ticks again (source = the dolphin) |
| `stop` | the `player` field is cleared and the navigation stopped |

Worked example (treasure goal): a dolphin that was fed a cod has `gotFish` true and air 4800; `canUse` holds. `start` finds a shipwreck 40 blocks away (inside the search), sets `treasurePos` and broadcasts event 38. On each evaluation at which its navigation is done it picks a point about 16 blocks toward the wreck (try A) and swims there at 1.3; it reaches the 4.0 range of the wreck's column, `canContinueToUse` fails, and `stop` clears `gotFish`. If instead its air falls to 99 on the way, `canContinueToUse` fails, `stop` does not clear `gotFish`, and `canUse` stays false until the dolphin surfaces and the air reaches 100 again.

## 8. Axolotl

Everything of 21 section 4.7 stands except the corrections of section 3. Additional data read here: item tag `axolotl_food` = {`tropical_fish_bucket`}
(`isFood`); block tag `axolotls_spawnable_on` = {`clay`}; fluid tag `axolotl_tries_to_find` = {`water`}; entity tags `axolotl_always_hostiles` = {drowned, guardian, elder_guardian}
and `axolotl_hunt_targets` = {tropical_fish, pufferfish, salmon, cod, squid, glow_squid, tadpole}. Metadata and attribute values are in 21 section 4.7.

### 8.1 Spawn variants and babies (`finalizeSpawn`)

Bucket spawns (reason BUCKET) return immediately, keeping their stored variant. For any other reason, with `r` = the level's random source:

1. If the supplied group data is an `AxolotlGroupData`: if its group size is **at least 2**, this axolotl will be a baby. Otherwise (no group data) create one: an array of two
   variants, each drawn by `getCommonSpawnVariant` (a uniform pick, `nextInt(4)`, among the four variants whose `common` flag is true: lucy 0, wild 1, gold 2, cyan 3), first array slot first.
   `AxolotlGroupData` is built with `AgeableMobGroupData(false)`, so the generic baby chance of 2.1 never applies.
2. variant = `types[r.nextInt(types.length)]` (so `nextInt(2)`).
3. If it is a baby: `setAge(-24000)`.
4. `Animal.finalizeSpawn`, which runs 2.1 and increases the group size by one.

So in a pack of size 4 to 6 (lush caves), members 1 and 2 are adults and members 3 to 6 are babies, and all members share the two variants drawn for the first member (each member picks one of the two).
The rare blue variant never occurs from natural spawning (8.2).

### 8.2 Rare variant: offspring only (`useRareVariant`)

`useRareVariant(random)` is true when `nextInt(1200) == 0` (constant `RARE_VARIANT_CHANCE` 1200). It is called in one place only, `Axolotl.getBreedOffspring(level, partner)`, and that method has **two callers**: breeding, and the spawn egg used on an axolotl
(6.2, with the clicked axolotl as both parents; the coin flip of step 4 then picks between two copies of the same variant). The steps are:

1. create an axolotl with reason BREEDING (null aborts);
2. draw `useRareVariant` from **this** axolotl's random source (the parent that creates the child);
3. if true, the child's variant = `getRareSpawnVariant`: a uniform pick (`Util.getRandom` over the variants with `common` false, here only blue, id 4);
4. otherwise `nextBoolean()`: true -> this parent's variant, false -> the partner's variant;
5. the variant is set and the child is made persistent (`setPersistenceRequired`).

Probability that a child is blue is 1/1200 for any parents; blue parents otherwise pass blue on with the coin flip. Variant ids: lucy 0, wild 1, gold 2, cyan 3, blue 4 (`Variant` order); the
default variant is lucy; the legacy codec accepts the same names.

### 8.3 Play-dead damage test (`Axolotl.hurtServer`)

`h` is the health **before** the damage; `d` the incoming damage. The test is evaluated in this order, each step short-circuiting (the random draws occur only for the steps that are reached):

| Step | Condition (all must hold to continue) |
|---|---|
| 1 | AI is on (`!isNoAi`) |
| 2 | `nextInt(3) == 0` (draw A, probability 1/3) |
| 3 | `(float) nextInt(3) < d` (draw B) **or** `h / maxHealth < 0.5` (if draw B is not below `d`, the health ratio is tested; draw B is always made when step 2 passes) |
| 4 | `d < h` (the hit would not kill) |
| 5 | the axolotl is in water (`isInWater`, rain does not count) |
| 6 | the damage source has an entity or a direct entity (a `null`/environmental source fails) |
| 7 | the axolotl is not already playing dead (metadata 19 false) |

If all hold, Brain memory `PLAY_DEAD_TICKS` is set to **200**. In every case the ordinary `Animal.hurtServer` then runs with the unchanged damage. The playing-dead flag
(metadata 19) is derived each server tick in `customServerAiStep`: true when the memory is present and greater than 0, otherwise false (only when AI is on).
While playing dead: the move control and the look control do nothing (`AxolotlMoveControl.tick`, `AxolotlLookControl.tick` skip their parents) and `canBeSeenAsEnemy` is false.
The behaviour `PlayDead` (activity PLAY_DEAD, duration 200) requires memories `PLAY_DEAD_TICKS` and `HURT_BY_ENTITY` present and the axolotl in water;
`start` erases `WALK_TARGET` and `LOOK_TARGET` and adds Regeneration, duration 200, amplifier 0; it keeps running while in water and the memory exists. `ValidatePlayDead` (in CORE) runs when
`PLAY_DEAD_TICKS` is present: if the value is <= 0 it erases `PLAY_DEAD_TICKS` and `HURT_BY_ENTITY` and calls `useDefaultActivity`; otherwise it stores value - 1. Per tick this
is: the value counts down from 200 and the behaviour ends after 200 ticks.

The PLAY_DEAD activity (`initPlayDeadActivity`, read) is a two-entry list: priority 0 `PlayDead`; priority 1 `EraseMemoryIf(BehaviorUtils.isBreeding, PLAY_DEAD_TICKS)`, so a breeding axolotl forgets the play-dead memory. The activity is entered only while `PLAY_DEAD_TICKS` is present (its entry requirement) and it forgets `PLAY_DEAD_TICKS` when the activity stops.
The FIGHT activity (`initFightActivity`, read) is the four-entry list at priorities 0 to 3: `StopAttackingIfTargetInvalid` with the `onStopAttacking` callback (8.5); `SetWalkTargetFromAttackTargetIfTargetOutOfReach` (chase speed function 0.6 in water, 0.15 on land); `MeleeAttack(20)`; `EraseMemoryIf(isBreeding, ATTACK_TARGET)`. It is entered while `ATTACK_TARGET` is present and forgets `ATTACK_TARGET` when it stops.

`updateActivity` (every server tick): let `a` be the active non-core activity; if `a` is not PLAY_DEAD, set the active activity to the first valid of
[PLAY_DEAD, FIGHT, IDLE]; then if `a` was FIGHT and the new active non-core activity is no longer FIGHT, set `HAS_HUNTING_COOLDOWN` = true with expiry **2400** ticks.
Hurt-by and attack-target logic of the FIGHT activity are in 21 section 4.7.

### 8.4 Air supply and rehydration

Maximum air is 6000 (`getMaxAirSupply`). `handleAirSupply` (server, every tick, AI on): if alive and not in water or rain, air - 1 and when at or below -20 the air is set
to 0 and the axolotl takes `hurtServer(dryOut, 2)` (through its own hurt, so the play-dead test is reached but fails step 6); otherwise the air is set to the maximum.

`rehydrate()` sets `air = min(air + 1800, 6000)` (`REHYDRATE_AIR_SUPPLY` 1800). Its only caller is the thrown-potion hit handler (`AbstractThrownPotion.affectEntitiesAround`): when the potion's contents are in
potion tag `rehydrates_axolotls` (= {`water`}, i.e. a splash **or lingering** water potion), every `Axolotl` whose box intersects the potion entity's own bounding box inflated by **4.0 horizontally and 2.0 vertically**
(`inflate(4.0, 2.0, 4.0)`) is rehydrated. There is **no distance test** in this step (the water-sensitive and extinguish step before it additionally requires a squared distance below 16 and uses the same box); the tag test comes after that step.
`ThrownSplashPotion` and `ThrownLingeringPotion` do not override `AbstractThrownPotion.onHit`; they only implement `onHitAsPotion`. On the server `onHit` calls `affectEntitiesAround` **first** and only afterwards, if the contents have effects, `onHitAsPotion`.
`ThrownLingeringPotion.onHitAsPotion` (read) creates the lingering cloud: an `AreaEffectCloud` at the position of the hit entity when the hit is an entity hit, otherwise at the potion's own position. If the potion's owner is a `LivingEntity` it becomes the cloud's owner.
The cloud is given radius **3.0**, radius-on-use **-0.5**, duration **600**, wait time **10** and radius-per-tick = `-radius / duration` = -3.0 / 600 = **-0.005**; then the item components are applied and the cloud is added to the level. The cloud's per-tick application is in 44-9 section 3 (area effect cloud application loop).
Water has no effects, so no cloud is created, and the rehydration of a lingering water potion happens before (and without) any cloud.

### 8.5 Supporting effects (`onStopAttacking`, `applySupportingEffects`)

When the axolotl's attack ends (the `StopAttackingIfTargetInvalid` callback): if the target `isDeadOrDying`, and its last damage source's entity is a `Player`, and that player is in the list of all
players whose box intersects the axolotl's bounding box **inflated by 20.0** (a box, not a sphere; constant `PLAYER_REGEN_DETECTION_RANGE` 20), then `applySupportingEffects(player)`:

1. let `e` be the player's current Regeneration instance (may be absent);
2. **only if** `e` is absent or `e` is finite with duration <= 2399 (`endsWithin(2399)`): new duration = `min(2400, 100 + (e ? e.duration : 0))`; the player gets Regeneration for that duration, amplifier 0, source = the axolotl;
3. **always** (even when step 2 did not apply): the player's Mining Fatigue is removed.

So an axolotl kill can extend Regeneration by 100 ticks up to a cap of 2400, never replaces a longer effect, and always cures Mining Fatigue.

### 8.6 Idle activity details (completing 21 section 4.7)

Speeds (all `speedModifier` values): chasing in water 0.6, following an adult in water 0.6, idling in water 0.5, making love 0.2; every one of the three in-water speeds falls to **0.15 on land**
(each speed function tests `isInWater`). `ADULT_FOLLOW_RANGE` is uniform(5, 16). The IDLE activity (all priorities, 0 to 4) is:

| Priority | Behaviour |
|---|---|
| 0 | `SetEntityLookTargetSometimes(Player, 6.0, uniform(30, 60))` |
| 1 | `AnimalMakeLove(AXOLOTL, 0.2, 2)` |
| 2 | `RunOne`: `FollowTemptation(speed function)` weight 1 or `BabyFollowAdult(uniform(5, 16), speed function, NEAREST_VISIBLE_ADULT, false)` weight 1 |
| 3 | `StartAttacking(finder)`; the finder returns empty while breeding and otherwise the `NEAREST_ATTACKABLE` memory (9.1) |
| 3 | `TryFindLiquid(6, 0.15, fluid tag axolotl_tries_to_find)` |
| 4 | `GateBehavior` (requires `WALK_TARGET` absent; ordered, try-all): `RandomStroll.swim(0.5)` weight 2; `RandomStroll.stroll(0.15, false)` weight 2; `SetWalkTargetFromLookTarget(test, speed function, 3)` weight 3, whose test holds when `Level.isWaterAt(look target block)` equals `isInWater` of the axolotl (`isWaterAt`, declared in `LevelReader`, is true when the fluid state at the position is in fluid tag `water`, read; so the test holds when the look target is water and the axolotl is in water, and also when neither is); a trigger that fires when the axolotl is in water (weight 5); a trigger that fires when it is on the ground (weight 5) |

The two last entries are `BehaviorBuilder.triggerIf(predicate)` behaviours with the predicates `Entity.isInWater` and `Entity.onGround`. `triggerIf` builds a `OneShot` with **no memory requirements** whose trigger simply returns the predicate's result, with no side effect
(read): they carry no walk or look action, and they "start" only when the predicate holds. What a started no-op does to the gate's ordered try-all pass is given by the `GateBehavior` rules of 18 section 4. 

`TryFindLiquid(range 6, speed 0.15, fluid tag)` (read; the speed is given to the walk target; a `OneShot` requiring `ATTACK_TARGET` absent, `WALK_TARGET` absent and `LOOK_TARGET` registered; it keeps a timer, initially 0). Each evaluation, with `now` = game time:

1. if the block the mob stands in already has a fluid in the tag: do not start;
2. if `now < timer`: set `timer = now + 22` and **start** (no scan, no target set);
3. otherwise scan the region given by `findBlocksInBoxByManhattanDistance(pos, 6)` (see the scan order below), keeping only positions that differ **horizontally** from the mob's own column and whose block is a liquid block (`LiquidBlock`) whose fluid is in the tag;
   for each candidate in scan order: if the block above it is air, it is chosen and the scan stops; otherwise, if no candidate has been remembered yet and the mob is **not** closer than 1.5 to the candidate's centre, remember this candidate (the first such) and continue;
4. if a position was chosen or remembered, set `LOOK_TARGET` and `WALK_TARGET` (speed 0.15, completion distance 0) to it; in either case set `timer = now + 40` and start.

Because step 2 pushes the timer to `now + 22` whenever it is evaluated before the timer has expired, and the behaviour is evaluated each tick, a second scan can only happen when the evaluation is skipped for a while (Open question 3).

**Scan order** (read: `LevelReader.findBlocksInBoxByManhattanDistance` passes the range as all three reaches to `BlockPos.withinBoxByManhattanDistance(pos, 6, 6, 6)`, whose maximum depth is the **sum** of the three reaches, 6 + 6 + 6 = **18**; the iterator is the anonymous class `BlockPos$3`).
The region is therefore the full 13 x 13 x 13 box of offsets with |dx|, |dy|, |dz| <= 6, **not** a Manhattan-distance-6 diamond; the Manhattan distance only orders it. Offsets (dx, dy, dz) relative to the mob's block are emitted as follows:

1. depth `d` runs from 0 to 18 ascending (d = |dx| + |dy| + |dz|, nearest first);
2. within a depth, dx ascends from -min(6, d) to +min(6, d);
3. for each dx, dy ascends from -min(6, d - |dx|) to +min(6, d - |dx|);
4. the z offset is `d - |dx| - |dy|`; offsets whose z exceeds 6 are skipped; otherwise the **positive** z is emitted first and then, only when it is nonzero, the mirrored negative z.

The first position emitted is the origin itself (d = 0). The scan filters of step 3 (horizontally different column, `LiquidBlock` with a fluid in the tag, then the air-above and 1.5-distance tests) are applied to this sequence in order. This closes 18 Open question 19 for `TryFindLiquid` (18 itself is not edited by this round).
Worked example: for d = 1 the order is (-1,0,0), (0,-1,0), (0,0,+1), (0,0,-1), (0,+1,0), (+1,0,0), the dx = 0 group going dy = -1 (z = 0), then dy = 0 (z = 1 then -1), then dy = +1.

CORE is `LookAtTargetSink(45, 90)`, `MoveToTargetSink`, `ValidatePlayDead`, `CountDownCooldownTicks(TEMPTATION_COOLDOWN_TICKS)`.

Other axolotl facts read here: the walk target value of any position is 0 (`getWalkTargetValue`); `removeWhenFarAway` is true unless the axolotl is from a bucket or has a custom name; `canBeLeashed` is true;
the spawn predicate `checkAxolotlSpawnRules` is: the block below is in tag `axolotls_spawnable_on` (clay), plus the lush-caves biome entry (21 section 4.11); `travelInWater` is `moveRelative(speed)`, move, velocity x 0.9;
`usePlayerItem` replaces a held tropical fish bucket with a water bucket (`ItemUtils.createFilledResult`), and `mobInteract` first tries bucket pickup with the `Bucketable` rules (18 section 4.11).
Its look control is `SmoothSwimmingLookControl` (yaw limit 20) and its move control `SmoothSwimmingMoveControl(85, 10, 0.1, 0.5, false)` (11).

## 9. Sensors

### 9.1 `axolotl_attackables` (`AxolotlAttackablesSensor`)

A `NearestVisibleLivingEntitySensor` (2.3) that writes `NEAREST_ATTACKABLE` and also requires memory `HAS_HUNTING_COOLDOWN`. Constant `TARGET_DETECTION_DISTANCE` 8.0. The candidate `other` (one of the
visible nearest living entities) matches when **all** of:

1. `distanceSqr(self, other) <= 64`;
2. `other` is in water (`isInWater`);
3. `other` is hostile (its type is in `axolotl_always_hostiles`) **or** (the axolotl's Brain has **no** `HAS_HUNTING_COOLDOWN` memory **and** `other`'s type is in `axolotl_hunt_targets`);
4. `Sensor.isEntityAttackable(level, axolotl, other)` (2.4).

The tests are evaluated in the order above. The closest matching visible entity is stored. Consequence: after any fight ends, the axolotl ignores the hunt-target tag for 2400 ticks (8.3) but still attacks drowned
and guardians.

### 9.2 `frog_attackables` (`FrogAttackablesSensor`)

A `NearestVisibleLivingEntitySensor` (2.3) writing `NEAREST_ATTACKABLE`, also requiring memory `UNREACHABLE_TONGUE_TARGETS`. Constant `TARGET_DETECTION_DISTANCE` 10.0. The candidate matches when **all** of:

1. `Sensor.isEntityAttackable(level, frog, other)` (2.4);
2. `Frog.canEat(other)`: if `other` is a cube mob (slime, magma cube, sulfur cube: `AbstractCubeMob`) its size must be exactly **1**; and `other`'s type is in entity tag `frog_food` (= {slime, magma_cube});
3. `other`'s UUID is **not** in the frog's `UNREACHABLE_TONGUE_TARGETS` memory (a list of UUIDs, empty when the memory is absent);
4. `other` is closer than 10.0 to the frog (`closerThan`, strict: distance squared < 100).

The nearest passing entity is stored. Frog goal and tongue behaviour are in 19 section 11 and 18 section 4.5 (Brain system).

The **writer** of `UNREACHABLE_TONGUE_TARGETS` is `ShootTongue.checkExtraStartConditions` (the start test of the tongue behaviour). It takes the `ATTACK_TARGET` and asks `canPathfindToTarget`: the frog's navigation must produce a path to the target (`createPath(target, 0)`: the integer argument is the constant 0, read) and the test is `path != null` and `Path.getDistToTarget() < 1.75` (`EATING_DISTANCE`), a strict comparison (read, `fcmpg` then branch); a null path counts as not reachable. If not, `ATTACK_TARGET` is erased and the target's UUID is added to the list (`addUnreachableTargetToMemory`):
the list (a new empty list if the memory was absent) gets the UUID appended if it is not already present; when the list already holds **5** entries (`MAX_UNREACHBLE_TONGUE_TARGETS_IN_MEMORY`) and the UUID is new, the **oldest** (index 0) is removed first; the memory is then set with
an expiry of **100** ticks (`UNREACHABLE_TONGUE_TARGETS_COOLDOWN_DURATION`), so each addition renews the expiry of the whole list. The behaviour starts only when this test did not erase the target, the target exists, the frog's pose is not CROAKING and `Frog.canEat(target)` holds.

### 9.3 `nautilus_temptations`

It is a `TemptingSensor` (2.5) whose item predicate is item tag `nautilus_food`. `nautilus_food` = {`#fishes`, `#nautilus_bucket_food`}, with `fishes` = {cod, cooked cod, salmon, cooked salmon,
pufferfish, tropical fish} and `nautilus_bucket_food` = {pufferfish bucket, cod bucket, salmon bucket, tropical fish bucket}. (Both nautilus kinds list this sensor.)

## 10. Nautilus and zombie nautilus

This section extends 21 section 4.10 with everything the sources of `AbstractNautilus`, `Nautilus`, `ZombieNautilus`, `NautilusAi`, `ZombieNautilusAi` and `ChargeAttack` contain. `AbstractNautilus` extends `TamableAnimal`
(an `Animal`). Attribute values, sizes, metadata indexes and constants are in 21 section 4.10 and are not repeated.

### 10.1 Classes and the shared water rules

| Rule | Nautilus | Zombie nautilus |
|---|---|---|
| Move control | `SmoothSwimmingMoveControl(85, 10, 0.011, 0, true)`; look control `SmoothSwimmingLookControl(10)` | same (inherited) |
| Navigation | `WaterBoundPathNavigation` (no breaching), WATER malus 0 | same |
| Walk target value | 0 for every position | 0 |
| Pushed by fluid | no | no |
| Air (the handler lives in `Nautilus` only: `getMaxAirSupply` 300 and `handleAirSupply`; `AbstractNautilus` and `ZombieNautilus` declare neither) | maximum 300; the handler (server, AI on, once per `baseTick`) takes `air - 1` while alive and not in water, and at air <= -20 sets air 0 and `hurtServer(dryOut, 2)`; in water the air is 300 | none of its own: the zombie nautilus is in the `undead` family through tag `zombies`, so the default rule lets it breathe water, and it has no dry-out |
| Poison | cannot be affected (`canBeAffected` false for Poison) | also immune through the `undead` tag (`ignores_poison_and_regen`) |
| Baby | yes; baby dimensions = adult dimensions x 0.5 with a passenger attachment at (0, 0.5, 0) | `canBeABaby` false: never a baby |
| `getBreedOffspring` | creates a nautilus (reason BREEDING); if the parent is tame, the child gets the parent's owner reference and the tame flag | returns null (nothing is born) |
| Leashing | `canBeLeashed` unless aggravated | unless aggravated or mob-controlled |
| Persistence | any player interaction (`interact`) calls `setPersistenceRequired`; `removeWhenFarAway` is always true (an unconditional constant in `AbstractNautilus`); persistence is kept only through `setPersistenceRequired` and `requiresCustomPersistence` (true when tame) | same code |
| Burning | not in `burn_in_daylight` | in `burn_in_daylight` (20 section 3 sun burn); its sun-protection slot is BODY (`sunProtectionSlot`) |
| Variant | none | metadata 21 holds a `zombie_nautilus_variant` holder; default `temperate` |
| Spawn variant | n/a | `finalizeSpawn`: `VariantUtils.selectVariantToSpawn(context at block position, registry)` picks among the variants whose conditions hold, at the highest priority, ties by random. The rule (`PriorityProvider.select` and `pick`, read): the entries are sorted highest priority first and walked in that order; an entry whose priority is below the best matched priority so far is dropped, and an entry whose condition fails is dropped;
every entry that passes sets the best priority. The result is **all passing entries at the top matched priority**; a lower-priority match is never chosen. `pick` then takes one of those entries uniformly (`Util.getRandomSafe`, empty when none passed). Variant files: `temperate` priority 0 with no condition (asset `zombie_nautilus`); `warm` priority 1 with condition "biome in tag `spawns_coral_variant_zombie_nautilus`" (= {`warm_ocean`}), model `warm`, asset `zombie_nautilus_coral`. So a zombie nautilus created in a warm ocean is the coral variant, anywhere else temperate. |

"Aggravated" means the Brain has an `ANGRY_AT` or an `ATTACK_TARGET` memory. "Mob-controlled" means the first passenger is a `Mob`.
Tags read: `can_wear_nautilus_armor` and `can_equip_saddle` both contain nautilus and zombie nautilus; `aquatic` contains both. Neither is in `dismounts_underwater`, so riders do not dismount in water.

### 10.2 Tame-state bits and owner (`TamableAnimal`)

Metadata 18 is a Byte of flags: bit **0x01** = sitting pose (`isInSittingPose` only; `isOrderedToSit` is **not** part of this byte: it returns a separate boolean field `orderedToSit`, written by `setOrderedToSit`, that is not synchronised metadata), bit **0x04** = tame (`isTame`); bit 0x02 is unused here. `setTame(tame, applySideEffects)` sets or clears the 0x04
bit (`b | 4`, `b & ~4`) and, if the second argument is true, calls `applyTamingSideEffects` (empty for the nautilus). Metadata 19 is the optional owner reference (an entity reference stored as a UUID).
`tame(player)` = `setTame(true, true)`, `setOwner(player)`, and for a server player the `TAME_ANIMAL` advancement trigger. A tamed nautilus's `canAttack` is false against its owner. (The sit and teleport-to-owner helpers
exist on the class, but no behaviour in `NautilusAi` or `ZombieNautilusAi` follows the owner or sits: a tame nautilus has **no follow-owner logic**; its only restriction is the home rule below.)

Taming (`mobInteract`, adults only; a baby uses `TamableAnimal.mobInteract` = `Animal` rules):

1. Tame and secondary use active: open the inventory (below); SUCCESS.
2. Holding an item: (a) server side, untamed, and `isFood(stack)` (for an untamed adult `isFood` is item tag `nautilus_taming_items` = {pufferfish bucket, pufferfish}): `usePlayerItem`
   (consume one; a pufferfish **bucket** is replaced by a water bucket, `nautilus_bucket_food`) then `tryToTame`; result SUCCESS_SERVER. `tryToTame`: with probability 1/3 (`nextInt(3) == 0`) `tame(player)`, stop the navigation and
   broadcast entity event **7**; otherwise broadcast entity event **6**; in both cases play the eating sound. (b) otherwise, if `isFood(stack)` and health < max health: `feed(player, hand, stack, 2.0, 1.0)`: consume one item and heal `2.0 x nutrition` of the item's food component (or 1.0 if it has none) and play the eating sound; SUCCESS. (c) otherwise try `stack.interactLivingEntity` (items acting on entities, equipment, 10.3), and if the result consumes the action return it.
3. Tame, not secondary use, and the held item is not food: `doPlayerRide(player)` (server: `startRiding`, and if the nautilus ends with no passenger, `clearHome`); SUCCESS.
4. Otherwise `TamableAnimal.mobInteract` (breeding by food and the like, 18 section 8.1).

Client handling of the two events (`TamableAnimal.handleEntityEvent`, `spawnTamingParticles`, read): event 7 calls it with true and event 6 with false; true uses `heart` particles and false uses `smoke`; each call adds **7** particles, and for each particle three `nextGaussian` draws multiplied by 0.02 give the particle velocity (x, y, z in that order), at position `(getRandomX(1.0), getRandomY() + 0.5, getRandomZ(1.0))`. No server rule depends on them.

`isFood` for a tame adult or any baby is item tag `nautilus_food` (9.3). So a tame adult is bred and healed with fish; an untamed adult is tamed only with pufferfish or a pufferfish bucket (fish in the `fishes` tag do
not tame, because for an untamed adult `isFood` is the taming tag). Any bucket food (`nautilus_bucket_food`) that is consumed leaves a water bucket in the player's hand.

Nautilus inventory (`NautilusInventoryMenu`, opened by `openCustomInventoryScreen` when the nautilus is tame and either not a vehicle or the player is its passenger): the container has `getInventoryColumns() x 3` slots, and
`getInventoryColumns` returns **0**, so the extra container is empty (size 0). The menu has the **saddle slot at (8, 18)** and the **armor (body) slot at (8, 36)**, then the standard player inventory at y = 84. A slot is active only when `canUseSlot` allows it (10.3). Slot ids addressed
through commands start at offset 500 (`INVENTORY_SLOT_OFFSET`), so `getSlot(500 + i)` indexes the inventory container (none exist) and other ids use the ordinary equipment slots.

### 10.3 Armor and saddle

`canUseSlot(slot)`: for SADDLE and BODY the slot is usable only when the nautilus is **alive, not a baby and tame**; other slots follow `TamableAnimal`. `canDispenserEquipIntoSlot` is true for BODY and SADDLE (so a dispenser can equip them).
The body armor items are `copper`, `iron`, `golden`, `diamond` and `netherite` `_nautilus_armor` (item registry order in `Items`: iron, golden, diamond, netherite, copper). Each is created with `nautilusArmor(material)`: stack size 1; attribute
modifiers of the material for the **BODY** armor type; an `equippable` component with slot BODY, the material's asset id, allowed entities = tag `can_wear_nautilus_armor`, equip sound `armor_equip_nautilus`,
`damageOnHurt` false (the armor takes no durability damage), `equipOnInteract` true (right-clicking the nautilus with it equips it), `canBeSheared` true with shearing sound `armor_unequip_nautilus`. There is no durability and no enchantability for these items.

| Material | Armor (BODY) | Toughness | Knockback resistance |
|---|---|---|---|
| copper | 4 | 0 | 0 |
| iron | 5 | 0 | 0 |
| golden | 7 | 0 | 0 |
| diamond | 11 | 2 | 0 |
| netherite | 19 | 3 | 0.1 |

The modifiers are `ADD_VALUE` modifiers whose slot group is `EquipmentSlotGroup.bySlot(BODY)` (applied while the item is in the BODY slot): `armor` = the BODY value, `armor_toughness` = the toughness (**always added, even when it is 0**), and `knockback_resistance` only when it is above 0 (netherite). The modifier id is the default-namespace
identifier `armor.` followed by the armor type's name, and the name of `ArmorType.BODY` is the string `body` (both literals read), so the id is `armor.body`.
The **netherite** nautilus armor is additionally registered with `Item$Properties.fireResistant()` (after `nautilusArmor(NETHERITE)`), so as an item it does not burn in fire or lava; the iron, golden, diamond and copper nautilus armors do not have it. The saddle slot holds a saddle (tag `can_equip_saddle`); `isSaddled` is true when the SADDLE slot holds a valid equippable item. Equip sounds: saddle `nautilus_saddle_underwater_equip` if the
nautilus is underwater else `nautilus_saddle_equip`; other slots use the item's sound. The equip, shear and dispenser dispatch is read in 10.3.1.

### 10.3.1 Equip, shear and dispenser dispatch (generic code, read)

This is the code shared by all mobs; the nautilus differs only through `canUseSlot` (10.3) and the sounds. A player's use of an item on a mob runs in this order (`Player.interactOn`, `Mob.interact`, `Entity.interact`, `ItemStack.interactLivingEntity`):

1. `Mob.interact`: a mob that is not alive returns PASS. **(a)** `checkAndHandleImportantInteractions`: a held name tag goes through `ItemStack.interactLivingEntity`; a held spawn egg runs the spawn-egg offspring rule (6.2); otherwise PASS. A consuming result ends the interaction with game event ENTITY_INTERACT.
2. **(b)** The `LivingEntity` and `Entity.interact` rules, in this order: with secondary use active and a leashable target, the leads held by the player in the area are attached; a held shears item on a leash connection shears it off (1 durability); then **shearing equipment**: the target is a `Mob`, the held item is the shears item (`Items.SHEARS`), `canShearEquipment(player)` holds and the player is **not** using secondary use, and `attemptToShearEquipment` returns true: the result is SUCCESS; then the lead untie and lead tie rules (18 section 8.3). A result other than PASS returns.
3. **(c)** `mobInteract` of the mob (for the nautilus family, 10.2; step 2c there calls `ItemStack.interactLivingEntity`). A consuming result also fires ENTITY_INTERACT.
4. Back in `Player.interactOn`, when nothing has consumed the action, the held stack's `interactLivingEntity(player, target, hand)` runs.

`canShearEquipment` is true when the mob is **not a vehicle** (has no passenger); `Mob` declares it and neither `TamableAnimal`, `Animal`, `AbstractNautilus` nor `Nautilus` overrides it (each class listing searched), so a **ridden** nautilus cannot be sheared.

**Shearing** (`Mob.attemptToShearEquipment`, `shearItem`): the slots are walked in the order of `EquipmentSlot.VALUES`, taken as the declaration order MAINHAND, OFFHAND, FEET, LEGS, CHEST, HEAD, BODY, SADDLE ((inferred): the list was not read). The **first** slot whose stack has an `equippable` component with `canBeSheared` true, and (the stack has no `prevent_armor_change` enchantment effect, or the player is in creative mode), is sheared: the shears take 1 durability damage (`hurtAndBreak(1, player, the hand's slot)`); the slot is emptied; game event SHEAR with the player as source; on the server the stack is dropped at the average passenger-attachment point of the mob (`spawnAtLocation`) and the advancement trigger `player_sheared_equipment` fires; the component's `shearingSound` is played by the mob; the result is true. Nautilus armor (10.3: `canBeSheared` true, sound `armor_unequip_nautilus`) and the saddle (`Equippable.saddle()`: slot SADDLE, `equipOnInteract` true, `canBeSheared` true, shearing sound `saddle_unequip`, allowed entities tag `can_equip_saddle`) qualify. Only the code of `Entity` and `Mob` refers to this method (class files searched), so `ShearsDispenseItemBehavior` does **not** shear equipment.

**Equipping** (`ItemStack.interactLivingEntity` then `Equippable.equipOnTarget`): when the stack has an `equippable` component with `equipOnInteract` true, the result of `equipOnTarget(player, target, stack)` is returned unless it is PASS (then `Item.interactLivingEntity` runs and returns PASS for these items). `equipOnTarget` returns PASS unless **all** hold: `target.isEquippableInSlot(stack, slot)`; the target has **no item** in that slot; the target is alive. `isEquippableInSlot(stack, slot)` (`LivingEntity`): with no component only MAINHAND qualifies and only when `canUseSlot(MAINHAND)`; with a component the requested slot must equal the component's slot, `canUseSlot(slot)` must hold (10.3: alive, adult and tame for BODY and SADDLE) and the component's allowed entities must be empty or contain the target's type (tags `can_wear_nautilus_armor`, `can_equip_saddle`). On success, server side only: one item is split from the stack into the slot (`setItemSlot`, which runs `onEquipItem` and the equip sound of 10.3) and, for a `Mob`, the slot is marked as a guaranteed drop; the result is SUCCESS on both sides (the client does the animation only).

Consequences for the nautilus: a tame adult with an empty BODY slot equips the armor; with the slot full the equip step passes and, since the item is not food, 10.2 step 3 makes the player ride; a saddle behaves the same on SADDLE; for an untamed or baby nautilus `canUseSlot` is false, so every equippable item passes and the interaction continues to taming (untamed) or the `Animal` rules (baby).

**Dispenser** (`EquipmentDispenseItemBehavior.dispenseEquipment`): the level is asked for `LivingEntity` instances inside the 1-block box in front of the dispenser that pass `canEquipWithDispenser(stack)` (order of 2.8); with none, the default dispense runs (the item is thrown). `canEquipWithDispenser` requires: the entity is alive and not a spectator; the stack has an `equippable` component whose `dispensable` flag is true (the `Equippable$Builder` default is true, read, and nothing in 10.3 sets it false); `canUseSlot(slot)`; the component allows the entity's type; the slot is currently empty; and `canDispenserEquipIntoSlot(slot)`, which is true for BODY and SADDLE on a nautilus (10.3). The **first** entity of the list gets one item split into `getEquipmentSlotForItem(stack)` (the component's slot when `canUseSlot` allows it, else MAINHAND); for a `Mob` the slot is a guaranteed drop and the mob becomes persistent (`setPersistenceRequired`); the dispenser keeps the rest of the stack. Worked example: a dispenser facing a tame adult nautilus holding diamond nautilus armor in a stack of 1 equips it (BODY empty, `canDispenserEquipIntoSlot(BODY)` true); facing an untamed nautilus, `canUseSlot(BODY)` is false and the item is thrown instead.

### 10.4 Ride and dash control

Only a **saddled** nautilus is steered: `getControllingPassenger` returns the first passenger if the nautilus is saddled and that passenger is a `Player`, otherwise the default. Riding uses the ordinary ridden travel (18 section 8.4, riding; `travelRidden`):
per tick the controlling client computes `riddenInput = getRiddenInput(player, ...)`, calls `tickRidden`, and if it simulates the movement sets `speed = getRiddenSpeed(player)` and runs `travel(riddenInput)`; otherwise it sets the velocity to zero
(the server does not simulate a mob that a client controls; the client reports position by the vehicle-move packets, 05c section 0x22 Serverbound Move Vehicle; the server-side validation is read in 10.4.1).

| Part | Rule |
|---|---|
| `getRiddenInput(player, travel)` | `x = player.xxa` (sideways input); if `player.zza != 0`: `c = cos(player xRot)`, `s = -sin(player xRot)`; if `zza < 0` both are multiplied by -0.5; then `y = s`, `z = c`; if `zza == 0`, `y = z = 0`. The result vector is `(x, y, z)`, so looking down while pressing forward dives and looking up climbs; reverse moves at half rate along the opposite direction |
| `getRiddenRotation(player)` | pitch = `player xRot x 0.5`, yaw = `player yRot` |
| `tickRidden` | `target = getRiddenRotation`; `yaw = ownYaw + wrapDegrees(target.yaw - ownYaw) x 0.5`; set rotation `(yaw, target pitch)`; head yaw, body yaw and previous yaw all equal `yaw`. Then, if this instance is authoritative (the controlling client): if `playerJumpPendingScale > 0` and the nautilus is not already jumping, `executeRidersJump(scale, player)`; the pending scale is then reset to 0 |
| `getRiddenSpeed` | in water `0.0325 x movement_speed`; out of water `0.02 x movement_speed` |
| `travelInWater` | `moveRelative(getSpeed(), input)`, move, velocity x 0.9 (water resistance factor 0.9) |
| `canJump` | `isSaddled` |
| `onPlayerJump(strength)` (client side, strength 0 to 100) | does nothing unless saddled; does nothing while `dashCooldown > 0`; otherwise `playerJumpPendingScale = getPlayerJumpPendingScale(strength)`. The scale (interface default) is **1.0 for strength >= 90**, otherwise `0.4 + 0.4 x strength / 90` (this reading confirms the full-scale 1.0 that 19 Open question 7 marked inferred) |
| `executeRidersJump(scale, player)` | velocity += `lookAngle(player) x (m x scale x movement_speed x blockSpeedFactor)` with `m` = **1.2 in water, 0.5 on land**; then `dashCooldown = 40`, `DASH` metadata = true, `needsSync` = true |
| `handleStartJump(strength)` (server side, see below) | make the dash sound (`getDashSound`: the nautilus or zombie nautilus dash sound, a land variant when not underwater), game event `ENTITY_ACTION`, `DASH` = true |
| `handleStopJump` | nothing |
| `onSyncedDataUpdated(DASH)` (not on the first tick) | `dashCooldown = (dashCooldown == 0 ? 40 : dashCooldown)`, so clients and the server start the cooldown when the flag flips |
| `tick` (after `TamableAnimal.tick`) | server only: apply the rider effect (below); then, on both sides: if dashing and `dashCooldown < 35`, `DASH` = false; if `dashCooldown > 0`, decrement it, and when it reaches 0 make the dash-ready sound; while in water call `spawnBubbles` (a particle add; the call in `tick` is guarded only by `isInWater`, with no visible `isClientSide` test at the call, and `Level.addParticle` of the base `Level` class has an empty body (read), so on the server the call has no effect; the rule is in 10.4.2) |

Server side of the jump: the serverbound player-command packet (05c section 0x2A Serverbound Player Command) with action "start riding jump" and a data value (the jump strength): if the player's controlled vehicle is a jumpable (`PlayerRideableJumping`), `canJump()` is true and
the data is greater than 0, the server calls `handleStartJump(data)`; "stop riding jump" calls `handleStopJump`. The dash impulse itself is applied by the controlling client; the server learns the position through the vehicle-move packets.
The dash flag therefore lives for the ticks in which the cooldown counts from 40: at the first tick the cooldown is 40 (not below 35); after the decrement it reads 39, and so on; the flag is cleared on the tick that **starts** with a cooldown of 34 or
less, that is, `DASH` stays true through the first 6 ticks after the cooldown starts and is cleared on the 7th (the constant `DASH_MINIMUM_DURATION_TICKS` 5 equals 40 - 35). The next dash is possible once the cooldown reaches 0, 40 ticks after the previous one.

Rider effect (`applyEffects`, server only, every tick): if the **first passenger** is a `Player` (saddled or not): the player gets `BREATH_OF_THE_NAUTILUS` for **60 ticks**, amplifier 0, ambient true, visible true, icon true, **when the player lacks it or `gameTime % 40 == 0`**;
the grant is skipped on other ticks if the player already has it. So the effect is refreshed every 40 ticks and never lapses while riding; it ends up to 60 ticks after dismounting.

Restriction radius: while tame and neither leashed nor a vehicle (`checkRestriction`, called each server AI step before the Brain tick): `radius = 32` if the nautilus is an adult with an empty SADDLE slot, else `16` (`getNautilusRestrictionRadius`;
babies always 16). If it has a home, whose position is closer than `radius + 8` to the nautilus's block and whose radius equals `radius`, nothing changes; otherwise `setHomeTo(blockPosition, radius)`. So a tame nautilus is kept within 32 (unsaddled) or 16 (saddled) blocks
of where it last was re-homed. The home position is used by the stroll behaviours through the restriction rule (18 section 4.2, `MoveTowardsRestrictionGoal` and the home helpers).

Ground-level effects: `playStepSound` is empty (no step sounds); sounds depend on `isUnderWater` and on baby (baby sounds for babies) (not tabulated, they are `SoundEvents`).

### 10.4.1 Server validation of a ridden vehicle's reported position (`ServerGamePacketListenerImpl.handleMoveVehicle`)

A nautilus has no special acceptance rule; its controlling client's position reports (05c section 0x22 Serverbound Move Vehicle) go through the generic vehicle handler, which was read in this round:

1. The handler runs on the server thread. When the packet's x, y, z or its rotations are invalid (`containsInvalidValues`) the player is disconnected with the translation key `multiplayer.disconnect.invalid_vehicle_movement`.
2. The packet is processed only when the player's root vehicle is the vehicle in question **and** the player is that vehicle's controlling passenger, and not while a teleport of the player is awaited or before the client has finished loading ((inferred) from the branch targets; the exact gate order was not decoded, Open question 1). Otherwise, when the player's vehicle is not under the player's control, a corrective Clientbound Move Vehicle packet (05a section 0x3A) with the vehicle's own position is sent (after a warning that the player "was expected to be controlling vehicle"; the distance bound of that branch is not tabulated, Open question 1).
3. Coordinates are clamped: x and z to +-3.0E7, y to +-2.0E7; rotations are wrapped to degrees.
4. **Speed test**: with `moved2` = squared distance between the clamped position and the vehicle's position at the start of the tick (`vehicleFirstGood`) and `v2` = squared length of the vehicle's own velocity, when `moved2 - v2 > 100.0` and the player is not the owner of a single-player world, the server logs "moved too quickly" and sends the corrective Move Vehicle packet, and **stops** (the packet is not applied).
5. Otherwise the vehicle is moved by the delta from its last accepted position (`vehicleLastGood`) with mover type PLAYER (so block collision applies), the fall distance is reset when a climbing living vehicle is on a climbable block, and the position error between the reported and resulting positions is computed; when the squared error is greater than **0.0625** (0.25 blocks) the server logs "moved wrongly" (the vertical error is treated as 0 when it lies between -0.5 and 0.5, (inferred) from two comparisons).
6. If the vehicle would collide with something it did not collide with before (the no-collision test of the pre-move box, then `isEntityCollidingWithAnythingNew` at the reported position), the vehicle is **snapped back** to its previous position and a corrective Move Vehicle packet is sent. Otherwise it is snapped to the **reported** position, the chunk source is told, the movement statistics are updated, and the reported on-ground flag is applied (with fall damage handling); a vehicle that is not on the ground, not flying, not under `allowFlight`, with gravity, and with no blocks around starts the generic "floating" counter ((inferred) from the condition list; the kick threshold was not read).

So the server **trusts** a controlling client's position up to the collision test and a speed bound of `moved2 - v2 <= 100` per packet (about 10 blocks beyond the vehicle's own velocity), and corrects violations by resending the position. Worked example: a nautilus with velocity length 0.5 (`v2` 0.25) reports a position 8 blocks from its start-of-tick position: `moved2` 64, `64 - 0.25 <= 100`, accepted; 11 blocks gives `121 - 0.25 > 100`, rejected with a correction.

### 10.4.2 Nautilus bubbles (`AbstractNautilus.spawnBubbles`, client effect)

Called every tick while the nautilus is in water; it adds particles only on a client (`Level.addParticle` is empty in the base class, read; the client's override is not read, Open question 2). With `s` = the length of the velocity and the constants `BUBBLE_PROBABILITY_MULTIPLIER` 2.0, `BUBBLE_PROBABILITY_MIN` 0.15, `BUBBLE_PROBABILITY_MAX` 1.0, `BUBBLE_SPREAD_FACTOR` 0.8, `BUBBLE_DIRECTION_SCALE` 1.1, `BUBBLE_Y_OFFSET` 0.25:

1. `p = clamp(s x 2.0, 0.15, 1.0)`; draw `nextFloat()`; no bubble unless the draw is below `p` (so a resting nautilus makes a bubble on 15% of ticks and one moving at 0.5 blocks per tick or more on every tick).
2. `view` = the view vector of `(pitch = clamp(xRot, -10, 10), yaw = yRot)`.
3. `spread = nextDouble() x 0.8 x (1 + s)`; then three draws `(nextFloat() - 0.5) x spread` give the particle velocity (x, then y, then z).
4. A `bubble` particle is added at `(x - view.x x 1.1, y - view.y + 0.25, z - view.z x 1.1)` (the y term has no 1.1 factor), with that velocity: it trails behind the nautilus's head direction.

### 10.5 Nautilus brain (`NautilusAi`)

Sensors: `NEAREST_LIVING_ENTITIES`, `NEAREST_ADULT`, `NEAREST_PLAYERS`, `HURT_BY`, `NAUTILUS_TEMPTATIONS`. Extra memories: `ANGRY_AT`, `ATTACK_TARGET_COOLDOWN` (besides those the sensors need). Activities are CORE, IDLE, FIGHT; active
order FIGHT then IDLE (`setActiveActivityToFirstValid`), re-evaluated each server tick. Speeds: idle 1.0, tempted 1.3, making love 0.4, panicking 1.6, attacking charge speed 0.6.

| Activity | Priorities |
|---|---|
| CORE (priority 0 group) | `AnimalPanic(1.6)`, `LookAtTargetSink(45, 90)`, `MoveToTargetSink`, `CountDownCooldownTicks` for each of `TEMPTATION_COOLDOWN_TICKS`, `CHARGE_COOLDOWN_TICKS`, `ATTACK_TARGET_COOLDOWN` |
| IDLE | 1: `AnimalMakeLove(NAUTILUS, 0.4, 2)`; 2: `FollowTemptation(speed 1.3, stop distance 2.5 for a baby and 3.5 for an adult)`; 3: `StartAttacking(findNearestValidAttackTarget)`; 4: `GateBehavior` requiring `WALK_TARGET` absent, ordered, try-all: `RandomStroll.swim(1.0)` weight 2 and `SetWalkTargetFromLookTarget(speed 1.0, close enough 3)` weight 3 |
| FIGHT | 0: `ChargeAttack(...)` (10.6); runs only while `ATTACK_TARGET` is present, `TEMPTING_PLAYER` absent, `BREED_TARGET` absent and `CHARGE_COOLDOWN_TICKS` absent |

There are no look-around, baby-follow or owner behaviours: apart from stroll, temptation and love, a nautilus does nothing in IDLE.

Target selection `findNearestValidAttackTarget(level, nautilus)`, in this order:

1. If the nautilus is breeding, **not in water**, a baby or **tame**: no target.
2. If the `ANGRY_AT` memory resolves to a living entity that is in water and passes `isEntityAttackableIgnoringLineOfSight`: that entity is the target (no cooldown test).
3. If `ATTACK_TARGET_COOLDOWN` is present: no target.
4. Otherwise store a new `ATTACK_TARGET_COOLDOWN` = uniform(**2400, 3600**); then with probability 0.5 (`nextFloat() < 0.5`) there is no target; else the nearest visible living entity (`NEAREST_VISIBLE_LIVING_ENTITIES`)
   that is in water and whose type is in `nautilus_hostiles` (= {pufferfish}); none if no such entity.

At spawn (`finalizeSpawn`, `NautilusAi.initMemories`) `ATTACK_TARGET_COOLDOWN` is set to a fresh uniform(2400, 3600), so a new wild nautilus does not hunt for 2400 to 3600 ticks. Hence a wild adult attempts to hunt a pufferfish at most once per
2400 to 3600 ticks, succeeding half the time.

Anger: `hurtServer` that actually causes damage and has a `LivingEntity` attacker calls `NautilusAi.setAngerTarget`: if the attacker passes `isEntityAttackableIgnoringLineOfSight` the memory `CANT_REACH_WALK_TARGET_SINCE` is erased and
`ANGRY_AT` is set to the attacker's UUID with expiry **400** ticks. A tame nautilus can be angered (the memory is set) but never gets a target (rule 1), and `isAggravated` then forbids leashing.
The charge's targeting conditions (`ATTACK_TARGET_CONDITIONS`) are combat `TargetingConditions` with a selector: the entity must be inside the world border, and an armor stand is a valid target only when the game rule `mob_griefing` is on.

### 10.6 `ChargeAttack(timeBetweenAttacks, conditions, speed, knockbackForce, maxChargeDistance, maxTargetDetectionDistance, sound)`

Typed on `Animal`. Nautilus: `(80, ATTACK_TARGET_CONDITIONS, 0.6, 2.0, 12.0, 11.0, nautilus dash sound)`. Zombie nautilus: the same with speed **0.5** and the zombie nautilus dash sound. The behaviour has the
default `Behavior` duration of **60 ticks** (the constructor with only a memory map gives min and max duration 60), after which the framework stops it. Start requirement: `CHARGE_COOLDOWN_TICKS` absent and `ATTACK_TARGET` present.

State: `startPosition`, and `chargeVelocity`.

- `canStillUse` (checked each tick by the framework, and once at start): `ATTACK_TARGET` is present; the animal is **not tame** (a tame `TamableAnimal` stops at once); the distance squared from the animal to `startPosition` is **below 12.0^2** (144);
  the distance squared to the target is **below 11.0^2** (121); the animal has line of sight to the target; and `CHARGE_COOLDOWN_TICKS` is absent.
- `start`: `startPosition` = the animal's position; `chargeVelocity = normalize(target position - own position) x speed` (positions are feet positions, computed once); if `canStillUse` holds, the dash sound plays at the animal.
- `tick`: the animal looks at the target with unlimited turn (`lookAt(target, 360, 360)`); its velocity is **overwritten every tick** with `chargeVelocity`; then it collects at most **one** living entity whose
  bounding box intersects the animal's own box (not inflated) and that passes `conditions.test(level, animal, entity)` (this can be any entity that is a valid attack target, not only the chosen target). If one is found:
  if the animal has it as a passenger, nothing happens this tick; otherwise `dealDamageToTarget`, `dealKnockBack`, and `stop`.
- `dealDamageToTarget`: `hurtServer(mobAttack(animal), attack_damage)`; if the damage landed, `EnchantmentHelper.doPostAttackEffects` (28 section 2.2, the `post_attack` component).
- `dealKnockBack`: `speedAmp` = Speed amplifier + 1 (0 without Speed); `slowAmp` = Slowness amplifier + 1 (0 without Slowness); `bonus = 0.25 x (speedAmp - slowAmp)`;
  `strength = clamp(speed x movement_speed attribute, 0.2, 2.0) + bonus`; then `animal.causeExtraKnockback(target, strength x knockbackForce, animal velocity, mobAttack source, attack_damage, false)`: when the
  strength is above 0 and the target is living, the target is knocked back by `strength` away along the animal's yaw (sine and negative cosine of its yaw; `knockback` rules of 18 section 7.4) and the animal's own horizontal velocity is multiplied by 0.6 (vertical 1.0).
- `stop`: `CHARGE_COOLDOWN_TICKS` = **80** (`timeBetweenAttacks`) and `ATTACK_TARGET` is erased. It runs on a hit, on the end of `canStillUse` (distance, line of sight), and after the 60-tick duration.

Since the dash speed is 0.6 blocks per tick (zombie 0.5), the 12-block limit is reached after 20 ticks (24 for the zombie), long before the 60-tick duration. While `ANGRY_AT` (400 ticks) lasts, IDLE's `StartAttacking` renews `ATTACK_TARGET` and FIGHT recharges as soon as
the 80-tick cooldown ends: a provoked nautilus charges about every 80 ticks plus the dash itself.

### 10.7 Nautilus damage numbers

Attack damage 3 (zombie nautilus the same); `mobAttack` source; knockback strength as in 10.6; knockback resistance 0.3 base (plus the armor modifier). Loot and XP: data tables and the `AbstractNautilus` XP rule of `Animal`
(18 section 7.6, experience); not changed here.

### 10.8 Zombie nautilus brain (`ZombieNautilusAi`)

Sensors and memories as the nautilus (`NEAREST_LIVING_ENTITIES`, `NEAREST_ADULT`, `NEAREST_PLAYERS`, `HURT_BY`, `NAUTILUS_TEMPTATIONS`; memories `ANGRY_AT`, `ATTACK_TARGET_COOLDOWN`). Differences:

| Part | Zombie nautilus |
|---|---|
| CORE | `LookAtTargetSink(45, 90)`, `MoveToTargetSink`, the same three cooldown countdowns; **no `AnimalPanic`** |
| IDLE | 1: `FollowTemptation(speed 0.9, stop distance 2.5 baby / 3.5 adult)`; 2: `StartAttacking(NautilusAi.findNearestValidAttackTarget)`; 3: the same gate (`RandomStroll.swim(1.0)` weight 2, `SetWalkTargetFromLookTarget(1.0, 3)` weight 3). **No `AnimalMakeLove`** |
| FIGHT | `ChargeAttack(80, NautilusAi.ATTACK_TARGET_CONDITIONS, 0.5, 2.0, 12.0, 11.0, zombie nautilus dash sound)`, same entry conditions as the nautilus |
| Order | FIGHT, IDLE |
| Anger | `AbstractNautilus.hurtServer` calls `NautilusAi.setAngerTarget` for both kinds (shared code), so provoking it works the same |
| Target finder | the nautilus finder (10.5): not in water, a baby (never) or tame gives no target; `nautilus_hostiles` = {pufferfish}; the cooldown, 50% roll and uniform(2400, 3600) are the same. `initMemories` runs through `AbstractNautilus.finalizeSpawn` for both |

The zombie nautilus is tamed, fed, armored, saddled and ridden by exactly the same code as the nautilus (10.2 to 10.4): untamed it accepts pufferfish items, a tame one is fed `nautilus_food`
and can be ridden. Zombie nautilus movement speed 1.1 (21 section 4.10) makes the ridden speed `0.0325 x 1.1` in water. It is also a drowned jockey mount (20 section 4.5).

## 11. Water movement controls, look controls and swim navigation per mob

The behaviours of the controls themselves are specified in 18 section 4.4 (`SmoothSwimmingMoveControl`, `SmoothSwimmingLookControl`) and 18 section 5 (`SwimNodeEvaluator`,
`WaterBoundPathNavigation`, `AmphibiousPathNavigation`). Read again in this round, with the additions:

- `SmoothSwimmingMoveControl` (checked line by line): the two pitch or yaw limits are `maxTurnX` (pitch) and `maxTurnY` (yaw); constants `FULL_SPEED_TURN_THRESHOLD` 10 and `STOP_TURN_THRESHOLD` 60 exist in the class; only the first is used (in `getTurningSpeedFactor = 1 - clamp((angle - 10) / 50, 0, 1)`, out of water).
  `rotlerp` is the 18 definition (difference limited to the maximum, result normalised to 0 to 360).
- `SmoothSwimmingLookControl(mob, maxYRotFromCenter)`, completing 18: `tick`: when `lookAtCooldown > 0` it is decremented and the head turns toward the wanted yaw plus **20** (`yHeadRot = rotateTowards(yHeadRot, wantedYaw + 20, yMaxRotSpeed)`) and the pitch toward the wanted pitch plus **10**
  (`xRot = rotateTowards(xRot, wantedPitch + 10, xMaxRotAngle)`), where the wanted angles are the ordinary `LookControl` yaw and pitch (absent when the look offset is below 1.0E-5);
  with no recent look target: if the navigation is done, `xRot = rotateTowards(xRot, 0, 5)`; then `yHeadRot = rotateTowards(yHeadRot, yBodyRot, yMaxRotSpeed)`. Finally, the head-to-body difference `wrapDegrees(yHeadRot - yBodyRot)` is compared with `maxYRotFromCenter`:
  if it is below `-max` the body yaw decreases by **4**; if above `+max` the body yaw increases by 4 (so the body follows a turning head by 4 degrees per tick).
- `WaterBoundPathNavigation`: **only a dolphin allows breaching** (`createPathFinder` sets it from "the mob is a dolphin"); `canUpdatePath` is "breaching allowed **or** the mob is in liquid" (so a dolphin can re-path in air, the others only in liquid);
  the working mob position is `(x, y at half height, z)`; the ground-Y helper returns the point's y unchanged; doors cannot be passed (`setCanPassDoors(false)`).

Per-mob control parameters (all read from the mob constructors):

| Mob | Move control `(maxTurnX, maxTurnY, inWaterModifier, outsideModifier, applyGravity)` | Look control | Navigation |
|---|---|---|---|
| Dolphin | `SmoothSwimmingMoveControl(85, 10, 0.02, 0.1, true)` | `SmoothSwimmingLookControl(10)` | `WaterBoundPathNavigation` with breaching |
| Axolotl | `AxolotlMoveControl(85, 10, 0.1, 0.5, false)` (does nothing while playing dead) | `AxolotlLookControl(20)` (does nothing while playing dead) | amphibious (21 section 4.7, WATER malus 0) |
| Nautilus, zombie nautilus | `SmoothSwimmingMoveControl(85, 10, 0.011, 0, true)` | `SmoothSwimmingLookControl(10)` | `WaterBoundPathNavigation` (no breaching) |
| Fish (`AbstractFish`) | `FishMoveControl` (21 section 4.1) | default | `WaterBoundPathNavigation` |
| Squid | none (the movement vector of 21 section 4.5) | default | none used |
| Guardian | `GuardianMoveControl` (21 section 4.8) | default | `WaterBoundPathNavigation` |

Note on units: the in-water speed modifier multiplies the attribute-based speed that `LivingEntity.travel` then feeds to `moveRelative`, so the dolphin's `0.02`, the axolotl's `0.1` and the nautilus's `0.011` are
the per-tick acceleration scales (18 section 3.2, `travelInWater`); they are not blocks-per-second.

## 12. Pointers for 19 Open questions 1 and 2

- **19 Open question 1** (bat, nautilus, happy ghast): the bat and the nautilus are covered by 21 section 4 and, for the nautilus family, by section 10 of this document; the happy ghast is covered by 44-9 section 9 and is not described here.
- **19 Open question 2** (axolotl): answered by section 8 of this document, with 21 section 4.7 and the corrections of section 3. Its entity-metadata cross-check row in 19 section 18 is unchanged.
- Related small answers for 19: the block tag `axolotls_spawnable_on` is {`clay`} (19 Open question 4, the axolotl part); the fluid tags `axolotl_tries_to_find` and `dolphin_tries_to_find` are both {`water`}.

## 13. Worked examples

**13.1 Fish flop.** A salmon lies on a stone block, out of water, with `onGround` true and `verticalCollision` true. Draws `nextFloat()` = 0.75 then 0.25: x += (0.75 x 2 - 1) x 0.05 = +0.025; z += (0.25 x 2 - 1) x 0.05 = -0.025;
y += 0.4. The same tick clears `onGround`, sets `needsSync`, plays the flop sound. While the salmon is airborne no further flop occurs; it flops again only after landing with the collision flag set.

**13.2 Dolphin drying.** A dolphin leaves the water at moistness 2400. Each tick moistness drops by 1 (2399, 2398, ...). Standing on a sand block (`onGround`) it hops every tick with velocity `+(+-0.2, 0.5, +-0.2)` and a random yaw. At tick 2400 out of water its moistness reaches 0, and from then on `hurt(dryOut, 1)` is called every tick. The hurt window (18, section on `hurt`, step 6) rejects the calls while `invulnerableTime > 10` and `amount <= lastHurt`: the first call lands (`invulnerableTime` 20, `lastHurt` 1), the next 9 are rejected (20 down to 11), and the call made when the value is 10 lands again, so 1 damage lands about every 10 ticks and a dolphin with its maximum health of 10 (`Dolphin.createAttributes`, `MAX_HEALTH` 10.0; also 21 section 4.6) lasts about 100 ticks, not 10.

**13.3 Elder guardian helper.** Elder at tick count 1190 with entity id 10: `(1190 + 10) % 1200 == 0`, so it fires. Player A (survival, distance 30, no effect) is affected. Player B (creative) is not. Player C (survival, distance 50.0 exactly) is not (strict `<`).
Player D (survival, distance 20, Mining Fatigue III with 5000 ticks left) is not (same amplifier, more than 1199 left). Player E (survival, 20 away, Mining Fatigue III with 800 left) is refreshed to 6000 and gets the packet.
A silent elder sends value 0, an ordinary one value 1.

**13.4 Squid XP and group.** Killing a squid by a player drops orbs for `1 + nextInt(3)` XP (draws 0, 1, 2 give 1, 2, 3). A spawn pack of 4 squid under a shared group data with chance 0.05: member 1 is an adult (group size 0), members 2 to 4 are each a baby when
`nextFloat() <= 0.05`.

**13.5 Axolotl play dead.** Axolotl 14 / 14 health in water, hit by a player for 4: draw A `nextInt(3)`: 0 with p 1/3. Draw B is 0, 1 or 2, always below 4, so step 3 holds; 4 < 14; in water; the source has an entity; it is not playing dead: `PLAY_DEAD_TICKS` = 200.
For a hit of 1: after draw A passes (1/3), draw B < 1 needs value 0 (1/3), or the ratio < 0.5 (not at full health): probability 1/9 per hit. At health 6 / 14 (ratio 0.43) a hit of 2 passes step 3 whenever draw A passed, so
p = 1/3; a hit of 6 fails step 4 (6 < 6 false).

**13.6 Axolotl pack.** A lush-caves pack of 5: group data draws two variants (for example gold and lucy); member 1: adult, `nextInt(2)` picks gold; member 2: adult, picks lucy; members 3, 4, 5: babies (age -24000). No blue.

**13.7 Axolotl rehydration.** An axolotl with air 2000 within the splash box of a water bottle: air = min(2000 + 1800, 6000) = 3800; with air 5000: min(6800, 6000) = 6000.

**13.8 Axolotl supporting effects.** A player already has Regeneration with 1000 ticks left; the axolotl's target dies in the player's presence (the player lands the killing blow) within the 20-block box: the condition (finite, <= 2399) holds, new duration = min(2400, 100 + 1000) = 1100.
With 2399 + 1 = 2400 left: `endsWithin(2399)` is false, so no Regeneration change; Mining Fatigue is removed in both cases.

**13.9 Nautilus taming.** An untamed adult nautilus and a player holding 3 pufferfish: first use consumes one and draws `nextInt(3)`; 0 tames (event 7, owner set), 1 or 2 fails (event 6); expected 3 pufferfish (inferred: the mean of a draw that succeeds with probability 1/3; not a value read). A cod does nothing (not in `nautilus_taming_items`). After taming, a cod heals
`2.0 x nutrition` (a cod has a food component: (inferred), the cod item's components were not read in this round; without one the heal is 2.0 x 1.0 by 10.2 step 2b) when it is hurt; at full health a cod starts love mode through `Animal.mobInteract` ((inferred) from 10.2 step 4 and 18 section 8.1; not traced for the cod item).

**13.10 Nautilus charge.** A provoked wild nautilus (movement speed 1.0) at (0, 0, 0) with the target at (6, 0, 8): distance 10 < 11. `chargeVelocity` = (0.6, 0, 0.8) x 0.6 = (0.36, 0, 0.48), so it moves 0.6 blocks per tick.

(a) Hit on contact. The target stands on the dash line and the dash ends on the first tick on which the nautilus box intersects a valid living entity's box; there `dealDamageToTarget`, `dealKnockBack` and `stop` run. Knockback: `clamp(0.6 x 1.0, 0.2, 2.0) = 0.6`, `+ 0` (no effects), x 2.0 = **1.2**. Zombie nautilus (speed attribute 1.1): `clamp(0.5 x 1.1) = 0.55`, x 2.0 = **1.1**. With Speed II on the animal (`speedAmp` 2): `+0.5`, so (0.6 + 0.5) x 2.0 = **2.2**.

(b) No hit. If nothing intersects, at tick 20 the animal has gone 12 blocks (squared 144 is not below 144), `canStillUse` fails, and `stop` sets `CHARGE_COOLDOWN_TICKS` to 80 and erases `ATTACK_TARGET`.

**13.11 Nautilus ridden dash.** A player rides a saddled nautilus in water (movement speed 1.0, block speed factor 1.0) and presses jump with strength 45: scale = 0.4 + 0.4 x 45 / 90 = 0.6; the impulse is `lookAngle x (1.2 x 0.6 x 1.0 x 1.0)` = 0.72 along the look vector. Cooldown = 40. Strength 100: scale 1.0, impulse 1.2.
On land the factor 0.5 gives 0.5 at full strength. A second jump within 40 ticks is ignored (`onPlayerJump` returns while `dashCooldown > 0`). Ridden speed in water 0.0325; on land 0.02. Breath of the Nautilus (60 ticks) is refreshed at game times 40, 80, ...

**13.12 Armor.** A tame adult nautilus with diamond armor in the BODY slot gains +11 armor and +2 toughness; with netherite +19 armor, +3 toughness and +0.1 knockback resistance (total 0.4). Taking damage does not reduce the armor's durability.

**13.13 Zombie nautilus variant.** Spawned at a block in `warm_ocean`: candidates temperate (priority 0) and warm (priority 1, condition true); highest priority wins: coral (warm). Spawned in `ocean`: only temperate matches.

**13.14 Dolphin jump goal.** A dolphin facing east at the surface of a long channel: on each evaluation `nextInt(5) == 0` (1 in 5). It then needs water at `x + 0, 1, 4, 5, 6, 7` and air at heights +1 and +2 above each of those. If the water at `x + 4` is stone (not water) the test fails at that step and the goal does not start;
if there is a block (air test fails) at height +1 over `x + 6`, it also fails. When it starts: velocity += (0.6, 0.7, 0); while it leaves the water the pitch follows the velocity; when it comes down at |pitch| below 10 and nonzero in water, or touches ground, the goal ends and `xRot` becomes 0.

**13.15 Targeting conditions.** See the worked example of 2.7 (visibility 0.5 gives range 8; visibility 0.05 gives the floor 2.0).

**13.16 Equip and shear.** A tame adult nautilus with empty BODY and SADDLE slots: the player right-clicks with iron nautilus armor: `canUseSlot(BODY)` true, slot empty, alive: the armor is split into BODY, the mob's BODY drop is guaranteed, SUCCESS. With a saddle: same on SADDLE. With both worn and no passenger, shears in hand without sneaking: `attemptToShearEquipment` walks the slots in order, BODY comes before SADDLE, so the **armor** is removed first and dropped, the shears lose 1 durability and sound `armor_unequip_nautilus` plays; a second use removes the saddle (`saddle_unequip`). With a rider aboard `canShearEquipment` is false and nothing is sheared.

**13.17 Bubbles.** A nautilus at rest in water (`s` = 0): `p` = clamp(0, 0.15, 1.0) = 0.15; the draw 0.10 is below it, so one bubble appears; the draw 0.20 gives none. At `s` = 0.3: `p` = 0.6.

## 14. Validation

How the claims of this document were checked:

| Check | Method |
|---|---|
| Archive identity | SHA-256 recorded in the header equals the one in `README.md` |
| Fish flop and dolphin hop | the complete `aiStep` and `tick` bytecode of `AbstractFish` and `Dolphin` was read; the only guards are those stated; draw order read from the sequence of `nextFloat` calls |
| Effect helper | both lambdas of `MobEffectUtil.addEffectToPlayersAround` read; `GameType.isSurvival`, `Vec3.closerThan` and `MobEffectInstance.endsWithin` read |
| XP and breeding | `AgeableWaterCreature.getBaseExperienceReward`, absence of an override in `Squid`, `GlowSquid`, `Dolphin`; the goal registrations; `AgeableMob.finalizeSpawn` and `AgeableMobGroupData` constructors (0.05, 0.1) read |
| Axolotl | `hurtServer`, `finalizeSpawn`, `getBreedOffspring`, `Variant` (common flags), `AxolotlGroupData`, `handleAirSupply`, `rehydrate`, `AbstractThrownPotion.affectEntitiesAround`, `PlayDead`, `ValidatePlayDead`, `AxolotlAi` (idle, fight, play dead, `updateActivity`), the sensor, `onStopAttacking`, `applySupportingEffects`; tag files `axolotl_food`, `axolotls_spawnable_on`, `axolotl_tries_to_find`, `rehydrates_axolotls`, `axolotl_always_hostiles`, `axolotl_hunt_targets` |
| Frog sensor | `FrogAttackablesSensor`, `Frog.canEat`, tag `frog_food`, the `Sensor` static conditions |
| Nautilus | all methods of `AbstractNautilus`, `Nautilus`, `ZombieNautilus`, `NautilusAi`, `ZombieNautilusAi`, `ChargeAttack`, `TemptingSensor`, `TamableAnimal` (flags, `tame`, `feed`), `NautilusInventoryMenu`, `PlayerRideableJumping`, `LivingEntity.travelRidden` and `causeExtraKnockback`, the `ServerGamePacketListenerImpl` player-command branch, `Items`/`Item$Properties.nautilusArmor`, `ArmorMaterial.createAttributes`, `ArmorMaterials` constants; tag files `nautilus_food`, `nautilus_taming_items`, `nautilus_bucket_food`, `nautilus_hostiles`, `can_wear_nautilus_armor`, `can_equip_saddle`, `zombies`, `undead`, `can_breathe_under_water`, `burn_in_daylight`, the two variant files, `spawns_coral_variant_zombie_nautilus` |
| Controls and navigation | `SmoothSwimmingMoveControl`, `SmoothSwimmingLookControl`, `WaterBoundPathNavigation`, `MoveControl.rotlerp`, the per-mob constructors |
| Dolphin jump goal | `DolphinJumpGoal` and `JumpGoal` fully read; the `STEPS_TO_CHECK` array read element by element |
| Dolphin treasure and swim-with-player goals | all methods of `Dolphin$DolphinSwimToTreasureGoal` and `Dolphin$DolphinSwimWithPlayerGoal`, the `Dolphin` static initialiser (`SWIM_WITH_PLAYER_TARGETING`), `Dolphin.createAttributes`, `Dolphin.handleEntityEvent` and `addParticlesAroundSelf`; tag file `data/minecraft/tags/worldgen/structure/dolphin_located.json` |
| Targeting and entity order | `TargetingConditions.test` (complete bytecode), `LevelReader.isWaterAt`, `TamableAnimal.spawnTamingParticles` and `handleEntityEvent`, `NearestLivingEntitySensor.doTick`, `EntitySectionStorage.forEachAccessibleNonEmptySection`, `EntitySection.getEntities`, `SectionPos.asLong` |
| Equip, shear, dispenser, vehicle move, bubbles | `ItemStack.interactLivingEntity`, `Equippable` (`equipOnTarget`, `saddle`, the builder defaults), `LivingEntity.isEquippableInSlot`, `canEquipWithDispenser`, `getEquipmentSlotForItem`, `Mob.interact`, `checkAndHandleImportantInteractions`, `attemptToShearEquipment`, `shearItem`, `canShearEquipment`, `Entity.interact`, `Player.interactOn`, `EquipmentDispenseItemBehavior`, `AbstractNautilus.canUseSlot`, `canDispenserEquipIntoSlot` and `spawnBubbles`, `ServerGamePacketListenerImpl.handleMoveVehicle` (bytecode; branch targets partly decoded), `Level.addParticle` |
| Counts | the tag file contents above were read with `unzip -p`; no file counts are claimed in this document |
| Recall | no statement is marked "(recalled, not verified)" because none rests on memory; the former "(inferred)" mark on lingering cloud creation was closed by reading `ThrownLingeringPotion.onHitAsPotion` (8.4); the dolphin drop velocity (`Dolphin$ItemGoal.drop`), the `BlockPos` Manhattan iterator (`BlockPos$3`), `ShootTongue.canPathfindToTarget`, `AxolotlAi.initPlayDeadActivity` and `initFightActivity`, `TamableAnimal.isInSittingPose` and `TemptingSensor` were read in the fixer round. In the second fixer round the items marked "(inferred)" in 2.8, 10.3.1, 10.4.1 and 13.9 were the only statements without a direct read; none rests on recalled source or wiki text, except that the unit of the structure search radius in 7.2 is **not** given because it was not read |

Test suggestions for implementers (from section 13): the elder filter table (13.3), the axolotl damage test (13.5), the group-size rule for babies (13.4, 13.6), the nautilus knockback arithmetic (13.10), the dash impulse and cooldown (13.11), the nautilus brain's selection rules (10.5), and the
zombie nautilus variant choice (13.13) are each a deterministic function of the stated inputs and random draws.

## 15. Open questions

Closed in the fixer rounds and removed from this list: the variant tie rule (read, 10.1), the sort and search order of `findClosest` and the tempting sensor (read, 2.3 and 2.5), the two weight-5 trigger entries (read, 8.6), lingering potions and the cloud (read, 8.4), the `armor.body` modifier id (both literals read, 10.3), the selector of `ATTACK_TARGET_CONDITIONS` (read, 10.5), the dolphin drop velocity (read, 7.1), the `TryFindLiquid` scan order (read, 8.6) and the frog path test (read, 9.2). Closed in the second fixer round: the dolphin treasure and swim-with-player goals (7.2), the generic `TargetingConditions.test` order (2.7), the definition of `Level.isWaterAt` (8.6), the taming-event particles (10.2), the tie order of the nearest-entity list (2.8), the equip, shear and dispenser dispatch (10.3.1), the server's handling of the vehicle-move position (10.4.1, with the residual below), the nautilus bubble rule and the server no-op of `Level.addParticle` (10.4.2). The remaining questions are renumbered.

1. **Residual branches of `handleMoveVehicle`.** 10.4.1 gives the speed bound, the error bound, the collision snap-back and the clamps, all read. Not decoded: the exact order of the "awaiting teleport" and "client loaded" gate, the distance bound of the "expected to be controlling vehicle" branch, the vertical-error damping, and the floating-counter kick threshold. Searched: the full bytecode of the method; only part of its branch targets were followed.
2. **Client effects.** The client override of `addParticle`, the dolphin water trail, the axolotl animation states and the nautilus models are client-only and were not specified (the base `Level.addParticle` body is empty, read). The server rules do not depend on them.
3. **`TryFindLiquid` re-arm and scan consumption.** The timer logic (8.6 step 2) re-arms the timer to `now + 22` on every evaluation before it expires; this was read literally from the bytecode and not checked by any worked example, so how often the scan really runs is uncertain. The iterator order itself is read (8.6); that `OrderedBlockMatcher` hands the positions to the filters in that order without reordering was taken from its constructor taking the iterable and was not read method by method.
4. **Unit of the structure search radius.** `findNearestMapStructure(tag, position, 50, false)` in 7.2 passes 50; the unit (blocks or chunks) and the search pattern were not read, and the nearest-structure search itself (placement, known-structure handling) is the world-generation side (10 and 35 describe structure placement, not this lookup). Searched: only the call site.
5. **`LivingEntity.getVisibilityPercent` and `canBeSeenByAnyone`/`canBeSeenAsEnemy`.** Step 6 of 2.7 uses the visibility percentage (armor-head and invisibility dependent); its formula and the two `canBeSeen...` flags were not read here. Searched: only the call sites in `TargetingConditions.test`.
6. **Defaults of the `TargetingConditions` factories and the `getNearestPlayer` filter.** The field set and the test are read (2.7); the default field values of `forCombat` and `forNonCombat` are by 18 section 4.3, and whether `ServerLevel.getNearestPlayer` skips spectators or creative players itself (before the conditions run) was not read.
7. **Insertion order inside an entity section and the level delegation chain.** 2.8 reads the section traversal; that `ServerLevel.getEntitiesOfClass` reaches it unchanged and that a section's per-class lists keep insertion order are (inferred) from the types.
8. **`EquipmentSlot.VALUES` order and the leash branches of `Entity.interact`.** 10.3.1 takes `VALUES` as the declaration order and does not re-derive the lead attach, untie and tie branches (18 section 8.3). Searched: the constant names of `EquipmentSlot` (read); the `VALUES` initialiser was not read.
9. **`addEffect` rules.** The merge of an existing and a new `MobEffectInstance` (longer duration, higher amplifier, hidden effects) is not in 17 or 18 and was not read here; 5 and 8.5 call it as a black box.
10. **Item components of the nautilus foods.** 13.9 marks as (inferred) that a cod has a food component and that a full-health tame nautilus enters love mode with a cod; `Items` components and the `Animal.mobInteract` path for these items were not read.
