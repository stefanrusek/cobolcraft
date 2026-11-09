# 27. Recipes, recipe book unlocks and the advancement engine

| Item | Value |
|---|---|
| Covers | The recipe ENGINE: recipe types and serializers with exact matching and result rules (crafting shaped, shapeless, transmute and every special crafting recipe; the cooking family, stonecutting, smithing, brewing), recipe lookup and display ids, recipe book categories and grouping, the recipe book unlock rules (`ServerRecipeBook`, `limited_crafting`, the recipe advancements), and the advancement ENGINE (tree, criteria, triggers, requirements, rewards, display, visibility, layout, per-player storage, packets). Recipe rows, advancement rows, loot tables and tags are DATA (extracted by the tool, 22) and are not tabulated |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap`), with no execution; data files read with `unzip -p`, counted with `unzip -Z1 ... | grep -v '/$' | wc -l` |
| Round | RS7 (GAP-5, GAP-5b, GAP-16 engine) |
| Related | 13 §3 (shaped and shapeless matching, menus, result slot, shift-click, ghost recipe, the recipe book UI), 05a/05b/05c (the packets and the `RecipeDisplay`, `SlotDisplay`, advancement wire formats), 45 §3.5 and §8 (the `recipeBook` NBT compound and the `advancements/<uuid>.json` file), 43 §7.4 (leather dye mixing), 31 section 3 (the `DyeColor` table), 31-2 (furnace processing), 26 (loot tables, predicates), 16 (`/recipe`, `/advancement`), 22 (extraction tool) |

Notation: class names in backticks say where a fact was read. "Stack" means an item stack. A recipe id is a
resource key such as `minecraft:oak_planks`.

## 1. Recipe model

### 1.1 Recipe types and serializers

A recipe has a **type** (the menu that runs it) and a **serializer** (its JSON and wire schema). 2042 recipe files
exist in the jar (`data/minecraft/recipe/`, 1763 directly and 279 under `brewing/`).

Recipe types (`RecipeType`, registration order): `crafting`, `smelting`, `blasting`, `smoking`,
`campfire_cooking`, `stonecutting`, `smithing`, `brewing`.

Serializers (`RecipeSerializers`, registration order, which is the numeric id order of the `recipe_serializer`
registry) with the file counts of the `type` field read in this round:

| Id | Serializer | Type | Files | Section |
|---|---|---|---|---|
| 0 | `crafting_shaped` | crafting | 827 | 13 §3.2, 2.3 |
| 1 | `crafting_shapeless` | crafting | 375 | 2.2 |
| 2 | `crafting_dye` | crafting | 6 | 2.5 |
| 3 | `crafting_imbue` | crafting | 1 | 2.9 |
| 4 | `crafting_transmute` | crafting | 33 | 2.4 |
| 5 | `crafting_decorated_pot` | crafting | 1 | 2.10 |
| 6 | `crafting_special_bookcloning` | crafting | 1 | 2.7 |
| 7 | `crafting_special_mapextending` | crafting | 1 | 2.11 |
| 8 | `crafting_special_firework_rocket` | crafting | 1 | 2.12 |
| 9 | `crafting_special_firework_star` | crafting | 1 | 2.12 |
| 10 | `crafting_special_firework_star_fade` | crafting | 1 | 2.12 |
| 11 | `crafting_special_bannerduplicate` | crafting | 16 | 2.6 |
| 12 | `crafting_special_shielddecoration` | crafting | 1 | 2.8 |
| 13 | `crafting_special_repairitem` | crafting | 1 | 2.13 |
| 14 | `smelting` | smelting | 73 | 3.1 |
| 15 | `blasting` | blasting | 25 | 3.1 |
| 16 | `smoking` | smoking | 9 | 3.1 |
| 17 | `campfire_cooking` | campfire_cooking | 9 | 3.1 |
| 18 | `stonecutting` | stonecutting | 351 | 3.2 |
| 19 | `smithing_transform` | smithing | 12 | 3.3 |
| 20 | `brewing` | brewing | 279 | 3.4 |
| 21 | `smithing_trim` | smithing | 18 | 3.3 |

The counts add to 2042. Note what is NOT a recipe type in 26.3: tipped arrows are `crafting_imbue`; map cloning
is a `crafting_transmute` file (`map_cloning`); leather and wolf armour dyeing are six `crafting_dye` files; suspicious
stew, bed, wool, carpet, harness and shulker box dyeing are ordinary shapeless or transmute files whose result
carries data components. There is no separate serializer for any of those.

### 1.2 Common recipe contract (`Recipe`)

Every recipe provides: `matches(input, level)`, `assemble(input)` (the result stack), `isSpecial`,
`showNotification`, `group` (string), `placementInfo`, `display()` (a list of `RecipeDisplay`), and
`recipeBookCategory`.

| Field (JSON) | Default | Notes |
|---|---|---|
| `show_notification` | true | `Recipe.CommonInfo`. Used for the toast flag in 3.5 |
| `group` | `""` (empty) | `Recipe.BookInfo` codec. Recipes with the same non-empty group are one recipe book cell |
| `category` (crafting) | `misc` | `CraftingBookCategory`: `building`, `redstone`, `equipment`, `misc` |
| `category` (cooking) | `misc` | `CookingBookCategory`: `food`, `blocks`, `misc` |

`isSpecial` is true for `CustomRecipe` (every `crafting_special_*` serializer and `crafting_decorated_pot`) and for
`brewing`. `crafting_dye` (`DyeRecipe`) and `crafting_imbue` (`ImbueRecipe`) extend `NormalCraftingRecipe`, not
`CustomRecipe`, so they are NORMAL recipes (read in this round from the class headers and codecs). A special recipe has `show_notification` false, group `""`, category
`misc`, and `NOT_PLACEABLE` placement info (no recipe book requirements). Normal recipes (shaped, shapeless,
transmute, dye, imbue, cooking, stonecutting, smithing) are not special.

`crafting_dye` and `crafting_imbue` codecs embed both `Recipe.CommonInfo` (`show_notification`, default true) and
`CraftingBookInfo` (`group`, `category`, default `misc`) as optional fields; the six dye files carry
`group: dyed_armor`, the tipped arrow file carries none. They have real placement info (dye: `[target, dye]`; imbue:
the 3 x 3 list, centre `source`, eight `material`), enter `known`, appear in Recipe Book Add and are subject to
`limited_crafting`. Only the `crafting_special_*` serializers and `crafting_decorated_pot` (all `CustomRecipe`: group
`""`, category `misc`, `NOT_PLACEABLE`, no notification) read none of these fields. Their `type` file fields are
listed in each section.

### 1.3 Ingredients, results and inputs

- **Ingredient** (`Ingredient`): a non-empty set of items. JSON: an item id, a `#tag`, or an array of ids
  (not mixed with tag references inside the array form; the codec is a holder set). An empty set is an error.
  `test(stack)` is item identity against the set (`stack.is(set)`); count and components are NOT inspected.
- **Optional ingredient** (smithing template and addition): `testOptionalIngredient(optional, stack)` is the
  ingredient's test when present, and "the stack is empty" when absent (inferred from the helper's shape).
- **Result template** (`ItemStackTemplate`): `{id, count?, components?}`; count defaults to 1. `create()` builds the
  stack. Result templates in `crafting_transmute` use a `TransmuteResult` (2.4) whose `id` may be absent.
