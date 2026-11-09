# Item registry, part 4: boats, technical blocks, materials, tools, food, armor and signs (ids 975 to 1127)

| Item | Value |
|---|---|
| Covers | The rows of registry ids 975 to 1127 of the item registry (153 items, `Items` statements 695 to 847): the 22 `BoatItem` entries (`oak_boat` to `bamboo_chest_raft`), the four technical block items (`structure_block`, `jigsaw`, `test_block`, `test_instance_block`), `turtle_helmet`, the two scutes, `wolf_armor`, `flint_and_steel`, `bowl`, `apple`, `bow`, `arrow`, the materials from `coal` to `netherite_scrap`, the 35 tools and weapons from `wooden_sword` to `netherite_hoe` (ids, keys and stack sizes only), `stick`, `mushroom_stew`, `string`, `feather`, `gunpowder`, `wheat_seeds`, `wheat`, `bread`, the 28 humanoid armor pieces, `flint`, the pork items, `painting`, the two golden apples, the 13 signs and the 13 hanging signs. Also the engines whose code lives in these item classes: boat item use (pointer), game-master placement, armor attribute generation, wolf armor, turtle helmet tick, the consumable (eating) timeline, sign and hanging sign placement and the sign text components |
| Does not cover | Ids 0 to 974 and 1128 onward (siblings: part 1 [25-item-registry-1-model-and-blocks-a.md](25-item-registry-1-model-and-blocks-a.md) for the shared model, part 3 [25-item-registry-3-blocks-c-and-utility.md](25-item-registry-3-blocks-c-and-utility.md) for ids 456 to 974, part 5 [25-item-registry-5-buckets-maps-potions-misc.md](25-item-registry-5-buckets-maps-potions-misc.md) from id 1128). Tool, weapon, damage and attribute tables (17 §2). Data rows the extraction tool copies (recipes, loot tables, tags, `context_int_provider`, trim materials, equipment assets, item models, language) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for lambda and bootstrap targets) and of data files in the jar (`unzip -p`), with no execution. Class, method and field names in backticks say where a fact was read. Values not read are marked "(inferred)" or "(recalled, not verified)" and listed in the Open questions |
| Status | Round RS5, part 4 of 8 (design map Part 5 GAP-2, Part 6 row RS5) |

"25 part 1 §n" (written "25-1 §n" below, where 25-1 always names this sibling and not a section of 25) means section n of part 1 (the shared model: id rule, helpers, `Item.Properties` builders, the 13 default
components, `Foods`, `Consumables`, the data-driven fuel and compost components, the row schema). "17 §n" is
[17-tools-weapons-and-combat.md](17-tools-weapons-and-combat.md); "29 §n" is
[29-block-updates-and-placement.md](29-block-updates-and-placement.md); "24 part 3" is
[24-block-registry-3-signs-doors-redstone.md](24-block-registry-3-signs-doors-redstone.md); "44 part 8" and "44 part 9" are
[44-residual-mob-questions-8-vehicles-and-projectiles.md](44-residual-mob-questions-8-vehicles-and-projectiles.md) and
[44-residual-mob-questions-9-end-bosses-decorations.md](44-residual-mob-questions-9-end-bosses-decorations.md); "46 §n" is
[46-registry-ids.md](46-registry-ids.md). Nothing the siblings state is repeated; this document adds only rows and the
behaviour of the classes named above.

Data versus code (design map R7): the registry rows, item classes, builders and the algorithms below are code and are
specified completely. Burn times, compost chances, trim materials, equipment assets, recipes (including the dyeing of
leather armor), tags and item models are data (22) and are named by key only.

## Contents

1. Scope: statement numbers versus ids
2. What this part adds to the shared model
3. Boats
4. Technical block items, scutes, wolf armor, turtle helmet, flint and steel, bowl, apple, bow, arrow
5. Materials and trim
6. Tools and weapons
7. Stick, mushroom stew, string, feather, gunpowder, seeds, wheat, bread; flint, pork, painting, golden apples
8. Humanoid armor
9. Signs and hanging signs
10. Eating: the consumable timeline
11. Fuel and compost keys used in this range
12. Worked examples
13. Validation
14. Open questions

---

## 1. Scope: statement numbers versus ids

The brief names the range "695 to 847". Those are **statement numbers** of `Items.<clinit>` (the order of the `putstatic`
instructions, 25-1 §2.2), counting the 35 collection statements as one statement each. The **registry ids** of the same
statements are higher, because 24 collections register several items per statement (25-1 §2.3): each of the 10
`WeatheringCopperCollection` statements before this range adds 7 extra items and each of the 14 `ColorCollection` statements adds 15.

    id = statement number + 10 x 7 + 14 x 15 = statement number + 280      (for every statement of this range)

Statement numbers are **0-based**: the first `putstatic` of `Items.<clinit>` is statement 0, `elytra` is 694 and `oak_boat` is 695. A reader counting
`putstatic` instructions from 1 gets 696 for `oak_boat` and would infer an offset of 279; the offset is 280 with 0-based numbers (id = 0-based statement number + 280).

No collection statement lies inside the range, so the offset is constant. The range is therefore:

| Boundary | Statement | Id | Key |
|---|---|---|---|
| First | 695 | **975** | `oak_boat` |
| Last | 847 | **1127** | `warped_hanging_sign` |
| Previous row (part 3, last) | 694 | 974 | `elytra` |
| Next row (part 5, first) | 848 | 1128 | `bucket` |

The anchor ids of the brief map to: `turtle_helmet` statement 721 = id 1001; `apple` 727 = 1007; `bow` 728 = 1008; `coal` 730 =
1010; `mushroom_stew` 781 = 1061; `wheat_seeds` 785 = 1065; `leather_helmet` 788 = 1068; `copper_helmet` 792 = 1072;
`netherite_boots` 815 = 1095; `oak_sign` 822 = 1102; `oak_hanging_sign` 835 = 1115. The offset check: the harness collection
of 25-1 §2.3 ends at id 965 and the registry has 9 more rows to `elytra` (966 to 974), so 975 follows. Every id in this
document is an id; every table row gives the id. Implementations must use ids on the wire (04 §5, 46 §3).

## 2. What this part adds to the shared model

25-1 §6 (builders), §7 (common components), §8 (foods, consumables) and §9 (fuel, compost) apply unchanged. Facts that
25-1 does not give and these rows need:

### 2.1 Data component types used here (id, name; layouts in 17 §1.2 unless given)

The id is the registration order of `DataComponents.<clinit>` (122 types, read again this round and equal to 17 §1.2 and 46 §8.1). Spot-checked again in the fix round against the registration order: ids 1, 2, 3, 12, 16, 21, 23, 24, 25, 27, 31, 32, 33, 44, 64, 78, 83, 84, 85 all match the names in this table.

