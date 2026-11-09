# 40-2 Menus, part 2: furnaces, brewing stand and crafter

| Item | Value |
|---|---|
| Covers | The processing menus with data slots and their screens: `AbstractFurnaceMenu` with `FurnaceMenu`, `BlastFurnaceMenu`, `SmokerMenu` and `AbstractFurnaceScreen` with `FurnaceScreen`, `BlastFurnaceScreen`, `SmokerScreen`; `BrewingStandMenu` and `BrewingStandScreen`; `CrafterMenu` (`MenuType` `crafter_3x3`) and `CrafterScreen`. Slot indexes and positions, slot rules, result-slot behaviour and the experience award on pick-up, quick-move rules, the data slots and what each one means, the recipe-book hooks of the furnace family, the progress sprites with their pixel arithmetic, the crafter's disabled-slot toggle (client behaviour, packet, server rule, synchronised data) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the jar's data files (`unzip -p`, `unzip -Z1`), with no execution. Every value was read in this round; anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions |
| Round | RS14 (design map GAP-19, processing-menu part). Siblings in the 40 series hold the shared menu model (slot clicks, cursor handling, container ids, the Open Screen flow) and the other menus; this part does not repeat them, except for the few shared routines that its quick-move rules depend on (section 1.3) |
| Related | 05a 0x13 (Container Set Data), 05a Open Screen and Container Set Slot, 05c 0x11 and 0x12 and 0x14 (container button, click, slot state changed), 12 section 5.6 (container screen frame, labels), 13 section 3.5 and 3.9 (menus, recipe book), 27 section 4.3 (recipe property sets), 30-4 (crafter as a redstone device), 31-2 (the furnace, brewing stand and crafter block entities: ticking, fuel, saved data, `RecipesUsed`, experience), 45-3 (statistics ids), 46 section 5.5 and 9.3 (menu type ids, recipe book category ids) |

Class names in backticks say where a fact was read. They are not the design.

Data is not tabulated here. Recipes, loot, tags, the `cooking_fuel` and `brewing_fuel` item components, language strings and the sprite and texture images are data (the vanilla data pack and resource pack extracted by the tool, 22). What is specified is the code: slot layout, rules, the engine that reads those data, and the drawing arithmetic. The texture and sprite pixel sizes quoted in this document were checked against the PNG headers in the jar (section 10, check V14).

---

## 1. Conventions shared by every menu in this document

### 1.1 Container screen frame

All four screens extend the container screen of 12 section 5.6: image 176 x 166, `leftPos = (screenWidth - 176) / 2`, `topPos = (screenHeight - 166) / 2`, the title at (`titleLabelX`, 6) and the player-inventory label at (8, 72), colour `#404040`. Every screen here overrides `init` to centre the title: `titleLabelX = (imageWidth - titleWidth) / 2` (integer division, `titleWidth` the pixel width of the title string in the screen font). The background is a texture of 256 x 256 pixels blitted at (`leftPos`, `topPos`) taking the region (0, 0, 176, 166). No sibling of this document changes the player-inventory label or the 8 / 72 / 142 placement.

Titles come from the server: the Open Screen packet carries the block entity's display name (its custom name, otherwise the default name key). The default name keys are `container.furnace`, `container.blast_furnace`, `container.smoker`, `container.brewing` and `container.crafter` (read in the four block entities). The English text of these keys is language data.

### 1.2 The standard inventory block

`addStandardInventorySlots(container, x, y)` appends 36 slots of the player's inventory after the menu's own slots, with the pair (x, y) = (8, 84) for every menu in this document:

| Part | Menu slots (relative to the first one appended) | Player inventory index | Position |
|---|---|---|---|
| Main inventory, row r (0 to 2), column c (0 to 8) | `c + 9 r` (0 to 26) | `9 + c + 9 r` (9 to 35) | (8 + 18 c, 84 + 18 r) |
| Hotbar, i (0 to 8) | 27 + i | i | (8 + 18 i, 142) |

(The hotbar y is 84 + 58 = 142: the code adds the constant 58 to y.) The block ends at menu index (first index + 35).

### 1.3 Shared routines the quick-move rules use

Read in `AbstractContainerMenu`; the full click model is a sibling's topic (40 part 1).

**`moveItemStackTo(stack, start, end, reverse)`** moves the given stack, in place, into the slots `start` (inclusive) to `end` (exclusive), scanning upward when `reverse` is false and downward from `end - 1` when it is true. It returns whether anything moved. Two passes:

1. Merge pass, run only when the stack is stackable (maximum stack size above 1) and not empty. Visit the slots in scan order; for each slot that holds a non-empty stack of the same item with the same components (`isSameItemSameComponents`): `total = slotCount + stackCount`, `cap = slot.getMaxStackSize(slotStack)`. When `total <= cap`: the moving stack becomes empty and the slot gets `total`. Otherwise, when `slotCount < cap`: the moving stack shrinks by `cap - slotCount` and the slot gets `cap`. Either change marks the slot changed and sets the result true. The pass stops as soon as the moving stack is empty. The merge pass does not ask `mayPlace`.
2. Placement pass, run when the stack is still not empty. Visit the slots in scan order and take the first slot that is empty **and** whose `mayPlace(stack)` is true: it receives `min(stackCount, slot.getMaxStackSize(stack))` items split off the moving stack, is marked changed, the result is true, and the pass ends. At most one empty slot is filled per call.

`Slot.getMaxStackSize(stack)` is `min(container max stack size, stack max stack size)`; a slot subclass may lower it (the fuel slot and the potion slot of this document do).

**The quick-move click** (`ContainerInput.QUICK_MOVE`): ignored for a negative slot id; ignored when the slot's `mayPickup(player)` is false; otherwise `quickMoveStack(player, slot)` is called, and while it returns a non-empty stack **and** the slot's current stack is the same item as the returned one, it is called again. A `quickMoveStack` that returns the empty stack therefore ends the loop. Every menu below returns the empty stack for "nothing could be moved" and returns a copy of the original stack (taken before the move) for "something moved".

The common tail of the three `quickMoveStack` methods here (furnace family, brewing stand, crafter): after the move, an emptied source stack is written back as empty with `setByPlayer`, otherwise the slot is marked changed; when the stack count did not change compared with the copy, return empty; otherwise call the slot's `onTake(player, stack)` and return the copy. The furnace and brewing menus also call `Slot.onQuickCraft(stack, copy)` on the source slot for the moves out of their output slots (section 2.4 and 4.4); the crafter does not.

### 1.4 Data slots

A menu built on a `ContainerData` registers one data slot per index, in index order, with `addDataSlots`. The property id of the Container Set Data packet (05a 0x13: container id VarInt, property Short, value Short) is the index among the menu's data slots, which equals the `ContainerData` index in all three menus here, because none of them registers any other data slot. The initial values travel with the initial content packet and later changes with 0x13. Both the property and the value are 16 bits on the wire: the packet class reads and writes the container id with `readContainerId` / `writeContainerId` (a VarInt) and the property and value with `readShort` / `writeShort`. `writeShort(int)` keeps only the low 16 bits, so an out-of-range value wraps modulo 65536 rather than clamping (32768 arrives as -32768). The furnace and brewing values stay far below that with vanilla data; a fuel whose evaluated burn time exceeds 32767 would wrap. The burn time carried in the furnace's total-burn data value is not a plain number field: it is the result of the item's `cooking_fuel` component, whose burn-time provider is a context int provider (a key such as `cooking/time_K`) evaluated when the fuel is consumed (31-2 section 4, 25-1 section 9, 25-3), so only data that makes a provider yield more than 32767 can trigger the wrap; that the data-slot value is exactly this evaluated duration was taken from 31-2 and was not re-read in the block entity here (inferred).

