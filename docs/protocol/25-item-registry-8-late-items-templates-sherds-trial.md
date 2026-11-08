# Item registry, part 8: composter to ominous bottle (`Items` fields 1150 to 1252, registry ids 1505 to 1657), smithing templates, pottery sherds, trial items, and the whole-registry check

| Item | Value |
|---|---|
| Covers | Rows for the last 103 fields of the `Items` static initialiser, `COMPOSTER` (field 1150) through `OMINOUS_BOTTLE` (field 1252): the late block items (workstations, lanterns, campfires, bee blocks, the blackstone family, candles, amethyst, froglights, copper variants), the consumables `HONEY_BOTTLE` and `OMINOUS_BOTTLE`, `ECHO_SHARD`, `BRUSH`, the 19 smithing templates, the 23 pottery sherds, the trial items. Also the engines that interpret what these items carry: the consume pipeline (food, consumable, use remainder, consume listeners), `HoneycombItem`, `BrushItem` and the brushable block entity, `PlaceOnWaterBlockItem`, `SmithingTemplateItem`, the `compostable` and `cooking_fuel` components, the common prototype components. It closes with the whole-registry check (classes, ids 0 to 1657, gaps, duplicates). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for the bootstrap method arguments of lambdas) and of data files inside the jar (`data/minecraft/context_int_provider`, `context_float_provider`, `predicate/block`, `decorated_pot_pattern`, and the file names under `assets/minecraft/items/`, used only to cross-check keys and counts). No execution. |
| Status | Round RS5, part 8 of 8 (design map Part 5, GAP-2). Siblings: part 7 covers fields 1105 to 1149. |
| Not tabulated | Data rows (recipes, loot tables, tags, item models, language texts, the `cooking/*` and `compostable/*` provider JSON beyond the few values quoted as examples) are produced by the extraction tool (22). This document gives the schema and the engines. |

Class, method and field names in backticks say where a fact was read. They are not the design. "04 §5" means section 5 of `04-registry-sync.md`; "17 §1.2" means section 1.2 of `17-tools-weapons-and-combat.md`; "29 §9.6" means section 9.6 of `29-block-updates-and-placement.md`; "46 §4" means section 4 of `46-registry-ids.md`; "24-8" is the block registry part 8. "Field" means the declaration (initialiser) order of `Items`; "registry id" is the number on the wire.

## Contents

