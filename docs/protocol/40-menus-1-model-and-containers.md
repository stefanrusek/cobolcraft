# 40-1 Menus and screens, part 1: shared model and container menus

| Item | Value |
|---|---|
| Covers | The shared menu model (menu type registry, `AbstractContainerMenu` semantics: container id, state id, slot numbering, click handling, quick-move template, data slots, synchronisation to the client, carried item), the shared client screen model (`AbstractContainerScreen`), the table schema every later part follows, and the container menus: the chest family (generic 9x1 to 9x6), shulker box, hopper, dispenser and dropper (generic 3x3). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`). |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of data files in the same jar (PNG headers, `lang/en_us.json`), with no execution. Every value was read in this round; anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions. |
| Round | RS14, part 1 (design map `docs/design/README.md` GAP-19). Siblings: parts 2 to 9 of document 40 cover furnaces, crafter, workstations, trading, mounts, creative and editor screens. This part covers none of them. |
| Related | 05a (Open Screen 0x3C, Container Close 0x11, Set Container Content 0x12, Set Container Data 0x13, Set Container Slot 0x14), 05b (Set Cursor Item 0x62), 05c (Container Button Click, Container Click, Container Close, Slot State Changed), 00 (ItemStack and HashedStack encodings), 12 §5.6 to §5.9 (generic container screen drawing, item decorations, tooltips, sprites), 13 §3.5 and §3.6 (inventory menu, crafting menu, result slot), 31-1 (the container block entities themselves, openers counter, double chest, lock and loot handling), 46 §5.5 (menu id table), 29 and 30-4 (dispenser, dropper and hopper behaviour in the world). |

Class names appear in backticks only to say where a fact was read. They are provenance, not design.

Content that is data (the textures, `lang` strings, sprite metadata) is not tabulated except where a menu's geometry depends on a number. The pixel art itself comes from the extracted resource pack (08, 22).

---

## 1. Scope and reading guide

1. Section 2: the menu type registry and which screens exist without a menu type.
2. Section 3: the server-side menu model: slots, containers, clicks, quick-move template, may-place and may-pickup.
3. Section 4: synchronisation: container ids, state ids, data slots, remote slots, the packets that carry them, closing.
4. Section 5: the client screen model.
5. Section 6: the schema that parts 2 to 9 follow (so a later part can be read without re-reading this one).
6. Sections 7 to 10: chest family, shulker box, hopper, dispenser and dropper.
7. Sections 11 to 13: worked examples, validation, open questions.

Conventions:

- "Menu slot index" is the index in `AbstractContainerMenu.slots` (the number on the wire in Container Click and Set Container Slot). "Container slot" is the index inside the backing `Container`.
- All pixel coordinates are relative to the top-left corner of the screen image (`leftPos`, `topPos`), in GUI pixels (one GUI pixel is one texture pixel at GUI scale 1).
- Counts are item counts; a stack with count 0 or less is empty.
- "Same item" means same item type; "same stack kind" means same item type and equal data component maps (`ItemStack.isSameItemSameComponents`: empty-vs-empty is true when both are empty, otherwise the item types must agree and the patched component maps must be equal).

---

## 2. Menu types

### 2.1 The registry (`MenuType`, registry `menu`)

25 entries, numeric id = registration order in the class initialiser (read in `MenuType.<clinit>`). The same table is in 46 §5.5. "Menu class" is the server-side menu the type creates on the client from just (container id, player inventory); "Screen" is what the client opens for it (`MenuScreens`, registered in the same order).

| Id | Key | Menu class | Client screen class | Part |
|---|---|---|---|---|
| 0 | `generic_9x1` | `ChestMenu` (1 row) | `ContainerScreen` | 40-1 §7 |
| 1 | `generic_9x2` | `ChestMenu` (2 rows) | `ContainerScreen` | 40-1 §7 |
| 2 | `generic_9x3` | `ChestMenu` (3 rows) | `ContainerScreen` | 40-1 §7 |
| 3 | `generic_9x4` | `ChestMenu` (4 rows) | `ContainerScreen` | 40-1 §7 |
| 4 | `generic_9x5` | `ChestMenu` (5 rows) | `ContainerScreen` | 40-1 §7 |
| 5 | `generic_9x6` | `ChestMenu` (6 rows) | `ContainerScreen` | 40-1 §7 |
| 6 | `generic_3x3` | `DispenserMenu` | `DispenserScreen` | 40-1 §10 |
| 7 | `crafter_3x3` | `CrafterMenu` | `CrafterScreen` | other part |
| 8 | `anvil` | `AnvilMenu` | `AnvilScreen` | other part |
| 9 | `beacon` | `BeaconMenu` | `BeaconScreen` | other part |
| 10 | `blast_furnace` | `BlastFurnaceMenu` | `BlastFurnaceScreen` | other part |
| 11 | `brewing_stand` | `BrewingStandMenu` | `BrewingStandScreen` | other part |
| 12 | `crafting` | `CraftingMenu` | `CraftingScreen` | 13 §3.5 |
| 13 | `enchantment` | `EnchantmentMenu` | `EnchantmentScreen` | other part |
| 14 | `furnace` | `FurnaceMenu` | `FurnaceScreen` | other part |
| 15 | `grindstone` | `GrindstoneMenu` | `GrindstoneScreen` | other part |
| 16 | `hopper` | `HopperMenu` | `HopperScreen` | 40-1 §9 |
| 17 | `lectern` | `LecternMenu` | `LecternScreen` | other part |
| 18 | `loom` | `LoomMenu` | `LoomScreen` | other part |
| 19 | `merchant` | `MerchantMenu` | `MerchantScreen` | other part |
| 20 | `shulker_box` | `ShulkerBoxMenu` | `ShulkerBoxScreen` | 40-1 §8 |
| 21 | `smithing` | `SmithingMenu` | `SmithingScreen` | other part |
| 22 | `smoker` | `SmokerMenu` | `SmokerScreen` | other part |
| 23 | `cartography_table` | `CartographyTableMenu` | `CartographyTableScreen` | other part |
| 24 | `stonecutter` | `StonecutterMenu` | `StonecutterScreen` | other part |

Notes:

- The key namespace is `minecraft`. The id is what Open Screen carries (a VarInt registry id, `ByteBufCodecs.registry`).
- All 25 types have a registered screen. If a client receives Open Screen for a type with no screen, `MenuScreens.create` logs a warning and opens nothing; the server-side menu stays the player's current menu until it is closed or becomes invalid (the second half is inferred from 4.6).
- Every `MenuType` carries a feature-flag set (`requiredFeatures`); all 25 are registered with the vanilla set (`FeatureFlags.VANILLA_SET`), so no flag gates any of them.
- A menu constructed with no type has no id: `AbstractContainerMenu.getType()` throws "Unable to construct this menu by type". Such menus are never sent through Open Screen.
- The client creates the menu itself from the type when Open Screen arrives (`MenuType.create(containerId, playerInventory)`). For the container menus of this part it builds the menu over a fresh empty `SimpleContainer` of the right size, and the real contents arrive in Set Container Content (4.3). For `lectern` the client builds `LecternMenu(containerId)` (a different constructor that makes its own client-side data holders).

### 2.2 Screens and menus that have no `MenuType`

These exist in the artifact and are not opened with Open Screen. They are specified in the other parts; this table says how each is opened so the packets are not confused with section 4.

| Screen (class) | Menu | How it is opened |
|---|---|---|
| inventory (`InventoryScreen`) | `InventoryMenu`, container id 0, no type (13 §3.5) | the inventory key; no packet; the menu is always the player's menu 0 |
| creative inventory (`CreativeModeInventoryScreen`, inner `ItemPickerMenu`, no type) | client-only picker menu plus the inventory menu | the inventory key in a game mode with infinite materials |
| horse, donkey, llama and similar (`HorseInventoryScreen`), nautilus (`NautilusInventoryScreen`) | `HorseInventoryMenu`, `NautilusInventoryMenu` over `AbstractMountInventoryMenu`, no type | Mount Screen Open (05a 0x2A) carries three fields: the container id, the inventory column count (`AbstractHorse.getInventoryColumns`, a VarInt) and the entity id (a 4-byte int); see 05a 0x2A and 40-6 (mount inventories) for how the columns and entity are used; the server creates the menu with an id from the same counter (4.1) |
| written book reader (`BookViewScreen`), book editor (`BookEditScreen`), book signer (`BookSignScreen`) | none | Open Book (05a 0x3B); the editor and signer are opened client-side from using a writable book |
| sign and hanging sign editors (`SignEditScreen`, `HangingSignEditScreen`, base `AbstractSignEditScreen`) | none | Open Sign Editor (05a 0x3D) |
| command block (`CommandBlockEditScreen`, `MinecartCommandBlockEditScreen`, base `AbstractCommandBlockEditScreen`), structure block (`StructureBlockEditScreen`), jigsaw (`JigsawBlockEditScreen`), test block (`TestBlockEditScreen`), test instance block (`TestInstanceBlockEditScreen`) | none | opened client-side when an operator uses the block; the command block screen refreshes itself when a Block Entity Data packet for a command block arrives while it is open (`ClientPacketListener.handleBlockEntityData`) |

`EffectsInInventory`, `CreativeInventoryListener`, `CyclingSlotBackground`, `EnchantmentNames`, `PageButton` and the `tooltip` package in the screens package are helpers of the screens above and of the generic screen (5.7). The package also holds base classes and an interface used by sibling parts: `ItemCombinerScreen` (40-3), `AbstractRecipeBookScreen` and `AbstractFurnaceScreen` (40-2), `AbstractMountInventoryScreen` (40-6) and the `MenuAccess` interface (implemented by menu-bearing screens so the client can reach `getMenu()`; implementers inferred from the names, not traced).

---

## 3. The menu model (`AbstractContainerMenu`, `Slot`)

### 3.1 State of a menu

| Field | Meaning |
|---|---|
| `containerId` | immutable int, the id the packets use. 0 is the player's inventory menu. |
| `menuType` | the `MenuType`, or none. |
| `slots` | the ordered list of `Slot`; the position in this list is the menu slot index (`Slot.index`, assigned by `addSlot` as the list size before adding). |
| `lastSlots` | per slot, the last stack copy that the menu's listeners were told about. |
| `remoteSlots`, `remoteCarried`, `remoteDataSlots` | what the menu believes the client currently shows (4.3). |
| `dataSlots` | the list of `DataSlot` (3.7). |
| `carried` | the stack on the cursor, default empty. |
| `stateId` | int revision counter (4.2). |
| quick-craft state | `quickcraftType` (-1 initially), `quickcraftStatus` (0), `quickcraftSlots` (a hash set of slots). |
| `containerListeners`, `synchronizer`, `suppressRemoteUpdates` | server-only plumbing (4.3). |

The menu holds no item data of its own: every stack lives in a `Container`, and a `Slot` is a view of one container slot at a screen position.

### 3.2 `Slot`

A `Slot` has: the backing `container`, the container slot index (`getContainerSlot`), the menu slot index `index`, and the pixel position `x`, `y` (final). Defaults, which a subclass may override:

| Method | Default behaviour |
|---|---|
| `getItem` | the container's stack at the container slot |
| `hasItem` | the stack is not empty |
| `set(stack)` | write to the container, then `setChanged` |
| `setByPlayer(stack)` | calls `set` (the two-argument form ignores the old stack) |
| `setChanged` | the container's `setChanged` |
| `mayPlace(stack)` | true |
| `mayPickup(player)` | true |
| `isActive` | true (inactive slots are neither drawn nor hit-tested) |
| `isHighlightable` | true (hover highlight, 5.4) |
| `isFake` | false (a fake slot draws its item without counting as a real stack) |
| `getNoItemIcon` | none (a slot may name a 16 x 16 sprite drawn while it is empty) |
| `getMaxStackSize()` | the container's `getMaxStackSize()` (99 for a block entity or simple container, 31-1 §9.1) |
| `getMaxStackSize(stack)` | `min(getMaxStackSize(), stack.getMaxStackSize())` |
| `allowModification(player)` | `mayPickup(player)` and `mayPlace(getItem())` |
| `onTake(player, stack)` | `setChanged` |
| `onQuickCraft(newStack, oldStack)` | calls `onQuickCraft(newStack, delta)` when the new count exceeds the old by delta greater than 0; the delta form does nothing |
| `onSwapCraft(count)`, `checkTakeAchievements(stack)` | nothing |

Derived operations (they are the primitives the click algorithm uses):

1. `tryRemove(count, decrement, player)`: returns nothing when `mayPickup(player)` is false, or when `allowModification(player)` is false and `decrement` is less than the stack's count. Otherwise let n = `min(count, decrement)`; take n items (`container.removeItem(slot, n)`); an empty result gives nothing; if the slot is now empty its `setByPlayer(EMPTY, takenStack)` is called; the result is the taken stack.
2. `safeTake(count, decrement, player)`: `tryRemove`, and when something came out, `onTake(player, taken)`; empty stack when nothing.
3. `safeInsert(stack, count)`: nothing happens (the stack is returned unchanged) if the stack is empty or `mayPlace(stack)` is false. Otherwise let room = `getMaxStackSize(stack) - slotStack.count` (slotStack = the stack in the slot, treated as count 0 when empty) and n = `min(min(stack.count, count), room)`. If n is 0 or less the stack is returned unchanged. If the slot is empty, `setByPlayer(stack.split(n))`; otherwise, if the slot stack is the same stack kind as `stack`, shrink `stack` by n and grow the slot stack by n, then `setByPlayer(slotStack)` (the same object). The remaining `stack` is returned.
4. `safeClone(player)`: a copy of the slot's stack with count = its item's max stack size (used by CLONE).

`ItemStack.split(n)` returns a copy of count `min(n, count)` and shrinks the original by the same amount.

### 3.3 Appending the player inventory

Every container menu ends with the 36 player inventory slots. Helpers (`addInventoryExtendedSlots`, `addInventoryHotbarSlots`, `addStandardInventorySlots(container, x, y)`):

| Part | Menu slots (relative to the first appended slot) | Container slot (player `Inventory`) | Position |
|---|---|---|---|
| main inventory, 3 rows of 9, row-major | +0 to +26: `+ col + 9 x row` | 9 to 35: `9 + col + 9 x row` | (x + 18 x col, y + 18 x row) |
| hotbar | +27 to +35: `+ 27 + i` | 0 to 8: `i` | (x + 18 x i, y + 58) |

So a menu whose own slots occupy menu indexes `0 .. N-1` has its main inventory at `N .. N+26` and its hotbar at `N+27 .. N+35`, total N + 36 slots. The standard call is `(x, y) = (8, 84)` for a screen 166 high, and the hotbar then sits at y = 142. The slot art is 18 x 18 and the item cell 16 x 16, so adjacent slots are 18 pixels apart.

The player inventory's container slot numbers (hotbar 0 to 8, main 9 to 35, armour and off-hand 36 to 40) are in 13 §3.5; the inventory menu (id 0) uses a different order and is not built with these helpers.

### 3.4 Click types (`ContainerInput`) and `clickMenuButton`

`ContainerInput` ids (VarInt on the wire, an out-of-range id decodes as 0): 0 `PICKUP`, 1 `QUICK_MOVE`, 2 `SWAP`, 3 `CLONE`, 4 `THROW`, 5 `QUICK_CRAFT`, 6 `PICKUP_ALL`. `ClickAction` has PRIMARY (button 0) and SECONDARY (button 1). Constants: slot -999 means "outside the screen image" (`SLOT_CLICKED_OUTSIDE`), -1 means "no slot"; `CARRIED_SLOT_SIZE` = 2147483647 is the "no limit" amount passed as the second argument of `tryRemove` and `safeTake`; `SLOTS_PER_ROW` = 9; `SLOT_SIZE` = 18.

`isValidSlotIndex(i)` is true for -1, for -999, and for every i strictly less than the slot count; it has no lower bound, so other negative numbers such as -2 or -5 also pass (bytecode read: two equality tests, then a single `i < size` comparison). The server drops a click only when the index is not valid, that is only when it is at or above the slot count and is neither -1 nor -999 (4.4).

**`clicked(slot, button, input, player)`** wraps `doClick` in an exception handler that raises a crash report ("Container click"); it adds nothing else. The behaviour of `doClick`:

0. Order of the checks: `QUICK_CRAFT` first; then, if a quick-craft is in progress (status not 0) and the input is anything else, the quick-craft is reset and nothing else happens; then the PICKUP / QUICK_MOVE group; then SWAP, CLONE, THROW, PICKUP_ALL.
1. **PICKUP and QUICK_MOVE** apply only when `button` is 0 or 1 (other buttons: the click does nothing).
   - **Slot -999** (both PICKUP and QUICK_MOVE): if the carried stack is not empty, PRIMARY drops the whole carried stack and empties it, SECONDARY drops one item split off it (`player.drop(stack, true)` with the "predicted" flag; the exact drop physics are in 41, 17). With an empty carried stack, nothing happens.
   - **QUICK_MOVE, slot >= 0**: nothing if the slot index is negative or `slot.mayPickup(player)` is false. Otherwise: `result = quickMoveStack(player, slot)`; while `result` is not empty and the stack now in the slot is the same item as `result`, `result = quickMoveStack(player, slot)` again. (So shift-click repeats until the move makes no more progress or the slot's item changes.)
   - **PICKUP, slot >= 0** (a negative slot, including -1, does nothing). First `tryItemClickBehaviourOverride` (items that define their own "stacked onto" behaviour, bundles; see Open question 6): if the slot's stack (when its item is enabled) handles being clicked by the carried stack, or the carried stack (when enabled) handles being clicked onto the slot's stack, the click is finished. Otherwise, with `s` the slot stack and `c` the carried stack:
     1. `s` empty, `c` not empty: amount = PRIMARY ? `c.count` : 1; `carried = slot.safeInsert(c, amount)`.
     2. `s` not empty and `slot.mayPickup(player)`:
        - `c` empty: amount = PRIMARY ? `s.count` : `(s.count + 1) / 2` (integer division, so SECONDARY takes the larger half); `slot.tryRemove(amount, 2147483647, player)`; if something came out, `carried = taken` and `slot.onTake(player, taken)`.
        - `c` not empty and `slot.mayPlace(c)`:
          - same stack kind: amount = PRIMARY ? `c.count` : 1; `carried = slot.safeInsert(c, amount)`.
          - different kind: if `c.count <= slot.getMaxStackSize(c)`, swap: `carried = s`, `slot.setByPlayer(c)`; otherwise nothing.
        - `c` not empty and `slot.mayPlace(c)` is false: if `s` and `c` are the same stack kind, `slot.tryRemove(s.count, c.maxStackSize - c.count, player)`; for what came out, grow `c` by its count and `slot.onTake(player, taken)`.
     3. `slot.setChanged()` is called at the end in every case, including when the override handled the click (the override's early exit jumps to that call).
2. **SWAP** (button 0 to 8 is a hotbar slot, button 40 is the off-hand; other buttons do nothing): let `h` be the player inventory stack at container slot `button` and `s` the clicked slot's stack (slot index must be 0 or more as the screen sends it; negative indexes are not guarded here although the validity guard of 4.4 lets them through, Open question 9).
   - both empty: nothing.
   - `h` empty, `s` not empty: only if `slot.mayPickup(player)`: `inventory[button] = s`; `slot.onSwapCraft(s.count)`; `slot.setByPlayer(EMPTY)`; `slot.onTake(player, s)`.
   - `h` not empty, `s` empty: only if `slot.mayPlace(h)`: n = `slot.getMaxStackSize(h)`; if `h.count > n`, `slot.setByPlayer(h.split(n))` (the rest stays in the hotbar slot); otherwise `inventory[button] = EMPTY` and `slot.setByPlayer(h)`.
   - both not empty: only if `slot.mayPickup(player)` and `slot.mayPlace(h)`: n = `slot.getMaxStackSize(h)`; if `h.count > n`: `slot.setByPlayer(h.split(n))`, `slot.onTake(player, s)`, then `inventory.add(s)` and if that fails `player.drop(s, true)`; otherwise `inventory[button] = s`, `slot.setByPlayer(h)`, `slot.onTake(player, s)`.
3. **CLONE**: only when `player.hasInfiniteMaterials()`, the carried stack is empty, slot >= 0 and the slot has an item: `carried = slot.safeClone(player)` (a full stack of the same kind).
4. **THROW**: only when the carried stack is empty and slot >= 0. count = (button 0) ? 1 : the slot stack's current count. If `player.canDropItems()` is false the click ends. Otherwise `taken = slot.safeTake(count, 2147483647, player)`, then `player.drop(taken, true)` and `player.handleCreativeModeItemDrop(taken)`. When button is 1 (the screen sends 1 for Ctrl-drop): while the stack just taken is not empty and the slot's stack is the same item as it: check `canDropItems` again (stop if false), take `count` again (the count computed at the start), drop it. (An empty slot yields an empty take; whether `drop` ignores an empty stack was not traced, Open question 9.)
5. **PICKUP_ALL** (double-click collect): only when slot >= 0, the carried stack is not empty, and the clicked slot has no item or `mayPickup` is false for it. Direction: button 0 scans slot 0 up to the last slot, any other button scans from the last slot down to 0. Two passes (pass 0, then pass 1) over every slot j in scan order while `c.count < c.maxStackSize`: the slot must have an item, be the same stack kind as `c` (`canItemQuickReplace(slot, c, true)`), `mayPickup(player)` must hold, and `menu.canTakeItemForPickAll(c, slot)` (default true; result slots override it to refuse) must hold; in pass 0 a slot whose stack is already at its item's max stack size is skipped, in pass 1 it is taken from too. For a slot that qualifies: `taken = slot.safeTake(slotStack.count, c.maxStackSize - c.count, player)` and `c.grow(taken.count)`.
6. **QUICK_CRAFT** (drag distribution): the button carries a header (bits 0 and 1) and a type (bits 2 and 3): `header = button & 3`, `type = (button >> 2) & 3`, `mask(header, type) = (header & 3) | ((type & 3) << 2)`. Header 0 starts, 1 adds a slot, 2 ends. Types: 0 charitable (left-drag: share equally), 1 greedy (right-drag: one per slot), 2 clone (middle-drag, only with infinite materials). The transition rule: the new header is accepted when the previous status equals it, or when the previous status is 1 and the new header is 2; any other transition resets the drag. A drag with an empty carried stack resets. Then:
   - header 0: `quickcraftType = type`; if `type` is valid (0 or 1 always, 2 only when `player.hasInfiniteMaterials()`) the status becomes 1 and the slot set is cleared; otherwise reset.
   - header 1 (status 1): the slot named by `slot` is added to the set when all hold: `canItemQuickReplace(slot, carried, true)` (the slot is empty, or has the same stack kind), `slot.mayPlace(carried)`, (`type == 2` or `carried.count >= set size + 1`; the check reads the set size before adding, so the carried stack must be larger than the number of slots already in the set), `menu.canDragTo(slot)` (default true).
   - header 2: if the set is empty, reset. If the set has exactly one slot, reset and perform a PICKUP on that slot with button = `quickcraftType` (0 places the whole stack, 1 places one item; type 2 gives button 2, which PICKUP ignores). Otherwise, with `n` = set size and `remaining` = the carried count: for each slot in the set (iteration order does not change the result, see 11.4) that still satisfies the header-1 conditions (`type == 2` or `carried.count >= n`): `existing` = the slot stack count (0 if empty), `limit = min(carried.maxStackSize, slot.getMaxStackSize(carried))`, `placed = min(placeCount + existing, limit)`, `remaining -= placed - existing`, and the slot gets a copy of the carried stack with count `placed` via `setByPlayer`. `placeCount` is `getQuickCraftPlaceCount(n, type, carried)`: type 0 gives `floor(carried.count / n)` (computed in float arithmetic, `Mth.floor(count / (float) n)`, equal to integer division for stack-sized counts), type 1 gives 1, type 2 gives the carried stack's max stack size; any other type (unreachable for valid types) gives the carried stack's current count. Finally the carried stack's count is set to `remaining` (clone type reduces it like the others; a count of 0 or less is an empty stack, inferred) and the drag is reset.
   - `canItemQuickReplace(slot, stack, ignoreSize)`: true when the slot is absent or empty; otherwise true when the slot stack and `stack` are the same stack kind and `slot.count + (ignoreSize ? 0 : stack.count) <= stack.maxStackSize`.

`clickMenuButton(player, id)` is the hook for Container Button Click (05c): the base implementation returns false. A subclass handles its own button ids (enchanting option, loom pattern, beacon, stonecutter, lectern, merchant trade); the server runs `broadcastChanges` after a handled button (returns true).

### 3.5 `moveItemStackTo(stack, start, end, reverse)`

The shared mover used by every `quickMoveStack`. It acts on the slot range `[start, end)`, scanning from `start` up, or from `end - 1` down when `reverse` is true. It returns whether anything changed. It changes `stack` itself (the caller passes the stack that lives in the source slot).

1. Pass A (merge) runs only when `stack` is stackable (`maxStackSize > 1` and not a damaged damageable item) and not empty. For each slot in scan order, while `stack` is not empty: let `t` be the slot stack; if `t` is not empty and the same stack kind as `stack`: `total = t.count + stack.count`, `limit = slot.getMaxStackSize(t)`. If `total <= limit`: `stack` becomes empty, `t.count = total`, `slot.setChanged`, changed. Else if `t.count < limit`: `stack` shrinks by `limit - t.count`, `t.count = limit`, `slot.setChanged`, changed. (Merging does not check `mayPlace`.)
2. Pass B (empty slot) runs when `stack` is still not empty. Scan again from the same end; in the first slot whose stack is empty and which accepts `slot.mayPlace(stack)`: `limit = slot.getMaxStackSize(stack)`, `slot.setByPlayer(stack.split(min(stack.count, limit)))`, `slot.setChanged`, changed, and the scan stops. Only one empty slot is filled per call.
3. Return changed.

### 3.6 The quick-move template and the container menus' use of it

Every `quickMoveStack(player, index)` of this part follows this template. `ret` starts as the empty stack.

1. `slot` = the slot at `index`. If the slot exists and has an item: `stack` = the slot's stack object; `ret` = a copy of it taken before anything moves.
2. Move: if `index` is inside the menu's own container range, move into the player inventory range; otherwise move into the own container range (the ranges and directions are given per menu). If `moveItemStackTo` returns false, return the empty stack (no change).
3. If `stack` is now empty, `slot.setByPlayer(EMPTY)`; otherwise `slot.setChanged()`.
4. Return `ret` (the pre-move copy, so its count is the original count even when everything moved).

The caller (QUICK_MOVE, 3.4) re-invokes it while the slot still holds the same item as `ret`. A menu may add a final progress test (the dispenser does, 10.3).

### 3.7 Data slots

`DataSlot` is one int shared between server and client: abstract `get` and `set`, plus a private `prevValue` used by `checkAndClearUpdateFlag` (compare `get()` with `prevValue`, store the current value as the new `prevValue`, return whether they differed). Factories: `forContainer(containerData, i)` (a view of one entry of a `ContainerData`), `shared(int[], i)` (a view of an array entry) and `standalone()` (own int, default 0). `ContainerData` has `get(i)`, `set(i, v)`, `getCount()`; `SimpleContainerData(n)` is an int array of n zeros. `addDataSlots(containerData)` adds one `DataSlot.forContainer` per entry in order; `checkContainerDataCount` throws when the data holder is smaller than the menu needs. `addDataSlot` appends a slot and a remote value of 0. The data slot index is the "property" of Set Container Data. Values travel as 16-bit signed shorts on the wire (4.3), so a value that can exceed 32767 or go below -32768 is truncated by the codec (the beacon effect ids and enchantment ids rely on small values; 46 §5.5 gives the beacon +1 rule).

### 3.8 Closing and the guard methods

- `stillValid(player)` is abstract. The container menus of this part delegate to `container.stillValid(player)` (block-entity containers: the entity is still the block entity at its position and the player is within the block interaction range plus 4.0, 31-1 §9.1; other containers define their own). The helper `stillValid(access, player, block)` used by block-bound workstation menus returns true when the block at the access position is that block and `player.isWithinBlockInteractionRange(pos, 4.0)`; with no level access it returns true.
- `removed(player)` (called when the menu is closed on the server; the client also calls it when its screen is removed, but it is a no-op there except for container `stopOpen`): for a server player, if the carried stack is not empty, it is returned to the inventory (`placeItemBackInInventory`) or dropped when the player is gone (removed for a reason other than a dimension change, or disconnected); the carried stack becomes empty. The container menus extend this by calling `container.stopOpen(player)`.
- The constructors of the container menus call `checkContainerSize(container, rows x 9)` (an `IllegalArgumentException` when the container is smaller) and `container.startOpen(player)`.
- `clearContainer(player, container)`: for every slot, remove the item without notifying and place it back in the inventory or drop it; used by crafting-like menus.
- `slotsChanged(container)`: calls `broadcastChanges`.
- `getRedstoneSignalFromContainer(container)` (comparator): see 31-1 §9.5.
- `findSlot(container, containerSlot)` returns the menu index of the slot that wraps that container slot. `transferState(other)` copies the remote bookkeeping (`RemoteSlot` state) between two menus for slots that wrap the same container slot (used when the player's inventory menu replaces another menu).

---

## 4. Synchronisation between server and client

### 4.1 Container ids

The player has `containerCounter` (starts at 0) and a current menu (`containerMenu`, default the inventory menu with id 0). `nextContainerCounter()` sets `containerCounter = (containerCounter % 100) + 1`, so ids cycle 1, 2, ..., 100, 1, ... Only ids 1 to 100 are given to opened menus.

`ServerPlayer.openMenu(provider)`:

1. A null provider gives no menu.
2. If the current menu is not the inventory menu, `closeContainer()` first (4.6).
3. `nextContainerCounter()`; `menu = provider.createMenu(containerCounter, inventory, player)`. A provider can return null (locked container, loot not ready, spectator): for a spectator, the red overlay message `container.spectatorCantOpen` is shown; no menu opens, no packet.
4. Send Open Screen (container id, `menu.getType()`, `provider.getDisplayName()`).
5. `initMenu(menu)`: add the player's slot listener (which immediately triggers one `broadcastChanges` with no synchronizer, so only listener side-effects run), then `setSynchronizer`, which creates the remote slot trackers and calls `sendAllDataToRemote()`: this sends Set Container Content (4.3) and one Set Container Data per data slot.
6. `containerMenu = menu`; the result is the container id.

The title in the packet is the provider's display name (a text component). The generic screen draws it as given.

The slot listener (`ServerPlayer`'s container listener) does one thing: for a changed slot that is not a result slot, if the slot's container is the player's own inventory it fires the `inventory_changed` advancement trigger. Its data-change hook does nothing.

### 4.2 State id

`stateId` is an int; `incrementStateId()` computes `(stateId + 1) & 32767` and returns it. The server increments it every time it sends Set Container Content or Set Container Slot (not for data or cursor packets), so the id wraps from 32767 to 0. The client stores the id of the last Set Container Content or Set Container Slot it applied (`initializeContents(stateId, ...)`, `setItem(slot, stateId, stack)`) and sends it in every Container Click.

### 4.3 What the server sends, and when

The menu keeps for each slot a `RemoteSlot` (the server's belief of what the client shows) that holds either a known stack copy or a hash received from the client. `RemoteSlot.matches(stack)`: if a stack copy is known, `ItemStack.matches(known, stack)` (same count and same stack kind); otherwise, if a client hash is known and equals the hash of `stack` (computed with the player's hash generator), the stack is stored as the known copy and the result is true; otherwise false. `force(stack)` stores a copy and clears any hash. `receive(hash)` clears the known copy and stores the hash. The hash generator caches the hash of each distinct data component value (a cache of at most 256 entries per player); this is only an optimisation. The hash function itself is in 00.

**`broadcastChanges()`** (called each server tick for the player's current menu, after every handled click and button click, and after `slotsChanged`):

1. For every slot i in index order, with `now` = the slot's stack: if `ItemStack.matches(lastSlots[i], now)` is false, store a copy in `lastSlots[i]` and tell every listener (`slotChanged`). Then, unless remote updates are suppressed, if `remoteSlot[i].matches(now)` is false: `force(now)` and send Set Container Slot(container id, `incrementStateId()`, i, copy of now).
2. The carried stack: unless suppressed, if `remoteCarried.matches(carried)` is false: `force`, and send Set Cursor Item (05b 0x62) with a copy.
3. For every data slot i: `v = get()`; if `checkAndClearUpdateFlag()` (the value changed since the last check), tell listeners (`dataChanged`); then unless suppressed, if `remoteDataSlots[i] != v`, store `v` and send Set Container Data(container id, i, v).

**`broadcastFullState()`** (used after a click whose state id disagreed with the server's): runs step 1's listener part for all slots and the data slot flag check for all data slots (listeners only, no packets), then `sendAllDataToRemote()`.

**`sendAllDataToRemote()`**: copies every slot's stack into a list and forces every `RemoteSlot` to it, forces `remoteCarried` to the carried stack, sets every `remoteDataSlots[i]` to the current value, and (if a synchronizer is attached) sends Set Container Content(container id, `incrementStateId()`, the list, a copy of the carried stack) followed by one Set Container Data per data slot, in index order.

`suppressRemoteUpdates()` and `resumeRemoteUpdates()` bracket the processing of a client click so that the click's own effects are not echoed slot by slot.

**Client application** (`ClientPacketListener`):

| Packet | Effect on the client |
|---|---|
| Open Screen | `MenuScreens.create(type, container id, title)`: build the menu from the type with that id, make the screen, show it, and make the menu the player's current menu. |
| Set Container Content | Container id 0: initialise the inventory menu's slots (list index = slot index), carried stack and state id. Container id equal to the open menu's id: the same for that menu. Any other id: ignored. |
| Set Container Slot | Container id 0: if the slot is a hotbar slot of the inventory menu (`InventoryMenu.isHotbarSlot`, menu indexes 36 to 44 are the hotbar and 45 is the off-hand (shield) slot; the test is true for 36 to 45 inclusive, so the off-hand also gets the bounce), the new stack is not empty, and the old stack there is empty or has a smaller count, the new stack's pop time is set to 5 (the pickup bounce); then the inventory menu's slot and state id are set. Container id equal to the open menu's id (not 0): the open menu's slot and state id are set. Any other id: ignored. (A creative-inventory-screen test also appears in this handler, Open question 14; after it the handler refreshes the inventory menu's remote slot when that screen is open.) Before the container-id branches the handler calls the tutorial hook `Tutorial.onGetItem` on the incoming stack (client-side tutorial only, no packet effect). |
| Set Container Data | Only when the id equals the open menu's: `menu.setData(property, value)` (writes the data slot). |
| Set Cursor Item | Unless the creative inventory screen is open: `menu.setCarried(stack)` on the current menu. |
| Container Close | `clientSideCloseContainer`: the player's menu becomes the inventory menu and the screen is removed (`setScreen(null)`), with no packet sent back. |

### 4.4 What the client sends and how the server handles it

**Container Click (05c 0x12)** from the generic screen: `MultiPlayerGameMode.handleContainerInput(containerId, slot, button, input, player)`:

1. If `containerId` is not the player's current menu id, the click is ignored with a warning.
2. Copy the stacks of all slots, run `menu.clicked(slot, button, input, player)` on the client's own menu (so the screen updates immediately), then build the "changed slots" map: for every slot whose stack no longer `ItemStack.matches` its copy, add (slot index, `HashedStack` of the new stack). The carried stack's hash goes in the carried field. The packet gets the client menu's `stateId`, the slot as a Short (checked cast), the button as a Byte (checked cast), the input and those two items.
3. The server (`ServerGamePacketListenerImpl.handleContainerClick`):
   1. after the thread check and before the id comparison, call `ServerPlayer.resetLastActionTime()`: every click packet, accepted or not, resets the player's idle (AFK) timer; then ignore the packet when its container id differs from the player's current menu id;
   2. if the player is a spectator or dying: `sendAllDataToRemote()` (a full resend, which also resets the remote bookkeeping) and stop;
   3. if the menu is no longer valid (`stillValid` false): drop the packet (a debug log only);
   4. if the slot index is not valid (3.4: the only rejected indexes are those at or above the slot count; every negative number passes): drop it (a debug log naming the slot count);
   5. `desync = (packet.stateId != menu.getStateId())`;
   6. `suppressRemoteUpdates()`; `menu.clicked(slot, button, input, player)` (the click is applied even when `desync` is true); for every (slot, hash) of the packet call `setRemoteSlotUnsafe(slot, hash)`, which stores the hash in that slot's `RemoteSlot` (a slot index outside the list is logged and skipped); `setRemoteCarried(carriedHash)`; `resumeRemoteUpdates()`;
   7. if `desync`: `broadcastFullState()`, otherwise `broadcastChanges()`.

   The effect of step 6: after the click the server compares each slot's real new stack to the hash the client predicted; where they agree no Set Container Slot is sent; where they differ (or the server changed something the client did not predict) the correct stack is sent with a new state id. The state id check does not reject a click; it only makes the server resend everything afterwards.

**Container Button Click (05c 0x11)**: ignored unless the container id equals the current menu's and the player is not a spectator; ignored when `stillValid` is false; otherwise `clickMenuButton(player, buttonId)`; when it returns true the server runs `broadcastChanges()`.

**Container Slot State Changed (05c 0x14)**: ignored for a spectator or a mismatching container id; otherwise only a crafter menu over a crafter block entity acts on it (part with the crafter).

**Container Close (05c 0x13)**: `doCloseContainer()` (4.6); the server does not echo a close packet.

**Per tick**: `ServerPlayer.tick` runs `containerMenu.broadcastChanges()` and then, if `containerMenu.stillValid(player)` is false, `closeContainer()` (which sends Container Close).

### 4.5 Screen opening from the client's side

Opening a screen from Open Screen replaces whatever screen is shown. The client's current menu is set when the screen is created, and cleared (back to the inventory menu) when the screen is closed.

### 4.6 Closing

- **Server initiated** (`ServerPlayer.closeContainer()`): send Container Close(current menu id), then `doCloseContainer()`.
- **`doCloseContainer()`**: `menu.removed(player)` (3.8), `inventoryMenu.transferState(menu)`, current menu = inventory menu. It sends nothing.
- **Client initiated** (`LocalPlayer.closeContainer()`, called by the screen's `onClose`): send Container Close(menu id), then the local close (current menu = inventory menu, remove screen).
- The screen's `onClose` runs on the inventory key (`keyInventory`, any container screen) and on Escape (`Screen.keyPressed` when the screen allows it). `AbstractContainerScreen.tick` closes the container when the local player is dead or removed.
- `ServerPlayer.openMenu` while another menu is open closes it first (4.1 step 2), so the carried stack is returned before the new menu opens.

---

## 5. The generic container screen (`AbstractContainerScreen`)

12 §5.6 gives the drawing summary for the inventory and crafting screens. This section is the complete model that every container screen inherits.

### 5.1 Geometry

| Item | Value |
|---|---|
| default image size | 176 x 166 (`DEFAULT_IMAGE_WIDTH`, `DEFAULT_IMAGE_HEIGHT`); a subclass passes its own `imageHeight` (chest family: `114 + 18 x rows`; hopper 133; shulker box 167; dispenser default) |
| `leftPos` | `(guiWidth - imageWidth) / 2` (integer division), recomputed in `init()` |
| `topPos` | `(guiHeight - imageHeight) / 2` (integer division) |
| `titleLabelX`, `titleLabelY` | 8, 6 (set in the constructor) |
| `inventoryLabelX`, `inventoryLabelY` | 8, `imageHeight - 94` (set in the constructor from the image height passed in) |
| background texture size | 256 x 256 (`BACKGROUND_TEXTURE_WIDTH`, `BACKGROUND_TEXTURE_HEIGHT`) |
| player inventory title | `Inventory.getDisplayName()`, the key `container.inventory` ("Inventory") |

`guiWidth` and `guiHeight` are the window size divided by the GUI scale (12 §5). At GUI scale 1 a 854 x 480 window gives `leftPos = 339`, and for a 168-high screen `topPos = 156`.

### 5.2 Draw order (`extractRenderState`)

1. `extractContents`: the screen background (`Screen.extractRenderState`: the in-game dimmed gradient of 12 §5.6, then the subclass's `extractBackground` texture blit), then with the origin translated to (`leftPos`, `topPos`): the labels, then the hovered slot is computed (the first active slot in menu order whose 18 x 18 cell contains the pointer, 5.5), then the highlight-back sprite, then every active slot (`extractSlots`), then the highlight-front sprite. If the hovered slot changed, the previous one gets `onStopHovering` (bundle scroll cleanup).
2. `extractCarriedItem`: the carried stack is drawn at (mouseX - 8, mouseY - 8), in its own layer above the slots. When the drag set has more than one slot, the carried item is drawn with the count text from a copy of the carried stack holding the remaining count (`quickCraftingRemainder`, recomputed as in 3.4 step 6); if that remainder is 0 (the copy is empty) the count text is the string "0" preceded by the yellow chat formatting code. With one slot or no drag the carried stack is drawn with its own count.
3. `extractTooltip` (5.6).

### 5.3 Labels

Both labels are drawn with `GuiGraphicsExtractor.text(font, component, x, y, color, shadow = false)`: the title at (`titleLabelX`, `titleLabelY`) and the inventory title at (`inventoryLabelX`, `inventoryLabelY`), colour `#404040` (the int -12566464), no shadow. A subclass may override `extractLabels` (the inventory screen draws only its own title). The `title` is the component from Open Screen.

