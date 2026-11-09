# Item registry, part 6: spawn eggs and special items (statements 940 to 1104, registry ids 1280 to 1459)

| Item | Value |
|---|---|
| Covers | The registry entries of `net.minecraft.world.item.Items` from statement 940 (`chicken_spawn_egg`) to statement 1104 (`debug_stick`): the 88 spawn eggs, then the items `experience_bottle` to `debug_stick` including the 16 banners that one statement registers. For each: key, statement number, registry id, item class, prototype components and every constant the registering code sets. The engines of the code-defined behaviour: the spawn egg (use on a block, use on a fluid, spawner blocks, dispenser, the generic spawn path of `EntityType`, the entity data merge), written books and the edit and sign packets, skulls and heads (placement, wearing, mob visibility, locator-bar hiding), the item frame, armor stand, end crystal, command block minecart and banner items, the animal armor items, the thrown items (experience bottle, splash and lingering potions), the arrow items, the totem, the knowledge book, the debug stick, the empty map item, and the foods and consumables of this range. |
| Does not cover | Statements 0 to 939 and 1105 onward (siblings: [25-item-registry-1-model-and-blocks-a.md](25-item-registry-1-model-and-blocks-a.md) holds the shared model, the id rule, the `Item.Properties` builders, the default components and the `Foods` and `Consumables` tables; [25-item-registry-5-buckets-maps-potions-misc.md](25-item-registry-5-buckets-maps-potions-misc.md) ends at statement 939; part 7 starts with `music_disc_13`, statement 1105). Music discs, disc fragment, trident, nautilus armor: part 7. Tool, weapon and shield numbers already in 17 (mace, spears, shield, firework use): cited, not repeated. Data rows the extraction tool copies (item models, `en_us`, recipes, loot, tags, `context_int_provider`, `trim_material`): named by key, never listed (22, 23, 26). Entity internals of the spawned mobs (18 to 21, 44, 45). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for lambda and bootstrap targets), of `assets/minecraft/lang/en_us.json`, of `assets/minecraft/items/*.json` and of `data/minecraft/jukebox_song` (names and counts only), with no execution. Class, method and field names in backticks say where a fact was read. Values not read are marked "(inferred)" or "(recalled, not verified)" and are listed in the Open questions. |
| Status | Written for round RS5 (design map Part 5 GAP-2, Part 6 row RS5), part 6 of 8. |

"17 section 3.6" means section 3.6 of [17-tools-weapons-and-combat.md](17-tools-weapons-and-combat.md); "25-1 section 8.3" means section 8.3 of
[25-item-registry-1-model-and-blocks-a.md](25-item-registry-1-model-and-blocks-a.md); "25-5 section 4" is the same for
[25-item-registry-5-buckets-maps-potions-misc.md](25-item-registry-5-buckets-maps-potions-misc.md); "29 section 9" is
[29-block-updates-and-placement.md](29-block-updates-and-placement.md); "44-8" is
[44-residual-mob-questions-8-vehicles-and-projectiles.md](44-residual-mob-questions-8-vehicles-and-projectiles.md); "46 section n" is
[46-registry-ids.md](46-registry-ids.md). Class names in backticks say where a fact was read. They are not the design.

## Contents