| Id | Name | Used by | Layout and notes |
|---|---|---|---|
| 1 | `max_stack_size` | all | VarInt (64 by default, 25-1 §7.1) |
| 2, 3 | `max_damage`, `damage` | tools, armor, `turtle_helmet`, `wolf_armor`, `flint_and_steel`, `bow` | VarInt each (17 §1.3) |
| 12 | `rarity` | chainmail, game-master items, `enchanted_golden_apple` | enum VarInt (common 0, uncommon 1, rare 2, epic 3) |
| 16 | `attribute_modifiers` | tools, armor, `wolf_armor` | 17 §1.3; armor entries in section 8.2 |
| 21 | `enchantment_glint_override` | `enchanted_golden_apple` | Boolean |
| 23, 24 | `food`, `consumable` | foods | 17 §1.2; defaults 25-1 §8; timeline section 10 |
| 25 | `use_remainder` | `mushroom_stew` | an item stack template (the item left behind) |
| 27 | `damage_resistant` | netherite items, `netherite_ingot`, `netherite_scrap` | 17 §1.3 |
| 31, 32, 33 | `enchantable`, `equippable`, `repairable` | armor, tools, `bow` | 17 §1.2 |
| 44 | `villager_food` | `bread` | record of one int (the villager food points, 4 for `bread`); wire layout not read (VarInt inferred) |
| 64 | `provides_trim_material` | nine materials of section 5 | a trim material holder (a key in the data registry `trim_material`, 23); wire not read |
| 78 | `block_state` | `test_block` | map of block property name to value; `BlockItemStateProperties` (29 §9.6 step 6.1) |
| 83 | `break_sound` | all (default `item.break`), `wolf_armor` (wolf armor break) | sound holder |
| 84, 85 | `compostable`, `cooking_fuel` | section 11 | records of provider references; layouts in section 11 |
| 118, 119 | `sign_text_front`, `sign_text_back` | all 26 sign items | `SignText`, section 9.3 |
| 120 | `waxed` | (never in a prototype) | Unit; copied onto a placed sign (section 9.3) |

### 2.2 Row columns

Rows use the schema of 25-1 §10. "Fuel" is the `cooking_fuel` burn-time key (`cooking/time_<key>`, the speed multiplier
key is always `cooking/speed_default`, 25-1 §9); `-` means no `cooking_fuel`. "Max stack" is the prototype value. An item
that has `max_damage` always has max stack 1 (the `durability` builder, and the validator of 25-1 §6.2).

## 3. Boats

Ids 975 to 996, statements 695 to 716. Each is registered by `registerItem(ItemIds.<KEY>, lambda, Properties)`; the
lambda constructs `BoatItem(entityType, properties)`. Properties of every row: `cookingFuel(cooking/time_boats)` then
`stacksTo(1)`; nothing else (no rarity, no durability, no food). Key and entity type key are equal (`oak_boat` item gives
entity type `oak_boat`; chest variants likewise; `bamboo_raft` and `bamboo_chest_raft` give the raft entity types of the same
names). The entity type ids and sizes are 21 §2; boat entity physics and models are 44 part 8 §3 and 34 part 8.

| Id | Key | Entity type | Max stack | Fuel (burn-time key) |
|---|---|---|---|---|
| 975 | `oak_boat` | `oak_boat` | 1 | boats |
| 976 | `oak_chest_boat` | `oak_chest_boat` | 1 | boats |
| 977 | `spruce_boat` | `spruce_boat` | 1 | boats |
| 978 | `spruce_chest_boat` | `spruce_chest_boat` | 1 | boats |
| 979 | `birch_boat` | `birch_boat` | 1 | boats |
| 980 | `birch_chest_boat` | `birch_chest_boat` | 1 | boats |
| 981 | `jungle_boat` | `jungle_boat` | 1 | boats |
| 982 | `jungle_chest_boat` | `jungle_chest_boat` | 1 | boats |
| 983 | `acacia_boat` | `acacia_boat` | 1 | boats |
| 984 | `acacia_chest_boat` | `acacia_chest_boat` | 1 | boats |
| 985 | `cherry_boat` | `cherry_boat` | 1 | boats |
| 986 | `cherry_chest_boat` | `cherry_chest_boat` | 1 | boats |
| 987 | `dark_oak_boat` | `dark_oak_boat` | 1 | boats |
| 988 | `dark_oak_chest_boat` | `dark_oak_chest_boat` | 1 | boats |
| 989 | `pale_oak_boat` | `pale_oak_boat` | 1 | boats |
| 990 | `pale_oak_chest_boat` | `pale_oak_chest_boat` | 1 | boats |
| 991 | `mangrove_boat` | `mangrove_boat` | 1 | boats |
| 992 | `mangrove_chest_boat` | `mangrove_chest_boat` | 1 | boats |
| 993 | `poplar_boat` | `poplar_boat` | 1 | boats |
| 994 | `poplar_chest_boat` | `poplar_chest_boat` | 1 | boats |
| 995 | `bamboo_raft` | `bamboo_raft` | 1 | boats |
| 996 | `bamboo_chest_raft` | `bamboo_chest_raft` | 1 | boats |

Order rule: for each wood in the order oak, spruce, birch, jungle, acacia, cherry, dark_oak, pale_oak, mangrove, poplar,
bamboo, the plain boat is followed by its chest variant (22 = 11 x 2; the eleventh wood is the bamboo raft).

Class behaviour: `BoatItem.use` is specified in 44 part 8 (the fluid-including pick ray, the entity-in-the-way PASS rule, creating the
boat at the hit location with the player's yaw, FAIL when its box collides, `ENTITY_PLACE`, consuming one item, the
`item_used` statistic). One construction detail read here and not in 44 part 8: the boat is created through
`EntityType.create(level, SPAWN_ITEM_USE)`, `setInitialPos(x, y, z)` of the hit location and, on a server level, the entity
type's default stack configuration is applied with the held stack (a `custom_name` or entity-data component of the stack is
copied onto the new boat; the component list is `EntityType.createDefaultStackConfig`, not traced: Open question 7).

## 4. Technical block items, scutes, wolf armor, turtle helmet, flint and steel, bowl, apple, bow, arrow

### 4.1 Game-master block items (ids 997 to 1000)

| Id | Key | Class | Max stack | Extra |
|---|---|---|---|---|
| 997 | `structure_block` | `GameMasterBlockItem` | 64 | rarity epic |
| 998 | `jigsaw` | `GameMasterBlockItem` | 64 | rarity epic |
| 999 | `test_block` | `GameMasterBlockItem` | 64 | rarity epic; `block_state` mode=start |
| 1000 | `test_instance_block` | `GameMasterBlockItem` | 64 | rarity epic |

All four are `GameMasterBlockItem` (a `BlockItem`) with `rarity(epic)`. `getPlacementState` returns null (so the placement
fails, 29 §9.6 step 4) unless the context's player is non-null **and** `Player.canUseGameMasterBlocks()` is true; the other rules
are `BlockItem`'s. A null player (a dispenser) therefore cannot place them. `test_block`'s prototype has `block_state`
= the empty property map with `mode` set to `start` (`TestBlock.MODE`, value `TestBlockMode.START`), which is applied to the
placed block by 29 §9.6 step 6.1. The blocks are in 24; the op-only block entity data rule is 29 §9.6 step 6.2. The creative inventory
shows these items only to game-master players (creative tabs: not specified here, Open question 8).

### 4.2 Remaining rows of ids 1001 to 1011

| Id | Key | Class | Max stack | Components beyond the common set |
|---|---|---|---|---|
| 1001 | `turtle_helmet` | `Item` | 1 | `humanoidArmor(TURTLE_SCUTE, HELMET)` (section 8): max damage 25 x 11 = 275 (`damage` 0), `enchantable` 9, `repairable` item tag `repairs_turtle_helmet`, equippable head slot, equip sound `ARMOR_EQUIP_TURTLE` |
| 1002 | `turtle_scute` | `Item` | 64 | none |
| 1003 | `armadillo_scute` | `Item` | 64 | none |
| 1004 | `wolf_armor` | `Item` | 1 | `wolfArmor(ARMADILLO_SCUTE)` (section 4.4) |
| 1005 | `flint_and_steel` | `FlintAndSteelItem` | 1 | `durability(64)`; behaviour 17 §3.3 |
| 1006 | `bowl` | `Item` | 64 | fuel `wood_items_extra_small` |
| 1007 | `apple` | `Item` | 64 | `food` apple (4, saturation 2.4), `consumable` default food; compostable `medium` |
| 1008 | `bow` | `BowItem` | 1 | fuel `wood_items_small`; `durability(384)`; `enchantable(1)`; behaviour 17 §3.9 |
| 1009 | `arrow` | `ArrowItem` | 64 | none (class below) |
(Ids 1010 `coal` and 1011 `charcoal` belong to section 5 and are listed only there; the brief groups them with the bow.)