- **`createWithOriginalComponents(template, original, extraCount)`** (`TransmuteRecipe`): builds a stack with item
  and base components from the template, count = `template.count + extraCount`, and the original stack's component
  PATCH applied (`ItemStackTemplate.apply(count, patch)`). Used by dye, banner, book, map, firework fade, shield
  and transmute results so that names, enchantments, contents and the like carry over (the exact merge order of the
  template's own components and the original patch is not read, see Open question 3).
- **Inputs.** `CraftingInput` (width, height, stack list, `ingredientCount` = number of non-empty stacks): for the
  crafting menus the grid is first TRIMMED to the bounding box of non-empty stacks (`CraftingInput.of` returns
  `ofPositioned(...).input()`); an empty grid gives the empty input. `SingleRecipeInput` (one stack; furnace
  family and stonecutter). `SmithingRecipeInput` (template, base, addition: slots 0, 1, 2). `BrewingInput` (input
  stack, reagent stack).
- **Empty input** never matches: `RecipeMap.getRecipesFor` returns nothing for an empty input.
- **Remaining items** (`CraftingRecipe.getRemainingItems`, default `defaultCraftingReminder`): for every grid slot,
  the item's craft remainder template (`Item.getCraftingRemainder`, an item property from the item registry, 25)
  made into a stack, else empty. The three recipes that override it are 2.6 and 2.7 (they keep one copy of the
  patterned banner and of the source book). Applied by the result slot (13 §3.6).

## 2. Crafting recipes

Lookup is by type `crafting` with a `CraftingInput` (6.1). All the rules below are tested on the TRIMMED input
unless stated.

### 2.1 Fields summary (JSON, besides `type`)

| Serializer | Fields |
|---|---|
| shaped | `pattern`, `key`, `result`, `group`, `category`, `show_notification` (13 §3.1) |
| shapeless | `ingredients` (list of 1 to 9 ingredients), `result`, `group`, `category`, `show_notification` |
| transmute | `input`, `material`, `material_count` (default exactly 1, inferred), `result` (transmute result), `add_material_count_to_result` (boolean, default false (inferred)), `group`, `category`, `show_notification` |
| dye | `target` (ingredient), `dye` (ingredient), `result`, plus the common `show_notification`, `group`, `category` |
| imbue | `source`, `material`, `result`, plus the common `show_notification`, `group`, `category` |
| decorated pot | `back`, `left`, `right`, `front`, `result` |
| book cloning | `source`, `material`, `allowed_generations` (default 0 to 1), `result` |
| map extending | `map`, `material`, `result` |
| firework rocket | `shell`, `fuel`, `star`, `result` |
| firework star | `shapes` (map shape name to ingredient), `trail`, `twinkle`, `fuel`, `dye`, `result` |
| firework star fade | `target`, `dye`, `result` |
| banner duplicate | `banner`, `result` |
| shield decoration | `banner`, `target`, `result` |
| repair item | none |

### 2.2 Shapeless (`ShapelessRecipe`)

Matches iff the count of non-empty stacks equals the ingredient count AND either (one stack, one ingredient: direct
test) or every ingredient can be assigned a distinct stack (bipartite matching, 13 §3.3). Result `result.create()`.
Placement info: the ingredient list (the recipe book requirements). Display: shapeless display with the crafting
table as station (05b `RecipeDisplay` 0).

### 2.3 Shaped (`ShapedRecipe`)

Matching, trimming and mirroring are in 13 §3.2 and are not repeated. Added here: the pattern is at most 3 x 3;
an ingredient set can be given for every key; the display is the shaped display (width, height, one `SlotDisplay` per
cell, empty cells empty) with the crafting table as station; placement info lists one ingredient per non-empty
cell and records which grid positions they occupy (`PlacementInfo.slotsToIngredientIndex`, `-1` = empty slot).
`PlacementInfo.create` returns `NOT_PLACEABLE` when any ingredient is empty.

### 2.4 Transmute (`TransmuteRecipe`) and `TransmuteResult`

`TransmuteResult`: `{id?, count (default 1), components?}`; an absent `id` means "keep the input's item" (the file
`map_cloning` uses `result: {}`). `resolve(inputItem)` fills the item.

Let `min`, `max` be the bounds of `material_count` (`MinMaxBounds.Ints`; the allowed range is 1 to 8; the default is
exactly one; the "full range" constant is 1 to 8).

Match, in order:
1. The non-empty stack count must be in `[min + 1, max + 1]`.
2. Walk the non-empty stacks. A stack passing `input` is the INPUT (a second one fails the match); otherwise a stack
   passing `material` is counted and the count must stay `<= max`; any other stack fails. The `input` test is made
   first, so an item accepted by both is the input.
3. An input stack must exist and the material count must satisfy `material_count`.
4. `resultSize = add_material_count_to_result ? materialCount + result.count : result.count`.
5. If `resultSize` is exactly 1 the recipe additionally requires that the computed result is non-empty and is NOT
   the same item with the same components as the input (so dyeing a shulker box its own colour does not match).

Assemble: `materialCount` = number of stacks passing `material` but not `input` (only counted when
`add_material_count_to_result`); result = `result.resolve(input item)` with `count = template.count + materialCount`
(zero when the flag is false) and the input's component patch carried over.

Display: one shapeless display per count from `min` to `max` (ingredients: the input display then that many material
displays; result count per `resultSize`). Placement: the input ingredient followed by `maxMaterialCount` copies of the material ingredient
(`maxMaterialCount` = the upper bound of `material_count`, 1 to 8), so a default recipe has 1 + 1 ingredients and
`map_cloning` (bound 8) has 1 + 8 = 9.

### 2.5 Dye (`DyeRecipe`, `crafting_dye`)

Match: at least 2 non-empty stacks; walk them: a stack passing `target` is the target (a second target fails); a
stack passing `dye` AND carrying the `dye` data component is a dye; any other stack fails; needs a target and at
least one dye. Assemble: exactly one target and at least one dye, else empty; the dye colours are the `dye`
components (default white) in slot order; the result is `createWithOriginalComponents(result, target)` with
`dyed_color` replaced by `DyedItemColor.applyDyes(existing dyed_color, colours)` (the mixing formula is 43 §7.4;
the result stack count is 1). All six files use `dye: #minecraft:dyes` and `group: dyed_armor`.

### 2.6 Banner duplicate (`BannerDuplicateRecipe`)

One file per banner colour (16): `banner` = that colour's banner item, `result` = the same banner.
Match: exactly 2 non-empty stacks; both must pass `banner` and be banner items of the SAME colour; each has a
layer count (`banner_patterns`); a stack with more than 6 layers fails; exactly one stack has 1 to 6 layers (the
source) and exactly one has 0 layers (the blank).
Assemble: the stack with 1 to 6 layers gives the result via `createWithOriginalComponents(result, source)`; if none
the result is empty.
Remaining items: for each non-empty stack, the item remainder if it has one, else if the stack has at least one
layer a one-count copy of it (the source banner stays in the grid), else empty.

### 2.7 Book cloning (`BookCloningRecipe`)

File: `source` `minecraft:written_book`, `material` `#minecraft:book_cloning_target`, `allowed_generations`
default `0..1` (the codec requires the range to lie within `0..2`).
Match: at least 2 non-empty stacks; a stack passing `source` must have `written_book_content` whose `generation` is
in `allowed_generations` and only one such stack may exist; stacks passing `material` set a flag; any other stack
fails; needs the source and at least one material.
Assemble: `n` = the number of material stacks; exactly one source (a second one gives empty); the content is the
source's `craftCopy()` (generation + 1, other fields kept; `MAX_GENERATION` is 3); result =
`createWithOriginalComponents(result, source, n - 1)` so its count is `result.count + n - 1` (n copies for count 1)
with the new content.
Remaining items: the item remainder if any, else for a stack that has `written_book_content` a one-count copy (the
original is returned).

### 2.8 Shield decoration (`ShieldDecorationRecipe`)

Match: exactly 2 non-empty stacks: one passing `banner` and being a banner item (once), one passing `target` (once)
whose `banner_patterns` layer list is EMPTY (already decorated shields do not match).
Assemble: result = `createWithOriginalComponents(result, shield)` then `banner_patterns` = the banner's layers and
`base_color` = the banner's colour (default white if no banner).

### 2.9 Imbue (`ImbueRecipe`, the tipped arrow)

Match: grid width 3 and height 3 and 9 non-empty stacks; the CENTRE cell (column 1, row 1) passes `source`, the
other eight pass `material`. Assemble: `result.create()` with `potion_contents` copied from the centre stack. File:
`source` `minecraft:lingering_potion`, `material` `minecraft:arrow`, result 8 `tipped_arrow`.
Display: a shaped 3 x 3 display with "any potion" slot displays.

### 2.10 Decorated pot (`DecoratedPotRecipe`)

Match: width 3, height 3, exactly 4 non-empty stacks, and the four cells (column, row) = back (1, 0), left (0, 1),
right (2, 1), front (1, 2) each pass their ingredient (all four use `#minecraft:decorated_pot_ingredients`).
Assemble: the result with `pot_decorations` = the four stacks' items (back, left, right, front). The recipe
`decorated_pot_simple` is an ordinary shaped recipe.

### 2.11 Map extending (`MapExtendingRecipe`)

Its pattern is fixed: row 1 `###`, row 2 `#x#`, row 3 `###` with `#` = `material` (paper) and `x` = `map`
(tag `extendable_maps`); the shaped matching rules of 13 §3.2 apply. Additional match conditions: the grid has a
stack with a `map_id` component, its saved map data exists and has `scale < 4`. Assemble: the result resolved
against the map's item (the file's `result` is `{}`), original components kept, and `map_post_processing` set to
`SCALE` (the map is enlarged later, when the map data processes the marker; that step is not in this document).

