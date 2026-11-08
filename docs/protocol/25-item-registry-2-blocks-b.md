# Item registry, part 2: block items of ids 228 to 455

| Item | Value |
|---|---|
| Covers | The rows of registry ids 228 to 455 (`flowering_azalea_leaves` to `deepslate_bricks`; 228 items, all block items): key, item class, max stack, and every default component beyond the common set; the three special item classes of the range (`BlockItem` summary, `StandingAndWallBlockItem`, `DoubleHighBlockItem`); the data-driven components these rows use (compost chance, fuel burn time, container, pot decorations, equippable, attribute modifiers) with the keys and the values of the provider files the rows name; the `Direction.orderedByNearest` rule that torch placement needs |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of the lambdas in `Items`), and of data files in the jar (`unzip -p`), with no execution. Class, method and field names in backticks say where a fact was read. Values not read are marked "(inferred)" or "(recalled, not verified)" and are listed in the Open questions |
| Status | Round RS5, part 2 of 8 (design map Part 5 GAP-2, Part 6 row RS5) |
| Shared model | [25-item-registry-1-model-and-blocks-a.md](25-item-registry-1-model-and-blocks-a.md) ("part 1", cited as "25-1 §n") defines the id rule, the registration helpers, the `Item.Properties` builders, the 13-component prototype, the row schema and the data-driven component keys. This document does not repeat them. Siblings: part 1 (ids 0 to 227), part 3 (ids 456 to 694) |

"04 §5" means section 5 of [04-registry-sync.md](04-registry-sync.md); "17 §1" means section 1 of
[17-tools-weapons-and-combat.md](17-tools-weapons-and-combat.md), and so on. "24 §n" is the block registry
([24-block-registry-1-model-and-foundation.md](24-block-registry-1-model-and-foundation.md) and its parts); "26 §9" is
[26-loot-and-predicates.md](26-loot-and-predicates.md); "29 §n" is
[29-block-updates-and-placement.md](29-block-updates-and-placement.md); "46 §8" is
[46-registry-ids.md](46-registry-ids.md); "22" is [22-extraction-tool.md](22-extraction-tool.md). The design map is
`docs/design/README.md`.

Data versus code (design map R7). Ids, keys, item classes and default components are code and are specified here for
every row. Item models, recipes, loot tables, tags and the `context_int_provider` JSON files are data that the
extraction tool (22) copies out of the jar; this document gives the schema of the few provider files the rows name and
the numbers that a row needs to be usable, and does not tabulate the data files.

## Contents

1. Scope, ids and statement numbers
2. What this range registers: the forms
3. The prototype of a block item in this range
4. Components that rows add
5. Item classes of the range
6. Special rows
7. The rows: ids 228 to 455
8. Worked examples
9. Validation
10. Open questions

---

## 1. Scope, ids and statement numbers

- Scope: registry ids 228 to 455 inclusive. By the id rule of 25-1 §2 (id = registration index) these are statements 193 to
  375 of `Items.<clinit>` (183 statements: 180 register one item each, 3 are colour collections of 16 items each, so
  180 + 48 = 228 items).
- **The brief's example numbers are statement numbers, not ids.** The brief names `WILDFLOWERS` 250, `CHERRY_SHELF` 300 and
  `PUMPKIN` 350. Those are the statement numbers (the `putstatic` order of `Items.<clinit>`); the registry ids are
  330, 380 and 430. `STONE_BRICK_STAIRS` (400) and `END_STONE_BRICK_WALL` (450) of the brief are statement numbers
  past the end of this range (statement 375 is the last in it); they are in part 3 or later.
- **Id from statement number** inside this range, for a reader who walks the statements: ids 228 to 249 are statement 193
  to 214 plus 35 (five weathering-copper collections before it, 7 extra items each); `WOOL` is statement 215 and id 250,
  `WOOL_STAIRS` 216 and id 266, `WOOL_SLAB` 217 and id 282 (each colour collection adds 15 extra items to what follows);
  from `DANDELION` (statement 218, id 298) to the end the id is the statement number plus 80 (35 + 3 x 15).
- The range starts exactly at the end of part 1 (id 227 `azalea_leaves`, statement 192) and ends one before the first
  row of part 3 (id 456 `cracked_deepslate_bricks`, statement 376).
- Every item in the range is a block item: its key equals its block key (25-1 §4.2), and its block is registered in 24.
  No item of the range has a different block key (the 14 exceptions of 25-1 §4.3 are all outside it).

## 2. What this range registers: the forms

Census of the 183 statements by the final registration call (25-1 §3 defines the helpers):

| Form | Statements | Items | Example rows |
|---|---|---|---|
| `registerBlock(id, block)`: default factory, fresh properties | 74 | 74 | `sponge`, `glass`, `sandstone`, `crimson_slab`, `obsidian`, `basalt`, `stone_bricks` |
| `registerBlock(id, block, Properties)`: properties built by the statement (54 call `compostable`, 5 of those also `cookingFuel`: `azalea`, `flowering_azalea`, `short_dry_grass`, `tall_dry_grass`, `leaf_litter`; `dead_bush` is the sixth dry_plants fuel row but is built by a lambda and belongs to the UnaryOperator form; the 55th, `decorated_pot`, sets the pot components) | 55 | 55 | `flowering_azalea_leaves`, `fern`, `dandelion`, `pumpkin`, `decorated_pot` |
| `registerBlock(id, block, UnaryOperator<Properties>)`: a lambda adjusts the fresh properties (`cookingFuel`, `component(...)`, or both) | 46 | 46 | `dead_bush`, `bamboo`, the 12 wood slabs, the shelves, `chest`, `carved_pumpkin` |
| `registerBlock(id, block, BiFunction factory)`: a different item class | 3 | 3 | `torch`, `soul_torch`, `copper_torch` (`StandingAndWallBlockItem`) |
| `registerBlock(id, block, factory, Properties)` | 1 | 1 | `small_dripleaf` (`DoubleHighBlockItem`, `compostable low`) |
| `registerBlock(id, block, Properties, Block...)`: extra block mapped to the same item | 1 | 1 | `big_dripleaf` (extra block `big_dripleaf_stem`) |
| `ColorCollection.registerBlockItems` | 3 | 48 | `WOOL`, `WOOL_STAIRS`, `WOOL_SLAB` (25-1 §2.3) |
| Total | 183 | 228 | |

No statement in the range uses `stacksTo`, `rarity`, `overrideDescription`, `durability`, `food`,
`useItemDescriptionPrefix`, `fireResistant` or `jukeboxPlayable` (searched as described in section 9 checks 8 and 9: 0
occurrences). Consequently **every item in the range has max stack 64, rarity common, the block description prefix
(`block.minecraft.<key>`), the vanilla feature set** (no block of `Blocks.<clinit>` calls `requiredFeatures`: 0
occurrences in the class), and no item has `damage`, `food`, `consumable` or `tool`.

Two key points that differ from a first reading of the field names:

1. The `Items` field name is not always the key. The key is the string in `BlockItemIds` for the id used by the statement.
   Three fields in this range differ: `Items.DRY_SHORT_GRASS` (key `short_dry_grass`, id 246), `Items.DRY_TALL_GRASS` (key
   `tall_dry_grass`, id 247) and `Items.CUT_STANDSTONE_SLAB` (the field name carries a typo; key `cut_sandstone_slab`,
   id 358). For the other 177 single-item statements the lower-case field name equals the key (checked: section 9).
