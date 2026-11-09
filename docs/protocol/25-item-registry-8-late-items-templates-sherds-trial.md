# Item registry, part 8: composter to ominous bottle (`Items` fields 1150 to 1252, registry ids 1505 to 1657), smithing templates, pottery sherds, trial items, and the whole-registry check

| Item | Value |
|---|---|
| Covers | Rows for the last 103 fields of the `Items` static initialiser, `COMPOSTER` (field 1150) through `OMINOUS_BOTTLE` (field 1252): the late block items (workstations, lanterns, campfires, bee blocks, the blackstone family, candles, amethyst, froglights, copper variants), the consumables `HONEY_BOTTLE` and `OMINOUS_BOTTLE`, `ECHO_SHARD`, `BRUSH`, the 19 smithing templates, the 23 pottery sherds, the trial items. Also the engines that interpret what these items carry: the consume pipeline (food, consumable, use remainder, consume listeners), `HoneycombItem`, `BrushItem` and the brushable block entity, `PlaceOnWaterBlockItem`, `SmithingTemplateItem`, the `compostable` and `cooking_fuel` components, the common prototype components. It closes with the whole-registry check (classes, ids 0 to 1657, gaps, duplicates). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for the bootstrap method arguments of lambdas) and of data files inside the jar (`data/minecraft/context_int_provider`, `context_float_provider`, `predicate/block`, `decorated_pot_pattern`, and the file names under `assets/minecraft/items/`, used only to cross-check keys and counts). No execution. |
| Status | Round RS5, part 8 of 8 (design map Part 5, GAP-2). Siblings: parts 1 to 7 and x1; part 7 covers fields 1105 to 1149 (ids 1460 to 1504). Section 11.4 to 11.6 hold the whole-registry reconciliation, family counts and the full ordered key list. |
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
3. **Closed.** The furnace fuel context and `fast_cooking` condition are specified in 31-2 (see 4.4 item 2).
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
3. `bees` component (`bee_nest`, `beehive`): empty in the prototype; the beehive block entity's use of this component (occupants, `flower_pos`, release) is specified in 31-4 §8, not here.
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
   Encoding (read): `cooking_fuel` is both persistent and network-synchronised (component type registration 85). Stream form: the burn-time provider, then the speed provider, nothing else. Each provider (`ResolvableInt`, `ResolvableFloat`) is an either: one boolean byte, then if true (a constant) a 4-byte big-endian int (or 4-byte float), if false (a reference) an identifier string naming an entry of `context_int_provider` (or `context_float_provider`). Note that the registered key `cooking/time_wood_blocks` is therefore sent as the reference form: boolean false and the identifier `minecraft:cooking/time_wood_blocks` (the Identifier stream codec of 04). Data form: field names `burn_time` and `speed_multiplier`; each an int/float or a key string. (Read: `ByteBufCodecs.either` writes boolean true then the left codec for a `Left` value and false then the right codec for a `Right`; `ResolvableInt.STREAM_CODEC` is `either(Constant.STREAM_CODEC, Reference.STREAM_CODEC)`, `Constant` uses the 4-byte `INT` codec (`ResolvableFloat.Constant` uses `FLOAT`), so true is a constant and false is a reference key. The receiving client needs the `context_*_provider` data registries only to evaluate, not to decode.)
2. The furnace engine (`AbstractFurnaceBlockEntity.getBurnDuration` and a speed multiplier accessor) calls these with a context built for the furnace block and the default 0 (burn) or the default speed given in code; the context, the burn duration and the `fast_cooking` condition are specified in 31-2 (the `getBurnDuration` and fast-cooking rules); not repeated here.
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
| honey bottle consumable (`Consumables.HONEY_BOTTLE`) | default drink with 2.0 s, sound `item.honey_bottle.drink`, one on-consume effect `remove_effects` of the single effect `poison` (46 §4.1: poison is mob effect id 18) |
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
   5. Game event `drink` if the animation is `drink`, else `eat` (46 §5.2: drink 12, eat 13).
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
| `OminousBottleAmplifier.onConsume` | `entity.addEffect(effect bad_omen, duration 120000 ticks, amplifier = value, ambient false, visible false, show icon true)` (46 §4.1: bad_omen is mob effect id 30). Constants: `EFFECT_DURATION` 120000, `MIN_AMPLIFIER` 0, `MAX_AMPLIFIER` 4. The tooltip lists that effect through `PotionContents.addPotionTooltip` with scale 1.0 and the tick rate. |
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

Count `nextInt(7, 12)` per event (origin 7, bound 12; read: `RandomSource.nextInt(origin, bound)` returns origin plus `nextInt(bound - origin)`, so the upper bound is exclusive and the count is 7 to 11 inclusive, as 31-4 and 42-7 state). Each particle is a block particle of the state at the hit location (x is shifted by 1.0e-6 toward lower coordinates when the hit face is west, z likewise for north), with velocity `(dx x side x 3.0 x r1, 0, dz x side x 3.0 x r2)`, `side` = +1 for the right arm and -1 for the left, `r1`, `r2` uniform doubles in [0,1) and `(dx, dz)` = `DustParticlesDelta.fromDirection(view vector, face)` (its table is in 42-7 §6.50: DOWN and UP give (view.z, 0, -view.x), NORTH (1, 0, -0.1), SOUTH (-1, 0, 0.1), WEST (-0.1, 0, -1), EAST (0.1, 0, 1)).

### 7.2 `BrushableBlockEntity`

The server state of suspicious sand and gravel (fields, `brush()`, `checkReset`, `unpackLootTable`, `brushingCompleted`, `dropContent`, the completion state to `dusted` mapping, constants 10, 40 and 10) is specified in 31-4 §7 and 17 §3.5; this document does not repeat it. This part keeps only the item side above.

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

1. The `provides_pottery_pattern` component (id 117) is a registry holder of the data-driven registry `decorated_pot_pattern` (23 entries in the jar, one per sherd, files `data/minecraft/decorated_pot_pattern/<name>.json`, each `{"asset_id": "minecraft:<name>_pottery_pattern"}`). On the wire it is the holder encoding of 04 'Composite types introduced here' (id into the synchronized registry, in the order the server sends its entries); read: the stream codec is the registry-holder codec of the `decorated_pot_pattern` registry (`holderRegistry`, a registry-friendly buffer), and the component is network-synchronised (component 117); the data form is the pattern key identifier. The pattern of a sherd resolves after the data registries are loaded (`delayedComponent`), so the item prototype exists only after registry load (23).
2. `DecoratedPotPatterns.bootstrap` registers the 23 patterns in the order `angler, archer, arms_up, blade, brewer, burn, danger, explorer, flow, friend, guster, heart, heartbreak, howl, miner, mourner, plenty, prize, scrape, sheaf, shelter, skull, snort`; the asset id is the key's identifier with the suffix `_pottery_pattern`.
3. A decorated pot block entity stores its four sides (`back`, `left`, `right`, `front`) as optional item stack templates (`PotDecorations`); a pot with nothing is `EMPTY`, and the all-brick pot (`allBrick`) uses the item `brick` for each side. The client renderer reads the pattern of each stored item through `provides_pottery_pattern` to pick the texture. The pot's server logic (breaking a pot returns the sherds, the block entity fields) is in 31-3; the sherd crafting recipes are recipe data (27) and are not repeated here.

## 10. Trial items, echo shard

| Id | Item | Class | Components beyond the common set |
|---|---|---|---|
| 1577 | `echo_shard` | `Item` | `rarity` uncommon |
| 1653 | `trial_spawner` | `BlockItem` of block `trial_spawner` | none |
| 1654 | `trial_key` | `Item` | none |
| 1655 | `ominous_trial_key` | `Item` | none |
| 1656 | `vault` | `BlockItem` of block `vault` | none |

1. The two keys carry no component of their own: whether a stack opens a vault is decided by the vault block entity's configuration (the key item it accepts), not by the item. The vault key rules (`trial_key` accepted, `ominous_trial_key` rejected) are in 31-7 §7.9, and the trial spawner's use of the ominous bottle is in 31-7.
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

### 11.4 Range boundaries of parts 1 to 8, by key

