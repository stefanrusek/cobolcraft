# Item registry, part 5: buckets, maps, bottles, potions and miscellaneous items (`Items` fields 848 to 939)

| Item | Value |
|---|---|
| Covers | The registry entries of `net.minecraft.world.item.Items` from field 848 (`bucket`) to field 939 (`glistering_melon_slice`): key, registry id, item class, prototype components and every constant the registering code sets; the food and consumable definitions those items use (`Foods`, `Consumables`, `Consumable`, the consume effects); the engines of the code-defined behaviour: buckets (empty, water, lava, powder snow, mob buckets, milk), snowball and eggs, compass and recovery compass, bundles and dyed bundles, cushions, ink sacs and dyes, glass bottle, potion bottle, ender eye, filled map and the sixteen exploration map items, map data (`MapItemSavedData`), the map update algorithm and decorations; potion contents and the 46 potions with their effects. |
| Does not cover | Fields 0 to 847 and 940 onward (siblings: part 1 [25-item-registry-1-model-and-blocks-a.md](25-item-registry-1-model-and-blocks-a.md) and the other parts of document 25). Splash, lingering potions and tipped arrows (fields after 939; the thrown-potion arithmetic is already in 17 section 3.15). Block rows (24). Entity internals of the bucketed mobs (45 part 7 section 8, 19 to 21). The `FishingHook` flight and bite physics (Open question 5; its retrieve cost is in 6.2b). The `EyeOfEnder` flight is in 6.3a. The data rows the extraction tool copies (recipes, loot tables, tags, `context_int_provider`, `en_us`, item models): this document names the key and the schema and lists only the few rows of 2.4 (22, 23, 26). Map colour table: it is in 24 part 1 section 8.1. Potion ids: 46 section 4.3 (repeated here only to attach effects). Mob effect ids: 46 section 4.1. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for lambda and bootstrap targets), with no execution. The classes read are named in backticks where a fact is given. Statements not read are marked "(inferred)" or "(recalled, not verified)" and listed in the Open questions. |
| Status | Written for round RS5 (design map Part 5, GAP-2, the part covering fields 848 to 939). |

Class names in backticks say where a fact was read. They are not the design. "17 section 1.4" means section 1.4 of
`17-tools-weapons-and-combat.md`, "46 section 4.3" means section 4.3 of `46-registry-ids.md`, and so on.

## Contents

1. Numbering: field number versus registry id
2. How an `Items` entry is built (2.1 registering helpers, 2.2 default components, 2.3 builders, 2.4 fuel and compost components)
3. The rows, fields 848 to 939 (3.1 shears tool component)
4. Foods, consumables and the consume pipeline (4.1 `FoodProperties`, 4.2 `Consumable`, 4.3 pipeline, 4.4 consume effects, 4.5 `Consumables` entries)
5. Buckets (5.1 `BucketItem.use`, 5.2 `emptyContents`, 5.3 powder snow, 5.4 mob buckets, 5.5 picking up a mob, 5.6 milk bucket, 5.7 `BucketPickup` implementers)
6. Throwables and the eye of ender (6.1 snowball and eggs, 6.2 ender pearl, 6.2a fishing rod, 6.2b `FishingHook.retrieve`, 6.3 ender eye, 6.3a `EyeOfEnder` entity)
7. Compass, spyglass, bundles, cushions, ink sacs, dyes, glass bottle (7.1 to 7.6)
8. Maps (8.1 items, 8.2 saved data, 8.3 update algorithm, 8.4 decorations, 8.5 update packet, 8.6 biome preview)
9. Potions (9.1 `PotionContents`, 9.2 `PotionItem`, 9.3 potions, 9.4 effect colours)
10. Worked examples
11. Validation
12. Open questions

---

## 1. Numbering: field number versus registry id

The scope of this part was given as "indices 848 to 939". Those numbers are **field numbers**: the position of the
`putstatic` of the entry in `Items.<clinit>`, counting from `air` = 0. They are not the registry ids, because some fields register
many items:

- A field of type `ColorCollection<Item>` registers 16 items (dye order of 24 part 1: white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black), key `<colour>_<base>`.
- A field of type `WeatheringCopperCollection<Item>` registers 8 items (24 part 1).
- Every other field registers exactly one item (every `registerItem` / `registerBlock` call ends in `Registry.register`, `Items.registerItem` last overload).

`Items` has 1253 fields: 1218 plain `Item`, 20 colour collections and 15 weathering collections, so the registry has
1218 + 20 x 16 + 15 x 8 = **1658** items. The registry id of an entry is the number of entries registered before it
(46 section 2.1). For fields 848 to 939 every collection field before field 848 is already counted, so
**registry id = field number + 280** for fields 848 to 873, and the collection fields inside the range add further shifts as shown
in the id column of section 3 (computed from the field types read in `Items`; the computation assumes that every non-collection field registers one item, which the helper code confirms).
(Re-read from the `Items` declarations in this round: 1253 fields, of which 20 are `ColorCollection` and 15 are `WeatheringCopperCollection`; 14 colour and 10 weathering collections lie before field 848, so the offset is 14 x 15 + 10 x 7 = 280 and `bucket` is 848 + 280 = 1128; 4 colour collections lie inside the range 848 to 939. Open question 1: not compared with 46 section 2.1 or with an extraction output.)

Fields with collections in this range: 874 `dyed_bundle` (ids 1154 to 1169), 875 `cushion` (1170 to 1185), 889 `dye` (1199 to 1214), 894 `bed`
(1219 to 1234).

---

## 2. How an `Items` entry is built

### 2.1 Registering helpers (`Items`)

