# 40-9 Menus and screens, part 9: block editor screens (command block, minecart command block, structure block, jigsaw block, test block)

| Item | Value |
|---|---|
| Covers | An independent second reading of the five operator editor screens `CommandBlockEditScreen` and `MinecartCommandBlockEditScreen` (base `AbstractCommandBlockEditScreen`), `StructureBlockEditScreen`, `JigsawBlockEditScreen` and `TestBlockEditScreen`: how each is opened and who may open it, every field with its limit, every mode and button with its position, the packet each one sends and when, the permission rules on both sides, the server-side handling (summary with pointers), and the close, cancel and resize rules. It also lists what this reading adds to, and where it agrees with, 40-x1. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`; protocol 777, data version 5023). Checked with `shasum -a 256` at the start of this round. |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the six screen classes and their inner classes, `LocalPlayer`, `Player`, `ServerPlayer`, `ClientPacketListener`, `ServerGamePacketListenerImpl`, `Screen`, `CycleButton`, `StructureMode`, `TestBlockMode`, `Mirror`, `JointType`, `Mth`, and the six `Serverbound*` packet classes; `unzip -p` for `assets/minecraft/lang/en_us.json`. No execution. |
| Evidence rule | Every number, key, ordering and rule below was read from the artifact in this round. "(inferred)" marks a deduction from the shape of read code. "(recalled, not verified)" marks a statement not read; each is repeated in Open questions. |
| Round | RS14, part 9 (design map `docs/design/README.md` GAP-19). Standard Minecraft content is the target (ticket CC-0001). |
| Relationship to 40-x1 | `40-menus-x1-continuation.md` (cited as 40-x1) already specifies these screens, and also `TestInstanceBlockEditScreen`. This part was written without relying on 40-x1: every position, limit, key and packet field in sections 4 to 8 was read again from the jar, and each matched 40-x1 (section 9 lists the checks). 40-x1 remains the place for the generic widgets (`EditBox`, `CycleButton`, slider, `CommandSuggestions`) and for the test instance block screen; this part is the protocol, permission and server-handling view plus a compact table per screen, and section 9 holds what is new. An implementer needs both only when the table here is not enough. |
| Siblings (not repeated) | Server side and entity state of the five blocks and the minecart: 31-6 (command block 2 to 5, structure block 6, jigsaw 8, test block 9, operator rules 11) and 44-8 (minecart synchronized data). Wire layouts: 05c ids 0x1B, 0x37, 0x38, 0x3B, 0x3C, 0x3D; 05a id 6 (Block Entity Data). Permission sets and the event ids that deliver them: 15 section 2.2. Screen model, Escape, Tab and pause rules: 40-1 section 5.7; key predicates and the text-input widgets used by the book editors: 40-8. Text width, shadow and font: 12 section 5.10. Identifier grammar: 23 section 1. Command suggestion display: 15 sections 3.6 and 14.5. |

Conventions: coordinates are GUI-scaled pixels (12 section 5.1); `W` and `H` are the scaled screen width and height; `cx` = `W / 2` with Java integer division. "Label" is a text draw in colour `0xFFA0A0A0` (the int -6250336, read at every label call) with shadow (40-8 section 6.3 step 2). "Title" is the 5-argument centred text in colour -1, drawn at (`cx`, 10) unless stated. "Button" is a 20-pixel-high button. "Cycle" is a `CycleButton` (40-x1 3.2): a click cycles by +1, Shift-click by -1, the wheel up by -1 and down by +1, over the value list (read in `CycleButton.onPress`, `cycleValue`, `mouseScrolled`).

## 1. Overview

| Screen | Entity it edits (client copy) | Sends | When |
|---|---|---|---|
| `CommandBlockEditScreen` | `CommandBlockEntity` | 05c 0x37 Set Command Block | Done, Enter |
| `MinecartCommandBlockEditScreen` | `MinecartCommandBlock` entity | 05c 0x38 Set Command Minecart | Done, Enter |
| `StructureBlockEditScreen` | `StructureBlockEntity` | 05c 0x3C Set Structure Block | Done, Enter (UPDATE_DATA); SAVE, LOAD, DETECT buttons |
| `JigsawBlockEditScreen` | `JigsawBlockEntity` | 05c 0x3B Set Jigsaw Block; Generate also sends 05c 0x1B Jigsaw Generate | Done, Enter; Generate |
| `TestBlockEditScreen` | copies position, mode and message once | 05c 0x3D Set Test Block | Done only |

None of the five is opened by a packet, none uses a menu or container id, and none sends a packet when it is cancelled. All five extend `Screen` (the two command screens through `AbstractCommandBlockEditScreen`) and implement no interface (class headers read), and all return true from `isInGameUi`.

## 2. Opening, and who may open

### 2.1 Opening (read: `LocalPlayer.open*`, the block classes, `MinecartCommandBlock.interact`)

`Player` declares `openCommandBlock`, `openMinecartCommandBlock`, `openStructureBlock`, `openJigsawBlock`, `openTestBlock` (and `openTestInstanceBlock`) as methods that do nothing; only `LocalPlayer` overrides them, each pushing the matching screen with the entity as its only argument. `ServerPlayer` overrides only `openCommandBlock`: it sends one Block Entity Data packet (05a id 6) built from the block entity's update tag (31-6 5.2) and nothing else.

| Trigger | Condition (both sides run the same use method; the screen opens on the client side) |
|---|---|
| `CommandBlock.useWithoutItem` | a `CommandBlockEntity` exists at the position AND `player.canUseGameMasterBlocks()`; result `SUCCESS`, otherwise `PASS` |
| `MinecartCommandBlock.interact` | `canUseGameMasterBlocks()`, else `PASS`; on a client level `openMinecartCommandBlock`; result `SUCCESS`. Nothing is sent: command text and last output are in the entity's synchronized data |
| `StructureBlockEntity.usedBy`, `JigsawBlock.useWithoutItem`, `TestBlock.useWithoutItem` | entity present and `canUseGameMasterBlocks()`; on a client level the matching `open*`; `SUCCESS` when the screen was requested, else `PASS` (31-6 6.7, 8.2, 9.2) |

Consequence: a server cannot open or refresh these screens by sending a packet, except the command block screen, which refreshes itself when a Block Entity Data packet arrives (section 4.3). For the structure, jigsaw and test blocks the screen shows whatever the client's copy of the entity holds when it is opened (from the chunk packet's block entity list or an earlier Block Entity Data packet, 31-1); the next Done writes those values back.

### 2.2 The permission rule (read)

`Player.canUseGameMasterBlocks()` is true when `abilities.instabuild` is true AND `permissions()` holds `Permissions.COMMANDS_GAMEMASTER`. The base `Player.permissions()` returns the empty set; `LocalPlayer.permissions()` returns a stored set. So on the client both conditions are known: `instabuild` is part of the player's abilities (set from the abilities packet of 05a; not traced here, inferred) and the permission set comes from the entity event described next.

`LocalPlayer.handleEntityEvent` handles the event ids 24 to 28 (a `tableswitch` over exactly that range, read) by storing the permission set: 24 the empty set, 25 `LevelBasedPermissionSet.MODERATOR`, 26 `GAMEMASTER`, 27 `ADMIN`, 28 `OWNER`. 15 section 2.2 gives the same mapping as "24 + level"; the level numbers 0 to 4 are taken from that document (inferred here). `setPermissions` compares the old and new "has gamemaster" values and, only when they differ, tells the current screen if it implements `HasGamemasterPermissionReaction`. None of the five screens here implements it (section 1), so a screen that is already open stays open after the player loses the right; the server then rejects what it sends (2.3).

A player who is not in a game mode with infinite materials (survival, adventure, spectator) or who has permission below level 2 never opens any of these screens: the use methods answer `PASS`.

### 2.3 Server-side checks (read in `ServerGamePacketListenerImpl`)

Every handler begins with the same test, `ServerPlayer.canUseGameMasterBlocks()` (the same method, evaluated on the server's own copy of the abilities and permissions):

| Handler | Packet | On failure |
|---|---|---|
| `handleSetCommandBlock` | 0x37 | sends the system message `advMode.notAllowed` ("Must be an opped player in creative mode") and stops |
| `handleSetCommandMinecart` | 0x38 | the same message, then stops |
| `handleSetStructureBlock`, `handleSetJigsawBlock`, `handleJigsawGenerate`, `handleSetTestBlock` | 0x3C, 0x3B, 0x1B, 0x3D | returns silently |

After the permission test each handler needs the target to exist and be of the right type (a block entity of the right class at the position, or for the minecart the entity id resolving to a command block minecart), else it returns silently. The effects are in 31-6 (5.1 for 0x37, 6.7 for 0x3C, 8.2 for 0x3B and 0x1B, 9.2 for 0x3D) and in 40-x1 4.3 (0x38). No distance test was seen in the first instructions of these handlers (only the permission test and the entity checks were read in this round, inferred for the rest; the full handler bodies are in 31-6).

## 3. Rules shared by the five screens

| Rule | Behaviour (read) |
|---|---|
| Escape | `Screen.keyPressed` calls `onClose` when the key is Escape and `shouldCloseOnEsc` (true; none of the five overrides it). `onClose` of the structure, jigsaw and test screens is their own `onCancel`; for the command screens it is the base `Screen.onClose`, which sets the screen to none. No packet in any case |
| Cancel button | the same as Escape |
| Enter | `Screen.keyPressed` runs first (it gives the focused widget the key; a text box does not take Enter), then, when the event is a confirmation key, `onDone`. Command, structure and jigsaw screens do this; the jigsaw screen only when Done is active; the test block screen has no `keyPressed` override, so Enter does nothing there. The command and structure screens do not test whether Done is enabled |
| Pause | `Screen.isPauseScreen` returns true and none of the five overrides it, so an integrated single-player game is paused while one is open (the pause itself is the 40-1 section 5.7 rule) |
| Text box limits | the box limit is applied by the box when typing or pasting (40-x1 3.1), and is independent of the wire limit (section 8) |
| Resize | command, structure and jigsaw screens override `resize` to save and restore their texts (sections 4.4, 5.6, 6.5). The test block screen does not: it inherits `Screen.resize` (sets the new width and height, then `repositionElements`, which is `rebuildWidgets`: clear widgets, clear focus, `init`, set initial focus), so the message box is rebuilt from the `message` field, which only Done writes (section 7) |

## 4. Command block screens

### 4.1 Shared base (`AbstractCommandBlockEditScreen`)

Title: none (the narrator's empty title); the screen draws the label `advMode.setCommand` ("Set Console Command for Block") centred at (`cx`, 20) in colour -1.

| Widget | Rectangle | Rules |
|---|---|---|
| Command box | (`cx - 150`, 50, 300, 20) | maximum 32500 characters (read, `setMaxLength(32500)`); responder refreshes the suggestions; initial focus; label `advMode.command` ("Console Command") at (`cx - 149`, 40) |
| Previous-output box | (`cx - 150`, `previousY`, 276, 20) | maximum 32500; not editable; value `"-"` before `updatePreviousOutput`; label `advMode.previousOutput` at (`cx - 149`, `previousY - 10`); both drawn only when the value is not empty |
| Track-output cycle | (`cx + 130`, `previousY`, 20, 20) | boolean cycle with the texts "O" for true and "X" for false (literal), value only, name `advMode.trackOutput`; initial `isTrackOutput()`; each change calls `setTrackOutput` on the client's shared block object at once and then refreshes the previous-output box |
| Done | (`cx - 154`, `H / 4 + 132`, 150, 20) | `gui.done`; `onDone` |
| Cancel | (`cx + 4`, `H / 4 + 132`, 150, 20) | `gui.cancel`; `onClose` |

`previousY` is 135 for the block screen and 150 for the minecart screen (`getPreviousY`). The previous-output label sits at `previousY - 10` because the code evaluates `75 + (5 x 9 + 1 + previousY - 135) + 4` (read: line height 9).

The suggestions object is built with `commandsOnly` true, `onlyShowIfCursorPastError` true, line start offset 0, line limit 7, not anchored to the bottom, fill colour -2147483648 (`0x80000000`), then `setAllowSuggestions(true)` and `updateCommandInfo()` (40-x1 3.5). Keys, mouse clicks and the wheel go to the suggestions first; only then to `Screen`.

`updatePreviousOutput(track)`: the box value is the last output's plain text when `track` is true, else `"-"`. `onDone`: send (4.2 or 4.5), then if `isTrackOutput()` is false call `setLastOutput(null)` on the client copy, then close. `tick`: when the shared block object reports `isValid()` false (block entity removed, or minecart entity removed) the screen closes itself with no packet.

### 4.2 `CommandBlockEditScreen` (the block)

Model fields in the constructor: `mode` = REDSTONE, `conditional` = false, `autoexec` = false. Three more cycles at y 165, 100 x 20 each, created after the track-output cycle:

| Cycle | x | Values (order) | Label of a value | Name |
|---|---|---|---|---|
| mode | `cx - 154` | `CommandBlockEntity.Mode` SEQUENCE (0), AUTO (1), REDSTONE (2), the order of `Mode.values()` and of the wire ids | `advMode.mode.sequence` "Chain", `advMode.mode.auto` "Repeat", `advMode.mode.redstone` "Impulse" | `advMode.mode` |
| type | `cx - 50` | true, false | true `advMode.mode.conditional` "Conditional", false `advMode.mode.unconditional` "Unconditional" | `advMode.type` |
| trigger | `cx + 54` | true, false | true `advMode.mode.autoexec.bat` "Always Active", false `advMode.mode.redstoneTriggered` "Needs Redstone" | `advMode.triggering` |

A change in one of the three stores into the screen field only; nothing reaches the entity.

`init` runs the base, then `enableControls(false)`: Done, the track-output cycle and the three cycles above become inactive; Cancel and the command box stay active.

### 4.3 Refresh and enabling

`ClientPacketListener.handleBlockEntityData` loads the packet's tag into the client's block entity of that type and position, then, when the loaded entity is a `CommandBlockEntity` AND the current screen is a `CommandBlockEditScreen`, calls `updateGui()` on that screen (read: the test is on the entity class and the screen class; it does not compare positions). `updateGui` always reads the screen's own entity (`autoCommandBlock`), not the entity that arrived, so a packet for a different command block simply refreshes the screen from its own entity again. `updateGui` steps: set the command box to the entity's command; read track output, mode, conditional (`CommandBlockEntity.isConditional`) and automatic (`isAutomatic`); set the four cycles with `setValue` (which does not fire their callbacks); refresh the previous-output box; `enableControls(true)`.

`resize` calls the base `resize` (4.4) and then `enableControls(true)`: after any window resize the controls are enabled even if no data has arrived.

### 4.4 Base `resize`

The base saves the command text, calls `init(width, height)`, restores the text with `setValue`, and refreshes the suggestions. The model fields keep mode, conditional and automatic, so the rebuilt cycles show them.

### 4.5 `MinecartCommandBlockEditScreen`

No extra controls; all controls enabled from the start. After the base `init` it sets the command box to `getCommandBlock().getCommand()` (the minecart's command text, already on the client). It never calls an `updateGui`. `populateAndSendPacket` sends 05c 0x38 (section 6). The server steps are in 40-x1 4.3 (command, track output, last output cleared when not tracking, `onUpdated` when command blocks are enabled, the feedback message `advMode.setCommand.success` or `advMode.setCommand.disabled` when the text is not empty).

## 5. `StructureBlockEditScreen`

Title: the translated structure block name (`block.minecraft.structure_block`, "Structure Block") at (`cx`, 10). The screen copies the entity's mirror, rotation, mode, ignore-entities, strict, show-air and show-bounding-box into `initial*` fields at every `init`. All button and cycle controls change the entity at once (so the in-world bounding box reacts); the ten text boxes are not written to the entity.

### 5.1 Widgets (creation order)

| Widget | Rectangle | Notes |
|---|---|---|
| Done, Cancel | (`cx - 154`, 210, 150, 20), (`cx + 4`, 210, 150, 20) | Done = `onDone`; Cancel = `onCancel` |
| SAVE | (`cx + 104`, 185, 50, 20) | text "SAVE" (`structure_block.button.save`); when the entity mode is SAVE: send SAVE_AREA, then close |
| LOAD | (`cx + 104`, 185, 50, 20) | "LOAD"; when the mode is LOAD: send LOAD_AREA, then close |
| Mode cycle | (`cx - 154`, 185, 50, 20) | default list SAVE, LOAD, CORNER; list while Alt is held SAVE, LOAD, CORNER, DATA (the static `DEFAULT_MODES` is all modes except DATA); label `structure_block.mode.<save/load/corner/data>`; name literal `MODE`; callback `setMode` on the entity and `updateMode` |
| DETECT | (`cx + 104`, 120, 50, 20) | "DETECT"; when the mode is SAVE: send SCAN_AREA, then close |
| Include entities | on/off cycle (`cx + 104`, 160, 50, 20) | shows `NOT ignoreEntities`; callback `setIgnoreEntities(NOT value)` |
| Strict | on/off cycle (`cx + 104`, 120, 50, 20) | `setStrict` |
| Mirror | cycle (`cx - 20`, 185, 40, 20) | values NONE, LEFT_RIGHT, FRONT_BACK; label `mirror.<none/left_right/front_back>` (a bar, a left-right arrow pair and an up-down arrow pair, texts in `en_us.json`; 40-x1 5.2 lists the code points); `setMirror` |
| Show air | on/off cycle (`cx + 104`, 80, 50, 20) | `setShowAir` |
| Show bounding box | on/off cycle (`cx + 104`, 80, 50, 20) | `setShowBoundingBox` |
| Rotation 0, 90, 180, 270 | buttons 40 x 20 at y 185, x = `cx - 102`, `cx - 61`, `cx + 21`, `cx + 62` | literal texts "0", "90", "180", "270"; set NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90 on the entity; then the button for the entity's current rotation becomes inactive and the others active |
| Name box | (`cx - 152`, 40, 300, 20) | max 128; typed characters filtered (5.3) |
| Position X, Y, Z | (`cx - 152`, 80), (`cx - 72`, 80), (`cx + 8`, 80), each 80 x 20 | max 15; initial `Integer.toString` of the entity's offset |
| Size X, Y, Z | (`cx - 152`, 120), (`cx - 72`, 120), (`cx + 8`, 120), each 80 x 20 | max 15 |
| Integrity box | (`cx - 152`, 120, 80, 20) | max 15; initial `DecimalFormat("0.0###")` (root locale) of the entity's integrity |
| Seed box | (`cx - 72`, 120, 80, 20) | max 31; initial `Long.toString` |
| Custom data box | (`cx - 152`, 120, 240, 20) | max 128; initial the entity's metadata |

After creation: `updateDirectionButtons()`, then `updateMode(initialMode)`. Initial focus: the name box. The boxes use `addWidget` (the screen draws them) and the other controls `addRenderableWidget`.

### 5.2 Visibility by mode (`updateMode`)

Everything starts hidden; then:

| Mode | Shown |
|---|---|
| SAVE | name, position, size; SAVE, DETECT, include entities, show air |
| LOAD | name, position, integrity, seed; LOAD, include entities, strict, mirror, the four rotation buttons, show bounding box |
| CORNER | name |
| DATA | custom data box only |

Mode, Done and Cancel are always shown. The labels drawn follow the same table (all in colour `0xFFA0A0A0`): name label at (`cx - 153`, 30) when the mode is not DATA; position label at (`cx - 153`, 70) and the right-aligned include-entities label (right edge `cx + 154`) at y 150 for SAVE and LOAD; size label (`cx - 153`, 110), right-aligned detect label at y 110 and right-aligned show-air label at y 70 for SAVE; integrity label (`cx - 153`, 110), right-aligned strict label at y 110 and right-aligned show-bounding-box label at y 70 for LOAD; custom data label (`cx - 153`, 110) for DATA; and always the mode description (`structure_block.mode_info.<name>`) at (`cx - 153`, 174). The drawn mode is the entity's, so a mode change shows at once.

### 5.3 Name filter

Only typing is filtered (`charTyped` of a box subclass calling `Screen.isValidCharacterForName(text, codepoint, cursor)`); paste is not. With `colon` and `slash` the first index of `:` and `/` in the current text (-1 when absent): `:` is accepted when `colon` is -1 and (`slash` is -1 or `cursor <= slash`); `/` is accepted when `cursor > colon`; every other code point is accepted only when it is `_`, `-`, `.`, `a` to `z` or `0` to `9`. Upper case is refused.

### 5.4 Packet source (`sendToServer(type)`)

All fields are read at the moment of sending, from the boxes and the entity: location = entity position; update type = the argument; mode, mirror, rotation, ignore-entities, strict, show-air and show-bounding-box = the entity's current values (not `initial*`); name = name box text; offset and size = the six boxes through `parseCoordinate` (`Integer.parseInt`, 0 on a number format error); metadata = custom data box text (note: the name goes in the Name field and the data box in the Metadata field); integrity = `parseIntegrity` (`Float.valueOf`, 1.0 on error); seed = `parseSeed` (`Long.valueOf`, 0 on error). Hidden boxes are sent with whatever they hold. The method always returns true and `onDone` closes the screen after it.

### 5.5 Cancel

`onCancel` writes the seven `initial*` values back into the entity (mirror, rotation, mode, ignore-entities, strict, show-air, show-bounding-box), closes, and sends nothing. The text boxes never reached the entity.

### 5.6 `resize`

Saves the ten values of the boxes read in order, calls `init(width, height)`, restores the boxes with `setValue`. Because `init` re-reads the `initial*` values from the entity (which the buttons already changed), a Cancel after a resize restores the state as of the resize, not as of the first open (inferred from the order, as in 40-x1 Open question 6).

## 6. `JigsawBlockEditScreen`

No title. Fields: `levels` = 0, `keepJigsaws` = true, `joint` = the entity's joint.

| Widget | Rectangle | Notes |
|---|---|---|
| Pool box | (`cx - 153`, 20, 300, 20) | max 128; value the entity pool key's identifier text; initial focus; label "Target Pool:" at (`cx - 153`, 10) |
| Name box | (`cx - 153`, 55, 300, 20) | max 128; label "Name:" at y 45 |
| Target box | (`cx - 153`, 90, 300, 20) | max 128; label "Target Name:" at y 80 |
| Final state box | (`cx - 153`, 125, 300, 20) | max 256; label "Turns into:" at y 115; no validation |
| Selection priority box | (`cx - 153`, 160, 98, 20) | max 3; tooltip `jigsaw_block.selection_priority.tooltip`; label "Selection Priority:" at y 150 |
| Placement priority box | (`cx - 50`, 160, 98, 20) | max 3; tooltip `jigsaw_block.placement_priority.tooltip`; label "Placement Priority:" at (`cx - 50`, 150) |
| Joint cycle | (`cx + 54`, 160, 100, 20) | ROLLABLE, ALIGNED (value label `jigsaw_block.joint.<name>`); active AND visible only when the block state's front direction is vertical (the label "Joint Type:" at (`cx + 53`, 150) is also drawn only then) |
| Levels slider | (`cx - 154`, 185, 100, 20) | slider value starts at 0.0; applying a value sets `levels = floor(clampedLerp(value, 0, 20))` (the argument order of `Mth.clampedLerp` is delta, start, end, read), so 0 to 20; its label is `jigsaw_block.levels` ("Levels: %s") with `levels` |
| Keep jigsaws | on/off cycle with name and value (`cx - 50`, 185, 100, 20) | shows "Keep Jigsaws" with its on or off text |
| Generate | (`cx + 54`, 185, 100, 20) | `onDone` then `sendGenerate` |
| Done, Cancel | (`cx - 154`, 210, 150, 20), (`cx + 4`, 210, 150, 20) | |

Validity: Done and Generate are active only while the name, target and pool boxes each parse with `Identifier.tryParse` (a text without a colon is in the default namespace; grammar in 23 section 1). The responders of the three boxes re-evaluate it; `init` evaluates it once at the end. Enter calls `onDone` only while Done is active.

`onDone` sends 0x3B (name, target and pool through `Identifier.parse`, which throws on bad text and is therefore only reachable while valid; final state text; joint; selection priority and placement priority each through `Integer.parseInt`, 0 on error) and then closes. Generate runs `onDone` and then sends 0x1B (position, `levels`, `keepJigsaws`), so the server receives Set Jigsaw Block first, then Jigsaw Generate (31-6 8.2).

### 6.5 `resize`

Saves the six texts, `levels` and `joint`, re-inits, restores them (and the joint cycle with `setValue`). The slider is rebuilt at value 0.0 while its label reads the restored `levels`: after a resize the handle is at the left end and the label shows the old level.

## 7. `TestBlockEditScreen`

Title: the translated test block name (`block.minecraft.test_block`, "Test Block") at (`cx`, 10). The constructor copies position, mode and message from the entity once. `MODES` = START, LOG, FAIL, ACCEPT in `values()` order (wire ids 0 to 3).

| Widget | Rectangle | Notes |
|---|---|---|
| Message box | (`cx - 152`, 80, 240, 20) | added as a renderable widget; max 128; initial the copied message; visible only when the mode is not START; label "Message:" at (`cx - 153`, 70) drawn only when the mode is not START |
| Mode cycle | (`cx - 154`, 185, 50, 20) | list MODES; label `test_block.mode.<name>`; name = the title; each change stores the mode in the screen and shows or hides the message box |
| Done, Cancel | (`cx - 154`, 210, 150, 20), (`cx + 4`, 210, 150, 20) | Done stores the box text in `message`, sends 0x3D, then calls `onClose`, which is `onCancel` (close) |

The mode description `test_block.mode_info.<name>` is always drawn at (`cx - 153`, 174). The message is sent whatever the mode, with the hidden box's text when the mode is START. There is no `keyPressed` override and no `resize` override: Enter does nothing, and a resize recreates the message box from the `message` field, which holds the text at open (or at the last Done), so text typed before the resize is lost while the chosen mode is kept.

## 8. Packets sent (source and limits)

| Packet | Fields in wire order, source on the screen | Screen limit | Wire limit (read in the packet class) |
|---|---|---|---|
| 0x37 Set Command Block | Position; Command (box text); Mode (VarInt ordinal of `Mode`: SEQUENCE 0, AUTO 1, REDSTONE 2); Flags (byte: 0x01 track output from the shared block, 0x02 conditional field, 0x04 automatic field) | 32500 | `readUtf` default 32767 (05c) |
| 0x38 Set Command Minecart | Entity id (VarInt); Command; Track output (boolean) | 32500 | `readUtf` default |
| 0x3C Set Structure Block | Position; Update type (VarInt ordinal: UPDATE_DATA 0, SAVE_AREA 1, LOAD_AREA 2, SCAN_AREA 3); Mode (SAVE 0, LOAD 1, CORNER 2, DATA 3); Name; Offset X, Y, Z and Size X, Y, Z (one byte each; the reader reads signed bytes and clamps offsets to -48..48, sizes to 0..48); Mirror (VarInt ordinal); Rotation; Metadata; Integrity (float, clamped 0..1); Seed (VarLong); Flags (0x01 ignore entities, 0x02 show air, 0x04 show bounding box, 0x08 strict) | name 128, metadata 128, numbers 15 characters, seed 31 | name default 32767, metadata 128 (`readUtf(128)`, read) |
| 0x3B Set Jigsaw Block | Position; Name, Target, Pool (identifiers); Final state; Joint (string `rollable` or `aligned`); Selection priority (VarInt); Placement priority (VarInt) | 128 for identifiers, 256 final state, 3 for priorities | final state and joint `readUtf` default |
| 0x1B Jigsaw Generate | Position; Levels (VarInt); Keep jigsaws (boolean) | levels 0..20 | none beyond the types |
| 0x3D Set Test Block | Position; Mode (VarInt id 0..3); Message | 128 | `readUtf` default (05c) |

The screen limits are smaller than or equal to the wire limits everywhere except where a box accepts a number the byte or clamp cannot hold (typed `300` as a structure size is sent through a one-byte write; the byte arithmetic is the Netty library's, recalled, not verified, 40-x1 Open question 10).

## 9. Cross-check with 40-x1, and what is new here

Every constant in sections 4 to 7 was read from the jar and matched 40-x1 sections 4 to 7 (positions, sizes, limits 32500, 128, 15, 31, 3, 256, mode lists and orders, label y values including the include-entities label at 150 over its button at 160, the colours, the conditions of the validity and the packet sources). No numeric discrepancy was found in positions, sizes and limits (one count differs, item 8). Facts this part adds or closes:

1. `Screen.resize` is `width, height, repositionElements`, and the default `repositionElements` is `rebuildWidgets` (clear, clear focus, `init`, initial focus). The test block screen has no `resize` override, so a window resize loses the typed message text there (section 7). 40-x1 section 7 does not mention it.
2. No one of the five screens implements `HasGamemasterPermissionReaction`, so none reacts when the player loses the permission while the screen is open (section 2.2). The server-side rejections of 2.3 are then the only defence.
3. The client learns the permission level through entity events 24 to 28 on the player (section 2.2), and both `instabuild` and the gamemaster permission are required (31-6 11.1).
4. 40-x1 Open question 1 is closed for the five screens read here: `Screen.isPauseScreen` returns true and none of the five (nor the abstract base) overrides `isPauseScreen` or `shouldCloseOnEsc` (section 3). The test instance screen was not re-read.
5. 40-x1 Open question 12 is closed: `updateGui` refreshes from the screen's own entity, so a Block Entity Data packet for another command block never injects foreign data into the screen (section 4.3).
6. 40-x1 Open question 6, the call chain is read: `Screen.resize` rebuilds through `init` for screens without an override, and the three screens with an override call `init(width, height)` themselves (section 3, 5.6, 6.5).
7. Wire-level reads of the packet classes (section 8) agree with 05c: strings, VarInts, enum ordinals, byte offsets and sizes with clamps, metadata limit 128.
8. One count in 40-x1 is off: 40-x1 5.7 says the structure screen's `resize` saves and restores nine boxes; the code saves and restores ten (the name, three position, three size, integrity, seed and custom data boxes; ten `getValue` and ten `setValue` calls, and ten `addWidget` calls in `init`, read). (40-x1 5.2 also lists ten boxes in its widget table.)

## 10. Worked examples (`W = 400`, `H = 300`, so `cx` = 200)

1. Command block screen: command box x 50 to 350, y 50 to 70; previous-output box x 50 to 326, y 135 to 155; track-output cycle x 330 to 350, y 135; mode x 46 to 146, type x 150 to 250, trigger x 254 to 354, all y 165 to 185; Done (46, 207), Cancel (204, 207) (`H / 4` = 75). Minecart screen: previous box y 150, label text y 140, no mode, type or trigger cycles.
2. Structure block in SAVE mode: name box x 48 to 348 (y 40); position boxes x 48, 128, 208 (y 80); size boxes x 48, 128, 208 (y 120); SAVE x 304 to 354 (y 185); DETECT x 304 (y 120); include entities x 304 (y 160); show air x 304 (y 80); mode cycle x 46 to 96 (y 185); Done x 46, Cancel x 204 (y 210). In LOAD mode: integrity x 48, seed x 128 (y 120); rotation buttons x 98, 139, 221, 262 (40 wide, y 185); mirror x 180 to 220.
3. Jigsaw: pool box x 47 to 347 (y 20); name y 55; target y 90; final state y 125; selection priority x 47 to 145 and placement x 150 to 248 (y 160); joint x 254 to 354 (y 160, only with a vertical front); slider x 46 to 146, keep jigsaws x 150 to 250, Generate x 254 to 354 (y 185); Done x 46, Cancel x 204 (y 210).
4. Test block: message box x 48 to 288 (y 80, only when the mode is not START); mode cycle x 46 to 96 (y 185); Done x 46, Cancel x 204 (y 210); mode text at (47, 174).
5. Command block, race: the screen opens, the Block Entity Data packet has not yet arrived (Done greyed). The player presses Enter: `onDone` sends mode 2 (REDSTONE), flags 0 and the (empty) command; the server rebuilds the block as an impulse, non-conditional command block (31-6 5.1 step 3).
6. Jigsaw Generate with pool `minecraft:bad pool`: `Identifier.tryParse` fails on the space; Done and Generate are inactive; Enter does nothing; no packet.
7. Permission: a creative player with level 1 (event id 25) uses a structure block: the use method returns `PASS` and no screen opens. The same player with level 2 (event 26) opens it. If the level drops to 1 while the screen is open, it stays open; its Done sends 0x3C and the server drops it without a message.

## 11. Validation

1. A server that wants the editors usable must: set the abilities `instabuild` (05a); send the permission as entity event 24 + level on the player's own entity; send Block Entity Data for the structure, jigsaw and test blocks via the normal update path, and for a command block only on the open call (31-6 5.2).
2. Accept, from a client with the right permission only: 0x37, 0x38, 0x3B, 0x3C, 0x3D, 0x1B; ignore silently when the entity is missing; send `advMode.notAllowed` only for 0x37 and 0x38.
3. Treat the structure packet's name and metadata as arbitrary text, the offsets and sizes as already clamped, integrity in 0 to 1.
4. Expect a jigsaw Generate packet to follow a Set Jigsaw Block packet on the same connection.

## 12. Open questions

1. `TestInstanceBlockEditScreen` (named in 40-x1 section 8) was not re-read in this round; section 9 covers only the five screens above.
2. Java number grammars for `Integer.parseInt`, `Float.valueOf` and `Long.valueOf` (signs, spaces, hexadecimal and exponent forms, `NaN`) and the half-even rounding of `DecimalFormat("0.0###")` are library behaviour, not read (recalled, not verified); the same as 40-x1 Open question 5.
3. `ByteBuf.writeByte(int)` keeping only the low 8 bits is Netty library behaviour (recalled, not verified), as in 40-x1 Open question 10.
4. The permission level numbers behind entity events 25 to 28 (1 to 4) are taken from 15 section 2.2 (inferred from the constant names `MODERATOR`, `GAMEMASTER`, `ADMIN`, `OWNER` and the 24 + level rule there); the constant values were not read here.
5. Slider keyboard step and focus behaviour of `AbstractSliderButton` are in 40-x1 3.3 and were not re-read; only `applyValue`, the initial value 0.0 and `Mth.clampedLerp`'s argument order were read here.
6. Text box internals (word boundaries, selection colours, scrolling, blink duty beyond the 300 ms interval, IME) are those of 40-x1 Open questions 2, 4 and 15 and 40-8 section 2; not traced for the single-line `EditBox`.
7. `CommandSuggestions` placement and drawing under the parameters of section 4.1 (40-x1 Open question 11).
8. Whether the mirror symbol glyphs exist in the default font (40-x1 Open question 3).
9. `docs/protocol/README.md` has no Documents-table row for this file; the orchestrator adds it (not done here by instruction).
