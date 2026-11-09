# Aquatic, Nether and End mobs, bosses, and the entity cross-check

| Item | Value |
|---|---|
| Covers | Aquatic mobs (fish, squids, dolphin, axolotl, guardians, nautilus family); Nether mobs (ghast, blaze, magma cube, wither skeleton, piglin family with sensors, hoglin, zoglin, strider, zombified piglin); End mobs (shulker and its bullet); the Ender Dragon fight (phases, flight graph, crystals, pillars, respawn, rewards); the Wither; boss bars; bat, happy ghast, eye of ender, thrown experience bottle, llama spit, leash knot, cushion, mannequin, ominous item spawner; a cross-check table giving every one of the 161 entity types in the registry exactly one owner; compact behaviour of the non-mob entities that no other document covers |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap`) and of the JSON data inside the jar (`data/minecraft/loot_table`, `worldgen/biome`, `worldgen/structure`, `dimension_type`, `tags`), with no execution. Every value was read in this round; values that were not read are marked "(recalled, not verified)" or "(inferred)" and are listed in the Open questions. |
| Status | Written by the reader for the gameplay story "all the standard mobs exist and have their standard behavior" in `tickets/CC-0001-client-polish.md` |

Class names in backticks (for example `Guardian`, `EnderDragonPhaseManager`) say where a fact was read. They are
not the design. "18 framework: <topic>" means the shared mob framework document `18-mob-framework.md` (entity model,
attributes, goal and target selectors, Brain, pathfinding, natural spawning, loot, damage and death); this document
gives per-mob parameters and does not repeat the framework.

## Contents

1. [Conventions and cross-references](#1-conventions-and-cross-references)
2. [All entity types: cross-check table](#2-all-entity-types-cross-check-table)
3. [Shared data: spawn placement, biome spawn tables, structure overrides, tags, metadata base](#3-shared-data)
4. [Aquatic mobs](#4-aquatic-mobs)
5. [Nether mobs](#5-nether-mobs)
6. [End mobs and the Ender Dragon fight](#6-end-mobs-and-the-ender-dragon-fight)
7. [The Wither, boss bars and the Nether Star](#7-the-wither-boss-bars-and-the-nether-star)
8. [Non-mob entities](#8-non-mob-entities)
9. [Worked examples](#9-worked-examples)
10. [Validation](#10-validation)
11. [Open questions](#11-open-questions)

## 1. Conventions and cross-references

- Tick = 1/20 s. Distances are blocks. "x" in a group size such as `x1-3` is the inclusive random group size.
- "18 framework: X" is a cross-reference. Terms used without explanation here and defined there: attribute base
  values of a plain Mob (`Mob.createMobAttributes`), the Monster base attributes (`Monster.createMonsterAttributes`),
  the Animal base attributes (`Animal.createAnimalAttributes`), goal priorities and flags, `HurtByTargetGoal`,
  `NearestAttackableTargetGoal(type, interval, mustSee, mustReach, selector)` argument order, `MeleeAttackGoal`,
  `PanicGoal`, `AvoidEntityGoal`, `RandomStrollGoal`, move controls, Brain activities and memory modules, the
  difficulty and looting rules of loot, XP orb awarding, persistence and despawning, the natural spawner loop.
- Tables of "goals" list `priority: Goal(arguments)`. Lower priority numbers run first. Target goals are in a
  separate selector and are labelled "target".
- Entity metadata indexes (00 §13) continue from fixed bases: every entity has indexes 0 to 7 (flags, air, custom name,
  name visible, silent, no gravity, pose, ticks frozen); every living entity adds 8 to 14 (living flags, health,
  effect particles, effect ambience, arrow count, stinger count, sleeping position); every Mob adds index 15 (mob flags
  byte). Mob-specific indexes therefore start at 16 (read with a script that walks the superclass chain in
  declaration order). For non-living entities the subclass indexes start at 8. Ageable mobs add 16 = baby (Boolean)
  and 17 = age locked (Boolean), so their own fields start at 18. Fish add 16 = from bucket.
- Status events (`ClientboundEntityEventPacket`, 05a 0x22) are given per mob as "event N". Game events are
  `ClientboundGameEventPacket` (05a 0x27); the ones used here are 9 (puffer fish sting, value 0) and 10 (guardian elder
  effect, value 1).
- Ownership of the other entities is given in the §2 "Coverage" column with real section numbers: 17 (tools, weapons and
  combat: arrows, trident, thrown snowball, egg, ender pearl, potions, wind charge, fishing bobber), 18 (framework),
  19 (land friendly and neutral mobs), 20 (Overworld hostile mobs, including drowned, endermite, sulfur cube and vex).
  This document does not repeat those mobs.
- Recall policy: nothing here is taken from memory of other versions. Where a value was not read it is marked.

## 2. All entity types: cross-check table

The registry has 161 entity types (ids 0 to 160 in `EntityTypes` static initializer order; 04 §5.1: a static registry's numeric id is its registration index, which is the id used in Add Entity, 05a 0x01). Columns: `Size` is the builder `sized(width, height)`;
`Eye` is the builder `eyeHeight` when set (otherwise `0.85 x height`, `EntityDimensions.defaultEyeHeight`); `Track range`
is `clientTrackingRange` (default 5 when the builder does not set it); `Update interval` is `updateInterval` (default 3
when not set); `Builder flags` are the other builder calls: `noLootTable`, `fireImmune`, `noSave`, `noSummon`,
`notInPeaceful` (monsters that disappear in peaceful), `dontTrackDeltas`, `noUpdateInterval`, `canSpawnFarFromPlayer`,
`immuneTo` (block tag), `passengerAttachments`, `ridingOffset`, `spawnDimensionsScale`. "Class" is the implementing
class in the artifact. Rows with size `0 x 0`, `1 x 1` or "see §8" are entities whose real size is dynamic or
data-driven (displays, interaction, marker, lightning, fireballs) or a fixed constant read from the builder.

Coverage codes: "21 full" = a section of this document specifies the mob; "21 §n" = the section of this document that
specifies it; "21 §8 (constants and metadata only)" = only the constants and metadata that were read are given;
"17", "19", "20" = the document that owns it (with the section where the owner gave one); "13 (players)" = the
player document. Every one of the 161 entity types has exactly one row below.

| Id | Key | Class | Category | Size (w x h) | Eye | Track range | Update interval | Builder flags | Coverage |
|---|---|---|---|---|---|---|---|---|---|
| 0 | `acacia_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 1 | `acacia_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 2 | `allay` | Allay | CREATURE | 0.35 x 0.6 | 0.36 | 8 | 2 | ridingOffset | 19 |
| 3 | `area_effect_cloud` | AreaEffectCloud | MISC | 6.0 x 0.5 | 0.85 x height | 10 | 3 (default) | noLootTable,fireImmune,noUpdateInterval | 21 §8 (read) |
| 4 | `armadillo` | Armadillo | CREATURE | 0.7 x 0.65 | 0.26 | 10 | 3 (default) | - | 19 |
| 5 | `armor_stand` | ArmorStand | MISC | 0.5 x 1.975 | 1.7775 | 10 | 3 (default) | - | 21 §8 (constants and metadata only; behaviour not read) |
| 6 | `arrow` | Arrow | MISC | 0.5 x 0.5 | 0.13 | 4 | 20 | noLootTable | 17 |
| 7 | `axolotl` | Axolotl | AXOLOTLS | 0.75 x 0.42 | 0.2751 | 10 | 3 (default) | - | 21 full (§4-§7) |
| 8 | `bamboo_chest_raft` | ChestRaft | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 9 | `bamboo_raft` | Raft | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 10 | `bat` | Bat | AMBIENT | 0.5 x 0.9 | 0.45 | 5 | 3 (default) | dontTrackDeltas | 21 §8.10 |
| 11 | `bee` | Bee | CREATURE | 0.55 x 0.5 | 0.3 | 8 | 3 (default) | - | 19 |
| 12 | `birch_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 13 | `birch_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 14 | `blaze` | Blaze | MONSTER | 0.6 x 1.8 | 0.85 x height | 8 | 3 (default) | fireImmune,notInPeaceful | 21 full (§4-§7) |
| 15 | `block_display` | Display.BlockDisplay | MISC | 0 x 0 | 0.85 x height | 10 | 1 | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 16 | `bogged` | Bogged | MONSTER | 0.6 x 1.99 | 1.74 | 8 | 3 (default) | ridingOffset,notInPeaceful | 20 |
| 17 | `breeze` | Breeze | MONSTER | 0.6 x 1.77 | 1.3452 | 10 | 3 (default) | notInPeaceful | 20 |
| 18 | `breeze_wind_charge` | BreezeWindCharge | MISC | 0.3125 x 0.3125 | 0 | 4 | 10 | noLootTable | 20 (fired by the breeze); base projectile 17 §3.15; explosion parameters 21 §8.18 |
| 19 | `camel` | Camel | CREATURE | 1.7 x 2.375 | 2.275 | 10 | 3 (default) | - | 19 |
| 20 | `camel_husk` | CamelHusk | MONSTER | 1.7 x 2.375 | 2.275 | 10 | 3 (default) | - | 19 §3.8 |
| 21 | `cat` | Cat | CREATURE | 0.6 x 0.7 | 0.35 | 8 | 3 (default) | passengerAttachments | 19 |
| 22 | `cave_spider` | CaveSpider | MONSTER | 0.7 x 0.5 | 0.45 | 8 | 3 (default) | notInPeaceful | 20 |
| 23 | `cherry_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 24 | `cherry_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 25 | `chest_minecart` | MinecartChest | MISC | 0.98 x 0.7 | 0.85 x height | 8 | 3 (default) | noLootTable,passengerAttachments | 21 §8 (constants and metadata only; behaviour not read) |
| 26 | `chicken` | Chicken | CREATURE | 0.4 x 0.7 | 0.644 | 10 | 3 (default) | passengerAttachments | 19 |
| 27 | `cod` | Cod | WATER_AMBIENT | 0.5 x 0.3 | 0.195 | 4 | 3 (default) | - | 21 full (§4-§7) |
| 28 | `copper_golem` | CopperGolem | MISC | 0.49 x 0.98 | 0.8125 | 10 | 3 (default) | - | 19 §21 |
| 29 | `command_block_minecart` | MinecartCommandBlock | MISC | 0.98 x 0.7 | 0.85 x height | 8 | 3 (default) | noLootTable,passengerAttachments | 21 §8 (constants and metadata only; behaviour not read) |
| 30 | `cow` | Cow | CREATURE | 0.9 x 1.4 | 1.3 | 10 | 3 (default) | passengerAttachments | 19 |
| 31 | `creaking` | Creaking | MONSTER | 0.9 x 2.7 | 2.3 | 8 | 3 (default) | notInPeaceful | 20 |
| 32 | `creeper` | Creeper | MONSTER | 0.6 x 1.7 | 0.85 x height | 8 | 3 (default) | notInPeaceful | 20 |
| 33 | `cushion` | Cushion | MISC | 1 x 0.25 | 0.85 x height | 10 | 2147483647 | noLootTable,dontTrackDeltas | 21 §8.16 |
| 34 | `dark_oak_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 35 | `dark_oak_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 36 | `dolphin` | Dolphin | WATER_CREATURE | 0.9 x 0.6 | 0.3 | 5 (default) | 3 (default) | - | 21 full (§4-§7) |
| 37 | `donkey` | Donkey | CREATURE | 1.3964844 x 1.5 | 1.425 | 10 | 3 (default) | passengerAttachments | 19 |
| 38 | `dragon_fireball` | DragonFireball | MISC | 1 x 1 | 0.85 x height | 4 | 10 | noLootTable | 21 §8 (read) |
| 39 | `drowned` | Drowned | MONSTER | 0.6 x 1.95 | 1.74 | 8 | 3 (default) | passengerAttachments,ridingOffset,notInPeaceful | 20 §4.5 |
| 40 | `egg` | ThrownEgg | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 10 | noLootTable | 17 |
| 41 | `elder_guardian` | ElderGuardian | MONSTER | 1.9975 x 1.9975 | 0.99875 | 10 | 3 (default) | passengerAttachments,notInPeaceful | 21 full (§4-§7) |
| 42 | `enderman` | Enderman | MONSTER | 0.6 x 2.9 | 2.55 | 8 | 3 (default) | passengerAttachments,notInPeaceful | 20 |
| 43 | `endermite` | Endermite | MONSTER | 0.4 x 0.3 | 0.13 | 8 | 3 (default) | passengerAttachments,notInPeaceful | 20 |
| 44 | `ender_dragon` | EnderDragon | MONSTER | 16.0 x 8.0 | 0.85 x height | 10 | 3 (default) | fireImmune,passengerAttachments | 21 full (§4-§7) |
| 45 | `ender_pearl` | ThrownEnderpearl | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 10 | noLootTable | 17 |
| 46 | `end_crystal` | EndCrystal | MISC | 2 x 2 | 0.85 x height | 16 | 3 (default) | noLootTable,fireImmune,noUpdateInterval,dontTrackDeltas | 21 §8 (read) |
| 47 | `evoker` | Evoker | MONSTER | 0.6 x 1.95 | 0.85 x height | 8 | 3 (default) | passengerAttachments,ridingOffset,notInPeaceful | 20 |
| 48 | `evoker_fangs` | EvokerFangs | MISC | 0.5 x 0.8 | 0.85 x height | 6 | 2 | noLootTable,dontTrackDeltas | 20 |
| 49 | `experience_bottle` | ThrownExperienceBottle | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 10 | noLootTable | 21 §8.13 |
| 50 | `experience_orb` | ExperienceOrb | MISC | 0.5 x 0.5 | 0.85 x height | 6 | 20 | noLootTable | 21 §8 (read) |
| 51 | `eye_of_ender` | EyeOfEnder | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 4 | noLootTable | 21 §8.12 |
| 52 | `falling_block` | FallingBlockEntity | MISC | 0.98 x 0.98 | 0.85 x height | 10 | 20 | noLootTable | 21 §8 (read) |
| 53 | `fireball` | LargeFireball | MISC | 1 x 1 | 0.85 x height | 4 | 10 | noLootTable | 21 §8 (read) |
| 54 | `firework_rocket` | FireworkRocketEntity | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 10 | noLootTable | 21 §8 (read) |
| 55 | `fox` | Fox | CREATURE | 0.6 x 0.7 | 0.4 | 8 | 3 (default) | passengerAttachments,immuneTo | 19 |
| 56 | `frog` | Frog | CREATURE | 0.5 x 0.5 | 0.85 x height | 10 | 3 (default) | passengerAttachments | 19 |
| 57 | `furnace_minecart` | MinecartFurnace | MISC | 0.98 x 0.7 | 0.85 x height | 8 | 3 (default) | noLootTable,passengerAttachments | 21 §8 (constants and metadata only; behaviour not read) |
| 58 | `ghast` | Ghast | MONSTER | 4.0 x 4.0 | 2.6 | 10 | 3 (default) | fireImmune,passengerAttachments,ridingOffset,notInPeaceful | 21 full (§4-§7) |
| 59 | `happy_ghast` | HappyGhast | CREATURE | 4.0 x 4.0 | 2.6 | 10 | 3 (default) | passengerAttachments,ridingOffset | 21 §8.11 |
| 60 | `giant` | Giant | MONSTER | 3.6 x 12.0 | 10.44 | 10 | 3 (default) | ridingOffset,notInPeaceful | 20 |
| 61 | `glow_item_frame` | GlowItemFrame | MISC | 0.5 x 0.5 | 0 | 10 | 3 (default) | noLootTable,noUpdateInterval,dontTrackDeltas | 21 §8 (constants and metadata only; behaviour not read) |
| 62 | `glow_squid` | GlowSquid | UNDERGROUND_WATER_CREATURE | 0.8 x 0.8 | 0.4 | 10 | 3 (default) | - | 21 full (§4-§7) |
| 63 | `goat` | Goat | CREATURE | 0.9 x 1.3 | 0.85 x height | 10 | 3 (default) | passengerAttachments | 19 |
| 64 | `guardian` | Guardian | MONSTER | 0.85 x 0.85 | 0.425 | 8 | 3 (default) | passengerAttachments,notInPeaceful | 21 full (§4-§7) |
| 65 | `hoglin` | Hoglin | MONSTER | 1.3964844 x 1.4 | 0.85 x height | 8 | 3 (default) | passengerAttachments,notInPeaceful | 21 full (§4-§7) |
| 66 | `hopper_minecart` | MinecartHopper | MISC | 0.98 x 0.7 | 0.85 x height | 8 | 3 (default) | noLootTable,passengerAttachments | 21 §8 (constants and metadata only; behaviour not read) |
| 67 | `horse` | Horse | CREATURE | 1.3964844 x 1.6 | 1.52 | 10 | 3 (default) | passengerAttachments | 19 |
| 68 | `husk` | Husk | MONSTER | 0.6 x 1.95 | 1.74 | 8 | 3 (default) | passengerAttachments,ridingOffset,notInPeaceful | 20 |
| 69 | `illusioner` | Illusioner | MONSTER | 0.6 x 1.95 | 0.85 x height | 8 | 3 (default) | passengerAttachments,ridingOffset,notInPeaceful | 20 |
| 70 | `interaction` | Interaction | MISC | 0 x 0 | 0.85 x height | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 71 | `iron_golem` | IronGolem | MISC | 1.4 x 2.7 | 0.85 x height | 10 | 3 (default) | - | 19 |
| 72 | `item` | ItemEntity | MISC | 0.25 x 0.25 | 0.2125 | 6 | 20 | noLootTable | 21 §8 (read) |
| 73 | `item_display` | Display.ItemDisplay | MISC | 0 x 0 | 0.85 x height | 10 | 1 | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 74 | `item_frame` | ItemFrame | MISC | 0.5 x 0.5 | 0 | 10 | 3 (default) | noLootTable,noUpdateInterval,dontTrackDeltas | 21 §8 (constants and metadata only; behaviour not read) |
| 75 | `jungle_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 76 | `jungle_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 77 | `leash_knot` | LeashFenceKnotEntity | MISC | 0.375 x 0.5 | 0.0625 | 10 | 3 (default) | noLootTable,noSave,noUpdateInterval,dontTrackDeltas | 21 §8.15 |
| 78 | `lightning_bolt` | LightningBolt | MISC | 0 x 0 | 0.85 x height | 16 | 3 (default) | noLootTable,noSave,noUpdateInterval | 21 §8 (read) |
| 79 | `llama` | Llama | CREATURE | 0.9 x 1.87 | 1.7765 | 10 | 3 (default) | passengerAttachments | 19 |
| 80 | `llama_spit` | LlamaSpit | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 10 | noLootTable,dontTrackDeltas | 21 §8.14 |
| 81 | `magma_cube` | MagmaCube | MONSTER | 0.52 x 0.52 | 0.325 | 8 | 3 (default) | fireImmune,spawnDimensionsScale,notInPeaceful | 21 full (§4-§7) |
| 82 | `mangrove_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 83 | `mangrove_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 84 | `mannequin` | Mannequin | MISC | 0.6 x 1.8 | 1.62 | 32 | 2 | vehicleAttachment | 21 §8.16 |
| 85 | `marker` | Marker | MISC | 0 x 0 | 0.85 x height | 0 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 86 | `minecart` | Minecart | MISC | 0.98 x 0.7 | 0.85 x height | 8 | 3 (default) | noLootTable,passengerAttachments | 21 §8 (constants and metadata only; behaviour not read) |
| 87 | `mooshroom` | MushroomCow | CREATURE | 0.9 x 1.4 | 1.3 | 10 | 3 (default) | passengerAttachments | 19 |
| 88 | `mule` | Mule | CREATURE | 1.3964844 x 1.6 | 1.52 | 8 | 3 (default) | passengerAttachments | 19 |
| 89 | `nautilus` | Nautilus | WATER_CREATURE | 0.875 x 0.95 | 0.2751 | 10 | 3 (default) | passengerAttachments | 21 full (§4-§7) |
| 90 | `oak_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 91 | `oak_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 92 | `ocelot` | Ocelot | CREATURE | 0.6 x 0.7 | 0.85 x height | 10 | 3 (default) | passengerAttachments | 19 |
| 93 | `ominous_item_spawner` | OminousItemSpawner | MISC | 0.25 x 0.25 | 0.85 x height | 8 | 3 (default) | noLootTable | 21 §8.17 |
| 94 | `painting` | Painting | MISC | 0.5 x 0.5 | 0.85 x height | 10 | 3 (default) | noLootTable,noUpdateInterval,dontTrackDeltas | 21 §8 (constants and metadata only; behaviour not read) |
| 95 | `pale_oak_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 96 | `pale_oak_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 97 | `panda` | Panda | CREATURE | 1.3 x 1.25 | 0.85 x height | 10 | 3 (default) | - | 19 |
| 98 | `parched` | Parched | MONSTER | 0.6 x 1.99 | 1.74 | 8 | 3 (default) | ridingOffset,notInPeaceful | 20 |
| 99 | `parrot` | Parrot | CREATURE | 0.5 x 0.9 | 0.54 | 8 | 3 (default) | passengerAttachments | 19 |
| 100 | `phantom` | Phantom | MONSTER | 0.9 x 0.5 | 0.175 | 8 | 3 (default) | passengerAttachments,ridingOffset,notInPeaceful | 20 |
| 101 | `pig` | Pig | CREATURE | 0.9 x 0.9 | 0.85 x height | 10 | 3 (default) | passengerAttachments | 19 |
| 102 | `piglin` | Piglin | MONSTER | 0.6 x 1.95 | 1.79 | 8 | 3 (default) | passengerAttachments,ridingOffset | 21 full (§4-§7) |
| 103 | `piglin_brute` | PiglinBrute | MONSTER | 0.6 x 1.95 | 1.79 | 8 | 3 (default) | passengerAttachments,ridingOffset,notInPeaceful | 21 full (§4-§7) |
| 104 | `pillager` | Pillager | MONSTER | 0.6 x 1.95 | 0.85 x height | 8 | 3 (default) | canSpawnFarFromPlayer,passengerAttachments,ridingOffset,notInPeaceful | 20 |
| 105 | `polar_bear` | PolarBear | CREATURE | 1.4 x 1.4 | 0.85 x height | 10 | 3 (default) | immuneTo | 19 |
| 106 | `poplar_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 107 | `poplar_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 108 | `splash_potion` | ThrownSplashPotion | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 10 | noLootTable | 17 |
| 109 | `lingering_potion` | ThrownLingeringPotion | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 10 | noLootTable | 17 |
| 110 | `pufferfish` | Pufferfish | WATER_AMBIENT | 0.7 x 0.7 | 0.455 | 4 | 3 (default) | - | 21 full (§4-§7) |
| 111 | `rabbit` | Rabbit | CREATURE | 0.49 x 0.6 | 0.59 | 8 | 3 (default) | - | 19 |
| 112 | `ravager` | Ravager | MONSTER | 1.95 x 2.2 | 0.85 x height | 10 | 3 (default) | passengerAttachments,notInPeaceful | 20 |
| 113 | `salmon` | Salmon | WATER_AMBIENT | 0.7 x 0.4 | 0.26 | 4 | 3 (default) | - | 21 full (§4-§7) |
| 114 | `sheep` | Sheep | CREATURE | 0.9 x 1.3 | 1.235 | 10 | 3 (default) | passengerAttachments | 19 |
| 115 | `shulker` | Shulker | MONSTER | 1 x 1 | 0.5 | 10 | 3 (default) | fireImmune,canSpawnFarFromPlayer | 21 full (§4-§7) |
| 116 | `shulker_bullet` | ShulkerBullet | MISC | 0.3125 x 0.3125 | 0.85 x height | 8 | 3 (default) | noLootTable | 21 §8 (read) |
| 117 | `silverfish` | Silverfish | MONSTER | 0.4 x 0.3 | 0.13 | 8 | 3 (default) | passengerAttachments,notInPeaceful | 20 |
| 118 | `skeleton` | Skeleton | MONSTER | 0.6 x 1.99 | 1.74 | 8 | 3 (default) | ridingOffset,notInPeaceful | 20 |
| 119 | `skeleton_horse` | SkeletonHorse | CREATURE | 1.3964844 x 1.6 | 1.52 | 10 | 3 (default) | passengerAttachments | 19 |
| 120 | `slime` | Slime | MONSTER | 0.52 x 0.52 | 0.325 | 10 | 3 (default) | spawnDimensionsScale,notInPeaceful | 20 |
| 121 | `small_fireball` | SmallFireball | MISC | 0.3125 x 0.3125 | 0.85 x height | 4 | 10 | noLootTable | 21 §8 (read) |
| 122 | `sniffer` | Sniffer | CREATURE | 1.9 x 1.75 | 1.05 | 10 | 3 (default) | passengerAttachments,nameTagOffset | 19 |
| 123 | `snowball` | Snowball | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 10 | noLootTable | 17 |
| 124 | `snow_golem` | SnowGolem | MISC | 0.7 x 1.9 | 1.7 | 8 | 3 (default) | immuneTo | 19 |
| 125 | `spawner_minecart` | MinecartSpawner | MISC | 0.98 x 0.7 | 0.85 x height | 8 | 3 (default) | noLootTable,passengerAttachments | 21 §8 (constants and metadata only; behaviour not read) |
| 126 | `spectral_arrow` | SpectralArrow | MISC | 0.5 x 0.5 | 0.13 | 4 | 20 | noLootTable | 17 |
| 127 | `spider` | Spider | MONSTER | 1.4 x 0.9 | 0.65 | 8 | 3 (default) | passengerAttachments,notInPeaceful | 20 |
| 128 | `spruce_boat` | Boat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 129 | `spruce_chest_boat` | ChestBoat | MISC | 1.375 x 0.5625 | 0.5625 | 10 | 3 (default) | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 130 | `squid` | Squid | WATER_CREATURE | 0.8 x 0.8 | 0.4 | 8 | 3 (default) | - | 21 full (§4-§7) |
| 131 | `stray` | Stray | MONSTER | 0.6 x 1.99 | 1.74 | 8 | 3 (default) | ridingOffset,immuneTo,notInPeaceful | 20 |
| 132 | `strider` | Strider | CREATURE | 0.9 x 1.7 | 0.85 x height | 10 | 3 (default) | fireImmune | 21 full (§4-§7) |
| 133 | `sulfur_cube` | SulfurCube | MONSTER | 0.49 x 0.49 | 0.175 | 10 | 3 (default) | spawnDimensionsScale | 20 §18.2 |
| 134 | `tadpole` | Tadpole | CREATURE | 0.4 x 0.3 | 0.19500001 | 10 | 3 (default) | - | 19 |
| 135 | `text_display` | Display.TextDisplay | MISC | 0 x 0 | 0.85 x height | 10 | 1 | noLootTable | 21 §8 (constants and metadata only; behaviour not read) |
| 136 | `tnt` | PrimedTnt | MISC | 0.98 x 0.98 | 0.15 | 10 | 10 | noLootTable,fireImmune | 21 §8 (read) |
| 137 | `tnt_minecart` | MinecartTNT | MISC | 0.98 x 0.7 | 0.85 x height | 8 | 3 (default) | noLootTable,passengerAttachments | 21 §8 (constants and metadata only; behaviour not read) |
| 138 | `trader_llama` | TraderLlama | CREATURE | 0.9 x 1.87 | 1.7765 | 10 | 3 (default) | passengerAttachments | 19 |
| 139 | `trident` | ThrownTrident | MISC | 0.5 x 0.5 | 0.13 | 4 | 20 | noLootTable | 17 |
| 140 | `tropical_fish` | TropicalFish | WATER_AMBIENT | 0.5 x 0.4 | 0.26 | 4 | 3 (default) | - | 21 full (§4-§7) |
| 141 | `turtle` | Turtle | CREATURE | 1.2 x 0.4 | 0.85 x height | 10 | 3 (default) | passengerAttachments | 19 §12 |
| 142 | `vex` | Vex | MONSTER | 0.4 x 0.8 | 0.51875 | 8 | 3 (default) | fireImmune,passengerAttachments,ridingOffset,notInPeaceful | 20 §13.4 |
| 143 | `villager` | Villager | MISC | 0.6 x 1.95 | 1.62 | 10 | 3 (default) | - | 19 |
| 144 | `vindicator` | Vindicator | MONSTER | 0.6 x 1.95 | 0.85 x height | 8 | 3 (default) | passengerAttachments,ridingOffset,notInPeaceful | 20 |
| 145 | `wandering_trader` | WanderingTrader | CREATURE | 0.6 x 1.95 | 1.62 | 10 | 3 (default) | - | 19 |
| 146 | `warden` | Warden | MONSTER | 0.9 x 2.9 | 0.85 x height | 16 | 3 (default) | passengerAttachments,attach,fireImmune,notInPeaceful | 20 |
| 147 | `wind_charge` | WindCharge | MISC | 0.3125 x 0.3125 | 0 | 4 | 10 | noLootTable | 17 |
| 148 | `witch` | Witch | MONSTER | 0.6 x 1.95 | 1.62 | 8 | 3 (default) | passengerAttachments,notInPeaceful | 20 |
| 149 | `wither` | WitherBoss | MONSTER | 0.9 x 3.5 | 0.85 x height | 10 | 3 (default) | fireImmune,immuneTo,notInPeaceful,dontTrackDeltas | 21 full (§4-§7) |
| 150 | `wither_skeleton` | WitherSkeleton | MONSTER | 0.7 x 2.4 | 2.1 | 8 | 3 (default) | fireImmune,immuneTo,ridingOffset,notInPeaceful | 21 full (§4-§7) |
| 151 | `wither_skull` | WitherSkull | MISC | 0.3125 x 0.3125 | 0.85 x height | 4 | 10 | noLootTable | 21 §8 (read) |
| 152 | `wolf` | Wolf | CREATURE | 0.6 x 0.85 | 0.68 | 10 | 3 (default) | passengerAttachments | 19 |
| 153 | `zoglin` | Zoglin | MONSTER | 1.3964844 x 1.4 | 0.85 x height | 8 | 3 (default) | fireImmune,passengerAttachments,notInPeaceful | 21 full (§4-§7) |
| 154 | `zombie` | Zombie | MONSTER | 0.6 x 1.95 | 1.74 | 8 | 3 (default) | passengerAttachments,ridingOffset,notInPeaceful | 20 |
| 155 | `zombie_horse` | ZombieHorse | MONSTER | 1.3964844 x 1.6 | 1.52 | 10 | 3 (default) | passengerAttachments | 19 §3.6 |
| 156 | `zombie_nautilus` | ZombieNautilus | MONSTER | 0.875 x 0.95 | 0.2751 | 10 | 3 (default) | passengerAttachments | 21 full (§4-§7) |
| 157 | `zombie_villager` | ZombieVillager | MONSTER | 0.6 x 1.95 | 1.74 | 8 | 3 (default) | passengerAttachments,ridingOffset,notInPeaceful | 20 |
| 158 | `zombified_piglin` | ZombifiedPiglin | MONSTER | 0.6 x 1.95 | 1.79 | 8 | 3 (default) | fireImmune,passengerAttachments,ridingOffset,notInPeaceful | 21 full (§4-§7) |
| 159 | `player` | Player | MISC | 0.6 x 1.8 | 1.62 | 32 | 2 | createNothing,noSave,noSummon,vehicleAttachment,dontTrackDeltas | 13 (players) |
| 160 | `fishing_bobber` | FishingHook | MISC | 0.25 x 0.25 | 0.85 x height | 4 | 5 | noLootTable,noSave,noSummon | 17 |

## 3. Shared data

### 3.1 Spawn placement of the mobs in this document

Registered in `SpawnPlacements` (one row per entity; the placement type is where the mob may be put, the heightmap is
the surface used when choosing the Y of a spawn column, the predicate is the extra rule). The shared predicates are
read in §3.2. 18 framework: natural spawning describes the spawner loop that calls them.

| Entity | Placement type | Heightmap | Predicate (class.method) |
|---|---|---|---|
| `axolotl` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `animal/axolotl/Axolotl.checkAxolotlSpawnRules` |
| `cod` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `animal/fish/WaterAnimal.checkSurfaceWaterAnimalSpawnRules` |
| `dolphin` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `animal/AgeableWaterCreature.checkSurfaceAgeableWaterCreatureSpawnRules` |
| `drowned` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `monster/zombie/Drowned.checkDrownedSpawnRules` |
| `guardian` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `monster/Guardian.checkGuardianSpawnRules` |
| `pufferfish` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `animal/fish/WaterAnimal.checkSurfaceWaterAnimalSpawnRules` |
| `salmon` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `animal/fish/WaterAnimal.checkSurfaceWaterAnimalSpawnRules` |
| `squid` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `animal/AgeableWaterCreature.checkSurfaceAgeableWaterCreatureSpawnRules` |
| `tropical_fish` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `animal/fish/TropicalFish.checkTropicalFishSpawnRules` |
| `blaze` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/Monster.checkAnyLightMonsterSpawnRules` |
| `breeze` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/Monster.checkAnyLightMonsterSpawnRules` |
| `endermite` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/Endermite.checkEndermiteSpawnRules` |
| `ender_dragon` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Mob.checkMobSpawnRules` |
| `ghast` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/Ghast.checkGhastSpawnRules` |
| `glow_squid` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `animal/squid/GlowSquid.checkGlowSquidSpawnRules` |
| `magma_cube` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/cubemob/MagmaCube.checkMagmaCubeSpawnRules` |
| `sulfur_cube` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/cubemob/SulfurCube.checkSulfurCubeSpawnRules` |
| `nautilus` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `animal/nautilus/AbstractNautilus.checkNautilusSpawnRules` |
| `hoglin` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/hoglin/Hoglin.checkHoglinSpawnRules` |
| `piglin` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/piglin/Piglin.checkPiglinSpawnRules` |
| `skeleton` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/Monster.checkMonsterSpawnRules` |
| `strider` | IN_LAVA | MOTION_BLOCKING_NO_LEAVES | `monster/Strider.checkStriderSpawnRules` |
| `turtle` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `animal/turtle/Turtle.checkTurtleSpawnRules` |
| `wither` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/Monster.checkMonsterSpawnRules` |
| `wither_skeleton` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/Monster.checkMonsterSpawnRules` |
| `zoglin` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/Monster.checkAnyLightMonsterSpawnRules` |
| `zombified_piglin` | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `monster/zombie/ZombifiedPiglin.checkZombifiedPiglinSpawnRules` |
| `elder_guardian` | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `monster/Guardian.checkGuardianSpawnRules` |
| `shulker` | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Mob.checkMobSpawnRules` |

### 3.2 The shared spawn predicates (read)

| Predicate | Rule |
|---|---|
| `Mob.checkMobSpawnRules` | The block under the spawn position must accept the entity as a valid spawn (`isValidSpawn`). Spawner-style spawn reasons skip this check. |
| `Monster.checkAnyLightMonsterSpawnRules` | Same as `checkMobSpawnRules` (no light test). Used by blaze, breeze, zoglin. |
| `Monster.isDarkEnoughToSpawn` | Fails when sky light at the position is greater than a fresh `nextInt(32)`; fails when the dimension's `monster_spawn_block_light_limit` is below 15 and block light exceeds it; otherwise passes when the raw local brightness (a thunder-adjusted value when thundering) is at most one sample of the dimension's `monster_spawn_light_level`. |
| `Monster.checkMonsterSpawnRules` | `isDarkEnoughToSpawn` unless the spawn reason ignores light, then `checkMobSpawnRules`. |
| `WaterAnimal.checkSurfaceWaterAnimalSpawnRules` | Position Y in `[seaLevel - 13, seaLevel]` inclusive; the fluid below is water; the block above is water. |
| `AgeableWaterCreature.checkSurfaceAgeableWaterCreatureSpawnRules` | Identical to the previous rule (Y in `[sea-13, sea]`, water below, water block above). Used by squid and dolphin. |
| `TropicalFish.checkTropicalFishSpawnRules` | Fluid below is water and the block above is water, and (the biome has tag `allows_tropical_fish_spawns_at_any_height`, or the surface rule above passes). |
| `Axolotl.checkAxolotlSpawnRules` | The block below is in block tag `axolotls_spawnable_on` (no other test). |
| `GlowSquid.checkGlowSquidSpawnRules` | Y at most `seaLevel - 33`; raw brightness at the position (with 0 sky darkening) equals 0; the block at the position is water. |
| `AbstractNautilus.checkNautilusSpawnRules` | Y in `[seaLevel - 25, seaLevel - 5]`; water below; water block above. |
| `Guardian.checkGuardianSpawnRules` | All of: (a fresh `nextInt(20)` is 0, or the sky is not visible from below the water at the position); the difficulty is not Peaceful; (the spawn reason is a spawner, or the fluid at the position is water); the fluid below the position is water. |
| `Drowned.checkDrownedSpawnRules` | Fluid below must be water unless a spawner reason; difficulty not Peaceful; light test as monsters unless the reason ignores light; fluid at the position must be water unless a spawner; reinforcement or spawner reason accept immediately; in biomes with tag `more_frequent_drowned_spawns` additionally `nextInt(15)==0`; elsewhere `nextInt(40)==0` and Y below `seaLevel - 5`. |
| `Ghast.checkGhastSpawnRules` | Difficulty not Peaceful; `nextInt(20)==0`; then `checkMobSpawnRules`. |
| `MagmaCube.checkMagmaCubeSpawnRules` | Difficulty not Peaceful (nothing else read). |
| `Piglin.checkPiglinSpawnRules`, `Hoglin.checkHoglinSpawnRules` | The block below must not be `nether_wart_block`; nothing else (no light or difficulty test). |
| `ZombifiedPiglin.checkZombifiedPiglinSpawnRules` | Difficulty not Peaceful; the block below is not `nether_wart_block`. |
| `Strider.checkStriderSpawnRules` | Walk upward from the position while the fluid there is lava; pass when the first non-lava cell is air. |
| `Endermite.checkEndermiteSpawnRules` | `checkAnyLightMonsterSpawnRules`; a spawner reason passes; otherwise no player within 5 blocks. |
| `Slime` (context only) | Not in scope; magma cube above is the lava analogue. |

### 3.3 Biome spawn tables (aquatic categories)

Each biome JSON carries `minecraft:gameplay/natural_mob_spawns` (attribute `modifier: overlay`) with
`spawns_by_category` and `spawn_costs`. Columns: entity `w` = weight, `x` = group size (inclusive range). Categories:
`water_creature`, `water_ambient`, `underground_water_creature`, `axolotls`. Biomes not listed have no entry in these
categories (`deep_dark` and `the_void` list every category as empty).

| Biomes | Category | Entries (weight, group size) |
|---|---|---|
| badlands bamboo_jungle beach birch_forest cherry_grove dappled_forest dark_forest desert dripstone_caves eroded_badlands flower_forest forest frozen_peaks grove ice_spikes jagged_peaks jungle meadow mushroom_fields old_growth_birch_forest old_growth_pine_taiga old_growth_spruce_taiga pale_garden plains savanna savanna_plateau snowy_beach snowy_plains snowy_slopes snowy_taiga sparse_jungle stony_peaks stony_shore sunflower_plains swamp taiga windswept_forest windswept_gravelly_hills windswept_hills windswept_savanna wooded_badlands | underground_water_creature | `glow_squid` w10 x4-6 |
| cold_ocean deep_cold_ocean | underground_water_creature | `glow_squid` w10 x4-6 |
|  | water_ambient | `cod` w15 x3-6; `salmon` w15 x1-5 |
|  | water_creature | `squid` w3 x1-4; `nautilus` w2 x1 |
| deep_frozen_ocean frozen_ocean | underground_water_creature | `glow_squid` w10 x4-6 |
|  | water_ambient | `salmon` w15 x1-5 |
|  | water_creature | `squid` w1 x1-4; `nautilus` w2 x1 |
| deep_lukewarm_ocean | underground_water_creature | `glow_squid` w10 x4-6 |
|  | water_ambient | `cod` w8 x3-6; `pufferfish` w5 x1-3; `tropical_fish` w25 x8 |
|  | water_creature | `squid` w8 x1-4; `dolphin` w2 x1-2; `nautilus` w5 x1 |
| deep_ocean ocean | underground_water_creature | `glow_squid` w10 x4-6 |
|  | water_ambient | `cod` w10 x3-6 |
|  | water_creature | `squid` w1 x1-4; `dolphin` w1 x1-2; `nautilus` w5 x1 |
| frozen_river river | underground_water_creature | `glow_squid` w10 x4-6 |
|  | water_ambient | `salmon` w5 x1-5 |
|  | water_creature | `squid` w2 x1-4 |
| lukewarm_ocean | underground_water_creature | `glow_squid` w10 x4-6 |
|  | water_ambient | `cod` w15 x3-6; `pufferfish` w5 x1-3; `tropical_fish` w25 x8 |
|  | water_creature | `squid` w10 x1-2; `dolphin` w2 x1-2; `nautilus` w5 x1 |
| lush_caves | axolotls | `axolotl` w10 x4-6 |
|  | underground_water_creature | `glow_squid` w10 x4-6 |
|  | water_ambient | `tropical_fish` w25 x8 |
| mangrove_swamp | underground_water_creature | `glow_squid` w10 x4-6 |
|  | water_ambient | `tropical_fish` w25 x8 |
| warm_ocean | underground_water_creature | `glow_squid` w10 x4-6 |
|  | water_ambient | `pufferfish` w15 x1-3; `tropical_fish` w25 x8 |
|  | water_creature | `nautilus` w5 x1; `squid` w10 x4; `dolphin` w2 x1-2 |

The `overlay` modifier is recorded on every biome; its merge semantics against a base list were not read (Open
question 2). The lists above are what the biome files themselves contain.

### 3.4 Biome spawn tables (Nether and End)

| Biomes | Category | Entries (weight, group size) | Spawn costs |
|---|---|---|---|
| nether_wastes | creature | `strider` w60 x1-2 |  |
| nether_wastes | monster | `ghast` w50 x4; `zombified_piglin` w100 x4; `magma_cube` w2 x4; `enderman` w1 x4; `piglin` w15 x4 |  |
| soul_sand_valley | creature | `strider` w60 x1-2 |  |
| soul_sand_valley | monster | `skeleton` w20 x5; `ghast` w50 x4; `enderman` w1 x4 | {"minecraft:enderman": {"charge": 0.7, "energy_budget": 0.15}, "minecraft:ghast": {"charge": 0.7, "energy_budget": 0.15}, "minecraft:skeleton": {"charge": 0.7, "energy_budget": 0.15}, "minecraft:strider": {"charge": 0.7, "energy_budget": 0.15}} |
| crimson_forest | creature | `strider` w60 x1-2 |  |
| crimson_forest | monster | `zombified_piglin` w1 x2-4; `hoglin` w9 x3-4; `piglin` w5 x3-4 |  |
| warped_forest | creature | `strider` w60 x1-2 |  |
| warped_forest | monster | `enderman` w1 x4 | {"minecraft:enderman": {"charge": 1.0, "energy_budget": 0.12}} |
| basalt_deltas | creature | `strider` w60 x1-2 |  |
| basalt_deltas | monster | `ghast` w40 x1; `magma_cube` w100 x2-5 |  |
| the_end | monster | `enderman` w10 x4 |  |
| end_highlands | monster | `enderman` w10 x4 |  |
| end_midlands | monster | `enderman` w10 x4 |  |
| end_barrens | monster | `enderman` w10 x4 |  |
| small_end_islands | monster | `enderman` w10 x4 |  |

`spawn_costs` (soul sand valley, warped forest) are per-entity `charge` and `energy_budget` values used by the
potential-based spawner (18 framework: natural spawning); they are only copied here.

The dimension types give the light parameters that `isDarkEnoughToSpawn` reads:

| Dimension type | `monster_spawn_light_level` | `monster_spawn_block_light_limit` | Notes |
|---|---|---|---|
| `overworld`, `overworld_caves` | uniform integer 0 to 7 | 0 | height 384, min y -64 |
| `the_nether` | 7 | 15 | height 256, logical height 128, coordinate scale 8.0 |
| `the_end` | 15 | 0 | `has_ender_dragon_fight` true, `has_fixed_time` true with `timelines` `#minecraft:in_end`, height 256 |

