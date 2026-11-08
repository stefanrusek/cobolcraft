# 19. Land-based friendly, passive and neutral mobs and NPCs

This document specifies the behaviour, parameters, data and spawning of the land-based passive, neutral and friendly mobs and the NPCs of Java Edition 26.3 (pig, cow, mooshroom, sheep, chicken, the horse family, llamas, camels, rabbit, cat, ocelot, wolf, fox, panda, polar bear, goat, frog, tadpole, turtle, armadillo, sniffer, allay, bee, parrot, the three golems, villager and wandering trader), including the full villager and wandering-trader trade data. The shared framework (entity model, attributes, goal and target selectors and the common goal classes, the Brain system, pathfinding, the natural spawning algorithm, loot, damage and death rules, breeding and taming bases) is in 18 framework (`18-mob-framework.md`); this document cross-references it by topic as "18 framework: <topic>" and gives only each mob's parameters. Overworld hostile mobs are in 20; aquatic, Nether, End and boss mobs are in 21.

| Item | Value |
|---|---|
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact already recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap`), with no execution, and of the data files under `data/minecraft/` in the same jar |
| Read classes | `net.minecraft.world.entity.animal.**`, `net.minecraft.world.entity.npc.**`, `net.minecraft.world.item.trading.*`, `net.minecraft.world.entity.ai.gossip.*`, `ai.village.poi.PoiTypes`, `ai.behavior.VillagerGoalPackages`, `SpawnPlacements`, `EntityTypes`, `EntityDimensions`, `ai.attributes.Attributes` and the data registries (loot tables, tags, biomes, variants, timelines, trade sets, villager trades) |
| Evidence rule | Every value is read from the artifact in this round. Items that were deduced from the shape of read code are marked "(inferred)"; items that could not be read are marked "(recalled, not verified)" or listed in section 27 |
| Dependencies | 00 §13 (entity metadata and serializer ids), 04 (registry and tag ids), 05a/05b (entity packets), 09, 13 |

## Contents

1. Conventions and shared tables (reading the tables, common constants, metadata layout, spawn placement, biome spawner tables, variant selection)
2. Farm animals: pig, cow, mooshroom, sheep, chicken
3. Equines: shared horse rules, stat genes, horse, feeding and taming, donkey/mule/skeleton horse/zombie horse, llama and trader llama, camel and camel husk
4. Rabbit
5. Felines: cat, ocelot
6. Wolf
7. Fox
8. Panda
9. Polar bear
10. Goat
11. Frog and tadpole
12. Turtle
13. Armadillo
14. Sniffer
15. Allay
16. Bee
17. Parrot
18. Axolotl (to 21)
19. Iron golem
20. Snow golem
21. Copper golem
22. Villager (identity, professions, brain, trades and prices, gossip, breeding, golem summoning)
23. Wandering trader
24. Trade data tables
25. Worked examples
26. Validation checklist
27. Open questions

## Index: mob, entity id, section

Entity ids are the registration order of `EntityTypes` (inferred; see Open questions 33).

| Mob | Entity id | Key | Section |
|---|---|---|---|
| Pig | 101 | `minecraft:pig` | 2.1 |
| Cow | 30 | `minecraft:cow` | 2.2 |
| Mooshroom | 87 | `minecraft:mooshroom` | 2.3 |
| Sheep | 114 | `minecraft:sheep` | 2.4 |
| Chicken | 26 | `minecraft:chicken` | 2.5 |
| Horse | 67 | `minecraft:horse` | 3.3 |
| Donkey | 37 | `minecraft:donkey` | 3.6 |
| Mule | 88 | `minecraft:mule` | 3.6 |
| Skeleton horse | 119 | `minecraft:skeleton_horse` | 3.6 |
| Zombie horse | 155 | `minecraft:zombie_horse` | 3.6 |
| Llama | 79 | `minecraft:llama` | 3.7 |
| Trader llama | 138 | `minecraft:trader_llama` | 3.7 |
| Camel | 19 | `minecraft:camel` | 3.8 |
| Camel husk | 20 | `minecraft:camel_husk` | 3.8 |
| Rabbit | 111 | `minecraft:rabbit` | 4 |
| Cat | 21 | `minecraft:cat` | 5.1 |
| Ocelot | 92 | `minecraft:ocelot` | 5.2 |
| Wolf | 152 | `minecraft:wolf` | 6 |
| Fox | 55 | `minecraft:fox` | 7 |
| Panda | 97 | `minecraft:panda` | 8 |
| Polar bear | 105 | `minecraft:polar_bear` | 9 |
| Goat | 63 | `minecraft:goat` | 10 |
| Frog | 56 | `minecraft:frog` | 11.1 |
| Tadpole | 134 | `minecraft:tadpole` | 11.2 |
| Turtle | 141 | `minecraft:turtle` | 12 |
| Armadillo | 4 | `minecraft:armadillo` | 13 |
| Sniffer | 122 | `minecraft:sniffer` | 14 |
| Allay | 2 | `minecraft:allay` | 15 |
| Bee | 11 | `minecraft:bee` | 16 |
| Parrot | 99 | `minecraft:parrot` | 17 |
| Axolotl (21) | 7 | `minecraft:axolotl` | 18 |
| Iron golem | 71 | `minecraft:iron_golem` | 19 |
| Snow golem | 124 | `minecraft:snow_golem` | 20 |
| Copper golem | 28 | `minecraft:copper_golem` | 21 |
| Villager | 143 | `minecraft:villager` | 22 |
| Wandering trader | 145 | `minecraft:wandering_trader` | 23 |

## 1. Conventions and shared tables

### 1.1 Reading the per-mob tables

- "18 framework: X" points to topic X in `18-mob-framework.md` (goal and target selectors, `PanicGoal`, `TemptGoal`, `BreedGoal`, `FollowParentGoal`, `WaterAvoidingRandomStrollGoal`, `LookAtPlayerGoal`, `RandomLookAroundGoal`, `FloatGoal`, `MeleeAttackGoal`, `HurtByTargetGoal`, `NearestAttackableTargetGoal`, `LeapAtTargetGoal`, the Brain system and its behaviours, pathfinding, the natural spawning algorithm, loot, damage, death, breeding, taming and anger bases). This document gives only the parameters each mob passes to those pieces.
- Brain behaviour lines (activities, §3.8, §10, §11, §13 to §15, §21 to §23) list each behaviour class with its constructor arguments in the artifact's positional order. Where this document names an argument (a speed, a distance, a duration, a memory) the meaning was read from the argument's type or from how the shared constants are used; an unlabelled number or `s` (the base speed 0.5 of the villager brain) is a positional value whose meaning inside that behaviour was not read. Recovered meanings (read from constants and call sites; "types only" and "inferred" as marked): `Swim(0.8)` = chance to jump when in fluid; `DoNothing(a, b)` = minimum and maximum duration in ticks; `LookAtTargetSink(45, 90)` and `MoveToTargetSink(80, 120)` = minimum and maximum duration (inferred); `VillageBoundRandomStroll(speed[, xz, y])` defaults are `MAX_XZ_DIST` 10 and `MAX_Y_DIST` 7, so the panic stroll's (2, 2) are the xz and y distances; `StrollAroundPoi(memory, speed, int)` has class constants: minimum 180 ticks between strolls, xz 8, y 6; `StrollToPoi` and `StrollToPoiList` integers are distances (roles not traced: types only); `SetWalkTargetFromBlockMemory` integers are a distance and timings (roles not traced: types only); `ShowTradesToPlayer(400, 1600)` with class constants `MAX_LOOK_TIME` 900 and `STARTING_LOOK_TIME` 40; `SetLookAndInteract(entity type, int)` = distance; `LocateHidingPlace` and `SetHiddenState` use `HIDE_TIMEOUT` 300; `GiveGiftToHero(100)` passes 100 to the base behaviour's duration constructor; `JumpOnBed` constants: 3 to 6 jumps, 5-tick cooldown, 100 ticks to reach the bed; `GoToWantedItem(speed, boolean, int)` as in the Core row. The behaviours' own algorithms (what `RunOne`, `GateBehavior`, `SetWalkTargetFromBlockMemory`, `InteractWith`, `LocateHidingPlace`, ... do with their arguments) belong to 18 framework: Brain system; where the artifact class was read in this round its effect is described in prose.
- A goal line `pN Name(args)` means: registered in the goal selector at priority N (lower number = higher priority) with the listed constructor arguments, in the order the artifact lists them. Speed arguments are speed modifiers (multiplied with the mob's movement-speed attribute). Target-selector entries are marked "target". `λ` marks a predicate or function argument that is described in the mob's prose.
- Attribute names use the lower-case registry names (`max_health`, `movement_speed`, `attack_damage`, `follow_range`, `flying_speed`, `jump_strength`, `step_height`, `safe_fall_distance`, `fall_damage_multiplier`, `armor`, `knockback_resistance`, `tempt_range`).
- Entity ids are the entity-type registry ids (04 §5.1): the registration index of the `EntityTypes` static initializer (inferred from the order of `register` calls, counted from 0). Sizes are `sized(width, height)` in blocks; "eye" is the eye height. When the artifact gives no eye height the default is 0.85 x height (read: `EntityDimensions.defaultEyeHeight`).
- Metadata indices are absolute: Entity 0 to 7, LivingEntity 8 to 14, Mob 15, then 16 and 17 for ageable mobs (16 = baby flag, boolean; 17 = age-locked flag, boolean), then the mob's own entries (§1.3). Serializer ids are those of 00 §13.2.
- Loot tables are quoted as they appear in `data/minecraft/loot_table/entities/<id>.json`. "looting +U(0,1)" means `enchanted_count_increase` with `count = uniform(0,1)` per level of the Looting enchantment added to the count. "smelt" means the `furnace_smelt` function with condition "the victim is on fire, or the direct attacker holds a main-hand item whose enchantments include the tag `#smelts_loot`"; it replaces the raw item with the cooked item. An entity with no pools drops nothing from its table (26.3 has no loot table pools for goat, wolf, fox, frog, tadpole, armadillo, sniffer, allay, bee, axolotl, camel, ocelot, villager and wandering trader).
- XP: every mob that extends `Animal` rewards `1 + nextInt(3)` experience points (1 to 3) when killed by a player or by tamed wolf damage per the death rules in 18 framework: loot/damage/death rules (`Animal.getBaseExperienceReward`). Exceptions are in each mob's table.
- Entity events (status bytes, Entity Event packet 05a) used by several mobs: 6 = taming failed (smoke), 7 = taming succeeded (hearts), 8 = wolf shake water, 10 = sheep/cow-like grass eating animation, 18 = love hearts, 40 = ocelot distrust, 41 = ocelot trust, 56 = wolf cancel shake. Others are listed per mob.

### 1.2 Common mob constants (apply to every `Animal` unless a mob row says otherwise)

| Item | Value |
|---|---|
| Base attributes (`createAnimalAttributes`) | mob defaults plus `follow_range` 16.0 and `tempt_range` 10.0; the mob row gives `max_health` and `movement_speed` |
| Love duration after feeding | 600 ticks |
| Age after breeding (both parents) | +6000 ticks (the cooldown, stored as a positive age) |
| Breeding experience | when two animals breed (`Animal.finalizeSpawnChildFromBreeding`, read) and the game rule `mob_drops` is on, one experience orb of `1 + nextInt(7)` (1 to 7) points is spawned at the first parent's position; both parents' age is set to 6000, love is reset, entity event 18 is sent, and the baby is spawned through `spawnChildFromBreeding` (baby flag set, placed at the parent, yaw 0). Turtles use their own routine that spawns the same orb size; their goal also puts the egg on the female. The partner search of `BreedGoal` takes the nearest suitable partner of the same class within 8 blocks that can mate and is not panicking; the goal runs while both are alive and in love, the partner is not panicking and `loveTime` is below 60; after 60 ticks and within 3 blocks (squared distance below 9) the breeding happens |
| Baby start age | -24000 ticks (`AgeableMob.getBabyStartAge`); the sniffer overrides it to -48000 (`Sniffer.getBabyStartAge`, constant `SNIFFER_BABY_START_AGE`) |
| Feeding a baby speeds growth | `(-age / 20) * 0.1` seconds (floored), applied as `ageUp(seconds * 20)` |
| Food interaction (adult age 0 and able to fall in love) | the item is consumed (not in creative), love is set, eating sound; the loving player is remembered for statistics |
| Natural despawn | animals never despawn when far away (`removeWhenFarAway` false); this applies to all mobs here except where stated |
| Golden dandelion (new in 26.3) | right-clicking a baby with a golden dandelion toggles its "age locked" flag (metadata 17) and sets its age to the baby start age when locking; the entity types in tag `cannot_be_age_locked` (`zombie_horse`, `skeleton_horse`, `villager`) refuse it; the item is consumed and the mob becomes persistent when locked |

### 1.3 Metadata layout summary

All indices are absolute; "(inh)" means inherited from a listed parent. Serializer names are 00 §13.2.

| Mob | Index: name (serializer) |
|---|---|
| Pig | 18 boost time (INT), 19 variant (PIG_VARIANT), 20 sound variant (PIG_SOUND_VARIANT) |
| Cow | 18 variant (COW_VARIANT), 19 sound variant (COW_SOUND_VARIANT) |
| Mooshroom | 18 type (INT: 0 = red, 1 = brown; ids of `MushroomCow$Variant`) |
| Sheep | 18 wool byte (BYTE): bits 0 to 3 dye colour id, bit 4 (value 16) sheared |
| Chicken | 18 variant (CHICKEN_VARIANT), 19 sound variant (CHICKEN_SOUND_VARIANT) |
| Horse | 18 abstract-horse flags (BYTE), 19 type variant (INT) |
| Donkey, Mule | 18 abstract-horse flags (BYTE), 19 has chest (BOOLEAN) |
| Llama, Trader llama | 18 flags (BYTE), 19 has chest (BOOLEAN), 20 strength (INT), 21 variant (INT) |
| Skeleton horse, Zombie horse | 18 abstract-horse flags (BYTE) |
| Camel, Camel husk | 18 abstract-horse flags (BYTE), 19 dash (BOOLEAN), 20 last pose change tick (LONG) |
| Rabbit | 18 type (INT) |
| Cat | 18 tamable flags (BYTE), 19 owner (OPTIONAL_LIVING_ENTITY_REFERENCE), 20 variant (CAT_VARIANT), 21 lying (BOOLEAN), 22 relaxed (BOOLEAN), 23 collar colour (INT dye id), 24 sound variant (CAT_SOUND_VARIANT) |
| Ocelot | 18 trusting (BOOLEAN) |
| Wolf | 18 tamable flags (BYTE), 19 owner (OPTIONAL_LIVING_ENTITY_REFERENCE), 20 interested/begging (BOOLEAN), 21 collar colour (INT), 22 anger end time (LONG), 23 variant (WOLF_VARIANT), 24 sound variant (WOLF_SOUND_VARIANT) |
| Fox | 18 type (INT), 19 flags (BYTE), 20 trusted uuid 0, 21 trusted uuid 1 (both OPTIONAL_LIVING_ENTITY_REFERENCE) |
| Panda | 18 unhappy counter (INT), 19 sneeze counter (INT), 20 eat counter (INT), 21 main gene (BYTE), 22 hidden gene (BYTE), 23 flags (BYTE) |
| Polar bear | 18 standing (BOOLEAN) |
| Goat | 18 screaming (BOOLEAN), 19 has left horn (BOOLEAN), 20 has right horn (BOOLEAN) |
| Frog | 18 variant (FROG_VARIANT), 19 tongue target (OPTIONAL_UNSIGNED_INT) |
| Tadpole | 16 from bucket (BOOLEAN), 17 age locked (BOOLEAN) |
| Turtle | 18 has egg (BOOLEAN), 19 laying egg (BOOLEAN) |
| Armadillo | 18 state (ARMADILLO_STATE) |
| Sniffer | 18 state (SNIFFER_STATE), 19 drop seed at tick (INT) |
| Allay | 16 dancing (BOOLEAN), 17 can duplicate (BOOLEAN) |
| Bee | 18 flags (BYTE), 19 anger end time (LONG) |
| Parrot | 18 tamable flags (BYTE), 19 owner, 20 variant (INT) |
| Axolotl | 18 variant (INT), 19 playing dead (BOOLEAN), 20 from bucket (BOOLEAN) |
| Iron golem | 16 flags (BYTE; bit 0 = player created) |
| Snow golem | 16 pumpkin flags (BYTE) |
| Copper golem | 16 weathering state (WEATHERING_COPPER_STATE), 17 golem state (COPPER_GOLEM_STATE) |
| Villager | 18 unhappy counter (INT), 19 villager data (VILLAGER_DATA), 20 villager data finalized (BOOLEAN) |
| Wandering trader | 18 unhappy counter (INT) |

Tamable flags (index 18 on cat, wolf, parrot): bit 0 (value 1) = sitting, bit 2 (value 4) = tamed (read in `TamableAnimal.isInSittingPose` and `isTame`). The horse-family flags (index 18): value 2 = tamed (`setTamed`), 8 = bred (`isBred`), 16 = eating (`isEating`), 32 = standing/rearing (`isStanding`); the other bits are not read (§3.1).

### 1.4 Spawn placement (natural spawning predicate inputs)

The generic algorithm (cycle, caps, packs, light, chunk rules) is in 18 framework: natural spawning algorithm. The per-type inputs are:

| Rule function | Condition |
|---|---|
| `Animal.checkAnimalSpawnRules` | block below is in block tag `animals_spawnable_on` (`grass_block`) AND raw brightness above 8 (light level strictly greater than 8), unless the spawn reason ignores light |
| `Mob.checkMobSpawnRules` | block below `isValidSpawn` for the type (non-spawner reasons) |
| Mooshroom | block below in `mooshrooms_spawnable_on` (`mycelium`) AND bright enough (light > 8) |
| Camel | block below in `camels_spawnable_on` (tag `#sand`) AND light > 8 |
| Rabbit | block below in `rabbits_spawnable_on` (`grass_block`, `snow`, `snow_block`, `sand`) AND light > 8 |
| Fox | block below in `foxes_spawnable_on` (`grass_block`, `snow`, `snow_block`, `podzol`, `coarse_dirt`) AND light > 8 |
| Wolf | block below in `wolves_spawnable_on` (`grass_block`, `snow`, `snow_block`, `coarse_dirt`, `podzol`) AND light > 8 |
| Goat | block below in `goats_spawnable_on` (tag `#animals_spawnable_on`, `stone`, `snow`, `snow_block`, `packed_ice`, `gravel`) AND light > 8 |
| Frog | block below in `frogs_spawnable_on` (`grass_block`, `mud`, `mangrove_roots`, `muddy_mangrove_roots`) AND light > 8 |
| Parrot | block below in `parrots_spawnable_on` (`grass_block`, `air`, `#leaves`, `#logs`) AND light > 8 |
| Armadillo | block below in tag `armadillo_spawnable_on` (= `#animals_spawnable_on`, `#badlands_terracotta` (terracotta, white, yellow, orange, red, brown and light gray terracotta), `red_sand`, `coarse_dirt`) AND light > 8 |
| Polar bear | if the biome is in `polar_bears_spawn_on_alternate_blocks` (`frozen_ocean`, `deep_frozen_ocean`): light > 8 AND block below is in `polar_bears_spawnable_on_alternate` (`ice`); otherwise `Animal.checkAnimalSpawnRules` |
| Turtle | y < sea level + 4 AND the block below is sand (`TurtleEggBlock.onSand`) AND light > 8 |
| Ocelot | `nextInt(3) == 0` fails the spawn (the rule returns true only when the roll is not 0, i.e. 2/3 pass), plus the heightmap `MOTION_BLOCKING` |
| Skeleton horse | spawner reasons need light > 8 unless they ignore light; then `checkAnimalSpawnRules` |
| Axolotl | block below in tag `axolotls_spawnable_on` (in water; see 21 for the aquatic rules) |

Spawn placement type / heightmap per type (read from `SpawnPlacements`): `ON_GROUND` with heightmap `MOTION_BLOCKING_NO_LEAVES` for pig, cow, mooshroom, sheep, chicken, horse, donkey, mule, llama, camel, camel husk, rabbit, goat, frog, turtle, armadillo, cat, polar bear, wolf, villager, iron golem, snow golem, skeleton horse, zombie horse, happy ghast; `ON_GROUND` with `MOTION_BLOCKING` for ocelot and parrot; `NO_RESTRICTIONS` with `MOTION_BLOCKING_NO_LEAVES` for fox, panda, trader llama; `IN_WATER` for axolotl.

### 1.5 Biome spawner tables (where each mob naturally spawns)

26.3 stores the spawner lists in each biome's `attributes["minecraft:gameplay/natural_mob_spawns"]` (modifier `overlay`) as `spawns_by_category` and `spawn_costs`. No biome in this artifact declares a `spawn_costs` entry for the mobs of this document. Counts are the group size per spawn event (a number or `uniform(min,max)`); weights are relative within the biome's category list. Category `creature` unless a row says otherwise. The same entry listed twice in one biome (bamboo jungle, jungle, sparse jungle each carry a second chicken entry) simply doubles the entry's weight (inferred from the list semantics in 18 framework: natural spawning algorithm).

| Mob | Weight | Group | Biomes |
|---|---|---|---|
| Sheep | 12 | 4 | badlands, bamboo jungle, birch forest, dappled forest, dark forest, eroded badlands, flower forest, forest, jungle, old-growth birch forest, old-growth pine taiga, old-growth spruce taiga, plains, savanna, savanna plateau, snowy taiga, sparse jungle, sunflower plains, swamp, taiga, windswept forest, windswept gravelly hills, windswept hills, windswept savanna, wooded badlands |
| Sheep | 2 | 2 to 4 | cherry grove, meadow |
| Pig | 10 | 4 | same 25 biomes as the weight-12 sheep row |
| Pig | 1 | 1 to 2 | cherry grove |
| Chicken | 10 | 4 | same 25 biomes (jungle, bamboo jungle and sparse jungle list it twice) |
| Cow | 8 | 4 | same 25 biomes |
| Horse | 5 | 2 to 6 | plains, sunflower plains |
| Horse | 1 | 2 to 6 | savanna, savanna plateau, windswept savanna |
| Donkey | 1 | 1 to 3 | plains, sunflower plains |
| Donkey | 1 | 1 | savanna, savanna plateau, windswept savanna |
| Donkey | 1 | 1 to 2 | meadow |
| Mooshroom | 8 | 4 to 8 | mushroom fields |
| Llama | 5 | 4 to 6 | windswept forest, windswept gravelly hills, windswept hills |
| Llama | 8 | 4 | savanna plateau |
| Camel | 1 | 1 | desert |
| Rabbit | 12 | 2 to 3 | desert |
| Rabbit | 10 | 2 to 3 | ice spikes, snowy plains |
| Rabbit | 8 | 2 to 3 | grove |
| Rabbit | 4 | 2 to 3 | flower forest, old-growth pine taiga, old-growth spruce taiga, snowy slopes, snowy taiga, taiga |
| Rabbit | 4 | 2 to 4 | dappled forest |
| Rabbit | 2 | 2 to 6 | cherry grove, meadow |
| Ocelot | 2 | 1 to 3 | jungle (category `monster` in the artifact data; see Open questions) |
| Ocelot | 2 | 1 | bamboo jungle (category `monster`) |
| Parrot | 40 | 1 to 2 | jungle, bamboo jungle |
| Panda | 80 | 1 to 2 | bamboo jungle |
| Panda | 1 | 1 to 2 | jungle |
| Wolf | 8 | 4 | old-growth pine taiga, old-growth spruce taiga, snowy taiga, taiga |
| Wolf | 8 | 2 to 4 | sparse jungle |
| Wolf | 8 | 4 to 8 | savanna plateau |
| Wolf | 5 | 4 | forest |
| Wolf | 2 | 4 to 8 | wooded badlands |
| Wolf | 1 | 1 | grove |
| Fox | 8 | 2 to 4 | old-growth pine taiga, old-growth spruce taiga, snowy taiga, taiga |
| Fox | 4 | 2 to 4 | dappled forest, grove |
| Polar bear | 1 | 1 to 2 | deep frozen ocean, frozen ocean, ice spikes, snowy plains |
| Goat | 5 | 1 to 3 | frozen peaks, jagged peaks, snowy slopes |
| Frog | 10 | 2 to 5 | mangrove swamp, swamp |
| Turtle | 5 | 2 to 5 | beach |
| Armadillo | 10 | 2 to 3 | savanna, savanna plateau, windswept savanna |
| Armadillo | 6 | 1 to 2 | badlands, eroded badlands, wooded badlands |
| Axolotl | 10 | 4 to 6 | lush caves (category `axolotls`) |

Not in any biome list (these appear by other mechanisms; the ones read in this round are described per mob): cat (the cat spawner reads villages and swamp huts, §5.1), wandering trader (world spawner, §23), iron golem (summoned by villagers, §22.10), skeleton horse (trap goal, §3.6), zombie horse and camel husk (monster category; spawn lists are in 20). How villagers, bees, allays, sniffers, snow golems and copper golems first appear in the world (worldgen placement, structures, player-built block patterns, eggs) was not read in this round; nothing is asserted; see Open questions.

Biome-level modifiers read from the same data that affect these mobs: `gameplay/creature_world_gen_spawn_probability` (the chance that chunk generation spawns the creatures of a biome at all) is 0.07 in snowy plains and ice spikes, 0.04 in wooded badlands, 0.03 in badlands and eroded badlands; every other biome leaves the default (read as unset in the data; the default value belongs to 18 framework: natural spawning algorithm).

### 1.6 Variant selection by priority (cat, wolf, frog, pig, cow, chicken and sound variants)

A variant registry entry has `spawn_conditions`: a list of `{condition?, priority}` selectors. To choose a variant for a new mob (`VariantUtils.selectVariantToSpawn`, used in `finalizeSpawn` for natural, spawner and spawn-egg spawns, not for breeding):

