# 40. Menus and screens, continuation x1: the block editor screens

| Item | Value |
|---|---|
| Covers | CONTINUATION part (file name `x1-continuation`) of the round RS14 document set 40 (Menus and screens). This part holds ONLY the block editor screens; menu types, slot layouts, quick-move rules, data slots and container screens are in 40-1 to 40-8 (40-1 model and containers, 40-2 furnaces, brewing, crafter, 40-3 anvil, grindstone, smithing, 40-4 enchanting, loom, stonecutter, cartography, 40-5 merchant, beacon, lectern, 40-6 mount inventories, 40-7 creative inventory, 40-8 book and sign editors). Round RS14, the screens that 40-1 section 2.3 only lists in one row and that no other part specifies: `AbstractCommandBlockEditScreen` with `CommandBlockEditScreen` and `MinecartCommandBlockEditScreen`, `StructureBlockEditScreen`, `JigsawBlockEditScreen`, `TestBlockEditScreen` and `TestInstanceBlockEditScreen`. For each: how it is opened, every widget with its pixel position and size, the visibility and enable rules, the text drawn and where, the key handling, the exact packet sent and when, and what the screen does with the answers that come back. Also the generic widgets these screens need and no earlier part specifies: `CycleButton` (with its `Builder`), `AbstractSliderButton` (as used by the jigsaw screen), the parts of `EditBox` the screens rely on, `FittingMultiLineTextWidget`, and the `CommandSuggestions` construction parameters. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`; protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), `unzip -p` for `assets/minecraft/lang/en_us.json`, with no execution. |
| Evidence rule | Every number, key, ordering and rule below was read from the artifact in this round. "(inferred)" marks a deduction from the shape of read code. "(recalled, not verified)" marks a statement not read; each is repeated in Open questions. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001; design README Parts 0, 1, 4; GAP-19). No data rows are tabulated: language strings and sprites come from the resource pack (14); only the language KEYS used by the screens are named, with the `en_us.json` text beside them as a convenience, never as the specification. Code-defined behaviour (layout, widget rules, modes, packets) is complete here. |
| Siblings (not repeated) | Server side and entity state of the five blocks and the minecart, and the "can use game master blocks" rule: 31-6 (command block 2 to 5, structure block 6, jigsaw 8, test block 9, test instance 10, operator rule 11.1). Wire layouts: 05c ids 0x1B, 0x37, 0x38, 0x3B, 0x3C, 0x3D, 0x41 and 05b id 0x81. The minecart's synchronized data and `interact`: 44-8. Screen model, escape and tab handling, background and button sprites: 40-1 section 5.7 and 12 sections 5.6, 5.9. Key-event predicates (`isConfirmation`, `isSelection`, `isEscape`) and the title text overload: 40-8 section 0 and 6. Identifier grammar: 23 section 1. Command suggestion display rules and colours: 15 sections 3.6 and 14.5. Text width and shadow: 12 section 5.10. |

Conventions: coordinates are GUI-scaled pixels (12 section 5.1). `W` and `H` are the scaled screen width and height; `cx` = `W / 2` with Java integer division (truncation). All screens here are non-container screens: no menu, no slots. "Label" means a `GuiGraphicsExtractor.text` call (shadow on, 40-8 section 6.3 step 2 and its Open question 11) in colour `0xFFA0A0A0` (the int -6250336) unless a colour is named. "Title" means the 5-argument `centeredText` (the text's left edge is `x - width / 2`, shadow on) in colour -1 (`0xFFFFFFFF`). All six screens return true from `isInGameUi`, so they draw the dimmed in-game gradient background (12 section 5.6) and none overrides `isPauseScreen` in the classes read (the game keeps running; not traced further, Open question 1). "Button" is a standard 20-pixel-high `Button` (12 section 5.9) unless a width and height are given. "Done" is the widget text key `gui.done`, "Cancel" is `gui.cancel`.

## 1. Overview

| Screen | Block or entity | Opened by | Sends | When |
|---|---|---|---|---|
| `CommandBlockEditScreen` | command, chain and repeating command block | server sends Block Entity Data (31-6 5.2) and the client-side use call opens the screen | Set Command Block, 05c 0x37 | Done button or Enter |
| `MinecartCommandBlockEditScreen` | `command_block_minecart` | client-side `interact` (section 2) | Set Command Minecart, 05c 0x38 | Done button or Enter |
| `StructureBlockEditScreen` | `structure_block` | client-side `usedBy` (section 2) | Set Structure Block, 05c 0x3C | Done, SAVE, LOAD, DETECT |
| `JigsawBlockEditScreen` | `jigsaw` | client-side `useWithoutItem` | Set Jigsaw Block, 05c 0x3B; then Jigsaw Generate, 05c 0x1B | Done or Generate button |
| `TestBlockEditScreen` | `test_block` | client-side `useWithoutItem` | Set Test Block, 05c 0x3D | Done button |
| `TestInstanceBlockEditScreen` | `test_instance_block` | client-side `useWithoutItem` | Test Instance Block Action, 05c 0x41 (INIT, QUERY, SET, RESET, SAVE, EXPORT, RUN) | several, section 8 |

Common facts, all read: every screen holds a reference to the CLIENT's own copy of the block entity or entity (`Screen` field `autoCommandBlock`, `structure`, `jigsawEntity`, `blockEntity`, `minecart`; the test block screen copies position, mode and message once in its constructor). The server never sends an "open screen" packet for any of them. A screen cannot be opened by any packet: it is a side effect of the client running the block's use method (section 2).

## 2. How each screen is opened (read: `LocalPlayer.open*`, the block classes)

`Player` has six overridable methods `openCommandBlock`, `openMinecartCommandBlock`, `openStructureBlock`, `openTestBlock`, `openTestInstanceBlock` and `openJigsawBlock`; the base implementations do nothing and only `LocalPlayer` overrides them (each does `Gui.setScreen(new ...Screen(argument))`). The server-side class `ServerPlayer` overrides only `openCommandBlock`.

| Trigger | Condition | Client | Server |
|---|---|---|---|
| `CommandBlock.useWithoutItem` | the block entity exists and `canUseGameMasterBlocks` | `LocalPlayer.openCommandBlock` opens `CommandBlockEditScreen` | `ServerPlayer.openCommandBlock` sends one Block Entity Data packet (31-6 5.2); result `SUCCESS` |
| `MinecartCommandBlock.interact` | `canUseGameMasterBlocks` else `PASS` | when the level is client side: `openMinecartCommandBlock`; result `SUCCESS` | nothing is sent; the command text and last output are in the entity's synchronized data (44-8) |
| `StructureBlockEntity.usedBy` | game master rights; on a client level | `openStructureBlock` | nothing sent |
| `JigsawBlock.useWithoutItem`, `TestBlock.useWithoutItem`, `TestInstanceBlock.useWithoutItem` | the entity exists and game master rights (31-6 8.2, 9.2, 10.4) | `openJigsawBlock`, `openTestBlock`, `openTestInstanceBlock` on a client level | nothing sent |

Consequences for a server implementer:

1. The screens show the client's last known block entity data. Data comes from the chunk packet's block entity list, from Block Entity Data packets (31-1 5.4), and for the command block only from the packet sent on open. A server that never refreshes a structure block entity, jigsaw entity, test block entity or test instance entity on the client shows stale values, and pressing Done writes the stale values back (section 5.8).
2. When the command block screen opens, it does not yet have the data: sections 4.2 and 4.7 describe the disabled state until the Block Entity Data packet arrives.
3. A player without game master rights never gets a screen: the blocks answer `PASS` and the packets from other clients are ignored (31-6 11.1).

## 3. Generic widgets used by the screens

### 3.1 `EditBox` (the parts these screens rely on)

Constructor `EditBox(font, x, y, width, height, narrationMessage)` (the 5-argument form; the narration text is only used for accessibility, here a language key). Defaults, read from the constructor: value `""`; maximum length 32; bordered; can lose focus; editable; not centered; text shadow on; invert-highlighted-text on; text colour -2039584 (`0xFFE0E0E0`); uneditable text colour -9408400 (`0xFF707070`). Setters used: `setMaxLength(n)` (screens below pass 3 to 32500), `setValue(s)`, `setEditable(false)`, `setResponder(fn)`, `visible` (a public field also toggled by `setVisible`), `setTooltip`.

Rules:

1. `setValue(s)`: truncates `s` to `maxLength` UTF-16 code units (`substring(0, maxLength)`, a surrogate pair may be cut), stores it, moves the cursor to the end with no selection, and calls the responder with the new value. It does not filter characters.
2. Typed characters (`charTyped`): ignored unless the box is active, focused and editable (`canConsumeInput`); the character must be an allowed chat character (`CharacterEvent.isAllowedChatCharacter`, 40-8 2.2); then `insertText(codepointAsString)`.
3. `insertText(t)` (typing and paste): the selection (between the cursor and the highlight position) is the replace range; space left = `maxLength - length + selectedLength`; when space left is 0 or less nothing happens. The text is cleaned by `StringUtil.filterText` (the chat character filter without line feeds, as in the book title field of 40-8), cut to the space left (one code unit less when the cut would leave a high surrogate last), spliced into the value, the cursor goes to the end of the inserted text, no selection, responder called.
4. Keys (`keyPressed`, only when active and focused; `shortcutKey` values, read): 8 (Backspace) deletes backwards, 127 (Delete) forwards, both by whole word when the control-with-quirk modifier is down (an editable box only); 1073741904 and 1073741903 (Left and Right) move one character, or one word with the control-with-quirk modifier; Shift extends the selection; 1073741898 and 1073741901 (Home and End) move to the start and end (Shift extends). Select-all moves to the end then the highlight to 0; copy and cut put the highlighted text on the clipboard (cut then inserts `""` when editable); paste inserts the clipboard text when editable. All handled keys return true. Enter (confirmation) is NOT handled by the box (returns false), so it reaches the screen's own handler.
5. Rendering (`extractWidgetRenderState`): nothing when `visible` is false. A bordered box draws the sprite `widget/text_field` (or `widget/text_field_highlighted` when focused) over the full widget rectangle (`WidgetSprites.get(active, focused)`; the sprite pair is built from the names `widget/text_field` and `widget/text_field_highlighted`). Inner width = `width - 8` when bordered, else `width`. The text origin is x + 4 (bordered), y + `(height - 8) / 2` when bordered; unbordered boxes use the widget origin. The displayed text is the part of the value from the scroll position that fits the inner width (`Font.plainSubstrByWidth`). The cursor blinks with period 300 ms (`TextCursorUtils.CURSOR_BLINK_INTERVAL_MS`; the exact on/off split of `isCursorVisible` was not read): a 1-pixel-wide insert bar in the middle of the text, or an underscore `_` at the end when the cursor is at the end of a box that still has room (`TextCursorUtils.extractAppendCursor`).
6. A box added with `addWidget` is interactive but not rendered by the screen's generic pass: the screen must draw it itself (the command block, structure block and jigsaw screens do, in `extractRenderState`). A box added with `addRenderableWidget` is drawn by the screen's generic pass (test block, test instance).
7. Not specified here (Open question 4): word boundaries, selection drawing and colours, scrolling of long text, mouse selection, the IME overlay, the hint text, the suggestion ghost text.

### 3.2 `CycleButton<T>` and its `Builder` (read)

A `CycleButton` is an `AbstractButton` (sprite and label rules of 12 section 5.9; narration is `narration.cycle_button.usage.focused` when focused and `narration.cycle_button.usage.hovered` otherwise, "Press Enter to switch to %s" and "Left click to switch to %s").

**Construction** (`Builder.create(x, y, width, height, name, onValueChange)`; the overload without a callback installs a callback that does nothing, and the overload without position uses (0, 0, 150, 20)):

1. The value list comes from `withValues`: a plain collection (or an array), or a pair of lists (`withValues(defaultList, altList)`) selected at use time by a boolean supplier, which for `CycleButton.DEFAULT_ALT_LIST_SELECTOR` is `Minecraft.hasAltDown()` (the Alt key is held NOW): alt list while Alt is held, else the default list. A button with an empty default list throws `No values for cycle button`.
2. Initial index = `defaultList.indexOf(initialValue)`; it is -1 when the initial value is not in the default list.
3. Label: the display state is `NAME_AND_VALUE` by default, `displayOnlyValue()` makes it `VALUE`. In `VALUE` the label is the stringifier's text for the value. In `NAME_AND_VALUE` it is the translatable text `options.generic_value` with the name and the value text (en_us `%s: %s`).
4. `booleanBuilder(onText, offText, initial)`: stringifier gives `onText` for TRUE and `offText` for FALSE; the value list is [TRUE, FALSE] in that order. `onOffBuilder(initial)`: same list, with the texts `options.on` ("ON") for TRUE and `options.off` ("OFF") for FALSE.

**Behaviour:**

1. Click or selection key (`onPress`): cycle by +1, or by -1 when Shift is held. Mouse wheel (`mouseScrolled`, always consumed): scroll up (positive vertical amount) cycles by -1, scroll down by +1, zero does nothing.
2. `cycleValue(d)`: the selected list is the alt list when the alt selector says so, else the default list; `index = positiveModulo(index + d, size)`; the new value is `list[index]`; the label is rebuilt; then `onValueChange(button, value)` is called.
3. `setValue(v)`: finds `v` in the selected list; when found the index is set, then in all cases the stored value and label are replaced by `v` (so the value may be one that is not in the list). It does NOT call `onValueChange`. This matters for `CommandBlockEditScreen.updateGui` (section 4.4) and the jigsaw resize.
4. Because the index survives a change of the Alt state, holding Alt can change which list the next step walks, without moving the index.

### 3.3 `AbstractSliderButton` (read; used by the jigsaw screen, section 6)

State `value` in [0, 1]. Handle sprite width is 8 (`HANDLE_WIDTH`); the track sprite is `widget/slider` (or `widget/slider_highlighted` when active, focused and `canChangeValue` is false); the handle is `widget/slider_handle`, or `widget/slider_handle_highlighted` when active and (hovered or `canChangeValue`). The handle is drawn at x + `trunc(value * (width - 8))`, y, 8 wide, height equal to the widget height. The label is the widget message, drawn as scrolling text with margin 2.

1. Mouse press (when active) starts a drag and sets the value from the pointer: `value = clamp((mouseX - (x + 4)) / (width - 8), 0, 1)`; dragging repeats this. Release ends the drag.
2. Keyboard: focus gives `canChangeValue = true` only when the last input type was the mouse or Tab navigation. A selection key toggles `canChangeValue`. While it is true, Left and Right change the value by -1 or +1 times `1 / (width - 8)` (a one-pixel step). Other keys are not consumed.
3. `setValue(v)`: clamps to [0, 1]; when the clamped value differs from the old value `applyValue()` is called; `updateMessage()` is always called.
4. Narration: `gui.narrate.slider` ("%s slider") with the message.

### 3.4 `FittingMultiLineTextWidget` (read)

A text area (`AbstractTextAreaWidget`: inner padding 4 on each side, total 8; sprite background and scroll bar as `AbstractScrollArea`, 40-8 13) containing a `MultiLineTextWidget` whose maximum width is `widgetWidth - 8`. The inner height is the number of wrapped lines times 9. The widget scrolls when the inner height exceeds the widget height minus 8 (`scrollable`). `setMessage` replaces the text. The constructor takes `(x, y, width, height, message, font)` and sets the scroll-rate setting from 9.

### 3.5 `CommandSuggestions` construction (read)

The command block screen builds `CommandSuggestions(minecraft, screen, commandEdit, font, commandsOnly = true, onlyShowIfCursorPastError = true, lineStartOffset = 0, suggestionLineLimit = 7, anchorToBottom = false, fillColor = 0x80000000)` (the int -2147483648; the parameter names are the field names read in the class constructor). It is then given `setAllowSuggestions(true)` and `updateCommandInfo()`. Display, colouring and completion rules are those of 15 sections 3.6 and 14.5 with these parameters: the chat screen's list limit is 10 lines (15 14.5), here 7; the text has no leading slash (`commandsOnly`, `lineStartOffset` 0). `isVisible`, `getUsageNarration`, `getNarrationMessage`, `keyPressed`, `mouseClicked` and `mouseScrolled` (one scroll amount) are used by the command screen (section 4.1).

## 4. The command block screens

### 4.1 `AbstractCommandBlockEditScreen` (the shared base)

The screen's title text is `GameNarrator.NO_TITLE` (nothing). Abstract hooks: `getCommandBlock()` (the shared `BaseCommandBlock` of the block entity or of the minecart), `getPreviousY()`, `populateAndSendPacket()`; optional `addExtraControls()` (nothing in the base).

Language keys: `advMode.setCommand` ("Set Console Command for Block"), `advMode.command` ("Console Command"), `advMode.previousOutput` ("Previous Output"), `advMode.trackOutput` ("Track Output").

**`init()` creates, in this order** (all coordinates with `cx`):

| Widget | Rectangle (x, y, w, h) | Rules |
|---|---|---|
| `commandEdit` | (`cx - 150`, 50, 300, 20) | narration `advMode.command` extended with the suggestion narration; maximum length 32500; responder calls `commandSuggestions.updateCommandInfo()`; added as a widget (drawn by the screen) |
| `previousEdit` | (`cx - 150`, `getPreviousY()`, 276, 20) | maximum length 32500; not editable; value set to `"-"` first; added as a widget |
| `outputButton` | a `CycleButton` from `booleanBuilder("O", "X", trackOutput)` with `displayOnlyValue`, (`cx + 150 - 20`, `getPreviousY()`, 20, 20) | name `advMode.trackOutput`; TRUE shows "O", FALSE "X"; initial value is `getCommandBlock().isTrackOutput()` read at init; callback: `setTrackOutput(value)` on the shared block IMMEDIATELY, then `updatePreviousOutput(value)` |
| extra controls | `addExtraControls()` | the command block screen adds three buttons (4.2) |
| `doneButton` | (`cx - 4 - 150`, `H / 4 + 120 + 12`, 150, 20) | text Done; press calls `onDone` |
| `cancelButton` | (`cx + 4`, `H / 4 + 120 + 12`, 150, 20) | text Cancel; press calls `onClose` (the base `Screen.onClose`: close the screen, nothing sent) |
| `commandSuggestions` | section 3.5 | created after the buttons; then `updateCommandInfo()` and `updatePreviousOutput(trackOutput)` |

Initial focus: `commandEdit`.

`updatePreviousOutput(track)`: `previousEdit.setValue(track ? lastOutput text : "-")` where the last output text is `BaseCommandBlock.getLastOutput().getString()` (the empty text when no output is stored).

**`onDone()`:** `populateAndSendPacket()`; then, if the block's `isTrackOutput()` is false, `setLastOutput(null)` on the client's copy; then close the screen. The packet is sent before the close, whatever the focus.

**Per-tick rule (`tick`):** when `getCommandBlock().isValid()` is false the screen closes itself (for a block entity, valid means not removed; for the minecart, the entity is not removed). A nulled block or a killed minecart therefore closes the screen without a packet.

**Keys:** `keyPressed` goes to the suggestions first (return true when consumed), then to `Screen.keyPressed` (Escape closes through `onClose`; Tab and arrow focus navigation; the focused widget), then, when the event `isConfirmation` (Enter, 40-8 section 0), `onDone()` runs and the key is consumed. The confirmation test does NOT check whether the Done button is enabled. `mouseScrolled` and `mouseClicked` also go to the suggestions first.

**`resize(w, h)`:** the command text is saved, the screen is re-initialized (all widgets rebuilt from the model, section 4.2 for the command block), the text is restored with `setValue`, and `updateCommandInfo()` runs. The block's track-output flag, mode, conditional and automatic values are in the model fields and survive.

**Drawing (`extractRenderState`):**

1. Base screen (background).
2. Title: `advMode.setCommand` centred at (`cx`, 20), colour -1.
3. Label `advMode.command` at (`cx - 150 + 1`, 40), colour `0xFFA0A0A0`.
4. `commandEdit`.
5. When `previousEdit.getValue()` is not empty: let `y = 75 + (5 * 9 + 1 + previousY - 135) = previousY - 14` (the 5 times the font line height plus 1 term is read from the code), label `advMode.previousOutput` at (`cx - 150 + 1`, `y + 4`) (that is `previousY - 10`), then `previousEdit`. With the value `""` (the tracked block has produced no output) neither is drawn.
6. `commandSuggestions` last.

### 4.2 `CommandBlockEditScreen` (read)

Model fields (initial values in the constructor): `mode = REDSTONE`, `conditional = false`, `autoexec = false`. `getPreviousY()` is 135. The constructor's own title is the base's (none).

`addExtraControls()` creates three `CycleButton`s, in this order, each 100 x 20 at y 165:

| Button | x | Values and initial | Label | Name key | Callback |
|---|---|---|---|---|---|
| mode | `cx - 50 - 100 - 4` (= `cx - 154`) | `CommandBlockEntity.Mode.values()` in order SEQUENCE, AUTO, REDSTONE (31-6 2.4; 05c 0x37 ids 0, 1, 2); initial `mode` field | `advMode.mode.sequence` ("Chain"), `advMode.mode.auto` ("Repeat"), `advMode.mode.redstone` ("Impulse"); value only | `advMode.mode` | `mode := value` |
| conditional | `cx - 50` | `booleanBuilder` TRUE text `advMode.mode.conditional` ("Conditional"), FALSE text `advMode.mode.unconditional` ("Unconditional"); initial `conditional` field | value only | `advMode.type` | `conditional := value` |
| automatic | `cx + 50 + 4` (= `cx + 54`) | `booleanBuilder` TRUE text `advMode.mode.autoexec.bat` ("Always Active"), FALSE text `advMode.mode.redstoneTriggered` ("Needs Redstone"); initial `autoexec` field | value only | `advMode.triggering` | `autoexec := value` |

`init()` runs the base `init()` and then `enableControls(false)`: Done, the track output button, mode, conditional and automatic buttons become inactive (greyed, `active` false). Cancel and the command box stay enabled. So until data arrives the screen shows the defaults above (command `""`, mode "Impulse", "Unconditional", "Needs Redstone") and the user may type but cannot press Done (Enter still sends, section 4.7).

`updateGui()` (called by `ClientPacketListener.handleBlockEntityData` after loading the packet's tag into the entity, when the block entity is a `CommandBlockEntity` and the current screen is a `CommandBlockEditScreen`; the check is on the current screen only, not on the position; read):

1. `commandEdit.setValue(command)` from the entity's `BaseCommandBlock`.
2. `track := isTrackOutput()`; `mode := entity.getMode()`; `conditional := entity.isConditional()`; `autoexec := entity.isAutomatic()`.
3. `outputButton.setValue(track)`, `modeButton.setValue(mode)`, `conditionalButton.setValue(conditional)`, `autoexecButton.setValue(autoexec)` (no callbacks fire, 3.2 behaviour 3).
4. `updatePreviousOutput(track)`.
5. `enableControls(true)` (all five become active).

`resize` calls the base resize and then `enableControls(true)` (so a window resize enables the controls even if no data has arrived; the rebuilt widgets use the model fields).

`populateAndSendPacket()` sends Set Command Block (05c 0x37) with: the entity's block position; the text of `commandEdit`; the mode field; and the flags: track output = `getCommandBlock().isTrackOutput()` (bit 0x01), conditional = the field (bit 0x02), automatic = the `autoexec` field (bit 0x04). The server side is 31-6 5.1.

### 4.3 `MinecartCommandBlockEditScreen` (read)

`getPreviousY()` is 150 (the previous output row is lower because there are no mode buttons). `getCommandBlock()` is the minecart's `getCommandBlock()`. `init()` runs the base `init()` and sets `commandEdit.setValue(getCommandBlock().getCommand())` immediately (the data is already on the client in the entity's synchronized data, 44-8). There is no `updateGui`: later changes to the entity do not refresh the open screen. All controls are enabled from the start. `populateAndSendPacket()` sends Set Command Minecart (05c 0x38) with the entity id (`getId()`), the text of `commandEdit` and `isTrackOutput()`. The server handler (not in 31-6) is `handleSetCommandMinecart` (the steps below are behaviour steps read from that handler in the server-side game packet listener class; the handler was re-read in the fixing pass and the order of the five steps was confirmed). The only server-side language keys involved are `advMode.notAllowed` ("Must be an opped player in creative mode"), `advMode.setCommand.success` ("Command set: %s") and `advMode.setCommand.disabled` ("Command set: %s, but command blocks are still disabled"); texts read from `en_us.json`:

1. If the player cannot use game master blocks: system message `advMode.notAllowed` and stop.
2. Resolve the entity from the packet's id on the player's level through `getCommandBlock(level)`; if it does not resolve (no such entity or not a command block minecart) nothing happens.
3. `setCommand(text)`; `setTrackOutput(flag)`; when the flag is false, `setLastOutput(none)`.
4. `enabled := level.isCommandBlockEnabled()` (the rule `command_blocks_work`, 33): when true, `onUpdated(level)`.
5. When the text is not null and not empty: a system message to the player, `advMode.setCommand.success` when enabled, else `advMode.setCommand.disabled`, argument the text.

### 4.4 Layout summary for the command block screen

| Element | Rectangle |
|---|---|
| Title `advMode.setCommand` | centred at (`cx`, 20) |
| Label `advMode.command` | (`cx - 149`, 40) |
| Command box | (`cx - 150`, 50, 300 x 20) |
| Previous-output label | (`cx - 149`, 125) |
| Previous-output box | (`cx - 150`, 135, 276 x 20) |
| Track-output button | (`cx + 130`, 135, 20 x 20) |
| Mode, conditional, automatic buttons | (`cx - 154`, 165), (`cx - 50`, 165), (`cx + 54`, 165), each 100 x 20 |
| Done, Cancel | (`cx - 154`, `H / 4 + 132`) and (`cx + 4`, `H / 4 + 132`), each 150 x 20 |

For the minecart screen the previous-output row moves to y 150 (label 140) and the three mode buttons do not exist.

### 4.5 Worked examples (W = 320, H = 240, so `cx` = 160)

1. Command block screen widgets: command box x 10 to 310, y 50 to 70; previous box x 10 to 286, y 135 to 155; output button x 290 to 310; mode button x 6 to 106, conditional x 110 to 210, automatic x 214 to 314, all y 165 to 185; Done at (6, 192), Cancel at (164, 192).
2. Minecart screen at the same size: previous box y 150 to 170, label text at y 140, output button (290, 150).
3. Data arrives for a block saved with `Command` = `say hi`, mode AUTO, `conditional` true, `auto` false, `TrackOutput` true, last output "hi": after `updateGui` the command box shows `say hi`, the mode button "Repeat", the type button "Conditional", the trigger button "Needs Redstone", the output button "O", the previous box `hi`; all five controls are enabled. Pressing Done sends mode 1, flags 0x01 | 0x02 = 0x03 (automatic is false), command `say hi`.
4. The user turns the output button to "X": `setTrackOutput(false)` is applied to the client's copy at once; the previous box shows `-`; the previous-output label and box stay drawn (the value `-` is not empty).
5. Block with no stored output and tracking on: `getLastOutput()` is the empty text, the previous box value is `""`, so neither the previous label nor the box is drawn.
6. Race: the screen is opened but the Block Entity Data packet has not arrived. Done is greyed. The user presses Enter: `onDone` runs and sends mode REDSTONE (2), flags 0 and the command typed so far (empty), overwriting the server block (31-6 5.1 step 3 rebuilds the block as an impulse, non-conditional command block).

### 4.6 Validation notes for the command block screens

| Check | Expected |
|---|---|
| `booleanBuilder` order | TRUE first: the first click on a FALSE-initial button goes to index 1 + 1 mod 2 = 0, which is TRUE |
| Mode button list | three entries; Alt does nothing (a single list) |
| Cancel and Esc | no packet; entity fields changed by the output button callback (`setTrackOutput`) stay changed on the client's copy until the next Block Entity Data packet (inferred: no restore code was read) |
| Resize | the command text survives; the controls of the command block screen are all enabled afterwards |

### 4.7 Edge cases to reproduce

1. Enter sends the packet even when Done is greyed and before any data was received (section 4.5 example 6).
2. `commandEdit` allows 32500 characters on the client; 05c 0x37 lists a maximum of 32767 characters for the command.
3. The minecart screen never refreshes; the block screen refreshes only when a Block Entity Data packet for a command block arrives (any position) while the screen is open.

## 5. `StructureBlockEditScreen`

Title: the translated name of the structure block (`Blocks.STRUCTURE_BLOCK.getDescriptionId()`, key `block.minecraft.structure_block`, "Structure Block"), drawn at (`cx`, 10) in colour -1. The entity is `StructureBlockEntity` (31-6 section 6). `decimalFormat` is `DecimalFormat("0.0###")` with the root locale's symbols (a decimal point, no grouping).

### 5.1 Model

At `init()` the screen copies from the entity into `initialMirror`, `initialRotation`, `initialMode`, `initialEntityIgnoring`, `initialStrict`, `initialShowAir`, `initialShowBoundingBox` (the field initializers NONE, NONE, DATA, ... are overwritten by init). The buttons below change the ENTITY immediately (`setMirror`, `setRotation`, `setMode`, `setIgnoreEntities`, `setStrict`, `setShowAir`, `setShowBoundingBox`), so the world renderer (31-6 7) shows the effect while the screen is open. The text boxes are not written to the entity.

### 5.2 Widgets (created in this order; `cx` as above)

Language keys with `en_us` text in parentheses.

| Widget | Rectangle (x, y, w, h) | Details |
|---|---|---|
| Done | (`cx - 4 - 150`, 210, 150, 20) | `onDone` |
| Cancel | (`cx + 4`, 210, 150, 20) | `onCancel` |
| SAVE button | (`cx + 4 + 100`, 185, 50, 20) | label `structure_block.button.save` ("SAVE"); press: when the entity's mode is SAVE send UPDATE type SAVE_AREA, then close |
| LOAD button | (`cx + 104`, 185, 50, 20) | label `structure_block.button.load` ("LOAD"); press: when the mode is LOAD send LOAD_AREA, then close. Same rectangle as SAVE (they are never visible together) |
| Mode cycle button | (`cx - 4 - 150`, 185, 50, 20) | `CycleButton` over mode values, `displayOnlyValue`, name text is the literal `MODE`; default list [SAVE, LOAD, CORNER], alt list (Alt held) [SAVE, LOAD, CORNER, DATA]; initial value `initialMode`; label of a value = the translatable text `structure_block.mode.<serialized name>` (save, load, corner, data; "Save", "Load", "Corner", "Data"); callback: `structure.setMode(mode)` and `updateMode(mode)` |
| DETECT button | (`cx + 104`, 120, 50, 20) | label `structure_block.button.detect_size` ("DETECT"); press: when the mode is SAVE send SCAN_AREA, then close |
| Include entities | on/off `CycleButton`, `displayOnlyValue`, (`cx + 104`, 160, 50, 20) | name `structure_block.include_entities`; initial = NOT `isIgnoreEntities`; callback `setIgnoreEntities(NOT value)` |
| Strict | on/off, `displayOnlyValue`, (`cx + 104`, 120, 50, 20) | name `structure_block.strict`; initial `isStrict`; callback `setStrict(value)` |
| Mirror | `CycleButton` over `Mirror.values()` (NONE, LEFT_RIGHT, FRONT_BACK, same order as 05c 0x3C), `displayOnlyValue`, (`cx - 20`, 185, 40, 20) | name literal `MIRROR`; initial `initialMirror`; value label is the `symbol` text of the mirror, the translatable `mirror.<serialized name>` (`mirror.none` "\|"; `mirror.left_right` is the three code points U+2190 U+0020 U+2192, "← →"; `mirror.front_back` is U+2191 U+0020 U+2193, "↑ ↓"; read from `en_us.json`); callback `setMirror` |
| Show air | on/off, `displayOnlyValue`, (`cx + 104`, 80, 50, 20) | name `structure_block.show_air`; initial `getShowAir`; callback `setShowAir` |
| Show bounding box | on/off, `displayOnlyValue`, (`cx + 104`, 80, 50, 20) | name `structure_block.show_boundingbox`; initial `getShowBoundingBox`; callback `setShowBoundingBox`. Same rectangle as Show air (never visible together) |
| Rotation 0 | Button, (`cx - 1 - 40 - 1 - 40 - 20`, 185, 40, 20) = (`cx - 102`, ...); full expression read in the bytecode: `width / 2 - 1 - 40 - 1 - 40 - 20`, then 185, 40, 20 (the offsets of the next three rows were read the same way; -102 = -1-40-1-40-20, -61 = -1-40-20, +21 = +1+20, +62 = +1+40+1+20) | literal text `0`; press: `setRotation(NONE)` then `updateDirectionButtons` |
| Rotation 90 | (`cx - 1 - 40 - 20`, 185, 40, 20) = (`cx - 61`, ...) | literal `90`; `CLOCKWISE_90` |
| Rotation 180 | (`cx + 1 + 20`, 185, 40, 20) = (`cx + 21`, ...) | literal `180`; `CLOCKWISE_180` |
| Rotation 270 | (`cx + 1 + 40 + 1 + 20`, 185, 40, 20) = (`cx + 62`, ...) | literal `270`; `COUNTERCLOCKWISE_90` |
| Name box | (`cx - 152`, 40, 300, 20) | narration `structure_block.structure_name`; max length 128; value `getStructureName()`; widget; subclass that filters typed characters (5.4) |
| Position X, Y, Z boxes | (`cx - 152`, 80), (`cx - 72`, 80), (`cx + 8`, 80), each 80 x 20 | narration `structure_block.position.x` and y, z; max length 15; initial `Integer.toString` of `getStructurePos()` components (the offset, relative to the block); widgets |
| Size X, Y, Z boxes | (`cx - 152`, 120), (`cx - 72`, 120), (`cx + 8`, 120), each 80 x 20 | narration `structure_block.size.x` and y, z; max 15; initial `getStructureSize()` components |
| Integrity box | (`cx - 152`, 120, 80, 20) | narration `structure_block.integrity.integrity`; max 15; initial `decimalFormat.format(getIntegrity())` (double conversion of the float) |
| Seed box | (`cx - 72`, 120, 80, 20) | narration `structure_block.integrity.seed`; max 31; initial `Long.toString(getSeed())` |
| Custom data box | (`cx - 152`, 120, 240, 20) | narration `structure_block.custom_data`; max 128; initial `getMetaData()` |

After the boxes: `updateDirectionButtons()` then `updateMode(initialMode)`. Initial focus: the name box. The order of the first widgets in the creation list (Done, Cancel, then SAVE, LOAD, mode, DETECT, include entities, strict, mirror, show air, bounding box, the four rotation buttons, then the boxes) is the order of the tab traversal for the renderable widgets; the boxes are added with `addWidget` after them.

### 5.3 `updateMode(mode)` visibility table

First every box is hidden (`visible` false) and every button and cycle button is hidden (the fields `visible`), then:

| Mode | Visible |
|---|---|
| SAVE | name, position X Y Z, size X Y Z; buttons SAVE, DETECT, include entities, show air |
| LOAD | name, position X Y Z, integrity, seed; buttons LOAD, include entities, strict, mirror, the four rotation buttons, show bounding box; and `updateDirectionButtons()` is called |
| CORNER | name only |
| DATA | custom data box only (the name box is hidden) |

The mode cycle button, Done and Cancel are always visible. `updateDirectionButtons()` makes all four rotation buttons active and then deactivates the one equal to the entity's current rotation (NONE: the 0 button, CLOCKWISE_90: the 90 button, CLOCKWISE_180: 180, COUNTERCLOCKWISE_90: 270).

### 5.4 Name filter

Typing in the name box (`charTyped`) is refused (returns false, nothing inserted) unless `isValidCharacterForName(value, codepoint, cursor)` (a protected method of `Screen`, read) is true. Rule for a typed code point `c` with `colon` = index of the first `:` in the value and `slash` = index of the first `/` (each -1 when absent):

1. `c` is `:` (58): allowed when (`slash` is -1 or `cursor <= slash`) and `colon` is -1.
2. `c` is `/` (47): allowed when `cursor > colon` (so a slash is allowed with no colon only when `cursor > -1`, always true).
3. Otherwise allowed when `c` is one of `_`, `-`, `.` or in `a` to `z` or `0` to `9`. Upper case letters are refused.

Only typed characters are filtered; pasting (`insertText`) is not (3.1 rule 3). The server validates the name when the packet arrives (31-6 6.7).

### 5.5 Drawing (`extractRenderState`)

All text colour `0xFFA0A0A0` unless said. Right aligned means x = `cx + 154 - font.width(label)`.

1. Base screen; the title at (`cx`, 10) colour -1.
2. When the mode is not DATA: label `structure_block.structure_name` ("Structure Name") at (`cx - 153`, 30); the name box.
3. When the mode is LOAD or SAVE: label `structure_block.position` ("Relative Position") at (`cx - 153`, 70); the three position boxes; label `structure_block.include_entities` ("Include Entities:") right aligned at y 150 (note: the label is at y 150 while its button is at y 160, as read).
4. When the mode is SAVE: label `structure_block.size` ("Structure Size") at (`cx - 153`, 110); the three size boxes; label `structure_block.detect_size` ("Detect Structure Size and Position:") right aligned at y 110; label `structure_block.show_air` ("Show Invisible Blocks:") right aligned at y 70.
5. When the mode is LOAD: label `structure_block.integrity` ("Structure Integrity and Seed") at (`cx - 153`, 110); the integrity box and the seed box; label `structure_block.strict` ("Strict Placement:") right aligned at y 110; label `structure_block.show_boundingbox` ("Show Bounding Box:") right aligned at y 70.
6. When the mode is DATA: label `structure_block.custom_data` ("Custom Data Tag Name") at (`cx - 153`, 110); the custom data box.
7. Always: the mode's descriptive text `StructureMode.getDisplayName()`, the translatable `structure_block.mode_info.<name>` ("Save Mode - Write to file", "Load Mode - Load from file", "Corner Mode - Placement and size marker", "Data Mode - Game logic marker"), at (`cx - 153`, 174).

The mode used by the drawing is the ENTITY's current mode (`structure.getMode()`), which the mode button changes at once.

### 5.6 Sending (`sendToServer(updateType)`)

Builds Set Structure Block (05c 0x3C) from:

| Packet field | Source |
|---|---|
| Location | the entity's block position |
| Update type | the argument: `UPDATE_DATA` (Done), `SAVE_AREA`, `LOAD_AREA`, `SCAN_AREA` |
| Mode, Mirror, Rotation | the entity's current values |
| Name | the name box text |
| Offset | the three position boxes through `parseCoordinate` |
| Size | the three size boxes through `parseCoordinate` |
| Metadata | the custom data box text |
| Flags | `ignoreEntities`, `strict`, `showAir`, `showBoundingBox` of the entity |
| Integrity | the integrity box through `parseIntegrity` |
| Seed | the seed box through `parseSeed` |

Parsers: `parseCoordinate` is `Integer.parseInt` with 0 on failure; `parseIntegrity` is `Float.valueOf` with 1.0 on failure; `parseSeed` is `Long.valueOf` with 0 on failure (the number grammars are those of the Java parsing methods: sign, digits, no surrounding spaces for the integer forms; recalled, not verified, Open question 5). Hidden boxes still hold their values and are still sent. The method returns true unconditionally, so each caller closes the screen after sending.

Encoding detail read in the packet class (`ServerboundSetStructureBlockPacket`, bytecode of both the writer and the reader): the six offset and size components are written with `FriendlyByteBuf.writeByte(int)` (read), the seed with `writeVarLong` and the name with the default `writeUtf` (read). The reader uses `readByte` (a SIGNED byte) for each of the six, then `Mth.clamp` (offset to -48 to 48, size to 0 to 48, both bounds read in the fixing pass), integrity clamped to 0 to 1, metadata `readUtf` limit 128 (read; 05c). That `writeByte(int)` keeps only the low 8 bits is a behaviour of the Netty `ByteBuf` library, which is outside the jar's own classes: it is stated here as library behaviour (recalled, not verified in this artifact, Open question 10). So a typed value outside the byte range is folded before clamping (worked examples in 5.9). Metadata is read with a limit of 128 characters; the integrity is clamped to 0 to 1.

### 5.7 Buttons, keys and closing

| Action | Effect |
|---|---|
| Done or Enter | send UPDATE_DATA then close (no restore) |
| SAVE (mode SAVE) | send SAVE_AREA then close |
| LOAD (mode LOAD) | send LOAD_AREA then close |
| DETECT (mode SAVE) | send SCAN_AREA then close |
| Cancel, Esc (`onClose` is `onCancel`) | restore the seven initial values to the entity, close, no packet |

`keyPressed`: `Screen.keyPressed` first (Escape, focus navigation, the focused widget; an `EditBox` does not take Enter), then `isConfirmation` calls `onDone`. The Enter shortcut does not look at the mode or any button state.

`resize(w, h)` saves the values of all nine boxes, rebuilds the screen with `init`, and restores the nine values with `setValue`. The entity (mode, mirror, rotation, flags) is not touched, so the rebuilt button states follow the entity; `initial*` values are re-read from the entity by the new `init`, so a Cancel after a resize restores the values at the time of the resize, not the values at the first open (read from the order: `init` re-reads them from the entity that the buttons already changed; Open question 6).

### 5.8 Layout summary and stale data

For W = 320 (`cx` = 160): name box x 8 to 308 (y 40); position boxes x 8, 88, 168 (y 80); size boxes x 8, 88, 168 (y 120), integrity x 8, seed x 88 (y 120), custom data box x 8 to 248; mode button x 6 to 56 (y 185); rotation buttons x 58, 99, 181, 222 (40 wide); mirror x 140 to 180; SAVE and LOAD x 264 to 314; DETECT x 264 (y 120); include entities x 264 (y 160); strict x 264 (y 120); show air and bounding box x 264 (y 80); Done x 6, Cancel x 164 (y 210).

The mode shown in the boxes, the offset and the size come from the client's entity copy when the screen opens; the first `UPDATE_DATA` writes all of them back (including hidden fields) to the server, so a stale copy overwrites newer server data (section 2 point 1).

### 5.9 Worked examples

1. Open a structure block in SAVE mode with name `house`, offset (0, 1, 0), size (5, 5, 5): visible are the name box with `house`, the position boxes `0 1 0`, the size boxes `5 5 5`, buttons SAVE, DETECT, entities ON, show-air OFF (`OFF` is the on/off text); the info text "Save Mode - Write to file" at y 174. Clicking SAVE sends `SAVE_AREA`, mode save, name `house`, offset 0, 1, 0, size 5, 5, 5, mirror none, rotation none, flags for `ignoreEntities` false (entities ON) so bit 0x01 clear, and closes.
2. Type `300` in the X size box and press Done: `parseCoordinate` gives 300; `writeByte` keeps 300 mod 256 = 44 (Netty low-8-bit behaviour, recalled, not verified); the decoder reads 44 and clamps to 44 (size range 0 to 48). Type `200` as an offset: 200 mod 256 = 200 which reads as -56 and clamps to -48. Type `255` as a size: reads -1, clamps to 0. Type `-5` as an offset: -5.
3. Name box typing `a:b/c`: `a` ok; `:` ok (no colon, no slash yet); `b` ok; `/` ok (cursor 3 > colon 1); `c` ok. Then typing `:` again is refused (a colon exists). Typing `A` is refused. Typing `/` with the cursor before the colon (cursor 0 and colon at 1) is refused (cursor 0 is not above 1).
4. The user types `abc` in the integrity box: `Float.valueOf` fails and 1.0 is sent. Typing `0.5` sends 0.5. The box shows `0.5` initially for an integrity of 0.5 (the format `0.0###` always prints at least one decimal digit and at most four): 1.0 prints `1.0`, 0.25 prints `0.25`, 0.123456 prints `0.1235` (round half even on the decimal expansion, recalled, not verified).
5. Mode cycling with no Alt: SAVE then LOAD then CORNER then SAVE. With the entity in DATA mode at open, the button shows "Data"; the initial index is -1 in the default list, so the first click selects index 0 (SAVE). While Alt is held the walk uses the four-entry list.
6. Rotation: with the entity rotation CLOCKWISE_90 the "90" button is greyed, the other three are active; pressing "180" sets the entity rotation, greys "180" and activates "90".
7. Esc after toggling mirror and mode: both are restored on the entity and nothing is sent.