`ArrowItem` (a `ProjectileItem`): `createArrow(level, ammoStack, shooter, weaponStack)` builds an `Arrow` entity from a copy of the
ammo stack with count 1 and the weapon stack; `asProjectile(level, position, stack, direction)` (the dispenser path) builds an `Arrow` at the
given position from a copy with count 1 and no weapon. The shooting arithmetic is 17 §3.9; the entity is 44 part 8.

### 4.3 Items whose key differs from the block (see 25-1 §4.3)

`string` (id 1062) and `wheat_seeds` (id 1065) are block-linked items registered through `registerItem(BlockItemId, ...)`
with the lambda `createBlockItemWithCustomItemName(block)`: a plain `BlockItem` whose properties use the **item** description prefix, so the
name key is `item.minecraft.string` / `item.minecraft.wheat_seeds` and not `block.minecraft.tripwire` / `block.minecraft.wheat`.
The pairs read in `BlockItemIds` are (`BlockItemId` constant, block key, item key): (`TRIPWIRE`, `tripwire`, `string`) and (`WHEAT_CROP`, `wheat`, `wheat_seeds`); the constant for the seeds is named `WHEAT_CROP`, not for `wheat`, and the item key stays `wheat_seeds`.
`Item.BY_BLOCK` maps the placed block (`tripwire`, `wheat`) to these items, which is how pick-block and similar reverse lookups find them.

### 4.4 `wolf_armor` (id 1004)

`Properties.wolfArmor(ArmorMaterials.ARMADILLO_SCUTE)` sets, in this order: durability = `ArmorType.BODY.getDurability(material.durability)`
= 16 x 4 = 64; `attribute_modifiers` = `material.createAttributes(BODY)` (section 8.2: armor 11, toughness 0, no knockback entry);
`repairable` = item tag `repairs_wolf_armor` (data: `armadillo_scute`); `equippable` = slot BODY, equip sound `ARMOR_EQUIP_WOLF`, asset
`armadillo_scute` (equipment asset key), allowed entities = {`wolf`}, `can_be_sheared` true, shearing sound `ARMOR_UNEQUIP_WOLF`
(a direct sound holder), the builder's other defaults (section 8.1); `break_sound` = `WOLF_ARMOR_BREAK`; `stacksTo(1)`. It
sets **no** `enchantable` component: unlike humanoid armor, wolf armor cannot be enchanted at the table (17 §6.5), and the `damage`
component is present (0) because `durability` was called. The item tag `cauldron_can_remove_dye` lists `wolf_armor` (data), so a cauldron cleans
a dyed one; the dyeing recipe is data (section 8.3).

### 4.5 Turtle helmet effect

Not in the item class. `Player.tick` (read) runs, every tick, a check: when the player's eyes are **not** in water
(`isEyeInFluid(water)` false) and the helmet is worn, `turtleHelmetTick` adds the effect `water_breathing` with duration 200 ticks,
amplifier 0, ambient false, show particles false, show icon true (constructor arguments `(effect, 200, 0, false, false, true)`, read). Because
the effect is re-added every tick with a fixed duration of 200, a worn helmet keeps `water_breathing` at 200 ticks while out of the water
and the effect then counts down from 200 after the eyes enter the water, giving 10 seconds (200 ticks / 20 ticks per second, arithmetic on the read constant). The merge rule of an effect added while the same effect is already active (`MobEffectInstance` merge) was not read and nothing here relies on it: the duration is stated only for the first add and for the re-add each tick (Open question 13). `Player.isEquipped(item)` (read) loops `EquipmentSlot.VALUES` in order; for each slot it takes the stack in that slot (`getItemBySlot`),
reads its `equippable` component, and returns true when the stack is the given item, the component is present and the component's `slot` is
the very slot being visited (reference comparison); otherwise it continues, and returns false after the last slot. So the helmet counts only when worn in the head slot, not when held or carried elsewhere.

## 5. Materials and trim

Ids 1010 to 1024. All are class `Item`.

| Id | Key | Class | Max stack | Extra components |
|---|---|---|---|---|
| 1010 | `coal` | `Item` | 64 | fuel coal |
| 1011 | `charcoal` | `Item` | 64 | fuel coal |
| 1012 | `diamond` | `Item` | 64 | `provides_trim_material` diamond |
| 1013 | `emerald` | `Item` | 64 | `provides_trim_material` emerald |
| 1014 | `lapis_lazuli` | `Item` | 64 | `provides_trim_material` lapis |
| 1015 | `quartz` | `Item` | 64 | `provides_trim_material` quartz |
| 1016 | `amethyst_shard` | `Item` | 64 | `provides_trim_material` amethyst |
| 1017 | `raw_iron` | `Item` | 64 | none |
| 1018 | `iron_ingot` | `Item` | 64 | `provides_trim_material` iron |
| 1019 | `raw_copper` | `Item` | 64 | none |
| 1020 | `copper_ingot` | `Item` | 64 | `provides_trim_material` copper |
| 1021 | `raw_gold` | `Item` | 64 | none |
| 1022 | `gold_ingot` | `Item` | 64 | `provides_trim_material` gold |
| 1023 | `netherite_ingot` | `Item` | 64 | fire_resistant; `provides_trim_material` netherite |
| 1024 | `netherite_scrap` | `Item` | 64 | fire_resistant |

Rules: `provides_trim_material` is set through `delayedHolderComponent`, so the value is resolved against the loaded
`trim_material` registry (23); trim material rows are data (the 11 files `amethyst`, `copper`, `diamond`, `emerald`, `gold`, `iron`, `lapis`, `netherite`,
`quartz`, `redstone`, `resin`; `redstone` and `resin_brick` belong to other parts). `fire_resistant` is the `damage_resistant`
component for the damage type tag `is_fire` (25-1 §6.4). Raw materials (`raw_iron`, `raw_copper`, `raw_gold`) and `amethyst_shard` have no other component. The item tag
`trim_materials` (data) lists the nine of this range plus `redstone` and `resin_brick`.

## 6. Tools and weapons

Ids 1025 to 1059: seven materials in the order wooden, copper, stone, golden, iron, diamond, netherite, each with sword,
shovel, pickaxe, axe, hoe in that order (note: copper comes before stone). Class `Item` for all (the item behaviour is the
components, 25-1 §5.1). Stack size is 1 (the material's `durability`). The numbers (durability, attack damage, attack speed, mining
speed, enchantability, repair ingredient, mining rules, block transformers, per-kind builder arguments) are in 17 §2.1 to §2.3 and §1.4.
Registering code reads the same argument pairs as 17 §2.2 and §2.3 (spot-checked this round: `iron_axe` 6.0 and -3.1, `stone_hoe` -1.0 and
-2.0, `netherite_hoe` -4.0 and 0.0, `wooden_shovel` 1.5 and -3.0, `copper_axe` 7.0 and -3.2); every pair matches.