1. Collect every (variant, selector) pair whose condition holds (a selector without a condition always holds). Conditions are `biome` (the mob's block position is in the biome or biome tag), `structure` (the position is inside the structure or structure tag) and `moon_brightness` (the current moon brightness within a range).
2. Keep only the pairs whose priority equals the highest priority among the holding pairs.
3. Pick one remaining variant uniformly at random (`Util.getRandomSafe`).

If no registry entry exists the default key is used (`getDefaultOrAny`). Sound variants (pig: classic, big, mini; cow: classic, moody; chicken: classic, picky; cat: classic, royal; wolf: 7 sound variants: angry, big, classic, cute, grumpy, puglin, sad) are chosen by a separate `pickRandomSoundVariant`, which takes a random element of the sound-variant registry (`Registry.getRandom`, read for cat and wolf; the same name is used by the others) with no conditions.

Variant data of 26.3:

| Registry | Entry (default marked *) | Selector |
|---|---|---|
| pig, cow, chicken | `cold` | priority 1: biome in tag `spawns_cold_variant_farm_animals` |
| | `temperate`* | priority 0, no condition |
| | `warm` | priority 1: biome in tag `spawns_warm_variant_farm_animals` |
| frog | `cold` | priority 1: biome in `spawns_cold_variant_frogs` |
| | `temperate` | priority 0 |
| | `warm` | priority 1: biome in `spawns_warm_variant_frogs` |
| cat | `all_black` | priority 1: structure in tag `cats_spawn_as_black` (`swamp_hut`); also priority 0: moon brightness at least 0.9 |
| | `black`*, `british_shorthair`, `calico`, `jellie`, `persian`, `ragdoll`, `red`, `siamese`, `tabby`, `white` | priority 0, no condition |
| wolf | `pale` | priority 0 |
| | `ashen` | priority 1: biome snowy taiga |
| | `black` | priority 1: old-growth pine taiga |
| | `chestnut` | priority 1: old-growth spruce taiga |
| | `rusty` | priority 1: biome tag `is_jungle` |
| | `snowy` | priority 1: grove |
| | `spotted` | priority 1: biome tag `is_savanna` |
| | `striped` | priority 1: biome tag `is_badlands` |
| | `woods` | priority 1: forest |

Biome tags: `spawns_cold_variant_farm_animals` = snowy plains, ice spikes, frozen peaks, jagged peaks, snowy slopes, frozen ocean, deep frozen ocean, grove, deep dark, frozen river, snowy taiga, snowy beach, #is_end, cold ocean, deep cold ocean, old-growth pine taiga, old-growth spruce taiga, taiga, windswept forest, windswept gravelly hills, windswept hills, stony peaks, dappled forest. `spawns_warm_variant_farm_animals` = desert, warm ocean, #is_jungle, #is_savanna, #is_nether, #is_badlands, mangrove swamp, deep lukewarm ocean, lukewarm ocean. `spawns_cold_variant_frogs` = snowy plains, ice spikes, frozen peaks, jagged peaks, snowy slopes, frozen ocean, deep frozen ocean, grove, deep dark, frozen river, snowy taiga, snowy beach, #is_end. `spawns_warm_variant_frogs` = desert, warm ocean, #is_jungle, #is_savanna, #is_nether, #is_badlands, mangrove swamp. `is_jungle` = bamboo jungle, jungle, sparse jungle. `is_savanna` = savanna, savanna plateau, windswept savanna. `is_badlands` = badlands, eroded badlands, wooded badlands. `is_taiga` = taiga, snowy taiga, old-growth pine taiga, old-growth spruce taiga. `spawns_white_rabbits` and `spawns_snow_foxes` = snowy plains, ice spikes, frozen ocean, snowy taiga, frozen river, snowy beach, frozen peaks, jagged peaks, snowy slopes, grove. `spawns_gold_rabbits` = desert.

## 2. Farm animals

### 2.1 Pig

| Item | Value |
|---|---|
| Entity | `minecraft:pig`, id 101, category creature, size 0.9 x 0.9, eye 0.765 (default), baby box 0.45 x 0.45 eye 0.40625, passenger attachment y 0.86875 |
| Attributes | `max_health` 10, `movement_speed` 0.25 |
| Food | item tag `pig_food`: carrot, potato, beetroot |
| Goals | p0 Float; p1 Panic(1.25); p3 Breed(1.0); p4 Tempt(1.2, item = carrot on a stick, scare off by player movement false); p4 Tempt(1.2, item tag `pig_food`, false); p5 FollowParent(1.1); p6 WaterAvoidingRandomStroll(1.0); p7 LookAtPlayer(Player, 6.0); p8 RandomLookAround |
| Variant | metadata 19, default `temperate`; chosen by §1.6 at spawn; breeding: the baby takes one parent's variant, 50/50 (`nextBoolean`) |
| Sound variant | metadata 20, default `classic` |
| Saddle | the saddle is an item equippable in the saddle slot (`can_equip_saddle` includes pig); right-click a pig that is not food-feeding with a saddle in hand equips it; a saddled pig with no passenger and no sneaking player is ridden by right-click (the rider starts riding) |
| Steering | a saddled pig is controlled by its first passenger only if that passenger is a player holding a carrot on a stick; ridden speed = `movement_speed * 0.225 * boost factor`; head and body follow the rider's yaw, pitch is half the rider's pitch |
| Boost | using a carrot on a stick while riding starts a boost if none is running: total duration `nextInt(841) + 140` ticks (stored in metadata 18); boost factor = `1 + 1.15 * sin(pi * elapsed / total)` while boosting, 1 otherwise |
| Lightning | when struck by lightning (difficulty not peaceful) the pig converts into a zombified piglin keeping name/persistence (conversion framework in 18); the converted piglin gets default equipment and is persistent |
| Drops | 1 pool: porkchop `uniform(1,3)`, smelt, looting +U(0,1) |
| XP | 1 to 3 |
| Spawn | `checkAnimalSpawnRules`; §1.5 |

### 2.2 Cow

| Item | Value |
|---|---|
| Entity | `minecraft:cow`, id 30, creature, 0.9 x 1.4, eye 1.3, baby 0.45 x 0.7 eye 0.69 |
| Attributes | `max_health` 10, `movement_speed` 0.2 |
| Food | item tag `cow_food`: wheat |
| Goals | p0 Float; p1 Panic(2.0); p2 Breed(1.0); p3 Tempt(1.25, `cow_food`, false); p4 FollowParent(1.25); p5 WaterAvoidingRandomStroll(1.0); p6 LookAtPlayer(Player, 6.0); p7 RandomLookAround |
| Milking | right-click an adult with an empty bucket: plays the cow-milk sound, the bucket in hand is replaced by a milk bucket (`createFilledResult`: one bucket consumed, the player receives the milk bucket in the same hand, or in the inventory when the stack was larger; creative keeps the bucket) |
| Variant | metadata 18 default `temperate`; breeding: 50/50 parent's variant; sound variant metadata 19 default `classic` |
| Drops | pool 1: leather `uniform(0,2)`, looting +U(0,1); pool 2: beef `uniform(1,3)`, smelt, looting +U(0,1) |
| XP | 1 to 3 |

### 2.3 Mooshroom

| Item | Value |
|---|---|
| Entity | `minecraft:mooshroom`, id 87, creature, 0.9 x 1.4, eye 1.3 (same box as cow) |
| Attributes, goals, food, milk | as cow (it extends the same base: goals p0 Float, p1 Panic(2.0), p2 Breed(1.0), p3 Tempt(1.25, wheat), p4 FollowParent(1.25), p5 WaterAvoidingRandomStroll(1.0), p6 LookAtPlayer(6), p7 RandomLookAround; `max_health` 10, `movement_speed` 0.2) |
| Type | metadata 18 INT: 0 red (default), 1 brown (`MushroomCow$Variant`) |
| Bowl | right-click an adult with a bowl: if the mooshroom holds stored suspicious-stew effects (set by feeding it a small flower, below) the bowl becomes a suspicious stew with those effects and the stored effects are cleared, otherwise it becomes mushroom stew; the sound is the "milk suspiciously" event when stew effects were used, else "milk" |
| Flower feeding | only a brown mooshroom (adult) with a flower item (an item with the suspicious-stew effects component) and no stored effect: consumes one item, stores the flower's stew effects, plays the eat sound (volume 2, pitch 1) and emits effect particles; if it already holds effects, smoke particles (2) and no consumption |
| Shearing | shears on an adult: `shear` plays the mooshroom-shear sound; the loot table `shearing/mooshroom` chooses by type: red -> 5 rolls of red mushroom; brown -> 5 rolls of brown mushroom (each pool roll yields 1 item); the mooshroom converts into a normal cow (ordinary cow, health and data kept per the conversion rules in 18; the new cow keeps variant `temperate`) |
| Lightning | a red mooshroom becomes brown and a brown becomes red, once per distinct lightning bolt (the last bolt uuid is remembered); sound "mooshroom convert" (volume 2) |
| Breeding result | if both parents have the same type and `nextInt(1024) == 0`, the baby has the opposite type (a brown pair gives red, a red pair gives brown); otherwise the baby takes one parent's type with `nextBoolean` |
| Drops | as cow (leather `uniform(0,2)`, beef `uniform(1,3)` smelt) |
| Spawn | `checkMushroomSpawnRules`; only the mushroom fields biome, group 4 to 8, weight 8 |

### 2.4 Sheep

| Item | Value |
|---|---|
| Entity | `minecraft:sheep`, id 114, creature, 0.9 x 1.3, eye 1.235, baby 0.45 x 0.65 eye 0.65625 |
| Attributes | `max_health` 8, `movement_speed` 0.23 (stored as 0.2300000041723251) |
| Food | item tag `sheep_food`: wheat |
| Goals | p0 Float; p1 Panic(1.25); p2 Breed(1.0); p3 Tempt(1.1, `sheep_food`, false); p4 FollowParent(1.1); p5 EatBlock; p6 WaterAvoidingRandomStroll(1.0); p7 LookAtPlayer(Player, 6.0); p8 RandomLookAround |
| Metadata | 18 BYTE: low nibble dye id (0 white, 1 orange, 2 magenta, 3 light blue, 4 yellow, 5 lime, 6 pink, 7 gray, 8 light gray, 9 cyan, 10 purple, 11 blue, 12 brown, 13 green, 14 red, 15 black), 16 = sheared |
| EatBlock goal | start chance each tick `nextInt(adjustedTickDelay(50 if baby else 1000)) == 0` (a baby tries 20 times more often); usable when the block at the feet is in tag `edible_for_sheep` (short grass, short dry grass, tall dry grass, fern) or the block below is grass block; on start: animation timer 40 ticks, entity event 10, the path is stopped; when the timer reaches 4 the block is eaten: a tall-grass-like block is destroyed (no drop) or the grass block below becomes dirt (level event 2001 with the grass block state); both only when the mob-griefing game rule is true; then `ate`: sheared flag cleared (wool regrows) and a baby ages up by 60 ticks (`ageUp(60)` when it can age up) |
| Shearing | right-click with shears when the sheep is not sheared and not a baby (`readyForShearing`): plays the shear sound, drops from the loot table `shearing/sheep` (per colour: `shearing/sheep/<colour>` = `<colour>_wool` with `uniform(1,3)` rolls of 1 item each), the sheared flag is set, the shears lose 1 durability (hurt-and-break), game event shear; each dropped item gets a small random velocity (x,z in +-0.1, y up to 0.05) |
| Dyeing | right-click on a sheep with an item that has the `dye` data component (read: `DyeItem.interactLivingEntity`): the sheep must be alive, not sheared, and the dye colour must differ from its current colour; then the dye-use sound plays (volume 1, pitch 1), on the server only the sheep's colour is set to the dye's colour (metadata low nibble) and the stack shrinks by 1 (creative included, per the item's own rule: the artifact shrinks without a creative check in this method); result SUCCESS. Any other case passes |
| Colour at spawn | `finalizeSpawn` sets colour by biome (below) |
| Breeding colour | `DyeColor.getMixedColor(serverLevel, parentA, parentB)`: search the crafting recipes for a two-item shapeless recipe whose ingredients are dye items of the two parent colours (both orders) and whose result item carries a dye colour; if found the baby has that colour; if not, a uniformly random one of the two parent colours (`nextBoolean`) |
| Drops (death) | pool 1: mutton `uniform(1,2)`, smelt, looting +U(0,1); pool 2: if not sheared, the per-colour table `entities/sheep/<colour>` (a wool drop of 1 for each colour, see data); sheared sheep drop no wool |
| XP | 1 to 3 |

Sheep colour at spawn (`SheepColorSpawnRules`): pick the configuration by biome: biome in `spawns_warm_variant_farm_animals` = warm, in `spawns_cold_variant_farm_animals` = cold, else temperate. Each configuration is a weighted list of providers with total weight 100: temperate = black 5, gray 5, light gray 5, brown 3, common-white 82; warm = gray 5, light gray 5, white 5, black 3, common-brown 82; cold = light gray 5, gray 5, white 5, brown 3, common-black 82. A "common-C" provider returns C with weight 499 and pink with weight 1 (so pink occurs with probability 0.82 x 1/500 = 0.164 percent).

Sheep dye mix table (two-item shapeless recipes read from the crafting data whose ingredients are two dyes and whose result is a dye; unordered pairs): blue+green = cyan; black+white = gray; blue+white = light blue; gray+white = light gray; green+white = lime; purple+pink = magenta; red+yellow = orange; red+white = pink; blue+red = purple. A pair not in this list (for example red+green, or two equal colours) has no recipe and the lamb takes one parent's colour at random. Three-ingredient dye recipes are ignored (inferred: the search builds a 2 x 1 crafting input, so only recipes that fit two items can match).

### 2.5 Chicken

| Item | Value |
|---|---|
| Entity | `minecraft:chicken`, id 26, creature, 0.4 x 0.7, eye 0.644, baby 0.3 x 0.4 eye 0.28125 |
| Attributes | `max_health` 4, `movement_speed` 0.25 |
| Food | item tag `chicken_food`: wheat seeds, melon seeds, pumpkin seeds, beetroot seeds, torchflower seeds, pitcher pod |
| Goals | p0 Float; p1 Panic(1.4); p2 Breed(1.0); p3 Tempt(1.0, `chicken_food`, false); p4 FollowParent(1.1); p5 WaterAvoidingRandomStroll(1.0); p6 LookAtPlayer(Player, 6.0); p7 RandomLookAround |
| Egg laying | every tick on the server for an alive adult that is not a chicken jockey: `eggTime` counts down; at 0 the loot table `gameplay/chicken_lay` is dropped (egg for temperate, brown egg for warm, blue egg for cold variant), the chicken-egg sound plays (pitch `1 + (rand-rand)*0.2`), game event entity-place, and `eggTime = nextInt(6000) + 6000` |
| Flight | while not on the ground and moving down the vertical speed is multiplied by 0.6 (slow fall); no fall damage (entity tag `fall_damage_immune`) |
| Variant | metadata 18, default `temperate`, chosen by §1.6 at spawn; breeding: 50/50 a parent's variant; sound variant metadata 19 |
| Jockey | a chicken jockey is a chicken marked as jockey (created by baby-zombie spawning rules in 20); it never despawns while jockey is true (`removeWhenFarAway` returns the flag) and gives 10 XP |
| Drops | pool 1: feather `uniform(0,2)`, looting +U(0,1); pool 2: chicken 1, smelt (cooked chicken), looting +U(0,1) |
| XP | 1 to 3 (10 if jockey) |

## 3. Equines (horse family, llamas, camels)

### 3.1 Shared horse rules (`AbstractHorse`)

| Item | Value |
|---|---|
| Base attributes (`createBaseHorseAttributes`) | `max_health` 53, `movement_speed` 0.225, `jump_strength` 0.7, `step_height` 1.0, `safe_fall_distance` 6.0, `fall_damage_multiplier` 0.5, plus the animal base (`follow_range` 16, `tempt_range` 10). Each subtype overrides some values (rows below); a spawned horse or donkey-family mob then has its base values replaced by the random genes (§3.2) |
| Metadata 18 flags (BYTE) | the flag constants of `AbstractHorse` (read): 2 = tamed, 8 = bred, 16 = eating, 32 = standing (rearing), 64 = open mouth; no constant exists for bits 1 and 4 (26.3 has no saddle flag bit: the saddle is an equipment slot). `BABY_SCALE` 0.7 (baby box = adult box scaled 0.7); `BREEDING_CROSS_FACTOR` 0.15; `BACKWARDS_MOVE_SPEED_FACTOR` 0.25; `SIDEWAYS_MOVE_SPEED_FACTOR` 0.5; `DEFAULT_TEMPER` 0; `INVENTORY_ROWS` 3 |
| Equipment | saddle slot (`can_equip_saddle`: horse, skeleton horse, zombie horse, donkey, mule, pig, strider, camel, camel husk, nautilus, zombie nautilus); body slot for armour (`can_wear_horse_armor`: horse and zombie horse only). A saddle can only be used in the slot when the mob is alive, not a baby, and tamed |
| Max temper | 100 |
| Max spawn cluster | 6 |
| Behaviour goals added by `addBehaviourGoals` (the family's own goals, besides the subtype's) | p1 Panic variant "mount panic"(1.2) (flees when hurt only if it has no rider that controls it; cross-reference 18 framework: PanicGoal); p0 Float; p3 Tempt(1.25, item tag `horse_tempt_items`: golden carrot, golden apple, enchanted golden apple, false). Base goals registered in `registerGoals`: p1 RunAroundLikeCrazy(1.2); p2 Breed(1.0, the horse class); p4 FollowParent(1.0); p6 WaterAvoidingRandomStroll(0.7); p7 LookAtPlayer(Player, 6.0); p8 RandomLookAround; p9 RandomStand |
| Mate rule | `canMate` is false at the abstract level; subtype rules in 3.3 (`canParent` = alive, not rearing-passenger, not baby, in love-ready state, tamed horse breeds only when fed the golden items) |
| Passive behaviour | each tick `nextInt(200) == 0` swishes the tail; `nextInt(900) == 0` and not dying heals 1 HP; a horse that can eat grass (always true) and is not eating, not ridden, with `nextInt(300) == 0` and grass block below starts eating (flag 16) for 50 ticks (eating counter counts up to 50); a bred baby (flag 8) within 16 blocks of an adult horse that qualifies as "mom" (`PARENT_HORSE_SELECTOR`: the other is an `AbstractHorse` that is bred) walks toward it when farther than 2 blocks |
| Hurt | after a successful hit `nextInt(3) == 0` makes the horse rear (stand if possible) |
| Riding speed | ridden speed = the `movement_speed` attribute value (the horse subtype can scale it); strafe input is halved, forward input is quartered when going backwards; while rearing on the ground with no pending jump the rider input is zero |
| Jump | the client sends a jump power 0 to 100 via the player-jump action; below 0 is clamped to 0; the pending scale (`PlayerRideableJumping.getPlayerJumpPendingScale`) is `0.4 + 0.4 * p / 90` when p < 90 and the full scale (1.0, inferred from the branch shape) when p >= 90; the jump launches vertical speed `jump_strength * scale` (+ jump boost) plus a forward impulse of `(0.4 * sin/cos(yaw)) * scale` |

### 3.2 Stat genes: formulas and worked values

Randomised at spawn (`randomizeAttributes`, called from `finalizeSpawn` of every `AbstractHorse`):

| Stat | Formula (R = three or two independent `nextDouble` / `nextInt` draws) | Min | Max |
|---|---|---|---|
| Max health | `15 + nextInt(8) + nextInt(9)` | 15 | 30 |
| Jump strength | `0.4 + 0.2 * r1 + 0.2 * r2 + 0.2 * r3` | 0.4 | 1.0 |
| Movement speed | `(0.45 + 0.3 * r1 + 0.3 * r2 + 0.3 * r3) * 0.25` | 0.1125 | 0.3375 |

Which classes apply which draws (read): `AbstractHorse.randomizeAttributes` is empty. `Horse` randomises health, speed and jump; donkey, mule and llamas (`AbstractChestedHorse.randomizeAttributes`) randomise only max health (speed and jump stay at the chested base 0.175 and 0.5); `SkeletonHorse.randomizeAttributes` randomises only jump strength with the shared horse jump formula (health stays 15, speed 0.2); `ZombieHorse.randomizeAttributes` sets jump strength to `0.5 + (r1 + r2 + r3) / 15` and movement speed to `(9 + r1 + r2 + r3) / 42.16` (three `nextDouble` draws each; zombie horse health stays 25). The constants `MIN_*`/`MAX_*` are the shared generators evaluated at the extreme draws (health extremes use an int source returning 0 and `n - 1`, doubles 0 and 1).

Foal genes (`setOffspringAttributes`, applied to health, jump and speed separately; parent values A, B are base values of the two parents):

1. Clamp A and B into [MIN, MAX]. Let `range = MAX - MIN`.
2. `spread = |A - B| + 2 * (0.15 * range)`.
3. `mean = (A + B) / 2`.
4. `noise = (nextDouble() + nextDouble() + nextDouble()) / 3 - 0.5`.
5. `value = mean + spread * noise`.
6. If `value > MAX`, reflect: `MAX - (value - MAX)`; if `value < MIN`, reflect: `MIN + (MIN - value)`.

Worked example (jump): parents 0.5 and 0.9, MIN 0.4, MAX 1.0, range 0.6. spread = 0.4 + 2 x 0.09 = 0.58, mean 0.7. If the three draws are 0.9, 0.9, 0.9: noise = 0.4, value = 0.7 + 0.58 x 0.4 = 0.932 (kept). If the draws are 1, 1, 1: noise 0.5, value 0.99. With parents 1.0 and 1.0 and draws 1,1,1: spread = 0 + 0.18 = 0.18, mean 1.0, value 1.09, reflected to 1.0 - 0.09 = 0.91.

Worked example (speed attribute): the artifact stores movement speed as the attribute value; the extreme spawn values are 0.1125 (draws 0, 0, 0) and 0.3375 (draws 1, 1, 1); a draw of (0.5, 0.5, 0.5) gives `(0.45 + 0.45) * 0.25 = 0.225`, the base value. A conversion to blocks per second is not given by anything read here and is not asserted (the physics conversion belongs to 18 framework: attribute system and to 13).

### 3.3 Horse

| Item | Value |
|---|---|
| Entity | `minecraft:horse`, id 67, creature, 1.3964844 x 1.6, eye 1.52; baby box = adult box scaled 0.7 with passenger y `height - 0.125` |
| Attributes | base horse attributes; spawn genes of 3.2 |
| Food/healing/aging/temper table | see 3.4 |
| Colours | metadata 19 INT: bits 0 to 7 = coat variant (0 white, 1 creamy, 2 chestnut, 3 brown, 4 black, 5 gray, 6 dark brown), bits 8 to 15 = markings (0 none, 1 white, 2 white field, 3 white dots, 4 black dots) |
| Spawn colours | random coat from the 7 and random markings from the 5, uniform; a group spawn reuses the first member's coat (`HorseGroupData`) but picks its own markings |
| Breeding partner | `canMate`: not itself, other is a horse or donkey, both `canParent` |
| Offspring | with a donkey: a mule; with a horse: a foal whose coat is `nextInt(9)`: 0 to 3 = this parent's coat, 4 to 7 = the other's, 8 = a random coat; markings `nextInt(5)`: 0 to 1 = this parent's, 2 to 3 = the other's, 4 = random; stats by 3.2 |
| Interaction | see 3.5 |
| Drops | leather `uniform(0,2)`, looting +U(0,1) |
| Armour | body slot (`can_wear_horse_armor`: horse, zombie horse); an item equippable in the body slot is equipped by right-click when none is worn (read, §3.5). Armour damage and protection values were not read in this round; nothing is asserted |

### 3.4 Feeding table (`handleEating`; Horse and shared)

For `AbstractHorse` (horse, donkey, mule, skeleton horse and zombie horse only accept it when `isFood`): each food gives heal H (HP), age-up A (seconds, babies only, not age-locked), temper T (only when untamed, below max temper; also given when not consumed by love).

| Item | H | A | T | Love (only when tamed, adult, age 0 and not already in love) |
|---|---|---|---|---|
| Wheat | 2 | 20 | 3 | no |
| Sugar | 1 | 30 | 3 | no |
| Hay block | 20 | 180 | 0 | no (the artifact sets no temper for hay) |
| Apple | 3 | 60 | 3 | no |
| Red mushroom (zombie horse food) | 3 | 0 | 3 | no |
| Carrot | 3 | 60 | 3 | no |
| Golden carrot | 4 | 60 | 5 | yes |
| Golden apple | 10 | 240 | 10 | yes |
| Enchanted golden apple | 10 | 240 | 10 | yes |

After the table: if health < max and H > 0: heal H and mark consumed. If a baby, A > 0 and not age-locked: happy-villager particles and `ageUp(A)` (seconds), consumed. If T > 0, the item was consumed or the horse is untamed, and `temper < 100`: `modifyTemper(T)` (clamped 0 to 100), consumed. If anything was consumed: eating sound and game event eat; the caller then takes one item unless creative. Llama (`Llama.handleEating`, read): wheat gives H 2, A 10, T 3; hay block gives H 10, A 90, T 6; love only when tamed, adult, age 0 and able to fall in love, with either item. Camel (`Camel.handleEating`, read): any `camel_food` item (cactus): heals 2 if hurt; love if tamed, age 0 and able to fall in love; a baby gets `ageUp(10)` (seconds) with particles; no temper.

Taming (horse, donkey, mule, skeleton horse and zombie horse when ridden; not llamas): an untamed adult is mounted by an empty-hand right-click (`doPlayerRide`). While a player rides an untamed horse, the `RunAroundLikeCrazy` goal runs (usable when not controlled by a mob, not tamed, with a passenger): each tick with chance `1/50` it reads temper T and max 100: if `max > 0` and `nextInt(100) < T` the horse is tamed to that player (`tameWithName`: owner = rider, tamed flag, taming trigger, entity event 7 hearts), otherwise `modifyTemper(5)`, the horse ejects all passengers, `makeMad` (rears with the angry sound if not already standing) and entity event 6 (smoke). Feeding any food that carries temper raises T beforehand. Hence the chance to tame per attempt is T percent.

### 3.5 Interaction order (`mobInteract`) shared by horse, donkey, mule

1. Baby or already a vehicle: the animal food path (love or age-up) is attempted first.
2. Tamed and the player sneaks and the horse is not a baby: open the horse inventory screen (the custom inventory: saddle slot plus armour slot, 2 more rows for chested types).
3. Item in hand: if the item is food, `fedFood` (table 3.4); else if the horse is not tamed (and not a baby): `makeMad` (rears; `SUCCESS`). Otherwise try `interactLivingEntity` of the item (this is how a saddle or other item with an interaction is applied); if that consumes the action, done. If the item is equippable in the body slot, the horse is not wearing body armour: equip one copy (`equipBodyArmor`).
4. Empty hand (or unhandled): mount the player (`doPlayerRide`: eating flag cleared, standing cleared, the player faces the horse's yaw/pitch).
5. A chested animal also: with a chest item in hand and no chest yet: `equipChest` (sets the chest flag, plays the equip sound, consumes 1 item, rebuilds the inventory; the slot count was not read in this round; nothing is asserted).

### 3.6 Donkey, mule, skeleton horse, zombie horse

| Item | Donkey | Mule | Skeleton horse | Zombie horse |
|---|---|---|---|---|
| Entity id, size, eye | 37, 1.3964844 x 1.5, eye 1.425 | 88, 1.3964844 x 1.6, eye 1.52 | 119, 1.3964844 x 1.6, eye 1.52 | 155, 1.3964844 x 1.6, eye 1.52 |
| Category | creature | creature | creature | monster |
| Attributes | chested base: `movement_speed` 0.175, `jump_strength` 0.5, health 53 base (spawn health 15 to 30 by 3.2) | same | `max_health` 15, `movement_speed` 0.2 | `max_health` 25 |
| Food | `horse_food` | `horse_food` | none (not tamed by food) | red mushroom (`zombie_horse_food`) |
| Breeds with | `Donkey.canMate` accepts a donkey or a horse (both able to parent); `Horse.canMate` accepts a donkey or a horse | `canMate` is not overridden, so it is the abstract false (read): mules cannot breed | not overridden: cannot breed | not overridden: cannot breed |
| Offspring | `Donkey.getBreedOffspring`: with a horse partner the offspring type is a mule, otherwise a donkey (read: the donkey class creates a mule for a horse partner and a donkey otherwise); `Horse.getBreedOffspring`: with a donkey partner a mule; stats by 3.2 | method returns a mule but is unreachable (`canMate` false) | a skeleton horse (unreachable) | a zombie horse (unreachable) |
| Chest | yes (metadata 19; right-click with a chest item and no chest sets the flag, plays the equip sound, consumes 1 and rebuilds the inventory; slot counts depend on `getInventoryColumns` and were not read) | yes | no | no |
| Taming | by riding (3.4) | by riding | an untamed skeleton horse cannot be interacted with (`mobInteract` returns PASS while untamed); it is tamed by the trap (below) | by riding (food red mushroom) |
| Goals specific | p0 Float, p3 Tempt(1.25, `horse_tempt_items`) in addBehaviourGoals of zombie horse; skeleton horse `addBehaviourGoals` registers nothing (it has its own movement goals: the trap goal at p1 when `isTrap`) | | | |
| Drops | leather `uniform(0,2)` | leather `uniform(0,2)` | bone `uniform(0,2)`, looting +U(0,1) | rotten flesh `uniform(2,3)`, looting +U(0,1) |
| Burn | no | no | no | in tag `burn_in_daylight`; undead tag (`zombies`, `undead`) |
| Natural spawn | plains/savanna entries in 1.5 (donkey) | none (breeding only) | none naturally; trap only | `checkMonsterSpawnRules` (monster lists of 20) |

Skeleton horse trap (`SkeletonTrapGoal`, goal p1, present only while the horse's trap flag is set): usable when a living player is within 10 blocks (`hasNearbyAlivePlayer`). On tick: the trap flag is cleared, the horse becomes tamed and an adult, a visual-only lightning bolt strikes the horse, a skeleton (finalised with the local difficulty, an iron helmet if it has no helmet, main hand and head items enchanted by the difficulty) is created and rides the horse, then 3 additional skeleton horses with riding skeletons are created (each tamed, adult, invulnerable for 60 ticks, persistent) with a random horizontal push (`triangle(0, 1.1485)` on x and z). A skeleton horse with a trap flag that is not persistent despawns after 18000 ticks. The trap flag is set by the world's thunder tick (`ServerLevel.tickThunder`, read): for each chunk tick while it is raining and thundering, with chance 1 in 100000 a random position of the chunk (`findLightningTargetAround`) is chosen; if it is raining there, the spawn-mobs game rule is on, `nextDouble()` is below `effective local difficulty x 0.01` and the block below is not in tag `lightning_rods`, a skeleton horse (spawn reason EVENT) is created with the trap flag set and age 0, placed at that position and added, and the lightning bolt there is visual-only; otherwise a normal bolt strikes.

Zombie horse spawn extra: when finalised with the spawn reason NATURAL (a zombie horse spawned naturally), a zombie (spawn reason JOCKEY) is created at the horse position, given an iron spear in the main hand and made to ride the horse.

Zombie horse stat genes (read, called from `ZombieHorse.randomizeAttributes` at spawn): jump strength `0.5 + (r1 + r2 + r3) / 15` (range 0.5 to 0.7); speed `(9 + r1 + r2 + r3) / 42.16` (range 0.2134 to 0.2845). Skeleton horse: jump strength by the shared formula of §3.2 (0.4 to 1.0).

### 3.7 Llama and trader llama

| Item | Llama | Trader llama |
|---|---|---|
| Entity | `minecraft:llama` id 79, 0.9 x 1.87, eye 1.7765 | `minecraft:trader_llama` id 138, same size |
| Attributes | chested base, `max_health` spawn gene 15 to 30; `movement_speed` 0.175 | same |
| Variant | metadata 21: 0 creamy, 1 white, 2 brown, 3 gray; random at spawn (uniform, group shares first member's variant); breeding: this or other parent 50/50 | same, but see spawn |
| Strength | metadata 20 INT, clamped to 1 to 5 on write. At spawn: `bound = 5` if `nextFloat() < 0.04` else 3 (read), strength = `1 + nextInt(bound)`. Chest capacity as a function of strength was not read in this round; nothing is asserted |
| Foal | strength = `nextInt(max(parent strengths)) + 1`, plus 1 with probability 0.03 (`nextFloat() < 0.03`); stats via 3.2; variant from either parent |
| Goals | p0 Float; p1 RunAroundLikeCrazy(1.2); p2 LlamaFollowCaravan(2.1); p3 RangedAttack(1.25, interval 40, range 20.0); p3 Panic(1.2); p4 Breed(1.0); p5 Tempt(1.25, item tag `llama_tempt_items` = hay block, false); p6 FollowParent(1.0); p7 WaterAvoidingRandomStroll(0.7); p8 LookAtPlayer(Player, 6.0); p9 RandomLookAround. Targets: p1 LlamaHurtByTarget; p2 LlamaAttackWolf (a wolf that is not tamed... or any wolf, 18 framework: NearestAttackableTarget) | trader llama: p1 Panic(2.0); target p1 TraderLlamaDefendWanderingTrader; p2 NearestAttackable(Zombie, must see = true, predicate: not a zombified piglin); p2 NearestAttackable(AbstractIllager, must see = true) (these add to the llama's goals) |
| Spit | `performRangedAttack` fires a `LlamaSpit` projectile: direction to the target (y from 1/3 of its height), horizontal speed scaled by 0.2 offset on y by `sqrt(dx^2+dz^2) * 0.2`, velocity 1.5, uncertainty from `rangedAttackUncertainty`; plays the spit sound |
| Caravan | `joinCaravan(head)` / `leaveCaravan` link llamas into a train (caravan head and tail fields) that the follow goal moves in line |
| Food | item tag `llama_food`: wheat, hay block; feeding table in 3.4 |
| Mate | other is a llama, both `canParent`, not itself |
| Drops | leather `uniform(0,2)` | leather `uniform(0,2)` |
| Spawn | biome list 1.5 (llama); trader llama appears with the wandering trader (§23); the trader llama spawns as a baby-less adult (age set 0 when spawned by an event) and has a despawn delay (`maybeDespawn` each tick) tied to its trader |

### 3.8 Camel and camel husk

| Item | Camel | Camel husk |
|---|---|---|
| Entity | id 19, creature, 1.7 x 2.375, eye 2.275 | id 20, monster, same box |
| Attributes | `max_health` 32, `movement_speed` 0.09, `jump_strength` 0.42, `step_height` 1.5 (over the base horse set) | same attributes; `chargeSpeedModifier` 4.0 (read; a method of the husk) |
| Persistence | none | `removeWhenFarAway` returns true; `interact` first calls `setPersistenceRequired` and then runs the camel interaction; it cannot be leashed while mob-controlled (a `Mob` rider) |
| Food | `camel_food`: cactus | `camel_husk_food`: rabbit foot |
| Breeding | cactus; `canMate`: other is a camel, both can parent; offspring is a camel | none (`canMate` false, `canFallInLove` false, `canBeABaby` false) |
| AI | Brain (see below) | the same brain family, with mob control: `isMobControlled` when its first passenger is a `Mob` (a jockey), cannot be leashed while mob-controlled; `removeWhenFarAway` returns true |
| Drops | none | rotten flesh `uniform(2,3)`, looting +U(0,1) |
| Spawn | desert, weight 1, group 1; `checkCamelSpawnRules`: block below in `camels_spawnable_on` (#sand), light > 8 | `checkSurfaceMonstersSpawnRules` (surface monster rule in 20) |

Camel Brain (18 framework: Brain system): core activity (priority 0): Swim(0.8), CamelPanic(4.0), LookAtTargetSink(45, 90), MoveToTargetSink, CountDownCooldownTicks(temptation), CountDownCooldownTicks(gaze). Idle activity: p0 SetEntityLookTargetSometimes(player, 6.0, uniform 30 to 60); p1 AnimalMakeLove(camel); p2 RunOne [FollowTemptation (weight 1), BabyFollowAdult(range = adult follow range, speed 2.5) unless sitting (weight 1)]; p3 RandomLookAround(uniform 150 to 250, max yaw 30, pitch 0 to 0); p4 RunOne (needs no walk target) [RandomStroll(2.0) unless sitting (1), SetWalkTargetFromLookTarget(2.0, 3) unless sitting (1), RandomSitting(20) (1), DoNothing(30 to 60) (1)].

Camel specifics: poses standing and sitting; sitting is stored in metadata 20 (last pose change tick: negative while sitting, the absolute game time otherwise; sitting if the value is negative). `sitDown` sets pose SITTING and stores `-gameTime`; `standUp` sets STANDING and stores `gameTime`. Two riders: right-clicking with the camel at fewer than 2 passengers and not a baby mounts (`CONSUME`); sneaking with an empty item (adult) opens the inventory (saddle). The dash: the rider's jump input, only when saddled, the dash cooldown is 0 and the camel is on the ground, performs a dash: velocity added = `normalize(look.xz) * (22.2222 * power * movement_speed * blockSpeedFactor)` horizontally plus `1.4285 * power * jumpPower` vertically; `dashCooldown = 55` ticks; metadata 19 (dash) set. Ridden speed = `movement_speed` plus a sprint bonus when the rider sprints and the dash cooldown is 0 (the bonus is `RUNNING_SPEED_BONUS` 0.1; the other constants: baby scale `BABY_SCALE` 0.6, dash cooldown 55 ticks, `DASH_MINIMUM_DURATION_TICKS` 5, `SITDOWN_DURATION_TICKS` 40, `STANDUP_DURATION_TICKS` 52, `IDLE_MINIMAL_DURATION_TICKS` 80, `SITTING_HEIGHT_DIFFERENCE` 1.43, `MAX_HEAD_Y_ROT` 30); a camel that is sitting or in a pose transition refuses to move and cannot jump. A forward move input while sitting stands the camel up.

## 4. Rabbit

| Item | Value |
|---|---|
| Entity | `minecraft:rabbit`, id 111, creature, 0.49 x 0.6, eye 0.59; baby 0.24 x 0.4 eye 0.39 |
| Attributes | `max_health` 3, `movement_speed` 0.3, `attack_damage` 3 |
| Food | `rabbit_food`: carrot, golden carrot, dandelion |
| Goals | p1 Float; p1 ClimbOnTopOfPowderSnow; p1 RabbitPanic(2.2); p2 Breed(0.8); p3 Tempt(1.0, `rabbit_food`, false); p4 RabbitAvoidEntity(Player, 8.0, 2.2, 2.2); p4 RabbitAvoidEntity(Wolf, 10.0, 2.2, 2.2); p4 RabbitAvoidEntity(Monster, 4.0, 2.2, 2.2); p5 RaidGarden; p6 WaterAvoidingRandomStroll(0.6); p11 LookAtPlayer(Player, 10.0) |
| Variants | metadata 18 INT = variant id: 0 brown, 1 white, 2 black, 3 white splotched ("black and white"), 4 gold, 5 salt, 99 evil ("killer bunny") |
| Spawn variant | `r = nextInt(100)` (read from `getRandomRabbitVariant`): biome in `spawns_white_rabbits`: `r < 80` white (id 1), else white splotched (id 3); biome in `spawns_gold_rabbits`: gold (id 4); otherwise `r < 50` brown (id 0), `r < 90` salt (id 5), else black (id 2). A group spawn reuses the first member's variant |
| Breeding variant | the offspring first takes the biome-based spawn variant of the birth position (the function above); then `nextInt(20) != 0` (95 percent): if the other parent is a rabbit, a random one of the two parents' variants (`nextBoolean`: the other parent's or this parent's); the remaining 5 percent keeps the biome variant |
| Killer bunny | setting variant 99: `armor` base +8; adds goal p4 MeleeAttack(1.4, true) and targets p1 HurtByTarget (no alert), p2 NearestAttackable(Player), p2 NearestAttackable(Wolf); attack-damage modifier `evil` +5.0 (ADD_VALUE); if unnamed gets the custom name "Killer Bunny" (translation `entity.minecraft.killer_bunny`). Setting any other variant removes the modifier |
| Jumping | constants read: `JUMP_DELAY_TICKS` 10, `PANIC_JUMP_DELAY_TICKS` 3, `JUMP_DURATION_IN_TICKS` 15, `BABY_JUMP_HEIGHT` 0.5, `ADULT_JUMP_HEIGHT` 1.5, `IDLE_MINIMAL_DURATION_TICKS` 180. Speed modifiers: stroll 0.6, breed 0.8, follow 1.0, flee 2.2, attack 1.4. Hop jump power: base 0.3; 0.2 when the move controller's speed modifier is at most 0.6; 0.5 when the next path node is more than 0.5 above the rabbit or when it is jumping and the wanted y is more than 0.5 above; the final power is the shared `getJumpPower(p / 0.42)`. After landing, `jumpDelayTicks` = 10 when the speed modifier is below 2.2, else 3 (read; this corrects an earlier ordering). The hop animation lasts 15 ticks. An evil rabbit with a target closer than 4 blocks (squared distance below 16) faces it and hops toward it |
| RaidGarden | needs the mob-griefing game rule. The rabbit wants more food only when `moreCarrotTicks` is 0 (`MORE_CARROTS_DELAY` 40: set to 40 after each carrot bite and decreased by `nextInt(3)` per tick). It walks to a carrot crop block, looks at it, and on arrival: if the crop age is 0 the block is replaced by air (flag 2) and then destroyed with item drops (the rabbit as the breaker); otherwise the crop age is reduced by 1 (flag 2); both cases emit game event block change and level event 2001 (break particles with the block's state id), set `moreCarrotTicks` 40, set the goal's next start tick 10 ticks ahead |
| Drops | pool 1: rabbit hide `uniform(0,1)`, looting +U(0,1); pool 2: raw rabbit, count 1, smelt, looting +U(0,1); pool 3: rabbit's foot (1), only killed by a player, chance `0.10` unenchanted, `0.13 + 0.03 x (looting level - 1)` enchanted (`random_chance_with_enchanted_bonus`, unenchanted 0.1, enchanted linear base 0.13 per level above first 0.03) |
| XP | 1 to 3 |
| Spawn | `checkRabbitSpawnRules` (§1.4), §1.5 |
| Powder snow | the type tag `powder_snow_walkable_mobs` lets rabbits, endermites, silverfish and foxes walk on powder snow |

## 5. Felines

### 5.1 Cat

| Item | Value |
|---|---|
| Entity | `minecraft:cat`, id 21, creature, 0.6 x 0.7, eye 0.35; passenger attachment y 0.5125; baby 0.3 x 0.35 eye 0.34375 |
| Attributes | `max_health` 10, `movement_speed` 0.3, `attack_damage` 3 |
| Food | `cat_food`: cod, salmon (raw) |
| Variants | metadata 20 CAT_VARIANT (registry cat_variant: all_black, black (default), british_shorthair, calico, jellie, persian, ragdoll, red, siamese, tabby, white); sound variant 24 (classic, royal); collar colour 23 default red (dye id 14) |
| Goals | p1 Float; p1 TamableAnimalPanic(1.5); p2 SitWhenOrdered; p3 CatRelaxOnOwner; p4 Tempt (`CatTemptGoal`, speed 0.6, item `cat_food`, scare-off flag true: the goal is kept in a field `temptGoal`); p5 CatLieOnBlock(1.1, 8); p6 FollowOwner(1.0, start 10.0, stop 5.0); p7 CatSitOnBlock(0.8); p8 LeapAtTarget(0.3); p9 OcelotAttack; p10 Breed(0.8); p11 WaterAvoidingRandomStroll(0.8, probability 1.0000001E-5); p12 LookAtPlayer(Player, 10.0). Targets: p1 NonTameRandomTarget(Rabbit, must see 0 = false); p1 NonTameRandomTarget(Turtle, false, baby-turtle-on-land selector) |
| Pose by speed | each server AI step: if the move controller has a wanted position: speed modifier exactly 0.6 = crouching and not sprinting; exactly 1.33 = standing and sprinting; otherwise standing, not sprinting; with no wanted position: standing, not sprinting |
| Taming | an untamed cat accepts raw cod or salmon: the item is consumed (`usePlayerItem`), then `tryToTame`: `nextInt(3) == 0` tames (owner set, sit order true, entity event 7), else entity event 6; `setPersistenceRequired`; eating sound. An untamed cat also begs: while the tempt goal is running and not tamed, every 100 ticks (`tickCount % 100 == 0`) it plays the "beg for food" sound |
| Tame interactions | owner + dye item (tag `cat_collar_dyes` = `#dyes`): sets the collar colour if different, consumes 1, persistent; owner + food while hurt (health below max): the shared tamable feeding routine consumes the item (not in creative), plays the eating sound and heals `1 x nutrition` of the item's food component (the two float parameters of the routine, both 1 for cats, are: the multiplier applied to the nutrition value and the heal amount used when the item has no food component; inferred from the branch shape); otherwise an owner right-click that no other rule consumes toggles the sit order (SUCCESS) |
| Offspring | variant from either parent 50/50; if the mother (`this`) is tame the kitten is tamed with the same owner and collar colour = `getMixedColor` of the parents' collars (dye-mix rule of §2.4) |
| Morning gift | `CatRelaxOnOwnerGoal` is usable when the cat is tame, not ordered to sit, its owner is a player who is sleeping within 10 blocks (distance squared at most 100) and the block at the owner's position is in `cats_can_lie_on` (a bed-facing offset is computed for the goal position). When it stops, if the owner's sleep timer is at least 100 and `nextFloat()` is below the environment attribute `cat_waking_up_gift_chance` at the cat's position, the cat gives a gift: it first moves to a random nearby position (if leashed, around its leash holder) by teleporting to x + `nextInt(11) - 5`, y + `nextInt(5) - 2`, z + `nextInt(11) - 5` relative to the starting block, never onto blocks in tag `cat_does_not_teleport_to`; then it drops one item of `gameplay/cat_morning_gift` (below) there. The chance is a day-timeline track: 0.0 from day tick 362 and 0.7 from day tick 23667 (constant easing, `maximum` modifier) |
| Morning gift table | weights: rabbit hide 10, rabbit foot 10, chicken 10, feather 10, rotten flesh 10, string 10, phantom membrane 2 (total 62), 1 roll |
| Natural spawner | `CatSpawner` (a world spawner): every 1200 ticks pick a random player; offset `8 + nextInt(24)` on each of x and z (read), multiplied by -1 when `nextBoolean()` is true and by +1 otherwise (read); the 20 x 20 area around the position must be loaded; if the spot is a valid spawn position: inside a village (`isCloseToVillage(pos, 2)`): spawn a cat if the number of occupied home-bed points of interest within 48 blocks is greater than 4 and fewer than 5 cats are within a 48 x 8 x 48 box (cats not persistent); else if the position lies in a structure piece of tag `cats_spawn_in` (swamp hut): spawn a persistent cat if no cat within a 16 x 8 x 16 box. A spawned cat is finalised with spawn reason NATURAL (variant by §1.6: swamp hut = all black) |
| Drops | string `uniform(0,2)` (no looting function) |
| Despawn | an untamed cat despawns when far away after existing 2400 ticks (`removeWhenFarAway` true when untamed and older than 2400 ticks) |
| Fall damage | cats are in `fall_damage_immune` |
| Spawn | `Animal` rule through the placement entry; no biome-list spawners; by `CatSpawner` and villages' start pieces |

### 5.2 Ocelot

| Item | Value |
|---|---|
| Entity | `minecraft:ocelot`, id 92, creature, 0.6 x 0.7, eye 0.595 (default), attachment y 0.6375, baby 0.3 x 0.35 eye 0.34375 |
| Attributes | `max_health` 10, `movement_speed` 0.3, `attack_damage` 3 |
| Food | `ocelot_food`: raw cod, raw salmon |
| Goals | p1 Float; p3 Tempt (stored goal, shared with distrust logic); p7 LeapAtTarget(0.3); p8 OcelotAttack; p9 Breed(0.8); p10 WaterAvoidingRandomStroll(0.8, 1.0000001E-5); p11 LookAtPlayer(Player, 10.0). Targets: p1 NearestAttackable(Chicken, 0 = no sight check); p1 NearestAttackable(Turtle, 10, no sight, no persistence, baby-turtle-on-land selector). While not trusting: goal p4 OcelotAvoidEntity(Player, 16.0, 0.8, 1.33) is registered (removed once trusting) |
| Trust | metadata 18 boolean. While the tempt goal runs, the ocelot is not trusting, the item is food and the player is within 3 blocks (`distanceToSqr < 9`): the item is used; on the server `nextInt(3) == 0` sets trusting (heart particles via `spawnTrustingParticles(true)`, event 41) else particles of smoke (event 40); returns success |
| Despawn | despawns when far away if not trusting and older than 2400 ticks |
| Breeding | offspring is an ocelot (`EntityTypes.OCELOT.create`); no trust is copied in `getBreedOffspring` |
| Spawn | the entry in 1.5 is in category monster in this artifact; `checkOcelotSpawnRules` (2/3 pass: `nextInt(3) != 0`) |
| Drops | none (empty table), XP 1 to 3 |

## 6. Wolf

### 6.1 Wolf

| Item | Value |
|---|---|
| Entity | `minecraft:wolf`, id 152, creature, 0.6 x 0.85, eye 0.68, attachment y 0.81875 |
| Attributes | wild: `max_health` 8, `movement_speed` 0.3, `attack_damage` 4 (tamed: `max_health` 40, health set to 40 on taming) |
| Food | `wolf_food`: tag `meat` (beef, chicken, cooked beef, cooked chicken, cooked mutton, cooked porkchop, cooked rabbit, mutton, porkchop, rabbit, rotten flesh), cod, cooked cod, salmon, cooked salmon, tropical fish, pufferfish, rabbit stew |
| Goals | p1 Float; p1 TamableAnimalPanic(1.5, damage tag `panic_environmental_causes`); p2 SitWhenOrdered; p3 WolfAvoidEntity(Llama, 24.0, 1.5, 1.5); p4 LeapAtTarget(0.4); p5 MeleeAttack(1.0, true); p6 FollowOwner(1.0, 10.0, 2.0); p7 Breed(1.0); p8 WaterAvoidingRandomStroll(1.0); p9 Beg(8.0); p10 LookAtPlayer(Player, 8.0); p10 RandomLookAround. Targets: p1 OwnerHurtBy; p2 OwnerHurtTarget; p3 HurtByTarget(alert others false... `HurtByTarget(no ignores)`, the artifact registers it with an empty ignore list and calls `setAlertOthers`); p4 NearestAttackable(Player, random interval 10, must see true, must reach false, predicate = angry-at test); p5 NonTameRandomTarget(Animal, no sight check, `PREY_SELECTOR` = the target is a sheep, a rabbit or a fox (read)); p6 NonTameRandomTarget(Turtle, baby-turtle-on-land); p7 NearestAttackable(AbstractSkeleton, no sight check); p8 ResetUniversalAnger(true) |
| Variants | metadata 23 WOLF_VARIANT, selected by §1.6 (pale default); sound variant 24 (7 sound variants: angry, big, classic, cute, grumpy, puglin, sad; random); collar colour metadata 21 (default red, dye id 14) |
| Taming | an untamed, non-angry wolf with a bone (right-click on the server): the bone is consumed (not creative), `tryToTame`: `nextInt(3) == 0` tames (owner, `max_health` becomes 40 and heals to 40, navigation stops, target cleared, sit order true, event 7) else event 6; the interaction returns `SUCCESS_SERVER` |
| Tamed interactions | food while hurt (health below max): the shared tamable feeding routine consumes the item, plays the eating sound and heals `2 x nutrition` of the item's food component (parameters 2 and 2: multiplier and no-food fallback amount, same meaning as for cats); dye in `wolf_collar_dyes` (`#dyes`) by the owner: sets collar colour if different; wolf armour (an item equippable in the body slot) by the owner when not wearing armour and not a baby: equips one copy in the body slot (dropped when killed); a sitting owner-owned wolf wearing damaged armour with a valid repair item (armadillo scute): consumes 1, repairs `floor(max durability x 0.125)` points (`ARMOR_REPAIR_UNIT` 0.125), plays the repair sound; otherwise the base interaction; when the base interaction does not consume and the player is the owner: toggles the sit order; on sit the wolf stops jumping, navigation stops, target cleared (the stand-up path also stops) |
| Armour | `canArmorAbsorb`: body armour is wolf armour and the damage source is not in tag `bypasses_wolf_armor`: the armour absorbs the hit instead of the wolf: damage `ceil(amount)` is applied to the item; the crack stage (`Crackiness.WOLF_ARMOR`) is compared before and after; when it changes the "armour crack" sound plays and 20 armadillo scute item particles (spread 0.2, 0.1, 0.2, speed 0.1) are sent at the wolf |
| Wet shake | on the server, when wet, not already shaking, not path-finding and on the ground, it starts a shake (event 8). While shaking `shakeAnim` grows by 0.05 per tick; the shake ends at 2.0 and also stops (event 56 cancel) if the wolf is in water or rain again; splash particles appear after anim 0.4 |
| Hurt | any damage that is not ignored makes a tamed sitting wolf stand (`setOrderedToSit(false)`) |
| Anger | persistent anger (18 framework: NeutralMob): `PERSISTENT_ANGER_TIME` ticks per sample; metadata 22 stores the end time; `updatePersistentAnger` runs every server tick; an angry wolf's tail angle is a constant (1.5393804 rad) |
| `wantsToAttack` | false when the target is a creeper, a ghast or an armor stand; a tamed wolf target: attack only when its owner differs from this wolf's owner; a player target: only if the owner player can harm that player (PVP); a horse family animal target that is tamed: no attack; tamed targets of the owner are skipped |
| Breeding | `canMate`: both are tame wolves, neither sitting, both in love; the pup variant is this or the other parent's, 50/50 (`nextBoolean`); if `this` parent is tame the pup is tamed with the same owner and its collar is `getMixedColor` of the two collars; the pup gets a random sound variant (all read) |
| Spawn | biome list 1.5 (max cluster size 8); `checkWolfSpawnRules` (§1.4) |
| Drops | none; XP 1 to 3 |
| Pack | a group spawn uses `WolfPackData`: every wolf in the group inherits the first wolf's variant |
| Tamed wolf behaviours | follows the owner (`FollowOwner(1.0, 10.0, 2.0)`: begins when farther than 10, stops within 2), teleports to the owner when farther than 12 (shared with cats and parrots in 18 framework: taming base), sits when ordered |

## 7. Fox

| Item | Value |
|---|---|
| Entity | `minecraft:fox`, id 55, creature, 0.6 x 0.7, eye 0.4, attachment y 0.6375 (x offset -0.25), immune to fire damage types as per the `immuneTo` list |
| Attributes | `max_health` 10, `movement_speed` 0.3, `attack_damage` 2, `safe_fall_distance` 5, `follow_range` 32 |
| Food | `fox_food`: sweet berries, glow berries |
| Goals | p0 FoxFloat; p0 ClimbOnTopOfPowderSnow; p1 Faceplant; p2 FoxPanic(2.2); p3 FoxBreed(1.0); p4 AvoidEntity(Player, 16.0, 1.6, 1.4, trusted players excluded); p4 AvoidEntity(Wolf, 8.0, 1.6, 1.4, only when the wolf is not tamed... predicate λ); p4 AvoidEntity(PolarBear, 8.0, 1.6, 1.4); p5 StalkPrey; p6 FoxPounce; p6 SeekShelter(1.25); p7 FoxMeleeAttack(1.2, true); p7 Sleep; p8 FoxFollowParent(1.25); p9 FoxStrollThroughVillage(32, 200); p10 FoxEatBerries(1.2, 12, 1); p10 LeapAtTarget(0.4); p11 WaterAvoidingRandomStroll(1.0); p11 FoxSearchForItems; p12 FoxLookAtPlayer(Player, 24.0); p13 PerchAndSearch. Targets: p3 DefendTrustedTarget(LivingEntity, no sight, ...); the remaining target goals depend on the variant (below) and are added in `setTargetGoals` |
| Variants | metadata 18: 0 red, 1 snow; chosen at spawn by biome: snow if the biome is in `spawns_snow_foxes` else red; breeding: 50/50 parent's variant. A group shares the first member's variant (`FoxGroupData`); when the group size reaches 2 or more the member after the second spawns as a baby (age -24000) |
| Target goals by variant | red: p4 land-animal target, p4 turtle-egg target, p6 fish target; snow: p4 fish target, p6 land-animal target, p6 turtle-egg target (the targets: chicken, rabbit, small fish, turtle eggs; exact predicates in 18 framework) |
| Flags | metadata 19 BYTE: bit 1 sitting, bit 4 crouching, bit 8 interested, bit 16 pouncing, bit 32 sleeping, bit 64 faceplanted, bit 128 defending (read from the flag getters and setters) |
| Trust | metadata 20 and 21 hold up to two trusted player references; a fox trusts the players that bred it; trusted players are not avoided and are defended |
| Held item | main hand; new adult foxes spawned in `finalizeSpawn` get `populateDefaultEquipmentSlots`: with probability 0.2 (`nextFloat() < 0.2`) a roll `r = nextFloat()`: r < 0.05 emerald; r < 0.2 egg; r < 0.4 rabbit hide or rabbit foot (`nextBoolean`); r < 0.6 wheat; r < 0.8 leather; otherwise feather. A fox can pick up an item when its main hand is empty, or (cooldown logic) swap when holding non-food and the new item is food and `ticksSinceEaten > 0`; picking up keeps 1 of the stack (drops the rest) and guarantees the drop; foxes eat consumable food (an item with both `food` and `consumable` components) when not targeting, on ground and awake |
| Death drops | the held main-hand item is dropped (`dropAllDeathLoot`); no loot table |
| Spawn | `checkFoxSpawnRules` (§1.4) with `NO_RESTRICTIONS` placement; §1.5 |
| XP | 1 to 3 |

## 8. Panda

| Item | Value |
|---|---|
| Entity | `minecraft:panda`, id 97, creature, 1.3 x 1.25, eye 1.0625 (default) |
| Attributes | `movement_speed` 0.15, `attack_damage` 6; `max_health` is the attribute default 20 (read: `Attributes.MAX_HEALTH` default 20.0, no explicit panda value) |
| Food | `panda_food`: bamboo |
| Goals | p0 Float; p2 PandaPanic(2.0); p2 PandaBreed(1.0); p3 PandaAttack(1.2, true); p4 Tempt(1.0, `panda_food`, false); p6 PandaAvoid(Player, 8.0, 2.0, 2.0); p6 PandaAvoid(Monster, 4.0, 2.0, 2.0); p7 PandaSit; p8 PandaLieOnBack; p8 PandaSneeze; p9 PandaLookAtPlayer(Player, 6.0); p10 RandomLookAround; p12 PandaRoll; p13 FollowParent(1.25); p14 WaterAvoidingRandomStroll(1.0). Target: p1 PandaHurtByTarget (`HurtByTarget` subclass, ignore list empty) |
| Genes | metadata 21 (main gene) and 22 (hidden gene), each a gene id: 0 normal, 1 lazy, 2 worried, 3 playful, 4 brown, 5 weak, 6 aggressive. Recessive genes (brown, weak) are those flagged in the gene table (4 and 5); all others are dominant |
| Visible trait | `variant` = main gene if the main gene is dominant; if it is recessive, the main gene only if the hidden gene equals it, else normal |
| Random gene | one draw `nextInt(16)` (read from `Panda$Gene.getRandom`): 0 lazy; 1 worried; 2 playful; 4 aggressive; any other value below 9 (3, 5, 6, 7, 8) weak; 9 and 10 brown; 11 to 15 normal. Probabilities: lazy 1/16, worried 1/16, playful 1/16, aggressive 1/16, weak 5/16, brown 2/16, normal 5/16 |
| Spawn | main and hidden genes are random draws, then `setAttributes`; a group spawns with baby chance 0.2 (`AgeableMobGroupData(0.2)`) |
| Attribute effects | weak trait: `max_health` 10; lazy trait: `movement_speed` 0.07 |
| Breeding genes | both parents: with 1/2 the child's main gene is one of parent A's two genes (50/50) and the hidden gene is one of parent B's genes, else swapped (main from B, hidden from A); with a single parent (breeding cause missing): main from the parent's genes and hidden random, or the reverse; then each of main and hidden is replaced by a random gene with probability 1/32 (`nextInt(32) == 0`); `setAttributes` runs on the baby |
| Flags | metadata 23 BYTE: bit 2 sneezing, bit 4 rolling, bit 8 sitting, bit 16 on back (read from the setters) |
| Moods | worried panda: sits (and stops eating) during thunderstorms when not in water; `isScared` = worried and thundering: interactions return PASS. Which goals react to the lazy, playful and aggressive traits (lying on the back, rolling, attacking when hit) was not traced beyond the goal list above |
| Sneeze | a panda sneezes randomly (counter metadata 19 counts up from the sneeze start: pre-sneeze sound at counter 1, sneeze at counter > 20), then particles, a sneeze sound, a jump of every non-baby panda on the ground within 10 blocks (`inflate(10)`), and the loot table `gameplay/panda_sneeze` (1 roll: slime ball weight 1, empty weight 699, so 1 in 700) drops at the panda when the mob-drops game rule is on |
| Eating | when sitting, not scared, not eating, holding an item (bamboo etc.), `nextInt(80) == 1` starts eating (`eat(true)`); eating counter metadata 20 increases; after 80 ticks, `nextInt(20) == 1` per tick: if the counter > 100 and the held item is in tag `panda_eats_from_ground` the item is consumed and the panda stops sitting/eating |
| Interaction | scared: PASS; a panda on its back: right-click rights it; food (bamboo): a baby ages up with the standard formula (`ageUp((-age / 20) * 0.1)`), an adult with age 0 that can fall in love gets in love (only when not a baby); other food use also sets `gotBamboo` when it has a target |
| Item pickup | when the main hand is empty and the panda can eat the item (bamboo and cake-like items by `canPickUpAndEat`): picks it up and holds it (guaranteed drop) |
| Drops | bamboo x1 (fixed, no looting function); XP 1 to 3 |
| Spawn | jungle and bamboo jungle, §1.5; `checkAnimalSpawnRules`, `NO_RESTRICTIONS` placement |

## 9. Polar bear

| Item | Value |
|---|---|
| Entity | `minecraft:polar_bear`, id 105, creature, 1.4 x 1.4 (eye default 1.19), immune to freezing (`freeze_immune_entity_types`) |
| Attributes | `max_health` 30, `follow_range` 20, `movement_speed` 0.25, `attack_damage` 6 |
| Food | none (`isFood` is false; it cannot be bred) |
| Goals | p0 Float; p1 PolarBearMeleeAttack (see below); p1 Panic(2.0, with a condition predicate that was not read); p4 FollowParent(1.25); p5 RandomStroll(1.0); p6 LookAtPlayer(Player, 6.0); p7 RandomLookAround. Targets: p1 PolarBearHurtBy (alerts adults only); p2 PolarBearAttackPlayers (usable only when the bear is an adult and a baby polar bear is within 8 x 4 x 8 of it, in addition to the normal target rules); p3 NearestAttackable(Player, 10, true, false, angry-at predicate); p4 NearestAttackable(Fox, 10, true, true, predicate λ not read); p5 ResetUniversalAnger(false) |
| Anger | persistent anger timer `PERSISTENT_ANGER_TIME` per sample (18 framework: NeutralMob), updated every server tick |
| Melee goal | if the target is within reach the bear attacks (`doHurtTarget`), cooldown reset, standing false. If the squared distance is below `(target width + 3)^2` and the cooldown is not ready: stand false and reset after the attack time; when 10 or fewer ticks remain until the next attack the bear stands up (`setStanding(true)`) and plays the warning sound; beyond that distance it resets the cooldown and lies down. The standing flag is metadata 18 and also changes the bounding box when it is true (client animation counter 0 to 6) |
| Spawn | frozen ocean, deep frozen ocean, ice spikes, snowy plains (weight 1, group 1 to 2); `checkPolarBearSpawnRules` (§1.4) |
| Drops | one pool: cod (weight 3, count `uniform(0,2)`, smelt, looting +U(0,1)) or salmon (weight 1, count `uniform(0,2)`, smelt, looting +U(0,1)) |
| XP | 1 to 3 |

## 10. Goat

| Item | Value |
|---|---|
| Entity | `minecraft:goat`, id 63, creature, 0.9 x 1.3 (eye default 1.105), passenger y 1.1125; baby dimensions scaled; while in the LONG_JUMPING pose the adult box is used |
| Attributes | `max_health` 10, `movement_speed` 0.2, `attack_damage` 2 |
| Food | `goat_food`: wheat |
| Metadata | 18 screaming (boolean), 19 has left horn, 20 has right horn |
| Brain | sensors per `Goat` brain provider; activities (priority order of selection in `updateActivity`): RAM, LONG_JUMP, IDLE |
| Core (priority 0) | Swim(0.8), AnimalPanic(2.0), LookAtTargetSink(45, 90), MoveToTargetSink, three CountDownCooldownTicks (temptation, long-jump, ram cooldowns) |
| Idle | p0 SetEntityLookTargetSometimes(Player, 6.0, uniform 30 to 60); p0 AnimalMakeLove(goat); p1 FollowTemptation(speed 1.25 constant); p2 BabyFollowAdult(range uniform 5 to 16, speed 1.25); p3 RunOne[RandomStroll(1.0) weight 2, SetWalkTargetFromLookTarget(1.0, 3) weight 2, DoNothing(30 to 60) weight 1]. Entry condition: ram cooldown and long-jump cooldown memories present (cooldown running) |
| Long jump | p0 LongJumpMidJump(time between jumps uniform 600 to 1200, step sound); p1 LongJumpToRandomPos(cooldown uniform 600 to 1200, max horizontal 5, max vertical 5, velocity 3.5714288, sound). Entry: not tempted, no breed target, no walk target, long-jump cooldown absent |
| Ram | p0 RamTarget(cooldown after ramming: uniform 600 to 6000, screaming goat 100 to 300; targeting conditions `RAM_TARGET_CONDITIONS` = combat targeting plus a selector: reject goats, reject armor stands unless mob griefing is on, require the target inside the world border; ramming speed multiplier `SPEED_MULTIPLIER_WHEN_RAMMING` 3.0; knockback force `ADULT_RAM_KNOCKBACK_FORCE` 2.5 for adults and `BABY_RAM_KNOCKBACK_FORCE` 1.0 for babies; horn-break and impact sounds by screaming or normal); p1 PrepareRamNearestTarget(minimum cooldown per goat kind (screaming 100 or regular 600), `RAM_MIN_DISTANCE` 4, `RAM_MAX_DISTANCE` 7, speed `SPEED_MULTIPLIER_WHEN_PREPARING_TO_RAM` 1.25, same targeting conditions, `RAM_PREPARE_TIME` 20 ticks, prepare sound screaming or normal). Entry: not tempted, no breed target, ram cooldown absent |
| Goat constants | `GOAT_FALL_DAMAGE_REDUCTION` 10; `ADULT_ATTACK_DAMAGE` 2, `BABY_ATTACK_DAMAGE` 1; `BABY_SCALE` 0.55 (baby box 0.45 x 0.65, eye 0.59375, passenger y 0.53125); `LONG_JUMPING_DIMENSION_SCALE_FACTOR` 0.7; `GOAT_SCREAMING_CHANCE` 0.02; `UNIHORN_CHANCE` 0.1; long-jump limits `MAX_LONG_JUMP_HEIGHT` 5, `MAX_LONG_JUMP_WIDTH` 5, `MAX_JUMP_VELOCITY_MULTIPLIER` 3.5714288; sensors: nearest living entities, nearest players, nearest items, nearest adult, hurt-by, food temptations |
| Cooldown start | at spawn and at breeding: `LONG_JUMP_COOLDOWN` = sample uniform(600,1200); `RAM_COOLDOWN` = sample uniform(600,6000) (`initMemories`) |
| Screaming | metadata 18; at spawn `nextDouble() < 0.02` (2 percent); offspring: one of the parents chosen 50/50 and if that parent is a goat and is not screaming, a 2 percent roll makes the kid scream, if the chosen parent is screaming the kid screams (the artifact sets screaming = parent screaming OR roll) |
| Horns | at spawn, adult goats: `nextFloat() < 0.1` removes one horn (left or right 50/50); baby goats grow both horns; `dropHorn` (called from the ram behaviour's horn-break callback; the block tag `snaps_goat_horn` exists = overworld natural logs, stone, packed ice, iron ore, coal ore, copper ore, emerald ore, but the ram code that tests it was not read in this round; nothing is asserted) drops one remaining horn (not for babies): the item is a goat horn whose instrument is a random element chosen with a random source seeded by the goat's uuid hash from instrument tag `screaming_goat_horns` for screaming goats, else `regular_goat_horns` (the first is the name read by tag file; the second is read in code); the item entity spawns at the goat with velocity x,z `U(-0.2, 0.2)`, y `U(0.3, 0.7)` |
| Milk | right-click an adult with a bucket: milking sound, bucket becomes milk bucket (same rule as the cow) |
| Spawn | `checkGoatSpawnRules` (§1.4); frozen peaks, jagged peaks, snowy slopes |
| Drops | none (empty table) |

## 11. Frog and tadpole

### 11.1 Frog

| Item | Value |
|---|---|
| Entity | `minecraft:frog`, id 56, creature, 0.5 x 0.5 (eye default 0.425) |
| Attributes | `movement_speed` 1.0, `max_health` 10, `attack_damage` 10, `step_height` 1.0 |
| Food (breeding) | `frog_food` item tag: slime ball |
| Entity food (tongue) | entity tag `frog_food`: slime, magma cube; a cube mob qualifies only when its size is 1 |
| Variants | metadata 18 (cold, temperate, warm; §1.6) |
| Brain | sensors: nearest living entities, hurt-by, frog attackables, frog temptations, is-in-water. Activities in selection order: TONGUE, LAY_SPAWN, LONG_JUMP, SWIM, IDLE |
| Core | AnimalPanic(2.0), LookAtTargetSink(45, 90), MoveToTargetSink, CountDownCooldownTicks(temptation), CountDownCooldownTicks(long jump) |
| Idle (needs not mid-long-jump and not in water) | p0 SetEntityLookTargetSometimes(Player, 6.0, 30 to 60); p0 AnimalMakeLove(frog); p1 FollowTemptation(speed 1.25); p2 StartAttacking (target from `NEAREST_ATTACKABLE` memory when `canAttack`); p3 TryFindLand(6, 1.0); p4 RunOne (needs no walk target) [RandomStroll(1.0) w1, SetWalkTargetFromLookTarget(1.0, 3) w1, Croak w3, a conditional behaviour w2] |
| Swim (needs in water) | p0 look; p1 FollowTemptation(1.25); p2 StartAttacking; p3 TryFindLand(8, 1.5); p5 gate (no walk target; ordered, try all) [RandomStroll swim(0.75) w1, RandomStroll(1.0) w1, SetWalkTargetFromLookTarget(1.0, 3) w1, conditional w5] |
| Lay spawn (needs pregnant) | p0 look; p1 StartAttacking; p2 TryFindLandNearLiquid(8, 1.0, fluid tag `frog_tries_to_find_land_near`); p3 TryLaySpawnOnFluidNearLand(frogspawn block); p4 RunOne[RandomStroll(1.0) w2, SetWalkTargetFromLookTarget(1.0, 3) w1, Croak w2, conditional w1] |
| Long jump (needs not tempted, no breed target, cooldown absent, not in water) | p0 LongJumpMidJump(uniform 100 to 140, frog step sound); p1 LongJumpToPreferredBlock(uniform 100 to 140, height 2 to 4, velocity 3.5714288, block tag `frog_prefer_jump_to` weight 0.5) |
| Tongue (attack target present) | StopAttackingIfTargetInvalid; ShootTongue: sets the tongue target (metadata 19), walks toward the target at speed 2.0 (path refreshed every 10 ticks); when the target is within 1.75 blocks plays the tongue sound, pose USING_TONGUE, pulls the target (velocity toward the frog, magnitude 0.75); after a 6-tick eat animation the frog hurts the target (`doHurtTarget`), plays the eat sound (volume 2), and removes the target when it dies (reason KILLED) |
| Breeding | slime ball; the result is a frogspawn block placed on water near land by the pregnant frog (`TryLaySpawnOnFluidNearLand`). Frogspawn block (`FrogspawnBlock`, read): on placement a block tick is scheduled after `nextInt(3600, 12000)` ticks; when it ticks, if the block can still survive it is destroyed, the hatch sound plays and `nextInt(2, 6)` tadpoles (2 to 5) are created (spawn reason BREEDING, persistent) at random small offsets around the block, y - 0.5 and a random yaw; if it can no longer survive it is just destroyed. Constants `FROG_FALL_DAMAGE_REDUCTION` 5 |
| Spawn | `checkFrogSpawnRules` (§1.4), swamp and mangrove swamp, weight 10, group 2 to 5 |
| Drops | none; XP 1 to 3 |

### 11.2 Tadpole

| Item | Value |
|---|---|
| Entity | `minecraft:tadpole`, id 134, creature, 0.4 x 0.3, eye 0.195 |
| Attributes | `movement_speed` 1.0, `max_health` 6 |
| Growth | age counts up by 1 per tick on the server unless age-locked; at 24000 ticks (`ticksToBeFrog`) it converts into a frog (`convertTo(frog)`, the conversion framework in 18, the new frog keeps persistence and the variant by its own `finalizeSpawn`) |
| Feeding | right-click with `frog_food` (slime ball): item consumed, `ageUp(getSpeedUpSecondsWhenFeeding(ticksLeftUntilAdult))` (the same `(ticks / 20) * 0.1` seconds formula, applied as ticks x 20) and happy villager particles; ignored when age-locked. Golden dandelion toggles the age lock |
| Bucket | `Bucketable`: a water bucket picks it up (the bucket item saves its data) |
| Brain | core: AnimalPanic(2.0), LookAtTargetSink(45, 90), MoveToTargetSink, CountDownCooldownTicks(temptation). Idle: p0 SetEntityLookTargetSometimes(Player, 6.0, 30 to 60); p1 FollowTemptation(1.25); p2 gate (no walk target; ordered, try all) [RandomStroll swim(0.5) w2, SetWalkTargetFromLookTarget(0.5, 3) w3, conditional w5] |
| Drops | none (empty table) |

## 12. Turtle

| Item | Value |
|---|---|
| Entity | `minecraft:turtle`, id 141, creature, 1.2 x 0.4, passenger attachment y 0.55625 |
| Attributes | `max_health` 30, `movement_speed` 0.25, `step_height` 1.0 |
| Food | `turtle_food`: seagrass |
| Goals | p0 TurtlePanic(1.2); p1 TurtleBreed(1.0); p1 TurtleLayEgg(1.0); p2 Tempt(1.1, `turtle_food`, false); p3 TurtleGoToWater(1.0); p4 TurtleGoHome(1.0); p7 TurtleTravel(1.0); p8 LookAtPlayer(Player, 8.0); p9 TurtleRandomStroll(1.0, interval 100) |
| Home | `setHomePos` at spawn to its block position; egg-laying is only usable when the turtle has an egg and its home position is within 9 blocks |
| Breeding | when two turtles breed, neither lays an offspring directly: the female (the one that breeds) gets `hasEgg` (metadata 18) set, both get age +6000, love reset, and an experience orb of `1 + nextInt(7)` XP is spawned (when mob-drops is on). A turtle with an egg cannot fall in love |
| Laying | the egg goal walks to the home beach, then the turtle digs: `layEggCounter` counts up; the first tick starts laying (metadata 19 true); at more than 200 ticks it plays the lay sound (volume 0.3, pitch `0.9 + 0.2 * rand`), places a turtle egg block with `1 + nextInt(4)` eggs on the block above the sand, clears `hasEgg` and `layingEgg`, and sets love time to 600 (the turtle can breed again). While laying, every 5 ticks it spawns block-break particles of the sand below |
| Growing | when a baby turtle grows up (`ageBoundaryReached` for a non-baby) and mob drops are on, it drops one item of `gameplay/turtle_grow` (a scute) via the gift path |
| Fluid | not pushed by fluid; `travelInWater` is overridden |
| Drops | pool 1: seagrass (weight 3, count `uniform(0,2)`, looting +U(0,1)), 1 roll; pool 2: a bowl, only when the damage source is in tag `is_lightning` |
| Spawn | beach, weight 5, group 2 to 5; `checkTurtleSpawnRules` (§1.4); baby scale `BABY_SCALE` 0.3; the egg-hatch chance is the environment attribute `turtle_egg_hatch_chance`, a step track (`ease` constant, `maximum` modifier) of the day timeline: value 1.0 from day tick 21062 and 0.002 from day tick 21905 (no interpolation) |
| XP | 1 to 3 |

## 13. Armadillo

| Item | Value |
|---|---|
| Entity | `minecraft:armadillo`, id 4, creature, 0.7 x 0.65, eye 0.26 |
| Attributes | `max_health` 12, `movement_speed` 0.14 |
| Food | `armadillo_food`: spider eye |
| State | metadata 18: 0 idle, 1 rolling (animation 10 ticks), 2 scared (50 ticks), 3 unrolling (30 ticks); the numbers are the state ids and animation durations |
| Brain | activities PANIC then IDLE; core: Swim(0.8), ArmadilloPanic(2.0), LookAtTargetSink(45, 90), a danger-detection behaviour, CountDownCooldownTicks(temptation), CountDownCooldownTicks(gaze), a rolling-out behaviour; idle: p0 SetEntityLookTargetSometimes(Player, 6.0, 30 to 60); p1 AnimalMakeLove(armadillo, speed 1.0, ...); p2 RunOne[FollowTemptation (speed 1.25 adult, 2.0 baby) w1, BabyFollowAdult(range uniform 5 to 16, 1.25) w1]; p3 RandomLookAround(uniform 150 to 250, 30, 0, 0); p4 RunOne (no walk target) [RandomStroll(1.0) w1, SetWalkTargetFromLookTarget(1.0, 3) w1, DoNothing(30 to 60) w1]. Panic activity (needs `danger_detected_recently` and not panicking): p0 ArmadilloBallUp |
| Danger | `isScaredBy(entity)` (read): false unless the entity's box intersects the armadillo's box inflated by (7, 2, 7); true for entities in tag `undead`; true for its last attacker; for a player: false for spectators, otherwise true when the player is sprinting or is a passenger, else false; false for everything else |
| Rolling | `rollUp`: not already scared; stops movement, resets love, game event, roll sound, state ROLLING; the state switches to SCARED after the rolling animation duration (10 ticks); `rollOut` returns to IDLE with the unroll-finish sound |
| Damage | while scared, incoming damage `amount` is replaced by `(amount - 1) / 2`; damage from a living attacker sets the memory `danger_detected_recently` for 80 ticks and (if it can stay rolled up) rolls up; damage in tag `panic_environmental_causes` rolls out |
| Scutes | `scuteTime` counts down; at 0 (and if drops are allowed) one item of `gameplay/armadillo_shed` (armadillo scute) is dropped, sound with pitch variation, game event place, and the next time is `nextInt(6000) + 6000` ticks (`20 * 60 * 5` = 6000 each, so 6000 to 11999) |
| Brushing | right-click with a brush on a non-baby, non-scared armadillo that can shed (`brushOffScute`): returns success and the brush loses 16 durability; interacting while scared fails (FAIL) |
| Spawn | savanna family (weight 10, group 2 to 3), badlands family (weight 6, group 1 to 2); `checkArmadilloSpawnRules`; `BABY_SCALE` 0.6; `SCARE_CHECK_INTERVAL` 80, scare distance 7 horizontal and 2 vertical, `MAX_HEAD_ROTATION_EXTENT` 32.5 |
| Drops | none; XP 1 to 3 |

## 14. Sniffer

| Item | Value |
|---|---|
| Entity | `minecraft:sniffer`, id 122, creature, 1.9 x 1.75, eye 1.05, name tag offset 2.05; digging box height `height - 0.4` with eye 0.81 |
| Attributes | `max_health` 14, `movement_speed` 0.1 |
| Food | `sniffer_food`: torchflower seeds |
| Baby start age | -48000 ticks (overrides the common -24000 of §1.2); digging constants: `DIGGING_DROP_SEED_OFFSET_TICKS` 120, particle delay 1700 ticks, particle duration 6000 ticks, particle amount 30 |
| State | metadata 18 id: 0 idling, 1 feeling happy, 2 scenting, 3 sniffing, 4 searching, 5 digging, 6 rising; metadata 19 = tick at which the seed drops while digging |
| Brain | memory `sniffer_explored_positions` (list, newest first, capped to 20 stored, 21 after insertion); activities in selection order: DIG, SNIFF, IDLE |
| Core | Swim(0.8), a panic behaviour (2.0), MoveToTargetSink(500, 700), CountDownCooldownTicks(temptation) |
| Idle (requires not digging) | p0 AnimalMakeLove(sniffer); p1 FollowTemptation (speed 1.25 adult, 3.5 baby); p2 LookAtTargetSink(45, 90); p3 FeelingHappy(40, 100); p4 RunOne[SetWalkTargetFromLookTarget(1.0, 3) w2, Scenting(40, 80) w1, Sniffing(40, 80) w1, SetEntityLookTarget(Player, 6.0) w1, RandomStroll(1.0) w1, DoNothing(5, 20) w2] |
| Sniff | requires not panicking, a sniffing target and a walk target present; behaviour Searching |
| Digging | `canDig`: not panicking, not tempted, not baby, not in water, on ground, not a passenger, and the block below the head position (`position + forward * 2.25`) is in `sniffer_diggable_block` and not in the explored list (same dimension and position), with a reachable path; on dig start metadata 19 = `tickCount + 120` and entity event 63; when `tickCount` equals metadata 19 the seed drops: one item of `gameplay/sniffer_digging` (torchflower seeds or pitcher pod, 1 roll, equal weights) is thrown out as an item entity with default pickup delay at the head block; the explored position is stored |
| Pathing | `onPathfindingDone` sets the water path malus to -1 (sniffers avoid water in paths) |
| Breeding | torchflower seeds (`sniffer_food`); what the breeding produces and how it hatches was not read in this round; nothing is asserted (Open questions) |
| Drops | none; XP 1 to 3 |
| Spawn | no biome spawner entry; how sniffers first appear (eggs, archaeology) was not read in this round; nothing is asserted |

## 15. Allay

| Item | Value |
|---|---|
| Entity | `minecraft:allay`, id 2, creature, 0.35 x 0.6, eye 0.36, riding offset 0.04, tracking 8, update interval 2 |
| Attributes | `max_health` 20, `flying_speed` 0.1, `movement_speed` 0.1, `attack_damage` 2 (built on the plain mob base: no animal base, so no `tempt_range`) |
| Navigation | flying; cannot open doors; can float; required path length 48 |
| Brain | activity IDLE only; core (priority 0): Swim(0.8), AnimalPanic(2.5), LookAtTargetSink(45, 90), MoveToTargetSink, CountDownCooldownTicks(liked noteblock), CountDownCooldownTicks(item pickup). Idle (priority group 0 list order): GoToWantedItem(wanted item predicate, speed 1.75, 1, range 32); GoAndGiveItemsToTarget(liked player or noteblock position supplier, speed 2.25, reach 20, throw item, cooldown memory item pickup, cooldown 60 ticks); StayCloseToTarget(liked player, not holding-while-condition, 4, 16, 2.25); SetEntityLookTargetSometimes(6.0, uniform 30 to 60); RunOne[RandomStroll fly(1.0) w2, SetWalkTargetFromLookTarget(1.0, 3) w2, DoNothing(30 to 60) w1] |
| Item | holds one item in the main hand; right-click while holding nothing and the player holds an item: the allay takes a copy of 1 (not creative), plays "item given", and remembers the player as `liked_player`; an allay holding an item picks up only items equal to what it holds (`allayConsidersItemEqual`) when mob griefing is on and its small inventory can add them. Right-click with an empty hand on an allay holding an item: the held item is returned to the player, all inventory items are thrown out, `liked_player` is forgotten |
| Duplication | right-click with an item in tag `duplicates_allays` (amethyst shard) while the allay is dancing and `canDuplicate` (metadata 17): a new allay (spawn reason BREEDING, persistent) is created at the same position, both get a duplication cooldown of 6000 ticks, event 18 hearts and a chime; the item is consumed. `canDuplicate` is true when the cooldown is 0 (the setter writes false while cooldown > 0 and counts it down 1 per server tick) |
| Dancing | metadata 16; the jukebox position is stored while dancing (what starts the dance was not read in this round; nothing is asserted); it stops when the stored jukebox position is farther than the game-event radius of jukebox play or the block there is no longer a jukebox (checked every 20 ticks) |
| Regeneration | heals 1 HP every 10 ticks on the server |
| Damage | the liked player cannot hurt it (`hurtServer` returns false for hits by its liked player) |
| Spawn | no biome spawner entry; structure placement was not read in this round; nothing is asserted |
| Drops | none (empty table) |

## 16. Bee

| Item | Value |
|---|---|
| Entity | `minecraft:bee`, id 11, creature, 0.55 x 0.5, eye 0.3 |
| Attributes | `max_health` 10, `flying_speed` 0.6, `movement_speed` 0.3, `attack_damage` 2 |
| Food | `bee_food` (flowers): dandelion, open eyeblossom, poppy, blue orchid, allium, azure bluet, red tulip, orange tulip, white tulip, pink tulip, oxeye daisy, cornflower, lily of the valley, wither rose, torchflower, sunflower, lilac, peony, rose bush, pitcher plant, flowering azalea leaves, flowering azalea, mangrove propagule, cherry leaves, pink petals, wildflowers, chorus flower, spore blossom, cactus flower |
| Goals | p0 BeeAttack(1.4, true); p1 BeeEnterHive; p2 Breed(1.0); p3 Tempt(1.25, `bee_food`, false); p3 ValidateHive; p3 ValidateFlower; p4 BeePollinate; p5 FollowParent(1.25); p5 BeeLocateHive; p5 GoToHive; p6 GoToKnownFlower; p7 BeeGrowCrop; p8 BeeWander; p9 Float. Targets: p1 BeeHurtByOther; p2 BeeBecomeAngryTarget; p3 ResetUniversalAnger(true) |
| State fields | flags metadata 18 (bit 2 rolling, bit 4 stung, bit 8 has nectar); anger end time metadata 19; saved data: hive position, flower position, nectar, stung, ticks since last pollination, cannot-enter-hive ticks, crops grown since pollination. Constants read: `STING_DEATH_COUNTDOWN` 1200, `TICKS_BEFORE_GOING_TO_KNOWN_FLOWER` 600, `TICKS_WITHOUT_NECTAR_BEFORE_GOING_HOME` 3600, `MIN_ATTACK_DIST` 4, `MAX_CROPS_GROWABLE` 10, `TOO_FAR_DISTANCE` 48, `HIVE_CLOSE_ENOUGH_DISTANCE` 2, `HIVE_SEARCH_DISTANCE` 20, `PATHFIND_TO_HIVE_WHEN_CLOSER_THAN` 16, `DEFAULT_WANDER_DISTANCE_REDUCTION` 16, `RESTRICTED_WANDER_DISTANCE_REDUCTION` 24, `COOLDOWN_BEFORE_LOCATING_NEW_HIVE` 200, `COOLDOWN_BEFORE_LOCATING_NEW_FLOWER` 200, find-flower retry cooldown uniform 20 to 60 |
| Sting | attack damage is the attribute value truncated to an int; the sting damage type `sting`; on a hit on a living target: the target's stinger count +1 and poison: peaceful/easy 0 seconds, normal 10 s, hard 18 s (poison level 0, amplifier 0, duration = seconds x 20); then the bee marks itself stung, stops being angry and plays the sting sound. A stung bee loses health over time: each tick `timeSinceSting` increases; every 5 ticks with chance `1 / clamp(1200 - timeSinceSting, 1, 1200)` it dies (a generic hurt with its full health) |
| Water | a bee in water for more than 20 consecutive ticks takes 1 drown damage per tick afterwards |
| Hive entry | `wantsToEnterHive`: not cooling down (`stayOutOfHiveCountdown` <= 0), not pollinating, not stung, no target, and (it has nectar, or is tired of looking for nectar, or the environment attribute `bees_stay_in_hive` is true; the day timeline sets that attribute true from tick 12542 and false from tick 23460 (read from `timeline/day.json`, `or` modifier)) and the hive is not near fire |
| Nectar | carries nectar after pollinating a flower; while carrying nectar and fewer than 10 crops grown, particles drip nectar with 5 percent chance per tick; crops grown increments when it grows a crop (`BeeGrowCrop`) |
| Anger | persistent anger, `PERSISTENT_ANGER_TIME`; hurt-by-other alerts nearby bees (18 framework: NeutralMob); rolling flag set when angry, not stung, with a target within 2 blocks |
| Drops | none; XP 1 to 3 |
| Spawn | with bee nests (worldgen features); the nest POI types `beehive`, `bee_nest` (ticket count 0 each, search distance 1) |

## 17. Parrot

| Item | Value |
|---|---|
| Entity | `minecraft:parrot`, id 99, creature, 0.5 x 0.9, eye 0.54, passenger attachment y 0.4625 |
| Attributes | `max_health` 6, `flying_speed` 0.4, `movement_speed` 0.2, `attack_damage` 3 |
| Food | taming only: `parrot_food` = wheat seeds, melon seeds, pumpkin seeds, beetroot seeds, torchflower seeds, pitcher pod; `isFood` is false (parrots do not breed: `canMate` false, `getBreedOffspring` null) |
| Poison | an item in `parrot_poisonous_food` (cookie): consumed, poison effect 900 ticks (45 s); for non-creative players, and if the parrot is not invulnerable, the parrot is hurt for a lethal amount (3.4028235E38 damage) so it dies |
| Goals | p0 TamableAnimalPanic(1.25); p0 Float; p1 LookAtPlayer(Player, 8.0); p2 SitWhenOrdered; p2 FollowOwner(1.0, 5.0, 1.0); p2 ParrotWander(1.0); p3 LandOnOwnersShoulder; p3 FollowMob(1.0, 3.0, 7.0) |
| Variants | metadata 20 INT: 0 red-blue, 1 blue, 2 green, 3 yellow-blue, 4 gray; random uniform at spawn; a group shares a baby chance of 0 (never babies) |
| Taming | an untamed parrot with a seed: item consumed, eat sound (pitch `1 + (rand-rand)*0.2`), on the server `nextInt(10) == 0` tames (owner, event 7) else event 6; success returns SUCCESS |
| Owned interactions | the owner right-clicking a tamed parrot that is not flying and not otherwise handled toggles the sit order (SUCCESS on the server) |
| Shoulder | the goal `LandOnOwnersShoulder` (priority 3) exists; its conditions and the storage of a shoulder-riding parrot in the owner's data were not read in this round; nothing is asserted (Open questions) |
| Imitation | each tick `nextInt(400) == 0` (and alive and not silent and `nextInt(2) == 0` of those) the parrot imitates a random non-parrot `Mob` within 20 blocks: it plays that mob type's sound from a map (default parrot ambient), volume 0.7, pitch from its random source |
| Party | a jukebox within 3.46 blocks sets a party flag (dancing) |
| Spawn | jungle family (weight 40, group 1 to 2); `checkParrotSpawnRules` (§1.4) |
| Drops | feather `uniform(1,2)`, looting +U(0,1); XP 1 to 3 |

## 18. Axolotl (left to the aquatic reader)

The axolotl is aquatic and belongs to 21 (aquatic mobs). For the entity-metadata cross-check only: entity id 7, 0.75 x 0.42, eye 0.2751; metadata 18 variant (INT 0 lucy, 1 wild, 2 gold, 3 cyan, 4 blue; ids 0 to 3 are the naturally spawning variants, 4 the rare variant), 19 playing dead (BOOLEAN), 20 from bucket (BOOLEAN). Biome spawner: lush caves, category `axolotls`, weight 10, group 4 to 6. Attributes: `max_health` 14, `movement_speed` 1.0, `attack_damage` 2, `step_height` 1.0.

## 19. Iron golem

| Item | Value |
|---|---|
| Entity | `minecraft:iron_golem`, id 71, category misc, 1.4 x 2.7 (eye default 2.295) |
| Attributes | `max_health` 100, `movement_speed` 0.25, `knockback_resistance` 1.0, `attack_damage` 15, `step_height` 1.0 (and the mob base `follow_range` 16) |
| Metadata | 16 BYTE: bit 1 = player created |
| Goals | p1 MeleeAttack(1.0, true); p2 MoveTowardsTarget(0.9, 32.0); p2 MoveBackToVillage(0.6, false); p4 GolemRandomStrollInVillage(0.6); p5 OfferFlower; p7 LookAtPlayer(Player, 6.0); p8 RandomLookAround. Targets: p1 DefendVillageTarget; p2 HurtByTarget(no alert); p3 NearestAttackable(Player, 10, true, false, angry-at predicate); p3 NearestAttackable(Mob, 5, false, false, predicate λ not read); p4 ResetUniversalAnger(false) |
| Attack | `doHurtTarget` (read): attack animation 10 ticks, entity event 4; with A = the `attack_damage` attribute: if `int(A) > 0` the damage dealt is `A / 2 + nextInt(int(A))` (for 15: 7.5 to 21.5), else A; the target gets +`0.4 * max(0, 1 - knockback_resistance)` on y velocity (living targets; 0.4 for others); post-attack enchantment effects; the attack sound |
| Healing | right-click with an iron ingot: heals 25 HP; if nothing was healed (already at max) it returns PASS; else plays the repair sound with pitch `1 + (rand-rand)*0.2` and consumes 1 ingot |
| Flower | `OfferFlower` (goal p5, read): usable when it is not dark (`isBrightOutside`), with chance 1 in 8000 per evaluation (`nextInt(8000) == 0`), and the nearest entity in tag `candidate_for_iron_golem_gift` (villagers and copper golems) that is within range 6 (`OFFER_TARGET_CONTEXT`: non-combat targeting, range 6) and inside the golem's gift box is found; the gift box is the golem's bounding box inflated by (6, 2, 6); it then holds the flower: `offerFlowerTick` 400 (entity event 11), looking at the target (30, 30). When it stops (event 34): if the target is a mob in tag `accepts_iron_golem_gift` (copper golem), its antenna slot (equipment slot SADDLE) is empty, and the target's box intersects the gift box, the golem puts the offer item, a poppy (`OFFER_ITEM`), into that slot as a guaranteed drop. Nothing is given to villagers |
| Damage states | `Crackiness` stages computed from health; when a hit changes the stage the damage sound plays |
| Anger | persistent anger, `PERSISTENT_ANGER_TIME`; `updatePersistentAnger` every server tick |
| Player created | metadata 16 bit 1; golems created by the build pattern have it set (`setPlayerCreated(true)`); the effects of the flag on target selection (`DefendVillageTarget`) were searched but not read |
| Spawn | villagers summon them (§22.10). Build pattern (`CarvedPumpkinBlock`, read; rows listed top to bottom, `#` iron block, `~` air-like): `~ P ~` / `# # #` / `~ # ~` with P a carved pumpkin or jack o'lantern. The pattern blocks are cleared and the golem (spawn reason TRIGGERED, player created flag set) appears centred on the block position of the bottom iron block (pattern column 1, row 2), y + 0.05; players within 5 blocks get the summoned-entity trigger |
| Drops | poppy `uniform(0,2)` (no looting function); iron ingot `uniform(3,5)` (no looting function) |
| Misc | in entity tag `fall_damage_immune` (iron golem, snow golem, copper golem all listed) |

## 20. Snow golem

| Item | Value |
|---|---|
| Entity | `minecraft:snow_golem`, id 124, misc, 0.7 x 1.9, eye 1.7, tracking range 8, immune to freezing |
| Attributes | `max_health` 4, `movement_speed` 0.2 |
| Metadata | 16 BYTE pumpkin flags (bit 16 = has pumpkin head, set means head on) |
| Goals | p1 RangedAttack(1.25, interval 20, range 10.0); p2 WaterAvoidingRandomStroll(1.0, probability 1.0000001E-5); p3 LookAtPlayer(Player, 6.0); p4 RandomLookAround. Target: p1 NearestAttackable(Mob, 10, true, false, predicate: monsters (the artifact predicate λ)) |
| Ranged attack | spawns a `Snowball` owned by the golem: dx and dz = target minus golem, dy = target eye y - 1.1 - golem y, arc term `sqrt(dx^2+dz^2) * 0.2` added to dy (read), launched with speed 1.6 and the `rangedAttackUncertainty` value (read: `shoot(dx, dy + arc - snowball y, dz, 1.6, uncertainty)`); shoot sound pitch `0.4 / (rand * 0.4 + 0.8)` |
| Melting | each server tick the golem reads the environment attribute `snow_golem_melts` at its position; when true it takes 1 on-fire damage (read). The attribute is true in the dimension type `the_nether` and in the biomes desert, savanna, savanna plateau, windswept savanna, badlands, eroded badlands, wooded badlands (read from data). `isSensitiveToWater` is true; the water-damage rule itself is in 18 framework: damage (not read here) |
| Trail | only when the mob-griefing rule is on (read): each tick, for i = 0 to 3, the cell x = floor(golem x + ((i mod 2) * 2 - 1) * 0.25), y = floor(golem y), z = floor(golem z + (((i div 2) mod 2) * 2 - 1) * 0.25) gets a snow layer block (`Blocks.SNOW` default state) if it is air and the snow block `canSurvive` there; game event block place |
| Shearing | right-click with shears while it has a pumpkin: plays the shear sound, removes the pumpkin flag, drops the loot table `shearing/snow_golem` (a carved pumpkin x1), shears lose 1 durability, game event shear |
| Drops | snowball `uniform(0,15)` (no looting function) |
| Spawn | built by players (`CarvedPumpkinBlock`, read): a carved pumpkin or jack o'lantern on top of two stacked snow blocks (rows top to bottom: pumpkin, snow block, snow block); the blocks are cleared and the golem (spawn reason TRIGGERED) appears at the lowest snow block position (row 2), y + 0.05 |

## 21. Copper golem

| Item | Value |
|---|---|
| Entity | `minecraft:copper_golem`, id 28, misc, 0.49 x 0.98, eye 0.8125 |
| Attributes | `movement_speed` 0.2, `step_height` 1.0, `max_health` 12 |
| Metadata | 16 weathering state (WEATHERING_COPPER_STATE; ordered unaffected, exposed, weathered, oxidized); 17 golem state (id 0 idle, 1 getting item, 2 getting no item, 3 dropping item, 4 dropping no item) |
| Brain | sensors: nearest living entities, hurt-by; activity IDLE only. Core (priority 0): AnimalPanic(1.5), LookAtTargetSink(45, 90), MoveToTargetSink, InteractWithDoor, CountDownCooldownTicks(gaze), CountDownCooldownTicks(transport items). Idle: p0 TransportItemsBetweenContainers(speed 1.0, source predicate, destination predicate, max 32 blocks search, 8 vertical, per-step interactions, travelling callback, queue rule); p1 SetEntityLookTargetSometimes(Player, 6.0, uniform 40 to 80); p2 RunOne (needs no walk target and the transport cooldown memory present) [RandomStroll(1.0, 2, 2) w1, DoNothing(30 to 60) w1] |
| Containers | the source and destination predicates test the block: one accepts a chest or trapped chest; the other accepts the copper chests (block tag `copper_chests`); which is which was not traced (see Open questions). The queue rule makes a golem wait while another entity has that chest open |
| Interaction steps | when the behaviour interacts with a container the callback by step number: step 1 opens the container (container opener count) and records the opened chest position and sets the golem state; step 9 plays the interaction sound; step 60 closes the container if it opened it and clears the position. Leaving travel resets the state to idle and clears the opened position |
| Item in hand | a player right-clicking with any item while the golem holds an item in its main hand takes it: the item is thrown toward the player and the hand cleared (SUCCESS) |
| Shearing | right-click with shears when `readyForShearing` (an item sits in the antenna slot, equipment slot SADDLE): plays the shear sound, empties that slot and spawns the item 1.5 above the golem; shears lose 1 durability |
| Waxing | honeycomb when not already waxed (the weathering timer is not -2): level event 3003, wax-on sound, sets the timer to -2 (waxed, weathering stops), consumes the item |
| Scraping | an axe on a waxed golem (timer -2): axe-scrape sound, level event 3004, timer -1 (unwaxed), the axe loses 1 durability; an axe on an unwaxed golem that has a weathering state other than unaffected: scrape sound, level event 3005, timer reset to -1 and the state steps to the previous level, 1 durability |
| Weathering | `nextWeatheringTick` states: -2 = waxed (no weathering), -1 = unscheduled. When -1 the timer becomes `gameTime + nextIntBetweenInclusive(504000, 552000)` (read). When game time reaches it and the state is not oxidized: the state advances one step (unaffected, exposed, weathered, oxidized) and the timer increases by another `504000 to 552000`. A golem that is oxidized turns into a statue when the block at its position is air and `nextFloat() <= 0.0058` on that evaluation (read) |
| Statue | the golem is replaced by a `copper_golem_statue` block (oxidized weathering variant) with a random pose from the pose enum and facing from the golem's yaw; the block entity stores the golem; preserved equipment is dropped, the golem is discarded, the becomes-statue sound plays, and any leash is dropped or removed |
| Lightning | a bolt (once per bolt uuid) on a golem that is not unaffected resets the timer to -1 and steps the state back one level |
| Hurt | any damage resets the golem state to idle |
| Candidates for the golem gift | the entity tag `accepts_iron_golem_gift` = copper golem; `candidate_for_iron_golem_gift` = villager and the former (iron golems offer flowers to these) |
| Drops | copper ingot `uniform(1,3)`, looting +U(0,1) |
| Spawn | built by players (`CarvedPumpkinBlock`, read): a carved pumpkin or jack o'lantern on top of one block in block tag `copper`; the pattern is cleared, the golem (spawn reason TRIGGERED) appears at the pumpkin's position, y + 0.05, with the weathering state of the copper block (waxed blocks count as their unwaxed level), and the copper block's position receives a copper chest of that block's type facing the pumpkin's facing |

## 22. Villager

### 22.1 Identity, attributes, metadata

| Item | Value |
|---|---|
| Entity | `minecraft:villager`, id 143, category misc, 0.6 x 1.95, eye 1.62; baby box 0.49 x 0.98 eye 0.63 |
| Attributes | `movement_speed` 0.5 on the plain mob base (`max_health` 20 default, `follow_range` 16 from the mob base; no `tempt_range`) |
| Metadata | 18 unhappy counter (INT, 40 right after a refusal, counts down); 19 villager data (VILLAGER_DATA: type registry id, profession registry id, level VarInt); 20 data finalized (BOOLEAN) |
| Villager type | registry `villager_type`: desert, jungle, plains (default), savanna, snow, swamp, taiga |
| Profession | registry `villager_profession`: none, armorer, butcher, cartographer, cleric, farmer, fisherman, fletcher, leatherworker, librarian, mason, nitwit, shepherd, toolsmith, weaponsmith |
| Default data | type plains, profession none, level 1 |
| Removal | never despawns when far away (`removeWhenFarAway` false) |
| Lightning | struck by lightning (difficulty not peaceful): converts into a witch |
| Inventory | a `SimpleContainer` of 8 slots held by `AbstractVillager` (read); used for food and farm items |

Type by biome at spawn (`VillagerType.byBiome`; used by `finalizeVillagerType` for non-breeding spawns and by breeding): desert = badlands, desert, eroded badlands, wooded badlands; jungle = bamboo jungle, jungle, sparse jungle; savanna = savanna plateau, savanna, windswept savanna; snow = deep frozen ocean, frozen ocean, frozen river, ice spikes, snowy beach, snowy taiga, snowy plains, grove, snowy slopes, frozen peaks, jagged peaks; swamp = swamp, mangrove swamp; taiga = old-growth spruce taiga, old-growth pine taiga, windswept gravelly hills, windswept hills, taiga, windswept forest; every other biome (and a non-registered biome) = plains.

### 22.2 Professions, workstations and levels

Each profession registers: an acquirable job-site predicate (the POI type), the held job-site predicate (same POI), optional gathered items and secondary workstation blocks (only farmer has them), a work sound, and one trade set per level. POI types (`PoiTypes`, read): ticket count 1 and search distance 1 for every job site and for `home`; `meeting` has 32 tickets and distance 6; beehive and bee nest 0 tickets and distance 1.

| Profession | Workstation block (POI type) | Work sound event | Extra |
|---|---|---|---|
| armorer | blast furnace | `villager.work_armorer` | |
| butcher | smoker | `villager.work_butcher` | |
| cartographer | cartography table | `villager.work_cartographer` | |
| cleric | brewing stand | `villager.work_cleric` | |
| farmer | composter | `villager.work_farmer` | requested items wheat, wheat seeds, beetroot seeds, bone meal; secondary block farmland |
| fisherman | barrel | `villager.work_fisherman` | |
| fletcher | fletching table | `villager.work_fletcher` | |
| leatherworker | cauldron (all cauldron variants, the `CAULDRONS` state set) | `villager.work_leatherworker` | |
| librarian | lectern | `villager.work_librarian` | |
| mason | stonecutter | `villager.work_mason` | |
| shepherd | loom | `villager.work_shepherd` | |
| toolsmith | smithing table | `villager.work_toolsmith` | |
| weaponsmith | grindstone | `villager.work_weaponsmith` | |
| nitwit | none (no job, no trades) | none | |
| none | none; acquires any job in POI tag `acquirable_job_site` (the 13 workstation POIs above) | none | |

Other POI types: `home` = any bed block (the `BEDS` state set), `meeting` = bell.

Levels: the villager level is 1 to 5 (novice, apprentice, journeyman, expert, master). Experience thresholds (`NEXT_LEVEL_XP_THRESHOLDS`): level 1 from 0, level 2 from 10, level 3 from 70, level 4 from 150, level 5 from 250. A villager levels up when its level is 1 to 4 and `villagerXp >= threshold of the next level` (for level L the maximum xp of the level is the threshold of level L + 1). On level-up: the level increases by 1, `updateTrades` adds the offers of the new level's trade set (§22.4), and the villager gets Regeneration 200 ticks amplifier 0; the XP orb dropped by that trade is 5 larger.

Trade experience (`rewardTradeXp`): villager XP increases by the offer's `xp` field; the trading player's reputation is queued (`lastTradedPlayer`, applied next server tick as the TRADE reputation event, §22.5); an experience orb of `3 + nextInt(4)` (+5 when the villager levelled up) is spawned at the villager (y + 0.5) when the offer rewards experience (the `shouldRewardExp` flag of the offer). The server's per-tick step then broadcasts entity event 14 (happy particles) once for the traded player.

### 22.3 Brain

Sensors: nearest living entities, nearest players, nearest items, nearest bed, hurt-by, villager hostiles, villager babies, secondary POIs, golem detected. Memories relevant here: `home`, `job_site`, `potential_job_site`, `meeting_point`, `last_slept`, `last_woken`, `golem_detected_recently`, `breed_target`, `interaction_target`, `walk_target`, `nearest_hostile`, `hurt_by_entity`.

Schedule: the villager brain reads the environment attribute `gameplay/villager_activity` (baby villagers: `gameplay/baby_villager_activity`), driven by the timeline `timeline/villager_schedule` (clock `overworld`, period 24000 ticks). Keyframes are (tick in day, activity), each applying from its tick until the next keyframe (the track defines no easing, so the activity is discrete; wraps at 24000):

| Day tick | Adult activity | Baby activity |
|---|---|---|
| 10 | idle | idle |
| 2000 | work | |
| 3000 | | play |
| 6000 | | idle |
| 9000 | meet | |
| 10000 | | play |
| 11000 | idle | |
| 12000 | rest | rest |

(So an adult is in `rest` from tick 12000 through tick 23999 and tick 0 to 9 of the next day.) The brain registers activities with base speed 0.5: for adults CORE, WORK (needs a `job_site` memory), MEET (needs `meeting_point`), REST, IDLE, PANIC, PRE_RAID, RAID, HIDE; for babies CORE, PLAY, MEET, REST, IDLE, PANIC, PRE_RAID, RAID, HIDE (the factory adds WORK only for adults and PLAY only for babies). The brain is rebuilt when the villager's age boundary is reached.

Package contents (priority: behaviour; the base speed 0.5 is written `s`; the argument-labelling convention of §1.1 applies: arguments not named in prose are unlabelled positional values whose behaviour-internal meaning was not read, including the numbers in `SetWalkTargetFromBlockMemory`, `LocateHidingPlace`, `InteractWith`, `StrollToPoi`, `ShowTradesToPlayer` and `AcquirePoi`):

| Activity | Behaviours |
|---|---|
| Core | ordinary prioritised entries (priority: behaviour): p0 Swim(0.8), p0 InteractWithDoor, p0 LookAtTargetSink(45, 90), p0 VillagerPanicTrigger, p0 WakeUp, p0 ReactToBell, p0 SetRaidStatus, p0 ValidateNearbyPoi(held job site, memory `job_site`), p0 ValidateNearbyPoi(acquirable job site, memory `potential_job_site`); p1 MoveToTargetSink; p2 PoiCompetitorScan; p3 LookAndFollowTradingPlayerSink(s); p5 GoToWantedItem(speed s, boolean false, int 4); p6 AcquirePoi(acquirable job-site POI, store as `job_site` or `potential_job_site`, only-if-adult flag 1, no entity event); p7 GoToPotentialJobSite(s); p8 YieldJobSite(s); p10 AcquirePoi(home POI with the bed-validity check, store `home`, only-if-adult flag 0, entity event byte 14); p10 AcquirePoi(meeting POI, store `meeting_point`, only-if-adult flag 1, entity event byte 14); p10 AssignProfessionFromJobSite; p10 ResetProfession (the eight entries 5, 6, 7, 8, 10, 10, 10, 10 are normal priority pairs, not a random-order group) |
| Work | in package order: the minimal look behaviour (p5 RunOne [look at villager w2, look at player w2, DoNothing(30, 60) w8], range 8); p5 RunOne whose members are, in order: WorkAtComposter (farmer) or WorkAtPoi (everyone else) with weight 7, StrollToPoi(job_site, speed 0.4, 1, 10) w5, StrollToPoiList(secondary job sites, speed s, 1, 6, job_site) w5, StrollAroundPoi(job_site, speed 0.4, 4) w2, HarvestFarmland (weight 2 for a farmer, 5 for every other profession) and UseBonemeal (weight 4 for a farmer, 7 for every other profession); p10 ShowTradesToPlayer(400, 1600); p10 SetLookAndInteract(Player, 4); p2 SetWalkTargetFromBlockMemory(job_site, speed s, 9, 100, 1200); p3 GiveGiftToHero(100); p99 UpdateActivityFromSchedule. `HarvestFarmland` starts only if the mob-griefing rule is on and the villager's profession is farmer (read), then scans the 3 x 3 x 3 cells around the villager for farmland to harvest/replant and works for `HARVEST_DURATION` 200 ticks. `UseBonemeal` (read): can start only on a tick where the villager's `tickCount` is a multiple of 10, at least 160 ticks after the last bonemealing session, when its inventory holds bone meal and a growing crop (a `CropBlock` below maximum age) lies within the 3 x 3 x 3 cells around it (one chosen by uniform reservoir selection); on start it holds bone meal in the main hand and works for `BONEMEALING_DURATION` 80 ticks |
| Play (babies) | p0 MoveToTargetSink(80, 120); full look behaviour; p5 PlayTagWithOtherKids; p5 RunOne (needs no visible baby villagers) [InteractWith(villager, 8, interaction_target, s, 2) w2, InteractWith(cat, 8, ...) w1, VillageBoundRandomStroll w1, SetWalkTargetFromLookTarget(s, 2) w1, JumpOnBed(s) w2, DoNothing(20, 40) w2]; p99 UpdateActivityFromSchedule |
| Rest | p2 SetWalkTargetFromBlockMemory(home, s, 1, 150, 1200); p3 ValidateNearbyPoi(home); p3 SleepInBed; p5 RunOne (needs no home) [SetClosestHomeAsWalkTarget(s) w1, InsideBrownianWalk(s) w4, GoToClosestVillage(s, 4) w2, DoNothing(20, 40) w2]; minimal look behaviour; p99 UpdateActivityFromSchedule |
| Meet | p2 gate-shuffled [StrollAroundPoi(meeting_point, 0.4, 40) w2, SocializeAtBell w2]; p10 ShowTradesToPlayer(400, 1600); p10 SetLookAndInteract(Player, 4); p2 SetWalkTargetFromBlockMemory(meeting_point, s, 6, 100, 200); p3 GiveGiftToHero(100); p3 ValidateNearbyPoi(meeting); p3 gate [TradeWithVillager] (sets interaction_target); full look behaviour; p99 UpdateActivityFromSchedule |
| Idle | p2 RunOne [InteractWith(villager, 8, interaction_target, s, 2) w2, InteractWith(villager, 8, (adult with breeding possible condition), breed_target, s, 2) w1, InteractWith(cat, 8, ...) w1, VillageBoundRandomStroll w1, SetWalkTargetFromLookTarget(s, 2) w1, JumpOnBed(s) w1, DoNothing(30, 60) w1]; p3 GiveGiftToHero(100); p3 SetLookAndInteract(Player, 4); p3 ShowTradesToPlayer(400, 1600); p3 gate [TradeWithVillager]; p3 gate (needs `breed_target`) [VillagerMakeLove]; full look behaviour; p99 UpdateActivityFromSchedule |
| Panic (speed s x 1.5 for the movement behaviours) | p0 VillagerCalmDown; p1 SetWalkTargetAwayFrom(nearest_hostile, 6, 0); p1 SetWalkTargetAwayFrom(hurt_by_entity, 6, 0); p3 VillageBoundRandomStroll(2, 2); minimal look |
| Pre-raid | p0 RingBell; p0 gate-shuffled [SetWalkTargetFromBlockMemory(meeting_point, 1.5s, 2, 150, 200) w6, VillageBoundRandomStroll(1.5s) w2]; minimal look; p99 ResetRaidStatus |
| Raid | p0 (when raid active and not victorious) gate-shuffled [MoveToSkySeeingSpot w5, VillageBoundRandomStroll(1.1s) w2]; p0 CelebrateVillagersSurvivedRaid(600, 600); p2 (conditional) LocateHidingPlace(24, 1.4s, 1); minimal look; p99 ResetRaidStatus |
| Hide | p0 SetHiddenState(15, 3); p1 LocateHidingPlace(32, 1.25s, 2); minimal look |

Look behaviours: full = p5 RunOne [look at cat (range 8) w8, villager w2, player w2, creature w1, water creature w1, axolotl w1, underground water creature w1, water ambient w1, monster w1, DoNothing(30, 60) w2]; minimal = p5 RunOne [villager w2, player w2, DoNothing(30, 60) w8], all with range 8.

`VillagerPanicTrigger` (core, every tick) puts the villager into PANIC when it was hurt or sees a hostile (memory present); on the server every 100 ticks (`gameTime % 100 == 0`) a panicking villager calls the golem-spawn check with required count 3 (§22.10). The server tick also (random 1 in 100, when a raid is active and not over at its position) broadcasts event 42; if the villager has offers and is trading it stops trading when `offers.isEmpty()` or not trading... (the final check ends a trade when there are no offers).

### 22.4 Trade offers, selection and the price formula

A trade is a data entry (`villager_trade` registry; full tables in §24). The fields and defaults (read from the codec):

| Field | Meaning | Default when absent |
|---|---|---|
| `wants` | the price item (item id, count, optional components) | required |
| `additional_wants` | optional second price item | none |
| `gives` | the result item template | required |
| `max_uses` | integer provider (context) | 4 |
| `xp` | villager experience granted per use | 1 |
| `reputation_discount` | the price multiplier of the offer (float provider) | 0 |
| `merchant_predicate` | loot-condition on the villager: e.g. `villager/variant` in a list | always true |
| `given_item_modifier` | item functions applied to the result (enchanting, exploration map, ...) | none |
| `double_trade_price_enchantments` | holder set; if the result is an enchanted book with a stored enchantment in the set, the price is doubled | none |

Offer construction (`VillagerTrade.getOffer`). Input: the trade entry and a context holding the villager. Output: an offer or nothing. Steps: (1) if the entry has a merchant predicate and the villager does not satisfy it, produce nothing; (2) create the result stack from `gives`; if the entry has a result modifier chain, apply it to the stack, and if the modified stack is empty produce nothing; (3) if the result carries the component `additional_trade_cost`, remove that component and keep its integer value as the extra price E (else E = 0). The component is written by the result modifiers (read): `enchant_randomly` (with its extra-cost flag, when the context allows it, which villager trades do) picks a random enchantment from its pool (restricted to enchantments the item accepts when `only_compatible`; a plain book becomes an enchanted book), draws its level uniformly from the enchantment's minimum level to its maximum level inclusive, and sets E = `2 + nextInt(5 + 10 x L) + 3 x L` for level L; `enchant_with_levels` (with the flag) enchants at the drawn level value V and sets E = V when V is positive and the result is not empty. So in the book trades with `emerald x 0` the price is exactly E emeralds (doubled for treasure enchantments by step 4 below), and equipment trades add V to their base count; (4) if the entry lists double-price enchantments and the result's stored enchantments contain one of them, double E; (5) the first price is `wants` with its count raised by E, and a first-price count below 1 produces nothing; the optional second price from `additional_wants` likewise needs a count of at least 1; (6) the offer holds maximum uses `max(max_uses sample, 1)`, villager xp `max(xp sample, 0)` and price multiplier `max(reputation_discount sample, 0)`, with uses 0, demand 0 and special price difference 0.

Selection (`addOffersFromTradeSet`): a trade set names an `amount` (int provider, constant in all data of this artifact) and a tag of trades (nested tags expanded); `calculateNumberOfTrades` = amount. If the set allows duplicates (the flag does not occur in the data, so it is false) the picker draws a random trade index with replacement; otherwise it removes a random entry from the remaining list each draw. For each draw the offer is built; a trade that yields no offer does not count toward the amount; the loop ends when `amount` offers exist or the list is empty. The trade-set random sequence name is the set id.

For a villager: the offers list is created lazily on the first `getOffers`; the trade set for level 1 is added at that time (`updateTrades` uses the villager's current level, `tradeSetsByLevel`). Each level-up adds the set of the new level. Villagers with no profession or nitwit have no trade set, so no offers (`getTrades` returns null and `updateTrades` returns).

Price shown to a player (`MerchantOffer.getCostA`): `count = clamp(base + max(0, floor(base * demand * priceMultiplier)) + specialPriceDiff, 1, maxStackSize of the price item)`, where `base` is the first cost's base count, `demand` the offer's demand, `priceMultiplier` the offer's multiplier (`reputation_discount`) and `specialPriceDiff` the player-specific discount (below). The second cost is unchanged.

`demand` changes only in `updateDemand`, which runs at each restock: `demand = demand + uses - (maxUses - uses)` (no clamp at 0 in the artifact, so a barely used offer lowers its demand). Demand below 0 does not lower the price because of the `max(0, ...)`.

Special price (`updateSpecialPrices(player)`, called when a trade starts, after each restock and after a gossip exchange while trading): first every offer's `specialPriceDiff` is reset to 0; let `R` = the player's reputation with this villager (§22.5), `H` = the discount of the Hero of the Village effect if the player has it, `H = 0.3 + 0.0625 * amplifier` (else 0). For every offer: if `R != 0`, `specialPriceDiff -= floor(R * priceMultiplier)` (so a positive reputation lowers the price and a negative one raises it); if `H > 0`, `specialPriceDiff -= max(floor(H * baseCount), 1)`. The result is then sent to the client if the player has the merchant menu open.

Restocking (`shouldRestock`, checked by the brain's work/idle behaviours; `canRestock` is true): the villager remembers `lastRestockGameTime`, `numberOfRestocksToday` and `lastRestockCheckDay`. A new "day" for restocking starts when more than 12000 ticks have passed since the last restock, or when the overworld day count of the `overworld_day` timeline has increased (the check day is stored); then `lastRestockGameTime` becomes now and the daily restock counter is reset to 0. A restock is allowed (`allowedToRestock`) when the counter is 0, or when the counter is below 2 and `gameTime > lastRestockGameTime + 2400`. The villager restocks only if it is allowed and at least one offer needs a restock (`needsToRestock`: some offer has been used). `restock`: `updateDemand` on every offer, `uses = 0` on every offer, refresh special prices for a trading player, `lastRestockGameTime = now`, counter + 1. `catchUpDemand` (after waking from long absences): runs `2 - restocksToday` extra `updateDemand` calls after resetting uses.

Performing a trade (`MerchantOffer.take`): the offer is satisfied when the first input stack matches the first cost item with a count of at least the modified cost and the second input matches the second cost (or the offer has none and the slot is empty); the input stacks are shrunk by the modified cost counts, `increaseUses`, then `rewardTradeXp`. An offer is out of stock when `uses >= maxUses`.

Villager interaction (`mobInteract`): ignored (falls to the base) if the item is a villager spawn egg, the villager is dead, already trading, sleeping, or (when it has no offers and is a baby) the villager shakes its head: baby villager: `setUnhappy` (unhappy counter 40, refuse sound) and SUCCESS; adult: main hand only: if it has no offers, `setUnhappy`; if it has offers, award the "talked to villager" statistic and `startTrading` (update special prices, set the trading player, open the merchant screen with the display name and level). With no offers the interaction returns CONSUME after the head-shake.

### 22.5 Gossip and reputation

Each villager keeps a `GossipContainer`: for each target uuid (players, golems, other villagers) a map gossip type -> value. Types (read; `weight` multiplies the value in the reputation sum, `max` caps a stored value, `decay` is removed per decay step, `share decay` is subtracted when the gossip is copied to another villager):

| Type | Weight | Max | Decay per day | Share decay |
|---|---|---|---|---|
| major_negative | -5 | 100 | 10 | 10 |
| minor_negative | -1 | 200 | 20 | 20 |
| minor_positive | 1 | 25 | 1 | 5 |
| major_positive | 5 | 20 | 0 | 20 |
| trading | 1 | 25 | 2 | 20 |

Reputation of a player = the sum over the player's stored gossip of `value * weight` (`weightedValue`, optional type filter). Rules: adding a value to a type adds to the stored value (`mergeValuesForAddition`, read: new = existing + added; if the sum exceeds the type's `max` the result is the larger of `max` and the existing value, so an already over-cap value is kept) (`makeSureValueIsntTooLowOrTooHigh`); a stored value below 2 is removed (the rule: any value less than 2 is dropped). Decay: every 24000 ticks (`maybeDecayGossip`, `lastGossipDecayTime`; the first call only records the time) each stored value loses `decay per day`; a result below 2 removes the entry. Gossip exchange (`gossip(level, other, time)`): at most once per 1200 ticks per villager (both villagers must be at least 1200 ticks past their `lastGossipTime`); the receiver copies up to 10 entries chosen from the sender with probability proportional to the absolute weighted value (selection by `nextInt(total)` and binary search over cumulative sums, sampling with replacement into a set), each copied value being the sender's value minus the type's share decay; copied values below 2 are skipped; merged into the receiver by `mergeInt` (read: transfer merges with `max(existing, incoming)`; additions are described above). After an exchange both villagers' `lastGossipTime` is now and `spawnGolemIfNeeded(time, 5)` is called on the first; a trading player gets refreshed prices if any entry was copied.

Reputation events (`onReputationEventFrom`, applied by the village event system for players and other entities): ZOMBIE_VILLAGER_CURED: major_positive +20 and minor_positive +25 for the curing player; TRADE: trading +2; VILLAGER_HURT: minor_negative +25; VILLAGER_KILLED: major_negative +25 (the artifact then also consults the trading player; the follow-up was not read). Villagers hurt by a player send VILLAGER_HURT for that player (and event 13, angry particles, when the attacker is a player and the villager is alive); when a villager dies and the killer entity exists, every `ReputationEventHandler` entity among its nearest visible living entities receives VILLAGER_KILLED for the killer; a dying villager also releases its home, job site, potential job site and meeting-point POI claims.

### 22.6 Food, breeding and children

| Item | Value |
|---|---|
| Food points | items with the `villager_food` data component carry a `nutrition` number: bread 4, carrot 1, potato 1, beetroot 1 (read from the item properties of `Items`) |
| `foodLevel` | an integer; `hungry` is `foodLevel < 12`; `eatUntilFull` consumes inventory food items one at a time adding nutrition until not hungry; `digestFood(n)` subtracts n |
| Willingness (`canBreed`) | `foodLevel + foodPointsInInventory >= 12`, not sleeping, and age 0 (an adult) |
| Wants more food | inventory food points below 12; has excess food at 24 or more (used by the gift/share behaviour) |
| Pick up | `wantsToPickUp(item)`: the item is in tag `villager_picks_up` (villager plantable seeds, bread, wheat, beetroot) or has the food component, or is in the profession's requested items, and fits the inventory |
| Make love (`VillagerMakeLove`) | start condition `isBreedingPossible` (read): the `breed_target` memory is present and is a valid villager target, and both this villager and the target satisfy `canBreed`; birth needs a vacant `home` POI for the child: `takeVacantBed` takes an unclaimed bed POI within 48 blocks that this villager can path to; if none is available both parents get entity event 13 (angry particles) and no child is created, otherwise the child is created and given that bed (the POI claim moves to the child) and, if the child could not be created, the claim is released; on start: both face and walk toward each other (speed 0.5, reach 2), love particles event 18 on both, birth time = now + `275 + nextInt(50)`; every tick while within sqrt(5) blocks: face each other; with chance 1/35 broadcast event 12 (happy particles) to both; at birth time both `eatAndDigestFood`, then `tryToGiveBirth`: `breed` creates the child through `getBreedOffspring`, sets both parents' age to 6000, the baby's age to -24000, places the baby at parent A's position and sends event 12 for the baby |
| Offspring type | `getBreedOffspring`: roll r = `nextDouble()`: r < 0.5 the type of the biome at the villager's position (`VillagerType.byBiome`); r < 0.75 this parent's type; else the other parent's type; profession none; `villagerDataFinalized` true |
| Spawn finalise | a villager that is not spawned by breeding resets to profession none (only when the reason is breeding) and picks its type by biome (`finalizeVillagerType`) |

### 22.7 Job acquisition and profession change

Core behaviours (§22.3) implement the job cycle (all read). `AcquirePoi` (read): scans for unclaimed POIs of the given type within a class constant range of 48 blocks, path-checks up to 5 candidates, and stores the first reachable one in its target memory; its integer flag is the "only if adult" switch (1 for job and meeting acquisition, 0 for home, so babies can claim a home) and its optional byte is the entity event broadcast on success (14, happy-villager particles; none for the job-site entry stored as `potential_job_site`). The number 1 or 0 seen in the package list is that flag, and the POI type's own valid range (1 for job sites, 6 for the bell) is a different quantity. `AssignProfessionFromJobSite` runs while `potential_job_site` is present: once the villager is within 2 blocks of that site it erases `potential_job_site`, sets `job_site` to it, broadcasts entity event 14, and, if the villager's profession is `none`, picks the first profession in the registry whose held-job-site predicate accepts the POI type at that position, sets it in the villager data and rebuilds the brain. `ResetProfession` runs while `job_site` is absent: if the profession is neither `none` nor `nitwit`, the villager's experience is 0 and its level is at most 1, the profession becomes `none` and the brain is rebuilt. A villager with experience or a higher level keeps its profession without a job site. `YieldJobSite` and `PoiCompetitorScan` resolve two villagers wanting the same site (their internals were not read).

### 22.8 Sleeping and waking

`SleepInBed` (rest activity, read). Start conditions: the villager is not a passenger; its `home` memory is in the same dimension; it did not wake within the last 100 ticks (`last_woken` exists and `0 < now - last_woken < 100` blocks starting, `COOLDOWN_AFTER_BEING_WOKEN` 100); the bed position is within 2 blocks of the villager; the bed block is in tag `villagers_can_sleep_on_bed` and is not occupied; and `now` is past `nextOkStartTime`. Effects of a start: nearby doors it opened are closed; the villager starts sleeping at the home bed position (`startSleeping`); if that succeeded, the memory `last_slept` is set to the current game time at once, and the walk target and the can't-reach marker are erased. The behaviour continues (`canStillUse`) only while the `home` memory exists and REST is the active activity and the villager's y is above the bed block's y + 0.4 and it is within 1.14 blocks of the bed position; outside the REST activity `canStillUse` is false. On stop: if the villager is sleeping it wakes (`stopSleeping`, which stores `last_woken` = now) and `nextOkStartTime` = now + 40, so the behaviour cannot start again for 40 ticks. `WakeUp` (core) calls `stopSleeping` when the villager is sleeping while REST is not its active activity. The POI validity check for a home bed (`validateBedPoi`): the block is in `villagers_can_sleep_on_bed` and the bed is not occupied. `last_slept` is read by the golem check (§22.10).

### 22.9 Hero of the Village gifts

`GiveGiftToHero(100)` (work, meet and idle; read): requires a visible player (the nearest-visible-player memory) with the Hero of the Village effect. The check order is: first a hero must be visible; only then is the cooldown `timeUntilNextGift` examined and, while above 0, decremented by 1 (so it counts down only while a hero is visible); the behaviour starts when the cooldown is 0 or less. The cooldown is 600 when the behaviour object is created (so the first gift needs 600 visible-hero evaluations), then `600 + nextInt(6001)` after each run (below). On start the hero becomes the interaction target and the villager looks at them. Each tick: look at the hero; if the hero is within 5 blocks and at least 20 ticks have passed since the start, throw one gift (a draw of the table below, dropped toward the hero); otherwise walk toward the hero (speed 0.5, closeness 5). On stop: the next cooldown is `600 + nextInt(6001)` ticks and the interaction, walk and look targets are erased. Table by profession: baby villager `baby_gift`; no profession or a profession without a mapping `unemployed_gift`; otherwise the profession's table. The tables (all `gift` type, 1 roll):

| Gift table | Items (each entry equally likely unless a weight is shown) |
|---|---|
| armorer_gift | chainmail helmet, chestplate, leggings, boots |
| baby_gift | poppy |
| butcher_gift | cooked rabbit, cooked chicken, cooked porkchop, cooked beef, cooked mutton |
| cartographer_gift | map, paper |
| cleric_gift | redstone, lapis lazuli |
| farmer_gift | bread, pumpkin pie, cookie |
| fisherman_gift | cod, salmon |
| fletcher_gift | arrow (weight 26) and one tipped arrow each (weight 1, count `uniform(0,1)`) of the potion types swiftness, slowness, strength, healing, harming, leaping, regeneration, fire resistance, water breathing, invisibility, night vision, weakness, poison |
| leatherworker_gift | leather |
| librarian_gift | book |
| mason_gift | clay |
| shepherd_gift | wool of all 16 colours |
| toolsmith_gift | stone pickaxe, stone axe, stone hoe, stone shovel |
| unemployed_gift | wheat seeds |
| weaponsmith_gift | stone axe, golden axe, iron axe |

### 22.10 Iron golem summoning by villagers

`spawnGolemIfNeeded(level, time, minimum)` (read). Input: the current game time and the number of villagers required. Condition on this villager: `wantsToSpawnGolem(time)` = it slept recently (`last_slept` memory present and `time - last_slept < 24000`) and has no `golem_detected_recently` memory. Step 1: collect the villagers inside the box that extends 10 blocks in every direction around this villager and that also satisfy `wantsToSpawnGolem(time)`, at most 5 (`HOW_MANY_VILLAGERS_NEED_TO_AGREE_TO_SPAWN_A_GOLEM` 5, scan radius `HOW_FAR_AWAY_TO_TALK_TO_OTHER_VILLAGERS_ABOUT_GOLEMS` 10). Step 2: if fewer than `minimum` were collected (3 when called from the panic behaviour every 100 ticks, 5 after a gossip exchange), stop. Step 3: try to place one iron golem (spawn reason MOB_SUMMONED) near this villager: up to 10 attempts; each attempt picks x and z offsets uniformly in -8 to 8 (inclusive) from the villager's block, searches downward from 6 blocks above the villager's y for a block position whose block below is a valid standing block under the legacy iron-golem rule (rejected below-blocks: cobweb, cactus, glass pane, stained glass, stained glass pane, leaves, conduit, ice, TNT, glowstone, beacon, sea lantern, frosted ice, tinted glass, glass; the strategy then also needs the block above to have no collision; the full list is in the strategy method), requires the position inside the world border, creates the golem, accepts it only if its spawn rules and its spawn-obstruction check pass (`checkSpawnObstruction` needs the standing block to hold it and free space above), then adds it to the world and plays its ambient sound; the first valid attempt ends the search. Step 4: if a golem was placed, each collected villager receives the golem-detected memory by the `GolemSensor` rule: the memory `golem_detected_recently` is set with a lifetime of 599 ticks (`MEMORY_TIME_TO_LIVE`), and the same sensor rescans nearby living entities every 200 ticks (`GOLEM_SCAN_RATE`) and sets the memory whenever an iron golem is among them. A villager that spawned a golem does not itself stop the others from checking (each tests its own memory).

### 22.11 Raids, curing and zombie conversion (villager side)

- Raid: on 1 in 100 server ticks, if a raid is active (not over) at the villager's position, event 42 is broadcast; activities PRE_RAID, RAID and HIDE (§22.3) are the villager's raid behaviour. Raid logic proper (waves, bell, victory) is in 20.
- Curing: the cured villager's reputation events (§22.5) are applied to the player who cured it; the conversion from zombie villager is in 20.
- Death: reputation event (§22.5), POI release.

## 23. Wandering trader

| Item | Value |
|---|---|
| Entity | `minecraft:wandering_trader`, id 145, creature, 0.6 x 1.95, eye 1.62 |
| Attributes | the plain mob base with no overrides: `max_health` 20, `movement_speed` 0.7 (attribute default), `follow_range` 16 |
| Goals | p0 Float; p0 UseItem(item = potion with the invisibility potion type, sound `wandering_trader.disappeared`, condition λ not read); p0 UseItem(milk bucket, sound `wandering_trader.reappeared`, condition λ); p1 TradeWithPlayer; p1 AvoidEntity(Zombie, 8.0, 0.5, 0.5); p1 AvoidEntity(Evoker, 12.0, 0.5, 0.5); p1 AvoidEntity(Vindicator, 8.0, 0.5, 0.5); p1 AvoidEntity(Vex, 8.0, 0.5, 0.5); p1 AvoidEntity(Pillager, 15.0, 0.5, 0.5); p1 AvoidEntity(Illusioner, 12.0, 0.5, 0.5); p1 AvoidEntity(Zoglin, 10.0, 0.5, 0.5); p1 Panic(0.5); p1 LookAtTradingPlayer; p2 WanderToPosition(2.0, 0.35); p4 MoveTowardsRestriction(0.35); p8 WaterAvoidingRandomStroll(0.35); p9 Interact(Player, 3.0, 1.0); p10 LookAtPlayer(Mob, 8.0) |
| Metadata | 18 unhappy counter |
| Offers | built on the first `getOffers` by adding trade sets in this order: `wandering_trader/buying` (2 trades), `wandering_trader/uncommon` (2), `wandering_trader/common` (5); selection and construction as §22.4 (no duplicates). The full list is in §24 |
| Interaction | not for villager spawn eggs, dead, trading or baby: main-hand interaction awards the "talked" statistic; if there are no offers returns CONSUME; else sets the trading player and opens the merchant screen with level 1 (SUCCESS_SERVER). `showProgressBar` is false (no level bar) |
| Trade XP | `rewardTradeXp`: when the offer rewards experience, an orb of `3 + nextInt(4)` XP at the trader; no levels |
| Despawn | `despawnDelay` is decremented each tick while it is above 0 and the trader is not trading; at 0 the entity is discarded; the spawner sets 48000 |
| Spawner | `WanderingTraderSpawner` (world spawner, runs when the game rule `spawn_wandering_traders` is true): every 1200 ticks decrement the stored spawn delay by 1200; when it is 0 or less: reset the delay to 24000, set the spawn chance to `clamp(chance + 25, 25, 75)`, and if `nextInt(100) <= chance` try to spawn; a successful spawn resets the chance to 25 (the defaults are `DEFAULT_SPAWN_DELAY` 24000 and `MIN_SPAWN_CHANCE` 25; other constants: chance step 25, maximum 75, one-in-10 gate, 10 position attempts, tick delay 1200). `spawn`: pick a random online player (none: report success); with probability 9/10 abort this attempt (`nextInt(10) != 0` returns false); find the nearest `meeting` POI within 48 blocks of the player (else use the player's position); choose a spawn position near it: up to 10 tries at a random offset of up to +-48 on x and z (`nextInt(96) - 48`) at the `MOTION_BLOCKING_NO_LEAVES` height with the wandering trader's placement type `ON_GROUND` valid; the area (1 x 2 x 1 above) must have empty collision; the biome must not be in tag `without_wandering_trader_spawns` (`the_void`); spawn with reason EVENT; then spawn 2 trader llamas (each: random position within 4 blocks, spawn reason EVENT, leashed to the trader); the trader gets despawn delay 48000, wander target = the chosen centre, and home restriction radius 16 |
| Drops | none (empty table); XP none by the trader's own death rules |

## 24. Villager and wandering-trader trade data

Format of each line below (read from `data/minecraft/villager_trade/**` through the trade-set tags; the data files are JSON, the notation here is this document's own): `trade id: price item x count [+ second price item x count] -> result item x count [max uses; xp; multiplier (the price multiplier of §22.4); optional restriction on the villager type; optional result modifiers]`. A count written "uniform A to B" is an integer drawn uniformly from A to B inclusive. `pick N distinct trades` is the trade set's `amount`. A trade set is chosen by profession and villager level (`trade_set/<profession>/level_<n>`, §22.2); the wandering trader uses `wandering_trader/buying`, `wandering_trader/common` and `wandering_trader/uncommon`. The shared smith trades (tag `common_smith/level_N`) appear in the armorer, toolsmith and weaponsmith sets and are expanded inline. A first price of `emerald x 0` means the whole price is the extra price created by the result modifier (§22.4 step 3). Modifier phrases: "enchant as at an enchanting table" gives the result enchantments by the level shown and adds that level to the price; "add one random enchantment" picks from the named pool and adds the extra price shown; "drop the offer if the result ..." removes the offer when the modifiers did not produce the named property; "make an exploration map" lists the destination structure ids that the map can point to. Scope of this section: it transcribes the default registries (`data/minecraft/villager_trade/**` 391 trade files and `data/minecraft/trade_set/**`, 68 sets; 397 trade references appear across the sets because a few trades, such as the shared smith trades, belong to several sets). The jar also bundles an experimental data pack `data/minecraft/datapacks/trade_rebalance` (feature flag `trade_rebalance`, 106 files) that replaces the armorer and librarian trade tags and adds new trade files and chest loot tables; it is not part of the default registries and is not transcribed. Enchantment tag contents used by the modifiers (read): `on_traded_equipment` = `#non_treasure`; `non_treasure` = protection, fire protection, feather falling, blast protection, projectile protection, respiration, aqua affinity, thorns, depth strider, sharpness, smite, bane of arthropods, knockback, fire aspect, looting, sweeping edge, efficiency, silk touch, unbreaking, fortune, power, punch, flame, infinity, luck of the sea, lure, loyalty, impaling, riptide, channeling, multishot, quick charge, piercing, density, breach, lunge; `tradeable` = `#non_treasure`, binding curse, vanishing curse, frost walker, mending; `double_trade_price` = `#treasure`; `treasure` = binding curse, vanishing curse, swift sneak, soul speed, frost walker, mending, wind burst. Exploration-map destination tags (read): `on_plains_village_maps` = village_plains, `on_desert_village_maps` = village_desert, `on_savanna_village_maps` = village_savanna, `on_snowy_village_maps` = village_snowy, `on_taiga_village_maps` = village_taiga, `on_swamp_hut_maps` = swamp_hut, `on_jungle_pyramid_maps` = jungle_pyramid, `on_ocean_monument_maps` = monument, `on_woodland_mansion_maps` = mansion, `on_buried_trial_chambers_maps` = trial_chambers, `on_treasure_maps` = buried_treasure; the jungle explorer map uses the jungle-pyramid destination and the swamp explorer map the swamp-hut destination.

```text
## armorer/level_1: pick 2 distinct trades
  smith/1/coal_emerald: coal x 15 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  armorer/1/emerald_iron_leggings: emerald x 7 -> iron_leggings x 1 [max uses 12; xp 1; multiplier 0.2]
  armorer/1/emerald_iron_boots: emerald x 4 -> iron_boots x 1 [max uses 12; xp 1; multiplier 0.2]
  armorer/1/emerald_iron_helmet: emerald x 5 -> iron_helmet x 1 [max uses 12; xp 1; multiplier 0.2]
  armorer/1/emerald_iron_chestplate: emerald x 9 -> iron_chestplate x 1 [max uses 12; xp 1; multiplier 0.2]
## armorer/level_2: pick 2 distinct trades
  smith/2/iron_ingot_emerald: iron_ingot x 4 -> emerald x 1 [max uses 12; xp 10; multiplier 0.05]
  smith/2/emerald_bell: emerald x 36 -> bell x 1 [max uses 12; xp 5; multiplier 0.2]
  armorer/2/emerald_chainmail_boots: emerald x 1 -> chainmail_boots x 1 [max uses 12; xp 5; multiplier 0.2]
  armorer/2/emerald_chainmail_leggings: emerald x 3 -> chainmail_leggings x 1 [max uses 12; xp 5; multiplier 0.2]
## armorer/level_3: pick 2 distinct trades
  armorer/3/lava_bucket_emerald: lava_bucket x 1 -> emerald x 1 [max uses 12; xp 20; multiplier 0.05]
  armorer/3/emerald_chainmail_helmet: emerald x 1 -> chainmail_helmet x 1 [max uses 12; xp 10; multiplier 0.2]
  armorer/3/emerald_chainmail_chestplate: emerald x 4 -> chainmail_chestplate x 1 [max uses 12; xp 10; multiplier 0.2]
  armorer/3/emerald_shield: emerald x 5 -> shield x 1 [max uses 12; xp 10; multiplier 0.2]
  armorer/3/diamond_emerald: diamond x 1 -> emerald x 1 [max uses 12; xp 20; multiplier 0.05]
## armorer/level_4: pick 2 distinct trades
  armorer/4/emerald_enchanted_diamond_leggings: emerald x 14 -> diamond_leggings x 1 [max uses 3; xp 15; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  armorer/4/emerald_enchanted_diamond_boots: emerald x 8 -> diamond_boots x 1 [max uses 3; xp 15; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
## armorer/level_5: pick 2 distinct trades
  armorer/5/emerald_enchanted_diamond_helmet: emerald x 8 -> diamond_helmet x 1 [max uses 3; xp 30; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  armorer/5/emerald_enchanted_diamond_chestplate: emerald x 16 -> diamond_chestplate x 1 [max uses 3; xp 30; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
## butcher/level_1: pick 2 distinct trades
  butcher/1/chicken_emerald: chicken x 14 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  butcher/1/porkchop_emerald: porkchop x 7 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  butcher/1/rabbit_emerald: rabbit x 4 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  butcher/1/emerald_rabbit_stew: emerald x 1 -> rabbit_stew x 1 [max uses 12; xp 1; multiplier 0.05]
## butcher/level_2: pick 2 distinct trades
  butcher/2/coal_emerald: coal x 15 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  butcher/2/emerald_cooked_porkchop: emerald x 1 -> cooked_porkchop x 5 [max uses 16; xp 5; multiplier 0.05]
  butcher/2/emerald_cooked_chicken: emerald x 1 -> cooked_chicken x 8 [max uses 16; xp 5; multiplier 0.05]
## butcher/level_3: pick 2 distinct trades
  butcher/3/mutton_emerald: mutton x 7 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  butcher/3/beef_emerald: beef x 10 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
## butcher/level_4: pick 2 distinct trades
  butcher/4/dried_kelp_block_emerald: dried_kelp_block x 10 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
## butcher/level_5: pick 2 distinct trades
  butcher/5/sweet_berries_emerald: sweet_berries x 10 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
## cartographer/level_1: pick 2 distinct trades
  cartographer/1/paper_emerald: paper x 24 -> emerald x 1 [max uses 12; xp 2; multiplier 0.05]
  cartographer/1/emerald_map: emerald x 7 -> map x 1 [max uses 12; xp 1; multiplier 0.05]
## cartographer/level_2: pick 2 distinct trades
  cartographer/2/glass_pane_emerald: glass_pane x 11 -> emerald x 1 [max uses 12; xp 10; multiplier 0.05]
  cartographer/2/emerald_and_compass_village_taiga_map: emerald x 8 + compass x 1 -> taiga_village_map x 1 [max uses 12; xp 5; multiplier 0.2; only offered by villagers whose type is swamp or snow or plains; result modifiers: make an exploration map: marker village_taiga, destination structures [village_taiga], search radius 100; drop the offer if the result has no map id]
  cartographer/2/emerald_and_compass_explorer_swamp_map: emerald x 8 + compass x 1 -> swamp_hut_map x 1 [max uses 12; xp 5; multiplier 0.2; only offered by villagers whose type is taiga or snow or jungle; result modifiers: make an exploration map: marker swamp_hut, destination structures [swamp_hut], search radius 100; drop the offer if the result has no map id]
  cartographer/2/emerald_and_compass_village_snowy_map: emerald x 8 + compass x 1 -> snowy_village_map x 1 [max uses 12; xp 5; multiplier 0.2; only offered by villagers whose type is taiga or swamp; result modifiers: make an exploration map: marker village_snowy, destination structures [village_snowy], search radius 100; drop the offer if the result has no map id]
  cartographer/2/emerald_and_compass_village_savanna_map: emerald x 8 + compass x 1 -> savanna_village_map x 1 [max uses 12; xp 5; multiplier 0.2; only offered by villagers whose type is plains or jungle or desert; result modifiers: make an exploration map: marker village_savanna, destination structures [village_savanna], search radius 100; drop the offer if the result has no map id]
  cartographer/2/emerald_and_compass_village_plains_map: emerald x 8 + compass x 1 -> plains_village_map x 1 [max uses 12; xp 5; multiplier 0.2; only offered by villagers whose type is taiga or snow or savanna or desert; result modifiers: make an exploration map: marker village_plains, destination structures [village_plains], search radius 100; drop the offer if the result has no map id]
  cartographer/2/emerald_and_compass_explorer_jungle_map: emerald x 8 + compass x 1 -> jungle_pyramid_map x 1 [max uses 12; xp 5; multiplier 0.2; only offered by villagers whose type is swamp or savanna or desert; result modifiers: make an exploration map: marker jungle_temple, destination structures [jungle_pyramid], search radius 100; drop the offer if the result has no map id]
  cartographer/2/emerald_and_compass_village_desert_map: emerald x 8 + compass x 1 -> desert_village_map x 1 [max uses 12; xp 5; multiplier 0.2; only offered by villagers whose type is savanna or jungle; result modifiers: make an exploration map: marker village_desert, destination structures [village_desert], search radius 100; drop the offer if the result has no map id]
## cartographer/level_3: pick 2 distinct trades
  cartographer/3/compass_emerald: compass x 1 -> emerald x 1 [max uses 12; xp 20; multiplier 0.05]
  cartographer/3/emerald_and_compass_ocean_monument_map: emerald x 13 + compass x 1 -> ocean_monument_map x 1 [max uses 12; xp 10; multiplier 0.2; result modifiers: make an exploration map: marker monument, destination structures [monument], search radius 100; drop the offer if the result has no map id]
  cartographer/3/emerald_and_compass_buried_trial_chambers_map: emerald x 12 + compass x 1 -> buried_trial_chambers_map x 1 [max uses 12; xp 10; multiplier 0.2; result modifiers: make an exploration map: marker trial_chambers, destination structures [trial_chambers], search radius 100; drop the offer if the result has no map id]
## cartographer/level_4: pick 2 distinct trades
  cartographer/4/emerald_item_frame: emerald x 7 -> item_frame x 1 [max uses 12; xp 15; multiplier 0.05]
  cartographer/4/emerald_white_banner: emerald x 2 -> white_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is snow or plains]
  cartographer/4/emerald_orange_banner: emerald x 2 -> orange_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is savanna or desert]
  cartographer/4/emerald_magenta_banner: emerald x 2 -> magenta_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is savanna]
  cartographer/4/emerald_blue_banner: emerald x 2 -> blue_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is snow or taiga]
  cartographer/4/emerald_light_blue_banner: emerald x 2 -> light_blue_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is snow or swamp]
  cartographer/4/emerald_yellow_banner: emerald x 2 -> yellow_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is plains or jungle]
  cartographer/4/emerald_lime_banner: emerald x 2 -> lime_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is desert or taiga]
  cartographer/4/emerald_pink_banner: emerald x 2 -> pink_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is taiga or plains]
  cartographer/4/emerald_gray_banner: emerald x 2 -> gray_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is desert]
  cartographer/4/emerald_cyan_banner: emerald x 2 -> cyan_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is desert or snow]
  cartographer/4/emerald_purple_banner: emerald x 2 -> purple_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is taiga or swamp]
  cartographer/4/emerald_brown_banner: emerald x 2 -> brown_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is plains or jungle]
  cartographer/4/emerald_green_banner: emerald x 2 -> green_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is desert or savanna or jungle]
  cartographer/4/emerald_red_banner: emerald x 2 -> red_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is snow or savanna]
  cartographer/4/emerald_black_banner: emerald x 2 -> black_banner x 1 [max uses 12; xp 15; multiplier 0.05; only offered by villagers whose type is swamp]
## cartographer/level_5: pick 2 distinct trades
  cartographer/5/emerald_globe_banner_pattern: emerald x 8 -> globe_banner_pattern x 1 [max uses 12; xp 30; multiplier 0.05]
  cartographer/5/emerald_and_compass_woodland_mansion_map: emerald x 14 + compass x 1 -> woodland_mansion_map x 1 [max uses 12; xp 30; multiplier 0.2; result modifiers: make an exploration map: marker default, destination structures [mansion], search radius 100; drop the offer if the result has no map id]
## cleric/level_1: pick 2 distinct trades
  cleric/1/rotten_flesh_emerald: rotten_flesh x 32 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  cleric/1/emerald_redstone: emerald x 1 -> redstone x 2 [max uses 12; xp 1; multiplier 0.05]
## cleric/level_2: pick 2 distinct trades
  cleric/2/gold_ingot_emerald: gold_ingot x 3 -> emerald x 1 [max uses 12; xp 10; multiplier 0.05]
  cleric/2/emerald_lapis_lazuli: emerald x 1 -> lapis_lazuli x 1 [max uses 12; xp 5; multiplier 0.05]
## cleric/level_3: pick 2 distinct trades
  cleric/3/rabbit_foot_emerald: rabbit_foot x 2 -> emerald x 1 [max uses 12; xp 20; multiplier 0.05]
  cleric/3/emerald_glowstone: emerald x 4 -> glowstone x 1 [max uses 12; xp 10; multiplier 0.05]
## cleric/level_4: pick 2 distinct trades
  cleric/4/turtle_scute_emerald: turtle_scute x 4 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
  cleric/4/glass_bottle_emerald: glass_bottle x 9 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
  cleric/4/emerald_ender_pearl: emerald x 5 -> ender_pearl x 1 [max uses 12; xp 15; multiplier 0.05]
## cleric/level_5: pick 2 distinct trades
  cleric/5/nether_wart_emerald: nether_wart x 22 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
  cleric/5/emerald_experience_bottle: emerald x 3 -> experience_bottle x 1 [max uses 12; xp 30; multiplier 0.05]
## farmer/level_1: pick 2 distinct trades
  farmer/1/wheat_emerald: wheat x 20 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  farmer/1/potato_emerald: potato x 26 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  farmer/1/carrot_emerald: carrot x 22 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  farmer/1/beetroot_emerald: beetroot x 15 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  farmer/1/emerald_bread: emerald x 1 -> bread x 6 [max uses 16; xp 1; multiplier 0.05]
## farmer/level_2: pick 2 distinct trades
  farmer/2/pumpkin_emerald: pumpkin x 6 -> emerald x 1 [max uses 12; xp 10; multiplier 0.05]
  farmer/2/emerald_pumpkin_pie: emerald x 1 -> pumpkin_pie x 4 [max uses 12; xp 5; multiplier 0.05]
  farmer/2/emerald_apple: emerald x 1 -> apple x 4 [max uses 16; xp 5; multiplier 0.05]
## farmer/level_3: pick 2 distinct trades
  farmer/3/emerald_cookie: emerald x 3 -> cookie x 18 [max uses 12; xp 10; multiplier 0.05]
  farmer/3/melon_emerald: melon x 4 -> emerald x 1 [max uses 12; xp 20; multiplier 0.05]
## farmer/level_4: pick 2 distinct trades
  farmer/4/emerald_cake: emerald x 3 -> cake x 1 [max uses 12; xp 15; multiplier 0.05]
  farmer/4/emerald_suspicious_stew: emerald x 1 -> suspicious_stew x 1 [max uses 12; xp 15; multiplier 0.05; result modifiers: stew effects: night_vision 5s, jump_boost 8s, weakness 7s, blindness 6s, poison 14s, saturation 7s]
## farmer/level_5: pick 2 distinct trades
  farmer/5/emerald_golden_carrot: emerald x 3 -> golden_carrot x 3 [max uses 12; xp 30; multiplier 0.05]
  farmer/5/emerald_glistening_melon_slice: emerald x 4 -> glistering_melon_slice x 3 [max uses 12; xp 30; multiplier 0.05]
## fisherman/level_1: pick 2 distinct trades
  fisherman/1/string_emerald: string x 20 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  fisherman/1/coal_emerald: coal x 10 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  fisherman/1/raw_cod_and_emerald_cooked_cod: cod x 6 + emerald x 1 -> cooked_cod x 6 [max uses 16; xp 1; multiplier 0.05]
  fisherman/1/emerald_cod_bucket: emerald x 3 -> cod_bucket x 1 [max uses 16; xp 1; multiplier 0.05]
## fisherman/level_2: pick 2 distinct trades
  fisherman/2/cod_emerald: cod x 15 -> emerald x 1 [max uses 16; xp 10; multiplier 0.05]
  fisherman/2/salmon_and_emerald_cooked_salmon: salmon x 6 + emerald x 1 -> cooked_salmon x 6 [max uses 16; xp 5; multiplier 0.05]
  fisherman/2/emerald_campfire: emerald x 2 -> campfire x 1 [max uses 12; xp 5; multiplier 0.05]
## fisherman/level_3: pick 2 distinct trades
  fisherman/3/salmon_emerald: salmon x 13 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  fisherman/3/emerald_enchanted_fishing_rod: emerald x 3 -> fishing_rod x 1 [max uses 3; xp 10; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
## fisherman/level_4: pick 2 distinct trades
  fisherman/4/tropical_fish_emerald: tropical_fish x 6 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
## fisherman/level_5: pick 2 distinct trades
  fisherman/5/pufferfish_emerald: pufferfish x 4 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
  fisherman/5/oak_boat_emerald: oak_boat x 1 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05; only offered by villagers whose type is plains]
  fisherman/5/spruce_boat_emerald: spruce_boat x 1 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05; only offered by villagers whose type is taiga or snow]
  fisherman/5/jungle_boat_emerald: jungle_boat x 1 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05; only offered by villagers whose type is desert or jungle]
  fisherman/5/acacia_boat_emerald: acacia_boat x 1 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05; only offered by villagers whose type is savanna]
  fisherman/5/dark_oak_boat_emerald: dark_oak_boat x 1 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05; only offered by villagers whose type is swamp]
## fletcher/level_1: pick 2 distinct trades
  fletcher/1/stick_emerald: stick x 32 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  fletcher/1/emerald_arrow: emerald x 1 -> arrow x 16 [max uses 12; xp 1; multiplier 0.05]
  fletcher/1/gravel_and_emerald_flint: gravel x 10 + emerald x 1 -> flint x 10 [max uses 12; xp 1; multiplier 0.05]
## fletcher/level_2: pick 2 distinct trades
  fletcher/2/flint_emerald: flint x 26 -> emerald x 1 [max uses 12; xp 10; multiplier 0.05]
  fletcher/2/emerald_bow: emerald x 2 -> bow x 1 [max uses 12; xp 5; multiplier 0.05]
## fletcher/level_3: pick 2 distinct trades
  fletcher/3/string_emerald: string x 14 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  fletcher/3/emerald_crossbow: emerald x 3 -> crossbow x 1 [max uses 12; xp 10; multiplier 0.05]
## fletcher/level_4: pick 2 distinct trades
  fletcher/4/feather_emerald: feather x 24 -> emerald x 1 [max uses 16; xp 30; multiplier 0.05]
  fletcher/4/emerald_enchanted_bow: emerald x 2 -> bow x 1 [max uses 3; xp 15; multiplier 0.05; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
## fletcher/level_5: pick 2 distinct trades
  fletcher/5/tripwire_hook_emerald: tripwire_hook x 8 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
  fletcher/5/emerald_enchanted_crossbow: emerald x 3 -> crossbow x 1 [max uses 3; xp 15; multiplier 0.05; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  fletcher/5/arrow_and_emerald_tipped_arrow: emerald x 2 + arrow x 5 -> tipped_arrow x 5 [max uses 12; xp 30; multiplier 0.05; result modifiers: random potion from pool #tradeable]
## leatherworker/level_1: pick 2 distinct trades
  leatherworker/1/leather_emerald: leather x 6 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  leatherworker/1/emerald_dyed_leather_leggings: emerald x 3 -> leather_leggings x 1 [max uses 12; xp 1; multiplier 0.2; result modifiers: dye the result with 1 + binomial(n=2, p=0.75) random dyes; drop the offer if the result has no dye colour]
  leatherworker/1/emerald_dyed_leather_chestplate: emerald x 7 -> leather_chestplate x 1 [max uses 12; xp 1; multiplier 0.2; result modifiers: dye the result with 1 + binomial(n=2, p=0.75) random dyes; drop the offer if the result has no dye colour]
## leatherworker/level_2: pick 2 distinct trades
  leatherworker/2/flint_emerald: flint x 26 -> emerald x 1 [max uses 12; xp 10; multiplier 0.05]
  leatherworker/2/emerald_dyed_leather_helmet: emerald x 5 -> leather_helmet x 1 [max uses 12; xp 5; multiplier 0.2; result modifiers: dye the result with 1 + binomial(n=2, p=0.75) random dyes; drop the offer if the result has no dye colour]
  leatherworker/2/emerald_dyed_leather_boots: emerald x 4 -> leather_boots x 1 [max uses 12; xp 5; multiplier 0.2; result modifiers: dye the result with 1 + binomial(n=2, p=0.75) random dyes; drop the offer if the result has no dye colour]
## leatherworker/level_3: pick 2 distinct trades
  leatherworker/3/rabbit_hide_emerald: rabbit_hide x 9 -> emerald x 1 [max uses 12; xp 20; multiplier 0.05]
  leatherworker/3/emerald_dyed_leather_chestplate: emerald x 7 -> leather_chestplate x 1 [max uses 12; xp 1; multiplier 0.2; result modifiers: dye the result with 1 + binomial(n=2, p=0.75) random dyes; drop the offer if the result has no dye colour]
## leatherworker/level_4: pick 2 distinct trades
  leatherworker/4/turtle_scute_emerald: turtle_scute x 4 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
  leatherworker/4/emerald_dyed_leather_horse_armor: emerald x 6 -> leather_horse_armor x 1 [max uses 12; xp 15; multiplier 0.2; result modifiers: dye the result with 1 + binomial(n=2, p=0.75) random dyes; drop the offer if the result has no dye colour]
## leatherworker/level_5: pick 2 distinct trades
  leatherworker/5/emerald_saddle: emerald x 6 -> saddle x 1 [max uses 12; xp 30; multiplier 0.2]
  leatherworker/5/emerald_dyed_leather_helmet: emerald x 5 -> leather_helmet x 1 [max uses 12; xp 5; multiplier 0.2; result modifiers: dye the result with 1 + binomial(n=2, p=0.75) random dyes; drop the offer if the result has no dye colour]
## librarian/level_1: pick 2 distinct trades
  librarian/1/paper_emerald: paper x 24 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  librarian/1/emerald_and_book_enchanted_book: emerald x 0 + book x 1 -> enchanted_book x 1 [max uses 12; xp 1; multiplier 0.2; result modifiers: add one random enchantment from pool #tradeable (restricted to enchantments the item accepts: False), level uniform from the enchantment minimum to maximum, and add the extra price 2 + nextInt(5 + 10 x level) + 3 x level; drop the offer if the result has no stored enchantments; extra price doubled if a stored enchantment is in #double_trade_price]
  librarian/1/emerald_bookshelf: emerald x 9 -> bookshelf x 1 [max uses 12; xp 1; multiplier 0.05]
## librarian/level_2: pick 2 distinct trades
  librarian/2/book_emerald: book x 4 -> emerald x 1 [max uses 12; xp 10; multiplier 0.05]
  librarian/2/emerald_and_book_enchanted_book: emerald x 0 + book x 1 -> enchanted_book x 1 [max uses 12; xp 5; multiplier 0.2; result modifiers: add one random enchantment from pool #tradeable (restricted to enchantments the item accepts: False), level uniform from the enchantment minimum to maximum, and add the extra price 2 + nextInt(5 + 10 x level) + 3 x level; drop the offer if the result has no stored enchantments; extra price doubled if a stored enchantment is in #double_trade_price]
  librarian/2/emerald_lantern: emerald x 1 -> lantern x 1 [max uses 12; xp 5; multiplier 0.05]
## librarian/level_3: pick 2 distinct trades
  librarian/3/ink_sac_emerald: ink_sac x 5 -> emerald x 1 [max uses 12; xp 20; multiplier 0.05]
  librarian/3/emerald_and_book_enchanted_book: emerald x 0 + book x 1 -> enchanted_book x 1 [max uses 12; xp 10; multiplier 0.2; result modifiers: add one random enchantment from pool #tradeable (restricted to enchantments the item accepts: False), level uniform from the enchantment minimum to maximum, and add the extra price 2 + nextInt(5 + 10 x level) + 3 x level; drop the offer if the result has no stored enchantments; extra price doubled if a stored enchantment is in #double_trade_price]
  librarian/3/emerald_glass: emerald x 1 -> glass x 4 [max uses 12; xp 10; multiplier 0.05]
## librarian/level_4: pick 2 distinct trades
  librarian/4/writable_book_emerald: writable_book x 2 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
  librarian/4/emerald_book_and_enchanted_book: emerald x 0 + book x 1 -> enchanted_book x 1 [max uses 12; xp 15; multiplier 0.2; result modifiers: add one random enchantment from pool #tradeable (restricted to enchantments the item accepts: False), level uniform from the enchantment minimum to maximum, and add the extra price 2 + nextInt(5 + 10 x level) + 3 x level; drop the offer if the result has no stored enchantments; extra price doubled if a stored enchantment is in #double_trade_price]
  librarian/4/emerald_clock: emerald x 5 -> clock x 1 [max uses 12; xp 15; multiplier 0.05]
  librarian/4/emerald_compass: emerald x 4 -> compass x 1 [max uses 12; xp 15; multiplier 0.05]
## librarian/level_5: pick 3 distinct trades
  librarian/5/emerald_yellow_candle: emerald x 3 -> yellow_candle x 1 [max uses 12; xp 30; multiplier 0.05]
  librarian/5/emerald_red_candle: emerald x 3 -> red_candle x 1 [max uses 12; xp 30; multiplier 0.05]
## mason/level_1: pick 2 distinct trades
  mason/1/clay_ball_emerald: clay_ball x 10 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  mason/1/emerald_brick: emerald x 1 -> brick x 10 [max uses 16; xp 1; multiplier 0.05]
## mason/level_2: pick 2 distinct trades
  mason/2/stone_emerald: stone x 20 -> emerald x 1 [max uses 16; xp 10; multiplier 0.05]
  mason/2/emerald_chiseled_stone_bricks: emerald x 1 -> chiseled_stone_bricks x 4 [max uses 16; xp 5; multiplier 0.05]
## mason/level_3: pick 2 distinct trades
  mason/3/granite_emerald: granite x 16 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  mason/3/andesite_emerald: andesite x 16 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  mason/3/diorite_emerald: diorite x 16 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  mason/3/emerald_dripstone_block: emerald x 1 -> dripstone_block x 4 [max uses 16; xp 10; multiplier 0.05]
  mason/3/emerald_polished_andesite: emerald x 1 -> polished_andesite x 4 [max uses 16; xp 10; multiplier 0.05]
  mason/3/emerald_polished_diorite: emerald x 1 -> polished_diorite x 4 [max uses 16; xp 10; multiplier 0.05]
  mason/3/emerald_polished_granite: emerald x 1 -> polished_granite x 4 [max uses 16; xp 10; multiplier 0.05]
## mason/level_4: pick 2 distinct trades
  mason/4/quartz_emerald: quartz x 12 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
  mason/4/emerald_white_terracotta: emerald x 1 -> white_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_orange_terracotta: emerald x 1 -> orange_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_magenta_terracotta: emerald x 1 -> magenta_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_light_blue_terracotta: emerald x 1 -> light_blue_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_yellow_terracotta: emerald x 1 -> yellow_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_lime_terracotta: emerald x 1 -> lime_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_pink_terracotta: emerald x 1 -> pink_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_gray_terracotta: emerald x 1 -> gray_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_light_gray_terracotta: emerald x 1 -> light_gray_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_cyan_terracotta: emerald x 1 -> cyan_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_purple_terracotta: emerald x 1 -> purple_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_blue_terracotta: emerald x 1 -> blue_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_brown_terracotta: emerald x 1 -> brown_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_green_terracotta: emerald x 1 -> green_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_red_terracotta: emerald x 1 -> red_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_black_terracotta: emerald x 1 -> black_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_white_glazed_terracotta: emerald x 1 -> white_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_orange_glazed_terracotta: emerald x 1 -> orange_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_magenta_glazed_terracotta: emerald x 1 -> magenta_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_light_blue_glazed_terracotta: emerald x 1 -> light_blue_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_yellow_glazed_terracotta: emerald x 1 -> yellow_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_lime_glazed_terracotta: emerald x 1 -> lime_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_pink_glazed_terracotta: emerald x 1 -> pink_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_gray_glazed_terracotta: emerald x 1 -> gray_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_light_gray_glazed_terracotta: emerald x 1 -> light_gray_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_cyan_glazed_terracotta: emerald x 1 -> cyan_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_purple_glazed_terracotta: emerald x 1 -> purple_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_blue_glazed_terracotta: emerald x 1 -> blue_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_brown_glazed_terracotta: emerald x 1 -> brown_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_green_glazed_terracotta: emerald x 1 -> green_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_red_glazed_terracotta: emerald x 1 -> red_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
  mason/4/emerald_black_glazed_terracotta: emerald x 1 -> black_glazed_terracotta x 1 [max uses 12; xp 15; multiplier 0.05]
## mason/level_5: pick 2 distinct trades
  mason/5/emerald_quartz_pillar: emerald x 1 -> quartz_pillar x 1 [max uses 12; xp 30; multiplier 0.05]
  mason/5/emerald_quartz_block: emerald x 1 -> quartz_block x 1 [max uses 12; xp 30; multiplier 0.05]
## shepherd/level_1: pick 2 distinct trades
  shepherd/1/white_wool_emerald: white_wool x 18 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  shepherd/1/brown_wool_emerald: brown_wool x 18 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  shepherd/1/gray_wool_emerald: gray_wool x 18 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  shepherd/1/black_wool_emerald: black_wool x 18 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  shepherd/1/emerald_shears: emerald x 2 -> shears x 1 [max uses 12; xp 1; multiplier 0.05]
## shepherd/level_2: pick 2 distinct trades
  shepherd/2/white_dye_emerald: white_dye x 12 -> emerald x 1 [max uses 16; xp 10; multiplier 0.05]
  shepherd/2/gray_dye_emerald: gray_dye x 12 -> emerald x 1 [max uses 16; xp 10; multiplier 0.05]
  shepherd/2/black_dye_emerald: black_dye x 12 -> emerald x 1 [max uses 16; xp 10; multiplier 0.05]
  shepherd/2/light_blue_dye_emerald: light_blue_dye x 12 -> emerald x 1 [max uses 16; xp 10; multiplier 0.05]
  shepherd/2/lime_dye_emerald: lime_dye x 12 -> emerald x 1 [max uses 16; xp 10; multiplier 0.05]
  shepherd/2/emerald_white_wool: emerald x 1 -> white_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_orange_wool: emerald x 1 -> orange_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_magenta_wool: emerald x 1 -> magenta_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_light_blue_wool: emerald x 1 -> light_blue_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_yellow_wool: emerald x 1 -> yellow_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_lime_wool: emerald x 1 -> lime_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_pink_wool: emerald x 1 -> pink_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_gray_wool: emerald x 1 -> gray_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_light_gray_wool: emerald x 1 -> light_gray_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_cyan_wool: emerald x 1 -> cyan_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_purple_wool: emerald x 1 -> purple_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_blue_wool: emerald x 1 -> blue_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_brown_wool: emerald x 1 -> brown_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_green_wool: emerald x 1 -> green_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_red_wool: emerald x 1 -> red_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_black_wool: emerald x 1 -> black_wool x 1 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_white_carpet: emerald x 1 -> white_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_orange_carpet: emerald x 1 -> orange_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_magenta_carpet: emerald x 1 -> magenta_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_light_blue_carpet: emerald x 1 -> light_blue_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_yellow_carpet: emerald x 1 -> yellow_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_lime_carpet: emerald x 1 -> lime_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_pink_carpet: emerald x 1 -> pink_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_gray_carpet: emerald x 1 -> gray_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_light_gray_carpet: emerald x 1 -> light_gray_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_cyan_carpet: emerald x 1 -> cyan_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_purple_carpet: emerald x 1 -> purple_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_blue_carpet: emerald x 1 -> blue_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_brown_carpet: emerald x 1 -> brown_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_green_carpet: emerald x 1 -> green_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_red_carpet: emerald x 1 -> red_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
  shepherd/2/emerald_black_carpet: emerald x 1 -> black_carpet x 4 [max uses 16; xp 5; multiplier 0.05]
## shepherd/level_3: pick 2 distinct trades
  shepherd/3/yellow_dye_emerald: yellow_dye x 12 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  shepherd/3/light_gray_dye_emerald: light_gray_dye x 12 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  shepherd/3/orange_dye_emerald: orange_dye x 12 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  shepherd/3/red_dye_emerald: red_dye x 12 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  shepherd/3/pink_dye_emerald: pink_dye x 12 -> emerald x 1 [max uses 16; xp 20; multiplier 0.05]
  shepherd/3/emerald_white_bed: emerald x 3 -> white_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_orange_bed: emerald x 3 -> orange_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_magenta_bed: emerald x 3 -> magenta_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_light_blue_bed: emerald x 3 -> light_blue_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_yellow_bed: emerald x 3 -> yellow_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_lime_bed: emerald x 3 -> lime_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_pink_bed: emerald x 3 -> pink_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_gray_bed: emerald x 3 -> gray_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_light_gray_bed: emerald x 3 -> light_gray_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_cyan_bed: emerald x 3 -> cyan_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_purple_bed: emerald x 3 -> purple_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_blue_bed: emerald x 3 -> blue_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_brown_bed: emerald x 3 -> brown_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_green_bed: emerald x 3 -> green_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_red_bed: emerald x 3 -> red_bed x 1 [max uses 12; xp 10; multiplier 0.05]
  shepherd/3/emerald_black_bed: emerald x 3 -> black_bed x 1 [max uses 12; xp 10; multiplier 0.05]
## shepherd/level_4: pick 2 distinct trades
  shepherd/4/brown_dye_emerald: brown_dye x 12 -> emerald x 1 [max uses 16; xp 30; multiplier 0.05]
  shepherd/4/purple_dye_emerald: purple_dye x 12 -> emerald x 1 [max uses 16; xp 30; multiplier 0.05]
  shepherd/4/blue_dye_emerald: blue_dye x 12 -> emerald x 1 [max uses 16; xp 30; multiplier 0.05]
  shepherd/4/green_dye_emerald: green_dye x 12 -> emerald x 1 [max uses 16; xp 30; multiplier 0.05]
  shepherd/4/magenta_dye_emerald: magenta_dye x 12 -> emerald x 1 [max uses 16; xp 30; multiplier 0.05]
  shepherd/4/cyan_dye_emerald: cyan_dye x 12 -> emerald x 1 [max uses 16; xp 30; multiplier 0.05]
  shepherd/4/emerald_white_banner: emerald x 3 -> white_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_orange_banner: emerald x 3 -> orange_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_magenta_banner: emerald x 3 -> magenta_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_light_blue_banner: emerald x 3 -> light_blue_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_yellow_banner: emerald x 3 -> yellow_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_lime_banner: emerald x 3 -> lime_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_pink_banner: emerald x 3 -> pink_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_gray_banner: emerald x 3 -> gray_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_light_gray_banner: emerald x 3 -> light_gray_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_cyan_banner: emerald x 3 -> cyan_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_purple_banner: emerald x 3 -> purple_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_blue_banner: emerald x 3 -> blue_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_brown_banner: emerald x 3 -> brown_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_green_banner: emerald x 3 -> green_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_red_banner: emerald x 3 -> red_banner x 1 [max uses 12; xp 15; multiplier 0.05]
  shepherd/4/emerald_black_banner: emerald x 3 -> black_banner x 1 [max uses 12; xp 15; multiplier 0.05]
## shepherd/level_5: pick 2 distinct trades
  shepherd/5/emerald_painting: emerald x 2 -> painting x 3 [max uses 12; xp 30; multiplier 0.05]
## toolsmith/level_1: pick 2 distinct trades
  smith/1/coal_emerald: coal x 15 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  toolsmith/1/emerald_stone_axe: emerald x 1 -> stone_axe x 1 [max uses 12; xp 1; multiplier 0.2]
  toolsmith/1/emerald_stone_shovel: emerald x 1 -> stone_shovel x 1 [max uses 12; xp 1; multiplier 0.2]
  toolsmith/1/emerald_stone_pickaxe: emerald x 1 -> stone_pickaxe x 1 [max uses 12; xp 1; multiplier 0.2]
  toolsmith/1/emerald_stone_hoe: emerald x 1 -> stone_hoe x 1 [max uses 12; xp 1; multiplier 0.2]
## toolsmith/level_2: pick 2 distinct trades
  smith/2/iron_ingot_emerald: iron_ingot x 4 -> emerald x 1 [max uses 12; xp 10; multiplier 0.05]
  smith/2/emerald_bell: emerald x 36 -> bell x 1 [max uses 12; xp 5; multiplier 0.2]
## toolsmith/level_3: pick 2 distinct trades
  toolsmith/3/flint_emerald: flint x 30 -> emerald x 1 [max uses 12; xp 20; multiplier 0.05]
  toolsmith/3/emerald_enchanted_iron_axe: emerald x 1 -> iron_axe x 1 [max uses 3; xp 10; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  toolsmith/3/emerald_enchanted_iron_shovel: emerald x 2 -> iron_shovel x 1 [max uses 3; xp 10; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  toolsmith/3/emerald_enchanted_iron_pickaxe: emerald x 3 -> iron_pickaxe x 1 [max uses 3; xp 10; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  toolsmith/3/emerald_diamond_hoe: emerald x 4 -> diamond_hoe x 1 [max uses 3; xp 10; multiplier 0.2]
## toolsmith/level_4: pick 2 distinct trades
  toolsmith/4/emerald_enchanted_diamond_axe: emerald x 12 -> diamond_axe x 1 [max uses 3; xp 15; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  toolsmith/4/emerald_enchanted_diamond_shovel: emerald x 5 -> diamond_shovel x 1 [max uses 3; xp 15; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  toolsmith/4/diamond_emerald: diamond x 1 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
## toolsmith/level_5: pick 2 distinct trades
  toolsmith/5/emerald_enchanted_diamond_pickaxe: emerald x 13 -> diamond_pickaxe x 1 [max uses 3; xp 30; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
## wandering_trader/buying: pick 2 distinct trades
  wandering_trader/water_bottle_emerald: potion x 1 with components {"potion_contents":{"potion":"water"}} -> emerald x 1 [max uses 2; xp 1; multiplier 0.05]
  wandering_trader/water_bucket_emerald: water_bucket x 1 -> emerald x 2 [max uses 2; xp 1; multiplier 0.05]
  wandering_trader/milk_bucket_emerald: milk_bucket x 1 -> emerald x 2 [max uses 2; xp 1; multiplier 0.05]
  wandering_trader/fermented_spider_eye_emerald: fermented_spider_eye x 1 -> emerald x 3 [max uses 2; xp 1; multiplier 0.05]
  wandering_trader/baked_potato_emerald: baked_potato x 4 -> emerald x 1 [max uses 2; xp 1; multiplier 0.05]
  wandering_trader/hay_block_emerald: hay_block x 1 -> emerald x 1 [max uses 2; xp 1; multiplier 0.05]
## wandering_trader/common: pick 5 distinct trades
  wandering_trader/emerald_white_dye: emerald x 1 -> white_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_orange_dye: emerald x 1 -> orange_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_magenta_dye: emerald x 1 -> magenta_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_light_blue_dye: emerald x 1 -> light_blue_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_yellow_dye: emerald x 1 -> yellow_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_lime_dye: emerald x 1 -> lime_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_pink_dye: emerald x 1 -> pink_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_gray_dye: emerald x 1 -> gray_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_light_gray_dye: emerald x 1 -> light_gray_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_cyan_dye: emerald x 1 -> cyan_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_purple_dye: emerald x 1 -> purple_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_blue_dye: emerald x 1 -> blue_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_brown_dye: emerald x 1 -> brown_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_green_dye: emerald x 1 -> green_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_red_dye: emerald x 1 -> red_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_black_dye: emerald x 1 -> black_dye x 3 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_fish_bucket: emerald x 3 -> tropical_fish_bucket x 1 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_pufferfish_bucket: emerald x 3 -> pufferfish_bucket x 1 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_sea_pickle: emerald x 2 -> sea_pickle x 1 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_slime_ball: emerald x 4 -> slime_ball x 1 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_glowstone: emerald x 2 -> glowstone x 1 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_nautilus_shell: emerald x 5 -> nautilus_shell x 1 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_fern: emerald x 1 -> fern x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_sugar_cane: emerald x 1 -> sugar_cane x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_pumpkin: emerald x 1 -> pumpkin x 1 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_kelp: emerald x 3 -> kelp x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_cactus: emerald x 3 -> cactus x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_dandelion: emerald x 1 -> dandelion x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_poppy: emerald x 1 -> poppy x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_blue_orchid: emerald x 1 -> blue_orchid x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_allium: emerald x 1 -> allium x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_azure_bluet: emerald x 1 -> azure_bluet x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_red_tulip: emerald x 1 -> red_tulip x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_orange_tulip: emerald x 1 -> orange_tulip x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_white_tulip: emerald x 1 -> white_tulip x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_pink_tulip: emerald x 1 -> pink_tulip x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_oxeye_daisy: emerald x 1 -> oxeye_daisy x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_cornflower: emerald x 1 -> cornflower x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_lily_of_the_valley: emerald x 1 -> lily_of_the_valley x 1 [max uses 7; xp 1; multiplier 0.05]
  wandering_trader/emerald_open_eyeblossom: emerald x 1 -> open_eyeblossom x 1 [max uses 7; xp 1; multiplier 0.05]
  wandering_trader/emerald_wheat_seeds: emerald x 1 -> wheat_seeds x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_beetroot_seeds: emerald x 1 -> beetroot_seeds x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_pumpkin_seeds: emerald x 1 -> pumpkin_seeds x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_melon_seeds: emerald x 1 -> melon_seeds x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_acacia_sapling: emerald x 5 -> acacia_sapling x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_birch_sapling: emerald x 5 -> birch_sapling x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_dark_oak_sapling: emerald x 5 -> dark_oak_sapling x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_jungle_sapling: emerald x 5 -> jungle_sapling x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_oak_sapling: emerald x 5 -> oak_sapling x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_spruce_sapling: emerald x 5 -> spruce_sapling x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_cherry_sapling: emerald x 5 -> cherry_sapling x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_pale_oak_sapling: emerald x 5 -> pale_oak_sapling x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_mangrove_propagule: emerald x 5 -> mangrove_propagule x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_poplar_sapling: emerald x 5 -> poplar_sapling x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_brain_coral_block: emerald x 3 -> brain_coral_block x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_bubble_coral_block: emerald x 3 -> bubble_coral_block x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_fire_coral_block: emerald x 3 -> fire_coral_block x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_horn_coral_block: emerald x 3 -> horn_coral_block x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_tube_coral_block: emerald x 3 -> tube_coral_block x 1 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_vine: emerald x 1 -> vine x 3 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_pale_hanging_moss: emerald x 1 -> pale_hanging_moss x 3 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_brown_mushroom: emerald x 1 -> brown_mushroom x 3 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_red_mushroom: emerald x 1 -> red_mushroom x 3 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_lily_pad: emerald x 1 -> lily_pad x 5 [max uses 2; xp 1; multiplier 0.05]
  wandering_trader/emerald_small_dripleaf: emerald x 1 -> small_dripleaf x 2 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_sand: emerald x 1 -> sand x 8 [max uses 8; xp 1; multiplier 0.05]
  wandering_trader/emerald_red_sand: emerald x 1 -> red_sand x 4 [max uses 6; xp 1; multiplier 0.05]
  wandering_trader/emerald_pointed_dripstone: emerald x 1 -> pointed_dripstone x 2 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_sulfur_spike: emerald x 1 -> sulfur_spike x 2 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_rooted_dirt: emerald x 1 -> rooted_dirt x 2 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_moss_block: emerald x 1 -> moss_block x 2 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_pale_moss_block: emerald x 1 -> pale_moss_block x 2 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_wildflowers: emerald x 1 -> wildflowers x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_dry_tall_grass: emerald x 1 -> tall_dry_grass x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_firefly_bush: emerald x 3 -> firefly_bush x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_golden_dandelion: emerald x 2 -> golden_dandelion x 1 [max uses 12; xp 1; multiplier 0.05]
  wandering_trader/emerald_name_tag: emerald x 1 -> name_tag x 1 [max uses 5; xp 1; multiplier 0.05]
  wandering_trader/emerald_shelf_mushroom: emerald x 1 -> shelf_mushroom x 3 [max uses 12; xp 1; multiplier 0.05]
## wandering_trader/uncommon: pick 2 distinct trades
  wandering_trader/emerald_packed_ice: emerald x 1 -> packed_ice x 1 [max uses 6; xp 1; multiplier 0.05]
  wandering_trader/emerald_blue_ice: emerald x 6 -> blue_ice x 1 [max uses 6; xp 1; multiplier 0.05]
  wandering_trader/emerald_gunpowder: emerald x 1 -> gunpowder x 4 [max uses 2; xp 1; multiplier 0.05]
  wandering_trader/emerald_podzol: emerald x 3 -> podzol x 3 [max uses 6; xp 1; multiplier 0.05]
  wandering_trader/emerald_acacia_log: emerald x 1 -> acacia_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_birch_log: emerald x 1 -> birch_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_dark_oak_log: emerald x 1 -> dark_oak_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_jungle_log: emerald x 1 -> jungle_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_oak_log: emerald x 1 -> oak_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_spruce_log: emerald x 1 -> spruce_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_cherry_log: emerald x 1 -> cherry_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_mangrove_log: emerald x 1 -> mangrove_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_pale_oak_log: emerald x 1 -> pale_oak_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_poplar_log: emerald x 1 -> poplar_log x 8 [max uses 4; xp 1; multiplier 0.05]
  wandering_trader/emerald_enchanted_iron_pickaxe: emerald x 1 -> iron_pickaxe x 1 [max uses 1; xp 1; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  wandering_trader/emerald_long_invisibility_potion: emerald x 5 -> potion x 1 [max uses 1; xp 1; multiplier 0.05; result modifiers: potion long_invisibility]
## weaponsmith/level_1: pick 2 distinct trades
  smith/1/coal_emerald: coal x 15 -> emerald x 1 [max uses 16; xp 2; multiplier 0.05]
  weaponsmith/1/emerald_iron_axe: emerald x 3 -> iron_axe x 1 [max uses 12; xp 1; multiplier 0.2]
  weaponsmith/1/emerald_enchanted_iron_sword: emerald x 2 -> iron_sword x 1 [max uses 12; xp 1; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
## weaponsmith/level_2: pick 2 distinct trades
  smith/2/iron_ingot_emerald: iron_ingot x 4 -> emerald x 1 [max uses 12; xp 10; multiplier 0.05]
  smith/2/emerald_bell: emerald x 36 -> bell x 1 [max uses 12; xp 5; multiplier 0.2]
## weaponsmith/level_3: pick 2 distinct trades
  weaponsmith/3/flint_emerald: flint x 24 -> emerald x 1 [max uses 12; xp 20; multiplier 0.05]
## weaponsmith/level_4: pick 2 distinct trades
  weaponsmith/4/emerald_enchanted_diamond_axe: emerald x 12 -> diamond_axe x 1 [max uses 3; xp 15; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
  weaponsmith/4/diamond_emerald: diamond x 1 -> emerald x 1 [max uses 12; xp 30; multiplier 0.05]
## weaponsmith/level_5: pick 2 distinct trades
  weaponsmith/5/emerald_enchanted_diamond_sword: emerald x 8 -> diamond_sword x 1 [max uses 3; xp 30; multiplier 0.2; result modifiers: enchant as at an enchanting table with a level of uniform 5 to 19 from enchantment pool #on_traded_equipment, and add that level to the price; drop the offer if the result has no enchantments]
```

## 25. Worked examples

### 25.1 Sheep colour breeding

- Red (id 14) x yellow (id 4): the crafting data has a two-dye recipe red + yellow giving orange, so the lamb is orange (id 1), always.
- Blue x green: cyan. Black x white: gray. Purple x pink: magenta.
- Red x green: no two-dye recipe exists in the data, so the lamb is red or green with equal probability (`nextBoolean`).
- Red x red: the search finds no recipe (red + red gives nothing), so the result is red.
- A sheared parent still passes its colour; the lamb is born unsheared with metadata byte `colour id` (for orange `0x01`).

### 25.2 Villager trade price (demand, gossip, hero)

Trade `armorer/3/emerald_chainmail_chestplate`: price 4 emeralds, `max_uses` 12, `xp` 10, multiplier 0.2.

1. New offer, nobody has traded, the player has no gossip: demand 0, special diff 0: price = 4 + max(0, floor(4 x 0 x 0.2)) + 0 = 4.
2. The offer is used 12 times (sold out), then the villager restocks: demand = 0 + 12 - (12 - 12) = 12. Price = 4 + floor(4 x 12 x 0.2) + 0 = 4 + floor(9.6) = 13.
3. The same offer for a player whose stored gossip with this villager is trading 20, major_positive 6, minor_negative 4: reputation R = 20 x 1 + 6 x 5 + 4 x (-1) = 46. Special diff = -floor(46 x 0.2) = -9. Price = 13 - 9 = 4.
4. The player additionally has Hero of the Village amplifier 0: H = 0.3, diff -= max(floor(0.3 x 4), 1) = 1. Price = 3.
5. Clamp: with R = 200 the diff would be -40 and the price 13 - 40 < 1, so it is clamped to 1 (never above the stack size of the price item).
6. A second restock the same day after a second sell-out: demand = 12 + 12 - 0 = 24, price (no gossip) = 4 + floor(4 x 24 x 0.2) = 4 + 19 = 23.
7. A stalled offer: uses 2 of 12 at restock: demand = 12 + 2 - 10 = 4 (demand falls); price = 4 + floor(4 x 4 x 0.2) = 4 + 3 = 7.

Reputation arithmetic: a player trades 10 times: trading +2 each, capped at 25, so stored trading = 20 after 10 trades; after a villager is hurt by that player: minor_negative +25; after killing: major_negative +25 (weighted -125). A day later (decay step): trading 20 -> 18, minor_negative 25 -> 5, major_negative 25 -> 15, major_positive stays.

### 25.3 Horse gene formula

Foal health from parents with base health 20 and 28 (MIN 15, MAX 30, range 15): spread = |20 - 28| + 2 x (0.15 x 15) = 8 + 4.5 = 12.5; mean = 24. Draws (0.5, 0.5, 0.5): noise = 0, health 24. Draws (1, 1, 1): noise = 0.5, value = 24 + 6.25 = 30.25, reflected: 30 - 0.25 = 29.75. Draws (0, 0, 0): noise -0.5, value 17.75 (above MIN 15, kept). With parents 15 and 15: spread = 0 + 4.5, mean 15; draws (0,0,0): value 12.75, reflected to 15 + 2.25 = 17.25.

Jump check: a spawned horse with draws 1, 1, 1 has jump strength 0.4 + 0.2 x 3 = 1.0; with draws 0, 0, 0 it is 0.4. Speed: draws 1,1,1 give (0.45 + 0.9) x 0.25 = 0.3375, draws 0,0,0 give 0.1125.

### 25.4 Wandering trader spawn chance

Start: chance 25 (`MIN_SPAWN_CHANCE`). Day 1 timer fires: chance = clamp(25 + 25, 25, 75) = 50; roll `nextInt(100)`: spawn attempt if the roll is 0 to 50 (51 percent), then the 9 in 10 abort step leaves a 5.1 percent chance (0.51 x 0.1) of an actual spawn; on a successful spawn the chance returns to 25; on failure the chance stays at 50 and the next firing (24000 ticks later) makes it 75.

### 25.5 Mooshroom milk and shears

A brown mooshroom fed a poppy stores a stew effect; a bowl on it then yields a suspicious stew with that effect and clears the stored effect; a second bowl yields mushroom stew. Shearing a red adult: 5 red mushrooms (`rolls` 5), and the mooshroom becomes a cow.

## 26. Validation checklist

An implementer can check the following against this document:

1. Entity ids and sizes (index table) equal the entity-type registry order of 04 §5.1 and the sizes in each section.
2. Metadata: every mob's entries use the indices of §1.3 and the serializer ids of 00 §13.2 (for example sheep byte at 18, wolf variant serializer 25 at index 23, villager data serializer 18 at index 19, cat variant serializer 21 at index 20).
3. Attributes: pig 10 / 0.25; cow 10 / 0.2; sheep 8 / 0.23; chicken 4 / 0.25; rabbit 3 / 0.3 / 3; cat and ocelot 10 / 0.3 / 3; wolf 8 / 0.3 / 4 (tamed health 40); fox 10 / 0.3 / 2; panda 20 / 0.15 / 6; polar bear 30 / 0.25 / 6; goat 10 / 0.2 / 2; frog 10 / 1.0 / 10; tadpole 6 / 1.0; turtle 30 / 0.25; armadillo 12 / 0.14; sniffer 14 / 0.1; allay 20 / flying 0.1 / 0.1 / 2; bee 10 / flying 0.6 / 0.3 / 2; parrot 6 / flying 0.4 / 0.2 / 3; iron golem 100 / 0.25 / kb 1.0 / 15; snow golem 4 / 0.2; copper golem 12 / 0.2; villager 20 default / 0.5; wandering trader 20 / 0.7 default.
4. Breeding constants: love 600, parents age 6000, baby -24000, villager birth delay 275 to 324.
5. Price test vectors of §25.2 and gene test vectors of §25.3.
6. Biome spawner totals: for plains (`sheep` 12, `pig` 10, `chicken` 10, `cow` 8, `horse` 5, `donkey` 1 in the creature category) the creature list weight total is 46.
7. Sheep colour weights: temperate configuration totals 100 (5 + 5 + 5 + 3 + 82); pink probability 0.82 x 1/500.
8. Villager level thresholds 0, 10, 70, 150, 250; schedule keyframes at 10, 2000, 9000, 11000, 12000.

## 27. Open questions

Each item states what is unresolved and what was searched. No statement in the body text rests on memory; where something could not be read it says so and is listed here. The marker "(recalled, not verified)" is reserved for a statement that came from memory, and none remains.

1. Happy ghast and bat are covered in 21 (cross-reference: happy ghast, id 59, creature, 4 x 4, `Animal` based, food `happy_ghast_food` = snowball; bat, ambient). Nautilus (ids 89, 156) belongs to 21 as an aquatic mob. This document covers none of them beyond this note.
2. Axolotl is left to 21 (§18 gives only its metadata and spawner for the cross-check).
3. Sound event names per mob were not tabulated; they are the `SoundEvents` constants referenced by each class.
4. Spawn: the contents of block tag `axolotls_spawnable_on` and of `valid_spawn` for `Mob.checkMobSpawnRules` users (villager, wandering trader, iron golem, snow golem) were not read; `armadillo_spawnable_on` was read (§1.4).
5. Ocelot appears in the `monster` category lists of jungle and bamboo jungle in the 26.3 data (read data); the monster mob cap consequence is in 18 framework: natural spawning algorithm.
6. Biome entries listed twice (chicken in jungle, bamboo jungle, sparse jungle) were read as two entries; combining by weight is the natural reading but the spawn picker was not traced.
7. Horse family: the `randomizeAttributes` overrides are now read (§3.2); the full-power value (1.0) of the jump scale for input at least 90 is inferred from the branch shape of `getPlayerJumpPendingScale`.
8. Llama: slot count by strength (`getInventoryColumns`, searched in `Llama` and `AbstractChestedHorse`: it returns a value depending on `hasChest`; the arithmetic with strength was not displayed), carpet rules, `LlamaFollowCaravan` and the hurt-by and attack-wolf targets were not traced.
9. Camel: `RandomSitting` timing and the husk's jockey rules were searched but not traced; the rest of the camel constants are in §3.8.
10. Rabbit: exact jump-control integration (`JumpControl` subclass) beyond the constants of §4 was not traced.
11. Fox: goal internals (`StalkPrey`, `FoxPounce`, `Sleep`, `SeekShelter`, `FoxEatBerries`, `PerchAndSearch`, `FoxStrollThroughVillage`, `FoxSearchForItems`) and the trust rules were not read (only the parameter lists, flags and constants `MIN_TICKS_BEFORE_EAT` 600, baby scale 0.6 are given).
12. Wolf: `WolfAvoidEntity`, `Beg` and the angry-at predicate internals; the tamable owner-teleport rule is read in part (`shouldTryTeleportToOwner` is true when the owner is at least 12 blocks away: squared distance 144; the destination search `teleportToAroundBlockPos` was not displayed).
13. Cat: `CatLieOnBlock`, `CatSitOnBlock`, the cat tempt goal's scare rule; contents of tags `cats_can_lie_on` and `cat_does_not_teleport_to` were not read.
14. Panda: the goals that implement the lazy, playful and aggressive traits; `canPickUpAndEat`, tag `panda_eats_from_ground`.
15. Polar bear: the `Panic` condition and the target predicates.
16. Goat: which blocks make a ram break a horn (the ram behaviour's block test; the block tag `snaps_goat_horn` exists = overworld natural logs, stone, packed ice, iron ore, coal ore, copper ore, emerald ore, but the code that tests it was not displayed).
17. Frog: froglight drops when a frog eats a magma cube were searched for in `Frog`, `ShootTongue`, `FrogAi` and the data directory and not found; the contents of fluid tag `frog_tries_to_find_land_near` and block tag `frog_prefer_jump_to` were not read.
18. Turtle: the goals' internals (go home, travel, go to water, random stroll) and the egg block's hatch and trample rules were not read (only parameters and the laying goal are given).
19. Armadillo: the danger-detection behaviour class `ArmadilloAi$1`, the rolling-out behaviour and `canStayRolledUp`.
20. Sniffer: what breeding produces and how the egg hatches, and the internals of `Searching`, `Scenting`, `Sniffing`, `FeelingHappy`.
21. Allay: what makes an allay dance (jukebox / note-block listening), the liked-noteblock behaviour and `GoAndGiveItemsToTarget`; how allays first appear (structure placement) is not stated in this document.
22. Bee: pollination, nest entry and exit timings, `BeeGrowCrop`, the anger share radius; only the goal list, constants, sting, water and hive-entry rules were read.
23. Parrot: shoulder-landing rules and shoulder-parrot storage; the imitation sound map; dance behaviour beyond the 3.46-block jukebox check.
24. Iron golem: `DefendVillageTarget`, `MoveBackToVillage` details and the effect of the player-created flag on targeting.
25. Snow golem: whether melting biomes also suppress the snow trail.
26. Copper golem: which of the two container predicates is the source and which is the destination (one is block tag `copper_chests`, the other chest or trapped chest); transport parameters (stack size moved, timing) beyond the quoted callbacks.
27. Villager: `AcquirePoi`, `YieldJobSite`, `PoiCompetitorScan`, `ReactToBell`, `SocializeAtBell`, `TradeWithVillager`, `SetRaidStatus` internals; the schedule track's interpolation (read as discrete: the track gives no easing); the stored value of `numberOfRestocksToday` across saves.
28. Villager trade modifiers: the extra-cost rules for enchanted books and enchanted equipment are read (§22.4); the data lines of §24 list banner, potion and stew modifiers as in the data; the exploration-map item behaviour (map marker and search algorithm) is outside this document.
29. Wandering trader: the `UseItem` conditions of the invisibility and milk goals, `WanderToPosition` internals and the trader-llama leash behaviour.
30. The cat, wolf, pig, cow, chicken sound-variant registries have 2 to 7 entries (wolf 7: angry, big, classic, cute, grumpy, puglin, sad); their numeric ids depend on the order in Registry Data (04 §4), a server choice.
31. Entity ids in the index are the registration order of the `EntityTypes` static initializer (inferred), not the `registries.json` dump.
32. Item definitions for dye, brush, shears, bucket, saddle, harness, horse armour and wolf armour are in the item docs.
33. Brain-argument meanings: the unlabelled numeric arguments of the villager, camel, goat, frog, armadillo, sniffer, allay and copper-golem behaviour lists are "types only" (positional numbers whose role inside the behaviour was not read), except those listed in §1.1; `RunOne`, `GateBehavior`, `TriggerGate` semantics are in 18 framework: Brain system.
34. The effect of the iron golem player-created flag on `DefendVillageTarget` was searched and not read.
35. The ocelot spawner entries appear under the category `monster` in the 26.3 biome data; whether that is intended is not determinable from the artifact (the placement rules are read).
36. Verification status: sections 22 to 24 and 1 were re-verified in the last review round; the equines (§3), rabbit, cats, wolf, fox, panda, polar bear, goat, frog, turtle, armadillo, sniffer, allay, bee, parrot and golems were verified in earlier rounds only and not re-checked in round 3.