## 6. `JigsawBlockEditScreen`

No title text (`GameNarrator.NO_TITLE`). Entity `JigsawBlockEntity` (31-6 section 8). Fields: `levels` (0), `keepJigsaws` (true), `joint`.

### 6.1 Widgets

| Widget | Rectangle (x, y, w, h) | Details |
|---|---|---|
| Pool box | (`cx - 153`, 20, 300, 20) | narration `jigsaw_block.pool`; max 128; value = the entity's pool key identifier text (`ResourceKey.identifier().toString()`); responder `updateValidity` |
| Name box | (`cx - 153`, 55, 300, 20) | narration `jigsaw_block.name`; max 128; value `getName().toString()`; responder `updateValidity` |
| Target box | (`cx - 153`, 90, 300, 20) | narration `jigsaw_block.target`; max 128; value `getTarget().toString()`; responder `updateValidity` |
| Final state box | (`cx - 153`, 125, 300, 20) | narration `jigsaw_block.final_state`; max 256; value `getFinalState()`; no responder |
| Selection priority box | (`cx - 153`, 160, 98, 20) | narration `jigsaw_block.selection_priority`; max 3; value `Integer.toString`; tooltip `jigsaw_block.selection_priority.tooltip` |
| Placement priority box | (`cx - 50`, 160, 98, 20) | narration `jigsaw_block.placement_priority`; max 3; value `Integer.toString`; tooltip `jigsaw_block.placement_priority.tooltip` |
| Joint button | `CycleButton` over `JointType.values()` (ROLLABLE, ALIGNED; same order as 31-6 8.1), `displayOnlyValue`, (`cx + 54`, 160, 100, 20) | name `jigsaw_block.joint_label`; value label translatable `jigsaw_block.joint.<name>` ("Rollable", "Aligned"); initial = the entity's joint; callback `joint := value`; both `active` and `visible` are set to "the front direction of the block state is vertical" (`JigsawBlock.getFrontFacing(state).getAxis().isVertical()`) |
| Levels slider | an `AbstractSliderButton` subclass, (`cx - 154`, 185, 100, 20), empty initial message, initial value 0.0 | its message is the translatable `jigsaw_block.levels` with the argument `levels` ("Levels: %s"), refreshed by `updateMessage`; `applyValue` sets `levels = floor(clampedLerp(value, 0, 20))`, i.e. `floor(20 * value)`, an integer 0 to 20 |
| Keep jigsaws | on/off `CycleButton` (NOT value only), (`cx - 50`, 185, 100, 20) | name `jigsaw_block.keep_jigsaws` ("Keep Jigsaws: ON"); initial `keepJigsaws`; callback sets `keepJigsaws` |
| Generate | Button, (`cx + 54`, 185, 100, 20) | text `jigsaw_block.generate` ("Generate"); press: `onDone()` then `sendGenerate()` |
| Done | (`cx - 4 - 150`, 210, 150, 20) | `onDone` |
| Cancel | (`cx + 4`, 210, 150, 20) | `onCancel` |