2. A colour collection field is the base name: `Items.WOOL` registers `white_wool` ... `black_wool`; the key is the colour name,
   an underscore, then the base name (the concatenation recipe of `ColorCollection.prefixWithColor` is the two operands
   joined by one `_`, colour first; read; the `DyeColor` serialized names were read in this round and match), in the dye order of 24 §2.3 (white, orange, magenta, light_blue, yellow, lime,
   pink, gray, light_gray, cyan, purple, blue, brown, green, red, black).

## 3. The prototype of a block item in this range

The 13-component prototype of 25-1 §7.1 applies unchanged to every row: the 11 components of `COMMON_ITEM_COMPONENTS`
(`max_stack_size` 64, `lore` empty, `enchantments` empty, `repair_cost` 0, `use_effects` default, `attribute_modifiers`
empty, `rarity` common, `break_sound` `entity.item.break` (the registered string of `SoundEvents.ITEM_BREAK`; read), `tooltip_display` default, `attack_animation` and
`interact_animation` default) plus `item_name` = translatable text with key `block.minecraft.<key>` and `item_model` = the
identifier `minecraft:<key>`, both set when the item is constructed (`Item$Properties.finalizeInitializer`, 25-1 §6.2).
A row adds components on top of it (section 4); every other common entry (`use_effects`, `tooltip_display` and the rest) is unchanged for all 228 rows (the statements of this range call none of the property setters that would change them, check 8 of section 9). Order of application (read): the common set is added first (`Item$Properties` constructor), the statement's own
`component(...)` / helper calls follow in call order, then `item_name` and `item_model` last (`finalizeInitializer`); a later
set of the same type replacing an earlier one is inferred from the builder's `set`. A validator then rejects any prototype that has `damage` and a max stack above 1 ("Item
cannot have both durability and be stackable"); no row here has `damage`.

Component type ids used in this range (46 §8.1): `max_stack_size` 1, `item_name` 9, `item_model` 10, `rarity` 12,
`attribute_modifiers` 16, `equippable` 32, `pot_decorations` 76, `container` 77, `compostable` 84, `cooking_fuel` 85.
A stack on the wire carries a patch against the prototype (00 §12.2), so a client must hold the same prototype.

## 4. Components that rows add

### 4.1 `compostable` (84): the chance provider key

Record `Compostable(chanceKey)`, one field: the resource key of a `context_int_provider`. Set by `Properties.compostable(key)`.
The keys used in the range and what their files contain (read in `data/minecraft/context_int_provider/compostable/*.json`):

| Key (`ContextIntProviders` constant, file) | Percent chance a non-empty composter rises |
|---|---|
| `COMPOSTABLE_LOW` (`compostable/low`) | 30 |
| `COMPOSTABLE_LOW_MEDIUM` (`compostable/low_medium`) | 50 |
| `COMPOSTABLE_MEDIUM` (`compostable/medium`) | 65 |
| `COMPOSTABLE_MEDIUM_HIGH` (`compostable/medium_high`) | 85 |

Each file is a `number_dispatcher` with one case and a default. The case: when the block under evaluation is the block
`composter` with state `level` = `0`, the value is 1 (the first item always raises an empty composter). The default is a
`weighted_list` of two entries, data 1 with weight W and data 0 with weight 100 - W, where W is the percentage of the
table. The providers are evaluated by the engine of 26 §9; the composter block that calls them and applies the level
change is block behaviour (24 and the block-behaviour documents; not in this range). (`compostable/always_add_one` is the
constant 1 and is not used in the range; it is in part 3 or later.)

### 4.2 `cooking_fuel` (85): the burn-time provider key

Record `CookingFuel(burnTimeKey, speedKey)`; `Properties.cookingFuel(burnTimeKey)` sets `speedKey` =
`cooking/speed_default` (25-1 §9). Keys used in the range, with the file read (`cooking/time_*.json`):

| Key | `left` (ticks) | Rows |
|---|---|---|
| `COOKING_TIME_WOOD_BLOCKS` (`cooking/time_wood_blocks`) | 300 | 15 plain wooden block items (`bookshelf`, `crafting_table`, `ladder`, `jukebox`, the 11 fences from `oak_fence` to `bamboo_fence`) and 13 container items (11 shelves, `chiseled_bookshelf`, `chest`) |
| `COOKING_TIME_WOOD_SLABS` (`cooking/time_wood_slabs`) | 150 | the 12 wooden slabs, ids 341 to 352 |
| `COOKING_TIME_BAMBOO` (`cooking/time_bamboo`) | 50 | `bamboo` (id 340) |
| `COOKING_TIME_DRY_PLANTS` (`cooking/time_dry_plants`) | 100 | `azalea`, `flowering_azalea`, `dead_bush`, `short_dry_grass`, `tall_dry_grass`, `leaf_litter` |
| `COOKING_TIME_WOOL` (`cooking/time_wool`) | 100 | the 16 wool blocks and the 16 wool stairs, ids 250 to 281 |
| `COOKING_TIME_WOOL_SLABS` (`cooking/time_wool_slabs`) | 50 | the 16 wool slabs, ids 282 to 297 |

Every one of these files is the same shape: `div` of the constant `left` by a `conditional` on the predicate
`block/fast_cooking` (matches `smoker` and `blast_furnace`, 26 §9) whose false branch is the key
`cooking/normal_burn_time_reduction_factor` (constant 1) and true branch `cooking/fast_burn_time_reduction_factor` (constant 2).
The burn time in ticks of an item in a furnace is therefore `left`, and `left / 2` in a smoker or a blast furnace (integer
division by the provider arithmetic of 26 §9). Example: a wooden slab burns 150 ticks in a furnace and 75 in a smoker.
The `speedKey` (`cooking/speed_default`, 1.0 normally, 2.0 in a fast-cooking block, 25-1 §9) is the same for every row.
The fuel engine (the furnace block entity that reads the component) is not in this range.

### 4.3 `container` (77): the empty container

Set by `component(container, ItemContainerContents.EMPTY)`: a container with no slots filled. Present on 17 rows: `chest`,
`furnace`, `decorated_pot`, `chiseled_bookshelf` and all 13 shelves (section 7). The prototype value is the empty list; that
the component is what carries inventory contents when a block is picked or its block entity data is copied to an item is
(inferred, not traced here). A block item also drops its own container contents when the item entity is destroyed: `BlockItem.onDestroyed`
sets the stack's `container` to the empty value, takes the previous value if there was one, and passes the non-empty
stacks to `ItemUtils.onContainerDestroyed` (`ItemUtils.onContainerDestroyed` returns at once on a client level; on the server it creates one new `ItemEntity` per non-empty stack at the destroyed entity's X, Y, Z holding that stack and adds it with `addFreshEntity`; no motion is set there, the initial motion comes from the `ItemEntity` constructor, 41). This hook is inherited by every row of the range (no row
overrides it); it always sets the `container` component to the empty value, so a stack without a container gains an empty container component; no entity is spawned in that case because the previous value is absent.

### 4.4 `pot_decorations` (76): the decorated pot prototype

Only `decorated_pot` (id 392). The statement sets it through a delayed initialiser (it needs the item registry to be
complete): value = `PotDecorations.allBrick`, a record of four optional item templates (`back`, `left`, `right`, `front`),
each the template { item `brick`, count 1, empty component patch }. So the prototype of a decorated pot item shows a pot
with four plain brick sides, not the blank `PotDecorations.EMPTY`.

### 4.4a Wire layout of `pot_decorations`

The record has four optional item slots in the order back, left, right, front, each an optional item template (item, count, component patch); its stream layout is not re-derived here and is owned by 17 §1.2 and 46 (not re-read in this round, Open question 8).

### 4.5 `equippable` (32) and `attribute_modifiers` (16) on the carved pumpkin

Only `carved_pumpkin` (id 431). Its lambda calls `Waypoint.addHideAttribute` on the properties, then sets `equippable`, then
`compostable medium`:

