# Residual mob questions, part 1: shared model and framework answers (round RS26)

| Item | Value |
|---|---|
| Covers | Part 1 of round RS26 (GAP-31, GAP-18 villages): the shared model for all nine parts (conventions, answer-row schema, answer ids `RQ-<part>.<n>`, master index of every open item of documents 18 to 21, shared AI vocabulary), and the framework answers that belong to no single mob: default equipment tiers and enchanting, item entity motion, merge, pickup and throw, fire extinguishing by blocks, block friction, speed, jump and spawn data, per-mob framework values (experience, cluster size, ambient interval, taming), the `EntitySpawnReason` matrix, game rules, statistics, the arthropod tag, gate behaviours, generic behaviour internals, generic sensors and `getWalkTargetValue` |
| Does not cover | Parts 2 to 9 (spawners and trial spawner, villagers and villages, land animals, warden and overworld hostiles, Nether, aquatic, vehicles and decorations, End); the data rows of any data pack (tag members, loot, recipes, enchantment definitions) which the extraction tool supplies |
| Version | 26.3, protocol 777, world data version 5023 (as recorded in [README.md](README.md)) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in README.md) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the JSON data in the jar, with no execution. Counts were taken from the extracted class tree, never from a zip listing. Recalled knowledge was used only to decide where to look. |

Standing rules for this round (from `docs/design/README.md` Parts 0, 1 and 4): the standard Minecraft content is the target; the extraction tool supplies data rows (tags, loot tables, recipes, registry JSON, structure NBT) so this document gives schemas, semantics and the engines that interpret them; code-defined content (behaviours, algorithms, constants in code) is given completely.

Cross-references use `NN section` for other reference documents, for example "18 section 4.7" is [18](18-mob-framework.md) section 4.7. Other round documents numbered 22 to 47 may exist; this document does not repeat their content. **Authority rule:** for the item entity (motion, friction block, merge, pickup, throw, drops) [41](41-item-entity-physics.md) is authoritative (41 section 1 constructors and setters, 41 section 3 tick order and friction, 41 section 4 pickup); sections 4.2 and 4.4 below keep only what the mob framework needs and point to 41 where the two overlap. Entity type ids are verified in [46](46-registry-ids.md) section 11 (Open question 6). Block counts are reconciled with [24](24-block-registry-1-model-and-foundation.md) (sections 1 and 2.3) in RQ-1.9.

---

## 1. Conventions shared by every part of RS26

### 1.1 Evidence classes

Every value, formula, ordering rule and behaviour in the RS26 documents carries one of these classes, either in the answer row or in the text.

| Class | Meaning | How written |
|---|---|---|
| **B** | read from bytecode of the artifact in this round | plain statement |
| **C** | read from a constant table (static initialiser, enum constants, pool constants) | plain statement |
| **D** | read from a JSON data file in the artifact (`data/minecraft/...`) | plain statement, with the data path named; rows are not copied when they are data rows |
| **I** | deduced from partial bytecode plus the surrounding structure | marked **(inferred)** and listed in Open questions |
| **R** | taken from recall, never read | marked **(recalled, not verified)** and listed in Open questions; never used for a number an implementer needs |

No class **R** statement is present in this document. Where the artifact differs from older knowledge, the difference is stated in section 5 (corrections).

### 1.2 Answer-row schema

Every part of RS26 reports its results as answer rows. A row has these columns, in this order.

| Column | Content |
|---|---|
| Id | `RQ-<part>.<n>`, assigned in section 4 order within each part |
| Source doc | the document (18, 19, 20 or 21) the question came from |
| Item | the open-question number (`OQ n`) or the text location ("not read" list, section number) |
| Answer | the answer in one or two sentences, or the section of this part that holds it |
| Evidence | class from 1.1, plus the artifact class or file that was read and the method (for example "B, `Mob`, `javap -c`") |
| Replaces | the section of document 18, 19, 20 or 21 that the answer replaces, with a fold-in note: "delete OQ", "replace the sentence", "append" |

Fold-in notes are instructions to the document editors of the next edit round, not text already applied. Documents 18 to 21 are not edited in RS26.

### 1.3 Numbering of answer ids

`RQ-<part>.<n>` where the part is 1 to 9 as in 2.1. Within a part `n` increases in the order of that part's document. The ids of this part are RQ-1.1 to RQ-1.40 (section 4). An answer that other parts rely on is cited by id.

### 1.4 Random numbers

The artifact draws from the entity's own generator for gameplay rolls. Implementations may use any uniform generator (18 "Reading conventions"). Where the call order of draws matters for tests, the order is stated and a fixture can feed values in that order. The only exception in this document is the weighted shuffle of behaviour gates (3.5), which the artifact draws from a fresh unseeded generator: any uniform generator is acceptable there too.

---

## 2. Master index of the open items of documents 18 to 21

### 2.1 Parts

| Part | Subject |
|---|---|
| 1 | shared model and framework (this document) |
| 2 | spawners, trial spawner, custom spawners, structure spawn overrides, spawn tables |
| 3 | villager, points of interest, village, raid, village siege |
| 4 | land animal goals (documents 19 sections 3 to 21) |
| 5 | warden, creaking, breeze, overworld hostile mobs |
| 6 | Nether mobs, strider, piglin family |
| 7 | aquatic mobs and nautilus |
| 8 | vehicles, projectiles, decorations, other entities |
| 9 | End mobs, happy ghast, Ender Dragon |

Status values: **here** (answered in this document, id given), **pointer** (this document records where it goes), **part n** (answered or to be answered by part n), **data** (the item is a data row, supplied by the extraction tool), **closed** (the source document already marked it closed), **n/a** (not a behaviour question).

### 2.2 Document 18 (mob framework), Open questions

| Item | Topic | Part | Status |
|---|---|---|---|
| 1 | attachments of player, mannequin, camel, boats, rafts, chest boats | 8 | pointer |
| 2 | `getWalkTargetValue` overrides | 1 | here, RQ-1.35 |
| 3 | Brain generics: villager, raid and POI behaviours | 3 | part 3 |
| 3 | `LongJump*` behaviours | 4 | part 4 |
| 3 | `warden` package behaviours | 5 | part 5 |
| 3 | sensors `villager_hostiles`, `golem_detected` | 1 (use in 3) | here, RQ-1.30 |
| 3 | sensors `axolotl_attackables`, `frog_attackables` | 1 (use in 4, 7) | here, RQ-1.31 |
| 3 | sensors `piglin_specific_sensor`, `piglin_brute_specific_sensor`, `hoglin_specific_sensor` | 1 (detail in 6) | here, RQ-1.32 |
| 3 | sensors `warden_entity_sensor`, `breeze_attack_entity_sensor` | 1 (detail in 5) | here, RQ-1.33 |
| 3 | sensor `armadillo_scare_detected` | 1 (detail in 4) | here, partly, RQ-1.34 |
| 3 | sensor `secondary_pois` | 1 (rule), 3 (profession data) | here, RQ-1.30; the per-profession block sets are part 3 |
| 3 | sensors `villager_babies`, `nearest_bed`, `hurt_by`, `nearest_items`, `dummy` | 1 | here, RQ-1.30 |
| 4 | trial spawner, spawn egg components, custom spawners (phantom, patrol, trader, cat) | 2 | part 2 |
| 4 | custom spawner: village siege, raid | 3 | part 3 |
| 5 | tier table, `mob_spawn_equipment`, comparison functions | 1 | here, RQ-1.1 to RQ-1.4 |
| 6 | `ItemEntity` motion, friction, merge | 1 | here, RQ-1.5, RQ-1.6 |
| 7 | `extinguishFire` callers in fluids | 1 | here, RQ-1.8 |
| 8 | protection arithmetic | n/a | closed by 17 section 6 |
| 9 | block friction, speed, jump, `isValidSpawn`, `valid_spawn`, per-block effects | 1 | here, RQ-1.9 to RQ-1.12 |
| 10 | per-mob framework values | 1 | here, RQ-1.13 to RQ-1.17 |
| 11 | `EntitySpawnReason` matrix | 1 | here, RQ-1.18 |
| 12 | projectiles, wind charge entities | 8 | part 8 |
| 13 | game rules | 1 | here, RQ-1.19 |
| 14 | statistics used by mobs | 1 | here, RQ-1.20 |
| 15 | enchantment helper for mob equipment | 1 | here, RQ-1.2 |
| 16 | arthropod tag and Bane of Arthropods | 1 | here, RQ-1.21 |
| 17 | structure `spawn_overrides` replacement rule, piece versus full box | 2 | part 2 |
| 18 | `GateBehavior` and `TriggerGate` | 1 | here, RQ-1.22 |
| 19 | `TryFindLand`, `TryFindLandNearLiquid`, `TryFindLiquid`, `GoToWantedItem`, `Croak`, `SetHiddenState`, `CopyMemoryWithExpiry` | 1 | here, RQ-1.23 to RQ-1.27 |
| 3 (tail) | `TryLaySpawnOnFluidNearLand`, `SetWalkTargetFromBlockMemory`, `ChargeAttack`, `RamTarget`, `PrepareRamNearestTarget` | 1 (the first two); 4 (the last three) | here, RQ-1.28, RQ-1.29; part 4 |

### 2.3 Document 19 (land animals and neutral mobs), Open questions

| Item | Topic | Part | Status |
|---|---|---|---|
| 1, 2 | happy ghast, bat, axolotl owned elsewhere | 9, 7 | closed (cross-references) |
| 3 | sound event names | n/a | out of scope (spec 001: sounds) |
| 4 | tag `axolotls_spawnable_on`, `valid_spawn` | 1 | here: `valid_spawn` RQ-1.11; tag members are data |
| 5, 35 | ocelot in `monster` category | 2 | part 2 |
| 6 | duplicate biome entries, spawn picker | 2 | part 2 |
| 7 | horse jump scale | 4 | part 4 |
| 8 | llama | 4 | part 4 |
| 9 | camel, husk jockey | 4 | part 4 |
| 10 | rabbit jump control | 4 | part 4 |
| 11 | fox | 4 | part 4 |
| 12 | wolf | 4 | part 4 (taming chance RQ-1.16) |
| 13 | cat | 4 | part 4 (taming chance RQ-1.16) |
| 14 | panda | 4 | part 4 |
| 15 | polar bear | 4 | part 4 |
| 16 | goat | 4 | part 4 |
| 17 | frog | 4 | part 4 (sensor RQ-1.31, croak RQ-1.26, spawn laying RQ-1.28) |
| 18 | turtle | 4 | part 4 |
| 19 | armadillo | 4 | part 4 (scare predicate RQ-1.34) |
| 20 | sniffer | 4 | part 4 |
| 21 | allay | 4 | part 4 |
| 22 | bee | 4 | part 4 |
| 23 | parrot | 4 | part 4 (taming chance RQ-1.16) |
| 24, 34 | iron golem, village defence | 3 | part 3 |
| 25 | snow golem melting | 4 | part 4 |
| 26 | copper golem | 4 | part 4 |
| 27 | villager internals | 3 | part 3 |
| 28 | villager trade modifiers, map items | 3 | part 3 |
| 29 | wandering trader | 3 | part 3 |
| 30 | sound-variant registries | n/a | data; ids are the registry order the server chooses (04) |
| 31 | entity ids in the index | 1 | not answered, see Open question 6 |
| 32 | item definitions | n/a | pointer to 17 |
| 33 | brain argument meanings | 3, 4, 7 | each part labels its own mobs' arguments |
| 36 | verification status | n/a | n/a |

### 2.4 Document 20 (overworld hostile mobs), Open questions

| Item | Topic | Part | Status |
|---|---|---|---|
| 1 to 9, 11, 13, 15 to 21, 23, 26, 28 | already closed in the document | n/a | closed |
| 10 | pillager crossbow quick charge, `performShooting` | 5 | part 5 |
| 12 | mineshaft and mansion spawner blocks and structure spawns | 2 | part 2 |
| 14 | reserved | n/a | n/a |
| 22 | warden `TryToSniff`, `Digging`, `Emerging` | 5 | part 5 |
| 24 | sulfur cube attributes in movement | 5 | part 5 |
| 25 | entity ids against a captured registry sync | 1 | not answered, Open question 6 |
| 27 | block blast resistance | 1 | not answered: block registry data, deferred to the block registry round (GAP-1); Open question 7 |

### 2.5 Document 21 (aquatic, Nether, End, bosses, entities), Open questions

| Item | Topic | Part | Status |
|---|---|---|---|
| 1, 5, 15, 18, 20, 21, 22 | ownership, recall, resolved or n/a | n/a | closed or n/a |
| 2 | biome `overlay` modifier | 2 | part 2 |
| 3 | bastion and fortress piece spawners | 2, 6 | part 2 and part 6 |
| 4, 16 | piglin and hoglin details, loot, anger writer | 6 | part 6 |
| 6 | spawn predicates for `Turtle`, `Slime`, `Animal` | 2 | part 2; the `Animal` rule is read here, RQ-1.38 |
| 7 | fish flop, dolphin hop, elder guardian effect filter | 7 | part 7 |
| 8 | squid experience reward; breeding food of squids and dolphins | 1 (xp); 7 (food) | xp here, RQ-1.37; food part 7 |
| 9 | axolotl play-dead | 7 | part 7 |
| 10 | nautilus | 7 | part 7 |
| 11 | strider | 6 | part 6 |
| 12 | dragon phase hooks, strafe | 9 | part 9 |
| 13 | item pickup and throw delays | 1 | here, RQ-1.7 |
| 13 | `thunderHit`, area effect cloud loop, armor stand, frames, paintings, interaction, marker, display | 8 | part 8 |
| 14 | boats and minecarts | 8 | part 8 |
| 17 | cushion, mannequin | 8 | part 8 |
| 19 | happy ghast | 9 | part 9 |

---

## 3. Shared vocabulary for the AI system

Parts 2 to 9 cite these terms by name. The Brain framework is first described in [18](18-mob-framework.md) sections 4.5 to 4.7; this section completes the parts that those sections left open and fixes the terms.

### 3.1 Terms