| Id | Key | Builder | Max stack | Extra |
|---|---|---|---|---|
| 1025 | `wooden_sword` | `sword` | 1 | fuel wood_items_large |
| 1026 | `wooden_shovel` | `shovel` | 1 | fuel wood_items_large |
| 1027 | `wooden_pickaxe` | `pickaxe` | 1 | fuel wood_items_large |
| 1028 | `wooden_axe` | `axe` | 1 | fuel wood_items_large |
| 1029 | `wooden_hoe` | `hoe` | 1 | fuel wood_items_large |
| 1030 | `copper_sword` | `sword` | 1 | none |
| 1031 | `copper_shovel` | `shovel` | 1 | none |
| 1032 | `copper_pickaxe` | `pickaxe` | 1 | none |
| 1033 | `copper_axe` | `axe` | 1 | none |
| 1034 | `copper_hoe` | `hoe` | 1 | none |
| 1035 | `stone_sword` | `sword` | 1 | none |
| 1036 | `stone_shovel` | `shovel` | 1 | none |
| 1037 | `stone_pickaxe` | `pickaxe` | 1 | none |
| 1038 | `stone_axe` | `axe` | 1 | none |
| 1039 | `stone_hoe` | `hoe` | 1 | none |
| 1040 | `golden_sword` | `sword` | 1 | none |
| 1041 | `golden_shovel` | `shovel` | 1 | none |
| 1042 | `golden_pickaxe` | `pickaxe` | 1 | none |
| 1043 | `golden_axe` | `axe` | 1 | none |
| 1044 | `golden_hoe` | `hoe` | 1 | none |
| 1045 | `iron_sword` | `sword` | 1 | none |
| 1046 | `iron_shovel` | `shovel` | 1 | none |
| 1047 | `iron_pickaxe` | `pickaxe` | 1 | none |
| 1048 | `iron_axe` | `axe` | 1 | none |
| 1049 | `iron_hoe` | `hoe` | 1 | none |
| 1050 | `diamond_sword` | `sword` | 1 | none |
| 1051 | `diamond_shovel` | `shovel` | 1 | none |
| 1052 | `diamond_pickaxe` | `pickaxe` | 1 | none |
| 1053 | `diamond_axe` | `axe` | 1 | none |
| 1054 | `diamond_hoe` | `hoe` | 1 | none |
| 1055 | `netherite_sword` | `sword` | 1 | fire_resistant |
| 1056 | `netherite_shovel` | `shovel` | 1 | fire_resistant |
| 1057 | `netherite_pickaxe` | `pickaxe` | 1 | fire_resistant |
| 1058 | `netherite_axe` | `axe` | 1 | fire_resistant |
| 1059 | `netherite_hoe` | `hoe` | 1 | fire_resistant |

Only the five wooden tools carry a fuel component (`wood_items_large`); the other 30 never burn.

## 7. Row groups between the families

### 7.1 Ids 1060 to 1067

| Id | Key | Class / kind | Max stack | Components beyond the common set |
|---|---|---|---|---|
| 1060 | `stick` | `Item` | 64 | fuel dry_plants |
| 1061 | `mushroom_stew` | `Item` | 1 | `food` mushroom_stew, `consumable` default food, `use_remainder` bowl |
| 1062 | `string` | `BlockItem` (tripwire) | 64 | item-prefix name (section 4.3) |
| 1063 | `feather` | `Item` | 64 | none |
| 1064 | `gunpowder` | `Item` | 64 | none |
| 1065 | `wheat_seeds` | `BlockItem` (wheat) | 64 | compostable low; item-prefix name (section 4.3) |
| 1066 | `wheat` | `Item` | 64 | compostable medium |
| 1067 | `bread` | `Item` | 64 | `food` bread, `villager_food` 4, compostable medium_high |

`mushroom_stew` is the only stackable-1 food of the range without durability: it calls `stacksTo(1)`, `food(Foods.MUSHROOM_STEW)` (default food
consumable) and `usingConvertsTo(bowl)`. Eating it replaces the stack with a `bowl` (section 10.4). `bread` additionally sets
`villagerFood(4)`: villagers treat it as 4 food points (villager behaviour: 19 §24, 44-3). `stick` is a plain `Item` with fuel only.

### 7.2 Ids 1096 to 1101

| Id | Key | Class | Max stack | Components beyond the common set |
|---|---|---|---|---|
| 1096 | `flint` | `Item` | 64 | none |
| 1097 | `porkchop` | `Item` | 64 | `food` porkchop |
| 1098 | `cooked_porkchop` | `Item` | 64 | `food` cooked_porkchop |
| 1099 | `painting` | `HangingEntityItem` (painting) | 64 | none |
| 1100 | `golden_apple` | `Item` | 64 | `food` golden_apple, `consumable` golden_apple |
| 1101 | `enchanted_golden_apple` | `Item` | 64 | rarity rare; `food` enchanted_golden_apple; `consumable` enchanted_golden_apple; `enchantment_glint_override` true |

`painting` is `HangingEntityItem(PAINTING)`; its use (variant selection and survival) is specified in the placement paragraphs of 44 part 9. Note
`HangingEntityItem.mayPlace`: the clicked face must be horizontal (not vertical) and `Player.mayUseItemAt(pos, face, stack)` must be true;
the item action returns `FAIL` when `mayPlace` is false, `CONSUME` when no painting variant fits, else creates the entity,
applies the default stack configuration, and succeeds only if the entity `survives()` (play the placement sound, `ENTITY_PLACE`,
add the entity, shrink the stack by 1; result SUCCESS; when it does not survive: CONSUME). Foods: 25-1 §8.2; consumables 25-1 §8.3
(values re-read this round and equal): `golden_apple` effects regeneration 100 ticks amplifier 1 and absorption 2400 ticks amplifier 0;
`enchanted_golden_apple` regeneration 400/1, resistance 6000/0, fire_resistance 6000/0, absorption 2400/3. The constructor taking a list
of instances gives probability **1.0** (read: the argument is the literal 1.0; this closes 25-1 Open question 4), and an instance is applied
when `nextFloat() < probability` (the comparison read: strictly less), so probability 1.0 always applies.

## 8. Humanoid armor

### 8.1 Builder, types and equippable defaults

`humanoidArmor(material, type)` (25-1 §6.4) in the order read: `durability(type.getDurability(material.durability))`;
`attributes(material.createAttributes(type))`; `enchantable(material.enchantmentValue)`; `equippable` = `Equippable.builder(type slot)`
with `setEquipSound(material.equipSound)` and `setAsset(material.assetId)`, built; `repairable(material.repairIngredient tag)`.
The rarity, if any, is applied after the call by the row (`chainmail`: uncommon; fire resistance: netherite).

`ArmorType` (read): helmet slot head, unit durability 11, name `helmet`; chestplate chest, 16, `chestplate`; leggings legs, 15, `leggings`;
boots feet, 13, `boots`; body slot body, 16, `body`. Durability = unit x material multiplier.

`Equippable.Builder` defaults (read): equip sound `ARMOR_EQUIP_GENERIC`; no asset id; no camera overlay; no allowed-entity restriction;
`dispensable` true; `swappable` true; `damage_on_hurt` true; `equip_on_interact` false; `can_be_sheared` false; shearing sound
`SHEARS_SNIP`. Record codec field names: `slot`, `equip_sound`, `asset_id`, `camera_overlay`, `allowed_entities`, `dispensable`, `swappable`,
`damage_on_hurt`, `equip_on_interact`, `can_be_sheared`, `shearing_sound`.

### 8.2 `ArmorMaterial.createAttributes(type)`

Inputs: the material's defense map (value per type, absent = 0), toughness, knockback resistance, and the type. Output: an
`attribute_modifiers` list built in this order, all in the slot group of the type's slot (`EquipmentSlotGroup.bySlot`) and all with
the **same modifier id** `minecraft:armor.<type name>` (for example `minecraft:armor.chestplate`):

1. attribute `armor`, `add_value` operation, amount = the defense value of the type;
2. attribute `armor_toughness`, `add_value`, amount = the toughness (added even when 0.0);
3. attribute `knockback_resistance`, `add_value`, amount = the knockback resistance, **only when it is greater than 0**. The resistance is stored as a 32-bit float constant (netherite: `0.1f`) and widened to a double (a float-to-double conversion) when the modifier is built, so the wire amount (a double) is **0.10000000149011612**, not exactly 0.1; reproduce it by widening the float 0.1. Toughness (3.0, 2.0) is exactly representable and unaffected.

So every piece has two entries, and the four netherite pieces have three. The damage formula that consumes the sums is 17 §4.5.