### 3.5 Structure spawn overrides

`worldgen/structure/*.json` `spawn_overrides`. "piece" restricts the override to the bounding boxes of the structure
pieces, "full" to the whole structure box. An override replaces the biome list of that category inside its box (the
replacement rule is the framework's, 18 framework: natural spawning); an empty list means "nothing spawns".

| Structure | Category | Box | Entries (weight, count) |
|---|---|---|---|
| `fortress` (Nether fortress) | monster | piece | `blaze` w10 x2-3; `zombified_piglin` w5 x4; `wither_skeleton` w8 x5; `skeleton` w2 x5; `magma_cube` w3 x4 |
| `monument` (ocean monument) | monster | full | `guardian` w1 x2-4 |
| `monument` | axolotls, underground_water_creature | full | empty |
| `pillager_outpost` | monster | full | `pillager` w1 x1 |
| `swamp_hut` | creature / monster | piece | `cat` w1 x1 / `witch` w1 x1 |
| `trial_chambers` | all eight categories | piece | empty |
| `ancient_city` | all eight categories | full | empty |
| `bastion_remnant`, `nether_fossil`, `ocean_ruin_warm` | none | - | no overrides; bastion piglins are placed by the structure's own pieces (not read, Open question 3) |

Fortress code path (`NaturalSpawner.mobsAt`): for the MONSTER category, when the block below the spawn position is `nether_bricks` and the position is inside a valid
fortress structure (`isInNetherFortressBounds`: the structure manager reports a valid `fortress` structure at the position), the spawner uses the static list
`NetherFortressStructure.FORTRESS_ENEMIES` instead of the biome list: `blaze` (count uniform 2 to 3) weight 10, `zombified_piglin` (4) weight 5, `wither_skeleton` (5) weight 8,
`skeleton` (5) weight 2, `magma_cube` (4) weight 3 (the same entries as `fortress.json`'s override above). Other structures use `getMobsAt` (the overrides of the table). This agrees with 18 §6.5 step 4.

### 3.6 Entity type tags used by the mobs here

| Tag | Members (`#` = other tag) |
|---|---|
| `accepts_iron_golem_gift` | copper_golem |
| `aquatic` | turtle axolotl guardian elder_guardian cod pufferfish salmon tropical_fish dolphin squid glow_squid tadpole nautilus zombie_nautilus |
| `arrows` | arrow spectral_arrow |
| `arthropod` | bee endermite silverfish spider cave_spider |
| `axolotl_always_hostiles` | drowned guardian elder_guardian |
| `axolotl_hunt_targets` | tropical_fish pufferfish salmon cod squid glow_squid tadpole |
| `beehive_inhabitors` | bee |
| `boat` | oak_boat spruce_boat birch_boat jungle_boat acacia_boat cherry_boat dark_oak_boat pale_oak_boat mangrove_boat bamboo_raft poplar_boat |
| `burn_in_daylight` | skeleton stray wither_skeleton bogged zombie zombie_horse zombie_villager drowned zombie_nautilus phantom |
| `can_breathe_under_water` | #undead axolotl frog guardian elder_guardian turtle glow_squid cod pufferfish salmon squid tropical_fish tadpole armor_stand copper_golem nautilus |
| `can_equip_harness` | happy_ghast |
| `can_equip_saddle` | horse skeleton_horse zombie_horse donkey mule pig strider camel camel_husk nautilus zombie_nautilus |
| `can_float_while_ridden` | horse zombie_horse mule donkey camel camel_husk |
| `can_turn_in_boats` | breeze |
| `can_wear_horse_armor` | horse zombie_horse |
| `can_wear_nautilus_armor` | nautilus zombie_nautilus |
| `candidate_for_iron_golem_gift` | villager #accepts_iron_golem_gift |
| `cannot_be_age_locked` | zombie_horse skeleton_horse villager |
| `cannot_be_dismounted_by_item_usage` | interaction |
| `cannot_be_pushed_onto_boats` | player elder_guardian cod pufferfish salmon tropical_fish dolphin squid glow_squid tadpole creaking nautilus zombie_nautilus sulfur_cube |
| `deflects_projectiles` | breeze |
| `dismounts_underwater` | camel chicken donkey happy_ghast horse llama mule pig ravager spider strider trader_llama zombie_horse |
| `fall_damage_immune` | copper_golem iron_golem snow_golem shulker allay bat bee blaze cat chicken ghast happy_ghast phantom magma_cube ocelot parrot wither breeze |
| `followable_friendly_mobs` | armadillo bee camel cat chicken cow donkey fox goat happy_ghast horse skeleton_horse llama mule ocelot panda parrot pig polar_bear rabbit sheep sniffer strider villager wolf |
| `freeze_hurts_extra_types` | strider blaze magma_cube |
| `freeze_immune_entity_types` | stray polar_bear snow_golem wither |
| `frog_food` | slime magma_cube |
| `ignores_poison_and_regen` | #undead |
| `illager` | evoker illusioner pillager vindicator |
| `illager_friends` | #illager |
| `immune_to_infested` | silverfish |
| `immune_to_oozing` | slime |
| `impact_projectiles` | #arrows firework_rocket snowball fireball small_fireball egg trident dragon_fireball wither_skull wind_charge breeze_wind_charge |
| `inverted_healing_and_harm` | #undead |
| `nautilus_hostiles` | pufferfish |
| `no_anger_from_wind_charge` | breeze skeleton bogged stray zombie husk spider cave_spider slime |
| `non_controlling_rider` | slime magma_cube sulfur_cube |
| `not_affected_by_geysers` | ender_dragon |
| `not_scary_for_pufferfish` | turtle guardian elder_guardian cod pufferfish salmon tropical_fish dolphin squid glow_squid tadpole nautilus zombie_nautilus sulfur_cube |
| `powder_snow_walkable_mobs` | rabbit endermite silverfish fox |
| `raiders` | evoker pillager ravager vindicator illusioner witch |
| `redirectable_projectile` | fireball wind_charge breeze_wind_charge |
| `sensitive_to_bane_of_arthropods` | #arthropod |
| `sensitive_to_impaling` | #aquatic |
| `sensitive_to_smite` | #undead |
| `skeletons` | skeleton stray wither_skeleton skeleton_horse bogged parched |
| `undead` | #skeletons #zombies wither phantom |
| `wither_friends` | #undead |
| `zombies` | zombie_horse camel_husk zombie zombie_villager zombified_piglin zoglin drowned husk zombie_nautilus |

### 3.7 Loot-table notation

Loot tables are `data/minecraft/loot_table/entities/<key>.json`. In this jar the schema uses `modifier` for item
functions and `condition` for pool and entry conditions. The notation below shortens them: `set_count a-b` (uniform
integer), `+looting a-b/level` (`enchanted_count_increase`: adds a uniform amount per looting level),
`smelt` (the furnace-smelt modifier applied when the mob is burning or the killing weapon smelts loot),
`chance p` (`random_chance`), `chance p0 -> base + step/level above first` (the looting-bonus rare chance, written
`rare(p0; base, step)`), `player` (`killed_by_player`). Rolls are 1 unless stated. 18 framework: loot owns the
evaluation rules.

### 3.8 Block tags used by the dragon and the Wither

Read from `data/minecraft/tags/block` (the literal lists):

| Tag | Members |
|---|---|
| `dragon_immune` | `barrier`, `bedrock`, `end_portal`, `end_portal_frame`, `end_gateway`, `command_block`, `repeating_command_block`, `chain_command_block`, `structure_block`, `jigsaw`, `moving_piston`, `obsidian`, `crying_obsidian`, `end_stone`, `iron_bars`, `respawn_anchor`, `reinforced_deepslate`, `test_block`, `test_instance_block` |
| `wither_immune` | `barrier`, `bedrock`, `end_portal`, `end_portal_frame`, `end_gateway`, `command_block`, `repeating_command_block`, `chain_command_block`, `structure_block`, `jigsaw`, `moving_piston`, `light`, `reinforced_deepslate`, `test_block`, `test_instance_block` |
| `dragon_transparent` | `light`, tag `fire` |
| `wither_summon_base_blocks` | `soul_sand`, `soul_soil` |
| `strider_warm_blocks` | `lava` |
| `piglin_repellents` | `soul_fire`, `soul_torch`, `soul_lantern`, `soul_wall_torch`, `soul_campfire` |
| `hoglin_repellents` | `warped_fungus`, `potted_warped_fungus`, `nether_portal`, `respawn_anchor` |
| `bats_spawnable_on` | tag `base_stone_overworld` |

Meaning for block breaking: the dragon's body (head, neck, body boxes) removes every block it touches except air, `dragon_transparent`
blocks and `dragon_immune` blocks; touching an immune block only marks it "in wall" (it slows down). So it breaks ordinary terrain it flies through but
cannot break obsidian (the pillars), end stone, iron bars (the cages), the exit portal blocks or bedrock. The Wither's breaking after being hurt removes everything
except air and `wither_immune`: obsidian, end stone and iron bars are destroyed; bedrock, portal blocks, command blocks, barriers and reinforced deepslate are not.


## 4. Aquatic mobs

Water mobs share `WaterAnimal` (non-ageable fish) or `AgeableWaterCreature` (squid family, dolphin, nautilus) behaviour.
Dimensions and attributes of every mob below are in the §2 table (size) and in the per-mob tables.

### 4.1 Shared water-animal rules (`WaterAnimal`, `AbstractFish`)

| Rule | Value |
|---|---|
| Water path malus | `WATER` malus 0 (water is free to path through) |
| Not pushed by fluid, cannot be leashed | yes (`isPushedByFluid` false, `canBeLeashed` false; squid family and dolphin override leashing to true) |
| Spawn obstruction | the entity box must be unobstructed (`isUnobstructed`) |
| Ambient sound interval | 120 ticks |
| Base XP reward | `1 + nextInt(3)` for fish; guardians and others set their own `xpReward` field |
| Air supply (fish and any `WaterAnimal`) | each tick while alive and not in water: air - 1; when the drowning test fires the air is set to 0 and the mob takes 2 damage of the drown type (`damageSources().drown()`); in water the air is reset to 300. The check runs once per tick from `baseTick`. |
| Persistence | fish are persistent when `fromBucket` is true or they have a custom name (`removeWhenFarAway` is false then) |
| Bucket pickup | right-click with a water bucket: the fish becomes the matching bucket item and `FROM_BUCKET` = true (18 framework: Bucketable interaction) |
| Fish attributes | Mob base attributes plus `MAX_HEALTH 3.0` |
| Fish goals | 0: `PanicGoal(speed 1.25)`; 2: `AvoidEntityGoal(Player, radius 8, walk 1.6, sprint 1.4, NO_SPECTATORS)`; 4: `RandomSwimmingGoal(speed 1, interval 40)` (only when `canRandomSwim`, which is true for fish and false for a schooling follower); schooling fish add 5: `FollowFlockLeaderGoal` |
| Move control (`FishMoveControl`) | while the eyes are in water: vertical velocity + 0.005 per tick. With a move-to target: speed = lerp(0.125, current speed, `speedModifier * MOVEMENT_SPEED`); when the Y difference is non-zero, vertical velocity += `speed * (dy / distance) * 0.1`; when x or z differ, yaw lerps toward the heading with a limit of 90 degrees per tick and the body follows the head yaw. When the navigation is done the speed is set to 0. |
| In-water travel (`travelInWater`) | accelerate by `moveRelative(0.01)`, move, multiply the velocity by 0.9; when there is no attack target, vertical velocity -= 0.005 |
| Out of water | when not in water, on the ground and `verticalCollision`: add a velocity of `((rand*2-1)*0.05, 0.4, (rand*2-1)*0.05)`, clear on-ground, flag sync and play the flop sound (the further conditions that space the flops were not read; Open question 7) |
| Spawn cluster | `getMaxSpawnClusterSize` = 8 for fish; for schooling fish the max school size equals the cluster size, except salmon (5) |
| Schooling (`AbstractSchoolingFish`) | one leader per school; `startFollowing(leader)` increments the leader's `schoolSize`; a follower moves only by following (`FollowFlockLeaderGoal`); a leader with followers re-checks every tick with probability 1/200 whether another fish of the same class is within an 8-block inflated box, and if at most itself is found sets `schoolSize` to 1; leader within distance squared 121 counts as "in range"; spawn group data makes the first spawned fish the leader and every later fish of the group follow it |

Metadata of all fish: 16 = from bucket (Boolean).

### 4.2 Cod, salmon, pufferfish, tropical fish

| Mob | Size (w x h) | Extra attributes | Special | Metadata (own) | Loot | Spawn |
|---|---|---|---|---|---|---|
| `cod` | 0.5 x 0.3 | - | schooling; no special | - | `cod` (smelt); pool 2: `bone_meal` `chance 0.05` | placement IN_WATER, predicate surface water animal |
| `salmon` | 0.7 x 0.4 base | - | variants small/medium/large; max school 5 | 17 = size variant (VarInt, 0 small, 1 medium, 2 large) | `salmon` (smelt); `bone_meal` 0.05 | surface water animal |
| `pufferfish` | 0.7 x 0.7 at the maximum state | - | inflation (§4.3) | 17 = puff state (VarInt 0, 1, 2) | `pufferfish` (smelt); `bone_meal` 0.05 | surface water animal |
| `tropical_fish` | 0.5 x 0.4 | - | variants (§4.4) | 17 = packed variant (VarInt) | `tropical_fish` (smelt); `bone_meal` 0.05 | tropical rule (§3.2) |

Salmon variants (`Salmon$Variant`): id 0 `small` scale 0.5, id 1 `medium` scale 1.0, id 2 `large` scale 1.5. The dimensions are the type dimensions times the scale (`getDefaultDimensions`
scales by the variant, and `refreshDimensions` runs when metadata 17 changes). Spawn variant (`finalizeSpawn`) is a
weighted pick: small 30, medium 50, large 15 (total 95). The default (before spawn) is medium.

### 4.3 Pufferfish inflation (`Pufferfish`)

Puff state: 0 deflated, 1 half, 2 full. Dimension scale by state: state 0 x 0.5, state 1 x 0.7, state 2 x 1.0
(`getScale`); dimensions refresh on every change of metadata 17. The save tag `PuffState` is clamped to at most 2.

Two counters: `inflateCounter` and `deflateTimer`. Goal 1 (`PufferfishPuffGoal`): `canUse` is true when any living
entity within the mob's box inflated by 2.0 passes the scary-mob test (not a creative-mode player, and its type is not
in tag `not_scary_for_pufferfish`); `start` sets `inflateCounter = 1` and `deflateTimer = 0`; `stop` sets
`inflateCounter = 0`.

Server tick (alive and effective AI only):

| Condition | Action |
|---|---|
| `inflateCounter > 0`, state 0 | play blow-up sound, state = 1 |
| `inflateCounter > 0`, `inflateCounter > 40`, state 1 | play blow-up sound, state = 2 |
| `inflateCounter > 0` | then `inflateCounter += 1` |
| `inflateCounter <= 0`, state != 0, `deflateTimer > 60`, state 2 | play blow-out sound, state = 1 |
| (else) `deflateTimer > 100`, state 1 | play blow-out sound, state = 0 |
| `inflateCounter <= 0`, state != 0 | then `deflateTimer += 1` |

Sting (every `aiStep`, server, alive, state > 0): every `Mob` whose box intersects the pufferfish's box inflated by
0.3 and passes the non-combat targeting test (invisibility and line of sight ignored, selector = scary-mob) is stung
if teams allow damage: `hurt(mobAttack, 1 + state)` and, when that damage lands, Poison for `60 * state` ticks at
amplifier 0, plus the sting sound. `playerTouch` does the same to a player: when state > 0 and teams allow damage,
`hurt(mobAttack, 1 + state)`; if it lands: a Game Event packet 9 (value 0) is sent to that player unless the pufferfish
is silent, then Poison `60 * state` ticks amplifier 0.

### 4.4 Tropical fish variants (`TropicalFish`)

The packed variant is a 32-bit integer stored in metadata 17:

`packed = pattern.packedId | (baseColor.id << 16) | (patternColor.id << 24)`

with `pattern.packedId = base.id | (patternIndex << 8)` where `base.id` is 0 for the SMALL shape and 1 for the LARGE
shape, and the colours are `DyeColor` ids (0 to 15, the ids of 00 §13 serializer 43). Unpack: shape = `packed & 0xFF`,
pattern index = `(packed >> 8) & 0xFF`, base colour = `(packed >> 16) & 0xFF`, pattern colour = `(packed >> 24) & 0xFF`.
(The pattern lookup uses `packed & 0xFFFF`.)

| Pattern | Shape | Index | `packedId` (hex, low 16 bits) |
|---|---|---|---|
| kob | small | 0 | 0x0000 |
| sunstreak | small | 1 | 0x0100 |
| snooper | small | 2 | 0x0200 |
| dasher | small | 3 | 0x0300 |
| brinely | small | 4 | 0x0400 |
| spotty | small | 5 | 0x0500 |
| flopper | large | 0 | 0x0001 |
| stripey | large | 1 | 0x0101 |
| glitter | large | 2 | 0x0201 |
| blockfish | large | 3 | 0x0301 |
| betty | large | 4 | 0x0401 |
| clayfish | large | 5 | 0x0501 |

Default variant: kob, base white, pattern white. Spawn (`finalizeSpawn`): when the spawn group already carries a variant
the fish takes it; otherwise with probability 0.9 (`nextFloat() < 0.9`) a uniform pick from the 22 named common variants
below and the group variant is set to it (the fish is a school member); with the remaining 0.1 the fish is not a school
(`isSchool = false`, so `isMaxGroupSizeReached` returns false for it) and gets a uniformly random pattern (12 values),
random base colour and random pattern colour (16 values each, independent draws, in the order pattern, base, pattern
colour).

Common variants (pattern, base colour, pattern colour), index 0 to 21:

| # | Pattern | Base | Pattern colour | # | Pattern | Base | Pattern colour |
|---|---|---|---|---|---|---|---|
| 0 | stripey | orange | gray | 11 | clayfish | white | orange |
| 1 | flopper | gray | gray | 12 | dasher | cyan | pink |
| 2 | flopper | gray | blue | 13 | brinely | lime | light_blue |
| 3 | clayfish | white | gray | 14 | betty | red | white |
| 4 | sunstreak | blue | gray | 15 | snooper | gray | red |
| 5 | kob | orange | white | 16 | blockfish | red | white |
| 6 | spotty | pink | light_blue | 17 | flopper | white | yellow |
| 7 | blockfish | purple | yellow | 18 | kob | red | white |
| 8 | clayfish | white | red | 19 | sunstreak | gray | white |
| 9 | spotty | white | yellow | 20 | dasher | cyan | yellow |
| 10 | glitter | white | gray | 21 | flopper | yellow | yellow |

### 4.5 Squid and glow squid (`Squid`, `GlowSquid`)

| Field | Squid | Glow squid |
|---|---|---|
| Type, size | `squid` 0.8 x 0.8; baby 0.5 x 0.5 eye 0.37 | `glow_squid` 0.8 x 0.8 |
| Category | WATER_CREATURE | UNDERGROUND_WATER_CREATURE |
| Attributes | Mob base + `MAX_HEALTH 10` | same |
| Ageable | yes: baby chance 0.05 via spawn group data; breeds into its own type; leashable | same |
| Gravity | 0.08 (`getDefaultGravity`); movement emission = events only | same |
| Metadata | 16 baby, 17 age locked | + 18 = dark ticks remaining (VarInt, default 0) |
| Loot | `ink_sac` (one pool, one roll, no modifier) | `glow_ink_sac` |
| XP | no `xpReward` is set in the squid classes; the amount comes from the generic Mob rule (not read; Open question 8) | same |
| Spawn | surface ageable water creature (§3.2), biomes §3.3 | glow squid rule (§3.2) |

Squid goals: 0 `SquidRandomMovementGoal`; 1 `SquidFleeGoal`. Movement works on a movement vector `m` (blocks per tick)
stored on the squid:

- Random movement (each tick): if `noActionTime > 100`, `m = 0`. Otherwise, when `nextInt(50) == 0`, or the squid is not
  touching water, or it currently has no movement vector (`|m|^2 <= 1e-5`): pick `a = nextFloat * 2*pi` and set
  `m = (cos(a) * 0.2, -0.1 + nextFloat * 0.2, sin(a) * 0.2)`.
- Flee (`canUse`: in water, has a last attacker, attacker distance squared < 100; `requiresUpdateEveryTick`): `fleeTicks`
  counts up; the push vector is `self - attacker`; the cell at self + push must be water or air (else the vector is not
  used, `m` unchanged); when valid: normalize, scale by `3.0` reduced by `(d - 5) / 10` once the distance `d` exceeds
  5 (never below 0), drop the Y component when the target cell is air, then `m = vector / 20`; a bubble particle is
  spawned when `fleeTicks % 10 == 5`.
- Swimming animation phase (`aiStep`): a `tentacleMovement` phase advances by `tentacleSpeed` each tick and wraps at
  `2*pi`; on wrap (server) with probability 1/10 a new `tentacleSpeed = 0.2 / (nextFloat + 1)` is chosen and entity
  event 19 is broadcast (client resets `tentacleMovement` to 0). During the first half of the phase (phase < pi) the
  squid is thrust: when the normalised phase `p = phase / pi` exceeds 0.75, the velocity is set to `m` (only on the
  authority side) and `rotateSpeed = 1`; otherwise `rotateSpeed *= 0.8`. In the second half the velocity is scaled by
  0.9 and `rotateSpeed *= 0.99`. Out of water: vertical velocity -= gravity (or the levitation rule
  `0.05 * (amplifier + 1)`) times the air drag, horizontal velocity zero.
- Ink: when `hurtServer` succeeds and the squid has a last attacker, it spawns 30 ink particles (`SQUID_INK`, glow
  variant `GLOW_SQUID_INK`) and plays the squirt sound.
- Glow squid: `hurtServer` that lands sets dark ticks to 100 (it stops glowing for 100 ticks; the counter decrements
  each `aiStep`); the client spawns glow particles while the counter is zero.

### 4.6 Dolphin (`Dolphin`)

Type `dolphin`, 0.9 x 0.6, eye 0.3, category WATER_CREATURE, ageable (baby scale 0.65 of the adult dimensions,
baby eye 0.09375; baby chance 0.1). Attributes: Mob base + `MAX_HEALTH 10`, `MOVEMENT_SPEED 1.2`, `ATTACK_DAMAGE 3`.
Move control `SmoothSwimmingMoveControl(85, 10, 0.02, 0.1, true)`, look control `SmoothSwimmingLookControl(10)`; it can pick
up loot (`setCanPickUpLoot(true)`); water path navigation. Metadata: 16 baby, 17 age locked, 18 got fish (Boolean),
19 moistness (VarInt, default 2400). Max air 4800, and the air is always refilled to max (no drowning in water).
Does not take the base drowning damage: the air handler is disabled (`handleAirSupply` returns).

Goals: 0 `BreathAirGoal`; 0 `TryFindLiquidGoal(tag dolphin_tries_to_find)`; 1 `DolphinSwimToTreasureGoal`;
2 `DolphinSwimWithPlayerGoal(speed 4.0)`; 4 `RandomSwimmingGoal(1, 10)`; 4 `RandomLookAroundGoal`;
5 `LookAtPlayerGoal(Player, 6)`; 5 `DolphinJumpGoal(10)`; 6 `MeleeAttackGoal(1.2, true)`; 7 `MoveToItemGoal`;
8 `PlayWithItemsGoal`; 8 `FollowPlayerRiddenEntityGoal(AbstractBoat)`; 8 `FollowPlayerRiddenEntityGoal(AbstractNautilus)`;
9 `AvoidEntityGoal(Guardian, 8, 1.0, 1.0)`; target 1: `HurtByTargetGoal(Guardian)` with `setAlertOthers()`.
Babies cannot attack (`canAttack` false when baby).

Rules:

- Moisture: every tick it is decremented unless the dolphin is in water or rain, in which case it is set to 2400. At
  moisture <= 0 it takes `hurt(dryOut, 1)` every tick. While on the ground (and dry) it also performs random hops: a
  velocity addition of `((rand*2-1)*0.2, 0.5, (rand*2-1)*0.2)` and a random yaw (the surrounding guard conditions were
  displayed only partially; Open question 7).
- Feeding (`mobInteract`): holding an item in tag `fishes`: sound `dolphin eat`; an adult sets `gotFish = true`; a
  baby ages up by `getSpeedUpSecondsWhenFeeding`; the item is consumed (1). Result SUCCESS.
- Treasure goal: usable when `gotFish` and air supply >= 100; not interruptible. `start`: server only; looks up the
  nearest structure in tag `dolphin_located` within a search radius of 50 (the lookup does not skip known
  structures); if none is found the goal is `stuck` and `stop` clears `gotFish`; otherwise broadcast entity event 38
  (happy villager particles around the dolphin: 7 particles at Gaussian offsets with sigma 0.01). Each tick it moves
  toward a point at distance 16 (angle limit 0.3927 rad) from the treasure, falling back to distance 8 with 90 degrees
  and then 8 with height 5; speed modifier 1.3; every `1/80` tick sample it broadcasts event 38 again. It runs while the
  dolphin is farther than 4 blocks (horizontally, at its own Y) from the treasure, not stuck and air >= 100.
- Swim with player: finds the nearest player within 10 blocks (no line of sight needed) who is swimming and is not its
  target; the goal continues while the player swims and is within 16 blocks (256 squared). On `start` and with
  probability 1/6 per tick afterwards (while the player swims) the player gets Dolphin's Grace for 100 ticks. Within
  2.5 blocks (6.25 squared) it stops moving, otherwise it follows at speed 4.0 (modifier).
- Items: `MoveToItemGoal` finds an item entity in an 8 x 8 x 8 expanded box (not pickup-delayed, alive, in water) and
  walks to it at 1.2 with cooldown `tickCount + nextInt(100)` after dropping; `pickUpItem` puts the stack in the main
  hand (guaranteed drop on death) when the main hand is empty and `canHoldItem`; `PlayWithItemsGoal` drops the held
  item.
- Loot: `cod`, `set_count 0-1`, `+looting 0-1/level`, smelt.
- Biomes: §3.3 (`water_creature`).

### 4.7 Axolotl (`Axolotl`, `AxolotlAi`, `PlayDead`, `ValidatePlayDead`)

Type `axolotl`, 0.75 x 0.42, eye 0.2751, category AXOLOTLS, ageable (baby 0.375 x 0.21, eye 0.09375). Attributes: Animal
base + `MAX_HEALTH 14`, `MOVEMENT_SPEED 1.0`, `ATTACK_DAMAGE 2.0`, `STEP_HEIGHT 1.0`. Water malus 0. Metadata: 16 baby,
17 age locked, 18 variant (VarInt), 19 playing dead (Boolean), 20 from bucket (Boolean). Persistent when from bucket.

Variants (`Axolotl$Variant`): 0 `lucy` (common), 1 `wild` (common), 2 `gold` (common), 3 `cyan` (common), 4 `blue`
(rare, not common). Default `lucy`. A "rare" roll is `nextInt(1200) == 0` (`useRareVariant`). The group data picks the
variant (the group data holds an array of variants and `getVariant(random)` returns `types[nextInt(types.length)]`; `finalizeSpawn` builds that array from two `getCommonSpawnVariant` draws). Bucket spawns skip `finalizeSpawn`. In `finalizeSpawn`, for a spawn group of size 2 or more the new
axolotl is a baby (`age = -24000`); otherwise adult.

Air: `AXOLOTL_TOTAL_AIR_SUPPLY` 6000; the air handler runs every tick: out of water and not in rain, air - 1 and at the
drowning threshold the air becomes 0 and it takes `hurt(dryOut, 2)`; in water or rain the air is reset to max.
`REHYDRATE_AIR_SUPPLY` 1800 is a constant that is declared; its use was not traced.

Brain (18 framework: Brain): sensors `NEAREST_LIVING_ENTITIES`, `NEAREST_ADULT`, `HURT_BY`, `AXOLOTL_ATTACKABLES`,
`FOOD_TEMPTATIONS`. Activities (priority: behaviour):

| Activity | Priorities |
|---|---|
| CORE | `LookAtTargetSink(45, 90)`, `MoveToTargetSink`, `ValidatePlayDead`, `CountDownCooldownTicks(TEMPTATION_COOLDOWN_TICKS)` |
| IDLE | 0: `SetEntityLookTargetSometimes(Player, 6.0, 30-60)`; 1: `AnimalMakeLove(AXOLOTL, 0.2, 2)`; 2: one-of {`FollowTemptation` (weight 1; speed 0.6 in water, 0.15 on land), `BabyFollowAdult(range 5-16, speed 0.6 / 0.15)` (weight 1)}; 3: `StartAttacking(nearest attackable)`; 3: `TryFindLiquid(6, 0.15, tag axolotl_tries_to_find)`; 4: gate (runs only while there is no walk target): `RandomStroll.swim(0.5)` w2, `RandomStroll.stroll(0.15)` w2, `SetWalkTargetFromLookTarget` (target in same medium; speed 0.5 in water / 0.15) w3, two conditional movers w5 |
| FIGHT (memory ATTACK_TARGET present) | `StopAttackingIfTargetInvalid`, `SetWalkTargetFromAttackTargetIfTargetOutOfReach` (speed 0.6 in water, 0.15 on land), `MeleeAttack(cooldown 20)`, erase `ATTACK_TARGET` when the target is dead |
| PLAY_DEAD (memory PLAY_DEAD_TICKS present) | 0: `PlayDead`; 1: erase `PLAY_DEAD_TICKS` when no longer valid |

Active activity order: PLAY_DEAD, FIGHT, IDLE (first valid). When FIGHT ends the memory `HAS_HUNTING_COOLDOWN` is set
for 2400 ticks.

Hunting sensor (`AxolotlAttackablesSensor`): a living entity is the nearest attackable when it is within 8 blocks
(distance squared <= 64), is in water, and either is of a type in tag `axolotl_always_hostiles` or (no hunting
cooldown and its type is in tag `axolotl_hunt_targets`) and it passes the standard attackability test. Breeding mobs
are not attacked (the function returns empty while the axolotl is breeding).

Play dead (`hurtServer`): when AI is on, with probability 1/3 per hurt (`nextInt(3) == 0`), and (`nextInt(3) < damage`
or health / max health < 0.5) and `damage < current health` and the axolotl is in water and the source has an entity or
direct entity and it is not already playing dead: set memory `PLAY_DEAD_TICKS` = 200. The behaviour `PlayDead` requires
being in water, erases the walk and look targets on start and gives the axolotl Regeneration for 200 ticks at amplifier
0; `ValidatePlayDead` decrements the memory each tick and on reaching 0 erases it and the `HURT_BY_ENTITY` memory and
restores the default activity. While playing dead the move control does nothing (the movement tick is skipped). The
exact branch structure of the damage test was read from bytecode order and is marked in Open question 9.

Supporting effect (`onStopAttacking`): when the target of an axolotl dies, the last damage source's entity is a player
and that player is within 20 blocks of the axolotl: Regeneration on the player for `min(2400, 100 + extra)` ticks
(`extra` is the player's remaining Regeneration duration when the current effect ends within 2399 ticks, else 0;
inferred from the branch) at amplifier 0, and Mining Fatigue removed from the player.

Spawn: `checkAxolotlSpawnRules` (§3.2) with category AXOLOTLS; biome `lush_caves` w10 x4-6. Loot: the loot table has no
pools (nothing drops). Animation state metadata is client-side only.

### 4.8 Guardian and elder guardian (`Guardian`, `ElderGuardian`)

| Field | Guardian | Elder guardian |
|---|---|---|
| Type, size | `guardian` 0.85 x 0.85, eye 0.425, range 8 | `elder_guardian` 1.9975 x 1.9975, eye 0.99875, range 10 |
| Attributes | Monster base + `ATTACK_DAMAGE 6`, `MOVEMENT_SPEED 0.5`, `MAX_HEALTH 30` | Guardian attributes + `MOVEMENT_SPEED 0.3`, `ATTACK_DAMAGE 8`, `MAX_HEALTH 80` |
| XP reward | 10 | 10 (inherited field) |
| Beam duration (`getAttackDuration`) | 80 ticks | 60 ticks |
| Persistence | normal | persistent from construction; random stroll interval set to 400 |
| Metadata | 16 moving (Boolean), 17 active attack target (VarInt entity id, 0 none) | same |
| Spawn | placement IN_WATER, predicate §3.2; biome table: ocean monument override (§3.5) | same predicate |

Water path malus 0; `WaterBoundPathNavigation`; movement emission = events only; walk-target value in water is
`10 + light-based cost`. Goals: 4 `GuardianAttackGoal`; 5 `MoveTowardsRestrictionGoal(1)`; 7 `RandomStrollGoal(1, 80)`
(the same instance is "triggered" after damage and after an attack); 8 `LookAtPlayerGoal(Player, 8)`; 8
`LookAtPlayerGoal(Guardian, 12, 0.01)`; 9 `RandomLookAroundGoal`; target 1: `NearestAttackableTargetGoal(LivingEntity, 10, mustSee
true, mustReach false, GuardianAttackSelector)`. The selector accepts players, squids and axolotls whose distance squared
from the guardian is greater than 9.

Attack (`GuardianAttackGoal`): `start`: `attackTime = -10`, stop navigating, look at target. Each tick: stop navigating
and look at the target; if the guardian has no line of sight to the target, drop the target; `attackTime += 1`; at
`attackTime == 0` set the active attack target metadata to the target id and broadcast entity event 21 (attack sound
on clients) unless silent; at `attackTime >= beam duration`: damage = 1, +2 on Hard, +2 more for an elder guardian;
the target takes that damage as `indirectMagic` (source and direct entity = the guardian) and then the guardian performs
its ordinary melee hit (`doHurtTarget`, using `ATTACK_DAMAGE`); finally the target is cleared. `canContinueToUse` for a
non-elder guardian additionally requires the target farther than 3 blocks (distance squared > 9).
`stop`: active attack target metadata = 0, clear target, trigger the stroll goal.

Thorns: `hurtServer` while the guardian is not moving (`isMoving` false), the damage type is not in tag
`avoids_guardian_thorns` and not the thorns type, and the direct entity is a `LivingEntity`: the attacker takes
`hurt(thorns(guardian), 2)`; then the stroll goal is triggered; then the normal damage is applied.

Move control (`GuardianMoveControl`): with a move-to target the guardian turns to the heading (rotation limit 90 degrees
per tick), sets speed = lerp(0.125, current speed, `speedModifier * MOVEMENT_SPEED`), adds a sine "wobble" to the
velocity (`sin((tick + id) * 0.5) * 0.05` along the heading and `sin((tick + id) * 0.75) * 0.05` vertically), looks
ahead toward the target, and sets `isMoving = true`; with no target it sets speed 0 and `isMoving = false`.
In water the travel uses `moveRelative(0.1)`, velocity x 0.9, and sinks by 0.005 per tick when neither moving nor
targeting. Out of water the guardian flops (random hop of `(rand*2-1)*0.4` horizontally, 0.5 up, random yaw).

Elder guardian effect: every 1200 ticks (`(tickCount + entityId) % 1200 == 0`, server side) the elder applies Mining
Fatigue (6000 ticks, amplifier 2) to the players within 50 blocks through `MobEffectUtil.addEffectToPlayersAround` (display
limit 1200; the helper's filter for players that already carry the effect was not read, Open question 7). Each
server player returned by that helper gets Game Event packet 10 with value 1 (curse overlay and sound) unless the
elder guardian is silent. If the elder has no home it sets home = its block position with radius 16.

Loot (guardian): pool 1 `prismarine_shard` `set_count 0-2` `+looting 0-1/level`; pool 2 one of {`cod` w2 (looting, smelt),
`prismarine_crystals` w2 (looting), empty}; pool 3 `player` and `rare(0.025; 0.035, 0.01)` rolls the table
`gameplay/fishing/fish` (smelt modifier). Loot (elder): pool 1 as guardian; pool 2 {`cod` w3, `prismarine_crystals` w2,
empty}; pool 3 `player`: `wet_sponge`; pool 4 `player` and `rare(0.025; 0.035, 0.01)`: `gameplay/fishing/fish`; pool 5
one of {empty w4, `tide_armor_trim_smithing_template` w1} (elder only). The rare thresholds of pool 4 (elder) were
read as the same JSON shape as the guardian's pool 3.

### 4.9 Drowned

The drowned has one home: 20 §4.5 (Overworld hostile mobs). This document keeps only its spawn predicate (§3.2) and its
biome weights (§3.3), which are part of the shared aquatic tables.

### 4.10 Nautilus and zombie nautilus (`AbstractNautilus`, `Nautilus`, `ZombieNautilus`)

| Field | Nautilus | Zombie nautilus |
|---|---|---|
| Type, size | `nautilus` 0.875 x 0.95, eye 0.2751, category WATER_CREATURE | `zombie_nautilus` same size, category MONSTER |
| Attributes | Animal base + `MAX_HEALTH 15`, `MOVEMENT_SPEED 1.0`, `ATTACK_DAMAGE 3`, `KNOCKBACK_RESISTANCE 0.3` | same, with `MOVEMENT_SPEED 1.1` |
| Air | 300 total (`NAUTILUS_TOTAL_AIR_SUPPLY`) | (inherits) |
| Metadata | 16 baby, 17 age locked, 18 flags (Byte; tame bits), 19 owner (optional living-entity UUID), 20 dash (Boolean) | same + 21 variant (`zombie_nautilus_variant` registry id) |
| Spawn | placement IN_WATER, §3.2 nautilus rule; biomes §3.3 | `finalizeSpawn` selects a variant from the `zombie_nautilus_variant` registry using the spawn context; is spawned as a drowned's mount (20 §4.5) |
| Loot | `nautilus_shell` | `rotten_flesh` |

Constants (`AbstractNautilus`): restriction radius small 16, large 32, buffer 8; effect duration 60, refresh 40;
water resistance factor 0.9; in-water speed modifier 0.011; ridden speed 0.0325 in water and 0.02 on land; dash
cooldown 40 ticks, minimum dash duration 5 ticks, dash momentum 1.2 in water and 0.5 on land; inventory 3 rows, slot
offset 500. Move control `SmoothSwimmingMoveControl(85, 10, 0.011, 0, true)`, look control smooth (10), water malus 0.

Interaction (`mobInteract`, adults): a tame nautilus with secondary use opens its inventory; an untamed one fed an item
in tag `nautilus_taming_items` is tamed with probability 1/3 per feeding (`nextInt(3) == 0`; event 7 on success, event 6
on failure; feeding consumes the item); a hurt tamed nautilus fed a food heals by the `feed(...)` rule; a tamed
nautilus without secondary use and without a food in hand is ridden. Breeding: the offspring of a tame nautilus is
tamed with the same owner. `hurtServer` calls `NautilusAi.setAngerTarget` for a living attacker.
Sensors (both nautilus kinds): `NEAREST_LIVING_ENTITIES`, `NEAREST_ADULT`, `NEAREST_PLAYERS`, `HURT_BY`, `NAUTILUS_TEMPTATIONS` (the last sensor's body was not read); extra memories `ANGRY_AT`, `ATTACK_TARGET_COOLDOWN`. Brain (`NautilusAi`): activities CORE (`AnimalPanic(1.6)`, `LookAtTargetSink(45, 90)`, `MoveToTargetSink`, temptation and
charge cooldown countdowns), IDLE (`AnimalMakeLove(NAUTILUS, 0.4, 2)` priority 1, `FollowTemptation` priority 2, ...), FIGHT
(`ChargeAttack(80, ..., 0.6, 2, 12.0, 11.0, dash sound)`). Order: FIGHT, IDLE. The non-player attack cooldown is
uniform integer 2400 to 3600. Tag `nautilus_hostiles` = {pufferfish}. (The remaining idle behaviours were not
expanded; Open question 10.)

### 4.11 Spawn rules by biome and depth (summary)

| Depth rule | Mobs |
|---|---|
| Surface band `seaLevel - 13` to `seaLevel`, water below and above | cod, salmon, pufferfish, squid, dolphin; tropical fish also anywhere in biomes tagged `allows_tropical_fish_spawns_at_any_height` |
| `seaLevel - 25` to `seaLevel - 5` | nautilus |
| `y <= seaLevel - 33`, brightness 0 | glow squid (underground water creature category: in every biome with the entry, §3.3) |
| `nextInt(20) == 0` gate, no sky from below the water | guardian (the ocean monument override of §3.5 restricts guardians to the monument box; the biome lists carry no guardian entries) |
| Y < `seaLevel - 5` and `nextInt(40) == 0` in oceans; `nextInt(15) == 0` in `more_frequent_drowned_spawns` biomes | drowned |
| Block below in `axolotls_spawnable_on` | axolotl (lush caves) |

### 4.12 Turtle

The turtle has one home: 19 §12. Its entity row is in §2.

## 5. Nether mobs

Biome weights are in §3.4; the fortress override in §3.5. "Monster base" = 18 framework: `Monster.createMonsterAttributes`.

### 5.1 Ghast (`Ghast`)

| Field | Value |
|---|---|
| Type | `ghast`, 4.0 x 4.0, eye 2.6, MONSTER, fire immune, `notInPeaceful`, range 10 |
| Attributes | Mob base + `MAX_HEALTH 10`, `FOLLOW_RANGE 100`, `CAMERA_DISTANCE 8`, `FLYING_SPEED 0.06` (the builder line was displayed up to these four) |
| XP | 5; `explosionPower` field starts at 1 |
| Metadata | 16 = charging (Boolean) |
| Move control | `GhastMoveControl`: a countdown `floatDuration` is decremented per tick; at <= 0 it is increased by `nextInt(5) + 2` and, if the straight path to the wanted point is free (`canReach`), the velocity gains `normalize(delta) * (FLYING_SPEED * 5 / 3)`; if the path is blocked the operation is set to WAIT. A "should be stopped" callback can clear the operation and stop the mob in place. |
| Goals | 5 `RandomFloatAroundGoal` (up to 64 attempts to find a free float point); 7 `GhastLookGoal`; 7 `GhastShootFireballGoal` |
| Target | 1 `NearestAttackableTargetGoal(Player, 10, mustSee true, mustReach false, selector |dy| <= 4)` |
| Spawn | `checkGhastSpawnRules` (§3.2), weights §3.4, fortress override none for ghast |
| Reflection | `hurtServer`: when the source is a reflected fireball (a fireball deflected by a player hit) the damage becomes 1000; otherwise normal invulnerability rules |

Shoot goal (`GhastShootFireballGoal`): needs a target within 64 blocks (distance squared < 4096) with line of sight;
otherwise a positive `chargeTime` decays by 1 per tick. Each tick with a valid target: `chargeTime += 1`; at
`chargeTime == 10` world event 1015 (warn sound) unless silent; at `chargeTime == 20`: `view = viewVector`, the fireball
direction is `target position (Y at half height) - (ghast position + view * 4, Y at half height + 0.5)`, a
`LargeFireball` with that normalized direction and the ghast's `explosionPower` is created at
`(x + view.x * 4, y_half + 0.5, z + view.z * 4)`, world event 1016 (shoot sound) unless silent, then `chargeTime = -40`.
The charging flag (metadata 16) is true while `chargeTime > 10`.

Large fireball (`LargeFireball`): type `fireball`, 1 x 1 (builder), explosion on hit with radius `explosionPower`, block
destruction when the mob-griefing game rule is true, source interaction MOB; direct hit on an entity: `hurt(fireball, 6.0)`.
Fireballs are deflectable (`redirectable_projectile` tag) and counted as impact projectiles (§3.6).

Loot: pool 1 `ghast_tear` `set_count 0-1` `+looting 0-1/level`; pool 2 `gunpowder` `set_count 0-2` `+looting 0-1/level`;
pool 3 `music_disc_tears` with `set_count 1` when the killing damage's direct entity is a `fireball` and tagged
`is_projectile` and the kill is `player`.

### 5.2 Blaze and small fireball (`Blaze`, `SmallFireball`)

| Field | Value |
|---|---|
| Type | `blaze`, 0.6 x 1.8, MONSTER, fire immune, `notInPeaceful`, range 8 |
| Attributes | Monster base + `ATTACK_DAMAGE 6`, `MOVEMENT_SPEED 0.23f` (0.23000000417232513 as double), `FOLLOW_RANGE 48` |
| XP | 10 |
| Path malus | water -1, lava 8, fire-in-neighbor 0, fire 0 |
| Metadata | 16 = flags (Byte; the charged flag is one bit of it, (inferred) bit 0) |
| Goals | 4 `BlazeAttackGoal`; 5 `MoveTowardsRestrictionGoal(1)`; 7 `WaterAvoidingRandomStrollGoal(1, 0)`; 8 `LookAtPlayerGoal(Player, 8)`; 8 `RandomLookAroundGoal` |
| Targets | 1 `HurtByTargetGoal` with alert-others; 2 `NearestAttackableTargetGoal(Player, mustSee true)` |
| Height keeping (server `customServerAiStep`) | every 100 ticks pick `allowedHeightOffset = triangle(0.5, 6.891)`; when the target's eye Y is above `own eye Y + allowedHeightOffset` and it can attack, `velocity.y += (0.3 - velocity.y) * 0.3` |
| Falling | when not on ground and `velocity.y < 0`: `velocity.y *= 0.6` (glide) |
| Spawn | `checkAnyLightMonsterSpawnRules` (no light test); fortress override `blaze` w10 x2-3 |

`BlazeAttackGoal` per tick: `attackTime -= 1`; with a target: track `lastSeen` (ticks since line of sight). Cases by
distance squared `d2`: if `d2 < 4.0` and the blaze can reach it: when `attackTime <= 0` set `attackTime = 20` and make an
ordinary melee hit; keep moving toward the target at speed modifier 1. Else if `d2 < followDistance^2` and the blaze
sees the target: when `attackTime <= 0`: `attackStep += 1`; step 1: `attackTime = 60` and the charged flag on; steps 2 to
4: `attackTime = 6`; step 5 (more than 4): `attackTime = 100`, `attackStep = 0`, charged flag off. For `attackStep > 1`
(that is steps 2, 3, 4) fire one `SmallFireball`: world event 1018 unless silent; direction vector
`(triangle(dx, 2.297 * f), dy, triangle(dz, 2.297 * f))` with `f = sqrt(sqrt(d2)) * 0.5`, normalized; spawned at the blaze's
half height + 0.5. So a cycle is: 60 ticks of charging, then three fireballs 6 ticks apart, then a 100-tick pause. In all
cases the blaze keeps looking at the target (10, 10); if it has lost sight for fewer than 5 ticks it moves toward the
target at modifier 1.

Small fireball (`SmallFireball`, type `small_fireball`, 0.3125 x 0.3125): entity hit: remember the target's fire ticks,
set it on fire for 5 s, `hurt(fireball, 5.0)`; if the hurt fails the previous fire ticks are restored. Block hit: when
the owner is a Mob and the mob-griefing rule is on, a fire block is placed in the free neighbouring cell on the hit face.
Any hit discards the projectile.

Loot: pool 1 (`player` condition) `blaze_rod` `set_count 0-1` `+looting 0-1/level`.

### 5.3 Magma cube and the cube-mob family (`AbstractCubeMob`, `MagmaCube`)

Slime and magma cube share `AbstractCubeMob`; `sulfur_cube` (§8.9) also derives from it. Size `s` is stored as a VarInt
(metadata 18 for magma cube; ageable metadata 16/17 precede it) and clamped to `1..127`; natural spawns are at most size 4.

| Quantity | Value |
|---|---|
| Max health | `s * s` |
| Movement speed | `0.2f + 0.1f * (float) s` in float32, widened to double and stored as the attribute base by `setSize` (size 1: 0.30000001192092896; size 2: 0.4000000059604645; size 4: 0.6000000238418579) |
| Attack damage attribute | `s` (magma cube and slime) |
| Armor | magma cube: `3 * s` |
| XP reward | `s` |
| Melee damage dealt | attribute value; magma cube adds 2 (`getAttackDamage` + 2) |
| Spawn size (`setSpawnSize`) | `r = nextInt(3)`; if `r < 2` and `nextFloat() < 0.5 * specialMultiplier` then `r += 1`; size = `1 << r` (1, 2 or 4). `specialMultiplier` is the local difficulty special multiplier (18 framework: difficulty). |
| Jump delay | `nextInt(20) + 10` ticks; magma cube x 4; the aggressive move control divides the delay by 3 |
| Magma cube jump | jump velocity = base jump power + `0.1 * s` |
| Split on death | when removed dead with `s > 1`: `2 + nextInt(3)` children (2 to 4), each size `s / 2` (integer), placed at offsets `((i % 2) - 0.5) * (width/2)` and `((i / 2) - 0.5) * (width/2)` around the parent, at y + 0.5, random yaw, same team, full health |
| Contact damage | `canDealDamage` (magma cube: whenever the AI is effective; slime: not when `s == 1`); damage is applied through `push` (only for iron golems) and `playerTouch`, subject to alive, teams, melee range and line of sight |
| Squish | client animation only; targets 1 when landing, -0.5 on ground transition; decay x 0.9 (magma cube), x 0.6 (slime) |

Type `magma_cube`: 0.52 x 0.52 at size 1 (dimensions scale with size), eye 0.325, MONSTER, fire immune,
`spawnDimensionsScale`, `notInPeaceful`, range 8; attributes Monster base + `MOVEMENT_SPEED 0.2` (then overridden by
`setSize`). Metadata 16 baby, 17 age locked, 18 size. Particle `flame` on landing. Goals: 1 `CubeMobFloatGoal`; 2
`CubeMobAttackGoal`; 4 `CubeMobRandomDirectionGoal`; 5 `CubeMobKeepOnJumpingGoal`; targets 1 `NearestAttackableTarget(Player, 10,
true, false, |dy| <= 4)`; 3 `NearestAttackableTarget(IronGolem, true)`. Move control `CubeMobMoveControl`: turns to the wanted
yaw (limit 90 per tick); on the ground it counts `jumpDelay` down and jumps when it reaches 0, resetting it from
`getJumpDelay`. Spawn: `checkMagmaCubeSpawnRules` (§3.2); weights §3.4; fortress `magma_cube` w3 x4.

Loot (magma cube): one pool; entry `magma_cream` with `set_count -2-1` and looting, only when the killer is not a frog and the dying magma cube's size is at least 2 (`cube_mob` type-specific predicate `size >= 2`); three alternative froglight entries apply when a frog with
the matching variant (`warm` = `pearlescent_froglight`, `cold` = `verdant_froglight`, `temperate` = `ochre_froglight`)
kills it (`set_count 1`).

### 5.4 Wither skeleton (`WitherSkeleton`)

Type `wither_skeleton`, 0.7 x 2.4, eye 2.1, MONSTER, fire immune, `immuneTo` (block tag), range 8. A skeleton variant: base
attributes and bow-less melee behaviour come from `AbstractSkeleton` (documented with skeletons in 20; the attack damage
base is overwritten at spawn). `finalizeSpawn`: attack damage base = 4.0, then the weapon goal is re-evaluated; spawn
equipment: main hand `stone_sword`; the equipment-enchantment hook is overridden (no random enchantments). Extra target:
3 `NearestAttackableTarget(AbstractPiglin, true)`. Melee hit (`doHurtTarget`): after a successful hit a living target
gets Wither for 200 ticks (amplifier 0, source = the skeleton). Metadata: none beyond skeleton base. Spawn
`checkMonsterSpawnRules`; fortress w8 x5. Loot: `coal` `set_count -1-1` `+looting 0-1/level`; `bone` `set_count 0-2`
`+looting`; `wither_skeleton_skull` with `player` and `rare(0.025; 0.035, 0.01)`. XP: skeleton default (20).

### 5.5 Piglin family

Common to `AbstractPiglin`: pick-up loot on by default; opens doors; path malus fire-in-neighbor 16, fire -1;
metadata 16 = immune to zombification (Boolean).

Zombification (`isConverting`): not immune, AI on, and the environment attribute `piglins_zombify` is true at the
mob's position (the attribute's value per dimension was not read; Open question 4). While converting, `timeInOverworld`
increases once per server AI step; when it exceeds 300 and the difficulty is not Peaceful the conversion sound plays and
the mob becomes a `zombified_piglin` (conversion parameters `single(self, 1, 1)` for piglins and `single(self, 1, 0)` for hoglins; what the two
flags mean was not read; the converted mob receives Nausea for 200 ticks, amplifier 0); a piglin first cancels admiring and drops its inventory items. Not
converting resets `timeInOverworld` to 0. Hoglins do the same with `zoglin` (§5.6).

#### 5.5.1 Piglin (`Piglin`, `PiglinAi`)

| Field | Value |
|---|---|
| Type | `piglin`, 0.6 x 1.95, eye 1.79, MONSTER (not `notInPeaceful`), range 8 |
| Attributes | Monster base + `MAX_HEALTH 16`, `MOVEMENT_SPEED 0.35f` (0.3499999940395355 as double), `ATTACK_DAMAGE 5` |
| XP | 5 |
| Inventory | 8 slots (slot offset 300); metadata 16 immune, 17 baby, 18 charging crossbow, 19 dancing |
| Spawn (`finalizeSpawn`) | unless `STRUCTURE`: baby with probability 0.2; an adult gets a main-hand weapon: a crossbow when `nextFloat() < 0.5`, else `nextInt(10) == 0` gives a golden spear, else a golden sword; each of helmet, chestplate, leggings, boots is a golden piece independently with probability 0.1 (adults only); `PiglinAi.initMemories` sets `HUNTED_RECENTLY` with expiry uniform 30 to 120 s |
| Spawn rule | `checkPiglinSpawnRules`, weights §3.4 |
| Loot table | none (an empty pool list; items come from equipment and inventory) |

Brain activities (18 framework: Brain). Activity selection order: ADMIRE_ITEM, FIGHT, AVOID, CELEBRATE, RIDE, IDLE
(first valid). The aggressive flag follows the `ATTACK_TARGET` memory; the dancing flag follows `DANCING` while a
`CELEBRATE_LOCATION` exists.

| Activity | Behaviours (priority order) |
|---|---|
| CORE | `LookAtTargetSink(45, 90)`, `MoveToTargetSink`, `InteractWithDoor`, baby avoid nemesis (5 to 7 s), avoid zombified (5 to 7 s), `StopHoldingItemIfNoLongerAdmiring`, `StartAdmiringItemIfSeen(119)`, `StartCelebratingIfTargetDead(300 ticks, adults)`, `StopBeingAngryIfTargetDead` |
| IDLE (priority 10) | `SetEntityLookTarget(14)`, `StartAttacking` (adults), `StartHuntingHoglin` (when allowed), avoid repellent, baby sometimes rides a baby hoglin, idle look and idle movement (speed 0.6), `SetLookAndInteract(Player, 4)` |
| FIGHT | `StopAttackingIfTargetInvalid`, `BackUpIfTooClose(5, 0.75)` (crossbow users), `SetWalkTargetFromAttackTargetIfTargetOutOfReach(1)`, spear approach (1, 10), spear attack (1, 1, 2), spear retreat (1), `MeleeAttack(20)`, `CrossbowAttack`, `RememberIfHoglinWasKilled`, erase `ATTACK_TARGET` when invalid |
| CELEBRATE | avoid repellent, look target 14, `StartAttacking`, go to `CELEBRATE_LOCATION` (radius 2 at speed 1.0, radius 4 at speed 0.6 while dancing), one-of {look at piglin 8, stroll 0.6, do nothing 10 to 20 ticks} |
| ADMIRE_ITEM | `GoToWantedItem(speed 1, within 9)`, `StopAdmiringIfItemTooFarAway(9)`, `StopAdmiringIfTiredOfTryingToReachItem(200, 200)` |
| AVOID | `SetWalkTargetAwayFrom(AVOID_TARGET, speed 1.0, distance 12)`, idle look and movement, erase when no longer valid (retreat 5 to 20 s) |
| RIDE | `Mount(0.8)`, look target 8, dismount rules (8 blocks), baby rides baby hoglins for 10 to 30 s after waiting 10 to 40 s |

Sensors (`Brain` provider of `Piglin`: `NEAREST_LIVING_ENTITIES`, `NEAREST_PLAYERS`, `NEAREST_ITEMS`, `HURT_BY`, `PIGLIN_SPECIFIC_SENSOR`; extra registered
memories `UNIVERSAL_ANGER`, `ATE_RECENTLY`, `SPEAR_FLEEING_TIME`, `SPEAR_FLEEING_POSITION`, `SPEAR_CHARGE_POSITION`, `SPEAR_ENGAGE_TIME`):

| Sensor | Rule |
|---|---|
| `NEAREST_LIVING_ENTITIES` | all living entities other than itself, alive, in the box inflated by `FOLLOW_RANGE` on every axis, sorted by distance; the visible subset (line of sight) forms `NEAREST_VISIBLE_LIVING_ENTITIES` |
| `NEAREST_PLAYERS` | non-spectator players within `FOLLOW_RANGE`, sorted by distance; derived memories for the visible targetable and the visible attackable players |
| `NEAREST_ITEMS` | item entities in the box inflated `(32, 16, 32)`, sorted by distance; the nearest one the piglin wants to pick up (`wantsToPickUp`), within 32 blocks and in line of sight, becomes `NEAREST_VISIBLE_WANTED_ITEM` |
| `PIGLIN_SPECIFIC_SENSOR` | sets `NEAREST_REPELLENT` = the first block (by Manhattan-distance box of 8 horizontal, 4 vertical) in block tag `piglin_repellents`. From the visible living entities: the first baby hoglin; the first adult hoglin that `canBeHunted` (`NEAREST_VISIBLE_HUNTABLE_HOGLIN`) and the count of visible adult hoglins; the first baby piglin; every adult piglin and piglin brute (adult list, with a count); the first player that is not wearing safe armor and that the piglin can attack (`NEAREST_TARGETABLE_PLAYER_NOT_WEARING_GOLD`); the first non-spectator player holding a loved item (`NEAREST_PLAYER_HOLDING_WANTED_ITEM`); the first wither skeleton or Wither (`NEAREST_VISIBLE_NEMESIS`); the first zombified creature (`NEAREST_VISIBLE_ZOMBIFIED`, per `PiglinAi.isZombified`); and `NEARBY_ADULT_PIGLINS` from `findNearbyAdultPiglins`. |

Bartering and loved items (read from `PiglinAi` and tags):

- Currency: `gold_ingot`. A player can hand one to an adult piglin (`mobInteract`) when the piglin is an adult, not already
  admiring and `ADMIRING_DISABLED` is not set: the player's stack loses 1, the item moves to the piglin's off hand, the
  memory `ADMIRING_ITEM` is set for 119 ticks (`ADMIRE_DURATION`). A piglin also picks up dropped gold ingots it can reach
  (`wantsToPickup` accepts barter currency when its off hand does not already hold a loved item), and picks up gold
  nuggets, food (tag `piglin_food`: `porkchop`, `cooked_porkchop`, only when it has not eaten recently and has room), other
  loved items (when its off hand holds no loved item) and equipment it prefers. It refuses items in `piglin_repellents`,
  and a baby ignores items in `ignored_by_piglin_babies` (`leather`). While it has an attack target and admiring is
  disabled it does not pick up currency.
- When the admiring period ends (`StopHoldingItemIfNoLongerAdmiring`), the held ingot is consumed and the piglin throws
  the items of one roll of the loot table `gameplay/piglin_bartering` (loot context: this entity; param set `piglin
  barter`): toward the nearest visible player when there is one, otherwise toward a random nearby position; the throw
  swings the off hand and each item is thrown with the generic item-throw behaviour at the target position + 1 block up.
- Admiring cancellation (`cancelAdmiring` / hurt): the memory is erased, `ADMIRING_DISABLED` is set for 400 ticks and,
  if the piglin was hurt by a living entity, `AVOID_TARGET` for 100 ticks is set for a baby or a piglin outnumbered by
  hoglins (the exact branch conditions were not expanded; Open question 4).
- `piglin_loved` (items that make a piglin choose to hold something in the off hand and that count as loved): tag
  `gold_ores` plus `gold_block`, `gilded_blackstone`, `light_weighted_pressure_plate`, `gold_ingot`, `bell`, `clock`,
  `golden_carrot`, `glistering_melon_slice`, `golden_apple`, `enchanted_golden_apple`, the four golden armor pieces,
  `golden_horse_armor`, `golden_nautilus_armor`, `golden_sword`, `golden_spear`, `golden_pickaxe`, `golden_shovel`,
  `golden_axe`, `golden_hoe`, `raw_gold`, `raw_gold_block`, `golden_dandelion`. `piglin_repellents` = `soul_torch`,
  `soul_lantern`, `soul_campfire` (the item tag; the block tag of the same name in §3.8 is what the sensor searches within
  8 horizontal and 4 vertical blocks).
- Safe armor: `PiglinAi.isWearingSafeArmor` is true when any armor slot holds an item in tag `piglin_safe_armor` (the four golden armor
  pieces). `PiglinSpecificSensor` skips players for which it is true when it fills `NEAREST_TARGETABLE_PLAYER_NOT_WEARING_GOLD`
  (the sensor also requires `piglin.canAttack(player)`), so a player wearing any golden piece is never chosen from that memory.
- Anger spreading (`angerNearbyPiglins(player, requireLineOfSight)`): all piglins within a 16-block box around the player
  (when line of sight is required, only those that can see the player): with the `universal_anger` game rule they target
  the nearest targetable player, otherwise they target this player. `ANGER_DURATION` 600 ticks; `PLAYER_ANGER_RANGE` 16.

Barter table `gameplay/piglin_bartering` (one pool, one roll, total weight 469):

| Item | Weight | Count / modifier |
|---|---|---|
| `book` | 5 | enchant randomly with `soul_speed` |
| `iron_boots` | 8 | enchant randomly with `soul_speed` |
| `potion` | 8 | potion `fire_resistance` |
| `splash_potion` | 8 | potion `fire_resistance` |
| `potion` | 10 | potion `water` |
| `iron_nugget` | 10 | 10-36 |
| `ender_pearl` | 10 | 2-4 |
| `dried_ghast` | 10 | 1 |
| `string` | 20 | 3-9 |
| `quartz` | 20 | 5-12 |
| `obsidian` | 40 | 1 |
| `crying_obsidian` | 40 | 1-3 |
| `fire_charge` | 40 | 1 |
| `leather` | 40 | 2-4 |
| `soul_sand` | 40 | 2-8 |
| `nether_brick` | 40 | 2-8 |
| `spectral_arrow` | 40 | 6-12 |
| `gravel` | 40 | 8-16 |
| `blackstone` | 40 | 8-16 |

Timers summary: admire 119 ticks; admiring disabled 400; anger 600; celebration 300; hunt gap 30 to 120 s uniform; baby
flee after being hit 100; "hit by player" memory timeout 400; eat cooldown 200; walk-to-item limits 9 blocks and 200 ticks;
retreat 5 to 20 s; avoid zombified 5 to 7 s; ride start interval 10 to 40 s and ride duration 10 to 30 s; dance
probability for a celebration 0.1 per check (`wantsToDance`: target is a hoglin and a thread-local roll below 0.1).

#### 5.5.2 Piglin brute (`PiglinBrute`, `PiglinBruteAi`)

Type `piglin_brute`, 0.6 x 1.95, eye 1.79, MONSTER, `notInPeaceful`, range 8. Attributes: Monster base +
`MAX_HEALTH 50`, `MOVEMENT_SPEED 0.35f` (0.3499999940395355), `ATTACK_DAMAGE 7`, `FOLLOW_RANGE` (the field `TARGETING_RANGE` is 12.0; the
builder's number was cut off in the displayed line; read as 12). XP 20. Never hunts (`canHunt` false); does not
barter. Spawn equipment: `golden_axe`. Memory `HOME` is set to the spawn position (dimension + position) in
`PiglinBruteAi.initMemories`. Sensors: `NEAREST_LIVING_ENTITIES`, `NEAREST_PLAYERS`, `NEAREST_ITEMS`, `HURT_BY`, `PIGLIN_BRUTE_SPECIFIC_SENSOR` (the closest visible wither skeleton or Wither becomes `NEAREST_VISIBLE_NEMESIS`; `NEARBY_ADULT_PIGLINS` is refreshed); extra memory `NEAREST_VISIBLE_ADULT_PIGLINS`. Brain: CORE (`LookAtTargetSink(45, 90)`, `MoveToTargetSink`, `InteractWithDoor`,
`StopBeingAngryIfTargetDead`), IDLE (`StartAttacking`, idle look, idle movement, `SetLookAndInteract(Player, 4)`), FIGHT
(`StopAttackingIfTargetInvalid`, `SetWalkTargetFromAttackTargetIfTargetOutOfReach(1)`, `MeleeAttack(20)`). `hurtServer`
with a living attacker calls the brute's `wasHurtBy`. It converts to a zombified piglin like a piglin (immunity flag at
metadata 16). Loot: none. Bastion remnants place them (Open question 3).

#### 5.5.3 Zombified piglin (`ZombifiedPiglin`)

Type `zombified_piglin`, 0.6 x 1.95, eye 1.79, MONSTER, fire immune, `notInPeaceful`, range 8. A zombie: attributes are
`Zombie.createAttributes` (documented with zombies in 20: follow range 35, speed 0.23, attack damage 3, armor 2, spawn
reinforcements chance) with `SPAWN_REINFORCEMENTS_CHANCE 0`, `MOVEMENT_SPEED 0.23f` (0.23000000417232513), `ATTACK_DAMAGE 5`. Baby 0.49 x 0.98 eye 0.78.
Goals (`addBehaviourGoals`): 1 `SpearUseGoal(1, 1, 10, 2)`; 2 `ZombieAttackGoal(1, false)`; 7
`WaterAvoidingRandomStrollGoal(1)`; targets 1 `HurtByTargetGoal` + alert others; 2 `NearestAttackableTarget(Player, 10, true,
false, anger test)`; 3 `ResetUniversalAngerTargetGoal(true)`.

Anger: persistent (angry at the entity that hurt it, stored as a reference and an end time). Duration on start: uniform
20 to 39 seconds. First-anger sound delay uniform 0 to 1 s. While angry the speed has a transient `+0.05` modifier
(`attacking`, add value). `alertOthers` runs every 4 to 6 s while it has a target: every zombified piglin within
`FOLLOW_RANGE` blocks horizontally and 10 vertically that has no target and is not allied to the target takes the same
target. A zombified piglin keeps preventing player rest while angry at that player. Spawn equipment: `nextInt(20) == 0` gives a golden spear, otherwise a golden sword.
Spawn rule `checkZombifiedPiglinSpawnRules`; weights §3.4 (`nether_wastes` w100 x4, `crimson_forest` w1 x2-4, fortress w5
x4). Loot: `rotten_flesh` `set_count 0-1` `+looting`; `gold_nugget` `set_count 0-1` `+looting`; `gold_ingot` with `player` and
`rare(0.025; 0.035, 0.01)`. Metadata 16 baby, 17 special type, 18 conversion.

### 5.6 Hoglin and zoglin (`Hoglin`, `HoglinAi`, `HoglinBase`, `Zoglin`)

| Field | Hoglin | Zoglin |
|---|---|---|
| Type, size | `hoglin` 1.3964844 x 1.4, MONSTER, `notInPeaceful`, range 8 | `zoglin` same size, MONSTER, fire immune, `notInPeaceful` |
| Attributes | Monster base + `MAX_HEALTH 40`, `MOVEMENT_SPEED 0.3f` (as double 0.30000001192092896), `KNOCKBACK_RESISTANCE 0.6f`, `ATTACK_DAMAGE 6`, `ATTACK_KNOCKBACK 1` | `MAX_HEALTH 40`, `KNOCKBACK_RESISTANCE 0.6`, `ATTACK_DAMAGE 6`, `ATTACK_KNOCKBACK 1`, speed 0.3 when fighting |
| Baby damage | 0.5 | 0.5 |
| XP | 5 | 5 |
| Metadata | 16 baby, 17 age locked, 18 immune to zombification | 16 baby |
| Zombification | `timeInOverworld` > 300 while converting: becomes a zoglin (conversion flags `(1, 0)`, Nausea 200 ticks) | - |
| Spawn | `checkHoglinSpawnRules`; baby probability 0.2; weights §3.4 (`crimson_forest` w9 x3-4) | not in any biome list read; fortress none |
| Loot | `porkchop` `set_count 2-4` `+looting` smelt; `leather` `set_count 0-1` `+looting` | `rotten_flesh` `set_count 1-3` `+looting` |

Melee (`doHurtTarget`): `attackAnimationRemainingTicks = 10`, broadcast entity event 4, attack sound, then
`HoglinBase.hurtAndThrowTarget`: damage `A = ATTACK_DAMAGE`; for an adult with `A > 0` the damage is `A / 2 + nextInt(A)`
(integer `A`), for a baby it is `A` (the baby attack value 0.5 is applied by `ageBoundaryReached`, below); mob-attack damage; on success
post-attack enchantment effects and, for adults only, a throw: `k = ATTACK_KNOCKBACK - target KNOCKBACK_RESISTANCE`; if
`k > 0`: direction = horizontal vector from the hoglin to the target, normalized, scaled by `k * (nextFloat * 0.5 + 0.2)`,
rotated about Y by `(nextInt(21) - 10)` degrees, vertical `k * nextFloat * 0.5`; applied with `push`, velocity sync on.

`ageBoundaryReached` (hoglin): becoming a baby sets `xpReward = 3` and the attack-damage base to 0.5; growing up restores `xpReward = 5` and the base 6.0.

Hoglin sensors: `NEAREST_LIVING_ENTITIES`, `NEAREST_PLAYERS`, `NEAREST_ADULT`, `HOGLIN_SPECIFIC_SENSOR`: it sets `NEAREST_REPELLENT` = the first block in tag `hoglin_repellents` (§3.8) in the Manhattan box (8, 4); among visible adult piglins and adult hoglins it records the first adult piglin (`NEAREST_VISIBLE_ADULT_PIGLIN`) and the number of visible adult piglins, and the list and number of visible adult hoglins. Zoglin sensors: `NEAREST_LIVING_ENTITIES`, `NEAREST_PLAYERS` only.

Hoglin brain activities: CORE (`LookAtTargetSink(45, 90)`, `MoveToTargetSink`); IDLE priority 10 (`BecomePassiveIfMemoryPresent(NEAREST_REPELLENT,
200)`, `AnimalMakeLove(HOGLIN, 0.6, 2)`, `StartAttacking`, `SetWalkTargetAwayFrom(NEAREST_VISIBLE_ADULT_PIGLIN, speed 0.4,
distance 8)`, `SetEntityLookTargetSometimes(8, 30-60)`, `BabyFollowAdult(range, 0.6)`, idle movement); FIGHT priority 10
(`BecomePassiveIfMemoryPresent`, `AnimalMakeLove`, `SetWalkTargetFromAttackTargetIfTargetOutOfReach(1)`, `MeleeAttack(40)` for
adults / `MeleeAttack(15)` for babies, `StopAttackingIfTargetInvalid`, erase target); AVOID priority 10 (`SetWalkTargetAwayFrom(AVOID_TARGET, 1.3, 15)`, idle movement, look,
erase). Order: FIGHT, AVOID, IDLE. Zoglin constants: attack interval 40 (baby 15), `ATTACK_DURATION` 200 ticks of
memory, speed when idling 0.4. (The zoglin brain was not expanded further; the melee is the hoglin one.)

### 5.7 Strider (`Strider`)

| Field | Value |
|---|---|
| Type | `strider`, 0.9 x 1.7, CREATURE, fire immune, range 10; baby 0.45 x 0.85 eye 0.4375 |
| Attributes | Animal base + `MOVEMENT_SPEED 0.175f` (float32; as double 0.17499999701976776) |
| Metadata | 16 baby, 17 age locked, 18 boost time (VarInt), 19 suffocating (Boolean) |
| Path malus | water -1, lava 0, fire-in-neighbor 0, fire 0 |
| Lava walking | `canStandOnFluid(lava)`; `floatStrider` (each tick): in lava: when the block above its position is lava the velocity becomes `0.5 * v + (0, 0.05, 0)` (it rises), otherwise `onGround` is set true so it stands on the surface (nesting of the surrounding collision-shape test inferred) |
| Warm blocks | tag `strider_warm_blocks` = {`lava`} (blocks) |
| Suffocating | every non-AI-disabled tick: not suffocating when the block at its position or the block below is warm, or the lava fluid height at its position is above 0, or it is the rider of a non-suffocating strider; otherwise `setSuffocating(true)`. Suffocating adds a transient speed modifier of -0.34 (multiply-base) named `suffocating` (a cold strider is slow and shivers) |
| Food, tempt | food `warped_fungus`; temptation items = `warped_fungus` and `warped_fungus_on_a_stick` |
| Saddle | slot `saddle`; tag `can_equip_saddle` contains `strider`; right-clicking a saddled, rider-free strider with no food in hand and without secondary use makes the player ride (server: `startRiding`); a saddle item uses the generic equip interaction |
| Steering | `ItemBasedSteering` with boost time metadata 18; while ridden: `STEERING_MODIFIER` 0.55 (0.35 when suffocating); the held-item condition for steering was not read (Open question 11). Rotation: the strider yaw follows the rider's, pitch = rider pitch x 0.5 |
| Goals | 1 `PanicGoal(1.65)`; 2 `BreedGoal(1)`; 3 `TemptGoal(1.4, temptation items, false)`; 4 `StriderGoToLavaGoal(1)`; 5 `FollowParentGoal(1)`; 7 `RandomStrollGoal(1, 60)`; 8 `LookAtPlayerGoal(Player, 8)`; 8 `RandomLookAroundGoal`; 9 `LookAtPlayerGoal(Strider, 8)` |
| Walk-target value | lava: 10; else 0 when in lava, else the base value |
| Sounds on tempt/panic | tempted: happy sound with probability 1/140 per tick; panicking: retreat sound with probability 1/60 |
| Spawn | placement IN_LAVA, `checkStriderSpawnRules`; weights §3.4 (`creature` w60 x1-2 in all four Nether forest/wastes/valley/delta biomes) |
| `finalizeSpawn` (adults) | with probability 1/30 (and monsters allowed): a `zombified_piglin` jockey (reason JOCKEY) rides it with `warped_fungus_on_a_stick` in the main hand, the strider gets a `saddle` (guaranteed drop); otherwise with probability 1/10 a baby strider (age -24000) rides it; ordinary spawns use group data 0.5 baby chance |
| Loot | `string` `set_count 2-5` `+looting` |

### 5.8 Skeleton variants in the Nether

Skeletons (20) spawn in `soul_sand_valley` (w20 x5, with `spawn_costs`) and in fortress pieces (w2 x5). Wither skeletons spawn
only through the fortress override (w8 x5); no biome list read contains `wither_skeleton`. `piglin` spawns in `nether_wastes`
w15 x4 and `crimson_forest` w5 x3-4 (§3.4); bastion placement is Open question 3.

## 6. End mobs and the Ender Dragon fight

Enderman variants and behaviour are in 20 (cross-reference: enderman, 20). In the End biomes the only list entry is
`enderman` w10 x4 (§3.4); in the Nether it is `enderman` w1 x4 (nether wastes, soul sand valley, warped forest).

### 6.1 Endermite

The endermite has one home: 20 (Overworld hostile mobs, endermite). The thrown ender pearl that creates endermites belongs to 17.

### 6.2 Shulker and shulker bullet (`Shulker`, `ShulkerBullet`)

| Field | Value |
|---|---|
| Type | `shulker`, size 1.0 x 1.0 (builder; the real box varies with the peek amount via `getProgressAabb`), eye 0.5, MONSTER, fire immune, `canSpawnFarFromPlayer`, range 10 |
| Attributes | Mob base + `MAX_HEALTH 30`; while closed (peek amount 0) a transient armor modifier `+20` (`covered`, add value) |
| XP | 5 |
| Metadata | 16 attach face (Direction, default DOWN), 17 peek amount (Byte, raw 0 to 100), 18 colour (Byte; a dye id; 16 = no colour, the default, constants `NO_COLOR` and `DEFAULT_COLOR` are both 16) |
| Constants | peek speed 0.05 per tick, max scale 3.0, max lid open 1.0, teleport tries: the constant `TELEPORT_STEPS` is 6 but the loop in `teleportSomewhere` runs 5 attempts, max teleport distance 8, scan radius for the other shulkers 8, other shulker limit 5 |
| Goals | 1 `LookAtPlayerGoal(Player, 8, 0.02, true)`; 4 `ShulkerAttackGoal`; 7 `ShulkerPeekGoal`; 8 `RandomLookAroundGoal` |
| Targets | 1 `HurtByTargetGoal(own class)` + alert others (no alert); 2 `ShulkerNearestAttackGoal` (players); 3 `ShulkerDefenseAttackGoal` (target type `Enemy`) |
| Spawn | placement NO_RESTRICTIONS, predicate `Mob.checkMobSpawnRules`; no biome list entry; placed by End city generation (not read) |
| Loot | `shulker_shell` with `chance 0.5` unenchanted and `0.5625 + 0.0625 per level above first` with looting (no `player` condition) |

Peek: the logical peek value is `rawPeek * 0.01` (0 closed, up to 1). Each tick the current peek moves toward it by 0.05
(clamped) and, when it changes, the entity box and the "pushing" of entities in the opened lid region run (each entity
in the swept box that is not a shulker, is not `noPhysics` and is not a passenger of the same vehicle is moved along the
opposite of the attach face by `(newPhysical - oldPhysical) * scale`, where `physical(p) = 0.5 - sin((0.5 + p) * pi) * 0.5`).
`ShulkerPeekGoal`: usable when it has no target and `nextInt(40) == 0` and it can stay at its position and face;
`start`: `peekTime = 20 * (1 + nextInt(3))` ticks and raw peek = 30; `stop` (when it gets a target): raw peek 0 (closes).
`ShulkerAttackGoal` (`canUse`: there is a living target and the difficulty is not Peaceful); `start`: `attackTime = 20` and raw peek 100 (fully open); `stop`: raw peek 0; per tick: only when the difficulty is not Peaceful; needs a target within 20 blocks (distance squared < 400),
else the target is dropped; counts `attackTime` down; at 0 launches a `ShulkerBullet` toward the target (axis = the
axis of its attach face) with the shoot sound (volume 2.0) and sets `attackTime = 20 + (nextInt(10) * 20) / 2`.

Attaching: the shulker stands on a face of a block; if `canStayAt(position, attach face)` becomes false (server tick,
not a passenger) it calls `findNewAttachment` (tries the six directions in order for a surface it can stay on).
`canStayAt` requires the cell not to be blocked, the neighbouring block to be standable on the opposite face, and the
box of the shulker (with the peek extension) to be collision-free.

Teleport (`teleportSomewhere`): requires AI on and alive; up to 5 attempts at an offset of `randomBetweenInclusive(-8, 8)`
on each axis from the current position: the cell must be above the world minimum, empty (air), inside the world border, the
box collision-free, a valid attachable face must exist (`findAttachableSurface`), and the block on the attach side not in
tag `shulker_does_not_teleport_to`. On success: unride, set the attach face, play the teleport sound, move to the cell
centre bottom, `TELEPORT` game event, world event 2016 with the packed movement difference (8, 8, 8), raw peek = 0,
target cleared.

Damage (`hurtServer`): arrow-type direct hits while closed are ignored (returns false). When damage is taken: if health
is below half the maximum, with probability 1/4 it teleports; otherwise if the damage is a projectile and the direct
entity is a `shulker_bullet`, the shulker may split (`hitByShulkerBullet`): when it is not closed or it can teleport
away; count the shulkers within an 8-block inflated box (including itself, a limit of 5 is declared as `OTHER_SHULKER_LIMIT`); compute `p = (count - 1) / 5` and, when `nextFloat() < p`, a new shulker of the same colour (reason BREEDING) is created at its previous position (it teleported away first).

Shulker bullet (`ShulkerBullet`, type `shulker_bullet`, 0.3125 x 0.3125, range 8, no metadata): speed constant 0.15; it homes on
its target (velocity eased toward a target delta that grows by `x 1.025` per tick clamped to `[-1, 1]`), takes steps
of `flightSteps = 10 + nextInt(5) * 10` along one axis at a time (`selectNextMoveDirection`), then re-aims. Hit on an
entity: `hurt(mobProjectile, 4.0)` and, if it lands and the victim is living, Levitation for 200 ticks (source = the
shulker). Bullets can be destroyed by being hit (`hurtServer`).

### 6.3 End crystal (`EndCrystal`)

Type `end_crystal`, 2.0 x 2.0 (builder), no loot table, fire immune, no update interval, no delta tracking, range 16.
Metadata (own, from index 8): 8 beam target (optional block position), 9 show bottom (Boolean, default true).
`blocksBuilding` true. Each server tick: if the level has a dragon fight and the block at the crystal's position is air,
a fire block is placed there. Damage (`hurtServer`): ignored if invulnerable or the attacker is an ender dragon; otherwise
the first hit removes the crystal (`KILLED`) and, unless the damage already is an explosion, explodes with power 6.0,
interaction BLOCK, attributed to the damager; then `EnderDragonFight.onCrystalDestroyed` runs. `permanentlyInvulnerable`
(set for the respawn pillars) makes it invulnerable to base damage. NBT: `beam_target`, `ShowBottom`.

### 6.4 The Ender Dragon (`EnderDragon`)

| Field | Value |
|---|---|
| Type | `ender_dragon`, 16.0 x 8.0, MONSTER (no `notInPeaceful`), fire immune, range 10 |
| Attributes | Mob base + `MAX_HEALTH 200`, `CAMERA_DISTANCE 16` |
| Physics | `noPhysics` true: it ignores blocks for collision and instead breaks them (below) |
| Metadata | 16 = current phase id (VarInt) |
| Spawn | placement ON_GROUND with `Mob.checkMobSpawnRules`; in practice only created by the fight (reason EVENT) |
| Persistence of state | NBT `DragonPhase` (phase id), `DragonDeathTime`, `sitting_damage_received` |
| Loot | the loot table has no pools; XP only (§6.4.6) |

Body parts (`EnderDragonPart`, name, width x height): head 1 x 1, neck 3 x 3, body 5 x 3, three tails 2 x 2, two wings
4 x 2. Part positions are recomputed every tick from the "flight history", a ring of 64 samples `(y, yaw)` recorded each tick
(`get(n)` = the sample n ticks ago). Let `yaw = yRot in radians`, `pitchTerm = (hist(5).y - hist(10).y) * 10` in radians,
`cp = cos(pitchTerm)`, `sp = sin(pitchTerm)`, `hy` = head Y offset (`-1` when the phase is sitting, else
`hist(5).y - hist(0).y`), `sy = sin(yaw)`, `cy = cos(yaw)`, and for head and neck `yawH = yaw - yRotA * 0.01` (radians),
`sh = sin(yawH)`, `ch = cos(yawH)`. Offsets from the dragon position:

| Part | dx | dy | dz |
|---|---|---|---|
| body | `sy * 0.5` | 0 | `-cy * 0.5` |
| wing 1 | `cy * 4.5` | 2.0 | `sy * 4.5` |
| wing 2 | `-cy * 4.5` | 2.0 | `-sy * 4.5` |
| head | `sh * 6.5 * cp` | `hy + sp * 6.5` | `-ch * 6.5 * cp` |
| neck | `sh * 5.5 * cp` | `hy + sp * 5.5` | `-ch * 5.5 * cp` |
| tail i (0, 1, 2) | `-((sy * 1.5) + sin(a_i) * L_i) * cp` | `(hist(12 + 2i).y - hist(5).y) - (L_i + 1.5) * sp + 1.5` | `((cy * 1.5) + cos(a_i) * L_i) * cp` |

where `L_i = (i + 1) * 2`, `a_i = yaw + wrap(hist(12 + 2i).yaw - hist(5).yaw) in radians`. (The part positions are applied by
`tickPart`; offsets of all eight parts are relative to the main entity position.)

Wing and head contact each tick when the dragon was not hurt recently (server): living entities in the box of each wing
inflated by (4, 2, 4) and moved down 2 are knocked back (below); living entities in the head box inflated by 1 and in
the neck box inflated by 1 take 10.0 `mobAttack` damage (teams allowing) and post-attack enchantment effects.
Knock back (wing): for each living entity: direction from the body-centre (x, z) to the entity; `d = max(dx^2 + dz^2, 0.1)`;
`push(dx / d * 4.0, 0.2, dz / d * 4.0)`; if the phase is not a sitting phase and the entity's last-hurt-by-mob timestamp
is older than `tickCount - 2` and teams allow damage: `hurt(mobAttack, 5.0)` plus post-attack effects. Knock-back of the
dragon itself is ignored while in a sitting phase.

Block breaking (`checkWalls` on the head, neck and body boxes each tick): for every block position in the box (integer
floor of the box): non-air blocks that are not in tag `dragon_transparent` (`light` and the `fire` tag) are either
removed (when the game rule `mob_griefing` is true and the block is not in tag `dragon_immune`; removed without drops)
or, when immune or griefing is off, set the "in wall" result. If any block was removed, world event 2008 (explosion
particles) at a random position inside the box. The result "in wall" (any non-removable block touched) slows the dragon
(movement x 0.8 and flapping slower). The full block tags are in §3.8: `dragon_immune` is never removed and also stops the wall test from clearing (obsidian, crying obsidian, end stone, iron bars, respawn anchor, reinforced deepslate and the unbreakable technical blocks are in it), while `dragon_transparent` (`light` and the `fire` tag) is ignored.

Healing crystals (`checkCrystals`, each server tick): if a nearest crystal exists and is removed it is forgotten; else every
10 ticks (`tickCount % 10 == 0`) if health < max the dragon heals 1. With probability 1/10 per tick it rescans for the
nearest `end_crystal` within the box of its own bounding box inflated by 32 (nearest by distance squared).
When a crystal is destroyed (`onCrystalDestroyed`) and it is the dragon's nearest crystal, the dragon takes
`hurt(head, explosion(crystal, player), 10.0)` where the player is the destroyer if a player, else the nearest player
within the `CRYSTAL_DESTROY_TARGETING` range; then the current phase's `onCrystalDestroyed` hook runs (the hooks of the
phases were not expanded; Open question 12).