| Helper | What it does |
|---|---|
| `registerItem(key)` | `Item` with a fresh `Item$Properties` |
| `registerItem(key, props)` | `Item` with the given properties |
| `registerItem(key, factory)` and `(key, factory, props)` | the item built by `factory(props)` |
| `registerItem(BlockItemId, ...)` | the same with the key taken from the `BlockItemId` (`BlockItemId.item()`) |
| `registerBlock(BlockItemId, block)` and overloads | a `BlockItem` (or the given factory's item) for `block`, with `useBlockDescriptionPrefix()` (name key prefix `block.`) and `requiredFeatures` copied from the block; the variants with trailing blocks also put the item in `Item.BY_BLOCK` for each extra block (the cauldron row uses this) |
| `createBlockItemWithCustomItemName(block)` | a `BlockItem` whose name key prefix is `item.` (`useItemDescriptionPrefix`), used for seeds, cocoa beans and nether wart |
| `mapProperties()` | `Item$Properties` with `map_decorations` = empty `MapDecorations` |

The final step (`registerItem(key, factory, props)`) sets the id on the properties, calls the factory, runs `BlockItem.registerBlocks` for block items
(entry in `Item.BY_BLOCK`) and registers in `BuiltInRegistries.ITEM`.

### 2.2 Default components of every item

`DataComponents.COMMON_ITEM_COMPONENTS` is added to every item's prototype first (read at the end of `DataComponents.<clinit>`):

| Component | Default |
|---|---|
| `max_stack_size` | 64 |
| `lore` | empty |
| `enchantments` | empty |
| `repair_cost` | 0 |
| `use_effects` | `UseEffects.DEFAULT` (17 section 1.3) |
| `attribute_modifiers` | empty |
| `rarity` | `common` |
| `break_sound` | `entity.item.break` |
| `tooltip_display` | `TooltipDisplay.DEFAULT` |
| `attack_animation` | `SwingAnimation.DEFAULT` |
| `interact_animation` | `SwingAnimation.DEFAULT` |

`Item$Properties.finalizeInitializer` then adds `item_name` (translatable key from the description id: prefix `item.` or `block.` joined with the key) and `item_model`
(the item's own key) and installs a validator: an item that has a `damage` component and a `max_stack_size` above 1 is an error ("Item cannot have both durability and be stackable").
The calls `.component(...)` of the builders are applied in call order; `delayed` components (those needing registries such as the chicken variants) are filled when the registries are available.

### 2.3 Builders used by this part

| Builder | Effect |
|---|---|
| `stacksTo(n)` | `max_stack_size` = n |
| `durability(n)` | `max_damage` n, `max_stack_size` 1, `damage` 0 (17 section 1.4) |
| `enchantable(n)` | `enchantable` = n (the value used by the enchanting table, 17 section 6.5) |
| `rarity(r)` | `rarity` |
| `craftRemainder(item)` | the **crafting** remainder item (a field of the properties, not a component): `ItemStackTemplate(item)` |
| `usingConvertsTo(item)` | component `use_remainder` = `UseRemainder(ItemStackTemplate(item))` |
| `useCooldown(seconds)` | component `use_cooldown` (seconds only, no group) |
| `food(food)` | `food` = the record and `consumable` = `Consumables.DEFAULT_FOOD` |
| `food(food, consumable)` | both given |
| `component(type, value)` | the component |
| `compostable(key)` | component `compostable` = `Compostable(ResolvableInt.fromKey(key))`; `key` names a `context_int_provider` data file (`compostable/*`, values in 2.4) giving the layer count |
| `cookingFuel(key)` | component `cooking_fuel` = `CookingFuel(ResolvableInt.fromKey(burn-time key), ResolvableFloat.fromKey(COOKING_DEFAULT_SPEED_MULTIPLIER))`; the burn time is a data row (`cooking/time_*`, values in 2.4) |
| `brewingFuel(key)` | component `brewing_fuel` = `BrewingFuel(ResolvableInt.fromKey(uses key), ResolvableFloat.fromKey(BREWING_DEFAULT_SPEED_MULTIPLIER))` (values in 2.4) |
| `delayedHolderComponent(type, key)` | component whose holder is looked up when the registries exist (used for `chicken_variant`) |
| `useItemDescriptionPrefix()` / `useBlockDescriptionPrefix()` | `item_name` key prefix |

Fuel and compost values are **data** (the named providers, 2.4). The component names and their provider keys per item are in section 3.

### 2.4 `compostable`, `cooking_fuel` and `brewing_fuel`: wire, file layout and data rows

Each of the three components holds `ResolvableInt` (and, for the two fuels, `ResolvableFloat`) values built with `fromKey`, that is the **Reference** branch, not a bare resource key. (Components 84 to 86 in 46 section 8.1.)

| Type | Wire form | File form |
|---|---|---|
| `ResolvableInt` | `Either` of Constant and Reference: a Boolean (the decode reads it first and builds the left branch or the right branch from it; true = Constant is inferred from the usual encoding order, not read), then for Constant an Int (4 bytes, `ByteBufCodecs.INT`), for Reference a resource key of the registry `context_int_provider` (an identifier) | an `Either` of an int and a resource key string |
| `ResolvableFloat` | the same with Float (4 bytes) and a resource key of `context_float_provider` | an `Either` of a float and a resource key string |
| `CookingFuel` | composite: `ResolvableInt` (burn time) then `ResolvableFloat` (speed multiplier) | fields `burn_time`, `speed_multiplier` |
| `BrewingFuel` | composite: `ResolvableInt` (uses) then `ResolvableFloat` (speed multiplier) | fields `uses`, `speed_multiplier` |
| `Compostable` | composite of one field: `ResolvableInt` (layers) | one field `layers` |

Data rows referenced by this part (read in the jar under `data/minecraft/context_int_provider/` and `context_float_provider/`; the mapping of the Java constant names in section 3 to the file names is by name, inferred):

| Key (file) | Content |
|---|---|
| `cooking/time_lava_bucket` | `div`: 20000 divided by `conditional(block/fast_cooking, on_true cooking/fast_burn_time_reduction_factor, on_false cooking/normal_burn_time_reduction_factor)` |
| `cooking/time_blaze_rod` | the same with left 2400 |
| `cooking/time_dried_kelp_block` | the same with left 4001 |
| `cooking/time_wool_slabs` | the same with left 50 |
| `cooking/time_wood_items_small` | the same with left 300 |
| `cooking/normal_burn_time_reduction_factor`, `cooking/fast_burn_time_reduction_factor` | constants 1 and 2 |
| `cooking/speed_default` (float) | `conditional(block/fast_cooking, cooking/fast_speed_multiplier, cooking/normal_speed_multiplier)`; the two are constants 2.0 and 1.0 |
| `brewing/uses_default` | constant 20 |
| `brewing/speed_default` (float) | constant 1.0 |
| `compostable/always_add_one` | constant 1 |
| `compostable/low`, `low_medium`, `medium`, `medium_high` | `number_dispatcher`: case (`match_block` `composter` with `level` = 0) gives 1; default is a `weighted_list` of data 1 and data 0 with weights 30/70, 50/50, 65/35 and 85/15 respectively |

(The `div`, `conditional`, `number_dispatcher` and `weighted_list` provider types belong to the loot number providers, 26; the evaluation context for `block/fast_cooking` is the furnace or campfire, not read here.)

---

## 3. The rows, fields 848 to 939

Key is `minecraft:<key>`. "Class" is the Java class created by the factory (`Item` = plain item with no behaviour). "Components" lists only what the
registering code sets (beyond section 2.2). `stack` is `max_stack_size` when different from 64. A provider key such as `COOKING_TIME_LAVA_BUCKET` names a data file of the data pack (26); its numbers are not in this document.

| Field | Id | Key | Class | Components set by the registering code |
|---|---|---|---|---|
| 848 | 1128 | `bucket` | `BucketItem` (fluid empty) | stack 16 |
| 849 | 1129 | `water_bucket` | `BucketItem` (water) | stack 1; crafting remainder `bucket` |
| 850 | 1130 | `lava_bucket` | `BucketItem` (lava) | stack 1; crafting remainder `bucket`; `cooking_fuel` (`COOKING_TIME_LAVA_BUCKET`) |
| 851 | 1131 | `powder_snow_bucket` | `SolidBucketItem` (block `powder_snow`, sound `bucket.empty_powder_snow`) | stack 1; name prefix `item.` (the block item id's item key is `powder_snow_bucket`) |
| 852 | 1132 | `snowball` | `SnowballItem` | stack 16 |
| 853 | 1133 | `leather` | `Item` | |
| 854 | 1134 | `milk_bucket` | `Item` | stack 1; crafting remainder `bucket`; `consumable` = `Consumables.MILK_BUCKET`; `use_remainder` `bucket` |
| 855 | 1135 | `pufferfish_bucket` | `MobBucketItem` (pufferfish, water, `bucket.empty_fish`) | stack 1; `bucket_entity_data` empty; `food` = `Foods.PUFFERFISH` (**no** `consumable`) |
| 856 | 1136 | `salmon_bucket` | `MobBucketItem` (salmon, water, `bucket.empty_fish`) | stack 1; `bucket_entity_data` empty; `food` = `Foods.SALMON` (no `consumable`) |
| 857 | 1137 | `cod_bucket` | `MobBucketItem` (cod, water, `bucket.empty_fish`) | stack 1; `bucket_entity_data` empty; `food` = `Foods.COD` (no `consumable`) |
| 858 | 1138 | `tropical_fish_bucket` | `MobBucketItem` (tropical_fish, water, `bucket.empty_fish`) | stack 1; `bucket_entity_data` empty; `food` = `Foods.TROPICAL_FISH` (no `consumable`) |
| 859 | 1139 | `axolotl_bucket` | `MobBucketItem` (axolotl, water, `bucket.empty_axolotl`) | stack 1; `bucket_entity_data` empty |
| 860 | 1140 | `sulfur_cube_bucket` | `MobBucketItem` (sulfur_cube, **empty fluid**, `bucket.empty_sulfur_cube`) | stack 1; `bucket_entity_data` empty |
| 861 | 1141 | `tadpole_bucket` | `MobBucketItem` (tadpole, water, `bucket.empty_tadpole`) | stack 1; `bucket_entity_data` empty |
| 862 | 1142 | `brick` | `Item` | |
| 863 | 1143 | `clay_ball` | `Item` | |
| 864 | 1144 | `dried_kelp_block` | `BlockItem` (`dried_kelp_block`) | `compostable` (`COMPOSTABLE_LOW_MEDIUM`); `cooking_fuel` (`COOKING_TIME_DRIED_KELP_BLOCK`) |
| 865 | 1145 | `paper` | `Item` | |
| 866 | 1146 | `book` | `Item` | `enchantable` 1 |
| 867 | 1147 | `slime_ball` | `Item` | |
| 868 | 1148 | `egg` | `EggItem` | stack 16; `chicken_variant` = `temperate` (delayed holder) |
| 869 | 1149 | `blue_egg` | `EggItem` | stack 16; `chicken_variant` = `cold` |
| 870 | 1150 | `brown_egg` | `EggItem` | stack 16; `chicken_variant` = `warm` |
| 871 | 1151 | `compass` | `CompassItem` | |
| 872 | 1152 | `recovery_compass` | `Item` | `rarity` uncommon |
| 873 | 1153 | `bundle` | `BundleItem` | stack 1; `bundle_contents` empty |
| 874 | 1154 to 1169 | `<colour>_bundle` (16) | `BundleItem` | stack 1; `bundle_contents` empty (the colour is carried by the key and the model only) |
| 875 | 1170 to 1185 | `<colour>_cushion` (16) | `CushionItem` | stack 16; `cushion/color` = the colour (`DyeColor`); `cooking_fuel` (`COOKING_TIME_WOOL_SLABS`) |
| 876 | 1186 | `fishing_rod` | `FishingRodItem` | `cooking_fuel` (`COOKING_TIME_WOOD_ITEMS_SMALL`); durability 64; `enchantable` 1 |
| 877 | 1187 | `clock` | `Item` | |
| 878 | 1188 | `spyglass` | `SpyglassItem` | stack 1 |
| 879 | 1189 | `glowstone_dust` | `Item` | |
| 880 | 1190 | `cod` | `Item` | `food` `Foods.COD` + default food consumable |
| 881 | 1191 | `salmon` | `Item` | `food` `Foods.SALMON` + default food consumable |
| 882 | 1192 | `tropical_fish` | `Item` | `food` `Foods.TROPICAL_FISH` + default food consumable |
| 883 | 1193 | `pufferfish` | `Item` | `food` `Foods.PUFFERFISH`, `consumable` `Consumables.PUFFERFISH` |
| 884 | 1194 | `cooked_cod` | `Item` | `food` `Foods.COOKED_COD` + default food consumable |
| 885 | 1195 | `cooked_salmon` | `Item` | `food` `Foods.COOKED_SALMON` + default food consumable |
| 886 | 1196 | `ink_sac` | `InkSacItem` | |
| 887 | 1197 | `glow_ink_sac` | `GlowInkSacItem` | |
| 888 | 1198 | `cocoa_beans` | `BlockItem` (block `cocoa`, prefix `item.`; the `BlockItemId` is `cocoa_crop` with item key `cocoa_beans`) | `compostable` (`COMPOSTABLE_MEDIUM`) |
| 889 | 1199 to 1214 | `<colour>_dye` (16) | `DyeItem` | `dye` = the colour (component id in 46 section 8.1) |
| 890 | 1215 | `bone_meal` | `BoneMealItem` (17 section 3.4) | |
| 891 | 1216 | `bone` | `Item` | |
| 892 | 1217 | `sugar` | `Item` | |
| 893 | 1218 | `cake` | `BlockItem` (`cake`) | stack 1; `compostable` (`COMPOSTABLE_ALWAYS_ADD_ONE`) |
| 894 | 1219 to 1234 | `<colour>_bed` (16) | `BlockItem` (the colour's bed block) | stack 1 |
| 895 | 1235 | `straw_bed` | `BlockItem` (`straw_bed`) | stack 16; `compostable` (`COMPOSTABLE_MEDIUM_HIGH`) |
| 896 | 1236 | `cookie` | `Item` | `food` `Foods.COOKIE` + default food consumable; `compostable` (`COMPOSTABLE_MEDIUM_HIGH`) |
| 897 | 1237 | `crafter` | `BlockItem` (`crafter`) | `container` empty |
| 898 | 1238 | `filled_map` | `MapItem` | `map_decorations` empty (stack 64, the default) |
| 899 | 1239 | `ocean_monument_map` | `MapItem` | `map_decorations` empty |
| 900 | 1240 | `woodland_mansion_map` | `MapItem` | `map_decorations` empty |
| 901 to 914 | 1241 to 1254 | `buried_trial_chambers_map`, `jungle_pyramid_map`, `swamp_hut_map`, `desert_village_map`, `plains_village_map`, `savanna_village_map`, `snowy_village_map`, `taiga_village_map`, `buried_treasure_map`, `buried_ancient_city_map`, `buried_mineshaft_map`, `desert_pyramid_map`, `abandoned_camp_map`, `warm_ocean_ruins_map` (in field order) | `MapItem` | `map_decorations` empty |
| 915 | 1255 | `shears` | `ShearsItem` | durability 238; `tool` = `ShearsItem.createToolProperties` (section 3.1) |
| 916 | 1256 | `melon_slice` | `Item` | `food` `Foods.MELON_SLICE` + default food consumable; `compostable` (`COMPOSTABLE_LOW_MEDIUM`) |
| 917 | 1257 | `dried_kelp` | `Item` | `food` `Foods.DRIED_KELP`, `consumable` `Consumables.DRIED_KELP`; `compostable` (`COMPOSTABLE_LOW`) |
| 918 | 1258 | `pumpkin_seeds` | `BlockItem` (block `pumpkin_stem`, prefix `item.`; `BlockItemId` `pumpkin_crop`) | `compostable` (`COMPOSTABLE_LOW`) |
| 919 | 1259 | `melon_seeds` | `BlockItem` (block `melon_stem`, prefix `item.`; `BlockItemId` `melon_crop`) | `compostable` (`COMPOSTABLE_LOW`) |
| 920 | 1260 | `beef` | `Item` | `food` `Foods.BEEF` + default food consumable |
| 921 | 1261 | `cooked_beef` | `Item` | `food` `Foods.COOKED_BEEF` + default food consumable |
| 922 | 1262 | `chicken` | `Item` | `food` `Foods.CHICKEN`, `consumable` `Consumables.CHICKEN` |
| 923 | 1263 | `cooked_chicken` | `Item` | `food` `Foods.COOKED_CHICKEN` + default food consumable |
| 924 | 1264 | `rotten_flesh` | `Item` | `food` `Foods.ROTTEN_FLESH`, `consumable` `Consumables.ROTTEN_FLESH` |
| 925 | 1265 | `ender_pearl` | `EnderpearlItem` | stack 16; `use_cooldown` 1.0 s |
| 926 | 1266 | `blaze_rod` | `Item` | `cooking_fuel` (`COOKING_TIME_BLAZE_ROD`) |
| 927 | 1267 | `ghast_tear` | `Item` | |
| 928 | 1268 | `gold_nugget` | `Item` | |
| 929 | 1269 | `nether_wart` | `BlockItem` (block `nether_wart`, prefix `item.`) | `compostable` (`COMPOSTABLE_MEDIUM`) |
| 930 | 1270 | `glass_bottle` | `BottleItem` | |
| 931 | 1271 | `potion` | `PotionItem` | stack 1; `potion_contents` empty; `consumable` `Consumables.DEFAULT_DRINK`; `use_remainder` `glass_bottle` |
| 932 | 1272 | `spider_eye` | `Item` | `food` `Foods.SPIDER_EYE`, `consumable` `Consumables.SPIDER_EYE` |
| 933 | 1273 | `fermented_spider_eye` | `Item` | |
| 934 | 1274 | `blaze_powder` | `Item` | `brewing_fuel` (`BREWING_DEFAULT_USES`) |
| 935 | 1275 | `magma_cream` | `Item` | |
| 936 | 1276 | `brewing_stand` | `BlockItem` (`brewing_stand`) | `container` empty |
| 937 | 1277 | `cauldron` | `BlockItem` (`cauldron`), also the item of `water_cauldron`, `lava_cauldron`, `powder_snow_cauldron` in `Item.BY_BLOCK` | |
| 938 | 1278 | `ender_eye` | `EnderEyeItem` | |
| 939 | 1279 | `glistering_melon_slice` | `Item` | |

Notes on the table:

- **Fish bucket food.** The four fish buckets carry the `food` component without `consumable`; `Consumable.canConsume` is what makes a stack edible, so they cannot be eaten
  (inferred: the `food` component is used by animal feeding logic, which is in 19 to 21). A stack's use is "place the bucket", not "eat".
- **Chicken variant.** `egg`, `blue_egg`, `brown_egg` put `chicken_variant` into the prototype so that the thrown egg inherits it (17 section 3.15).
- **Dyed bundle, cushion and bed colour.** Only the cushion and the dye carry the colour as a component. Bundles and beds are distinguished by their keys.
- **Cauldron.** The cauldron item places `cauldron` only; the filled cauldrons have no item of their own (`Item.BY_BLOCK` maps them to it).
- **Shears row.** `shears` has no `repairable` and no `enchantable` set in the registering code (read: the row calls `durability`, then `component(tool, ...)` only).

### 3.1 Shears tool component (`ShearsItem.createToolProperties`)

`tool` = rules in order: (1) block `cobweb`, speed 15.0, correct for drops true; (2) tag `shears_extreme_breaking_speed`, speed 15.0 (override speed only); (3) tag `shears_major_breaking_speed`, speed 5.0; (4) tag `shears_minor_breaking_speed`, speed 2.0;
default mining speed 1.0, `damage_per_block` 1, `can_destroy_blocks_in_creative` true. Tag contents are data. This agrees with 17 section 3.2 (cobweb 15, leaves 15, wool 5, vine and glow lichen 2).

---

## 4. Foods, consumables and the consume pipeline

### 4.1 `FoodProperties`

Record (nutrition: int, saturation: float, can_always_eat: boolean). The builder takes a **modifier**, and `build` stores
`saturation = nutrition x modifier x 2.0` (`FoodConstants.saturationByModifier`). Wire: nutrition VarInt, saturation Float, can_always_eat Boolean (17 section 1.2, component 23).

Entries used in this part (nutrition, modifier, saturation = nutrition x modifier x 2):

| Foods field | Nutrition | Modifier | Saturation | Always edible |
|---|---|---|---|---|
| `PUFFERFISH` | 1 | 0.1 | 0.2 | no |
| `SALMON` | 2 | 0.1 | 0.4 | no |
| `COD` | 2 | 0.1 | 0.4 | no |
| `TROPICAL_FISH` | 1 | 0.1 | 0.2 | no |
| `COOKED_COD` | 5 | 0.6 | 6.0 | no |
| `COOKED_SALMON` | 6 | 0.8 | 9.6 | no |
| `COOKIE` | 2 | 0.1 | 0.4 | no |
| `MELON_SLICE` | 2 | 0.3 | 1.2 | no |
| `DRIED_KELP` | 1 | 0.3 | 0.6 | no |
| `BEEF` | 3 | 0.3 | 1.8 | no |
| `COOKED_BEEF` | 8 | 0.8 | 12.8 | no |
| `CHICKEN` | 2 | 0.3 | 1.2 | no |
| `COOKED_CHICKEN` | 6 | 0.6 | 7.2 | no |
| `ROTTEN_FLESH` | 4 | 0.1 | 0.8 | no |
| `SPIDER_EYE` | 2 | 0.8 | 3.2 | no |

(The products are computed with float arithmetic by the artifact; the decimal values above are the exact products of the two read constants and may differ from the float result in the last binary digit.)

`FoodProperties.onConsume` (it is a `ConsumableListener`, see 4.3): plays the consumable's sound at the entity, source `neutral`, volume 1.0, pitch `triangle(1.0, 0.4)`; if the entity is a player, calls
`FoodData.eat(food)` (17 section 4.9) and plays `entity.player.burp` at the player, source `players`, volume 0.5, pitch `randomBetween(0.9, 1.0)`.

### 4.2 `Consumable` record

Fields: `consume_seconds` (float, default 1.6, non-negative), `animation` (`ItemUseAnimation`, default `eat`), `sound` (holder, default `entity.generic.eat`), `has_consume_particles` (boolean, default true),
`on_consume_effects` (list, default empty). Wire (component 24, 17 section 1.2): Float, animation VarInt id, sound holder (00 section 10.2), Boolean, list of consume effects (type id VarInt, 46 section 8.2, then payload).

`ItemUseAnimation` ids (enum order, read): 0 `none`, 1 `eat`, 2 `drink`, 3 `block`, 4 `bow`, 5 `trident`, 6 `crossbow`, 7 `spyglass`, 8 `toot_horn`, 9 `brush`, 10 `bundle`, 11 `spear`.

Builders: `defaultFood` = (1.6 s, eat, `entity.generic.eat`, particles true); `defaultDrink` = (1.6 s, drink, `entity.generic.drink`, particles false). `Consumable$Builder.onConsume` appends an effect; `soundAfterConsume(sound)` appends a `PlaySoundConsumeEffect`.

Derived values: `consumeTicks` = floor(consume_seconds x 20). `shouldEmitParticlesAndSounds(remaining)`: the elapsed ticks are `consumeTicks - remaining`; the effects start after the first floor(consumeTicks x 0.21875) ticks, then fire every 4 ticks: true when elapsed > floor(consumeTicks x 0.21875) **and** `remaining mod 4 == 0`.

### 4.3 Consume pipeline

1. **Start** (`Consumable.startConsuming`, on Use Item): if `canConsume` fails, the result is FAIL. `canConsume` is true unless the stack has `food` and the user is a player for whom `Player.canEat(food.can_always_eat)` is false (hunger full and the food not always edible). If `consumeTicks > 0` the entity starts using the item (`startUsingItem(hand)`) and the result is CONSUME; if it is 0 the item is consumed at once (step 3).
2. **Each tick while using** (client and server): when `shouldEmitParticlesAndSounds(remaining)` holds, `emitParticlesAndSounds(random, entity, stack, 5)` is called (particle count 5 on the ticking path, 16 at the end): volume `eat`: `nextBoolean ? 0.5 : 1.0`; pitch `eat`: `triangle(1.0, 0.2)`; `drink`: volume 0.5, pitch `randomBetween(0.9, 1.0)`; if `has_consume_particles`, `spawnItemParticles(stack, count)`; the sound is the `sound` field (an entity implementing `OverrideConsumeSound` may substitute its own); played by `LivingEntity.playSound(sound, volume, pitch)`.
3. **Finish** (`Consumable.onConsume`, when the use time elapses, server side for effects): (a) `emitParticlesAndSounds(..., 16)`; (b) for a server player: stat `item_used` for the item and criterion trigger `consume_item`; (c) every `ConsumableListener` component of the stack runs `onConsume` (`food` = 4.1, `potion_contents` = section 9.2), in component order; (d) on the server, each effect of `on_consume_effects` runs `apply(level, stack, entity)` in list order; (e) game event `drink` if the animation is `drink`, else `eat`; (f) the stack shrinks by 1 (`ItemStack.consume(1, entity)`; for a player with infinite materials nothing is lost) and the stack, or its `use_remainder` replacement, is returned.

### 4.4 Consume effects used by this part

| Effect (type, 46 section 8.2) | Payload (read) | Behaviour |
|---|---|---|
| `apply_effects` (`ApplyStatusEffectsConsumeEffect`) | list of effect instances, probability float 0..1 (default 1.0) | rolls `random.nextFloat()`; if the roll is at or above the probability the result is "not applied" and **nothing** happens; otherwise each instance is copied and `LivingEntity.addEffect` is called; returns true if any was added |
| `clear_all_effects` (`ClearAllStatusEffectsConsumeEffect`, singleton, no payload) | none | `LivingEntity.removeAllEffects` |
| `play_sound` (`PlaySoundConsumeEffect`) | sound holder | plays the sound (used by `soundAfterConsume`, not by the items of this part) |

**This table is not the complete list of consume-effect types.** The class `ConsumeEffect$Type` registers five (keys read: `apply_effects`, `remove_effects`, `clear_all_effects`, `teleport_randomly`, `play_sound`; ids 0 to 4, 46 section 8.2). The two not used by the rows of this part are `remove_effects` (class `RemoveStatusEffectsConsumeEffect`; used by `honey_bottle`, row in 25 part 8) and `teleport_randomly` (class `TeleportRandomlyConsumeEffect`; used by `chorus_fruit`, specified in 25 part 6). Their payloads and behaviour are in those parts.

Read in `ApplyStatusEffectsConsumeEffect.apply`: the effects apply exactly when the roll is strictly below the probability (roll < probability); probability 1.0 always applies and 0.0 never does.

Read in `MobEffectInstance`: the form (effect, duration, amplifier) delegates to the five-argument form with ambient false and visible true; the five-argument form passes its `visible` value also as the show-icon flag, so show icon is true as well. The form (effect, duration) uses amplifier 0; the form (effect) alone uses duration 0 and amplifier 0. Every row of the `Consumables` table in 4.5 uses the three-argument form with an explicit amplifier.

### 4.5 `Consumables` entries used by this part

Only the entries used by the rows 848 to 939 are listed. Other `Consumables` entries (`HONEY_BOTTLE`, `CHORUS_FRUIT` and the rest) are in the parts that register their items (25 part 4, 6 and 8); the effect types they use are named in the note after 4.4.

| Field | Based on | Changes | On-consume effects |
|---|---|---|---|
| `DEFAULT_FOOD` | `defaultFood` | none | none |
| `DEFAULT_DRINK` | `defaultDrink` | none | none |
| `MILK_BUCKET` | `defaultDrink` | none | `clear_all_effects` |
| `DRIED_KELP` | `defaultFood` | `consume_seconds` 0.8 | none |
| `CHICKEN` | `defaultFood` | none | `hunger` 600 ticks amplifier 0, probability 0.3 |
| `ROTTEN_FLESH` | `defaultFood` | none | `hunger` 600 ticks amplifier 0, probability 0.8 |
| `SPIDER_EYE` | `defaultFood` | none | `poison` 100 ticks amplifier 0 (probability 1.0) |
| `PUFFERFISH` | `defaultFood` | none | one effect with three instances (probability 1.0): `poison` 1200 ticks amplifier 1; `hunger` 300 ticks amplifier 2; `nausea` 300 ticks amplifier 0 |

---

## 5. Buckets

### 5.1 `BucketItem.use` (empty, water, lava; the mob buckets reuse it)

Fields: `content` (the fluid; empty for the empty bucket and for the sulfur cube bucket).

1. Ray: `Item.getPlayerPOVHitResult(level, player, fluidMode)`: from the eye position along the look vector, length `block_interaction_range` attribute (17 section 1.5: 4.5 for a player), with `ClipContext$Block.OUTLINE`. `fluidMode` is `SOURCE_ONLY` for the empty bucket and `NONE` for every other (`getFluidContext`; the mob bucket class overrides it to `NONE`, so a mob bucket ignores fluids).
2. If the ray missed, the result is PASS. If it did not hit a block, PASS.
3. Let `P` = hit block position, `F` = hit face, `N` = `P` moved one step along `F`. If `Level.mayInteract(player, P)` is false or `Player.mayUseItemAt(N, F, stack)` is false the result is FAIL (spawn protection and adventure-mode rules, 13).
4. Target position `T`: `P` if the block at `P` is a `LiquidBlockContainer` (a waterloggable block) **and** the bucket's content is water, otherwise `N`.
5. `emptyContents(player, level, T, hit)` (5.2). If it returns true: `checkExtraContent` (nothing for fluid buckets; for a mob bucket it spawns the mob, 5.4); for a server player and a non-empty content the `placed_block` trigger fires at `T`; stat `item_used`; the result is SUCCESS with the held item replaced by `ItemUtils.createFilledResult(stack, player, emptySuccessItem)` where `emptySuccessItem` = `stack` itself if the player has infinite materials (creative) else a new `bucket` stack.
6. Otherwise, if the content is empty (so this is the empty bucket, which never succeeds in step 5): the block at `P` is asked `BucketPickup.pickupBlock(player, level, P, state)` (the implementers, results and sounds are in 5.7). If the block is not a `BucketPickup` or the returned stack is empty the result is FAIL. On success: stat `item_used`; the pickup sound (an `Optional` of the block; played to the player at volume 1, pitch 1); game event `fluid_pickup` at `P`; the held item becomes `createFilledResult(stack, player, pickedStack)`; on the server the `filled_bucket` trigger fires with the picked stack; result SUCCESS.
7. A filled bucket that could not empty (step 5 false) gives FAIL.

`ItemUtils.createFilledResult(stack, player, filled, creativeKeeps = true)` (read): if `creativeKeeps` and the player has infinite materials: the filled stack is added to the inventory if the inventory does not already contain an equal one, and the original `stack` is returned unchanged. Otherwise `stack.consume(1, player)` runs (a no-op for a player with infinite materials, so in creative the stack is never emptied); if it is now empty the result is `filled`; else `filled` is added to the inventory (if it does not fit it is dropped with `Player.drop(filled, false, Prediction.PREDICTED)`) and the remaining `stack` is returned.

### 5.2 `BucketItem.emptyContents(entity, level, T, hit)`

Returns false at once if the content is not a `FlowingFluid` (the empty fluid is not).

1. `state` = block state at `T`. `canReplace` = `state.canBeReplaced(fluid)`. `sneak` = entity exists and `isShiftKeyDown`.
2. `canPlaceInside` = `canReplace`, or the block is a `LiquidBlockContainer` whose `canPlaceLiquid(entity, level, T, state, fluid)` is true.
3. The position is acceptable when `state.isAir()`, or (`canPlaceInside` and (not `sneak` or no `hit`)). If not acceptable: when `hit` is present the whole procedure is repeated once for `hit.pos` moved one step along `hit.direction` with no hit result; otherwise false.
4. **Evaporation.** If the environment attribute `water_evaporates` (dimension environment, sampled at `T`) is true and the fluid is in the fluid tag `water`: play `block.fire.extinguish` at `T`, source `blocks`, volume 0.5, pitch `2.6 + (nextFloat - nextFloat) x 0.8`; on a server level send 8 `large_smoke` particles at `(T.x, T.y, T.z)` with offsets 1.0, 1.0, 1.0 and speed 0 (randomisation mode `ALTERNATIVE`); return true (the bucket is spent, no fluid placed).
5. Else if the block is a `LiquidBlockContainer` and the content is water: `placeLiquid(level, T, state, waterSource(falling=false))`, play the empty sound, return true.
6. Else: on the **server** only, if `canReplace` and the block is not itself a liquid (`BlockState.liquid()` false), `Level.destroyBlock(T, dropResources = true)`. Then set the block at `T` to `fluid.defaultFluidState().createLegacyBlock()` with flags 11. If that fails and the old state's fluid is not a source, return false. Play the empty sound, return true.

Sound key note: `SoundEvents` registers the bucket sounds under keys with an `item.` prefix (`item.bucket.empty`, `item.bucket.empty_lava`, `item.bucket.empty_fish`, `item.bucket.fill`, `item.bucket.fill_lava`, `item.bucket.fill_powder_snow`, `item.bucket.empty_powder_snow` and so on, read); the short forms `bucket.empty` used in this document for buckets are those keys without the prefix. Other sounds in this document are written with their full registered keys (`item.bundle.insert`, `entity.cushion.place`, `entity.item.break` and so on).

Empty sound (`playEmptySound`): `bucket.empty_lava` if the fluid is in tag `lava`, else `bucket.empty`; source `blocks`, volume 1, pitch 1, at `T`; then game event `fluid_place` at `T`. The mob bucket class plays its own sound with source `neutral` instead.

### 5.3 `SolidBucketItem` (powder snow)

A `BlockItem` (placing follows the block-item rules of 29) with a place sound. After a successful `useOn` that consumes the action and the user is a player, the held stack is replaced by `BucketItem.getEmptySuccessItem` (an empty bucket, or the same stack in creative). Dispenser variant `emptyContents(T)`: succeeds only if `T` is inside the world bounds and is an empty (air) block; on the server sets `powder_snow` default state with a block update, fires `fluid_place`, plays the place sound (source `blocks`, volume 1, pitch 1). Picking powder snow back up is the powder snow block's `BucketPickup` (5.7).

### 5.4 `MobBucketItem`

Fields: entity type, fluid (water, or the empty fluid for the sulfur cube), empty sound. Differences from the plain bucket:

- `getFluidContext` is `NONE`: the ray ignores fluids.
- `emptyContents`: when the fluid is empty (sulfur cube) it only plays the empty sound and returns true (nothing placed); otherwise it runs the plain algorithm with the water fluid.
- `checkExtraContent` (called after a successful empty): on a server level, `spawn(level, stack, T)`: creates the entity with `EntityType.create` using the stack's default configuration (`createDefaultStackConfig`, so a `custom_name` on the stack applies) at `T` with spawn reason `bucket`, align true, not the "above" variant; if the entity is `Bucketable`, takes the `bucket_entity_data` compound (empty if absent), `loadFromBucketTag(copy)` then `setFromBucket(true)`; adds it (with passengers) and calls `playAmbientSound()`; then game event `entity_place` at `T`.
- `emptySound` is played at the **neutral** source.

The tag layout, the keys saved on pickup (`Bucketable.saveDefaultDataToBucketTag`: `NoAI`, `Silent`, `NoGravity`, `Glowing`, `Invulnerable`, `PersistenceRequired` only when true, `Health` always) and the per-mob keys are specified in `45-entity-nbt-7-aquatic-and-misc-mobs.md` (45 part 7) section 8 and the item-stack component form in its section 9; `custom_name` is copied from the mob to the stack on pickup.

### 5.5 Picking up a mob with a bucket (`Bucketable.bucketMobPickup`)

Called from the mob's `mobInteract` with the hand item. Succeeds when the stack is a `water_bucket` (`canBePickedUpWithBucket` default; mobs may override) and the mob is alive:
play the mob's pickup sound (volume 1, pitch 1, from the mob), create the mob's bucket stack (`getBucketItemStack`), `saveToBucketTag(stack)`, replace the held item via `createFilledResult(held, player, bucketStack, creativeKeeps = false)` (in creative this does **not** lose the water bucket: `consume(1, player)` is a no-op for infinite materials, so the stack never empties, the filled mob bucket is **always** added to the inventory (dropped with `Player.drop(filled, false, Prediction.PREDICTED)` if it does not fit) with no "already contains an equal stack" check, and the original water bucket is returned unchanged; the only difference from `creativeKeeps = true` is that the equal-stack suppression is skipped), fire `filled_bucket` for a server player, drop the leash if the mob is leashable, `discard()` the mob, result SUCCESS.

### 5.6 Milk bucket

`milk_bucket` is a plain `Item` with `consumable` = `MILK_BUCKET` (4.5) and `use_remainder` `bucket`: eating takes 32 ticks (floor(1.6 x 20)), animation `drink`, then `clear_all_effects`; the stack becomes a `bucket` (use remainder, 4.3 step 3f).

### 5.7 `BucketPickup` implementers

Interface `BucketPickup`: `pickupBlock(entity, level, pos, state)` returns an `ItemStack` (empty = nothing picked up) and `getPickupSound()` returns an optional sound. Classes that implement it (read from the class declarations in `net.minecraft.world.level.block`): `LiquidBlock`, `PowderSnowBlock`, `BubbleColumnBlock`, and the interface `SimpleWaterloggedBlock` (which extends `BucketPickup` and supplies default methods for every waterloggable block). `SpongeBlock` only calls `pickupBlock` on its neighbours (its absorption search) and does not implement it. The cauldron classes (`AbstractCauldronBlock`, `LayeredCauldronBlock`, `LavaCauldronBlock`) do not implement it, so an empty bucket used on a cauldron gets FAIL from 5.1 step 6; cauldron filling and emptying is cauldron-interaction code (24 part 7, not read here).

| Implementer | Condition | Block change | Stack returned | Sound (key, 5.2 note) |
|---|---|---|---|---|
| `LiquidBlock` | block state property `level` = 0 (a source block) | `air` with flags 11 | `water_bucket` for the water fluid, `lava_bucket` for the lava fluid (the fluid's `getBucket`) | water `item.bucket.fill`, lava `item.bucket.fill_lava` (the fluid's `getPickupSound`) |
| `LiquidBlock` | `level` not 0 (flowing) | none | empty (FAIL) | |
| `SimpleWaterloggedBlock` (default) | property `waterlogged` true | the property set to false with a block update; then, if the state that was passed in (before the change) reports that it cannot survive at the position, the block is destroyed with drops | `water_bucket` | `item.bucket.fill` |
| `SimpleWaterloggedBlock` (default) | `waterlogged` false | none | empty (FAIL) | |
| `PowderSnowBlock` | always | `air` with flags 11; on a server level level event 2001 (block break effect) at the position with the block state id | `powder_snow_bucket` | `item.bucket.fill_powder_snow` |
| `BubbleColumnBlock` | always | `air` with flags 11 | `water_bucket` | `item.bucket.fill` (the water fluid's) |

Fluid classes: `WaterFluid.getBucket` = `water_bucket` and `getPickupSound` = `item.bucket.fill`; `LavaFluid.getBucket` = `lava_bucket` and `getPickupSound` = `item.bucket.fill_lava`; the base `Fluid` default sound is absent (empty `Optional`).

Worked examples: an empty bucket aimed at a water source block (ray in `SOURCE_ONLY` mode) at position `P`: `P` becomes `air` (flags 11), the player gets `water_bucket`, `item.bucket.fill` plays. The same bucket aimed at a waterlogged slab: the slab stays and loses `waterlogged`, the player gets `water_bucket`. Aimed at a `water` block with `level` 3 (the ray ignores it in `SOURCE_ONLY` mode, so another block behind is the hit): no pickup.

---

## 6. Throwables and the eye of ender

### 6.1 `snowball` and eggs

`SnowballItem.use` and `EggItem.use` are identical except for the sound and its source:

1. Play at the player's position: snowball `entity.snowball.throw`, source `neutral`; egg `entity.egg.throw`, source `players`; volume 0.5, pitch `0.4 / (nextFloat x 0.4 + 0.8)`.
2. On a server level: spawn the projectile from the player's rotation with `Projectile.spawnProjectileFromRotation(factory, level, stack, player, y offset 0.0, power 1.5, inaccuracy 1.0)` (`PROJECTILE_SHOOT_POWER` = 1.5); stat `item_used`; `stack.consume(1, player)` (nothing is lost with infinite materials).
3. Result SUCCESS.

Both implement `ProjectileItem.asProjectile(level, position, stack, direction)` for dispensers: a `Snowball` or `ThrownEgg` at the position. Impact behaviour is in 17 section 3.15. `use_cooldown` is not set on these items (the registering code has none).

### 6.2 `ender_pearl`

Class `EnderpearlItem`, stack 16, `use_cooldown` 1.0 s (no group, keyed by the item). `use` has the same shape as the snowball (6.1) and differs only in the sound: (1) play `entity.ender_pearl.throw` at the player's position, source `neutral`, volume 0.5, pitch `0.4 / (nextFloat x 0.4 + 0.8)`; (2) on a server level spawn the projectile with `Projectile.spawnProjectileFromRotation(factory, level, stack, player, y offset 0.0, power 1.5, inaccuracy 1.0)`; (3) stat `item_used`; (4) `stack.consume(1, player)`; (5) result SUCCESS. Impact and teleport rules are in 17 section 3.15.

### 6.2a `fishing_rod` (`FishingRodItem`)

Row 876: durability 64, `enchantable` 1, `cooking_fuel`; no `use_cooldown` is set. `use(level, player, hand)` (read):

1. If the player has no active hook (`Player.fishing` is null), cast: play `entity.fishing_bobber.throw` at the player's position (`SoundEvents.FISHING_BOBBER_THROW`, source `neutral`, volume 0.5, pitch `0.4 / (nextFloat x 0.4 + 0.8)`, played on both sides, listener entity null so every player hears it). On a server level only: `lure` = `trunc(EnchantmentHelper.getFishingTimeReduction x 20)`, `luck` = `EnchantmentHelper.getFishingLuckBonus`; a `FishingHook(player, level, luck, lure)` is created and added by `Projectile.spawnProjectile(hook, level, stack)`; stat `item_used`. Both sides then call `causeUseVibration(player, ITEM_INTERACT_START)`.
2. Otherwise (a hook exists), reel in: on a server level only, `used = hook.retrieve(stack)` (an int, the durability cost computed by the hook) and `stack.hurtAndBreak(used, player, the hand's equipment slot)`. On both sides play `entity.fishing_bobber.retrieve` (source `neutral`, volume 1.0, pitch `0.4 / (nextFloat x 0.4 + 0.8)`), then `causeUseVibration(player, ITEM_INTERACT_FINISH)`.
3. The result is SUCCESS in both cases.

The reel-in cost is read in 6.2b. The rest of the hook entity (flight, bite timer, hooked-entity detection) is not read in this part (Open question 5).

### 6.2b `FishingHook.retrieve(stack)` (cost and catch)

Inputs: the owner (`getPlayerOwner`), the rod stack. Output: the int durability cost used by 6.2a step 2.

1. Returns 0 at once on a client level, when there is no owner, or when `shouldStopFishing(owner)` is true. `shouldStopFishing` is false only when the owner can interact with the level, holds a `fishing_rod` in the main or off hand, and `distanceToSqr` is at most 1024.0 (32 blocks); otherwise it discards the hook and returns true.
2. `cost` starts at 0.
3. **Hooked entity** present: the entity is pulled toward the owner (`pullEntity`), the `fishing_rod_hooked` trigger fires with an empty item list, entity event 31 is broadcast, and `cost` = 3 if the hooked entity is an `ItemEntity`, else 5.
4. **Else if the bite counter `nibble` is above 0** (a fish is biting): loot is rolled from the `fishing` loot table with parameters origin = hook position, tool = the rod, this entity = the hook, luck = `luck` (the enchantment bonus passed at cast) + `Player.getLuck` (as float), parameter set `fishing`; the trigger fires with the item list; `cost` = 1. For each item produced: an `ItemEntity` at the hook position with velocity `(dx x 0.1, dy x 0.1 + sqrt(sqrt(dx^2 + dy^2 + dz^2)) x 0.08, dz x 0.1)` where `(dx, dy, dz)` = owner position minus hook position; an `ExperienceOrb` worth `nextInt(6) + 1` at `(owner.x, owner.y + 0.5, owner.z + 0.5)`; and when the item is in tag `fishes`, the stat `fish_caught` +1.
5. If the hook is on the ground, `cost` = 2 (this overrides 1, 3 and 5).
6. The hook is discarded and `cost` is returned. With nothing hooked, no bite and not on the ground the cost is 0.

Worked example: reeling in with a fish biting while the hook floats: cost 1, one item (say a cod) thrown to the player, 1 to 6 XP. Reeling in with nothing on the line: cost 0. Reeling in a dropped item entity: cost 3.

`clock` (row 877) is registered with plain `Item` and no override: no use behaviour in the item class (its dial is an item-model property, not read here).

### 6.3 `ender_eye` (`EnderEyeItem`)

**Use on a block** (`useOn`): if the clicked block is not an `end_portal_frame` or its `eye` property is already true, PASS. On a client level SUCCESS. On the server: set `eye` true (with `Block.pushEntitiesUp`, flags 2); `updateNeighbourForOutputSignal`; shrink the stack by 1 (always, creative included, read: plain `shrink`); level event 1503 at the block; then `EndPortalFrameBlock.getOrCreatePortalShape().find(level, pos)`: if the 3 x 3 portal pattern matches, take its front-top-left corner offset by (-3, 0, -3) and for the 3 x 3 area (x, z from 0 to 2 of that corner) destroy the block with drops and set `end_portal` with flags 2; then a global level event 1038 at the corner offset (1, 0, 1). Result SUCCESS.

**Use in air** (`use`): `use duration` is 0. Ray with fluid mode `NONE`; if it hits an `end_portal_frame` block the result is PASS (so `useOn` handles it). Otherwise the player starts using the item; on a server level, `findNearestMapStructure(tag eye_of_ender_located, player block position, radius 100, skipKnownStructures false)`; if none is found the result is CONSUME (nothing thrown, nothing consumed). Otherwise an `EyeOfEnder` entity is created at `(x, y + 0.5 x height, z)` of the player, given the stack as its item, `signalTo(target)` (target as the lower corner of the found block position), game event `projectile_shoot`, added to the level; the `used_ender_eye` trigger fires; the launch sound `entity.ender_eye.launch` is played at the player (source `neutral`, volume 1.0, pitch `lerp(random, 0.33, 0.5)`, i.e. `0.33 + (0.5 - 0.33) x nextFloat` read as `Mth.lerp(nextFloat, 0.33, 0.5)`); the stack is reduced by `consume(1, player)` (a creative player does not lose the eye, unlike the `useOn` path, which uses a plain shrink) and the stat `item_used` is awarded; result SUCCESS_SERVER. Order notes: `startUsingItem` is called before the structure search, on both client and server levels. The result is SUCCESS_SERVER on a non-server level and after the server has thrown the eye; only the "no structure found" case returns CONSUME. The flight of the `EyeOfEnder` entity is in 6.3a.

### 6.3a `EyeOfEnder` entity (class `EyeOfEnder`)

State: `target` (position, absent until signalled), `life` (int), `surviveAfterDeath` (boolean), item stack (synchronised, default `ender_eye`; saved under key `Item`). The entity cannot be attacked (`hurtServer` returns false, `isAttackable` false) and has no light dependence (magic value 1.0). Constants: too-far distance 12.0, too-far signal height 8.0.

**`signalTo(t)`** (called by the item with the structure's lower block corner): `d = t - position`; `h` = horizontal length of `d`. If `h > 12.0` the target becomes `position + (d.x / h x 12.0, 8.0, d.z / h x 12.0)`, otherwise `t` itself. Then `life` = 0 and `surviveAfterDeath` = (`random.nextInt(5)` > 0), i.e. true with probability 4/5.

**`tick`** (every tick; the entity starts with zero velocity, the item sets none):

1. `next = position + deltaMovement`.
2. Server side, when `target` is present, the velocity is replaced by `steer(velocity, next, target)` (below). The client does not steer.
3. Client side only: particles from `next - 0.25 x velocity` with the velocity as particle speed: in water 4 `bubble`; otherwise one `portal` at `(x + nextDouble x 0.6 - 0.3, y - 0.5, z + nextDouble x 0.6 - 0.3)`.
4. The position is set to `next` (so the position advances by the velocity as it was before step 2).
5. Server side: `life` += 1. When `life > 80` (the 81st tick after the signal): play `entity.ender_eye.death` at the entity (volume 1.0, pitch 1.0) and discard the entity; then if `surviveAfterDeath` an `ItemEntity` holding the entity's stack is added at the entity position, else level event 2003 (the shatter effect, client side) is sent at the block position.

**`steer(velocity v, next position n, target t)`**: `d = (t.x - n.x, 0, t.z - n.z)`, `len = |d|`. `speed = hd + 0.0025 x (len - hd)` where `hd` is the horizontal length of `v` (a linear interpolation from the current horizontal speed toward the remaining distance, weight 0.0025). `vy = v.y`. If `len < 1.0`: `speed` and `vy` are both multiplied by 0.8. `dir` = +1.0 if `n.y - v.y < t.y`, else -1.0. The new velocity is `d x (speed / len)` horizontally and `vy + (dir - vy) x 0.015` vertically (double arithmetic).

Worked example: eye thrown at `(0, 65.6, 0)`, structure corner `(100, 40, 0)`: `h` = 100 > 12, so `target = (12, 65.6 + 8, 0) = (12, 73.6, 0)`. Tick 1: velocity 0, `next` = position, `hd` = 0, `len` = 12, `speed` = 0.03, `dir` = +1 (65.6 < 73.6), new velocity `(0.03, 0.015, 0)`. The eye drifts toward the target, rises and decelerates near it, and after 80 ticks drops (80% as an item, 20% shattering). (Whether the eye overshoots its target is not simulated here; the steering rule above is the whole rule read.)

---

## 7. Compass, spyglass, bundles, cushions, ink sacs, dyes, glass bottle

### 7.1 `compass` and `recovery_compass`

`CompassItem` adds three behaviours (the pointing logic itself is the client item model property, 12 and 17 section 3.14):

- `isFoil`: true if the stack has `lodestone_tracker` (otherwise the default).
- `getName`: if the stack has `lodestone_tracker` the name is the translatable `item.minecraft.lodestone_compass` instead of the item name.
- `inventoryTick` (server): if the stack has `lodestone_tracker`, replace it by `tracker.tick(level)` when the tick returns a different value (a tracker whose lodestone disappeared is cleared).
- `useOn` on a `lodestone` block: play `item.lodestone_compass.lock` (source `players`, volume 1, pitch 1) at the block; a lodestone tracker is built: `GlobalPos(level dimension, clicked pos)`, `tracked` true. If the player has infinite materials or the stack has more than one item the compass is **split**: one compass copy (`transmuteCopy(COMPASS, 1)`) receives the tracker, the original shrinks by 1 (not in creative), and the copy is added to the inventory or dropped (`Player.drop(copy, false, Prediction.PREDICTED)`); in the single-item survival case the tracker is set on the held stack itself. SUCCESS. Any other block falls through to `Item.useOn`.

`recovery_compass` is a plain `Item` with rarity uncommon; its pointing (last death position) is a client model property fed by data components not set by this registering code (17 section 3.14).

### 7.2 `spyglass`

`SpyglassItem`: use duration 1200 ticks; use animation `spyglass`; `use` plays `item.spyglass.use` to the player (volume 1, pitch 1), awards `item_used`, and starts using at once (`ItemUtils.startUsingInstantly`, result CONSUME). When the use ends by finishing (`finishUsingItem`) or by release (`releaseUsing`, returns true) it plays `item.spyglass.stop_using` at the entity. Zoom factor constant `ZOOM_FOV_MODIFIER` = 0.1 (client rendering, 12).

### 7.3 Bundles (`bundle`, 16 dyed bundles; `BundleItem`, `BundleContents`)

**Component** `bundle_contents` (`BundleContents`): an ordered list of `ItemStackTemplate`s plus a transient selected index (-1 = none). Wire: VarInt count then the list of item stack templates (the selected index is not on the wire, read: the stream codec is a list codec only). A bundle's weight is the exact fraction sum, never more than 1:

| Content | Weight of one stack of count n |
|---|---|
| an ordinary stack | n x 1 / `max_stack_size` of the stack |
| a stack that has `bundle_contents` (a bundle inside a bundle) | n x (1/16 + the inner bundle's own weight) |
| a stack with a non-empty `bees` component (beehive with bees) | n x 1 |

`canItemBeInBundle(stack)` = the stack is non-empty and `Item.canFitInsideContainerItems()` is true (`Item` returns true; `BlockItem` overrides it to return false exactly when its block is a `ShulkerBoxBlock`, so shulker boxes cannot go in a bundle; searched: every top-level class of `net/minecraft/world/item/` for a declaration of the method, only `Item` and `BlockItem` declare it; overrides outside that package were not searched, Open question 6). A contents value whose total weight exceeds 1 is invalid when decoded ("Excessive total bundle weight").

**Mutable operations** (`BundleContents$Mutable`; the inventory code works on a mutable copy and writes it back with `set`):

- `tryInsert(stack)`: refuse (0) if the stack cannot be in a bundle or its weight is an error; amount = `min(stack.count, floor((1 - currentWeight) / itemWeight))`; refuse if 0; add `amount x itemWeight` to the weight; if the bundle already holds a stack with the same item and components (only stackable items match) that stack is **removed and re-inserted at the front** with the combined count (the stack count may exceed the item's stack size here: read, `copyWithCount(old + amount)`), else a new stack of `amount` items is split off and inserted at the front (index 0). Returns the amount inserted. The front is where the player sees "most recently inserted".
- `tryTransfer(slot, player)`: the slot's stack; maximum amount from the weight; takes up to that count out of the slot (`Slot.safeTake(min..max)`) and `tryInsert`s it.
- `removeOne()`: returns null if empty. Removes the stack at the **selected index**; if the index is out of range (no selection) it removes index 0 (read: `indexIsOutsideAllowedBounds` then 0). The removed stack is copied; its weight is subtracted; the selection resets to -1.
- `toggleSelectedItem(i)`: selects `i`, or deselects (-1) if `i` is already selected or out of range.
- `getNumberOfItemsToShow` (read): `limit` = 11 if `size` > 12, else 12; `rem` = `size mod 4`; `pad` = 0 if `rem` is 0, else `4 - rem`; result = `min(size, limit - pad)`. The grid thus shows whole rows of 4, and one cell fewer than 12 when there is an overflow marker. Examples: size 5 gives min(5, 12 - 3) = 5; size 11 gives min(11, 12 - 1) = 11; size 13 gives min(13, 11 - 3) = 8 (`rem` 1, `pad` 3); size 12 gives 12.

**Click handling** (menu code calls these; `ClickAction.PRIMARY` = left click, `SECONDARY` = right click):

- `overrideStackedOnOther(bundle, slot, action, player)` (the player clicks a slot with the bundle on the cursor... the bundle is the *clicked* stack): requires `bundle_contents`. Left click with a non-empty slot stack: `tryTransfer` from the slot; sound `item.bundle.insert` if something moved else `item.bundle.insert_fail`. Right click on an **empty** slot: `removeOne()` and put it into the slot (`safeInsert`; any remainder goes back with `tryInsert`), sound `item.bundle.remove_one`. Always writes the contents back and broadcasts a menu change when it handled the click.
- `overrideOtherStackedOnMe(bundle, cursor, slot, action, player, access)` (the cursor stack is dropped on the bundle slot): left click with an **empty** cursor toggles the selection (`toggleSelectedItem(-1)`) and returns false (the click goes on); with `bundle_contents`: left click with a non-empty cursor and `slot.allowModification`: `tryInsert(cursor)`, `item.bundle.insert` or `item.bundle.insert_fail` sound; right click with an empty cursor and `allowModification`: `removeOne()` into the cursor (`item.bundle.remove_one`). Otherwise toggles the selection.
- Sounds: `item.bundle.insert` and `item.bundle.remove_one` at volume 0.8 and pitch `0.8 + 0.4 x nextFloat`; `item.bundle.insert_fail` volume 1 pitch 1; `item.bundle.drop_contents` (source `players`, at the player, volume 0.8, pitch `0.8 + 0.4 x nextFloat`).

**Use** (`use`): starts using (SUCCESS). Use duration 200 ticks, animation `bundle`. `onUseTick(remaining)` for a player: with `elapsed = 200 - remaining`: the first tick (`remaining == 200`) drops one item, and afterwards one more every 2 ticks while `remaining < 190` (so `elapsed` is at least 11) and `remaining` is even (read: the condition is `remaining == duration`, or `remaining < duration - 10` and `remaining mod 2 == 0`). The first drop after the initial one is therefore at `remaining` 188 (`elapsed` 12), not at `elapsed` 10; `TICKS_AFTER_FIRST_THROW` 10 is the strict bound `duration - 10`. Dropping (`dropContent`): if the bundle is empty nothing happens; else `removeOneItemFromBundle` (the selected stack, else the first, with the `item.bundle.remove_one` sound), the stack is dropped as an item entity by `Player.drop(stack, true)`, `item.bundle.drop_contents` plays and `item_used` is awarded. Dropped stacks keep their full count (a whole stack leaves per drop).

**Item entity destroyed**: `onDestroyed` of the bundle's item entity: the contents are cleared on the stack and every stored stack is spawned as new item entities at the same position (`ItemUtils.onContainerDestroyed`).

**Bar** (inventory display, `isBarVisible`, `getBarWidth`, `getBarColor`): visible when the weight is greater than 0; width = `min(1 + mulAndTruncate(weight, 12), 13)` pixels (`Mth.mulAndTruncate`: fraction times 12, truncated); colour `ARGB.colorFromFloat(1.0, 1.0, 0.33, 0.33)` when the weight is at least 1 (full), else `colorFromFloat(1.0, 0.44, 0.53, 1.0)`. The fullness display value for the item model is the weight as a float.

Constants: `MAX_SHOWN_GRID_ITEMS` 12 (4 x 3), `OVERFLOWING_MAX_SHOWN_GRID_ITEMS` 11, `TICKS_AFTER_FIRST_THROW` 10, `TICKS_BETWEEN_THROWS` 2, `TICKS_MAX_THROW_DURATION` 200. The tooltip image is `BundleTooltip` unless `tooltip_display` hides `bundle_contents`.

### 7.4 Cushions (`CushionItem`, entity `cushion`)

`useOn`: (1) if the player exists and the clicked block is in tag `cushion_uses_collision_shape`, the click location is recomputed by clipping that block's collision shape from the eye toward the click location (the click location moved 0.001 toward the eye, `COLLISION_SHAPE_RAYCAST_EPSILON`); if the clip hits, a new context is used. (2) The clicked face must be `up`, else FAIL. (3) Placement position: the clicked block's centre with Y replaced by the click location's Y (`Vec3.atCenterOfWithY`); the spawn box is `EntityTypes.CUSHION.getSpawnAABB(pos)`; `Cushion.canBePlacedAt(level, box)` must hold, else FAIL. (4) On a server level: no existing `Cushion` entity may intersect the box (else FAIL); the entity is created with the stack's default configuration (spawn reason `spawn_item_use`), set to `snapTo(pos, Direction.fromYRot(placeContext.rotation).toYRot(), 0)`, added, `destroyIfInFire`; sound `entity.cushion.place` (source `blocks`, volume 0.75, pitch 0.8) at the entity; game event `entity_place`; the stack shrinks by 1 (not in creative). Result SUCCESS. The entity model is in `34-entity-models-9-non-living-entities.md` (34 part 9) and the save and load keys in `45-entity-nbt-9-bosses-and-decorations.md` (45 part 9) section 10.

### 7.5 Ink sacs, glow ink sacs and dyes (`SignApplicator`)

- `ink_sac`: `tryApplyToSign`: the sign text's glowing flag is cleared (`withGlowingText(false)`); on success plays `item.ink_sac.use` (source `blocks`, volume 1, pitch 1, at the sign).
- `glow_ink_sac`: sets glowing true; sound `item.glow_ink_sac.use`.
- Dye (`DyeItem`, colour from the `dye` component): `tryApplyToSign` applies `withColor(colour)` and plays `item.dye.use` (source `blocks`); `interactLivingEntity` on a **sheep** that is alive, not sheared, and whose colour differs from the dye's: plays `item.dye.use` (source `players`) at the sheep; on the server sets the colour and shrinks the stack by 1; SUCCESS; otherwise PASS. Whether each call actually changed the sign (`SignBlockEntity.updateText` returns false when unchanged) decides the item use (block entity code, 24).

### 7.6 `glass_bottle` (`BottleItem`)

`use(level, player, hand)`:

1. Find `AreaEffectCloud` entities that are alive with owner an `EnderDragon` in the player's bounding box inflated by 2.0. If any exist: the first one's radius is reduced by 0.5; play `item.bottle.fill_dragonbreath` at the player (source `neutral`, volume 1, pitch 1); game event `fluid_pickup` at the player; a server player triggers `player_interacted_with_entity`; the bottle is turned into `dragon_breath` (`turnBottleIntoItem`: stat `item_used`, `createFilledResult(bottle, player, filled)`); SUCCESS.
2. Else ray with fluid mode `SOURCE_ONLY`. A miss or non-block gives PASS. For a block hit: `mayInteract` must be true else PASS; if the fluid at the hit position is in tag `water`: play `item.bottle.fill` (neutral, volume 1, pitch 1), game event `fluid_pickup` at the position, and the held item becomes a `potion` stack with `potion_contents` = potion `water` (`PotionContents.createItemStack(POTION, Potions.WATER)`) through `turnBottleIntoItem`; SUCCESS. Otherwise PASS.

---

## 8. Maps

### 8.1 Items

`filled_map` and the sixteen exploration map items (899 to 914) are all `MapItem` with `map_decorations` empty; they have no `map_id` until data is created. Which item is created where (cartographer trades, structure loot via the `exploration_map` loot function) is data and the engines in 19 and 26.

Statics: `IMAGE_WIDTH` = `IMAGE_HEIGHT` = 128.

`MapItem.create(level, x, z, scale, trackingPosition, unlimitedTracking)` makes a `filled_map` stack and calls `applyNewSavedData`, which sets component `map_id` to a new id: `ServerLevel.getFreeMapId()` (the next free number of the map counter, saved in the level's `idcounts` data, 07/45 sections for saved data) and stores `MapItemSavedData.createFresh(x, z, scale, tracking, unlimited, dimension)` under it (`setMapData`). The dimension is that of the creating level. `MapItem.getSavedData(stack, level)` reads `map_id` and looks the data up (null when there is no id).

`inventoryTick(stack, level, entity, slot)` (server): fetches the saved data; if the entity is a `Player` it runs `tickCarriedBy(player, stack, null)` (8.4); if the map is **not locked**, the entity is a player and the slot is a hand slot (main hand or off hand), `update(level, entity, data)` runs (8.3). Maps in other slots are not updated.

`onCraftedPostProcess(stack, level)` (after a crafting or menu result): removes `map_post_processing`; on a server level, if it was one value runs `lockMap`, if the other `scaleMap` (`MapPostProcessing` has `LOCK` as ordinal 0, id 0 and `SCALE` as ordinal 1, id 1; the item's switch maps `LOCK` to the lock-map case and `SCALE` to the scale-map case). `scaleMap`: new id from `getFreeMapId`, data `scaled()`, stored, the stack's `map_id` replaced (the old data remains for the original map). `lockMap`: new id, data `locked()`, stored, `map_id` replaced. So scaling and locking **copy** the map.

`useOn` on a block in tag `banners`: on the server, `MapItemSavedData.toggleBanner(level, pos)` on the stack's data; if it returns false the result is FAIL, else SUCCESS (the click adds or removes a banner marker). Other blocks use the default `Item.useOn`.

### 8.2 Saved data (`MapItemSavedData`)

Fields: `centerX`, `centerZ` (ints), `dimension` (resource key), `trackingPosition`, `unlimitedTracking`, `scale` (byte 0 to 4, `MAX_SCALE` 4), `colors` (128 x 128 = 16384 bytes, index `x + z x 128`), `locked`, banner markers (by string key), decorations (by string key), frame markers; constants `MAP_SIZE` 128, `HALF_MAP_SIZE` 64, `TRACKED_DECORATION_LIMIT` 256. A map pixel byte is `(base colour id << 2) | brightness id` (`MapColor.getPackedId`; brightness ids LOW 0, NORMAL 1, HIGH 2, LOWEST 3 with multipliers 180, 220, 255, 135, 24 part 1 section 8.1; base colour id 0 = no colour, transparent).

`createFresh(x, z, scale, tracking, unlimited, dimension)`: with `size = 128 << scale`: `centerX = floor((x + 64.0) / size) x size + size/2 - 64` and the same for `centerZ` with `z` (integer arithmetic after the floor; `size/2` is integer division). `scaled()` calls `createFresh` with the old `centerX` and `centerZ` as the x and z arguments and `scale + 1` clamped to [0, 4], the same flags and dimension: it recomputes the centre from the old centre with the new size (example 7), the pixels are empty and the map refills as the player carries it. `locked()` copies the data with `locked` true, all markers, decorations, the tracked count and the pixel array.

`updateColor(x, z, packed)`: if the byte at `(x, z)` already equals `packed` returns false; else `setColor` stores it, marks the rectangle dirty for every holding player and returns true.

### 8.3 `MapItem.update(level, entity, data)` (the pixel algorithm)

Runs for a player in the map's dimension (a different dimension returns at once). Let `S = 1 << scale` (blocks per pixel), `(cx, cz)` the centre.

1. Player pixel position: `px = floor(player.x - cx) / S + 64`, `pz = floor(player.z - cz) / S + 64` (**integer division truncating toward zero**).
2. Radius in pixels `r = 128 / S`; if the dimension type has a ceiling (nether-like) `r = r / 2`.
3. The `HoldingPlayer` for the player (created on demand) has its `step` incremented.
4. Columns `col` run from `px - r + 1` to `px + r - 1` inclusive. A column is processed only when `(col mod 16) == (step mod 16)` (bitwise `& 15`) or `changed` is true; when processed `changed` is first reset to false. So each call refreshes one column in sixteen across the visible width, and keeps going column after column while pixels keep changing. For **every processed column** `changed` is reset to false and `lastHeight` to 0.0 (`changed` also starts false before the first column). `lastHeight` therefore carries over only between consecutive rows of one column; each processed column starts again at row `pz - r - 1`, which is why row -1 and the rows above it prime `lastHeight` for that column.
5. Rows `row` run from `pz - r - 1` to `pz + r - 1` inclusive; a pixel is considered only when `0 <= col < 128` and `-1 <= row < 128`. Row -1 is only used to prime `lastHeight`.
6. `dist2 = (col - px)^2 + (row - pz)^2`; `edge = dist2 > (r - 2)^2`.
7. World block origin of the pixel: `x0 = (cx / S + col - 64) x S`, `z0 = (cz / S + row - 64) x S` (integer division of the centre by `S`). The chunk containing `(x0, z0)` must exist and be non-empty, else the pixel is skipped.
8. Colour sampling. Let `heightSum` (double) and `waterDepth` (int) start at 0 and `counts` be an insertion-ordered multiset of map colours.
   - **Dimension with ceiling**: `h = x0 + z0 x 231871`; `h = h x h x 31287121 + h x 11` (32-bit wrap); if bit 20 of `h` is 0 add colour `DIRT` with count 10, else colour `STONE` with count 100; `heightSum = 100.0`. (A fixed pseudo-random dirt/stone speckle: ceilinged dimensions show no terrain.)
   - **Otherwise** for each of the `S x S` blocks `(x0 + i, z0 + j)`, `i` and `j` in `[0, S)`: `y` = `WORLD_SURFACE` height of the column + 1. If `y > minY`: step down (`y = y - 1`, read the state at `y`) until the state's map colour is not `NONE` or `y` reaches `minY`. If then `y > minY` and the state has a fluid: scan downward starting at `y - 1` counting consecutive blocks while the block has a fluid (`waterDepth += 1` per block examined, stopping when `y` reaches `minY` or a non-fluid is read); the shown state is then `getCorrectStateForFluidBlock`: for a state with a fluid whose **top face is not sturdy** the fluid's legacy block state, otherwise the state unchanged. If `y <= minY` at the end the state is the default `bedrock` state. Then banners at that column are checked (`checkBanners(level, x, z)`), `heightSum += y / (S x S)` (as double), and the state's `getMapColor` is added to the multiset once.
9. `waterDepth = waterDepth / (S x S)` (integer division). The base colour is the multiset's most frequent entry (ties keep insertion order); `NONE` if empty.
10. Brightness:
    - base colour `WATER`: `v = waterDepth x 0.1 + ((col + row) & 1) x 0.2`; `HIGH` if `v < 0.5`; `LOW` if `v > 0.9`; else `NORMAL`.
    - otherwise: `v = (heightSum - lastHeight) x 4.0 / (S + 4) + (((col + row) & 1) - 0.5) x 0.4`; `HIGH` if `v > 0.6`; `LOW` if `v < -0.6`; else `NORMAL`.
11. `lastHeight = heightSum`.
12. The pixel is written only if `row >= 0`, `dist2 < r x r`, and not (`edge` and `(col + row)` even); the write is `changed |= data.updateColor(col, row, packed)` with `packed = (colour id << 2) | brightness id`. (So the rim of the disc is a checkerboard.)

The map colour of a block state is the `map colour` column of the block registry (24 part 1 section 8.1; `BlockState.getMapColor(level, pos)`).

### 8.4 Decorations and holding players (`tickCarriedBy`, `addDecoration`)

- A `HoldingPlayer` is created for a player the first time they carry the map; it starts with the data dirty (whole map region 0 to 127 both axes) and the decorations dirty, `tick` 0, `step` 0.
- `tickCarriedBy(player, stack, frame)`: (1) register the player; if the player's inventory contains no stack that is **this map** (same item type and `map_id`) the player's decoration (key = the player's plain-text name) is removed. (2) For every registered holder in list order: if the holder was removed or no longer holds the map **and** is not in an item frame context, drop the holder and its decoration; otherwise, when the carrying player is in the map's dimension and `trackingPosition` is true, `addDecoration(player type, ..., key = name, x, z, yaw)`; a player other than the ticking one who wears an item in tag `map_invisibility_equipment` (any slot except main and off hand) has the decoration removed. (3) For an **item frame** holding the map and `trackingPosition`: a `frame` decoration with key `frame-<entityId>` at the frame's block position with rotation `direction.get2DDataValue() x 90`; a stale frame marker at the same position with another entity id is removed first. (4) If the stack's `map_decorations` component names keys that the data lacks, those are added from the stack (type, x, z, rotation) the same way (the entries of structure maps; marker target).
- `addDecoration(type, level, key, worldX, worldZ, rotation, name)`: pixel offset `dx = (worldX - centerX) / (1 << scale)` and likewise `dz` (float arithmetic); `clamp(v)` = -128 if `v <= -63`, 127 if `v >= 63`, else `(byte)(int)(v x 2 + 0.5)`. For a `player` type: if `|dx|,|dz|` are within [-63, 63] the type stays `player` with rotation `calculateRotation`; else the type is `player_off_map` if both `|dx| < 320` and `|dz| < 320`, else `player_off_limits` when `unlimitedTracking`, else the decoration is dropped (removed). For other types: inside the map the given type with `calculateRotation`; outside only when `unlimitedTracking`, otherwise removed. A replaced decoration updates the tracked count when `MapDecorationType.trackCount()` and marks decorations dirty; at most 256 tracked decorations (`isTrackedCountOverLimit`).
- `calculateRotation(level, yaw)`: in the **nether** dimension: `i = (int)(gameTime / 10)`, rotation = `(i x i x 34187121 + i x 121) >> 15 & 15` (a spinning marker); otherwise `yaw'` = `yaw - 8.0` if `yaw < 0` else `yaw + 8.0`, rotation = `(int)(yaw' x 16.0 / 360.0)` as a byte.
- Player decoration type ids and the full list of decoration types: 46 section 5.6.

### 8.5 Update packet (`HoldingPlayer.nextUpdatePacket`)

Each call builds at most one `ClientboundMapItemDataPacket` (05a, 0x34): `(map id, scale, locked, decorations or none, patch or none)`. The pixel patch is sent when the data is dirty: the rectangle `[minX..maxX] x [minY..maxY]` of dirty pixels (each marked dirty widens it), `width = maxX + 1 - minX`, row-major bytes copied from the map array; after sending the dirty flag clears (the next dirty mark restarts the rectangle). The decorations are sent (the whole collection) only when decorations are dirty **and** the holder's `tick` counter (incremented each time this branch is reached with dirty decorations, post-increment) is a multiple of 5 at that moment; the dirty flag then clears. If both parts are empty no packet is sent. Packet layout is 05a; the interval to the client is the server's map-tick cadence (inferred: once per tick per holder, Open question 2).

### 8.6 `renderBiomePreviewMap` (exploration map preview)

`MapItem.renderBiomePreviewMap(level, stack)` (server level) paints the pixels of a **new** exploration map from biomes only, without terrain. Inputs: the stack's saved data (nothing happens if there is none or if its dimension differs from the level's), `S = 1 << scale`, centre `(cx, cz)`, the level's sea level `sea`. Output: pixels written with `setColor` (which also marks them dirty); pixels not written keep colour 0 (transparent).

1. **Watery grid.** For `z` and `x` in `[0, 128)` the biome is sampled at the world position `((cx / S - 64 + x) x S, sea, (cz / S - 64 + z) x S)` (integer division of the centre); `watery[x, z]` = the biome is in tag `water_on_map_outlines` (array index `z x 128 + x`).
2. **Painting.** For every `x` and `z` in `[1, 126]` (the one-pixel border of the map is never painted): `n` = number of watery cells among the 8 neighbours (the 3 x 3 block minus the centre). Start with colour `NONE` and brightness `LOWEST`, then:
   - **Cell is watery:** colour `COLOR_ORANGE`; then
     - if `n > 7` and `z` is even: brightness from `k = ((x + trunc(sin(z) x 7.0)) / 8) mod 5` (integer division and remainder truncating toward zero; `sin` is `Mth.sin`, a table lookup, see below; `z` converted to a double): `k` = 0 gives `LOW`, 1 `NORMAL`, 2 `HIGH`, 3 `NORMAL`, 4 `LOW`, anything else (a negative `k`) stays `LOWEST`. This draws the diagonal wave pattern of open water;
     - else if `n > 7` (odd `z`): colour back to `NONE` (nothing is painted);
     - else if `n > 5`: `NORMAL`; else if `n > 3`: `LOW`; else if `n > 1`: `LOW`; else (`n` is 0 or 1): `LOWEST`. (The outlines of coastlines get darker where fewer neighbours are watery.)
   - **Cell is not watery:** if `n > 0`: colour `COLOR_BROWN`, brightness `NORMAL` if `n > 3`, else `LOWEST`; if `n` = 0 the colour stays `NONE`.
   - If the colour is not `NONE`, write `(colour id << 2) | brightness id` at `(x, z)` (colour ids and brightness ids as in 8.2 and 24 part 1 section 8.1).

`Mth.sin(d)` = `SIN[(long)(d x 10430.378350470453) & 65535]` where `SIN[i]` = `(float)sin(i / 10430.378350470453)` for `i` in `[0, 65536)` (read: the table is filled by that loop).

Worked example: a pixel `(x, z) = (10, 4)` in open ocean (all 8 neighbours watery, `n` = 8): colour `COLOR_ORANGE`, `z` even, `sin(4)` = -0.7568, times 7 = -5.30, truncated -5, `k = ((10 - 5) / 8) mod 5` = 0 mod 5 = 0, brightness `LOW`. The same pixel with `z` = 5 is `NONE` (not painted). A land pixel with 2 watery neighbours: `COLOR_BROWN`, brightness `LOWEST`.

---

## 9. Potions

### 9.1 `PotionContents` (component `potion_contents`, id 53 in 17 section 1.2)

Record: `potion` (optional holder of a `Potion`), `custom_color` (optional int ARGB), `custom_effects` (list of effect instances), `custom_name` (optional string). Wire and file codec layouts: the stream codec is composite of the four fields in that order (Optional holder, Optional Int, list of `MobEffectInstance`, Optional String); the codec file keys are `potion`, `custom_color`, `custom_effects` (default empty), `custom_name`. `EMPTY` has everything absent. `new PotionContents(holder)` = potion only.

- **Effects**: `getAllEffects` = the potion's effects, then the custom effects. `forEachEffect(consumer, durationScale)` hands each effect with duration scaled: `MobEffectInstance.withScaledDuration(scale)` = duration `max(floor(duration x scale), 1)` (read in the mapping lambda; infinite or zero durations are left to `mapDuration`, the clamp to at least 1 is confirmed; the guard on infinite or zero durations in `mapDuration` was not decoded further).
- **Colour** `getColor`: `custom_color` if present, else `getColorOptional(all effects)`, else the base colour `-13083194` = `0xFF385DC6` (`BASE_POTION_COLOR`). `getColorOptional`: over the effects that are **visible** (`MobEffectInstance.isVisible`), weight `w = amplifier + 1`, sum `w x` each of red, green, blue of the effect's colour (`MobEffect.getColor`) and `sum w`; if `sum w` is 0 the result is empty, else each channel is the integer division of its sum by `sum w`, composed with `ARGB.color(r, g, b)` (opaque).
- **Name** `getName(prefix)`: translatable key `<prefix>.effect.<n>` where `n` is the `custom_name` if present, else the potion's `name()` (the string passed to `Potion` construction, which for the long and strong variants is the **base** name: `long_night_vision` has name `night_vision`), else `empty`. For `PotionItem`, the prefix is the item's description id (`item.minecraft.potion`), so the key is `item.minecraft.potion.effect.water`, `.mundane`, and so on (text is `en_us` data).
- `hasEffects`: custom effects non-empty or the potion has effects. `is(holder)`, `is(tag)`, `isPotionWithoutCustomEffects`: tests used by cauldron, recipes and brewing.
- `applyToLivingEntity(entity, scale)` (server only): `forEachEffect(scale)` then for each instance: **instantaneous** effects call `MobEffect.applyInstantaneousEffect(level, player-or-null as source, same as direct source, entity, amplifier, intensity 1.0)`; others call `LivingEntity.addEffect(instance)`.
- `onConsume(level, entity, stack, consumable)` (a `ConsumableListener`): `applyToLivingEntity(entity, stack.potion_duration_scale default 1.0)`.
- Tooltip (`addPotionTooltip`): each effect line is the effect name with `potion.withAmplifier` when amplifier above 0 and `potion.withDuration` unless `MobEffectInstance.endsWithin(20)` holds (the duration is hidden when it is 20 ticks or shorter) (the instant effects show no duration); no effects shows the static component `NO_EFFECT`, the translatable key `effect.none` styled gray; attribute modifiers of the effects are listed under `potion.whenDrank` in dark purple with blue/red styling (percentage for multiplied operations, scaled by 100). Format text is `en_us` data.

### 9.2 `PotionItem` (`potion`, field 931)

- Stack 1, `potion_contents` empty prototype, `consumable` = `DEFAULT_DRINK` (1.6 s, 32 ticks, `drink`, sound `entity.generic.drink`, no particles), `use_remainder` `glass_bottle`: drinking applies `PotionContents.onConsume` (9.1, listener step 3c) and leaves a `glass_bottle`.
- `getDefaultInstance` (creative tab, `/give` without components): a stack with `potion_contents` = potion `water`.
- `getName` uses the key of 9.1 when the stack has `potion_contents`, else the plain item name.
- `useOn`: only when the clicked face is not `down`, the clicked block is in tag `convertible_to_mud`, and the potion is `water`: play `entity.generic.splash` (blocks, 1, 1), the held item becomes a `glass_bottle` through `createFilledResult` (creative keeps the potion), on the server five `splash` particles at `(x + nextDouble, y + 1, z + nextDouble)` (count 1, no spread, speed 1.0), `item.bottle.empty` sound, game event `fluid_place`, the block becomes `mud` with a block update; SUCCESS. Otherwise PASS.
- Splash and lingering potion items (`SplashPotionItem` and `LingeringPotionItem`, fields after 939), tipped arrows and their `potion_duration_scale` (the scales are splash 1.0, lingering 0.25 and tipped arrow 0.125 as listed in 17 sections 1.2 and 3.15; the 0.5 in 17 section 3.15 is the splash throw power, not a duration scale; the registering rows are in the later parts) are not repeated here.

### 9.3 Potions (static registry `potion`, 46 entries; ids in 46 section 4.3)

Each `Potion` is (name string, effect instances). The effect id is the key of 46 section 4.1; duration in ticks, amplifier 0 unless shown. "Instant" effects (`instant_health`, `instant_damage`) are created with duration 1.

| Id | Key | Name string | Effects |
|---|---|---|---|
| 0 | `water` | water | none |
| 1 | `mundane` | mundane | none |
| 2 | `thick` | thick | none |
| 3 | `awkward` | awkward | none |
| 4 | `night_vision` | night_vision | `night_vision` 3600 |
| 5 | `long_night_vision` | night_vision | `night_vision` 9600 |
| 6 | `invisibility` | invisibility | `invisibility` 3600 |
| 7 | `long_invisibility` | invisibility | `invisibility` 9600 |
| 8 | `leaping` | leaping | `jump_boost` 3600 |
| 9 | `long_leaping` | leaping | `jump_boost` 9600 |
| 10 | `strong_leaping` | leaping | `jump_boost` 1800 amplifier 1 |
| 11 | `fire_resistance` | fire_resistance | `fire_resistance` 3600 |
| 12 | `long_fire_resistance` | fire_resistance | `fire_resistance` 9600 |
| 13 | `swiftness` | swiftness | `speed` 3600 |
| 14 | `long_swiftness` | swiftness | `speed` 9600 |
| 15 | `strong_swiftness` | swiftness | `speed` 1800 amplifier 1 |
| 16 | `slowness` | slowness | `slowness` 1800 |
| 17 | `long_slowness` | slowness | `slowness` 4800 |
| 18 | `strong_slowness` | slowness | `slowness` 400 amplifier 3 |
| 19 | `turtle_master` | turtle_master | `slowness` 400 amplifier 3; `resistance` 400 amplifier 2 |
| 20 | `long_turtle_master` | turtle_master | `slowness` 800 amplifier 3; `resistance` 800 amplifier 2 |
| 21 | `strong_turtle_master` | turtle_master | `slowness` 400 amplifier 5; `resistance` 400 amplifier 3 |
| 22 | `water_breathing` | water_breathing | `water_breathing` 3600 |
| 23 | `long_water_breathing` | water_breathing | `water_breathing` 9600 |
| 24 | `healing` | healing | `instant_health` (duration 1) |
| 25 | `strong_healing` | healing | `instant_health` amplifier 1 |
| 26 | `harming` | harming | `instant_damage` |
| 27 | `strong_harming` | harming | `instant_damage` amplifier 1 |
| 28 | `poison` | poison | `poison` 900 |
| 29 | `long_poison` | poison | `poison` 1800 |
| 30 | `strong_poison` | poison | `poison` 432 amplifier 1 |
| 31 | `regeneration` | regeneration | `regeneration` 900 |
| 32 | `long_regeneration` | regeneration | `regeneration` 1800 |
| 33 | `strong_regeneration` | regeneration | `regeneration` 450 amplifier 1 |
| 34 | `strength` | strength | `strength` 3600 |
| 35 | `long_strength` | strength | `strength` 9600 |
| 36 | `strong_strength` | strength | `strength` 1800 amplifier 1 |
| 37 | `weakness` | weakness | `weakness` 1800 |
| 38 | `long_weakness` | weakness | `weakness` 4800 |
| 39 | `luck` | luck | `luck` 6000 |
| 40 | `slow_falling` | slow_falling | `slow_falling` 1800 |
| 41 | `long_slow_falling` | slow_falling | `slow_falling` 4800 |
| 42 | `wind_charged` | wind_charged | `wind_charged` 3600 |
| 43 | `weaving` | weaving | `weaving` 3600 |
| 44 | `oozing` | oozing | `oozing` 3600 |
| 45 | `infested` | infested | `infested` 3600 |

The brewing recipes (which ingredient turns which potion into which) are the data/engine of the brewing stand (24 part 7 and the brewing engine round) and are not in this part. The `potion` tags are data (46 section 4.3).

### 9.4 Effect colours (`MobEffects`, `MobEffect.getColor`)

Each `MobEffect` is registered with a category and an integer RGB colour (the second constructor argument, returned unchanged by `getColor`). Read in `MobEffects.<clinit>`; all 20 effects used by the potions of 9.3 plus the two used by the consumables of 4.5. The ARGB result of `PotionContents.getColor` is `0xFF000000 | rgb` (opaque).

| Effect | Decimal | RGB hex | (R, G, B) |
|---|---|---|---|
| `speed` | 3402751 | `33EBFF` | 51, 235, 255 |
| `slowness` | 9154528 | `8BAFE0` | 139, 175, 224 |
| `jump_boost` | 16646020 | `FDFF84` | 253, 255, 132 |
| `strength` | 16762624 | `FFC700` | 255, 199, 0 |
| `instant_health` | 16262179 | `F82423` | 248, 36, 35 |
| `instant_damage` | 11101546 | `A9656A` | 169, 101, 106 |
| `resistance` | 9520880 | `9146F0` | 145, 70, 240 |
| `fire_resistance` | 16750848 | `FF9900` | 255, 153, 0 |
| `water_breathing` | 10017472 | `98DAC0` | 152, 218, 192 |
| `invisibility` | 16185078 | `F6F6F6` | 246, 246, 246 |
| `night_vision` | 12779366 | `C2FF66` | 194, 255, 102 |
| `weakness` | 4738376 | `484D48` | 72, 77, 72 |
| `poison` | 8889187 | `87A363` | 135, 163, 99 |
| `regeneration` | 13458603 | `CD5CAB` | 205, 92, 171 |
| `luck` | 5882118 | `59C106` | 89, 193, 6 |
| `slow_falling` | 15978425 | `F3CFB9` | 243, 207, 185 |
| `wind_charged` | 12438015 | `BDC9FF` | 189, 201, 255 |
| `weaving` | 7891290 | `78695A` | 120, 105, 90 |
| `oozing` | 10092451 | `99FFA3` | 153, 255, 163 |
| `infested` | 9214860 | `8C9B8C` | 140, 155, 140 |
| `nausea` | 5578058 | `551D4A` | 85, 29, 74 |
| `hunger` | 5797459 | `587653` | 88, 118, 83 |

Colour of every potion of 9.3 (rounded down per channel, weights `amplifier + 1`): the potions with no effect (ids 0 to 3) use the base colour `0xFF385DC6`; every single-effect potion has its effect's colour from the table (for example `healing` and `strong_healing` `F82423`, `harming` `A9656A`); `turtle_master` and `long_turtle_master` `8D82E6`; `strong_turtle_master` `8D85E6`. `health_boost` is not used here (its colour, 16284963, was read in the same class).

---

## 10. Worked examples

1. **Ids.** `bucket` is field 848, id 1128; `shears` field 915 = id 1255; `potion` field 931 = id 1271. The 16 dyes occupy ids 1199 to 1214 in dye order, so `red_dye` is 1199 + 14 = 1213 and `black_dye` is 1214. `filled_map` is 1238 and the sixteen exploration maps are 1239 to 1254, so `warm_ocean_ruins_map` is 1254.
2. **Drinking milk.** Use Item with a `milk_bucket`: `canConsume` true (no `food`), `consumeTicks` = floor(1.6 x 20) = 32. During the use, sound events at elapsed > floor(32 x 0.21875) = 7 with `remaining mod 4 == 0`: remaining 24, 20, 16, 12, 8, 4 (elapsed 8 to 28). Remaining 0 also satisfies `mod 4 == 0` but is never tested: `ItemStack.onUseTick` is called with the current remaining value (32 on the first tick, down to 1 on the last) and the counter is decremented afterwards; when the decrement reaches 0 (server side, and the item not use-on-release) `completeUsingItem` runs, whose step 3(a) plays the final burst instead. After 32 ticks: `clear_all_effects` runs, the game event is `drink`, the bucket is replaced by a `bucket` (use remainder). Creative: the stack count is unchanged.
3. **Dried kelp.** `consume_seconds` 0.8 gives 16 ticks; threshold floor(16 x 0.21875) = 3; sound events at remaining 12, 8, 4 (elapsed 4, 8, 12); remaining 0 is never reached by the tick (see example 2), the finish step covers it. Food: 1 nutrition, saturation 0.6.
4. **Pufferfish.** Eating applies one `apply_effects` effect with probability 1.0 and the three instances: poison 1200 ticks amplifier 1, hunger 300 ticks amplifier 2, nausea 300 ticks amplifier 0, plus 1 nutrition and 0.2 saturation.
5. **Water bucket on a waterlogged-capable block.** Player right-clicks the top of a waterloggable slab holding a `water_bucket`: ray hit block `P` is a `LiquidBlockContainer` and the content is water, so `T = P`. `canPlaceLiquid` true: `placeLiquid` waterlogs the slab, sound `bucket.empty`, the bucket becomes `bucket` (a survival player), `item_used` +1.
6. **Water bucket in the nether.** Dimension with `water_evaporates` true: no water is placed; `block.fire.extinguish` plays at volume 0.5 with pitch between 1.8 and 3.4 (2.6 +/- 0.8), 8 `large_smoke` particles; the bucket is emptied. 
7. **Map centre.** `MapItem.create(level, 1000, -200, scale 1, ...)`: `size = 256`; `centerX = floor(1064 / 256) x 256 + 128 - 64 = 4 x 256 + 64 = 1088`; `centerZ = floor((-200 + 64) / 256) x 256 + 64 = -1 x 256 + 64 = -192`. Scaling that map once more (cartography) gives scale 2 and `size = 512`: `centerX` is recomputed from the **old centre** (1088, -192): `floor(1152 / 512) = 2`, `2 x 512 + 256 - 64 = 1216`; `centerZ`: `floor(-128 / 512) = -1`, `-512 + 192 = -320`.
8. **Map pixel update.** Scale 0, centre (0, 0), player at (10.7, 70, -5.2) in the overworld: `S = 1`, `px = floor(10.7)/1 + 64 = 74`, `pz = floor(-5.2) + 64 = 58`, `r = 128`. A call with `step = 10` processes columns `col` with `col & 15 == 10` (and following columns while pixels change) within `[-53, 201]` clipped to `[0, 127]`. Pixel (74, 58): `x0 = (0 + 74 - 64) x 1 = 10`, `z0 = -6`; `dist2` is 0 so the pixel is not on the rim. If the top block is stone (colour `STONE`, id 11) and its height equals the height of the previously processed pixel, `v = 0 x 4.0 / 5 + (((74 + 58) & 1) - 0.5) x 0.4 = -0.2`, which is neither above 0.6 nor below -0.6, so brightness `NORMAL` and the packed byte is (11 << 2) | 1 = 45. (A height step of +1 would give `v` of about 0.6, a boundary value; implementations must use double arithmetic as the artifact does.)
9. **Nether-style map** (`hasCeiling`): the pixel at world (20, 5): `h = 20 + 5 x 231871 = 1159375`; `h x h` in 32-bit arithmetic then `x 31287121 + h x 11`; bit 20 decides dirt (x10) or stone (x100): the primary colour is the more frequent one, so a stone pixel when bit 20 is 1 and a dirt pixel when 0 (`r` is halved, so only a radius of 64 pixels around the player updates at scale 0).
10. **Bundle weights.** A bundle holds 3 `ender_pearl` (stack 16: 3/16) and 64 `cobblestone` (64/64 = 1) -> insertion of the cobblestone would stop earlier: with weight 3/16 held, `floor((1 - 3/16) / (1/64)) = floor(52) = 52` cobblestone can be added. An empty bundle placed inside a bundle weighs 1/16; with its own contents of weight w it weighs 1/16 + w. Removing with a selection of index 2 removes the stack at index 2; with no selection index 0 (the most recently inserted stack).
11. **Potion colour.** `PotionContents` with potion `turtle_master` and no custom colour: weights are `amplifier + 1`: slowness amplifier 3 weight 4, resistance amplifier 2 weight 3; the colour is `(4 x slowness_rgb + 3 x resistance_rgb) / 7` per channel with integer division (the effect colours are in 9.4: slowness `0x8BAFE0` = (139, 175, 224), resistance `0x9146F0` = (145, 70, 240); red = (4 x 139 + 3 x 145) / 7 = 991 / 7 = 141, green = (4 x 175 + 3 x 70) / 7 = 910 / 7 = 130, blue = (4 x 224 + 3 x 240) / 7 = 1616 / 7 = 230, so the colour is (141, 130, 230) = `0xFF8D82E6`). `long_turtle_master` has the same amplifiers and therefore the same colour; `strong_turtle_master` (slowness amplifier 5, weight 6; resistance amplifier 3, weight 4) gives (141, 133, 230) = `0xFF8D85E6`. A potion with one effect has the colour of that effect (the weight cancels).
12. **Dragon breath.** Glass bottle used with an ender-dragon `AreaEffectCloud` within 2 blocks: the cloud's radius shrinks by 0.5 (a radius of 0.5 or less is reduced to 0 or negative; the cloud's own tick handles removal, entity code), the bottle becomes `dragon_breath`.
13. **Compass on a lodestone.** A stack of 3 compasses, survival: one compass is split off with `lodestone_tracker((overworld, lodestone pos), tracked true)`, the stack becomes 2, the lodestone compass goes to the inventory or is dropped; a stack of 1 survival compass gets the tracker in place.

---

## 11. Validation

An implementation of this part is checked against the following statements.

1. Registry: with the field order of section 3 and the collections of section 1, `bucket` is 1128, `water_bucket` 1129, `milk_bucket` 1134, `compass` 1151, `spyglass` 1188, `filled_map` 1238, `woodland_mansion_map` 1240, `potion` 1271, `ender_eye` 1278 and `glistering_melon_slice` 1279 (the 1128 for `bucket` and the offset 280 were re-derived from the `Items` field declarations in this round, section 1); the entry after the range, `chicken_spawn_egg` (field 940), is 1280 (offset 280 before the range plus 4 collections x 15 extra items inside it = 340, so id = field + 340 for fields 940 onward until the next collection).
2. Every row of section 3 builds the component set listed, on top of the defaults of 2.2; `max_stack_size` is 16 for `bucket`, `snowball`, the three eggs, `ender_pearl`, `cushion`, `straw_bed`; 1 for filled buckets, `milk_bucket`, `bundle`, `spyglass`, `cake`, beds, `potion`; 64 otherwise (including `filled_map`).
3. Consuming `milk_bucket` takes 32 ticks, `dried_kelp` 16 ticks, everything else with `defaultFood` or `defaultDrink` 32 ticks.
4. A water bucket used where `water_evaporates` is true never places water, always empties.
5. An empty bucket used on a water source with the ray in `SOURCE_ONLY` mode picks the water up (the `BucketPickup` of the block gives `water_bucket`); on a flowing-water block (non-source) the ray ignores it.
6. A creative player keeps their stack with every bucket interaction, picking a mob up with a water bucket included; in that case they also receive the filled mob bucket even if the inventory already holds an equal one (5.5).
7. Fish buckets are not edible: `consumable` is absent.
8. Bundle: inserted amount never makes the weight exceed 1 (exact fractions, never floats); `removeOne` takes the selected stack or index 0.
9. Map: for the same inputs the packed pixel byte equals `(colour id << 2) | brightness id`, brightness decisions are exactly the thresholds 0.5, 0.9 (water) and 0.6, -0.6 (land); only a hand-held map updates.
10. Potions: `PotionContents.getColor` returns -13083194 for water and for mundane/thick/awkward (no effects), and the weighted mean for others: `0xFFF82423` for `healing`, `0xFF33EBFF` for `swiftness`, `0xFF8D82E6` for `turtle_master`, `0xFF8D85E6` for `strong_turtle_master` (9.4).

---

## 12. Open questions

1. **Registry id arithmetic.** The field counts and collection counts were re-derived from the `Items` declarations (section 1) and agree with the table, but the resulting ids were not compared with 46 section 2.1 or with an extraction output. Statement 1 of section 11 gives ids after the range as `field + 340` (280 + 4 collections x 15 extra items).
2. **Map update cadence.** How often `nextUpdatePacket` is polled per player (once per tick for each holder in `ServerPlayer` tick code) was not traced.
3. **Map tooltip and `map_id` display,** the structure-map item names and the exploration-map loot function's use of `map_decorations` are in 26 and the `en_us` data and were not read here. When the loot function or trade calls `renderBiomePreviewMap` was not read either (19 and 26).
4. **Game rule and attribute reads** used by `Player.mayUseItemAt`, `Level.mayInteract` (spawn protection, adventure mode) were not read here (13 covers the player abilities).
5. **`FishingHook` entity (narrowed).** The retrieve cost, catch loot call, XP and fish stat are read in 6.2b. Not read: flight and water physics, the bite timer (how `nibble`, `lure` and `luck` set the wait times), hooked-entity detection, and the fishing loot table contents (data, 26).
6. **`canFitInsideContainerItems` overrides outside `net/minecraft/world/item/`** (7.3) were not searched; the `EyeOfEnder` entity type's size, tracking range and update interval (registered in `EntityTypes`) were not read; the sign of the `Either` Boolean on the wire (2.4, true = Constant) was inferred, not read from the encode path.
