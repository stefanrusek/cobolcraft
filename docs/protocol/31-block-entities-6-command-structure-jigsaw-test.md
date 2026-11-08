# 31-6 Block entities, part 6: command block, structure block, jigsaw block, test block, test instance block

| Item | Value |
|---|---|
| Covers | The five "game master" block entity types: `command_block` (`CommandBlockEntity` and `BaseCommandBlock`: keys, execution, scheduling, chains, output capture, the command source it builds), `structure_block` (`StructureBlockEntity`: keys, the four modes, save, load, corner scan, bounding box geometry, packet handling), `jigsaw` (`JigsawBlockEntity`), `test_block` (`TestBlockEntity`) and `test_instance_block` (`TestInstanceBlockEntity` with `Data`, `Status`, `ErrorMarker`); `BoundingBoxRenderable` and the client's bounding box renderer; the server handlers of the five Set/Action packets; the operator-only rules (`canUseGameMasterBlocks`, `OP_ONLY_CUSTOM_DATA`, the item warning). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Class and method names are cited to say where a fact was read; they are not a design. Every value was read in this round; anything not read is marked "(inferred)" or "(recalled, not verified)" and listed in Open questions. |
| Round | RS13 (GAP-8 of `../design/README.md` Part 5), sibling of 31 parts 1 to 5, 7 and 8 |
| Data versus code | Structure NBT files (templates), template pools, processor lists, loot, tags, game test instance and environment JSON are DATA (22, 23). This part specifies the block entity state, the server and client engines around it, and the geometry. The template engine (`StructureTemplate.fillFromWorld`, `placeInWorld`, the jigsaw assembler, the game test runner) is cited, not specified (36 structures, RS20). |

Related documents, not repeated here: 31-1 (the shared block entity model: `saveWithoutMetadata`, `saveCustomOnly`, `loadAdditional`, `components`, update tag and Block Entity Data rules, chunk interplay, the six operator-only types), 05a id 6 (Block Entity Data) and 05b id 129 (Test Instance Block Status), 05c ids 27 (Jigsaw Generate), 55 (Set Command Block), 59 (Set Jigsaw Block), 60 (Set Structure Block), 61 (Set Test Block), 65 (Test Instance Block Action), 15 and 16 (command framework, game rules table at 16 §"game rules"), 29 (block change pipeline, scheduled ticks, `hasNeighborSignal`, `sendBlockUpdated`), 24 (block registry: states of the five blocks), 07 (NBT).

---

## 0. Reader's map

| Question | Section |
|---|---|
| Which block entity types and which blocks | 1 |
| Command block keys, defaults, load and save | 2 |
| When and how a command block runs (power, scheduling, modes, chain, conditional) | 3 |
| What the command sees (source stack, output capture) | 4 |
| Command block packet handler and sync | 5 |
| Structure block keys, modes, save, load, scan | 6 |
| Bounding box geometry and the client renderer | 7 |
| Jigsaw block | 8 |
| Test block | 9 |
| Test instance block | 10 |
| Operator rules, `OP_ONLY_CUSTOM_DATA`, the item warning | 11 |
| Worked examples | 12 |
| Validation | 13 |

"Boolean" in a saved compound means the value-output boolean: it is stored as an NBT Byte, 0 or 1 (inferred: the NBT format of 07 has no boolean tag). "Optional" in a read means: an absent key or a value that does not decode gives the stated default.

---

## 1. Types, blocks and state at a glance

| Block entity type (registry key) | Valid blocks | Class | Sends Block Entity Data after a change | Update tag |
|---|---|---|---|---|
| `command_block` | `command_block`, `chain_command_block`, `repeating_command_block` (this order) | `CommandBlockEntity` | **No** (the class has neither `getUpdatePacket` nor `getUpdateTag`: the base defaults, null and an empty compound apply) | empty; but see 5.2: the data is sent when a game master opens the block |
| `structure_block` | `structure_block` | `StructureBlockEntity` | yes, `create(this)` | "custom only" (all 19 keys of 6.1) |
| `jigsaw` | `jigsaw` | `JigsawBlockEntity` | yes | "custom only" (the 7 keys of 8.1) |
| `test_block` | `test_block` | `TestBlockEntity` | yes | "custom only" (3 keys, 9.1) |
| `test_instance_block` | `test_instance_block` | `TestInstanceBlockEntity` | yes | "custom only" (`data`, `errors`, 10.1) |

The numeric ids of the types are in 31-1 §3.1 and 46 (command_block 23, structure_block 21, jigsaw 31, test_instance_block 46 in the `block_entity_type` registry; `test_block` is 45 in the same table at 46 §5.4, read there). The five blocks all have hardness -1 and blast resistance 3600000 and no loot table (`Blocks`: `strength(-1.0, 3600000.0)`, `noLootTable`); `command_block` and the structure, jigsaw blocks also `requiresCorrectToolForDrops`; the test instance block uses `noOcclusion` and no map colour. Their state properties are in 24: command blocks have `facing` (6 directions, default north) and `conditional` (Boolean, default false); the structure block has `mode` (the `structure_block` mode property, default `load`); the jigsaw block has `orientation` (a `FrontAndTop` value, default `north_up`); the test block has `mode` (`start`, `log`, `fail`, `accept`).

### 1.1 The `automatic` flag of the three command block blocks

