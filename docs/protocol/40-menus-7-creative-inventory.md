# 40-7 Menus and screens, part 7: the creative inventory screen

| Item | Value |
|---|---|
| Covers | The creative inventory screen (`CreativeModeInventoryScreen`, inner `ItemPickerMenu`, `CustomCreativeSlot`, `SlotWrapper`, `CreativeInventoryListener`): the tab registry (14 tabs, ids, titles, rows, columns, icons, alignment, backgrounds, types), which tabs are displayed, how the content list of a tab is built (`CreativeModeTab`, `CreativeModeTabs`: visibility modes, display parameters, the special generators and the operator-only rule), the screen geometry (image size, tab pixel boxes, selected and unselected sprites, icon positions, the 9x5 grid, the hotbar row, the scrollbar and its maths, the delete slot, the search box), the survival-inventory tab slot remapping, the saved-hotbars tab and its file, the search tab (name search, tag search, tooltips), every creative-mode click rule (pick up, clone, swap, drop, delete, delete-all, drag), the packets the screen sends (Set Creative Mode Slot, cross-reference to 05c) and the server rule for them, and the opening and refresh rules. The per-item member list of each tab is NOT given here (see this part §4.6 and Open question 1). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`). |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of data files in the same jar (PNG headers, `lang/en_us.json`), with no execution. Every value was read in this round; anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions. |
| Round | RS14, part 7 (design map `docs/design/README.md` GAP-19). The shared menu model, the generic container screen and the table schema are in [40-menus-1-model-and-containers.md](40-menus-1-model-and-containers.md) (cited as 40-1); this part does not repeat them. |
| Related | 05c (0x39 Set Creative Mode Slot, 0x2C-range container clicks), 40-1 §2.2, §3.4 (click types, drag), §5 (generic screen, hit tests, button numbers), 13 §3.5 (the inventory menu 46 slots), 13 §3.9 (the recipe-book search tree, same engine), 13 §7 (key bindings), 12 §5.6 to §5.9 (container drawing, tooltips, sprites), 25 (item registry), 46 §5.5 (menu types: this screen has none), 41 (item entity physics for dropped items). |

Class names in backticks say where a fact was read. They are provenance, not design. Pixel art and `lang` text come from the extracted resource pack (08, 22); only the numbers the code depends on are given.

All pixel coordinates are relative to (`leftPos`, `topPos`) of the screen unless stated, in GUI pixels. "Left button" is the primary button (button number 1 in this version's numbering, 40-1 §5.5); the code compares the number against that constant directly.

---

## 1. Identity

| Item | Value |
|---|---|
| Screen class | `CreativeModeInventoryScreen` (extends the generic container screen, 40-1 §5) |
| Menu class | inner `ItemPickerMenu`, a client-only `AbstractContainerMenu` created with menu type none and container id 0 |
| Menu type | none (not in the `menu` registry, 40-1 §2.2) |
| Image size | 195 wide, 136 high (constructor arguments) |
| Background texture size | 256 x 256 (sheet) |
| Title | no title on the screen object (empty component); the selected tab's own title is drawn (section 6.3) |
| Available when | the local player has infinite materials (`hasInfiniteMaterials`, the creative abilities flag "instabuild", 05a Player Abilities 0x08). In any other case the screen replaces itself with the survival `InventoryScreen`. |
| Opened by | the inventory key; `InventoryScreen.init` itself redirects to the creative screen when the player has infinite materials (so the creative screen is what the inventory key shows in creative mode); `InventoryScreen` has a second code path (a method that ends just before its `init`) that also constructs the creative screen with the same arguments (its trigger was not traced, Open question 14). Constructor arguments: the local player, the connection's enabled feature flag set, and the boolean client option `operatorItemsTab` ("show operator items tab"). |
| `displayOperatorCreativeTab` | the third constructor argument, stored |
| Has operator permission (`hasPermissions`) | `player.canUseGameMasterBlocks()` AND `displayOperatorCreativeTab`. `canUseGameMasterBlocks` is true when the abilities `instabuild` flag is set AND the player's permission set contains the game-master permission level (`Permissions.COMMANDS_GAMEMASTER`, command permission level 2 in the earlier numbering, inferred from the name). |
| Closes | like any container screen; `removed` unregisters the creative listener (section 9.2) |
| Pause | not a pause screen (40-1 §5.5) |

Tick behaviour (`containerTick`): the generic tick, then, if a local player exists, `tryRefreshInvalidatedTabs` with the connection's enabled features, `hasPermissions` and the level's registry access (section 4.5), then, if the player no longer has infinite materials, the screen is replaced by `InventoryScreen`.

The selected tab is a static field of the screen class (`selectedTab`), so it survives closing and reopening the screen. Its initial value is the default tab, `building_blocks` (`CreativeModeTabs.getDefaultTab`).

---

## 2. Tab model (`CreativeModeTab`)

### 2.1 Fields and defaults

| Field | Default | Set by builder |
|---|---|---|
| title (display name) | empty component | `title` |
| icon (supplier of an item stack, evaluated lazily once and cached) | empty stack | `icon` |
| display items generator | does nothing | `displayItems` |
| can scroll | true | `noScrollBar` sets false |
| show title | true | `hideTitle` sets false |
| aligned right | false | `alignedRight` sets true |
| type | CATEGORY | `type` |
| background texture | the texture named `items` (below) | `backgroundTexture` |
| row, column | constructor arguments of the builder | none |

`createTextureLocation(name)` builds the identifier `minecraft:textures/gui/container/creative_inventory/tab_<name>.png`. The default background is `tab_items`; the inventory tab uses `tab_inventory`, the search tab `tab_item_search`. Each is a 256 x 256 PNG (header read).

`Type` has four values in this order: `CATEGORY`, `INVENTORY`, `HOTBAR`, `SEARCH`. `Row` has two: `TOP`, `BOTTOM`. The builder refuses (throws "Special tabs can't have display items") a tab of type HOTBAR or INVENTORY that has a display items generator other than the empty one.

Two content collections exist per tab, both insertion-ordered sets that identify a stack by item type plus component map (`ItemStackLinkedSet.createTypeAndComponentsSet`, so adding an equal stack twice keeps the first): the parent-tab list (`displayItems`, what the tab shows) and the search-tab list (`displayItemsSearchTab`, what the tab contributes to the search tab).

Derived rules:

| Query | Rule |
|---|---|
| `hasAnyItems` | the parent-tab list is not empty |
| `shouldDisplay` | true unless the type is CATEGORY and `hasAnyItems` is false. So the three special tabs are always displayed, and a CATEGORY tab disappears when it is empty. |
| `contains(stack)` | the search-tab list contains the stack (type and components) |

### 2.2 The registry order (14 tabs)

`CreativeModeTabs.bootstrap` registers the tabs in this order, which is the registry order and the order used for hit testing, drawing and listings. Resource key names are in the registry `creative_mode_tab`, namespace `minecraft`; the title strings are the translation keys with their `en_us` text.

| # | Key | Row | Col | Type | Right-aligned | Title key (en_us) | Icon stack | Background | Scrollbar | Title shown |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `building_blocks` | TOP | 0 | CATEGORY | no | `itemGroup.buildingBlocks` (Building Blocks) | bricks block | `tab_items` | yes | yes |
| 2 | `colored_blocks` | TOP | 1 | CATEGORY | no | `itemGroup.coloredBlocks` (Colored Blocks) | cyan wool | `tab_items` | yes | yes |
| 3 | `natural_blocks` | TOP | 2 | CATEGORY | no | `itemGroup.natural` (Natural Blocks) | grass block | `tab_items` | yes | yes |
| 4 | `functional_blocks` | TOP | 3 | CATEGORY | no | `itemGroup.functional` (Functional Blocks) | oak sign (item) | `tab_items` | yes | yes |
| 5 | `redstone_blocks` | TOP | 4 | CATEGORY | no | `itemGroup.redstone` (Redstone Blocks) | redstone (item) | `tab_items` | yes | yes |
| 6 | `hotbar` | TOP | 5 | HOTBAR | yes | `itemGroup.hotbar` (Saved Hotbars) | bookshelf | `tab_items` | yes | yes |
| 7 | `search` | TOP | 6 | SEARCH | yes | `itemGroup.search` (Search Items) | compass | `tab_item_search` | yes | yes |
| 8 | `tools_and_utilities` | BOTTOM | 0 | CATEGORY | no | `itemGroup.tools` (Tools & Utilities) | diamond pickaxe | `tab_items` | yes | yes |
| 9 | `combat` | BOTTOM | 1 | CATEGORY | no | `itemGroup.combat` (Combat) | netherite sword | `tab_items` | yes | yes |
| 10 | `food_and_drinks` | BOTTOM | 2 | CATEGORY | no | `itemGroup.foodAndDrink` (Food & Drinks) | golden apple | `tab_items` | yes | yes |
| 11 | `ingredients` | BOTTOM | 3 | CATEGORY | no | `itemGroup.ingredients` (Ingredients) | iron ingot | `tab_items` | yes | yes |
| 12 | `spawn_eggs` | BOTTOM | 4 | CATEGORY | no | `itemGroup.spawnEggs` (Spawn Eggs) | creeper spawn egg | `tab_items` | yes | yes |
| 13 | `op_blocks` | BOTTOM | 5 | CATEGORY | yes | `itemGroup.op` (Operator Utilities) | command block | `tab_items` | yes | yes |
| 14 | `inventory` | BOTTOM | 6 | INVENTORY | yes | `itemGroup.inventory` (Survival Inventory) | chest | `tab_inventory` | no | no |

Notes:

- Self-check: `CreativeModeTabs.validate` throws if two registered tabs with the same row and column have the same title string (a build-time self-check; the table above has none).
- The keys for the `lang` entries `itemGroup.consumables` and `itemGroup.crafting` also exist in `en_us.json` but no tab above uses them (inferred unused).
- The tab icon items are the ones named; the item registry entries are in 25. The icon is a stack of count 1 of the named item or block item, with no components.
- `tabs()` (the list the screen draws and tests) is the registry-order list filtered by `shouldDisplay`. `allTabs()` is the unfiltered registry-order list.

---

## 3. Tab layout on screen

### 3.1 Tab box and sprites

A tab sprite is 26 x 32 (`TAB_WIDTH`, `TAB_HEIGHT`; the sprite PNGs are 26 x 32, header read). Four sets of seven sprites exist under `minecraft:container/creative_inventory/`: `tab_top_unselected_1` to `_7`, `tab_top_selected_1` to `_7`, `tab_bottom_unselected_1` to `_7`, `tab_bottom_selected_1` to `_7`. The sprite used for a tab is index `clamp(column, 0, N)` where `N` is the length of the sprite array (7; read as `arraylength` fed to `Mth.clamp`, with no subtraction of 1). Columns only run 0 to 6, so the upper bound never takes effect and column 0 uses `_1`, in the set chosen by row (top or bottom) and by whether the tab is the selected tab.

The tab's left edge `tabX` (relative to `leftPos`) is:

- `27 x column` for a tab that is not right-aligned;
- `imageWidth - 27 x (7 - column) + 1` for a right-aligned tab, with `imageWidth` = 195.

The tab's top edge used for hit testing, `tabY` (relative to `topPos`), is -32 for the TOP row and `imageHeight` = 136 for the BOTTOM row.

The tab is drawn at screen x = `leftPos + tabX` and screen y = `topPos - 28` for the TOP row or `topPos + imageHeight - 4` = `topPos + 132` for the BOTTOM row, size 26 x 32. (This y differs from the hit-test `tabY` by 4: the hit box of a TOP tab spans y -32 to 0 and the drawn sprite spans y -28 to 4. The values are as read; see Open question 3.)

The tab icon item is drawn with its 16 x 16 cell at screen x = (drawn x) + 13 - 8 = (drawn x) + 5 and screen y = (drawn y) + 16 - 8 + 1 = (drawn y) + 9 for a TOP tab, (drawn y) + 16 - 8 - 1 = (drawn y) + 7 for a BOTTOM tab.

Resulting positions, all 14 tabs (x is `tabX`; drawn y is -28 for TOP and 132 for BOTTOM; hit y range is [-32, 0] and [136, 168]):

| Tab | tabX | Sprite index |
|---|---|---|
| building_blocks, tools_and_utilities | 0 | 1 |
| colored_blocks, combat | 27 | 2 |
| natural_blocks, food_and_drinks | 54 | 3 |
| functional_blocks, ingredients | 81 | 4 |
| redstone_blocks, spawn_eggs | 108 | 5 |
| hotbar, op_blocks | 142 | 6 |
| search, inventory | 169 | 7 |

(142 = 195 - 27 x 2 + 1 and 169 = 195 - 27 x 1 + 1.) At most 7 tabs per row; with 7 columns the right-most tab ends at x = 195.

### 3.2 Hit testing and hover

- `checkTabClicked(tab, x, y)`, with x and y relative to (`leftPos`, `topPos`): true when `tabX <= x <= tabX + 26` and `tabY <= y <= tabY + 32` (inclusive on both ends).
- Hover (`checkTabHovering`): the pointer is inside the box starting at (`tabX + 3`, `tabY + 3`) of size 21 x 27 using the generic `isHovering` (which widens the box by one pixel on the low side and one on the high side, 40-1 §5.5). When true, the tab's title is set as the tooltip for the next frame at the pointer, and the loop over tabs stops at the first match.
- Cursor: for an unselected tab whose drawn box (the 26 x 32 box at the drawn position) contains the pointer (strict inequalities on the low edge: pointer x greater than the left and y greater than the top, and less than right and bottom edges) the pointing-hand cursor is requested.

### 3.3 Selecting a tab

Pressing the left button on a tab only consumes the event (so nothing under it reacts). The tab is selected on mouse release: `mouseReleased` with the left button clears the scrolling flag, then tests every displayed tab in registry order and calls `selectTab` for the first hit, consuming the event. A release that hits no tab falls through to the generic release (40-1 §5.5).

`hasClickedOutside(px, py, left, top)` is the generic outside test (40-1 §5.5) combined with the tab rule: the click counts as "outside" (the field `hasClickedOutside` that later allows dropping the carried stack, section 7.5) only if the point is outside the image rectangle AND does not hit the currently selected tab's box (so clicking the tab strip never drops the carried item).

---

## 4. Content lists

### 4.1 Display parameters and the cache

`ItemDisplayParameters` is a record of three values: the enabled feature flag set, `hasPermissions` (section 1) and the registry lookup provider (`holders`). `needsUpdate(features, perms, holders)` is true when the feature set is not equal, the permission flag differs, or the provider is a different object (identity comparison).

`CreativeModeTabs.tryRebuildTabContents(features, perms, holders)`: if a cached parameters record exists and `needsUpdate` is false, return false (nothing to do). Otherwise store a new record, rebuild every tab (section 4.2), return true.

### 4.2 Building all tabs

`buildAllTabContents(parameters)` runs two passes over the registry-order tab list:

1. every tab of type CATEGORY is built;
2. every tab of any other type (HOTBAR, SEARCH, INVENTORY) is built.

This order matters because the search tab's generator reads the other tabs' search lists (section 4.4); CATEGORY tabs must be complete first. Building a tab (`buildContents`) runs the tab's generator with the parameters and an output object, then replaces the tab's two lists with the output's two lists. The output (`ItemDisplayBuilder`) is given each stack with a visibility:

| `TabVisibility` (ordinal) | Effect |
|---|---|
| `PARENT_AND_SEARCH_TABS` (0) | added to the parent list and to the search list |
| `PARENT_TAB_ONLY` (1) | added to the parent list only |
| `SEARCH_TAB_ONLY` (2) | added to the search list only |

Rules of the output object, in this order, for every stack offered:

1. The stack count must be exactly 1, otherwise the build throws ("Stack size must be exactly 1").
2. If the parent list already contains an equal stack (type and components) and the visibility is not `SEARCH_TAB_ONLY`, the build throws (a duplicate-entry check that names the stack and the tab). Duplicates in the search list are not checked (the set drops them).
3. The stack is added only if its item is enabled under the feature flag set (`Item.isEnabled(features)`); a disabled item is silently skipped (no error, rule 2 still ran first).
4. The visibility chooses which list receives it (table above).

Convenience forms used by the generators: `accept(item)` / `accept(stack)` use `PARENT_AND_SEARCH_TABS`; `accept(item, visibility)` wraps the item in a count-1 stack; `acceptAll(collection[, visibility])` offers each stack in iteration order.

### 4.3 Which items appear in which tab: the rule

Each CATEGORY tab's generator is a fixed list written in code (an explicit sequence of item and block-item references and a few generator helpers, section 4.4). The order in the tab is the order of that sequence, then de-duplicated by (type, components). The member lists and their order are not reproduced in this document (this part §4.6). The structural facts that are needed are:

- Every generator offers only count-1 stacks and the output refuses items that are disabled for the enabled features (rule 3 above), so a tab's content depends on the feature set from the connection (`ClientPacketListener.enabledFeatures`) and on whether the player has operator permission (only the `op_blocks` generator reads that flag; all others ignore it).
- The `hotbar` and `inventory` tabs have no generator and are always empty lists (their content is produced by the screen, sections 5 and 6.4).

### 4.4 Special generators (items that are not a plain item reference)

These helpers produce components-bearing stacks. Counts of generated stacks are read; the tab each belongs to was read from the call sites.

| Generator | Tab(s) | Produces | Visibility |
|---|---|---|---|
| presets of potions (`generatePotionEffectTypes`) for `potion`, `splash_potion`, `lingering_potion` | `food_and_drinks` | one stack of the item per potion type of the `potion` registry that is enabled under the feature set (`Potion.isEnabled`), with the potion contents component set to that potion (`PotionContents.createItemStack(item, potion)`), in registry iteration order (`listElements`), the three potion items in the order `potion`, `splash_potion`, `lingering_potion` | PARENT_AND_SEARCH_TABS |
| tipped arrows | `combat` | the same helper with `tipped_arrow` | PARENT_AND_SEARCH_TABS |
| suspicious stews | `food_and_drinks` | one `suspicious_stew` stack per suspicious effect holder (`SuspiciousEffectHolder.getAllEffectHolders` order, duplicates removed by (type, components)), with the suspicious stew effects component of that holder. In this tab the plain `milk_bucket` and `honey_bottle` items were seen after the stews, then the ominous bottles, then the three potion families (the reviewer's reading; the interleaving of these generated groups with the plain items elsewhere in the tab was not tabulated, Open question 1) | PARENT_AND_SEARCH_TABS |
| ominous bottles | `food_and_drinks` | `ominous_bottle` with the ominous bottle amplifier component for each amplifier 0, 1, 2, 3, 4 (5 stacks) | PARENT_AND_SEARCH_TABS |
| fireworks | `tools_and_utilities` and `combat` | `firework_rocket` with a fireworks component of an empty explosion list and flight duration d for each d in the item's craftable durations (the array `FireworkRocketItem.CRAFTABLE_DURATIONS`, a static initialiser of a 3-byte array whose three stores are 1, 2, 3 in that order, read) | PARENT_AND_SEARCH_TABS |
| goat horns | `tools_and_utilities` | for each instrument holder of the `goat_horns` instrument tag (set order of the tag), a `goat_horn` stack carrying that instrument (`InstrumentItem.create`) | PARENT_AND_SEARCH_TABS |
| enchanted books, max level | `ingredients` | one `enchanted_book` per enchantment of the enchantment registry (`listElements` order) with that enchantment at its maximum level (`EnchantmentHelper.createBook`) | PARENT_TAB_ONLY |
| enchanted books, all levels | `ingredients` | for each enchantment in registry order, for each level from its minimum to its maximum level inclusive, one `enchanted_book` | SEARCH_TAB_ONLY |
| coloured families | `colored_blocks`, `functional_blocks` | for a colour collection (wool, carpets, beds, banners, candles, concrete, glazed terracotta, glass, shulker boxes and so on, taken from `ColorCollection`), one item per dye colour in this fixed colour order: white, light_gray, gray, black, brown, red, orange, yellow, lime, green, cyan, light_blue, blue, purple, magenta, pink (16 colours; this colour order and the copper family order were not re-read in the review pass and have no cited method, so treat them as unverified, Open question 13) | PARENT_AND_SEARCH_TABS |
| copper families | `building_blocks`, `functional_blocks` | copper block families are offered through a weathering collection helper (`copperBlockFamilies`); the per-block order is in the item tables of 25 | PARENT_AND_SEARCH_TABS |
| placeable paintings | `functional_blocks` | the `painting` item with the painting variant component for each variant of the `painting_variant` registry that has the `placeable` tag, sorted by variant area ascending, then width ascending (a stable sort over the registry's `listElements` order for ties) | PARENT_AND_SEARCH_TABS |
| non-placeable paintings | `op_blocks` | the same but for variants without the `placeable` tag, same sort | PARENT_AND_SEARCH_TABS |

Only when the painting registry is present in the holder provider does the painting step run (it is guarded by an optional lookup).

The `op_blocks` generator produces nothing unless `hasPermissions` is true. When true it offers, in this order: `command_block`, `chain_command_block`, `repeating_command_block`, `command_block_minecart`, `jigsaw`, `structure_block`, `structure_void`, `barrier`, `debug_stick`, `test_instance_block`; then one `test_block` stack per `TestBlockMode` in declaration order (`start`, `log`, `fail`, `accept`) with the block-state-properties component `mode` set to that mode; then 16 `light` stacks for levels 15 down to 0 with the block-state-properties component `level` set (so the light block appears brightest first); then the non-placeable paintings. A tab of type CATEGORY with an empty list is not displayed (section 2.1), so without permission the `op_blocks` tab does not exist for the player.

The `spawn_eggs` generator begins with `spawner`, `trial_spawner`, `creaking_heart`, then the spawn eggs in a fixed code order (chicken first, then cow, pig, sheep, camel, donkey, horse, mule, cat, parrot, wolf, armadillo, bat, bee, fox, goat, llama, ocelot, panda, polar bear, rabbit, axolotl, cod, dolphin, frog, glow squid, nautilus, pufferfish, salmon, squid, tadpole, tropical fish, turtle, allay, mooshroom, sniffer, sulfur cube, and so on; the remaining entries are not listed here, section 4.6).

### 4.5 The search tab list and refresh

The `search` tab's generator offers, as one `acceptAll` with PARENT_AND_SEARCH_TABS, the union of the search lists of every tab in the registry whose type is not SEARCH, in registry order (the union is itself a (type, components) identity set, so the first occurrence of a stack keeps its position). Since the two-pass build (4.2) built the CATEGORY tabs first, and the HOTBAR and INVENTORY tabs have empty lists, the search tab list is the building blocks tab's search list, then colored, natural, functional, redstone, tools, combat, food, ingredients, spawn eggs, op (when permitted).

After a rebuild the screen refreshes the search trees (`tryRebuildTabContents` in the screen): if the session search trees exist, `updateCreativeTooltips(holders, copy of the search tab list)` and `updateCreativeTags(copy of the search tab list)` are called (section 8.2).

`tryRefreshInvalidatedTabs` (run by the constructor's first rebuild and every tick, section 1): if `tryRebuildTabContents` returned true, for each tab in `allTabs()`: take its parent list; if the tab is the selected tab then: when the type is CATEGORY and its list is empty, select the default tab; otherwise refresh the current tab contents with the list (section 6.5).

### 4.6 What this part leaves to other parts

The explicit per-item member sequences of the CATEGORY tabs (`building_blocks`, `colored_blocks`, `natural_blocks`, `functional_blocks`, `redstone_blocks`, `tools_and_utilities`, `combat`, `food_and_drinks`, `ingredients`, `spawn_eggs`, the plain part of `op_blocks`) are code-defined content (about 1,300 references in the generator methods). They are not tabulated in this round. The item documents 25-1 to 25-8 state creative-tab membership only for game-master items (they defer to this document, 25-4 Open question 8). Open question 1 asks for a follow-up round that tabulates the member order of each tab. Everything else an implementer needs to build the lists (visibility, de-duplication, feature filtering, permission rule, special generators) is above.

---

## 5. The item picker menu (`ItemPickerMenu`)

State: `items` (the list of stacks of the selected tab, a client list of any length), the inventory menu (the local player's `inventoryMenu`, container id 0), and the slot list.

### 5.1 Slots in tabs other than the survival inventory tab

The menu is constructed with 54 slots:

| Menu slot index | Container | Container slot | x | y | Class |
|---|---|---|---|---|---|
| 0 to 44 | the static 45-slot `SimpleContainer` (`CONTAINER`) | same as the index | `9 + 18 x col` | `18 + 18 x row` (col 0 to 8, row 0 to 4; index = `row x 9 + col`) | `CustomCreativeSlot` |
| 45 to 53 | the local player's `Inventory` | 0 to 8 (hotbar) | `9 + 18 x i` | 112 | plain `Slot` |

`CustomCreativeSlot.mayPickup(player)`: if the base rule allows pickup and the slot is not empty, then true only when the stack's item is enabled in the level's enabled features AND the stack has no `creative_slot_lock` component; otherwise the result is "the slot is empty". So empty slots are always pickable; non-empty slots are pickable unless locked or disabled.

Because the 45 grid slots all belong to one shared container (`CONTAINER`), each slot is "a view of `items[firstRow x 9 + index]`" after a scroll update (5.2). The items in the grid are the list's own stacks (not copies); the click rules (section 7) copy before changing.

### 5.2 Scrolling maths

| Quantity | Formula |
|---|---|
| `calculateRowCount` | `ceil(items.size / 9) - 5` (positive ceiling division; can be 0 or negative for short lists) |
| `canScroll` (menu) | `items.size > 45` |
| `getRowIndexForScroll(s)` | `max(0, (int)(s x rowCount + 0.5))`, with `s` a float: the product `s x rowCount` is computed in single precision (float times the row count converted to float); only that float product is widened to double for the addition of 0.5, then truncated and clamped at 0. i.e. rounding to nearest, half up. An implementation that multiplies in double can differ for products very close to a .5 boundary |
| `getScrollForRowIndex(r)` | `clamp(r / rowCount, 0, 1)` (float) |
| `subtractInputFromScroll(s, wheel)` | `clamp(s - wheel / rowCount, 0, 1)`, `wheel` a double |
| `scrollTo(s)` | `first = getRowIndexForScroll(s)`; for `row` 0 to 4 and `col` 0 to 8: `i = col + (row + first) x 9`; if `0 <= i < items.size` the container slot `col + row x 9` is set to `items[i]`, otherwise to the empty stack |

The screen's `canScroll` (used for the scrollbar and wheel) is the tab's can-scroll flag AND the menu's `canScroll`.

### 5.3 Other menu rules

- `stillValid` is always true.
- `canDragTo(slot)` and `canTakeItemForPickAll(stack, slot)` are true only for slots whose container is not `CONTAINER` (the 45 grid slots can be neither drag targets nor double-click collected).
- `quickMoveStack(player, index)`: for an index among the last 9 slots of the slot list (the hotbar slots 45 to 53 in this layout) that has an item, the slot is set empty by the player (`setByPlayer(EMPTY)`); the result is always the empty stack. So a shift-click on a hotbar slot through the menu deletes the item (in the survival tab the slot list is different, section 6.4, and the inventory menu's own quick-move applies).
- `getCarried` / `setCarried` read and write the carried stack of the player's inventory menu (there is one carried stack, shared).

---

## 6. The screen

### 6.1 Initialisation (`init`)

If the player lacks infinite materials, replace the screen with `InventoryScreen` and stop. Otherwise:

1. Generic init (computes `leftPos`, `topPos`, 40-1 §5.1).
2. Create the search box: an `EditBox` at (`leftPos + 82`, `topPos + 6`), width 80, height 9, narration text `itemGroup.search`; max length 50; no border; initially invisible; text colour -1 (opaque white, 0xFFFFFFFF); the inverted highlight text colour disabled. It is added as a widget.
3. Remember the previously selected tab, set `selectedTab` to the default tab, then `selectTab(previous)` (this rebuilds the menu for the previous tab).
4. Remove any previous `CreativeInventoryListener` from the local player's `inventoryMenu`, create a new one and add it (section 9.2).
5. If the selected tab is not displayed (`shouldDisplay` false), select the default tab.

`resize(w, h)` saves the current first row index and the search text, re-runs `init`, restores the search text, runs the search refresh if the text is non-empty, converts the saved row back to a scroll value and re-applies `scrollTo`.

### 6.2 Drawing order

`extractRenderState`: first the active effects panel (`EffectsInInventory`, the status-effect list to the left of the screen, the same helper the survival inventory screen uses; `showsActiveEffects` returns its `canSeeEffects`), then the generic container drawing (40-1 §5.2), then the tab tooltips (first hovered displayed tab only), then, if the selected tab is the survival inventory tab and the pointer is over the delete slot's 16 x 16 box (generic `isHovering`), the tooltip `inventory.binSlot` ("Destroy Item") at the pointer.

`extractBackground` (drawn inside the generic background step):

1. generic background (dimmed world);
2. every displayed tab except the selected tab: its tab button (3.1);
3. the selected tab's background texture blitted at (`leftPos`, `topPos`), size 195 x 136, from a 256 x 256 sheet, source origin (0, 0);
4. scrollbar cursor feedback: if the pointer is inside the scrollbar box (6.6): the resize north-south cursor when currently dragging and scroll is possible, the pointing-hand cursor when scroll is possible and not dragging, the not-allowed cursor when scroll is not possible;
5. the search box widget (it draws only when visible);
6. if the tab can scroll (tab flag): the scroller sprite at (`leftPos + 175`, `topPos + 18 + (int)(95 x scrollOffs)`), 12 x 15, using `scroller` when the screen can scroll and `scroller_disabled` otherwise (the 95 is `112 - 17`);
7. the selected tab's button (so it is drawn over the background edge);
8. for the survival inventory tab only: the player model preview, with its panel from (`leftPos + 73`, `topPos + 6`) to (`leftPos + 105`, `topPos + 49`), scale 20, offset factor 0.0625, following the pointer (`InventoryScreen.extractEntityInInventoryFollowsMouse`, shared with the survival inventory, 12 §5.6a).

### 6.3 Labels and text

`extractLabels` draws the selected tab's title only when the tab shows its title: at (8, 6), colour -12566464 (#404040), no shadow. The player inventory title of the generic screen is not drawn. The search tab has `showTitle` true, so "Search Items" is drawn at (8, 6) like any other title; the search box starts at x = 82, so the two do not overlap (inferred from the coordinates).

### 6.4 The survival inventory tab (type INVENTORY)

When the selected tab is the INVENTORY tab (`selectTab` step 4 below), the picker menu's slot list is replaced by wrappers over the 46 slots of the player's `InventoryMenu` (13 §3.5: 0 crafting result, 1 to 4 crafting grid, 5 to 8 armour, 9 to 35 main inventory, 36 to 44 hotbar, 45 off-hand). The original slot list is saved first and restored when the tab changes to anything else. Each wrapper is a slot over the same container and container slot as its target, delegating `mayPlace`, `mayPickup`, `getItem`, `set`, `remove`, `getMaxStackSize`, `isActive`, `onTake`, `setByPlayer`, `setChanged` and the empty-slot icon to the target, but with its own position:

| InventoryMenu slot | Wrapper x | Wrapper y |
|---|---|---|
| 0 to 4 (crafting result and grid) | -2000 | -2000 (off screen; effectively hidden) |
| 5 to 8 (armour), with `k = index - 5` | `54 + (k / 2) x 54` (integer division: k 0 and 1 give 54, k 2 and 3 give 108) | `6 + (k mod 2) x 27` (k even 6, k odd 33) |
| 9 to 35 (main), with `j = index - 9`, `row = j / 9`, `col = j mod 9` | `9 + 18 x col` | `54 + 18 x row` |
| 36 to 44 (hotbar), `col = (index - 9) mod 9` | `9 + 18 x col` | 112 |
| 45 (off-hand) | 35 | 20 |

The wrapper's menu slot index equals its position in the new list, so the list index equals the InventoryMenu index (0 to 45). After the 46 wrappers, one extra plain slot is appended: the delete (destroy) slot, container `CONTAINER` container slot 0, at (173, 112). The survival tab therefore has 47 slots. The scrollbar is absent in this tab (`noScrollBar`), and the title is hidden.

These positions are the ones read from this class; the survival `InventoryScreen` has its own layout (13 §3.5) and is not compared here.

### 6.5 `selectTab(tab)`

1. Remember the old tab, set `selectedTab` to the new tab, clear the drag slot set (`quickCraftSlots`), clear the picker's `items`.
2. If the type is HOTBAR: for each of the 9 saved hotbars `h` (0 to 8, from `HotbarManager.get(h)`, this part §10): if the hotbar is empty, add 9 entries: for `j` 0 to 8, entry `j` is a `paper` stack with `creative_slot_lock` set and the item name component set to the translation `inventory.hotbarInfo` ("Save hotbar with %1$s + %2$s") with arguments (the translated key name of the save-hotbar activator key, the translated key name of the hot bar key `h`) when `j == h`, and the empty stack otherwise. If the hotbar has content, add its 9 loaded stacks. (So the list always has 81 entries, 9 per hotbar, and the tab scrolls 4 rows.)
3. Otherwise if the type is CATEGORY: `items` = a copy of the tab's parent list.
4. If the new type is INVENTORY: save the original slot list the first time, replace the slot list with the 47 slots of 6.4.
5. Otherwise, if the OLD tab was INVENTORY: clear the slot list and restore the saved original list; forget it.
6. If the new type is SEARCH: make the search box visible, not able to lose focus, focused; if the new tab is not the same as the old one clear the text; then `refreshSearchResults` (8.1).
   Otherwise: hide the box, let it lose focus, unfocus it, clear its text.
7. Reset `scrollOffs` to 0 and `scrollTo(0)`.

`refreshCurrentTabContents(list)` (after a content rebuild): keep the current first row, clear `items`; if the selected tab is SEARCH run `refreshSearchResults`, otherwise add all of `list`; convert the first row back to a scroll value, store it, and `scrollTo`.

### 6.6 The scrollbar

| Item | Value |
|---|---|
| Box (hit test `insideScrollbar(px, py)`, absolute pointer coordinates) | `leftPos + 175 <= px < leftPos + 189` and `topPos + 18 <= py < topPos + 130` (14 x 112) and the tab's can-scroll flag |
| Scroller sprite | 12 x 15 at (`leftPos + 175`, `topPos + 18 + (int)(95 x scroll)`) |
| Press (left button) inside the box | set `scrolling` to the screen's `canScroll`; consume the event |
| Drag (`mouseDragged`, while `scrolling`) | `scroll = clamp((pointerY - (topPos + 18) - 7.5) / (112 - 15), 0, 1)` then `scrollTo(scroll)`; consume |
| Release (left button) | `scrolling` = false |
| Wheel (`mouseScrolled`) | the generic handler first; if it did not consume and the screen can scroll: `scroll = subtractInputFromScroll(scroll, wheelY)` (5.2), `scrollTo(scroll)`, consume; one wheel notch moves `wheelY / rowCount`, so a wheel value of 1 scrolls one row of a list with `rowCount` rows |

(The sprite travels over 95 pixels and the drag maths divide by 97; the two constants are as read.)

---

## 7. Slot click rules (`slotClicked`)

Inputs: `slot` (may be none), `slotId` (the generic target index: -999 outside, -1 none), `button`, `input` (a `ContainerInput`, 40-1 §3.4). The generic mouse code (40-1 §5.5) calls this method for every click, drag step, key action; the creative rules below replace the server round trip (the server has no creative picker menu).

### 7.1 Pre-processing (in order)

1. If the slot is one of the 45 grid slots, move the search box cursor to the end and clear its selection highlight.
2. `quick` = (input is `QUICK_MOVE`).
3. If `slotId == -999` and the input is `PICKUP`, the input becomes `THROW` (an outside click throws).
4. If the input is `THROW` and the local player cannot drop items (`canDropItems`: the drop spam throttler is under its threshold, section 9.3), return.
5. Run the generic mouse-action hook (bundle behaviour, 40-1 §3.4).
6. Outside rule: if the slot is none AND the selected tab is not INVENTORY AND the input is not `QUICK_CRAFT`, go to 7.5 (the outside click handler) and nothing else.
7. If a slot exists and `mayPickup(player)` is false, return.
8. Delete-all: if the slot is the delete slot and `quick` is true (shift-click on it): for every index `i` from 0 to 45 of the player's `InventoryMenu`: set the slot to the empty stack and send a creative set-slot (9.1) with the empty stack and slot `i`. Done.

### 7.2 Survival inventory tab (type INVENTORY)

- Click on the delete slot (any input but the shift-click of rule 8): set the carried stack to the empty stack.
- `THROW` on a wrapper slot with an item: remove `1` item if the button is 0, else the full max stack size of the slot's stack (a count taken from the slot, capped by what it holds); drop the taken stack (`player.drop(stack, true, PREDICTED)`); send a creative drop (9.1, slot -1 rule through `handleCreativeModeItemDrop`); then send a creative set-slot for the slot's target index with the slot's remaining stack.
- `THROW` outside (slotId -999 after pre-processing) with a non-empty carried stack: drop the carried stack, send the creative drop, empty the carried stack.
- Anything else: forward to the player's `InventoryMenu`: `clicked(target index, button, input, player)` where the target index is the wrapper's `target.index` (or `slotId` when no slot), then `inventoryMenu.broadcastChanges()`. The standard menu rules (40-1 §3.4, 13 §3.5) apply to the inventory menu, and every changed slot reaches the server through the listener (9.2).

### 7.3 Other tabs: clicks on the 45 grid slots

(`input` is not `QUICK_CRAFT` and the slot belongs to `CONTAINER`.) `C` is the carried stack, `S` the grid slot's stack (count 1 as generated, but any count is handled).

| Input | Rule |
|---|---|
| `SWAP` (button 0 to 8 is a hotbar index, 40 is the off-hand) | if `S` is not empty: set the player's inventory slot `button` to `S` with its count raised to its max stack size (a copy), then `inventoryMenu.broadcastChanges()` (the listener sends the packet). Nothing else changes (the carried stack is not touched). |
| `CLONE` (middle button) | if `C` is empty and `S` is not: `C` = copy of `S` with count = its max stack size. |
| `THROW` | if `S` is not empty: copy of `S` with count 1 (button 0) or its max stack size (button not 0); drop it and send the creative drop. The grid stack itself is unchanged. |
| anything else (PICKUP, QUICK_MOVE, PICKUP_ALL), with the button 0 (left) or other (right) | see the case table below |

Case table (all rows use copies; "same" means same item and same component map, `isSameItemSameComponents`):

| `C` | `S` | Button | `quick` | Result |
|---|---|---|---|---|
| not empty | not empty, same | 0 | yes | `C.count` = `C` max stack size |
| not empty | not empty, same | 0 | no | `C.count` + 1 if `C.count` is below its max stack size, else unchanged |
| not empty | not empty, same | not 0 | any | `C.count` - 1 (becomes empty when it reaches 0) |
| any | empty | 0 | any | `C` = empty (the carried stack is deleted) |
| any | empty | not 0 | any | if `C` is not empty, `C.count` - 1 |
| not empty | not empty, different | 0 | any | `C` = empty |
| not empty | not empty, different | not 0 | any | `C.count` - 1 |
| empty | not empty | any | yes | `C` = copy of `S` with count = its max stack size |
| empty | not empty | any | no | `C` = copy of `S` with count `S.count` |

No packet is sent for a grid click (the carried stack lives only on the client until it is placed). Placing happens through the hotbar slots (7.4) or the survival tab.

### 7.4 Other tabs: clicks on the nine hotbar slots, and drags

(`input` is `QUICK_CRAFT` or the slot is not in `CONTAINER`, including slotId -1 and -999 for a drag.) The click is run on the picker menu itself: `menu.clicked(slot index or slotId, button, input, player)` with the generic rules of 40-1 §3.4 (the picker menu's slots 45 to 53 are the hotbar; `quickMoveStack` is the delete rule of 5.3; `canDragTo` excludes the grid). Afterwards:

1. If the drag header of `button` is 2 (the end of a drag), for `i` 0 to 8 send a creative set-slot with the stack in picker slot `45 + i` and slot index `36 + i`.
2. Otherwise, if a slot exists, it is a hotbar container slot (`Inventory.isHotbarSlot(containerSlot)`, 0 to 8) and the tab is not INVENTORY:
   - if the input is `THROW` and the stack read before the click (from the picker slot) is not empty and the carried stack is not empty: count = `1` if the button is 0 else the stack's count; copy that many, shrink the stack by that count, drop the copy, send the creative drop;
   - then `inventoryMenu.broadcastChanges()`; the listener sends every changed inventory slot (9.2).

### 7.5 Clicking outside the image

(Slot is none, tab not INVENTORY, not a drag step.) Only when the carried stack is not empty AND the field `hasClickedOutside` (section 3.3) is true: if the player cannot drop items, return. Button 0: drop the whole carried stack (`player.drop(carried, true, PREDICTED)`), send the creative drop, empty the carried stack. Button 1: split one item from the carried stack, drop it, send the creative drop for that one item. Any other button does nothing.

### 7.6 Keys

- In every tab except SEARCH, the chat key sets `ignoreTextInput` (so the key press is not typed into the box that is about to appear), selects the search tab and consumes the key. Other keys go to the generic handler.
- In the SEARCH tab: let `flag` = the hovered slot is not a grid slot, or it has an item. If `flag` and the key is a digit key (`getNumericKeyValue` present) and `checkHotbarKeyPressed` (40-1 §5.5: hotbar key `i` sends SWAP with button `i` for the hovered slot, the off-hand key sends SWAP with button 40; needs a hovered slot and an empty carried stack) handles it: set `ignoreTextInput`, consume. Otherwise the search box gets the key; if it consumed it, and the text changed, run `refreshSearchResults`; consume. Otherwise, if the box captures input and the key is not Escape, consume. Otherwise the generic handler (which closes on the inventory key or Escape).
- `charTyped`: ignored when `ignoreTextInput` or the tab is not SEARCH; else the search box gets it, and a change in the text runs `refreshSearchResults`. `preeditUpdated` (IME) is forwarded to the box in the same conditions. `keyReleased` clears `ignoreTextInput`. `isInputCaptured` is the generic value or the box capturing input.

---

## 8. The search tab

### 8.1 `refreshSearchResults`

Triggered by the text changing (7.6), by entering the tab (6.5) and after content rebuild (6.5).

1. Clear the picker's `items` and the set of visible tags.
2. Let `q` = the box text. If `q` is empty: `items` = the search tab's parent list (the whole union of 4.5).
3. Otherwise (needs a connection; without one the list stays empty): if `q` starts with `#` take the rest after the `#` as `q`, use the TAG search tree and call `updateVisibleTags(q)`; else use the NAME search tree. `items` = the tree's results for the lower-cased query (`toLowerCase(Locale.ROOT)`).
4. `scrollOffs` = 0 and `scrollTo(0)`.