- `attribute_modifiers` = one entry: attribute `waypoint_transmit_range` (46 §4, id 38), modifier id
  `minecraft:waypoint_transmit_range_hide`, amount -1.0, operation `add_multiplied_total`, slot group `head`, tooltip
  display `hidden`. The intended effect is that a worn carved pumpkin cancels the wearer's waypoint transmit range, so the wearer is not
  shown on locator bars (inferred from the modifier name and values; the operation arithmetic and the waypoint consumer were not traced here). The registry default is read: `Attributes.WAYPOINT_TRANSMIT_RANGE` is a ranged attribute with base 0.0, minimum 0.0 and maximum 6.0E7 (sentiment neutral), agreeing with 18 (attribute table, section number not re-checked here); Open question 2.
- `equippable` = `Equippable.builder(HEAD)` with `swappable` = false, camera overlay `minecraft:misc/pumpkinblur`, and every other
  field at the builder default: equip sound `item.armor.equip_generic`, no asset id, no allowed-entity set, `dispensable`
  true, `damage_on_hurt` true, `equip_on_interact` false, `can_be_sheared` false, shearing sound `item.shears.snip`
  (the builder constructor, read).
- Consequences by the rules of 25-1 §5.1: `use` in the air on a swappable `equippable` swaps with the slot, so a carved
  pumpkin is **not** equipped by right-clicking in the air (swappable is false); it is equipped by dispensers
  (`dispensable`: inferred from the field name), by moving the stack into the head slot of the inventory (13 §4 for the slot rules), and the overlay
  identifier is what the client reads when the worn stack's `equippable` carries a camera overlay (Open question 1).
  Right-clicking a block places the pumpkin first, as for any block item (`BlockItem.useOn`, 29 §9.6).

## 5. Item classes of the range

All items of the range are `BlockItem` or one of its two subclasses. 224 rows are plain `BlockItem`, 3 are
`StandingAndWallBlockItem`, 1 is `DoubleHighBlockItem`.

### 5.1 `BlockItem`

Constructor: `BlockItem(block, properties)` stores the block and calls `Item(properties)`. The placement algorithm
(`useOn`, `place`, `canPlace`, sounds, game events, stack consumption) is 29 §9.6 and is not repeated. Behaviour that
rows of this range add or fix (read in `BlockItem`):

| Method | Rule |
|---|---|
| `getBlock()` | the single placed block (the standing block for the torch rows) |
| `registerBlocks(map, item)` | puts the block into `Item.BY_BLOCK` with this item as the value (done at registration, 25-1 §3). `registerBlock` with extra blocks puts them in too |
| `canFitInsideContainerItems()` | true unless the block is a `ShulkerBoxBlock`; always true in this range |
| `onDestroyed(itemEntity)` | section 4.3 |
| `useOn`, `place`, `placeBlock`, `getPlacementState`, `updatePlacementContext` | 29 §9.6 |

### 5.2 `StandingAndWallBlockItem` (rows 395, 439, 440)

Fields: the standing block (the `BlockItem` block), a wall block and an attachment direction. All three rows use attachment
direction `DOWN` and these wall blocks (read in the three factory lambdas):

| Id | Key | Standing block | Wall block |
|---|---|---|---|
| 395 | `torch` | `torch` | `wall_torch` |
| 439 | `soul_torch` | `soul_torch` | `soul_wall_torch` |
| 440 | `copper_torch` | `copper_torch` | `copper_wall_torch` |

Behaviour:

1. `registerBlocks`: the item is registered in `Item.BY_BLOCK` for the standing block (the superclass step) and for the wall
   block, so `Item.byBlock(wall_torch)` is the `torch` item: breaking or picking a wall torch gives the torch item.
2. `getPlacementState(context)` (replaces the superclass rule), in order:
   1. `wallState` = the wall block's `getStateForPlacement(context)` (may be none; the wall block's own facing logic is
      its block behaviour, 24 §10.3).
   2. Take `dirs` = `context.getNearestLookingDirections()` (29 §9.5; its base order is section 5.4).
   3. For each direction `d` in `dirs`, in order: if `d` is the opposite of the attachment direction (`UP`), skip it. Otherwise the
      candidate is the standing block's `getStateForPlacement(context)` when `d` equals the attachment direction (`DOWN`), else
      `wallState`. If the candidate exists and `candidate.canSurvive(level, clickedPos)` is true, it is the result: stop.
   4. If a result was found and `level.isUnobstructed(result, clickedPos, CollisionContext.empty())` is true, return it; else return
      none (which makes `place` fail, 29 §9.6 step 4).
3. `canPlace(level, state, pos)` for this class is only `state.canSurvive(level, pos)` (it is the survival test used in step 2.3).
4. After the state is chosen the common path of 29 §9.6 runs (including its own `canPlace(context, state)` check, the write with
   flags 11, sounds and stack consumption).

### 5.3 `DoubleHighBlockItem` (row 339, `small_dripleaf`)

Constructor is the `BlockItem` one. The only override is `placeBlock(context, state)`:

1. Let `above` = clicked position + (0, 1, 0) (`getClickedPos()` of the context, which is the position being filled).
2. Write the block above: the default state of `water` when `level.isWaterAt(above)` is true, else the default state of `air`,
   with flags 27 (= 1 `UPDATE_NEIGHBORS` + 2 `UPDATE_CLIENTS` + 8 `UPDATE_IMMEDIATE` + 16 `UPDATE_KNOWN_SHAPE`, 29 §1). The result of this write
   is ignored.
3. Call `BlockItem.placeBlock(context, state)` (the normal write of the lower half, flags 11) and return its result.

The effect is that the position above the lower half is cleared (and water kept if the position holds water) before the lower
half is written, so that the upper half can then be written by the block's `setPlacedBy` hook (the double-block hook of 29 §9.6
step 6.4; inferred, the hook of `small_dripleaf` is 24's). `Level.isWaterAt(pos)` (`LevelReader`, read) is true when the fluid state at `pos` is in the fluid tag `water`, so it holds for source and flowing water, and for waterlogged blocks (they have a water fluid state). The class is constructed at 11 `new` sites in lambda bodies and 2 constructor method-handle bootstrap entries of `Items`; the other `DoubleHighBlockItem` rows lie in later parts and are tabulated in 25-3 (ids 599 to 604, 888 to 909 and so on), not here.

### 5.4 `Direction.orderedByNearest(entity)` (needed by 5.2; closes 29 Open question 9)

Input: the placing entity. Output: an array of all six directions, nearest to the viewing direction first.

1. `pitch` = the entity's view X rotation in degrees (`getViewXRot(1.0)`) times 0.017453292; `yaw` = the negation of the view Y rotation
   (`getViewYRot(1.0)`) times 0.017453292. Let `sp` = sin(pitch), `cp` = cos(pitch), `sy` = sin(yaw), `cy` = cos(yaw)
   (the `Mth` sine and cosine on the float widened to double; both are table lookups, read: `Mth.SIN` is a float table of 65536 entries with SIN[i] = (float) sin(i / 10430.378350470453); sin(x) = SIN[(long)(x x 10430.378350470453) & 65535] and cos(x) = SIN[(long)(x x 10430.378350470453 + 16384.0) & 65535]; the cast to long truncates toward zero; the table is filled by the `Mth` static initialiser with the exact `Math.sin`, the fill expression itself was taken from the finding and the table constants 65536, 65535, 16384 and 10430.378350470453 were read in `Mth`). Because of the table, angles at exact multiples of the table step give table values, not exact trigonometry; an implementation must use this table to reproduce tie behaviour. `getViewXRot(1.0)` and `getViewYRot(1.0)` return the plain rotation fields when the partial tick is 1.0.
