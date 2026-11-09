# Item registry, part 1: shared model and the block items of ids 0 to 227

| Item | Value |
|---|---|
| Covers | The shared model of the whole item registry (id assignment, the registration helpers, the block-item relationship, the `Item.Properties` builders and their defaults, the default data components, the `Foods` and `Consumables` constants, the row schema and a part index), and the rows of registry ids 0 to 227 (`air` to `azalea_leaves`: all block items) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of lambdas), and of data files in the jar (`unzip -p`), with no execution. Class, method and field names in backticks say where a fact was read. Values not read are marked "(inferred)" or "(recalled, not verified)" and are listed in the Open questions |
| Status | Round RS5, part 1 of 8 (design map Part 5 GAP-2, Part 6 row RS5) |
| Siblings | Parts 2 to 8 cover ids 228 to 1657 in id order and cite this document for the model, the row schema and every column definition. Their file names are fixed by those parts; section 12 gives the family map of the whole registry |

"04 §5" means section 5 of [04-registry-sync.md](04-registry-sync.md); "17 §1" means section 1 of
[17-tools-weapons-and-combat.md](17-tools-weapons-and-combat.md), and so on. "24 §2" is the block registry
([24-block-registry-1-model-and-foundation.md](24-block-registry-1-model-and-foundation.md)); "26 §9" is
[26-loot-and-predicates.md](26-loot-and-predicates.md); "29" is
[29-block-updates-and-placement.md](29-block-updates-and-placement.md); "46 §8" is
[46-registry-ids.md](46-registry-ids.md). The design map is `docs/design/README.md`.

Data versus code (design map R7). The item registry is code: ids, keys, item classes, default components, the
helpers that fill them. This document specifies all of that for its rows. It does not tabulate data that the
extraction tool (22) copies out of the jar (item models and item assets, recipes, loot tables, tag files,
`data/minecraft/context_int_provider/*.json`); it names the schema, the keys that code reads and the engines.

## Contents

1. Scope, and two corrections to the brief
2. The item id rule
3. The registration helpers
4. Keys: `BlockItemId`, `ItemIds`, and the block-item relationship
5. Item classes
6. `Item.Properties`: defaults and builders
7. Default data components
8. Foods and Consumables
9. Data-driven item components: fuel, compost, brewing fuel
10. Row schema
11. The rows: ids 0 to 227
12. Part index (family map of ids 228 to 1657)
13. Worked examples
14. Validation
15. Open questions

---

## 1. Scope, and two corrections to the brief

- Scope: the shared model (sections 2 to 10), the rows of ids 0 to 227 (section 11), the family map (section 12).
- **Correction 1: the number of items.** `Items` has 1253 `public static final` fields and 1253 `putstatic`
  statements in its static initialiser (read; the field order and the statement order are the same sequence).
  Not every field is one item: 35 fields are collections that register several items each (section 2.3), so the
  registry has **1658** items, ids 0 to 1657 (computed, section 2.4). The figure 1253 is the field count.
- **Correction 2: the registration call census.** Counting the final registration call of each of the 1253 statements
  gives the figures of section 2.4 (749 `registerBlock` calls, 17 `registerItem` calls keyed by a `BlockItemId`,
  364 `registerItem` calls keyed by an `ItemIds` key, 88 `registerSpawnEgg` calls and 35 collection calls). They do
  not reproduce the split 773 / 392 / 88 given in the brief; the sum is the same, 1253. Recounted in the fixing pass
  (section 14, check 4): 749 + 381 (of which 17 keyed by a `BlockItemId`) + 88 + 35 = 1253; the brief's two larger
  figures exceed these by 24 and 11, which sum to the 35 collection statements (inferred explanation, Open question 1).
- Placement behaviour of `BlockItem` (what happens when the item is used on a block) is summarised in section 5.2 and
  owned by 29. Fuel, composting and brewing semantics at the furnace, composter and brewing stand are owned by the
  documents of those machines; section 9 specifies how the item side is expressed.

## 2. The item id rule

### 2.1 Registration

1. `net.minecraft.core.registries.BuiltInRegistries.ITEM` is a defaulted registry (default key `air`, 04 §5).
2. `Items.<clinit>` registers items one statement at a time through the private static helpers of section 3. Every
   helper ends in `Registry.register(ITEM, key, item)` (inside `registerItem(ResourceKey, Function, Properties)`).
3. The numeric id of an item is its registration index, the number of items registered before it, starting at 0
   (`MappedRegistry.register`, 04 §5.1). `Item.getId(item)` returns that index, or 0 for a null item; `Item.byId` is
   the reverse lookup.

### 2.2 Order

- The order of registration is the order of the `putstatic` instructions of `Items.<clinit>`, which is also the field
  declaration order. There is no separate ordering table.
- A statement that is not a collection registers exactly one item. Statement number N (0-based) of a part of the
  registry that contains no collection before it therefore has id N.

### 2.3 Collections

Two collection types appear in `Items` (same classes as in 24 §2.3):

| Collection | Items per field | Expansion rule |
|---|---|---|
| `ColorCollection<Item>` | 16 | Registered by `ColorCollection.registerBlockItems(blockIdCollection, blockCollection, factory)` (block items, 16 statements) or `ColorCollection.registerItems(idCollection, factory)` (plain items, 4 statements: `harness`, `dyed_bundle`, `cushion`, `dye`). The 16 items are registered consecutively, in the dye order of 24 §2.3 (white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black). The key of each is the colour joined to the base name, colour first |
| `WeatheringCopperCollection<Item>` | 8 | `WeatheringCopperCollection.registerItems(ids, blocks, factory)` zips the id collection with the block collection. The order is the weathering record (unaffected, exposed, weathered, oxidized) and then the waxed record, with the key prefixes `""`, `exposed_`, `weathered_`, `oxidized_`, `waxed_`, `waxed_exposed_`, `waxed_weathered_`, `waxed_oxidized_` (`WeatheringCopperCollection.PREFIXES`, read). The prefix is joined to the base name by plain concatenation, prefix first (the `makeConcatWithConstants` recipe of `prefixWithState` is two operands with no separator; operand order prefix first, read; Open question 2 is resolved). `BlockItemIds.COPPER_BLOCK` uses special base names: `copper_block` for the unaffected state and `copper` for the other three, and the waxed record repeats them (`COPPER_BLOCK_SPECIAL_NAMES`, read). Every other weathering collection uses one base name for all eight |

All 35 collection statements, with the first and last id computed in section 2.4:

| Statement | Field | Kind | Items | First id | Last id |
|---|---|---|---|---|---|
| 120 | `COPPER_BLOCK` | weathering | 8 | 120 | 127 |
| 124 | `CHISELED_COPPER` | weathering | 8 | 131 | 138 |
| 125 | `CUT_COPPER` | weathering | 8 | 139 | 146 |
| 126 | `CUT_COPPER_STAIRS` | weathering | 8 | 147 | 154 |
| 127 | `CUT_COPPER_SLAB` | weathering | 8 | 155 | 162 |
| 215 | `WOOL` | colour (block) | 16 | 250 | 265 |
| 216 | `WOOL_STAIRS` | colour (block) | 16 | 266 | 281 |
| 217 | `WOOL_SLAB` | colour (block) | 16 | 282 | 297 |
| 385 | `COPPER_BARS` | weathering | 8 | 465 | 472 |
| 387 | `COPPER_CHAIN` | weathering | 8 | 474 | 481 |
| 467 | `DYED_TERRACOTTA` | colour (block) | 16 | 561 | 576 |
| 471 | `CARPET` | colour (block) | 16 | 580 | 595 |
| 481 | `STAINED_GLASS` | colour (block) | 16 | 605 | 620 |
| 482 | `STAINED_GLASS_PANE` | colour (block) | 16 | 621 | 636 |
| 503 | `DYED_SHULKER_BOX` | colour (block) | 16 | 657 | 672 |
| 504 | `GLAZED_TERRACOTTA` | colour (block) | 16 | 673 | 688 |
| 505 | `CONCRETE` | colour (block) | 16 | 689 | 704 |
| 506 | `CONCRETE_STAIRS` | colour (block) | 16 | 705 | 720 |
| 507 | `CONCRETE_SLAB` | colour (block) | 16 | 721 | 736 |
| 508 | `CONCRETE_POWDER` | colour (block) | 16 | 737 | 752 |
| 596 | `LIGHTNING_ROD` | weathering | 8 | 840 | 847 |
| 651 | `COPPER_DOOR` | weathering | 8 | 902 | 909 |
| 666 | `COPPER_TRAPDOOR` | weathering | 8 | 924 | 931 |
| 685 | `HARNESS` | colour (item) | 16 | 950 | 965 |
| 874 | `DYED_BUNDLE` | colour (item) | 16 | 1154 | 1169 |
| 875 | `CUSHION` | colour (item) | 16 | 1170 | 1185 |
| 889 | `DYE` | colour (item) | 16 | 1199 | 1214 |
| 894 | `BED` | colour (block) | 16 | 1219 | 1234 |
| 1077 | `BANNER` | colour (block) | 16 | 1417 | 1432 |
| 1162 | `COPPER_LANTERN` | weathering | 8 | 1517 | 1524 |
| 1189 | `DYED_CANDLE` | colour (block) | 16 | 1551 | 1566 |
| 1244 | `COPPER_GRATE` | weathering | 8 | 1621 | 1628 |
| 1245 | `COPPER_BULB` | weathering | 8 | 1629 | 1636 |
| 1246 | `COPPER_CHEST` | weathering | 8 | 1637 | 1644 |
| 1247 | `COPPER_GOLEM_STATUE` | weathering | 8 | 1645 | 1652 |

### 2.4 Counts (computed from the 1253 statements)

Method of the count: each of the 1253 `putstatic` statements of `Items.<clinit>` is taken with the last registration
call before it (`registerBlock`, `registerItem`, `registerSpawnEgg`, `ColorCollection.registerBlockItems` /
`registerItems`, `WeatheringCopperCollection.registerItems`); a `registerItem` statement counts as "keyed by a
`BlockItemId`" when a `BlockItemIds` constant is loaded inside the statement (the 3 statements `air`, `resin_clump`,
`nether_wart` use `.item()` of that constant, the other 14 use the `registerItem(BlockItemId, ...)` overloads). All
figures below were recomputed from the bytecode in the fixing pass (read).

