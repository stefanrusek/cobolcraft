# Item registry, continuation x1: the block items of ids 456 to 549 (statements 376 to 455)

| Item | Value |
|---|---|
| Covers | The 94 registry rows that parts 2 and 3 of the item registry left out: ids 456 to 549 (`cracked_deepslate_bricks` to `cobbled_deepslate_wall`), statements 376 to 455 of `Items.<clinit>`. For each row: id, statement, key, item class, max stack and the components beyond the common set. Also the two item classes this run introduces (`GameMasterBlockItem`, `PlaceOnWaterBlockItem`), the compost and fuel keys it uses, and a reconciliation of the id and statement labels of 25-2 and 25-3 |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of the lambdas in `Items`; `BlockItemIds` for the key strings) and of data files in the jar (`unzip -p`, `unzip -Z1`), with no execution. Class, method and field names in backticks say where a fact was read. Values not read are marked "(inferred)" or "(recalled, not verified)" and are listed in the Open questions |
| Status | Round RS5, continuation x1 (design map Part 5 GAP-2, Part 6 row RS5) |
| Shared model | [25-item-registry-1-model-and-blocks-a.md](25-item-registry-1-model-and-blocks-a.md) ("25-1 §n") defines the id rule, the helpers, the 13-component prototype, the row schema and the data-driven component keys. [25-item-registry-2-blocks-b.md](25-item-registry-2-blocks-b.md) ("25-2") ends at id 455; [25-item-registry-3-blocks-c-and-utility.md](25-item-registry-3-blocks-c-and-utility.md) ("25-3") starts at id 550. This document fills the gap between them and does not repeat the model |

Data versus code (design map R7). Ids, keys, classes and default components are code and are tabulated here. Item
models, recipes, loot tables, tags and the `context_int_provider` files are data copied by the extraction tool
([22-extraction-tool.md](22-extraction-tool.md)); only the schema and the numbers a row needs are given.

## Contents

1. Scope and the reconciliation of labels
2. Census of the run
3. Item classes introduced here
4. Components used by the rows
5. The rows: ids 456 to 549
6. Worked examples
7. Validation
8. Open questions

---

## 1. Scope and the reconciliation of labels

1. **The gap.** 25-2 covers ids 228 to 455 and 25-3 covers ids 550 to 974. Ids 456 to 549 were in neither. They are one
   contiguous run of **80 statements** (statement 376 `CRACKED_DEEPSLATE_BRICKS` to statement 455 `COBBLED_DEEPSLATE_WALL`)
   that register **94 items**: 78 statements register one item each and the two weathering collections `COPPER_BARS`
   (statement 385) and `COPPER_CHAIN` (statement 387) register 8 each; 78 + 16 = 94 = 80 + 2 x 7. Statements are zero-based,
   as in 25-1 §2 (statement 0 is `air`); the statement order was walked from the `putstatic` sequence of the artifact in
   this round, and the totals agree with 25-1 (1253 statements, 1658 items).
2. **Id from statement inside the run.**

| Statements | Offset (id = statement + offset) |
|---|---|
| 376 to 384 (`cracked_deepslate_bricks` to `iron_bars`) | 80 (ids 456 to 464) |
| 385 `copper_bars` | 80; the collection takes ids 465 to 472 |
| 386 `iron_chain` | 87 (id 473) |
| 387 `copper_chain` | 87; the collection takes ids 474 to 481 |
| 388 to 455 (`glass_pane` to `cobbled_deepslate_wall`) | 94 (ids 482 to 549) |

3. **Label reconciliation.** 25-2's "Id" column holds ids: its last row, id 455 `deepslate_bricks`, is statement 375
   (375 + 80). Its rule "from statement 218 the id is statement + 80" holds up to statement 375. 25-3 §1 is right that its
   range starts at statement 456 (id 550) and that the preceding run ends at id 549 (`cobbled_deepslate_wall`, statement
   455); its phrase "Part 2 ends with id 549" means the run before 25-3, which is this document's last row. 25-2 itself ends
   at id 455 and its header line "part 3 (ids 456 to 694)" is a mislabel for "ids 456 to 974 across this document and 25-3".
   The numbers agree; only that wording differs.
