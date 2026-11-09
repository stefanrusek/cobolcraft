# 40-3 Menus and screens, part 3: item combiner base, anvil, grindstone, smithing table

| Item | Value |
|---|---|
| Covers | The `ItemCombinerMenu` / `ItemCombinerScreen` base and the three menus that use it or sit beside it: `AnvilMenu` / `AnvilScreen` (two inputs, result, rename text field and its packet, the cost data slot, the "too expensive" display, the full repair-cost, rename, repair and enchantment-merge rules, the result-take rules, anvil wear, pixel positions of the text field, cost label and error sprite), `GrindstoneMenu` / `GrindstoneScreen` (two inputs, result, merge and disenchant rules, experience refund, `mayPlace` rules, error sprite) and `SmithingMenu` / `SmithingScreen` (template, base and addition slots, result, recipe matching, the error data slot, the armor-stand preview, the cycling template-hint icons, tooltips, pixel coordinates). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`). |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of data files in the same jar (PNG headers, `lang/en_us.json`, a few JSON tags and enchantment files for examples), with no execution. Every value was read in this round unless marked "(inferred)" or "(recalled, not verified)"; both kinds are listed in Open questions (none remain marked in the text). |
| Round | RS14, part 3 (design map `docs/design/README.md` GAP-19). Siblings: 40-1 (shared model, chest family, hopper, dispenser), 40-2 (furnaces, brewing stand, crafter), 40-4 (enchanting table, loom, stonecutter, cartography table), 40-5 to 40-8. This part does not repeat them. |
| Related | 40-1 (§3.2 `Slot`, §3.3 appending the player inventory, §3.4 click types, §3.5 `moveItemStackTo`, §3.6 quick-move template, §3.7 data slots, §3.8 closing and guards, §4 synchronisation, §5 generic container screen, §6 table schema M1 to M9), 05a (Open Screen 0x3C, Container Set Data 0x13, Set Container Slot 0x14), 05c 0x31 (Rename Item), 17 §4.10 (experience orb tiers), 17 §5.4 to §5.7 (earlier, shorter prose of the anvil, grindstone and repair rules; this document supersedes it where they differ, see §9), 27 §1.3, §3.3, §4.3 (smithing recipes, property sets), 28 (enchantment data fields), 25-8 §8 (smithing template items), 46 §5.5 (menu type ids), 12 §5.6 to §5.10 (GUI drawing). |

Class names appear in backticks only to say where a fact was read. They are provenance, not design.

Content that is data is not tabulated: textures and sprites (the pixel art comes from the extracted resource pack, 08 and 22), `lang` strings (except the few that the layout depends on), recipes, enchantment definitions, item and block tags, and the `repairable` components. This document specifies the schema each engine reads, the semantics, and the engines. The three menus are the same in the standard and the cobolcraft world types (design map rule R2); only the item identities named follow the content set.

All coordinates are relative to (`leftPos`, `topPos`) of the screen image, in GUI pixels, unless said otherwise. All three screens use the default image size 176 x 166 (no constructor passes another size), the default inventory label at (8, 72), and `addStandardInventorySlots(inventory, 8, 84)` (40-1 §3.3). Each background texture is a 256 x 256 PNG (headers read: `anvil.png`, `grindstone.png`, `smithing.png`), blitted from region (0, 0, 176, 166) at (`leftPos`, `topPos`).

---

## 1. Identity and shared facts (table M1)

| | Anvil | Grindstone | Smithing table |
|---|---|---|---|
| Menu class | `AnvilMenu` (extends `ItemCombinerMenu`) | `GrindstoneMenu` (extends `AbstractContainerMenu` directly, it does not use the combiner base) | `SmithingMenu` (extends `ItemCombinerMenu`) |
| `MenuType` key and id | `anvil`, 8 | `grindstone`, 15 | `smithing`, 21 |
| Screen class | `AnvilScreen` (extends `ItemCombinerScreen`) | `GrindstoneScreen` (extends `AbstractContainerScreen`) | `SmithingScreen` (extends `ItemCombinerScreen`) |
| Client factory | the `(containerId, inventory)` constructor, with `ContainerLevelAccess.NULL` | same | same; also takes `inventory.player.level()` |
| Server factory | the block's menu provider, with a level access for the block position | same | same |
| Default title (key, English) | `container.repair` "Repair & Name" | `container.grindstone_title` "Repair & Disenchant" | `container.upgrade` "Upgrade Gear" |
| Bound block | block tag `anvil` (data: `anvil`, `chipped_anvil`, `damaged_anvil`) | `grindstone` | `smithing_table` |
| Interaction stat (46) | `interact_with_anvil` | `interact_with_grindstone` | `interact_with_smithing_table` |
| Menu slot count | 3 + 36 = 39 | 3 + 36 = 39 | 4 + 36 = 40 |
| Data slots | 1 (id 0: cost) | none | 1 (id 0: recipe error) |

How the blocks open the menus (read from `AnvilBlock`, `GrindstoneBlock`, `SmithingTableBlock`, each `useWithoutItem`): on the client the use returns SUCCESS and does nothing else; on the server it calls `Player.openMenu` with a simple menu provider built from the block position and the title above, then `awardStat` of the interaction stat, then returns SUCCESS. Open Screen (05a 0x3C) carries the menu type id and the title component.

**Block binding.** `ContainerLevelAccess` is the pair (level, position) on the server and `NULL` on the client. `access.execute(f)` runs `f(level, pos)` only for a real access; `access.evaluate(f, default)` returns `default` for `NULL`.

**`stillValid(player)`** (40-1 §3.8): the combiner base evaluates, with the level access and default true: the block at the position must satisfy `isValidBlock` (anvil: tag `anvil`; smithing: block `smithing_table`), and the player must be within block interaction range of the position plus 4.0 (`isWithinBlockInteractionRange(pos, 4.0)`). The grindstone uses the plain block-bound helper of 40-1 §3.8 with the block `grindstone`. With the `NULL` access all three are true.

**Infinite materials** means the player's `abilities.instabuild` flag (creative mode).

**Level events** used by these menus (data: client handler of Level Event, 05a): the client plays a local sound at the block position, source `BLOCKS`, volume 1.0 (anvil land 0.3), distance delay off, with pitch `nextFloat() x 0.1 + 0.9` (one client random draw per event):

| Event | Sound event | Sent by |
|---|---|---|
| 1029 | `anvil.destroy` | anvil take, the block was destroyed |
| 1030 | `anvil.use` | anvil take, the block survived (or infinite materials) |
| 1031 | `anvil.land` (volume 0.3) | a falling anvil, not used by the menus |
| 1042 | `grindstone.use` | grindstone take |
| 1044 | `smithing_table.use` | smithing take |

---

## 2. The item combiner base (`ItemCombinerMenu`, `ItemCombinerMenuSlotDefinition`)

### 2.1 Slot definition (builder rules)

A menu builds an `ItemCombinerMenuSlotDefinition` from: input slots, each (slot index, x, y, `mayPlace` predicate), and one result slot (index, x, y). `build` throws `IllegalArgumentException` when (a) the input indexes are not exactly 0, 1, 2, ... in order ("Expected input slots to have continous indexes"), (b) the result index is not the number of inputs ("Expected result slot index to follow last input slot"), or (c) there are no inputs or no result ("Need to define both inputSlots and resultSlot"). So the layout is always: inputs `0 .. n-1`, result `n`, then the 36 inventory slots `n+1 .. n+36`.

### 2.2 Construction (order matters for slot indexes)

1. Create the result container (`ResultContainer`: one slot, plus a remembered "recipe used", default none) with a `setChanged` hook that calls `slotsChanged(thisContainer)`.
2. Store the level access and the player (`inventory.player`).
3. Create the input container (`SimpleContainer` of n slots, default stack limit 99) whose `setChanged` calls `slotsChanged(thisContainer)` after the normal behaviour.
4. Add the n input slots in order, then the result slot, then `addStandardInventorySlots(inventory, 8, 84)`.

### 2.3 Slots (table M2 form)

| Slot | `mayPlace` | `mayPickup` | `onTake` |
|---|---|---|---|
| input i | the predicate given in the definition | default (true) | default |
| result | always false | `menu.mayPickup(player, slot.hasItem())` (the menu hook, default true) | `menu.onTake(player, stack)` (abstract) |

Menu hooks: `mayPickup(player, hasItem)` default true; `onTake(player, stack)` abstract; `isValidBlock(state)` abstract; `canMoveIntoInputSlots(stack)` default true; `createResult()` abstract.

### 2.4 Behaviour common to the base

- `slotsChanged(container)`: the base behaviour (`broadcastChanges`, 40-1 §3.8), and when `container` is the input container, `createResult()`. A change of the result container does not call `createResult`. `createResult` runs on both sides (the client menu recomputes from the stacks it holds); the server's packets overwrite the client's guess.
- `removed(player)`: the base behaviour (carried stack returns to the player), then `access.execute(clearContainer(player, inputSlots))`: on the server every input stack goes back to the inventory or is dropped (40-1 §3.8). The result slot is not returned.
- `stillValid`: section 1.

### 2.5 Quick-move (table M5), shared by the anvil and the smithing table

Let `R` = the result slot index (= n), `INV0` = `R + 1`, `INV1` = `INV0 + 27` (end of the main inventory), `HB0` = `INV1`, `HB1` = `HB0 + 9`. Follows the template of 40-1 §3.6 (copy first, move, `setByPlayer(EMPTY)` or `setChanged`, return the copy; the caller repeats while the slot still holds the same kind). The branch is chosen by the source index, in this order:

| Order | Source index | Target range | Reverse | If nothing moved |
|---|---|---|---|---|
| 1 | `R` (result) | `[INV0, HB1)` | true | return empty; otherwise `slot.onQuickCraft(moved, copy)` is called after the move |
| 2 | `0 .. R-1` (an input) | `[INV0, HB1)` | false | return empty |
| 3 | in `[INV0, HB1)` and `canMoveIntoInputSlots(stack)` | `[0, R)` | false | return empty |
| 4 | in `[INV0, INV1)` (main) | `[HB0, HB1)` (hotbar) | false | return empty |
| 5 | in `[HB0, HB1)` (hotbar) | `[INV0, INV1)` (main) | false | return empty |

Branches 4 and 5 are reached only when `canMoveIntoInputSlots` is false. After the branch: if the remaining stack is empty the source slot is set to EMPTY, otherwise `setChanged`; if the remaining count equals the pre-move copy count return empty (no progress); otherwise `slot.onTake(player, remaining)` is called, and the copy is returned. Note that `slot.onTake` is therefore also called for non-result slots (it is a no-op for them) and for the result slot it is the menu's `onTake` (one result per call, the caller loops).

`moveItemStackTo` (40-1 §3.5) honours `mayPlace` for empty target slots only (merging into a non-empty slot of the same kind does not check it).

### 2.6 The client screen base (`ItemCombinerScreen`)

- Constructor takes the background texture identifier (anvil: `textures/gui/container/anvil.png`; smithing: `textures/gui/container/smithing.png`).
- `init`: the generic init, then the subclass hook `subInit()`, then the screen registers itself as a slot listener of the menu (`addSlotListener`); `removed` unregisters it. `dataChanged(menu, id, value)` does nothing; `slotChanged(menu, slot, stack)` does nothing by default (the anvil and smithing screens override it).
- `extractBackground`: the generic background (40-1 §5.2), then one `GUI_TEXTURED` blit of the texture region (0, 0, `imageWidth`, `imageHeight`) from the 256 x 256 sheet to (`leftPos`, `topPos`), then the subclass's `extractErrorIcon(leftPos, topPos)`.

---

## 3. Anvil (`AnvilMenu`, `AnvilScreen`)

### 3.1 Slots (table M2): 39 slots

| Menu slot | Container, slot | x, y | Class and rules |
|---|---|---|---|
| 0 (left, "input") | input container, 0 | 27, 47 | combiner input slot, `mayPlace` always true |
| 1 (right, "additional") | input container, 1 | 76, 47 | combiner input slot, `mayPlace` always true |
| 2 (result) | result container, 0 | 134, 47 | combiner result slot (section 2.3); `mayPickup` and `onTake` in 3.4 and 3.5 |
| 3 to 29 | player inventory 9 to 35 | 8 + 18 col, 84 + 18 row | standard |
| 30 to 38 | player hotbar 0 to 8 | 8 + 18 i, 142 | standard |

Constants of the class: `MAX_NAME_LENGTH` 50; the cost constants are listed in 3.3.

### 3.2 Data slot (table M3)

| Id | Meaning | Range | Writer |
|---|---|---|---|
| 0 | the level cost of the current result (0 when there is no result) | 0 to 2147483647 in memory; on the wire a signed 16-bit short (05a 0x13, `writeShort`), so a cost above 32767 (possible for a player with infinite materials, and also in survival: step 12 stores the clamped total before the too-expensive step 15 empties the result, e.g. an item whose `repair_cost` was inflated in creative or by command) is truncated to its low 16 bits and sign-extended by the client | `createResult` (both sides), `onTake` (sets 0) |

### 3.3 `createResult` (the engine)

Terms: `L` = left stack (slot 0), `R` = right stack (slot 1), `res` = a copy of `L`, `ench` = a mutable copy of `L`'s enchantments, `cost` = a running int (the "added cost"), `base` = a running long (the "prior work" cost), `renameCost` = int 0, `repairUnits` = 0 (an instance field read by `onTake`; it is reset in step 3, after early exit A, not in step 1), `onlyRenaming` = false (instance field, reset in step 1).

**Damageable** (`ItemStack.isDamageableItem`, read): true only when the stack has a `max_damage` component, has NO `unbreakable` component, and has a `damage` component. `maxDamage(stack)` is the `max_damage` component, default 0 when absent. `setDamageValue(d)` stores `clamp(d, 0, maxDamage)` (both bounds apply, not only the lower one). Consequences: an unbreakable item is never "damageable", so it skips the anvil repair (step 6), durability-merge (step 8) and combine-requires-damageable (step 7) branches, and the grindstone `mayPlace` (4.1) refuses it unless it is enchanted. `enchOf(stack)` = the `stored_enchantments` component for an `enchanted_book`, the `enchantments` component for everything else (default empty); every item has an `enchantments` component (empty) and a `repair_cost` of 0 by default (`DataComponents.COMMON_ITEM_COMPONENTS`, read), so every non-empty stack can carry enchantments. `hover(stack)` = the plain string of `custom_name` if the stack has one, else of the stack's item name (`ItemStack.getHoverName`: `custom_name`, else `getItemName`; the default `Item.getName(stack)` returns the `item_name` component, default empty text, read; that `getItemName` forwards to `Item.getName(stack)` is inferred from the call, and an item class may override `getName(stack)`, which was not surveyed, Open question 13). The rename-versus-default comparison in step 11 uses this string. `repairCost(stack)` = the `repair_cost` component, default 0.

Steps (numbered behaviour, in order):

1. Reset: `onlyRenaming` = false; the cost data slot is set to 1 (this value is overwritten in step 12 or cleared by an early exit). (`repairUnits` is not reset here.)
2. **Early exit A**: if `L` is empty, or `L` cannot store enchantments (never true for a non-empty stack, see above), set the result slot to EMPTY, set the cost data slot to 0, and stop.
3. `res` = copy of `L`; `ench` = copy of `enchOf(res)`; `base` = `repairCost(L) + repairCost(R)` (`R` empty has 0); `repairUnits` = 0 (read: this reset follows early exit A and precedes the empty-`R` test; it is unobservable because `onTake` only runs with a non-empty result).
4. If `R` is empty, go to step 11 (rename only).
5. `bookAdd` = whether `R` has the `stored_enchantments` component (an enchanted book, or any stack that carries it).
6. **Repair with material** (if `res` is damageable and `L.isValidRepairItem(R)`, that is `R`'s item is in `L`'s `repairable` set): let `step` = `min(damage(res), maxDamage(res) / 4)` (integer division). If `step <= 0`: **Early exit B** (result EMPTY, cost 0, stop). Otherwise loop with `used` = 0: while `step > 0` and `used < R.count`: `damage = damage - step` (clamped at 0 by `setDamageValue`), `cost += 1`, recompute `step` = `min(damage, maxDamage / 4)`, `used += 1`. Set `repairUnits` = `used`. Go to step 11 (enchantments are not merged on this path).
7. Otherwise (combining). **Early exit C**: if `bookAdd` is false and (`res`'s item is not `R`'s item, or `res` is not damageable): result EMPTY, cost 0, stop.
8. **Durability merge**: if `res` is damageable and `bookAdd` is false: `a` = `maxDamage(L) - damage(L)`, `b` = `maxDamage(R) - damage(R)`, `bonus` = `b + maxDamage(res) x 12 / 100` (integer), `remaining` = `a + bonus`, `newDamage` = `max(maxDamage(res) - remaining, 0)`. If `newDamage < damage(res)`: `damage(res) = newDamage` and `cost += 2`.
9. **Enchantment merge**: `addEnch` = `enchOf(R)`. `anyApplied` = false, `anyRejected` = false. For every entry (e, lr) of `addEnch`, in the iteration order of the enchantment map:
   1. `ll` = the level of e in `ench` (0 if absent). `n` = `lr + 1` if `ll == lr`, else `max(lr, ll)`. (Despite the parameter names, the level comparison is "equal levels go up by one".)
   2. `can` = `e.canEnchant(L)` (`L`'s item is in e's `supported_items` set). `can` is forced true when the player has infinite materials or `L` is an `enchanted_book`.
   3. For every enchantment `x` currently in `ench` (including ones added earlier in this loop) with `x != e`: if `x` and `e` are not compatible (`areCompatible` is false when either one's `exclusive_set` contains the other), `can` = false and `cost += 1`. This check is NOT skipped for infinite materials; it adds 1 per incompatible enchantment already present.
   4. If `can` is false: `anyRejected` = true; continue with the next entry.
   5. `anyApplied` = true. `n` = `min(n, e.maxLevel)` (the cap applies in every mode, including infinite materials). `ench[e] = n` (the mutable map's `set(e, n)`: removes the entry when `n <= 0`, otherwise stores `min(n, 255)`, so a data-pack `max_level` above 255 still stores at most 255).
   6. `ac` = e's `anvil_cost`; if `bookAdd`, `ac` = `max(1, ac / 2)` (integer division). `cost += ac x n`.
   7. If `L.count > 1`: `cost = 40` (assignment, replaces the running value; the data-slot value is then at least 40, which fails in survival, step 15).
10. **Early exit D**: if `anyRejected` and not `anyApplied`: result EMPTY, cost 0, stop.
11. **Rename** (reached from steps 4, 6 and 10): let `name` = the menu's `itemName` (an instance field, null until the client sends one). If `name` is null or blank (section 3.7): if `L` has a `custom_name`: `renameCost` = 1, `cost += 1`, remove `custom_name` from `res`. Else (non-blank): if `name` differs from `hover(L)`: `renameCost` = 1, `cost += 1`, set `res`'s `custom_name` to the literal text `name`. Otherwise no rename cost.
12. `total` = if `cost <= 0` then 0 else `clamp(base + cost, 0, 2147483647)`. The cost data slot is set to `total`.
13. If `cost <= 0`: `res` = EMPTY.
14. **Only renaming**: if `renameCost == cost` and `renameCost > 0`: if the cost data slot is 40 or more, set it to 39; set `onlyRenaming` = true.
15. **Too expensive**: if the cost data slot is 40 or more and the player does not have infinite materials: `res` = EMPTY.
16. **New repair cost**: if `res` is not empty: `rc` = `repairCost(res)`; if `rc < repairCost(R)`, `rc` = `repairCost(R)`. Unless (`renameCost == cost` and `renameCost != 0`): `rc` = `min(2 x rc + 1, 2147483647)` (the function `calculateIncreasedRepairCost`). Set `res`'s `repair_cost` to `rc`; write `ench` back with `setEnchantments` (to `stored_enchantments` for a book, `enchantments` otherwise).
17. Store `res` in the result slot (EMPTY included) and `broadcastChanges`.

Constants read: repair cost growth factor 2 and offset 1; durability bonus 12 percent for item-item combining; the divisor 4 for the per-unit repair step; the threshold 40; the lowered cost 39; the max name length 50. The class constants `COST_BASE` 1, `COST_ADDED_BASE` 1, `COST_REPAIR_MATERIAL` 1, `COST_REPAIR_SACRIFICE` 2, `COST_INCOMPATIBLE_PENALTY` 1, `COST_RENAME` 1 match the values used above; `COST_FAIL` is 0.

Growth of `repair_cost` for an item that is only enchanted or repaired: 0, 1, 3, 7, 15, 31, 63 (each use maps `rc` to `2 rc + 1`); a pure rename never changes it. Once `base` (the sum of the two stacks' repair costs) plus the added cost reaches 40, survival players get no result.

### 3.4 Taking the result

`mayPickup(player, hasItem)` (the hook behind the result slot's `mayPickup`): true when (the player has infinite materials OR `player.experienceLevel >= cost data slot`) AND the cost data slot is greater than 0 (read: the conjunction, so a creative player is also refused while the data slot is 0 or negative, including a negative value produced by the 16-bit wire truncation of 3.2). (The screen colours the cost label red when this is false, 3.8; for a creative player that only matters when `c <= 0`, where no label is drawn anyway.)

### 3.5 `onTake(player, stack)` (the engine)

In order:

1. If the player does not have infinite materials: `player.giveExperienceLevels(-cost data slot)`. That method adds the amount to the level with a saturating add and, if the level becomes negative, sets level, progress and total experience to 0; for a non-negative result it changes only the level (the progress fraction and the total-experience counter are not touched, read).
2. Right slot: if `repairUnits > 0`: if the right slot is non-empty and its count is greater than `repairUnits`, shrink it by `repairUnits` and store it back; otherwise empty the slot. Else, if `onlyRenaming` is false, empty the right slot (an item-item or book merge consumes the whole right stack). Else (a pure rename) the right slot is left alone.
3. Set the cost data slot to 0.
4. On the server, if the player is a `ServerPlayer`, the `itemName` is not blank and differs from `hover(L)` of the left slot: the name is passed to the player's text filter (`processStreamMessage`, a fire-and-forget moderation call; its result is not used in the menu).
5. Empty the left slot.
6. `access.execute`: with the block state at the position: if the player does not have infinite materials and the block is in the tag `anvil` and `player.getRandom().nextFloat() < 0.12`: compute the damaged state (`AnvilBlock.damage`: `anvil` becomes `chipped_anvil`, `chipped_anvil` becomes `damaged_anvil`, `damaged_anvil` gives none; `facing` is copied). If none: remove the block (no drops, flag false) and send level event 1029. Else set the block state with flags 2 and send level event 1030. In every other case (infinite materials, a roll of 0.12 or more, a block outside the tag) send level event 1030. The random draw happens only when the first two conditions hold.

The input container's `setChanged` fires on steps 2 and 5, so `createResult` runs again with the stacks as they are at that moment; after step 5 the left slot is empty and the result slot is empty with cost 0 again.

### 3.6 Quick-move (table M5)

Section 2.5 applies with `R` = 2: `INV0` 3, `INV1` 30, `HB0` 30, `HB1` 39. `canMoveIntoInputSlots` is true for the anvil, so branch 3 always applies to a stack in the player inventory (target slots 0 and 1, merging first, then the first empty slot that accepts; both accept anything). Branches 4 and 5 are never reached: if both input slots are occupied and nothing merges, shift-click on an inventory slot does nothing.

### 3.7 Rename: packet and server handling

- Packet: Serverbound Rename Item (05c 0x31), one string. The wire type is the default `readUtf` limit (32767 characters, 05c).
- Server (`ServerGamePacketListenerImpl.handleRenameItem`): runs on the main thread; if the player's open menu is an `AnvilMenu` and `stillValid(player)` is true, calls `menu.setItemName(name)`; if `stillValid` is false it logs at debug level and returns; any other open menu ignores the packet.
- `setItemName(raw)`: `v` = `filterText(raw)`: keep a character only if it is allowed (not `§` 167, not below 32, not 127; newlines are dropped). If the length of `v` is greater than 50 the name is rejected (`v` = none). If `v` is none or equals the current `itemName`: return false (no change, no recompute). Otherwise store `itemName = v`; if the result slot has an item, edit that stack in place (blank: remove `custom_name`; else set `custom_name` to the literal) so that it reflects the new name at once; call `createResult()`; return true.
- Blank test (`StringUtil.isBlank`): null, empty, or every character satisfies `Character.isWhitespace` or `Character.isSpaceChar` (the predicate is `StringUtil.isWhitespace`, read from the bootstrap method handle).
- The server never clears `itemName` itself: it keeps the last accepted value until a new packet arrives (the menu object is new for every opening, so it starts null).

### 3.8 Screen (table M7): `AnvilScreen`

| Item | Value |
|---|---|
| Image size, labels | 176 x 166; `titleLabelX` is set to 60 in the constructor (`titleLabelY` stays 6); the inventory label stays at (8, 72); both labels `#404040`, no shadow (40-1 §5.3) |
| Background | `textures/gui/container/anvil.png` region (0, 0, 176, 166) |
| Name field widget | an `EditBox` at (`leftPos` + 62, `topPos` + 24), 103 x 12, narration message key `container.repair`. Settings applied: cannot lose focus; text colour white (`#FFFFFFFF`, int -1) for both editable and uneditable; invert-highlighted-text off; no border; max length 50; value set to "". Defaults left as the widget has them (read from its constructor): shadowed text, value limit 32 before `setMaxLength`, default text colour int -2039584 (overridden). With no border the text origin is (x, y) of the widget (a bordered box would add 4 on x and centre on y); the inner width is the widget width (103) when unbordered and width minus 8 when bordered |
| Responder | `onNameChanged(text)`, section below |
| Editable | the field is editable exactly when slot 0 has an item (checked in `subInit` and in `slotChanged`) |
| Initial focus | the name field |
| Field background sprite | drawn after the generic background in `extractBackground`: `container/anvil/text_field` when slot 0 has an item, else `container/anvil/text_field_disabled`; at (`leftPos` + 59, `topPos` + 20), 110 x 16 (both PNGs read as 110 x 16, no `.mcmeta`, so they are drawn unscaled) |
| Error sprite | `container/anvil/error` (28 x 21, read): drawn at (`leftPos` + 99, `topPos` + 45), 28 x 21, when (slot 0 has an item or slot 1 has an item) and the result slot has no item |
| Tick | `containerTick` sets the local player's `experienceDisplayStartTick` to its `tickCount` every tick (keeps the experience bar showing while the screen is open) |
| Resize | `resize(w, h)` saves the field value, runs `init`, restores the value |
| Keys | Escape closes the container (`closeContainer`, which sends Container Close); otherwise the field gets the key (`keyPressed`); if the field handled it, or the field `canConsumeInput`, the key is consumed (so the inventory key does not close the screen while the field is focused); otherwise the generic handling (40-1 §5.5) |