`updateVisibleTags(q)` (the text, not lower-cased, case-sensitive substring tests): if `q` contains no colon, a tag identifier `ns:path` is selected when its path contains `q`; if it contains a colon, split at the first colon into `a` and `b` (each trimmed) and the tag is selected when its namespace contains `a` AND its path contains `b`. The candidate tags are all tags of the item registry (`BuiltInRegistries.ITEM.getTags()`). The selected tags are kept (a set) and used for the tooltip (8.3).

### 8.2 The two search trees (`SessionSearchTrees`)

Both are built in the background (a completed future; an empty tree until built) from the search tab's list whenever `updateCreativeTooltips` and `updateCreativeTags` are called (section 4.5) and again after a language change.

| Tree | Class | Text indexed per stack | Identifier indexed per stack |
|---|---|---|---|
| name search | `FullTextSearchTree` | the stack's tooltip lines with the NORMAL tooltip flag set to the creative variant (`TooltipFlag.Default.NORMAL.asCreative()`) and no player: each line's plain string, formatting codes stripped (`ChatFormatting.stripFormatting`), trimmed, empty ones dropped, then lower-cased (root locale) | the item's registry key (namespace and path) |
| tag search | `IdSearchTree` | none | every tag (`ItemStack.tags()`) of the stack's item, as its identifier (namespace and path) |

