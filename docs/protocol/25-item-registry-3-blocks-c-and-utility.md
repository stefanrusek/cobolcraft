# Item registry, part 3: block items from `polished_deepslate_wall` to `activator_rail`, saddle, harnesses, minecarts and elytra (statements 456 to 694, ids 550 to 974)

| Item | Value |
|---|---|
| Covers | The rows of the item registry for statements 456 to 694 of `Items.<clinit>`, which are registry ids 550 to 974 (425 items): the block items from `polished_deepslate_wall` to `activator_rail` (walls, anvils, quartz, terracotta, carpets, glass, shulker boxes, glazed terracotta, concrete, corals, redstone parts, buttons, plates, doors, trapdoors, fence gates, rails), then `saddle`, the 16 harnesses, the five minecart items, `carrot_on_a_stick`, `warped_fungus_on_a_stick`, `phantom_membrane` and `elytra`. Also the item classes and components that these rows introduce: `GameMasterBlockItem`, `MinecartItem`, `FoodOnAStickItem`, the `equippable` component (saddle, harness, carpet, elytra), the `container` and `block_state` components, the glider default, and the fuel and compost keys used. `PlaceOnWaterBlockItem` (lily pad, id 497) is also read, because it is the one class in the neighbouring range that no earlier document reads. Section 8 adds beds and banners, which sit at ids 1219 to 1234 and 1417 to 1432 |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of lambdas) and of data files in the jar (`unzip -p`), with no execution. Class, method and field names in backticks say where a fact was read. Values not read are marked "(inferred)" or "(recalled, not verified)" and are listed in the Open questions |
| Status | Round RS5, part 3 of 8 (design map Part 5 GAP-2, Part 6 row RS5) |
| Siblings | Part 1 [25-item-registry-1-model-and-blocks-a.md](25-item-registry-1-model-and-blocks-a.md) owns the shared model: id rule, collections, registration helpers, `Item.Properties`, the default components, the row schema. This part cites it as "25-1 §n" and does not repeat it. Part 2 covers statements 228 to 455 (ids 308 to 549), part 4 starts at statement 695 (`oak_boat`, id 975) |

"04 §5" means section 5 of [04-registry-sync.md](04-registry-sync.md); "17 §1" is
[17-tools-weapons-and-combat.md](17-tools-weapons-and-combat.md); "24" is the block registry
([24-block-registry-1-model-and-foundation.md](24-block-registry-1-model-and-foundation.md) and its parts); "26 §9" is
[26-loot-and-predicates.md](26-loot-and-predicates.md); "29" is
[29-block-updates-and-placement.md](29-block-updates-and-placement.md); "44-8" is
[44-residual-mob-questions-8-vehicles-and-projectiles.md](44-residual-mob-questions-8-vehicles-and-projectiles.md); "46 §8" is
[46-registry-ids.md](46-registry-ids.md). The design map is `docs/design/README.md`.

Data versus code (design map R7). Ids, keys, item classes and default components are code and are given in full. Item
models, recipes, loot tables, tag files and the JSON of `context_int_provider` are data that the extraction tool (22)
copies out of the jar; this document names the schema and the keys the code reads, and quotes a data value only where an
engine needs it to be understood.

## Contents

1. Scope and statement numbers
2. Id arithmetic for this range
3. The construction groups (every row of the range, by family)
4. Item classes read in this range
5. Components introduced or used here
6. Fuel and compost keys used in this range
7. The complete id to key table (ids 550 to 974)
8. Beds and banners (outside the id range)
9. Worked examples
10. Validation
11. Open questions

## 1. Scope and statement numbers

- The scope is given by statement numbers 456 to 694, where `BONE_BLOCK` is 500, `STONE_STAIRS` 550,
  `TRIPWIRE_HOOK` 600, `WARPED_DOOR` 650, `SADDLE` 684, the minecart items 686 to 690 and `ELYTRA` 694. These are
  **statement numbers** of `Items.<clinit>` (the position in the sequence of the 1253 `putstatic` statements, the
  "Statement" column of 25-1 §2.3 and §4.3), not registry ids. **Statement numbers are zero-based**: the first `putstatic` of `Items.<clinit>` is statement 0, so
  `polished_deepslate_wall` (456) is the 457th `putstatic` in the order read and `activator_rail` (683) the 684th; an
  implementer counting `putstatic` lines from 1 gets a number one higher than every statement number in this document and
  in 25-1. Eleven statements here register 16 items and three register
  8 (25-1 §2.3), so ids run ahead of statement numbers. Read in this round: statement 456 is `polished_deepslate_wall`
  (id 550), 500 `bone_block` (654), 550 `stone_stairs` (794), 600 `tripwire_hook` (851), 650 `warped_door` (901), 683
  `activator_rail` (948), 684 `saddle` (949), 685 `harness` (the collection, ids 950 to 965), 686 to 690 the five
  minecart items (966 to 970), 691 and 692 the two on-a-stick items (971, 972), 693 `phantom_membrane` (973), 694 `elytra`
  (974). So statements 686 to 693 are five minecarts and three non-minecart items; and statement 695
  is `oak_boat` (975), the first row of part 4.
- This document therefore covers **statements 456 to 694, ids 550 to 974**: 239 statements (456 to 694) of which 11
  are colour collections (10 block collections and `harness`) and 3 are weathering collections (`lightning_rod`,
  `copper_door`, `copper_trapdoor`): 239 + 11 x 15 + 3 x 7 = 425 items. Part 2 ends with id 549
  (`cobbled_deepslate_wall` is statement 455, id 549).
- Not in this range: the 16 beds (statement 894, ids 1219 to 1234) and the 16 banners
  (statement 1077, ids 1417 to 1432). Their construction is read and given in section 8 so that a reader of this part
  finds it.
- Each row's id is the number of registrations before it (25-1 §2.1). The ids were computed from the statement
  sequence with the collection sizes of 25-1 §2.3 and agree with every first and last id in that table
  (section 10 check 2).

## 2. Id arithmetic for this range

