# Residual mob questions, part 7: aquatic mobs, nautilus family, amphibian sensors

| Item | Value |
|---|---|
| Covers | The residual open questions of the aquatic mobs: fish flop spacing, the dolphin on-ground hop guard, the player filter of the elder guardian's effect helper, squid and dolphin experience and breeding, the axolotl (play-dead damage test, rare variant, air refill, hunting sensor, supporting effects), the whole nautilus family (idle behaviours, ride and dash control, tame-state bits, armor, the charge attack, the temptation sensor, the zombie nautilus brain), the frog attack sensor, the dolphin jump goal, the water movement and look controls and the swim navigation as used by each aquatic mob, and pointers for 19 Open questions 1 and 2 |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the small JSON tag and variant files inside the jar, with no execution. Every value was read in this round. Nothing was taken from memory; where something could not be read it is marked "(inferred)" and listed in the Open questions. |
| Status | Round RS26, part 7. It answers questions left open by [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) (Open questions 7 to 10), by [18](18-mob-framework.md) (Open question 3, amphibian side) and by [19](19-mobs-land-friendly-and-neutral.md) (Open questions 1 and 2). Where this document disagrees with 21 section 4, this document is the later reading and wins (section 3 lists each correction). |

Class names in backticks (`Axolotl`, `ChargeAttack`) say where a fact was read; they are not the design. "18 framework: X"
and "21 section N" are cross-references; their content is not repeated. Data files (loot tables, recipes, tag lists, the
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
| 19 Open questions 1 and 2 | 12 |

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
reuses one group data object for all members of a pack (18 framework: natural spawning), the chance applies to the second member onward.

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
the memory `NEAREST_VISIBLE_LIVING_ENTITIES` (the entities that the `NEAREST_LIVING_ENTITIES` sensor found and that are visible, 18 framework: Brain
sensors), asks `NearestVisibleLivingEntities.findClosest(predicate)` for the closest entity that matches, and stores the result (an empty optional
clears the memory). It requires both memories (its target memory and `NEAREST_VISIBLE_LIVING_ENTITIES`).
`NearestLivingEntitySensor` stores `NEAREST_LIVING_ENTITIES` already sorted by `Entity.distanceToSqr` (squared distance, ascending, a `comparingDouble` sort), and `findClosest(predicate)` walks that list **in
order** and returns the first entity that passes both the given predicate and the stored line-of-sight test (`lineOfSightTest`, `Sensor.isEntityTargetable`, cached per entity). So "closest" means smallest squared distance; ties keep the list order (the order in which the
level returned the entities, as the sort is stable).

### 2.4 `Sensor.isEntityAttackable`

`isEntityAttackable(level, self, other)` evaluates `TargetingConditions` (18 framework: `TargetingConditions`): the combat conditions with range 16. If the Brain's `ATTACK_TARGET`
memory already equals `other`, the variant that **ignores the invisibility test** is used; otherwise the plain combat conditions. The variant
`isEntityAttackableIgnoringLineOfSight` uses the same two forms with line of sight ignored (and for the current target, invisibility ignored too).
The six static condition objects of `Sensor` are: non-combat range 16, non-combat range 16 without invisibility test (used by other sensors), combat range 16, combat range 16 without invisibility test, combat
range 16 without line of sight, and combat range 16 without line of sight and without invisibility test (all with range 16).

### 2.5 `TemptingSensor`

`TemptingSensor` has one public constructor, one static factory and one private constructor that stores a `BiPredicate(mob, stack)`: the public `TemptingSensor(itemPredicate)` wraps the item predicate so that the mob argument is ignored, and the factory `forAnimal()` stores a test that
holds when the mob is an `Animal` and `mob.isFood(stack)`. It writes memory `TEMPTING_PLAYER`. Every sensor tick (server): among all players of the mob's level that are not
spectators (`NO_SPECTATORS`), keep those that pass non-combat `TargetingConditions` with line of sight ignored and range = the mob's `tempt_range` attribute
(18 framework: `TemptGoal`, default 10), that hold a matching item in the main hand or the off hand (`itemPredicate`), and that are **not a passenger of the
mob**; sort ascending by `Entity.distanceToSqr(mob)` (squared distance, a `comparingDouble` sort); the first becomes `TEMPTING_PLAYER`, and if there is none the memory is erased. `FOOD_TEMPTATIONS` is the `forAnimal()` form (the mob's own `isFood`);
`FROG_TEMPTATIONS` and `NAUTILUS_TEMPTATIONS` give their own item predicates.

### 2.6 Air supply defaults

`LivingEntity.shouldTakeDrowningDamage` is true when the air supply is **<= -20**. `Entity.isInWaterOrRain` is `isInWater` or `isInRain`. The
`WaterAnimal`, `AgeableWaterCreature`, `Axolotl` and `Nautilus` air handlers all follow the pattern: while alive and not in water (axolotl: not in water or rain) the air
falls by 1 per tick, and when it is at or below -20 it is reset to **0** and the mob takes 2 damage (`dryOut` for axolotl and nautilus, `drown` for
`WaterAnimal`/`AgeableWaterCreature`); in water the air is set to the mob's maximum. Because the reset is to 0, repeated damage then comes every 20 ticks.
Per-mob maxima: fish and squid 300 (the value set in the handler), axolotl 6000, nautilus 300, dolphin 4800 (and its handler does nothing).

## 3. Corrections to 21 section 4

| 21 section | Statement in 21 | Reading in this round |
|---|---|---|
| 4.1, "Out of water" | the further conditions that space the flops were not read | there are none: the flop happens on every tick on which the fish is not in water, on the ground, and has a vertical collision (4.1) |
| 4.5, Ageable row | squid and glow squid "breed into their own type" | no food, no love mode and no breeding goal exists for squid or glow squid; the offspring method is reachable only through the spawn egg used on a mob of the same type, which makes a baby (6.2; 18 section 6.12) |
| 4.5, XP row | XP "not read" | `1 + nextInt(3)`, i.e. 1 to 3, from `AgeableWaterCreature.getBaseExperienceReward` (6.1) |
| 4.6, moisture rule | hop "surrounding guard conditions displayed only partially" | the hop is guarded only by "not in water or rain" and "on ground" (4.2) |
| 4.6, Dolphin | the dolphin has no breeding food | correct: no breeding; the fish tag only speeds up a baby or sets `gotFish` (6.3) |
| 4.7, Variants | `useRareVariant` use unknown | only inside the axolotl's `getBreedOffspring`, which has two callers: breeding and the spawn egg used on an axolotl (8.2) |
| 4.7, Air | `REHYDRATE_AIR_SUPPLY` use not traced | a splashed or lingering water potion refills 1800 (8.4) |
| 4.7, Play dead | branch structure "read from bytecode order" | the exact test is given in 8.3 |
| 4.7, Supporting effect | "`extra` inferred from the branch" | read: whole Regeneration grant is gated; Mining Fatigue is always removed (8.5) |
| 4.7, IDLE row | "two conditional movers" | they are two predicate-only triggers, in water and on ground (8.6) |
| 4.8, Elder guardian | "Game Event packet 10 with value 1 ... unless silent" | the packet is sent to every returned player; its value is 0 when the elder is silent and 1 otherwise (5) |
| 4.10 | `ChargeAttack(80, ..., 0.6, 2, 12.0, 11.0, ...)` | argument roles are given in 10.6 (distance 12.0 is the maximum charge distance, 11.0 the maximum target detection distance) |

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
3. Otherwise: moistness = moistness - 1; if the new moistness is <= 0, `hurt(dryOut, 1)`; then, **if `onGround()`** (this test is made in the same branch,
   whether or not the moistness is zero): velocity += `((nextFloat()*2-1) * 0.2, 0.5, (nextFloat()*2-1) * 0.2)` (x drawn first), yaw = `nextFloat() * 360`,
   `onGround` = false, `needsSync` = true.

So a dry dolphin on the ground hops on every tick on which it stands on the ground; only the "dry" condition (not in water or rain) and the ground flag guard it.
Client-only: while in water with velocity squared length above 0.03, two `DOLPHIN` particles per tick are added behind the dolphin (not specified further).

Other dolphin routines read here: `canAttack` is false for a baby; `increaseAirSupply` returns the maximum (4800); `handleAirSupply` does nothing;
max head turn is 1 on both axes (`getMaxHeadXRot`, `getMaxHeadYRot`); `travelInWater` is: accelerate with `moveRelative(speed)`, move, multiply velocity by
0.9, and subtract 0.005 from vertical velocity when there is no attack target (this is **not** the whole vertical story: the dolphin's `SmoothSwimmingMoveControl` has `applyGravity` true (section 11), and that control's `tick` adds 0.005 to the vertical velocity on every tick on which the dolphin is in water (constant 0.005 read in `SmoothSwimmingMoveControl.tick`; 18 framework: movement controls), so for an idle dolphin the two cancel and the net vertical drift is 0; with an attack target only the +0.005 remains); `closeToNextPos` is true when the navigation target position is within 12 blocks
of the dolphin (distance to the block centre); a dolphin picks up one item at a time into the main hand (`pickUpItem`, 21 section 4.6).

## 5. Elder guardian: the effect helper

`ElderGuardian.customServerAiStep`, server side: after the ordinary guardian step, when `(tickCount + entityId) % 1200 == 0`, the elder builds the effect
instance Mining Fatigue, duration **6000**, amplifier **2**, and calls `MobEffectUtil.addEffectToPlayersAround(level, source = the elder, centre = the elder's position, radius 50.0, effect, displayLimit 1200)`.

Separately, and outside that periodic branch (it is tested on **every** server AI step): if the elder has no home, `setHomeTo(blockPosition, 16)`.

`addEffectToPlayersAround` builds the list of **all players of that level** (`ServerLevel.getPlayers`, so other dimensions are excluded) that pass **all** of:

| Order | Test |
|---|---|
| 1 | the player's game mode is survival or adventure (`ServerPlayerGameMode.isSurvival`, which delegates to `GameType.isSurvival`: SURVIVAL or ADVENTURE; creative and spectator are excluded) |
| 2 | the source entity is null **or** it is not allied to the player (`Entity.isAlliedTo`, the team test of 18 framework: teams) |
| 3 | the centre is closer than the radius: `distanceSqr(player position, centre) < radius^2` (here 2500; a player exactly 50 away is excluded) |
| 4 | the player does not have the effect, **or** the player's current instance has a **lower amplifier** than the new instance, **or** the current instance is finite and `duration <= displayLimit - 1` (here <= 1199 ticks left; an infinite duration never qualifies) |

Every player in the list receives `addEffect(copy of the instance, source = the elder)` (effect application rules: 17 and 18 framework: effects). The helper returns the
same list; the elder then sends each returned player a Game Event packet of type "guardian elder effect" (05b, Game Event) whose value is **0 if the elder is
silent, otherwise 1** (the packet is sent either way; the value is the sound/curse-overlay switch). Players that failed the filter, for example those
that still have more than 1199 ticks of Mining Fatigue III, get neither the effect nor the packet.

## 6. Squid, glow squid and dolphin: experience, breeding, babies, feeding

### 6.1 Experience

`AgeableWaterCreature` overrides `getBaseExperienceReward` to `1 + nextInt(3)`, that is **1, 2 or 3** with equal probability. Neither `Squid`,
`GlowSquid` nor `Dolphin` overrides it. This override replaces the generic `Mob` rule of 18 framework section 7.6, so the equipment bonus of that rule does not apply to them.
It applies as 18 framework: damage, death and experience describes for the killed-by-player condition. (`WaterAnimal`, the fish base, has the same formula; the guardians set their own field, 21 section 4.8.)

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
| Dolphin | `AgeableMobGroupData(0.1f)` | scale 0.65, 21 section 4.6 |

Rule 2.1 applies: the first mob of a spawned group is never a baby; each later member is a baby with the chance above. A baby has age -24000 and grows
up as an `AgeableMob` does (its age counts up each tick; `ageBoundaryReached`; 18 framework: ageing). A baby squid or dolphin can be age-locked (2.2).

### 6.4 Feeding a dolphin

`Dolphin.mobInteract`: holding an item in item tag `fishes` (cod, cooked cod, salmon, cooked salmon, pufferfish, tropical fish): on the server
the eating sound plays; if `canAgeUp()` (it is a baby that is not age-locked) the item is consumed (1) and the baby ages up by
`getSpeedUpSecondsWhenFeeding(-age)` seconds (forced); otherwise `gotFish` is set true and one item is consumed. The result is SUCCESS in both cases. Without a fish the
interaction goes to `AgeableMob.mobInteract` (2.2). Squid have no feeding interaction apart from 2.2.

## 7. Dolphin jump goal

`DolphinJumpGoal(dolphin, interval = 10)`; it is registered at priority 5 and extends `JumpGoal`, whose flags are MOVE and JUMP. The stored `interval` is
`reducedTickDelay(10)` = **5** (18 framework: tick-delay scaling). The goal is **not interruptible**.

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
   `xRot = atan2(-vy, horizontalSpeed)` in degrees (nose along the velocity).

### 7.1 Dolphin item goals (`MoveToItemGoal`, `PlayWithItemsGoal`, `ItemGoal`)

The dolphin's goal list as registered (priority, goal): 0 `BreathAirGoal`; 0 `TryFindLiquidGoal` (fluid tag `dolphin_tries_to_find`); 1 `DolphinSwimToTreasureGoal`; 2 `DolphinSwimWithPlayerGoal(4.0)`; 4 `RandomSwimmingGoal(speed 1.0, interval 10)`;
4 `RandomLookAroundGoal`; 5 `LookAtPlayerGoal(Player, 6.0)`; 5 `DolphinJumpGoal(10)`; 6 `MeleeAttackGoal(speed 1.2000000476837158, true)`; 7 `MoveToItemGoal`; 8 `PlayWithItemsGoal`; 8 `FollowPlayerRiddenEntityGoal(AbstractBoat)`; 8 `FollowPlayerRiddenEntityGoal(AbstractNautilus)`;
9 `AvoidEntityGoal(Guardian, 8.0, 1.0, 1.0)`; target selector priority 1 `HurtByTargetGoal` constructed with the class list {Guardian} and `setAlertOthers` called with an empty class list (the meaning of the two lists is by 18 framework: `HurtByTargetGoal`; not re-derived here). Goal internals other than those below are in 18 framework: goals.

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

`DolphinSwimToTreasureGoal` and `DolphinSwimWithPlayerGoal` exist as inner classes but were not re-read (Open question 7).

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
The cloud is given radius **3.0**, radius-on-use **-0.5**, duration **600**, wait time **10** and radius-per-tick = `-radius / duration` = -3.0 / 600 = **-0.005**; then the item components are applied and the cloud is added to the level. The cloud's per-tick application is in 44-9 (area effect cloud application loop).
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
| 4 | `GateBehavior` (requires `WALK_TARGET` absent; ordered, try-all): `RandomStroll.swim(0.5)` weight 2; `RandomStroll.stroll(0.15, false)` weight 2; `SetWalkTargetFromLookTarget(test, speed function, 3)` weight 3, whose test holds when the look target block is water exactly when the axolotl is in water; a trigger that fires when the axolotl is in water (weight 5); a trigger that fires when it is on the ground (weight 5) |

The two last entries are `BehaviorBuilder.triggerIf(predicate)` behaviours with the predicates `Entity.isInWater` and `Entity.onGround`. `triggerIf` builds a `OneShot` with **no memory requirements** whose trigger simply returns the predicate's result, with no side effect
(read): they carry no walk or look action, and they "start" only when the predicate holds. What a started no-op does to the gate's ordered try-all pass is given by the `GateBehavior` rules of 18 section 4. 

`TryFindLiquid(range 6, speed 0.15, fluid tag)` (read; the speed is given to the walk target; a `OneShot` requiring `ATTACK_TARGET` absent, `WALK_TARGET` absent and `LOOK_TARGET` registered; it keeps a timer, initially 0). Each evaluation, with `now` = game time:

1. if the block the mob stands in already has a fluid in the tag: do not start;
2. if `now < timer`: set `timer = now + 22` and **start** (no scan, no target set);
3. otherwise scan the region given by `findBlocksInBoxByManhattanDistance(pos, 6)` (see the scan order below), keeping only positions that differ **horizontally** from the mob's own column and whose block is a liquid block (`LiquidBlock`) whose fluid is in the tag;
   for each candidate in scan order: if the block above it is air, it is chosen and the scan stops; otherwise, if no candidate has been remembered yet and the mob is **not** closer than 1.5 to the candidate's centre, remember this candidate (the first such) and continue;
4. if a position was chosen or remembered, set `LOOK_TARGET` and `WALK_TARGET` (speed 0.15, completion distance 0) to it; in either case set `timer = now + 40` and start.

Because step 2 pushes the timer to `now + 22` whenever it is evaluated before the timer has expired, and the behaviour is evaluated each tick, a second scan can only happen when the evaluation is skipped for a while (Open question 8).

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
`usePlayerItem` replaces a held tropical fish bucket with a water bucket (`ItemUtils.createFilledResult`), and `mobInteract` first tries bucket pickup with the `Bucketable` rules (18 framework).
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

The nearest passing entity is stored. Frog goal and tongue behaviour are in 19 section 11 and 18 framework: Brain.

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
| Air | maximum 300; the handler (server, AI on, once per `baseTick`) takes `air - 1` while alive and not in water, and at air <= -20 sets air 0 and `hurtServer(dryOut, 2)`; in water the air is 300 | none of its own: the zombie nautilus is in the `undead` family through tag `zombies`, so the default rule lets it breathe water, and it has no dry-out |
| Poison | cannot be affected (`canBeAffected` false for Poison) | also immune through the `undead` tag (`ignores_poison_and_regen`) |
| Baby | yes; baby dimensions = adult dimensions x 0.5 with a passenger attachment at (0, 0.5, 0) | `canBeABaby` false: never a baby |
| `getBreedOffspring` | creates a nautilus (reason BREEDING); if the parent is tame, the child gets the parent's owner reference and the tame flag | returns null (nothing is born) |
| Leashing | `canBeLeashed` unless aggravated | unless aggravated or mob-controlled |
| Persistence | any player interaction (`interact`) calls `setPersistenceRequired`; `requiresCustomPersistence` is true when tame; `removeWhenFarAway` returns true otherwise | same code |
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
4. Otherwise `TamableAnimal.mobInteract` (breeding by food and the like, 18 framework: breeding).

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
nautilus is underwater else `nautilus_saddle_equip`; other slots use the item's sound. The equip, shear and `equipOnInteract` dispatch itself (shared with horses and wolves) is not re-derived here (Open question 1).

### 10.4 Ride and dash control

Only a **saddled** nautilus is steered: `getControllingPassenger` returns the first passenger if the nautilus is saddled and that passenger is a `Player`, otherwise the default. Riding uses the ordinary ridden travel (18 framework: riding; `travelRidden`):
per tick the controlling client computes `riddenInput = getRiddenInput(player, ...)`, calls `tickRidden`, and if it simulates the movement sets `speed = getRiddenSpeed(player)` and runs `travel(riddenInput)`; otherwise it sets the velocity to zero
(the server does not simulate a mob that a client controls; the client reports position by the vehicle-move packets, 05c).

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
| `tick` (after `TamableAnimal.tick`) | server only: apply the rider effect (below); then, on both sides: if dashing and `dashCooldown < 35`, `DASH` = false; if `dashCooldown > 0`, decrement it, and when it reaches 0 make the dash-ready sound; while in water spawn bubble particles (client only) |

Server side of the jump: the serverbound player-command packet (05c) with action "start riding jump" and a data value (the jump strength): if the player's controlled vehicle is a jumpable (`PlayerRideableJumping`), `canJump()` is true and
the data is greater than 0, the server calls `handleStartJump(data)`; "stop riding jump" calls `handleStopJump`. The dash impulse itself is applied by the controlling client; the server learns the position through the vehicle-move packets.
The dash flag therefore lives for the ticks in which the cooldown counts from 40: at the first tick the cooldown is 40 (not below 35); after the decrement it reads 39, and so on; the flag is cleared on the tick that **starts** with a cooldown of 34 or
less, that is, `DASH` stays true through the first 6 ticks after the cooldown starts and is cleared on the 7th (the constant `DASH_MINIMUM_DURATION_TICKS` 5 equals 40 - 35). The next dash is possible once the cooldown reaches 0, 40 ticks after the previous one.

Rider effect (`applyEffects`, server only, every tick): if the **first passenger** is a `Player` (saddled or not): the player gets `BREATH_OF_THE_NAUTILUS` for **60 ticks**, amplifier 0, ambient true, visible true, icon true, **when the player lacks it or `gameTime % 40 == 0`**;
the grant is skipped on other ticks if the player already has it. So the effect is refreshed every 40 ticks and never lapses while riding; it ends up to 60 ticks after dismounting.

Restriction radius: while tame and neither leashed nor a vehicle (`checkRestriction`, called each server AI step before the Brain tick): `radius = 32` if the nautilus is an adult with an empty SADDLE slot, else `16` (`getNautilusRestrictionRadius`;
babies always 16). If it has a home, whose position is closer than `radius + 8` to the nautilus's block and whose radius equals `radius`, nothing changes; otherwise `setHomeTo(blockPosition, radius)`. So a tame nautilus is kept within 32 (unsaddled) or 16 (saddled) blocks
of where it last was re-homed. The home position is used by the stroll behaviours through the restriction rule (18 framework: restriction).

Ground-level effects: `playStepSound` is empty (no step sounds); sounds depend on `isUnderWater` and on baby (baby sounds for babies) (not tabulated, they are `SoundEvents`).

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
- `dealDamageToTarget`: `hurtServer(mobAttack(animal), attack_damage)`; if the damage landed, `EnchantmentHelper.doPostAttackEffects` (17).
- `dealKnockBack`: `speedAmp` = Speed amplifier + 1 (0 without Speed); `slowAmp` = Slowness amplifier + 1 (0 without Slowness); `bonus = 0.25 x (speedAmp - slowAmp)`;
  `strength = clamp(speed x movement_speed attribute, 0.2, 2.0) + bonus`; then `animal.causeExtraKnockback(target, strength x knockbackForce, animal velocity, mobAttack source, attack_damage, false)`: when the
  strength is above 0 and the target is living, the target is knocked back by `strength` away along the animal's yaw (sine and negative cosine of its yaw; `knockback` rules of 18 framework section 7) and the animal's own horizontal velocity is multiplied by 0.6 (vertical 1.0).
- `stop`: `CHARGE_COOLDOWN_TICKS` = **80** (`timeBetweenAttacks`) and `ATTACK_TARGET` is erased. It runs on a hit, on the end of `canStillUse` (distance, line of sight), and after the 60-tick duration.

Since the dash speed is 0.6 blocks per tick (zombie 0.5), the 12-block limit is reached after 20 ticks (24 for the zombie), long before the 60-tick duration. While `ANGRY_AT` (400 ticks) lasts, IDLE's `StartAttacking` renews `ATTACK_TARGET` and FIGHT recharges as soon as
the 80-tick cooldown ends: a provoked nautilus charges about every 80 ticks plus the dash itself.

### 10.7 Nautilus damage numbers

Attack damage 3 (zombie nautilus the same); `mobAttack` source; knockback strength as in 10.6; knockback resistance 0.3 base (plus the armor modifier). Loot and XP: data tables and the `AbstractNautilus` XP rule of `Animal`
(18 framework: experience); not changed here.

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

The behaviours of the controls themselves are specified in 18 framework: movement controls (`SmoothSwimmingMoveControl`, `SmoothSwimmingLookControl`) and 18 section 5 (`SwimNodeEvaluator`,
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
the per-tick acceleration scales (18 framework: travel in water); they are not blocks-per-second.

## 12. Pointers for 19 Open questions 1 and 2

- **19 Open question 1**: the bat and the nautilus are covered by 21 (the nautilus family fully by section 10 above). The **happy ghast** is covered by 44-9 section 9; this document does not describe it.
- Pointer targets: 19 Open question 1 (bat, nautilus, happy ghast) is answered by 21, 10 of this document and 44-9 section 9; 19 Open question 2 (axolotl) by section 8 of this document.
- **19 Open question 2**: the **axolotl** is answered by section 8 of this document (and 21 section 4.7 with the corrections of section 3). Its entity-metadata cross-check row in 19 section 18 is unchanged.
- Related small answers for 19: the block tag `axolotls_spawnable_on` is {`clay`} (19 Open question 4, the axolotl part); the fluid tags `axolotl_tries_to_find` and `dolphin_tries_to_find` are both {`water`}.

## 13. Worked examples

**13.1 Fish flop.** A salmon lies on a stone block, out of water, with `onGround` true and `verticalCollision` true. Draws `nextFloat()` = 0.75 then 0.25: x += (0.75 x 2 - 1) x 0.05 = +0.025; z += (0.25 x 2 - 1) x 0.05 = -0.025;
y += 0.4. The same tick clears `onGround`, sets `needsSync`, plays the flop sound. While the salmon is airborne no further flop occurs; it flops again only after landing with the collision flag set.

**13.2 Dolphin drying.** A dolphin leaves the water at moistness 2400. Each tick moistness drops by 1 (2399, 2398, ...). Standing on a sand block (`onGround`) it hops every tick with velocity `+(+-0.2, 0.5, +-0.2)`
and a random yaw. At tick 2400 out of water its moistness reaches 0, and from then on it takes 1 `dryOut` damage per tick as well as hopping; 10 health lasts 10 further ticks.

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

**13.9 Nautilus taming.** An untamed adult nautilus and a player holding 3 pufferfish: first use consumes one and draws `nextInt(3)`; 0 tames (event 7, owner set), 1 or 2 fails (event 6); expected 3 pufferfish. A cod does nothing (not in `nautilus_taming_items`). After taming, a cod heals
`2.0 x nutrition` (a cod has a food component) when it is hurt; at full health a cod starts love mode through `Animal.mobInteract`.

**13.10 Nautilus charge.** A provoked wild nautilus (movement speed 1.0) at (0, 0, 0) with the target at (6, 0, 8): distance 10 < 11. `chargeVelocity` = (0.6, 0, 0.8) x 0.6 = (0.36, 0, 0.48). It moves 0.6 blocks per tick; at tick 20 it has gone 12 blocks (squared 144 is not below 144), the behaviour ends with
`CHARGE_COOLDOWN` 80 and `ATTACK_TARGET` erased, **only if nothing is hit first**. This example's target is exactly on the dash line and stationary, so the dash really ends on the first intersecting valid living entity: the nautilus box (width of the adult nautilus, 21 section 4.10) touches the target when the centre-to-centre
distance falls to about the sum of the half widths, around tick 16 to 17 of the 20 (the 12-block limit is not reached). To see the 12-block end, place the target off the dash line, for example at a bearing that the 0.6 per tick line passes by with a gap larger than the two half widths, and still within 11 of the nautilus. Knockback on a hit: `clamp(0.6 x 1.0, 0.2, 2.0) = 0.6`, `+ 0` (no effects), x 2.0 = **1.2**. Zombie nautilus (speed attribute 1.1): `clamp(0.5 x 1.1) = 0.55`, x 2.0 = **1.1**. With Speed II on the animal (`speedAmp` 2): `+0.5`, so (0.6 + 0.5) x 2.0 = 2.2.

**13.11 Nautilus ridden dash.** A player rides a saddled nautilus in water (movement speed 1.0, block speed factor 1.0) and presses jump with strength 45: scale = 0.4 + 0.4 x 45 / 90 = 0.6; the impulse is `lookAngle x (1.2 x 0.6 x 1.0 x 1.0)` = 0.72 along the look vector. Cooldown = 40. Strength 100: scale 1.0, impulse 1.2.
On land the factor 0.5 gives 0.5 at full strength. A second jump within 40 ticks is ignored (`onPlayerJump` returns while `dashCooldown > 0`). Ridden speed in water 0.0325; on land 0.02. Breath of the Nautilus (60 ticks) is refreshed at game times 40, 80, ...

**13.12 Armor.** A tame adult nautilus with diamond armor in the BODY slot gains +11 armor and +2 toughness; with netherite +19 armor, +3 toughness and +0.1 knockback resistance (total 0.4). Taking damage does not reduce the armor's durability.

**13.13 Zombie nautilus variant.** Spawned at a block in `warm_ocean`: candidates temperate (priority 0) and warm (priority 1, condition true); highest priority wins: coral (warm). Spawned in `ocean`: only temperate matches.

**13.14 Dolphin jump goal.** A dolphin facing east at the surface of a long channel: on each evaluation `nextInt(5) == 0` (1 in 5). It then needs water at `x + 0, 1, 4, 5, 6, 7` and air at heights +1 and +2 above each of those. If the water at `x + 4` is stone (not water) the test fails at that step and the goal does not start;
if there is a block (air test fails) at height +1 over `x + 6`, it also fails. When it starts: velocity += (0.6, 0.7, 0); while it leaves the water the pitch follows the velocity; when it comes down at |pitch| below 10 and nonzero in water, or touches ground, the goal ends and `xRot` becomes 0.

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
| Counts | the tag file contents above were read with `unzip -p`; no file counts are claimed in this document |
| Recall | no statement is marked "(recalled, not verified)" because none rests on memory; the former "(inferred)" mark on lingering cloud creation was closed by reading `ThrownLingeringPotion.onHitAsPotion` (8.4); the dolphin drop velocity (`Dolphin$ItemGoal.drop`), the `BlockPos` Manhattan iterator (`BlockPos$3`), `ShootTongue.canPathfindToTarget`, `AxolotlAi.initPlayDeadActivity` and `initFightActivity`, `TamableAnimal.isInSittingPose` and `TemptingSensor` were read in the fixer round |

Test suggestions for implementers (from section 13): the elder filter table (13.3), the axolotl damage test (13.5), the group-size rule for babies (13.4, 13.6), the nautilus knockback arithmetic (13.10), the dash impulse and cooldown (13.11), the nautilus brain's selection rules (10.5), and the
zombie nautilus variant choice (13.13) are each a deterministic function of the stated inputs and random draws.

## 15. Open questions

Closed in the fixer rounds and removed from this list: the variant tie rule (read, 10.1), the sort and search order of `findClosest` and the tempting sensor (read, 2.3 and 2.5), the two weight-5 trigger entries (read, 8.6), lingering potions and the cloud (read, 8.4), the
`armor.body` modifier id (both literals read, 10.3), the selector of `ATTACK_TARGET_CONDITIONS` (read, 10.5), the dolphin drop velocity (read, 7.1), the `TryFindLiquid` scan order (read, 8.6) and the frog path test (read, 9.2). The remaining questions are renumbered.

1. **Equip and shear dispatch.** The `equippable` component of the nautilus armor and the saddle (`equipOnInteract`, `canBeSheared`, the shearing sound) is read, but the generic interaction code that equips an item on
   a target, the shears-removal rule for BODY and SADDLE items, and the dispenser path (`canDispenserEquipIntoSlot` is read) were not traced here.
2. **Server acceptance of ridden nautilus movement.** The server does not simulate a nautilus that a client controls (`canSimulateMovement`); the validation of the reported vehicle position (speed or distance limits) is the generic vehicle-move handling and was not read here (05c, 18 framework: riding).
3. **`TargetingConditions.test` order.** The selector of `ATTACK_TARGET_CONDITIONS` is read (the entity passes unless `mob_griefing` is false and it is an armor stand, and it must be inside the world border); its place in the generic `TargetingConditions.test` order is by reference to 18 framework and was not re-derived.
4. **Client effects.** The dolphin and nautilus bubble particles, the dolphin water trail, the axolotl animation states and the nautilus models are client-only; their parameters (bubble probability clamp(speed x 2, 0.15, 1.0), spread 0.8) were seen but are not specified, since they do not affect the server rules.
5. **`isWaterAt` and the walk-target helper.** `SetWalkTargetFromLookTarget` with a predicate (axolotl) tests `Level.isWaterAt(block) == isInWater`; the exact definition of `isWaterAt` (fluid state of the block is in the water tag) was not displayed.
6. **Entity events 6 and 7.** The nautilus broadcasts events 6 (taming failed) and 7 (taming succeeded) from `TamableAnimal`; their client particle handling (`spawnTamingParticles`) was seen in the method list but its particle counts were not read (client-only).
7. **Dolphin treasure and swim-with-player goals.** `DolphinSwimToTreasureGoal` and `DolphinSwimWithPlayerGoal(4.0)` keep their 21 section 4.6 descriptions; they were not re-read. The item goals were read in 7.1.
8. **`TryFindLiquid` re-arm and scan consumption.** The timer logic (8.6 step 2) re-arms the timer to `now + 22` on every evaluation before it expires; this was read literally from the bytecode and not checked by any worked example, so how often the scan really runs is uncertain. The iterator order itself is read (8.6); that `OrderedBlockMatcher` hands the positions to the filters in that order without reordering was taken from its constructor taking the iterable and was not read method by method.
9. **Tie order of the nearest-entity list.** Ties in the sorted nearest-entity list keep the order in which the level returned the entities; that order (a level query order) was not read.