Taking damage (`hurt(part, source, amount)`): returns false while in phase DYING; the phase may filter the damage
(`onHurt`: the sitting phases ignore arrows and wind charges, setting wind charges on fire for 1 s, and return 0);
if the part is not the head or the neck: `amount = amount / 4 + min(amount, 1)`; amounts below 0.01 do nothing; only damage
whose attacker is a `Player` or whose type is in the damage type tag `always_hurts_ender_dragons` is applied
(`reallyHurt`). If the dragon is in a sitting phase, the health lost is added to `sittingDamageReceived`; when it exceeds
`SITTING_ALLOWED_DAMAGE_PERCENTAGE x max health` = 0.25 x 200 = 50, the counter resets to 0 and the phase becomes TAKEOFF.
`hurtServer` (damage to the entity root) is routed to `hurt(body, ...)`. A killing blow (`handleKillingBlow`): if the
current phase is not sitting, health is set to 1 and the phase to DYING; in a sitting phase nothing is changed (health 0 and the
death sequence begins).

#### 6.4.1 Movement (all phases)

Each server tick `aiStep` ticks the current phase (`doServerTick`); if that changed the phase, the new phase is ticked
once as well in the same tick. The phase then provides a fly target (may be null: then the dragon does not steer) and a
fly speed `s` and a turn speed `t`. With a target `T` (position `P`, delta `D = T - P`, `d2 = |D|^2`, `h = sqrt(Dx^2 + Dz^2)`):