4. **Keys.** The key of every one of the 80 statements is the lower-case field name of `Items`, and equals the key strings
   of `BlockItemIds` (read for all 80, no exception; so item key = block key for the whole run, 25-1 §4.2). For the two
   collections the base names are `copper_bars` and `copper_chain` (read as the single string in `BlockItemIds`), and the
   eight keys of each are the prefixes of 25-1 §2.3 joined in front: `copper_bars`, `exposed_copper_bars`,
   `weathered_copper_bars`, `oxidized_copper_bars`, `waxed_copper_bars`, `waxed_exposed_copper_bars`,
   `waxed_weathered_copper_bars`, `waxed_oxidized_copper_bars` (all 8 matching item definition files
   `assets/minecraft/items/<key>.json` in the jar; same for `copper_chain`). `iron_bars` and `iron_chain` are separate
   statements (384, 386), not part of the collections.
5. **Items the brief listed as missing that are outside this run.** Wooden stairs are inside (ids 515 to 526, 527 `crimson`,
   528 `warped`), so are the stone, brick, mud brick, nether brick, sandstone and resin brick stairs and 19 walls. Other
   keys named in the brief (waxed copper bulbs, grates, lanterns, chests and golem statues, `copper_chest`) are registered
   later (25-1 §2.3 gives their collections at ids 1517 to 1652; rows in 25-8) and are not part of this run.

## 2. Census of the run

| Form (by the registration call) | Statements | Items |
|---|---|---|
| `registerBlock(id, block)`: plain `BlockItem`, no extra component | 55 | 55 |
| `registerBlock(id, block, properties)` with `compostable` | 6 (`brown_mushroom_block`, `red_mushroom_block`, `mushroom_stem`, `melon`, `vine`, `glow_lichen`) | 6 |
| `registerBlock(id, block, properties)` with `rarity` | 2 (`dragon_egg` epic, `beacon` rare) | 2 |
| `registerBlock(id, block, factory, properties)` | 2 (`lily_pad`, `command_block`) | 2 |
| `registerBlock(id, block, UnaryOperator)` adding `cooking_fuel` (the 12 wooden stairs) | 12 | 12 |
| `registerItem(BlockItemId, factory)` (`resin_clump`) | 1 | 1 |
| `WeatheringCopperCollection.registerItems` | 2 | 16 |
| Total | 80 | 94 |

55 + 6 + 2 + 2 + 12 + 1 + 2 = 80 statements; 55 + 6 + 2 + 2 + 12 + 1 + 16 = 94 items. No row of the run sets
`stacksTo`, `durability`, `food`, `fireResistant` or any component other than the ones named in section 4 (read: the
only `Item.Properties` builder calls in the 80 statements are `compostable`, `rarity`, `cookingFuel` and the
description-prefix calls the helpers make).

## 3. Item classes introduced here

| Class | Rows | Behaviour read |
|---|---|---|
| `BlockItem` | all rows except the two below | 25-1 §5.2 |
| `PlaceOnWaterBlockItem` | `lily_pad` (id 497) | `useOn` returns PASS (right-clicking a block does nothing by itself). `use` (right click, also on air): trace a player-point-of-view ray with the fluid mode SOURCE_ONLY (only water source blocks, not flowing water, count as hit), take the block position of the hit and add one block upward, build a `UseOnContext` for the same player and hand with the hit result moved to that position, and run the normal `BlockItem.useOn` on it. The lily pad therefore is placed on the surface of a water source it is aimed at. The normal placement checks (29) then decide: the lily pad block's own survival rule |
| `GameMasterBlockItem` | `command_block` (id 529) | overrides `getPlacementState`: the result is the normal one only when the placing player exists and `Player.canUseGameMasterBlocks()` is true; otherwise null (placement fails, nothing is consumed). Nothing else changes. The permission test is the op-or-creative rule of the player (13) |

