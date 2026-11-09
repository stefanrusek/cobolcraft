# Static registry ids on the wire

| Item | Value |
|---|---|
| Covers | How the numeric id of an entry of a static (built-in) registry is assigned, and the id to key tables of every static registry whose ids appear in a packet and that no earlier document tabulates: mob effects, attributes, particle types, menu types, block entity types, potions, game events, fluids, sound events, villager types and professions, point of interest types, stat types and custom stats, data component types (checked against 17), map decoration types, recipe display, slot display, recipe serializers, data component predicate types, recipe types, recipe book categories, number format types, consume effect types, position source types, command argument types (checked against 05a), debug subscriptions, the enchantment effect families, the entity metadata serializers and the id enums they carry. Entity types are verified against 21 §2 and not repeated. Block, block state and item ids are other rounds (24, 25). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for bootstrap method arguments) with no execution. Every key and id below was read in this round from the class named in section 2.2, in the order of its registering code. Where a statement is not read it is marked "(inferred)" or "(recalled, not verified)" and listed in the Open questions. |
| Status | Written for round RS28 (design map Part 5, GAP-1 ids, and "entity type id check"). Section 17 item 1 lists all 95 static registries as tabulated, owned by another document, or not on the wire. The jar-wide scan of codecs that pair a static registry with a numeric id (Open question 13) covers every registry. It found one wire use that is not a plain VarInt registry id: the beacon menu data slots carry mob effect ids as registry id plus 1 (sections 3 and 4.1). That use is now covered. The sound event helper methods and the pattern-C registries were not scanned for other registering classes (Open question 14). |

Class names in backticks say where a fact was read. They are not the design. "04 §5" means section 5 of
`04-registry-sync.md`; "21 §2" means section 2 of document 21, and so on.

## Contents