Collections in this range (25-1 §2.3 gives the rule; first and last id computed here and equal to 25-1's table):

| Field | Kind | Items | Ids | Key pattern |
|---|---|---|---|---|
| `DYED_TERRACOTTA` | colour (block) | 16 | 561 to 576 | `<colour>_terracotta` |
| `CARPET` | colour (block) | 16 | 580 to 595 | `<colour>_carpet` |
| `STAINED_GLASS` | colour (block) | 16 | 605 to 620 | `<colour>_stained_glass` |
| `STAINED_GLASS_PANE` | colour (block) | 16 | 621 to 636 | `<colour>_stained_glass_pane` |
| `DYED_SHULKER_BOX` | colour (block) | 16 | 657 to 672 | `<colour>_shulker_box` |
| `GLAZED_TERRACOTTA` | colour (block) | 16 | 673 to 688 | `<colour>_glazed_terracotta` |
| `CONCRETE` | colour (block) | 16 | 689 to 704 | `<colour>_concrete` |
| `CONCRETE_STAIRS` | colour (block) | 16 | 705 to 720 | `<colour>_concrete_stairs` |
| `CONCRETE_SLAB` | colour (block) | 16 | 721 to 736 | `<colour>_concrete_slab` |
| `CONCRETE_POWDER` | colour (block) | 16 | 737 to 752 | `<colour>_concrete_powder` |
| `LIGHTNING_ROD` | weathering | 8 | 840 to 847 | `lightning_rod`, `exposed_lightning_rod`, `weathered_lightning_rod`, `oxidized_lightning_rod`, then the same four with `waxed_` in front |
| `COPPER_DOOR` | weathering | 8 | 902 to 909 | `copper_door`, ..., `waxed_oxidized_copper_door` |
| `COPPER_TRAPDOOR` | weathering | 8 | 924 to 931 | `copper_trapdoor`, ..., `waxed_oxidized_copper_trapdoor` |
| `HARNESS` | colour (item) | 16 | 950 to 965 | `<colour>_harness` |

Colour order in every colour collection (`ColorCollection.zipMap`, which applies the factory to `white`, `orange`,
`magenta`, `light_blue`, `yellow`, `lime`, `pink`, `gray`, `light_gray`, `cyan`, `purple`, `blue`, `brown`, `green`,
`red`, `black` in that order; names from `DyeColor`, read: `light_blue`, `light_gray` with an underscore). The colour is
joined in front of the base name with an underscore (`ColorCollection.prefixWithColor`, recipe `\u0001_\u0001`). The base
strings were read from `BlockItemIds`: `terracotta`, `carpet`, `stained_glass`, `stained_glass_pane`, `shulker_box`,
`glazed_terracotta`, `concrete`, `concrete_stairs`, `concrete_slab`, `concrete_powder`, and from `ItemIds`: `harness`. The
single-item rows have as key the lower-case field name (checked for all 425 rows: the key read from `BlockItemIds` or
`ItemIds` equals the lower-case field name, with the one exception `REDSTONE`: the `BlockItemIds` field is named `REDSTONE_DUST` (string `redstone`) while the `Items` field is `REDSTONE`; its block is `redstone_wire`, 25-1 §4.3. In this range `REDSTONE` is the only mismatch; mismatches exist elsewhere, for example `TRIPWIRE` giving `string`, but they are outside this range).

## 3. The construction groups (every row of the range, by family)

Column conventions are those of 25-1 §10. "Common set" is the default component set of 25-1 §7.1. "fuel K" is
`cooking_fuel` with burn-time provider `cooking/time_K` (and speed provider `cooking/speed_default`, 25-1 §9);
"compostable K" is `compostable` with provider `compostable/K`; values behind the keys are in section 6. Every
`BlockItem` row is registered through `registerBlock`, which also adds the block's required feature flags (25-1 §3) and
gives the item the description id prefix `block.` (25-1 §6.3); the one row marked "item prefix" (`redstone`) uses the `item.` prefix.
Max stack is 64 unless stated.

| Ids | Keys | Class | Max stack | Components beyond the common set |
|---|---|---|---|---|
| 550 to 560 | `polished_deepslate_wall`, `deepslate_brick_wall`, `deepslate_tile_wall`, `anvil`, `chipped_anvil`, `damaged_anvil`, `chiseled_quartz_block`, `quartz_block`, `quartz_bricks`, `quartz_pillar`, `quartz_stairs` | `BlockItem` | 64 | none |
| 561 to 576 | `<colour>_terracotta` | `BlockItem` | 64 | none |
| 577 | `barrier` | `BlockItem` | 64 | rarity epic |
| 578 | `light` | `BlockItem` | 64 | rarity epic; `block_state` = {`level` = `15`} (section 5.2) |
| 579 | `hay_block` | `BlockItem` | 64 | compostable medium_high |
| 580 to 595 | `<colour>_carpet` | `BlockItem` | 64 | fuel wool_carpets; `equippable` carpet(colour) (section 5.1) |
| 596 to 598 | `terracotta`, `packed_ice`, `dirt_path` | `BlockItem` | 64 | none |
| 599 to 602 | `sunflower`, `lilac`, `rose_bush`, `peony` | `DoubleHighBlockItem` | 64 | compostable medium |
| 603 | `tall_grass` | `DoubleHighBlockItem` | 64 | compostable low_medium |
| 604 | `large_fern` | `DoubleHighBlockItem` | 64 | compostable medium |
| 605 to 647 | stained glass (605 to 620), stained glass panes (621 to 636), prismarine family and `sea_lantern` (637 to 643), red sandstone family (644 to 647) | `BlockItem` | 64 | none |
| 648, 649 | `repeating_command_block`, `chain_command_block` | `GameMasterBlockItem` | 64 | rarity epic |
| 650 | `magma_block` | `BlockItem` | 64 | none |
| 651, 652 | `nether_wart_block`, `warped_wart_block` | `BlockItem` | 64 | compostable medium_high |
| 653, 654 | `red_nether_bricks`, `bone_block` | `BlockItem` | 64 | none |
| 655 | `structure_void` | `BlockItem` | 64 | rarity epic |
| 656 | `shulker_box` | `BlockItem` | **1** | `container` = empty (section 5.3) |
| 657 to 672 | `<colour>_shulker_box` | `BlockItem` | **1** | `container` = empty |
| 673 to 753 | glazed terracotta (673 to 688), concrete (689 to 704), concrete stairs (705 to 720), concrete slabs (721 to 736), concrete powder (737 to 752), `turtle_egg` (753) | `BlockItem` | 64 | none |
| 754 | `sniffer_egg` | `BlockItem` | 64 | rarity uncommon |
| 755 to 775 | `dried_ghast`, the dead coral blocks, live coral blocks, live corals, dead corals (the 20 coral and coral block rows 756 to 775 in the order of section 7) | `BlockItem` | 64 | none |
| 776 to 785 | the ten coral fans: `tube`, `brain`, `bubble`, `fire`, `horn`, then the five `dead_` fans | `StandingAndWallBlockItem(fan block, matching `*_coral_wall_fan` block, DOWN)` (25-1 §5.3) | 64 | none |
| 786 | `blue_ice` | `BlockItem` | 64 | none |
| 787 | `conduit` | `BlockItem` | 64 | rarity uncommon |
| 788 to 822 | 18 stairs (ids 788 to 805, `polished_granite_stairs` to `deepslate_tile_stairs`, with `stone_stairs` at 794 among them) and 17 slabs (ids 806 to 822, (`polished_granite_slab` to `deepslate_tile_slab`; 35 rows in all) | `BlockItem` | 64 | none |
| 823 | `scaffolding` | `ScaffoldingBlockItem` (25-1 §5.3) | 64 | fuel bamboo |
| 824 | `redstone` | `BlockItem` made by `createBlockItemWithCustomItemName` over block `redstone_wire` (item prefix) | 64 | `provides_trim_material` = `redstone` (delayed holder component, section 5.5) |
| 825 | `redstone_torch` | `StandingAndWallBlockItem(redstone_torch, redstone_wall_torch, DOWN)` | 64 | none |
| 826 to 833 | `redstone_block`, `repeater`, `comparator`, `piston`, `sticky_piston`, `slime_block`, `honey_block`, `observer` | `BlockItem` | 64 | none |
| 834 to 836 | `hopper`, `dispenser`, `dropper` | `BlockItem` | 64 | `container` = empty |
| 837 | `lectern` | `BlockItem` | 64 | fuel wood_blocks |
| 838 to 847 | `target`, `lever`, the 8 lightning rods | `BlockItem` | 64 | none (lightning rod collection: its `registerItems` lambda is the plain two-argument `registerBlock`, read) |
| 848 | `daylight_detector` | `BlockItem` | 64 | fuel wood_blocks |
| 849 to 851 | `sculk_sensor`, `calibrated_sculk_sensor`, `tripwire_hook` | `BlockItem` | 64 | none |
| 852 | `trapped_chest` | `BlockItem` | 64 | fuel wood_blocks; `container` = empty |
| 853, 854 | `tnt`, `redstone_lamp` | `BlockItem` | 64 | none |
| 855 | `note_block` | `BlockItem` | 64 | fuel wood_blocks |
| 856, 857 | `stone_button`, `polished_blackstone_button` | `BlockItem` | 64 | none |
| 858 to 868 | `oak_button` to `bamboo_button` (oak, spruce, birch, jungle, acacia, cherry, dark_oak, pale_oak, mangrove, poplar, bamboo) | `BlockItem` | 64 | fuel wood_items_extra_small |
| 869 to 874 | `crimson_button`, `warped_button`, `stone_pressure_plate`, `polished_blackstone_pressure_plate`, `light_weighted_pressure_plate`, `heavy_weighted_pressure_plate` | `BlockItem` | 64 | none |
| 875 to 885 | `oak_pressure_plate` to `bamboo_pressure_plate` (the same 11 woods) | `BlockItem` | 64 | fuel wood_blocks |
| 886, 887 | `crimson_pressure_plate`, `warped_pressure_plate` | `BlockItem` | 64 | none |
| 888 | `iron_door` | `DoubleHighBlockItem` | 64 | none |
| 889 to 899 | `oak_door` to `bamboo_door` (the same 11 woods) | `DoubleHighBlockItem` | 64 | fuel wood_items_large |
| 900, 901 | `crimson_door`, `warped_door` | `DoubleHighBlockItem` | 64 | none |
| 902 to 909 | the 8 copper doors | `DoubleHighBlockItem` | 64 | none (copper door collection: its lambda calls `registerBlock` with the plain `DoubleHighBlockItem` constructor, no `cookingFuel`, read) |
| 910 | `iron_trapdoor` | `BlockItem` | 64 | none |
| 911 to 921 | `oak_trapdoor` to `bamboo_trapdoor` (the same 11 woods) | `BlockItem` | 64 | fuel wood_blocks |
| 922 to 931 | `crimson_trapdoor`, `warped_trapdoor`, the 8 copper trapdoors | `BlockItem` | 64 | none (copper trapdoor collection: `Items.<clinit>` passes the same plain two-argument `registerBlock` method reference as the lightning rods, read) |
| 932 to 942 | `oak_fence_gate` to `bamboo_fence_gate` (the same 11 woods) | `BlockItem` | 64 | fuel wood_blocks |
| 943 to 948 | `crimson_fence_gate`, `warped_fence_gate`, `powered_rail`, `detector_rail`, `rail`, `activator_rail` | `BlockItem` | 64 | none |
| 949 | `saddle` | `Item` | **1** | `equippable` saddle (section 5.1) |
| 950 to 965 | `<colour>_harness` | `Item` | **1** | `equippable` harness(colour) (section 5.1) |
| 966 to 970 | `minecart`, `chest_minecart`, `furnace_minecart`, `tnt_minecart`, `hopper_minecart` | `MinecartItem(entity type of the same name)` (section 4.3) | **1** | none |
| 971 | `carrot_on_a_stick` | `FoodOnAStickItem(pig, damage 7)` (section 4.4) | 1 (durability) | `max_damage` 25 |
| 972 | `warped_fungus_on_a_stick` | `FoodOnAStickItem(strider, damage 1)` | 1 (durability) | `max_damage` 100 |
| 973 | `phantom_membrane` | `Item` | 64 | none |
| 974 | `elytra` | `Item` | 1 (durability) | `max_damage` 432; rarity epic; `glider` (Unit); `equippable` elytra; `repairable` = {`phantom_membrane`} (section 5.4) |

Notes on the table:

1. In the wood rows "the same 11 woods" means, in id order: `oak`, `spruce`, `birch`, `jungle`, `acacia`, `cherry`,
   `dark_oak`, `pale_oak`, `mangrove`, `poplar`, `bamboo`. `crimson` and `warped` always follow the 11 and never have a
   fuel component (read: those rows carry no `cookingFuel` call). The 11 woods are the same list in doors, trapdoors, gates,
   buttons, plates and stairs (the stairs of part 2 add `bamboo_mosaic` as a 12th).
2. Durability rows (`durability(n)`) set `max_damage` n, `max_stack_size` 1 and `damage` 0 together (25-1 §6.4, read
   again in `Item$Properties.durability`). `stacksTo(1)` on the saddle, harnesses, shulker boxes and minecarts sets only
   `max_stack_size` (no `max_damage`). The validator that `Item$Properties.finalizeInitializer` attaches throws
   "Item cannot have both durability and be stackable" when a map has `damage` and `max_stack_size` above 1.
3. Every row has the common components of 25-1 §7.1 plus `item_name` (the translatable component for the description id)
   and `item_model` (the item key as an identifier) added by the finalising initialiser (`Item$Properties.finalizeInitializer`:
   25-1 §6.2).
4. No row of this range carries `food`, `consumable`, `tool`, `weapon`, `attribute_modifiers` or a use cooldown: the range
   has no food and no tools (read: none of the 239 statements calls those builders).

## 4. Item classes read in this range

The shared `BlockItem`, `StandingAndWallBlockItem`, `DoubleHighBlockItem` and `ScaffoldingBlockItem` are specified in
25-1 §5.2 and §5.3 (the bytecode of all four was re-read here and agrees with those sections, including: the
double-high placement writes water or air above with flags 27 before the normal placement; the standing-and-wall item
skips the direction opposite the attachment direction and uses `canSurvive` as its `canPlace`; scaffolding's
`mustSurvive` is false and its re-aim walks at most 7 steps counting horizontal moves). This section adds the classes
that part 1 did not read.

### 4.1 `GameMasterBlockItem` (command blocks: ids 648 and 649 here; `command_block` is id 529, part 2)

A `BlockItem` that overrides only `getPlacementState`: when the placing player is non-null and
`Player.canUseGameMasterBlocks()` is false, the placement state is null (so `BlockItem.place` returns FAIL with nothing
written, 25-1 §5.2 step 4); otherwise the normal `BlockItem` placement state is used. A null player (a dispenser or a
command) is allowed. `Player.canUseGameMasterBlocks()` is read: it is true only when the player's abilities have `instabuild` set (creative mode) and the player's permission set has the `COMMANDS_GAMEMASTER` permission (command level `GAMEMASTERS`); the base `Player.permissions()` is the empty set, and `ServerPlayer.permissions()` returns the server's profile permissions for the player (`getProfilePermissions`; the numeric level of `GAMEMASTERS` is 2, read: `PermissionLevel.<clinit>` constructs `ALL` (id 0, serialized name `all`), `MODERATORS` (1, `moderators`), `GAMEMASTERS` (2, `gamemasters`), `ADMINS` (3, `admins`), `OWNERS` (4, `owners`), and `Permissions.COMMANDS_GAMEMASTER` is built from `GAMEMASTERS`; how `getProfilePermissions` derives the level for a player is not read). So a survival player, or a creative player without gamemaster rights, cannot place a command block (29 Open question 4; Open question 1).

### 4.2 `PlaceOnWaterBlockItem` (`lily_pad`, id 497: outside this range, read here because no other part reads the class)



A `BlockItem` whose normal `useOn` is replaced by "do nothing, PASS", so using it on a block never places it directly.
`use(level, player, hand)` (right click) does:

1. Ray cast from the player's point of view with the fluid mode `SOURCE_ONLY` (`Item.getPlayerPOVHitResult`: the ray stops
   at water source blocks; the reach is the player's block interaction range, 17 §1.5).
2. Take the hit block position and move it **one block up**; keep the hit location and the face, so the result is a
   block hit result at the position above the water.
3. Run `BlockItem.useOn` with a new `UseOnContext` (player, hand, that hit result) and return its result.

So the lily pad is placed on top of a water source the player is looking at (the replaced position is the one above the
water; the placement checks of 29 §9.6 and the `lily_pad` block's own survival rule (24) apply there). The consumption
of one item and the place sound are the ordinary `BlockItem.place` steps.

### 4.3 `MinecartItem` (ids 966 to 970)



Fields: the entity type (`minecart`, `chest_minecart`, `furnace_minecart`, `tnt_minecart`, `hopper_minecart`, each the
entity type of the same key). There is no `use` override; the item acts through `useOn(context)`:

1. `state` = the block state at the clicked position. If it is not in the block tag `rails`: return FAIL.
2. `shape` = the rail shape property of the block when the block is a `BaseRailBlock`, else `north_south`. `yOffset` is
   0.5 when the shape is a slope (`RailShape.isSlope`), else 0.
3. Spawn position = (x + 0.5, y + 0.0625 + yOffset, z + 0.5) with (x, y, z) the clicked block position (doubles).
4. Create the minecart with `AbstractMinecart.createMinecart(level, x, y, z, type, spawnReason = DISPENSER, stack, player)`.
   That creates the entity with `EntityType.create(level, reason)` (null: FAIL), sets its initial position, applies the
   default stack configuration of `EntityType.createDefaultStackConfig` (the stack's data components, and the stack's
   `entity_data` component merged into the entity, with the permission check of `EntityType.updateCustomEntityTag`; the
   exact merge is not read, Open question 2), and, when the entity uses the new movement behaviour, calls
   `NewMinecartBehavior.adjustToRails` for the rail below. The spawn reason constant used is `EntitySpawnReason.DISPENSER`
   for a player click as well (read).
5. If the world's enabled features contain `minecart_improvements` (`AbstractMinecart.useExperimentalMovement`, which tests
   `Level.enabledFeatures` for `FeatureFlags.MINECART_IMPROVEMENTS`): collect the entities in the new minecart's bounding
   box; if any is an `AbstractMinecart`, return FAIL. In 26.3 `FeatureFlags.DEFAULT_FLAGS` and `VANILLA_SET` hold only the
   flag `vanilla`, and `minecart_improvements` is a separate flag (read: `FeatureFlags.<clinit>` registers `vanilla`,
   `trade_rebalance`, `redstone_experiments`, `minecart_improvements`; the vanilla set is `{vanilla}`), so in a default world
   this step is skipped and the old movement behaviour is used (44-8 §4 specifies both behaviours).
6. On the server: `addFreshEntity(minecart)`, then game event `entity_place` at the clicked position with context
   (the player, the block state **below** the clicked position).
7. `stack.shrink(1)` on both sides. The method contains no creative-mode test; whether a creative player keeps the item is
   decided elsewhere (the creative rule for ordinary block placement is cited in 25-1 §5.2 step 7; 29 §9.3 to §9.6 describe the placement flow; Open question 3).
8. Return SUCCESS.

The block tag `rails` (read from `data/minecraft/tags/block/rails.json`) holds exactly four blocks: `rail`, `powered_rail`, `detector_rail`, `activator_rail`. The ids 945 to 948 (`powered_rail`, `detector_rail`, `rail`,
`activator_rail`) are plain `BlockItem`s: their placement is the ordinary block placement with the shape rules of 24.

### 4.4 `FoodOnAStickItem` (ids 971, 972)

Fields: the entity type the item can steer (`pig` for the carrot, `strider` for the fungus) and `consumeItemDamage` (7 for
the carrot, 1 for the fungus; read as the integer constants pushed in `Items`). Only `use` is overridden:

1. On the client: PASS.
2. Server: `vehicle` = `player.getControlledVehicle()`. If the player is a passenger and the vehicle is an `ItemSteerable`
   entity whose type equals the item's entity type and `vehicle.boost()` returns true: the stack is damaged by
   `consumeItemDamage` with `hurtAndConvertOnBreak(damage, fishing_rod, player, hand slot)` (when the stack breaks it is
   replaced by a `fishing_rod`, 17 §5.1 for durability loss), and the result is `SUCCESS_SERVER` with the held item
   replaced by the returned stack.
3. Otherwise: award the `item_used` statistic for this item and return PASS.

`boost()` is the entity's (a pig's, a strider's) own rule: 19 (pig boost and steering) and 44-6 (strider).

### 4.5 Items whose class is plain `Item`

`saddle`, the 16 harnesses, `phantom_membrane` and `elytra` use `Item` itself (25-1 §5.1): their behaviour comes from
components. Right-click in air runs the `equippable` branch of `Item.use` (25-1 §5.1: `consumable` first, then a swappable
`equippable`): the `saddle` and the harnesses have `swappable` true by the builder default (section 5.1), but the swap
operation answers PASS unless the player can use the item's slot and the player's entity type is allowed
(`Player.canUseSlot`, `Equippable.canBeEquippedBy`); `Player` does not override `canUseSlot` and `LivingEntity.canUseSlot` returns true for every slot (read), so a player passes that test for `saddle` and `body`; the swap is refused by the allowed-entity rule instead: `Equippable.canBeEquippedBy` is true when `allowed_entities` is absent or contains the type (read), and the player entity type is in none of the tags `can_equip_saddle`, `can_equip_harness` or the llama pair, so the saddle, harnesses and carpets answer PASS to a player's right-click in air (tags read from the data files, section 5.1). Elytra can be worn: `chest` slot, section 5.4.

## 5. Components introduced or used here

### 5.1 `equippable` (component 32): the four configurations in this range

Wire layout: 17 §1.2. Record fields in order and the builder defaults (`Equippable$Builder.<init>`, read):

| Field | Builder default |
|---|---|
| `slot` | the argument of `Equippable.builder(slot)` |
| `equip_sound` | `SoundEvents.ARMOR_EQUIP_GENERIC` (a sound holder) |
| `asset_id` | empty |
| `camera_overlay` | empty |
| `allowed_entities` | empty (no restriction) |
| `dispensable` | true |
| `swappable` | true |
| `damage_on_hurt` | true |
| `equip_on_interact` | false |
| `can_be_sheared` | false |
| `shearing_sound` | the sound event `SHEARS_SNIP` wrapped as a direct holder |

Equipment slot ids on the wire (`EquipmentSlot.STREAM_CODEC` is an id mapper over `EquipmentSlot.getId()`; the ids were
read from the constructor arguments of the enum constants: the 4-argument constructor is (type, index, id, name), the
5-argument one is (type, index, count limit, id, name)): `mainhand` 0, `feet` 1, `legs` 2, `chest` 3, `head` 4,
`offhand` 5, `body` 6, `saddle` 7. (Registry id of a sound holder: 00 §10.2, 46 §14.)

The four configurations (all other fields at the defaults above):

| Item | Slot | Equip sound | Asset | Allowed entities | Other fields changed |
|---|---|---|---|---|---|
| `saddle` (`Equippable.saddle()`) | `saddle` (7) | `horse_saddle` | `EquipmentAssets.SADDLE` (the equipment asset key `saddle`) | the entity type tag `can_equip_saddle` | `equip_on_interact` true, `can_be_sheared` true, shearing sound `saddle_unequip` |
| `<colour>_harness` (`Equippable.harness(colour)`) | `body` (6) | `harness_equip` | `EquipmentAssets.HARNESSES[colour]` | the entity type tag `can_equip_harness` | `equip_on_interact` true, `can_be_sheared` true, shearing sound `harness_unequip` |
| `<colour>_carpet` (`Equippable.llamaSwag(colour)`) | `body` (6) | `llama_swag` | `EquipmentAssets.CARPETS[colour]` | exactly `llama` and `trader_llama` | `can_be_sheared` true, shearing sound `llama_carpet_unequip` (`equip_on_interact` stays false) |
| `elytra` | `chest` (3) | `armor_equip_elytra` | `EquipmentAssets.ELYTRA` | none | `damage_on_hurt` false |

The sound keys above are the lower-case names of the `SoundEvents` constants that were read; the sound registry ids are
46 §14. The equipment asset keys are data rows of the `equipment` assets (22); `EquipmentAssets.CARPETS[colour]` is the key `minecraft:<colour>_carpet` and `HARNESSES[colour]` is `minecraft:<colour>_harness` (read: the two lambdas of `EquipmentAssets.<clinit>` concatenate the dye serialized name with `_carpet` or `_harness`; `SADDLE` is `saddle` and `ELYTRA` is `elytra`). Tag contents (read from the data files): `can_equip_saddle` = `horse`, `skeleton_horse`, `zombie_horse`, `donkey`, `mule`, `pig`, `strider`, `camel`, `camel_husk`, `nautilus`, `zombie_nautilus`; `can_equip_harness` = `happy_ghast`.

Equip operations (`Equippable`, read):

- **Swap with the player's slot** (`Equippable.swapWithEquipmentSlot(stack, player)`, bytecode read), reached from right-click in air (25-1 §5.1):
  1. If `player.canUseSlot(slot)` is false or the player's entity type is not allowed (`canBeEquippedBy`: true when
     `allowed_entities` is empty or contains the type): PASS. A player passes `canUseSlot` for every slot, so only the allowed-entity test blocks `saddle`, harness and carpet items; the elytra has no restriction and swaps.
  2. `current` = the player's stack in the slot. FAIL when (`current` has the enchantment effect `prevent_armor_change`
     and the player is not in creative mode) or the held stack is the same item with the same components as `current`.
  3. On the server, award the `item_used` statistic for the held item.
  4. If the held count is at most 1: the held item given back to the hand is the held stack itself when `current` is empty,
     else `current` cleared out of the slot; the slot receives the held stack (a copy in creative mode, so the hand keeps the held stack and the item is duplicated; the held stack
     itself cleared out of the hand otherwise; read in `Equippable.swapWithEquipmentSlot`: `Player.isCreative` selects `ItemStack.copy` or `copyAndClear`); SUCCESS with the hand's item transformed to the given-back stack.
  5. If the held count is more than 1: `current` is cleared from the slot; one item is split off the held stack with
     `consumeAndReturn(1, player)` and put in the slot; the removed `current` is added to the player's inventory or, when
     it does not fit, dropped (`Player.drop(stack, false, PREDICTED)`); SUCCESS with the hand holding the remaining stack.