`resin_clump` (id 486) is registered with `createBlockItemWithCustomItemName(block)` through `registerItem(BlockItemId, ...)`: its class is `BlockItem`, but it uses the item description prefix (`item.minecraft.resin_clump`) instead of `block.minecraft.resin_clump` (25-1 §3 and §6.3), so its translated name is looked up under the `item.` key. It is also registered as a block item of block `resin_clump`, so `Item.byBlock` maps that block back to it.

## 4. Components used by the rows

| Row text | Meaning |
|---|---|
| `fuel wood_blocks` | `cooking_fuel` = (`cooking/time_wood_blocks`, `cooking/speed_default`); burn time 300 ticks in a furnace, 150 in a smoker or blast furnace (25-1 §9; the 12 lambdas of the stairs all reference the `COOKING_TIME_WOOD_BLOCKS` key) |
| `compostable <key>` | `compostable` with provider `compostable/<key>`. Weights as 25-1 §9: `medium` 65 for 1 and 35 for 0; `medium_high` 85 and 15 (25-1 §9, read there). `low_medium` is read in this round: a `number_dispatcher` whose single case, a composter with `level` 0, gives 1; the default is a `weighted_list` of data 1 weight 50 and data 0 weight 50, i.e. a 50 percent chance to raise a composter that is not empty |
| `rarity <name>` | `rarity` component (7.2 in 25-1): `epic` is 3, `rare` is 2. `dragon_egg` and `command_block` epic, `beacon` rare |
| `none` | only the 13 common components of 25-1 §7.1 |

## 5. The rows: ids 456 to 549

Columns follow 25-1 §10 with the statement number added; max stack is 64 for every row (section 2).

