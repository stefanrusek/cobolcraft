# 31-2 Block entities: processing and redstone containers

| Item | Value |
|---|---|
| Covers | `AbstractFurnaceBlockEntity` with `FurnaceBlockEntity`, `SmokerBlockEntity`, `BlastFurnaceBlockEntity`; `BrewingStandBlockEntity`; `HopperBlockEntity` and the `Hopper` interface; `DispenserBlockEntity` and `DropperBlockEntity`; `CrafterBlockEntity`; `ComparatorBlockEntity`; `DaylightDetectorBlockEntity`; `ChiseledBookShelfBlockEntity`. For each: slots, saved keys, tick logic, the block-side code that drives it, and what is sent to clients. Round RS13 (GAP-8 of `docs/design/README.md`), second of the block entity documents |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data files in the jar (`unzip -p`), with no execution. Class names are cited only to say where a fact was read |
| Siblings | 31-1 (shared block entity model, chests, barrels, shulker boxes) is a sibling round; this document states which of its shared facts it relies on (section 2) and does not repeat them. Documents 3 to 8 of the family cover the other block entities |
| Data versus code | Per the operator decisions, data rows are not tabulated: smelting, blasting, smoking and brewing recipes, fuel burn-time providers, tags, loot tables come from the data pack the extraction tool builds (22, 23). This document specifies their schema, how the block entities interpret them, and the code-defined constants |
| Cross references | 25-1 section 9 (the `cooking_fuel` and `brewing_fuel` components on items), 25-3 (which items carry `cooking_fuel`), 26 (number providers, `match_block`, the loot context), 13 section 3 (recipe data and menus), 24-5 section 7.5 and 7.6 (comparator and daylight detector blocks), 32 (effective sky brightness), 18 section 7.6 (`ExperienceOrb.award`), 41 (item entity), 29 (block updates), 46 (registry ids) |

All "tick" values are game ticks (20 per second). Slot numbers are container slot indexes, not menu slot indexes (menus are RS14).

## 1. Registration summary

Block entity types are registered in `BlockEntityTypes`; registry ids follow the registration order and are in 46. Each type below has exactly one valid block, the block of the same name.

| Type key | Class | Valid block | Container size | Default name (translation key) | Server ticker |
|---|---|---|---|---|---|
| `minecraft:furnace` | `FurnaceBlockEntity` | `furnace` | 3 | `container.furnace` | `AbstractFurnaceBlockEntity.serverTick` (section 3.4) |
| `minecraft:smoker` | `SmokerBlockEntity` | `smoker` | 3 | `container.smoker` | same |
| `minecraft:blast_furnace` | `BlastFurnaceBlockEntity` | `blast_furnace` | 3 | `container.blast_furnace` | same |
| `minecraft:brewing_stand` | `BrewingStandBlockEntity` | `brewing_stand` | 5 | `container.brewing` | `BrewingStandBlockEntity.serverTick` (section 4.3) |
| `minecraft:hopper` | `HopperBlockEntity` | `hopper` | 5 | `container.hopper` | `HopperBlockEntity.pushItemsTick` (section 5.3) |
| `minecraft:dispenser` | `DispenserBlockEntity` | `dispenser` | 9 | `container.dispenser` | none (the block schedules a tick, section 6.3) |
| `minecraft:dropper` | `DropperBlockEntity` | `dropper` | 9 | `container.dropper` | none |
| `minecraft:crafter` | `CrafterBlockEntity` | `crafter` | 9 | `container.crafter` | `CrafterBlockEntity.serverTick` (section 7.3) |
| `minecraft:comparator` | `ComparatorBlockEntity` | `comparator` | none (not a container) | none | none |
| `minecraft:daylight_detector` | `DaylightDetectorBlockEntity` | `daylight_detector` | none | none | none in the entity; the block supplies one (section 9) |
| `minecraft:chiseled_bookshelf` | `ChiseledBookShelfBlockEntity` | `chiseled_bookshelf` | 6 | none (not a menu container) | none |

The type keys were read from `BlockEntityTypeIds`. Block entities of the first nine rows extend `BaseContainerBlockEntity` (custom name, lock); hoppers, dispensers, droppers and crafters extend `RandomizableContainerBlockEntity` (loot table); furnaces and the brewing stand extend `BaseContainerBlockEntity` only.

## 2. Shared facts this document relies on

These belong to the shared model (31-1) and are restated only as far as the numbers below need them. Where 31-1 and this section disagree, 31-1 wins and this section is the one to fix.

1. **Container defaults** (`Container`): the per-slot maximum is 99 (`getMaxStackSize()`), and the maximum for a given stack is `min(99, stack.maxStackSize)` unless a class overrides it. Only `ChiseledBookShelfBlockEntity` (1) overrides it among the classes here. `canPlaceItem` and `canTakeItem` default to true.
2. **`Items` list on disk** (`ContainerHelper.saveAllItems` and `loadAllItems`): the compound key is `Items`, a list of compounds, one per non-empty slot, each holding `Slot` (unsigned byte, the slot index) plus the item stack fields (id, count, components; 00 section 12 and 07). On load a list entry whose slot index is outside the container is ignored. When every slot is empty the key `Items` is not written, except where noted (the chiseled bookshelf always writes it).
3. **Base keys** (`BaseContainerBlockEntity`): `CustomName` (text component, written only when set) and `lock` (the lock code, written only when set). Their item-component twins: `custom_name`, `container_lock`, `container` (an `ItemContainerContents`), used when the block is picked up with its data; all `Items`, `lock` and `CustomName` keys are removed from the tag when the data lives in components.
4. **Loot table fields** (`RandomizableContainer`): `LootTable` (identifier, written when a table is set) and `LootTableSeed` (long, written only when nonzero). On load, when `LootTable` is present the stored `Items` are **not** read (the entity loads the table instead); when absent `Items` are read. Every `getItem`, `setItem`, `removeItem`, `removeItemNoUpdate` and `isEmpty` of a randomizable container first "unpacks" the table: when a table is set and a server exists, the table is cleared, the table is filled into the container with a loot context holding the block center (`Vec3.atCenterOf(pos)`) as `origin`, the container's seed as the random seed, and the player's luck when a player triggered it; a loot-table advancement trigger fires for a server player. The loot engine is 26.
5. **Redstone signal of a container** (`AbstractContainerMenu.getRedstoneSignalFromContainer`, used by every analog output below that says "container signal"): `f` is the sum over the slots of `count / container.getMaxStackSize(stack)` for each non-empty slot, divided by the container size; the signal is `lerpDiscrete(f, 0, 15)`, which is `floor(f * 14)` plus 1 when `f > 0`, so an empty container gives 0, any content gives at least 1, and a completely full container gives 15. A block entity that is not a `Container` gives 0.
6. **Client sync**: none of the classes in this document overrides `getUpdatePacket` (base returns no packet) or `getUpdateTag` (base returns an empty compound). Their data never reaches a client through the block entity data path; clients see only block states and menu synchronisation (section 11).
7. **Dropping an item at a block** (`Containers.dropItemStack(level, x, y, z, stack)`): scatters the stack as entities with random offsets, in chunks whose size is `10 + nextInt(21)`, with velocity components `triangle(0, 0.11485000171139836)`, `triangle(0.2, 0.11485000171139836)`, `triangle(0, 0.11485000171139836)` (constants read; the position formula was not transcribed, Open question 5). Used here for fuel remainders.
8. **`Containers.updateNeighboursAfterDestroy`** is what the container blocks call when removed: it updates comparators around the position (`updateNeighbourForOutputSignal`); the contents are dropped by the block entity's `preRemoveSideEffects` (31-1).

## 3. Furnace, smoker and blast furnace

The three classes differ only in the recipe type they query (`smelting`, `smoking`, `blasting`), the menu they open, the default name and the block they belong to. All logic is in `AbstractFurnaceBlockEntity`.

### 3.1 Slots and faces

| Slot | Role |
|---|---|
| 0 | input (ingredient) |
| 1 | fuel |
| 2 | result |