### 5.4 Slots

`extractSlot(slot)` for one slot at (x, y) with `stack` = its item:

1. If a drag is in progress and this slot is in the drag set: with a drag set of exactly one slot nothing is drawn for the slot (the early return); otherwise, if the slot qualifies (`canItemQuickReplace` with ignore-size true and `menu.canDragTo`) a 16 x 16 rectangle `#80ffffff` (the int -2130706433) is filled at (x, y), and the displayed stack becomes a copy of the carried stack with count `min(placeCount + existing, limit)` (placeCount, existing and limit as in 3.4 step 6) and, when the limit is smaller than the unclamped value, the count text is the limit in yellow; a slot in the set that does not qualify is removed from the set and the remainder is recomputed.
2. If the stack is empty, the slot is active and `getNoItemIcon()` names a sprite, the sprite is drawn 16 x 16 at (x, y) and nothing else is drawn for the slot.
3. Otherwise: the item is drawn at (x, y) (as a fake item when the slot is fake) with a z-seed of `x + y x imageWidth`, followed by the item decorations (12 §5.7) with the optional count override text.

Hover highlight: two 24 x 24 sprites `container/slot_highlight_back` and `container/slot_highlight_front` (resource `textures/gui/sprites/container/slot_highlight_back.png` and `..._front.png`, each with a `.mcmeta`), both drawn at (slot.x - 4, slot.y - 4) when the hovered slot is highlightable, the back one before the slots' items and the front one after.