- **Equip onto another entity** (`equipOnTarget(player, target, stack)`), used when the item has `equip_on_interact` (the
  saddle and the harnesses, via the Interact packet, 17 §3.7): PASS unless the target is alive, `target.isEquippableInSlot(stack,
  slot)` holds (the allowed-entity rule) and the target's slot is empty; on the server the target's slot receives one item
  split from the stack, and when the target is a `Mob` its guaranteed-drop flag for that slot is set (so the item drops
  with certainty when the mob dies); SUCCESS. The shearing of a saddle, harness or carpet with shears (`can_be_sheared`) is
  mob logic (19, 44-4).

### 5.2 `block_state` (component 78) and the `light` item

`BlockItemStateProperties` is a map of string property name to string value. Wire: `ByteBufCodecs.map` of two UTF-8
strings (VarInt count, then pairs; read: `PROPERTIES_STREAM_CODEC`, the string codec `STRING_UTF8` for key and value).
`EMPTY` is the empty map. Applying it to a placed state (`BlockItem.updateBlockStateFromTag`, 25-1 §5.2 step 6, 29 §9.6):
for every entry, look up the property by name in the placed block's state definition; entries naming no property are
skipped; each found property is set from its string value (`updateState`: the value is looked up with `Property.getValue(String)`, which returns an `Optional`; the present value is applied to the state, and when it is absent (an unparsable value) `orElse` yields the original state, so the state is left unchanged, read).