Query handling (`IdSearchTree.search` and the `FullTextSearchTree` override):

1. If the query has no colon: the name tree returns the text matches (substring of any indexed line); the tag tree returns the matches over the tag path.
2. If the query has a colon: split at the first colon into `ns` and `path`, each trimmed. The tag tree returns the stacks whose tags have a namespace containing `ns` AND a path containing `path` (an intersection of two result lists). The name tree returns the intersection of (namespace matches of `ns`) with the unique union of (path matches of `path`) and (text matches of `path`), merged by addition order.
3. Matching is a substring search over a suffix array of the lower-cased strings. The result of one search is the set of matching entries ordered by the order in which entries were added, de-duplicated (a stack matched through several lines appears once, at its first position). Entries are added in the order of the input list (the search tab list), so results keep the search tab's order. There is no relevance ranking. The entry's ordering key is the insertion index of the (stack, string) pair, not a name sort.

Worked behaviour: typing `iron` lists every item with "iron" in a tooltip line (including tooltip lines of items whose lore or enchantment text contains it) in search-tab order; typing `minecraft:lea` lists items whose namespace contains `minecraft` and whose path contains `lea` or whose tooltip text contains `lea`; typing `#logs` lists the items that have a tag whose path contains `logs`.

### 8.3 Tooltips in this screen (`getTooltipFromContainerItem`)