### 8.3 Materials (read from `ArmorMaterials.<clinit>`; same values as 17 §2.5)

| Material | Durability multiplier | Boots / leggings / chestplate / helmet / body defense | Enchantability | Toughness | Knockback res. | Repair item tag (data) | Equipment asset key | Equip sound field |
|---|---|---|---|---|---|---|---|---|
| `LEATHER` | 5 | 1 / 2 / 3 / 1 / 3 | 15 | 0 | 0 | `repairs_leather_armor` (`leather`) | `leather` | `ARMOR_EQUIP_LEATHER` |
| `COPPER` | 11 | 1 / 3 / 4 / 2 / 4 | 8 | 0 | 0 | `repairs_copper_armor` | `copper` | `ARMOR_EQUIP_COPPER` |
| `CHAINMAIL` | 15 | 1 / 4 / 5 / 2 / 4 | 12 | 0 | 0 | `repairs_chain_armor` (`iron_ingot`) | `chainmail` | `ARMOR_EQUIP_CHAIN` |
| `IRON` | 15 | 2 / 5 / 6 / 2 / 5 | 9 | 0 | 0 | `repairs_iron_armor` | `iron` | `ARMOR_EQUIP_IRON` |
| `GOLD` | 7 | 1 / 3 / 5 / 2 / 7 | 25 | 0 | 0 | `repairs_gold_armor` | `gold` | `ARMOR_EQUIP_GOLD` |
| `DIAMOND` | 33 | 3 / 6 / 8 / 3 / 11 | 10 | 2.0 | 0 | `repairs_diamond_armor` | `diamond` | `ARMOR_EQUIP_DIAMOND` |
| `TURTLE_SCUTE` | 25 | 2 / 5 / 6 / 2 / 5 | 9 | 0 | 0 | `repairs_turtle_helmet` (`turtle_scute`) | `turtle_scute` | `ARMOR_EQUIP_TURTLE` |
| `NETHERITE` | 37 | 3 / 6 / 8 / 3 / 19 | 15 | 3.0 | 0.1f (float; wire double 0.10000000149011612, 8.2) | `repairs_netherite_armor` | `netherite` | `ARMOR_EQUIP_NETHERITE` |
| `ARMADILLO_SCUTE` (wolf) | 4 | 3 / 6 / 8 / 3 / 11 | 10 (unused: no `enchantable` set) | 0 | 0 | `repairs_wolf_armor` (`armadillo_scute`) | `armadillo_scute` | `ARMOR_EQUIP_WOLF` |

The argument order of the defense map (boots, leggings, chestplate, helmet, body) is the order of 17 §2.5, which the five constants of
every material follow in the bytecode. Only `turtle_helmet` uses `TURTLE_SCUTE` (helmet defense 2). The equip sound event keys were read from `SoundEvents.<clinit>` (each is a registered sound event of the default namespace; 46 §14 holds the id table):

| Field | Key string |
|---|---|
| `ARMOR_EQUIP_LEATHER` | `item.armor.equip_leather` |
| `ARMOR_EQUIP_COPPER` | `item.armor.equip_copper` |
| `ARMOR_EQUIP_CHAIN` | `item.armor.equip_chain` |
| `ARMOR_EQUIP_IRON` | `item.armor.equip_iron` |
| `ARMOR_EQUIP_GOLD` | `item.armor.equip_gold` |
| `ARMOR_EQUIP_DIAMOND` | `item.armor.equip_diamond` |
| `ARMOR_EQUIP_TURTLE` | `item.armor.equip_turtle` |
| `ARMOR_EQUIP_NETHERITE` | `item.armor.equip_netherite` |
| `ARMOR_EQUIP_WOLF` | `item.armor.equip_wolf` |
| `ARMOR_UNEQUIP_WOLF` | `item.armor.unequip_wolf` |
| `WOLF_ARMOR_BREAK` | `item.wolf_armor.break` |
| `ARMOR_EQUIP_GENERIC` (builder default) | `item.armor.equip_generic` |

Dyeing: **no leather armor item has a dye component or tag in its prototype.** Dyed armor is produced by the recipe type `crafting_dye` (data:
`recipe/leather_helmet_dyed.json` has `dye` = item tag `dyes`, `group` = `dyed_armor`, `target` and `result` = `leather_helmet`, one such recipe per
piece), which sets the `dyed_color` component (id 47) on the result; the item tag `cauldron_can_remove_dye` (data) names the pieces a water cauldron
cleans (the four leather pieces, `leather_horse_armor`, `wolf_armor`). The tint on the model is 43. The engine of `crafting_dye` is for the recipe round
(design map RS7).

### 8.4 Rows

The turtle helmet (id 1001) is **not** in this table: it is a section 4.2 row with max damage 25 x 11 = 275. Ids 1068 to 1095 in the order leather, copper, chainmail, iron, diamond, golden, netherite (note: copper before chainmail, golden after diamond), each
helmet, chestplate, leggings, boots. Class `Item`; max stack 1; Max damage is multiplier x unit durability (8.1).

| Id | Key | Max damage (durability) | Extra |
|---|---|---|---|
| 1068 | `leather_helmet` | 55 | none |
| 1069 | `leather_chestplate` | 80 | none |
| 1070 | `leather_leggings` | 75 | none |
| 1071 | `leather_boots` | 65 | none |
| 1072 | `copper_helmet` | 121 | none |
| 1073 | `copper_chestplate` | 176 | none |
| 1074 | `copper_leggings` | 165 | none |
| 1075 | `copper_boots` | 143 | none |
| 1076 | `chainmail_helmet` | 165 | rarity uncommon |
| 1077 | `chainmail_chestplate` | 240 | rarity uncommon |
| 1078 | `chainmail_leggings` | 225 | rarity uncommon |
| 1079 | `chainmail_boots` | 195 | rarity uncommon |
| 1080 | `iron_helmet` | 165 | none |
| 1081 | `iron_chestplate` | 240 | none |
| 1082 | `iron_leggings` | 225 | none |
| 1083 | `iron_boots` | 195 | none |
| 1084 | `diamond_helmet` | 363 | none |
| 1085 | `diamond_chestplate` | 528 | none |
| 1086 | `diamond_leggings` | 495 | none |
| 1087 | `diamond_boots` | 429 | none |
| 1088 | `golden_helmet` | 77 | none |
| 1089 | `golden_chestplate` | 112 | none |
| 1090 | `golden_leggings` | 105 | none |
| 1091 | `golden_boots` | 91 | none |
| 1092 | `netherite_helmet` | 407 | fire_resistant |
| 1093 | `netherite_chestplate` | 592 | fire_resistant |
| 1094 | `netherite_leggings` | 555 | fire_resistant |
| 1095 | `netherite_boots` | 481 | fire_resistant |