2. Booleans: `xPos` = (`sy` > 0), `yPos` = (`sp` < 0), `zPos` = (`cy` > 0).
3. Magnitudes: `xAbs` = |`sy`|, `yAbs` = |`sp`|, `zAbs` = |`cy`| (each selected by the matching sign flag; a value of exactly 0 counts as not positive).
   `xComp` = `xAbs` x `cp`, `zComp` = `zAbs` x `cp`.
4. Axis directions: `xDir` = EAST when `xPos` else WEST; `yDir` = UP when `yPos` else DOWN; `zDir` = SOUTH when `zPos` else NORTH.
5. Choose an ordered triple (first, second, third):

| Condition (tested in this order) | Triple |
|---|---|
| `xAbs` > `zAbs` and `yAbs` > `xComp` | (`yDir`, `xDir`, `zDir`) |
| `xAbs` > `zAbs`, `yAbs` <= `xComp`, `zComp` > `yAbs` | (`xDir`, `zDir`, `yDir`) |
| `xAbs` > `zAbs`, `yAbs` <= `xComp`, `zComp` <= `yAbs` | (`xDir`, `yDir`, `zDir`) |
| `xAbs` <= `zAbs` and `yAbs` > `zComp` | (`yDir`, `zDir`, `xDir`) |
| `xAbs` <= `zAbs`, `yAbs` <= `zComp`, `xComp` > `yAbs` | (`zDir`, `xDir`, `yDir`) |
| `xAbs` <= `zAbs`, `yAbs` <= `zComp`, `xComp` <= `yAbs` | (`zDir`, `yDir`, `xDir`) |

6. The result array is [first, second, third, opposite(third), opposite(second), opposite(first)].

All comparisons are single-precision float comparisons with the ordinary less/greater semantics (ties go to the `<=`
branch as the table shows).

## 6. Special rows

Rows that are not "plain" in the sense of section 3 (all others have only the common prototype or one of `compostable`,
`cooking_fuel`):

| Id | Key | What is special |
|---|---|---|
| 250 to 297 | `<colour>_wool`, `<colour>_wool_stairs`, `<colour>_wool_slab` | a colour collection each (16 items); the statement's factory ignores the colour, so the 16 items of a collection differ only by key and block; `cooking_fuel` `wool` (wool, stairs) or `wool_slabs` (slabs) |
| 338 | `big_dripleaf` | `compostable medium`; `Item.BY_BLOCK` also maps the block `big_dripleaf_stem` to this item (picking a stem gives this item) |
| 339 | `small_dripleaf` | `DoubleHighBlockItem` (section 5.3); `compostable low` |
| 392 | `decorated_pot` | `container` empty, `pot_decorations` all-brick (section 4.4) |
| 395, 439, 440 | `torch`, `soul_torch`, `copper_torch` | `StandingAndWallBlockItem` (section 5.2) |
| 431 | `carved_pumpkin` | `equippable` head, `attribute_modifiers` hide, `compostable medium` (section 4.5) |
| 377 to 389 | the 13 shelves | `container` empty; all but `crimson_shelf` (381) and `warped_shelf` (389) also have `cooking_fuel` `wood_blocks` |
| 391, 404, 407 | `chiseled_bookshelf`, `chest`, `furnace` | `container` empty; `chiseled_bookshelf` and `chest` also `wood_blocks` fuel; `furnace` has no fuel |

Rows with `fuel dry_plants` and `compostable`: `azalea` (242, medium), `flowering_azalea` (243, medium_high), `short_dry_grass`
(246) and `tall_dry_grass` (247) and `leaf_litter` (331), all low. `dead_bush` (244) has fuel and no compost component.
Nether wood (`crimson_*`, `warped_*`): the slabs (353, 354) and fences (428, 429) have no fuel component (the 12 slabs and 11
fences of the overworld wood types and bamboo do).

## 7. The rows: ids 228 to 455

Columns are those of 25-1 §10. "Class" is `BlockItem` unless shown. "Max stack" is the `max_stack_size` of the prototype
(64 in every row of the range). "Components beyond the common set": `compostable <k>` = component 84 with provider
`compostable/<k>` (section 4.1); `fuel <k>` = component 85 with burn-time provider `cooking/time_<k>` (section 4.2);
`container empty` (section 4.3); the other entries are described in sections 4.4 and 4.5 and 5.2; `none` = nothing. Rows with
the same entry and consecutive ids are summarised first, for reading.

Runs of equal rows:

| Ids | Keys | Class | Components beyond the common set |
|---|---|---|---|
| 228 | `flowering_azalea_leaves` | BlockItem | compostable low_medium |
| 229 to 237 | `sponge` ... `cobweb` | BlockItem | none |
| 238 | `short_grass` | BlockItem | compostable low |
| 239 | `fern` | BlockItem | compostable medium |
| 240, 241 | `bush`, `red_shrub` | BlockItem | compostable low |
| 242 | `azalea` | BlockItem | compostable medium, fuel dry_plants |
| 243 | `flowering_azalea` | BlockItem | compostable medium_high, fuel dry_plants |
| 244 | `dead_bush` | BlockItem | fuel dry_plants |
| 245 | `firefly_bush` | BlockItem | compostable low |
| 246, 247 | `short_dry_grass`, `tall_dry_grass` | BlockItem | compostable low, fuel dry_plants |
| 248 | `seagrass` | BlockItem | compostable low |
| 249 | `sea_pickle` | BlockItem | compostable medium |
| 250 to 281 | `<colour>_wool`, `<colour>_wool_stairs` | BlockItem | fuel wool |
| 282 to 297 | `<colour>_wool_slab` | BlockItem | fuel wool_slabs |
| 298 | `dandelion` | BlockItem | compostable medium |
| 299 | `golden_dandelion` | BlockItem | none |
| 300 to 313 | `open_eyeblossom` ... `wither_rose` | BlockItem | compostable medium |
| 314, 315 | `torchflower`, `pitcher_plant` | BlockItem | compostable medium_high |
| 316 to 323 | `spore_blossom` ... `warped_roots` | BlockItem | compostable medium |
| 324 to 327 | `nether_sprouts`, `weeping_vines`, `twisting_vines`, `sugar_cane` | BlockItem | compostable low_medium |
| 328 to 330 | `kelp`, `pink_petals`, `wildflowers` | BlockItem | compostable low |
| 331 | `leaf_litter` | BlockItem | compostable low, fuel dry_plants |
| 332 | `moss_carpet` | BlockItem | compostable low |
| 333 | `moss_block` | BlockItem | compostable medium |
| 334, 335 | `pale_moss_carpet`, `pale_hanging_moss` | BlockItem | compostable low |
| 336 | `pale_moss_block` | BlockItem | compostable medium |
| 337 | `hanging_roots` | BlockItem | compostable low |
| 338 | `big_dripleaf` | BlockItem | compostable medium; extra block `big_dripleaf_stem` |
| 339 | `small_dripleaf` | DoubleHighBlockItem | compostable low |
| 340 | `bamboo` | BlockItem | fuel bamboo |
| 341 to 352 | `oak_slab` ... `bamboo_mosaic_slab` | BlockItem | fuel wood_slabs |
| 353 to 376 | `crimson_slab` ... `bricks` | BlockItem | none |
| 377 to 380 | `acacia_shelf` ... `cherry_shelf` | BlockItem | fuel wood_blocks, container empty |
| 381 | `crimson_shelf` | BlockItem | container empty |
| 382 to 388 | `dark_oak_shelf` ... `spruce_shelf` | BlockItem | fuel wood_blocks, container empty |
| 389 | `warped_shelf` | BlockItem | container empty |
| 390 | `bookshelf` | BlockItem | fuel wood_blocks |
| 391 | `chiseled_bookshelf` | BlockItem | fuel wood_blocks, container empty |
| 392 | `decorated_pot` | BlockItem | container empty, pot_decorations all-brick |
| 393, 394 | `mossy_cobblestone`, `obsidian` | BlockItem | none |
| 395 | `torch` | StandingAndWallBlockItem | wall block `wall_torch` |
| 396 to 403 | `end_rod` ... `creaking_heart` | BlockItem | none |
| 404 | `chest` | BlockItem | fuel wood_blocks, container empty |
| 405 | `crafting_table` | BlockItem | fuel wood_blocks |
| 406 | `farmland` | BlockItem | none |
| 407 | `furnace` | BlockItem | container empty |
| 408 | `ladder` | BlockItem | fuel wood_blocks |
| 409 to 412 | `cobblestone_stairs` ... `snow_block` | BlockItem | none |
| 413 | `cactus` | BlockItem | compostable low_medium |
| 414 | `cactus_flower` | BlockItem | compostable low |
| 415 | `clay` | BlockItem | none |
| 416 to 427 | `jukebox` ... `bamboo_fence` | BlockItem | fuel wood_blocks |
| 428, 429 | `crimson_fence`, `warped_fence` | BlockItem | none |
| 430 | `pumpkin` | BlockItem | compostable medium |
| 431 | `carved_pumpkin` | BlockItem | compostable medium, equippable head, attribute_modifiers hide |
| 432 to 438 | `jack_o_lantern` ... `smooth_basalt` | BlockItem | none |
| 439 | `soul_torch` | StandingAndWallBlockItem | wall block `soul_wall_torch` |
| 440 | `copper_torch` | StandingAndWallBlockItem | wall block `copper_wall_torch` |
| 441 to 455 | `glowstone` ... `deepslate_bricks` | BlockItem | none |