1. if `h > 0`: `dy = clamp(Dy / h, -s, s)`; `velocity.y += dy * 0.01`.
2. `yRot = wrapDegrees(yRot)`.
3. `u = normalize(D)`; heading `g = normalize(sin(yaw), velocity.y, -cos(yaw))`; `f = max((g.u + 0.5) / 1.5, 0)`.
4. if `|Dx| > 1e-5` or `|Dz| > 1e-5`: `turn = clamp(wrapDegrees(180 - atan2(Dx, Dz) in degrees - yRot), -50, 50)`;
   `yRotA = yRotA * 0.8 + turn * t`; `yRot += yRotA * 0.1`. (When both are tiny, this step is skipped entirely.)
5. `k = 2 / (d2 + 1)`; `moveRelative(0.06 * (f * k + (1 - k)), (0, 0, -1))`.
6. move by the velocity (x 0.8 when "in wall"), then `v = normalize(velocity)`, `m = 0.8 + 0.15 * (v.g + 1) / 2`,
   `velocity = (velocity.x * m, velocity.y * 0.91, velocity.z * m)`.
`yBodyRot = yRot`. Default fly speed 0.6; default turn speed `(0.7 / min(hs + 1, 40)) / (hs + 1)` with `hs` the horizontal speed
(blocks/tick); landing: fly speed 1.5 and turn speed `min(hs + 1, 40) / (hs + 1)`; charging and dying: fly speed 3.0; hover:
fly speed 1.0. Wing flap phase advances `0.2 / (hs * 10 + 1) * 2^(velocity.y)` per tick (0.1 when sitting, half when in wall).

