# 40-5 Menus, part 5: merchant, beacon and lectern

| Item | Value |
|---|---|
| Covers | Three menus and their screens: the trading menu (`MerchantMenu`, `MerchantContainer`, `MerchantResultSlot`, `MerchantScreen` and its row buttons), the beacon (`BeaconMenu`, `BeaconMenu$PaymentSlot`, `BeaconScreen` and its buttons) and the lectern (`LecternMenu`, `LecternScreen`, `BookViewScreen`, `PageButton`). Slot tables, data slots, button ids, quick-move, lifecycle, screen layout in pixels, sprites, packets, and the offer arithmetic (modified price, matching, taking, XP bar, scrollbar) |
| Does not cover | The shared menu model (slot click algorithm, container ids, `moveItemStackTo`, data slot sync, the generic screen): 40-1. The villager and wandering trader entities (trade sets, demand, restocking, gossip, level-up, XP orbs): 19 §22 to §24. The beacon block entity (pyramid scan, beam, effect application): 31 and the block documents. The lectern block entity (`Book`, `Page`, comparator output, block state): 31-4 §3. The wire layout of the offer list and of the three packets: 05a, 05c (cross-referenced, repeated only where a number below depends on it). Written-book content and the book editing and signing screens: 17 and 13 |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the jar's data files and PNG headers (`unzip -p`, `file`), with no execution. Every value was read in this round; anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions |
| Round | RS14 (design map GAP-19), part 5 |
| Related | 40-1 §3 (menu model), §4 (sync), §5 (screen), §6 (the M1 to M9 schema used here); 05a 0x13 (Set Container Data), 0x35 (Merchant Offers), 0x3C (Open Screen); 05c 0x11 (Container Button Click), 0x34 (Select Trade), 0x35 (Set Beacon); 46 §5 (menu ids; the mob-effect id +1 data slot encoding); 12 §5.6 to §5.10 (GUI drawing rules, sprites, text); 19 §22, §23 |

Class names in backticks say where a fact was read. They are not the design. Pixel coordinates are relative to (`leftPos`, `topPos`) unless the text says "screen". Sprite and texture names are data in the vanilla resource pack extracted by the asset tool; they are listed because the code refers to them by name, with the pixel sizes read from the PNG headers. Language strings are data too; the keys and the English texts read are given where a screen shows them.

---

## 1. Shared facts

### 1.1 Menu type ids

`MenuType` registration order (read from the static initialiser) gives the ids sent in Open Screen (05a 0x3C, 46 §5): `generic_9x1` 0, `generic_9x2` 1, `generic_9x3` 2, `generic_9x4` 3, `generic_9x5` 4, `generic_9x6` 5, `generic_3x3` 6, `crafter_3x3` 7, `anvil` 8, **`beacon` 9**, `blast_furnace` 10, `brewing_stand` 11, `crafting` 12, `enchantment` 13, `furnace` 14, `grindstone` 15, `hopper` 16, **`lectern` 17**, `loom` 18, **`merchant` 19**, `shulker_box` 20, `smithing` 21, `smoker` 22, `cartography_table` 23, `stonecutter` 24 (25 entries; 40-1 §2.1 is the full table). The three menus here have no feature flag.

### 1.2 Menu summary

| Menu | Own slots | Total slots | Data slots | Image size | Background texture | Texture size |
|---|---|---|---|---|---|---|
| merchant | 3 | 39 | 0 | 276 x 166 | `textures/gui/container/villager.png` | 512 x 256 |
| beacon | 1 | 37 | 3 | 230 x 219 | `textures/gui/container/beacon.png` | 256 x 256 |
| lectern | 1 | 1 | 1 | not a container screen: the book view of §4.7 | `textures/gui/book.png` | 256 x 256 |

### 1.3 Packets in play

| Packet | Used by | Content that matters here |
|---|---|---|
| Open Screen (05a 0x3C) | all three | container id, menu type id (§1.1), title component |
| Merchant Offers (05a 0x35) | merchant | container id, the offer list (offer layout 05a "MerchantOffer"), villager level, villager XP, show-progress flag, can-restock flag |
| Container Set Data (05a 0x13) | beacon, lectern | container id, property (data slot index, Short), value (Short) |
| Container Button Click (05c 0x11) | lectern | container id, button id (§4.4); the server calls the menu's `clickMenuButton` and, when it returns true, `broadcastChanges` (read: `handleContainerButtonClick`; the packet is ignored when the container id differs from the open menu's, when the player is a spectator, or when `stillValid` fails) |
| Select Trade (05c 0x34) | merchant | one VarInt, the offer index |
| Set Beacon (05c 0x35) | beacon | optional primary and optional secondary mob-effect registry id (the plain registry id, not the +1 of the data slots) |

The wire form of an offer carries the offer's **base** first cost (`getItemCostA`), not the demand-adjusted price: the client recomputes the price from `demand`, `priceMultiplier` and `specialPriceDiff` (§2.4). It also carries an out-of-stock flag in addition to `uses` and `maxUses`; on decode, when the flag is true the offer is forced to out of stock (`uses` := `maxUses`), and `specialPriceDiff` is applied afterwards. The persisted form of an offer (the villager's NBT, 45-6) is a different record: field `Recipes` (a list, default empty) of compounds with `buy` (an item cost, required), `buyB` (optional, a malformed value is ignored), `sell` (an item stack, required), `uses` (default 0), `maxUses` (default 4), `rewardExp` (default true), `specialPrice` (default 0), `demand` (default 0), `priceMultiplier` (default 0.0) and `xp` (default 1). An item cost compound is `id`, `count` (positive int, default 1) and `components` (an exact component predicate, default empty). The flag `rewardExp` is not on the wire.

---

## 2. Merchant (`MerchantMenu`, id 19)

### 2.1 M1 identity

| Item | Value |
|---|---|
| Menu class, type | `MerchantMenu`, `MenuType.MERCHANT` (`merchant`, id 19) |
| Client factory | constructor `(containerId, inventory)`, which builds a `ClientSideMerchant` for the local player (§2.9) |
| Server factory | `Merchant.openTradingScreen(player, title, level)` (a default method of the `Merchant` interface): opens a menu through a simple menu provider whose factory builds `MerchantMenu(containerId, inventory, merchant)`. When the open call returns a container id and the merchant's offer list is not empty, it then calls `player.sendMerchantOffers(containerId, offers, level, merchant.getVillagerXp(), merchant.showProgressBar(), merchant.canRestock())`. So Open Screen is sent first, then Merchant Offers. With an empty offer list the screen opens and no offers packet is sent |
| Screen | `MerchantScreen`, 276 x 166 |
| Title | the component given to `openTradingScreen`: for villagers the display name and the level (19 §22), for the wandering trader level 1 (19 §23) |
| Per-menu state | `merchantLevel` (int, set by the offers packet), `showProgressBar` (boolean), `canRestock` (boolean), the trader (`Merchant`), the trade container (`MerchantContainer`, 3 stacks, §2.3) |

The `Merchant` interface (members read): `getTradingPlayer`/`setTradingPlayer`, `getOffers`/`overrideOffers`, `notifyTrade(offer)`, `notifyTradeUpdated(stack)`, `getVillagerXp`/`overrideXp`, `showProgressBar` (default per class, §2.8), `getNotifyTradeSound`, `canRestock` (default false), `isClientSide`, `stillValid(player)`.

### 2.2 M2 slot table (39 slots)

| Menu slot | Container, slot | x, y | Slot class | Notes |
|---|---|---|---|---|
| 0 | trade container, 0 | (136, 37) | `Slot` | first payment slot |
| 1 | trade container, 1 | (162, 37) | `Slot` | second payment slot |
| 2 | trade container, 2 | (220, 37) | `MerchantResultSlot` | `mayPlace` false; `mayPickup` and `onTake` in §2.5 |
| 3 to 29 | player inventory 9 to 35 | (108 + 18 x col, 84 + 18 x row) | `Slot` | `+0 to +26` of 40-1 §3.3, appended with `(x, y) = (108, 84)` |
| 30 to 38 | player inventory 0 to 8 | (108 + 18 x i, 142) | `Slot` | the hotbar, y = 84 + 58 |

