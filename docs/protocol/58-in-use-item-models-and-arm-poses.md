# 58. In-use item models and arm poses (item-definition properties, the goat horn, the third-person arm pose, one table of every in-use item)

| Item | Value |
|---|---|
| Covers | How the client chooses the model of a held item while it is in use or charged: the use state of a living entity and the flags that carry it (§2); the exact semantics of every item-definition property that the shipped definitions use (§3); the goat horn: its definition, its two models and their display transforms (§4); the third-person arm pose of a player who uses a goat horn, the held-item layer, the entity pose, first and third person camera, and how a player's main arm reaches every viewer (§5); one table of every held item whose model, arm pose or first-person transform changes while it is in use (§6); cross-checks and corrections to documents 08, 12, 18, 25-7, 34-2 and 57-1 (§7); worked examples (§8) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3, protocol 777 (the artifact recorded in the README header) |
| Method | Static reading of the shipped bytecode (`javap`) and of the shipped item definition and model data files, with no execution; clean-room reader round "58" (reader only; a reviewer follows) |
| Extends or corrects | 08 §6.3 (property ids by name only), 12 §6.6, §6.12, §6.13 and §7.5 (first-person use poses, the shield, the use-animation dispatch, the humanoid arm poses), 25-7 §12.2 (the horn's use), 34-2 §4.2 (arm order), 57-1 §3.4 (using-item state). Corrections applied in place (the list is in §7): 12 §7.5 (the left-arm `yRot` sign of the `TOOT_HORN` and `SPYGLASS` rows, and the idle-bob exception, which is the arm pose `SPYGLASS` and not "holds a spyglass"); 34-2 §4.2 (the `Order` sentence: the main-arm substitution applies only when the entity is not using an item; and the left-arm `yRot` signs in the parenthetical list of arm-pose formulas); 18 §1.4 (the sentence on slots 15 and up: three direct subclasses of the living entity define them); everything else is a pointer or an addition |

All angles in the pose formulas are radians; display transform rotations are degrees and translations are sixteenths of a block unless said otherwise. Floats are Java `float`. Artifact class names are cited in backticks only to say where a fact was read. Section numbers "12 §6.13" name sections of other documents of this folder.

---

## 1. How a held stack becomes a model

### 1.1 Entry points and what they pass

Every item model is resolved by one routine (`ItemModelResolver.updateForTopItem`) that takes: the render state to fill, the stack, the display context (§1.4), the level (the client level, or none), an **owner** (an object that can be asked for a living entity and a position; null when there is none) and an integer **seed**. It first clears the state; an empty stack stays empty. Otherwise it reads the stack's `item_model` component (an identifier; a stack without the component yields nothing) and takes the item definition (08 §6) with that identifier, **not** the item's registry key. The root node of the definition then updates the state.

| Caller | Stack | Context | Owner | Seed |
|---|---|---|---|---|
| First-person hands (`FirstPersonHandsAndItems.extractRenderState`) | the **displayed** stack of the hand (12 §6.2, not always the live stack, see §2.5) | `FIRST_PERSON_RIGHT_HAND` if the local player's main arm (`LocalPlayer.getMainArm`, entity data entry 15, §5.2.1) is right, else `FIRST_PERSON_LEFT_HAND`, for the main-hand item; the other one for the off-hand item | the local player | entity id + context ordinal |
| Third-person held items of every armed model, including players (`ArmedEntityRenderState.extractArmedEntityRenderState`) | `getItemHeldByArm(arm)`: the main-hand stack for the main arm, the off-hand stack for the other arm | `THIRD_PERSON_RIGHT_HAND` for the right arm, `THIRD_PERSON_LEFT_HAND` for the left arm | the entity | entity id + context ordinal |
| Item held on the head (`AvatarRenderer`, spyglass only, §6) | the used-hand stack | `HEAD` | the avatar | entity id + context ordinal |
| Non-living holders (item frames, dropped items and so on) | the stack | `FIXED`, `GROUND` and so on | the holder entity when there is one, else none | holder entity id, or a caller-chosen value |
| GUI draw with the default owner (`GuiGraphicsExtractor.item(stack, x, y)` and `item(stack, x, y, seed)`) | the stack of the slot or widget | `GUI` | **the local player** (`Minecraft.player`) with the client level | 0, or the caller's seed |
| GUI draw with a given entity (`GuiGraphicsExtractor.item(entity, stack, x, y, seed)`) | the stack | `GUI` | the given entity, with that entity's level | the caller's seed |
| GUI draw without an owner (`GuiGraphicsExtractor.fakeItem(stack, x, y[, seed])`) | the stack | `GUI` | **none** (null), with the client level | 0, or the caller's seed |

Callers of the GUI entry points (all read in the artifact):

- The hotbar and the off-hand slot of the HUD (`Hud.extractSlot`) use the entity-taking overload; the entity is the camera player (`Hud.getCameraPlayer`), the local player unless the camera follows another player. The stacks are `Inventory.getItem(i)` for the nine hotbar slots and `Player.getOffhandItem()`.
- The container screens (`AbstractContainerScreen.extractSlot`) draw a slot with `fakeItem` when `Slot.isFake()` is true and with `item(stack, x, y, seed)` (owner = the local player) otherwise. `Slot.isFake()` is false by default; only `ResultSlot` and `NonInteractiveResultSlot` return true (the result slots). The stack is `Slot.getItem()` (`Container.getItem`), and the slots of the player's inventory return the stack objects of the player's `Inventory`. The cursor stack (`extractFloatingItem`) uses `item(stack, x, y)`. A slot that is part of an active quick-craft drag (two or more slots in the drag set) is drawn with a `copyWithCount` copy of the carried stack, which is not the object of any hand stack, so the identity test of §2.5 fails for it and `using_item` is false for that icon.
- Other owner-passing callers (`item(stack, x, y[, seed])`): the beacon screen, the stonecutter recipe list, the creative-inventory tab buttons, the game-mode switcher icons, the item display widget, the overlay recipe buttons and one draw of the recipe button, and the bundle tooltip slots.
- `fakeItem` callers: the recipe book (ghost slots, tab-button icons, the recipe button), the advancements screen (widgets, tab icons) and the advancement and recipe toasts, the merchant screen (trade costs), the create-flat-world layer list and the flat-world preset list, and the result slots above.

So the GUI does **not** pass a null owner in general: the slots of the inventory, the hotbar and the other container slots resolve their stack with the local player (or the camera player) as the owner, and only the `fakeItem` callers pass none. The property results for a null owner are listed per property in §3; what the owner means in the GUI is in §3.2 and §6.

### 1.2 Node semantics (arithmetic)

- `minecraft:condition`: the property returns a boolean for (stack, level, owner as a living entity or none, seed, context); true selects `on_true`, false selects `on_false`. The node's `transformation` composes as in 12 §8.5.
- `minecraft:select`: the property returns a value; the case whose `when` list contains it is taken, else `fallback`, else nothing is drawn.
- `minecraft:range_dispatch`: v = property value × `scale` (a float multiplication; `scale` defaults to 1). If v is NaN, `fallback`. Otherwise the thresholds (floats; the entries are copied and sorted by threshold with `List.sort` and the entry comparator `BY_THRESHOLD` when the model is baked, so a definition's entry order does not matter, but duplicates survive the sort) are searched for the **last** index i with `threshold[i] <= v`; no such index gives `fallback`. A threshold that equals v is a hit. The search is a linear scan for fewer than 16 entries (it returns the index before the first threshold greater than v, or the last index when none is greater; comparisons are float comparisons in which 0.0 equals −0.0) and `Arrays.binarySearch` from 16 entries up (a found index is returned as it is; a miss returns insertion point − 1; it orders floats by total order, with −0.0 below 0.0, and may return **any** of several equal thresholds). The two give the same index only when the thresholds are **strictly ascending** and v is not −0.0 (with a 0.0 threshold present, v = −0.0 hits it in the scan and misses it in the binary search). The shipped data satisfies the first condition: every `range_dispatch` node of the 1658 shipped definitions (bow 2 entries, crossbow 2, brush 3, `compass` 33 in each of its two nodes, `recovery_compass` 33, `clock` 65 in each of its two nodes; read from the files, compared as 32-bit floats) has strictly ascending thresholds. The second condition is not reachable from the shipped properties that have 16 or more entries (inferred: the compass and clock values come from a positive modulo, and the random source gives values in [0, 1)); the brush (3 entries) uses the scan, which treats −0.0 as 0.0. All comparisons are in 32-bit floats: the thresholds are the JSON numbers rounded to `float` (0.65 is 0.64999998, 0.9 is 0.89999998), v is the float product. This matters at the boundaries; §8 lists the exact values.
- A model that is not drawn at all yields an empty state; an unset `fallback` yields nothing.

### 1.3 The property interfaces

A conditional property gets (stack, client level or none, living-entity owner or none, seed, context). A numeric property gets (stack, level or none, the owner object or none, seed) and returns a float. A select property gets the same five inputs as a conditional one and returns a value. Numeric properties that need a living entity ask the owner for it (`asLivingEntity`; an owner that is not a living entity gives none).

### 1.4 Display context names

`ItemDisplayContext` (ordinal, JSON name): 0 `none`, 1 `thirdperson_lefthand`, 2 `thirdperson_righthand`, 3 `firstperson_lefthand`, 4 `firstperson_righthand`, 5 `head`, 6 `gui`, 7 `ground`, 8 `fixed`, 9 `on_shelf`. The seed of a living entity's held item is the entity id plus the context ordinal. A "left-hand context" is 1 or 3 (12 §8.2).

---

## 2. The use state of a living entity

### 2.1 Fields

Each living entity (on both sides) has `useItem` (the stack being used; the empty stack when not using) and `useItemRemaining` (an int). Both are plain fields, **not synchronised**. What is synchronised is entity metadata entry 8, the living-entity flags (Byte, entity data serializer BYTE):

| Mask | Meaning | Set by | Cleared by |
|---|---|---|---|
| 1 (0x01) | "is using an item" (hand active) | server `startUsingItem` | server `stopUsingItem` |
| 2 (0x02) | "used hand is the off hand" | server `startUsingItem`: set when the hand is the off hand, **cleared** when the hand is the main hand | **not** cleared by `stopUsingItem`; only the next start rewrites it |
| 4 (0x04) | auto spin attack (Riptide, 25-7 §7) | the spin attack start | the end of the spin attack |

So the byte values seen on the wire for a player are: 0 (idle; the last use, if any, was with the main hand), 1 (using, main hand), 2 (idle; the last use was with the off hand), 3 (using, off hand), and the same four with 4 added during a spin attack. The viewer reads bit 1 as `byte & 1 > 0` and bit 2 as `byte & 2 > 0` (`isUsingItem`, `getUsedItemHand`); no other bit is read for this purpose. Metadata slot numbering and the dirty-value sending rule are in 18 §1.4 and §9.3; the packet is 05b 0x65.

### 2.2 Server: start, tick, stop

- **Start** (`LivingEntity.startUsingItem(hand)`): ignored if the hand stack is empty or the entity is already using an item. Otherwise `useItem` = the hand stack (the same object), `useItemRemaining` = the stack's use duration (for a horn `floor(use_duration × 20)` = 140 of the instrument in the stack's `instrument` component, and **0 for a horn stack without that component**, 25-7 §12.2 and §5.2 below; bow, crossbow, trident, shield 72000). On the server it then, **in this order**: (1) sends Set Equipment (05b 0x68) at once with the used hand's slot and the stack, to the tracking players; (2) sets flag 1 and sets or clears flag 2; (3) emits the `item_interact_start` vibration; (4) for a stack with the `kinetic_weapon` component resets its recent-hit map. The flag change travels with the next entity metadata pass (Set Entity Data, 05b 0x65) of the tracker, after the equipment packet. A horn use does this from `InstrumentItem.use` and then plays the sound (25-7 §12.2).
- **Per tick** (`LivingEntity.tick`, on **both** sides, right after `Entity.tick`): if `isUsingItem()`: if the stack in the used hand is the same item (item type) as `useItem`, then `useItem` is set to the hand's stack object (so the field always follows the live stack object) and the stack's `onUseTick` runs, then `useItemRemaining` is decremented; if the decremented value is exactly 0, on the server and for a stack whose `useOnRelease` is false, the use is completed (`completeUsingItem`, Open question 1). `ItemStack.useOnRelease` asks `Item.useOnRelease(stack)`, whose default is **false**; the only class that overrides it is `CrossbowItem` (true for a crossbow stack; read: no other class of the artifact declares the method). So the horn, bow, trident, shield, brush and every other item complete at count 0 (a bow or trident use that is never released completes at 72000 ticks of use); only a crossbow is a release item and stays in use at 0 until the key is released. If the hand now holds a different item (item type), the use is stopped.
- **Stop** (`stopUsingItem`): on the server it clears flag 1 only (and the vibration `item_interact_finish` if it was using); on both sides `useItem` becomes the empty stack and `useItemRemaining` 0.
- **Release** (`releaseUsingItem`, called when the player lets go): if `useItem` is not empty and the hand stack is the same item, `useItem` = the hand stack, the item's `releaseUsing` runs with the remaining ticks, and for release items (`useOnRelease` true: the crossbow only, §2.2) one more tick of use is run; then stop. The client sends Player Action `RELEASE_USE_ITEM` (05c 0x29, ordinal 6) when the key is released.
- `getTicksUsingItem()` = `useItem.getUseDuration − useItemRemaining` while `isUsingItem()`, else 0; the float form adds the partial tick (and is 0 when not using).

### 2.3 Remote entities (every viewer except the local player)

A viewer holds the entity's flags from metadata (05b 0x65). The use-start and use-clear logic is **state based**: it runs on the client side for **every** received entry 8 (the receiving routine fires the update hook once per entry of every Set Entity Data packet, whether or not the byte changed), and it tests the state at that moment, not a change of a flag:

- Start: bit 1 is set and the viewer's `useItem` is empty. Then `useItem` = the stack in the hand named by bit 2 at that moment, and, only if that stack is not empty, `useItemRemaining` = its use duration (when the hand stack is empty, `useItem` is set to that empty stack and `useItemRemaining` is left as it was).
- Clear: bit 1 is clear and `useItem` is not empty. Then `useItem` = empty and `useItemRemaining` = 0.
- Otherwise nothing happens (in particular, an entry 8 update while the viewer already holds a non-empty `useItem` and bit 1 is set changes nothing, and does not restart the count).

From then on the per-tick rule of §2.2 keeps `useItem` pointing at the live hand stack and counts `useItemRemaining` down, so the viewer's "ticks used" counts from the moment its start test succeeded, not from the server's start (a latency offset, no correction); the value of k in the first rendered frame after that moment is in §2.6. The per-tick rule also **ends** a viewer-side use on its own (`useItem` empty, remaining 0, with bit 1 still set) when the item in the used hand is not the item type of `useItem`.

Order of arrival (the failure cases below are inferred, Open question 6): the start test needs the used hand's stack to be present when it runs. If bit 1 is set while the hand is still empty, `useItem` stays empty and the count does not start (inferred from the code path, not run); the viewer's own per-tick rule then sees the stack that arrives later as a different item from the empty `useItem` and runs its stop, which leaves `useItem` empty and the remaining count 0 (inferred), so the use stays unstarted **until another entry 8 update arrives while bit 1 is still set** (for example the spin-attack bit changing, or a repeated byte), which retries the start from the then-current hand stack and starts the count at that time. Entry 8 normally changes only at use start, use end and spin attack, so for an ordinary use (horn, bow) there is usually no such retry and the viewer shows no in-use model or pose for that use (inferred). A server must therefore send Set Equipment for the used hand **before** the Set Entity Data that carries bit 1 (vanilla does, §2.2). The same rule bears on a viewer that starts tracking a player who is already using an item: the pairing bundle of 18 §9.1 lists Set Entity Data before Set Equipment, so by the rules above such a viewer does not show the in-use state until a later entry 8 update arrives with bit 1 still set (inferred from the bundle order and the start test; not run).

### 2.4 The local player

`LocalPlayer` overrides the use state and **predicts** it:

- `isUsingItem()` returns a private boolean `startedUsingItem`, not the metadata bit; `getUsedItemHand()` returns a private `usingItemHand` (the main hand when none).
- `startUsingItem(hand)` (called by the client's use-item path through the item's `use`): ignored for an empty hand stack or when already using; else the common start runs (`useItem` and `useItemRemaining` set; on a client level no flags are written), then `startedUsingItem` = true and `usingItemHand` = hand.
- `stopUsingItem()`: the common stop, then `startedUsingItem` = false. The player's own key release calls `releaseUsingItem` and sends the packet of §2.2.
- When the **server's** flags arrive (`onSyncedDataUpdated` for entry 8; the override first runs the common logic of §2.3, whose tests call the predicted `isUsingItem` and `getUsedItemHand` above, then this rule, which reads the bits of the received byte): if flag 1 is set and `startedUsingItem` is false, the local player starts using with the hand named by flag 2; if flag 1 is clear and `startedUsingItem` is true, the local use is stopped. The code gives no reason for a flag 1 that arrives while the local player is not using (no cause is traced; a use that the server started without the client's own start is the only case this branch can serve, inferred). A server that **refuses** a start sends no entry 8 change at all (the flag was never set, so the byte does not change and nothing is sent), so nothing from the server cancels the local prediction; the ways to end it that were read are the key release (§2.2) and the per-tick stop when the used hand holds a different item type (other local stops, such as opening a screen or taking damage, were not enumerated; Open question 8). The server ends the local use when it completes it (a horn at 140 ticks) because the completion clears flag 1. A late "flag 1 set" that arrives after the player has already released the key (the local use stopped) would start a local use again, which the next "flag 1 clear" would stop (inferred from the rule above; not run).
- The client never completes a use on its own (the completion test of §2.2 is server only): at `useItemRemaining` 0 the local use simply goes on, with a remaining count that goes negative, until the key is released or the server's flag clears it.