**`onNameChanged(text)`** (the responder): `slot` = menu slot 0; if it has no item: return. `name` = `text`; if the stack has no `custom_name` and `text` equals `hover(stack)`: `name` = "" (so that leaving an item's default name unchanged is "no rename"). Call the client menu's `setItemName(name)` (the same engine as 3.7, run locally on the client menu so the preview updates); if it returned true, send Rename Item with `name`. (The menu applies the same length-50 and character filter as the server; the field's own limit is also 50.)

**`slotChanged(menu, slot, stack)`**: only for `slot == 0`: set the field value to "" when `stack` is empty, else `hover(stack)`; set the field editable when `stack` is not empty; give the field focus. `setValue` runs the responder, so each change of the left slot sends a Rename Item with the new default name when the server's `itemName` would differ.

**Cost label** (`extractLabels`, drawn in label space after the two generic labels, so with the origin at (`leftPos`, `topPos`)): `c` = the client's cost data slot. Nothing when `c <= 0`. Otherwise colour `#FF80FF20` (int -8323296); then:

| Condition | Text | Colour |
|---|---|---|
| `c >= 40` and the local player has no infinite materials | `container.repair.expensive` ("Too Expensive!") | `#FFFF6060` (int -40864) |
| else, result slot has no item | no text and no box | |
| else | `container.repair.cost` with the integer `c` ("Enchantment Cost: %1$s") | `#FF80FF20`, or `#FFFF6060` when the result slot's `mayPickup(player)` is false (not enough levels) |

When there is text: `x` = `imageWidth - 8 - width(text) - 2` = `166 - width(text)`, `y` = 69. First a rectangle is filled from (`x - 2`, 67) to (`imageWidth - 8` = 168, 79) with colour `#4F000000` (int 1325400064), then the text is drawn at (`x`, 69) with a shadow (the five-argument `text` overload shadows) in the colour above.

### 3.9 Anvil quick-move and lifecycle summary (tables M5, M6)

Quick-move: 3.6. Lifecycle: `stillValid` and `removed` as in section 2.4 (input slots are returned on close); `slotsChanged` recomputes the result; there are no containers to open or close.

---

## 4. Grindstone (`GrindstoneMenu`, `GrindstoneScreen`)

### 4.1 Slots (table M2): 39 slots

The grindstone has its own two containers: `repairSlots` (a `SimpleContainer` of 2 whose `setChanged` calls `slotsChanged(thisContainer)`) and `resultSlots` (a `ResultContainer`).

| Menu slot | Container, slot | x, y | Class and rules |
|---|---|---|---|
| 0 (top input) | `repairSlots`, 0 | 49, 19 | `mayPlace(stack)` = the stack is damageable or has any enchantments (`isDamageableItem` or `EnchantmentHelper.hasAnyEnchantments`, which is item-independent: true when the `enchantments` component is non-empty OR the `stored_enchantments` component is non-empty, whatever the item; this differs from `enchOf` of 3.3, which chooses the component by item, and the two are kept apart in 4.3) |
| 1 (bottom input) | `repairSlots`, 1 | 49, 40 | the same `mayPlace` as slot 0 |
| 2 (result) | `resultSlots`, 0 | 129, 34 | `mayPlace` false; `mayPickup` default true; `onTake` in 4.4 |
| 3 to 29 | player inventory 9 to 35 | 8 + 18 col, 84 + 18 row | standard |
| 30 to 38 | player hotbar 0 to 8 | 8 + 18 i, 142 | standard |

Class constants read: `INPUT_SLOT` 0, `ADDITIONAL_SLOT` 1, `RESULT_SLOT` 2, `INV_SLOT_START` 3, `INV_SLOT_END` 30, `USE_ROW_SLOT_START` 30, `USE_ROW_SLOT_END` 39, `MAX_NAME_LENGTH` 35 (unused by the menu logic read here).

### 4.2 Data slots, buttons

None. The menu has no data slots and no `clickMenuButton` use.

### 4.3 `slotsChanged` and the result (the engine)

`slotsChanged(container)`: the base behaviour, then, if `container` is `repairSlots`, `createResult`. `createResult` stores `computeResult(slot 0 stack, slot 1 stack)` in the result slot and calls `broadcastChanges`. It runs on both sides.

`computeResult(a, b)` (numbered):

1. `anyPresent` = `a` non-empty or `b` non-empty. If not: EMPTY.
2. If `a.count > 1` or `b.count > 1`: EMPTY (the grindstone only takes single items).
3. `both` = `a` non-empty and `b` non-empty.
4. **Single item** (`both` false): `s` = the non-empty one. If `s` has no enchantments (`hasAnyEnchantments` false: both `enchantments` and `stored_enchantments` are empty, whatever the item): EMPTY (a damaged-but-unenchanted single item gives nothing). Otherwise the result is `removeNonCurses(copy of s)`.
5. **Two items** (`both`): `mergeItems(a, b)`.

`mergeItems(a, b)`:

1. If `a`'s item is not `b`'s item: EMPTY.
2. `M` = `max(maxDamage(a), maxDamage(b))`; `ra` = `maxDamage(a) - damage(a)`; `rb` = `maxDamage(b) - damage(b)`; `remaining` = `ra + rb + M x 5 / 100` (integer).
3. `count` = 1. If `a` is not damageable: if `a`'s item max stack size is less than 2, or `a` and `b` are not equal under `ItemStack.matches` (read: true on reference equality; otherwise the two counts must be equal AND the stacks must be the same item with equal components; the count is compared, not ignored, but both are already at most 1 here, so it cannot change the outcome), the result is EMPTY; otherwise `count` = 2.
4. `res` = a copy of `a` with the count `count`. If `res` is damageable: set its `max_damage` component to `M` and its damage to `max(M - remaining, 0)`.
5. `mergeEnchants(res, b)`: for each enchantment (e, level) of `enchOf(b)`: if e is not in the tag `enchantment/curse`, or `res` currently has level 0 of e: `upgrade(e, level)` (read: ignored when `level <= 0`; otherwise merges `min(level, 255)` with the current level by taking the maximum, so the stored level never exceeds 255; an absent entry counts as 0). The anvil's `set(e, n)` rule is in 3.3 step 9.5 (removes at `n <= 0`, caps at 255). The other items' enchantments therefore move across, curses only if the result lacks them (data: the tag `enchantment/curse` holds `binding_curse` and `vanishing_curse`, read).
6. Return `removeNonCurses(res)`.

Two enchantment helpers are used and must not be confused: `hasAnyEnchantments(stack)` (input `mayPlace`, step 4, quick-move placement) is item-independent as described in 4.1; `removeNonCurses`, the experience sum and the can-store test use `enchOf` (`stored_enchantments` for `enchanted_book`, `enchantments` otherwise).

`removeNonCurses(s)`: remove every enchantment not in the tag `enchantment/curse` from `enchOf(s)` (via `updateEnchantments`). If `s` is an `enchanted_book` and no enchantment remains, replace it by a `book` (`transmuteCopy`: same count and components, new item). Then set `repair_cost`: start at 0 and apply `calculateIncreasedRepairCost` (n -> 2n + 1, anvil 3.3) once for each enchantment that remains, so with k remaining curses the cost is 0, 1, 3, 7 for k = 0, 1, 2, 3. Return `s`.

Notes on what this means: merging two unenchanted, equal items is allowed and yields a repaired item; two enchanted books or two non-stackable non-damageable items give no result (max stack size below 2); two unrelated items give no result, shown by the error arrow.

### 4.4 Taking the result (the engine, `GrindstoneMenu$4.onTake`)

In order:

1. `access.execute(level, pos)`: if `level` is a `ServerLevel`: `T` = the sum, over slot 0 and slot 1 of the current inputs, of `getExperienceFromItem`: for every enchantment e at level l in `enchOf(stack)` that is NOT in the tag `enchantment/curse`, add `e.getMinCost(l)` = `minCost.base + minCost.per_level_above_first x (l - 1)` (data fields in 28 and 17 §6). If `T > 0`: `h` = `ceil(T / 2)`, `xp` = `h + nextInt(h)` where the random source is the level's (`Level.getRandom`, one draw); else `xp` = 0. `ExperienceOrb.award(serverLevel, centre of pos, xp)` (orb value tiers: 17 §4.10 Experience; nothing is spawned for `xp <= 0`). The award rule (read): while the remaining amount is above 0, take the next orb value `v` from the tier mapping (the largest tier that fits), subtract it, then try to merge: draw one `nextInt(40)` from the same level random (call it `d`), and look in a 1 x 1 x 1 box centred on the award position for the first unremoved orb whose entity id minus `d` is divisible by 40 and whose value equals `v`. If one is found its count is increased by 1 and its age reset to 0 (no orb is spawned); otherwise a new orb of value `v` is spawned there with zero velocity. So the number of level-random draws of one grindstone take is 1 (the xp roll, only when `T > 0`) plus 1 per orb of the split, merged or not. The periodic 0.5-block merge between living orbs is a separate rule (not part of this award). In every case (also on the client's access, but there the access is `NULL` so nothing runs) level event 1042 is sent afterwards.
2. Set slot 0 and slot 1 of `repairSlots` to EMPTY (each `setItem` triggers `createResult`).

The experience is computed from the inputs before they are emptied; the result's enchantments play no part.

### 4.5 Quick-move (table M5)

Indexes as in 4.1; `moveItemStackTo` target ranges are exclusive at the end. Branch order:

| Order | Source | Target | Reverse | Otherwise |
|---|---|---|---|---|
| 1 | 2 (result) | `[3, 39)` | true | none moved: return empty; else `slot.onQuickCraft(moved, copy)` |
| 2 | 0 or 1 | `[3, 39)` | false | none moved: return empty |
| 3 | any other, when slot 0 is empty or slot 1 is empty | `[0, 2)` | false | none moved: return empty |
| 4 | `[3, 30)` (main), both inputs occupied | `[30, 39)` | false | none moved: return empty |
| 5 | `[30, 39)` (hotbar), both inputs occupied | `[3, 30)` | false | none moved: return empty |

After the branch the common ending of 2.5 applies (empty or `setChanged`, no-progress test, `onTake`). In branch 3 stacks are placed into the input slots through `moveItemStackTo`, which only fills an empty input slot when `mayPlace` accepts (damageable or enchanted).

### 4.6 Lifecycle (table M6)

- `stillValid`: block `grindstone` (section 1).
- `removed(player)`: the base behaviour, then `access.execute(clearContainer(player, repairSlots))`.
- `slotsChanged`: 4.3.

### 4.7 Screen (table M7): `GrindstoneScreen`

| Item | Value |
|---|---|
| Image size, labels | 176 x 166, labels at (8, 6) and (8, 72), `#404040`; no overrides |
| Background | `textures/gui/container/grindstone.png` region (0, 0, 176, 166), drawn after the generic background |
| Error sprite | `container/grindstone/error` (28 x 21, read), at (`leftPos` + 92, `topPos` + 31), 28 x 21, when (slot 0 has an item or slot 1 has an item) and the result slot has no item |
| Widgets | none; no tick behaviour; no slot listener |

---

## 5. Smithing table (`SmithingMenu`, `SmithingScreen`)

### 5.1 Slots (table M2): 40 slots

The menu is a combiner with three inputs. The `mayPlace` of an input slot is a test against a **recipe property set** that the menu fetches from the level's recipe access when it is built: slot 0 uses `smithing_template`, slot 1 `smithing_base`, slot 2 `smithing_addition` (27 §4.3 for how the sets are built from the loaded smithing recipes and sent in Update Recipes; the client menu reads the sets it received). `RecipePropertySet.test(stack)` is true when the stack's item is in the set (read: `test` checks that the stack's item holder is in the set; `create` builds the set as the union of the item sets of all given ingredients, an unmodifiable set; the three keys are `smithing_template`, `smithing_base`, `smithing_addition`).

| Menu slot | Container, slot | x, y | Class and rules |
|---|---|---|---|
| 0 (template) | input container, 0 | 8, 48 | combiner input; `mayPlace` = template set contains the item |
| 1 (base) | input container, 1 | 26, 48 | `mayPlace` = base set contains the item |
| 2 (addition) | input container, 2 | 44, 48 | `mayPlace` = addition set contains the item |
| 3 (result) | result container, 0 | 98, 48 | combiner result slot; `mayPickup` default true; `onTake` in 5.4 |
| 4 to 30 | player inventory 9 to 35 | 8 + 18 col, 84 + 18 row | standard |
| 31 to 39 | player hotbar 0 to 8 | 8 + 18 i, 142 | standard |

Constants read: `TEMPLATE_SLOT` 0, `BASE_SLOT` 1, `ADDITIONAL_SLOT` 2, `RESULT_SLOT` 3, x placements 8, 26, 44 and 98, y placement 48.

### 5.2 Data slot (table M3)

| Id | Meaning | Range | Writer |
|---|---|---|---|
| 0 | recipe error flag | 0 or 1 | `slotsChanged`, on a server level only (the client's value comes from packets); initialised to 0 in the constructor |

`slotsChanged(container)`: the base behaviour (which calls `createResult` for the input container), then, only when the level is a `ServerLevel`: set the data slot to 1 when slot 0, slot 1 and slot 2 all have items and the result slot has none; otherwise 0. The hook is also entered when the result container changes (`setChanged` on it), so the flag is also refreshed then. It is therefore 1 exactly when the three slots are full and no recipe matched.

### 5.3 `createResult` (the engine)

1. Build the `SmithingRecipeInput` from slots 0, 1, 2 (template, base, addition).
2. On a `ServerLevel`: look up the first loaded `smithing` recipe that matches the input in registry order (`RecipeManager.getRecipeFor(SMITHING, input, level)`, 27 §3.3 and §6.1: the template, base and addition must each pass their ingredient test, where an absent template or addition ingredient means the corresponding slot must be empty). On a client level: no recipe.
3. If a recipe was found: `res = recipe.assemble(input)` (27 §3.3: `smithing_transform` copies the base's components onto the result item; `smithing_trim` yields one trimmed copy of the base, or EMPTY if the same trim is already present); set the result container's "recipe used" to the holder and store `res` in the result slot. If none: set "recipe used" to none and the result slot to EMPTY. So the client menu always shows an empty result until the server sends Set Container Slot for the result slot.

### 5.4 Taking the result and quick-move

`onTake(player, stack)`, in order:

1. `stack.onCraftedBy(player, stack.count)` (crafting statistic and triggers, 27 and 17).
2. `resultSlots.awardUsedRecipes(player, [slot 0, slot 1, slot 2 stacks])` (27 §4.6: recipe unlock award).
3. For slot index 0, then 1, then 2: if the slot is not empty, shrink it by 1 and store it back (each store triggers `createResult` and the error-flag refresh).
4. `access.execute`: send level event 1044 at the position.

Shift-click and `canMoveIntoInputSlots(stack)` (the override): true when (the template set accepts the stack and slot 0 is empty) or (the base set accepts it and slot 1 is empty) or (the addition set accepts it and slot 2 is empty); false otherwise. Section 2.5 applies with `R` = 3: `INV0` 4, `INV1` 31, `HB0` 31, `HB1` 40. A stack that fits none of the roles is shuffled main to hotbar or hotbar to main (branches 4 and 5). A stack that fits a role is moved to `[0, 3)`, where `moveItemStackTo` first merges into occupied slots of the same kind and then fills the first empty slot whose `mayPlace` accepts it.

`canTakeItemForPickAll(stack, slot)` (double-click gather): false for the result slot, otherwise the base rule. Read: only `SmithingMenu` overrides it; `AnvilMenu`, `GrindstoneMenu` and `ItemCombinerMenu` do not, so the default (true) applies there and the anvil and grindstone result slots are NOT excluded from double-click gathering.

Lifecycle (table M6): `stillValid` block `smithing_table` (section 1); `removed` returns the three input stacks (`clearContainer`); `slotsChanged` 5.2.

### 5.5 Screen (table M7): `SmithingScreen`

| Item | Value |
|---|---|
| Image size, labels | 176 x 166; `titleLabelX` 44, `titleLabelY` 15 (constructor); inventory label stays at (8, 72) |
| Background | `textures/gui/container/smithing.png` region (0, 0, 176, 166) |
| Error sprite | `container/smithing/error` (28 x 21, read) at (`leftPos` + 65, `topPos` + 46), 28 x 21, drawn (by `extractErrorIcon`) when the menu's error flag is true |
| Preview box | the rectangle (`leftPos` + 121, `topPos` + 20) to (`leftPos` + 161, `topPos` + 80), 40 x 60 |
| Cycling icons | three `CyclingSlotBackground` helpers for slots 0, 1, 2 (section 5.6) |
| Title | `container.upgrade` ("Upgrade Gear") |

**Draw order** (`extractRenderState`): the generic render (background: gradient, texture blit, error sprite, then the three cycling icons, then the armor-stand preview; then labels, slots, hover highlights and carried stack of 40-1 §5.2), then `extractOnboardingTooltips`. The icons are therefore under the slot items and the preview is under the slot art highlights.

### 5.6 Cycling template-hint icons (`CyclingSlotBackground`)

Each helper has: a slot index, a current icon list (initially empty), a tick counter (initially 0) and an icon index (initially 0). Constants read: change period 30 ticks, icon size 16, transition duration 4 ticks.

- Per tick (`containerTick`, once per client tick): the screen computes `tmpl` = the `SmithingTemplateItem` in slot 0 if slot 0 is non-empty and its item is one, else none. It calls `tick(list)` on: the slot 0 helper with the fixed list [`container/slot/smithing_template_armor_trim`, `container/slot/smithing_template_netherite_upgrade`]; the slot 1 helper with `tmpl`'s base-slot icon list (empty list when none); the slot 2 helper with `tmpl`'s addition-slot icon list (empty list when none).
- `tick(list)`: if `list` is not equal to the current list, store it and reset the icon index to 0 (the tick counter is NOT reset). Then, if the list is not empty: increment the tick counter; if the new value is a multiple of 30, icon index = (icon index + 1) mod list size.
- Draw (`extractRenderState(menu, graphics, partialTick, leftPos, topPos)`): nothing when the list is empty or the slot has an item. `transitioning` = list size greater than 1 and tick >= 30. `alpha` = if transitioning, `min((tick mod 30) + partialTick, 4) / 4`, else 1. If `alpha < 1`: first draw the previous icon (index - 1, floor mod list size) with alpha `1 - alpha`. Then draw the current icon with alpha `alpha`. Drawing an icon: sprite blit, 16 x 16, at (`leftPos` + slot.x, `topPos` + slot.y), tinted white with that alpha.

Icon lists (code, read from `SmithingTemplateItem`; sprite names are in `container/slot/`):

| Template kind | Base slot icons, in order | Addition slot icons, in order |
|---|---|---|
| armor trim | helmet, chestplate, leggings, boots | ingot, redstone_dust, lapis_lazuli, quartz, diamond, emerald, amethyst_shard |
| netherite upgrade | helmet, sword, chestplate, pickaxe, leggings, axe, boots, hoe, shovel, nautilus_armor, spear | ingot |

The slot 0 list is the two template icons above. The sprite files exist under `textures/gui/sprites/container/slot/` (`helmet`, `chestplate`, `leggings`, `boots`, `hoe`, `axe`, `sword`, `shovel`, `spear`, `pickaxe`, `ingot`, `redstone_dust`, `quartz`, `emerald`, `diamond`, `lapis_lazuli`, `amethyst_shard`, `nautilus_armor`, `smithing_template_armor_trim`, `smithing_template_netherite_upgrade`; `ingot` and `smithing_template_armor_trim` read as 16 x 16).

### 5.7 Tooltips (`extractOnboardingTooltips`)

A tooltip text is chosen as follows (later rules override earlier ones), then drawn through `setTooltipForNextFrame(font, font.split(text, 115), mouseX, mouseY)` (wrapped at width 115):

1. If the error flag is true and the pointer is inside the 28 x 21 box at (65, 46) (relative to `leftPos`, `topPos`): `container.upgrade.error_tooltip` ("Item can't be upgraded this way").
2. If a slot is hovered: let `t` = slot 0's stack and `h` = the hovered slot's stack. If `t` is empty: when the hovered slot index is 0, `container.upgrade.missing_template_tooltip` ("Add Smithing Template"). Else if `t`'s item is a `SmithingTemplateItem` and `h` is empty: hovered index 1 gives the template's base-slot description, hovered index 2 the template's addition-slot description (other indexes: nothing).

Descriptions (data, `lang`): armor trim: base "Add a piece of armor", addition "Add ingot or crystal"; netherite upgrade: base "Add diamond armor, weapon, or tool", addition "Add Netherite Ingot". (keys `item.minecraft.smithing_template.armor_trim.base_slot_description`, `...additions_slot_description`, and the `netherite_upgrade` pair.)

### 5.8 Armor-stand preview (the result preview)

A client-side render state of an armor stand: entity type armor stand, base plate hidden, arms shown, `xRot` 25.0, `bodyRot` 210.0. It is drawn each frame in the box of 5.5 with the entity-in-GUI draw: scale 25, translation (0, 1, 0), rotation = the quaternion built from Euler angles (X = 0.43633232 rad = 25 degrees, Y = 0, Z = 3.1415927 rad = 180 degrees) (`rotationXYZ`), no camera override.

The preview items are updated by `updateArmorStandPreview(resultStack)`: from `subInit` (with slot 3's current stack) and from `slotChanged` whenever slot index 3 changes. Steps: clear the left-hand item, head item, and the head, chest, legs and feet equipment stacks. If the result is non-empty: let `slot` = the `slot` of its `equippable` component (none when it has none).

| Equippable slot | Effect |
|---|---|
| head | if `HumanoidArmorLayer.shouldRender(stack, HEAD)` holds (read: the stack has an `equippable` component whose `asset_id` is present and whose slot equals the given slot; so a head-slot item with no asset id fails it) the stack copy is the head equipment; otherwise the stack is resolved as an item model with display context `HEAD` and shown as the head item |
| chest | a copy is the chest equipment |
| legs | a copy is the legs equipment |
| feet | a copy is the feet equipment |
| any other slot, or no `equippable` component | a copy is the left-hand stack and the item model is resolved with display context `THIRD_PERSON_LEFT_HAND` |

---

## 6. Smithing recipe data the engine reads (cross-reference)

The recipe schemas, the matching rule, the assemble rule and the property sets are in 27 §1.3 (optional ingredients), §3.3 (smithing transform and trim) and §4.3 (property sets). Recipe records are data (extracted by the tool, 22); this part only relies on: `template`, `base`, `addition` ingredients (template and addition optional for the transform type; all required for trim), and the lookup order (first match in registry order). The smithing template items themselves (`SmithingTemplateItem`, kinds armor trim and netherite upgrade) are in 25-8 §8; their tooltip text lines (`appendHoverText`) are: the "Smithing Template" suffix line, a blank line, "Applies to:", the applies-to text indented by one space, "Ingredients:", the ingredients text indented by one space; title lines gray, description lines blue (`item.minecraft.smithing_template*` keys).

---

## 7. Worked examples

All numbers use the rules above; item data (max damage, repairable, supported items, anvil costs) are values read from the jar's data files or 17.

**E1. Repair with material (anvil).** An iron pickaxe, maximum damage 250, damage 100, `repair_cost` 0. Right slot: 3 iron ingots (in the pickaxe's `repairable` set). `step` = `min(100, 250 / 4 = 62)` = 62. Loop: damage 38, cost 1, step `min(38, 62)` = 38, used 1; damage 0, cost 2, step 0, used 2; stop. `repairUnits` = 2. No rename (name blank, no custom name): `cost` = 2, `base` = 0, data slot = 2. New `repair_cost` = 2 x 0 + 1 = 1. The label reads "Enchantment Cost: 2". Taking it costs 2 levels (survival), leaves 1 ingot in slot 1 (`3 > 2`, shrink by 2), clears slot 0, and with probability 0.12 chips the anvil.

**E2. Rename only.** Left: an iron sword with no `custom_name`, `repair_cost` 0; right empty; the player types "Excalibur". `name` differs from `hover(L)` ("Iron Sword"), so `renameCost` = 1, `cost` = 1, data slot = 0 + 1 = 1. `renameCost == cost > 0`: `onlyRenaming` = true, `repair_cost` stays 0 (not 2 x 0 + 1). The result has `custom_name` "Excalibur" and the right slot is untouched on take.
With `repair_cost` 63 on the sword: `base` = 63, total 64, which is at least 40, so the rename-only rule lowers it to 39 and the result is allowed (survival players with 39 or more levels can take it).

**E3. Merge a book into a sword.** A diamond sword with sharpness 3, `repair_cost` 0, plus an enchanted book storing sharpness 3 (sharpness `anvil_cost` 1, max level 5, sword in its supported set). `ll` = 3 = `lr`, so `n` = 4. `can` is true (supported). No other enchantment is present. `n` stays 4 (max 5). Book: `ac` = `max(1, 1 / 2 = 0)` = 1; `cost += 1 x 4` = 4. Data slot = 4, new `repair_cost` 1, result sharpness 4. Taking costs 4 levels and consumes the whole book (the right slot is emptied because `repairUnits` is 0 and `onlyRenaming` is false).

**E4. Incompatible pair.** A sword with sharpness 2 plus a book storing smite 2: sharpness and smite are in the same exclusive set (data `exclusive_set`), so `can` becomes false and `cost += 1`; `anyRejected` is set, `anyApplied` stays false: early exit D, no result (the error arrow shows). With a second book enchantment that is compatible and supported, the merge succeeds and the incompatible one is skipped at a cost of 1.

**E5. Too expensive.** `base` = 31 (left `repair_cost` 31), merge cost 10: data slot 41. Survival: the result is empty, the label shows "Too Expensive!" in red. Creative: the result stays, the label reads "Enchantment Cost: 41", nothing is deducted on take. Stack of 2 or more as left input: only when an enchantment was actually applied in the merge loop (step 9.7) `cost` becomes 40, so the data slot is at least 40 and survival gets no result; with no applied enchantment (a rename, the repair-material path) a left count above 1 does not set 40.

**E6. Repair-cost ladder.** An item enchanted six times on the anvil goes 0, 1, 3, 7, 15, 31, 63. At 63 the next merge has `base` of at least 63, so it is refused in survival.

**E7. Grindstone merge.** Two iron pickaxes (max 250): left damage 100 (remaining 150), right damage 200 (remaining 50). `remaining` = 150 + 50 + 250 x 5 / 100 (= 12) = 212; damage = 250 - 212 = 38; `max_damage` set to 250. Left has efficiency 3 (min cost 1 + 10 x 2 = 21), right has unbreaking 2 (min cost 5 + 8 x 1 = 13) and `vanishing_curse`. `T` = 21 + 13 = 34 (the curse adds nothing); `h` = 17; experience = 17 + `nextInt(17)`, so 17 to 33. The result keeps only the curse (it was copied because the result lacked it), `repair_cost` = 1 (one remaining enchantment).

**E8. Grindstone single item.** A diamond sword with sharpness 5 (min cost 1 + 11 x 4 = 45) and mending: `T` = 45 + (25 + 25 x 0 = 25) = 70; `h` = 35; experience 35 + `nextInt(35)` (35 to 69). The result is the sword without enchantments, `repair_cost` 0. An enchanted book with only unbreaking 3 yields a plain `book` (count 1, same components minus the enchantment) and `T` = 5 + 8 x 2 = 21, `h` = 11, experience 11 + `nextInt(11)`.

**E9. Netherite upgrade.** Template `netherite_upgrade_smithing_template`, base `diamond_sword` (sharpness 5, damage 100), addition `netherite_ingot`. The recipe matches; the result is `netherite_sword` with the base's components (enchantments, damage, name). On take: onCrafted, recipes awarded, one of each of the three stacks removed, level event 1044. The preview: the sword has no `equippable` component, so it appears in the armor stand's left hand. A diamond helmet upgrade: slot head; the humanoid layer draws armour, so the stack is the head equipment.

**E10. Smithing error.** An addition item the addition set does not contain cannot be placed (`mayPlace` refuses it), so the error state comes from valid-looking combinations that fail the recipe match or the assemble rule. Example: a valid armour-trim template, a netherite chestplate that already carries the same trim and material, and that material in the addition slot: all three slots are full, `assemble` gives EMPTY (27 §3.3), the result stays empty, the flag becomes 1, the sprite appears at (65, 46) and the tooltip "Item can't be upgraded this way".

**E11. Layout arithmetic.** Window 854 x 480, GUI scale 1: `leftPos` = (854 - 176) / 2 = 339, `topPos` = (480 - 166) / 2 = 157. The anvil result slot item is at (339 + 134, 157 + 47) = (473, 204). The anvil name field is at (401, 181); its background sprite at (398, 177); the error sprite at (438, 202). The smithing preview box runs from (460, 177) to (500, 237). For a label whose text is W pixels wide the box is filled from (164 - W, 67) to (168, 79) and the text is drawn at (166 - W, 69) (label space); the box therefore starts at x = 164 - W and the text at x = 166 - W, for any W (no concrete width is given; fonts are data).

---

## 8. Validation (table M9)

1. `build` rules: any definition with indexes `0..n-1` then result `n`; anvil has n = 2, result 2; smithing n = 3, result 3. Total slots: anvil 39, grindstone 39, smithing 40 (own slots + 36).
2. Menu type ids from `MenuType` registration order: anvil 8, grindstone 15, smithing 21 (agrees with 46 §5.5).
3. Anvil: unrenamed, unenchanted left with an empty right slot has `cost` 0, so the result is EMPTY and the data slot is 0 (not 1: the 1 set in step 1 is replaced).
4. Anvil: for any non-empty result, data slot = `clamp(base + cost, 0, 2147483647)`, which is below 40 in survival; `repair_cost` of the result = `2 x max(rc(L), rc(R)) + 1` unless rename-only.
5. Anvil: in creative (infinite materials), `onTake` changes neither levels nor the right-slot consumption rule; the cap at the enchantment's maximum level and the incompatibility surcharge still apply.
6. Anvil rename text: a 51-character name is rejected (server and client menu) and no packet is sent; `§`, control characters and 127 are removed before the length test.
7. Grindstone: result is EMPTY for count > 1 on either input; for a single unenchanted item; for two different items.
8. Grindstone: with k remaining curses the result `repair_cost` is 2^k - 1; experience is never produced from curses; `T = 0` spawns no orb but still plays event 1042.
9. Smithing: error flag = 1 iff all three inputs are present and the result slot is empty after `createResult`; on a client level the result slot is always emptied by `createResult` and the flag is only changed by server packets.
10. Quick-move: shift-clicking a stack into a full anvil leaves everything unchanged; shift-clicking a stone block with an empty smithing table moves it main to hotbar (no role accepts it).
11. Layout: slot positions in 3.1, 4.1 and 5.1; error sprite positions (99, 45), (92, 31), (65, 46); the three error sprites are 28 x 21 and the anvil field sprites 110 x 16 (PNG headers read).
12. Wire: the cost data slot as a short: a cost of 70000 (creative, or an inflated `repair_cost`) arrives as 4464 (70000 mod 65536).

---

## 9. Differences from earlier prose (17 §5.4 and §5.5)

This document is read directly from the menu classes and supersedes the following statements of 17. Document 17 itself is outside this round's targets and still carries the earlier statements without a pointer to this part; the orchestrator should add a one-line "superseded by 40-3 §3 and §4" note in 17 §5.4 and §5.5 (Open question 14).

1. **Grindstone result `repair_cost`.** 17 §5.5 says `2n + 1` applied to the number of remaining enchantments. Read: the increase function is applied once per remaining enchantment, starting from 0, so the result is `2^n - 1`.
2. **Grindstone curse merge.** 17 says `upgrade` keeps the higher level. Read: a curse of the second item is carried over only when the result has level 0 of it; non-curses are upgraded and then all non-curses are removed.
3. **Grindstone non-damageable merge.** Requires the item's max stack size of at least 2 (not the stack size) and `ItemStack.matches` (same item, same components and equal counts, which are both at most 1 here); the result count is 2.
4. **Anvil incompatibility in creative.** 17 §5.4 says an incompatible pair adds 1 and skips the enchantment "unless infinite materials". Read: infinite materials only forces the supported-item test to true; the incompatibility test and its surcharge still apply.
5. **Anvil level cap.** Applied in every mode (including infinite materials).
6. **Smithing preview, error flag, hints.** Not covered in 17 or 27; sections 5.2 and 5.5 to 5.8.

---

## Open questions

1. (Closed.) `ItemStack.matches` was read: reference equality, else equal counts and same item with same components (4.3).
2. (Closed, partly inferred.) The `RecipeManager` property-set extractors for `smithing_template` and `smithing_addition` return an Optional ingredient taken from the smithing recipe's optional fields (an empty Optional when the recipe has none); `smithing_base` returns `Optional.of(base)`; `RecipePropertySet.create` takes a Collection of ingredients. So an absent template or addition ingredient contributes no items, and an empty slot is never "accepted" by a set (the flattening of Optionals into the collection is inferred from the `create` signature, not read).
3. The server's `TextFilter.processStreamMessage(itemName)` call in the anvil `onTake` is a moderation side effect; what it does to the named item (nothing visible in this menu) and what a filtered result would change was not read.
4. `EditBox` internals beyond the settings the anvil screen applies (cursor blink timing, word selection, IME overlay, scroll) were not specified here; only the draw rules that matter for the unbordered, white-text case were read (text origin at the widget origin, shadow on, inner width = width when unbordered). A general widget part should cover the rest.
5. `Font.plainSubstrByWidth` and the width of "Enchantment Cost: N" in a concrete font are font data; the layout formulas are exact, the pixel widths are not tabulated.
6. The client computes `createResult` for the anvil and the grindstone too. Whether the temporary client-side result can ever disagree with the server's result is not analysed (the server's Set Container Slot and Set Container Data always overwrite it).
7. `ClientboundContainerSetDataPacket` writes the value as a short. The consequence is derived arithmetic, not observed: 65540 arrives as 4 (label drawn as cost 4, no "Too Expensive!"), 40000 arrives as -25536 (c <= 0, no label). This applies to survival players too (3.2).
8. The ordering of the enchantment iteration (a hash map, 28 Open questions item 6) affects which incompatible enchantment is rejected first and the incompatibility surcharge counts when several enchantments of the right item conflict with each other; the surcharge for each pair is order independent but the set of applied enchantments is not. Not resolved.
9. (Closed.) `HumanoidArmorLayer.shouldRender` was read (5.8).
10. (Closed.) Read: `SmithingScreen`, `ItemCombinerScreen` and `AnvilScreen` contain no recipe-book widget (the only recipe-named member is the private error test of the smithing screen); the recipe-book components in the jar are crafting and furnace ones, and the only smithing class under the screens package is `SmithingScreen.class`.
11. The level event handlers (1029, 1030, 1042, 1044) were read for sound event and pitch; their exact stereo/attenuation parameters beyond volume and pitch are handled by the sound engine (a part of 12's open items).
12. The block-side `useWithoutItem` was read for the three blocks; the shape or collision of the anvil and the falling-anvil behaviour (`anvil.land`, damage on landing) are outside this part (29b, 17).
13. Whether any item class overrides `Item.getName(stack)` (so that `hover(stack)` would differ from the `item_name` component for that item) was not surveyed; `ItemStack.getItemName` forwarding to `Item.getName(stack)` is inferred (3.3). Searched: `ItemStack.getHoverName` and `Item.getName` only.
14. Cross-document conflict: 17 §5.4 and §5.5 still state the superseded rules listed in section 9 and carry no pointer here. 17 is not a target of this fix; it needs a one-line correction by its owner. Also the experience orb tier mapping and the award rule are cross-referenced to 17 §4.10 (Experience) and described in 4.4; a world-simulation part owning orb entities (33) may supersede that cross-reference.