The sibling parts label their ranges in different units: parts 1 and 2 and the continuation x1 by registry id, part 3 by statement with the ids added, parts 4 to 6 by statement, part 7 by the numbers 1105 to 1149 (which are field numbers, not ids: `music_disc_13` is id 1460), this part by field. The table below fixes both numbers for every boundary. A "field" is the declaration order of 25-1 section 1 (the 0-based `putstatic` order of `Items.<clinit>`). The contiguous partition was checked by walking the 1253 fields and comparing each part's last id plus one with the next part's first id (every row below starts one id after the previous row ends).

| Part | Document | Fields | Ids | First key | Last key | Fields | Items |
|---|---|---|---|---|---|---|---|
| 1 | 25-1 | 0 to 192 | 0 to 227 | `air` | `azalea_leaves` | 193 | 228 |
| 2 | 25-2 | 193 to 375 | 228 to 455 | `flowering_azalea_leaves` | `deepslate_bricks` | 183 | 228 |
| x1 | 25-x1 | 376 to 455 | 456 to 549 | `cracked_deepslate_bricks` | `cobbled_deepslate_wall` | 80 | 94 |
| 3 | 25-3 | 456 to 694 | 550 to 974 | `polished_deepslate_wall` | `elytra` | 239 | 425 |
| 4 | 25-4 | 695 to 847 | 975 to 1127 | `oak_boat` | `warped_hanging_sign` | 153 | 153 |
| 5 | 25-5 | 848 to 939 | 1128 to 1279 | `bucket` | `glistering_melon_slice` | 92 | 152 |
| 6 | 25-6 | 940 to 1104 | 1280 to 1459 | `chicken_spawn_egg` | `debug_stick` | 165 | 180 |
| 7 | 25-7 | 1105 to 1149 | 1460 to 1504 | `music_disc_13` | `goat_horn` | 45 | 45 |
| 8 | 25-8 (this) | 1150 to 1252 | 1505 to 1657 | `composter` | `ominous_bottle` | 103 | 153 |

Notes on the boundaries:

1. Every boundary falls between two single-item fields, so no collection straddles a part: the first and last field of each part is a single-item field (part 1 `air`/`azalea_leaves`, part 2 `flowering_azalea_leaves`/`deepslate_bricks`, x1 `cracked_deepslate_bricks`/`cobbled_deepslate_wall`, part 3 `polished_deepslate_wall`/`elytra`, part 4 `oak_boat`/`warped_hanging_sign`, part 5 `bucket`/`glistering_melon_slice`, part 6 `chicken_spawn_egg`/`debug_stick`, part 7 `music_disc_13`/`goat_horn`, part 8 `composter`/`ominous_bottle`).
2. Ranges sum to the whole registry: 228 + 228 + 94 + 425 + 153 + 152 + 180 + 45 + 153 = 1658. The field counts sum to 193 + 183 + 80 + 239 + 153 + 92 + 165 + 45 + 103 = 1253.
3. Label reconciliation: the part 3 title "statements 456 to 694, ids 550 to 974" and the x1 title "ids 456 to 549, statements 376 to 455" agree with the table. Part 7's `ids 1105 to 1149` are fields 1105 to 1149 and the ids are 1460 to 1504 (Open question 16). Parts 5 and 6 head their ranges by field (848 to 939, 940 to 1104); their ids are 1128 to 1279 and 1280 to 1459.

### 11.5 Count per part and per family

Families are defined by the registering call, as in 11.1: block family (registered by `registerBlock` or by a block collection), other family (`registerItem` and the four non-block collections; `air` and `resin_clump` are in it, and so are `sweet_berries` and `glow_berries`, which are `BlockItem` instances registered through `registerItem`), spawn egg (`registerSpawnEgg`). A collection field counts every item it registers.

| Part | Items | Block family | Other family | Spawn eggs | Collection fields | Items from collections |
|---|---|---|---|---|---|---|
| 1 | 228 | 227 | 1 | 0 | 5 | 40 |
| 2 | 228 | 228 | 0 | 0 | 3 | 48 |
| x1 | 94 | 93 | 1 | 0 | 2 | 16 |
| 3 | 425 | 398 | 27 | 0 | 14 | 200 |
| 4 | 153 | 30 | 123 | 0 | 0 | 0 |
| 5 | 152 | 22 | 130 | 0 | 4 | 64 |
| 6 | 180 | 24 | 68 | 88 | 1 | 16 |
| 7 | 45 | 1 | 44 | 0 | 0 | 0 |
| 8 | 153 | 102 | 51 | 0 | 6 | 56 |
| **Total** | **1658** | **1125** | **445** | **88** | **35** | **440** |

By family over the registry: 1125 block-family items (749 single-item fields plus 376 items from the 31 block collections), 445 other items (381 single-item fields plus 64 items from the 4 colour collections `harness`, `dyed_bundle`, `cushion`, `dye`), 88 spawn eggs: 1125 + 445 + 88 = 1658. Items from collections: 15 x 8 + 20 x 16 = 440, of which 376 + 64 = 440 (all 31 block collections and the 4 other ones: 376 block items = 15 x 8 + 16 x 16 = 120 + 256; 64 = 4 x 16).

Part 8 itself: 153 items = 102 "block" family (46 single block fields, 5 weathering collections = 40 items, 1 colour collection = 16 items) + 51 other (`honeycomb`, `honey_bottle`, `echo_shard`, `brush`, 19 templates, 23 sherds, `trial_key`, `ominous_trial_key`, `ominous_bottle` = 49, plus `sweet_berries` and `glow_berries`) + 0 spawn eggs. 102 + 51 = 153.

### 11.6 Verification appendix: all 1658 keys in registry order

Each entry is `id key` (the key is the path of `minecraft:<key>`). The list was produced by the id rule of section 1 over the 1253 fields (item key from `ItemIds`/`BlockItemIds` constants, collections expanded by 1.3) and compared as a set with the 1658 file names under `assets/minecraft/items/`: equal sets, no duplicate. Implementers: this is the table to compare a generated registry against.