### 2.12 Fireworks

All three require at least 2 non-empty stacks and every non-empty stack to be one of the listed kinds.

**Rocket** (`FireworkRocketRecipe`): exactly one `shell` (paper); 1 to 3 `fuel` (gunpowder); any number of `star`
(firework stars). Result (count 3 in the file): `fireworks` component with `flight_duration` = the number of fuel
stacks and `explosions` = the `firework_explosion` component of each star stack that has one, in slot order.

**Star** (`FireworkStarRecipe`): exactly one `fuel` (gunpowder), at least one dye (passes `dye` and has the `dye`
component), at most one `shape` item (a stack matching one of the `shapes` ingredients; at most one such stack),
at most one `twinkle` (glowstone dust) and at most one `trail` (diamond). Needs fuel and at least one dye. Result:
`firework_explosion` with shape = the shape entry whose ingredient matched (default `small_ball` when none),
colours = the `DyeColor.getFireworkColor` of each dye in slot order (default white; table in 31 section 3), no fade
colours, `has_trail` from the trail, `has_twinkle` from the twinkle. The data file's shapes: `burst` (feather),
`creeper` (`#minecraft:skulls`), `large_ball` (fire charge), `star` (gold nugget).

**Fade** (`FireworkStarFadeRecipe`): exactly one `target` (a firework star) and at least one dye. Result: the
target with its `firework_explosion` fade colours set to the dyes' firework colours (the other explosion fields
unchanged; if no explosion component exists the default explosion is updated).

### 2.13 Repair item (`RepairItemRecipe`)