The `light` item (id 578) has `block_state` = {`level`: `15`} (built with `BlockItemStateProperties.EMPTY.with(LightBlock.LEVEL, 15)`;
the property name is `level`, 24 part 5) and rarity epic, so a freshly given light item places a level-15 light block. The
`level` of a placed light block is changed by right-clicking the placed block, not by using the item again (read: `LightBlock.useWithoutItem`). On the client (`Level.isClientSide` true) or when `Player.canUseGameMasterBlocks()` is false (4.1: creative mode plus the gamemaster permission) it returns CONSUME and changes nothing. Otherwise, on the server only, it sets the next value of the `level` property (`BlockState.cycle`, which wraps from 15 to 0) with `setBlock` flags 2 and returns SUCCESS_SERVER. `LightBlock.getShape` gives a full-block hit shape only while the player holds the `light` item (`CollisionContext.isHoldingItem`), else the empty shape, so the block can only be targeted with the item in hand. Block behaviour in general: 24 part 5.

### 5.3 `container` (component 77) and shulker boxes

`ItemContainerContents`: a list of at most 256 slots, each an optional stack (the internal list holds `Optional<ItemStackTemplate>`). Wire (`ItemContainerContents.STREAM_CODEC`, read in `<clinit>`): `ByteBufCodecs.optional` applied to `ItemStackTemplate.STREAM_CODEC`, then `ByteBufCodecs.list(256)`. So the wire is a VarInt entry count (at most 256), then that many entries, and **each entry** is a Boolean present flag followed by a template only when the flag is true. An empty slot is a single `00` byte. A template (`ItemStackTemplate.STREAM_CODEC`) is the item (VarInt registry id), VarInt count, then a `DataComponentPatch` (00 §12.2). `EMPTY` is the empty list (wire: `00`). Worked example: a container with slot 0 empty and slot 1 holding 3 of item id 5 with an empty patch is `02` (count), `00` (slot 0 absent), `01` (slot 1 present), `05` (item), `03` (count), then the empty patch (`00 00`, zero added and zero removed components): `02 00 01 05 03 00 00`. The save form: `ItemContainerContents$Slot.CODEC` has exactly two fields, named `slot` and `item`, and the list of slots is size-limited to 256 (`sizeLimitedListOf(256)`; read).
Rows with `container` = empty in this range: `shulker_box` and the 16 coloured boxes (max stack 1), `hopper`,
`dispenser`, `dropper`, `trapped_chest` (max stack 64). (`chest` has it too, 25-1 / part 2.) What the empty default means:
the component exists with no content, so two empty boxes compare equal (25-1 §5.1 merge rule: same item and same
components); when the item is placed, `updateBlockEntityComponents` applies the stack's components to the block entity
(29 §9.6 step 6.3). How a broken shulker box writes its contents back into a dropped item is a block behaviour not read
here (Open question 7).