`getSlotsForFace(face)`: DOWN gives `[2, 1]` (result first, then fuel); UP gives `[0]`; any side gives `[1]`. `canPlaceItemThroughFace(slot, stack, face)` is `canPlaceItem(slot, stack)`. `canTakeItemThroughFace(slot, stack, face)` is true, except for face DOWN and slot 1, where it is true only when the stack is in the item tag `furnace_fuel_bottom_takeable` (data: this jar's tag holds `water_bucket` and `bucket`), so a hopper under a furnace takes the result, then spent buckets from the fuel slot, never real fuel.

`canPlaceItem(slot, stack)`:
- slot 2: always false;
- slot 1: true when the stack has the component `cooking_fuel`, or when it is a `bucket` and the fuel slot does not currently hold a `bucket` (this lets a player place an empty bucket to receive the sponge water);
- slot 0: true for anything.

The furnace container maximum stack size is the default, 99.

### 3.2 Saved data

| Key | Type | Default | Meaning |
|---|---|---|---|
| `Items` | list | empty | slots 0 to 2 (section 2.2) |
| `cooking_time_spent` | int | 0 | `cookingTimer`: progress of the current item |
| `cooking_total_time` | int | 0 | `cookingTotalTime`: ticks needed for the current item |
| `lit_time_remaining` | int | 0 | `litTimeRemaining`: ticks of fire left from the current fuel |
| `lit_total_time` | int | 0 | `litTotalTime`: the burn time the current fuel started with (the flame gauge denominator) |
| `speed_multiplier` | float | 1.0 | `speedMultiplier` of the fuel that is burning |
| `RecipesUsed` | compound | empty | map recipe key to count (section 3.6) |
| `CustomName`, `lock` | | | section 2.3 |

All numbers are read with "int or default" semantics: a missing key gives the default. These key names (with underscores) are the ones of this artifact; older keys are not read by this class (Open question 9). `RecipesUsed` is cleared before loading, then filled from the saved map.

The menu synchronises four ints in this order (`ContainerData`, count 4): 0 `litTimeRemaining`, 1 `litTotalTime`, 2 `cookingTimer`, 3 `cookingTotalTime`.

### 3.3 Fuel and speed come from components, not a table

In this artifact the burn time of a fuel is not a lookup table in the block entity. A fuel item has the component `cooking_fuel` with two fields, a burn-time provider and a speed-multiplier provider (25-1 section 9). The block entity resolves them at the moment a fuel item is consumed:

- **Burn duration** `getBurnDuration(level, stack)`: the burn-time provider resolved against the furnace's loot context, with the fallback 0 when the stack has no `cooking_fuel`.
- **Speed multiplier** `getSpeedMultiplier(level, stack)`: the speed provider resolved the same way, with the fallback 1.0.
- **The loot context** (`BaseContainerBlockEntity.getLootContext`): parameters `block_state` (the furnace's current state), `block_entity` (the entity), `origin` (the block center), `container` (the entity), parameter set `container_process`. Providers are the `context_int_provider` and `context_float_provider` registries (data; 26 section on number providers).
- **What the shipped data does with it** (read from the jar, not tabulated): every fuel burn-time provider is a constant divided by a conditional factor; the condition is the predicate `minecraft:block/fast_cooking`, which is `match_block` for the blocks `smoker` and `blast_furnace`. The factor is 1 for other blocks and 2 for those two. The speed provider `cooking/speed_default` is 2.0 under the same predicate and 1.0 otherwise. Consequences: in a smoker or a blast furnace a fuel burns for half as long and the item cooks at twice the speed. The recipe's own `cookingtime` is the same field for all three furnace kinds (`blasting` and `smoking` recipes in this jar carry the same 200 as the smelting ones for the same item, so a smoker or blast furnace takes 100 ticks per item because of the multiplier). Which items are fuels and their base burn times are data/registry content of 25-3.

The implementer therefore needs: the number-provider engine (26), the `match_block` condition, and the item `cooking_fuel` component, and implements the furnace as a consumer of "burn time" and "speed" integers/floats evaluated per fuel consumption, not per tick.

### 3.4 Cooking recipes (`AbstractCookingRecipe`)

Recipe types `smelting`, `smoking`, `blasting` (and `campfire_cooking`, which is a campfire concern, not here) share one schema (read from the codec): `ingredient` (an ingredient), `result` (an item stack template: `id`, optional `count`, `components`), `experience` (float, default 0), `cookingtime` (int, required), plus the common recipe fields `group` and `category`. Recipes are data (extracted by the tool; 13 section 3.1). Matching is by the single input item (the recipe's ingredient tested against the input stack; the exact `matches` body was not re-read, it is (inferred) from the type `SingleRecipeInput`). Output of a recipe: `assemble(input)` gives the result stack (a fresh stack of the template).

The lookup `getRecipeFor(input, level)` uses a per-block-entity cache of the last recipe key as a hint (`RecipeManager.createCheck`): the previously matched recipe is tried first, otherwise the recipes of that type are searched. When two recipes match the same input, the first found wins, so which is chosen depends on the recipe map's iteration order and the hint (Open question 2).

### 3.5 The server tick (`serverTick`)

Called once per game tick, server side only, for a loaded furnace (`AbstractFurnaceBlock.createFurnaceTicker` returns the ticker only on the server). Let `changed` start false.

1. **Burning down.** If `litTimeRemaining > 0` before the tick: `wasLit = true`, decrement `litTimeRemaining`, and `isLit = (litTimeRemaining > 0)` after the decrement. Otherwise `wasLit = false` and `isLit = false`. (A furnace whose counter reaches 0 on this tick is not lit for the rest of the tick unless step 3 relights it.)
2. `fuelStack` is slot 1, `inputStack` is slot 0; `hasInput` and `hasFuel` are "not empty".
3. If `isLit`, or (`hasFuel` and `hasInput`):
   1. If `hasInput`: find the recipe for slot 0. If **no recipe**, nothing happens in this step (the timer is neither advanced nor reset; Open question 3 notes this because it differs from the "no input" case). If a recipe is found: `result = recipe.assemble(input)`.
      - If `result` is empty or **cannot be output** (`canBurn`, below), `cookingTimer = 0`.
      - Otherwise:
        1. If not `isLit`: `burnDuration = getBurnDuration(fuelStack)`, `speed = getSpeedMultiplier(fuelStack)`; set `litTimeRemaining = litTotalTime = burnDuration` and `speedMultiplier = speed`. If `cookingTotalTime > 0` and `cookingTimer < cookingTotalTime`, rescale the progress to the new speed: `ratio = cookingTimer / cookingTotalTime` (float), `cookingTotalTime = totalCookTime(recipe)`, `cookingTimer = ceil(ratio * cookingTotalTime)`. If `burnDuration > 0`: consume one fuel (section 3.7), `isLit = true`, `changed = true`.
        2. If `isLit`: `cookingTimer += 1`. If `cookingTimer >= cookingTotalTime`: `cookingTimer = 0`, `cookingTotalTime = totalCookTime(recipe)`, move the result (section 3.8), `setRecipeUsed(recipe)` (increment its count in `RecipesUsed`), `changed = true`. Otherwise (still not lit, because the fuel gave burn time 0) `cookingTimer = 0`.
   2. If not `hasInput`: `cookingTimer = 0`.
4. Otherwise (not lit and not (fuel and input)): if `cookingTimer > 0`, `cookingTimer = clamp(cookingTimer - 2, 0, cookingTotalTime)` (progress decays at 2 per tick, `BURN_COOL_SPEED = 2`).
5. If `wasLit != isLit`: `changed = true`; set the block state's `lit` property to `isLit` and write it with `setBlockAndUpdate` (flags 3).
6. If `changed`: `setChanged` (marks the chunk for saving and updates comparators).

`totalCookTime(recipe)` is `ceil(recipe.cookingtime / speedMultiplier)` when `speedMultiplier > 0`, otherwise `recipe.cookingtime`; when there is no recipe the fallback is `BURN_TIME_STANDARD = 200`. `DATA` constants: `NUM_DATA_VALUES = 4`.

`canBurn(maxStack, result)`: slot 2 empty gives true; slot 2 not the same item with the same components as `result` gives false; otherwise true when `slot2.count + result.count <= min(maxStack, result.maxStackSize)` where `maxStack` is the container maximum (99).

### 3.6 `RecipesUsed` and experience

`recipesUsed` is a map from recipe key to a count of how many items that recipe has produced since the last collection. It is saved as a compound whose keys are recipe identifiers (the codec is `unboundedMap(Recipe.KEY_CODEC, INT)`; the key string form is (inferred) the identifier of the recipe, Open question 10).

`getRecipesToAwardAndPopExperience(level, position)`: for each (key, count) entry, in the map's own order, look the recipe up by key; when present add it to the returned list and call `createExperience(level, position, count, recipe.experience)`. The entry is not removed here.

`createExperience(level, position, count, xp)`: `total = count * xp` (float). `whole = floor(total)`, `frac = total - floor(total)`. When `frac != 0` and a `nextFloat()` of the level random source is `< frac`, `whole += 1`. Then `ExperienceOrb.award(level, position, whole)` (18 section 7.6).

Two callers: (a) the result slot, when a player takes items: `awardUsedRecipesAndPopExperience(player)` computes the list at the player's position, awards the recipes to the player (recipe book), triggers the recipe-crafted advancement trigger with the furnace's current items for each recipe, then clears `recipesUsed`; (b) `preRemoveSideEffects` (block removed): computes the list at the block center and pops the experience (the map is not cleared, the entity is going away). The hopper never triggers experience. `awardUsedRecipes(player, items)` itself does nothing.

### 3.7 Consuming a fuel item

1. Take the item's crafting remainder, if any (for a lava bucket, an empty bucket; the remainder is data of the item registry, 25).
2. Remember the stack, shrink it by 1.
3. If there is a remainder: when the fuel stack became empty, the remainder stack replaces it in slot 1; otherwise the remainder is dropped as an item at the block position (`Containers.dropItemStack` at x, y, z of the position).
4. Write slot 1.

### 3.8 Moving the result

Slot 2 empty: it becomes a copy of the result. Otherwise it grows by `result.count`. Then, as a special case, when the **input** was a `wet_sponge` and the fuel slot is non-empty and is a `bucket`, slot 1 becomes a `water_bucket`. Finally the input stack shrinks by 1.

### 3.9 Putting an item into the input slot

`setItem(slot, stack)`: the stack is stored (its size is limited to the container maximum for that stack). When the slot is 0 and the new stack is not "the same item with the same components" as the one that was there (an empty new stack counts as different), then `cookingTotalTime` becomes `totalCookTime` of the recipe that matches the new input (200 when none; uses the speed multiplier stored from the last fuel), `cookingTimer` becomes 0, and the entity is marked changed. Items inserted by hoppers or menus go through this method.

### 3.10 Block side

`AbstractFurnaceBlock` (24-7): `facing`, `lit`; ticker only on the server; the analog output is the container signal (section 2.5); use opens the menu on the server (`openContainer`); removal calls `updateNeighboursAfterDestroy`. The light level 13 when lit and the particles are in 24-7.

## 4. Brewing stand

### 4.1 Slots and faces

| Slot | Role |
|---|---|
| 0, 1, 2 | the three potion (bottle) positions |
| 3 | ingredient (reagent) |
| 4 | fuel |

`getSlotsForFace`: UP gives `[3]`; DOWN gives `[0, 1, 2, 3]`; any side gives `[0, 1, 2, 4]`. `canPlaceItemThroughFace` is `canPlaceItem`. `canTakeItemThroughFace(slot, ...)`: for slot 3 true only when the stack is a `glass_bottle`; true otherwise. (Below, the DOWN list is `[0, 1, 2, 3]`, so a hopper below takes the potions and an empty bottle sitting in the ingredient slot, never the fuel.)

`canPlaceItem(slot, stack)`:
- slot 4: the stack has the component `brewing_fuel` (only `blaze_powder` in the item registry, 25-5);
- when the entity has no level: false;
- slot 3: the stack is accepted by the recipe property set `brewing_reagent` (a set computed from all brewing recipes' `reagent` ingredients, 13 and section 4.4);
- slots 0 to 2: the stack is a "potion input" (`PotionIngredient.isPotionInput`: accepted by the property set `brewing_input`, or in the item tag `brewing_potion_inputs`) and the slot is currently empty.

### 4.2 Saved data

| Key | Type | Default | Meaning |
|---|---|---|---|
| `Items` | list | empty | slots 0 to 4 |
| `BrewTime` | int | 0 | `brewTime`: ticks left in the current brew (0 when idle) |
| `total_brew_time` | int | 400 | `totalBrewTime` |
| `Fuel` | int | 0 | `fuel`: remaining brews from the current fuel item |
| `total_fuel` | int | 20 | `totalFuel` (the gauge denominator) |
| `speed_multiplier` | float | 1.0 | brew speed of the fuel in use |
| `CustomName`, `lock` | | | section 2.3 |

On load, when `BrewTime > 0` the remembered `ingredient` item becomes the item currently in slot 3 (it is not saved). The menu synchronises four ints in this order: 0 `brewTime`, 1 `fuel`, 2 `totalBrewTime`, 3 `totalFuel`. `BREWING_TIME_SECONDS = 20`, so a normal brew is `400` ticks.

### 4.3 Fuel components

`brewing_fuel` has two fields (`uses` provider, `speed_multiplier` provider) and is resolved like the furnace fuel with the same loot context (section 3.3). In the shipped data `uses_default` is 20 and `brewing/speed_default` is 1.0 (read; the single fuel item is `blaze_powder`). Resolution fallbacks: uses 0, speed 1.0.

### 4.4 Brewing recipes

A `brewing` recipe (data, in `recipe/brewing/`, read from one example) has `input` (a potion ingredient: `item` plus an optional `potion_contents` condition such as `{"potions": "minecraft:awkward"}`), `reagent` (a potion ingredient: normally just `item`) and `output` (an item stack template with components, for example `potion_contents`). `matches(BrewingInput(potion, reagent))` is `input.test(potion) and reagent.test(reagent)`. The property sets `brewing_input` and `brewing_reagent` are built by the recipe manager from all brewing recipes (the inputs' items and the reagents) and answer "could this stack ever take part".

### 4.5 The server tick (`serverTick`)

Server side only. Each tick:

1. **Load fuel.** Let `fuelStack` be slot 4 and `comp` its `brewing_fuel` component. If `fuel <= 0` and `comp` exists: `fuel = uses(comp)`, `totalFuel = fuel`, `speedMultiplier = speed(comp)`; shrink the fuel stack by 1; if the item has a crafting remainder, it replaces the empty slot or is dropped at the block position (as in 3.7); mark changed.
2. `brewable = isBrewable()`: slot 3 is non-empty, slot 3 is accepted by `brewing_reagent`, and at least one of slots 0 to 2 is non-empty and has a recipe with the slot-3 stack as reagent (the first such slot decides, empty potion slots are skipped).
3. `brewing = brewTime > 0`.
4. If `brewing`: decrement `brewTime`; `finished = (brewTime == 0)`. If `finished` and `brewable`, run `doBrew` (4.6). Otherwise, if not `brewable` or slot 3's item is no longer the remembered `ingredient`, set `brewTime = 0`. Mark changed.
5. Else if `brewable` and `fuel > 0`: `speed = (speedMultiplier > 0) ? speedMultiplier : 1`; `fuel -= 1`; `brewTime = ceil(400 / speed)`; `totalBrewTime = brewTime`; remember `ingredient` = the item of slot 3; mark changed.
6. **Bottle states.** Compute the three flags "slot i non-empty". If they differ from the last remembered flags, remember them and set the block's `has_bottle_0`, `has_bottle_1`, `has_bottle_2` properties from them, written with flags 2 (no neighbour update); if the block is not a brewing stand, stop.

### 4.6 `doBrew`

1. For each potion slot `i` in 0 to 2: build `BrewingInput(slot i, slot 3)`; when a recipe matches, slot `i` becomes the recipe's assembled output, otherwise it is unchanged.
2. The ingredient: take its crafting remainder, shrink slot 3 by 1; if there is a remainder, it replaces an emptied slot or is dropped at the block position.
3. Fire level event 1035 at the position (the brew-complete sound, 42/audio documents).

Because `brewTime` reaches 0 only after the decrement, the brew lands on the tick where the counter hits 0, `totalBrewTime` ticks after the start tick (example in section 12).

### 4.7 Block side

`BrewingStandBlock` (24-4): the ticker is server only and is `serverTick`; `has_bottle_0..2`; the comparator reads the container signal. Hoppers interact through the face tables of 4.1.

## 5. Hopper

### 5.1 Data

| Item | Value |
|---|---|
| Container size | 5 (`HOPPER_CONTAINER_SIZE`); the slot order is the transfer order |
| Per-slot maximum | the default (99) bounded by the item's own maximum |
| Saved keys | `Items` (or `LootTable` and `LootTableSeed`, section 2.4), `TransferCooldown` (int, default -1) |
| `MOVE_ITEM_SPEED` | 8 |
| Facing | cached from the block state property `facing` at construction and on `setBlockState` |

The `Hopper` interface: `getLevelX/Y/Z` (the hopper's own centre: block position + 0.5 on each axis for the block entity), `isGridAligned` (true for the block entity; the hopper minecart returns false, 21/45), and `getSuckAabb` (the `SUCK_AABB`).

`SUCK_AABB` is the box from `Block.column(16, 11, 32)` read in sixteenths: x from 0 to 1, y from 11/16 = 0.6875 to 2.0, z from 0 to 1, in block-local coordinates. It is the "pickup column": the top 5/16 of the hopper block plus the whole block above.

### 5.2 Cooldown

`cooldownTime` (saved as `TransferCooldown`): -1 on a fresh hopper. "On cooldown" is `cooldownTime > 0`. "On custom cooldown" is `cooldownTime > 8`. `tickedGameTime` (a long, not saved) records the game time of the hopper's last tick.

### 5.3 The tick (`pushItemsTick`) and `tryMoveItems`

Server only (`HopperBlock.getTicker` returns null on the client).

1. `cooldownTime -= 1`; `tickedGameTime = level game time`.
2. If not on cooldown: `cooldownTime = 0`, then `tryMoveItems(supplier = suckInItems)`.

`tryMoveItems(supplier)`: nothing on the client. If the hopper is not on cooldown and the block's `enabled` property is true:
1. `moved = false`.
2. If the hopper has any item: `moved = ejectItems()` (5.4).
3. If the hopper is not full (some slot empty or below its stack maximum): `moved = moved OR supplier()`. (`ejectItems` has already run; the supplier runs regardless of its result.)
4. If `moved`: `cooldownTime = 8`, mark the block entity changed, return true.
Otherwise return false (the cooldown stays at 0, so an idle hopper retries every tick).

`enabled` is a block state property set by `HopperBlock.checkPoweredState`: `enabled = NOT level.hasNeighborSignal(pos)`, written with flags 2 when it differs, on `onPlace` (when the block is new) and on every `neighborChanged`.

### 5.4 Pushing (`ejectItems`)

1. `target = getContainerAt(pos relative to facing)` (5.7). If none: false.
2. `side = facing.getOpposite()`. If the target is "full" for that side (every slot in `getSlots(target, side)` has `count >= stack maximum`): false.
3. For each hopper slot in order 0 to 4: skip empty slots; remember the count; `leftover = addItem(hopper, target, hopper.removeItem(slot, 1), side)`. If `leftover` is empty: mark the target container changed and return true. Otherwise restore the count on the original stack, and when the count was 1 write the stack back into the slot (removing the single item had taken the whole stack out); continue with the next slot.
4. Return false.

So a hopper moves **one item per transfer**, from the first slot that the target accepts.

### 5.5 Pulling (`suckInItems`)

1. `abovePos = block containing (levelX, levelY + 1, levelZ)`; `aboveState` its state.
2. `source = getSourceContainer(...)`: `getContainerAt(level, abovePos, aboveState, levelX, levelY + 1, levelZ)` (5.7).
3. If a source container exists: for each slot in `getSlots(source, DOWN)` (in that order), `tryTakeInItemFromSlot`; the first success returns true; none gives false. **Item entities are not considered when there is a container above.**
4. Otherwise (no container above): the item pickup is allowed unless the hopper is grid aligned and the block above has a full-block collision shape and is not in the block tag `does_not_block_hoppers` (data; the jar's tag holds the `beehives` block tag). When allowed: for each `ItemEntity` returned by `getItemsAtAndAbove` (all alive item entities intersecting `SUCK_AABB` translated by the block position (levelX - 0.5, levelY - 0.5, levelZ - 0.5); entities in the order the world's entity query returns them), `addItem(hopper, entity)` (5.6); the first that returns true makes `suckInItems` return true. If blocked or none: false.

`tryTakeInItemFromSlot(hopper, source, slot, DOWN)`: the stack in `slot`; if non-empty and `canTakeItemFromContainer`: remember the count; `remaining = addItem(source, hopper, source.removeItem(slot, 1), null)`; if the remaining stack is empty: mark the source changed, return true; otherwise restore the count on the source stack, and when the count was 1 write it back into the slot; return false.

`canTakeItemFromContainer(hopper, source, stack, slot, DOWN)`: `source.canTakeItem(hopper, slot, stack)` AND, when the source is a `WorldlyContainer`, `canTakeItemThroughFace(slot, stack, DOWN)`. (`canTakeItem` is the generic `Container` hook, true by default; the chiseled bookshelf overrides it, section 10.)

### 5.6 `addItem` (moving stacks into a container)

- `addItem(itemEntity into hopper)`: copy the entity's stack; `rest = addItem(null, hopper, copy, null)`; if `rest` is empty: set the entity's stack to empty, discard the entity, return true; else set the entity's stack to `rest` and return false (so a partial pickup does not start a cooldown).
- `addItem(source, dest, stack, direction)`: when `dest` is a `WorldlyContainer` and `direction != null`: for each slot in `dest.getSlotsForFace(direction)` in order, while the stack is non-empty, `stack = tryMoveInItem(...)`. Otherwise: for each slot `0 .. size-1` in order, the same. Returns the remainder.
- `tryMoveInItem(source, dest, stack, slot, direction)`: let `current = dest.getItem(slot)`. If `canPlaceItemInContainer(dest, stack, slot, direction)` (the destination's `canPlaceItem(slot, stack)` AND, for a worldly destination, `canPlaceItemThroughFace(slot, stack, direction)`):
  - if `current` is empty: `dest.setItem(slot, stack)`; the stack becomes empty; `moved = true`;
  - else if `canMergeItems(current, stack)` (`current.count <= current.maxStackSize` and same item with same components): `space = stack.maxStackSize - current.count`; `n = min(stack.count, space)`; `stack.shrink(n)`; `current.grow(n)`; `moved = n > 0`.
  - If `moved`: when `dest` was **empty before** the move and is a `HopperBlockEntity` that is not on custom cooldown (`cooldownTime <= 8`): `offset = 1` when the source is also a `HopperBlockEntity` and `dest.tickedGameTime >= source.tickedGameTime`, else 0; `dest.cooldownTime = 8 - offset`. Then `dest.setChanged()`.
  - Returns the (possibly reduced) stack.

### 5.7 Which container is at a position (`getContainerAt`)

Given a block position (with centre coordinates `(x + 0.5, y + 0.5, z + 0.5)` when called by position only):
1. **Block container.** If the block implements `WorldlyContainerHolder` (composters, 24-7), use `holder.getContainer(state, level, pos)`. Otherwise, if the state has a block entity and the entity is a `Container`: for a `ChestBlockEntity` whose block is a `ChestBlock`, the (possibly double) chest container (`ChestBlock.getContainer(block, state, level, pos, true)`, 31-1); otherwise the entity itself. No block container gives null.
2. **Entity container** (only when no block container): all entities in the box centre ± 0.5 on each axis that satisfy `CONTAINER_ENTITY_SELECTOR` (alive and a `Container`; chest minecarts, hopper minecarts, ...). When any exist, one is chosen with `level.getRandom().nextInt(count)`; none gives null.

For the pull from above, the entity box centre is the point (levelX, levelY + 1, levelZ), the same as the block above's centre.

### 5.8 Hopper and item entities inside the block (`entityInside`)

`HopperBlock.entityInside` forwards to `HopperBlockEntity.entityInside`: for an `ItemEntity` whose stack is non-empty, whose bounding box translated by minus the block position intersects `SUCK_AABB`: call `tryMoveItems` with the supplier `addItem(hopper, thatEntity)`. This is an additional trigger, subject to the same cooldown and `enabled` rules as the tick, and the `ejectItems` step also runs.

### 5.9 Block side

`HopperBlock` (24-7): `facing` (down or horizontal) and `enabled`; analog output is the container signal; use opens the menu (stat `inspect_hopper`); removal calls `updateNeighboursAfterDestroy`.

## 6. Dispenser and dropper

### 6.1 Data

| Item | Value |
|---|---|
| Container size | 9 (`CONTAINER_SIZE`) |
| Saved keys | `Items` or `LootTable`/`LootTableSeed` (section 2.4), `CustomName`, `lock` |
| Other state | none on the entity; `triggered` and `facing` are block state properties |

`DropperBlockEntity` is a `DispenserBlockEntity` with the type `dropper` and the name key `container.dropper`.

### 6.2 Entity methods

- `getRandomSlot(random)`: unpack the loot table; scan slots 0 to 8 in order; for each non-empty slot with running count `n` (starting at 1, incremented after each non-empty slot), pick it when `random.nextInt(n) == 0`. This is uniform reservoir selection among the non-empty slots; the result is -1 when all slots are empty. One `nextInt` call per non-empty slot, in slot order.
- `insertItem(stack)` (used by dispense behaviours that return an item to the dispenser): for each slot in order: skip a non-empty slot whose stack is not the same item with the same components; `n = min(stack.count, maxStackSizeFor(stack) - slot.count)`; if `n > 0`: when the slot is empty it receives `stack.split(n)`, otherwise `stack.shrink(n)` and `slot.grow(n)`; stop when the stack is empty. Returns the remainder.

### 6.3 Block side (the triggering)

`DispenserBlock.neighborChanged` (the dropper inherits it): `powered = hasNeighborSignal(pos) OR hasNeighborSignal(pos.above())` (the block is quasi-connected, as the piston is). With the state's `triggered`:
- `powered` and not `triggered`: schedule a block tick for this position in 4 ticks and write `triggered = true` with flags 2;
- not `powered` and `triggered`: write `triggered = false` with flags 2.

The scheduled `tick` calls `dispenseFrom`.

### 6.4 `dispenseFrom` (dispenser)

1. Get the block entity; if it is missing, log and stop.
2. `slot = getRandomSlot(level.getRandom())`.
3. If `slot < 0`: level event 1001 (the dispense-failure click) at the position, plus the game event `block_activate`. Stop.
4. Otherwise `stack = item in slot`. Choose the behaviour (`getDispenseMethod`): when the item is not enabled by the active feature flags, the default behaviour; otherwise the behaviour registered for the item (`DispenserBlock.registerBehavior`, filled by `DispenseItemBehavior.bootStrap`); if none, the **default choice**: an item with the `equippable` component gets the equipment behaviour; an item in the item tag `sulfur_cube_swallowable` gets the sulfur-cube behaviour; an item with the `entity_data` component (spawn eggs) gets the spawn-egg behaviour; anything else gets the default behaviour. A behaviour equal to `NOOP` leaves the slot untouched.
5. `slot := behaviour.dispense(source, stack)` (the returned stack replaces the slot).

The table of registered behaviours (bucket, bone meal, TNT, boats, shears, projectiles, ...) is code of `DispenseItemBehavior`; it was not read in this round and is a gap for the block-behaviour rounds (Open question 6). 29 §"DirectionalPlaceContext" already notes its dependency.

### 6.5 The default behaviour (`DefaultDispenseItemBehavior`)

`dispense(source, stack)`: `result = execute(source, stack)`; then level event 1000 (the dispense click) at the position; then level event 2000 with data the block's facing `get3DDataValue()` (the smoke animation); return `result`.

`execute`: `facing` of the block; `position = getDispensePosition(source)` = block centre plus 0.7 in the facing direction (`DispenserBlock.getDispensePosition(source)` with offset 0.7); `one = stack.split(1)`; `spawnItem(level, one, accuracy 6, facing, position)`; return the reduced stack.

`spawnItem(level, stack, accuracy, facing, position)`:
1. `y -= 0.125` when the facing axis is vertical, otherwise `y -= 0.15625`.
2. Create an `ItemEntity` at `(x, y, z)` holding the stack.
3. `speed = random.nextDouble() * 0.1 + 0.2`.
4. Motion: `vx = triangle(stepX * speed, 0.0172275 * accuracy)`, `vy = triangle(0.2, 0.0172275 * accuracy)`, `vz = triangle(stepZ * speed, 0.0172275 * accuracy)`, in the order x, y, z, where `triangle(c, d) = c + d * (nextDouble() - nextDouble())`. Random order: `speed` first, then the six `nextDouble` calls of the three triangles in order.
5. Add the entity to the level.

`consumeWithRemainder(source, stack, remainder)`: shrink the stack by 1; if it is now empty return `remainder`; otherwise `addToInventoryOrDispense(remainder)`: `insertItem` into the dispenser; any leftover is spawned with `spawnItem` at the dispense position with accuracy 6; then the default click and animation events. (Used by behaviours such as buckets.)

### 6.6 Dropper

`DropperBlock.dispenseFrom`: the same trigger (6.3) and the same `getRandomSlot`. If `slot < 0`: level event 1001 (no game event was read). Otherwise `stack = item in slot`; the front container `target = HopperBlockEntity.getContainerAt(pos relative to the block's facing)`:
- no container in front: `result = DISPENSE_BEHAVIOUR.dispense(source, stack)` where `DISPENSE_BEHAVIOUR` is the default behaviour of 6.5 (the dropper does not look up registered behaviours);
- a container in front: `rest = HopperBlockEntity.addItem(dropper, target, stack.copyWithCount(1), facing.getOpposite())`; `result` is a copy of the stack with 1 less if `rest` is empty (the item was moved), otherwise an unchanged copy.
The slot then receives `result`.

## 7. Crafter

### 7.1 Slots and data

| Item | Value |
|---|---|
| Size | 9, in a 3x3 grid; `getWidth` and `getHeight` are 3; the slot index is `row * 3 + column` (it is a `CraftingContainer`, so recipe matching reads it as a 3x3 `CraftingInput`) |
| `crafting_ticks_remaining` | int, default 0: the length of the crafting animation still to run |
| `triggered` | int, default 0: 1 when the crafter received its redstone pulse (stored in the entity, mirroring the block's `triggered`) |
| `disabled_slots` | int array, default empty: the indexes of disabled slots |
| Saved keys | `crafting_ticks_remaining`, `Items` or `LootTable`/`LootTableSeed`, `disabled_slots`, `triggered`, `CustomName`, `lock` |

The menu synchronises ten ints (`NUM_DATA = 10`): indexes 0 to 8 are the slot states (0 enabled = `SLOT_ENABLED`, 1 disabled = `SLOT_DISABLED`), index 9 (`DATA_TRIGGERED`) is `triggered`.

### 7.2 Slot rules

- `slotCanBeDisabled(slot)`: `0 <= slot < 9` and the slot is empty.
- `setSlotState(slot, enabled)`: ignored unless `slotCanBeDisabled(slot)` (so only empty slots change state, in both directions); otherwise slot state = 0 when `enabled`, else 1; marks changed.
- `isSlotDisabled(slot)`: in range and state 1.
- `canPlaceItem(slot, stack)`: false when the slot is disabled. Otherwise, with `n` the stack already in the slot: false when `n.count >= n.maxStackSize`; true when the slot is empty; otherwise true only when no later enabled slot holds a **smaller** stack of the same item with the same components (items are distributed evenly: the hopper fills the emptier of equal slots first; the check is `smallerStackExist(count, stack, slot)`, scanning slots above `slot` in order, skipping disabled slots).
- `setItem(slot, stack)`: if the slot is disabled it is re-enabled first (`setSlotState(slot, true)`), then the regular store.
- `getRedstoneSignal()`: the number of slots that are **non-empty or disabled**, from 0 to 9.
- Loading: all slot states are first set to enabled; then each index in `disabled_slots` is disabled when `slotCanBeDisabled` (so a disabled slot that holds an item in the save is left enabled); `triggered` is read as an int.
- Saving: `disabled_slots` is the list of the disabled indexes (an empty array is written when none); `triggered` is the int.

### 7.3 Ticker

`CrafterBlockEntity.serverTick`: `r = craftingTicksRemaining - 1`; if `r < 0` stop (nothing is stored); store `r`; when `r == 0`, set the block property `crafting` to false with `setBlockAndUpdate`.

### 7.4 Block side (`CrafterBlock`)

Properties: `orientation` (the `FrontAndTop` of 24, front is the output face), `triggered`, `crafting`. Constants read: `MAX_CRAFTING_TICKS = 6`, `CRAFTING_TICK_DELAY = 4`, a recipe cache of 10 entries, advancement trigger diameter 17.

1. `neighborChanged`: `powered = hasNeighborSignal(pos)`; with the block's `triggered` and the entity existing: powered and not triggered: schedule a tick in 4 ticks, write `triggered = true` (flags 2) and set the entity's triggered to true; not powered and triggered: write `triggered = false` and `crafting = false` (flags 2) and set the entity's triggered to false. `setPlacedBy` schedules a tick in 4 when the state is triggered. `getStateForPlacement` sets `triggered` from the current neighbour signal.
2. `tick` runs `dispenseFrom`:
   1. input = the 3x3 `CraftingInput` of the entity; `getPotentialResults` looks up a crafting recipe (the cache `RecipeCache`, 13 section 3.2 to 3.4).
   2. No recipe: level event 1050 (the failure click) and stop. The recipe's assembled result empty: also 1050 and stop.
   3. Otherwise `craftingTicksRemaining = 6`, set `crafting = true` (flags 2), the result's `onCraftedBySystem`, then `dispenseItem(result)` (7.5) and `dispenseItem` for each non-empty remaining item of `recipe.getRemainingItems(input)`; then every non-empty slot of the crafter shrinks by 1; mark changed.
3. `getAnalogOutputSignal` = `getRedstoneSignal()` of 7.2.

### 7.5 `dispenseItem`

`target = HopperBlockEntity.getContainerAt(pos relative to the front)`. When the target container exists and is not a crafter (a crafter target is rejected when the stack exceeds the container maximum, per the test read), items are moved one at a time with `addItem(crafter, target, copyWithCount(1), front.opposite)` until the stack is empty or a move fails (a loop; first the single-item path for hopper-like containers, then the stack-wise path). Anything left is spawned with `DefaultDispenseItemBehavior.spawnItem` at the block centre plus 0.7 in the front direction, accuracy 6. Then every server player within a 17 x 17 x 17 box centred on the crafter receives the recipe-crafted advancement trigger with the recipe key and the crafter's items; level event 1049 (crafting sound) at the position; level event 2010 (the dispense animation) with the front's `get3DDataValue()`.

The exact branching of the container versus drop cases above (a hopper-style container may take items to its stack limit; the drop path takes the rest) is summarised from the call structure rather than transcribed (Open question 7).

## 8. Comparator

`ComparatorBlockEntity` holds one int `output` (not a container, no loot, no name). Saved key: `OutputSignal` (int, default 0). No ticker; no sync.

It exists so that the comparator remembers the output signal it last computed. The block (`ComparatorBlock`, 24-5 section 7.5, redstone rules in 30 and 29) uses it as follows (read):

- `getOutputSignal(state)` returns the entity's `output`, or 0 when the entity is missing.
- `calculateOutputSignal`: `input = getInputSignal` (the signal read from behind: `DiodeBlock` signal, replaced by the analog output of the block behind when it has one, or when the block behind is a redstone conductor, the analog output of the block two positions behind; an item frame holding an item on the conductor contributes its analog output, the larger of the two wins); if `input == 0` the result is 0; `alt = getAlternateSignal` (the strongest side signal); if `alt > input` the result is 0; the result is `input - alt` in subtract mode, `input` in compare mode.
- `refreshOutputState` (from the scheduled `tick` and from `useWithoutItem`): `new = calculateOutputSignal`; `old` = the entity's output (0 if no entity); the entity's output is set to `new`; if `old != new` OR the mode is `compare`: `shouldTurnOn` is evaluated and the `powered` property is written (flags 2) to match when it differs; then `updateNeighborsInFront`.
- `checkTickOnNeighbor`: unless a tick for this position is already due this tick, `new = calculateOutputSignal`, `old = entity output`; when `new != old` or the powered state differs from `shouldTurnOn`, a tick is scheduled in 2 ticks (priority raised when `shouldPrioritize`, 29).
- `triggerEvent` forwards to the base and then to the block entity's `triggerEvent`.

Because `output` is saved, a comparator keeps its subtract/compare output across a restart even when its input chunk is not yet loaded.

## 9. Daylight detector

`DaylightDetectorBlockEntity` has only a constructor: no fields, no saved keys, no methods. Its ticker is supplied by `DaylightDetectorBlock.getTicker`, which returns a ticker only on the server and only when the dimension type has sky light; the ticker (`tickEntity`) calls `updateSignalStrength` when `gameTime % 20 == 0`. The block's power formula and use are in 24-5 section 7.6 and 32 (effective sky brightness); summary for completeness (read again for this round): `s = effectiveSkyBrightness(pos)`; inverted: `s = 15 - s`; otherwise when `s > 0`: `a = sun_angle_degrees * 0.017453292`; the target is 0 when `a < pi` (3.1415927) and `2*pi` (6.2831855) otherwise; `a = a + (target - a) * 0.2`; `s = round(s * cos(a))`; always clamp to 0 to 15; the `power` property is rewritten with `setBlockAndUpdate` only when it changes.

## 10. Chiseled bookshelf

### 10.1 Data

| Item | Value |
|---|---|
| Slots | 6 (`MAX_BOOKS_IN_STORAGE`), arranged 2 rows by 3 columns (`getRows() = 2`, `getColumns() = 3`); slot index `= column + 3 * row`, row 0 is the top row, column 0 the left column as seen facing the shelf |
| Max stack size | 1 (the entity overrides `getMaxStackSize`) |
| Accepted items | `acceptsItemType(stack)`: the item tag `bookshelf_books` (data) |
| Saved keys | `Items` (always written, even when empty: the list-save is called with "always put the tag"), `last_interacted_slot` (int, default -1) |
| Item component twin | `container` (the whole list as an `ItemContainerContents`); `Items` is removed from the tag when components carry it |
| Not a menu container | it has no menu; interactions are direct clicks on the block |

### 10.2 Entity methods

- `setItem(slot, stack)`: when `acceptsItemType(stack)`: the slot receives the stack and `updateState(slot)` runs. Otherwise, when the stack is empty: the slot's item is removed through `removeItem(slot, 1)` (which also runs `updateState` if something was removed). A non-empty stack that is not a book is ignored.
- `removeItem(slot, count)`: take whatever is in the slot (empty if none), set the slot to empty; if the removed stack is non-empty, `updateState(slot)`. Returns the removed stack.
- `canTakeItem(target, slot, stack)` (what hoppers ask when pulling from the shelf): true when the **target** container has any slot that is empty, or that holds the same item with the same components and whose count plus `stack.count` does not exceed `target.getMaxStackSize(thatStack)`.
- `updateState(slot)`: slots outside 0 to 5 are logged and ignored. Otherwise `lastInteractedSlot = slot`; for each of the six block properties `slot_0_occupied .. slot_5_occupied`, set it to "that slot is non-empty"; write the state with `setBlockAndUpdate`; fire the game event `block_change` with the new state as context.
- Note: loading does not call `updateState` (the saved block state already carries the occupancy bits).

### 10.3 Block side (`ChiseledBookShelfBlock`, 24-2)

- Placement: `facing` is the opposite of the placer's horizontal direction; six occupancy properties default to false.
- Hit slot (`SelectableSlotContainer.getHitSlot(hit, facing)`): empty unless the face hit equals `facing`. Otherwise take the hit location relative to the block in front of the face (so the component along the facing axis is dropped), build a 2-D point `(u, v)` with `v = y` and `u` by face: NORTH `1 - x`, SOUTH `x`, WEST `z`, EAST `1 - z` (up and down faces give no slot). `row = clamp(floor((1 - v) * 16 / (16 / 2)), 0, 1)`; `column = clamp(floor(u * 16 / (16 / 3)), 0, 2)`; the slot is `column + row * 3`.
- Use with a book (`bookshelf_books` item): when the hit slot is occupied the click does nothing here; otherwise `addBook`: on the server, awards a use stat and puts one item from the stack into the slot (`consumeAndReturn(1)`; a creative player's stack is not reduced, the stack passed to `setItem` is a copy), plays the insert sound (one of two sounds by item kind, volume 1.0, pitch 1.0) and the entity updates its state.
- Use without an item: when the hit slot is non-empty, `removeBook`: `removeItem(slot, 1)`, the remove sound (by item kind), the stack goes to the player's inventory, or is dropped at the player if it does not fit, plus a game event.
- Analog output: on the client 0; on the server `lastInteractedSlot + 1` (0 when the entity is missing, so an untouched shelf outputs 0 and slot 5 outputs 6; the emptied last-used slot still outputs its index + 1).
- Removal: `updateNeighboursAfterDestroy`.

## 11. What clients see

- Furnace, smoker, blast furnace: the block state `lit` (chunk data and block updates); the menu's four data ints while the menu is open (3.2).
- Brewing stand: block states `has_bottle_0..2`; the four menu data ints.
- Hopper: block states `facing`, `enabled`.
- Dispenser, dropper: block states `facing`, `triggered`; no animation data besides level events 1000, 1001, 2000 (dispenser/dropper) which the client turns into sound and smoke (docs on audio and particles).
- Crafter: block states `orientation`, `triggered`, `crafting`; the ten menu ints while open; level events 1049, 1050, 2010.
- Comparator: block states `powered`, `mode`, `facing`; the entity value is invisible to clients.
- Daylight detector: block state `power`, `inverted`.
- Chiseled bookshelf: the six occupancy properties (the item types are not sent through the block entity path; how the client chooses book models was not read, Open question 15).
- None of the entities sends a block entity data packet (section 2.6). Whether chunk data lists these block entities with an empty tag is the shared chunk rule of 31-1 and 06, not restated here.

## 12. Worked examples

1. **First smelt, furnace, coal.** Input 1 raw iron in slot 0 (set through `setItem`, so `cookingTotalTime = 200`, `cookingTimer = 0`), 1 coal in slot 1, output empty. Provider `cooking/time_coal` is 1600 divided by factor 1 (a furnace is not `fast_cooking`), speed 1.0. Tick 1: not lit, `hasFuel && hasInput`; recipe found; `canBurn` true; not lit so `burnDuration = 1600`, `litTimeRemaining = litTotalTime = 1600`, `speedMultiplier = 1.0`; since `cookingTotalTime = 200 > 0` and `cookingTimer = 0 < 200`, `ratio = 0`, `cookingTotalTime = ceil(200 / 1.0) = 200`, `cookingTimer = ceil(0) = 0`; the coal stack is shrunk (slot 1 empty, coal has no remainder); `isLit = true`; `cookingTimer = 1`; `wasLit (false) != isLit (true)`: `lit = true`. Tick 2: `litTimeRemaining` 1600 -> 1599, still lit; `cookingTimer = 2`. Tick 200: `cookingTimer = 200 >= 200`: reset to 0, slot 2 becomes 1 iron ingot, slot 0 empty, `recipesUsed[iron_ingot_from_smelting_raw_iron] = 1`. At that moment `litTimeRemaining = 1600 - 199 = 1401`. Tick 201: input empty, still lit (`isLit` true so enters step 3); `hasInput` false so `cookingTimer = 0`; the furnace keeps burning until the counter ends.
2. **Smoker with coal.** Same data but block is `smoker`: burn time `1600 / 2 = 800`, speed 2.0, `totalCookTime = ceil(200 / 2.0) = 100`. One coal smokes 8 items (800 / 100); a furnace smelts 8 items per coal as well (1600 / 200).
3. **Cooling.** Furnace with `cookingTimer = 50`, `cookingTotalTime = 200`, no fuel: each tick `cookingTimer = max(0, timer - 2)`: 48, 46, ..., 0 after 25 ticks.
4. **Experience.** A recipe with `experience = 0.7` used 3 times: `total = 2.1` (as a float, slightly above 2.1), `whole = 2`, `frac` about 0.1; when `nextFloat() < frac`, 3 experience points are awarded, otherwise 2. A recipe with `experience = 0.0` awards `ExperienceOrb.award(level, pos, 0)`.
5. **Bucket as fuel remainder.** A lava bucket in slot 1 (burn time 20000 / 1 in a furnace): when consumed, the stack becomes empty and `bucket` is its crafting remainder, so slot 1 becomes `bucket`. A second lava bucket stack of 2: after consumption the stack of 1 stays and a `bucket` is dropped in the world at the block position.
6. **Wet sponge.** Input `wet_sponge`, fuel slot holds a `bucket`, a recipe `wet_sponge -> sponge`: when the item finishes, slot 2 gets a `sponge` and slot 1 becomes `water_bucket`.
7. **Brewing.** Slots 0 to 2: three water bottles; slot 3 `nether_wart`; slot 4 `blaze_powder` (1 item). Tick 1: `fuel = 0 <= 0` and the component exists, so `fuel = 20` (provider `brewing/uses_default` = 20), `totalFuel = 20`, `speedMultiplier = 1.0`, the blaze powder is consumed (slot 4 empty). `isBrewable` is true if a recipe maps water bottle plus nether wart (the potion input is accepted by `brewing_input` and the reagent by `brewing_reagent`). `brewTime = 0` so step 5: `fuel = 19`, `brewTime = ceil(400 / 1.0) = 400`, `totalBrewTime = 400`, remembered ingredient `nether_wart`. Ticks 2 to 400 decrement to 1; on tick 401 the decrement reaches 0, `doBrew`: each bottle becomes the recipe output, `nether_wart` shrinks by 1, level event 1035. With `speedMultiplier = 2.0` the brew time would be `ceil(400 / 2.0) = 200`.
8. **Hopper into a chest, one hopper facing down.** The hopper holds 5 cobblestone in slot 0 and 3 in slot 1; chest below. Fresh hopper (`cooldownTime = -1`). Tick N: `cooldownTime = -2`, not on cooldown so `cooldownTime = 0`; `tryMoveItems`: enabled, not empty: `ejectItems`: target chest, not full; slot 0: `removeItem(0, 1)` (count 5 becomes 4 in the hopper), `addItem` into the chest's first slot that accepts; leftover empty, return true. Not full hopper: `suckInItems` also runs (above is whatever block is above); suppose it returns false. `moved` true: `cooldownTime = 8`. Ticks N+1 to N+7: the value decrements 7, 6, ..., 1 and the hopper is on cooldown. Tick N+8: `cooldownTime = 0`, a transfer happens again. One item every 8 ticks, 2.5 items per second.
9. **Hopper chain timing.** Hopper A (source) pushes into empty hopper B at tick T. B was empty and `cooldownTime <= 8`, so `B.cooldownTime = 8 - offset` with `offset = 1` if `B.tickedGameTime >= A.tickedGameTime` (B ticked after A within this tick or the same) else 0: 7 or 8. This is the "hopper cooldown compensation" that keeps a chain at one item per 8 ticks.
10. **Item pickup.** An item entity of 5 `oak_log` rests in the block above a hopper holding 60 `oak_log` in one slot (stack max 64) and empty elsewhere. `addItem(entity)`: copy 5; `tryMoveInItem` into slot 0 adds 4 (to 64); the remaining 1 goes to slot 1 (empty). Remainder empty: the entity is discarded; returns true, cooldown 8.
11. **Dispenser slot choice.** Slots: `[A, empty, B, empty, C, empty, empty, empty, empty]`. `getRandomSlot`: slot 0 non-empty `n = 1`: `nextInt(1) == 0` always true, choose 0, `n = 2`; slot 2: `nextInt(2) == 0` with probability 1/2, choose 2, `n = 3`; slot 4: `nextInt(3) == 0` with probability 1/3. Final probabilities: each of the three slots 1/3. Three `nextInt` calls in this order.
12. **Dropper into a container.** A dropper facing north with a chest at north holding space; the chosen slot holds 2 `stone`. `rest = addItem(dropper, chest, 1 stone, SOUTH)`: the chest slot list for the south face of a normal chest is all slots. If the chest accepted it, `rest` is empty and the slot becomes a stack of 1.
13. **Crafter signal.** Slots 0 and 4 hold items, slot 1 is disabled, others empty and enabled: `getRedstoneSignal = 3` (slots 0, 1, 4). `canPlaceItem(0, X)` for slot 0 holding 3 of item X while slot 3 holds 2 of X and slot 5 holds none: false (a later enabled slot, 3, has a smaller stack of the same item); `canPlaceItem(3, X)`: true if no later slot has fewer than 2; the empty slot 5 is empty and not "same item", so true.
14. **Comparator.** Input from a chest behind it with 14 of 27 slots full of fully stacked items: `f = 14 / 27 = 0.5185`; `floor(0.5185 * 14) + 1 = 7 + 1 = 8`; side signal 3, subtract mode: output 5; compare mode: 8. The entity's `OutputSignal` is 5 (or 8) after the next `refreshOutputState`.
15. **Daylight detector.** Skylight effective 15, `sun_angle = 90` degrees: `a = 1.5707964`; target 0 (since a < pi); `a = 1.5707964 + (0 - 1.5707964) * 0.2 = 1.2566371`; `cos = 0.30901699`; `round(15 * 0.30901699) = round(4.635) = 5`. At `sun_angle = 270` degrees: `a = 4.712389`, target 6.2831855, `a = 5.0265484`, `cos = 0.309017`, power 5. At `sun_angle = 0`: power 15.
16. **Chiseled bookshelf slot.** Facing north, a hit on the north face at world-relative `x = 0.3`, `y = 0.8` (within the block): `u = 1 - 0.3 = 0.7`, `v = 0.8`; `row = floor((1 - 0.8) * 16 / 8) = floor(0.4) = 0`; `column = floor(0.7 * 16 / (16/3)) = floor(2.1) = 2`; slot 2. After adding a book to slot 2: `last_interacted_slot = 2`, comparator output 3. Removing it makes the slot empty but `last_interacted_slot` remains 2 (the removal calls `updateState(2)` only when the removed stack is non-empty, which sets 2 again), so the output stays 3.
17. **Saved forms.** A furnace mid-cook: compound with `Items` = list of two compounds (`Slot` 0 byte, `id`, `count`; `Slot` 1 byte, coal), `cooking_time_spent` 57, `cooking_total_time` 200, `lit_time_remaining` 1500, `lit_total_time` 1600, `speed_multiplier` 1.0f, `RecipesUsed` an empty compound. A hopper: `Items` list, `TransferCooldown` 5. A crafter: `crafting_ticks_remaining` 0, `disabled_slots` `[1, 3]` (int array), `triggered` 0, `Items`.

## 13. Validation section

An implementation is acceptable for this document when all of the following hold (each is checkable with the examples above or with a unit test on the entity alone):

1. Round trip: for every type, save then load yields equal data; every default in sections 3.2, 4.2, 5.1, 7.1, 8, 10.1 is used for a missing key; `Items` is absent when all slots are empty (except the bookshelf).
2. Furnace: example 1, 2, 3 and 5 to 6 produce the values stated; a `lit` state change is written only on change; `cookingTimer` rescaling when a fuel with a different speed takes over (a smoker fuel multiplier 2 over a half-progress item halves the remaining time with the `ceil` rule); no timer reset when the recipe lookup finds nothing (section 3.5).
3. Brewing: example 7; a brew is cancelled (`brewTime = 0`) when the reagent is removed or replaced by another item, or when no recipe matches any bottle; fuel is consumed only when a brew starts; the three `has_bottle_*` bits follow the occupied potion slots and are written with flags 2.
4. Hopper: cooldown sequence of example 8 (8, 7, ..., 1, 0), cooldown compensation of example 9, the pull order (result before fuel for a furnace above via `[2, 1]`; slot lists per face for the brewing stand), the pickup box (x in [0, 1], y in [0.6875, 2.0], z in [0, 1]), the "container above blocks item pickup" rule, the random container pick among entity containers with one `nextInt(count)`.
5. Dispenser and dropper: example 11 probabilities over many trials; the dispense-failure event 1001 when empty; the default behaviour's item entity position and velocity formulas (6.5) and the RNG call order; a dropper facing a container moves exactly one item per trigger.
6. Crafter: example 13; disabled slots refuse hopper input; `triggered` stored and loaded; `crafting` property reset after 6 ticks (the entity counts 6 down to 0).
7. Comparator: example 14 together with the entity value surviving save and load.
8. Chiseled bookshelf: example 16, the `Items` key present when empty, max stack 1, the tag restriction.
9. Daylight detector: example 15 and the 20-tick update period; the detector never writes block entity data.
10. No entity of this document produces a block entity data packet.

## Open questions

1. **Fuel and brewing-fuel value tables.** Which items are fuels and their provider keys are item-registry content (25-3, 25-5); this document only specifies the engine. The provider resolution (26) was not re-read here; the numbers of the examples (1600, 800, 20000, 20) are values read from the shipped provider files (`time_coal`, `time_lava_bucket`, `uses_default`) in this round.
2. **Ambiguous cooking recipes.** `RecipeManager.getRecipeFor` was read only up to the hint path. If two recipes of one type match one input, the winner depends on the recipe map order (data load order) and on the cached last key. The data pack in this jar may not have such pairs; not checked.
3. **Recipe not found while lit.** In step 3.1 of section 3.5 a missing recipe leaves `cookingTimer` unchanged, but a missing input or a blocked output resets it. Read from the bytecode (the jump target for the null case skips the reset); it differs from the behaviour one may expect from earlier versions and from the cooling branch. Confirm with a trace on a real run when a client-side validator is available.
4. **`AbstractCookingRecipe.matches`.** The body was not re-read; "ingredient tests the single input stack" is inferred from `SingleRecipeInput` and the ingredient field.
5. **`Containers.dropItemStack`.** The block-relative offset formula (it uses the entity width and `floor` terms of the position with `nextDouble` calls) was not transcribed; only the chunk size `10 + nextInt(21)` and the velocity constants were read.
6. **Dispense behaviour registry.** `DispenseItemBehavior.bootStrap` (the per-item behaviours of dispensers, such as buckets, fire charges, TNT, armor, boats, minecarts, spawn eggs, shulker boxes, glass bottles, bone meal) and the classes `EquipmentDispenseItemBehavior`, `SulfurCubeBlockDispenseItemBehavior`, `SpawnEggItemBehavior`, `ProjectileDispenseBehavior` were not read. The dispenser block's default choice (6.4 step 4) was read; the check at the end of `getDefaultDispenseMethod` that selects the spawn-egg behaviour tests the `entity_data` component first, then an item-class test whose body was not decoded in full.
7. **Crafter `dispenseItem` branching.** The structure of the container versus drop path (7.5) is summarised from the call sequence; the comparison against the container maximum and the exact loop exit were not traced instruction by instruction.
8. **Dropper game event.** Whether the dropper fires `block_activate` on a failed dispense (the dispenser does) was not seen in the dropper's `dispenseFrom`; none is described.
9. **Older save keys.** Worlds saved by older versions use other key names for furnace and brewing data (for example `BurnTime`, `CookTime`); the data fixers that rename them were not read. World data version 5023 is what this document describes.
10. **Recipe key string in `RecipesUsed`.** The codec is `unboundedMap(Recipe.KEY_CODEC, INT)`; the string form of the key is (inferred) the plain identifier of the recipe, as for recipe ids elsewhere.
11. **Map iteration order of `RecipesUsed`.** The map is a hash map keyed by reference; the order only decides in which order experience is created and thus the order of RNG draws. An implementation need not reproduce it.
12. **`ChestBlock.getContainer(..., true)` and `WorldlyContainerHolder`.** Used by the hopper's container lookup (5.7); the double-chest merge and the composter's container are 31-1 and 24-7 respectively.
13. **Chiseled bookshelf sounds and stats.** The sound events chosen by item kind and the stat awarded on insertion were not decoded.
14. **Daylight detector sun angle unit.** Degrees inferred from the conversion constant (as in 24-5, Open question 7).
15. **Chiseled bookshelf client model.** The client-side selection of the per-slot book model (assets, data) was not read; it is a rendering matter (12, 14).