The three identifier boxes are widgets drawn by the screen; the two priority boxes are also widgets. Initial focus: the pool box. At the end of `init`, `updateValidity()` runs.

### 6.2 Validity and keys

`updateValidity()`: `valid = isValidIdentifier(name) and isValidIdentifier(target) and isValidIdentifier(pool)` where `isValidIdentifier(s)` is "`Identifier.tryParse(s)` is not null" (grammar: 23 section 1; a string without a colon takes the namespace `minecraft`, 45-1). Both Done and Generate get `active = valid`. The final state box and the priority boxes are not validated.

`keyPressed`: `Screen.keyPressed` first; then, when the Done button is active and the event is a confirmation, `onDone()`. Esc closes through `onClose`, which is `onCancel` (close, no packet). Enter never triggers Generate.

### 6.3 Sending

`onDone()`: `sendToServer()` then close. `sendToServer` sends Set Jigsaw Block (05c 0x3B): position; `Identifier.parse` of the name, target and pool boxes (`parse` throws on an invalid text, so a send is only possible while valid); the final state text; the joint field; the selection priority and the placement priority each through `Integer.parseInt` with 0 on failure (so a typed `-` or empty text is 0; three characters allow `-99` to `999`). The field order in the packet is as in 05c 0x3B (selection priority before placement priority). `sendGenerate()` sends Jigsaw Generate (05c 0x1B) with the position, `levels` and `keepJigsaws`.