Match: exactly 2 non-empty stacks which `canCombine`: the same item, each of count 1, each with `max_damage` and
`damage` components. Assemble (`M` = the larger `max_damage` of the two; `remA`, `remB` = max damage minus damage
of each):
1. `remaining = remA + remB + floor(M * 5 / 100)` (integer arithmetic: multiply by 5, then divide by 100).
2. The result is a NEW stack of the first item (default components only, none of the inputs' names, trims, etc.)
   with `max_damage` = `M` and `damage` = `max(M - remaining, 0)`.
3. Enchantments: only enchantments with the `curse` tag are carried over, at the higher level of the two inputs
   (non-curse enchantments are dropped).

## 3. The other recipe families

### 3.1 Cooking: smelting, blasting, smoking, campfire cooking (`AbstractCookingRecipe`)

Input: a `SingleRecipeInput`; match is `ingredient.test(stack)`. Fields: `ingredient`, `result`, `experience`
(float, default 0.0), `cookingtime` (int, REQUIRED, no default), `group`, `category` (default `misc`),
`show_notification`. Result: `result.create()`.

| Serializer | Station item | Recipe book category by cooking category |
|---|---|---|
| `smelting` | furnace | food to `furnace_food`, blocks to `furnace_blocks`, misc to `furnace_misc` |
| `blasting` | blast furnace | blocks to `blast_furnace_blocks`; food and misc both to `blast_furnace_misc` |
| `smoking` | smoker | always `smoker_food` |
| `campfire_cooking` | campfire | always `campfire` |

Display: `furnace` display (ingredient, "any fuel" slot display, result, station item, `cookingtime`,
`experience`). Examples read: smelting `raw_iron` to `iron_ingot` `cookingtime` 200, `experience` 0.7, group
`iron_ingot`; smoking and campfire `beef` to `cooked_beef` `experience` 0.35, `cookingtime` 200 and 600.
How a furnace block uses `cookingtime`, the experience and the used-recipe map is 31-2. On taking output,
`AbstractFurnaceBlockEntity` awards and unlocks the used recipes (4.6).

### 3.2 Stonecutting (`StonecutterRecipe`)

Fields: `ingredient`, `result`, no group (always `""`), no book fields; the `show_notification` common field exists.
Match: `ingredient.test(stack)`. Recipe book category `stonecutter`. The stonecutter menu does not use the recipe
book: the server sends the list of (ingredient, result display) pairs once at join (6.3) and the client offers the
entries whose ingredient accepts the input item (`selectByInput`, order = recipe order). Menu rules: choosing
button index `i` is valid when `0 <= i < option count` and different from the current index; changing the input
item kind resets the selection to -1 and clears the result; the result slot holds `recipe.assemble(input)`. Taking
the result: the input stack shrinks by 1, the used recipe is awarded without the limited-crafting check (4.6), and the
selection is re-evaluated.

### 3.3 Smithing

`SmithingRecipeInput` (template, base, addition). Match: template passes (optional ingredient rule 1.3), base
passes `base`, addition passes (optional rule).

- **`smithing_transform`**: fields `template`, `base`, `addition` (template and addition optional), `result`.
  Assemble: `createWithOriginalComponents(result, base)` (the base's components carry over, so enchantments, name and
  damage survive). Example: `netherite_sword_smithing`: template `netherite_upgrade_smithing_template`, base
  `diamond_sword`, addition `#minecraft:netherite_tool_materials`, result `netherite_sword`.
- **`smithing_trim`**: fields `template`, `base`, `addition` (all required), `pattern` (a trim pattern). Assemble
  (`applyTrim`): the addition's `provides_trim_material` component must exist; if the base already has a `trim`
  equal to the new (pattern, material) pair the result is EMPTY (re-applying the same trim is refused); otherwise a
  one-count copy of the base with `trim` set.
- Common: group `""`, recipe book category `smithing` (no book), display = smithing display with the smithing
  table. Taking the result consumes one of each of the three input slots (`SmithingMenu`), and the recipe is
  awarded (4.6). Lookup: the first matching `smithing` recipe in registry order (6.1); no limited-crafting check.

### 3.4 Brewing (`BrewingRecipe`)

Fields `input`, `reagent` (each a `PotionIngredient`: an `item` ingredient plus optional `potion_contents`
predicate; the stack must pass the item ingredient and, when the predicate is present, match it), `output` (a
template, usually with `potion_contents` components). `BrewingInput` is (potion stack, reagent stack). Match: both
pass; `assemble` is `output.create()`. The recipe is special (never unlocked, never in the book, group `""`,
category `crafting_misc`, `NOT_PLACEABLE`, no notification). How a brewing stand applies it per slot, the brew time
and the ingredient item-property sets are in 31-2.

## 4. Recipe book and unlocking

### 4.1 Recipe book categories (`RecipeBookCategories`) and settings types

Thirteen categories, in registration (id) order: `crafting_building_blocks` (0), `crafting_redstone` (1),
`crafting_equipment` (2), `crafting_misc` (3), `furnace_food` (4), `furnace_blocks` (5), `furnace_misc` (6),
`blast_furnace_blocks` (7), `blast_furnace_misc` (8), `smoker_food` (9), `stonecutter` (10), `smithing` (11),
`campfire` (12). The crafting mapping of `CraftingBookCategory` is: building to `crafting_building_blocks`,
redstone to `crafting_redstone`, equipment to `crafting_equipment`, misc to `crafting_misc`
(`CraftingRecipe.recipeBookCategory`). The book TYPES
(`RecipeBookType`, the four settings sets) are `crafting`, `furnace`, `blast_furnace`, `smoker`; the settings per
type are (`open`, `filtering`) and are carried by the settings packet and the player NBT (45 §3.5). Which UI tab a
category belongs to and how the client groups entries is in 13 §3.9.

### 4.2 Display ids, groups and requirements (server side, `RecipeManager.finalizeRecipeLoading`)

Run after every data reload (and once at startup). For every recipe in `RecipeMap.values()` order (the registry
listing order of the recipe registry, Open question 1):
1. If the recipe is not special and its placement info is `NOT_PLACEABLE` (an ingredient is empty or disabled by
   feature flags): log "Recipe {} can't be placed due to empty ingredients and will be ignored" and skip it for
   the property sets.
2. **Group number**: an empty `group` gives no group; otherwise the group string's number is its first-seen index
   in this pass (0-based, one counter shared by ALL recipe types and categories). On the wire the group is the
   index plus one (05b `RecipeDisplayEntry`).
3. **Requirements**: a special recipe has none; any other has `placementInfo.ingredients` (the list used for client
   craftability, 13 §3.9).
4. For each `RecipeDisplay` of `recipe.display()` that is enabled by the world's feature flags: its **display id** =
   the current length of the display list (so ids are 0-based and contiguous), then the entry (display id, display,
   group, category, requirements) is appended. A recipe may have several displays (transmute with several counts) so
   a recipe maps to several display ids.
The lists kept: all displays, display id to (entry, recipe) for `place recipe` and `seen`, recipe key to its
displays (`listDisplaysForRecipe`). The display ids are NOT stable across reloads or data changes; they are only
meaningful within a session (the packets use them, 05c). The stonecutter list and the property sets are in 4.3.

### 4.3 Update Recipes packet and property sets

At join the server sends Update Recipes (05b 0x88) with (a) the recipe property sets and (b) the stonecutter
single-input set. A property set is the union of ingredient item sets for one purpose, from the enabled recipes: ids
`smithing_base`, `smithing_template`, `smithing_addition` (from smithing recipes), `furnace_input`,
`blast_furnace_input`, `smoker_input`, `campfire_input` (from the matching cooking type's `ingredient`),
`brewing_input`, `brewing_reagent` (names read from `RecipePropertySet`; the brewing sets are built from the
brewing recipes). The client uses them to restrict what a slot accepts. The stonecutter set contains, for each
stonecutting recipe whose input ingredient and result display are enabled, the pair (ingredient, result display);
no recipe key is sent.

### 4.4 Server recipe book (`ServerRecipeBook`)

State per player: `known` (set of recipe keys), `highlight` (subset not yet seen), the four-type settings.

| Operation | Rule |
|---|---|
| `addRecipes(recipes, player)` | For each recipe that is NOT known and NOT special: add to `known`, add to `highlight`, collect its display entries, and fire the `recipe_unlocked` trigger for the player and that recipe. Entries are sent in ONE Recipe Book Add (05b 0x4B) with `replace` false when any entry exists. Each entry carries flags: notification (1) = `recipe.showNotification`, highlight (2) = always set. Returns the number of recipes added |
| `removeRecipes(recipes, player)` | For each KNOWN recipe: remove from `known` and `highlight`; collect its display ids; one Recipe Book Remove (0x4C) when any. Returns the number removed. No trigger |
| `removeHighlight(key)` | Called when the client reports a recipe seen (05c Seen Recipe); resolves the display id to its recipe, removes it from `highlight` |
| `setBookSetting(type, open, filtering)` | Called by Change Settings (05c); stores the pair |
| `sendInitialRecipeBook(player)` | Sent at join: Recipe Book Settings (0x4D) with a copy of the settings, then one Recipe Book Add with `replace` true containing the entries of EVERY known recipe (their display entries), each with notification 0 and highlight = the recipe is in `highlight` |
| `loadUntrusted(packed, validity)` | See 45 §3.5: settings replaced, then each listed key in `recipes` and `toBeDisplayed` kept only if it passes the validity test (the recipe manager knows it), others are logged "Tried to load unrecognized recipe: {} removed now." and dropped |
| `copyOverData(old)` | At respawn: the new player's book becomes a copy of the old one's packed state (settings, `known`, `highlight`) |

A special recipe never enters `known` (so a Recipe Book Add never contains one and a brewing, firework, banner,
book, map, repair, shield or decorated pot recipe is never "unlocked"). Dye and imbue recipes are normal and are
unlocked like any other crafting recipe.

### 4.5 `limited_crafting` (game rule)

Game rule `limited_crafting` (registered id `limited_crafting`, category player, boolean, default false; the
legacy display name is "Require recipe for crafting").
- At join the Login packet carries the rule's value (the last-but-one boolean field, 05a) and a Game Event (type
  `LIMITED_CRAFTING` = 12, value 1 or 0) is sent when the rule changes. The client stores the flag in `LocalPlayer`
  and does not read it anywhere else in this artifact.
- Server rule (`RecipeCraftingHolder.setRecipeUsed(player, holder)`, used by the crafting menus only): a recipe is
  usable iff it is special, OR the rule is off, OR the player's recipe book `contains` it. When not usable the result
  slot is left empty (it is not assembled; `AbstractCraftingMenu.slotChangedCraftingGrid` clears slot 0 and sends it).
  The result item must also be enabled by the world's feature flags.
- The smithing table, stonecutter, furnaces and brewing stand never check the rule.
- The recipe book (4.4) is not restricted by the rule: with the rule off, recipes are still unlocked as in 4.6,
  and a player can place from the book only recipes it knows (4.7).

### 4.6 What unlocks a recipe

All paths end in `ServerPlayer.awardRecipes(recipes)` which is `ServerRecipeBook.addRecipes`.
1. **Recipe advancements** (the normal route, 5.9): the 1739 files under `data/minecraft/advancement/recipes/`
   (plus `root.json`) reward `recipes: [id]` when a trigger fires; `AdvancementRewards.grant` calls
   `awardRecipesByKey` (keys not in the manager are ignored).
2. **Crafting or taking a result**: `RecipeCraftingHolder.awardUsedRecipes(player, stacks)` runs when a result is
   taken from a crafting grid, smithing table or stonecutter (`ResultSlot.checkTakeAchievements`, `SmithingMenu`,
   `StonecutterMenu`): if a recipe was recorded as used, fire `recipe_crafted` (with the ingredient stacks), and
   when the recipe is not special award it; the recorded recipe is then cleared.
3. **Furnace family output** (`AbstractFurnaceBlockEntity.awardUsedRecipesAndPopExperience`): when the player takes
   the output, all used recipes are awarded (`awardRecipes`) and `recipe_crafted` is fired for each, then the
   used-recipe counters are cleared (experience: 31-2).
4. **Knowledge book** (`KnowledgeBookItem`): using the item consumes it (unless creative rules apply, not read),
   reads its `recipes` component (a list of recipe keys), awards all valid ones, logs "Invalid recipe: {}" and FAILS
   when any key is unknown, and adds the item-used stat.
5. **`/recipe give|take`** (16 section 6): `give` calls `awardRecipes`, `take` calls `resetRecipes`
   (`removeRecipes`).
6. **Crafter block** (a redstone crafter) fires `recipe_crafted` and `crafter_recipe_crafted`; it does not unlock.
7. **Advancement `recipe_unlocked`** criteria (5.9) turn the advancement done when the recipe becomes known by ANY of
   the routes above, which closes the advancement (its inventory criterion listeners are removed).

Consequence: `/recipe take` removes a recipe from the book, but the recipe advancement stays DONE, so the recipe is
not unlocked again by picking up the item; `/advancement revoke` of the recipe advancement is needed to re-arm it.

### 4.7 Place recipe, seen, settings (server handling)

- **Place Recipe** (05c): ignored when the player is a spectator, the container id differs from the open menu's, or the
  menu is no longer valid; the display id must resolve to a recipe, the player's book must contain that recipe
  (otherwise silently ignored), the open menu must be a recipe book menu, and the recipe must not be "impossible to
  place" (logged). Then the menu fills the grid (13 §3.8) with arguments (use-max, player is creative); if the menu
  reports it could not fill (the PLACE_GHOST_RECIPE outcome) the server sends Place Ghost Recipe (05a 0x40) with the
  container id and the recipe's display.
- **Seen Recipe**: 4.4. **Change Settings**: 4.4.

## 5. Advancements

### 5.1 Data model

Advancements are a data registry (`advancement`, from the data pack, 1866 files in the jar: 1740 under `recipes/`,
`adventure` 47, `husbandry` 31, `nether` 23, `story` 16, `end` 9). One advancement (`Advancement` codec):

| Field | Default | Notes |
|---|---|---|
| `parent` | none | An id. Absent means a ROOT |
| `display` | none | `DisplayInfo`. Absent means the advancement is never shown to the client |
| `rewards` | empty | 5.5 |
| `criteria` | required, non-empty | Map criterion name to `{trigger, conditions}` (5.2) |
| `requirements` | all of `criteria`, one group each | List of groups (AND of ORs) |
| `sends_telemetry_event` | false | Not used by this server logic |

Validation (`Advancement.validate`): `background` is only allowed in a root's display and a root WITH display must
have a background; the criteria list must not be empty ("Advancement criteria cannot be empty"); every requirement
group must be non-empty ("Requirement entry cannot be empty"); every name used in requirements must exist in
`criteria` and every criterion must appear in the requirements. Invalid advancements are logged
("Found validation problems in advancement {}") and the load goes on.

`DisplayInfo`: `icon` (item stack template), `title`, `description` (text components), `background` (optional
texture, only roots), `frame` (`task`, `challenge`, `goal`; default `task`), `show_toast` (default true),
`announce_to_chat` (default true), `hidden` (default false). Frame colours used in text: task GREEN, challenge
DARK_PURPLE, goal GREEN (`AdvancementType.getChatColor`).

### 5.2 Criteria and the trigger registry

A criterion is `{trigger: <id>, conditions: {...}}`; `conditions` is that trigger's instance codec. Every instance
also accepts an optional `player` entity condition (a loot-predicate condition on the player, 26) except where
noted. Registered triggers, in registration order, with the instance fields (codec strings read) and the classes that
call them (`CriteriaTriggers`):

| Id | Instance fields | Fired from |
|---|---|---|
| `impossible` | none | nowhere (never fires) |
| `player_killed_entity` | `entity`, `killing_blow` | `ServerPlayer` (kill) |
| `entity_killed_player` | `entity`, `killing_blow` | `Entity` |
| `enter_block` | `block`, `state` | `ServerPlayer` |
| `inventory_changed` | `slots {occupied, full, empty}`, `items` | menu listener of `ServerPlayer` (5.3) |
| `recipe_unlocked` | `recipes` | `ServerRecipeBook.addRecipes` |
| `player_hurt_entity` | `entity`, `damage` | `LivingEntity`, `Interaction` |
| `entity_hurt_player` | `damage` | `LivingEntity` |
| `enchanted_item` | `item`, `levels` | `EnchantmentMenu` |
| `filled_bucket` | `item` | `BucketItem`, `Bucketable` |
| `brewed_potion` | `potion` | `BrewingStandMenu` potion slot |
| `construct_beacon` | `level` | `BeaconBlockEntity` |
| `used_ender_eye` | `distance` | `EnderEyeItem` |
| `summoned_entity` | `entity` | dragon fight, wither skull, carved pumpkin |
| `bred_animals` | `parent`, `partner`, `child` | `Animal`, turtle, fox breed goals |
| `location` | (player conditions only) | `ServerPlayer` (position update, 5.3) |
| `slept_in_bed` | none | `ServerPlayer` |
| `cured_zombie_villager` | `zombie`, `villager` | `ZombieVillager` |
| `villager_trade` | `villager`, `item` | `AbstractVillager` |
| `item_durability_changed` | `item`, `durability`, `delta` | `ItemStack` |
| `levitation` | `distance`, `duration` | `ServerPlayer`, `LivingEntity` |
| `changed_dimension` | `from`, `to` | `ServerPlayer`, `Entity` |
| `tick` | none | `ServerPlayer`, every tick (5.3) |
| `tame_animal` | `entity` | `TamableAnimal`, `AbstractHorse` |
| `placed_block` | `location` (block and item conditions) | `BlockItem`, `BucketItem`, `FlintAndSteelItem` |
| `consume_item` | `item` | `Consumable` |
| `effects_changed` | `effects`, `source` | `ServerPlayer` |
| `used_totem` | `item` | `LivingEntity` |
| `nether_travel` | `start_position`, `distance` | `ServerPlayer` |
| `fishing_rod_hooked` | `rod`, `entity`, `item` | `FishingHook` |
| `channeled_lightning` | `victims` | `LightningBolt` |
| `shot_crossbow` | `item` | `CrossbowItem` |
| `spear_mobs` | `count` | `KineticWeapon` |
| `killed_by_arrow` | `victims`, `unique_entity_types`, `fired_from_weapon` | `AbstractArrow` |
| `hero_of_the_village` | none | `Raid` (raid won) |
| `voluntary_exile` | none | `Raid` (raid omen) |
| `slide_down_block` | `block`, `state` | `HoneyBlock` |
| `bee_nest_destroyed` | `block`, `state`, `item`, `num_bees_inside` | `BeehiveBlock` |
| `target_hit` | `projectile`, `signal_strength` | `TargetBlock` |
| `item_used_on_block` | `location` | `ServerPlayerGameMode`, `ShearsItem`, `HoneycombItem`, axe-like transformers |
| `default_block_use` | `location` | `ServerPlayerGameMode` |
| `any_block_use` | `location` | `ServerGamePacketListenerImpl` |
| `player_generates_container_loot` | `loot_table` | containers, brushable blocks |
| `thrown_item_picked_up_by_entity` | `item`, `entity` | `LivingEntity` |
| `thrown_item_picked_up_by_player` | `item`, `entity` | `ServerPlayer` |
| `player_interacted_with_entity` | `item`, `entity` | `ServerGamePacketListenerImpl`, `BottleItem` |
| `player_sheared_equipment` | `item`, `entity` | `Mob` and a cube mob |
| `started_riding` | none | `Entity` |
| `lightning_strike` | `lightning`, `bystander` | `LightningBolt` |
| `using_item` | `item` | `ServerPlayer` (every tick while using) |
| `fall_from_height` | `start_position`, `distance` | `ServerPlayer` |
| `ride_entity_in_lava` | `start_position`, `distance` | `ServerPlayer` |
| `kill_mob_near_sculk_catalyst` | `entity`, `killing_blow` | sculk catalyst listener |
| `allay_drop_item_on_block` | `location` | `AllayAi` |
| `avoid_vibration` | none | vibration listeners |
| `recipe_crafted` | `recipes`, `ingredients` | `ServerPlayer.triggerRecipeCrafted` |
| `crafter_recipe_crafted` | `recipes`, `ingredients` | `CrafterBlock` |
| `fall_after_explosion` | `cause`, `start_position`, `distance` | `ServerPlayer` |

(Field names above that read `block`, `item`, `recipes`, `loot_table`, `levels` are given as in the strings read
where those were plural or singular variants, see Open question 6; the rows are data, only the schema matters.)
The exact moment each trigger fires inside its caller is NOT traced here except for `tick`, `location`,
`inventory_changed`, `recipe_unlocked`, `recipe_crafted` and `crafter_recipe_crafted`; the remaining callers belong to
the mechanics documents (17, 18 to 21, 29 to 33) and are listed here only as the call sites (Open question 5).

### 5.3 The trigger engine (`SimpleCriterionTrigger`, `PlayerAdvancements`)

Per player, `PlayerAdvancements` keeps for each trigger type a map from (advancement, criterion name) to the
registered instance (`activeTriggers`).

**Firing** `trigger(player, predicate)`:
1. Take the active instances of this trigger type for the player; if none, return.
2. Build the entity context of the player (for `player` conditions).
3. For each instance in map order: if `predicate(instance)` is false skip it; if the instance has a `player`
   condition and it fails for the context skip it; else collect (advancement, criterion).
4. For each collected pair call `PlayerAdvancements.award(advancement, criterion)` (5.4).

Registration: when an advancement's progress is loaded or created, `registerListeners` adds an instance for each
criterion that is not yet done, and only if the advancement is not yet done. `unregisterListeners` removes the
instances of criteria not done when the advancement completes. Revoking a criterion of a done advancement
re-registers.

Per-trigger predicates read in this round:
- **`recipe_unlocked`**: true iff the unlocked recipe's key is in the instance's `recipes` set.
- **`recipe_crafted` and `crafter_recipe_crafted`**: true iff the crafted recipe key is in the instance's `recipes`
  set, AND every `ingredients` item predicate matches a DISTINCT stack of the ingredient list (each predicate
  consumes the first still-unconsumed stack that matches it, in list order; a predicate with no match fails).
- **`inventory_changed`**: fired by the player's container listener when a slot changes: ignored for a result slot,
  and for slots of the player's own inventory it calls the trigger with the inventory, the changed stack and three
  counts over ALL inventory slots (`full` = slots holding a stack at max stack size or more, `empty` = empty slots,
  `occupied` = non-empty slots). Instance match: the `slots` ranges (`occupied`, `full`, `empty`, each a
  `MinMaxBounds`, default any) must match; then `items` (list of item predicates): empty list matches; one predicate
  matches the changed stack (which must be non-empty); several predicates must each be matched by a distinct
  non-empty inventory stack (each inventory stack removes the predicates it satisfies; success when none remain).
- **`tick`** is fired for the player every server tick of that player (`ServerPlayer.doTick`), before the
  advancement flush (5.7). **`location`** is fired from `ServerPlayer`'s per-tick update path (its gating
  condition was not traced, Open question 5).
