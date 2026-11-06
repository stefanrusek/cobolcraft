# Mob framework: entity model, AI, pathfinding, spawning, combat, tracking

| Item | Value |
|---|---|
| Covers | The shared framework every mob builds on: the entity type registry, categories, attributes and modifiers, entity metadata base slots, the per-tick update order of living entities and mobs, entity physics, the goal and target selectors and the shared goal catalogue, the control classes, the Brain system, A* pathfinding and node evaluators, natural spawning (mob caps, positions, packs, light, placements, despawn), spawners, finishing a spawn, damage, knockback, death, drops and experience, breeding, ageing, taming and leashing basics, and the server-side tracking and sending rules |
| Does not cover | Per-mob parameters (see the per-mob catalogues 19, 20 and 21, which cite this document for "goal X priority n with params"); the per-mob metadata slots beyond the base chain; per-mob loot tables beyond the format |
| Version | 26.3, protocol 777, world data version 5023 (already recorded in [README.md](README.md)) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in README.md) |
| Method | Static reading of the shipped bytecode (`javap`), with no execution. Data tables (entity types, attributes, path types, mob categories, spawn placements, biome spawns, dimension types, timelines) were extracted mechanically from the class constants and from the JSON data in the jar. |

Reading conventions:

- A fact marked **(inferred)** was deduced from partial bytecode plus the structure of the surrounding code and was not seen in full. Everything else was read directly.
- Class and method names in backticks say where something was read. They are not the design.
- "Tick" is one server tick (50 ms). "Block units" are blocks. `rand` is the entity's own random source (`Mob.getRandom`) unless said otherwise. The game's random generators and their seeding are not specified by the artifact for these uses; any uniform generator is acceptable (CobolCraft does not need to reproduce vanilla's random streams).
- Player movement is already specified in [13](13-client-gameplay-and-controls.md) §1. This document extends that to non-player entities and does not repeat the player-only parts.
- Entity wire packets (Add Entity, Move Entity, Teleport, Set Entity Motion, Set Entity Data, Update Attributes, Entity Event, Set Equipment, Set Passengers, Rotate Head, Damage Event, Hurt Animation) are defined in [05a](05a-play-clientbound-00-71.md) and [05b](05b-play-clientbound-72-143.md); here only the rules for **when** they are sent are given (section 9).

---

## 1. Entity types

### 1.1 Registry

The entity type registry is a static registry (04 §5): the numeric id is the registration index in `EntityTypes`' static initialiser, starting at 0. The table below lists every entry in that order (161 entries, ids 0 to 160). Columns:

- **cat**: mob category (section 1.2): MO monster, C creature, AM ambient, AX axolotls, UWC underground water creature, WC water creature, WA water ambient, MI misc.
- **w x h**: the collision box (`sized(width, height)`); the box is centred on the entity position horizontally and starts at the position's y.
- **eye**: eye height. An entry marked `*` has no explicit eye height; the default is height x 0.85.
- **track**: `clientTrackingRange` in chunks (section 9.1). The builder default is 5.
- **upd**: update interval in ticks (section 9.2). The builder default is 3. `-` means `noUpdateInterval` (value 2147483647: never sends periodic updates).
- **flags**: `fire` fire immune; `noloot` has no loot table; `nosave` is never written to disk; `nosummon` cannot be summoned by command or spawner; `nopeace` is removed in Peaceful difficulty (`notInPeaceful`); `nodelta` does not track velocity deltas (`dontTrackDeltas`); `far` explicitly allowed to spawn far from the player (`canSpawnFarFromPlayer`, see 6.5).

Defaults for fields not listed: `serialize` true, `summon` true, `allowedInPeaceful` true, `trackDeltas` true. `canSpawnFarFromPlayer` defaults to true exactly for categories CREATURE and MISC, otherwise false. Block-damage immunity (`immuneTo`) is a block tag per type: default `DEFAULT_IMMUNE_TO`; fox, polar bear, snow golem, stray, wither and wither skeleton use their own tag (`FOX_IMMUNE_TO`, `POLAR_BEAR_IMMUNE_TO`, `SNOW_GOLEM_IMMUNE_TO`, `STRAY_IMMUNE_TO`, `WITHER_IMMUNE_TO`, `WITHER_SKELETON_IMMUNE_TO`); these tags decide which blocks do not hurt the entity when it stands in or touches them (contents of the tags are in the jar's block tag data and are synchronised by Update Tags, 04).

Types registered with a size scale at spawn (`spawnDimensionsScale`): magma_cube 4.0, slime 4.0, sulfur_cube 2.0 (these three are the cube mobs; their real size is width/height times a size factor, defined per mob).

| id | key | cat | w x h | eye | track | upd | flags |
|---|---|---|---|---|---|---|---|
| 0 | acacia_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 1 | acacia_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 2 | allay | C | 0.35 x 0.6 | 0.36 | 8 | 2 |  |
| 3 | area_effect_cloud | MI | 6.0 x 0.5 | 0.425* | 10 | - | noloot fire noupd |
| 4 | armadillo | C | 0.7 x 0.65 | 0.26 | 10 | 3 |  |
| 5 | armor_stand | MI | 0.5 x 1.975 | 1.7775 | 10 | 3 |  |
| 6 | arrow | MI | 0.5 x 0.5 | 0.13 | 4 | 20 | noloot |
| 7 | axolotl | AX | 0.75 x 0.42 | 0.2751 | 10 | 3 |  |
| 8 | bamboo_chest_raft | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 9 | bamboo_raft | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 10 | bat | AM | 0.5 x 0.9 | 0.45 | 5 | 3 | nodelta |
| 11 | bee | C | 0.55 x 0.5 | 0.3 | 8 | 3 |  |
| 12 | birch_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 13 | birch_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 14 | blaze | MO | 0.6 x 1.8 | 1.53* | 8 | 3 | fire nopeace |
| 15 | block_display | MI | 0 x 0 | 0.0* | 10 | 1 | noloot |
| 16 | bogged | MO | 0.6 x 1.99 | 1.74 | 8 | 3 | nopeace |
| 17 | breeze | MO | 0.6 x 1.77 | 1.3452 | 10 | 3 | nopeace |
| 18 | breeze_wind_charge | MI | 0.3125 x 0.3125 | 0 | 4 | 10 | noloot |
| 19 | camel | C | 1.7 x 2.375 | 2.275 | 10 | 3 |  |
| 20 | camel_husk | MO | 1.7 x 2.375 | 2.275 | 10 | 3 |  |
| 21 | cat | C | 0.6 x 0.7 | 0.35 | 8 | 3 |  |
| 22 | cave_spider | MO | 0.7 x 0.5 | 0.45 | 8 | 3 | nopeace |
| 23 | cherry_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 24 | cherry_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 25 | chest_minecart | MI | 0.98 x 0.7 | 0.595* | 8 | 3 | noloot |
| 26 | chicken | C | 0.4 x 0.7 | 0.644 | 10 | 3 |  |
| 27 | cod | WA | 0.5 x 0.3 | 0.195 | 4 | 3 |  |
| 28 | copper_golem | MI | 0.49 x 0.98 | 0.8125 | 10 | 3 |  |
| 29 | command_block_minecart | MI | 0.98 x 0.7 | 0.595* | 8 | 3 | noloot |
| 30 | cow | C | 0.9 x 1.4 | 1.3 | 10 | 3 |  |
| 31 | creaking | MO | 0.9 x 2.7 | 2.3 | 8 | 3 | nopeace |
| 32 | creeper | MO | 0.6 x 1.7 | 1.445* | 8 | 3 | nopeace |
| 33 | cushion | MI | 1 x 0.25 | 0.2125* | 10 | 2147483647 | noloot nodelta |
| 34 | dark_oak_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 35 | dark_oak_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 36 | dolphin | WC | 0.9 x 0.6 | 0.3 | 5 | 3 |  |
| 37 | donkey | C | 1.3964844 x 1.5 | 1.425 | 10 | 3 |  |
| 38 | dragon_fireball | MI | 1 x 1 | 0.85* | 4 | 10 | noloot |
| 39 | drowned | MO | 0.6 x 1.95 | 1.74 | 8 | 3 | nopeace |
| 40 | egg | MI | 0.25 x 0.25 | 0.2125* | 4 | 10 | noloot |
| 41 | elder_guardian | MO | 1.9975 x 1.9975 | 0.99875 | 10 | 3 | nopeace |
| 42 | enderman | MO | 0.6 x 2.9 | 2.55 | 8 | 3 | nopeace |
| 43 | endermite | MO | 0.4 x 0.3 | 0.13 | 8 | 3 | nopeace |
| 44 | ender_dragon | MO | 16.0 x 8.0 | 6.8* | 10 | 3 | fire |
| 45 | ender_pearl | MI | 0.25 x 0.25 | 0.2125* | 4 | 10 | noloot |
| 46 | end_crystal | MI | 2 x 2 | 1.7* | 16 | - | noloot fire noupd nodelta |
| 47 | evoker | MO | 0.6 x 1.95 | 1.6575* | 8 | 3 | nopeace |
| 48 | evoker_fangs | MI | 0.5 x 0.8 | 0.68* | 6 | 2 | noloot nodelta |
| 49 | experience_bottle | MI | 0.25 x 0.25 | 0.2125* | 4 | 10 | noloot |
| 50 | experience_orb | MI | 0.5 x 0.5 | 0.425* | 6 | 20 | noloot |
| 51 | eye_of_ender | MI | 0.25 x 0.25 | 0.2125* | 4 | 4 | noloot |
| 52 | falling_block | MI | 0.98 x 0.98 | 0.833* | 10 | 20 | noloot |
| 53 | fireball | MI | 1 x 1 | 0.85* | 4 | 10 | noloot |
| 54 | firework_rocket | MI | 0.25 x 0.25 | 0.2125* | 4 | 10 | noloot |
| 55 | fox | C | 0.6 x 0.7 | 0.4 | 8 | 3 | immune:FOX_IMMUNE_TO |
| 56 | frog | C | 0.5 x 0.5 | 0.425* | 10 | 3 |  |
| 57 | furnace_minecart | MI | 0.98 x 0.7 | 0.595* | 8 | 3 | noloot |
| 58 | ghast | MO | 4.0 x 4.0 | 2.6 | 10 | 3 | fire nopeace |
| 59 | happy_ghast | C | 4.0 x 4.0 | 2.6 | 10 | 3 |  |
| 60 | giant | MO | 3.6 x 12.0 | 10.44 | 10 | 3 | nopeace |
| 61 | glow_item_frame | MI | 0.5 x 0.5 | 0 | 10 | - | noloot noupd nodelta |
| 62 | glow_squid | UWC | 0.8 x 0.8 | 0.4 | 10 | 3 |  |
| 63 | goat | C | 0.9 x 1.3 | 1.105* | 10 | 3 |  |
| 64 | guardian | MO | 0.85 x 0.85 | 0.425 | 8 | 3 | nopeace |
| 65 | hoglin | MO | 1.3964844 x 1.4 | 1.19* | 8 | 3 | nopeace |
| 66 | hopper_minecart | MI | 0.98 x 0.7 | 0.595* | 8 | 3 | noloot |
| 67 | horse | C | 1.3964844 x 1.6 | 1.52 | 10 | 3 |  |
| 68 | husk | MO | 0.6 x 1.95 | 1.74 | 8 | 3 | nopeace |
| 69 | illusioner | MO | 0.6 x 1.95 | 1.6575* | 8 | 3 | nopeace |
| 70 | interaction | MI | 0 x 0 | 0.0* | 10 | 3 | noloot |
| 71 | iron_golem | MI | 1.4 x 2.7 | 2.295* | 10 | 3 |  |
| 72 | item | MI | 0.25 x 0.25 | 0.2125 | 6 | 20 | noloot |
| 73 | item_display | MI | 0 x 0 | 0.0* | 10 | 1 | noloot |
| 74 | item_frame | MI | 0.5 x 0.5 | 0 | 10 | - | noloot noupd nodelta |
| 75 | jungle_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 76 | jungle_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 77 | leash_knot | MI | 0.375 x 0.5 | 0.0625 | 10 | - | noloot nosave noupd nodelta |
| 78 | lightning_bolt | MI | 0 x 0 | 0.0* | 16 | - | noloot nosave noupd |
| 79 | llama | C | 0.9 x 1.87 | 1.7765 | 10 | 3 |  |
| 80 | llama_spit | MI | 0.25 x 0.25 | 0.2125* | 4 | 10 | noloot nodelta |
| 81 | magma_cube | MO | 0.52 x 0.52 | 0.325 | 8 | 3 | fire spawnDimensionsScale(4.0) nopeace |
| 82 | mangrove_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 83 | mangrove_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 84 | mannequin | MI | 0.6 x 1.8 | 1.62 | 32 | 2 |  |
| 85 | marker | MI | 0 x 0 | 0.0* | 0 | 3 | noloot |
| 86 | minecart | MI | 0.98 x 0.7 | 0.595* | 8 | 3 | noloot |
| 87 | mooshroom | C | 0.9 x 1.4 | 1.3 | 10 | 3 |  |
| 88 | mule | C | 1.3964844 x 1.6 | 1.52 | 8 | 3 |  |
| 89 | nautilus | WC | 0.875 x 0.95 | 0.2751 | 10 | 3 |  |
| 90 | oak_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 91 | oak_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 92 | ocelot | C | 0.6 x 0.7 | 0.595* | 10 | 3 |  |
| 93 | ominous_item_spawner | MI | 0.25 x 0.25 | 0.2125* | 8 | 3 | noloot |
| 94 | painting | MI | 0.5 x 0.5 | 0.425* | 10 | - | noloot noupd nodelta |
| 95 | pale_oak_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 96 | pale_oak_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 97 | panda | C | 1.3 x 1.25 | 1.0625* | 10 | 3 |  |
| 98 | parched | MO | 0.6 x 1.99 | 1.74 | 8 | 3 | nopeace |
| 99 | parrot | C | 0.5 x 0.9 | 0.54 | 8 | 3 |  |
| 100 | phantom | MO | 0.9 x 0.5 | 0.175 | 8 | 3 | nopeace |
| 101 | pig | C | 0.9 x 0.9 | 0.765* | 10 | 3 |  |
| 102 | piglin | MO | 0.6 x 1.95 | 1.79 | 8 | 3 |  |
| 103 | piglin_brute | MO | 0.6 x 1.95 | 1.79 | 8 | 3 | nopeace |
| 104 | pillager | MO | 0.6 x 1.95 | 1.6575* | 8 | 3 | far nopeace |
| 105 | polar_bear | C | 1.4 x 1.4 | 1.19* | 10 | 3 | immune:POLAR_BEAR_IMMUNE_TO |
| 106 | poplar_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 107 | poplar_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 108 | splash_potion | MI | 0.25 x 0.25 | 0.2125* | 4 | 10 | noloot |
| 109 | lingering_potion | MI | 0.25 x 0.25 | 0.2125* | 4 | 10 | noloot |
| 110 | pufferfish | WA | 0.7 x 0.7 | 0.455 | 4 | 3 |  |
| 111 | rabbit | C | 0.49 x 0.6 | 0.59 | 8 | 3 |  |
| 112 | ravager | MO | 1.95 x 2.2 | 1.87* | 10 | 3 | nopeace |
| 113 | salmon | WA | 0.7 x 0.4 | 0.26 | 4 | 3 |  |
| 114 | sheep | C | 0.9 x 1.3 | 1.235 | 10 | 3 |  |
| 115 | shulker | MO | 1 x 1 | 0.5 | 10 | 3 | fire far |
| 116 | shulker_bullet | MI | 0.3125 x 0.3125 | 0.2656* | 8 | 3 | noloot |
| 117 | silverfish | MO | 0.4 x 0.3 | 0.13 | 8 | 3 | nopeace |
| 118 | skeleton | MO | 0.6 x 1.99 | 1.74 | 8 | 3 | nopeace |
| 119 | skeleton_horse | C | 1.3964844 x 1.6 | 1.52 | 10 | 3 |  |
| 120 | slime | MO | 0.52 x 0.52 | 0.325 | 10 | 3 | spawnDimensionsScale(4.0) nopeace |
| 121 | small_fireball | MI | 0.3125 x 0.3125 | 0.2656* | 4 | 10 | noloot |
| 122 | sniffer | C | 1.9 x 1.75 | 1.05 | 10 | 3 |  |
| 123 | snowball | MI | 0.25 x 0.25 | 0.2125* | 4 | 10 | noloot |
| 124 | snow_golem | MI | 0.7 x 1.9 | 1.7 | 8 | 3 | immune:SNOW_GOLEM_IMMUNE_TO |
| 125 | spawner_minecart | MI | 0.98 x 0.7 | 0.595* | 8 | 3 | noloot |
| 126 | spectral_arrow | MI | 0.5 x 0.5 | 0.13 | 4 | 20 | noloot |
| 127 | spider | MO | 1.4 x 0.9 | 0.65 | 8 | 3 | nopeace |
| 128 | spruce_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 129 | spruce_chest_boat | MI | 1.375 x 0.5625 | 0.5625 | 10 | 3 | noloot |
| 130 | squid | WC | 0.8 x 0.8 | 0.4 | 8 | 3 |  |
| 131 | stray | MO | 0.6 x 1.99 | 1.74 | 8 | 3 | immune:STRAY_IMMUNE_TO nopeace |
| 132 | strider | C | 0.9 x 1.7 | 1.445* | 10 | 3 | fire |
| 133 | sulfur_cube | MO | 0.49 x 0.49 | 0.175 | 10 | 3 | spawnDimensionsScale(2) |
| 134 | tadpole | C | 0.4 x 0.3 | 0.19500001 | 10 | 3 |  |
| 135 | text_display | MI | 0 x 0 | 0.0* | 10 | 1 | noloot |
| 136 | tnt | MI | 0.98 x 0.98 | 0.15 | 10 | 10 | noloot fire |
| 137 | tnt_minecart | MI | 0.98 x 0.7 | 0.595* | 8 | 3 | noloot |
| 138 | trader_llama | C | 0.9 x 1.87 | 1.7765 | 10 | 3 |  |
| 139 | trident | MI | 0.5 x 0.5 | 0.13 | 4 | 20 | noloot |
| 140 | tropical_fish | WA | 0.5 x 0.4 | 0.26 | 4 | 3 |  |
| 141 | turtle | C | 1.2 x 0.4 | 0.34* | 10 | 3 |  |
| 142 | vex | MO | 0.4 x 0.8 | 0.51875 | 8 | 3 | fire nopeace |
| 143 | villager | MI | 0.6 x 1.95 | 1.62 | 10 | 3 |  |
| 144 | vindicator | MO | 0.6 x 1.95 | 1.6575* | 8 | 3 | nopeace |
| 145 | wandering_trader | C | 0.6 x 1.95 | 1.62 | 10 | 3 |  |
| 146 | warden | MO | 0.9 x 2.9 | 2.465* | 16 | 3 | fire nopeace |
| 147 | wind_charge | MI | 0.3125 x 0.3125 | 0 | 4 | 10 | noloot |
| 148 | witch | MO | 0.6 x 1.95 | 1.62 | 8 | 3 | nopeace |
| 149 | wither | MO | 0.9 x 3.5 | 2.975* | 10 | 3 | fire immune:WITHER_IMMUNE_TO nopeace nodelta |
| 150 | wither_skeleton | MO | 0.7 x 2.4 | 2.1 | 8 | 3 | fire immune:WITHER_SKELETON_IMMUNE_TO nopeace |
| 151 | wither_skull | MI | 0.3125 x 0.3125 | 0.2656* | 4 | 10 | noloot |
| 152 | wolf | C | 0.6 x 0.85 | 0.68 | 10 | 3 |  |
| 153 | zoglin | MO | 1.3964844 x 1.4 | 1.19* | 8 | 3 | fire nopeace |
| 154 | zombie | MO | 0.6 x 1.95 | 1.74 | 8 | 3 | nopeace |
| 155 | zombie_horse | MO | 1.3964844 x 1.6 | 1.52 | 10 | 3 |  |
| 156 | zombie_nautilus | MO | 0.875 x 0.95 | 0.2751 | 10 | 3 |  |
| 157 | zombie_villager | MO | 0.6 x 1.95 | 1.74 | 8 | 3 | nopeace |
| 158 | zombified_piglin | MO | 0.6 x 1.95 | 1.79 | 8 | 3 | fire nopeace |
| 159 | player | MI | 0.6 x 1.8 | 1.62 | 32 | 2 | nosave nosummon nodelta |
| 160 | fishing_bobber | MI | 0.25 x 0.25 | 0.2125* | 4 | 5 | noloot nosave nosummon |


### 1.1.1 Passenger attachments and riding offsets

Read from the `EntityType.Builder` calls (`passengerAttachments`, `ridingOffset`, `vehicleAttachment`, `attach`, `nameTagOffset`). `passengerAttachments(y...)` gives one passenger seat per value at `(0, y, 0)` relative to the entity position (the float form); the `Vec3` form gives full seat offsets (x, y, z; z positive is the entity's front). `ridingOffset(r)` is the y offset applied to the entity's own position when **it** rides something (the vehicle's seat y plus `ridingOffset`). Types not listed have no declared attachments (the default seat is at the top of the bounding box, `height`, **(inferred)**). Boats, rafts and chest boats declare none here: their seats are computed in the boat classes (Open question 1).

| Type | Passenger seat(s) | Riding offset | Other |
|---|---|---|---|
| allay | none | 0.04 | |
| bogged, skeleton, stray, parched | none | -0.7 | |
| cat | y 0.5125 | | |
| chicken | (0, 0.7, -0.1) | | |
| cow, mooshroom | y 1.36875 | | |
| donkey | y 1.1125 | | |
| mule | y 1.2125 | | |
| horse | y 1.44375 | | |
| skeleton_horse, zombie_horse | y 1.31875 | | |
| camel | none declared | | (Open question 1) |
| drowned, husk, piglin, piglin_brute, zombie | y 2.0125 (husk 2.075) | -0.7 | |
| zombie_villager | y 2.125 | -0.7 | |
| zombified_piglin | y 2 | -0.7 | |
| evoker, illusioner, pillager, vindicator | y 2 | -0.6 | |
| witch | y 2.2625 | | |
| elder_guardian | y 2.350625 | | |
| guardian | y 0.975 | | |
| enderman | y 2.80625 | | |
| endermite, silverfish | y 0.2375 | | |
| ender_dragon | y 3.0 | | |
| fox | (0, 0.6375, -0.25) | | |
| frog | (0, 0.375, -0.25) | | |
| ghast | y 4.0625 | 0.5 | |
| happy_ghast | 4 seats: (0, 4.0, 1.7), (-1.7, 4.0, 0), (0, 4.0, -1.7), (1.7, 4.0, 0) | 0.5 | |
| giant | none | -3.75 | |
| goat | y 1.1125 | | |
| hoglin, zoglin | y 1.49375 | | |
| llama, trader_llama | (0, 1.37, -0.3) | | |
| nautilus, zombie_nautilus | y 1.1375 | | |
| ocelot | y 0.6375 | | |
| parrot | y 0.4625 | | |
| phantom | y 0.3375 | -0.125 | |
| pig | y 0.86875 | | |
| ravager | (0, 2.2625, -0.0625) | | |
| sheep | y 1.2375 | | |
| sniffer | y 2.09375 | | name tag y 2.05 |
| spider | y 0.765 | | |
| turtle | (0, 0.55625, -0.25) | | |
| vex | y 0.7375 | 0.04 | |
| warden | y 3.15 | | chest attachment (0, 1.6, 0) |
| wither_skeleton | none | -0.875 | |
| wolf | (0, 0.81875, -0.0625) | | |
| minecart, chest/furnace/hopper/command_block/spawner/tnt minecart | y 0.1875 | | |
| player, mannequin | | | `vehicleAttachment` (value not captured; Open question 1) |


### 1.2 Mob categories (`MobCategory`)

| Category | Serialized name | Cap per chunk-unit (`max`) | Friendly | Persistent | Despawn distance | Notes |
|---|---|---|---|---|---|---|
| MONSTER | monster | 70 | no | no | 128 | |
| CREATURE | creature | 10 | yes | yes | 128 | spawned only on the 400-tick friendly cycle (section 6.1) |
| AMBIENT | ambient | 15 | yes | no | 128 | |
| AXOLOTLS | axolotls | 5 | yes | no | 128 | |
| UNDERGROUND_WATER_CREATURE | underground_water_creature | 5 | yes | no | 128 | |
| WATER_CREATURE | water_creature | 5 | yes | no | 128 | |
| WATER_AMBIENT | water_ambient | 20 | yes | no | 64 | |
| MISC | misc | 1 | yes | yes | 128 | never naturally spawned (not in the spawning list) |

The "no-despawn distance" is 32 for every category. "Friendly" and "persistent" are used by the spawner (6.1), "despawn distance" by despawn (6.11) and by the spawn validity rules (6.5). The categories that take part in natural spawning are all but MISC, in the order of the table (`SPAWNING_CATEGORIES`).

### 1.3 Attributes

Attributes are a static registry (id = registration index in `Attributes`, in the order below). "Sync" = the attribute is sent to clients in Update Attributes (05b 0x86). The registry's resource name is `minecraft:<name>`. Every attribute is a ranged attribute: its value is clamped to [min, max] after modifiers.

| id | name | default | min | max | sync |
|---|---|---|---|---|---|
| 0 | air_drag_modifier | 1 | 0 | 2048 | yes |
| 1 | armor | 0 | 0 | 30 | yes |
| 2 | armor_toughness | 0 | 0 | 20 | yes |
| 3 | attack_damage | 2 | 0 | 2048 | no |
| 4 | attack_knockback | 0 | 0 | 5 | no |
| 5 | attack_speed | 4 | 0 | 1024 | yes |
| 6 | below_name_distance | 10 | 0 | 512 | yes |
| 7 | block_break_speed | 1 | 0 | 1024 | yes |
| 8 | block_interaction_range | 4.5 | 0 | 64 | yes |
| 9 | bounciness | 0 | 0 | 1 | yes |
| 10 | burning_time | 1 | 0 | 1024 | yes (negative sentiment) |
| 11 | camera_distance | 4 | 0 | 32 | yes |
| 12 | explosion_knockback_resistance | 0 | 0 | 1 | yes |
| 13 | entity_interaction_range | 3 | 0 | 64 | yes |
| 14 | fall_damage_multiplier | 1 | 0 | 100 | yes (negative) |
| 15 | flying_speed | 0.4 | 0 | 1024 | yes |
| 16 | follow_range | 32 | 0 | 2048 | no |
| 17 | friction_modifier | 1 | 0 | 2048 | yes |
| 18 | gravity | 0.08 | -1 | 1 | yes |
| 19 | jump_strength | 0.41999998688697815 | 0 | 32 | yes |
| 20 | knockback_resistance | 0 | -2 | 1 | no |
| 21 | luck | 0 | -1024 | 1024 | yes |
| 22 | max_absorption | 0 | 0 | 2048 | yes |
| 23 | max_health | 20 | 1 | 1024 | yes |
| 24 | mining_efficiency | 0 | 0 | 1024 | yes |
| 25 | movement_efficiency | 0 | 0 | 1 | yes |
| 26 | movement_speed | 0.7 | 0 | 1024 | yes |
| 27 | name_tag_distance | 64 | 0 | 512 | yes |
| 28 | oxygen_bonus | 0 | 0 | 1024 | yes |
| 29 | safe_fall_distance | 3 | -1024 | 1024 | yes |
| 30 | scale | 1 | 0.0625 | 16 | yes |
| 31 | sneaking_speed | 0.3 | 0 | 1 | yes |
| 32 | spawn_reinforcements | 0 | 0 | 1 | no |
| 33 | step_height | 0.6 | 0 | 10 | yes |
| 34 | submerged_mining_speed | 0.2 | 0 | 20 | yes |
| 35 | sweeping_damage_ratio | 0 | 0 | 1 | yes |
| 36 | tempt_range | 10 | 0 | 2048 | no |
| 37 | water_movement_efficiency | 0 | 0 | 1 | yes |
| 38 | waypoint_transmit_range | 0 | 0 | 60000000 | no |
| 39 | waypoint_receive_range | 0 | 0 | 60000000 | no |

A mob's own attribute set is the set created by its class (`createAttributes`): only attributes in that set exist on the entity, and the class gives base-value overrides. The shared base sets are:

- **Living entity base** (`LivingEntity.createLivingAttributes`), 26 attributes: max_health, knockback_resistance, movement_speed, armor, armor_toughness, max_absorption, step_height, scale, gravity, safe_fall_distance, fall_damage_multiplier, jump_strength, entity_interaction_range, oxygen_bonus, burning_time, explosion_knockback_resistance, water_movement_efficiency, movement_efficiency, attack_knockback, camera_distance, waypoint_transmit_range, bounciness, air_drag_modifier, friction_modifier, name_tag_distance, below_name_distance. Each takes the registry default unless the mob class overrides the base value. `flying_speed` is **not** in this set: flying mobs add it themselves, and `attack_damage`, `follow_range` (Mob), `tempt_range`, `attack_speed`, `luck`, `spawn_reinforcements` exist only where a class adds them.
- **Mob base** (`Mob.createMobAttributes`): the living base plus follow_range with base value **16**. Per-mob classes then set max_health, movement_speed, attack_damage etc. (those values are in the per-mob catalogues).
- `Mob.finalizeSpawn` gives each mob a permanent follow_range modifier `random_spawn_bonus` of operation ADD_MULTIPLIED_BASE, value = triangle(0, 0.11485), i.e. a triangular random in (-0.11485, +0.11485) (section 7.1).

#### Modifiers

An attribute has a base value and a set of modifiers keyed by id. A modifier has an id (resource name), an amount (double) and an operation:

| Operation | id | Effect |
|---|---|---|
| ADD_VALUE | 0 | amount is added to the base |
| ADD_MULTIPLIED_BASE | 1 | amount x (base after ADD_VALUE) is added |
| ADD_MULTIPLIED_TOTAL | 2 | the running total is multiplied by (1 + amount), one factor per modifier |

Value (`AttributeInstance.calculateValue`, read): `v = base + sum of ADD_VALUE amounts`; `r = v`; then `r += v x sum of ADD_MULTIPLIED_BASE amounts` (the multiplied-base amounts are summed first, and multiplied by `v`, the value after ADD_VALUE); then for each ADD_MULTIPLIED_TOTAL modifier in turn `r = r x (1 + amount)`; finally the result is sanitised to the attribute's [min, max] (NaN becomes the minimum). Modifiers may be permanent (saved) or transient. Equipment, status effects, sprinting, powder snow and baby/size changes all use modifiers.

Known framework modifiers: sprinting adds ADD_MULTIPLIED_TOTAL +0.3 to movement_speed (`SPEED_MODIFIER_SPRINTING`), powder snow adds a negative speed modifier (`SPEED_MODIFIER_POWDER_SNOW`).

An attribute change marks it dirty; dirty syncable attributes are sent with Update Attributes (section 9.3).

### 1.4 Entity metadata base slots

Slot numbers are assigned in static-initialiser order up the class chain (the wire format is in 00 §13). Slots up to the first subclass are fixed:

| Slot | Class | Name | Serializer | Default |
|---|---|---|---|---|
| 0 | Entity | shared flags | BYTE | 0 |
| 1 | Entity | air supply | INT | 300 (max air) |
| 2 | Entity | custom name | OPTIONAL_COMPONENT | empty |
| 3 | Entity | custom name visible | BOOLEAN | false |
| 4 | Entity | silent | BOOLEAN | false |
| 5 | Entity | no gravity | BOOLEAN | false |
| 6 | Entity | pose | POSE | STANDING |
| 7 | Entity | ticks frozen | INT | 0 |
| 8 | LivingEntity | living flags | BYTE | 0 |
| 9 | LivingEntity | health | FLOAT | 1.0 (set to max health at spawn) |
| 10 | LivingEntity | effect particles | PARTICLES | empty list |
| 11 | LivingEntity | effect ambience | BOOLEAN | false |
| 12 | LivingEntity | arrow count | INT | 0 |
| 13 | LivingEntity | stinger count | INT | 0 |
| 14 | LivingEntity | sleeping position | OPTIONAL_BLOCK_POS | empty |
| 15 | Mob | mob flags | BYTE | 0 |
| 16 | AgeableMob | is baby | BOOLEAN | false |
| 17 | AgeableMob | age locked | BOOLEAN | false |

Slots 15 and up exist only for Mob subclasses; a plain Entity (such as an item) continues from slot 8 with its own slots. Per-mob slots continue after 15 (Mob), or 17 (AgeableMob and descendants such as Animal). `PathfinderMob` and `Animal` define no slots of their own (their static initialisers define none); `TamableAnimal` defines slots 18 (flags) and 19 (owner), 8.2.

Shared flags (slot 0 bits): 0 on fire, 1 shift key down (crouching), 3 sprinting, 4 swimming, 5 invisible, 6 glowing, 7 fall flying (bit 2 is unused by this version's constants).
Living flags (slot 8): 1 is using an item, 2 off-hand, 4 spin attack.
Mob flags (slot 15): 1 no AI, 2 left-handed, 4 aggressive.
Only values that differ from the slot default are sent when an entity is first paired (`getNonDefaultValues`); afterwards only dirty values are sent (section 9.3).

---

## 2. Per-tick update order

### 2.1 Where the tick runs

`ServerLevel` ticks each entity; for a living mob the sequence is `Mob.tick` -> `LivingEntity.tick` -> `Entity.tick`, with `baseTick`, `aiStep`, `serverAiStep` and `travel` nested as below. Every mob that is within the entity-ticking range of a player is ticked; entities outside it are not.

### 2.2 `Mob.tick`

1. `LivingEntity.tick` (2.3).
2. On the server, when `tickCount mod 5 = 0`, `updateControlFlags`: the goal selector's MOVE and LOOK flags are enabled only if the controlling passenger is not a mob (i.e. nothing is riding it under mob control); the JUMP flag is enabled only if additionally the mob's vehicle is not a boat. A "disabled flag" prevents any goal that needs that flag from starting, and stops running goals that hold it (4.1).

### 2.3 `LivingEntity.tick`

1. `Entity.tick` (which calls `baseTick`, 2.5).
2. Item use state, swim-amount animation.
3. On the server: arrow stuck counter (when above 0, a timer starts at 20 x (30 - arrowCount); each tick it decrements and when it reaches 0 the count drops by one); stinger count the same way; `detectEquipmentUpdates` (equipment changes are queued for Set Equipment); every 20th tick the combat tracker rechecks; sleeping checks.
4. If not removed: `aiStep` (2.6).
5. Body/head rotation bookkeeping: compute the horizontal movement since the previous tick; when the squared distance exceeds 0.0025000002 the body yaw turns toward the movement direction (atan2 minus 90 degrees), with a 180 degree flip applied when moving backwards by more than 95/265 degrees relative to the facing; `tickHeadTurn` smooths `yBodyRot` toward the target; then the previous-tick rotation values are normalised into a 180 degree window.
6. Fall-flying tick counter; sleeping pose forces pitch 0; dirty attributes refreshed; elytra animation; grace timers decrement.

### 2.4 `Mob.baseTick`

`LivingEntity.baseTick` (2.5), then if alive: `if nextInt(1000) < ambientSoundTime++` then `ambientSoundTime = -getAmbientSoundInterval()` and the ambient sound plays. Ambient sound interval: Mob 80, Animal 120 (other mobs override).

### 2.5 `Entity.baseTick` and `LivingEntity.baseTick`

`Entity.baseTick` (read), in order:
1. Update the speed bookkeeping; drop the vehicle link if the vehicle was removed; `boardingCooldown` decrements; handle portal contact; sprint particles; remember `wasInPowderSnow` and clear `isInPowderSnow`; remember `wasEyeInWater`; update the fluid interaction (`updateFluidInteraction`: water and lava heights, fluid pushing) and swimming state.
2. **Fire** (server only): if `remainingFireTicks > 0`: a fire-immune entity (flag `fire`) has its fire cleared; otherwise every tick where `remainingFireTicks mod 20 == 0` and the entity is **not** in lava it takes **1.0** `on_fire` damage, then `remainingFireTicks` decrements by 1; if the count is not above 0 the fire is cleared (`clearFire`). `igniteForSeconds(s)` = `igniteForTicks(floor(s x 20))`; `igniteForTicks(n)` raises `remainingFireTicks` to at least `n` and clears the freeze counter. Water contact extinguishes (`extinguishFire`) elsewhere in the fluid code (not re-read).
3. If in lava: `fallDistance x= 0.5`. Lava contact calls `lavaHurt` (not for fire-immune entities): `lava` damage **4.0** and the burn sound; and `lavaIgnite` (not for fire-immune entities): `igniteForSeconds(15)` (read).
4. `checkBelowWorld`: if `y < minY - 64` then `onBelowWorld`: for a plain entity it is discarded; for a `LivingEntity` it takes **4.0** `fell_out_of_world` damage (`hurt`) every tick until dead.
5. Server: the shared on-fire flag (metadata slot 0 bit 0) is set to `remainingFireTicks > 0`; `firstTick = false`; if the entity is `Leashable`, `Leashable.tickLeash` (8.3).

`LivingEntity.baseTick`, on top (read):

1. Swing animation tick; on first tick sleeping position handling; enchantment tick effects.
2. `Entity.baseTick`.
3. If alive and on the server, for non-players: **in-wall damage**: if the entity's head is inside a solid block (`isInWall`) it takes 1.0 of in_wall damage; **world border** damage when outside the border beyond its safe zone: `floor(-(distanceToBorder + safeZone) x damagePerBlock)` at minimum 1 (only when damagePerBlock > 0).
4. **Air supply**: if the eye is in water and the block there is not a bubble column: when the entity cannot breathe under water (type tag `can_breathe_under_water` or water-breathing effect or a player with invulnerable abilities counts as able), the air supply decreases by 1 per tick (`decreaseAirSupply`, with the `oxygen_bonus` attribute chance: with probability oxygen_bonus/(oxygen_bonus+1) the decrease is skipped); when the air supply is at or below -20 (`shouldTakeDrowningDamage`), it is reset to 0, Entity Event 67 (drown particles) is broadcast and 2.0 `drown` damage is dealt (repeating each time the supply falls back to -20). Riding entities whose vehicle `dismountsUnderwater` are dismounted. Otherwise (not in water) the air supply refills by `increaseAirSupply` (+4 per tick, capped at the maximum; read) up to the maximum of 300. Max air is 300 (`getMaxAirSupply`).
5. Block-change hook when the block position changed.
6. **Timers**: `hurtTime` decrements if above 0; `invulnerableTime` (called `damageCooldownTime` here) decrements if above 0 (except for server players); if dead or dying, `tickDeath` (2.9); `lastHurtByPlayerMemoryTime` decrements (and the remembered player is cleared at 0); `lastHurtMob` cleared if dead; `lastHurtByMob` cleared if dead or if `tickCount - lastHurtByMobTimestamp > 100` (2.8); `tickEffects` (status effects tick); head and body previous rotations are stored.

### 2.6 `LivingEntity.aiStep` (server relevant parts)

In order (read):

1. `noJumpDelay` decrements if above 0.
2. If not interpolating and the entity cannot simulate movement, velocity is scaled by 0.98.
3. Head interpolation steps; equipment tick.
4. **Velocity clean-up**: for non-players each component of velocity whose absolute value is below **0.003** is set to 0 (players use the squared horizontal rule from 13 §1.3).
5. If `isImmobile` (dead, sleeping, or the mob-specific immobility such as a sitting pet or a mob with a no-move state): `jumping = false`, `xxa = 0`, `zza = 0`. Else if `isEffectiveAi` and on the server: **`serverAiStep`** (2.7).
6. **Jump handling**: if `jumping` and the entity is affected by fluids: the fluid height (lava height if in lava, else water height); the entity treats itself as in a fluid deep enough when in water with height > 0 and (not on ground or height > the fluid jump threshold (`getFluidJumpThreshold`: 0.4 for an entity whose eye height is at least 0.4, otherwise 0; read)); in that case, in water: `jumpInLiquid` adds **+0.04** to vertical velocity; in lava likewise (unless on ground in shallow lava, then a normal jump); else if on ground (or in shallow-fluid conditions) and `noJumpDelay = 0`: `jumpFromGround` and `noJumpDelay = 10`. If not jumping, `noJumpDelay = 0`.
   `jumpFromGround`: power = `jump_strength` x block jump factor + jump boost; if power <= 1.0E-5 nothing; vertical velocity = max(power, current vy); sprinting adds 0.2 horizontally along the facing (13 §1.3).
7. `xxa`, `zza` are the strafe and forward inputs (-1..1 scaled by `setSpeed`'s movement speed, see 3.1); `yya` vertical input for flyers.
8. Fall-flying update (not used by mobs except specific ones).
9. **Travel**: `travel(Vec3(xxa, yya, zza))` if `canSimulateMovement` and `isEffectiveAi` (and no player controls it); a rider that is a Player uses `travelRidden`. See 3.2 for what travel does.
10. After travel: block effects applied (`applyEffectsFromBlocks`), `calculateEntityAnimation` (walk animation from horizontal movement).
11. **Freezing** (server): if in powder snow and `canFreeze`, ticks frozen +1 (via `tryAddFrost`); otherwise it decreases by 2 per tick (max with 0). When fully frozen (ticks frozen >= 140) every 40th tick the entity takes 1.0 freeze damage (5.0 for the type tag `freeze_hurts_extra_types`). Entities in `freeze_immune_entity_types` cannot freeze.
12. `pushEntities` (4.4); water-sensitive entities (`isSensitiveToWater`, e.g. enderman, snow golem, blaze) take 1.0 drowning-type damage each tick while in water or rain.

### 2.7 `Mob.aiStep` and `Mob.serverAiStep`

`Mob.aiStep` = `LivingEntity.aiStep` (above) plus:

1. If the type is in tag `burn_in_daylight` (zombies, skeletons and their variants, phantoms, etc.): `burnUndead`: if alive and `isSunBurnTick`: if the sun-protection slot (HEAD) holds a damageable item it takes `nextInt(2)` durability damage; if it holds a non-damageable item nothing happens; if empty the mob is ignited for **8 seconds**.
   `isSunBurnTick` (read): the environment attribute `monsters_burn` at the mob's position is true (the overworld timeline sets it false from tick 12542 and true from tick 23460 of the 24000-tick day, a step change **(inferred as a step)**; i.e. it is true from day-tick 23460 through day-tick 12541); and `lightLevelDependentMagicValue` (brightness at the mob, 0..1) > 0.5; and `nextFloat() x 30 < (brightness - 0.4) x 2`; and not in water or rain or powder snow; and the sky is visible at the mob's eye block.
2. **Loot pickup** (when `canPickUpLoot`, alive, not dead and the game rule `mob_griefing` is on): items within the pickup reach (box inflated by 1 horizontally, 0 vertically, 1) that are not removed, not empty and have no pickup delay are picked up if `wantsToPickUp` (section 7.2).

`Mob.serverAiStep` (called from `aiStep` step 5; read), in order:

1. `noActionTime` += 1.
2. `Sensing.tick` (clears the line-of-sight cache).
3. If `(tickCount + entityId) mod 2 = 0` or `tickCount <= 1`: **target selector `tick()`** then **goal selector `tick()`** (full evaluation, 4.1). On the other ticks: `tickRunningGoals(false)` on both selectors: only goals that return `requiresUpdateEveryTick` have their `tick()` called.
4. `PathNavigation.tick` (3.2).
5. `customServerAiStep` (the per-mob hook; Brain mobs tick their Brain here, 2.10).
6. **Controls**: `MoveControl.tick`, `LookControl.tick`, `JumpControl.tick`, in that order (4.1 and 2.11).

So AI decisions happen every second tick per mob (staggered by entity id), while movement controls and navigation run every tick.

### 2.8 Hurt-by and last-hurt memory

`LivingEntity.lastHurtByMob` (+ `lastHurtByMobTimestamp = tickCount` at the time of damage) is set by `setLastHurtByMob` when an attacker hurts it. It is cleared when the attacker is dead or 100 ticks have passed since the timestamp (checked each tick in `baseTick`). `lastHurtByPlayer` is set when a player (or a player-owned tamed mob) damages it and kept for `PLAYER_HURT_EXPERIENCE_TIME` = 100 ticks (`lastHurtByPlayerMemoryTime`), which gates experience and "killed by player" loot conditions.

### 2.9 Death tick

When `isDeadOrDying` and the level ticks deaths, `tickDeath` runs each tick: `deathTime` += 1; at `deathTime >= 20` (`DEATH_DURATION`) on the server and not yet removed: broadcast Entity Event **60** (poof) and remove the entity with reason KILLED. So a killed mob is visible falling over for 20 ticks, then disappears in a puff. (Experience and drops are created at the moment of death, 7.3, not at removal.)

### 2.10 No-AI and immobile mobs

A mob with the no-AI flag (mob flag 1, `setNoAi`) has `isEffectiveAi` false (`Mob.isEffectiveAi` = the living entity rule and not no-AI). In `LivingEntity.aiStep` this has two effects (both read): `serverAiStep` is not called (no goals, navigation, controls, `customServerAiStep`), and `travel` is not called, so the mob applies no gravity, friction or movement from its own velocity; only effects from outside (knockback velocity is stored but not integrated, pushes, vehicles, `setPos`) can change it. `isImmobile` (dead or dying, sleeping, plus per-mob rules) zeroes `jumping`, `xxa` and `zza`.

---

## 3. Entity physics beyond the player

All values are per tick. Player rules (13 §1) are the same code path: a mob moves by `LivingEntity.travel`, driven by the three inputs `xxa` (strafe), `yya` (vertical, flyers) and `zza` (forward) and by `speed`.

### 3.1 How AI movement becomes inputs

`MoveControl` (4.4) does not move the mob. It sets `speed` (`setSpeed`, a float) and `zza` (forward input 0 or 1), `xxa` (strafe) and rotates the mob's yaw. `LivingEntity.aiStep` then calls `travel(Vec3(xxa, yya, zza))`. In `travelInAir` and the fluid variants, the input vector is rotated by yaw and added to the velocity scaled by:

- on ground: `speed` x 0.21600002 / F^3 where F is the ground friction value described below, when F > 0.6; when F <= 0.6 it is simply `speed` (read: the bytecode applies the friction division only when the modified friction is above 0.6);
- in air: `getFlyingSpeed()`, which **ignores** the `flying_speed` attribute (read): it returns `getSpeed() x 0.1` when the controlling passenger is a Player, otherwise the constant **0.02**. Mobs that fly use `FlyingMoveControl`, which sets `speed` itself (4.4);
- in water (`travelInWater`) the acceleration is 0.02 (see 3.2).

The input vector length is normalised if above 1 (standard `moveRelative` behaviour, 13 §1.3).

`speed` = `movement_speed` attribute x the goal's `speedModifier` (MoveControl, operation MOVE_TO or JUMPING), so a goal "walk at speed 1.0" moves at the attribute value and a panic goal at 1.25 moves 25% faster. Strafe mode uses `movement_speed x speedModifier` too with speedModifier forced to 0.25 by `strafe()`.

### 3.2 `travel`

`LivingEntity.travel(input)` chooses (read):

1. If the entity `shouldTravelInFluid` (it is in a liquid, affected by fluids, and cannot stand on that fluid): `travelInFluid`.
2. Else if fall flying: `travelFallFlying` (elytra; not used by mobs).
3. Else `travelInAir`.

Flying mobs use `travelFlying(input, ...)` from their own `travel` override (see below).

**`travelInAir`** (read):
1. Block under the entity (`getBlockPosBelowThatAffectsMyMovement`, the block 0.500001 below the feet): if on ground, friction F = clamp(1 - (1 - blockFriction) x `friction_modifier`, 0, 1) with blockFriction the block's friction (read: default 0.6; ice, packed ice and frosted ice 0.98; blue ice 0.989; slime block 0.8); in air F = 1.0.
2. Horizontal acceleration by 3.1, the climbing clamp (on a ladder or vine: x,z clamped to +-0.15, y = max(y, -0.15) **(read)**), `move(SELF, velocity)` (collision, 3.3); if the entity collided horizontally while jumping or climbing, vertical velocity becomes 0.2.
3. Vertical: with Levitation, `y += (0.05 x (amplifier + 1) - y) x 0.2`. Otherwise `y -= effective gravity` where effective gravity is the `gravity` attribute (0.08), capped at 0.01 while descending with Slow Falling. For an entity in an unloaded chunk (server side) vertical velocity is -0.1 (or 0 below the world) as a guard.
4. Drag: unless `discardFriction`, horizontal velocity is multiplied by `F_h = F x modified(0.91, air_drag_modifier)` and vertical velocity by `modified(0.98, air_drag_modifier)`, where modified(b, m) = clamp(1 - (1 - b) x m, 0, 1). For entities that are `omnidirectionalAirMover` (bees, ghasts, flying mobs) the vertical factor is `modified(0.91, air_drag_modifier)` (read: the same factor as the horizontal air drag without ground friction) instead of `modified(0.98, ...)`.

Steady-state numbers on friction 0.6 ground: horizontal factor 0.6 x 0.91 = 0.546 per tick, so a mob with speed s moves at about s x 0.98 / 0.454 per tick toward its target (for the player: 13 §1.3).

**`travelInFluid`** (water or lava, read): remember whether the entity is falling (vy <= 0), the start y and effective gravity, then `travelInWater` or `travelInLava`; afterwards if the entity is in a floatable fluid and ridden, `floatInLiquidWhileRidden`.
- `travelInWater`: slowdown factor = 0.9 if sprinting else `getWaterSlowDown` (0.8; dolphins override with 0.9, see per-mob); acceleration 0.02; `water_movement_efficiency` e (attribute, 0 default) is halved when not on the ground; if e > 0: slowdown += (0.54600006 - slowdown) x e and acceleration += (speed - acceleration) x e (`speed` = the entity's `getSpeed()`); Dolphin's Grace sets slowdown 0.96. Then `moveRelative(acceleration)`, `move`, velocity x (slowdown, slowdown_vertical = same factor per the `Vec3.multiply(f, 0.8, f)` pattern: horizontal factor = slowdown, vertical 0.8), a horizontal collision while climbing makes y = 0.2, then `getFluidFallingAdjustedMovement` (when not sprinting and falling: `y - gravity/16`, with a floor of -0.003 when |y - 0.005| >= 0.003 and |y - gravity/16| < 0.003), then `jumpOutOfFluid`: if horizontally collided and the position one step up (y + 0.6 - current y + 0.1) is free, set vy = 0.3.
- `travelInLava`: acceleration 0.02, `move`; if lava height <= the fluid jump threshold: velocity x (0.5, 0.8, 0.5) then the falling adjustment; else velocity x 0.5; if gravity != 0, `y += -gravity/4`; then `jumpOutOfFluid`.

**`travelFlying(input, speed...)`** (used by `FlyingMoveControl` mobs, bats, bees, allays, parrots, phantoms, ghasts, happy ghasts depending on class): `moveRelative(speed)`, `move`, then velocity x 0.8 in water, 0.5 in lava, 0.91 in air; gravity is not applied (these mobs set no-gravity while flying).

**Climbing** (`onClimbable`): on a block in tag `climbable` (ladder, vines, scaffolding...) a living entity's fall distance resets, and the clamps above apply. Spiders use the wall-climber navigation (5.6) and `Entity` flag for climbing.

**Gravity attribute** can be overridden per entity (`gravity` base value): e.g. phantoms, bees, ghasts, allays have no gravity effect in flight (set via `setNoGravity` while flying).

**Step height**: `step_height` attribute (0.6 default; `maxUpStep`). A collision that is blocked horizontally but passable if the entity rises by <= step height is resolved by stepping up (3.3). Mobs that should climb whole blocks (e.g. horses 1.0) raise the attribute.

**Fall damage**: `causeFallDamage(distance, multiplier)`: the damage is `floor((distance - safe_fall_distance) x multiplier x fall_damage_multiplier)` (safe distance 3 by default; types in tag `fall_damage_immune` take none); applied as a fall damage type; a mob's AI also uses `getMaxFallDistance` when pathing (5.3).

### 3.3 Collision, push and block effects

- `Entity.move` moves along each axis in the order y, then the larger of x/z, with collision against block shapes and the world border, honouring the step height; sets `onGround` (vertical movement was blocked while moving down), `horizontalCollision`, `verticalCollision`. Sneaking-off-edge protection applies to players only.
- Block speed factor: the block the entity stands on or in multiplies velocity by its speed factor and `jump_factor` scales jump power (13 §1.2: defaults 1.0 and 1.0; read: soul sand speed factor 0.4; honey block speed factor 0.4 and jump factor 0.5; the full per-block table is block data, not repeated here).
- `pushEntities` (`LivingEntity.pushEntities`, read): each tick the pushable entities overlapping the box are collected (`getPushableEntities`). Server side, with the game rule `max_entity_cramming` above 0, if more than that many (minus one) overlap, then with probability 1/4 per tick the number of overlapping entities that are not passengers is counted and, if it exceeds the rule value, the entity takes **6.0** cramming damage. Then every overlapping entity is pushed (`doPush` -> `Entity.push(other)`; a sleeping living entity is not pushed). `Entity.push(other)`: nothing if the two are passengers of the same vehicle or either has `noPhysics`; `dx = other.x - this.x`, `dz = other.z - this.z` (the direction toward the other entity), `d = max(|dx|, |dz|)`; if `d >= 0.01`: `d = sqrt(d)`, `dx /= d`, `dz /= d`, `f = min(1 / d, 1)`, `dx x= f x 0.05`, `dz x= f x 0.05`; if `this` is not a vehicle and is pushable, `this` is pushed by `(-dx, 0, -dz)`; if `other` is not a vehicle and is pushable it is pushed by `(dx, 0, dz)` (the two calls and the factor 0.05 are read).
- `applyEffectsFromBlocks` (called after `travel`, 2.6 step 10) applies the touched blocks' entity effects. Read values: **cactus** 1.0 `cactus` damage (`entityInside`); **magma block** 1.0 `hot_floor` damage on `stepOn` unless the entity is stepping carefully (sneaking); **cobweb** `makeStuckInBlock` multiplier `(0.25, 0.05, 0.25)`; **sweet berry bush** `makeStuckInBlock` `(0.8, 0.75, 0.8)` (not for foxes and bees) and, when the entity moved horizontally more than 0.003 on x or z since its old position (and the bush is grown enough), 1.0 `sweet_berry_bush` damage. Other blocks (powder snow, honey, bubble columns, portals, fire, campfire) behave as defined with the blocks and are not specified here; entities in the immune block tag of 1.1 ignore the damaging ones.


---

## 4. The AI system

A `Mob` owns two goal selectors (`goalSelector`, `targetSelector`), a `Brain` is used instead by Brain mobs (4.5), and five controls (`MoveControl`, `LookControl`, `JumpControl`, `BodyRotationControl`, and the navigation). A mob's constructor calls `registerGoals` (and `registerTargetGoals` style hooks) which add goals as `addGoal(priority, goal)`.

### 4.1 Goal selector

A **goal** has: `canUse()`, `canContinueToUse()` (default: `canUse()`), `start()`, `tick()`, `stop()`, `isInterruptable()` (default true), `requiresUpdateEveryTick()` (default false) and a set of **flags**: MOVE, LOOK, JUMP, TARGET. A goal is wrapped with its **priority** (an int; a lower number is a higher priority).

Selector state: a set of registered goals (in registration order), `lockedFlags` (flag -> the running goal holding it) and `disabledFlags` (set by `updateControlFlags`, 2.2).

**`GoalSelector.tick()`** (full evaluation, every second tick per mob, 2.7), in order:

1. **Cleanup.** For every running goal: if any of its flags is in `disabledFlags`, or `canContinueToUse()` is false, call `stop()` (the goal is no longer running).
2. Remove from `lockedFlags` every entry whose holding goal is no longer running.
3. **Update.** For every goal in registration order that is not running: it may start only if (a) none of its flags is disabled, (b) it can replace the current holder of **every** one of its flags (`canBeReplacedForAllFlags`: for each flag the holder, if any, must satisfy `holder.isInterruptable() && goal.priority < holder.priority`; an empty flag counts as replaceable), and (c) its `canUse()` returns true. When it starts: for each of its flags, if another goal holds the flag, that goal is `stop()`ped, then the flag is assigned to the new goal; then `start()`.
4. **`tickRunningGoals(true)`**: call `tick()` on every running goal.

**`tickRunningGoals(false)`** (the odd ticks): call `tick()` only on running goals that return true from `requiresUpdateEveryTick()`.

Consequences used throughout: equal priority never interrupts (strictly lower number only); a goal with `isInterruptable() = false` can never be displaced; goals sharing no flag run concurrently; the first goal in registration order wins ties when both could start in the same pass.

**Tick-delay scaling.** Goals count delays in ticks but are evaluated only every second tick. `adjustedTickDelay(n)` returns `ceil(n / 2)` (`reducedTickDelay`) unless the goal `requiresUpdateEveryTick()`, in which case it returns `n`. Any "interval" below is the value passed to `adjustedTickDelay`/`reducedTickDelay` and so effectively half in ticks of evaluation.

### 4.2 Shared goal catalogue

Format: `Class(params)` flags; conditions in prose. `nav` = the mob's `PathNavigation` (section 5). "target" = `mob.getTarget()`. "speed" arguments are the `speedModifier` of 3.1. `RS` = `RandomSource`.

**FloatGoal(mob [, fluid tag = entity_floatable])** flags JUMP; requires update every tick; marks the mob's navigation as able to float. Behaviour: while the mob is deeper than its fluid jump threshold (3.2) in the fluid, or in lava, it requests a jump on 80% of the ticks (`nextFloat() < 0.8` each tick, via `JumpControl.jump()`).

**PanicGoal(mob, speed [, damage-type tag = `panic_causes` | function mob -> tag])** flags MOVE. *Triggers* when the mob's last damage source is in the tag. *Destination*: if the mob is on fire, the nearest water block found by a Manhattan-distance search of radius 5 and vertical range 1 around the mob (`lookForWater`, only when the mob's own block has an empty collision shape); otherwise `DefaultRandomPos.getPos(mob, 5, 4)`; no destination means no start. *Effect*: walk to the destination at `speed`; runs until the navigation finishes; `isPanicking` is true while it runs (used by breeding and the Brain `is_panicking` memory).

**MeleeAttackGoal(mob, speed, followingTargetEvenIfNotSeen)** flags MOVE, LOOK; requires update every tick. Behaviour:
- *Start condition* (`canUse`): evaluated at most once per 20 game ticks (the goal remembers the last check time). It needs a living target and a path to it (`nav.createPath(target, 0)`); if no path exists it still starts when the target is already within melee range.
- *Keep condition*: the target is alive; with `followingTargetEvenIfNotSeen` false the goal runs while the navigation has a path left; with it true the goal runs while the target is inside the mob's home area and is not a spectator or creative player.
- *On start*: follow the path at `speed`, set the mob aggressive, zero the path-recalculation and attack timers. *On stop*: clear the target if it is no longer a valid (non-creative, non-spectator) target, clear aggressive, stop the navigation.
- *Each tick*: look at the target (30, 30). Both timers count down to 0. The path is recomputed when the recalculation timer is 0 and the mob can see the target (or `followingTargetEvenIfNotSeen`), and either no previous target position is stored, or the target moved at least 1 block (squared 1.0) from the stored position, or with probability 0.05; the new timer is `4 + nextInt(7)`, plus 10 if the target is more than 32 blocks away (squared 1024) or plus 5 if more than 16 blocks (squared 256), plus 15 when the new `moveTo(target, speed)` fails, then passed through `adjustedTickDelay`.
- *Attack*: when the attack timer is 0, the target is in melee range and visible, the timer is set to `adjustedTickDelay(20)`, the main hand swings and `doHurtTarget` (7.3) is called on the target.
- *Melee range* (`Mob.isWithinMeleeAttackRange`): the target's hitbox intersects the mob's bounding box inflated by R on x and z and by 0 on y, with R = `sqrt(2.0399999618530273) - 0.6000000238418579` ~ 0.8283, or the maximum range of the held item's `attack_range` component when it has one (and, if the component has a minimum range, the hitbox must not intersect the box inflated by that minimum). A mob that is riding uses the union of its own box and the vehicle's box. (Both constants and the use of the intersection test are read; the subtraction of the two constants is the only combination in the bytecode.)

**ZombieAttackGoal(zombie, speed, follow)**: a MeleeAttackGoal that also drives the raised-arms pose: a counter `raiseArmTicks` increments each tick (reset to 0 on start and stop); the zombie is set aggressive while `raiseArmTicks >= 5` and `ticksUntilNextAttack < attackInterval / 2` (integer division, the interval being `adjustedTickDelay(20)`), otherwise not aggressive; stopping clears aggressive.

**RangedAttackGoal(mob, speed, minAttackInterval [, maxAttackInterval], attackRadius)** (the mob implements `RangedAttackMob`; flags MOVE, LOOK; requires update every tick). `attackRadiusSqr = attackRadius^2`. Runs while the target is alive (or the navigation still has a path). Each tick: track `seeTime` (ticks of continuous line of sight; reset to 0 when visibility turns off); stand still when the target is within the radius and `seeTime >= 5` (navigation stopped), otherwise path to the target at `speed`; look at the target (30, 30); count the attack timer down; when it reaches 0 and the target is visible, shoot with `power = clamp(distance / attackRadius, 0.1, 1.0)` and reset the timer to `floor(distance/attackRadius x (max - min) + min)`; when the timer is negative (first shot) initialise it with the same formula. With a single interval, min = max. (Read as above; the order of the `seeTime` reset relative to the increment is the only part of the bytecode read less closely.)

**RangedBowAttackGoal(skeleton-like mob, speed, attackIntervalMin, attackRadius)** flags MOVE, LOOK; requires update every tick; starts when the mob has a target and holds a bow; aggressive while running. Each tick (read): `seeTime` is incremented while the target is visible and decremented otherwise (it is reset to 0 whenever visibility flips relative to the sign of `seeTime`). *Movement*: if the target is farther than the radius (squared distance > `attackRadiusSqr`) or `seeTime < 20`, path to the target and set `strafingTime = -1`; otherwise stop the navigation and increment `strafingTime`. When `strafingTime >= 20`, with probability 0.3 each the clockwise flag and the backwards flag are toggled, and `strafingTime` returns to 0. When `strafingTime > -1` the mob strafes: if the squared distance is above 0.75 x `attackRadiusSqr` backwards is cleared; if below 0.25 x `attackRadiusSqr` backwards is set; then `MoveControl.strafe(backwards ? -0.5 : 0.5, clockwise ? 0.5 : -0.5)`. The mob (or a mob vehicle) faces the target (30, 30). *Shooting*: while using the bow: if the target is not visible and `seeTime < -60` stop using it; else if visible and the bow has been drawn for 20 ticks or more, stop using it, shoot with power `BowItem.getPowerForTime(ticks)` and set the attack timer to `attackIntervalMin`. While not using the bow: the attack timer counts down and, when it is 0 or below and `seeTime >= -60`, the mob starts using the bow in its holding hand. Stopping the goal clears aggressive, resets `seeTime` and the timer to -1 and stops using the item.

**RangedCrossbowAttackGoal(mob, speed, attackRadius)** states UNCHARGED, CHARGING, CHARGED, READY_TO_ATTACK; flags MOVE, LOOK; requires update every tick. It follows the target at `speed`, stops when within the radius and visible, charges the crossbow by using it, shoots when charged and visible after a random delay sampled from a uniform of 1 to 2 seconds (`TimeUtil.rangeOfSeconds(1, 2)`), and returns to UNCHARGED on stop (clearing the charged projectile component).

**RandomStrollGoal(mob, speed [, interval = 120 [, checkNoActionTime = true]])** flags MOVE. *Triggers* each evaluation with probability `1 / reducedTickDelay(interval)` (default 1/60), unless the mob has a controlling passenger, or (`checkNoActionTime`) its `noActionTime >= 100`; a forced `trigger()` skips the roll. *Destination*: `getPosition()` (default `DefaultRandomPos.getPos(mob, 10, 7)`); none means no start. *Effect*: walk there at `speed` until the navigation finishes or a passenger takes control; `stop` stops the navigation.
- **WaterAvoidingRandomStrollGoal(mob, speed [, probability = 0.001])**: `getPosition`: if the mob is in water: `LandRandomPos.getPos(mob, 15, 7)`, falling back to the default; else if `RS.nextFloat() >= probability`: `LandRandomPos.getPos(mob, 10, 7)`, else the default random position. (So with probability 0.001 it uses the plain position.)
- **WaterAvoidingRandomFlyingGoal(mob, speed)**: position = `HoverRandomPos.getPos(mob, 8, 7, viewVector.x, viewVector.z, PI/2, 3, 1)`, falling back to `AirAndWaterRandomPos.getPos(mob, 8, 4, -2, viewVector.x, viewVector.z, PI/2)` (the view vector is the mob's facing).
- **RandomSwimmingGoal(mob, speed, interval)**: position = `BehaviorUtils.getRandomSwimmablePos(mob, 10, 7)` (random swimmable water position within 10 horizontally, 7 vertically).

**LookAtPlayerGoal(mob, lookAtType, lookDistance [, probability = 0.02 [, onlyHorizontal = false]])** flags LOOK. For `Player` the conditions are `forNonCombat().range(lookDistance)` with the selector `EntitySelector.notRiding(mob)` (a player who is riding the looking mob is excluded; the call is read, its exact predicate is the standard "not riding this entity"); for other types `forNonCombat().range(lookDistance)`. *Start*: with probability `probability` per evaluation; the target is the mob's current attack target if it has one, otherwise the nearest matching player, or for other classes the nearest matching entity of that class in the box inflated by (lookDistance, 3, lookDistance). *Keep*: the target is alive, within `lookDistance`, and `lookTime > 0`. *On start*: `lookTime = adjustedTickDelay(40 + nextInt(40))`. *Each tick*: look at (target.x, onlyHorizontal ? mob.eyeY : target.eyeY, target.z) and decrement `lookTime`.
- **InteractGoal(mob, type, distance [, probability])** = LookAtPlayerGoal with flags LOOK and MOVE (used by villagers to face a player or each other).
- **RandomLookAroundGoal(mob)** flags MOVE, LOOK; requires update every tick. *Triggers* with probability 0.02 per evaluation. *Effect*: picks a random horizontal direction `a = 2 PI x nextDouble()` and looks along `(cos a, sin a)` from the mob's eye for `20 + nextInt(20)` ticks (`LookControl.setLookAt(mob.x + cos a, mob.eyeY, mob.z + sin a)` each tick).

**AvoidEntityGoal(mob, avoidClass, [predicate,] maxDistance, walkSpeedModifier, sprintSpeedModifier [, extra predicate])** flags MOVE. *Triggers* when an entity of the class (not a creative or spectator player, passing the optional predicates and `forCombat().range(maxDistance)`) is nearest to the mob within the box inflated by `(maxDistance, 3, maxDistance)`, and a flee destination exists: `DefaultRandomPos.getPosAway(mob, 16, 7, entity.position)` that is **not** closer to the avoided entity than the mob is now, with a path to it (`createPath(pos, 0)`). *Effect*: follow that path at `walkSpeedModifier`, switching the navigation speed to `sprintSpeedModifier` while the mob is within 7 blocks (squared 49) of the avoided entity, back to walk speed otherwise; runs until the navigation finishes.

**BreedGoal(animal, speed [, partnerClass])** flags MOVE, LOOK. *Triggers* while the animal is in love and a free partner exists: the nearest `Animal` of the partner class within the box inflated by 8 blocks that `canMate` the animal and is not panicking (range 8, line of sight ignored). *Effect*: look at the partner and walk to it at `speed`; a counter counts up while the goal runs; once it reaches `adjustedTickDelay(60)` and the partner is within 3 blocks (squared 9), `Animal.spawnChildFromBreeding` is called (8.1). The goal ends (counter reset) when either animal stops being in love, dies, panics, or the counter passes 60 without the distance condition.

**TemptGoal(mob, speed, itemPredicate, canScare [, within])** flags MOVE, LOOK. *Triggers* when the nearest player (non-combat conditions, line of sight ignored, range = the mob's `tempt_range` attribute, default 10) holds a matching item in either hand and the goal is not cooling down (after the goal stops it cools down for `reducedTickDelay(100)`). *Effect*: look at the player (turn limit `getMaxHeadYRot + 20`); stop moving when within 2.5 blocks (the constructor's `within` default 2.5, compared squared), else walk to the player at `speed`. With `canScare`, the goal ends when the player is within 6 blocks (squared 36) and has moved more than 0.1 blocks (squared 0.01) or turned more than 5 degrees in pitch or yaw since the last check.

**FollowParentGoal(animal, speed)** (no flags). *Triggers* for a baby (`getAge() < 0`) when an adult of the same species (`getAge() >= 0`) is within the box inflated by `(8, 4, 8)` and at least 3 blocks away (squared 9); the closest adult is followed. *Effect*: every `adjustedTickDelay(10)` ticks, walk to the parent at `speed`; ends when the parent dies or the baby is within 3 blocks or farther than 16 blocks (squared 256).

**FollowOwnerGoal(tamable, speed, startDistance, stopDistance)** flags MOVE, LOOK. *Triggers* when the mob has an owner it can move to (`unableToMoveToOwner` false: not a spectator owner, and the sitting, leashed and passenger cases of the subclass) and the squared distance to the owner exceeds `startDistance^2`. *Effect*: while running, water is made free for pathing (the WATER malus is set to 0 and restored on stop). Every `adjustedTickDelay(10)` ticks: if the owner is 12 or more blocks away (squared 144, `shouldTryTeleportToOwner`) the mob teleports (`tryToTeleportToOwner`: up to 10 attempts at a random offset `(nextIntBetweenInclusive(-3, 3), nextIntBetweenInclusive(-1, 1), nextIntBetweenInclusive(-3, 3))` from the owner's block, skipping offsets within 2 blocks on both axes; a spot is valid when its static path type is WALKABLE, the block below is not leaves (unless the mob can fly to its owner), and the mob's box moved there is collision free; teleporting stops the navigation); otherwise it walks to the owner at `speed`. When the owner is **not** being teleported to, the mob also looks at the owner every tick. Ends when the path finishes, the owner becomes unreachable, or the distance falls below `stopDistance^2`.
- **SitWhenOrderedToGoal(tamable)** flags JUMP, MOVE. `canUse` (read, in order): false if the mob is neither ordered to sit nor tame; false in water; false when not on the ground; **true** when it has no owner or the owner is in another level; false when the owner is within 12 blocks (squared distance below 144) and the mob has a last-hurt-by mob; otherwise the result is `isOrderedToSit`. `start`: `nav.stop()`, sit pose; `stop`: stand; continue while `isOrderedToSit`.
- **BegGoal(wolf, lookDistance)** flags LOOK: the nearest player holding a bone or the wolf's food; `start`: interested flag, timer = adjusted `40 + RS.nextInt(40)`; looks at the player.

**FollowMobGoal(mob, speed, stopDistance, areaSize)** flags MOVE, LOOK. *Triggers* when a visible (not invisible) mob that passes the goal's predicate (a different mob of any type that is not itself) is within the box inflated by `areaSize`; the closest is followed. *Effect*: water is made free for pathing while it runs; the mob looks at the target, and while the target is farther than `stopDistance` it walks to it at `speed`; when closer the navigation stops and the mob only turns toward it. Which mobs use it is per mob.

**OpenDoorGoal(mob, closeDoorAfter)** / **DoorInteractGoal(mob)** (ground navigation only; throws if the mob has no ground navigation). *Triggers* when the mob has an unfinished path and, among the next nodes (path index to index + 2, bounded by the node count) or the block above the mob, a wooden door (`DoorBlock.isWoodenDoor`) lies within 1.5 blocks (squared 2.25) of the mob; the door is then opened (`DoorBlock.setOpen`). With `closeDoorAfter` it closes the door `20` ticks after passing (a countdown from `start`, decremented in `tick`) or when the goal stops. The goal tracks which side of the door the mob stands on (it stops once the mob has passed: the dot product of the offset to the door centre changes sign) and requires update every tick.

**BreakDoorGoal(mob [, breakTime = 240], difficultyPredicate)**: as DoorInteract but for **closed** doors, only when `mob_griefing` is on and the world difficulty passes the predicate (Hard for zombies). While the mob stays within 2 blocks of the door the break progress `breakTicks` grows by 1 per tick; every tick with probability 1/20 the door-hitting sound (level event 1019) plays and the mob swings; `destroyBlockProgress` is sent with stage `(breakTicks / max(240, breakTime)) x 10`; when `breakTicks == max(240, breakTime)` and the difficulty still passes, the door is removed, level events 1021 and 2001 play. Stopping resets the progress (the block crack is cleared).

**RestrictSunGoal(mob)**: while it is bright outside (`Level.isBrightOutside`: the dimension has no fixed time and the level's `skyDarken` is below 4; this is **not** the `monsters_burn` attribute used by 2.7), the mob's head slot is empty and it has ground navigation, the goal is active and turns on `avoidSun` in the ground navigation (paths are trimmed to stay out of open sky, 5.4); stopping turns it off.

**FleeSunGoal(mob, speed)** flags MOVE. *Triggers* when the mob has no target, it is bright outside, the mob is burning, the sky is visible at its block and its head slot is empty, and a hiding place exists: up to 10 random offsets `(nextInt(20) - 10, nextInt(6) - 3, nextInt(20) - 10)` from the mob are tried and the first block that cannot see the sky and whose `getWalkTargetValue` is below 0 (read) is chosen (bottom centre). *Effect*: walk there at `speed` until the navigation finishes.

**EatBlockGoal(mob)** (sheep) flags MOVE, LOOK, JUMP. *Triggers* with probability `1/50` (baby) or `1/1000` per evaluation when the block at the mob's feet is in tag `edible_for_sheep` or the block below it is a grass block. *Effect*: for `adjustedTickDelay(40)` ticks the mob stands still (navigation stopped) and Entity Event 10 starts the head-down animation; at exactly 4 ticks remaining: if the feet block is edible and `mob_griefing` is on, it is destroyed without drops and `ate()` is called (a sheep regrows its wool); else if the block below is grass and `mob_griefing` is on, level event 2001 (block break effect) plays, the block below becomes dirt (set flags 2) and `ate()` is called.

**MoveToBlockGoal(mob, speed, searchRange [, verticalSearchRange = 1])** (abstract; subclasses define `isValidTarget(level, pos)`, e.g. the egg-stomping, farmland and bed goals): flags MOVE, JUMP; requires update every tick. *Start*: a cooldown `nextStartTick = reducedTickDelay(200 + nextInt(200))` counts down; when it reaches 0 the cooldown is re-rolled and `findNearestBlock()` runs; the goal starts if it finds a target. `findNearestBlock` (read) scans candidate positions around the mob's block `M` in this order and stores the first one that is within the mob's home (`isWithinHome`) and satisfies `isValidTarget`: for the vertical offset `v` taking the values `verticalSearchStart, then 1, -1, 2, -2, ...` (after the first value each next value is `1 - v` when `v <= 0` and `-v` when `v > 0`) while `v <= verticalSearchRange`; for each ring radius `r = 0, 1, ..., searchRange - 1`; for each `a` in the sequence `0, 1, -1, 2, -2, ...` while `a <= r`; for each `b` in the same style of sequence `0, 1, -1, 2, -2, ...` while `b <= r`, where `b` starts at `r` (so only the outer ring cell `b = r` and then `b = -r`) when `|a| < r`, and starts at 0 (all of `0, 1, -1, ..., r, -r`) when `|a| == r`; the candidate is `M + (a, v - 1, b)`. So it searches layer by layer outward in square rings, nearest rings first, and layers near the mob's own height first. *Keep*: `tryTicks >= -maxStayTicks` and `tryTicks <= 1200` and the stored block is still valid. *On start*: walk to the block centre (`nav.moveTo(x + 0.5, y + 1, z + 0.5, speed)`), `tryTicks = 0`, `maxStayTicks = nextInt(nextInt(1200) + 1200) + 1200`. *Each tick*: if the mob is not within `acceptedDistance()` (1.0) of the target block: `reachedTarget = false`, `tryTicks += 1`, and every 40th `tryTicks` the walk order is repeated; otherwise `reachedTarget = true` and `tryTicks -= 1`.
- **RemoveBlockGoal(block, mob, speed, verticalSearchRange)** (a zombie breaking turtle eggs): a MoveToBlockGoal with horizontal search range **24**. It starts only when `mob_griefing` is on. A valid target is a block of the given type in a loaded chunk with air above it (the position or a neighbour: `getPosWithin` also accepts the block itself, then below and the four horizontal neighbours). When the mob is on top of the block it stomps: every 2nd tick its vertical velocity is set to -0.3 and item particles of an egg are sent; every 6th tick a destroy-progress sound plays; after 60 ticks the block is removed and the break sound plays.
**MoveTowardsRestrictionGoal(mob, speed)** flags MOVE: `canUse`: the mob is **not** within its home (`isWithinHome`); pos = `DefaultRandomPos.getPosTowards(mob, 16, 7, home.bottomCenter, PI/2)`; `start`: `nav.moveTo(pos, speed)`; continue while the path is not done.
**MoveTowardsTargetGoal(mob, speed, within)** flags MOVE: `canUse`: target alive and farther than `within` blocks (squared); pos = `getPosTowards(mob, 16, 7, target.position, PI/2)`; continue while path not done and target alive and distance squared > within^2.

**LeapAtTargetGoal(mob, yd)** flags JUMP, MOVE. *Triggers* (1 in `reducedTickDelay(5)` evaluations) when the mob has no controlling passenger, has a target 2 to 4 blocks away (squared distance between 4.0 and 16.0, exclusive of the ends as read), and is on the ground. *Effect*: one leap: the horizontal direction to the target `(dx, dz)`, if its squared length exceeds 1.0E-7 is normalised, multiplied by 0.4 and added to 0.2 x the current velocity; the new velocity is `(that x, yd, that z)`; the goal runs until the mob lands (`!onGround`).

**TryFindLiquidGoal(mob, fluid)** (frog, axolotl): `canUse`: on ground and not in the fluid; `start`: scans the box (mob +- 2 horizontally, 2 vertically) for a fluid block and sets `MoveControl.setWantedPosition(x, y, z, 1.0)`.
**BreathAirGoal(mob)** flags MOVE, LOOK; **not interruptable**. *Triggers* when the air supply is below 140. *Effect*: stop the navigation; look for a block column neighbour (`BlockPos.neighborColumn`) within 8 blocks above the mob whose block gives air (not a fluid except a bubble column, and pathfindable by land) and walk to the block above it (`nav.moveTo(x, y + 1, z, 1.0)`); with no such block, each tick the mob accelerates by 0.02 upward-forward (`moveRelative(0.02, ...)`).
**ClimbOnTopOfPowderSnowGoal(mob, level)** flags JUMP: `canUse`: the mob is in tag `powder_snow_walkable_mobs` and the block at its position or the block above it is powder snow with a non-empty collision shape (read: two powder-snow checks and a collision-shape test), requires update every tick; `tick`: `JumpControl.jump()`.
**SwellGoal(creeper)** flags MOVE: `canUse`: swell direction > 0 or target within 3 blocks (squared 9); `start`: `nav.stop()`; `tick`: no target -> direction -1; dead -> -1; distance squared > 49 (7 blocks) -> -1; no line of sight -> -1; else +1. Requires update every tick.
**OcelotAttackGoal(mob)** (cat family) flags MOVE, LOOK; requires update every tick. Runs while the target is alive, within 15 blocks (squared 225) and the navigation is not finished. Each tick: look at the target (30, 30); approach speed 0.8, or 1.33 when the squared distance is above `(2 x bbWidth)^2` and below 16, or 0.6 when the squared distance is below 225 (checked in that order, the 1.33 case first); `moveTo(target, speed)`; the attack timer counts down to 0; the mob attacks (`doHurtTarget`) when the squared distance is at most `(2 x bbWidth)^2` and the timer is 0, then the timer is 20.
**RandomStandGoal(horse)**: `canUse`: counter increments, `RS.nextInt(1000) < counter` and not immobile with `RS.nextInt(10) == 0`; `start`: stand rear animation. Update each tick.
**FollowFlockLeaderGoal(schooling fish)**: `nextStartTick = reducedTickDelay(200 + RS.nextInt(200) % 20)`; flock logic in the fish class.
**DolphinJumpGoal** and **JumpGoal**: mob-specific (see 21).
**RunAroundLikeCrazyGoal**, **OfferFlowerGoal**, **LlamaFollowCaravanGoal**, **LandOnOwnersShoulderGoal**, **CatSitOnBlockGoal**, **CatLieOnBlockGoal**, **GolemRandomStrollInVillageGoal**, **MoveThroughVillageGoal**, **StrollThroughVillageGoal**, **MoveBackToVillageGoal**, **PathfindToRaidGoal**, **TradeWithPlayerGoal**, **LookAtTradingPlayerGoal**, **UseItemGoal**, **SpearUseGoal**, **FollowPlayerRiddenEntityGoal**: mob-specific goals; their parameters belong to the per-mob catalogues (they use the same machinery as above).

**Random position helpers** (`net.minecraft.world.entity.ai.util`), read in full:

*Core* (`RandomPos.generateRandomPos(mob, candidateSupplier)`): up to **10** candidates are drawn from the supplier; null candidates are skipped; each non-null block position is scored with the mob's `getWalkTargetValue(pos)` (0 for `PathfinderMob`; `Animal` returns 10 on a grass block below the position, otherwise a light-level-based cost) and the **highest** score wins (strictly greater replaces, so the earliest wins ties); the result is the bottom centre of the winning block, or none if every candidate was null. Helper flag `restricted = mobRestricted(mob, hRange)`: true when the mob has a home and its position is **not** closer than `homeRadius + hRange + 1` to the home centre.

*Random direction*: `generateRandomDirection(rand, h, v)` = `(nextInt(2h+1) - h, nextInt(2v+1) - v, nextInt(2h+1) - h)`. `generateRandomDirectionWithinRadians(rand, minH, maxH, v, yOffset, dx, dz, maxAngle)`: `angle = atan2(dz, dx) - PI/2 + (2 x nextFloat() - 1) x maxAngle`; `dist = lerp(sqrt(nextDouble()), minH, maxH) x sqrt(2)`; `x = -dist x sin(angle)`, `z = dist x cos(angle)`; reject (none) if `|x| > maxH` or `|z| > maxH`; `y = nextInt(2v+1) - v + yOffset`; result `BlockPos.containing(x, y, z)`.

*Toward direction* (`generateRandomPosTowardDirection(mob, hRange, rand, offset)`): start from `(offset.x + mob.x, offset.y + mob.y, offset.z + mob.z)`; if the mob has a home and `hRange > 1`, nudge x and z away from the mob's side of the home: if `mob.x > home.x` then `x -= nextDouble() x hRange / 2` else `x += nextDouble() x hRange / 2` (same for z); the result is `BlockPos.containing`.

*`DefaultRandomPos`* (any mob): candidate = random direction (or the within-radians direction), converted by the toward-direction step; it is **rejected** (null) if any holds: outside the build height (`isOutsideLimits`); `restricted` and not within home (`isRestricted`); the navigation says the position is not a stable destination (`nav.isStableDestination`); or the static path type at the position has a malus other than 0 for this mob (`hasMalus`). Variants: `getPos(mob, h, v)` uses the plain direction; `getPosTowards(mob, h, v, target, maxAngle)` uses the within-radians direction with `minH = 0`, `maxH = h`, `dx, dz` = target minus mob; `getPosAway(mob, h, v, from)` uses it with `dx, dz` = mob minus `from` and `maxAngle = PI/2`.

*`LandRandomPos`* (ground mobs that must not end in water): same generation, with rejections outside the limits, restricted, or not stable; then the position is moved **up out of solid** (while the block is solid and not above the world height, move up one); then rejected if the block has water fluid or has a nonzero malus. `getPos(mob, h, v [, scoring])`, `getPosTowards`, `getPosAway(mob, h, v, from)` as above; the 5-argument `getPosAway(mob, minH?, maxH, v, from)` first checks that mob and `from` are apart (if the vector length is 0 a random horizontal vector `(nextDouble - 0.5, 0, nextDouble - 0.5)` is used) and uses the within-radians direction.

*`AirAndWaterRandomPos`* (flyers allowed over water): within-radians direction with the toward-direction step, rejecting outside limits and restricted, then moving up out of solid and rejecting a nonzero malus. *`AirRandomPos.getPosTowards`*: uses `AirAndWaterRandomPos` and additionally rejects positions in water. *`HoverRandomPos.getPos(mob, h, v, dx, dz, maxAngle, hoverHeight, minHover)`*: within-radians direction, the toward-direction step, then a vertical target `nextInt(hoverHeight - minHover + 1) + minHover` above, moved **up to above solid** (so the position floats that many blocks over ground), then rejected if in water or with a nonzero malus.

### 4.3 Target selection

**TargetingConditions** (`forCombat()` / `forNonCombat()`; `range(d)`, `ignoreLineOfSight()`, `ignoreInvisibilityTesting()`, `selector(fn)`; defaults: range -1 (unlimited), line of sight checked, invisibility tested). `test(level, attacker, target)` returns false at the first failing rule, in this order (read):
1. `target == attacker`.
2. The target `canBeSeenByAnyone` is false (`canBeSeenByAnyone` = not a spectator and alive).
3. A custom selector exists and rejects the target.
4. **No attacker** (null): with combat conditions, the target must `canBeSeenAsEnemy` (= not invulnerable and `canBeSeenByAnyone`) and the difficulty must not be Peaceful, otherwise false; **the result is then true** (with or without combat conditions, the test returns true here and rules 5 to 7 do not run).
5. **With an attacker**, combat conditions: `attacker.canAttack(target)` must be true and `attacker.isAlliedTo(target)` false. Rules 5 to 7 apply only with an attacker.
6. **Range** (when range > 0): `effective = max(range x visibility, 2.0)` where `visibility` is 1.0 when invisibility testing is off, else `target.getVisibilityPercent(attacker)`; false if the squared distance from the attacker to the target exceeds `effective^2`.
7. **Line of sight** (when enabled and the attacker is a `Mob`): `attacker.getSensing().hasLineOfSight(target)` must be true.

`getVisibilityPercent(looker)` (read): start at 1.0; if crouching: x 0.8; if invisible: x `max(armorCoverPercentage, 0.1)` x 0.7, where `armorCoverPercentage` (`getArmorCoverPercentage`) is the number of non-empty humanoid armor slots divided by the number of humanoid armor slots (0 when there are none), 0..1; then for every equipment slot, an item whose `mob_visibility` component applies to that slot (the item's equippable slot) and whose `targetingEntityTypes` set contains the looker's type multiplies the value by the component's `visibility` factor; the result is clamped to [0, 10].

**TargetGoal(mob, mustSee [, mustReach])** (base; flags TARGET). `canContinueToUse`: the mob has a target; the target is attackable (`mob.canAttack`); teams: not the same non-null team; the distance squared to the target <= `getFollowDistance()^2` (the `follow_range` attribute value); if `mustSee`: `Sensing.hasLineOfSight(target)` else `unseenTicks` counts up and the goal ends when `unseenTicks > unseenMemoryTicks` (default 60); on failure the target is cleared. `start`: reach-check counters 0. `stop`: `setTarget(null)`, target memory cleared. `canAttack(target, conditions)` (used when selecting): conditions must pass; the target block must be within home; if `mustReach`: a periodic reachability check: every `10 + RS.nextInt(5)` ticks it computes a path to the target and the end node must be within 1.5 blocks (squared 2.25) of the target; two consecutive failures (counter 2) disqualify it.

**NearestAttackableTargetGoal(mob, targetType, [randomInterval = 10,] mustSee, mustReach [, selector])** flags TARGET. `canUse`: if `randomInterval > 0` and `RS.nextInt(randomInterval) != 0` -> false; then `findTarget()`; true if a target was found. `findTarget`: for `Player`/`ServerPlayer`: `getNearestPlayer(conditions, mob, x, eyeY, z)`; else the nearest entity of the class within `getTargetSearchArea(followDistance)` (the mob's bounding box inflated by `(range, 4.0, range)`) filtered by the conditions. `start`: `mob.setTarget(target)`; Target base start. Conditions: `forCombat().range(followDistance)` plus the optional selector. `targetType` can be a class (zombie targets villagers etc.) or the player type. Mobs with `randomInterval` of 10 run this check on average every 10 evaluations (every ~20 ticks).

**HurtByTargetGoal(mob, ignoredAttackerClasses...)** flags TARGET. *Constructed with `mustSee = true` (the `TargetGoal` base).* *Triggers* when the mob has been hurt anew (`lastHurtByMobTimestamp` differs from the timestamp the goal last handled) by an attacker that: is not a player while the game rule `universal_anger` is on (the universal-anger goal 4.8 handles that case); is not an instance of any class in `ignoredAttackerClasses` (checked with `isAssignableFrom`; for example `HurtByTargetGoal(this, Raider.class)` makes a raider not retaliate against other raiders); and passes the `HURT_BY_TARGETING` conditions (combat, line of sight and invisibility ignored). *On start*: `setTarget(attacker)`, `unseenMemoryTicks = 300`, and, when alerting is enabled (`setAlertOthers(...)` was called), **alert others**: every mob in the box `unitCubeFromLowerCorner(mob.position).inflate(followDistance, 10, followDistance)` whose runtime class is the same as (or a subclass of) the alerting mob's class (`getEntitiesOfClass` with the `NO_SPECTATORS` selector), other than the mob itself, with no target, that is not a tamable animal with a different owner, is not an ally of the attacker, and whose exact class is **not** one of the classes passed to `setAlertOthers(...)` (that argument is an exclusion list: those classes are never alerted), gets `setTarget(attacker)` (`alertOther`, which individual mobs may override). Used for packs and for groups of the same type (wolves, zombified piglins, iron golems against attackers of a village, and so on).

Other target goals (OwnerHurtByTargetGoal, OwnerHurtTargetGoal, NonTameRandomTargetGoal, DefendVillageTargetGoal, NearestAttackableWitchTargetGoal, ResetUniversalAngerTargetGoal) exist and are mob-specific; they use the same TargetGoal base.

**Sensing** (`Sensing.hasLineOfSight(target)`): a per-tick cache of ray-casts from the mob's eye to the target's eye point (`hasLineOfSight` using a collider clip with fluids ignored); the cache is cleared at the start of `serverAiStep`.

**`Mob.setTarget` / `canAttack`**: `setTarget` stores the target; `Mob.canAttack(target)` is false for every mob when the target is a ghast, otherwise it is `LivingEntity.canAttack`: false when the target is a Player and the level difficulty is Peaceful, else `target.canBeSeenAsEnemy()` (not invulnerable, not a spectator, alive). `getTarget()` returns the stored target if alive and valid (`asValidTarget`).


### 4.4 Controls

**MoveControl** (ground mobs). State: `operation` (WAIT, MOVE_TO, STRAFE, JUMPING), the wanted position, `speedModifier`, the strafe inputs. `setWantedPosition(x, y, z, speed)` stores them and sets MOVE_TO (unless the control is JUMPING); `strafe(forward, right)` sets STRAFE with those inputs and `speedModifier = 0.25`. Rules each tick (`MoveControl.tick`, read):
- **STRAFE**: `moveSpeed = movement_speed x speedModifier`. The input `(forward, right)` is scaled so its length is at most 1 and multiplied by `moveSpeed`; it is rotated by the mob's yaw (`dx = right x cos - forward x sin`, `dz = forward x cos + right x sin`). If the block at `(mob.x + dx, mob.y, mob.z + dz)` is not WALKABLE for the mob's node evaluator, the inputs are replaced by forward 1, right 0. The mob's `speed`, `zza` (forward) and `xxa` (right) are set, and the operation becomes WAIT.
- **MOVE_TO**: the operation becomes WAIT. With `(dx, dy, dz)` to the wanted position: if `dx^2 + dy^2 + dz^2 < 2.5000002779052011E-7` the forward input is set to 0 and nothing else happens (arrived). Otherwise the yaw turns toward `atan2(dz, dx) in degrees - 90` by at most 90 degrees per tick (`rotlerp`), `speed = speedModifier x movement_speed`, and the mob **jumps** (`JumpControl.jump()`, operation becomes JUMPING) when either: the wanted point is higher than `step_height` and the horizontal squared distance is below `max(1.0, bbWidth)`; or the block at the mob's position has a non-empty collision shape whose top (plus the block y) is above the mob's feet and the block is not in tag `doors` or `fences`.
- **JUMPING**: `speed = speedModifier x movement_speed`; when the mob is on the ground, or is in a liquid and affected by fluids, the operation returns to WAIT.
- **WAIT**: the forward input is 0.
`rotlerp(a, b, max)`: the angle difference `wrapDegrees(b - a)` limited to `[-max, max]`, added to `a` and normalised into 0..360.

**FlyingMoveControl(mob, maxTurn, hoversInPlace)** (read): in MOVE_TO the operation becomes WAIT and gravity is switched off (`setNoGravity(true)`); with the vector to the wanted position, if its squared length is below 2.5E-7 the vertical and forward inputs are set to 0 and nothing else happens; otherwise the yaw turns toward `atan2(dz, dx) - 90` degrees by at most `maxTurn`; `speed = speedModifier x flying_speed` when airborne or `speedModifier x movement_speed` when on the ground (the mob must have the `flying_speed` attribute for the first case); the pitch turns to `-atan2(dy, horizontalDistance)` (limited to `maxTurn`) when either component is above 1.0E-5; and the vertical input `yya` is `speed` when the target is above and `-speed` when below. When not in MOVE_TO: if `hoversInPlace` is false gravity is switched back on; `yya` and `zza` are 0.

**SmoothSwimmingMoveControl(mob, maxTurnX, maxTurnY, inWaterSpeedModifier, outsideWaterSpeedModifier, applyGravity)** (dolphins, fish, nautiluses; the two ints are the maximum pitch and yaw turn per tick). Each tick (read): if `applyGravity` and the mob is in water, add `(0, 0.005, 0)` to its velocity. If the operation is not MOVE_TO or the navigation is done: `speed = 0`, `xxa = yya = zza = 0` and stop. Otherwise, with the vector `(dx, dy, dz)` to the wanted position: if its squared length is below 2.5E-7, `zza = 0` and stop; `targetYaw = atan2(dz, dx) deg - 90`; `yRot = rotlerp(yRot, targetYaw, maxTurnY)`; body yaw and head yaw are set equal to `yRot`; `base = speedModifier x movement_speed`. *In water*: `speed = base x inWaterSpeedModifier`; if `|dy| > 1.0E-5` or the horizontal distance `> 1.0E-5`: `targetPitch = clamp(wrapDegrees(-atan2(dy, horizontalDistance) deg), -maxTurnX, +maxTurnX)` and `xRot = rotateTowards(xRot, targetPitch, 5.0)`; then `zza = cos(xRot) x base`, `yya = -sin(xRot) x base` (using `base`, not the water-modified speed). *Out of water*: `speed = base x outsideWaterSpeedModifier x turningFactor`, with `turningFactor = 1 - clamp((|wrapDegrees(yRot - targetYaw)| - 10) / 50, 0, 1)`.

**LookControl**: state: `lookAtCooldown`, `wantedX/Y/Z`, `yMaxRotSpeed`, `xMaxRotAngle`. `setLookAt(x, y, z [, yMaxRotSpeed = mob.getHeadRotSpeed() (10), xMaxRotAngle = mob.getMaxHeadXRot() (40)])` stores the target and sets `lookAtCooldown = 2`. `setLookAt(entity [, ySpeed, xAngle])` uses the entity's (x, eyeY, z). `tick`: if `resetXRotOnTick` (true) then `mob.xRot = 0` first; if `lookAtCooldown > 0`: decrement; `yHeadRot = rotateTowards(yHeadRot, wantedYaw, yMaxRotSpeed)` where `wantedYaw = atan2(dz, dx) deg - 90` (undefined if the horizontal offset is below 1.0E-5) and `xRot = rotateTowards(xRot, wantedPitch, xMaxRotAngle)` where `wantedPitch = -atan2(dy, horizontalDistance) deg` (skipped if both offsets are below 1.0E-5); else (no look target recently): `yHeadRot = rotateTowards(yHeadRot, yBodyRot, 10)`. Then if the navigation is not done: `yHeadRot = rotateIfNecessary(yHeadRot, yBodyRot, getMaxHeadYRot() (75))` (the head is clamped to within 75 degrees of the body). `Mob.lookAt(entity, yMax, xMax)` (the older direct helper) turns `xRot` and `yRot` immediately with `rotlerp`.

**SmoothSwimmingLookControl(mob, maxYawDiff)**: like LookControl but, while the navigation is not done, the head pitch is limited and the body pitch eased by 5 degree steps; the head is clamped within `maxYawDiff` of the body; the constants `10.0f` (added to the target pitch) and `20.0f` (added to the yaw limit) are read in its two lambdas.

**JumpControl**: `jump()` sets `jump = true`; `tick`: `mob.setJumping(jump); jump = false`. So a jump request lasts one tick of the `jumping` input, and `LivingEntity.aiStep` (2.6 step 6) turns it into a jump when on the ground.

**BodyRotationControl** (`clientTick`, runs on the client for the visual body yaw; the server's body yaw follows 2.3 step 5): the head and body are rotated toward each other when the entity moves (squared horizontal speed > 2.5E-7) or has a mob passenger: body yaw is set to the entity's yaw and the head is clamped within `getMaxHeadYRot` (75) of the body; while standing still, after the head has been turned more than 15 degrees from the body for more than 10 ticks the body rotates toward the head by up to a ratio that eases from 1 down over `(counter - 10)/10` (clamped to [0, 1]), keeping the head within `max - 1` degrees: i.e. a stationary mob turns its body lazily after its head has looked aside for 10+ ticks (the 15 degree, 10 tick and 75 degree constants are read; the easing ratio form is inferred).

### 4.5 Brain system

Used by (mobs whose `customServerAiStep` ticks a `Brain`): villagers, wandering traders do not (goals), piglins, piglin brutes, hoglins, allays, frogs, warden, camel, sniffer, axolotl, goat, armadillo, breeze, nautilus, happy ghast (the per-mob documents list which mobs use a Brain). The Brain is a registry-driven state machine; each mob supplies the memory modules, sensors and activities.

**Memory modules** (`MemoryModuleType`, registry names): dummy, home, job_site, potential_job_site, meeting_point, secondary_job_site, mobs, visible_mobs, visible_villager_babies, nearest_players, nearest_visible_player, nearest_visible_targetable_player, nearest_visible_targetable_players, walk_target, look_target, attack_target, attack_cooling_down, interaction_target, breed_target, ride_target, path, doors_to_close, nearest_bed, hurt_by, hurt_by_entity, avoid_target, nearest_hostile, nearest_attackable, hiding_place, heard_bell_time, cant_reach_walk_target_since, golem_detected_recently, danger_detected_recently, last_slept, last_woken, last_worked_at_poi, nearest_visible_adult, nearest_visible_wanted_item, nearest_visible_nemesis, play_dead_ticks, tempting_player, temptation_cooldown_ticks, gaze_cooldown_ticks, long_jump_cooling_down, long_jump_mid_jump, has_hunting_cooldown, ram_cooldown_ticks, ram_target, is_in_water, is_pregnant, is_panicking, unreachable_tongue_targets, visited_block_positions, unreachable_transport_block_positions, transport_items_cooldown_ticks, charge_cooldown_ticks, attack_target_cooldown, spear_fleeing_time, spear_fleeing_position, spear_charge_position, spear_engage_time, spear_status, angry_at, universal_anger, admiring_item, time_trying_to_reach_admire_item, disable_walk_to_admire_item, admiring_disabled, hunted_recently, celebrate_location, dancing, nearest_visible_huntable_hoglin, nearest_visible_baby_hoglin, nearest_targetable_player_not_wearing_gold, nearby_adult_piglins, nearest_visible_adult_piglins, nearest_visible_adult_hoglins, nearest_visible_adult_piglin, nearest_visible_zombified, visible_adult_piglin_count, visible_adult_hoglin_count, nearest_player_holding_wanted_item, ate_recently, nearest_repellent, pacified, roar_target, disturbance_location, recent_projectile, is_sniffing, is_emerging, roar_sound_delay, dig_cooldown, roar_sound_cooldown, sniff_cooldown, touch_cooldown, vibration_cooldown, sonic_boom_cooldown, sonic_boom_sound_cooldown, sonic_boom_sound_delay, liked_player, liked_noteblock, liked_noteblock_cooldown_ticks, item_pickup_cooldown_ticks, sniffer_explored_positions, sniffer_sniffing_target, sniffer_digging, sniffer_happy, breeze_jump_cooldown, breeze_shoot, breeze_shoot_charging, breeze_shoot_recover, breeze_shoot_cooldown, breeze_jump_inhaling, breeze_jump_target, breeze_leaving_water.

A memory slot is empty (absent) or holds a value, optionally with a time-to-live in ticks (`setMemoryWithExpiry(module, value, ttl)`); each Brain tick decrements the TTL and erases the memory at 0. `eraseMemory` clears it.

**Sensors** (`SensorType`, registry names): dummy, nearest_items, nearest_living_entities, nearest_players, nearest_bed, hurt_by, villager_hostiles, villager_babies, secondary_pois, golem_detected, armadillo_scare_detected, piglin_specific_sensor, piglin_brute_specific_sensor, hoglin_specific_sensor, nearest_adult, nearest_adult_any_type, axolotl_attackables, food_temptations, frog_temptations, nautilus_temptations, frog_attackables, is_in_water, warden_entity_sensor, breeze_attack_entity_sensor. A sensor runs `doTick` every `scanRate` ticks (default **20**; the first run is randomly delayed `RS.nextInt(scanRate)` so mobs do not synchronise) and writes memories. Sensor helpers: `isEntityTargetable` and `isEntityAttackable` use `TargetingConditions` (4.3) with the range set to the mob's `follow_range` each tick; they additionally require that the entity is already the current `attack_target` or pass the ignore-invisibility variants.

**Activities** (`Activity`): core, idle, work, play, rest, meet, panic, raid, pre_raid, hide, fight, celebrate, admire_item, avoid, ride, play_dead, long_jump, ram, tongue, swim, lay_spawn, sniff, investigate, roar, emerge, dig.

**Brain tick** (`Brain.tick`): (1) `tickSensors`: each sensor `tick`; (2) the schedule: a mob with a schedule (villager) calls `updateActivityFromSchedule(attributeSystem, gameTime, position)` which, when the activity from the environment schedule attribute (daily timeline, `villager_schedule`) differs from the current one and at most every 20 ticks, switches the active activity; (3) `startEachNonRunningBehavior`: for each active activity (the core activities always active, plus the chosen one) in priority order, for each behaviour whose entry conditions (required memory present/absent/registered) hold and which is in the STOPPED state: `tryStart` (each behaviour decides with its own start conditions and random chance); (4) `tickEachRunningBehavior`: each running behaviour's `tickOrStop` (a behaviour has a max duration after which it stops). Activities are chosen by `setActiveActivityToFirstValid(list)` (the first activity in the list whose memory requirements are met) or by schedule; `setDefaultActivity` is the fallback (idle). Behaviours are grouped in priority-ordered lists per activity; a behaviour's control over MOVE/LOOK is expressed by the memories `walk_target` and `look_target`: the Brain mob's `MoveControl` is driven by `walk_target` through a `MoveToTargetSink` core behaviour (path to the target, with a timeout when the target is unreachable, recorded in `cant_reach_walk_target_since`), and `LookControl` by `look_target` (`LookAtTargetSink`).

### 4.6 Shared sensors and behaviours

Read from the sensor and behaviour classes. `Brain` mobs: the set that uses a Brain is the set whose `customServerAiStep` ticks it; the per-mob catalogues (19, 21) list which mobs and which behaviours at which priority and with which parameters.

**Behaviour base class** (`Behavior`): constructed with a map of required memory states (each module must be `VALUE_PRESENT`, `VALUE_ABSENT` or `REGISTERED`) and a duration range `[minDuration, maxDuration]` (default **60 and 60**). `tryStart(level, mob, time)`: all required memories must match and `checkExtraStartConditions` must hold; then the status becomes RUNNING, the end time is `time + minDuration + nextInt(maxDuration - minDuration + 1)`, and `start` runs. `tickOrStop`: while `canStillUse` (default false) and the end time has not passed (`timedOut`: game time greater than the end time) `tick` runs, else `doStop` (status STOPPED, `stop` runs). **GateBehavior / RunOne**: a behaviour made of weighted children (`ShufflingList` of `(behaviour, weight)` pairs); `RunOne` uses order policy SHUFFLED (weighted random order) and running policy RUN_ONE (start the first child that can start and run only that one); `TriggerGate` and sequences use the other policies; a gate is running while any child runs and its required memories are the union of its children's. `OneShot` behaviours (built declaratively with `BehaviorBuilder`) run once at start and finish immediately.

**Sensors** (every `scanRate` = 20 ticks, with a random initial delay, 4.5):
- `nearest_living_entities` (`NearestLivingEntitySensor`): the living entities in the mob's bounding box inflated by the `follow_range` attribute value (all three axes), excluding the mob and the dead, sorted by distance to the mob: stored as `nearest_living_entities`; the subset that the mob can see (line of sight, `NearestVisibleLivingEntities`) as `nearest_visible_living_entities`.
- `nearest_players` (`PlayerSensor`): non-spectator players within the mob's follow range (the sensor's `getFollowDistance` = `follow_range`), sorted by distance: `nearest_players`; the first one that is targetable (`isEntityTargetable`) and visible as `nearest_visible_player`; the attackable ones (`isEntityAttackable`) as `nearest_visible_targetable_players` and the first as `nearest_visible_targetable_player`.
- `hurt_by` (`HurtBySensor`): copies the mob's last damage source type to `hurt_by` and its causing entity to `hurt_by_entity`; erases `hurt_by` when there is no damage source; erases `hurt_by_entity` when that entity is no longer alive or in the same level.
- `nearest_items` (`NearestItemSensor`): item entities in the box inflated by (32, 16, 32) that the mob `wantsToPickUp`, are within 32 blocks and visible: the closest is stored as `nearest_visible_wanted_item`.
- `nearest_bed` (`NearestBedSensor`, scan rate 20): not for babies; at most once per 20 ticks randomised, finds the home-type points of interest (beds) within 48 blocks (any occupancy), tries a path to each not recently failed; a reachable one is stored as `nearest_bed`; unreachable ones are remembered in a map for 40 ticks (retry counters up to 5).
- `nearest_adult` (`AdultSensor`): from `nearest_visible_living_entities`, the closest entity of the same type that is not a baby: `nearest_visible_adult`.
- `food_temptations` / `frog_temptations` / `nautilus_temptations` (`TemptingSensor`): the nearest non-spectator player within the mob's `tempt_range` attribute who passes the non-combat conditions (ignoring line of sight) and holds a tempting item in either hand and is not riding the mob: `tempting_player`; erased when none. For animals the item test is `Animal.isFood`.
- `villager_babies`: villager babies from the visible entities as `visible_villager_babies`. `is_in_water`: sets `is_in_water` (a unit marker) when the mob is in water, else erases it.
- The remaining sensors (`secondary_pois`, `villager_hostiles`, `golem_detected`, `armadillo_scare_detected`, `piglin_specific_sensor`, `piglin_brute_specific_sensor`, `hoglin_specific_sensor`, `axolotl_attackables`, `frog_attackables`, `warden_entity_sensor`, `breeze_attack_entity_sensor`) were listed but their bodies were not read (Open question 3).

**Core behaviours read**:
- `MoveToTargetSink(minDuration 150, maxDuration 250)` (core activity): requires `walk_target` present and `path` absent. Starts if a path can be computed to the target block (`createPath(target, 0)`); remembers `cant_reach_walk_target_since` when the target is unreachable (the first time; and, when the target is not reached, tries a fallback `DefaultRandomPos.getPosTowards(mob, 10, 7, target, PI/2)` once); keeps running while a path remains and the mob has not reached the target (`reachedTarget`: Manhattan distance to the target block at most the walk target's `closeEnoughDist`); while running, re-paths when the target moved more than 2 blocks (squared 4.0); on stop erases `walk_target` and `path`, and if the navigation reports `isStuck` the sink also waits a random `nextInt(40)` ticks (as a cooldown through `stop`); a spectator walk target is ignored.
- `LookAtTargetSink(min, max)` (core): runs while `look_target` is present and visible; each tick calls `LookControl.setLookAt(target position)`; erases `look_target` on stop.
- `Swim(chance)` (core): runs when the mob is deeper than the fluid jump threshold in `entity_floatable` fluid or in lava; each tick with probability `chance` calls `JumpControl.jump()` (for example 0.8).
- `AnimalPanic(speedModifier [, panicCauseTag, ...])` (default cause tag `panic_causes`; durations 100 to 120): starts when the mob's `hurt_by` damage type matches and `is_panicking` is absent; on start sets `is_panicking`, clears `walk_target`, stops the navigation; each tick, when the navigation is done, chooses a panic position (water within 5 blocks if the mob is on fire, otherwise `LandRandomPos.getPos(mob, 5, 4)`, or for flyers `AirAndWaterRandomPos.getPos(mob, 5, 4, ...)`) and sets `walk_target` to it at the speed modifier; erases `is_panicking` on stop.
- `AnimalMakeLove(type [, speedModifier = 1.0, closeEnoughDist = 2])` (duration 110): requires `nearest_visible_living_entities` present, `breed_target` absent, `is_panicking` absent; starts when the mob is in love and a visible partner of the same type that can mate exists (the closest); sets `breed_target` on both and makes them walk to and look at each other; `canStillUse`: both alive, can mate, visible to each other and not panicking; each tick re-aims and, when within 3 blocks (squared 9), calls `spawnChildFromBreeding`; on stop erases `breed_target`, `walk_target` and `look_target`; its random delay is `60 + nextInt(50)` after breeding.
- `BabyFollowAdult(range, speedModifier)`: for a baby with a `nearest_visible_adult`, when farther than `range.minInclusive`, sets `look_target` (entity tracker) and `walk_target` toward the adult at the speed modifier with a close-enough distance of `range.minInclusive - 1`.
- `RandomStroll`, `StrollAroundPoi`, `SetWalkTargetFromLookTarget`, `SetEntityLookTarget`, `SetEntityLookTargetSometimes`, `FollowTemptation`, `MeleeAttack`, `StartAttacking`, `StopAttackingIfTargetInvalid`, `SetWalkTargetAwayFrom`, `SetWalkTargetFromAttackTargetIfTargetOutOfReach`, `RunOne`/`GateBehavior` compositions, `CountDownCooldownTicks`, `DoNothing`, `EraseMemoryIf`, `InteractWithDoor`, and the rest of the 128 classes (`AcquirePoi`, `AssignProfessionFromJobSite`, `CelebrateVillagersSurvivedRaid`, `ChargeAttack`, `Croak`, `GoAndGiveItemsToTarget`, `GoToClosestVillage`, `HarvestFarmland`, `JumpOnBed`, `LocateHidingPlace`, `LongJump*`, `Mount`, `MoveToSkySeeingSpot`, `PlayTagWithOtherKids`, `PoiCompetitorScan`, `PrepareRamNearestTarget`, `RamTarget`, `ReactToBell`, `RingBell`, `SetHiddenState`, `ShowTradesToPlayer`, `SleepInBed`, `SocializeAtBell`, `Spear*`, `StrollThroughPoi*`, `TradeWithVillager`, `TransportItemsBetweenContainers`, `TryFind*`, `TryLaySpawnOnFluidNearLand`, `UseBonemeal`, `ValidateNearbyPoi`, `VillagerMakeLove`, `WakeUp`, `WorkAtComposter`, `WorkAtPoi`, `YieldJobSite` and the `warden` package) are declarative or mob-specific and were **not** read: their parameters are not in this document (Open question 3).

### 4.7 Shared behaviours cited by the mob documents

The behaviour classes below are the ones that [19](19-mobs-land-friendly-and-neutral.md), [20](20-mobs-overworld-hostile.md) and [21](21-mobs-aquatic-nether-end-bosses-and-entities.md) name. Most are built with the declarative `BehaviorBuilder`; the table gives what was read: the memory conditions (present, absent or merely registered) under which they run, the constants, and the effect. "Walk target" means setting memory `walk_target` (a position or entity tracker, a speed modifier and a close-enough distance, which `MoveToTargetSink` of 4.6 then executes). Per-mob arguments (speeds, ranges, durations) are in the mob documents. Behaviours that those documents name but that were not read are listed at the end.

| Behaviour | Runs when | Effect |
|---|---|---|
| `CountDownCooldownTicks(memory)` | the integer memory is present | each tick decrements the memory by 1; stops (and erases it) when it reaches 0; never times out |
| `DoNothing(min, max)` | always (no memories) | occupies its slot for `min + nextInt(max - min + 1)` ticks (used to pad a `RunOne`) |
| `RandomStroll.stroll(speed [, canFloat])` | `walk_target` absent | picks `LandRandomPos.getPos(mob, 10, 7)` (or the swim/fly variants: `fly` uses `AirAndWaterRandomPos.getPos(mob, 10, 7, ...)` along the view direction; `swim` tiers the horizontal distance and uses `BehaviorUtils.getRandomSwimmablePos`) and sets `walk_target` (close-enough 0); the land variant skips mobs in water unless `canFloat`; `stroll(speed, xyRange, yRange)` uses custom ranges |
| `SetEntityLookTarget(filter, maxDistance)` | `look_target` absent, `nearest_visible_living_entities` present | sets `look_target` to the closest visible entity matching the filter (a category, type, or predicate) whose squared distance to the mob is at most `maxDistance^2` (`create` squares the argument) and that is not riding the looking mob (`mob.hasPassenger(entity)` excludes it) |
| `SetEntityLookTargetSometimes(maxDistance, interval)` | same | as above but only when a countdown `Ticker` (a uniform interval of ticks) fires |
| `SetWalkTargetFromLookTarget(speed, closeEnough)` | `walk_target` absent, `look_target` present | sets `walk_target` to the look target at the given speed |
| `StartAttacking(condition, finder)` | `attack_target` absent | when the condition holds, the finder returns a target and `canAttack` accepts it: sets `attack_target` and erases `cant_reach_walk_target_since` |
| `StopAttackingIfTargetInvalid(condition, callback)` | `attack_target` present | erases `attack_target` (and calls the callback) when the target is in a different level, `mob.canAttack` fails, it is dead, `cant_reach_walk_target_since` is more than 200 ticks old (tired of trying), or the stop condition holds |
| `MeleeAttack(cooldownTicks)` | `attack_target` present, `attack_cooling_down` absent, `nearest_visible_living_entities` present | when the target is in melee range and visible: sets `look_target`, swings, `doHurtTarget`, sets `attack_cooling_down` (true, expiring after the given ticks) |
| `SetWalkTargetFromAttackTargetIfTargetOutOfReach(speed)` | `attack_target` present | when the target is visible and within attack range erases `walk_target` and looks at it; otherwise sets `look_target` and `walk_target` to the target at the speed (the speed may depend on the target) |
| `SetWalkTargetAwayFrom(memory, speed, distance, isEntity)` | the memory is present, `walk_target` registered | when the memory position is closer than `distance`: if there is already a walk target moving away from it nothing changes; else sets a walk target to `LandRandomPos.getPosAway(mob, 16, 7, position)` |
| `FollowTemptation(speedFn [, closeEnoughFn])` | `tempting_player` present, `temptation_cooldown_ticks`, `breed_target` and `is_panicking` absent | each tick sets `look_target` to the player and, when the mob is farther than the close-enough distance (default 2.5 blocks, compared squared; the class also has a constant `BACKED_UP_CLOSE_ENOUGH_DIST` of 3.5), `walk_target` to the player at the speed; erases `walk_target` when close; on stop sets `temptation_cooldown_ticks = 100` and erases `walk_target` and `look_target`; never times out |
| `StayCloseToTarget(getter, predicate, closeEnough, tooFar, speed)` | always | when the tracked position is not within `tooFar` blocks and the predicate holds, sets `look_target` and `walk_target` toward it |
| `BackUpIfTooClose(distance, speed)` | `walk_target` absent, `attack_target` and `nearest_visible_living_entities` present | when the attack target is closer than `distance` and visible: sets `look_target`, strafes backwards via `MoveControl.strafe(-speed, 0)` and aligns the body yaw (`rotateIfNecessary`) |
| `BecomePassiveIfMemoryPresent(memory, ticks)` | `attack_target` registered, `pacified` absent, the given memory present | erases `attack_target` and sets `pacified` with expiry `ticks` (the given memory is **not** erased) |
| `StopBeingAngryIfTargetDead` | `angry_at` present | erases `angry_at` when the referenced entity is dead, except a dead player when the game rule `forgive_dead_players` is off |
| `StartCelebratingIfTargetDead(ticks, predicate)` | `attack_target` present, `celebrate_location` absent | when the target is dead (and the predicate holds, and for players `forgive_dead_players` is on) sets `dancing` and `celebrate_location` (the mob's block) for the given ticks and erases `attack_target` and `angry_at` |
| `TryFindLand(range, speed)` | `attack_target`, `walk_target` absent | while the mob is in water, at most once per 60 ticks (a mutable timer): finds the nearest block within `range` (Manhattan, closest first) whose collision shape at the position is empty, whose block below has a **sturdy top face** and which has **no fluid**; sets `look_target` and `walk_target` (speed, close-enough 1) to it |
| `TryFindLandNearLiquid(range, speed)` | same | does not start while the mob stands in the fluid; at most once per 40 ticks: finds the nearest candidate whose collision shape is empty, whose block below has a non-empty collision shape, and which has a horizontal neighbour that is **air** whose block below holds the fluid (a shoreline); sets `look_target` and `walk_target` (close-enough 0) |
| `TryFindLiquid(range, speed)` | same | while the mob is not in the fluid, every 20 ticks (the timer is re-armed with 40 when it finds nothing and 2 when it starts moving, per the constants 20, 2 and 40): scans for a block of the fluid with air above it (`forEachUntil`), preferring one within 1.5 blocks of the mob, and sets `look_target` and `walk_target` to the position above it |
| `TryLaySpawnOnFluidNearLand(block)` | `attack_target` absent, `walk_target` and `is_pregnant` present | when the mob is on the ground next to a fluid that supports frogspawn at the block below a face-adjacent block, places the block and clears `is_pregnant` (the frog's egg laying) |
| `Croak(...)` (frog) | `walk_target` absent | 60 ticks (max duration 100): sets the CROAKING pose while not in liquid; standing otherwise |
| `GoToWantedItem(filter, speed, interrupt, range)` | `nearest_visible_wanted_item` present, `item_pickup_cooldown_ticks` absent | when the item is within the range, inside the world border and `canPickUpLoot`: sets `look_target` and `walk_target` to the item entity |
| `InsideBrownianWalk(speed)` | `walk_target` absent | a mob under open sky does nothing; otherwise picks the first block (in shuffled order) of the box mob +-1 whose position is collision free and standable and cannot see the sky, and walks there |
| `MoveToSkySeeingSpot(speed)` | `walk_target` absent | finds a position that can see the sky and sets it as the walk target |
| `SetHiddenState(ticks, distance)` | `hiding_place` and `heard_bell_time` present | a villager hiding after a bell: when more than 300 ticks since the bell it leaves hiding (erases both memories and refreshes the schedule); while within `distance` of the hiding place it counts hidden ticks |
| `SetLookAndInteract(type, distance)` | `interaction_target` absent, `nearest_visible_living_entities` present | looks at and sets `interaction_target` to the closest visible entity of the type within the distance |
| `SetWalkTargetFromBlockMemory(memory, speed, closeEnough, maxDistance, maxTries)` | `walk_target` absent, the block memory present | walks to the remembered block position if it is in the same dimension and within the Manhattan distance limit; releases the point of interest and gives up after the retry count (tracks `cant_reach_walk_target_since`) |
| `StrollAroundPoi(memory, speed, maxDistance)` | `walk_target` registered, the position memory present | every 180 ticks (a mutable timer) within the distance of the point: `LandRandomPos.getPos(mob, 8, 6)` as the walk target |
| `StrollToPoi(memory, speed, closeEnough, maxDistance)` | same | when farther than `maxDistance` from the point (and the timer, 80 ticks, allows) walks toward the point |
| `VillageBoundRandomStroll(speed [, xzRange, yRange])` (default 10 and 7) | `walk_target` absent | `LandRandomPos.getPos(mob, xz, y)`; when the mob is inside a village the position stays in; otherwise it picks toward the closest village section (`DefaultRandomPos.getPosTowards(..., PI/2)`) |
| `ChargeAttack(...)` (typed on `Animal`) | `attack_target` present, `charge_cooldown_ticks` absent | within a distance window and with line of sight toward a non-tame target: lunges (`setDeltaMovement` toward the target), plays the sound; damage on contact; sets `charge_cooldown_ticks` and erases `attack_target` |
| `CrossbowAttack` | `attack_target` present (max duration 1200) | states UNCHARGED, CHARGING, CHARGED, READY_TO_ATTACK; holds a crossbow, charges by using it for `CrossbowItem.getChargeDuration`, shoots when charged and visible; clears the charged projectile on stop |
| `Mount` | `ride_target` present, `walk_target` absent | when within the close distance `startRiding(target)`; otherwise walks to it |
| `PrepareRamNearestTarget(...)` (goat) | `ram_cooldown_ticks` and `ram_target` absent, `nearest_visible_living_entities` present (max duration 160) | selects the closest visible, alive target for which a path exists (`createPath`, `canReach`); walks to the start position of the chosen target and looks at it; on stop, if no `ram_target` was set, Entity Event **59** is broadcast and `ram_cooldown_ticks` is set (a per-mob function of the goat); the candidate-selection details beyond the above were not read |
| `RamTarget(...)` (goat) | `ram_cooldown_ticks` absent, `ram_target` present (max duration 200) | charges along the line to the ram target (walk target set along the normalised direction), damages entities hit with `no_aggro_mob_attack` damage of the `attack_damage` attribute and knocks them back, speed effect scaled; sets the cooldown |
| `CopyMemoryWithExpiry(condition, source, target, duration)` | the source present, the target absent | copies the memory with an expiry sampled from the uniform duration |
| `UpdateActivityFromSchedule` | always | calls `Brain.updateActivityFromSchedule(attributes, gameTime, position)` (4.5) |

Read at the call level only (so only the shape above is certain): `ChargeAttack`, `RamTarget` and `PrepareRamNearestTarget` internals, `SetHiddenState`, `TryLaySpawnOnFluidNearLand`, `SetWalkTargetFromBlockMemory`. The specifics of the villager and raid behaviours named in 19 (`AcquirePoi`, `AssignProfessionFromJobSite`, `CelebrateVillagersSurvivedRaid`, `GiveGiftToHero`, `GoAndGiveItemsToTarget`, `GoToClosestVillage`, `GoToPotentialJobSite`, `HarvestFarmland`, `InteractWith`, `InteractWithDoor`, `JumpOnBed`, `LocateHidingPlace`, `LookAndFollowTradingPlayerSink`, `PlayTagWithOtherKids`, `PoiCompetitorScan`, `ReactToBell`, `ResetProfession`, `ResetRaidStatus`, `RingBell`, `SetClosestHomeAsWalkTarget`, `SetRaidStatus`, `ShowTradesToPlayer`, `SleepInBed`, `SocializeAtBell`, `StrollToPoiList`, `TradeWithVillager`, `TransportItemsBetweenContainers`, `UseBonemeal`, `ValidateNearbyPoi`, `VillagerCalmDown`, `VillagerMakeLove`, `VillagerPanicTrigger`, `WakeUp`, `WorkAtComposter`, `WorkAtPoi`, `YieldJobSite`) and the `LongJumpMidJump`, `LongJumpToPreferredBlock`, `LongJumpToRandomPos` behaviours were **not read** (Open question 3); their arguments are in the mob documents.

### 4.8 NeutralMob (persistent anger)

`NeutralMob` is the interface for mobs that stay angry at a target for a while (wolves, bees, endermen, iron golems, zombified piglins, polar bears and so on). State: `persistentAngerEndTime` (a game-time stamp; 0 or below means not angry), `persistentAngerTarget` (an entity reference), saved as `anger_end_time` and `angry_at`. Rules (read):
- `isAngry()`: the end time is above 0 and above the current game time (`endTime - gameTime > 0`). `setTimeToRemainAngry(ticks)` sets the end time to `gameTime + ticks` (the angry time is a per-mob uniform in the per-mob documents). `stopBeingAngry()` is a default interface method that sets the last-hurt-by mob to null, the persistent anger target to null, the target to null and the end time to **-1**. Saving writes `anger_end_time` and writes `angry_at` with a nullable store; loading reads `anger_end_time`, and when it is absent falls back to the legacy integer key `AngerTime` (applied through `setTimeToRemainAngry`), then reads `angry_at`.
- `isAngryAt(entity, level)`: false if the mob cannot attack the entity; true if the entity is a valid player target (not creative or spectator, and the difficulty is not Peaceful) and `isAngryAtAllPlayers`; otherwise true if the entity matches the persistent anger target.
- `isAngryAtAllPlayers(level)`: the game rule `universal_anger` is on, the mob is angry and it has **no** specific anger target.
- `updatePersistentAnger(level, canTrackTarget)`: if the mob has an anger target, **the anger target entity is dead or dying**, it matches the persistent anger target and the **dead target is a `Mob`**, then `stopBeingAngry` and return (a dead *player* target does not end the anger through this branch; `playerDied` handles it). Otherwise, if the mob has a (valid) target that differs from the anger target: the anger target is set to it and, when it changed or `canTrackTarget`, `startPersistentAngerTimer()` (per mob). If the anger target is set but the mob is no longer angry: `stopBeingAngry` unless a valid player target and `canTrackTarget`. If the anger target is a player who is creative or spectator, or the difficulty is Peaceful: `stopBeingAngry`.
- `playerDied(level, player)`: if the game rule `forgive_dead_players` is on and the dead player is the persistent anger target, the mob calls `stopBeingAngry()` (which clears the target, the anger target, the last-hurt-by mob and the end time).
- `forgetCurrentTargetAndRefreshUniversalAnger` and `startPersistentAngerTimer` are per-mob.
- **`ResetUniversalAngerTargetGoal(mob, alertOthers)`** (target selector): runs when `universal_anger` is on and the mob was hurt by a player (`wasHurtByPlayer`: the last hurt-by mob is a player and the timestamp is new); on start it records the timestamp and calls `forgetCurrentTargetAndRefreshUniversalAnger`; when `alertOthers` it does the same for every `NeutralMob` of the same type in the box `(followRange, 10, followRange)` around the mob (no spectators) that is not itself.

### 4.9 Monster base class

`Monster` extends `PathfinderMob`. Read: `Monster.createMonsterAttributes()` = `Mob.createMobAttributes()` (1.3 base) plus `attack_damage` at its registry default (**2.0**, the builder call has no explicit value); the experience reward is **5** (`xpReward`); `Monster.aiStep` calls `updateNoActionTime` first: the entity's own `getLightLevelDependentMagicValue()` (sampled at the block `(x, eyeY, z)`, and 0 when that chunk is not loaded); if it is **above 0.5**, `noActionTime += 2` (so a mob in bright light, which counts 1 per `serverAiStep` already, accumulates 3 per tick toward the random despawn threshold of 600, 6.11); then `PathfinderMob.aiStep`. `getWalkTargetValue(pos)` = `levelReader.getPathfindingCostFromLightLevels(pos)` = `lightLevelDependentMagicValue(pos) - 0.5` (negative in dim light), which is what makes hiding and wandering goals prefer shadow. `isPreventingPlayerRest` is true. The light-dependent magic value is `b = getMaxLocalRawBrightness(pos) / 15`, `v = b / (4 - 3 b)`, result `Mth.lerp(ambientLight, v, 1.0)` where `lerp(delta, start, end) = start + delta x (end - start)`, i.e. `v + ambientLight x (1 - v)` (`ambientLight` is the dimension type's `ambient_light`: 0 overworld, 0.1 nether, 0.25 end). The spawn rules `checkMonsterSpawnRules`, `checkAnyLightMonsterSpawnRules` and `isDarkEnoughToSpawn` are in 6.8. Monsters in `burn_in_daylight` burn per 2.7.

### 4.10 Conversion (`Mob.convertTo`)

`Mob.convertTo(type, ConversionParams, [spawnReason,] afterConversion)` (read): returns null if the old mob is removed or the new one cannot be created; creates the new mob (reason CONVERSION; **the freshly created mob's own pre-existing passengers are discarded first**); applies `ConversionType.convert(old, new, params)`; calls `afterConversion.finalizeConversion(new)`; adds the new entity **only when the level is a `ServerLevel`**; discards the old mob if the conversion type says so (`SINGLE` does, `SPLIT_ON_DEATH` does not); returns the new mob. `ConversionParams(type, keepEquipment, preserveCanPickUpLoot, team)`. A zombie that can break doors passes that flag on when the result is a zombie (per-mob code in the zombie conversion). With a params team the old mob is removed from that team when it is in the same team (and the new mob is added to it).

**Common copy** (`convertCommon`, both types): absorption amount; every active mob effect (copied as new instances); baby state and age for ageable mobs (`setBaby`, `setAge`) and the **forced age and forced-age timer**; the Brain memory `angry_at` if the new mob registers it; `canPickUpLoot` only if `preserveCanPickUpLoot`; left-handedness; no-AI; persistence required; custom name visibility; on-fire flag; permanently invulnerable; invulnerable time; no gravity; portal cooldown; silent; the entity tags; and the data components `custom_name` and `custom_data`.

**SINGLE**: position and rotation (`copyPosition`) and velocity; only the **first passenger** (`getFirstPassenger`) is handled: it is dismounted, its boarding cooldown set to 0, and it starts riding the new mob; the old mob's vehicle is taken over (the old stops riding, the new starts riding it); with `keepEquipment` every non-empty equipment slot is moved (`copyAndClear`) with its drop chance; the fall-flying flag, on-ground flag, **fall distance, `lastHurtByPlayerMemoryTime`, `hurtTime` and `yBodyRot`**; the sleeping position; the leash holder re-attached (`setLeashedTo`). **SPLIT_ON_DEATH**: only the first passenger is dismounted, the leash is dropped if there is a holder, then the common copy.

### 4.11 Bucketable

The implementers found in the jar are `AbstractFish` (all fish and the tadpole, which extends it), `Axolotl` and `SulfurCube`. `Bucketable` mobs hold a `fromBucket` flag. Read: `bucketMobPickup(player, hand, mob)`: when the held item can pick the mob up (`canBePickedUpWithBucket`: a water bucket) and the mob is alive: the pickup sound plays, the bucket is replaced by the mob's bucket item (`getBucketItemStack`, `ItemUtils.createFilledResult`), the entity data is saved into the item (`saveDefaultDataToBucketTag`: the custom name component is copied; the `bucket_entity_data` custom data gets `NoAI`, `Silent`, `NoGravity`, `Glowing`, `Invulnerable` and `PersistenceRequired` **only when that flag is true**, and `Health` **always**), the `FILLED_BUCKET` trigger fires for a server player, a leash is dropped, the mob is discarded, and the interaction is SUCCESS. Releasing restores the keys (`loadDefaultDataFromBucketTag`: the booleans, health, and `setPersistenceRequired` **only when the stored value is true**) and per-mob variant data (`loadFromBucketTag`). A mob taken from a bucket has `fromBucket = true` (used by the mob's `requiresCustomPersistence` and `removeWhenFarAway`, per mob).

---

## 5. Pathfinding

### 5.1 Path types and the malus table

Every block position is classified into a **path type** (`PathType`); each type has a default **malus** (cost added to a node; a negative malus means the node is blocked). A mob can override the malus per type (`Mob.setPathfindingMalus`; `getPathfindingMalus` returns the override or the type default; per-mob overrides are in the per-mob catalogues).

| id | PathType | default malus | meaning |
|---|---|---|---|
| 0 | BLOCKED | -1 | solid or impassable |
| 1 | OPEN | 0 | air |
| 2 | WALKABLE | 0 | a standable surface |
| 3 | WALKABLE_DOOR | 0 | an open or openable-by-mob door (wooden door that the mob can open) |
| 4 | TRAPDOOR | 0 | a trapdoor (including lily pad, big dripleaf classification) |
| 5 | POWDER_SNOW | -1 | |
| 6 | ON_TOP_OF_POWDER_SNOW | 0 | |
| 7 | FENCE | -1 | fences, walls, closed fence gates |
| 8 | LAVA | -1 | |
| 9 | WATER | 8 | |
| 10 | WATER_BORDER | 8 | next to water |
| 11 | RAIL | 0 | |
| 12 | UNPASSABLE_RAIL | -1 | |
| 13 | FIRE_IN_NEIGHBOR | 8 | next to fire or lava |
| 14 | FIRE | 16 | |
| 15 | DAMAGING_IN_NEIGHBOR | 8 | next to a damaging block |
| 16 | DAMAGING | -1 | cactus, sweet berry bush |
| 17 | DOOR_OPEN | 0 | |
| 18 | DOOR_WOOD_CLOSED | -1 | closed door the mob cannot open |
| 19 | DOOR_IRON_CLOSED | -1 | |
| 20 | BREACH | 4 | water surface (swimmers) |
| 21 | LEAVES | -1 | |
| 22 | STICKY_HONEY | 8 | |
| 23 | COCOA | 0 | |
| 24 | DAMAGE_CAUTIOUS | 0 | pointed dripstone, wither rose (SPELEOTHEMS) |
| 25 | ON_TOP_OF_TRAPDOOR | 0 | |
| 26 | BIG_MOBS_CLOSE_TO_DANGER | 4 | |

(The ids are the declaration order in `PathType`; they are used only in debug codecs.)

**Block -> path type** (`WalkNodeEvaluator.getPathTypeFromState`, read): air -> OPEN; blocks in tag `trapdoors`, lily pad, big dripleaf -> TRAPDOOR; powder snow -> POWDER_SNOW; cactus or sweet berry bush -> DAMAGING; honey block -> STICKY_HONEY; cocoa -> COCOA; wither rose or tag `speleothems` -> DAMAGE_CAUTIOUS; lava fluid -> LAVA; fire blocks -> FIRE; doors: open -> DOOR_OPEN, closed and openable by hand -> DOOR_WOOD_CLOSED, closed and not openable by hand (iron) -> DOOR_IRON_CLOSED; rails -> RAIL; leaves -> LEAVES; tags `fences`, `walls`, or an unopened fence gate -> FENCE; otherwise a block that is not pathfindable by land -> BLOCKED, else OPEN. Water fluid -> WATER (the order of the checks is the read order above).

**Static type of a position** (`getPathTypeStatic`): the type at the feet position; if it is OPEN, look at the block below (clamped to the world's minimum y): below is WATER -> WATER, LAVA -> LAVA, FIRE -> FIRE, DAMAGING -> DAMAGING, STICKY_HONEY -> STICKY_HONEY, ON_TOP_OF_POWDER_SNOW from powder snow, DAMAGE_CAUTIOUS -> DAMAGE_CAUTIOUS, TRAPDOOR -> ON_TOP_OF_TRAPDOOR, anything else -> WALKABLE. Then `checkNeighbourBlocks` (the 26 surrounding blocks, only for WALKABLE/OPEN-adjacent cases): a neighbour that is DAMAGING turns the type into DAMAGING_IN_NEIGHBOR, FIRE or LAVA neighbours -> FIRE_IN_NEIGHBOR, WATER neighbours -> WATER_BORDER, DAMAGE_CAUTIOUS neighbours -> DAMAGE_CAUTIOUS.

**Mob-aware type** (`getPathTypeOfMob(context, x, y, z, mob)`, read): collect the set of path types over the mob's bounding-box footprint at the node (`getPathTypeWithinMobBB`: a rail in or under the box gives RAIL, an unpassable rail UNPASSABLE_RAIL; closed doors the mob can open become WALKABLE_DOOR and open doors DOOR_OPEN). Then: a set with one type returns it; a set containing FENCE returns FENCE; one containing UNPASSABLE_RAIL returns UNPASSABLE_RAIL; otherwise look at each type's **mob malus**: the first type whose malus is **negative** is returned at once; else the result is the type with the **highest** malus (ties go to the later type) and `maxMalus` is that malus. Finally, a footprint wider than 1 block (`entityWidth > 1`) returns `BIG_MOBS_CLOSE_TO_DANGER` when the mob's malus for the origin type is below `maxMalus` and the mob's malus for `BIG_MOBS_CLOSE_TO_DANGER` is below `maxMalus` (otherwise the result type); for a width of 1 the result is returned, except that an origin type of OPEN with a non-OPEN result whose `maxMalus` is exactly 0 returns OPEN. (The branch conditions are read; the pairing of the two width conditions is **(inferred)**.)

### 5.2 Nodes, costs and A*

A **node** holds integer x, y, z; `g` (cost from the start), `h` (heuristic), `f = g + h`, `walkedDistance` (the sum of step distances, used as the search range limit), `costMalus` (the malus of the path type at the node, taking the maximum when a node is reached again), `closed`, `cameFrom`, and its `PathType`. Distances (`Node.distanceTo`): Euclidean `sqrt(dx^2 + dy^2 + dz^2)` in float; Manhattan `|dx| + |dy| + |dz|`.

**`PathFinder.findPath(region, mob, targets, maxDistanceFromStart, reach, searchDepthMultiplier)`** (read):
1. Clear the open set (a binary min-heap on `f`) and prepare the node evaluator (it takes the world snapshot and the mob). Get the start node; if it is null the result is null. Each target block position becomes a `Target` node.
2. Start: `start.g = 0`; `start.h = getBestH(start, targets)` where `getBestH` = the minimum over targets of `start.distanceTo(target)` (each target also records the best node seen, `updateBest`) -- **unweighted**; `start.f = start.h`; insert. Only neighbours get the 1.5 weight (step 4e).
3. The node budget is `maxVisitedNodes x searchDepthMultiplier` truncated to an integer (the navigation's `maxVisitedNodes` is `floor(follow_range x 16)`, `updatePathfinderMaxVisitedNodes`; the multiplier is the navigation's `maxVisitedNodesMultiplier`, 1.0 by default).
4. **Search loop.** Repeat while the open set is not empty and fewer than `budget` nodes have been popped:
   - Pop the node with the smallest `f` and close it. Every target within `reach` (Manhattan distance from the node to the target block `<= reach`) is marked reached. If any target is reached, stop.
   - A node at Euclidean distance `>= maxDistanceFromStart` from the start is not expanded.
   - Otherwise, for each neighbour `n` from the evaluator (never a closed node; 5.3): `dist = Euclidean(node, n)`; `n.walkedDistance = node.walkedDistance + dist`; `tentative = node.g + dist + n.costMalus`. The neighbour is (re)queued when `n.walkedDistance < maxDistanceFromStart` and (`n` is not in the open set or `tentative < n.g`): set `cameFrom = node`, `g = tentative`, `h = 1.5 x getBestH(n, targets)`, and `f = g + h` (the heap entry is re-keyed if already queued, else inserted).
5. Result: if some target was reached, the best path is the one of the reached targets with the **fewest nodes** (`Comparator.comparingInt(path length)`); if none was reached, the best is the path to the node that came closest to a target: the target with the smallest `bestHeuristic` (distance of its best node), ties broken by fewest nodes. `reconstructPath` follows `cameFrom` from the best node to the start (the path list runs from start to end). The path records whether the target was actually reached (`canReach`).
6. The evaluator is released (`done`).

Note the heuristic weight 1.5 (a weighted A*): paths are good but not guaranteed shortest.

`PathNavigation.createPath(targets, regionOffset, offsetUpward, reach, maxPathLength)`: returns null if the target set is empty or the mob's y is below the world's minimum y; if the current path exists, is not done and its target is in the set, the current path is returned unchanged. Otherwise it builds a snapshot region (`PathNavigationRegion`) covering the box around the mob and the targets padded by `regionOffset` (8 for block or set targets, 16 for entity targets) and calls `PathFinder.findPath` with `maxPathLength = max(follow_range, requiredPathLength)` (`getMaxPathLength`: the `follow_range` attribute value; `setRequiredPathLength` raises it, e.g. for specific goals), `searchDepthMultiplier` = the navigation's multiplier. For an entity target the target block is `entity.blockPosition()` shifted up by 1 when `offsetUpward` (so a mob paths to the block above the target's feet). The resulting path is stored together with its target position (`targetPos`) and `reach`.

### 5.3 Node evaluators

All evaluators share: a world snapshot (`PathfindingContext`), a mob, `canPassDoors` (default true), `canOpenDoors`, `canFloat`, `canWalkOverFences`, an entity-sized footprint (the number of blocks the mob's bounding box spans in x, y, z, rounded up: width, height, width) and caches of path types per position for the current search.

**WalkNodeEvaluator** (ground mobs):
- **Start node** (`getStart`): the mob's feet block; if the mob is on the ground use its y (floor of the bounding box minY + 0.5 when in water/on a fluid it can stand on); if in water and cannot float, scan down to the first non-water; if not on the ground and in air, scan down to the first solid; a start is accepted if the type there has `malus >= 0`; otherwise the four corner positions of the bounding box are tried (the evaluator tries `getStartNode` on each; returns the first valid). The start node's `costMalus` is the malus of its type.
- **Neighbours** (`getNeighbors`): for each of the 4 horizontal directions: `findAcceptedNode(x + dx, y, z + dz, jumpHeight, floorY, direction, nodeType)`; `isNeighborValid` requires non-null, not closed, and `(neighbour.costMalus >= 0 or node.costMalus < 0)`. Then **diagonals**: for each pair of adjacent cardinal directions, the diagonal node is added only if both adjacent cardinal nodes are valid (`isDiagonalValid` also rejects diagonals through WALKABLE_DOOR nodes, through FENCE neighbours when the mob is narrower than 0.5, and requires both cardinals to be non-negative-malus when the mob is wider than 1.0). The step height: `jumpHeight = max(1.125, step_height)` (`getMobJumpHeight`), and the count `floor(max(1, step_height))` is the vertical step-up allowed. If the mob's own start type is STICKY_HONEY the step is limited to 0 (a mob in honey cannot jump).
- **`findAcceptedNode`**: given a column position: determine the floor height at the column (`getFloorLevel`: top of the collision shape of the block below, or +0.5 when the position is in a fluid the mob floats on) and compare to the current floor: if the floor is higher than the jump height above the node's floor, try `tryJumpOn` (the node one up, accepted only if the head room box is free and the diagonal clearance holds) else blocked; if the type is WALKABLE/OPEN: accept at that y; if the type is OPEN (a gap) the evaluator scans down (`tryFindFirstGroundNodeBelow`) up to `mob.getMaxFallDistance()` blocks and accepts the landing node if the type there is not WATER-with-negative-malus; falling nodes get the malus of the **fall**: landing in water is rejected unless the mob accepts water; a node on a FENCE/UNPASSABLE_RAIL/TRAPDOOR/POWDER_SNOW/WATER/DAMAGING type is closed or blocked per its malus (the `getClosedNode` for malus-negative types: closed, `costMalus = malus`). When accepted, the node's `costMalus = max(costMalus, malus(type))` and `PathType` recorded; the evaluator also bumps the malus for nodes next to walls for WALKABLE_DOOR.
- **Max fall distance** (`Mob.getMaxFallDistance`, read): `getComfortableFallDistance(n)` is `floor(n + 3.0)` (the constant 3.0, not the `safe_fall_distance` attribute). With no target the result is `getComfortableFallDistance(0)` = 3. With a target: `n = (int)(health - maxHealth x 0.33)` (truncated by `f2i`), then `n -= (3 - difficultyId) x 4` (Peaceful 0, Easy 1, Normal 2, Hard 3), clamped to at least 0, and the result is `getComfortableFallDistance(n)`.
- **Target nodes**: `getTarget(x, y, z)` = a node at the block position.
- **Block corner cutting**: after a path is found, `PathNavigation.canCutCorner(type)` is true when the type is not FIRE_IN_NEIGHBOR, DAMAGING_IN_NEIGHBOR or WALKABLE_DOOR (a mob will cut across the corner of a node only if neighbour types are safe).

**SwimNodeEvaluator(allowBreaching)** (fish, squid, dolphin, axolotl in water, guardians; read): *Start*: the block at `(floor(minX), floor(minY + 0.5), floor(minZ))` of the mob's bounding box. *Neighbours*: the **6 face neighbours** (every `Direction`), each accepted when the node is non-null and not closed; then, for each of the 4 horizontal directions, the **horizontal diagonal** `(x + dx1 + dx2, y, z + dz1 + dz2)` formed by the direction and its clockwise neighbour, accepted when both face nodes it is built from exist with a non-negative `costMalus` and the diagonal node itself is valid. There are no vertical diagonals. *Accepting a position* (`findAcceptedNode`): its type must be WATER, or BREACH when `allowBreaching`; the node's malus is the mob's malus for that type and must be non-negative; the node gets `costMalus = max(existing, malus)`, and if the block has **no fluid** (an air position above the water) `costMalus += 8.0`. Type classification (`getPathTypeOfMob`, read): it scans the whole mob footprint (`entityWidth x entityHeight x entityDepth` cells from the node). Per cell: if the cell has **no fluid**, the block below is water-pathfindable and the cell is air, **BREACH is returned at once** (the `allowBreaching` test happens only later, in `findAcceptedNode`); if the cell has a fluid that is not water, **BLOCKED** is returned; after the loop, the state at the **last cell** decides: water-pathfindable gives WATER, otherwise BLOCKED. The mob's malus for WATER is 8 by default (5.1); fish classes set it to 0 so open water is free (per-mob catalogues).

**FlyNodeEvaluator** (bees, bats, allays, parrots, phantoms, ghasts, vexes): *Start*: the mob's block (if in water, the first non-water block above); if the start type has a negative malus (`canStartAt`), candidate positions inside the mob's bounding box inflated by `max(0, 1.1 - size)` per axis are tried, **10** random block positions (`randomBetweenClosed`). *Neighbours*: the 6 face neighbours (each accepted when `isOpen`: non-null, not closed, malus >= 0); then the 12 edge neighbours and 8 corner neighbours, each accepted when `isOpen` and every face neighbour it is composed of is a valid node (`hasMalus`: non-null and non-negative cost). *Accepting a node* (`findAcceptedNode`): the node's malus is the mob's malus for its type; it is rejected when the malus is negative, otherwise `costMalus = max(existing, malus)` and a node of type WALKABLE costs an extra `+1`. *Types*: `getPathType` = the block's state type with FIRE, LAVA, DAMAGING and COCOA kept, fences accepted only at the mob's own position (as WALKABLE), water as OPEN, anything else as OPEN or WALKABLE (a solid floor below a free block is WALKABLE).

**AmphibiousNodeEvaluator(prefersShallowSwimming)** (frog, axolotl, turtle, drowned and the other land-and-water mobs): extends the walk evaluator. `prepare` saves the mob's malus for WALKABLE and WATER_BORDER and sets WATER to **0**, WALKABLE to **6**, WATER_BORDER to **4**; `done` restores them. A position whose state is water is classified WATER, or WATER_BORDER if any of its six neighbours is BLOCKED. Neighbours: the walk neighbours, plus the node above (`UP`, with step height `max(1, step_height) - 1`) and the node below (`DOWN`); a vertical neighbour is accepted only if it is a valid neighbour **and its type is WATER** (the DOWN node is also accepted when its type is not TRAPDOOR). When `prefersShallowSwimming`, every resulting node of type WATER whose y is **below `seaLevel - 10`** gets `costMalus + 1` (so shallower water is preferred).

### 5.4 Navigation classes

All extend `PathNavigation` (mob, level). Common state: `path`, `speedModifier`, `tick` counter, stuck detection state, `maxVisitedNodesMultiplier`, `requiredPathLength`, `hasDelayedRecomputation`, `timeLastRecompute`.

| Class | Evaluator | `canUpdatePath` | Notes |
|---|---|---|---|
| `GroundPathNavigation` | Walk | on ground, or in liquid, or passenger | `trimPath`: trims the path at the first node under open sky when avoiding sun (`avoidSun`); targets below the surface allowed (`setCanPathToTargetsBelowSurface`); `canNavigateGround` true; `createPath(pos)` adjusts a target in air down to the surface and a target in a block up to the first air (`findSurfacePosition`) |
| `WaterBoundPathNavigation` | Swim (dolphin: allow breaching) | in a liquid | `canMoveDirectly`: a collider ray test between the two points raised by half the mob's height (`isClearForMovementBetween`, fluids ignored); `isStableDestination`: the block at the position is not a solid render block; `getMaxVerticalDistanceToWaypoint` 0.5; `canNavigateGround` false |
| `FlyingPathNavigation` | Fly | not in liquid and not a passenger | `canMoveDirectly`: the same ray test counting fluids as hits (`Fluid.ANY`); `isStableDestination`: the block below `entityCanStandOn`; its `tick` advances nodes by block-position proximity (see 5.5) |
| `AmphibiousPathNavigation` | Amphibious | always | `canMoveDirectly`: the ray test only when the mob is in a liquid, **false** when it is not (the fluid flag for the amphibious test was not captured); `isStableDestination`: the block below is not air; `canNavigateGround` true |
| `WallClimberNavigation` | Walk | ground rules | wraps path creation so a spider's target is the block position; `moveTo(entity, speed)` remembers the entity; `tick` re-paths toward the remembered target when the mob has not got a path and, while a target entity is set, drives the MoveControl directly toward it when within the mob's width |

`setCanFloat(b)` sets the evaluator's `canFloat` (FloatGoal sets true). `setCanOpenDoors`. `setSpeedModifier(s)`. `getMaxDistanceToWaypoint` defaults to 0.5 (used for the single-node case; see 5.5), `getMaxVerticalDistanceToWaypoint` is 1.0.

### 5.5 Following a path

`PathNavigation.moveTo(x, y, z, speed)`: `createPath(BlockPos.containing(x, y, z), 0)` (reach 0) then `moveTo(path, speed)`; `moveTo(entity, speed)`: `createPath(entity, 1)` (reach 1) then `moveTo(path, speed)`. `moveTo(path, speed)`: null path -> clears and returns false; if the new path is the same as the current (`sameAs`) keep it; if the node count is 0 return false; else `onPathfindingStart`-style setup, `trimPath()`, store `speedModifier`, set the current position as the stuck reference (`lastStuckCheck = tick`, position), return true. `recomputePath()`: when the target position is known, recompute at most once per 20 game ticks (`gameTime - timeLastRecompute > 20`; otherwise a delayed recomputation is flagged). `stop()` clears the path.

**`PathNavigation.tick`** (every tick, from `serverAiStep`), read:
1. `tick += 1`; if a recomputation is pending, do it.
2. If the path is not done and `canUpdatePath()`: `followThePath()`. (If the path is done, nothing.)
3. If the path is not done: `nextPos = path.getNextEntityPos(mob)`; ask the move control to go there: `moveControl.setWantedPosition(nextPos.x, groundY(nextPos), nextPos.z, speedModifier)` where `groundY` = the floor level of that block (`getGroundY`: if the block below is air then the position's y else `WalkNodeEvaluator.getFloorLevel`) for ground navigation, and the node's y for fly/swim.
4. `doStuckDetection` (below) runs inside `followThePath`/tick.

`Path.getNextEntityPos(entity)` = the next node's block x + `(floor(bbWidth + 1) x 0.5)` and likewise z, y = the node's y (`getEntityPosAtNode`: `x + (int)(bbWidth + 1) x 0.5`). So a wide mob aims at the centre of its footprint.

**`followThePath`** (ground; read): `maxDistanceToWaypoint = bbWidth > 0.75 ? bbWidth / 2 : 0.75 - bbWidth / 2`. The mob has **reached** the next node when `|mob.x - (node.x + 0.5)| < maxDistanceToWaypoint`, `|mob.z - (node.z + 0.5)| < maxDistanceToWaypoint` and `|mob.y - node.y| < maxVerticalDistanceToWaypoint` (1.0). When reached, the path advances one node. When not reached, the path still advances if **both** hold: `canCutCorner(next node's path type)` (5.3), and the shortcut rule `shouldTargetNextNodeInDirection(mobPos)`:
- false if the next node is the last node;
- false unless the mob is within 2.0 blocks of the next node's bottom centre;
- true if `canMoveDirectly(mobPos, nextEntityPos)` (`GroundPathNavigation` and the base class return false, so this never applies to walkers; the water, flying and amphibious navigations use ray tests, 5.4);
- otherwise let `A` = the vector from the mob to the **bottom centre of the next node** and `B` = the vector from the mob to the bottom centre of the node **after** the next; if `|B|^2 < |A|^2` or `|A|^2 < 0.5` then the result is `dot(normalize(B), normalize(A)) < 0`; else false.
`doStuckDetection(mobPos)` runs after this on every call.

**Flying** (`FlyingPathNavigation.tick`): `tick += 1`; if the path is not done: the mob has reached the next node when its block position equals the node's block position (floor x, y, z of the mob); then `advance()`; then the move control targets `getNextEntityPos`.

**Stuck detection** (`doStuckDetection(mobPos)`, read):
- *Movement check*, every time more than 100 ticks have passed since the last check: let `f = speed` if `speed >= 1.0` else `speed x speed` (`speed` = the mob's float `getSpeed()`, set by MoveControl), `t = f x 100 x 0.25`; if the squared distance from the position at the last check to the current position is less than `t x t`, the navigation is flagged stuck and `stop()` is called (the path is dropped); otherwise the flag is cleared. The reference time and position are then reset.
- *Node timeout*, while a path is in progress (`doStuckDetection`, read): the navigation keeps `timeoutTimer`, `timeoutLimit`, `timeoutCachedNode` and `lastTimeoutCheck`. Each call: if the next node is the **same** as `timeoutCachedNode`, the ticks since `lastTimeoutCheck` are **added** to `timeoutTimer`; if it is a **new** node, the cached node and the limit are recomputed (`timeoutLimit = distance(mobPos, bottom centre of the node) / speed x 20` if `speed > 0`, else 0) and the timer is **not** reset by this code. The path times out (`timeoutPath`) when `timeoutLimit > 0` and `timeoutTimer > timeoutLimit x 3.0`; with speed 0 the limit is 0 and it never times out. `lastTimeoutCheck` is set to the current time. The timer, cached node and limit are cleared by `resetStuckTimeout`, which `createPath` calls after computing a new path and `timeoutPath` calls on timing out.

`shouldRecomputePath(target)`: true if the path is done or empty, or the target block is not within `(remaining nodes) / 2` blocks of the path's end node centre (`BlockPos.closerToCenterThan(endNode + 0.5-ish, nodesRemaining / 2.0)`): used by goals such as chasing a moving target to decide to re-path.

`isStableDestination(pos)`: ground navigation requires the block below to be a solid render block.

**Entity speed in navigation**: the navigation's `speedModifier` is passed to `MoveControl.setWantedPosition` (3.1), so a goal's speed argument is the multiplier of the mob's `movement_speed`.


---

## 6. Natural spawning

Sources: `ServerChunkCache.tickChunks`, `NaturalSpawner` (and `SpawnState`, `LocalMobCapCalculator`), `SpawnPlacements`, `SpawnPlacementTypes`, `MobCategory`, `Mob.checkSpawnRules`, `Monster`, `Animal`, `WaterAnimal`, the dimension type data, and the biome data.

### 6.1 The spawn cycle (per server tick, per dimension)

`ServerChunkCache.tickChunks` (read), every tick:

1. `spawnableChunkCount` = the number of chunks counted for spawning (6.2). A `SpawnState` is created: for every entity in the level that is **not** persistence-required (`isPersistenceRequired` / `requiresCustomPersistence` mobs are skipped) and not MISC category: count per category globally (`mobCategoryCounts`), count per category in the entity's chunk for the **local** cap (6.3), and add the entity's **spawn cost charge** (6.7) to the potential-energy field at its position.
2. If the game rule `spawn_mobs` is true, the **category list** is computed by `getFilteredSpawningCategories(state, spawnFriendlies, spawnEnemies)` with `spawnFriendlies = (gameTime mod 400 == 0)` (so the friendly cycle runs once every 400 ticks) and `spawnEnemies` = the level's flag `spawnEnemies`, which the server sets (`MinecraftServer.updateMobSpawningFlags` -> `ServerLevel.setSpawnSettings`) to `spawn_mobs && spawn_monsters` (both game rules; the difficulty does not enter here, Peaceful is handled by `checkSpawnRules` and `checkDespawn`). A category from the spawning categories (all except MISC, in the table order of 1.2) is included if **both**: (`spawnEnemies` or the category is friendly) and (`spawnFriendlies` or the category is not persistent); and its **global cap** holds (6.3). In effect MONSTER (when enabled), AMBIENT, AXOLOTLS, UNDERGROUND_WATER_CREATURE, WATER_CREATURE and WATER_AMBIENT are tried on every tick and CREATURE only on ticks where `gameTime mod 400 == 0`. (The method also reads the `random_tick_speed` game rule, which is used for block random ticks, not for category selection.) If `spawn_mobs` is false the list is empty.
3. The **spawn candidate chunks** (6.2) that have a ticking holder are shuffled (random order each tick) and for each such chunk `tickSpawningChunk(chunk, categories, state)`: increment the chunk's inhabited time; tick thunder (lightning) if in entity-ticking range; if the category list is empty return; if the chunk may spawn entities (`canSpawnEntitiesInChunk`: the chunk is within the world border and an entity-ticking chunk) then `NaturalSpawner.spawnForChunk`.
4. Block random ticks in ticking chunks, then custom spawners (`tickCustomSpawners`: phantoms, patrols, wandering trader, cats-in-village, and the others; these are specified in the per-mob catalogues) when the level's spawn setting allows.

`spawnForChunk(level, chunk, state, categories)`: for each category in the list (in order): if the **local cap** allows it for this chunk (6.3), call `spawnCategoryForChunk`, which picks **one random position** in the chunk (6.4) and, if its y is at least `minY + 1`, calls `spawnCategoryForPosition` (6.5) with the predicates `state.canSpawn(type, pos, chunk)` (the spawn-cost check, 6.7) and a callback `state.afterSpawn(mob, chunk)` (updates the counters and the energy field). So each chunk gets, per tick, at most one attempted pack per eligible category.

### 6.2 Which chunks count, and the "17 x 17" rule

- A chunk is a **spawn candidate** if it is within the distance tracker of any non-spectator player: the tracker marks every chunk within **8 chunks** (Chebyshev distance, a 17 x 17 square of chunks = 289 chunks around the player) of a player (`getNaturalSpawnChunkCount` counts the distinct chunks marked; `getSpawnCandidateChunks` iterates them); the chunk must also have a ticking chunk holder.
- `hasPlayersNearby(chunk)` (used by `anyPlayerCloseEnoughForSpawning` and `getPlayersCloseForSpawning`): returns TRUE when the chunk is within `INSCRIBED_SQUARE_SPAWN_DISTANCE_CHUNK` = floor(8 / sqrt(2)) = **5** chunks (Chebyshev) of a player, FALSE when the tracker says the chunk is beyond 8, otherwise DEFAULT, which is computed directly: a non-spectator player counts when the **horizontal** squared distance from the player's `(x, z)` to the chunk centre `(minBlockX + 8, minBlockZ + 8)` is **strictly below 16384** (128 blocks); the y coordinate is not used (`playerIsCloseEnoughForSpawning`, read).
- Constant: `MAGIC_NUMBER = floor(17^2) = 289`.

### 6.3 Mob caps

- **Global cap** per category: a category may spawn while `currentCount(category) < max(category) x spawnableChunkCount / 289` (integer division; `max` from 1.2: 70 monsters, 10 creatures, 15 ambient, 5 each for axolotls / underground water / water creatures, 20 water ambient). With one player and the full 289 chunks loaded: monster cap 70, creature 10, ambient 15, water creature 5, water ambient 20, axolotl 5, underground 5. Counts are of existing non-persistent mobs of that category in the whole level (all chunks, including those far from players).
- **Local cap** (`LocalMobCapCalculator.canSpawn(category, chunk)`, read): the players "close for spawning" to the chunk (6.2, `getPlayersCloseForSpawning`) are collected (cached per chunk). Each player has per-category counters of the mobs in the chunks that are close to that player (when a mob is added, every player close to its chunk counts it; a player has counters only once a mob has been counted for them). The category may spawn in the chunk if **any** of those players has no counters yet or has a count for the category **below** `max(category)` (the same `max` as 1.2, not scaled by chunk count). It may **not** spawn when every close player is at or above the cap, and it may not spawn when **no** player is close to the chunk (the result is false for an empty list).

### 6.4 Choosing a position (`getRandomPosWithin`)

For the chunk with minimum block corner `(cx, cz)`: `x = cx + RS.nextInt(16)`, `z = cz + RS.nextInt(16)`; `top = chunk.getHeight(WORLD_SURFACE, x, z) + 1`; `y = Mth.randomBetweenInclusive(RS, minY, top)` (a uniform integer in `[minY, top]`, so most attempts are underground or in caves; sky positions are above the surface by at most 1). The returned block position is `(x, y, z)`; the attempt is skipped when `y < minY + 1`.

### 6.5 Spawning a pack at the position (`spawnCategoryForPosition`)

Inputs: the category, the chunk, the start position `P`, the spawn-cost predicate and the after-spawn callback. Counters: `spawned` counts the mobs created in this whole call, `spawnedInPack` counts those of the current pack.

1. If the block at `P` is a redstone conductor (a full solid block), nothing is spawned.
2. Up to **3 packs** are attempted. For each pack, the pack state starts empty (no chosen entry, no group data, `spawnedInPack = 0`), the horizontal cursor starts at `(P.x, P.z)` with the fixed `y = P.y`, and the pack's attempt limit is `maxPack = ceil(nextFloat() x 4)` (1 to 4). The pack makes attempts `i = 0, 1, ...` while `i < maxPack`; **each attempt, whatever its outcome, counts as one `i`**. One attempt does the following in order, and the attempt is **abandoned** (the pack continues with the next attempt) as soon as a rule fails:
   1. *Move the cursor*: `x += nextInt(6) - nextInt(6)`, `z += nextInt(6) - nextInt(6)` (each step in -5..5; the cursor accumulates over the pack, so a pack wanders). The candidate is `(x + 0.5, y, z + 0.5)`.
   2. *Player distance*: the nearest non-spectator player at any distance must exist, and the squared distance to it must be **above 576** (24 blocks), the candidate must not be within 24 blocks of the level's respawn position when that position is in this dimension, and the candidate's chunk must be the chunk being processed or a chunk that may spawn entities (`canSpawnEntitiesInChunk`) (`isRightDistanceToPlayerAndSpawnPoint`).
   3. *Choose the entry* (only when the pack has none yet): draw one from the weighted list of the category at the candidate (6.6; `getRandomSpawnMobAt`; for WATER_AMBIENT in a biome tagged `reduced_water_ambient_spawns`, `nextFloat() < 0.98` yields no entry). If there is no entry, the **whole pack ends** (it makes no further attempts). Otherwise the entry becomes the pack's entry and **`maxPack` is replaced by one sample of the entry's `count`** (the pack size from the biome data); later attempts of the same pack keep the entry and do not draw again.
   4. *Position validity for the type* (`isValidSpawnPostitionForType`): it returns false at once for category MISC; otherwise the entry must be valid for the candidate (`canSpawnMobAt`: the weighted list for the position contains it; the list comes from `mobsAt`, which uses the structure's own list inside a Nether fortress bounding box when the block below is nether bricks, and the structure spawn overrides of swamp huts, ocean monuments and pillager outposts); if the category is not MISC and the type cannot spawn far from the player (`canSpawnFarFromPlayer` false), the squared distance to the player must be **at most `despawnDistance^2`** (16384 for 128, 4096 for 64); the type must be summonable; `SpawnPlacements.isSpawnPositionOk` (6.9); `SpawnPlacements.checkSpawnRules(type, level, NATURAL, pos, RS)` (6.8, which includes the Peaceful gate); and the type's spawn box at the candidate must be free of collisions.
   5. *Spawn-cost check*: the predicate (6.7) must accept the type at the position.
   6. *Create*: `EntityType.create(level, NATURAL)`; if creation fails the **whole call ends** (a warning is logged). Place the mob at `(x + 0.5, y, z + 0.5)` with yaw `nextFloat() x 360` and pitch 0.
   7. *Mob validity* (`isValidPositionForMob`): reject when the squared distance to the player exceeds `despawnDistance^2` and the mob's `removeWhenFarAway(d)` is true; the mob's own `checkSpawnRules(level, NATURAL)` and `checkSpawnObstruction(level)` must hold (no colliding entity or block in its box, and by default no liquid).
   8. *Finalise and add*: `groupData = finalizeSpawn(level, difficultyAt(mob position), NATURAL, groupData)` (7.1; the group data object is shared by the pack so baby chance and group variants apply to the whole pack); `spawned += 1`, `spawnedInPack += 1`; `addFreshEntityWithPassengers(mob)` (the mob is now tracked, 9); the after-spawn callback updates counters and charges. Then: if `spawned >= mob.getMaxSpawnClusterSize()` (default **4**; mobs may override) the **whole call ends**; if `mob.isMaxGroupSizeReached(spawnedInPack)` (default `spawnedInPack >= getMaxSpawnClusterSize()`; mobs may override) the **pack ends**.
3. After the third pack the call returns.

### 6.6 Spawner data (`natural_mob_spawns`)

Biome spawn data is not a `spawners` field in this version: it is the environment attribute `minecraft:gameplay/natural_mob_spawns` under the biome's `attributes`, with the form `{ "argument": { "spawns_by_category": { "<category>": [ {type, weight, count} ... ] }, "spawn_costs": { "<entity id>": {energy_budget, charge} } }, "modifier": "overlay" }`. `count` is either an integer or `{ "type": "minecraft:uniform", "min_inclusive": a, "max_inclusive": b }` and is the **pack size** sampled in 6.5 step 5; `weight` is the integer weight of the weighted list (the probability of an entry is `weight / sum of weights in that category`). `modifier: overlay` means the biome's values are laid over the dimension's default; the dimension types in this artifact define **no** `natural_mob_spawns` attribute and its default value is **empty** (`MobSpawnSettings.EMPTY`), so a biome's list is exactly what its JSON says. A biome that lacks a category has no natural spawns of that category (e.g. a mushroom field has no monster entry in this data). Appendix A gives the data for every biome.
`gameplay/creature_world_gen_spawn_probability` (float, default **0.1**) is the chance per chunk generation that animals are spawned at world generation (6.10); a biome may override it (appendix A).
`gameplay/can_pillager_patrol_spawn` (default true), `gameplay/surface_slime_spawn_chance` (default 0, set by the moon timeline) are read by their own spawn logic (per-mob catalogues).

### 6.7 Spawn costs (the potential-energy field)

A biome's `spawn_costs` map (entity id -> `{energy_budget, charge}`) models crowding for the few mob types that use it. `PotentialCalculator` keeps a list of point charges `(position, charge)` per spawn state: each existing counted mob whose type has a cost adds its `charge` at its position (`addCharge`, skipped when the charge is 0). The **energy change** of a candidate charge `c` at position `p` is `c x (sum over existing charges q_i of q_i / sqrt(distanceSquared(p, position_i)))` (read: each point's `getPotentialChange` = `charge / sqrt(distSqr)`, infinite when the squared distance is 0; the sum is multiplied by `c`; the result is 0 when `c = 0`). A mob of a type with a cost entry may spawn only if the energy change of its `charge` at the position is **<=** its `energy_budget` (`SpawnState.canSpawn`); types without a cost always pass. `afterSpawn` adds the new mob's charge at its position. Appendix A lists the biomes that define costs (the `costs:` lines).

### 6.8 Light, difficulty gates and the per-type predicates

`SpawnPlacements.checkSpawnRules(type, level, reason, pos, RS)` (read): returns false if the difficulty is **Peaceful** and the type is not allowed in Peaceful (`notInPeaceful`); else the type's registered predicate `test(type, level, reason, pos, RS)`.

Generic predicates (read):

- `Mob.checkMobSpawnRules` ("any light"): `reason` is SPAWNER/TRIAL_SPAWNER (`isSpawner`), or the block below `isValidSpawn(level, pos.below(), type)`. (The default block predicate for `isValidSpawn` is read: the block's top face is sturdy and its light emission is below 14; individual blocks override it in block data, not tabulated here; a block tag `valid_spawn` lists grass block and podzol.)
- `Monster.checkMonsterSpawnRules`: `reason.ignoresLightRequirements()` (only TRIAL_SPAWNER) **or** `isDarkEnoughToSpawn(level, pos, RS)`; **and** `Mob.checkMobSpawnRules`. `isDarkEnoughToSpawn`: reject if `level.getBrightness(SKY, pos) > RS.nextInt(32)`; reject if the dimension's `monster_spawn_block_light_limit` is below 15 and `getBrightness(BLOCK, pos) > limit`; then `light = isThundering ? getMaxLocalRawBrightness(pos, 10) : getMaxLocalRawBrightness(pos)` (the combination of sky and block light, the sky part being reduced by the time of day, or by 10 while thundering); accept if `light <= dimension.monster_spawn_light_level.sample(RS)`.
  - Overworld: `monster_spawn_block_light_limit` 0, `monster_spawn_light_level` uniform 0..7 inclusive. Overworld caves: see the `overworld_caves` dimension type (same data class; values in the jar's dimension_type JSON). Nether: limit 15 (block light is not checked), light level 7. End: limit 0, light level 15.
- `Monster.checkAnyLightMonsterSpawnRules`: `Mob.checkMobSpawnRules` only (no light test): blaze, breeze, zoglin.
- `Monster.checkSurfaceMonstersSpawnRules`: `Monster.checkMonsterSpawnRules` and (`reason` is a spawner or the position can see the sky): husks, camel husks, parched.
- `Animal.checkAnimalSpawnRules`: `reason.ignoresLightRequirements()` or `isBrightEnoughToSpawn` (`getRawBrightness(pos, 0) > 8`), **and** the block below is in tag `animals_spawnable_on` (**grass_block** only). Cow, chicken, pig, sheep, horse, donkey, mule, llama, trader llama, cat, panda, happy ghast use this.
- `WaterAnimal.checkSurfaceWaterAnimalSpawnRules`: `seaLevel - 13 <= y <= seaLevel` (inclusive at both ends), the fluid at the block below is water, and the block above is water (`Blocks.WATER`).
- `Mob.checkSpawnObstruction` default: no liquid inside and `isUnobstructed` (no colliding blocks or entities in the box).

Per-type predicate map (`SpawnPlacements` registrations: type, placement type, heightmap, predicate). The placement type (6.9) and heightmap are shown per type:

| type | placement | heightmap | predicate |
|---|---|---|---|
| axolotl | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `Axolotl.checkAxolotlSpawnRules` |
| cod | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `WaterAnimal.checkSurfaceWaterAnimalSpawnRules` |
| dolphin | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `AgeableWaterCreature.checkSurfaceAgeableWaterCreatureSpawnRules` |
| drowned | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `Drowned.checkDrownedSpawnRules` |
| guardian | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `Guardian.checkGuardianSpawnRules` |
| pufferfish | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `WaterAnimal.checkSurfaceWaterAnimalSpawnRules` |
| salmon | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `WaterAnimal.checkSurfaceWaterAnimalSpawnRules` |
| squid | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `AgeableWaterCreature.checkSurfaceAgeableWaterCreatureSpawnRules` |
| tropical_fish | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `TropicalFish.checkTropicalFishSpawnRules` |
| armadillo | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Armadillo.checkArmadilloSpawnRules` |
| bat | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Bat.checkBatSpawnRules` |
| blaze | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkAnyLightMonsterSpawnRules` |
| bogged | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| breeze | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkAnyLightMonsterSpawnRules` |
| camel | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Camel.checkCamelSpawnRules` |
| camel_husk | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkSurfaceMonstersSpawnRules` |
| cave_spider | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| chicken | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| cow | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| creeper | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| donkey | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| enderman | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| endermite | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Endermite.checkEndermiteSpawnRules` |
| ender_dragon | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Mob.checkMobSpawnRules` |
| frog | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Frog.checkFrogSpawnRules` |
| ghast | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Ghast.checkGhastSpawnRules` |
| happy_ghast | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| giant | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| glow_squid | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `GlowSquid.checkGlowSquidSpawnRules` |
| goat | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Goat.checkGoatSpawnRules` |
| horse | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| husk | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkSurfaceMonstersSpawnRules` |
| iron_golem | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Mob.checkMobSpawnRules` |
| llama | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| magma_cube | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `MagmaCube.checkMagmaCubeSpawnRules` |
| sulfur_cube | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `SulfurCube.checkSulfurCubeSpawnRules` |
| mooshroom | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `MushroomCow.checkMushroomSpawnRules` |
| mule | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| nautilus | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `AbstractNautilus.checkNautilusSpawnRules` |
| ocelot | ON_GROUND | MOTION_BLOCKING | `Ocelot.checkOcelotSpawnRules` |
| parrot | ON_GROUND | MOTION_BLOCKING | `Parrot.checkParrotSpawnRules` |
| pig | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| hoglin | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Hoglin.checkHoglinSpawnRules` |
| piglin | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Piglin.checkPiglinSpawnRules` |
| pillager | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `PatrollingMonster.checkPatrollingMonsterSpawnRules` |
| polar_bear | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `PolarBear.checkPolarBearSpawnRules` |
| rabbit | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Rabbit.checkRabbitSpawnRules` |
| sheep | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| silverfish | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Silverfish.checkSilverfishSpawnRules` |
| skeleton | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| skeleton_horse | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `SkeletonHorse.checkSkeletonHorseSpawnRules` |
| slime | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Slime.checkSlimeSpawnRules` |
| snow_golem | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Mob.checkMobSpawnRules` |
| spider | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| stray | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Stray.checkStraySpawnRules` |
| parched | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkSurfaceMonstersSpawnRules` |
| strider | IN_LAVA | MOTION_BLOCKING_NO_LEAVES | `Strider.checkStriderSpawnRules` |
| turtle | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Turtle.checkTurtleSpawnRules` |
| villager | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Mob.checkMobSpawnRules` |
| witch | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| wither | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| wither_skeleton | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| wolf | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Wolf.checkWolfSpawnRules` |
| zoglin | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkAnyLightMonsterSpawnRules` |
| creaking | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| zombie | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| zombie_horse | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| zombified_piglin | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `ZombifiedPiglin.checkZombifiedPiglinSpawnRules` |
| zombie_villager | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| cat | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| elder_guardian | IN_WATER | MOTION_BLOCKING_NO_LEAVES | `Guardian.checkGuardianSpawnRules` |
| evoker | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| fox | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Fox.checkFoxSpawnRules` |
| illusioner | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| panda | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| phantom | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Mob.checkMobSpawnRules` |
| ravager | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| shulker | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Mob.checkMobSpawnRules` |
| trader_llama | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Animal.checkAnimalSpawnRules` |
| vex | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| vindicator | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |
| wandering_trader | ON_GROUND | MOTION_BLOCKING_NO_LEAVES | `Mob.checkMobSpawnRules` |
| warden | NO_RESTRICTIONS | MOTION_BLOCKING_NO_LEAVES | `Monster.checkMonsterSpawnRules` |

The mob-specific predicate bodies (frog, wolf, slime, fox, and so on) are catalogued with their mobs in 19, 20 and 21; the generic ones are above. The `animals_spawnable_on` tag and the per-species tags (`rabbits_spawnable_on`, `wolves_spawnable_on`, `foxes_spawnable_on`, `bats_spawnable_on`, `mooshrooms_spawnable_on`, `parrots_spawnable_on`, `goats_spawnable_on`, `frogs_spawnable_on`, `axolotls_spawnable_on`, `camels_spawnable_on`, `armadillo_spawnable_on`, `polar_bears_spawnable_on_alternate`) are in the jar's block tag data (the synchronised tags, 04).

### 6.9 Placement types (`SpawnPlacementTypes`)

`SpawnPlacements.isSpawnPositionOk(type, level, pos)` delegates to the type's placement type:
- **ON_GROUND**: the position is inside the world border; the block below `isValidSpawn(level, pos.below(), type)`; and the block at `pos` and the block at `pos.above()` are each a **valid empty spawn block** for the type (`NaturalSpawner.isValidEmptySpawnBlock`: the block's collision shape is not a full block, it is not a redstone signal source, its fluid state is empty, it is not in tag `prevent_mob_spawning_inside` (rails), and it is not dangerous for the type (`isBlockDangerous`: fire and lava for non-fire-immune types)). The adjusted spawn position (used when spawning from structure or chunk generation) is `pos` moved down by one if the block below is pathfindable by land.
- **IN_WATER**: inside the border; the fluid at `pos` is water and the block above `pos` is **not** a redstone conductor.
- **IN_LAVA**: inside the border; the fluid at `pos` is lava.
- **NO_RESTRICTIONS**: unconditionally true (no border check). ON_GROUND, IN_WATER and IN_LAVA each check the world border.
The default placement for a type without a registration is NO_RESTRICTIONS.

### 6.10 Chunk-generation spawns

`NaturalSpawner.spawnMobsForChunkGeneration` (read) runs when a chunk is generated, only if the game rule `spawn_mobs` is true and the biome's CREATURE spawn list is not empty. Let `p` = the biome's `creature_world_gen_spawn_probability` (default 0.1) and `(minX, minZ)` the chunk's block corner. **While `nextFloat() < p`** (the check repeats after each group): pick a weighted entry from the list (if none, check again); `count` = the entry's pack size sample; pick the start `x = minX + nextInt(16)`, `z = minZ + nextInt(16)`; for each of the `count` members make up to **4** attempts, stopping at the first success. An attempt: find the top non-colliding position of the type at `(x, z)` (`getTopNonCollidingPos`, using the type's heightmap and placement type); require `canSummon` and `SpawnPlacements.isSpawnPositionOk`; clamp the spawn x and z into the chunk's 16 x 16 block region shrunk by the entity width on each side; require the spawn box to be collision free and `SpawnPlacements.checkSpawnRules(..., CHUNK_GENERATION, ...)`; create the mob (reason NATURAL), give it a random yaw `nextFloat() x 360`; require its own `checkSpawnRules(CHUNK_GENERATION)` and `checkSpawnObstruction`; `finalizeSpawn` (reason CHUNK_GENERATION); add it. After each attempt `x` and `z` move by `nextInt(5) - nextInt(5)` each; if the new position is outside the chunk's 16 x 16 region it is replaced by a fresh random position inside the chunk. Animals made this way never despawn (6.11).

### 6.11 Persistence and despawn

- A mob is **persistent** (never despawns) when `isPersistenceRequired()` (`setPersistenceRequired()` and the mob's own save flag) or `requiresCustomPersistence()` (`Mob` returns false; subclasses override). What sets persistence for a given mob (name tag, leash, taming, trading, pickups) is per mob and is in the per-mob catalogues.
- `Animal.removeWhenFarAway` returns **false**, so animals never despawn by distance; `Mob.removeWhenFarAway` returns **true**.
- `Entity.checkDespawn` is called from the per-entity tick consumer in `ServerLevel` for **every** entity that is not removed and not frozen by the tick-rate manager, **before** the check that skips entities outside the entity-ticking range (so mobs far from players are still despawn-checked each tick). For a `Mob` (`Mob.checkDespawn`), in order (read):
  1. If the difficulty is Peaceful and the type is not allowed in Peaceful: discard.
  2. `persistent = isPersistenceRequired() || requiresCustomPersistence()`.
  3. Find the nearest player at any distance; if there is none, do nothing more.
  4. `d` = the squared distance to that player.
  5. **Instant despawn**: `despawn` = the category's despawn distance (1.2: 128, or 64 for WATER_AMBIENT); if not persistent and `d > despawn^2` and `removeWhenFarAway(d)`: discard.
  6. **Random despawn**: `noDespawn` = 32; if not persistent and `noActionTime > 600` and `nextInt(800) == 0` and `d > 32^2` and `removeWhenFarAway(d)`: discard.
  7. Otherwise, if `d < 32^2`: `noActionTime = 0`.
  `noActionTime` increments once per `serverAiStep` (2.7) and is reset to 0 by damage (7.3 step 4) and by rule 7.
- **Item entities** (`ItemEntity`, read): lifetime constant `LIFETIME` = **6000** ticks; default pickup delay 10 ticks (`setDefaultPickUpDelay`); the pickup delay and lifetime special values 32767 (infinite pickup delay) and -32768 (infinite lifetime) exist; items merge with nearby items (box inflated by 0.5 horizontally) of the same stack type while below the maximum stack size. Experience orbs: 7.5. (The stand-in item rules are in `docs/design/standin-content.md` section 9.)

### 6.12 Spawn eggs, spawner blocks and trial spawners

- **Spawn egg** (`SpawnEggItem`, read): using it on a block: if the block is a spawner (and the player is allowed: `isSpawnerBlockEnabled`, and operator rights for entity data) the spawner's entity data and id are set instead; otherwise the entity type is spawned at the block (offset by the clicked face when the block has a collision shape) with reason `SPAWN_ITEM_USE` through `EntityType.spawn` (which runs `finalizeSpawn`), the item is consumed (not in creative) and the `entity_place` game event fires. Using it on a water source block (`use`) spawns at the hit block the same way. Using it on an existing mob of an ageable type (`spawnOffspringFromSpawnEgg`) creates a **baby** (`getBreedOffspring`, `setBaby(true)`, reason `SPAWN_ITEM_USE`) at the target's position. No spawn caps, light checks or placement predicates are applied.
- **Mob spawner block** (`BaseSpawner.serverTick`, read). Defaults: `spawnDelay` 20, `minSpawnDelay` 200, `maxSpawnDelay` 800, `spawnCount` 4, `maxNearbyEntities` 6, `requiredPlayerRange` 16, `spawnRange` 4. Each server tick: do nothing unless a player is within `requiredPlayerRange` of the block centre (`+0.5` on each axis) and the spawner block is enabled in the game. If `spawnDelay` is -1, roll a delay (below). Else if `spawnDelay > 0`, decrement it and stop. Otherwise make `spawnCount` attempts with the current spawn data (`getOrCreateNextSpawnData`); an attempt:
  1. Read the entity type from the spawn data's entity NBT; if it has none, roll a delay and stop. The spawn position is the NBT `Pos` if present, otherwise `(blockX + (nextDouble - nextDouble) x spawnRange + 0.5, blockY + nextInt(3) - 1, blockZ + (nextDouble - nextDouble) x spawnRange + 0.5)`.
  2. The type's spawn box at that position must be collision free (else this attempt fails).
  3. If the spawn data has **custom spawn rules**: when the type's category is not friendly and the difficulty is Peaceful, the attempt fails; otherwise the rules' `isValidPosition` (block light and sky light ranges at the position) must hold. If there are no custom rules: `SpawnPlacements.checkSpawnRules(type, level, SPAWNER, pos, RS)` must hold (so placement, the Peaceful gate and the type's predicate apply; light matters for monsters because only the trial spawner reason ignores light).
  4. Load the entity from the NBT at the position (`EntityType.loadEntityRecursive`); if that fails, roll a delay and stop.
  5. Count the entities of exactly that class in the box from `(blockX, blockY, blockZ)` to `(blockX + 1, blockY + 1, blockZ + 1)` inflated by `spawnRange` on every axis, excluding spectators; if the count is `>= maxNearbyEntities`, roll a delay and stop.
  6. Set a random yaw (`nextFloat() x 360`), pitch 0. For a `Mob`: without custom rules, its own `checkSpawnRules(SPAWNER)` must hold; `checkSpawnObstruction` must hold; if the spawn data's entity NBT is only an `id` (size 1) the mob is finalised (`finalizeSpawn`, reason SPAWNER, no group data); the spawn data's equipment table, if any, is applied.
  7. Add the entity with its passengers (if that fails, roll a delay and stop); play level event **2004** (smoke and flames) at the block, fire the `entity_place` game event and, for a mob, its spawn animation; the attempt succeeds.
  After all attempts, if at least one succeeded, roll a delay. **Rolling a delay**: `spawnDelay = minSpawnDelay + nextInt(maxSpawnDelay - minSpawnDelay)` (just `minSpawnDelay` if the maximum is not larger) and the next spawn data is taken from the weighted potentials list.
- **Trial spawner**: uses the reason `TRIAL_SPAWNER` (ignores light requirements), has its own state machine (waiting for players, active, ejecting rewards, cooldown); its configuration is data-driven. The per-mob catalogues do not cover it; it is not specified here beyond the reason (Open question 4).


---

## 7. Damage, knockback, death, drops and experience

### 7.1 Finishing a spawn (`Mob.finalizeSpawn`) and equipment

`finalizeSpawn(level, difficultyInstance, reason, groupData)` (read) applies, for every mob regardless of reason:

1. The **follow-range spread**: if the mob has no `random_spawn_bonus` modifier on `follow_range`, add the permanent modifier `random_spawn_bonus`, operation ADD_MULTIPLIED_BASE, amount = triangle(0, 0.11485) = `RS.nextDouble() - RS.nextDouble()` scaled by 0.11485 (a triangular distribution with mode 0 and half-width 0.11485).
2. **Left-handedness**: `RS.nextFloat() < 0.05` -> mob flag left-handed (set via `setLeftHanded`; the flag is bit 2 of slot 15).
Subclass overrides call this first and then add their own rules: `AgeableMob.finalizeSpawn` (7.1.1), monster equipment (7.1.2) and per-mob variants (per-mob catalogues).

**7.1.1 Baby chance** (`AgeableMob.finalizeSpawn`): the group data object `AgeableMobGroupData` carries `babySpawnChance` (default 0.05, a mob may pass a different value), `shouldSpawnBaby` (default true), a group size counter. When called with an existing group data: if `groupSize > 0` (and spawning babies is enabled) and `RS.nextFloat() <= babySpawnChance` then `setAge(-24000)` (baby); the counter increments. The first member of a pack creates the group data (size counter 0) and so is never a baby from this rule; later members have a 5% chance each. A spawn egg or a breed creates babies by other means (`setBaby`).

**7.1.2 Monster default equipment** (`Mob.populateDefaultEquipmentSlots`, read in full). With `special = difficulty.getSpecialMultiplier()` (7.1.3):
1. If `nextFloat() < 0.15 x special`: the mob receives armor; otherwise nothing is added.
2. Armor tier `t = nextInt(3)` (0 to 2). Then exactly **three** independent rolls: each `nextFloat() < 0.1087` adds 1 to `t` (so `t` is 0 to 5; a failed roll does not stop the later rolls).
3. Per-slot chance `c` = 0.1 when the level difficulty is Hard, else 0.25. Go through the slots in `EQUIPMENT_POPULATION_ORDER`; the **first** slot in the order is always considered; for every later slot, if `nextFloat() < c` the loop **stops** (that slot and all later ones stay as they are). A considered slot that is empty receives `Mob.getEquipmentForSlot(slot, t)` when that is a non-null item (the table from tier to item is in `Mob.getEquipmentForSlot` and was not tabulated here, Open question 5).
Enchantments (`populateDefaultEquipmentEnchantments`, read): the main-hand item is considered with base chance **0.25** and each humanoid armor slot with base chance **0.5**; a non-empty slot is enchanted when `nextFloat() < base x special`, using the enchantment provider `mob_spawn_equipment` (`EnchantmentHelper.enchantItemFromProvider`, whose level and selection rules were not read).

**7.1.3 Local (regional) difficulty** (`DifficultyInstance`, read): inputs: the difficulty, the world's day time `T`, the chunk's `inhabitedTime` `I`, the moon-phase factor `M` (0 to 1, from the moon brightness; 1 at full moon):
- Peaceful: effective = 0.
- `a = clamp((T - 72000) / 1440000, 0, 1) x 0.25`; `b = clamp(I / 3600000, 0, 1) x (Hard ? 1.0 : 0.75)`; `b += clamp(M x 0.25, 0, a)`; if Easy: `b x= 0.5`; `base = 0.75 + a + b`; **effective = difficultyId x base** where id: Easy 1, Normal 2, Hard 3.
- `getSpecialMultiplier()`: 0 if effective < 2.0; 1.0 if effective >= 4.0; else `(effective - 2.0) / 2.0`.
- `isHard()`: the difficulty is Hard.
From the formula: the base factor ranges from 0.75 (day time 0, no inhabited time) to `0.75 + 0.25 + b`, with `b` up to 1.0 on Easy-halved/Normal (0.75 + 0.25) and 1.25 on Hard; so the effective difficulty ranges over Easy 0.75 to 1.5, Normal 1.5 to 4.0, Hard 2.25 to 6.75. The inhabited-time term saturates at 3 600 000 ticks of chunk inhabited time and the world-time term at day time 72000 + 1 440 000 ticks.

**7.1.4 Drop chances and equipment** (`DropChances`, read): the default drop chance of every equipment slot is **0.085** (`DEFAULT_EQUIPMENT_DROP_CHANCE`); a slot is **preserved** (always dropped intact, by the rule in 7.5) when its chance is **above 1.0** (`PRESERVE_ITEM_DROP_CHANCE_THRESHOLD`); the value `PRESERVE_ITEM_DROP_CHANCE` is 2 (used when a slot is set to "always drop", e.g. an item the mob picked up or a guaranteed spawn item).

### 7.2 Which items a mob wants (`wantsToPickUp`, `canReplaceCurrentItem`)

`canReplaceCurrentItem(candidate, current, slot)`: armor is compared by (armor value, toughness, then durability) `compareArmor`; weapons by the sum of attack damage attribute modifiers (plus a 1.0 bonus for being non-empty) `compareWeapons`; the replacement is allowed when strictly better; an empty slot always accepts a valid item (`canHoldItem`). The inner comparison functions (`compareArmor`, `compareWeapons`, `getApproximateAttributeWith`) were read only at the call level (Open question 5).

### 7.3 Damage (`LivingEntity.hurtServer(level, source, amount)`)

The player-side additions (PvP gating, difficulty scaling of the amount, the totem hand order main hand first, statistics and triggers) and the full armor, toughness and Breach arithmetic are in [17](17-tools-weapons-and-combat.md) section 4.4 (hurt flow), 4.5 (armor), 4.6 (knockback) and 4.7 (the hurt window); this section gives the mob-side flow and does not repeat them. A mob starts at step 1 with no difficulty scaling. Read order (`LivingEntity.hurtServer`):

1. `isInvulnerableTo(source)` -> false. Dead or dying -> false.
2. Source in tag `is_fire` and the entity has Fire Resistance -> false.
3. Wake a sleeping entity. `noActionTime = 0`. A negative amount becomes 0.
4. **Blocking** (`applyItemBlocking`, when using an item with `blocks_attacks`): the blocked amount is subtracted; `blocked` is true when the blocked amount was **greater than 0** (any blocking at all); the hit is **fully blocked** when `blocked` and the remaining amount is `<= 0`.
5. Freezing x5 (source in `is_freezing` and the type in `freeze_hurts_extra_types`); `damages_helmet` with a helmet: `hurtHelmet` and x0.75; NaN or infinite becomes 3.4028235E38. (This is after blocking.)
6. **Hurt window**: if `invulnerableTime > 10` and the source is not in `bypasses_cooldown`: if `amount <= lastHurt` return false; else `actuallyHurt(amount - lastHurt)`, `lastHurt = amount`, and the hit is **not fresh**. Otherwise the hit is **fresh**: `lastHurt = amount`, `invulnerableTime = 20`, `actuallyHurt(amount)`, `hurtDuration = hurtTime = 10`.
7. `resolveMobResponsibleForDamage`: a living causing entity, source not in `no_anger`, and not (`wind_charge` damage against a type in `no_anger_from_wind_charge`) -> `setLastHurtByMob`. `resolvePlayerResponsibleForDamage`: a Player cause, or the owner of a tamed Wolf cause, is recorded with `lastHurtByPlayerMemoryTime = 100`; a tamed wolf without an owner clears the record.
8. **Only on a fresh hit**: if blocked and the item has `blocks_attacks`, its `onBlocked` effects run, else `ServerLevel.broadcastDamageEvent` (Damage Event 05a 0x19); `markHurt` unless the source is in `no_impact` or (blocked and the remaining amount is 0); **default knockback** unless the source is in `no_knockback` or the hit was **fully blocked** (a partially blocked hit still knocks back): `dealDefaultKnockback` (7.4), whose `indicateDamage` runs only when the hit was **not blocked at all**.
9. If the entity is dead or dying (this check runs for fresh and non-fresh hits): `checkTotemDeathProtection(source)` (not for `bypasses_invulnerability`; a held item with `death_protection`, main hand first; one consumed, health 1.0, the component's effects, Entity Event 35); if no totem saved it, on a fresh hit the death sound and the secondary hurt sound play, then `die(source)` runs (also for a non-fresh hit); if still alive, on a fresh hit the hurt sound and the secondary hurt sound play. **No Damage Event, no `markHurt`, no knockback and no hurt or death sound occur for a non-fresh ("difference") hit.**
10. Inside the gate `!blocked || amount > 0`: remember `lastDamageSource` and `lastDamageStamp`, and run each active effect's `onMobHurt`. **Unconditionally** for a server player victim: the `ENTITY_HURT_PLAYER` trigger and, when `blocked` and the blocked amount is above 0 and below 3.4E37, the `damage_blocked_by_shield` statistic (`round(10 x blocked)`); and when the causing entity is a server player the `PLAYER_HURT_ENTITY` trigger. The method returns whether the gate held (damage accepted).

`actuallyHurt(amount)` (read call structure; arithmetic in 17): armor first (`getDamageAfterArmorAbsorb`: unless the source is in `bypasses_armor`, `hurtArmor(source, amount)` damages the armor pieces' durability, then `CombatRules.getDamageAfterAbsorb(damage, armor, toughness)` = with `f = 2 + toughness / 4`, `e = clamp(armor - damage / f, 0.2 x armor, 20)`, `q = e / 25`, an optional weapon Breach adjustment clamped to [0, 1], result `damage x (1 - q)`, 17 section 4.5); then `getDamageAfterMagicAbsorb` (unless in `bypasses_effects`: Resistance multiplies by `(25 - 5 x (amplifier + 1)) / 25`, floored at 0, unless in `bypasses_resistance`; then unless in `bypasses_enchantments` the protection points `P` (`EnchantmentHelper.getDamageProtection`) give `damage x (1 - clamp(P, 0, 20) / 25)`); absorption hearts are consumed first; then `health -= remaining`; the combat tracker records it and the `entity_damage` game event fires.

**Other damage sources** (each calls `hurtServer`): fall (3.2), drowning 2.0 (2.5), in-wall 1.0, on-fire 1.0 per 20 ticks, lava 4.0, freeze 1.0 (5.0 for the tagged types), cramming 6.0 (3.3), world border (2.5), fell-out-of-world 4.0 (2.5), cactus 1.0, magma block 1.0 (`hot_floor`, when the entity is not stepping carefully), sweet berry bush 1.0, and mob attacks.

`Mob.doHurtTarget(level, target)` (read): damage = the `attack_damage` attribute value with the held item's damage source and bonus (`Item.getAttackDamageBonus`) and enchantment damage modification (`EnchantmentHelper.modifyDamage`); `target.hurtServer` is called with the attacker's `mob_attack` source (or the item's own damage source); on success the item's `hurtEnemy` and `EnchantmentHelper.doPostAttackEffects` run.

### 7.4 Knockback

`dealDefaultKnockback(source, ...)` (read): the horizontal direction `(dx, dz)` from the victim to the source: if the source's direct entity is a `Projectile`, the direction is the **negated** `Projectile.calculateHorizontalHurtKnockbackDirection` result; else if the damage source has a source position, `(sourcePos.x - victim.x, sourcePos.z - victim.z)`; else `(0, 0)`. It then calls `knockback(strength = 0.4, dx, dz, ...)` (the constant 0.4 is read) and, if the hit was not blocked, `indicateDamage(dx, dz)` (the client tilt direction).

`LivingEntity.knockback(strength, dx, dz, ...)` (read): `strength = strength x (1 - knockback_resistance)`; if `strength <= 0` return; set `needsSync` (the velocity is sent); while `dx^2 + dz^2 < 9.999999747378752E-6` replace `dx` and `dz` each with `(nextDouble() - nextDouble()) x 0.01` (repeat until the squared length is large enough); `delta = normalize(dx, 0, dz) x strength`; with the current velocity `v`: new velocity `x = v.x / 2 - delta.x`, `z = v.z / 2 - delta.z`, `y = onGround ? min(0.4, v.y / 2 + strength) : v.y`. Because `(dx, dz)` points from the victim toward the source, subtracting `delta` moves the victim away from the source. Mobs that attack with `attack_knockback` and enchantments add extra knockback in `Mob.doHurtTarget` through the attack path; the base hit strength is the constant 0.4 above.

### 7.5 Death (`LivingEntity.die(source)`) and timing

On the server, once: log the death message (named entities), `Entity.killedEntity` for the killer (scores/stats), game event `entity_die`, broadcast Entity Event **3** (death: the client plays the death sound and starts the death animation), pose DYING (for the entities that use it), then `dropAllDeathLoot` (below). The entity stays in the world for `DEATH_DURATION` = **20 ticks** with `deathTime` counting from 0 and `isDeadOrDying` true (it ignores AI: `isImmobile`), tilting over on the client; at `deathTime >= 20` Entity Event **60** (poof) is broadcast and the entity is removed (2.9). While dying it cannot be hit (`hurtServer` returns false for dead entities).

`dropAllDeathLoot(level, source)` (read), in order:
1. `wasKilledByPlayer = lastHurtByPlayerMemoryTime > 0`.
2. If `shouldDropLoot()` (the game rule `mob_drops` allows; a `Mob` summoned without loot suppresses): `dropFromLootTable(level, source, wasKilledByPlayer)`: if the loot table is present: roll it (7.6) and spawn the item entities at the mob's position; then `dropCustomDeathLoot` (equipment drops, below).
3. `dropEquipment` (default no-op for most mobs; some drop extras).
4. `dropExperience(level, killer)`: **if** `shouldDropExperience()` (true for all but a few) and (the mob always drops experience, or `wasKilledByPlayer`/`lastHurtByPlayerMemoryTime > 0`) **and** the game rule `mob_drops` is on: `ExperienceOrb.award(level, position, xp)` where `xp = getExperienceReward(level, killer)` = the enchantment-processed (`processMobExperience`, looting-like effects) value of `getBaseExperienceReward`: for a `Mob`: `xpReward` (a per-type field set by the mob's constructor; values are per mob) plus, if `xpReward > 0`, for each equipment slot that can increase experience (`canIncreaseExperience`: armor and hand slots) holding a non-empty item whose slot drop chance is `<= 1.0`: `+ 1 + RS.nextInt(3)`. Animals and the breeding XP are in 8.1.
   `ExperienceOrb.award(level, pos, total)` (read): while `total > 0`: `v` = the largest value in the table `[2477, 1237, 617, 307, 149, 73, 37, 17, 7, 3, 1]` that is `<= total` (`getExperienceValue`); `total -= v`; first try to **merge into an existing orb**: a random `r = nextInt(40)` is drawn; an existing, non-removed orb inside a 1 x 1 x 1 box centred on the position qualifies if `(orb.id - r) mod 40 == 0` and its value equals `v`; if one qualifies the first one's `count` is incremented by 1 and its `age` reset to 0; otherwise a new orb of value `v` is spawned at the position. (The icon of an orb, chosen by value: 2477+ icon 10, 1237 9, 617 8, 307 7, 149 6, 73 5, 37 4, 17 3, 7 2, 3 1, else 0.)

   **The orb entity** (`ExperienceOrb`, read): type `experience_orb` (box 0.5 x 0.5, tracking 6 chunks, update interval 20); fields `value`, `count` (how many orbs of that value it represents, starts 1), `age`. *Spawn*: random yaw `nextFloat() x 360`; initial velocity `((nextDouble x 0.2 - 0.1) x 2, nextDouble x 0.2 x 2, (nextDouble x 0.2 - 0.1) x 2)`; if a direction is given the velocity is flipped (x -1) when it points against it, and the orb is offset by `normalize(velocity) x (bboxSize x 0.5)`; if it then collides with blocks it is nudged out (`unstuckIfPossible`). *Each tick*: gravity is the entity default **0.03** (applied unless the orb is inside blocks); in water (eye in water) `setUnderwaterMovement`: velocity x 0.99 on x and z and `y = min(y + 5.0E-4, 0.06)` instead of gravity; in lava the velocity is set to `((nextFloat - nextFloat) x 0.2, 0.2, (nextFloat - nextFloat) x 0.2)`; `tickCount mod 20 == 1`: **scan for merges** (`scanForMerges`: orbs within the box inflated by 0.5 that pass `canMerge`: not removed, `(id - thisId) mod 40 == 0`, same value; the other's `count` is added to this orb's, the smaller `age` is kept and the other is discarded); `followNearbyPlayer`; an orb stuck in blocks is pushed toward the closest free space; then `move`, block effects, drag: velocity x 0.98 (`getAirDrag`), times the friction of the block below when on the ground; if it landed with downward speed below -gravity, `vy = -oldVy x 0.4`; `age += 1`; at `age >= 6000` the orb is discarded. *Attraction* (`followNearbyPlayer`): the tracked player is dropped if spectating or farther than 8 blocks (squared 64); then the nearest non-spectator, non-dying player within **8.0** blocks is chosen; with a target: `delta = (player.x - x, player.y + eyeHeight / 2 - y, player.z - z)`, `f = 1 - sqrt(|delta|^2) / 8`, and the velocity becomes `velocity + normalize(delta) x (f x f) x 0.1` (so a closer orb accelerates more; the existing velocity is kept, `f` is 0 at 8 blocks and 1 at 0 blocks). *Pickup* (`playerTouch`, server player only): when the player's `takeXpDelay` is 0: set it to **2**; `take` the orb (pickup animation); repair items with Mending (`repairPlayerItems(player, value)`: pick a random equipped item with a `repair_with_xp` enchantment effect; `toRepair = modifyDurabilityToRepairFromXp(level, value)` (the enchantment effect scales the XP into durability); `repaired = min(toRepair, item damage)`; the item's damage is reduced by `repaired`; if `repaired > 0` the XP not used is `value - repaired x value / toRepair` and the process repeats on another item with that remainder; with no such item the whole value remains); any remaining XP is given to the player (`giveExperiencePoints`); then `count -= 1` and the orb is discarded at 0 (an orb with count n is picked up n times).

`dropCustomDeathLoot(level, source, killedByPlayer)` (read): for each equipment slot (hand, armor, body, saddle): `chance = dropChances.byEquipment(slot)`; skip if chance is 0; if the killer is a living entity the chance is modified by enchantments (looting-style `processEquipmentDropChance`); the item drops if: it is not empty, not tagged `prevent_equipment_drop`, and (`killedByPlayer` or the slot is preserved) and `RS.nextFloat() < chance`; if the slot is not preserved and the item is damageable the item's damage is randomised: `maxDamage - RS.nextInt(1 + RS.nextInt(max(maxDamage - 3, 1)))` (a damaged item); the item is spawned at the mob (`spawnAtLocation`) and the slot emptied. Preserved slots (drop chance above 1.0) drop intact.

### 7.6 Entity loot tables

Entity loot lives in `data/minecraft/loot_table/entities/*.json` (94 files in this artifact), registered under the loot table registry key `minecraft:entities/<name>`. The entity's table key defaults to `minecraft:entities/<entity name>` and a type with `noLootTable` (flag in 1.1) has none; `Mob` has the optional key `DeathLootTable` in NBT; a mob with a `loot_table` override uses it; the seed is `LootTableSeed` (0 = random).

**Table format** (the types that occur in entity tables; the generic loot system is the same as for blocks and chests):
- `{ "type": "minecraft:entity", "random_sequence": "minecraft:entities/<name>", "pools": [ ... ] }`. The `type` is the loot context param set (ENTITY: params `this_entity`, `origin`, `damage_source`, `attacking_entity` (optional), `direct_attacking_entity` (optional), `last_damage_player` (the player to credit, when `killed by player`), with the luck of that player).
- A **pool**: `rolls` (a number provider: constant or `{ "type": "minecraft:uniform", "min", "max" }`), optional `bonus_rolls`, optional `condition` (a single predicate, ANDed), optional `conditions`; `entries`: a list of entries. Each pool is rolled `rolls` times; each roll selects one entry by weighted choice among the entries whose conditions pass (entry `weight` default 1, `quality` x luck adjusts it).
- **Entry types** present: `minecraft:item` (`name`, `modifier` list, `condition`), `minecraft:empty`, `minecraft:tag` (`items` tag, `expand`: whether to choose one random member (true) or drop all), `minecraft:alternatives` (`children`: the first child whose conditions pass), `minecraft:loot_table` (a nested table by key or inline).
- **Functions** (`modifier`): `minecraft:set_count` (`count` number provider; the final count is clamped to >= 0), `minecraft:enchanted_count_increase` (`count` provider added **per level** of the named enchantment on the attacker's held item, `enchantment: minecraft:looting`, optional `limit`: so looting level L adds `L` rolls of the provider (e.g. uniform 0 to 1 per level)), `minecraft:furnace_smelt` (replaces the stack by its smelting result when the condition holds, e.g. the mob was on fire or the killer's weapon has a `smelts_loot` enchantment), `minecraft:set_potion`, `minecraft:set_ominous_bottle_amplifier` (with a uniform `amplifier`).
- **Conditions**: `minecraft:killed_by_player` (the `last_damage_player` param is present: i.e. `lastHurtByPlayerMemoryTime > 0`), `minecraft:random_chance` (`chance`), `minecraft:random_chance_with_enchanted_bonus` (`unenchanted_chance`, `enchanted_chance` as a linear `{ base, per_level_above_first }` over the enchantment level (looting), the chance is `base + per_level_above_first x (level - 1)` for level >= 1 else `unenchanted_chance`), `minecraft:entity_properties` (`entity`: `this`, `attacker`, `direct_attacker`, `attacking_player`; `predicate`: matching `minecraft:entity_type` (id or `#tag`), `minecraft:flags` (`is_on_fire`, `is_baby`...), `minecraft:equipment`, `minecraft:vehicle`, `minecraft:type_specific/*` (sheep, cube_mob size, raider captain...), `minecraft:components` (sheep colour, frog variant)), `minecraft:damage_source_properties` (`predicate` over `source_entity`, `direct_entity`, tags), `minecraft:inverted` (`term`), `minecraft:all_of` / `minecraft:any_of` (`terms`).
- **Number providers**: constants or `{ "type": "minecraft:uniform", "min": a, "max": b }` (inclusive for integers; real-valued for floats), `minecraft:linear`.
- Looting: the level of the `minecraft:looting` enchantment on the killer's weapon is read by the functions above; there is no global "looting bonus" apart from them.

Rolling: `LootTable.getRandomItems(params)` creates a loot context with the random source seeded from `random_sequence` plus the table seed and returns the list of item stacks; stacks over the item's max stack size are split. The stacks are spawned as item entities at the mob's position, each with the standard drop velocity and 10-tick pickup delay (item entity rules, standin-content §9).

Per-mob drop contents are in the per-mob catalogues, derived from the 94 files. Example (zombie): `rotten_flesh` with `set_count uniform(0,2)` and `enchanted_count_increase` looting `uniform(0,1)` per level, plus conditional extras.

### 7.7 Status events (`Entity Event`, 05a 0x22) used by mobs

The byte ids defined by `EntityEvent` (all handled client side in `handleEntityEvent`):

| id | name | id | name |
|---|---|---|---|
| 1 | jump (rabbit) | 2 | kinetic hit |
| 3 | death | 4 | start attacking |
| 5 | stop attacking | 6 | taming failed (smoke) |
| 7 | taming succeeded (hearts) | 8 | shake wetness (wolf) |
| 9 | use item complete | 10 | eat grass (sheep) |
| 11 | offer flower | 12 | love hearts (villager breed) |
| 13 | villager angry | 14 | villager happy |
| 15 | witch hat magic | 16 | zombie converting |
| 17 | fireworks explode | 18 | in love hearts (animal) |
| 19 | squid animation sync | 20 | silverfish merge anim |
| 21 | guardian attack sound | 31 | fishing rod reel in |
| 32 | armor stand wobble | 34 | stop offer flower |
| 35 | protected from death (totem) | 38 | dolphin looking for treasure |
| 39 | ravager stunned | 40 | trusting failed |
| 41 | trusting succeeded | 42 | villager sweat |
| 45 | fox eat | 46 | teleport (enderman-style particles) |
| 47-52, 65, 68 | break item in slot (main hand 47, off hand 48, head 49, chest 50, legs 51, feet 52, body 65, saddle 68) | 53 | honey slide |
| 54 | honey jump | 55 | swap hands |
| 56 | cancel shake wetness | 58 | start ram (goat) |
| 59 | end ram | 60 | poof (death removal) |
| 61 | tendrils shiver (warden/sculk) | 62 | sonic charge |
| 63 | sniffer digging sound | 64 | armadillo peek |
| 66 | shake | 67 | drown particles |
| 69 | ravager roared | 70 | TNT prime |
| 71 | boat sink | 72 | boat launch |

(Ids 22 to 28 are player-only: debug-info and permission levels. Which mob uses which event at which moment is in the per-mob catalogues; this table gives the meaning.) Hurt feedback is **not** status 2 in this version: it is Damage Event (05a 0x19) and Hurt Animation (05a 0x2B) (7.3 step 6).

---

## 8. Breeding, ageing, taming, leashing, riding

### 8.1 Love mode and breeding (`Animal`)

- State: `inLove` (a counter; 0 = not in love, set by `setInLove(player)` to **600** ticks and records the feeding player (an entity reference)); `getAge()` (from `AgeableMob`: negative for a baby, 0 or positive for an adult; an adult with a positive age is in **breeding cooldown**).
- Feeding (`Animal.mobInteract`, read): the player's held stack must satisfy `isFood(stack)`. **First** the love branch: if the interacting player is a `ServerPlayer`, the animal's `getAge() == 0` and `canFallInLove()`: `usePlayerItem` (consume one unless creative), `setInLove(player)` (600 ticks), Entity Event **18** (hearts) is broadcast when love starts, result SUCCESS. **Otherwise** the baby branch: if `canAgeUp()` (the mob is a baby): `usePlayerItem`, `ageUp(seconds)` with `seconds = (int)((remainingTicks / 20) x 0.1f)` where `remainingTicks` is `-age` (integer truncation, i.e. 10% of the remaining baby time in whole seconds), and `ageUp` adds `seconds x 20` to the age and clamps the age at 0; heart particles; result SUCCESS. On the client, when nothing was consumed, `mobInteract` returns CONSUME; otherwise the interaction falls through to `AgeableMob.mobInteract` (for example the golden dandelion rules, 8.2).
- Each tick (`Animal.aiStep`, read): if `getAge() != 0` then `inLove = 0`; if `inLove > 0`: decrement it and **every 10th tick** (`inLove mod 10 == 0`) spawn one heart particle burst with Gaussian offsets of standard deviation 0.02 for the velocity (server-side `sendParticles`, particle `heart`). The "in love" state itself is not a metadata slot **(inferred)**.
- `canMate(other)`: `other != this`, same class (`other.getClass() == this.getClass()` or the declared partner class), both `isInLove()`.
- `BreedGoal` (4.2) walks the two partners together and calls `breed()` after 60 ticks together within 3 blocks. `Animal.spawnChildFromBreeding(level, other)`: `child = getBreedOffspring(level, other)` (per-mob: pig -> pig, horse x donkey -> mule, variants/colour mixing in the per-mob doc); fire the `ageable` pre-checks; `child.setBaby(true)` (age -24000), position = the parent's position, rotation 0; `finalizeSpawnChildFromBreeding`: both parents `setAge(6000)` (**6000 ticks = 5 minutes breeding cooldown**; `PARENT_AGE_AFTER_BREEDING`), `resetLove()` (both), award the `animals_bred` stat and trigger to the player (`inLoveCause`), Entity Event **18** (hearts) on the first parent, spawn `1 + RS.nextInt(7)` experience orbs (1 to 7 xp, if `mob_drops`), `addFreshEntityWithPassengers(child)`.
- Gestation: none for these animals (instant); turtles, sniffers, frogs, armadillos, allays, and axolotls have their own egg/pregnancy mechanisms (per-mob catalogues, using `is_pregnant` memories etc.).
- **Ageing** (`AgeableMob`): a mob's age is stored as an int (`age`; baby when negative); `DATA_BABY_ID` (slot 16) holds the **is-baby** flag and `AGE_LOCKED` (slot 17) the lock. `setBaby(true)` sets age to `BABY_START_AGE` = **-24000**; `setBaby(false)` sets 0. Each server tick (`AgeableMob.aiStep`): if `age < 0`: `age += 1` (when it reaches 0 the mob grows up: `ageBoundaryReached` hook, e.g. boats/horses re-evaluating); if `age > 0`: `age -= 1` (cooldown), unless age-locked; `forcedAge` handling spawns happy-villager particles every 4 ticks for `forcedAgeTimer` ticks (40) after a forced age-up. A baby is 0.5 x the adult size (`scale` modification at the type level, per-mob) and its sounds/animation change client side.
- Baby growth boost: feeding a baby ages it up by 10% of the remaining time; a golden dandelion locks age (`setAgeLocked`, cooldown 40 ticks) on mobs not in `cannot_be_age_locked`.
- Persistence: a bred baby is persistent only if a parent is; `Animal` mobs do not despawn anyway (6.11).

### 8.2 Taming, ownership (`TamableAnimal`)

`TamableAnimal` adds: `isTame` (flag), `owner` (UUID, optional entity reference), `orderedToSit` and `inSittingPose`, in metadata slots 18 (flags BYTE; bit 1 = sitting pose, bit 4 = tame (`setTame`); `setInSittingPose` sets or clears bit 1 by masking with -2) and 19 (owner, OPTIONAL_LIVING_ENTITY_REFERENCE), read from the static initialiser order (`DATA_FLAGS_ID`, then `DATA_OWNERUUID_ID`). `shouldTryTeleportToOwner` is true when the squared distance to the owner is at least 144 (12 blocks); `unableToMoveToOwner` is true for a spectator owner (and the sitting or leashed cases of the subclass). `tame(player)` sets the tame flag and the owner and triggers the `tame_animal` advancement; per-mob code sets health. `spawnTamingParticles(success)` is driven by Entity Event **7** (success: heart particles) and **6** (failure: smoke), each emitting 7 particles with Gaussian offsets of standard deviation 0.02. The taming chance per feeding and the mob's response are per-mob (per-mob catalogues). A tame mob follows its owner (`FollowOwnerGoal`: start at 10, stop at 2 blocks for wolves/cats **(per-mob)**; teleports when 12+ blocks away), sits on command (`SitWhenOrderedToGoal`), defends the owner (`OwnerHurtByTargetGoal`, `OwnerHurtTargetGoal`) and is not alerted by `HurtByTargetGoal` against the same owner. Owned mobs do not despawn (persistence required).

### 8.3 Leashing

A leashable mob (`Leashable`) holds `LeashData` (the holder entity or fence knot, an `angularMomentum` double, and a delayed-restore record used when loading a save). Constants (read): `LEASH_TOO_FAR_DIST` (snap distance, `leashSnapDistance()`) **12.0**; `LEASH_ELASTIC_DIST` (`leashElasticDistance()`) **6.0**; `MAXIMUM_ALLOWED_LEASHED_DIST` **16.0** (a mob cannot be leashed to a holder farther than the snap distance: `canHaveALeashAttachedTo` is false for the holder itself, for a distance above `leashSnapDistance()`, or when `canBeLeashed()` is false); `STIFFNESS` **0.11**; `SPRING_DAMPENING` **0.7**; `TORSIONAL_ELASTICITY` **10.0**; `AXIS_SPECIFIC_ELASTICITY` the vector `(0.8, 0.2, 0.8)`. The distance used everywhere is between the centres of the two bounding boxes (`leashDistanceTo`).

`Leashable.tickLeash(level, entity)` runs from `Entity.baseTick` (2.5) on the server (read):
1. Restore a delayed leash from save data if pending; return if there is no holder.
2. If the mob or the holder cannot interact with the level (unloaded or removed): drop the lead (`dropLeash`, which spawns the lead item when the game rule `entity_drops` is on) or just remove it.
3. If the holder is in the same level: `distance = leashDistanceTo(holder)`; call `whenLeashedTo(holder)` (notifies the holder; `PathfinderMob.whenLeashedTo` sets the mob's home to the holder's block with radius 5); then:
   - if `distance > leashSnapDistance()` (12.0): play the lead-break sound at the mob and `leashTooFarBehaviour()` (default: `dropLeash`);
   - else if `distance > leashElasticDistance() - holder.bbWidth - mob.bbWidth` and `checkElasticInteractions(holder, data)` returns true: `onElasticLeashPull()` (resets the fall-distance accumulation); 
   - else `closeRangeLeashBehaviour(holder)` (default: nothing; `PathfinderMob`'s version: when `shouldStayCloseToLeashHolder()` and the mob is not panicking, the MOVE flag is enabled and, if the mob is further than 2 blocks from the holder, `nav.moveTo(mob.position + normalize(holder - mob) x max(distance - 2, 0), followLeashSpeed = 1.0)`).
   - then the mob's yaw is changed by `-angularMomentum` degrees and the momentum is damped: `angularMomentum x= angularFriction`, where angularFriction = ground block friction x 0.91 when on the ground, 0.8 in liquid, 0.91 otherwise.

**Elastic (spring) physics** (`checkElasticInteractions`, read). Attachment point constants: `ENTITY_ATTACHMENT_POINT` = `(0, 0.5, 0.5)`, `LEASHER_ATTACHMENT_POINT` = `(0, 0.5, 0)`; the quad-leash list `SHARED_QUAD_ATTACHMENT_POINTS` = `(-0.5, 0.5, 0.5)`, `(-0.5, 0.5, -0.5)`, `(0.5, 0.5, -0.5)`, `(0.5, 0.5, 0.5)` (a quad leash is used when the holder `supportQuadLeashAsHolder` and the mob `supportQuadLeash`, e.g. happy ghasts, and then the shared list serves as both entity and leasher points and the summed wrench is scaled by 0.25; otherwise the scale is 1). For each pair of points `(holderPoint, mobPoint)` (the i-th point of each list, each multiplied component-wise by the owner's `(bbWidth, bbHeight, bbWidth)`, rotated about y by minus its yaw and added to its position): `computeDampenedSpringInteraction(holderPoint, mobPoint, elasticDistance = 6.0)`: `d = distance`; no interaction if `d < 6.0`; else `force = normalize(holderPoint - mobPoint) x (d - 6.0)`; `torque = torqueFromForce(...)` (a cross-product-style component from the force and the lever arm); if `dot(...) >= 0` (the force is not opposing the mob's motion) the force is scaled by **0.3**; the pair gives a `Wrench(force, torque)`. If no wrench results the method returns false. Otherwise the wrenches are summed (`Wrench.accumulate`) and scaled, `angularMomentum += scaledWrench.torque x 10.0` (`TORSIONAL_ELASTICITY`), and the mob's velocity gets `addDeltaMovement(scaledWrench.force x (0.8, 0.2, 0.8) + (holderMovement - mobKnownMovement) x 0.11)`, where `holderMovement` is the holder's known movement (zero for a no-AI mob holder) and 0.11 (`STIFFNESS`) multiplies the **relative velocity**, not the force. `PathfinderMob.whenLeashedTo(holder)` sets the home to the holder's block with radius `(int)leashElasticDistance() - 1` = **5**.

Leash visual: Set Entity Link (05b) is sent when a player starts tracking the mob (9.1) and when the leash changes. Unleashing by the player and the lead item rules are per-mob / item rules.

### 8.4 Riding and passengers

`startRiding(vehicle)` makes the mob a passenger; `getControllingPassenger` decides who steers: a Mob under a Player controlling uses `travelRidden`; a vehicle with a mob passenger only keeps the passenger's goals if `updateControlFlags` allows (2.2). Dismount on water for types in `dismounts_underwater`. Passengers are synchronised with Set Passengers (05b); a passenger's position is not sent separately (`isPassenger` branch in `ServerEntity.sendChanges`, 9.2). Jockey spawns (chicken jockey, spider jockey, skeleton horse trap) are created by the owning mob's `finalizeSpawn` with reason JOCKEY; per-mob.

---

## 9. Server-side entity tracking and sending

Source: `ServerEntity`, `ChunkMap$TrackedEntity`. The wire formats are in 05a/05b; this section is the sending policy.

### 9.1 Who tracks what

A player tracks an entity (`ChunkMap$TrackedEntity.updatePlayer`, read) when all of: the entity is not the player itself; the **horizontal** squared distance (`dx^2 + dz^2`; y is not used) between the player and the entity is `<= range^2`, where `range = min(effectiveRange, playerViewDistance x 16)` in blocks; `Entity.broadcastToPlayer(player)` allows it; and the entity's chunk is currently tracked (sent) for that player. `effectiveRange` (`getEffectiveRange`): the maximum over the entity itself (its `range` field, `clientTrackingRange x 16`) and every **indirect passenger** of `clientTrackingRange x 16`, passed through `scaledRange`, which is `entity_broadcast_range_percentage x value / 100` on a dedicated server (the server property, default 100) and unchanged otherwise. When the entity becomes tracked by the player (the `seenBy` set gains the connection) the **pairing bundle** is sent (`addPairing` -> `sendPairingData`): Add Entity, then Set Entity Data (non-default values only, `getNonDefaultValues`), then Update Attributes (only the syncable attributes of living entities; skipped if none), then Set Equipment (all non-empty slots; skipped if none), then Set Passengers (if the entity has passengers, and again for the vehicle the entity rides), then Set Entity Link (if leashed), all wrapped in one bundle. When the player stops tracking: Remove Entities. Players always track themselves; self-directed copies of the data, attribute and velocity packets are sent to them.

### 9.2 Periodic updates (`ServerEntity.sendChanges`, each tick for each tracked entity)

In order (read):
1. If the passenger list differs from the last sent list, Set Passengers is sent to the trackers (this check opens the method); item frames holding maps update map data for players every 10th tick.
2. Dirty entity data: `sendDirtyEntityData` sends Set Entity Data with `packDirty()` (the changed slots only) to trackers **and the entity itself** (for players), then the dirty attributes (Update Attributes for the dirty syncable ones) likewise.
3. **When movement is processed**: the entity's interpolation tracker is updated (`updateTracking`); if `syncPosition` is set the tick counter is advanced by the update interval step (`UpdateInterval.nextInterval`) and the flag cleared. Movement, rotation and velocity are processed only when the entity needs a sync (`needsSync`), or its update interval is due (`UpdateInterval.test(tickCount)`, i.e. `tickCount` is a multiple of the type's interval, 1.1), or its metadata is dirty.
4. Compute the **packed rotation**: `yRot` and `xRot` are packed to one byte each (`packDegrees`, 256 steps per turn); `rotChanged` is true when either packed value differs from the last sent value by 1 or more.
5. A **passenger** (riding another entity): only a Move Entity Rot is sent, when `rotChanged`; the interpolation tracker is cleared, the position base is set to the current position, dirty data is flushed and `wasRiding` is set. A **minecart** with the new minecart behaviour uses a separate Move Minecart path (`handleMinecartPosRot`: sends the recorded interpolation steps when the speed or position changed, or every 60 ticks; not used by mobs).
6. Otherwise (a normal entity): `teleportDelay` increments; the interpolation tracker's **position path** (a linear or stepped path of the positions the entity passed since the last send) is taken and the tracker cleared; `createMovePacket(path, packedY, packedX, hasPositionChange, rotChanged)`:
   - A full **Entity Position Sync** (absolute position) is sent instead of a delta when any of: the entity requires precise position (`getRequiresPrecisePosition`); `teleportDelay > 400` (the counter resets to 0 on this path); the entity was riding on the previous send; or its on-ground flag differs from the last sent one.
   - Otherwise, if the position changed: the path's end position is encoded relative to the last sent base with `VecDeltaCodec.tryEncode` (each axis delta is `round(delta x 4096)` as a signed 16-bit value; `tryEncode` fails when an axis does not fit, i.e. the delta is about 8 blocks or more); on failure, or when `isFullPrecisionEncodingRequired` (only for **item entities**: when it collided vertically or horizontally and an axis of the delta would lose precision when quantised) an Entity Position Sync is sent; else a Move Entity Pos Rot (if `rotChanged`) or Move Entity Pos is sent.
   - Otherwise, if only rotation changed: Move Entity Rot. If nothing changed: no movement packet.
   - The decision to attempt a position delta: `hasPositionChange` is true when the squared length of the delta from the base to the entity position is `>= 7.62939453125E-6` (2^-17.0) or `tickCount mod 60 == 0`. **Arrows** (`AbstractArrow`) always attempt position and rotation.
   - On send, the position base is set to the sent position and the last sent rotation to the packed rotation.
7. **Velocity** (Set Entity Motion): when `needsSync` or `trackDelta` (the type's `trackDeltas`, false for `dontTrackDeltas`) or the entity is a fall-flying living entity: if the velocity differs from the last sent by a squared distance above 1.0E-7, or it is now exactly zero while the last sent was non-zero, the packet is sent to trackers and `lastSentMovement` updated (hurting projectiles also send a Projectile Power packet in a bundle). Entities with `syncVelocity` set (after knockback, explosions) send Set Entity Motion to the trackers **and the entity itself** once and clear the flag.
8. **Head rotation**: if the packed head yaw changed by at least 1 unit from the last sent, send Rotate Head (05b 0x55).
9. Clear `needsSync`; if the metadata was dirty but no movement was due, the dirty data is still flushed (`sendDirtyEntityData`); `tickCount` increments.

### 9.3 Metadata, attributes and equipment: when sent

- **Metadata** (Set Entity Data): the first pairing sends non-default values; afterwards any slot written with a different value marks the data dirty and the next `sendChanges` sends only the dirty slots. Health (slot 9) is a synced slot of every living entity, so health changes are sent automatically; the client derives the damage tilt from Damage Event, not from health.
- **Attributes** (Update Attributes): the pairing bundle sends all syncable attributes with their base value and modifier lists; afterwards, an attribute whose value or modifiers changed (`dirty`) is sent in the next `sendDirtyEntityData`. Non-syncable attributes (1.3: attack_damage, follow_range, knockback_resistance...) are never sent.
- **Equipment** (Set Equipment): the pairing bundle sends all non-empty slots; afterwards `detectEquipmentUpdates` (every tick, `LivingEntity.tick`) compares each slot with its last-seen stack and broadcasts Set Equipment with the changed slots (a copy of the stack) to trackers.
- **Passengers**, **leash link**: sent in pairing, and on change.

### 9.4 Sending the same data for a freshly spawned mob

`addFreshEntityWithPassengers` registers the entity; the chunk map's tracker immediately pairs every player in range, so the Add Entity bundle in 9.1 is sent in the same tick as the spawn. Subsequent changes follow 9.2 and 9.3.

---

## 10. Worked examples (for tests)

The random numbers below are chosen by hand to exercise the rules; they are not produced by any vanilla generator. A test fixture feeds the listed values to the implementation's random source in the stated order.

### 10.1 Goal arbitration

Fixture goals on one mob (priorities are illustrative, not a real mob): G1 `FloatGoal` flags {JUMP} priority 0; G2 `MeleeAttackGoal` flags {MOVE, LOOK} priority 2; G3 `WaterAvoidingRandomStrollGoal` flags {MOVE} priority 7; G4 `LookAtPlayerGoal` flags {LOOK} priority 8; G5 `RandomLookAroundGoal` flags {MOVE, LOOK} priority 9. Registration order G1..G5.

- Evaluation tick t (a tick where `(tickCount + id) mod 2 = 0`). Nothing running; no target; the mob is on dry ground. Update pass in registration order: G1 `canUse` false (not in fluid). G2 `canUse` false (no target). G3: flags {MOVE} are free; `canUse`: the stroll interval roll `RS.nextInt(reducedTickDelay(120) = 60)` returns 0 (fixture) and a position exists -> G3 starts and locks MOVE. G4: LOOK free, `canUse`: `RS.nextFloat() = 0.01 < 0.02` and a player is within 8 blocks -> starts, locks LOOK. G5: flags {MOVE, LOOK}: for MOVE the holder is G3 (priority 7), G5 priority 9: `canBeReplacedBy` requires `9 < 7`: false -> G5 cannot start (checked before `canUse`). Result: running = {G3, G4}.
- Tick t+2: the mob is hit and gets a target (set by a target goal in the target selector, which runs before the goal selector). Cleanup: G3 `canContinueToUse` true (path not done), G4 true. Update: G2 `canUse` now true (target alive; path to target exists): needs MOVE and LOOK. MOVE holder G3: interruptable and `2 < 7` -> replaceable; LOOK holder G4: `2 < 8` -> replaceable. G2 starts: `stop()` G3 (navigation stopped by G3's `stop`), `stop()` G4; locks MOVE and LOOK to G2. Running = {G2}.
- G2 `tick` runs every tick (it `requiresUpdateEveryTick`); on odd ticks only `tickRunningGoals(false)` ticks G2.
- If the player is in water in the next evaluation, G1 `canUse` is true (deeper than the jump threshold): G1 flags {JUMP}: no one holds JUMP -> it starts alongside G2.

### 10.2 A natural spawn attempt (monster category, Overworld, plains, night)

Setup: one player at block (200, 70, 0); Overworld (`minY = -64`), difficulty Normal, `spawn_mobs` true, `gameTime mod 400 != 0` (so CREATURE is excluded this tick), 289 chunks counted. The monster count is 12, below the global cap `70 x 289 / 289 = 70`, so MONSTER is in the category list. The chunk under test is chunk (12, 0) (block corner (192, 0)); the player is within 128 blocks of its centre, so it is a candidate; the player's local monster count 9 is below 70, so the local cap passes. Plains biome.

Draws, in order:
1. Position: `nextInt(16) = 5` -> x = 197; `nextInt(16) = 9` -> z = 9. Surface height at (197, 9) = 64, so `top = 65`. `randomBetweenInclusive(-64, 65)` = `nextInt(130) + (-64)`: the draw `nextInt(130) = 54` -> y = -10. `y >= minY + 1`: continue.
2. The block at (197, -10, 9) is air (a cave): not a redstone conductor -> continue.
3. Pack 1: `nextFloat() = 0.6` -> `ceil(0.6 x 4) = ceil(2.4) = 3` attempts. Attempt `i = 0`: jitter x: `nextInt(6) = 4`, `nextInt(6) = 1` -> +3 -> 200; z: `nextInt(6) = 0`, `nextInt(6) = 5` -> -5 -> 4. Candidate (200.5, -10, 4.5). Nearest player at (200, 70, 0): `d = 0.25 + 6400 + 20.25 = 6420.5 > 576` OK; the respawn point is elsewhere; same chunk -> OK.
4. `spawnData == null`: plains MONSTER list (appendix A): spider 100, zombie 90, zombie_villager 5, zombie_horse 5, skeleton 100, creeper 100, slime 100, enderman 10, witch 5; total 515. Weighted draw `nextInt(515) = 240`: cumulative bounds spider [0,100), zombie [100,190), zombie_villager [190,195), zombie_horse [195,200), skeleton [200,300) -> **skeleton**, count 4 -> `maxPack = 4`.
5. Validity: the skeleton `canSummon`; `canSpawnFarFromPlayer` false; `d = 6420.5 <= 128^2 = 16384` OK; placement ON_GROUND: block below (200, -11, 4) must be a valid spawn block (stone: top face sturdy, no emission) and the two blocks (200, -10, 4) and (200, -9, 4) valid empty (air); inside the border; predicate `Monster.checkMonsterSpawnRules`: sky light at that cave position is 0 so `0 > nextInt(32)` is false; block light limit 0: block light there 0 -> OK; `light = max local raw brightness = 0 <= monster_spawn_light_level.sample()` (uniform 0..7; fixture draw 3) OK; `checkMobSpawnRules` OK. The box is collision free.
6. The spawn cost check passes (no costs in plains). Create the skeleton at (200.5, -10, 4.5), yaw `nextFloat() x 360` with `nextFloat() = 0.25` -> 90 degrees, pitch 0. Final validity: `d <= 128^2` so no distance rejection; its `checkSpawnRules` and `checkSpawnObstruction` pass.
7. `finalizeSpawn` (7.1): follow_range modifier `random_spawn_bonus` (draws `0.7`, `0.3` -> `(0.7 - 0.3) x 0.11485 = +0.04594`), left-handed `nextFloat() = 0.5` -> no; skeleton equipment per 7.1.2 and the per-mob doc. Add the entity: pairing packets go to the player if within the skeleton's tracking range (`clientTrackingRange` 8 chunks = 128 blocks; the player is 80 blocks away: tracked) (9.1). `spawned = 1`, `spawnedInPack = 1`; the cluster limit 4 not reached.
8. Attempts `i = 1, 2, 3` continue the pack from the jittered position until 4 skeletons exist or the attempts run out (`maxPack = 4`, `i < 4`); each draws the jitter again but does **not** redraw the weighted entry (`spawnData` is already set). When `spawned` reaches `getMaxSpawnClusterSize()` = 4 (skeleton's default) the whole call returns; with `maxPack = 4` and one spawn per attempt this happens after attempt `i = 3`.
Expected result: 1 to 4 skeletons within a 5 block wander of (197, -10, 9); never within 24 blocks of the player.

Mob cap arithmetic: with 289 counted chunks the monster cap is `70 x 289 / 289 = 70`; with only 25 chunks counted (a view distance of 2) it is `70 x 25 / 289 = 6` (integer division of 1750 by 289).

### 10.3 A path on a grid

Open flat ground (all nodes WALKABLE, malus 0), a mob 0.6 wide, step height 0.6, start block (0, 64, 0), target block (3, 64, 0), `createPath(target, reach 0)`, `follow_range` 16 (so maxDistanceFromStart 16, node budget `16 x 16 = 256`).

- Pop start: `f = h = 3.0` (the start's `h` is the unweighted distance 3 to the target; only the neighbours below use the 1.5 weight). Neighbours: east (1,0) `g = 1`, `h = 1.5 x 2 = 3`, `f = 4.0`; north/south (0,+-1): `g = 1`, `h = 1.5 x sqrt(10) = 4.743`, `f = 5.743`; west (-1,0): `g = 1`, `h = 6`, `f = 7`; the four diagonals: east-north `(1, 1)`: `g = 1.4142`, `h = 1.5 x sqrt(5) = 3.354`, `f = 4.768` (diagonals are only produced when both adjacent cardinal neighbours are valid).
- Pop the lowest `f`: (1,0) `f = 4.0`. Its neighbours include (2,0): `g = 2`, `h = 1.5`, `f = 3.5`; diagonal (2,1): `g = 2.4142`, `h = 1.5 x 1.4142 = 2.121`, `f = 4.536`.
- Pop (2,0) `f = 3.5`: neighbour (3,0): `g = 3`, `h = 0`, `f = 3.0`.
- Pop (3,0): its Manhattan distance to the target is 0 <= reach 0: the target is reached; the loop ends. The path is the node list (0,0), (1,0), (2,0), (3,0) with `canReach = true`.
- Following: `maxDistanceToWaypoint = 0.75 - 0.6/2 = 0.45`; the mob (centre (0.5, 0.5)) first aims at node 0's centre; after it is within 0.45 of (0.5, 0.5) in x and z and within 1.0 in y, `advance()`; it then aims at (1.5, 64, 0.5) with MoveControl speed `movement_speed x speedModifier`; and so on; at the end `isDone` is true. The path nodes' x,z for a 0.6-wide mob: `getNextEntityPos` adds `(floor(0.6 + 1) x 0.5) = 0.5`.
- A blocked target: if the target is enclosed (all neighbours of the target BLOCKED) the search exhausts the open set or the node budget; no target is reached, so the best path is the one to the node with the smallest distance to the target (smallest `bestHeuristic`), with `canReach = false`; `moveTo` still follows it.
- Stuck: for `speed = 0.25`, `f = 0.0625`, `t = 1.5625`, so a mob whose squared displacement over the last 100 ticks is below 2.44 (about 1.56 blocks) has its path cancelled.

### 10.4 Damage, invulnerability and knockback numbers

- Armor (17 section 4.5): `damage 6`, `armor 10`, `toughness 0`: `f = 2 + 0/4 = 2`, `e = clamp(10 - 6/2, 0.2 x 10, 20) = 7`, `q = 7/25 = 0.28`, so the damage becomes `6 x (1 - 0.28) = 4.32`.
- Window: a first hit of 4.0 at tick 0 sets `invulnerableTime = 20` and `lastHurt = 4`, health -4. At tick 5 (`invulnerableTime = 15 > 10`) a hit of 6.0 applies only `6 - 4 = 2.0` and `lastHurt = 6`; a hit of 3.0 is ignored (not greater than `lastHurt`). At tick 11 (`invulnerableTime = 9`, not above 10) a hit of 1.0 is a fresh hit: applied in full, `invulnerableTime = 20`.
- Knockback: victim on the ground at rest, `knockback_resistance 0`, strength 0.4, the damage source's position 2 blocks toward negative z of the victim, so `(dx, dz) = (0, -2)` (source minus victim): `delta = normalize(0, -2) x 0.4 = (0, -0.4)`; new velocity `(0/2 - 0, min(0.4, 0/2 + 0.4) = 0.4, 0/2 - (-0.4) = +0.4)`: the victim moves toward positive z (away from the source) and upward. With `knockback_resistance 0.5` the strength is 0.2 and the result `(0, 0.2, 0.2)`.
- Death: health reaches 0 at tick T: Entity Event 3 at T; the entity is removed with Event 60 at T + 20.
- Experience: a mob with `xpReward 5` wearing two armor pieces with drop chance 0.085 (<= 1.0): `5 + (1 + nextInt(3)) x 2` = 7 to 11 xp, spawned as orbs `[7]` -> one orb of 7, `[11]` -> orbs 7 + 3 + 1.

### 10.5 Breeding timeline

Two adult cows (age 0). A player feeds both wheat: each gets `inLove = 600` and Entity Event 18. `BreedGoal` starts when each `isInLove()`, finds the partner (within 8 blocks), walks to it; after 60 ticks together within 3 blocks `breed()`: a baby cow (age -24000) spawns; both parents `age = 6000` and `inLove = 0`; 1 to 7 xp is dropped. The parents can breed again after 6000 ticks (their age counts back to 0 at 1 per tick). The baby grows up after 24000 ticks; feeding it wheat advances its age by 10% of the time remaining per feeding.

---

## 11. Validation (what was verified and how)

Read directly from bytecode or data in the jar (high confidence): the entity type table (1.1: ids, sizes, eye heights, tracking ranges, update intervals, flags) and attachment values (1.1.1); the attribute table (1.3) and the living/mob base attribute sets; `MobCategory` values; the metadata slot chain order; the `PathType` list and malus values; `NaturalSpawner` control flow (3 packs, `ceil(nextFloat x 4)`, jitter 6, 24-block rule, pack-size override, cluster limit), the category filter, the 400-tick friendly cycle, `spawn_mobs && spawn_monsters`, caps and the 289 constant, the local cap rule, `SpawnPlacements` registrations (generated from the bootstrap data), placement types, the `DifficultyInstance` formula, the goal selector algorithm and `WrappedGoal.canBeReplacedBy`, the goal constants of 4.2, the control algorithms of 4.4, the random-position helpers, the A* algorithm (including the unweighted start `h` and the 1.5 neighbour weight), the path-following, shortcut, stuck and timeout rules, the node evaluator structure, `LivingEntity` travel formulas, `hurtServer` order and `knockback`, `die`/`tickDeath`/`dropAllDeathLoot`, `ExperienceOrb`, `ItemEntity` constants, `Leashable`, `ServerEntity.sendChanges` and `ChunkMap$TrackedEntity` rules, the `BaseSpawner` flow, the sensor bodies and behaviours listed as read in 4.6, the biome and dimension JSON, and the loot table schema as used in the 94 entity tables.

A conforming implementation can be tested with: the worked examples in section 10 (feed the fixture random values); the mob-cap formula `max x chunks / 289`; the goal-arbitration fixture; A* costs on small grids; the attribute value formula (base 10, ADD_VALUE +2, ADD_MULTIPLIED_BASE +0.5 and +0.25, ADD_MULTIPLIED_TOTAL +0.1 and +0.2: `v = 12; r = 12 + 12 x 0.75 = 21; r = 21 x 1.1 x 1.2 = 27.72`); fall damage `floor((distance - 3) x multiplier)`; entity-type id and category checks against the table.

**Remaining uncertainty markers in this document**: **(inferred)** 3 occurrences in the body (not counting the legend and this paragraph): the default seat for types without declared attachments, the `monsters_burn` step change, and the pairing of the two width conditions in `getPathTypeOfMob`. There are **no** `(recalled, not verified)` marks left; every earlier recalled value (block friction, soul sand, honey, cactus, magma, cobweb, sweet berry bush, lava ignition, the tame flag bit, the armor formula, the feeding speed-up) was read and is stated as read. What is **not** covered is listed in the Open questions and in the unread lists of 4.6 and 4.7.

## Open questions

1. Attachments: tabulated for the types that declare them (1.1.1). Not captured: the `vehicleAttachment` vector of the player and mannequin, the camel's seat data (the builder declares none; its seats are in the camel class), and the passenger seats of boats, rafts and chest boats (computed in the boat classes).
2. Mob-specific overrides of `getWalkTargetValue` (beyond `Animal` and the default 0) and per-mob goal speeds are per-mob data (per-mob catalogues).
3. Brain: the generic behaviours cited by 19, 20 and 21 are in 4.7 (read at the shape level; the arithmetic inside the declarative lambdas of `ChargeAttack`, `RamTarget`, `PrepareRamNearestTarget`, `SetHiddenState`, `TryLaySpawnOnFluidNearLand`, `SetWalkTargetFromBlockMemory` was not expanded). Not read: the villager, raid and point-of-interest behaviours (`AcquirePoi`, `ValidateNearbyPoi`, `SleepInBed`, `WakeUp`, `WorkAtPoi`, `TradeWithVillager`, and the others listed at the end of 4.7), the three `LongJump*` behaviours, the `warden` package, and these sensors: `secondary_pois`, `villager_hostiles`, `golem_detected`, `armadillo_scare_detected`, `piglin_specific_sensor`, `piglin_brute_specific_sensor`, `hoglin_specific_sensor`, `axolotl_attackables`, `frog_attackables`, `warden_entity_sensor`, `breeze_attack_entity_sensor`.
4. Trial spawner mechanics (states, configuration, ominous variant), spawn egg item components beyond 6.12, and the custom spawners (`tickCustomSpawners`: phantom, patrol, trader, cat, village siege/raid) are not specified here.
5. Default monster equipment: the roll structure is read (7.1.2); the tier-to-item table (`Mob.getEquipmentForSlot`), the `mob_spawn_equipment` enchantment provider, and the inner comparison functions of `canReplaceCurrentItem` (7.2) were not read.
6. `ItemEntity` motion, friction and merge conditions beyond the constants in 6.11 were not expanded.
7. Water extinguishing fire (`extinguishFire` callers in the fluid code) was not read; the fire tick rules of 2.5 and the lava damage and ignition are read.
8. The protection arithmetic of `EnchantmentHelper.getDamageProtection` per enchantment is in [17](17-tools-weapons-and-combat.md) section 6; not repeated here.
9. Block data used by spawning and physics: friction, speed factor, jump factor, `isValidSpawn` overrides per block, per-block entity effects (cactus, berry bushes, magma, cobweb, honey, soul sand), and the `valid_spawn` tag semantics, are block-registry data not tabulated here.
10. Per-mob values referenced by the framework (xpReward, getMaxSpawnClusterSize and isMaxGroupSizeReached overrides, ambient sound intervals, attack ranges, food items, goal priorities, the taming chance, baby feeding speed-up) are left to the per-mob catalogues.
11. `EntitySpawnReason`: the set (NATURAL, CHUNK_GENERATION, SPAWNER, STRUCTURE, BREEDING, MOB_SUMMONED, JOCKEY, EVENT, CONVERSION, REINFORCEMENT, TRIGGERED, BUCKET, SPAWN_ITEM_USE, COMMAND, DISPENSER, PATROL, TRIAL_SPAWNER, LOAD, DIMENSION_TRAVEL) is read; only `isSpawner` (SPAWNER, TRIAL_SPAWNER) and `ignoresLightRequirements` (TRIAL_SPAWNER) were read as gates. Which other reasons skip which `checkSpawnRules`, obstruction and light gates is not consolidated.
12. Projectiles: arrow piercing and knockback, the wind charge entities and the other projectile entities (ranged attacks call `performRangedAttack`) were not read; see [17](17-tools-weapons-and-combat.md) for the item side.
13. A consolidated game-rules section: the rules read here are `spawn_mobs`, `spawn_monsters`, `mob_griefing`, `mob_drops`, `entity_drops`, `universal_anger`, `forgive_dead_players`, `random_tick_speed` and `max_entity_cramming`, each described where used; their defaults and the remaining mob-related rules were not collected.
14. Statistics used by mobs (for example `time_since_rest` and the damage statistics) were not read here.
15. The mob equipment enchantment-selection helper (`EnchantmentHelper.enchantItemFromProvider` with the `mob_spawn_equipment` provider) and the equipment tier table (`Mob.getEquipmentForSlot`) (see Open question 5).
16. The arthropod entity-type tag and the Bane of Arthropods effects were not read (the tag `arthropod` and `sensitive_to_bane_of_arthropods` are synchronised tags, 04).
17. Structure `spawn_overrides` replacement rule and the "piece" versus "full" bounding-box semantics used by `mobsAt` (6.5 step 4 uses the fortress case only).
18. `GateBehavior` and `TriggerGate` order and running policies beyond `RunOne` (4.6).
19. Internals not expanded beyond the shape given in 4.7: `TryFindLand`, `TryFindLandNearLiquid`, `TryFindLiquid` (the candidate tests are given; the scan order is not), `GoToWantedItem`, `Croak`, `SetHiddenState`, `CopyMemoryWithExpiry`.

## Appendix A. Natural spawn data per biome (`gameplay/natural_mob_spawns`, `gameplay/creature_world_gen_spawn_probability`)

Format: `type:wWEIGHT:nCOUNT` where COUNT is the pack size (a constant, or `min-max` uniform inclusive). Categories are as in 1.2. Extracted mechanically from `data/minecraft/worldgen/biome/*.json`. `creature_worldgen_prob` is shown only where the biome sets it; otherwise the default 0.1 applies. Spawn costs, where present, appear on a `costs:` line. Biomes with no listed category have no natural spawns of that category.

```
## badlands | creature_worldgen_prob= 0.03
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, armadillo:w6:n1-2
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## bamboo_jungle | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, chicken:w10:n4, parrot:w40:n1-2, panda:w80:n1-2
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, ocelot:w2:n1
 underground_water_creature: glow_squid:w10:n4-6
## basalt_deltas | creature_worldgen_prob= None
 creature: strider:w60:n1-2
 monster: ghast:w40:n1, magma_cube:w100:n2-5
## beach | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: turtle:w5:n2-5
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## birch_forest | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## cherry_grove | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: pig:w1:n1-2, rabbit:w2:n2-6, sheep:w2:n2-4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## cold_ocean | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: cod:w15:n3-6, salmon:w15:n1-5
 water_creature: squid:w3:n1-4, nautilus:w2:n1
## crimson_forest | creature_worldgen_prob= None
 creature: strider:w60:n1-2
 monster: zombified_piglin:w1:n2-4, hoglin:w9:n3-4, piglin:w5:n3-4
## dappled_forest | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, rabbit:w4:n2-4, fox:w4:n2-4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## dark_forest | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## deep_cold_ocean | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: cod:w15:n3-6, salmon:w15:n1-5
 water_creature: squid:w3:n1-4, nautilus:w2:n1
## deep_dark | creature_worldgen_prob= None
 ambient: 
 axolotls: 
 creature: 
 misc: 
 monster: 
 underground_water_creature: 
 water_ambient: 
 water_creature: 
## deep_frozen_ocean | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: polar_bear:w1:n1-2
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: salmon:w15:n1-5
 water_creature: squid:w1:n1-4, nautilus:w2:n1
## deep_lukewarm_ocean | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: cod:w8:n3-6, pufferfish:w5:n1-3, tropical_fish:w25:n8
 water_creature: squid:w8:n1-4, dolphin:w2:n1-2, nautilus:w5:n1
## deep_ocean | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: cod:w10:n3-6
 water_creature: squid:w1:n1-4, dolphin:w1:n1-2, nautilus:w5:n1
## desert | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: rabbit:w12:n2-3, camel:w1:n1
 monster: spider:w100:n4, zombie:w19:n4, zombie_villager:w1:n1, skeleton:w50:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, husk:w80:n4, parched:w50:n4
 underground_water_creature: glow_squid:w10:n4-6
## dripstone_caves | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w95:n4
 underground_water_creature: glow_squid:w10:n4-6
## end_barrens | creature_worldgen_prob= None
 monster: enderman:w10:n4
## end_highlands | creature_worldgen_prob= None
 monster: enderman:w10:n4
## end_midlands | creature_worldgen_prob= None
 monster: enderman:w10:n4
## eroded_badlands | creature_worldgen_prob= 0.03
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, armadillo:w6:n1-2
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## flower_forest | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, rabbit:w4:n2-3
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## forest | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, wolf:w5:n4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## frozen_ocean | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: polar_bear:w1:n1-2
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: salmon:w15:n1-5
 water_creature: squid:w1:n1-4, nautilus:w2:n1
## frozen_peaks | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: goat:w5:n1-3
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## frozen_river | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w1:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: salmon:w5:n1-5
 water_creature: squid:w2:n1-4
## grove | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: wolf:w1:n1, rabbit:w8:n2-3, fox:w4:n2-4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## ice_spikes | creature_worldgen_prob= 0.07
 ambient: bat:w10:n8
 creature: rabbit:w10:n2-3, polar_bear:w1:n1-2
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w20:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, stray:w80:n4
 underground_water_creature: glow_squid:w10:n4-6
## jagged_peaks | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: goat:w5:n1-3
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## jungle | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, chicken:w10:n4, parrot:w40:n1-2, panda:w1:n1-2
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, ocelot:w2:n1-3
 underground_water_creature: glow_squid:w10:n4-6
## lukewarm_ocean | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: cod:w15:n3-6, pufferfish:w5:n1-3, tropical_fish:w25:n8
 water_creature: squid:w10:n1-2, dolphin:w2:n1-2, nautilus:w5:n1
## lush_caves | creature_worldgen_prob= None
 ambient: bat:w10:n8
 axolotls: axolotl:w10:n4-6
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: tropical_fish:w25:n8
## mangrove_swamp | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: frog:w10:n2-5
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w70:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, slime:w1:n1, bogged:w30:n4
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: tropical_fish:w25:n8
## meadow | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: donkey:w1:n1-2, rabbit:w2:n2-6, sheep:w2:n2-4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## mushroom_fields | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: mooshroom:w8:n4-8
 underground_water_creature: glow_squid:w10:n4-6
## nether_wastes | creature_worldgen_prob= None
 creature: strider:w60:n1-2
 monster: ghast:w50:n4, zombified_piglin:w100:n4, magma_cube:w2:n4, enderman:w1:n4, piglin:w15:n4
## ocean | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: cod:w10:n3-6
 water_creature: squid:w1:n1-4, dolphin:w1:n1-2, nautilus:w5:n1
## old_growth_birch_forest | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## old_growth_pine_taiga | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, wolf:w8:n4, rabbit:w4:n2-3, fox:w8:n2-4
 monster: spider:w100:n4, zombie:w100:n4, zombie_villager:w25:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## old_growth_spruce_taiga | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, wolf:w8:n4, rabbit:w4:n2-3, fox:w8:n2-4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## pale_garden | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## plains | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, horse:w5:n2-6, donkey:w1:n1-3
 monster: spider:w100:n4, zombie:w90:n4, zombie_villager:w5:n1, zombie_horse:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## river | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, drowned:w100:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: salmon:w5:n1-5
 water_creature: squid:w2:n1-4
## savanna | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, horse:w1:n2-6, donkey:w1:n1, armadillo:w10:n2-3
 monster: spider:w100:n4, zombie:w90:n4, zombie_villager:w5:n1, zombie_horse:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## savanna_plateau | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, horse:w1:n2-6, donkey:w1:n1, armadillo:w10:n2-3, llama:w8:n4, wolf:w8:n4-8
 monster: spider:w100:n4, zombie:w90:n4, zombie_villager:w5:n1, zombie_horse:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## small_end_islands | creature_worldgen_prob= None
 monster: enderman:w10:n4
## snowy_beach | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## snowy_plains | creature_worldgen_prob= 0.07
 ambient: bat:w10:n8
 creature: rabbit:w10:n2-3, polar_bear:w1:n1-2
 monster: spider:w100:n4, zombie:w90:n4, zombie_villager:w5:n1, zombie_horse:w5:n1, skeleton:w20:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, stray:w80:n4
 underground_water_creature: glow_squid:w10:n4-6
## snowy_slopes | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: rabbit:w4:n2-3, goat:w5:n1-3
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## snowy_taiga | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, wolf:w8:n4, rabbit:w4:n2-3, fox:w8:n2-4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## soul_sand_valley | creature_worldgen_prob= None
 creature: strider:w60:n1-2
 monster: skeleton:w20:n5, ghast:w50:n4, enderman:w1:n4
 costs: {"enderman": {"charge": 0.7, "energy_budget": 0.15}, "ghast": {"charge": 0.7, "energy_budget": 0.15}, "skeleton": {"charge": 0.7, "energy_budget": 0.15}, "strider": {"charge": 0.7, "energy_budget": 0.15}}
## sparse_jungle | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, chicken:w10:n4, wolf:w8:n2-4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## stony_peaks | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## stony_shore | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## sulfur_caves | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: sulfur_cube:w100:n2-4, creeper:w50:n2, skeleton:w50:n2, slime:w25:n1, cave_spider:w20:n1, zombie:w50:n2, enderman:w10:n1, witch:w1:n1, zombie_villager:w5:n1
## sunflower_plains | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, horse:w5:n2-6, donkey:w1:n1-3
 monster: spider:w100:n4, zombie:w90:n4, zombie_villager:w5:n1, zombie_horse:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## swamp | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, frog:w10:n2-5
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w70:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1, slime:w1:n1, bogged:w30:n4
 underground_water_creature: glow_squid:w10:n4-6
## taiga | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, wolf:w8:n4, rabbit:w4:n2-3, fox:w8:n2-4
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## the_end | creature_worldgen_prob= None
 monster: enderman:w10:n4
## the_void | creature_worldgen_prob= None
 ambient: 
 axolotls: 
 creature: 
 misc: 
 monster: 
 underground_water_creature: 
 water_ambient: 
 water_creature: 
## warm_ocean | creature_worldgen_prob= None
 ambient: bat:w10:n8
 monster: drowned:w5:n1, spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
 water_ambient: pufferfish:w15:n1-3, tropical_fish:w25:n8
 water_creature: nautilus:w5:n1, squid:w10:n4, dolphin:w2:n1-2
## warped_forest | creature_worldgen_prob= None
 creature: strider:w60:n1-2
 monster: enderman:w1:n4
 costs: {"enderman": {"charge": 1.0, "energy_budget": 0.12}}
## windswept_forest | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, llama:w5:n4-6
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## windswept_gravelly_hills | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, llama:w5:n4-6
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## windswept_hills | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, llama:w5:n4-6
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## windswept_savanna | creature_worldgen_prob= None
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, horse:w1:n2-6, donkey:w1:n1, armadillo:w10:n2-3
 monster: spider:w100:n4, zombie:w90:n4, zombie_villager:w5:n1, zombie_horse:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
## wooded_badlands | creature_worldgen_prob= 0.04
 ambient: bat:w10:n8
 creature: sheep:w12:n4, pig:w10:n4, chicken:w10:n4, cow:w8:n4, armadillo:w6:n1-2, wolf:w2:n4-8
 monster: spider:w100:n4, zombie:w95:n4, zombie_villager:w5:n1, skeleton:w100:n4, creeper:w100:n4, slime:w100:n4, enderman:w10:n1-4, witch:w5:n1
 underground_water_creature: glow_squid:w10:n4-6
```