```text
0 air  1 stone  2 granite  3 polished_granite  4 diorite  5 polished_diorite
6 andesite  7 polished_andesite  8 deepslate  9 cobbled_deepslate  10 polished_deepslate  11 calcite
12 tuff  13 tuff_slab  14 tuff_stairs  15 tuff_wall  16 chiseled_tuff  17 polished_tuff
18 polished_tuff_slab  19 polished_tuff_stairs  20 polished_tuff_wall  21 tuff_bricks  22 tuff_brick_slab  23 tuff_brick_stairs
24 tuff_brick_wall  25 chiseled_tuff_bricks  26 sulfur  27 potent_sulfur  28 sulfur_slab  29 sulfur_stairs
30 sulfur_wall  31 polished_sulfur  32 polished_sulfur_slab  33 polished_sulfur_stairs  34 polished_sulfur_wall  35 sulfur_bricks
36 sulfur_brick_slab  37 sulfur_brick_stairs  38 sulfur_brick_wall  39 chiseled_sulfur  40 cinnabar  41 cinnabar_slab
42 cinnabar_stairs  43 cinnabar_wall  44 polished_cinnabar  45 polished_cinnabar_slab  46 polished_cinnabar_stairs  47 polished_cinnabar_wall
48 cinnabar_bricks  49 cinnabar_brick_slab  50 cinnabar_brick_stairs  51 cinnabar_brick_wall  52 chiseled_cinnabar  53 dripstone_block
54 grass_block  55 dirt  56 coarse_dirt  57 podzol  58 rooted_dirt  59 mud
60 crimson_nylium  61 warped_nylium  62 cobblestone  63 oak_planks  64 spruce_planks  65 birch_planks
66 jungle_planks  67 acacia_planks  68 cherry_planks  69 dark_oak_planks  70 pale_oak_planks  71 mangrove_planks
72 poplar_planks  73 bamboo_planks  74 crimson_planks  75 warped_planks  76 bamboo_mosaic  77 oak_sapling
78 spruce_sapling  79 birch_sapling  80 jungle_sapling  81 acacia_sapling  82 cherry_sapling  83 dark_oak_sapling
84 pale_oak_sapling  85 mangrove_propagule  86 poplar_sapling  87 bedrock  88 sand  89 suspicious_sand
90 suspicious_gravel  91 red_sand  92 gravel  93 coal_ore  94 deepslate_coal_ore  95 iron_ore
96 deepslate_iron_ore  97 copper_ore  98 deepslate_copper_ore  99 gold_ore  100 deepslate_gold_ore  101 redstone_ore
102 deepslate_redstone_ore  103 emerald_ore  104 deepslate_emerald_ore  105 lapis_ore  106 deepslate_lapis_ore  107 diamond_ore
108 deepslate_diamond_ore  109 nether_gold_ore  110 nether_quartz_ore  111 ancient_debris  112 coal_block  113 raw_iron_block
114 raw_copper_block  115 raw_gold_block  116 heavy_core  117 amethyst_block  118 budding_amethyst  119 iron_block
120 copper_block  121 exposed_copper  122 weathered_copper  123 oxidized_copper  124 waxed_copper_block  125 waxed_exposed_copper
126 waxed_weathered_copper  127 waxed_oxidized_copper  128 gold_block  129 diamond_block  130 netherite_block  131 chiseled_copper
132 exposed_chiseled_copper  133 weathered_chiseled_copper  134 oxidized_chiseled_copper  135 waxed_chiseled_copper  136 waxed_exposed_chiseled_copper  137 waxed_weathered_chiseled_copper
138 waxed_oxidized_chiseled_copper  139 cut_copper  140 exposed_cut_copper  141 weathered_cut_copper  142 oxidized_cut_copper  143 waxed_cut_copper
144 waxed_exposed_cut_copper  145 waxed_weathered_cut_copper  146 waxed_oxidized_cut_copper  147 cut_copper_stairs  148 exposed_cut_copper_stairs  149 weathered_cut_copper_stairs
150 oxidized_cut_copper_stairs  151 waxed_cut_copper_stairs  152 waxed_exposed_cut_copper_stairs  153 waxed_weathered_cut_copper_stairs  154 waxed_oxidized_cut_copper_stairs  155 cut_copper_slab
156 exposed_cut_copper_slab  157 weathered_cut_copper_slab  158 oxidized_cut_copper_slab  159 waxed_cut_copper_slab  160 waxed_exposed_cut_copper_slab  161 waxed_weathered_cut_copper_slab
162 waxed_oxidized_cut_copper_slab  163 oak_log  164 spruce_log  165 birch_log  166 jungle_log  167 acacia_log
168 cherry_log  169 pale_oak_log  170 dark_oak_log  171 mangrove_log  172 poplar_log  173 mangrove_roots
174 muddy_mangrove_roots  175 crimson_stem  176 warped_stem  177 bamboo_block  178 stripped_oak_log  179 stripped_spruce_log
180 stripped_birch_log  181 stripped_jungle_log  182 stripped_acacia_log  183 stripped_cherry_log  184 stripped_dark_oak_log  185 stripped_pale_oak_log
186 stripped_mangrove_log  187 stripped_poplar_log  188 stripped_crimson_stem  189 stripped_warped_stem  190 stripped_oak_wood  191 stripped_spruce_wood
192 stripped_birch_wood  193 stripped_jungle_wood  194 stripped_acacia_wood  195 stripped_cherry_wood  196 stripped_dark_oak_wood  197 stripped_pale_oak_wood
198 stripped_mangrove_wood  199 stripped_poplar_wood  200 stripped_crimson_hyphae  201 stripped_warped_hyphae  202 stripped_bamboo_block  203 oak_wood
204 spruce_wood  205 birch_wood  206 jungle_wood  207 acacia_wood  208 cherry_wood  209 pale_oak_wood
210 dark_oak_wood  211 mangrove_wood  212 poplar_wood  213 crimson_hyphae  214 warped_hyphae  215 oak_leaves
216 spruce_leaves  217 birch_leaves  218 jungle_leaves  219 acacia_leaves  220 cherry_leaves  221 dark_oak_leaves
222 pale_oak_leaves  223 mangrove_leaves  224 red_poplar_leaves  225 orange_poplar_leaves  226 yellow_poplar_leaves  227 azalea_leaves
228 flowering_azalea_leaves  229 sponge  230 wet_sponge  231 glass  232 tinted_glass  233 lapis_block
234 sandstone  235 chiseled_sandstone  236 cut_sandstone  237 cobweb  238 short_grass  239 fern
240 bush  241 red_shrub  242 azalea  243 flowering_azalea  244 dead_bush  245 firefly_bush
246 short_dry_grass  247 tall_dry_grass  248 seagrass  249 sea_pickle  250 white_wool  251 orange_wool
252 magenta_wool  253 light_blue_wool  254 yellow_wool  255 lime_wool  256 pink_wool  257 gray_wool
258 light_gray_wool  259 cyan_wool  260 purple_wool  261 blue_wool  262 brown_wool  263 green_wool
264 red_wool  265 black_wool  266 white_wool_stairs  267 orange_wool_stairs  268 magenta_wool_stairs  269 light_blue_wool_stairs
270 yellow_wool_stairs  271 lime_wool_stairs  272 pink_wool_stairs  273 gray_wool_stairs  274 light_gray_wool_stairs  275 cyan_wool_stairs
276 purple_wool_stairs  277 blue_wool_stairs  278 brown_wool_stairs  279 green_wool_stairs  280 red_wool_stairs  281 black_wool_stairs
282 white_wool_slab  283 orange_wool_slab  284 magenta_wool_slab  285 light_blue_wool_slab  286 yellow_wool_slab  287 lime_wool_slab
288 pink_wool_slab  289 gray_wool_slab  290 light_gray_wool_slab  291 cyan_wool_slab  292 purple_wool_slab  293 blue_wool_slab
294 brown_wool_slab  295 green_wool_slab  296 red_wool_slab  297 black_wool_slab  298 dandelion  299 golden_dandelion
300 open_eyeblossom  301 closed_eyeblossom  302 poppy  303 blue_orchid  304 allium  305 azure_bluet
306 red_tulip  307 orange_tulip  308 white_tulip  309 pink_tulip  310 oxeye_daisy  311 cornflower
312 lily_of_the_valley  313 wither_rose  314 torchflower  315 pitcher_plant  316 spore_blossom  317 brown_mushroom
318 red_mushroom  319 shelf_mushroom  320 crimson_fungus  321 warped_fungus  322 crimson_roots  323 warped_roots
324 nether_sprouts  325 weeping_vines  326 twisting_vines  327 sugar_cane  328 kelp  329 pink_petals
330 wildflowers  331 leaf_litter  332 moss_carpet  333 moss_block  334 pale_moss_carpet  335 pale_hanging_moss
336 pale_moss_block  337 hanging_roots  338 big_dripleaf  339 small_dripleaf  340 bamboo  341 oak_slab
342 spruce_slab  343 birch_slab  344 jungle_slab  345 acacia_slab  346 cherry_slab  347 dark_oak_slab
348 pale_oak_slab  349 mangrove_slab  350 poplar_slab  351 bamboo_slab  352 bamboo_mosaic_slab  353 crimson_slab
354 warped_slab  355 stone_slab  356 smooth_stone_slab  357 sandstone_slab  358 cut_sandstone_slab  359 petrified_oak_slab
360 cobblestone_slab  361 brick_slab  362 stone_brick_slab  363 mud_brick_slab  364 nether_brick_slab  365 quartz_slab
366 red_sandstone_slab  367 cut_red_sandstone_slab  368 purpur_slab  369 prismarine_slab  370 prismarine_brick_slab  371 dark_prismarine_slab
372 smooth_quartz  373 smooth_red_sandstone  374 smooth_sandstone  375 smooth_stone  376 bricks  377 acacia_shelf
378 bamboo_shelf  379 birch_shelf  380 cherry_shelf  381 crimson_shelf  382 dark_oak_shelf  383 jungle_shelf
384 mangrove_shelf  385 poplar_shelf  386 oak_shelf  387 pale_oak_shelf  388 spruce_shelf  389 warped_shelf
390 bookshelf  391 chiseled_bookshelf  392 decorated_pot  393 mossy_cobblestone  394 obsidian  395 torch
396 end_rod  397 chorus_plant  398 chorus_flower  399 purpur_block  400 purpur_pillar  401 purpur_stairs
402 spawner  403 creaking_heart  404 chest  405 crafting_table  406 farmland  407 furnace
408 ladder  409 cobblestone_stairs  410 snow  411 ice  412 snow_block  413 cactus
414 cactus_flower  415 clay  416 jukebox  417 oak_fence  418 spruce_fence  419 birch_fence
420 jungle_fence  421 acacia_fence  422 cherry_fence  423 dark_oak_fence  424 pale_oak_fence  425 mangrove_fence
426 poplar_fence  427 bamboo_fence  428 crimson_fence  429 warped_fence  430 pumpkin  431 carved_pumpkin
432 jack_o_lantern  433 netherrack  434 soul_sand  435 soul_soil  436 basalt  437 polished_basalt
438 smooth_basalt  439 soul_torch  440 copper_torch  441 glowstone  442 infested_stone  443 infested_cobblestone
444 infested_stone_bricks  445 infested_mossy_stone_bricks  446 infested_cracked_stone_bricks  447 infested_chiseled_stone_bricks  448 infested_deepslate  449 stone_bricks
450 mossy_stone_bricks  451 cracked_stone_bricks  452 chiseled_stone_bricks  453 packed_mud  454 mud_bricks  455 deepslate_bricks
456 cracked_deepslate_bricks  457 deepslate_tiles  458 cracked_deepslate_tiles  459 chiseled_deepslate  460 reinforced_deepslate  461 brown_mushroom_block
462 red_mushroom_block  463 mushroom_stem  464 iron_bars  465 copper_bars  466 exposed_copper_bars  467 weathered_copper_bars
468 oxidized_copper_bars  469 waxed_copper_bars  470 waxed_exposed_copper_bars  471 waxed_weathered_copper_bars  472 waxed_oxidized_copper_bars  473 iron_chain
474 copper_chain  475 exposed_copper_chain  476 weathered_copper_chain  477 oxidized_copper_chain  478 waxed_copper_chain  479 waxed_exposed_copper_chain
480 waxed_weathered_copper_chain  481 waxed_oxidized_copper_chain  482 glass_pane  483 melon  484 vine  485 glow_lichen
486 resin_clump  487 resin_block  488 resin_bricks  489 resin_brick_stairs  490 resin_brick_slab  491 resin_brick_wall
492 chiseled_resin_bricks  493 brick_stairs  494 stone_brick_stairs  495 mud_brick_stairs  496 mycelium  497 lily_pad
498 nether_bricks  499 cracked_nether_bricks  500 chiseled_nether_bricks  501 nether_brick_fence  502 nether_brick_stairs  503 sculk
504 sculk_vein  505 sculk_catalyst  506 sculk_shrieker  507 enchanting_table  508 end_portal_frame  509 end_stone
510 end_stone_bricks  511 dragon_egg  512 sandstone_stairs  513 ender_chest  514 emerald_block  515 oak_stairs
516 spruce_stairs  517 birch_stairs  518 jungle_stairs  519 acacia_stairs  520 cherry_stairs  521 dark_oak_stairs
522 pale_oak_stairs  523 mangrove_stairs  524 poplar_stairs  525 bamboo_stairs  526 bamboo_mosaic_stairs  527 crimson_stairs
528 warped_stairs  529 command_block  530 beacon  531 cobblestone_wall  532 mossy_cobblestone_wall  533 brick_wall
534 prismarine_wall  535 red_sandstone_wall  536 mossy_stone_brick_wall  537 granite_wall  538 stone_brick_wall  539 mud_brick_wall
540 nether_brick_wall  541 andesite_wall  542 red_nether_brick_wall  543 sandstone_wall  544 end_stone_brick_wall  545 diorite_wall
546 blackstone_wall  547 polished_blackstone_wall  548 polished_blackstone_brick_wall  549 cobbled_deepslate_wall  550 polished_deepslate_wall  551 deepslate_brick_wall
552 deepslate_tile_wall  553 anvil  554 chipped_anvil  555 damaged_anvil  556 chiseled_quartz_block  557 quartz_block
558 quartz_bricks  559 quartz_pillar  560 quartz_stairs  561 white_terracotta  562 orange_terracotta  563 magenta_terracotta
564 light_blue_terracotta  565 yellow_terracotta  566 lime_terracotta  567 pink_terracotta  568 gray_terracotta  569 light_gray_terracotta
570 cyan_terracotta  571 purple_terracotta  572 blue_terracotta  573 brown_terracotta  574 green_terracotta  575 red_terracotta
576 black_terracotta  577 barrier  578 light  579 hay_block  580 white_carpet  581 orange_carpet
582 magenta_carpet  583 light_blue_carpet  584 yellow_carpet  585 lime_carpet  586 pink_carpet  587 gray_carpet
588 light_gray_carpet  589 cyan_carpet  590 purple_carpet  591 blue_carpet  592 brown_carpet  593 green_carpet
594 red_carpet  595 black_carpet  596 terracotta  597 packed_ice  598 dirt_path  599 sunflower
600 lilac  601 rose_bush  602 peony  603 tall_grass  604 large_fern  605 white_stained_glass
606 orange_stained_glass  607 magenta_stained_glass  608 light_blue_stained_glass  609 yellow_stained_glass  610 lime_stained_glass  611 pink_stained_glass
612 gray_stained_glass  613 light_gray_stained_glass  614 cyan_stained_glass  615 purple_stained_glass  616 blue_stained_glass  617 brown_stained_glass
618 green_stained_glass  619 red_stained_glass  620 black_stained_glass  621 white_stained_glass_pane  622 orange_stained_glass_pane  623 magenta_stained_glass_pane
624 light_blue_stained_glass_pane  625 yellow_stained_glass_pane  626 lime_stained_glass_pane  627 pink_stained_glass_pane  628 gray_stained_glass_pane  629 light_gray_stained_glass_pane
630 cyan_stained_glass_pane  631 purple_stained_glass_pane  632 blue_stained_glass_pane  633 brown_stained_glass_pane  634 green_stained_glass_pane  635 red_stained_glass_pane
636 black_stained_glass_pane  637 prismarine  638 prismarine_bricks  639 dark_prismarine  640 prismarine_stairs  641 prismarine_brick_stairs
642 dark_prismarine_stairs  643 sea_lantern  644 red_sandstone  645 chiseled_red_sandstone  646 cut_red_sandstone  647 red_sandstone_stairs
648 repeating_command_block  649 chain_command_block  650 magma_block  651 nether_wart_block  652 warped_wart_block  653 red_nether_bricks
654 bone_block  655 structure_void  656 shulker_box  657 white_shulker_box  658 orange_shulker_box  659 magenta_shulker_box
660 light_blue_shulker_box  661 yellow_shulker_box  662 lime_shulker_box  663 pink_shulker_box  664 gray_shulker_box  665 light_gray_shulker_box
666 cyan_shulker_box  667 purple_shulker_box  668 blue_shulker_box  669 brown_shulker_box  670 green_shulker_box  671 red_shulker_box
672 black_shulker_box  673 white_glazed_terracotta  674 orange_glazed_terracotta  675 magenta_glazed_terracotta  676 light_blue_glazed_terracotta  677 yellow_glazed_terracotta
678 lime_glazed_terracotta  679 pink_glazed_terracotta  680 gray_glazed_terracotta  681 light_gray_glazed_terracotta  682 cyan_glazed_terracotta  683 purple_glazed_terracotta
684 blue_glazed_terracotta  685 brown_glazed_terracotta  686 green_glazed_terracotta  687 red_glazed_terracotta  688 black_glazed_terracotta  689 white_concrete
690 orange_concrete  691 magenta_concrete  692 light_blue_concrete  693 yellow_concrete  694 lime_concrete  695 pink_concrete
696 gray_concrete  697 light_gray_concrete  698 cyan_concrete  699 purple_concrete  700 blue_concrete  701 brown_concrete
702 green_concrete  703 red_concrete  704 black_concrete  705 white_concrete_stairs  706 orange_concrete_stairs  707 magenta_concrete_stairs
708 light_blue_concrete_stairs  709 yellow_concrete_stairs  710 lime_concrete_stairs  711 pink_concrete_stairs  712 gray_concrete_stairs  713 light_gray_concrete_stairs
714 cyan_concrete_stairs  715 purple_concrete_stairs  716 blue_concrete_stairs  717 brown_concrete_stairs  718 green_concrete_stairs  719 red_concrete_stairs
720 black_concrete_stairs  721 white_concrete_slab  722 orange_concrete_slab  723 magenta_concrete_slab  724 light_blue_concrete_slab  725 yellow_concrete_slab
726 lime_concrete_slab  727 pink_concrete_slab  728 gray_concrete_slab  729 light_gray_concrete_slab  730 cyan_concrete_slab  731 purple_concrete_slab
732 blue_concrete_slab  733 brown_concrete_slab  734 green_concrete_slab  735 red_concrete_slab  736 black_concrete_slab  737 white_concrete_powder
738 orange_concrete_powder  739 magenta_concrete_powder  740 light_blue_concrete_powder  741 yellow_concrete_powder  742 lime_concrete_powder  743 pink_concrete_powder
744 gray_concrete_powder  745 light_gray_concrete_powder  746 cyan_concrete_powder  747 purple_concrete_powder  748 blue_concrete_powder  749 brown_concrete_powder
750 green_concrete_powder  751 red_concrete_powder  752 black_concrete_powder  753 turtle_egg  754 sniffer_egg  755 dried_ghast
756 dead_tube_coral_block  757 dead_brain_coral_block  758 dead_bubble_coral_block  759 dead_fire_coral_block  760 dead_horn_coral_block  761 tube_coral_block
762 brain_coral_block  763 bubble_coral_block  764 fire_coral_block  765 horn_coral_block  766 tube_coral  767 brain_coral
768 bubble_coral  769 fire_coral  770 horn_coral  771 dead_brain_coral  772 dead_bubble_coral  773 dead_fire_coral
774 dead_horn_coral  775 dead_tube_coral  776 tube_coral_fan  777 brain_coral_fan  778 bubble_coral_fan  779 fire_coral_fan
780 horn_coral_fan  781 dead_tube_coral_fan  782 dead_brain_coral_fan  783 dead_bubble_coral_fan  784 dead_fire_coral_fan  785 dead_horn_coral_fan
786 blue_ice  787 conduit  788 polished_granite_stairs  789 smooth_red_sandstone_stairs  790 mossy_stone_brick_stairs  791 polished_diorite_stairs
792 mossy_cobblestone_stairs  793 end_stone_brick_stairs  794 stone_stairs  795 smooth_sandstone_stairs  796 smooth_quartz_stairs  797 granite_stairs
798 andesite_stairs  799 red_nether_brick_stairs  800 polished_andesite_stairs  801 diorite_stairs  802 cobbled_deepslate_stairs  803 polished_deepslate_stairs
804 deepslate_brick_stairs  805 deepslate_tile_stairs  806 polished_granite_slab  807 smooth_red_sandstone_slab  808 mossy_stone_brick_slab  809 polished_diorite_slab
810 mossy_cobblestone_slab  811 end_stone_brick_slab  812 smooth_sandstone_slab  813 smooth_quartz_slab  814 granite_slab  815 andesite_slab
816 red_nether_brick_slab  817 polished_andesite_slab  818 diorite_slab  819 cobbled_deepslate_slab  820 polished_deepslate_slab  821 deepslate_brick_slab
822 deepslate_tile_slab  823 scaffolding  824 redstone  825 redstone_torch  826 redstone_block  827 repeater
828 comparator  829 piston  830 sticky_piston  831 slime_block  832 honey_block  833 observer
834 hopper  835 dispenser  836 dropper  837 lectern  838 target  839 lever
840 lightning_rod  841 exposed_lightning_rod  842 weathered_lightning_rod  843 oxidized_lightning_rod  844 waxed_lightning_rod  845 waxed_exposed_lightning_rod
846 waxed_weathered_lightning_rod  847 waxed_oxidized_lightning_rod  848 daylight_detector  849 sculk_sensor  850 calibrated_sculk_sensor  851 tripwire_hook
852 trapped_chest  853 tnt  854 redstone_lamp  855 note_block  856 stone_button  857 polished_blackstone_button
858 oak_button  859 spruce_button  860 birch_button  861 jungle_button  862 acacia_button  863 cherry_button
864 dark_oak_button  865 pale_oak_button  866 mangrove_button  867 poplar_button  868 bamboo_button  869 crimson_button
870 warped_button  871 stone_pressure_plate  872 polished_blackstone_pressure_plate  873 light_weighted_pressure_plate  874 heavy_weighted_pressure_plate  875 oak_pressure_plate
876 spruce_pressure_plate  877 birch_pressure_plate  878 jungle_pressure_plate  879 acacia_pressure_plate  880 cherry_pressure_plate  881 dark_oak_pressure_plate
882 pale_oak_pressure_plate  883 mangrove_pressure_plate  884 poplar_pressure_plate  885 bamboo_pressure_plate  886 crimson_pressure_plate  887 warped_pressure_plate
888 iron_door  889 oak_door  890 spruce_door  891 birch_door  892 jungle_door  893 acacia_door
894 cherry_door  895 dark_oak_door  896 pale_oak_door  897 mangrove_door  898 poplar_door  899 bamboo_door
900 crimson_door  901 warped_door  902 copper_door  903 exposed_copper_door  904 weathered_copper_door  905 oxidized_copper_door
906 waxed_copper_door  907 waxed_exposed_copper_door  908 waxed_weathered_copper_door  909 waxed_oxidized_copper_door  910 iron_trapdoor  911 oak_trapdoor
912 spruce_trapdoor  913 birch_trapdoor  914 jungle_trapdoor  915 acacia_trapdoor  916 cherry_trapdoor  917 dark_oak_trapdoor
918 pale_oak_trapdoor  919 mangrove_trapdoor  920 poplar_trapdoor  921 bamboo_trapdoor  922 crimson_trapdoor  923 warped_trapdoor
924 copper_trapdoor  925 exposed_copper_trapdoor  926 weathered_copper_trapdoor  927 oxidized_copper_trapdoor  928 waxed_copper_trapdoor  929 waxed_exposed_copper_trapdoor
930 waxed_weathered_copper_trapdoor  931 waxed_oxidized_copper_trapdoor  932 oak_fence_gate  933 spruce_fence_gate  934 birch_fence_gate  935 jungle_fence_gate
936 acacia_fence_gate  937 cherry_fence_gate  938 dark_oak_fence_gate  939 pale_oak_fence_gate  940 mangrove_fence_gate  941 poplar_fence_gate
942 bamboo_fence_gate  943 crimson_fence_gate  944 warped_fence_gate  945 powered_rail  946 detector_rail  947 rail
948 activator_rail  949 saddle  950 white_harness  951 orange_harness  952 magenta_harness  953 light_blue_harness
954 yellow_harness  955 lime_harness  956 pink_harness  957 gray_harness  958 light_gray_harness  959 cyan_harness
960 purple_harness  961 blue_harness  962 brown_harness  963 green_harness  964 red_harness  965 black_harness
966 minecart  967 chest_minecart  968 furnace_minecart  969 tnt_minecart  970 hopper_minecart  971 carrot_on_a_stick
972 warped_fungus_on_a_stick  973 phantom_membrane  974 elytra  975 oak_boat  976 oak_chest_boat  977 spruce_boat
978 spruce_chest_boat  979 birch_boat  980 birch_chest_boat  981 jungle_boat  982 jungle_chest_boat  983 acacia_boat
984 acacia_chest_boat  985 cherry_boat  986 cherry_chest_boat  987 dark_oak_boat  988 dark_oak_chest_boat  989 pale_oak_boat
990 pale_oak_chest_boat  991 mangrove_boat  992 mangrove_chest_boat  993 poplar_boat  994 poplar_chest_boat  995 bamboo_raft
996 bamboo_chest_raft  997 structure_block  998 jigsaw  999 test_block  1000 test_instance_block  1001 turtle_helmet
1002 turtle_scute  1003 armadillo_scute  1004 wolf_armor  1005 flint_and_steel  1006 bowl  1007 apple
1008 bow  1009 arrow  1010 coal  1011 charcoal  1012 diamond  1013 emerald
1014 lapis_lazuli  1015 quartz  1016 amethyst_shard  1017 raw_iron  1018 iron_ingot  1019 raw_copper
1020 copper_ingot  1021 raw_gold  1022 gold_ingot  1023 netherite_ingot  1024 netherite_scrap  1025 wooden_sword
1026 wooden_shovel  1027 wooden_pickaxe  1028 wooden_axe  1029 wooden_hoe  1030 copper_sword  1031 copper_shovel
1032 copper_pickaxe  1033 copper_axe  1034 copper_hoe  1035 stone_sword  1036 stone_shovel  1037 stone_pickaxe
1038 stone_axe  1039 stone_hoe  1040 golden_sword  1041 golden_shovel  1042 golden_pickaxe  1043 golden_axe
1044 golden_hoe  1045 iron_sword  1046 iron_shovel  1047 iron_pickaxe  1048 iron_axe  1049 iron_hoe
1050 diamond_sword  1051 diamond_shovel  1052 diamond_pickaxe  1053 diamond_axe  1054 diamond_hoe  1055 netherite_sword
1056 netherite_shovel  1057 netherite_pickaxe  1058 netherite_axe  1059 netherite_hoe  1060 stick  1061 mushroom_stew
1062 string  1063 feather  1064 gunpowder  1065 wheat_seeds  1066 wheat  1067 bread
1068 leather_helmet  1069 leather_chestplate  1070 leather_leggings  1071 leather_boots  1072 copper_helmet  1073 copper_chestplate
1074 copper_leggings  1075 copper_boots  1076 chainmail_helmet  1077 chainmail_chestplate  1078 chainmail_leggings  1079 chainmail_boots
1080 iron_helmet  1081 iron_chestplate  1082 iron_leggings  1083 iron_boots  1084 diamond_helmet  1085 diamond_chestplate
1086 diamond_leggings  1087 diamond_boots  1088 golden_helmet  1089 golden_chestplate  1090 golden_leggings  1091 golden_boots
1092 netherite_helmet  1093 netherite_chestplate  1094 netherite_leggings  1095 netherite_boots  1096 flint  1097 porkchop
1098 cooked_porkchop  1099 painting  1100 golden_apple  1101 enchanted_golden_apple  1102 oak_sign  1103 spruce_sign
1104 birch_sign  1105 jungle_sign  1106 acacia_sign  1107 cherry_sign  1108 dark_oak_sign  1109 pale_oak_sign
1110 mangrove_sign  1111 poplar_sign  1112 bamboo_sign  1113 crimson_sign  1114 warped_sign  1115 oak_hanging_sign
1116 spruce_hanging_sign  1117 birch_hanging_sign  1118 jungle_hanging_sign  1119 acacia_hanging_sign  1120 cherry_hanging_sign  1121 dark_oak_hanging_sign
1122 pale_oak_hanging_sign  1123 mangrove_hanging_sign  1124 poplar_hanging_sign  1125 bamboo_hanging_sign  1126 crimson_hanging_sign  1127 warped_hanging_sign
1128 bucket  1129 water_bucket  1130 lava_bucket  1131 powder_snow_bucket  1132 snowball  1133 leather
1134 milk_bucket  1135 pufferfish_bucket  1136 salmon_bucket  1137 cod_bucket  1138 tropical_fish_bucket  1139 axolotl_bucket
1140 sulfur_cube_bucket  1141 tadpole_bucket  1142 brick  1143 clay_ball  1144 dried_kelp_block  1145 paper
1146 book  1147 slime_ball  1148 egg  1149 blue_egg  1150 brown_egg  1151 compass
1152 recovery_compass  1153 bundle  1154 white_bundle  1155 orange_bundle  1156 magenta_bundle  1157 light_blue_bundle
1158 yellow_bundle  1159 lime_bundle  1160 pink_bundle  1161 gray_bundle  1162 light_gray_bundle  1163 cyan_bundle
1164 purple_bundle  1165 blue_bundle  1166 brown_bundle  1167 green_bundle  1168 red_bundle  1169 black_bundle
1170 white_cushion  1171 orange_cushion  1172 magenta_cushion  1173 light_blue_cushion  1174 yellow_cushion  1175 lime_cushion
1176 pink_cushion  1177 gray_cushion  1178 light_gray_cushion  1179 cyan_cushion  1180 purple_cushion  1181 blue_cushion
1182 brown_cushion  1183 green_cushion  1184 red_cushion  1185 black_cushion  1186 fishing_rod  1187 clock
1188 spyglass  1189 glowstone_dust  1190 cod  1191 salmon  1192 tropical_fish  1193 pufferfish
1194 cooked_cod  1195 cooked_salmon  1196 ink_sac  1197 glow_ink_sac  1198 cocoa_beans  1199 white_dye
1200 orange_dye  1201 magenta_dye  1202 light_blue_dye  1203 yellow_dye  1204 lime_dye  1205 pink_dye
1206 gray_dye  1207 light_gray_dye  1208 cyan_dye  1209 purple_dye  1210 blue_dye  1211 brown_dye
1212 green_dye  1213 red_dye  1214 black_dye  1215 bone_meal  1216 bone  1217 sugar
1218 cake  1219 white_bed  1220 orange_bed  1221 magenta_bed  1222 light_blue_bed  1223 yellow_bed
1224 lime_bed  1225 pink_bed  1226 gray_bed  1227 light_gray_bed  1228 cyan_bed  1229 purple_bed
1230 blue_bed  1231 brown_bed  1232 green_bed  1233 red_bed  1234 black_bed  1235 straw_bed
1236 cookie  1237 crafter  1238 filled_map  1239 ocean_monument_map  1240 woodland_mansion_map  1241 buried_trial_chambers_map
1242 jungle_pyramid_map  1243 swamp_hut_map  1244 desert_village_map  1245 plains_village_map  1246 savanna_village_map  1247 snowy_village_map
1248 taiga_village_map  1249 buried_treasure_map  1250 buried_ancient_city_map  1251 buried_mineshaft_map  1252 desert_pyramid_map  1253 abandoned_camp_map
1254 warm_ocean_ruins_map  1255 shears  1256 melon_slice  1257 dried_kelp  1258 pumpkin_seeds  1259 melon_seeds
1260 beef  1261 cooked_beef  1262 chicken  1263 cooked_chicken  1264 rotten_flesh  1265 ender_pearl
1266 blaze_rod  1267 ghast_tear  1268 gold_nugget  1269 nether_wart  1270 glass_bottle  1271 potion
1272 spider_eye  1273 fermented_spider_eye  1274 blaze_powder  1275 magma_cream  1276 brewing_stand  1277 cauldron
1278 ender_eye  1279 glistering_melon_slice  1280 chicken_spawn_egg  1281 cow_spawn_egg  1282 pig_spawn_egg  1283 sheep_spawn_egg
1284 camel_spawn_egg  1285 donkey_spawn_egg  1286 horse_spawn_egg  1287 mule_spawn_egg  1288 cat_spawn_egg  1289 parrot_spawn_egg
1290 wolf_spawn_egg  1291 armadillo_spawn_egg  1292 bat_spawn_egg  1293 bee_spawn_egg  1294 fox_spawn_egg  1295 goat_spawn_egg
1296 llama_spawn_egg  1297 ocelot_spawn_egg  1298 panda_spawn_egg  1299 polar_bear_spawn_egg  1300 rabbit_spawn_egg  1301 axolotl_spawn_egg
1302 cod_spawn_egg  1303 dolphin_spawn_egg  1304 frog_spawn_egg  1305 glow_squid_spawn_egg  1306 nautilus_spawn_egg  1307 pufferfish_spawn_egg
1308 salmon_spawn_egg  1309 squid_spawn_egg  1310 tadpole_spawn_egg  1311 tropical_fish_spawn_egg  1312 turtle_spawn_egg  1313 allay_spawn_egg
1314 mooshroom_spawn_egg  1315 sniffer_spawn_egg  1316 sulfur_cube_spawn_egg  1317 copper_golem_spawn_egg  1318 iron_golem_spawn_egg  1319 snow_golem_spawn_egg
1320 trader_llama_spawn_egg  1321 villager_spawn_egg  1322 wandering_trader_spawn_egg  1323 bogged_spawn_egg  1324 camel_husk_spawn_egg  1325 drowned_spawn_egg
1326 husk_spawn_egg  1327 parched_spawn_egg  1328 skeleton_spawn_egg  1329 skeleton_horse_spawn_egg  1330 stray_spawn_egg  1331 wither_spawn_egg
1332 wither_skeleton_spawn_egg  1333 zombie_spawn_egg  1334 zombie_horse_spawn_egg  1335 zombie_nautilus_spawn_egg  1336 zombie_villager_spawn_egg  1337 cave_spider_spawn_egg
1338 spider_spawn_egg  1339 breeze_spawn_egg  1340 creaking_spawn_egg  1341 creeper_spawn_egg  1342 elder_guardian_spawn_egg  1343 guardian_spawn_egg
1344 phantom_spawn_egg  1345 silverfish_spawn_egg  1346 slime_spawn_egg  1347 warden_spawn_egg  1348 witch_spawn_egg  1349 evoker_spawn_egg
1350 pillager_spawn_egg  1351 ravager_spawn_egg  1352 vindicator_spawn_egg  1353 vex_spawn_egg  1354 blaze_spawn_egg  1355 ghast_spawn_egg
1356 happy_ghast_spawn_egg  1357 hoglin_spawn_egg  1358 magma_cube_spawn_egg  1359 piglin_spawn_egg  1360 piglin_brute_spawn_egg  1361 strider_spawn_egg
1362 zoglin_spawn_egg  1363 zombified_piglin_spawn_egg  1364 ender_dragon_spawn_egg  1365 enderman_spawn_egg  1366 endermite_spawn_egg  1367 shulker_spawn_egg
1368 experience_bottle  1369 fire_charge  1370 wind_charge  1371 writable_book  1372 written_book  1373 breeze_rod
1374 mace  1375 item_frame  1376 glow_item_frame  1377 flower_pot  1378 carrot  1379 potato
1380 baked_potato  1381 poisonous_potato  1382 map  1383 golden_carrot  1384 skeleton_skull  1385 wither_skeleton_skull
1386 player_head  1387 zombie_head  1388 creeper_head  1389 dragon_head  1390 piglin_head  1391 nether_star
1392 pumpkin_pie  1393 firework_rocket  1394 firework_star  1395 enchanted_book  1396 nether_brick  1397 resin_brick
1398 prismarine_shard  1399 prismarine_crystals  1400 rabbit  1401 cooked_rabbit  1402 rabbit_stew  1403 rabbit_foot
1404 rabbit_hide  1405 armor_stand  1406 copper_horse_armor  1407 iron_horse_armor  1408 golden_horse_armor  1409 diamond_horse_armor
1410 netherite_horse_armor  1411 leather_horse_armor  1412 lead  1413 name_tag  1414 command_block_minecart  1415 mutton
1416 cooked_mutton  1417 white_banner  1418 orange_banner  1419 magenta_banner  1420 light_blue_banner  1421 yellow_banner
1422 lime_banner  1423 pink_banner  1424 gray_banner  1425 light_gray_banner  1426 cyan_banner  1427 purple_banner
1428 blue_banner  1429 brown_banner  1430 green_banner  1431 red_banner  1432 black_banner  1433 end_crystal
1434 chorus_fruit  1435 popped_chorus_fruit  1436 torchflower_seeds  1437 pitcher_pod  1438 beetroot  1439 beetroot_seeds
1440 beetroot_soup  1441 dragon_breath  1442 splash_potion  1443 spectral_arrow  1444 tipped_arrow  1445 lingering_potion
1446 shield  1447 wooden_spear  1448 stone_spear  1449 copper_spear  1450 iron_spear  1451 golden_spear
1452 diamond_spear  1453 netherite_spear  1454 totem_of_undying  1455 shulker_shell  1456 iron_nugget  1457 copper_nugget
1458 knowledge_book  1459 debug_stick  1460 music_disc_13  1461 music_disc_cat  1462 music_disc_blocks  1463 music_disc_bounce
1464 music_disc_chirp  1465 music_disc_creator  1466 music_disc_creator_music_box  1467 music_disc_far  1468 music_disc_lava_chicken  1469 music_disc_mall
1470 music_disc_mellohi  1471 music_disc_stal  1472 music_disc_strad  1473 music_disc_ward  1474 music_disc_11  1475 music_disc_wait
1476 music_disc_otherside  1477 music_disc_relic  1478 music_disc_5  1479 music_disc_pigstep  1480 music_disc_precipice  1481 music_disc_tears
1482 disc_fragment_5  1483 trident  1484 nautilus_shell  1485 iron_nautilus_armor  1486 golden_nautilus_armor  1487 diamond_nautilus_armor
1488 netherite_nautilus_armor  1489 copper_nautilus_armor  1490 heart_of_the_sea  1491 crossbow  1492 suspicious_stew  1493 loom
1494 flower_banner_pattern  1495 creeper_banner_pattern  1496 skull_banner_pattern  1497 mojang_banner_pattern  1498 globe_banner_pattern  1499 piglin_banner_pattern
1500 flow_banner_pattern  1501 guster_banner_pattern  1502 field_masoned_banner_pattern  1503 bordure_indented_banner_pattern  1504 goat_horn  1505 composter
1506 barrel  1507 smoker  1508 blast_furnace  1509 cartography_table  1510 fletching_table  1511 grindstone
1512 smithing_table  1513 stonecutter  1514 bell  1515 lantern  1516 soul_lantern  1517 copper_lantern
1518 exposed_copper_lantern  1519 weathered_copper_lantern  1520 oxidized_copper_lantern  1521 waxed_copper_lantern  1522 waxed_exposed_copper_lantern  1523 waxed_weathered_copper_lantern
1524 waxed_oxidized_copper_lantern  1525 sweet_berries  1526 glow_berries  1527 campfire  1528 soul_campfire  1529 shroomlight
1530 honeycomb  1531 bee_nest  1532 beehive  1533 honey_bottle  1534 honeycomb_block  1535 lodestone
1536 crying_obsidian  1537 blackstone  1538 blackstone_slab  1539 blackstone_stairs  1540 gilded_blackstone  1541 polished_blackstone
1542 polished_blackstone_slab  1543 polished_blackstone_stairs  1544 chiseled_polished_blackstone  1545 polished_blackstone_bricks  1546 polished_blackstone_brick_slab  1547 polished_blackstone_brick_stairs
1548 cracked_polished_blackstone_bricks  1549 respawn_anchor  1550 candle  1551 white_candle  1552 orange_candle  1553 magenta_candle
1554 light_blue_candle  1555 yellow_candle  1556 lime_candle  1557 pink_candle  1558 gray_candle  1559 light_gray_candle
1560 cyan_candle  1561 purple_candle  1562 blue_candle  1563 brown_candle  1564 green_candle  1565 red_candle
1566 black_candle  1567 small_amethyst_bud  1568 medium_amethyst_bud  1569 large_amethyst_bud  1570 amethyst_cluster  1571 pointed_dripstone
1572 sulfur_spike  1573 ochre_froglight  1574 verdant_froglight  1575 pearlescent_froglight  1576 frogspawn  1577 echo_shard
1578 brush  1579 netherite_upgrade_smithing_template  1580 sentry_armor_trim_smithing_template  1581 dune_armor_trim_smithing_template  1582 coast_armor_trim_smithing_template  1583 wild_armor_trim_smithing_template
1584 ward_armor_trim_smithing_template  1585 eye_armor_trim_smithing_template  1586 vex_armor_trim_smithing_template  1587 tide_armor_trim_smithing_template  1588 snout_armor_trim_smithing_template  1589 rib_armor_trim_smithing_template
1590 spire_armor_trim_smithing_template  1591 wayfinder_armor_trim_smithing_template  1592 shaper_armor_trim_smithing_template  1593 silence_armor_trim_smithing_template  1594 raiser_armor_trim_smithing_template  1595 host_armor_trim_smithing_template
1596 flow_armor_trim_smithing_template  1597 bolt_armor_trim_smithing_template  1598 angler_pottery_sherd  1599 archer_pottery_sherd  1600 arms_up_pottery_sherd  1601 blade_pottery_sherd
1602 brewer_pottery_sherd  1603 burn_pottery_sherd  1604 danger_pottery_sherd  1605 explorer_pottery_sherd  1606 flow_pottery_sherd  1607 friend_pottery_sherd
1608 guster_pottery_sherd  1609 heart_pottery_sherd  1610 heartbreak_pottery_sherd  1611 howl_pottery_sherd  1612 miner_pottery_sherd  1613 mourner_pottery_sherd
1614 plenty_pottery_sherd  1615 prize_pottery_sherd  1616 scrape_pottery_sherd  1617 sheaf_pottery_sherd  1618 shelter_pottery_sherd  1619 skull_pottery_sherd
1620 snort_pottery_sherd  1621 copper_grate  1622 exposed_copper_grate  1623 weathered_copper_grate  1624 oxidized_copper_grate  1625 waxed_copper_grate
1626 waxed_exposed_copper_grate  1627 waxed_weathered_copper_grate  1628 waxed_oxidized_copper_grate  1629 copper_bulb  1630 exposed_copper_bulb  1631 weathered_copper_bulb
1632 oxidized_copper_bulb  1633 waxed_copper_bulb  1634 waxed_exposed_copper_bulb  1635 waxed_weathered_copper_bulb  1636 waxed_oxidized_copper_bulb  1637 copper_chest
1638 exposed_copper_chest  1639 weathered_copper_chest  1640 oxidized_copper_chest  1641 waxed_copper_chest  1642 waxed_exposed_copper_chest  1643 waxed_weathered_copper_chest
1644 waxed_oxidized_copper_chest  1645 copper_golem_statue  1646 exposed_copper_golem_statue  1647 weathered_copper_golem_statue  1648 oxidized_copper_golem_statue  1649 waxed_copper_golem_statue
1650 waxed_exposed_copper_golem_statue  1651 waxed_weathered_copper_golem_statue  1652 waxed_oxidized_copper_golem_statue  1653 trial_spawner  1654 trial_key  1655 ominous_trial_key
1656 vault  1657 ominous_bottle
```

