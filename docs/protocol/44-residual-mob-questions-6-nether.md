# Residual mob questions 6: piglin and hoglin engines, strider, Nether mob details

| Item | Value |
|---|---|
| Covers | The unread parts of the piglin family (hostility, anger spreading, retaliation, hunting, bartering and admiring behaviours, the three Nether sensors, zombification), the hoglin and zoglin brains, the generic brain behaviours those mobs use (`StartAttacking`, `StopAttackingIfTargetInvalid`, `SetWalkTargetAwayFrom`, `GoToWantedItem`, `ChargeAttack`, `RamTarget`, `PrepareRamNearestTarget`), the strider's steering, lava goal and navigation, and the details of blaze, ghast, magma cube and wither skeleton that [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) section 5 did not read. Also answers the loot and structure-weight questions for these mobs. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the JSON data inside the jar (`data/minecraft/dimension_type`, `tags`, `loot_table/entities`, `worldgen/structure`, `worldgen/biome`), with no execution. A statement is read from the artifact unless it is marked "(inferred)" or "(recalled, not verified)"; every marked item is repeated in the Open questions. |
| Scope | Round RS26, GAP-31 of `docs/design/README.md` (Nether part). Answers: 21 Open questions 4, 11, 16 and 22; 18 Open question 3 (piglin, hoglin and strider behaviours), 18 Open question 19 (`GoToWantedItem`); the not-read items of 21 section 5 for blaze, ghast, magma cube and wither skeleton. Data rows (loot tables, tags, biome lists, barter table) are not tabulated again; the schema and engine are given and the few data values that a rule depends on are quoted. The per-item answer table (source document and number, answering section, section replaced) follows the header; 21 Open questions 3 (partly) and 10 stay open. |

Class names in backticks say where a fact was read; they are not the design. "21 section 5.5" means section 5.5 of document 21; the form "NN section X" is used throughout. Where this
document differs from an earlier statement, the difference is listed in section 12 and this document wins. Villages
(GAP-18, `PoiTypes`, raids) are not in this document; they belong to the villages part of round RS26.

## Contents