Shulker-box rules found in the item layer (read in `BlockItem`):

- `canFitInsideContainerItems()` is false for any `BlockItem` whose block is a `ShulkerBoxBlock` (all 17 boxes), true for
  every other `BlockItem` and for `Item` (read: `Item.canFitInsideContainerItems` returns constant true): a shulker box cannot be put into another container item (shulker box, bundle:
  the check is made by those containers, 25 part 4).
- `BlockItem.onDestroyed(itemEntity)` (an item entity destroyed by fire, lava, explosion or the void, 41): the entity's
  stack gets its `container` replaced by `EMPTY` and each non-empty item of the old contents is dropped as a new item
  entity at the entity's position (`ItemUtils.onContainerDestroyed`, server only). This applies to every `BlockItem`, so
  it matters for the 21 rows of this range that carry `container` (and for `chest` and the like).

### 5.4 Elytra: `glider`, `equippable`, `repairable`, durability

The `elytra` row sets, in order: `max_damage` 432 with `max_stack_size` 1 and `damage` 0, rarity epic, `glider` (the Unit
value, no payload), `equippable` (section 5.1), `repairable` = a direct set with the single item `phantom_membrane`. The
flight, durability loss in flight and the Player Command that starts gliding are in 17 §3.13 (not repeated). Combined
with 25-1 §5.1: the elytra in the chest slot does not lose durability when its wearer is hurt (`damage_on_hurt` false);
right-click in air with it in hand swaps it with the chest armor (section 5.1).

### 5.5 `provides_trim_material` (component 64) and the `redstone` item

The `redstone` item (id 824) is built with `Item$Properties.trimMaterial(TrimMaterials.REDSTONE)`: it sets component 64 to
the holder of the trim material with the key `redstone`, resolved after the registries are available
(`delayedHolderComponent`, the same delayed mechanism as 25-1 §6.2). Its item class is a plain `BlockItem` over
`redstone_wire` made by `createBlockItemWithCustomItemName` (description prefix `item.`, key `redstone`), so using it on a
block places redstone wire. The trim material data (colour, asset name) is data.

### 5.6 Rarity

`Rarity` is an enum with ordinals 0 to 3: `common` (white), `uncommon` (yellow), `rare` (aqua) and `epic` (light purple).
The colours are the `ChatFormatting` constants passed to each constant in `Rarity.<clinit>`: `WHITE`, `YELLOW`, `AQUA`,
`LIGHT_PURPLE`, read; their numeric values were not read and are not needed here. The `rarity`
component value is a VarInt of the ordinal (17 §1.2). Rows with a rarity in this range: epic: `repeating_command_block`,
`chain_command_block`, `barrier`, `light`, `structure_void`, `elytra`; uncommon: `sniffer_egg`, `conduit`. (Just outside the
range, read in the same round: epic `dragon_egg` 511 and `command_block` 529, rare `beacon` 530.)

## 6. Fuel and compost keys used in this range

`cooking_fuel` and `compostable` store provider keys (25-1 §9). The values below were read from the data files named and
are quoted so the rows can be understood; they are data, and the extraction tool copies them. Burn time in ticks is the
integer provider `div(left, factor)` where factor is 1 in a furnace and 2 in a smoker or blast furnace (predicate
`block/fast_cooking`: blocks `smoker` and `blast_furnace`; `cooking/normal_burn_time_reduction_factor` is the constant 1,
`cooking/fast_burn_time_reduction_factor` the constant 2; the division semantics are 26 §9).

| Key (`cooking/time_K`) | `left` (read) | Rows in this range |
|---|---|---|
| `wood_blocks` | 300 | 37 rows: `lectern`, `daylight_detector`, `trapped_chest`, `note_block`, 11 pressure plates, 11 trapdoors, 11 fence gates (the 12 wooden stairs, ids 515 to 526, have it too and belong to part 2) |
| `wood_items_extra_small` | 100 | 11 wooden buttons |
| `wood_items_large` | 200 | 11 wooden doors |
| `wool_carpets` | 67 | 16 carpets |
| `bamboo` | 50 | `scaffolding` |