On the client the menu is built with a plain array container (`SimpleContainerData`: an int array of the given count, initially zeros, `get` and `set` by index) and a plain simple container for the items; the server supplies the block entity and its data object. Items arrive by Container Set Content and Container Set Slot (05a), data by 0x13.

---

## 2. The furnace family menu (`AbstractFurnaceMenu`)

### 2.1 Identity

| Menu class | `MenuType` key and id (46 section 5.5) | Property set that decides what the input slot accepts (27 section 4.3) | Recipe book type (05b Recipe Book Settings order, 13 section 3.9) | Default title key |
|---|---|---|---|---|
| `FurnaceMenu` | `furnace`, 14 | `furnace_input` | `FURNACE` | `container.furnace` |
| `BlastFurnaceMenu` | `blast_furnace`, 10 | `blast_furnace_input` | `BLAST_FURNACE` | `container.blast_furnace` |
| `SmokerMenu` | `smoker`, 22 | `smoker_input` | `SMOKER` | `container.smoker` |

The three subclasses differ only in these three values (and the screens in section 3). Everything else in this section is `AbstractFurnaceMenu`. The set is read from the level's recipe access when the menu is built, so on the client it is the property set the server sent in Update Recipes (27 section 4.3) and on the server the one built from the loaded recipes.

The menu has 3 own slots, 4 data slots and 36 inventory slots (39 slots in all). The block entity side (ticking, fuel burn, cooking, saved keys) is 31-2 section 3; this document uses its four numbers as read.

### 2.2 Slots

| Index | Role | Class | Position (x, y) |
|---|---|---|---|
| 0 | input (ingredient) | plain `Slot` | (56, 17) |
| 1 | fuel | `FurnaceFuelSlot` | (56, 53) |
| 2 | result | `FurnaceResultSlot` | (116, 35) |
| 3 to 29 | player main inventory (inventory 9 to 35) | plain | (8 + 18 c, 84 + 18 r) |
| 30 to 38 | player hotbar (inventory 0 to 8) | plain | (8 + 18 i, 142) |

The constants in the class: `INGREDIENT_SLOT` 0, `FUEL_SLOT` 1, `RESULT_SLOT` 2, `SLOT_COUNT` 3, `DATA_COUNT` 4, inventory range 3 to 30 (exclusive end), hotbar range 30 to 39 (exclusive end). The input slot accepts any item at menu level (`mayPlace` true): the property set only steers quick-move, and the block entity's own `canPlaceItem` filters hopper input (31-2).

### 2.3 Slot rules

**Input slot (0).** Plain slot: accepts any stack, maximum stack size from the container and the item (64 for most).