| Id | Statement | Key | Class | Max stack | Components beyond the common set |
|---|---|---|---|---|---|
| 456 | 376 | `cracked_deepslate_bricks` | BlockItem | 64 | none |
| 457 | 377 | `deepslate_tiles` | BlockItem | 64 | none |
| 458 | 378 | `cracked_deepslate_tiles` | BlockItem | 64 | none |
| 459 | 379 | `chiseled_deepslate` | BlockItem | 64 | none |
| 460 | 380 | `reinforced_deepslate` | BlockItem | 64 | none |
| 461 | 381 | `brown_mushroom_block` | BlockItem | 64 | compostable medium_high |
| 462 | 382 | `red_mushroom_block` | BlockItem | 64 | compostable medium_high |
| 463 | 383 | `mushroom_stem` | BlockItem | 64 | compostable medium |
| 464 | 384 | `iron_bars` | BlockItem | 64 | none |
| 465 | 385 | `copper_bars` | BlockItem | 64 | none |
| 466 | 385 | `exposed_copper_bars` | BlockItem | 64 | none |
| 467 | 385 | `weathered_copper_bars` | BlockItem | 64 | none |
| 468 | 385 | `oxidized_copper_bars` | BlockItem | 64 | none |
| 469 | 385 | `waxed_copper_bars` | BlockItem | 64 | none |
| 470 | 385 | `waxed_exposed_copper_bars` | BlockItem | 64 | none |
| 471 | 385 | `waxed_weathered_copper_bars` | BlockItem | 64 | none |
| 472 | 385 | `waxed_oxidized_copper_bars` | BlockItem | 64 | none |
| 473 | 386 | `iron_chain` | BlockItem | 64 | none |
| 474 | 387 | `copper_chain` | BlockItem | 64 | none |
| 475 | 387 | `exposed_copper_chain` | BlockItem | 64 | none |
| 476 | 387 | `weathered_copper_chain` | BlockItem | 64 | none |
| 477 | 387 | `oxidized_copper_chain` | BlockItem | 64 | none |
| 478 | 387 | `waxed_copper_chain` | BlockItem | 64 | none |
| 479 | 387 | `waxed_exposed_copper_chain` | BlockItem | 64 | none |
| 480 | 387 | `waxed_weathered_copper_chain` | BlockItem | 64 | none |
| 481 | 387 | `waxed_oxidized_copper_chain` | BlockItem | 64 | none |
| 482 | 388 | `glass_pane` | BlockItem | 64 | none |
| 483 | 389 | `melon` | BlockItem | 64 | compostable medium |
| 484 | 390 | `vine` | BlockItem | 64 | compostable low_medium |
| 485 | 391 | `glow_lichen` | BlockItem | 64 | compostable low_medium |
| 486 | 392 | `resin_clump` | BlockItem (item. name prefix) | 64 | none; registered by `registerItem(BlockItemId, factory)` |
| 487 | 393 | `resin_block` | BlockItem | 64 | none |
| 488 | 394 | `resin_bricks` | BlockItem | 64 | none |
| 489 | 395 | `resin_brick_stairs` | BlockItem | 64 | none |
| 490 | 396 | `resin_brick_slab` | BlockItem | 64 | none |
| 491 | 397 | `resin_brick_wall` | BlockItem | 64 | none |
| 492 | 398 | `chiseled_resin_bricks` | BlockItem | 64 | none |
| 493 | 399 | `brick_stairs` | BlockItem | 64 | none |
| 494 | 400 | `stone_brick_stairs` | BlockItem | 64 | none |
| 495 | 401 | `mud_brick_stairs` | BlockItem | 64 | none |
| 496 | 402 | `mycelium` | BlockItem | 64 | none |
| 497 | 403 | `lily_pad` | PlaceOnWaterBlockItem | 64 | compostable medium |
| 498 | 404 | `nether_bricks` | BlockItem | 64 | none |
| 499 | 405 | `cracked_nether_bricks` | BlockItem | 64 | none |
| 500 | 406 | `chiseled_nether_bricks` | BlockItem | 64 | none |
| 501 | 407 | `nether_brick_fence` | BlockItem | 64 | none |
| 502 | 408 | `nether_brick_stairs` | BlockItem | 64 | none |
| 503 | 409 | `sculk` | BlockItem | 64 | none |
| 504 | 410 | `sculk_vein` | BlockItem | 64 | none |
| 505 | 411 | `sculk_catalyst` | BlockItem | 64 | none |
| 506 | 412 | `sculk_shrieker` | BlockItem | 64 | none |
| 507 | 413 | `enchanting_table` | BlockItem | 64 | none |
| 508 | 414 | `end_portal_frame` | BlockItem | 64 | none |
| 509 | 415 | `end_stone` | BlockItem | 64 | none |
| 510 | 416 | `end_stone_bricks` | BlockItem | 64 | none |
| 511 | 417 | `dragon_egg` | BlockItem | 64 | rarity epic |
| 512 | 418 | `sandstone_stairs` | BlockItem | 64 | none |
| 513 | 419 | `ender_chest` | BlockItem | 64 | none |
| 514 | 420 | `emerald_block` | BlockItem | 64 | none |
| 515 | 421 | `oak_stairs` | BlockItem | 64 | fuel wood_blocks |
| 516 | 422 | `spruce_stairs` | BlockItem | 64 | fuel wood_blocks |
| 517 | 423 | `birch_stairs` | BlockItem | 64 | fuel wood_blocks |
| 518 | 424 | `jungle_stairs` | BlockItem | 64 | fuel wood_blocks |
| 519 | 425 | `acacia_stairs` | BlockItem | 64 | fuel wood_blocks |
| 520 | 426 | `cherry_stairs` | BlockItem | 64 | fuel wood_blocks |
| 521 | 427 | `dark_oak_stairs` | BlockItem | 64 | fuel wood_blocks |
| 522 | 428 | `pale_oak_stairs` | BlockItem | 64 | fuel wood_blocks |
| 523 | 429 | `mangrove_stairs` | BlockItem | 64 | fuel wood_blocks |
| 524 | 430 | `poplar_stairs` | BlockItem | 64 | fuel wood_blocks |
| 525 | 431 | `bamboo_stairs` | BlockItem | 64 | fuel wood_blocks |
| 526 | 432 | `bamboo_mosaic_stairs` | BlockItem | 64 | fuel wood_blocks |
| 527 | 433 | `crimson_stairs` | BlockItem | 64 | none |
| 528 | 434 | `warped_stairs` | BlockItem | 64 | none |
| 529 | 435 | `command_block` | GameMasterBlockItem | 64 | rarity epic |
| 530 | 436 | `beacon` | BlockItem | 64 | rarity rare |
| 531 | 437 | `cobblestone_wall` | BlockItem | 64 | none |
| 532 | 438 | `mossy_cobblestone_wall` | BlockItem | 64 | none |
| 533 | 439 | `brick_wall` | BlockItem | 64 | none |
| 534 | 440 | `prismarine_wall` | BlockItem | 64 | none |
| 535 | 441 | `red_sandstone_wall` | BlockItem | 64 | none |
| 536 | 442 | `mossy_stone_brick_wall` | BlockItem | 64 | none |
| 537 | 443 | `granite_wall` | BlockItem | 64 | none |
| 538 | 444 | `stone_brick_wall` | BlockItem | 64 | none |
| 539 | 445 | `mud_brick_wall` | BlockItem | 64 | none |
| 540 | 446 | `nether_brick_wall` | BlockItem | 64 | none |
| 541 | 447 | `andesite_wall` | BlockItem | 64 | none |
| 542 | 448 | `red_nether_brick_wall` | BlockItem | 64 | none |
| 543 | 449 | `sandstone_wall` | BlockItem | 64 | none |
| 544 | 450 | `end_stone_brick_wall` | BlockItem | 64 | none |
| 545 | 451 | `diorite_wall` | BlockItem | 64 | none |
| 546 | 452 | `blackstone_wall` | BlockItem | 64 | none |
| 547 | 453 | `polished_blackstone_wall` | BlockItem | 64 | none |
| 548 | 454 | `polished_blackstone_brick_wall` | BlockItem | 64 | none |
| 549 | 455 | `cobbled_deepslate_wall` | BlockItem | 64 | none |