(In a smoker or blast furnace those are 150, 50, 100, 33 and 25 with integer division, 26 §9.) Compost keys
(`compostable/K`; each is a `number_dispatcher` with one case, "when the block is a `composter` whose `level` is 0, the
value 1", else a `weighted_list` of {1, 0}; weights for 1 and 0):

| Key | Weights (1 : 0) | Rows in this range |
|---|---|---|
| `low_medium` | 50 : 50 | `tall_grass` (outside the range: `vine` 484, `glow_lichen` 485) |
| `medium` | 65 : 35 | `sunflower`, `lilac`, `rose_bush`, `peony`, `large_fern` (outside: `mushroom_stem` 463, `melon` 483, `lily_pad` 497) |
| `medium_high` | 85 : 15 | `hay_block`, `nether_wart_block`, `warped_wart_block` (outside: the two mushroom blocks 461, 462) |

The 76 rows with `cooking_fuel` (37 + 11 + 11 + 16 + 1) also carry the speed provider `cooking/speed_default` (read: `data/minecraft/context_float_provider/cooking/speed_default.json` is a `conditional` on the condition `block/fast_cooking`, `on_false` = provider `cooking/normal_speed_multiplier` (value 1.0), `on_true` = provider `cooking/fast_speed_multiplier` (value 2.0); both files exist in the jar; so 1.0 normal, 2.0 fast cooking block,
25-1 §9). Wire of the three components (`Compostable.STREAM_CODEC`, `CookingFuel.STREAM_CODEC`): a provider reference is a
`ResolvableInt` or `ResolvableFloat`, encoded as an Either: a Boolean, true then a fixed 4-byte big-endian **INT** (ints;
`ByteBufCodecs.INT`, not a VarInt) or **FLOAT** (floats) constant, false then the resource key as an Identifier string. So
`cooking_fuel` is two such fields in order (burn time, speed multiplier); `compostable` is one. The item rows always use
the reference form (Boolean false + Identifier, for example `minecraft:cooking/time_wood_blocks`), never a constant.

## 7. The complete id to key table (ids 550 to 974)

Four (id, key) pairs per row; ids ascend left to right then down. All keys are in the `minecraft` namespace. The class and
components of a row are in section 3 by id.

| Id | Key | Id | Key | Id | Key | Id | Key |
|---|---|---|---|---|---|---|---|
| 550 | `polished_deepslate_wall` | 551 | `deepslate_brick_wall` | 552 | `deepslate_tile_wall` | 553 | `anvil` |
| 554 | `chipped_anvil` | 555 | `damaged_anvil` | 556 | `chiseled_quartz_block` | 557 | `quartz_block` |
| 558 | `quartz_bricks` | 559 | `quartz_pillar` | 560 | `quartz_stairs` | 561 | `white_terracotta` |
| 562 | `orange_terracotta` | 563 | `magenta_terracotta` | 564 | `light_blue_terracotta` | 565 | `yellow_terracotta` |
| 566 | `lime_terracotta` | 567 | `pink_terracotta` | 568 | `gray_terracotta` | 569 | `light_gray_terracotta` |
| 570 | `cyan_terracotta` | 571 | `purple_terracotta` | 572 | `blue_terracotta` | 573 | `brown_terracotta` |
| 574 | `green_terracotta` | 575 | `red_terracotta` | 576 | `black_terracotta` | 577 | `barrier` |
| 578 | `light` | 579 | `hay_block` | 580 | `white_carpet` | 581 | `orange_carpet` |
| 582 | `magenta_carpet` | 583 | `light_blue_carpet` | 584 | `yellow_carpet` | 585 | `lime_carpet` |
| 586 | `pink_carpet` | 587 | `gray_carpet` | 588 | `light_gray_carpet` | 589 | `cyan_carpet` |
| 590 | `purple_carpet` | 591 | `blue_carpet` | 592 | `brown_carpet` | 593 | `green_carpet` |
| 594 | `red_carpet` | 595 | `black_carpet` | 596 | `terracotta` | 597 | `packed_ice` |
| 598 | `dirt_path` | 599 | `sunflower` | 600 | `lilac` | 601 | `rose_bush` |
| 602 | `peony` | 603 | `tall_grass` | 604 | `large_fern` | 605 | `white_stained_glass` |
| 606 | `orange_stained_glass` | 607 | `magenta_stained_glass` | 608 | `light_blue_stained_glass` | 609 | `yellow_stained_glass` |
| 610 | `lime_stained_glass` | 611 | `pink_stained_glass` | 612 | `gray_stained_glass` | 613 | `light_gray_stained_glass` |
| 614 | `cyan_stained_glass` | 615 | `purple_stained_glass` | 616 | `blue_stained_glass` | 617 | `brown_stained_glass` |
| 618 | `green_stained_glass` | 619 | `red_stained_glass` | 620 | `black_stained_glass` | 621 | `white_stained_glass_pane` |
| 622 | `orange_stained_glass_pane` | 623 | `magenta_stained_glass_pane` | 624 | `light_blue_stained_glass_pane` | 625 | `yellow_stained_glass_pane` |
| 626 | `lime_stained_glass_pane` | 627 | `pink_stained_glass_pane` | 628 | `gray_stained_glass_pane` | 629 | `light_gray_stained_glass_pane` |
| 630 | `cyan_stained_glass_pane` | 631 | `purple_stained_glass_pane` | 632 | `blue_stained_glass_pane` | 633 | `brown_stained_glass_pane` |
| 634 | `green_stained_glass_pane` | 635 | `red_stained_glass_pane` | 636 | `black_stained_glass_pane` | 637 | `prismarine` |
| 638 | `prismarine_bricks` | 639 | `dark_prismarine` | 640 | `prismarine_stairs` | 641 | `prismarine_brick_stairs` |
| 642 | `dark_prismarine_stairs` | 643 | `sea_lantern` | 644 | `red_sandstone` | 645 | `chiseled_red_sandstone` |
| 646 | `cut_red_sandstone` | 647 | `red_sandstone_stairs` | 648 | `repeating_command_block` | 649 | `chain_command_block` |
| 650 | `magma_block` | 651 | `nether_wart_block` | 652 | `warped_wart_block` | 653 | `red_nether_bricks` |
| 654 | `bone_block` | 655 | `structure_void` | 656 | `shulker_box` | 657 | `white_shulker_box` |
| 658 | `orange_shulker_box` | 659 | `magenta_shulker_box` | 660 | `light_blue_shulker_box` | 661 | `yellow_shulker_box` |
| 662 | `lime_shulker_box` | 663 | `pink_shulker_box` | 664 | `gray_shulker_box` | 665 | `light_gray_shulker_box` |
| 666 | `cyan_shulker_box` | 667 | `purple_shulker_box` | 668 | `blue_shulker_box` | 669 | `brown_shulker_box` |
| 670 | `green_shulker_box` | 671 | `red_shulker_box` | 672 | `black_shulker_box` | 673 | `white_glazed_terracotta` |
| 674 | `orange_glazed_terracotta` | 675 | `magenta_glazed_terracotta` | 676 | `light_blue_glazed_terracotta` | 677 | `yellow_glazed_terracotta` |
| 678 | `lime_glazed_terracotta` | 679 | `pink_glazed_terracotta` | 680 | `gray_glazed_terracotta` | 681 | `light_gray_glazed_terracotta` |
| 682 | `cyan_glazed_terracotta` | 683 | `purple_glazed_terracotta` | 684 | `blue_glazed_terracotta` | 685 | `brown_glazed_terracotta` |
| 686 | `green_glazed_terracotta` | 687 | `red_glazed_terracotta` | 688 | `black_glazed_terracotta` | 689 | `white_concrete` |
| 690 | `orange_concrete` | 691 | `magenta_concrete` | 692 | `light_blue_concrete` | 693 | `yellow_concrete` |
| 694 | `lime_concrete` | 695 | `pink_concrete` | 696 | `gray_concrete` | 697 | `light_gray_concrete` |
| 698 | `cyan_concrete` | 699 | `purple_concrete` | 700 | `blue_concrete` | 701 | `brown_concrete` |
| 702 | `green_concrete` | 703 | `red_concrete` | 704 | `black_concrete` | 705 | `white_concrete_stairs` |
| 706 | `orange_concrete_stairs` | 707 | `magenta_concrete_stairs` | 708 | `light_blue_concrete_stairs` | 709 | `yellow_concrete_stairs` |
| 710 | `lime_concrete_stairs` | 711 | `pink_concrete_stairs` | 712 | `gray_concrete_stairs` | 713 | `light_gray_concrete_stairs` |
| 714 | `cyan_concrete_stairs` | 715 | `purple_concrete_stairs` | 716 | `blue_concrete_stairs` | 717 | `brown_concrete_stairs` |
| 718 | `green_concrete_stairs` | 719 | `red_concrete_stairs` | 720 | `black_concrete_stairs` | 721 | `white_concrete_slab` |
| 722 | `orange_concrete_slab` | 723 | `magenta_concrete_slab` | 724 | `light_blue_concrete_slab` | 725 | `yellow_concrete_slab` |
| 726 | `lime_concrete_slab` | 727 | `pink_concrete_slab` | 728 | `gray_concrete_slab` | 729 | `light_gray_concrete_slab` |
| 730 | `cyan_concrete_slab` | 731 | `purple_concrete_slab` | 732 | `blue_concrete_slab` | 733 | `brown_concrete_slab` |
| 734 | `green_concrete_slab` | 735 | `red_concrete_slab` | 736 | `black_concrete_slab` | 737 | `white_concrete_powder` |
| 738 | `orange_concrete_powder` | 739 | `magenta_concrete_powder` | 740 | `light_blue_concrete_powder` | 741 | `yellow_concrete_powder` |
| 742 | `lime_concrete_powder` | 743 | `pink_concrete_powder` | 744 | `gray_concrete_powder` | 745 | `light_gray_concrete_powder` |
| 746 | `cyan_concrete_powder` | 747 | `purple_concrete_powder` | 748 | `blue_concrete_powder` | 749 | `brown_concrete_powder` |
| 750 | `green_concrete_powder` | 751 | `red_concrete_powder` | 752 | `black_concrete_powder` | 753 | `turtle_egg` |
| 754 | `sniffer_egg` | 755 | `dried_ghast` | 756 | `dead_tube_coral_block` | 757 | `dead_brain_coral_block` |
| 758 | `dead_bubble_coral_block` | 759 | `dead_fire_coral_block` | 760 | `dead_horn_coral_block` | 761 | `tube_coral_block` |
| 762 | `brain_coral_block` | 763 | `bubble_coral_block` | 764 | `fire_coral_block` | 765 | `horn_coral_block` |
| 766 | `tube_coral` | 767 | `brain_coral` | 768 | `bubble_coral` | 769 | `fire_coral` |
| 770 | `horn_coral` | 771 | `dead_brain_coral` | 772 | `dead_bubble_coral` | 773 | `dead_fire_coral` |
| 774 | `dead_horn_coral` | 775 | `dead_tube_coral` | 776 | `tube_coral_fan` | 777 | `brain_coral_fan` |
| 778 | `bubble_coral_fan` | 779 | `fire_coral_fan` | 780 | `horn_coral_fan` | 781 | `dead_tube_coral_fan` |
| 782 | `dead_brain_coral_fan` | 783 | `dead_bubble_coral_fan` | 784 | `dead_fire_coral_fan` | 785 | `dead_horn_coral_fan` |
| 786 | `blue_ice` | 787 | `conduit` | 788 | `polished_granite_stairs` | 789 | `smooth_red_sandstone_stairs` |
| 790 | `mossy_stone_brick_stairs` | 791 | `polished_diorite_stairs` | 792 | `mossy_cobblestone_stairs` | 793 | `end_stone_brick_stairs` |
| 794 | `stone_stairs` | 795 | `smooth_sandstone_stairs` | 796 | `smooth_quartz_stairs` | 797 | `granite_stairs` |
| 798 | `andesite_stairs` | 799 | `red_nether_brick_stairs` | 800 | `polished_andesite_stairs` | 801 | `diorite_stairs` |
| 802 | `cobbled_deepslate_stairs` | 803 | `polished_deepslate_stairs` | 804 | `deepslate_brick_stairs` | 805 | `deepslate_tile_stairs` |
| 806 | `polished_granite_slab` | 807 | `smooth_red_sandstone_slab` | 808 | `mossy_stone_brick_slab` | 809 | `polished_diorite_slab` |
| 810 | `mossy_cobblestone_slab` | 811 | `end_stone_brick_slab` | 812 | `smooth_sandstone_slab` | 813 | `smooth_quartz_slab` |
| 814 | `granite_slab` | 815 | `andesite_slab` | 816 | `red_nether_brick_slab` | 817 | `polished_andesite_slab` |
| 818 | `diorite_slab` | 819 | `cobbled_deepslate_slab` | 820 | `polished_deepslate_slab` | 821 | `deepslate_brick_slab` |
| 822 | `deepslate_tile_slab` | 823 | `scaffolding` | 824 | `redstone` | 825 | `redstone_torch` |
| 826 | `redstone_block` | 827 | `repeater` | 828 | `comparator` | 829 | `piston` |
| 830 | `sticky_piston` | 831 | `slime_block` | 832 | `honey_block` | 833 | `observer` |
| 834 | `hopper` | 835 | `dispenser` | 836 | `dropper` | 837 | `lectern` |
| 838 | `target` | 839 | `lever` | 840 | `lightning_rod` | 841 | `exposed_lightning_rod` |
| 842 | `weathered_lightning_rod` | 843 | `oxidized_lightning_rod` | 844 | `waxed_lightning_rod` | 845 | `waxed_exposed_lightning_rod` |
| 846 | `waxed_weathered_lightning_rod` | 847 | `waxed_oxidized_lightning_rod` | 848 | `daylight_detector` | 849 | `sculk_sensor` |
| 850 | `calibrated_sculk_sensor` | 851 | `tripwire_hook` | 852 | `trapped_chest` | 853 | `tnt` |
| 854 | `redstone_lamp` | 855 | `note_block` | 856 | `stone_button` | 857 | `polished_blackstone_button` |
| 858 | `oak_button` | 859 | `spruce_button` | 860 | `birch_button` | 861 | `jungle_button` |
| 862 | `acacia_button` | 863 | `cherry_button` | 864 | `dark_oak_button` | 865 | `pale_oak_button` |
| 866 | `mangrove_button` | 867 | `poplar_button` | 868 | `bamboo_button` | 869 | `crimson_button` |
| 870 | `warped_button` | 871 | `stone_pressure_plate` | 872 | `polished_blackstone_pressure_plate` | 873 | `light_weighted_pressure_plate` |
| 874 | `heavy_weighted_pressure_plate` | 875 | `oak_pressure_plate` | 876 | `spruce_pressure_plate` | 877 | `birch_pressure_plate` |
| 878 | `jungle_pressure_plate` | 879 | `acacia_pressure_plate` | 880 | `cherry_pressure_plate` | 881 | `dark_oak_pressure_plate` |
| 882 | `pale_oak_pressure_plate` | 883 | `mangrove_pressure_plate` | 884 | `poplar_pressure_plate` | 885 | `bamboo_pressure_plate` |
| 886 | `crimson_pressure_plate` | 887 | `warped_pressure_plate` | 888 | `iron_door` | 889 | `oak_door` |
| 890 | `spruce_door` | 891 | `birch_door` | 892 | `jungle_door` | 893 | `acacia_door` |
| 894 | `cherry_door` | 895 | `dark_oak_door` | 896 | `pale_oak_door` | 897 | `mangrove_door` |
| 898 | `poplar_door` | 899 | `bamboo_door` | 900 | `crimson_door` | 901 | `warped_door` |
| 902 | `copper_door` | 903 | `exposed_copper_door` | 904 | `weathered_copper_door` | 905 | `oxidized_copper_door` |
| 906 | `waxed_copper_door` | 907 | `waxed_exposed_copper_door` | 908 | `waxed_weathered_copper_door` | 909 | `waxed_oxidized_copper_door` |
| 910 | `iron_trapdoor` | 911 | `oak_trapdoor` | 912 | `spruce_trapdoor` | 913 | `birch_trapdoor` |
| 914 | `jungle_trapdoor` | 915 | `acacia_trapdoor` | 916 | `cherry_trapdoor` | 917 | `dark_oak_trapdoor` |
| 918 | `pale_oak_trapdoor` | 919 | `mangrove_trapdoor` | 920 | `poplar_trapdoor` | 921 | `bamboo_trapdoor` |
| 922 | `crimson_trapdoor` | 923 | `warped_trapdoor` | 924 | `copper_trapdoor` | 925 | `exposed_copper_trapdoor` |
| 926 | `weathered_copper_trapdoor` | 927 | `oxidized_copper_trapdoor` | 928 | `waxed_copper_trapdoor` | 929 | `waxed_exposed_copper_trapdoor` |
| 930 | `waxed_weathered_copper_trapdoor` | 931 | `waxed_oxidized_copper_trapdoor` | 932 | `oak_fence_gate` | 933 | `spruce_fence_gate` |
| 934 | `birch_fence_gate` | 935 | `jungle_fence_gate` | 936 | `acacia_fence_gate` | 937 | `cherry_fence_gate` |
| 938 | `dark_oak_fence_gate` | 939 | `pale_oak_fence_gate` | 940 | `mangrove_fence_gate` | 941 | `poplar_fence_gate` |
| 942 | `bamboo_fence_gate` | 943 | `crimson_fence_gate` | 944 | `warped_fence_gate` | 945 | `powered_rail` |
| 946 | `detector_rail` | 947 | `rail` | 948 | `activator_rail` | 949 | `saddle` |
| 950 | `white_harness` | 951 | `orange_harness` | 952 | `magenta_harness` | 953 | `light_blue_harness` |
| 954 | `yellow_harness` | 955 | `lime_harness` | 956 | `pink_harness` | 957 | `gray_harness` |
| 958 | `light_gray_harness` | 959 | `cyan_harness` | 960 | `purple_harness` | 961 | `blue_harness` |
| 962 | `brown_harness` | 963 | `green_harness` | 964 | `red_harness` | 965 | `black_harness` |
| 966 | `minecart` | 967 | `chest_minecart` | 968 | `furnace_minecart` | 969 | `tnt_minecart` |
| 970 | `hopper_minecart` | 971 | `carrot_on_a_stick` | 972 | `warped_fungus_on_a_stick` | 973 | `phantom_membrane` |
| 974 | `elytra` | | | | | | |

## 8. Beds and banners (outside the id range)

Both are collections of 16 rows in the colour order of section 2.

| Ids | Keys | Class | Max stack | Components beyond the common set |
|---|---|---|---|---|
| 1219 to 1234 (statement 894) | `<colour>_bed` | `BlockItem` (`ColorCollection.registerBlockItems`, factory builds `Item$Properties` with `stacksTo(1)`) | **1** | none |
| 1417 to 1432 (statement 1077) | `<colour>_banner` | `BannerItem(banner block, wall banner block of the same colour, props)` | **16** | fuel wood_blocks; `banner_patterns` = empty layers (`BannerPatternLayers.EMPTY`) |

- A separate row `straw_bed` (`BlockItemIds.STRAW_BED` over `Blocks.STRAW_BED`, `stacksTo(16)`, compostable `medium_high`; read in `Items.<clinit>`) is registered immediately after the bed collection, so its id is 1235 if the statement order is unbroken (inferred); it is outside the colour collection and this document's id range; the part that owns id 1235 must cover it (cross-reference, Open question 9).
- Bed placement is the plain `BlockItem` flow; the head half is written by the bed block's `setPlacedBy` hook (29 §9.6 step
  6.4, 24).