| Statement kind | Statements | Items |
|---|---|---|
| `registerBlock` (any overload, key from a `BlockItemId`) | 749 | 749 |
| `registerItem` keyed by a `BlockItemId` (`air`, `resin_clump`, `nether_wart`, and the 14 items whose key differs from their block, section 4.3) | 17 | 17 |
| `registerItem` keyed by an `ItemIds` key | 364 | 364 |
| `registerSpawnEgg` | 88 | 88 |
| `ColorCollection.registerBlockItems` | 16 | 256 |
| `ColorCollection.registerItems` | 4 | 64 |
| `WeatheringCopperCollection.registerItems` | 15 | 120 |
| Total | 1253 | **1658** |

Block-linked items (key from a `BlockItemId`): 749 + 17 + 256 + 120 = 1142. Items keyed by `ItemIds`:
364 + 64 + 88 = 516. 1142 + 516 = 1658.

The first collection is statement 120 (`COPPER_BLOCK`), so ids 0 to 119 equal the statement number, and from
statement 121 on the id is the statement number plus the extra items of the collections before it (7 for each
weathering collection, 15 for each colour collection).

## 3. The registration helpers

All are private static methods of `Items`. In the descriptions, "properties" is a fresh `Item.Properties` unless
a call supplies one.

| Helper | What it does |
|---|---|
| `registerBlock(BlockItemId id, Block block)` | `registerBlock(id, block, factory)` with the default factory below |
| `registerBlock(id, block, Properties p)` | default factory, properties `p` |
| `registerBlock(id, block, UnaryOperator<Properties> f)` | factory builds `new BlockItem(block, f(properties))` |
| `registerBlock(id, block, Block... extra)` | registers as the two-argument form, then puts every block of `extra` into `Item.BY_BLOCK` with the new item as value (extra blocks that give the same item). 1 statement uses this form |
| `registerBlock(id, block, Properties p, Block... extra)` | as above with explicit properties. 1 statement uses this form |
| `registerBlock(id, block, BiFunction<Block, Properties, Item> factory)` | `factory` gets the block and a fresh `Properties` |
| `registerBlock(id, block, factory, Properties p)` | the core form: item key = `id.item()`; the properties get `useBlockDescriptionPrefix()` and `requiredFeatures(block.requiredFeatures())`; then `registerItem(key, props -> factory(block, props), p)`. The default factory is `BlockItem::new` |
| `registerItem(ResourceKey<Item> key)` | `new Item(properties)`, fresh properties |
| `registerItem(key, Properties p)` | `new Item(p)` |
| `registerItem(key, Function<Properties, Item> f)` and `(key, f, Properties p)` | the core form: `p.setId(key)`, build the item with `f`, and register it (below) |
| `registerItem(BlockItemId id, ...)` overloads | the same, with key `id.item()` (used by the 17 statements of section 2.4) |
| `registerSpawnEgg(key, EntityType<?> type)` | `registerItem(key, SpawnEggItem::new, new Properties().spawnEgg(type))` |
| `createBlockItemWithCustomItemName(Block block)` | returns a factory `p -> new BlockItem(block, p.useItemDescriptionPrefix())`; the item keeps the item name prefix `item.` although it places a block (seeds, carrots, potatoes, berries: section 4.3) |
| `mapProperties()` | `new Properties().component(map_decorations, MapDecorations.EMPTY)`, used by the map items (sibling part) |

The core registration step (`registerItem(ResourceKey, Function, Properties)`), in order:

1. `p.setId(key)`: the key is stored in the properties (the properties need it for the description id and the model).
2. The factory builds the `Item`. The `Item` constructor (section 6.2) creates the intrusive registry holder, derives
   the description id and the default item model, and queues the component initialiser under `key`.
3. If the item is a `BlockItem`, `registerBlocks(Item.BY_BLOCK, item)` runs: `BlockItem` puts its block into
   `BY_BLOCK` with the item as value; `StandingAndWallBlockItem` also puts its wall block (and `HangingSignItem`
   likewise); so a standing and a wall block map to the same item.
4. `Registry.register(ITEM, key, item)` assigns the next id.

`AIR` is the first statement and has its own form: `registerItem(BlockItemIds.AIR.item(), AirItem::new,
new Properties().useBlockDescriptionPrefix())`. It is not a `BlockItem`, so `BY_BLOCK` gets no entry for any block
from it.

`Item.byBlock(block)` is `BY_BLOCK.getOrDefault(block, Items.AIR)`; a block with no item (water, lava, and every block
that no `registerBlock` call or `extra` argument names) maps to `air`.

## 4. Keys: `BlockItemId`, `ItemIds`, and the block-item relationship

### 4.1 Key sources

- `net.minecraft.references.BlockItemIds` has 798 `putstatic` instructions in its static initialiser (read), one per `BlockItemId` or collection constant. A
  `BlockItemId` is a record of a block key and an item key, both in the `minecraft` namespace, built by
  `BlockItemId.create(String)` (block path equals item path) or `BlockItemId.create(String blockPath, String itemPath)`.
  Collection constants (`ColorCollection<BlockItemId>`, `WeatheringCopperCollection<BlockItemId>`) hold one per member.
- `net.minecraft.references.ItemIds` holds the plain `ResourceKey<Item>` constants of the items that have no block (516 are used by `Items`, section 2.4; the static initialiser of `ItemIds` has 456 `putstatic` instructions, read).
- In a `registerBlock` row the item key is `id.item()` and the block is the `Block` argument; the block key of the same
  id is `id.block()`. The blocks are registered under the block key in 24 §2.

### 4.2 The relationship, stated as rules

1. Item key equals block key for all 1142 block-linked items except the 14 of section 4.3 (`1142 - 14 = 1128`; the rule is
   checked for ids 0 to 227 in section 14, and for the 3 other `registerItem(BlockItemId)` rows in section 4.3).
2. `BlockItem.getBlock()` is the single placed block; `Item.byBlock` maps the block back to the item.
3. The description id of a block item is `block.minecraft.<path>` (`useBlockDescriptionPrefix`) except the items made
   by `createBlockItemWithCustomItemName`, which use `item.minecraft.<path>`.
4. `requiredFeatures` of an item is taken from its block (`registerBlock` core form) or from its entity type
   (`spawnEgg`); every other item has the vanilla set (`FeatureFlags.VANILLA_SET`). An item whose feature set is not
   enabled in the world is not available (feature flags: 04 and the world-type document).
5. The extra-blocks varargs let one item stand for several blocks without registering them again (only 2 statements in
   the registry use it; they are in the sibling parts).

### 4.3 Block-linked items whose key differs from the block key (`registerItem(BlockItemId, ...)` with two strings)

| Statement | Item field | Id | Block key | Item key | Factory |
|---|---|---|---|---|---|
| 580 | `REDSTONE` | 824 | `redstone_wire` | `redstone` | not a `BlockItem` (dust item, sibling part) |
| 782 | `STRING` | 1062 | `tripwire` | `string` | sibling part |
| 785 | `WHEAT_SEEDS` | 1065 | `wheat` | `wheat_seeds` | `createBlockItemWithCustomItemName(WHEAT)` |
| 851 | `POWDER_SNOW_BUCKET` | 1131 | `powder_snow` | `powder_snow_bucket` | sibling part |
| 888 | `COCOA_BEANS` | 1198 | `cocoa` | `cocoa_beans` | sibling part |
| 918 | `PUMPKIN_SEEDS` | 1258 | `pumpkin_stem` | `pumpkin_seeds` | sibling part |
| 919 | `MELON_SEEDS` | 1259 | `melon_stem` | `melon_seeds` | sibling part |
| 1038 | `CARROT` | 1378 | `carrots` | `carrot` | sibling part |
| 1039 | `POTATO` | 1379 | `potatoes` | `potato` | sibling part |
| 1081 | `TORCHFLOWER_SEEDS` | 1436 | `torchflower_crop` | `torchflower_seeds` | sibling part |
| 1082 | `PITCHER_POD` | 1437 | `pitcher_crop` | `pitcher_pod` | sibling part |
| 1084 | `BEETROOT_SEEDS` | 1439 | `beetroots` | `beetroot_seeds` | sibling part |
| 1163 | `SWEET_BERRIES` | 1525 | `sweet_berry_bush` | `sweet_berries` | sibling part |
| 1164 | `GLOW_BERRIES` | 1526 | `cave_vines` | `glow_berries` | sibling part |

(14 rows; the other three `registerItem(BlockItemId, ...)` statements have equal keys: `air` at 0, `resin_clump` at 486,
`nether_wart` at id 1269 (statement 929; the collections before it add 340 extra items), whose block `nether_wart` has the same key.) The classes of the rows marked "sibling part" are
read there. All ids were computed with section 2.

## 5. Item classes

### 5.1 `Item`

`net.minecraft.world.item.Item implements ItemLike, FeatureElement`. Constants: `DEFAULT_MAX_STACK_SIZE = 64`,
`ABSOLUTE_MAX_STACK_SIZE = 99`, `MAX_BAR_WIDTH = 13`, `APPROXIMATELY_INFINITE_USE_DURATION = 72000`. Static maps:
`BY_BLOCK` (a `HashMap<Block, Item>`), identifiers `BASE_ATTACK_DAMAGE_ID = minecraft:base_attack_damage` and
`BASE_ATTACK_SPEED_ID = minecraft:base_attack_speed`. The codec `Item.CODEC` is the registry-by-name holder codec and
**rejects `minecraft:air`** ("Item must not be minecraft:air"); the wire form is a registry holder (VarInt id, 04 §5).

Behaviour of the base class that depends on components (an implementation needs these for every row; the numbers are
read):