- **Item predicate** (`ItemPredicate`): optional `items` (an item set: id, tag or list), `count` bounds (default
  any), and component matchers (`components` exact and `predicates` partial). A stack passes iff all three pass.
  `MinMaxBounds`: a number or an object with `min` and `max`; the error messages `argument.range.empty` and
  `argument.range.swapped` exist for an empty and a swapped range (the matching rule `min <= v <= max` is inferred).
- The other predicate classes (block, fluid, location, entity, damage, distance, enchantment, food, effects, NBT,
  state properties, tag, game type, slots, collection, input, movement, player, sheep, raider, hook, lightning)
  and their field names (read) are listed in 5.8; the full matching rules of those are Open question 7.

### 5.4 Progress, requirements and award

`AdvancementRequirements` is a list of groups; it is satisfied iff every group has at least one done criterion
(a requirement list with no groups is never satisfied). `count(predicate)` is the number of satisfied groups;
`size` the number of groups.

`AdvancementProgress`: map criterion name to `CriterionProgress` (an optional obtained instant: done iff present).
`isDone` = the requirements are satisfied. `update(requirements)` (when attached to an advancement): drop
criteria no longer named, add missing ones as not done. `getPercent`: 0 with no criteria, else satisfied groups /
groups.

`award(advancement, criterion)` returns whether progress changed:
1. Get or create the progress; remember whether it was done.
2. `grantProgress(criterion)`: only if that criterion exists and is not done; it records the current time. If
   nothing changed return false.