#### 6.4.2 The flight graph (24 nodes)

Built once (`findClosestNode`): index `i` 0 to 23. The coordinates use the game's table trigonometry `Mth.sin` / `Mth.cos`
(not exact trigonometry) and float32 arithmetic:

- `Mth.sin(d)` = `SIN[(long)(d * 10430.378350470453) & 65535]`; `Mth.cos(d)` = `SIN[(long)(d * 10430.378350470453 + 16384.0) & 65535]`.
- `SIN` has 65536 entries: `SIN[k] = (float) sin(k / 10430.378350470453)` (the same table as 11 §4).
- Angle `a = (float)(2 * (-3.1415927f + step * (float) j))` (all float32), `x = floor(radius * Mth.cos(a))`, `z = floor(radius * Mth.sin(a))`
  with `radius` a float32 constant, the product taken in float32, then floor.

| Nodes | Ring | `j` | `step` (float32) | Radius | Y |
|---|---|---|---|---|---|
| 0 to 11 | outer | `i` | `0.2617994f` | 60 | `max(73, surfaceY(x, z) + 5)` |
| 12 to 19 | middle | `i - 12` | `0.3926991f` | 40 | `max(73, surfaceY(x, z) + 15)` |
| 20 to 23 | inner | `i - 20` | `0.7853982f` | 20 | `max(73, surfaceY(x, z) + 5)` |

`surfaceY` is the `MOTION_BLOCKING_NO_LEAVES` height at that column. The resulting `(x, z)` of the 24 nodes (computed by running the rule above; this table is the test oracle):

| Node | x | z | Node | x | z | Node | x | z | Node | x | z |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 0 | 60 | 0 | 6 | -60 | 0 | 12 | 40 | 0 | 18 | 0 | -40 |
| 1 | 51 | 30 | 7 | -52 | -31 | 13 | 28 | 28 | 19 | 28 | -29 |
| 2 | 29 | 51 | 8 | -30 | -52 | 14 | 0 | 40 | 20 | 20 | 0 |
| 3 | 0 | 60 | 9 | 0 | -60 | 15 | -29 | 28 | 21 | 0 | 20 |
| 4 | -31 | 51 | 10 | 29 | -52 | 16 | -40 | 0 | 22 | -20 | 0 |
| 5 | -52 | 29 | 11 | 51 | -30 | 17 | -29 | -29 | 23 | 0 | -20 |

Adjacency (bitmask per node; bit `j` set = edge to node `j`, symmetric):

| Node | Mask | Node | Mask | Node | Mask | Node | Mask |
|---|---|---|---|---|---|---|---|
| 0 | 6146 | 6 | 65696 | 12 | 1581057 | 18 | 9044480 |
| 1 | 8197 | 7 | 131392 | 13 | 3166214 | 19 | 9706496 |
| 2 | 8202 | 8 | 131712 | 14 | 2138120 | 20 | 15216640 |
| 3 | 16404 | 9 | 263424 | 15 | 6373424 | 21 | 13688832 |
| 4 | 32808 | 10 | 526848 | 16 | 4358208 | 22 | 11763712 |
| 5 | 32848 | 11 | 525313 | 17 | 12910976 | 23 | 8257536 |

`findClosestNode(x, y, z)`: nearest node by squared distance among nodes `s..23`, where `s = 0` when the fight has at least one
living crystal and `s = 12` when it has none (the outer ring is excluded once all crystals are dead). `findPath(from, to,
extra)`: A* over the allowed nodes (`s..23`) with cost = Euclidean distance between node positions, heuristic = distance to the goal,
using the adjacency masks; an optional `extra` final node is appended as the goal; if the goal is unreachable the path
to the explored node closest to the goal is returned; a null path means the start equals the goal.
`path.advance()` moves to the next node; `isDone()` when it is past the last node.

Flying to a node (`navigateToNextPathNode`, shared by the flying phases): target = `(node.x, node.y + nextFloat * 20, node.z)`.

#### 6.4.3 Phases (id, behaviour)

| Id | Phase | Sitting | Fly speed | Description |
|---|---|---|---|---|
| 0 | HOLDING_PATTERN | no | 0.6 | circles on the ring; see below |
| 1 | STRAFE_PLAYER | no | 0.6 | flies at a player and shoots a fireball |
| 2 | LANDING_APPROACH | no | 0.6 | flies the path to the podium |
| 3 | LANDING | no | 1.5 | descends onto the podium |
| 4 | TAKEOFF | no | 0.6 | leaves the podium back to the ring |
| 5 | SITTING_FLAMING | yes | 0.6 (default, unused: no target) | breathes fire |
| 6 | SITTING_SCANNING | yes | 0.6 (default, unused) | idles and looks for players |
| 7 | SITTING_ATTACKING | yes | 0.6 (default, unused) | roars |
| 8 | CHARGING_PLAYER | no | 3.0 | rams the position of a player |
| 9 | DYING | no | 3.0 | flies to the podium to die |
| 10 | HOVERING | yes | 1.0 | hovers at its own position |