Full rows (228 rows; the runs above are a view of this table):

| Id | Key | Class | Max stack | Components beyond the common set |
|---|---|---|---|---|
| 228 | `flowering_azalea_leaves` | BlockItem | 64 | compostable low_medium |
| 229 | `sponge` | BlockItem | 64 | none |
| 230 | `wet_sponge` | BlockItem | 64 | none |
| 231 | `glass` | BlockItem | 64 | none |
| 232 | `tinted_glass` | BlockItem | 64 | none |
| 233 | `lapis_block` | BlockItem | 64 | none |
| 234 | `sandstone` | BlockItem | 64 | none |
| 235 | `chiseled_sandstone` | BlockItem | 64 | none |
| 236 | `cut_sandstone` | BlockItem | 64 | none |
| 237 | `cobweb` | BlockItem | 64 | none |
| 238 | `short_grass` | BlockItem | 64 | compostable low |
| 239 | `fern` | BlockItem | 64 | compostable medium |
| 240 | `bush` | BlockItem | 64 | compostable low |
| 241 | `red_shrub` | BlockItem | 64 | compostable low |
| 242 | `azalea` | BlockItem | 64 | compostable medium, fuel dry_plants |
| 243 | `flowering_azalea` | BlockItem | 64 | compostable medium_high, fuel dry_plants |
| 244 | `dead_bush` | BlockItem | 64 | fuel dry_plants |
| 245 | `firefly_bush` | BlockItem | 64 | compostable low |
| 246 | `short_dry_grass` | BlockItem | 64 | compostable low, fuel dry_plants |
| 247 | `tall_dry_grass` | BlockItem | 64 | compostable low, fuel dry_plants |
| 248 | `seagrass` | BlockItem | 64 | compostable low |
| 249 | `sea_pickle` | BlockItem | 64 | compostable medium |
| 250 | `white_wool` | BlockItem | 64 | fuel wool |
| 251 | `orange_wool` | BlockItem | 64 | fuel wool |
| 252 | `magenta_wool` | BlockItem | 64 | fuel wool |
| 253 | `light_blue_wool` | BlockItem | 64 | fuel wool |
| 254 | `yellow_wool` | BlockItem | 64 | fuel wool |
| 255 | `lime_wool` | BlockItem | 64 | fuel wool |
| 256 | `pink_wool` | BlockItem | 64 | fuel wool |
| 257 | `gray_wool` | BlockItem | 64 | fuel wool |
| 258 | `light_gray_wool` | BlockItem | 64 | fuel wool |
| 259 | `cyan_wool` | BlockItem | 64 | fuel wool |
| 260 | `purple_wool` | BlockItem | 64 | fuel wool |
| 261 | `blue_wool` | BlockItem | 64 | fuel wool |
| 262 | `brown_wool` | BlockItem | 64 | fuel wool |
| 263 | `green_wool` | BlockItem | 64 | fuel wool |
| 264 | `red_wool` | BlockItem | 64 | fuel wool |
| 265 | `black_wool` | BlockItem | 64 | fuel wool |
| 266 | `white_wool_stairs` | BlockItem | 64 | fuel wool |
| 267 | `orange_wool_stairs` | BlockItem | 64 | fuel wool |
| 268 | `magenta_wool_stairs` | BlockItem | 64 | fuel wool |
| 269 | `light_blue_wool_stairs` | BlockItem | 64 | fuel wool |
| 270 | `yellow_wool_stairs` | BlockItem | 64 | fuel wool |
| 271 | `lime_wool_stairs` | BlockItem | 64 | fuel wool |
| 272 | `pink_wool_stairs` | BlockItem | 64 | fuel wool |
| 273 | `gray_wool_stairs` | BlockItem | 64 | fuel wool |
| 274 | `light_gray_wool_stairs` | BlockItem | 64 | fuel wool |
| 275 | `cyan_wool_stairs` | BlockItem | 64 | fuel wool |
| 276 | `purple_wool_stairs` | BlockItem | 64 | fuel wool |
| 277 | `blue_wool_stairs` | BlockItem | 64 | fuel wool |
| 278 | `brown_wool_stairs` | BlockItem | 64 | fuel wool |
| 279 | `green_wool_stairs` | BlockItem | 64 | fuel wool |
| 280 | `red_wool_stairs` | BlockItem | 64 | fuel wool |
| 281 | `black_wool_stairs` | BlockItem | 64 | fuel wool |
| 282 | `white_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 283 | `orange_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 284 | `magenta_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 285 | `light_blue_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 286 | `yellow_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 287 | `lime_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 288 | `pink_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 289 | `gray_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 290 | `light_gray_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 291 | `cyan_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 292 | `purple_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 293 | `blue_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 294 | `brown_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 295 | `green_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 296 | `red_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 297 | `black_wool_slab` | BlockItem | 64 | fuel wool_slabs |
| 298 | `dandelion` | BlockItem | 64 | compostable medium |
| 299 | `golden_dandelion` | BlockItem | 64 | none |
| 300 | `open_eyeblossom` | BlockItem | 64 | compostable medium |
| 301 | `closed_eyeblossom` | BlockItem | 64 | compostable medium |
| 302 | `poppy` | BlockItem | 64 | compostable medium |
| 303 | `blue_orchid` | BlockItem | 64 | compostable medium |
| 304 | `allium` | BlockItem | 64 | compostable medium |
| 305 | `azure_bluet` | BlockItem | 64 | compostable medium |
| 306 | `red_tulip` | BlockItem | 64 | compostable medium |
| 307 | `orange_tulip` | BlockItem | 64 | compostable medium |
| 308 | `white_tulip` | BlockItem | 64 | compostable medium |
| 309 | `pink_tulip` | BlockItem | 64 | compostable medium |
| 310 | `oxeye_daisy` | BlockItem | 64 | compostable medium |
| 311 | `cornflower` | BlockItem | 64 | compostable medium |
| 312 | `lily_of_the_valley` | BlockItem | 64 | compostable medium |
| 313 | `wither_rose` | BlockItem | 64 | compostable medium |
| 314 | `torchflower` | BlockItem | 64 | compostable medium_high |
| 315 | `pitcher_plant` | BlockItem | 64 | compostable medium_high |
| 316 | `spore_blossom` | BlockItem | 64 | compostable medium |
| 317 | `brown_mushroom` | BlockItem | 64 | compostable medium |
| 318 | `red_mushroom` | BlockItem | 64 | compostable medium |
| 319 | `shelf_mushroom` | BlockItem | 64 | compostable medium |
| 320 | `crimson_fungus` | BlockItem | 64 | compostable medium |
| 321 | `warped_fungus` | BlockItem | 64 | compostable medium |
| 322 | `crimson_roots` | BlockItem | 64 | compostable medium |
| 323 | `warped_roots` | BlockItem | 64 | compostable medium |
| 324 | `nether_sprouts` | BlockItem | 64 | compostable low_medium |
| 325 | `weeping_vines` | BlockItem | 64 | compostable low_medium |
| 326 | `twisting_vines` | BlockItem | 64 | compostable low_medium |
| 327 | `sugar_cane` | BlockItem | 64 | compostable low_medium |
| 328 | `kelp` | BlockItem | 64 | compostable low |
| 329 | `pink_petals` | BlockItem | 64 | compostable low |
| 330 | `wildflowers` | BlockItem | 64 | compostable low |
| 331 | `leaf_litter` | BlockItem | 64 | compostable low, fuel dry_plants |
| 332 | `moss_carpet` | BlockItem | 64 | compostable low |
| 333 | `moss_block` | BlockItem | 64 | compostable medium |
| 334 | `pale_moss_carpet` | BlockItem | 64 | compostable low |
| 335 | `pale_hanging_moss` | BlockItem | 64 | compostable low |
| 336 | `pale_moss_block` | BlockItem | 64 | compostable medium |
| 337 | `hanging_roots` | BlockItem | 64 | compostable low |
| 338 | `big_dripleaf` | BlockItem | 64 | compostable medium, also places for block big_dripleaf_stem |
| 339 | `small_dripleaf` | DoubleHighBlockItem | 64 | compostable low |
| 340 | `bamboo` | BlockItem | 64 | fuel bamboo |
| 341 | `oak_slab` | BlockItem | 64 | fuel wood_slabs |
| 342 | `spruce_slab` | BlockItem | 64 | fuel wood_slabs |
| 343 | `birch_slab` | BlockItem | 64 | fuel wood_slabs |
| 344 | `jungle_slab` | BlockItem | 64 | fuel wood_slabs |
| 345 | `acacia_slab` | BlockItem | 64 | fuel wood_slabs |
| 346 | `cherry_slab` | BlockItem | 64 | fuel wood_slabs |
| 347 | `dark_oak_slab` | BlockItem | 64 | fuel wood_slabs |
| 348 | `pale_oak_slab` | BlockItem | 64 | fuel wood_slabs |
| 349 | `mangrove_slab` | BlockItem | 64 | fuel wood_slabs |
| 350 | `poplar_slab` | BlockItem | 64 | fuel wood_slabs |
| 351 | `bamboo_slab` | BlockItem | 64 | fuel wood_slabs |
| 352 | `bamboo_mosaic_slab` | BlockItem | 64 | fuel wood_slabs |
| 353 | `crimson_slab` | BlockItem | 64 | none |
| 354 | `warped_slab` | BlockItem | 64 | none |
| 355 | `stone_slab` | BlockItem | 64 | none |
| 356 | `smooth_stone_slab` | BlockItem | 64 | none |
| 357 | `sandstone_slab` | BlockItem | 64 | none |
| 358 | `cut_sandstone_slab` | BlockItem | 64 | none |
| 359 | `petrified_oak_slab` | BlockItem | 64 | none |
| 360 | `cobblestone_slab` | BlockItem | 64 | none |
| 361 | `brick_slab` | BlockItem | 64 | none |
| 362 | `stone_brick_slab` | BlockItem | 64 | none |
| 363 | `mud_brick_slab` | BlockItem | 64 | none |
| 364 | `nether_brick_slab` | BlockItem | 64 | none |
| 365 | `quartz_slab` | BlockItem | 64 | none |
| 366 | `red_sandstone_slab` | BlockItem | 64 | none |
| 367 | `cut_red_sandstone_slab` | BlockItem | 64 | none |
| 368 | `purpur_slab` | BlockItem | 64 | none |
| 369 | `prismarine_slab` | BlockItem | 64 | none |
| 370 | `prismarine_brick_slab` | BlockItem | 64 | none |
| 371 | `dark_prismarine_slab` | BlockItem | 64 | none |
| 372 | `smooth_quartz` | BlockItem | 64 | none |
| 373 | `smooth_red_sandstone` | BlockItem | 64 | none |
| 374 | `smooth_sandstone` | BlockItem | 64 | none |
| 375 | `smooth_stone` | BlockItem | 64 | none |
| 376 | `bricks` | BlockItem | 64 | none |
| 377 | `acacia_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 378 | `bamboo_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 379 | `birch_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 380 | `cherry_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 381 | `crimson_shelf` | BlockItem | 64 | container empty |
| 382 | `dark_oak_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 383 | `jungle_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 384 | `mangrove_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 385 | `poplar_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 386 | `oak_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 387 | `pale_oak_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 388 | `spruce_shelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 389 | `warped_shelf` | BlockItem | 64 | container empty |
| 390 | `bookshelf` | BlockItem | 64 | fuel wood_blocks |
| 391 | `chiseled_bookshelf` | BlockItem | 64 | fuel wood_blocks, container empty |
| 392 | `decorated_pot` | BlockItem | 64 | container empty, pot_decorations all-brick |
| 393 | `mossy_cobblestone` | BlockItem | 64 | none |
| 394 | `obsidian` | BlockItem | 64 | none |
| 395 | `torch` | StandingAndWallBlockItem | 64 | wall block wall_torch |
| 396 | `end_rod` | BlockItem | 64 | none |
| 397 | `chorus_plant` | BlockItem | 64 | none |
| 398 | `chorus_flower` | BlockItem | 64 | none |
| 399 | `purpur_block` | BlockItem | 64 | none |
| 400 | `purpur_pillar` | BlockItem | 64 | none |
| 401 | `purpur_stairs` | BlockItem | 64 | none |
| 402 | `spawner` | BlockItem | 64 | none |
| 403 | `creaking_heart` | BlockItem | 64 | none |
| 404 | `chest` | BlockItem | 64 | fuel wood_blocks, container empty |
| 405 | `crafting_table` | BlockItem | 64 | fuel wood_blocks |
| 406 | `farmland` | BlockItem | 64 | none |
| 407 | `furnace` | BlockItem | 64 | container empty |
| 408 | `ladder` | BlockItem | 64 | fuel wood_blocks |
| 409 | `cobblestone_stairs` | BlockItem | 64 | none |
| 410 | `snow` | BlockItem | 64 | none |
| 411 | `ice` | BlockItem | 64 | none |
| 412 | `snow_block` | BlockItem | 64 | none |
| 413 | `cactus` | BlockItem | 64 | compostable low_medium |
| 414 | `cactus_flower` | BlockItem | 64 | compostable low |
| 415 | `clay` | BlockItem | 64 | none |
| 416 | `jukebox` | BlockItem | 64 | fuel wood_blocks |
| 417 | `oak_fence` | BlockItem | 64 | fuel wood_blocks |
| 418 | `spruce_fence` | BlockItem | 64 | fuel wood_blocks |
| 419 | `birch_fence` | BlockItem | 64 | fuel wood_blocks |
| 420 | `jungle_fence` | BlockItem | 64 | fuel wood_blocks |
| 421 | `acacia_fence` | BlockItem | 64 | fuel wood_blocks |
| 422 | `cherry_fence` | BlockItem | 64 | fuel wood_blocks |
| 423 | `dark_oak_fence` | BlockItem | 64 | fuel wood_blocks |
| 424 | `pale_oak_fence` | BlockItem | 64 | fuel wood_blocks |
| 425 | `mangrove_fence` | BlockItem | 64 | fuel wood_blocks |
| 426 | `poplar_fence` | BlockItem | 64 | fuel wood_blocks |
| 427 | `bamboo_fence` | BlockItem | 64 | fuel wood_blocks |
| 428 | `crimson_fence` | BlockItem | 64 | none |
| 429 | `warped_fence` | BlockItem | 64 | none |
| 430 | `pumpkin` | BlockItem | 64 | compostable medium |
| 431 | `carved_pumpkin` | BlockItem | 64 | compostable medium, equippable head (unswappable, overlay misc/pumpkinblur), attribute_modifiers waypoint hide |
| 432 | `jack_o_lantern` | BlockItem | 64 | none |
| 433 | `netherrack` | BlockItem | 64 | none |
| 434 | `soul_sand` | BlockItem | 64 | none |
| 435 | `soul_soil` | BlockItem | 64 | none |
| 436 | `basalt` | BlockItem | 64 | none |
| 437 | `polished_basalt` | BlockItem | 64 | none |
| 438 | `smooth_basalt` | BlockItem | 64 | none |
| 439 | `soul_torch` | StandingAndWallBlockItem | 64 | wall block soul_wall_torch |
| 440 | `copper_torch` | StandingAndWallBlockItem | 64 | wall block copper_wall_torch |
| 441 | `glowstone` | BlockItem | 64 | none |
| 442 | `infested_stone` | BlockItem | 64 | none |
| 443 | `infested_cobblestone` | BlockItem | 64 | none |
| 444 | `infested_stone_bricks` | BlockItem | 64 | none |
| 445 | `infested_mossy_stone_bricks` | BlockItem | 64 | none |
| 446 | `infested_cracked_stone_bricks` | BlockItem | 64 | none |
| 447 | `infested_chiseled_stone_bricks` | BlockItem | 64 | none |
| 448 | `infested_deepslate` | BlockItem | 64 | none |
| 449 | `stone_bricks` | BlockItem | 64 | none |
| 450 | `mossy_stone_bricks` | BlockItem | 64 | none |
| 451 | `cracked_stone_bricks` | BlockItem | 64 | none |
| 452 | `chiseled_stone_bricks` | BlockItem | 64 | none |
| 453 | `packed_mud` | BlockItem | 64 | none |
| 454 | `mud_bricks` | BlockItem | 64 | none |
| 455 | `deepslate_bricks` | BlockItem | 64 | none |