Other components: `enchantable` (material value, 8.3), `repairable` (tag, 8.3), `equippable` (8.1 with the material's asset and sound), `attribute_modifiers`
(8.2). Piglin behaviour toward gold armor uses the item tag `piglin_safe_armor` (the four golden pieces; data). The tag `trimmable_armor` is the
union of the head, chest, leg and foot armor tags (data); trims (the `trim` component and its application) have no dedicated document in docs/protocol/ at the time of writing (no NN section covers the `trim` component; see Open questions); cross-reference one when it exists.

## 9. Signs and hanging signs

### 9.1 Rows

Standing sign items, ids 1102 to 1114, statements 822 to 834. Registered by `registerBlock(BlockItemIds.<WOOD>_SIGN, Blocks.<WOOD>_SIGN, factory, properties)`;
the factory creates `StandingAndWallBlockItem(sign block, wall sign block, Direction.DOWN, properties)`; properties: `cookingFuel(cooking/time_wood_items_large)`
(not for crimson and warped), `stacksTo(16)`, `signText()`. There is no `SignItem` class in this version: the sign-specific behaviour is in the blocks (24 part 3) and in the
block-entity component copy (9.3).

| Id | Key | Wall block | Max stack | Fuel |
|---|---|---|---|---|
| 1102 | `oak_sign` | `oak_wall_sign` | 16 | wood_items_large |
| 1103 | `spruce_sign` | `spruce_wall_sign` | 16 | wood_items_large |
| 1104 | `birch_sign` | `birch_wall_sign` | 16 | wood_items_large |
| 1105 | `jungle_sign` | `jungle_wall_sign` | 16 | wood_items_large |
| 1106 | `acacia_sign` | `acacia_wall_sign` | 16 | wood_items_large |
| 1107 | `cherry_sign` | `cherry_wall_sign` | 16 | wood_items_large |
| 1108 | `dark_oak_sign` | `dark_oak_wall_sign` | 16 | wood_items_large |
| 1109 | `pale_oak_sign` | `pale_oak_wall_sign` | 16 | wood_items_large |
| 1110 | `mangrove_sign` | `mangrove_wall_sign` | 16 | wood_items_large |
| 1111 | `poplar_sign` | `poplar_wall_sign` | 16 | wood_items_large |
| 1112 | `bamboo_sign` | `bamboo_wall_sign` | 16 | wood_items_large |
| 1113 | `crimson_sign` | `crimson_wall_sign` | 16 | - |
| 1114 | `warped_sign` | `warped_wall_sign` | 16 | - |

Hanging sign items, ids 1115 to 1127, statements 835 to 847. The factory creates `HangingSignItem(ceiling block, wall block, properties)`; properties: `cookingFuel(cooking/time_hanging_signs)`
(not for crimson and warped), `stacksTo(16)`, `signText()`.

| Id | Key | Wall block | Max stack | Fuel |
|---|---|---|---|---|
| 1115 | `oak_hanging_sign` | `oak_wall_hanging_sign` | 16 | hanging_signs |
| 1116 | `spruce_hanging_sign` | `spruce_wall_hanging_sign` | 16 | hanging_signs |
| 1117 | `birch_hanging_sign` | `birch_wall_hanging_sign` | 16 | hanging_signs |
| 1118 | `jungle_hanging_sign` | `jungle_wall_hanging_sign` | 16 | hanging_signs |
| 1119 | `acacia_hanging_sign` | `acacia_wall_hanging_sign` | 16 | hanging_signs |
| 1120 | `cherry_hanging_sign` | `cherry_wall_hanging_sign` | 16 | hanging_signs |
| 1121 | `dark_oak_hanging_sign` | `dark_oak_wall_hanging_sign` | 16 | hanging_signs |
| 1122 | `pale_oak_hanging_sign` | `pale_oak_wall_hanging_sign` | 16 | hanging_signs |
| 1123 | `mangrove_hanging_sign` | `mangrove_wall_hanging_sign` | 16 | hanging_signs |
| 1124 | `poplar_hanging_sign` | `poplar_wall_hanging_sign` | 16 | hanging_signs |
| 1125 | `bamboo_hanging_sign` | `bamboo_wall_hanging_sign` | 16 | hanging_signs |
| 1126 | `crimson_hanging_sign` | `crimson_wall_hanging_sign` | 16 | - |
| 1127 | `warped_hanging_sign` | `warped_wall_hanging_sign` | 16 | - |

The woods are, in order: oak, spruce, birch, jungle, acacia, cherry, dark_oak, pale_oak, mangrove, poplar, bamboo, crimson, warped (the same order as in every other wood family). The block ids and states of the sign blocks are in 24 part 3.

### 9.2 Placement (`StandingAndWallBlockItem.getPlacementState` and `canPlace`)

Inputs: the placement context (player, clicked position `P`, `getNearestLookingDirections()` of 29 §9.5), the standing block, the wall block, the attachment direction `A`
(DOWN for standing signs, UP for hanging signs; `HangingSignItem` passes UP to the superclass).

1. `wallState` = the wall block's `getStateForPlacement(context)` (may be null). The result starts null.
2. Take the nearest looking directions in order. For each direction `d`: skip it if `d` is the opposite of `A`. Otherwise the candidate is the standing block's
   `getStateForPlacement(context)` when `d` equals `A`, else `wallState`. If the candidate is not null and `canPlace(level, candidate, P)` is true, the result is the
   candidate and the loop stops.
3. If the result is not null and `level.isUnobstructed(result, P, CollisionContext.empty())` is true, return it; otherwise null (placement fails, 29 §9.6 step 4).

`canPlace(level, state, P)` of `StandingAndWallBlockItem` is `state.canSurvive(level, P)`. `HangingSignItem` overrides it: when the candidate's block is a `WallHangingSignBlock`, the answer is
false unless `WallHangingSignBlock.canPlace(state, level, P)` is true; for any other candidate (the ceiling block) it is the superclass rule (`canSurvive`).

`WallHangingSignBlock.canPlace(state, level, P)` (read): let `f` be the state's `facing`, `cw` = clockwise of `f`, `ccw` = counter-clockwise of `f`. True when
`canAttachTo(level, state, P + cw, ccw)` or `canAttachTo(level, state, P + ccw, cw)`, where `canAttachTo(level, state, pos, dir)` looks at the block state `N` at `pos`:
if `N` is in the block tag `wall_hanging_signs`, the answer is whether `N`'s `facing` has the **same axis** as the new sign's `facing` (a chain of wall hanging signs);
otherwise the answer is `N.isFaceSturdy(level, pos, dir, SupportType.FULL)`. The wall hanging sign's `canSurvive` is not overridden (24 part 3 Open question 6).

`StandingAndWallBlockItem.registerBlocks` maps both the standing and the wall block to the item in `Item.BY_BLOCK`.

### 9.3 Sign text components

A sign item's prototype has `sign_text_front` and `sign_text_back` both `SignText.EMPTY`. After placement, 29 §9.6 step 6.3 (`applyComponentsFromItemStack`) calls the block
entity's `applyImplicitComponents`: the sign's front text = the stack's `sign_text_front` (default `SignText.EMPTY`), back text likewise, and `waxed` = the stack has the component `waxed`.
Breaking and pick-block run the reverse (`collectImplicitComponents`: front, back, and `waxed` only when waxed), so a sign keeps its text in its dropped item.

`SignText` (read): four lines (`messages`, text components), four filtered lines (`filtered_messages`, a lenient optional field: when absent they equal the messages),
`color` (a dye colour, default `black`) and `has_glowing_text` (Boolean). `SignText.EMPTY` has four empty components (both lists), `black`, false. NBT field names: `messages`,
`filtered_messages`, `color`, `has_glowing_text`; the NBT codec accepts exactly 4 entries in each list (a list of another size is rejected). Network layout (component stream codec,
fixed-size list of 4, then the dye colour stream codec, then a Boolean): 4 text components, 4 filtered components, the colour, the glow Boolean (field order read from
the composite). Tooltip labels `sign.front_text` and `sign.back_text` (gray) are language keys.

## 10. Eating: the consumable timeline

Applies to every row with `consumable` (apples, bread, stew, pork, golden apples). Values read from `Consumable`, `Consumable$Builder`, `Consumables`, `ItemStack`, `Item` and
`LivingEntity`. The wire form of `food` and `consumable` is 17 §1.2; `FoodData.eat` and the hunger constants are 17 §4.9 and 25-1 §8.1.

### 10.1 Start (`Item.use` -> `Consumable.startConsuming(entity, stack, hand)`)

1. `canConsume(entity, stack)`: when the stack has `food` **and** the entity is a player, the result is `player.canEat(food.can_always_eat)`; otherwise true.
   `Player.canEat(always)` is true when the player's abilities have `invulnerable`, or `always` is true, or `FoodData.needsFood()` is true.
   If false: result `FAIL`.
2. `consumeTicks()` = `trunc(consume_seconds x 20)` (float multiply, then truncate): 1.6 s gives 32. If it is > 0: `entity.startUsingItem(hand)` and the result is `CONSUME`.
3. Otherwise (0 ticks) the consumption completes at once (`onConsume`, section 10.3) and the result is `CONSUME` with the held stack replaced by the returned stack.

`startUsingItem` sets the remaining use ticks to `Item.getUseDuration` = `consumeTicks` for a consumable (25-1 §5.1).

### 10.2 Each tick (`LivingEntity.updateUsingItem`)

With `r` = the remaining use ticks before this tick: call `ItemStack.onUseTick(level, entity, r)`; then decrement `r`; when the decremented value is 0, on the server, and the stack does not
use "use on release", call `completeUsingItem` (which runs `ItemStack.finishUsingItem` and section 10.3). `onUseTick` for a consumable calls `Consumable.shouldEmitParticlesAndSounds(r)` and, when true,
`emitParticlesAndSounds(random, entity, stack, 5)`. Let `T` = `consumeTicks` and `W` = `trunc(T x 0.21875)`. `shouldEmitParticlesAndSounds(r)` is true when **both** `T - r > W` (more than `W` ticks elapsed) and
`r mod 4 = 0`.

### 10.3 Emission (`emitParticlesAndSounds(random, entity, stack, count)`) and completion (`onConsume`)

Random draws, in this order: (1) `nextBoolean`: if true value `a` = 0.5 else 1.0; (2) `b` = `triangle(1.0, 0.2)` (centre 1.0, spread 0.2); (3) `d` = `randomBetween(0.9, 1.0)`; (the literal 0.5 is also used).
Volume = 0.5 if the animation is `DRINK` else `a`; pitch = `d` if the animation is `DRINK` else `b`. If `has_consume_particles`: spawn `count` item particles of the stack at the entity. Play the sound
(the item's own override sound if the item implements `OverrideConsumeSound`, else the consumable's `sound` holder) at the entity with that volume and pitch. (Note: the eat sound of a food is also the sound of the consumable;
`FoodProperties.onConsume` plays it again at completion, 25-1 §8.1.)

`Consumable.onConsume(level, entity, stack)` (completion), in order:
1. `emitParticlesAndSounds(random, entity, stack, 16)`.
2. For a `ServerPlayer`: award the stat `item_used` for the item, trigger the `consume_item` criterion with the stack.
3. For every component of the stack that implements `ConsumableListener` (the `food` record is one; 25-1 §8.1 gives its effect: sound, `FoodData.eat`, burp): call its `onConsume`.
4. On the server only: apply each entry of `on_consume_effects` in list order (`ConsumeEffect.apply(level, stack, entity)`; the result is ignored).
5. Emit the game event `drink` when the animation is `DRINK`, else `eat`.
6. `stack.consume(1, entity)` (nothing removed when the entity has infinite materials).

After `Item.finishUsingItem`, `ItemStack.finishUsingItem` runs `applyAfterUseComponentSideEffects`: the `use_remainder` and `use_cooldown` components, in that order of reading.

### 10.4 `use_remainder` and `use_cooldown` after use

`UseRemainder.convertIntoRemainder(stack, originalCount, hasInfiniteMaterials, onExtraCreated)`: the remainder is created from the template (`convertInto`) when the entity
does not have infinite materials and the stack has fewer items than before; if the used stack is now empty the result is the remainder stack; otherwise the remainder is handed to the
`onExtraCreated` callback (the player receives it or it is dropped) and the stack stays. (Read, branch by branch: 1 infinite materials returns the used stack unchanged; 2 a count at or above the original count returns it unchanged; 3 otherwise the remainder is created from the item-stack template; 4 an empty used stack returns the remainder; 5 otherwise the callback receives the remainder and the used stack is returned.) `mushroom_stew` has stack size 1, so eating it always leaves a `bowl` in the hand.

## 11. Fuel and compost keys used in this range

Component layouts: `cooking_fuel` (85) holds a burn time (an integer provider reference) and a speed multiplier (a float provider reference); `compostable` (84) holds one integer provider
reference (`layers`). A reference is "either a constant integer or a provider key" (`ResolvableInt` is an either of a `Constant` coded as a 4-byte integer and a `Reference` holding a
`context_int_provider` key; the stream codec of `Either` is not traced, Open question 2). The item builders always store a **reference**.

Keys used by this range (data values re-read in this round from `data/minecraft/context_int_provider/<key>.json`: each burn-time key is a `div` of `left` by a conditional factor, and each compost key is a `number_dispatcher` returning 1 when the composter `level` is 0, otherwise a `weighted_list` of 1 and 0 with the weights given below; 25-1 §9 gives the evaluation rule `left / factor`, factor 1 normally, 2 in a smoker or blast furnace):

| Key | `left` (ticks in a furnace; half in smoker and blast furnace) | Rows |
|---|---|---|
| `cooking/time_boats` | 1200 | 22 boats |
| `cooking/time_wood_items_large` | 200 | 5 wooden tools, 11 signs (oak to bamboo) |
| `cooking/time_wood_items_small` | 300 | `bow` |
| `cooking/time_wood_items_extra_small` | 100 | `bowl` |
| `cooking/time_hanging_signs` | 800 | 11 hanging signs (oak to bamboo) |
| `cooking/time_coal` | 1600 | `coal`, `charcoal` |
| `cooking/time_dry_plants` | 100 | `stick` |

Compost keys: `compostable/low` (`wheat_seeds`: 30 percent to raise the level when the composter is not empty; weights 30 / 70), `compostable/medium` (`apple`, `wheat`: weights 65 / 35),
`compostable/medium_high` (`bread`: weights 85 / 15); each returns 1 unconditionally when the composter's `level` is 0 (the first item always counts). The composter engine is a block behaviour
(24 family documents, not repeated).

## 12. Worked examples

1. **Ids.** (Statements are 0-based, section 1.) `oak_boat`: statement 695, id 695 + 280 = 975. `bamboo_chest_raft`: statement 716, id 996. `wheat_seeds`: statement 785, id 1065. `warped_hanging_sign`: statement 847, id 1127.
2. **Iron chestplate** (id 1081): durability 15 x 16 = 240; max stack 1; `enchantable` 9; `repairable` item tag `repairs_iron_armor`; equippable chest slot, equip sound `ARMOR_EQUIP_IRON`, asset `iron`, dispensable,
   swappable, `damage_on_hurt` true; attribute entries (chest slot group, id `minecraft:armor.chestplate`): `armor` +6, `armor_toughness` +0.0; no knockback entry. Netherite chestplate (id 1093): +8, +3.0 and a third entry
   `knockback_resistance` +0.10000000149011612 (the float 0.1f widened to a double, 8.2); durability 37 x 16 = 592; fire resistant.
3. **Wolf armor** (id 1004): durability 4 x 16 = 64; one `armor` entry +11 in the `body` group with id `minecraft:armor.body`, one `armor_toughness` +0; no `enchantable`; `stacksTo(1)`.
4. **Mushroom stew eaten** (id 1061): nutrition 6, saturation 6 x 0.6 x 2 = 7.2, not always edible; consume 1.6 s: `T` = 32 ticks, `W` = trunc(32 x 0.21875) = 7. Remaining ticks passed to `onUseTick` run from 32 down to 1 (the call receives the value before the decrement; the first call has r = 32, which is tested and fails because 32 - 32 = 0 is not > 7);
   the emission test passes where `32 - r > 7` and `r mod 4 = 0`: r = 24, 20, 16, 12, 8, 4 (six emissions of 5 particles with the eat sound; r = 28 fails because only 4 ticks elapsed). At the decrement to 0 the stew completes: 16 particles,
   statistics, food: food level +6 and saturation +7.2 (17 §4.9), game event `eat`, the stack shrinks by 1 and the `bowl` remainder replaces the empty slot.
5. **Eating when full.** A player with food level 20 who is not invulnerable holding an apple: `canEat(false)` false, `FAIL`, nothing starts. Holding a golden apple: `can_always_eat` true, starts, completion adds food 4,
   saturation 9.6 and effects regeneration (100 ticks, amplifier 1) and absorption (2400 ticks, amplifier 0), each applied with probability 1.0.
6. **Hanging sign placement.** A player looks straight up at the underside of a solid block and uses an `oak_hanging_sign` on it: the nearest-looking order (29 §9.5) puts UP first for a clicked face DOWN; `A` = UP, the opposite DOWN is skipped;
   `d` = UP equals `A`, so the candidate is the ceiling hanging sign state; `canPlace` is `canSurvive` (the block above must support it, 24 part 3); the result is kept if unobstructed. Looking at the side of a wall instead gives a horizontal `d`:
   the candidate is the wall hanging sign state, and `WallHangingSignBlock.canPlace` demands a sturdy full face or a same-axis wall hanging sign on one of the two lateral neighbours.
7. **Fuel.** An `oak_boat` in a furnace burns 1200 ticks (60 s); in a smoker it burns 600 ticks. A `bowl` burns 100 ticks in a furnace. A `crimson_sign` and every `crimson` or `warped` sign burns 0 (no `cooking_fuel`).

## 13. Validation

| # | Check | Result |
|---|---|---|
| 1 | Rows | 153 (ids 975 to 1127); every row's key equals the lower-case `Items` field name (all 153) |
| 2 | Statement to id offset (0-based statements, section 1) | 695 + 280 = 975 and 847 + 280 = 1127; 24 collection statements precede the range (10 weathering x 8 + 14 colour x 16 = 304 items), none inside it; 671 plain statements precede it |
| 3 | Total registry (1253 `putstatic` statements in all: 1218 plain + 35 collection statements, 0-based numbers 0 to 1252) | 1658 items (1218 plain item statements + 20 x 16 + 15 x 8), equal to 25-1 §2.4 |
| 4 | Stack sizes | 1: 90 rows (22 boats, 35 tools, 28 armor, `turtle_helmet`, `wolf_armor`, `flint_and_steel`, `bow`, `mushroom_stew`); 16: 26 rows (signs); 64: 37 rows |
| 5 | Rows with `max_damage` | 67 (35 tools, 28 armor, `turtle_helmet`, `wolf_armor`, `flint_and_steel`, `bow`); each has stack size 1 |
| 6 | Fuel rows | 54 = 22 boats + 5 wooden tools + 11 signs (oak to bamboo) + 11 hanging signs (oak to bamboo) + 2 coal items (`coal`, `charcoal`) + `bow` + `bowl` + `stick`; the other 99 rows have none |
| 7 | Rarity | epic 4 (game-master items), uncommon 4 (chainmail), rare 1 (`enchanted_golden_apple`); all others common |
| 8 | `fire_resistant` | 11 (netherite: 5 tools, 4 armor, ingot, scrap) |
| 9 | Trim material rows | 9 (`diamond`, `emerald`, `lapis_lazuli`, `quartz`, `amethyst_shard`, `iron_ingot`, `copper_ingot`, `gold_ingot`, `netherite_ingot`) |
| 10 | Compostable rows | 4 (`apple`, `wheat_seeds`, `wheat`, `bread`) |
| 11 | Tool builder arguments vs 17 §2.2, §2.3 | all 35 pairs equal (the spot checks of section 6 plus the whole table compared) |
| 12 | Armor materials vs 17 §2.5 | all values equal (durability multipliers, defense values, enchantability, toughness, knockback resistance) |
| 13 | Component ids | 122 `DataComponents` types read; 44, 64, 78, 83, 84, 85, 118, 119, 120 as in section 2.1 and 46 §8.1 |

An implementation test: build the id table with 25-1 §2.3 and compare the anchors id 975 `oak_boat`, 996 `bamboo_chest_raft`, 997 `structure_block`, 1001 `turtle_helmet`, 1007 `apple`, 1008 `bow`, 1010 `coal`,
1025 `wooden_sword`, 1060 `stick`, 1061 `mushroom_stew`, 1065 `wheat_seeds`, 1068 `leather_helmet`, 1095 `netherite_boots`, 1102 `oak_sign`, 1115 `oak_hanging_sign`, 1127 `warped_hanging_sign`. A prototype test: the component map
of `oak_sign` has the 13 common entries (25-1 §7.1) with `max_stack_size` 16, plus `cooking_fuel` (burn time key `cooking/time_wood_items_large`), `sign_text_front` and `sign_text_back`.

## 14. Open questions

1. The wire layouts of `cooking_fuel`, `compostable` and `ResolvableInt` (an `Either` of a 4-byte integer and a provider key) were read only as codec names; the stream codec of `Either` (presumably a Boolean selector then the payload) and the key
   encoding were not traced. Until then, a server must send item stack patches that do not touch these components (a patch against the prototype never includes them for these rows).
2. The wire layouts of `villager_food` (a VarInt is inferred) and `provides_trim_material` (a holder of `trim_material`) were not read.
3. Resolved: the equip sound key strings were read (8.3). Not read: the numeric ids of these events in the sound registry (46 §14) and whether the keys carry the `minecraft` namespace by default registration (inferred).
4. The ordering inside `ColorCollection`/`WeatheringCopperCollection` (needed for the ids before this range) is taken from 25-1 §2.3, not re-read here; this range does not depend on it (no collection inside it), only the total offset 280 does.
5. Resolved: `Player.isEquipped(item)` was read in full (section 4.5): per slot, stack `is(item)`, `equippable` present and its `slot` identical to the visited slot. The turtle helmet's head slot is also read: `Items` statement 721 calls `humanoidArmor(TURTLE_SCUTE, HELMET)` and `ArmorType.HELMET` maps to `EquipmentSlot.HEAD`; `Player.tick` additionally requires `isEyeInFluid(water)` false and `isEquipped(TURTLE_HELMET)`. Nothing remains open.
6. Resolved: `UseRemainder.convertIntoRemainder` was read with branch targets (section 10.4). Formerly: the branch order of the two conditions (infinite materials, remaining count) was read without branch targets; the stated reading (a remainder is produced only when not infinite and the stack shrank; empty stack returns the remainder, otherwise the callback gives it) was inferred before that read.
7. `EntityType.createDefaultStackConfig` (which stack components a spawned boat or painting takes from the item) was not traced.
8. Creative inventory membership of the game-master items (`CreativeModeTabs`) and the operator-only filtering were not read.
9. The `crafting_dye` recipe engine, the trim application, and the item entries `leather_horse_armor` and horse armor of other parts are outside this range.
10. Whether `Player.tick` runs the turtle helmet check on the client as well as on the server (the effect is only meaningful on the server) was not traced.
11. The brief numbered part 3 as "456-694", part 5 as "848-939" and this part as "695 to 847": those are statement numbers (section 1), not ids; the ids of this part are 975 to 1127 (part 3 ends at id 974, part 5 starts at id 1128). If another document uses the brief's numbers as ids it is wrong by 280.
12. No document in docs/protocol/ was found that covers the `trim` component and its application (searched file names for "trim"; grep of 04, 08, 13, 14, 16, 17, 19, 23 only matched smithing or trim material mentions in other contexts and was not read for this purpose). Add an NN cross-reference when one exists.
13. The effect-merge rule when `water_breathing` is added while already active (`MobEffectInstance` merge, whether the longer duration is kept) was not read; section 4.5 does not depend on it.
