# 40-4 Menus and screens, part 4: enchanting table, loom, stonecutter, cartography table

| Item | Value |
|---|---|
| Covers | The four button-driven workstation menus and their client screens: `EnchantmentMenu` / `EnchantmentScreen` (item and lapis slots, three option buttons, ten data slots, clue names, the animated book, tooltips), `LoomMenu` / `LoomScreen` (banner, dye, pattern item, result, pattern list, selected-pattern data slot, pattern grid, scrollbar, banner preview), `StonecutterMenu` / `StonecutterScreen` (input, result, recipe list, selected-index data slot, 4 x 3 grid, scrollbar), `CartographyTableMenu` / `CartographyTableScreen` (map slot, additional slot, result, the scale, lock and copy modes, preview rendering, error icon). Identity, slot tables, data slots, buttons, quick-move, lifecycle, screen geometry, worked examples and validation, in the schema of 40-1 section 6 (M1 to M9). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`). |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of `assets/minecraft/lang/en_us.json` in the same jar, with no execution. Every value was read in this round unless marked "(inferred)" or "(recalled, not verified)"; both kinds are listed in Open questions. |
| Round | RS14, part 4 (design map `docs/design/README.md` GAP-19). Siblings: parts 1 to 3 and 5 to 9 of document 40 cover the shared model, the furnace family, other workstations, trading, mounts, creative and editor screens; this part covers none of them. |
| Related | 40-1 (menu model, click types, `moveItemStackTo`, quick-move template, data slots, synchronisation, generic container screen), 05a 0x13 (Container Set Data), 05c 0x11 (Container Button Click), 46 section 5.5 (menu type ids), 17 section 6.5 (enchanting algorithms: bookshelf power, cost, selection), 27 sections 3.2 and 4.3 (stonecutting recipes and the list sent at join), 25-5 section 8 (maps, `onCraftedPostProcess`, saved data), 31-3 section 3 (banner pattern layers and the `banner_pattern` tags), 12 section 5.6 (container screen frame), 24-7 (the four blocks open these menus). |

Class names appear in backticks only to say where a fact was read. They are provenance, not design.

Content that is data is not tabulated: textures, sprites, `lang` strings, the 62-word list excepted (it is code), the item and banner-pattern tags, the recipes, the enchantment definitions. The pixel art comes from the extracted resource pack (08, 22). The menus below are the same in the standard and the cobolcraft world types (design map rule R2: crafting screens are shared rules); only the item identities named (lapis lazuli, paper, map, glass pane, book, banners, dyes) follow the content set.

All coordinates are relative to (`leftPos`, `topPos`) of the screen image, in GUI pixels, unless said otherwise. All four screens use the default image size 176 x 166 (no constructor sets another size; each blits the region (0, 0, `imageWidth`, `imageHeight`) of a 256 x 256 background texture at (`leftPos`, `topPos`)), the default inventory label at (8, 72), and the player inventory appended with `addStandardInventorySlots(inventory, 8, 84)` (40-1 section 3.3).

---

## 1. Common rules used by all four menus

1. **Menu type ids** (46 section 5.5, re-read from the static initialiser order of `MenuType` here): `enchantment` 13, `loom` 18, `cartography_table` 23, `stonecutter` 24.
2. **Block binding.** Each menu is created with a `ContainerLevelAccess` for the block position on the server, and with the `NULL` access on the client. `stillValid(player)` is the block-bound helper of 40-1 section 3.8 with the block `enchanting_table`, `loom`, `cartography_table`, `stonecutter` respectively. Everything that the menus do through `access.execute(...)` (computing bookshelf power, applying an enchantment, playing the take sounds, assembling maps, returning items on close) therefore happens only on the server; the client menu runs the same `slotsChanged` and `clickMenuButton` code with no effect except for the parts that need no level (list filtering that depends only on data the client holds, and the return value of `clickMenuButton`).
3. **Titles** (data, `lang`): `container.enchant` "Enchant" (the enchanting table block entity's display name, 24-4), `container.loom` "Loom", `container.stonecutter` "Stonecutter", `container.cartography_table` "Cartography Table"; the screens draw them as the title label at (`titleLabelX`, `titleLabelY`) = (8, 6) minus the per-screen y shift of sections 3.10, 4.9 and 5.7 (enchanting 0, loom 2, stonecutter 1, cartography 2).
4. **Close.** `removed(player)` first runs the base behaviour (the carried stack goes back to the player), then, on the server, `clearContainer(player, container)` over the menu's input container (enchanting: both slots; loom: the three input slots; stonecutter: the input slot; cartography: the two input slots). The result slots are never returned: the stonecutter and the cartography table first remove their result item without notification (`removeItemNoUpdate`); the loom's output container is not cleared (its single stack is dropped with the menu).
5. **Take sounds** (loom, stonecutter, cartography): the result slot's `onTake` plays a UI sound only when `level.getGameTime()` differs from the menu's remembered `lastSoundTime` (initially 0), and then stores the current game time. So at most one sound per game tick, however many results are taken (shift-click repeats). Sound events: `UI_LOOM_TAKE_RESULT`, `UI_STONECUTTER_TAKE_RESULT`, `UI_CARTOGRAPHY_TABLE_TAKE_RESULT`; each is played at the block position with source `BLOCKS`, volume 1.0, pitch 1.0, excluded from no player (the player argument is null). The sound keys are data (`sounds.json`) and were not looked up (Open question 9).
6. **Data slot wire format.** A data slot is an int in the menu but Container Set Data (05a 0x13) carries property and value as signed 16-bit shorts (`writeShort` / `readShort`, read on `ClientboundContainerSetDataPacket`). The client applies `setData(property, value)` to its data slot with the sign-extended value. Every value in this part fits a short except the enchantment seed (section 2.3).

---

## 2. Enchanting table (`EnchantmentMenu`, `EnchantmentScreen`)

The algorithms (bookshelf power, `getEnchantmentCost`, `selectEnchantment`) are in 17 section 6.5. This section adds what that section does not state: the exact random-number sequence of the menu, the clue choice, the data slots, quick-move, and the screen.

### 2.1 M1. Identity

| Item | Value |
|---|---|
| Menu class | `EnchantmentMenu`, type `enchantment` (id 13) |
| Screen class | `EnchantmentScreen` |
| Server constructor | (container id, inventory, `ContainerLevelAccess` of the table position); the client constructor passes `NULL` |
| Own slots | 2; with the player inventory 38 |
| Menu random | `RandomSource.create()`, a `LegacyRandomSource` (the `java.util.Random` LCG of 10 section 3, re-seeded by `setSeed`; `nextInt(bound)`, `nextFloat` as in 10) |
| Backing container | `enchantSlots`, a `SimpleContainer(2)` whose `setChanged` additionally calls the menu's `slotsChanged(enchantSlots)` |

### 2.2 M2. Slots

| Menu slot | Container slot | x, y | Class and rules |
|---|---|---|---|
| 0 | `enchantSlots` 0 (the item to enchant) | (15, 47) | `Slot` with `getMaxStackSize()` = 1 (one item only, regardless of the item's own stack size); `mayPlace` is the default (any item) |
| 1 | `enchantSlots` 1 (lapis lazuli) | (35, 47) | `Slot` with `mayPlace(stack)` true only for the item `lapis_lazuli`; empty-slot icon sprite `container/slot/lapis_lazuli` (`getNoItemIcon`) |
| 2 to 28 | player inventory 9 to 35 | (8 + 18 col, 84 + 18 row) | standard |
| 29 to 37 | player hotbar 0 to 8 | (8 + 18 i, 142) | standard |

### 2.3 M3. Data slots (10, in this order)

| Index | Meaning | Range | Writer |
|---|---|---|---|
| 0, 1, 2 | `costs[0..2]`: the level cost shown for option 0, 1, 2 (0 = option unavailable) | 0 up to 30 | server `slotsChanged` |
| 3 | `enchantmentSeed` (a standalone data slot) | full int on the server | constructor (the player's `getEnchantmentSeed`), and after every enchant |
| 4, 5, 6 | `enchantClue[0..2]`: registry id of the clue enchantment for option i, or -1 | -1 up to the enchantment registry size | server `slotsChanged` |
| 7, 8, 9 | `levelClue[0..2]`: level of that clue, or -1 | -1 up to the enchantment's max level | server `slotsChanged` |

Indices 0 to 2, 4 to 6 and 7 to 9 are views of the three arrays (`DataSlot.shared`), the seed a private int. The constructor initialises `costs` to 0, `enchantClue` and `levelClue` to -1, and the seed to the player's current `getEnchantmentSeed()`.

**Seed on the wire.** Index 3 travels as a 16-bit short (section 1 rule 6). The server keeps the full 32-bit seed and uses it for every random decision; the client's copy is the low 16 bits sign-extended. The client uses its copy only to seed the galactic-alphabet names (section 2.7), so the names it shows derive from the truncated seed. The clue enchantment ids and levels, which the client reads from the data slots and looks up in its registry, are unaffected.

### 2.4 `slotsChanged` (server and client run it; only the server does the work)

Triggered by any change of `enchantSlots` (item or lapis placed, removed or changed).

1. Let `item` = slot 0's stack. If `item` is empty or not enchantable (`isEnchantable`: the stack has the `enchantable` component AND its `enchantments` component is present and empty; an absent `enchantments` component also makes it NOT enchantable, as does a non-empty one; ordinary items carry an empty default for that component, so they stay enchantable, and an already enchanted item is not), set `costs[i] = 0`, `enchantClue[i] = -1`, `levelClue[i] = -1` for i = 0..2, and stop. (No explicit broadcast in this branch; the data slot changes go out with the next `broadcastChanges`.)
2. Otherwise, on the server (`access.execute`): `B` = the number of valid bookshelf offsets (17 section 6.5; uncapped count here, the cap of 15 is inside the cost function).
3. `random.setSeed(enchantmentSeed)`. For i = 0, 1, 2 in order: `costs[i] = getEnchantmentCost(random, i, B, item)`, `enchantClue[i] = -1`, `levelClue[i] = -1`, and if `costs[i] < i + 1` then `costs[i] = 0`.
4. `getEnchantmentCost(random, i, B, item)` (read; 17 section 6.5 has the same formula): 0 when the item has no `enchantable` component (the component's value is not used in the cost); `b = min(B, 15)`; `base = nextInt(8) + 1 + (b >> 1) + nextInt(b + 1)` (the two draws in this order; `nextInt(1)` still consumes one `next(31)` when b = 0); i = 0: `max(base / 3, 1)`; i = 1: `base * 2 / 3 + 1`; i = 2: `max(base, b * 2)`; integer division. Each of the three options draws its own `base` from the one stream, in the order of i.
5. For i = 0, 1, 2 with `costs[i] > 0`: `list = getEnchantmentList(registryAccess, item, i, costs[i])` (2.5); if the list is not empty, pick `e = list[random.nextInt(list.size())]` (the same `random`, continuing from the state left by 2.5, not re-seeded); `enchantClue[i]` = the registry id of `e`'s enchantment in the enchantment registry's holder id map (the same numbering as 46 for the dynamic `enchantment` registry); `levelClue[i]` = `e`'s level. If the list is empty the clue stays -1.
6. `broadcastChanges()`.

So the displayed clue is one randomly chosen enchantment of the offered list, and the clue draw consumes the random after the selection; the cost draws of step 3 are finished before any clue is computed.

### 2.5 `getEnchantmentList(registryAccess, item, slotIndex, cost)`

1. `random.setSeed(enchantmentSeed + slotIndex)` (int addition, widened to long).
2. If the enchantment registry has no tag `in_enchanting_table`, return the empty list. Otherwise `list = selectEnchantment(random, item, cost, the tag's members in tag order)` (17 section 6.5 "Selection").
3. If the item is a `book` and `list.size() > 1`: remove one entry at index `random.nextInt(list.size())`.
4. Return `list`.

The same function runs when an option is chosen, from the same seed, so the applied enchantments are exactly those of the offer (the clue is just one of them).

### 2.6 M4. Button (`clickMenuButton(player, id)`), ids 0, 1, 2

| Step | Rule |
|---|---|
| Range | `id < 0` or `id >= 3`: log, return false |
| Inputs | `item` = slot 0, `lapis` = slot 1, `need = id + 1` |
| Lapis test | if `lapis` is empty or `lapis.count < need`, and the player does not have infinite materials: return false |
| Validity | `costs[id] > 0` and `item` not empty, and (`player.experienceLevel >= need` and `player.experienceLevel >= costs[id]`, or infinite materials); else return false |
| Effect (server only, via `access.execute`) | 1. `list = getEnchantmentList(item, id, costs[id])`. 2. If the list is not empty: `player.onEnchantmentPerformed(item, need)` = the player's level drops by **need** (not by the cost; the cost is only a threshold), clamped so a negative result becomes level 0, progress 0, total experience 0; then the player's enchantment seed becomes a fresh `nextInt()` of the player's own random. 3. If `item` is a `book`, replace slot 0 by `item.transmuteCopy(enchanted_book)` (same count and components, new item). 4. For each entry of the list in order: `stack.enchant(enchantment, level)`. 5. `lapis.consume(need, player)` (no shrink with infinite materials); if `lapis` is now empty, slot 1 is set to empty. 6. Award the stat `enchant_item`; on a server player fire the `enchanted_item` trigger with the stack and `need`. 7. `enchantSlots.setChanged()` (this re-runs `slotsChanged` with the OLD seed). 8. `enchantmentSeed.set(player.getEnchantmentSeed())` (the NEW seed). 9. `slotsChanged(enchantSlots)` again (costs and clues recomputed with the new seed). 10. Play `ENCHANTMENT_TABLE_USE` at the table position, source `BLOCKS`, volume 1.0, pitch `level.getRandom().nextFloat() * 0.1 + 0.9`, player argument null. |
| Return | true when the validity test passed, even if the list was empty (nothing happens in that case) |

On the client the menu's `clickMenuButton` runs only the tests (the access is `NULL`), and the screen then sends the button id to the server (2.9).

### 2.7 M5. Quick-move (`quickMoveStack(player, index)`)

Template of 40-1 section 3.6 with these source rules (ranges `[start, end)`):

| Source slot | Rule |
|---|---|
| 0 (item) | `moveItemStackTo(stack, 2, 38, reverse = true)`; failure returns empty |
| 1 (lapis) | `moveItemStackTo(stack, 2, 38, reverse = true)`; failure returns empty |
| 2 to 37 holding lapis lazuli | `moveItemStackTo(stack, 1, 2, reverse = true)` (into the lapis slot only); failure returns empty |
| 2 to 37 holding anything else | if slot 0 is empty and `slot0.mayPlace(stack)` (always true): put **one** copy (`copyWithCount(1)`) of the stack into slot 0 with `setByPlayer`, shrink the source by 1; otherwise return empty (also when slot 0 is occupied) |

After the move: if the source stack is empty set the slot to empty, else `setChanged()`; if the source count equals its pre-move count return empty; then `slot.onTake(player, stack)`; return the pre-move copy.

### 2.8 M6. Lifecycle

`stillValid`: block `enchanting_table`. `removed`: base (carried stack), then on the server `clearContainer(player, enchantSlots)` (both slots returned or dropped). `slotsChanged`: 2.4. No data slot is written on the client.

### 2.9 M7. Screen (`EnchantmentScreen`)

| Item | Value |
|---|---|
| Image | 176 x 166, background `textures/gui/container/enchanting_table.png` blitted at (0, 0, 176, 166) of a 256 x 256 sheet |
| Labels | defaults (8, 6) and (8, 72) |
| Book rectangle | x 14 to 52, y 14 to 45 (width 38, height 31), see 2.10 |
| Option rows | i = 0..2; row origin (60, 14 + 19 i); row size 108 x 19; sprite size 108 x 19 |
| Level icon | 16 x 16 at (61, 15 + 19 i): `container/enchanting_table/level_<i+1>` when enabled, `.../level_<i+1>_disabled` when disabled |
| Text origin | clue text x = 80 (row x + 20), y = 16 + 19 i; the cost number is right-aligned to x = 166, drawn at y = 23 + 19 i |
| Sprites (row backgrounds) | `container/enchanting_table/enchantment_slot` (normal), `.../enchantment_slot_highlighted` (pointer inside the row), `.../enchantment_slot_disabled` |
| Book texture | `textures/entity/enchantment/enchanting_table_book.png` |

**Per-row drawing** (`extractBackground`, after the book), with `gold` = lapis count in slot 1 (`getGoldCount`: 0 for an empty slot), `cost` = `costs[i]`, `level` = the local player's experience level, and `infinite` = the local player's infinite-materials flag. `EnchantmentNames.initSeed(menu seed)` first re-seeds the name generator with the client's (possibly truncated) seed, once per frame.

1. `cost == 0`: draw only the disabled row sprite; nothing else for this row (no name is generated, so the generator is not advanced for this row).
2. Otherwise let `s` = the decimal string of `cost`; `w = 86 - textWidth(s)`; generate the galactic name for width `w` (below), consuming the shared name generator; the row is **enabled** when (`gold >= i + 1` and `level >= cost`) or `infinite`, else **disabled**.
3. Disabled row: disabled row sprite; disabled level icon; the name drawn with word wrap at (80, 16 + 19 i), width `w`, no shadow, colour = opaque of `(0xFF685E4A and 0xFEFEFE) >> 1` = `#FF342F25`; then the cost number in colour `#FF407F10`.
4. Enabled row: if the pointer is inside the row (x in [60, 168), y in [14 + 19 i, 33 + 19 i), the same 108 x 19 rectangle as the click test) draw the highlighted sprite, request the pointing-hand cursor, name colour `#FFFFFF80`; otherwise the normal sprite and name colour `#FF685E4A`. Then the enabled level icon, the name at (80, 16 + 19 i), then the cost number in colour `#FF80FF20`.
5. The cost number is drawn with shadow at x = 166 - textWidth(s), y = 23 + 19 i.

**Galactic name** (`EnchantmentNames.getRandomName(font, width)`): the generator is a `LegacyRandomSource` re-seeded by `initSeed(seed)` (long) and used for the rows in order of i that have a nonzero cost, so a row's text depends on how many earlier rows consumed draws. For one name: `n = nextInt(2) + 3` (3 or 4 words); for each word `words[nextInt(62)]` (each word is picked by `Util.getRandom(array, random)`, read: one `nextInt(array length)` draw per word, so one `nextInt(62)`); the words are joined by a single space; the text is a literal string with the font `minecraft:alt` (the Standard Galactic Alphabet glyphs, data); it is cut to at most `width` pixels (`StringSplitter.headByWidth`, the head that fits). The 62 words, index 0 to 61: the, elder, scrolls, klaatu, berata, niktu, xyzzy, bless, curse, light, darkness, fire, air, earth, water, hot, dry, cold, wet, ignite, snuff, embiggen, twist, shorten, stretch, fiddle, destroy, imbue, galvanize, enchant, free, limited, range, of, towards, inside, sphere, cube, self, other, ball, mental, physical, grow, shrink, demon, elemental, spirit, animal, creature, beast, humanoid, undead, fresh, stale, phnglui, mglwnafh, cthulhu, rlyeh, wgahnagl, fhtagn, baguette.

**Tooltip** (`extractRenderState`, after the generic drawing): for i = 0, 1, 2 in order, the first row for which all hold: the pointer is inside the rectangle (60, 14 + 19 i, width 108, height **17**) relative to the image (note 17, not 19); `costs[i] > 0`; `levelClue[i] >= 0`; `enchantClue[i]` is a valid id in the client's enchantment registry (an empty lookup skips the row). Lines:
1. `container.enchant.clue` ("%s . . . ?") with the argument `Enchantment.getFullname(enchantment, levelClue[i])`, styled white. `getFullname` is the enchantment's description copied and coloured red when it is in the tag `curse`, else gray; then, unless the level is 1 and the enchantment's max level is 1, a space and the component `enchantment.level.<n>` (data: I, II, ... X).
2. Unless `infinite`: an empty line; then, if `level < costs[i]`: `container.enchant.level.requirement` ("Level Requirement: %s") with `costs[i]`, red, and nothing more; else the lapis line (`container.enchant.lapis.one` "1 Lapis Lazuli" when `i + 1 == 1`, else `container.enchant.lapis.many` with `i + 1`), gray when `gold >= i + 1` and red otherwise, followed by the level line (`container.enchant.level.one` when `i + 1 == 1`, else `container.enchant.level.many` with `i + 1`), gray.
The loop stops at the first hovered row.

**Click** (`mouseClicked`, any mouse button): for i = 0..2: with `rx = mouseX - (leftPos + 60)`, `ry = mouseY - (topPos + 14 + 19 i)`: if `0 <= rx < 108` and `0 <= ry < 19` and `menu.clickMenuButton(localPlayer, i)` returns true, send the button click (container id, i) through `handleInventoryButtonClick` (Container Button Click 05c 0x11) and consume the click. Otherwise the click goes to the generic handler (40-1 section 5.5).

**Tick** (`containerTick`): base tick, then sets the local player's `experienceDisplayStartTick` to its `tickCount` (keeps the experience bar showing), then `tickBook`.

### 2.10 The book (client animation and drawing)

State on the screen: `flip`, `oFlip`, `flipT`, `flipA`, `open`, `oOpen` (floats, all 0), `last` (an item stack, empty), `random` (`RandomSource.create()`, a separate generator from the names').

**`tickBook`** (once per client tick):
1. `item` = slot 0's stack. If it does not match `last` (`ItemStack.matches`: same item, count and components): `last = item`, then repeat `flipT += nextInt(4) - nextInt(4)` (two draws, the first minus the second, from the screen's `random`) while `flip` is within [`flipT` - 1, `flipT` + 1] (inclusive); the loop body runs at least once.
2. `oFlip = flip`, `oOpen = open`.
3. `anyCost` = whether any of `costs[0..2]` is nonzero. `open += 0.2` if so else `open -= 0.2`; `open` clamped to [0, 1].
4. `d = clamp((flipT - flip) * 0.4, -0.2, 0.2)`; `flipA += (d - flipA) * 0.9`; `flip += flipA`.

**Drawing** (`extractBook`): `pt` = the game-time partial tick (not paused); `o = lerp(pt, oOpen, open)`, `f = lerp(pt, oFlip, flip)`; the book is drawn as a picture-in-picture model in the rectangle with top-left (leftPos + 14, topPos + 14), width 38, height 31, model scale 40 (`book(model, texture, 40.0, o, f, x0, y0, x1, y1)`).

**Model pose** (`GuiBookModelRenderer.renderToTexture`, read): lighting preset "entity in UI"; rotate 180 degrees about Y, then 25 degrees about X; translate by `((1 - o) * 0.2, (1 - o) * 0.1, (1 - o) * 0.25)`; rotate about Y by `-(1 - o) * 90 - 90` degrees; rotate 180 degrees about X. Page flips: `p1 = clamp(frac(f + 0.25) * 1.6 - 0.3, 0, 1)`, `p2 = clamp(frac(f + 0.75) * 1.6 - 0.3, 0, 1)` (`frac` = the fractional part, x - floor(x)). The animation state is `BookModel$State.forAnimation(0, p1, p2, o)`: `openness = (sin(0 * 0.02) * 0.1 + 1.25) * o` = `1.25 * o`, `pageFlip1 = p1`, `pageFlip2 = p2`. The pixel mapping of the model into the rectangle is in the base class of the picture-in-picture renderers: the model origin is placed at the horizontal centre of the rectangle and 17 pixels (times the GUI scale) below its top for the book (`getTranslateY`), and the model scaled by (40 times the GUI scale, z negated) as in Open question 2 (which gives the projection, texture and blit; the Y-axis sign convention remains inferred).

**Model geometry and animation** (`BookModel`, a 64 x 32 texture): parts and cubes (offset x, y, z; size; texture origin), all in model units:

| Part | Cube origin (x, y, z) | Size (w, h, d) | Texture origin | Part offset / rotation |
|---|---|---|---|---|
| `left_lid` | (-6, -5, -0.005) | (6, 10, 0.005) | (0, 0) | offset (0, 0, -1) |
| `right_lid` | (0, -5, -0.005) | (6, 10, 0.005) | (16, 0) | offset (0, 0, 1) |
| `seam` | (-1, -5, 0) | (2, 10, 0.005) | (12, 0) | rotation about Y of pi/2 (1.5707964) |
| `left_pages` | (0, -4, -0.99) | (5, 8, 1) | (0, 10) | none |
| `right_pages` | (0, -4, -0.01) | (5, 8, 1) | (12, 10) | none |
| `flip_page1`, `flip_page2` | (0, -4, 0) | (5, 8, 0.005) | (24, 10) | none |

`setupAnim(openness o2, pageFlip1 p1, pageFlip2 p2)`: `left_lid.yRot = pi + o2`; `right_lid.yRot = -o2`; `left_pages.yRot = o2`; `right_pages.yRot = -o2`; `flip_page1.yRot = o2 - 2 * o2 * p1`; `flip_page2.yRot = o2 - 2 * o2 * p2`; and the x position of `left_pages`, `right_pages`, `flip_page1` and `flip_page2` is `sin(o2)`. (pi = 3.1415927.) The `seam` part is not animated.

---

## 3. Loom (`LoomMenu`, `LoomScreen`)

### 3.1 M1. Identity

| Item | Value |
|---|---|
| Menu class | `LoomMenu`, type `loom` (id 18) |
| Screen class | `LoomScreen` |
| Own slots | 4; with the player inventory 40 |
| Containers | `inputContainer` (`SimpleContainer(3)`: slots 0 banner, 1 dye, 2 pattern item) and `outputContainer` (`SimpleContainer(1)`). Both call the registered screen update listener from `setChanged`; the input container first calls `slotsChanged` (so on the client the screen's `containerChanged` runs after the menu update) |
| Constants | `PATTERN_NOT_SET` = -1; inventory ranges used by quick-move: main 4 to 31 (exclusive end), hotbar 31 to 40 |
| Banner layer cap | 6 layers (a banner with 6 or more layers cannot be given another) |

### 3.2 M2. Slots

| Menu slot | Container slot | x, y | Rules |
|---|---|---|---|
| 0 (banner) | `inputContainer` 0 | (13, 26) | `mayPlace`: the item is a `BannerItem` (any banner colour); empty-slot sprite `container/slot/banner` drawn by the screen |
| 1 (dye) | `inputContainer` 1 | (33, 26) | `mayPlace`: the stack is in the item tag `loom_dyes` AND has the `dye` component; sprite `container/slot/dye` |
| 2 (pattern) | `inputContainer` 2 | (23, 45) | `mayPlace`: in the item tag `loom_patterns` AND has the `provides_banner_patterns` component; sprite `container/slot/banner_pattern` |
| 3 (result) | `outputContainer` 0 | (143, 57) | `mayPlace` false; `onTake` below |
| 4 to 30 | player inventory 9 to 35 | (8 + 18 col, 84 + 18 row) | standard |
| 31 to 39 | player hotbar | (8 + 18 i, 142) | standard |

The dye colour of a dye stack is its `dye` component value (a `DyeColor`); the pattern list of a pattern item is its `provides_banner_patterns` component, a set of banner patterns (in the standard content: a tag reference `#minecraft:pattern_item/<name>`, each listing exactly one pattern, 31-3 section 3.4).

### 3.3 M3. Data slot

One data slot, index 0: `selectedBannerPatternIndex`, a standalone slot (default 0 in the field, but set to -1 by every clearing path), range -1 to (number of selectable patterns - 1). Written by the menu on both sides. -1 means no pattern selected.

### 3.4 Selectable patterns (`getSelectablePatterns(patternStack)`)

- Pattern slot empty: the members of the banner pattern tag `no_item_required`, in tag order (32 patterns in the standard content, in the order listed in 31-3 section 3.4); if the tag is missing, the empty list.
- Pattern slot not empty: the items of its `provides_banner_patterns` set in order, or the empty list if the stack has no such component.

The list is stored in `selectablePatterns`; the screen reads it through `getSelectablePatterns()`.

### 3.5 `slotsChanged` (both sides; the argument is ignored)

Let `banner`, `dye`, `pattern` = the three input stacks.

1. If `banner` or `dye` is empty: result slot := empty, `selectablePatterns` := empty list, selected index := -1; return (no broadcast).
2. Else: `oldIndex` = selected index; `wasValid` = `0 <= oldIndex < size(selectablePatterns)` (the OLD list); `oldList` = the old list; `selectablePatterns` := `getSelectablePatterns(pattern)`.
3. Choose `chosen` (a pattern or none):
   - new list has exactly one entry: selected index := 0, `chosen` = that entry (automatic selection);
   - else if `wasValid` is false: selected index := -1, `chosen` = none;
   - else: `old` = `oldList[oldIndex]`; `newIndex` = its index in the new list (first equal entry); if found: `chosen` = `old`, selected index := `newIndex`; else selected index := -1, `chosen` = none. (So the selection survives a list change when the same pattern is still offered, at its new position.)
4. If `chosen` is none: result slot := empty. Else: if `banner`'s `banner_patterns` component (default empty) has 6 or more layers: selected index := -1, result slot := empty; otherwise `setupResultSlot(chosen)`.
5. `broadcastChanges()`.

`setupResultSlot(pattern)`: `dyeColor` = `dye`'s `dye` component; if `banner` and `dye` are non-empty and `dyeColor` is not null: `result = banner.copyWithCount(1)` with `banner_patterns` replaced by (the old layers, then one new layer of `pattern` and `dyeColor`, appended last); otherwise `result` = empty. If `result` does not match the current result slot stack (`ItemStack.matches`), set the result slot to `result`.

### 3.6 M4. Button (`clickMenuButton(player, id)`)

`id` is the index into `selectablePatterns`. If `0 <= id < size`: selected index := `id`, `setupResultSlot(selectablePatterns[id])`, return true. Otherwise return false. (There is no "same as current" test and no layer-cap test here: with a 6-layer banner the screen shows no grid, so the click cannot occur; a forged click would still call `setupResultSlot`, which appends a seventh layer. Open question 7.)

### 3.7 Result slot `onTake(player, stack)`

1. Remove 1 item from the banner slot and 1 from the dye slot (the pattern item is not consumed).
2. If the banner slot or the dye slot is now empty, selected index := -1.
3. On the server: play `UI_LOOM_TAKE_RESULT` under the once-per-tick rule (section 1 rule 5).
4. Base `onTake`.
No `item_crafted` statistic and no `onCraftedBy` call happen for the loom result (neither is in the code).

### 3.8 M5. Quick-move

Indices: banner 0, dye 1, pattern 2, result 3, main 4 to 30, hotbar 31 to 39. The result slot's rule moves into [4, 40) with reverse true and then calls `onQuickCraft`; the other rules (checked in this order):

| Source | Rule |
|---|---|
| 3 (result) | `moveItemStackTo(stack, 4, 40, true)`; failure returns empty; then `slot.onQuickCraft(stack, copy)` |
| 0, 1 or 2 | `moveItemStackTo(stack, 4, 40, false)`; failure returns empty |
| inventory slot holding a `BannerItem` | `moveItemStackTo(stack, 0, 1, false)`; failure returns empty |
| inventory slot holding a dye item (`loom_dyes` tag and `dye` component) | `moveItemStackTo(stack, 1, 2, false)`; failure returns empty |
| inventory slot holding a pattern item (`loom_patterns` tag and `provides_banner_patterns`) | `moveItemStackTo(stack, 2, 3, false)`; failure returns empty |
| 4 to 30 (anything else) | `moveItemStackTo(stack, 31, 40, false)`; failure returns empty |
| 31 to 39 (anything else) | `moveItemStackTo(stack, 4, 31, false)`; failure returns empty |

Ending: stack empty then `setByPlayer(empty)`, else `setChanged()`; count unchanged returns empty; `slot.onTake(player, stack)`; return the pre-move copy. (A banner, dye or pattern item that is in the inventory is therefore routed to its input slot even when that slot is occupied: `moveItemStackTo` then merges or fails, and failure ends the move.)

### 3.9 M6. Lifecycle

`stillValid`: block `loom`. `removed`: base, then on the server `clearContainer(player, inputContainer)`. Screen update listener: replaced by the screen's `containerChanged` after the screen is created (the menu's default listener does nothing).

### 3.10 M7. Screen (`LoomScreen`)

| Item | Value |
|---|---|
| Image | 176 x 166, `textures/gui/container/loom.png`, blit (0, 0, 176, 166) of 256 x 256 |
| Title label y | 6 - 2 = 4 |
| Empty-slot icons | for each of banner, dye, pattern whose slot is empty: the sprite (16 x 16) at the slot's (x, y) |
| Sprites | `container/loom/scroller` and `scroller_disabled` (12 x 15), `container/loom/pattern` / `pattern_highlighted` / `pattern_selected` (14 x 14 each), `container/loom/error` (26 x 26) |
| Pattern grid | origin (60, 13), 4 columns x 4 rows, cell 14 x 14, `PATTERN_COLUMNS` = `PATTERN_ROWS` = 4 |
| Scroll track | x 119 to 131 (width 12), y 13 to 69 (full height 56); thumb 12 x 15; thumb y = 13 + `int(41 * scrollOffs)` |
| Banner preview | picture-in-picture rectangle top-left (141, 8), width 20, height 40 (so x1 = 161, y1 = 48), model scale 16 (read: `GuiBannerResultRenderState.scale()` returns the constant 16.0; `LoomScreen` does not pass a scale; pose and projection in Open question 2) |
| Error icon | at (resultSlot.x - 5, resultSlot.y - 5) = (138, 52), 26 x 26 |

**State** (`containerChanged`, run as the update listener on every change of either container, client side): `resultBannerPatterns` = the result slot's `banner_patterns` (default empty) or null if the result slot is empty; the stacks `bannerStack`, `dyeStack`, `patternStack` are the last-seen copies. `hasMaxPatterns` = the banner slot's `banner_patterns` has 6 or more layers; if so `resultBannerPatterns` := null. If any of the three input stacks differs from the remembered copy (`ItemStack.matches`): `displayPatterns` := (banner not empty and dye not empty and not `hasMaxPatterns` and the selectable list not empty). Then, always: if `startRow >= totalRowCount()` (= `ceil(listSize / 4)`) set `startRow` := 0 and `scrollOffs` := 0. Then the remembered copies are refreshed.

**Draw order** (`extractBackground`): the background blit; the three empty-slot icons; the scroll thumb (enabled sprite when `isScrollBarActive`, i.e. `displayPatterns` and the list has more than 16 entries, else the disabled sprite) and, when the pointer is over the track rectangle (x 119 to 131, y 13 to 69): resize-vertical cursor if active and dragging, pointing hand if active, not-allowed otherwise; then either the result banner preview (when `resultBannerPatterns` is not null and not `hasMaxPatterns`: the colour is the base colour of the result stack's banner item) or, when `hasMaxPatterns`, the error icon; then, when `displayPatterns`, the grid; then the lighting preset is reset to "items 3D".

**Grid cells**: for row r = 0..3 and column c = 0..3: `index = (startRow + r) * 4 + c`; stop the whole grid at the first `index >= listSize`. Cell origin `(60 + 14 c, 13 + 14 r)`. State: selected (`index == selectedIndex`): sprite `pattern_selected`; else hovered (pointer inside the 14 x 14 cell): sprite `pattern_highlighted`, a tooltip and the pointing-hand cursor; else `pattern`. The tooltip is the translatable component whose key is `<pattern.translationKey>.<dyeName>`, where `dyeName` is the colour name of the dye stack's `dye` component, defaulting to white (data: `block.minecraft.banner.<pattern>.<colour>`, for example "Fully White Field"). Then the pattern's small preview is drawn on the cell by `extractBannerOnButton`.

**Banner preview on a button** (`extractBannerOnButton`, atlas sprite of the pattern's banner texture `s` with texture coordinates U0, V0, U1, V1): translate by (4, 2) from the cell origin; `du = U1 - U0`, `dv = V1 - V0`; fill the 5 x 10 rectangle at (0, 0) with the texture-diffuse colour of dye `gray`; blit the sprite's atlas region into the same 5 x 10 rectangle with texture coordinates u from `U0` to `U0 + du * 21 / 64` and v from `V0 + dv / 64` to `V0 + dv / 64 + dv * 40 / 64` (the banner texture is a 64 x 64 sheet; 21 x 40 texels are shown). The asymmetric start (u at the left edge, v one texel down) is as read (Open question 8).

**Result banner preview**: the model is the standing-banner flag model (`ModelLayers.STANDING_BANNER_FLAG`); the picture-in-picture renderer (`GuiBannerResultRenderer`, lighting preset "items flat") translates by (0, 0.25, 0), draws the flag with the base banner sprite tinted white, then the base pattern layer coloured with the result banner's colour, then each of the result's layers in order (at most 16, drawn at increasing order values), using the banner pattern sprite of each layer's pattern and its dye colour. The model scale is 16 and the rectangle of the table above. The flag's own geometry belongs to the banner block entity renderer (outside this part).

**Mouse**:
- *Click* (`mouseClicked`), only when `displayPatterns`: for each grid cell as above (cells `index` any value, including beyond the list: the menu rejects an out-of-range id): if the pointer is inside the cell and `menu.clickMenuButton(localPlayer, index)` returns true, play `UI_LOOM_SELECT_PATTERN` (volume/pitch 1.0 as a UI sound), send the button click (container id, index), consume. Else, if the pointer is in x [119, 131), y [9, 65) (note: starts at 9, four pixels above the 13 of the drawn track), set `scrolling` := true. Otherwise the generic handler.
- *Drag* (`mouseDragged`): when `scrolling`, `displayPatterns` and `totalRows - 4 > 0`: `scrollOffs = clamp((mouseY - (topPos + 13) - 7.5) / (56 - 15), 0, 1)` (the denominator is 41.0); `startRow = max(int(scrollOffs * (totalRows - 4) + 0.5), 0)`; consumed. Otherwise the generic handler.
- *Release*: `scrolling` := false, then the generic handler.
- *Wheel* (`mouseScrolled`): the generic handler first (consumed if it returns true); else when `displayPatterns` and `totalRows - 4 > 0`: `scrollOffs = clamp(scrollOffs - scrollY / (totalRows - 4), 0, 1)` and `startRow = max(int(scrollOffs * (totalRows - 4) + 0.5), 0)` (`scrollY` is the vertical wheel amount); the call returns true whenever it reaches this point.
- *Outside click*: `hasClickedOutside` is the generic rule (40-1 section 5.5): outside the image rectangle.

---

## 4. Stonecutter (`StonecutterMenu`, `StonecutterScreen`)

Recipes: 27 section 3.2 (the stonecutting recipe) and 27 section 4.3 (the list the server sends at join; both sides filter it with `selectByInput`, in recipe order, so the list index means the same on both sides).

### 4.1 M1. Identity

| Item | Value |
|---|---|
| Menu class | `StonecutterMenu`, type `stonecutter` (id 24) |
| Screen class | `StonecutterScreen` |
| Own slots | 2; with the player inventory 38 |
| Containers | `container`: `SimpleContainer(1)` (input) whose `setChanged` calls `slotsChanged` and then the screen's listener; `resultContainer`: a plain `ResultContainer` |
| Constants | `INPUT_SLOT` 0, `RESULT_SLOT` 1; inventory ranges: main 2 to 29 (exclusive end), hotbar 29 to 38 |
| Menu state | `recipesForInput` (the filtered `SingleInputSet`, initially empty), `input` (a copy of the input stack as last seen, initially empty) |

### 4.2 M2. Slots

| Menu slot | Container slot | x, y | Rules |
|---|---|---|---|
| 0 (input) | `container` 0 | (20, 33) | plain `Slot` (any item may be placed; the list is empty for an item no recipe takes) |
| 1 (result) | `resultContainer` 1 (the slot is constructed with index 1 of the result container) | (143, 33) | `mayPlace` false; `onTake` below |
| 2 to 28 | player inventory 9 to 35 | (8 + 18 col, 84 + 18 row) | standard |
| 29 to 37 | player hotbar | (8 + 18 i, 142) | standard |

The menu overrides `canTakeItemForPickAll(stack, slot)`: false for the result slot, otherwise the default (so a double-click collect never drains the result slot).

### 4.3 M3. Data slot

One data slot: `selectedRecipeIndex`, a standalone slot, -1 = none, otherwise an index into `recipesForInput`. Written on both sides.

### 4.4 `slotsChanged` and the list

1. If the input slot's item **kind** (item type, not count or components) differs from the remembered `input`'s kind: `input` := a copy of the slot stack, `setupRecipeList(stack)`. Count-only changes do not reset the list or the selection.
2. `setupRecipeList(stack)`: selected index := -1; result slot := empty; `recipesForInput` := (stack not empty) ? the level's stonecutter set `selectByInput(stack)` : empty.
3. `setupResultSlot(index)` (called by buttons and after a take): if `recipesForInput` is not empty and `0 <= index < size`: take that entry's recipe holder, set the result container's "recipe used" to it, set the result slot to `recipe.assemble(SingleRecipeInput(input slot stack))` (27 section 3.2: the recipe's result); otherwise clear the result slot and the "recipe used" to none. Then `broadcastChanges()`.

`hasInputItem()` = the input slot has an item and `recipesForInput` is not empty. `getNumberOfVisibleRecipes()` = its size.

### 4.5 M4. Button (`clickMenuButton(player, id)`)

If `id == selectedRecipeIndex`: return false (no action, so the screen sends nothing and plays no sound). Otherwise, if `0 <= id < size`: selected index := `id` and `setupResultSlot(id)`; in all other cases nothing changes; **return true in both** (an out-of-range id returns true without effect).

### 4.6 Result slot `onTake(player, stack)`

1. `stack.onCraftedBy(player, stack.count)`: the `item_crafted` statistic by the taken count and the item's crafted hook (40-2 section 3.3).
2. `resultContainer.awardUsedRecipes(player, [the input slot stack])`: the used recipe is awarded without the limited-crafting check (27 section 4.6).
3. Remove 1 from the input slot (this triggers `slotsChanged`); if the removed stack was not empty, `setupResultSlot(selectedRecipeIndex)`.
4. On the server: `UI_STONECUTTER_TAKE_RESULT` under the once-per-tick rule.
5. Base `onTake`.
(Order effect, inferred: when the removal empties the input slot, `slotsChanged` has already reset the selection to -1, so step 3's re-evaluation clears the result; otherwise it reassembles from the remaining input.)

### 4.7 M5. Quick-move

| Source | Rule |
|---|---|
| 1 (result) | `stack.getItem().onCraftedBy(stack, player)`, then `moveItemStackTo(stack, 2, 38, true)`; failure returns empty; then `slot.onQuickCraft(stack, copy)` |
| 0 (input) | `moveItemStackTo(stack, 2, 38, false)`; failure returns empty |
| other, and the stonecutter set `acceptsInput(stack)` | `moveItemStackTo(stack, 0, 1, false)`; failure returns empty |
| 2 to 28 (not accepted) | `moveItemStackTo(stack, 29, 38, false)`; failure returns empty |
| 29 to 37 (not accepted) | `moveItemStackTo(stack, 2, 29, false)`; failure returns empty |

Ending: if the stack is empty, `setByPlayer(empty)`; **always** `setChanged()` (not an else); count unchanged returns empty; `slot.onTake(player, stack)`; if the source was the result slot (index 1), `player.drop(stack, false, Prediction.PREDICTED)` drops whatever remains of the moved stack in the world (an unmoved remainder). The third argument (read: the `Prediction` enum has the two values `PREDICTED` and `SERVER_ONLY`; the call here passes `PREDICTED`) only affects the arm swing that `drop` starts: `drop` returns nothing for an empty stack, otherwise starts a main-hand swing whose broadcast flag is true only when the argument is not `PREDICTED` (on a server level the swing packet goes to the tracking players and also to the dropping player itself when the flag is true, only to the tracking players otherwise; the reason is (inferred): with `PREDICTED` the dropping client has already played the swing itself). On a client level `drop` then returns with no item entity; on a server level it builds the item entity from the stack (the second argument, here false, is passed on to the entity creation; its meaning was not read) and adds it to the level; `broadcastChanges()`; return the pre-move copy.

### 4.8 M6. Lifecycle

`stillValid`: block `stonecutter`. `removed`: base, remove the result container's item without notification, then on the server `clearContainer(player, container)`.

### 4.9 M7. Screen (`StonecutterScreen`)

| Item | Value |
|---|---|
| Image | 176 x 166, `textures/gui/container/stonecutter.png`, blit (0, 0, 176, 166) of 256 x 256 |
| Title label y | 6 - 1 = 5 |
| Sprites | `container/stonecutter/scroller`, `scroller_disabled` (12 x 15), `recipe`, `recipe_highlighted`, `recipe_selected` (16 x 18 each) |
| Recipe grid | origin (52, 14), 4 columns x 3 rows (12 visible), cell 16 wide, 18 high |
| Scroll track | x 119 to 131, y 14 to 68 (full height 54); thumb 12 x 15; thumb y = 15 + `int(41 * scrollOffs)` |

**State**: `scrollOffs`, `scrolling`, `startIndex` (the index of the first visible recipe, always a multiple of 4), `displayRecipes`. The update listener `containerChanged` (run on every change of the input container, including count changes) sets `displayRecipes := menu.hasInputItem()`, `scrollOffs := 0`, `startIndex := 0`.

`isScrollBarActive` = `displayRecipes` and `numberOfVisibleRecipes > 12`. `getOffscreenRows()` = `(n + 4 - 1) / 4 - 3` (integer division; the number of grid rows beyond the three shown).

**Draw order**: the background; the scroll thumb (enabled or disabled sprite) with the cursor rule of section 3.10 for the rectangle x 119 to 131, y 15 to 69 (note: the hover test starts at the thumb's top y = 15); the recipe buttons then the recipe items (`extractButtons`, `extractRecipes`) for indices `startIndex` to `startIndex + 11` while `< n`; the tooltip is drawn in `extractTooltip`.

**Cell geometry** for visible position `k = index - startIndex`: column `k % 4`, row `k / 4`. Button sprite at `(52 + 16 (k % 4), 14 + 18 (k / 4) + 1)`, 16 x 18 (the row origin in `extractButtons` is `y = top + 14 + 18 r + 2`; the sprite is blitted at `y - 1`). State: selected when `index == selectedRecipeIndex` (`recipe_selected`), else hovered (`recipe_highlighted`) else `recipe`; the highlight test uses the 16 x 18 rectangle at `(52 + 16 (k % 4), 14 + 18 (k / 4) + 2)` (the same rectangle as the item and tooltip, NOT the sprite rectangle); the pointing-hand cursor test uses the sprite rectangle at `+ 1`. The click rectangle (`+ 0`, below) therefore differs from the highlight rectangle by 2 pixels. The item (the first stack of the recipe's option display, resolved with the level's slot-display context) is drawn at `(52 + 16 (k % 4), 14 + 18 (k / 4) + 2)`. The tooltip is the item tooltip of that stack, shown when the pointer is inside the 16 x 18 rectangle at `(52 + 16 (k % 4), 14 + 18 (k / 4) + 2)` (a third, slightly shifted rectangle).

**Mouse**:
- *Click*, only when `displayRecipes`: for each visible index `i` (position `k`): `rx = mouseX - (leftPos + 52 + 16 (k % 4))`, `ry = mouseY - (topPos + 14 + 18 (k / 4))`; if `0 <= rx < 16` and `0 <= ry < 18` and `menu.clickMenuButton(localPlayer, i)` is true: play `UI_STONECUTTER_SELECT_RECIPE` (UI sound, pitch 1.0), send the button click (container id, `i`), consume. Else, if the pointer is in x [119, 131), y [9, 63) (top starts at 9, as the loom), `scrolling` := true. Otherwise the generic handler.
- *Drag*: when `scrolling` and the bar is active: `scrollOffs = clamp((mouseY - (topPos + 14) - 7.5) / (54 - 15), 0, 1)` (denominator 39.0); `startIndex = int(scrollOffs * offscreenRows + 0.5) * 4`; consumed.
- *Release*: `scrolling` := false, then generic.
- *Wheel*: generic first; else when active: `scrollOffs = clamp(scrollOffs - scrollY / offscreenRows, 0, 1)`, `startIndex = int(scrollOffs * offscreenRows + 0.5) * 4`; returns true when it reaches this point.

---

## 5. Cartography table (`CartographyTableMenu`, `CartographyTableScreen`)

### 5.1 M1. Identity

| Item | Value |
|---|---|
| Menu class | `CartographyTableMenu`, type `cartography_table` (id 23) |
| Screen class | `CartographyTableScreen` |
| Own slots | 3; with the player inventory 39 |
| Containers | `container`: `SimpleContainer(2)` (slot 0 map, slot 1 additional) whose `setChanged` calls `slotsChanged` **before** the base `setChanged`; `resultContainer`: a `ResultContainer` whose `setChanged` also calls `slotsChanged` first |
| Constants | `MAP_SLOT` 0, `ADDITIONAL_SLOT` 1, `RESULT_SLOT` 2; ranges: main 3 to 30 (exclusive end), hotbar 30 to 39 |
| Data slots | none |

### 5.2 M2. Slots

| Menu slot | Container slot | x, y | Rules |
|---|---|---|---|
| 0 (map) | `container` 0 | (15, 15) | `mayPlace`: the stack has the `map_id` component (a filled map) |
| 1 (additional) | `container` 1 | (15, 52) | `mayPlace`: the item is `paper`, `map` (the empty map) or `glass_pane` |
| 2 (result) | `resultContainer` 2 | (145, 39) | `mayPlace` false; `onTake` and `safeClone` below |
| 3 to 29 | player inventory 9 to 35 | (8 + 18 col, 84 + 18 row) | standard |
| 30 to 38 | player hotbar | (8 + 18 i, 142) | standard |

The menu overrides `canTakeItemForPickAll`: false for the result slot.

### 5.3 `slotsChanged` and the result

Let `mapStack` = slot 0, `extra` = slot 1, `result` = the result container's item (index 2).

1. If `result` is not empty and (`mapStack` is empty or `extra` is empty): remove the result item without notification.
2. Else if `result` is empty and `mapStack` and `extra` are both not empty: `setupResultSlot(mapStack, extra, result)`. (If `result` is not empty and both inputs are non-empty nothing is recomputed: the result is only recomputed when it is empty, or after a take or an input change that empties the result first.)

`setupResultSlot` (server only through `access.execute`): `data` = the saved map data of `mapStack` (`MapItem.getSavedData`: the `map_id` looked up in the level; null when missing). If `data` is null: return with nothing changed (a stale result stays). Otherwise choose `newResult`:

| Condition (checked in this order) | `newResult` |
|---|---|
| `extra` is `paper`, and `mapStack` is in the item tag `extendable_maps`, and `data.locked` is false, and `data.scale < 4` | `mapStack.copyWithCount(1)` with component `map_post_processing` set to `SCALE`; then `broadcastChanges` |
| `extra` is `glass_pane` and `data.locked` is false | `mapStack.copyWithCount(1)` with `map_post_processing` set to `LOCK`; then `broadcastChanges` |
| `extra` is `map` (the empty map) | `mapStack.copyWithCount(2)` (the original map twice, the same `map_id`: a copy shares the saved data); then `broadcastChanges` |
| otherwise | remove the result item without notification, `broadcastChanges`, and return |

If `newResult` does not match the current result stack (`ItemStack.matches`): set it into result slot 2 and `broadcastChanges`.

So: paper extends (zoom out) a map whose item is in `extendable_maps` and is unlocked and below scale 4; a glass pane locks an unlocked map; an empty map clones any map (also a locked one); a paper or glass pane that fails its condition gives no result.

### 5.4 Result slot `onTake(player, stack)`

1. Remove 1 item from menu slot 0 and 1 from menu slot 1 (via the slots, so the containers notify).
2. `stack.getItem().onCraftedBy(stack, player)`: for a filled map the `onCraftedPostProcess` step of 25-5 section 8.1: the `map_post_processing` component is removed and, on a server level, a `LOCK` value creates a NEW saved map (new id from the level's counter, data `locked()`) and a `SCALE` value a new saved map (new id, data `scaled()`: scale + 1, the centre recomputed, pixels empty) whose id replaces the stack's `map_id`; the copy case (count 2) has no post-processing and keeps the id. The original map's data is untouched.
3. On the server: `UI_CARTOGRAPHY_TABLE_TAKE_RESULT` under the once-per-tick rule.
4. Base `onTake`.
`safeClone(player)` (creative clone of the result, 40-1 section 3.4) also runs `onCraftedBy`, so a cloned result gets its own post-processing.

### 5.5 M5. Quick-move

| Source | Rule |
|---|---|
| 2 (result) | `stack.getItem().onCraftedBy(stack, player)`, then `moveItemStackTo(stack, 3, 39, true)`; failure returns empty; then `slot.onQuickCraft(stack, copy)` |
| 0 or 1 | `moveItemStackTo(stack, 3, 39, false)`; failure returns empty |
| other, with a `map_id` component | `moveItemStackTo(stack, 0, 1, false)`; failure returns empty |
| other, `paper`, `map` or `glass_pane` | `moveItemStackTo(stack, 1, 2, false)`; failure returns empty |
| 3 to 29 (anything else) | `moveItemStackTo(stack, 30, 39, false)`; failure returns empty |
| 30 to 38 (anything else) | `moveItemStackTo(stack, 3, 30, false)`; failure returns empty |

Ending: if the stack is empty `setByPlayer(empty)`; always `setChanged()`; count unchanged returns empty; `slot.onTake(player, stack)`; `broadcastChanges()`; return the pre-move copy.

### 5.6 M6. Lifecycle

`stillValid`: block `cartography_table`. `removed`: base, remove the result container's item without notification, then on the server `clearContainer(player, container)`.

### 5.7 M7. Screen (`CartographyTableScreen`)

| Item | Value |
|---|---|
| Image | 176 x 166, `textures/gui/container/cartography_table.png`, blit (0, 0, 176, 166) of 256 x 256 |
| Title label y | 6 - 2 = 4 |
| Sprites | `container/cartography_table/map` (66 x 66), `scaled_map` (66 x 66), `duplicated_map` (50 x 66), `locked` (10 x 14), `error` (28 x 21) |
| Map drawing | `MapRenderer.extractRenderState` then the GUI `map` primitive, under a translate to the given point and a uniform scale; a map is 128 x 128 map pixels |

**Mode** (computed every frame from the slots; the client uses its own saved-data copy): `extra` = slot 1's stack; `isMap`, `isPaper`, `isGlass` = `extra` is `map`, `paper`, `glass_pane`. `mapStack` = slot 0, `mapId` = its `map_id` (may be null), `error` := false. If `mapId` is not null and its saved data `data` is found:
- if `data.locked`: `error := true`, and if `isPaper` or `isGlass` draw the error sprite at (35, 31);
- if `isPaper` and (`mapStack` is not in `extendable_maps` or `data.scale >= 4`): `error := true` and draw the error sprite at (35, 31) (so a locked map with paper draws the sprite twice at the same place, harmlessly).
If `mapId` is null or no data is found, no error is set and no map pixels are drawn (the frames below still are).

**Preview** (`extractResultingMap`), at the following positions; "map(x, y, s)" is the map drawn at (x, y) with scale s (a 128-pixel map shown at 128 s pixels):

| Case (first match) | Drawing |
|---|---|
| `isPaper` and not `error` | sprite `scaled_map` at (67, 13) size 66 x 66, then map(85, 31, 0.226) (about 29 pixels) |
| `isMap` | sprite `duplicated_map` at (83, 13) size 50 x 66; map(86, 16, 0.34) (about 43.5 pixels); next stratum (a new drawing layer, so the following sprite overlays the first map); sprite `duplicated_map` again at (67, 29) size 50 x 66; map(70, 32, 0.34). (This case ignores `error`: it is reached for an empty map even when the map is locked.) |
| `isGlass` | sprite `map` at (67, 13) size 66 x 66; map(71, 17, 0.45) (about 57.6 pixels); sprite `locked` at (118, 60) size 10 x 14 |
| otherwise (paper with error, or no additional item) | sprite `map` at (67, 13) size 66 x 66; map(71, 17, 0.45) |

A map is drawn only when both the id and the data exist. The preview ignores the result slot: it shows the map of slot 0 in the mode of slot 1. The screen has no widgets, no mouse handling of its own and no tick behaviour.

---

## 6. Packets and synchronisation used here

| Step | Packet or call | Source |
|---|---|---|
| Open | Open Screen 05a 0x3C with the menu type id (13, 18, 23, 24), container id and the title component | 40-1 section 4.5 |
| Button | Container Button Click 05c 0x11 (container id, button id) from `handleInventoryButtonClick`; the server runs `clickMenuButton` then `broadcastChanges` | 40-1 section 3.4 |
| Data | Container Set Data 05a 0x13 (container id, short property, short value) for each changed data slot; full resend with the Set Container Content on open | 40-1 section 4.3 |
| Slots | Set Container Slot / Content for the slots, including the result slots and the enchanting input | 40-1 section 4.3 |
| Stonecutter list | Update Recipes 05b 0x88 at join (not per open) | 27 section 4.3 |

The enchanting data slot ids are 0 to 2 costs, 3 seed, 4 to 6 clue enchantments, 7 to 9 clue levels; the loom and stonecutter use property 0.

---

## 7. Worked examples

**7.1 Enchanting costs.** Bookshelf count 15 (the maximum used): `b` = 15, `b >> 1` = 7, `base = nextInt(8) + 1 + 7 + nextInt(16)` ranges 8 to 30. Option 0 cost `max(base / 3, 1)` ranges 2 to 10 (base 8 gives 2; base 30 gives 10); option 1 cost `base * 2 / 3 + 1` ranges 6 (base 8: 16 / 3 = 5, +1) to 21 (base 30: 20 + 1); option 2 cost `max(base, 30)` is 30 for every `base` (so the top option always costs 30 with 15 shelves). With zero shelves: `b` = 0, `base = nextInt(8) + 1 + 0 + nextInt(1)` ranges 1 to 8; option 0: `max(base / 3, 1)` is 1 or 2 (base 1..2 gives 1; 6..8 gives 2); option 1: `base * 2 / 3 + 1` ranges 1 to 6, so it is zeroed when it is 1 (cost < 2); option 2: `max(base, 0)` = base, zeroed when below 3 (base 1 or 2).

**7.2 Enchant button validity.** Slot 1 holds 2 lapis, the player has level 5, `costs` = [2, 6, 30], not creative. Button 1: needs `id + 1` = 2 lapis (ok), `costs[1] = 6 > 0`, but level 5 is below 6: returns false, nothing changes. Button 0: needs 1 lapis (ok), `costs[0] = 2 > 0`, level 5 >= 1 and >= 2: true; the player's level becomes 4 (it pays `id + 1` = 1 level, not 2), the lapis stack becomes 1, the item is enchanted from the list for seed + 0, a new player seed is drawn, and the costs and clues are recomputed from it. With lapis 0 the same click returns false.

**7.3 Enchant seed on the wire.** Server seed `0x12345678` is sent as the short `0x5678` = 22136; the client's menu seed becomes 22136. Server seed `0x0001ABCD` is sent as `0xABCD`, read as the signed short -21555 (43981 - 65536); the client seeds its name generator with -21555. The costs, clue ids and levels are unaffected (they are sent separately).

**7.4 Enchant book transform.** A `book` (count 1) in slot 0, cost 30 offered for option 2 with a candidate list of three entries: `getEnchantmentList` removes one entry (index `nextInt(3)` from the same seeded stream) leaving two; choosing option 2 replaces the book by an `enchanted_book`, applies both enchantments, costs 3 lapis and 3 levels (not 30). The clue shown for option 2 is one of the two remaining entries, chosen by one more `nextInt(2)` draw in the clue computation.

**7.5 Loom pattern list and selection.** Pattern slot empty, a banner and a dye present: the list is the 32 `no_item_required` patterns in tag order, 8 rows; the scroll bar is active (32 > 16); `offscreen` = 8 - 4 = 4. Drag so that `scrollOffs` = 0.5: `startRow = int(0.5 * 4 + 0.5)` = 2; the visible cells show indices 8 to 23; the thumb y is `13 + int(41 * 0.5)` = 33. Clicking the cell at row 1, column 2 sends index `(2 + 1) * 4 + 2` = 14; the menu sets the selection to 14 and the result is the banner with that pattern in the dye colour appended as a new layer. Putting a pattern item whose set has exactly one pattern into the pattern slot replaces the list by that one pattern, selects index 0 automatically and fills the result at once. If the selection was pattern X at index 14 and a list change still contains X at index 3, the selection moves to 3. A banner that already has 6 layers: the result is cleared, the selection is -1, the screen shows the error icon at (138, 52) and no grid.

**7.6 Loom take.** Result taken with banner count 3, dye count 1: the banner drops to 2, the dye slot becomes empty, the selection becomes -1 (the dye slot is empty), the result slot is recomputed empty by `slotsChanged`; one sound if the game time differs from the last sound's.

**7.7 Stonecutter scroll.** The input item has 20 matching recipes: 5 rows, `getOffscreenRows` = (20 + 3) / 4 - 3 = 2; active (20 > 12). Drag giving `scrollOffs` 0.5: `startIndex = int(0.5 * 2 + 0.5) * 4` = 4, so indices 4 to 15 are shown; at `scrollOffs` 0.24: `int(0.48 + 0.5)` = 0, `startIndex` 0. With 13 recipes: (13 + 3) / 4 - 3 = 1 row beyond; active. With 12: not active (12 > 12 is false), no scrolling. Button positions for `startIndex` 0: index 5 is at k = 5, column 1, row 1: sprite at (68, 33), item at (68, 34), click rectangle origin (68, 32).

**7.8 Stonecutter clicks.** Selected index 3: a click on index 3 returns false (no sound, no packet). A click on index 5 sets 5 and assembles the result. Changing the input stack from 64 to 63 logs no reset in the menu (same item kind) but the screen's `containerChanged` still resets the scroll to the top.

**7.9 Cartography modes.** (a) A filled map at scale 1, unlocked, in `extendable_maps`, with paper: result = one copy with `map_post_processing` SCALE; preview `scaled_map` frame and the map at 0.226. Taking it consumes 1 map and 1 paper; the taken stack gets a new `map_id` (scale 2 data, empty pixels). (b) The same map with a glass pane: result locked copy; preview the `map` frame, the map at 0.45 and the lock icon at (118, 60). (c) The same map with an empty map: result two maps with the same id; preview two overlapped `duplicated_map` frames at (83, 13) and (67, 29). (d) A locked map with paper: no result; the screen draws the error sprite at (35, 31) and the plain `map` frame. (e) A scale-4 map with paper: no result, error sprite. (f) Paper in the additional slot and a map that is not in `extendable_maps`: no result, error.

---

## 8. Validation

1. Menu slot counts: enchanting 38 (2 + 36), loom 40 (4 + 36), stonecutter 38 (2 + 36), cartography table 39 (3 + 36). The player inventory begins at index 2, 4, 2, 3 respectively; the quick-move ranges of sections 2.7, 3.8, 4.7 and 5.5 match (main to hotbar split at 29, 31, 29, 30).
2. Menu type ids 13, 18, 23, 24 and block names `enchanting_table`, `loom`, `stonecutter`, `cartography_table`.
3. Data slot counts: enchanting 10, loom 1, stonecutter 1, cartography 0.
4. Enchanting: with an unenchantable or enchanted item every cost is 0 and every clue -1; with 0 shelves and a fresh seed, options whose raw cost is below `i + 1` are zeroed; option 2 with 15 shelves is always 30; the level deduction is `id + 1`, the lapis deduction is `id + 1`; after the click the seed in data slot 3 changes.
5. Enchanting wire: a seed of `0x00018000` arrives at the client as -32768; costs and clues round-trip exactly.
6. Loom: the selectable list for an empty pattern slot has 32 entries (the standard `no_item_required` tag); a banner or dye slot emptied forces selection -1, an empty result and an empty list; the result always has exactly one more layer than the banner, appended last, in the dye colour; no result when the banner has 6 layers.
7. Loom take consumes exactly one banner and one dye and never the pattern item.
8. Stonecutter: a change of the input item kind resets selection to -1 and clears the result; a count change does not; taking the result consumes one input item; the result stack is the recipe's result.
9. Stonecutter screen: scroll bar active exactly when more than 12 recipes; `startIndex` is always a multiple of 4; the maximum `startIndex` is `offscreenRows * 4`.
10. Cartography: paper needs an `extendable_maps` item, unlocked, scale below 4; the glass pane needs an unlocked map; the empty map copies any map including a locked one and yields two; copies keep the `map_id`, scale and lock results get a new `map_id` when taken (server).
11. Screen geometry: every rectangle of the tables above fits inside 176 x 166 (the loom banner preview 141 to 161 by 8 to 48; the cartography error sprite 35 to 63 by 31 to 52; the enchanting rows 60 to 168 by 14 to 71; the book 14 to 52 by 14 to 45).
12. Book animation: `open` stays within [0, 1], one frame of 0.2 steps; with a nonzero cost it reaches 1 in five ticks; `flipA` is bounded by the clamp of `d` to +-0.2 scaled by the 0.9 smoothing (it can only grow toward the clamped target).
13. Galactic names: each name has 3 or 4 words, each word index in [0, 61]; a row with cost 0 consumes no draws, so the same seed gives different text for row 1 depending on whether row 0 had a cost.

---

## Open questions

1. **Fonts and text metrics.** `Font.width`, `textWithWordWrap`, `StringSplitter.headByWidth` and the `minecraft:alt` font's glyphs are not specified here; the layout above assumes the glyph metrics of 12 and 14. The 62 words are specified; their rendering width is data of the font providers.
2. **Picture-in-picture projection (mostly closed).** Read in `PictureInPictureRenderer.prepare` for a rectangle (x0, y0, x1, y1) and GUI scale `g`: texture size W = (x1 - x0) * g by H = (y1 - y0) * g (RGBA8 colour and 32-bit float depth, recreated when the size changes; cleared to the GUI renderer's clear colour and depth 0); projection = orthographic with the size (W, H) and clip range -1000 to 1000 (`setupOrtho(-1000, 1000, W, H, true)`; the meaning of the final `true`, presumably a flipped Y axis, was not read); model pose = translate by (W / 2, `getTranslateY(H, g)`, 0), then scale by (S, S, -S) with S = g * the state's scale; the base `getTranslateY` returns H (origin at the bottom edge, banner), the book renderer returns 17 * g. The result is blitted back into the GUI rectangle with nearest filtering, premultiplied-alpha textured pipeline, texture coordinates u 0 to 1 and v 1 to 0 (vertical flip), white tint, under the state's scissor area. The banner renderer (`GuiBannerResultRenderer.renderToTexture`): lighting preset "items flat"; translate by (0, 0.25, 0); submit the flag model with the banner base sprite at full light (15728880) and no overlay, then the pattern layers via the banner pattern helper with the base colour and the result layers. Banner scale 16 is `GuiBannerResultRenderState.scale()`; book scale 40 is the constant passed by `EnchantmentScreen` (2.10). Still unread: the semantics of `Projection.setupOrtho`'s last flag and of the model's own vertex scale (so the exact orientation sign of the Y axis is (inferred) from the (S, S, -S) scale and the v flip, not verified), and `BannerRenderer.submitPatterns` (the layer-order rules are in 25-5 section 8 where present).
3. **Banner flag model and layers.** The geometry of `BannerFlagModel` and `BannerRenderer.submitPatternLayer` (UV rectangle, tint) belong to the banner renderer; this part cites the draw order only (base sprite white, base pattern layer, then up to 16 layers).
4. **Map rendering.** `MapRenderer.extractRenderState` and the GUI `map` primitive (decorations, the 128 x 128 colour table, the frame) were not read; section 5.7 gives only positions and scales.
5. **`SelectableRecipe.SingleInputSet`.** `selectByInput`, `acceptsInput`, the entries order and `optionDisplay` were not re-read here; the behaviour is taken from 27 sections 3.2 and 4.3.
6. **`selectEnchantment` was not re-read in this round.** Section 2.5 depends on the selection algorithm of 17 section 6.5 (and 44-1 RQ-1.2, which closed `WeightedRandom` and `selectEnchantment`); `getEnchantmentCost`, `isEnchantable`, `onEnchantmentPerformed`, `consume` and `getFullname` were read here.
7. **Forged or stale loom clicks.** `clickMenuButton` of the loom checks only the index range; a client that sends a valid index while the banner has 6 layers makes `setupResultSlot` append a seventh layer to the result. Whether `ItemStack.matches`, the layer codec or `BannerPatternLayers` limits it elsewhere was not traced. An implementation may add the 6-layer guard; the vanilla menu has none in this method (the screen prevents the click by not showing the grid).
8. **Banner button UV offset.** `extractBannerOnButton` starts u at the sprite's left edge and v one texel (1/64 of the sprite height) down, which looks asymmetric next to a 1 x 1 texel border; it is recorded as read. The banner pattern texture layout (data) was not inspected.
9. **Sound keys.** The sound events named in rule 5 and sections 2.6, 3.7, 3.10, 4.6, 4.9 and 5.4 (`UI_LOOM_TAKE_RESULT`, `UI_LOOM_SELECT_PATTERN`, `UI_STONECUTTER_TAKE_RESULT`, `UI_STONECUTTER_SELECT_RECIPE`, `UI_CARTOGRAPHY_TABLE_TAKE_RESULT`, `ENCHANTMENT_TABLE_USE`) are referenced by constant name; their registry keys and ids were not looked up (they are in the sound event registry, 46).
10. **`enchantment.level.<n>` recipe.** The key format is inferred from `lang/en_us.json` ("enchantment.level.1" = "I", "enchantment.level.10" = "X") and the single-argument concatenation; the dumped bootstrap shows one placeholder only.
11. **Menu order effects.** Section 4.6's remark on the order of `slotsChanged` and the re-evaluation, and section 5.3's "recomputed only when the result is empty" are read from the control flow; they were not exercised.
12. **Titles of the table menus.** The enchanting table's title is the block entity's display name (24-4); the exact custom-name behaviour (a named table) was not re-read here.
13. **Recalled, not verified.** No statement in this document rests on recall. Statements marked "(inferred)" are: the order effect of 4.6, the sign convention of the picture-in-picture Y axis (Open question 2), and the sprite sizes taken from the blit calls (not from the PNG files).