### 5.5 Pointer and click handling

- **Hit test** (`isHovering(slot, px, py)`): with `rx = px - leftPos`, `ry = py - topPos`, the slot is hit when `x - 1 <= rx < x + 17` and `y - 1 <= ry < y + 17` (an 18 x 18 cell around the 16 x 16 item cell).
- **Outside** (`hasClickedOutside(px, py, left, top)`): true when `px < left`, `py < top`, `px >= left + imageWidth` or `py >= top + imageHeight`.
- **Mouse button numbers** in this version: `InputConstants` defines `MOUSE_BUTTON_LEFT` = 1, `MOUSE_BUTTON_MIDDLE` = 2, `MOUSE_BUTTON_RIGHT` = 3 (not the 0, 1, 2 of GLFW). The container click button sent to the server is PRIMARY 0 for the left button and SECONDARY 1 for the right button (`getContainerClickButton`: 1 to 0, 3 to 1, any other value unchanged).
- **Mouse down** (`mouseClicked`), after the widgets did not consume it: `doubleclick` = the same hovered slot as the previous click and the event's double-click flag; `skipNextRelease` = false (the screen constructor initialises it to true, so a fresh screen swallows its first mouse release, 5.5 release step 4). Only for the left button, the right button, or the pick-item key (creative only) is anything done. The target slot is the hovered slot's index, or -999 when outside, or -1 when none. If the target is not -1 and no drag is running:
  - carried stack empty: with the pick-item key (infinite materials) send CLONE for the slot; otherwise `quick = shift held and target != -999`; the input is QUICK_MOVE when `quick`, THROW when the target is -999, else PICKUP. When `quick`, remember a copy of the slot's stack in `lastQuickMoved` (empty if the slot has none). Send it, and set `skipNextRelease`.
  - carried stack not empty: start a drag: `isQuickCrafting = true`, `quickCraftingButton` = the event button, the drag set cleared, and the drag type: left button 0 (charitable), right button 1 (greedy), pick-item key with infinite materials 2 (clone).
  - Mouse down with another button on a slot: `checkHotbarMouseClicked`: with the carried stack empty and a hovered slot, the swap-off-hand key (as a mouse button) sends SWAP with button 40, a hotbar key (as a mouse button) i sends SWAP with button i.
  The previous-slot memory is updated at the end.
