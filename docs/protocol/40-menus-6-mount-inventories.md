# 40-6 Menus, part 6: mount inventories (horse, donkey, mule, llama, nautilus)

| Item | Value |
|---|---|
| Covers | The menus opened through the Mount Screen Open packet and without a `MenuType` registry entry: `AbstractMountInventoryMenu`, `HorseInventoryMenu`, `NautilusInventoryMenu`, and the screens `AbstractMountInventoryScreen`, `HorseInventoryScreen`, `NautilusInventoryScreen`. Slot layout, slot rules, quick-move, the open packet and its trigger, column counts, the entity preview rectangle, background and slot sprites, per-entity-type variants |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the jar's data files (`unzip -p`), with no execution. Every value was read in this round; anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions |
| Round | RS14 (design map GAP-19, mount part). Siblings in the 40 series hold the shared menu model (slot clicks, `moveItemStackTo`, container ids) and the other menus; this part does not repeat them |
| Related | 05a id 0x2A (packet table), 05c (container click, close container), 34-4 and 34-8 (equine and nautilus models), 19 and 44-4 (taming, saddling), 45-4 (horse NBT) |

Class names in backticks say where a fact was read. They are not the design.

Data is not tabulated here: the two entity-type tags and the item `equippable` components are data (resource and data pack), and only their semantics are given. Sprite and texture images are assets from the vanilla resource pack.

---

## 1. Overview

A mount inventory is a small menu with up to two equipment slots (saddle and body) and, for chested equines, a grid of chest slots, followed by the player's 27 + 9 slots. It is the only family of menus that is not a `MenuType`: the base constructor is called with a null menu type and the container id, and clients build the menu themselves when the Mount Screen Open packet arrives (section 3). There is no Open Screen packet and no registry id for it.

Two menu classes exist and are otherwise identical in structure: `HorseInventoryMenu` (for `AbstractHorse`: horse, donkey, mule, llama, trader llama, skeleton horse, zombie horse) and `NautilusInventoryMenu` (for `AbstractNautilus`: nautilus, zombie nautilus). Both extend `AbstractMountInventoryMenu`.

---

## 2. The menu

### 2.1 Constants and state

| Name | Value | Meaning |
|---|---|---|
| `SLOT_SADDLE` | 0 | Menu slot index of the saddle slot |
| `SLOT_BODY_ARMOR` | 1 | Menu slot index of the body armor slot |
| `SLOT_INVENTORY_START` | 2 | First chest slot index |
| `INVENTORY_ROWS` | 3 | Chest rows (also on the entities: `AbstractHorse.INVENTORY_ROWS`, `AbstractNautilus.INVENTORY_ROWS`, both 3) |
| `getInventorySize(columns)` | columns x 3 | Size of the chest container |

State: `mountContainer` (the chest container) and `mount` (the entity). The constructor calls the container's `startOpen` for the player; `removed` calls `stopOpen`.

`stillValid(player)` is true only when all four of these hold, tested in this order: (1) `hasInventoryChanged(mountContainer)` is FALSE; (2) the mount container is still valid for the player (the simple container default: true); (3) the mount is alive; (4) the player is within entity interaction range of the mount with a margin of 4.0 (the `isWithinEntityInteractionRange(entity, 4.0)` form). Otherwise the menu closes on the server.

`hasInventoryChanged` is overridden by both `AbstractHorse` and `AbstractNautilus`: it returns true when the entity's current `inventory` field is not the same object as the menu's container. Consequence: when the entity re-creates its container with `createInventory` (section 3.4) while a menu is open, the server menu becomes invalid and closes. The client menu has its own container object and does not run this check; `stillValid` is the server check.

### 2.2 Slot list (both menu classes)

Slots are added in this order, which fixes the menu slot indexes. "Item xy" is the position of the slot's 16x16 item area relative to the screen's top-left (`leftPos`, `topPos`).