| Behaviour | Rule |
|---|---|
| Default max stack | the `max_stack_size` component of the prototype, 1 if absent (the common set always has it, section 7.1) |
| `getDestroySpeed(stack, state)` | `Tool.getMiningSpeed(state)` when the stack has `tool`, else 1.0 (17 §1.3) |
| `isCorrectToolForDrops` | `Tool.isCorrectForDrops(state)` when the stack has `tool`, else false |
| `canDestroyBlock` | false when the stack has `tool` with `can_destroy_blocks_in_creative` false and the miner is a player in creative (`instabuild`); true in every other case, including a non-player miner (read) |
| `mineBlock` | returns false when the stack has no `tool`; otherwise, on the server side, for a block whose destroy speed is not 0 and with `damage_per_block` > 0, hurt the stack by `damage_per_block` (main hand); returns true (read, `Item.mineBlock`) |
| `use` (right click in air) | in order: `consumable` present: `Consumable.startConsuming` (FAIL when `canConsume` is false; when `consumeTicks` > 0 start using the item and CONSUME; with 0 ticks the item is consumed at once and CONSUME carries the resulting stack); `equippable` present and swappable: swap with the equipment slot; `blocks_attacks` present: start using, CONSUME; `kinetic_weapon` present: start using and make its sound, CONSUME; else PASS |
| `useOn` | the `block_transformer` component's `transformBlock` when present, else PASS |
| `finishUsingItem` | `Consumable.onConsume` when `consumable` is present |
| Use animation | `consumable.animation`, else BLOCK when `blocks_attacks`, else SPEAR when `kinetic_weapon`, else NONE |
| Use duration | `consumable.consumeTicks` (= `trunc(consume_seconds x 20)`), else 72000 for `blocks_attacks` or `kinetic_weapon`, else 0 |
| Durability bar | visible when the stack is damaged; width `clamp(round(13 - damage x 13 / max_damage), 0, 13)`; colour from `hsvToRgb(f / 3, 1, 1)` with `f = max(0, (max_damage - damage) / max_damage)` (this settles the "inferred" bar width of 17 §1.3) |
| Foil | `ItemStack.isEnchanted` |
| Name | the `item_name` component of the stack (default empty text if absent); `AirItem` reads it from the prototype |
| `canFitInsideContainerItems` | true (`BlockItem` returns false for a `ShulkerBoxBlock` block) |
| Hooks with no effect in the base class | `onUseTick`, `onDestroyed`, `hurtEnemy`, `postHurtEnemy`, `inventoryTick`, `onCraftedPostProcess` (`onCraftedBy` only calls it), `releaseUsing` (false), `useOnRelease` (false), `interactLivingEntity` (PASS), `getAttackDamageBonus` (0), `getItemDamageSource` (none) |

Verification status of this table (fixing pass): every row was re-read in `Item` (`getDefaultMaxStackSize`, `getDestroySpeed`, `isCorrectToolForDrops`, `canDestroyBlock`, `mineBlock`, `use`, `useOn`, `finishUsingItem`, `getUseAnimation`, `getUseDuration`, `isBarVisible` (= `ItemStack.isDamaged`), `getBarWidth`, `getBarColor`, `isFoil`, `getName`, `canFitInsideContainerItems`, the empty hooks). The bar width is the float `13 - damage x 13 / max_damage`, rounded with `Math.round` and clamped to 0..13; the colour is `Mth.hsvToRgb(f / 3.0, 1, 1)` with `f = max(0, (max_damage - damage) / max_damage)`; the use duration constant is 72000; `consumeTicks` multiplies `consume_seconds` by 20.0 in float and truncates to int (`Consumable.consumeTicks`). `Item.useOn` is read in the form above and is also called by `BlockItem.useOn` (section 5.2). The `BlockItem` method `canFitInsideContainerItems` exception for shulker boxes was not re-traced (Open question 8).

The constructor of every item (and therefore of every row) does: create the intrusive registry holder; derive the
description id (section 6.3); queue the component initialiser (section 6.2) under the item key in
`BuiltInRegistries.DATA_COMPONENT_INITIALIZERS`; keep the crafting remainder template and the required feature set.
In the `Item` constructor, when the shared flag `SharedConstants.IS_RUNNING_IN_IDE` is set, the simple class name is tested for the suffix `Item` and, when it lacks it, the message "Item classes should end with Item and {} doesn't" is logged as an error; nothing else happens (read, `Item.<init>`).

### 5.2 `BlockItem` (class of every row of this part except `air`)

Fields: the placed `block`. `useOn(context)` is (read, `BlockItem.useOn`): try `place` on a `BlockPlaceContext` built from the use context; if the
result consumes the action, return it; else run the base `Item.useOn` (the `block_transformer` step of section 5.1) and
return its result if it consumes the action; else, when the stack has a `consumable` component, run the base `Item.use`
for the held hand; else return the last result. `place(context)` in order (read in `BlockItem.place`; the order of the
seven steps and the constants 11, 1, 2 and 0.8 were traced in the fixing pass) (the placement checks are specified in
29; the item-side steps are):

1. If the block is not enabled by the world's enabled features, FAIL.
2. If `context.canPlace()` is false (clicked position not replaceable), FAIL.
3. `updatePlacementContext(context)` (identity for `BlockItem`; `ScaffoldingBlockItem` overrides it; null, FAIL).
4. `getPlacementState(context)`: `block.getStateForPlacement(context)` kept only if `canPlace(context, state)` (the state
   survives at the position when `mustSurvive()` (true), and the shape is unobstructed under the placement collision
   context); else null, FAIL.
5. `placeBlock(context, state)`: `Level.setBlock(pos, state, 11)` (the flag bits are decoded in 29); false, FAIL.
6. If the block at the position is now the item's block: apply the stack's `block_state` component
   (`BlockItemStateProperties.apply` to the placed state; a changed state is written with flags 2), apply the stack's
   `block_entity_data` through `updateCustomBlockEntityTag` (server only; a type mismatch or an op-only block entity type
   without a game-master player is refused), apply the stack's block-entity components, call
   `block.setPlacedBy(level, pos, state, player, stack)`, and for a `ServerPlayer` trigger the `placed_block` criterion.
7. Play the placed state's place sound at the position, source BLOCKS, volume `(soundType.volume + 1) / 2`, pitch
   `soundType.pitch x 0.8` (constants 1, 2 and 0.8 read in `BlockItem.place`; the sound event is `SoundType.getPlaceSound` of the placed state); emit game event `block_place`; consume 1 from the stack (creative rule: 13 §2.5);
   SUCCESS.

`BlockItem.onDestroyed` empties a `container` component of a destroyed item entity and drops the contents.
`shouldPrintOpWarning` is true for a game-master player holding a stack whose `block_entity_data` names an op-only type.

### 5.3 Subclasses of `BlockItem` used by the registry

| Class | Difference from `BlockItem` | Where used |
|---|---|---|
| `StandingAndWallBlockItem(standing, wall, attachmentDirection, props)` | `getPlacementState` tries the wall block first: for each direction of `getNearestLookingDirections()` (nearest first), skip the opposite of the attachment direction; the candidate is the standing block's state when the direction equals the attachment direction (down in all rows read), else the wall block's state; the first candidate that is non-null and survives (`canSurvive`) is used; the result is kept only if unobstructed (empty collision context); `registerBlocks` also maps the wall block to the item | torches, coral fans, signs, skulls, heads (sibling parts) |
| `DoubleHighBlockItem` | `placeBlock` first sets the position above to water (if there is water there) or air with flags 27 (bits decoded in 29), then places normally | doors, tall plants (sibling parts) |
| `ScaffoldingBlockItem` | `updatePlacementContext`: when the clicked block is scaffolding, walk (up to 7 steps, counting only horizontal moves) in the clicked face direction (reversed for an inside click while sneaking; the horizontal facing when clicking the top) to the first position that is not scaffolding and replaceable and re-aim the context there; stop at the world height limit with a build-limit message; `mustSurvive()` is false | scaffolding (sibling part) |
| `AirItem` | not a `BlockItem`; `getName` reads `item_name` of the prototype | `air` only |

The remaining classes (`SpawnEggItem`, `BowItem`, `DyeItem`, ...) are read in the sibling parts that register them.
`SpawnEggItem` is the class of all 88 spawn eggs (section 12); its `use` and `useOn` spawn the entity of the
`entity_data` component.

## 6. `Item.Properties`: defaults and builders

### 6.1 State of a new `Properties`

| Field | Initial value |
|---|---|
| component initialiser | one that copies `DataComponents.COMMON_ITEM_COMPONENTS` into the item's component map (section 7.1) |
| `craftingRemainingItem` | none |
| `requiredFeatures` | `FeatureFlags.VANILLA_SET` |
| `id` | unset (`setId`; reading it before gives "Item id not set") |
| `descriptionId` | the item-prefix rule (`item.<namespace>.<path>`) |
| `model` | the item key's identifier |

### 6.2 How the prototype components are built

- `component(type, value)` appends "set `type` to `value`" to the initialiser. Later calls win over earlier ones.
- `delayedComponent(type, initialiser)` and `delayedHolderComponent(type, key)` append a step that runs once the
  registries exist (they need a `HolderLookup.Provider`): used for `damage_resistant`, `jukebox_playable`,
  `provides_pottery_pattern`, `block_transformer`, `damage_type`, `provides_trim_material`, `mob_visibility`.
- When the `Item` is constructed, `finalizeInitializer(itemName, model)` appends two more steps: set `item_name` to the
  translatable text of the description id and `item_model` to the model identifier, and add a **validator**: if the
  map has `damage` and `max_stack_size` is greater than 1, fail with "Item cannot have both durability and be stackable".
- The prototype is built when the data component initialisers run against the loaded registries (after the registries
  of a world are available, 04 and 23).

### 6.3 Description id, model and name

- `descriptionId` = `Util.makeDescriptionId(type, key)` where `type` is `block` (`useBlockDescriptionPrefix`) or
  `item` (default, `useItemDescriptionPrefix`); the result is `type + "." + namespace + "." + path` with every `/` in
  the path replaced by `.` (recipe `\u0001.\u0001.\u0001`, read). `overrideDescription(text)` fixes the id to a given
  string.
- `item_name` default = translatable component with that key; text comes from the language file (design map GAP-27).
- `item_model` default = the item key as an identifier, so item `minecraft:stone` uses the item model definition
  `assets/minecraft/items/stone.json` (data, 14 and 12 §8).

### 6.4 Builder methods (every public method of the class, read)