- **Mouse drag** (`mouseDragged`): the slot under the pointer is added to the drag set when `shouldAddSlotToQuickCraft` holds (a drag is running, the carried stack is not empty, `carried.count > set size` or the type is 2, `canItemQuickReplace(slot, carried, true)`, `slot.mayPlace(carried)`, `menu.canDragTo(slot)`); when a slot is added the remainder preview is recomputed.
- **Mouse up** (`mouseReleased`):
  1. Target slot as above (-999 outside).
  2. Double-click with the left button and a hovered slot for which `canTakeItemForPickAll(EMPTY, slot)`: with shift held and a remembered `lastQuickMoved`, send QUICK_MOVE for every slot of the same container that has an item, can be picked up and is the same stack kind as `lastQuickMoved` (`canItemQuickReplace` ignore-size true); without shift send PICKUP_ALL for the target slot. Clear `doubleclick`. (A client-side convenience: the server only sees the resulting clicks.)
  3. Otherwise, if a drag is running and the release button differs from the drag's button: end the drag (clear the set), set `skipNextRelease`, done.
  4. Otherwise, if `skipNextRelease` is set: clear it, done (the release of a click that already acted on press).
  5. Otherwise, if a drag is running with a non-empty set: send the drag (below).
  6. Otherwise, if the carried stack is not empty: pick-item key: CLONE; otherwise `quick` as for mouse down, PICKUP or QUICK_MOVE with `lastQuickMoved` recorded.
  7. A running drag ends (`isQuickCrafting` false).