For a hovered stack: the flag set is the advanced one when the client option `advancedItemTooltips` is on, the normal one otherwise; when the hovered slot is a grid slot (a `CustomCreativeSlot`) the creative variant is used. The lines are the stack's tooltip lines with the player and a level-based context. If the list is empty it is returned. If the selected tab is a CATEGORY tab and the slot is a grid slot, the lines are returned unchanged. Otherwise (search tab, or a non-grid slot such as the hotbar or survival slots in any tab): a copy of the lines is made; in the SEARCH tab with a grid slot, for each visible tag (8.1) the stack's item belongs to, a line `#<tag id>` in dark purple is inserted at line index 1; then for each displayed tab that is not the SEARCH tab and whose search list contains the stack, the tab's title in blue is inserted at index 1, 2, ... (so the tab names come before the tag lines).

---

## 9. Packets and listener

### 9.1 Set Creative Mode Slot (05c 0x39)

`MultiPlayerGameMode.handleCreativeModeItemAdd(stack, slot)`: sends Set Creative Mode Slot only when the local player has infinite materials AND the stack's item has all its required feature flags enabled on the connection (`isFeatureEnabled(item.requiredFeatures())`). The packet carries the slot (as an int in the constructor, a short on the wire, 05c) and the stack (optional item stack, 00).