1. [Scope and conventions](#1-scope-and-conventions)
2. [The id rule](#2-the-id-rule)
3. [Where each registry is referenced on the wire](#3-where-each-registry-is-referenced-on-the-wire)
4. [Combat and status registries: mob effects, attributes, potions](#4-combat-and-status-registries)
5. [World registries: particle types, game events, fluids, block entity types, menu types, map decorations](#5-world-registries)
6. [Villager and point of interest registries](#6-villager-and-point-of-interest-registries)
7. [Statistics](#7-statistics)
8. [Items: data component types, consume effects, number formats, data component predicate types](#8-items-and-ui)
9. [Recipes: serializers, types, displays, book categories](#9-recipes)
10. [Commands: argument types](#10-commands-argument-types)
11. [Entity types: verification of 21 §2](#11-entity-types-verification-of-21-2)
12. [Entity metadata: serializers and id enums](#12-entity-metadata-serializers-and-id-enums)
13. [Enchantment effect families, debug subscriptions, position sources](#13-enchantment-families-debug-subscriptions-position-sources)
14. [Sound events](#14-sound-events)
15. [Worked examples](#15-worked-examples)
16. [Validation](#16-validation)
17. [Open questions](#17-open-questions)

## 1. Scope and conventions

- A **static registry** is one of the 95 registries created in the static initialiser of
  `net.minecraft.core.registries.BuiltInRegistries` (84 by `registerSimple`, 6 by `registerDefaulted`, 4 by
  `registerDefaultedWithIntrusiveHolders`, 1 by `registerSimpleWithIntrusiveHolders`). They are never sent
  (04 §5). A packet that names an entry of one of them carries a VarInt id, so a server must reproduce the
  client's numbering exactly (R8, standard world type).
- **Keys.** An entry's key is `minecraft:<name>`. The tables give `<name>` only. The one exception is
  the command argument type registry (section 10), whose first six keys are in the namespace `brigadier`.
  The string given to the registering helper is parsed with `Identifier.parse`, which supplies the namespace
  `minecraft` when none is written, or the key is built with `Identifier.withDefaultNamespace` (read in each
  class's helper).
- **Table layout.** Long tables list several (id, key) pairs per row. Ids ascend down each column group, and the
  first column group holds the lowest ids.
- **Counts are of registered entries**, not of fields: several content classes also hold non-registered static
  fields (codecs, caches, sets). Section 2.3 lists them.
- Data rows (the contents of the entries of data-driven registries) are not tabulated here. These are code
  registries: the order of registration is code.

## 2. The id rule

### 2.1 Mechanism

1. Every static registry is a `MappedRegistry` (the four with a default are `DefaultedMappedRegistry`, a subclass).
   `MappedRegistry.register(key, value, info)` reads the current size of its `byId` list, appends the new holder,
   and stores that size as the value's id in `toId`. The id of an entry is therefore the number of entries
   registered before it in the same registry. Ids are contiguous from 0.
2. There is no registering method that takes an explicit id. The only writers of the id list are the constructor
   and `register`. `freeze()` does not modify the id list (checked: the method reads `frozen`, `byValue`, `byKey`,
   `allTags`, `frozenTags` and `unregisteredIntrusiveHolders`; it reads the `byId` list once, only to pass it as an iterable to
   the `DataComponentLookup` constructor, and it writes the `frozen`, `unregisteredIntrusiveHolders`, `componentLookup` and `allTags`
   fields). Only the constructor (which creates the list) and `register` (size, then append) write it.
3. `Registry.register(registry, String, value)` turns the string into an Identifier with `Identifier.parse`; the
   `Identifier` overload builds a `ResourceKey` and calls `register`.
4. The order of registration of **different registries** does not matter for ids. `BuiltInRegistries.bootStrap`
   calls `createContents`, which runs each registry's loader in the insertion order of the `LOADERS` map (the order
   of the static initialiser's calls), then `freeze`. Each registry's ids depend only on the order of the
   registering code of that registry.
5. The registering code of each registry of this document lives in one class. Two methods were used to show it.
   - Jar-wide scan (done): I scanned every class of the jar for `Registry.register` and `registerForHolder` calls that follow a
     `BuiltInRegistries.<NAME>` reference. Each registry of pattern A and pattern B (section 2.2) has one registering class.
     `SOUND_EVENT` has one class with three helper methods.
   - Bootstrap method only (not scanned jar-wide): the registries whose loader passes the registry as an argument
     (`VILLAGER_TYPE`, `VILLAGER_PROFESSION`, `POINT_OF_INTEREST_TYPE`, `RECIPE_SERIALIZER`, `RECIPE_DISPLAY`, `SLOT_DISPLAY`,
     `NUMBER_FORMAT_TYPE`, `COMMAND_ARGUMENT_TYPE`) and the codec-type registries of section 13. I read their `bootstrap` methods. The scan
     pattern cannot see calls that receive the registry as an argument, so that no other class registers into them is inferred (Open question 14).

### 2.2 Where the order is written

There are three patterns. The table says which one each registry uses and where the order must be read.

| Pattern | Order of the ids is | Registries (registering class) |
|---|---|---|
| A. Static initialiser of the content class | the order of the `register(...)` calls in `<clinit>` (which is also the order of the `putstatic` that stores each result) | mob effect (`MobEffects`), attribute (`Attributes`), particle type (`ParticleTypes`), menu (`MenuType`), game event (`GameEvent`), data component type (`DataComponents`), map decoration type (`MapDecorationTypes`), position source type (`PositionSourceType`), recipe type (`RecipeType`), recipe book category (`RecipeBookCategories`), debug subscription (`DebugSubscriptions`), enchantment effect component type (`EnchantmentEffectComponents`), stat type and custom stat (`Stats`), consume effect type (`ConsumeEffect$Type`, a nested class), sound event (`SoundEvents`, with the generated groups of 14.2) |
| B. Key class plus content class | the order of `register(key, ...)` calls in the content class `<clinit>`. The keys come from a separate class of `ResourceKey` constants (`EntityTypeIds`, `PotionIds`, `BlockEntityTypeIds`, `FluidIds`), each key built by a helper from the plain name; the declaration order in the key class is not the registration order | entity type (`EntityTypes`), potion (`Potions`), block entity type (`BlockEntityTypes`), fluid (`Fluids`) |
| C. `bootstrap` method | the order of the register calls inside the class's `public static ... bootstrap(Registry)` method. The `ResourceKey` fields of the class are created in `<clinit>`, and may be declared in a different order | villager profession (`VillagerProfession`), villager type (`VillagerType`), point of interest type (`PoiTypes`), recipe serializer (`RecipeSerializers`), recipe display (`RecipeDisplays`), slot display (`SlotDisplays`), number format type (`NumberFormatTypes`), command argument type (`ArgumentTypeInfos`), and the codec-type registries of section 13 |

### 2.3 Traps found (read from the artifact)

- **Field order is not always registration order.** `PoiTypes` declares the key `lightning_rod` before
  `test_instance`, but its `bootstrap` registers `test_instance` (id 19) before `lightning_rod` (id 20). An id
  table built from field declarations would swap the two. The same trap can exist in any pattern-C class. For villager profession and villager type the bootstrap order and the field
  order agree (compared in this round); the other pattern-C classes have no key fields to compare.
- **Non-registered static fields.** `DataComponents` has two (`ENCODER_CACHE` first, `COMMON_ITEM_COMPONENTS` last),
  so the first registered component, `custom_data`, is the second `putstatic`. `ParticleTypes` has two (`CODEC`
  and `STREAM_CODEC`), `GameEvent` has one (`CODEC`), `EntityTypes` has one (`OP_ONLY_CUSTOM_DATA`, a set), `BlockEntityTypes`
  has two (`LOGGER`, `OP_ONLY_CUSTOM_DATA`). Counting `putstatic` instead of registrations shifts ids. Rule: count
  `register` calls.
- **The registered key is not always the constant's name.** Read: attribute `spawn_reinforcements` (constant `SPAWN_REINFORCEMENTS_CHANCE`),
  particle `trial_spawner_detection` and `trial_spawner_detection_ominous` (constants `TRIAL_SPAWNER_DETECTED_PLAYER` and `..._OMINOUS`), custom stat
  `sneak_time` (`CROUCH_TIME`), the nine stat types (`mined`, `crafted`, ... from `BLOCK_MINED`, `ITEM_CRAFTED`, ...), and 24 map decoration types
  (`mansion`, `monument`, `banner_<colour>`, `village_<kind>`, `ocean_ruin_warm`, ...). Use the tables, not the constant names.
- **Entity types are almost, but not exactly, alphabetical** (section 11): six entries sit out of place.
- **Sound events are produced partly by loops.** `SoundEvents` registers 1897 single names and six groups of
  generated names (section 14.2).
- **`stat_type` and `custom_stat` come from one class.** Section 7.

### 2.4 Defaulted registries

Ten static registries are defaulted: `game_event` (default key `step`), `fluid` (`empty`), `block` (`air`), `entity_type`
(`pig`), `item` (`air`), `chunk_status` (`empty`), `villager_type` (`plains`), `villager_profession` (`none`),
`memory_module_type` (`dummy`), `sensor_type` (`dummy`). The default key is stored as a string at creation and the
default entry is the one registered under that key; it takes the id its position gives it. The default is not id 0 in
general: `step` is 42, `pig` is 101, `plains` is 2; `empty` fluid is 0 and `none` profession is 0. In a
`DefaultedMappedRegistry`, `byId` for an id that is out of range returns the default entry's value, and `getId`
for a value that is not registered returns the default entry's id (read in `byId` and `getId`; a plain `MappedRegistry`
returns null for an out-of-range `byId`, and its `getId` of an unregistered value is -1: the constructor builds `toId` through `Util.make` with a
lambda that sets `defaultReturnValue(-1)`, read in this round; a defaulted registry maps that -1 to the default entry's id).

**Consequence for a server**: use the numbering only. Do not rely on the default entry to absorb an unknown id on the
client; wire decoders for plain registry references fail on an unknown id (04 §4: `byIdOrThrow`).

### 2.5 Names for saves and JSON, ids for packets

Every registry-valued field has two codecs side by side: a name codec for NBT, JSON and data files, and a registry
id codec for the network. Read for `MobEffect`, `Attribute`, `Potion`, `MapDecorationType`, `VillagerData`
(`holderByNameCodec` next to `ByteBufCodecs.holderRegistry`), and for `EntityType`, `ParticleTypes`,
`DataComponentType`, `ConsumeEffect` (`byNameCodec` next to `ByteBufCodecs.registry`). So, for these registries, **save
data and data packs refer to entries by key, and the numeric ids of this document appear only in packets**. (The other
registries of the document were not individually checked: inferred, Open question 5.) Numeric ids in save data
(inferred, none found for the registries read) would only come from enums with their own id (section 12), which are
not registries.

### 2.6 Registries that are not `MappedRegistry`

- Entity metadata serializers: a `CrudeIncrementalIntIdentityHashBiMap` filled by `registerSerializer`. Its `add`
  takes its id from a persistent cursor `nextId`, which starts at 0 and is advanced while `byId[nextId]` is occupied; nothing is
  ever removed, so ids are the call order, from 0 (confirms the inference of 00 §13.2).
- Block states: `Block.BLOCK_STATE_REGISTRY` (04 §5.2).
- Enums with an explicit `id` (`Pose`, `DyeColor`, `HumanoidArm`, ...): section 12.2.

## 3. Where each registry is referenced on the wire

Scan of 05a, 05b, 05c, 00, 03 and 09. "This" is a table of this document; "other" says which round or document owns
the numbers.

| Registry | Wire form | Packets and fields | Ids |
|---|---|---|---|
| `entity_type` | VarInt id | Add Entity (05a 0x01); tags (04, Update Tags 0x0E / 0x89) | 21 §2 (verified, section 11) |
| `block_entity_type` | VarInt id | Block Entity Data (05a 0x06); chunk data block entity list (06); the `block_entity_data` item component (id 62, section 8.1): its network codec is a type id (`ByteBufCodecs.registry(BLOCK_ENTITY_TYPE)`) followed by a network NBT compound (`TypedEntityData.streamCodec`, composite of the type codec and `COMPOUND_TAG`) | section 5.4 |
| `block` | VarInt id | Block Event (05a 0x07); tags; the hive info of the clientbound debug payloads (`DebugHiveInfo`, `ByteBufCodecs.registry(BLOCK)`, 05a Debug Event and Debug Block Value) | other (24) |
| `item` | VarInt id (`holderRegistry`) | slots, item stack templates, Container Click (05c 0x12), slot display, tags | other (25) |
| `fluid` | in tags only | Update Tags (04, Update Tags 0x0E / 0x89) | section 5.3 |
| `game_event` | VarInt id (`holderRegistry`) in the `DebugGameEventInfo` payload; also in tags | Update Tags (04, Update Tags 0x0E / 0x89); clientbound debug payloads (05a Debug Event, Debug Block Value, Debug Entity Value) | section 5.2 |
| `potion` | in tags; `Potion.STREAM_CODEC` is `holderRegistry(POTION)` | Update Tags; the `potion_contents` component (17, payload layout not in this round) | section 4.3 |
| `point_of_interest_type` | VarInt id (`holderRegistry`) in the `DebugPoiInfo` payload; also in tags | Update Tags (04, Update Tags 0x0E / 0x89); clientbound debug payloads (05a) | section 6.3 |
| `command_argument_type` | VarInt id | Commands (05a 0x10) | section 10 (matches 05a) |
| `menu` | VarInt id | Open Screen (05a 0x3C) | section 5.5 |
| `mob_effect` | VarInt id (`holderRegistry`, no inline form) | Update Mob Effect (05b 0x87), Remove Mob Effect (05b 0x4F), Set Beacon (05c 0x35), item components with effect lists; also the beacon menu data slots 1 and 2 (Set Container Property traffic), which carry the id plus 1 and not a VarInt registry id (section 4.1) | section 4.1 |
| `attribute` | VarInt id (`holderRegistry`) | Update Attributes (05b 0x86), attribute modifier components | section 4.2 |
| `particle_type` | VarInt id then options | Level Particles (05a 0x30), Explode (explosion particle and block particles), metadata serializers 16 and 17 (00 §13.2) | section 5.1 (options layouts in 05a) |
| `sound_event` | Holder: VarInt 0 plus an inline sound, or id + 1 | Sound (05b 0x77), Sound Entity (05b 0x76), Explode, item components | section 14; an inline sound avoids the table |
| `stat_type`, `custom_stat` and the registries the stat types range over | VarInt stat type, VarInt value id | Award Statistics (05a) | section 7 (the other value registries: block 24, item 25, entity type 21 §2) |
| `entity_type` (component use) | the `entity_data` component (id 60) uses `EntityType.STREAM_CODEC`, which is `ByteBufCodecs.registry(ENTITY_TYPE)`, inside the same `TypedEntityData.streamCodec` form | item stacks | 21 §2 |
| `data_component_type` | VarInt id | item stacks and patches (00 §12), Container Click hashed stacks (05c 0x12), slot display | section 8.1 (compared with 17) |
| `data_component_predicate_type` | Either: Boolean, then a VarInt id of this registry (true) or of `data_component_type` (false) | `can_place_on` and `can_break` components (ids 14 and 15 of section 8.1) through the adventure mode predicate | section 8.4 |
| `number_format_type` | VarInt id | scoreboard number formats (05b) | section 8.3 |
| `recipe_display`, `slot_display`, `recipe_book_category` | VarInt id | Recipe Book Add (05a/05b) | section 9 |
| `map_decoration_type` | VarInt id (`holderRegistry`) | Map Item Data (05a) | section 5.6 |
| `position_source_type` | VarInt id | the `vibration` particle option (05a) | section 13.3 |
| `debug_subscription` | VarInt id | Debug Subscription Request (05c 0x17), debug packets (05a) | section 13.2 |
| `villager_type`, `villager_profession` | VarInt ids inside metadata serializer 18 | Set Entity Data (00 §13.2) | section 6 |
| `consume_effect_type` | VarInt id inside the `consumable` component | item components (17) | section 8.2 |
| entity metadata serializers | VarInt id | Set Entity Data (00 §13) | section 12 (matches 00 §13.2) |
| `game_rule` | Identifier (no number): `ClientboundGameRuleValuesPacket` is a map codec of `ResourceKey.streamCodec(GAME_RULE)` keys to `STRING_UTF8` values (read; matches 05a 0x28) | Game rule values (05a) | 16 |
| `dimension_type`, `damage_type`, `world_clock`, `dialog`, `chat_type`, `trim_pattern`, variants | synchronized registries | various | 04 §3 and §4 (ids are the order of Registry Data) |
| (scan result) | The jar-wide search for classes that pair a `BuiltInRegistries` reference with `getId`, `byId` or `asHolderIdMap` found `ClientboundCommandsPacket` (argument types), `Item`, `BeaconMenu` (mob effect, the use named in the `mob_effect` row), and `ParticleEngine` and `ParticleResources` (client side only, no packet) | | |
| `loot_*` and other data engine registries | none | not referenced by any packet read | none (Open question 4) |

## 4. Combat and status registries

### 4.1 Mob effects (`mob_effect`, 40 entries, `MobEffects` pattern A)

Wire: Update Mob Effect, Remove Mob Effect, Set Beacon (optional primary and secondary), `apply_effects` and
`remove_effects` consume effects and other item components that hold effects (payload layouts: 17). There is no inline form.

**Second wire use, beacon menu data slots.** `BeaconMenu` has three container data slots (a `SimpleContainerData` of size 3, read). Slot 0 is the pyramid level count (read in `getLevels`), slot 1 is the primary effect and slot 2 the secondary effect (read in `getPrimaryEffect` and `getSecondaryEffect`). `encodeEffect` stores
`MOB_EFFECT.asHolderIdMap().getId(effect) + 1` and stores 0 when the holder is null; `decodeEffect` maps 0 to no effect and any other value v to the entry with id v - 1. These slot values travel in the container data traffic (Set Container Property, a plain number and not a VarInt registry id; the exact integer width is Open question 15),
so a server must send id + 1 for slots 1 and 2 of an open beacon menu. Worked example: speed (id 0) is sent as 1, haste (id 2) as 3, regeneration (id 9) as 10, no effect as 0. (That the container data packet carries these values as plain numbers is the reading of the menu classes; the packet itself is not in 05a or 05b: Open question 15.)

| Id | Key | Id | Key |
|---|---|---|---|
| 0 | `speed` | 20 | `health_boost` |
| 1 | `slowness` | 21 | `absorption` |
| 2 | `haste` | 22 | `saturation` |
| 3 | `mining_fatigue` | 23 | `glowing` |
| 4 | `strength` | 24 | `levitation` |
| 5 | `instant_health` | 25 | `luck` |
| 6 | `instant_damage` | 26 | `unluck` |
| 7 | `jump_boost` | 27 | `slow_falling` |
| 8 | `nausea` | 28 | `conduit_power` |
| 9 | `regeneration` | 29 | `dolphins_grace` |
| 10 | `resistance` | 30 | `bad_omen` |
| 11 | `fire_resistance` | 31 | `hero_of_the_village` |
| 12 | `water_breathing` | 32 | `darkness` |
| 13 | `invisibility` | 33 | `trial_omen` |
| 14 | `blindness` | 34 | `raid_omen` |
| 15 | `night_vision` | 35 | `wind_charged` |
| 16 | `hunger` | 36 | `weaving` |
| 17 | `weakness` | 37 | `oozing` |
| 18 | `poison` | 38 | `infested` |
| 19 | `wither` | 39 | `breath_of_the_nautilus` |

### 4.2 Attributes (`attribute`, 40 entries, `Attributes` pattern A)

The registered name is the first string of each registration. One name differs from the constant name: `spawn_reinforcements`
(constant `SPAWN_REINFORCEMENTS_CHANCE`, id 32). The order is not strictly alphabetical: `explosion_knockback_resistance` (12)
precedes `entity_interaction_range` (13), and `waypoint_transmit_range` (38) precedes `waypoint_receive_range` (39).

| Id | Key | Id | Key |
|---|---|---|---|
| 0 | `air_drag_modifier` | 20 | `knockback_resistance` |
| 1 | `armor` | 21 | `luck` |
| 2 | `armor_toughness` | 22 | `max_absorption` |
| 3 | `attack_damage` | 23 | `max_health` |
| 4 | `attack_knockback` | 24 | `mining_efficiency` |
| 5 | `attack_speed` | 25 | `movement_efficiency` |
| 6 | `below_name_distance` | 26 | `movement_speed` |
| 7 | `block_break_speed` | 27 | `name_tag_distance` |
| 8 | `block_interaction_range` | 28 | `oxygen_bonus` |
| 9 | `bounciness` | 29 | `safe_fall_distance` |
| 10 | `burning_time` | 30 | `scale` |
| 11 | `camera_distance` | 31 | `sneaking_speed` |
| 12 | `explosion_knockback_resistance` | 32 | `spawn_reinforcements` |
| 13 | `entity_interaction_range` | 33 | `step_height` |
| 14 | `fall_damage_multiplier` | 34 | `submerged_mining_speed` |
| 15 | `flying_speed` | 35 | `sweeping_damage_ratio` |
| 16 | `follow_range` | 36 | `tempt_range` |
| 17 | `friction_modifier` | 37 | `water_movement_efficiency` |
| 18 | `gravity` | 38 | `waypoint_transmit_range` |
| 19 | `jump_strength` | 39 | `waypoint_receive_range` |

### 4.3 Potions (`potion`, 46 entries, `Potions` pattern B, keys in `PotionIds`)

Potion ids appear in Update Tags (the data pack has 5 potion tags) and, by holder id, in the `potion_contents` component.
Long and strong variants are separate entries, in the order shown.

| Id | Key | Id | Key |
|---|---|---|---|
| 0 | `water` | 23 | `long_water_breathing` |
| 1 | `mundane` | 24 | `healing` |
| 2 | `thick` | 25 | `strong_healing` |
| 3 | `awkward` | 26 | `harming` |
| 4 | `night_vision` | 27 | `strong_harming` |
| 5 | `long_night_vision` | 28 | `poison` |
| 6 | `invisibility` | 29 | `long_poison` |
| 7 | `long_invisibility` | 30 | `strong_poison` |
| 8 | `leaping` | 31 | `regeneration` |
| 9 | `long_leaping` | 32 | `long_regeneration` |
| 10 | `strong_leaping` | 33 | `strong_regeneration` |
| 11 | `fire_resistance` | 34 | `strength` |
| 12 | `long_fire_resistance` | 35 | `long_strength` |
| 13 | `swiftness` | 36 | `strong_strength` |
| 14 | `long_swiftness` | 37 | `weakness` |
| 15 | `strong_swiftness` | 38 | `long_weakness` |
| 16 | `slowness` | 39 | `luck` |
| 17 | `long_slowness` | 40 | `slow_falling` |
| 18 | `strong_slowness` | 41 | `long_slow_falling` |
| 19 | `turtle_master` | 42 | `wind_charged` |
| 20 | `long_turtle_master` | 43 | `weaving` |
| 21 | `strong_turtle_master` | 44 | `oozing` |
| 22 | `water_breathing` | 45 | `infested` |

## 5. World registries

### 5.1 Particle types (`particle_type`, 128 entries, `ParticleTypes` pattern A)

The third column says whether the type carries option bytes after its id. "options" are the 22 types that 05a's
option table lists (the two lists match exactly: compared in this round); the other 106 are of the simple particle
class and carry no bytes.

| Id | Key | Payload | Id | Key | Payload |
|---|---|---|---|---|---|
| 0 | `angry_villager` | none | 64 | `item_snowball` | none |
| 1 | `block` | options | 65 | `large_smoke` | none |
| 2 | `block_marker` | options | 66 | `lava` | none |
| 3 | `bubble` | none | 67 | `mycelium` | none |
| 4 | `sulfur_bubbles` | none | 68 | `note` | none |
| 5 | `noxious_gas` | none | 69 | `poof` | none |
| 6 | `noxious_gas_cloud` | none | 70 | `portal` | none |
| 7 | `geyser` | options | 71 | `rain` | none |
| 8 | `geyser_base` | options | 72 | `smoke` | none |
| 9 | `geyser_poof` | options | 73 | `white_smoke` | none |
| 10 | `geyser_plume` | options | 74 | `sneeze` | none |
| 11 | `cloud` | none | 75 | `spit` | none |
| 12 | `copper_fire_flame` | none | 76 | `squid_ink` | none |
| 13 | `crit` | none | 77 | `sweep_attack` | none |
| 14 | `damage_indicator` | none | 78 | `totem_of_undying` | none |
| 15 | `dragon_breath` | options | 79 | `underwater` | none |
| 16 | `dripping_lava` | none | 80 | `splash` | none |
| 17 | `falling_lava` | none | 81 | `witch` | none |
| 18 | `landing_lava` | none | 82 | `bubble_pop` | none |
| 19 | `dripping_water` | none | 83 | `current_down` | none |
| 20 | `falling_water` | none | 84 | `bubble_column_up` | none |
| 21 | `dust` | options | 85 | `nautilus` | none |
| 22 | `dust_color_transition` | options | 86 | `dolphin` | none |
| 23 | `effect` | options | 87 | `campfire_cosy_smoke` | none |
| 24 | `elder_guardian` | none | 88 | `campfire_signal_smoke` | none |
| 25 | `enchanted_hit` | none | 89 | `dripping_honey` | none |
| 26 | `enchant` | none | 90 | `falling_honey` | none |
| 27 | `end_rod` | none | 91 | `landing_honey` | none |
| 28 | `entity_effect` | options | 92 | `falling_nectar` | none |
| 29 | `explosion_emitter` | none | 93 | `falling_spore_blossom` | none |
| 30 | `explosion` | none | 94 | `ash` | none |
| 31 | `gust` | none | 95 | `crimson_spore` | none |
| 32 | `small_gust` | none | 96 | `warped_spore` | none |
| 33 | `gust_emitter_large` | none | 97 | `spore_blossom_air` | none |
| 34 | `gust_emitter_small` | none | 98 | `dripping_obsidian_tear` | none |
| 35 | `sonic_boom` | none | 99 | `falling_obsidian_tear` | none |
| 36 | `falling_dust` | options | 100 | `landing_obsidian_tear` | none |
| 37 | `firework` | none | 101 | `reverse_portal` | none |
| 38 | `fishing` | none | 102 | `white_ash` | none |
| 39 | `flame` | none | 103 | `small_flame` | none |
| 40 | `infested` | none | 104 | `snowflake` | none |
| 41 | `cherry_leaves` | none | 105 | `dripping_dripstone_lava` | none |
| 42 | `pale_oak_leaves` | none | 106 | `falling_dripstone_lava` | none |
| 43 | `red_poplar_leaves` | none | 107 | `dripping_dripstone_water` | none |
| 44 | `orange_poplar_leaves` | none | 108 | `falling_dripstone_water` | none |
| 45 | `yellow_poplar_leaves` | none | 109 | `glow_squid_ink` | none |
| 46 | `tinted_leaves` | options | 110 | `glow` | none |
| 47 | `sculk_soul` | none | 111 | `wax_on` | none |
| 48 | `sculk_charge` | options | 112 | `wax_off` | none |
| 49 | `sculk_charge_pop` | none | 113 | `electric_spark` | none |
| 50 | `soul_fire_flame` | none | 114 | `scrape` | none |
| 51 | `soul` | none | 115 | `shriek` | options |
| 52 | `flash` | options | 116 | `egg_crack` | none |
| 53 | `happy_villager` | none | 117 | `dust_plume` | none |
| 54 | `composter` | none | 118 | `trial_spawner_detection` | none |
| 55 | `heart` | none | 119 | `trial_spawner_detection_ominous` | none |
| 56 | `instant_effect` | options | 120 | `vault_connection` | none |
| 57 | `item` | options | 121 | `dust_pillar` | options |
| 58 | `vibration` | options | 122 | `ominous_spawning` | none |
| 59 | `trail` | options | 123 | `raid_omen` | none |
| 60 | `pause_mob_growth` | none | 124 | `trial_omen` | none |
| 61 | `reset_mob_growth` | none | 125 | `block_crumble` | options |
| 62 | `item_slime` | none | 126 | `firefly` | none |
| 63 | `item_cobweb` | none | 127 | `sulfur_cube_goo` | none |

### 5.2 Game events (`game_event`, 61 entries, `GameEvent` pattern A, default `step`)

`resonate_1` to `resonate_15` end the list (ids 46 to 60). Ids appear in Update Tags (the data pack has 5 game event tag files) and, as a holder id, in the clientbound `DebugGameEventInfo` payload (section 3).

| Id | Key | Id | Key | Id | Key |
|---|---|---|---|---|---|
| 0 | `block_activate` | 21 | `entity_action` | 42 | `step` |
| 1 | `block_attach` | 22 | `equip` | 43 | `swim` |
| 2 | `block_change` | 23 | `explode` | 44 | `teleport` |
| 3 | `block_close` | 24 | `flap` | 45 | `unequip` |
| 4 | `block_deactivate` | 25 | `fluid_pickup` | 46 | `resonate_1` |
| 5 | `block_destroy` | 26 | `fluid_place` | 47 | `resonate_2` |
| 6 | `block_detach` | 27 | `hit_ground` | 48 | `resonate_3` |
| 7 | `block_open` | 28 | `instrument_play` | 49 | `resonate_4` |
| 8 | `block_place` | 29 | `item_interact_finish` | 50 | `resonate_5` |
| 9 | `bounce` | 30 | `item_interact_start` | 51 | `resonate_6` |
| 10 | `container_close` | 31 | `jukebox_play` | 52 | `resonate_7` |
| 11 | `container_open` | 32 | `jukebox_stop_play` | 53 | `resonate_8` |
| 12 | `drink` | 33 | `lightning_strike` | 54 | `resonate_9` |
| 13 | `eat` | 34 | `note_block_play` | 55 | `resonate_10` |
| 14 | `elytra_glide` | 35 | `prime_fuse` | 56 | `resonate_11` |
| 15 | `entity_damage` | 36 | `projectile_land` | 57 | `resonate_12` |
| 16 | `entity_die` | 37 | `projectile_shoot` | 58 | `resonate_13` |
| 17 | `entity_dismount` | 38 | `sculk_sensor_tendrils_clicking` | 59 | `resonate_14` |
| 18 | `entity_interact` | 39 | `shear` | 60 | `resonate_15` |
| 19 | `entity_mount` | 40 | `shriek` |  |  |
| 20 | `entity_place` | 41 | `splash` |  |  |

### 5.3 Fluids (`fluid`, 5 entries, `Fluids` pattern B, default `empty`)

Fluid ids appear in Update Tags (10 fluid tags in the data pack).

| Id | Key |
|---|---|
| 0 | `empty` |
| 1 | `flowing_water` |
| 2 | `water` |
| 3 | `flowing_lava` |
| 4 | `lava` |

### 5.4 Block entity types (`block_entity_type`, 49 entries, `BlockEntityTypes` pattern B, keys in `BlockEntityTypeIds`)

Used by Block Entity Data, by the block entity list of a chunk packet and by the `block_entity_data` item component (id 62; the type id is followed by a network NBT compound). The registry is created with intrusive holders
(`registerSimpleWithIntrusiveHolders`), which does not change numbering.

| Id | Key | Id | Key |
|---|---|---|---|
| 0 | `furnace` | 25 | `conduit` |
| 1 | `chest` | 26 | `barrel` |
| 2 | `trapped_chest` | 27 | `smoker` |
| 3 | `ender_chest` | 28 | `blast_furnace` |
| 4 | `jukebox` | 29 | `lectern` |
| 5 | `dispenser` | 30 | `bell` |
| 6 | `dropper` | 31 | `jigsaw` |
| 7 | `sign` | 32 | `campfire` |
| 8 | `hanging_sign` | 33 | `beehive` |
| 9 | `mob_spawner` | 34 | `sculk_sensor` |
| 10 | `creaking_heart` | 35 | `calibrated_sculk_sensor` |
| 11 | `piston` | 36 | `sculk_catalyst` |
| 12 | `brewing_stand` | 37 | `sculk_shrieker` |
| 13 | `enchanting_table` | 38 | `chiseled_bookshelf` |
| 14 | `end_portal` | 39 | `shelf` |
| 15 | `beacon` | 40 | `brushable_block` |
| 16 | `skull` | 41 | `decorated_pot` |
| 17 | `daylight_detector` | 42 | `crafter` |
| 18 | `hopper` | 43 | `trial_spawner` |
| 19 | `comparator` | 44 | `vault` |
| 20 | `banner` | 45 | `test_block` |
| 21 | `structure_block` | 46 | `test_instance_block` |
| 22 | `end_gateway` | 47 | `copper_golem_statue` |
| 23 | `command_block` | 48 | `potent_sulfur` |
| 24 | `shulker_box` |  |  |

### 5.5 Menu types (`menu`, 25 entries, `MenuType` pattern A)

Used by Open Screen. `crafting` is 12 (13 §3.5 says the same).

| Id | Key | Id | Key |
|---|---|---|---|
| 0 | `generic_9x1` | 13 | `enchantment` |
| 1 | `generic_9x2` | 14 | `furnace` |
| 2 | `generic_9x3` | 15 | `grindstone` |
| 3 | `generic_9x4` | 16 | `hopper` |
| 4 | `generic_9x5` | 17 | `lectern` |
| 5 | `generic_9x6` | 18 | `loom` |
| 6 | `generic_3x3` | 19 | `merchant` |
| 7 | `crafter_3x3` | 20 | `shulker_box` |
| 8 | `anvil` | 21 | `smithing` |
| 9 | `beacon` | 22 | `smoker` |
| 10 | `blast_furnace` | 23 | `cartography_table` |
| 11 | `brewing_stand` | 24 | `stonecutter` |
| 12 | `crafting` |  |  |

### 5.6 Map decoration types (`map_decoration_type`, 40 entries, `MapDecorationTypes` pattern A)

The registered key is the first argument of the helper (`mansion`, `monument`, `banner_white`, `village_desert`,
`ocean_ruin_warm`, ...). The second argument is the asset id and differs from the key for 24 entries (for example key `mansion` has asset
`woodland_mansion`); it is not on the wire.

| Id | Key | Id | Key |
|---|---|---|---|
| 0 | `player` | 20 | `banner_purple` |
| 1 | `frame` | 21 | `banner_blue` |
| 2 | `red_marker` | 22 | `banner_brown` |
| 3 | `blue_marker` | 23 | `banner_green` |
| 4 | `target_x` | 24 | `banner_red` |
| 5 | `target_point` | 25 | `banner_black` |
| 6 | `player_off_map` | 26 | `red_x` |
| 7 | `player_off_limits` | 27 | `village_desert` |
| 8 | `mansion` | 28 | `village_plains` |
| 9 | `monument` | 29 | `village_savanna` |
| 10 | `banner_white` | 30 | `village_snowy` |
| 11 | `banner_orange` | 31 | `village_taiga` |
| 12 | `banner_magenta` | 32 | `jungle_temple` |
| 13 | `banner_light_blue` | 33 | `swamp_hut` |
| 14 | `banner_yellow` | 34 | `trial_chambers` |
| 15 | `banner_lime` | 35 | `abandoned_camp` |
| 16 | `banner_pink` | 36 | `ancient_city` |
| 17 | `banner_gray` | 37 | `desert_pyramid` |
| 18 | `banner_light_gray` | 38 | `mineshaft` |
| 19 | `banner_cyan` | 39 | `ocean_ruin_warm` |

## 6. Villager and point of interest registries

### 6.1 Villager types (`villager_type`, 7 entries, `VillagerType.bootstrap`, default `plains`)

| Id | Key |
|---|---|
| 0 | `desert` |
| 1 | `jungle` |
| 2 | `plains` |
| 3 | `savanna` |
| 4 | `snow` |
| 5 | `swamp` |
| 6 | `taiga` |

### 6.2 Villager professions (`villager_profession`, 15 entries, `VillagerProfession.bootstrap`, default `none`)

| Id | Key |
|---|---|
| 0 | `none` |
| 1 | `armorer` |
| 2 | `butcher` |
| 3 | `cartographer` |
| 4 | `cleric` |
| 5 | `farmer` |
| 6 | `fisherman` |
| 7 | `fletcher` |
| 8 | `leatherworker` |
| 9 | `librarian` |
| 10 | `mason` |
| 11 | `nitwit` |
| 12 | `shepherd` |
| 13 | `toolsmith` |
| 14 | `weaponsmith` |

The metadata serializer VILLAGER_DATA (00 §13.2 id 18) carries the type id, then the profession id, then the level.
Professions and point of interest types are separate registries with separate ids. `nitwit` has no point of interest type
(its registration passes the empty-type predicate `PoiType.NONE` for both predicates); the point of interest list also has
`home`, `meeting`, `beehive` and others that are not professions.

### 6.3 Point of interest types (`point_of_interest_type`, 21 entries, `PoiTypes.bootstrap`)

Ids appear in Update Tags (3 point of interest tags in the data pack) and, as a holder id, in the clientbound `DebugPoiInfo` payload (section 3). Bootstrap order, which differs from the order of
the key fields at ids 19 and 20 (section 2.3).

| Id | Key |
|---|---|
| 0 | `armorer` |
| 1 | `butcher` |
| 2 | `cartographer` |
| 3 | `cleric` |
| 4 | `farmer` |
| 5 | `fisherman` |
| 6 | `fletcher` |
| 7 | `leatherworker` |
| 8 | `librarian` |
| 9 | `mason` |
| 10 | `shepherd` |
| 11 | `toolsmith` |
| 12 | `weaponsmith` |
| 13 | `home` |
| 14 | `meeting` |
| 15 | `beehive` |
| 16 | `bee_nest` |
| 17 | `nether_portal` |
| 18 | `lodestone` |
| 19 | `test_instance` |
| 20 | `lightning_rod` |

## 7. Statistics

`Stats` registers two registries from one static initialiser: the 9 stat types first (by `makeRegistryStatType`), then the 78
custom stats (by `makeCustomStat`). The Stat composite of 05a (used by Award Statistics) is a VarInt stat type id followed by a VarInt id in the
registry that the stat type ranges over.

| Stat type id | Key | Ranges over (the registry passed to `makeRegistryStatType`) |
|---|---|---|
| 0 | `mined` | `block` (24) |
| 1 | `crafted` | `item` (25) |
| 2 | `used` | `item` |
| 3 | `broken` | `item` |
| 4 | `picked_up` | `item` |
| 5 | `dropped` | `item` |
| 6 | `killed` | `entity_type` (section 11) |
| 7 | `killed_by` | `entity_type` |
| 8 | `custom` | `custom_stat` (table below) |

Custom stat ids (`custom_stat`, 78 entries). Each is a plain Identifier registered with a number formatter. The key `sneak_time`
is the one registered for the constant named `CROUCH_TIME`; the registered name is always the first string.

| Id | Key | Id | Key | Id | Key |
|---|---|---|---|---|---|
| 0 | `leave_game` | 26 | `damage_dealt_absorbed` | 52 | `pot_flower` |
| 1 | `play_time` | 27 | `damage_dealt_resisted` | 53 | `trigger_trapped_chest` |
| 2 | `total_world_time` | 28 | `damage_taken` | 54 | `open_enderchest` |
| 3 | `time_since_death` | 29 | `damage_blocked_by_shield` | 55 | `enchant_item` |
| 4 | `time_since_rest` | 30 | `damage_absorbed` | 56 | `play_record` |
| 5 | `sneak_time` | 31 | `damage_resisted` | 57 | `interact_with_furnace` |
| 6 | `walk_one_cm` | 32 | `deaths` | 58 | `interact_with_crafting_table` |
| 7 | `crouch_one_cm` | 33 | `mob_kills` | 59 | `open_chest` |
| 8 | `sprint_one_cm` | 34 | `animals_bred` | 60 | `sleep_in_bed` |
| 9 | `walk_on_water_one_cm` | 35 | `player_kills` | 61 | `sleep_in_straw_bed` |
| 10 | `fall_one_cm` | 36 | `fish_caught` | 62 | `open_shulker_box` |
| 11 | `climb_one_cm` | 37 | `talked_to_villager` | 63 | `open_barrel` |
| 12 | `fly_one_cm` | 38 | `traded_with_villager` | 64 | `interact_with_blast_furnace` |
| 13 | `walk_under_water_one_cm` | 39 | `eat_cake_slice` | 65 | `interact_with_smoker` |
| 14 | `minecart_one_cm` | 40 | `fill_cauldron` | 66 | `interact_with_lectern` |
| 15 | `boat_one_cm` | 41 | `use_cauldron` | 67 | `interact_with_campfire` |
| 16 | `pig_one_cm` | 42 | `clean_armor` | 68 | `interact_with_cartography_table` |
| 17 | `happy_ghast_one_cm` | 43 | `clean_banner` | 69 | `interact_with_loom` |
| 18 | `horse_one_cm` | 44 | `clean_shulker_box` | 70 | `interact_with_stonecutter` |
| 19 | `aviate_one_cm` | 45 | `interact_with_brewingstand` | 71 | `bell_ring` |
| 20 | `swim_one_cm` | 46 | `interact_with_beacon` | 72 | `raid_trigger` |
| 21 | `strider_one_cm` | 47 | `inspect_dropper` | 73 | `raid_win` |
| 22 | `nautilus_one_cm` | 48 | `inspect_hopper` | 74 | `interact_with_anvil` |
| 23 | `jump` | 49 | `inspect_dispenser` | 75 | `interact_with_grindstone` |
| 24 | `drop` | 50 | `play_noteblock` | 76 | `target_hit` |
| 25 | `damage_dealt` | 51 | `tune_noteblock` | 77 | `interact_with_smithing_table` |

## 8. Items and UI

### 8.1 Data component types (`data_component_type`, 122 entries, `DataComponents` pattern A)

The id is the VarInt that precedes each entry of a component patch (00 §12.2). The table is complete (17 §1.2 lists 43 ids of the 122: 42 table rows, one of which merges ids 53 and 54).
All 43 ids of 17's table were compared by name and id: no difference. Keys that contain `/` are real keys
(`minecraft:wolf/variant`). The registry is created without a default.

| Id | Key | Id | Key | Id | Key |
|---|---|---|---|---|---|
| 0 | `custom_data` | 41 | `interact_animation` | 82 | `container_loot` |
| 1 | `max_stack_size` | 42 | `additional_trade_cost` | 83 | `break_sound` |
| 2 | `max_damage` | 43 | `block_transformer` | 84 | `compostable` |
| 3 | `damage` | 44 | `villager_food` | 85 | `cooking_fuel` |
| 4 | `unbreakable` | 45 | `stored_enchantments` | 86 | `brewing_fuel` |
| 5 | `use_effects` | 46 | `dye` | 87 | `mob_visibility` |
| 6 | `custom_name` | 47 | `dyed_color` | 88 | `villager/variant` |
| 7 | `minimum_attack_charge` | 48 | `map_id` | 89 | `wolf/variant` |
| 8 | `damage_type` | 49 | `map_decorations` | 90 | `wolf/sound_variant` |
| 9 | `item_name` | 50 | `map_post_processing` | 91 | `wolf/collar` |
| 10 | `item_model` | 51 | `charged_projectiles` | 92 | `fox/variant` |
| 11 | `lore` | 52 | `bundle_contents` | 93 | `salmon/size` |
| 12 | `rarity` | 53 | `potion_contents` | 94 | `parrot/variant` |
| 13 | `enchantments` | 54 | `potion_duration_scale` | 95 | `tropical_fish/pattern` |
| 14 | `can_place_on` | 55 | `suspicious_stew_effects` | 96 | `tropical_fish/base_color` |
| 15 | `can_break` | 56 | `writable_book_content` | 97 | `tropical_fish/pattern_color` |
| 16 | `attribute_modifiers` | 57 | `written_book_content` | 98 | `mooshroom/variant` |
| 17 | `custom_model_data` | 58 | `trim` | 99 | `rabbit/variant` |
| 18 | `tooltip_display` | 59 | `debug_stick_state` | 100 | `pig/variant` |
| 19 | `repair_cost` | 60 | `entity_data` | 101 | `pig/sound_variant` |
| 20 | `creative_slot_lock` | 61 | `bucket_entity_data` | 102 | `cow/variant` |
| 21 | `enchantment_glint_override` | 62 | `block_entity_data` | 103 | `cow/sound_variant` |
| 22 | `intangible_projectile` | 63 | `instrument` | 104 | `chicken/variant` |
| 23 | `food` | 64 | `provides_trim_material` | 105 | `chicken/sound_variant` |
| 24 | `consumable` | 65 | `ominous_bottle_amplifier` | 106 | `zombie_nautilus/variant` |
| 25 | `use_remainder` | 66 | `jukebox_playable` | 107 | `frog/variant` |
| 26 | `use_cooldown` | 67 | `provides_banner_patterns` | 108 | `horse/variant` |
| 27 | `damage_resistant` | 68 | `recipes` | 109 | `painting/variant` |
| 28 | `tool` | 69 | `lodestone_tracker` | 110 | `llama/variant` |
| 29 | `weapon` | 70 | `firework_explosion` | 111 | `axolotl/variant` |
| 30 | `attack_range` | 71 | `fireworks` | 112 | `cat/variant` |
| 31 | `enchantable` | 72 | `profile` | 113 | `cat/sound_variant` |
| 32 | `equippable` | 73 | `note_block_sound` | 114 | `cat/collar` |
| 33 | `repairable` | 74 | `banner_patterns` | 115 | `sheep/color` |
| 34 | `glider` | 75 | `base_color` | 116 | `shulker/color` |
| 35 | `tooltip_style` | 76 | `pot_decorations` | 117 | `provides_pottery_pattern` |
| 36 | `death_protection` | 77 | `container` | 118 | `sign_text_front` |
| 37 | `blocks_attacks` | 78 | `block_state` | 119 | `sign_text_back` |
| 38 | `piercing_weapon` | 79 | `bees` | 120 | `waxed` |
| 39 | `kinetic_weapon` | 80 | `sulfur_cube_content` | 121 | `cushion/color` |
| 40 | `attack_animation` | 81 | `lock` |  |  |

### 8.2 Consume effect types (`consume_effect_type`, 5 entries, nested class `ConsumeEffect$Type` pattern A)

Used inside the `consumable` component's effect list (VarInt type id, then the type's own fields).

| Id | Key |
|---|---|
| 0 | `apply_effects` |
| 1 | `remove_effects` |
| 2 | `clear_all_effects` |
| 3 | `teleport_randomly` |
| 4 | `play_sound` |

### 8.3 Number format types (`number_format_type`, 3 entries, `NumberFormatTypes.bootstrap`)

This confirms the inferred ids in 05b ("blank 0, styled 1, fixed 2").

| Id | Key |
|---|---|
| 0 | `blank` |
| 1 | `styled` |
| 2 | `fixed` |

### 8.4 Data component predicate types (`data_component_predicate_type`, 15 entries, `DataComponentPredicates` pattern A)

Registered by `DataComponentPredicates.<clinit>` in this order (15 register calls, ids contiguous from 0):

| Id | Key | Id | Key | Id | Key |
|---|---|---|---|---|---|
| 0 | `damage` | 5 | `container` | 10 | `written_book_content` |
| 1 | `enchantments` | 6 | `bundle_contents` | 11 | `attribute_modifiers` |
| 2 | `stored_enchantments` | 7 | `firework_explosion` | 12 | `trim` |
| 3 | `potion_contents` | 8 | `fireworks` | 13 | `jukebox_playable` |
| 4 | `custom_data` | 9 | `writable_book_content` | 14 | `villager/variant` |

Wire form (`DataComponentPredicate$Type.STREAM_CODEC`): `ByteBufCodecs.either` of two registry-id codecs. The Either codec reads one Boolean
(`ByteBufCodecs$29.decode`): true selects the left codec, false the right. The left codec is `ByteBufCodecs.registry(DATA_COMPONENT_PREDICATE_TYPE)`
(this table), the right is `ByteBufCodecs.registry(DATA_COMPONENT_TYPE)` (section 8.1). So a type is: Boolean true then a VarInt id from this
table, or Boolean false then a VarInt id from the component type table. (`unpackType` puts a type of the any-value class on the right side and
every other type on the left.) The path to the wire: `DataComponentPredicate$Type.STREAM_CODEC`, used by `DataComponentPredicate.STREAM_CODEC`,
then `DataComponentMatchers.STREAM_CODEC`, then `BlockPredicate.STREAM_CODEC`, then `AdventureModePredicate.STREAM_CODEC`, which is the codec
behind the `can_place_on` and `can_break` item components (ids 14 and 15 in 8.1). The payload that follows the type id is not read in this round
(Open question 12).

Worked example: the predicate type `enchantments` on the wire is `01 01` (Boolean true, VarInt 1); a component type test on `custom_name`
(component id 6) is `00 06`.

## 9. Recipes

### 9.1 Recipe display types (`recipe_display`, 5 entries, `RecipeDisplays.bootstrap`)

Confirms 05a and 05b (no difference).

| Id | Key |
|---|---|
| 0 | `crafting_shapeless` |
| 1 | `crafting_shaped` |
| 2 | `furnace` |
| 3 | `stonecutter` |
| 4 | `smithing` |

### 9.2 Slot display types (`slot_display`, 11 entries, `SlotDisplays.bootstrap`)

05a and 05b both list all 11 entries, ids 0 to 10, and both match the artifact (checked in this round: both 05a and 05b list all 11 and match the artifact).

| Id | Key |
|---|---|
| 0 | `empty` |
| 1 | `any_fuel` |
| 2 | `with_any_potion` |
| 3 | `only_with_component` |
| 4 | `item` |
| 5 | `item_stack` |
| 6 | `tag` |
| 7 | `dyed` |
| 8 | `smithing_trim` |
| 9 | `with_remainder` |
| 10 | `composite` |

### 9.3 Recipe book categories (`recipe_book_category`, 13 entries, `RecipeBookCategories` pattern A)

| Id | Key |
|---|---|
| 0 | `crafting_building_blocks` |
| 1 | `crafting_redstone` |
| 2 | `crafting_equipment` |
| 3 | `crafting_misc` |
| 4 | `furnace_food` |
| 5 | `furnace_blocks` |
| 6 | `furnace_misc` |
| 7 | `blast_furnace_blocks` |
| 8 | `blast_furnace_misc` |
| 9 | `smoker_food` |
| 10 | `stonecutter` |
| 11 | `smithing` |
| 12 | `campfire` |

### 9.4 Recipe types (`recipe_type`, 8 entries, `RecipeType` pattern A)

Not sent in a packet read. They appear in data (recipe JSON uses the serializer key, section 9.5).

| Id | Key |
|---|---|
| 0 | `crafting` |
| 1 | `smelting` |
| 2 | `blasting` |
| 3 | `smoking` |
| 4 | `campfire_cooking` |
| 5 | `stonecutting` |
| 6 | `smithing` |
| 7 | `brewing` |

### 9.5 Recipe serializers (`recipe_serializer`, 22 entries, `RecipeSerializers.bootstrap`)

The `type` string of a recipe file. Not sent as a number in a packet read. Evidence: `Recipe.STREAM_CODEC` does dispatch on `ByteBufCodecs.registry(RECIPE_SERIALIZER)`, a registry-id codec, so these ids would be on the wire if that codec were used; a scan of the classes of the jar that mention `crafting/Recipe` found `RecipeHolder` as the only class that reads `Recipe.STREAM_CODEC`, and no packet document lists it. An implementer must use the numbering below if a packet ever carries it.

| Id | Key |
|---|---|
| 0 | `crafting_shaped` |
| 1 | `crafting_shapeless` |
| 2 | `crafting_dye` |
| 3 | `crafting_imbue` |
| 4 | `crafting_transmute` |
| 5 | `crafting_decorated_pot` |
| 6 | `crafting_special_bookcloning` |
| 7 | `crafting_special_mapextending` |
| 8 | `crafting_special_firework_rocket` |
| 9 | `crafting_special_firework_star` |
| 10 | `crafting_special_firework_star_fade` |
| 11 | `crafting_special_bannerduplicate` |
| 12 | `crafting_special_shielddecoration` |
| 13 | `crafting_special_repairitem` |
| 14 | `smelting` |
| 15 | `blasting` |
| 16 | `smoking` |
| 17 | `campfire_cooking` |
| 18 | `stonecutting` |
| 19 | `smithing_transform` |
| 20 | `brewing` |
| 21 | `smithing_trim` |

## 10. Commands: argument types

`command_argument_type`, 62 entries, `ArgumentTypeInfos.bootstrap`. Property layouts are in 05a and 15; the id to key list
matches 05a's table row for row (compared in this round: 62 of 62). The bootstrap method is a straight sequence of 62 register calls
with no jump instruction, so the ids are fixed for this version.

| Id | Key | Id | Key |
|---|---|---|---|
| 0 | `brigadier:bool` | 31 | `score_holder` |
| 1 | `brigadier:float` | 32 | `swizzle` |
| 2 | `brigadier:double` | 33 | `team` |
| 3 | `brigadier:integer` | 34 | `item_slot` |
| 4 | `brigadier:long` | 35 | `item_slots` |
| 5 | `brigadier:string` | 36 | `resource_location` |
| 6 | `entity` | 37 | `function` |
| 7 | `game_profile` | 38 | `entity_anchor` |
| 8 | `block_pos` | 39 | `int_range` |
| 9 | `column_pos` | 40 | `float_range` |
| 10 | `vec3` | 41 | `dimension` |
| 11 | `vec2` | 42 | `gamemode` |
| 12 | `block_state` | 43 | `time` |
| 13 | `block_predicate` | 44 | `resource_or_tag` |
| 14 | `item_stack` | 45 | `resource_or_tag_key` |
| 15 | `item_predicate` | 46 | `resource` |
| 16 | `team_color` | 47 | `resource_key` |
| 17 | `hex_color` | 48 | `resource_selector` |
| 18 | `component` | 49 | `template_mirror` |
| 19 | `style` | 50 | `template_rotation` |
| 20 | `message` | 51 | `heightmap` |
| 21 | `nbt_compound_tag` | 52 | `loot_table` |
| 22 | `nbt_tag` | 53 | `loot_predicate` |
| 23 | `nbt_path` | 54 | `loot_modifier` |
| 24 | `objective` | 55 | `context_float_provider` |
| 25 | `objective_criteria` | 56 | `context_int_provider` |
| 26 | `operation` | 57 | `slot_source` |
| 27 | `particle` | 58 | `dialog` |
| 28 | `angle` | 59 | `feature` |
| 29 | `rotation` | 60 | `swing_animation` |
| 30 | `scoreboard_slot` | 61 | `uuid` |

## 11. Entity types: verification of 21 §2

- Registry: `entity_type`, `registerDefaultedWithIntrusiveHolders` (default key `pig`), 161 entries; `EntityTypes`, pattern B.
  The keys come from `EntityTypeIds` (161 constants), each `ResourceKey` built from the plain lower-case name; each
  of the 161 `register(key, builder)` calls in `EntityTypes.<clinit>` stores the registered type in the field of the same
  name.
- **Result of the check:** all 161 rows of 21 §2 (ids 0 to 160, key, in order) equal the registration order read here. Zero
  differences. Documents 19 and 20 say their entity ids are the registration order of `EntityTypes` (inferred there); that is the order
  confirmed here, and 21 §2 is the table to use. The 68 mob rows with an entity id in 19 (36) and 20 (32) were compared with 21 §2 afterwards: zero differences.
- **Order rule.** The 155 types other than the six below are in ascending ASCII order of their constant names (upper case letters, `_`
  compared as the character 0x5F, which sorts after every letter): for example `ENDERMITE` 43, `ENDER_DRAGON` 44, `ENDER_PEARL` 45, `END_CRYSTAL` 46.
  (Verified mechanically: the list with the six removed equals its own sorted copy.) Six types are not at their sorted position, so sorting alone gets
  them wrong. Copy the table of 21 §2 instead of sorting.

| Id | Key | Where sorting by constant name would put it |
|---|---|---|
| 28 | `copper_golem` | after `command_block_minecart`, before `cow`. Actual neighbours: `cod` (27) and `command_block_minecart` (29) |
| 59 | `happy_ghast` | between `guardian` and `hoglin` (it follows `ghast` here). Actual neighbours: `ghast` (58) and `giant` (60) |
| 108 | `splash_potion` | between `spider` and `spruce_boat`. Actual neighbours: `poplar_chest_boat` (107) and `lingering_potion` (109) |
| 109 | `lingering_potion` | between `lightning_bolt` and `llama`. Actual neighbours: `splash_potion` (108) and `pufferfish` (110) |
| 159 | `player` | between `pillager` and `polar_bear`. Actual neighbours: `zombified_piglin` (158) and `fishing_bobber` (160) |
| 160 | `fishing_bobber` | between `firework_rocket` and `fox`. Actual neighbours: `player` (159) and nothing (last entry) |

- Notable ids: `pig` 101 (the default entry), `item` 72, `player` 159, `fishing_bobber` 160 (the last two entries; `splash_potion` and
  `lingering_potion` sit between `poplar_chest_boat` and `pufferfish`).
- The set `OP_ONLY_CUSTOM_DATA` (`falling_block`, `command_block_minecart`, `spawner_minecart`) is not a registry.

## 12. Entity metadata: serializers and id enums

### 12.1 Serializers

The 44 serializers of 00 §13.2 were read again from `EntityDataSerializers.<clinit>` (the 44 `registerSerializer` calls, in order). The
44 names and their order are identical to the table of 00 §13.2 (0 BYTE, 1 INT, ..., 43 DYE_COLOR; compared name by name). The
sequential allocation that 00 inferred is confirmed by reading `CrudeIncrementalIntIdentityHashBiMap.add` (section 2.6). No change to 00.

### 12.2 Id enums used by those serializers

Each serializer is `EntityDataSerializer.forValueType(<Enum>.STREAM_CODEC)`. The stream codec is `ByteBufCodecs.idMapper(byId, getId)`. `byId` is
`ByIdMap.continuous(idFunction, values(), strategy)`: an array indexed by id, with the out-of-range strategy below (it decides what an
id that is not in the array decodes to). The id function is the enum's own `id` field, or `ordinal` (`WeatherState`). The values below are
the `id` read from each enum constant's constructor (for `Direction` the `data3d` field).

| Enum (serializer id) | Out-of-range strategy | Id to constant |
|---|---|---|
| `Direction` (12) | WRAP | 0 down, 1 up, 2 north, 3 south, 4 west, 5 east |
| `Pose` (20) | ZERO | 0 standing, 1 fall_flying, 2 sleeping, 3 swimming, 4 spin_attack, 5 crouching, 6 long_jumping, 7 dying, 8 croaking, 9 using_tongue, 10 sitting, 11 roaring, 12 sniffing, 13 emerging, 14 digging, 15 sliding, 16 shooting, 17 inhaling |
| `Sniffer.State` (35) | ZERO | 0 idling, 1 feeling_happy, 2 scenting, 3 sniffing, 4 searching, 5 digging, 6 rising |
| `Armadillo.ArmadilloState` (36) | ZERO | 0 idle, 1 rolling, 2 scared, 3 unrolling |
| `CopperGolemState` (37) | ZERO | 0 idle, 1 getting_item, 2 getting_no_item, 3 dropping_item, 4 dropping_no_item |
| `WeatheringCopper.WeatherState` (38) | CLAMP | by ordinal: 0 unaffected, 1 exposed, 2 weathered, 3 oxidized |
| `HumanoidArm` (42) | ZERO | 0 left, 1 right |
| `DyeColor` (43) | ZERO | 0 white, 1 orange, 2 magenta, 3 light_blue, 4 yellow, 5 lime, 6 pink, 7 gray, 8 light_gray, 9 cyan, 10 purple, 11 blue, 12 brown, 13 green, 14 red, 15 black |

Out-of-range ids (below 0, or at or above the number of constants), read in `ByIdMap.continuous`: ZERO returns the constant at array index 0
(the first); WRAP returns the constant at index `positiveModulo(id, length)`; CLAMP returns the constant at index `clamp(id, 0, length - 1)`. Names
are the lower-case serialized names read from the constants, except `Sniffer.State`, which has no serialized-name string (only the constant names IDLING, FEELING_HAPPY, SCENTING, SNIFFING, SEARCHING, DIGGING, RISING): its names are the lowercased constant names (inferred). For `Armadillo.ArmadilloState` and `CopperGolemState` the id is the last constructor
argument (the `id` field, read in the constructor of the first); the printed values equal the ordinals.

Also read: `SwingAnimationType` (used in the `swing_animation` command argument and the `attack_animation` component) has ids 0 `none`, 1 `whack`, 2 `stab`, with the
id read from the constant and the stream codec built on `getId` (this answers 05b Open question 4: ids equal the ordinals).

## 13. Enchantment families, debug subscriptions, position sources

### 13.1 Enchantment-related registries

None of these is referenced by number in a packet read: enchantment data reaches the client in the synchronized `enchantment` registry (04 §6), whose entries refer to these registries by key
string (the name codecs of section 2.5; the exact field names are 04 §6's). They are tabulated because the order is code and the data tool needs
the set of valid keys. Order is the registration order (ids are internal).

Enchantment effect component types (`enchantment_effect_component_type`, 31 entries, `EnchantmentEffectComponents` pattern A):

| Id | Key | Id | Key |
|---|---|---|---|
| 0 | `damage_protection` | 16 | `projectile_spread` |
| 1 | `damage_immunity` | 17 | `projectile_count` |
| 2 | `damage` | 18 | `trident_return_acceleration` |
| 3 | `smash_damage_per_fallen_block` | 19 | `fishing_time_reduction` |
| 4 | `knockback` | 20 | `fishing_luck_bonus` |
| 5 | `armor_effectiveness` | 21 | `block_experience` |
| 6 | `post_attack` | 22 | `mob_experience` |
| 7 | `post_piercing_attack` | 23 | `repair_with_xp` |
| 8 | `hit_block` | 24 | `attributes` |
| 9 | `item_damage` | 25 | `crossbow_charge_time` |
| 10 | `equipment_drops` | 26 | `crossbow_charging_sounds` |
| 11 | `location_changed` | 27 | `trident_sound` |
| 12 | `tick` | 28 | `prevent_equipment_drop` |
| 13 | `ammo_use` | 29 | `prevent_armor_change` |
| 14 | `projectile_piercing` | 30 | `trident_spin_attack_strength` |
| 15 | `projectile_spawned` |  |  |

Level based values (`enchantment_level_based_value_type`, 6, `LevelBasedValue.bootstrap`):

| Id | Key |
|---|---|
| 0 | `clamped` |
| 1 | `fraction` |
| 2 | `levels_squared` |
| 3 | `linear` |
| 4 | `exponent` |
| 5 | `lookup` |

Entity effects (`enchantment_entity_effect_type`, 15, `EnchantmentEntityEffect.bootstrap`):

| Id | Key |
|---|---|
| 0 | `all_of` |
| 1 | `apply_mob_effect` |
| 2 | `change_item_damage` |
| 3 | `damage_entity` |
| 4 | `explode` |
| 5 | `ignite` |
| 6 | `apply_impulse` |
| 7 | `apply_exhaustion` |
| 8 | `play_sound` |
| 9 | `replace_block` |
| 10 | `replace_disk` |
| 11 | `run_function` |
| 12 | `set_block_properties` |
| 13 | `spawn_particles` |
| 14 | `summon_entity` |

Location based effects (`enchantment_location_based_effect_type`, 16, `EnchantmentLocationBasedEffect.bootstrap`): same names as the entity effects with
`attribute` inserted at id 2 (the first read of that pair differs by this one entry).

| Id | Key |
|---|---|
| 0 | `all_of` |
| 1 | `apply_mob_effect` |
| 2 | `attribute` |
| 3 | `change_item_damage` |
| 4 | `damage_entity` |
| 5 | `explode` |
| 6 | `ignite` |
| 7 | `apply_impulse` |
| 8 | `apply_exhaustion` |
| 9 | `play_sound` |
| 10 | `replace_block` |
| 11 | `replace_disk` |
| 12 | `run_function` |
| 13 | `set_block_properties` |
| 14 | `spawn_particles` |
| 15 | `summon_entity` |

Value effects (`enchantment_value_effect_type`, 6, `EnchantmentValueEffect.bootstrap`):

| Id | Key |
|---|---|
| 0 | `add` |
| 1 | `all_of` |
| 2 | `multiply` |
| 3 | `remove_binomial` |
| 4 | `exponential` |
| 5 | `set` |

Enchantment provider types (`enchantment_provider_type`, 3, `EnchantmentProviderTypes.bootstrap`):

| Id | Key |
|---|---|
| 0 | `by_cost` |
| 1 | `by_cost_with_difficulty` |
| 2 | `single` |

### 13.2 Debug subscriptions (`debug_subscription`, 16 entries, `DebugSubscriptions` pattern A)

Used by Serverbound Debug Subscription Request (05c 0x17: up to 32 ids) and by the clientbound debug packets (05a).

| Id | Key |
|---|---|
| 0 | `dedicated_server_tick_time` |
| 1 | `bees` |
| 2 | `brains` |
| 3 | `breezes` |
| 4 | `goal_selectors` |
| 5 | `entity_paths` |
| 6 | `entity_block_intersections` |
| 7 | `bee_hives` |
| 8 | `pois` |
| 9 | `redstone_wire_orientations` |
| 10 | `village_sections` |
| 11 | `raids` |
| 12 | `structures` |
| 13 | `game_event_listeners` |
| 14 | `neighbor_updates` |
| 15 | `game_events` |

### 13.3 Position source types (`position_source_type`, 2 entries, `PositionSourceType` pattern A)

Confirms 05a ("0 = block and 1 = entity").

| Id | Key |
|---|---|
| 0 | `block` |
| 1 | `entity` |

## 14. Sound events

### 14.1 Wire form

A sound is `Holder<sound_event>` (05b Sound 0x77, Sound Entity 0x76, Explode in 05a, and the sound fields of item components): VarInt 0
followed by an inline sound event (an Identifier and an optional fixed range, see 05b composite types), or the id plus 1. **A server never needs the
table of this section**: an inline sound names the sound by Identifier and is always allowed by the codec shape (04 §4: the holder-or-inline rule). The
table is for a server that wants the compact form, and for tools that resolve a reference written by a vanilla server. Stop Sound (05b 0x79)
uses an Identifier, not an id. (Whether the client accepts an inline sound whose Identifier it does not know is not read here: Open question 6.)

### 14.2 How the ids are built

`SoundEvents.<clinit>` registers, in order, 1991 sound events:

- 1897 single registrations. 1682 call `register(String)` and 215 call `registerForHolder(String)`. Both helpers build the key with
  `Identifier.withDefaultNamespace(name)` and register into `sound_event`, so both count the same way. The name is the dotted string constant of the call
  (for example `entity.allay.ambient_with_item`), in the order of the statements.
- Six generated groups, inserted at six points of the same initialiser, each a loop over a small set (read from the generating methods):

| Group | Inserted after | First id | Count | Names |
|---|---|---|---|---|
| cat sound variants | `entity.baby_cat.purreow` | 288 | 18 | for each set in (`cat`, `cat_royal`), in that order: `entity.<set>.` + `ambient`, `stray_ambient`, `hiss`, `hurt`, `death`, `eat`, `beg_for_food`, `purr`, `purreow` |
| chicken sound variants | `entity.baby_chicken.step` | 356 | 6 | for each set in (`chicken`, `chicken_picky`): `ambient`, `hurt`, `death` |
| cow sound variants | `entity.cow.milk` | 450 | 8 | for each set in (`cow`, `cow_moody`): `ambient`, `hurt`, `death`, `step` |
| goat horn variants | `item.honey_bottle.drink` | 845 | 8 | `item.goat_horn.sound.0` to `item.goat_horn.sound.7` (loop of 8) |
| pig sound variants | `entity.baby_pig.death` | 1272 | 12 | for each set in (`pig`, `pig_mini`, `pig_big`): `ambient`, `hurt`, `death`, `eat` |
| wolf sound variants | `entity.baby_wolf.whine` | 1807 | 42 | for each set in (`wolf`, `wolf_puglin`, `wolf_sad`, `wolf_angry`, `wolf_grumpy`, `wolf_big`, `wolf_cute`): `ambient`, `death`, `growl`, `hurt`, `pant`, `whine` |

  The set names are the `soundEventIdentifier` strings of the `SoundSet` enums (`classic` -> `cat`, `royal` -> `cat_royal`, and so on), taken
  in the enum constant order; each name is the template `entity.` + set + `.` + suffix (read from the `makeConcatWithConstants` recipes of the
  generating lambdas). The suffix order is the order of the `registerForHolder` calls in each lambda.
- No name is registered twice (checked: the 1991 names are distinct).

The 1991 names are listed in section 14.3 with the group names at their ids.

### 14.3 Table (`sound_event`, 1991 entries)

| Id | Key | Id | Key | Id | Key |
|---|---|---|---|---|---|
| 0 | `entity.allay.ambient_with_item` | 664 | `block.suspicious_sand.step` | 1328 | `entity.polar_bear.ambient_baby` |
| 1 | `entity.allay.ambient_without_item` | 665 | `block.suspicious_sand.place` | 1329 | `entity.polar_bear.death` |
| 2 | `entity.allay.death` | 666 | `block.suspicious_sand.hit` | 1330 | `entity.polar_bear.hurt` |
| 3 | `entity.allay.hurt` | 667 | `block.suspicious_sand.fall` | 1331 | `entity.polar_bear.step` |
| 4 | `entity.allay.item_given` | 668 | `block.suspicious_gravel.break` | 1332 | `entity.polar_bear.warning` |
| 5 | `entity.allay.item_taken` | 669 | `block.suspicious_gravel.step` | 1333 | `block.polished_deepslate.break` |
| 6 | `entity.allay.item_thrown` | 670 | `block.suspicious_gravel.place` | 1334 | `block.polished_deepslate.fall` |
| 7 | `ambient.cave` | 671 | `block.suspicious_gravel.hit` | 1335 | `block.polished_deepslate.hit` |
| 8 | `ambient.basalt_deltas.additions` | 672 | `block.suspicious_gravel.fall` | 1336 | `block.polished_deepslate.place` |
| 9 | `ambient.basalt_deltas.loop` | 673 | `block.froglight.break` | 1337 | `block.polished_deepslate.step` |
| 10 | `ambient.basalt_deltas.mood` | 674 | `block.froglight.fall` | 1338 | `block.portal.ambient` |
| 11 | `ambient.crimson_forest.additions` | 675 | `block.froglight.hit` | 1339 | `block.portal.travel` |
| 12 | `ambient.crimson_forest.loop` | 676 | `block.froglight.place` | 1340 | `block.portal.trigger` |
| 13 | `ambient.crimson_forest.mood` | 677 | `block.froglight.step` | 1341 | `block.powder_snow.break` |
| 14 | `ambient.nether_wastes.additions` | 678 | `block.frogspawn.step` | 1342 | `block.powder_snow.fall` |
| 15 | `ambient.nether_wastes.loop` | 679 | `block.frogspawn.break` | 1343 | `block.powder_snow.hit` |
| 16 | `ambient.nether_wastes.mood` | 680 | `block.frogspawn.fall` | 1344 | `block.powder_snow.place` |
| 17 | `ambient.soul_sand_valley.additions` | 681 | `block.frogspawn.hatch` | 1345 | `block.powder_snow.step` |
| 18 | `ambient.soul_sand_valley.loop` | 682 | `block.frogspawn.hit` | 1346 | `entity.puffer_fish.blow_out` |
| 19 | `ambient.soul_sand_valley.mood` | 683 | `block.frogspawn.place` | 1347 | `entity.puffer_fish.blow_up` |
| 20 | `ambient.warped_forest.additions` | 684 | `entity.frog.ambient` | 1348 | `entity.puffer_fish.death` |
| 21 | `ambient.warped_forest.loop` | 685 | `entity.frog.death` | 1349 | `entity.puffer_fish.flop` |
| 22 | `ambient.warped_forest.mood` | 686 | `entity.frog.eat` | 1350 | `entity.puffer_fish.hurt` |
| 23 | `ambient.underwater.enter` | 687 | `entity.frog.hurt` | 1351 | `entity.puffer_fish.sting` |
| 24 | `ambient.underwater.exit` | 688 | `entity.frog.lay_spawn` | 1352 | `block.pumpkin.carve` |
| 25 | `ambient.underwater.loop` | 689 | `entity.frog.long_jump` | 1353 | `entity.rabbit.ambient` |
| 26 | `ambient.underwater.loop.additions` | 690 | `entity.frog.step` | 1354 | `entity.rabbit.attack` |
| 27 | `ambient.underwater.loop.additions.rare` | 691 | `entity.frog.tongue` | 1355 | `entity.rabbit.death` |
| 28 | `ambient.underwater.loop.additions.ultra_rare` | 692 | `block.roots.break` | 1356 | `entity.rabbit.hurt` |
| 29 | `block.amethyst_block.break` | 693 | `block.roots.step` | 1357 | `entity.rabbit.jump` |
| 30 | `block.amethyst_block.chime` | 694 | `block.roots.place` | 1358 | `event.raid.horn` |
| 31 | `block.amethyst_block.fall` | 695 | `block.roots.hit` | 1359 | `entity.ravager.ambient` |
| 32 | `block.amethyst_block.hit` | 696 | `block.roots.fall` | 1360 | `entity.ravager.attack` |
| 33 | `block.amethyst_block.place` | 697 | `block.furnace.fire_crackle` | 1361 | `entity.ravager.celebrate` |
| 34 | `block.amethyst_block.resonate` | 698 | `entity.generic.big_fall` | 1362 | `entity.ravager.death` |
| 35 | `block.amethyst_block.step` | 699 | `entity.generic.burn` | 1363 | `entity.ravager.hurt` |
| 36 | `block.amethyst_cluster.break` | 700 | `entity.generic.death` | 1364 | `entity.ravager.step` |
| 37 | `block.amethyst_cluster.fall` | 701 | `entity.generic.drink` | 1365 | `entity.ravager.stunned` |
| 38 | `block.amethyst_cluster.hit` | 702 | `entity.generic.eat` | 1366 | `entity.ravager.roar` |
| 39 | `block.amethyst_cluster.place` | 703 | `entity.generic.explode` | 1367 | `block.nether_gold_ore.break` |
| 40 | `block.amethyst_cluster.step` | 704 | `entity.generic.extinguish_fire` | 1368 | `block.nether_gold_ore.fall` |
| 41 | `block.ancient_debris.break` | 705 | `entity.generic.hurt` | 1369 | `block.nether_gold_ore.hit` |
| 42 | `block.ancient_debris.step` | 706 | `entity.generic.small_fall` | 1370 | `block.nether_gold_ore.place` |
| 43 | `block.ancient_debris.place` | 707 | `entity.generic.splash` | 1371 | `block.nether_gold_ore.step` |
| 44 | `block.ancient_debris.hit` | 708 | `entity.generic.swim` | 1372 | `block.nether_ore.break` |
| 45 | `block.ancient_debris.fall` | 709 | `entity.ghast.ambient` | 1373 | `block.nether_ore.fall` |
| 46 | `block.anvil.break` | 710 | `entity.ghast.death` | 1374 | `block.nether_ore.hit` |
| 47 | `block.anvil.destroy` | 711 | `entity.ghast.hurt` | 1375 | `block.nether_ore.place` |
| 48 | `block.anvil.fall` | 712 | `entity.ghast.scream` | 1376 | `block.nether_ore.step` |
| 49 | `block.anvil.hit` | 713 | `entity.ghast.shoot` | 1377 | `block.redstone_torch.burnout` |
| 50 | `block.anvil.land` | 714 | `entity.ghast.warn` | 1378 | `block.resin.break` |
| 51 | `block.anvil.place` | 715 | `entity.ghastling.ambient` | 1379 | `block.resin.fall` |
| 52 | `block.anvil.step` | 716 | `entity.ghastling.death` | 1380 | `block.resin.place` |
| 53 | `block.anvil.use` | 717 | `entity.ghastling.hurt` | 1381 | `block.resin.step` |
| 54 | `entity.armadillo.eat` | 718 | `entity.ghastling.spawn` | 1382 | `block.resin_bricks.break` |
| 55 | `entity.armadillo.hurt` | 719 | `block.gilded_blackstone.break` | 1383 | `block.resin_bricks.fall` |
| 56 | `entity.armadillo.hurt_reduced` | 720 | `block.gilded_blackstone.fall` | 1384 | `block.resin_bricks.hit` |
| 57 | `entity.armadillo.ambient` | 721 | `block.gilded_blackstone.hit` | 1385 | `block.resin_bricks.place` |
| 58 | `entity.armadillo.step` | 722 | `block.gilded_blackstone.place` | 1386 | `block.resin_bricks.step` |
| 59 | `entity.armadillo.death` | 723 | `block.gilded_blackstone.step` | 1387 | `block.respawn_anchor.ambient` |
| 60 | `entity.armadillo.roll` | 724 | `block.glass.break` | 1388 | `block.respawn_anchor.charge` |
| 61 | `entity.armadillo.land` | 725 | `block.glass.fall` | 1389 | `block.respawn_anchor.deplete` |
| 62 | `entity.armadillo.scute_drop` | 726 | `block.glass.hit` | 1390 | `block.respawn_anchor.set_spawn` |
| 63 | `entity.armadillo.unroll_finish` | 727 | `block.glass.place` | 1391 | `block.rooted_dirt.break` |
| 64 | `entity.armadillo.peek` | 728 | `block.glass.step` | 1392 | `block.rooted_dirt.fall` |
| 65 | `entity.armadillo.unroll_start` | 729 | `item.glow_ink_sac.use` | 1393 | `block.rooted_dirt.hit` |
| 66 | `entity.armadillo.brush` | 730 | `entity.glow_item_frame.add_item` | 1394 | `block.rooted_dirt.place` |
| 67 | `item.armor.equip_chain` | 731 | `entity.glow_item_frame.break` | 1395 | `block.rooted_dirt.step` |
| 68 | `item.armor.equip_diamond` | 732 | `entity.glow_item_frame.place` | 1396 | `entity.salmon.ambient` |
| 69 | `item.armor.equip_elytra` | 733 | `entity.glow_item_frame.remove_item` | 1397 | `entity.salmon.death` |
| 70 | `item.armor.equip_generic` | 734 | `entity.glow_item_frame.rotate_item` | 1398 | `entity.salmon.flop` |
| 71 | `item.armor.equip_gold` | 735 | `entity.glow_squid.ambient` | 1399 | `entity.salmon.hurt` |
| 72 | `item.armor.equip_iron` | 736 | `entity.glow_squid.death` | 1400 | `block.sand.break` |
| 73 | `item.armor.equip_leather` | 737 | `entity.glow_squid.hurt` | 1401 | `block.sand.fall` |
| 74 | `item.armor.equip_copper` | 738 | `entity.glow_squid.squirt` | 1402 | `block.sand.hit` |
| 75 | `item.armor.equip_netherite` | 739 | `entity.goat.ambient` | 1403 | `block.sand.place` |
| 76 | `item.armor.equip_turtle` | 740 | `entity.goat.death` | 1404 | `block.sand.step` |
| 77 | `item.armor.equip_wolf` | 741 | `entity.goat.eat` | 1405 | `block.sand.idle` |
| 78 | `item.armor.unequip_wolf` | 742 | `entity.goat.hurt` | 1406 | `block.scaffolding.break` |
| 79 | `item.armor.equip_nautilus` | 743 | `entity.goat.long_jump` | 1407 | `block.scaffolding.fall` |
| 80 | `item.armor.unequip_nautilus` | 744 | `entity.goat.milk` | 1408 | `block.scaffolding.hit` |
| 81 | `entity.armor_stand.break` | 745 | `entity.goat.prepare_ram` | 1409 | `block.scaffolding.place` |
| 82 | `entity.armor_stand.fall` | 746 | `entity.goat.ram_impact` | 1410 | `block.scaffolding.step` |
| 83 | `entity.armor_stand.hit` | 747 | `entity.goat.horn_break` | 1411 | `block.sculk.spread` |
| 84 | `entity.armor_stand.place` | 748 | `entity.goat.screaming.ambient` | 1412 | `block.sculk.charge` |
| 85 | `entity.arrow.hit` | 749 | `entity.goat.screaming.death` | 1413 | `block.sculk.break` |
| 86 | `entity.arrow.hit_player` | 750 | `entity.goat.screaming.eat` | 1414 | `block.sculk.fall` |
| 87 | `entity.arrow.shoot` | 751 | `entity.goat.screaming.hurt` | 1415 | `block.sculk.hit` |
| 88 | `item.axe.strip` | 752 | `entity.goat.screaming.long_jump` | 1416 | `block.sculk.place` |
| 89 | `item.axe.scrape` | 753 | `entity.goat.screaming.milk` | 1417 | `block.sculk.step` |
| 90 | `item.axe.wax_off` | 754 | `entity.goat.screaming.prepare_ram` | 1418 | `block.sculk_catalyst.bloom` |
| 91 | `entity.axolotl.attack` | 755 | `entity.goat.screaming.ram_impact` | 1419 | `block.sculk_catalyst.break` |
| 92 | `entity.axolotl.death` | 756 | `entity.goat.step` | 1420 | `block.sculk_catalyst.fall` |
| 93 | `entity.axolotl.hurt` | 757 | `item.golden_dandelion.use` | 1421 | `block.sculk_catalyst.hit` |
| 94 | `entity.axolotl.idle_air` | 758 | `item.golden_dandelion.unuse` | 1422 | `block.sculk_catalyst.place` |
| 95 | `entity.axolotl.idle_water` | 759 | `block.grass.break` | 1423 | `block.sculk_catalyst.step` |
| 96 | `entity.axolotl.splash` | 760 | `block.grass.fall` | 1424 | `block.sculk_sensor.clicking` |
| 97 | `entity.axolotl.swim` | 761 | `block.grass.hit` | 1425 | `block.sculk_sensor.clicking_stop` |
| 98 | `block.azalea.break` | 762 | `block.grass.place` | 1426 | `block.sculk_sensor.break` |
| 99 | `block.azalea.fall` | 763 | `block.grass.step` | 1427 | `block.sculk_sensor.fall` |
| 100 | `block.azalea.hit` | 764 | `block.gravel.break` | 1428 | `block.sculk_sensor.hit` |
| 101 | `block.azalea.place` | 765 | `block.gravel.fall` | 1429 | `block.sculk_sensor.place` |
| 102 | `block.azalea.step` | 766 | `block.gravel.hit` | 1430 | `block.sculk_sensor.step` |
| 103 | `block.azalea_leaves.break` | 767 | `block.gravel.place` | 1431 | `block.sculk_shrieker.break` |
| 104 | `block.azalea_leaves.fall` | 768 | `block.gravel.step` | 1432 | `block.sculk_shrieker.fall` |
| 105 | `block.azalea_leaves.hit` | 769 | `block.grindstone.use` | 1433 | `block.sculk_shrieker.hit` |
| 106 | `block.azalea_leaves.place` | 770 | `block.growing_plant.crop` | 1434 | `block.sculk_shrieker.place` |
| 107 | `block.azalea_leaves.step` | 771 | `entity.guardian.ambient` | 1435 | `block.sculk_shrieker.shriek` |
| 108 | `entity.baby_nautilus.ambient` | 772 | `entity.guardian.ambient_land` | 1436 | `block.sculk_shrieker.step` |
| 109 | `entity.baby_nautilus.ambient_land` | 773 | `entity.guardian.attack` | 1437 | `block.sculk_vein.break` |
| 110 | `entity.baby_nautilus.death` | 774 | `entity.guardian.death` | 1438 | `block.sculk_vein.fall` |
| 111 | `entity.baby_nautilus.death_land` | 775 | `entity.guardian.death_land` | 1439 | `block.sculk_vein.hit` |
| 112 | `entity.baby_nautilus.eat` | 776 | `entity.guardian.flop` | 1440 | `block.sculk_vein.place` |
| 113 | `entity.baby_nautilus.hurt` | 777 | `entity.guardian.hurt` | 1441 | `block.sculk_vein.step` |
| 114 | `entity.baby_nautilus.hurt_land` | 778 | `entity.guardian.hurt_land` | 1442 | `entity.sheep.ambient` |
| 115 | `entity.nautilus.riding` | 779 | `block.hanging_roots.break` | 1443 | `entity.sheep.death` |
| 116 | `entity.baby_nautilus.swim` | 780 | `block.hanging_roots.fall` | 1444 | `entity.sheep.hurt` |
| 117 | `block.bamboo.break` | 781 | `block.hanging_roots.hit` | 1445 | `entity.sheep.shear` |
| 118 | `block.bamboo.fall` | 782 | `block.hanging_roots.place` | 1446 | `entity.sheep.step` |
| 119 | `block.bamboo.hit` | 783 | `block.hanging_roots.step` | 1447 | `item.shears.snip` |
| 120 | `block.bamboo.place` | 784 | `block.hanging_sign.step` | 1448 | `block.shelf.activate` |
| 121 | `block.bamboo.step` | 785 | `block.hanging_sign.break` | 1449 | `block.shelf.break` |
| 122 | `block.bamboo_sapling.break` | 786 | `block.hanging_sign.fall` | 1450 | `block.shelf.deactivate` |
| 123 | `block.bamboo_sapling.hit` | 787 | `block.hanging_sign.hit` | 1451 | `block.shelf.fall` |
| 124 | `block.bamboo_sapling.place` | 788 | `block.hanging_sign.place` | 1452 | `block.shelf.hit` |
| 125 | `block.bamboo_wood.break` | 789 | `entity.happy_ghast.ambient` | 1453 | `block.shelf.multi_swap` |
| 126 | `block.bamboo_wood.fall` | 790 | `entity.happy_ghast.death` | 1454 | `block.shelf.place` |
| 127 | `block.bamboo_wood.hit` | 791 | `entity.happy_ghast.hurt` | 1455 | `block.shelf.place_item` |
| 128 | `block.bamboo_wood.place` | 792 | `entity.happy_ghast.riding` | 1456 | `block.shelf.single_swap` |
| 129 | `block.bamboo_wood.step` | 793 | `block.heavy_core.break` | 1457 | `block.shelf.step` |
| 130 | `block.bamboo_wood_door.close` | 794 | `block.heavy_core.fall` | 1458 | `block.shelf.take_item` |
| 131 | `block.bamboo_wood_door.open` | 795 | `block.heavy_core.hit` | 1459 | `item.shield.block` |
| 132 | `block.bamboo_wood_trapdoor.close` | 796 | `block.heavy_core.place` | 1460 | `item.shield.break` |
| 133 | `block.bamboo_wood_trapdoor.open` | 797 | `block.heavy_core.step` | 1461 | `block.shroomlight.break` |
| 134 | `block.bamboo_wood_button.click_off` | 798 | `block.nether_wood_hanging_sign.step` | 1462 | `block.shroomlight.step` |
| 135 | `block.bamboo_wood_button.click_on` | 799 | `block.nether_wood_hanging_sign.break` | 1463 | `block.shroomlight.place` |
| 136 | `block.bamboo_wood_pressure_plate.click_off` | 800 | `block.nether_wood_hanging_sign.fall` | 1464 | `block.shroomlight.hit` |
| 137 | `block.bamboo_wood_pressure_plate.click_on` | 801 | `block.nether_wood_hanging_sign.hit` | 1465 | `block.shroomlight.fall` |
| 138 | `block.bamboo_wood_fence_gate.close` | 802 | `block.nether_wood_hanging_sign.place` | 1466 | `item.shovel.flatten` |
| 139 | `block.bamboo_wood_fence_gate.open` | 803 | `block.bamboo_wood_hanging_sign.step` | 1467 | `entity.shulker.ambient` |
| 140 | `block.barrel.close` | 804 | `block.bamboo_wood_hanging_sign.break` | 1468 | `block.shulker_box.close` |
| 141 | `block.barrel.open` | 805 | `block.bamboo_wood_hanging_sign.fall` | 1469 | `block.shulker_box.open` |
| 142 | `block.basalt.break` | 806 | `block.bamboo_wood_hanging_sign.hit` | 1470 | `entity.shulker_bullet.hit` |
| 143 | `block.basalt.step` | 807 | `block.bamboo_wood_hanging_sign.place` | 1471 | `entity.shulker_bullet.hurt` |
| 144 | `block.basalt.place` | 808 | `block.trial_spawner.break` | 1472 | `entity.shulker.close` |
| 145 | `block.basalt.hit` | 809 | `block.trial_spawner.step` | 1473 | `entity.shulker.death` |
| 146 | `block.basalt.fall` | 810 | `block.trial_spawner.place` | 1474 | `entity.shulker.hurt` |
| 147 | `entity.bat.ambient` | 811 | `block.trial_spawner.hit` | 1475 | `entity.shulker.hurt_closed` |
| 148 | `entity.bat.death` | 812 | `block.trial_spawner.fall` | 1476 | `entity.shulker.open` |
| 149 | `entity.bat.hurt` | 813 | `block.trial_spawner.spawn_mob` | 1477 | `entity.shulker.shoot` |
| 150 | `entity.bat.loop` | 814 | `block.trial_spawner.about_to_spawn_item` | 1478 | `entity.shulker.teleport` |
| 151 | `entity.bat.takeoff` | 815 | `block.trial_spawner.spawn_item` | 1479 | `entity.silverfish.ambient` |
| 152 | `block.beacon.activate` | 816 | `block.trial_spawner.spawn_item_begin` | 1480 | `entity.silverfish.death` |
| 153 | `block.beacon.ambient` | 817 | `block.trial_spawner.detect_player` | 1481 | `entity.silverfish.hurt` |
| 154 | `block.beacon.deactivate` | 818 | `block.trial_spawner.ominous_activate` | 1482 | `entity.silverfish.step` |
| 155 | `block.beacon.power_select` | 819 | `block.trial_spawner.ambient` | 1483 | `entity.skeleton.ambient` |
| 156 | `entity.bee.death` | 820 | `block.trial_spawner.ambient_ominous` | 1484 | `entity.skeleton.converted_to_stray` |
| 157 | `entity.bee.hurt` | 821 | `block.trial_spawner.open_shutter` | 1485 | `entity.skeleton.death` |
| 158 | `entity.bee.loop_aggressive` | 822 | `block.trial_spawner.close_shutter` | 1486 | `entity.skeleton_horse.ambient` |
| 159 | `entity.bee.loop` | 823 | `block.trial_spawner.eject_item` | 1487 | `entity.skeleton_horse.death` |
| 160 | `entity.bee.sting` | 824 | `entity.happy_ghast.equip` | 1488 | `entity.skeleton_horse.hurt` |
| 161 | `entity.bee.pollinate` | 825 | `entity.happy_ghast.unequip` | 1489 | `entity.skeleton_horse.swim` |
| 162 | `block.beehive.drip` | 826 | `entity.happy_ghast.harness_goggles_up` | 1490 | `entity.skeleton_horse.ambient_water` |
| 163 | `block.beehive.enter` | 827 | `entity.happy_ghast.harness_goggles_down` | 1491 | `entity.skeleton_horse.gallop_water` |
| 164 | `block.beehive.exit` | 828 | `item.hoe.till` | 1492 | `entity.skeleton_horse.jump_water` |
| 165 | `block.beehive.shear` | 829 | `entity.hoglin.ambient` | 1493 | `entity.skeleton_horse.step_water` |
| 166 | `block.beehive.work` | 830 | `entity.hoglin.angry` | 1494 | `entity.skeleton.hurt` |
| 167 | `block.bell.use` | 831 | `entity.hoglin.attack` | 1495 | `entity.skeleton.shoot` |
| 168 | `block.bell.resonate` | 832 | `entity.hoglin.converted_to_zombified` | 1496 | `entity.skeleton.step` |
| 169 | `block.big_dripleaf.break` | 833 | `entity.hoglin.death` | 1497 | `entity.slime.attack` |
| 170 | `block.big_dripleaf.fall` | 834 | `entity.hoglin.hurt` | 1498 | `entity.slime.death` |
| 171 | `block.big_dripleaf.hit` | 835 | `entity.hoglin.retreat` | 1499 | `entity.slime.hurt` |
| 172 | `block.big_dripleaf.place` | 836 | `entity.hoglin.step` | 1500 | `entity.slime.jump` |
| 173 | `block.big_dripleaf.step` | 837 | `block.honey_block.break` | 1501 | `entity.slime.squish` |
| 174 | `entity.blaze.ambient` | 838 | `block.honey_block.fall` | 1502 | `block.slime_block.break` |
| 175 | `entity.blaze.burn` | 839 | `block.honey_block.hit` | 1503 | `block.slime_block.fall` |
| 176 | `entity.blaze.death` | 840 | `block.honey_block.place` | 1504 | `block.slime_block.hit` |
| 177 | `entity.blaze.hurt` | 841 | `block.honey_block.slide` | 1505 | `block.slime_block.place` |
| 178 | `entity.blaze.shoot` | 842 | `block.honey_block.step` | 1506 | `block.slime_block.step` |
| 179 | `entity.boat.paddle_land` | 843 | `item.honeycomb.wax_on` | 1507 | `block.small_amethyst_bud.break` |
| 180 | `entity.boat.paddle_water` | 844 | `item.honey_bottle.drink` | 1508 | `block.small_amethyst_bud.place` |
| 181 | `entity.bogged.ambient` | 845 | `item.goat_horn.sound.0` | 1509 | `block.small_dripleaf.break` |
| 182 | `entity.bogged.death` | 846 | `item.goat_horn.sound.1` | 1510 | `block.small_dripleaf.fall` |
| 183 | `entity.bogged.hurt` | 847 | `item.goat_horn.sound.2` | 1511 | `block.small_dripleaf.hit` |
| 184 | `entity.bogged.shear` | 848 | `item.goat_horn.sound.3` | 1512 | `block.small_dripleaf.place` |
| 185 | `entity.bogged.step` | 849 | `item.goat_horn.sound.4` | 1513 | `block.small_dripleaf.step` |
| 186 | `block.bone_block.break` | 850 | `item.goat_horn.sound.5` | 1514 | `block.soul_sand.break` |
| 187 | `block.bone_block.fall` | 851 | `item.goat_horn.sound.6` | 1515 | `block.soul_sand.step` |
| 188 | `block.bone_block.hit` | 852 | `item.goat_horn.sound.7` | 1516 | `block.soul_sand.place` |
| 189 | `block.bone_block.place` | 853 | `entity.horse.ambient` | 1517 | `block.soul_sand.hit` |
| 190 | `block.bone_block.step` | 854 | `entity.baby_horse.ambient` | 1518 | `block.soul_sand.fall` |
| 191 | `item.bone_meal.use` | 855 | `entity.horse.angry` | 1519 | `block.soul_soil.break` |
| 192 | `item.book.page_turn` | 856 | `entity.baby_horse.angry` | 1520 | `block.soul_soil.step` |
| 193 | `item.book.put` | 857 | `entity.horse.armor` | 1521 | `block.soul_soil.place` |
| 194 | `block.blastfurnace.fire_crackle` | 858 | `item.horse_armor.unequip` | 1522 | `block.soul_soil.hit` |
| 195 | `item.bottle.empty` | 859 | `entity.horse.breathe` | 1523 | `block.soul_soil.fall` |
| 196 | `item.bottle.fill` | 860 | `entity.baby_horse.breathe` | 1524 | `particle.soul_escape` |
| 197 | `item.bottle.fill_dragonbreath` | 861 | `entity.horse.death` | 1525 | `block.spawner.break` |
| 198 | `entity.breeze.charge` | 862 | `entity.baby_horse.death` | 1526 | `block.spawner.fall` |
| 199 | `entity.breeze.deflect` | 863 | `entity.horse.eat` | 1527 | `block.spawner.hit` |
| 200 | `entity.breeze.inhale` | 864 | `entity.baby_horse.eat` | 1528 | `block.spawner.place` |
| 201 | `entity.breeze.idle_ground` | 865 | `entity.horse.gallop` | 1529 | `block.spawner.step` |
| 202 | `entity.breeze.idle_air` | 866 | `entity.horse.hurt` | 1530 | `item.spear.use` |
| 203 | `entity.breeze.shoot` | 867 | `entity.baby_horse.hurt` | 1531 | `item.spear.hit` |
| 204 | `entity.breeze.jump` | 868 | `entity.horse.jump` | 1532 | `item.spear.attack` |
| 205 | `entity.breeze.land` | 869 | `entity.horse.land` | 1533 | `item.spear_wood.use` |
| 206 | `entity.breeze.slide` | 870 | `entity.baby_horse.land` | 1534 | `item.spear_wood.hit` |
| 207 | `entity.breeze.death` | 871 | `entity.horse.saddle` | 1535 | `item.spear_wood.attack` |
| 208 | `entity.breeze.hurt` | 872 | `entity.horse.step` | 1536 | `block.spore_blossom.break` |
| 209 | `entity.breeze.whirl` | 873 | `entity.baby_horse.step` | 1537 | `block.spore_blossom.fall` |
| 210 | `entity.breeze.wind_burst` | 874 | `entity.horse.step_wood` | 1538 | `block.spore_blossom.hit` |
| 211 | `block.brewing_stand.brew` | 875 | `entity.hostile.big_fall` | 1539 | `block.spore_blossom.place` |
| 212 | `item.brush.brushing.generic` | 876 | `entity.hostile.death` | 1540 | `block.spore_blossom.step` |
| 213 | `item.brush.brushing.sand` | 877 | `entity.hostile.hurt` | 1541 | `entity.strider.ambient` |
| 214 | `item.brush.brushing.gravel` | 878 | `entity.hostile.small_fall` | 1542 | `entity.strider.happy` |
| 215 | `item.brush.brushing.sand.complete` | 879 | `entity.hostile.splash` | 1543 | `entity.strider.retreat` |
| 216 | `item.brush.brushing.gravel.complete` | 880 | `entity.hostile.swim` | 1544 | `entity.strider.death` |
| 217 | `block.bubble_column.bubble_pop` | 881 | `entity.husk.ambient` | 1545 | `entity.strider.hurt` |
| 218 | `block.bubble_column.upwards_ambient` | 882 | `entity.husk.converted_to_zombie` | 1546 | `entity.strider.step` |
| 219 | `block.bubble_column.upwards_inside` | 883 | `entity.husk.death` | 1547 | `entity.strider.step_lava` |
| 220 | `block.bubble_column.whirlpool_ambient` | 884 | `entity.husk.hurt` | 1548 | `entity.strider.eat` |
| 221 | `block.bubble_column.whirlpool_inside` | 885 | `entity.husk.step` | 1549 | `entity.strider.saddle` |
| 222 | `ui.hud.bubble_pop` | 886 | `entity.illusioner.ambient` | 1550 | `entity.slime.death_small` |
| 223 | `item.bucket.empty` | 887 | `entity.illusioner.cast_spell` | 1551 | `entity.slime.hurt_small` |
| 224 | `item.bucket.empty_axolotl` | 888 | `entity.illusioner.death` | 1552 | `entity.slime.jump_small` |
| 225 | `item.bucket.empty_fish` | 889 | `entity.illusioner.hurt` | 1553 | `entity.slime.squish_small` |
| 226 | `item.bucket.empty_lava` | 890 | `entity.illusioner.mirror_move` | 1554 | `block.smithing_table.use` |
| 227 | `item.bucket.empty_powder_snow` | 891 | `entity.illusioner.prepare_blindness` | 1555 | `block.smoker.smoke` |
| 228 | `item.bucket.empty_sulfur_cube` | 892 | `entity.illusioner.prepare_mirror` | 1556 | `entity.sniffer.step` |
| 229 | `item.bucket.empty_tadpole` | 893 | `item.ink_sac.use` | 1557 | `entity.sniffer.eat` |
| 230 | `item.bucket.fill` | 894 | `block.iron.break` | 1558 | `entity.sniffer.idle` |
| 231 | `item.bucket.fill_axolotl` | 895 | `block.iron.step` | 1559 | `entity.sniffer.hurt` |
| 232 | `item.bucket.fill_fish` | 896 | `block.iron.place` | 1560 | `entity.sniffer.death` |
| 233 | `item.bucket.fill_lava` | 897 | `block.iron.hit` | 1561 | `entity.sniffer.drop_seed` |
| 234 | `item.bucket.fill_powder_snow` | 898 | `block.iron.fall` | 1562 | `entity.sniffer.scenting` |
| 235 | `item.bucket.fill_sulfur_cube` | 899 | `block.iron_door.close` | 1563 | `entity.sniffer.sniffing` |
| 236 | `item.bucket.fill_tadpole` | 900 | `block.iron_door.open` | 1564 | `entity.sniffer.searching` |
| 237 | `item.bundle.drop_contents` | 901 | `entity.iron_golem.attack` | 1565 | `entity.sniffer.digging` |
| 238 | `item.bundle.insert` | 902 | `entity.iron_golem.damage` | 1566 | `entity.sniffer.digging_stop` |
| 239 | `item.bundle.insert_fail` | 903 | `entity.iron_golem.death` | 1567 | `entity.sniffer.happy` |
| 240 | `item.bundle.remove_one` | 904 | `entity.iron_golem.hurt` | 1568 | `block.sniffer_egg.plop` |
| 241 | `block.cactus_flower.break` | 905 | `entity.iron_golem.repair` | 1569 | `block.sniffer_egg.crack` |
| 242 | `block.cactus_flower.place` | 906 | `entity.iron_golem.step` | 1570 | `block.sniffer_egg.hatch` |
| 243 | `block.cake.add_candle` | 907 | `block.iron_trapdoor.close` | 1571 | `entity.snowball.throw` |
| 244 | `block.calcite.break` | 908 | `block.iron_trapdoor.open` | 1572 | `block.snow.break` |
| 245 | `block.calcite.step` | 909 | `entity.item_frame.add_item` | 1573 | `block.snow.fall` |
| 246 | `block.calcite.place` | 910 | `entity.item_frame.break` | 1574 | `entity.snow_golem.ambient` |
| 247 | `block.calcite.hit` | 911 | `entity.item_frame.place` | 1575 | `entity.snow_golem.death` |
| 248 | `block.calcite.fall` | 912 | `entity.item_frame.remove_item` | 1576 | `entity.snow_golem.hurt` |
| 249 | `entity.camel_husk.ambient` | 913 | `entity.item_frame.rotate_item` | 1577 | `entity.snow_golem.shoot` |
| 250 | `entity.camel_husk.dash` | 914 | `entity.item.break` | 1578 | `entity.snow_golem.shear` |
| 251 | `entity.camel_husk.dash_ready` | 915 | `entity.item.pickup` | 1579 | `block.snow.hit` |
| 252 | `entity.camel_husk.death` | 916 | `block.ladder.break` | 1580 | `block.snow.place` |
| 253 | `entity.camel_husk.eat` | 917 | `block.ladder.fall` | 1581 | `block.snow.step` |
| 254 | `entity.camel_husk.hurt` | 918 | `block.ladder.hit` | 1582 | `entity.spider.ambient` |
| 255 | `entity.camel_husk.saddle` | 919 | `block.ladder.place` | 1583 | `entity.spider.death` |
| 256 | `entity.camel_husk.sit` | 920 | `block.ladder.step` | 1584 | `entity.spider.hurt` |
| 257 | `entity.camel_husk.stand` | 921 | `block.lantern.break` | 1585 | `entity.spider.step` |
| 258 | `entity.camel_husk.step` | 922 | `block.lantern.fall` | 1586 | `entity.splash_potion.break` |
| 259 | `entity.camel_husk.step_sand` | 923 | `block.lantern.hit` | 1587 | `entity.splash_potion.throw` |
| 260 | `entity.camel.ambient` | 924 | `block.lantern.place` | 1588 | `block.sponge.break` |
| 261 | `entity.camel.dash` | 925 | `block.lantern.step` | 1589 | `block.sponge.fall` |
| 262 | `entity.camel.dash_ready` | 926 | `block.large_amethyst_bud.break` | 1590 | `block.sponge.hit` |
| 263 | `entity.camel.death` | 927 | `block.large_amethyst_bud.place` | 1591 | `block.sponge.place` |
| 264 | `entity.camel.eat` | 928 | `block.lava.ambient` | 1592 | `block.sponge.step` |
| 265 | `entity.camel.hurt` | 929 | `block.lava.extinguish` | 1593 | `block.sponge.absorb` |
| 266 | `entity.camel.saddle` | 930 | `block.lava.pop` | 1594 | `item.spyglass.use` |
| 267 | `entity.camel.sit` | 931 | `block.leaf_litter.break` | 1595 | `item.spyglass.stop_using` |
| 268 | `entity.camel.stand` | 932 | `block.leaf_litter.step` | 1596 | `entity.squid.ambient` |
| 269 | `entity.camel.step` | 933 | `block.leaf_litter.place` | 1597 | `entity.squid.death` |
| 270 | `entity.camel.step_sand` | 934 | `block.leaf_litter.hit` | 1598 | `entity.squid.hurt` |
| 271 | `block.campfire.crackle` | 935 | `block.leaf_litter.fall` | 1599 | `entity.squid.squirt` |
| 272 | `block.candle.ambient` | 936 | `item.lead.untied` | 1600 | `block.stone.break` |
| 273 | `block.candle.break` | 937 | `item.lead.tied` | 1601 | `block.stone_button.click_off` |
| 274 | `block.candle.extinguish` | 938 | `item.lead.break` | 1602 | `block.stone_button.click_on` |
| 275 | `block.candle.fall` | 939 | `block.lever.click` | 1603 | `block.stone.fall` |
| 276 | `block.candle.hit` | 940 | `entity.lightning_bolt.impact` | 1604 | `block.stone.hit` |
| 277 | `block.candle.place` | 941 | `entity.lightning_bolt.thunder` | 1605 | `block.stone.place` |
| 278 | `block.candle.step` | 942 | `entity.lingering_potion.throw` | 1606 | `block.stone_pressure_plate.click_off` |
| 279 | `entity.baby_cat.ambient` | 943 | `entity.llama.ambient` | 1607 | `block.stone_pressure_plate.click_on` |
| 280 | `entity.baby_cat.stray_ambient` | 944 | `entity.llama.angry` | 1608 | `block.stone.step` |
| 281 | `entity.baby_cat.death` | 945 | `entity.llama.chest` | 1609 | `entity.stray.ambient` |
| 282 | `entity.baby_cat.eat` | 946 | `entity.llama.death` | 1610 | `entity.stray.death` |
| 283 | `entity.baby_cat.hiss` | 947 | `entity.llama.eat` | 1611 | `entity.stray.hurt` |
| 284 | `entity.baby_cat.beg_for_food` | 948 | `entity.llama.hurt` | 1612 | `entity.stray.step` |
| 285 | `entity.baby_cat.hurt` | 949 | `entity.llama.spit` | 1613 | `block.sulfur_spike.break` |
| 286 | `entity.baby_cat.purr` | 950 | `entity.llama.step` | 1614 | `block.sulfur_spike.step` |
| 287 | `entity.baby_cat.purreow` | 951 | `entity.llama.swag` | 1615 | `block.sulfur_spike.place` |
| 288 | `entity.cat.ambient` | 952 | `item.llama_carpet.unequip` | 1616 | `block.sulfur_spike.hit` |
| 289 | `entity.cat.stray_ambient` | 953 | `entity.magma_cube.death_small` | 1617 | `block.sulfur_spike.fall` |
| 290 | `entity.cat.hiss` | 954 | `block.lodestone.break` | 1618 | `block.sulfur_spike.land` |
| 291 | `entity.cat.hurt` | 955 | `block.lodestone.step` | 1619 | `block.sweet_berry_bush.break` |
| 292 | `entity.cat.death` | 956 | `block.lodestone.place` | 1620 | `block.sweet_berry_bush.place` |
| 293 | `entity.cat.eat` | 957 | `block.lodestone.hit` | 1621 | `block.sweet_berry_bush.pick_berries` |
| 294 | `entity.cat.beg_for_food` | 958 | `block.lodestone.fall` | 1622 | `entity.tadpole.death` |
| 295 | `entity.cat.purr` | 959 | `item.lodestone_compass.lock` | 1623 | `entity.tadpole.flop` |
| 296 | `entity.cat.purreow` | 960 | `item.spear.lunge_1` | 1624 | `entity.tadpole.grow_up` |
| 297 | `entity.cat_royal.ambient` | 961 | `item.spear.lunge_2` | 1625 | `entity.tadpole.hurt` |
| 298 | `entity.cat_royal.stray_ambient` | 962 | `item.spear.lunge_3` | 1626 | `enchant.thorns.hit` |
| 299 | `entity.cat_royal.hiss` | 963 | `item.mace.smash_air` | 1627 | `entity.tnt.primed` |
| 300 | `entity.cat_royal.hurt` | 964 | `item.mace.smash_ground` | 1628 | `item.totem.use` |
| 301 | `entity.cat_royal.death` | 965 | `item.mace.smash_ground_heavy` | 1629 | `item.trident.hit` |
| 302 | `entity.cat_royal.eat` | 966 | `entity.magma_cube.death` | 1630 | `item.trident.hit_ground` |
| 303 | `entity.cat_royal.beg_for_food` | 967 | `entity.magma_cube.hurt` | 1631 | `item.trident.return` |
| 304 | `entity.cat_royal.purr` | 968 | `entity.magma_cube.hurt_small` | 1632 | `item.trident.riptide_1` |
| 305 | `entity.cat_royal.purreow` | 969 | `entity.magma_cube.jump` | 1633 | `item.trident.riptide_2` |
| 306 | `block.cave_vines.break` | 970 | `entity.magma_cube.squish` | 1634 | `item.trident.riptide_3` |
| 307 | `block.cave_vines.fall` | 971 | `entity.magma_cube.squish_small` | 1635 | `item.trident.throw` |
| 308 | `block.cave_vines.hit` | 972 | `block.mangrove_roots.break` | 1636 | `item.trident.thunder` |
| 309 | `block.cave_vines.place` | 973 | `block.mangrove_roots.fall` | 1637 | `block.tripwire.attach` |
| 310 | `block.cave_vines.step` | 974 | `block.mangrove_roots.hit` | 1638 | `block.tripwire.click_off` |
| 311 | `block.cave_vines.pick_berries` | 975 | `block.mangrove_roots.place` | 1639 | `block.tripwire.click_on` |
| 312 | `block.chain.break` | 976 | `block.mangrove_roots.step` | 1640 | `block.tripwire.detach` |
| 313 | `block.chain.fall` | 977 | `block.medium_amethyst_bud.break` | 1641 | `entity.tropical_fish.ambient` |
| 314 | `block.chain.hit` | 978 | `block.medium_amethyst_bud.place` | 1642 | `entity.tropical_fish.death` |
| 315 | `block.chain.place` | 979 | `block.metal.break` | 1643 | `entity.tropical_fish.flop` |
| 316 | `block.chain.step` | 980 | `block.metal.fall` | 1644 | `entity.tropical_fish.hurt` |
| 317 | `block.cherry_wood.break` | 981 | `block.metal.hit` | 1645 | `block.tuff.break` |
| 318 | `block.cherry_wood.fall` | 982 | `block.metal.place` | 1646 | `block.tuff.step` |
| 319 | `block.cherry_wood.hit` | 983 | `block.metal_pressure_plate.click_off` | 1647 | `block.tuff.place` |
| 320 | `block.cherry_wood.place` | 984 | `block.metal_pressure_plate.click_on` | 1648 | `block.tuff.hit` |
| 321 | `block.cherry_wood.step` | 985 | `block.metal.step` | 1649 | `block.tuff.fall` |
| 322 | `block.cherry_sapling.break` | 986 | `entity.minecart.inside.underwater` | 1650 | `block.tuff_bricks.break` |
| 323 | `block.cherry_sapling.fall` | 987 | `entity.minecart.inside` | 1651 | `block.tuff_bricks.fall` |
| 324 | `block.cherry_sapling.hit` | 988 | `entity.minecart.riding` | 1652 | `block.tuff_bricks.hit` |
| 325 | `block.cherry_sapling.place` | 989 | `entity.mooshroom.convert` | 1653 | `block.tuff_bricks.place` |
| 326 | `block.cherry_sapling.step` | 990 | `entity.mooshroom.eat` | 1654 | `block.tuff_bricks.step` |
| 327 | `block.cherry_leaves.break` | 991 | `entity.mooshroom.milk` | 1655 | `block.polished_tuff.break` |
| 328 | `block.cherry_leaves.fall` | 992 | `entity.mooshroom.suspicious_milk` | 1656 | `block.polished_tuff.fall` |
| 329 | `block.cherry_leaves.hit` | 993 | `entity.mooshroom.shear` | 1657 | `block.polished_tuff.hit` |
| 330 | `block.cherry_leaves.place` | 994 | `block.moss_carpet.break` | 1658 | `block.polished_tuff.place` |
| 331 | `block.cherry_leaves.step` | 995 | `block.moss_carpet.fall` | 1659 | `block.polished_tuff.step` |
| 332 | `block.cherry_wood_hanging_sign.step` | 996 | `block.moss_carpet.hit` | 1660 | `entity.turtle.ambient_land` |
| 333 | `block.cherry_wood_hanging_sign.break` | 997 | `block.moss_carpet.place` | 1661 | `entity.turtle.death` |
| 334 | `block.cherry_wood_hanging_sign.fall` | 998 | `block.moss_carpet.step` | 1662 | `entity.turtle.death_baby` |
| 335 | `block.cherry_wood_hanging_sign.hit` | 999 | `block.pink_petals.break` | 1663 | `entity.turtle.egg_break` |
| 336 | `block.cherry_wood_hanging_sign.place` | 1000 | `block.pink_petals.fall` | 1664 | `entity.turtle.egg_crack` |
| 337 | `block.cherry_wood_door.close` | 1001 | `block.pink_petals.hit` | 1665 | `entity.turtle.egg_hatch` |
| 338 | `block.cherry_wood_door.open` | 1002 | `block.pink_petals.place` | 1666 | `entity.turtle.hurt` |
| 339 | `block.cherry_wood_trapdoor.close` | 1003 | `block.pink_petals.step` | 1667 | `entity.turtle.hurt_baby` |
| 340 | `block.cherry_wood_trapdoor.open` | 1004 | `block.moss.break` | 1668 | `entity.turtle.lay_egg` |
| 341 | `block.cherry_wood_button.click_off` | 1005 | `block.moss.fall` | 1669 | `entity.turtle.shamble` |
| 342 | `block.cherry_wood_button.click_on` | 1006 | `block.moss.hit` | 1670 | `entity.turtle.shamble_baby` |
| 343 | `block.cherry_wood_pressure_plate.click_off` | 1007 | `block.moss.place` | 1671 | `entity.turtle.swim` |
| 344 | `block.cherry_wood_pressure_plate.click_on` | 1008 | `block.moss.step` | 1672 | `ui.button.click` |
| 345 | `block.cherry_wood_fence_gate.close` | 1009 | `block.mud.break` | 1673 | `ui.loom.select_pattern` |
| 346 | `block.cherry_wood_fence_gate.open` | 1010 | `block.mud.fall` | 1674 | `ui.loom.take_result` |
| 347 | `block.chest.close` | 1011 | `block.mud.hit` | 1675 | `ui.cartography_table.take_result` |
| 348 | `block.chest.locked` | 1012 | `block.mud.place` | 1676 | `ui.stonecutter.take_result` |
| 349 | `block.chest.open` | 1013 | `block.mud.step` | 1677 | `ui.stonecutter.select_recipe` |
| 350 | `entity.baby_chicken.ambient` | 1014 | `block.mud_bricks.break` | 1678 | `ui.toast.challenge_complete` |
| 351 | `entity.baby_chicken.death` | 1015 | `block.mud_bricks.fall` | 1679 | `ui.toast.in` |
| 352 | `entity.chicken.egg` | 1016 | `block.mud_bricks.hit` | 1680 | `ui.toast.out` |
| 353 | `entity.baby_chicken.hurt` | 1017 | `block.mud_bricks.place` | 1681 | `block.vault.activate` |
| 354 | `entity.chicken.step` | 1018 | `block.mud_bricks.step` | 1682 | `block.vault.ambient` |
| 355 | `entity.baby_chicken.step` | 1019 | `block.muddy_mangrove_roots.break` | 1683 | `block.vault.break` |
| 356 | `entity.chicken.ambient` | 1020 | `block.muddy_mangrove_roots.fall` | 1684 | `block.vault.close_shutter` |
| 357 | `entity.chicken.hurt` | 1021 | `block.muddy_mangrove_roots.hit` | 1685 | `block.vault.deactivate` |
| 358 | `entity.chicken.death` | 1022 | `block.muddy_mangrove_roots.place` | 1686 | `block.vault.eject_item` |
| 359 | `entity.chicken_picky.ambient` | 1023 | `block.muddy_mangrove_roots.step` | 1687 | `block.vault.reject_rewarded_player` |
| 360 | `entity.chicken_picky.hurt` | 1024 | `entity.mule.ambient` | 1688 | `block.vault.fall` |
| 361 | `entity.chicken_picky.death` | 1025 | `entity.mule.angry` | 1689 | `block.vault.hit` |
| 362 | `block.chiseled_bookshelf.break` | 1026 | `entity.mule.chest` | 1690 | `block.vault.insert_item` |
| 363 | `block.chiseled_bookshelf.fall` | 1027 | `entity.mule.death` | 1691 | `block.vault.insert_item_fail` |
| 364 | `block.chiseled_bookshelf.hit` | 1028 | `entity.mule.eat` | 1692 | `block.vault.open_shutter` |
| 365 | `block.chiseled_bookshelf.insert` | 1029 | `entity.mule.hurt` | 1693 | `block.vault.place` |
| 366 | `block.chiseled_bookshelf.insert.enchanted` | 1030 | `entity.mule.jump` | 1694 | `block.vault.step` |
| 367 | `block.chiseled_bookshelf.step` | 1031 | `music.creative` | 1695 | `entity.vex.ambient` |
| 368 | `block.chiseled_bookshelf.pickup` | 1032 | `music.credits` | 1696 | `entity.vex.charge` |
| 369 | `block.chiseled_bookshelf.pickup.enchanted` | 1033 | `music_disc.5` | 1697 | `entity.vex.death` |
| 370 | `block.chiseled_bookshelf.place` | 1034 | `music_disc.11` | 1698 | `entity.vex.hurt` |
| 371 | `block.chorus_flower.death` | 1035 | `music_disc.13` | 1699 | `entity.villager.ambient` |
| 372 | `block.chorus_flower.grow` | 1036 | `music_disc.blocks` | 1700 | `entity.villager.celebrate` |
| 373 | `item.chorus_fruit.teleport` | 1037 | `music_disc.bounce` | 1701 | `entity.villager.death` |
| 374 | `block.cobweb.break` | 1038 | `music_disc.cat` | 1702 | `entity.villager.hurt` |
| 375 | `block.cobweb.step` | 1039 | `music_disc.chirp` | 1703 | `entity.villager.no` |
| 376 | `block.cobweb.place` | 1040 | `music_disc.far` | 1704 | `entity.villager.trade` |
| 377 | `block.cobweb.hit` | 1041 | `music_disc.lava_chicken` | 1705 | `entity.villager.yes` |
| 378 | `block.cobweb.fall` | 1042 | `music_disc.mall` | 1706 | `entity.villager.work_armorer` |
| 379 | `entity.cod.ambient` | 1043 | `music_disc.mellohi` | 1707 | `entity.villager.work_butcher` |
| 380 | `entity.cod.death` | 1044 | `music_disc.pigstep` | 1708 | `entity.villager.work_cartographer` |
| 381 | `entity.cod.flop` | 1045 | `music_disc.stal` | 1709 | `entity.villager.work_cleric` |
| 382 | `entity.cod.hurt` | 1046 | `music_disc.strad` | 1710 | `entity.villager.work_farmer` |
| 383 | `block.comparator.click` | 1047 | `music_disc.wait` | 1711 | `entity.villager.work_fisherman` |
| 384 | `block.composter.empty` | 1048 | `music_disc.ward` | 1712 | `entity.villager.work_fletcher` |
| 385 | `block.composter.fill` | 1049 | `music_disc.otherside` | 1713 | `entity.villager.work_leatherworker` |
| 386 | `block.composter.fill_success` | 1050 | `music_disc.relic` | 1714 | `entity.villager.work_librarian` |
| 387 | `block.composter.ready` | 1051 | `music_disc.creator` | 1715 | `entity.villager.work_mason` |
| 388 | `block.conduit.activate` | 1052 | `music_disc.creator_music_box` | 1716 | `entity.villager.work_shepherd` |
| 389 | `block.conduit.ambient` | 1053 | `music_disc.precipice` | 1717 | `entity.villager.work_toolsmith` |
| 390 | `block.conduit.ambient.short` | 1054 | `music_disc.tears` | 1718 | `entity.villager.work_weaponsmith` |
| 391 | `block.conduit.attack.target` | 1055 | `music.dragon` | 1719 | `entity.vindicator.ambient` |
| 392 | `block.conduit.deactivate` | 1056 | `music.end` | 1720 | `entity.vindicator.celebrate` |
| 393 | `block.copper_bulb.break` | 1057 | `music.game` | 1721 | `entity.vindicator.death` |
| 394 | `block.copper_bulb.step` | 1058 | `music.menu` | 1722 | `entity.vindicator.hurt` |
| 395 | `block.copper_bulb.place` | 1059 | `music.nether.basalt_deltas` | 1723 | `block.vine.break` |
| 396 | `block.copper_bulb.hit` | 1060 | `music.nether.crimson_forest` | 1724 | `block.vine.fall` |
| 397 | `block.copper_bulb.fall` | 1061 | `music.overworld.deep_dark` | 1725 | `block.vine.hit` |
| 398 | `block.copper_bulb.turn_on` | 1062 | `music.overworld.dripstone_caves` | 1726 | `block.vine.place` |
| 399 | `block.copper_bulb.turn_off` | 1063 | `music.overworld.grove` | 1727 | `block.vine.step` |
| 400 | `block.copper.break` | 1064 | `music.overworld.jagged_peaks` | 1728 | `block.lily_pad.place` |
| 401 | `block.copper.step` | 1065 | `music.overworld.lush_caves` | 1729 | `entity.wandering_trader.ambient` |
| 402 | `block.copper.place` | 1066 | `music.overworld.swamp` | 1730 | `entity.wandering_trader.death` |
| 403 | `block.copper.hit` | 1067 | `music.overworld.forest` | 1731 | `entity.wandering_trader.disappeared` |
| 404 | `block.copper.fall` | 1068 | `music.overworld.old_growth_taiga` | 1732 | `entity.wandering_trader.drink_milk` |
| 405 | `block.copper_chest.close` | 1069 | `music.overworld.meadow` | 1733 | `entity.wandering_trader.drink_potion` |
| 406 | `block.copper_chest.open` | 1070 | `music.overworld.cherry_grove` | 1734 | `entity.wandering_trader.hurt` |
| 407 | `block.copper_chest_weathered.close` | 1071 | `music.nether.nether_wastes` | 1735 | `entity.wandering_trader.no` |
| 408 | `block.copper_chest_weathered.open` | 1072 | `music.overworld.frozen_peaks` | 1736 | `entity.wandering_trader.reappeared` |
| 409 | `block.copper_chest_oxidized.close` | 1073 | `music.overworld.snowy_slopes` | 1737 | `entity.wandering_trader.trade` |
| 410 | `block.copper_chest_oxidized.open` | 1074 | `music.nether.soul_sand_valley` | 1738 | `entity.wandering_trader.yes` |
| 411 | `block.copper_door.close` | 1075 | `music.overworld.stony_peaks` | 1739 | `entity.warden.agitated` |
| 412 | `block.copper_door.open` | 1076 | `music.nether.warped_forest` | 1740 | `entity.warden.ambient` |
| 413 | `entity.copper_golem.step` | 1077 | `music.overworld.flower_forest` | 1741 | `entity.warden.angry` |
| 414 | `entity.copper_golem.hurt` | 1078 | `music.overworld.desert` | 1742 | `entity.warden.attack_impact` |
| 415 | `entity.copper_golem.death` | 1079 | `music.overworld.badlands` | 1743 | `entity.warden.death` |
| 416 | `entity.copper_golem_weathered.step` | 1080 | `music.overworld.jungle` | 1744 | `entity.warden.dig` |
| 417 | `entity.copper_golem_weathered.hurt` | 1081 | `music.overworld.sparse_jungle` | 1745 | `entity.warden.emerge` |
| 418 | `entity.copper_golem_weathered.death` | 1082 | `music.overworld.bamboo_jungle` | 1746 | `entity.warden.heartbeat` |
| 419 | `entity.copper_golem_oxidized.step` | 1083 | `music.overworld.sulfur_caves` | 1747 | `entity.warden.hurt` |
| 420 | `entity.copper_golem_oxidized.hurt` | 1084 | `music.under_water` | 1748 | `entity.warden.listening` |
| 421 | `entity.copper_golem_oxidized.death` | 1085 | `entity.nautilus.ambient` | 1749 | `entity.warden.listening_angry` |
| 422 | `entity.copper_golem.spin` | 1086 | `entity.nautilus.ambient_land` | 1750 | `entity.warden.nearby_close` |
| 423 | `entity.copper_golem_weathered.spin` | 1087 | `entity.nautilus.dash` | 1751 | `entity.warden.nearby_closer` |
| 424 | `entity.copper_golem_oxidized.spin` | 1088 | `entity.nautilus.dash_land` | 1752 | `entity.warden.nearby_closest` |
| 425 | `entity.copper_golem.no_item_get` | 1089 | `entity.nautilus.dash_ready` | 1753 | `entity.warden.roar` |
| 426 | `entity.copper_golem.no_item_no_get` | 1090 | `entity.nautilus.dash_ready_land` | 1754 | `entity.warden.sniff` |
| 427 | `entity.copper_golem.item_drop` | 1091 | `entity.nautilus.death` | 1755 | `entity.warden.sonic_boom` |
| 428 | `entity.copper_golem.item_no_drop` | 1092 | `entity.nautilus.death_land` | 1756 | `entity.warden.sonic_charge` |
| 429 | `entity.copper_golem_become_statue` | 1093 | `entity.nautilus.eat` | 1757 | `entity.warden.step` |
| 430 | `block.copper_golem_statue.break` | 1094 | `entity.nautilus.hurt` | 1758 | `entity.warden.tendril_clicks` |
| 431 | `block.copper_golem_statue.place` | 1095 | `entity.nautilus.hurt_land` | 1759 | `block.hanging_sign.waxed_interact_fail` |
| 432 | `block.copper_golem_statue.hit` | 1096 | `entity.nautilus.swim` | 1760 | `block.sign.waxed_interact_fail` |
| 433 | `block.copper_golem_statue.step` | 1097 | `block.nether_bricks.break` | 1761 | `block.water.ambient` |
| 434 | `block.copper_golem_statue.fall` | 1098 | `block.nether_bricks.step` | 1762 | `weather.end_flash` |
| 435 | `entity.copper_golem.spawn` | 1099 | `block.nether_bricks.place` | 1763 | `weather.rain` |
| 436 | `entity.copper_golem.shear` | 1100 | `block.nether_bricks.hit` | 1764 | `weather.rain.above` |
| 437 | `block.copper_grate.break` | 1101 | `block.nether_bricks.fall` | 1765 | `block.wet_grass.break` |
| 438 | `block.copper_grate.step` | 1102 | `block.nether_wart.break` | 1766 | `block.wet_grass.fall` |
| 439 | `block.copper_grate.place` | 1103 | `item.nether_wart.plant` | 1767 | `block.wet_grass.hit` |
| 440 | `block.copper_grate.hit` | 1104 | `block.nether_wood.break` | 1768 | `block.wet_grass.place` |
| 441 | `block.copper_grate.fall` | 1105 | `block.nether_wood.fall` | 1769 | `block.wet_grass.step` |
| 442 | `block.copper_trapdoor.close` | 1106 | `block.nether_wood.hit` | 1770 | `block.wet_sponge.break` |
| 443 | `block.copper_trapdoor.open` | 1107 | `block.nether_wood.place` | 1771 | `block.wet_sponge.dries` |
| 444 | `block.coral_block.break` | 1108 | `block.nether_wood.step` | 1772 | `block.wet_sponge.fall` |
| 445 | `block.coral_block.fall` | 1109 | `block.nether_wood_door.close` | 1773 | `block.wet_sponge.hit` |
| 446 | `block.coral_block.hit` | 1110 | `block.nether_wood_door.open` | 1774 | `block.wet_sponge.place` |
| 447 | `block.coral_block.place` | 1111 | `block.nether_wood_trapdoor.close` | 1775 | `block.wet_sponge.step` |
| 448 | `block.coral_block.step` | 1112 | `block.nether_wood_trapdoor.open` | 1776 | `entity.wind_charge.wind_burst` |
| 449 | `entity.cow.milk` | 1113 | `block.nether_wood_button.click_off` | 1777 | `entity.wind_charge.throw` |
| 450 | `entity.cow.ambient` | 1114 | `block.nether_wood_button.click_on` | 1778 | `entity.witch.ambient` |
| 451 | `entity.cow.hurt` | 1115 | `block.nether_wood_pressure_plate.click_off` | 1779 | `entity.witch.celebrate` |
| 452 | `entity.cow.death` | 1116 | `block.nether_wood_pressure_plate.click_on` | 1780 | `entity.witch.death` |
| 453 | `entity.cow.step` | 1117 | `block.nether_wood_fence_gate.close` | 1781 | `entity.witch.drink` |
| 454 | `entity.cow_moody.ambient` | 1118 | `block.nether_wood_fence_gate.open` | 1782 | `entity.witch.hurt` |
| 455 | `entity.cow_moody.hurt` | 1119 | `intentionally_empty` | 1783 | `entity.witch.throw` |
| 456 | `entity.cow_moody.death` | 1120 | `block.packed_mud.break` | 1784 | `entity.wither.ambient` |
| 457 | `entity.cow_moody.step` | 1121 | `block.packed_mud.fall` | 1785 | `entity.wither.break_block` |
| 458 | `block.crafter.craft` | 1122 | `block.packed_mud.hit` | 1786 | `entity.wither.death` |
| 459 | `block.crafter.fail` | 1123 | `block.packed_mud.place` | 1787 | `entity.wither.hurt` |
| 460 | `entity.creaking.ambient` | 1124 | `block.packed_mud.step` | 1788 | `entity.wither.shoot` |
| 461 | `entity.creaking.activate` | 1125 | `block.stem.break` | 1789 | `entity.wither_skeleton.ambient` |
| 462 | `entity.creaking.deactivate` | 1126 | `block.stem.step` | 1790 | `entity.wither_skeleton.death` |
| 463 | `entity.creaking.attack` | 1127 | `block.stem.place` | 1791 | `entity.wither_skeleton.hurt` |
| 464 | `entity.creaking.death` | 1128 | `block.stem.hit` | 1792 | `entity.wither_skeleton.step` |
| 465 | `entity.creaking.step` | 1129 | `block.stem.fall` | 1793 | `entity.wither.spawn` |
| 466 | `entity.creaking.freeze` | 1130 | `block.nylium.break` | 1794 | `item.wolf_armor.break` |
| 467 | `entity.creaking.unfreeze` | 1131 | `block.nylium.step` | 1795 | `entity.baby_wolf.ambient` |
| 468 | `entity.creaking.spawn` | 1132 | `block.nylium.place` | 1796 | `item.wolf_armor.crack` |
| 469 | `entity.creaking.sway` | 1133 | `block.nylium.hit` | 1797 | `item.wolf_armor.damage` |
| 470 | `entity.creaking.twitch` | 1134 | `block.nylium.fall` | 1798 | `item.wolf_armor.repair` |
| 471 | `block.creaking_heart.break` | 1135 | `block.nether_sprouts.break` | 1799 | `entity.baby_wolf.death` |
| 472 | `block.creaking_heart.fall` | 1136 | `block.nether_sprouts.step` | 1800 | `entity.baby_wolf.growl` |
| 473 | `block.creaking_heart.hit` | 1137 | `block.nether_sprouts.place` | 1801 | `entity.baby_wolf.hurt` |
| 474 | `block.creaking_heart.hurt` | 1138 | `block.nether_sprouts.hit` | 1802 | `entity.baby_wolf.pant` |
| 475 | `block.creaking_heart.place` | 1139 | `block.nether_sprouts.fall` | 1803 | `entity.wolf.shake` |
| 476 | `block.creaking_heart.step` | 1140 | `block.fungus.break` | 1804 | `entity.wolf.step` |
| 477 | `block.creaking_heart.idle` | 1141 | `block.fungus.step` | 1805 | `entity.baby_wolf.step` |
| 478 | `block.creaking_heart.spawn` | 1142 | `block.fungus.place` | 1806 | `entity.baby_wolf.whine` |
| 479 | `entity.creeper.death` | 1143 | `block.fungus.hit` | 1807 | `entity.wolf.ambient` |
| 480 | `entity.creeper.hurt` | 1144 | `block.fungus.fall` | 1808 | `entity.wolf.death` |
| 481 | `entity.creeper.primed` | 1145 | `block.weeping_vines.break` | 1809 | `entity.wolf.growl` |
| 482 | `block.crop.break` | 1146 | `block.weeping_vines.step` | 1810 | `entity.wolf.hurt` |
| 483 | `item.crop.plant` | 1147 | `block.weeping_vines.place` | 1811 | `entity.wolf.pant` |
| 484 | `item.crossbow.hit` | 1148 | `block.weeping_vines.hit` | 1812 | `entity.wolf.whine` |
| 485 | `item.crossbow.loading_end` | 1149 | `block.weeping_vines.fall` | 1813 | `entity.wolf_puglin.ambient` |
| 486 | `item.crossbow.loading_middle` | 1150 | `block.wart_block.break` | 1814 | `entity.wolf_puglin.death` |
| 487 | `item.crossbow.loading_start` | 1151 | `block.wart_block.step` | 1815 | `entity.wolf_puglin.growl` |
| 488 | `item.crossbow.quick_charge_1` | 1152 | `block.wart_block.place` | 1816 | `entity.wolf_puglin.hurt` |
| 489 | `item.crossbow.quick_charge_2` | 1153 | `block.wart_block.hit` | 1817 | `entity.wolf_puglin.pant` |
| 490 | `item.crossbow.quick_charge_3` | 1154 | `block.wart_block.fall` | 1818 | `entity.wolf_puglin.whine` |
| 491 | `item.crossbow.shoot` | 1155 | `block.netherite_block.break` | 1819 | `entity.wolf_sad.ambient` |
| 492 | `entity.cushion.break` | 1156 | `block.netherite_block.step` | 1820 | `entity.wolf_sad.death` |
| 493 | `entity.cushion.place` | 1157 | `block.netherite_block.place` | 1821 | `entity.wolf_sad.growl` |
| 494 | `entity.cushion.sit` | 1158 | `block.netherite_block.hit` | 1822 | `entity.wolf_sad.hurt` |
| 495 | `entity.cushion.get_up` | 1159 | `block.netherite_block.fall` | 1823 | `entity.wolf_sad.pant` |
| 496 | `block.deadbush.idle` | 1160 | `block.netherrack.break` | 1824 | `entity.wolf_sad.whine` |
| 497 | `block.decorated_pot.break` | 1161 | `block.netherrack.step` | 1825 | `entity.wolf_angry.ambient` |
| 498 | `block.decorated_pot.fall` | 1162 | `block.netherrack.place` | 1826 | `entity.wolf_angry.death` |
| 499 | `block.decorated_pot.hit` | 1163 | `block.netherrack.hit` | 1827 | `entity.wolf_angry.growl` |
| 500 | `block.decorated_pot.insert` | 1164 | `block.netherrack.fall` | 1828 | `entity.wolf_angry.hurt` |
| 501 | `block.decorated_pot.insert_fail` | 1165 | `block.note_block.basedrum` | 1829 | `entity.wolf_angry.pant` |
| 502 | `block.decorated_pot.step` | 1166 | `block.note_block.bass` | 1830 | `entity.wolf_angry.whine` |
| 503 | `block.decorated_pot.place` | 1167 | `block.note_block.bell` | 1831 | `entity.wolf_grumpy.ambient` |
| 504 | `block.decorated_pot.shatter` | 1168 | `block.note_block.chime` | 1832 | `entity.wolf_grumpy.death` |
| 505 | `block.deepslate_bricks.break` | 1169 | `block.note_block.flute` | 1833 | `entity.wolf_grumpy.growl` |
| 506 | `block.deepslate_bricks.fall` | 1170 | `block.note_block.guitar` | 1834 | `entity.wolf_grumpy.hurt` |
| 507 | `block.deepslate_bricks.hit` | 1171 | `block.note_block.harp` | 1835 | `entity.wolf_grumpy.pant` |
| 508 | `block.deepslate_bricks.place` | 1172 | `block.note_block.hat` | 1836 | `entity.wolf_grumpy.whine` |
| 509 | `block.deepslate_bricks.step` | 1173 | `block.note_block.pling` | 1837 | `entity.wolf_big.ambient` |
| 510 | `block.deepslate.break` | 1174 | `block.note_block.snare` | 1838 | `entity.wolf_big.death` |
| 511 | `block.deepslate.fall` | 1175 | `block.note_block.trumpet` | 1839 | `entity.wolf_big.growl` |
| 512 | `block.deepslate.hit` | 1176 | `block.note_block.trumpet_exposed` | 1840 | `entity.wolf_big.hurt` |
| 513 | `block.deepslate.place` | 1177 | `block.note_block.trumpet_oxidized` | 1841 | `entity.wolf_big.pant` |
| 514 | `block.deepslate.step` | 1178 | `block.note_block.trumpet_weathered` | 1842 | `entity.wolf_big.whine` |
| 515 | `block.deepslate_tiles.break` | 1179 | `block.note_block.xylophone` | 1843 | `entity.wolf_cute.ambient` |
| 516 | `block.deepslate_tiles.fall` | 1180 | `block.note_block.iron_xylophone` | 1844 | `entity.wolf_cute.death` |
| 517 | `block.deepslate_tiles.hit` | 1181 | `block.note_block.cow_bell` | 1845 | `entity.wolf_cute.growl` |
| 518 | `block.deepslate_tiles.place` | 1182 | `block.note_block.didgeridoo` | 1846 | `entity.wolf_cute.hurt` |
| 519 | `block.deepslate_tiles.step` | 1183 | `block.note_block.bit` | 1847 | `entity.wolf_cute.pant` |
| 520 | `block.dispenser.dispense` | 1184 | `block.note_block.banjo` | 1848 | `entity.wolf_cute.whine` |
| 521 | `block.dispenser.fail` | 1185 | `block.note_block.imitate.zombie` | 1849 | `block.wooden_door.close` |
| 522 | `block.dispenser.launch` | 1186 | `block.note_block.imitate.skeleton` | 1850 | `block.wooden_door.open` |
| 523 | `entity.dolphin.ambient` | 1187 | `block.note_block.imitate.creeper` | 1851 | `block.wooden_trapdoor.close` |
| 524 | `entity.dolphin.ambient_water` | 1188 | `block.note_block.imitate.ender_dragon` | 1852 | `block.wooden_trapdoor.open` |
| 525 | `entity.dolphin.attack` | 1189 | `block.note_block.imitate.wither_skeleton` | 1853 | `block.wooden_button.click_off` |
| 526 | `entity.dolphin.death` | 1190 | `block.note_block.imitate.piglin` | 1854 | `block.wooden_button.click_on` |
| 527 | `entity.dolphin.eat` | 1191 | `entity.ocelot.hurt` | 1855 | `block.wooden_pressure_plate.click_off` |
| 528 | `entity.dolphin.hurt` | 1192 | `entity.ocelot.ambient` | 1856 | `block.wooden_pressure_plate.click_on` |
| 529 | `entity.dolphin.jump` | 1193 | `entity.ocelot.death` | 1857 | `block.wood.break` |
| 530 | `entity.dolphin.play` | 1194 | `item.ominous_bottle.dispose` | 1858 | `block.wood.fall` |
| 531 | `entity.dolphin.splash` | 1195 | `entity.painting.break` | 1859 | `block.wood.hit` |
| 532 | `entity.dolphin.swim` | 1196 | `entity.painting.place` | 1860 | `block.wood.place` |
| 533 | `entity.donkey.ambient` | 1197 | `block.pale_hanging_moss.idle` | 1861 | `block.wood.step` |
| 534 | `entity.donkey.angry` | 1198 | `entity.panda.pre_sneeze` | 1862 | `block.wool.break` |
| 535 | `entity.donkey.chest` | 1199 | `entity.panda.sneeze` | 1863 | `block.wool.fall` |
| 536 | `entity.donkey.death` | 1200 | `entity.panda.ambient` | 1864 | `block.wool.hit` |
| 537 | `entity.donkey.eat` | 1201 | `entity.panda.death` | 1865 | `block.wool.place` |
| 538 | `entity.donkey.hurt` | 1202 | `entity.panda.eat` | 1866 | `block.wool.step` |
| 539 | `entity.donkey.jump` | 1203 | `entity.panda.step` | 1867 | `entity.zoglin.ambient` |
| 540 | `block.dried_ghast.break` | 1204 | `entity.panda.cant_breed` | 1868 | `entity.zoglin.angry` |
| 541 | `block.dried_ghast.step` | 1205 | `entity.panda.aggressive_ambient` | 1869 | `entity.zoglin.attack` |
| 542 | `block.dried_ghast.fall` | 1206 | `entity.panda.worried_ambient` | 1870 | `entity.zoglin.death` |
| 543 | `block.dried_ghast.ambient` | 1207 | `entity.panda.hurt` | 1871 | `entity.zoglin.hurt` |
| 544 | `block.dried_ghast.ambient_water` | 1208 | `entity.panda.bite` | 1872 | `entity.zoglin.step` |
| 545 | `block.dried_ghast.place` | 1209 | `entity.parched.ambient` | 1873 | `entity.zombie.ambient` |
| 546 | `block.dried_ghast.place_in_water` | 1210 | `entity.parched.death` | 1874 | `entity.zombie.attack_wooden_door` |
| 547 | `block.dried_ghast.transition` | 1211 | `entity.parched.hurt` | 1875 | `entity.zombie.attack_iron_door` |
| 548 | `block.dripstone_block.break` | 1212 | `entity.parched.step` | 1876 | `entity.zombie.break_wooden_door` |
| 549 | `block.dripstone_block.step` | 1213 | `entity.parrot.ambient` | 1877 | `entity.zombie.converted_to_drowned` |
| 550 | `block.dripstone_block.place` | 1214 | `entity.parrot.death` | 1878 | `entity.zombie.death` |
| 551 | `block.dripstone_block.hit` | 1215 | `entity.parrot.eat` | 1879 | `entity.zombie.destroy_egg` |
| 552 | `block.dripstone_block.fall` | 1216 | `entity.parrot.fly` | 1880 | `entity.zombie_horse.ambient` |
| 553 | `block.dry_grass.ambient` | 1217 | `entity.parrot.hurt` | 1881 | `entity.zombie_horse.angry` |
| 554 | `block.pointed_dripstone.break` | 1218 | `entity.parrot.imitate.blaze` | 1882 | `entity.zombie_horse.death` |
| 555 | `block.pointed_dripstone.step` | 1219 | `entity.parrot.imitate.bogged` | 1883 | `entity.zombie_horse.eat` |
| 556 | `block.pointed_dripstone.place` | 1220 | `entity.parrot.imitate.breeze` | 1884 | `entity.zombie_horse.hurt` |
| 557 | `block.pointed_dripstone.hit` | 1221 | `entity.parrot.imitate.camel_husk` | 1885 | `entity.zombie.hurt` |
| 558 | `block.pointed_dripstone.fall` | 1222 | `entity.parrot.imitate.creaking` | 1886 | `entity.zombie.infect` |
| 559 | `block.pointed_dripstone.land` | 1223 | `entity.parrot.imitate.creeper` | 1887 | `entity.zombie_nautilus.ambient` |
| 560 | `block.pointed_dripstone.drip_lava` | 1224 | `entity.parrot.imitate.drowned` | 1888 | `entity.zombie_nautilus.ambient_land` |
| 561 | `block.pointed_dripstone.drip_water` | 1225 | `entity.parrot.imitate.elder_guardian` | 1889 | `entity.zombie_nautilus.dash` |
| 562 | `block.pointed_dripstone.drip_lava_into_cauldron` | 1226 | `entity.parrot.imitate.ender_dragon` | 1890 | `entity.zombie_nautilus.dash_land` |
| 563 | `block.pointed_dripstone.drip_water_into_cauldron` | 1227 | `entity.parrot.imitate.endermite` | 1891 | `entity.zombie_nautilus.dash_ready` |
| 564 | `block.big_dripleaf.tilt_down` | 1228 | `entity.parrot.imitate.evoker` | 1892 | `entity.zombie_nautilus.dash_ready_land` |
| 565 | `block.big_dripleaf.tilt_up` | 1229 | `entity.parrot.imitate.ghast` | 1893 | `entity.zombie_nautilus.death` |
| 566 | `entity.drowned.ambient` | 1230 | `entity.parrot.imitate.guardian` | 1894 | `entity.zombie_nautilus.death_land` |
| 567 | `entity.drowned.ambient_water` | 1231 | `entity.parrot.imitate.hoglin` | 1895 | `entity.zombie_nautilus.eat` |
| 568 | `entity.drowned.death` | 1232 | `entity.parrot.imitate.husk` | 1896 | `entity.zombie_nautilus.hurt` |
| 569 | `entity.drowned.death_water` | 1233 | `entity.parrot.imitate.illusioner` | 1897 | `entity.zombie_nautilus.hurt_land` |
| 570 | `entity.drowned.hurt` | 1234 | `entity.parrot.imitate.magma_cube` | 1898 | `entity.zombie_nautilus.swim` |
| 571 | `entity.drowned.hurt_water` | 1235 | `entity.parrot.imitate.phantom` | 1899 | `entity.zombified_piglin.ambient` |
| 572 | `entity.drowned.shoot` | 1236 | `entity.parrot.imitate.parched` | 1900 | `entity.zombified_piglin.angry` |
| 573 | `entity.drowned.step` | 1237 | `entity.parrot.imitate.piglin` | 1901 | `entity.zombified_piglin.death` |
| 574 | `entity.drowned.swim` | 1238 | `entity.parrot.imitate.piglin_brute` | 1902 | `entity.zombified_piglin.hurt` |
| 575 | `item.dye.use` | 1239 | `entity.parrot.imitate.pillager` | 1903 | `entity.zombie.step` |
| 576 | `entity.egg.throw` | 1240 | `entity.parrot.imitate.ravager` | 1904 | `entity.zombie_villager.ambient` |
| 577 | `entity.elder_guardian.ambient` | 1241 | `entity.parrot.imitate.shulker` | 1905 | `entity.zombie_villager.converted` |
| 578 | `entity.elder_guardian.ambient_land` | 1242 | `entity.parrot.imitate.silverfish` | 1906 | `entity.zombie_villager.cure` |
| 579 | `entity.elder_guardian.curse` | 1243 | `entity.parrot.imitate.skeleton` | 1907 | `entity.zombie_villager.death` |
| 580 | `entity.elder_guardian.death` | 1244 | `entity.parrot.imitate.slime` | 1908 | `entity.zombie_villager.hurt` |
| 581 | `entity.elder_guardian.death_land` | 1245 | `entity.parrot.imitate.spider` | 1909 | `entity.zombie_villager.step` |
| 582 | `entity.elder_guardian.flop` | 1246 | `entity.parrot.imitate.stray` | 1910 | `event.mob_effect.bad_omen` |
| 583 | `entity.elder_guardian.hurt` | 1247 | `entity.parrot.imitate.vex` | 1911 | `event.mob_effect.trial_omen` |
| 584 | `entity.elder_guardian.hurt_land` | 1248 | `entity.parrot.imitate.vindicator` | 1912 | `event.mob_effect.raid_omen` |
| 585 | `item.elytra.flying` | 1249 | `entity.parrot.imitate.warden` | 1913 | `item.saddle.unequip` |
| 586 | `block.enchantment_table.use` | 1250 | `entity.parrot.imitate.witch` | 1914 | `item.nautilus_saddle_underwater_equip` |
| 587 | `block.ender_chest.close` | 1251 | `entity.parrot.imitate.wither` | 1915 | `item.nautilus_saddle_equip` |
| 588 | `block.ender_chest.open` | 1252 | `entity.parrot.imitate.wither_skeleton` | 1916 | `block.sulfur.break` |
| 589 | `entity.ender_dragon.ambient` | 1253 | `entity.parrot.imitate.zoglin` | 1917 | `block.sulfur.step` |
| 590 | `entity.ender_dragon.death` | 1254 | `entity.parrot.imitate.zombie` | 1918 | `block.sulfur.place` |
| 591 | `entity.dragon_fireball.explode` | 1255 | `entity.parrot.imitate.zombie_horse` | 1919 | `block.sulfur.hit` |
| 592 | `entity.ender_dragon.flap` | 1256 | `entity.parrot.imitate.zombie_nautilus` | 1920 | `block.sulfur.fall` |
| 593 | `entity.ender_dragon.growl` | 1257 | `entity.parrot.imitate.zombie_villager` | 1921 | `block.potent_sulfur.break` |
| 594 | `entity.ender_dragon.hurt` | 1258 | `entity.parrot.step` | 1922 | `block.potent_sulfur.step` |
| 595 | `entity.ender_dragon.shoot` | 1259 | `entity.phantom.ambient` | 1923 | `block.potent_sulfur.place` |
| 596 | `entity.ender_eye.death` | 1260 | `entity.phantom.bite` | 1924 | `block.potent_sulfur.hit` |
| 597 | `entity.ender_eye.launch` | 1261 | `entity.phantom.death` | 1925 | `block.potent_sulfur.fall` |
| 598 | `entity.enderman.ambient` | 1262 | `entity.phantom.flap` | 1926 | `block.potent_sulfur.geyser_eruption` |
| 599 | `entity.enderman.death` | 1263 | `entity.phantom.hurt` | 1927 | `block.potent_sulfur.geyser_eruption_active` |
| 600 | `entity.enderman.hurt` | 1264 | `entity.phantom.swoop` | 1928 | `block.potent_sulfur.geyser_continuous_eruption` |
| 601 | `entity.enderman.scream` | 1265 | `entity.pig.saddle` | 1929 | `block.potent_sulfur.geyser_continuous_eruption_active` |
| 602 | `entity.enderman.stare` | 1266 | `entity.pig.step` | 1930 | `block.cinnabar.break` |
| 603 | `entity.enderman.teleport` | 1267 | `entity.baby_pig.step` | 1931 | `block.cinnabar.step` |
| 604 | `entity.endermite.ambient` | 1268 | `entity.baby_pig.ambient` | 1932 | `block.cinnabar.place` |
| 605 | `entity.endermite.death` | 1269 | `entity.baby_pig.eat` | 1933 | `block.cinnabar.hit` |
| 606 | `entity.endermite.hurt` | 1270 | `entity.baby_pig.hurt` | 1934 | `block.cinnabar.fall` |
| 607 | `entity.endermite.step` | 1271 | `entity.baby_pig.death` | 1935 | `entity.sulfur_cube.absorb` |
| 608 | `entity.ender_pearl.throw` | 1272 | `entity.pig.ambient` | 1936 | `entity.sulfur_cube.bounce` |
| 609 | `block.end_gateway.spawn` | 1273 | `entity.pig.hurt` | 1937 | `entity.sulfur_cube.death` |
| 610 | `block.end_portal_frame.fill` | 1274 | `entity.pig.death` | 1938 | `entity.sulfur_cube.eject` |
| 611 | `block.end_portal.spawn` | 1275 | `entity.pig.eat` | 1939 | `entity.sulfur_cube.hurt` |
| 612 | `entity.evoker.ambient` | 1276 | `entity.pig_mini.ambient` | 1940 | `entity.sulfur_cube.jump` |
| 613 | `entity.evoker.cast_spell` | 1277 | `entity.pig_mini.hurt` | 1941 | `entity.sulfur_cube.regular.hit` |
| 614 | `entity.evoker.celebrate` | 1278 | `entity.pig_mini.death` | 1942 | `entity.sulfur_cube.regular.push` |
| 615 | `entity.evoker.death` | 1279 | `entity.pig_mini.eat` | 1943 | `entity.sulfur_cube.bouncy.hit` |
| 616 | `entity.evoker_fangs.attack` | 1280 | `entity.pig_big.ambient` | 1944 | `entity.sulfur_cube.bouncy.push` |
| 617 | `entity.evoker.hurt` | 1281 | `entity.pig_big.hurt` | 1945 | `entity.sulfur_cube.slow_bouncy.hit` |
| 618 | `entity.evoker.prepare_attack` | 1282 | `entity.pig_big.death` | 1946 | `entity.sulfur_cube.slow_bouncy.push` |
| 619 | `entity.evoker.prepare_summon` | 1283 | `entity.pig_big.eat` | 1947 | `entity.sulfur_cube.slow_flat.hit` |
| 620 | `entity.evoker.prepare_wololo` | 1284 | `entity.piglin.admiring_item` | 1948 | `entity.sulfur_cube.slow_flat.push` |
| 621 | `entity.experience_bottle.throw` | 1285 | `entity.piglin.ambient` | 1949 | `entity.sulfur_cube.fast_flat.hit` |
| 622 | `entity.experience_orb.pickup` | 1286 | `entity.piglin.angry` | 1950 | `entity.sulfur_cube.fast_flat.push` |
| 623 | `block.eyeblossom.open_long` | 1287 | `entity.piglin.celebrate` | 1951 | `entity.sulfur_cube.light.hit` |
| 624 | `block.eyeblossom.open` | 1288 | `entity.piglin.death` | 1952 | `entity.sulfur_cube.light.push` |
| 625 | `block.eyeblossom.close_long` | 1289 | `entity.piglin.jealous` | 1953 | `entity.sulfur_cube.fast_sliding.hit` |
| 626 | `block.eyeblossom.close` | 1290 | `entity.piglin.hurt` | 1954 | `entity.sulfur_cube.fast_sliding.push` |
| 627 | `block.eyeblossom.idle` | 1291 | `entity.piglin.retreat` | 1955 | `entity.sulfur_cube.slow_sliding.hit` |
| 628 | `block.fence_gate.close` | 1292 | `entity.piglin.step` | 1956 | `entity.sulfur_cube.slow_sliding.push` |
| 629 | `block.fence_gate.open` | 1293 | `entity.piglin.converted_to_zombified` | 1957 | `entity.sulfur_cube.sticky.hit` |
| 630 | `item.firecharge.use` | 1294 | `entity.piglin_brute.ambient` | 1958 | `entity.sulfur_cube.sticky.push` |
| 631 | `block.firefly_bush.idle` | 1295 | `entity.piglin_brute.angry` | 1959 | `entity.sulfur_cube.high_resistance.hit` |
| 632 | `entity.firework_rocket.blast` | 1296 | `entity.piglin_brute.death` | 1960 | `entity.sulfur_cube.high_resistance.push` |
| 633 | `entity.firework_rocket.blast_far` | 1297 | `entity.piglin_brute.hurt` | 1961 | `entity.sulfur_cube.explosive.hit` |
| 634 | `entity.firework_rocket.large_blast` | 1298 | `entity.piglin_brute.step` | 1962 | `entity.sulfur_cube.explosive.push` |
| 635 | `entity.firework_rocket.large_blast_far` | 1299 | `entity.piglin_brute.converted_to_zombified` | 1963 | `entity.sulfur_cube.hot.hit` |
| 636 | `entity.firework_rocket.launch` | 1300 | `entity.pillager.ambient` | 1964 | `entity.sulfur_cube.hot.push` |
| 637 | `entity.firework_rocket.shoot` | 1301 | `entity.pillager.celebrate` | 1965 | `entity.sulfur_cube.squish` |
| 638 | `entity.firework_rocket.twinkle` | 1302 | `entity.pillager.death` | 1966 | `block.potent_sulfur.noxious_gas` |
| 639 | `entity.firework_rocket.twinkle_far` | 1303 | `entity.pillager.hurt` | 1967 | `entity.small_sulfur_cube.death` |
| 640 | `block.fire.ambient` | 1304 | `block.piston.contract` | 1968 | `entity.small_sulfur_cube.hurt` |
| 641 | `block.fire.extinguish` | 1305 | `block.piston.extend` | 1969 | `entity.small_sulfur_cube.jump` |
| 642 | `entity.fish.swim` | 1306 | `entity.player.attack.crit` | 1970 | `entity.small_sulfur_cube.squish` |
| 643 | `entity.fishing_bobber.retrieve` | 1307 | `entity.player.attack.knockback` | 1971 | `entity.small_sulfur_cube.eat` |
| 644 | `entity.fishing_bobber.splash` | 1308 | `entity.player.attack.nodamage` | 1972 | `block.shelf_mushroom.break` |
| 645 | `entity.fishing_bobber.throw` | 1309 | `entity.player.attack.strong` | 1973 | `block.shelf_mushroom.fall` |
| 646 | `item.flintandsteel.use` | 1310 | `entity.player.attack.sweep` | 1974 | `block.shelf_mushroom.place` |
| 647 | `block.flowering_azalea.break` | 1311 | `entity.player.attack.weak` | 1975 | `block.shelf_mushroom.step` |
| 648 | `block.flowering_azalea.fall` | 1312 | `entity.player.big_fall` | 1976 | `block.shelf_mushroom.bounce` |
| 649 | `block.flowering_azalea.hit` | 1313 | `entity.player.breath` | 1977 | `block.poplar_leaves.break` |
| 650 | `block.flowering_azalea.place` | 1314 | `entity.player.burp` | 1978 | `block.poplar_leaves.hit` |
| 651 | `block.flowering_azalea.step` | 1315 | `entity.player.death` | 1979 | `block.poplar_leaves.fall` |
| 652 | `entity.fox.aggro` | 1316 | `entity.player.hurt` | 1980 | `block.poplar_leaves.place` |
| 653 | `entity.fox.ambient` | 1317 | `entity.player.hurt_drown` | 1981 | `block.poplar_leaves.step` |
| 654 | `entity.fox.bite` | 1318 | `entity.player.hurt_freeze` | 1982 | `block.poplar_leaves.ambient` |
| 655 | `entity.fox.death` | 1319 | `entity.player.hurt_on_fire` | 1983 | `block.straw_bed.break` |
| 656 | `entity.fox.eat` | 1320 | `entity.player.hurt_sweet_berry_bush` | 1984 | `block.straw_bed.break_leave` |
| 657 | `entity.fox.hurt` | 1321 | `entity.player.levelup` | 1985 | `block.straw_bed.step` |
| 658 | `entity.fox.screech` | 1322 | `entity.player.small_fall` | 1986 | `block.straw_bed.place` |
| 659 | `entity.fox.sleep` | 1323 | `entity.player.splash` | 1987 | `block.straw_bed.hit` |
| 660 | `entity.fox.sniff` | 1324 | `entity.player.splash.high_speed` | 1988 | `block.straw_bed.fall` |
| 661 | `entity.fox.spit` | 1325 | `entity.player.swim` | 1989 | `block.red_shrub.break` |
| 662 | `entity.fox.teleport` | 1326 | `entity.player.teleport` | 1990 | `block.red_shrub.place` |
| 663 | `block.suspicious_sand.break` | 1327 | `entity.polar_bear.ambient` |  |  |

## 15. Worked examples

All numbers are read from the tables above.

1. **Mob effect.** Update Mob Effect for Haste: the effect field is VarInt 2 (byte `02`). Regeneration is 9; Speed is 0. The ids are not alphabetical
   (`speed` 0, `slowness` 1, `haste` 2).
2. **Open Screen.** A crafting table opens menu type `crafting`: VarInt 12 (byte `0C`). A single chest uses `generic_9x3`: 2; a hopper: 16;
   a furnace: 14.
3. **Command argument.** In Commands, a node of type `brigadier:integer` has parser VarInt 3; `entity` 6; `resource_or_tag` 44; `uuid` 61 (the last).
4. **Block entity.** A chest's Block Entity Data carries type 1; a sign 7. (`furnace` is 0.)
5. **Particles.** `block` is 1 and is followed by a VarInt block state id; `flash` is 52 and is followed by an Int ARGB colour; `dust` is 21 (Int colour,
   Float scale); `heart` is 55 and has no option bytes; `vibration` is 58.
6. **Statistics.** "Jumped N times" is stat type 8 (`custom`), value id 23 (`jump`), value N: bytes `08 17` and then N as a VarInt. Blocks mined
   use stat type 0 and a block registry id (24).
7. **Villager metadata.** A plains librarian is `VILLAGER_DATA` (serializer 18) with type 2 (`plains`), profession 9 (`librarian`), then the level VarInt.
   The default profession `none` is id 0 (as is `empty` for fluids; most defaults are not 0).
8. **Sounds.** `entity.allay.ambient_with_item` is sound id 0, so the Holder VarInt is 1 (`01`). `entity.cat.ambient` is id 288 (the first of the
   cat group), so the Holder VarInt is 289, which is `A1 02` as a VarInt (289 = 2 x 128 + 33: low 7 bits 33 = `21` with the continuation bit set =
   `A1`, then `02`). `entity.wolf.ambient` is 1807. An inline sound is always `00` followed by the Identifier. The same sound sent inline needs no table.
9. **Id shift by a group.** `item.honey_bottle.drink` is 844, `item.goat_horn.sound.0` is 845, and `entity.horse.ambient` is 853: the
   eight goat horn entries sit between them, so a table built from `register("...")` statements alone would put `entity.horse.ambient` at 845.
10. **Order trap.** `point_of_interest_type` `test_instance` is 19 and `lightning_rod` is 20 (bootstrap order). Update Tags for the
    the point of interest tags (`acquirable_job_site`, `bee_home`, `village`: the three tag files of the data pack) use these ids, so a swapped pair silently
    puts the wrong types in a tag.
11. **Component ids.** `custom_name` is 6, `max_damage` 2, `tool` 28 (matches 17), `waxed` 120 and `cushion/color` 121 (the last).
    A component patch that adds `custom_name` writes VarInt 6 first.
12. **Entity types.** `pig` is 101 (`65`), `item` 72, `player` 159; sorting the keys alphabetically would give wrong ids for the six entries of section 11.

## 16. Validation

Results of the checks made in this round (all mechanical unless stated):

| # | Check | Result |
|---|---|---|
| 1 | Number of static registries in `BuiltInRegistries.<clinit>` | 95 (84 + 6 + 4 + 1) |
| 2 | `MappedRegistry.register` assigns `byId.size()`; no explicit-id writer; `freeze` reads the id list once (for the component lookup) but never modifies it | read, section 2.1 |
| 3 | For each pattern-A class, number of register calls in `<clinit>` equals the number of entries listed in this document (not the number of `putstatic`, which differs where section 2.3 lists non-registered static fields) | equal for all 16 classes counted (mob effect 40, particle 128, menu 25, game event 61, component 122, attribute 40, potion 46, entity 161, block entity 49, fluid 5, stats 87, map decoration 40, debug 16, recipe type 8, recipe book category 13, position source 2) |
| 4 | Only one class registers into each registry (scan of all classes of the jar for a register call after a `BuiltInRegistries.<NAME>` read) | yes for mob effect, attribute, particle, menu, block entity, entity, potion, game event, sound, fluid, component, stat, custom stat, recipe book category, map decoration, position source, recipe type, consume effect, debug subscription |
| 5 | Entity type ids vs 21 §2 | 161 of 161 rows equal |
| 6 | Data component ids vs 17 §1.2 | 43 of 43 ids equal (42 table rows, one merging ids 53 and 54); total 122 equals 17's count |
| 7 | Argument type ids vs 05a | 62 of 62 equal |
| 8 | Entity metadata serializers vs 00 §13.2 | 44 of 44 equal |
| 9 | Particle types with options vs 05a's option table | 22 of 22 equal (names), the other 106 are simple |
| 10 | Menu `crafting` = 12 vs 13 §3.5 | equal |
| 11 | Recipe display and slot display ids vs 05b | equal (05a and 05b both list slot display 10 `composite`) |
| 12 | Number format ids vs 05b (inferred there) | confirmed |
| 13 | Position source ids vs 05a | equal |
| 14 | Sound events: 1897 singles + 94 generated = 1991, all distinct | yes (8 + 18 + 6 + 8 + 12 + 42 = 94) |
| 15 | `PoiTypes` bootstrap order vs field order | differ at ids 19 and 20 |
| 16 | Update Tags registries with tag files in the data pack (static ones: block, entity_type, fluid, game_event, item, point_of_interest_type, potion; the others are synchronized registries or timeline and villager_trade) | counts read with `unzip -Z1 \| grep -v '/$'` of `data/minecraft/tags/` |

How a COBOL implementation should test itself:

- Build the tables of sections 4 to 13 into a copybook and assert the counts: mob effect 40, attribute 40, potion 46, particle type 128,
  game event 61, fluid 5, block entity type 49, menu 25, map decoration 40, villager type 7, villager profession 15, point of interest 21, stat type 9,
  custom stat 78, component 122, consume effect 5, number format 3, recipe display 5, slot display 11, recipe book category 13, recipe type 8,
  recipe serializer 22, data component predicate type 15, argument type 62, debug subscription 16, position source 2, sound event 1991, entity type 161, serializer 44.
- Assert the anchor ids of section 15 (examples 1 to 12).
- Assert that the id of every entry in these tables is its row position, with no gaps.
- Compare against the reference client with the vanilla data generator reports (04 §5.1: `registries.json` gives `protocol_id` for every entry); the
  tool of the design map (GAP-1 ids) may produce the copybook from the user's jar instead of from this document.

## 17. Open questions

1. **Completeness of the registry list, and registries with no table.** The static initialiser of `BuiltInRegistries` creates 95 registries (section 1). I classified every one:
   - Tabulated in this document (33): `attribute`, `block_entity_type`, `command_argument_type`, `consume_effect_type`, `custom_stat`, `data_component_predicate_type`, `data_component_type`, `debug_subscription`, `enchantment_effect_component_type`, `enchantment_entity_effect_type`, `enchantment_level_based_value_type`, `enchantment_location_based_effect_type`, `enchantment_provider_type`, `enchantment_value_effect_type`, `fluid`, `game_event`, `map_decoration_type`, `menu`, `mob_effect`, `number_format_type`, `particle_type`, `point_of_interest_type`, `position_source_type`, `potion`, `recipe_book_category`, `recipe_display`, `recipe_serializer`, `recipe_type`, `slot_display`, `sound_event`, `stat_type`, `villager_profession`, `villager_type`.
   - Owned by another document (4): `block` (24), `item` (25), `entity_type` (21 §2, verified in section 11), `game_rule` (16; the wire form is a key, section 3).
   - Not on the wire (58): `activity`, `attribute_type`, `biome_source`, `block_predicate_type`, `block_state_provider_type`, `carver_type`, `chunk_generator`, `chunk_status`, `context_float_provider_type`, `context_int_provider_type`, `context_key_set`, `creative_mode_tab`, `density_function_type`, `dialog_action_type`, `dialog_body_type`, `dialog_type`, `entity_sub_predicate_type`, `environment_attribute`, `feature_size_type`, `feature_type`, `float_provider_type`, `foliage_placer_type`, `height_provider_type`, `incoming_rpc_method`, `input_control_type`, `int_provider_type`, `loot_condition_type`, `loot_function_type`, `loot_nbt_provider_type`, `loot_pool_entry_type`, `loot_score_provider_type`, `material_condition_type`, `material_rule_type`, `memory_module_type`, `outgoing_rpc_method`, `permission_check_type`, `permission_type`, `placement_modifier_type`, `pool_alias_binding_type`, `pos_rule_test`, `root_placer_type`, `rule_block_entity_modifier`, `rule_test`, `sensor_type`, `slot_source_type`, `spawn_condition_type`, `structure_piece`, `structure_placement`, `structure_pool_element`, `structure_processor`, `structure_type`, `test_environment_definition_type`, `test_function`, `test_instance_type`, `ticket_type`, `tree_decorator_type`, `trunk_placer_type`, `trigger_types`.
   For the 58 not on the wire, the basis is the jar-wide search of Open question 13 (no packet class pairs them with a numeric id) plus the reading of 05a, 05b, 05c, 00, 03 and 09. I did not read the contents (keys) of these registries: the data tool (design map GAP-1 ids, RS6, RS19, RS20) owns those names. `attribute_type` registers at least 15 names in its bootstrap (not fully read), and the dialog action registry is registered partly through a static map of `StaticAction` (not fully decoded).
2. **Synchronized registries** are not covered (04 §3, 04 §4): their ids are the order of Registry Data.
3. **`makeRegistryStatType` registry arguments** were read from the static initialiser: block, item (five times), entity type (twice), custom
   stat. The semantics of the value that follows the two ids in Award Statistics (the stat value VarInt) are 05a's.
4. **Loot-related ids in packets.** None was found in 05a, 05b, 05c or 09: loot tables and their codec registries are server-side data. No loot id
   needs a table. (Not every field of every packet was re-read here; the scan was the registry references listed in section 3.)
5. **Save data.** That save and data files use keys and not ids was read for `MobEffect`, `Attribute`, `Potion`, `MapDecorationType`,
   `VillagerData`, `EntityType`, `ParticleTypes`, `DataComponentType`, `ConsumeEffect`; it is inferred for the other registries of the document
   (`BlockEntityType` has no codec in its own class). A numeric id in a save file other than the id enums of section 12 was not found.
6. **Inline sounds.** The packet codec allows an inline sound event, but whether the client plays a sound whose Identifier is not in its
   `sounds.json`, or how it treats a fixed range, was not read here.
7. **The `Holder` id of a data-driven registry used in a component** (for example `instrument`, `jukebox_playable`, trim patterns, painting
   variants) is the Registry Data order (04), not this document; the component payload layouts that mix both are 17's and 00 §12's.
8. **Enum ids.** Section 12.2 covers the enums of the entity metadata serializers and `SwingAnimationType`. Other id enums on the wire (the
   Game Event packet's event ids, the recipe book `GameType`, the `Entity Event` ids, ...) are owned by their packet documents.
9. **`Direction` id** is the `data3d` field (the first integer after the ordinal), read from the enum constants; the id function used by the stream
    codec is `get3DDataValue`, read in the bootstrap method arguments of the class.
10. **Class names of the content classes** (`EntityTypes`, `BlockEntityTypes`, `MenuType`) are as in this artifact and differ from earlier versions in
    places; nothing in this document relies on another version.
11. **19 and 20 id listings.** Closed: all 68 mob rows with an entity id in 19 and 20 equal 21 §2 and section 11.
12. **Payload after a data component predicate type** (section 8.4): the layout of the predicate value that follows the type id inside
    `DataComponentPredicate.STREAM_CODEC`, and of `DataComponentMatchers` and `BlockPredicate` around it, was not read in this round.
13. **Registry ids reaching the wire (jar-wide scan).** I read `DebugGameEventInfo` (game event), `DebugPoiInfo` (point of interest type) and `DebugHiveInfo` (block). I scanned every class of the jar for `ByteBufCodecs.registry` and `holderRegistry` calls against a static registry: they are these three plus the debug subscription classes (`DebugSubscription$Event`, `DebugSubscription$Update`, `ServerboundDebugSubscriptionRequestPacket`, registry `debug_subscription`). I scanned a second pattern, classes that pair a `BuiltInRegistries` reference with `getId`, `byId` or `asHolderIdMap`: `ClientboundCommandsPacket`, `Item`, `BeaconMenu` (mob effect id plus 1 in the data slots, section 4.1), `ParticleEngine` and `ParticleResources` (client side only). I did not scan for other forms of numbering (for example a registry id packed into a larger integer by a class that does not name `BuiltInRegistries`). The block transformer and decorated pot pattern registries are `Registries` keys only (data-driven), so they have no table. Closed for the two patterns scanned.
14. **Single-registering-class check (section 2.1 item 5).** For the sound event helper methods and the pattern-C registries (those registered through a bootstrap method) only the bootstrap method was read; no jar-wide scan for other callers was made. That no other class registers into them is inferred.
15. **Container data packet.** The beacon data slot values (section 4.1) are numbers in the menu's container data. I did not read the packet that carries them (Set Container Property) in this round, and 05a and 05b do not describe the beacon slots. The integer width of the value on the wire was not read (recalled, not verified).