- `BannerItem extends StandingAndWallBlockItem` with the attachment direction `DOWN` (25-1 §5.3: the wall block is tried
  for the nearest looking directions first, else the standing block). Its constructor checks (`Validate.isInstanceOf`)
  that both blocks are `AbstractBannerBlock`; `getColor()` returns the colour of the standing block. The wall block of
  each row is the wall banner of the same colour picked from the `WALL_BANNER` colour collection with
  `ColorCollection.pick(colour)`.
- `banner_patterns` (component 74): list of (pattern holder, dye colour) layers, 17 §1.2. An empty list is the default of
  every banner item and of the shield; patterns are added by a loom or by commands. The pattern registry entries are data.

## 9. Worked examples

1. **Ids.** `white_shulker_box` is the first of the collection at id 657, so `black_shulker_box` is 657 + 15 = 672 and
   `light_blue_shulker_box` is 657 + 3 = 660. `lime_concrete` is 689 + 5 = 694. `waxed_oxidized_copper_door` is
   902 + 7 = 909. `tripwire_hook` (statement 600) is id 851. The last row, `elytra`, is id 974 (statement 694).
2. **Statement to id.** id = statement + 15 x (colour collections up to and including those before the statement) + 7 x
   (weathering collections before it). For `saddle`, statement 684: 13 colour collections lie before it (`wool`,
   `wool_stairs`, `wool_slab` and the ten of section 2) and 10 weathering collections (`copper_block`, `chiseled_copper`,
   `cut_copper`, `cut_copper_stairs`, `cut_copper_slab`, `copper_bars`, `copper_chain`, `lightning_rod`, `copper_door`,
   `copper_trapdoor`): 684 + 13 x 15 + 10 x 7 = 684 + 195 + 70 = 949, as read.