## 8. Worked examples

1. **Ids and statements.** `WILDFLOWERS` is statement 250. Statement 250 is past `DANDELION` (statement 218), so its id is
   250 + 80 = 330 (row 330 in section 7). `WOOL` is statement 215, id 250; its colour index 14 is `red`, so `red_wool` is id
   250 + 14 = 264 and `black_wool` (index 15) is 265. `WOOL_SLAB` is id 282; `black_wool_slab` is 282 + 15 = 297. The id after
   `black_wool_slab` is 298, `dandelion`.
2. **A shelf prototype.** `cherry_shelf` (id 380, key `cherry_shelf`): the 11 `COMMON_ITEM_COMPONENTS` entries, then `container`
   = empty, then `cooking_fuel` = (`cooking/time_wood_blocks`, `cooking/speed_default`), then `item_name` = `block.minecraft.cherry_shelf`
   and `item_model` = `minecraft:cherry_shelf`: 15 components, max stack 64. `crimson_shelf` (id 381) is the same without `cooking_fuel`:
   14 components.
3. **Fuel.** A wooden slab (`oak_slab`, id 341) has `cooking/time_wood_slabs`, left = 150, so it burns 150 ticks in a
   furnace and 150 / 2 = 75 in a smoker. A `white_wool_stairs` (id 266) burns 100 / 1 = 100 in a furnace; a `white_wool_slab` (id 282)
   burns 50. `bamboo` (id 340) burns 50. `chest` (id 404) burns 300 and also carries an empty `container`.