0. [Answer table: items of documents 18 to 21 answered here](#answer-table)
1. [Conventions and brain vocabulary](#1-conventions-and-brain-vocabulary)
2. [Piglin hostility engine](#2-piglin-hostility-engine)
3. [Admiring and bartering behaviours](#3-admiring-and-bartering-behaviours)
4. [Piglin, piglin brute and hoglin sensors](#4-piglin-piglin-brute-and-hoglin-sensors)
5. [Generic behaviours used by these brains](#5-generic-behaviours-used-by-these-brains)
6. [Hoglin and zoglin brains](#6-hoglin-and-zoglin-brains)
7. [Zombification](#7-zombification)
8. [Strider](#8-strider)
9. [Blaze, ghast, magma cube, wither skeleton: details](#9-blaze-ghast-magma-cube-wither-skeleton-details)
10. [Loot, spawn weights in structures, UNIVERSAL_ANGER](#10-loot-spawn-weights-in-structures-universal_anger)
11. [Worked examples and validation](#11-worked-examples-and-validation)
12. [Corrections to earlier documents](#12-corrections-to-earlier-documents)
13. [Open questions](#13-open-questions)

## Answer table

Each row is one Open question or "not read" item of documents 18 to 21 that this document answers (or leaves open), with the section here and the section of 18 to 21 that it replaces.

| Source (document, item) | Answered in | Replaces |
|---|---|---|
| 21 Open question 3 (bastion and fortress structure data) | not answered (partly: structure spawn overrides and biome lists in 10) | stays open: Open question 10 |
| 21 Open question 4 (zombification attribute per dimension, hoglin and piglin conversion) | 7 | 21 section 5.5.1 zombification |
| 21 Open question 10 | not answered, outside this part | stays open |
| 21 Open question 11 (strider steering, lava, navigation) | 8 | 21 section 5.7 |
| 21 Open question 16 (piglin and hoglin loot, `UNIVERSAL_ANGER` writer) | 10, 2.5 | 21 sections 5.5.1, 5.6 |
| 21 Open question 22 (hoglin and zoglin in structures) | 10 | 21 section 5.6 |
| 21 section 5, not read: piglin sensors, hostility, retaliation, hunting | 2, 4 | 21 section 5.5.1, 5.5.2 |
| 21 section 5, not read: admiring and bartering | 3 | 21 section 5.5.1 |
| 21 section 5, not read: hoglin and zoglin brains | 5.1 to 5.3, 6 | 21 section 5.6 |
| 21 section 5, not read: blaze details | 9.2 | 21 section 5.2 |
| 21 section 5, not read: ghast details | 9.1 | 21 section 5.1 |
| 21 section 5, not read: magma cube details, cube-mob goals | 9.3 | 21 section 5.3 |
| 21 section 5, not read: wither skeleton details | 9.4 | 21 section 5.4 |
| 21 section 5, not read: piglin spear behaviours | 2.11 | 21 section 5.5.1 (parameters only) |
| 18 Open question 3 (piglin, hoglin, strider behaviours) | 2 to 8 | 18 section 4 examples |
| 18 Open question 19 (`GoToWantedItem`) | 3.3, 5.4 | 18 section 4.6 |
| 18 `Sensor.isEntityAttackable` clause list | 1 (conditions and range 16 read; `TargetingConditions.test` body not) | 18 section 4 (follow-range wording) |
| 19 goat `RamTarget`, `PrepareRamNearestTarget` | 5.6 (constants, cooldown ranges and target conditions read; only the candidate selection of `PrepareRamNearestTarget` open) | 19 goat section |
| Nautilus `ChargeAttack` parameters, happy ghast leftovers | not in this part: the generic `ChargeAttack` engine is in 5.5; the nautilus parameters and the happy ghast items are answered in part 7 of this round (`44-residual-mob-questions-7-*`, cross-reference by that number when it exists); the happy ghast move-control `careful` branch is already read in 9.1 | stays with part 7 |
| Villages, raids, POI (`PoiTypes`, GAP-18) | not in this part: the villages part of round RS26 (`44-residual-mob-questions-3-villagers-poi-raids.md`, section number 3 of the 44 series) | stays with that document |
| 20 | no item of document 20 is in the Nether scope | none |

## 1. Conventions and brain vocabulary

The brain model is that of [18](18-mob-framework.md) 4 (memories with optional expiry in ticks, sensors, activities, behaviours). Terms used here:

- A memory "with expiry N" is set for N game ticks and then disappears; "set" without expiry stays until erased.
- `ATTACK_TARGET`, `ANGRY_AT` (a UUID), `AVOID_TARGET`, `WALK_TARGET`, `LOOK_TARGET`, `HURT_BY` (the sensor memory of the last attacker), `HUNTED_RECENTLY`, `ADMIRING_ITEM`, `ADMIRING_DISABLED`, `UNIVERSAL_ANGER`, `NEAREST_REPELLENT`, `PACIFIED`, `BREED_TARGET`, `CANT_REACH_WALK_TARGET_SINCE` (game time of the first failure to reach the walk target) are the memory types named.
- An activity created with a "gating memory" (the 4-argument `ActivityData.create`) is valid only while that memory has a value, and that memory is erased when the activity stops. Piglin: FIGHT gated by `ATTACK_TARGET`, ADMIRE_ITEM by `ADMIRING_ITEM`, AVOID by `AVOID_TARGET`, CELEBRATE by `CELEBRATE_LOCATION`, RIDE by `RIDE_TARGET`. IDLE and CORE have no gate. Hoglin: FIGHT by `ATTACK_TARGET`, AVOID by `AVOID_TARGET`. Zoglin: FIGHT by `ATTACK_TARGET`. (Read: `ActivityData.create` adds a `VALUE_PRESENT` condition and the same memory to the erase-when-stopped set.)
- "Attackable" for the brain helpers (`Sensor`, read): `isEntityAttackable(level, mob, target)` is `TargetingConditions.forCombat()` with range 16.0 tested on (level, mob, target); when the target is already the mob's `ATTACK_TARGET` the variant that also ignores invisibility testing is used. `isEntityAttackableIgnoringLineOfSight` is the same pair of conditions with `ignoreLineOfSight()` added. So the range is the fixed 16 blocks of the condition, not the mob's follow range. The clauses inside `TargetingConditions.test` (the generic can-attack, creative/spectator, range and line-of-sight tests) were not expanded here (Open question 1); they are in 18 section 4.
- `BehaviorUtils.isOtherTargetMuchFurtherAwayThanCurrentAttackTarget(mob, other, 4.0)`: false when the mob has no `ATTACK_TARGET`; otherwise true when `distanceSqr(mob, other) > distanceSqr(mob, currentTarget) + 4.0 * 4.0` (that is, other is more than 16 squared-blocks further than the current target, additive on the squared distance). All three Nether brains call it with 4.0.
- `BehaviorUtils.getNearestTarget(mob, optionalCurrent, candidate)`: the candidate when the optional is empty; otherwise `getTargetNearestMe(mob, current, candidate)`, which compares `distanceToSqr` of the two entities' positions from the mob with a single strict less-than style test on doubles and returns the nearer one (read; which entity wins an exact tie was not determined, Open question 8).
- `BehaviorUtils.throwItem(mob, stack, targetPos)`: spawns an item entity at (mob x, mob eye Y minus 0.3, mob z) with the mob as thrower, velocity = `normalize(targetPos - mobPos) * (0.3, 0.3, 0.3)` (each axis multiplied by 0.3), default pick-up delay, then adds the entity.

## 2. Piglin hostility engine

All of this is `PiglinAi` unless another class is named. Piglin brutes share only the pieces named in 2.7.

### 2.1 Constants

| Constant | Value |
|---|---|
| `ANGER_DURATION` (memory expiry of `ANGRY_AT` and `UNIVERSAL_ANGER`) | 600 ticks |
| `PLAYER_ANGER_RANGE` | 16 blocks (box inflate) |
| `TIME_BETWEEN_HUNTS` (expiry of `HUNTED_RECENTLY`) | uniform 30 to 120 seconds, i.e. 600 to 2400 ticks (`TimeUtil.rangeOfSeconds(30, 120)`) |
| `RETREAT_DURATION` (expiry of `AVOID_TARGET` set by retreat) | uniform 5 to 20 seconds = 100 to 400 ticks |
| `BABY_FLEE_DURATION_AFTER_GETTING_HIT` | 100 ticks |
| `HIT_BY_PLAYER_MEMORY_TIMEOUT` (expiry of `ADMIRING_DISABLED` when hurt by a player) | 400 ticks |
| `DESIRED_DISTANCE_FROM_ZOMBIFIED` (`isNearZombified`) | 6 blocks |
| `AVOID_ZOMBIFIED_DURATION`, `BABY_AVOID_NEMESIS_DURATION` | each uniform 5 to 7 seconds = 100 to 140 ticks |
| `MELEE_ATTACK_COOLDOWN` | 20 ticks |
| `EAT_COOLDOWN` (`ATE_RECENTLY` expiry) | 200 ticks |
| `PROBABILITY_OF_CELEBRATION_DANCE` | 0.1 |
| `CELEBRATION_TIME` | 300 ticks |
| `ADMIRE_DURATION` | 119 ticks (used as the expiry of `ADMIRING_ITEM`) |
| `RIDE_START_INTERVAL` / `RIDE_DURATION` | uniform 10 to 40 seconds / uniform 10 to 30 seconds |
| `MAX_WALK_DISTANCE_TO_START_RIDING` | 8 blocks |
| `MAX_LOOK_DIST` / look distance for a player holding a loved item | 8 / 14 blocks |
| `INTERACTION_RANGE` | 8 blocks |
| `MAX_DISTANCE_TO_WALK_TO_ITEM` | 9 blocks (3.3) |
| `MAX_TIME_TO_WALK_TO_ITEM` / disable-walk expiry after failing to reach | 200 / 200 ticks |
| `DESIRED_DISTANCE_FROM_ENTITY_WHEN_AVOIDING` | 12 blocks |
| Crossbow minimum desired distance from target | 5 blocks |
| Speed multipliers | strafing back from target 0.75; mounting 0.8; dancing 0.6; idling 0.6; avoiding, retreating, going to a wanted item, going to the celebrate location 1.0; all other behaviours listed in this document 1.0 (not a statement about behaviours not tabulated, Open question 5) |

The per-activity behaviour lists of the piglin brain (CORE, IDLE, FIGHT, AVOID, CELEBRATE, RIDE, ADMIRE_ITEM) and of the brute brain are not tabulated here beyond the behaviours specified in 2.2 to 2.8, 2.11, 3.3 and 5; the brain layout is that of 21 section 5.5. This document does **not** replace 21 section 5.5 in full: a complete ordered list of the CORE, IDLE, AVOID, CELEBRATE, RIDE and ADMIRE_ITEM behaviours with their priorities is still missing and stays in Open question 5; the answer table above lists only the parts answered. The FIGHT activity also holds `BackUpIfTooClose(5, 0.75)`, `SpearApproach(1.0, 10.0)`, `SpearAttack(1.0, 1.0, 2.0)`, `SpearRetreat(1.0)` and `CrossbowAttack` (read in `PiglinAi`, constructor arguments only; bodies in 2.11 and 5.7, except the crossbow, Open question 5). The behaviours `StartCelebratingIfTargetDead`, `Mount`, `DismountOrSkipMounting` and `GoToTargetLocation` are read in 5.7.

### 2.2 What a piglin may attack: `findNearestValidAttackTarget` and `isNearestValidAttackTarget`

`findNearestValidAttackTarget(piglin)` returns an optional living entity, evaluated in this order (first hit wins):

1. If `isNearZombified(piglin)` (a memory `NEAREST_VISIBLE_ZOMBIFIED` exists and that entity is closer than 6 blocks): no target.
2. If the entity with UUID `ANGRY_AT` exists (looked up among the level's entities by UUID) and is attackable ignoring line of sight: it.
3. If `UNIVERSAL_ANGER` has a value and `NEAREST_VISIBLE_ATTACKABLE_PLAYER` has a value: that player.
4. If `NEAREST_VISIBLE_NEMESIS` has a value (a wither skeleton or Wither, 4.1): it (no attackable test).
5. If `NEAREST_TARGETABLE_PLAYER_NOT_WEARING_GOLD` has a value and that player is attackable (with line of sight): it.
6. Otherwise none.

`isNearestValidAttackTarget(piglin, entity)` is true when step 1 to 6 returns exactly `entity` (identity). The FIGHT activity's `StopAttackingIfTargetInvalid` condition is the negation of that (5.2), so a piglin keeps fighting only while its target is still the best candidate, and drops the fight when it walks within 6 blocks of a zombified piglin or zoglin.

The same finder is the target finder of `StartAttacking` in IDLE and in CELEBRATE; the start condition is `isAdult` in both (babies never start attacks).

### 2.3 `PiglinAi.wasHurtBy(level, piglin, attacker)`

Called from `Piglin.hurtServer` after a successful hurt when the damage source's causing entity is a living entity (the entity, not the direct one). Order:

1. If the attacker is a `Piglin`: return (piglins ignore piglin attackers; a piglin brute attacker is not excluded here).
2. If the piglin holds anything in its off hand, run `stopHoldingOffHandItem(level, piglin, false)` (3.4: the item is put away, not bartered).
3. Erase `CELEBRATE_LOCATION`, `DANCING`, `ADMIRING_ITEM`.
4. If the attacker is a player: set `ADMIRING_DISABLED` = true with expiry 400.
5. If an `AVOID_TARGET` exists and the attacker's entity type differs from the type of the avoid target: erase `AVOID_TARGET` (a hit by a different kind of creature cancels the current retreat; read: the `Optional.ifPresent` consumer `lambda$wasHurtBy$0` compares the avoid-target entity's entity type with the attacker's entity type by object identity and erases `AVOID_TARGET` when they are not the same type object).
6. If the piglin is a baby: set `AVOID_TARGET` = the attacker with expiry 100; then, if the attacker is attackable ignoring line of sight, run `broadcastAngerTarget(attacker)` (2.5). Return.
7. If the attacker is a hoglin and hoglins outnumber piglins (2.6): `setAvoidTargetAndDontHuntForAWhile(attacker)` then `broadcastRetreat(attacker)`. Return.
8. Otherwise `maybeRetaliate(piglin, attacker)`.

### 2.4 `maybeRetaliate(level, piglinOrBrute, attacker)`

1. If the mob's AVOID activity is active: return.
2. If the attacker is not attackable ignoring line of sight: return.
3. If `isOtherTargetMuchFurtherAwayThanCurrentAttackTarget(mob, attacker, 4.0)`: return.
4. If the attacker is a player and the game rule `universal_anger` is true: `setAngerTargetToNearestTargetablePlayerIfFound` (the nearest visible attackable player from `NEAREST_VISIBLE_ATTACKABLE_PLAYER`, else the attacker) and `broadcastUniversalAnger`.
5. Else: `setAngerTarget(attacker)` and `broadcastAngerTarget(attacker)`.

### 2.5 Setting and spreading anger

`setAngerTarget(level, piglin, target)`:
1. If the target is not attackable ignoring line of sight: return.
2. Erase `CANT_REACH_WALK_TARGET_SINCE`.
3. Set `ANGRY_AT` = target UUID with expiry 600.
4. If the target is a hoglin and the piglin `canHunt()`: `dontKillAnyMoreHoglinsForAWhile` (set `HUNTED_RECENTLY` = true with a `TIME_BETWEEN_HUNTS` sample).
5. If the target is a player and the game rule `universal_anger` is true: set `UNIVERSAL_ANGER` = true with expiry 600. (This is the writer of `UNIVERSAL_ANGER`; no other writer exists in the piglin classes. `UNIVERSAL_ANGER` is registered on `Piglin` only; a brute never gets it because brutes are not given this memory in their registered list, 2.7.)

`maybeRetaliate` (2.4) therefore calls `setAngerTarget` on the source first and broadcasts only to the others. In the baby branch of `wasHurtBy` (2.3 step 6) the source itself gets no anger (only its listeners do). The source is likewise absent from its own `NEAREST_VISIBLE_ADULT_PIGLINS`, so no broadcast reaches the piglin that started it.

`ATTACK_TARGET` is not set here; the IDLE/CELEBRATE `StartAttacking` behaviour converts the anger into an attack target on a later brain tick (5.1).

`broadcastAngerTarget(level, source, target)`: for every adult piglin or piglin brute in the source's `NEARBY_ADULT_PIGLINS` memory (the list written by the sensor, 4.1; it is built from `NEAREST_LIVING_ENTITIES`, a memory that never contains the mob itself, so the **source is not in its own list**): if the target is a hoglin, skip unless that listener `canHunt()` and the hoglin `canBeHunted()` (`Hoglin.canBeHunted` is `isAdult && !cannotBeHunted`); otherwise `setAngerTargetIfCloserThanCurrent(listener, target)`, which keeps the listener's current anger target when it is the nearer of the two (`getNearestTarget(listener, currentAngerTarget, target)`; the call to `setAngerTarget` happens only when the nearest is the new target and differs from the current one).

`broadcastUniversalAnger(level, source)`: for every adult piglin in `NEARBY_ADULT_PIGLINS`, take that listener's `NEAREST_VISIBLE_ATTACKABLE_PLAYER` and, if present, `setAngerTarget` to it.

### 2.6 Retreat from hoglins

- `hoglinsOutnumberPiglins(piglin)`: `visibleAdultHoglinCount > visibleAdultPiglinCount + 1`, where the counts are the memories `VISIBLE_ADULT_HOGLIN_COUNT` and `VISIBLE_ADULT_PIGLIN_COUNT` (default 0 when absent). The `+ 1` counts the piglin itself, which is not in its own visible list (2.5, 4.1). `piglinsEqualOrOutnumberHoglins` is its negation.
- `setAvoidTargetAndDontHuntForAWhile(piglin, entity)`: erase `ANGRY_AT`, `ATTACK_TARGET`, `WALK_TARGET`; set `AVOID_TARGET` = entity with expiry uniform 100 to 400 ticks; then `dontKillAnyMoreHoglinsForAWhile`.
- `broadcastRetreat(piglin, entity)`: for every adult piglin in the source's visible adult list (`NEAREST_VISIBLE_ADULT_PIGLINS`), if it is a `Piglin` (not a brute): `retreatFromNearestTarget(listener, entity)`, which takes the nearer of (the listener's current `AVOID_TARGET`, `entity`), then the nearer of (the listener's current `ATTACK_TARGET`, that result), and calls `setAvoidTargetAndDontHuntForAWhile` with it.
- `wantsToStopFleeing(piglin)` (the AVOID activity's erase test for `AVOID_TARGET`): true when there is no `AVOID_TARGET`; if the avoid target is a hoglin, true when piglins equal or outnumber hoglins; if it is zombified (`isZombified`), true when `NEAREST_VISIBLE_ZOMBIFIED` is not that entity; otherwise false. A retreat from a hoglin or zombified creature therefore ends by expiry (100 to 400 ticks) or by the balance test.
- `isZombified(entity)`: the entity type is `zombified_piglin` or `zoglin` (exactly those two).

### 2.7 Piglin brute

`PiglinBruteAi` (read) has its own target finder, hurt handler, activity list and memory initialisation; it shares `maybeRetaliate`, `broadcastAngerTarget`, `setAngerTarget` and the sensors' `NEARBY_ADULT_PIGLINS` with `PiglinAi`.

**Target finder** (`PiglinBruteAi.findNearestValidAttackTarget`, parameter type `AbstractPiglin`), first hit wins:

1. The entity with UUID `ANGRY_AT`, when it exists and is attackable ignoring line of sight (the same test as 2.2 step 2).
2. The `NEAREST_VISIBLE_ATTACKABLE_PLAYER` memory value, when present.
3. The `NEAREST_VISIBLE_NEMESIS` memory value (wither skeleton or Wither, 4.2), when present, with no attackable test.
4. Otherwise none.

There is no zombified-piglin check, no `UNIVERSAL_ANGER` step, no not-wearing-gold step and no gold-armour test: a brute attacks any visible attackable player regardless of armour. `isNearestValidAttackTarget(brute, entity)` is true when that finder returns exactly `entity` (identity).

**Activities.** `updateActivity` picks the first valid of FIGHT, IDLE (no ADMIRE_ITEM, AVOID, CELEBRATE or RIDE); when the active non-core activity changed it plays the activity sound (angry sound only for FIGHT; no other activity has a sound) and sets the aggressive flag to "`ATTACK_TARGET` has a value". `maybePlayActivitySound` (each AI step) plays the same sound with probability `nextFloat() < 0.0125` (read: float compared to 0.0125 as a double). FIGHT is gated by `ATTACK_TARGET`, priority base 10, behaviours in order: `StopAttackingIfTargetInvalid` with the condition "the target is not the nearest valid attack target" (the brute finder above), `SetWalkTargetFromAttackTargetIfTargetOutOfReach(1.0)`, `MeleeAttack(20)`. `initMemories` only sets `HOME` to the global position (current dimension and block position) of the brute.

**Hurt.** `PiglinBruteAi.wasHurtBy(level, brute, attacker)` returns at once when the attacker is any `AbstractPiglin` (a piglin or another brute), so brutes ignore damage from piglins and from other brutes; for any other attacker it calls `PiglinAi.maybeRetaliate` (declared for `AbstractPiglin`), so steps 1 to 5 of 2.4 apply, including the AVOID-active test (a brute has no AVOID activity, so the test is always false, inferred from its activity list above).

**Which `setAngerTarget` runs.** There are two methods:

| Method | Signature | Effect | Callers (read) |
|---|---|---|---|
| `PiglinBruteAi.setAngerTarget(brute, target)` | no level, no attackable test | erase `CANT_REACH_WALK_TARGET_SINCE`; set `ANGRY_AT` = target UUID with expiry 600 | none: a search of every class in the jar found `PiglinBruteAi` referenced only by `PiglinBrute` (calls `initMemories`, `updateActivity`, `maybePlayActivitySound`, `wasHurtBy`) and by itself; the method is never invoked |
| `PiglinAi.setAngerTarget(level, mob, target)` | `AbstractPiglin` mob | the 5 steps of 2.5, including the attackable test, the hunt-hoglin step and the `UNIVERSAL_ANGER` write | every anger path: `maybeRetaliate` (2.4), `broadcastAngerTarget`, `broadcastUniversalAnger`, `setAngerTargetToNearestTargetablePlayerIfFound`, `StartHuntingHoglin`, `angerNearbyPiglins` (2.9, `Piglin` only) |

So for a brute, `maybeRetaliate` and the broadcasts from a piglin or brute run `PiglinAi.setAngerTarget` (the brute's own method is unused). The `UNIVERSAL_ANGER` write in step 5 of 2.5 is executed on a brute when the target is a player and the game rule is true, but `UNIVERSAL_ANGER` is not in the brute's registered memory list, so the write has no effect on a brute (inferred from the registered list, which holds `NEAREST_VISIBLE_ADULT_PIGLINS` and the sensor memories only; whether `Brain.setMemoryWithExpiry` ignores an unregistered type was not read). Brutes never hunt (`canHunt` false), do not read `UNIVERSAL_ANGER` (their finder has no such step) and set no `ADMIRING_*` memory.

### 2.8 Hunting hoglins: `StartHuntingHoglin` and `RememberIfHoglinWasKilled`

`StartHuntingHoglin` (IDLE, gated by `canHunt()`; for `Piglin` that is `!cannotHunt`, a persisted flag `CannotHunt` that nothing in the game sets to true, so it is false unless loaded from data):

- Required memories: `NEAREST_VISIBLE_HUNTABLE_HOGLIN` present; `ANGRY_AT` absent; `HUNTED_RECENTLY` absent; `NEAREST_VISIBLE_ADULT_PIGLINS` registered.
- Extra conditions: the piglin is not a baby, and none of the piglins in `NEAREST_VISIBLE_ADULT_PIGLINS` has `HUNTED_RECENTLY`.
- Effect: `setAngerTarget(hoglin)` (which also sets `HUNTED_RECENTLY`, 2.5 step 4); `dontKillAnyMoreHoglinsForAWhile(self)`; `broadcastAngerTarget(hoglin)`; and every piglin in `NEAREST_VISIBLE_ADULT_PIGLINS` gets `HUNTED_RECENTLY` the same way. So one hunt at a time per group, then a 30 to 120 second pause for all of them.

`RememberIfHoglinWasKilled` (FIGHT): requires `ATTACK_TARGET` present, `HUNTED_RECENTLY` registered. When the target is a hoglin that `isDeadOrDying`, set `HUNTED_RECENTLY` = true with a `TIME_BETWEEN_HUNTS` sample. Always succeeds.

### 2.9 Who calls `angerNearbyPiglins(level, player, requireLineOfSight)`

The method collects every `Piglin` (not brutes: the query class is `Piglin`) in the box `player.boundingBox.inflate(16)`; keeps only those whose brain has the IDLE activity active (`PiglinAi.isIdle` = `brain.isActive(IDLE)`: a piglin that is already fighting, admiring, avoiding, celebrating or riding is not affected); and, when `requireLineOfSight` is true, only those that can see the player (`BehaviorUtils.canSee`). For each, with game rule `universal_anger` true: `setAngerTargetToNearestTargetablePlayerIfFound`, else `setAngerTarget(player)`. It does not broadcast.

Callers (every reference found in the server classes of the jar):

| Trigger | Line of sight required |
|---|---|
| A player opens a chest, trapped chest or copper chest (any of the four oxidation states, waxed or not), barrel, ender chest or shulker box (`ChestBlock`, `BarrelBlock`, `EnderChestBlock`, `ShulkerBoxBlock`, after the menu opens and the statistic is awarded). `CopperChestBlock` extends `ChestBlock` and overrides neither the use method nor the open path, so a copper chest runs the inherited `ChestBlock` call | yes |
| A player opens a chest boat, two call sites in `AbstractChestBoat`: `interact` (only on the secondary-use branch, when `interactWithContainerVehicle` consumed the action and the level is a server level, after the container-open game event) and `openCustomInventoryScreen` (server level, after the menu opens and the game event fires); both pass line of sight true. A chest minecart: `MinecartChest.interact` calls `interactWithContainerVehicle`; when that consumed the action and the player's level is a server level it fires the container-open game event and then calls the anger method with line of sight true (read) | yes |
| A container entity (`ContainerEntity.chestVehicleDestroyed`) is destroyed: the method returns at once when the game rule `entity_drops` is false (no drop, no anger); otherwise it drops the contents and, only when the damage source's direct entity is a player, calls anger | yes |
| A player breaks a block in block tag `guarded_by_piglins` (`Block.playerWillDestroy`, server side) | no |

Block tag `guarded_by_piglins` (read): `#copper_chests`, `gold_block`, `barrel`, `chest`, `ender_chest`, `gilded_blackstone`, `trapped_chest`, `raw_gold_block`, `#shulker_boxes`, `#gold_ores`. The caller list (`ChestBlock`, `BarrelBlock`, `EnderChestBlock`, `ShulkerBoxBlock`, `MinecartChest` (`interact`), `AbstractChestBoat`, `ContainerEntity`, and `Block.playerWillDestroy` with the flag false) was verified by a constant-pool search across the world classes; there are no other callers.

### 2.10 Activity selection and the aggressive flag

Every server AI step (`Piglin.customServerAiStep`): `brain.tick`, then `PiglinAi.updateActivity`, then `AbstractPiglin.customServerAiStep` (zombification, section 7). `updateActivity`: choose the first valid of ADMIRE_ITEM, FIGHT, AVOID, CELEBRATE, RIDE, IDLE (valid = the gating memory has a value); when the active activity changed, play the sound for it (FIGHT: angry; AVOID: retreat when the avoid target is near; ADMIRE_ITEM: admiring; CELEBRATE: celebrate; jealous when a player holding a loved item is seen while idle-type; ambient otherwise); set the aggressive flag to "`ATTACK_TARGET` has a value"; stop riding when the piglin is a baby riding a baby piglin or baby hoglin and `RIDE_TARGET` is absent; erase `DANCING` when `CELEBRATE_LOCATION` is absent; set the `dancing` entity flag from the `DANCING` memory. Sound selection (`getSoundForActivity`, read), first match wins: activity FIGHT: angry; else the piglin `isConverting`: retreat; else activity AVOID and the avoid target exists and is closer than 12 blocks (`closerThan` 12.0): retreat; else ADMIRE_ITEM: admiring; else CELEBRATE: celebrate; else a visible player holding a loved item (`seesPlayerHoldingLovedItem`): jealous; else a repellent is near (`isNearRepellent`, the `NEAREST_REPELLENT` memory present): retreat; else ambient.

### 2.11 Spear behaviours of the piglin FIGHT activity

The brain registers four extra memories: `SPEAR_STATUS` (values APPROACH, CHARGING, RETREAT; no expiry), `SPEAR_ENGAGE_TIME` (int), `SPEAR_CHARGE_POSITION` and `SPEAR_FLEEING_POSITION` (positions), `SPEAR_FLEEING_TIME` (int). All three behaviours use the same "able to attack" test: `ATTACK_TARGET` present and the main-hand stack has the data component `kinetic_weapon` (a spear). The speed factor of a movement is the behaviour's speed times the `chargeSpeedModifier` of the root vehicle when the mob rides a `Mob`, else 1 (the multiplication was read at the operand level, the product is inferred). They run in the order BackUpIfTooClose, SpearApproach, SpearAttack, SpearRetreat, CrossbowAttack among the FIGHT behaviours, after the walk-to-target behaviour (21 section 5.5.1).

| Behaviour | Required memories | Start | While running | Stop |
|---|---|---|---|---|
| `SpearApproach(speed 1.0, approach distance 10.0)` | `SPEAR_STATUS` absent | able to attack and the mob is not using an item | continues while able to attack and the squared distance to the target is greater than 10.0 (the field is named and used as a squared distance: the 10.0 passed by the brain is compared to a squared distance directly). Each tick: `LOOK_TARGET` = target; navigate toward the target entity at speed 1.0. No timeout | navigation stopped; `SPEAR_STATUS` = CHARGING. Start sets aggressive true and `SPEAR_STATUS` = APPROACH |
| `SpearAttack(charging speed 1.0, repositioning speed 1.0, in-range radius squared 2.0)` | `SPEAR_STATUS` present | `SPEAR_STATUS` is CHARGING, able to attack, not using an item. Start: aggressive true; `SPEAR_ENGAGE_TIME` = the use duration read from the `kinetic_weapon` component (0 when absent; which component field is the duration was not resolved, Open question 12); `SPEAR_CHARGE_POSITION` erased; the mob starts using the main-hand item | continues while `SPEAR_ENGAGE_TIME` > 0 and able to attack. Each tick: `LOOK_TARGET` = target; `SPEAR_ENGAGE_TIME` is reduced by 1 (the subtract was not visible in the instruction filter, inferred); if a `SPEAR_CHARGE_POSITION` exists navigate to it at the repositioning speed and erase it when the navigation is done; else navigate toward the target at the charging speed, and when the squared distance to the target is below 2.0, or the navigation has finished, pick a new `SPEAR_CHARGE_POSITION` with `LandRandomPos.getPosAway` away from the target, using the reposition distances 6 and 7 (`MIN_REPOSITION_DISTANCE`, `MAX_REPOSITION_DISTANCE`; a +2 passenger adjustment to the distance is present, exact arithmetic inferred) | navigation stopped, mob stops using the item, `SPEAR_CHARGE_POSITION` and `SPEAR_ENGAGE_TIME` erased, `SPEAR_STATUS` = RETREAT |
| `SpearRetreat(speed 1.0)` | `SPEAR_STATUS` present; behaviour timeout 100 ticks (`MAX_FLEEING_TIME`) | able to attack, not using an item, `SPEAR_STATUS` is RETREAT, and `getPosAway(mob, max(0, 9 - dist), max(1, 11 - dist), vertical 7, target position)` returns a position, with dist = the distance to the target (+2 when the mob is a passenger); the position is stored in `SPEAR_FLEEING_POSITION` (`MIN_COOLDOWN_DISTANCE` 9, `MAX_COOLDOWN_DISTANCE` 11; the subtractions are inferred from the two constants and the two max calls). Start: aggressive true; `SPEAR_FLEEING_TIME` = 0 | continues while `SPEAR_FLEEING_TIME` < 100, a fleeing position exists, the navigation is not done and the mob is able to attack. Each tick: `LOOK_TARGET` = target; `SPEAR_FLEEING_TIME` + 1; navigate to the fleeing position at speed 1.0 | navigation stopped and aggressive reset to false (the remaining erasures of the three spear memories at stop were not expanded, Open question 12) |

So one spear cycle is: approach until within sqrt(10) = 3.16 blocks, charge (use the item, whose kinetic-weapon duration sets the engage time) while repositioning when too close, then retreat 9 to 11 blocks away for at most 100 ticks.

## 3. Admiring and bartering behaviours

### 3.1 Predicates (`PiglinAi`)

| Predicate | Rule |
|---|---|
| `isBarterCurrency(stack)` | item is `gold_ingot` (`BARTERING_ITEM`) |
| `isLovedItem(stack)` | item tag `piglin_loved` |
| `isFood(stack)` | item tag `piglin_food` |
| `canAdmire(piglin, stack)` | `ADMIRING_DISABLED` absent, `ADMIRING_ITEM` absent, piglin is an adult, and the stack is barter currency |
| `isNotHoldingLovedItemInOffHand` | off hand empty, or its item is not loved |
| `isPlayerHoldingLovedItem(entity)` | the entity is a player and any held stack (`isHolding(predicate)`) is loved |
| `hasEatenRecently` | memory `ATE_RECENTLY` present |

Item tag `piglin_loved` (read, 26 entries; `#` marks a tag reference): `#gold_ores` (block-item tag), `gold_block`, `gilded_blackstone`, `light_weighted_pressure_plate`, `gold_ingot`, `bell`, `clock`, `golden_carrot`, `glistering_melon_slice`, `golden_apple`, `enchanted_golden_apple`, `golden_helmet`, `golden_chestplate`, `golden_leggings`, `golden_boots`, `golden_horse_armor`, `golden_nautilus_armor`, `golden_sword`, `golden_spear`, `golden_pickaxe`, `golden_shovel`, `golden_axe`, `golden_hoe`, `raw_gold`, `raw_gold_block`, `golden_dandelion`. Item tag `piglin_food` (read): `porkchop`, `cooked_porkchop`. (`gold_ingot` is in `piglin_loved`, so barter currency is also a loved item.)

### 3.2 Picking things up

`Piglin.wantsToPickUp(level, stack)` = game rule `mob_griefing` is true and `canPickUpLoot` and `PiglinAi.wantsToPickup(piglin, stack)`. The latter, in order:

1. Baby and the stack is in tag `ignored_by_piglin_babies` (`leather`): no.
2. The stack is in item tag `piglin_repellents`: no.
3. `ADMIRING_DISABLED` present and `ATTACK_TARGET` present: no.
4. Barter currency: yes exactly when no loved item is in the off hand.
5. `canAddToInventory(stack)` is computed as `fits`. Gold nugget: `fits`. Food: yes when not `hasEatenRecently` and `fits`. A loved item: yes when no loved item is in the off hand and `fits`.
6. Anything else: `canReplaceCurrentItem(stack)` (the equipment comparison; its inner comparison was not expanded: Open question 2).

`Piglin.pickUpItem` calls `onItemPickup` and `PiglinAi.pickUpItem(level, piglin, itemEntity)`:
1. Stop walking (erase `WALK_TARGET`).
2. A gold nugget: take the whole stack (`take(item, count)`), discard the entity, and the stack is the nugget stack; any other item: take 1 (`take(item, 1)`) and split one item off the entity (discard the entity when empty).
3. If the picked stack is loved: erase `TIME_TRYING_TO_REACH_ADMIRE_ITEM`; `holdInOffhand(stack)` (if the off hand already holds something it is dropped as an item first, then the stack goes to the off hand); `admireGoldItem` (set `ADMIRING_ITEM` = true with expiry 119).
4. Else if it is food (`piglin_food`) and the piglin has not eaten recently: it eats. `eat` sets `ATE_RECENTLY` = true with expiry 200 and the method **returns**: the one porkchop already taken from the entity (step 2) is consumed, and it is neither equipped nor put in the inventory (read: the branch is `isFood && !hasEatenRecently` followed by `eat` and an immediate return).
5. Otherwise (a non-loved, non-food item such as armor, a gold nugget or any other wanted item, or food when `ATE_RECENTLY` is already set): `equipItemIfPossible(stack)`; if the stack was not equipped (the returned stack is not the empty stack), `putInInventory` it. (The equip rules of `equipItemIfPossible` are the generic mob equipment rules, 18; Open question 2.) Step 5 is therefore never reached for a loved item (step 3 returns) or for food eaten under step 4.

A player hands over gold: `Piglin.mobInteract` first calls the base `AbstractPiglin.mobInteract`; if that consumed the action it returns; otherwise on the server `PiglinAi.mobInteract`: when `canAdmire(piglin, stack in the player's hand)`: consume one item from the player's stack (`consumeAndReturn(1, player)`), `holdInOffhand(that item)`, `admireGoldItem`, `stopWalking`; result SUCCESS. Else PASS. (On the client the result is SUCCESS when `canAdmire` and the piglin's arm pose is not already ADMIRING_ITEM.)

### 3.3 Behaviours

| Behaviour | Memories required | Rule |
|---|---|---|
| `StartAdmiringItemIfSeen(119)` (CORE) | `NEAREST_VISIBLE_WANTED_ITEM` present; `ADMIRING_ITEM`, `ADMIRING_DISABLED`, `DISABLE_WALK_TO_ADMIRE_ITEM` absent | If the wanted item entity's stack is a loved item: set `ADMIRING_ITEM` = true with expiry 119. (Otherwise nothing: the item is picked up by the ordinary pick-up path, 3.2.) |
| `StopHoldingItemIfNoLongerAdmiring` (CORE) | `ADMIRING_ITEM` absent | If the off hand is non-empty and the stack does not have the component `blocks_attacks` (so a shield is kept): `stopHoldingOffHandItem(level, piglin, true)` (3.4). |
| `GoToWantedItem(speed 1.0, requireWalkTargetRegistered true, within 9)` (ADMIRE_ITEM) | `WALK_TARGET` registered, `LOOK_TARGET` registered, `NEAREST_VISIBLE_WANTED_ITEM` present, `ITEM_PICKUP_COOLDOWN_TICKS` registered | Predicate is `isNotHoldingLovedItemInOffHand`. Fires when the cooldown memory is empty, the predicate holds, the wanted item is closer than 9 blocks, inside the world border, and the mob `canPickUpLoot`: set `WALK_TARGET` = (tracker of the item entity, speed 1.0, completion distance 0) and `LOOK_TARGET` = (tracker of the item, with eye offset). |
| `StopAdmiringIfItemTooFarAway(9)` (ADMIRE_ITEM) | `ADMIRING_ITEM` present; `NEAREST_VISIBLE_WANTED_ITEM` registered | If the off hand is non-empty: nothing. Otherwise, if a wanted item exists and is closer than 9: nothing; else erase `ADMIRING_ITEM`. |
| `StopAdmiringIfTiredOfTryingToReachItem(200, 200)` (ADMIRE_ITEM) | `ADMIRING_ITEM`, `NEAREST_VISIBLE_WANTED_ITEM` present; `TIME_TRYING_TO_REACH_ADMIRE_ITEM`, `DISABLE_WALK_TO_ADMIRE_ITEM` registered | If the off hand is non-empty: nothing. If the counter is absent: set it to 0. If the counter is greater than 200: erase `ADMIRING_ITEM` and the counter, and set `DISABLE_WALK_TO_ADMIRE_ITEM` = true with expiry 200. Else the counter is replaced by its value plus 1 (read: constant 1, add, store). |

### 3.4 `stopHoldingOffHandItem(level, piglin, barter)` (the end of admiring, also used when hurt and on conversion)

1. Take the off-hand stack and set the off hand to empty.
2. If the piglin is an adult: let `isCurrency` = the stack is barter currency. If `barter` and `isCurrency`: `throwItems(getBarterResponseItems(piglin))`. Else if not `isCurrency`: try `equipItemIfPossible(stack)`; if it was not equipped, `putInInventory(stack)`. (When `isCurrency` and not `barter`, i.e. the piglin was hurt while admiring, nothing is done with the stack and the ingot is lost; read from the branch structure.)
3. If the piglin is a baby: `equipItemIfPossible(stack)`; if not equipped: take the main-hand stack; if it is loved put it in the inventory, else throw it as a single-item list; then hold the stack in the main hand (`holdInMainHand(stack)`), so the baby's main hand takes the off-hand item when it could not be equipped.

`getBarterResponseItems`: roll the loot table `gameplay/piglin_bartering` once with context parameter `this_entity` = the piglin (param set `piglin barter`, [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) 5.5.1 lists the table). `throwItems(list)`: if `NEAREST_VISIBLE_PLAYER` is present, throw toward that player's position, else toward `getRandomNearbyPos`, which is `LandRandomPos.getPos(piglin, 4, 2)` or the piglin's own position when none is found. `throwItemsTowardPos`: if the list is non-empty, swing the off hand (default swing animation) and for each stack call `BehaviorUtils.throwItem(piglin, stack, targetPos + (0, 1, 0))` (1 above the target).

`cancelAdmiring` (called on conversion): if admiring and the off hand is non-empty: spawn the off-hand stack as an item entity and empty the off hand.

`wantsToDance(self, target)` (the `StartCelebratingIfTargetDead` predicate): the target is a hoglin and a fresh thread-local random seeded with the level game time gives `nextFloat() < 0.1`.

## 4. Piglin, piglin brute and hoglin sensors

All three sensors use the no-argument `Sensor` constructor, which passes scan rate 20 (read: `Sensor.<init>()` calls the one-argument constructor with 20; the three classes call that no-argument constructor and declare no other interval). `Sensor.tick` decrements a private countdown by 1 each call; when it is at most 0 it is reset to the scan rate (20) and the sensor runs, so a sensor runs once every 20 brain ticks; `randomlyDelayStart` sets the initial countdown to `nextInt(scanRate)`, spreading first scans over 0 to 19 ticks. (An earlier draft of this document said 18; the artifact says 20.) Results are `Brain.setMemory(type, optional)`; an absent optional clears the memory.

### 4.1 `PiglinSpecificSensor`

Registered memories it writes: `NEAREST_REPELLENT`, `NEAREST_VISIBLE_NEMESIS`, `NEAREST_TARGETABLE_PLAYER_NOT_WEARING_GOLD`, `NEAREST_PLAYER_HOLDING_WANTED_ITEM`, `NEAREST_VISIBLE_HUNTABLE_HOGLIN`, `NEAREST_VISIBLE_BABY_HOGLIN`, `NEAREST_VISIBLE_ADULT_PIGLINS`, `NEARBY_ADULT_PIGLINS`, `VISIBLE_ADULT_PIGLIN_COUNT`, `VISIBLE_ADULT_HOGLIN_COUNT`, `NEAREST_VISIBLE_ZOMBIFIED`.

1. `NEAREST_REPELLENT`: the first block (in `findBlocksInBoxByManhattanDistance(pos, 8, 4)` order: nearest first, 8 horizontal 4 vertical) whose state is in block tag `piglin_repellents` **and** which is not an unlit campfire: the test is "state in tag; if it is also `soul_campfire`, it must be lit". Tag contents: `soul_fire`, `soul_torch`, `soul_lantern`, `soul_wall_torch`, `soul_campfire`. (21 section 5.5.1 omitted the lit test and the wall torch and fire members.)
2. Iterate the visible living entities in the memory's order (nearest first). Per entity, one branch only:
   - Hoglin: a baby fills the baby slot if it is empty. An adult increments the adult-hoglin counter (always) and, if the huntable slot is empty and `canBeHunted()`, fills the huntable slot.
   - Piglin brute: appended to the visible adult list (unconditionally).
   - Piglin: a baby fills the baby-piglin slot if empty (the baby piglin is only tracked locally); an adult is appended to the visible adult list.
   - Player: if the "not wearing gold" slot is empty and the player is not wearing safe armor (`isWearingSafeArmor`: any armor slot item in tag `piglin_safe_armor`, the four golden armor pieces) and `piglin.canAttack(player)`: fill it. Independently, if the holding-wanted-item slot is empty, the player is not a spectator and `isPlayerHoldingLovedItem(player)`: fill it.
   - Otherwise: if the nemesis slot is empty and the entity is a wither skeleton or a Wither: fill it; else if the zombified slot is empty and `isZombified(entity)`: fill it.
3. `NEARBY_ADULT_PIGLINS` = `PiglinAi.findNearbyAdultPiglins(brain)`: the adult `AbstractPiglin` instances (brutes included) in the non-visible `NEAREST_LIVING_ENTITIES` memory (so including piglins behind walls, sorted by distance).
4. `NEAREST_VISIBLE_ADULT_PIGLINS` = the visible adult list; `VISIBLE_ADULT_PIGLIN_COUNT` = its size; `VISIBLE_ADULT_HOGLIN_COUNT` = the adult-hoglin counter.

### 4.2 `PiglinBruteSpecificSensor`

`NEAREST_VISIBLE_NEMESIS` = the closest visible living entity that is a wither skeleton or Wither, filtered to `Mob` instances; `NEARBY_ADULT_PIGLINS` = `findNearbyAdultPiglins`. Nothing else (no repellent, no player memories; a brute finds players through the `NEAREST_PLAYERS` sensor of its brain).

### 4.3 `HoglinSpecificSensor`

- `NEAREST_REPELLENT`: the first block in tag `hoglin_repellents` within the Manhattan box (8, 4), nearest first. Tag contents: `warped_fungus`, `potted_warped_fungus`, `nether_portal`, `respawn_anchor`. There is no lit test.
- Over the visible living entities, only **adult** ones (the filter is "not a baby and (a piglin or a hoglin)"): the first adult piglin fills `NEAREST_VISIBLE_ADULT_PIGLIN` (only if empty); every adult piglin (brutes are not `Piglin`, so not counted) increments the piglin counter; every adult hoglin is appended to a list.
- Writes `NEAREST_VISIBLE_ADULT_PIGLIN`, `NEAREST_VISIBLE_ADULT_HOGLINS` (the list), `VISIBLE_ADULT_PIGLIN_COUNT`, `VISIBLE_ADULT_HOGLIN_COUNT` (the list size).

## 5. Generic behaviours used by these brains

The `OneShot` and `Behavior` conventions are those of [18](18-mob-framework.md) 4.6: a one-shot runs its trigger once when its memory preconditions hold; a `Behavior` has start, tick, stop, `canStillUse`.

### 5.1 `StartAttacking`

Precondition memories: `ATTACK_TARGET` absent, `CANT_REACH_WALK_TARGET_SINCE` registered. Parameters: a start condition `(level, mob) -> bool` (default always true) and a target finder `(level, mob) -> optional living`. Steps: if the condition is false: fail. Ask the finder; if empty: fail. If `mob.canAttack(target)` is false: fail. Otherwise set `ATTACK_TARGET` = target (no expiry) and erase `CANT_REACH_WALK_TARGET_SINCE`; succeed. Users: piglin IDLE and CELEBRATE (adult-only condition, finder 2.2), hoglin IDLE (condition always true, finder 6.2), zoglin IDLE (6.3).

### 5.2 `StopAttackingIfTargetInvalid`

Precondition: `ATTACK_TARGET` present; `CANT_REACH_WALK_TARGET_SINCE` registered. Parameters: a stop condition `(level, target) -> bool` (default always false), a callback when the target is erased (default none), and `canGiveUp` (always true in all users here). Each time it runs it stops the attack (callback, then erase `ATTACK_TARGET`) when **any** of: the mob cannot attack the target (`canAttack`); `canGiveUp` and the mob has been unable to reach its walk target for more than 200 ticks (`gameTime - CANT_REACH_WALK_TARGET_SINCE > 200`); the target is not alive; the target is in a different level; the stop condition is true. It always reports success. Users: piglin FIGHT (condition: the target is no longer the "nearest valid attack target", 2.2), brute FIGHT, hoglin FIGHT and zoglin FIGHT (default condition: never).

### 5.3 `SetWalkTargetAwayFrom`

Two factories: `entity(memory, speed, distance, override)` reads the position of an entity memory, `pos(memory, speed, distance, override)` the position of a block memory (a position memory is the block's position; both use the entity's/pos's `Vec3`). Precondition memories: `WALK_TARGET` registered; the named memory present. Steps when it triggers:

1. If a `WALK_TARGET` already exists and `override` is false: fail.
2. If the mob is not within `distance` blocks of the point to avoid (`position.closerThan(avoid, distance)` false): fail.
3. If a `WALK_TARGET` exists whose speed equals this behaviour's speed and the vector from the mob to that walk target dotted with the vector from the mob to the avoided point is below zero (the existing walk target already leads away): fail (keep it).
4. Up to 10 times: ask `LandRandomPos.getPosAway(mob, 16, 7, avoidedPoint)` (horizontal range 16, vertical range 7, biased away from the point; read: the 4-argument form calls the 5-argument form with minimum distance 0, which takes `mob position - avoided point`, and when that vector has length 0 substitutes a random horizontal direction `(nextDouble - 0.5, 0, nextDouble - 0.5)`, then calls `getPosInDirection` with the mob-restricted flag, which delegates to the generic `RandomPos.generateRandomPos`; the sampling inside that generator was not read, Open question 3); the first non-null position is stored as `WALK_TARGET` (position, speed, completion distance 0) and the loop ends. After the loop, succeed (also when none was found).

Parameters used: piglin AVOID (`AVOID_TARGET`, 1.0, 12, true); hoglin IDLE (`NEAREST_REPELLENT` as a position, 1.0, 8, true) and (`NEAREST_VISIBLE_ADULT_PIGLIN` as an entity, 0.4, 8, false); hoglin AVOID (`AVOID_TARGET`, 1.3, 15, false). The operand identity in step 3 (which vector is dotted with which) was read from the instruction order and is marked inferred (Open question 3).

### 5.4 `GoToWantedItem`

See the table in 3.3 (it is the only user in this round; the others are the allay and villagers' item pick-up in other documents). Closes 18 Open question 19 for `GoToWantedItem`.

### 5.5 `ChargeAttack` (generic engine; the nautilus parameters are part 7)

`Behavior<Animal>` with preconditions `CHARGE_COOLDOWN_TICKS` absent and `ATTACK_TARGET` present. Constructor parameters: `timeBetweenAttacks` (ticks), targeting conditions, `speed`, `knockbackForce`, `maxTargetDetectionDistance`, `maxChargeDistance`, `chargeSound`.

- Extra start condition: `ATTACK_TARGET` has a value.
- `canStillUse` is false when: the target memory is empty; the mob is a tamed `TamableAnimal`; the squared distance from the charge start position is at least `maxChargeDistance` squared; the squared distance from the mob to the target is at least `maxTargetDetectionDistance` squared; the mob has no line of sight to the target; or `CHARGE_COOLDOWN_TICKS` has a value.
- `start`: remember the start position; `chargeVelocityVector = normalize(target position - mob position) * speed`; if `canStillUse` still holds, play `chargeSound`.
- `tick`: look at the target (360, 360); set the mob's velocity to `chargeVelocityVector` every tick; collect the first living entity overlapping the mob's bounding box that passes the targeting conditions; if one exists (and is not a passenger of the mob): deal damage and knockback, then stop.
- Damage: `mobAttack` damage source from the mob, amount = the mob's `ATTACK_DAMAGE` attribute; if the hurt succeeds, post-attack enchantment effects run.
- Knockback: `speedAmp` = Speed amplifier + 1 (0 without), `slowAmp` = Slowness amplifier + 1 (0 without); `modifier = 0.25 * (speedAmp - slowAmp)`; strength = `clamp(speed * mobMovementSpeedAttribute, 0.2, 2.0) + modifier`; call `causeExtraKnockback(target, strength * knockbackForce, mobVelocity, damageSource, attackDamage, false)` (the internals of that call were not expanded).
- `stop`: set `CHARGE_COOLDOWN_TICKS` = `timeBetweenAttacks` and erase `ATTACK_TARGET`.

### 5.6 `RamTarget` and `PrepareRamNearestTarget` (goat brain, `Goat`)

Both are bound to the goat. Constants read: `RamTarget`: time-out 200 ticks, `RAM_SPEED_FORCE_FACTOR` 1.65; `PrepareRamNearestTarget`: time-out 160 ticks.

- `PrepareRamNearestTarget`: runs with `RAM_COOLDOWN_TICKS` absent, `NEAREST_VISIBLE_LIVING_ENTITIES` present, `RAM_TARGET` absent, `LOOK_TARGET` registered. It picks a candidate from the visible entities (targeting conditions, a start position found by `calculateRammingStartPosition`: walk each horizontal direction outward over walkable blocks, collecting positions that are the required distance away; the arithmetic of the distance window and the choice among candidates was not expanded: Open question 4). While running it sets `WALK_TARGET` to the candidate's start position (the configured walk speed) and `LOOK_TARGET` to the target entity. When the target moved to a different block it broadcasts entity event 59 (stop) and re-chooses; when the goat stands on the start position it broadcasts entity event 58 (start charging animation), records the arrival time, and after `ramPrepareTime` ticks sets `RAM_TARGET` = the edge of the target's block facing the goat (`getEdgeOfBlock`: bottom centre of the target block plus `(0.5 * sign(dx), 0, 0.5 * sign(dz))` with dx and dz the goat's block minus the target's block, per axis) and plays the prepare sound. On stop, if no `RAM_TARGET` was set it broadcasts event 59 and sets `RAM_COOLDOWN_TICKS` from the configured range.
- `RamTarget`: runs with `RAM_COOLDOWN_TICKS` absent and `RAM_TARGET` present; `start` sets `WALK_TARGET` toward the ram target position (the horizontal direction normalised, speed from the configuration). Each tick it collects living entities overlapping the goat's bounding box (targeting conditions). If one is hit: hurt it with the no-aggro mob attack damage source for the goat's `ATTACK_DAMAGE`, run post-attack effects, then knockback using `strength = clamp(goatSpeed * 1.65, 0.2, 3.0) + 0.25 * (speedAmp - slowAmp)`, scaled by 0.5 when the target blocked the hit with a shield (`applyItemBlocking` returned above zero) else by 1, and finish the ram. If nothing was hit: when the block in front of the goat (position + horizontal velocity normalised) or the block above it is in block tag `snaps_goat_horn`, play the horn-break sound, drop a horn (`dropHorn`) with its sound, and finish; or finish when the walk target is reached (closer than 0.25) or absent. `finishRam`: broadcast event 59, set `RAM_COOLDOWN_TICKS` from the configured range, erase `RAM_TARGET`.
- Goat configuration read in `GoatAi`: ram prepare time 20 ticks, ram minimum distance 4 and maximum distance 7 blocks, walk speed while preparing to ram 1.25, speed while ramming 3.0 (the `RamTarget` speed factor argument), knockback force 2.5 for an adult and 1.0 for a baby, ram target conditions held in a static field. The static initialiser of `GoatAi` (read) builds these `UniformInt` values: `TIME_BETWEEN_RAMS` 600 to 6000 ticks and `TIME_BETWEEN_RAMS_SCREAMER` 100 to 300 ticks (the ram cooldown supplier returns the screamer range when the goat `isScreamingGoat`, else the normal range; both ram behaviours draw `RAM_COOLDOWN_TICKS` from it; the minimum of the same range is also read where the ram activity is built, use of that minimum not traced); `TIME_BETWEEN_LONG_JUMPS` 600 to 1200 ticks (the long-jump cooldown); `ADULT_FOLLOW_RANGE` 5 to 16 (the baby-follow range). `RAM_TARGET_CONDITIONS` is `TargetingConditions.forCombat()` plus a selector that accepts a target when it is not a goat, and (the `mob_griefing` game rule is true or the target is not an armor stand), and the target's bounding box is within the world border. Impact sound: screaming goat `GOAT_SCREAMING_RAM_IMPACT`, else `GOAT_RAM_IMPACT`. Only the candidate selection of `PrepareRamNearestTarget` remains unread (Open question 4).

### 5.7 Further generic behaviours read

| Behaviour | Rule (read; items marked inferred are from operand order) |
|---|---|
| `BecomePassiveIfMemoryPresent(memory, ticks)` | Memory preconditions: `ATTACK_TARGET` registered (inferred), `PACIFIED` absent, the named memory present. When it triggers: `PACIFIED` = true with expiry `ticks`, and `ATTACK_TARGET` erased; always succeeds. |
| `SetEntityLookTargetSometimes(range, uniform interval[, entity type])` | Preconditions: `LOOK_TARGET` absent, `NEAREST_VISIBLE_LIVING_ENTITIES` present. Find the closest visible entity that passes the optional type filter and is within `range` (squared distance compared to the range; precisely `<=` on the squared value as inferred from the comparison direction). If none: fail. Otherwise tick down the behaviour's private countdown (a `Ticker` that is reset by sampling the interval from the level random source whenever it reaches its limit); only when it fires set `LOOK_TARGET` = tracker of that entity (with eye height) and succeed. The countdown therefore only runs down while a candidate exists. |
| `BabyFollowAdult(UniformInt range, speed[, tracker option])` | Preconditions: the adult memory (`NEAREST_VISIBLE_ADULT`) present, `LOOK_TARGET` registered, `WALK_TARGET` absent (inferred from the order of the three conditions). The mob must be a baby. Triggers when the adult is closer than `range.max + 1` blocks and not closer than `range.min`: `LOOK_TARGET` = tracker of the adult; `WALK_TARGET` = (tracker of the adult, speed, completion distance `range.min`). (Hoglin: range 5 to 16, 0.6.) |
| `BackUpIfTooClose(distance, speed)` | Preconditions: `WALK_TARGET` absent, `LOOK_TARGET` registered, `ATTACK_TARGET` present, `NEAREST_VISIBLE_LIVING_ENTITIES` present. Triggers when the mob is closer than `distance` to the target and the target is in the visible list: `LOOK_TARGET` = tracker of the target; the move control strafes with forward value `-speed` (sign inferred) and sideways 0; yaw is rotated toward the head yaw by the standard `rotateIfNecessary` with maximum 0. Succeeds. (Piglin: 5 blocks, 0.75.) |
| `StartCelebratingIfTargetDead(ticks, predicate)` | Preconditions: `ATTACK_TARGET` present, `ANGRY_AT` registered, `CELEBRATE_LOCATION` absent, `DANCING` registered. Fails unless the target `isDeadOrDying`. When the predicate (piglin: `wantsToDance`, 3.4) is true: `DANCING` = true with expiry `ticks` and `CELEBRATE_LOCATION` = the target's block position with expiry `ticks`. Then, independent of the predicate (from the branch offsets, inferred): if the target is a player and the game rule `forgive_dead_players` is true, `ANGRY_AT` is erased; `ATTACK_TARGET` is erased. Succeeds. (Piglin: 300 ticks.) |
| `GoToTargetLocation(memory, closeEnough, speed)` | Preconditions: `ATTACK_TARGET` absent, `WALK_TARGET` absent, `LOOK_TARGET` registered, the location memory present. When the mob is not within `closeEnough` blocks of the stored block: pick a nearby block = the location offset by `(r1, 0, r2)` with each `r` = `nextInt(3) - 1` (the minus 1 inferred), and set `WALK_TARGET` and `LOOK_TARGET` toward it via `BehaviorUtils.setWalkAndLookTargetMemories` (speed; the completion distance argument was not traced, taken as `closeEnough`, inferred). Succeeds when it acted. |
| `Mount(speed)` | Preconditions: `LOOK_TARGET` and `WALK_TARGET` absent, `RIDE_TARGET` present (inferred from order). Fails when the mob is already a passenger. When the mob is closer than 1 block to the ride target: `startRiding`. Otherwise `LOOK_TARGET` = tracker of the target and `WALK_TARGET` = (tracker, speed, completion distance 1). |
| `DismountOrSkipMounting(maxDistance, predicate)` | `RIDE_TARGET` registered. Takes the current vehicle and the `RIDE_TARGET` entity; fails when neither exists. A vehicle is valid when alive, within `maxDistance` and in the same level. When the vehicle is invalid, or the predicate holds for (mob, vehicle): `stopRiding` and erase `RIDE_TARGET`; succeed. (Piglin: 8 blocks; the predicate is the baby-on-baby/hoglin test of 2.10, the exact wiring not traced.) |
| `AnimalMakeLove(type, speed, distance)`, `CrossbowAttack` | Not read: Open question 5. |

## 6. Hoglin and zoglin brains

### 6.1 Constants (`HoglinAi`)

| Constant | Value |
|---|---|
| `REPELLENT_DETECTION_RANGE_HORIZONTAL` / `VERTICAL` | 8 / 4 |
| `RETREAT_DURATION` | uniform 5 to 20 seconds (100 to 400 ticks) |
| `ATTACK_DURATION` (expiry of `ATTACK_TARGET`) | 200 ticks |
| `DESIRED_DISTANCE_FROM_PIGLIN_WHEN_IDLING` | 8 |
| `DESIRED_DISTANCE_FROM_PIGLIN_WHEN_RETREATING` | 15 |
| `ATTACK_INTERVAL` / `BABY_ATTACK_INTERVAL` | 40 / 15 ticks |
| `REPELLENT_PACIFY_TIME` | 200 ticks |
| `ADULT_FOLLOW_RANGE` | uniform 5 to 16 (integers) |
| speeds | avoiding repellent 1.0; retreating 1.3; making love 0.6; idling 0.4; following adult 0.6 |

### 6.2 Hoglin brain

Sensors: `NEAREST_LIVING_ENTITIES`, `NEAREST_PLAYERS`, `NEAREST_ADULT`, `HOGLIN_SPECIFIC_SENSOR` (4.3). Activity order: FIGHT, AVOID, IDLE (CORE always). The class builds the activities with `initCoreActivity`, `initIdleActivity`, `initFightActivity` and `initRetreatActivity`; the last one is the third activity and is bound to `Activity.AVOID` gated by `AVOID_TARGET` (the name "retreat" is the method's only; the activity is AVOID, as in 21). CORE: `LookAtTargetSink(45, 90)`, `MoveToTargetSink`.

| Activity (priority base 10) | Behaviours in order |
|---|---|
| IDLE | `BecomePassiveIfMemoryPresent(NEAREST_REPELLENT, 200)`; `AnimalMakeLove(HOGLIN, 0.6, 2)`; `SetWalkTargetAwayFrom.pos(NEAREST_REPELLENT, 1.0, 8, true)`; `StartAttacking(finder)`; adults only: `SetWalkTargetAwayFrom.entity(NEAREST_VISIBLE_ADULT_PIGLIN, 0.4, 8, false)`; `SetEntityLookTargetSometimes(8, uniform 30 to 60)`; `BabyFollowAdult(5..16, 0.6)`; idle movement (`RunOne`: stroll 0.4 weight 2, `SetWalkTargetFromLookTarget(0.4, 3)` weight 2, `DoNothing(30..60)` weight 1) |
| FIGHT (gated by `ATTACK_TARGET`) | `BecomePassiveIfMemoryPresent(NEAREST_REPELLENT, 200)`; `AnimalMakeLove(HOGLIN, 0.6, 2)`; `SetWalkTargetFromAttackTargetIfTargetOutOfReach(1.0)`; adults: `MeleeAttack(40)`; babies: `MeleeAttack(15)`; `StopAttackingIfTargetInvalid()` (defaults); erase `ATTACK_TARGET` if the hoglin is breeding (`BREED_TARGET` present) |
| AVOID (gated by `AVOID_TARGET`) | `SetWalkTargetAwayFrom.entity(AVOID_TARGET, 1.3, 15, false)`; idle movement; `SetEntityLookTargetSometimes(8, 30..60)`; erase `AVOID_TARGET` when `wantsToStopFleeing` (adult and not piglins-outnumber) |

Hoglin attributes (read, `Hoglin.createAttributes`, on top of `Monster.createMonsterAttributes`): max health 40.0, movement speed 0.30000001192092896, knockback resistance 0.6000000238418579, attack knockback 1.0, attack damage 6.0 for an adult; `BABY_ATTACK_DAMAGE` is 0.5 (as for the zoglin, 6.3). Dimensions 1.3964844 x 1.4 adult (the width is the `EntityTypes` constant `MAGIC_HORSE_WIDTH`, 1.3964844f, passed to the `HOGLIN` and `ZOGLIN` registrations; it is not a `Hoglin` or `Zoglin` constant, and the same constant sizes other entity types).

`BecomePassiveIfMemoryPresent(memory, 200)`: when the memory has a value, set `PACIFIED` = true with expiry 200 and erase `ATTACK_TARGET` (body in 5.7).

Target finder (IDLE `StartAttacking`): if the hoglin is pacified (`PACIFIED` present) or breeding (`BREED_TARGET` present): none; else `NEAREST_VISIBLE_ATTACKABLE_PLAYER`. A hoglin therefore attacks only players on its own initiative, never piglins or other mobs.

`updateActivity` each AI step: first valid of FIGHT, AVOID, IDLE; if the active activity changed, play its sound (AVOID, or converting: retreat sound; FIGHT: angry; near a repellent: retreat; else ambient); set the aggressive flag from `ATTACK_TARGET`.

`piglinsOutnumberHoglins(hoglin)` (hoglin's own count): false for a baby; else `VISIBLE_ADULT_PIGLIN_COUNT > VISIBLE_ADULT_HOGLIN_COUNT + 1`.

Hurt: `Hoglin.hurtServer` calls `HoglinAi.wasHurtBy(attacker)` after a successful hurt with a living causing entity: erase `PACIFIED` and `BREED_TARGET`; a baby retreats (`retreatFromNearestTarget`: nearer of (`AVOID_TARGET`, attacker), then nearer of (`ATTACK_TARGET`, that); `setAvoidTarget` of it: erase `ATTACK_TARGET`, `WALK_TARGET`, set `AVOID_TARGET` = it with a `RETREAT_DURATION` sample); an adult runs `maybeRetaliate`:
1. Return if the AVOID activity is active and the attacker is a piglin.
2. Return if the attacker is a hoglin.
3. Return if `isOtherTargetMuchFurtherAwayThanCurrentAttackTarget(hoglin, attacker, 4.0)`.
4. Return if the attacker is not attackable (`isEntityAttackable`, with line of sight).
5. `setAttackTarget(attacker)` (erase `CANT_REACH_WALK_TARGET_SINCE` and `BREED_TARGET`; set `ATTACK_TARGET` with expiry 200) and `broadcastAttackTarget`: every visible adult hoglin (`NEAREST_VISIBLE_ADULT_HOGLINS`) takes the target unless pacified, if it is the nearer than its current one (`setAttackTargetIfCloserThanCurrent`).

`onHitTarget` (after a successful melee hit, read): a baby hoglin returns with no effect. Otherwise, when the target is a piglin (entity type test, not a brute) and `piglinsOutnumberHoglins(hoglin)` (the hoglin's own formula above: piglin count > hoglin count + 1, false for babies): `setAvoidTarget(target)` and `broadcastRetreat` (every visible adult hoglin `retreatFromNearestTarget`); else `broadcastAttackTarget(target)`.

Other hoglin facts read: `checkHoglinSpawnRules` is true when the block below is not a nether wart block; `finalizeSpawn` makes a baby with probability 0.2 (`nextFloat() < 0.2`); `removeWhenFarAway` always true; `getWalkTargetValue(pos)`: -1 if `pos` is within 8 blocks of the nearest repellent, 10 if the block below is `crimson_nylium`, else 0; `canFallInLove` requires not pacified plus the animal rule; food tag `hoglin_food` = `crimson_fungus`; `mobInteract` that consumes the action marks the hoglin persistent; persisted flags `CannotBeHunted` (read by `canBeHunted`) and `IsImmuneToZombification`; the offspring is a hoglin created with reason BREEDING and set persistent.

### 6.3 Zoglin brain

Sensors: `NEAREST_LIVING_ENTITIES`, `NEAREST_PLAYERS`. Activities FIGHT then IDLE; CORE `LookAtTargetSink(45, 90)`, `MoveToTargetSink`.

| Activity | Behaviours |
|---|---|
| IDLE (priority 10) | `StartAttacking(finder)`; `SetEntityLookTargetSometimes(8, 30..60)`; idle movement as for the hoglin (stroll 0.4 weight 2, `SetWalkTargetFromLookTarget(0.4, 3)` weight 2, `DoNothing(30..60)` weight 1) |
| FIGHT (gated by `ATTACK_TARGET`) | `SetWalkTargetFromAttackTargetIfTargetOutOfReach(1.0)`; adults `MeleeAttack(40)`; babies `MeleeAttack(15)`; `StopAttackingIfTargetInvalid()` |

Target finder: the closest visible living entity that is not a zoglin, not a creeper and is attackable (`isEntityAttackable`). A zoglin therefore attacks every other creature that can be attacked: players, piglins, hoglins, villagers and so on, which is the "attacks anything" behaviour of 21 section 5.6.

Hurt (`Zoglin.hurtServer`): after a successful hurt with a living causing entity that the zoglin `canAttack` and that is not "much further" (4.0, 2.4 formula) than the current target: `setAttackTarget` (erase `CANT_REACH_WALK_TARGET_SINCE`, set `ATTACK_TARGET` with expiry 200). `updateActivity`: first valid of FIGHT, IDLE; when it changes from not-FIGHT to FIGHT play the angry sound; aggressive flag from `ATTACK_TARGET`. `finalizeSpawn`: baby with probability 0.2. Attributes (read): max health 40, movement speed 0.30000001192092896, knockback resistance 0.6000000238418579, attack knockback 1 (the class constant `ATTACK_KNOCKBACK` is 1), attack damage 6 for an adult; both `Hoglin` and `Zoglin` declare `BABY_ATTACK_DAMAGE` = 0.5, and `Zoglin.setBaby` (server side) sets the `ATTACK_DAMAGE` base value to 0.5 when the zoglin becomes a baby. The `MOVEMENT_SPEED_WHEN_FIGHTING` field is 0.3 (float), matching the attribute value. The zoglin step sound plays with volume 0.15 and pitch 1.0 (as read). Dimensions 1.3964844 x 1.4 (adult; width from the `EntityTypes` constant `MAGIC_HORSE_WIDTH`, see 6.2), baby 0.75 x 0.85 with eye height 0.625 and passenger attachment (0, 0.875, 0).

### 6.4 Melee damage and throw (`HoglinBase.hurtAndThrowTarget`)

Reconfirmed from 21 section 5.6 without change; Zoglin uses the same method (entity event 4, `ZOGLIN_ATTACK` sound).

## 7. Zombification

`AbstractPiglin.isConverting` and `Hoglin.isConverting` are identical: the immunity flag is false, the mob has AI, and the environment attribute `gameplay/piglins_zombify` is true at the mob's position (boolean attribute; default true; syncable). Values read in `data/minecraft/dimension_type`: `the_nether` sets it to false; `overworld`, `overworld_caves` and `the_end` set no value, so they use the default true; no biome file overrides it. Therefore piglins, piglin brutes and hoglins convert in the Overworld and the End and never in the Nether (answers 21 Open question 4, third item).

`customServerAiStep` (piglin family): `timeInOverworld` is incremented by 1 per server AI step while converting, reset to 0 otherwise; when it exceeds 300 the converted sound plays unless the difficulty is Peaceful (only the sound is gated by difficulty), and `finishConversion` runs whatever the difficulty (read: the conversion call is not under the difficulty test). The piglin first `cancelAdmiring` and drops its whole inventory as items, then converts to `zombified_piglin` with `ConversionParams.single(self, true, true)` and then Nausea 200 ticks amplifier 0. `ConversionParams` has the fields `keepEquipment` and `preserveCanPickUpLoot`, and `single(mob, a, b)` passes `a` and `b` in that order into the constructor (read), so the piglin conversion keeps equipment and preserves can-pick-up-loot. Hoglin: the same counter; at > 300, inside the converting branch, the `hoglin_converted_to_zombified` sound plays and `finishConversion` makes a `zoglin` with `single(self, true, false)` (keep equipment, do not preserve can-pick-up-loot) and Nausea 200 ticks.

## 8. Strider

Reads for 21 Open question 11; the rest of section 5.7 stands except the corrections in section 12.

### 8.1 Riding and steering

- Control: `getControllingPassenger` returns the first passenger only when the strider is saddled and that passenger is a player currently holding (main or off hand, `isHolding`) a `warped_fungus_on_a_stick`; otherwise the default (no controlling rider: the strider walks on its own while a non-holding rider sits on it).
- Saddle: `canUseSlot(SADDLE)` is true when the strider is alive and not a baby.
- While controlled (`tickRidden`): the strider's yaw = the rider's yaw; pitch = rider pitch x 0.5; head and body yaw copy the new yaw; then `ItemBasedSteering.tickBoost`. `getRiddenInput` = (0, 0, 1) (always straight ahead; strafing and backward input are ignored). `getRiddenSpeed` = `MOVEMENT_SPEED attribute value * (suffocating ? 0.35 : 0.55) * boostFactor` (float32 product).
- `ItemBasedSteering` (also used by the pig, [19](19-mobs-land-friendly-and-neutral.md)): `boost(random)`: false when already boosting; else `boosting = true`, `boostTime = 0`, and the synchronised total (metadata 18) = `140 + nextInt(841)` ticks (140 to 980 inclusive; the class constants `MIN_BOOST_TIME` 140 and `MAX_BOOST_TIME` 700 are declared but the 841 range is what the code draws). `tickBoost`: while boosting, `boostTime += 1` and boosting ends when `boostTime > total`. `boostFactor` = `1.0 + 1.15 * sin(boostTime / total * PI)` while boosting, else 1.0. Receiving a changed total from the server (`onSyncedDataUpdated` for the boost data, client only) sets `boosting = true`, `boostTime = 0` on the client.
- Item: `warped_fungus_on_a_stick` has durability 100 and `consumeItemDamage` 1 for the strider. `use` (server): if the player's controlled vehicle is a strider and `strider.boost()` succeeds: the stack takes 1 damage and, when it breaks, becomes a `fishing_rod` (`hurtAndConvertOnBreak(1, fishing_rod, ...)`), result SUCCESS_SERVER with the transformed held item; otherwise award the item-used statistic and PASS.
- `canAddPassenger`: no passenger yet and the strider's eyes are not in lava.
- Tags read: item tag `strider_food` = [`warped_fungus`]; item tag `strider_tempt_items` = [`#strider_food`, `warped_fungus_on_a_stick`] (the tempt goal, speed 1.4, tests the tempt tag; breeding food tests the food tag). This agrees with 21 section 5.7.

### 8.2 Lava behaviour

- `floatStrider` each tick: only when in lava. With the liquid collision shape (a column 16 wide, from y 0 to 8, i.e. the lower half of the block) at the strider's block: if the strider is **not** above that shape, or the block above its block holds lava: velocity = `0.5 * velocity + (0, 0.05, 0)` (it rises). Otherwise (above the shape and no lava over it): `onGround` is set true (it stands on the surface). (`CollisionContext.isAbove(shape, pos, true)`; its numeric epsilon was not expanded.)
- Falling: `checkFallDamage` resets the fall distance while in lava. `isOnFire` is always false. `isSensitiveToWater` is true. `getWalkTargetValue(pos)`: 10 when the block at `pos` has lava as its fluid; else negative infinity when the strider is itself in lava; else 0 (correction of 21 section 5.7).
- Spawn rule `checkStriderSpawnRules`: starting at the candidate position, move up one block at a time while the fluid at the new position is lava (the first move up is always made); the rule is true when the first non-lava position is air. Spawn obstruction check: the strider's box is unobstructed.
- Suffocation each tick (not NoAI): `warm` = the block at the strider's position or the block it stands on (`getBlockStateOnLegacy`) is in block tag `strider_warm_blocks` (contents: `lava`), or the lava fluid height at the strider is greater than 0; `ridingWarm` = the vehicle is a strider that is not suffocating; `suffocating = !warm && !ridingWarm`.
- `shouldPassengersInheritMalus` true: a rider's path malus is the strider's.
- Sounds: step sound lava variant when in lava; `STRIDER_HAPPY` with probability 1/140 per tick while tempting; `STRIDER_RETREAT` with probability 1/60 per tick while panicking.

### 8.3 `StriderGoToLavaGoal` (priority 4, speed 1.0)

A `MoveToBlockGoal(strider, 1.0, searchRange 8, verticalSearchRange 2)`.
- `canUse`: the strider is not in lava and the base `MoveToBlockGoal.canUse` holds (its search: a timed scan of blocks inside the 8 by 2 range for a block satisfying `isValidTarget`, per [18](18-mob-framework.md) goal framework, which also owns the cooldown rules; here only the predicate is specified).
- `canContinueToUse`: the strider is not in lava and the stored target is still valid.
- `isValidTarget(level, pos)`: the block at `pos` is `lava` (the block, not just a lava fluid state) and the block above is path-computable for LAND (`isPathfindable(LAND)`, i.e. passable for a land walker: an air-like cell).
- `shouldRecalculatePath`: true every 20 ticks of the goal's try counter.
- `getMoveToTarget`: the stored block position.

### 8.4 `StriderPathNavigation`

A `GroundPathNavigation` with a plain `WalkNodeEvaluator` (the stock ground evaluator; the lava-walking comes from the path malus table of the strider: water -1, lava 0, fire and fire-neighbour 0, 21 section 5.7) and one override: `isStableDestination(pos)` is true when the block at `pos` is lava, or the ground rule says it is stable. So a lava surface is a valid stand-still destination.

## 9. Blaze, ghast, magma cube, wither skeleton: details

### 9.1 Ghast

- Attributes (read, `Ghast.createAttributes`, on top of the generic mob attributes): max health 10.0, follow range 100.0, camera distance 8.0, flying speed 0.06. `getSoundVolume` (ambient and other sounds) is 5.0 (float). The flying speed 0.06 is the `FLYING_SPEED` attribute value used in the move-control gain below, so the per-gain factor is 0.06 * 5 / 3 = 0.1. Document 21 section 5.1 does not state these values (searched for the ghast attribute rows; none found), so they are given here.
- Constructor: `explosionPower` 1, `xpReward` 5, move control `GhastMoveControl(careful = false, shouldBeStopped = always false)`. Persisted `ExplosionPower` (byte, default 1). `getMaxSpawnClusterSize` 1. `checkGhastSpawnRules`: in this order, difficulty is not Peaceful, then `nextInt(20) == 0`, then the mob spawn rules (`checkMobSpawnRules`, 18 spawning) hold. Travel: `travelFlying(input, 0.02)`. Not climbable; fall damage ignored. Charging flag (metadata 16) default false.
- `isInvulnerableTo` and `hurtServer`: a "reflected fireball" is a damage source whose direct entity is a `LargeFireball` and whose causing entity is a player; for it the ghast takes damage 1000 and is never invulnerable to it (other sources: normal rules).
- `GhastMoveControl.tick` (mode MOVE_TO only): first, if the stop supplier is true (never) clear the operation and stop. While the operation is MOVE_TO: `floatDuration -= 1`; when it is at most 0: `floatDuration += nextInt(5) + 2`; compute delta = wanted position - mob position; if `canReach(delta)`: velocity += `normalize(velocity) * (FLYING_SPEED attribute * 5 / 3)` (read: the normalised **current velocity**, not the delta, scaled by `FLYING_SPEED * 5.0 / 3.0` and added to the current velocity), else the operation becomes WAIT.
- `canReach(delta)`: let `moved` = the mob's bounding box moved by delta, `from` = the mob position and `to` = position + delta. With `careful` false (the ghast): sweep the blocks intersected between `from` and `to` along the box (`forEachBlockIntersectedBetween`); a block whose cell the `moved` box intersects is skipped (counts as passable); every other block must pass `blockTraversalPossible(from, to, pos)`. That test, with `careful` false, is collision only: **air is traversable**; for any other block, since both vectors are supplied, it is traversable when the mob's `collidedWithShapeMovingFrom(from, to, block collision shape boxes moved to the block)` is **false**. `collidedWithShapeMovingFrom` is the mob's bounding box rebuilt at `from`, then `AABB.collidedAlongVector(to - from, shapes)`; the result is the negation. **Fluids are ignored by the ghast**: a water or lava block with an empty collision shape is traversable. The `careful` branch is used only by the happy ghast (21 section 8.11): before the sweep it tests every block of `moved` inflated by 1.0 with no vectors (so the collision test is "collision shape empty" and any water or lava fluid cell counts as blocked, because both fluid flags are passed as false), and in both tests a block in tag `happy_ghast_avoids` is not traversable; a non-empty fluid cell (in the sweep, only when `collidedWithFluid` along the movement holds; `Entity.collidedWithFluid` uses the fluid's AABB with the same moving-from test) is traversable for water only when the mob `isInWater` and for lava only when the mob `isInLava`; any other block falls back to the collision result.
- `RandomFloatAroundGoal` (priority 5): `canUse` when the move control has no wanted position, or the squared distance to the wanted point is below 1.0 or above 3600.0; `canContinueToUse` false; `start`: `getSuitableFlyToPosition(mob, 0)` then `setWantedPosition(x, y, z, speed 1.0)`. `getSuitableFlyToPosition(mob, distanceToBlocks)`: up to 64 attempts: random point = mob position plus, per axis, `(nextFloat * 2 - 1) * 16` (so a cube of half-side 16; with a home set, points outside the home are rejected); the point is good when `distanceToBlocks <= 0` (any point), or otherwise when the target position itself is air and, in at least one of the 6 directions, some block at offset i = 1 up to `distanceToBlocks` minus 1 (the loop bound is exclusive) is non-air. `MAX_ATTEMPTS` is 64. If no attempt succeeds: one unrestricted random point of the same cube (each axis `(nextFloat * 2 - 1) * 16`). The chosen point is then clamped (read): when the `MOTION_BLOCKING` height at the point's column is below the point's block Y and above the level's minimum Y, the new point is (x, `mobY - |mobY - pointY|`, z) with x and z unchanged, so the ghast does not float over open void.
- `GhastLookGoal` (priority 7, flag LOOK, always usable, ticks every tick): `faceMovementDirection`: with no target, yaw = `-atan2(vx, vz) * 57.295776` (float constant 57.295776) from the velocity and body yaw = yaw; with a target within 64 blocks (squared distance < 4096): yaw = `-atan2(dx, dz) * 57.295776` toward the target, body yaw copies it; a target beyond 64 blocks leaves the yaw unchanged.
- Target selector: `NearestAttackableTargetGoal(Player, 10, mustSee true, mustReach false)` with the filter "`|player.y - ghast.y| <= 4`".

### 9.2 Blaze

- Attributes (read, `Blaze.createAttributes`, on top of `Monster.createMonsterAttributes`): attack damage 6.0, movement speed 0.23000000417232513, follow range 48.0. Goals (read, `Blaze.registerGoals`; priority, goal, parameters): 4 `BlazeAttackGoal`; 5 `MoveTowardsRestrictionGoal` (speed 1.0); 7 `WaterAvoidingRandomStrollGoal` (speed 1.0); 8 `LookAtPlayerGoal` (Player, distance 8.0); 8 `RandomLookAroundGoal`. Target selector: 1 `HurtByTargetGoal` (no ignored classes); 2 `NearestAttackableTargetGoal` (Player, must see true). The only float 8.0 in the goal list is the `LookAtPlayerGoal` distance. The attack goal's own constants stay as in 21 section 5.2.
- Charged flag is bit 0 of metadata 16 (read: `flags & 1`); `isOnFire()` returns the charged flag (so a charging blaze counts as burning for rendering and the fire rules); `isSensitiveToWater` true; `getLightLevelDependentMagicValue` 1.0 (always fully lit for the brightness-dependent effects).
- `aiStep` (every tick): when airborne and the vertical velocity is negative, vertical velocity x 0.6. Client only: with probability 1/24 per tick, and not silent, play `BLAZE_BURN` locally at (x+0.5, y+0.5, z+0.5), volume `1.0 + nextFloat`, pitch `nextFloat * 0.7 + 0.3`; and 2 `large_smoke` particles per tick at random positions inside the box (`getRandomX(0.5)`, `getRandomY`, `getRandomZ(0.5)`) with zero velocity.
- `customServerAiStep`: `nextHeightOffsetChangeTick` is decremented; at or below 0 it becomes 100 and `allowedHeightOffset = triangle(0.5, 6.891)` (`nextFloat - nextFloat` form scaled: a random-source triangle distribution with mean 0.5 and half-width 6.891, as in 21 section 5.2); then, if the target's eye Y is above `eyeY + allowedHeightOffset` and the blaze can attack it: velocity += `(0, (0.30000001192092896 - velocity.y) * 0.30000001192092896, 0)` and a velocity sync is requested. The counter starts at its default field value (0), so the first server tick picks an offset.
- The attack goal and small fireball are as in 21 section 5.2 (unchanged).

### 9.3 Magma cube and the cube-mob goals

- `CubeMobMoveControl`: stores a wanted yaw (initial = the mob's yaw) and an `isAggressive` flag; `setDirection(yaw, aggressive)`; `setWantedMovement(speed)` sets the MOVE_TO operation. Tick: yaw rotates toward the wanted yaw by at most 90 degrees; head and body yaw copy it; when the operation is not MOVE_TO the forward input is 0. On the ground: set the mob speed to `speedModifier * MOVEMENT_SPEED attribute`; decrement `jumpDelay`; when it reaches 0: `jumpDelay = getJumpDelay()`, divided by 3 (integer) when `isAggressive`; make the jump (`JumpControl.jump`) and play the jump sound if `doPlayJumpSound`. While airborne the speed is kept. When not on the ground nothing else changes (the operation resets to WAIT after the on-ground tick; the forward input is zeroed with it).
- `CubeMobRandomDirectionGoal` (flag LOOK): usable when there is no target and the mob is on the ground, in liquid or levitating, and its move control is a cube-mob control. Every `adjustedTickDelay(40 + nextInt(60))` ticks it picks a new wanted yaw `nextInt(360)` degrees and calls `setDirection(yaw, false)`.
- `CubeMobKeepOnJumpingGoal` (flags JUMP and MOVE): usable while not a passenger; each tick `setWantedMovement(1.0)`.
- `CubeMobFloatGoal` (flags JUMP and MOVE, every tick): usable in liquid with a cube-mob move control (it also sets the navigation to float in its constructor); each tick, with probability 0.8 per tick, `JumpControl.jump`; and `setWantedMovement(1.2)`.
- `CubeMobAttackGoal` (flag LOOK, every tick): usable with a target that the mob can attack and a cube-mob move control; `start` sets the give-up timer to `reducedTickDelay(300)`; continues while the target is valid and the timer (decremented each check) is above 0; each tick it looks at the target (10, 10) and calls `setDirection(yaw, canDealDamage())` (so the jump delay is divided by 3 when the mob can deal damage: whenever the AI is effective for a magma cube).
- Magma cube specifics from 21 section 5.3 stand; the jump delay, jump velocity bonus and splitting formulas are read there.

### 9.4 Wither skeleton

- Lava path malus 8. Preferred weapon type: none (`getPreferredWeaponType` returns null). `canHoldItem(stack)`: the stack is not in item tag `wither_skeleton_disliked_weapons` (`bow`, `crossbow`) and the base skeleton rule holds. Default equipment: a stone sword in the main hand (no random enchantments). `finalizeSpawn` sets the attack damage base to 4.0 and re-evaluates the weapon goal (so it fights in melee).
- Arrows it would fire (`getArrow`) are set on fire for 100 seconds (the goal normally does not fire arrows because it holds a sword; relevant when a player gives it a bow, which it refuses to hold).
- `canBeAffected(effect)` is false for the Wither effect (immune), otherwise the skeleton rule. Melee: a successful hit gives the living target Wither for 200 ticks (21 section 5.4). Extra target goal at priority 3: `NearestAttackableTargetGoal(AbstractPiglin, mustSee true)`.

## 10. Loot, spawn weights in structures, UNIVERSAL_ANGER

- **Piglin and brute loot** (21 Open question 16): the files `loot_table/entities/piglin.json` and `piglin_brute.json` contain only the type and a `random_sequence`, with no pools; nothing drops from the table. What a piglin drops is its equipment and inventory: `Piglin.dropCustomDeathLoot` first runs the generic drop of equipment (`AbstractPiglin`), then empties the 8-slot inventory (`removeAllItems`) and drops each stack. A brute drops only the generic equipment drops (its golden axe subject to the equipment drop chances of [18](18-mob-framework.md) 6).
- **Hoglin loot** (read): pool 1, one roll: `porkchop`, `set_count` uniform 2 to 4, `furnace_smelt` (cooked porkchop) when the hoglin is on fire or the direct attacker's main-hand item has an enchantment in tag `smelts_loot`, plus looting `+uniform(0, 1)` per level; pool 2, one roll: `leather`, `set_count` uniform 0 to 1 plus looting `+uniform(0, 1)` per level. **Zoglin**: `rotten_flesh`, `set_count` uniform 1 to 3 plus looting `+uniform(0, 1)` per level. **Strider**: `string`, `set_count` uniform 2 to 5 plus looting `+uniform(0, 1)` per level. (The generic loot engine is 18; data rows are not tabulated.)
- **`UNIVERSAL_ANGER` memory writer** (21 Open question 16): written only by `PiglinAi.setAngerTarget` (2.5 step 5); read only by `findNearestValidAttackTarget` (2.2 step 3). The game rule `universal_anger` itself is read by the same code. The brute never writes or reads it (it is not in its registered memory list).
- **Hoglin and zoglin in structures** (21 Open question 22): confirmed none. Across all `data/minecraft/worldgen/structure/*.json` (52 files declare `spawn_overrides`) no override lists `hoglin`, `zoglin`, `piglin` or `piglin_brute`; the `fortress` overrides (monster list, bounding box "piece") are `blaze` weight 10 count 2 to 3, `zombified_piglin` weight 5 count 4, `wither_skeleton` weight 8 count 5, `skeleton` weight 2 count 5, `magma_cube` weight 3 count 4; `bastion_remnant` has an empty override. In the biome data (attribute `gameplay/natural_mob_spawns`, category `monster`) the only references are: `crimson_forest`: `hoglin` weight 9 count uniform 3 to 4, `piglin` weight 5 count uniform 3 to 4 (and `zombified_piglin` weight 1 count uniform 2 to 4); `nether_wastes`: `piglin` weight 15 count 4 (and `ghast` 50 count 4, `zombified_piglin` 100 count 4, `magma_cube` 2 count 4, `enderman` 1 count 4); no biome lists `zoglin` or `piglin_brute`. Hoglins, piglins and brutes in bastions therefore come from the bastion structure pieces' own data (spawner and entity placement in the structure templates, not read: Open question 6).

## 11. Worked examples and validation

### 11.1 Worked examples

1. **Anger by chest.** A player without golden armor opens a chest 6 blocks from three adult piglins in the same room, one of them behind a wall. Line of sight is required, so the two piglins that see the player run `setAngerTarget(player)` (each: `ANGRY_AT` = player UUID for 600 ticks; with `universal_anger` true also `UNIVERSAL_ANGER` 600 ticks). The piglin behind the wall is untouched. Next brain tick each of the two, in IDLE with no `ATTACK_TARGET`, finds step 2 of 2.2 (`ANGRY_AT` entity attackable) and `StartAttacking` sets `ATTACK_TARGET`; the activity becomes FIGHT. If the player equips a golden helmet afterwards, step 5 no longer yields the player, but step 2 still does until the 600 ticks end.
2. **Retaliation distance.** Piglin A has `ATTACK_TARGET` = player P at 6 blocks (36 squared) and is hit by an arrow shooter S at 10 blocks (100). Step 3 of 2.4: 100 > 36 + 16 = 52, so `isOtherTargetMuchFurther...` is true and A does not retarget. If S were 7 blocks (49), 49 > 52 is false and A may retaliate (anger on S, broadcast to nearby adult piglins).
3. **Hunt.** An adult piglin sees an adult hoglin (not marked `cannotBeHunted`), has no `ANGRY_AT`, no `HUNTED_RECENTLY`, and the visible adult piglins nearby have no `HUNTED_RECENTLY`. `StartHuntingHoglin` fires: it sets anger on the hoglin, sets `HUNTED_RECENTLY` on itself and the visible adults for 600 to 2400 ticks, and broadcasts anger to `NEARBY_ADULT_PIGLINS` (those that are hunters and can hunt hoglins). When the hoglin dies, `RememberIfHoglinWasKilled` renews `HUNTED_RECENTLY` for the killer.
4. **Outnumbered.** Three adult hoglins visible to piglin A: Piglin A sees two OTHER adult piglins (A is not in its own visible list, so `VISIBLE_ADULT_PIGLIN_COUNT` = 2) and three adult hoglins (`VISIBLE_ADULT_HOGLIN_COUNT` = 3). `hoglinsOutnumberPiglins`: 3 > 2 + 1 = false. With four hoglins: 4 > 3 = true. (If A sees only one other piglin the count is 1 and the `+ 1` supplies A: 3 > 2 is true.) When A is then hit by a hoglin: it erases its anger and target, sets `AVOID_TARGET` = that hoglin for 100 to 400 ticks, blocks hunting for a while, and every other visible adult `Piglin` does the same toward the nearest of its relevant targets.
5. **Barter.** A player right-clicks an adult piglin with 3 gold ingots: the stack becomes 2; the piglin holds 1 ingot, `ADMIRING_ITEM` for 119 ticks (adult only, not disabled). While admiring, a hit on it by a mob (not a player) cancels admiring: `ADMIRING_DISABLED` is not set (only players set it), the ingot is lost (2.3 step 2 then 3.4 step 2). When 119 ticks pass undisturbed, `StopHoldingItemIfNoLongerAdmiring` empties the off hand and rolls `piglin_bartering` once, throwing the results (each with velocity 0.3 toward the nearest visible player, spawned at the piglin's x and z and 0.3 below its eye height) at the player's position plus one block.
6. **Zombification timeline.** An adult piglin carried into the Overworld with no immunity: `timeInOverworld` counts 1 per AI step; at step 301 it becomes a zombified piglin with Nausea for 200 ticks, its inventory dropped. In the Nether the counter stays at 0.
7. **Strider boost.** A saddled strider ridden by a player holding warped fungus on a stick; `boost` draws a total of 140 + nextInt(841); at `boostTime = total / 2` the factor is `1 + 1.15 * sin(pi/2) = 2.15`. Speed attribute 0.175 (float 0.17499999701976776), not suffocating: ridden speed = 0.175 * 0.55 * 2.15 = 0.2069 (approximately). The stick takes 1 damage per boost, so a new stick lasts 100 boosts then becomes a fishing rod.
8. **Ghast spawn.** `checkGhastSpawnRules` evaluates in this order (read): difficulty is not Peaceful; then `nextInt(20) == 0`; then `checkMobSpawnRules` (the generic spawn rules). A candidate with difficulty Normal passes the second test with probability 1/20 (derived), and only then is the generic rule evaluated; Peaceful fails at the first test and never reaches the others.

### 11.2 Validation

An implementation is conforming when these tests hold:

| # | Test | Expected |
|---|---|---|
| V1 | Piglin (not baby) in IDLE; player opens a chest within 16 blocks and in line of sight; game rule `universal_anger` false | `ANGRY_AT` = that player for 600 ticks; no `UNIVERSAL_ANGER` memory; an `ATTACK_TARGET` appears within a few brain ticks |
| V2 | Same with `universal_anger` true and a second player nearer to the piglin | the piglin targets the nearest visible attackable player; `UNIVERSAL_ANGER` set 600 |
| V3 | Break a `gold_ore` block with no line of sight to the piglins | all idle piglins in the 16-block box get angry (line of sight not required for block breaking) |
| V4 | Piglin holding `ADMIRING_ITEM`; hurt by a player | `ADMIRING_DISABLED` for 400 ticks, no barter roll |
| V5 | Zombified piglin within 6 blocks and visible to a fighting piglin | its `StopAttackingIfTargetInvalid` ends the fight; step 1 of 2.2 returns none |
| V6 | `hoglinsOutnumberPiglins` with counts (piglin 2, hoglin 3) and (2, 4) | false, true |
| V7 | `StartHuntingHoglin` with a baby piglin | never fires |
| V8 | Zoglin with a villager, a creeper and another zoglin visible | targets the closest of villager (not creeper, not zoglin) |
| V9 | Hoglin near a `warped_fungus` block (8 horizontal, 4 vertical) | `NEAREST_REPELLENT` set; `PACIFIED` 200 ticks; no attack on players; walk-target value -1 at positions within 8 blocks of it |
| V10 | `piglin_repellents` search with an unlit soul campfire and a lit one at equal distance | the lit one (or the nearest lit/other) is chosen; an unlit soul campfire is never returned |
| V11 | Strider ridden by a player not holding the stick | no steering (the strider has no controlling passenger) |
| V12 | Ghast hit by a fireball reflected by a player | 1000 damage |
| V13 | Blaze with charged flag | `isOnFire` true; bit 0 of metadata 16 |
| V14 | `piglins_zombify` per dimension | false only in the Nether |
| V15 | Wither skeleton given the Wither effect | the effect is not applied |

## 12. Corrections to earlier documents

| Document | Statement | Correction |
|---|---|---|
| 21 section 5.5.1 sensor table | `NEAREST_REPELLENT` = first block in tag `piglin_repellents` | the lit-campfire test of 4.1 applies; the block tag also contains `soul_fire` and `soul_wall_torch`; the item tag of the same name differs |
| 21 section 5.5.1 sensor table | piglin sensor "first adult hoglin that `canBeHunted`" and "count of visible adult hoglins" | the count includes every adult hoglin, including ones that cannot be hunted (4.1) |
| 21 section 5.5.1 sensor table | `NEARBY_ADULT_PIGLINS` includes the source | the source is never in `NEARBY_ADULT_PIGLINS` or `NEAREST_VISIBLE_ADULT_PIGLINS` (2.5); the visible-piglin count therefore excludes the piglin itself |
| 21 section 5.5.2 | brute `wasHurtBy` calls `maybeRetaliate` | it first returns when the attacker is any `AbstractPiglin` (2.7) |
| 21 section 5.6 / earlier statement | a hoglin retreats or attacks after every hit | a baby hoglin does nothing in `onHitTarget` (6.2) |
| 21 section 5.5.1 zombification | "the attribute's value per dimension was not read" | read: false in the Nether only (section 7) |
| 21 section 5.7 | walk-target value "lava: 10; else 0 when in lava, else the base value" | 10 for lava at the position, negative infinity when in lava, else 0 (8.2) |
| 21 section 5.7 | steering "held-item condition not read" | the rider must hold `warped_fungus_on_a_stick` (8.1) |
| 21 section 5.6 | zoglin brain "not expanded" | section 6.3 |
| 18 section 4 | `isEntityAttackable` tests the target against the mob's follow range | the wrapper uses `TargetingConditions.forCombat` with a fixed range of 16.0 (section 1) |
| 21 section 5.5.1 | piglin FIGHT lists only the crossbow behaviours by parameter | spear behaviours, `BackUpIfTooClose` and the other bodies read in 2.11 and 5.7 |
| 21 section 5.1 (ghast move control) | the velocity gain is `normalize(delta) * ...` | the gain uses the normalised current velocity; and `canReach` ignores fluids for the ghast, only the happy ghast's careful mode tests them (9.1) |
| 21 section 5.3 | magma cube jump delay divisor | the divisor 3 applies when the move control's aggressive flag is set, which the attack goal sets from `canDealDamage()` (9.3) |

## 13. Open questions

1. `TargetingConditions.test` (the clause list behind `isEntityAttackable` and its ignoring-line-of-sight variant: can-attack, creative and spectator exclusion, range test, line-of-sight test, invisibility scaling) was not expanded. The wrappers, the fixed range 16.0 and the two flag variants were read (section 1); the clause list is taken from 18 section 4.
2. `Piglin.canReplaceCurrentItem` (the equipment comparison used in `wantsToPickup` step 6) and `equipItemIfPossible` were not expanded (see also 18 Open question 5).
3. `LandRandomPos.getPosAway` was read down to its delegation (section 5.3); the sampling inside `RandomPos.generateRandomPos` (candidate count, validity tests, biasing away from the point) was not read. The operand order of the dot product in `SetWalkTargetAwayFrom` step 3 is inferred from instruction order.
4. `PrepareRamNearestTarget` candidate selection arithmetic (distance window, `calculateRammingStartPosition` continuation) was not read; the goat cooldown ranges and `RAM_TARGET_CONDITIONS` are read (5.6); the other goat constants are in 5.6.
5. `AnimalMakeLove` and `CrossbowAttack` (with `CrossbowAttackMob` and the crossbow state machine) bodies were not read; the spear, `BackUpIfTooClose`, `BecomePassiveIfMemoryPresent`, `BabyFollowAdult`, `SetEntityLookTargetSometimes`, `StartCelebratingIfTargetDead`, `GoToTargetLocation`, `Mount` and `DismountOrSkipMounting` bodies are in 2.11 and 5.7 with the inferred operands marked. The per-activity behaviour lists of the piglin and brute brains are not tabulated beyond those named.
6. Bastion remnant and Nether fortress piece data (jigsaw pools under `data/minecraft/worldgen/template_pool/bastion`, spawner blocks, preplaced piglins, brutes and hoglins in structure NBT, jigsaw data-marker handling) were not read; 21 Open question 3 stays open for that part, and 21 Open question 10 is outside this part.
7. Closed: the sound-selection conditions of the piglin (2.10) and the scan interval of the three sensors (section 4, rate 20) were read. Still not expanded: the brute's and hoglin's sound selection beyond what 2.7 and 6.2 state, and the `Piglin`-side `isNearRepellent` and `seesPlayerHoldingLovedItem` bodies (taken as "memory present" from their names and memory use, inferred).
8. `BehaviorUtils.getTargetNearestMe` was read (strict comparison of squared distances, nearer wins); which entity wins an exact tie was not determined. `Entity.collidedWithShapeMovingFrom` was read down to `AABB.collidedAlongVector`, whose arithmetic was not.
9. `CollisionContext.isAbove` (strider `floatStrider`) epsilon and the precise liquid collision shape position semantics were not expanded.
10. `MoveToBlockGoal` internals (search cadence, `tryTicks` limits, `nextStartTick`) used by `StriderGoToLavaGoal` were not re-read; see the goal framework in 18.
11. Closed: the `MinecartChest.interact` path was read (2.9). Not read: whether the `interact` server-level test is a negated client-side check or a server-level instance test (same effect).
12. Spear behaviours (2.11): the `kinetic_weapon` component field read as the engage time, the exact arithmetic of the reposition and retreat distances, the product with `chargeSpeedModifier`, and the stop-time erasures of `SpearRetreat` were read only at the instruction-filter level; items marked inferred there are the only ones not read directly.