`handleCreativeModeItemDrop(stack)`: let `inContainerScreen` = the current screen is a container screen that is not the creative screen. Sends Set Creative Mode Slot with slot -1 and the stack when the player has infinite materials AND not `inContainerScreen` AND the stack is not empty AND the item's required features are enabled; after sending, the local drop throttler is incremented (9.3). The creative screen itself therefore sends drops; other container screens do not.

Slot numbers sent by the creative screen are `InventoryMenu` slot indices (13 §3.5): hotbar 36 to 44, main 9 to 35, armour 5 to 8, off-hand 45, 0 to 4 the crafting area; the delete-all sends slots 0 to 45 with the empty stack.

Server rule (`ServerGamePacketListenerImpl.handleSetCreativeModeSlot`), run on the server thread: ignored unless the player has infinite materials. Let `slot` be the packet's short (negative for a drop). If the stack's item is not enabled for the level's enabled features, ignore the packet. `validSlot` = `1 <= slot <= 45`; `validStack` = the stack is empty or its count is at most its max stack size. If `validSlot` and `validStack`: set the player's `inventoryMenu` slot `slot` to the stack as if by the player (`setByPlayer`), set the menu's remote slot memory for `slot` to the stack (so the next broadcast does not echo it back), and `broadcastChanges`. Else if `slot < 0` and `validStack`: if the server's drop-spam throttler is under its threshold, increment it and drop the stack from the player (`drop(stack, true, PREDICTED)`; an empty stack drops nothing, inferred); otherwise log "Player {} was dropping items too fast in creative mode, ignoring." and ignore. Slot 0 (crafting result) and slots above 45 are ignored. This is the whole server side: no creative menu exists on the server.

