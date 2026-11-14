# 40-9 Menus and screens, part 9: block editor screens (command block, minecart command block, structure block, jigsaw block, test block)

| Item | Value |
|---|---|
| Covers | An independent second reading of the five operator editor screens `CommandBlockEditScreen` and `MinecartCommandBlockEditScreen` (base `AbstractCommandBlockEditScreen`), `StructureBlockEditScreen`, `JigsawBlockEditScreen` and `TestBlockEditScreen` (and, in section 7A, `TestInstanceBlockEditScreen`): how each is opened and who may open it, every field with its limit, every mode and button with its position, the packet each one sends and when, the permission rules on both sides, the server-side handling (summary with pointers), and the close, cancel and resize rules. It also lists what this reading adds to, and where it agrees with, 40-x1. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`; protocol 777, data version 5023). Checked with `shasum -a 256` at the start of this round. |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the six screen classes and their inner classes, `LocalPlayer`, `Player`, `ServerPlayer`, `ClientPacketListener`, `ServerGamePacketListenerImpl`, `Screen`, `CycleButton`, `StructureMode`, `TestBlockMode`, `Mirror`, `JointType`, `Mth`, and the six `Serverbound*` packet classes; `unzip -p` for `assets/minecraft/lang/en_us.json`. No execution. |
| Evidence rule | Every number, key, ordering and rule below was read from the artifact in this round. "(inferred)" marks a deduction from the shape of read code. "(recalled, not verified)" marks a statement not read; each is repeated in Open questions. |
| Round | RS14, part 9 (design map `docs/design/README.md` GAP-19). Standard Minecraft content is the target (ticket CC-0001). |
| Relationship to 40-x1 | `40-menus-x1-continuation.md` (cited as 40-x1) already specifies these screens, and also `TestInstanceBlockEditScreen`, which section 7A of this part now reads again. This part was written without relying on 40-x1: every position, limit, key and packet field in sections 4 to 8 was read again from the jar, and each matched 40-x1 (section 9 lists the checks). 40-x1 remains the place for the generic widgets (`EditBox`, `CycleButton`, slider, `CommandSuggestions`) and for the test instance block screen; this part is the protocol, permission and server-handling view plus a compact table per screen, and section 9 holds what is new. An implementer needs both only when the table here is not enough. |
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

## 7A. `TestInstanceBlockEditScreen` (round TIBE, a second reading of 40-x1 section 8, same artifact `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, re-checked with `shasum -a 256`)

Classes read for this section: `TestInstanceBlockEditScreen` and its synthetic switch class, `ServerboundTestInstanceBlockActionPacket` and its `Action`, `TestInstanceBlockEntity$Data` and `$Status`, `Rotation`, `Vec3i`, `ResourceKey`, `ByteBufCodecs` (the optional codec), `Screen`, `LocalPlayer.openTestInstanceBlock`, `TestInstanceBlock.useWithoutItem`, `ClientPacketListener.handleTestInstanceBlockStatus`, `ServerGamePacketListenerImpl.handleTestInstanceBlockAction`, `ClientboundTestInstanceBlockStatus`; `en_us.json` for the texts. Every constant below matched 40-x1 section 8 (positions, limits, texts); the differences and additions are in 7A.6.

### 7A.1 Opening and what it edits