| Term | Definition (all read) |
|---|---|
| **Brain** | the per-mob container of memories, sensors, activities and behaviours; ticked from the mob's `customServerAiStep` (18 section 4.5) |
| **MemoryModuleType** | a registered key of the Brain's memory map. The registry names are listed in 18 section 4.5. A memory slot is absent or holds one value, optionally with a time-to-live in ticks |
| **MemoryStatus** | the three entry conditions a behaviour places on a memory: `VALUE_PRESENT` (slot holds a value), `VALUE_ABSENT` (slot is empty), `REGISTERED` (the key is registered with the mob's Brain, the slot may be either) |
| **Sensor** | a periodic scanner (default scan rate 20 ticks, random first delay) that reads the world and writes memories (18 section 4.6). A sensor declares the memories it needs in `requires` |
| **Behavior** | a unit of work with required memory states, a duration range (default 60 and 60) and a status STOPPED or RUNNING (18 section 4.6) |
| **OneShot** | a behaviour built with `BehaviorBuilder` from memory conditions and one trigger function: when started it evaluates the trigger once and finishes in the same tick; the trigger's boolean result says whether it started successfully |
| **Trigger** | the function inside a OneShot: `(level, mob, gameTime) -> boolean` |
| **BehaviorControl** | the interface of anything the Brain can run: a Behavior, a OneShot or a GateBehavior; it has `getStatus`, `tryStart`, `tickOrStop`, `doStop` and `getRequiredMemories` |
| **GateBehavior** | a behaviour that holds weighted child behaviours and decides, by an order policy and a running policy, which children to start (3.4); `RunOne` is the gate `(SHUFFLED, RUN_ONE)` |
| **TriggerGate** | the OneShot counterpart: a gate over triggers; `triggerOneShuffled` is `(SHUFFLED, RUN_ONE)` (3.4) |
| **ShufflingList** | the weighted list a gate keeps; "shuffle" re-sorts it by a random key per entry (3.5) |
| **Activity** | a named group of prioritised behaviours (18 section 4.5): core, idle, work, play, rest, meet, panic, raid, pre_raid, hide, fight, celebrate, admire_item, avoid, ride, play_dead, long_jump, ram, tongue, swim, lay_spawn, sniff, investigate, roar, emerge, dig |
| **WalkTarget** | the memory value `walk_target`: a position tracker, a speed modifier (float) and a close-enough distance (int). `MoveToTargetSink` (18 section 4.6) executes it |
| **PositionTracker** | `BlockPosTracker(pos)` is a fixed block; `EntityTracker(entity, trackEyes)` follows an entity, aiming at its eye position when `trackEyes` is true and at its feet otherwise. `look_target` and `walk_target` hold trackers |
| **GlobalPos** | a dimension key plus a block position; used by `home`, `job_site`, `potential_job_site`, `meeting_point`, `hiding_place` and other block memories |
| **Ticker** | a countdown helper used by behaviours with a cooldown: either a mutable "next allowed game time" long, or a counter reset to a uniform interval |

### 3.2 Entry conditions in practice

`Brain.checkMemory(type, status)` is what both a plain behaviour and a gate use to test an entry condition. A gate tests only its own entry map; the entry maps of its children are tested later by each child's own `tryStart`. `getRequiredMemories` of a gate is the union of its own map and its children's (used only by the Brain to know which activities need which memories). **(B, `GateBehavior`)**

### 3.3 Brain tick order

`Brain.tick` runs exactly four steps, in this order: (1) `forgetOutdatedMemories` (memory time-to-live expiry: every memory with a timer is decremented and erased at expiry), (2) `tickSensors`, (3) `startEachNonRunningBehavior` (every STOPPED behaviour of every active activity, in priority order), (4) `tickEachRunningBehavior`. There is **no schedule step inside `Brain.tick`**: the active activity is refreshed from the schedule by the mob itself, or by the `UpdateActivityFromSchedule` and `SetHiddenState` behaviours calling `Brain.updateActivityFromSchedule`. **(B, `Brain.tick`)** This corrects 18 section 4.5, which lists "sensors, schedule, start, tick" and omits the memory-expiry step (section 5, item 11). The gate rules below apply inside step 3 (the Brain calls `tryStart` on a gate only while the gate is STOPPED) and step 4.

### 3.4 Gate semantics (RQ-1.22)

A `GateBehavior` is built from: an entry-condition map, a set of memories to **erase when the gate stops**, an **order policy**, a **running policy** and a list of `(behaviour, weight)` pairs. **(B, `GateBehavior`, `GateBehavior$OrderPolicy`, `GateBehavior$RunningPolicy`, `RunOne`, `TriggerGate`)**

| Policy | Values | Effect |
|---|---|---|
| Order policy | `ORDERED` | the children keep the order in which they were given; no draws |
| | `SHUFFLED` | the children are re-sorted by a random key each time the gate starts (3.5) |
| Running policy | `RUN_ONE` | walk the children in the (possibly shuffled) order, considering only children whose status is STOPPED, and call `tryStart` on each until one returns true; stop there. At most one child is started |
| | `TRY_ALL` | call `tryStart` on every STOPPED child, in order; all children that can start do start |

Gate lifecycle:

1. `tryStart(level, mob, time)`: if every entry condition holds, the gate becomes RUNNING, the order policy is applied to the child list, the running policy is applied, and `tryStart` **returns true even when no child could start**. If an entry condition fails it returns false and nothing changes.
2. `tickOrStop`: every child whose status is RUNNING gets its `tickOrStop` call. Afterwards, if **no** child is RUNNING, the gate calls its own `doStop`. (A gate in which no child started therefore stops in the same Brain tick, in step "tick", because the Brain runs step "tick" after step "start".)
3. `doStop`: status STOPPED; every child still RUNNING gets `doStop`; then every memory in the erase-on-exit set is erased.
4. While one child runs, the gate does not start another: children are only chosen at `tryStart`. A `RUN_ONE` gate selects again only after the whole gate has stopped.

`TriggerGate` is the OneShot form. It builds a OneShot with no memory conditions of its own whose trigger does the following: when the order policy is `SHUFFLED` it re-sorts the weighted list; then it visits the triggers in list order; it calls each trigger; after a trigger that returns true, a `RUN_ONE` policy stops the visit, a `TRY_ALL` policy continues; the OneShot itself always returns true. **(B, `TriggerGate.triggerGate`)** The only entry point used by the artifact is `triggerOneShuffled` = `(SHUFFLED, RUN_ONE)`.

Combinations used by the artifact (read from the Ai classes):

| Gate | Order, running | Used by |
|---|---|---|
| `RunOne` | SHUFFLED, RUN_ONE | the common "pick one idle behaviour" gate (most Brain mobs) |
| `GateBehavior` | ORDERED, TRY_ALL | frog, axolotl, nautilus, zombie nautilus, tadpole (the Ai classes build one gate this way) |
| `GateBehavior` | ORDERED, RUN_ONE | villager goal packages (three gates) |
| `TriggerGate.triggerOneShuffled` | SHUFFLED, RUN_ONE | villager goal packages (three), piglin Ai (one) |

### 3.5 Weighted shuffle (`ShufflingList.shuffle`)

Each entry has a positive integer weight `w`. When a shuffle is requested, every entry gets a fresh random float `r` in [0, 1) and the key `k = -(r ^ (1 / w))`; the list is then sorted ascending by `k`. So the entry with the largest `r^(1/w)` comes first, and a larger weight makes a large `r^(1/w)` more likely. **(B, `ShufflingList$WeightedEntry.setRandom`)** The generator is a fresh `RandomSource.create()` held by the list, not the entity's generator.

Worked example: entries A (weight 2) and B (weight 1). Draws `r_A = 0.25`, `r_B = 0.60`. Keys: A = -(0.25^0.5) = -0.5; B = -(0.60^1) = -0.6. Ascending order puts B (-0.6) first, then A. With `RUN_ONE` the gate tries B first.

---

## 4. Answers

Evidence column abbreviations: **B** bytecode, **C** constant table, **D** data JSON, **I** inferred.

### 4.1 Default equipment: tiers, comparison, enchanting (RQ-1.1 to RQ-1.4)

**RQ-1.1 Tier table (`Mob.getEquipmentForSlot(slot, tier)`).** Tiers run 0 to 5 (the roll in 18 section 7.1.2 produces 0 to 5). The slot decides the item kind, the tier decides the material:

| Tier | Material | Helmet, chestplate, leggings, boots |
|---|---|---|
| 0 | leather | `leather_helmet`, `leather_chestplate`, `leather_leggings`, `leather_boots` |
| 1 | copper | `copper_helmet`, `copper_chestplate`, `copper_leggings`, `copper_boots` |
| 2 | golden | `golden_*` |
| 3 | chainmail | `chainmail_*` |
| 4 | iron | `iron_*` |
| 5 | diamond | `diamond_*` |

A tier above 5, or a slot that is not head, chest, legs or feet, returns no item (nothing is equipped). **(B, C)** Copper is a tier of this version, between leather and golden. Netherite is not in the table.

The slot order used when equipment is populated, `EQUIPMENT_POPULATION_ORDER`, is head, chest, legs, feet: the static initialiser builds it with `List.of(HEAD, CHEST, LEGS, FEET)`, an immutable four-element list **(C)**. Do not confuse it with `EquipmentSlot.VALUES` (RQ-1.2), which runs feet, legs, chest, head. The roll structure (probability `0.15 x special`, tier `nextInt(3)` plus three `0.1087` rolls, per-slot stop chance 0.25 or 0.1 on Hard, first slot always considered) is in 18 section 7.1.2 and is confirmed unchanged by this reading. The check for an empty slot comes after the stop roll: a slot that already holds an item still consumes its stop roll.

**RQ-1.2 Enchanting default equipment.** After equipment is populated (and for any mob that calls it), `populateDefaultEquipmentEnchantments` handles the main hand with base chance **0.25** and every humanoid armour slot with base chance **0.5**, in the order main hand first, then every entry of `EquipmentSlot.VALUES` in list order, keeping only the slots whose type is HUMANOID_ARMOR (all other slot types are skipped without any draw). `VALUES` is the declaration order of the enum, `List.of(values())`: MAINHAND, OFFHAND, FEET, LEGS, CHEST, HEAD, BODY, SADDLE. So the armour enchant rolls run **feet, legs, chest, head**, the opposite of the population order head, chest, legs, feet (RQ-1.1); a fixture that feeds draws in order must follow this. **(C)** For one slot (`enchantSpawnedEquipment`): an empty stack is skipped **before** any `nextFloat` is drawn; if the stack is non-empty and `nextFloat() < base x special` (`special` is the local-difficulty special multiplier: 0 when the effective local difficulty is below 2, 1 when it is above 4, and `(d - 2) / 2` in between; 18 section 7.1.3; `DifficultyInstance.getSpecialMultiplier`, **B**), the stack is enchanted from the provider `mob_spawn_equipment` and replaces the slot's stack. **(B, `Mob`)**

The provider (`EnchantmentHelper.enchantItemFromProvider`, then `EnchantmentsByCostWithDifficulty.enchant`) is a data entry `data/minecraft/enchantment_provider/mob_spawn_equipment.json` of type `by_cost_with_difficulty` with `enchantments` = tag `on_mob_spawn_equipment`, `min_cost` 5, `max_cost_span` 17. **(D)** The engine:

1. `special` again = the difficulty's special multiplier.
2. `cost = randomBetweenInclusive(min_cost, min_cost + (int)(special x max_cost_span))`, where `(int)` truncates the float product. With these data, cost lies in 5 to 22.
3. `selectEnchantment(random, stack, cost, pool)` produces a list of (enchantment, level) pairs by exactly the selection of 17 section 6.5 (the enchanting-table algorithm: enchantability `N` from the stack's `enchantable` component, `m = cost + 1 + nextInt(N/4+1) + nextInt(N/4+1)`, the 0.15 spread, the highest satisfying level per enchantment, weighted pick, the `nextInt(50) > m` continuation test, removal of incompatible enchantments, `m = m / 2`). Read in this round and consistent with 17 section 6.5: two `nextInt(N/4 + 1)` draws, then two `nextFloat` draws for the 0.15 spread, `Math.round` then a clamp to at least 1, the weighted pick, and a `nextInt(50)` continuation test. The weighted pick (`WeightedRandom.getRandomItem(random, list, weightFn)`) sums the weights and draws exactly one `nextInt(total)`; a negative total is an error and a zero total gives no result, with two differences read here: the pool is the tag `on_mob_spawn_equipment` (which contains the tag `non_treasure`, so every non-treasure enchantment, **D**) and a stack with no `enchantable` component yields an empty list (nothing is added). An enchantment is a candidate only when the stack is in its `primary_items` (or, for a book, always). **(B, `EnchantmentHelper.selectEnchantment`, `getAvailableEnchantmentResults`)**
4. Each pair is applied with `upgrade`: the level becomes the larger of the existing and the new level. The result is written to the stack's enchantments component.

The other providers (`pillager_spawn_crossbow`, `enderman_loot_drop`, the `raid` set) use the same `EnchantmentProvider` interface and are data entries of other parts. **(D, file names only)**

**RQ-1.3 Replacing equipment (`canReplaceCurrentItem(candidate, current, slot)`).** This replaces the summary in 18 section 7.2.

1. If `current` is empty: yes.
2. If the slot is an armour slot (`isArmor`): `compareArmor`.
3. If the slot is the main hand: `compareWeapons`.
4. Otherwise: no. Mobs override this for their own rules (per-mob catalogues).

`compareArmor(candidate, current, slot)`:
1. If `current` has the enchantment effect `prevent_armor_change` (the Curse of Binding component): no.
2. Compute `A_c`, `A_o` = the armour attribute approximated for candidate and current (below), then `T_c`, `T_o` for armour toughness.
3. If `A_c != A_o`: yes exactly when `A_c > A_o`.
4. Else if `T_c != T_o`: yes exactly when `T_c > T_o`.
5. Else `canReplaceEqualItem`.

`compareWeapons(candidate, current, slot)`:
1. Let `P` be the mob's preferred-weapon item tag (`getPreferredWeaponType`; none by default). If `P` exists: if `current` is in `P` and `candidate` is not: no. If `current` is not in `P` and `candidate` is: yes.
2. Compute `D_c`, `D_o` = the attack-damage attribute approximated for candidate and current. If `D_c != D_o`: yes exactly when `D_c > D_o`.
3. Else `canReplaceEqualItem`.

`getApproximateAttributeWith(stack, attribute, slot)`: start with `v = base value of the attribute on this mob` (0 when the mob does not have the attribute), then fold the stack's attribute-modifier component: for each modifier entry **in list order** whose slot group matches `slot` and whose attribute is the one asked for, with `a` the modifier amount: operation ADD_VALUE does `v += a`; ADD_MULTIPLIED_BASE does `v += a x base`; ADD_MULTIPLIED_TOTAL does `v += a x v` (the running value). `base` is the mob's base value (the starting `v`). The result is `v`. **(B, `Mob`, `ItemAttributeModifiers.compute`)**

`canReplaceEqualItem(candidate, current)` (the tie-break), in order:
1. Let `n_c`, `n_o` be the numbers of distinct enchantments (entries of the `enchantments` component) of candidate and current. If `n_c != n_o`: yes exactly when `n_c > n_o`.
2. Else compare damage values `d_c`, `d_o`: if different, yes exactly when `d_c < d_o` (less worn is better).
3. Else: yes exactly when the candidate has a custom name and the current has none.

Preferred weapon tags (the class-to-tag pairing is read from each override): `Drowned` returns tag `drowned_preferred_weapons`, `AbstractSkeleton` `skeleton_preferred_weapons`, `Pillager` `pillager_preferred_weapons`, `Piglin` `piglin_preferred_weapons` (the tag files are in `data/minecraft/tags/item/`; the members are data). Two behaviours refine this: `Piglin.getPreferredWeaponType` returns **none for a baby** (so a baby piglin has no preferred tag), and `WitherSkeleton` overrides it to return **none** (the skeleton tag does not apply to it) and overrides `canHoldItem` to reject any item in tag `wither_skeleton_disliked_weapons` before deferring to the `AbstractSkeleton` rule. **(B, D)**

**RQ-1.4 Worked fold-in.** See examples E1 to E3 in section 6.

### 4.2 Item entity (RQ-1.5 to RQ-1.7)

**RQ-1.5 Motion.** (`ItemEntity.tick`; extends 21 section 8.1.) [41](41-item-entity-physics.md) section 3 is the authoritative description of item motion (gravity, drag, fluids, friction, bounce, merge cadence, age, with the f32 details); this list is the framework summary and agrees with 41. The constructor `(level, x, y, z, stack)` gives the item a random motion `(nextDouble x 0.2 - 0.1, 0.2, nextDouble x 0.2 - 0.1)`, x drawn before z; the eight-argument constructor takes an explicit motion (41 section 1). Per tick, in order:

1. If the stack is empty: discard and stop.
2. Entity base tick; then if `pickupDelay > 0` and it is not the infinite value 32767, decrement it.
3. Remember the old position (for the block-change test of step 9).
4. Fluids: if in water with water height above **0.1**: the new velocity is `(v_x x 0.99, v_y + n, v_z x 0.99)` where `n = 0.0005` when `v_y < 0.06` and 0 otherwise (the vertical component is **not** multiplied by the factor, it only receives the small upward nudge); else if in lava with lava height above 0.1: the same formula with the horizontal factor **0.95**; else apply gravity (item gravity **0.04** per tick: `v_y -= 0.04`).
5. Server only: `noPhysics` is set when the item's box, shrunk by `1e-7`, collides with blocks; if set, the item is pushed toward the nearest free space (`moveTowardsClosestSpace`) at the box's x, vertical middle and z. On the client `noPhysics` is cleared.
6. Movement happens when the item is airborne, or its horizontal speed squared exceeds `1e-5`, or `(tickCount + entityId) mod 4 == 0`; otherwise (resting on the ground) it does not move this tick. When it moves: `move(SELF, velocity)` then block effects (RQ-1.8).
7. Friction: `air = getAirDrag()` (**0.98**, the entity default). `f = air`; on the ground `f = air x friction of the block below`, where the block is the one returned by `ItemEntity.getBlockPosBelowThatAffectsMyMovement`, an **override that calls `getOnPos(0.999999)`** (the base `Entity` method uses 0.500001 instead; that value is for other entities, see RQ-1.9; 41 section 3, paragraph on the block below and friction). Velocity becomes `(v_x x f, v_y x air, v_z x f)`. If on the ground and `v_y < 0`, the velocity is then multiplied by `(1, -0.5, 1)` (a bounce).
8. (If it did not move, the block effects of the last movements are still applied.)
9. Merge scheduling: `interval = 2` when the item's block position (floor of x, y, z) differs from the old one, else `40`. When `tickCount mod interval == 0`, and on the server, and `isMergable`, `mergeWithNeighbours` runs.
10. Age: increment by 1 unless it is the infinite value -32768; fluid interaction may set a sync flag; the server sets the sync flag when the velocity changed by more than `0.01` squared since the tick began; the server discards the item when `age >= 6000`.

**(B)** This replaces the first-half description in 21 section 8.1 and the bounce and merge-interval sentences (see section 5, items 3 and 4).

**RQ-1.6 Merge.** `isMergable`: the stack is alive, `pickupDelay != 32767`, `age != -32768` and `age < 6000`, and the stack count is below the stack's maximum size. `mergeWithNeighbours`: if mergeable, find all other item entities in the box inflated by **(0.5, 0, 0.5)** that are mergeable; for each, in the order the level returns them, try to merge and stop when this entity is removed. `tryToMerge(other)`: both must have the same `target` (owner UUID or both none) and `areMergable(stackA, stackB)`: total count not above the item's maximum stack size, same item and same components. The receiver is chosen by comparing `other.count` with `this.count` (`tryToMerge`, read): when `other.count < this.count`, **this** entity receives and `other` is the source; otherwise (`other` is equal or larger) **the other entity receives** and this entity is the source. So on equal counts the other entity survives and this one is drained (41 section 4.4 step 2 states the same). Transfer = `min(min(maxStack, 64) - receiver.count, source.count)`; the receiver's stack grows by it, the source shrinks by it. The receiver's `pickupDelay` becomes the larger of the two and its `age` the smaller; a source whose stack is now empty is discarded. **(B)**

**RQ-1.7 Pickup, throw and pickup delays.**
- Constructor values: `age 0`, `pickupDelay 0`, `health 5`, random yaw `nextFloat x 360`, and the random motion of RQ-1.5 for the five-argument constructor. The delay is 0 at construction; callers set it (41 section 1).
- Setters: default delay = **10**; none = 0; never = 32767 (infinite); unlimited lifetime sets `age = -32768`; extended lifetime sets `age = -6000` (so it lives 12000 ticks); `makeFakeItem` = never pick up plus `age = 5999` (a display item that dies one tick later). The throw, death-drop, `popResource` and dispenser formulas are in 41 section 2, which is authoritative for the exact draw order and single-precision constants; the throw summary below agrees with it.
- Callers: the delay **10** is set by `Entity.spawnAtLocation` (all generic drops), `Block` (block drops), hanging entities, composter, beehive, shulker box, lectern, jukebox, sniffer, brain item behaviours, and `LootCommand`; the delay **0** by `GiveCommand` and advancement rewards; the delay **40** by `LivingEntity.createItemStackToDrop` (a thrown or dropped item, below); the Wither's nether star uses extended lifetime; the fox and dolphin item goals set their own delays (per-mob). **(B)**
- Throw (`createItemStackToDrop(stack, randomly, thrownFromHand)`): the position is `(x, eyeY - 0.3, z)`; the delay is 40; when `thrownFromHand` the thrower is recorded. *Random drop* (`randomly = true`, used for dying players' inventories): `f = nextFloat x 0.5`, `a = nextFloat x 2 pi`, velocity `(-sin a x f, 0.2, cos a x f)`. *Thrown from the hand*: with `p` = pitch and `y` = yaw in radians and `s = 0.3`: `cos_p = cos p`, `a = nextFloat x 2 pi`, `r = 0.02 x nextFloat`; velocity x = `-sin y x cos_p x 0.3 + cos a x r`; velocity y = `-sin p x 0.3 + 0.1 + (nextFloat - nextFloat) x 0.1`; velocity z = `cos y x cos_p x 0.3 + sin a x r`. The draw order is `a`, then `r`, then the two floats of the vertical term. **(B, `LivingEntity`)** The drop statistics (`drop`, `item_dropped`) are awarded by `ServerPlayer.drop` when the item was thrown from the hand.
- Player pickup (`playerTouch`, server only): when `pickupDelay == 0` and (`target` is none or equals the player's UUID) and `Inventory.add(stack)` accepts (fully or partially): the player takes the item (animation and sound, `Player.take(entity, count)`); if the stack is now empty the entity is discarded and the stack count is restored (`setCount`) to the original value just before that; the statistic `item_picked_up` (item) is awarded with `count`; then the pickup advancement hook runs. `count` is the stack count read into a local **before** `Inventory.add`; it is used by both `take` and `awardStat` in the full-pickup and the partial case alike, so a partial pickup reports the original count, not the number actually inserted. The count is put back on the entity only when the stack ended up empty. **(B)**
- Damage (`hurtServer`): not hurt when invulnerable to the base check; not hurt by a mob when `mob_griefing` is off; the stack must accept the damage (`canBeHurtBy`); health decreases by the damage truncated to int; at 0 the stack's `onDestroyed` runs and the entity is discarded. **(B)**

### 4.3 Fire extinguishing and block effects (RQ-1.8)

Entities that are inside a block are handled by the **inside-block effect** engine (`InsideBlockEffectApplier`, run from `Entity.applyEffectsFromBlocks` after movement, 18 section 2.6 step 10). A block, fluid or entity asks for an effect by type; the engine de-duplicates per movement step and applies them in a fixed order. **(B, `InsideBlockEffectType`, `InsideBlockEffectApplier$StepBasedCollector`)**

| Order | Effect type | What it does |
|---|---|---|
| 1 | `FREEZE` | marks the entity as in powder snow; if it can freeze, `ticksFrozen = min(ticksRequiredToFreeze, ticksFrozen + 1)` |
| 2 | `CLEAR_FREEZE` | `clearFreeze` (frozen ticks to 0) |
| 3 | `FIRE_IGNITE` | `BaseFireBlock.fireIgnite`: nothing when fire immune; otherwise, if the entity's fire ticks are negative, add 1; else if it is a server player, add a random integer from the call `nextInt(1, 3)` (origin 1, bound 3: the value is 1 or 2) to the fire ticks; then, when the fire ticks are zero or more, `igniteForSeconds(8)` |
| 4 | `LAVA_IGNITE` | `lavaIgnite`: nothing when fire immune, else `igniteForSeconds(15)` |
| 5 | `EXTINGUISH` | `clearFire` |

`igniteForSeconds(s)` = `igniteForTicks(floor(s x 20))`; `igniteForTicks(t)` sets the fire ticks to `t` when the current value is smaller, then clears freezing. `clearFire` sets the fire ticks to `min(0, current)`: a positive timer becomes 0 and the negative values that mark the post-fire grace period are kept. `extinguishFire` (the method) plays the extinguished sound only if the entity is on fire, then `clearFire`. **(B, `Entity`)**

In one movement step the collector, for each effect type in the order above, runs the effect's registered "before" callbacks, then the effect itself if it was requested, then its "after" callbacks. All callbacks run in that order after the step; a dead entity stops the list. So when one step both requests `LAVA_IGNITE` and `EXTINGUISH`, the lava ignite runs first and the extinguish last; the result is fire cleared, while the lava damage callback registered "after `LAVA_IGNITE`" still runs before the extinguish.

Which fluids and blocks request which effects (the callers of the extinguishing path): **(B)**

| Source | Requests |
|---|---|
| `WaterFluid.entityInside` | `EXTINGUISH` |
| `LavaFluid.entityInside` | `CLEAR_FREEZE`, `LAVA_IGNITE`, and an after-`LAVA_IGNITE` callback that does the lava hurt (18 section 2.5 lists the damage) |
| `LayeredCauldronBlock` (water, powder snow cauldrons) | `EXTINGUISH` (twice requested; de-duplicated) |
| `LavaCauldronBlock` | `CLEAR_FREEZE`, `LAVA_IGNITE` |
| `PowderSnowBlock` | `FREEZE`, `EXTINGUISH` |
| `BaseFireBlock` (fire, soul fire) | `CLEAR_FREEZE`, `FIRE_IGNITE` |

Direct callers outside the engine (all read): `AbstractThrownPotion` calls `extinguishFire` (the method that plays the sound) on entities near a splash of water; `AbstractArrow.tick` calls `clearFire` when the arrow `isInWaterOrRain`; `Player.die` and `ServerPlayer.die` each contain one `clearFire` call (the server player override has its own, in addition to the `Player` one). On the client `Entity.baseTick` clears the fire every tick; on the server a fire-immune entity has its fire cleared in `baseTick` (18 section 2.5). **(B)**

### 4.4 Block data used by physics and spawning (RQ-1.9 to RQ-1.12)

**RQ-1.9 Friction, speed factor, jump factor.** Every block has three floats from its properties, defaults **friction 0.6, speed factor 1.0, jump factor 1.0**. All blocks that differ in this artifact are the seven below (blocks that copy another block's properties inherit its values, and none of the copies changes these three). Block count: [24](24-block-registry-1-model-and-foundation.md) (sections 1 and 2.3) records 911 block fields in `Blocks`, of which 33 are collection fields, so 878 are single registrations. The static initialiser contains exactly 878 calls of the register family: `register` 729, `registerSlab` 60, `registerLegacyStair` 51, `registerStair` 6, `registerWall` 32. The whole-class totals (738, 62, 51, 8, 32 = 891) additionally include 9 `register`, 2 `registerSlab` and 2 `registerStair` calls inside helper or lambda bodies (13 in all), which are not initialiser registrations. The table was verified by reading the initialiser for these properties. **(C)**

| Block | Friction | Speed factor | Jump factor |
|---|---|---|---|
| `ice` | 0.98 | 1.0 | 1.0 |
| `packed_ice` | 0.98 | 1.0 | 1.0 |
| `frosted_ice` | 0.98 | 1.0 | 1.0 |
| `blue_ice` | 0.989 | 1.0 | 1.0 |
| `slime_block` | 0.8 | 1.0 | 1.0 |
| `soul_sand` | 0.6 | 0.4 | 1.0 |
| `honey_block` | 0.6 | 0.4 | 0.5 |

How they are used (all **B**):
- **Friction** multiplies the ground drag as in RQ-1.5 and 18 section 3.2. The block is `getBlockPosBelowThatAffectsMyMovement`, which is `getOnPos(offset)`: the offset is **0.999999** for item entities (their override; 41 section 3) and 0.500001 for the base `Entity` method, which `Entity.getBlockSpeedFactor` and `getBlockJumpFactor` use for non-item entities. `getOnPos(offset)`: when the offset is at most `1e-5` and a supporting block is known, that supporting block position is returned unchanged. When a supporting block is known and the offset is above `1e-5`: a block in tag `fences` is accepted (the supporting position is returned as is) only for offsets of at most 0.5, while a block in tag `walls` or a `FenceGateBlock` is accepted at **any** offset; otherwise the result is the supporting block's x and z with `y = floor(posY - offset)`. With no supporting block known, the position is `(floor(x), floor(y - offset), floor(z))`.
- **Speed factor**: `Entity.getBlockSpeedFactor` takes the factor of the block at the entity's block position; if that block is water or a bubble column the factor `f` is returned; otherwise, when `f` equals 1.0 exactly, the speed factor of the block at the "below that affects movement" position is returned, and when `f` is not 1.0 it is returned as is. `LivingEntity.getBlockSpeedFactor` lerps it by the entity's `movement_efficiency` attribute `e`: `factor = base + e x (1 - base)` (`e = 1` gives 1.0, so the attribute removes the slowdown).
- **Jump factor**: `Entity.getBlockJumpFactor` takes the jump factor of the block at the entity's block position, and when that equals 1.0 exactly it takes the factor of the block "below that affects movement" (the same rule as the speed factor without the water test); `LivingEntity.getJumpPower(m) = jump_strength x m x blockJumpFactor + jumpBoostPower` (the `m` multiplier is 1.0 by default).

**RQ-1.10 `isValidSpawn` overrides.** The per-block predicate `isValidSpawn(state, level, pos, entityType)`. The default (every block with no override, **C**) is: the block's top face is sturdy **and** its light emission is below 14. The `Blocks` class has **35** call sites of the property setter `isValidSpawn`: 31 inside the static initialiser and 4 inside property helpers (`leavesProperties` and the lambdas `lambda$static$158`, `lambda$static$393`, `lambda$static$396`). Each call passes one of five predicates (bootstrap method arguments read: `Blocks.never`, `Blocks.always`, `Blocks.ocelotOrParrot`, and two inline lambdas). The mapping below was traced call site by call site in this round. **(C)**

| Predicate | Call sites | Blocks |
|---|---|---|
| never (false for all types) | **24** | in initialiser order: `bedrock`, `glass`, `moving_piston`, then the 11 wood trapdoors `oak`, `spruce`, `birch`, `jungle`, `acacia`, `cherry`, `dark_oak`, `pale_oak`, `mangrove`, `poplar`, `bamboo` (consecutive registrations, in this order), then `barrier`, `iron_trapdoor`, `chorus_flower`, `scaffolding`, `crimson_trapdoor`, `warped_trapdoor`, `tinted_glass` (that is 21 in the initialiser); plus three helper sites: the stained-glass colour helper (`lambda$static$158`: strength 0.3, glass sound, never; it is the property function passed to the `STAINED_GLASS` colour collection, so 16 blocks share one site), the copper trapdoor helper (`lambda$static$393`, used by `WeatheringCopperTrapDoorBlock`) and the copper grate helper (`lambda$static$396`, sound `COPPER_GRATE`, used by `WaterloggedTransparentBlock`). Each copper helper builds a weathering collection of 8 blocks (4 weathering states plus 4 waxed copies; the waxed copy is **inferred**, not read) |
| only ocelot and parrot | 3 | `cherry_leaves`, `pale_oak_leaves` (inline, in the initialiser) and the shared `leavesProperties` helper, which is called 12 times (the leaves other than those two: `oak`, `spruce`, `birch`, `jungle`, `acacia`, `dark_oak`, `mangrove`, the three poplar leaves, `azalea`, `flowering_azalea`) |
| always true | 5 | `soul_sand`, `carved_pumpkin`, `jack_o_lantern`, `redstone_lamp`, `mud` |
| only `polar_bear` | 2 (two separate lambdas with the same body) | `ice`, `frosted_ice` |
| only entity types that are fire immune | 1 | `magma_block` |

Totals: 24 + 3 + 5 + 2 + 1 = 35. The 24 never sites cover 14 trapdoors (11 wood, iron, crimson, warped, listed above) plus the copper trapdoor collection, the 16 stained glass blocks, the copper grate collection and the 7 single blocks `bedrock`, `glass`, `moving_piston`, `barrier`, `scaffolding`, `chorus_flower`, `tinted_glass`. [24](24-block-registry-1-model-and-foundation.md) may record the predicate per block as well; this table is the source for the call-site split.

The predicate is used by `Mob.checkMobSpawnRules` (below); reasons that skip it are in RQ-1.18.

**RQ-1.11 Tag `valid_spawn`.** The tag exists (members `grass_block`, `podzol`, **D**) but **no class of the artifact reads it** except the tag registry that declares it; it has no effect on spawning or placement in 26.3. The tag that spawning behaviour reads is `animals_spawnable_on` (RQ-1.38), and the one that the vehicle-dismount helper reads is `invalid_spawn_inside`. **(B, search of every class for the tag constant)**

**RQ-1.12 Per-block entity effects.** The generic engine is RQ-1.8. The values 18 section 3.3 already lists for cactus, magma block, cobweb and sweet berry bush stand unchanged. Not read in this part: honey block sliding and sticking, powder snow walking, bubble columns, portals, campfire and fire damage numbers (Open question 2); parts 8 and the block-behaviour rounds own them.

### 4.5 Per-mob framework values (RQ-1.13 to RQ-1.17)

**RQ-1.13 Experience reward (`xpReward` and `getBaseExperienceReward`).** The base rule (`Mob.getBaseExperienceReward`): if `xpReward > 0`, result = `xpReward` plus, for every entry of `EquipmentSlot.VALUES` (order in RQ-1.2: mainhand, offhand, feet, legs, chest, head, body, saddle) that `canIncreaseExperience` accepts (every slot except the saddle slot, so mainhand, offhand, feet, legs, chest, head and body are eligible) whose item is non-empty and whose drop chance is at most 1.0, `1 + nextInt(3)` (one draw per qualifying slot, in that slot order); otherwise result = `xpReward`. `LivingEntity` returns 0. Overrides and the values set in code (**B**, scan of every class under `world/entity`: the 599 class and enum declarations among the 727 non-nested class files, the other 128 being interfaces, plus the 430 inner and anonymous classes, which contain no `xpReward` write and none of the overrides listed in RQ-1.13 to RQ-1.15 and RQ-1.35; the only hit is a call to `Fox.getWalkTargetValue` from a `Fox` inner goal, so the tables are complete for the entity tree):

| Class | xp |
|---|---|
| `Mob` (all not listed) | field default 0 |
| `Monster` (all monsters not listed) | 5 |
| `Animal`, `WaterAnimal`, `AgeableWaterCreature` (cows, pigs, fish, squid and so on) | `1 + nextInt(3)` (overrides the base rule, no equipment bonus) |
| `Chicken` | 10 when a chicken jockey, else the `Animal` rule |
| `Zombie` and subclasses | a baby: the field is first replaced by `(int)(xpReward x 2.5)` (so 12 from 5), then the base rule runs; an adult: the base rule. The baby branch **writes the product back into the field on every call** (5, then 12, then 30 on later calls), so a harness that calls the method twice on the same entity sees compounding; the game reads it once per death |
| `Slime`, `MagmaCube` | `xpReward = size` (set in `setSize`) |
| `SulfurCube` | baby 0, else `1 + nextInt(2)` |
| `Hoglin` | baby 3, adult 5 (set when the age boundary is reached); the reward is the field with no equipment bonus |
| `Piglin` | 5 (field, no equipment bonus); `PiglinBrute` 20 |
| `WitherBoss` | 50 |
| `Blaze`, `Guardian`, `Breeze`, `Evoker` | 10 |
| `Ghast`, `Phantom`, `Shulker`, `Zoglin`, `Illusioner`, `Warden` | 5 |
| `Endermite`, `Vex` | 3 |
| `Ravager` | 20 |
| `Creaking` | 0 |

`Player` has its own override (it depends on the `keep_inventory` rule); the Ender Dragon awards its experience in its death sequence (21 section 6.4). Other `Mob` descendants with no entry above (villagers, golems, bats, allay) have 0. Mobs that change `xpReward` only for baby or size reasons are listed in the table.

**RQ-1.14 Spawn cluster size.** `getMaxSpawnClusterSize` is the largest group a natural spawn pack may reach (18 section 6.5): `Mob` **4**; `AbstractHorse` 6; `AbstractFish` 8; `AbstractSchoolingFish` its `getMaxSchoolSize` (default the `AbstractFish` value 8; `Salmon` overrides it to **5**); `Wolf` 8; `Ghast` 1; `Pillager` 1; `HappyGhast` 1. `isMaxGroupSizeReached(size)` is false for every mob except `TropicalFish`, which returns true when it is **not** part of a school (a lone tropical fish spawns one at a time). **(B)**

**RQ-1.15 Ambient sound interval** (the `Mob.baseTick` rule is 18 section 2.4): `Mob` 80; `Animal`, `WaterAnimal`, `AgeableWaterCreature`, `AbstractGolem`, `Cat` **120**; `AbstractHorse` **400**; `Turtle` 200; `Guardian` 160; `Ocelot` **900**; `HappyGhast` = the `Animal` value (120) multiplied by **6** (720) while it is a vehicle (carries a passenger). Every other mob inherits the nearest value above. **(B)**

**RQ-1.16 Taming and trust chance.** One feeding of an accepted item: wolf, cat and nautilus tame with probability **1/3** (`nextInt(3) == 0`; on success the wolf also stops navigation, clears its target and is ordered to sit, the cat is ordered to sit, the nautilus stops navigation; Entity Event 7 hearts on success, 6 smoke on failure); parrot **1/10** (`nextInt(10) == 0`, Entity Events 7 and 6; the item is always consumed); ocelot trust (`Ocelot.mobInteract`): the branch requires the tempt goal to be absent or running, the ocelot not yet trusting, the item accepted as food and the player within squared distance 9 (`distanceToSqr < 9`); the item is consumed with `usePlayerItem`; on the server, `nextInt(3) == 0` (**1/3**) sets trusting true, spawns the trusting particles (true) and broadcasts Entity Event **41**, otherwise it spawns the trusting particles (false) and broadcasts Entity Event **40**; the result is SUCCESS. The wolf and cat events 7 (success) and 6 (failure) and the parrot's `nextInt(10)` are as stated above. Horses and donkeys use the temper system (19 section 3), not a flat chance. **(B)**

**RQ-1.17 Baby feeding speed-up.** Confirmed as written in 18 section 8.1 (`seconds = (int)((remaining ticks / 20) x 0.1f)`, age up by `seconds x 20`, clamp at 0); no per-mob override was found in the entity classes read for RQ-1.13. **(B)**

### 4.6 `EntitySpawnReason` matrix (RQ-1.18)

The 19 reasons (18 Open question 4). **Producers** (the code that passes each reason; read by scanning all classes for the constant) and **gates** (the code that tests a reason). **(B)**

**Producers.**

| Reason | Passed by |
|---|---|
| `NATURAL` | `NaturalSpawner`, `PhantomSpawner`, `CatSpawner`; also tested by `Drowned`, `Husk`, `Raider`, `ZombieHorse` finalisation |
| `CHUNK_GENERATION` | `NaturalSpawner.spawnMobsForChunkGeneration`, mineshaft corridor chest generation |
| `SPAWNER` | `BaseSpawner` (spawner block, minecart spawner), the creaking heart spawn |
| `TRIAL_SPAWNER` | `TrialSpawner` |
| `STRUCTURE` | structure templates and pieces (end city, end spike, swamp hut, ocean monument and ruins, woodland mansion), nether portal random tick, game test; also tested by `Drowned`, `Piglin`, `PatrollingMonster` |
| `BREEDING` | every `getBreedOffspring`, frogspawn, dried ghast block, shulker bullets duplicating a shulker, allay duplication; tested by `Villager` |
| `MOB_SUMMONED` | evoker vex summon spell, `Villager.spawnGolemIfNeeded` |
| `JOCKEY` | spider and skeleton jockeys, strider jockeys, zombie and drowned riders |
| `EVENT` | ender dragon fight, raids, village siege, wandering trader and its llamas, thunder skeleton trap rider; tested by `PatrollingMonster`, `TraderLlama` |
| `CONVERSION` | `Mob.convertTo` (zombie villager, husk, tadpole and the other conversions) |
| `REINFORCEMENT` | zombie reinforcements (`Zombie.hurtServer`), tested in `Drowned` spawn rules |
| `TRIGGERED` | carved pumpkin golems, copper golem statue, infested block, infested and oozing effects, shrieker warden, skeleton trap, summon effect, thrown egg and ender pearl, wither skull, cube mob splits |
| `BUCKET` | `MobBucketItem.spawn`; tested by `Axolotl` |
| `SPAWN_ITEM_USE` | spawn eggs, armour stand, boat and cushion items |
| `COMMAND` | `/summon`, `/raid` leader |
| `DISPENSER` | dispenser behaviours (spawn egg, boat, minecart) |
| `PATROL` | `PatrolSpawner`; tested by `PatrollingMonster` |
| `LOAD` | entity storage, chunk load, beehive occupants, shoulder and vehicle reload, ender pearl reload |
| `DIMENSION_TRAVEL` | `Entity.teleportCrossDimension`; tested by `Zombie.handleAttributes` |

**Which reasons run the spawn-rule gates.** Only these call `checkSpawnRules` (the per-type rule of 18 section 6.8) or `checkSpawnObstruction` (no liquid in the box, unobstructed): `NaturalSpawner` (`NATURAL`: both, via `isValidPositionForMob` and `isValidSpawnPostitionForType`), `NaturalSpawner.spawnMobsForChunkGeneration` (`CHUNK_GENERATION`), `BaseSpawner` (`SPAWNER`: both), `TrialSpawner` (`TRIAL_SPAWNER`: both), `Zombie.hurtServer` (`REINFORCEMENT`: the placement rule), and `SpawnUtil.trySpawnMob` (used by `Villager` iron golems with `MOB_SUMMONED`, the creaking heart with `SPAWNER`, the shrieker with `TRIGGERED`: both). Every other reason spawns without calling either gate (spawn eggs, commands, dispensers, breeding, buckets, conversion, structures, load, and so on).

**What a reason changes inside the gates.**
- `EntitySpawnReason.isSpawner` is true for `SPAWNER` and `TRIAL_SPAWNER`. It makes `Mob.checkMobSpawnRules` skip the block-below test (`isValidSpawn`, RQ-1.10), and it is also consulted by `BaseSpawner`, `ServerLevel` and the spawn egg item and by the per-class rules below (all read):

| Class rule | Test (a spawner reason replaces or short-cuts the extra test) |
|---|---|
| `Endermite`, `Silverfish` (`checkAnyLightMonsterSpawnRules` first) | spawner: true; otherwise no player within **5.0** blocks of the block centre (`getNearestPlayer(x+0.5, y+0.5, z+0.5, 5.0, true)` returns none) |
| `Slime` | false on Peaceful; spawner: the plain `checkMobSpawnRules`; otherwise either the surface branch (biome in tag `allows_surface_slime_spawns`, `50 < y < 70`, `nextFloat() <` the environment attribute `surface_slime_spawn_chance`, and `getMaxLocalRawBrightness <= nextInt(8)`) or the slime-chunk branch (a generator seeded by chunk x, chunk z, world seed and the constant 987234911: `nextInt(10) == 0`, and a fresh `nextInt(10) == 0`, and `y < 40`; only on a world-generation level); each then runs `checkMobSpawnRules` |
| `Guardian` | `(nextInt(20) == 0 or the position cannot see the sky from below water)` and not Peaceful and (spawner, or water at the position and water below it) |
| `Stray` | after skipping upward through powder snow blocks: the `Monster` rule and (spawner, or the position below can see the sky) |
| `SkeletonHorse` | spawner: the light test `ignoresLightRequirements or isBrightEnoughToSpawn`; otherwise `Animal.checkAnimalSpawnRules` |
| `Monster.checkSurfaceMonstersSpawnRules` | the `Monster` rule and (spawner, or the position can see the sky) |
| `Drowned` | water below the position or spawner; then (not Peaceful and (light test unless `ignoresLightRequirements`) and (spawner or water at the position)); a spawner or `REINFORCEMENT` reason then returns true; else the biome-tag branch (`nextInt(15) == 0`) or the depth branch (`nextInt(40) == 0` and deep enough) (the grouping of the final flag is read, the biome tags and depth rule are part 5 data) |
- `EntitySpawnReason.ignoresLightRequirements` is true only for `TRIAL_SPAWNER`. It skips the darkness test of `Monster.checkMonsterSpawnRules` (a `Monster` rule is `ignoresLightRequirements or isDarkEnoughToSpawn`, then `checkMobSpawnRules`), the brightness test of `Animal.checkAnimalSpawnRules`, and the light tests of `SkeletonHorse` and `Drowned` (table above). **(B)**
- `Drowned.checkDrownedSpawnRules` also treats `REINFORCEMENT` specially.

**What a reason changes inside `finalizeSpawn` and similar finishers (all read):**

| Class | Reason | Effect |
|---|---|---|
| `Axolotl` | `BUCKET` | returns early (no random variant or group handling) |
| `TraderLlama` | `EVENT` | `setAge(0)` (an adult) before the llama rules |
| `ZombieHorse` | `NATURAL` | no probability roll: a zombie is always created (`EntityType.create` with reason `JOCKEY`) and placed with `snapTo(x, y, z, yRot, 0)` at the horse's position, then finalised with `Zombie.finalizeSpawn` called with the **incoming reason (`NATURAL`, not `JOCKEY`)** and null group data; its main hand is set to `iron_spear`; then `startRiding(horse, false, false)` runs; finally the `AbstractHorse` finaliser runs for the horse. For any reason other than `NATURAL` only the `AbstractHorse` finaliser runs |
| `Villager` | `BREEDING` | the profession is reset to `none` (the village type is then chosen by `finalizeVillagerType`; whether that call is unconditional was not displayed) |
| `Raider` | `NATURAL` | a witch spawned naturally cannot join a raid (`canJoinRaid` false); every other combination can (confirmed) |
| `Piglin` | `STRUCTURE` | skips the 20 % baby roll (confirmed) |
| `Warden` | `TRIGGERED` | pose EMERGING and the `is_emerging` memory for the emerge duration |
| `Zombie.handleAttributes` | `CONVERSION`, `DIMENSION_TRAVEL`, `LOAD` | tests these three reasons (the other reasons take a different branch); the bodies of the branches were not read (Open question 4) |
| `Zombie`, `Husk`, `Drowned`, `PatrollingMonster` | `CONVERSION`, `NATURAL`, `STRUCTURE`, `EVENT`, `PATROL`, `JOCKEY` | the reasons are tested in `finalizeSpawn` (rider, patrol and conversion branches); only the tests were read; the bodies belong to part 5 |

### 4.7 Game rules (RQ-1.19)

The complete table of the 59 rules (names, categories, types, defaults, ranges) is [16](16-commands-catalog.md) section 13 and is not repeated. This answer adds the **consumers** of the mob-related rules (the classes that read each rule, found by scanning the class tree; each reading class is the place the rule's behaviour is specified):

| Rule (default) | Read by |
|---|---|
| `spawn_mobs` (true) | `NaturalSpawner`, `TrialSpawner`, `ServerChunkCache`, `ServerLevel`, create-world screen |
| `spawn_monsters` (true) | `MinecraftServer`, `ServerLevel` |
| `spawn_patrols` (true) | `PatrolSpawner` |
| `spawn_phantoms` (true) | `PhantomSpawner` |
| `spawn_wandering_traders` (true) | `WanderingTraderSpawner` |
| `spawn_wardens` (true) | `SculkShriekerBlockEntity` |
| `spawner_blocks_work` (true) | `TrialSpawner`, `ServerLevel` |
| `raids` (true) | `Raids` (and the debug classes) |
| `mob_griefing` (true) | `LivingEntity`, `Mob`, `ItemEntity`, `Projectile`, `ServerExplosion`, `ServerLevel`, `ArmorStand`, `EnderDragon`, `WitherBoss`, `LargeFireball`, `SmallFireball`, `VehicleEntity`, `BlockAttachedEntity`, `Ravager`, `Silverfish` merge and wake goals, `Enderman` take and leave goals, `Evoker` wololo goal, `SnowGolem`, `Rabbit` garden raid, `Fox` berry goal, `SulfurCube`, `Piglin`, `Allay`, `GoatAi`, `NautilusAi`, `HarvestFarmland`, `EatBlockGoal`, `RemoveBlockGoal`, `BreakDoorGoal`, `WeavingMobEffect`, `TurtleEggBlock`, `PitcherCropBlock`, `FarmlandBlock`, `CropBlock`, `PowderSnowBlock` |
| `mob_drops` (true) | `LivingEntity` (experience and loot), `EnderDragon`, `Animal`, `Monster`, `Panda`, `Turtle`, turtle and fox breed goals |
| `entity_drops` (true) | `Leashable`, `VehicleEntity`, `Cushion`, `ItemFrame`, `Painting`, `ContainerEntity`, `FallingBlockEntity`, `CopperGolem` |
| `universal_anger` (false) | `NeutralMob`, `HurtByTargetGoal`, `ResetUniversalAngerTargetGoal`, `Piglin`, `PiglinAi`, the `universal_anger` memory type |
| `forgive_dead_players` (true) | `NeutralMob`, `StopBeingAngryIfTargetDead`, `StartCelebratingIfTargetDead`, `ServerPlayer` |
| `max_entity_cramming` (24) | `LivingEntity`, `OozingMobEffect` |
| `random_tick_speed` (3) | `ServerChunkCache`, `ServerWatchdog` |
| `projectiles_can_break_blocks` (true) | `Projectile` |
| `mob_explosion_drop_decay` (true) | `ServerLevel` |
| `players_sleeping_percentage` (100) | `ServerLevel` |
| `advance_time` (true) | `ServerClockManager`, `MinecraftServer`, `ServerLevel`, create-world screen |

The rule defaults come from 16 section 13; the table above only adds where each is consumed. **(B, class constant references; D not applicable)**

### 4.8 Statistics (RQ-1.20)

The custom statistics (identifiers under `minecraft:custom`, 78 in all) are `Stats` constants; the statistic types that take an object are `block_mined`, `item_crafted`, `item_used`, `item_broken`, `item_picked_up`, `item_dropped`, `entity_killed`, `entity_killed_by`. Those used by mobs and by mob-related rules (class that awards each; `awardStat` adds 1 unless an amount is given): **(B)**

| Statistic | Awarded by and when |
|---|---|
| `time_since_rest` | `ServerPlayer.doTick`: +1 every tick while the player is **not sleeping**; reset to 0 by a successful `startSleeping` and by `die`; read by `PhantomSpawner` (20 section 12) |
| `time_since_death` | +1 every tick while alive; reset by `die` |
| `play_time`, `total_world_time`, `sneak_time` | +1 per tick (`sneak_time` only while discrete) |
| `deaths` | +1 in `die` (both `Player` and `ServerPlayer`) |
| `mob_kills`, `player_kills` | `ServerPlayer.awardKillScore(victim, source)`: `player_kills` when the victim is a `Player`, else `mob_kills` |
| `entity_killed` (type) | `Player.killedEntity`: +1 for the victim's type; `entity_killed_by` (type) in `ServerPlayer.die` for the killer's type |
| `animals_bred` | `Animal.spawnChildFromBreeding`, turtle and fox breed goals, awarded to the player that caused love |
| `talked_to_villager`, `traded_with_villager` | `Villager` and `WanderingTrader` (interaction); `MerchantResultSlot` (taking a trade result) |
| `raid_trigger`, `raid_win` | `Raid`; `raid_win` also drives an advancement trigger (`CriteriaTriggers`, `PlayerTrigger`) |
| `bell_ring` | `BellBlock` |
| `damage_dealt`, `damage_taken`, `damage_absorbed`, `damage_resisted`, `damage_blocked_by_shield` | `Player` and `LivingEntity` damage code (17 section 4) |
| `pig_one_cm`, `horse_one_cm`, `strider_one_cm`, `nautilus_one_cm`, `happy_ghast_one_cm`, `boat_one_cm`, `minecart_one_cm` | `ServerPlayer` movement statistics by the vehicle the player rides |
| `fish_caught` | `FishingHook` |
| `sleep_in_bed` | `AbstractBedBlock` |

The display formatting of each statistic (distance and time units) is client presentation and was not read (Open question 10).

### 4.9 Arthropods and Bane of Arthropods (RQ-1.21)

Entity type tag `arthropod` has members `bee`, `endermite`, `silverfish`, `spider`, `cave_spider` (**D**, `data/minecraft/tags/entity_type/arthropod.json`); tag `sensitive_to_bane_of_arthropods` has the single member `#arthropod`. **No class reads the `arthropod` tag directly**; it matters only through the enchantment's own conditions (so it needs only tag resolution, 04). The effects of Bane of Arthropods are already specified in 17 section 6 (data `enchantment/bane_of_arthropods.json`): the `damage` effect adds `2.5 + 2.5 x (level - 1)` when the victim's type is in the sensitive tag, and the `post_attack` effect applies Slowness with amplifier 3 (min and max amplifier 3) to the victim for a duration between 1.5 seconds and `1.5 + 0.5 x (level - 1)` seconds, only for a direct hit (`is_direct` true) on a sensitive victim. Cost lines: min cost `5 + 8 x (level - 1)`, max cost `25 + 8 x (level - 1)`, weight 5, max level 5, anvil cost 2. **(D)**

### 4.10 Gate behaviours (RQ-1.22)

Full semantics are in 3.4 and 3.5. Summary row: `RunOne` is `(SHUFFLED, RUN_ONE)`; `TRY_ALL` and `ORDERED` combinations occur only in the five Ai classes and the villager packages listed in 3.4. **(B)**

### 4.11 Generic behaviour internals (RQ-1.23 to RQ-1.29)

Shared helper: **ordered box scan** (`ServerLevel.findBlocksInBoxByManhattanDistance(centre, r)`): the box is `2r + 1` blocks on each axis around `centre`, enumerated in **increasing Manhattan depth** `d = 0 .. 3r` (the depth range is `r + r + r`). Within one depth `d`, `x` runs from `-min(r, d)` to `+min(r, d)`; for each `x`, `y` runs from `-min(r, d - |x|)` to `+min(r, d - |x|)`; the z offset is `z = d - |x| - |y|` and the position is produced only when `z <= r`; when `z != 0` the mirrored position at `-z` follows immediately. `findFirst` takes the first position in this order for which the predicate holds; `forEachUntil` visits in this order until told to stop. **(B, `BlockPos.manhattanOrdered`, `OrderedBlockMatcher`)** A two-radius variant `(r_h, r_v)` exists (the horizontal reach `r_h` for x and z, the vertical reach `r_v` for y; the depth limit is `r_h + r_v + r_h`), used by the hoglin repellent search.

All three finders below use a **mutable next-allowed time** `t_next` (a long starting at 0, one per behaviour instance) and the common filter "the candidate position differs from the mob's own position horizontally" (the mob's own column is excluded).

**RQ-1.23 `TryFindLand(range, speed)`** (typed on `PathfinderMob`; used by amphibians): memories: `attack_target` absent, `walk_target` absent, `look_target` registered.
1. If the mob's block is not in water: return false (does nothing).
2. If `gameTime < t_next`: set `t_next = gameTime + 60` and return true (no scan: the timer is pushed forward).
3. Else scan the ordered box of radius `range`; filter: horizontal position differs from the mob's, and the block state has **no fluid**; take the first position whose collision shape at the position is **empty** and whose block below has a **sturdy top face**.
4. If found: set `look_target` to a block tracker on it and `walk_target` to a block tracker with speed `speed` and close-enough **1**.
5. Set `t_next = gameTime + 60` and return true.

**RQ-1.23 (cont.) `TryFindLandNearLiquid(range, speed, fluidTag)`**: same memories. Returns false while the mob's block holds a fluid in the given tag. The timer is **40** (step 2 uses `+40`, step 5 uses `+40`). The scan filter is only the horizontal difference; the candidate test is: collision shape at the position **empty**, the block below has a **non-empty** collision shape, and some horizontal neighbour (iteration order of the horizontal plane) is **air** whose block below holds the given fluid (a shoreline). A found position becomes `look_target` and `walk_target` with close-enough **0** and the given speed.

**RQ-1.23 (cont.) `TryFindLiquid(range, speed, fluidTag)`**: same memories. Returns false while the mob's block holds the fluid. If `gameTime < t_next`: `t_next = gameTime + 20 + 2` and return true (the timer constants are 20, 2 and 40). Else scan: the state filter is "a liquid block whose fluid is in the tag"; the visit goes in the ordered-box order and stops at the first such position whose **block above is air**; if no such position was found it falls back to the **first** matching position that is **not within 1.5 blocks** of the mob (a position within 1.5 blocks is never chosen as the fallback). If a position was chosen, `look_target` is set to a block tracker and `walk_target` to a block tracker (the given speed, close-enough 0), both on the **chosen position itself** (the liquid block, not the block above it). The air-above block is only a test inside the scan: the first liquid candidate whose block above is air is stored and aborts the scan; until one is stored, the first candidate that is not within 1.5 blocks (`closerToCenterThan`) becomes the stored fallback, and a later air-above candidate still overrides that fallback. The candidate filter is a `LiquidBlock` whose fluid is in the tag, plus a different-horizontal-position test. Then `t_next = gameTime + 40`; return true.

**RQ-1.24 `GoToWantedItem(filter, speed, interrupt, range)`**: memories: `walk_target` registered when `interrupt` is true and absent when false; `look_target` registered; `nearest_visible_wanted_item` present; `item_pickup_cooldown_ticks` registered. Trigger: let `item` be the remembered entity; it runs only when `item_pickup_cooldown_ticks` is **absent**, `filter(mob)` holds (default: always true), the mob is closer than `range` to the item, the item's block lies inside the world border, and the mob `canPickUpLoot`. Effect: `look_target` = entity tracker on the item **with eye tracking** and `walk_target` = (entity tracker on the item, without eye tracking, `speed`, close-enough **0**). Returns true when set. **(B)**

**RQ-1.25 `CopyMemoryWithExpiry(condition, source, target, duration)`**: memories: `source` present, `target` absent. Trigger: if `condition(mob)` holds, copy the source value into the target with an expiry of one uniform-integer sample of `duration` ticks (the sample from the level random); return true. Otherwise false. **(B)**

**RQ-1.26 `Croak` (frog)**: memory `walk_target` absent; duration up to 100 ticks. Start condition: the frog's pose is STANDING. `start`: unless the frog is in liquid, set pose CROAKING and reset `croakCounter` to 0. `canStillUse`: while `croakCounter < 60`. Each tick `croakCounter++`. `stop`: pose STANDING. **(B)**

**RQ-1.27 `SetHiddenState(seconds, distance)`** (villager after a bell): with `limit = seconds x 20`; memories `hiding_place` and `heard_bell_time` present; a hidden-ticks counter starts at 0 and is per behaviour instance. Each evaluation: `bellOver = (heard_bell_time + 300 <= gameTime)`. If the counter exceeds `limit` **or** `bellOver`: erase `hiding_place` and `heard_bell_time`, refresh the activity from the schedule (`Brain.updateActivityFromSchedule` with the current environment attributes, game time and position), reset the counter to 0 and return true. Otherwise, if the hiding place block is within `distance` of the mob (`closerThan`), increment the counter. Return true. **(B)**

**RQ-1.28 `TryLaySpawnOnFluidNearLand(block)`** (frog laying): memories: `attack_target` absent, `walk_target` present, `is_pregnant` present. Trigger: the mob must be in water or on the ground, otherwise false. Let `b` = the block below the mob. For each horizontal direction in the order of the horizontal plane: the block at `b` shifted by the direction (the "neighbour") must have an **empty** top-face shape (a fluid or non-solid), and either its fluid is in tag `supports_frogspawn` or the block is in block tag `supports_frogspawn`; and the block **above** that neighbour must be air. For the **first** direction that satisfies all, place the given block (frogspawn) at the position above the neighbour (`setBlockAndUpdate`), emit the block-place game event, play `frog_lay_spawn` (blocks, volume 1, pitch 1), erase `is_pregnant`, and return true. If no direction qualifies the trigger returns true with no effect. **(B)**

**RQ-1.29 `SetWalkTargetFromBlockMemory(memory, speed, closeEnough, maxDistance, maxTicksUnreachable)`** (villager; the argument order is as in 19 section 22: for example `(home, s, 1, 150, 1200)`): memories: `cant_reach_walk_target_since` registered, `walk_target` absent, the block memory present. Let `G` be the remembered `GlobalPos`.
1. If `G`'s dimension differs from the level's, **or** `cant_reach_walk_target_since` exists and `gameTime - since > maxTicksUnreachable`: the villager releases the point of interest (`releasePoi(memory)`), erases the block memory and sets `cant_reach_walk_target_since = gameTime`; return true.
2. Else if the Manhattan distance (`distManhattan`) from `G`'s block to the villager exceeds `maxDistance`: a retry loop with counter `n` starting at 0. A candidate is `DefaultRandomPos.getPosTowards(mob, 15, 7, Vec3.atBottomCenterOf(G's block), 1.5707963)` (horizontal range 15, vertical range 7, so the target is the bottom centre of the block, not its middle). Each pass: (a) if a candidate exists from the previous pass and `BlockPos.containing(candidate).distManhattan(villager) <= maxDistance`, accept it and leave the loop; (b) otherwise generate a new candidate (it may be null), add 1 to `n`, and if `n` equals **1000** leave to the failure branch **without testing that candidate**. The candidate (null or not) is therefore tested at the top of the next pass, so 1000 candidates are generated but only the first 999 are tested; the 1000th is never used even when valid. Failure: release the POI, erase the memory, set `cant_reach_walk_target_since`, and return true. Success: set `walk_target` to the accepted position with `speed` and `closeEnough`. **(B)**
3. Else if the Manhattan distance (`distManhattan > closeEnough`) from `G`'s block to the villager exceeds `closeEnough`: set `walk_target` to `G`'s block with `speed` and `closeEnough`.
4. Return true. **(B)**

### 4.12 Generic sensors (RQ-1.30 to RQ-1.34)

**RQ-1.30 Nearest-visible family and villager sensors.** `NearestVisibleLivingEntitySensor` (base of the single-target sensors): writes one memory (named by the subclass) every scan with the **closest visible living entity** (from `nearest_visible_living_entities`, which is already distance-sorted) for which `isMatchingEntity(level, mob, entity)` holds; when none matches the memory is erased. Requires `nearest_visible_living_entities`. **(B)**

`villager_hostiles` (`VillagerHostilesSensor`): memory written `nearest_hostile`. An entity matches when its type is a key of the table below **and** it is within that type's distance (the squared distance of the mob to the entity is at most the value squared). **(C)**

| Type | Distance | Type | Distance |
|---|---|---|---|
| `drowned` | 8 | `vindicator` | 10 |
| `evoker` | 12 | `zoglin` | 10 |
| `husk` | 8 | `zombie` | 8 |
| `illusioner` | 12 | `zombie_villager` | 8 |
| `pillager` | 15 | `vex` | 8 |
| `ravager` | 12 | | |

`golem_detected` (`GolemSensor`): scan rate **200** ticks (constructor default; a second constructor takes the rate); requires `nearest_living_entities` and writes `golem_detected_recently`. If any entity in `nearest_living_entities` is an iron golem, the memory is set to true with expiry **599** ticks; otherwise nothing changes. The static helper `golemDetected` sets the same memory (also used when a golem is seen elsewhere). **(B)**

**RQ-1.31 Axolotl and frog sensors.**
- `axolotl_attackables` writes `nearest_attackable`. A visible entity matches when **all** hold: its squared distance to the axolotl is at most **64** (8 blocks); the entity is in water; its type is in tag `axolotl_always_hostiles`, **or** (the axolotl has **no** `has_hunting_cooldown` memory and the type is in tag `axolotl_hunt_targets`); and `Sensor.isEntityAttackable` passes (18 section 4.6). The sensor needs `has_hunting_cooldown` registered. **(B; tag members are D)**
- `frog_attackables` writes `nearest_attackable`. A visible entity matches when: `isEntityAttackable` passes, `Frog.canEat(entity)`, the entity's UUID is **not** in the list memory `unreachable_tongue_targets`, and it is closer than **10** blocks. Requires `unreachable_tongue_targets` registered. **(B)**

**RQ-1.32 Piglin family and hoglin sensors** (summary level; part 6 owns the full behaviour). **(B)**
- `hoglin_specific_sensor` (typed on `Hoglin`, scan rate 20): writes `nearest_repellent` = the first block in the ordered box scan `findBlocksInBoxByManhattanDistance(pos, 8, 4)` (horizontal reach 8, vertical reach 4) whose state is in block tag `hoglin_repellents`, with **no** campfire test. From the visible entities it keeps those that pass the filter **not baby and (a `Piglin` or a `Hoglin`)**, so only adults are counted; a `PiglinBrute` is not a `Piglin` instance and is not counted. Of those, the first `Piglin` is `nearest_visible_adult_piglin` and the number of `Piglin` matches is `visible_adult_piglin_count`; the `Hoglin` matches form the list `nearest_visible_adult_hoglins` and its size is `visible_adult_hoglin_count`.
- `piglin_brute_specific_sensor`: writes `nearest_visible_nemesis` = the closest visible `WitherSkeleton` or `WitherBoss` (`findClosest` over `nearest_visible_living_entities`, which the sensor requires; the memory is erased when none matches), and `nearby_adult_piglins` = `PiglinAi.findNearbyAdultPiglins(brain)`. The sensor requires and writes exactly these three memories; no other predicate is involved.
- `piglin_specific_sensor`: writes `nearest_repellent` with its own search `findNearestRepellent`: the same ordered box scan (reach 8 horizontal, 4 vertical, in the ordered order) with `isValidRepellent`: the block must be in tag `piglin_repellents`, and when it is a soul campfire it must also be lit (`CampfireBlock.isLitCampfire`). (The hoglin sensor uses tag `hoglin_repellents` and no campfire test.) From the visible entities it fills, scanning each entity once: for a `Hoglin`, a baby sets `nearest_visible_baby_hoglin` when that slot is still empty, and an adult sets `nearest_visible_huntable_hoglin` when empty and `canBeHunted`, while every adult hoglin increments the local count that becomes `visible_adult_hoglin_count`; a `PiglinBrute` is appended to the piglin list; a baby `Piglin` sets the baby-piglin slot when it is empty (the slot is a local that is not written to any memory in this sensor's final writes); an adult `Piglin` is appended to the same piglin list; a `Player` fills `nearest_targetable_player_not_wearing_gold` (the first for whom `PiglinAi.isWearingSafeArmor` is false and `canAttack` holds) and `nearest_player_holding_wanted_item` (the first non-spectator for whom `PiglinAi.isPlayerHoldingLovedItem` holds); a `WitherSkeleton` or `WitherBoss` fills `nearest_visible_nemesis`; any other entity for which `PiglinAi.isZombified` holds fills `nearest_visible_zombified`. After the loop `nearby_adult_piglins` = `PiglinAi.findNearbyAdultPiglins(brain)`, `nearest_visible_adult_piglins` = the accumulated list and `visible_adult_piglin_count` = its size. The brute add and the adult add both target one local list (the same local variable in both branches); only the baby slot is separate. So brutes count in `nearest_visible_adult_piglins` and `visible_adult_piglin_count` of this sensor, while the hoglin sensor's counts exclude them.

**RQ-1.33 Warden and breeze sensors.** Both extend `NearestLivingEntitySensor` (18 section 4.6) and run its scan first. `warden_entity_sensor` writes `nearest_attackable`: the first entity in `nearest_living_entities` (distance order) that is a **player** and passes `Warden.canTargetEntity`; if there is none, the first entity that is **not** a player and passes `canTargetEntity`; if still none, the memory is erased. `breeze_attack_entity_sensor` writes `nearest_attackable`: the first entity in `nearest_living_entities` that is not a creative or spectator player and passes `Sensor.isEntityAttackable` for the breeze; else the memory is erased. **(B)**

**RQ-1.34 Armadillo scare sensor and predicate.** `SensorType.ARMADILLO_SCARE_DETECTED` (`armadillo_scare_detected`) is a generic `MobSensor<Armadillo>` built in the `SensorType` initialiser with scan rate **5** ticks, mob test `Armadillo.isScaredBy` (a (mob, other) test), ready test `Armadillo.canStayRolledUp`, memory `danger_detected_recently` (Boolean) and expiry **80** ticks (all read, including the pairing of the two predicates from the bootstrap method arguments). It requires `nearest_living_entities`. Each scan: if the ready test fails the memory is erased; otherwise, if any entity of `nearest_living_entities` passes the mob test, the memory is set to true with the expiry; otherwise nothing changes. The predicate (`Armadillo.isScaredBy(entity)`): false unless the entity's box intersects the armadillo's box inflated by **(7, 2, 7)**; true for any entity in tag `undead`; true when the entity is the armadillo's last attacker; for a player: false when a spectator, true when sprinting or when a passenger; false for anything else. **(B)**

**RQ-1.30 (cont.) Remaining generic sensors.** The sensor type registry (`SensorType`) also registers the sensors below, none of which is answered elsewhere. **(B)**

| Sensor (registry name) | Rate | Requires and writes | Rule |
|---|---|---|---|
| `dummy` | default 20 | requires nothing | its tick does nothing; a placeholder for brains that need a registered sensor with no effect |
| `villager_babies` | default 20 | writes `visible_villager_babies` | the list of entities of `nearest_visible_living_entities` (empty when that memory is absent) whose type is `villager` and that are babies; the list is stored every scan, possibly empty |
| `hurt_by` | default 20 | requires and writes `hurt_by` and `hurt_by_entity` | if the mob has a last damage source: store it in `hurt_by` and, when the source has an entity that is a living entity, store that entity in `hurt_by_entity`; if there is no last damage source, erase `hurt_by`. Afterwards, if `hurt_by_entity` holds an entity that is dead or is in a different level from the mob, erase `hurt_by_entity` |
| `nearest_items` | default 20 | writes `nearest_visible_wanted_item` | collects `ItemEntity` instances in the mob's box inflated by (32, 16, 32), sorts them by squared distance to the mob, then takes the first one that passes `Mob.wantsToPickUp(level, stack)`, is closer than 32 blocks (`closerThan(mob, 32)`) and passes `LivingEntity.hasLineOfSight`; the memory is set to that entity or to nothing |
| `nearest_bed` | 20 | writes `nearest_bed` | acts only for **baby** mobs. Each scan resets a try counter to 0 and sets its `lastUpdate` to `gameTime + nextInt(20)`; it asks the point-of-interest manager for every `home` point within **48** blocks (any occupancy), skipping positions in a cache that remembers a position for 40 ticks and allowing at most **5** new positions per scan, finds a path to those points (`AcquirePoi.findPathToPois`), and when a reachable path exists and its target is a registered point of interest, writes the target position to `nearest_bed`; otherwise, while fewer than 5 positions were tried, expired cache entries (value below `lastUpdate`) are removed (the cache bookkeeping is **inferred** from the constants 40 and 5 and the cache calls) |
| `secondary_pois` | 40 | requires and writes `secondary_job_site` | villager only: scans the box of offsets x in [-4, 4], y in [-2, 2], z in [-4, 4] around the villager (the loop order is x outermost, z innermost); every block whose block is in the villager's current profession `secondaryPoi` set adds a `GlobalPos` (dimension plus position) to a list; the memory is set to the list when it is non-empty and erased otherwise. The per-profession block sets are data of part 3 |

### 4.13 `getWalkTargetValue` (RQ-1.35)

`PathfinderMob.getWalkTargetValue(pos, level)` scores a candidate stroll position (higher is preferred by the random-position helpers of 18 section 4.2). The default is **0**. Overrides (all read): **(B)**

| Class | Value |
|---|---|
| `Animal` | **10** when the block below is `grass_block`; else the light cost |
| `MushroomCow` | **10** when the block below is `mycelium`; else the light cost |
| `Turtle` | 10 when not heading home and the fluid at the position is water; else 10 when the position is on sand (`TurtleEggBlock.onSand`); else the light cost |
| `Bee` | 10 when the block at the position is air; else 0 |
| `HappyGhast` | 0 unless the position is empty; if empty, 10 when the block below is empty and two below is not empty (a drop of exactly two blocks to the ground); else 5 |
| `Hoglin` | -1 when `HoglinAi.isPosNearNearestRepellent(hoglin, pos)`; else 10 when the block below is `crimson_nylium`; else 0. `isPosNearNearestRepellent` is true when the hoglin's `nearest_repellent` memory is present and that block position is `closerThan` the candidate position with distance argument **8.0** (`Vec3i.closerThan(v, r)` is `distSqr(v) < r squared` with a **strict** less-than, so the test is true when the squared distance from the remembered repellent to the candidate position is below **64**) |
| `Strider` | 10 when the position holds lava; else minus infinity when the strider is in lava; else 0 |
| `Monster` | minus the light cost |
| `Giant` | the light cost |
| `Silverfish` | 10 when the block below is a compatible infested host block; else the `Monster` value |
| `Guardian` | when the position is water: 10 plus the light cost; else the `Monster` value |
| `AbstractNautilus`, `Axolotl`, `Enderman`, `Pillager`, `Creaking`, `Warden` | 0 |

The **light cost** is `lightLevelDependentMagicValue(pos) - 0.5` (`LevelReader.getPathfindingCostFromLightLevels`), where with `r = getMaxLocalRawBrightness(pos) / 15` and `v = r / (4 - 3r)` the magic value is `lerp(dimensionAmbientLight, v, 1)` = `v + ambient x (1 - v)`. In the Overworld ambient light is 0, so the cost runs from -0.5 (raw brightness 0) to +0.5 (raw brightness 15). `ambientLight` is a dimension type field (data, 04).

### 4.14 Pointers (RQ-1.36 to RQ-1.40)

| Id | Item | Answer |
|---|---|---|
| RQ-1.36 | 18 OQ 1 | attachments: part 8 (boats, rafts, chest boats) and part 4 (camel); player and mannequin attachments are part 8 |
| RQ-1.37 | 21 OQ 8 (squid xp) | squids derive from `AgeableWaterCreature`: `1 + nextInt(3)` (RQ-1.13); dolphin the same via `WaterAnimal`/`Animal` families; breeding food: part 7 |
| RQ-1.38 | 21 OQ 6 (`Animal` spawn rule) | `Animal.checkAnimalSpawnRules(type, level, reason, pos, rand)`: `lightOk = ignoresLightRequirements(reason) or isBrightEnoughToSpawn(level, pos)`; the rule holds when the block below is in tag `animals_spawnable_on` **and** `lightOk`. (`isBrightEnoughToSpawn` is the light test of 18 section 6.8.) **(B)** |
| RQ-1.39 | 18 OQ 8 | closed by 17 section 6; no new reading |
| RQ-1.40 | 18 OQ 12 | projectile entities: part 8 |

### 4.15 Answer rows (schema of 1.2)

| Id | Source doc | Item | Answer | Evidence | Replaces |
|---|---|---|---|---|---|
| RQ-1.1 | 18 | OQ 5 | tier table, six tiers incl. copper, slot order head, chest, legs, feet (4.1) | B, C, `Mob.getEquipmentForSlot` | 18 s7.1.2 last sentence: replace; delete OQ 5 |
| RQ-1.2 | 18 | OQ 5, 15 | `mob_spawn_equipment` by-cost-with-difficulty engine, cost 5 to 22, pool tag, `upgrade` (4.1) | B, D, `EnchantmentHelper`, `EnchantmentsByCostWithDifficulty` | 18 s7.1.2 "Enchantments" paragraph: append; delete OQ 5 and 15 |
| RQ-1.3 | 18 | OQ 5 | `canReplaceCurrentItem`, `compareArmor`, `compareWeapons`, `getApproximateAttributeWith`, `canReplaceEqualItem` (4.1) | B, `Mob`, `ItemAttributeModifiers` | 18 s7.2: replace the first paragraph |
| RQ-1.4 | 18 | OQ 5 | worked example E1 to E3 | B | 18 s10 or s7: append |
| RQ-1.5 | 18 | OQ 6 | item entity motion order, fluids, friction, bounce (4.2) | B, `ItemEntity.tick` | 21 s8.1: replace first half; 18 s6.11: item bullet |
| RQ-1.6 | 18 | OQ 6 | merge conditions, receiver (other receives unless `other.count < this.count`), transfer, pickup delay and age combination (4.2; 41 authoritative) | B, `ItemEntity.tryToMerge` | 21 s8.1 merge sentences: replace; delete 18 OQ 6 |
| RQ-1.7 | 21 | OQ 13 | pickup, throw and drop delays by caller; throw and random-drop velocity; player pickup; damage (4.2) | B, `LivingEntity`, `ItemEntity`, `ServerPlayer` | 21 s8.1 last sentence: replace; delete part of 21 OQ 13 |
| RQ-1.8 | 18 | OQ 7 | inside-block effect engine, fire constants, who requests `EXTINGUISH` (4.3) | B, `InsideBlockEffect*` | 18 s2.5: append; delete OQ 7 |
| RQ-1.9 | 18 | OQ 9 | friction, speed and jump factors table and use; register-call count reconciled (4.4) | C, B, `Blocks`, `Entity` | 18 s3.3 bullet "Block speed factor": replace |
| RQ-1.10 | 18 | OQ 9 | `isValidSpawn` default and the 35 override call sites, traced per block (4.4) | C, `Blocks`, `BlockBehaviour$Properties` | 18 s6.8 "any light" bullet: append |
| RQ-1.11 | 18, 19 | OQ 9; 19 OQ 4 | tag `valid_spawn` has no readers (4.4) | B, D | 19 OQ 4: replace |
| RQ-1.12 | 18 | OQ 9 | per-block entity effects: engine given, block list partly open (4.4) | B | 18 s3.3 last bullet: append |
| RQ-1.13 | 18 | OQ 10 | experience rewards lookup (4.5) | B, scan of entity classes | 18 s7.5 dropExperience: append |
| RQ-1.14 | 18 | OQ 10 | spawn cluster sizes and group-size rule (4.5) | B | 18 s6.5: append |
| RQ-1.15 | 18 | OQ 10 | ambient sound intervals (4.5) | B | 18 s2.4: replace last sentence |
| RQ-1.16 | 18 | OQ 10 | taming chances, ocelot trust 1/3 with events 41 and 40 (4.5) | B | 18 s8.2 last sentence: replace; 19 OQ 12, 13, 23 partly |
| RQ-1.17 | 18 | OQ 10 | feeding speed-up confirmed (4.5) | B | none |
| RQ-1.18 | 18 | OQ 11 | `EntitySpawnReason` producers, gates and effects (4.6) | B | 18 s6.12: append; delete OQ 11 |
| RQ-1.19 | 18 | OQ 13 | game-rule consumers over 16 s13 (4.7) | B, D | 18 OQ 13: replace with a pointer |
| RQ-1.20 | 18 | OQ 14 | statistics used by mobs (4.8) | B | 18 OQ 14: replace with a pointer |
| RQ-1.21 | 18 | OQ 16 | arthropod tag, bane effects (4.9) | D, B | 18 OQ 16: delete; 17 s6 unchanged |
| RQ-1.22 | 18 | OQ 18 | gate and trigger-gate semantics, combinations in use (3.4, 3.5) | B | 18 s4.6 "GateBehavior / RunOne" sentence: replace; delete OQ 18 |
| RQ-1.23 | 18 | OQ 19 | `TryFindLand`, `TryFindLandNearLiquid`, `TryFindLiquid`: scan order, timers, target (4.11) | B | 18 s4.7 rows: replace; delete part of OQ 19 |
| RQ-1.24 | 18 | OQ 19 | `GoToWantedItem` (4.11) | B | 18 s4.7 row: replace |
| RQ-1.25 | 18 | OQ 19 | `CopyMemoryWithExpiry` (4.11) | B | 18 s4.7 row: replace |
| RQ-1.26 | 18, 19 | OQ 19; 19 OQ 17 | `Croak` (4.11) | B | 18 s4.7 row: replace |
| RQ-1.27 | 18 | OQ 3, 19 | `SetHiddenState` (4.11) | B | 18 s4.7 row: replace |
| RQ-1.28 | 18 | OQ 3 | `TryLaySpawnOnFluidNearLand` (4.11) | B | 18 s4.7 row: replace |
| RQ-1.29 | 18 | OQ 3 | `SetWalkTargetFromBlockMemory` (4.11) | B | 18 s4.7 row: replace |
| RQ-1.30 | 18 | OQ 3 | `nearest-visible` family, `villager_hostiles`, `golem_detected`, and the remaining sensors `dummy`, `villager_babies`, `hurt_by`, `nearest_items`, `nearest_bed`, `secondary_pois` (4.12) | B, C | 18 s4.6 "remaining sensors": shorten |
| RQ-1.31 | 18 | OQ 3 | `axolotl_attackables`, `frog_attackables` (4.12) | B | same |
| RQ-1.32 | 18 | OQ 3 | piglin, piglin brute, hoglin sensors (4.12) | B | same; part 6 completes |
| RQ-1.33 | 18 | OQ 3 | `warden_entity_sensor`, `breeze_attack_entity_sensor` (4.12) | B | same |
| RQ-1.34 | 18, 19 | OQ 3; 19 OQ 19 | armadillo scare sensor (rate 5, expiry 80, ready test `canStayRolledUp`) and predicate (4.12) | B | same |
| RQ-1.35 | 18 | OQ 2 | `getWalkTargetValue` overrides and the light cost (4.13) | B | 18 OQ 2: replace; 18 s4.2 random-position helpers: cite |
| RQ-1.36 | 18 | OQ 1 | pointer to part 8 | n/a | none |
| RQ-1.37 | 21 | OQ 8 | squid experience (4.14) | B | 21 OQ 8: partial |
| RQ-1.38 | 21 | OQ 6 | `Animal.checkAnimalSpawnRules` (4.14) | B | 21 OQ 6: partial; 18 s6.8: append |
| RQ-1.39 | 18 | OQ 8 | closed by 17 | n/a | none |
| RQ-1.40 | 18 | OQ 12 | pointer to part 8 | n/a | none |

---

## 5. Corrections to documents 18 to 21 (fold-in notes)

These are the places where this reading differs from what the older documents say, or where an older sentence is superseded. The documents are not edited in RS26; the editors of the next edit round apply these.

| # | Document and section | Older text | Corrected text (this document) |
|---|---|---|---|
| 1 | 18 section 7.2, `canReplaceCurrentItem` | weapons are compared by "the sum of attack damage attribute modifiers plus a 1.0 bonus"; armour by "armor value, toughness, then durability" | RQ-1.3: weapons by the preferred-weapon tag rule, then the approximated attack damage (base plus modifiers by operation), then the tie-break; armour by armour, toughness, then the tie-break (enchantment count, damage value, custom name) |
| 2 | 18 section 7.1.2, 7.1.2 closing sentence about the tier table | "not tabulated, Open question 5" | RQ-1.1: the table, with the copper tier; and the mob_spawn_equipment provider is RQ-1.2 |
| 3 | 21 section 8.1 and 18 section 6.11 | merge "every 40 ticks"; default pickup delay 10 | RQ-1.5, RQ-1.7: merge interval is 2 ticks when the item changed block this tick, else 40; the constructor delay is 0, 10 is applied by callers, thrown items 40; the friction block of an item is looked up at offset 0.999999 (41 section 3); on a merge the other entity receives unless `other.count < this.count` (RQ-1.6) |
| 4 | 21 section 8.1 | "on the ground with downward velocity the Y velocity is multiplied by -0.5" and friction "velocity scaled (f, drag, f)" | both confirmed; RQ-1.5 gives the full order and the block-friction lookup |
| 5 | 19 Open question 4 | `valid_spawn` listed as needed for spawn rules | RQ-1.11: no class reads that tag; the block predicate `isValidSpawn` (RQ-1.10) is what the rules use |
| 6 | 18 section 4.7 behaviour table rows for `TryFindLand`, `TryFindLandNearLiquid`, `TryFindLiquid` | "finds the nearest block within `range` (Manhattan, closest first)" | RQ-1.23: the scan covers the whole box of side `2r + 1`, enumerated by increasing Manhattan depth; the timers and the not-yet-expired branch (the timer is pushed forward, no scan) are specified |
| 7 | 18 section 4.7 row for `TryFindLiquid` | timer "re-armed with 40 when it finds nothing and 2 when it starts moving" | RQ-1.23: while the timer has not expired the behaviour sets the timer to `now + 22` and does nothing; after a scan the timer is `now + 40`; a fallback position not within 1.5 blocks is used when no position has air above |
| 8 | 18 Open question 11 | "not consolidated" | RQ-1.18 |
| 9 | 18 section 4.7, `SetHiddenState` row | "more than 300 ticks since the bell it leaves hiding" | RQ-1.27: also leaves when the hidden-ticks counter exceeds `seconds x 20`; the counter counts only evaluations in which the hiding place is within `distance` |
| 10 | 18 section 8.2, taming chance "per-mob" | | RQ-1.16 |
| 11 | 18 section 4.5, "Brain tick" paragraph | "(1) `tickSensors` ... (2) the schedule ... " | 3.3: `Brain.tick` runs `forgetOutdatedMemories`, `tickSensors`, `startEachNonRunningBehavior`, `tickEachRunningBehavior`; there is no schedule step in it, the schedule is refreshed by the mob or by the `UpdateActivityFromSchedule` and `SetHiddenState` behaviours |

---

## 6. Worked examples

**E1 Default equipment (RQ-1.1, 18 section 7.1.2).** Per-slot stop chance 0.25 (Normal) and `special = 1.0` (effective local difficulty above 4; the special multiplier is 0 below 2, 1 above 4 and `(d - 2) / 2` between, 4.1 RQ-1.2 and 18 section 7.1.3, and it does not follow from the difficulty setting alone). Fixture draws in order: roll 0.10 (< 0.15, armour is added); `nextInt(3)` = 1 (tier 1); three tier rolls 0.05 (< 0.1087, tier 2), 0.50 (no), 0.09 (tier 3). Per-slot stop chance on Normal is 0.25. Slots in order head, chest, legs, feet. Head: first slot, always considered, empty: tier 3 head item = `chainmail_helmet`. Chest: stop roll 0.60 (>= 0.25, continue), empty: `chainmail_chestplate`. Legs: stop roll 0.20 (< 0.25): stop. Result: chainmail helmet and chainmail chestplate; legs and feet stay empty.

**E2 Enchanting spawn equipment (RQ-1.2).** `special = 0.5`. The chestplate slot base chance is 0.5, so the threshold is 0.25. Draw 0.30: not enchanted. Draw 0.20: enchanted. Cost = random between 5 and `5 + (int)(0.5 x 17)` = `5 + 8` = 13 inclusive, for example 9. The selection then adds `1 + nextInt(N/4+1) + nextInt(N/4+1)` where `N` is the chestplate's `enchantable` value (17 gives the item values), applies the 0.15 spread and picks by weight as in 17 section 6.5. With `special = 0` the cost is always 5; with `special = 1` it is 5 to 22.

**E3 Armour replacement (RQ-1.3).** Mob has an iron helmet with armour approximated 2 (base 0 plus modifier 2). Candidate: a chainmail helmet with armour 2 and toughness 0, current toughness 0. Armour equal, toughness equal: tie-break. Candidate has 1 enchantment, current has 0: candidate wins. If both have 0 enchantments and damage values 40 and 10: current wins (a more worn candidate loses). If the current helmet has Curse of Binding (`prevent_armor_change`): no replacement regardless.

**E4 Gate (3.4, 3.5).** A `RunOne` gate with children A (w 2), B (w 1), both STOPPED. Draws `r_A = 0.25`, `r_B = 0.60`: order B, A. B's `tryStart` fails (its memory condition is not met), A's succeeds: A runs, B stays STOPPED. Next Brain tick the gate is RUNNING, only A ticks; when A stops, no child is RUNNING and the gate stops. Next tick it can pick again. With `(ORDERED, TRY_ALL)` and the same children both would be tried in the given order and both could run together.

**E5 Ordered box scan (4.11).** Radius 1 around origin. Depth 0: (0,0,0). Depth 1, in order: (-1,0,0); then x = 0: y = -1 gives z = 0: (0,-1,0); y = 0 gives z = 1: (0,0,1) then its mirror (0,0,-1); y = 1 gives (0,1,0); then (1,0,0). So the first candidate for `TryFindLand` with a one-block range, after the mob's own column is excluded, is (-1,0,0) when it qualifies.

**E6 Item merge (RQ-1.6).** Two stacks of the same item and components, 40 and 30, maximum 64. Whichever entity runs `tryToMerge` first, the 40-stack ends up the receiver (if the 40-stack entity runs it, `other.count` 30 is less than its 40, so it receives; if the 30-stack entity runs it, `other.count` 40 is not less than 30, so the other entity receives). With two equal stacks (say 20 and 20) the entity that does **not** run `tryToMerge` receives. Transfer = `min(64 - 40, 30)` = 24: receiver 64, source 6. Receiver's pickup delay = the larger of the two, age = the smaller. The source remains (6 items). If the stacks were 40 and 24: transfer 24, source 0 and discarded.

**E7 Thrown item velocity (RQ-1.7).** Player at yaw 0, pitch 0 (looking along +z in the artifact's convention), draws `a = 0` (so `cos a = 1`, `sin a = 0`), `r = 0.02 x 0.5 = 0.01`, the two floats 0.7 and 0.2. Velocity x = `-sin(0) x 1 x 0.3 + 1 x 0.01` = 0.01; y = `0 + 0.1 + (0.7 - 0.2) x 0.1` = 0.15; z = `cos(0) x 1 x 0.3 + 0` = 0.3. Pickup delay 40; spawned at eye height minus 0.3.

**E8 Item friction on ice (RQ-1.5, RQ-1.9).** An item resting on `blue_ice` (the friction block is looked up at offset 0.999999, RQ-1.5) with horizontal velocity 0.1 on a tick it moves: `f = 0.98 x 0.989 = 0.96922`; new horizontal velocity 0.096922; vertical velocity x 0.98 (and, if it was moving down onto the ground, then x -0.5). On normal blocks `f = 0.98 x 0.6 = 0.588`.

**E9 Inside-block ordering (4.3).** An entity whose box overlaps a lava block and a water block in one movement step requests `LAVA_IGNITE` (from the lava) and `EXTINGUISH` (from the water). The collector runs `LAVA_IGNITE` (fire ticks become 300 when they were lower, then the lava hurt callback queued after it) and then `EXTINGUISH`, which sets the fire ticks to `min(0, 300)` = 0.

**E10 Experience (RQ-1.13).** A baby zombie with an iron helmet (drop chance 0.085): `xpReward` becomes `(int)(5 x 2.5)` = 12; the base rule adds `1 + nextInt(3)` for the helmet: 13 to 15. A slime of size 4: 4 (plus nothing, it has no equipment). A cow: `1 + nextInt(3)` = 1 to 3.

**E11 Walk-target scoring (RQ-1.35).** Overworld, a cow: a grass position scores 10; a stone position with raw brightness 15 scores 0.5; raw brightness 0 scores -0.5. The same two non-grass positions score -0.5 and +0.5 for a zombie (the `Monster` value is the negated light cost).

**E12 Statistics (RQ-1.20).** A player is awake for 24000 ticks: `time_since_rest` = 24000; sleeping through a night resets it to 0 on `startSleeping`, and while sleeping it does not grow. A phantom spawn test reads it (20 section 12).

**E13 Villager home walk (RQ-1.29).** `(home, 0.5s, closeEnough 1, maxDistance 150, maxTicks 1200)`. Villager 200 blocks (Manhattan) from home with the walk target absent: 1000 candidates are generated, the first 999 are tested against `maxDistance` 150, and the first one that passes becomes the walk target. Villager 5 blocks away: the target is the home block itself (distance above `closeEnough` 1). Villager unable to reach for 1300 ticks: the home memory is erased, the bed point of interest released, `cant_reach_walk_target_since` set to now.

---

## 7. Validation

**What was read directly and how.** Class listings and bytecode: `Brain` (tick and its four steps), `GateBehavior`, `GateBehavior$OrderPolicy`, `GateBehavior$RunningPolicy` and its two constants, `RunOne`, `TriggerGate`, `ShufflingList` and its weighted entry; `TryFindLand`, `TryFindLandNearLiquid`, `TryFindLiquid`, `GoToWantedItem`, `CopyMemoryWithExpiry`, `Croak`, `SetHiddenState`, `TryLaySpawnOnFluidNearLand`, `SetWalkTargetFromBlockMemory`; `BlockPos` ordered iteration, `OrderedBlockMatcher`, `LevelReader` finders, `Vec3i.closerThan`; `Mob` equipment code and `EQUIPMENT_POPULATION_ORDER`, `EquipmentSlot` (enum order, `VALUES`, `canIncreaseExperience`), `DifficultyInstance.getSpecialMultiplier`, `EnchantmentHelper`, `WeightedRandom`, `EnchantmentsByCostWithDifficulty`, `ItemAttributeModifiers.compute`; `ItemEntity`, `LivingEntity.createItemStackToDrop`, `ServerPlayer.drop`; `Entity` fire, speed and jump code; `InsideBlockEffectType`, `InsideBlockEffectApplier$StepBasedCollector`, the fluid and block `entityInside` code; the `Blocks` class (35 `isValidSpawn` call sites traced, 878 register-family calls in the static initialiser), `Entity.getOnPos`, `getBlockSpeedFactor`, `getBlockJumpFactor`, `ItemEntity.tryToMerge` and `playerTouch`, `Ocelot.mobInteract`, the sensors listed in 4.12, `MobSensor` and the `SensorType` bootstrap arguments, `WitherSkeleton`, `Piglin` and the other preferred-weapon overrides, `Zombie.getBaseExperienceReward`, `HoglinAi.isPosNearNearestRepellent`, `ZombieHorse.finalizeSpawn`, `BlockBehaviour$Properties` defaults; `EntitySpawnReason` and every class that passes or tests it (150 class files contain the name), including the per-class rules of 4.6; `Mob`, `Animal`, `Monster` spawn rules; the sensing package; every class under `world/entity` (599 class and enum declarations, 128 interfaces and 430 inner and anonymous classes) scanned for experience, cluster size, ambient interval and walk-target overrides; `GameRules` consumers and `Stats` consumers by constant reference; data: `enchantment_provider/mob_spawn_equipment.json`, tags `enchantment/on_mob_spawn_equipment`, `non_treasure`, `entity_type/arthropod`, `sensitive_to_bane_of_arthropods`, `block/valid_spawn`, `enchantment/bane_of_arthropods.json`.

**Cross-checks done.** The tier switch was read as constants (24 item constants plus null default). Slot-to-item mapping by item name is consistent in all four slots. The merge, throw and friction values were read as constants; friction values were cross-read in the `Blocks` initialiser for all five blocks and the two speed-factor blocks. The `RunOne` constructor was read to confirm `(SHUFFLED, RUN_ONE)`. The ordered scan was read from the iterator class and its three call forms (`findBlocksInBoxByManhattanDistance(pos, r)` calls the three-reach form with `(r, r, r)`). The register-family counts (878 in the static initialiser, 13 in helpers) agree with 911 fields minus 33 collection fields.

**Tests an implementer can write from this document.**
1. Equipment roll fixture E1 and the tier table (RQ-1.1): 6 tiers x 4 slots = 24 items.
2. Enchant cost range: for `special` in {0, 0.5, 1}: cost range {5..5, 5..13, 5..22}; enchant roll order feet, legs, chest, head.
3. `compareArmor` and `compareWeapons` decision tables with the tie-break chain (RQ-1.3).
4. Gate tests: shuffle key formula (E4), `RUN_ONE` versus `TRY_ALL`, the stop-when-no-child-running rule, erase-on-exit memories; Brain tick order (3.3).
5. Ordered scan enumeration of radius 1 and radius 2 (the number of positions in a radius-`r` cube is `(2r + 1)^3` and the order is non-decreasing in `|dx| + |dy| + |dz|`).
6. Item entity: friction, bounce, fluid factors, merge interval 2 versus 40, merge transfer arithmetic, throw velocity formula with fixture draws, pickup delay table by caller.
7. Inside-block ordering test (RQ-1.8).
8. Spawn gates: for each reason in RQ-1.18, whether `checkSpawnRules` is consulted and which of block, light tests are skipped; the per-class spawner tests of 4.6.
9. Experience reward table with equipment bonus; cluster size and ambient interval lookups.
10. Sensor tests: `villager_hostiles` distance table, `golem_detected` expiry 599, axolotl and frog predicates, `villager_babies`, `hurt_by`.
11. `SetWalkTargetFromBlockMemory` retry loop: 1000 candidates generated, 999 tested (RQ-1.29).

**Remaining uncertainty markers in this document.** **(inferred)** appears only for the waxed copper copies in RQ-1.10 and for the cache bookkeeping of `nearest_bed` in RQ-1.30. There are **no** "(recalled, not verified)" marks.

---

## Open questions

Numbers are stable; entries marked "Closed" record where the answer now is.

1. Closed: `EQUIPMENT_POPULATION_ORDER` is `List.of(HEAD, CHEST, LEGS, FEET)` (RQ-1.1).
2. **Per-block entity effects beyond the engine.** Honey block sliding and sticking, powder snow walking and its leather boots rule, bubble columns, portals, campfire and fire damage constants, and the soul-sand valley interactions were not read here; the jump-factor and speed-factor lookups they need are given in RQ-1.9. Owned by the block-behaviour rounds and part 8.
3. Closed: no inner or anonymous class under `world/entity` overrides the experience, cluster size, school size, ambient interval or walk-target value (RQ-1.13).
4. **`finalizeSpawn` branches.** The `ZombieHorse` natural branch is closed (4.6). Still open: the `Zombie.handleAttributes` bonus rolls for fresh spawns and the patrol-leader rules of `PatrollingMonster` were read only at the reason-test level (part 5 owns them).
5. Closed: the retry loop of `SetWalkTargetFromBlockMemory` is read (RQ-1.29).
6. **Entity ids.** 19 Open question 31 and 20 Open question 25 (ids by registration order against a captured registry sync) cannot be answered from the artifact by static reading; [46](46-registry-ids.md) section 11 verifies the entity type ids against 21 section 2 (161 entries, zero differences) and is the reference. 19's and 20's own per-mob id lists were not compared here.
7. **Block blast resistance** (20 Open question 27) is block registry data; deferred to the block registry round (GAP-1; see 24).
8. Closed: block registration count (RQ-1.9: 878 in the static initialiser).
9. Closed: `isValidSpawn` per-block mapping (RQ-1.10). The only inferred part is that the waxed copper copies share their unwaxed helper.
10. **Statistic display units.** `StatFormatter` choices (ticks, centimetres, hearts) were not read.
11. **Game rule consumers are class-level.** The table of 4.7 lists reading classes only, not the test each class performs; those tests are in the mob documents or later rounds. Searched: every class referencing the rule constants.
12. **Item entity helpers.** `moveTowardsClosestSpace` and `applyEffectsFromBlocks` internals were not expanded here (the latter is 4.3); 41 Open question 4 covers the former.
13. Closed: `WeightedRandom.getRandomItem` and `EnchantmentHelper.selectEnchantment` were read (RQ-1.2).
14. Closed: `Vec3i.closerThan` is strict (RQ-1.35).
15. **Per-mob goal speeds.** The finding that 18 lists per-mob goal speeds as open is not answered by this part: the speed modifiers of each mob's goals belong to the per-mob parts (4 to 9); this part reads only the generic behaviours and sensors.
16. **Per-class spawn rules not expanded.** The `Slime` and `Drowned` rules in 4.6 give the branch structure; the biome tags, the `surface_slime_spawn_chance` attribute values and the depth helpers are data or part 5.
17. **`nearest_bed` cache bookkeeping (inferred).** The constants 40 (cache lifetime) and 5 (positions per scan) and the cache calls were read; the exact filter lambda that records a position and the expiry removal were not expanded line by line. Searched: `NearestBedSensor` and its three lambdas.