4. **Compost.** `pumpkin` (id 430) has `compostable medium`. On an empty composter (`level` 0) the provider returns 1: the level
   always rises. On a composter at `level` 3 the default branch draws data 1 with weight 65 and data 0 with weight 35: the level
   rises with probability 65 / 100. `leaf_litter` (low) rises it with probability 30 / 100 at the same level.
5. **Torch placement, looking horizontally.** A player with view X rotation 0 and view Y rotation 0 has `sp` = 0, `cp` = 1, `sy` = 0,
   `cy` = 1 (values at exactly 0 degrees: table index 0 for sine gives 0, index 16384 for cosine gives the table entry for a quarter turn, the value 1 within float precision; section 5.4): `xPos` false, `yPos` false, `zPos` true, `xAbs` 0, `yAbs` 0, `zAbs` 1,
   `xComp` 0, `zComp` 1, `xDir` WEST, `yDir` DOWN, `zDir` SOUTH. `xAbs` <= `zAbs`, `yAbs` (0) <= `zComp` (1), `xComp` (0) <= `yAbs` (0)
   gives the triple (`zDir`, `yDir`, `xDir`) = (SOUTH, DOWN, WEST), so `orderedByNearest` = [SOUTH, DOWN, WEST, EAST, UP, NORTH].
   The player right-clicks the top face (UP) of a solid block with a `torch`. The clicked block is not replaceable, so the array is
   rotated to put the opposite of the clicked face (DOWN) first (29 §9.5): [DOWN, SOUTH, WEST, EAST, UP, NORTH]. The first
   direction, DOWN, is not the opposite of the attachment direction (UP) and equals the attachment direction, so the candidate is
   the standing torch state; the position is the one above the clicked block, whose floor is that block, so `canSurvive` is true.
   The result is the standing `torch`. If the block under the target position were air, the standing state would fail
   `canSurvive`, and the loop would continue with SOUTH, WEST, EAST (each candidate is the wall state), and skip UP.
6. **Torch on a wall, looking straight down.** View X rotation 90, view Y rotation 0: `sp` = 1, `yPos` false, `yAbs` 1, `zAbs` 1,
   `xAbs` 0, `cp` about 0 (a tiny value; the result does not depend on its sign), so `zComp` about 0 and `xComp` 0.
   `xAbs` (0) <= `zAbs` (1) and `yAbs` (1) > `zComp`: triple (`yDir`, `zDir`, `xDir`) = (DOWN, SOUTH, WEST), result [DOWN,
   SOUTH, WEST, EAST, NORTH, UP]. The player clicks the east face of a stone block. The target position is east of the block, so the
   rotated array starts with the opposite of the clicked face, WEST: [WEST, DOWN, SOUTH, EAST, NORTH, UP]. WEST is neither the
   attachment direction nor UP, so the candidate is the wall torch state; if the wall torch block's own placement rule
   (24 §10.3) gives a state facing east that `canSurvive` on the stone block's face, the item places a `wall_torch` there. Picking it
   gives the `torch` item, because `registerBlocks` mapped `wall_torch` to it.