### 9.2 `CreativeInventoryListener`

A `ContainerListener` registered on the local player's `inventoryMenu` while the creative screen is open (added in `init`, removed in `removed` and on re-init). `slotChanged(menu, slotIndex, stack)` calls `handleCreativeModeItemAdd(stack, slotIndex)`; `dataChanged` does nothing. This is how every change of the player's inventory (done locally by the menu click rules in 7.2 and 7.4, by `SWAP` in 7.3 and by the hotbar load in this part §10) becomes a Set Creative Mode Slot packet when `broadcastChanges` runs.

### 9.3 Drop throttlers

Both sides use `TickThrottler(step, threshold)` with `step` 20: the client's local player has threshold 1280, the server's packet handler has three throttlers created in its constructor, all with step 20: `dropSpamThrottler` threshold 1480 (the one the creative drop rule of 9.1 reads and increments, read by field name), `commandSpamThrottler` threshold 20 and `chatSpamThrottler` threshold 20 (these two serve command and chat spam detection, not drops). `increment` adds `step` to a counter; `tick` subtracts 1 per tick while the counter is positive (call sites read: the local player's tick method calls the client's drop throttler's `tick` once per tick; the server packet handler's tick method calls `tick` on the chat, command and drop throttlers once each per tick); `isUnderThreshold` is true when the threshold is not positive or the counter is below it. So the server allows 74 creative drops in a burst (74 x 20 = 1480 is not below the threshold), the client 64.

