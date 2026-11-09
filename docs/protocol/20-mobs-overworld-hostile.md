# 20 — Overworld hostile mobs

| Item | Value |
|---|---|
| Covers | Every hostile or monster-class mob that spawns in the Overworld in 26.3, per-mob parameters (entity type, size, attributes, goals and targets, special abilities, equipment, drops, experience, spawn rules, metadata, status events), the shared tables that families use, explosions, patrols, phantom spawning, and the illager raid system |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the `data/minecraft/` JSON inside the jar, with no execution. A statement is read from the artifact unless it is marked "(inferred)", names an open question, or says it was not read; nothing in this document is marked recalled. |
| Related | The shared mob framework (entity model, attribute system, goal and target selectors and the shared goal classes, Brain, pathfinding, the natural-spawning loop, loot/damage/death plumbing) is in 18-mob-framework.md; this document cites it as "18 framework: <topic>" and does not repeat it. Nether and End mobs are in 21. Entity metadata wire format: [00 §13](00-data-types.md). |

## Table of contents

1. [How to read this document](#1-how-to-read-this-document)
2. [Index: mob to entity id to section](#2-index-mob-to-entity-id-to-section)
3. [Shared tables](#3-shared-tables)
4. [Zombie family](#4-zombie-family)
5. [Skeleton family](#5-skeleton-family)
6. [Creeper and explosions](#6-creeper-and-explosions)
7. [Spiders](#7-spiders)
8. [Enderman and Endermite](#8-enderman-and-endermite)
9. [Silverfish and infested blocks](#9-silverfish-and-infested-blocks)
10. [Slime](#10-slime)
11. [Witch](#11-witch)
12. [Phantom](#12-phantom)
13. [Illagers, Ravager, Vex](#13-illagers-ravager-vex)
14. [Raid system and patrols](#14-raid-system-and-patrols)
15. [Warden](#15-warden)
16. [Breeze](#16-breeze)
17. [Creaking](#17-creaking)
18. [Giant, Sulfur Cube, and mobs owned elsewhere](#18-giant-sulfur-cube-and-mobs-owned-elsewhere)
19. [Spawn tables](#19-spawn-tables)
20. [Worked examples](#20-worked-examples)
21. [Validation](#21-validation)
22. [Open questions](#22-open-questions)

## 1. How to read this document

- Entity ids are the registration order of `EntityTypes.<clinit>` (00-based; 04 states that static-registry ids are assigned in registration order). The id column of the index is therefore "(inferred)" from that rule, but the order itself was read.
- Sizes are width x height in blocks from the `EntityType` builder. Eye height and attachment offsets are given only where an implementation needs them. Where the builder gives no eye height, the default eye height is `0.85 * height`.
- "Tick" is 1/20 s. "Difficulty id" is Peaceful 0, Easy 1, Normal 2, Hard 3.
- Attribute defaults used when a class does not set a value (read from `Attributes`): max health 20, movement speed 0.7 (only meaningful when the class sets its own), attack damage 2, follow range 32 (the `Mob` base sets 16), step height 0.6, armor 0, knockback resistance 0, explosion knockback resistance 0. Every `Monster` adds `attack_damage`; every `Mob` sets follow range 16. A class's "Attributes" row below lists only what it sets on top of that.
- Priority numbers are the numbers passed to the goal selector (lower number is higher priority). "Goal" and "Target" rows give the class and constructor parameters; their behaviour is in 18 framework: goal selector and shared goal classes unless described here.
- `Monster` base: experience reward 5, sound category hostile, and `aiStep` accumulates "no action time" by 2 per tick when the light-dependent brightness at the mob is above 0.5 (18 framework: despawning).

## 2. Index: mob to entity id to section

| Mob | Entity type | Id | Size (w x h) | Section | Natural Overworld spawn |
|---|---|---|---|---|---|
| Bogged | `minecraft:bogged` | 16 | 0.6 x 1.99 | 5 | swamp, mangrove swamp |
| Breeze | `minecraft:breeze` | 17 | 0.6 x 1.77 | 16 | no (trial chambers spawner only; none in biome lists) |
| Camel husk | `minecraft:camel_husk` | 20 | 1.7 x 2.375 | 4.4 (husk jockey), 18 | only as the husk jockey mount |
| Cave spider | `minecraft:cave_spider` | 22 | 0.7 x 0.5 | 7 | sulfur caves; mineshaft spawners (not read) |
| Creaking | `minecraft:creaking` | 31 | 0.9 x 2.7 | 17 | from creaking heart blocks |
| Creeper | `minecraft:creeper` | 32 | 0.6 x 1.7 | 6 | most biomes |
| Drowned | `minecraft:drowned` | 39 | 0.6 x 1.95 | 4.5 | oceans, rivers, dripstone caves |
| Enderman | `minecraft:enderman` | 42 | 0.6 x 2.9 | 8.1 | most biomes |
| Endermite | `minecraft:endermite` | 43 | 0.4 x 0.3 | 8.2 | none naturally in this table (ender-pearl only, 8.2) |
| Evoker | `minecraft:evoker` | 47 | 0.6 x 1.95 | 13.3 | raids, woodland mansion (not read) |
| Evoker fangs | `minecraft:evoker_fangs` | 48 | 0.5 x 0.8 | 13.3 | spell only |
| Giant | `minecraft:giant` | 60 | 3.6 x 12.0 | 18.1 | none |
| Husk | `minecraft:husk` | 68 | 0.6 x 1.95 | 4.3 | desert |
| Illusioner | `minecraft:illusioner` | 69 | 0.6 x 1.95 | 13.5 | none |
| Parched | `minecraft:parched` | 98 | 0.6 x 1.99 | 5 | desert |
| Phantom | `minecraft:phantom` | 100 | 0.9 x 0.5 (size 0) | 12 | phantom spawner |
| Pillager | `minecraft:pillager` | 104 | 0.6 x 1.95 | 13.2 | patrols, outposts, raids |
| Ravager | `minecraft:ravager` | 112 | 1.95 x 2.2 | 13.6 | raids |
| Silverfish | `minecraft:silverfish` | 117 | 0.4 x 0.3 | 9 | infested blocks, none in biome lists |
| Skeleton | `minecraft:skeleton` | 118 | 0.6 x 1.99 | 5 | most biomes |
| Slime | `minecraft:slime` | 120 | 0.52 x 0.52 at size 1 | 10 | most biomes, swamp slime chunks |
| Spider | `minecraft:spider` | 127 | 1.4 x 0.9 | 7 | most biomes |
| Stray | `minecraft:stray` | 131 | 0.6 x 1.99 | 5 | snowy plains, ice spikes |
| Sulfur cube | `minecraft:sulfur_cube` | 133 | 0.49 x 0.49 at size 1 | 18.2 | sulfur caves |
| Vex | `minecraft:vex` | 142 | 0.4 x 0.8 | 13.4 | evoker summon only |
| Vindicator | `minecraft:vindicator` | 144 | 0.6 x 1.95 | 13.1 | raids, woodland mansion (not read) |
| Warden | `minecraft:warden` | 146 | 0.9 x 2.9 | 15 | sculk shrieker only |
| Witch | `minecraft:witch` | 148 | 0.6 x 1.95 | 11 | most biomes, swamp hut |
| Zombie | `minecraft:zombie` | 154 | 0.6 x 1.95 | 4.1 | most biomes |
| Zombie horse | `minecraft:zombie_horse` | 155 | 1.3964844 x 1.6 | 18.3 | plains-type biomes (mount: 19 §3.6) |
| Zombie nautilus | `minecraft:zombie_nautilus` | 156 | 0.875 x 0.95 | 18.3 | drowned jockey mount (mount: 21 §4.10) |
| Zombie villager | `minecraft:zombie_villager` | 157 | 0.6 x 1.95 | 4.2 | most biomes |

Decisions on scope: Drowned is covered here (4.5); 21's §2 table assigns it to this document (21 §4.9 holds no separate description): it is an undead zombie that walks on land, converts from zombies, and spawns on land-adjacent water, so it is not aquatic-only. Wither skeleton, magma cube, zombified piglin, ghast, blaze, hoglin, zoglin, piglin, strider, guardian, elder guardian and shulker are left to 21. Zombie horse and skeleton horse are owned by 19 §3.6, camel husk by 19 §3.8 and zombie nautilus by 21 §4.10 (mounts per 21's §2 ownership table); this document describes only where they appear as mounts of mobs covered here.

Entity trackers: `clientTrackingRange` is 8 for most mobs here, 10 for Ravager, Giant, Breeze, Camel husk, Slime, Sulfur cube, and 16 for Warden (read from the builders).

## 3. Shared tables

### 3.1 Damage scaling by difficulty (attack damage against players)

A mob melee or projectile hit whose damage source "scales with difficulty" (`DamageSource.scalesWithDifficulty`) against a player (`Player.hurtServer`) is changed by difficulty before armor: Peaceful 0, Easy `min(d / 2 + 1, d)`, Normal `d`, Hard `d * 3 / 2`, where `d` is the incoming damage. Attack damage attributes below are the values `d` starts from; they do not vary by difficulty by themselves. Armor, enchantments and absorption are in 18 framework: damage.

### 3.2 Effective (local) difficulty, `DifficultyInstance`

Inputs: difficulty id, world game time `T`, chunk inhabited time `I`, moon brightness `M` (0 to 1). Peaceful gives 0. Otherwise:

1. `a = clamp((T - 72000) / 1440000, 0, 1) * 0.25`.
2. `base = 0.75 + a`.
3. `b = clamp(I / 3600000, 0, 1) * (1 if Hard else 0.75)`.
4. `b = b + clamp(M * 0.25, 0, a)`.
5. If Easy, `b = b * 0.5`.
6. Effective difficulty = difficulty id * (base + b).

"Special multiplier": 0 when effective difficulty < 2, 1 when > 4, otherwise `(eff - 2) / 2`. It scales pickup-loot, armor, enchantment, slime-size, and Hard reinforcement and spider-effect chances below. `isHarderThan(x)` means effective difficulty > x.

### 3.3 Brightness and "dark enough to spawn"

- Light-dependent brightness `B(l)` at a position with raw light `l` (0 to 15; sky light already reduced by the current sky-darkness): `f = l / 15`, `v = f / (4 - 3 f)`, result = `v + ambient * (1 - v)` where `ambient` is the dimension's ambient light (0 in the Overworld, so `B = v`; the lerp argument order is inferred). `B > 0.5` is true exactly for `l >= 13`.
- Monster spawn dark check (`Monster.isDarkEnoughToSpawn`), used by `checkMonsterSpawnRules`: fail if sky light at the position > a fresh `nextInt(32)`; fail if the dimension's block-light limit is below 15 and block light exceeds it (Overworld limit 0, so any block light fails); then take the raw brightness (a flat 10 during a thunderstorm in place of the real sky-dependent value) and pass if it is `<=` one sample from the dimension's spawn-light distribution (Overworld: uniform integer 0 to 7 inclusive). `checkMonsterSpawnRules` also requires the standable-block test (3.4) and skips the light test for spawn reasons that "ignore light requirements" (the reason set was not read here; 18 framework: spawn reasons).
- `checkSurfaceMonstersSpawnRules` (husk, parched, camel husk) additionally needs sky access unless the reason is a spawner. `checkAnyLightMonsterSpawnRules` (silverfish, endermite, pillager) has no light test beyond the standable-block test.

### 3.4 Standable-block test (`Mob.checkMobSpawnRules`)

Passes for spawner reasons; otherwise the block below the position must allow spawning on it (`BlockState.isValidSpawn`, 18 framework: spawn placement). Spawn placement type: all Overworld ground mobs here are `ON_GROUND`; Drowned `IN_WATER`; Evoker, Illusioner, Phantom, Vex, Vindicator, Warden `NO_RESTRICTIONS`; heightmap `MOTION_BLOCKING_NO_LEAVES` for all.

### 3.5 Daylight burning (tag `burn_in_daylight`)

Tag members: skeleton, stray, wither skeleton, bogged, zombie, zombie horse, zombie villager, drowned, zombie nautilus, phantom. Husk and parched are not in the tag (Husk also overrides sun sensitivity to false). `Mob.aiStep` calls the burn routine for tagged types every tick:

1. The environment attribute `gameplay/monsters_burn` at the mob's position must be true. In the Overworld this is the `day` timeline track: false from tick 12542 of the 24000-tick day cycle, true from 23460 (so true during [23460, 24000) and [0, 12542) of the day clock).
2. `B` at the block of the mob's eye position must exceed 0.5 (so light >= 13).
3. A random draw `nextFloat() * 30 < (B - 0.4) * 2` must succeed (per-tick probability `(B - 0.4) / 15`; 0.04 at full light).
4. The mob must not be in water or rain or in powder snow (also not "was in powder snow"), and the sky must be visible from the block at its position (`canSeeSky`).
5. If the head slot is empty: ignite for 8 seconds. If the head item is damageable: damage it by `nextInt(2)` (0 or 1) durability and do not ignite. Any other non-empty head item: nothing happens.

### 3.6 Equipment population (`Mob.populateDefaultEquipmentSlots`, used by zombies, skeletons and others via `Monster`)

1. With probability `0.15 * specialMultiplier`: pick tier `t = nextInt(3)` (0 to 2), then make 3 attempts that each add 1 to `t` with probability 0.1087.
2. Slot order is head, chest, legs, feet. The chance `p` to stop after the first slot is 0.1 on Hard and 0.25 otherwise: before each slot except the first, draw a float and stop if it is below `p`.
3. For each slot whose current item is empty: tier 0 leather, 1 copper, 2 golden, 3 chainmail, 4 iron, 5 diamond (a tier above 5 gives nothing).

After that `populateDefaultEquipmentEnchantments`: the main-hand weapon is enchanted with probability `0.25 * specialMultiplier`, each armor slot with `0.5 * specialMultiplier`, using the enchantment provider `minecraft:mob_spawn_equipment` ("by cost with difficulty": enchantments from tag `on_mob_spawn_equipment`, min cost 5, max cost span 17; selection mechanics 18 framework: enchanting helper).

Pickup loot: `finalizeSpawn` sets "can pick up loot" with probability `0.55 * specialMultiplier` (zombies, skeletons, illagers' own rules differ below). `Mob.finalizeSpawn` also adds a follow-range modifier of `triangle(0, 0.11485)` (multiplied-base) once, and with probability 0.05 makes the mob left-handed.

Equipment drop chance per slot defaults to 0.085 (`DropChances`); a stored chance above 1.0 means "guaranteed, preserved" and 2.0 is used for guaranteed drops (pumpkin helmets are set to 0). Death-drop handling is in 18 framework: loot, drops and death.

Experience: `Mob.getBaseExperienceReward` returns the type's reward; when it is above 0 it adds `1 + nextInt(3)` for each armor and hand-held slot item whose drop chance is not above 1.0. Rewards: Monster default 5; Slime and Magma Cube = size; Ravager 20; Evoker 10; Breeze 10; Phantom 5; Warden 5; Vex 3; Endermite 3; Illusioner 5; Creaking 0; baby zombie (all zombie variants) multiplies the reward by 2.5 (truncated); Pillager, Vindicator, Witch, Creeper, Skeleton family, Spider family, Enderman, Silverfish, Giant: 5 (default).

### 3.7 Common entity metadata base indices

Every mob here inherits Entity (indices 0 to 7), LivingEntity (8 to 14) and Mob (15: one byte, the mob flags; its bit meanings are not re-read here, see 18 framework: entity metadata) fields; a class's own fields start at index 16 in static-initializer order, parent first. Counts read: Entity 8 fields, LivingEntity 7, Mob 1, PathfinderMob 0, Monster 0.

### 3.8 Conversion tracker (zombie to drowned, skeleton to stray)

A "conversion tracker" runs on the server each tick while the mob is alive, not no-AI, and the mob's *afflicted* condition holds: it counts afflicted ticks up; when the count reaches the "affliction time" it switches to converting (the synched converting flag turns true) and counts down the conversion time; when the countdown goes below 0 the mob is replaced by the target type (all equipment kept per `convertTo`). If the afflicted condition stops being true at any time, both counters are reset (affliction -1) and the converting flag clears. Parameters: zombie in water (eyes in water): affliction 600, conversion 300; skeleton in powder snow: affliction 140, conversion 300. Save fields: `InWaterTime`/`DrownedConversionTime`, `FreezingTime`/`StrayConversionTime`.

### 3.9 Loot tables (all read from `data/minecraft/loot_table/entities/`)

Tables are in each mob's section. Notation: `U(a..b)` uniform integer; "looting +U(0..1)/level" means `enchanted_count_increase` of uniform 0 to 1 per level. "killed by player" is the `killed_by_player` condition. Mechanics (rolls, conditions, looting math) are 18 framework: loot.

### 3.10 Status events and level events cited

Broadcast entity events (play packet Entity Event, 05a) read from these mobs: 4 attack animation (Ravager, Warden, Creaking; the Evoker fangs entity uses 4 for its bite), 15 witch particles, 16 zombie-villager cure started (sound), 39 Ravager stunned, 61 Warden tendril clicks, 62 Warden sonic-boom charge, 69 Ravager roar. Other events these classes handle are listed in the mob's section when read. Level events (World Event packet, 05b) cited: 1019/1021 door breaking, 1026 zombie converts villager, 1027 villager cured, 1039 phantom swoop, 1040/1041 zombie and husk conversion sounds, 2001 block break particles, 2018 enderman teleport, 3007 shrieker.

## 4. Zombie family

Classes: `Zombie` (base) with subclasses `Husk`, `Drowned`, `ZombieVillager`; `ZombifiedPiglin` is Nether (21). All share the zombie goals, attributes and spawn handling below unless a subsection overrides them.

### 4.1 Zombie

| Property | Value |
|---|---|
| Entity | `zombie`, id 154, 0.6 x 1.95, baby 0.49 x 0.98 (`BABY_DIMENSIONS`), eye height 1.74 (baby 0.775), tracking range 8 |
| Attributes | follow range 35, movement speed 0.23, attack damage 3.0, armor 2.0, spawn-reinforcements chance base 0 (randomized at spawn, below). Max health 20 (default) |
| Metadata (index, serializer) | 16 baby flag (BOOLEAN, default false); 17 special type (INT, default 0, unused here); 18 "drowned conversion in progress" (BOOLEAN, default false). Changing 16 refreshes the dimensions |
| Save keys | `IsBaby`, `CanBreakDoors`, plus the conversion tracker keys (3.8) |
| Burning | in `burn_in_daylight` (3.5); the zombie class's sun-sensitive flag is true |

**Goals** (selector priority, class, parameters):

| Pri | Goal | Parameters |
|---|---|---|
| 1 | break-door goal (added only while "can break doors" is true; removed when false) | min break time 240 ticks (see below); active only when the world difficulty is Hard (the door-breaking predicate) |
| 2 | spear use (`SpearUseGoal`) | usable when the mob has a target, holds an item with the `kinetic_weapon` data component in the main hand, and is not already using an item; arguments: charge speed modifier 1.0, reposition speed modifier 1.0, approach distance 10.0 (squared 100), target-in-range radius 2.0 (squared 4); fixed distances: reposition 6 to 7 blocks, cooldown (flee) 9 to 11 blocks, flee timer `reducedTickDelay(100)`; behaviour: looks at the target (30/30); while farther than the approach distance it paths to the target; at that distance it starts the weapon engagement (starts using the item for the kinetic weapon's use duration) and charges (path to the target at the charge speed); when the target is within the in-range radius or the path ends it picks a reposition point away from the target (`LandRandomPos.getPosAway`, distances `6 + b - d` to `7 + b - d`, vertical 7, with `b` 2 when riding else 0 and `d` the current distance) and moves there; when the engagement ends it stops using the item and flees to a point `max(0, 9 + b - d)` to `max(1, 11 + b - d)` blocks away, the goal ending when that path is finished; the approach path uses the reposition speed modifier times the vehicle's charge modifier (1.0 when not riding a `Mob`); `start` sets aggressive and creates the state; `stop` stops the navigation, clears aggressive, clears the state and stops using the item; the engagement timer counts down from the kinetic weapon's use duration; after the engagement the flee timer counts up and the goal ends when it exceeds `MAX_FLEEING_TIME` (`reducedTickDelay(100)`) or when the flee path is done while the flee timer is running |
| 3 | zombie attack goal (melee) | speed 1.0, does not follow an unseen target; adds "aggressive" raise to the attack-interval half-point (below) |
| 4 | attack turtle egg goal | speed 1.0, search range 3 |
| 6 | move through village | speed 1.0, only at night (`true`), max 4 doors, "can break doors" supplier |
| 7 | water-avoiding random stroll | speed 1.0 |
| 8 | look at player | player, 8 blocks |
| 8 | random look around | |

**Targets**: 1 hurt-by (alert-others list: `ZombifiedPiglin`; 18 framework); 2 nearest attackable `Player` (must see); 3 nearest `AbstractVillager` (need not see); 3 nearest `IronGolem` (must see); 5 nearest `Turtle` within 10 ticks interval, must see, need not reach, selector "baby turtle on land".

Melee goal numbers (shared `MeleeAttackGoal`, 18 framework): attack interval 20 ticks; re-check spacing 20 game ticks; path recalculation delay base 4 + `nextInt(7)` (+10 if target farther than 32 blocks, +5 if farther than 16, +15 if the path fails); the zombie goal sets "aggressive" while the attack timer has run for 5 ticks and is within half the interval of the next attack.

**Attack**: `doHurtTarget` = base melee with attack damage 3.0 (3.1 scaling). If the hit lands, the zombie's main hand is empty and the zombie is on fire, then with probability `effectiveDifficulty * 0.3` the target is set on fire for `2 * floor(effectiveDifficulty)` seconds.

**Door breaking** (`BreakDoorGoal`): canUse when the mob-griefing rule is true, the difficulty predicate holds and the door is closed; each tick, with 1/20 chance, play level event 1019 and swing; the break progress goes up 1 per tick; the visible stage is `floor(progress / breakTime * 10)` and is sent as block destruction progress; when progress reaches the break time (minimum 240 ticks, `max(240, ...)`) and the predicate still holds the door block is removed (level events 1021 and 2001 with the block id). `Zombie.setCanBreakDoors(true)` also enables the navigation's "can open doors". Vindicators use a 6-tick-interval variant (13.1).

**Spawn setup** (`finalizeSpawn`, 3.6 applies):

1. (not for spawn reason CONVERSION) can-pick-up-loot with probability `0.55 * specialMultiplier`.
2. If no group data: baby with probability 0.05 (and jockeys allowed). If the zombie is baby and jockeys are allowed: with probability 0.05 look for an un-ridden chicken within the box inflated by (5, 3, 5) around the zombie; if one exists, mark it a chicken jockey and ride it. Otherwise (the first 0.05 test failed) with probability 0.05 create a chicken (spawn reason JOCKEY), place it at the zombie, finalize it, mark it a jockey, ride it, add it to the level.
3. Baby zombies get the movement-speed modifier id `baby`: +0.5, multiplied-base.
4. "Can break doors" is set with probability `0.1 * specialMultiplier` (only for entities whose navigation can navigate ground).
5. Unless the reason is CONVERSION: populate default equipment (3.6), then the zombie weapon: with probability 0.05 on Hard and 0.01 otherwise, draw `nextInt(6)`: 0 iron sword, 1 iron spear, otherwise iron shovel, in the main hand; then enchant (3.6).
6. If the head is empty and the date is Halloween (client date check) and `nextFloat < 0.25`: head becomes a carved pumpkin (jack-o'-lantern with probability 0.1), with drop chance 0. (Date source: the world clock's `SpecialDates.isHalloween`, not traced.)
7. `handleAttributes(specialMultiplier, reason)`:
   - Reinforcement chance base value = `nextDouble() * 0.1`.
   - Knockback resistance + `nextDouble() * 0.05` (add-value modifier `random_spawn_bonus`).
   - `x = nextDouble() * 1.5 * specialMultiplier`; if `x > 1`, follow range gets a multiplied-total modifier of `x` (`zombie_random_spawn_bonus`).
   - With probability `0.05 * specialMultiplier` the zombie is a "leader": reinforcement chance + `0.5 + nextDouble() * 0.25` (add-value, `leader_zombie_bonus`), max health multiplied-total modifier `nextDouble() * 3 + 1` (`leader_zombie_bonus`), health set to the new max unless the reason is CONVERSION, LOAD or DIMENSION_TRAVEL, and can-break-doors forced true.

**Reinforcements** (`hurtServer`, only after a successful base hurt): requires world difficulty Hard, a living target (the zombie's target, or the attacker if the zombie has none), `nextFloat < reinforcements chance attribute value`, and `ServerLevel.isSpawningMonsters` (game rules `spawn_mobs` and `spawn_monsters`). Then up to 50 attempts: pick a position offset from the zombie on each axis by `nextInt(7..40) * nextInt(-1..1)` (so 0 is possible); a try succeeds when all hold: the spawn position passes the entity type's placement check, `checkSpawnRules` with reason REINFORCEMENT passes, no living player within 7 blocks, no entity or block collision, and not in liquid unless the type allows liquids. The new zombie of the *same type* (`getType`) has the attacker as target, is finalized with reason REINFORCEMENT and added; the caller's reinforcement chance is lowered by 0.05 (modifier `reinforcement_caller_charge`, accumulating) and the callee gets `reinforcement_callee_charge` -0.05.

**Kill a villager** (`killedEntity`): when world difficulty is Normal or Hard and the victim is a `Villager`: on Hard always, on Normal only if `nextBoolean()`: the villager is converted to a `ZombieVillager` (4.2) with villager data, gossips, offers and xp copied (level event 1026 unless silent) and the villager does not drop. On Easy the villager dies normally.

**Pickup**: zombies never pick up glow ink sacs; babies riding something do not hold eggs. They pick up loot when allowed by 3.6 and the mob-griefing rule.

**Drops** (`entities/zombie`): rotten flesh `U(0..2)` + looting `U(0..1)`/level; red mushroom `U(0..1)` + looting when riding a `zombie_horse`; if killed by player, one of {iron ingot, carrot, potato (smelted to baked potato if the zombie was on fire or the killer's main-hand item has an enchantment from `#smelts_loot`)} with chance 0.025 (looting: 0.035 + 0.01 per level above the first); if killed by player and the zombie is a baby riding a chicken, one `music_disc_lava_chicken`. XP 5, x2.5 truncated for babies (plus equipment bonus 3.6).

### 4.2 Zombie villager

Differs from 4.1: entity `zombie_villager` (id 157), same attributes, baby dimension 0.49 x 0.98 with eye height 0.67, adult eye height 1.74, `convertsInWater` false (no drowned conversion).

Metadata (own fields, after the Zombie ones 16-18): 19 converting flag (BOOLEAN, false), 20 villager data (VILLAGER_DATA; default = the default villager data with a uniformly random registered profession; the villager type is set once, by `finalizeVillagerType` during `finalizeSpawn`, to the type mapped from the biome at the spawn position: desert for badlands, desert, eroded_badlands, wooded_badlands; jungle for bamboo_jungle, jungle, sparse_jungle; savanna for savanna_plateau, savanna, windswept_savanna; snow for deep_frozen_ocean, frozen_ocean, frozen_river, ice_spikes, snowy_beach, snowy_taiga, snowy_plains, grove, snowy_slopes, frozen_peaks, jagged_peaks; swamp for swamp, mangrove_swamp; taiga for old_growth_spruce_taiga, old_growth_pine_taiga, windswept_gravelly_hills, windswept_hills, taiga, windswept_forest; every other biome and the default type: plains), 21 villager-data-finalized (BOOLEAN, false). Save keys: `VillagerData`, `VillagerDataFinalized`, `Offers`, `Gossips`, `ConversionTime`, `ConversionPlayer`, `Xp`.

**Curing**: `mobInteract` with a golden apple while the zombie villager has Weakness: consume 1 item; (server side) conversion time = `2401 + nextInt(3600)` ticks, conversion player = the feeder; set converting; remove Weakness; add Strength with amplifier `min(difficultyId - 1, 0)` and a duration equal to the conversion time (the amplifier expression gives 0 on Easy, Normal and Hard); broadcast entity event 16 (cure sound at the mob). Returns SUCCESS_SERVER for the server, CONSUME for the client.
Each tick while converting and alive (server): the remaining conversion time is reduced by the "conversion progress" amount: 1, and with probability 0.01 per tick a block scan is done over x, y and z in [floor-4, floor+4) around the zombie, counting up to 14 matching blocks (blocks in `speeds_up_zombie_villager_curing`: `iron_bars`, `#beds`); each matching block adds 1 progress with probability 0.3. When the time reaches 0 the zombie villager becomes a `Villager` (spawn reason CONVERSION): equipment: all equipment is dropped (`dropPreservedEquipment`) except stacks that carry the `prevent_armor_change` enchantment effect, which are kept and set into the villager's matching equipment slots, villager data, finalized flag, gossips, offers, xp; the new villager gets Nausea 200 ticks; level event 1027 (unless silent); advancement trigger and a `ZOMBIE_VILLAGER_CURED` reputation event for the conversion player.
A converting zombie villager never despawns (`removeWhenFarAway` false while converting).

Drops: rotten flesh `U(0..2)` + looting; if killed by player, the same iron ingot / carrot / potato pool at 0.025 (looting 0.035 + 0.01 per level above first). XP 5 (x2.5 baby).

### 4.3 Husk

Same as 4.1 except: entity `husk` (id 68), eye height 1.74 (baby: 0.49 x 0.98 with eye height 0.825), not sun-sensitive (never burns), `convertsInWater` true (the Zombie conversion tracker runs; the conversion type is a plain `Zombie`, conversion sound level event 1041). Melee: `doHurtTarget` applies Hunger to a living target when the main hand is empty: duration `140 * floor(effectiveDifficulty)` ticks, amplifier 0.

`finalizeSpawn` (after `Zombie.finalizeSpawn`, 4.1): (1) when the spawn reason is not CONVERSION, can-pick-up-loot is rolled again with probability `0.55 * specialMultiplier`. (2) If group data exists it is wrapped in a `HuskGroupData` (copying baby and jockey flags) whose flag `triedToSpawnCamelHusk` is initialised to "the spawn reason is not NATURAL" (so only NATURAL spawns ever try). (3) If the group data is a `HuskGroupData` and its flag is false, and the camel husk's spawn box (`EntityType.getSpawnAABB` at the husk's block center x + 0.5, y, z + 0.5) has no collision: the flag is set true *before* rolling (one attempt per group, no second collision test), then with probability 0.1 (`nextFloat < 0.1`): an iron spear is placed in the husk's main hand; a `camel_husk` (spawn reason NATURAL) is created, positioned at the husk, finalized (spawn reason NATURAL as passed, no group data), the husk starts riding it (force flags true), and the camel husk is added to the level; then a `parched` (spawn reason NATURAL) is created, positioned at the husk's position with the husk's yaw and pitch 0, finalized with the passed difficulty, reason and no group data, starts riding the camel husk (force flags false) and is added with its passengers. Babies are not excluded by any test in this method (the group data carries the baby flag but it is not read here); the group's first husk gets the single attempt.
Spawn rule: `checkSurfaceMonstersSpawnRules`. Drops: rotten flesh `U(0..2)` + looting; `rabbit_foot` `U(0..1)` + looting when riding a `camel_husk`; killed-by-player iron/carrot/potato pool as the zombie (0.025; looting 0.035 +0.01/level above first). XP 5.

### 4.4 Camel husk (mount)

Entity `camel_husk` (id 20), 1.7 x 2.375, eye height 2.275, category monster, spawn check `checkSurfaceMonstersSpawnRules`, loot table `entities/camel_husk`: rotten flesh `U(2..3)` + looting `U(0..1)`/level. Camel husk behaviour is described in 19 §3.8.

### 4.5 Drowned

| Property | Value |
|---|---|
| Entity | `drowned`, id 39, 0.6 x 1.95 (baby 0.49 x 0.98), eye height 1.74 (baby 0.775), `notInPeaceful` |
| Attributes | as Zombie plus step height 1.0 |
| Movement | `AmphibiousPathNavigation`, path-type malus for WATER set to 0 (no avoidance), custom move control; while swimming (`isSwimming`) not pushed by fluid; in water with a target in water it moves freely |
| Conversion | converts nothing (`convertsInWater` false); drowned come from zombie conversion (3.8) |
| Burning | in `burn_in_daylight` |

Goals in addition to the zombie's look and random-look (8) and turtle-egg (4): 1 go-to-water (speed 1.0; active only when it is bright outside and the mob is not in water; walks to a water position found by `getWaterPos`); 2 trident attack (speed 1.0, interval 40 ticks, range 10.0; usable only with a trident in the main hand; starts using the item); 2 drowned attack (speed 1.0, no unseen-follow; only when `okTarget`); 5 go-to-beach (speed 1.0; active only at night, when in water and `y >= seaLevel - 3`); 6 swim-up (speed 1.0; at night, in water and `y < seaLevel - 2`, swims up; picks a point towards the sea surface when it is near its next path node); 7 random stroll (speed 1.0). Targets: 1 hurt-by (drowned, alerting zombified piglins); 2 player (random interval 10, must see, selector `okTarget`); 3 villager; 3 iron golem; 5 turtle (as zombie). `okTarget(t)` = target not null and (it is not bright outside or `t` is in water). "Wants to swim" = searching-for-land flag or (has a target in water) (inferred from the checks).

Trident throw (`performRangedAttack`): a thrown trident (an item stack of the held trident), aim vector from the drowned to the target's position at one third of its height, y component plus `0.2 * horizontal distance`, speed 1.6, inaccuracy = the field `rangedAttackUncertainty` when set (>= 0) else `14 - 4 * difficultyId`; sound level `drowned_shoot`.

Equipment (`populateDefaultEquipmentSlots`, which replaces the zombie one: no armor or zombie weapons): with probability 0.1 (`nextFloat > 0.9`) a weapon: `nextInt(16) < 10` trident, else fishing rod. `finalizeSpawn`: after the zombie's, if the off hand is empty and `nextFloat < 0.03` a nautilus shell in the off hand with guaranteed drop; for reasons NATURAL or STRUCTURE with a trident in the main hand, `nextFloat < 0.5`, not baby, and the biome not in `more_frequent_drowned_spawns`: a `zombie_nautilus` (spawn reason JOCKEY) at the same position carries it (persistence required for STRUCTURE).

Spawn rule (`checkDrownedSpawnRules`; placement IN_WATER): the block below must hold water (or the reason is a spawner); and `base` = difficulty is not Peaceful, (reason ignores light or the dark check 3.3 passes), and (reason is a spawner or the block itself holds water). If `base` and (spawner or REINFORCEMENT reason): true. Otherwise in biomes tagged `more_frequent_drowned_spawns` (rivers): `nextInt(15) == 0 && base`; elsewhere: `nextInt(40) == 0 && y < seaLevel - 5 && base`.
Drops: rotten flesh `U(0..2)` + looting; killed-by-player copper ingot with chance 0.11 (looting 0.13 + 0.02 per level above first); nautilus shell and held items per 3.6. XP 5.

## 5. Skeleton family

`AbstractSkeleton` (base) with `Skeleton`, `Stray`, `Bogged`, `Parched`; `WitherSkeleton` is Nether (21). Tag `skeletons` = skeleton, stray, wither skeleton, skeleton horse, bogged, parched.

| Mob | Id | Attributes (beyond Monster: speed 0.25) | Arrow effect | Attack interval (non-Hard / Hard) | Extra |
|---|---|---|---|---|---|
| Skeleton | 118 | movement speed 0.25, max health 20 | none | 40 / 20 | freezes to stray (3.8: 140 / 300, trigger = in powder snow) |
| Stray | 131 | as skeleton | Slowness 600 ticks added to arrows | 40 / 20 | entity builder `immuneTo` block tag `stray_immune_to`; cannot freeze; in `freeze_immune_entity_types` |
| Bogged | 16 | max health 16 | Poison 100 ticks | 70 / 50 | shearing (below) |
| Parched | 98 | max health 16 | Weakness 600 ticks | 70 / 50 | cannot be affected by the Weakness effect |

(Metadata: Skeleton index 16 = stray-conversion flag BOOLEAN; Bogged 16 = sheared flag BOOLEAN; Stray and Parched add none; the base adds none.)

**Goals** (AbstractSkeleton): the constructor builds a bow goal (speed 1.0, base interval 20, radius 15.0) and a melee goal (speed 1.2, no follow); `reassessWeaponGoal` (on spawn, load and equipment change, server only) removes both and, when the held weapon is a bow, adds the bow goal at priority 4 with minimum attack interval = the Hard interval on Hard and the normal interval otherwise, else adds the melee goal at priority 4. Fixed: 2 restrict-sun, 3 flee-sun (speed 1.0), 3 avoid `Wolf` (6.0, speeds 1.0 / 1.2), 5 water-avoiding stroll (1.0), 6 look at player (8.0), 6 random look around. Targets: 1 hurt-by, 2 nearest `Player`, 3 `IronGolem`, 3 `Turtle` (10 ticks interval, must see, selector baby on land).

**Bow goal** (shared `RangedBowAttackGoal`): needs a target and a bow in hand. Fields: `seeTime`, `strafingTime` (starts -1), `strafingClockwise`, `strafingBackwards`, `attackTime`; `attackRadiusSqr` = radius squared (225); `speedModifier`; `attackIntervalMin`. Each tick, with a target:
1. `d2` = squared distance to the target; `sees` = line of sensing to the target. If `sees` differs from `seeTime > 0`, `seeTime` is reset to 0; then `seeTime` increases by 1 when `sees`, else decreases by 1.
2. If `d2 <= attackRadiusSqr` and `seeTime >= 20`: stop the navigation and `strafingTime += 1`; otherwise path to the target at `speedModifier` and set `strafingTime = -1`.
3. If `strafingTime >= 20`: with probability 0.3 (`nextFloat < 0.3`) flip `strafingClockwise`, with a separate draw of 0.3 flip `strafingBackwards`, then `strafingTime = 0`.
4. If `strafingTime > -1`: if `d2 > 0.75 * attackRadiusSqr` set backwards false, else if `d2 < 0.25 * attackRadiusSqr` set backwards true; then strafe with forward component -0.5 (backwards) or +0.5 and sideways +0.5 (clockwise) or -0.5; look at the target with 30/30 limits (through the vehicle if the shooter rides a `Mob`). Otherwise just look at the target with the look control (30/30).
5. If the shooter is using its item: when it does not see the target and `seeTime < -60` it stops using the item; otherwise, when it sees the target and has used the item for at least 20 ticks, it stops using it, calls `performRangedAttack(target, BowItem.getPowerForTime(ticksUsed))` and sets `attackTime = attackIntervalMin`. If it is not using the item: `attackTime` decreases by 1 and when it is 0 or below and `seeTime >= -60` it starts using the bow (main hand if it holds a bow, else off hand).
Release power `getPowerForTime(ticks)`: with `f = ticks / 20` capped at 1 the power is `(f*f + 2f) / 3` capped at 1, so 1.0 at 20 ticks. The goal flags are move and look, usable with a target and a bow in hand, and it sets aggressive on start and clears it (and stops using the item) on stop.

**Shot** (`performRangedAttack(target, power)`): arrow from `ProjectileUtil.getMobArrow` (uses the held ammo or a normal arrow, `Stray`/`Bogged`/`Parched` add their effect); `setBaseDamageFromMob(power)`: base damage = `power * 2 + triangle(difficultyId * 0.11, 0.57425)`. Aim: dx = target.x - mob.x, dz likewise, dy = target.y(at 1/3 of its height) - arrow.y; the vertical component passed is `dy + horizontalDistance * 0.2`; arrow speed 1.6. **`Projectile.shoot(dx, dy, dz, speed, inaccuracy)`** (`getMovementToShoot`): the direction vector is normalized; each of its three components gets an independent `triangle(0, 0.0172275 * inaccuracy)` added (a triangular distribution: the difference of two uniform draws scaled by the half-width); the vector is multiplied by `speed` and becomes the delta movement; yaw = `atan2(x, z)` and pitch = `atan2(y, horizontal length)` in degrees. Inaccuracy `14 - 4 * difficultyId` (Easy 10, Normal 6, Hard 2; Peaceful 14); sound `skeleton_shoot` volume 1, pitch `1 / (nextFloat * 0.4 + 0.8)`.
Arrow hit damage (`AbstractArrow.onHitEntity`): `ceil(clamp(|velocity| * baseDamage, 0, 2147483647))`, plus a critical bonus `nextInt(ceil/2 + 2)` if the arrow is critical, then a flame effect (burning 5 s) if the arrow burns; pierce and knockback per 18 framework: projectiles. Mob arrows live 1200 ticks (`tickDespawn`), water inertia 0.6.

**Equipment**: `AbstractSkeleton.populateDefaultEquipmentSlots` calls the `Mob` one (3.6) and puts a bow in the main hand (always); then enchant (3.6). `finalizeSpawn`: pickup-loot probability `0.55 * specialMultiplier`; Halloween pumpkin as 4.1.6 with drop chance 0. Skeletons do not pick up spears (they refuse `spears`-tagged items).

**Skeleton drops**: arrow `U(0..2)` + looting; bone `U(0..2)` + looting. **Stray, Bogged, Parched**: the same two pools plus, if killed by player, a tipped arrow `U(0..1)` + looting `U(0..1)`/level limited to +1, with potion Slowness (stray), Poison (bogged), Weakness (parched). XP 5.

**Bogged shearing**: `mobInteract` with shears when not sheared: shear sound, drop the `BOGGED_SHEAR` shearing loot table at the mob, set sheared (metadata 16), damage the shears 1. The table has 2 rolls, each choosing uniformly between `brown_mushroom` x1 and `red_mushroom` x1.

**Stray spawn**: `checkStraySpawnRules`: a working position starts at the spawn position and is moved up one block at a time while the block at the new position is powder snow; the result is `checkMonsterSpawnRules` evaluated for the spawn position and, unless the reason is a spawner, `canSeeSky` for the block below the final working position (the monster rules are evaluated at the original position: the loop variable is a separate local). **Others**: Skeleton, Bogged: `checkMonsterSpawnRules`; Parched: `checkSurfaceMonstersSpawnRules`.

## 6. Creeper and explosions

### 6.1 Creeper

| Property | Value |
|---|---|
| Entity | `creeper`, id 32, 0.6 x 1.7, tracking range 8 |
| Attributes | movement speed 0.25 |
| Fields | max fuse (`maxSwell`) 30, explosion radius 3 (both saved: `Fuse` as short, `ExplosionRadius` as byte, `ignited` boolean, `powered` boolean) |
| Metadata | 16 swell direction (INT, default -1), 17 powered (BOOLEAN, false), 18 ignited (BOOLEAN, false) |
| Fall damage | `causeFallDamage`: adds `floor(distance * 1.5)` to the swell counter, capped at `maxSwell - 5`; max safe fall distance is the comfortable-fall distance of (health - 1), or of 0 when targeting |

Goals: 1 float; 2 swell (see below); 3 avoid `Ocelot` (6.0, speeds 1.0 / 1.2); 3 avoid `Cat` (6.0, 1.0 / 1.2); 4 melee (speed 1.0, no follow); 5 water-avoiding stroll (0.8); 6 look at player (8.0); 6 random look around. Targets: 1 nearest `Player` (must see); 2 hurt-by. `setTarget` ignores a `Goat` as target. The creeper's `doHurtTarget` only returns true (its "attack" is the swell).

**Swell goal**: usable when the swell direction is above 0 or the target is alive and within `distanceToSqr < 9` (3 blocks); `start` stops navigation. Each tick: swell direction is set to -1 when there is no target, the target is dying, the target is farther than 7 blocks (`distanceToSqr > 49`), or the creeper cannot see it (line of sensing); otherwise 1. The goal updates every tick (`requiresUpdateEveryTick`).

**Tick**: when alive: remember the previous swell; if ignited force direction to 1; when direction > 0 and swell is 0 play `creeper_primed` (volume 1, pitch 0.5) and the `prime_fuse` game event; add the direction to the swell; below 0 clamp to 0; when swell >= `maxSwell` set swell to `maxSwell` and explode. The visible swell fraction is the lerp of old/new swell divided by `maxSwell - 2`.

**Ignition**: `mobInteract` with an item in tag `creeper_igniters` (members `flint_and_steel`, `fire_charge`): sound (`firecharge_use` for fire charge, else `flintandsteel_use`, volume 1, pitch `nextFloat * 0.4 + 0.8`), set ignited, damage or consume the item. Lightning (`thunderHit`) sets powered.

**Explosion** (`explodeCreeper`): power = `explosionRadius * (2 if powered else 1)` = 3 or 6 (floats), at the creeper's position, with interaction `MOB` and no fire; then a lingering cloud if the creeper has active effects (below), `triggerOnDeathMobEffects`, discard (removal reason KILLED). The creeper sets its `dead` flag before exploding (`isDeadOrDying` is true when health is 0 or less or `dead` is set). Charged creeper kills: `killedEntity`: if the victim's death was caused by this powered creeper and it has not yet dropped a skull, the loot table `charged_creeper/root` is rolled once (head by victim type: creeper head, piglin head, skeleton skull, wither skeleton skull, zombie head).
**Lingering cloud** (`spawnLingeringCloud`): only when the creeper has active mob effects: area effect cloud at the creeper with radius 2.5, radius-on-use -0.5, wait time 10 ticks, duration 300, potion duration scale 0.25, radius per tick = -radius / duration, carrying copies of each active effect.

**Drops** (`entities/creeper`): gunpowder `U(0..2)` + looting `U(0..1)`/level; if the attacker (killer) is an entity of tag `skeletons`: one random item of tag `creeper_drop_music_discs` (`music_disc_13, cat, blocks, chirp, far, mall, mellohi, stal, strad, ward, 11, wait`). XP 5. Spawn rule `checkMonsterSpawnRules`.

### 6.2 Explosion algorithm (`ServerExplosion`)

Input: center, power `R` (float), source entity, interaction (NONE, KEEP, DESTROY, DESTROY_WITH_DECAY, TRIGGER_BLOCK), fire flag. `ServerLevel.explode` maps the interaction `MOB` to: when the mob-griefing rule is true, block destruction, with loot decay (each drop survives with probability `1/R`) when the `mob_explosion_drop_decay` rule is true and without it otherwise (`getDestroyType`: rule true gives DESTROY_WITH_DECAY, false gives DESTROY); when mob griefing is false, KEEP (damage and knockback only, no block changes). NONE maps to KEEP. `BLOCK` uses the `block_explosion_drop_decay` rule; `TNT` uses `tnt_explosion_drop_decay`; a trigger interaction (wind charges) is TRIGGER_BLOCK (all rules per 18 framework: game rules). The game event `explode` is emitted first.

**Block selection** (`calculateExplodedPositions`): for each of the 16 x 16 x 16 grid cells `(i, j, k)` that lie on the surface of the cube (at least one of i, j, k is 0 or 15; loops in order i outer, j middle, k inner), form the direction `(i/15*2 - 1, j/15*2 - 1, k/15*2 - 1)` and normalize it. The ray starts at the center with strength `R * (0.7 + nextFloat() * 0.6)` (one random float per ray, taken at ray start). While strength > 0: take the block at the current position (floored); if it is air and has no fluid, nothing; otherwise the blast resistance of the block or fluid (the larger of block resistance and fluid resistance; for an entity-based calculator it is further adjusted by the entity) `r` reduces the strength by `(r + 0.3) * 0.3`; if the strength is still > 0 and the block may explode (`shouldBlockExplode`, always true for the default calculator), add the block position to the set. Then advance the position by `direction * 0.3` and subtract 0.225 (read as `0.22500001f`) from the strength. A ray ends if the position leaves the world bounds.

**Entity damage** (`hurtEntities`): nothing happens when `R < 0.00001`. The damage radius is `2R`: entities whose bounding boxes intersect the box from `center - (2R + 1)` to `center + (2R + 1)` (each corner floored/ceiled to block coordinates) are considered (`getEntities(source, box)` excludes the explosion's source entity, so a creeper never damages itself), except those that ignore explosions. For each: `dist = distance(entity position, center) / (2R)` (entity feet position; for a primed TNT its position); skip if `dist > 1`. The *exposure direction* is `normalize(eyePosition(or position for TNT) - center)`. `seen` (fraction of rays that reach the entity, below) is computed when the calculator allows damage to the entity (always true by default) or the knockback multiplier is nonzero, and is 0 otherwise. If damage is allowed and teams allow it, the entity is hurt with damage = `((s*s + s) / 2 * 7 * (2R) + 1)` with `s = (1 - dist) * seen`, delivered as the explosion damage source (damage after 3.1 scaling for players). Knockback strength `= (1 - dist) * seen * knockbackMultiplier * (1 - explosionKnockbackResistance)` (multiplier 1 by default, resistance attribute for living entities, 0 otherwise); the entity's velocity is increased by `direction * strength` (`pushFromExplosion`). Each entity then also receives `onExplosionHit(source)` (a no-op with the default calculator). Each hit player that is not a spectator and not (creative and flying) is recorded with its knockback vector so that the client applies it (Explode packet 05a 0x24, sent to players within 64 blocks of the center (distance squared < 4096)). Redirectable projectiles (tag `redirectable_projectile`) that are `Projectile`s get the explosion's damage-source entity as owner and are never added to the hit-player map.

**Seen fraction** (`getSeenPercent(center, entity)`): with the entity's bounding box extents `ex, ey, ez` (max minus min on each axis) the per-axis steps are `sx = 1 / (2 * ex + 1)`, `sy = 1 / (2 * ey + 1)`, `sz = 1 / (2 * ez + 1)`; the horizontal offsets are `ox = (1 - floor(1 / sx) * sx) / 2` and `oz = (1 - floor(1 / sz) * sz) / 2` (there is no vertical offset). The result is 0 when any step is negative. Otherwise sample parameters `tx`, `ty`, `tz` each run from 0 to 1 inclusive in increments of their step (x outermost, then y, then z innermost); each sample point is `(lerp(tx, minX, maxX) + ox, lerp(ty, minY, maxY), lerp(tz, minZ, maxZ) + oz)`; a ray is cast from the sample point to the explosion center with the collider block context and no fluids; a sample counts as unobstructed when the ray result is a miss. The result is `unobstructed samples / total samples` as a float.

**After blocks** (`interactWithBlocks`, when the interaction is not NONE/KEEP): the positions are shuffled; each block's `onExplosionHit` runs: air is skipped; for TRIGGER_BLOCK interactions triggerable blocks react (not traced); for DESTROY(_WITH_DECAY): the block's loot table is rolled with the explosion origin at the block center, an empty-hand tool, the block entity and the source entity, plus the explosion radius parameter when decay applies (the `explosion_decay` condition passes with probability `1 / R`); the block is replaced by air (neighbors updated) and `wasExploded` runs; dropped stacks are merged by `addOrAppendStack` and spawned. Fire (when the fire flag is set, not for creepers): about one in three of the exploded positions that are now air above a solid-render block becomes fire.

**Charged creeper**: power 6 instead of 3 changes `2R` from 6 to 12, so it reaches farther (worked example 20.1).

## 7. Spiders

### 7.1 Spider

| Property | Value |
|---|---|
| Entity | `spider`, id 127, 1.4 x 0.9, eye height 0.65, tracking range 8 |
| Attributes | max health 16, movement speed 0.3 |
| Metadata | 16 spider flags (BYTE; bit 0 = climbing) |
| Navigation | wall-climber navigation; `onClimbable` = the climbing bit, which the server sets every tick to "has horizontal collision" |
| Immunities | cannot receive the Poison effect; cobwebs do not slow it (`makeStuckInBlock` ignores cobweb) |
| Arthropod | member of tag `arthropod` (Bane of Arthropods; 18 framework) |

Goals: 1 float; 2 avoid `Armadillo` (6.0, speeds 1.0 / 1.2, only armadillos that are not "scared"); 3 leap at target (leap strength 0.4); 4 spider attack (melee speed 1.0, follows unseen targets, usable only when not carrying a passenger; each tick it can continue only while the light-dependent brightness at the spider is below 0.5, else with probability 1/100 per tick it clears its target and stops); 5 water-avoiding stroll (0.8); 6 look at player (8.0); 6 random look around. Targets: 1 hurt-by; 2 spider-target `Player`; 3 spider-target `IronGolem`. The spider-target goal only starts when the brightness at the spider is below 0.5 (light below 13); both use "must see". Net effect: neutral in daylight unless already provoked.

Attack damage: default `Monster` attack damage 2.0 (3.1 applies). Spawn rule `checkMonsterSpawnRules`. Drops: string `U(0..2)` + looting; if killed by player a spider eye `U(-1..1)` + looting (negative results clamp to 0 stacks). XP 5.

**Jockey and effects** (`finalizeSpawn`): with probability 1/100 (`nextInt(100) == 0`) a skeleton (spawn reason JOCKEY) is created at the spider's position, finalized and made to ride it. If no group data is given, a spider-effects data object is created; on Hard difficulty (world difficulty, not effective) with probability `0.1 * specialMultiplier` a random effect is chosen: draw `nextInt(5)`; 0 or 1 Speed, 2 Strength, 3 Regeneration, 4 Invisibility; a spider whose group data has an effect gets it with an infinite duration (-1), amplifier 0 (infinite = no expiry). The passenger attachment point for a rider is (0, 0.3125 * scale, 0) when the rider is not wider than the spider.

### 7.2 Cave spider

Entity `cave_spider`, id 22, 0.7 x 0.5, eye height 0.45. Inherits all of 7.1 with max health 12. Attack (`doHurtTarget`): after a successful hit on a living target, apply Poison with amplifier 0 for 7 seconds on Normal, 15 seconds on Hard, nothing on Easy (and Peaceful). Passenger attachment point (0, 0.21875 * scale, 0). Drops: same two pools as the spider (string `U(0..2)` + looting; spider eye `U(-1..1)` + looting if killed by player). Spawn rule `checkMonsterSpawnRules`; natural spawns only in the `sulfur_caves` biome in this artifact's biome lists; mineshaft cave-spider spawner blocks are structure content not traced here (open question 12).

## 8. Enderman and Endermite

### 8.1 Enderman

| Property | Value |
|---|---|
| Entity | `enderman`, id 42, 0.6 x 2.9, eye height 2.55, tracking range 8 |
| Attributes | max health 40, movement speed 0.3, attack damage 7.0, follow range 64, step height 1.0 |
| Metadata | 16 carried block (OPTIONAL_BLOCK_STATE, absent), 17 creepy / angry-look flag (BOOLEAN, false), 18 has-been-stared-at (BOOLEAN, false) |
| Path costs | water path type malus -1 (avoid), another type malus `Integer.MIN_VALUE` as a float (read as `-2147483648` int constant; treated as impassable, inferred) |
| Water | hurt by water and rain (`isSensitiveToWater`) and hurt by water-containing potions (`hurtWithCleanWater`: potions of tag `hurts_water_sensitive_entities`) |
| Save keys | `carriedBlockState` (block state) plus the persistent-anger fields (`AngerTime`-style, 18 framework: universal anger) |
| Angry speed | when it has a target, the transient movement-speed modifier `attacking` +0.15 (add-value) is applied; removed when the target clears; the creepy flag follows "has a target" |

Goals: 0 float; 1 freeze-when-looked-at (flags jump and move; usable when its target is a `Player` farther than 0 and within 16 blocks and the player is staring at it; stops navigation and looks at the target); 2 melee (speed 1.0, no unseen follow); 7 water-avoiding stroll (speed 1.0, probability 0.0 float arg); 8 look at player (8.0); 8 random look around; 10 leave block; 11 take block. Targets: 1 look-for-player (see below); 2 hurt-by; 3 nearest `Endermite` (must not see: `false`, interval 10); 4 reset-universal-anger.

**Gaze anger**: `isBeingStaredBy(player)` is true when the player's head slot does not hold an item of tag `gaze_disguise_equipment` (`carved_pumpkin`) and the player is "looking at me" with tolerance 0.025: normalize the player's view vector `v` and the vector `w` from the player's eye... to the enderman's eye height position (components: enderman x minus player x, enderman eye y minus player eye y, enderman z minus player z; the player position used for the first two terms is the player's eye); with `d = |w|` and `w` normalized: stared at when `dot(v, w) > 1 - 0.025 / d` and the player has line of sight to the enderman (collider block context, no fluids; the test arguments scale the tolerance by distance and use the eye height position). The look-for-player goal (`NearestAttackableTargetGoal<Player>` with interval 10, line of sight ignored, range = the follow range 64, selector "being stared at or already angry at") picks the nearest player; on `start` it sets the stared-at flag false and arms a 5-tick timer; while it holds a target and the target is staring: `canContinueToUse` checks the selector; each tick if the enderman has no target but a candidate exists the timer counts down and then takes it; with a target: if the target is staring and within 4 blocks (`distanceToSqr < 16`), it teleports (random, 8.1); if the target is farther than 16 blocks (`distanceToSqr > 256`) for 30 consecutive ticks it teleports towards the target. The "stare" sets metadata 18 and plays the stare sound on the client when metadata 17 turns true (and every 400 ticks).
**Anger duration**: persistent anger time `rangeOfSeconds(20, 39)` (uniform 20 to 39 seconds, 400 to 780 ticks) on start; angry mobs keep the target until it ends (18 framework: universal anger).

**Daylight**: each server AI step, if it is bright outside, at least 600 ticks have passed since the target last changed (`tickCount >= targetChangeTime + 600`), the brightness at the enderman exceeds 0.5, the sky is visible and `nextFloat * 30 < (B - 0.4) * 2`, then the target is cleared and it teleports (randomly). This is not a burn: Endermen are not in `burn_in_daylight`.

**Random teleport** (`teleport()`): target position `(x + (nextDouble - 0.5) * 64, y + (nextInt(64) - 32), z + (nextDouble - 0.5) * 64)`, then `randomTeleport(..., true)`: clamp to the world border; if the chunk is loaded, walk down from the target y until the block below is one of tag `entities_can_teleport_to` (`blocks_motion`) or the world's bottom is reached; at the first y where the check passes (no collisions for the moved bounding box, no liquids in it, no block of tag `enderman_does_not_teleport_to` (`dangerous_for_teleportation`: fire, soul fire, lava cauldron, campfire, soul campfire, cactus, magma block, sweet berry bush, wither rose, pointed dripstone, powder snow; plus bedrock) among the blocks scanned, and the block below is not water) it moves, broadcasts entity event 46 and plays level event 2018 and the `enderman_teleport` sound at both ends; a riding enderman never teleports. `repeatedlyTryToTeleport` tries up to 64 times (stopping at the first success). **Teleport towards** an entity: `v = normalize(enderman.x - e.x, enderman.y + 0.5 - e.eyeY, enderman.z - e.z)` (note: enderman minus entity); the destination is `x = enderman.x + (nextDouble - 0.5) * 8 - v.x * 16`, `y = enderman.y + (nextInt(16) - 8) - v.y * 16`, `z = enderman.z + (nextDouble - 0.5) * 8 - v.z * 16` (draw order x, y, z), then `randomTeleport` as above (the destination is therefore 16 blocks from the enderman towards the entity, jittered).

**Damage reactions** (`hurtServer`): invulnerable-to check first; if the direct entity is a thrown potion item or the damage is tagged `is_projectile` (and the enderman is not riding): it tries up to 64 random teleports and the damage is ignored (returns false); a potion that hurts water-sensitive entities still hurts it normally; otherwise base hurt; and when the attacker is not a living entity, with probability 1/10 it teleports.

**Blocks**: take block (priority 11): usable when not carrying, the mob-griefing rule is true, and `nextInt(20) == 0` (reduced tick delay); on each run it picks a position `(x - 2 + nextDouble * 4, y + nextDouble * 3, z - 2 + nextDouble * 4)` (floored); if the block there is in tag `enderman_holdable` (small flowers, dirt, mud, moss blocks, grass blocks, sand, red sand, gravel, brown and red mushrooms, tnt, cactus, clay, pumpkin, carved pumpkin, melon, crimson and warped fungus, nylium and roots, cactus flower) and a ray from the enderman's block center to the target block center (outline block context, no fluids) hits exactly that block, the block is removed (game event `block_destroy`) and the enderman carries the block's default state. Leave block (priority 10): usable while carrying, mob griefing true, `nextInt(2000) == 0`; picks `(x - 1 + nextDouble * 2, y + nextDouble * 2, z - 1 + nextDouble * 2)` floored; places the carried block (state updated from neighbor shapes) if the target is air, the block below is not air, not bedrock, has a full collision shape, the carried state can survive there, and no entity intersects the unit cube (game event `block_place`). An enderman carrying a block never despawns (`requiresCustomPersistence`).

**Drops**: ender pearl `U(0..1)` + looting `U(0..1)`/level. Custom death loot: if it carries a block, the block's drops are rolled with a diamond axe enchanted with Silk Touch 1 (provider `enderman_loot_drop`) as the tool and spawned at the enderman. XP 5. Spawn rule `checkMonsterSpawnRules`. Category: monster; tracking 8; `notInPeaceful`.

### 8.2 Endermite

Entity `endermite`, id 43, 0.4 x 0.3, eye height 0.13 (read from the builder; passenger attachment (0, 0.2375, 0)). Attributes: max health 8, movement speed 0.25, attack damage 2.0. XP 3. Lifetime counter `Lifetime` (saved): a non-persistent endermite is discarded when the counter reaches 2400 ticks (the counter increments each tick; persistence required stops it). Goals: 1 float; 1 climb on top of powder snow; 2 melee (1.0, no unseen follow); 3 water-avoiding stroll (1.0); 7 look at player (8.0); 8 random look around. Targets: 1 hurt-by (not alerting); 2 `Player`. Member of `arthropod`, immune to powder-snow sinking (tag `powder_snow_walkable_mobs`). Spawn rule: `checkEndermiteSpawnRules` = any-light monster rules (standable block only) plus: unless a spawner, no player within 5 blocks of the position center (`getNearestPlayer(x+0.5, y+0.5, z+0.5, 5.0, true)` is null). Not in any biome list of this artifact: it appears via ender pearl teleport (the pearl is owned by 17) and spawners. No loot. Endermite has its single home here (21 §6.1 defers to this section); the ender pearl that creates endermites belongs to 17.

## 9. Silverfish and infested blocks

### 9.1 Silverfish

Entity `silverfish`, id 117, 0.4 x 0.3, eye height 0.13. Attributes: max health 8, movement speed 0.25, attack damage 1.0. XP 5. Member of `arthropod`, `powder_snow_walkable_mobs`, `immune_to_infested`. Movement emission "events" only (no step-sound events). Its body rotation follows its yaw. No loot table drops (empty table).
Goals: 1 float; 1 climb on top of powder snow; 3 wake-up-friends (the goal object is registered first with its own priority 3, run state controlled by its timer); 4 melee (1.0, no follow); 5 merge-with-stone. Targets: 1 hurt-by (no alerting of same-class mobs through this goal); 2 nearest `Player` (must see). Preferred walking: `getWalkTargetValue` returns 10.0 for positions whose block below is an infested host-compatible block.
**Hurt** (`hurtServer`): if the attacker exists or the damage type is in `always_triggers_silverfish` (`magic`), and the wake-up goal exists, tell it (`notifyHurt`: set its timer to 20 ticks).
**Wake-up friends** (timer decrements each tick while positive; when it reaches 0): scan offsets in the box x in [-10, 10], y in [-5, 5], z in [-10, 10] around the silverfish in an outward-expanding order (distance by layers); for each infested block found: if the mob-griefing rule is true, destroy the block with drops (spawning its silverfish via the infested block's break handling); otherwise replace it with its host block; after processing a block, with probability 1/2 the scan stops.
**Merge with stone** (priority 5, extends random stroll with speed 1.0, interval 10): usable when it has no target, its navigation is idle, the mob-griefing rule is true, and `nextInt(10) == 0` (reduced tick delay); it chooses a random direction and checks the block at `floor(x, y + 0.5, z)` relative in that direction; the goal is eligible only if that block is a host-compatible block. On start (if the host block is still compatible): replace it with the infested state of that host (`setBlockAndUpdate`), play `spawnAnim` and discard the silverfish.
**Spawn rule**: `checkSilverfishSpawnRules` = any-light monster rules (standable block) and, unless the reason is a spawner, no player within 5 blocks of the spawn position center. Silverfish are not in any biome spawn list of this artifact; they appear from infested blocks (9.2) and spawners.

### 9.2 Infested blocks

Block class `InfestedBlock` / `InfestedRotatedPillarBlock`: the host to infested map is: stone to `infested_stone`, cobblestone to `infested_cobblestone`, stone bricks to `infested_stone_bricks`, mossy stone bricks to `infested_mossy_stone_bricks`, cracked stone bricks to `infested_cracked_stone_bricks`, chiseled stone bricks to `infested_chiseled_stone_bricks`, deepslate to `infested_deepslate` (read from the `Blocks` constants; rotated state properties are copied between host and infested states). Properties: destroy time = half the host's destroy time, explosion resistance 0.75. When an infested block is broken with drops enabled (`spawnAfterBreak` with the `block_drops` rule on) and the tool lacks an enchantment of tag `prevents_infested_spawns` (`silk_touch`), a silverfish (spawn reason TRIGGERED) appears at `(x + 0.5, y, z + 0.5)` with the spawn animation. Infested blocks drop nothing themselves (loot tables of blocks are 18/other documents).

## 10. Slime

`AbstractCubeMob` (shared with Magma Cube, Sulfur Cube) extends `AgeableMob`. Entity `slime` (id 120): base size 0.52 x 0.52, eye 0.325, spawn dimension scale 4.0 (spawner preview); the size `n` scales it (`getDefaultDimensions` = base dimensions scaled by `n`).

| Property | Formula |
|---|---|
| Metadata | `AgeableMob` defines 16 baby flag (BOOLEAN) and 17 age-locked (BOOLEAN); the cube adds 18 `ID_SIZE` (INT, default 1) |
| Size range | 1 to 127 (clamped) |
| Max health | `size * size` |
| Movement speed | `0.2 + 0.1 * size` (set on every size change) |
| Attack damage | `size` (Slime); Magma Cube: attack damage `size` and armor `size * 3`; magma cube's melee adds +2 |
| XP | `size` |
| Save keys | `Size` = size - 1 (saved), `wasOnGround` |
| Natural size (`setSpawnSize`) | `t = nextInt(3)`; if `t < 2` and `nextFloat < 0.5 * specialMultiplier` then `t += 1`; `size = 1 << t` (1, 2 or 4) |
| Passenger point | `(0, height - 0.015625 * size * scale, 0)` |

Goals: 1 float (`CubeMobFloatGoal`: only when in liquid; each tick jumps with probability 0.8, wanted speed 1.2); 2 attack (`CubeMobAttackGoal`: needs a target that `canAttack`; runs while `300` ticks of "growTired" have not elapsed (300 reduced ticks, reset on start); looks at the target 10/10 and tells the move control the facing direction and "jump aggressively" when it can deal damage); 4 random direction (when no target and on ground or in liquid or levitating: every `40 + nextInt(60)` ticks picks a random yaw `nextInt(360)` for the move control); 5 keep on jumping (wants to move at speed 1.0 whenever it is not a passenger). Targets (Slime): 1 nearest `Player` (range check interval 10, must see) with a filter that the player's y difference is within 4 blocks (`|dy| <= 4`); 3 nearest `IronGolem` (must see).
**Move control**: yaw lerps towards the wanted yaw by at most 90 degrees per tick; when on ground it sets the movement speed to `speedModifier * movementSpeed`; the `jumpDelay` counter is reduced each tick; at 0 it resets to `10 + nextInt(20)` (divided by 3 with integer division when the mob is aggressive) and triggers a jump (jump velocity = the base jump power; Magma Cube adds `0.1 * size`), plus the jump sound (not when the size is 0).
**Damage**: `playerTouch` and `push` (colliding with a player or iron golem) call `dealDamage` if `canDealDamage` (Slime: not tiny, i.e. `size > 1`, and effective AI; Magma Cube: effective AI only, so size 1 magma cubes hurt): requires alive, team allows, within melee reach, line of sight; hurts for the `attack_damage` attribute (Magma Cube `+2` from its `getAttackDamage`), with the mob-attack damage source (3.1 scaling), plays the attack sound, applies post-attack enchantment effects.
**Split on death** (`remove` while dying with size > 1): count = `2 + nextInt(3)` (2 to 4). Let `w` = the dying slime's current width / 2 and `n = size / 2` (integer division; the new size). Child `i` (0-based) is created by "convertTo" with conversion type SPLIT_ON_DEATH (spawn reason TRIGGERED, team kept) at the parent position offset by `x += ((i % 2) - 0.5) * w`, `z += ((i / 2) - 0.5) * w` (with integer division `i / 2`), y + 0.5, a random yaw `nextFloat * 360`, size `n` with full health (`setSize(n, true)`).
Liquid: in lava a magma cube jumps with `+0.22 + 0.05 * size` y velocity (Nether, 21).
**Spawn rule** (`checkSlimeSpawnRules`): fails on Peaceful. A spawner reason goes straight to the standable-block test (3.4). Otherwise two alternatives are tried in order. (a) Surface alternative: the biome is in tag `allows_surface_slime_spawns` (`swamp`, `mangrove_swamp`), `50 < y < 70` (strict), `nextFloat() < ` the environment attribute `gameplay/surface_slime_spawn_chance` at the position, the raw brightness at the position `<= nextInt(8)`, and the standable test passes. The attribute comes from the `moon` timeline (clock `overworld`, period 192000 ticks, constant ease, "maximum" modifier): value 0.5 for ticks 0 to 23999 of the 192000 cycle (the full-moon day), then 0.375, 0.25, 0.125, 0.0 (new moon), 0.125, 0.25, 0.375 for the following 24000-tick blocks. (b) Slime-chunk alternative: the chunk test applies only when the level accessor is a `WorldGenLevel` (otherwise the chunk flag is false); the position's chunk `(x, z)` seeds `WorldgenRandom.seedSlimeChunk(chunkX, chunkZ, worldSeed, 987234911)` and `nextInt(10) == 0` marks it a slime chunk; then a fresh `nextInt(10) == 0` from the passed random, `y < 40` and the standable test. (`ServerLevel` implements `WorldGenLevel`, so the slime-chunk test applies to natural spawning; the level's seed is used.)
**Drops**: only size 1 drops: slime ball `U(0..2)` + looting, but exactly 1 when killed by a frog.

Size and other slimes' dimensions: `getDefaultDimensions` = entity dimensions scaled by size; `fixupDimensions` runs in the constructor.

## 11. Witch

| Property | Value |
|---|---|
| Entity | `witch`, id 148, 0.6 x 1.95, eye height 1.62; extends `Raider` (can be a raid member, never a leader) |
| Attributes | max health 26, movement speed 0.25 |
| Metadata | 16 celebrating (BOOLEAN, from Raider), 17 using item (BOOLEAN, false) |
| Damage | magic, indirect magic, sonic boom and thorns damage is multiplied by 0.15 (tag `witch_resistant_to`); damage from the witch itself is 0 |

Goals: 1 float; 2 ranged attack (speed 1.0, interval 60 ticks, radius 10.0); 2 water-avoiding stroll (1.0); 3 look at player (8.0); 3 random look around. Targets: 1 hurt-by (class `Raider`); 2 nearest healable raider (class `Raider`, must see, with the predicate "has an active raid and is not a witch"); 3 nearest attackable witch-target `Player` (interval 10, must see, need not reach). The healable-raider goal: random interval 500, must see; usable only when its cooldown is 0 or less, a `nextBoolean()` draw succeeds, the witch has an active raid and a target is found; `start` sets its cooldown to 200 (reduced) ticks. Each server `aiStep` decrements that cooldown by 1; the witch-target goal's `canAttack` is set to false while the cooldown is above 0 and true otherwise (the goal is `canAttack && base canUse`).
**Drinking** (server `aiStep`): while drinking, a counter of the item use runs; when it ends the using flag is cleared, the main hand is emptied, and, only if the drunk item is a potion, its effects are applied to the witch (scaled by the item's duration scale) with game event `drink`; the movement-speed modifier `drinking` (-0.25 add-value) is then removed. (The client's handling of entity event 15 spawns `10 + nextInt(35)` witch particles with gaussian spread 0.13 around x, the box's max y + 0.5 and z; client only.) When not drinking, one potion is chosen by four tests in this order; for each test the random draw (`nextFloat`) is taken first and the condition second, so a float is consumed at every check that is reached even when the condition then fails; the first test that succeeds decides: (1) eyes in water, no Water Breathing effect, and `nextFloat < 0.15`: Water Breathing; (2) on fire or last damage was fire, no Fire Resistance, `nextFloat < 0.15`: Fire Resistance; (3) health below max and `nextFloat < 0.05`: Healing; (4) `nextFloat < 0.5`, has a target, no Speed effect and the target farther than 11 blocks (`distanceToSqr > 121`): Swiftness. The potion is put in the main hand, the using flag set (duration = the potion's use duration), `witch_drink` sound (volume 1, pitch `0.8 + nextFloat * 0.4`), and the drinking modifier added (-0.25, add-value). After the drinking logic, with probability 0.00075 (`nextFloat < 7.5E-4`) per tick the witch broadcasts entity event 15 (witch particles).
**Throw** (`performRangedAttack`, not while drinking): aim at the target position plus its velocity: `dx = target.x + vel.x - witch.x`, `dy = target.eyeY - 1.1 - witch.y`, `dz` likewise; with horizontal distance `d`. Default potion Harming; if the target is a `Raider`: Healing when its health is at most 4, else Regeneration, and the witch's target is cleared; otherwise: if `d >= 8` and the target lacks Slowness: Slowness; else if the target's health is at least 8 and it lacks Poison: Poison; else if `d <= 3`, it lacks Weakness and `nextFloat < 0.25`: Weakness. A splash potion is thrown with the y component raised by `d * 0.2`, speed 0.45 when `d` is 2 or less else 0.75, inaccuracy 8.0, `witch_throw` sound (volume 1, pitch `0.8 + nextFloat * 0.4`). (`d <= 2` selecting 0.45 is inferred from the comparison direction.)
**Spawn**: `checkMonsterSpawnRules`; also forced spawns by swamp huts (19.2). `finalizeSpawn` (Raider): `canJoinRaid` is true unless the spawn reason is NATURAL. Witches cannot be raid captains. Drops: pool 1 rolls `U(1..3)` of: glowstone dust, sugar, spider eye, glass bottle, gunpowder (each weight 1), stick (weight 2); each stack `U(0..2)` + looting `U(0..1)`/level; pool 2: redstone `U(4..8)` + looting. XP 5.

## 12. Phantom

| Property | Value |
|---|---|
| Entity | `phantom`, id 100, base 0.9 x 0.5, eye 0.175; dimensions scaled by `1 + 0.15 * size`; category monster; tracking 8; in `burn_in_daylight`; `notInPeaceful`; immune to fall damage (tag `fall_damage_immune`) |
| Attributes | Monster defaults; `attack_damage` is set to `6 + size`; max health 20 |
| Metadata | 16 `size` (INT, default 0, clamped 0 to 64) |
| Save keys | `anchor_pos`, `size` |
| Flight | `travel` uses flying travel with friction 0.2; no climbing; checkFallDamage no-op; custom body control, look control and move control |
| XP / drops | XP 5; membrane `U(0..1)` + looting `U(0..1)`/level, only when killed by a player |

Phase state: `CIRCLE` or `SWOOP`; initial `CIRCLE`; `moveTargetPoint` initial (0, 0, 0); `anchorPoint` initial = spawn block + 5 up; `finalizeSpawn` sets `anchorPoint = blockPosition + (0, 5, 0)` and size 0.
Goals: 1 attack-strategy; 2 sweep-attack; 3 circle-around-anchor; target goal 1 attack-player-target. The `canAttack` of the phantom uses the default targeting conditions.
- **Attack strategy** (priority 1): usable when it has a target that passes `TargetingConditions.DEFAULT`; on start: next-sweep timer `adjustedTickDelay(10)`, phase CIRCLE, set the anchor above the target; every tick in CIRCLE the timer counts down; at 0: phase SWOOP, set the anchor above the target, timer `adjustedTickDelay((8 + nextInt(4)) * 20)`, sound `phantom_swoop` (volume 10, pitch `0.95 + nextFloat * 0.1`). On stop, only when `anchorPoint` is set: `anchorPoint` = the MOTION_BLOCKING heightmap position at the anchor's x and z, plus `10 + nextInt(20)` blocks up.
- **Set anchor above target**: returns immediately when `anchorPoint` is unset; otherwise `anchorPoint = target block + (0, 20 + nextInt(20), 0)`, and if its y is below sea level the anchor becomes `(x, seaLevel + 1, z)` of that anchor.
- **Circle around anchor** (priority 3, shares the "move to a point" base `PhantomMoveTargetGoal`): usable when it has no target (a target-less phantom circles its anchor) or the phase is CIRCLE. Fields: `distance`, `height`, `angle` (starts at 0, never set in `start`), `clockwise` (+1 or -1). On start: `distance = 5.0 + nextFloat * 10.0`; `height = -4.0 + nextFloat * 9.0`; `clockwise = +1` if `nextBoolean()` else -1 (the three draws in that order); then select the next point. Each tick, in this order: (a) with probability 1/350 (`nextInt(350) == 0`, tick-delay adjusted): `height = -4.0 + nextFloat * 9.0`; (b) with probability 1/250: `distance += 1`; if it is then above 15.0: `distance = 5.0` and `clockwise = -clockwise`; (c) with probability 1/450: `angle = nextFloat * 2 * pi` and select the next point; (d) if it is touching the move target (distance squared from the phantom to the move target point is below 4.0) select the next point; (e) if the move target's y is below the phantom's y and the block directly under the phantom's block is not empty: `height = max(1.0, height)` and select the next point; (f) if the move target's y is above the phantom's y and the block directly above its block is not empty: `height = min(-1.0, height)` and select the next point. **Select next point**: if `anchorPoint` is unset it becomes the phantom's block; `angle += clockwise * 15 degrees` (15 * 0.017453292 radians); the move target point becomes the anchor block's lower corner plus `(distance * cos(angle), -4.0 + height, distance * sin(angle))`.
- **Sweep attack** (priority 2): usable when it has a target and the phase is SWOOP. `canContinueToUse` is false when the target is null or dead, or is a spectator or creative player, or when `canUse` fails; otherwise, when `tickCount > catSearchTick`, it sets `catSearchTick = tickCount + 20`, scans cats within the box inflated by 16 (`ENTITY_STILL_ALIVE`), makes every cat found hiss, and sets `isScaredOfCat` to "any cat found"; it continues only while `isScaredOfCat` is false. `stop` sets the target to null and the phase to CIRCLE. Each tick: target point = (target.x, target.y at half its height, target.z); when the phantom's box inflated by 0.2 intersects the target's: hurt the target with the mob attack (`doHurtTarget`), phase CIRCLE, level event 1039 (unless silent); a swoop also ends in CIRCLE if the phantom has a horizontal collision or was hurt recently.
- **Attack player target** (target priority 1): `attackTargeting = forCombat().range(64)`; the scan counter starts at `reducedTickDelay(20)`; each `canUse` call with the counter above 0 decrements it and fails; at 0 it is reset to `reducedTickDelay(60)` and the goal queries `getNearbyPlayers(attackTargeting, phantom, box inflated by (16, 64, 16))`; the list is sorted by player `getY` descending (highest first); the first player for whom `phantom.canAttack(player, TargetingConditions.DEFAULT)` holds becomes the target and the goal starts. `canContinueToUse` re-checks `canAttack` with the DEFAULT conditions.
- **Move control** (`PhantomMoveControl`; its `speed` field starts at 0.1; it runs every tick with no operation check): (1) if the phantom has a horizontal collision: yaw `+= 180` and `speed = 0.1`. (2) `dx, dy, dz` = move target point minus the phantom's position; `h = sqrt(dx^2 + dz^2)`. (3) If `h > 0.00001` (absolute value): `f = 1 - |dy * 0.7| / h`; `dx *= f`, `dz *= f`; recompute `h = sqrt(dx^2 + dz^2)` and `d3 = sqrt(dx^2 + dz^2 + dy^2)` using the scaled `dx`, `dz`; then (steps 4 to 8; if `h` is not above the threshold nothing below runs). (4) Heading `= atan2(dz, dx)` converted to degrees with 57.295776 and wrapped; the current yaw plus 90 is wrapped; the new yaw is `approachDegrees(yaw + 90 wrapped, heading wrapped, 4.0) - 90` (at most 4 degrees per tick) and the body yaw is set to it. (5) If the absolute difference between the yaw before and after the turn is below 3.0 degrees: `speed = approach(speed, 1.8, 0.005 * (1.8 / speed))`; otherwise `speed = approach(speed, 0.2, 0.025)` (`approach(value, target, step)` moves value toward target by at most step without overshoot). (6) Pitch `= atan2(dy, h)` in degrees (the code computes `-(atan2(-dy, h) * 57.2957763671875)`). (7) With `a = yaw + 90` (degrees, new yaw): `vx = speed * cos(a) * |dx / d3|`, `vz = speed * sin(a) * |dz / d3|`, `vy = speed * sin(pitch in radians) * |dy / d3|`. (8) The velocity becomes `velocity + (Vec3(vx, vy, vz) - velocity) * 0.2`. Flight itself uses flying travel with friction 0.2 (table at the start of this section). Note the sign of `vy` follows the sign of the pitch, not of `dy`.

**Client-side `Phantom.tick`** (visual only; 12-client-rendering has no phantom entry): flap offset = `entityId * 3`; with `f = cos((offset + tickCount) * 7.448451 degrees + pi)` and `g` the same for `tickCount + 1`: when `f > 0` and `g <= 0` the `phantom_flap` sound plays locally (pitch and volume `0.95 + nextFloat * 0.05` each; hostile source). Two `mycelium` particles are spawned every tick at the phantom's x and z plus and minus `(cos(yaw) * width * 1.48, sin(yaw) * width * 1.48)` and at y plus `(0.3 + f * 0.45) * height * 2.5`. `TICKS_PER_FLAP` = `ceil(24.166098)` = 25 (`isFlapping` = `(offset + tickCount) % 25 == 0`).

**Spawning** (`PhantomSpawner.tick`, called every server tick for the Overworld with the spawn-enemies flag): requires the `spawn_phantoms` game rule. A counter `nextTick` is decremented each call; while it is above 0 the spawner returns. When it reaches 0 or below, it is increased by `(60 + nextInt(60)) * 20` ticks (1200 to 2379). The spawner returns when `getSkyDarken() < 5` and the dimension has skylight (so spawning proceeds only when the sky is dark enough, or in a dimension without skylight). Otherwise, for every non-spectator player in the level: if the dimension has skylight the player's block y must be at or above sea level and the block must see the sky; draw `nextFloat * 3` and require the effective difficulty at the player's position to be greater than it; read the player's `time_since_rest` statistic `r` (clamp to at least 1); require `nextInt(r) >= 72000` (so only players who have not slept for more than 72000 ticks can attract phantoms, with probability `1 - 72000 / r`); then the spawn position is the player's block + (up `20 + nextInt(15)`, east `-10 + nextInt(21)`, south `-10 + nextInt(21)`); the block and fluid there must be valid empty spawn blocks for phantoms (`NaturalSpawner.isValidEmptySpawnBlock`); then `count = 1 + nextInt(difficultyId + 1)` phantoms are created (spawn reason NATURAL), placed at that block with yaw and pitch 0, finalized, and added with passengers. (The effective-difficulty draw happens once per player before the rest check; the statistic is `time_since_rest`, its reset rules are in 13 or 18 framework: statistics and were not re-read here.)

## 13. Illagers, Ravager, Vex

All raiders extend `Raider` (extends `PatrollingMonster` extends `Monster`): evoker, pillager, ravager, vindicator, illusioner, witch (tag `raiders`). Illagers (`AbstractIllager`): evoker, illusioner, pillager, vindicator (tag `illager`; `illager_friends` = `#illager`). Illagers do not attack baby villagers (`canAttack` false for a baby `AbstractVillager`) and treat entities of tag `illager_friends` that have no team (or share the team) as allies.

**Raider base goals** (added by `Raider.registerGoals`, plus the patrol goal at priority 4 from `PatrollingMonster`: long-distance patrol, speeds 0.7 / 0.595): 1 obtain raid-leader banner; 3 pathfind to raid; 4 raider move-through-village (speed 1.05, can break doors `true`); 5 raider celebration. Metadata: 16 `IS_CELEBRATING` (BOOLEAN, false).
- **Obtain banner** (`Raider.pickUpItem`): a raider with an active raid picks up the ominous banner item only when the raid's current wave has no leader (`Raid.getLeader(wave)` is null). If its head slot already holds an item, that item is dropped when `max(nextFloat - 0.1, 0) < the head slot's drop chance`; the banner is worn, the raider becomes the wave's leader (`Raid.setLeader`) and a patrol leader. Any other item is handled by the normal pickup rules. Pillagers additionally collect items into their own inventory (13.2).
- **Pathfind to raid** (priority 3): usable when no target, no controlling passenger, has an active raid that is not over, and the raider is not in a village (`isVillage` at its position); each tick: every 20 ticks it may "recruit nearby" raiders (any `Raider` within 16 blocks that has no active raid and can join one: they join this raid's current wave); if not already path finding it picks a position towards the raid center (random position within 15 blocks horizontally, vertical 4, via `getPosTowards` angle 90 degrees) and moves at speed 1.0.
- **Raider.aiStep** (server, alive): if it has no raid and the game time is a multiple of 20, it looks up `getRaidAt(position)` and, when `Raids.canJoinRaid` allows (alive, `canJoinRaid` true, no-action time at most 2400), joins that raid at wave `groupsSpawned + 1`; when it already has a raid and its target is a `Player` or `IronGolem`, its no-action time is reset to 0. The join call passes the raid's current wave `groupsSpawned + 1`, no spawn position and `exists = true`. `Raider.hurtServer` refreshes the boss bar when it has an active raid. `die`: if it was the patrol leader and has a raid, the raid's leader entry for its wave is removed; if the killer is a player, that player is added to the raid's heroes of the village; then `removeFromRaid`.
- **Despawn and persistence**: a raider with a raid never despawns for distance and requires persistence (`requiresCustomPersistence`); without a raid, `PatrollingMonster.removeWhenFarAway` applies: a non-patrolling mob follows the normal rule (despawn when beyond the despawn distance), a patrolling one is removed only when its squared distance to the nearest player exceeds 16384 (128 blocks). The raid itself drops raiders that are far or idle (14.2).
- **Hold ground** (`Raider$HoldGroundAttackGoal(range)`, goal priority 2 for pillagers, 4 for vindicators; the range argument is 10.0 and the goal keeps `hostileRadiusSqr = range * range` = 100): usable when the raider has no current raid, is patrolling (`isPatrolling`), has a target, is not aggressive, and its last attacker is null or not a player. A "shout" targeting condition (non-combat, range 8.0, ignoring line of sight and invisibility) selects the raiders it shouts to. On start: stop the navigation and set the target of every raider within the box inflated by (8, 8, 8) that passes the shout condition to this raider's target. Each tick with a target: if the squared distance to the target is above `hostileRadiusSqr` it looks at the target (30/30) and with probability 1/50 plays its ambient sound; otherwise it sets itself aggressive. On stop (when it still has a target): every raider within that box that passes the shout condition gets this raider's target and is set aggressive; then this raider is set aggressive.
- **Celebration** (`RaiderCelebration`, priority 5): usable when the raider has a raid, is alive, has no target and the raid's status is LOSS. On start it sets the celebrating metadata true (false on stop). Each tick: if not silent, with probability 1/100 (adjusted) it plays its celebrate sound; if not a passenger, with probability 1/50 (adjusted) it jumps.
- **Captain**: a raider is a captain when its head item matches the ominous banner or when it is a patrol leader and has no raid-wave (so the captain test is true for banner wearers); loot tables use it (`is_captain`).
- **Patrol membership** (`PatrollingMonster`): save keys `patrol_target`, `PatrolLeader`, `Patrolling`. `finalizeSpawn`: when the reason is not PATROL, EVENT or STRUCTURE: with probability 0.06 the mob becomes patrol leader if `canBeLeader` (true except Witch false and Ravager false); a patrol leader gets the ominous banner on its head with drop chance 2.0; reason PATROL sets patrolling. `canJoinPatrol` true except when the raider has an active raid. Patrol find target: a position within +-500 blocks (offset `-500 + nextInt(1000)` per horizontal axis). Long-distance patrol goal (priority 4): usable when the game time is past its cooldown (-1 initial) and it is patrolling with no target, no controlling passenger, has a patrol target and no raid; the leader repaths when its navigation is done, companions within 16 blocks that can join are made to follow its patrol target; when within 10 blocks of the target it picks a new one (`nextInt` offsets); otherwise it walks a point 10 blocks ahead offset sideways by a 90 degree rotation scaled 0.4, height from the heightmap; if it cannot path it moves randomly within -8..+8 blocks (`moveRandomly`) and the cooldown becomes +200 ticks; `removeWhenFarAway` for patrollers: beyond 128 blocks from players.

### 13.1 Vindicator

| Property | Value |
|---|---|
| Entity | `vindicator`, id 144, 0.6 x 1.95 |
| Attributes | movement speed 0.35, follow range 12, max health 24, attack damage 5.0 |
| Save key | `Johnny` (boolean; also set when its custom name is "Johnny") |
| Goals | 0 float; 1 avoid `Creaking` (8.0, speeds 1.0 / 1.2); 2 break-door (priority 2, only with an active raid and with probability 1/10 per reduced tick; the break goal is built with break-time 6, which has no effect because the goal's break time is `max(240, that value)`; the difficulty predicate is true for Normal and Hard); 3 raider open door; 4 hold ground (10.0); 5 melee (1.0, no follow); 8 stroll (0.6); 9 look at player (3.0, probability 1.0); 10 look at mob (8.0) |
| Targets | 1 hurt-by (constructed with `Raider` as its class argument and an empty alert-others list; meaning in 18 framework); 2 `Player` (must see); 3 `AbstractVillager` (must see); 3 `IronGolem` (must see); 4 "Johnny" attack goal (`LivingEntity` targets, `attackable` selector, only when the Johnny flag is set) |
| Equipment | `populateDefaultEquipmentSlots`: if it has no raid, an iron axe in the main hand; with a raid, `applyRaidBuffs` gives the axe (14.4). `finalizeSpawn`: can open doors on its navigation, equipment and enchantments as 3.6 |
| Navigation | `customServerAiStep`: sets "can open doors" when ground navigation exists and the block is in a raided village (`isRaided`) |
| Drops | emerald `U(0..1)` + looting `U(0..1)`/level only when killed by a player; XP 5 |
| Spawn | `checkMonsterSpawnRules`, placement NO_RESTRICTIONS; raids and woodland mansion content (not traced) |

### 13.2 Pillager

| Property | Value |
|---|---|
| Entity | `pillager`, id 104, 0.6 x 1.95, `canSpawnFarFromPlayer` |
| Attributes | movement speed 0.35, max health 24, attack damage 5.0, follow range 32 |
| Metadata | 16 celebrating (from Raider); 17 charging crossbow (BOOLEAN, false) |
| Inventory | 5 slots (`SimpleContainer(5)`), saved with the entity; `canPickUpLoot` set true in `readAdditionalSaveData`; it picks up banner items only through the Raider rule and any item `wantsItem` accepts (when it has an active raid: only the white ominous banner) |
| Max group | `getMaxSpawnClusterSize` = 1 |
| Walk target value | 0 (no light preference) |
| Goals | 0 float; 1 avoid `Creaking` (8.0, 1.0, 1.2); 2 hold ground (10.0); 3 crossbow attack (`RangedCrossbowAttackGoal`, speed 1.0, radius 8.0 so squared 64; usable with a valid target and a crossbow in hand; it continues while the target is valid, (`canUse` or the navigation is not done) and a crossbow is held; `stop` clears aggressive, clears the mob's target, resets `seeTime` to 0 and, if the mob is using an item, stops it, clears the charging metadata and empties the item's charged projectiles; the goal never sets aggressive on start; per tick: `seeTime` as for the bow goal; it must approach when (squared distance above 64 or `seeTime < 5`) and `attackDelay == 0`: then every `updatePathDelay` (reset to a uniform 1 to 2 seconds, 20 to 40 ticks) it paths to the target at speed 1.0 when UNCHARGED and at half speed otherwise; when it need not approach it stops its navigation; it looks at the target (30/30). States: UNCHARGED: if it need not approach, starts using the crossbow, state CHARGING and the charging metadata (17) true; CHARGING: if no longer using the item it returns to UNCHARGED; when the use time reaches `CrossbowItem.getChargeDuration` (`floor(modifyCrossbowChargingTime(stack, mob, 1.25) * 20)`, 25 ticks without Quick Charge) it releases the item, state CHARGED, `attackDelay = 20 + nextInt(20)`, charging metadata false; CHARGED: `attackDelay` decrements, at 0 state READY_TO_ATTACK; READY_TO_ATTACK: when the target is in line of sight it shoots (`performRangedAttack(target, 1.0)` which calls `performCrossbowAttack` with arrow speed 1.6 and inaccuracy `14 - 4 * difficultyId`, then `onCrossbowAttackPerformed`) and returns to UNCHARGED; the Quick Charge modifier arithmetic is in `EnchantmentHelper` and was not read); 8 random stroll (0.6); 9 look at player (15.0, probability 1.0); 10 look at mob (15.0) |
| Targets | 1 hurt-by (constructed with `Raider` as its class argument and an empty alert-others list; meaning in 18 framework); 2 `Player` (must see); 3 `AbstractVillager` (need not see); 3 `IronGolem` (need not see) |
| Equipment | main hand crossbow; `enchantSpawnedWeapon`: base 3.6 chance, plus `nextInt(300) == 0` for the `pillager_spawn_crossbow` provider (Piercing 1) when holding a crossbow |
| Captain loot | if the pillager is a raid captain: an `ominous_bottle` with amplifier `U(0..4)` |
| XP | 5; spawn rule `checkPatrollingMonsterSpawnRules`: block light at the position must not exceed 8, then the any-light rules (standable block) |

### 13.3 Evoker

| Property | Value |
|---|---|
| Entity | `evoker`, id 47, 0.6 x 1.95 (extends `SpellcasterIllager`; XP 10) |
| Attributes | movement speed 0.5, follow range 12, max health 24 |
| Metadata | 16 celebrating; 17 spell casting (BYTE; value = spell id; 0 none) |
| Spell ids | 0 NONE, 1 SUMMON_VEX, 2 FANGS, 3 WOLOLO, 4 DISAPPEAR, 5 BLINDNESS (the RGB particle colors are client only) |
| Allies | counts its own vexes (a `Vex` whose root owner is the evoker) as allies |
| Goals | 0 float; 1 casting-spell (move and look flags; usable while `spellCastingTickCount > 0`; stops navigation; looks at the target or the wololo sheep with the max head turn limits); 2 avoid `Player` (8.0, 0.6, 1.0); 3 avoid `Creaking` (8.0, 0.6, 1.0); 4 summon-spell; 5 attack-spell; 6 wololo-spell; 8 random stroll (0.6); 9 look at player (3.0, 1.0); 10 look at mob (8.0). Targets: 1 hurt-by (constructed with `Raider` as its class argument and an empty alert-others list; meaning in 18 framework); 2 `Player` (must see, unseen memory 300 ticks); 3 `AbstractVillager` (need not see, 300); 3 `IronGolem` (need not see) |

Spell use goal (shared `SpellcasterUseSpellGoal`): usable when the target is alive, the caster is not already casting and `tickCount >= nextAttackTickCount`. On start: warm-up counter = `adjustedTickDelay(castWarmupTime)` (default 20; wololo 40), `spellCastingTickCount = castingTime`, `nextAttackTickCount = tickCount + castingInterval`, play the prepare sound, set the casting spell. Each tick: warm-up counter minus 1; at 0 the spell is performed and the cast sound plays. `customServerAiStep` decrements `spellCastingTickCount`. The goal continues while the target is alive and the warm-up counter is above 0.

| Spell | Casting time | Interval | Notes |
|---|---|---|---|
| Fangs | 40 | 100 | see below |
| Summon vex | 100 | 340 | only if the number of `Vex` within the box inflated by 16 around the evoker is below `1 + nextInt(8)` (a fresh draw each check) |
| Wololo | 60 | 140 (warm-up 40) | only with the mob-griefing rule true; a sheep of color blue within the box inflated by (16, 4, 16) is chosen at random; at cast, the sheep (if alive) becomes red; `canUse` also requires no target-less state: a target must exist |

**Fangs** (`EvokerFangs` entity id 48, 0.5 x 0.8): the evoker computes `minY = min(target.y, evoker.y)`, `maxY = max(target.y, evoker.y) + 1`, and `yaw = atan2(target.z - evoker.z, target.x - evoker.x)`. If the target is within 3 blocks (`distanceToSqr < 9`): 5 fangs on a ring of radius 1.5 at angles `yaw + i * pi * 0.4` (i 0 to 4), warm-up 0, then 8 fangs at radius 2.5 at angles `yaw + i * 2pi / 8 + 1.2566371` (72 degrees) (i 0 to 7), warm-up 3. Otherwise a line of 16 fangs at distance `1.25 * (i + 1)` along the yaw, warm-up `i` (i 0 to 15). Each fang column is placed on the highest suitable block between `minY` and `maxY` found by scanning down from `maxY` for a block with an upward-facing sturdy face below an empty or short-collision space (adding the collision shape height); if none, no fang. The fang entity: when its warm-up reaches -8 (the warm-up counter counts down below 0) it damages living entities within its box inflated by (0.2, 0, 0.2) for 6.0 damage, magic damage when it has no owner else indirect magic (not to allies of the owner; the owner itself is only skipped for the bite when allied); entity event 4 is sent at the end, and the entity is discarded after its life counter reaches zero.
**Summon vex**: 3 vexes (spawn reason MOB_SUMMONED), each at the evoker's block + `(-2 + nextInt(5), 1, -2 + nextInt(5))`, yaw 0, finalized, owner = the evoker, bound origin = that block position, limited life `20 * (30 + nextInt(90))` ticks, added to the evoker's scoreboard team if it has one, game event `entity_place`.
Drops: totem of undying (always); emerald `U(0..1)` + looting only when killed by a player. Spawn rule `checkMonsterSpawnRules`, placement NO_RESTRICTIONS.

### 13.4 Vex

| Property | Value |
|---|---|
| Entity | `vex`, id 142, 0.4 x 0.8, fire immune, eye height 0.51875, XP 3 |
| Attributes | max health 14, attack damage 4.0 |
| Metadata | 16 vex flags (BYTE; bit 0 charging) |
| Flight | no gravity once `tick` runs (it sets no-gravity each tick), custom move control (flying) |
| Life | when limited life is set (evokers do), `lifeTicks` decreases by 1 per tick and at 0 the vex takes 1 point of starvation damage every 20 ticks until it dies (read: `limitedLifeTicks` reset to 20 each time and a `starve` damage of 1.0) |
| Equipment | iron sword, main hand, drop chance 0 |
| Brightness | always treated as full brightness (`getLightLevelDependentMagicValue` = 1.0) |
| Save keys | `bound_pos`, `life_ticks`, `owner` |

Goals: 0 float; 4 charge attack (usable when it has a living target, the move control has no pending wish, a 1/7 draw (reduced) passes and it is more than 2 blocks away; starts charging: move to the target's eye position at speed 1.0, sets the charging flag, sound `vex_charge`; each tick: if its box meets the target's it hurts the target and clears charging, otherwise if within 3 blocks of the target it re-aims at the eye position); 8 random move (usable when no pending move and a 1/7 draw; up to 3 tries: bound origin (or own position) + `(-7 + nextInt(15), -5 + nextInt(11), -7 + nextInt(15))`, if that block is empty it moves there at speed 0.25 and, without a target, looks there); 9 look at player (3.0, 1.0); 10 look at mob (8.0). Targets: 1 hurt-by (constructed with `Raider` as its class argument and an empty alert-others list; meaning in 18 framework); 2 copy-owner-target (non-combat targeting conditions, not limited by sight; copies the owner's attack target); 3 `Player` (must see). `isAffectedByBlocks` only while not removed. Vexes ignore gravity, walk through nothing special, and collisions are normal. XP 3. Drops: none (empty loot table). Spawn: only via the evoker summon.

### 13.5 Illusioner

Entity `illusioner`, id 69, 0.6 x 1.95, XP 5; attributes movement speed 0.5, follow range 18, max health 32; no natural spawn in any list read. Goals: 0 float; 1 casting-spell; 3 avoid `Creaking` (8.0, 1.0, 1.2); 4 mirror spell; 5 blindness spell; 6 ranged bow attack (speed 0.5, interval 20, radius 15.0); 8 random stroll (0.6); 9 look at player (3.0, 1.0); 10 look at mob (8.0). Targets: 1 hurt-by (constructed with `Raider` as its class argument and an empty alert-others list; meaning in 18 framework); 2 `Player` (must see, unseen memory 300); 3 `AbstractVillager` (need not see, 300); 3 `IronGolem` (need not see, 300). `finalizeSpawn`: a bow in the main hand. Arrow: same as skeleton (speed 1.6; inaccuracy from the difficulty formula). Spells: mirror (disappear): usable when it lacks Invisibility; casting time 20, interval 340; applies Invisibility 1200 ticks to itself; blindness: usable when it has a target, the target's entity id differs from the last one it blinded (a remembered id, set at spell start) and the effective difficulty exceeds 2.0 (the Normal ordinal as a float); casting time 20, interval 180; applies Blindness 400 ticks to the target. While invisible the client shows displaced "illusion" copies (4 offsets recomputed every ~1200 ticks and when hurt; client-side, not specified here). No loot table drops (empty table).

### 13.6 Ravager

| Property | Value |
|---|---|
| Entity | `ravager`, id 112, 1.95 x 2.2, tracking 10, XP 20 |
| Attributes | max health 100, movement speed 0.3, knockback resistance 0.75, attack damage 12.0, attack knockback 1.5, follow range 32, step height 1.0 |
| Save keys | `AttackTick`, `StunTick`, `RoarTick` |
| Path type | `LEAVES` malus 0 (it walks through leaves) |
| Max head yaw | 45 |
| Goals | 0 float; 4 melee (1.0, follow unseen target true); 5 water-avoiding stroll (0.4); 6 look at player (6.0); 10 look at mob (8.0). Targets: 2 hurt-by (constructed with `Raider` as its class argument and an empty alert-others list; meaning in 18 framework); 3 `Player` (must see); 4 `AbstractVillager` (must see, a not-baby filter); 4 `IronGolem` (must see) |
| Control flags | when its controlling passenger is a mob of tag `raiders` and it is not in a boat, the passenger controls move, look, jump, target flags (the ravager's own goals yield) |

**Speed and leaves**: each tick its movement speed base value lerps by 0.1 towards 0.35 if it has a target else 0.3 (0 when immobile). With the mob-griefing rule true, a ravager with a horizontal collision destroys every leaves block inside its bounding box inflated by 0.2 (`destroyBlock` with drops) and jumps if it destroyed any (when on the ground).
**Attack**: `doHurtTarget` sets `AttackTick` to 10, broadcasts entity event 4 and plays the attack sound before the base melee hit (12.0 damage; shield hits: `blockedByItem` below).
**Stun/roar**: a hit blocked by a shield does anything only when `roarTick == 0`; then with probability 0.5 the ravager becomes stunned for 40 ticks (sound `ravager_stunned`, entity event 39) and pushes the blocker; otherwise it applies `strongKnockback` to the blocker (constant `0.5` branch read; the knockback scale is derived below). The ravager is immobile (base movement speed 0 and no line of sight) while stunned (`StunTick > 0`), while `AttackTick > 0` (10 ticks after each attack) or while `RoarTick > 0`; while stunned it emits stun particles each tick with probability 1/6; when the stun counter reaches 0 the `ravager_roar` sound plays and the roar countdown (`roarTick`) is set to 20; the countdown decreases each tick and at 10 the roar is performed: every living entity within the box inflated by 4 that passes the roar predicate (`ROAR_TARGET_WITH_GRIEFING` when mob griefing is true, `ROAR_TARGET_WITHOUT_GRIEFING` otherwise; both exclude other Ravagers and dead entities, and the without-griefing predicate also excludes armor stands) is affected: entities that are not illagers take mob-attack damage 6.0; every such entity that is not a player, illagers included, gets `strongKnockback`; the game event `entity_action` and entity event 69 follow (the client applies the same knockback to players).
**strongKnockback(e)**: `dx = e.x - ravager.x`, `dz = e.z - ravager.z`, `n = max(dx*dx + dz*dz, 0.001)` (the squared distance, not its root); `e.push(dx / n * 4.0, 0.2, dz / n * 4.0)` (so the horizontal push has magnitude `4 / distance`).
**Raid use**: `canBeLeader` false; `applyRaidBuffs` none; it is the mount of an illager in specific waves (14.4). Drops: a saddle (count 1). Spawn rule `checkMonsterSpawnRules`, placement ON_GROUND, no liquid in its bounding box (`checkSpawnObstruction`).

## 14. Raid system and patrols

### 14.1 Patrols (`PatrolSpawner.tick`, Overworld, per server tick)

Requires the `spawn_patrols` game rule. A counter `nextTick` is decremented each call and while above 0 the spawner returns. When it reaches 0 or below it increases by `12000 + nextInt(1200)` ticks. Then: it must be bright outside (`isBrightOutside`, daytime); `nextInt(5) == 0` must pass; at least 1 player must exist; pick one player at random; a spectator ends the attempt; a player within 2 chunks-of-village distance (`isCloseToVillage(pos, 2)`: false when the argument exceeds 6, otherwise true when the POI manager's section distance from the position's section to the nearest village is at most 2 sections; `isVillage(pos)` is the same test with 1) ends the attempt; offsets: `x = (24 + nextInt(24)) * (+1 or -1 by nextBoolean)`, `z` likewise; the position is the player's block moved by `(x, 0, z)`; all chunks within +-10 blocks of that position must be loaded; the environment attribute `can_pillager_patrol_spawn` must be true at the position (in the early game timeline: false for the first 120000 game ticks (100 minutes), true afterwards, "and"-combined; biome `mushroom_fields` sets it false); the member count is `ceil(effectiveDifficulty at the position) + 1`; for each member `i` the y is set to the MOTION_BLOCKING_NO_LEAVES heightmap and `spawnPatrolMember(leader = i == 0)` is tried (stop at the first failure), then x and z are moved by `nextInt(5) - nextInt(5)` each. `spawnPatrolMember` needs `isValidEmptySpawnBlock` for a pillager, `checkPatrollingMonsterSpawnRules` (13.2), creates a pillager (spawn reason PATROL), makes it patrol leader when requested (and calls `findPatrolTarget`), places it, finalizes (reason PATROL) and adds it with passengers.

### 14.2 Raid lifecycle (`Raid`, `Raids`)

State: status ONGOING, VICTORY, LOSS, STOPPED; `started`, `active`, `groupsSpawned` (waves spawned so far), `raidCooldownTicks` (initial 300), `ticksActive`, `postRaidTicks`, `raidOmenLevel` (max 5), `totalHealth`, per-wave raider sets, per-wave leader, heroes-of-the-village set, a boss bar (red, notched 10, name "Raid", with " - Victory"/"Defeat" or "N raiders remaining" when 2 or fewer remain), center position, `waveSpawnPos`.
Number of waves by difficulty: Peaceful 0, Easy 3, Normal 5, Hard 7. A bonus wave exists when `raidOmenLevel > 1` (`hasBonusWave`) and is the wave after the final one.

**Starting**: Bad Omen comes from consuming an ominous bottle (the pillager captain drop): the item's amplifier component (`ominous_bottle_amplifier`, integer 0 to 4, default 0 on the item; the captain drop sets `U(0..4)`) is applied on consumption as Bad Omen for 120000 ticks at that amplifier (flags read as false, false, true: ambient, particles, icon); the bottle itself plays the `ominous_bottle_dispose` sound after consumption. `BadOmenMobEffect.applyEffectTick` (each tick): if the player is a server player, not a spectator, the difficulty is not Peaceful and the player's block is in a village (`isVillage`): if a raid exists at that position and its omen level is already at the maximum (5) nothing happens (the effect stays); otherwise the player gets Raid Omen for 600 ticks, `raidOmenPosition` is stored, and the Bad Omen effect ends (the method returns false). `RaidOmenMobEffect` acts when the effect has exactly 1 tick left: if the entity is a server player, not a spectator, with a stored raid omen position: `Raids.createOrExtendRaid(player, position)`, then the stored position is cleared. `createOrExtendRaid` returns nothing when the player is a spectator, the `raids` game rule is false, or the environment attribute `can_start_raid` is false at the player's position. Otherwise: the point-of-interest manager returns occupied POIs of POI type tag `village` within 64 blocks of the position; the raid center is the average (sum / count) of their block positions, or the position itself when there are none; `getOrCreateRaid(level, center)` returns the raid at that center or a new one; when the raid has not started and is not yet in the manager it is added under a new unique id; when the raid has not started or its omen level is below the maximum, `absorbRaidOmen(player)` runs and the manager is marked dirty. `absorbRaidOmen` returns false when the player has no Raid Omen effect; otherwise `raidOmenLevel = clamp(raidOmenLevel + amplifier + 1, 0, 5)` where `amplifier` is the player's Raid Omen amplifier, and if the first wave has not yet spawned the `raid_trigger` statistic and the raid-omen advancement trigger are awarded to the player.
**Raids.tick** (each tick): each raid is ticked unless the `raids` game rule is false (then it is stopped and removed when stopped); the manager is marked dirty every 200 ticks.

**Raid.tick** (while status is ONGOING; the checks run in this order): the raid is "active" while its center chunk is loaded; Peaceful stops it (status STOPPED) and ends the tick; an inactive raid does nothing further (the boss bar visibility follows `active`). If the center is not a village: it is moved by `moveRaidCenterToNearbyVillageSection` (the nearest, by squared distance to the old center, village section within the cube of radius 2 sections around the center's section; its center becomes the new center), and if the center is still not a village the status becomes LOSS when `groupsSpawned > 0`, else the raid stops. `ticksActive` then increments; at 48000 the raid stops and the tick ends. Then, when no raiders are alive and more waves remain (`hasMoreWaves`: a bonus wave exists and has not spawned, or the final wave has not been reached): if `raidCooldownTicks > 0`: when `waveSpawnPos` is absent every 5th cooldown value (or when it is present but not entity-ticking) it is recomputed with `getValidSpawnPos`; players are refreshed when the cooldown is 300 or divisible by 20; the cooldown decreases by 1; the boss bar progress becomes `clamp((300 - cooldown) / 300, 0, 1)`; execution then continues to the wave-spawn check below in the same tick (so the tick on which the cooldown reaches 0 can spawn). If the cooldown is 0 and `groupsSpawned > 0` it is set back to 300, the bar name reset to "Raid" and the tick ends (this is the pause after a wave has been cleared). On every tick not ended by the cases above, when `ticksActive % 20 == 0`: players are refreshed, raiders are refreshed (below), and the boss bar name shows the raid name followed by an "N raiders remaining" text when between 1 and 2 raiders are alive, else just the raid name. **Raider refresh** (`updateRaiders`): for every raider of every wave: it is marked for removal from the raid when it is removed, or in another dimension, or the squared distance between the raid center and its block is at least 12544 (112 blocks); otherwise, if its `tickCount` is at most 600 the remaining checks are skipped for it; otherwise it is marked if its UUID no longer resolves to a level entity; then, if its block is not in a village and its no-action time is above 2400, its `ticksOutsideRaid` is incremented by 1 (it is never reset here); and it is marked when `ticksOutsideRaid >= 30`. Marked raiders are removed from the raid (`removeFromRaid(raider, true)`), and a removed patrol leader also clears its wave's leader entry. **Wave spawning** (each tick, a loop with a failure counter starting at 0): while `shouldSpawnGroup` holds, namely `raidCooldownTicks == 0`, no raiders are alive, and (`groupsSpawned < numGroups`, or the bonus-group condition: the final wave has been reached, no raiders alive, and the raid has a bonus wave): take `waveSpawnPos` or a new `getValidSpawnPos`; if a position exists: `started = true`, `spawnGroup`, and on the first success of this call `playSound` (horn) is called; if no position exists the failure counter is incremented, and when it is above 5 (the 6th consecutive failed search) the raid stops. The same condition applies to ordinary and bonus waves. **Horn** (`playSound(level, pos)`): constants 13.0 and 64; one random long is drawn per call as the sound seed; for each player in the level: `d` = horizontal distance between the player and the block center of `pos` (x and z only); the packet is sent when `d <= 64` or the player is in the boss-bar player set; it is a `raid_horn` sound, neutral source, volume 64.0, pitch 1.0, at x = `player.x + 13 / d * (pos.x + 0.5 - player.x)`, z likewise, y = the player's own y. **Victory**: after the first wave has spawned (`started`), when no more waves remain and no raiders are alive, `postRaidTicks` counts up to 40; then the status becomes VICTORY and every hero of the village (players recorded by `addHeroOfTheVillage` that are still alive entities, living and not spectators) gets Hero of the Village for 48000 ticks with amplifier `raidOmenLevel - 1` (constructor flags read as false, false, true: ambient, particles, icon), the `raid_win` statistic and the raid-win advancement. **After the raid is over** (VICTORY or LOSS): each tick `celebrationTicks` increments; at 600 the raid stops; every 20 celebration ticks players are refreshed, the boss bar is made visible and (victory) its progress is set to 0 and its name to the raid-bar victory component, or (loss) its name to the raid-bar defeat component (the component strings were not read).

**Valid spawn position** (`getValidSpawnPos` calls `findRandomSpawnPos(level, 8)`): let `n = raidCooldownTicks / 20` (integer division) and `f = 0.22 * n - 0.24` (as a float). Choose a start angle `nextFloat * 2 pi`. For attempt `i` from 0 to 7: angle `a = start + pi * i / 8`; `x = center.x + floor(cos(a) * 32 * f) + nextInt(3) * floor(f)`, `z = center.z + floor(sin(a) * 32 * f) + nextInt(3) * floor(f)` (the two `nextInt(3)` draws happen in that order, x first); `y` = the WORLD_SURFACE height at `(x, z)`. Reject the attempt if `|y - center.y| > 96`; reject if the position is in a village and `n > 7`; reject if any chunk in the box +-10 blocks around is not loaded; reject if the position is not entity-ticking. Accept when the ravager's spawn placement type accepts the position, or when the block below is snow and the block at the position is air. The first accepted position is returned; if none, no position. At cooldown 300 (`n = 15`) `f = 3.06`, so positions lie about 98 blocks out; the radius shrinks as the countdown falls, and for `n = 0` `f` is negative, which mirrors the offsets through the center (a consequence of the formula as read).

### 14.3 Wave composition (`spawnGroup`, `Raid$RaiderType`)

A raid spawns wave number `w = groupsSpawned + 1` (read directly; the bonus wave is therefore `w = numGroups + 1`). `spawnGroup` first resets `totalHealth` to 0, computes the difficulty instance at the spawn position and evaluates the bonus-group condition once. For each raider type in the order vindicator, evoker, pillager, witch, ravager: `count = default[type][index] + bonus(type)`, where `index = w` for an ordinary wave and `index = numGroups(difficulty)` for the bonus wave (the flag is the bonus-group condition evaluated once at the start of the call: the final wave has been reached, no raiders are alive, and a bonus wave exists). Default spawns per wave (`spawnsPerWaveBeforeBonus`, indices 0 to 7; wave number = index):

| Type | w0 | w1 | w2 | w3 | w4 | w5 | w6 | w7 |
|---|---|---|---|---|---|---|---|---|
| Vindicator | 0 | 0 | 2 | 0 | 1 | 4 | 2 | 5 |
| Evoker | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 2 |
| Pillager | 0 | 4 | 3 | 3 | 4 | 4 | 4 | 2 |
| Witch | 0 | 0 | 0 | 0 | 3 | 0 | 0 | 1 |
| Ravager | 0 | 0 | 0 | 1 | 0 | 1 | 0 | 2 |

(Easy raids use waves 1 to 3, Normal 1 to 5, Hard 1 to 7.) **Bonus count** `bonus(type)`: let `max` be: for Vindicator and Pillager: Easy `nextInt(2)` (a first draw), Normal 1, Hard 2; for Witch: 0 on Easy or when the wave is 1, 2 or 4, else 1; for Ravager: 1 if the difficulty is not Easy and this is the bonus group, else 0; Evoker 0. If `max > 0` the bonus is `nextInt(max + 1)` (a second draw), else 0. (The Witch rule is: not Easy, `w > 2` and `w != 4`, with `w` the wave number above, so on Normal the bonus wave `w = 6` can add a witch; the Ravager rule uses the same bonus-group flag as the table index; the two random draws are in the order stated.)
For each of the `count` raiders of a type: create it (spawn reason EVENT; if creation fails the rest of that type is skipped); if no leader has been chosen yet *within this `spawnGroup` call* (a local flag that persists across the raider types; the raid's recorded leaders of earlier waves play no part) and the raider can be a leader, it becomes the wave's leader (`setPatrolLeader`, `setLeader`: the wave's leader is recorded, the ominous banner placed on its head with drop chance 2.0); `joinRaid(wave, raider, spawnPos, false)` (the first call with `exists = false` applies position, finalize with reason EVENT, raid buffs, on-ground and adds it with passengers). For a ravager (a counter of ravagers created in this call is kept; it increments after every ravager, with or without a rider): a rider is created: if `w == 5` (`getNumGroups(NORMAL)`, the value is 5 on every difficulty) a pillager; else if `w >= 7` (`getNumGroups(HARD)`): the first ravager of the call (counter 0) gets an evoker, later ravagers a vindicator. Consequences: on Normal the bonus wave (`w = 6`) gets no rider; on Hard the bonus wave (`w = 8`) gets evoker and vindicator riders; on Easy (waves 1 to 3, bonus `w = 4`) no ravager has a rider; on Hard wave 5 ravagers carry pillagers; the rider joins the raid, is snapped to the ravager's position (yaw and pitch 0) and starts riding. After the loop `waveSpawnPos` is cleared, `groupsSpawned++`, the boss bar and the saved data are updated.
**Raid buffs** (`applyRaidBuffs(level, wave, isLeader)`): `enchantOdds` by raid omen level: 2 gives 0.1, 3 gives 0.25, 4 gives 0.5, 5 gives 0.75, any other level 0 (so a raid with omen level 1 never enchants). Vindicator: always holds an iron axe; if `nextFloat <= enchantOdds` (the comparison is "random below odds" as read from `ifgt`) the axe is enchanted with provider `raid/vindicator` (Sharpness 1) when the wave is at most the Normal wave count (5), else `raid/vindicator_post_wave_5` (Sharpness 2); main hand set to it. Pillager: crossbow; same odds; provider `raid/pillager_post_wave_5` (Quick Charge 2) when the wave is above 5, else `raid/pillager_post_wave_3` (Quick Charge 1) when the wave is above 3 (Easy wave count), else none. Evoker, Witch, Ravager, Illusioner: none.
Raiders' boss bar health counts: `totalHealth` is the sum of raider health added when they join; the bar progress is `clamp(sum of living raiders' health / totalHealth, 0, 1)`.

## 15. Warden

| Property | Value |
|---|---|
| Entity | `warden`, id 146, 0.9 x 2.9 (while digging or emerging the dimensions are fixed to width x 1.0), passenger attachment height 3.15, chest attachment (0, 1.6, 0), tracking range 16, fire immune |
| Attributes | max health 500, movement speed 0.3, knockback resistance 1.0, attack knockback 1.5, attack damage 30, follow range 24 |
| Metadata | 16 `CLIENT_ANGER_LEVEL` (INT, default 0; the active anger value of the current target, synced every 20 ticks) |
| Other | XP 5; cannot ride; `removeWhenFarAway` false; dampens vibrations (`dampensVibrations`); pushing and explosions ignored while digging/emerging; invulnerable while digging or emerging (except damage that bypasses invulnerability); shield disable time 5 seconds; path costs: DAMAGING, POWDER_SNOW and LAVA 8.0; UNPASSABLE_RAIL, FIRE, FIRE_IN_NEIGHBOR 0; can float; `getWalkTargetValue` 0 |
| Brain | Warden brain (not goals); activities CORE (always: swim 0.8, look at target sink, move to target sink), EMERGE, DIG, IDLE, ROAR, FIGHT, INVESTIGATE, SNIFF; choice order: emerge, dig, roar, fight, investigate, sniff, idle (first valid) |
| Save keys | `anger`, `listener` (vibration listener state) |

**Anger** (`AngerManagement`): per-entity anger values (max 150, clamp on increase); `getActiveAnger(target)`; levels by the sum for the top suspect: CALM below 40, AGITATED 40 to 79, ANGRY 80 and above (`AngerLevel` minimum anger 0, 40, 80). The manager is ticked every 20 server ticks (`tickCount % 20`): conversion of stored UUIDs to entities runs every 2 ticks, each stored anger value is reduced by 1 per tick of the manager (`DEFAULT_ANGER_DECREASE 1`), values of 1 or less (or of removed/invalid entities) are dropped. Increments seen: hurt by a living attacker: `ANGRY minimum (80) + 20` = 100, without a sound; vibration from an entity: 35 (with the warden's listening reaction); touching an entity (`doPush`, with a 20-tick touch cooldown): 35; starting a roar: 20 (no sound). `increaseAngerAt(entity)` = 35. When `hurtServer` hurts the warden and it has no attack target, and the attacker is a living entity at a direct hit or within 5 blocks, it sets it as the attack target (erasing the roar target, resetting the cant-reach memory and setting the sonic boom cooldown to 200 ticks). `canTargetEntity`: living, in the same level, not creative or spectator, not allied, not an armor stand or another warden, not invulnerable, not dying, inside the world border.
**Darkness**: every `120` ticks offset by the entity id (`(id + tickCount) % 120 == 0`) it applies the Darkness effect (duration 260 ticks) to all players within 20 blocks (`applyDarknessAround(position, source, 20)`: effect Darkness amplifier 0 without particles, duration 260; the helper's last argument 200 is the constant `DARKNESS_DISPLAY_LIMIT`). 
**Vibrations**: the listener radius is 16 blocks; the listenable events are the game event tag `warden_can_listen`; it ignores vibrations when no-AI, dying, in vibration cooldown, digging/emerging or out of the world border, and, when the source is a living entity, if `canTargetEntity` fails. On receiving a vibration (`onReceiveVibration`, ignored when dying): the `vibration_cooldown` memory is set for 40 ticks, entity event 61 (tendril) is broadcast, the `tendril_clicks` sound plays (volume 5.0). If the vibration has a projectile owner entity: when that owner is within 30 blocks of the warden, then: if the `recent_projectile` memory is present, `increaseAngerAt(owner)` (35, with sound) is called unconditionally, else (memory absent) `increaseAngerAt(owner, 10, true)`; after that (whether or not the owner was within 30 blocks) the `recent_projectile` memory is set for 100 ticks. If there is no projectile owner: `increaseAngerAt(sourceEntity)` (35, with sound). Afterwards the disturbance location is set only when the warden's anger level is not ANGRY and (a projectile owner exists, or the anger manager has no active entity, or the active entity is the source entity): the location is `WardenAi.setDisturbanceLocation(warden, position)` where, in the projectile case, `position` is the owner's block position when `canTargetEntity(owner)` holds and the vibration's position otherwise, and in the other case the vibration's position. `setDisturbanceLocation` (investigate): the location expires after 100 ticks; it sets the sniff cooldown to 100 ticks, the look target for 100 ticks and clears the walk target; it does nothing when the warden has a target angry at it, and sets the dig cooldown when it already has an attack target. **`increaseAngerAt(entity, amount, playSound)`**: ignored when no-AI or `canTargetEntity` fails; otherwise sets the dig cooldown (1200 ticks), remembers whether the current target is not a player, adds `amount` to the entity's anger (capped at 150), and if the entity is a player, the warden's previous target was not a player and the resulting level is ANGRY, the attack target memory is erased (so the warden switches to the player); then plays the listening sound when `playSound`.
**Brain constants**: speeds: idle stroll 0.5, investigating 0.7, fighting 1.2; melee attack cooldown 18 ticks; digging duration 100, emerging 134 (133.6 rounded up with `Mth.ceil`), roar 84, sniff 84 (83.2 rounded up); dig cooldown 1200 ticks after losing the target; after spawning (`finalizeSpawn`) the dig cooldown memory is set for 1200 ticks, and for spawn reason TRIGGERED (sculk shrieker) the pose is EMERGING and the emerging memory lasts the emerge duration; agitated sound. Idle: `SetRoarTarget` first (priority 10); a stroll at speed 0.5 or a pause of 30 to 60 ticks (random one of); `TryToSniff`. Fight: stop attacking if the target is invalid (then clear anger and set the dig cooldown), look at the target, walk to the target at 1.2 when out of reach, **sonic boom**, melee (cooldown 18). Roar: roar behaviour (anger +20 on the roar target, `ROARING` pose, roar sound delayed 25 ticks). Sniff (`Sniffing` behaviour, duration 84, needs IS_SNIFFING present, no attack target and no walk target): on start plays `warden_sniff` (volume 5.0); on stop returns to the STANDING pose (if SNIFFING), clears IS_SNIFFING, and if the `nearest_attackable` memory holds an entity that passes `canTargetEntity`: when that entity is within 6 blocks horizontally and 20 vertically it calls `increaseAngerAt` (35), and if the warden has no `disturbance_location` memory it sets one at that entity's block. Setting the roar target belongs to the `SetRoarTarget` step (idle activity priority 10, investigate and sniff activities priority 5).
**Melee**: `doHurtTarget`: entity event 4, `attack_impact` sound, sets the sonic boom cooldown to 40 ticks, then the base melee (30 damage, knockback 1.5 with the target's resistance).
**Sonic boom** (`SonicBoom` behaviour): usable when the target is within 15 blocks horizontally and 20 vertically (`closerThan(target, 15.0, 20.0)`) and the sonic boom cooldown memory is absent. Total duration 60 ticks; the charge sound plays at start (volume 3.0) with entity event 62; at tick 34 of the behaviour (the sound delay memory expires) the boom fires: `SONIC_BOOM` particles at one-block steps along the line from the warden's chest (the `WARDEN_CHEST` attachment, (0, 1.6, 0)) to the target's eye (one particle at each step `i` from 1 up to `floor(length) + 6`, positioned `chest + normalized direction * i`), the boom sound (volume 3.0), the target takes 10.0 sonic-boom damage (`sonicBoom` damage source; ignores armor per the damage type data, which is not re-read here) and, only when the damage call returns true, the target's velocity is increased by the normalised direction vector (warden chest to target eye) multiplied component-wise: x and z by `2.5 * (1 - knockbackResistance)`, y by `0.5 * (1 - knockbackResistance)`. After the behaviour stops the cooldown is 40 ticks.
**Spawning** (the warden has no biome spawn entry): sculk shrieker block entity: a shriek (when the block detects a vibration from a player: `tryShriek`, requires the block not already shrieking and `canRespond`) sets the `shrieking` state for 90 ticks (schedules a tick), plays level event 3007 and emits the `shriek` game event; `tryToWarn` consults the `WardenSpawnTracker`: warning level 0 to 4 (maximum 4), increase cooldown 200 ticks, the level decreases every 12000 ticks, players within 16 blocks are considered, and the warning check area is a 48-block box (`WARNING_CHECK_DIAMETER`); when the shrieking ends (`preRemoveSideEffects` while shrieking, i.e. the scheduled tick) `tryRespond` plays warning sounds by level (random position within +-10 blocks, volume 5.0) and applies Darkness 40 blocks around; if the warning level reached 4 and a warden is allowed (`canRespond`: the block state `can_summon` true, difficulty not Peaceful, the `spawn_wardens` game rule) it tries 20 times to spawn a warden (spawn reason TRIGGERED) at random positions within +-5 blocks horizontally and +-6 vertically of the shrieker (strategy: on top of a collider) and succeeds on the first valid one.
**Drops**: one sculk catalyst (unconditional, count 1); no looting. XP 5. Tendril and heart animations (`getTendrilAnimation`, heartbeat delay `40 - floor(clamp(angerLevel / 80, 0, 1) * 30)`) are client details.

## 16. Breeze

| Property | Value |
|---|---|
| Entity | `breeze`, id 17, 0.6 x 1.77, eye 1.3452, tracking 10, `notInPeaceful`, fall damage immune, in `deflects_projectiles` |
| Attributes (extends `Monster`, uses `Mob` base) | movement speed 0.63, max health 30, follow range 24, attack damage 3.0 |
| Other | XP 10; max head yaw 30, head rotation speed 25; path costs ON_TOP_OF_TRAPDOOR and FIRE -1 (avoid); invulnerable to damage from other breezes; can attack only players and iron golems (`canAttack` rule); fluid jump threshold = eye height; movement emission events only |
| Brain | activities CORE (swim 0.8, look-at-target sink 45/90), IDLE, FIGHT (default activity FIGHT); `updateActivity` chooses FIGHT if valid else IDLE |

Idle activity (run in order): start attacking (nearest attackable memory, then the hurt-by memory), slide-to-target sink (wait 20 to 40 ticks between slides; speed 0.6), then random pause 20 to 100 ticks or stroll at 0.6. Fight activity (first valid, in priority order 0 to 4): stop attacking when the target has not been attackable for 100 ticks (`StopAttackingIfTargetInvalid` with memory 100); 1 **shoot**; 2 **long jump**; 3 shoot-when-stuck; 4 **slide**; requires an attack target and no walk target.
**Shoot**: starts only when the breeze is STANDING, has an attack target, and the squared distance between the breeze's position and the target's position is below 256 (16 blocks); when the test fails the `breeze_shoot` memory is erased. Timings (ticks): charging/inhale 15 (`SHOOT_INITIAL_DELAY`), recovery 4 (`SHOOT_RECOVER_DELAY`), cooldown 10 (`SHOOT_COOLDOWN`); sound `breeze_inhale` at start, pose SHOOTING. After the charge it fires one **breeze wind charge** (entity `breeze_wind_charge`, id 18, 0.3125 cube): direction `(target.x - breeze.x, targetY - firingY, target.z - breeze.z)` with `targetY = target.getY(0.8 if the target is a passenger else 0.3)` and `firingY = breeze.y + height / 2 + 0.3`; speed 0.7; inaccuracy `5 - difficultyId * 4` (Easy 1, Normal -3, Hard -7; the spread of `Projectile.shoot` (below) is symmetric, so a negative value gives a spread of its absolute value: 1, 3 and 7); sound `breeze_shoot` (volume 1.5). Wind charge damage and knockback: wind charge entity behaviour (18 framework: projectiles; not traced here).
**Long jump**: usable when the breeze is on the ground and not in water or (deep) fluid, the jump target memory exists or can be found: not out of aggro range (follow range 24 squared test), not too close (`distance - 4 > 0`), the current position can jump (4 air blocks above, not on honey); the target point is a random point behind the target (`randomPointBehindTarget`) snapped to the surface (10-block vertical rays), not above a dangerous block and with line of sight within 50 blocks; the jump vector comes from a shuffled list of allowed angles (degrees 40, 55, 60, 75, 80), max velocity `followRange * 0.058333334` (default 1.4) with Jump Boost scaling; inhaling takes 10 ticks (pose INHALING then LONG_JUMPING); cooldown 10 ticks (2 when hurt). Emits jump-trail particles (client).
**Slide**: when on the ground, not in water and STANDING: if the target is within the inner circle (4 blocks) it picks a point 5 blocks away (`getPosAway`, 5, 5) that has line of sight and is farther from the target; else a random point behind the target or in the middle circle (radius lerp between 4 and 8); walk target set at speed 0.6. Circle radii: inner 4, middle 8, outer 24.
**Drops**: breeze rod `U(1..2)` + looting `U(1..2)` per level, only when killed by a player. Spawn: no biome list entry; the spawn check is the generic monster rule (`checkMonsterSpawnRules`); in practice trial spawners and structures (not traced).

## 17. Creaking

| Property | Value |
|---|---|
| Entity | `creaking`, id 31, 0.9 x 2.7, eye 2.3, tracking 8, `notInPeaceful` |
| Attributes | max health 1.0, movement speed 0.4, attack damage 3.0, follow range 32, step height 1.0625 |
| Metadata | 16 `CAN_MOVE` (BOOLEAN, default true), 17 `IS_ACTIVE` (BOOLEAN, false), 18 `IS_TEARING_DOWN` (BOOLEAN, false), 19 `HOME_POS` (OPTIONAL_BLOCK_POS, absent) |
| XP | 0; no loot table drops (empty table) |
| Save key | `home_pos` |

Brain with sensors `NEAREST_LIVING_ENTITIES`, `NEAREST_PLAYERS`: CORE (a swim variant with 0.8, look-at-target sink 45/90, move-to-target sink), IDLE (start attacking; look at a random entity (range 8.0) every 30 to 60 ticks (uniform); one of: stroll at 0.3 (weight 2), walk towards the look target at 0.3 within 3 blocks (weight 2), pause 30 to 60 ticks (weight 1)), FIGHT (walk towards the attack target at speed 1.0 when out of reach, melee with cooldown 40 ticks, stop attacking when the target is invalid; requires an attack target). `updateActivity`: when it cannot move the default activity is used; otherwise FIGHT if valid else IDLE. Attack: `doHurtTarget` broadcasts entity event 4 (the constant 15 appears in that method, probably the attack animation counter). The target is reachable while some visible attackable player exists.
**Freezing when watched**: `checkCanMove` (each server tick): nearest players list; if the creaking is active and no player is near it deactivates; for each player that `canAttack` and is not allied: when the player does not wear a carved pumpkin and `isLookingAtMe(creaking, tolerance 0.5, no distance scaling, visual obstruction, y samples at the eye and body)` and the player is within 12 blocks (`distanceToSqr < 144`): it becomes active (activated) and `CAN_MOVE` false; when no such player exists `CAN_MOVE` true. While `CAN_MOVE` is false it cannot be pushed or knocked back and does not walk. Activation also depends on the environment attribute `gameplay/creaking_active` (timeline `day`: true from tick 12600 until 23401 of the day cycle, `or`-combined; the creaking heart block reads the same attribute to switch between AWAKE and DORMANT).
**Heart binding**: a creaking spawned by a creaking heart block (`spawnProtector`, spawn reason SPAWNER, up to 5 attempts within +-16 horizontally and +-8 vertically, ON_TOP_OF_COLLIDER_NO_LEAVES; then `setTransient(home block)` and entity event 60) has a home position, cannot use portals, is not fire immune, and dies (health set to 0 in its `tick`) when its heart no longer lists it as its protector. Constants of the heart block entity: player detection range 32, roaming radius 32, "too far" distance 34, update ticks 20 (+ variance 5), hurt-call sequence of 10 calls every 10 ticks over 100 ticks, particles 50 ticks; a spread-resin step traverses at most 64 blocks to depth 2. Damage to a heart-bound creaking is redirected through the heart (`creakingHurt`, resin effects); damage that bypasses invulnerability still works. On death a heart-bound creaking runs a 45-tick teardown (`IS_TEARING_DOWN`) before it is removed. Walk target value 0. The path node evaluator for a home-bound creaking treats positions farther than 32 blocks (distance squared 1024) from home as BLOCKED. Creakings are in the `creaking` list of avoid-goals of illagers (13). Natural spawning: not through biome lists in this artifact (`pale_garden` lists only the common monsters); `SpawnPlacements` registers `checkMonsterSpawnRules` for it.

## 18. Giant, Sulfur Cube, and mobs owned elsewhere

### 18.1 Giant

Entity `giant`, id 60, 3.6 x 12.0, eye 10.44, riding offset -3.75, tracking 10, `notInPeaceful`. Attributes: max health 100, movement speed 0.5, attack damage 50, camera distance 16. No goals or targets are registered (inert), walk target value uses the light-cost rule, XP 5 (default). Empty loot table. Spawn check: `checkMonsterSpawnRules`; not in any biome list (summon only).

### 18.2 Sulfur cube (native to the `sulfur_caves` biome)

Entity `sulfur_cube`, id 133, 0.49 x 0.49 at size 1 (size scaling as in section 10; its spawn dimension scale is 2.0, the slime's is 4.0), eye 0.175, tracking 10, category monster. Class `SulfurCube` extends `AbstractCubeMob`, so size, health `size^2`, speed `0.2 + 0.1 * size`, jumping, move control and split-on-death of section 10 apply, with these changes: it never deals contact damage (`canDealDamage` false), has no target goals (`addTargetingGoals` empty), is always treated as full brightness (`getLightLevelDependentMagicValue` 1.0), has attributes `Mob` base plus `tempt_range` 8.0 (not the monster set), its spawn predicate `checkSulfurCubeSpawnRules` is always true, and `getSplitCount` returns 2 (instead of 2 + `nextInt(3)`), or 0 while primed (an exploding cube never splits). Its max health and its attack-damage setting follow `AbstractCubeMob.setSize` (no attack-damage or armor override was found). Biome entry: `sulfur_caves` only (weight 100, count 2 to 4). Loot table `sulfur_cube`: empty. Metadata after the cube size (18): 19 `MAX_FUSE` (INT, default -1) and 20 `FROM_BUCKET` (BOOLEAN, default false) (declaration order; `defineSynchedData` calls them in the other order, which does not change the indices).
**Size**: `MIN_SIZE` 1, `MAX_SIZE` 2, `SPLIT_COUNT` 2, `PICKUP_TIMER_DURATION` 100. `setSpawnSize` gives size 1 for a baby and size 2 otherwise (full health, `setSize(n, true)`); `setSize(1, true)` makes a non-baby cube a baby, so size 1 is the baby form (and the section 10 spawn-size draw does not apply). The cube is not in the `notInPeaceful` list (it stays in Peaceful). Save keys: `pickup_timer`, `from_bucket`, `fuse` (default -1), plus the bucket item's `age` and `age_locked`. Other constants read in the class (uses not traced): push distance threshold 1.3, player push speed cap 0.5, player push scale 0.3, vehicle push scale 0.16, vertical push multiplier 0.3, hit angle scales 1.6 (horizontal), 0.5 (vertical), position angle scale 0.8, extra knockback dampening 0.25.
**Goals**: `registerGoals` is the cube's (float priority 1, random direction 4, keep jumping 5) plus `addBehaviourGoals`: 2 tempt (`SulfurCubeTemptGoal`, speed 1.0; an item in tag `sulfur_cube_food` = `slime_ball`; it looks at the holder with 10/10 limits and keeps the move control facing it, stopping the wanted movement when not following), 3 search for items (`SulfurCubeSearchForItemsGoal`: usable when not a baby and a nearby `ItemEntity` matching `ALLOWED_ITEMS` exists within the box inflated by 8; it looks at the nearest such item). When the cube holds a body item, `collectEquipmentChanges` removes all goals and sets its speed to 0 (it becomes inert; while it holds a body item its step height is 0, it cannot freeze, it can breathe underwater (otherwise it uses the cube's rule), it counts as an "omnidirectional air mover" for movement, and it can be leashed only in that state), and `registerGoals` is run again when the body slot becomes empty.
**Swallowing**: items of tag `sulfur_cube_swallowable` (the union of the archetype item tags listed below) go to the BODY equipment slot: via `pickUpItem` (an item entity it can hold: one item is split off, absorb sound, guaranteed drop on death, `take`), or via `equipItem` when a player gives one (a non-baby cube replaces and drops its current body item at its passenger attachment point, plays the absorb sound). **Shearing** (`mobInteract` with shears while it holds a body item): the body item is dropped at the passenger attachment point and the eject sound plays, the shears are damaged by 1 (`shear` also contains the constant 100, whose use was not traced). **Feeding**: a baby fed `slime_ball` ages up (`isFood`, `canAgeUp`).
**Archetype selection** (`matchingArchetypes`): all archetypes (registry `sulfur_cube_archetype`) whose item tag contains the body item; on a body change the previous archetypes' attribute modifiers are removed and the new ones applied (modifier ids `<archetype>_add_...` / `<archetype>_mul_...`); the cube is buoyant if any matching archetype is buoyant; the explosion data, contact-damage list, knockback modifiers and sound settings come from the matching archetypes (defaults when none). Per archetype (values read from `data/minecraft/sulfur_cube_archetype/*.json`; modifier operations: knockback resistance, explosion knockback resistance and bounciness are `add_value`, friction modifier and air drag modifier are `add_multiplied_total`; sounds are `entity.sulfur_cube.<archetype>.hit` and `.push`; the push sound plays at most every cooldown seconds when the impulse exceeds the threshold):

| Archetype | Attribute modifiers (knockback resistance, explosion knockback resistance, bounciness, friction modifier, air drag modifier) | Buoyant | Explosion | Contact damage | Knockback h / v | Sound cooldown / threshold |
|---|---|---|---|---|---|---|
| bouncy | -2, -2, 0.9, -0.7, -0.99 | yes | - | - | 0.4125 / 0.105 | 0.7 / 0.3 |
| explosive | -1, -1, 0.5, -0.7, -0.7 | yes | power 3, fuse 120, fire false | - | 0.4125 / 0.09 | 0.7 / 0.1 |
| fast_flat | -1, -1, 0.5, -0.8, -0.99 | no | - | - | 0.9125 / 0.09 | 0.9 / 0.03 |
| fast_sliding | 0.5, 0.5, 0.1, -0.95, -0.99 | no | - | - | 0.6625 / 0.09 | 1.0 / 0.05 |
| high_resistance | 0.7, 0.7, 0.2, 0, -0.99 | no | - | - | 0.4125 / 0.09 | 0.7 / 0.03 |
| hot | -1, -1, 0.5, -0.7, -0.9 | yes | - | 1.0 `sulfur_cube_hot` | 0.4125 / 0.09 | 0.7 / 0.2 |
| light | -1, -1, 1, -0.7, 0.8 | yes | - | - | 0.4125 / 0.18 | 0.7 / 0.2 |
| regular | -1, -1, 0.5, -0.7, -0.9 | yes | - | - | 0.4125 / 0.09 | 0.5 / 0.2 |
| slow_bouncy | 0.4, 0.4, 0.6, -0.7, -0.95 | no | - | - | 0.4125 / 0.24 | 0.5 / 0.05 |
| slow_flat | 0.5, 0.5, 0.4, -0.6, -0.9 | no | - | - | 0.4125 / 0.105 | 0.9 / 0.03 |
| slow_sliding | 0.8, 0.8, 0.1, -0.95, -0.99 | no | - | - | 0.4125 / 0.09 | 1.0 / 0.02 |
| sticky | -2, -2, 0, 1, -0.99 | no | - | - | 0.4125 / 0.09 | 0.5 / 0.05 |

Item tags per archetype (`tags/item/sulfur_cube_archetype/*`): bouncy = `#planks`, `bamboo_mosaic`, `#logs`, `#bamboo_blocks`; explosive = `tnt`; hot = `magma_block`; light = `#wool`; sticky = `honeycomb_block`; fast_sliding = `blue_ice`, `packed_ice`, `snow_block`; high_resistance = `soul_sand`, `soul_soil`; slow_sliding = `brown_mushroom_block`, `red_mushroom_block`, `mushroom_stem`, `mycelium`, `#wart_blocks`, `shroomlight`; regular = `#concrete_powders`, `mud`, `muddy_mangrove_roots`, `packed_mud`, `coal_block`, `dirt`, `coarse_dirt`, `rooted_dirt`, `podzol`, `grass_block`, `clay`, `bone_block`; fast_flat = coral blocks (live and dead), `sponge`, `wet_sponge`, `dried_kelp_block`, `#moss_blocks`, resin blocks and bricks, `melon`, `hay_block`, `pumpkin`, `carved_pumpkin`, `jack_o_lantern`, the three froglights; slow_flat = iron, gold, copper (all weathering and waxed variants, cut, chiseled and bulb variants), raw metal blocks, `netherite_block`, `ancient_debris`, `#gold_ores`, `#iron_ores`, `#copper_ores`; slow_bouncy = the long list of stone-like blocks (stone family, deepslate and tuff families, bricks, sandstone, quartz, prismarine, blackstone, nether bricks, obsidian, glowstone, end stone, purpur, sea lantern, redstone lamp, observer, gem blocks, the sulfur and cinnabar blocks, nylium, `#concrete`, terracotta and glazed terracotta, and the coal, lapis, redstone, diamond, emerald ores; the full list is in the tag file).
**Explosion** (`explosive` archetype, fuse 120, power 3, no fire): `primeTime(shortFuse)` works only when the cube has explosion data, is alive, on the server, the `tnt_explodes` rule is true and it is not already primed: fuse = the archetype's fuse, or `PrimedTnt.getRandomShortFuse(random, fuse)` when the call comes from an explosion; it becomes permanently invulnerable, `setFuse` and the `MAX_FUSE` metadata are set, `tnt_primed` sounds and the `prime_fuse` game event follow. Triggers: a hit by fire damage (damage type tag `is_fire`) or by a burning arrow primes with the normal fuse; a hit by explosion damage (`is_explosion`) primes with the short fuse; right-clicking with flint and steel or a fire charge primes (item damaged or consumed, `item_used` statistic; when `tnt_explodes` is false the player gets the "tnt disabled" overlay message and nothing happens); standing on a block with a redstone signal (`getBestOwnOrNeighbourSignal` above 0 at its block, checked every tick by `primeWhenOnPoweredPosition`) primes with the normal fuse. While it holds a body item, damage whose type is in `sulfur_cube_with_block_immune_to` is ignored, and other damage still applies default knockback (unless the type is tagged `no_knockback`). Each tick the fuse counts down while positive; at 0 (explosion data present): the leash drops, the `dead` flag is set, and if `tnt_explodes` is true it explodes at `(x, y + 0.0625, z)` with the archetype power and fire flag and interaction `TNT` when mob griefing is true else `NONE` (the portal-used damage calculator when it has a portal cooldown), then death mob effects trigger and it is discarded. **Hot** archetype: `applyContactDamage` hurts nearby entities with 1.0 damage of type `sulfur_cube_hot` (`applyContactDamage(entity)` is called from `doPush(entity)` and from `playerPush` (reached via `playerTouch`), for every contact-damage entry of the matching archetypes; the damage source is built from the entry's damage type with a causing entity chosen by the attribute-to-source flag and whether the touched entity is a player (the exact choice was read only as a branch shape); the amount is sampled from a float provider (a constant 1.0 for `hot`)). The effect of the `bounciness`, `friction_modifier` and `air_drag_modifier` attributes on movement and of the knockback modifiers on pushes were not traced. Bucket: `sulfur_cube_bucket` (save keys `age`, `age_locked`; picking up needs a `bucket`); persistence is required while it holds a body item or came from a bucket.

### 18.3 Owned elsewhere

- Wither skeleton, magma cube, zombified piglin, blaze, ghast, hoglin, zoglin, piglin, piglin brute, strider: Nether (21).
- Guardian, elder guardian, shulker, ender dragon, wither: not in scope here (21).
- Zombie horse (id 155), skeleton horse (id 119), zombie nautilus (id 156), camel husk (id 20): mounts. Zombie horse appears in `plains`-type biome lists (weight 5, group 1); zombie nautilus appears as a drowned jockey mount (4.5). Their behaviour: zombie horse and skeleton horse 19 §3.6, camel husk 19 §3.8, zombie nautilus 21 §4.10. Loot tables read: `zombie_nautilus`: rotten flesh `U(0..3)` + looting `U(0..1)`/level only when killed by a player.

## 19. Spawn tables

### 19.1 Biome monster lists (`gameplay/natural_mob_spawns` attribute, `spawns_by_category.monster`; all entries are `weight`, `count` (the group size: the maximum group; a range means uniform integer inclusive))

The attribute modifier mode written in the biome files read is `overlay` (that it replaces the default category entries is inferred). The 67 biome files fall into these monster lists (entries `type weight x count`):

| List | Biomes | Entries |
|---|---|---|
| A (default surface/underground) | badlands, beach, birch_forest, cherry_grove, dappled_forest, dark_forest, eroded_badlands, flower_forest, forest, frozen_peaks, grove, jagged_peaks, lush_caves, meadow, old_growth_birch_forest, old_growth_spruce_taiga, pale_garden, snowy_beach, snowy_slopes, snowy_taiga, sparse_jungle, stony_peaks, stony_shore, taiga, windswept_forest, windswept_gravelly_hills, windswept_hills, wooded_badlands | spider 100 x 4; zombie 95 x 4; zombie_villager 5 x 1; skeleton 100 x 4; creeper 100 x 4; slime 100 x 4; enderman 10 x 1-4; witch 5 x 1 |
| B (oceans) | cold_ocean, deep_cold_ocean, deep_frozen_ocean, deep_lukewarm_ocean, deep_ocean, frozen_ocean, lukewarm_ocean, ocean | list A plus drowned 5 x 1 |
| B2 | warm_ocean | list B in a different order (drowned 5 x 1 first); same contents as B |
| C (plains-like) | plains, savanna, savanna_plateau, sunflower_plains, windswept_savanna | spider 100 x 4; zombie 90 x 4; zombie_villager 5 x 1; zombie_horse 5 x 1; skeleton 100 x 4; creeper 100 x 4; slime 100 x 4; enderman 10 x 1-4; witch 5 x 1 |
| D | mangrove_swamp, swamp | spider 100 x 4; zombie 95 x 4; zombie_villager 5 x 1; skeleton 70 x 4; creeper 100 x 4; slime 100 x 4; enderman 10 x 1-4; witch 5 x 1; slime 1 x 1; bogged 30 x 4 |
| E | bamboo_jungle | list A plus ocelot 2 x 1 |
| F | jungle | list A plus ocelot 2 x 1-3 |
| G | desert | spider 100 x 4; zombie 19 x 4; zombie_villager 1 x 1; skeleton 50 x 4; creeper 100 x 4; slime 100 x 4; enderman 10 x 1-4; witch 5 x 1; husk 80 x 4; parched 50 x 4 |
| H | dripstone_caves | list A plus drowned 95 x 4 |
| I | frozen_river | list A plus drowned 1 x 1 |
| J | river | list A plus drowned 100 x 1 |
| K | ice_spikes | spider 100 x 4; zombie 95 x 4; zombie_villager 5 x 1; skeleton 20 x 4; creeper 100 x 4; slime 100 x 4; enderman 10 x 1-4; witch 5 x 1; stray 80 x 4 |
| L | snowy_plains | spider 100 x 4; zombie 90 x 4; zombie_villager 5 x 1; zombie_horse 5 x 1; skeleton 20 x 4; creeper 100 x 4; slime 100 x 4; enderman 10 x 1-4; witch 5 x 1; stray 80 x 4 |
| M | old_growth_pine_taiga | spider 100 x 4; zombie 100 x 4; zombie_villager 25 x 1; skeleton 100 x 4; creeper 100 x 4; slime 100 x 4; enderman 10 x 1-4; witch 5 x 1 |
| N | sulfur_caves | sulfur_cube 100 x 2-4; creeper 50 x 2; skeleton 50 x 2; slime 25 x 1; cave_spider 20 x 1; zombie 50 x 2; enderman 10 x 1; witch 1 x 1; zombie_villager 5 x 1 |
| O (none) | deep_dark, mushroom_fields, the_void | no monsters |
| Nether and End lists | basalt_deltas, crimson_forest, nether_wastes, soul_sand_valley, warped_forest, end_*, small_end_islands, the_end | 21 (the End lists contain enderman 10 x 4; `nether_wastes` has enderman 1 x 4) |

Spawn costs (energy budget, charge): only `soul_sand_valley` and `warped_forest` (Nether, 21). The monster category: max 70 per level cap factor, despawn distance 128, no-despawn distance 32, not friendly, not persistent (the `MobCategory` constants read: MONSTER max 70, CREATURE 10, AMBIENT 15, water ambient 20); the natural spawning loop, group placement, and caps are 18 framework: natural spawning. A monster-type spawn entry's "count" is the maximum group size (the minimum is 1 unless a range is given; the group-size draw method is 18 framework).

### 19.2 Structure-bound spawns (`spawn_overrides`, category monster)

| Structure | Bounding box | Entry | Notes |
|---|---|---|---|
| `pillager_outpost` | whole structure ("full") | pillager 1 x 1 | the structure's monster list replaces the biome list inside it |
| `swamp_hut` | per piece | witch 1 x 1 | also cat 1 x 1 in the creature category |
| `fortress`, `monument` | | Nether blaze/etc., guardian | 21 |
| `trial_chambers` | | empty lists in every category | no natural spawning inside |
| `mineshaft`, `mineshaft_mesa` | | none | cave spiders there come from block-entity spawners (not read) |

### 19.3 Spawn predicates (per entity type)

| Predicate | Types |
|---|---|
| `checkMonsterSpawnRules` (3.3, 3.4) | bogged, cave spider, creeper, enderman, giant, skeleton, spider, witch, zombie, zombie villager, zombie horse, evoker, illusioner, vindicator, vex, ravager, warden, creaking, breeze (the generic one), wither skeleton, wither |
| `checkSurfaceMonstersSpawnRules` | husk, parched, camel husk |
| `checkAnyLightMonsterSpawnRules` family | silverfish (with the 5-block player test), endermite (same), pillager (`checkPatrollingMonsterSpawnRules`) |
| `checkDrownedSpawnRules` | drowned (4.5) |
| `checkSlimeSpawnRules` | slime (10) |
| `checkStraySpawnRules` | stray (5) |
| always true | sulfur cube |

Placement type and heightmap are in 3.4. Phantoms are not placed by the natural spawner; see 12.

### 19.4 Despawning

`Mob.checkDespawn` (18 framework: despawning): in Peaceful, a type that is not allowed in Peaceful is discarded at each check. The types built with `notInPeaceful` (read from the builders) are: blaze, bogged, breeze, cave spider, creaking, creeper, drowned, elder guardian, enderman, endermite, evoker, ghast, giant, guardian, hoglin, husk, illusioner, magma cube, parched, phantom, piglin brute, pillager, ravager, silverfish, skeleton, slime, spider, stray, vex, vindicator, warden, witch, wither, wither skeleton, zoglin, zombie, zombie villager, zombified piglin; `sulfur_cube`, `zombie_horse`, `zombie_nautilus` and `camel_husk` are not on the list. Otherwise, when a player exists, with the nearest player at distance `d`: for a mob that is not persistent and does not require custom persistence: if `d^2 > 128^2` (the monster category's despawn distance) and `removeWhenFarAway` is true it is discarded (the check then continues); then, if its no-action counter is above 600, `nextInt(800) == 0` is drawn (only for such non-persistent mobs, whenever the counter exceeds 600 and before the distance test) and if it succeeds and `d^2 > 32^2` (the no-despawn distance) and `removeWhenFarAway`, it is discarded; and for every mob (persistent ones included) when `d^2 < 32^2` the counter is reset to 0. Overridden `removeWhenFarAway`: Warden false; zombie villager false while converting; raiders with a raid false; a patrolling `PatrollingMonster` true only beyond 128 blocks (16384 squared); `requiresCustomPersistence` adds carrying-block endermen, raiders with a raid, converting mobs and body-item sulfur cubes.

## 20. Worked examples

### 20.1 Creeper blast damage to a player

Creeper (power 3, not charged): `2R = 6`. Player on Normal at 2 blocks (feet to center), fully exposed (`seen = 1`): `dist = 2 / 6 = 0.3333`, `s = 0.6667`, damage `= (0.6667^2 + 0.6667) / 2 * 7 * 6 + 1 = 24.33`; scaled by difficulty (3.1): Easy 13.17, Normal 24.33, Hard 36.5 (before armor). Knockback strength `0.6667 * 1 * (1 - 0) = 0.6667` along the direction from the center to the player's eye.
Other distances (exposure 1, Normal): 0 blocks 43.0; 1 block 33.08; 3 blocks 16.75; 5 blocks 5.083 (strength 0.1667); 6 blocks 1.0 (strength 0); beyond 6 blocks nothing.
Charged creeper (power 6, `2R = 12`) at 2 blocks: `dist = 0.1667`, `s = 0.8333`, damage `65.17` (Easy 33.58, Hard 97.75); at 6 blocks: 32.5 (strength 0.5); the radius reaches 12 blocks.
Exposure: a player half behind a wall with `seen = 0.5` at 2 blocks from a normal creeper: `s = 0.3333`, damage `(0.1111 + 0.3333)/2 * 42 + 1 = 10.33`.

### 20.2 Slime splitting

A natural slime is size 1, 2 or 4. Size 4: 16 health, speed 0.6, attack damage 4, XP 4. On death it spawns 2 to 4 size-2 slimes (each: health 4, speed 0.4, attack 2, XP 2); each size-2 slime on death spawns 2 to 4 size-1 slimes (health 1, speed 0.3, attack-damage attribute 1 but it deals no contact damage because tiny slimes cannot deal damage, XP 1; the only ones that drop slime balls, `U(0..2)` + looting). Minimum total descendants (counting all spawned): 2 + 2*2 = 6; maximum 4 + 4*4 = 20 (16 size-1 slimes at the end). Child `i` offsets: with parent width `w` (size 4 -> 2.08) and `w/2 = 1.04`: children at `((i % 2) - 0.5) * 1.04` in x and `((i / 2) - 0.5) * 1.04` in z: `(-0.52, -0.52)`, `(+0.52, -0.52)`, `(-0.52, +0.52)`, `(+0.52, +0.52)` for i = 0 to 3, y + 0.5. Spawn-size probabilities: with special multiplier 0 (effective difficulty below 2): size 1 with 1/3, 2 with 1/3, 4 with 1/3; with multiplier 1: `nextInt(3)` of 0 or 1 is bumped with probability 0.5: size 1 with probability 1/6, size 2 with 1/3, size 4 with 1/2 (the draw 0 or 1 is bumped up by one with probability 0.5 each; 2 stays).

### 20.3 Raid wave composition (Normal difficulty, 5 waves, omen level 1)

| Wave | Pillager | Vindicator | Evoker | Witch | Ravager | Riders |
|---|---|---|---|---|---|---|
| 1 | 4 | 0 | 0 | 0 | 0 | |
| 2 | 3 | 2 | 0 | 0 | 0 | |
| 3 | 3 | 0 | 0 | 0 | 1 | |
| 4 | 4 | 1 | 0 | 3 | 0 | |
| 5 | 4 | 4 | 1 | 0 | 1 | +1 pillager on the ravager (wave 5 = Normal's wave count) |

plus the bonus draws for each of vindicator, pillager (`nextInt(1 + 1)`: 0 or 1 each; Normal max is 1) and for the witch from wave 3 on except wave 4 (0 or 1 for waves 3, 5): for example wave 5 spawns 4 + (0..1) pillagers, 4 + (0..1) vindicators, 1 evoker, a witch (0..1) and 1 ravager with a pillager rider: base 10 raiders + 1 rider = 11 mobs (up to 14 with all bonuses). The first raider created (a vindicator, or a pillager if none) that can lead becomes the wave leader with the banner. Easy (3 waves): wave 3 gets the table's wave-3 row plus Easy bonuses (vindicator and pillager `nextInt(1 + nextInt(2))`, witch none); Hard (7 waves): waves 6 and 7 use columns w6 and w7: wave 7 = 2 pillagers, 5 vindicators, 2 evokers, 1 witch, 2 ravagers: with `w >= 7` the first ravager carries an evoker and the second a vindicator (so +2 riders) and bonus up to 2 each for vindicators and pillagers. A bonus wave (omen level >= 2, after the last wave when no raiders alive) repeats the table row of the last regular wave (`numGroups`) and the Ravager bonus is 1 on Normal and Hard.
Timing: first wave 300 ticks (15 s) after the raid starts; between waves a 300-tick pause after the last raider of a wave dies; the raid ends at 48000 ticks; enchant odds with omen level 3: 0.25.

### 20.4 Zombie reinforcement chance

A zombie spawned on Hard with effective difficulty 3 (special multiplier 0.5): base chance `nextDouble * 0.1` (mean 0.05); leader chance `0.05 * 0.5 = 0.025`: leader adds 0.5 to 0.75 chance. When a zombie is hurt on Hard: spawns reinforcements if `nextFloat < chance`; the caller's chance drops by 0.05 each time (never below the attribute minimum 0 in the read range 0 to 1: the attribute clamp is in 18 framework).

### 20.5 Phantom insomnia

A player with `time_since_rest` of 144000 ticks (2 hours) at night, effective difficulty 3 on Hard: `nextFloat * 3 < 3` almost always passes; the rest check `nextInt(144000) >= 72000` passes with probability 0.5; if it passes a group of `1 + nextInt(4)` phantoms (Hard) appears 20 to 34 blocks above, within +-10 blocks horizontally. With a rest time of 72000 or less the check can never pass.

### 20.6 Sunburn probability

A zombie at full sky light (15) at noon with sky visible: `B = 1.0`; per tick probability `(1.0 - 0.4) * 2 / 30 = 0.04`; expected ignition after 25 ticks; then the zombie burns for 8 seconds and re-ignites. At light 13 (`B = 13/15 / (4 - 3*13/15) = 0.8667 / 1.4 = 0.619`): probability `(0.619 - 0.4) * 2 / 30 = 0.0146` per tick. At light 12: `B = 0.8 / 1.6 = 0.5` which is not above 0.5: never burns.

## 21. Validation

An implementation can check itself against these cases:

1. Explosion damage table 20.1 for radii 3 and 6 at distances 0 to 6, exposure 1, all difficulties: exact to 3 decimals.
2. A creeper with a target within 3 blocks starts the swell (fuse 30 ticks): exactly 30 ticks later it explodes unless the target leaves 7 blocks or line of sight (swell direction -1 makes the counter fall by 1 per tick to 0).
3. Powered creeper explosion radius 6, normal 3; mob-griefing false: damage and knockback but no block changes.
4. `getSeenPercent`: an entity fully in the open gives 1.0; fully enclosed 0.0.
5. Slime split counts 2 to 4, sizes halve (integer division), only size 1 drops slime balls; slime health `size^2`, speed `0.2 + 0.1 * size`, attack damage `size`; size-1 slimes deal no damage, size-1 magma cubes do (not here).
6. Zombie: attributes 35 / 0.23 / 3.0 / 2.0; baby speed +50% (multiplied-base); sun ignition only for light >= 13 and daytime keyframe; helmets protect (damageable helmets take 0 or 1 damage per ignition roll).
7. Zombie to drowned: 600 ticks eyes-in-water then 300-tick shaking, reset if the zombie leaves water at any time; husk likewise converts to zombie; skeleton to stray after 140 ticks in powder snow plus 300.
8. Zombie villager cure: golden apple + Weakness, countdown `2401..5999`, speed-up blocks; resulting villager keeps trades.
9. Skeleton arrows: speed 1.6, inaccuracy 10/6/2 (Easy/Normal/Hard), draw 20 ticks, interval 40 (20 on Hard); bogged and parched 70 (50 on Hard); base damage `2 + triangle(0.11 * difficultyId, 0.57425)` for a full draw, hit damage `ceil(speed * baseDamage)`.
10. Spider: neutral at light >= 13 (not provoked), 1% give-up chance per tick; cave spider poison 7 s (Normal) / 15 s (Hard) / none (Easy).
11. Enderman: gaze test tolerance 0.025 scaled by distance; teleports 64 tries; carried block set; not burned by day but teleports away from sun; takes damage from water.
12. Phantom spawn: needs 72000+ ticks since rest; count `1 + nextInt(difficultyId + 1)`.
13. Raid wave table (20.3) and enchantment odds by omen level; patrol timer 12000 + `nextInt(1200)`, one in five checks; first wave 300 ticks; hero effect 48000 ticks amplifier `omen - 1`.
14. Warden: sonic boom damage 10 within 15 x 20; anger thresholds 40 / 80; darkness 260 ticks.
15. Entity ids of the index table; metadata indices of each mob (16 onward) as listed.

## 22. Open questions

1. (closed: the default eye height is `0.85 * height` (`EntityDimensions.defaultEyeHeight`); builders that set no eye height use it.)
2. (closed: `SpearUseGoal` is described in 4.1; the kinetic weapon's use duration and the spear item itself are item data not read here.)
3. (closed: `finalizeVillagerType` and the default villager data are in 4.2.)
4. (closed in this round: Husk jockey fully read, 4.3.)
5. (closed: bow goal read, 5.)
6. (closed: the `BOGGED_SHEAR` table is 2 rolls of {`brown_mushroom` x1, `red_mushroom` x1}, given in section 5.)
7. (closed: tag read, members `flint_and_steel` and `fire_charge`.)
8. (closed: `checkStraySpawnRules` read, 5.)
9. (closed: mounts are owned by 19 §3.6, 19 §3.8 and 21 §4.10.)
10. Pillager crossbow: the goal's state machine is in 13.2; still unread are the Quick Charge arithmetic (`EnchantmentHelper.modifyCrossbowChargingTime`) and the internals of `CrossbowItem.performShooting`.
11. (closed: ominous bottle consumption read, 14.2.)
12. Mineshaft cave-spider spawner blocks and woodland mansion/evoker/vindicator structure spawns were not read.
13. (closed: teleport-towards read, 8.1.)
14. (reserved)
15. (closed: slime spawn rule fully read, 10.)
16. (closed: witch target goals read, 11.)
17. (closed: circle goal and move control read, 12.)
18. (closed: raider goals read, 13.)
19. (closed: ravager knockback read, 13.6.)
20. (closed: horn read, 14.2.)
21. (closed: spawn position search read, 14.2.)
22. Warden: the bodies of the `TryToSniff`, `Digging` and `Emerging` behaviours were not read (the `Sniffing` behaviour and the vibration handling are in 15).
23. (closed: negative inaccuracy gives a symmetric spread, 16.)
24. Sulfur cube: the effect of the `bounciness`, `friction_modifier` and `air_drag_modifier` attributes on movement and of the archetype knockback modifiers on pushes (all values are in 18.2) was not read.
25. The registry ids in section 2 follow `EntityTypes.<clinit>` registration order and 04's rule; they should be verified against a captured registry sync before use on the wire.
26. (closed: `Mob.checkDespawn` read: in Peaceful a not-allowed type is discarded; otherwise, for a non-persistent mob with the nearest player at distance `d`: if `d^2 > 128^2` (monster despawn distance) and `removeWhenFarAway` it is discarded at once; else if `noActionTime > 600` and `nextInt(800) == 0` (the draw is made whenever the counter exceeds 600, before the distance test) and `d^2 > 32^2` and `removeWhenFarAway` it is discarded; when `d^2 < 32^2` the counter resets to 0.)
27. Block blast resistance and `Block.getExplosionResistance` values are block data (not covered here).
28. (closed: `getSeenPercent` fully read, 6.2.)