| Menu index | Slot | Container and index | Item x, y | Count |
|---|---|---|---|---|
| 0 | Saddle `ArmorSlot` | single-item container of the entity's `SADDLE` equipment slot, index 0 | 8, 18 | 1 |
| 1 | Body armor `ArmorSlot` | single-item container of the entity's `BODY` equipment slot, index 0 | 8, 36 | 1 |
| 2 .. 1+3c | Chest slots (only when columns c > 0) | `mountContainer`, index = col + row x c | x = 80 + col x 18, y = 18 + row x 18, for row 0..2 (outer loop) and col 0..c-1 (inner loop) | 3c |
| next 27 | Player main inventory | player inventory index 9 + row x 9 + col | x = 8 + col x 18, y = 84 + row x 18 (row 0..2, col 0..8) | 27 |
| next 9 | Hotbar | player inventory index col | x = 8 + col x 18, y = 142 | 9 |

Total menu slots = 2 + 3c + 36. Let N = 2 + size(`mountContainer`) = 2 + 3c. Then the main inventory is menu indexes N .. N+26 and the hotbar N+27 .. N+35.

The saddle and body slots are always added, even when the entity cannot use them; the slot's `isActive` decides whether it is shown and clickable (section 2.4). The equipment container (`Mob.createEquipmentSlotContainer`) is a one-slot container: `getItem(0)` reads the mob's item in that equipment slot and `setItem` writes it with `setItemSlot`; when the stack written is non-empty the mob also gets a guaranteed drop for that slot and persistence required (it will not despawn). `setChanged` does nothing. Its own `stillValid` is true when the player is riding the mob or within 4.0 of it.

### 2.3 `ArmorSlot` rules (shared by saddle and body slots)