Server order for the Generate button: Set Jigsaw Block first (the screen's `onDone`), then Jigsaw Generate on the same connection (31-6 8.2), so the generation uses the values just sent.

### 6.4 Drawing

All labels colour `0xFFA0A0A0`. Pool label (`jigsaw_block.pool`, "Target Pool:") at (`cx - 153`, 10); name label ("Name:") at (`cx - 153`, 45); target label ("Target Name:") at (`cx - 153`, 80); final state label ("Turns into:") at (`cx - 153`, 115); selection priority label ("Selection Priority:") at (`cx - 153`, 150); placement priority label ("Placement Priority:") at (`cx - 50`, 150); when the front direction is vertical the joint label (`jigsaw_block.joint_label`, "Joint Type:") at (`cx + 53`, 150). Then the boxes. The renderable widgets (buttons, slider) are drawn by the base pass.

### 6.5 `resize`

Saves the six box texts, `levels` and `joint`; re-inits; restores the box texts, `levels` and `joint` (and `jointButton.setValue(joint)`). `keepJigsaws` survives as a field. The slider is rebuilt with initial value 0.0 while its label reads the restored `levels`, so after a resize the handle is at the left end while the label shows the old level (read from the constructor and from `resize`; Open question 7).

### 6.6 Worked examples (W = 320)

1. Boxes: pool x 7 to 307 (y 20), name y 55, target y 90, final state y 125, selection priority x 7 to 105, placement x 110 to 208, joint x 214 to 314, slider x 6 to 106, keep jigsaws x 110, Generate x 214, Done x 6, Cancel x 164 (y 210).
2. A jigsaw at orientation `up_north` (front vertical): the joint button and its label are shown and enabled. At orientation `north_up` (front horizontal) they are hidden and inactive.
3. Slider: width 100 gives handle travel 92 pixels. Clicking at pointer x = slider x + 4 + 46 gives value 0.5 and `levels` 10. Clicking at the far right gives value 1.0 and `levels` 20. Value 0.999 gives 19 (floor of 19.98). One Left key step with keyboard control changes the value by 1/92.
4. Done with the pool box text `minecraft:bad pool`: `Identifier.tryParse` fails (the space is invalid), Done and Generate are greyed and Enter does nothing.
5. Priorities: `-5` sends -5, `abc` sends 0, `1000` cannot be typed (3 characters).

## 7. `TestBlockEditScreen`

Title: `Blocks.TEST_BLOCK.getDescriptionId()` ("Test Block"), the title at (`cx`, 10) colour -1. The constructor copies the position, mode and message from the entity once; later changes to the entity do not refresh the screen. Constants: `MODES` = `TestBlockMode.values()` in order START, LOG, FAIL, ACCEPT (31-6 9.1 ids 0 to 3).

| Widget | Rectangle | Details |
|---|---|---|
| Message box | (`cx - 152`, 80, 240, 20), added as a RENDERABLE widget | narration `test_block.message`; max 128; initial value the copied message; `visible = (mode != START)` (set by `updateMode`) |
| Mode button | `CycleButton` over `MODES`, `displayOnlyValue`, (`cx - 4 - 150`, 185, 50, 20) | name = the title text; initial = the copied mode; value label = the translatable `test_block.mode.<name>` ("Start", "Log", "Fail", "Accept"); callback `updateMode(value)` which stores the mode in the screen and toggles the message box visibility |
| Done | (`cx - 154`, 210, 150, 20) | `onDone` |
| Cancel | (`cx + 4`, 210, 150, 20) | `onCancel` (close) |

`init()` creates the message box, calls `updateMode(mode)`, then creates the mode button, Done and Cancel. Initial focus: the message box (when it exists; else the default). Drawing: the base pass (all widgets), the title, then when the mode is not START the label `test_block.message` ("Message:") at (`cx - 153`, 70) colour `0xFFA0A0A0`; then ALWAYS the mode's detailed text `TestBlockMode.getDetailedMessage()`, the translatable `test_block.mode_info.<name>` ("Start Mode - The starting point for a test", "Log Mode - Log a message", "Fail Mode - Fail the test", "Accept Mode - Accept success for (part of) a test"), at (`cx - 153`, 174), colour `0xFFA0A0A0`.

`onDone`: `message := messageEdit.getValue()`; send Set Test Block (05c 0x3D) with the position, the mode and the message (the message is sent even when the box is hidden in START mode, with its previous text); then `onClose` (which here is `onCancel`: close). The server side is 31-6 9.2. The screen has no `keyPressed` override: Enter does nothing; Esc closes without a packet.

Worked examples (W = 320): message box x 8 to 248, y 80 to 100; mode button x 6 to 56, y 185; Done x 6, Cancel x 164 at y 210; label at (7, 70); mode text at (7, 174). Open on a block in START mode with message `""`: no message box, no "Message:" label, text "Start Mode - The starting point for a test". Click the mode button: LOG: the box appears; type `hello`; Done sends mode 1 (log) and `hello`. Click the mode button back to START and press Done: sends mode 0 with message `hello` (the hidden box keeps its text). Alt has no effect (one list). Shift-click cycles backwards: from START to ACCEPT.

## 8. `TestInstanceBlockEditScreen`

Title: the block's `getName()` ("Test Instance Block"), at (`cx`, 10), colour -1. Constant `WIDTH` = 316, `BUTTON_PADDING` = 8. Let `left` = `cx - 158` (= `W / 2 - 158`).

### 8.1 Layout functions (read)

- `exactWidgetSize(n)` = `(316 - (n - 1) * 8) / n` as a float (int numerator and denominator converted to float, float division).
- `widgetSize(n)` = `(int) exactWidgetSize(n)` (truncation).
- `widgetX(i, n)` = `(int) ((float) left + (float) i * (8.0f + exactWidgetSize(n)))` (all in float arithmetic, then truncated).

| n | `exactWidgetSize` | `widgetSize` | step `8 + exact` |
|---|---|---|---|
| 2 | 154.0 | 154 | 162.0 |
| 3 | 100.0 | 100 | 108.0 |
| 5 | 56.8 | 56 | 64.8 |

### 8.2 Widgets (created in this order)

| Widget | Rectangle | Details |
|---|---|---|
| ID box | (`left`, 40, 316, 20) | narration `test_instance_block.test_id`; max 128; initial value = the entity's test key identifier text when present, else `""`; responder: `updateTestInfo(false)`; renderable |
| Info widget | `FittingMultiLineTextWidget` (`left`, 70, 316, 8 * 9 = 72), message `""` | section 3.4; renderable |
| Size X, Y, Z | EditBoxes at (`widgetX(0, 5)`, 160), (`widgetX(1, 5)`, 160), (`widgetX(2, 5)`, 160), width `widgetSize(5)`, height 20 | narrations `structure_block.size.x` and y, z; max 15; text set afterwards by `setSize(entity.getSize())`; renderable |
| Rotation | `CycleButton` over `Rotation.values()` (NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90), `displayOnlyValue`, (`widgetX(3, 5)`, 160, `widgetSize(5)`, 20) | name `test_instance_block.rotation`; initial = the entity's rotation; value labels the literals `0`, `90`, `180`, `270` in that order; callback `updateSaveState()` |
| Include entities | on/off `CycleButton`, `displayOnlyValue`, (`widgetX(4, 5)`, 160, `widgetSize(5)`, 20), no callback | name `test_instance_block.entities`; initial = NOT `ignoreEntities()` of the entity |
| Reset | Button, (`widgetX(0, c)`, 185, `widgetSize(c)`, 20) | text `test_instance.action.reset` ("Reset and Load"); press: send RESET then close |
| Save | (`widgetX(1, c)`, 185, ...) | `test_instance.action.save` ("Save Structure"); press: send SAVE then close; field `saveButton` |
| Export | (`widgetX(2, c)`, 185, ...) | only when `SharedConstants.IS_RUNNING_IN_IDE` is true; the literal text `Export Structure`; press: send EXPORT then close; field `exportButton` |
| Run | (`widgetX(0, 3)`, 210, `widgetSize(3)`, 20) | `test_instance.action.run` ("Load and Run"); press: send RUN then close |
| Done | (`widgetX(1, 3)`, 210, ...) | `onDone`: send SET, then close |
| Cancel | (`widgetX(2, 3)`, 210, ...) | `onCancel`: close, no packet |

where `c` = 3 when `IS_RUNNING_IN_IDE` else 2. `IS_RUNNING_IN_IDE` is a plain public static non-final boolean field of `SharedConstants` (read). All 11383 classes of the jar were disassembled and searched for the field: it is read (getstatic) in `Minecraft`, `Util`, `Commands`, `Bootstrap`, `Eula`, `GameNarrator`, `TracingExecutor` and `AccountProfileKeyPairManager`, and NO putstatic to it exists in any class of the jar (read). Nothing in the jar sets it, so the value is the JVM default false unless an external launcher sets it by reflection (inferred); the Export button is absent in a normal run (Open question 8).

After the widgets, `updateTestInfo(true)` runs.

### 8.3 Behaviour

1. `sendToServer(action)` builds Test Instance Block Action (05c 0x41) with: the entity position; the action; the optional test key = the ID box text through `Identifier.tryParse` (null gives an empty optional) mapped to a key of the `test_instance` registry; the size = the three size boxes through `parseSize` (`Integer.parseInt` then `clamp(1, 48)`, 1 on failure); the rotation button's value; and `ignoreEntities` = NOT the include-entities button's value. It returns whether a test key was present.
2. `updateTestInfo(init)`: `sendToServer(init ? INIT : QUERY)`; when it returns false (the ID box does not parse), the info widget message is set to the translatable `test_instance.description.invalid_id` ("Invalid test ID") coloured red. Then `updateSaveState()`. It runs once at the end of `init` (INIT) and after every change of the ID box (QUERY). Both actions are answered by the server with the Test Instance Block Status packet (31-6 10.4, 05b 0x81), so a typed id causes one request per change.
3. `updateSaveState()`: the Save button (and the Export button when it exists) is active only when the rotation button's value is NONE and `Identifier.tryParse(idBox) != null`.
4. Status packet (`ClientPacketListener.handleTestInstanceBlockStatus`): only when the current screen is a `TestInstanceBlockEditScreen`; calls `setStatus(text, optionalSize)`: the info message is built as an empty component; when the entity has an error message, first the translatable `test_instance.description.failed` ("Failed: %s") with an argument that is the error message coloured red, then the literal text of two line feeds; then the status text of the packet is appended; the info widget shows the result. When the packet carries a size, `setSize(size)` writes the three size boxes with `Integer.toString` of the components.
5. Keys: no override (Enter does nothing; Esc closes through `Screen.onClose`, no packet).
6. Drawing: base pass (renderable widgets), title at (`cx`, 10), labels colour `0xFFA0A0A0`: `test_instance_block.test_id` ("Test Instance ID") at (`left`, 30), `test_instance_block.size` ("Test Structure Size") at (`left`, 150), `test_instance_block.rotation` ("Rotation:") at (rotation button x, 150), `test_instance_block.entities` ("Entities:") at (include entities button x, 150).

### 8.4 Worked examples (W = 320, `left` = 2, no IDE)

1. ID box x 2 to 318, y 40 to 60; info text area x 2, y 70, 316 x 72 (inner text width 308); size boxes (2, 160), (66, 160), (131, 160) each 56 wide (`2 + 64.8 = 66.8` truncates to 66; `2 + 129.6 = 131.6` to 131); rotation button (196, 160); include entities (261, 160); Reset (2, 185, 154 wide), Save (164, 185); Run (2, 210, 100 wide), Done (110, 210), Cancel (218, 210).
2. With IDE (c = 3): Reset (2, 185, 100), Save (110, 185), Export (218, 185).
3. ID box text `minecraft:my_test`: parse succeeds; each keystroke after the first valid parse sends QUERY. Text `Bad Id`: `tryParse` fails; INIT or QUERY is not meaningful, the packet is still sent with an empty test (the packet is built before the return value is checked), the info text turns red "Invalid test ID", Save is greyed.
4. Rotation set to "90": Save is greyed (needs NONE); Reset, Run and Done stay active (they have no such rule).
5. Typing `0` in a size box and Done: `parseSize(0)` gives clamp to 1. Typing `99` gives 48; typing `x` gives 1.
6. Server replies status text "Function: foo" with size (3, 3, 3) while the entity has error "boom": info text is `Failed: boom` (the word after the colon red), two line feeds, then `Function: foo`; the size boxes show 3, 3, 3.

## 9. Validation

A reimplementation passes when all of the following hold.

| # | Check | Expected |
|---|---|---|
| 1 | Open a command block screen, send no data | Done and four buttons greyed; default texts "Impulse", "Unconditional", "Needs Redstone"; Enter sends a packet (mode 2, flags 0, command `""`) |
| 2 | Deliver a command block Block Entity Data packet while the screen is open | text fields and four buttons updated, controls enabled; no callbacks fire |
| 3 | Command block flags | track output 0x01, conditional 0x02, automatic 0x04 |
| 4 | Minecart screen | previous row at y 150; no mode buttons; sends 0x38 with id, text and the track flag; server order of checks as 4.3 |
| 5 | Structure block visible sets | exactly the table of 5.3 for each mode; DATA hides the name box |
| 6 | Structure block closing | Done, SAVE, LOAD and DETECT each send one packet and close; Esc and Cancel restore seven values and send nothing |
| 7 | Structure offsets and sizes | typed values go through the low byte then the decoder clamp (5.9 example 2) |
| 8 | Name filter | uppercase refused; colon once; slash only after the colon index (5.4) |
| 9 | Jigsaw validity | Done and Generate follow the three identifier boxes only; Generate sends 0x3B then 0x1B |
| 10 | Jigsaw joint control | shown and enabled only for a vertical front; slider `levels` = floor(20 * value) |
| 11 | Test block | message box hidden in START; detailed text always drawn; no Enter shortcut |
| 12 | Test instance | layout of 8.4 for W = 320; Save needs rotation NONE and a valid id; QUERY on every id change; status packet text as 8.3 point 4 |
| 13 | `CycleButton` | click +1, Shift-click -1, wheel up -1, wheel down +1; `setValue` fires no callback; Alt swaps the structure mode list |
| 14 | Widget positions for W = 321 | `cx` = 160, `left` = 2: identical to W = 320 |

## Open questions

1. Whether any of the six screens overrides `isPauseScreen` or `shouldCloseOnEsc` was not checked beyond the methods read in each class (none was found in the six classes); the base-class defaults (`Screen`) are those of 40-1 section 5.7 and are assumed here (inferred).
2. The cursor on-off duty of `TextCursorUtils.isCursorVisible` (only the 300 ms interval constant was read) and the exact appearance of the insert bar and the append underscore.
3. The text width of the arrow glyphs in `mirror.left_right`, `mirror.front_back` and the other non-ASCII language texts, and whether the default bitmap font has those glyphs (14 and 12 section 5.10 hold the font rules; not traced for these characters).
4. General `EditBox` internals beyond section 3.1: word boundary rules (`getWordPosition`), selection drawing and highlight colours, horizontal scrolling (`scrollTo`, `displayPos`), mouse selection and double-click, IME pre-edit overlay, hint text, suggestion ghost text, `formatters`, the `setSuggestion` use by `CommandSuggestions`.
5. The number grammars of `Integer.parseInt`, `Float.valueOf` and `Long.valueOf` (accepted signs, whitespace, hexadecimal and exponent forms, `NaN` and `Infinity`) are those of the Java standard library and were not read in this round (recalled, not verified); the decimal-format rounding of `0.0###` (half-even) is likewise recalled, not verified.
6. `StructureBlockEditScreen.resize` followed by Cancel: the `initial*` values are re-read from the entity in the new `init` (read order), but whether `Screen.resize` calls `init` after the old widgets were mutated in a way that changes this was not traced further.
7. `JigsawBlockEditScreen` slider after `resize` (handle at 0, label at the old level) is read from the code order; not confirmed by any other class.
8. The value of `SharedConstants.IS_RUNNING_IN_IDE` in a normal client run: searched all classes of the jar (including `Minecraft` and the launcher-side `net.minecraft` classes) for a putstatic to the field and found none (read); the value is therefore false unless an external launcher or agent sets it, which cannot be seen in the jar (inferred), so the Export button is absent.
9. `Tooltip.create` timing and drawing for the jigsaw priority box tooltips (delay, wrapping width, background): only the attachment of the tooltips was read.
10. `ByteBuf.writeByte(int)` keeps only the low 8 bits: a Netty library behaviour outside the jar's own classes (recalled, not verified); the packet's use of `writeByte` / `readByte` and the clamps were read (5.6). The folding examples in 5.9 depend on this one fact.
11. `CommandSuggestions` internals under the parameters of 3.5 (list placement with `anchorToBottom` false, the 7-line limit drawing, `fillColor` use) are not specified; 15 sections 3.6 and 14.5 hold the chat-screen rules only.
12. Whether the Block Entity Data packet that reaches an open `CommandBlockEditScreen` for a DIFFERENT command block position is applied to the screen (the check reads the current screen and the entity type, not the position): the code shows no position comparison (read), but the effect on a screen of another block was not traced.
13. Focus order and narration order of the widgets in each screen (derived from the order of `addWidget` and `addRenderableWidget` calls given here) and the rules by which `Screen` walks them were not traced.
14. `FittingMultiLineTextWidget` scroll bar width, scroll rate and background sprite names (`AbstractScrollArea`, 40-8 section 13 holds the scroll bar constants of another widget); the visible line count of the 72-pixel info box is therefore only bounded here: inner height 64 pixels holds 7 full lines of 9 pixels.
15. Pixel-level text box details (open questions 2 and 4: cursor blink duty, word boundaries, scrolling, selection colours) are needed by every screen here and are left for a later clean-room round; to be ticketed (CC-0001 follow-up) before the client implements text boxes.
16. Out of scope for this part and belonging to other rounds: the `structure_block.hover.*` tooltip keys (en_us has `corner`, `data`, `load`, `save`, each "Name: %s"; existence read, use not traced); the `test_instance.description.*` keys other than `invalid_id` and `failed` (`batch`, `dimension`, `function`, `structure`, `type`, `no_test`, existence read, built server-side, not traced); whether a client screen exists for the spawner block (key `advMode.notEnabled.spawner` exists, not checked); `Tooltip` timing (question 9).
17. `docs/protocol/README.md` has no Documents-table row for this file (`40-menus-x1-continuation`) nor for any 40-N part, and its scope sentence does not mention menus (grep for `40-menus` and `menus` found nothing). The orchestrator or reader with README access must add the rows for 40-1 to 40-8 and 40-menus-x1-continuation and update the scope sentence; not done here by instruction.
18. Section 3.1 rule 5 and Open questions 2, 4 and 15: only the 300 ms cursor interval and the EditBox colours -2039584 and -9408400 were read; cursor blink duty, word boundaries, selection colours and scrolling are required by every screen here and must be supplied by a later round before a client can implement the text boxes.