| Item | Behaviour (read) |
|---|---|
| Opened by | `TestInstanceBlock.useWithoutItem`: when the block entity at the position is a `TestInstanceBlockEntity` and the player passes `canUseGameMasterBlocks` (creative plus gamemaster permission, 31-6 11.1), then on the client level it calls `Player.openTestInstanceBlock` (only `LocalPlayer` implements it: it pushes the screen) and the result is `SUCCESS` on both sides. No entity, or no permission: `PASS`, no screen. The client opens the screen itself in this call; no open-screen message from the server was involved in the path read (the client level runs `useWithoutItem` on the use click) |
| Title | the block's name, `block.minecraft.test_instance_block` = "Test Instance Block", at (`cx`, 10), colour -1 |
| Entity data edited | the `data` record of the test instance block entity (31-6 10.1 and 10.2; 31-8 10.2): `test` (optional key in the `test_instance` registry), `size` (3 ints), `rotation`, `ignore_entities`. The screen never edits `status` or `error_message`; it sends them as `cleared` and absent |
| Initial values copied once at construction/`init` | ID box = the identifier text of `test`, else empty; size boxes = `Integer.toString` of the entity size (a fresh block has size (0, 0, 0), so the boxes show `0`, `0`, `0`); rotation button = the entity's `getRotation()`, the EFFECTIVE rotation: the test definition's own rotation (NONE when no test resolves) combined with `data.rotation` through `Rotation.getRotated` (the table in 7A.3, read), not `data.rotation` alone; include-entities button = NOT `ignoreEntities()` |
| Pause, background | `isPauseScreen` is the `Screen` default (true); the screen overrides `isInGameUi` to true (also true on the structure, jigsaw and test block screens, false on the command block screen, read), so `Screen.extractBackground` calls `extractTransparentBackground` instead of the blurred panorama and menu background. That method fills the whole screen rectangle (0, 0) to (`W`, `H`) with a vertical gradient from the ARGB colour `0xC0101010` at the top (the int -1072689136, read) to `0xD0101010` at the bottom (the int -804253680, read), i.e. a near-black veil at alpha 192 rising to 208 (the gradient interpolation is the generic `fillGradient`, 12). The same background is used by every `isInGameUi` screen; 40-1 section 5.2 states the generic rule for container screens |
| Keys | no `keyPressed`, `resize` or `onClose` override: Enter does nothing; Escape closes with no packet; a resize rebuilds the screen through `init` (7A.5) |

### 7A.2 Layout (`W` = scaled width; `left` = `W / 2 - 158` with integer division)

Constants: `WIDTH` = 316, `BUTTON_PADDING` = 8. For `n` columns: `exactWidgetSize(n)` = `(316 - (n - 1) * 8) / n` in float arithmetic; `widgetSize(n)` = that truncated to int; `widgetX(i, n)` = `left + i * (8 + exactWidgetSize(n))` in float arithmetic, truncated to int (the Java `f2i` cast; the value is positive, so truncation equals floor). `c` = 3 when `SharedConstants.IS_RUNNING_IN_IDE` is true, else 2 (a plain static field, in a normal run false: 40-x1 8.2, Open question 8 there).

| n | `exactWidgetSize` | `widgetSize` | step `8 + exact` |
|---|---|---|---|
| 2 | 154.0 | 154 | 162.0 |
| 3 | 100.0 | 100 | 108.0 |
| 5 | 56.8 | 56 | 64.8 |

Widgets, in creation (and so focus and draw) order:

| # | Widget | Rectangle | Details |
|---|---|---|---|
| 1 | ID box | (`left`, 40, 316, 20) | narration `test_instance_block.test_id`; max 128; initial text as 7A.1; the responder (installed AFTER the initial text is set, so the initial text does not fire it) runs `updateTestInfo(false)` on every change |
| 2 | Info text | `FittingMultiLineTextWidget` (`left`, 70, 316, 72) (the height is 8 times the font line height 9), initial message the empty string | read-only multi-line text; a renderable widget |
| 3 to 5 | Size X, Y, Z | (`widgetX(0,5)`, 160), (`widgetX(1,5)`, 160), (`widgetX(2,5)`, 160); each `widgetSize(5)` = 56 wide, 20 high | narrations `structure_block.size.x`, `.y`, `.z`; max 15 characters each; texts set from the entity size |
| 6 | Rotation cycle | (`widgetX(3,5)`, 160, 56, 20) | `CycleButton` over `Rotation.values()` in order NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90 (wire ids 0 to 3), `displayOnlyValue` (the button shows only the value text), value texts the literals `0`, `90`, `180`, `270` in that order, initial value as 7A.1; change callback `updateSaveState` |
| 7 | Include-entities cycle | (`widgetX(4,5)`, 160, 56, 20) | on/off `CycleButton`, `displayOnlyValue` (shows the on or off text only; cycle behaviour 40-x1 3.2), no callback |
| 8 | Reset | (`widgetX(0,c)`, 185, `widgetSize(c)`, 20) | text `test_instance.action.reset` "Reset and Load" |
| 9 | Save | (`widgetX(1,c)`, 185, `widgetSize(c)`, 20) | `test_instance.action.save` "Save Structure"; kept in a field to be enabled and disabled |
| 10 | Export (only when `c` = 3) | (`widgetX(2,c)`, 185, `widgetSize(c)`, 20) | the literal text `Export Structure` (not translated) |
| 11 | Run | (`widgetX(0,3)`, 210, 100, 20) | `test_instance.action.run` "Load and Run" |
| 12 | Done | (`widgetX(1,3)`, 210, 100, 20) | `gui.done` |
| 13 | Cancel | (`widgetX(2,3)`, 210, 100, 20) | `gui.cancel` |