Groups, for reading: 456 to 460 deepslate variants (plain); 461 to 463 mushroom blocks and stem; 464 `iron_bars`; 465 to 472
the eight copper bars; 473 `iron_chain`; 474 to 481 the eight copper chains; 482 `glass_pane`; 483 `melon`; 484 `vine`, 485
`glow_lichen`; 486 `resin_clump`; 487 to 492 resin blocks (`resin_block`, `resin_bricks`, `resin_brick_stairs`,
`resin_brick_slab`, `resin_brick_wall`, `chiseled_resin_bricks`); 493 to 495 brick, stone brick and mud brick stairs; 496
`mycelium`; 497 `lily_pad`; 498 to 502 nether brick family; 503 to 506 sculk blocks; 507 `enchanting_table`; 508
`end_portal_frame`; 509, 510 end stone and bricks; 511 `dragon_egg`; 512 `sandstone_stairs`; 513 `ender_chest`; 514
`emerald_block`; 515 to 526 wooden stairs (fuel), 527 `crimson_stairs`, 528 `warped_stairs` (no fuel); 529 `command_block`;
530 `beacon`; 531 to 549 the 19 walls.

## 6. Worked examples

1. **Statement to id.** `RESIN_BRICK_WALL` is statement 397; it is after both collections, so id = 397 + 94 = 491. `IRON_CHAIN`
   is statement 386: 386 + 87 = 473. `COPPER_CHAIN` (statement 387) takes 474 to 481, so `waxed_oxidized_copper_chain`
   is 474 + 7 = 481 and `glass_pane` (statement 388) is 482.