---

## 10. The saved hotbars (`HotbarManager`, `Hotbar`)

| Item | Value |
|---|---|
| Count | 9 hotbars (`NUM_HOTBAR_GROUPS`), index 0 to 8, matching the hotbar keys 1 to 9 |
| File | `hotbar.nbt` in the folder given to the manager (the game directory, inferred from the constructor argument); NBT written by `NbtIo.write(compound, path)` and read by `NbtIo.read(path)` (compression not traced, Open question 7) |
| File layout | a compound with the current data version (`DataVersion` int) and entries named `"0"` to `"8"`, each the codec encoding of a hotbar: a list of nine item stack encodings (the optional item stack codec, so an empty slot is the empty stack's encoding), validated to the hotbar size (9) |
| Loading | lazily on the first `get`; a missing file keeps nine empty hotbars; the stored data version defaults to 1343 when absent, then the data fixer for the hotbar type brings the compound to the current version; an entry that fails to parse is replaced by an empty hotbar and a warning "Failed to parse hotbar: {}" is logged; any exception logs "Failed to load creative mode options" |
| Saving | writes the whole file after each save; an exception logs "Failed to save creative mode options" |
| `Hotbar.isEmpty` | every stored entry equals the empty stack encoding |
| `Hotbar.storeFrom(inventory, registryAccess)` | for slot 0 to 8, encodes the stack with the serialization context, an encoding failure logs "Could not encode hotbar item: {}" and stores the empty encoding |
| `Hotbar.load(provider)` | decodes each entry with the registry context injected; a failure stores the empty stack |

Key use (`Minecraft`, in the hotbar key handling of every tick): for each hotbar key `i` (0 to 8) that was pressed: spectators go to the spectator hotbar; if the player has infinite materials AND no screen is open AND at least one of the load-hotbar and save-hotbar activator keys is down: `handleHotbarLoadOrSave(i, load = loadActivatorDown, save = saveActivatorDown)`; otherwise the selected hotbar slot becomes `i`. The default keys are C for save and X for load (13 §7 lists `key.saveToolbarActivator` and `key.loadToolbarActivator`).

`handleHotbarLoadOrSave(minecraft, i, load, save)`:

1. If `load`: take the saved hotbar `i`'s nine stacks; for `j` 0 to 8 set the player's inventory slot `j` to stack `j` and send a creative set-slot with that stack and slot `36 + j`; then `inventoryMenu.broadcastChanges()` (the listener may also send; at most one extra echo, the server accepts both).
2. Else if `save`: store the player's nine hotbar stacks into hotbar `i`, build the message `inventory.hotbarSaved` ("Item hotbar saved (restore with %1$s + %2$s)") with the translated key names of the load activator and of hotbar key `i`, show it as the overlay (action bar) message with no animation, speak it through the narrator, and save the file.
3. If both `load` and `save` are true, load wins (the first branch).

The saved hotbars tab (6.5 step 2) reads these hotbars when it is selected; it is not refreshed while it stays selected.

---

## 11. Worked examples

All use GUI scale 1 unless stated.

**11.1 Geometry.** Window 854 x 480: `leftPos` = (854 - 195) / 2 = 329, `topPos` = (480 - 136) / 2 = 172. Search tab: `tabX` = 195 - 27 + 1 = 169, drawn at (498, 144), sprite `tab_top_selected_7` or `tab_top_unselected_7`; its icon (compass) is drawn at (503, 153). Inventory tab: drawn at (498, 304), icon (chest) at (503, 311). Tools tab: drawn at (329, 304), sprite `tab_bottom_..._1`, icon (diamond pickaxe) at (334, 311). The scrollbar box is x 504 to 517, y 190 to 301 (absolute). Grid slot (row 2, col 3) has its item cell at (329 + 9 + 54, 172 + 18 + 36) = (392, 226). Hotbar slot 8 at (329 + 9 + 144, 172 + 112) = (482, 284). The delete slot (survival tab) at (502, 284).

**11.2 Scroll.** A search list of 100 stacks: rows = ceil(100/9) = 12, `rowCount` = 12 - 5 = 7. Scroll 0.5 gives first row = (int)(0.5 x 7 + 0.5) = 4, so grid slot 0 shows `items[36]` and slot 44 shows `items[80]`. Scroll 0.07 gives (int)(0.49 + 0.5) = 0. Scroll 1.0 gives 7: slot 0 shows `items[63]` and slots with index above 99 (`items[100]` onward) are empty. Scroller sprite y at scroll 0.5: 190 + (int)(95 x 0.5) = 237. Dragging with the pointer at y = 246: (246 - 190 - 7.5) / 97 = 0.5. A wheel step of +1 at scroll 0.5 gives 0.5 - 1/7 = 0.357143, first row (int)(0.357143 x 7 + 0.5) = (int)3.0 = 3.

**11.3 A list of 45 or fewer.** 45 stacks: `canScroll` false (45 is not greater than 45), the scroller sprite is the disabled one, the not-allowed cursor shows over the bar, and the wheel does nothing. 46 stacks: rows = 6, `rowCount` = 1, scrolling moves one row.

**11.4 Picking up and placing.** Building blocks tab, left click on a stone slot: `C` is empty, `S` = stone x1, no shift: `C` = stone x1. Left click again on the same slot: same stack, button 0, no shift: `C` = stone x2. Shift-left-click on the slot while `C` is empty: `C` = stone x64. Right-click on any stone slot with `C` = stone x5: `C` = stone x4. Left-click on an empty grid slot with a carried stack: `C` is deleted. Left click on a hotbar slot 3 with `C` = stone x64 and the slot empty: handled by the picker menu's generic PICKUP (the whole stack goes in), then the listener sends Set Creative Mode Slot (slot 39, stone x64) when `broadcastChanges` runs.

**11.5 Swap key.** Hover a diamond sword slot in the grid and press 4: SWAP with button 3: the player's inventory slot 3 becomes a diamond sword x1 (its max stack size is 1), and a packet (slot 39, diamond sword) is sent. A stack of 64 stone instead gives stone x64.

**11.6 Delete and delete-all.** In the survival tab with a carried apple: left-click on the delete slot: the carried stack becomes empty (no packet: the carried stack is client only). Shift-click on the delete slot: all 46 inventory menu slots are set empty and 46 packets are sent (slots 0 to 45, empty stacks); the server ignores slot 0 and applies slots 1 to 45.

**11.7 Drop.** Carried stone x64, left click outside the image (not on the selected tab): `hasClickedOutside` is true, the input became `THROW`: the whole stack is dropped and Set Creative Mode Slot (-1, stone x64) is sent; the carried stack is empty. Right click outside: one stone x1 dropped (packet with count 1). 75 drops in the same tick-burst: the server's throttler reaches 1480 after the 74th and the 75th is logged and ignored.

**11.8 Search.** Search list = [..., `oak_log`, `oak_planks`, `iron_ingot`, ...]. Query `oak`: matches by tooltip text ("Oak Log", "Oak Planks") and by item path; results in list order: `oak_log`, `oak_planks`. Query `#minecraft:logs`: the colon splits into namespace `minecraft` and path `logs`: items having a tag whose namespace contains `minecraft` and whose path contains `logs` (for example the `logs` tag and `logs_that_burn`), tooltip lines of such items list the tags (`#minecraft:logs`) at line 1 onwards, after the names of the tabs that contain the item.

**11.9 Operator tab.** A creative player without game-master permission, option `operatorItemsTab` on: `hasPermissions` false, the `op_blocks` list is empty, the tab is not in `tabs()`, so the bottom row shows 6 tabs (tools, combat, food, ingredients, spawn eggs at x 0 to 108, inventory at 169). With permission: 7 tabs, `op_blocks` at 142. If the player loses permission while the tab is selected, the next tick's refresh sees an empty CATEGORY list and selects `building_blocks`.

**11.10 Saved hotbar.** Hotbar 3 saved empty; hotbar tab opened: entry 3 of hotbar 3's row (list index 3 x 9 + 3 = 30) is a paper with the tooltip name "Save hotbar with C + 4" (default keys; the key names are the translated key messages), and the other 80 entries are empty slots. Press C + 4 with no screen open: hotbar 3 stores the nine hotbar stacks, the message "Item hotbar saved (restore with X + 4)" is shown, `hotbar.nbt` is written.

---

## 12. Validation

An implementation can check:

1. The tab list has 14 registered tabs in the order of 2.2, the TOP row has columns 0 to 6 (7 tabs), the BOTTOM row has columns 0 to 6 (7 tabs). `tabs()` has 14 tabs with the operator tab, else 13, and the three special tabs are always present.
2. Positions: for every tab the hit box is 26 x 32; the 14 `tabX` values are 0, 27, 54, 81, 108, 142, 169 for each row.
3. `ItemPickerMenu` has 54 slots outside the survival tab (indices 0 to 44 grid at `9 + 18 col`, `18 + 18 row`; 45 to 53 at `9 + 18 i`, 112) and 47 slots in the survival tab (46 wrappers + the delete slot at (173, 112)).
4. Wrapper positions in the survival tab: slot 5 at (54, 6), 6 at (54, 33), 7 at (108, 6), 8 at (108, 33), 9 at (9, 54), 35 at (153, 90), 36 at (9, 112), 44 at (153, 112), 45 at (35, 20), 0 to 4 off screen.
5. `getRowIndexForScroll`: (rowCount, scroll) = (7, 0.5) gives 4; (7, 0.07) gives 0; (7, 0.0715) gives 1 (0.5005 + 0.5 = 1.0005, truncated to 1). `canScroll` is false for 45 and true for 46.
6. Search lower-casing uses the root locale, so locale-specific case rules (a Turkish locale) must not change results.
7. Click table 7.3: the nine rows reproduce exactly the listed results; no packet is sent for a grid click; the hotbar-slot click sends a packet through the listener only after `broadcastChanges`.
8. Server rule: slot 0, slot 46 and above, and a stack of count above its max stack size are ignored; a drop with slot -1 is subject to the 74-burst throttle; an unknown (feature-disabled) item is ignored.
9. The default selected tab is `building_blocks` and persists between opens within one run; after a feature or permission change the selected CATEGORY tab falls back to `building_blocks` when it becomes empty.
10. The special generators produce: 5 ominous bottle stacks (amplifier 0 to 4); 16 light stacks (levels 15 to 0) and 4 test block stacks (`start`, `log`, `fail`, `accept`) in `op_blocks` when permitted; 81 entries in the hotbar tab.

---

## 13. Open questions

1. Per-tab member lists and their order are not tabulated (this part §4.6). They are code-defined content of `CreativeModeTabs` (about 1,300 item references plus the colour and copper family helpers). A follow-up round should tabulate them by tab in generator order, mark which are PARENT_TAB_ONLY or SEARCH_TAB_ONLY, and read the colour collection and weathering collection member orders. The item registry parts 25-1 to 25-8 do not carry tab membership.
2. The left-button number: the creative screen compares the mouse button number against the constant 1 in `mouseClicked`, `mouseReleased` and the generic widget check; 40-1 §5.5 states the left button is 1 in this version's numbering. This document relies on that statement and did not re-read `InputConstants`.
3. The vertical mismatch between the hit box of a tab (`tabY` -32 or 136) and the drawn sprite (-28 or 132, 4 pixels apart) and between the scrollbar sprite travel (95) and the drag divisor (97) are as read; whether the offsets are intentional was not determined, and the document gives both numbers.
4. (Closed in the fixer pass: the firework craftable durations array was read as 1, 2, 3.)
5. `ItemStack.getTooltipLines` content (the lines the name search indexes and the tooltip shows) is not specified here; it belongs with items (25) and the tooltip engine (12 §5.8). The advanced tooltip lines are also not covered.
6. `ChatFormatting.stripFormatting` was not read; it is inferred to remove section-sign formatting codes.
7. `NbtIo.read(Path)` and `NbtIo.write(compound, Path)` were not checked for compression, so whether `hotbar.nbt` is gzip-compressed is unknown. The data fixer type for the hotbar was not read (the stored data version defaults to 1343).
8. `TickThrottler.tick` call sites were read: once per tick for the client's drop throttler, and once each for the server's chat, command and drop throttlers. `LocalPlayer.drop` and `ServerPlayer.drop` were not read (what happens with an empty stack, the drop position and velocity, the pickup delay): see 41 and 17.
9. `Item.requiredFeatures` and `FeatureFlags` (which items need which flag, which flags a vanilla server enables) were not read; the enabled feature set arrives from the server (03, Update Enabled Features).
10. The player preview drawing (`InventoryScreen.extractEntityInInventoryFollowsMouse`) internals and `EffectsInInventory` layout were not read here (they are shared with the survival inventory screen, 12 §5.6a).
11. The suffix array matcher was read for its result ordering (sorted by insertion index, de-duplicated) but its sentinel and bounds handling in the binary search was not traced; the behaviour is documented as plain case-insensitive substring matching (inferred). Behaviour with a query longer than any indexed string is therefore inferred to return nothing.
12. The tag set iteration order used for the `#tag` tooltip lines is a hash set, so the order of those lines is unspecified; implementations may sort.
13. `CreativeModeTabs.copperBlockFamilies` and the colour collection helpers were identified but not enumerated (Open question 1); the 16-colour order of section 4.4 and the copper family order were not re-verified in the review pass.
14. The trigger of the second construction path of the creative screen inside `InventoryScreen` (section 1) was not traced; and whether a game mode change (Game Event 3, 05a) closes an open screen was not read.
15. Scope gap (GAP-19): the member lists and order of the 10 CATEGORY tabs, the plain part of `op_blocks`, the colour collection order, the weathering/copper collection order and the complete spawn-egg sequence (section 4.4 stops at 'and so on') are not tabulated; see question 1. A follow-up round must tabulate each tab in generator order with visibility before the search tab order can be built from these documents alone.
16. Coverage of the other menu screens (chests, hopper, furnaces, brewing stand, enchanting table, anvil, grindstone, smithing table, loom, stonecutter, cartography table, beacon, merchant, lectern, horse/llama, shulker box, crafter, book and quill, sign editing, command block, structure block) belongs to parts 40-1 to 40-6, which this document does not cover and this pass did not review; the orchestrator must confirm each is covered there. The `EffectsInInventory` layout stays open (question 10).
17. The English titles of section 2.2 were not re-checked against `en_us.json` in the review pass; the game-master permission level (section 1) and the unused `itemGroup.consumables` / `itemGroup.crafting` keys are inferred; section 2.2 and 6.3 inferences stay marked. The compression of `hotbar.nbt` and the hotbar data fixer remain unread (question 7). The tab-internal order of the generated groups (potions, stews, ominous bottles, milk and honey) relative to plain items in `food_and_drinks` was not tabulated (question 1).