### 2.5 The stack identity that the properties test

Every use-state property below compares the stack it is asked about with `owner.getUseItem()` by **object identity**, not by item type or equality. Consequences:

- Third person: each arm's stack is the live equipment stack object of that hand; `useItem` is re-pointed at the used hand's object each tick (§2.2), so exactly the arm of the used hand matches. A second horn in the other hand is a different object and never matches (the "same item in both hands" case).
- First person: the stack is the **displayed** stack `FirstPersonHandsAndItems.mainHandItem` or `offHandItem`. Each tick the displayed stack is replaced by the live stack object at once when the two stacks match ignoring the components flagged `ignoreSwapAnimation` (the damage-like components, Open question 2) or when the item's definition sets `hand_animation_on_swap` false; otherwise the displayed stack stays the old object while the hand height dips to 0 and is replaced when the height is below 0.1 (12 §6.2). While a displayed stack is not the live object, every use-state property is false and the normal model is shown.

### 2.6 Order inside one client loop iteration, and which k a rendered frame shows

Read in `Minecraft.runTick`, `Minecraft.tick`, `Minecraft.handleKeybinds`, `ClientLevel.tickEntities` and `LivingEntity.tick`. Notation: U = the stack's use duration, R = `useItemRemaining`, k = U − R (ticks used).

One loop iteration with game time advancing (`runTick(true)`), in order:

1. N = the tick count that the delta tracker reports for this iteration (`DeltaTracker.Timer.advanceGameTime`; how it is computed was not read, Open question 14).
2. The queued packet tasks run (`PacketProcessor.processQueuedPackets`), then the other scheduled main-thread tasks (`runAllTasks`). This step runs **once per iteration, even when N is 0**; every received packet (Set Entity Data, Set Equipment) is applied here, which includes the viewer's use start test of §2.3.
3. `tick()` runs min(10, N) times.
4. The render frame (item model resolution of §1 included).