The `CommandBlock` block class takes one constructor flag, `automatic`; a new block entity copies it into its `auto` field. Read from the three block factories (each registration's factory function resolved through the bootstrap table): `command_block` = false, `repeating_command_block` = false, `chain_command_block` = true. See Open question 1.

---

## 2. The command block entity

### 2.1 State

| Field | Type | Default | Saved key |
|---|---|---|---|
| `powered` | boolean | false | `powered` |
| `conditionMet` | boolean | false | `conditionMet` |
| `auto` ("always active") | boolean | false (then set from the block flag, 1.1) | `auto` |
| `command` | string | `""` | `Command` |
| `successCount` | int | 0 | `SuccessCount` |
| `customName` | text component or none | none | `CustomName` |
| `trackOutput` | boolean | true | `TrackOutput` |
| `lastOutput` | text component or none | none | `LastOutput` |
| `updateLastExecution` | boolean | true | `UpdateLastExecution` |
| `lastExecution` | long (game time of the last run; -1 = never) | -1 | `LastExecution` |

The first three fields belong to `CommandBlockEntity`, the rest to the embedded `BaseCommandBlock` (the same object is shared with the command block minecart, 21). The display name used for the command source is `customName` when set, otherwise the literal text `@` (constant `DEFAULT_NAME`).

### 2.2 Saving (`saveAdditional`) in key order

1. `BaseCommandBlock.save`: `Command` (String, always); `SuccessCount` (Int, always); `CustomName` (text component codec, only when set); `TrackOutput` (Boolean, always); `LastOutput` (text component codec) only when `trackOutput` is true and `lastOutput` is not null; `UpdateLastExecution` (Boolean, always); `LastExecution` (Long) only when `updateLastExecution` is true and `lastExecution` is not -1.
2. `powered` (Boolean), `conditionMet` (Boolean), `auto` (Boolean), always.

The base class then adds `components` (31-1 §2.2). `removeComponentsFromTag` discards `CustomName`, `conditionMet` and `powered` (those become or are dropped when the block entity is turned into item data); `collectImplicitComponents` stores `customName` as the `custom_name` component; `applyImplicitComponents` reads `custom_name` back into `customName` (31-1 §2.5).

### 2.3 Loading (`loadAdditional`), in order

1. `Command` default `""`; `SuccessCount` default 0.
2. `CustomName` through the lenient reader `parseCustomNameSafe` (a missing or unreadable value gives none).
3. `TrackOutput` default true. If true, `LastOutput` through the same lenient reader; if false, `lastOutput` becomes none.
4. `UpdateLastExecution` default true. If true, `LastExecution` default -1; if false, `lastExecution` becomes -1.
5. `powered` default false; `conditionMet` default false (stored directly, no side effect).
6. `auto` default false, applied through `setAutomatic` (so it has the side effect of 3.3).

### 2.4 Mode of a command block entity

`getMode()` is derived from the block state, never saved: `command_block` is `REDSTONE`, `repeating_command_block` is `AUTO`, `chain_command_block` is `SEQUENCE`; any other block gives `REDSTONE`. The mode enum order is SEQUENCE (0), AUTO (1), REDSTONE (2) (the order of the packet, 05c id 55).

`isConditional()`: false when the entity has no level or the block is not a command block; otherwise the `conditional` property.

---

## 3. When a command block runs

All of this runs on the server only (the block's neighbour handler returns at once on a client level).

### 3.1 Constants and rules used

- Scheduled tick delay: 1 game tick, `Level.scheduleTick(pos, block, 1)` (queue rules: 29 §4).
- `max_command_sequence_length`: game rule, default 65536 (16 §game rules); `command_blocks_work`: default true; `command_block_output`: default true; `send_command_feedback`: default true. `ServerLevel.isCommandBlockEnabled()` is the value of `command_blocks_work`.

### 3.2 `markConditionMet()`

Returns and stores `conditionMet`:

1. `conditionMet := true`.
2. If the block is conditional: let `behind` be the position one step from the block opposite to its `facing` (the block the command block "faces away from"). If the block at `behind` is a command block of any kind and its entity is a `CommandBlockEntity` whose `successCount` is greater than 0, `conditionMet := true`, otherwise false. If the block at `behind` is not a command block at all, `conditionMet := false`.
3. Return `conditionMet`.

A non-conditional block therefore always ends with true.

### 3.3 `setAutomatic(newAuto)` and `onModeSwitch()`

- `setAutomatic`: store the new value; if the old value was false, the new value is true, `powered` is false, the entity has a level and the mode is not SEQUENCE, then `scheduleTick()`.
- `scheduleTick()` (private): if the block at the entity's position is a command block: `markConditionMet()` (result discarded), then schedule a block tick of that block at the position with delay 1.
- `onModeSwitch()`: if the mode is AUTO and (`powered` or `auto`) and the entity has a level, `scheduleTick()`.

### 3.4 Power changes (`CommandBlock.neighborChanged`, `setPlacedBy`, `setPoweredAndUpdate`)

- `neighborChanged` (server only): if the entity at the position is a command block entity, `setPoweredAndUpdate(level, pos, entity, level.hasNeighborSignal(pos))`.
- `setPoweredAndUpdate(newPowered)`: if `newPowered` equals the stored `powered`, do nothing. Otherwise store it. Then only when `newPowered` is true: if the entity is `auto` or the mode is SEQUENCE, stop; otherwise `markConditionMet()` (discard) and schedule a tick at delay 1. A power-off does nothing else.
- `setPlacedBy` (placement): the entity must exist; on a server level: if the placed item stack has NO `block_entity_data` component, `trackOutput := value of send_command_feedback` and `setAutomatic(block's automatic flag)`; then in all cases `setPoweredAndUpdate(hasNeighborSignal(pos))`.
- `newBlockEntity`: creates the entity and calls `setAutomatic(block's automatic flag)`.

### 3.5 The scheduled tick (`CommandBlock.tick`)

If the entity at the position is not a command block entity, stop. Otherwise, read at the start: `hasCommand` = the command string is not null or empty; `mode`; `prevMet` = the value of `wasConditionMet()` before anything below changes it. Then:

| Mode | Steps |
|---|---|
| AUTO | 1. `markConditionMet()` (recomputes the flag for the next run; the run below uses `prevMet`). 2. If `prevMet`: `execute(hasCommand)` (3.6). Else if the block is conditional: `successCount := 0`. 3. If `powered` or `auto`: schedule the next tick at delay 1 (this is the repeat). |
| REDSTONE | If `prevMet`: `execute(hasCommand)`. Else if conditional: `successCount := 0`. No reschedule. |
| SEQUENCE | Nothing (chain blocks run only from `executeChain`). |

At the end, in every mode, `updateNeighbourForOutputSignal(pos, block)` (comparators next to the block recompute: the comparator signal of a command block is its `successCount`, see 3.8).

### 3.6 `execute(hasCommand)`

If `hasCommand`: `BaseCommandBlock.performCommand(level)` (result ignored). Otherwise `successCount := 0`. Then `executeChain(level, pos, facing)` from this block's `facing`.

### 3.7 `executeChain(level, startPos, direction)`

Let `remaining` = the value of `max_command_sequence_length` read once at the start.

Loop, entered while `remaining > 0` (the counter is tested and then decremented):

1. Move one block in `direction` from the current position (the first move is from the block that just ran).
2. If the block there is not a `chain_command_block`, leave the loop. If its entity is not a `CommandBlockEntity`, leave the loop. If that entity's mode is not SEQUENCE, leave the loop.
3. If the entity is `powered` or `auto`: call `markConditionMet()`; if it returned true, call `performCommand(level)` and, if that returned false, leave the loop; then `updateNeighbourForOutputSignal` for that position. If `markConditionMet()` returned false and the block is conditional: `successCount := 0`. (If the entity is neither powered nor auto, nothing runs and the chain continues.)
4. `direction := ` the `facing` of the block just visited (the chain follows each block's own facing).

After the loop, if `remaining <= 0` (the counter ran out; note that leaving the loop early with a counter that happens to be 0 after the decrement also counts), log a warning "Command Block chain tried to execute more than {} steps!" with `max(rule, 0)`.

`performCommand` returns false only when a command already ran in this same game tick (3.9); a command that fails still returns true, so a failed command does not stop a chain.

### 3.8 Comparator output

`hasAnalogOutputSignal` is true; `getAnalogOutputSignal` is the entity's `successCount` (the raw int, not clamped here; the comparator engine in 31-1 §9.5 and the redstone documents apply their own limits), 0 when the entity is not a command block entity.

### 3.9 `BaseCommandBlock.performCommand(level)`

Inputs: the current game time `t`. Output: a boolean (true unless noted).

1. If `t == lastExecution`: return false without doing anything (this blocks two runs in the same tick, for example from a loop in a chain).
2. If the command text equals "Searge" ignoring case: set `lastOutput` to the literal text `#itzlipofutzli`, `successCount := 1`, return true (`lastExecution` is not touched).
3. `successCount := 0`.
4. If `ServerLevel.isCommandBlockEnabled()` (rule `command_blocks_work`) and the command is not null or empty:
   a. `lastOutput := none`.
   b. Build the command source (section 4) and a source stack with a result callback; the callback receives (success, result) and does `successCount += 1` when `success` is true (the result value is ignored). So `successCount` counts the successful command executions of the line, which can exceed 1 (for example for `execute ... run` forms that run several times; 15 §execution).
   c. Run `Commands.performPrefixedCommand(stack, command)`: a leading `/` is removed once (`trimOptionalPrefix`), then the command is parsed and run through the normal path (15 §4, 16).
   d. Close the output capture (section 4).
   e. Any exception thrown by the run is converted to a crash report ("Executing command block", with the details `Command` and `Name`) that stops the server; ordinary command errors are not exceptions of this kind (15 §6: failures are reported through the source).
5. If `updateLastExecution`: `lastExecution := t`; else `lastExecution := -1`.
6. Return true.

When the rule `command_blocks_work` is false, or the command is empty, steps 4a to 4e are skipped but 3 and 5 still run, so `successCount` ends 0 and `lastExecution` is updated.

`setCommand(text)` sets the command and resets `successCount` to 0, and (in the command block subclass) calls `setChanged()` on the entity. `BaseCommandBlock.onUpdated(level)` in the block entity subclass calls `level.sendBlockUpdated(pos, state, state, 3)` (29 §7.2); because the entity has no update packet, that sends nothing to clients (1, 5.2).

---

## 4. The command source of a command block

### 4.1 `createCommandSourceStack(level, source)` (`CommandBlockEntity$1`)

| Component | Value |
|---|---|
| Output sink | the capture of 4.2, or the null sink when `trackOutput` is false |
| Position | the centre of the block (x+0.5, y+0.5, z+0.5) |
| Rotation | pitch 0, yaw = the `facing` direction's yaw (`Direction.toYRot`) |
| Level | the server level |
| Permissions | the level-based set GAMEMASTER (level 2; 15 §2) |
| Name | the command block's display name (2.1: custom name or `@`), used as both the plain name and the display name |
| Entity | none |

`isValid()` is "the entity is not removed". A source with no entity: selectors such as `@s` select nothing, as for any entity-less source (15 §7).

### 4.2 Output capture (`CloseableCommandBlockSource`)

Used only when `trackOutput` is true. It implements the command output sink:

| Query | Answer |
|---|---|
| `acceptsSuccess()` | `!closed` and the rule `send_command_feedback` |
| `acceptsFailure()` | `!closed` |
| `shouldInformAdmins()` | `!closed` and the rule `command_block_output` |
| `sendSystemMessage(text)` | if not closed: `lastOutput := literal("[" + HH:mm:ss + "]") followed by text` (time of day from the system clock in the system time zone, pattern `HH:mm:ss`, root locale; there is no space between `]` and the text) and then `onUpdated(level)` |

`close()` sets `closed`. The capture is closed right after the command returns (3.9 step 4d), so messages that arrive later (delayed output) are ignored. The `lastOutput` text is replaced by each message; only the last message of a run is kept.

---

## 5. Command block packets and sync

### 5.1 Set Command Block (05c id 55): `handleSetCommandBlock`

1. If the player cannot use game master blocks (11.1): send the system message with the translation key `advMode.notAllowed` and stop.
2. Find the entity at the packet's position; if it is not a command block entity, stop.
3. Remember the old mode. Compute the new block: `SEQUENCE` gives `chain_command_block`, `AUTO` gives `repeating_command_block`, `REDSTONE` gives `command_block`; copy the old `facing`; set `conditional` from the packet's conditional flag (flag 0x02).
4. If the computed state is not the identical current state: `setBlock(pos, newState, 2)`, give the entity the new state (`setBlockState`) and re-register the entity in its chunk (`LevelChunk.setBlockEntity`), so replacing the block does not lose the entity's data.
5. `setCommand(packet command)` (this resets `successCount` to 0); `setTrackOutput(flag 0x01)`; if track output is false, `lastOutput := none`.
6. `setAutomatic(flag 0x04)` (side effect 3.3).
7. If the packet's mode differs from the old mode: `onModeSwitch()` (3.3).
8. If `command_blocks_work` is true: `onUpdated(level)`.
9. If the command is not empty: send the system message with key `advMode.setCommand.success` when `command_blocks_work` is true, otherwise `advMode.setCommand.disabled`; the argument is the command text (inferred from a one-element argument array).

### 5.2 What clients receive

- A command block entity has no `getUpdatePacket` and no `getUpdateTag`: neither a change nor a chunk send gives a client its data (the chunk packet carries an absent tag for it, 31-1 §5.3).
- When a player with game master rights uses the block (`CommandBlock.useWithoutItem`: the entity exists and `canUseGameMasterBlocks`), the server calls `ServerPlayer.openCommandBlock`, which sends one Block Entity Data packet built from the entity's "custom only" form (the keys of 2.2, no `components`, no metadata). The result is `SUCCESS`; for others the interaction is `PASS`. The client loads the tag (`loadAdditional`, 2.3) and refreshes an open command block screen (31-1 §5.4).
- Because `onUpdated` sends nothing, the output shown in the screen refreshes only when the screen is opened again.

### 5.3 Other interactions

- `rotate` rotates `facing` by the given rotation; `mirror` applies the mirror's rotation to `facing` (`Mirror.getRotation(facing)`).
- `getStateForPlacement`: `facing` is the opposite of the placing player's nearest looking direction (`getNearestLookingDirection().getOpposite()`).

---

## 6. The structure block entity

### 6.1 State and saved keys

| Field | Default | Saved key (NBT type), in write order | Load default and clamp |
|---|---|---|---|
| `structureName` (identifier or none) | none | `name` (String; the identifier text or `""` when none) | `""`; stored through `setStructureName`: an empty string gives none, other text is parsed with `Identifier.tryParse` (an unparsable text gives none) |
| `author` | `""` | `author` (String) | `""` |
| `metaData` | `""` | `metadata` (String) | `""` |
| `structurePos` (offset) | (0, 1, 0) | `posX`, `posY`, `posZ` (Int each) | each default from (0, 1, 0), each clamped to -48..48 |
| `structureSize` | (0, 0, 0) | `sizeX`, `sizeY`, `sizeZ` (Int each) | each default 0, each clamped to 0..48 |
| `rotation` | `NONE` | `rotation` (String: the enum constant name `NONE`, `CLOCKWISE_90`, `CLOCKWISE_180`, `COUNTERCLOCKWISE_90`, written through the "legacy codec"; inferred form, Open question 7) | `NONE` when absent or invalid |
| `mirror` | `NONE` | `mirror` (String: `NONE`, `LEFT_RIGHT`, `FRONT_BACK`) | `NONE` |
| `mode` | from the block state's `mode` (new entity) | `mode` (String: `SAVE`, `LOAD`, `CORNER`, `DATA`) | **`DATA`** when absent or invalid (not the block's default `load`) |
| `ignoreEntities` | true | `ignoreEntities` (Boolean) | true |
| `strict` | false | `strict` (Boolean) | false |
| `powered` | false | `powered` (Boolean) | false |
| `showAir` | false | `showair` (Boolean) | false |
| `showBoundingBox` | true | `showboundingbox` (Boolean) | true |
| `integrity` | 1.0 | `integrity` (Float) | 1.0 (not clamped on load) |
| `seed` | 0 | `seed` (Long) | 0 |

Constants: `MAX_OFFSET_PER_AXIS` 48, `MAX_SIZE_PER_AXIS` 48, scan range 80 (`SCAN_CORNER_BLOCKS_RANGE`). After loading, `updateBlockState()` runs: if the entity has a level and the block at its position is the structure block, set the block's `mode` property to the entity's mode with flags 2 (client broadcast only, no neighbour updates). `setMode(mode)` stores it and does the same.

Update tag: the "custom only" form: all 19 keys above (so every key reaches clients, including `author`, `metadata`, `seed`).

### 6.2 Triggering by redstone (`StructureBlock.neighborChanged`)

Server only; the entity must be a structure block entity. `p := level.hasNeighborSignal(pos)`. If `p` is true and the stored `powered` is false: `powered := true`, then `trigger`. If `p` is false and the stored `powered` is true: `powered := false`. (Neither calls `setChanged`.)

`trigger(level, entity)` by the entity's mode: `SAVE`: `saveStructure(false)` (6.3, no write to disk); `LOAD`: `placeStructure(level)` (6.4); `CORNER`: `unloadStructure()` (6.5); `DATA`: nothing. `setPlacedBy` (server, placer not null, entity exists): `author := placer plain-text name`.

### 6.3 Saving the area

`saveStructure()` (the button): only in mode SAVE; calls `saveStructure(true)`. `saveStructure(writeToDisk)`: needs a structure name and a server level, otherwise false. Then the static form with: origin = block position + `structurePos`, the name, `structureSize`, `ignoreEntities`, `author`, `writeToDisk`, and the list of blocks to ignore, which is exactly one block, `structure_void` (plus any extra entries the caller passes; this caller passes none). The static form: get or create the template named `name` (`StructureTemplateManager.getOrCreate`; failure gives false); `template.fillFromWorld(level, origin, size, includeEntities = !ignoreEntities, ignoreBlocks)`; `template.setAuthor(author)`; if `writeToDisk`, `StructureTemplateManager.save(name)` and return its result, else true. The template content (palette, blocks, entities, the NBT file written) is specified with the template engine (36).

### 6.4 Loading and placing

- `isStructureLoadable()`: mode LOAD, server level, a name, and the template manager can `get` the template (a lookup that may read the file).
- `loadStructureInfo(template)`: `author := template author` (or `""`), `structureSize := template size`, `setChanged()`.
- `loadStructureInfo(level)` (used by the screen): get the template; none gives false; else the previous and true.
- `placeStructureIfSameSize(level)`: mode LOAD and a name, else false. Get the template (none gives false). If `template.size == structureSize`: `placeStructure(level, template)` and return true. Otherwise `loadStructureInfo(template)` (adopt the template's size and author) and return false.
- `placeStructure(level)`: get the template by name and, when present, place it.
- `placeStructure(level, template)` steps: (1) `loadStructureInfo(template)`; (2) placement settings: mirror, rotation, `ignoreEntities`, "known shape" = `strict`; (3) if `integrity < 1.0`: clear the processor list and add one `BlockRotProcessor` with integrity clamped to 0..1, and set the settings' random source to `createRandom(seed)`; (4) origin = block position + `structurePos`; (5) in the debug "structure edit mode" (`SharedConstants.DEBUG_STRUCTURE_EDIT_MODE`, normally false) the region is first filled with `structure_void`; (6) `template.placeInWorld(level, origin, origin, settings, createRandom(seed), flags)` with `flags = 2 | (strict ? 816 : 0)` (816 = `UPDATE_SKIP_ALL_SIDEEFFECTS`, 29 §1). Note the random source of the settings and the one passed to `placeInWorld` are two separate objects.
- `createRandom(seed)`: seed 0 gives a source seeded from the current time in milliseconds (not reproducible); otherwise `RandomSource.create(seed)`, which is the legacy linear congruential source (`LegacyRandomSource`, 10 §random sources).
- `BlockRotProcessor` (the "integrity" processor): for each placed block (when no `rottable_blocks` set is given, every block): draw one `nextFloat()` from the settings' random source (in processing order); the block is kept when the draw is `<= integrity`, and removed (not placed) when the draw is `> integrity`. When a `rottable_blocks` set is given (data pack processors use the same class through the processor registry, field `rottable_blocks` and `integrity`), only blocks in that set take part and others are always kept (22).

### 6.5 Corner mode

`unloadStructure()`: needs a name and a server level; removes the template with that name from the manager's cache (`StructureTemplateManager.remove`). It does not delete a file.

### 6.6 Scanning corners (`detectSize`)

Only in mode SAVE; otherwise false. Steps:

1. Scan the box from (x-80, level min Y, z-80) to (x+80, level max Y, z+80) around the structure block for blocks that are `structure_block`s.
2. For each such block whose entity is a structure block entity in mode CORNER and whose `structureName` equals this entity's name (equal including both none): count it and grow a bounding box over its position.
3. By the count: 0 corners: no box (failure). 1 corner: the box that covers that corner AND this structure block's own position. 2 or more corners: the box covering all the corners (this block's position is not included).
4. The box passes if, on each axis, `max - min > 1` (the extremes differ by at least 2).
5. On success: `structurePos := (minX - x + 1, minY - y + 1, minZ - z + 1)` (x, y, z = this block), `structureSize := (maxX - minX - 1, maxY - minY - 1, maxZ - minZ - 1)`, `setChanged()`, `sendBlockUpdated(pos, state, state, 3)`, return true. Otherwise false.

### 6.7 Set Structure Block (05c id 60): `handleSetStructureBlock`

If the player cannot use game master blocks (11.1) or the entity is not a structure block entity, the packet is ignored silently. Otherwise:

1. Copy from the packet: mode (`setMode`, which also updates the block's property), name (6.1 parsing), offset, size, mirror, rotation, metadata, `ignoreEntities`, `strict`, `showAir`, `showBoundingBox`, integrity, seed. The packet decoder has already clamped offsets to -48..48, sizes to 0..48 and integrity to 0..1 (05c id 60).
2. If the entity now has a structure name: by the update type: `UPDATE_DATA` nothing more; `SAVE_AREA`: `saveStructure()` then the system message `structure_block.save_success` or `structure_block.save_failure` (argument: the name); `LOAD_AREA`: if not loadable `structure_block.load_not_found`; else if `placeStructureIfSameSize` is true `structure_block.load_success`, else `structure_block.load_prepare` (argument: the name); `SCAN_AREA`: `detectSize()` then `structure_block.size_success` (argument: the name) or `structure_block.size_failure`.
3. If the entity has no name: the message `structure_block.invalid_structure_name` with the packet's name as argument.
4. In all cases: `setChanged()` and `sendBlockUpdated(pos, state, state, 3)` (so the Block Entity Data packet of 6.1 reaches clients).

`StructureBlockEntity.usedBy(player)`: false unless the player can use game master blocks; on a client level it opens the screen; true. The block's `useWithoutItem` returns `SUCCESS` when `usedBy` is true, else `PASS`.

---

## 7. Bounding boxes and the client renderer

### 7.1 `BoundingBoxRenderable`

An interface of two methods: `renderMode()` returning `NONE`, `BOX` or `BOX_AND_INVISIBLE_BLOCKS` (that order), and `getRenderableBox()` returning a `RenderableBox` record (`localPos`: a position relative to the block entity; `size`: a vector). `RenderableBox.fromCorners(x1,y1,z1,x2,y2,z2)`: `localPos = (min x, min y, min z)`, `size = (|x2-x1|, |y2-y1|, |z2-z1|)` (max minus min per axis). Implemented by the structure block and the test instance block (the jigsaw block does not draw a box).

### 7.2 Structure block `renderMode`

| Mode | showAir | showBoundingBox | Result |
|---|---|---|---|
| CORNER or DATA | any | any | `NONE` |
| SAVE | true | any | `BOX_AND_INVISIBLE_BLOCKS` |
| SAVE | false | any | `BOX` |
| LOAD | n/a | true | `BOX` |
| LOAD | n/a | false | `NONE` |

### 7.3 Structure block `getRenderableBox`

Inputs: offset `(ox, oy, oz) = structurePos`, size `(sx, sy, sz)`, `mirror`, `rotation`. Let `x = ox`, `z = oz`, `y1 = oy`, `y2 = oy + sy`.

1. Mirror: `LEFT_RIGHT`: `dx = sx`, `dz = -sz`. `FRONT_BACK`: `dx = -sx`, `dz = sz`. `NONE`: `dx = sx`, `dz = sz`.
2. Rotation:

| Rotation | `x1` | `z1` | `x2` | `z2` |
|---|---|---|---|---|
| `NONE` | `dx < 0 ? x + 1 : x` | `dz < 0 ? z + 1 : z` | `x1 + dx` | `z1 + dz` |
| `CLOCKWISE_90` | `dz < 0 ? x : x + 1` | `dx < 0 ? z + 1 : z` | `x1 - dz` | `z1 + dx` |
| `CLOCKWISE_180` | `dx < 0 ? x : x + 1` | `dz < 0 ? z : z + 1` | `x1 - dx` | `z1 - dz` |
| `COUNTERCLOCKWISE_90` | `dz < 0 ? x + 1 : x` | `dx < 0 ? z : z + 1` | `x1 + dz` | `z1 - dx` |

3. Result: `fromCorners(x1, y1, z1, x2, y2, z2)` with `y2` as above.

The result is relative to the block entity's position (the renderer adds it). The `+1` terms make the box include the blocks on the negative side of a flipped extent.

### 7.4 The renderer (`BlockEntityWithBoundingBoxRenderer`, client only)

Applies to every block entity that implements `BoundingBoxRenderable`.

- It draws only when the local player can use game master blocks or is a spectator; otherwise nothing.
- `shouldRenderOffScreen` is true; view distance 96 blocks.
- Mode `NONE` draws nothing. Otherwise, a box is drawn only when the size is at least 1 on all three axes: a wireframe cuboid from `blockPos + localPos` to that plus `size`, colour ARGB float (alpha 1.0, red 0.9, green 0.9, blue 0.9), drawn through blocks.
- Mode `BOX_AND_INVISIBLE_BLOCKS` additionally scans every block position in the box (on extract) and classifies it: air gives `AIR`, `structure_void` gives `STRUCTURE_VOID`, `barrier` gives `BARRIER`, `light` gives `LIGHT`, anything else is not marked. Each marked block gets a small cuboid around the block centre: from 0.45 to 0.55 on each axis, inflated by 0.05 for `AIR` only (so `AIR` markers span 0.40 to 0.60, the others 0.45 to 0.55); colours (alpha, red, green, blue): `AIR` (1.0, 0.5, 0.5, 1.0) read as the float order of `colorFromFloat`, `STRUCTURE_VOID` (1.0, 1.0, 0.75, 0.75), `BARRIER` the int -65536 (0xFFFF0000, red), `LIGHT` the int -256 (0xFFFFFF00, yellow).
- `STRUCTURE_VOIDS_COLOR` is (0.2, 0.75, 0.75, 1.0) in the same float order; it fills the exposed faces of the structure void voxels (a `renderStructureVoids` pass built from a voxel bit set, each face a quad inset 0.48 from the centre line); whether this pass is reached from `submit` was not traced (Open question 9).

---

## 8. The jigsaw block entity

### 8.1 State and saved keys

| Field | Default | Key (written in this order, all always written) | Type | Load rule |
|---|---|---|---|---|
| `name` | `minecraft:empty` | `name` | identifier | missing or invalid gives `minecraft:empty` |
| `target` | `minecraft:empty` | `target` | identifier | same |
| `pool` | key of the template pool `minecraft:empty` | `pool` | identifier of a `worldgen/template_pool` | same default |
| `finalState` | `minecraft:air` | `final_state` | String (a block state in text form) | default `minecraft:air` |
| `joint` | `rollable` | `joint` | String `rollable` or `aligned` | when missing or invalid: `aligned` if the block's front direction is horizontal, else `rollable` |
| `placementPriority` | 0 | `placement_priority` | Int | 0 |
| `selectionPriority` | 0 | `selection_priority` | Int | 0 |

Constants: `EMPTY_ID` = `minecraft:empty`. Translation keys of the joint names: `jigsaw_block.joint.rollable`, `jigsaw_block.joint.aligned`. The update tag is "custom only" (these seven keys). The block's `orientation` is a `FrontAndTop` (24); the front direction is the face that points at the next piece and the top is the "up" of the piece. `JigsawBlock.canAttach` (used by the assembler, 36): two jigsaws match when their fronts are opposite and either the joint of the first is `rollable` or their tops are equal, and the target of the second equals the name of the first (or the name is null).

### 8.2 Packets

- Set Jigsaw Block (05c id 59), `handleSetJigsawBlock`: ignored silently unless the player can use game master blocks and the entity is a jigsaw entity. Sets name, target, pool (`ResourceKey` in the template pool registry made from the packet's pool identifier), final state, joint, placement priority, selection priority; `setChanged()`; `sendBlockUpdated(pos, state, state, 3)`.
- Jigsaw Generate (05c id 27), `handleJigsawGenerate`: same permission check; calls `generate(level, packet.levels, packet.keepJigsaws)`.
- `generate(level, levels, keepJigsaws)`: `start = block position + front direction`; look up the pool in the template pool registry by the entity's `pool` key (a missing pool throws, the lookup is `getOrThrow`); call `JigsawPlacement.generateJigsaw(level, poolHolder, target, levels, start, keepJigsaws)` and ignore its result. The assembler is part of 36.
- `JigsawBlock.useWithoutItem`: with a jigsaw entity and a player that can use game master blocks: open the screen and `SUCCESS`, else `PASS`.
- `getStateForPlacement`: the orientation is `FrontAndTop.fromFrontAndTop(front, top)` with `front` = the clicked face and `top` = the opposite of the placing player's horizontal direction when the clicked face's axis is Y, otherwise `up` (the argument order was read as clicked face first; see Open question 5). `rotate` and `mirror` transform the orientation by the octahedral group of the rotation or mirror.

---

## 9. The test block entity

### 9.1 State and saved keys

| Field | Default | Key | Notes |
|---|---|---|---|
| `mode` | from the block state's `mode` (new entity) | `mode` | `TestBlockMode` serialized names `start`, `log`, `fail`, `accept` (ids 0 to 3); on load, missing or invalid gives `fail` |
| `message` | `""` | `message` | String |
| `powered` | false | `powered` | Boolean |
| `triggered` | false | not saved | transient |

Update tag: "custom only" (these three keys). `setMode(mode)`: store, then if the block at the position is the test block set its `mode` property with flags 2.

### 9.2 Behaviour

- `reset()`: `triggered := false`; if mode is START and the entity has a level: `setPowered(false)` and `updateNeighborsAt(pos, block)`.
- `trigger()`: if mode is START and a level exists: `setPowered(true)`, `updateNeighborsAt(pos, block)`, call `log()`, and return (`triggered` stays false in this branch). Otherwise: if mode is LOG, `log()`; then `triggered := true`.
- `log()`: when the message is not blank, write the log line "Test {} (at {}): {}" with the mode's serialized name, the position and the message (server log, info level).
- Block `TestBlock`: `neighborChanged` (server only): when the mode is START, `p := hasNeighborSignal`; `p` and not `powered` gives `setPowered(true)` and `trigger()`; not `p` and `powered` gives `setPowered(false)`. `tick`: `reset()`. `ownSignal`: 15 when the mode is START and `powered`, else 0. `useWithoutItem`: needs the entity and a player that can use game master blocks; on a client level it opens the screen; always `SUCCESS` in that case, else `PASS`. `getStateForPlacement` takes `mode` from the item's `block_state` component. Pick block copies the mode into that component.
- Set Test Block (05c id 61), `handleSetTestBlock`: ignored silently unless game master rights and a test block entity; `setMode`, `setMessage`, `setChanged()`, `sendBlockUpdated(pos, state, state, 3)`.

Who calls `trigger()` for the LOG, FAIL and ACCEPT modes (the game test runner) was not traced (Open question 8).

---

## 10. The test instance block entity

### 10.1 State and saved keys

`data` (a `Data` record) and the list `errorMarkers`.

| Saved key | Content |
|---|---|
| `data` | compound of `Data` (below), always written |
| `errors` | list of `{pos, text}`, written only when the list is not empty |

`Data` fields, in codec order: `test` (optional key of a `test_instance` registry entry; key `test`, omitted when none), `size` (`Vec3i` codec; key `size`), `rotation` (the standard `Rotation` codec with lower-case names `none`, `clockwise_90`, `180`, `counterclockwise_90`; key `rotation`), `ignore_entities` (Boolean), `status` (`cleared`, `running`, `finished`; ids 0, 1, 2; key `status`), `error_message` (optional text component; key `error_message`). Default `data`: no test, size (0,0,0), rotation `none`, `ignore_entities` false, status `cleared`, no error message.

`ErrorMarker`: `pos` (block position codec) and `text` (text component).

Load: read `data`; if it decodes, replace the current `data` through `set` (which calls `setChanged`); a missing or undecodable `data` keeps the current one. Then clear the marker list and add the decoded `errors` (an empty list when missing). Update tag: "custom only" (the two keys).

`setChanged()` override: the base behaviour, then on a server level `sendBlockUpdated(pos, air default state, current state, 3)` (an air "old state" forces the broadcast).

### 10.2 Data transitions

`withSize(size)` replaces the size. `withStatus(status)` replaces the status and clears the error message. `withError(text)` sets the status `finished` and the message. `setSuccess()`: status `finished` (error cleared). `setRunning()`: status `running` (error cleared). `markError(pos, text)` appends a marker and `setChanged()`; `clearErrorMarkers()` clears the list (and `setChanged()` when it was not empty).

### 10.3 Geometry

Let `padding` = the `padding` of the test's definition (0 when no test is set). `STRUCTURE_OFFSET` = (0, 1, 1).

- `getStructurePos()` (the world position of the structure's origin) = block position + (`padding`, `padding`, `padding`) + (0, 1, 1).
- `getTransformedSize()` = `size`, with x and z swapped when the effective rotation is `CLOCKWISE_90` or `COUNTERCLOCKWISE_90`.
- `getStructureBoundingBox()` = the box from `getStructurePos()` to `getStructurePos() + transformedSize - (1,1,1)`, inclusive. `getTestBoundingBox()` = that box inflated by `padding`.
- Effective rotation `getRotation()` = the test definition's own rotation (when a test is set and defines one; mapping lambdas not fully read, Open question 10) composed with `data.rotation` through `Rotation.getRotated`; `NONE` when no test is set.
- `getStartCorner()` (where the template's own origin lands) = `getStructurePos()` plus an offset by the effective rotation: `NONE`: (0,0,0); `CLOCKWISE_90`: (sizeZ - 1, 0, 0); `CLOCKWISE_180`: (sizeX - 1, 0, sizeZ - 1); `COUNTERCLOCKWISE_90`: (0, 0, sizeX - 1) (here `sizeX`, `sizeZ` are the untransformed `data.size`).
- `renderMode()` is always `BOX`. `getRenderableBox()`: `localPos = (0 + padding, 1 + padding, 1 + padding)`, `size = getTransformedSize()` (drawn by 7.4 relative to the block).
- The beam (beacon-style) colours by status (`getBeamSections`, one section): `cleared`: none; `running`: ARGB colour (128,128,128); `finished` with no error: (0,255,0); `finished` with an error: (255,0,0) when the test is "required" (default true when unknown), else (255,128,0).

### 10.4 Actions (05c id 65, `handleTestInstanceBlockAction`)

Requires the player to be able to use game master blocks and the entity to be a test instance block entity; otherwise the entity is treated as absent and the packet only triggers the final block update (below). Actions: `INIT` (0) and `QUERY` (1): both answer with a Test Instance Block Status packet (05b id 129) carrying the test's description text (`GameTestInstance.describe`, or the red translation `test_instance.description.no_test` when no test) and, for QUERY, the structure size of the test. For all other actions (`SET` 2, `RESET` 3, `SAVE` 4, `EXPORT` 5, `RUN` 6) the entity first takes the packet's `Data` (`set`), then: `RESET`: `resetTest`; `SAVE`: `saveTest`; `EXPORT`: `exportTest`; `RUN`: `runTest`. Feedback texts go to the player as system messages. In every case the handler ends with `sendBlockUpdated(pos, state, air default state, 3)`.

- `placeStructure()` (internal): settings: effective rotation, `ignore_entities`, known shape true; force-load every chunk of the structure bounding box (`setChunkForced(x, z, true)`); `StructureUtils.clearSpaceForStructure` on the test bounding box; remove all non-player entities in the test bounds (box inflated by `padding`); `placeInWorld(level, startCorner, startCorner, settings, level.getRandom(), 818)` (818 = 2 + 816).
- `resetTest(feedback)`: remove barriers (below), clear error markers, `placeStructure()`; on success send the green translation `test_instance_block.reset_success` with the test name; then `data := data.withStatus(cleared)`.
- `saveTest(feedback)`: structure id = the test's `structure` (or, with no test holder, derived from the test key), absent gives the red message `test_instance_block.error.unable_to_save` (x, y, z); on a server level call the static `StructureBlockEntity` save with origin `getStructurePos()`, size `data.size`, `ignore_entities`, author `""`, write to disk true, ignore list [air].
- `exportTest`: `saveTest` then an export of the template file through the test template manager; when exporting is disabled the red text "Test structure exporting is disabled" is sent. Details of path and file layout were not traced (Open question 11).
- `runTest(feedback)`: needs a test (else red `test_instance_block.error.no_test`); `placeStructure()` (failure gives red `test_instance_block.error.no_test_structure`); clear error markers; clear the game test ticker and the failed test tracker; send `test_instance_block.starting` with the test name; build a `GameTestInfo` (test, rotation, no retries), `setTestBlockPos`, and start a game test runner for it. The runner (ticks, assertions, timeouts) is not specified here (Open question 8).
- `encaseStructure()` and `removeBarriers()` walk the boundary of the structure's bounds (positions where x, y or z equals the box's min or max; with the test's `skyAccess` the top layer is skipped) and place `barrier` blocks where the block is not a test instance block, or replace `barrier` by air. They use `setBlockAndUpdate` (flags 3).
- Block `TestInstanceBlock.useWithoutItem`: with the entity and a game master player, opens the screen on a client level and returns `SUCCESS`, else `PASS`.

---

## 11. Operator rules

### 11.1 `canUseGameMasterBlocks`

`Player.canUseGameMasterBlocks()` is true when the player has the `instabuild` ability (creative mode) AND holds the permission `COMMANDS_GAMEMASTER` (level 2 or more, 15 §2). Every handler of this part (Set Command Block, Set Structure Block, Set Jigsaw Block, Jigsaw Generate, Set Test Block, Test Instance Block Action) and every screen-opening `useWithoutItem` requires it. Only Set Command Block tells the player (`advMode.notAllowed`); the others ignore the packet.

### 11.2 `OP_ONLY_CUSTOM_DATA` and the item data

`BlockEntityTypes.OP_ONLY_CUSTOM_DATA` is a set of exactly six block entity types: `command_block`, `lectern`, `sign`, `hanging_sign`, `mob_spawner`, `trial_spawner` (31-1 §3.2); `BlockEntityType.onlyOpCanSetNbt()` is membership in it. The entity side has its own set `EntityTypes.OP_ONLY_CUSTOM_DATA` (see 45 and 46 §entity types for its three members). The structure, jigsaw, test and test instance blocks are NOT in the set.

Uses (server side, `BlockItem.updateCustomBlockEntityTag(level, player, pos, stack)`, called when an item is placed):

1. On a client level: do nothing, return false.
2. Read the stack's `block_entity_data` component (a typed entity data with a block entity type); if absent, or no block entity exists at the position, return false.
3. If the placed block's entity type differs from the component's type: return false.
4. If `onlyOpCanSetNbt()` for that type: the data is applied only when the placing player is not null AND `canUseGameMasterBlocks()` is true; otherwise return false (the data is discarded, the entity keeps its defaults).
5. Otherwise load the component's tag into the entity (`loadInto`) and return the result.

Note: step 4 requires creative mode as well as the permission, while 31-1 §3.2 says "operators".

The tooltip warning: `BlockItem.shouldPrintOpWarning(stack, player)` is true when the player is not null, holds the permission `COMMANDS_GAMEMASTER` (without needing creative), and the stack's `block_entity_data` names a type for which `onlyOpCanSetNbt()` holds. `ItemStack` (tooltip construction, two places) then appends three lines (the constant `OP_NBT_WARNING`): translation key `item.op_warning.line1` in red and bold, `item.op_warning.line2` in red, `item.op_warning.line3` in red. The texts are language data (22, 14).

---

## 12. Worked examples

### 12.1 A new repeating command block with a command

A creative operator places a `repeating_command_block` (no `block_entity_data`) while the rule `send_command_feedback` is true; then types `say hi` in the screen: mode AUTO, track output on, conditional off, "always active" off, and OKs.

- Entity at placement: `auto := false` (1.1: repeating = false), `trackOutput := true`; `setPoweredAndUpdate(false)` no change.
- Packet 55 (command `say hi`, mode 1, flags 0x01): block already `repeating_command_block`, same state (conditional false), no replacement; `setCommand("say hi")`, `successCount 0`; track on; `setAutomatic(false)`; mode unchanged; the system message `advMode.setCommand.success`.
- Saved compound (3 keys of the base added after): `Command: "say hi"`, `SuccessCount: 0`, `TrackOutput: 1b`, `UpdateLastExecution: 1b`, `powered: 0b`, `conditionMet: 0b`, `auto: 0b` (no `CustomName`, no `LastOutput`, no `LastExecution`).
- A lever powers the block: `setPoweredAndUpdate(true)`: not auto, mode AUTO: `markConditionMet()` (true), tick scheduled for t+1. At t+1 `tick`: `prevMet` true; AUTO: `markConditionMet()`; `execute(true)`: `performCommand`: the last run was never (-1), so run `say hi`; the capture stores `lastOutput = "[14:03:07]" + message` when the source sends one; `successCount` becomes 1; `lastExecution := t+1`; the chain walk starts in `facing` (nothing there). `powered` is true: schedule the next tick at t+2. At t+2 the same happens again: `lastExecution` differs, so it runs again (every tick while powered).

### 12.2 A conditional chain

Blocks A (repeating, facing east, powered), B (chain, conditional, facing east) and C (chain, non-conditional) in a row to the east. A runs: `successCount 1`. `executeChain(A pos, east)`: step to B: a chain block in mode SEQUENCE, `powered`? B was powered only if it has its own neighbour signal or `auto`; with `auto` true (the chain block default, 1.1) B runs: `markConditionMet()`: B conditional, the block behind B (opposite of east = west) is A, a command block with `successCount 1 > 0`: true. `performCommand` runs B's command. If instead A's command failed (`successCount 0`) the flag is false and B's `successCount := 0` and B does not run; the walk still continues to C (C is not conditional: `markConditionMet()` true, C runs).

### 12.3 `Searge`

Command text `searge` (any case): `performCommand` sets `lastOutput` to `#itzlipofutzli`, `successCount 1`, returns true at once, with no command parsing, and without updating `lastExecution`.

### 12.4 Structure block scan

Structure block `S` at (12, 64, 8) in mode SAVE named `demo:house`. Corner blocks (mode CORNER, name `demo:house`) at (10, 64, 10) and (20, 70, 25). Two corners found: box (10,64,10)-(20,70,25), spans 10, 6, 15, all greater than 1. Result: `structurePos = (10-12+1, 64-64+1, 10-8+1) = (-1, 1, 3)`, `structureSize = (9, 5, 14)`. With only the first corner present: the box covers (10,64,10) and S (12,64,8): spans (2, 0, 2): the y span 0 fails (`0 > 1` false), so `detectSize` returns false and the message is `structure_block.size_failure`.

### 12.5 Structure block box geometry

`structurePos = (1, 1, 0)`, `size = (3, 2, 4)`, mirror `NONE`, rotation `NONE`: `x=1, z=0, y1=1, y2=3`, `dx=3, dz=4`, `x1=1, z1=0, x2=4, z2=4`: box local position (1,1,0), size (3,2,4). Same input with `CLOCKWISE_90`: `x1 = x+1 = 2` (`dz >= 0`), `z1 = z = 0` (`dx >= 0`), `x2 = x1 - dz = -2`, `z2 = z1 + dx = 3`: `fromCorners(2,1,0,-2,3,3)`: local position (-2,1,0), size (4,2,3). With `mirror LEFT_RIGHT` and rotation NONE: `dx = 3`, `dz = -4`: `x1 = 1`, `z1 = z+1 = 1`, `x2 = 4`, `z2 = 1 + (-4) = -3`: local position (1,1,-3), size (3,2,4).

### 12.6 Integrity

`integrity = 0.5`, seed 7: the processor list holds one `BlockRotProcessor(0.5)`; the settings' random source is `LegacyRandomSource(7)`; each block takes one `nextFloat()` in processing order and is kept when the draw is `<= 0.5`. With seed 0, the source is seeded from the clock and two placements differ.

### 12.7 Jigsaw default joint

A jigsaw saved without a `joint` key whose orientation front is `east` loads with joint `aligned`; with front `up` it loads `rollable`.

### 12.8 Test instance geometry

Block at (100, 64, 100), `padding` 2, `size (5, 3, 7)`, effective rotation `CLOCKWISE_90`: structure origin = (100+2, 64+2+1, 100+2+1) = (102, 67, 103); transformed size (7, 3, 5); bounding box (102,67,103) to (108,69,107); test box (padding 2) = (100,65,101) to (110,71,109); start corner = origin + (sizeZ-1, 0, 0) = (102+6, 67, 103) = (108, 67, 103). Renderable box: local position (2, 3, 3), size (7, 3, 5).

---

## 13. Validation

An implementation is conformant for this part when the following hold.

1. A fresh command block entity saves exactly the keys of 12.1 (no `CustomName`, `LastOutput`, `LastExecution`), and loads them back to the same state; loading an empty compound gives the defaults of 2.1 with `trackOutput` true and `updateLastExecution` true.
2. `LastOutput` is not written when `TrackOutput` is false, and is dropped on load in that case; `LastExecution` is not written when `UpdateLastExecution` is false or the value is -1, and is -1 after loading when `UpdateLastExecution` is false.
3. Powering a non-auto, non-chain command block schedules exactly one tick at delay 1 on the rising edge only; a power-off schedules nothing; an `auto` block ignores power edges (3.4).
4. Two runs of `performCommand` in the same game tick: the second returns false and does nothing; in the next tick it runs.
5. `successCount` after a run equals the number of success callbacks; it is 0 when the rule `command_blocks_work` is false or the command is empty; `Searge` gives 1 without running a command.
6. A conditional block runs only when the block behind it is a command block with `successCount > 0`; when it does not run, its `successCount` is 0.
7. A chain stops at the first block that is not a chain block in mode SEQUENCE, follows each block's `facing`, and stops after at most `max_command_sequence_length` steps with the warning; a chain block that is neither powered nor auto does not run but does not stop the walk.
8. The source of a command block: level 2 permissions, position at the block centre, yaw from `facing`, name `@` or the custom name; output capture closed after the run; the stored `lastOutput` begins with `[HH:mm:ss]` and has no space after it.
9. A Block Entity Data packet for a command block is sent only when a creative game master uses the block; chunk and block-change sends carry nothing for it.
10. Set Command Block by a player without creative and permission only sends `advMode.notAllowed`; the other five packet handlers silently ignore.
11. The structure block save and load use the 19 keys of 6.1 in that order; an entity saved without `mode` loads as `DATA`; offsets are clamped to -48..48 and sizes to 0..48 on load; `integrity` is not clamped on load.
12. Corner scan: the box rules of 6.6 reproduce 12.4 including the single-corner case that includes the structure block's own position.
13. `getRenderableBox` reproduces 12.5 for all 12 combinations of mirror and rotation (tests should cover the four rotation rows against both mirrors).
14. `placeStructureIfSameSize` returns false and adopts the template's size and author when sizes differ; true when it placed.
15. Flags for a placement from a structure block are 2, or 818 when `strict` is true; for a test instance always 818.
16. Jigsaw: all seven keys are written; a missing `joint` takes the default from the front direction; a missing pool gives `minecraft:empty`.
17. Test block: `trigger` in mode START powers the block (output 15), logs, and leaves `triggered` false; in LOG it logs and sets `triggered`; in FAIL or ACCEPT it only sets `triggered`.
18. Test instance: `errors` is written only when non-empty; `withStatus` clears the error message; geometry reproduces 12.8.
19. Item data: placing a `block_entity_data` item for `command_block` as a non-creative or non-gamemaster player leaves the entity at its defaults; for a structure, jigsaw or test block the data is applied for any player.

---

## Open questions

1. The `automatic` flag: read through the bootstrap tables, `repeating_command_block` constructs the block with false and `chain_command_block` with true (1.1). This is the opposite of what the reader would have expected from recall (recalled, not verified); a reviewer should re-read the two factory lambdas and their order in the `Blocks` initializer before an implementer relies on the table. It decides the default "always active" of a freshly placed block.
2. Client-side effect of `loadAdditional` on a command block entity: it calls `setAutomatic`, which can call `scheduleTick` and so `Level.scheduleTick` on a client level when the loaded `auto` turns on. Whether the client level ignores that call was not read.
3. The comparator signal of a command block is the raw `successCount`; the clamp to 15 of the comparator engine was not re-read here (31-1 §9.5 and the redstone document apply it).
4. `StructureTemplate.fillFromWorld`, `placeInWorld`, `StructureTemplateManager` (cache, `save`, `getOrCreate`, file location and format), and `StructureUtils.clearSpaceForStructure` are cited, not specified (36, RS20).
5. `JigsawPlacement.generateJigsaw` and the jigsaw block matching beyond `canAttach` (36, RS20); the jigsaw `getStateForPlacement` wording of 8.2 is a paraphrase of a conditional read in bytecode (the horizontal direction used as the top when the clicked face is vertical) and should be re-checked.
6. The game test framework (`GameTestRunner`, `GameTestInfo`, `GameTestTicker`, `GameTestInstance` fields `padding`, `skyAccess`, `required`, `structure`, `rotation`, the `test_instance` and `test_environment` data) is not specified; only the block entity side is.
7. The exact NBT string written for `rotation`, `mirror` and `mode` by the "legacy codec": the codec is a plain string codec built on the enum (`ExtraCodecs.legacyEnum`) whose encoder was not read in detail; the constant names in upper case are inferred (the decoder is a lookup by constant name).
8. Callers of `TestBlockEntity.trigger()` for the LOG, FAIL and ACCEPT modes, and the game test runner's use of `reset()`; only the START mode and the redstone path in `TestBlock.neighborChanged` were read.
9. The renderer's `renderStructureVoids` pass: whether and when it runs (it is not reached from the `submit` path that was read for modes BOX and BOX_AND_INVISIBLE_BLOCKS), the face geometry beyond the constants 0.48 and 0.5, and the exact component order of `ARGB.colorFromFloat` for the colours of 7.4 (read as alpha, red, green, blue).
10. `TestInstanceBlockEntity.getRotation()`: the two mapping lambdas from the test holder to a rotation were not resolved; the "test definition's rotation" is inferred. The `Vec3i` codec form used for `size` (inferred: an Int array of three) and the `Rotation.CODEC` strings of 10.1 (read as lower-case serialized names) should be confirmed against 00 and 07.
11. `TestInstanceBlockEntity.exportTest` and the test template manager (path validation, file format, the "testTemplates" enable condition).
12. The `Direction.toYRot` values for `up` and `down` (command block yaw when facing vertically) were not read.
13. The wording of the translation keys (`advMode.*`, `structure_block.*`, `test_instance_block.*`, `item.op_warning.*`, `jigsaw_block.joint.*`) lives in language data and was not read here.
14. The set `EntityTypes.OP_ONLY_CUSTOM_DATA` members are taken from 46 and not re-read; `SpawnEggItem` and `EntityType` use `onlyOpCanSetNbt` for entity data (the entity documents 21 and 45).
15. The `ServerPlayer.permissions()` source (how a player's `COMMANDS_GAMEMASTER` is derived) is in 15 §2; not re-read.