(Sitting phases' `getFlyTargetLocation` is null except hover; the three sitting phases come from `AbstractDragonSittingPhase`.) The
initial phase of a newly created dragon is HOLDING_PATTERN. `setPhase` ignores a request for the current phase; otherwise it
ends the old phase, begins the new one and stores the id into metadata 16 on the server.

**Holding pattern** (`DragonHoldingPatternPhase`): `begin` clears the path and target. Each tick: if there is no target, or
the dragon is within `d2 in [100, 22500]` of the target and has no horizontal or vertical collision, it keeps flying;
else (target reached, too far, or collided) `findNewTarget`. `findNewTarget`: when the path is null or done:
`podium = surface(MOTION_BLOCKING_NO_LEAVES) at the fight podium position`; `c = living crystals` (0 when there is no
fight); with probability `1 / (c + 3)` (`nextInt(c + 3) == 0`) the phase becomes LANDING_APPROACH; otherwise find the nearest
player to the podium (`NEW_TARGET_TARGETING`); the strafe test: `r = player ? podium.distToCenterSqr(player) / 512 : 64`;
if `nextInt(r + 2) == 0` or `nextInt(c + 2) == 0` (when a player exists) the dragon switches to STRAFE_PLAYER with that player
as target. Then (path null or done) it picks the next ring node: `n = findClosestNode()`; with probability 1/8 the direction
flips (`clockwise = not clockwise`) and `n += 6`; then `n += 1` when clockwise else `n -= 1`; if no crystals are alive:
`n = ((n - 12) & 7) + 12` (8-node middle ring); else `n = n mod 12` (made non-negative, 12-node outer ring); the new path
is `findPath(closest, n)` advanced once, and `navigateToNextPathNode` sets the target.

**Strafe player** (`DragonStrafePlayerPhase`): `begin` clears charge, target location, path and target player; with no player
it logs and goes back to HOLDING_PATTERN. Flies a path like the holding pattern, and when the path is done the target is
`(player.x, player.y + yOffset, player.z)` with `yOffset = min(0.4 + dist / 80 - 1, 10)` where `dist` is the horizontal
distance. While the player is within 64 blocks (distance squared < 4096) and visible: `fireballCharge += 1`; when
`fireballCharge >= 5` and the angle between the dragon's facing and the player direction (degrees, plus 0.5) is in
`[0, 10)`: a `DragonFireball` is launched from the head (position = head position - view vector, Y at head half height +
0.5) toward the player's half height with world event 1017 unless silent; the charge resets to 0 and the remaining path
is skipped; the phase returns to HOLDING_PATTERN. Out of range or out of sight: `fireballCharge` decays by 1 per tick
down to 0. (Recomputing the path node when the target is lost mirrors the holding pattern.)

**Landing approach**: same arrival test as the holding pattern; when the path is null or done: `closest = findClosestNode()`;
goal node = the nearest node to `(-px * 40, 105, -pz * 40)` where `(px, pz)` is the normalized horizontal direction to the
nearest player to the podium (`NEAR_EGG_TARGETING`, no line of sight needed), or to `(40, podiumY, 0)` when there is no
player; path = `findPath(closest, goal, extraNode = podium position)`; and when the path is done the phase becomes LANDING.

**Landing**: target = bottom centre of the podium surface; fly speed 1.5; turn speed `min(hs + 1, 40) / (hs + 1)`; when the
squared distance to the target is below 1 the sitting-flame counter is reset and the phase becomes SITTING_SCANNING.

**Takeoff**: on the first tick it computes a path from the closest node to the node nearest `(-view.x * 40, 105,
-view.z * 40)` where `view` is the head look vector (`getHeadLookVector`, which during LANDING and TAKEOFF aims the head
`-6 / max(dist / 4, 1) * 1.5 * 5` degrees down toward the podium, and 45 degrees down when sitting); the ring wrap rule is the
holding pattern's (inner ring when no crystals live). When the dragon is no longer within 10 blocks of the podium the phase
becomes HOLDING_PATTERN.

**Sitting scanning**: `scanningTime += 1`. A player within 20 horizontally and 10 vertically (`scanTargeting`): if
`scanningTime > 25` the phase becomes SITTING_ATTACKING; otherwise the dragon turns toward the player (the angle to
the player, plus 0.5, must be within `[0, 10]` degrees else `yRotA = yRotA * 0.8 + clamp(wrapDegrees(180 - atan2(dx, dz)
deg - yRot), -100, 100) * ((0.7 / min(dist + 1, 40)) / (dist + 1))`, `yRot += yRotA`). With no such player and
`scanningTime >= 100`: look for a player within 150 blocks (`CHARGE_TARGETING`); none: TAKEOFF; else CHARGING_PLAYER with the
player's position as the charge target.

**Sitting attacking**: `ROAR_DURATION` 40 ticks, then SITTING_FLAMING. **Sitting flaming**: `begin` increments `flameCount`;
`flameTicks` counts from 0; at `flameTicks == 10` a lingering breath cloud is spawned (below); at `flameTicks >= 200` the phase
becomes TAKEOFF if `flameCount >= 4` (`SITTING_FLAME_ATTACKS_COUNT`), else SITTING_SCANNING. LANDING resets `flameCount`.
Breath cloud (`AreaEffectCloud` owner = dragon): centre = head XZ + (horizontal head direction * 5 / 2), Y = scan down from the
head half height to the first non-air cell, +1; radius 5.0, duration 200, `dragon_breath` particle, potion duration scale
0.25, effect `instant_damage` (default amplifier and duration). Client particles: 8 groups of 6 particles every 2 ticks
for the first 10 ticks.

**Charging player**: `setTarget(position)` from the scanning phase; speed 3.0. Each tick: no target: HOLDING_PATTERN;
`timeSinceCharge > 0`: `+= 1` and at `>= 10` HOLDING_PATTERN; the counter starts (`+= 1`) when the dragon is within
10 blocks of the target, or farther than 150 (`d2 > 22500`), or collides.

**Hovering**: target = its own position (set the first tick); sitting. **Dying**: target = bottom centre of the `MOTION_BLOCKING`
surface at the podium; speed 3.0; while still flying toward it health is held at 1; when it arrives (within
`d2 < 100`) or is too far or collides, health is set to 0. `begin` clears target and `time`; client: explosion emitter
particles every 10 ticks.

Dragon fireball (`DragonFireball`, type `dragon_fireball`, no loot): on a hit that is not the owner: living entities in the box
inflated (4, 2, 4) are collected; a `AreaEffectCloud` is spawned (owner = dragon) at the hit position (moved to the first
entity within 4 blocks), radius 3.0, duration 600, radius per tick `(7.0 - radius) / duration`, potion duration scale
0.25, effect `instant_damage` amplifier 1 duration 1, particle `dragon_breath`; world event 2006 unless silent; the
fireball is discarded; `shouldBurn` false.

Area effect cloud constants (`AreaEffectCloud`): wait time default 20, reapplication delay 20, `TIME_BETWEEN_APPLICATIONS` 5,
radius default 3.0, maximum 32, minimum 0.5, height 0.5, default duration -1 (infinite), metadata 8 radius (Float), 9 waiting
(Boolean), 10 particle. The application loop itself was not read (§8.5).

#### 6.4.4 Death sequence (`tickDeath`)

Each server tick of a dying dragon: `dragonFight.updateDragon`, `dragonDeathTime += 1`. XP base `B = 500`, or `12000` if the
fight has not yet recorded a previous kill (`hasPreviouslyKilledDragon` false). While `dragonDeathTime > 150` and
`dragonDeathTime % 5 == 0` and the `mob_drops` game rule is on: award `floor(B * 0.08f)` XP as orbs (float multiplication; the periodic award runs before the final one in the same tick). At
`dragonDeathTime == 1` and not silent: global world event 1028 (the dragon-death sound heard in the whole dimension).
The dragon rises by 0.1 per tick (all parts move with it). While `180 <= dragonDeathTime <= 200`: explosion-emitter particles at random
offsets each tick. At `dragonDeathTime >= 200`: award `floor(B * 0.2f)` XP (when `mob_drops` is on), `dragonFight.setDragonKilled`,
remove the entity with reason KILLED and the `ENTITY_DIE` game event. With `B = 12000` the orbs total
`floor(12000 * 0.08) = 960` for each of the ticks 155, 160, ..., 200 (10 awards) = 9600, plus `floor(12000 * 0.2) = 2400`:
12000 in total (orb splitting rules: §8.2).

#### 6.4.5 The fight controller (`EnderDragonFight`)

Created for the End dimension (the dimension type has `has_ender_dragon_fight`); persists `dragonKilled`, `previouslyKilled`,
`needsStateScanning`, the respawn stage and time, the dragon UUID, the exit portal location, the remaining gateway indexes and
the respawn crystal references. Origin = the fight origin (default `(0, 0, 0)`); podium location = origin (`END_PODIUM_LOCATION` is
`(0, 0, 0)` offset by the origin) with Y taken from the `MOTION_BLOCKING_NO_LEAVES` heightmap.

| Constant | Value |
|---|---|
| Ticks without seeing the dragon before looking for or creating one | 1200 |
| Crystal rescan interval | 100 ticks |
| Player scan interval | 20 ticks |
| Arena | 8 chunks; ticket level 9 radius around chunk (0, 0), only while players are present |
| Valid player | alive entity within 192 blocks of `(origin.x, 128 + origin.y, origin.z)` |
| Dragon spawn Y | `128 + origin.y` at `(origin.x, ., origin.z)`, random yaw |
| Gateways | 20, each index used once, taken from a list shuffled at first init (`Util.shuffle` with a thread-local generator seeded from the level seed) |
| Gateway position | index `n`: `x = floor(96 * cos(2 * (-pi + 0.15707963 * n)))`, `z = floor(96 * sin(...))`, `y = 75`; world event 3000; feature `end_gateway_delayed` placed there |

Boss bar of the fight: a server boss event with a random UUID, the name component `entity.minecraft.ender_dragon`
(translation key), colour PINK, overlay PROGRESS, flags: play boss music and create world fog (wire flags `0x02 | 0x04`;
darken screen is not set). Progress = dragon health / max health, updated on `updateDragon` (every dragon tick); the custom
name of the dragon replaces the title. The bar is hidden when the dragon is killed and its progress is 0. Players are added or
removed every 20 ticks according to the valid-player rule. Packet use: 05a 0x09 (Boss Event) ADD when a player joins the
event, UPDATE_PROGRESS / UPDATE_NAME as they change, REMOVE when a player leaves.

Per tick (only while the event has at least one player, otherwise the arena ticket is removed): load check; first time:
`scanState` (look for an active exit portal by finding a block entity of the end portal type in chunks -8..8: if found, the dragon
was killed before, `hasPreviouslyKilledDragon = true`; else the exit portal is built inactive; find any living dragon in the dimension
(none: `dragonKilled = true`; one: adopt it, and if there was no portal discard it)); respawn sequence tick if active
(abort if all respawn crystals vanish); otherwise when the dragon is not killed: `ticksSinceDragonSeen` counts, at 1200
`findOrCreateDragon` (adopt any dragon or create a new one), and every 100 ticks the crystal count is recomputed by counting
`end_crystal` entities inside the top bounding box of each pillar.

`setDragonKilled(dragon)` (for the fight's own dragon): boss progress 0 and hidden; `spawnExitPortal(active)`; `spawnNewGateway`
(pop the last index; nothing if none left); when this is the first kill the dragon egg block is placed at the `MOTION_BLOCKING`
surface at the podium and `hasPreviouslyKilledDragon = true`; `dragonKilled = true`.

Exit portal (`spawnExitPortal(active)` and `EndPodiumFeature`): location = the `MOTION_BLOCKING_NO_LEAVES` surface at the
podium minus 1 block, lowered while the block is bedrock and the Y is above 63, then clamped to at least `minY + 1`; stored. The
feature (`active` = portal blocks or air in the middle): over the box from `(-4, -1, -4)` to `(+4, +32, +4)` relative to the centre
(3-D distance to the centre `c`): cells below the centre layer: distance < 2.5 bedrock, distance < 3.5 end stone; centre layer:
distance < 2.5 `end_portal` (active) or air (inactive), distance in [2.5, 3.5) bedrock; above the centre layer: air; then four bedrock blocks
straight above the centre (heights 0 to 3) and a wall torch on each of the four horizontal sides at centre + 2. (The `distance < 2.5` cell test
for the layers below uses the cell's own 3-D distance; the active variant destroys and re-places changed blocks with drops.)

Respawn (`tryRespawn`, called when a player completes the crystal ring around the portal; the caller was not read): requires
`dragonKilled` and no sequence running; finds the portal (or builds it); each of the four horizontal directions, at
`portal.above(1).relative(direction, 3)`, must contain at least one `end_crystal` (collected), else nothing happens; then
`respawnDragon`: every bedrock or `end_portal` block of the portal pattern is replaced with `end_stone`, the portal is rebuilt
inactive, stage = START, time = 0, crystal references stored. Each tick `respawnTime += 1` and the stage ticks; the sequence aborts
(portal rebuilt active, spike crystals reset, stage cleared) if every respawn crystal disappears or when one of them is destroyed.

| Stage | Ticks (`t` = respawn time) | Action |
|---|---|---|
| START | first tick | every respawn crystal gets beam target `(0, 128, 0)`; next stage PREPARING_TO_SUMMON_PILLARS |
| PREPARING_TO_SUMMON_PILLARS | `t < 100` | world event 3001 at `(0, 128, 0)` at `t == 0, 50, 51, 52` and for `t >= 95`; at `t >= 100` next stage SUMMONING_PILLARS |
| SUMMONING_PILLARS | `t` runs 0 .. 399 | pillar index `i = t / 40`; at `t % 40 == 0` each respawn crystal gets the beam target `(spike.x, spike.height + 1, spike.z)`; at `t % 40 == 39`: remove all blocks in the cube of half-size 10 around `(x, height, z)`, explode at `(x + 0.5, height, z + 0.5)` with power 5.0 (block interaction), and regenerate that pillar (EndSpikeFeature with one spike, crystal invulnerable, beam target `(0, 128, 0)`, placed at `(x, 45, z)`); after the tenth pillar next stage SUMMONING_DRAGON |
| SUMMONING_DRAGON | `t` | `t == 0`: beam targets `(0, 128, 0)`; `t < 5`: world event 3001; `t >= 80`: world event 3001; `t >= 100`: stage END, `resetSpikeCrystals` (all spike crystals vulnerable again, beams cleared), each respawn crystal: beam cleared, explosion power 6.0 with no block interaction, entity discarded |
| END | - | `setRespawnStage(END)`: stage cleared, `dragonKilled = false`, a new dragon is created (`createNewDragon`: chunk load, entity with reason EVENT, `setDragonFight`, fight origin, phase HOLDING_PATTERN, placed at `(origin.x, 128 + origin.y, origin.z)` with random yaw), and each player on the boss bar gets the summoned-entity criterion |

#### 6.4.6 The pillars (`EndSpikeFeature`)

Ten obsidian pillars, deterministic from the world seed.

Random numbers: both uses below create `RandomSource.createThreadLocalInstance(seed)`, which is the Java linear congruential
generator (10 §2.6: `nextLong()` and `nextInt(bound)` as defined there). `spikesForLevel`: `r` = that generator seeded with the level seed;
`seed16 = r.nextLong() & 65535`; the list is cached per `seed16`. `order` = the integers 0 to 9 shuffled by `Util.shuffle` with a
second generator `createThreadLocalInstance(seed16)` (the same Java LCG). The shuffle: for `n` from 10 down to 2: `j = nextInt(n)`, swap element `n - 1` with element `j`.
For position `i` (0 to 9): `centerX = floor(42 * cos(2 * (-pi + (pi / 10) * i)))`, `centerZ = floor(42 * sin(2 * (-pi + (pi / 10) * i)))` (double
precision `Math.cos` and `Math.sin`, not the float table), `s = order[i]`, `radius = 2 + s / 3` (integer division), `height = 76 + s * 3`,
`guarded = (s == 1 or s == 2)`.

Placement (`placeSpike`): visit every column of the square of half-size `radius` around the centre and every Y from the world minimum up to `height + 10`
inclusive. For a cell with horizontal distance squared `q` from the low corner of the centre block (`distToLowCornerSqr(centerX, y, centerZ)`):
if `q <= radius^2 + 1` and `y < height` the cell becomes obsidian; otherwise, if `y > 65`, the cell becomes air. So every cell above Y 65 that is not obsidian
(the square's corners outside the circle at every height, and the whole interior at and above `height`) is cleared to air; cells at or below Y 65 outside the obsidian are left untouched.

Cage (only when `guarded`): for `dx` and `dz` in -2..2 and `dy` in 0..3, a block is placed at `(centerX + dx, height + dy, centerZ + dz)` when `|dx| == 2`
or `|dz| == 2` or `dy == 3` (so a 5 x 5 ring of walls, 4 high, and at `dy == 3` a full 5 x 5 plate). The block is `iron_bars` with
connection properties: `north` = (`|dx| == 2` or `dy == 3`) and `dz != -2`; `south` = (`|dx| == 2` or `dy == 3`) and `dz != 2`; `west` = (`|dz| == 2` or `dy == 3`) and `dx != -2`;
`east` = (`|dz| == 2` or `dy == 3`) and `dx != 2`.

Crystal: an `end_crystal` (reason STRUCTURE) at `(centerX + 0.5, height + 1, centerZ + 0.5)` with a random yaw (`nextFloat * 360` from the feature's random source), beam target from the
feature (none at world generation; `(0, 128, 0)` in the respawn), `permanentlyInvulnerable` from the feature (only the respawn pillars set it); bedrock at the crystal's
cell minus 1 (so at `height`) and a fire block in the crystal's cell (`FireBlock.getState`).

## 7. The Wither, boss bars and the Nether Star

### 7.1 Build pattern (`WitherSkullBlock`)

A wither skeleton skull block (floor or wall variant) placed anywhere triggers `checkSpawn` on the server (not in Peaceful,
position Y at or above the world minimum). The pattern (`BlockPattern`, rows listed top to bottom, three columns, found in either
orientation by the pattern search) is:

| Row | Cells | Meaning |
|---|---|---|
| 1 (top) | `^ ^ ^` | `^` = `wither_skeleton_skull` or `wither_skeleton_wall_skull` |
| 2 | `# # #` | `#` = a block in tag `wither_summon_base_blocks` = {`soul_sand`, `soul_soil`} |
| 3 (bottom) | `~ # ~` | `~` = air; `#` as above |

A second pattern with a blank top row (`getOrCreateWitherBase`: rows blank, `###`, `~#~`) also exists; its caller was not read. On a full match:
create a `wither` (reason TRIGGERED); clear the pattern blocks (`CarvedPumpkinBlock.clearPatternBlocks`); position it at the X and Z
of the pattern block returned by `getBlock(1, 2, 0)` (pattern coordinates as `BlockPattern` defines them; the middle column of the
last aisle row, read as the bottom `~ # ~` row's middle) centred (+0.5), Y = that block's Y + 0.55, yaw 90 degrees when the pattern's forward axis is X (else 0;
body yaw 90 when X); call `makeInvulnerable` (below); trigger the "summoned entity" criterion for every server player within 50
blocks; add the entity; then `updatePatternBlocks` (neighbour updates around the cleared cells).

### 7.2 The Wither (`WitherBoss`)

| Field | Value |
|---|---|
| Type | `wither`, 0.9 x 3.5, MONSTER, fire immune, `immuneTo` (block tag), `notInPeaceful`, no delta tracking, range 10 |
| Attributes | Monster base + `MAX_HEALTH 300`, `MOVEMENT_SPEED 0.6`, `FLYING_SPEED 0.6`, `FOLLOW_RANGE 40`, `ARMOR 4.0` |
| XP | 50 |
| Movement | `FlyingMoveControl(10, false)`; `FlyingPathNavigation` (cannot open doors, can float) |
| Metadata | 16 = head target A (VarInt entity id; the main target), 17 = target B, 18 = target C, 19 = invulnerable ticks (VarInt) |
| Immunities | cannot receive any effect (`addEffect` returns false); cannot be affected by the Wither effect; cannot ride; cannot use portals |
| Peaceful | `checkDespawn` discards it in Peaceful (a type that is not allowed in peaceful) and resets `noActionTime` |
| Goals | 0 `WitherDoNothingGoal` (flags move, jump, look; usable while `invulnerableTicks > 0`); 2 `RangedAttackGoal(1.0, 40, 20.0)` (interval 40 ticks, range 20; the shot uses head 0); 5 `WaterAvoidingRandomFlyingGoal(1)`; 6 `LookAtPlayerGoal(Player, 8)`; 7 `RandomLookAroundGoal` |
| Targets | 1 `HurtByTargetGoal`; 2 `NearestAttackableTargetGoal(LivingEntity, 0, false, false, selector)` with selector "type not in tag `wither_friends` and attackable"; the head targeting test for side heads is `forCombat().range(20).selector(same)` |
| Spawn | never naturally (the registry has a spawn placement row with `checkMonsterSpawnRules`, no biome entry) |
| Loot | no pools; drops a `nether_star` item entity with an extended lifetime (`setExtendedLifetime`) at death through `dropCustomDeathLoot`; XP as above |

**Spawn sequence.** `makeInvulnerable`: `invulnerableTicks = 220`, boss bar progress 0, health = max / 3 (100). While
`invulnerableTicks > 0` each server tick: `n = invulnerableTicks - 1`; bar progress = `1 - n / 220`; when `n <= 0`: explosion of
power 7.0 at its eye position with interaction MOB (block damage per the mob-griefing rule), and global world event 1023 unless
silent; store `n`; every 10 ticks (`tickCount % 10 == 0`) heal 10; the normal head logic below is not run in that branch
(the method returns after the healing step). Damage during the spawn is ignored unless it bypasses invulnerability
(damage type tag `bypasses_invulnerability`).

**Heads.** Head 0 is at the body position with no horizontal offset and `y + 3.0 * scale`. A head `n > 0` is at the angle `yBodyRot + 180 * (n - 1)` degrees,
horizontal radius `1.3 * scale`, Y `y + 2.2 * scale` (head 3 is at 360 degrees, so it coincides with head 1). Each head's pitch turns at most 40 degrees per tick and yaw at most 10
degrees per tick toward its target (or the body yaw when it has none). Head target ids are metadata 16 to 19 (A is the entity
target of head 0 and equals the main target; B and C are the side heads' targets).

**Server AI (`customServerAiStep`, after the spawn branch).** For each side head slot `i` in {1, 2} (arrays use `i - 1`):
when `tickCount >= nextHeadUpdate[i-1]`: `nextHeadUpdate = tickCount + 10 + nextInt(10)`; on Normal or Hard difficulty
`idleHeadUpdates[i-1] += 1` and, when it exceeds 15, a skull is shot at a random point uniformly within `x +- 10`, `y +- 5`, `z +- 10`
(as a dangerous skull) and the counter resets; then if slot `i` holds a target id: that entity is looked up; if it is
alive, attackable, within 30 blocks (distance squared <= 900) and visible, a skull is shot at it, `nextHeadUpdate = tickCount + 40
+ nextInt(20)` and `idleHeadUpdates = 0`; if the target is not valid it is cleared; with no target id the wither picks a
random living entity from `getNearbyEntities(TARGETING_CONDITIONS, box inflated (20, 8, 20))` and stores its id. Slot 0 mirrors
the mob's own target (id of `getTarget()` or 0). The skull origin head index passed to the shooting function is `i + 1`
(head 2 or 3; angles `yBodyRot + 180` and `yBodyRot + 360`, so head 3 coincides with head 1); the goal-driven shot (`RangedAttackGoal`) uses head 0.

**Skull launch (`performRangedAttack(head, x, y, z, dangerous)`)**: world event 1024 unless silent; a `WitherSkull`
with direction `normalize(target - headPosition)`, owner = the wither, `dangerous` flag, placed at the head position. For a
shot at a living target the flag is `false` for heads other than 0 and `nextFloat() < 0.001` for head 0; the aim point is the
target X, `target Y + eyeHeight * 0.5`, target Z. The random-point shots above set `dangerous = true`.

**Flight (`aiStep`)**: velocity Y is multiplied by 0.6. With a main target (server only): the climb is applied when the wither's Y is below the
target's Y, or (when not powered) below the target's Y + 5: `velocity.y = max(0, velocity.y)` then `velocity.y += 0.3 - velocity.y * 0.6`.
When the horizontal distance squared to the target exceeds 9: `velocity += ((dir.x * 0.3 - velocity.x * 0.6), 0, (dir.z * 0.3 -
velocity.z * 0.6))` where `dir` is the normalized horizontal direction. Yaw follows the horizontal velocity when its squared length is above 0.05
(`yRot = atan2(vz, vx) in degrees - 90`).

**Powered state** (`isPowered`): health at most half the maximum (150). Powered: arrows and wind charges as the direct
entity do no damage; the climb-above-target rule is dropped; the client shows armor particles.

**Damage rules (`hurtServer`)**: ignored if invulnerable to the source; ignored for damage types in tag `wither_immune_to`
and for any damage whose entity is itself a Wither; ignored while `invulnerableTicks > 0` unless the type bypasses invulnerability; when powered ignores arrow and wind
charge direct entities; ignored when the attacker's type is in tag `wither_friends` (= `undead` tag family). Otherwise: if
`destroyBlocksTick <= 0` it is set to 20; each head's `idleHeadUpdates` increases by 3; then the normal damage is applied.

**Block destruction**: `destroyBlocksTick` counts down each server tick; when it reaches 0 and `mob_griefing` is on, every block in
the box from `(x - w, y, z - w)` to `(x + w, y + h, z + w)` with `w = floor(width / 2 + 1)` and `h = floor(height)` that is not
air and not in tag `wither_immune` is destroyed with drops, the wither as the destroyer; if any was destroyed, world event
1022 at the wither. Block tag `wither_immune` is in §3.8 (it does not contain obsidian or end stone: the Wither's blast and block breaking destroy those; it adds `light` and `reinforced_deepslate`).

**Regeneration**: when the spawn phase is over, `heal(1)` every 20 ticks (`tickCount % 20 == 0`); boss bar progress = health / max health
every server tick.

**Wither skull (`WitherSkull`)**: type `wither_skull`, 0.3125 x 0.3125, range 4, update interval 10, metadata 8 = dangerous (Boolean, default false).
Inertia: 0.73 when dangerous (the non-dangerous inertia is the base projectile's, not read). When dangerous, the block explosion
resistance of destroyable blocks is capped at 0.8 (`min(0.8, resistance)`; `canDestroy` = not air and not `wither_immune`).
Entity hit: with a living owner, `hurt(witherSkull(skull, owner), 8.0)`; if that damage lands and the target is still alive,
post-attack enchantment effects run, and if the target died the owner heals 5.0 (the displayed branch: alive -> effects, not
alive -> heal); with no living owner `hurt(magic, 5.0)`. When that hurt lands and the target is living: Wither effect, amplifier 1,
for `20 * s` ticks where `s = 0` Easy (none), 10 Normal, 40 Hard. Any hit (server): an explosion of radius 1.0 at the skull with no fire and interaction MOB, then the skull
is discarded.

### 7.3 Boss bars (`ServerBossEvent`, Boss Event packet 05a 0x09)

| Boss | Title | Colour | Overlay | Flags | Progress |
|---|---|---|---|---|---|
| Ender Dragon (fight) | `entity.minecraft.ender_dragon` (translatable) or the dragon's custom name | PINK | PROGRESS | play boss music, create world fog (`0x06`) | health / max health; 0 and hidden when the dragon is killed |
| Wither | the wither's display name (updates with `setCustomName`) | PURPLE | PROGRESS | darken screen (`0x01`) | `1 - remaining / 220` during the spawn, then health / max health |

Packet use: a server boss event holds a player set; `startSeenByPlayer` (Wither: when a player starts tracking the wither,
`addPlayer`; stop tracking: `removePlayer`) sends ADD with title, progress, colour, overlay and flags; progress changes send
UPDATE_PROGRESS; name changes UPDATE_NAME; a player leaving sends REMOVE. The dragon's bar membership is the fight's 20-tick
player scan (§6.4.5), not tracking.

### 7.4 Nether Star

`dropCustomDeathLoot` of the wither creates one `nether_star` item entity at the wither's position with `setExtendedLifetime`
(`setExtendedLifetime` sets the item's age to -6000, so it lives 12000 ticks instead of 6000). Beacon use and
crafting are outside this document.

## 8. Non-mob entities

All values are read from the classes named; behaviour not listed was not read (Open question 13).

### 8.1 Item entity (`ItemEntity`)

Type `item`, 0.25 x 0.25, eye 0.2125, range 6, update interval 20. Metadata 8 = item stack. Constants: lifetime 6000 ticks,
infinite pickup delay 32767, infinite lifetime -32768, health 5, float height 0.1. Created with velocity `(rand * 0.2 - 0.1,
0.2, rand * 0.2 - 0.1)` (or an explicit velocity), random yaw. Tick: discard when the stack is empty; decrement
`pickupDelay` (unless 32767); in water (fluid height > 0.1) the underwater movement, in lava the lava movement, else gravity;
an item inside blocks (client: never; server: when its box collides) is pushed toward the closest free space; it only
moves when airborne or when `(tickCount + entityId) % 4 == 0` or it is moving (on the ground and horizontal speed squared
<= 1e-5 skips the move on the other ticks); movement: air drag, on the ground multiplied by the block friction, velocity scaled
`(f, drag, f)`; on the ground with downward velocity the Y velocity is multiplied by -0.5 (bounce). Merge: every 40 ticks (server, mergeable) look for other
items in the box inflated `(0.5, 0, 0.5)`; mergeable = alive, pickup delay not infinite, age not infinite and below 6000,
count below the stack maximum; two stacks merge when they have the same owner/target, the same item and components and the total fits the maximum stack; the
smaller stack is merged into the larger. Age +1 per tick (unless infinite); discard at age >= 6000. A noticeable
velocity change (squared > 0.01) flags a sync. Player pickup and the throw-delay rules were not read.

### 8.2 Experience orb (`ExperienceOrb`)

Type `experience_orb`, 0.5 x 0.5, range 6, update interval 20. Metadata 8 = value (VarInt). Fields: health 5, count 1, age.
Spawn velocity: `((rand * 0.2 - 0.1) * 2, rand * 0.2 * 2, (rand * 0.2 - 0.1) * 2)` (reversed if it points against the supplied
direction). Tick: gravity (or underwater movement); in lava it hops (`(rand - rand) * 0.2`, 0.2, ...); every 20 ticks
(`tickCount % 20 == 1`) it merges with orbs within the box inflated 0.5 (`count` adds, `age` takes the minimum); it follows the
nearest non-spectator living player within 8 blocks (re-evaluated; dropped when farther than 8): acceleration along the
direction to the player's mid-height by `(1 - distance / 8)^2 * 0.1`; friction as for items; a downward ground bounce
`vy = -vy * 0.4`; discard at age 6000. Pickup (`playerTouch`, server player, `takeXpDelay == 0`): `takeXpDelay = 2`, mending repair
first (`repairPlayerItems`), the remainder `giveExperiencePoints`, `count -= 1`, discard at 0.

Award splitting (`award(total)`): repeat: `v = value(total)`, `total -= v`, try to merge into an existing nearby orb of the same
value (a random 1/40 slot test), else spawn a new orb of value `v`. `value(total)`: 2477 if `total >= 2477`; else 1237 if
`>= 1237`; 617 if `>= 617`; 307 if `>= 307`; 149 if `>= 149`; 73 if `>= 73`; 37 if `>= 37`; 17 if `>= 17`; 7 if `>= 7`; 3 if `>= 3`; else 1.

### 8.3 Primed TNT (`PrimedTnt`)

Type `tnt`, 0.98 x 0.98, eye 0.15, range 10, interval 10, fire immune. Metadata 8 = fuse (VarInt, default 80), 9 = block
state. Created by an igniter at a position with velocity `(-sin(a) * 0.02, 0.2, -cos(a) * 0.02)`, `a = nextDouble * 2*pi`,
fuse 80. Tick: portal handling, gravity, move, air drag; on the ground velocity `(0.7 vx, -0.5 vy, 0.7 vz)`; `fuse -= 1`; at `fuse <= 0` the entity is
discarded and (server, game rule `tnt_explodes` true) an explosion of `explosionPower` (default 4.0) is made at `(x, y + 0.0625, z)` with
the TNT interaction; otherwise (fuse above 0) fluid interaction is updated and the client spawns a smoke particle at `y + 0.5`.
NBT keys: `block_state`, `fuse`, `explosion_power` (read back clamped to 0 to 128; default 4.0).

### 8.4 Falling block (`FallingBlockEntity`)

Type `falling_block`, 0.98 x 0.98, range 10, interval 20; metadata 8 = start position; the Add Entity `Data` field carries the block
state id (05a 0x01). `time += 1` each tick, gravity, move. Landing (server, when on the ground, or a concrete-powder block reaching
water with squared speed above 1): the block must be placeable at the cell: the cell replaceable, the block can survive there, the
cell below is not free (not "free to fall"); then `setBlockAndUpdate` (waterlogged when the cell was water and the state has the
property), the clients near it get Block Update (05a 0x08) and Add Transient Block (05a 0x25) packets, the entity is discarded and
the block's `onLand` runs; a block entity's data is copied. If it cannot be placed: the item is dropped when `dropItem` is true
and the `entity_drops` rule is on. Landing attempt also multiplies the velocity by `(0.7, -0.5, 0.7)`. Expiry: `time > 100` and the Y outside the world height range, or `time >
600`: the item is dropped when allowed and the entity is discarded. Constants: fall damage per distance 0, max fall damage 40, drop item
true. A falling block is hit-proof (`hurtServer` only marks it hurt and returns false).

### 8.5 Area effect cloud (`AreaEffectCloud`)

Type `area_effect_cloud`, 6.0 x 0.5 at construction (the dimension follows the radius), fire immune, range 10, no update interval.
Metadata 8 radius (Float, default 3.0, clamped to 0..32), 9 waiting (Boolean), 10 particle. Constants: `DEFAULT_RADIUS` 3.0,
`MINIMAL_RADIUS` 0.5, `MAX_RADIUS` 32, `HEIGHT` 0.5, `TIME_BETWEEN_APPLICATIONS` 5, default wait time 20, default
reapplication delay 20, default duration -1 (infinite), lingering potion default duration 600, potion duration scale 1.0
default. `noPhysics` true. `serverTick` holds the application loop (victims map, radius shrink, effect application); its
body was not read, so the exact application rule is open (Open question 13). Users in this document: the dragon's breath
(radius 5, duration 200, scale 0.25) and the dragon fireball (radius 3 growing to 7 over 600 ticks, scale 0.25).

### 8.6 Lightning bolt (`LightningBolt`)

Type `lightning_bolt`, size 0, range 16, no save, no loot. Constants: `START_LIFE` 2, damage radius 3.0, detection radius 15.0.
`life` starts at 2; `flashes = nextInt(3) + 1`; a random seed for the visual. First tick (`life == 2`): sound events (client), on Normal
or Hard difficulty `spawnFire(4)`, power the lightning rod, clear copper oxidation/wax, `LIGHTNING_STRIKE` game event. Each tick `life -= 1`;
at `life < 0`: if `flashes == 0` the bolt triggers its advancement for players within 15 blocks (server) and is discarded;
else when `life < -nextInt(10)`: `flashes -= 1`, `life = 1`, new seed, `spawnFire(0)`. While `life >= 0` and not `visualOnly`
(server): every entity in the box `+- 3` horizontally, `-3` to `+6+3` vertically gets `thunderHit` (its own effect: not read). The client sets the sky
flash time to 2.

### 8.7 Firework rocket (`FireworkRocketEntity`)

Type `firework_rocket`, 0.25 x 0.25, range 4, interval 10. Metadata 8 item stack, 9 attached entity id (optional unsigned VarInt), 10
shot at angle (Boolean). Lifetime `10 * (1 + flightDuration) + nextInt(6) + nextInt(7)`; initial velocity `(triangle(0, 0.002297), 0.05,
triangle(0, 0.002297))`. A rocket attached to a gliding entity each tick adds to that entity's velocity `look * 0.1 + (look * 1.5 -
velocity) * 0.5` and follows it. On expiry `explode` broadcasts entity event 17, fires the `EXPLODE` game event (source = owner), calls `dealExplosionDamage` and discards the rocket. Damage `D = 5 + 2 * (number of explosion stars)` (0 when the item has none); the entity it is attached to takes `D` (fireworks damage source); other living entities in the box inflated by 5 take `D * sqrt((5 - distance) / 5)` when a collider-clip from the rocket to one of the sampled heights of the entity is unobstructed.

### 8.8 Boats and minecarts

| Entity family | Constants and facts read |
|---|---|
| Boats (`AbstractBoat`: all `*_boat`, `*_chest_boat`, `bamboo_raft`, `bamboo_chest_raft`) | size 1.375 x 0.5625 (builder), range 10, no loot. Metadata 8 hurt time (VarInt), 9 hurt direction, 10 damage (Float), 11 paddle left, 12 paddle right (Booleans), 13 bubble time. Constants: eject passengers after 60 ticks under water or flowing water (`outOfControlTicks >= 60`), paddle speed 0.3927 rad/tick, paddle sound when the paddle phase crosses 0.785 rad, bubble time 60. Hurt time and damage each decrease by 1 per tick. Control: the locally authoritative side (the riding player's client) computes the boat's motion (`controlBoat`, `floatBoat`) and sends `ServerboundPaddleBoat` (05c) with the two paddle booleans; the server applies `floatBoat` and `move` when it is authoritative, otherwise sets velocity to zero. The floating and steering numbers were not read (Open question 14). |
| Minecarts (`AbstractMinecart` and kinds) | size 0.98 x 0.7, range 8, no loot. Metadata 8 hurt, 9 hurt direction, 10 damage (Float), 11 custom display block (optional block state), 12 display offset (VarInt); furnace adds 13 fuel (Boolean); command block adds 13 command name and 14 last output. Two behaviours exist: `OldMinecartBehavior` (max speed 0.4 on land and 0.2 in water, absolute max 0.4, ridable threshold 0.01) and `NewMinecartBehavior` (position and rotation interpolation 3 ticks, on-rail Y offset 0.1, opposing-slopes rest threshold 0.005); water slowdown factor 0.95. Furnace minecart: 3600 fuel ticks per item, maximum 32000. TNT minecart: default explosion power base 4.0, speed factor 1.0 (NBT `explosion_power`, `explosion_speed_factor`). Rail physics were not read (Open question 14). |

### 8.9 Other non-mob entities (constants only)

| Entity | Facts read |
|---|---|
| `armor_stand` | 0.5 x 1.975, eye 1.7775, range 10. Metadata 15 client flags (Byte: 1 small, 4 show arms, 8 no base plate, 16 marker), 16 head pose, 17 body, 18 left arm, 19 right arm, 20 left leg, 21 right leg (Rotations). Constants: wobble time 5, equipment offsets feet 0.1, legs 0.4, chest 0.9, head 1.6; disabled-slot bit offsets: taking 8, putting 16. |
| `item_frame`, `glow_item_frame` | 0.5 x 0.5 builder, no update interval, no delta tracking. Metadata 8 direction, 9 item, 10 rotation (VarInt); 8 rotations; depth 0.0625, width and height 0.75; default drop chance 1.0. |
| `painting` | 0.5 x 0.5 builder; metadata 8 direction, 9 painting variant (Holder, 00 §10.2); depth 0.0625. |
| `leash_knot` | 0.375 x 0.5, eye 0.0625, not saved, no metadata beyond the base. |
| `marker` | no metadata, no tracking range (0): never sent to clients. |
| `interaction` | metadata 8 width, 9 height (Floats, defaults 1.0), 10 response (Boolean, default false); NBT `width`, `height`, `attack`, `interaction`, `response`. |
| `block_display`, `item_display`, `text_display` | metadata 8 to 22 common display fields (interpolation start delta, duration, pos-rot duration, translation, scale, left and right rotation, billboard byte, brightness override, view range, shadow radius and strength, width, height, glow colour); then block display 23 block state; item display 23 item stack, 24 item display type (Byte); text display 23 text component, 24 line width, 25 background colour, 26 text opacity (Byte), 27 style flags (Byte). Range 10, update interval 10. |
| `ominous_item_spawner` | metadata 8 item stack. |
| `sulfur_cube` | owned by 20 §18.2 (not repeated here). |
| Projectiles with a stack metadata (`snowball`, `egg`, `ender_pearl`, `experience_bottle`, `splash_potion`, `lingering_potion`, `eye_of_ender`, `fireball`, `small_fireball`) | metadata 8 = item stack for rendering; arrows 8 flags, 9 pierce level, 10 in ground, (arrow 11 effect colour); trident 11 loyalty, 12 foil; fishing bobber 8 hooked entity id, 9 biting; wind charge, llama spit, evoker fangs, shulker bullet: no metadata. Behaviour: not covered. |

### 8.10 Bat (`Bat`)

Type `bat`, 0.5 x 0.9, eye 0.45, category AMBIENT, range 5, no delta tracking. Attributes: Mob base + `MAX_HEALTH 6`. Metadata 16 = flags (Byte; bit 0 = resting).
Fall damage immune (tag `fall_damage_immune`, §3.6). Not pushable; it does not push other entities (`doPush` and `pushEntities` do nothing). Sound volume 0.1, voice pitch x 0.95. No loot
pools. Hurt while resting: it stops resting first, then takes the damage.

State machine (server, `customServerAiStep`; let `above` be the block at `pos + (0, 1, 0)`):

- Resting: the velocity is zero and the position is snapped to `y = floor(y) + 1 - boxHeight` (hanging under the ceiling). If `above` is not a redstone conductor the bat stops resting and, unless silent, world event 1025 is played. Otherwise, with probability 1/200 per tick it sets a random head yaw (`nextInt(360)`), and if a non-combat targetable player is within 4 blocks (`BAT_RESTING_TARGETING`, range 4.0) it stops resting (with event 1025 unless silent).
- Flying: velocity Y is multiplied by 0.6 each tick. `targetPosition` is cleared if its cell is not empty air or its Y is not above the world minimum. A new target is chosen when there is none, with probability 1/30 per tick, or when within 2 blocks of the target: `(x + nextInt(7) - nextInt(7), y + nextInt(6) - 2, z + nextInt(7) - nextInt(7))`. Steering: `d = (target.x + 0.5 - x, target.y + 0.1 - y, target.z + 0.5 - z)`; `velocity += ((sign(dx) * 0.5 - vx) * 0.1, (sign(dy) * 0.7 - vy) * 0.1, (sign(dz) * 0.5 - vz) * 0.1)`; then `heading = atan2(vz, vx) in degrees - 90`, `yRot += wrapDegrees(heading - yRot)`, forward input 0.5. While flying, with probability 1/100 per tick: if `above` is a redstone conductor it starts resting.
- Flap animation: it is "flapping" when not resting and `tickCount % 10 == 0`.

Spawn: category AMBIENT (biome entry `bat` w10 x8 in every Overworld biome that has an `ambient` list; empty in `deep_dark` and `the_void`; absent in the Nether and End biomes), placement ON_GROUND with `checkBatSpawnRules`: the position Y must be below the `WORLD_SURFACE` height at that column; `nextBoolean()` must be false; the raw brightness must not exceed `nextInt(4)`; the block below must be in tag `bats_spawnable_on` (= tag `base_stone_overworld`, §3.8); then `checkMobSpawnRules`. The method has no further tests.

### 8.11 Happy ghast (`HappyGhast`, `HappyGhastAi`)

Type `happy_ghast`, 4.0 x 4.0, eye 2.6, CREATURE, range 10. Baby scale 0.2375, maximum scale 1.0. Attributes: Animal base + `MAX_HEALTH 20`, `TEMPT_RANGE 16`, `FLYING_SPEED 0.05`,
`MOVEMENT_SPEED 0.05`, `FOLLOW_RANGE 16`, `CAMERA_DISTANCE 8`. Metadata: 16 baby, 17 age locked, 18 is leash holder (Boolean), 19 stays still (Boolean). Loot: no pools. Cannot breed (`canFallInLove` false);
food = item tag `happy_ghast_food` = {`snowball`}; max spawn cluster 1; no fall damage; breathes under water while a baby. Placement ON_GROUND with `checkAnimalSpawnRules`; no biome list read contains it (Open question 19).

Two modes, switched by `ageBoundaryReached`:

| | Adult | Baby |
|---|---|---|
| Move control | `GhastMoveControl` (with the "stand still" callback) | `FlyingMoveControl(180, true)` |
| Look control | `HappyGhastLookControl` | plain `LookControl` |
| Navigation | the default flying navigation | `BabyFlyingPathNavigation` |
| AI | goals: 3 `HappyGhastFloatGoal`; 4 `TemptGoal$ForNonPathfinders(speed 1.0, item predicate, false, 7.0)`; 5 `RandomFloatAroundGoal(16)` | Brain (below) |

The adult tempt predicate: when the ghast wears body armor or is a baby the item must be in `happy_ghast_food` (snowball); otherwise it must be in `happy_ghast_tempt_items` (= `happy_ghast_food` plus the `harnesses` tag, the 16 harnesses). An armored ghast is therefore tempted only by snowballs.

Baby brain: sensors `NEAREST_LIVING_ENTITIES`, `HURT_BY`, `FOOD_TEMPTATIONS`, `NEAREST_ADULT_ANY_TYPE`, `NEAREST_PLAYERS`. Activities: CORE (`Swim(0.8)`, `AnimalPanic(2, ...)`, `LookAtTargetSink(45, 90)`, `MoveToTargetSink`, temptation cooldown countdown); IDLE
(priority 1 `FollowTemptation(speed 1.25, stop distance 3.0)`; priorities 2 and 3 `BabyFollowAdult(range, speed 1.1)` (two variants); priority 4 one-of {`RandomStroll.fly(1)`, `SetWalkTargetFromLookTarget(1, 3)`, ...}); PANIC (while `IS_PANICKING`). Order: PANIC, IDLE. Panic speed multiplier 2.0.

Rules:

- Travel uses `travelFlying` with `FLYING_SPEED * 5 / 3`. Walk-target value: 0 when the cell is not air; otherwise 10 when the cell below is air and the cell two below is not air, else 5.
- Restriction radius `r`: 64 when the ghast is an adult and its body slot is empty; 32 when it is a baby or the harness (body armor) is equipped. `checkRestriction` runs each server tick, only when the ghast is not leashed and not carrying a passenger: when it has no home, or the home is farther than `r + 16` blocks from its block position, or the stored home radius differs from `r`, the home is set to the current block position with radius `r`.
- Healing (`continuousHeal`, server, alive, `deathTime == 0`, only while health differs from max health): the period is 20 ticks (`FAST_HEALING_TICKS`) when it is in clouds or `precipitationAt(position)` is not NONE, otherwise 600 ticks (`SLOW_HEALING_TICKS`); it heals 1 hp when `tickCount` is a multiple of the period.
- Leash holder state: metadata 18 is the "leash holder" flag. `HappyGhast.tick()` returns early on the client, so the counter `leashHolderTime` is server side: it counts down once per tick, and the flag is `leashHolderTime > 0`. The counter is started by `notifyLeashHolder(Leashable)`, which sets it to 5 when the leashed entity supports a quad leash.

Harness and riding: only an adult accepts an item in the `BODY` equipment slot; a dispenser may equip it. Right-click by a player without secondary use while the body slot is occupied: the player rides (`startRiding`, server).
Capacity: 4 passengers. When the first passenger boards the harness-goggles-down sound plays, and on the server (after adding the passenger) the still timeout is set to 0 when no player is standing above the ghast, otherwise capped to at most 10. When a passenger leaves, the server sets the still timeout to 10; when the last leaves the home is cleared and the goggles-up sound plays.
The controlling passenger is the first passenger if it is a player, the body slot is occupied and the ghast is not on its still timeout. Ridden input: strafe from `xxa` always applies; the forward and vertical components (`cos(pitch)` horizontally and `-sin(pitch)` vertically, both multiplied by -0.5 when moving backward) apply only when the forward input is non-zero; +0.5 vertical while jumping; the vector is scaled by `3.9 * FLYING_SPEED`.
Ridden rotation: `yRot += wrapDegrees(riderYaw - yRot) * 0.08`; pitch = rider pitch x 0.5; head and body yaw follow.
Still timeout (`serverStillTimeout`, maximum 10, ignored for the first 60 ticks of life): while positive the ghast holds still (a position sync packet is sent when it first becomes positive, metadata 19 is true); it counts down by 1 per tick; it is reset to 10 each tick while `scanPlayerAboveGhast` is true. `scanPlayerAboveGhast`: the box from `(minX - 1, maxY - 0.00001, minZ - 1)` to `(maxX + 1, maxY + height / 2, maxZ + 1)` of the ghast's bounding box; it tests the position of each non-spectator player's root vehicle (the player's own position when not riding) against it and skips the player only when that root vehicle is a happy ghast.

### 8.12 Eye of ender (`EyeOfEnder`)

Type `eye_of_ender`, 0.25 x 0.25, range 4, update interval 4, no loot, not attackable, ignores all damage. Metadata 8 = item stack (default `ender_eye`; set with count 1). Created by the throwing item at a position, then `signalTo(target)`:
`d = target - position`, `h = horizontal length of d`; if `h > 12` the target becomes `position + (dx / h * 12, 8.0, dz / h * 12)`, else the given position; `life = 0`; `surviveAfterDeath = (nextInt(5) > 0)` (probability 4/5).

Per tick: `newPos = position + velocity`; server with a target: `velocity = update(velocity, newPos, target)`; the entity moves to `newPos`; server: `life += 1`; when `life > 80`: play the eye-death sound, discard, and then either (survives) spawn an `ItemEntity` with the eye's item at its position, or (does not) play world event 2003 (the eye shatters). The client spawns portal particles (bubbles in water).
`update(v, p, t)`: `dh = (t.x - p.x, 0, t.z - p.z)`, `L = |dh|`; `s = lerp(0.0025, horizontal speed of v, L)`; `vy = v.y`; when `L < 1` both `s` and `vy` are multiplied by 0.8; `dir = +1` when `p.y - v.y < t.y`, else `-1` (read from the comparison of the position and the target height); result =
`dh * (s / L) + (0, vy + (dir - vy) * 0.015, 0)`.

### 8.13 Thrown experience bottle (`ThrownExperienceBottle`)

Type `experience_bottle`, 0.25 x 0.25, range 4, update interval 10, no loot; gravity 0.07; metadata 8 = item stack (default `experience_bottle`). On hit (server): world event 2002 with colour value -13083194, world event 1053 unless silent;
amount `3 + nextInt(5) + nextInt(5)` (3 to 11); `ExperienceOrb.awardWithDirection(hitLocation, direction, amount)` (the position is the hit location, not the bottle's position) where `direction` is the unit normal of the hit face for a block hit, else the negative of the bottle's velocity (orb splitting: §8.2); the bottle is discarded.

### 8.14 Llama spit (`LlamaSpit`)

Type `llama_spit`, 0.25 x 0.25, range 4, update interval 10, no delta tracking, no loot. Gravity 0.06; air drag 0.99 per tick; discarded when it enters water. Spawned by a llama (owner = the llama) at
`(x - (width + 1) * 0.5 * sin(bodyYaw), eyeY - 0.1, z + (width + 1) * 0.5 * cos(bodyYaw))`. Each tick: hit test along the velocity; discarded when none of the cells in its box has an air block state (that is, when it is inside solid blocks), and discarded by any block hit on the server; hit on an entity: if the owner is a living entity, `hurt(spit(self, owner), 1.0)` and post-attack effects.

### 8.15 Leash knot (`LeashFenceKnotEntity`)

Type `leash_knot`, 0.375 x 0.5, eye 0.0625, range 10, not saved, no update interval, no delta tracking. Position: block position + `(0.5, 0.375, 0.5)` (`OFFSET_Y` 0.375); its box is centred there. It survives while the block at its position is in block tag `fences`; rendered only within 32 blocks
(distance squared below 1024). Interaction (`interact`): with shears the default shear behaviour first; otherwise every leashable entity leashed to the player that accepts a leash on the knot is re-leashed to the knot; if none moved and the player is not using secondary action, the entities leashed to
the knot are re-leashed to the player; on either success the `BLOCK_ATTACH` game event and the lead-tied sound play. When the last leashed entity is removed (`notifyLeasheeRemoved`) the knot discards itself. Breaking plays the lead-untied sound. Its Add Entity packet (05a 0x01) carries the knot's block position in the `Data` field (`getAddEntityPacket` passes `getPos()`).

### 8.16 Cushion and mannequin

`cushion`: type size 1.0 x 0.25 (builder), range 10, no update interval, no delta tracking, no loot table; a block-attached decoration entity (it extends the decoration base). Metadata 8 = colour (dye id, 00 §13.2 serializer 43). Interaction: a player without secondary use
and while nobody sits on it right-clicks to sit (`startRiding`, sit sound; the get-up sound plays when the passenger leaves and the entity is not being removed). Breaking: break sound and particles; drops the cushion item of its colour (with its data) unless the `entity_drops` rule is off or the breaker has infinite materials;
a drop caused by lightning gets 20 ticks of invulnerability. Breaking by a player is refused when the player may not build or may not interact at the position.

`mannequin`: type size 0.6 x 1.8, eye 1.62, range 32, update interval 2; a living avatar entity that shows a player skin. Metadata: 15 main hand (humanoid arm: 0 left, 1 right), 16 model customisation (Byte; default all layers set = the 7 model-part bits = 127), 17 profile (resolvable profile, 00 §13.3), 18 immovable (Boolean),
19 description (optional component; default translation `entity.minecraft.mannequin.label`). NBT keys: `profile`, `hidden_layers`, `main_hand`, `pose` (allowed values: standing, crouching, swimming, fall_flying, sleeping), `immovable`, `description`, `hide_description`.

### 8.17 Ominous item spawner (`OminousItemSpawner`)

Type `ominous_item_spawner`, 0.25 x 0.25, range 8, no loot, no physics. Metadata 8 = item stack. Created with an item and `spawn_item_after_ticks = nextIntBetween(60, 120)` (inclusive). Server tick: when `tickCount == spawnAfter - 36` the about-to-spawn sound plays; when `tickCount >= spawnAfter`: if the item is a projectile item
it is launched downward (direction DOWN) with the item's dispense power and uncertainty, owner = the spawner; otherwise an `ItemEntity` with the stack appears at its position; then world event 3021 (data 1), the `ENTITY_PLACE` game event, the stack is cleared and the spawner is killed. Client: particles every 5 game ticks. NBT keys: `item`, `spawn_item_after_ticks`.

### 8.18 Breeze wind charge (explosion parameters)

`breeze_wind_charge`: 0.3125 x 0.3125, range 4, update interval 10 (§2). Its owner is 20 (it is shot by the breeze) and the base projectile is `wind_charge` (17 §3.15). Only the explosion was read here: `BreezeWindCharge.explode` creates an explosion at the hit position with radius 3.0, no fire,
interaction `TRIGGER`, the shared `EXPLOSION_DAMAGE_CALCULATOR` (`SimpleExplosionDamageCalculator` over the `blocks_wind_charge` block tag), particles `gust_emitter_small` and `gust_emitter_large` and the breeze wind charge burst sound. Flight and deflection are the base class's (not read).

## 9. Worked examples

Each example gives inputs and the expected outputs derived from the rules above, for tests.

**E1. Tropical fish packing.** Pattern `flopper` (large shape, index 0, `packedId` 0x0001), base colour `gray` (id 7), pattern colour
`blue` (id 11): `packed = 0x0001 | (7 << 16) | (11 << 24) = 0x0B070001 = 185008129`. Unpack: shape `0x01` large, pattern index `(packed >> 8) & 0xFF = 0`
(flopper), base `(packed >> 16) & 0xFF = 7` gray, pattern colour `packed >> 24 = 11` blue. The default variant (kob, white, white) packs to 0.
Common variant 2 (flopper, gray, blue) is exactly this value. Metadata wire form for the fish: index 17, serializer 1 (INT = VarInt, 00 §13.2), the VarInt of 185008129.

**E2. Pufferfish timeline.** A deflated pufferfish (state 0, both counters 0) with a scary mob at 1.5 blocks. Tick 1: the goal starts (`inflateCounter = 1`, `deflateTimer = 0`);
the tick method sees `inflateCounter > 0` and state 0: blow-up sound, state 1; counter 2. Ticks 2 to 41: counter reaches 41 at the end of tick 40; the first tick with
`inflateCounter > 40` and state 1 is tick 41 (counter value 41): state 2. If the mob leaves, `inflateCounter = 0`; with `deflateTimer` at 0 it increments every tick; the first tick with
`deflateTimer > 60` while in state 2 is the 62nd deflating tick (the value 61): state 1; the first tick with `deflateTimer > 100` in state 1 is when the value is 101: state 0. A
state-2 pufferfish that touches a player deals `hurt(mobAttack, 3)` and applies Poison for 120 ticks (`60 * 2`); a state-1 one deals 2 and 60 ticks.

**E3. Piglin barter distribution.** The pool weights sum to 469. `obsidian` has probability 40/469 = 0.0853; `ender_pearl` 10/469 = 0.0213; `book` 5/469 = 0.0107. A
`gold_ingot` thrown by a player into reach of an adult piglin with an empty off hand: picked up, admiring starts (119 ticks); at tick 119 the ingot is consumed and one roll of the table is
thrown toward the nearest visible player; admiring disabled for 400 ticks does not apply to a normal successful barter (it is set when admiring is cancelled by damage).

**E4. Cube mob arithmetic.** A size 4 magma cube: health 16, speed `0.2f + 0.1f * 4` in float32 = 0.6000000238418579 as double, `ATTACK_DAMAGE` 4 (melee 6 with the +2), armor 12, XP 4, jump
delay `(nextInt(20) + 10) * 4` ticks (40 to 156). Its death creates `2 + nextInt(3)` children of size 2 (health 4, speed 0.4, attack 2, armor 6). Spawn size: with the roll
`r = nextInt(3)`: `r = 2` -> size 4; `r < 2` -> size `1 << (r + 1)` with probability `0.5 * specialMultiplier`, else `1 << r`.

**E5. Guardian beam damage.** Hard difficulty, elder guardian: the beam deals `1 + 2 + 2 = 5` indirect-magic damage, immediately followed by one melee hit using `ATTACK_DAMAGE` 8; a plain guardian on
Normal deals 1 + the melee hit 6. The beam completes after 80 ticks (guardian) or 60 (elder), counted from `attackTime = -10` at the start: so the first damage happens 90 or 70 ticks after the
goal starts.

**E6. Dragon death XP.** First kill: `B = 12000`: orbs worth `floor(12000 * 0.08) = 960` XP are awarded on ticks 155, 160, ..., 200 of the death counter (10 awards) and `floor(12000 * 0.2) = 2400` at tick
200: total 12000. Later kills: `B = 500`: `floor(40) = 40` ten times plus `floor(100) = 100` = 500. Splitting 960 into orbs: `value(960) = 617`; remaining 343 -> 307; 36 -> 17; 19 -> 17; 2 -> 1; 1 -> 1: orbs 617, 307, 17, 17, 1, 1.

**E7. Experience orb split.** `award(100)`: 73 (remaining 27), 17 (10), 7 (3), 3 (0): four orbs 73, 17, 7, 3.

**E8. Pillar geometry.** Position `i = 0`: angle `2 * (-pi + 0) = -2*pi`: `centerX = floor(42 * cos) = 42`, `centerZ = floor(42 * sin(-2*pi))`; in IEEE double `sin(-2*pi)` is
`+2.449e-16` so `centerZ = 0`. Position `i = 5`: the angle is exactly `-pi` in double arithmetic (`0.3141592653589793 * 5 = 1.5707963267948966`), `cos = -1`, `sin = -1.2246e-16`: `centerX = -42`, `centerZ = floor(-5.1e-15) = -1`.
Implementations must use IEEE doubles and floor. If the shuffled value for position 0 is `s = 7`: `radius = 2 + 7/3 = 4`, `height = 76 + 21 = 97`, not guarded; `s = 1` or `2`: radius 2, height 79 or 82, guarded.
Shuffle check: for the order list `[0..9]` and a random source whose first draws are `nextInt(10) = 3`, `nextInt(9) = 0`: the first step swaps element 9 with element 3, the second swaps element 8 with element 0.

**E9. Flight graph.** Node 0: `a = 2 * (-3.1415927f + 0) = -6.2831855f`; `Mth.cos` gives 1.0, `Mth.sin` a tiny positive float, so `(x, z) = (60, 0)`; Y = `max(73, surface(60, 0) + 5)`.
Node 3 (outer, `j = 3`): the table lookups give `(0, 60)`. Node 10: `(29, -52)`. Node 12 (middle, `j = 0`): `(40, 0)`, Y = `max(73, surface + 15)`; node 14: `(0, 40)`; node 20: `(20, 0)`.
Node 0 is adjacent to the nodes whose bits are set in 6146 = `0b1100000000010` = bits 1, 11, 12: nodes 1, 11 and 12. With no crystals alive `findClosestNode` ignores nodes 0 to 11 and the holding pattern keeps the
index in `12..19` via `((n - 12) & 7) + 12`: from node 19 moving clockwise gives `n = 20`, `((20 - 12) & 7) + 12 = 12`.

**E10. Wither spawn timeline.** At skull placement: health 100, `invulnerableTicks = 220`, bar progress 0. Tick `k` of the sequence (1-based): bar progress `1 - (220 - k) / 220`; heals 10 on ticks where
`tickCount % 10 == 0`; at `k = 220` the explosion of power 7.0 and world event 1023; afterwards the bar shows `health / 300`. Powered threshold: health 150. Skull damage to a player: 8.0 `witherSkull` damage plus Wither II for
0 / 200 / 800 ticks on Easy / Normal / Hard (`20 * {0, 10, 40}`).

## 10. Validation

How the contents were checked in this round and what a test suite should assert.

- Entity registry: 161 entries, ids 0 to 160 contiguous (counting the static initializer's registrations); the Add Entity type VarInt is the registration index (04 §5.1). Spot checks from the table: `ender_dragon` = 44, `shulker` = 115, `wither` = 149, `guardian` = 64,
  `ghast` = 58, `piglin` = 102, `strider` = 132, `player` = 159, `fishing_bobber` = 160.
- Tables copied by script from the artifact (not by hand): the entity table (§2), the biome spawn tables (§3.3, §3.4), the structure overrides (§3.5), the entity-type tags (§3.6), spawn placements (§3.1), the metadata appendix (Appendix A) and the
  barter table. Totals to assert: barter weights 469; tropical fish common variants 22; salmon spawn weights 30 + 50 + 15 = 95; flight graph nodes 24; pillars 10; gateways 20; Wither armor 4.0; dragon health 200; wither health 300.
- Behavioural assertions (expected results of the formulas above): E1 to E10.
- Differential checks a test harness can run against a vanilla 26.3 client: the packed tropical fish variant renders the pattern and colours; the Boss Event ADD fields for the dragon (PINK, PROGRESS, flags 0x06) and the wither (PURPLE, PROGRESS, flags 0x01); entity events 4 (hoglin
  attack), 7 and 6 (tame success and failure), 19 (squid tentacle reset), 21 (guardian attack sound), 38 (dolphin happy particles); Game Events 9 and 10.
- Cross-reference check: every entity type has exactly one owner row in §2 (21: 85 rows including constants-only entries, 17: 10, 19: 35, 20: 30, 13: 1; total 161). Entities owned elsewhere are not specified here; the sections named in §2 are the home.

## 11. Open questions

1. **Ownership counts.** §2 follows the assignment given by the coordinator (19 owns 35 entity types, 20 owns 30, 17 owns 10). If a later document moves an entity, update its §2 row.
2. **Biome `overlay` modifier.** Every biome's `natural_mob_spawns` attribute carries `"modifier": "overlay"`; how it combines with other sources (for example a dimension-level list) was not read. The tables reproduce each biome file as stored.
3. **Bastion remnants and Nether fortress piece placement:** which pieces carry a piglin, piglin brute or hoglin spawner or a preplaced mob (structure generation, not read). Fortress natural spawns are in §3.5.
4. **Piglin details not expanded:** the exact conditions in `wasHurtBy`, `maybeRetaliate`, `isNearestValidAttackTarget`, `StartHuntingHoglin`, `RememberIfHoglinWasKilled`, `PiglinAi.isZombified`, the value of the `piglins_zombify` environment attribute per dimension, and which block interactions call `angerNearbyPiglins`.
5. **Recall.** Nothing in this document was taken from memory without a read; none of the statements is marked "(recalled, not verified)".
6. **Spawn predicates not given here:** `Turtle`, `Slime` and `Animal` (owned by 19 and 20).
7. **Fish flop spacing**, **dolphin on-ground hop guard**, and the filter inside `MobEffectUtil.addEffectToPlayersAround` (elder guardian) were not fully read.
8. **Squid XP reward** (generic Mob rule) and breeding food of squids and dolphins were not read.
9. **Axolotl:** the exact branch structure of the play-dead damage test, where `useRareVariant` is applied, and the use of `REHYDRATE_AIR_SUPPLY` were not traced.
10. **Nautilus:** idle behaviours, ride and dash control, tame-state bits, armor, `ChargeAttack` internals, the `NAUTILUS_TEMPTATIONS` sensor and `ZombieNautilusAi` were not expanded.
11. **Strider:** the held-item test and boost of steering, `StriderGoToLavaGoal` and the strider path navigation were not read.
12. **Dragon phase hooks:** each phase's `onCrystalDestroyed` hook was not read; `strafePlayer` (holding pattern) is described only as switching to STRAFE_PLAYER with the player as target; the strafe path creation was not expanded.
13. **Not read:** item pickup and throw delays; `thunderHit` effects; the area effect cloud application loop (`serverTick`); armor stand interaction and pose rules; item frame and painting survival and placement; `interaction` and `marker` details; display interpolation.
14. **Boats and minecarts:** buoyancy, steering, rail physics, slope handling, chest inventories, `MinecartBehavior` selection. Only constants and metadata are given.
15. (resolved: the default eye height is `0.85 x height`, §2.)
16. **Piglin and hoglin loot** conditions are not applicable (no pools); piglin anger for `UNIVERSAL_ANGER` memory is registered but its writer was not read.
17. **Cushion** survival check (`tickAtCheckInterval`) and mannequin interaction rules were not read.
18. (resolved: the bat spawn rule is fully described in §8.10.)
19. **Happy ghast:** natural spawning path (no biome entry), growth by feeding, harness item identity, `HappyGhastFloatGoal` and `BabyFlyingPathNavigation` were not read.
20. (resolved: the Wither is described in §7.2; its client-only powered effects are not specified.)
21. (resolved: llama spit, §8.14.)
22. **Hoglin/zoglin spawn weights in structures** are not applicable (none read).

## Appendix A. Entity metadata (own fields) for every entity type

Index and serializer name (00 §13.2 for the wire form). "Last inherited index" is the highest index owned by the common bases:
7 = entity base, 14 = living entity base, 15 = mob base. Display entities list their own fields from index 8. The 22 boat, chest boat and raft types have identical fields and are listed in one row.

| Entity | Last inherited index | Own metadata fields (index name serializer) |
|---|---|---|
| `acacia_boat`, `acacia_chest_boat`, `bamboo_chest_raft`, `bamboo_raft`, `birch_boat`, `birch_chest_boat`, `cherry_boat`, `cherry_chest_boat`, `dark_oak_boat`, `dark_oak_chest_boat`, `jungle_boat`, `jungle_chest_boat`, `mangrove_boat`, `mangrove_chest_boat`, `oak_boat`, `oak_chest_boat`, `pale_oak_boat`, `pale_oak_chest_boat`, `poplar_boat`, `poplar_chest_boat`, `spruce_boat`, `spruce_chest_boat` | 7 | 8 DATA_ID_HURT INT; 9 DATA_ID_HURTDIR INT; 10 DATA_ID_DAMAGE FLOAT; 11 DATA_ID_PADDLE_LEFT BOOLEAN; 12 DATA_ID_PADDLE_RIGHT BOOLEAN; 13 DATA_ID_BUBBLE_TIME INT |
| `allay` | 15 | 16 DATA_DANCING BOOLEAN; 17 DATA_CAN_DUPLICATE BOOLEAN |
| `area_effect_cloud` | 7 | 8 DATA_RADIUS FLOAT; 9 DATA_WAITING BOOLEAN; 10 DATA_PARTICLE PARTICLE |
| `armadillo` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 ARMADILLO_STATE ARMADILLO_STATE |
| `armor_stand` | 14 | 15 DATA_CLIENT_FLAGS BYTE; 16 DATA_HEAD_POSE ROTATIONS; 17 DATA_BODY_POSE ROTATIONS; 18 DATA_LEFT_ARM_POSE ROTATIONS; 19 DATA_RIGHT_ARM_POSE ROTATIONS; 20 DATA_LEFT_LEG_POSE ROTATIONS; 21 DATA_RIGHT_LEG_POSE ROTATIONS |
| `arrow` | 7 | 8 ID_FLAGS BYTE; 9 PIERCE_LEVEL BYTE; 10 IN_GROUND BOOLEAN; 11 ID_EFFECT_COLOR INT |
| `axolotl` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_VARIANT INT; 19 DATA_PLAYING_DEAD BOOLEAN; 20 FROM_BUCKET BOOLEAN |
| `bat` | 15 | 16 DATA_ID_FLAGS BYTE |
| `bee` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_FLAGS_ID BYTE; 19 DATA_ANGER_END_TIME LONG |
| `blaze` | 15 | 16 DATA_FLAGS_ID BYTE |
| `block_display` | 7 | 8 DATA_TRANSFORMATION_INTERPOLATION_START_DELTA_TICKS_ID INT; 9 DATA_TRANSFORMATION_INTERPOLATION_DURATION_ID INT; 10 DATA_POS_ROT_INTERPOLATION_DURATION_ID INT; 11 DATA_TRANSLATION_ID VECTOR3; 12 DATA_SCALE_ID VECTOR3; 13 DATA_LEFT_ROTATION_ID QUATERNION; 14 DATA_RIGHT_ROTATION_ID QUATERNION; 15 DATA_BILLBOARD_RENDER_CONSTRAINTS_ID BYTE; 16 DATA_BRIGHTNESS_OVERRIDE_ID INT; 17 DATA_VIEW_RANGE_ID FLOAT; 18 DATA_SHADOW_RADIUS_ID FLOAT; 19 DATA_SHADOW_STRENGTH_ID FLOAT; 20 DATA_WIDTH_ID FLOAT; 21 DATA_HEIGHT_ID FLOAT; 22 DATA_GLOW_COLOR_OVERRIDE_ID INT; 23 DATA_BLOCK_STATE_ID BLOCK_STATE |
| `bogged` | 15 | 16 DATA_SHEARED BOOLEAN |
| `breeze` | 15 | - |
| `breeze_wind_charge` | 7 | - |
| `camel` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_ID_FLAGS BYTE; 19 DASH BOOLEAN; 20 LAST_POSE_CHANGE_TICK LONG |
| `camel_husk` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_ID_FLAGS BYTE; 19 DASH BOOLEAN; 20 LAST_POSE_CHANGE_TICK LONG |
| `cat` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_FLAGS_ID BYTE; 19 DATA_OWNERUUID_ID OPTIONAL_LIVING_ENTITY_REFERENCE; 20 DATA_VARIANT_ID CAT_VARIANT; 21 IS_LYING BOOLEAN; 22 RELAX_STATE_ONE BOOLEAN; 23 DATA_COLLAR_COLOR INT; 24 DATA_SOUND_VARIANT_ID CAT_SOUND_VARIANT |
| `cave_spider` | 15 | 16 DATA_FLAGS_ID BYTE |
| `chest_minecart` | 7 | 8 DATA_ID_HURT INT; 9 DATA_ID_HURTDIR INT; 10 DATA_ID_DAMAGE FLOAT; 11 DATA_ID_CUSTOM_DISPLAY_BLOCK OPTIONAL_BLOCK_STATE; 12 DATA_ID_DISPLAY_OFFSET INT |
| `chicken` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_VARIANT_ID CHICKEN_VARIANT; 19 DATA_SOUND_VARIANT_ID CHICKEN_SOUND_VARIANT |
| `cod` | 15 | 16 FROM_BUCKET BOOLEAN |
| `copper_golem` | 15 | 16 DATA_WEATHER_STATE WEATHERING_COPPER_STATE; 17 COPPER_GOLEM_STATE COPPER_GOLEM_STATE |
| `command_block_minecart` | 7 | 8 DATA_ID_HURT INT; 9 DATA_ID_HURTDIR INT; 10 DATA_ID_DAMAGE FLOAT; 11 DATA_ID_CUSTOM_DISPLAY_BLOCK OPTIONAL_BLOCK_STATE; 12 DATA_ID_DISPLAY_OFFSET INT; 13 DATA_ID_COMMAND_NAME STRING; 14 DATA_ID_LAST_OUTPUT COMPONENT |
| `cow` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_VARIANT_ID COW_VARIANT; 19 DATA_SOUND_VARIANT_ID COW_SOUND_VARIANT |
| `creaking` | 15 | 16 CAN_MOVE BOOLEAN; 17 IS_ACTIVE BOOLEAN; 18 IS_TEARING_DOWN BOOLEAN; 19 HOME_POS OPTIONAL_BLOCK_POS |
| `creeper` | 15 | 16 DATA_SWELL_DIR INT; 17 DATA_IS_POWERED BOOLEAN; 18 DATA_IS_IGNITED BOOLEAN |
| `cushion` | 7 | 8 DATA_COLOR DYE_COLOR |
| `dolphin` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 GOT_FISH BOOLEAN; 19 MOISTNESS_LEVEL INT |
| `donkey` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_ID_FLAGS BYTE; 19 DATA_ID_CHEST BOOLEAN |
| `dragon_fireball` | 7 | - |
| `drowned` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 DATA_SPECIAL_TYPE_ID INT; 18 DATA_DROWNED_CONVERSION_ID BOOLEAN |
| `egg` | 7 | 8 DATA_ITEM_STACK ITEM_STACK |
| `elder_guardian` | 15 | 16 DATA_ID_MOVING BOOLEAN; 17 DATA_ID_ATTACK_TARGET INT |
| `enderman` | 15 | 16 DATA_CARRY_STATE OPTIONAL_BLOCK_STATE; 17 DATA_CREEPY BOOLEAN; 18 DATA_STARED_AT BOOLEAN |
| `endermite` | 15 | - |
| `ender_dragon` | 15 | 16 DATA_PHASE INT |
| `ender_pearl` | 7 | 8 DATA_ITEM_STACK ITEM_STACK |
| `end_crystal` | 7 | 8 DATA_BEAM_TARGET OPTIONAL_BLOCK_POS; 9 DATA_SHOW_BOTTOM BOOLEAN |
| `evoker` | 15 | 16 IS_CELEBRATING BOOLEAN; 17 DATA_SPELL_CASTING_ID BYTE |
| `evoker_fangs` | 7 | - |
| `experience_bottle` | 7 | 8 DATA_ITEM_STACK ITEM_STACK |
| `experience_orb` | 7 | 8 DATA_VALUE INT |
| `eye_of_ender` | 7 | 8 DATA_ITEM_STACK ITEM_STACK |
| `falling_block` | 7 | 8 DATA_START_POS BLOCK_POS |
| `fireball` | 7 | 8 DATA_ITEM_STACK ITEM_STACK |
| `firework_rocket` | 7 | 8 DATA_ID_FIREWORKS_ITEM ITEM_STACK; 9 DATA_ATTACHED_TO_TARGET OPTIONAL_UNSIGNED_INT; 10 DATA_SHOT_AT_ANGLE BOOLEAN |
| `fox` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_TYPE_ID INT; 19 DATA_FLAGS_ID BYTE; 20 DATA_TRUSTED_ID_0 OPTIONAL_LIVING_ENTITY_REFERENCE; 21 DATA_TRUSTED_ID_1 OPTIONAL_LIVING_ENTITY_REFERENCE |
| `frog` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_VARIANT_ID FROG_VARIANT; 19 DATA_TONGUE_TARGET_ID OPTIONAL_UNSIGNED_INT |
| `furnace_minecart` | 7 | 8 DATA_ID_HURT INT; 9 DATA_ID_HURTDIR INT; 10 DATA_ID_DAMAGE FLOAT; 11 DATA_ID_CUSTOM_DISPLAY_BLOCK OPTIONAL_BLOCK_STATE; 12 DATA_ID_DISPLAY_OFFSET INT; 13 DATA_ID_FUEL BOOLEAN |
| `ghast` | 15 | 16 DATA_IS_CHARGING BOOLEAN |
| `happy_ghast` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 IS_LEASH_HOLDER BOOLEAN; 19 STAYS_STILL BOOLEAN |
| `giant` | 15 | - |
| `glow_item_frame` | 7 | 8 DATA_DIRECTION DIRECTION; 9 DATA_ITEM ITEM_STACK; 10 DATA_ROTATION INT |
| `glow_squid` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_DARK_TICKS_REMAINING INT |
| `goat` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_IS_SCREAMING_GOAT BOOLEAN; 19 DATA_HAS_LEFT_HORN BOOLEAN; 20 DATA_HAS_RIGHT_HORN BOOLEAN |
| `guardian` | 15 | 16 DATA_ID_MOVING BOOLEAN; 17 DATA_ID_ATTACK_TARGET INT |
| `hoglin` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_IMMUNE_TO_ZOMBIFICATION BOOLEAN |
| `hopper_minecart` | 7 | 8 DATA_ID_HURT INT; 9 DATA_ID_HURTDIR INT; 10 DATA_ID_DAMAGE FLOAT; 11 DATA_ID_CUSTOM_DISPLAY_BLOCK OPTIONAL_BLOCK_STATE; 12 DATA_ID_DISPLAY_OFFSET INT |
| `horse` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_ID_FLAGS BYTE; 19 DATA_ID_TYPE_VARIANT INT |
| `husk` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 DATA_SPECIAL_TYPE_ID INT; 18 DATA_DROWNED_CONVERSION_ID BOOLEAN |
| `illusioner` | 15 | 16 IS_CELEBRATING BOOLEAN; 17 DATA_SPELL_CASTING_ID BYTE |
| `interaction` | 7 | 8 DATA_WIDTH_ID FLOAT; 9 DATA_HEIGHT_ID FLOAT; 10 DATA_RESPONSE_ID BOOLEAN |
| `iron_golem` | 15 | 16 DATA_FLAGS_ID BYTE |
| `item` | 7 | 8 DATA_ITEM ITEM_STACK |
| `item_display` | 7 | 8 DATA_TRANSFORMATION_INTERPOLATION_START_DELTA_TICKS_ID INT; 9 DATA_TRANSFORMATION_INTERPOLATION_DURATION_ID INT; 10 DATA_POS_ROT_INTERPOLATION_DURATION_ID INT; 11 DATA_TRANSLATION_ID VECTOR3; 12 DATA_SCALE_ID VECTOR3; 13 DATA_LEFT_ROTATION_ID QUATERNION; 14 DATA_RIGHT_ROTATION_ID QUATERNION; 15 DATA_BILLBOARD_RENDER_CONSTRAINTS_ID BYTE; 16 DATA_BRIGHTNESS_OVERRIDE_ID INT; 17 DATA_VIEW_RANGE_ID FLOAT; 18 DATA_SHADOW_RADIUS_ID FLOAT; 19 DATA_SHADOW_STRENGTH_ID FLOAT; 20 DATA_WIDTH_ID FLOAT; 21 DATA_HEIGHT_ID FLOAT; 22 DATA_GLOW_COLOR_OVERRIDE_ID INT; 23 DATA_ITEM_STACK_ID ITEM_STACK; 24 DATA_ITEM_DISPLAY_ID BYTE |
| `item_frame` | 7 | 8 DATA_DIRECTION DIRECTION; 9 DATA_ITEM ITEM_STACK; 10 DATA_ROTATION INT |
| `leash_knot` | 7 | - |
| `lightning_bolt` | 7 | - |
| `llama` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_ID_FLAGS BYTE; 19 DATA_ID_CHEST BOOLEAN; 20 DATA_STRENGTH_ID INT; 21 DATA_VARIANT_ID INT |
| `llama_spit` | 7 | - |
| `magma_cube` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 ID_SIZE INT |
| `mannequin` | 14 | 15 DATA_PLAYER_MAIN_HAND HUMANOID_ARM; 16 DATA_PLAYER_MODE_CUSTOMISATION BYTE; 17 DATA_PROFILE RESOLVABLE_PROFILE; 18 DATA_IMMOVABLE BOOLEAN; 19 DATA_DESCRIPTION OPTIONAL_COMPONENT |
| `marker` | 7 | - |
| `minecart` | 7 | 8 DATA_ID_HURT INT; 9 DATA_ID_HURTDIR INT; 10 DATA_ID_DAMAGE FLOAT; 11 DATA_ID_CUSTOM_DISPLAY_BLOCK OPTIONAL_BLOCK_STATE; 12 DATA_ID_DISPLAY_OFFSET INT |
| `mooshroom` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_TYPE INT |
| `mule` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_ID_FLAGS BYTE; 19 DATA_ID_CHEST BOOLEAN |
| `nautilus` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_FLAGS_ID BYTE; 19 DATA_OWNERUUID_ID OPTIONAL_LIVING_ENTITY_REFERENCE; 20 DASH BOOLEAN |
| `ocelot` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_TRUSTING BOOLEAN |
| `ominous_item_spawner` | 7 | 8 DATA_ITEM ITEM_STACK |
| `painting` | 7 | 8 DATA_DIRECTION DIRECTION; 9 DATA_PAINTING_VARIANT_ID PAINTING_VARIANT |
| `panda` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 UNHAPPY_COUNTER INT; 19 SNEEZE_COUNTER INT; 20 EAT_COUNTER INT; 21 MAIN_GENE_ID BYTE; 22 HIDDEN_GENE_ID BYTE; 23 DATA_ID_FLAGS BYTE |
| `parched` | 15 | - |
| `parrot` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_FLAGS_ID BYTE; 19 DATA_OWNERUUID_ID OPTIONAL_LIVING_ENTITY_REFERENCE; 20 DATA_VARIANT_ID INT |
| `phantom` | 15 | 16 ID_SIZE INT |
| `pig` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_BOOST_TIME INT; 19 DATA_VARIANT_ID PIG_VARIANT; 20 DATA_SOUND_VARIANT_ID PIG_SOUND_VARIANT |
| `piglin` | 15 | 16 DATA_IMMUNE_TO_ZOMBIFICATION BOOLEAN; 17 DATA_BABY_ID BOOLEAN; 18 DATA_IS_CHARGING_CROSSBOW BOOLEAN; 19 DATA_IS_DANCING BOOLEAN |
| `piglin_brute` | 15 | 16 DATA_IMMUNE_TO_ZOMBIFICATION BOOLEAN |
| `pillager` | 15 | 16 IS_CELEBRATING BOOLEAN; 17 IS_CHARGING_CROSSBOW BOOLEAN |
| `polar_bear` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_STANDING_ID BOOLEAN |
| `splash_potion` | 7 | 8 DATA_ITEM_STACK ITEM_STACK |
| `lingering_potion` | 7 | 8 DATA_ITEM_STACK ITEM_STACK |
| `pufferfish` | 15 | 16 FROM_BUCKET BOOLEAN; 17 PUFF_STATE INT |
| `rabbit` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_TYPE_ID INT |
| `ravager` | 15 | 16 IS_CELEBRATING BOOLEAN |
| `salmon` | 15 | 16 FROM_BUCKET BOOLEAN; 17 DATA_TYPE INT |
| `sheep` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_WOOL_ID BYTE |
| `shulker` | 15 | 16 DATA_ATTACH_FACE_ID DIRECTION; 17 DATA_PEEK_ID BYTE; 18 DATA_COLOR_ID BYTE |
| `shulker_bullet` | 7 | - |
| `silverfish` | 15 | - |
| `skeleton` | 15 | 16 DATA_STRAY_CONVERSION_ID BOOLEAN |
| `skeleton_horse` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_ID_FLAGS BYTE |
| `slime` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 ID_SIZE INT |
| `small_fireball` | 7 | 8 DATA_ITEM_STACK ITEM_STACK |
| `sniffer` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_STATE SNIFFER_STATE; 19 DATA_DROP_SEED_AT_TICK INT |
| `snowball` | 7 | 8 DATA_ITEM_STACK ITEM_STACK |
| `snow_golem` | 15 | 16 DATA_PUMPKIN_ID BYTE |
| `spawner_minecart` | 7 | 8 DATA_ID_HURT INT; 9 DATA_ID_HURTDIR INT; 10 DATA_ID_DAMAGE FLOAT; 11 DATA_ID_CUSTOM_DISPLAY_BLOCK OPTIONAL_BLOCK_STATE; 12 DATA_ID_DISPLAY_OFFSET INT |
| `spectral_arrow` | 7 | 8 ID_FLAGS BYTE; 9 PIERCE_LEVEL BYTE; 10 IN_GROUND BOOLEAN |
| `spider` | 15 | 16 DATA_FLAGS_ID BYTE |
| `squid` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN |
| `stray` | 15 | - |
| `strider` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_BOOST_TIME INT; 19 DATA_SUFFOCATING BOOLEAN |
| `sulfur_cube` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 ID_SIZE INT; 19 MAX_FUSE INT; 20 FROM_BUCKET BOOLEAN |
| `tadpole` | 15 | 16 FROM_BUCKET BOOLEAN; 17 AGE_LOCKED BOOLEAN |
| `text_display` | 7 | 8 DATA_TRANSFORMATION_INTERPOLATION_START_DELTA_TICKS_ID INT; 9 DATA_TRANSFORMATION_INTERPOLATION_DURATION_ID INT; 10 DATA_POS_ROT_INTERPOLATION_DURATION_ID INT; 11 DATA_TRANSLATION_ID VECTOR3; 12 DATA_SCALE_ID VECTOR3; 13 DATA_LEFT_ROTATION_ID QUATERNION; 14 DATA_RIGHT_ROTATION_ID QUATERNION; 15 DATA_BILLBOARD_RENDER_CONSTRAINTS_ID BYTE; 16 DATA_BRIGHTNESS_OVERRIDE_ID INT; 17 DATA_VIEW_RANGE_ID FLOAT; 18 DATA_SHADOW_RADIUS_ID FLOAT; 19 DATA_SHADOW_STRENGTH_ID FLOAT; 20 DATA_WIDTH_ID FLOAT; 21 DATA_HEIGHT_ID FLOAT; 22 DATA_GLOW_COLOR_OVERRIDE_ID INT; 23 DATA_TEXT_ID COMPONENT; 24 DATA_LINE_WIDTH_ID INT; 25 DATA_BACKGROUND_COLOR_ID INT; 26 DATA_TEXT_OPACITY_ID BYTE; 27 DATA_STYLE_FLAGS_ID BYTE |
| `tnt` | 7 | 8 DATA_FUSE_ID INT; 9 DATA_BLOCK_STATE_ID BLOCK_STATE |
| `tnt_minecart` | 7 | 8 DATA_ID_HURT INT; 9 DATA_ID_HURTDIR INT; 10 DATA_ID_DAMAGE FLOAT; 11 DATA_ID_CUSTOM_DISPLAY_BLOCK OPTIONAL_BLOCK_STATE; 12 DATA_ID_DISPLAY_OFFSET INT |
| `trader_llama` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_ID_FLAGS BYTE; 19 DATA_ID_CHEST BOOLEAN; 20 DATA_STRENGTH_ID INT; 21 DATA_VARIANT_ID INT |
| `trident` | 7 | 8 ID_FLAGS BYTE; 9 PIERCE_LEVEL BYTE; 10 IN_GROUND BOOLEAN; 11 ID_LOYALTY BYTE; 12 ID_FOIL BOOLEAN |
| `tropical_fish` | 15 | 16 FROM_BUCKET BOOLEAN; 17 DATA_ID_TYPE_VARIANT INT |
| `turtle` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 HAS_EGG BOOLEAN; 19 LAYING_EGG BOOLEAN |
| `vex` | 15 | 16 DATA_FLAGS_ID BYTE |
| `villager` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_UNHAPPY_COUNTER INT; 19 DATA_VILLAGER_DATA VILLAGER_DATA; 20 DATA_VILLAGER_DATA_FINALIZED BOOLEAN |
| `vindicator` | 15 | 16 IS_CELEBRATING BOOLEAN |
| `wandering_trader` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_UNHAPPY_COUNTER INT |
| `warden` | 15 | 16 CLIENT_ANGER_LEVEL INT |
| `wind_charge` | 7 | - |
| `witch` | 15 | 16 IS_CELEBRATING BOOLEAN; 17 DATA_USING_ITEM BOOLEAN |
| `wither` | 15 | 16 DATA_TARGET_A INT; 17 DATA_TARGET_B INT; 18 DATA_TARGET_C INT; 19 DATA_ID_INV INT |
| `wither_skeleton` | 15 | - |
| `wither_skull` | 7 | 8 DATA_DANGEROUS BOOLEAN |
| `wolf` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_FLAGS_ID BYTE; 19 DATA_OWNERUUID_ID OPTIONAL_LIVING_ENTITY_REFERENCE; 20 DATA_INTERESTED_ID BOOLEAN; 21 DATA_COLLAR_COLOR INT; 22 DATA_ANGER_END_TIME LONG; 23 DATA_VARIANT_ID WOLF_VARIANT; 24 DATA_SOUND_VARIANT_ID WOLF_SOUND_VARIANT |
| `zoglin` | 15 | 16 DATA_BABY_ID BOOLEAN |
| `zombie` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 DATA_SPECIAL_TYPE_ID INT; 18 DATA_DROWNED_CONVERSION_ID BOOLEAN |
| `zombie_horse` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_ID_FLAGS BYTE |
| `zombie_nautilus` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 AGE_LOCKED BOOLEAN; 18 DATA_FLAGS_ID BYTE; 19 DATA_OWNERUUID_ID OPTIONAL_LIVING_ENTITY_REFERENCE; 20 DASH BOOLEAN; 21 DATA_VARIANT_ID ZOMBIE_NAUTILUS_VARIANT |
| `zombie_villager` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 DATA_SPECIAL_TYPE_ID INT; 18 DATA_DROWNED_CONVERSION_ID BOOLEAN; 19 DATA_CONVERTING_ID BOOLEAN; 20 DATA_VILLAGER_DATA VILLAGER_DATA; 21 DATA_VILLAGER_DATA_FINALIZED BOOLEAN |
| `zombified_piglin` | 15 | 16 DATA_BABY_ID BOOLEAN; 17 DATA_SPECIAL_TYPE_ID INT; 18 DATA_DROWNED_CONVERSION_ID BOOLEAN |
| `player` | 14 | 15 DATA_PLAYER_MAIN_HAND HUMANOID_ARM; 16 DATA_PLAYER_MODE_CUSTOMISATION BYTE; 17 DATA_PLAYER_ABSORPTION_ID FLOAT; 18 DATA_SCORE_ID INT; 19 DATA_SHOULDER_PARROT_LEFT OPTIONAL_UNSIGNED_INT; 20 DATA_SHOULDER_PARROT_RIGHT OPTIONAL_UNSIGNED_INT |
| `fishing_bobber` | 7 | 8 DATA_HOOKED_ENTITY INT; 9 DATA_BITING BOOLEAN |