3. `unregisterListeners`; add the advancement to the changed set.
4. If it was not done before and is done now: grant the rewards (5.5), and if it has a display and
   `announce_to_chat` and the game rule `show_advancement_messages` is true, broadcast the system message
   `chat.type.advancement.<frame>` (`%s has made the advancement %s`, `%s has reached the goal %s`,
   `%s has completed the challenge %s`) with the player's display name and the advancement's name component
   (the title, coloured by frame, with a hover showing title and description).
5. If it was not done before and is done now: mark the root for a visibility update.
`revoke(advancement, criterion)` is the mirror (`revokeProgress`, re-register listeners, mark for visibility update
when it stops being done).

`checkForAutomaticTriggers` at load: every advancement whose criteria map is empty is awarded immediately with the
empty criterion name and its rewards granted (the validator forbids empty criteria, so this affects only
programmatic data).

### 5.5 Rewards (`AdvancementRewards`)

Fields: `experience` (int, default 0), `loot` (loot tables, default none), `recipes` (recipe ids, default none),
`function` (optional function). `grant(player)` in this order:
1. `giveExperiencePoints(experience)`.
2. Loot: build loot params (this entity = the player, origin = the player's position, parameter set
   `advancement_reward`); for each table in order, roll its items; each item is added to the inventory; if it fits
   play `item.pickup` (player category, volume 0.2, pitch `((r1 - r2) * 0.7 + 1) * 2` with `r1`, `r2` two draws of
   the player's random source `nextFloat`), else drop it (`drop` with the SERVER_ONLY prediction mode), set no pickup
   delay and target the player's uuid.
   If any item was inserted the open container menu broadcasts changes.
3. Recipes: `awardRecipesByKey` (4.6).
4. Function: run it as the player at the server's function manager (the function engine is in 15).

### 5.6 Tree, visibility and layout

**Tree** (`AdvancementTree`): nodes keyed by id; built from all advancements by repeated passes: a node is inserted
when its parent is present (or it has none); passes repeat until no node is added; remaining ones are logged
("Couldn't load advancements: {}"). A root is a node without parent. Reposition (`repositionNodes`): for every root
with a display run the layout below. A node's children are in insertion order.

**Visibility** (`AdvancementVisibilityEvaluator`, depth constant 2). For one root, evaluated recursively with a
rule stack initialised with three `NO_CHANGE` entries:
- Node rule: no display gives HIDE; node done gives SHOW; node `hidden` gives HIDE; otherwise NO_CHANGE.
- A node is visible iff (any child subtree is visible) OR (looking at its own rule, then its parent's, then its
  grandparent's: the first rule that is not NO_CHANGE decides, SHOW means visible, HIDE means hidden, all
  NO_CHANGE means hidden). Every child is evaluated even if an earlier one was visible.
Effect: a node is shown when it is done, or a descendant is shown, or its parent or grandparent is done (and it is
not itself hidden or undisplayed in between); a hidden-flag node shows only when done or when a descendant shows.
Advancements without display (all recipe advancements) are therefore never visible (HIDE at their own level, no
visible children) and never sent.

**Layout** (`TreeNodePosition.run`, a Walker/Buchheim style tidy tree). Only displayed nodes are positioned; a
node without display is skipped and its children attach to the nearest displayed ancestor. Each position has
`x` (an integer depth: the root 0, children parent + 1), `y` (float), and helper values `mod`, `change`, `shift`,
`ancestor`, `thread`, `childIndex` (1 + number of siblings before it).
1. **firstWalk(node)**: a leaf: `y = previousSibling.y + 1` if it has a previous sibling else 0. An inner node:
   run firstWalk on each child in order, calling `apportion(child, defaultAncestor)` after each (the default
   ancestor starts as the first child); then `executeShifts`; `mid = (first child y + last child y) / 2`; with a
   previous sibling: `y = previous.y + 1` and `mod = y - mid`, else `y = mid`.
2. **executeShifts**: scanning children from last to first with running `shift` and `change` (both 0): child
   `y += shift`, `mod += shift`, `change += child.change`, `shift += child.shift + change`.
3. **apportion(v, defaultAncestor)** (no previous sibling: return the default ancestor unchanged): contour
   walk with the four pointers (inner/outer right of the current subtree, inner/outer left of the previous
   siblings), moving all four with `nextOrThread`/`previousOrThread` while both inner contours continue; at each
   step `outerRight.ancestor = v`; `shift = (innerLeft.y + sumInnerLeft) - (innerRight.y + sumInnerRight) + 1`; when
   `shift > 0`: `moveSubtree(getAncestor(innerLeft, v, defaultAncestor), v, shift)` and add `shift` to the right
   sums. Then add each pointer's `mod` into its sum. After the loop, a leftover contour is threaded: when the left
   inner contour continues but the right outer ended, `outerRight.thread = innerLeft.next` and
   `outerRight.mod += sumInnerLeft - sumOuterRight`; symmetrically for the other side. The names and the pairing of
   the four sums are inferred from stack roles (Open question 4).
   `previousOrThread`/`nextOrThread` return the thread if set, else the first or last child, else none.
   `getAncestor(vil, v, default)` returns `vil.ancestor` when it is a sibling of `v` (in `v.parent.children`), else
   `default`.
   `moveSubtree(wl, wr, shift)`: `subtrees = wr.childIndex - wl.childIndex`; when non-zero `wr.change -= shift /
   subtrees` and `wl.change += shift / subtrees`; then `wr.shift += shift`, `wr.y += shift`, `wr.mod += shift`.
4. **secondWalk(m, depth, min)**: `y += m`, `x = depth`, `min = min(min, y)`; recurse into children with
   `m + node.mod`, `depth + 1`.
5. **thirdWalk(delta)** when the minimum is negative: `y += delta` for every node (`delta = -min`), so the topmost
   node is at 0.
6. Each node's final (x, y) is stored on the node and is what the packet carries (05b `PositionedAdvancement`).

### 5.7 Per-player flow and packets

- **Load** (`PlayerAdvancements` constructor, once per player per session; the file is
  `players/advancements/<uuid>.json`, schema and fix-up version in 45 §8): parse the map id to progress (each
  progress `{criteria: {name: "yyyy-MM-dd HH:mm:ss Z"}, done: bool}`), attach it to each advancement that still
  exists (`update`), drop unknown ones; then `checkForAutomaticTriggers`, then `registerListeners` for every
  advancement. A missing file loads nothing; a read or parse error is logged ("Couldn't access player advancements
  in {}", "Couldn't parse player advancements in {}") and treated as empty.
- **Save** when the player's data is saved (`PlayerList` save and removal paths call `PlayerAdvancements.save`): write the
  file (entry order and format: 45 §8).
- **Reload** (data reload): clear listeners, progress, visible set, roots to update and the changed set; set
  `isFirstPacket` true; clear the selected tab; re-load from the file against the new tree.
- **`flushDirty(player, showToasts)`** runs EVERY server tick of the player (`ServerPlayer.doTick`, with
  `showToasts` true), right after the `tick` trigger has fired:
  1. If it is not the first packet and there are no roots to update and no changed progress: do nothing.
  2. For each root to update: run the visibility evaluator (done predicate = progress done, creating progress on
     demand); for a node that becomes visible: add to `visible`, to the `added` set, and if progress exists add it to
     the changed set; a node that stops being visible: remove from `visible`, add its id to `removed`.
  3. For each changed advancement that is visible: put (id, progress) in the packet's progress map. Clear both sets.
  4. If progress, added and removed are ALL empty: send nothing (and `isFirstPacket` stays true).
  5. Else send Update Advancements (05b 0x85) with `reset` = `isFirstPacket`, the added advancements with their
     layout positions, the removed ids, the progress map, and `showAdvancements` = `showToasts`; then set
     `isFirstPacket` false.
- **Opening a tab**: Seen Advancements (05c) with action `OPENED_TAB` and a tab id: if the advancement exists
  `setSelectedTab` stores it when it is a root with a display and sends Select Advancements Tab (05b 0x57) with the id
  (or none when cleared); the other action value of that packet was not read (Open question 13).
- Toast and chat: the toast is client-side (frame text `advancements.toast.task` "Advancement Made!",
  `...goal` "Goal Reached!", `...challenge` "Challenge Complete!"); the chat message is 5.4 step 4.

### 5.8 Predicate field names (schema)

Read from the codec strings of `net.minecraft.advancements.predicates.*` (rules not traced, Open question 7):
`block` (blocks, state, nbt), `fluid` (fluids, state), `location` (position, biomes, structures, dimension, smokey,
light, block, fluid, can_see_sky), `light` (light), `distance` (x, y, z, horizontal, absolute), `damage` (dealt,
taken, source_entity, blocked, type), `damage_source` (tags, direct_entity, source_entity, is_direct), `enchantment`
(enchantments, levels), `food` (level, saturation), `nbt` (carries `SelectedItem` for the held item), `tag`
(id, expected), `input` (forward, backward, left, right, jump, sneak, sprint), `collection` (contains, count, size),
entity flags (is_on_ground, is_on_fire, is_sneaking, is_sprinting, is_swimming, is_flying, is_baby, is_in_water,
is_fall_flying), equipment (head, chest, legs, feet, body, mainhand, offhand), `player` (level, food, gamemode,
stats, recipes, advancements, looking_at, input), movement (x, y, z, speed, horizontal_speed, vertical_speed,
fall_distance), sheep (sheared), raider (has_raid, is_captain), fishing hook (in_open_water), lightning bolt
(blocks_set_on_fire, entity_struck). The `player` predicate's `recipes` entry maps recipe ids to a boolean and passes
when `ServerRecipeBook.contains` equals the boolean for every entry.

### 5.9 The recipe advancement pattern

`data/minecraft/advancement/recipes/root.json` has the single criterion `impossible` (never done) and no display.
Every other recipe advancement (1739) has `parent: minecraft:recipes/root`, no display, a `recipes` reward of one
recipe, a criterion `has_the_recipe` of trigger `recipe_unlocked` for that same recipe, and one or more other
criteria, with ONE requirement group containing all criterion names (an OR). Trigger counts across the 1739 files:
`inventory_changed` 1886 criteria, `recipe_unlocked` 1739, `enter_block` 11, `tick` 1, `impossible` 1 (root).
The group sizes of the first group: 2 names in 1660 files, 3 in 61, 4 in 12, 13 in 4, 17 in 2, 1 in 1.
Examples read: `oak_planks`: criteria `has_logs` (`inventory_changed`, one item predicate `#minecraft:oak_logs`) and
`has_the_recipe`, requirements `[[has_the_recipe, has_logs]]`; `crafting_table`: criteria `unlock_right_away`
(`tick`) and `has_the_recipe`, so the recipe is unlocked on the first tick of every player.
Flow for a normal recipe: the player gets any item of the predicate, `inventory_changed` fires, criterion
`has_logs` completes, the group is satisfied, the advancement is done, `AdvancementRewards.grant` calls
`awardRecipesByKey`, `addRecipes` adds the recipe, fires `recipe_unlocked` (which would complete `has_the_recipe`, a
no-op as the advancement is already done), and sends Recipe Book Add with notification flag from the recipe (true
unless `show_notification` is false). Flow when the recipe is unlocked first by another route (4.6): `recipe_unlocked`
completes `has_the_recipe` and the advancement closes without the item ever being picked up.
Other advancement packs (`story`, `adventure`, `husbandry`, `nether`, `end`) have displays and form the visible tree;
for example `story/root.json` shows no toast and no chat (`show_toast` false, `announce_to_chat` false) and has a
background.

## 6. Recipe lookup in the server (`RecipeManager`)

### 6.1 Order and cache

`getRecipeFor(type, input, level, lastRecipe)`: an empty input gives none; if `lastRecipe` is given and its recipe
matches the input it is returned (the one-entry cache of 13 §3.4); otherwise the FIRST recipe of that type, in the
registry listing order, that matches (`RecipeMap.getRecipesFor`, a multimap by type in listing order). The order
of crafting recipes therefore decides which recipe wins when several match (Open question 1).
`byKey(key)` and `byKeyTyped` fetch by id. The recipe map is rebuilt on every data reload; `getLearnableRecipes` is the
collection used by commands (not traced further).

### 6.2 Feature flags

`finalizeRecipeLoading(flags)` filters ingredients and displays disabled by the world's feature flags; recipes
that become impossible to place are ignored for the property sets (4.2) but remain usable by matching.

### 6.3 Join order

At join (`PlayerList.placeNewPlayer`) the relevant sends are, in order: Login (carries `limited_crafting`), ...,
Update Recipes (4.3), ..., Recipe Book Settings and Recipe Book Add (replace) from `sendInitialRecipeBook`; the
first Update Advancements is sent on the first player tick (5.7).

## 7. Worked examples

1. **Transmute, shulker box dye.** Grid: `white_shulker_box` (with contents) and `black_dye`. Recipe
   `black_shulker_box` (`input #minecraft:shulker_boxes`, `material minecraft:black_dye`, default material count).
   Two non-empty stacks, in range `[2, 2]`; one input, one material; `resultSize` 1; result black shulker box differs
   from the input, so it matches; the result keeps the contents (original patch). With `black_shulker_box` as input
   and `black_dye`: result equals the input, so no match.
2. **Map cloning.** `map_cloning` (`input #clonable_maps`, `material minecraft:map`, `material_count 1..8`,
   `add_material_count_to_result` true, `result {}`): a filled map and 3 empty maps: 4 stacks in `[2, 9]`, 3 materials in
   `1..8`, `resultSize = 3 + 1 = 4`; assemble gives 4 filled maps with the original's `map_id` (component patch),
   count `1 + 3`. Nine stacks (1 + 8) give 9 maps; ten stacks fail the range.
3. **Banner duplicate.** Red banner with 2 layers + blank red banner: both red banners, layer counts 2 and 0: match.
   Result: a red banner with the 2 layers, count 1; remaining items: the patterned banner (a one-count copy) in its
   slot, empty in the other. Red patterned + blue blank: colours differ, no match. A banner with 7 layers: no match.
4. **Repair.** Two pickaxes of the same item with `max_damage` 100 each, damages 60 and 70 (`remA` 40, `remB`
   30): `remaining = 40 + 30 + floor(100 * 5 / 100) = 75`, result damage `max(100 - 75, 0) = 25`. Damages 20 and 30
   (`remA` 80, `remB` 70): `remaining = 155`, damage 0. Enchantments: one with Mending (not a curse) and one with
   Vanishing Curse level 1: the result has only the curse. If both carry Binding Curse levels 1 and 1: the result has
   level 1.
5. **Firework star and rocket.** Grid: gunpowder, red dye, diamond, glowstone dust, gold nugget: fuel 1, dye 1, trail
   1, twinkle 1, shape `star`: a star with shape `star`, colours `[red firework colour]`, `has_trail`, `has_twinkle`.
   Adding a second gunpowder fails. Rocket: paper, gunpowder x2, that star: a rocket stack of 3 (`result.count`),
   `flight_duration` 2, `explosions` `[the star's explosion]`; four gunpowder fails.
6. **Smithing trim twice.** Applying the same pattern and material to armour that already has that exact trim gives an
   empty result (no output); a different material or pattern gives the armour with the new trim.
7. **Limited crafting.** `limited_crafting` true, the player has not unlocked `oak_planks`: placing one oak log in the
   2 x 2 grid leaves the result slot empty. After picking up a log, `has_logs` completes, the recipe is added, and the
   next grid change shows 4 planks. With the rule false the result shows without unlocking; taking the result unlocks
   the recipe (4.6, 2).
8. **Join.** Fresh player, no advancement file: the first tick fires `tick`, `unlock_right_away` completes, the
   `crafting_table` recipe unlocks, Recipe Book Add (replace false, entry flags 3 if `show_notification` true, 2 for
   `crafting_table` whose `show_notification` is false) is sent. A player with an existing book gets, at join, one
   Recipe Book Add with replace true and flags 0 or 2.
9. **Display ids.** Two recipes in listing order: A (group `planks`, one display) and B (no group, a transmute with
   counts 1 to 2 giving two displays): entries have display ids 0 (group number 0, sent as 1), 1 and 2 (no group,
   sent as 0).
10. **Visibility.** Chain story/root (displayed, undone), `mine_stone` (child, displayed, undone), `upgrade_tools`
    (grandchild, displayed, undone) with nothing done: root undone and NO_CHANGE; the root itself is visible only
    because the three-deep rule sees no SHOW: none visible. When the root is done (its criterion the crafting table):
    root SHOW; `mine_stone` sees its parent's SHOW (depth 1): visible; `upgrade_tools` sees grandparent SHOW (depth 2):
    visible. A great-grandchild would not be visible.

## 8. Validation

An implementation is conforming for this document when the following hold.
1. Every crafting recipe type of 1.1 matches and assembles per section 2 for the examples of section 7, including
   the transmute no-op rejection, banner remaining items and the book-cloning counts.
2. The recipe lookup picks the first matching recipe in registry order and rejects the empty input.
3. Display ids are contiguous from 0 in listing order, groups numbers are first-seen indices shared across types,
   and special recipes have no requirements.
4. `addRecipes` ignores special and known recipes, sends one packet, flags notification from `show_notification`,
   highlight always; the join packet has replace true, notification 0 and highlight from the highlight set.
5. `limited_crafting` leaves the crafting result empty for unknown non-special recipes and affects no other menu.
6. A recipe advancement completes by either its item criterion or `recipe_unlocked`, grants the recipe once, and
   stays done after `/recipe take`.
7. The trigger engine awards exactly the (advancement, criterion) pairs whose predicates and `player` conditions pass,
   unregisters listeners on completion and registers them on revoke.
8. Requirements are an AND of ORs; an empty requirement list is never satisfied.
9. Visibility follows 5.6 for the example chain, the packet is sent only when something changed, and `reset` is true
   only for the first packet.
10. The layout for a root with children of 1, 2 and 3 children gives `x` = depth, the topmost `y` is 0, and siblings
    differ by at least 1 in `y`.
11. The advancement file round trip (45 §8) and the recipe book NBT (45 §3.5) keep progress and known recipes across
    a restart; unknown recipe keys are dropped at load.

## Open questions

1. The order of recipes in the registry listing (`HolderLookup.listElements` over the loaded recipe registry), which
   decides display ids, group numbers and the winner among several matching recipes, was not traced to its source
   (data pack load order, the order of the jar entries, alphabetical or hash order). The tool (22) and the registry
   loader (23) must fix an explicit order.
2. The merge order of the template's own components against the original patch in `createWithOriginalComponents`
   (`ItemStackTemplate.apply(count, patch)`) was not read.
3. `material_count` default, the `add_material_count_to_result` default and the `FireworkExplosion` constructor
   argument roles (trail versus twinkle) were read through the constants and field names but not through a raw
   operand trace; they are as stated with "(inferred)" where marked.
4. The `apportion` contour pairing in 5.6 was reconstructed from stack roles; the variable pairing and the returned
   default ancestor in the second branch are inferred. A test with a tree of at least five nodes against the client
   behaviour is needed.
5. Call sites of most triggers (5.2) are listed only by class; the exact conditions and the arguments of each
   `trigger` call (for example the gating of `location`, `using_item` frequency, `fall_from_height` thresholds) were
   not traced.
6. Some instance field names in 5.2 are given as plain words from the codec strings (for example whether
   `block` is `blocks`, `item` is `items`, `loot_table` is `loot_tables`); the data tool must read the exact keys from
   the jar's advancement files. The strings read were: `blocks`, `state`; `items`, `slots`; `loot_tables`;
   `victims`; `recipes`, `ingredients`.
7. The matching rules of the predicate classes other than `ItemPredicate` (5.8), the `MinMaxBounds` bound check,
   data component matchers and the entity predicate sub-types were not traced.
8. `Recipe.getLearnableRecipes` and the `/recipe` command's selection (all or only learnable) are not traced.
9. `KnowledgeBookItem`: whether the item is consumed in creative mode and the order of consume versus validation
   were not read in detail (the stack is consumed first, then a failure returns FAIL).
10. Dyed leather and firework colour tables are in 43 and 31; the `DyedItemColor.applyDyes` formula was not re-derived
    here.
11. The advancement file ordering at save (entries sorted by progress comparison) and the `DataVersion` handling are
    covered by 45 §8, not here.
12. Recalled, not verified: nothing was written from recall in this document; values marked inferred are the only
    ones not read directly. A later review found that sections 4.2 to 4.7, 5.3 to 5.8 (tree build, visibility
    evaluator, layout, flushDirty, rewards, trigger instance field names, the contour pairing in 5.6 and the reward
    sound pitch in 5.5), `RecipeManager.finalizeRecipeLoading`, the `ServerRecipeBook` flags, the `limited_crafting`
    check and the worked examples in section 7 were not traced against bytecode in the first round; treat those as
    unverified until re-tested.
13. The handling of the non-`OPENED_TAB` action of Seen Advancements (05c) and the client-side toast and tab logic
    were not read in this round.