The payment and result slots have no empty-slot icon; their frames are part of the background texture. The trade container reports the default maximum stack size (40-1 §3.2); `setItem` additionally limits the stack to `getMaxStackSize(stack)` (the container default, then the item's own limit, through `limitSize`).

### 2.3 The trade container (`MerchantContainer`)

State: three item stacks (all empty at the start), `activeOffer` (an offer or none), `selectionHint` (int, initially 0) and `futureXp` (int, initially 0).

Container operations:

| Operation | Behaviour |
|---|---|
| `getContainerSize` | 3 |
| `removeItem(slot, n)` | for slot 2 with a non-empty stack: remove and return the whole stack (the count asked for is ignored). Otherwise remove up to n from the slot; when the removed stack is non-empty and the slot is 0 or 1, run `updateSellItem` (§2.4) |
| `removeItemNoUpdate(slot)` | take the whole stack out, no recalculation |
| `setItem(slot, stack)` | store the stack, limit its count to the maximum for that stack, and when the slot is 0 or 1 run `updateSellItem` |
| `setChanged` | `updateSellItem` |
| `stillValid(player)` | true only when `merchant.getTradingPlayer()` is that player (object identity) |

### 2.4 Offer arithmetic (`MerchantOffer`, `MerchantOffers`) and `updateSellItem`

**Modified first cost.** For an offer with base cost count `c`, `demand` d, `priceMultiplier` m and `specialPriceDiff` s:

`adj = max(0, floor(c x d x m))` (the product is computed as a float: `(float)(c x d) x m`), `count = clamp(c + adj + s, 1, maxStackSize of the cost item)`.

Both the modified count (`getCostA`, the stack the player must pay) and the base count (`getBaseCostA`) are used by the screen. The second cost is never modified: `getCostB` returns its stack with its own count, or the empty stack when there is no second cost.

**Matching.** An item cost matches a stack (`ItemCost.test`) when the stack is of the cost's item and the stack's components satisfy the cost's exact component predicate (read in `DataComponentExactPredicate.test`: for each expected component in the predicate's list, the stack's value for that component type is fetched and compared with the expected value by null-safe equality, and the test is true when the list is exhausted. Components on the stack that the predicate does not list are therefore ignored; an expected component that the stack lacks fails unless the expected value is itself null. `ItemCost.test` is exactly "the stack is of the cost's item and the predicate test passes"; an empty predicate always matches). `satisfiedBy(a, b)` holds when: the first cost matches `a` and `a.count >= modified first count`; and, if the offer has a second cost, the second cost matches `b` and `b.count >= second cost count`, else `b` is empty.

**Taking.** `take(a, b)` returns false unless `satisfiedBy(a, b)`. Otherwise it shrinks `a` by the modified first count and, when the second cost stack is non-empty, shrinks `b` by its count, and returns true.

**Looking up an offer.** `getRecipeFor(a, b, hint)`: when `0 < hint < offers.size`, only `offers[hint]` is tried: it is returned when `satisfiedBy(a, b)` holds, otherwise none. For any other hint (so for 0, negative, or out of range) the offer list is scanned from index 0 and the first offer with `satisfiedBy(a, b)` is returned, or none. Selecting the first row is therefore the same as having no preference.

**Other offer facts.** `isOutOfStock`: `uses >= maxUses`. `needsRestock`: `uses > 0`. `assemble`: a copy of the result stack. `increaseUses`: `uses + 1`. `updateDemand`: `demand := demand + uses - (maxUses - uses)` (the villager's restock calls it, 19 §22).

**`updateSellItem`** (called by `setItem`, `removeItem`, `setChanged` and `setSelectionHint`):

1. `activeOffer` := none.
2. If slot 0 is empty, let `a` = slot 1 and `b` = empty; otherwise `a` = slot 0 and `b` = slot 1. (A single payment stack in slot 1 therefore acts as the first payment.)
3. If `a` is empty: the result slot is set to empty, `futureXp` := 0, and the method **returns without notifying** the merchant.
4. Otherwise, if the merchant's offer list is not empty: look up `o = getRecipeFor(a, b, selectionHint)`. If `o` is none or out of stock, `activeOffer` := `o` (possibly none) and look up again with the payments swapped, `o = getRecipeFor(b, a, selectionHint)`. Then, if `o` is not none and not out of stock: `activeOffer` := `o`, the result slot := `o.assemble()`, `futureXp` := `o.xp`; otherwise the result slot := empty and `futureXp` := 0. (An out-of-stock first match stays as `activeOffer` when the swapped lookup finds nothing, so `activeOffer` can name an out-of-stock offer while the result slot is empty.)
5. `merchant.notifyTradeUpdated(result slot stack)` (§2.8).

`MerchantMenu.setSelectionHint(n)` stores n and runs `updateSellItem`. `MerchantMenu.slotsChanged(container)` runs `updateSellItem` and then the base `slotsChanged` (`broadcastChanges`).

### 2.5 The result slot (`MerchantResultSlot`)

It keeps a running `removeCount`.

- `mayPlace(stack)`: false.
- `mayPickup(player)`: false when `activeOffer` is none; otherwise true when `activeOffer.satisfiedBy(slot0, slot1)` or `activeOffer.satisfiedBy(slot1, slot0)` holds and the base `mayPickup` (true) allows.
- Taking by a click: the generic path calls `container.removeItem(2, n)`, which removes the whole result stack (§2.3), so a trade always yields exactly one result stack; `remove(n)` first adds `min(n, result count)` to `removeCount`.
- `onQuickCraft(stack, delta)` (called by the generic `onQuickCraft(newStack, oldStack)` with the number of items that left the slot): `removeCount += delta`, then `checkTakeAchievements(stack)`.
- `checkTakeAchievements(stack)`: `stack.onCraftedBy(player, removeCount)`; `removeCount := 0`.
- `onTake(player, stack)`: first `checkTakeAchievements(stack)`. Then, if `activeOffer` is not none, with `a` = slot 0 and `b` = slot 1: if `activeOffer.take(a, b)` or else `activeOffer.take(b, a)` succeeds (the first attempt that succeeds shrinks the stacks; both orders are accepted): `merchant.notifyTrade(activeOffer)`; the player's statistic `traded_with_villager` is awarded (display "Traded with Villagers"); slot 0 and slot 1 are set again with the shrunk stacks (each `setItem` re-runs `updateSellItem`). Finally, whether or not `take` succeeded, `merchant.overrideXp(merchant.getVillagerXp() + activeOffer.xp)`. On the server `overrideXp` is a no-op for villagers (read: `AbstractVillager.overrideXp` has an empty body), so this line only has an effect on the client's own copy of the merchant (§2.9).

### 2.6 M4 buttons, M3 data slots

`MerchantMenu` has no data slots and no `clickMenuButton`. Its only interaction besides slot clicks is the Select Trade packet (§2.7).

### 2.7 Select trade (`tryMoveItems`)

Client: clicking a row button (§2.10) sets the screen's `shopItem` to `row index + scrollOff`, and then does three things in order: `menu.setSelectionHint(shopItem)`, `menu.tryMoveItems(shopItem)` (client-side prediction), and sends Select Trade (05c 0x34) with `shopItem`.

Server (`handleSelectTrade`): the packet is acted on only when the player's open menu is a `MerchantMenu` (the container id is not checked); if `stillValid` is false the packet is ignored (debug log); otherwise `setSelectionHint(index)` then `tryMoveItems(index)`. The hint is stored unchecked; `tryMoveItems` checks the range.

`tryMoveItems(i)`:

1. If i < 0 or i >= the offer count, stop.
2. Return the current payments: if slot 0 holds a stack, call `moveItemStackTo(stack, 3, 39, reverse = true)` (into the player inventory, scanning from the end, 40-1 §3.5); if that fails (nothing could move) stop here; otherwise `setItem(0, stack)` (the same object, now smaller or empty, which re-runs `updateSellItem`). Then the same for slot 1 (`moveItemStackTo(..., 3, 39, true)`, stop on failure, `setItem(1, stack)`).
3. Only when both payment slots are now empty: let `offer` = `offers[i]`; fill slot 0 from the player inventory for the offer's **base** first cost (`getItemCostA`), then, when the offer has a second cost, fill slot 1 for it.

Filling a payment slot for an item cost `K` into payment slot `p`: scan menu slots 3 to 38 in ascending order (main inventory rows first, then the hotbar). For each slot whose stack is non-empty and matches `K` (`ItemCost.test`): let `cur` be the stack now in payment slot `p`; if `cur` is non-empty and is not the same item with the same components, skip this slot; otherwise `max` = the item's maximum stack size, `n = min(max - cur.count, stack.count)` (`cur.count` is 0 when empty), the new payment stack is a copy of `stack` with count `cur.count + n`, `stack` shrinks by n, `setItem(p, new stack)`; stop scanning when the new payment stack has reached `max`. The payment slot is thus filled to a full stack from the inventory, not only to the price; the result slot then shows the offer when the payments satisfy it (§2.4). Because the base cost and not the modified cost is used for matching, a stack that matches the item and components is moved even when it is too small to pay the current price.

### 2.8 M5 quick-move

`quickMoveStack(player, index)` follows the template of 40-1 §3.6 with these branches (the empty-stack and unchanged-count exits are as in the template):

| Source slot | Move | Extra |
|---|---|---|
| 2 (result) | `moveItemStackTo(stack, 3, 39, reverse = true)`; on failure return empty | on success: `slot.onQuickCraft(stack, copyBeforeMove)` (adds the moved count to `removeCount` and runs `checkTakeAchievements`, §2.5), then `playTradeSound` |
| 0 or 1 | `moveItemStackTo(stack, 3, 39, false)` | none |
| 3 to 29 | `moveItemStackTo(stack, 30, 39, false)` (into the hotbar only) | none |
| 30 to 38 | `moveItemStackTo(stack, 3, 30, false)` (into the main inventory only) | none |

At the end of the template, when the count changed, `slot.onTake(player, stack)` runs, which for the result slot is the trade of §2.5. The caller repeats the quick-move while the slot still holds the same kind of item (40-1 §3.4), so shift-clicking the result trades repeatedly until the payments no longer satisfy the offer or the inventory is full. Items cannot be quick-moved from the inventory into the payment slots (only the Select Trade packet fills them). `canTakeItemForPickAll` is false for every slot of this menu, so a double-click does not gather items from it.

`playTradeSound` (server side only, `!isClientSide`): plays `merchant.getNotifyTradeSound()` at the merchant entity's position as a local sound in category NEUTRAL with volume 1.0 and pitch 1.0 (no distance delay). Villager: `villager.yes`; wandering trader: `wandering_trader.yes` (both read as `SoundEvents` fields).

### 2.9 M6 lifecycle

- `stillValid(player)` = `merchant.stillValid(player)`. For villagers and the wandering trader (`AbstractVillager.stillValid`): true when the trading player is that player, the entity is alive, and the player is within entity interaction range 4.0 of it. The client-side merchant returns true only for its own player.
- `removed(player)`: first the base `removed` (the carried stack, 40-1 §3.8); then `merchant.setTradingPlayer(null)`. On the client, stop. On the server: if the player is not alive, or is a server player that has disconnected, drop slot 0's stack and then slot 1's stack (taken out without notification, `drop(stack, throwRandomly = false)`); otherwise, for a server player, put slot 0's stack back into the inventory (`placeItemBackInInventory`, which drops what does not fit) and then slot 1's. All four calls (both drops and both placements) pass the prediction mode `SERVER_ONLY` (read), meaning only the server applies them and the client does not predict the result; the lectern take-book drop (§4.4) passes `PREDICTED`.
- **Client merchant** (`ClientSideMerchant`): holds the local player, the offer list set by Merchant Offers (`overrideOffers`), a local `xp` number (`overrideXp` stores it, `getVillagerXp` returns it), and returns `showProgressBar` true. `notifyTrade` only calls `offer.increaseUses()` on the local copy (prediction); `notifyTradeUpdated` does nothing.
- **Merchant Offers handling** (client): if the packet's container id equals the open menu's id and the menu is a `MerchantMenu`: `setOffers`, `setXp`, `setMerchantLevel`, `setShowProgressBar`, `setCanRestock` in that order. Otherwise the packet is ignored.
- **Trade-updated sound** (server, `AbstractVillager.notifyTradeUpdated`): when the level is the server and the merchant's `ambientSoundTime` is greater than `-80 + 20` (the ambient sound interval of `Mob` is 80, read), set `ambientSoundTime := -80` and make the "yes" sound if the result stack is non-empty or the "no" sound if it is empty (`villager.yes`/`villager.no`, `wandering_trader.yes`/`wandering_trader.no`). The same method is called from `updateSellItem` step 5.
- **After a trade** (server, `AbstractVillager.notifyTrade`): `offer.increaseUses()`, `ambientSoundTime := -80`, `rewardTradeXp(offer)` (XP, orb and level-up: 19 §22.2 for villagers, 19 §23 for the wandering trader), and for a server player the "trade" advancement criterion is triggered with the result stack.
- **Resending the offers**: `Villager.updateSpecialPrices` (a trade start, a restock, a gossip exchange, 19 §22) ends, when the trading player's open menu is a merchant menu and the offer list is not empty, with `menu.updateSellItem()` and a new Merchant Offers packet with the villager's current level, XP, `showProgressBar` and `canRestock`. No resend was found in the per-trade path (Open question 3).

### 2.10 M7 screen (`MerchantScreen`)

**Geometry.** Image 276 x 166; `leftPos` and `topPos` as in 40-1 §5.1. The inventory label is moved to x = 107 (`inventoryLabelX`), y stays `imageHeight - 94` = 72. The background is `villager.png` (512 x 256) blitted from (0, 0) with size 276 x 166 at (`leftPos`, `topPos`) (the draw call passes the texture size 512 x 256).

**Constants read:** 7 trade buttons (`NUMBER_OF_OFFER_BUTTONS`), each 88 x 20 (`TRADE_BUTTON_WIDTH`, `TRADE_BUTTON_HEIGHT`) at x = 5; row pitch 20; the first button at y = 16 + 2 = 18; scroller sprite 6 x 27; scroll area x from 94, top 18, height 139.

**Row buttons.** In `init`, button k (0 to 6) is created at (`leftPos` + 5, `topPos` + 18 + 20 k), 88 x 20, empty label, initially invisible; its press handler is the selection of §2.7. Each frame, while the offer list is non-empty, a button is made visible when its own index k is less than the total offer count (not `k + scrollOff`). The update sits at the end of the contents pass, after the empty-list early exit (read), so with an empty offer list it never runs and the buttons keep their initial invisible state. The button's background is the standard plain button sprite (12 §5.9); the row contents below are drawn over it.

**Row contents** (`extractContents`, after the slots; nothing is drawn when the offer list is empty). Order within the contents pass, all inside the non-empty branch (read): the scroller, the rows, the XP bar (only when `showProgressBar`), the out-of-stock tooltip check (not gated by `showProgressBar`, gated by out of stock, pointer position and `canRestock`), then the row-button visibility update and the row tooltips. Let `canScroll` = offer count > 7. Rows are enumerated over all offers with a running index; when `canScroll`, an offer is skipped unless `scrollOff <= index < scrollOff + 7`. The visible rows are drawn at screen row y_r = `topPos` + 19 + 20 r (r = 0 for the first drawn row):

| Part | Position | Drawn |
|---|---|---|
| first cost | x = `leftPos` + 10, y_r | the modified cost stack as a fake item (not a real stack), then its decorations (below) |
| second cost | x = `leftPos` + 40, y_r | only when the second cost is not empty: fake item and standard item decorations (the count at the bottom right) |
| arrow | x = `leftPos` + 60, y_r + 3, 10 x 9 | sprite `container/villager/trade_arrow`, or `container/villager/trade_arrow_out_of_stock` when the offer is out of stock |
| result | x = `leftPos` + 73, y_r | the result stack as a fake item with its standard decorations |

First-cost decorations (`extractAndDecorateCostA`): if the base count equals the modified count, the standard decorations at (x, y_r). If they differ (a discount or a price increase): the base count is drawn first at (x, y_r) with the forced text "1" when the base count is 1 (otherwise the real count), then the modified count at (x + 14, y_r) with the same "1" rule, then the sprite `container/villager/discount_strikethrough` (9 x 2) at (x + 7, y_r + 12), which crosses out the base count. (Item decorations are 12 §5.7; the count text right edge is at x + 17, so the two counts sit side by side at x + 17 - width and x + 31 - width.)

**Scroller** (`extractScroller`): with n = offer count + 1 - 7 = count - 6: when n > 1 (equivalent to `canScroll`), the thumb is drawn with sprite `container/villager/scroller` (6 x 27) at x = `leftPos` + 94, y = `topPos` + 18 + t, where `step = 1 + h / n + 139 / n`, `h = 139 - (27 + (n - 1) x 139 / n)` (all integer divisions), `t = min(113, scrollOff x step)`, and `t = 113` when `scrollOff = n - 1`. While the pointer is over the thumb (x from `leftPos` + 94 inclusive to +100 exclusive, y from the thumb top to the thumb top + 27 inclusive) the screen requests the resize-vertical cursor while dragging and the pointing-hand cursor otherwise. When n <= 1 the thumb is drawn with `container/villager/scroller_disabled` at (`leftPos` + 94, `topPos` + 18) and nothing else.

**Scroll input.** Mouse wheel (after the base class declined it): when `canScroll`, `scrollOff := clamp(int(scrollOff - scrollY), 0, count - 7)` (the vertical wheel amount is subtracted, truncated toward zero); the event is always consumed. Mouse press: when `canScroll` and the pointer is strictly right of `leftPos` + 94 and strictly left of `leftPos` + 100 and strictly below `topPos` + 18 and y <= `topPos` + 18 + 139 + 1 (inclusive upper bound, all four read in the press method, with `leftPos` and `topPos` recomputed there as (width - imageWidth) / 2 and (height - imageHeight) / 2), `isDragging` := true; then the base press handling runs. Drag (read: the only guard is the `isDragging` flag; `canScroll` is not re-checked, and when the flag is false the base class handles the drag): while `isDragging`, with `top` = `topPos` + 18, `bottom` = `top` + 139, `maxOff` = count - 7: `f = (mouseY - top - 13.5) / ((bottom - top) - 27.0) x maxOff + 0.5`, `scrollOff := clamp(int(f), 0, maxOff)`; consumed. Release: `isDragging` := false.

**Selected offer and the out-of-stock cross.** `shopItem` (initially 0) is the selected offer index. In the background pass (after the texture), if the offer list is non-empty and `0 <= shopItem < count` and the selected offer is out of stock, the sprite `container/villager/out_of_stock` (28 x 21; the position and the draw condition were re-checked) is drawn at (`leftPos` + 83 + 99, `topPos` + 35) = (`leftPos` + 182, `topPos` + 35). Only the selected offer's state decides this; rows do not draw it. In the contents pass, when the selected offer is out of stock, the pointer is inside the rectangle x 186 to 208, y 35 to 56 (relative to `leftPos`/`topPos`, 22 x 21) and `menu.canRestock()`, a tooltip with the text of the key `merchant.deprecated` ("Villagers restock up to two times per day.") is set for the next frame at the pointer. For the wandering trader (`canRestock` false) there is no tooltip.

**Level title and labels** (`extractLabels`, colour `#404040`, no shadow, text drawn at y = 6 unless noted):

| Label | Text | x |
|---|---|---|
| title | when `1 <= level <= 5` and `showProgressBar`: the key `merchant.title` ("%s - %s") with the screen title and the component `merchant.level.<level>`; otherwise the screen title alone | 49 + 276 / 2 - width / 2 = 187 - width / 2 (integer division of the image width, then of the text width) |
| inventory | `container.inventory` | 107 (y = 72) |
| trades | key `merchant.trades` ("Trades") | 5 - width / 2 + 48 = 53 - width / 2 |

`merchant.level.1` to `.5`: Novice, Apprentice, Journeyman, Expert, Master.

**XP bar** (`extractProgressBar`, only when `showProgressBar` and a selected offer exists; drawn in the contents pass after the rows). Let `level` = `merchantLevel` and `xp` = the local villager XP. Nothing at all is drawn when `level >= 5`. Otherwise the sprite `container/villager/experience_bar_background` (102 x 5) is drawn at (`leftPos` + 136, `topPos` + 16). Let `min = T[level - 1]` and `max = T[level]` with `T = [0, 10, 70, 150, 250]` (`VillagerData.getMinXpPerLevel` and `getMaxXpPerLevel`: for levels 1 to 4 the thresholds, and 0 outside; `NEXT_LEVEL_XP_THRESHOLDS`, read as 0, 10, 70, 150, 250). When `xp < min`, or the level cannot level up (`1 <= level < 5` fails), stop after the background. Otherwise `scale = 102.0 / (max - min)` (float), `cur = min(floor(scale x (xp - min)), 102)`; the sprite `experience_bar_current` (102 x 5) is drawn from its left edge at (`leftPos` + 136, `topPos` + 16) clipped to a width of `cur` (the sprite blit takes the full sprite size 102 x 5, source origin (0, 0), destination width `cur`). Then `future` = the menu's `futureXp` (the `xp` of the offer currently shown in the result slot, §2.4): when `future > 0`, `w = min(floor(future x scale), 102 - cur)` and the sprite `experience_bar_result` is drawn with source origin (`cur`, 0) at (`leftPos` + 136 + `cur`, `topPos` + 16) with width `w` and height 5 (it previews the XP the trade will give, behind the filled part).

**Row tooltips** (a hovered row button, each frame): when the pointer is over a button and the offer index `k + scrollOff` exists, for pointer x relative to the button's left edge bx: x < bx + 20: the item tooltip of the modified first cost stack; bx + 30 < x < bx + 50: the item tooltip of the second cost stack when it is non-empty; x > bx + 65: the item tooltip of the result stack; anything else (the gaps and the arrow): none. Item tooltips are 12 §5.8 and 40-1 §5.6.

**Other.** `isInGameUi` and the draw order are the generic ones (40-1 §5.2). The screen has no tick logic of its own.

### 2.11 Worked examples (merchant)

**E1. Modified price.** A cost of 7 items, `demand` 2, `priceMultiplier` 0.2, `specialPriceDiff` -3: `floor(7 x 2 x 0.2) = floor(2.8) = 2`, count = `7 + 2 - 3 = 6`. The row draws "7" and "6" at x + 17 - width and x + 31 - width with the strike-through at (x + 7, y_r + 12).

**E2. Floors and clamps.** Base 1, demand 0, `specialPriceDiff` -5: count = `clamp(1 + 0 - 5, 1, 64)` = 1 (never below 1). Base 4, `priceMultiplier` 0.2, demand 12 (one full restock, 19 §22 worked example): `floor(4 x 12 x 0.2) = floor(9.6) = 9`, count 13. A negative demand gives `max(0, ...) = 0`.

**E3. Scroller with 10 offers.** n = 10 + 1 - 7 = 4; `h = 139 - (27 + 3 x 139 / 4) = 139 - (27 + 104) = 8`; `step = 1 + 8 / 4 + 139 / 4 = 1 + 2 + 34 = 37`. Thumb offsets t for `scrollOff` 0, 1, 2, 3: 0, 37, 74, and 113 (the last forced). The maximum `scrollOff` is `10 - 7 = 3`. Rows drawn for `scrollOff` 2: offers 2 to 8. A drag with the pointer 70 pixels below the scroll area top: `f = (70 - 13.5) / (139 - 27) x 3 + 0.5 = 2.01`, so `scrollOff` = 2. Seven or fewer offers: no scroller activity, the disabled thumb.

**E4. XP bar.** Level 2, xp 40, the selected result offer worth 5 XP: `min` 10, `max` 70, `scale = 102 / 60 = 1.7`, `cur = floor(1.7 x 30) = 51`; `w = min(floor(5 x 1.7) = 8, 102 - 51 = 51) = 8`. Level 3, xp 100: `min` 70, `max` 150, `scale = 1.275`, `cur = floor(1.275 x 30) = 38`. Level 5: only the title changes, no bar.

**E5. Selecting a trade.** The inventory holds 40 emeralds in main slot 3 and 30 in main slot 4; the selected offer's first cost is emerald (base 8, modified 8). `tryMoveItems`: payments empty; fill slot 0: slot 3 matches, `max` 64, `n = min(64 - 0, 40) = 40`, payment stack 40, slot 3 empties; payment not full, continue: slot 4 matches, `cur` is 40 of the same item, `n = min(64 - 40, 30) = 24`, payment 64, slot 4 keeps 6; payment full: stop. The result slot shows the offer's result with `futureXp` = the offer's XP. Clicking another row while this is in place first returns the payments to the inventory with a reverse scan (`moveItemStackTo(..., 3, 39, true)`), then fills for the new offer.

**E6. Taking the result.** Payments: slot 0 holds 64 emeralds, offer cost 13 emeralds, `uses` 0, `maxUses` 12. A click on the result slot: `mayPickup` is true (`64 >= 13`), `removeItem(2, n)` takes the whole result stack, `onTake`: `take` shrinks slot 0 to 51, `notifyTrade` (`uses` 1; on the server also XP and orb, 19 §22.2), statistic +1, `setItem(0, 51)` re-runs `updateSellItem` and the result reappears; `overrideXp(xp + offer xp)` updates the local bar. A shift-click repeats this while the result slot keeps the same item, so with 64 emeralds the loop ends after 4 trades (64 / 13) leaving 12 emeralds, or earlier at `uses = 12`.

---

## 3. Beacon (`BeaconMenu`, id 9)

### 3.1 M1 identity

| Item | Value |
|---|---|
| Menu class, type | `BeaconMenu`, `MenuType.BEACON` (`beacon`, id 9) |
| Client factory | constructor `(containerId, inventory-container)` building a 1-slot simple container, a 3-entry `SimpleContainerData`, and the null level access |
| Server factory | `BeaconBlockEntity.createMenu`: when the block entity's lock code lets the player open it, `BeaconMenu(containerId, playerInventory, blockEntity.dataAccess, ContainerLevelAccess.create(level, pos))`; otherwise no menu opens and the "container is locked" notification is sent (the key `container.isLocked`, "%s is locked!", with the block entity's display name) |
| Screen | `BeaconScreen`, 230 x 219 |
| Title | the block entity display name, default key `container.beacon` ("Beacon") (the screen does not draw it, §3.8) |

### 3.2 M2 slot table (37 slots)

| Menu slot | Container, slot | x, y | Slot class | Notes |
|---|---|---|---|---|
| 0 | the beacon's own 1-slot container, 0 | (136, 110) | `BeaconMenu$PaymentSlot` | `mayPlace(stack)`: the stack is in the item tag `beacon_payment_items` (the five items netherite ingot, emerald, diamond, gold ingot and iron ingot, read from the tag file); `getMaxStackSize` = 1 |
| 1 to 27 | player inventory 9 to 35 | (36 + 18 x col, 137 + 18 x row) | `Slot` | appended with `(x, y) = (36, 137)` |
| 28 to 36 | player inventory 0 to 8 | (36 + 18 x i, 195) | `Slot` | the hotbar, y = 137 + 58 |

The beacon's own container is a simple container of 1 slot (`BeaconMenu$1`, a `SimpleContainer` subclass): `canPlaceItem` is the same tag test and `getMaxStackSize` is 1. It is not the block entity: the payment stack lives only in the menu and is never saved with the block entity.

### 3.3 M3 data slots (3, a `ContainerData` of the block entity on the server)

Written to the client through Container Set Data (05a 0x13: property = the index, value = a Short).

| Index | Meaning | Range | Writer |
|---|---|---|---|
| 0 | `levels`, the pyramid level count of the beacon (`getLevels`) | 0 to 4 | the block entity (the beacon scan, 31 and the block documents); a `set` on this index stores the value |
| 1 | primary effect, encoded | 0 = none, otherwise the mob-effect registry id + 1 | `updateEffects` (§3.4); `set` stores `filterEffect(decode(value))` and, on the server and when the beacon currently has a beam, plays `beacon.power_select` at the block |
| 2 | secondary effect, encoded | same | same, without the sound |

`encodeEffect(holder)` = 0 for none, else the effect's registry id + 1 (`BuiltInRegistries.MOB_EFFECT` holder id map); `decodeEffect(0)` = none, else the effect with id `value - 1`. `filterEffect` keeps the effect only when it is one of the seven valid beacon effects of §3.4, otherwise none. The registry ids and a worked wire example are in 46 §5 (speed 0 is sent as 1, regeneration 9 as 10). `BeaconMenu.setData(i, v)` calls the base `setData` and then `broadcastChanges`.

### 3.4 M4 the Set Beacon packet and the valid effects

There is no `clickMenuButton`; the confirmation is the packet Set Beacon (05c 0x35).

**Effect tiers** (`BeaconBlockEntity.BEACON_EFFECTS`, read as four lists in this order): tier 1 (index 0): speed, haste; tier 2 (index 1): resistance, jump boost; tier 3 (index 2): strength; tier 4 (index 3): regeneration. The set of valid effects is the union of the lists (7 effects). `requiredLevels(effect)` = the 1-based index of the list that contains it (so speed and haste 1, resistance and jump boost 2, strength 3, regeneration 4), 0 for none, and a very large value (the int maximum) for an effect in no list.

**`validateEffects(primary, secondary, levels)`** returns true only when all hold; the tests in order:

1. If `secondary` is not none and `levels < 4`: false.
2. Let `rp = requiredLevels(primary)` and `rs = requiredLevels(secondary)`. If `rp > levels` or `rs > levels`: false.
3. If `rp >= 4` (the primary is regeneration or invalid): false.
4. If `rs` is not 0 and `rs < 4` and `primary` is not equal to `secondary`: false.
5. Otherwise true.

So a secondary of regeneration (tier 4) is free, any other secondary must equal the primary, and a primary of none with a non-none secondary is allowed only for regeneration.

**`updateEffects(primary, secondary)`** (server, from the packet handler): returns false when the payment slot is empty or when `validateEffects(primary, secondary, levels)` fails. Otherwise: data slot 1 := encode(primary), data slot 2 := encode(secondary) (so a primary of none and secondary of none clear the beacon's effects), then the payment slot is shrunk by 1 (`remove(1)`, which consumes the payment item), then `level.blockEntityChanged(pos)` through the level access, and returns true. The packet handler (`handleSetBeaconPacket`): ignored unless the open menu is a `BeaconMenu`; ignored with a debug log when `stillValid` fails; when `updateEffects` returns false the player is disconnected with the generic disconnect message (key `multiplayer.disconnect.generic`) and a warning is logged ("tried to set invalid beacon effects"). A server implementation must therefore expect the client to send the packet only with a payment present and valid choices.

### 3.5 M5 quick-move

`quickMoveStack(player, index)` (template 40-1 §3.6; the first matching branch applies):

| Condition | Move | Extra |
|---|---|---|
| index = 0 (payment) | `moveItemStackTo(stack, 1, 37, reverse = true)`; on failure return empty | on success `slot.onQuickCraft(stack, copy)` (the base two-argument form, no effect for a plain slot) |
| the payment slot is empty, the stack is accepted by `mayPlace` and its count is exactly 1 | `moveItemStackTo(stack, 0, 1, false)`; on failure return empty | none |
| 1 <= index < 28 | `moveItemStackTo(stack, 28, 37, false)` (into the hotbar) | none |
| 28 <= index < 37 | `moveItemStackTo(stack, 1, 28, false)` (into the main inventory) | none |

A stack of two or more payment items shift-clicked from the inventory therefore goes to the other inventory part, not to the payment slot, and a single payment item goes to the payment slot only when it is empty. (The method's final fall-through branch, a move into 1 to 37, is unreachable for the 37 slots.)

### 3.6 M6 lifecycle

- `stillValid(player)`: the block at the access position is a beacon and the player is within block interaction range plus 4.0 (40-1 §3.8 `stillValid(access, player, block)`).
- `removed(player)`: base `removed` (carried stack), then on the server only: take the payment stack out (`paymentSlot.remove(maxStackSize)`) and, when non-empty, drop it at the player with `drop(stack, throwRandomly = false)` (it is dropped, not placed back into the inventory).
- The payment slot's change does not run any hook (the buttons read `hasPayment` every tick on the client).

### 3.7 M7 screen: widgets (`BeaconScreen`)

Image 230 x 219; background `beacon.png` (256 x 256) blitted from (0, 0) with size 230 x 219. In the background pass, after the texture, five real items (the normal `item` draw, not fake) are drawn at y = `topPos` + 109: netherite ingot at x = `leftPos` + 20, emerald at + 41, diamond at + 41 + 22 = + 63, gold ingot at + 42 + 44 = + 86, iron ingot at + 42 + 66 = + 108 (the payment item icons shown in the lower strip).

**Labels** (`extractLabels`; the screen draws no title and no inventory label): the key `block.minecraft.beacon.primary` ("Primary Power") centred on x = 62, y = 10, and `block.minecraft.beacon.secondary` ("Secondary Power") centred on x = 169, y = 10, colour `#e0e0e0` (the int -2039584) **with** shadow (read: the screen calls the 5-argument `centeredText(font, component, x, y, colour)` overload, which in `GuiGraphicsExtractor` converts the component to its visual order text, subtracts half the width from x and calls the 5-argument `text`, and that overload forwards to the 6-argument `text` with the shadow flag constant 1, true). Centring: x - width / 2.

**Buttons.** Every button is 22 x 22 and draws a background sprite first and then an 18 x 18 icon at its (x + 2, y + 2). Background sprite choice (`BeaconScreenButton`): inactive: `container/beacon/button_disabled`; else selected: `container/beacon/button_selected`; else hovered or focused: `container/beacon/button_highlighted`; else `container/beacon/button` (all four 22 x 22). Buttons are created in `init` in this order, which is also their focus order: first the primary power buttons, then the secondary ones, then the upgrade button, the confirm and the cancel buttons.

*Primary rows* (`isPrimary` true), for tier t = 0, 1, 2 (the three lists): let `n` = the list size (2, 2, 1), `w = n x 22 + (n - 1) x 2` (46, 46, 22). Button j (0 to n - 1), effect = `BEACON_EFFECTS[t][j]`, at (`leftPos` + 76 + 24 j - w / 2, `topPos` + 22 + 25 t):

| Tier t | Effects | Buttons at (x, y) |
|---|---|---|
| 0 | speed, haste | (53, 22), (77, 22) |
| 1 | resistance, jump boost | (53, 47), (77, 47) |
| 2 | strength | (65, 72) |

Each is created inactive. *Secondary row* (`isPrimary` false), tier 3: `n` = the size of list 3 + 1 = 2 and `w = 46`. The buttons for the first `n - 1` = 1 entries of `BEACON_EFFECTS[3]` (regeneration) at (`leftPos` + 167 + 24 j - 23, `topPos` + 47) = (144, 47); created inactive. *The upgrade button* (`BeaconUpgradePowerButton`, tier 3, secondary): at (`leftPos` + 167 + 24 x 1 - 23, `topPos` + 47) = (168, 47), created invisible, with the effect of the first list entry (speed) as a placeholder. *Confirm* at (`leftPos` + 164, `topPos` + 107), *Cancel* at (`leftPos` + 190, `topPos` + 107).

The effect icon of a power button is the sprite named `mob_effect/<effect id path>` (read: `Hud.getMobEffectSprite` takes the effect holder's registry key, and prefixes its identifier with `mob_effect/`; the same sprites as the status icons, e.g. `mob_effect/speed`) drawn 18 x 18. The jar holds `textures/mob_effect/` files for speed, haste, resistance, jump_boost, strength and regeneration (listed). Tooltip of a power button: the translated effect name (the effect's description id, e.g. `effect.minecraft.speed` "Speed", `.haste` "Haste", `.resistance` "Resistance", `.jump_boost` "Jump Boost", `.strength` "Strength", `.regeneration` "Regeneration"); the upgrade button's tooltip is that text followed by the literal " II" (for example "Speed II"). The confirm button's sprite is `container/beacon/confirm` and its tooltip/label the key `gui.done` ("Done"); the cancel button's sprite is `container/beacon/cancel` and its text `gui.cancel` ("Cancel") (both sprites 18 x 18).

**Draw order and narration.** Background pass (`extractBackground`): the generic background, then the `beacon.png` blit, then the five payment items (as listed above). Widgets (the buttons, each drawing its background sprite then its icon) and the labels follow in the generic container-screen order (40-1 §5.2); the labels are the separate `extractLabels` pass. Button narration is the default button narration (the button's message text) via `updateWidgetNarration` (read); that the message of a power button is the effect name is inferred from the tooltip, and the hover delay of the tooltips and the client-side container class `BeaconMenu$1` are generic (12 §5.9).

**State.** The screen keeps `primary` and `secondary` (an effect or none, initially none). It registers a container listener on the menu; on every data slot change it sets `primary := menu.getPrimaryEffect()` and `secondary := menu.getSecondaryEffect()` (slot changes are ignored). Every client tick (`containerTick`) `updateButtons` calls `updateStatus(levels)` on every button with `levels` = data slot 0.

**`updateStatus`** per button class:

| Button | Rule |
|---|---|
| power button (tier t) | active := `t < levels`; selected := the button's effect equals the screen's `primary` (for a primary button) or `secondary` (for a secondary button) |
| upgrade button | when `primary` is not none: visible := true, the effect (sprite, tooltip) := the current `primary`, then the power-button rule (tier 3, secondary: active := `3 < levels`, selected := `secondary` equals that effect); when `primary` is none: visible := false |
| confirm | active := `menu.hasPayment()` (the payment slot holds an item) and `primary` is not none |
| cancel | nothing (always active) |

So with levels 1 the first row is active, with 2 the first two rows, with 3 all three primary rows, and with 4 the secondary regeneration button and the upgrade button also become active.

**Presses.**

| Button | Action |
|---|---|
| a primary power button | if already selected, nothing; otherwise `primary := its effect`; if `secondary` is not equal to that effect, `secondary := none`; then update the buttons |
| the secondary regeneration button | if already selected, nothing; otherwise `secondary := its effect`; update the buttons |
| the upgrade button | the same as the secondary button, with the effect being the current primary: `secondary := primary` |
| confirm | send Set Beacon (05c 0x35) with `primary` and `secondary` as optional effects (present flag, then the registry id), then close the container (`closeContainer`: Container Close and local close) |
| cancel | close the container |

### 3.8 Worked examples (beacon)

**E7. Valid combinations** (`levels` in brackets): (3) primary speed, secondary none: true. (4) primary speed, secondary speed: true (the upgrade). (4) primary haste, secondary regeneration: true (`rs` = 4). (4) primary strength, secondary jump boost: false (`rs` = 2, not equal to the primary). (3) primary regeneration: false (`rp` = 4 > 3). (4) primary regeneration: false (`rp` >= 4). (3) primary speed, secondary regeneration: false (a secondary needs `levels` 4). (2) primary strength: false (`rp` = 3 > 2). (4) primary none, secondary none, with a payment: true; the payment is consumed and both effects are cleared. Any of these with an empty payment slot: false, and the client is disconnected.

**E8. Wire encoding.** Choosing speed (registry id 0) and regeneration (id 9) at level 4 sends Set Beacon with present flags and the ids 0 and 9; the server then sets data slots 1 and 2 to 1 and 10, and Container Set Data packets carry property 1 value 1 and property 2 value 10 (46 §5).

**E9. Layout at one glance.** Row tier 0: 22-wide buttons at x 53 and 77 with a 2-pixel gap (a 46-wide block centred on 76, from 53 to 99); the lone strength button is centred on 76 (x 65 to 87). The secondary block is centred on 167 (regeneration at 144 to 166, the upgrade at 168 to 190), directly above the confirm and cancel buttons at 164 and 190.

---

## 4. Lectern (`LecternMenu`, id 17, `LecternScreen`, `BookViewScreen`)

### 4.1 M1 identity

| Item | Value |
|---|---|
| Menu class, type | `LecternMenu`, `MenuType.LECTERN` (`lectern`, id 17) |
| Client factory | constructor `(containerId)` with a 1-slot `SimpleContainer` and a 1-entry `SimpleContainerData` (`MenuType`'s own factory lambda) |
| Server factory | `LecternBlockEntity.createMenu`: `LecternMenu(containerId, bookAccess, dataAccess)` where `bookAccess` is the block entity's book container and `dataAccess` its page counter (31-4 §3) |
| Screen | `LecternScreen`, which extends `BookViewScreen` (a plain `Screen`, not an `AbstractContainerScreen`) and implements `MenuAccess` |
| Title | the block entity's display name, key `container.lectern` ("Lectern") (not drawn) |

### 4.2 M2 slot table (1 slot, no player inventory)

| Menu slot | Container, slot | x, y | Slot class | Notes |
|---|---|---|---|---|
| 0 | the lectern book container, 0 | (0, 0) | an anonymous `Slot` subclass (`LecternMenu$1`) | its `setChanged` runs the base then `menu.slotsChanged(container)` (so `broadcastChanges`); `mayPlace` is the default true |

The lectern's book container (`LecternBlockEntity$1`, read): size 1, maximum stack size 1, `getItem(0)` is the held book (empty stack otherwise), `canPlaceItem` is false for every slot, `removeItem` splits the book and, when it becomes empty, runs the book-removed reset (page 0, page count 0, `LecternBlock.resetBookState(..., hasBook = false)`), `removeItemNoUpdate` takes the book out and runs the same reset, `stillValid(player)` is "the block entity is still at its position and the player is within interaction range (31-1 §9.1) **and** the lectern still has a book" (`hasBook`: the stack has the `writable_book_content` or the `written_book_content` component). No player inventory is part of this menu and no slot is drawn (the book screen is not a container screen). The slot's `setItem` body of the book container was not traced (Open question 5).

### 4.3 M3 data slots (1)

| Index | Meaning | Range | Writer |
|---|---|---|---|
| 0 | the page currently shown | 0 to page count - 1 | server: `LecternBlockEntity.setPage` through the container data; `set(0, v)` clamps `v` to `[0, pageCount - 1]` (the page count is the page list size of the written book content, else of the writable book content, else 0); when the clamped value differs from the stored page, it is stored, the block entity is marked changed and the page-change signal (redstone, `LecternBlock.signalPageChange`) is sent |

`LecternMenu.setData(i, v)` calls the base `setData` and `broadcastChanges`, so the client receives the clamped value through Container Set Data. `getBook` is slot 0's stack; `getPage` is data slot 0.

### 4.4 M4 buttons (`clickMenuButton`, Container Button Click 05c 0x11)

| Button id | Effect | Returns |
|---|---|---|
| `id >= 100` | page jump: data slot 0 := `id - 100` (clamped by the block entity, §4.3). No permission check | true |
| 1 | previous page: data slot 0 := current page - 1 | true |
| 2 | next page: data slot 0 := current page + 1 | true |
| 3 | take book: false (nothing happens) unless `player.mayBuild()`; otherwise `removeItemNoUpdate(0)` on the book container (which also resets page and page count and the block state), `setChanged`, then `player.getInventory().add(book)`; when the inventory cannot take it the book is dropped (`drop(stack, throwRandomly = false)`, predicted) | true when `mayBuild`, else false |
| any other id (including 0 and 4 to 99) | nothing | false |

The server then calls `broadcastChanges` when the result is true (§1.3). The `mayBuild` test is the player ability (adventure mode and spectator: false, 13 and 17 gamemode rules).

### 4.5 M5 quick-move

`quickMoveStack` always returns the empty stack (nothing is moved).

### 4.6 M6 lifecycle

`stillValid` = the book container's `stillValid` (§4.2). There is no `removed` override beyond the base. The comparator output and block state side effects of changing the page and removing the book are in 31-4 §3; the redstone formula is `floor(14 x f) + (1 if a book is present)`, with `f = page / (pageCount - 1)` when `pageCount > 1` and `f = 1.0` otherwise (`getRedstoneSignal`, read).

### 4.7 M7 screens

**The book view (`BookViewScreen`).** A plain screen that fills the window (no container offsets). Constants (read): background image 192 x 192 from `textures/gui/book.png` (256 x 256 sheet, region origin (0, 0)); text width 114; text height 128; page text offset (36, 30); page indicator offset (148, 16); page button row y = 157; back button x = 43; forward button x = 116.

| Item | Value |
|---|---|
| `backgroundLeft` | `(windowWidth - 192) / 2` (integer division) |
| `backgroundTop` | 2 |
| `menuControlsTop` | `backgroundTop + 192 + 2` = 196 |
| background | the 192 x 192 region of `book.png` at (`backgroundLeft`, `backgroundTop`), drawn after the generic screen background; `isInGameUi` true |
| page text | style: colour `#000000` (the int -16777216), no shadow. The current page's component is merged with this style and split into lines with the font's splitter at a width of 114 pixels. Up to `min(128 / 9, lineCount)` = `min(14, lineCount)` lines are drawn, line i at (`backgroundLeft` + 36, `backgroundTop` + 30 + 9 i) |
| page indicator | the key `book.pageIndicator` ("Page %1$s of %2$s") with `currentPage + 1` and `max(pageCount, 1)`, the same black style, right-aligned so that its right edge is at x = `backgroundLeft` + 148, y = `backgroundTop` + 16 |
| line cache | the split lines and the indicator are recomputed only when `currentPage` differs from the cached page (set to -1 when the book or the page changes) |
| Done button | the plain screen's Done button (key `gui.done`): 200 wide, at x = `(windowWidth - 200) / 2`, y = `menuControlsTop`, default height 20; it calls `onClose` |
| page buttons (`PageButton`) | 23 x 13 each; forward at (`backgroundLeft` + 116, `backgroundTop` + 157), back at (`backgroundLeft` + 43, `backgroundTop` + 157). Sprites `widget/page_forward`, `widget/page_forward_highlighted`, `widget/page_backward`, `widget/page_backward_highlighted` (highlighted when hovered or focused), drawn at the button's position with size 23 x 13. Names (narration) `book.page_button.next` ("Next Page") and `book.page_button.previous` ("Previous Page"). A press plays the UI sound `book.page_turn` (volume/pitch argument 1.0) only when the screen was created with `playTurnSound` true; the button does not take focus after a click |
| visibility | forward visible when `currentPage < pageCount - 1`; back visible when `currentPage > 0`; refreshed after every page change |
| keys | after the generic `keyPressed` (Escape and the like): the key whose shortcut code is 1073741899 presses the back button and 1073741902 presses the forward button (read in the key switch; `KeyEvent.shortcutKey` returns the event's key code field unchanged). `InputConstants` defines `KEY_PAGEUP` = 75 and `KEY_PAGEDOWN` = 78 (read), next to `KEY_LEFT` = 80 and `KEY_RIGHT` = 79, and the switch constants equal 1 << 30 plus those values (1073741824 + 75 = 1073741899, + 78 = 1073741902; arithmetic on read constants). Which key-code space this is (the common GLFW table has other values for these keys, recalled, not verified) is not documented by a read of the input layer and is left in Open question 6; the input document, 12 or 13, owns it |
| text clicks | mouse button value 1 (the left button in this version, 40-1 §5.5): the style under the pointer in the page text is looked up; if it has a click event, `handleClickEvent` runs and the click is consumed when it does something. A "change page" event calls `forcePage(page - 1)` (pages in the event are 1-based); a "run command" event calls `closeContainerOnServer()` then runs the command as if the player had typed it; every other click event goes to the default game click handling. The handler returns true for any non-null event |
| `setBookAccess(access)` | stores the access, clamps `currentPage` into `[0, pageCount]` (the upper bound is the page count, not count - 1; read), refreshes the buttons and the cache |
| `setPage(p)` | clamps `p` into `[0, pageCount - 1]`; returns true and updates when it differs from the current page |
| page access (`BookAccess`) | a list of components; `getPageCount` is its size; `getPage(i)` is the i-th component or the empty component for an out-of-range index. `fromItem(stack)` builds it from the `written_book_content` component (`getPages(filterEnabled)`, the filtered or the plain text depending on the client's text-filtering setting) or else from the `writable_book_content` component (each page as a literal text component), or none when the stack is neither |

The plain `BookViewScreen` (opened by Open Book 05a 0x3B for a held written book) is constructed with `playTurnSound` true, and its page buttons only change `currentPage` locally. It is outside the menu system.

**The lectern screen (`LecternScreen`).** It is a `BookViewScreen` with the empty book access and `playTurnSound` false. Differences:

- `init`: the base init (menu controls, page buttons) then the menu's slot listener is registered. The listener: a slot change (the book) rebuilds the access from `menu.getBook()` (the empty access when the stack is not a book) and calls `setBookAccess`; a data change calls `setPage(menu.getPage())`.
- `createMenuControls`: when the local player `mayBuild`: two buttons of width 98 at y = `menuControlsTop` (196): "Done" (`gui.done`) at x = `windowWidth / 2 - 98 - 2` and "Take Book" (key `lectern.take_book`) at x = `windowWidth / 2 + 2` (`MENU_BUTTON_SIZE` 98, `MENU_BUTTON_MARGIN` 4 between them). Otherwise the base single 200-wide Done button.
- Done: `onClose`, which sends the container close (`closeContainer`) and then closes the screen. Take Book: sends the button click with id 3.
- Page buttons do not change the page locally: the back button sends button id 1, the forward button id 2 (the page changes when the server's data slot update arrives). A "change page" text click calls `forcePage(p)`, which, when `p` differs from `menu.getPage()`, sends the button click `100 + p` and reports success, else reports no change. The button clicks are sent as `handleInventoryButtonClick(containerId, buttonId)`, which is Container Button Click (05c 0x11) with the menu's container id.
- `closeContainerOnServer` (used by "run command" events) calls `closeContainer`. `isPauseScreen` is false. `removed` removes the listener.

The keys Page Up and Page Down press the same buttons, so they also go to the server.

### 4.8 Worked examples (lectern)

**E10. Layout.** Window width 854: `backgroundLeft = (854 - 192) / 2 = 331`; the page text starts at x = 367, y = 32 for the first line, the next lines at y = 41, 50 and so on up to the 14th at y = 149; the indicator's right edge is at x = 479, y = 18; the forward button at (447, 159), the back button at (374, 159), both 23 x 13; the buttons Done and Take Book (a player who can build) at x = 854 / 2 - 100 = 327 and 429, y = 196.

**E11. Page turning.** A book of 5 pages on a lectern at page 0: the player presses the forward button: button id 2 is sent, the server sets data slot 0 to 1, `setPage` stores it (changed, so the comparator signal updates), `setData` broadcasts, the client's listener calls `setPage(1)` and the buttons refresh (back visible). A change-page link to page 9 sends id 109; the server sets 9, which is clamped to 4; the value 4 is broadcast; the client shows page 5 of 5 (index 4). A page-jump to the same page does not send anything.

**E12. Taking the book.** A player in adventure mode presses the (not drawn) take-book id 3: `mayBuild` is false, the call returns false, nothing changes. A survival player with a full inventory: the book is removed from the lectern (page and page count reset, block state loses its book flag), the inventory add fails, and the book is dropped at the player.

---

## 5. Validation (checks an implementer can run)

1. Slot counts: merchant 39 (3 + 36), beacon 37 (1 + 36), lectern 1. Main-inventory and hotbar origins: merchant (108, 84) and y 142, beacon (36, 137) and y 195.
2. Quick-move ranges: merchant result goes to 3 to 38 with a reverse scan, payment slots go to 3 to 38 forward, main goes to the hotbar 30 to 38, hotbar goes to 3 to 29; beacon payment goes to 1 to 36 with a reverse scan, a single payment item goes to slot 0 only when it is empty, main to hotbar 28 to 36 and hotbar to main 1 to 27; lectern never moves.
3. Price formula: `count = clamp(base + max(0, floor(base x demand x multiplier)) + special, 1, max stack)`; the wire carries `base`, the offer comparison uses the modified count for the first cost only, the second cost never changes.
4. `getRecipeFor`: hint 0 or out of range scans; hint 1 to size - 1 tries one offer only; the swapped payment order is tried when the first lookup finds none or an out-of-stock offer.
5. `updateSellItem` skips the merchant notification only when the first payment is empty.
6. Result slot: the whole stack is removed in one take; the second `take` order is tried when the first fails; the XP override has no server effect.
7. Scroller: for count 8 (n = 2): `h = 139 - (27 + 139 / 2) = 139 - 96 = 43`, `step = 1 + 43 / 2 + 139 / 2 = 1 + 21 + 69 = 91`, so `scrollOff` 0 gives offset 0 and the last offset 1 (= n - 1) is forced to 113; for count 7 the disabled thumb is drawn.
8. Beacon: `validateEffects` truth table of E7; Set Beacon with an empty payment slot or an invalid choice is a disconnect; the payment is consumed by exactly 1; data slots 1 and 2 are the registry id + 1.
9. Beacon layout: power buttons at x 53, 77 (tiers 0 and 1), 65 (tier 2) with y 22, 47, 72; secondary buttons at (144, 47) and (168, 47); confirm (164, 107), cancel (190, 107).
10. Lectern buttons: ids 1, 2, 3 and 100 or more only; id 3 needs `mayBuild`; page values are clamped by the block entity; redstone signal 0 with no book, `floor(14 x page / (pageCount - 1)) + 1` with a book and more than one page, 15 with a one-page book (`f = 1`).
11. Book screen: text width 114 and 14 lines at most; page 1 of a book with 0 pages shows "Page 1 of 1" and no buttons.

---

## Open questions

1. (Resolved: `DataComponentExactPredicate.test` and `ItemCost.test` were read, §2.4.) Only the case of a stack whose component is absent because it equals the item's default value was not traced: whether `get` reports the default for an absent component belongs to the component model.
2. (Merged into 1.)
3. UNRESOLVED: whether the villager's server side resends Merchant Offers after a level-up while the screen is open (so the displayed level and the new offers refresh) was not found: the only resend read is in `updateSpecialPrices`. 19 §22.2 was checked and does not answer it (it describes the level-up, `updateTrades` and the orb, but no packet resend); the villager server classes were not traced in this document. The client's own XP (`overrideXp`) is updated locally after each trade; the level shown stays that of the last packet.
4. The `Villager.rewardTradeXp` details (level-up check, orb, regeneration) are taken from 19 §22.2 (checked in this pass: it lists XP, reputation, orb 3 + nextInt(4) plus 5 on level-up, and regeneration); this document read only the first lines of the method and did not re-verify the whole method; 19 §22.2 owns it.
5. The body of the lectern book container's `setItem` (and thus the behaviour of a forged click on the invisible slot 0, whose `Slot.mayPlace` is true while the container's `canPlaceItem` is false) was not traced.
6. The constants 1073741899, 1073741902 (read in the `BookViewScreen` key switch), `KEY_PAGEUP` = 75 and `KEY_PAGEDOWN` = 78 (read) and the 1 << 30 offset arithmetic are verified; only the ownership and description of the key-code space (what the 1 << 30 offset means) was not found by a read of the input layer.
7. The standard plain button sprite names and nine-slice data used by the row buttons of the merchant screen (`Button$Plain`) are 12 §5.9; the row button's own background was not re-read in this round.
8. The behaviour of `Font.split` for the page text (word-wrap rules, handling of newlines and of components with several styles) is the font engine of 12 §5.10 and was not re-read; the page text uses width 114 only.
9. The seven beacon effects use six distinct sprites (speed, haste, resistance, jump_boost, strength, regeneration; all six files listed). Nothing further open.
10. The `ClientboundMerchantOffersPacket` field order and widths are taken from 05a (the decode order is not repeated here); the packet's own encode and decode methods were not re-read in this round, only the offer layout (`MerchantOffer.STREAM_CODEC`), which matches 05a.
11. The sound events `villager.yes`, `villager.no`, `wandering_trader.yes`, `wandering_trader.no`, `beacon.power_select` and `book.page_turn` are cited by their `SoundEvents` field names; their registry ids and files are owned by the sound documents.
12. The effect of the screen's `Tooltip.create` on narration and hover delay (the tooltips of the beacon buttons) is generic widget behaviour (12 §5.9) and was not re-read.