The screen sets no focus itself. Focus follows the generic `Screen` rule: `init(w, h)` (first time) and `rebuildWidgets` (clear widgets, clear focus, `init()`, then `setInitialFocus()`) end with `setInitialFocus()`, which does nothing unless the last input type was the keyboard; with the keyboard it moves the focus to the first focusable widget in tab order (a forward tab navigation from nothing). Which widget that is, is the first focusable child in creation order, expected to be the ID box (inferred: the widget tree's tab order was not traced). After a mouse-driven open or resize no widget has focus until clicked. This also applies to the other screens of this document.

Labels (drawn by the screen after the widgets, colour `0xFFA0A0A0`, with shadow): "Test Instance ID" (`test_instance_block.test_id`) at (`left`, 30); "Test Structure Size" (`test_instance_block.size`) at (`left`, 150); "Rotation:" (`test_instance_block.rotation`) at (rotation button x, 150); "Entities:" (`test_instance_block.entities`) at (include-entities button x, 150). The title is drawn at (`cx`, 10). The two cycle buttons have no text of their own for these words: the labels above are the only place they appear.

### 7A.3 Behaviour

| Rule | Behaviour (read) |
|---|---|
| `parseSize(text)` | `Integer.parseInt` of the box text, then clamp to 1..48; any `NumberFormatException` (empty, letters, a lone sign, a number outside the int range) gives 1. Applied to all three boxes every time a packet is built; the boxes themselves keep the typed text. Number grammar: Open question 2 |
| `sendToServer(action)` | builds one 05c 0x41 packet (7A.4) from the current widgets and sends it; returns whether the test id was present. The packet is sent even when the id is absent |
| Test id of a packet | the ID box text through `Identifier.tryParse`, which (read in `Identifier.tryBySeparator`, separator `:`) works as follows: split at the FIRST `:`; the part after it must pass `isValidPath` (every character in `a-z 0-9 _ - / .`; the empty text passes); with a colon at index 0 the namespace is `minecraft`; with a colon after index 0 the part before it must pass `isValidNamespace` (every character in `a-z 0-9 _ - .`, and the text `..` is refused; the empty prefix cannot occur here); with no colon at all the whole text must pass `isValidPath` and the namespace is `minecraft`. Any failure gives null (grammar and messages 23 section 1: namespace `[a-z0-9_.-]`, path `[a-z0-9_./-]`, as read here). So `foo` gives `minecraft:foo`; `:foo` gives `minecraft:foo`; `a:b:c` fails (the path `b:c` contains a colon); an upper-case letter or a space fails. THE EMPTY TEXT PARSES (path empty, namespace `minecraft`): the id counts as present with the key `minecraft:` and the red "Invalid test ID" text does not appear. A parsed identifier becomes a key of the `test_instance` registry |
| `updateTestInfo(init)` | sends INIT (when `init`) or QUERY, then, when the returned flag is false, sets the info text to the translation `test_instance.description.invalid_id` ("Invalid test ID") in red; then `updateSaveState`. Called once at the end of `init` (INIT) and after every change of the ID box text (QUERY): one packet per keystroke that changes the text |
| `updateSaveState` | Save (and Export when present) are active exactly when the rotation button value is NONE AND the ID box text parses with `Identifier.tryParse` (so also with the empty text). Run on `init` (through `updateTestInfo`), on each ID box change and on each rotation change. Reset, Run, Done and Cancel have no activity rule and are always active |
| Reset, Save, Export, Run | each sends its action (RESET 3, SAVE 4, EXPORT 5, RUN 6) and then sets the screen to none directly (`Gui.setScreen(null)`) |
| Done (`onDone`) | sends SET (2), then `onClose` (the `Screen` default, sets the screen to none). Done is never gated: with an invalid id it sends SET with the test absent, which clears the entity's test |
| Cancel (`onCancel`) | `onClose` only; no packet |
| Escape | `Screen.keyPressed` then `onClose`; no packet |
| Status reply | `ClientPacketListener.handleTestInstanceBlockStatus` acts only when the current screen is this screen (a status packet that arrives with no such screen is dropped). It calls `setStatus(text, optional size)` (below) |
| `setStatus(text, size)` | builds the info message as: an empty component; if the CLIENT-SIDE entity has an `error_message`, first the translation `test_instance.description.failed` ("Failed: %s") whose argument is that message in red, then the two characters line feed, line feed; then the packet's text. The info widget shows it. When the packet carries a size, the three size boxes are replaced by `Integer.toString` of its components (`setValue` on the boxes; they have no responders, so no packet follows) |
| What the server answers | 31-6 10.4: to INIT and QUERY with one 05c 0x81 packet, text = the test's description (`test_instance.description.no_test` "No such test" in red when the id does not resolve), size = present only for QUERY and only when the test resolves. The info text and the size boxes are therefore updated only by those replies |

Display note: the info widget uses the multi-line fitting widget (40-x1 3.4); its text is not scrolled by the screen.

`Rotation.getRotated(argument)` (read: a 4 by 4 table keyed by the argument and the receiver; it is addition of quarter turns modulo 4 on the ids 0 to 3). The entity's `getRotation()` is `testRotation.getRotated(data.rotation)` (receiver = the test definition's rotation, argument = the stored rotation; NONE for the receiver when no test resolves). Result by receiver (rows) and argument (columns):