2. **Copper bars family.** `weathered_copper_bars`: collection base id 465, weathered is position 2 of the 8 prefixes, so
   id 467. `waxed_copper_bars` is position 4, id 469. Each is a plain `BlockItem`, max stack 64, 13 components.
3. **A wooden stair prototype.** `cherry_stairs` (id 520): the 11 common entries, `item_name` = `block.minecraft.cherry_stairs`,
   `item_model` = `minecraft:cherry_stairs`, and `cooking_fuel` = (`cooking/time_wood_blocks`, `cooking/speed_default`): 14
   components; it burns 300 ticks in a furnace and 150 in a smoker. `crimson_stairs` (id 527) has the 13 only.
4. **Compost.** `vine` (id 484) on a composter with `level` 2: the default branch draws data 1 with probability 50 / 100.
   On an empty composter (`level` 0) the level always rises by 1. `brown_mushroom_block` rises it with probability 85 / 100
   at level 2.
5. **Lily pad.** A player aims at a water source block whose top is open air and right-clicks with a `lily_pad`. The ray
   (fluid mode source only) hits the water block; the position one block above it becomes the target; the normal block-item
   placement runs with that target. Aimed at flowing water the ray does not hit and nothing is placed.
6. **Command block.** A survival player without game-master permission uses a `command_block` on a solid block:
   `getPlacementState` returns null, so `place` fails and the stack is not consumed. With permission it places as an
   ordinary block item.
7. **Resin clump name.** `resin_clump` translates through `item.minecraft.resin_clump` although it places a block;
   `resin_block` translates through `block.minecraft.resin_block`.

## 7. Validation

1. **Count.** The rows of section 5 are 94, with ids 456 to 549 consecutive, none skipped, none repeated.
2. **Join with the neighbours.** Row 455 of 25-2 is `deepslate_bricks`; the first row here is 456 `cracked_deepslate_bricks`. The
   last row here is 549 `cobbled_deepslate_wall`; the first row of 25-3 is 550 `polished_deepslate_wall`. Statements 375
   (25-2) and 376 (here), 455 (here) and 456 (25-3) are consecutive.
3. **Census.** Counting section 5 by (class, components): plain `BlockItem` 71 rows (55 statements plus 16 copper rows), fuel
   12, compostable on `BlockItem` 6, `lily_pad` 1, `command_block` 1, `resin_clump` 1, `dragon_egg` 1, `beacon` 1; 71 + 12 + 6 + 1 + 1 +
   1 + 1 + 1 = 94.
4. **Totals of the registry.** Ids up to 549 here plus 25-3 (550 to 974) and later parts add to 1658 as 25-1 §2.4 states;
   this run neither adds nor removes items.
5. **Key rule.** Item key equals block key for all 94 rows (every `BlockItemIds` string for the run equals the lower-case
   field name), so the 14-row exception table of 25-1 §4.3 does not touch this run (`resin_clump` is one of its three
   same-key `registerItem(BlockItemId, ...)` statements, 25-1 §4.3).
6. **Block registry.** Each key must exist in the block registry (24 §2 and parts) with the same key; the walls, stairs and
   bars correspond to 24 parts 7 and 8 (not re-read here).

## 8. Open questions

1. Whether the blocks that each row's `block` argument names are registered with block states that the item rows depend
   on (for example the `lily_pad` and `resin_clump` block survival rules) is owned by 24 and 29 and was not re-read here.
2. The `canUseGameMasterBlocks` permission rule (operator level, creative mode) is cited from 13 and was not read in this
   round (recalled, not verified).
3. The weights of `compostable/medium` and `compostable/medium_high` are taken from 25-1 §9; only `low_medium` was read
   in this round.
4. Whether `Item.byBlock` has any extra block entries for the rows of this run (the two `extra` varargs statements of
   25-1 §3 lie outside the run) was not exhaustively checked beyond the registration forms listed in section 2.