7. **Small dripleaf in water.** The player places a `small_dripleaf` on a clay block under one block of water. The lower half goes
   at the water block's position. `DoubleHighBlockItem.placeBlock` first writes `water` (the default state) at the position above
   it, because `isWaterAt` is true there, with flags 27; had the position held air, `air` would have been written. Then the lower half
   is written with flags 11.
8. **Carved pumpkin.** Right-clicking the air with a `carved_pumpkin` in hand: the item has `equippable` but `swappable` is false and
   it has no `consumable`, `blocks_attacks` or `kinetic_weapon`, so `use` returns PASS (25-1 §5.1) and nothing is equipped.
   Right-clicking the top of a stone block places the pumpkin block (the normal path of 29 §9.6).
9. **Decorated pot item.** `decorated_pot` (id 392) in the inventory shows four brick sides: its `pot_decorations` prototype is the
   record (back, left, right, front) each = { `brick`, count 1, no component patch }, and its `container` is empty.

## 9. Validation

Checks run in this round (all against the artifact; counts from `Items.<clinit>`, `BlockItemIds.<clinit>` and the jar listing
with `unzip -Z1 ... | grep -v '/$'`):

| # | Check | Result |
|---|---|---|
| 1 | `Items.<clinit>` has 1253 `putstatic` of fields of type `Item` or a collection; 35 are collections (15 weathering of 8 items, 20 colour of 16 items); 1218 single items + 15 x 8 + 20 x 16 | 1218 + 120 + 320 = 1658 items, ids 0 to 1657 (equals the 1658 item model files that 22 counts under `items/`) |
| 2 | statement 192 is `AZALEA_LEAVES` with id 227 and statement 193 is `FLOWERING_AZALEA_LEAVES` with id 228 | agrees with the end of part 1 and the start of this range |
| 3 | statements 193 to 375 | 183 statements, 3 collections: 180 + 48 = 228 items, ids 228 to 455 |
| 4 | statement 375 `DEEPSLATE_BRICKS` has id 455; statement 376 `CRACKED_DEEPSLATE_BRICKS` has id 456 | agrees with the part 3 boundary |
| 5 | collection items: `WOOL` first id 250, `WOOL_STAIRS` 266, `WOOL_SLAB` 282, next statement id 298 | agrees with 25-1 §2.3 (first and last ids) |
| 6 | key = string of the `BlockItemIds` constant used by the statement, for the 180 single-item statements; `BlockItemIds` constant name lower-cased equals that string | 180 of 180; the `Items` field name differs from the `BlockItemIds` constant in 3 (`DRY_SHORT_GRASS`, `DRY_TALL_GRASS`, `CUT_STANDSTONE_SLAB`) |
| 7 | classes: statements whose expanded factory is `StandingAndWallBlockItem`, `DoubleHighBlockItem` | 3 and 1; the other 224 items are `BlockItem` |
| 8 | occurrences of `Item$Properties.stacksTo`, `rarity`, `overrideDescription`, `durability`, `food`, `fireResistant`, `jukeboxPlayable`, `useItemDescriptionPrefix`, `requiredFeatures` (a) in the `javap -c -p -constants` output of `Items.<clinit>` between the `putstatic` of `AZALEA_LEAVES` and that of `DEEPSLATE_BRICKS` (the statements of this range, the one before and the one after), grepped for each method name; (b) in the bodies of the 52 lambdas (46 `UnaryOperator` + 3 torch + 3 colour-collection lambdas; the stretch has 54 `invokedynamic` factory sites, the `decorated_pot` delayed initialiser `lambda$static$89` and the `small_dripleaf` constructor reference are excluded) that the `invokedynamic` sites of that stretch bind (bootstrap indices mapped to `lambda$...` names with `javap -v`, each body grepped) | (a) 0 of each; (b) the lambdas call only `component` (17 calls), `compostable` (1) and `cookingFuel` (42; outside the three inner `UnaryOperator` lambdas `lambda$static$56`, `58`, `60` that the colour-collection lambdas pass to `registerBlock`, which hold `cookingFuel` for wool, wool stairs, wool slabs), none of the others: all rows max stack 64, rarity common, `block.` prefix |
| 9 | `requiredFeatures` occurrences in the whole `javap -c -p -constants` output of `Blocks` (class-wide grep) | 0: the vanilla feature set for every row |
| 10 | rows with `compostable`: low 17, low_medium 6, medium 31, medium_high 3 | 57 rows |
| 11 | rows with `cooking_fuel`: wood_blocks 28, wool 32, wool_slabs 16, wood_slabs 12, dry_plants 6, bamboo 1 | 95 rows |
| 12 | rows with `container` 17 (13 shelves, chest, furnace, chiseled bookshelf, decorated pot); rows with neither compost, fuel, container nor a class or special component | 74, equal to the 74 default-form statements |
| 13 | the sum of the rows of section 7 by class and component | 228 rows; 224 + 3 + 1 classes |

Check 1 detail: `COPPER_BLOCK` (statement 120) is the first collection; the number of items of a statement is 1, 8 (weathering) or 16
(colour), and the sum over all statements was recomputed from the bytecode in this round (it agrees with 25-1 §2.4). The 74 plain rows in check 12 are the 74 statements of the form
`registerBlock(id, block)` of section 2, a count taken independently from the statement forms, so the two censuses
(by form, by components) agree.

An implementer's test list: (a) the id of every key in section 7 round-trips through a table built from the 228 rows; (b) the three
collections expand in dye order with `<colour>_<base>` keys; (c) every row's prototype has exactly the components of its row
plus the 13 of 25-1 §7.1 (the 11 common entries, `item_name`, `item_model`); (d) torch placement gives the standing torch on top of a solid
block and a wall torch on a side face, and `Item.byBlock(wall_torch)` is the torch item; (e) the burn time of every fuel row equals
the `left` value of its key divided by 1 or 2.

## 10. Open questions

1. **Camera overlay consumer.** `carved_pumpkin` sets the camera overlay `minecraft:misc/pumpkinblur` on its `equippable`. The
   client code that draws the overlay when the stack is worn (and its opacity and condition) was not read. The texture itself
   is a resource-pack file (22).
2. **Attribute arithmetic.** The modifier `waypoint_transmit_range_hide` (amount -1.0, operation `add_multiplied_total`) is read;
   how `add_multiplied_total` combines modifiers and how the waypoint code uses `waypoint_transmit_range` (18 attribute table, 46 §4) were not
   traced in this round (the registry default 0.0 with maximum 6.0E7 is read, section 4.5), so the "wearer hidden" effect is inferred.
3. **Wall torch placement.** The wall blocks' own `getStateForPlacement` and `canSurvive` (which neighbour supports a wall torch,
   how the facing is picked) are block behaviour (24 §10.3 and the block parts) and were not re-read here.
4. **Container component source.** That the `container` component of a picked chest, furnace, shelf or decorated pot is filled from
   the block entity (pick block, creative copy, break with a loot function) is not traced here; 26 owns the loot function and block entity
   data components (`copy_components`).
5. **`tooltip_display` default and `use_effects` default** are those of 25-1 §7.1 (their open questions apply).
6. **Names.** The English display names of the 228 items are data in the resource pack's `lang/en_us.json` (design map GAP-27); this
    document gives only translation keys (`block.minecraft.<key>`).
7. **Composter and furnace engines.** Where the `compostable` and `cooking_fuel` components are consumed (the composter block
    behaviour, the furnace, smoker and blast furnace block entities) are outside this part; 25-1 §9 states the same open point.
8. **`pot_decorations` stream layout.** The wire encoding of the record is not given here and was not re-read; see 17 §1.2 and 46.