| receiver \ argument | NONE | CLOCKWISE_90 | CLOCKWISE_180 | COUNTERCLOCKWISE_90 |
|---|---|---|---|---|
| NONE | NONE | CLOCKWISE_90 | CLOCKWISE_180 | COUNTERCLOCKWISE_90 |
| CLOCKWISE_90 | CLOCKWISE_90 | CLOCKWISE_180 | COUNTERCLOCKWISE_90 | NONE |
| CLOCKWISE_180 | CLOCKWISE_180 | COUNTERCLOCKWISE_90 | NONE | CLOCKWISE_90 |
| COUNTERCLOCKWISE_90 | COUNTERCLOCKWISE_90 | NONE | CLOCKWISE_90 | CLOCKWISE_180 |

With `t` the test's own rotation id and `d` the stored id: shown = `(t + d) mod 4`; a Done stores `d' = (t + d) mod 4`; the effective rotation afterwards is `(2t + d) mod 4`. Example: test rotation CLOCKWISE_90 (1), stored NONE (0): the button opens at `90`; Done stores 1 and the effective rotation becomes CLOCKWISE_180.

### 7A.4 The packet sent (05c 0x41, read in `ServerboundTestInstanceBlockActionPacket` and its stream codec)

The codec is a composite of three fields in this order: Position (the block's position), Action (VarInt id), Data (the `TestInstanceBlockEntity$Data` stream codec). `Action` ids: INIT 0, QUERY 1, SET 2, RESET 3, SAVE 4, EXPORT 5, RUN 6 (id equals ordinal; the id mapper uses the ZERO out-of-range strategy: an id outside 0..6 decodes as INIT).

`Data` codec, in order:

| # | Field | Encoding (read) |
|---|---|---|
| 1 | test | optional: a boolean (1 present, 0 absent), then when present the key through `ResourceKey.streamCodec(test_instance registry)`, which is the `Identifier` stream codec mapped to and from the key: `Identifier.STREAM_CODEC` is the UTF-8 string codec (limit 32767, the `STRING_UTF8` default) with `Identifier.parse` on read and `Identifier.toString` on write, and `toString` is always `namespace:path`. So the sent text always has the namespace: a box text `foo` is sent as `minecraft:foo`, and the empty box as `minecraft:`. The key's registry is implied by the field, not written (all read) |
| 2 | size | `Vec3i.STREAM_CODEC`: three VarInts x, y, z |
| 3 | rotation | VarInt id (NONE 0, CLOCKWISE_90 1, CLOCKWISE_180 2, COUNTERCLOCKWISE_90 3; out-of-range wraps) |
| 4 | ignore entities | boolean |
| 5 | status | VarInt id (cleared 0, running 1, finished 2; out-of-range gives 0) |
| 6 | error message | optional: a boolean, then when present a `ComponentSerialization.STREAM_CODEC` text component |

The screen fills the packet through the constructor that takes the loose values: test = the parsed id (7A.3), size = the three `parseSize` results, rotation = the rotation button value, `ignoreEntities` = NOT the include-entities button value, and it fixes status = cleared (0) and error message = absent. So each packet from this screen has, after the position and action, the bytes: test optional, three size VarInts (each 1 to 48, one byte each), rotation VarInt, a boolean, `00`, `00`.

Server validation (read in `handleTestInstanceBlockAction`): the handler requires `canUseGameMasterBlocks` and a `TestInstanceBlockEntity` at the position, otherwise it returns with no reply and no message; no distance test was seen in the instructions read. For INIT and QUERY it answers (31-6 10.4) and does not store the packet's data. For SET, RESET, SAVE, EXPORT and RUN it first stores the packet's `Data` into the entity through `set` (`setChanged`) WITHOUT any check of the size, rotation or test id (the server trusts the client's 1 to 48 clamp, read: `set` only assigns the field and marks the block changed), then performs the action, and always ends with a block update for the position (flags 3). A test id that is not in the registry is stored as sent and only fails later (INIT/QUERY description "No such test"; RUN and RESET messages 31-6 10.4).

Wire example, Done with id `foo`, size 3, 3, 3, rotation 0, include entities on (position P): P (the packed position, 05c Position type), `02` (SET), `01` (test present), `0D` `minecraft:foo` (13 characters: VarInt length then the ASCII), `03 03 03`, `00` (rotation), `00` (ignore entities false), `00` (cleared), `00` (no error message). A QUERY packet differs only in the second field (`01`).

### 7A.5 Resize

There is no `resize` override: `Screen.resize` stores the new size and runs `repositionElements`, which is `rebuildWidgets` (section 3 above). The whole widget set is created again from the ENTITY values: a typed id, typed sizes, a changed rotation and a changed include-entities state are lost (the widgets return to the entity's data), the info text returns to the empty string, and the closing `updateTestInfo(true)` sends one more INIT packet (with the entity's id, size, rotation and include-entities state). Until the reply comes, the info text is empty.

### 7A.6 Cross-check with 40-x1 section 8, and what is new

1. Every position, size, limit, text key and the layout arithmetic matched 40-x1 8.1 to 8.3. The worked examples of 40-x1 8.4 were recomputed and hold (see 7A.7).
2. New: the Reset, Save, Export and Run buttons close the screen with `Gui.setScreen(null)` directly, whereas Done uses `onClose`; both end with no screen. Cancel and Escape send nothing.
3. New: INIT and QUERY never store the packet data on the server (only SET, RESET, SAVE, EXPORT, RUN do), and the server applies no clamp to the stored data.
4. New: the initial rotation shown is the entity's effective rotation (the test definition's rotation combined with the stored one, table in 7A.3), not the stored `data.rotation`. A Done stores the shown value as `data.rotation`, so with a test whose own rotation `t` is not NONE the effective rotation changes by `t` on each Done (`(t + d)` is shown and stored, then `(2t + d)` is in effect). Read, no longer inferred.
5. New: a fresh block has size (0, 0, 0), the boxes show `0`, and a Done without editing sends 1, 1, 1 (the clamp), so the stored size changes to (1, 1, 1).
6. New: Done is always allowed. With an unparseable id (upper case, space, a second colon) it sends the test absent and so clears the stored test; with the EMPTY id box it sends the key `minecraft:` (the empty text parses, 7A.3), not an absent test.
7. New: a resize resets every edit and re-sends INIT (7A.5); 40-x1 8 does not mention the resize.
8. New: `isInGameUi` is true, so the transparent background is drawn (7A.1).
9. New: the response path: the status packet is dropped unless this screen is the current one, so a late reply after Cancel does nothing.
10. The packet's field layout (7A.4) agrees with 05c 0x41 and its `TestInstanceData` type, including the optional encodings (a boolean then the value) and the VarInt triple.

### 7A.7 Worked examples (`W = 320`, so `left` = 2; no IDE, so `c` = 2)

| Case | Result |
|---|---|
| Layout | ID box x 2 to 318, y 40 to 60; info text x 2, y 70, 316 by 72; size boxes at x 2, 66, 131 (`2 + 64.8` = 66.8 gives 66; `2 + 129.6` = 131.6 gives 131), y 160, 56 wide; rotation x 196 (`2 + 194.4` = 196.4); include entities x 261 (`2 + 259.2` = 261.2); Reset x 2 (154 wide), Save x 164 (`2 + 162`) at y 185; Run x 2, Done x 110, Cancel x 218 (100 wide) at y 210. With `c` = 3: Reset x 2, Save x 110, Export x 218 (100 wide), y 185. Labels at y 30 and y 150 |
| Valid id | text `minecraft:my_test`: each change of the text sends QUERY with the parsed id; Save is active while the rotation is `0` |
| Invalid id | text `Bad Id`: `tryParse` fails on the space and the capital; the packet is still sent with the test absent; the info text becomes the red "Invalid test ID"; Save is inactive; Done still works and clears the test |
| Rotation 90 | Save inactive; Reset, Run, Done active; a RUN then carries rotation id 1 |
| Sizes | `0` sends 1; `99` sends 48; `x` sends 1; `-5` sends 1 (clamp); `48` sends 48 |
| Reply | a status reply "Function: foo" with size (3, 3, 3) while the entity has the error "boom": the info text reads `Failed: boom` (the argument in red), two line feeds, `Function: foo`; the boxes show 3, 3, 3 |
| Fresh block | boxes `0 0 0`, id empty. The empty text parses, so INIT carries the test PRESENT with the key `minecraft:` (wire: `01`, `0A`, `minecraft:`), size 1, 1, 1; Save is active (rotation NONE, id parses); no red text. The server finds no such registry entry and answers "No such test" in red; the screen shows it |
| Resize | the player had typed `minecraft:abc` and size 5 and the window is resized: the id box is empty again (entity test absent) and a new INIT is sent |

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
4. 40-x1 Open question 1 is closed for the five screens read here: `Screen.isPauseScreen` returns true and none of the five (nor the abstract base) overrides `isPauseScreen` or `shouldCloseOnEsc` (section 3). The test instance screen is read in section 7A.
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

1. CLOSED (round TIBE): `TestInstanceBlockEditScreen` is now read in section 7A (screen, packet field layout, validation, entity data). Section 9 items 1 to 8 still cover only the five screens above.
2. Java number grammars for `Integer.parseInt`, `Float.valueOf` and `Long.valueOf` (signs, spaces, hexadecimal and exponent forms, `NaN`) and the half-even rounding of `DecimalFormat("0.0###")` are library behaviour, not read (recalled, not verified); the same as 40-x1 Open question 5.
3. `ByteBuf.writeByte(int)` keeping only the low 8 bits is Netty library behaviour (recalled, not verified), as in 40-x1 Open question 10.
4. The permission level numbers behind entity events 25 to 28 (1 to 4) are taken from 15 section 2.2 (inferred from the constant names `MODERATOR`, `GAMEMASTER`, `ADMIN`, `OWNER` and the 24 + level rule there); the constant values were not read here.
5. Slider keyboard step and focus behaviour of `AbstractSliderButton` are in 40-x1 3.3 and were not re-read; only `applyValue`, the initial value 0.0 and `Mth.clampedLerp`'s argument order were read here.
6. Text box internals (word boundaries, selection colours, scrolling, blink duty beyond the 300 ms interval, IME) are those of 40-x1 Open questions 2, 4 and 15 and 40-8 section 2; not traced for the single-line `EditBox`.
7. `CommandSuggestions` placement and drawing under the parameters of section 4.1 (40-x1 Open question 11).
8. Whether the mirror symbol glyphs exist in the default font (40-x1 Open question 3).
9. (Removed in round TIBE: the README index row is the orchestrator's task and not a question about the artifact.)
10. Which widget is first in the tab order of the test instance screen (expected: the ID box; the order of the widget tree's focusable children was not traced), 7A.2.
11. (Closed in round TIBE: `Identifier.tryParse` on empty and colon-less text, `Rotation.getRotated`, and the transparent background are read in 7A.1 and 7A.3.)