| Builder | Effect |
|---|---|
| `stacksTo(n)` | `max_stack_size` = n |
| `durability(n)` | `max_damage` n, `max_stack_size` 1, `damage` 0 (in that order, so the stack size of 1 overrides the 64 of the common set) |
| `rarity(r)` | `rarity` = r (`Rarity` ids: common 0, uncommon 1, rare 2, epic 3, section 7.2) |
| `food(food)` / `food(food, consumable)` | `food` = the record and `consumable` = the given one, default `Consumables.DEFAULT_FOOD` |
| `villagerFood(n)` | `villager_food` = `VillagerFood(n)` |
| `usingConvertsTo(item)` | `use_remainder` = `UseRemainder(ItemStackTemplate(item))` |
| `useCooldown(seconds)` | `use_cooldown` = `UseCooldown(seconds)` (no group) |
| `craftRemainder(item or template)` | stores the crafting remainder template (not a component) |
| `fireResistant()` | delayed `damage_resistant` = `DamageResistant(damage type tag is_fire)` |
| `jukeboxPlayable(songKey)` | delayed `jukebox_playable` = `JukeboxPlayable(song holder)` |
| `enchantable(n)` | `enchantable` = `Enchantable(n)` |
| `potPattern(key)` | delayed `provides_pottery_pattern` = the decorated pot pattern holder |
| `repairable(item)` | `repairable` = `Repairable(direct set of that one item)` |
| `repairable(tag)` | `repairable` = `Repairable(items of the tag)` |
| `equippable(slot)` | `equippable` = `Equippable.builder(slot).build()` (defaults of the builder: 17 §1.2 and section 7.2) |
| `equippableUnswappable(slot)` | same with `swappable` false |
| `tool`, `pickaxe`, `axe`, `shovel`, `hoe`, `sword`, `spear` | 17 §1.4 (tool materials and the spear table); `axe`, `shovel` and `hoe` also set a delayed `block_transformer` (`BlockTransformers.AXE`, `SHOVEL`, `HOE`, 17 §3.1) |
| `spawnEgg(entityType)` | `entity_data` = `TypedEntityData.of(entityType, empty compound)`, `requiredFeatures` = the entity type's feature set |
| `humanoidArmor(material, type)` | durability = `type.getDurability(material.durability)`, `attribute_modifiers` = `material.createAttributes(type)`, `enchantable`, `equippable` (slot of the type, the material's equip sound and asset), `repairable` = material repair tag |
| `wolfArmor(material)` | durability from the BODY armor type, BODY attributes, `repairable`, `equippable` (BODY slot, equip sound, asset, allowed entities = wolf only, `can_be_sheared` true, shearing sound `armor_unequip_wolf`), `break_sound` = wolf armor break, `stacksTo(1)` |
| `horseArmor(material)` | BODY attributes, `equippable` (BODY, equip sound `horse_armor`, asset, allowed = entity type tag `can_wear_horse_armor`, `damage_on_hurt` false, `can_be_sheared` true, shearing sound `horse_armor_unequip`), `stacksTo(1)` |
| `nautilusArmor(material)` | like horse armor with tag `can_wear_nautilus_armor`, equip sound `armor_equip_nautilus`, `equip_on_interact` true, shearing sound `armor_unequip_nautilus` |
| `trimMaterial(key)` | delayed `provides_trim_material` |
| `signText()` | `sign_text_front` and `sign_text_back` both `SignText.EMPTY` |
| `cookingFuel(burnTimeKey)` | `cooking_fuel` = `CookingFuel(burnTimeKey, cooking/speed_default)` (section 9) |
| `brewingFuel(usesKey)` | `brewing_fuel` = `BrewingFuel(usesKey, brewing/speed_default)` |
| `compostable(chanceKey)` | `compostable` = `Compostable(chanceKey)` |
| `loweredMobVisibility(entityTypeKeys...)` | delayed `mob_visibility` = `MobVisibility(set of those entity types, 0.5)` (heads and skulls, sibling part) |
| `attributes(modifiers)` | `attribute_modifiers` |
| `component(type, value)` | any other component |
| `requiredFeatures(flags)` / `(set)` | sets the feature set (the set form checks it is a subset of the registry, "Mismatched flag sets") |
| `overrideDescription`, `useBlockDescriptionPrefix`, `useItemDescriptionPrefix`, `setId` | section 6.3 |

Components that `Items` sets through `component(...)` (not helper methods) are listed in the rows that use them.

## 7. Default data components

### 7.1 `COMMON_ITEM_COMPONENTS` (the default set of every item, `DataComponents.<clinit>`)

| Component (id, 46 §8.1) | Default value |
|---|---|
| `max_stack_size` (1) | 64 |
| `lore` (11) | `ItemLore.EMPTY` (no lines) |
| `enchantments` (13) | `ItemEnchantments.EMPTY` |
| `repair_cost` (19) | 0 |
| `use_effects` (5) | `UseEffects.DEFAULT` = can_sprint false, interact_vibrations true, speed_multiplier 0.2 |
| `attribute_modifiers` (16) | `ItemAttributeModifiers.EMPTY` |
| `rarity` (12) | `Rarity.COMMON` |
| `break_sound` (83) | sound event `entity.item.break` (`SoundEvents.ITEM_BREAK`, read as the string `entity.item.break`) |
| `tooltip_display` (18) | `TooltipDisplay.DEFAULT` (hide_tooltip false, empty hidden set: read, built as `new TooltipDisplay(false, empty set)`) |
| `attack_animation` (40) | `SwingAnimation.DEFAULT` = swing type `whack`, duration 6 ticks |
| `interact_animation` (41) | `SwingAnimation.DEFAULT` (same values) |

Together with `item_name` (9) and `item_model` (10), set when the item is constructed (section 6.2), these 13
components are the prototype of a plain block item. No other component is present unless a builder or a row adds it.
`DataComponents` has 122 registered types (46 §8.1) plus two non-registered fields; the type table is in 46 §8.1 and
the wire layouts of the item components in 17 §1.2. A prototype is never sent: a stack on the wire carries a patch
against it (00 §12.2), so a client must reproduce this default set exactly.

### 7.2 Enumerations and record defaults used here

| Name | Values |
|---|---|
| `Rarity` (ordinal, id, serialised name; read in `Rarity.<clinit>`: 4 constants, each with ordinal equal to its id) | 0 `COMMON` `common`, 1 `UNCOMMON` `uncommon`, 2 `RARE` `rare`, 3 `EPIC` `epic` (each also carries a chat formatting colour, not read here) |
| `ItemUseAnimation` (ordinal, id, serialised name; 12 constants read in `ItemUseAnimation.<clinit>`, id equal to ordinal) | 0 `NONE` `none`, 1 `EAT` `eat`, 2 `DRINK` `drink`, 3 `BLOCK` `block`, 4 `BOW` `bow`, 5 `TRIDENT` `trident`, 6 `CROSSBOW` `crossbow`, 7 `SPYGLASS` `spyglass`, 8 `TOOT_HORN` `toot_horn`, 9 `BRUSH` `brush`, 10 `BUNDLE` `bundle`, 11 `SPEAR` `spear`. The class also has a boolean `customArmTransform` (read as true for `EAT`, `DRINK` and `SPEAR`, false for the others; its use is a rendering matter, not traced) |
| `SwingAnimationType` (3 constants, read in `SwingAnimationType.<clinit>`, id equal to ordinal) | 0 `NONE` `none`, 1 `WHACK` `whack`, 2 `STAB` `stab`. `SwingAnimation` is a record (type, duration); `SwingAnimation.DEFAULT` is (`WHACK`, 6) (read; the `stab` use by spears is in 17 §1.4, not re-read here) |
| `Consumable.Builder` defaults | consume_seconds 1.6, animation `EAT`, sound `entity.generic.eat` (`GENERIC_EAT`), has_consume_particles true, no effects |
| `Consumable.consumeTicks` | `trunc(consume_seconds x 20)` |

### 7.3 The `ItemStack` view

Max stack of a stack = the effective `max_stack_size`. An item with `damage` in its prototype must have max stack 1
(validator above). The absolute upper bound of a stack size is 99 (`ABSOLUTE_MAX_STACK_SIZE`). The `max_stack_size` component's persistent codec is an integer range 1 to 99 (`ExtraCodecs.intRange(1, 99)`), so a saved or JSON value outside 1..99 is rejected on decode; its network codec is a plain VarInt with no range check (read). Container and inventory rules that use these values: 13 §3.

## 8. Foods and Consumables

### 8.1 `FoodProperties`

A record (nutrition int, saturation float, can_always_eat boolean). Wire: VarInt, Float, Boolean (17 §1.2).
`FoodProperties.Builder` takes `nutrition(int)`, `saturationModifier(float)` and `alwaysEdible()`; `build()` stores
**saturation = nutrition x modifier x 2** (`FoodConstants.saturationByModifier`: float multiply, then multiply by 2).
Eating (`FoodProperties.onConsume`, for a player) does, in order: play the consumable's sound at the eater's position (source NEUTRAL, volume 1.0, pitch `RandomSource.triangle(1.0, 0.4)`, read); `FoodData.eat(food)` (17 §4.9); play `entity.player.burp` at the player (source PLAYERS, volume 0.5, pitch `Mth.randomBetween(random, 0.9, 1.0)`, read); the three calls and their order, the constants 1.0 / 0.4 (triangle), 0.5, 0.9 and 1.0 were re-read in `FoodProperties.onConsume` in the fixing pass (the first sound is played from the eater's position with the consumable's sound event, no excluded player argument was traced). `FoodConstants`: MAX_FOOD 20, MAX_SATURATION 20.0,
START_SATURATION 5.0, SATURATION_FLOOR 2.5, EXHAUSTION_DROP 4.0, HEALTH_TICK_COUNT 80, HEALTH_TICK_COUNT_SATURATED 10,
HEAL_LEVEL 18, SPRINT_LEVEL 6, STARVE_LEVEL 0, the modifier scale POOR 0.1, LOW 0.3, NORMAL 0.6, GOOD 0.8, MAX 1.0,
SUPERNATURAL 1.2, and the exhaustion costs HEAL 6.0, JUMP 0.05, SPRINT_JUMP 0.2, MINE 0.005, ATTACK 0.1, WALK 0.0,
CROUCH 0.0, SPRINT 0.1, SWIM 0.01 (the use of each is 17 §4.9).

### 8.2 `Foods` (40 constants, in declaration order)

`stew(n)` is the private helper "nutrition n, modifier 0.6". Every other row sets nutrition and modifier directly.

| # | Field | Nutrition | Modifier | Saturation (= nutrition x modifier x 2, float) | can_always_eat |
|---|---|---|---|---|---|
| 0 | `APPLE` | 4 | 0.3 | 2.4 | false |
| 1 | `BAKED_POTATO` | 5 | 0.6 | 6 | false |
| 2 | `BEEF` | 3 | 0.3 | 1.8 | false |
| 3 | `BEETROOT` | 1 | 0.6 | 1.2 | false |
| 4 | `BEETROOT_SOUP` | 6 | 0.6 (stew) | 7.2 | false |
| 5 | `BREAD` | 5 | 0.6 | 6 | false |
| 6 | `CARROT` | 3 | 0.6 | 3.6 | false |
| 7 | `CHICKEN` | 2 | 0.3 | 1.2 | false |
| 8 | `CHORUS_FRUIT` | 4 | 0.3 | 2.4 | true |
| 9 | `COD` | 2 | 0.1 | 0.4 | false |
| 10 | `COOKED_BEEF` | 8 | 0.8 | 12.8 | false |
| 11 | `COOKED_CHICKEN` | 6 | 0.6 | 7.2 | false |
| 12 | `COOKED_COD` | 5 | 0.6 | 6 | false |
| 13 | `COOKED_MUTTON` | 6 | 0.8 | 9.6 | false |
| 14 | `COOKED_PORKCHOP` | 8 | 0.8 | 12.8 | false |
| 15 | `COOKED_RABBIT` | 5 | 0.6 | 6 | false |
| 16 | `COOKED_SALMON` | 6 | 0.8 | 9.6 | false |
| 17 | `COOKIE` | 2 | 0.1 | 0.4 | false |
| 18 | `DRIED_KELP` | 1 | 0.3 | 0.6 | false |
| 19 | `ENCHANTED_GOLDEN_APPLE` | 4 | 1.2 | 9.6 | true |
| 20 | `GOLDEN_APPLE` | 4 | 1.2 | 9.6 | true |
| 21 | `GOLDEN_CARROT` | 6 | 1.2 | 14.4 | false |
| 22 | `HONEY_BOTTLE` | 6 | 0.1 | 1.2 | true |
| 23 | `MELON_SLICE` | 2 | 0.3 | 1.2 | false |
| 24 | `MUSHROOM_STEW` | 6 | 0.6 (stew) | 7.2 | false |
| 25 | `MUTTON` | 2 | 0.3 | 1.2 | false |
| 26 | `POISONOUS_POTATO` | 2 | 0.3 | 1.2 | false |
| 27 | `PORKCHOP` | 3 | 0.3 | 1.8 | false |
| 28 | `POTATO` | 1 | 0.3 | 0.6 | false |
| 29 | `PUFFERFISH` | 1 | 0.1 | 0.2 | false |
| 30 | `PUMPKIN_PIE` | 8 | 0.3 | 4.8 | false |
| 31 | `RABBIT` | 3 | 0.3 | 1.8 | false |
| 32 | `RABBIT_STEW` | 10 | 0.6 (stew) | 12 | false |
| 33 | `ROTTEN_FLESH` | 4 | 0.1 | 0.8 | false |
| 34 | `SALMON` | 2 | 0.1 | 0.4 | false |
| 35 | `SPIDER_EYE` | 2 | 0.8 | 3.2 | false |
| 36 | `SUSPICIOUS_STEW` | 6 | 0.6 (stew) | 7.2 | true |
| 37 | `SWEET_BERRIES` | 2 | 0.1 | 0.4 | false |
| 38 | `GLOW_BERRIES` | 2 | 0.1 | 0.4 | false |
| 39 | `TROPICAL_FISH` | 1 | 0.1 | 0.2 | false |

The mapping from items to foods is read in the sibling parts that register the items (`Properties.food(Foods.X, ...)`).

### 8.3 `Consumables` (14 constants)

All use `Consumable.builder()` defaults of section 7.2 through `defaultFood()` (consume 1.6 s, `EAT`, eat sound,
particles on) or `defaultDrink()` (consume 1.6 s, `DRINK`, sound `entity.generic.drink` (string read in `SoundEvents`), particles off). `MobEffectInstance`
arguments are (effect, duration in ticks, amplifier).

| Constant | Base | Changes and on-consume effects |
|---|---|---|
| `DEFAULT_FOOD` | food | none |
| `DEFAULT_DRINK` | drink | none |
| `HONEY_BOTTLE` | drink | consume 2.0 s, sound `item.honey_bottle.drink` (string read in `SoundEvents`); remove effect `poison` |
| `OMINOUS_BOTTLE` | drink | sound after consuming `item.ominous_bottle.dispose` (string read in `SoundEvents`) |
| `DRIED_KELP` | food | consume 0.8 s |
| `CHICKEN` | food | apply `hunger` 600 ticks amplifier 0, probability 0.3 |
| `ENCHANTED_GOLDEN_APPLE` | food | apply together: `regeneration` 400 amp 1, `resistance` 6000 amp 0, `fire_resistance` 6000 amp 0, `absorption` 2400 amp 3 |
| `GOLDEN_APPLE` | food | apply together: `regeneration` 100 amp 1, `absorption` 2400 amp 0 |
| `POISONOUS_POTATO` | food | apply `poison` 100 amp 0, probability 0.6 |
| `PUFFERFISH` | food | apply together: `poison` 1200 amp 1, `hunger` 300 amp 2, `nausea` 300 amp 0 |
| `ROTTEN_FLESH` | food | apply `hunger` 600 amp 0, probability 0.8 |
| `SPIDER_EYE` | food | apply `poison` 100 amp 0 |
| `MILK_BUCKET` | drink | clear all effects |
| `CHORUS_FRUIT` | food | teleport randomly (default parameters of the constructor with no arguments) |

"apply" is `ApplyStatusEffectsConsumeEffect`: the constructor with one instance and a probability, or with a list
(probability then defaults to `1.0`, read: the one-instance and list-only constructors pass `fconst_1`), or with one instance alone. Effect ids: 46 (mob effects).
Consume effect types and wire ids: 46 §8.2. The effect engine (applying, clearing, stacking) is not specified here.

## 9. Data-driven item components: fuel, compost, brewing fuel

Fuel burn time, compost chance and brewing uses are not numbers in the item rows. They are **keys of context providers**
whose JSON is in the data pack (26 §9): `ContextIntProviders` and `ContextFloatProviders` name `ResourceKey`s into the
`context_int_provider` (26 files) and `context_float_provider` (4 files) registries (26 §1, 23). Item rows below and in
the sibling parts quote only the key.

| Component | Record | Meaning |
|---|---|---|
| `cooking_fuel` (85) | (burn time provider key, speed multiplier provider key) | `Properties.cookingFuel(key)` sets the speed key to `cooking/speed_default` |
| `brewing_fuel` (86) | (uses provider key, speed provider key) | `Properties.brewingFuel(key)` sets the speed key to `brewing/speed_default` |
| `compostable` (84) | (chance provider key) | `Properties.compostable(key)` |

How the providers evaluate, read from the 26 files (all values below were re-read from the jar in the fixing pass; paths `data/minecraft/context_int_provider/cooking/*.json`, `.../compostable/*.json`, `data/minecraft/context_float_provider/cooking/*.json` and `brewing/speed_default.json`; the predicate is `data/minecraft/predicate/block/fast_cooking.json`, a `match_block` on the list smoker, blast_furnace):

- `cooking/time_*` (18 keys): `div` of a constant "left" (ticks) by a `conditional` on the block predicate
  `block/fast_cooking` (the predicate matches the blocks `smoker` and `blast_furnace`): 1 (`cooking/normal_burn_time_reduction_factor`)
  when false, 2 (`cooking/fast_burn_time_reduction_factor`) when true. Burn time in ticks therefore is `left / factor` in the
  integer provider arithmetic of 26 §9 (division semantics there). Examples: `cooking/time_wood_blocks` left 300 (300 ticks in
  a furnace, 150 in a smoker or blast furnace); `cooking/time_coal_block` left 16000; `cooking/time_roots` left 300;
  `cooking/time_dry_plants` left 100 (each file read). The statement count of the keys: `cooking/time_roots` is used by exactly one statement of `Items` (`mangrove_roots`, mechanical count of the fixing pass).
- `cooking/speed_default`: `conditional` on `block/fast_cooking` between `cooking/normal_speed_multiplier` (1.0) and
  `cooking/fast_speed_multiplier` (2.0); `brewing/speed_default` is 1.0; `brewing/uses_default` is 20 (read).
- `compostable/*` (5 keys): a `number_dispatcher` whose single case, when the block is a `composter` with `level` 0, gives 1
  (the first item always raises an empty composter), else a `weighted_list` of {1, 0}; weights: `low` 30 for 1 and 70 for 0
  (30 percent), `low_medium` 50 and 50; `medium` 65 and 35 (65 percent), `medium_high` 85 and 15 (85 percent) (all four files read: the case list is the same in each, `match_block` composter with `level` 0 gives the constant 1, and the `weighted_list` weights are 30/70, 50/50, 65/35 and 85/15); `always_add_one` is the constant 1. The composter engine that rolls them (level step, result) is owned by the block
  behaviour documents (sibling of 29).

The keys that appear in rows 0 to 227 are `compostable/low`, `cooking/time_wood_blocks`, `cooking/time_dry_plants`,
`cooking/time_coal_block` and `cooking/time_roots`.

## 10. Row schema

Every part of the item registry uses the rows below (the same columns as 24 §7 where they apply).

| Column | Meaning |
|---|---|
| Id | the registry id (section 2) |
| Key | the item key path in `minecraft` |
| Class | the Java class of the item (`BlockItem` etc.) |
| Max stack | the `max_stack_size` of the prototype (64 unless a row says otherwise; 1 when it has durability) |
| Components beyond the common set | the components that the row adds to the 13 of section 7.1: `fuel <key>` = `cooking_fuel` with the burn-time provider `cooking/time_<key>`; `compostable <key>` = `compostable` with provider `compostable/<key>`; `fire_resistant` = `damage_resistant` for tag `is_fire`; `rarity <name>`; `none` = nothing |

For a block item the placed block has the same key (section 4.2), and its translation key is `block.minecraft.<key>`.
Sibling parts add columns only for components they introduce; they define them in their own header.

## 11. The rows: ids 0 to 227

Statement numbers 0 to 192 of `Items.<clinit>` (the last row, id 227, is the statement of `AZALEA_LEAVES`). Every class
is `BlockItem` except id 0. The key of every row is the lower-case field name and equals the block key (section 14,
check 5). Groups of equal rows, for reading: ids 1 to 62 plain; 63 to 73 planks with `fuel wood_blocks`; 74 and 75 (`crimson_planks`,
`warped_planks`) plain; 76 `bamboo_mosaic` fuel; 77 to 86 saplings (`compostable low`, `fuel dry_plants`); 87 to 110 plain;
111 `ancient_debris` fire resistant; 112 `coal_block` fuel `coal_block`; 116 `heavy_core` rarity epic; 120 to 127 the copper
block family; 130 `netherite_block` fire resistant; 163 to 172, 177 to 187, 190 to 199, 202 to 212 logs, bamboo blocks
and wood with `fuel wood_blocks`; 173 `mangrove_roots` (`compostable low`, `fuel roots`); 215 to 227 leaves (`compostable low`).

| Id | Key | Class | Max stack | Components beyond the common set (section 10) |
|---|---|---|---|---|
| 0 | `air` | AirItem | 64 | none |
| 1 | `stone` | BlockItem | 64 | none |
| 2 | `granite` | BlockItem | 64 | none |
| 3 | `polished_granite` | BlockItem | 64 | none |
| 4 | `diorite` | BlockItem | 64 | none |
| 5 | `polished_diorite` | BlockItem | 64 | none |
| 6 | `andesite` | BlockItem | 64 | none |
| 7 | `polished_andesite` | BlockItem | 64 | none |
| 8 | `deepslate` | BlockItem | 64 | none |
| 9 | `cobbled_deepslate` | BlockItem | 64 | none |
| 10 | `polished_deepslate` | BlockItem | 64 | none |
| 11 | `calcite` | BlockItem | 64 | none |
| 12 | `tuff` | BlockItem | 64 | none |
| 13 | `tuff_slab` | BlockItem | 64 | none |
| 14 | `tuff_stairs` | BlockItem | 64 | none |
| 15 | `tuff_wall` | BlockItem | 64 | none |
| 16 | `chiseled_tuff` | BlockItem | 64 | none |
| 17 | `polished_tuff` | BlockItem | 64 | none |
| 18 | `polished_tuff_slab` | BlockItem | 64 | none |
| 19 | `polished_tuff_stairs` | BlockItem | 64 | none |
| 20 | `polished_tuff_wall` | BlockItem | 64 | none |
| 21 | `tuff_bricks` | BlockItem | 64 | none |
| 22 | `tuff_brick_slab` | BlockItem | 64 | none |
| 23 | `tuff_brick_stairs` | BlockItem | 64 | none |
| 24 | `tuff_brick_wall` | BlockItem | 64 | none |
| 25 | `chiseled_tuff_bricks` | BlockItem | 64 | none |
| 26 | `sulfur` | BlockItem | 64 | none |
| 27 | `potent_sulfur` | BlockItem | 64 | none |
| 28 | `sulfur_slab` | BlockItem | 64 | none |
| 29 | `sulfur_stairs` | BlockItem | 64 | none |
| 30 | `sulfur_wall` | BlockItem | 64 | none |
| 31 | `polished_sulfur` | BlockItem | 64 | none |
| 32 | `polished_sulfur_slab` | BlockItem | 64 | none |
| 33 | `polished_sulfur_stairs` | BlockItem | 64 | none |
| 34 | `polished_sulfur_wall` | BlockItem | 64 | none |
| 35 | `sulfur_bricks` | BlockItem | 64 | none |
| 36 | `sulfur_brick_slab` | BlockItem | 64 | none |
| 37 | `sulfur_brick_stairs` | BlockItem | 64 | none |
| 38 | `sulfur_brick_wall` | BlockItem | 64 | none |
| 39 | `chiseled_sulfur` | BlockItem | 64 | none |
| 40 | `cinnabar` | BlockItem | 64 | none |
| 41 | `cinnabar_slab` | BlockItem | 64 | none |
| 42 | `cinnabar_stairs` | BlockItem | 64 | none |
| 43 | `cinnabar_wall` | BlockItem | 64 | none |
| 44 | `polished_cinnabar` | BlockItem | 64 | none |
| 45 | `polished_cinnabar_slab` | BlockItem | 64 | none |
| 46 | `polished_cinnabar_stairs` | BlockItem | 64 | none |
| 47 | `polished_cinnabar_wall` | BlockItem | 64 | none |
| 48 | `cinnabar_bricks` | BlockItem | 64 | none |
| 49 | `cinnabar_brick_slab` | BlockItem | 64 | none |
| 50 | `cinnabar_brick_stairs` | BlockItem | 64 | none |
| 51 | `cinnabar_brick_wall` | BlockItem | 64 | none |
| 52 | `chiseled_cinnabar` | BlockItem | 64 | none |
| 53 | `dripstone_block` | BlockItem | 64 | none |
| 54 | `grass_block` | BlockItem | 64 | none |
| 55 | `dirt` | BlockItem | 64 | none |
| 56 | `coarse_dirt` | BlockItem | 64 | none |
| 57 | `podzol` | BlockItem | 64 | none |
| 58 | `rooted_dirt` | BlockItem | 64 | none |
| 59 | `mud` | BlockItem | 64 | none |
| 60 | `crimson_nylium` | BlockItem | 64 | none |
| 61 | `warped_nylium` | BlockItem | 64 | none |
| 62 | `cobblestone` | BlockItem | 64 | none |
| 63 | `oak_planks` | BlockItem | 64 | fuel wood_blocks |
| 64 | `spruce_planks` | BlockItem | 64 | fuel wood_blocks |
| 65 | `birch_planks` | BlockItem | 64 | fuel wood_blocks |
| 66 | `jungle_planks` | BlockItem | 64 | fuel wood_blocks |
| 67 | `acacia_planks` | BlockItem | 64 | fuel wood_blocks |
| 68 | `cherry_planks` | BlockItem | 64 | fuel wood_blocks |
| 69 | `dark_oak_planks` | BlockItem | 64 | fuel wood_blocks |
| 70 | `pale_oak_planks` | BlockItem | 64 | fuel wood_blocks |
| 71 | `mangrove_planks` | BlockItem | 64 | fuel wood_blocks |
| 72 | `poplar_planks` | BlockItem | 64 | fuel wood_blocks |
| 73 | `bamboo_planks` | BlockItem | 64 | fuel wood_blocks |
| 74 | `crimson_planks` | BlockItem | 64 | none |
| 75 | `warped_planks` | BlockItem | 64 | none |
| 76 | `bamboo_mosaic` | BlockItem | 64 | fuel wood_blocks |
| 77 | `oak_sapling` | BlockItem | 64 | compostable low, fuel dry_plants |
| 78 | `spruce_sapling` | BlockItem | 64 | compostable low, fuel dry_plants |
| 79 | `birch_sapling` | BlockItem | 64 | compostable low, fuel dry_plants |
| 80 | `jungle_sapling` | BlockItem | 64 | compostable low, fuel dry_plants |
| 81 | `acacia_sapling` | BlockItem | 64 | compostable low, fuel dry_plants |
| 82 | `cherry_sapling` | BlockItem | 64 | compostable low, fuel dry_plants |
| 83 | `dark_oak_sapling` | BlockItem | 64 | compostable low, fuel dry_plants |
| 84 | `pale_oak_sapling` | BlockItem | 64 | compostable low, fuel dry_plants |
| 85 | `mangrove_propagule` | BlockItem | 64 | compostable low, fuel dry_plants |
| 86 | `poplar_sapling` | BlockItem | 64 | compostable low, fuel dry_plants |
| 87 | `bedrock` | BlockItem | 64 | none |
| 88 | `sand` | BlockItem | 64 | none |
| 89 | `suspicious_sand` | BlockItem | 64 | none |
| 90 | `suspicious_gravel` | BlockItem | 64 | none |
| 91 | `red_sand` | BlockItem | 64 | none |
| 92 | `gravel` | BlockItem | 64 | none |
| 93 | `coal_ore` | BlockItem | 64 | none |
| 94 | `deepslate_coal_ore` | BlockItem | 64 | none |
| 95 | `iron_ore` | BlockItem | 64 | none |
| 96 | `deepslate_iron_ore` | BlockItem | 64 | none |
| 97 | `copper_ore` | BlockItem | 64 | none |
| 98 | `deepslate_copper_ore` | BlockItem | 64 | none |
| 99 | `gold_ore` | BlockItem | 64 | none |
| 100 | `deepslate_gold_ore` | BlockItem | 64 | none |
| 101 | `redstone_ore` | BlockItem | 64 | none |
| 102 | `deepslate_redstone_ore` | BlockItem | 64 | none |
| 103 | `emerald_ore` | BlockItem | 64 | none |
| 104 | `deepslate_emerald_ore` | BlockItem | 64 | none |
| 105 | `lapis_ore` | BlockItem | 64 | none |
| 106 | `deepslate_lapis_ore` | BlockItem | 64 | none |
| 107 | `diamond_ore` | BlockItem | 64 | none |
| 108 | `deepslate_diamond_ore` | BlockItem | 64 | none |
| 109 | `nether_gold_ore` | BlockItem | 64 | none |
| 110 | `nether_quartz_ore` | BlockItem | 64 | none |
| 111 | `ancient_debris` | BlockItem | 64 | fire_resistant |
| 112 | `coal_block` | BlockItem | 64 | fuel coal_block |
| 113 | `raw_iron_block` | BlockItem | 64 | none |
| 114 | `raw_copper_block` | BlockItem | 64 | none |
| 115 | `raw_gold_block` | BlockItem | 64 | none |
| 116 | `heavy_core` | BlockItem | 64 | rarity epic |
| 117 | `amethyst_block` | BlockItem | 64 | none |
| 118 | `budding_amethyst` | BlockItem | 64 | none |
| 119 | `iron_block` | BlockItem | 64 | none |
| 120 | `copper_block` | BlockItem | 64 | none |
| 121 | `exposed_copper` | BlockItem | 64 | none |
| 122 | `weathered_copper` | BlockItem | 64 | none |
| 123 | `oxidized_copper` | BlockItem | 64 | none |
| 124 | `waxed_copper_block` | BlockItem | 64 | none |
| 125 | `waxed_exposed_copper` | BlockItem | 64 | none |
| 126 | `waxed_weathered_copper` | BlockItem | 64 | none |
| 127 | `waxed_oxidized_copper` | BlockItem | 64 | none |
| 128 | `gold_block` | BlockItem | 64 | none |
| 129 | `diamond_block` | BlockItem | 64 | none |
| 130 | `netherite_block` | BlockItem | 64 | fire_resistant |
| 131 | `chiseled_copper` | BlockItem | 64 | none |
| 132 | `exposed_chiseled_copper` | BlockItem | 64 | none |
| 133 | `weathered_chiseled_copper` | BlockItem | 64 | none |
| 134 | `oxidized_chiseled_copper` | BlockItem | 64 | none |
| 135 | `waxed_chiseled_copper` | BlockItem | 64 | none |
| 136 | `waxed_exposed_chiseled_copper` | BlockItem | 64 | none |
| 137 | `waxed_weathered_chiseled_copper` | BlockItem | 64 | none |
| 138 | `waxed_oxidized_chiseled_copper` | BlockItem | 64 | none |
| 139 | `cut_copper` | BlockItem | 64 | none |
| 140 | `exposed_cut_copper` | BlockItem | 64 | none |
| 141 | `weathered_cut_copper` | BlockItem | 64 | none |
| 142 | `oxidized_cut_copper` | BlockItem | 64 | none |
| 143 | `waxed_cut_copper` | BlockItem | 64 | none |
| 144 | `waxed_exposed_cut_copper` | BlockItem | 64 | none |
| 145 | `waxed_weathered_cut_copper` | BlockItem | 64 | none |
| 146 | `waxed_oxidized_cut_copper` | BlockItem | 64 | none |
| 147 | `cut_copper_stairs` | BlockItem | 64 | none |
| 148 | `exposed_cut_copper_stairs` | BlockItem | 64 | none |
| 149 | `weathered_cut_copper_stairs` | BlockItem | 64 | none |
| 150 | `oxidized_cut_copper_stairs` | BlockItem | 64 | none |
| 151 | `waxed_cut_copper_stairs` | BlockItem | 64 | none |
| 152 | `waxed_exposed_cut_copper_stairs` | BlockItem | 64 | none |
| 153 | `waxed_weathered_cut_copper_stairs` | BlockItem | 64 | none |
| 154 | `waxed_oxidized_cut_copper_stairs` | BlockItem | 64 | none |
| 155 | `cut_copper_slab` | BlockItem | 64 | none |
| 156 | `exposed_cut_copper_slab` | BlockItem | 64 | none |
| 157 | `weathered_cut_copper_slab` | BlockItem | 64 | none |
| 158 | `oxidized_cut_copper_slab` | BlockItem | 64 | none |
| 159 | `waxed_cut_copper_slab` | BlockItem | 64 | none |
| 160 | `waxed_exposed_cut_copper_slab` | BlockItem | 64 | none |
| 161 | `waxed_weathered_cut_copper_slab` | BlockItem | 64 | none |
| 162 | `waxed_oxidized_cut_copper_slab` | BlockItem | 64 | none |
| 163 | `oak_log` | BlockItem | 64 | fuel wood_blocks |
| 164 | `spruce_log` | BlockItem | 64 | fuel wood_blocks |
| 165 | `birch_log` | BlockItem | 64 | fuel wood_blocks |
| 166 | `jungle_log` | BlockItem | 64 | fuel wood_blocks |
| 167 | `acacia_log` | BlockItem | 64 | fuel wood_blocks |
| 168 | `cherry_log` | BlockItem | 64 | fuel wood_blocks |
| 169 | `pale_oak_log` | BlockItem | 64 | fuel wood_blocks |
| 170 | `dark_oak_log` | BlockItem | 64 | fuel wood_blocks |
| 171 | `mangrove_log` | BlockItem | 64 | fuel wood_blocks |
| 172 | `poplar_log` | BlockItem | 64 | fuel wood_blocks |
| 173 | `mangrove_roots` | BlockItem | 64 | compostable low, fuel roots |
| 174 | `muddy_mangrove_roots` | BlockItem | 64 | none |
| 175 | `crimson_stem` | BlockItem | 64 | none |
| 176 | `warped_stem` | BlockItem | 64 | none |
| 177 | `bamboo_block` | BlockItem | 64 | fuel wood_blocks |
| 178 | `stripped_oak_log` | BlockItem | 64 | fuel wood_blocks |
| 179 | `stripped_spruce_log` | BlockItem | 64 | fuel wood_blocks |
| 180 | `stripped_birch_log` | BlockItem | 64 | fuel wood_blocks |
| 181 | `stripped_jungle_log` | BlockItem | 64 | fuel wood_blocks |
| 182 | `stripped_acacia_log` | BlockItem | 64 | fuel wood_blocks |
| 183 | `stripped_cherry_log` | BlockItem | 64 | fuel wood_blocks |
| 184 | `stripped_dark_oak_log` | BlockItem | 64 | fuel wood_blocks |
| 185 | `stripped_pale_oak_log` | BlockItem | 64 | fuel wood_blocks |
| 186 | `stripped_mangrove_log` | BlockItem | 64 | fuel wood_blocks |
| 187 | `stripped_poplar_log` | BlockItem | 64 | fuel wood_blocks |
| 188 | `stripped_crimson_stem` | BlockItem | 64 | none |
| 189 | `stripped_warped_stem` | BlockItem | 64 | none |
| 190 | `stripped_oak_wood` | BlockItem | 64 | fuel wood_blocks |
| 191 | `stripped_spruce_wood` | BlockItem | 64 | fuel wood_blocks |
| 192 | `stripped_birch_wood` | BlockItem | 64 | fuel wood_blocks |
| 193 | `stripped_jungle_wood` | BlockItem | 64 | fuel wood_blocks |
| 194 | `stripped_acacia_wood` | BlockItem | 64 | fuel wood_blocks |
| 195 | `stripped_cherry_wood` | BlockItem | 64 | fuel wood_blocks |
| 196 | `stripped_dark_oak_wood` | BlockItem | 64 | fuel wood_blocks |
| 197 | `stripped_pale_oak_wood` | BlockItem | 64 | fuel wood_blocks |
| 198 | `stripped_mangrove_wood` | BlockItem | 64 | fuel wood_blocks |
| 199 | `stripped_poplar_wood` | BlockItem | 64 | fuel wood_blocks |
| 200 | `stripped_crimson_hyphae` | BlockItem | 64 | none |
| 201 | `stripped_warped_hyphae` | BlockItem | 64 | none |
| 202 | `stripped_bamboo_block` | BlockItem | 64 | fuel wood_blocks |
| 203 | `oak_wood` | BlockItem | 64 | fuel wood_blocks |
| 204 | `spruce_wood` | BlockItem | 64 | fuel wood_blocks |
| 205 | `birch_wood` | BlockItem | 64 | fuel wood_blocks |
| 206 | `jungle_wood` | BlockItem | 64 | fuel wood_blocks |
| 207 | `acacia_wood` | BlockItem | 64 | fuel wood_blocks |
| 208 | `cherry_wood` | BlockItem | 64 | fuel wood_blocks |
| 209 | `pale_oak_wood` | BlockItem | 64 | fuel wood_blocks |
| 210 | `dark_oak_wood` | BlockItem | 64 | fuel wood_blocks |
| 211 | `mangrove_wood` | BlockItem | 64 | fuel wood_blocks |
| 212 | `poplar_wood` | BlockItem | 64 | fuel wood_blocks |
| 213 | `crimson_hyphae` | BlockItem | 64 | none |
| 214 | `warped_hyphae` | BlockItem | 64 | none |
| 215 | `oak_leaves` | BlockItem | 64 | compostable low |
| 216 | `spruce_leaves` | BlockItem | 64 | compostable low |
| 217 | `birch_leaves` | BlockItem | 64 | compostable low |
| 218 | `jungle_leaves` | BlockItem | 64 | compostable low |
| 219 | `acacia_leaves` | BlockItem | 64 | compostable low |
| 220 | `cherry_leaves` | BlockItem | 64 | compostable low |
| 221 | `dark_oak_leaves` | BlockItem | 64 | compostable low |
| 222 | `pale_oak_leaves` | BlockItem | 64 | compostable low |
| 223 | `mangrove_leaves` | BlockItem | 64 | compostable low |
| 224 | `red_poplar_leaves` | BlockItem | 64 | compostable low |
| 225 | `orange_poplar_leaves` | BlockItem | 64 | compostable low |
| 226 | `yellow_poplar_leaves` | BlockItem | 64 | compostable low |
| 227 | `azalea_leaves` | BlockItem | 64 | compostable low |

## 12. Part index (family map of ids 228 to 1657)

The siblings (parts 2 to 8, plus the continuation x1) split the remaining 1430 items (1658 - 228) among themselves
and read their rows in full; **the boundaries of their ranges belong to those documents** and are not stated here
(their own headers differ in how they number statements and ids, so this map does not depend on them). Only part 2
was cross-checked: its header states ids 228 to 455 (`flowering_azalea_leaves` to `deepslate_bricks`), which matches
the id arithmetic of section 2.

The table lists, for the whole registry, every item class that the 1218 non-collection statements of `Items` give
their item, with a count computed in the fixing pass from the bytecode: the class is taken from the method handle of
the statement's factory (`X::new`) or, for a lambda factory, from the class that the lambda body instantiates
(read). "Id of first member" is the lowest id of the class; members of one class are generally **not**
consecutive, so the column is not the start of a range. The 35 collection statements (440 items) are not
in the counts, because their factories are lambdas that delegate to the register helpers and their classes were not
traced here (Open question 9; the sibling parts that cover them read the classes).

| Id of first member | Field of first member | Class | Statements | Basis |
|---|---|---|---|---|
| 0 | `AIR` | `AirItem` | 1 | read |
| 1 | `STONE` | `BlockItem` (default factory, or a lambda that only changes the properties; members run to id 1656) | 671 | read |
| 339 | `SMALL_DRIPLEAF` | `DoubleHighBlockItem` (11 through a lambda, 10 through a direct constructor reference; ids 339 to 901) | 21 | read |
| 395 | `TORCH` | `StandingAndWallBlockItem` (all through a lambda; ids 395 to 1390) | 33 | read |
| 486 | `RESIN_CLUMP` | plain `Item` (a constructor reference, a plain `registerItem`, or a lambda that only changes the properties; largest id 1657) | 256 | read |
| 497 | `LILY_PAD` | `PlaceOnWaterBlockItem` (second member at id 1576) | 2 | read |
| 529 | `COMMAND_BLOCK` | `GameMasterBlockItem` (ids 529, 648, 649 and 997 to 1000: `command_block`, `repeating_command_block`, `chain_command_block`, `structure_block`, `jigsaw`, `test_block`, `test_instance_block`) | 7 | read |
| 823 | `SCAFFOLDING` | `ScaffoldingBlockItem` (one member) | 1 | read |
| 966 | `MINECART` | `MinecartItem` (ids 966 to 968 and later ones, last id 1414 `command_block_minecart`) | 6 | read |
| 971 | `CARROT_ON_A_STICK` | `FoodOnAStickItem` (ids 971, 972) | 2 | read |
| 975 | `OAK_BOAT` | `BoatItem` (ids 975 to 996, `oak_boat` to `bamboo_chest_raft`) | 22 | read |
| 1005 | `FLINT_AND_STEEL` | one-member classes, see below | 46 in all (including `AirItem` and `ScaffoldingBlockItem` above) | read |
| 1115 | `OAK_HANGING_SIGN` | `HangingSignItem` (ids 1115 to 1127) | 13 | read |
| 1128 | `BUCKET` | `BucketItem` 3 (ids 1128 to 1130) | 3 | read |
| 1131 | `POWDER_SNOW_BUCKET` | `SolidBucketItem` (one member, counted among the one-member classes) | 1 | read |
| 1135 | `PUFFERFISH_BUCKET` | `MobBucketItem` (ids 1135 to 1141, last `tadpole_bucket`) | 7 | read |
| 1148 | `EGG` | `EggItem` (ids 1148 to 1150: `egg`, `blue_egg`, `brown_egg`) | 3 | read |
| 1238 | `FILLED_MAP` | `MapItem` (ids 1238 to 1254, last `warm_ocean_ruins_map`) | 17 | read |
| 1280 | `CHICKEN_SPAWN_EGG` | `SpawnEggItem`, ids 1280 to 1367 | 88 | read |
| 1375 | `ITEM_FRAME` | `ItemFrameItem` (ids 1375, 1376) | 2 | read |
| 1579 | `NETHERITE_UPGRADE_SMITHING_TEMPLATE` | `SmithingTemplateItem` (ids 1579 to 1597) | 19 | inferred: the factory is a static method reference whose name says this class; its body was not read |

The one-member classes (each exactly one statement, id of the member in parentheses): `FlintAndSteelItem` (1005),
`BowItem` (1008), `ArrowItem` (1009), `HangingEntityItem` (1099), `SolidBucketItem` (1131), `SnowballItem` (1132), `CompassItem` (1151),
`BundleItem` (1153), `FishingRodItem` (1186), `SpyglassItem` (1188), `InkSacItem` (1196), `GlowInkSacItem` (1197),
`BoneMealItem` (1215), `ShearsItem` (1255), `EnderpearlItem` (1265), `BottleItem` (1270), `PotionItem` (1271),
`EnderEyeItem` (1278), `ExperienceBottleItem` (1368), `FireChargeItem` (1369), `WindChargeItem` (1370),
`WritableBookItem` (1371), `WrittenBookItem` (1372), `MaceItem` (1374), `EmptyMapItem` (1382), `PlayerHeadItem` (1386),
`FireworkRocketItem` (1393), `ArmorStandItem` (1405), `LeadItem` (1412), `NameTagItem` (1413), `EndCrystalItem` (1433),
`SplashPotionItem` (1442), `SpectralArrowItem` (1443), `TippedArrowItem` (1444), `LingeringPotionItem` (1445),
`ShieldItem` (1446), `KnowledgeBookItem` (1458), `DebugStickItem` (1459), `DiscFragmentItem` (1482), `TridentItem`
(1483), `CrossbowItem` (1491), `InstrumentItem` (1504), `HoneycombItem` (1530), `BrushItem` (1578), plus `AirItem` (0)
and `ScaffoldingBlockItem` (823), which makes 46 (44 names in the list above plus these two). (Their ids come from the same id arithmetic as section 2;
a registry dump from the extraction tool, 22, would confirm them.)

Sum check (statement counts, 1218 in all): `BlockItem` 671, plain `Item` 256, `SpawnEggItem` 88, `StandingAndWallBlockItem` 33,
`BoatItem` 22, `DoubleHighBlockItem` 21, `SmithingTemplateItem` 19, `MapItem` 17, `HangingSignItem` 13, `GameMasterBlockItem` 7,
`MobBucketItem` 7, `MinecartItem` 6, `BucketItem` 3, `EggItem` 3, `PlaceOnWaterBlockItem` 2, `FoodOnAStickItem` 2,
`ItemFrameItem` 2 add up to 1172, and the 46 one-member classes bring it to 1218.

Ids 228 to 455 are a **sibling-part range** (part 2), not a family; the first `DoubleHighBlockItem` (id 339) and
the first `StandingAndWallBlockItem` (id 395) fall inside it.

## 13. Worked examples

1. **Id of `stone`.** `STONE` is statement 1, no collection precedes it, so id 1. Its key is `stone`, class `BlockItem`,
   max stack 64, description id `block.minecraft.stone`, `item_model` `minecraft:stone`, 13 default components.
2. **Id of `gold_block`.** `COPPER_BLOCK` is statement 120 and registers 8 items (ids 120 to 127); `EXPOSED_COPPER`
   is not a separate statement. `GOLD_BLOCK` is statement 121, id = 121 + 7 = 128.
3. **Copper block family keys.** Ids 120 to 127: `copper_block`, `exposed_copper`, `weathered_copper`,
   `oxidized_copper`, `waxed_copper_block`, `waxed_exposed_copper`, `waxed_weathered_copper`, `waxed_oxidized_copper`.
   Ids 131 to 138 (statement 124, `CHISELED_COPPER`): `chiseled_copper`, `exposed_chiseled_copper`, `weathered_chiseled_copper`,
   `oxidized_chiseled_copper`, `waxed_chiseled_copper`, `waxed_exposed_chiseled_copper`, `waxed_weathered_chiseled_copper`,
   `waxed_oxidized_chiseled_copper`.
4. **A saplings row.** `oak_sapling` (id 77): `BlockItem`, 64, `compostable` provider `compostable/low` (30 percent chance
   of raising the composter level, and a certain raise when the composter is empty), `cooking_fuel` with
   `cooking/time_dry_plants` (100 ticks in a furnace, 50 in a smoker).
5. **Fuel in a smoker.** `oak_log` (id 163) has `cooking/time_wood_blocks` (left 300): 300 ticks in a furnace and `300 / 2
   = 150` in a smoker or a blast furnace.
6. **Saturation.** `Foods.COOKED_BEEF` (nutrition 8, modifier 0.8): saturation 8 x 0.8 x 2 = 12.8. `Foods.GOLDEN_CARROT`:
   6 x 1.2 x 2 = 14.4.
7. **Durability bar.** An item of `max_damage` 250 at damage 100: width `round(13 - 100 x 13 / 250) = round(7.8) = 8`; `f = 150 / 250
   = 0.6`; colour `hsvToRgb(0.2, 1, 1)`.
8. **Placing.** A player right-clicks the top face of grass with an `oak_sapling` stack: `BlockItem.useOn` runs `place`; the
   block state is the sapling default; the block is set with flags 11; the placed sound is the sapling's place sound at
   volume `(v + 1) / 2` and pitch `p x 0.8`; the stack loses 1 (creative mode excepted).

## 14. Validation

Checks performed while reading (each is a count or a comparison against the artifact):

| # | Check | Result |
|---|---|---|
| 1 | `Items` `public static final` fields | 1253; `putstatic` statements in `<clinit>` 1253; same order |
| 2 | Fields whose type is an `Item` (not a collection) | 1218; collection fields 35 (20 `ColorCollection`, 15 `WeatheringCopperCollection`) |
| 3 | Items registered | 1218 + 20 x 16 + 15 x 8 = 1658 |
| 4 | Statements per call kind | 749 / 17 / 364 / 88 / 16 / 4 / 15 (section 2.4); recounted in the fixing pass with the method of section 2.4: `registerBlock` 749 (388 + 177 + 104 + 48 + 30 + 1 + 1 over its eight overload shapes), `registerItem` 381 (17 with a `BlockItemIds` constant, 364 without), `registerSpawnEgg` 88, `registerBlockItems` 16, `ColorCollection.registerItems` 4, `WeatheringCopperCollection.registerItems` 15; total 1253 |
| 5 | Rows 0 to 227: key equals the lower-case `BlockItemIds` field name, and the item key equals the block key | all 228 rows (air included) |
| 6 | The last row of the range | id 227, statement 192, `AZALEA_LEAVES`; id 228 is `FLOWERING_AZALEA_LEAVES` |
| 7 | Rows with a collection statement in 0 to 227 | statement 120 (ids 120 to 127), 124 (131 to 138), 125 (139 to 146), 126 (147 to 154), 127 (155 to 162) |

An implementation test: build the id table from the registration order and compare these anchors: id 0 `air`, id 1
`stone`, id 63 `oak_planks`, id 77 `oak_sapling`, id 87 `bedrock`, id 111 `ancient_debris`, id 120 `copper_block`, id 128
`gold_block`, id 163 `oak_log`, id 215 `oak_leaves`, id 227 `azalea_leaves`; total count 1658. A prototype test: the component
map of `stone` has exactly the 13 entries of section 7.1; `oak_planks` additionally has `cooking_fuel`; `item_name` is
the translatable text of `block.minecraft.stone`.

## 15. Open questions

1. The brief's split 773 `registerBlock`, 392 `registerItem`, 88 spawn eggs (total 1253) could not be reproduced; the counts of
   section 2.4 (sum 1253) are from the final registration call of each statement, and were recounted in the fixing pass with the
   same result (749 / 381 / 88 / 35). The brief's figures exceed the recount by 24 and 11, whose sum is the 35 collection
   statements: the brief probably assigned the collections to the two larger groups (inferred, not checkable from the artifact). The brief's total of "1253 items" is the
   field count; the registered count is 1658. The ids were computed from the code, not compared with a registry dump
   (the extraction tool, 22, can compare them).
2. Resolved: `prefixWithState` calls `zipMap(PREFIXES, names, f)` and `f` (`lambda$prefixWithState$0(String,String)`) concatenates its first argument and then its second with the recipe `\u0001\u0001`, so the prefix comes first (read). The inner per-state zip of the two `ByState` records was not traced separately; a registry dump (22) would confirm `waxed_copper_block`.
3. The data component initialisers are built when the registries exist; whether an item with a `delayedComponent` has a
   usable prototype before that (a client in the configuration phase) was not traced (04 open question).
4. `Item.CODEC_WITH_BOUND_COMPONENTS` (a validation that the holder's components are bound) was seen but its use is not traced.
5. Section 12 is a family map only; the sibling parts read each row and class.
6. Display of item names: the translation texts (`block.minecraft.*`, `item.minecraft.*`) are in the language file
    (design map GAP-27) and are not given here.
7. Spawn egg behaviour (`SpawnEggItem.useOn` and `use`, the spawn offset, the baby spawn) is for the sibling part that registers
    the eggs.
8. `BlockItem.canFitInsideContainerItems` (false for a shulker box block) and `BlockItem.onDestroyed` were taken over from the first
   reading and not re-traced in the fixing pass; `StandingAndWallBlockItem` and `DoubleHighBlockItem` (section 5.3) were likewise not
   re-traced. The `Item.Properties` builder rows of section 6.4 other than `durability` (read: `max_damage`, then `max_stack_size`
   1, then `damage` 0) were not spot-checked; the armor rows (`humanoidArmor`, `wolfArmor`, `horseArmor`, `nautilusArmor`) are
   verified in the sibling part that registers armor (part 4 and later).
9. The item classes of the 35 collection statements (440 items) are not in the section 12 counts: their factories are lambdas that
   delegate to the register helpers, and the class that finally builds each item was not traced here. The class of each plain `Item`
   and `BlockItem` statement whose factory is a lambda that only changes properties was not separately inspected (the lambda bodies
   contain no `new` of an item class, read), and `SmithingTemplateItem` is inferred (section 12).