## 12. Worked examples

1. **Field to id.** `ECHO_SHARD` is field 1200. The collection fields before it contribute 405 - 4 x 7 = 377 extra ids (all 405 extra ids of the registry minus the 28 of the four weathering collections at fields 1244 to 1247 that come later), so its id is 1200 + 377 = 1577. Check with 11.2: field 1150 has offset 355, and `COPPER_LANTERN` (8 items, +7) and `DYED_CANDLE` (16 items, +15) lie between 1150 and 1200: 355 + 7 + 15 = 377.
2. **Last items.** Field 1247 `COPPER_GOLEM_STATUE` starts at id 1645 and ends at 1652; field 1248 `TRIAL_SPAWNER` is id 1653, `TRIAL_KEY` 1654, `OMINOUS_TRIAL_KEY` 1655, `VAULT` 1656, `OMINOUS_BOTTLE` 1657.
3. **Drinking honey at full food.** Player food 20, saturation 5.0, three honey bottles in the main hand. Use: `canConsume` is true (always edible). 40 ticks later `onConsume`: `FoodData.eat(6, 1.2)`: food = clamp(26, 0, 20) = 20, saturation = clamp(6.2, 0, 20) = 6.2. Poison is removed if present. Stack count 3 becomes 2; 2 is below the earlier count 3, so a glass bottle is created; the stack is not empty, so `Inventory.add(glass_bottle)` is tried and, if full, the bottle is dropped at the player. Game event `drink`.
4. **Last honey bottle.** One bottle: after `consume` the stack is empty, so the glass bottle becomes the held item (no inventory add).
5. **Creative.** The same drink with infinite materials: `consume` does nothing, `convertIntoRemainder` returns the stack unchanged: the bottle stays, no glass bottle appears.
6. **Closed.** Decorated pot engine and break drops: 31-3 (see 9 item 3).
7. **Closed.** Vault key rules: 31-7 §7.9; trial spawner: 31-7 (see 10 item 1).
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
| V15 | Part ranges partition the registry | 9 ranges (11.4), each starting one id after the previous ends, 228 + 228 + 94 + 425 + 153 + 152 + 180 + 45 + 153 = 1658 |
| V16 | Key list equals the item definition file names | 1658 keys in 11.6, all distinct, set equal to the 1658 `assets/minecraft/items/*.json` names; id 1505 `composter`, 1577 `echo_shard`, 1657 `ominous_bottle` |
| V17 | Family counts | 1125 + 445 + 88 = 1658 (11.5) |