**Fuel slot (1), `FurnaceFuelSlot`.**
- `mayPlace(stack)` is true when the stack has the item component `cooking_fuel` (the menu's `isFuel`; the component is data, 25-1 section 9 and 25-3) **or** the stack is the empty bucket item (`Items.BUCKET` only, not water, lava or other buckets).
- `getMaxStackSize(stack)` is 1 when the stack is the empty bucket, otherwise the plain slot rule. So an empty bucket stack (stackable to 16) can be put into the fuel slot, one at a time, so that it can receive the bucket back; a lava bucket (not stackable beyond 1 by its own item rule) fits as 1.
- The bucket rule applies to placing by the player (cursor, number-key swap, drag), not to shift-click: shift-click routes by `isFuel` (section 2.5) and an empty bucket has no `cooking_fuel` component.

**Result slot (2), `FurnaceResultSlot`.**
- `mayPlace` is always false: nothing can be put into it.
- It may be picked up normally (default `mayPickup`).
- The slot holds an internal counter `removeCount`, starting at 0, used for statistics and experience (section 2.4).

### 2.4 Taking from the result slot: statistics and experience

The pick-up paths feed `removeCount`:

| Event | Effect on `removeCount` | Then |
|---|---|---|
| `remove(amount)` (a pick-up with the cursor, called by the click model before `onTake`) | while the slot has an item: add `min(amount, count of the stack in the slot)` | the click model then calls `onTake` |
| `onQuickCraft(stack, n)` (the protected form, reached from the quick-move below through `Slot.onQuickCraft(stack, copy)` with `n = copy.count - stack.count`, only when `n > 0`) | add `n` | run `checkTakeAchievements(stack)` immediately |
| `onTake(player, stack)` | none | run `checkTakeAchievements(stack)`, then the base slot's `onTake` |

Base slot behaviour (read): `Slot.onTake` only calls `setChanged()`; `Slot.remove(int)` calls `container.removeItem(slot, amount)`.

`checkTakeAchievements(stack)` has these steps, in order:

1. `stack.onCraftedBy(player, removeCount)`: awards the statistic `item_crafted` for the stack's item with the amount `removeCount` (45-3, stat type `crafted`), then calls the item's own crafted hook.
2. When the player is a server player **and** the slot's container is a furnace-family block entity (`AbstractFurnaceBlockEntity`): `awardUsedRecipesAndPopExperience(player)`. Its rules are those of 31-2 section 3.6 and are not repeated: for each (recipe key, count) of the block entity's `recipesUsed` map the recipe's experience is paid out with `createExperience(level, position, count, experience)` (whole part plus a random fractional round-up, orbs spawned with `ExperienceOrb.award`) **at the player's position**; the used recipes are awarded to the player's recipe book and the recipe-crafted trigger fires for each with the furnace's items; then `recipesUsed` is cleared.
3. `removeCount` is reset to 0.

Consequences (read from the call structure):
- Experience is never paid when items leave by hopper or are destroyed with the block in this path; only pulling from the result slot pays it (the block-removal path of 31-2 is separate).
- The experience of everything smelted since the last pick-up is paid in full on the first pick-up of any number of items, even one: `recipesUsed` is cleared whole.
- A quick-move out of the result slot reaches `checkTakeAchievements` twice: once from `onQuickCraft` (with the moved count, paying the experience), once from the tail `onTake` of `quickMoveStack` with `removeCount` back at 0 (statistic increment of 0, experience loop over an already empty map, so nothing more is paid).
- The statistic counts the items that left the slot (pick-up amount, or the moved amount of the quick-move), not the number of smelting operations.

### 2.5 Quick-move (`quickMoveStack`)

The clicked menu slot decides the rule. Ranges are written [start, end) as passed to `moveItemStackTo`.

| Clicked slot | Rule, in order | On failure |
|---|---|---|
| 2 (result) | move into [3, 39) with `reverse = true` (fills from the hotbar end, hotbar slot 38 first, merging into matching stacks before placing in an empty slot); then `onQuickCraft(stack, copy)` on the source slot | return empty |
| 0 (input) or 1 (fuel) | move into [3, 39), `reverse = false` (main inventory first, top-left first, then the hotbar) | return empty |
| 3 to 38 (inventory), stack accepted by the menu's property set (`canSmelt`) | move into [0, 1) (the input slot) | return empty; **no fall-through to the fuel rule** |
| 3 to 38, not smeltable, `isFuel` (component `cooking_fuel`) | move into [1, 2) (the fuel slot) | return empty |
| 3 to 29 (main), neither | move into [30, 39) (the hotbar), forward | return empty |
| 30 to 38 (hotbar), neither | move into [3, 30) (the main inventory), forward | return empty |

Order matters: the smeltable test is made before the fuel test, so an item that is both a valid input and a valid fuel goes only to the input slot, and when the input slot cannot take it (a different item, or full) the click ends without trying the fuel slot. "Per recipe category" in the sense of the three furnace kinds: each menu tests its own property set (section 2.1), so raw food shift-clicks into a smoker or a furnace only if its recipes are in that kind's set, and ore only into a furnace or blast furnace by the same rule. Which items are in which set is recipe data.

Because the click model repeats `quickMoveStack` while the same item remains (section 1.3), a shift-click on a large stack moves as much as fits: merging into the existing input stack, and placing the remainder only if the slot was empty (placement fills one empty slot per call).

### 2.6 Data slots and derived values

The four data slots, indexes as in the block entity's data accessor (`AbstractFurnaceBlockEntity.dataAccess`, 31-2 section 3):

| Index | Meaning | Block entity field | Use in the menu |
|---|---|---|---|
| 0 | remaining burn ticks of the current fuel | `litTimeRemaining` | `isLit` is true when it is greater than 0 |
| 1 | total burn ticks of the current fuel item | `litTotalTime` | denominator of the flame |
| 2 | cooking progress in ticks | `cookingTimer` | numerator of the arrow |
| 3 | total cooking time in ticks for the current input | `cookingTotalTime` | denominator of the arrow |

`get` of an index outside 0 to 3 returns 0 and `set` outside it does nothing (read). Derived values (floats):

- `litProgress`: let `d = data[1]`; when `d` is 0 use 200 (the constant `BURN_TIME_STANDARD`). Result `clamp(data[0] / d, 0, 1)`.
- `burnProgress`: `p = data[2]`, `t = data[3]`; when either is 0 the result is 0, otherwise `clamp(p / t, 0, 1)`.

### 2.7 Recipe book hooks

The furnace menus extend `RecipeBookMenu` (the general recipe book flow is 13 section 3.9). Their specific parts:

- **Book type.** `getRecipeBookType()` returns the menu's value from the table in 2.1; it selects the open/filtering pair among the four in Recipe Book Settings (05b 0x4D) and the Change Settings packet (05c 0x2F).
- **Stacked contents for the craftability test.** `fillCraftSlotsStackedContents` adds the contents of the menu's own container to the counter only when that container is a `StackedContentsCompatible` (the furnace block entity is the server container). `SimpleContainer` is declared as implementing `StackedContentsCompatible`, so on the client the menu's `fillCraftSlotsStackedContents` does contribute the container's items to the counter, and the client counts the furnace's own input for craftability highlighting.
- **Which slots are "crafting slots".** In `FurnaceRecipeBookComponent`, `isCraftingSlot` is true for menu slots 0, 1 and 2 (they are cleared of the ghost recipe when clicked, see 13 section 3.9 "any click on a crafting slot").
- **Ghost recipe.** `fillGhostRecipe`: the display's result is drawn as ghost in the result slot (index 2); when the display is a furnace recipe display, its ingredient is the ghost of slot 0, and its fuel display is the ghost of slot 1 **only while slot 1 currently holds nothing**. Other display kinds put only the result ghost.
- **Recipe filter.** `selectMatchingRecipes` keeps, for craftability, only recipe displays that are furnace recipe displays (a collection's non-furnace displays are ignored).
- **Place recipe (server, `handlePlacement`).** The recipe is placed as a 1 x 1 grid whose single input slot is menu slot 0; the slots cleared first (returned to the player's inventory) are slots 0 and 2 (input and result), never slot 1 (fuel); a recipe is accepted for placement when it matches the single item currently in slot 0 (`AbstractCookingRecipe.matches` with a single-item input, the level being the server level); the placement routine is the shared `ServerPlaceRecipe` of 13 section 3.8 with that geometry (its crafting-grid centring rules are irrelevant for a 1 x 1 grid). The result of `handlePlacement` is the shared post-place action (none of the furnace-specific code names another one).
- **Filter button.** The furnace family uses the sprites `recipe_book/furnace_filter_enabled`, `_disabled`, `_enabled_highlighted`, `_disabled_highlighted` for all three kinds, and the filter label key given by each screen (section 3.3).

---

## 3. The furnace family screens (`AbstractFurnaceScreen`)

### 3.1 Frame and recipe book button

The screen is a recipe-book screen (`AbstractRecipeBookScreen`): it owns a `FurnaceRecipeBookComponent`. The panel and the shifting of the main screen to the right by 86 pixels when the window width is 379 or more (the panel overlays the screen below that) are 13 section 3.9. The furnace specifics:

- Recipe book button: an `ImageButton` of 20 x 18 pixels at (`leftPos + 20`, `screenHeight / 2 - 49`) (integer division; `leftPos` is the possibly shifted left edge). Pressing it toggles the book (13 section 3.9).
- Title centred (section 1.1).
- Texture: `textures/gui/container/<kind>.png`, 256 x 256, drawn at (`leftPos`, `topPos`) with the region (0, 0, 176, 166).

### 3.2 Progress sprites

Both sprites are drawn after the background texture, in this order (flame first, arrow second). Sprite file sizes (checked): flame 14 x 14, arrow 24 x 16.

**Flame (lit progress).** Drawn only while `isLit` (data 0 greater than 0).
1. `h = ceil(litProgress x 13) + 1` (float multiply, then the integer ceiling; `h` is between 2 and 14 whenever lit, because `litProgress` is above 0 and at most 1).
2. Draw the bottom `h` rows of the 14 x 14 sprite: source region (u, v) = (0, 14 - h), size 14 x `h`; destination (x, y) = (`leftPos + 56`, `topPos + 36 + 14 - h`), size 14 x `h`. So the flame is anchored at the bottom, y = `topPos + 50` for the bottom edge, and shrinks from the top as the fuel burns.

**Arrow (burn progress).** Always drawn (a width of 0 draws nothing).
1. `w = ceil(burnProgress x 24)`.
2. Draw the left `w` columns of the 24 x 16 sprite: source (0, 0), size `w` x 16; destination (`leftPos + 79`, `topPos + 34`), size `w` x 16.

(The two sprite calls take the sprite's own width and height first, then the source offset, then the destination and the drawn size: `blitSprite(pipeline, sprite, spriteW, spriteH, u, v, x, y, drawW, drawH)`.)

### 3.3 Per-kind data

| Screen | Texture | Flame sprite | Arrow sprite | Filter label key | Tabs of the book (in order) |
|---|---|---|---|---|---|
| `FurnaceScreen` | `gui/container/furnace.png` | `container/furnace/lit_progress` | `container/furnace/burn_progress` | `gui.recipebook.toggleRecipes.smeltable` | search (category `FURNACE`); `furnace_food` icon porkchop; `furnace_blocks` icon stone; `furnace_misc` icons lava bucket and emerald |
| `BlastFurnaceScreen` | `gui/container/blast_furnace.png` | `container/blast_furnace/lit_progress` | `container/blast_furnace/burn_progress` | `gui.recipebook.toggleRecipes.blastable` | search (`BLAST_FURNACE`); `blast_furnace_blocks` icon redstone ore; `blast_furnace_misc` icons iron shovel and golden leggings |
| `SmokerScreen` | `gui/container/smoker.png` | `container/smoker/lit_progress` | `container/smoker/burn_progress` | `gui.recipebook.toggleRecipes.smokable` | search (`SMOKER`); `smoker_food` icon porkchop |

Texture and sprite paths are relative to `assets/minecraft/textures/` with `.png` for sprites under `gui/sprites/`. A tab with two icons draws both (first icon, second icon, then the category). The recipe book category ids are in 46 section 9.3 (4 to 9). The tab labels' behaviour (hidden when empty, default selection, wiggle) is the generic one of 13 section 3.9.

---

## 4. The brewing stand menu (`BrewingStandMenu`)

### 4.1 Identity

`MenuType` `brewing_stand`, id 11 (46 section 5.5). Not a recipe-book menu (it extends `AbstractContainerMenu` directly). 5 own slots, 4 data slots, 36 inventory slots (41 slots). Default title key `container.brewing`. Construction order in the constructor: the 5 own slots, then `addDataSlots` (the 4 data slots), then `addStandardInventorySlots`; the furnace family (2.1) does the reverse, inventory slots first and data slots last. Data slots take no slot id and property ids are the `ContainerData` indices, so the order changes no index; do not assume property ids and slot ids share a construction order. The client constructor builds a 5-slot simple container and a 4-value data object; the server constructor takes the block entity and its data.

### 4.2 Slots

| Index | Role | Class | Position (x, y) | Empty-slot icon (sprite drawn at the slot while empty, 16 x 16) |
|---|---|---|---|---|
| 0 | bottle, left | `PotionSlot` | (56, 51) | `container/slot/potion` |
| 1 | bottle, middle (lower) | `PotionSlot` | (79, 58) | `container/slot/potion` |
| 2 | bottle, right | `PotionSlot` | (102, 51) | `container/slot/potion` |
| 3 | ingredient | `IngredientsSlot` | (79, 17) | none |
| 4 | fuel | `FuelSlot` | (17, 17) | `container/slot/brewing_fuel` |
| 5 to 31 | player main inventory | plain | (8 + 18 c, 84 + 18 r) | none |
| 32 to 40 | player hotbar | plain | (8 + 18 i, 142) | none |

Class constants: bottle range 0 to 2 (the class constant names the end as 2, inclusive), ingredient 3, fuel 4, `SLOT_COUNT` 5, `DATA_COUNT` 4, inventory [5, 32), hotbar [32, 41). The empty-slot icon is drawn by the container screen's slot drawing when the slot's stack is empty and the slot is active, at the slot's (x, y), 16 x 16, inside the container screen's per-slot drawing (`extractSlot`): after the test that the stack is empty and the slot active, and before the item, the item decorations and the fake-item branches are drawn; the slot highlight is drawn separately, a back highlight before all slots and a front highlight after all slots.

### 4.3 Slot rules

- **`PotionSlot` (0 to 2).** `mayPlace(stack)` is `PotionIngredient.isPotionInput(stack, recipeAccess)`: true when the stack is accepted by the property set `brewing_input` (27 section 4.3: the union of the `input` items of all brewing recipes) **or** the item is in the item tag `brewing_potion_inputs` (read from `data/minecraft/tags/item/brewing_potion_inputs.json`: exactly four members, `potion`, `splash_potion`, `lingering_potion` and `glass_bottle`; so an empty glass bottle is accepted by the bottle slots, and quick-move rule 4 of 4.4 relies on this). The slot has **no** emptiness check (unlike the block entity's `canPlaceItem` for hoppers, 31-2, which also requires the slot to be empty); its maximum stack size is **1** (`getMaxStackSize()` returns 1, so the effective cap is `min(1, item max)`). `onTake(player, stack)`: when the stack has a `potion_contents` component and the player is a server player, the advancement trigger `brewed_potion` fires with those contents (26 and 27 advancement engine); then the base `onTake`.
- **`IngredientsSlot` (3).** `mayPlace(stack)` is true when the stack is accepted by the property set `brewing_reagent` (the union of the `reagent` items of all brewing recipes, 27 section 4.3, set key `BREWING_REAGENTS`). Maximum stack size is the plain slot rule.
- **`FuelSlot` (4).** `mayPlace(stack)` (also exposed as the static `mayPlaceItem`) is true when the stack has the item component `brewing_fuel` (31-2 section 4: the component carries the uses and speed providers; in the shipped data only blaze powder has it). Plain stack size.

### 4.4 Quick-move

The clicked slot decides; the checks run in this exact order. "Fail" means `moveItemStackTo` returned false.

| # | Condition | Action |
|---|---|---|
| 1 | clicked slot in 0 to 4 (a bottle, the ingredient or the fuel) | move into [5, 41) with `reverse = true`; fail: return empty; success: `onQuickCraft(stack, copy)` on the source slot, then the common tail |
| 2 | the stack passes `FuelSlot.mayPlaceItem` | move into [4, 5) (fuel slot). **When this move succeeds, return empty immediately** (the common tail is skipped, so the loop of 1.3 ends after this one call). When it fails: if the ingredient slot's `mayPlace` accepts the stack, move into [3, 4); a successful ingredient move continues to the common tail, a failed one returns empty; if the ingredient slot does not accept it, continue to the common tail with nothing moved (which then returns empty because the count is unchanged) |
| 3 | the ingredient slot's `mayPlace` accepts the stack (and rule 2 did not apply) | move into [3, 4); fail: return empty; success: common tail |
| 4 | `isPotionInput` (as in `PotionSlot`) | move into [0, 3) forward; fail: return empty; success: common tail |
| 5 | clicked slot in [5, 32) | move into [32, 41) forward; fail: return empty |
| 6 | clicked slot in [32, 41) | move into [5, 32) forward; fail: return empty |
| 7 | anything else | move into [5, 41) forward; fail: return empty |

Reading notes: (a) Because rule 2 precedes rule 3, blaze powder (which is both a fuel and a brewing reagent in the shipped data, 31-2 section 4) goes first to the fuel slot, and only goes to the ingredient slot when the fuel slot cannot take any of it. (b) A potion-input stack is placed one per call because potion stacks do not stack beyond 1 and the placement pass puts into a single empty slot with a cap of 1; the click loop repeats the call while the same item remains in the source slot, so a stack of several bottles fills the three bottle slots one after the other and stops when a call fails. (c) The early return of rule 2 on a successful fuel move skips the "write back empty / mark changed" step; the moved-from stack was changed in place, so a fully moved source stack is left as a count-0 stack object, which is empty for every purpose (inferred; see Open question 2).

### 4.5 Data slots

The four data slots, in the order of the block entity's data accessor (`BrewingStandBlockEntity`, constants `DATA_BREW_TIME` 0, `DATA_FUEL_USES` 1, `DATA_TOTAL_BREW_TIME` 2, `DATA_TOTAL_FUEL_USES` 3):

| Index | Meaning | Block entity field (31-2 section 4) | Menu accessor |
|---|---|---|---|
| 0 | remaining brew ticks (0 when idle) | `brewTime` | `getBrewingTicks` |
| 1 | remaining fuel uses | `fuel` | `getFuel` |
| 2 | total brew ticks of the current brew (400 divided by the speed multiplier, rounded up, 31-2 example 7) | `totalBrewTime` | `getTotalBrewingTicks` |
| 3 | fuel uses loaded with the last fuel item (20 with the shipped fuel) | `totalFuel` | `getTotalFuel` |

(The names of indexes 2 and 3 are the unusual part: index 2 is the total brew time and index 3 the total fuel, read from the `tableswitch` of the accessor; the menu's accessors read them in that mapping.)

---

## 5. The brewing stand screen (`BrewingStandScreen`)

Frame as 1.1 (title centred). Texture `textures/gui/container/brewing_stand.png` (256 x 256), region (0, 0, 176, 166). No recipe book. Three sprites are drawn after the background, in this order (fuel bar, then the arrow and the bubbles, the last two only while a brew runs):

**Fuel bar** (sprite `container/brewing_stand/fuel_length`, file 18 x 4).
1. `f = data[1]`, `T = data[3]`. When `T > 0`: `w = clamp(ceilDiv(18 x f, T), 0, 18)` where `ceilDiv` is the positive-integer ceiling division (`Mth.positiveCeilDiv(int,int)`, read as the negation of `Math.floorDiv(-a, b)`, which is a true ceiling `ceil(a / b)` for positive operands). When `T <= 0`: `w = 0`.
2. When `w > 0`: draw the left `w` columns: source (0, 0), size `w` x 4; destination (`leftPos + 60`, `topPos + 44`), size `w` x 4.

**Arrow and bubbles** run only when both `b = data[0] > 0` and `B = data[2] > 0`.
- Arrow (sprite `container/brewing_stand/brew_progress`, file 9 x 28): `a = trunc(28 x (1 - b / B))` (float arithmetic, truncation toward zero by the float-to-int conversion). When `a > 0`: draw the top `a` rows: source (0, 0), size 9 x `a`; destination (`leftPos + 97`, `topPos + 16`), size 9 x `a`. The arrow therefore grows downward as `b` falls from `B` to 1.
- Bubbles (sprite `container/brewing_stand/bubbles`, file 12 x 29): the length table `BUBBLELENGTHS` has seven entries, indexed 0 to 6: 29, 24, 20, 16, 11, 6, 0. Index = `(b / 2) % 7` (integer division, then remainder). With `L` the table value, when `L > 0` draw the bottom `L` rows: source (0, 29 - L), size 12 x `L`; destination (`leftPos + 63`, `topPos + 14 + 29 - L`), size 12 x `L`. The bubbles animate by index stepping every two ticks, as `b` counts down the index falls 6, 5, 4, 3, 2, 1, 0 (lengths 0, 6, 11, 16, 20, 24, 29), so the bubbles go from none, to short, to long (29 rows at index 0), then jump back to none when the index wraps from 0 to 6; index 6 (no bubbles) holds for the two ticks with `b mod 14` equal to 12 or 13 of each 14-tick cycle.

No tooltip or other widget is added. Slot positions are those of 4.2; the player-inventory label stays at (8, 72).

---

## 6. The crafter menu (`CrafterMenu`)

### 6.1 Identity

`MenuType` `crafter_3x3`, id 7 (46 section 5.5). Extends `AbstractContainerMenu` and implements `ContainerListener`. The block entity is 31-2 section 7 and the redstone behaviour 30-4; this section is the menu. 9 crafting slots, 1 result slot, 36 inventory slots, 10 data slots; 46 slots in all. Opening the block (`CrafterBlock.useWithoutItem`): on the server, when the block entity is a crafter, open its menu; the result is a success on both sides. No statistic is awarded on opening (none is called in that method). Default title key `container.crafter`.

Two constructors: the client one builds a transient 3 x 3 crafting container with 10 data values (all 0); the server one receives the block entity (a 9-slot `CraftingContainer`) and its data object, checks the sizes, calls `startOpen` on the container for the player, and registers the menu as its own slot listener (`addSlotListener(this)`). `stillValid` is the container's: for the block entity, `Container.stillValidBlockEntity` (31-1 section 8.1, the 4.0 buffer rule).

### 6.2 Slots

| Index | Role | Class | Position (x, y) |
|---|---|---|---|
| 0 to 8 | crafting slot, row-major: index = column + 3 x row | `CrafterSlot` | (26 + 18 x column, 17 + 18 x row) |
| 9 to 35 | player main inventory | plain | (8 + 18 c, 84 + 18 r) |
| 36 to 44 | player hotbar | plain | (8 + 18 i, 142) |
| 45 | result (display only) | `NonInteractiveResultSlot` on a one-slot `ResultContainer` | (134, 35) |

(Order of addition: the nine crafter slots, then the standard inventory block, then the result slot, then the data slots, then the first result refresh.) Class constants: `SLOT_COUNT` 9, inventory [9, 36), hotbar [36, 45).

**`CrafterSlot`.** `mayPlace(stack)` is true only when the slot is not disabled (`menu.isSlotDisabled(index)`) **and** the base rule accepts (always). `setChanged` calls the base, then `menu.slotsChanged(container)`, which broadcasts the menu changes (`broadcastChanges`). A disabled slot is empty by construction (section 6.4), so its other rules are the plain ones.

**`NonInteractiveResultSlot` (45).** A display-only slot: `mayPlace` false, `mayPickup` false, `tryRemove` and `safeTake` return nothing, `remove` returns the empty stack, `allowModification` false, `safeInsert` (both forms) returns the stack it was given unchanged, `onTake` and `onQuickCraft` do nothing, it is not highlightable (`isHighlightable` false) and it reports `isFake` true. It never consumes ingredients; the crafter crafts only by its redstone pulse (30-4 section 3).

### 6.3 The result preview

The result slot's content is a **prediction** the server computes and syncs; the client never computes it.
- `refreshRecipeResult` runs once at the end of slot construction and again from `slotChanged` (the `ContainerListener` callback fires from `broadcastChanges` for each slot whose content changed since the last broadcast, including the crafting slots).
- On the server (the player is a `ServerPlayer`): build the 3 x 3 crafting input from the container (31-2 section 7.1), ask `CrafterBlock.getPotentialResults(level, input)` for the matching crafting recipe (the cached lookup of 30-4 section 3), and set the result container's slot 0 to `recipe.assemble(input)`; with no matching recipe set it to the empty stack.
- On the client the method does nothing (the player is not a server player): the result slot shows what Container Set Slot sent.
- `dataChanged` (the other `ContainerListener` callback) does nothing.

### 6.4 Data slots

Ten data slots (property ids 0 to 9), the block entity's own data object (31-2 section 7):

| Index | Meaning | Values |
|---|---|---|
| 0 to 8 | state of crafting slot `i` | 0 = enabled, 1 = disabled |
| 9 | powered (the block entity's `triggered` flag, set by the redstone signal) | 0 or 1 |

Menu accessors: `isSlotDisabled(i)` is true when `-1 < i < 9` and `data[i] == 1` (any other index, including 45 and the inventory slots, is false); `isPowered()` is `data[9] == 1`.

`setSlotState(slot, enabled)` (menu level): look up the `CrafterSlot` at that menu index, write `data[slot index] = enabled ? 0 : 1`, then `broadcastChanges()`. Used by the client screen for immediate feedback. The authoritative change is the block entity's own `setSlotState` (31-2 section 7.2): ignored unless the slot index is 0 to 8 **and the slot is empty**, then it writes the same value and marks the block entity changed. The server menu and the block entity share one data object, so the block entity's write reaches the menu, and the next `broadcastChanges` sends Container Set Data for each changed property.

### 6.5 Quick-move

| Clicked slot | Rule | On failure |
|---|---|---|
| 0 to 8 (a crafting slot) | move into [9, 45) with `reverse = true` (the 36 inventory slots, from the last hotbar slot downward; the result slot 45 is outside the range) | return empty |
| anything else (9 to 45) | move into [0, 9) forward (the crafting slots in index order; a disabled slot refuses through `mayPlace`, an occupied one only merges) | return empty |

Then the common tail of 1.3, with this difference: the emptied source is written with `Slot.set(empty)`; there is no `onQuickCraft`. The result slot cannot reach this code: the click model returns before `quickMoveStack` when `mayPickup` is false (section 1.3).

The "anything else" rule moves inventory items into the crafter in slot order; it does not apply the even-distribution fairness rule of the block entity's `canPlaceItem` (31-2 section 7.2), because the menu's own placement pass calls only the slot's `mayPlace`, which checks only the disabled flag.

---

## 7. The crafter screen (`CrafterScreen`)

### 7.1 Frame

Plain container screen (no recipe book). Texture `textures/gui/container/crafter.png` (256 x 256), region (0, 0, 176, 166) at (`leftPos`, `topPos`). Title centred (1.1).

### 7.2 Clicking a crafting slot (the toggle)

`slotClicked(slot, slotId, button, input)` is overridden. The special handling applies only when **all** of these hold: the clicked slot is a `CrafterSlot`; it has no item; the player is not a spectator. Then, by click type:

| Click type | Condition | Action |
|---|---|---|
| `PICKUP` (ordinary click) | slot is disabled | enable the slot |
| `PICKUP` | slot is enabled and the **cursor (carried) stack is empty** | disable the slot |
| `PICKUP` | slot is enabled and the cursor holds an item | nothing special (the ordinary click then places the cursor items) |
| `SWAP` (number key or off-hand swap; `button` is the inventory index used) | slot is disabled **and** the player-inventory stack at index `button` is not empty | enable the slot |
| any other click type | | nothing special |

Whatever happened, the base `slotClicked` then runs, so the ordinary Container Click packet (05c 0x12) is sent after the toggle packet and a click on a disabled slot with a held item enables the slot first and then places the item. Quick-move, throw, clone and the others get no toggle.

`enableSlot(slotId)` and `disableSlot(slotId)` call `updateSlotState(slotId, newState)` with `true` and `false`:
1. `menu.setSlotState(slotId, newState)`: the immediate local change of data property `slotId` (6.4).
2. Send the **Container Slot State Changed** packet (05c 0x14): slot id (VarInt) = `slotId` (the menu index, equal to the crafting slot's index 0 to 8), container id = the menu's container id, new state (Boolean) = the enabled flag. (Sent through the shared `handleSlotStateChanged` of the container screen.)
3. Play the sound event `ui.button.click` to the player (`SoundEvents.UI_BUTTON_CLICK`) with volume 0.4 and pitch **1.0** when enabling, **0.75** when disabling.

**Server handling of 0x14** (`handleContainerSlotStateChanged`): ignored when the sender is a spectator, or the container id differs from the open menu's, or the open menu is not a `CrafterMenu`, or the menu's container is not the crafter block entity. Otherwise it calls the block entity's `setSlotState(slotId, newState)` (31-2 section 7.2): only an empty slot with an index from 0 to 8 changes. The change is then visible to the client through Container Set Data (6.4). If the server refuses (the slot was filled in the meantime), the next data synchronisation restores the client's local guess. There is no other server check, and no reply.

### 7.3 Drawing

Per slot (`extractSlot`):
- A `CrafterSlot` that is disabled is drawn as the sprite `container/crafter/disabled_slot` (file 18 x 18) at (`slot.x - 1`, `slot.y - 1`), size 18 x 18, in place of the normal slot drawing (no item can be there). An enabled one is drawn the normal way.
- For every `CrafterSlot` (enabled or disabled), after drawing: when the pointer (`mouseX`, `mouseY`, in screen coordinates) is inside the rectangle with corner (`leftPos + slot.x - 2`, `topPos + slot.y - 2`), exclusive on all four sides, and size 19 x 19 (so `x0 < mouseX < x0 + 19` and `y0 < mouseY < y0 + 19`), a pointing-hand mouse cursor is requested for the frame.
- Other slots: normal.

Tooltip (in `extractRenderState`, after the normal rendering and the redstone sprite): when the hovered slot is a `CrafterSlot`, it is **not** disabled, the cursor stack is empty, the slot has no item, and the player is not a spectator, the translatable text `gui.togglable_slot` is set as the tooltip at the pointer position (a plain one-line text tooltip, same style as other tooltips, 12 section 5.8).

Powered indicator (`extractRedstone`, drawn from `extractRenderState` after the frame): a 16 x 16 sprite at (`screenWidth / 2 + 9`, `screenHeight / 2 - 48`) (integer divisions; these are screen-size based, not `leftPos` based; for even screen sizes that is (`leftPos + 97`, `topPos + 35`)). The sprite is `container/crafter/powered_redstone` when `isPowered()` (data 9 equal to 1) and `container/crafter/unpowered_redstone` otherwise. The sprites are drawn with the plain GUI-sprite call that takes only the destination rectangle (the sprite files are 16 x 16 and 18 x 18; no scaling metadata exists for them in the jar, so they draw at native size).

---

## 8. Packet summary for this part

| Packet | Use here |
|---|---|
| Open Screen (05a) | menu type id (7, 10, 11, 14, 22), container id, title; the menu is built on the client by its two-argument constructor |
| Container Set Content / Set Slot (05a) | all item slots, including the crafter's prediction in slot 45 |
| Container Set Data 0x13 (05a) | the data slot values of 2.6, 4.5 and 6.4 |
| Container Click 0x12 (05c) | all slot interaction (the quick-move rules above run on the server) |
| Container Slot State Changed 0x14 (05c) | crafter slot toggle (7.2) |
| Recipe Book Settings 0x4D, Change Settings 0x2F, Seen Recipe 0x30, Place Recipe 0x27, Place Ghost Recipe 0x40 (05a, 05c) | furnace family recipe book (2.7) |
| Container Button Click 0x11 | not used by any menu in this part (no button ids) |

---

## 9. Worked examples

**E1. Furnace shift-click, ordinary cases.** Menu slot numbering as 2.2. (a) The player holds 64 raw iron in menu slot 5 (main inventory) and the input slot is empty: rule "3 to 38, smeltable" calls `moveItemStackTo(stack, 0, 1, false)`: the merge pass finds no matching stack, the placement pass puts `min(64, 64)` = 64 into slot 0. The source empties. (b) The input slot already holds 40 raw iron and the source holds 40: the merge pass computes `total = 80 > cap = 64`, so 24 move, slot 0 becomes 64, the source keeps 16, and the result is true; the click loop calls again, the second call moves nothing (the merge pass finds slot 0 full, the placement pass finds no empty slot), returns empty and ends the loop with 16 left. (c) 64 coal in slot 30 (hotbar): coal is not in `furnace_input` (so not smeltable) and has `cooking_fuel`, so it goes to [1, 2): slot 1 gets 64.

**E2. Fuel-slot rules.** A second lava bucket onto a fuel slot holding one: the merge pass has `total = 2 > cap = 1` and `slotCount = 1`, not below the cap, so nothing; the placement pass finds the slot occupied; false. An empty bucket stack of 16 dropped on the empty fuel slot by the cursor: `mayPlace` is true (bucket rule), `getMaxStackSize` is 1, so one bucket is placed and 15 stay on the cursor (the cursor mechanics are 40 part 1). Shift-clicking the same empty-bucket stack does not target the fuel slot: it is neither smeltable nor `cooking_fuel`, so it is shuffled between main inventory and hotbar by the last two rules of 2.5.

**E3. Furnace data and drawing.** A furnace is cooking raw iron with coal: `data[0] = 1200`, `data[1] = 1600`, `data[2] = 57`, `data[3] = 200`. `litProgress = 1200 / 1600 = 0.75`; `0.75 x 13 = 9.75`, ceiling 10, `h = 11`. The flame draws source (0, 3), size 14 x 11, at (`leftPos + 56`, `topPos + 36 + 14 - 11` = `topPos + 39`). `burnProgress = 57 / 200 = 0.285`; `0.285 x 24 = 6.84`, ceiling 7: arrow source (0, 0), size 7 x 16 at (`leftPos + 79`, `topPos + 34`). Edge: `data[0] = 1`, `data[1] = 1600`: `1 / 1600 x 13 = 0.008`, ceiling 1, `h = 2`. Edge: `data[1] = 0` (menu freshly built, nothing synced): the divisor falls back to 200. Full: `data[0] = data[1] = 1600` gives `h = 14` (the whole sprite).

**E4. Experience on pick-up.** A furnace smelted three raw gold items in a row (the block entity holds `recipesUsed` = {the gold recipe: 3}, with the recipe's experience 1.0): the player shift-clicks the 3 ingots out of slot 2. `moveItemStackTo` moves 3, `Slot.onQuickCraft(stack, copy)` has `n = 3` so `removeCount = 3`, `checkTakeAchievements` runs: statistic `item_crafted` of the ingot +3, experience `total = 3 x 1.0 = 3.0`, whole part 3, no fractional part so no random draw, 3 experience points spawn at the player's position, the recipe is awarded to the recipe book, `recipesUsed` is cleared, `removeCount` is 0. The tail `onTake` repeats `checkTakeAchievements` with `removeCount = 0`: statistic +0, nothing more to pay. (With the recipe experience 0.7 the example of 31-2 section 3.6 applies: the fractional part decides by one random float.)

**E5. Brewing quick-move, ordered rules.** Menu slots as 4.2. (a) The player shift-clicks 5 blaze powder in slot 20 (main inventory) while the fuel slot is empty: rule 2: the stack passes `FuelSlot.mayPlaceItem`, `moveItemStackTo(stack, 4, 5, false)` puts all 5 in slot 4 (cap 64) and returns true, so the method returns the empty stack at once (the loop ends; the source stack was shrunk in place to count 0). (b) The same click with the fuel slot already full (64): rule 2's fuel move fails; the ingredient slot accepts blaze powder (reagent) so the stack goes into [3, 4): slot 3 empty, receives the stack (placement pass); success continues to the common tail and the count change calls `onTake`. (c) A water bottle in slot 33 (hotbar): not fuel; not a reagent; `isPotionInput` true: moved into [0, 3), one per call into the first empty bottle slot; three calls fill 0, 1, 2; the fourth call finds all three occupied (the merge pass is skipped for unstackable stacks), returns false and ends. (d) A finished potion in slot 1 shift-clicked: rule 1 moves it into [5, 41) in reverse, so it lands in the last free hotbar slot (the hotbar end of the range first), and `onQuickCraft` runs on the source slot (a no-op for plain slots, since only the furnace result slot overrides the protected form).

**E6. Brewing screen drawing.** `data[0] = 400`, `data[2] = 400` (a brew just started): `a = trunc(28 x (1 - 1)) = 0`, no arrow; bubble index `(400 / 2) % 7 = 200 % 7 = 4`, `L = 11`: bubbles source (0, 18), size 12 x 11 at (`leftPos + 63`, `topPos + 14 + 29 - 11` = `topPos + 32`). At `data[0] = 200`: arrow height `trunc(28 x 0.5) = 14` (source (0, 0), 9 x 14 at (`leftPos + 97`, `topPos + 16`)); bubble index `100 % 7 = 2`, `L = 20`. At `data[0] = 1`: `28 x (1 - 1/400) = 27.93`, truncated to 27. Fuel with `data[1] = 20`, `data[3] = 20`: `ceilDiv(360, 20) = 18`, the full bar; `data[1] = 19`: `ceilDiv(342, 20) = 18` (17.1 rounds up), still full; `data[1] = 10`: 9; `data[1] = 1`: `ceilDiv(18, 20) = 1`; `data[1] = 0`: width 0 so nothing is drawn.

**E7. Crafter toggle round trip.** The player right-clicks or left-clicks the empty crafting slot at menu index 4 (the centre) with an empty cursor. The client: slot is a `CrafterSlot`, empty, not spectator, click type `PICKUP`, the slot is enabled and the cursor is empty: `disableSlot(4)`: local `data[4] = 1`, packet 0x14 with slot id 4, the open container id and new state false, sound `ui.button.click` volume 0.4 pitch 0.75, then the ordinary Container Click is sent (it changes nothing, the slot being empty). The server validates the menu and calls the block entity's `setSlotState(4, false)`: slot 4 is empty, so its state becomes 1 and the entity is marked changed. At the next `broadcastChanges` the server sends Container Set Data (container id, property 4, value 1) to every viewer. The screen then draws the 18 x 18 disabled sprite at (`slot.x - 1`, `slot.y - 1`) = slot 4 has (x, y) = (26 + 18, 17 + 18) = (44, 35), so the sprite is at (43, 34) relative to (`leftPos`, `topPos`). A later click on it with an empty cursor enables it again (`data[4] = 0`, pitch 1.0). Holding an item and clicking the disabled slot sends the enable packet first, then the click places the item.

**E8. Crafter preview and quick-move.** The crafter slots 0 to 8 hold the pattern of a recipe: after the last item arrives, `broadcastChanges` fires `slotChanged`, the server recomputes and sets the result container's slot 0, and Container Set Slot for menu slot 45 carries the product. Shift-clicking an item from main inventory slot 20: the rule "anything else" tries [0, 9) forward: it merges into matching crafting stacks first, otherwise it places into the first empty enabled slot (a disabled slot's `mayPlace` is false, so it is skipped). Shift-clicking crafting slot 3: moves into [9, 45) in reverse: first merges into matching inventory stacks scanning down from slot 44, else the highest-index empty inventory slot.

---

## 10. Validation

Checks an implementation can run without the jar. "V" items are testable assertions; the expected values follow from the tables above.

| # | Check | Expected |
|---|---|---|
| V1 | Furnace menu slot count and positions | 39 slots; slot 0 (56, 17), 1 (56, 53), 2 (116, 35); inventory 3 to 29 and hotbar 30 to 38 per 1.2 |
| V2 | Brewing menu slot count and positions | 41 slots; 0 (56, 51), 1 (79, 58), 2 (102, 51), 3 (79, 17), 4 (17, 17); inventory 5 to 31, hotbar 32 to 40 |
| V3 | Crafter menu slot count and positions | 46 slots; crafting slot (column c, row r) at index c + 3r, (26 + 18c, 17 + 18r); inventory 9 to 35; hotbar 36 to 44; result 45 at (134, 35) |
| V4 | Data slot counts | furnace family 4, brewing 4, crafter 10; property ids equal the data indexes |
| V5 | Fuel slot `mayPlace` | true for `cooking_fuel` items and for the empty bucket only; a water bucket is refused; the bucket stack cap in that slot is 1 |
| V6 | Result slot (furnace) | `mayPlace` false for every stack; the first pick-up pays the experience of all of `recipesUsed` then clears it (E4) |
| V7 | Furnace quick-move precedence | an item both smeltable and fuel goes to slot 0 only; a failed input move returns empty without trying the fuel slot |
| V8 | Furnace flame arithmetic | `data = (1200, 1600)`: `h = 11`; `(1, 1600)`: `h = 2`; `(1600, 1600)`: `h = 14`; `data[1] = 0` uses divisor 200 (E3) |
| V9 | Furnace arrow arithmetic | `(57, 200)`: width 7; `(1, 200)`: 1; `(200, 200)`: 24; either value 0: 0 |
| V10 | Potion slot | cap 1; refuses an item not in `brewing_input` or the tag `brewing_potion_inputs` (potion, splash_potion, lingering_potion, glass_bottle; an empty bottle is accepted); does not check emptiness |
| V11 | Brewing quick-move precedence | fuel before ingredient before potion input; a successful fuel move returns empty at once (E5a) |
| V12 | Brewing arithmetic | bubble table 29, 24, 20, 16, 11, 6, 0 indexed by `(ticks / 2) % 7`; arrow `trunc(28 x (1 - b / B))`; bar `ceilDiv(18 f, T)` clamped to 18 (E6) |
| V13 | Crafter toggle | disabled when empty slot clicked with an empty cursor; enabled when clicked while disabled; packet 0x14 fields (slot id, container id, new state); server refuses a non-empty slot; sound pitch 0.75 on disable, 1.0 on enable |
| V14 | Image sizes (read from the PNG headers in the jar) | textures `furnace.png`, `blast_furnace.png`, `smoker.png`, `brewing_stand.png`, `crafter.png`: 256 x 256; sprites: flame 14 x 14, arrow 24 x 16, bubbles 12 x 29, brew arrow 9 x 28, fuel bar 18 x 4, crafter disabled slot 18 x 18, crafter powered and unpowered indicators 16 x 16 (the blast furnace and smoker `lit_progress.png` 14 x 14 and `burn_progress.png` 24 x 16 headers read the same as the furnace folder) |
| V15 | Crafter result slot | cannot be taken, placed into, quick-moved, or highlighted; server fills it from the recipe match of the 3 x 3 grid after every slot change |
| V16 | Menu type ids | `crafter_3x3` 7, `blast_furnace` 10, `brewing_stand` 11, `furnace` 14, `smoker` 22 |

---

## Open questions

1. **Cursor pick-up path of the furnace result slot.** The click model's pick-up branch (which calls `remove`, then `onTake`) belongs to the sibling document on the shared menu model; here only `remove`, `onQuickCraft` and `onTake` of the slot were read. Whether pick-up with a split click (right click, half the stack) calls `remove` with the half amount (so that `removeCount` counts only the taken half) was not traced: the slot code gives the arithmetic (`min(amount, count)`), the amount passed by the click model is the sibling's topic.
2. **Brewing fuel quick-move skipped tail.** The early return after a successful fuel move leaves the moved-from stack object in place with its count reduced (possibly to 0) and does not call `setByPlayer(empty)` or `setChanged` on the source slot. Whether the synchroniser and the block entity treat a count-0 stack exactly like the empty stack (including when saving the block entity) was inferred, not read. Block entity save and `ContainerHelper` skipping of empty stacks is 31-1.
3. **`ServerPlaceRecipe` for the 1 x 1 furnace grid.** Only the arguments of the call (grid 1 x 1, input slot 0, cleared slots 0 and 2, match test on slot 0) were read here. The detailed fill and the use-max behaviour for one slot follow 13 section 3.8 by inference; a dedicated trace for the furnace family was not made.
4. **Sound event data.** `ui.button.click` is the event name read from the code field `UI_BUTTON_CLICK` (the registry key was not looked up); its file and subtitle are data (14 and the sound documents).
5. **Language strings and tooltip layout.** The English text of `gui.togglable_slot` and the three `toggleRecipes` keys, and the layout of a one-line text tooltip, are data and 12 section 5.8; not repeated here.
6. **`getRecipeFilterName`-related button and tab layout** (positions of the recipe book's tabs for the furnace kinds) follow the generic panel of 13 section 3.9 (13 section 3.9, "The recipe book"; searched there, no furnace-specific pixel layout); the furnace-specific tab icons are in 3.3, but their pixel layout beyond what 13 section 3.9 states was not read.
7. **Feature-flag gating of recipe displays** in `selectMatchingRecipes` (section 2.7) beyond the instance-of test was not read.
8. **Unverified coverage (review note).** Not re-checked against the artifact after the review: the container frame constants of 1.1 (title y = 6, inventory label (8, 72), colour #404040), the 86 px recipe-book shift and the 379 width threshold of 3.1, the `moveItemStackTo` and quick-move loop semantics of 1.3 (`AbstractContainerMenu` itself), the recipe-book hooks of 2.7, and the block-entity data accessor mapping (menu accessors were read, the block entity was not).