1. [Scope and the three numberings](#1-scope-and-the-three-numberings)
2. [What this part adds to the shared model](#2-what-this-part-adds-to-the-shared-model)
3. [Spawn eggs](#3-spawn-eggs)
4. [The rows](#4-the-rows)
5. [Foods and consumables of this range](#5-foods-and-consumables-of-this-range)
6. [Books](#6-books)
7. [Skulls and heads](#7-skulls-and-heads)
8. [Items that place entities or blocks](#8-items-that-place-entities-or-blocks)
9. [Animal armor (horse armor)](#9-animal-armor-horse-armor)
10. [Thrown items and arrows](#10-thrown-items-and-arrows)
11. [Other special items](#11-other-special-items)
12. [Items taken from 17](#12-items-taken-from-17)
13. [Worked examples](#13-worked-examples)
14. [Validation](#14-validation)
15. [Open questions](#15-open-questions)

## 1. Scope and the three numberings

The brief for this part named "registry indices 940 to 1104". Those numbers are **statement numbers** in the sense of 25-1 section 2.2
and section 2.3: the position of the `putstatic` in `Items.<clinit>`, counting a collection field (`ColorCollection`, `WeatheringCopperCollection`)
as one statement. The brief's item names agree with that reading (`mace` 1034, `tipped_arrow` 1089, `shield` 1091, `piglin_head` 1050: each is the statement number
below). They are not registry ids. Three numbers exist for every entry:

| Number | Meaning | Example (`chicken_spawn_egg`) |
|---|---|---|
| Statement S | **0-based** position among the 1253 statements of `Items.<clinit>` (they run 0 to 1252; `chicken_spawn_egg` is the 941st statement, `BANNER` is S 1077, `debug_stick` S 1104, `music_disc_13` S 1105; a reader counting from 1 is off by one) | 940 |
| Item field F | position among the 1218 plain `Item` fields only (collections skipped) | 912 |
| Registry id I | the number of items registered before it; this is what packets carry (46 section 2.1, 25-1 section 2.1) | 1280 |

Relations read for this range (25-1 section 2.4 computes the same totals; both were derived independently from the field types in `Items`):

- Before statement 940 there are 28 collection statements (18 colour collections and 10 weathering collections), each adding extra items
  beyond its one statement: 18 x 15 + 10 x 7 = 340. So **I = S + 340** for S = 940 to 1076.
- Statement 1077 is the colour collection `BANNER`: 16 items, ids 1417 to 1432 (25-1 section 2.3 gives the same range).
- After it **I = S + 355** for S = 1078 to 1104 (340 + 15).
- The range therefore holds 88 spawn eggs (ids 1280 to 1367), 76 single-item statements and the 16 banners: 165 statements, 180 items, ids 1280 to 1459, contiguous.
- The registry has 1658 items in total (ids 0 to 1657), and the jar holds 1658 item model definitions (`assets/minecraft/items/*.json`, `air.json` included),
  one per registry entry (section 14, check 1).
- The last row of this part is `debug_stick` (S 1104, id 1459). Part 7 starts at S 1105, `music_disc_13`, id 1460.

Statement and id columns below are computed from the field types read in `Items`; no registry dump was available (Open question 1).

**Where the other special items named by the round brief are specified.** They are registered outside statements 940 to 1104 and are covered by the sibling parts (checked by key in each part's rows):

| Item(s) | Document |
|---|---|
| `bundle`, the 16 `dyed_bundle` items (`bundle_contents`), `compass`, `recovery_compass`, lodestone-tracker compass behaviour, maps, potions, buckets | [25-item-registry-5-buckets-maps-potions-misc.md](25-item-registry-5-buckets-maps-potions-misc.md) (25-5 section 7) |
| `structure_block`, `jigsaw` (`GameMasterBlockItem`, rarity epic), `command_block`, barrier-like game-master items | [25-item-registry-4-boats-food-armor-signs.md](25-item-registry-4-boats-food-armor-signs.md) |
| `lodestone` (plain `BlockItem`), `ominous_bottle`, `ominous_trial_key`, trial key, trial spawner, vault | [25-item-registry-8-late-items-templates-sherds-trial.md](25-item-registry-8-late-items-templates-sherds-trial.md) |
| `enchanted_book` (`stored_enchantments`), `written_book`, `knowledge_book`, `totem_of_undying`, `nether_star`, `debug_stick`, `command_block_minecart` | this document (rows in section 4; engines in sections 6, 8 and 11) |

## 2. What this part adds to the shared model

The id rule, the registering helpers (`registerItem`, `registerBlock`, `registerSpawnEgg`), `Item$Properties` defaults, the 13 default
components (`COMMON_ITEM_COMPONENTS` plus `item_name` and `item_model`), the builder table, `Foods` and `Consumables` are in 25-1
section 2 to section 9 and are not repeated. Facts re-read here that this part depends on:

1. **Description id and model.** `Item$Properties.effectiveDescriptionId` is `item.<namespace>.<path>` for items registered with `registerItem`
   and `block.<namespace>.<path>` for items registered with `registerBlock` (which calls `useBlockDescriptionPrefix`). `useItemDescriptionPrefix`
   switches back. The `item_model` component is always the item's own identifier (the model function is `ResourceKey.identifier`). `item_name` is the translatable
   component of the description id. Consequences used below: skulls, heads and banners are named by block keys (`block.minecraft.player_head`);
   carrot, potato, torchflower seeds, pitcher pod and beetroot seeds are block items that use the **item** prefix (`createBlockItemWithCustomItemName`), so they are
   named `item.minecraft.carrot` and so on while the block is `block.minecraft.carrots` (`en_us.json`: `block.minecraft.carrots` = "Carrots", no `block.minecraft.carrot`).
2. **Durability and stacking.** The validator added by `finalizeInitializer` rejects an item whose prototype has a `damage` component and a `max_stack_size` above 1
   (`Item cannot have both durability and be stackable`). Every durable row below has stack size 1.
3. **Plain `Item`.** `registerItem(key)` with no further call is `new Item(Properties)` with the default components only. A row marked class `Item` and "none" is
   exactly the 13 default components.
4. **Block-item map.** `BlockItem.registerBlocks` enters the placed block in `Item.BY_BLOCK`; `StandingAndWallBlockItem.registerBlocks` enters the standing and the wall
   block, so both map back to the one item (skulls, heads, banners).

New builder methods that 25-1 section 6.4 names and this part needs the content of: `Properties.equippableUnswappable`, `Properties.loweredMobVisibility`, `Waypoint.addHideAttribute` (section 7),
`Properties.horseArmor` (section 9). `Properties.spawnEgg` is in section 3.1.

## 3. Spawn eggs

### 3.1 Registration

`Items.registerSpawnEgg(key, entityType)` builds `new Properties().spawnEgg(entityType)` and registers `new SpawnEggItem(properties)`:

| Part | Value |
|---|---|
| Component `entity_data` (id by 46 section 8) | `TypedEntityData.of(entityType, empty CompoundTag)`: type = the entity type, tag = empty compound (the `id` entry of any tag is stripped on construction) |
| `requiredFeatures` | the entity type's own feature set (the set form checks it is a subset of the registry) |
| Stack size | default 64 (no `stacksTo` call) |
| Rarity, durability, anything else | none: the 13 default components plus `entity_data` |
| Description id | `item.minecraft.<key>` ("Chicken Spawn Egg"), model `minecraft:item/<key>` is a plain model with no tint (`assets/minecraft/items/chicken_spawn_egg.json`: type `minecraft:model`; 43: eggs have no tints) |

All 88 statements call `registerSpawnEgg` once; in every statement the item key is `<entity key>_spawn_egg` and the entity argument is `EntityTypes.<ENTITY>` (read for each of the 88: the field names
agree, check 3 of section 14). The entity keys are the lower-case field names (46 section 11 states that `EntityTypeIds` keys are the plain lower-case names; the match of the egg name to the entity name was checked, the match of the
`EntityTypes` field name to the registry key is inferred from that rule).

The wire form of `entity_data` is the composite of the entity type codec (a registry id, 46 section 11) and a compound tag (`TypedEntityData.streamCodec`: type stream codec, then `ByteBufCodecs.COMPOUND_TAG`).
The persistent (JSON/NBT) form is a compound whose `id` string holds the type and whose remaining entries are the tag (`TYPE_TAG` = "id").

### 3.2 The 88 rows

S = statement, Id = registry id (I = S + 340). Left half 940 to 983, right half 984 to 1027.

| S | Id | Key (entity) | S | Id | Key (entity) |
|---|---|---|---|---|---|
| 940 | 1280 | `chicken_spawn_egg` | 984 | 1324 | `camel_husk_spawn_egg` |
| 941 | 1281 | `cow_spawn_egg` | 985 | 1325 | `drowned_spawn_egg` |
| 942 | 1282 | `pig_spawn_egg` | 986 | 1326 | `husk_spawn_egg` |
| 943 | 1283 | `sheep_spawn_egg` | 987 | 1327 | `parched_spawn_egg` |
| 944 | 1284 | `camel_spawn_egg` | 988 | 1328 | `skeleton_spawn_egg` |
| 945 | 1285 | `donkey_spawn_egg` | 989 | 1329 | `skeleton_horse_spawn_egg` |
| 946 | 1286 | `horse_spawn_egg` | 990 | 1330 | `stray_spawn_egg` |
| 947 | 1287 | `mule_spawn_egg` | 991 | 1331 | `wither_spawn_egg` |
| 948 | 1288 | `cat_spawn_egg` | 992 | 1332 | `wither_skeleton_spawn_egg` |
| 949 | 1289 | `parrot_spawn_egg` | 993 | 1333 | `zombie_spawn_egg` |
| 950 | 1290 | `wolf_spawn_egg` | 994 | 1334 | `zombie_horse_spawn_egg` |
| 951 | 1291 | `armadillo_spawn_egg` | 995 | 1335 | `zombie_nautilus_spawn_egg` |
| 952 | 1292 | `bat_spawn_egg` | 996 | 1336 | `zombie_villager_spawn_egg` |
| 953 | 1293 | `bee_spawn_egg` | 997 | 1337 | `cave_spider_spawn_egg` |
| 954 | 1294 | `fox_spawn_egg` | 998 | 1338 | `spider_spawn_egg` |
| 955 | 1295 | `goat_spawn_egg` | 999 | 1339 | `breeze_spawn_egg` |
| 956 | 1296 | `llama_spawn_egg` | 1000 | 1340 | `creaking_spawn_egg` |
| 957 | 1297 | `ocelot_spawn_egg` | 1001 | 1341 | `creeper_spawn_egg` |
| 958 | 1298 | `panda_spawn_egg` | 1002 | 1342 | `elder_guardian_spawn_egg` |
| 959 | 1299 | `polar_bear_spawn_egg` | 1003 | 1343 | `guardian_spawn_egg` |
| 960 | 1300 | `rabbit_spawn_egg` | 1004 | 1344 | `phantom_spawn_egg` |
| 961 | 1301 | `axolotl_spawn_egg` | 1005 | 1345 | `silverfish_spawn_egg` |
| 962 | 1302 | `cod_spawn_egg` | 1006 | 1346 | `slime_spawn_egg` |
| 963 | 1303 | `dolphin_spawn_egg` | 1007 | 1347 | `warden_spawn_egg` |
| 964 | 1304 | `frog_spawn_egg` | 1008 | 1348 | `witch_spawn_egg` |
| 965 | 1305 | `glow_squid_spawn_egg` | 1009 | 1349 | `evoker_spawn_egg` |
| 966 | 1306 | `nautilus_spawn_egg` | 1010 | 1350 | `pillager_spawn_egg` |
| 967 | 1307 | `pufferfish_spawn_egg` | 1011 | 1351 | `ravager_spawn_egg` |
| 968 | 1308 | `salmon_spawn_egg` | 1012 | 1352 | `vindicator_spawn_egg` |
| 969 | 1309 | `squid_spawn_egg` | 1013 | 1353 | `vex_spawn_egg` |
| 970 | 1310 | `tadpole_spawn_egg` | 1014 | 1354 | `blaze_spawn_egg` |
| 971 | 1311 | `tropical_fish_spawn_egg` | 1015 | 1355 | `ghast_spawn_egg` |
| 972 | 1312 | `turtle_spawn_egg` | 1016 | 1356 | `happy_ghast_spawn_egg` |
| 973 | 1313 | `allay_spawn_egg` | 1017 | 1357 | `hoglin_spawn_egg` |
| 974 | 1314 | `mooshroom_spawn_egg` | 1018 | 1358 | `magma_cube_spawn_egg` |
| 975 | 1315 | `sniffer_spawn_egg` | 1019 | 1359 | `piglin_spawn_egg` |
| 976 | 1316 | `sulfur_cube_spawn_egg` | 1020 | 1360 | `piglin_brute_spawn_egg` |
| 977 | 1317 | `copper_golem_spawn_egg` | 1021 | 1361 | `strider_spawn_egg` |
| 978 | 1318 | `iron_golem_spawn_egg` | 1022 | 1362 | `zoglin_spawn_egg` |
| 979 | 1319 | `snow_golem_spawn_egg` | 1023 | 1363 | `zombified_piglin_spawn_egg` |
| 980 | 1320 | `trader_llama_spawn_egg` | 1024 | 1364 | `ender_dragon_spawn_egg` |
| 981 | 1321 | `villager_spawn_egg` | 1025 | 1365 | `enderman_spawn_egg` |
| 982 | 1322 | `wandering_trader_spawn_egg` | 1026 | 1366 | `endermite_spawn_egg` |
| 983 | 1323 | `bogged_spawn_egg` | 1027 | 1367 | `shulker_spawn_egg` |

The entity of each row is its key without the `_spawn_egg` suffix. Eggs exist for 88 entity types; the other types of 21 section 2 (161 in all) have none (the egg table above is complete for the registry).

### 3.3 Using an egg on a block (`SpawnEggItem.useOn`)

Inputs: the use context (level, clicked position, clicked face, player, stack in hand). Steps, in order:

1. `type` = the entity type of the stack's `entity_data` (null when the component is absent). If `type` is null, or `type.canSpawn(level)` is false (rule in 3.6): result `FAIL`.
2. On a client level the result is `SUCCESS` and nothing else happens (the server decides).
3. If the block entity at the clicked position implements `Spawner` (a spawner block, trial spawner and the like):
   a. if `level.isSpawnerBlockEnabled()` is false: send the system message `advMode.notEnabled.spawner` ("Spawner blocks are not enabled", `en_us.json`) to the player (when a server player) and return `FAIL`;
   b. if the stack has an `entity_data` value **and** a player is present **and** the server's op list contains that player: `spawner.setEntityData(data, level.random)`; otherwise `spawner.setEntityId(type, level.random)`;
   c. `level.sendBlockUpdated(pos, state, state, 3)`, game event `BLOCK_CHANGE` at the position with the player as source, `stack.shrink(1)` (an unconditional shrink, no creative exemption: read, `ItemStack.consume` is the one with the exemption, 3.4 step 2), result `SUCCESS`.
4. Otherwise spawn a mob: `spawnPos` = the clicked position if the clicked block state's collision shape is empty, else the clicked position moved one block along the clicked face.
   Call the spawn helper (3.4) with (type, player, stack, spawnPos, `alignToBlock` = true, `lowerToSurface` = (spawnPos != clickedPos AND face == UP)). Return its result.

### 3.4 The spawn helper (`SpawnEggItem.spawnMob`) and `EntityType.spawn`

`spawnMob(type, owner, stack, level, pos, A, B)`:

1. `entity = type.spawn(level, stack, owner, pos, SPAWN_ITEM_USE, A, B)`.
2. If `entity` is not null: `stack.consume(1, owner)` (read, `ItemStack.consume(int, LivingEntity)`: the shrink is skipped only when the owner is not null and `hasInfiniteMaterials()` is true, that is a creative-mode player; otherwise the stack shrinks by the count. A null owner, such as a dispenser, always shrinks, so a creative player placing a mob keeps the egg), game event `ENTITY_PLACE` at `pos` (entity null as source), result `SUCCESS`; else `FAIL`.

`EntityType.spawn(level, stack, owner, pos, reason, A, B)` builds a post-spawn processor and calls the same-named method with it:

- processor = nothing when `stack` is null, else (`createDefaultStackConfig`): first apply the stack's implicit components to the entity (`Entity.applyComponentsFromItemStack`, which in the base class applies `custom_name` through `setCustomName`
  and stores `custom_data`; entity classes add the components that they understand, for example colour and variant components: the class overrides are not read here, Open question 10), then the entity data merge of 3.5 when the stack has `entity_data`.
- `spawn(level, processor, pos, reason, A, B)` calls `create(...)`; if the result is not null: `level.addFreshEntityWithPassengers(entity)`, and when the entity is a `Mob`, `playAmbientSound()`.

`EntityType.create(level, processor, pos, reason, A, B)`, in order:

1. `entity = create(level, reason)`: returns null (so the spawn fails) unless `ignoreChecks` or `canSpawn(level)` (3.6). The entity is built by the type's factory.
2. Vertical offset `dy`: if A is false, `dy` = 0. If A is true: first `entity.setPos(pos.x + 0.5, pos.y + 1, pos.z + 0.5)` so that its bounding box is above the block, then
   `dy = getYOffset(level, pos, B, entity.boundingBox)`.
3. `getYOffset`: `box` = the block cell at `pos` (unit AABB); if B, `box` is extended by 1 downwards (`expandTowards(0, -1, 0)`). `collisions` = the collision shapes of `level` inside `box` (no entity excluded).
   `dy = 1.0 + Shapes.collide(Y axis, entityBox, collisions, limit)` with `limit` = -2.0 when B and -1.0 when not B. `Shapes.collide` (read) passes the movement through each shape's `collide` in turn and returns the reduced movement; a movement with absolute value below 1.0E-7 returns 0.0 immediately, and with no shape it returns the movement unchanged. The per-shape clipping scan in `VoxelShape.collideX` was only partly read (Open question 8).
4. Place the entity at (`pos.x + 0.5`, `pos.y + dy`, `pos.z + 0.5`) with yaw = `wrapDegrees(level.random.nextFloat() * 360.0)` (one `nextFloat`) and pitch 0 (`snapTo`).
5. If the entity is a `Mob`: head yaw and body yaw are set to the yaw; `finalizeSpawn(level, level.getCurrentDifficultyAt(blockPosition), reason, null)` is called (per-type initialisation: 18, 44).
6. Apply the processor (3.5, components first).

### 3.5 The entity data merge (`EntityType.updateCustomEntityTag`, `TypedEntityData.loadInto`)

Applied when the stack has `entity_data`:

1. Nothing happens if the server is null, the data is null, or the entity's type differs from the data's type.
2. For an entity type in the set `EntityTypes.OP_ONLY_CUSTOM_DATA` (`falling_block`, `command_block_minecart`, `spawner_minecart`; the set was read): on a server level the data is applied **only** if the `owner` is a player on the server's op list. A null owner (dispenser) or a non-player owner applies nothing.
3. `loadInto(entity)`: save the entity without its `id` into a compound; merge the item's tag over it (the item's entries replace those of the entity); load the merged compound back into the entity (`Entity.load`); restore the entity's original UUID (the UUID of the new entity survives
   even if the item tag contains one). The entity-save schema is 45.

### 3.6 `EntityType.canSpawn(level)`

True only if (a) the type is enabled by the level's enabled feature flags, and (b) the type is allowed in peaceful mode (`isAllowedInPeaceful`) **or** the level difficulty is not `PEACEFUL`. A hostile type's egg therefore
fails in peaceful difficulty (the per-type `isAllowedInPeaceful` flag values come from the type builders in 21 section 2: not re-read here, Open question 11).

### 3.7 Using an egg in the air (`SpawnEggItem.use`)

1. Ray cast from the player's eyes with fluid mode `SOURCE_ONLY` (`Item.getPlayerPOVHitResult`). If the hit is not a block hit: `PASS`.
2. `type` null or `!canSpawn`: `FAIL`. Client level: `SUCCESS`.
3. If the hit block is not a `LiquidBlock`: `PASS` (the normal `useOn` handles solid blocks).
4. If `!level.mayInteract(player, pos)` or `!player.mayUseItemAt(pos, face, stack)`: `FAIL`.
5. `spawnMob(type, player, stack, level, pos, A = false, B = false)` with `pos` the fluid hit block position (no offset). If it returns `SUCCESS`, award the stat `item_used` for the egg item. Return the result.

### 3.8 Dispenser (`core.dispenser.SpawnEggItemBehavior`)

`execute(source, stack)`: `facing` = the dispenser's `FACING`; `type` = the stack's egg type. If `type` is null the method returns the original stack unchanged (read: no spawn, no shrink, no game event).
Otherwise `pos` = the dispenser position moved one block along `facing`, and `type.spawn(level, stack, null, pos, DISPENSER, A = (facing != UP), B = false)` is called inside an exception guard:

- result null: the original stack is returned unchanged (no shrink, no game event);
- an exception: the message `Error while dispensing spawn egg from dispenser at <pos>` is logged and `ItemStack.EMPTY` is returned (the dispensed slot is emptied);
- success: `stack.shrink(1)`, game event `ENTITY_PLACE` at the dispenser position (no source entity), the shrunk stack is returned.

The owner passed is null, so `OP_ONLY_CUSTOM_DATA` types get no entity data (3.5, step 2). Binding (read in `DispenserBlock`): the dispenser first looks the item up in its behaviour map; when none is registered it uses the default method, which tests in order: stack has `equippable` gives the equipment behaviour; stack is in the tag `sulfur_cube_swallowable` gives the sulfur cube behaviour; stack's item is a `SpawnEggItem` AND the stack has the component `entity_data` gives `SpawnEggItemBehavior`; otherwise the plain default behaviour. No reference to `SpawnEggItemBehavior` exists in `DispenseItemBehavior` or `SpawnEggItem`, so an egg without `entity_data` is dispensed by the plain default behaviour (a dropped item) unless the map holds an entry (the `bootStrap` map was not enumerated: Open question 3).

### 3.9 Offspring and the op warning

- `SpawnEggItem.spawnOffspringFromSpawnEgg(player, parentMob, type, level, position, stack)`: used by mob interaction code (not read here). If `stack`'s egg type differs from `type`: no result. The baby is `getBreedOffspring(level, parent)` for an `AgeableMob`, else a fresh `type.create(level, SPAWN_ITEM_USE)` with `setBaby(true)`;
  if the result is not a baby: no result. It is placed at `position` with yaw 0 and pitch 0, `applyComponentsFromItemStack(stack)`, added with passengers, and one item is consumed.
- `SpawnEggItem.byId(type)` finds an egg whose `entity_data` has that type (used by "pick block"); `spawnsEntity(stack, type)` is `getType(stack) == type`.
- `shouldPrintOpWarning` (client tooltip): true when the player has the gamemaster permission and the stack's entity type is in `OP_ONLY_CUSTOM_DATA` (the third condition is `onlyOpCanSetNbt`).

## 4. The rows

Statements 1028 to 1104 after the eggs. "Components beyond the common set" follows the schema of 25-1 section 10: the 13 default components of 25-1 section 7.1 are present in every row and not repeated.
`fuel`, `compostable` and `cooking_fuel` give the provider key (25-1 section 9). "waypoint hide modifier" and "equippable head unswappable" are defined in section 7.
"Item" in the Class column means the base class `Item` (a plain registration). Foods: the `FoodProperties` and `Consumable` of the named constant (25-1 section 8.2, section 8.3; section 5 here).

| S | Id | Key | Class | Max stack | Components beyond the common set |
|---|---|---|---|---|---|
| 1028 | 1368 | `experience_bottle` | ExperienceBottleItem | 64 | rarity uncommon; glint override true |
| 1029 | 1369 | `fire_charge` | FireChargeItem | 64 | none |
| 1030 | 1370 | `wind_charge` | WindChargeItem | 64 | `use_cooldown` 0.5 s, no group |
| 1031 | 1371 | `writable_book` | WritableBookItem | 1 | `writable_book_content` empty |
| 1032 | 1372 | `written_book` | WrittenBookItem | 16 | glint override true |
| 1033 | 1373 | `breeze_rod` | Item | 64 | none |
| 1034 | 1374 | `mace` | MaceItem | 1 | rarity epic; durability 500; `tool`, `weapon`, attributes, enchantable 15, repairable `breeze_rod` (17 section 2.6) |
| 1035 | 1375 | `item_frame` | ItemFrameItem (entity `item_frame`) | 64 | none |
| 1036 | 1376 | `glow_item_frame` | ItemFrameItem (entity `glow_item_frame`) | 64 | none |
| 1037 | 1377 | `flower_pot` | BlockItem (block `flower_pot`) | 64 | none |
| 1038 | 1378 | `carrot` | BlockItem (block `carrots`, item name from the item) | 64 | food `carrot`; `villager_food` 1; compostable `medium` |
| 1039 | 1379 | `potato` | BlockItem (block `potatoes`, item name from the item) | 64 | food `potato`; `villager_food` 1; compostable `medium` |
| 1040 | 1380 | `baked_potato` | Item | 64 | food `baked_potato`; compostable `medium_high` |
| 1041 | 1381 | `poisonous_potato` | Item | 64 | food `poisonous_potato`; consumable `poisonous_potato` |
| 1042 | 1382 | `map` | EmptyMapItem | 64 | none |
| 1043 | 1383 | `golden_carrot` | Item | 64 | food `golden_carrot` |
| 1044 | 1384 | `skeleton_skull` | StandingAndWallBlockItem (blocks `skeleton_skull`, `skeleton_wall_skull`) | 64 | rarity uncommon; waypoint hide modifier; equippable head unswappable; `mob_visibility` {skeleton} 0.5 |
| 1045 | 1385 | `wither_skeleton_skull` | StandingAndWallBlockItem (`wither_skeleton_skull`, `wither_skeleton_wall_skull`) | 64 | rarity rare; waypoint hide modifier; equippable head unswappable |
| 1046 | 1386 | `player_head` | PlayerHeadItem (`player_head`, `player_wall_head`) | 64 | rarity uncommon; waypoint hide modifier; equippable head unswappable |
| 1047 | 1387 | `zombie_head` | StandingAndWallBlockItem (`zombie_head`, `zombie_wall_head`) | 64 | rarity uncommon; waypoint hide modifier; equippable head unswappable; `mob_visibility` {zombie} 0.5 |
| 1048 | 1388 | `creeper_head` | StandingAndWallBlockItem (`creeper_head`, `creeper_wall_head`) | 64 | rarity uncommon; waypoint hide modifier; equippable head unswappable; `mob_visibility` {creeper} 0.5 |
| 1049 | 1389 | `dragon_head` | StandingAndWallBlockItem (`dragon_head`, `dragon_wall_head`) | 64 | rarity epic; waypoint hide modifier; equippable head unswappable |
| 1050 | 1390 | `piglin_head` | StandingAndWallBlockItem (`piglin_head`, `piglin_wall_head`) | 64 | rarity uncommon; waypoint hide modifier; equippable head unswappable; `mob_visibility` {piglin, piglin_brute} 0.5 |
| 1051 | 1391 | `nether_star` | Item | 64 | rarity rare; glint override true; `damage_resistant` tag `is_explosion` |
| 1052 | 1392 | `pumpkin_pie` | Item | 64 | food `pumpkin_pie`; compostable `always_add_one` |
| 1053 | 1393 | `firework_rocket` | FireworkRocketItem | 64 | `fireworks` = (flight duration 1, no explosions) (17 section 3.13) |
| 1054 | 1394 | `firework_star` | Item | 64 | none |
| 1055 | 1395 | `enchanted_book` | Item | 1 | rarity rare; `stored_enchantments` empty; glint override true |
| 1056 | 1396 | `nether_brick` | Item | 64 | none |
| 1057 | 1397 | `resin_brick` | Item | 64 | `provides_trim_material` = trim material `resin` |
| 1058 | 1398 | `prismarine_shard` | Item | 64 | none |
| 1059 | 1399 | `prismarine_crystals` | Item | 64 | none |
| 1060 | 1400 | `rabbit` | Item | 64 | food `rabbit` |
| 1061 | 1401 | `cooked_rabbit` | Item | 64 | food `cooked_rabbit` |
| 1062 | 1402 | `rabbit_stew` | Item | 1 | food `rabbit_stew`; `use_remainder` `bowl` |
| 1063 | 1403 | `rabbit_foot` | Item | 64 | none |
| 1064 | 1404 | `rabbit_hide` | Item | 64 | none |
| 1065 | 1405 | `armor_stand` | ArmorStandItem | 16 | none |
| 1066 | 1406 | `copper_horse_armor` | Item (horse armor, material copper) | 1 | section 9 |
| 1067 | 1407 | `iron_horse_armor` | Item (horse armor, material iron) | 1 | section 9 |
| 1068 | 1408 | `golden_horse_armor` | Item (horse armor, material gold) | 1 | section 9 |
| 1069 | 1409 | `diamond_horse_armor` | Item (horse armor, material diamond) | 1 | section 9 |
| 1070 | 1410 | `netherite_horse_armor` | Item (horse armor, material netherite) | 1 | section 9; fire resistant (`is_fire`) |
| 1071 | 1411 | `leather_horse_armor` | Item (horse armor, material leather) | 1 | section 9 |
| 1072 | 1412 | `lead` | LeadItem | 64 | 17 section 3.7 |
| 1073 | 1413 | `name_tag` | NameTagItem | 64 | 17 section 3.7 |
| 1074 | 1414 | `command_block_minecart` | MinecartItem (entity `command_block_minecart`) | 1 | rarity epic |
| 1075 | 1415 | `mutton` | Item | 64 | food `mutton` |
| 1076 | 1416 | `cooked_mutton` | Item | 64 | food `cooked_mutton` |
| 1077 | 1417 to 1432 | `white_banner` to `black_banner` (field `BANNER`, 16 items) | BannerItem (blocks `<colour>_banner`, `<colour>_wall_banner`) | 16 | `cooking_fuel` `cooking/time_wood_blocks`; `banner_patterns` empty (set by the per-colour lambda of `registerBlockItems`, see 8.5) |
| 1078 | 1433 | `end_crystal` | EndCrystalItem | 64 | glint override true |
| 1079 | 1434 | `chorus_fruit` | Item | 64 | food `chorus_fruit`; consumable `chorus_fruit`; `use_cooldown` 1.0 s |
| 1080 | 1435 | `popped_chorus_fruit` | Item | 64 | none |
| 1081 | 1436 | `torchflower_seeds` | BlockItem (block `torchflower_crop`, item name from the item) | 64 | compostable `low` |
| 1082 | 1437 | `pitcher_pod` | BlockItem (block `pitcher_crop`, item name from the item) | 64 | compostable `low` |
| 1083 | 1438 | `beetroot` | Item | 64 | food `beetroot`; `villager_food` 1; compostable `medium` |
| 1084 | 1439 | `beetroot_seeds` | BlockItem (block `beetroots`, item name from the item) | 64 | compostable `low` |
| 1085 | 1440 | `beetroot_soup` | Item | 1 | food `beetroot_soup`; `use_remainder` `bowl` |
| 1086 | 1441 | `dragon_breath` | Item | 64 | crafting remainder `glass_bottle`; rarity uncommon |
| 1087 | 1442 | `splash_potion` | SplashPotionItem | 1 | `potion_contents` empty |
| 1088 | 1443 | `spectral_arrow` | SpectralArrowItem | 64 | none |
| 1089 | 1444 | `tipped_arrow` | TippedArrowItem | 64 | `potion_contents` empty; `potion_duration_scale` 0.125 |
| 1090 | 1445 | `lingering_potion` | LingeringPotionItem | 1 | `potion_contents` empty; `potion_duration_scale` 0.25 |
| 1091 | 1446 | `shield` | ShieldItem | 1 (derived: not registered, set by `durability`) | durability 336; `banner_patterns` empty; repairable tag `wooden_tool_materials`; equippable offhand unswappable; `blocks_attacks`; `break_sound` shield break (17 section 3.6) |
| 1092 | 1447 | `wooden_spear` | Item (spear, material wood) | 1 | 17 section 2.4; cooking fuel `cooking/time_wood_items_large` |
| 1093 | 1448 | `stone_spear` | Item (spear, stone) | 1 | 17 section 2.4 |
| 1094 | 1449 | `copper_spear` | Item (spear, copper) | 1 | 17 section 2.4 |
| 1095 | 1450 | `iron_spear` | Item (spear, iron) | 1 | 17 section 2.4 |
| 1096 | 1451 | `golden_spear` | Item (spear, gold) | 1 | 17 section 2.4 |
| 1097 | 1452 | `diamond_spear` | Item (spear, diamond) | 1 | 17 section 2.4 |
| 1098 | 1453 | `netherite_spear` | Item (spear, netherite) | 1 | 17 section 2.4; fire resistant |
| 1099 | 1454 | `totem_of_undying` | Item | 1 | rarity uncommon; `death_protection` (section 13) |
| 1100 | 1455 | `shulker_shell` | Item | 64 | none |
| 1101 | 1456 | `iron_nugget` | Item | 64 | none |
| 1102 | 1457 | `copper_nugget` | Item | 64 | none |
| 1103 | 1458 | `knowledge_book` | KnowledgeBookItem | 1 | rarity epic; `recipes` empty list |
| 1104 | 1459 | `debug_stick` | DebugStickItem | 1 | rarity epic; `debug_stick_state` empty; glint override true |

Notes on the rows:

- The `rarity` component values are `common` (the default), `uncommon`, `rare`, `epic` (25-1 section 7.2 gives their ids).
- "glint override true" is the component `enchantment_glint_override` = true: the item shows the enchantment glint without enchantments.
- Rows with "compostable `x`" use the provider key `compostable/x`; the composter engine is not in this document (25-1 section 9).
- The banner statement (S 1077) registers its 16 items before `end_crystal`'s own statement; it has no separate field per colour in this range (the `Items.BANNER` field is the collection).
  The 16 items are `<colour>_banner`, colours in the dye order white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black (25-1 section 2.3; `ColorCollection.zipMap` evaluates the colours in that record order). All 16 `<colour>_banner` item model files exist in the jar.
- The item class names are the artifact's; an implementation needs only the behaviours of sections 3 and 6 to 11.

## 5. Foods and consumables of this range

The `Foods` and `Consumables` tables are 25-1 section 8.2 and section 8.3 (and 25-5 section 4 for the consume pipeline). This part re-read the 14 foods that its rows use and the values agree with those tables. `saturation` is
`FoodConstants.saturationByModifier(nutrition, modifier)` = `(float) nutrition * modifier * 2.0` in single precision (`i2f`, multiply by the modifier, multiply by 2); `Foods` builders store the modifier and the record stores the product.

| Food | Nutrition | Modifier | Saturation (float) | Always edible | Consumable | Notes |
|---|---|---|---|---|---|---|
| `carrot` | 3 | 0.6 | 3.6000001 | no | default food | item also a block item (crop) |
| `potato` | 1 | 0.3 | 0.6 | no | default food | block item (crop) |
| `baked_potato` | 5 | 0.6 | 6.0 | no | default food | |
| `poisonous_potato` | 2 | 0.3 | 1.2 | no | `Consumables.POISONOUS_POTATO` | poison 100 ticks amp 0 with probability 0.6 |
| `golden_carrot` | 6 | 1.2 | 14.4 | no | default food | |
| `pumpkin_pie` | 8 | 0.3 | 4.8 | no | default food | |
| `rabbit` | 3 | 0.3 | 1.8 | no | default food | |
| `cooked_rabbit` | 5 | 0.6 | 6.0 | no | default food | |
| `rabbit_stew` | 10 | 0.6 (the `stew(n)` helper) | 12.0 | no | default food | `use_remainder` bowl, stack 1 |
| `mutton` | 2 | 0.3 | 1.2 | no | default food | |
| `cooked_mutton` | 6 | 0.8 | 9.6 | no | default food | |
| `chorus_fruit` | 4 | 0.3 | 2.4 | **yes** | `Consumables.CHORUS_FRUIT` | teleport randomly; `use_cooldown` 1.0 s |
| `beetroot` | 1 | 0.6 | 1.2 | no | default food | |
| `beetroot_soup` | 6 | 0.6 (the `stew(n)` helper) | 7.2 | no | default food | `use_remainder` bowl, stack 1 |

The `stew(n)` helper of `Foods` is `new Builder().nutrition(n).saturationModifier(0.6f)`. Defaults of `Consumables.defaultFood()` (read): consume time 1.6 s, animation `EAT`, sound `entity.generic.eat`, consume particles on; `consumeTicks` = `(int)(1.6 x 20.0)` = 32.
The whole consume pipeline (use start, per-tick sounds, `onConsume`, `FoodData.eat`, burp, `use_remainder`, `canConsume`) is 25-5 section 4 and 17 section 4.9; it is not repeated. One fact this part re-read: the `food` component is itself a `ConsumableListener`: when the consumable finishes,
the listener plays `entity.generic.eat` at the eater (neutral source, volume 1.0, pitch `triangle(1.0, 0.4)`), and for a player calls `FoodData.eat(food)` and plays `entity.player.burp` (players source, volume 0.5, pitch `randomBetween(0.9, 1.0)`).

`ApplyStatusEffectsConsumeEffect.apply`: draws one `nextFloat` from the entity's random source; if the draw is >= probability, no effect and the effect returns false; otherwise adds a **copy** of each listed effect instance to the entity and returns true if any addition succeeded (probability default 1.0, since the constructors without a probability pass `1`).
`TeleportRandomlyConsumeEffect` (chorus fruit, diameter 16.0 and directional particles true by default): up to 16 attempts; each attempt picks a target (x, y, z) = position + (`nextDouble` - 0.5) x diameter on each axis, with y clamped to [level min Y, level min Y + logical height - 1], stops riding if a passenger, and calls `LivingEntity.randomTeleport(x, y, z, true, tag consumable_does_not_teleport_to)`; the first success (read in this order) posts game event `TELEPORT` at the position held before the teleport (the entity's position captured before the attempt, with the entity as context), then plays `item.chorus_fruit.teleport` (`entity.fox.teleport` for a fox,
source neutral; players source otherwise) at the new position, then sends level event 2017 with the clamped block-position difference (clamp 127 per axis) when directional particles are on, then resets fall distance and the impulse context, and ends with success. The `randomTeleport` search (safe-ground descent) is not specified here (Open question 2).

## 6. Books

### 6.1 Items

| Item | Class | Stack | Components | Use |
|---|---|---|---|---|
| `writable_book` (S 1031) | `WritableBookItem` | 1 | `writable_book_content` = empty page list | Use Item: `player.openItemGui(stack, hand)` (the clientbound Open Book packet 0x3B, 05a, carries the hand), stat `item_used`, result `SUCCESS` |
| `written_book` (S 1032) | `WrittenBookItem` | 16 | `enchantment_glint_override` true | same use |

The statement numbers are the ones of section 4.

### 6.2 Components

**`writable_book_content`** (`WritableBookContent`): a list of pages, each a `Filterable<String>`; at most 100 pages (the constructor rejects a larger list; the codecs limit to 100) and each page string is 0 to 1024 characters (`Codec.string(0, 1024)`, `ByteBufCodecs.stringUtf8(1024)`).
Persistent form: an object with the optional field `pages` (default empty list). A `Filterable<T>` is a value with an optional filtered alternative for players with text filtering (the server uses the raw text unless the viewer has filtering on; the wire layout of `Filterable` is not specified here, Open question 5).

**`written_book_content`** (`WrittenBookContent`): fields in order: `title` (`Filterable<String>`, 0 to 32 characters: `TITLE_MAX_LENGTH` = 32; the class also declares a second constant `TITLE_LENGTH` = 16, whose role was not read, Open question 18), `author` (string), `generation` (int 0 to 3, default 0; the constructor rejects another value with "Generation was N, but must be between 0 and 3"),
`pages` (list of `Filterable<Component>`; each page is a text component whose serialized form is limited to 32767 characters (the class constant `PAGE_LENGTH` = 32767): `ComponentSerialization.flatRestrictedCodec(32767)`; no count limit read), `resolved` (boolean, default false). Default instance (`EMPTY`): title "", author "", generation 0, no pages, resolved true.
The tooltip shows the author as the translation `book.byAuthor` ("by %1$s") when the author is not blank and the generation as `book.generation.<n>` ("Original", "Copy of original", "Copy of a copy", "Tattered" for 0 to 3; `en_us.json`). Copy and unlock behaviour of generations (crafting recipes) belongs to the recipe documents.

### 6.3 Editing and signing (`ServerGamePacketListenerImpl.handleEditBook`, packet 0x18, 05c)

Packet fields: Slot (VarInt inventory slot), Pages (up to 100 strings of up to 1024), Title (optional string up to 32; present = sign).

1. The slot must be a hotbar slot (`Inventory.isHotbarSlot`) or 40 (the off hand); otherwise the packet is ignored.
2. Build a list of the texts: the title first when present, then all pages; run the server's text filter over them (asynchronously; the update runs on the server thread when done).
3. Not signing (no title): `updateBookContents`: the stack in that slot must have the component `writable_book_content`; its value is replaced by a `WritableBookContent` made from the (filtered) page strings.
4. Signing: `signBook`: the stack must have `writable_book_content`. The result is a copy of the stack transmuted to `written_book` (`ItemStack.transmuteCopy`: same count and components, new item), with `writable_book_content` removed and `written_book_content` set to
   (title = the filtered title, author = the player's plain-text name, generation 0, pages = each page converted to a text component, resolved **true**). The page conversion maps each `Filterable<String>` to a `Filterable<Component>` through a one-argument function (read: the function bound is the static method `Component.literal(String)`, so each page becomes a plain literal text component carrying the page string). The new stack replaces the slot (`Inventory.setItem`).
   The title and pages are `filterableFromOutgoing` values: with text filtering enabled for the player the filtered text is used and the raw text is dropped; otherwise the raw text passes through.

The stored book is persistent: a written book cannot be edited again (it has no `writable_book_content`).

## 7. Skulls and heads

### 7.1 The seven items

Statements 1044 to 1050 (field order skeleton, wither skeleton, player, zombie, creeper, dragon, piglin; the statement numbers are those of section 4): all are registered with `registerBlock` so they are **block items** (name from the block, `block.minecraft.<key>`), class `StandingAndWallBlockItem`
(`PlayerHeadItem` for the player head). Constructor arguments: standing block, wall block, `attachmentDirection` = `DOWN` (the `PlayerHeadItem` constructor passes `DOWN` itself).

Properties set by the registering statement of `Items.<clinit>` (in this order): `rarity`, `equippableUnswappable(HEAD)`, and for four of them `loweredMobVisibility`. `Waypoint.addHideAttribute` (the attribute component below) is **not** applied by the registering statement: it is applied last, at construction, inside the item-factory lambda (seven calls in the `lambda$static$287` to `$293` family, `$289` being the `PlayerHeadItem` one), which calls it on the Properties when building the `StandingAndWallBlockItem` or `PlayerHeadItem`. The resulting component set does not depend on the order. The same helper is also used for the carved pumpkin item (outside this part, read in its own lambda `$107`):

| Item | Rarity | `mob_visibility` target entity types |
|---|---|---|
| `skeleton_skull` | uncommon | `skeleton` |
| `wither_skeleton_skull` | rare | none |
| `player_head` | uncommon | none |
| `zombie_head` | uncommon | `zombie` |
| `creeper_head` | uncommon | `creeper` |
| `dragon_head` | epic | none |
| `piglin_head` | uncommon | `piglin`, `piglin_brute` |

**Waypoint hide modifier** (`Waypoint.addHideAttribute`): `attribute_modifiers` = one entry: attribute `waypoint_transmit_range`, modifier id `minecraft:waypoint_transmit_range_hide`, amount -1.0, operation `add_multiplied_total`, slot group `head`, display `hidden`
(not shown in the tooltip). Worn on the head the modifier multiplies the wearer's transmit range by (1 + -1) = 0, so the wearer does not appear on other players' locator bars (the attribute's use by the waypoint engine is not read here; the attribute is in 23 section 8).

**Equippable (`equippableUnswappable(HEAD)`)**: `Equippable.builder(HEAD)` with `swappable` false. The builder defaults (read in `Equippable$Builder`): equip sound `item.armor.equip_generic`, no asset id, no camera overlay, no allowed-entity set,
`dispensable` true, `swappable` (false here), `damage_on_hurt` true, `equip_on_interact` false, `can_be_sheared` false, shearing sound `item.shears.snip`. Because `swappable` is false, `Item.use` (use in the air) does **not** swap the head onto the player (the equippable check requires `swappable`);
the head is worn through the inventory slot, by a dispenser (`dispensable`, behaviour not read, Open question 3) or by creative-mode picking. No asset id means no worn model overlay of its own; the player-model hat layer is a client matter (12 section 7).

**`mob_visibility`** (`MobVisibility`, record: `targetingEntityTypes` a holder set of entity types, `visibility` float 0.0 to 10.0; wire: holder set of `entity_type`, then Float): `loweredMobVisibility(types...)` stores the given set and visibility **0.5**.
The set is built after the entity type registry exists (delayed component).

**Use in AI** (`LivingEntity.getVisibilityPercent(level, lookingEntity)`, the number mobs use for detection range). Evaluated in double precision throughout. Start with v = 1.0 (double). If the wearer is discrete (sneaking), v = v x 0.8. If the wearer is invisible: c = max(armor cover fraction, 0.1) (a float), widened to double, and v = v x (0.7 x c).
The slot loop is skipped entirely when `lookingEntity` is null (the sneak and invisibility factors still apply). Otherwise, for each equipment slot, in `EquipmentSlot.VALUES` order: if the stack in that slot has `mob_visibility` and an `equippable` whose slot is **that same slot**, and the looking entity's type is in the set, v = v x `visibility`, the float 0.5 widened to double (exactly 0.5), so the product is exact. Finally v is clamped to [0.0, 10.0].
(The consumers of this number are the targeting conditions of 18; they multiply the follow range.)

### 7.2 Placement (`StandingAndWallBlockItem`)

`getPlacementState(context)`:

1. `wallState` = the wall block's `getStateForPlacement(context)` (may be null).
2. For each direction `d` in `context.getNearestLookingDirections()` (the order of 29 section 9.5): skip `d` if it is the opposite of `attachmentDirection` (UP, for DOWN); `state` = the standing block's `getStateForPlacement(context)` when `d == attachmentDirection` (DOWN), else `wallState`;
   if `state` is not null and `canPlace(level, state, pos)` (= `state.canSurvive(level, pos)`) the search stops with that state.
3. The state found is returned only if `level.isUnobstructed(state, pos, CollisionContext.empty())` is true; otherwise no state (placement fails).

Everything else (the placement pipeline, `BlockPlaceContext`, sounds, `Item.BY_BLOCK`) is `BlockItem` (25-1 section 5.2, 29 section 9.6). The skull block states and block entity are 24.

### 7.3 `player_head`

`PlayerHeadItem.getName(stack)`: if the stack has the component `profile` (`ResolvableProfile`) whose `name` is present, the name is the translation `<descriptionId>.named` = `block.minecraft.player_head.named` ("%s's Head", `en_us.json`) with the profile name as its argument; else the base item name ("Player Head").
The layout of `profile` and the skin resolution are not read here (Open question 6).

## 8. Items that place entities or blocks

### 8.1 Item frames (`ItemFrameItem` extends `HangingEntityItem`)

Rows `item_frame` (S 1035) and `glow_item_frame` (S 1036), stack 64. `useOn(context)`:

1. `pos` = clicked position moved along the clicked face; `direction` = the clicked face.
2. If a player is present and `mayPlace(player, direction, stack, pos)` is false: `FAIL`. For `ItemFrameItem`, `mayPlace` = `level.isInsideBuildHeight(pos)` AND `player.mayUseItemAt(pos, direction, stack)`
   (the base `HangingEntityItem.mayPlace`, used by paintings, instead requires the face axis not vertical AND `mayUseItemAt`).
3. Create `ItemFrame(level, pos, direction)` or `GlowItemFrame(level, pos, direction)` by the item's entity type (a painting uses `Painting.create`, other classes).
4. Apply the default stack config of 3.4 (components, then entity data) to it.
5. If `entity.survives()`: on the server play the placement sound, post game event `ENTITY_PLACE` at the entity position, `level.addFreshEntity(entity)`, `stack.shrink(1)`; return `SUCCESS` on both sides. If it does not survive: `CONSUME`.

### 8.2 `armor_stand` (S 1065), stack 16 (`ArmorStandItem.useOn`)

1. Clicked face `DOWN`: `FAIL`.
2. `placePos` = the clicked position of a `BlockPlaceContext` built from the context (the adjacent cell unless the clicked block is replaceable). `box` = the armor stand's entity dimensions (0.5 x 1.975, 21 section 2) as a bounding box at `Vec3.atBottomCenterOf(placePos)`.
   If `!level.noCollision(null, box)` or any entity (no exclusion) is inside `box`: `FAIL`.
3. Server side: create the entity with `EntityType.create(level, defaultStackConfig, placePos, SPAWN_ITEM_USE, true, true)` (A true, B true, see 3.4); null: `FAIL`.
4. Yaw = `floor((wrapDegrees(player rotation - 180.0) + 22.5) / 45.0) x 45.0` (the `UseOnContext` rotation is the player's yaw); the stand keeps its x, y, z and gets that yaw, pitch 0 (`snapTo`).
5. Add with passengers; play `entity.armor_stand.place` at the stand, `blocks` source, volume 0.75, pitch 0.8; game event `ENTITY_PLACE` with the player as source; `stack.shrink(1)`. Return `SUCCESS` (client: `SUCCESS` without creating).

### 8.3 `end_crystal` (S 1078), stack 64, glint (`EndCrystalItem.useOn`)

1. The clicked block must be `obsidian` or `bedrock`, else `FAIL`. Let `above` = the cell above it; it must be an empty block (`isEmptyBlock`: air), else `FAIL`.
2. Entities (any) in the box [x, x + 1] x [above.y, above.y + 2] x [z, z + 1] (above's coordinates) must be none, else `FAIL`.
3. Server side: `new EndCrystal(level, x + 0.5, above.y, z + 0.5)` with `showBottom` false, `addFreshEntity`, game event `ENTITY_PLACE` (player source) at `above`; if the level has a dragon fight (`getDragonFight`), call `tryRespawn()` (the respawn algorithm is the fight's: 21 section 6.3).
4. `stack.shrink(1)`; `SUCCESS` (client: `SUCCESS` after the checks).

### 8.4 `command_block_minecart` (S 1074), stack 1, rarity epic (`MinecartItem.useOn`)

1. The clicked block state must be in the block tag `rails`, else `FAIL`. `shape` = the rail shape of the block when it is a `BaseRailBlock` (its shape property), else `NORTH_SOUTH`; `yOff` = 0.5 if the shape is a slope, else 0.
2. Position = (x + 0.5, y + 0.0625 + yOff, z + 0.5) of the clicked cell. Create the minecart with `AbstractMinecart.createMinecart(level, x, y, z, type, DISPENSER, stack, player)` (the spawn reason read is `DISPENSER`, even for player use); null: `FAIL`.
3. If the level uses experimental minecart movement (`useExperimentalMovement`): any other `AbstractMinecart` intersecting the new minecart's box makes the result `FAIL`.
4. Server side: `addFreshEntity`, game event `ENTITY_PLACE` at the clicked position with the player and the state of the block below as context; `stack.shrink(1)`; `SUCCESS`.

### 8.5 Banners (`BannerItem`, 16 items, stack 16)

The properties below come from the per-colour factory lambda that `ColorCollection.registerBlockItems` calls with the dye colour, not from `BannerItem`: its own constructor only validates the blocks and passes `DOWN`. `BannerItem(block, wallBlock, properties)` extends `StandingAndWallBlockItem` with `attachmentDirection` `DOWN`, and checks that both blocks are `AbstractBannerBlock` (`getColor()` = the block's dye colour). Properties: `cooking_fuel` with provider `cooking/time_wood_blocks` (300 left, 25-1 section 9), `stacksTo(16)`, `banner_patterns` = `BannerPatternLayers.EMPTY`.
Registered with `registerBlock`, so the name is `block.minecraft.<colour>_banner`. The wall block of colour c is `Blocks.WALL_BANNER.pick(c)`. Placement is 7.2. The pattern layers are applied by crafting and the loom (recipes, GAP of the workstation round); the layer list component is `banner_patterns` (17 section 1.2, wire 17).

## 9. Animal armor (horse armor)

Six rows (S 1066 to 1071, ids 1406 to 1411): `copper_horse_armor`, `iron_horse_armor`, `golden_horse_armor`, `diamond_horse_armor`, `netherite_horse_armor`, `leather_horse_armor`, registered with `new Properties().horseArmor(material)` where material is
`ArmorMaterials.COPPER`, `IRON`, `GOLD`, `DIAMOND`, `NETHERITE`, `LEATHER`; `netherite_horse_armor` also `fireResistant()`. (Read against `Item$Properties`: `wolfArmor` sets durability from `ArmorType.getDurability(BODY)` applied to the material's durability, the attributes, `repairable` from the material's repair-ingredient tag, an equippable (slot body, the material's equip sound and asset, allowed entities = {wolf}, `can_be_sheared` true, shearing sound `ARMOR_UNEQUIP_WOLF`, `damage_on_hurt` left at its default true), the component `break_sound` = `SoundEvents.WOLF_ARMOR_BREAK`, and `stacksTo(1)`; it makes no `enchantable` call. `horseArmor` and `nautilusArmor` set no durability and no repairable. `nautilusArmor` differs from `horseArmor` in three read points: equip sound `ARMOR_EQUIP_NAUTILUS`, allowed entities = the entity tag `can_wear_nautilus_armor`, shearing sound `ARMOR_UNEQUIP_NAUTILUS`; it also sets `equip_on_interact` true, which `horseArmor` leaves false. Both set `damage_on_hurt` false and `can_be_sheared` true; `horseArmor` uses equip sound `HORSE_ARMOR`, allowed entities = tag `can_wear_horse_armor`, shearing sound `HORSE_ARMOR_UNEQUIP`.)

`Properties.horseArmor(material)` sets, in order:

1. `attribute_modifiers` = `material.createAttributes(BODY)`: slot group `body`; three modifiers that share the identifier `minecraft:armor.body` (the format `armor.<type name>`), each `add_value`: `armor` = the material's defense for the BODY type (default 0 when absent), `armor_toughness` = the material's toughness (added **even when 0**),
   and `armor_knockback_resistance`-class attribute `knockback_resistance` = the material's value, added **only when greater than 0**. Values per material (17 section 2.5, body column): leather 3, copper 4, iron 5, gold 7, diamond 11, netherite 19; toughness 0 except diamond 2 and netherite 3; knockback resistance 0 except netherite 0.1.
2. `equippable` = `Equippable.builder(BODY)` with: equip sound `entity.horse.armor` (`SoundEvents.HORSE_ARMOR`); asset id = `material.assetId` (an equipment asset key, data); allowed entities = the entity type tag `can_wear_horse_armor` (data);
   `damage_on_hurt` **false**; `can_be_sheared` true; shearing sound `item.horse_armor.unequip`. Other builder defaults stay (dispensable true, swappable true, `equip_on_interact` false).
3. `stacksTo(1)`.

Not set (read: the method does not call them): `durability` and `repairable`. A horse armor item therefore has **no** `max_damage`, no `damage` and no `repairable`, and no `break_sound`. (Document 17 section 1.4's table row "`wolfArmor`, `horseArmor`, `nautilusArmor` ... like humanoid with the body slot (durability multiplier x 16)" is correct for the wolf armor and not for horse and nautilus armor: see Open question 12.)

Because `swappable` is true, Use Item swaps the armor into the body slot when no other use applies (`Item.use`: consumable, then swappable equippable, then blocks-attacks, then kinetic weapon, else `PASS`; 25-1 section 5.1). Putting horse armor on a horse is an interaction of the horse (`equippable.allowedEntities` is the gate; 19, 44).
The nautilus armor items (`Properties.nautilusArmor`, 25-1 section 6.4) are rows of part 7; their builder differs from `horseArmor` as stated in the note at the head of this section (equip sound, allowed-entity tag, shearing sound, `equip_on_interact` true).

## 10. Thrown items and arrows

### 10.1 `experience_bottle` (S 1028, stack 64, rarity uncommon, glint; `ExperienceBottleItem`, a `ProjectileItem`)

`use(level, player, hand)`:
1. Play `entity.experience_bottle.throw` at the player (source neutral), volume 0.5, pitch `0.4 / (nextFloat x 0.4 + 0.8)` (one `nextFloat` from the level's random).
2. On a server level: `Projectile.spawnProjectileFromRotation(ThrownExperienceBottle::new, level, stack, player, -20.0, 0.7, 1.0)` (arguments after the player, by position: -20.0 offset, 0.7 power, 1.0 uncertainty. Read: `spawnProjectileFromRotation` hands its three floats, in order, to `shootFromRotation(entity, xRot, yRot, offset, power, uncertainty)`, where in `shootFromRotation` the first float is added to the pitch term of the Y component and the last two are the arguments `shoot` takes as speed and inaccuracy). `shootFromRotation`: 44-8.
3. Stat `item_used`; `stack.consume(1, player)`; `SUCCESS`.

Dispenser configuration (`createDispenseConfig`): uncertainty = default x 0.5, power = default x 1.25 (the default config values are in 44-8 or the dispenser round: not read here).

### 10.2 Potions (`splash_potion` S 1087, `lingering_potion` S 1090, both stack 1; `ThrowablePotionItem` extends `PotionItem`)

`SplashPotionItem.use`: play `entity.splash_potion.throw` (source players, volume 0.5, pitch `0.4 / (nextFloat x 0.4 + 0.8)`), then `ThrowablePotionItem.use`. `LingeringPotionItem.use` the same with `entity.lingering_potion.throw` (source neutral).
`ThrowablePotionItem.use`: on a server level `Projectile.spawnProjectileFromRotation(factory, level, stack, player, -20.0, 0.5, 1.0)` (`PROJECTILE_SHOOT_POWER` = 0.5), stat `item_used`, `stack.consume(1, player)`, `SUCCESS`. The entity is `ThrownSplashPotion` or the lingering variant (`createPotion`).
Dispenser config: uncertainty x 0.5, power x 1.25 as for the bottle. Components: `potion_contents` = empty (`PotionContents.EMPTY`), lingering also `potion_duration_scale` 0.25 (17 section 1.2). The potion effects, the cloud and the arithmetic are in 17 section 3.15 and 25-5 section 8.

### 10.3 Arrows

| Item | Class | Components | Notes |
|---|---|---|---|
| `spectral_arrow` (S 1088) | `SpectralArrowItem` extends `ArrowItem` | none | `createArrow` builds a `SpectralArrow` with a one-count copy of the stack; dispensed arrows get pickup `ALLOWED` |
| `tipped_arrow` (S 1089) | `TippedArrowItem` | `potion_contents` empty, `potion_duration_scale` 0.125 | `getDefaultInstance` = the stack with `potion_contents` of the potion `poison`; `getName` = `PotionContents.getName("<descriptionId>.effect.")`: e.g. `item.minecraft.tipped_arrow.effect.poison` ("Arrow of Poison") |

Arrow flight, damage and pickup: 17 section 3.9 and 44-8. The `arrows` tag membership of the three arrow items is data (17 section 3.9).

## 11. Other special items

- **empty map** (`map`, S 1042, class `EmptyMapItem`, stack 64): `use(level, player, hand)`: server side: consume one item from the stack in hand, stat `item_used`, play `ui.cartography_table.take_result` at the player's sound source (volume 1, pitch 1), then
  `MapItem.create(level, player block X, player block Z, scale 0, trackingPosition true, unlimitedTracking false)`. If the result stack is empty: `SUCCESS` with the (shrunk) hand stack. Otherwise if the shrunk hand stack is empty the filled map replaces it in the hand (`heldItemTransformedTo`); else the filled map is added to the inventory, dropped at the player with prediction `SERVER_ONLY` if the inventory is full; `SUCCESS`. Map creation and map data: 25-5 section 8.
- **`knowledge_book`** (S 1103, stack 1, rarity epic, `KnowledgeBookItem`): the component `recipes` is a list of recipe resource keys (empty by default). `use`: take the list (default empty), consume one item; empty list: `FAIL`; on a server level: look each key up in the recipe manager (an unknown key logs `Invalid recipe: <key>` and returns `FAIL`), award all found recipes with `Player.awardRecipes` (recipe book unlock, 27), stat `item_used`; `SUCCESS`.
- **`debug_stick`** (S 1104 = id 1459, stack 1, rarity epic, glint, `DebugStickItem`): needs the game-master-blocks permission (`canUseGameMasterBlocks`, else the click does nothing: `useOn` fails, left click returns false). The component `debug_stick_state` is a map from block (by registered name) to the selected property name (empty by default).
  Behaviour (`handleInteraction(player, state, level, pos, cycling, stack)`): if the block has no properties: send the actionbar (overlay) message `<descriptionId>.empty` ("%s has no properties", argument the registered block name) and do nothing. Otherwise the selected property for the block is looked up in the state map (`DebugStickState.properties`); if none was stored or it is not a property of the block, the first property of the block's state definition is used.
  Right click on a block (`useOn`, `cycling` true): replace the block state by the next value of the selected property in the property's value order, or the previous value when the player is sneaking (`isSecondaryUseActive`), wrapping around (`Util.findNextInIterable` or `findPreviousInIterable`); set with `setBlock(pos, newState, 18)` (flags 2 clients + 16 skip shape updates, 29 section 1) and message `<descriptionId>.update` ("\"%s\" to %s", property name and the new value name). Left click on a block (`canDestroyBlock`, which then returns false so the block is never broken, `cycling` false): select the next property of the block's property list (previous with sneak), store it with `withProperty`, message `<descriptionId>.select` ("selected \"%s\" (%s)", property name and its current value name). The value names are `Property.getName(value)`. Both successful paths return `SUCCESS`/`false`; the right click returns `FAIL` if `handleInteraction` returned false.
- **`totem_of_undying`** (S 1099, stack 1, rarity uncommon): component `death_protection` = `DeathProtection.TOTEM_OF_UNDYING` = the on-death consume effects, in order: clear all status effects, then apply together `regeneration` 900 ticks amplifier 1, `absorption` 100 ticks amplifier 1, `fire_resistance` 800 ticks amplifier 0 (probability 1). The death check, the health set and the trigger: 17 section 4.10.
- **`nether_star`** (S 1051): `damage_resistant` for the tag `is_explosion` (the item entity survives explosions), not fire; rarity rare; glint.
- **`resin_brick`** (S 1057): `provides_trim_material` = the `trim_material` registry entry `resin` (delayed: resolved when the data registries exist; `trim_material` data is 23). `nether_brick`, `prismarine_shard`, `prismarine_crystals`, `breeze_rod`, `rabbit_foot`, `rabbit_hide`, `popped_chorus_fruit`, `shulker_shell`, `iron_nugget`, `copper_nugget`, `firework_star`: plain items.
- **`dragon_breath`** (S 1086): `craftRemainder(glass_bottle)` (the crafting remainder), rarity uncommon: not a component; it is stored on the item (`Item.getCraftingRemainder`).
- **`wind_charge`**, **`fire_charge`**, **`flower_pot`**, **`lead`**, **`name_tag`**: 17 section 3.15, section 3.3, 24, section 3.7.
- **Seeds and crops as items** (`torchflower_seeds`, `pitcher_pod`, `beetroot_seeds`, `carrot`, `potato`): `BlockItem` with the item description prefix, so right-clicking a block plants the crop block through the normal placement (29 section 9.6). The crop blocks are `torchflower_crop`, `pitcher_crop`, `beetroots`, `carrots`, `potatoes`.
- **`firework_star`** (S 1054) is a plain `Item` with no components (its `firework_explosion` component is applied by crafting, 27); **`enchanted_book`** (S 1055) is a plain `Item` with stack 1, rarity rare, glint and `stored_enchantments` = empty (the enchantments are stored in `stored_enchantments`, 17 section 1.2).

## 12. Items taken from 17

Fully specified there and only located here: `mace` (17 section 2.6, section 4.8), `shield` (17 section 2.6, section 3.6; this part adds that its `equippable` slot is `offhand` with `swappable` false and that `BASE_COLOR` renames it `item.minecraft.shield.<colour>` through `ShieldItem.getName`, e.g. "White Shield"),
the seven spears `wooden_spear` to `netherite_spear` (17 section 2.4; their cooking fuel for wood is the provider `cooking/time_wood_items_large`), `firework_rocket` (17 section 3.13), `wind_charge` and `fire_charge` (17 section 3.15, section 3.3), `lead` and `name_tag` (17 section 3.7), `tipped_arrow` and `spectral_arrow` potion scale (17 section 2.6).

## 13. Worked examples

**Example 1: ids.** `chicken_spawn_egg`: S 940; collections before it: 18 colour (13 block collections, `harness`, `dyed_bundle`, `cushion`, `dye`, `bed`) and 10 weathering; I = 940 + 18 x 15 + 10 x 7 = 940 + 340 = **1280**.
`shulker_spawn_egg`: S 1027, I = 1367. `cooked_mutton`: S 1076, I = 1416. The banner collection (S 1077) takes ids 1417 to 1432 (`white_banner` 1417, `black_banner` 1432). `end_crystal`: S 1078, I = 1078 + 355 = **1433**. `debug_stick`: S 1104, I = 1459. The next row (part 7), `music_disc_13`, S 1105, I = 1460.

**Example 2: a spawn egg on the top of a full block.** The player right-clicks the top face of a stone block at (10, 64, 10) with a `chicken_spawn_egg` in survival, difficulty normal. The block's collision shape is not empty, so `spawnPos` = (10, 65, 10); `lowerToSurface` B = (spawnPos != clickedPos AND face == UP) = true; A = true.
`create`: the chicken is first moved to (10.5, 66, 10.5); `getYOffset`: the query box is the cell (10, 65, 10) extended one block down, i.e. y from 64 to 66; the collision shape inside it is the stone's [64, 65]; the entity box (bottom at 66) can move down at most to 65, so the allowed movement is -1.0 and
`dy` = 1.0 + (-1.0) = 0.0 (assumed: the clip of a downward movement of -1.0 by the full block top, Open question 8). The chicken is placed at (10.5, 65.0, 10.5) with a random yaw (one `nextFloat` x 360 wrapped to [-180, 180)) and pitch 0, `finalizeSpawn` runs, `addFreshEntityWithPassengers` adds it, the egg stack loses one, game event `ENTITY_PLACE` is posted, the result is `SUCCESS`.
The same click on the top of a bottom slab (top at 64.5): the allowed movement is -1.5, `dy` = -0.5, the chicken is placed at y = 64.5.

**Example 3: a spawn egg on a spawner.** A player who is on the op list uses a `zombie_spawn_egg` on a spawner block; `entity_data` is present (type `zombie`, empty tag) so `setEntityData(data, random)` is called (not `setEntityId`); a non-op player makes the `setEntityId(zombie, random)` call. Both send block update 3, post `BLOCK_CHANGE` and shrink the stack by one.
With the server option for spawner blocks off, the player gets "Spawner blocks are not enabled" and the result is `FAIL`.

**Example 4: peaceful.** `canSpawn` for `zombie` in peaceful difficulty: the zombie type is not allowed in peaceful (`isAllowedInPeaceful` false, inferred for hostile types, Open question 11): `FAIL`, nothing spawns and nothing is consumed. A `chicken_spawn_egg` still works (allowed in peaceful, inferred).

**Example 5: food.** `baked_potato`: nutrition 5, saturation 5 x 0.6 x 2.0 = 6.0; 32 use ticks; stack 64; compostable `medium_high`. `rabbit_stew`: nutrition 10, saturation 12.0, stack 1, leaves a `bowl`. `golden_carrot`: nutrition 6, saturation 14.4 (6 x 1.2 x 2.0 = 14.4000006 in single precision).
`poisonous_potato`: nutrition 2, saturation 1.2; with probability 0.6 (one `nextFloat` below 0.6) the eater gets `poison` for 100 ticks at amplifier 0. `chorus_fruit`: always edible; after eating it up to 16 random teleports within a cube of side 16 are tried and the item has a 20-tick cooldown.

**Example 6: signing a book.** A player holds a `writable_book` in hotbar slot 2 with pages ["Hello", "World"], and signs it with the title "Log". The client sends Edit Book (slot 2, pages ["Hello", "World"], title "Log"). The server (text filtering off) replaces slot 2 with a `written_book` carrying
`written_book_content` (title "Log", author = the player's name, generation 0, two pages, resolved true) and no `writable_book_content`. Slot 12 is ignored (neither hotbar nor 40). A signed book has stack size 16, and a stack of `writable_book` has stack size 1.

**Example 7: head visibility.** A player wearing `zombie_head` is seen by a zombie: v = 1.0 x 0.5 = 0.5 (with a null looking entity the head would not be consulted: v = 1.0). The same player sneaking: 1.0 x 0.8 x 0.5 = 0.4. Seen by a skeleton: only the sneak factor applies (0.8), since the `zombie` set does not contain `skeleton`. An invisible wearer with no armor
(cover 0 raised to 0.1) seen by a zombie: 1.0 x (0.7 x 0.1f widened) x 0.5 = about 0.035. The float 0.1f widened to double is 0.10000000149011612, so the result is 0.035000000521541... in double, not exactly 0.035.

**Example 8: armor stand rotation.** A player with yaw 0: rotation - 180 = -180, wrapped to -180; + 22.5 = -157.5; / 45 = -3.5; floor = -4; x 45 = -180: the stand is rotated -180 degrees. Yaw 90: (90 - 180) = -90; +22.5 = -67.5; /45 = -1.5; floor -2; -90 degrees.

**Example 9: the horse armor attribute entries.** `iron_horse_armor`: attribute modifiers in slot group `body`: (`armor`, id `minecraft:armor.body`, +5.0, add_value), (`armor_toughness`, same id, +0.0, add_value); no knockback entry (0 is not added). Stack size 1, no `max_damage`.
`netherite_horse_armor`: `armor` +19, `armor_toughness` +3, `knockback_resistance` +0.1 (the float 0.1 widened to a double), and `damage_resistant` for `is_fire`.

## 14. Validation

1. **Item model count equals the registry size.** `unzip -Z1 minecraft-26.3-client.jar | grep -v '/$' | grep '^assets/minecraft/items/' | wc -l` = **1658**, equal to the 1658 items computed from the field types (1218 plain fields + 20 colour collections x 16 + 15 weathering collections x 8). `air.json` is one of them.
2. **The key of every row has an item model file.** All 88 spawn egg keys, the 76 single-item rows and the 16 `<colour>_banner` keys have a file `assets/minecraft/items/<key>.json` (checked by script against the lower-case field names; no key missing).
3. **Eggs.** 88 statements call `registerSpawnEgg` (also 25-1 section 2.4: 88), 88 item models match `*spawn_egg*`, and in each of the 88 statements the entity named by the `EntityTypes` argument equals the egg's key without `_spawn_egg`.
4. **Ranges.** 165 statements (S 940 to 1104) = 88 + 76 + 1; items 88 + 76 + 16 = 180; ids 1280 to 1459 = 180 values. The two anchors that 25-1 section 2.3 also derives (the banner range 1417 to 1432, and S 1077 for `BANNER`) agree with this document's formula.
5. **Statement numbers against the brief.** The brief's `mace` 1034, `piglin_head` 1050, `tipped_arrow` 1089 and `shield` 1091 equal S = F + 28 (F + 29 after the banner statement): `mace` F 1006, `piglin_head` F 1022, `tipped_arrow` F 1060, `shield` F 1062.
6. **Language keys exist.** `en_us.json` contains `advMode.notEnabled.spawner`, `book.byAuthor`, `book.generation.0` to `3`, `block.minecraft.player_head.named`, `item.minecraft.tipped_arrow.effect.poison`, `item.minecraft.debug_stick.empty`, `.update`, `.select`, `painting.random`, `painting.dimensions`, `item.minecraft.shield.white` (read). `item.minecraft.carrot` exists and `block.minecraft.carrot` does not (the block is `carrots`).
7. **Food arithmetic.** The saturation column of section 5 was computed with single-precision multiplication in the order of `saturationByModifier`; the nutrition and modifier values agree with 25-1 section 8.2 (which was written by a separate reading).
8. **Durable rows have stack 1.** `Item$Properties.durability(n)` was read: it sets `MAX_DAMAGE` to n, `MAX_STACK_SIZE` to 1 and `DAMAGE` to 0, so `mace` and `shield` get stack 1 from `durability`, not from a `stacksTo` call (the `Items` registration of the shield calls only `durability(336)`). Rows: `mace` 1, `shield` 1, and the seven spears (17); horse armor has stack 1 through `stacksTo(1)` and no durability.
9. **Self-checks for an implementation.** (a) Registering the 88 spawn eggs in table order must reproduce ids 1280 to 1367. (b) `Item.getId(banner colour c)` = 1417 + position of c in the dye order. (c) A spawn egg stack with no `entity_data` fails with `FAIL` in `useOn` and `use`. (d) A stack of 65 spawn eggs cannot exist (stack size 64).

## 15. Open questions

1. **Registry ids not compared with a dump.** The ids of this part (I = S + 340 for S 940 to 1076, S + 355 for S 1078 to 1104) were computed from the field types read in `Items` (one item per plain field, 16 per colour collection, 8 per weathering collection). No packet capture or registry dump was available. The jar's 1658 item model files and the independent derivation in 25-1 section 2.4 agree on the total.
2. **`LivingEntity.randomTeleport(x, y, z, broadcast, tag)`** (chorus fruit, safe-ground descent, the `consumable_does_not_teleport_to` block tag, ender pearl sharing): not read here. The consume effect (16 attempts, diameter, clamp) is specified in section 5.
3. **Dispenser behaviours.** `SpawnEggItemBehavior.execute` (including its null branch) and the fallback selection in `DispenserBlock` (3.8) were read. The explicit map filled by `DispenseItemBehavior.bootStrap` (which items are bound to which behaviour), the behaviour of armor stand, skulls and banners (equipment dispensing), minecarts, end crystals, potions and the experience bottle (`ProjectileDispenseBehavior` with the `createDispenseConfig` values: this part reads only the multipliers 0.5 and 1.25 of the experience bottle and potions) are not specified.
4. **Thrown entities' behaviour.** The roles of the three floats of `Projectile.spawnProjectileFromRotation` are read (10.1) and no longer open. The thrown entities' own behaviour (experience amounts, splash application) is 21 section 8 and 17 section 3.15.
5. **`Filterable` wire layout and the page conversion in `signBook`.** The filtered/raw pair of `Filterable` was not expanded. The page conversion is no longer open: the mapping function is `Component.literal(String)` (read, 6.3 step 4). Server text filtering (the `filterTextPacket` service) is out of scope; with filtering off the raw text is used.
6. **`ResolvableProfile`** (the `profile` component of `player_head`) layout, the skin resolution and the name fallback.
7. **Network synchronisation of the components first seen here.** Wire layouts read: `entity_data` (entity type id, compound tag), `mob_visibility` (holder set of entity types, float), `villager_food` (VarInt), `compostable` (a `ResolvableInt` stream codec), `cooking_fuel` and `brewing_fuel` (a `ResolvableInt` and a `ResolvableFloat`). Whether each of these components is network-synchronised at all (the `DataComponents` registration flags) and the wire layouts of `writable_book_content` (list of `Filterable<String>`, at most 100) and `written_book_content` are given in 46 section 8 or not read here.
8. **`Shapes.collide` / `VoxelShape.collideX` clipping.** Read: `Shapes.collide` threads the movement through every shape and returns the result, with a 1.0E-7 early exit. Not read: the exact clipping inside `VoxelShape.collideX` (index search with 1.0E-7 tolerance, cutoff per voxel layer). That a movement of -1.0 above a full block is cut to 0.0 relative to the box bottom, as example 2 of section 13 uses, is therefore still an assumption.
9. **`ItemStack.shrink` versus `consume`.** The spawner path of the spawn egg calls `shrink(1)` unconditionally; the mob path calls `consume(1, owner)`. Resolved by reading: `consume(int, LivingEntity)` skips the shrink only for a non-null owner with `hasInfiniteMaterials()` true, so the mob path keeps the egg for a creative player and shrinks for a null owner (dispenser), while the spawner path always shrinks. The Use Item path that calls the item is in 29 section 9.
10. **`Entity.applyImplicitComponents` overrides.** The base class applies `custom_name` and `custom_data`; the overrides of the mob classes (variants, colours, sizes, for example a sheep colour or a cat variant carried by components of the spawn egg stack) were not read; 45 holds the entity fields.
11. **`EntityType.isAllowedInPeaceful` per type.** The flag exists (read in `canSpawn`); its value for each of the 88 types is set in the type builders (21 section 2 may list it: not re-read here).
12. **Correction to 17 section 1.4.** The builder table of 17 says that `wolfArmor`, `horseArmor` and `nautilusArmor` are "like humanoid with the body slot (durability multiplier x 16)". In `Item$Properties` only `wolfArmor` sets a durability and a repairable tag (and, in addition to the equippable, the component `break_sound` = `wolf_armor_break`, read, with `stacksTo(1)` and no `enchantable`); `horseArmor` and `nautilusArmor` set attributes, the equippable and `stacksTo(1)` and **nothing else** (section 9). The statement in 17 should be amended by its owner; this document does not edit 17.
13. **Feature-flagged egg types.** `Properties.spawnEgg` copies the entity type's required feature set into the item. Which of the 88 types are outside the vanilla feature set (and therefore tied to a disabled feature data pack, 22) was not read.
14. **The waypoint (locator bar) engine.** Section 7 specifies the hide modifier on the `waypoint_transmit_range` attribute; the engine that reads that attribute (range, which players are tracked) is not in this document.
15. **Consumers of `getVisibilityPercent`.** The calculation is read; its use as a multiplier of the follow range in the targeting conditions is inferred (18 holds the targeting conditions).
16. **Spawn egg on an ageable mob.** `spawnOffspringFromSpawnEgg` is specified here; its caller (the mob interaction that handles a spawn egg of the same type) was not read.
17. **Map creation.** `MapItem.create(level, x, z, scale, tracking, unlimited)` is called with (player block X, player block Z, 0, true, false); the algorithm is 25-5 section 8.
18. **`WrittenBookContent.TITLE_LENGTH` = 16.** The constant exists beside `TITLE_MAX_LENGTH` = 32; searched: the class's static fields and the edit-book handler. Where (if anywhere) 16 is applied, for instance in a client edit screen, was not read.