| Rule | Value |
|---|---|
| Max stack | 1 |
| `mayPlace(stack)` | `mount.isEquippableInSlot(stack, slot)`: the stack has an `equippable` component whose slot equals this slot AND `mount.canUseSlot(slot)` AND the component's allowed-entity set is absent or contains the mount's entity type. A stack without the component is rejected (the only exception, main hand, does not apply here) |
| `mayPickup(player)` | false when the slot is non-empty, the player is not in creative mode, and the stack has the enchantment effect component `prevent_armor_change` (index 29 in the effect component order, as in 28 section 4); otherwise true |
| `isActive` | `mount.canUseSlot(slot)`, further restricted per class (section 2.4) |
| `setByPlayer(new, old)` | calls `mount.onEquipItem(slot, old, new)` then stores. `onEquipItem` runs only on the server and not for spectators; it does nothing when old and new are the same item with the same components or on the entity's first tick; otherwise two independent steps follow. Step A (sound): only if the entity is not silent AND the new stack has an `equippable` component AND that component's slot equals this slot, play the equip sound (volume 1, pitch 1, seeded by the entity's `nextLong`). Step B (game event): independent of silence and of any slot match, if the entity's `doesEmitEquipEvent(slot)` is true, emit EQUIP when the new stack has an `equippable` component (of any slot), else UNEQUIP. UNEQUIP is therefore chosen by "the new stack has no `equippable` component", which includes the empty stack but is not the same as empty. A silent mount still emits the game event |
| Empty icon | the sprite named in the table of section 2.4 |

Reading trace (this round): the `onEquipItem` steps are from `LivingEntity.onEquipItem` and `doesEmitEquipEvent` (bytecode: client-side or spectator return, `isSameItemSameComponents` or `firstTick` return, the `isSilent` / `equippable` / slot-equality sound test with `playSeededSound` and `nextLong`, then the EQUIP / UNEQUIP game event); the equipment container is the anonymous class `Mob$1` returned by `Mob.createEquipmentSlotContainer` (`getTheItem` reads `getItemBySlot`, `setTheItem` calls `setItemSlot` and, for a non-empty stack, `setGuaranteedDrop` and `setPersistenceRequired`, `setChanged` is empty, `stillValid` tests the player's vehicle or `isWithinEntityInteractionRange(mob, 4.0)`); the sounds below are from `AbstractHorse.getEquipSound` and `AbstractNautilus.getEquipSound`. Volume 1 and pitch 1 are the two float constants 1.0 in that call.

Equip sounds: for horses, the saddle slot plays the horse saddle sound, other slots use the item's own equip sound (the `LivingEntity` base behaviour; `Animal` has no `getEquipSound` override, confirmed). For nautilus, the saddle slot plays the underwater saddle sound when the nautilus is under water, otherwise the nautilus saddle sound; other slots use the item's component sound.

### 2.4 Per-class slot activity and sprites

| Property | `HorseInventoryMenu` | `NautilusInventoryMenu` |
|---|---|---|
| Saddle slot `isActive` | `horse.canUseSlot(SADDLE)` AND the horse's type is in tag `can_equip_saddle` | `nautilus.canUseSlot(SADDLE)` |
| Body slot `isActive` | `horse.canUseSlot(BODY)` AND (type in tag `can_wear_horse_armor` OR the entity is a `Llama`, which covers trader llama) | `nautilus.canUseSlot(BODY)` |
| Saddle empty-slot icon | `container/slot/saddle` | `container/slot/saddle` |
| Body empty-slot icon | `container/slot/llama_armor` for a llama, else `container/slot/horse_armor` | `container/slot/nautilus_armor_inventory` |
| Chest slots | yes, when columns > 0 | never (the nautilus has 0 columns, section 4) |

`canUseSlot` per entity:

| Entity | SADDLE | BODY |
|---|---|---|
| `AbstractHorse` (horse, donkey, mule, skeleton horse, zombie horse) | alive AND not a baby AND tamed | the `LivingEntity` base default (true); `Animal` has no override |
| `Llama` (and `TraderLlama`, which declares no `canUseSlot` and inherits it) | true | true |
| `AbstractNautilus` | alive, not a baby, tamed | alive, not a baby, tamed |

Note the llama quirk: `Llama.canUseSlot` returns true for every slot, but its saddle slot is still hidden by the tag test above because `llama` and `trader_llama` are not in `can_equip_saddle` (section 5.1); a llama therefore shows only the body (carpet) slot.

### 2.5 What may be placed (via `equippable`)

The item decides, through its `equippable` data component (slot, allowed entities):

- Saddle: `Equippable.saddle()` uses slot SADDLE, allowed entities = tag `can_equip_saddle`, equip-on-interact, can be sheared (shear sound: saddle unequip). The same saddle item fits the horse family, nautilus and zombie nautilus, pig, strider, camel, camel husk.
- Llama carpet: `Equippable.llamaSwag(dye)` uses slot BODY, allowed entities = exactly `llama` and `trader_llama`, can be sheared (llama carpet unequip sound), asset = the carpet asset for that dye colour.
- Horse armor (`Item$Properties.horseArmor(material)`): `equippable` with slot BODY, allowed entities = tag `can_wear_horse_armor`, damage-on-hurt false, can be sheared (shear sound: horse armor unequip), equip sound horse armor, asset from the material, stack size 1.
- Nautilus armor (`Item$Properties.nautilusArmor(material)`): `equippable` with slot BODY, allowed entities = tag `can_wear_nautilus_armor`, damage-on-hurt false, equip-on-interact true, can be sheared (nautilus unequip sound), nautilus equip sound, asset from the material, stack size 1. This tag is read only here (and by the tag provider), not by the menu classes.

Consequences: a horse or zombie horse takes horse armor; a nautilus or zombie nautilus takes nautilus armor; a llama can take only carpets (items whose allowed set contains llama); donkey and mule have no active body slot, so nothing is placeable there.

### 2.6 Quick move (`quickMoveStack(player, index)`)

Let N = 2 + size(`mountContainer`). An empty or missing source slot returns the empty stack. Otherwise the working stack is the live stack in the slot, and the original (copied before any change) is the return value on success. Steps:

1. Source in the mount part (index < N): try `moveItemStackTo(stack, N, totalSlots, reverse = true)` (player inventory, filling from the end, hotbar first). If nothing moves, return empty.
2. Otherwise (source in the player part):
   1. If the body slot (1) accepts the stack by `mayPlace` and is currently empty: try `moveItemStackTo(stack, 1, 2, forward)`. If that fails, return empty. If it moved, go to the finish step. (If the body slot rejects the stack or is full, continue.)
   2. Else if the saddle slot (0) accepts the stack and is empty: try `moveItemStackTo(stack, 0, 1, forward)`; failure returns empty; success goes to the finish step.
   3. Else if the chest container size is not 0: `moveItemStackTo(stack, 2, N, forward)`; success goes to the finish step; failure continues.
   4. Hotbar shuffle: let mainEnd = N + 27, hotbarStart = mainEnd, hotbarEnd = mainEnd + 9. If the source is in the hotbar (hotbarStart..hotbarEnd-1): move to [N, mainEnd) forward; if the source is in the main inventory (N..mainEnd-1): move to [hotbarStart, hotbarEnd) forward. On failure return empty. On success these two branches return the empty stack immediately, without the finish step (the source slot is not marked changed and not cleared by this function; the stack was reduced in place). The third branch (any other source index) attempts the empty range [hotbarStart, mainEnd) and so always fails; it is unreachable for valid indexes.
3. Finish step (reached from steps 1 success, 2.1 to 2.3 success): if the source stack is now empty, set the slot to the empty stack (as a player change); otherwise call the slot's `setChanged`. Return the copy of the original stack.

Resulting behaviour: shift-click an armor-like item from the inventory fills the body slot, then the saddle slot, then the chest columns, and only then swaps between main and hotbar. A saddle shift-clicked on a horse that already wears one goes to the chest if one exists, else swaps main/hotbar. Items shift-clicked from the chest go to the player inventory, from the end backwards (hotbar slot 8 first). Items shift-clicked from the saddle or body slot go to the player inventory the same way (and are refused only if `mayPickup` is false, handled by the shared click engine, 40-1 section 4.4).

The chest pass in step 2.3 has no per-item filter: the chest slots are plain `Slot`s (mayPlace true, max stack the container's max, normally 64). Total behaviour of `moveItemStackTo` (stack merging first, then empty slots, the reverse flag, the max-stack rule) is in 40-1 section 3.5.

---

## 3. Opening a mount inventory

### 3.1 Trigger (server)

`openCustomInventoryScreen(player)` (the `HasCustomInventoryScreen` interface, implemented by `AbstractHorse` and `AbstractNautilus` identically in structure). It acts only on the logical server, and only when BOTH hold: (the mount has no passengers OR the player is a passenger of it) AND the mount is tamed. Then:

- `AbstractHorse`: `player.openHorseInventory(horse, horse.inventory)`.
- `AbstractNautilus`: `player.openNautilusInventory(nautilus, nautilus.inventory)`.

Callers read in this round (bytecode of `AbstractHorse.mobInteract` and `AbstractNautilus.mobInteract`; the branch order is: baby or vehicle goes to the superclass, tame plus secondary use opens the screen and returns SUCCESS, and only afterwards held-item handling such as feeding, taming and riding): (1) `mobInteract` of `AbstractHorse`: when the horse is a vehicle (has passengers) or a baby, the call goes to the `Animal` default; otherwise, if the horse is tamed and the player's secondary use is active (sneaking), it calls `openCustomInventoryScreen` and returns SUCCESS. (2) `mobInteract` of `AbstractNautilus`: a baby goes to the `TamableAnimal` default; otherwise, if tame and secondary use is active, it calls it and returns SUCCESS (before any held-item handling). (3) `ServerGamePacketListenerImpl`, in the handler that tests the player's vehicle for `HasCustomInventoryScreen` (read as the open-inventory player command, 05c; only the instanceof test and the call were read, the command-name match was not): it calls `openCustomInventoryScreen` on the vehicle. Taming and other interactions are in 19 and 44-4.

`ServerPlayer.openHorseInventory` and `openNautilusInventory` do the same three things, in this order:

1. If the player's current menu is not the inventory menu, close it (`closeContainer`).
2. Advance the container counter (`nextContainerCounter`; container ids wrap in 1..100 per 40-1 section 4.1) and send the Mount Screen Open packet with: container id = the new counter, inventory columns = `getInventoryColumns()` of the mount, entity id = the mount's id.
3. Create the server menu with the new container id, the player inventory, the mount's real chest container and the mount, and initialise it (`initMenu`, which sends the initial slot contents).

The packet is sent before the menu exists on the server; the menu uses the same columns value as the packet.

### 3.2 Packet (05a id 0x2A, clientbound)

| Field | Type | Meaning |
|---|---|---|
| Container id | container id codec of `FriendlyByteBuf` (a VarInt; 05a lists it as VarInt) | The window id used by later slot and click packets |
| Inventory columns | VarInt | Chest columns (0 when none) |
| Entity id | Int, 4 bytes big-endian (not a VarInt) | The mount entity |

### 3.3 Client handling

1. Look up the entity by the id in the client level. (The entity must already be tracked by the client.)
2. Create a client `SimpleContainer` of size columns x 3 (for the chest slots, holding no items until the server's slot-content packets arrive).
3. If the entity is an `AbstractHorse`: build `HorseInventoryMenu(containerId, player inventory, that container, horse, columns)`, set it as the local player's current menu, and open `HorseInventoryScreen`.
4. Else if it is an `AbstractNautilus`: the same with `NautilusInventoryMenu` and `NautilusInventoryScreen`.
5. Any other entity (or an unknown id): nothing happens (read: `handleMountScreenOpen` tests `AbstractHorse` first, then `AbstractNautilus`, and returns with no third branch); no menu is installed and no close packet is sent.

The saddle and body slots on the client read the client copy of the mount's equipment, which the server keeps in sync through the normal equipment packets; they do not travel in the menu's slot-content packet for container slots 0 and 1 beyond what the shared initial-content mechanism sends for the server menu's slots.

### 3.4 Menu close and persistence

`removed` calls `stopOpen` on the chest container. The chest contents live in the entity's `inventory` (a `SimpleContainer`); saving and loading (item list under the entity's NBT, with the equipment in the entity's equipment fields) is 45-4. The server's chest container is the entity's live container, so changes are immediate. When the columns of an entity change (a chest is added to a donkey or a llama's strength changes) the entity re-creates its container with `createInventory`, copying existing stacks index by index for min(old size, new size) slots (items beyond the new size are dropped: not copied).

---

## 4. Column counts

| Entity | `getInventoryColumns()` | Chest slots |
|---|---|---|
| `AbstractHorse` default (horse, skeleton horse, zombie horse) | 0 | 0 |
| `AbstractChestedHorse` (donkey, mule) | 5 if the chest flag is set, else 0 | 15 or 0 |
| `Llama`, `TraderLlama` | `getStrength()` if the chest flag is set, else 0 | 3 x strength |
| `AbstractNautilus` (nautilus, zombie nautilus) | 0 (method body read: constant 0) | 0 |

Llama strength is a synced integer, clamped by `setStrength` to 1..5 (`MAX_STRENGTH` 5). Random strength at spawn: one `nextFloat` draw; if it is below 0.04 the bound is 5, else 3; strength = 1 + `nextInt(bound)`. So 96 % of llamas get 1..3 and 4 % get 1..5 (uniform within the bound). Breeding strength and NBT (`Strength`) are in 45-4 and 44-4.

The chest flag is a synced boolean (`DATA_ID_CHEST`, default false) of `AbstractChestedHorse`, set when a player uses a chest item on a tamed donkey, mule or llama (mob docs).

The screen's chest area is wide enough for at most 5 columns (90 px, section 6.3).

---

## 5. Per-entity-type variants

### 5.1 Tag semantics (data files read)

| Tag (entity_type) | Members in the jar's data |
|---|---|
| `can_equip_saddle` | horse, skeleton_horse, zombie_horse, donkey, mule, pig, strider, camel, camel_husk, nautilus, zombie_nautilus |
| `can_wear_horse_armor` | horse, zombie_horse |
| `can_wear_nautilus_armor` | nautilus, zombie_nautilus; used only by `Item$Properties.nautilusArmor` (allowed entities of nautilus armor items) and the tag provider |
| `can_equip_harness` | happy_ghast (not a mount inventory) |

### 5.2 Resulting slot visibility

| Entity | Saddle slot shown | Body slot shown | Chest grid | Body slot icon |
|---|---|---|---|---|
| Horse (tamed adult) | yes | yes | no | horse armor |
| Skeleton horse (tamed adult) | yes | no (`BODY` usable, not in armor tag, not llama) | no | n/a |
| Zombie horse (tamed adult) | yes | yes | no | horse armor |
| Donkey, mule (tamed adult) | yes | no | if chest: 5 columns | n/a |
| Llama, trader llama | no (tag) | yes (llama carpet) | if chest: strength columns | llama armor |
| Nautilus, zombie nautilus (tamed adult) | yes | yes | no | nautilus armor |
| Baby or untamed (any horse type, nautilus) | no | horse family: body per the table above; nautilus: no | per chest flag | |

The menu can only be opened when the mount is tamed (section 3.1), so "untamed" applies only to a menu that was already open when the state changed.

---

## 6. The screens

### 6.1 Shared state and frame

`AbstractMountInventoryScreen` extends the container screen with: `inventoryColumns` (from the packet), `mount` (the entity), `xMouse` and `yMouse` (floats, set to the mouse position on every render).

- Image size is the container screen default: 176 x 166. `leftPos = (width - 176) / 2` and `topPos = (height - 166) / 2` (integer division), recomputed in `init`.
- Title: the mount's display name (its custom name or the entity type name), drawn at the default title label position (8, 6). Player inventory label: default position (8, imageHeight - 94) = (8, 72) for the 166-high image (the `AbstractContainerScreen` constructor sets `inventoryLabelX` = 8 and `inventoryLabelY` = `imageHeight` - 94).
- The screen title text and the standard container-screen behaviours (slot hover highlight, tooltips, click handling, close on the inventory or escape key) come from the container screen (40-1 section 5).

### 6.2 Drawing order (`extractBackground`)

1. The base container background (the dimmed world blur).
2. The background texture, blitted at (left, top) with source origin (0, 0), size 176 x 166 out of a 256 x 256 texture. Horse: `textures/gui/container/horse.png`. Nautilus: `textures/gui/container/nautilus.png`. (An asset of the resource pack, not tabulated.)
3. The chest area, when columns > 0 and the screen supplies a chest sprite (horse: yes; nautilus: no): the sprite `container/horse/chest_slots` (a 90 x 54 sprite, not stretched: the region from (0,0) of width columns x 18 and height 54) drawn at (left + 79, top + 17), size (columns x 18) x 54. The chest slot item areas (80, 18) are 1 px inside this area.
4. Saddle slot frame, when `shouldRenderSaddleSlot`: the slot sprite `container/slot` (18 x 18) at (left + 7, top + 35 - 18) = (left + 7, top + 17).
5. Body slot frame, when `shouldRenderArmorSlot`: the same sprite at (left + 7, top + 35).
6. The entity preview (section 6.4).

`shouldRenderSaddleSlot` and `shouldRenderArmorSlot` are the same conditions as the slots' `isActive` (section 2.4), evaluated on the client copy of the mount. The slot sprite for both classes is `container/slot`. After the background, the container screen draws the slots (`extractSlots` skips inactive slots entirely: no item, no icon). For an active slot whose item is empty, `extractSlot` blits the slot's `getNoItemIcon` sprite (section 2.4 for `ArmorSlot`) as a 16 x 16 sprite at the slot's item position (x, y).

### 6.3 Pixel table (relative to left, top)

| Element | x | y | w | h |
|---|---|---|---|---|
| Background | 0 | 0 | 176 | 166 |
| Saddle slot frame | 7 | 17 | 18 | 18 |
| Body slot frame | 7 | 35 | 18 | 18 |
| Saddle item | 8 | 18 | 16 | 16 |
| Body item | 8 | 36 | 16 | 16 |
| Chest area sprite | 79 | 17 | 18 x columns | 54 |
| Chest slot (row r, col c) item | 80 + 18c | 18 + 18r | 16 | 16 |
| Entity preview box | 26 | 18 | 52 (to x = 78) | 52 (to y = 70) |
| Player main inventory | 8 | 84 | 162 | 54 |
| Hotbar | 8 | 142 | 162 | 18 |

### 6.4 Entity preview

The preview calls the shared inventory entity drawing function with the rectangle x0 = left + 26, y0 = top + 18, x1 = left + 78, y1 = top + 70, scale 17, y offset 0.25, the mouse position (`xMouse`, `yMouse`) and the mount.

The shared function (`InventoryScreen.extractEntityInInventoryFollowsMouse`; read this round from its bytecode, every constant 40.0, 20.0, 180, 0.017453292, 0.25 and the scale 17 confirmed), as it applies here:

1. Centre: cx = (x0 + x1) / 2 and cy = (y0 + y1) / 2 as floats; for this rectangle cx = left + 52 and cy = top + 44.
2. Look angles: ax = atan((cx - mouseX) / 40) and ay = atan((cy - mouseY) / 40), radians.
3. Two rotations are built. The X-only rotation Qx is a rotation about X of (ay x 20) degrees (converted with 0.017453292 rad per degree). The combined rotation Qc is a half turn about Z (pi, upright flip for the GUI projection) multiplied by Qx, so Qc includes the X rotation. Qx is kept unchanged alongside Qc.
4. The entity's render state is extracted. For a living entity: body rotation = 180 + ax x 20 (degrees), head yaw = ax x 20, head pitch = -ay x 20 (0 when the pose is fall-flying); the bounding-box width and height are divided by the state's scale and the scale is then set to 1 (so baby and scaled entities are normalised to their own box).
5. Translation vector (0, boundingBoxHeight / 2 + yOffset (0.25), 0).
6. The draw call receives the state, scale 17 (pixels per block), the translation, the combined rotation Qc, the separate X-only rotation Qx (a second quaternion argument; it is not a head-pose rotation, the head pose is carried only by the render-state fields bodyRot, yRot and xRot set in step 4), and the clipped rectangle (x0, y0, x1, y1) for scissoring.

Worked example: screen 854 x 480: left = (854 - 176) / 2 = 339, top = (480 - 166) / 2 = 157. Preview rectangle = (365, 175)-(417, 227); centre (391, 201). Mouse at (431, 201): ax = atan((391 - 431) / 40) = atan(-1) = -0.7854 rad, head yaw = -15.7 degrees; ay = atan(0) = 0, pitch 0. Saddle frame at (346, 174); body frame at (346, 192); chest area for 3 columns at (418, 174), 54 x 54.

---

## 7. Worked examples

### 7.1 Slot indexes

| Mount | Chest | N | Saddle | Body | Chest slots | Main | Hotbar | Total |
|---|---|---|---|---|---|---|---|---|
| Tamed horse | none | 2 | 0 | 1 | none | 2..28 | 29..37 | 38 |
| Donkey with chest | 5 columns | 17 | 0 | 1 | 2..16 | 17..43 | 44..52 | 53 |
| Llama strength 3 with chest | 3 columns | 11 | 0 | 1 | 2..10 | 11..37 | 38..46 | 47 |
| Llama strength 5 with chest | 5 columns | 17 | 0 | 1 | 2..16 | 17..43 | 44..52 | 53 |
| Tamed nautilus | none | 2 | 0 | 1 | none | 2..28 | 29..37 | 38 |

Chest slot positions for a llama, strength 3 (columns 0..2): menu index 2 + col + row x 3 at x = 80 + 18col, y = 18 + 18row, so index 2 at (80, 18), index 4 at (116, 18), index 5 at (80, 36), index 10 at (116, 54).

### 7.2 Quick move

1. Horse (N = 2), carries a saddle in main slot index 10, saddle slot empty: body slot `mayPlace` rejects a saddle (slot is SADDLE) so step 2.1 is skipped; step 2.2 accepts: the saddle moves to slot 0 and the source slot is cleared. Result: the original saddle stack returned.
2. Same horse, saddle slot already filled: 2.1 no, 2.2 no (slot not empty), 2.3 skipped (size 0), hotbar shuffle: index 10 is in the main range, so the saddle moves to the first free hotbar slot. Returns empty, the source slot is left reduced in place.
3. Llama strength 3 with chest, carpet in hotbar slot (index 38 + 4 = 42), body slot empty and a carpet allowed: moves to slot 1, returns the copy.
4. Llama, ordinary stack of 64 cobblestone in main slot 12 with a half empty chest: 2.1 and 2.2 reject, 2.3 merges into existing stacks and then empty chest slots from slot 2 upward.
5. Donkey (N = 17), item in chest slot 2: step 1 moves it to [17, 53) in reverse, so it lands in the last free spot, hotbar first.

### 7.3 Open conditions

- Tamed adult horse, player not riding, nothing riding it: opens. Same horse with another player riding: does not open for the first player. Same horse untamed: does not open.
- Server sends for a llama with chest and strength 4: container id 1 (first container), columns 4, entity id of the llama. The client creates a 12-slot container; the menu has 2 + 12 + 36 = 50 slots.

---

## 8. Validation

An implementation is conformant when:

1. Slot indexes, positions and counts match the tables of 2.2, 6.3 and 7.1 for every row of 5.2.
2. The packet is exactly VarInt id, VarInt columns, 4-byte Int entity id (build a packet fixture: container id 1, columns 3, entity id 0x00000102 gives bytes 01 03 00 00 01 02).
3. Quick-move reproduces 7.2 cases 1 to 5 and the return-value rule (original copy on the finish path, empty on the shuffle path).
4. A llama never shows a saddle slot, a donkey never shows a body slot, a nautilus never shows chest slots; a skeleton horse shows only the saddle slot.
5. Llama strength is always 1..5 and the chest column count equals strength; donkey and mule use 5.
6. Opening is refused when untamed, or when the mount has passengers and the player is not one of them.
7. The preview rectangle, scale and offset equal section 6.4; the chest sprite is drawn only with columns > 0 and only for the horse screen.
8. Armor slots refuse removal of an item with the `prevent_armor_change` effect unless the player is in creative mode.

---

## Open questions

1. (Resolved in this revision: sections 2.5 and 5.1 give the horse armor and nautilus armor `equippable` rules.) Not read: whether any item other than those built by `horseArmor`, `nautilusArmor`, `Equippable.saddle()` and `Equippable.llamaSwag(dye)` carries a BODY or SADDLE `equippable` accepted by a mount (searched: the two `Item$Properties` builders only).
2. The command-name match (which player command value reaches the `HasCustomInventoryScreen` call in `ServerGamePacketListenerImpl`) was not decoded; 05c is the authority for the action name.
3. (Resolved: `can_wear_nautilus_armor` is used only by `Item$Properties.nautilusArmor` and the tag provider.) Not traced: other users of the tag in data files outside `tags/entity_type`.
4. Server side is answered by 2.1 (`hasInventoryChanged` closes the server menu when the entity's container object is replaced). Still not traced: whether the server then sends a close packet to the client and what the client shows meanwhile; the client container size is fixed at open time.
5. The pixel appearance of `container/horse/chest_slots`, `container/slot/*` and the two background textures is asset data and was not read.
6. (Resolved: section 6.2 gives the empty-icon draw rule.)
7. The creative-mode and spectator behaviour of `mayPickup` beyond the `prevent_armor_change` check, and the container-click packet's handling of `isActive` false slots, belong to the shared click engine (40-1 section 4.4); not verified here.
8. Scope: this part covers only the mount inventories; the other menus listed in the 40 series scope belong to parts 1 to 5 and a whole-series reviewer must confirm their coverage.