1. [Scope, and the field number versus the registry id](#1-scope-and-the-field-number-versus-the-registry-id)
2. [How an item in this range is built](#2-how-an-item-in-this-range-is-built)
3. [The 103 rows](#3-the-103-rows)
4. [Block items of the range](#4-block-items-of-the-range)
5. [The consume pipeline, honey bottle, ominous bottle](#5-the-consume-pipeline-honey-bottle-ominous-bottle)
6. [Honeycomb](#6-honeycomb)
7. [Brush](#7-brush)
8. [Smithing templates](#8-smithing-templates)
9. [Pottery sherds](#9-pottery-sherds)
10. [Trial items, echo shard](#10-trial-items-echo-shard)
11. [Whole-registry check](#11-whole-registry-check)
12. [Worked examples](#12-worked-examples)
13. [Validation](#13-validation)
14. [Open questions](#14-open-questions)

## 1. Scope, and the field number versus the registry id

1. This range is fields 1150 to 1252. Those numbers are **field numbers** of `Items` (the 0-based order of the `putstatic` instructions in `Items.<clinit>`, 1253 in all). They are not registry ids. The artifact has 35 fields that register a whole collection in one go: 20 `ColorCollection` fields (16 items each, in the order of 1.2) and 15 `WeatheringCopperCollection` fields (8 items each, in the order of 1.3). Each of those fields registers several items, so the registry has 1253 + 20 x 15 + 15 x 7 = 1658 items, ids 0 to 1657.
2. **Id rule.** The item registry assigns ids in registration order (04 §5, 46 §2). Walk the 1253 fields in order and give a single-item field the next id, a `ColorCollection` field the next 16 ids, a `WeatheringCopperCollection` field the next 8 ids. This was done for every field (section 11) and gave a contiguous 0 to 1657. Field 1150 `COMPOSTER` is registry id **1505**; field 1252 `OMINOUS_BOTTLE` is registry id **1657**, the last item. The range of this document is therefore ids 1505 to 1657: 153 items in 103 fields (97 single-item fields, 5 weathering collections of 8, 1 colour collection of 16: 97 + 40 + 16 = 153).
3. **Collection order.**
   1. Colour collection: `white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black` (the record component order of `ColorCollection`, and the order of `DyeColor`). The item key is `<color>_<base>`.
   2. Weathering collection: the four weather states `unaffected, exposed, weathered, oxidized` first, then the same four waxed. Key prefixes are `""`, `exposed_`, `weathered_`, `oxidized_`, then `waxed_`, `waxed_exposed_`, `waxed_weathered_`, `waxed_oxidized_` (`WeatheringCopperCollection.PREFIXES`; the order of registration is the order of `zipMap`: weathering group then waxed group, each unaffected, exposed, weathered, oxidized).
4. **Keys.** The item key is `minecraft:<name>`; every key in this range was checked against the file names under `assets/minecraft/items/`. Where the item is a block item the key is the second string of the `BlockItemId` (for `SWEET_BERRIES` the block is `sweet_berry_bush`, the item key `sweet_berries`; for `GLOW_BERRIES` the block is `cave_vines`, the item key `glow_berries`).

## 2. How an item in this range is built

### 2.1 The registration helpers (`Items`)

| Helper | What it does |
|---|---|
| `registerItem(key, properties)` | Creates a plain `Item` from the properties (the constructor `Item(Item$Properties)`), registers it under `key`. |
| `registerItem(key, factory, properties)` | The same with another class built by `factory(properties)`. |
| `registerBlock(blockItemId, block[, ...])` | Key = `blockItemId.item()`. Builds `factory(block, properties.useBlockDescriptionPrefix().requiredFeatures(block.requiredFeatures()))`; the default factory is `new BlockItem(block, properties)`. A `UnaryOperator<Item$Properties>` variant lets the call add components first. A varargs variant additionally maps extra blocks to the same item in `Item.BY_BLOCK` (none in this range). |
| `registerItem(blockItemId, factory, properties)` | Same as `registerItem(key, ...)` with `blockItemId.item()` as the key; used by the berries (`createBlockItemWithCustomItemName`, a `BlockItem` whose properties call `useItemDescriptionPrefix()`). |
| Registering | Every item whose class is a `BlockItem` is entered into `Item.BY_BLOCK` (block to item) with `BlockItem.registerBlocks`, then `Registry.register(BuiltInRegistries.ITEM, key, item)` assigns the next id. |

### 2.2 `Item$Properties` (what the registrations in this range use)

| Method | Effect |
|---|---|
| `new Item$Properties()` | Component initialiser starts as: the common component map of 2.3. Required features start as the vanilla set. Description id source is the item prefix. The model is the item key's identifier. |
| `component(type, value)` | Adds (or overrides, in call order) one component of the prototype. |
| `delayedComponent(type, initialiser)` | A component built after the data registries exist (`potPattern`). |
| `rarity(r)` | `rarity` component. |
| `stacksTo(n)` | `max_stack_size` = n. |
| `durability(n)` | `max_damage` = n, `max_stack_size` = 1, `damage` = 0 (17 §1.3). |
| `food(food, consumable)` | `food` = food, `consumable` = consumable. `food(food)` uses the default food consumable (3.1). |
| `usingConvertsTo(item)` | `use_remainder` = a template of one `item` (stack of 1, no patch; the one-argument `ItemStackTemplate(Item)` constructor passes count 1 and the empty patch, read). |
| `craftRemainder(item)` | Not a component: the field `craftingRemainingItem` of the item (read by `Item.getCraftingRemainder`), used by crafting and fuel handling. |
| `cookingFuel(key)` | `cooking_fuel` = (burn time provider `key`, speed provider `cooking/speed_default`). |
| `compostable(key)` | `compostable` = (layers provider `key`). |
| `potPattern(key)` | `provides_pottery_pattern` = the registry holder for the decorated pot pattern `key`, resolved after the data registries load. |
| `useBlockDescriptionPrefix()` / `useItemDescriptionPrefix()` | The translation key of the item name is `block.<namespace>.<path>` or `item.<namespace>.<path>` (`Util.makeDescriptionId`). |
| `overrideDescription`, `requiredFeatures` | Not used for these items except the `requiredFeatures` call that `registerBlock` makes from the block. |

### 2.3 The common prototype and the finaliser

The component initialiser of every item starts by copying `DataComponents.COMMON_ITEM_COMPONENTS`. Values read from `DataComponents.<clinit>`:

| Component (id from 17 §1.2 or read from the registration order) | Common value |
|---|---|
| `max_stack_size` (1) | 64 |
| `lore` (11) | empty |
| `enchantments` (13) | empty |
| `repair_cost` (19) | 0 |
| `use_effects` (5) | `UseEffects.DEFAULT` = (can_sprint false, interact_vibrations true, speed multiplier 0.2) |
| `attribute_modifiers` (16) | empty |
| `rarity` (12) | `common` |
| `break_sound` (83) | `item.break` |
| `tooltip_display` (18) | `TooltipDisplay.DEFAULT` |
| `attack_animation` (40) | `SwingAnimation.DEFAULT` = (type `whack`, duration 6) |
| `interact_animation` (41) | `SwingAnimation.DEFAULT` |

After the item's own `component(...)` calls, the finaliser (`Item$Properties.finalizeInitializer`) sets, in this order: `item_name` (9) = the translatable text of the description id, and `item_model` (10) = the item key's identifier; then adds a validator: an item whose prototype has `damage` and a `max_stack_size` above 1 is rejected with the error text "Item cannot have both durability and be stackable". Component ids not listed in 17 §1.2 that this document uses: `container` 77, `block_state` 78, `bees` 79, `compostable` 84, `cooking_fuel` 85, `brewing_fuel` 86, `provides_pottery_pattern` 117, `ominous_bottle_amplifier` 65 (122 component types in all, 0 to 121; read from the registration order of `DataComponents`).

An item stack on the wire carries only a patch (00 §12.2), so both ends must reproduce the prototype of every item (this table and the rows of section 3 are what a server needs to build it).

### 2.4 `Item` behaviour used here

The base class `Item` implements, with no subclass needed: `use` (consumable first: `Consumable.startConsuming`; else equippable swap; else `blocks_attacks` or `kinetic_weapon` start using; else PASS), `finishUsingItem` (`Consumable.onConsume` when a `consumable` exists), `getUseDuration` (`consumable.consumeTicks`, or 72000 when `blocks_attacks` or `kinetic_weapon` exist, else 0), `useOn` (block transformer, else PASS), `getDestroySpeed` (the `tool` component, else 1.0), `isBarVisible` (stack damaged). The use-in-air path that calls `use` is 29 §9.7.

## 3. The 103 rows

Every row is a `registerBlock` or `registerItem` call (or a collection call) read from `Items.<clinit>`. "Components added" lists only what the registration adds to the common set of 2.3 (and the `item_name` and `item_model` of the finaliser, which every item has). "none" means the item is the default `BlockItem` or `Item` with no component beyond the common set. Food values are (nutrition, saturation, can_always_eat) with saturation computed as `nutrition x modifier x 2` in single precision (`FoodConstants.saturationByModifier`, read; the modifier is 0.1 for all three foods of this range). For a block item the first column of the Class says `BlockItem`: the block it places is the block of the same key (24-1 to 24-8) except where noted.

| Field | Registry id | Key | Class created | Components added by the registration (beyond the common set of 2.3) |
|---|---|---|---|---|
| 1150 | 1505 | `composter` | `BlockItem` | `cooking_fuel` (burn time `cooking/time_wood_blocks`, speed `cooking/speed_default`) |
| 1151 | 1506 | `barrel` | `BlockItem` | `cooking_fuel` (burn time `cooking/time_wood_blocks`, speed `cooking/speed_default`); `container` = empty |
| 1152 | 1507 | `smoker` | `BlockItem` | `container` = empty |
| 1153 | 1508 | `blast_furnace` | `BlockItem` | `container` = empty |
| 1154 | 1509 | `cartography_table` | `BlockItem` | `cooking_fuel` (burn time `cooking/time_wood_blocks`, speed `cooking/speed_default`) |
| 1155 | 1510 | `fletching_table` | `BlockItem` | `cooking_fuel` (burn time `cooking/time_wood_blocks`, speed `cooking/speed_default`) |
| 1156 | 1511 | `grindstone` | `BlockItem` | none |
| 1157 | 1512 | `smithing_table` | `BlockItem` | `cooking_fuel` (burn time `cooking/time_wood_blocks`, speed `cooking/speed_default`) |
| 1158 | 1513 | `stonecutter` | `BlockItem` | none |
| 1159 | 1514 | `bell` | `BlockItem` | none |
| 1160 | 1515 | `lantern` | `BlockItem` | none |
| 1161 | 1516 | `soul_lantern` | `BlockItem` | none |
| 1162 | 1517 to 1524 | 8 keys: `copper_lantern`, `exposed_copper_lantern`, `weathered_copper_lantern`, `oxidized_copper_lantern`, then the same four with `waxed_` in front | `BlockItem` | none |
| 1163 | 1525 | `sweet_berries` | `BlockItem`, item name prefix | `compostable` (`compostable/low`); `food` {2, 0.4, false}, `consumable` = default food |
| 1164 | 1526 | `glow_berries` | `BlockItem`, item name prefix | `compostable` (`compostable/low`); `food` {2, 0.4, false}, `consumable` = default food |
| 1165 | 1527 | `campfire` | `BlockItem` | `container` = empty |
| 1166 | 1528 | `soul_campfire` | `BlockItem` | `container` = empty |
| 1167 | 1529 | `shroomlight` | `BlockItem` | `compostable` (`compostable/medium`) |
| 1168 | 1530 | `honeycomb` | `HoneycombItem` | none |
| 1169 | 1531 | `bee_nest` | `BlockItem` | `bees` = empty; `block_state` {honey_level 0} |
| 1170 | 1532 | `beehive` | `BlockItem` | `bees` = empty; `block_state` {honey_level 0} |
| 1171 | 1533 | `honey_bottle` | `Item` | `food` {6, 1.2, true}, `consumable` honey, `use_remainder` glass_bottle, `max_stack_size` 16; crafting remainder glass_bottle (not a component) |
| 1172 | 1534 | `honeycomb_block` | `BlockItem` | none |
| 1173 | 1535 | `lodestone` | `BlockItem` | none |
| 1174 | 1536 | `crying_obsidian` | `BlockItem` | none |
| 1175 | 1537 | `blackstone` | `BlockItem` | none |
| 1176 | 1538 | `blackstone_slab` | `BlockItem` | none |
| 1177 | 1539 | `blackstone_stairs` | `BlockItem` | none |
| 1178 | 1540 | `gilded_blackstone` | `BlockItem` | none |
| 1179 | 1541 | `polished_blackstone` | `BlockItem` | none |
| 1180 | 1542 | `polished_blackstone_slab` | `BlockItem` | none |
| 1181 | 1543 | `polished_blackstone_stairs` | `BlockItem` | none |
| 1182 | 1544 | `chiseled_polished_blackstone` | `BlockItem` | none |
| 1183 | 1545 | `polished_blackstone_bricks` | `BlockItem` | none |
| 1184 | 1546 | `polished_blackstone_brick_slab` | `BlockItem` | none |
| 1185 | 1547 | `polished_blackstone_brick_stairs` | `BlockItem` | none |
| 1186 | 1548 | `cracked_polished_blackstone_bricks` | `BlockItem` | none |
| 1187 | 1549 | `respawn_anchor` | `BlockItem` | none |
| 1188 | 1550 | `candle` | `BlockItem` | none |
| 1189 | 1551 to 1566 | 16 keys: `<color>_candle`, colours in the order white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black | `BlockItem` | none |
| 1190 | 1567 | `small_amethyst_bud` | `BlockItem` | none |
| 1191 | 1568 | `medium_amethyst_bud` | `BlockItem` | none |
| 1192 | 1569 | `large_amethyst_bud` | `BlockItem` | none |
| 1193 | 1570 | `amethyst_cluster` | `BlockItem` | none |
| 1194 | 1571 | `pointed_dripstone` | `BlockItem` | none |
| 1195 | 1572 | `sulfur_spike` | `BlockItem` | none |
| 1196 | 1573 | `ochre_froglight` | `BlockItem` | none |
| 1197 | 1574 | `verdant_froglight` | `BlockItem` | none |
| 1198 | 1575 | `pearlescent_froglight` | `BlockItem` | none |
| 1199 | 1576 | `frogspawn` | `PlaceOnWaterBlockItem` | none |
| 1200 | 1577 | `echo_shard` | `Item` | `rarity` uncommon |
| 1201 | 1578 | `brush` | `BrushItem` | `max_damage` 64, `max_stack_size` 1, `damage` 0 |
| 1202 | 1579 | `netherite_upgrade_smithing_template` | `SmithingTemplateItem` (netherite upgrade) | `rarity` uncommon |
| 1203 | 1580 | `sentry_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1204 | 1581 | `dune_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1205 | 1582 | `coast_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1206 | 1583 | `wild_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1207 | 1584 | `ward_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` rare |
| 1208 | 1585 | `eye_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` rare |
| 1209 | 1586 | `vex_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` rare |
| 1210 | 1587 | `tide_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1211 | 1588 | `snout_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1212 | 1589 | `rib_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1213 | 1590 | `spire_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` rare |
| 1214 | 1591 | `wayfinder_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1215 | 1592 | `shaper_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1216 | 1593 | `silence_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` epic |
| 1217 | 1594 | `raiser_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1218 | 1595 | `host_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1219 | 1596 | `flow_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1220 | 1597 | `bolt_armor_trim_smithing_template` | `SmithingTemplateItem` (armor trim) | `rarity` uncommon |
| 1221 | 1598 | `angler_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `angler` |
| 1222 | 1599 | `archer_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `archer` |
| 1223 | 1600 | `arms_up_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `arms_up` |
| 1224 | 1601 | `blade_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `blade` |
| 1225 | 1602 | `brewer_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `brewer` |
| 1226 | 1603 | `burn_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `burn` |
| 1227 | 1604 | `danger_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `danger` |
| 1228 | 1605 | `explorer_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `explorer` |
| 1229 | 1606 | `flow_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `flow` |
| 1230 | 1607 | `friend_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `friend` |
| 1231 | 1608 | `guster_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `guster` |
| 1232 | 1609 | `heart_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `heart` |
| 1233 | 1610 | `heartbreak_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `heartbreak` |
| 1234 | 1611 | `howl_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `howl` |
| 1235 | 1612 | `miner_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `miner` |
| 1236 | 1613 | `mourner_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `mourner` |
| 1237 | 1614 | `plenty_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `plenty` |
| 1238 | 1615 | `prize_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `prize` |
| 1239 | 1616 | `scrape_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `scrape` |
| 1240 | 1617 | `sheaf_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `sheaf` |
| 1241 | 1618 | `shelter_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `shelter` |
| 1242 | 1619 | `skull_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `skull` |
| 1243 | 1620 | `snort_pottery_sherd` | `Item` | `rarity` uncommon; `provides_pottery_pattern` = `snort` |
| 1244 | 1621 to 1628 | 8 keys: `copper_grate`, `exposed_copper_grate`, `weathered_copper_grate`, `oxidized_copper_grate`, then the same four with `waxed_` in front | `BlockItem` | none |
| 1245 | 1629 to 1636 | 8 keys: `copper_bulb`, `exposed_copper_bulb`, `weathered_copper_bulb`, `oxidized_copper_bulb`, then the same four with `waxed_` in front | `BlockItem` | none |
| 1246 | 1637 to 1644 | 8 keys: `copper_chest`, `exposed_copper_chest`, `weathered_copper_chest`, `oxidized_copper_chest`, then the same four with `waxed_` in front | `BlockItem` | none |
| 1247 | 1645 to 1652 | 8 keys: `copper_golem_statue`, `exposed_copper_golem_statue`, `weathered_copper_golem_statue`, `oxidized_copper_golem_statue`, then the same four with `waxed_` in front | `BlockItem` | `block_state` {pose standing} |
| 1248 | 1653 | `trial_spawner` | `BlockItem` | none |
| 1249 | 1654 | `trial_key` | `Item` | none |
| 1250 | 1655 | `ominous_trial_key` | `Item` | none |
| 1251 | 1656 | `vault` | `BlockItem` | none |
| 1252 | 1657 | `ominous_bottle` | `Item` | `consumable` ominous, `ominous_bottle_amplifier` = 0, `rarity` uncommon |

Notes on the rows:

1. Name prefix. All block-item rows use `block.minecraft.<key>` for the name text; `sweet_berries` and `glow_berries` are block items that use `item.minecraft.<key>`; the other 49 `registerItem` rows use `item.minecraft.<key>`.
2. Stack size is the common 64 except: `honey_bottle` 16, `brush` 1. The templates, sherds, keys, `echo_shard`, `ominous_bottle` and all block items stack to 64.
3. Rarity is `common` except where a row says otherwise. Rarity colours (`Rarity`, read): common white, uncommon yellow, rare aqua, epic light purple. Rarity wire values are 0 common, 1 uncommon, 2 rare, 3 epic (`Rarity` ids).
4. Templates by rarity: uncommon 14 (`netherite_upgrade`, `sentry`, `dune`, `coast`, `wild`, `tide`, `snout`, `rib`, `wayfinder`, `shaper`, `raiser`, `host`, `flow`, `bolt`), rare 4 (`ward`, `eye`, `vex`, `spire`), epic 1 (`silence`). Count check: 14 + 4 + 1 = 19.
5. Fields 1244 to 1247 (`copper_grate`, `copper_bulb`, `copper_chest`, `copper_golem_statue`) register default `BlockItem`s through the weathering collection; the statue adds the block state component of its row. `copper_lantern` (1162) and the colour collection `candle` (1189, ids 1551 to 1566) are default block items too.
6. `trial_spawner` and `vault` are default `BlockItem`s. `trial_key` and `ominous_trial_key` are plain `Item`s with no component (no rarity, stack 64).

## 4. Block items of the range

### 4.1 What `BlockItem` adds (summary, not repeated from 29)

Placement (`useOn`, `place`, `getPlacementState`, `canPlace`, `placeBlock`) is specified in 29 §9.6 and is not repeated. Behaviours of `BlockItem` that the rows of this range rely on and that 29 does not state:

1. `block_state` component. After placing, `updateBlockStateFromTag` reads the stack's `block_state` (default empty). If it is non-empty and applying its properties to the placed state changes the state, the new state is written with flags 2. The prototypes with this component: `bee_nest` and `beehive` (`honey_level` = 0), `copper_golem_statue` and its seven siblings (`pose` = `standing`).
2. `container` component. `barrel`, `smoker`, `blast_furnace`, `campfire`, `soul_campfire` carry an empty `container`; when the block entity is created from a stack, `BlockEntity.applyComponentsFromItemStack` copies the stack components (the update of the block entity from the stack, `updateBlockEntityComponents`, is done on the placed position, then `setChanged`).
3. `bees` component (`bee_nest`, `beehive`): empty in the prototype; the use of this component by the beehive block entity was not read (block entity engines are not in this document, see Open questions 6 and 7).
4. `canFitInsideContainerItems` is true for every block item whose block is not a shulker box (not relevant to this range's blocks, all true).
5. `onDestroyed(itemEntity)`: when a block-item entity is destroyed, its stack's `container` is replaced by empty and the non-empty contents are spilled as new item entities (`ItemUtils.onContainerDestroyed`), so a destroyed barrel item entity drops its contents.
6. `getPlaceSound` returns the block's place sound (`SoundType`), played at placement (29).

### 4.2 Berries as block items

`sweet_berries` places `sweet_berry_bush` and `glow_berries` places `cave_vines` (the block of 24-3). Each is a `BlockItem` created through `createBlockItemWithCustomItemName`, so its name prefix is `item`, with components `food` (2, 0.4, false) and the default food `consumable` (3.1), and `compostable` = `compostable/low`. Right-click on a block runs `BlockItem.useOn` first (29 §9.5, §9.6); eating goes through `Item.use` (`consumable` present, section 5), which is the use-in-air path of 29 §9.7. Which of the two a click on a block reaches when placement is refused was not traced for these two items (Open question 5).

### 4.3 Frogspawn: `PlaceOnWaterBlockItem`

`useOn` always returns PASS (the item cannot be placed directly on a clicked block). `use` (in air or on a click that ends in `use`): compute the player's ray with fluid mode `SOURCE_ONLY` (`Item.getPlayerPOVHitResult`, so only water source blocks are hit), move the hit position one block **up** (`BlockHitResult.withPosition(pos.above())`), and run the ordinary `BlockItem.useOn` with a new use context built on that hit. The result is the result of that placement. This lets frogspawn be placed on the surface of water. (`lily_pad` uses the same class and lies earlier in the registry.)

### 4.4 The `cooking_fuel` component and the five wooden workstations

Rows 1150 (`composter`), 1151 (`barrel`), 1154 (`cartography_table`), 1155 (`fletching_table`), 1157 (`smithing_table`) are furnace fuel.

1. Schema: `cooking_fuel` = (burn time: an int provider reference, speed multiplier: a float provider reference). The registration passes the burn time key `cooking/time_wood_blocks` and the speed key `cooking/speed_default`. Both are `ResolvableInt` or `ResolvableFloat` values: either a constant or a reference to a data-pack entry in `context_int_provider` or `context_float_provider`, evaluated with a loot context (`ResolvableInt.get(context, default)`). `ResolvableInt.getFromItem(stack, component, accessor, context, default)` returns the provider's value when the stack has the component and `default` otherwise.
   Encoding (read): `cooking_fuel` is both persistent and network-synchronised (component type registration 85). Stream form: the burn-time provider, then the speed provider, nothing else. Each provider (`ResolvableInt`, `ResolvableFloat`) is an either: one boolean byte, then if true (a constant) a 4-byte big-endian int (or 4-byte float), if false (a reference) an identifier string naming an entry of `context_int_provider` (or `context_float_provider`). Note that the registered key `cooking/time_wood_blocks` is therefore sent as the reference form: boolean false and the identifier `minecraft:cooking/time_wood_blocks` (the Identifier stream codec of 04). Data form: field names `burn_time` and `speed_multiplier`; each an int/float or a key string. (The assignment boolean true = constant was read from the order of the two encode branches; the receiving client needs the `context_*_provider` data registries only to evaluate, not to decode.)
2. The furnace engine (`AbstractFurnaceBlockEntity.getBurnDuration` and a speed multiplier accessor) calls these with a context built for the furnace block and the default 0 (burn) or the default speed given in code; the exact parameters of that context were not read in this round (Open question 3).
3. Data read for this range: `context_int_provider/cooking/time_wood_blocks` = `div(300, conditional(block predicate "fast_cooking", on_true cooking/fast_burn_time_reduction_factor, on_false cooking/normal_burn_time_reduction_factor))`; normal factor = 1; fast factor = 2; `context_float_provider/cooking/speed_default` = conditional on the same predicate: normal multiplier 1.0, fast multiplier 2.0. The predicate `predicate/block/fast_cooking` is `match_block` with the blocks `smoker` and `blast_furnace`. So these five items burn 300 ticks in an ordinary furnace and 150 ticks in a smoker or blast furnace, with cooking speed 1.0 versus 2.0 (integer division of 300 by the factor is the reading of "div"; rounding for other values was not tested).

### 4.5 The `compostable` component

`compostable` = (layers: an int provider reference); used by the composter block (`ComposterBlock`). Encoding (read): persistent and network-synchronised (component 84); the stream form is exactly the `ResolvableInt` either of 4.4 item 1 (boolean, then int or identifier of a `context_int_provider` entry), with no wrapper; data form is an object with the field `layers`. In this range: `sweet_berries`, `glow_berries` use `compostable/low`; `shroomlight` uses `compostable/medium`.

1. Evaluation (`ComposterBlock.addLayer`, read): a loot context is built with the parameters `block_state` = the composter's current state, `origin` = the centre of the block position, and optionally `interacting_entity`, parameter set `block_interact`. `layers` = provider value with default 0 (`ResolvableInt.get(context, 0)`). If layers > 0: `newLevel = clamp(level + layers, 0, 7)`; the block is set to that level (`setBlockAndUpdate`); game event `block_change` with the entity and new state; if `newLevel` is 7, a tick is scheduled after 20 ticks. (When `level` becomes 8 the block's tick turns 7 into 8 and plays `block.composter.ready`; that is the block's engine, 24.)
2. Data read: `compostable/low` is a number dispatcher: when the composter's `level` is 0 the value is always 1; otherwise a weighted list with value 1 weight 30 and value 0 weight 70. `compostable/low_medium` is the same with weights 50 and 50, `compostable/medium` with weights 65 and 35. `compostable/medium_high` has the same dispatcher (level 0 gives 1) with default weights 85 for value 1 and 15 for value 0. `compostable/always_add_one` is the bare constant 1 (not a dispatcher). The first item put into an empty composter therefore always adds a layer. The random generator that picks from the weighted list is the context's (the draw order was not traced, Open question 4).

### 4.6 Copper block items

The five collections (`copper_lantern`, `copper_grate`, `copper_bulb`, `copper_chest`, `copper_golem_statue`) register their items with the default `BlockItem` factory; the only addition is the statue's `block_state` {pose standing}. The block for each key is the block of the same key in 24-8 (the block collections use the same ordering). Waxed variants are made by `HoneycombItem` (section 6): the mapping of unwaxed block to waxed block is the data of `HoneycombItem.WAXABLES`: for each weathering collection, `unaffected to waxed unaffected`, `exposed to waxed exposed`, and so on.

## 5. The consume pipeline, honey bottle, ominous bottle

### 5.1 Components

| Component | Wire (17 §1.2, 00 §12) and semantics |
|---|---|
| `food` (23) | `nutrition` VarInt, `saturation` Float, `can_always_eat` Boolean. Built by `FoodProperties$Builder`: saturation = `nutrition x modifier x 2` (single precision). Honey bottle: nutrition 6, modifier 0.1, always edible, so saturation 1.2. Sweet berries and glow berries: nutrition 2, modifier 0.1, saturation 0.4, not always edible. |
| `consumable` (24) | `consume_seconds` Float, `animation` (`ItemUseAnimation`, a VarInt; declaration order none, eat, drink, block, bow, trident, crossbow, spyglass, toot_horn, brush, bundle, spear, so the ordinals are 0 to 11; the `STREAM_CODEC` is built from `ByIdMap.continuous` over the ordinals with out-of-bounds strategy ZERO, so the wire value is the ordinal and an unknown id decodes as `none`), `sound` holder, `has_consume_particles` Boolean, list of consume effects. |
| `use_remainder` (25) | An item stack template (the item left behind). |
| `ominous_bottle_amplifier` (65) | VarInt `value`, codec range 0 to 4. |

Constants of `Consumable` and `Consumables` (read):

| Name | Value |
|---|---|
| default consume time | 1.6 s, `consumeTicks` = `(int)(seconds x 20.0f)` (honey bottle 2.0 s gives 40, default 1.6 s gives 32) |
| default food consumable (`DEFAULT_FOOD`, `defaultFood`) | 1.6 s, animation `eat`, sound `entity.generic.eat`, particles on, no effects |
| default drink (`defaultDrink`) | 1.6 s, animation `drink`, sound `entity.generic.drink`, particles off |
| honey bottle consumable (`Consumables.HONEY_BOTTLE`) | default drink with 2.0 s, sound `item.honey_bottle.drink`, one on-consume effect `remove_effects` of the single effect `poison` (46 §4: poison is mob effect id 18) |
| ominous bottle consumable (`Consumables.OMINOUS_BOTTLE`) | default drink (1.6 s, 32 ticks) plus one on-consume effect `play_sound` `item.ominous_bottle.dispose` (the builder method `soundAfterConsume`) |
| effect-emission interval | every 4 ticks (`CONSUME_EFFECTS_INTERVAL`) |
| start fraction | 0.21875 (`CONSUME_EFFECTS_START_FRACTION`) |

Sound names are keys of the sound event registry (46 §14 lists the ids): `item.honey_bottle.drink`, `item.ominous_bottle.dispose`, `entity.generic.eat`, `entity.generic.drink`, `entity.player.burp`.

### 5.2 Starting to eat or drink (`Item.use` then `Consumable.startConsuming`)

1. `canConsume(entity, stack)`: if the stack has `food` and the entity is a `Player`, the answer is `Player.canEat(food.can_always_eat)`; otherwise true. `Player.canEat(always)` is true when the player's abilities are invulnerable, or `always`, or the food data `needsFood` (food level below 20).
2. If `canConsume` is false: `FAIL`.
3. If `consumeTicks > 0`: `entity.startUsingItem(hand)` and return `CONSUME` (the use lasts `getUseDuration` = `consumeTicks` ticks: 40 for the honey bottle, 32 for the ominous bottle and the berries).
4. If `consumeTicks` is 0: `onConsume` runs at once and the result is `CONSUME` with the returned stack as the held item.

### 5.3 While using (`ItemStack.onUseTick`)

Each tick of use the stack calls `Consumable.shouldEmitParticlesAndSounds(remainingTicks)`; when true it calls `emitParticlesAndSounds(random, entity, stack, 5)`.

1. `elapsed = consumeTicks - remainingTicks`, `threshold = (int)(consumeTicks x 0.21875f)` (8 for honey bottle, 7 for 32 ticks).
2. True when `elapsed > threshold` and `remainingTicks mod 4 = 0`.
3. `emitParticlesAndSounds(random, entity, stack, count)`: draw `a` = 0.5 or 1.0 (`nextBoolean`), `b` = `triangle(1.0, 0.2)`, `c` = `randomBetween(0.9, 1.0)`. Volume = 0.5 if animation is `drink` else `a`; pitch = `c` if `drink` else `b`. If `has_consume_particles`: spawn `count` item particles of the stack (`spawnItemParticles`). Then play the sound (the consumable's `sound`, or the item's own override when the item implements `OverrideConsumeSound`) at the entity with that volume and pitch (`LivingEntity.playSound`).
4. Honey bottle and ominous bottle have `has_consume_particles` false, so only the sound is produced.

### 5.4 Finishing (`LivingEntity.completeUsingItem`, `ItemStack.finishUsingItem`, `Consumable.onConsume`)

1. `completeUsingItem` (server, or client while using): if the stack in the used hand no longer equals the stack being used, stop (`releaseUsingItem`). Otherwise `result = useItem.finishUsingItem(level, entity)`; if `result` is a different object, put it in the hand; `stopUsingItem`.
2. `ItemStack.finishUsingItem` takes a copy of the stack (the "before" count), runs `Item.finishUsingItem` (which calls `Consumable.onConsume` when a `consumable` exists), then `applyAfterUseComponentSideEffects`.
3. `Consumable.onConsume(level, entity, stack)` in order:
   1. `emitParticlesAndSounds(random, entity, stack, 16)`.
   2. If the entity is a `ServerPlayer`: award the statistic `item_used` for the item, fire the advancement trigger `consume_item` with the stack.
   3. For every component of the stack that is a **consume listener** (`ConsumableListener`: the `food` component and the `ominous_bottle_amplifier` component, among others) call its `onConsume(level, entity, stack, consumable)`. The order between several listeners on one stack was not traced (no item of this range carries two).
   4. If not client side: apply each on-consume effect in list order (`ConsumeEffect.apply(level, stack, entity)`).
   5. Game event `drink` if the animation is `drink`, else `eat` (46 §5: drink 12, eat 13).
   6. `stack.consume(1, entity)`: shrink the stack by 1 unless the entity has infinite materials (creative).
4. `applyAfterUseComponentSideEffects`: if the stack has `use_remainder`, `UseRemainder.convertIntoRemainder(stackAfter, countBefore, infiniteMaterials, onExtra)`:
   1. infinite materials: return the stack unchanged;
   2. if the stack's count is not below the count before (nothing was consumed): return it unchanged;
   3. create the remainder stack from the template;
   4. if the consumed stack is now empty: the remainder **replaces** it as the held item;
   5. else give the remainder to `entity.handleExtraItemsCreatedOnUse(remainder)`: for a `Player` that is `Inventory.add(remainder)`, and when the inventory has no room, `drop(remainder, false)`; for other entities nothing; and return the shrunken stack.
   Then if the stack has `use_cooldown`, apply it.
5. The statistic and trigger also happen in `onConsume` (step 3.2), so one meal is counted once.

### 5.5 The two listeners and the three consume effects of this range

| Piece | Behaviour (read) |
|---|---|
| `FoodProperties.onConsume` | Plays the consumable's `sound` at the entity position with source `neutral`, volume 1.0, pitch `triangle(1.0, 0.4)`. If the entity is a `Player`: `FoodData.eat(food)`, then plays `entity.player.burp` at the player with source `players`, volume 0.5, pitch `randomBetween(0.9, 1.0)`. |
| `FoodData.eat(food)` | `add(nutrition, saturation)`: `foodLevel = clamp(foodLevel + nutrition, 0, 20)`; `saturation = clamp(saturation + s, 0, foodLevel)`. |
| `OminousBottleAmplifier.onConsume` | `entity.addEffect(effect bad_omen, duration 120000 ticks, amplifier = value, ambient false, visible false, show icon true)` (46 §4: bad_omen is mob effect id 30). Constants: `EFFECT_DURATION` 120000, `MIN_AMPLIFIER` 0, `MAX_AMPLIFIER` 4. The tooltip lists that effect through `PotionContents.addPotionTooltip` with scale 1.0 and the tick rate. |
| `RemoveStatusEffectsConsumeEffect.apply` | For each effect in its set: `entity.removeEffect(effect)`; returns true if any was removed (honey: poison only). |
| `PlaySoundConsumeEffect.apply` | Plays its sound at the entity's block position with the entity's sound source, volume 1.0, pitch 1.0; returns true (ominous bottle: `item.ominous_bottle.dispose`). |

### 5.6 `honey_bottle` (field 1171, id 1533)

Components beyond the common set: `food` (6, 1.2, true), `consumable` (2.0 s, drink, `item.honey_bottle.drink`, no particles, [remove poison]), `use_remainder` = one `glass_bottle`, `max_stack_size` 16. The item field `craftingRemainingItem` is also one `glass_bottle` (used when the honey bottle is a crafting ingredient). Class is plain `Item`. Order of registration calls: crafting remainder, food and consumable, use remainder, stack size.

Behaviour: it can always be drunk (always edible); the drink lasts 40 ticks; the sound is played when `remainingTicks` is a multiple of 4 and `elapsed > 8` (both conditions of 5.3 step 2; `elapsed = 40 - remainingTicks`), with volume 0.5 and a pitch in [0.9, 1.0]; at the end the food rules of 5.5 apply and poison is removed; the stack shrinks by 1 and the glass bottle is returned as in 5.4 step 4.

Worked example (emission ticks, read from the two conditions of 5.3 step 2): 40-tick drink, threshold 8. Remaining 40 gives elapsed 0 and so on; the first remaining value that is a multiple of 4 with elapsed above 8 is 28 (elapsed 12). Emissions are at remaining 28, 24, 20, 16, 12, 8, 4 = elapsed 12, 16, 20, 24, 28, 32, 36 (seven sounds). Elapsed 9 is never an emission tick. For a 32-tick consumable the threshold is 7, the first emission is at remaining 24 (elapsed 8), then remaining 20, 16, 12, 8, 4 (elapsed 12 to 28).

### 5.7 `ominous_bottle` (field 1252, id 1657)

Components beyond the common set: `rarity` uncommon, `consumable` (the ominous consumable), `ominous_bottle_amplifier` = 0. Class is plain `Item`; stack size 64; no `food`, so it can be drunk at any food level (`canConsume` is true without `food`) and gives no nutrition. The actual amplifier of a dropped bottle is set by the loot function `set_ominous_bottle_amplifier` (data, 26). Effect on consumption: Bad Omen at amplifier `value` for 120000 ticks, plus the dispose sound. No remainder (the bottle is not returned).

## 6. Honeycomb

`honeycomb` (field 1168, id 1530) is a `HoneycombItem` (also a `SignApplicator`), with no components beyond the common set.

1. **Wax lookup.** `HoneycombItem.WAXABLES` is a bidirectional map built from 15 weathering block collections, in this order: `copper_block`, `cut_copper`, `cut_copper_slab`, `cut_copper_stairs`, `chiseled_copper`, `copper_door`, `copper_trapdoor`, `copper_bars`, `copper_grate`, `copper_bulb`, `copper_chest`, `copper_golem_statue`, `lightning_rod`, `copper_lantern`, `copper_chain`. For each collection the pairs (unwaxed to waxed) are, per weather state: unaffected to waxed unaffected, exposed to waxed exposed, weathered to waxed weathered, oxidized to waxed oxidized (`zipUnwaxedWaxed`). `WAX_OFF_BY_BLOCK` is the inverse (used by axes, 17). `getWaxed(state)` = the waxed block of the state's block (if any) with the properties of the old state copied (`withPropertiesOf`).
2. **`useOn(context)`.** If the clicked block has a waxed counterpart: (a) if the player is a `ServerPlayer`, fire `item_used_on_block` with the position and the stack; (b) shrink the stack by 1 (the item does not test creative itself; creative does not consume because the game mode restores the count, 29 §9.2 step 7); (c) `setBlock(pos, waxedState, flags 11)`; (d) game event `block_change` at the position with the player and the new state; (e) level event 3003 (wax-on particles) at the position; (f) play `item.honeycomb.wax_on` at the position, source `blocks`, volume 1.0, pitch 1.0; (g) if the block is a chest of any type other than `single`, do (d), (e), (f) once more for the connected half (`ChestBlock.getConnectedBlockPos`) using that position's current state (only the clicked half is rewritten by this item; the other half is handled by the chest block); (h) return `SUCCESS`. If there is no waxed counterpart: `PASS`.
3. **Signs.** `tryApplyToSign(level, sign, slot, stack, player)`: `sign.setWaxed(true)`; when that call reports a change, level event 3003 at the sign position and play `item.honeycomb.wax_on` (source `blocks`, volume 1.0, pitch 1.0) and return true, else false. `canApplyToSign` is always true. (The sign engine that calls these is 24-3 and 29.)

## 7. Brush

`brush` (field 1201, id 1578): class `BrushItem`, components beyond the common set: `max_damage` 64, `max_stack_size` 1, `damage` 0. Constants: use duration 200 ticks (`USE_DURATION`), `ANIMATION_DURATION` 10, use animation `brush`.

1. **`useOn`.** If a player exists and the player's view ray (`ProjectileUtil.getHitResultOnViewVector(player, entities that can be picked, blockInteractionRange)`) is a block hit, `player.startUsingItem(hand)`. The result is always `CONSUME`.
2. **`getUseDuration`** = 200 for every stack.
3. **`onUseTick(level, entity, stack, remainingTicks)`** (both sides):
   1. If `remainingTicks < 0` or the entity is not a `Player`: `releaseUsingItem`, stop.
   2. Recompute the view-ray hit; if it is not a block hit: `releaseUsingItem`, stop.
   3. `elapsed = 200 - remainingTicks + 1`. A brushing event happens when `elapsed mod 10 = 5` (elapsed 5, 15, ..., 195: 20 events in a full use).
   4. On an event: let `state` = the block at the hit position, `arm` = the player's main arm if the used hand is the main hand else the opposite arm. If `state.shouldSpawnTerrainParticles()` and its render shape is not invisible: spawn dust particles (client effect, 7.1). Play the sound at the position, source `blocks` (the call is the four-argument `Level.playSound(entity, blockPos, sound, source)` overload with the brushing player as the entity and no volume or pitch argument; whether it excludes the player's own client and the volume and pitch that overload applies were not read, so they are open, question 8): the block's `getBrushSound()` when the block is a `BrushableBlock`, else `item.brush.brushing.generic` (the other keys, `item.brush.brushing.sand` and `.gravel`, belong to the sand and gravel blocks). Then, on a `ServerLevel`, if the block entity at the position is a `BrushableBlockEntity`: `completed = brush(gameTime, level, player, hit face direction, stack)`; if `completed`: `stack.hurtAndBreak(1, player, slot)` where `slot` is the offhand when the stack equals the player's offhand item, else the main hand. **Durability is spent only when a block is finished** (so one brush completes up to 64 blocks).
4. The item model of the brush switches by a use-progress range dispatch (thresholds 0.25, 0.5, 0.75; models `brush_brushing_0`, `_1`, `_2`, fallback `brush`), data of the item definition.

### 7.1 Dust particles (client cosmetic)

Count `nextInt(7, 12)` per event (bounds as the call is written: origin 7, bound 12; whether the bound is exclusive was not read; if exclusive, 7 to 11, `(inferred)`). Each particle is a block particle of the state at the hit location (x is shifted by 1.0e-6 toward lower coordinates when the hit face is west, z likewise for north), with velocity `(dx x side x 3.0 x r1, 0, dz x side x 3.0 x r2)`, `side` = +1 for the right arm and -1 for the left, `r1`, `r2` uniform doubles in [0,1) and `(dx, dz)` = `DustParticlesDelta.fromDirection(view vector, face)` (its table was not read).

### 7.2 `BrushableBlockEntity` (server state of suspicious sand and gravel)

Fields: `brushCount`, `brushCountResetsAtTick`, `coolDownEndsAtTick`, `item` (the hidden stack), `hitDirection`, `lootTable`, `lootTableSeed`. Constants: `BRUSH_COOLDOWN_TICKS` 10, `BRUSH_RESET_TICKS` 40, `REQUIRED_BRUSHES_TO_BREAK` 10. NBT keys: `LootTable`, `LootTableSeed`, `hit_direction`, `item`.

Completion state (the block property `dusted`, 0 to 3): 0 when `brushCount` is 0; 1 when 1 to 2; 2 when 3 to 5; 3 when 6 or more.

`brush(gameTime, level, entity, face, stack)`:

1. If `hitDirection` is unset, set it to `face`.
2. `brushCountResetsAtTick = gameTime + 40`.
3. If `gameTime < coolDownEndsAtTick`: return false.
4. `coolDownEndsAtTick = gameTime + 10`.
5. Unpack the loot table (below).
6. Remember the completion state; `brushCount = brushCount + 1`; if it is now at least 10: run `brushingCompleted` and return true.
7. Otherwise schedule a block tick 2 ticks later for the block; recompute the completion state; if it changed, set the block's `dusted` property to it (`setBlockAndUpdate`); return false.

`checkReset(level)` (called from the block's scheduled tick): if `brushCount` is not 0 and `gameTime >= brushCountResetsAtTick`: remember the completion state; `brushCount = max(0, brushCount - 2)`; if the completion state changed, set `dusted`; then `brushCountResetsAtTick = gameTime + 4`; if `brushCount` is 0, clear `hitDirection`, `brushCountResetsAtTick` and `coolDownEndsAtTick` to unset or 0; at the end of the method, when `brushCount` is not 0 (this test runs after the reset step, whether or not that step fired), the method calls `scheduleTick(pos, block, 2)`: the delay is 2 ticks (read: the delay argument is the constant 2; the constant 4 is only the increment of `brushCountResetsAtTick`). So the block tick re-runs every 2 ticks, and the decay of 2 fires only once `gameTime >= brushCountResetsAtTick`, which after each decay is 4 ticks later: a decay cadence of 4 ticks. The block's own `tick` calls `checkReset` first and then the falling-block check (below-block free and not below the world: falls, 29 and 33).

`unpackLootTable(level, entity, stack)`: nothing if no `lootTable` is set. Otherwise: if the entity is a `ServerPlayer`, fire the `generate_loot` trigger; build loot parameters `origin` = block centre, `luck` = the entity's luck, `this_entity` = the entity, `tool` = the brush stack, in the parameter set `archaeology`; roll the table with `lootTableSeed`; no result gives an empty item; one result is the item; more than one logs a warning and the first result is used. Then `lootTable` is cleared and the entity is marked changed.

`brushingCompleted`: `dropContent`, then level event 3008 at the block position with the state's id (block-break effect), then set the block to the block's `turnsInto` (for a `BrushableBlock`, its `getTurnsInto()`: the plain sand or gravel) default state, or air when the block is not a `BrushableBlock`.

`dropContent`: unpack the loot table again; if the item is not empty: with `w` = the item entity width (read from the entity type) and `h` its height, base position `p = pos + hitDirection offset 1` (hit face direction, default up), spawn an item entity at `(p.x + 0.5 x (1 - w) + w/2, p.y + 0.5 + h/2, p.z + 0.5 x (1 - w) + w/2)` carrying `item.split(nextInt(21) + 10)` (that is 10 to 30 taken from the stack, as many as it holds), delta movement zero; then `item` is set empty. (`ItemEntity` width and height are in 21 §2.)

## 8. Smithing templates

Field 1202 `netherite_upgrade_smithing_template` (id 1579) and fields 1203 to 1220 (ids 1580 to 1597, 18 armor trim templates). All are `SmithingTemplateItem`s with `rarity` as in the rows of section 3 and no other component. The class stores six values and supplies the tooltip and the slot icons that the smithing table menu shows; the **recipes** that use templates (smithing transform and smithing trim) are recipe data and the recipe engine (13 §3; the recipe round).

1. The six stored values, per kind:

| Value | Armor trim template (18 items) | Netherite upgrade template (1 item) |
|---|---|---|
| applies-to text | `item.minecraft.smithing_template.armor_trim.applies_to` in blue | `item.minecraft.smithing_template.netherite_upgrade.applies_to` in blue |
| ingredients text | `item.minecraft.smithing_template.armor_trim.ingredients` in blue | `item.minecraft.smithing_template.netherite_upgrade.ingredients` in blue |
| base slot description | `item.minecraft.smithing_template.armor_trim.base_slot_description` (no colour) | `item.minecraft.smithing_template.netherite_upgrade.base_slot_description` |
| additions slot description | `item.minecraft.smithing_template.armor_trim.additions_slot_description` | `item.minecraft.smithing_template.netherite_upgrade.additions_slot_description` |
| base slot empty icons (in order) | `container/slot/helmet`, `chestplate`, `leggings`, `boots` | `helmet`, `sword`, `chestplate`, `pickaxe`, `leggings`, `axe`, `boots`, `hoe`, `shovel`, `nautilus_armor`, `spear` (11, all under `container/slot/`) |
| additions slot empty icons (in order) | `ingot`, `redstone_dust`, `lapis_lazuli`, `quartz`, `diamond`, `emerald`, `amethyst_shard` (7) | `ingot` (1) |

The icon identifiers are `minecraft:container/slot/<name>`; the 18 names used are `helmet, chestplate, leggings, boots, hoe, axe, sword, shovel, spear, pickaxe, ingot, redstone_dust, quartz, emerald, diamond, lapis_lazuli, amethyst_shard, nautilus_armor`. They are sprites of the GUI atlas (14 §6 and the generated resource pack).

2. Tooltip (`appendHoverText`, lines in order): the text `item.minecraft.smithing_template` in grey (the "Smithing Template" suffix), an empty line, the title `item.minecraft.smithing_template.applies_to` in grey, a line made of a space followed by the applies-to text, the title `item.minecraft.smithing_template.ingredients` in grey, a line made of a space followed by the ingredients text. Grey is `ChatFormatting.GRAY`, blue is `ChatFormatting.BLUE`.
3. The name of each item is `item.minecraft.<key>` (the template items use the item prefix); the pattern a trim template stands for is the item key without the suffix `_armor_trim_smithing_template`: `sentry, dune, coast, wild, ward, eye, vex, tide, snout, rib, spire, wayfinder, shaper, silence, raiser, host, flow, bolt` in registry order. The pattern ids come from `TrimPatterns` (the trim pattern registry is data, 04).
4. Rarity: `ward`, `eye`, `vex`, `spire` rare; `silence` epic; the other 14 (netherite upgrade and 13 trims) uncommon.

## 9. Pottery sherds

Fields 1221 to 1243 (ids 1598 to 1620), 23 items. Each is a plain `Item` with `rarity` uncommon and `provides_pottery_pattern` = the decorated pot pattern whose key equals the name before `_pottery_sherd`.

| Id | Sherd | Pattern key |
|---|---|---|
| 1598 | `angler_pottery_sherd` | `angler` |
| 1599 | `archer_pottery_sherd` | `archer` |
| 1600 | `arms_up_pottery_sherd` | `arms_up` |
| 1601 | `blade_pottery_sherd` | `blade` |
| 1602 | `brewer_pottery_sherd` | `brewer` |
| 1603 | `burn_pottery_sherd` | `burn` |
| 1604 | `danger_pottery_sherd` | `danger` |
| 1605 | `explorer_pottery_sherd` | `explorer` |
| 1606 | `flow_pottery_sherd` | `flow` |
| 1607 | `friend_pottery_sherd` | `friend` |
| 1608 | `guster_pottery_sherd` | `guster` |
| 1609 | `heart_pottery_sherd` | `heart` |
| 1610 | `heartbreak_pottery_sherd` | `heartbreak` |
| 1611 | `howl_pottery_sherd` | `howl` |
| 1612 | `miner_pottery_sherd` | `miner` |
| 1613 | `mourner_pottery_sherd` | `mourner` |
| 1614 | `plenty_pottery_sherd` | `plenty` |
| 1615 | `prize_pottery_sherd` | `prize` |
| 1616 | `scrape_pottery_sherd` | `scrape` |
| 1617 | `sheaf_pottery_sherd` | `sheaf` |
| 1618 | `shelter_pottery_sherd` | `shelter` |
| 1619 | `skull_pottery_sherd` | `skull` |
| 1620 | `snort_pottery_sherd` | `snort` |

1. The `provides_pottery_pattern` component (id 117) is a registry holder of the data-driven registry `decorated_pot_pattern` (23 entries in the jar, one per sherd, files `data/minecraft/decorated_pot_pattern/<name>.json`, each `{"asset_id": "minecraft:<name>_pottery_pattern"}`). On the wire it is the holder encoding of 04 §6 (id into the synchronized registry, in the order the server sends its entries); read: the stream codec is the registry-holder codec of the `decorated_pot_pattern` registry (`holderRegistry`, a registry-friendly buffer), and the component is network-synchronised (component 117); the data form is the pattern key identifier. The pattern of a sherd resolves after the data registries are loaded (`delayedComponent`), so the item prototype exists only after registry load (23).
2. `DecoratedPotPatterns.bootstrap` registers the 23 patterns in the order `angler, archer, arms_up, blade, brewer, burn, danger, explorer, flow, friend, guster, heart, heartbreak, howl, miner, mourner, plenty, prize, scrape, sheaf, shelter, skull, snort`; the asset id is the key's identifier with the suffix `_pottery_pattern`.
3. A decorated pot block entity stores its four sides (`back`, `left`, `right`, `front`) as optional item stack templates (`PotDecorations`); a pot with nothing is `EMPTY`, and the all-brick pot (`allBrick`) uses the item `brick` for each side. The client renderer reads the pattern of each stored item through `provides_pottery_pattern` to pick the texture. The pot's server logic (breaking a pot returns the sherds, the crafting recipe) is block and recipe data and was not read (Open question 6).

## 10. Trial items, echo shard

| Id | Item | Class | Components beyond the common set |
|---|---|---|---|
| 1577 | `echo_shard` | `Item` | `rarity` uncommon |
| 1653 | `trial_spawner` | `BlockItem` of block `trial_spawner` | none |
| 1654 | `trial_key` | `Item` | none |
| 1655 | `ominous_trial_key` | `Item` | none |
| 1656 | `vault` | `BlockItem` of block `vault` | none |

1. The two keys carry no component of their own: whether a stack opens a vault is decided by the vault block entity's configuration (the key item it accepts), not by the item. That logic, and the trial spawner's use of the ominous bottle (the string `ominous_bottle` appears in the trial spawner state data class), are block entity engines outside the item registry (Open question 7).
2. `echo_shard` has only the uncommon rarity; its uses (recipes, the recovery compass) are recipe data.

## 11. Whole-registry check

### 11.1 Fields, classes, ids

1. `Items.<clinit>` has 1253 `putstatic` instructions of type `Item` or of a collection type, in field order 0 to 1252, each field name distinct. 1218 fields register one item each; 20 `ColorCollection` fields register 16 items each (320); 15 `WeatheringCopperCollection` fields register 8 items each (120). 1218 + 320 + 120 = 1658. Applying the id rule of section 1 gives the ids 0 to 1657 with no gap and no duplicate (checked by listing every id once).
2. The item count equals the number of item definition files `assets/minecraft/items/*.json` in the jar (1658, counted with `unzip -Z1 ... | grep -v '/$'`), and equals the number of derived keys that are distinct (1658, checked in 11.3).
3. Classes by registration call of each of the 1253 fields (the call that registers the item, read from the instruction before the `putstatic`):

| Class | Fields | Items |
|---|---|---|
| `registerBlock` (single block item, direct call) | 749 | 749 |
| collection whose items are block items (`registerBlockItems` or `registerItems` over block collections: 15 weathering plus 16 colour: wool, wool stairs, wool slab, dyed terracotta, carpet, stained glass, stained glass pane, dyed shulker box, glazed terracotta, concrete, concrete stairs, concrete slab, concrete powder, bed, banner, dyed candle) | 31 | 15 x 8 + 16 x 16 = 376 |
| `registerItem` (plain or special item, direct call) | 381 | 381 |
| collection whose items are not block items (`harness`, `dyed_bundle`, `cushion`, `dye`) | 4 | 64 |
| `registerSpawnEgg` | 88 | 88 |
| Total | 1253 | 1658 |

So by field the block-item family is 749 + 31 = **780**, the other-item family 381 + 4 = **385**, spawn eggs **88**; 780 + 385 + 88 = 1253. Of the 749 direct `registerBlock` fields, exactly 7 use `GameMasterBlockItem` (a `BlockItem` subclass) as the factory: `command_block`, `repeating_command_block`, `chain_command_block`, `structure_block`, `jigsaw`, `test_block`, `test_instance_block`. Read: `Items` has one bootstrap method (index 137) whose handle is the `GameMasterBlockItem` constructor, and exactly 7 `invokedynamic` sites in `Items.<clinit>` use it, each followed by the `putstatic` of one of those 7 fields.
4. In this document's range (fields 1150 to 1252): 46 direct `registerBlock` fields, 6 block collections (5 weathering, 1 colour), 51 `registerItem` fields, no spawn egg; 46 + 6 + 51 = 103.
5. The 35 collection fields:

| Field | `Items` constant | Kind | First id | Items | Last id |
|---|---|---|---|---|---|
| 120 | `COPPER_BLOCK` | weathering | 120 | 8 | 127 |
| 124 | `CHISELED_COPPER` | weathering | 131 | 8 | 138 |
| 125 | `CUT_COPPER` | weathering | 139 | 8 | 146 |
| 126 | `CUT_COPPER_STAIRS` | weathering | 147 | 8 | 154 |
| 127 | `CUT_COPPER_SLAB` | weathering | 155 | 8 | 162 |
| 215 | `WOOL` | colour | 250 | 16 | 265 |
| 216 | `WOOL_STAIRS` | colour | 266 | 16 | 281 |
| 217 | `WOOL_SLAB` | colour | 282 | 16 | 297 |
| 385 | `COPPER_BARS` | weathering | 465 | 8 | 472 |
| 387 | `COPPER_CHAIN` | weathering | 474 | 8 | 481 |
| 467 | `DYED_TERRACOTTA` | colour | 561 | 16 | 576 |
| 471 | `CARPET` | colour | 580 | 16 | 595 |
| 481 | `STAINED_GLASS` | colour | 605 | 16 | 620 |
| 482 | `STAINED_GLASS_PANE` | colour | 621 | 16 | 636 |
| 503 | `DYED_SHULKER_BOX` | colour | 657 | 16 | 672 |
| 504 | `GLAZED_TERRACOTTA` | colour | 673 | 16 | 688 |
| 505 | `CONCRETE` | colour | 689 | 16 | 704 |
| 506 | `CONCRETE_STAIRS` | colour | 705 | 16 | 720 |
| 507 | `CONCRETE_SLAB` | colour | 721 | 16 | 736 |
| 508 | `CONCRETE_POWDER` | colour | 737 | 16 | 752 |
| 596 | `LIGHTNING_ROD` | weathering | 840 | 8 | 847 |
| 651 | `COPPER_DOOR` | weathering | 902 | 8 | 909 |
| 666 | `COPPER_TRAPDOOR` | weathering | 924 | 8 | 931 |
| 685 | `HARNESS` | colour | 950 | 16 | 965 |
| 874 | `DYED_BUNDLE` | colour | 1154 | 16 | 1169 |
| 875 | `CUSHION` | colour | 1170 | 16 | 1185 |
| 889 | `DYE` | colour | 1199 | 16 | 1214 |
| 894 | `BED` | colour | 1219 | 16 | 1234 |
| 1077 | `BANNER` | colour | 1417 | 16 | 1432 |
| 1162 | `COPPER_LANTERN` | weathering | 1517 | 8 | 1524 |
| 1189 | `DYED_CANDLE` | colour | 1551 | 16 | 1566 |
| 1244 | `COPPER_GRATE` | weathering | 1621 | 8 | 1628 |
| 1245 | `COPPER_BULB` | weathering | 1629 | 8 | 1636 |
| 1246 | `COPPER_CHEST` | weathering | 1637 | 8 | 1644 |
| 1247 | `COPPER_GOLEM_STATUE` | weathering | 1645 | 8 | 1652 |

Sum of the Items column over the fields of this table: 15 x 8 + 20 x 16 = 440; the single-item fields are the other 1218.

### 11.2 Duplicate and gap check for ids 0 to 1252 (field numbers)

Field numbers 0 to 1252 are consecutive by construction (one `putstatic` per field, in order); the item or items behind every field are registered exactly once (1253 registration calls, one per field; the only repetition is inside the 35 collection fields, which register 16 or 8 items in a fixed order). Consequently: **no field number is skipped and none repeats**, and the registry ids, which are the running totals of section 1 item 2, cover 0 to 1657 with every value once. Field 120 `COPPER_BLOCK` still has id 120 (offset 0); its 8 items raise the offset to 7, so the first field whose id differs from its field number is field 121 (id 128, id offset 7). Field n has id n for n up to 120, and the id offset grows by 7 at each weathering collection and 15 at each colour collection; at field 1150 the offset is 355, at field 1252 it is 405 (1657 - 1252).

### 11.3 Keys

Keys were derived for all 1658 items (single-item field: the item key; colour collection: `<color>_<base>`; weathering collection: prefix rule of 1.3) and compared with the file names under `assets/minecraft/items/`:

1. Every key of fields 1150 to 1252 is in the file list (153 of 153).
2. Over the whole registry, 1658 keys are distinct. Exceptions, both outside this range: (a) the `copper_block` collection is irregular: the file list has `copper_block` and `waxed_copper_block` for the two unaffected entries and `exposed_copper`, `weathered_copper`, `oxidized_copper` and their `waxed_` forms for the others, whereas the single-base rule gives `copper` and `waxed_copper`; (b) the `dyed_bundle` collection's keys are `<color>_bundle` (file list), not `<color>_dyed_bundle`. Part 7 owns those rows; this document only records that the id rule is unaffected.

## 12. Worked examples

1. **Field to id.** `ECHO_SHARD` is field 1200. The collection fields before it contribute 405 - 4 x 7 = 377 extra ids (all 405 extra ids of the registry minus the 28 of the four weathering collections at fields 1244 to 1247 that come later), so its id is 1200 + 377 = 1577. Check with 11.2: field 1150 has offset 355, and `COPPER_LANTERN` (8 items, +7) and `DYED_CANDLE` (16 items, +15) lie between 1150 and 1200: 355 + 7 + 15 = 377.
2. **Last items.** Field 1247 `COPPER_GOLEM_STATUE` starts at id 1645 and ends at 1652; field 1248 `TRIAL_SPAWNER` is id 1653, `TRIAL_KEY` 1654, `OMINOUS_TRIAL_KEY` 1655, `VAULT` 1656, `OMINOUS_BOTTLE` 1657.
3. **Drinking honey at full food.** Player food 20, saturation 5.0, three honey bottles in the main hand. Use: `canConsume` is true (always edible). 40 ticks later `onConsume`: `FoodData.eat(6, 1.2)`: food = clamp(26, 0, 20) = 20, saturation = clamp(6.2, 0, 20) = 6.2. Poison is removed if present. Stack count 3 becomes 2; 2 is below the earlier count 3, so a glass bottle is created; the stack is not empty, so `Inventory.add(glass_bottle)` is tried and, if full, the bottle is dropped at the player. Game event `drink`.
4. **Last honey bottle.** One bottle: after `consume` the stack is empty, so the glass bottle becomes the held item (no inventory add).
5. **Creative.** The same drink with infinite materials: `consume` does nothing, `convertIntoRemainder` returns the stack unchanged: the bottle stays, no glass bottle appears.
6. **Ominous bottle, amplifier 3.** After 32 ticks: `bad_omen` for 120000 ticks at amplifier 3, not ambient, not visible, with icon; `item.ominous_bottle.dispose` plays at the player's block position; the bottle is consumed and nothing returned. Food bar unchanged.
7. **Brushing a block to completion.** A player holds a brush on suspicious sand and the ray stays on the block. Events at elapsed ticks 5, 15, 25, ..., 95: nine brushes raise `brushCount` to 9 at tick 85 (dusted: 1 after the first, 2 after the third, 3 after the sixth); the tenth, at tick 95, completes (`brushCount` reaches 10), drops the item and turns the block into its `turnsInto` block, and the brush loses 1 durability. If the player looks away at tick 40, `releaseUsingItem` is called at the next tick, and the block's own scheduled ticks (re-run every 2 ticks while `brushCount` is above 0) decay `brushCount` by 2 every 4 ticks once 40 ticks have passed without a brush.
8. **Waxing.** Right-click an exposed copper chest with a honeycomb: the block becomes `waxed_exposed_copper_chest` with the old `facing`, `type` and waterlogged values copied; honeycomb count 1 less (unless creative); one particle event and one sound (two of each when the chest is half of a double chest).
9. **Wooden fuel.** A barrel item in an ordinary furnace: burn 300 ticks. In a smoker: 300 / 2 = 150 ticks, and the cooking speed multiplier is 2.0.
10. **Composter.** First sweet berries into an empty composter (`level` 0): `compostable/low` returns 1 (the case for level 0), level 1. With `level` 3, each berries has a 30 percent chance of adding 1 layer. Level 6 plus a layer gives 7 and schedules a tick in 20 ticks.
11. **Sherd.** `skull_pottery_sherd` (id 1619, uncommon) carries `provides_pottery_pattern` = `minecraft:skull`, whose asset id is `minecraft:skull_pottery_pattern`.

## 13. Validation

| # | Check | Result |
|---|---|---|
| V1 | Number of `Item`-typed or collection-typed `putstatic` in `Items.<clinit>` | 1253 |
| V2 | Items expanded from collections | 20 colour x 16 + 15 weathering x 8 = 440 items from 35 fields; 1218 single-item fields; total 1658 |
| V3 | Ids contiguous, unique | 0 to 1657, 1658 distinct values |
| V4 | Item definition files in the jar | 1658 `assets/minecraft/items/*.json` (file count, directories excluded) |
| V5 | Keys of this range present in the item definition files | 153 of 153 |
| V6 | Field numbers of landmark items | `COMPOSTER` 1150, `HONEY_BOTTLE` 1171, `ECHO_SHARD` 1200, `NETHERITE_UPGRADE_SMITHING_TEMPLATE` 1202, `BOLT_ARMOR_TRIM_SMITHING_TEMPLATE` 1220, `ANGLER_POTTERY_SHERD` 1221, `TRIAL_SPAWNER` 1248, `OMINOUS_TRIAL_KEY` 1250, `VAULT` 1251, `OMINOUS_BOTTLE` 1252 |
| V7 | Pottery sherd count and pattern files | 23 sherd fields, 23 files under `data/minecraft/decorated_pot_pattern/` |
| V8 | Template count | 1 netherite upgrade + 18 trims = 19 (fields 1202 to 1220) |
| V9 | Spawn egg registrations | 88 `registerSpawnEgg` calls |
| V10 | Block-item classes | 780 + 385 + 88 = 1253 fields (section 11.1; 7 of the 780 use `GameMasterBlockItem`) |
| V11 | Components' ids against 17 §1.2 | `max_stack_size` 1, `max_damage` 2, `damage` 3, `rarity` 12, `enchantments` 13, `attribute_modifiers` 16, `repair_cost` 19, `food` 23, `consumable` 24, `use_remainder` 25 agree; total 122 types |
| V12 | Saturation formula | `FoodConstants.saturationByModifier(n, m)` = `n x m x 2` read; honey 1.2, berries 0.4 |
| V13 | Consume float arithmetic | `1.6f x 20.0f` rounds to 32.0 in single precision (computed by hand: the exact product 32.0000005 is within half a unit in the last place, 1.9e-6, of 32.0), so 32 ticks; 2.0 x 20 = 40 |
| V14 | Fuel arithmetic | 300 / 1 = 300; 300 / 2 = 150 (data) |

## 14. Open questions

1. **Field numbers versus ids.** 1150 to 1252 are field numbers (section 1); the registry ids of the range are 1505 to 1657. Downstream documents (46, the packet documents) must use the ids; this follows from the id rule, which matches the contiguous 0 to 1657 and the 1658 item definition files.
2. **Consume listener order.** `Consumable.onConsume` iterates `ItemStack.getAllOfType(ConsumableListener)`; the order across several listener components on one stack (for example `food` and a potion component) was not traced. No item of this range has two.
3. **Furnace fuel evaluation context.** `AbstractFurnaceBlockEntity` resolves `cooking_fuel` through `ResolvableInt.getFromItem` and `ResolvableFloat.getFromItem`; the loot context parameters it builds (which block state or position feed the `fast_cooking` predicate) and the rounding of the integer division for factors other than 1 and 2 were not read.
4. **Composter random draws.** `compostable/*` use weighted lists evaluated with a loot context; the generator and the draw order inside the evaluation (which random source of the context, the number of draws) were not traced.
5. **Berries on a block.** Whether a right click on a block that refuses the berries' placement then reaches `Item.use` (eating) was not traced beyond 29 §9.5 to §9.7; `BlockItem` has no `use` override.
6. **Decorated pot engine.** The decorated pot block entity's server logic, the break drops of a pot with sherds and the sherd recipes were not read.
7. **Vault and trial spawner.** How a vault accepts `trial_key` and `ominous_trial_key`, how a trial spawner uses `ominous_bottle`, and the trial spawner states were not read; they are block entity engines.
8. **Brush details not read.** The volume, pitch and own-client exclusion of the four-argument `Level.playSound(entity, pos, sound, source)` overload used in the brush tick (the overload itself is read); the dust delta table `DustParticlesDelta.fromDirection`; the `getBrushSound` of each brushable block; whether the `nextInt(7, 12)` bound is exclusive.
9. **Wax-on second chest half.** Only the clicked half is rewritten by `HoneycombItem`; how the other half of a double copper chest becomes waxed (block `updateShape` or block entity) was not read.
10. **Feature flags.** `registerBlock` calls `properties.requiredFeatures(block.requiredFeatures())`; which of the 103 rows have non-vanilla required features (the flags `trade_rebalance`, `redstone_experiments`, `minecart_improvements` exist) was not read. The block registry parts (24-1 to 24-8) carry the per-block flags.
11. **Keys outside the range.** The base keys of the `copper_block` and `dyed_bundle` collections (11.3) are owned by the parts that cover them.
12. **Hover texts and creative tab order.** The English texts of the template, sherd and key names, and `CreativeModeTabs` ordering, are data (22) and were not read.
13. **`OverrideConsumeSound` and `use_cooldown`.** Items implementing `Consumable$OverrideConsumeSound` (not in this range) and the `UseCooldown.apply` rule were not read here.
14. **Recalled knowledge.** Nothing in this document was taken from recall; where the text says `(inferred)` the value is deduced from code that was read, and it is listed above.
15. **Either branch flag.** The boolean values of the `ResolvableInt`/`ResolvableFloat` stream form (true = constant, false = reference) were taken from the two encode lambdas of the either codec in registration order (the left lambda writes 1, the right writes 0, and the left codec is the constant); the pairing of lambda to branch was not confirmed by a separate trace. The exact string form of the `Identifier` stream codec is in 04.