## 14. Open questions

1. **Field numbers versus ids.** 1150 to 1252 are field numbers (section 1); the registry ids of the range are 1505 to 1657. Downstream documents (46, the packet documents) must use the ids; this follows from the id rule, which matches the contiguous 0 to 1657 and the 1658 item definition files.
2. **Consume listener order.** `Consumable.onConsume` iterates `ItemStack.getAllOfType(ConsumableListener)`; the order across several listener components on one stack (for example `food` and a potion component) was not traced. No item of this range has two.
3. **Furnace fuel evaluation context.** `AbstractFurnaceBlockEntity` resolves `cooking_fuel` through `ResolvableInt.getFromItem` and `ResolvableFloat.getFromItem`; the loot context parameters it builds (which block state or position feed the `fast_cooking` predicate) and the rounding of the integer division for factors other than 1 and 2 were not read.
4. **Composter random draws.** `compostable/*` use weighted lists evaluated with a loot context; the generator and the draw order inside the evaluation (which random source of the context, the number of draws) were not traced.
5. **Berries on a block.** Whether a right click on a block that refuses the berries' placement then reaches `Item.use` (eating) was not traced beyond 29 §9.5 to §9.7; `BlockItem` has no `use` override.
6. **Decorated pot engine.** The decorated pot block entity's server logic, the break drops of a pot with sherds and the sherd recipes were not read.
7. **Vault and trial spawner.** How a vault accepts `trial_key` and `ominous_trial_key`, how a trial spawner uses `ominous_bottle`, and the trial spawner states were not read; they are block entity engines.
8. **Brush sound overload.** The volume, pitch and own-client exclusion of the four-argument `Level.playSound(entity, pos, sound, source)` overload used in the brush tick, and the `getBrushSound` of each brushable block (the suspicious sand and gravel constructors), were not read: a search of `Level.class` found the six-argument overload (position plus 0.5, with volume and pitch) but the four-argument one was not traced, and the block classes were not located by name. The dust delta table is in 42-7 §6.50 and the `nextInt(7, 12)` range is read (7 to 11), so both are closed.
9. **Wax-on second chest half.** Only the clicked half is rewritten by `HoneycombItem`; how the other half of a double copper chest becomes waxed (block `updateShape` or block entity) was not read.
10. **Feature flags.** `registerBlock` calls `properties.requiredFeatures(block.requiredFeatures())`; which of the 103 rows have non-vanilla required features (the flags `trade_rebalance`, `redstone_experiments`, `minecart_improvements` exist) was not read. The block registry parts (24-1 to 24-8) carry the per-block flags.
11. **Keys outside the range.** The base keys of the `copper_block` and `dyed_bundle` collections (11.3) are owned by the parts that cover them.
12. **Hover texts and creative tab order.** The English texts of the template, sherd and key names, and `CreativeModeTabs` ordering, are data (22) and were not read.
13. **`OverrideConsumeSound` and `use_cooldown`.** Items implementing `Consumable$OverrideConsumeSound` (not in this range) and the `UseCooldown.apply` rule were not read here.
14. **Remaining inferred items.** The only `(inferred)` marks left are the constant-name to key mapping of 11.6 (see question 17).
15. **Closed.** The either flag is read (4.4 item 1).
16. **Sibling labels.** Part 7's header gives "ids 1105 to 1149" for what are fields 1105 to 1149 (ids 1460 to 1504, 11.4); parts 5 and 6 are headed by field. The sibling documents were not edited by this round; check any `id` column in them against 11.6. To the part 7 reader: the header and Covers rows of 25-7 label fields 1105 to 1149 as ids and name `trident (1128)` and similar; they should read ids 1460 to 1504 (trident is field 1128 and id 1483 per 11.6). This document did not edit 25-7.
17. **Constant names versus keys.** A few `Items` constants differ from the item key beyond case (`DRY_SHORT_GRASS` is key `short_dry_grass`, `DRY_TALL_GRASS` is `tall_dry_grass`, `CUT_STANDSTONE_SLAB` is `cut_sandstone_slab`, plus the `copper_block` and `dyed_*` collections of 11.3). The mapping was fixed by matching the derived key set against the item definition file names, not read from the registration calls of those fields (inferred).