3. **Fuel.** An `oak_door` (id 889) in a furnace: `cooking/time_wood_items_large` = 200 / 1 = 200 ticks; in a smoker 200 /
   2 = 100. A `white_carpet` (580) is 67 / 1 = 67 and in a blast furnace 67 / 2 = 33 with integer division (26 §9). A
   `crimson_door` (900) has no `cooking_fuel`, so it cannot be burned.
4. **`cooking_fuel` on the wire** for `oak_door`: Boolean false (`00`), Identifier `minecraft:cooking/time_wood_items_large`
   (`27` then 39 bytes), Boolean false (`00`), Identifier `minecraft:cooking/speed_default` (`1F` then 31 bytes). The
   component id is 85 (`55`). In a component patch entry: `55 00 27 ...`. A client that has the item prototypes
   (it builds them from the same code) does not need this unless the stack's patch changes the fuel.
5. **`block_state` of a light item** with level 7 set in a patch: component id 78 (`4E`), map count `01`, the key
   string `level` (`05 6C 65 76 65 6C`), the value string `7` (`01 37`): `4E 01 05 6C 65 76 65 6C 01 37`.
6. **Minecart on a slope.** Clicking a `rail` block at (10, 64, -3) whose shape is `ascending_east` (a slope): the spawn
   position is (10.5, 64 + 0.0625 + 0.5, -2.5) = (10.5, 64.5625, -2.5). On a flat `powered_rail` at the same position it is
   (10.5, 64.0625, -2.5). Clicking a `stone` block returns FAIL and consumes nothing.
7. **Swapping an elytra.** Held: one `elytra`; chest slot: an iron chestplate with no `prevent_armor_change` effect. Right
   click: the slot gets the elytra (the held stack is cleared in survival), the hand gets the chestplate, and `item_used`
   for the elytra is awarded. Held: an `elytra` identical to the one already worn: FAIL (same item, same components).
8. **Shulker box in a bundle.** `white_shulker_box.canFitInsideContainerItems()` is false, `chest`'s is true: a bundle
   (part 4) refuses the first and accepts the second.

## 10. Validation

1. **Statement and item counts.** The statement sequence has 1253 entries and 1658 items. Statement numbers are zero-based (0 to 1252); statements 456 to 694 are 239 statements counted inclusively either way. Statements 456 to 694 are 239;
   the 11 colour collections and 3 weathering collections inside them give 239 + 165 + 21 = 425 = 974 - 550 + 1. By
   class (computed from the statements, section 3): `BlockItem` 357, `DoubleHighBlockItem` 28 (6 tall plants, `iron_door`, 11
   wooden doors, `crimson_door`, `warped_door`, 8 copper doors), `StandingAndWallBlockItem` 11 (10 coral fans and
   `redstone_torch`), `GameMasterBlockItem` 2, `ScaffoldingBlockItem` 1, `MinecartItem` 5, `FoodOnAStickItem` 2, plain `Item`
   19 (`saddle`, 16 harnesses, `phantom_membrane`, `elytra`): 357 + 28 + 11 + 2 + 1 + 5 + 2 + 19 = 425.
2. **Id arithmetic.** The ids of the collections in section 2 match the first and last id of 25-1 §2.3 for `DYED_TERRACOTTA`
   (561 to 576), `CARPET` (580 to 595), `STAINED_GLASS` (605 to 620), `STAINED_GLASS_PANE` (621 to 636),
   `DYED_SHULKER_BOX` (657 to 672), `GLAZED_TERRACOTTA` (673 to 688), `CONCRETE` (689 to 704), `CONCRETE_STAIRS` (705 to
   720), `CONCRETE_SLAB` (721 to 736), `CONCRETE_POWDER` (737 to 752), `LIGHTNING_ROD` (840 to 847), `COPPER_DOOR` (902 to
   909), `COPPER_TRAPDOOR` (924 to 931), `HARNESS` (950 to 965). Both documents compute from the same statements and the same
   expansion rule; they agree.
3. **Keys.** For every single-item row the key string read in `BlockItemIds` or `ItemIds` equals the lower-case field name
   (one exception: `Items.REDSTONE` reads from `BlockItemIds.REDSTONE_DUST`, string `redstone`, 25-1 §4.3).
4. **Component census of the range.** Rows with `cooking_fuel`: 76 (37 `wood_blocks`, 11 `wood_items_extra_small`, 11
   `wood_items_large`, 16 `wool_carpets`, 1 `bamboo`); rows with `container`: 21; rows with `equippable`: 34 (16 carpets,
   `saddle`, 16 harnesses, `elytra`); rows with a rarity: 8; rows with `compostable`: 9; rows with durability: 3
   (`carrot_on_a_stick` 25, `warped_fungus_on_a_stick` 100, `elytra` 432); rows with max stack 1 and no durability: 39
   (17 shulker boxes, `saddle`, 16 harnesses, 5 minecarts).
5. **Cross-checks with other documents.** The strider and carrot steering numbers agree with 44-6 (durability 100, damage 1,
   `fishing_rod` conversion). The `elytra` row agrees with 17 §3.13 (432, `phantom_membrane`, `damage_on_hurt` false). The
   `light` block's `level` property and default 15 agree with 24 part 5. The component ids used (32, 64, 77, 78, 84, 85)
   agree with 46 §8.1.

## 11. Open questions

1. How `ServerPlayer.getProfilePermissions` derives a player's permission level (operator list, singleplayer cheats) was not read (4.1). The numeric level of `GAMEMASTERS` (2) is read and no longer open. Searched: `Player.canUseGameMasterBlocks`, `Player.permissions`, `ServerPlayer.permissions`, `PermissionLevel.<clinit>`. Same as 29 Open question 4.
2. `EntityType.createDefaultStackConfig` chains `appendDefaultStackConfig`, then `appendComponentsConfig(stack)`, then `appendCustomEntityStackConfig` (order read), but the body of each step is not read: which components are copied onto a
   spawned minecart (custom name and so on) and the permission rule of the `entity_data` merge were not read (4.3).
3. Whether a creative-mode player's minecart stack is consumed on placement: `MinecartItem.useOn` itself calls
   `shrink(1)` with no creative test (4.3). The section earlier cited as 13 §2.5 is the creative instant break rule and does not cover item consumption, so the creative handling (`ItemStack` consume, infinite materials; possibly 29 §9.3) was not located and is open.
4. Partly answered: the jar has `assets/minecraft/equipment/saddle.json` and `assets/minecraft/equipment/elytra.json` (read: both have a `layers` object; the saddle file has per-entity layer lists such as `horse_saddle` using texture `minecraft:saddle`, the elytra file a `wings` layer with texture `minecraft:elytra` and `use_player_texture` true). Closed part: the jar holds 45 files under `assets/minecraft/equipment` (counted with `unzip -Z1`, files only), of which 32 are the `<colour>_carpet` and `<colour>_harness` files for all 16 dyes (names read); the rest are `saddle`, `elytra`, armor material files and `trader_llama`, `trader_llama_baby`. Their layer contents are not read here.
5. (Closed: `updateState` leaves the state unchanged for an unparsable value, 5.2.)
6. (Closed: `Slot.CODEC` fields are `slot` and `item`, 5.3.)
7. How a shulker box block entity returns its contents into the dropped item's `container` component when the block is
   broken (24, loot and block entity behaviour) was not read here (5.3).
8. Not read: whether another code path (a command, a dispenser) bypasses `Equippable.canBeEquippedBy` for a player (4.5, 5.1).
9. Beds and banners are at ids outside 550 to 974; this document gives them in section 8 (plus the `straw_bed` neighbour, whose id 1235 is inferred), and part 4 should confirm that its range does not duplicate them with different content.
10. (Closed: `rails` is tabulated in 4.3, `can_equip_saddle` and `can_equip_harness` in 5.1.)