What matters in one `tick()`, in order: the key handling (`handleKeybinds`, **only when neither a screen nor an overlay is open**); then, when a level exists and the game is not paused, the entity tick (`ClientLevel.tickEntities`: each ticking entity's `tick`, where for a living entity `Entity.tick` is followed at once by the use-state rule of §2.2, which holds the decrement of R). The frame of step 4 comes after the whole `tick()`.

`handleKeybinds` (the part that matters here): when the local player is using an item and the use key is **not** down, it calls `releaseUsingItem` (§2.2); when the local player is not using an item, each pending use click calls `startUseItem`, and a held use key with the right-click delay at 0 calls it too. `startUseItem` starts the use through `MultiPlayerGameMode.useItem` (it sends the use packet inside a prediction, checks the client's own item cooldown, and calls `ItemStack.use`, whose item `use` calls `LocalPlayer.startUsingItem`, §2.4), or, when the crosshair is on a block, it tries `MultiPlayerGameMode.useItemOn` first and the item's `useOn` (the brush: `BrushItem.useOn` calls `startUsingItem` when the hit is a block, and the brush has no `use`); `useItemOn` runs `useOn` at once inside its prediction, after the block's own use has not consumed the click. Both routes run inside the same `handleKeybinds` call, so the k = 1 conclusion below holds for the brush as for every other item.

What a rendered frame sees:

- **Local player, use started by the key**: the start (`useItem` set, R = U) is made in `handleKeybinds`, which comes **before** `ClientLevel.tickEntities` in the same `tick()`; the same tick then runs the use-state rule and decrements, and the frame comes after the tick. So the first rendered frame after the press has **R = U − 1, k = 1**; a frame with k = 0 is never rendered for a key-started use of the local player. (The release is also seen before the decrement of its tick.)
- **A use state that is set while packets are applied** (a remote viewer's start test, §2.3; the local player's start from the server's flags, §2.4): the frame has **R = U, k = 0** when the iteration runs no tick between the packet step and the frame (N = 0), and **R = U − 1, k = 1** when it runs at least one tick; later frames count one more per tick. Whether a frame with k = 0 appears at all depends on the iteration having N = 0 at that moment (a frame rate above the tick rate makes that common; inferred, Open question 14).
- For a viewer the start test and the tick are the same rule as for the local player: the viewer's own k counts from its own start (§2.3).

---

## 3. Item-definition properties

### 3.1 Which properties the shipped definitions use

Counted from the 1658 files `assets/minecraft/items/*.json` of the jar (`unzip -Z1 | grep -v '/$' | grep assets/minecraft/items/ | wc -l` gives 1658), by walking every node that has a `property` member:

| Kind | Property | Nodes | Files |
|---|---|---|---|
| condition | `using_item` | 5 | `bow`, `crossbow`, `goat_horn`, `shield`, `trident` |
| condition | `bundle/has_selected_item` | 17 | the 17 bundles |
| condition | `has_component` | 2 | `compass` (`lodestone_tracker`), `wolf_armor` (`dyed_color`) |
| condition | `broken` | 1 | `elytra` |
| condition | `fishing_rod/cast` | 1 | `fishing_rod` |
| range_dispatch | `use_duration` | 1 | `bow` |
| range_dispatch | `crossbow/pull` | 1 | `crossbow` |
| range_dispatch | `use_cycle` | 1 | `brush` |
| range_dispatch | `compass` | 3 | `compass` (spawn, lodestone), `recovery_compass` (recovery) |
| range_dispatch | `time` | 2 | `clock` (daytime, random) |
| select | `display_context` | 26 | the 17 bundles, `spyglass`, `trident`, 7 spears |
| select | `charge_type` | 1 | `crossbow` |
| select | `trim_material` | 29 | armor pieces |
| select | `block_state` | 12 | `bee_nest`, `beehive`, `light`, `test_block`, the copper golem statues |
| select | `context_dimension` | 1 | `clock` |
| select | `local_time` | 2 | `chest`, `trapped_chest` |

No shipped definition uses `selected`, `carried`, `extended_view`, `keybind_down`, `view_entity`, `component`, `damaged`, `custom_model_data`, `damage`, `cooldown`, `bundle/fullness`, `count`, `main_hand` or `context_entity_type`; they exist in the client and are listed in §3.13. **No definition dispatches on the `instrument` component or on any stack data other than those above**: the goat horn model does not vary with the instrument.

The registered ids are the ones listed in 08 §6.3 (verified against the three property registries).

### 3.2 `minecraft:using_item` (condition, no options)

True exactly when: the owner is a living entity (a **null** owner gives false), `owner.isUsingItem()` is true, and `owner.getUseItem()` **is** the stack (§2.5). It reads no other state (not the hand, not the use animation, not the remaining ticks). For the local player `isUsingItem` is the predicted flag of §2.4, so the first-person model switches as soon as the client starts the use (the first rendered frame, §2.6), without waiting for the server; for a remote entity it is metadata bit 1 (§2.3). It is evaluated per frame (the render state is rebuilt each frame), so the model changes on the frame after the state changes.

The context does not matter to the property: a stack in the used hand is "in use" for the first-person and third-person hand contexts alike, and also for the `head`, `gui`, `ground` or `fixed` contexts whenever the caller passes an owner that uses this stack object. Which callers pass an owner is in §1.1: **a null owner is passed only by `fakeItem`** (result slots, recipe book, advancements, toasts, merchant, flat-world lists) and by holders that have no entity; a non-living holder entity (an item frame, a dropped item) is not a living entity, so the property is false for it as well. The GUI's ordinary draws (hotbar, off-hand slot, inventory and container slots, cursor stack, creative tabs) pass the local player (or the camera player for the hotbar), so for them the property can be true. A stack in a slot of the player's inventory is the **same object** as the hand stack (`Inventory.getItem(selected)` is the main-hand stack; the off-hand slot is the off-hand stack), and `useItem` is that object (§2.2), so in the GUI the stack of the used hand passes the identity test (inferred from the object identity read in the container and inventory code, not run; a stack object replaced by a container sync is re-pointed by the next tick, §2.2). The shipped definitions that read `using_item` (bow, crossbow, shield, goat horn, trident) therefore take their in-use branch for a used stack in a slot; what is visible is in §6 (the GUI note). Only the trident keeps the GUI away from its `using_item` node, and it does so by its own `display_context` select (§6), not by the owner.

### 3.3 `minecraft:use_duration` (range_dispatch)

Options: `remaining` (boolean, default false); the node's `scale` (default 1).

Value: 0.0 when the owner is not a living entity, or the owner's `useItem` is not the stack (§2.5; note that the test is the identity only: `isUsingItem` is not asked). Otherwise, with U = `stack.getUseDuration(owner)` and R = `owner.getUseItemRemainingTicks()` (int): `remaining` true gives R as a float; false gives (U − R) as a float, the number of ticks used. There is **no partial tick** in the value: it is an integer that changes once per client tick. For the local player R is the predicted count (§2.4); for another entity R is the viewer's count since the flag arrived (§2.3). For a stack that is not in use the value is 0, so a definition that wants "not in use" to fall to the fallback should keep its first threshold above 0 (the bow does: it is nested inside `using_item`, and its first entry is the fallback).

### 3.4 `minecraft:crossbow/pull` (range_dispatch, no options)

Value: 0.0 when the owner is not a living entity or when the stack is charged (`charged_projectiles` non-empty, 25-7 §9.3). Otherwise (U − R) / C as a float division, with U − R as in §3.3 and C = `CrossbowItem.getChargeDuration(stack, owner)` (an int, the Quick Charge adjusted 25, 20, 15 or 10 ticks, 25-7 §9.3). It does **not** test that the stack is the entity's use item: if the entity is not using anything, R is 0 and the value is U / C (72000 / 25 = 2880), so the property is only meaningful under `using_item`, which is how the shipped crossbow uses it. No `scale` is set (1).

### 3.5 `minecraft:use_cycle` (range_dispatch)

Option `period` (a positive float, default 1.0; the shipped brush uses 10.0); `scale` as usual (default 1.0, read in the range_dispatch node; the brush: 0.1). Value: 0.0 for a non-living owner or when `useItem` is not the stack; otherwise the Java float remainder `R mod period` (R the remaining ticks as a float; the remainder has the sign of R, so a negative R gives a value in (−period, 0]). The brush is therefore driven by the **remaining** ticks, which count down: the sequence of remainders over successive ticks is 9, 8, ..., 0, 9, ..., not up.

### 3.6 `minecraft:charge_type` (select)

Value: NONE when the stack has no `charged_projectiles` component or it is empty; ROCKET when it holds a `firework_rocket`; else ARROW (the check order read: rocket, then arrow). The values are written `none`, `arrow`, `rocket`. The owner is not read.

### 3.7 `minecraft:display_context` (select)

Value: the context argument itself. The `when` strings are the names of §1.4. It reads nothing else, so it works with a null owner.

### 3.8 `minecraft:fishing_rod/cast` (condition)

True when the owner is a player whose `fishing` field (the bobber) is not null and the stack equals (identity) the stack held by the arm `FishingHookRenderer.getHoldingArm(player)`: the player's main arm when the main-hand item is a fishing rod, otherwise the opposite arm. False for a non-player or null owner.

### 3.9 `broken`, `damaged`, `has_component`, `bundle/has_selected_item` (conditions)

- `broken`: `stack.nextDamageWillBreak()` (the next point of damage would break the stack; an item without durability is false). Owner not read.
- `damaged`: `stack.isDamaged()`. Owner not read.
- `has_component`: option `component` (a data component type, required) and `ignore_default` (boolean, default false). False `ignore_default`: the stack has the component (`has`, which includes prototype defaults); true: it has a component value that differs from the item's default (`hasNonDefault`). Owner not read.
- `bundle/has_selected_item`: a bundle's selected entry exists (`BundleItem.getSelectedItem(stack)` non-null). Owner not read.

### 3.10 `minecraft:time` (range_dispatch)

Options: `source` (required in the shipped data: `daytime` or `random`; the code also has `moon_phase`); `wobble` (boolean, default true); `scale`. The raw value T by source: `daytime`: the environment attribute `sun_angle` evaluated at the owner's position, divided by 360 (12 §3.1, 12 §3.2); `moon_phase`: the moon phase index divided by the phase count (`MoonPhase.COUNT`, read as the length of the enum's constant array: 8 constants, indices 0 `full_moon` to 7 `waxing_gibbous`); `random`: the next `nextFloat()` of a per-property random source (`RandomSource.create()`). A level or owner is required (the property needs a position). With `wobble` true the value goes through a wobbler once per **game tick** (it only updates when the level game time differs from its last update tick): d = positiveModulo(T − rotation + 0.5, 1) − 0.5; deltaRotation = (deltaRotation + d × 0.1) × 0.9; rotation = positiveModulo(rotation + deltaRotation, 1); the property returns `rotation`. With `wobble` false it returns T directly (the non-wobbler; assumed to hold T unchanged, inferred). Shipped use: `clock`: a `select` on `context_dimension` (§3.12): `minecraft:overworld` takes a `range_dispatch` of `time` (source `daytime`, scale 64.0) with 65 entries (thresholds 0.0, 0.5, 1.5, ... 63.5, models `item/clock_00` to `item/clock_63`, and the entry at 63.5 is `clock_00` again); every other dimension falls back to the same dispatch with source `random`.

### 3.11 `minecraft:compass` (range_dispatch)

Options: `target` (`none`, `lodestone`, `spawn`, `recovery`; required), `wobble` (boolean, default true); `scale` (shipped: 32.0; no `fallback`, `wobble` not written so true). The shipped lists (read from `compass.json`, both of its dispatch nodes, and from `recovery_compass.json`; all three have the same rule): 33 entries in this order; entry 0 has threshold 0.0 and entry i for i = 1 to 32 has threshold i − 0.5 (0.5, 1.5, ... 31.5); entry i has the model `item/compass_NN` with NN = (16 + i) mod 32 written with two digits (`recovery_compass_NN` in `recovery_compass.json`). So the list starts `compass_16` (0.0), `compass_17` (0.5), `compass_18` (1.5) and ends `compass_14` (29.5), `compass_15` (30.5), `compass_16` (31.5): the last entry is `compass_16` again and entry 0 and entry 32 show the same model. For v = rotation × 32 in [0, 32) the frame is therefore `compass_NN` with NN = (16 + floor(v + 0.5)) mod 32 (inferred from the entries; v and the thresholds are exact in 32-bit floats at the halves). The other compass-like items have no separate list: `compass.json` is the lodestone and spawn compass (below), `recovery_compass.json` the recovery compass; no other shipped definition uses the `compass` property. Target position P: `lodestone`: the `lodestone_tracker` component's target (a global position, may be absent); `spawn`: the client level's respawn data global position; `recovery`: the owner player's last death location (absent when none or when the owner is not a player). A target is **valid** when it exists, its dimension equals the owner's level dimension, and the squared distance from the block centre to the owner's position is at least 9.999999747378752E-6. With no valid target the needle spins randomly: a wobbler (factor 0.8, state private to the property) is updated once per game tick with a random float and the result is `positiveModulo(rotation + hash(seed) / 2.1474836E9, 1)` with hash(i) = i × 1327217883 (int overflow). With a valid target: a = atan2(dz, dx) / 6.2831854820251465, where (dx, dz) is the horizontal vector from the owner to the block centre; y = (the owner's visual body yaw in degrees / 360) taken modulo 1. For the **local player** under normal tick rate with `wobble` true: the wobbler (factor 0.8) is updated once per game tick with the value 0.5 − (y − 0.25) and the result is `positiveModulo(a + rotation, 1)`; for every other owner or with `wobble` false: `positiveModulo(0.5 − (y − 0.25 − a), 1)`. `compass.json` is a `condition` on `has_component` `lodestone_tracker` choosing the lodestone dispatch (true) or the spawn dispatch (false). (The wobbler of §3.10 and this one share one algorithm; only the factor differs: 0.9 and 0.8.)

### 3.12 `context_dimension`, `local_time`, `trim_material`, `block_state` (selects)

- `context_dimension`: the client level's dimension key, or null (no value, so `fallback`) when there is no level.
- `local_time`: the option `pattern` (a date-time pattern, shipped `MM-dd`) formatted against the real wall clock; the result is cached and recomputed at most once per fixed interval (the interval constant `UPDATE_INTERVAL_MS` was not read, Open question 5). The shipped chests use it for the Christmas dates (52 part 1).
- `trim_material`: the stack's `trim` component material, none when absent. `block_state`: option `block_state_property`; the value of that property in the stack's `block_state` component, none when absent.

### 3.13 Properties no shipped definition uses (one row each)

| Property | Kind | Reads |
|---|---|---|
| `custom_model_data` | condition, range_dispatch, select | the stack's `custom_model_data` component (flag, float or string at an index) |
| `selected` | condition | true when the owner **is the local player** (an instance of `LocalPlayer`; any other owner, a null owner, and a remote player give false) and the local player's selected inventory stack (`Inventory.getSelectedItem`) **is** the stack (object identity) |
| `carried` | condition | true when the owner **is the local player** (an instance of `LocalPlayer`; any other owner, a null owner and a remote player give false) and the stack **is** (object identity) the carried (cursor) stack of that player's current container menu (`AbstractContainerMenu.getCarried`). A `fakeItem` draw (null owner, §1.1) is therefore never true. The cursor stack that a container screen draws with the local player as owner is the carried object itself (true), except while a quick-craft drag over two or more slots is in progress, when the screen draws a `copyWithCount` copy (false) |
| `extended_view` | condition | true when the context is `gui` and Shift is down |
| `keybind_down` | condition | the named key mapping is held |
| `view_entity` | condition | the owner is the camera entity (`Minecraft.getCameraEntity`) when there is one; when there is no camera entity, the owner is compared with the local player instead |
| `component` | condition (`ComponentMatches`), select (`ComponentContents`) | a data component predicate against the stack |
| `damage` | range_dispatch | option `normalize`, **default true** (read). Normalized: clamp(damage / maximum damage, 0, 1) as a float division (a maximum damage of 0 divides by zero; not examined, no shipped use). Not normalized: clamp(damage, 0, maximum damage). The owner is not read |
| `count` | range_dispatch | option `normalize`, **default true** (read). Normalized: clamp(count / maximum stack size, 0, 1); not normalized: clamp(count, 0, maximum stack size). The owner is not read |
| `cooldown` | range_dispatch | 0 for a null owner or an owner that is not a player. Otherwise the player's item cooldown fraction for the stack, asked with the **constant partial tick 0.0** (not the frame's partial tick): clamp((end time − the cooldown set's tick counter) / (end time − start time), 0, 1) for the cooldown group of the stack, 0 when the group has no running cooldown. It therefore changes once per client tick, not per frame |
| `bundle/fullness` | range_dispatch | `BundleItem.getFullnessDisplay(stack)` |
| `main_hand` | select | the owner's main arm (`left` or `right`); none without an owner |
| `context_entity_type` | select | the owner's entity type key; none without an owner |

These were read only as far as the table says; none is needed by a shipped definition.

---

## 4. The goat horn

### 4.1 The item definition (`assets/minecraft/items/goat_horn.json`)

A single `minecraft:condition` node: property `minecraft:using_item` (§3.2), `on_false` = `minecraft:model` `minecraft:item/goat_horn`, `on_true` = `minecraft:model` `minecraft:item/tooting_goat_horn`. No `tints`, no `transformation`, no `component` test, no other top-level members. So: one flat model per state; the model never varies with the `instrument` component (all eight instruments, the plain horn included, look the same); no tint (the quad colour is white).

### 4.2 The two models

Both are `models/item/*.json` with `parent` `item/generated` (which has `parent` `builtin/generated` and `gui_light` `front`), `textures` {`layer0`: `item/goat_horn`} (the **same** texture in both) and a `display` block. `builtin/generated` produces the flat extruded mesh of 12 §6.8 from the one layer: layer 0 = `textures/item/goat_horn.png`, a 16 × 16 palette PNG (colour type 3); no `elements`, no other layer, the particle texture defaults to `layer0`. Model-level `gui_light` is `front` (inherited from `item/generated`; neither horn model sets it). The jar has no separate texture for the raised horn.

### 4.3 Display transforms

Per context the first model on the chain model → `item/generated` with an entry is used (12 §8.2). Absent members of a present entry default to rotation (0, 0, 0), translation (0, 0, 0), scale (1, 1, 1). Values as authored (rotation degrees; translation sixteenths; scale per axis):

| Context | `item/goat_horn` (normal) | `item/tooting_goat_horn` (in use) |
|---|---|---|
| `firstperson_righthand` | rot (0, −90, 25), tr (1.13, 3.2, 1.13), sc 0.68 | rot (0, −55, −5), tr (−1, −2.5, −7.5), sc absent = 1 |
| `firstperson_lefthand` | rot (0, 90, −25), tr (1.13, 3.2, 1.13), sc 0.68 | rot (0, 115, 5), tr (0, −2.5, −7.5), sc absent = 1 |
| `thirdperson_righthand` | rot (0, 180, 0), tr (0, 3, 1), sc 0.55 | rot (0, −125, 0), tr (−1, 2, 2), sc 0.5 |
| `thirdperson_lefthand` | rot (0, 0, 0), tr (0, 3, 1), sc 0.55 | rot (0, 55, 0), tr (−1, 2, 2), sc 0.5 |
| `head` | from `item/generated`: rot (0, 180, 0), tr (0, 13, 7), sc 1 | the same (inherited) |
| `gui` | none (no entry in the chain): only the −0.5 recentring | the same |
| `ground` | from `item/generated`: rot (0, 0, 0), tr (0, 2, 0), sc 0.5 | the same |
| `fixed` | from `item/generated`: rot (0, 180, 0), tr absent = 0, sc 1 | the same |
| `on_shelf`, `none` | none | none |

The explicit left-hand entries are applied **mirrored once more** (12 §8.2: translation x negated, rotation y and z negated), so what is applied for the left-hand contexts is: normal first person left rot (0, −90, 25), tr (−1.13, 3.2, 1.13), sc 0.68 (the same rotation as the right hand and a mirrored offset); normal third person left rot (0, 0, 0), tr (0, 3, 1), sc 0.55 (negating a zero changes nothing); in use first person left rot (0, −115, −5), tr (0, −2.5, −7.5), sc 1; in use third person left rot (0, −55, 0), tr (1, 2, 2), sc 0.5. The translation is applied in blocks after division by 16, clamped to ±5 blocks, scale clamped to ±4 (12 §8.2).

Comparison (every display entry of the two models re-compared; authored values, before the left-hand mirror): the two models have the same parent, the same texture and no `elements`; their `display` blocks differ in exactly the four hand contexts and in every one of the three members (rotation, translation, scale) of each; every other context is the same inherited entry.

| Context | rotation, normal to in use | translation (sixteenths), normal to in use (difference) | scale, normal to in use |
|---|---|---|---|
| `firstperson_righthand` | (0, −90, 25) to (0, −55, −5): y +35, z −30 | (1.13, 3.2, 1.13) to (−1, −2.5, −7.5) (−2.13, −5.7, −8.63) | 0.68 to 1 (absent) |
| `firstperson_lefthand` | (0, 90, −25) to (0, 115, 5): y +25, z +30 | (1.13, 3.2, 1.13) to (0, −2.5, −7.5) (−1.13, −5.7, −8.63) | 0.68 to 1 (absent) |
| `thirdperson_righthand` | (0, 180, 0) to (0, −125, 0): y −305 (equal to +55 modulo 360) | (0, 3, 1) to (−1, 2, 2) (−1, −1, +1) | 0.55 to 0.5 |
| `thirdperson_lefthand` | (0, 0, 0) to (0, 55, 0): y +55 | (0, 3, 1) to (−1, 2, 2) (−1, −1, +1) | 0.55 to 0.5 |

The x rotation is 0 in all eight entries. The in-use entries of the two first-person contexts have no `scale` member, so they are drawn at scale 1; the normal entries are at 0.68. For the right hand the in-use first-person horn therefore turns −55 degrees about y instead of −90, rolls −5 about z instead of +25, is drawn at scale 1 instead of 0.68 and moved by (−2.13, −5.7, −8.63) sixteenths; in third person it is drawn at 0.5 instead of 0.55, turned to −125 degrees about y instead of 180 and moved by (−1, −1, +1) sixteenths. The left-hand contexts differ by the amounts in the table before mirroring (the mirrored values are listed above). These entries are the only differences between the two models.

---

## 5. The third-person arm pose of a player who uses a goat horn

### 5.1 Which pose each arm gets (`AvatarRenderer.getArmPose`, the same code for the local player and for every other player)

For each hand stack (main hand, off hand) a pose is computed, in this order, first match wins:

1. empty stack: `EMPTY`;
2. the avatar is **not swinging**, the stack is a crossbow and it is charged: `CROSSBOW_HOLD` (this wins over using the crossbow);
3. the avatar's used hand (`getUsedItemHand`: bit 2 of the flags for a remote avatar, the predicted hand for the local player, §2) is this hand **and** `getUseItemRemainingTicks() > 0`. This test does **not** read `isUsingItem` (bit 1) and does not compare the stack with `useItem`; it reads only the used-hand value and the remaining-ticks count (which is 0 whenever the viewer's use state is cleared, so in a consistent state the two agree). The pose is then chosen by the use animation of this hand's own stack (`ItemStack.getUseAnimation`, evaluated on the hand stack, not on `useItem`): `block` gives `BLOCK`, `bow` gives `BOW_AND_ARROW`, `trident` gives `THROW_TRIDENT`, `crossbow` gives `CROSSBOW_CHARGE`, `spyglass` gives `SPYGLASS`, **`toot_horn` gives `TOOT_HORN`**, `brush` gives `BRUSH`, `spear` gives `SPEAR`; `none`, `eat`, `drink` and `bundle` fall through to step 4;
4. otherwise `SPEAR` when the avatar's current swing is by this hand's arm with swing type `stab`, or the stack is in item tag `spears`; else `ITEM`.

Then the pose of an **arm**: the main arm gets the main-hand pose; the other arm gets the off-hand pose, except that when the main-hand pose is two-handed (`BOW_AND_ARROW`, `CROSSBOW_CHARGE`, `CROSSBOW_HOLD`) the other arm's pose is replaced by `EMPTY` when the off-hand stack is empty and by `ITEM` when it is not. `HumanoidModel.ArmPose` ordinals (read): 0 `EMPTY`, 1 `ITEM`, 2 `BLOCK`, 3 `BOW_AND_ARROW`, 4 `THROW_TRIDENT`, 5 `CROSSBOW_CHARGE`, 6 `CROSSBOW_HOLD`, 7 `SPYGLASS`, 8 `TOOT_HORN` (confirmed: ordinal 8, not two-handed, does not affect the off-hand pose), 9 `BRUSH`, 10 `SPEAR`. `animateUseItem` is a no-op for every pose except `SPEAR`.

The use animation of a horn stack is `toot_horn` for every `goat_horn` stack (`InstrumentItem.getUseAnimation` returns the constant; the stack's instrument is not consulted). The ordinals of `ItemUseAnimation` are 0 `none`, 1 `eat`, 2 `drink`, 3 `block`, 4 `bow`, 5 `trident`, 6 `crossbow`, 7 `spyglass`, 8 `toot_horn`, 9 `brush`, 10 `bundle`, 11 `spear`. The default animation of an item without an override (`Item.getUseAnimation`) is the `consumable` component's animation, else `block` when the stack has `blocks_attacks`, else `spear` when it has `kinetic_weapon`, else `none`; `BowItem`, `CrossbowItem`, `SpyglassItem`, `TridentItem`, `BrushItem` and `InstrumentItem` override it with `bow`, `crossbow`, `spyglass`, `trident`, `brush` and `toot_horn`.

### 5.2 Which entity state selects it

Everything above is read from the viewer's copy of the entity. The inputs, each with its role:

| Input | Where it comes from | Used by |
|---|---|---|
| hand stacks | Set Equipment (05b 0x68) | empty test, charged-crossbow test, use animation (§5.1) |
| used hand (`getUsedItemHand`) | bit 2 of entry 8 (remote avatar), the predicted hand (local player, §2.4) | the per-hand test of §5.1 step 3; the first-posed arm (§5.3) |
| `getUseItemRemainingTicks()` | the viewer's own count (§2.2, §2.3, §2.4) | the per-hand test of §5.1 step 3 (> 0 required, so the horn arm is raised while the remaining count is 140 down to 1 and is lowered at 0; the 140 needs the `instrument` component in the stack, see below) |
| `isUsingItem` | bit 1 of entry 8 (remote), the predicted flag (local, §2.4) | **only** the choice of the first-posed arm (§5.3), the `ticksUsingItem` render input (0 when not using; per arm it is non-zero only for the used hand's arm), and the spyglass `HEAD` state (§6.3); **not** the per-hand pose test of §5.1 |
| swinging, current swing | the viewer's swing state | `CROSSBOW_HOLD` condition and `SPEAR` (§5.1 steps 2 and 4) |
| main arm | entry 15 of the avatar (§5.2.1) | which arm gets the main-hand pose, the arm of each hand, the context of each held-item layer, the first-person context choice |

The use animation comes from the stack in the hand (the stack that Set Equipment delivered). In a consistent viewer state `isUsingItem` and "remaining ticks > 0" go together (the stop of §2.2 sets the count to 0), so the two readings agree; the artifact's per-hand pose test uses the used hand and the count, and the first-posed arm uses `isUsingItem`. They can differ only in the states of §2.3 where bit 1 is set while the viewer's count is 0 (the start test not satisfied yet, or after a viewer-side stop); then the first-posed arm follows the used hand but no arm gets a use pose.

**The horn stack that a viewer receives must carry the `instrument` component.** The viewer's remaining count at its start test (§2.3) is `ItemStack.getUseDuration(entity)`, and `InstrumentItem.getUseDuration` takes it from the stack's `instrument` component: `floor(use_duration × 20)` of that instrument (140 for every shipped instrument), and **0 when the stack has no such component** (read). A stack's component lookup takes the stack's component patch first (a component that the patch marks as removed reads as absent) and the item's prototype second (read in `PatchedDataComponentMap.get` and `DataComponentPatch`), and the `goat_horn` prototype carries a default `instrument` (25-7 §12); so a horn stack delivered by Set Equipment with an empty patch, or with any instrument added, resolves and counts 140, and the component is missing only when the delivered patch removes it (the removed list of 00 §12.2). For a viewer whose horn stack lacks the component: the start test of §2.3 sets `useItemRemaining` to 0, the per-tick decrement then makes it negative (a client never completes a use), the pose test of §5.1 step 3 (remaining > 0) fails in every frame so the used arm gets `ITEM` and not `TOOT_HORN`, while `using_item` (§3.2) does not read the count, so the model still switches to `item/tooting_goat_horn` (the first-posed arm of §5.3 still follows the used hand). The viewer then shows the raised-horn model on an arm that is not raised. A server that builds the Set Equipment stack of a horn must therefore keep the `instrument` component present (leaving the prototype default in place is enough).

### 5.2.1 The main arm of a player (what a server must send)

The rule of §5.1 and §5.3 depends on the main arm of the **viewed** player, remote or local. Trace (read in the artifact):

1. **Where the viewer reads it.** `Avatar.getMainArm` returns the avatar's entity-data entry `DATA_PLAYER_MAIN_HAND`: the first entry that `Avatar` defines, after the living-entity entries 8 to 14 of 18 §1.4, so **index 15** (and **index 16**, `DATA_PLAYER_MODE_CUSTOMISATION`, a Byte, is the next; 21 and 47 §5.3 list both for `player` and `mannequin`). Serializer: `HUMANOID_ARM` (position 42 counting the registered serializers from 0, read; matches the id table of 00 §13.2). Value on the wire: a VarInt id, 0 = left, 1 = right, an id outside 0..1 reads as 0 = left (the codec is an id mapper with the "zero" out-of-bounds strategy). Default: right (`Avatar.DEFAULT_MAIN_HAND`). No client class overrides it: `LocalPlayer`, `AbstractClientPlayer` and `RemotePlayer` declare no `getMainArm`, so the **local player's own** main arm is also this entry, not the client option (the first-person pass picks its display context from `LocalPlayer.getMainArm()`, §1.1).
2. **How it reaches the viewer.** It is ordinary entity data (the receiving routine assigns every received entry to the entity found by id, the local player included). For **other** viewers the tracker's pairing bundle sends it only when it differs from the default (so only for a left-handed player, 18 §1.4, §9.1; the pairing sends the tracker's snapshot of the non-default values, taken when the tracker is created and refreshed at every dirty flush), and any later change is sent on the next tracker pass as a dirty entry. For the **player itself** there is no pairing: the tracker returns at once when asked to pair a player with itself, and the entity's own tracker is skipped when the player is added (both read). The player's own copy therefore arrives only through the dirty flush of the tracker pass (`sendDirtyEntityData`), which sends the dirty entries to the trackers **and to the player itself** (18 §9.2 step 2, read again here). An entry is dirty when it was set to a value different from the current one; `updateOptions` runs in the constructor, so a left-handed player's entry 15 is dirty from the start and goes out with the first tracker pass; a right-handed player's is the default and is never sent.
3. **Where the server learns it.** From the field `mainHand` of the Client Information record, wire form in 03 (Configuration 0x00, Play 0x0E; the field order read in the artifact: language (String, 16), view distance (Byte), chat visibility (VarInt), chat colors (Boolean), model customisation (UByte), **main hand (VarInt id)**, text filtering (Boolean), allows listing (Boolean), particle status (VarInt)). `ServerPlayer.updateOptions` copies it, together with the model customisation, into entries 15 and 16 of the player's entity data. It runs from the `ServerPlayer` constructor, which the spawn step at the end of Configuration (`PrepareSpawnTask`) calls with the Client Information that the Configuration phase stored (so the value is in place before the player is placed and first paired), and again from the play-phase handler for each Client Information packet received later (followed by the hat check of 47 §5.3).
4. **How the client sends its own option.** The option `Options.mainHand` (left or right, default **right**) goes into the record built by `Options.buildPlayerInformation`. The client sends it (a) once, as the first packets of the Configuration phase: right after it sends Login Acknowledged and switches its outbound protocol, it sends the `minecraft:brand` Custom Payload and then Client Information (read in the handler of Login Finished; 01 §7.3), and (b) in Play when `Options.save` calls `broadcastOptions` (for example on closing the Skin Customization screen, which holds the main-hand button, 47 §5.2) and the new record differs from the last one sent. Changing the option alone sends nothing (its update listener is the no-action listener).
5. **How the client's model uses it.** The render state of every avatar and of every armed mob takes `mainArm` from `getMainArm` once per frame; the held-item stack of an arm is the main-hand stack when that arm is the main arm, else the off-hand stack; a hand becomes an arm by `InteractionHand.asArm(mainArm)` (main hand: the main arm; off hand: the opposite arm); §5.1 and §5.3 use exactly these.

**What an implementer must send** so that a viewer shows a left-handed player correctly: (i) read Client Information in both phases (03); (ii) keep the main hand in the player's entity data entry 15 as a HUMANOID_ARM value; (iii) send Set Entity Data (05b 0x65; entry layout in 00 §13.1) with entry (15, serializer 42, VarInt 0 for left) in the pairing bundle of every viewer when the player is left-handed (a right-handed player needs nothing, the default is right), and again to the viewers **and to the player itself** whenever the value changes. If entry 15 is never sent, every player is drawn right-handed by every viewer, and the local player's first-person hands use the right-hand context whatever the client option says; if the self-directed copy is not sent, a left-handed client sees only itself as right-handed (first person and third person) while others see it correctly (inferred). Mobs are different: a mob's main arm is bit 2 of its Mob flags byte (index 15 as well, a BYTE, 18 §1.4); the serializer id in the packet tells the two apart. Not traced (Open question 12): the body of the tracker's `sendToTrackingPlayersAndSelf` is known by name only, and the timing of the joining player's first dirty flush relative to its join packets was not examined.

### 5.3 Which arm gets the horn pose and in what order (`HumanoidModel.setupAnim`)

The arm to pose first is A. **Branch 1, `isUsingItem` true** (the render state's copy of the flag, §5.2): A = the arm of the used hand (`useItemHand` converted to an arm by the main arm: main hand gives the main arm, off hand gives the other arm); **no** two-handed substitution applies in this branch. **Branch 2, not using an item**: A = the arm of the off hand (the opposite of the main arm), replaced by the main arm when the pose of that off-hand arm is two-handed; the substitution exists only in this branch. A is posed first; then the other arm is posed unless A's pose `affectsOffhandPose` (true for `BOW_AND_ARROW`, `THROW_TRIDENT`, `CROSSBOW_CHARGE`, `CROSSBOW_HOLD`). `TOOT_HORN` does not, so **both arms are always posed**: the horn arm with `TOOT_HORN`, the other arm with its own pose (normally `ITEM`, or `EMPTY` for an empty hand). With horns in both hands and one in use, the idle horn's arm is posed `ITEM` (step 3 of §5.1 fails for it).

### 5.4 The pose values

Let h = the head part's rotation at that moment (head xRot = pitch × 0.017453292, head yRot = relative head yaw × 0.017453292, set before the arms, 12 §7.5; the swimming head tilt comes later and is not seen by the arms). The posed arm part is `rightArm` or `leftArm` of the humanoid model (`PlayerModel`; the sleeve parts copy its rotation). `TOOT_HORN` **assigns** (it does not add to) the arm's xRot and yRot and leaves zRot alone:

| Arm | xRot | yRot |
|---|---|---|
| right | clamp(h.xRot, −1.2, 1.2) − 1.4835298 | h.yRot − 0.5235988 |
| left | clamp(h.xRot, −1.2, 1.2) − 1.4835298 | h.yRot + 0.5235988 |

(the constants `TOOT_HORN_XROT_BASE` 1.4835298 = 85 degrees and `TOOT_HORN_YROT_BASE` 0.5235988 = 30 degrees). The left arm's yRot sign is mirrored; 12 §7.5 printed only the right arm's sign (§7). The `SPYGLASS` pose has the same shape: xRot = clamp(h.xRot − 1.9198622 − (0.2617994 when crouching, else 0), −2.4, 3.3) for both arms, yRot = h.yRot − 0.2617994 (right arm) and h.yRot + 0.2617994 (left arm) (`SPYGLASS_ARM_ROT_Y` 0.2617994, `SPYGLASS_ARM_ROT_X` 1.9198622, `SPYGLASS_ARM_CROUCH_ROT_X` 0.2617994; the xRot is the same for both arms, only the yRot sign differs). The pose replaces the walk swing xRot of that arm (the walk term is applied first, §5.5) and the yRot. zRot is whatever the previous steps left (0 at rest; riding sets none).

### 5.5 Ordering inside `setupAnim`, and what happens after the pose

The order of one call: head; walk swing of both arms and legs (12 §7.5); riding adjustment (arms xRot −0.62831855); the two arm poses of §5.3 (this is where the horn values above are assigned); the attack swing (`setupAttackAnimation`, 12 §7.5, which can still add to the posed arm when the swing is by the arm: a horn user who also swings gets the swing terms on top); crouching (arms xRot += 0.4, so a sneaking horn user's arm xRot is the value above plus 0.4, body and arm y += 3.2, 12 §7.5); the idle arm bob (right sign +1, left sign −1: zRot += sign × (cos(age × 0.09) × 0.05 + 0.05), xRot += sign × sin(age × 0.067) × 0.05), which is skipped only for an arm whose pose is `SPYGLASS` (so it **is** applied to a horn arm); the swim animation when `swimAmount` > 0. The pose is therefore applied after the walk animation and before the crouch offset and the idle bob.

### 5.6 The held-item layer in third person (`ItemInHandLayer`)

For the right hand then the left hand (an empty item state is skipped): translateToHand of the arm (root part, then arm part, 12 §6.12: pivot (−5, 2, 0) right or (5, 2, 0) left, slim arms ±0.5 pixel), rotate X −90 degrees, rotate Y 180 degrees, translate (k/16, 2/16, −10/16) with k = +1 right, −1 left (a baby: (0, 1/16, −4.5/16)); then, only for a spear stab by that arm, `SpearAnimations.thirdPersonAttackItem` (34-1 §3.8); then, when `ticksUsingItem(arm)` is non-zero (the arm is the used hand's arm, the viewer's ticks since use start plus the partial tick), the arm pose's `animateUseItem`, which is a **no-op for `TOOT_HORN`** (only `SPEAR` does something). Then the item state is submitted (display transform D of the context, 12 §6.12 step 4; no overlay). So a horn gets **no use-state dependent offset or rotation** in the layer: the whole difference between a held and a raised horn in third person is the arm rotation of §5.4 and the display transform of the model that the property chose (§4.3). The model of each arm is chosen by the context of that arm (right arm: `thirdperson_righthand`), not by the hand.

### 5.7 Entity pose (metadata entry 6) and the cameras

Using a horn sets **no** entity pose: neither `InstrumentItem.use` nor `LivingEntity.startUsingItem` touches the pose, and `Player.updatePlayerPose` does not test `isUsingItem` (read). Entry 6 stays whatever 53 §3.2 derives from movement (standing, crouching, swimming and so on); a horn user who sneaks also gets the crouch term of §5.5. The use cooldown (25-7 §12.2) is server state and is not in the flags.

The local player: in first person (`CameraType` 0) the player model is **not drawn** (12 §7.1: the hand pass is drawn instead; the one exception is a sleeping local player, whose model is drawn even in first person because the entity extraction of `LevelExtractor` skips the camera entity of a non-detached camera only while it is not sleeping), so the arm pose of §5.4 has no visible effect; the first-person hand pass shows the held horn with the `firstperson_*hand` transform of the model chosen with the predicted state, and the first-person arm branch for the `toot_horn` animation does nothing beyond the common arm transform of 12 §6.3 step 1 (12 §6.13, verified: the switch map of the dispatch has no case for `toot_horn`, `spyglass` or `crossbow`). In the two third-person modes (1 and 2) the model is drawn with the same code as for any other player, so the pose and the `thirdperson_*hand` model apply, using the predicted local state. A third-person viewer of another player sees exactly §5.1 to §5.6.

### 5.8 Data path from the server

The server's `LivingEntity.startUsingItem` (§2.2) sends Set Equipment (05b 0x68: the used hand's slot, the stack) and marks flags 1 and 2 dirty; the entity tracker then sends Set Entity Data (05b 0x65) with entry 8 (index 8, serializer id BYTE, value as in §2.1) to the players that track the entity. `ClientPacketListener.handleSetEntityData` assigns the values to the viewer's entity, which fires `onSyncedDataUpdated` for entry 8 (§2.3). The release of the key makes the client send Player Action `RELEASE_USE_ITEM` (05c 0x29), after which the server's `releaseUsingItem` clears flag 1 (flag 2 stays, §2.1) and the next metadata pass tells the viewers.

---

## 6. Held items that change while in use: one table

The "state read" column names the property (§3) or the arm-pose step (§5.1). **What tells a viewer** is the same for every row that is a use state (bow, crossbow while charging, shield, horn, trident, spear, brush, spyglass, food and drink): metadata entry 8 bit 1 (using) and bit 2 (off hand) of §2.1, plus the Set Equipment stack of the hand; Riptide adds bit 4. The crossbow's charged state is the stack's `charged_projectiles` component (Set Equipment), not a flag. The fishing rod's cast state is the player's bobber field (`Player.fishing`), not a living-entity flag (how it reaches a viewer was not traced, Open question 13), and `broken` is stack data. "First-person arm" is the branch of 12 §6.13 step 4 (all begin with the common arm transform of 12 §6.3 step 1 unless said).

| Item (definition file) | State read and thresholds | Models selected (ids) | Use animation; third-person arm pose | First-person arm branch |
|---|---|---|---|---|
| Bow (`bow.json`) | `using_item`; if true, `use_duration` ticks used × 0.05 (§3.3): 0 up to 0.65 exclusive: `bow_pulling_0`; ≥ 0.65: `bow_pulling_1`; ≥ 0.9: `bow_pulling_2`; not using: `bow` | `item/bow`, `item/bow_pulling_0`, `item/bow_pulling_1`, `item/bow_pulling_2` (textures `item/bow`, `item/bow_pulling_0..2`; parent chain `item/bow` → `item/generated`). Ticks used: 0 to 12 stage 0, 13 to 17 stage 1, 18 and more stage 2 (§8.2) | `bow`; `BOW_AND_ARROW` on the using arm and the other arm (12 §7.5) | the bow pose of 12 §6.6; only the using hand is drawn (§6.1) |
| Crossbow (`crossbow.json`) | outer `select` on `charge_type` (§3.6): `arrow` gives `crossbow_arrow`, `rocket` gives `crossbow_firework`; `none`: `using_item`; if true `crossbow/pull` (§3.4): < 0.58 `crossbow_pulling_0`, ≥ 0.58 `crossbow_pulling_1`, ≥ 1.0 `crossbow_pulling_2`; not using `crossbow` | `item/crossbow` (texture `item/crossbow_standby`), `item/crossbow_pulling_0..2`, `item/crossbow_arrow`, `item/crossbow_firework` (textures of the same names) | `crossbow`; charging: `CROSSBOW_CHARGE` (12 §7.5); charged and not swinging: `CROSSBOW_HOLD` even when not using | charging: 12 §6.6 crossbow-charging branch; charged: the held branch of 12 §6.6; both-hand rule of §6.1 |
| Shield (`shield.json`) | `using_item`: true `shield_blocking`, false `shield` (both `minecraft:special` with the shield renderer, node transformation scale (1, −1, −1)) | `item/shield`, `item/shield_blocking` | `block`; `BLOCK` (12 §6.12) | step 1 only for a shield (12 §6.6, §6.12) |
| Goat horn (`goat_horn.json`) | `using_item` (§4) | `item/goat_horn`, `item/tooting_goat_horn` | `toot_horn`; `TOOT_HORN` (§5) | step 1 only (nothing more) |
| Trident (`trident.json`) | outer `select` `display_context`: `gui`, `ground`, `fixed`, `on_shelf` give the flat `item/trident`; every other context goes to a `condition` on `using_item` with the node transformation scale (1, −1, −1): true `item/trident_throwing`, false `item/trident_in_hand`, both drawn by the `minecraft:trident` special renderer | `item/trident`, `item/trident_in_hand`, `item/trident_throwing` | `trident`; `THROW_TRIDENT` | the trident branch of 12 §6.6 (charging, `e / 10`); Riptide after release: the auto-spin branch (12 §6.6, flag 4) |
| Spears (`wooden`, `stone`, `copper`, `iron`, `golden`, `diamond`, `netherite_spear.json`) | `display_context` only: `gui`, `ground`, `fixed`, `on_shelf` give `item/<m>_spear`; all other contexts `item/<m>_spear_in_hand`; top-level `swap_animation_scale` 1.95; **no** use-state switch | `item/<m>_spear`, `item/<m>_spear_in_hand` (parent `item/spear_in_hand`) | `spear` (the stack has `kinetic_weapon`); `SPEAR` | `spear` branch (12 §6.13, 34-1 §3.8) |
| Brush (`brush.json`) | `use_cycle` period 10, scale 0.1 (§3.5): v = (remaining mod 10) × 0.1; < 0.25 `brush`; ≥ 0.25 `brush_brushing_0`; ≥ 0.5 `brush_brushing_1`; ≥ 0.75 `brush_brushing_2`. The phase depends on the starting count: the brush's use duration is 200 (`BrushItem.getUseDuration`, read; 17 §3.5), so remaining 200 (k = 0) gives remaining mod 10 = 0, v = 0, and `brush`, and remaining 199 (k = 1) gives `brush_brushing_2` (v 0.9) and so on (table in §8.4). The **local player's first rendered frame after the key press has remaining 199 (k = 1)**, so the first model it shows is `brush_brushing_2`; remaining 200 (the `brush` model at k = 0) is rendered only for a use state that was set while packets were applied and with no tick before the frame (a remote viewer; §2.6) | `item/brush`, `item/brush_brushing_0..2` (parent `item/generated`; texture `item/brush`) | `brush`; `BRUSH` | `applyBrushTransform` (§6.2) |
| Spyglass (`spyglass.json`) | `display_context`: `gui`, `ground`, `fixed`, `on_shelf` give `item/spyglass`; all others `item/spyglass_in_hand`; no use-state switch | `item/spyglass`, `item/spyglass_in_hand` (a custom model with 2 elements) | `spyglass`; `SPYGLASS` (12 §7.5; right and left yRot signs differ, §5.4); while using, the avatar also gets a second item state `heldOnHead` for the stack in the context `head` (§6.3) | neither hand is drawn while `isScoping` (12 §6.6) |
| Food and drink (no switch; `apple.json`, `honey_bottle.json`, `potion.json`, `milk_bucket.json` and so on) | none | the one model | `eat` or `drink` (the `consumable` animation); `ITEM` (no third-person pose) | the eat transform of 12 §6.6 |
| Fishing rod (`fishing_rod.json`) | `fishing_rod/cast` (§3.8) | `item/fishing_rod`, `item/fishing_rod_cast` | none; `ITEM` | step 1 and the swing |
| Elytra (`elytra.json`) | `broken` (§3.9) | `item/elytra`, `item/elytra_broken` | none; `ITEM` | not a use state; listed because it switches on stack state |
| Bundle (17 definitions) | `display_context` `gui` only, then `bundle/has_selected_item` | `item/bundle`, open back, `bundle/selected_item`, open front (GUI only) | `bundle`; `ITEM` (the `bundle` animation falls through, §5.1 step 4) | the swing of 12 §6.3 step 2 |

**The GUI context (slot icons).** Every row above is also resolved for the `gui` context when a slot, the hotbar or the cursor draws the stack (owner = the local player or the camera player, §1.1, §3.2), and for a stack that is the owner's `useItem` object the use-state properties are true there (inferred from the object identity, §3.2). What the icon shows, read from the shipped definitions and models:

| Item | GUI result while the stack is the used stack |
|---|---|
| Bow | `using_item` is true, so the icon follows `use_duration` ticks used × 0.05 (§3.3): `item/bow_pulling_0`, `_1`, `_2` with their own textures (`item/bow_pulling_N`). Neither the bow models nor their parent `item/generated` have a **`gui` display entry**, so the icon is the flat model with the pulling texture: the slot icon shows the pulling frames |
| Crossbow | the same with `crossbow/pull`: `crossbow_pulling_0`, `_1`, `_2`, textures `item/crossbow_pulling_N`, no `gui` entry; the slot icon shows the pulling frames (a charged crossbow shows `crossbow_arrow` or `crossbow_firework` through `charge_type`, whether or not it is in use) |
| Shield | `using_item` selects `item/shield_blocking` as the base, but its `gui` display entry (rot (15, −25, −5), tr (2, 3, 0), sc 0.65) is **identical** to that of `item/shield`, both nodes use the same special renderer `minecraft:shield` and the same node transformation, so the icon looks the same (inferred from the equal data) |
| Goat horn | the model switches to `item/tooting_goat_horn`, but neither horn model has a `gui` entry and both use the same texture `item/goat_horn`, so the icon **looks identical** |
| Brush | `use_cycle` reads only the identity (not `using_item`), so the model cycles while the stack is the used stack, but all four brush models use the same texture `item/brush` and have no `gui` entry: the icon looks identical |
| Trident, spears, spyglass | `gui` is routed by the definition's own `display_context` select to the flat inventory model, so the use state is never read: no change |

For a `fakeItem` draw (null owner) and for any stack that is not the owner's used stack, the normal model is shown.

### 6.1 Which hands the first-person pass draws (`FirstPersonHandsAndItems.evaluateWhichHandsToRender`)

Neither hand holds a bow or a crossbow: both hands are drawn. Otherwise, while the local player is using an item: when the used stack is a bow or crossbow, only the used hand is drawn; when it is another item, only the main hand if the used hand is the main hand and the off-hand stack is a charged crossbow, else both. Not using: only the main hand when the main-hand stack is a charged crossbow, else both. (Charged = a crossbow with non-empty `charged_projectiles`.) A horn never changes this.

### 6.2 The brush arm transform (first person, `applyBrushTransform`)

Closes the brush half of 12 Open question 6. Inputs: the arm (s), the frame's partial tick f (the first float of the dispatch, as for the bow branch of 12 §6.6; inferred) and R, the remaining use ticks as a float. r = R mod 10 (float remainder); e = r − f + 1; p = 1 − e / 10; θ = −15 + 75 × cos(2π p) degrees, with the table cosine `Mth.cos` (the sine table of 10 §16.3). The common step 1 of 12 §6.3 has already been applied (`brush` has no custom arm transform, 12 §6.13 step 4); the branch then applies, in call order: right arm: translate (−0.25, 0.22, 0.35); rotate X −80; rotate Y +90; rotate Z 0; rotate X θ. left arm: translate (0.1, 0.83, 0.35); rotate X −80; rotate Y −90; rotate X θ; translate (−0.3, 0.22, 0.35). (Doubles for the translations; degrees for the rotations; each call multiplies on the right, 12 §6.)

### 6.3 The spyglass on the head

`AvatarRenderer.extractRenderState` clears `heldOnHead` and, when the avatar is using an item and the used-hand stack is a spyglass, resolves that stack for the context `HEAD` into `heldOnHead` (the item definition's `display_context` select sends `head` to `item/spyglass_in_hand`, whose `head` display is rot (90, 0, 0), tr (0, 0, −16), sc 1.6). The renderer draws it in place of the hand placement of 12 §6.12 (the "held to the eye" case). `LocalPlayer.isScoping` (`Player.isScoping`) is `isUsingItem && useItem is a spyglass`; the overlay and the zoom are outside this document.

### 6.4 Display transforms of the in-use models

Authored values (rotation; translation; scale), applied with the left-hand mirror of 12 §8.2. "gen" means inherited from `item/generated` (12 §8.2). All models listed have `gui_light` `front` unless they have no `parent` and set it themselves (the shield models, the trident models: `front`).

| Model | `firstperson_righthand` | `firstperson_lefthand` | `thirdperson_righthand` | `thirdperson_lefthand` | `gui` | `ground` | `fixed` | `head` |
|---|---|---|---|---|---|---|---|---|
| `item/bow`, `bow_pulling_0..2` | own (0,−90,25); (1.13,3.2,1.13); 0.68 (the same values as `item/generated`) | own (0,90,−25); (1.13,3.2,1.13); 0.68 | own (−80,260,−40); (−1,−2,2.5); 0.9 | own (−80,−280,40); (−1,−2,2.5); 0.9 | none | gen (0,0,0); (0,2,0); 0.5 | gen (0,180,0); 0; 1 | gen (0,180,0); (0,13,7); 1 |
| `item/crossbow` and its 5 variants | own (−90,0,−55); (1.13,3.2,1.13); 0.68 | own (−90,0,35); (1.13,3.2,1.13); 0.68 | own (−90,0,−60); (2,0.1,−3); 0.9 | own (−90,0,30); (2,0.1,−3); 0.9 | none | gen | gen | gen |
| `item/shield` | 12 §6.12 | 12 §6.12 | 12 §6.12 | 12 §6.12 | 12 §6.12 | 12 §6.12 | 12 §6.12 | none |
| `item/shield_blocking` | 12 §6.12 | 12 §6.12 | 12 §6.12 | 12 §6.12 | (15,−25,−5); (2,3,0); 0.65 | none | none | none |
| `item/goat_horn`, `item/tooting_goat_horn` | §4.3 | §4.3 | §4.3 | §4.3 | none | gen | gen | gen |
| `item/trident_in_hand` | (0,−90,25); (−3,17,1); 1 | (0,90,−25); (13,17,1); 1 | (0,60,0); (11,17,−2); 1 | (0,60,0); (3,17,12); 1 | (15,−25,−5); (2,3,0); 0.65 | (0,0,0); (4,4,2); 0.25 | (0,180,0); (−2,4,−5); 0.5 | none |
| `item/trident_throwing` | (0,−90,25); (−3,17,1); 1 | (0,90,−25); (13,17,1); 1 | (0,90,180); (8,−17,9); 1 | (0,90,180); (8,−17,−7); 1 | (15,−25,−5); (2,3,0); 0.65 | (0,0,0); (4,4,2); 0.25 | (0,180,0); (−2,4,−5); 0.5 | none |
| `item/trident` (flat, `parent` `item/generated`) | gen | none authored; filled from the right entry by the per-file rule | gen (0,0,0); (0,3,1); 0.55 | filled from right | none | gen | gen | gen |
| `item/<m>_spear_in_hand` (parent `item/spear_in_hand`) | own (−20,90,−35); (3.13,2,0.13); (1.36,1.36,0.68) | own (−20,−90,35); same translation and scale | own (5,270,−40); (0,2,2); (1.7,1.7,0.85) | own (5,−270,40); same | none | gen | gen | gen |
| `item/brush`, `brush_brushing_1` | gen (0,−90,25); (1.13,3.2,1.13); 0.68 | own (55,−85,0); (8,0.5,−5.5); 1 | own (0,0,45); (0,4,0); 0.9 | own (0,0,−45); (0,4,0); 0.9 | none | gen | gen | gen |
| `item/brush_brushing_0` | gen | own as `brush` | own (0,0,0); (4,2,0); 0.9 | own (0,0,0); (−4,2,0); 0.9 | none | gen | gen | gen |
| `item/brush_brushing_2` | gen | own as `brush` | own (0,0,90); (−4,2,0); 0.9 | own (0,0,−90); (4,2,0); 0.9 | none | gen | gen | gen |
| `item/spyglass_in_hand` | none | none | own tr (0,−2,0) (rot 0, sc 1) | filled from the right entry | own rot (−67.5,0,45); sc 1.5 | own rot (90,0,0) | own tr (0,0,−1.5); sc 1.5 | own (90,0,0); (0,0,−16); 1.6 |
| `item/fishing_rod`, `fishing_rod_cast` (parent `item/handheld_rod`) | (0,90,25); (0,1.6,0.8); 0.68 | (0,−90,−25); (0,1.6,0.8); 0.68 | (0,90,55); (0,4,2.5); 0.85 | (0,−90,−55); (0,4,2.5); 0.85 | none | gen | gen | gen |

"gen" for the model's contexts: `item/generated` has `thirdperson_righthand` (0,0,0); (0,3,1); 0.55, `firstperson_righthand` (0,−90,25); (1.13,3.2,1.13); 0.68, no `thirdperson_lefthand`, no `firstperson_lefthand`, no `gui`.

---

## 7. Cross-check against the existing documents

| Document, place | Statement | Result |
|---|---|---|
| 12 §7.5 `TOOT_HORN` row | "xRot = clamp(head.xRot, −1.2, 1.2) − 1.4835298; yRot = head.yRot − 0.5235988" | xRot correct. yRot is correct for the **right** arm only; the left arm is head.yRot **+** 0.5235988 (read in `poseLeftArm`). Corrected in 12 §7.5. |
| 12 §7.5 `SPYGLASS` row | "xRot = clamp(head.xRot − 1.9198622 − (0.2617994 when crouching, else 0), −2.4, 3.3); yRot = head.yRot − 0.2617994" | the same left-arm defect: xRot is correct and is the same for both arms; yRot is head.yRot − 0.2617994 for the **right** arm and head.yRot **+** 0.2617994 for the **left** arm (read in `poseRightArm` and `poseLeftArm`). Corrected in 12 §7.5; the values are repeated in §5.4. |
| 12 §7.5 pose application | "applied after the poses to both arms" for the bob | confirmed; the order walk, riding, arm poses, attack swing, crouch, bob, swim (§5.5) is new text |
| 34-2 §4.2 "Order" | "A = (isUsingItem ? the arm of `useItemHand` : the opposite of the main arm); if pose(A) is twoHanded, A = the main arm" | the two-handed substitution applies **only** in the not-using branch; with `isUsingItem` A is the used hand's arm without substitution (§5.3). Corrected in place in 34-2 §4.2 (the `Order` sentence). |
| 34-2 §4.2 parenthetical list of arm-pose formulas | `SPYGLASS` yRot = head.yRot − 0.2617994 and `TOOT_HORN` yRot = head.yRot − 0.5235988 (no arm named) | right arm only; the left arm is head.yRot + 0.2617994 (`SPYGLASS`) and head.yRot + 0.5235988 (`TOOT_HORN`), xRot the same for both arms (read in `poseRightArm` and `poseLeftArm`). Corrected in place in 34-2 §4.2: the two formulas now name both arms. |
| 12 §7.5 idle arm bob | "applied after the poses to both arms ... unless that arm holds a spyglass" | the skip is tested per arm on the arm's **pose**: the right arm is not bobbed when `rightArmPose` is `SPYGLASS`, the left arm not when `leftArmPose` is `SPYGLASS` (read in `HumanoidModel.setupAnim`). The pose is `SPYGLASS` only for the arm whose hand is being used with remaining ticks > 0 and a `spyglass` use animation (§5.1 step 3); an arm that merely holds a spyglass has the pose `ITEM` and **is** bobbed. Corrected in place in 12 §7.5 (the idle-bob sentence). |
| 18 §1.4 "Slots 15 and up exist only for Mob subclasses" | | the three direct subclasses of the living entity each start a run at 15: `Mob` (15 mob flags), `Avatar` (15 main arm, 16 model customisation; the base of `Player` and `Mannequin`, §5.2.1) and `ArmorStand` (15 client flags, 16 to 21 the six pose rotations, by declaration order). Corrected in place in 18 §1.4 (the sentence, with a pointer to §5.2.1). |
| 12 §6.6, §6.13 | the first-person branches of `toot_horn`, `spyglass`, `crossbow` (non-crossbow) do nothing beyond step 1; the dispatch mapping | confirmed (the switch map has cases only for none, eat, drink, block, bow, trident, brush, bundle, spear) |
| 12 §6.6 "Brush: not reproduced" | | now read: §6.2; 12 §6.6 and Open question 6 point here |
| 12 §6.12 shield display data and the BLOCK pose | table and the use-animation to pose rule | confirmed against `shield.json` models and `AvatarRenderer.getArmPose` |
| 25-7 §12.2 | use animation `toot_horn`, use duration `floor(use_duration × 20)` = 140, no pose | confirmed (`InstrumentItem.getUseAnimation`, `getUseDuration`; no pose call) |
| 57-1 §3.4 | "On the client the using-item state comes from the living-entity flags metadata" | true for every entity except the local player, whose use state is predicted (§2.4); pointer added |
| 08 §6.3 | the property id lists | confirmed against the three property registries (§3.1) |

---

## 8. Worked examples (for tests)

Notation: U = the stack's use duration, R = `useItemRemaining` and k = U − R, the ticks used, **as seen by a rendered frame** (the render step comes after the iteration's ticks, §2.6). The rows below are functions of k (or of R). Which k a frame can show first depends on how the use started (§2.6): for the **local player's key press** the first rendered frame has **k = 1** (R = U − 1), because the key handling that starts the use runs before the entity tick of the same client tick and the tick then decrements; a row with k = 0 is rendered only for a use state that is set while packets are applied (a remote viewer, or the local player started by the server's flags) and only when the loop iteration runs no tick between the packet step and the frame; otherwise those start at k = 1 too. Every table row for k = 0 is therefore conditional, as noted in its row. All values are exact floats of the artifact's arithmetic (§1.2).

### 8.1 Goat horn (instrument any; use duration 140)

Every row assumes that the horn stack in the viewer's hand carries the `instrument` component (§5.2); the consequence of a stack without it is stated after the table.

| Moment | State | `using_item` | Model | Third-person arm pose of the used arm |
|---|---|---|---|---|
| Before use | not using | false | `item/goat_horn` | `ITEM` (right arm xRot × 0.5 − 0.31415927, yRot 0) |
| k = 0 (conditional, §2.6: only a use state set during packet handling with no tick before the frame, so a remote viewer's frame or a server-started local use; **never** the first frame of a local key press) | `useItem` is the hand stack, remaining 140 | true | `item/tooting_goat_horn` | `TOOT_HORN` (remaining 140 > 0) |
| k = 1 (the **first rendered frame of a local key press**; a remote viewer's frame after one tick) | remaining 139 | true | `item/tooting_goat_horn` | `TOOT_HORN` |
| k = 139 | remaining 1 | true | `item/tooting_goat_horn` | `TOOT_HORN` |
| k = 140 | remaining 0 (the server completes the use at this decrement, §2.2; the horn is not a release item) | true until the clear flag arrives | `item/tooting_goat_horn` until then | `ITEM` (remaining is not > 0) |
| After release or completion | `useItem` empty, remaining 0 | false | `item/goat_horn` | `ITEM` |

For the horn nothing depends on whether the first rendered frame is k = 0 or k = 1: the model and the pose are the same in both (`using_item` is true and R > 0 in both); the only things that differ are the value of R (140 or 139) and, for the local player, that the first frame is k = 1 (§2.6).

For a viewer whose horn stack has **no `instrument` component** (§5.2) the use duration is 0: R is 0 at the start and negative after the first tick, `using_item` is true from the start test on, so the model column is as in the table (`item/tooting_goat_horn` while the use lasts), but remaining is never > 0, so the pose column reads `ITEM` in every using row (the horn is never raised) until the clear flag arrives.

Arm numbers with head pitch 0, head yaw 0, no sneaking, `ageInTicks` 0, no walk, no swing: right arm (xRot, yRot, zRot) = (−1.4835298, −0.5235988, 0.1); left arm = (−1.4835298, +0.5235988, −0.1) (the zRot values come from the idle bob, §5.5). Head pitch 60 degrees (1.0471976): both xRot = −0.4363322 (the clamp bound 1.2 is not reached); pitch 80 degrees (1.3962634): clamped to 1.2, xRot = −0.2835298; pitch −90 degrees: clamped to −1.2, xRot = −2.6835298. Head yaw 30 degrees: right yRot 0, left yRot 1.0471976. Sneaking adds 0.4 to xRot of both arms (−1.0835298 at pitch 0).

### 8.2 Bow (use 72000, scale 0.05, thresholds 0.65 and 0.9; ticks used = 72000 − remaining)

| Ticks used | v = ticks × 0.05f (float) | Model |
|---|---|---|
| 0 | 0.0 | `item/bow_pulling_0` |
| 5 | 0.25 | `item/bow_pulling_0` |
| 10 | 0.5 | `item/bow_pulling_0` |
| 12 | 0.6000000238418579 | `item/bow_pulling_0` |
| 13 | 0.6500000357627869 (≥ 0.6499999761581421) | `item/bow_pulling_1` |
| 15 | 0.75 | `item/bow_pulling_1` |
| 17 | 0.8500000238418579 | `item/bow_pulling_1` |
| 18 | 0.9000000357627869 (≥ 0.8999999761581421) | `item/bow_pulling_2` |
| 20 | 1.0 | `item/bow_pulling_2` |
| not using | `using_item` false | `item/bow` |

The float products agree with the exact fractions at every integer tick: the thresholds are crossed at 13 and 18 ticks used (0.65 / 0.05 and 0.9 / 0.05 rounded up to whole ticks). The row for 0 ticks used is conditional (§2.6): the local player's first frame after the key press is 1 tick used (v = 0.05f, `item/bow_pulling_0`, the same model as 0). A bow use is not a release item: if it is never released it completes on the server at 72000 ticks used (§2.2).

### 8.3 Crossbow (pull = (72000 − remaining) / C as float division; thresholds 0.58 and 1.0)

C = 25 (Quick Charge 0): ticks 0 to 14 `crossbow_pulling_0` (14/25 = 0.56; the local player's first frame after the key press is tick 1, §2.6); ticks 15 to 24 `crossbow_pulling_1` (15/25 = 0.6000000238418579; 24/25 = 0.9599999785423279); tick 25 and later `crossbow_pulling_2` (1.0 ≥ 1.0) until the stack is charged, after which `charge_type` selects `crossbow_arrow` or `crossbow_firework` and `crossbow/pull` is no longer asked. First tick of stage 1 / stage 2: C = 25: 15 / 25; C = 20: 12 / 20; C = 15: 9 / 15; C = 10: 6 / 10. An uncharged crossbow that is not in use shows `item/crossbow`.

### 8.4 Shield, brush

Shield: not using `item/shield`; using (any tick) `item/shield_blocking`; the model switches on the first use tick (the delay before blocking counts in damage, 17, is not in the model). Brush (R = remaining ticks, v = (R mod 10) × 0.1f): R mod 10 in {0, 1, 2}: `item/brush`; {3, 4}: `brush_brushing_0`; {5, 6, 7}: `brush_brushing_1` (5 gives exactly 0.5); {8, 9}: `brush_brushing_2`. As R counts down the model steps 2, 1, 0 and falls back to `brush` for three ticks of every ten.

Brush from the start of a use (use duration 200, §6; ticks used k = 200 − R as in the notation above). **The local player's first rendered frame after the key press is k = 1 (R = 199)** and shows `item/brush_brushing_2` (§2.6); the row k = 0 (R = 200) is rendered only for a use state that is set while packets are applied (a remote viewer, or a local start from the server's flags) and only when no tick runs between the packet step and the frame; otherwise those viewers also start at k = 1:

| k (R) | R mod 10 | v | Model |
|---|---|---|---|
| 0 (200), conditional (see above; never the local key press) | 0 | 0.0 | `item/brush` (when it is rendered at all, one frame or a few frames with no tick between; the same model is shown again at k = 8 to 10) |
| 1 (199), 2 (198) | 9, 8 | 0.9, 0.8 | `item/brush_brushing_2` |
| 3 (197), 4 (196), 5 (195) | 7, 6, 5 | 0.7, 0.6, 0.5 | `item/brush_brushing_1` |
| 6 (194), 7 (193) | 4, 3 | 0.4, 0.3 | `item/brush_brushing_0` |
| 8 (192), 9 (191), 10 (190) | 2, 1, 0 | 0.2, 0.1, 0.0 | `item/brush` |
| 11 (189) | 9 | 0.9 | `item/brush_brushing_2` (the cycle repeats every 10 ticks from k = 1) |

A viewer that starts counting late (§2.3) has its own R from 200, so it follows the same table from its own k (0 or 1, §2.6). An item stack that is not the entity's `useItem` has `use_cycle` 0 and shows `item/brush`.

### 8.5 A viewer receives entity metadata entry 8 for a player (right-handed, a horn in each hand, both stacks delivered by Set Equipment)

| Byte | Meaning | Right arm (main) | Left arm (off) |
|---|---|---|---|
| 0 | idle | `ITEM`; model `goat_horn` | `ITEM`; model `goat_horn` |
| 1 | using, main hand | `TOOT_HORN`; model `tooting_goat_horn` (context `thirdperson_righthand`) | `ITEM`; model `goat_horn` (that stack is not the use item) |
| 2 | idle, last used off hand (bit 1 clear) | as 0 | as 0 |
| 3 | using, off hand | `ITEM`; model `goat_horn` | `TOOT_HORN`; model `tooting_goat_horn` (context `thirdperson_lefthand`) |
| 4 | spin attack only | as 0 (the flag is read elsewhere, 12 §6.13 step 5 for the local player) | as 0 |
| 5 | using main hand and spin attack | as 1 | as 1 |

For a left-handed player (main arm left, §5.2.1: entry 15 of the avatar = 0) the byte is read the same way, the main hand is the left arm: byte 1 raises the left arm and byte 3 the right arm; the contexts follow the arms (the left arm uses `thirdperson_lefthand`). The viewer learns "left-handed" only from entry 15; the flags byte does not change with the main arm. If a server never sends entry 15, the table above applies to every player regardless of the player's client option.

---

## Open questions

1. **`completeUsingItem` and `finishUsingItem` bodies.** `ItemStack.isSameItem` was read (it compares the item types only). `LivingEntity.completeUsingItem` was read only in outline (it releases when the used-hand stack is not the same object as `useItem`, else calls the stack's `finishUsingItem` and ends with `stopUsingItem`); the bodies of the item-specific `finishUsingItem` overrides were not read, and that the completion clears flag 1 for a horn is inferred from the `stopUsingItem` call.
2. **`ignoreSwapAnimation` components.** §2.5 says which components are ignored when the first-person displayed stack is replaced at once; which `DataComponentType`s carry the flag was not enumerated.
3. **Compass and clock edge cases.** §3.10 and §3.11: the non-wobbling `Wobbler` (`nonWobbler`) was not read (taken as holding the target value); the exact `hash` use of the seed is as read but the intent was not traced; whether `Mth.cos` in §6.2 is the sine-table function was read from the call only (10 §16.3 gives the table rule).
4. **Unused properties.** §3.13 gives only the read targets of `custom_model_data` (its index options), `component` (the predicate form), `bundle/fullness` and the `bundle/selected_item` model; these were not read further. (`damage`, `count`, `cooldown` and `selected` are read in full in §3.13.)
5. **`local_time` interval.** `UPDATE_INTERVAL_MS` was not read.
6. **Equipment before metadata.** §2.3 and §2.2: the vanilla server sends the equipment packet inside `startUsingItem` and the flag byte with the next tracker pass; the tracker's per-tick order against other packets was not traced. The viewer's start and clear tests were read (state based, run on every entry 8); what a viewer shows when the order is reversed, when a viewer starts tracking a player who is already using an item (pairing bundle order of 18 §9.1), and when a later entry 8 update retries the start, is **inferred** from those tests, not run.
7. **First-person brush `f`.** §6.2 takes the first float of `submitArmWithItem` as the partial tick (inferred from the shared call shape).
8. **Local use ahead of the server.** Whether a stale Set Entity Data (flag 1 clear) can arrive after the client's predicted start and cancel it, whether a late "flag 1 set" restarts a local use after a quick release (§2.4, inferred from the rule), and which local events other than the key release and the item change stop a predicted use (opening a screen, damage and so on) were not examined.
9. **Spear arm poses.** The `SPEAR` arm pose and first-person spear branch are in 34-1 §3.8; their use-state coupling to flag 1 was not re-read here.
10. **Library behaviour.** The composition order of `rotationXYZ` in the display transform (12 Open question 17) is still "(recalled, not verified)"; §4.3 gives the transforms as authored and as mirrored, not as matrices.
11. **Swap-animation scale.** `swap_animation_scale` (the spears' 1.95) is applied by 12 §6.2 (`swapScale`); its use for the in-use models was not traced.
12. **Residual of the main-arm trace (§5.2.1).** The chain from the client option to the viewer's `getMainArm` is read in full except two parts: the body of the tracker's `sendToTrackingPlayersAndSelf` (the self-directed delivery of dirty entity data is known from its name and from 18 §9.2) and the timing of the joining player's first dirty flush relative to its join packets (whether the local player's own entry 15 can arrive before its `LocalPlayer` exists was not examined). The `Mannequin` source of its main arm (21) was not traced.
13. **Fishing rod cast for viewers.** How `Player.fishing` (the bobber) is set on a viewer's copy of another player (the bobber's spawn data and owner) was not traced (§3.8).
14. **Ticks per loop iteration.** §2.6 reads the loop (packets, then min(10, N) ticks, then the frame) but not how `DeltaTracker.Timer.advanceGameTime` computes N; that N is 0 for an iteration that comes sooner than the next tick is due, and so how often a frame with k = 0 is rendered for a viewer, is inferred from the loop shape. The cases with a screen, an overlay or a paused game (no key handling or no entity tick) were read only as the conditions of §2.6.