- **Sending a drag** (`quickCraftToSlots`): three kinds of QUICK_CRAFT packets: (slot -999, button `mask(0, type)`), then for each slot in the drag set (slot index, button `mask(1, type)`), then (slot -999, button `mask(2, type)`). For type 0 the three button values are 0, 1, 2; for type 1 they are 4, 5, 6; for type 2 they are 8, 9, 10. A drag that never entered a second slot has a one-slot set and is therefore a plain PICKUP on the server (3.4 step 6).
- **Keys** (`keyPressed`): the inventory key closes the screen. Then `checkHotbarKeyPressed`: with the carried stack empty and a hovered slot, the swap-off-hand key sends SWAP (button 40) and the hotbar key i (0 to 8) sends SWAP (button i); either consumes the key. Otherwise, with a hovered slot that has an item: the pick-item key sends CLONE (button 0); the drop key sends THROW with button 1 when Ctrl is held and 0 otherwise.
- `isPauseScreen` is false (the game keeps running with a container screen open); `isInGameUi` is true (the dimmed gradient background).
- All outgoing clicks go through `slotClicked(slot, button, input)`, which first runs the bundle mouse-action hooks and then `handleContainerInput` (4.4).

### 5.6 Tooltip

`extractTooltip`: nothing unless a slot is hovered and has an item. With the carried stack empty (or when the carried stack is not empty and the hovered stack's tooltip image allows it, `showTooltipWithItemInHand`), the tooltip is built from the item's tooltip lines, its optional tooltip image and its `tooltip_style` component, and is set for the next frame with the positioner of 12 §5.8.

### 5.7 Background textures and sprites: naming and conventions

- A container screen's background is one PNG under `textures/gui/container/` in the `minecraft` namespace, blitted from a 256 x 256 sheet with `blit(pipeline, texture, x, y, u, v, w, h, 256, 256)`: the destination is (`leftPos`, `topPos` + offset), the source origin is (u, v), and the sheet is 256 x 256 (a PNG header read gives 256 x 256 for `generic_54`, `hopper`, `dispenser` and `shulker_box`).
- Sprites (widgets, highlights, icons) live under `textures/gui/sprites/<folder>/<name>.png` and are named by the path without the extension (`container/slot_highlight_back`); an optional `.mcmeta` gives the nine-slice scaling (12 §5.9).
- The slot art is part of the background sheet; the code never draws a slot frame.
- Colour and text rules: 12 §5.6 to §5.10.

---

## 6. The table schema for the other parts (parts 2 to 9 of document 40)

A later part documents each of its menus with these subsections in this order, so an implementer can compare parts mechanically.

**M1. Identity table**: menu class, `MenuType` key and id (from 2.1), factory used on the client and on the server, client screen class, feature flag (none unless stated), default title key and string.

**M2. Slot table**, one row per slot or run of slots, columns:

| Column | Meaning |
|---|---|
| Menu slot index | single index or `a to b` |
| Container and container slot | which `Container` and its slot numbers |
| x, y | pixel position of the item cell (top-left of the 16 x 16 cell), as formulas in `col`, `row` or `i` |
| Slot class | `Slot` or the subclass, with `mayPlace`, `mayPickup`, `onTake`, `getMaxStackSize` when they differ from the defaults in 3.2 |
| Notes | empty-slot icon, `isFake`, `isActive`, `isHighlightable` when they differ |

The player inventory run uses the form of 3.3 (stated once per menu as `+0 to +26` and `+27 to +35` relative to the menu's own slot count).

**M3. Data slots**: index, meaning, range of values, who writes it, and whether the value is also copied by a menu constructor on the client (columns: index, meaning, range, writer).

**M4. Buttons** (`clickMenuButton`): button id, effect, validity test, whether it returns true.

**M5. Quick-move table**: for each source slot range, the target range or ranges, the direction (`reverse`), the `mayPlace` filters that decide the target, and any final progress test (the template is 3.6).

**M6. Lifecycle**: `stillValid`, `removed` (what is returned to the player), `slotsChanged` hooks, containers opened or closed (`startOpen`, `stopOpen`).

**M7. Screen**: image size, label positions (override of 5.1), background texture name, blit regions (u, v, w, h and destination offset), extra sprites with their positions and sizes, widgets (buttons, scroll bars, text fields) with positions, the exact text colours, and the tick behaviour.

**M8. Worked examples** and **M9. Validation** (checks an implementer can run on the slot counts, index mappings and quick-move results), then the numbered **Open questions**.

Pixel coordinates are always relative to (`leftPos`, `topPos`); slot rows are listed as formulas, not as expanded tables, unless a layout is irregular. A part states the menu slot count (own slots + 36) so that 3.3 can be checked.

---

## 7. The chest family (`ChestMenu`, `ContainerScreen`)

### 7.1 Identity (M1)

| Item | Value |
|---|---|
| Menu class | `ChestMenu`, one class for six types: `generic_9x1` to `generic_9x6` with `containerRows` 1 to 6 |
| Types and ids | `generic_9x1` 0, `generic_9x2` 1, `generic_9x3` 2, `generic_9x4` 3, `generic_9x5` 4, `generic_9x6` 5 |
| Factories | `oneRow` to `sixRows(containerId, inventory)` build a menu over a new `SimpleContainer(9 x rows)` (the client form); `threeRows` and `sixRows(containerId, inventory, container)` build one over a given container (the server form) |
| Server users in this artifact | `threeRows` over the container: chest, trapped chest, barrel, ender chest (`PlayerEnderChestContainer`), chest boat (`AbstractChestBoat`), chest minecart (`MinecartChest`); `sixRows` over a `CompoundContainer`: the double chest (`ChestBlock` menu provider, 31-1 §10.2). No other number of rows is created by any server code in the artifact, though the client supports all six (`oneRow`, `twoRows`, `fourRows`, `fiveRows` have no caller). |
| Screen | `ContainerScreen`, for all six types |
| Titles | the provider's display name: `container.chest` ("Chest"), `container.chestDouble` ("Large Chest"), `container.barrel` ("Barrel"), `container.enderchest` ("Ender Chest"), or a custom name; the menu itself carries none |

The constructor: `checkContainerSize(container, rows x 9)`, store the container and `containerRows`, `container.startOpen(player)`, add the chest grid, then `addStandardInventorySlots(inventory, 8, 18 + 18 x rows + 13)`. `stillValid` is `container.stillValid(player)`. `removed` calls the superclass then `container.stopOpen(player)`. `getRowCount()` returns the rows; `getContainer()` the container.

### 7.2 Slot table (M2) for `rows` = R

Menu slot count = 9 R + 36.

| Menu slot index | Container slot | x, y | Slot class |
|---|---|---|---|
| `0 .. 9R-1`, index = `col + 9 x row` | the same number in the chest container | `(8 + 18 x col, 18 + 18 x row)`, col 0 to 8, row 0 to R-1 | plain `Slot` (default rules) |
| `9R .. 9R+26` | player inventory 9 to 35 | `(8 + 18 x col, Y0 + 18 x row)` | plain `Slot` |
| `9R+27 .. 9R+35` | player inventory 0 to 8 | `(8 + 18 x i, Y0 + 58)` | plain `Slot` |

with `Y0 = 18 + 18 R + 13 = 31 + 18 R` and `imageHeight = 114 + 18 R`:

| R | own slots | total | `imageHeight` | `Y0` (main inventory top) | hotbar y | inventory label y (`imageHeight - 94`) |
|---|---|---|---|---|---|---|
| 1 | 9 | 45 | 132 | 49 | 107 | 38 |
| 2 | 18 | 54 | 150 | 67 | 125 | 56 |
| 3 | 27 | 63 | 168 | 85 | 143 | 74 |
| 4 | 36 | 72 | 186 | 103 | 161 | 92 |
| 5 | 45 | 81 | 204 | 121 | 179 | 110 |
| 6 | 54 | 90 | 222 | 139 | 197 | 128 |

The chest slots accept every item (no filter). Stack size limit in a slot is `min(99, item max)` (a chest container's `getMaxStackSize` is 99, 31-1 §9.1); the screen draws counts above 64 normally. A `SimpleContainer` (client form, `Container` default) has the same limit.

### 7.3 Quick-move (M5)

Template 3.6. `index < 9 R` (a chest slot): `moveItemStackTo(stack, 9R, slotCount, reverse = true)` (into the player inventory, filling from the last hotbar slot backwards). Otherwise (a player slot): `moveItemStackTo(stack, 0, 9R, reverse = false)` (into the chest, from slot 0). No other filter and no final progress test. Because Pass A of `moveItemStackTo` runs before Pass B, partial stacks are topped up first.

### 7.4 Lifecycle (M6)

Described by the shared model plus: `startOpen` and `stopOpen` of the container drive the opener counter, lid animation, sounds and, for the barrel, the `open` block state (31-1 §8, §10 to §12). A double chest is one menu over the `CompoundContainer`: slots 0 to 26 map to the first half's container slots 0 to 26 and slots 27 to 53 to the second half's (31-1 §10.2 and its worked example 4 say which half is first for a given chest orientation); the menu cannot tell the halves apart.

### 7.5 Screen (M7)

`ContainerScreen`: image 176 x (114 + 18 R); `inventoryLabelY` = `imageHeight - 94` (the same as the generic default); title at (8, 6). `extractBackground` draws the generic background, then two blits of `textures/gui/container/generic_54.png` (256 x 256) at `(leftPos, topPos)` where `leftPos = (guiW - imageWidth)/2` and `topPos = (guiH - imageHeight)/2`:

| Blit | Destination | Source (u, v) | Size |
|---|---|---|---|
| top (chest rows and the frame above them) | (`leftPos`, `topPos`) | (0, 0) | 176 x (18 R + 17) |
| bottom (inventory part) | (`leftPos`, `topPos` + 18 R + 17) | (0, 126) | 176 x 96 |

The two heights add to `18 R + 113`, one pixel less than `imageHeight`, so the last pixel row of the image is not covered by either blit (the screen background shows through that row; whether the texture's row there is empty was not checked, Open question 2). The sheet is shared by all six sizes: the top blit takes more or fewer rows of the chest area.

---

## 8. The shulker box (`ShulkerBoxMenu`, `ShulkerBoxSlot`, `ShulkerBoxScreen`)

### 8.1 Identity (M1)

| Item | Value |
|---|---|
| `MenuType` | `shulker_box`, id 20 |
| Menu class | `ShulkerBoxMenu`; client constructor `ShulkerBoxMenu(containerId, inventory)` over `SimpleContainer(27)`; server constructor over the block entity's container |
| Screen | `ShulkerBoxScreen` |
| Title | the block entity's display name (default `container.shulkerBox`, "Shulker Box"; a custom name replaces it; the colour of the box does not change the title) |

Constants: `CONTAINER_SIZE` = 27. The constructor: `checkContainerSize(container, 27)`, `container.startOpen(player)`, 3 x 9 `ShulkerBoxSlot`s, then `addStandardInventorySlots(inventory, 8, 84)`.

### 8.2 Slot table (M2): 63 slots

| Menu slot index | Container slot | x, y | Slot class |
|---|---|---|---|
| `0 .. 26`, `col + 9 x row` | shulker box 0 to 26 | `(8 + 18 x col, 18 + 18 x row)`, row 0 to 2 | `ShulkerBoxSlot` |
| `27 .. 53` | player inventory 9 to 35 | `(8 + 18 x col, 84 + 18 x row)` | `Slot` |
| `54 .. 62` | player inventory 0 to 8 | `(8 + 18 x i, 142)` | `Slot` |

**May-place rule** (`ShulkerBoxSlot.mayPlace(stack)`): `stack.getItem().canFitInsideContainerItems()`. The default for items is true; `BlockItem` overrides it to `not (block is a ShulkerBoxBlock)`. So every shulker box block item (the undyed box and the 16 colours; 17 item definition files named `*shulker_box.json` exist in the jar, `unzip -Z1` count, so 17 items is inferred from that) is refused by the 27 shulker slots, and every other item is accepted. (Bundles consult the same method for what may go into a bundle.) `mayPickup` is the default (true). The rule applies to the slot, so it also governs `safeInsert`, SWAP, the quick-move into empty slots (Pass B of `moveItemStackTo` checks `mayPlace`) and drag distribution; it does not apply to merging into an existing stack (Pass A), which cannot involve a shulker box because none can be inside.

The block entity applies its own sided-access rule for automation (31-1 §13.4: shulker boxes cannot be placed into a shulker box through a face); the menu rule above is separate and concerns the player.

### 8.3 Quick-move (M5)

Template 3.6 with `size = container.getContainerSize()` (27): `index < 27`: `moveItemStackTo(stack, 27, slotCount, true)` (into the player inventory); otherwise `moveItemStackTo(stack, 0, 27, false)` (into the box). A shulker box item in the player's inventory shift-clicked into an open shulker box moves nowhere: Pass A finds no merge target of a shulker kind, Pass B finds every empty slot refusing it (`mayPlace` false), so `moveItemStackTo` returns false and the click does nothing.

### 8.4 Lifecycle (M6)

`stillValid` = `container.stillValid(player)` (31-1 §9.1); `removed` = superclass `removed`, then `container.stopOpen(player)`, which for the shulker box block entity decrements its open count and may start the closing animation (31-1 §13.3).

### 8.5 Screen (M7)

`ShulkerBoxScreen`: image **176 x 167** (not 166), titles at (8, 6), `inventoryLabelY = 167 - 94 = 73` (the constructor derives it from the height passed). Background: one blit of `textures/gui/container/shulker_box.png` (256 x 256) at (`leftPos`, `topPos`), source (0, 0), size 176 x 167. The same texture serves every colour.

---

## 9. The hopper (`HopperMenu`, `HopperScreen`)

### 9.1 Identity (M1)

| Item | Value |
|---|---|
| `MenuType` | `hopper`, id 16 |
| Menu class | `HopperMenu`; client constructor over `SimpleContainer(5)`; `CONTAINER_SIZE` = 5 |
| Users | the hopper block entity and the hopper minecart (`MinecartHopper`) |
| Screen | `HopperScreen` |
| Title | `container.hopper` ("Item Hopper") or the custom name |

The constructor: `checkContainerSize(hopper, 5)`, `startOpen(player)`, 5 plain slots, `addStandardInventorySlots(inventory, 8, 51)`.

### 9.2 Slot table (M2): 41 slots

| Menu slot index | Container slot | x, y | Slot class |
|---|---|---|---|
| `0 .. 4` | hopper 0 to 4 | `(44 + 18 x i, 20)` | `Slot` |
| `5 .. 31` | player inventory 9 to 35 | `(8 + 18 x col, 51 + 18 x row)` | `Slot` |
| `32 .. 40` | player inventory 0 to 8 | `(8 + 18 x i, 109)` | `Slot` |

No slot filter. (The hopper block entity's own `canPlaceItem` and `canTakeItem` govern automation, not the menu; 30-4.)

### 9.3 Quick-move (M5)

Template 3.6: `index < container size (5)`: `moveItemStackTo(stack, 5, slotCount, true)`; otherwise `moveItemStackTo(stack, 0, 5, false)`. No progress test.

### 9.4 Lifecycle (M6)

`stillValid` = `hopper.stillValid(player)`; `removed` = superclass, then `stopOpen`. For the hopper minecart the container's `stillValid` is the entity's (not read here; 44 and 18 cover the minecart).

### 9.5 Screen (M7)

`HopperScreen`: image **176 x 133**, `inventoryLabelY = 133 - 94 = 39`, title at (8, 6). Background: one blit of `textures/gui/container/hopper.png` (256 x 256) at (`leftPos`, `topPos`), source (0, 0), size 176 x 133.

---

## 10. Dispenser and dropper (`DispenserMenu`, `DispenserScreen`)

### 10.1 Identity (M1)

| Item | Value |
|---|---|
| `MenuType` | `generic_3x3`, id 6 |
| Menu class | `DispenserMenu`; client constructor over `SimpleContainer(9)` |
| Users | the dispenser and the dropper block entities (the dropper entity subclasses the dispenser entity and creates the same `DispenserMenu`; only its default name differs) |
| Screen | `DispenserScreen`, used for both |
| Titles | `container.dispenser` ("Dispenser"), `container.dropper` ("Dropper"), or a custom name |

Constants of the class: `SLOT_COUNT` 9, `INV_SLOT_START` 9, `INV_SLOT_END` 36, `USE_ROW_SLOT_START` 36, `USE_ROW_SLOT_END` 45. The constructor: `checkContainerSize(dispenser, 9)`, `startOpen(player)`, `add3x3GridSlots(dispenser, 62, 17)`, `addStandardInventorySlots(inventory, 8, 84)`.

### 10.2 Slot table (M2): 45 slots

| Menu slot index | Container slot | x, y | Slot class |
|---|---|---|---|
| `0 .. 8`, index = `col + 3 x row` | dispenser `col + 3 x row` | `(62 + 18 x col, 17 + 18 x row)`, col and row 0 to 2 | `Slot` |
| `9 .. 35` | player inventory 9 to 35 | `(8 + 18 x col, 84 + 18 x row)` | `Slot` |
| `36 .. 44` | player inventory 0 to 8 | `(8 + 18 x i, 142)` | `Slot` |

No slot filter (any item, including shulker boxes, may be placed by hand).

### 10.3 Quick-move (M5)

This menu does not use the plain template of 3.6. For `index`: `slot` has an item, `stack` = its stack, `ret` = a copy of it.

1. `index < 9` (a dispenser slot): `moveItemStackTo(stack, 9, 45, true)` (into the player's main inventory and hotbar together, filling from the last hotbar slot backwards); if false return the empty stack.
2. Otherwise: `moveItemStackTo(stack, 0, 9, false)`; if false return the empty stack.
3. If `stack` is empty `slot.setByPlayer(EMPTY)`, else `slot.setChanged()`.
4. **Progress test**: if `stack.count == ret.count` (nothing was moved) return the empty stack.
5. `slot.onTake(player, stack)`; return `ret`.

(The ranges 9 to 45 treat the main inventory and the hotbar as one range, so for a move out of the dispenser the filling order is hotbar 8, 7, ..., 0, then main 35 down to 9: the reverse scan.)

### 10.4 Lifecycle (M6)

`stillValid` = `dispenser.stillValid(player)`; `removed` = superclass, then `stopOpen`. Dispensing and dropping (the block's behaviour) are in 30-4; the menu and the block share only the container.

### 10.5 Screen (M7)

`DispenserScreen`: image 176 x 166 (the default), `inventoryLabelY` 72 (the default), `titleLabelY` 6. In `init()`, after the superclass, `titleLabelX = (imageWidth - font.width(title)) / 2` (integer division), centring the title: so the title is centred in the 176-pixel image, not at x = 8. Background: one blit of `textures/gui/container/dispenser.png` (256 x 256) at (`leftPos`, `topPos`), source (0, 0), size 176 x 166. The dropper uses the same screen and texture.

---

## 11. Worked examples

### 11.1 Geometry

Double chest (R = 6), window 854 x 480 at GUI scale 1: `imageHeight = 222`, `leftPos = (854 - 176) / 2 = 339`, `topPos = (480 - 222) / 2 = 129`. Chest slot 0 is at screen (347, 147); slot 53 (col 8, row 5) at (8 + 144, 18 + 90) = (152, 108) relative, screen (491, 237). The main inventory starts at menu slot 54 at relative (8, 139); the hotbar is menu slots 81 to 89 at relative y = 197; the inventory label is drawn at relative (8, 128). The two background blits: (339, 129) from (0, 0) size 176 x 125, and (339, 254) from (0, 126) size 176 x 96; the image's last row (screen y 350) is covered by neither.

Hopper: slot 2 is at relative (44 + 36, 20) = (80, 20); player main inventory menu slot 5 at (8, 51); hotbar menu slot 36 (container slot 4) at (8 + 72, 109) = (80, 109).

Dispenser: dispenser slot 5 (col 2, row 1) at (62 + 36, 17 + 18) = (98, 35). Title "Dispenser" at (176 - w) / 2 where w is the pixel width of the rendered title.

### 11.2 Clicks on a chest slot

Chest slot holds 7 cobblestone, cursor empty.

- SECONDARY pick-up: amount `(7 + 1) / 2 = 4`: cursor 4, slot 3. PRIMARY: cursor 7, slot empty.
- Cursor holds 5 cobblestone, slot holds 60 cobblestone: PRIMARY: `safeInsert(c, 5)`: room `64 - 60 = 4`, n = 4: slot 64, cursor 1. SECONDARY: amount 1, n = 1: slot 61, cursor 4.
- Cursor 5 cobblestone, the clicked slot holds 2 oak planks: PRIMARY: `mayPlace` true, different kind, `5 <= 64`: swap: the cursor now holds 2 oak planks and the slot holds 5 cobblestone.
- Click on slot -999 with cursor 5: PRIMARY drops all 5; SECONDARY drops one and leaves 4.

### 11.3 Shift-click in a single chest

Menu slot 62 (hotbar slot 8, 27 chest slots, so hotbar slot 8 is menu index 27 + 27 + 8 = 62) holds 64 cobblestone; chest slot 0 holds 60 cobblestone, the rest are empty.

`quickMoveStack(62)`: `ret` = a copy of 64 cobblestone. Index 62 >= 27: `moveItemStackTo(stack, 0, 27, false)`. Pass A: slot 0: total 124 over the limit 64; `t.count 60 < 64`: stack shrinks by 4 (to 60), slot 0 becomes 64. Slots 1 to 26 are empty, skipped in Pass A. Pass B: slot 1 is empty and accepts: it receives `split(min(60, 64))` = 60; stack empty, the scan stops. Return true. The slot at 62 is set empty. `quickMoveStack` returns `ret` (count 64). Back in `doClick`: `ret` is not empty but the slot at 62 now holds nothing, so `isSameItem` is false and the loop ends.

If the chest is completely full: `moveItemStackTo` returns false, `quickMoveStack` returns the empty stack, nothing changes. If only 10 more items fit: 10 move, the slot keeps 54, `ret` is a 64 copy, the slot still holds cobblestone, so `quickMoveStack` runs again, finds no room (false), returns empty and the loop ends.

### 11.4 Drag distribution

Cursor holds 10 cobblestone; the player left-drags (type 0) over three empty chest slots A, B, C.

Packets: (slot -999, button 0, QUICK_CRAFT), (A, 1), (B, 1), (C, 1), (-999, 2). Server: header 0 sets type 0 and status 1; each header 1 adds a slot only if `carried.count (10) >= setSize + 1` is true at that time (10 >= 1, 2, 3) and the slot is empty or the same kind; header 2: n = 3, `placeCount = floor(10 / 3) = 3`, each slot gets `min(3 + 0, 64) = 3`, `remaining = 10 - 9 = 1`. Cursor 1. The order in which the three slots are visited does not change the outcome, because each slot's result depends only on n, the carried count and its own existing content. Right-drag (type 1): packets with buttons 4, 5, 5, 5, 6; each slot gets 1; cursor 7.

Drag over one slot only: the end packet finds a one-slot set, resets and performs PICKUP with button 0 (type 0) or 1 (type 1) on it: type 0 places all 10, type 1 places one.

A drag over 11 slots with a cursor of 10: the 11th header-1 packet is rejected (10 >= 11 is false) and that slot is not added.

### 11.5 State id

The server sent Set Container Content with state id 32767; a later Set Container Slot gets `(32767 + 1) & 32767 = 0`. If the client then sends a click carrying state id 32767 (it had not yet seen the newest packet), the server sees 32767 != 0: the click is still applied, then `broadcastFullState()` resends all slots (state id 1).

### 11.6 Swap

Hotbar slot 2 (button 2) holds 20 arrows; clicked chest slot 5 is empty: `h` not empty, `s` empty, `mayPlace` true: n = `min(99, 64)` = 64; `h.count 20 <= 64`: hotbar slot 2 becomes empty and the chest slot holds 20 arrows. Reverse: hotbar slot empty and the clicked chest slot holds 40 arrows: `h` empty, `s` not empty, `mayPickup` true: hotbar slot gets the 40 arrows (a reference to the same stack), `onSwapCraft(40)` runs (a no-op for a plain slot), the chest slot is emptied and `onTake` runs.

---

## 12. Validation

An implementation of this part is checked by these tests (inputs and outputs follow from the sections cited).

1. Menu registry: 25 entries with the ids of 2.1; `crafting` is 12, `hopper` 16, `shulker_box` 20, `generic_3x3` 6.
2. Slot counts: `generic_9xR` has `9R + 36`, shulker box 63, hopper 41, dispenser 45. Slot index i maps as in 3.3 for each.
3. Player-inventory mapping: in every menu of this part the main inventory slots are at `N .. N+26` mapped to inventory 9 to 35 (row-major), and the hotbar at `N+27 .. N+35` mapped to inventory 0 to 8.
4. Every position of 7.2, 8.2, 9.2, 10.2 and the `Y0` table (7.2), including hopper hotbar y 109 and dispenser grid origin (62, 17).
5. `imageHeight`: chest 114 + 18R, shulker 167, hopper 133, dispenser 166; label y values of the 7.2 table, 73 (shulker), 39 (hopper), 72 (dispenser).
6. `moveItemStackTo` on the cases of 11.3; a non-stackable item into a full chest returns false; a stackable item merges into an existing stack before using an empty slot (Pass A before Pass B); only one empty slot is filled per call.
7. Quick-move ranges: chest `[9R, total)` reversed and `[0, 9R)` forward; shulker `[27, 63)` reversed and `[0, 27)`; hopper `[5, 41)` reversed and `[0, 5)`; dispenser `[9, 45)` reversed and `[0, 9)`; the dispenser's progress test returns empty for a no-op move, the others do not test.
8. Shulker slot rule: every shulker box item (17, inferred) refused in menu slots 0 to 26 for PICKUP, SWAP and drag, and by quick-move; accepted in slots 27 to 62; any other item accepted everywhere.
9. Each click table entry of 3.4 on small inventories (pickup half `(n + 1) / 2`, swap rule, double-click scan order, drag split `floor`, single-slot drag becoming PICKUP, outside drop, THROW with button 0 and 1, CLONE only with infinite materials).
10. Synchronisation: opening sends Open Screen then Set Container Content (state id 1 for the first menu of a fresh counter after the id was 0; the counter id follows `(c % 100) + 1`); a change of a slot between ticks produces one Set Container Slot with state id +1; a client prediction whose hash matches the real result produces no Set Container Slot; a stale state id produces a full resend after applying the click; Set Container Data carries 16-bit values; the carried stack uses Set Cursor Item.
11. Close: Container Close from the client runs `removed`: the carried stack goes back to the inventory; a menu that fails `stillValid` is closed by the server tick.
12. Screen: centring with integer division at GUI scale 1 (`(854 - 176) / 2 = 339`); the chest background blits of 7.5; the 18 x 18 hit cell; the highlight sprites at (x - 4, y - 4) 24 x 24.

---

## Open questions

1. **GUI width and height.** `guiWidth` and `guiHeight` are the scaled window size; the scale factor rule (12 §5) was not re-read in this round, only its use in `init()` (`width`, `height` of `Screen`). The statement in 5.1 that they are the window size divided by the GUI scale is from 12, not from this round.
2. **Last pixel row of the chest screen.** The two blits cover `18 R + 113` of the `114 + 18 R` rows. Resolved this round by decoding the PNG: `generic_54.png` is 256 x 256, 4-bit palette (colour type 3), 7 palette entries, with a tRNS chunk making only palette index 0 transparent. Nothing is drawn by the chest blits in the uncovered destination row, so the texture's transparency is irrelevant to it: whatever lies beneath (the dimmed in-game gradient, 12 §5.6) shows through that row. The texture row never sampled by either blit (row 125) is fully opaque (indices 1, 2, 4, 6 only in columns 0 to 175), so it is a separator row simply left out. Remaining: nothing, apart from the unverified pixel-exact appearance of that row on screen (inferred from the blit arithmetic).
3. **Hash function for the predicted stacks.** The `HashedStack` and per-component hash algorithm is in 00; this part only uses the equality result. The per-player cache size 256 was read in `ServerPlayer$1` (a Guava cache), and its eviction does not change results.
4. **`Player.drop(stack, true, prediction)` semantics.** The second argument is taken as "throw" (inferred from the call sites: 3.4 uses it for cursor drops, THROW and swap overflow); the physics and the `PREDICTED` and `SERVER_ONLY` prediction modes (the latter used for the carried stack when a menu closes) are covered by 41 and 17, not re-read.
5. **Quick-craft count below zero.** In clone-type drags `remaining` can reach 0 or below; `setCount` of a non-positive number is taken to give an empty stack (inferred from the `isEmpty` definition used throughout: count 0 or less).
6. **Item click behaviour overrides.** `tryItemClickBehaviourOverride` calls `ItemStack.overrideStackedOnOther` and `overrideOtherStackedOnMe`; only bundles implement them. The bundle rules, the bundle scroll mouse actions (`BundleMouseActions`) and the packet that selects a bundle item (`setSelectedBundleItemIndex`) are not covered by this part (a bundle document should).
7. **A menu type with no screen.** What happens to a server menu after Open Screen for a type the client has no screen for (cannot happen with the 25 registered types) was not traced beyond the client's warning.
8. **Hopper minecart `stillValid`.** Not read; the hopper block entity's rule is the shared one of 31-1 §9.1.
9. **Unvalidated inputs.** SWAP with a negative slot such as -1, -999, -2 or -5: `isValidSlotIndex` accepts every negative number (it has no lower bound, 3.4), so an index like -5 passes the 4.4 guard; PICKUP, QUICK_MOVE, CLONE, THROW and PICKUP_ALL then return on any negative slot, while the SWAP branch of `doClick` has no negative-index guard (unlike those five), so it would read a slot at a negative list index; the client never sends it and the outcome (an exception in the click handler, inferred) was not traced; the guard-by-guard comparison above is unchanged; THROW on an empty slot (the take yields an empty stack; whether `Player.drop` then does nothing was not traced).
10. **Sounds and tutorial hooks.** No sound is played by the menu code read here (item pickup and drop sounds come from the entity code); `Player.updateTutorialInventoryAction` is a tutorial hook and is not specified.
11. **Slot highlight and no-item-icon art.** The `slot_highlight_back.png` and `slot_highlight_front.png` sprites are both 24 x 24 pixels (PNG header read this round); each `.mcmeta` holds `gui.scaling` with type `nine_slice`, width 24, height 24, border 4.
12. **Chest minecart and chest boat.** They use `threeRows` over their own container (so they have the same slot table); their titles, `stillValid` and open or close behaviour belong to 44 and 34 and were not read here.
13. **Which container-block interactions open which menu with which title.** Covered by 31-1 (chest, barrel, ender chest, shulker box) and 30-4 (dispenser, dropper, hopper); this part gives only the menu side.
14. **Creative inventory screen interaction.** `handleContainerSetSlot` and `handleSetCursorItem` contain tests for `CreativeModeInventoryScreen` (ignoring a Set Cursor Item while it is open; skipping the open-menu write for a slot packet while its picker tab is shown). The exact conditions belong to the creative screen part and were read only as far as 4.3 states. In `handleContainerSetSlot` the creative-screen flag is read once and tested again only on a path that needs container id 0 inside the open-menu branch, which the earlier id-0 branch has already taken, so for the open-menu write (non-zero id) the flag has no effect (bytecode read); the remaining use is the post-write refresh of the inventory menu's remote slot.
