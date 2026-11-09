# 31. Block entities, part 3: signs, banners, skulls, decorated pots, shelves

| Item | Value |
|---|---|
| Covers | Round RS13 part 3: `SignBlockEntity` and `HangingSignBlockEntity` (with `SignText`, `SignTextSlot`, editing, waxing, dyeing, glow ink, click commands, update tag), `BannerBlockEntity` (with `BannerPattern`, `BannerPatternLayers`), `SkullBlockEntity` (profile, note block sound, custom name, client animation), `DecoratedPotBlockEntity` (with `PotDecorations`, `DecoratedPotPattern`, wobble event and animation, single item, loot table), `ShelfBlockEntity`, and the finding that no bed block entity exists. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`; protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read (this revision adds `CeilingHangingSignBlock`, `WallHangingSignBlock`, `Items`, `Item$Properties`, `ByteBufCodecs` and its optional and either wrappers, and a scan of all `net/minecraft` classes for `setWaxed`): `BlockEntity`, `BlockEntityTypes`, `SignBlockEntity`, `HangingSignBlockEntity`, `SignText` and `SignText$Mutable`, `SignTextSlot`, `SignBlock`, `SignApplicator`, `DyeItem`, `GlowInkSacItem`, `InkSacItem`, `HoneycombItem`, `HangingSignItem`, `BannerBlockEntity`, `BannerPattern`, `BannerPatternLayers` (and `Layer`, `Builder`), `AbstractBannerBlock`, `SkullBlockEntity`, `AbstractSkullBlock`, `SkullBlock`, `ResolvableProfile` (and `Partial`, `Static`, `Dynamic`), `PlayerSkin$Patch`, `ExtraCodecs` (profile parts), `DecoratedPotBlockEntity` (and `WobbleStyle`), `PotDecorations`, `DecoratedPotPattern`, `DecoratedPotPatterns`, `DecoratedPotBlock`, `DecoratedPotRenderer`, `ItemStackTemplate`, `ShelfBlockEntity`, `ShelfBlock`, `DyeColor`, `ChatFormatting.stripFormatting`, `ServerboundSignUpdatePacket`, `ClientboundOpenSignEditorPacket`, `ClientboundBlockEntityDataPacket`, `ServerGamePacketListenerImpl` (sign update), `ServerPlayer.openTextEdit`, `ClientPacketListener` (block entity data, sign editor), `AbstractSignEditScreen`, `AbstractSignRenderer`. |
| Evidence rule | Every key, constant and rule below was read in this round. "(inferred)" marks a deduction from the shape of read code. "(recalled, not verified)" marks a statement not read; each is repeated in Open questions. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001; design README Parts 0, 1, 4; GAP-8). Data rows are not tabulated: the 43 `banner_pattern` entries and the 23 `decorated_pot_pattern` entries are JSON in the data pack (04 section 6, 23), and sound events, models and textures come from the resource pack. Code-defined content is complete here: field schemas, defaults, interaction rules, event ids, animation formulas. The shared block entity model (ids, `x`/`y`/`z`, `components`, load and save order, `BlockEntityData` packet, setChanged) is in 31 part 1 and is not repeated; this document states only what each type adds. Chiseled bookshelf (part 2), beacon beam owner (part 5), copper golem statue and potent sulfur (part 8) are other parts. Siblings: 31 parts 1, 2, 4 to 8. |

Conventions: NBT notation as in 07 and 45 section 2 (`Byte`, `Int`, `String`, `List<T>`, `Compound`); a Text Component is the JSON-or-NBT component of 00. "Absent" means the key is not in the compound. "Update tag" is the compound inside `ClientboundBlockEntityDataPacket` (05a, id 6) and in chunk data (06).

## Contents

1. Types and owning blocks
2. Signs and hanging signs
3. Banners
4. Skulls
5. Decorated pots
6. Shelves
7. Beds
8. DyeColor (values used here)
9. Worked examples
10. Validation checklist
11. Open questions

---

## 1. Types and owning blocks

`BlockEntityTypes` declares 49 `public static final` types in this artifact. The ones in this document:

| Type field | Class | Created by (`newBlockEntity`) | Notes |
|---|---|---|---|
| `SIGN` | `SignBlockEntity` | `SignBlock` (standing, wall) | text width 90, line height 10 |
| `HANGING_SIGN` | `HangingSignBlockEntity` | hanging sign blocks | text width 60, line height 9; extends `SignBlockEntity` |
| `BANNER` | `BannerBlockEntity` | `AbstractBannerBlock` (standing and wall banners) | base colour is read from the block |
| `SKULL` | `SkullBlockEntity` | `AbstractSkullBlock` (every head, floor and wall) | valid blocks read from the type declaration, 14: `skeleton_skull`, `skeleton_wall_skull`, `creeper_head`, `creeper_wall_head`, `dragon_head`, `dragon_wall_head`, `zombie_head`, `zombie_wall_head`, `wither_skeleton_skull`, `wither_skeleton_wall_skull`, `player_head`, `player_wall_head`, `piglin_head`, `piglin_wall_head` |
| `DECORATED_POT` | `DecoratedPotBlockEntity` | `DecoratedPotBlock` | |
| `SHELF` | `ShelfBlockEntity` | `ShelfBlock` | 3 slots |

The registry ids (the `id` key and the VarInt in the data packet) are the registered names of these fields, numbered in field declaration order (0 to 48); the full 49-row table with ids is in 31 part 1 section 3.1 (checked: it lists all 49 fields, `furnace` first and `potent_sulfur` last, id 48) and the ids are repeated in 46 section 5.4. Server tickers: `ShelfBlock`, `DecoratedPotBlock` and `AbstractBannerBlock` declare no `getTicker` method (checked with the class method lists), so `SHELF`, `DECORATED_POT` and `BANNER` never tick on the server (the base-class default was not read, presumably no ticker; inferred, Open question 17); the pot wobble and the skull animation are client state only. The sets of valid blocks per type (other than SKULL, listed above) are block registry data (24 parts 1 to 8) and are not read again here.

## 2. Signs and hanging signs

### 2.1 State

| Field | Type | Default | Persisted | Notes |
|---|---|---|---|---|
| `frontText` | `SignText` | `SignText.EMPTY` | yes, key `front_text` | |
| `backText` | `SignText` | `SignText.EMPTY` | yes, key `back_text` | |
| `isWaxed` | boolean | false | yes, key `is_waxed` (always written) | locks editing and dyeing |
| `allowOpFeatures` | boolean | false | key `allow_op_features`, written only when true | the class has no setter; it can only become true from NBT |
| `playerWhoMayEdit` | UUID or none | none | no | session state of the editor lock |

Hanging signs differ only in `getMaxTextLineWidth()` = 60, `getTextLineHeight()` = 9 and the "interaction failed" sound (`waxed_hanging_sign_interact_fail` instead of `waxed_sign_interact_fail`). Standing signs: 90 and 10.

### 2.2 SignText

A `SignText` has four fields: `messages` (4 Text Components), `filteredMessages` (4 Text Components), `color` (a `DyeColor`) and `hasGlowingText` (boolean). `EMPTY` is four empty components in both lists, colour `black`, glowing false. Text is immutable; changes build a new value (`withColor`, `withGlowingText` return the same object when nothing would change, which is how "no change" is detected).

NBT compound (`SignText.CODEC`, a record codec followed by a validation):

| Key | Type | Required | Default | Notes |
|---|---|---|---|---|
| `messages` | List of exactly 4 Text Components | yes | | list size must be 4 (`listOf(4, 4)`) |
| `filtered_messages` | List of exactly 4 Text Components | no | the value of `messages` | lenient optional: a malformed value is treated as absent |
| `color` | String, a dye colour name (section 8) | no | `black` | |
| `has_glowing_text` | Byte (boolean) | no | false (0) | |

Validation: after decoding, `filtered_messages.size()` must equal `messages.size()`; otherwise the error "Filtered and raw line counts are not equal" is raised and the whole `SignText` fails to decode.

Saving: `filtered_messages` is written only when it differs from `messages` (list equality). `color` and `has_glowing_text` are always written (the "always present" optional form).

Failure on load: a `front_text` or `back_text` that fails to decode is replaced by `SignText.EMPTY` (the read returns empty and `orElse(EMPTY)` applies), with the problem logged.

Stream form (`SignText.STREAM_CODEC`, used when the text travels as an item component, not in the block entity packet): a composite of four parts in this order:

| # | Part | Wire form |
|---|---|---|
| 1 | `messages` | exactly 4 components, each as `ComponentSerialization.STREAM_CODEC` (00), with no count prefix (`fixedSizeList(4)`) |
| 2 | filtered list | the same fixed list of 4, wrapped by an optional operation, taken from `filteredMessagesForSerialization` (empty when the two lists are equal, so the optional is absent) |
| 3 | `color` | `DyeColor.STREAM_CODEC` (a VarInt id, section 8) |
| 4 | `hasGlowingText` | boolean, one byte |

The `ByteBufCodecs.optional` wrapper was read: it writes a boolean first (1 byte, true when present), then the value only when present; decoding reads the boolean and yields empty when it is false. So with equal lists part 2 is the single byte `00`; with different lists it is `01` followed by 4 components. On decode, the four parts feed the static factory `load(messages, optional filtered, color, glowing)`, which builds the text with `filtered = optional.orElse(messages)` (read; the same factory is the combiner of both the NBT record codec and the stream codec), so an absent part 2 leaves the filtered list equal to `messages`.

Predicates used by interaction code:

| Method | Result |
|---|---|
| `hasMessage(filtering)` | true if any line of `getMessages(filtering)` has a non-empty plain string (`getString()` non-empty) |
| `hasEditableText(filtering)` | true if every line of `getMessages(filtering)` is the shared empty component OR has literal (plain text) contents; a line using a translatable, selector, score or NBT component makes the side non-editable |
| `hasAnyClickCommands(filtering)` | true if any line's style carries a click event whose action is `run_command` |
| `getMessages(filtering)` | `filteredMessages` when `filtering` is true, else `messages` |

`filtering` is `Player.isTextFilteringEnabled()` of the acting player. In a server without a text filter the filtered text equals the raw text (`FilteredText.passThrough`: raw string and an empty mask), so both lists stay equal (inferred from the pass-through factory; no filter service is read).

### 2.3 SignTextSlot

Enum with ids: `BACK` = 0, `FRONT` = 1. The stream codec is `ByteBufCodecs.idMapper` over a continuous id map with the out-of-bounds strategy `ZERO`: a VarInt out of range maps to `BACK` (matches 05c, "out-of-range value maps to 0").

### 2.4 Which side a player faces

`getSlotPlayerIsFacing(player)`: only when the block is a `SignBlock`; otherwise `FRONT`.

1. Centre = block position plus `getSignHitboxCenterPosition(state)`; `SignBlock.getSignHitboxCenterPosition` returns the constant (0.5, 0.5, 0.5), and `SignBlockEntity` delegates to the block's method. Of the sign block classes (`PlainSignBlock`, `StandingSignBlock`, `WallSignBlock`, `HangingSignBlock`, `CeilingHangingSignBlock`, `WallHangingSignBlock`) only `WallSignBlock` overrides it: it returns the centre of the bounding box of its facing-indexed shape. The wall sign shape table is built from one box (x 0 to 16, y 4.5 to 12.5, z 14 to 16, in sixteenths) passed through a horizontal rotation helper, so in the base orientation the centre is (0.5, 0.53125, 0.9375); the centres for the other three facings are the rotations of that box about the block centre (inferred; the facing-to-rotation mapping was not read, Open question 18). Standing sign and all hanging sign blocks use (0.5, 0.5, 0.5).
2. `dx = player.x - (blockX + centre.x)`, `dz = player.z - (blockZ + centre.z)`.
3. `signYaw = getYRotationDegrees(state)` (abstract; per block class).
4. `playerAngle = atan2(dz, dx) * 57.2957763671875 - 90` (float).
5. `FRONT` when `degreesDifferenceAbs(signYaw, playerAngle) <= 90`, else `BACK`.

### 2.5 Using a sign (`SignBlock`)

Terms: an *applicator* is an item that implements `SignApplicator` (dyes, ink sac, glow ink sac, honeycomb). `mayBuild` is `Player.mayBuild()`.

`useItemOn` (item in hand), in order:

1. Block entity missing or not a sign: result PASS.
2. `canApply` = item is an applicator AND `mayBuild`.
3. Client side: return SUCCESS when `canApply` or the sign is waxed; otherwise CONSUME.
4. Server side: when `!canApply`, or the sign is waxed, or another player holds the edit lock (`playerWhoMayEdit` set and different from this player): result `TRY_WITH_EMPTY_HAND` (the empty-hand path of 2.6 then runs).
5. `slot = getSlotPlayerIsFacing(player)`. Ask the applicator `canApplyToSign(text of slot, stack, player)`; the default is "the side has a non-empty message" (`hasMessage(filtering)`); only honeycomb overrides it to always true. If false: `TRY_WITH_EMPTY_HAND`.
6. Ask `tryApplyToSign(...)`. If it returns false: `TRY_WITH_EMPTY_HAND`.
7. On success: run click commands of that side (2.7, result ignored), award the item-used statistic, emit game event `block_change` at the sign, consume 1 item from the stack, result SUCCESS.

Applicators (the tinted dye comes from the item's `dye` data component, not from the item class):

| Item class | Effect through `updateText` | Sound (source blocks, volume 1, pitch 1, at the sign, no source entity) |
|---|---|---|
| `DyeItem` | `withColor(dye component colour)`; fails (no change) when the component is absent or the colour is already that colour | `dye_use` |
| `InkSacItem` | `withGlowingText(false)`; fails when already not glowing | `ink_sac_use` |
| `GlowInkSacItem` | `withGlowingText(true)`; fails when already glowing | `glow_ink_sac_use` |
| `HoneycombItem` | `setWaxed(true)` on the block entity; fails when already waxed. On success: level event 3003 at the sign (data 0) and `honeycomb_wax_on` | `honeycomb_wax_on` |

Waxing is one-way. `SignBlockEntity.setWaxed` is called from exactly one place, `HoneycombItem.tryApplyToSign`, and always with `true`: a scan of every class under `net/minecraft` in the jar found only `HoneycombItem` and the definition in `SignBlockEntity` mentioning `setWaxed`, and the jar contains no `AxeItem` class. So no code path in this artifact un-waxes a sign; only NBT (`is_waxed`), the `waxed` item component, or a block entity replacement changes it back.

`updateText(op, slot)` applies `op` to the text of that side; if the result is a different object it calls `setText` (which stores and runs `markUpdated`) and returns true, else false. `markUpdated` = `setChanged()` then `sendBlockUpdated(pos, state, state, flags 3)`; flags 3 means "update clients and neighbours" and queues the update packet (05a, id 6).

### 2.6 Using a sign with an empty hand (`useWithoutItem`)

Order of checks: first, a missing or non-sign block entity gives PASS. Then, on a level that is not a `ServerLevel`, the method builds an `IllegalStateException` ("Expected to only call this on server"), passes it to `Util.pauseInIde` (a debugging hook) and returns CONSUME; the exception is not thrown. So the client result of an empty-hand click on a sign is CONSUME, and the rest of this list runs on the server only. In order:

1. Run click commands of the faced side (2.7); let `ran` be its result.
2. If the sign is waxed: play the sign's interaction-failed sound (source blocks) and return SUCCESS_SERVER.
3. If `ran`: return SUCCESS_SERVER.
4. If no other player holds the edit lock AND `mayBuild` AND the faced side `hasEditableText(filtering)`: `openTextEdit(player, sign, slot)` and SUCCESS_SERVER.
5. Otherwise PASS.

`openTextEdit`: set `playerWhoMayEdit = player.uuid`, then `ServerPlayer.openTextEdit` sends, in order, a `ClientboundBlockUpdatePacket` for the sign position (05a, id 8; refreshes the client's block entity data) and `ClientboundOpenSignEditorPacket(pos, slot)` (05a, id 61: Position, then the slot as VarInt id).

Placing a sign: `setPlacedBy` (server, placer is a `ServerPlayer`, block is a sign, block entity exists, not waxed, and the FRONT side `hasEditableText`) opens the editor for the FRONT side. Hanging signs additionally refuse placement through `WallHangingSignBlock.canPlace`; placement rules belong to 29.

### 2.7 Click commands on signs

`executeClickCommandsIfPresent(level, player, pos, slot)`: iterate the lines of the side (`getMessages(filtering)`); for each line whose style has a click event:

| Click event | If `allowOpFeatures` is true | If false |
|---|---|---|
| `run_command` | run the command (`Commands.performPrefixedCommand`) with the source of the next paragraph, in this level | nothing |
| `show_dialog` | the player opens the dialog | nothing |
| `custom` | the server handles the custom click action with `id` and optional `payload` | nothing |
| any other action | ignored | ignored |

Command source (`createCommandSourceStack(player, level, pos)`). Common to both cases: output sink `CommandSource.NULL` (no output), position = block centre (`Vec3.atCenterOf`), rotation `Vec2.ZERO`, permission set `LevelBasedPermissionSet.GAMEMASTER`, the given level and the server. The two cases differ only in identity:

| Case | Display name | Entity |
|---|---|---|
| a player is given (click commands) | the player's own name | the player |
| no player (component resolution on load, 2.7 below) | the literal "Sign" | none |

The method returns true when any line had a click event of one of the three kinds above (whether or not `allowOpFeatures` let it run). After the loop, when `allowOpFeatures` is false and the result is true, the player gets the overlay message with translation key `sign.click_actions_disabled` in red. `canExecuteClickCommands(slot, player)` is true when the sign is waxed AND the side has any `run_command` event.

Since nothing in the game sets `allow_op_features`, click actions on signs run only for signs whose NBT was authored with `allow_op_features: 1b` (commands, structure files, data packs).

Component resolution: when `allowOpFeatures` is true, `loadAdditional` post-processes every line of both loaded sides by resolving the component (selectors, scores, NBT sources) against a command source built as above with no player (display name "Sign", no entity), only when the level is a `ServerLevel` (`resolveLine` tests it and otherwise returns without resolving); the resolution context is `ResolutionContext.create(source)` and the resolver is `ComponentUtils.resolve`; a `CommandSyntaxException` is caught and the original, unresolved line component is kept. When `allowOpFeatures` is false lines are used as stored.

### 2.8 The edit packet and the text it stores

Client: `AbstractSignEditScreen` shows four single-line fields; each line is limited by the font width of the sign type (90 or 60 in font units of the block entity), and sends `ServerboundSignUpdatePacket(pos, 4 strings, slot)` when the screen is removed (05c, id 62). Each string is at most 384 characters on the wire.

Server (`handleSignUpdate`):

1. Each of the four strings is stripped of formatting: every `§` followed by one of `0-9 a-f k-o r` (case-insensitive) is removed (pattern `(?i)§[0-9A-FK-OR]`).
2. The strings go through the text filter (asynchronously); the result is four `FilteredText` values (raw string plus filter mask). The handler continues on the server thread.
3. `resetLastActionTime` for the player (the AFK clock).
4. If the chunk at `pos` is loaded and its block entity is a sign: `SignBlockEntity.updateSignText(player, slot, filtered lines)`; otherwise nothing.

`updateSignText`: if the sign is waxed, OR `player.uuid` differs from `playerWhoMayEdit`, OR the level is absent: log "Player {} just tried to change non-editable sign" (warn) and stop (the lock is NOT cleared in this branch). Otherwise `updateText` with the message update below, then `setAllowedPlayerEditor(none)`, then `sendBlockUpdated(pos, state, state, 3)` (always, even when nothing changed).

Message update, for each line index i of the current side:

- Let `old` = the existing line component of `getMessages(filtering)`; its style is kept.
- When `filtering` is true (the tested value is the boolean parameter of the edit handler, inferred from the branch layout, Open question 19): set both raw and filtered line to literal(`filteredOrEmpty`) with the old style. `filteredOrEmpty` is the string with the mask applied, or the empty string.
- Otherwise: raw line = literal(`raw`), filtered line = literal(`filteredOrEmpty`), both with the old style.

Color and glow are never changed by the edit packet.

### 2.9 Editor lock tick

`SignBlockEntity.tick` (the ticker is registered through `SignBlock.getTicker` for the `SIGN` type; `CeilingHangingSignBlock.getTicker` and `WallHangingSignBlock.getTicker` were read and both register the same `SignBlockEntity.tick` for `HANGING_SIGN`): when `playerWhoMayEdit` is set, clear it if the player is not found in the level or is not within block interaction range of the sign using distance 4.0 (`isWithinBlockInteractionRange(pos, 4.0)`).

### 2.10 Persistence, update tag and components

- `saveAdditional` order: `allow_op_features` (only when true), `front_text`, `back_text`, `is_waxed`. `loadAdditional`: `allow_op_features` default false, then each side through the decode-and-resolve step, then `is_waxed` default false.
- Chunk compound (07 section 7, 31 part 1): `id`, `x`, `y`, `z`, these keys, and `components`.
- Update tag: `getUpdateTag` returns the custom-only save, which is exactly `saveAdditional` (no `id`, `x`, `y`, `z`, no `components`). The packet is `ClientboundBlockEntityDataPacket.create(be)` (05a, id 6) built from that tag. The client finds the existing block entity of that type at that position and calls `loadWithComponents` on the tag; it creates nothing.
- Data components: `applyImplicitComponents` reads `sign_text_front` and `sign_text_back` (default `EMPTY`) and sets `isWaxed` when a `waxed` (unit) component is present. `collectImplicitComponents` writes the two texts and the `waxed` unit when waxed. `removeComponentsFromTag` discards `front_text`, `back_text` and `is_waxed` (so item-supplied `block_entity_data` does not duplicate them).

### 2.11 Client text rendering rules

Only what depends on block entity state (the geometry and font belong to 12):

- Each side is drawn when its `SignText` is non-null (always, for a normal sign). Four lines; each line is split to the sign's maximum line width (`getMaxTextLineWidth`) and only the first piece is drawn (an empty split list gives `FormattedCharSequence.EMPTY`, otherwise element 0; read); with filtering enabled in the client options the filtered lines are drawn.
- Line y offset: `i * textLineHeight - (4 * textLineHeight) / 2`; each line is centred on its own width.
- Colour: the dye's text colour (section 8). Dark colour used for the non-glowing text outline: `DyeColor.textColor` scaled by 0.4 per channel, except black glowing text, whose dark colour is `0xFFF0EBCC` (the constant -988212).
- Glowing text: drawn with light coordinates `15728880` (`0xF000F0`, full block and sky light) and an outline; the outline is drawn when the colour is not black or when the "outline visible" flag is true (camera within a squared-distance threshold of the sign centre, or the local player is scoping in first person). The first-person scoping case returns true first; otherwise the camera entity's `distanceToSqr` to the block centre (`Vec3.atCenterOf`) is compared as a double with `OUTLINE_RENDER_DISTANCE`, true when strictly less. `OUTLINE_RENDER_DISTANCE` is `Mth.square(16)` = 256 (a squared distance, i.e. 16 blocks), read from the static initializer. `BLACK_TEXT_OUTLINE_COLOR` -988212 and light coordinates 15728880 as above.

## 3. Banners

### 3.1 State

| Field | Type | Default | Persisted |
|---|---|---|---|
| `baseColor` | `DyeColor` | from the block (`AbstractBannerBlock.getColor()`), 16 colour variants of the standing and wall banner blocks | no: it is a function of the block |
| `patterns` | `BannerPatternLayers` | `EMPTY` (no layers) | key `patterns`, written only when not equal to `EMPTY` |
| `name` | optional Text Component | none | key `CustomName`, written only when present (`storeNullable`) |

`MAX_PATTERNS` = 6. It is used by the tooltip (at most 6 layers shown) and by the crafting stations; the codecs do not enforce it, so NBT with more layers loads. The client `BannerRenderer` has its own private limit of 16: `submitPatterns` draws the base layer first, then loops over the layer list in list order while the index is below 16 and below the list size, so at most 16 patterns are drawn and layers after the 16th are not rendered (read). The block entity and the stored list keep all layers.

The default display name (when `CustomName` is absent) is the translatable component `block.minecraft.banner`. `Nameable.getName()` returns `CustomName` when set.

### 3.2 NBT

| Key | Type | Notes |
|---|---|---|
| `patterns` | List of Compound (layer) | layer order is draw order: the renderer draws the base, then layers in list order, first layer first, at most 16 (read, section 3.1) |
| `CustomName` | Text Component | note the capital C and N: this key keeps the old spelling, unlike the skull's `custom_name` |

Layer compound (`BannerPatternLayers.Layer.CODEC`): `pattern` (a banner pattern holder, below) and `color` (dye colour name String, required). Layers list codec: a plain list of layers (a `listOf` mapped to the record).

`pattern` is a registry holder codec for the dynamic `banner_pattern` registry: either the Identifier String of a registered pattern (the JSON files of `data/minecraft/banner_pattern/`; 43 files, all listed below) or an inline compound with the direct codec (`asset_id` Identifier, `translation_key` String; see 04 section 6). An unknown id fails the layer decode; the list then fails as a whole, and `patterns` loads as `EMPTY` (the read returns empty and `orElse(EMPTY)` applies).

The 43 registered pattern ids (file names in `data/minecraft/banner_pattern/`, counted with `unzip -Z1`; each file has `asset_id` of the same name and `translation_key` `block.minecraft.banner.<name>`, read for `stripe_bottom`): base, border, bricks, circle, creeper, cross, curly_border, diagonal_left, diagonal_right, diagonal_up_left, diagonal_up_right, flow, flower, globe, gradient, gradient_up, guster, half_horizontal, half_horizontal_bottom, half_vertical, half_vertical_right, mojang, piglin, rhombus, skull, small_stripes, square_bottom_left, square_bottom_right, square_top_left, square_top_right, straight_cross, stripe_bottom, stripe_center, stripe_downleft, stripe_downright, stripe_left, stripe_middle, stripe_right, stripe_top, triangle_bottom, triangle_top, triangles_bottom, triangles_top.

Stream form: `BannerPatternLayers.STREAM_CODEC` = VarInt-prefixed list of (holder VarInt/inline, dye colour id) pairs.

### 3.3 Update tag and components

- Update tag is `saveWithoutMetadata`: `saveAdditional` (the keys above) PLUS `components` (the block entity's explicit `components` map, 31 part 1), without `id`, `x`, `y`, `z`. The client loads it with `loadWithComponents`.
- `applyImplicitComponents`: `banner_patterns` component (default `EMPTY`) into `patterns`; `custom_name` component into `name`. `collectImplicitComponents` writes the same two. `removeComponentsFromTag` discards `patterns` and `CustomName`.
- `getItem()` builds an item stack of the block's item with all collected components applied. `AbstractBannerBlock.getCloneItemStack` (pick block) returns `getItem()` when the block entity exists, otherwise the plain block clone; so a picked banner carries its patterns and name.
- A banner item placed in the world gets its patterns and name through the shared "apply components from the placing item stack" path (31 part 1); there is no banner-specific placement code in the block entity.

### 3.4 What is not in the block entity

Loom crafting and the item tag `loom_patterns` are data and menu logic (13, RS14); shield banner decoration is the item side. The tag folder `data/minecraft/tags/banner_pattern/` holds:

| Tag | Content |
|---|---|
| `pattern_item/` folder, 10 files | one tag per patterned banner item, each listing exactly one pattern (read): `bordure_indented` lists curly_border, `field_masoned` lists bricks, and `creeper`, `flow`, `flower`, `globe`, `guster`, `mojang`, `piglin`, `skull` each list the pattern of the same name |
| `no_item_required` | 32 patterns, read in this order: square_bottom_left, square_bottom_right, square_top_left, square_top_right, stripe_bottom, stripe_top, stripe_left, stripe_right, stripe_center, stripe_middle, stripe_downright, stripe_downleft, small_stripes, cross, straight_cross, triangle_bottom, triangle_top, triangles_bottom, triangles_top, diagonal_left, diagonal_up_right, diagonal_up_left, diagonal_right, circle, rhombus, half_vertical, half_horizontal, half_vertical_right, half_horizontal_bottom, border, gradient, gradient_up |

The 32 `no_item_required` patterns and the 10 patterns of the `pattern_item/` tags do not overlap and together cover 42 of the 43; the remaining one is `base`, which is in no banner_pattern tag. How the loom uses these tags is menu logic outside this document.

## 4. Skulls

### 4.1 State and NBT

| Field | Type | Default | Key | Written when |
|---|---|---|---|---|
| `owner` | `ResolvableProfile` | none | `profile` | present (`storeNullable`) |
| `noteBlockSound` | Identifier | none | `note_block_sound` | present |
| `customName` | Text Component | none | `custom_name` (snake case) | present |
| `animationTickCount` | int | 0 | not persisted | |
| `isAnimating` | boolean | false | not persisted | |

On load each key is read independently; a decode failure gives none for that field. `custom_name` is read with `parseCustomNameSafe` (decode failure gives none).

### 4.2 ResolvableProfile (the `profile` key)

A profile is a flattened compound. It has a skin patch (optional keys) merged with an identity part.

Codec shape (read from `ResolvableProfile`): `FULL_CODEC` is a record whose identity part is `Codec.mapEither(ExtraCodecs.STORED_GAME_PROFILE, Partial.MAP_CODEC)` merged with `PlayerSkin.Patch.MAP_CODEC`, so the stored-profile form is tried first and the partial form second, both inside the same flat compound as the skin patch keys. `CODEC` is `FULL_CODEC` with `withAlternative` of `ExtraCodecs.PLAYER_NAME`, which gives the bare String shorthand below. `ExtraCodecs.MAX_PROPERTIES` = 16 bounds the properties list. `PLAYER_NAME` is a String with a length check (0 to 16 characters) plus a validation function (the validation predicate itself was not read, Open question 5).

Identity part, one of:

1. Stored profile: `id` (UUID, int-array form `UUIDUtil.CODEC`), `name` (String, 0 to 16 characters plus a validation), `properties` (optional, default empty).
2. Partial profile: `name` (optional String, 0 to 16 characters), `id` (optional UUID), `properties` (optional, default empty).

`properties` (`PROPERTY_MAP`) is either a map of String to List of String, or a list of up to 16 property compounds (`name`, `value`, `signature` optional; the `signature` and `value` key names were read in the property codec). The textures property is how a signed skin is carried.

Skin patch keys (all optional): `texture` (a resource texture Identifier, the body), `cape`, `elytra` (resource textures) and `model` (`slim` or `default`, the `PlayerModelType` serialized names: SLIM = "slim", WIDE = "default").

String shorthand: a bare String decodes as an unresolved profile by name (`createUnresolved(name)`), via the alternative codec; there is also an unresolved-by-UUID form. Unresolved profiles carry only the name or id; the client or server resolves them through a profile resolver (an online lookup), which a COBOL implementation can skip: a profile with `properties` containing textures renders without any lookup, and an unresolved one draws the default skin (47).

Stream form: `ResolvableProfile.STREAM_CODEC` is a composite of two parts in order: (1) `ByteBufCodecs.either(GAME_PROFILE, Partial.STREAM_CODEC)` and (2) `PlayerSkin.Patch.STREAM_CODEC`. The `either` wrapper was read: it writes one boolean, then the chosen side's stream codec; decoding reads the boolean and runs the first codec when true (the game profile, left) or the second when false (the partial profile, right) (the branch assignment is inferred from the layout of the read branches). The inner layouts of `GAME_PROFILE`, `Partial.STREAM_CODEC` and `PlayerSkin.Patch.STREAM_CODEC` were not read (Open question 1).

### 4.3 Components, update tag, packet

- Update tag = `saveCustomOnly` = `saveAdditional` (the three keys). Packet as 2.10.
- `applyImplicitComponents` reads the `profile`, `note_block_sound` and `custom_name` components into the fields; `collectImplicitComponents` writes them; `removeComponentsFromTag` discards the three keys.
- `note_block_sound` is read by a note block above the head to override the played sound (the note block code is in 33 or part 4, not read here).

### 4.4 Which heads tick, and the animation

`AbstractSkullBlock.getTicker`: a ticker exists only on the CLIENT (`level.isClientSide`) and only when the block is `dragon_head`, `dragon_wall_head`, `piglin_head` or `piglin_wall_head`. The server has no skull ticker.

Client tick (`SkullBlockEntity.animation`):

1. If the state has the `powered` property and `powered` is true: `isAnimating = true` and `animationTickCount += 1`.
2. Otherwise `isAnimating = false`; `animationTickCount` is kept (it does not reset, so the jaw or ear pose is frozen at the last count).

`getAnimation(partialTick)` = `animationTickCount + partialTick` when `isAnimating`, else `animationTickCount` (as a float). The model uses it as the animation time in ticks (dragon jaw and piglin ears; model geometry belongs to 34).

The `powered` property is maintained server side by `AbstractSkullBlock`: the default state has powered false; placement sets it to `level.hasNeighborSignal(pos)`; `neighborChanged` (server only) recomputes `hasNeighborSignal` and, when it differs from the stored value, sets the new `powered` value with block flags 2 (update clients). Heads also have `rotation` 0 to 15 (`ROTATION_16`; placement uses the placer's yaw segment) for floor heads and a `facing` for wall heads; shapes are in 24 part 4; the constants read here are `column(width, 0, height)` calls with first arguments 8.0 (default), 10.0 (piglin) and 8.0 (dragon outline, second argument 8.5); the heights were not captured (Open question 6).

## 5. Decorated pots

### 5.1 State

| Field | Type | Default | Persisted |
|---|---|---|---|
| `decorations` | `PotDecorations` | `EMPTY` | key `sherds`, written when not equal to `EMPTY` |
| `item` | ItemStack | empty | key `item`, written only when there is no loot table pending and the stack is non-empty |
| `lootTable`, `lootTableSeed` | `RandomizableContainer` fields | none, 0 | keys of the shared loot-table helper (`LootTable`, `LootTableSeed`; see 31 part 1 and 45 section 10) |
| `wobbleStartedAtTick` | long | 0 | no (client use) |
| `lastWobbleStyle` | `WobbleStyle` or none | none | no |

The pot holds one item stack (a single-slot container, "ContainerSingleItem"): reads and splits first unpack a pending loot table (with no player). Maximum stack size follows the item (the insert code compares with `getMaxStackSize`).

### 5.2 PotDecorations

Four optional entries, `back`, `left`, `right`, `front`, each an `ItemStackTemplate` (a template with `id` Item registry key, `count` Int in 1 to the maximum default 1, and `components` a patch default empty; the codec accepts a bare item id String as an alternative, read through a `withAlternative`). NBT:

| Key | Type | Notes |
|---|---|---|
| `back`, `left`, `right`, `front` | ItemStackTemplate compound (or item id String) | each optional; absent means a plain side |

`EMPTY` has all four absent. `allBrick(items)` gives `back = left = right = front = {id: minecraft:brick, count: 1}` (the default look of a pot made from four bricks; the recipe supplies it as data). This differs from older versions where `sherds` was a list of four item ids; the datafixer `PotDecorationsBlockEntityUnflatteningFix` exists in the jar to upgrade that old list (fix rules not specified here, Open question 7).

Which sherd item draws which pattern: the link is an item data component, `provides_pottery_pattern` (`DataComponents.PROVIDES_POTTERY_PATTERN`), whose value is a `decorated_pot_pattern` resource key. `Items` sets it on each item through `Item.Properties.potPattern(key)`; 23 items do so, and all 23 `DecoratedPotPatterns` keys are referenced there. The mapping, read from `Items`, is regular: the item named `<key>_pottery_sherd` carries the pattern key `<key>`, for every key listed below (for example `angler_pottery_sherd` carries `angler`, `arms_up_pottery_sherd` carries `arms_up`). The client renderer (`DecoratedPotRenderer.getSideSprite`) reads that component from each decoration's item; when the decoration is absent, or its item has no such component (for example the default brick), it uses the plain side sprite (`Sheets.DECORATED_POT_SIDE`). The 23 pattern keys declared in `DecoratedPotPatterns` are: angler, archer, arms_up, blade, brewer, burn, danger, explorer, flow, friend, guster, heart, heartbreak, howl, miner, mourner, plenty, prize, scrape, sheaf, shelter, skull, snort. Each is registered by the bootstrap with the asset id `<key>_pottery_pattern` (the suffix `_pottery_pattern` appended to the key's identifier); the textures with those names are in `assets/minecraft/textures/entity/decorated_pot/`. The `DecoratedPotPattern` direct codec is a record with one key `asset_id` (Identifier); the registry is a data registry of 23 JSON files in the jar, synced as `decorated_pot_pattern` (04 section 6).

Stream form: four optional `ItemStackTemplate` (optional-wrapped, in order back, left, right, front).

### 5.3 Interaction (`DecoratedPotBlock`)

Block state: `facing` (horizontal), `waterlogged`, `cracked` (04 and 24 for the state list).

`useItemOn` (item in hand):

1. Block entity missing: PASS. Client: SUCCESS.
2. Let `stored` be the pot's stored stack (after unpacking a loot table). The insert branch applies when the held stack is non-empty AND (the pot is empty OR the stored stack has the same item and components as the held stack and its count is below its maximum stack size):
   1. `wobble(POSITIVE)`.
   2. Award the item-used statistic.
   3. Move one item: take one from the player's stack (`consumeAndReturn(1)`); if the pot was empty, store that single item and set a "fill fraction" = `count / maxStackSize`; else grow the pot's stack by 1 and fraction = `newCount / maxStackSize`.
   4. Play `decorated_pot_insert` at the pot (source blocks, volume 1.0, pitch `0.7 + 0.5 * fraction`).
   5. On the server, send 7 `dust_plume` particles at (x + 0.5, y + 1.2, z + 0.5) with zero speed and zero offsets.
   6. `setChanged`; emit game event `block_change`; result SUCCESS.
3. Otherwise: `TRY_WITH_EMPTY_HAND`.

`useWithoutItem` (and the fall-through from 2): block entity missing: PASS. Otherwise: play `decorated_pot_insert_fail` (blocks, volume 1, pitch 1), `wobble(NEGATIVE)`, game event `block_change`, result SUCCESS.

The condition of step 2 was read from the bytecode: held stack non-empty, AND (stored stack empty, OR (`isSameItemSameComponents(stored, held)` AND stored count < stored `getMaxStackSize()`)). The client returns SUCCESS before this test (the server-side check is after the `isClientSide` return), so an uninsertable item still gives client SUCCESS and only the server returns TRY_WITH_EMPTY_HAND.

Breaking: `playerWillDestroy`: when the main-hand item is in the item tag `breaks_decorated_pots` AND does not carry an enchantment in the tag `prevents_decorated_pot_shattering` (silk touch is in that tag, data), the block state is set to `cracked = true` with flags 260 (no drops from the replacement, no neighbour shapes), and then the normal destruction proceeds. Drops: `getDrops` registers a dynamic drop under the id constant `SHERDS_DYNAMIC_DROP_ID`; the loot table for the pot (data) uses the `dynamic` entry with that id, which yields the sherds' items (or the pot itself when not cracked). `cracked` also changes the sound type. Pot contents drop on removal through the container removal path (`Containers.updateNeighboursAfterDestroy` in `affectNeighborsAfterRemoval`; contents drop through the standard container drop, 31 part 1). The pot is not pathfindable (`isPathfindable` false).

### 5.4 Wobble event

| Item | Value |
|---|---|
| Block event id | `EVENT_POT_WOBBLES` = 1 (05a id 7, `ClientboundBlockEventPacket`) |
| Block event data | `WobbleStyle` ordinal: 0 = POSITIVE, 1 = NEGATIVE |
| Durations in ticks | POSITIVE 7, NEGATIVE 10 |

`wobble(style)`: only on the server (when `level` exists and is not client side): `level.blockEvent(pos, block, 1, style.ordinal())`. No state is changed on the server.

`triggerEvent(type, data)` (runs on the client when the packet arrives, and on the server for its own handler): when level exists, `type == 1` and `0 <= data < 2`: `wobbleStartedAtTick = level.getGameTime()`, `lastWobbleStyle = values[data]`, return true. Any other event goes to the base class (false).

### 5.5 Wobble animation (client)

`progress = ((float)(gameTime - wobbleStartedAtTick) + partialTick) / (float)lastWobbleStyle.duration` (float arithmetic, computed in `extractRenderState`), or 0 when no wobble has started (the code stores 0 when `lastWobbleStyle` is none or the level is absent). The pot is drawn with the block's facing transform (rotation about (0.5, 0.5, 0.5) by `180 - facing yaw` degrees), then, only while `0 <= progress <= 1`:

- POSITIVE: let `a = progress * 2π`; `rx = (-1.5 * (cos a + 0.5)) * sin(a / 2)`; `rz = sin a`. Rotate about axis X by `rx * 0.015625` radians and about axis Z by `rz * 0.015625` radians, both around the pivot (0.5, 0, 0.5), X first then Z.
- NEGATIVE: let `r = sin(-progress * 3π) * 0.125`; rotate about axis Y by `r * (1 - progress)` radians around the pivot (0.5, 0, 0.5).

(Trigonometric functions are the game's `Mth.sin` and `Mth.cos` table versions, whose signature takes a double (`sin(double)` and `cos(double)` return float), so the float arguments are widened to double; the value tables are not read, Open question 10.) The model has parts neck, top, bottom (base texture sheet) and front, back, left, right sides (pattern texture or the plain side texture when the side has no decoration); the model geometry is 34 and the textures are data.

### 5.6 Components and update tag

- Update tag = `saveCustomOnly` = `saveAdditional` (`sherds`, loot table keys or `item`). The data packet is sent through `getUpdatePacket` (as 2.10).
- `applyImplicitComponents`: `pot_decorations` (default `EMPTY`) and `container` (first stack of the contents) into `decorations` and `item`. `collectImplicitComponents` writes `pot_decorations` and `container` (a one-element contents). `removeComponentsFromTag` discards `sherds` and `item`.
- `createDecoratedPotTemplate(decorations)` builds the template of item `decorated_pot` with the `pot_decorations` component, used by the crafting recipe type `DecoratedPotRecipe` (data and recipe class).

## 6. Shelves

### 6.1 State and NBT

| Field | Type | Default | Key | Notes |
|---|---|---|---|---|
| `items` | NonNullList of 3 ItemStacks | all empty | `Items` | `MAX_ITEMS` = 3 |
| `alignItemsToBottom` | boolean | false | `align_items_to_bottom` | always written (Byte) |

`saveAdditional`: `ContainerHelper.saveAllItems(output, items, true)` then `align_items_to_bottom`. The `true` argument is "also write when all slots are empty" (so the `Items` list is always present, possibly empty; see 45 section 9 for the slot list form: List of compounds, each an ItemStack compound plus a `Slot` Byte). `loadAdditional`: clear the list to empty stacks, load all items, then the boolean (default false). Slots outside 0 to 2 are ignored by the list loader (45 section 9).

### 6.2 Update tag, components, visual

- Update tag: `saveAllItems(..., true)` plus `align_items_to_bottom`: the same two keys, no `id`/`x`/`y`/`z`/`components`.
- `applyImplicitComponents`: the `container` component copied into the 3 slots; `collectImplicitComponents`: the `container` component from the 3 stacks; `removeComponentsFromTag` discards `Items`.
- `setChanged(event)`: base `setChanged`, emit the game event with the block state context (default event `block_activate`, via `setChanged()`), then `sendBlockUpdated(pos, state, state, 3)`: every change is pushed to clients.
- The shelf is an `ItemOwner`: its visual rotation is the `facing` property's opposite direction yaw in degrees (`getVisualRotationYInDegrees`), its position is the block centre. `stillValid` is the standard block entity range test.
- `alignItemsToBottom` is not changed by any code read in the block entity or block; it is data (placed by command or structure). The renderer uses it (client; not read, Open question 11).

### 6.3 Interaction (`ShelfBlock`)

Block states: `powered`, `facing` (horizontal), `side_chain_part` (`SideChainPart`: how a shelf joins its neighbours), `waterlogged`. A shelf is a "side chain" block: neighbouring powered shelves in a row share a chain (the chain and rows logic, `getMaxChainLength`, `getAllBlocksConnectedTo`, `onPlace`/`neighborChanged` chain updating, and the analog output are in 29 or part 2; not read in full here, Open question 12). `getRows()` and `getColumns()` come from the container grid interface (3 columns, 1 row inferred from `MAX_ITEMS`).

`useItemOn` (main hand only; OFF_HAND gives PASS):

1. Block entity must be a shelf, else PASS.
2. Compute the hit slot from the hit position and the facing (`getHitSlot`, an `OptionalInt`; geometry not read, Open question 12). None: PASS.
3. Client: if the selected hotbar item is empty: PASS; else CONSUME.
4. Server, shelf NOT powered: swap one slot with the held item:
   - `swapSingleItem`: swaps the shelf slot's stack with the selected stack (`swapItemNoUpdate`), puts the old shelf stack into the player's selected slot (creative players with infinite materials keep their stack when it was empty: the placed item is copied), `setChanged(item_interact_finish)` (or no event when the item has `use_effects` with `interact_vibrations` false), and reports success when the new shelf stack is non-empty or the old one was.
   - Sounds: when the swap succeeded: `shelf_take_item` if the held stack is now empty else `shelf_single_swap`; then `shelf_place_item` when the stack placed on the shelf is non-empty.
   - Result SUCCESS_SERVER with the held item transformed to the player's selected stack.
5. Server, shelf powered: multi-swap of the whole hotbar row with the shelf row (`swapHotbar`): collect all shelves connected through the side chain (`getAllBlocksConnectedTo`); for each shelf in the list, for each slot index j, the hotbar index is `9 - listSize * containerSize + (shelfIndex * containerSize + j)` (the arithmetic read: `9 - n*size` base plus running offset); swap the hotbar stack at that index with the shelf's slot; any non-empty movement marks success; `setChanged(entity_interact)`. If nothing moved: CONSUME. Sound `shelf_multi_swap`. Result SUCCESS_SERVER (held item transformed when the selected stack changed).

Sound event keys are sound registry data (resource pack `sounds.json`).

## 7. Beds

No bed block entity exists in this artifact. `BlockEntityTypes` has 49 `public static final` fields and none contains `bed`; the jar has no `world/level/block/entity/Bed*` class; `BedBlock` and `AbstractBedBlock` define no block entity method. A bed's colour is a property of its block (`BedBlock` has 16 colour variants as separate blocks, 24 part 7 and 25). Bed items and placement, the two-part state (`part`, `occupied`) and sleeping are block and player behaviour (29, 13). So: a chunk's `block_entities` list never contains a bed, and a world converted from a version that had one ignores the key (inferred from "no type registered": `loadStatic` skips an entry whose `id` is not a registered type and logs "Skipping block entity with invalid type: {}").

## 8. DyeColor (values used here)

Read from the `DyeColor` constructor calls: columns are `id` (also the order of the 16 stream ids; `DyeColor.STREAM_CODEC` is a continuous id map with out-of-bounds strategy ZERO, so an out-of-range id maps to `white`), serialized name (`DyeColor.CODEC` is by that name), `textColor` (sign text; the constructor passes it through `ARGB.opaque`, read, so 0xFF is set in the top byte), and `textureDiffuseColor` (opaque too). The map colours and `fireworkColor` are in 43 and 17.

| id | name | textColor (RGB) | textureDiffuseColor (RGB) | fireworkColor (RGB) |
|---|---|---|---|---|
| 0 | white | 0xFFFFFF | 0xF9FFFE | 0xF0F0F0 |
| 1 | orange | 0xFF681F | 0xF9801D | 0xEB8844 |
| 2 | magenta | 0xFF00FF | 0xC74EBD | 0xC354CD |
| 3 | light_blue | 0x9AC0CD | 0x3AB3DA | 0x6689D3 |
| 4 | yellow | 0xFFFF00 | 0xFED83D | 0xDECF2A |
| 5 | lime | 0xBFFF00 | 0x80C71F | 0x41CD34 |
| 6 | pink | 0xFF69B4 | 0xF38BAA | 0xD88198 |
| 7 | gray | 0x808080 | 0x474F52 | 0x434343 |
| 8 | light_gray | 0xD3D3D3 | 0x9D9D97 | 0xABABAB |
| 9 | cyan | 0x00FFFF | 0x169C9C | 0x287697 |
| 10 | purple | 0xA020F0 | 0x8932B8 | 0x7B2FBE |
| 11 | blue | 0x0000FF | 0x3C44AA | 0x253192 |
| 12 | brown | 0x8B4513 | 0x835432 | 0x51301A |
| 13 | green | 0x00FF00 | 0x5E7C16 | 0x3B511A |
| 14 | red | 0xFF0000 | 0xB02E26 | 0xB3312C |
| 15 | black | 0x000000 | 0x1D1D21 | 0x1E1B1B |

## 9. Worked examples

1. Dyeing. A sign's front text is `["Hi", "", "", ""]`, colour black. The player faces the front and uses a red dye (component `dye` = red). `canApplyToSign`: front has a non-empty message, true. `DyeItem.tryApplyToSign`: `withColor(red)` gives a new value, so `setText` runs and the item is consumed (1). Saved front text: `{messages:[...4 comps...], color:"red", has_glowing_text:0b}`; no `filtered_messages` key (equal lists). The packet sent: `{front_text:{...}, back_text:{...empty...}, is_waxed:0b}`.
2. Dyeing an empty side. Same but `["", "", "", ""]`: `hasMessage` false, so `TRY_WITH_EMPTY_HAND`; the editor opens instead (side is editable, not waxed).
3. Waxing, then right click. Honeycomb on a sign: `setWaxed(true)`, level event 3003, sound `honeycomb_wax_on`, item consumed even for an empty sign (`canApplyToSign` true). A later empty-hand click: waxed, so the `waxed_sign_interact_fail` sound plays (hanging sign: `waxed_hanging_sign_interact_fail`) and SUCCESS_SERVER.
4. Edit packet. Packet lines `["§aGreen", "plain", "", "x§r"]`: stripped to `["Green", "plain", "", "x"]`; with pass-through filtering and `filtering` false: raw and filtered equal; the old style of each line is kept. The editor lock is cleared and `sendBlockUpdated` is sent.
5. Edit by a stranger. A player not equal to `playerWhoMayEdit` sends the packet: warning logged, nothing changes, lock stays.
6. Banner NBT: `{patterns:[{pattern:"minecraft:stripe_bottom", color:"red"},{pattern:"minecraft:border", color:"white"}], CustomName:'"Flag"'}` on a blue banner block: base colour blue (from the block), two layers, name "Flag". Both ids exist in `data/minecraft/banner_pattern/` (section 3.2). Update tag contains `patterns`, `CustomName`, and `components`.
7. Piglin head. A piglin head on the client with `powered=true` for 30 ticks: `animationTickCount` = 30, `getAnimation(0.5)` = 30.5. Power removed: `isAnimating` false, `getAnimation(0.5)` = 30.0 and stays 30.0 (no reset). A zombie head never ticks.
8. Pot insert. Empty pot, player holds 16 sticks (max stack 64): first right click stores 1 stick, fraction 1/64, sound pitch `0.7 + 0.5 * 1/64`; a second click grows to 2, fraction 2/64; each click sends block event (pos, id 1, data 0) and 7 `dust_plume` particles. Holding an item that differs from the stored item: `TRY_WITH_EMPTY_HAND`, then `useWithoutItem`: fail sound and `wobble(NEGATIVE)` (event data 1).
9. Wobble. POSITIVE with `wobbleStartedAtTick = 100`, `gameTime = 103`, `partialTick = 0.5`: `progress = 3.5 / 7 = 0.5`, `a = π`, `rx = (-1.5 * (cos π + 0.5)) * sin(π/2) = (-1.5 * -0.5) * 1 = 0.75`, so about X by `0.75 * 0.015625 = 0.01171875` rad; `rz = sin π = 0` (about 0).
10. Shelf. Unpowered shelf, hit slot 1 empty, player holds 8 stone: the stone stack goes to shelf slot 1 and the player's selected slot receives the old (empty) stack. The swap reports success, the stack now in hand is empty, so the sound is `shelf_take_item`, then `shelf_place_item` because the shelf slot now holds stone (which stack the take-versus-swap test reads is inferred, Open question 12).

## 10. Validation checklist

1. `SignText` with 3 messages fails to decode; with 4 messages and 3 filtered messages fails; absent `filtered_messages` equals `messages`.
2. A sign never writes `filtered_messages` when equal to `messages`; always writes `color`, `has_glowing_text`, `is_waxed`; writes `allow_op_features` only when true.
3. Slot ids: back 0, front 1; VarInt 7 reads as back.
4. Dye, ink sac, glow ink sac and honeycomb: item consumed only when the action changed state; honeycomb works on blank text.
5. Edit packet strings are format-stripped and at most 384 chars; a wrong editor, waxed sign or missing sign changes nothing.
6. Sign update tag has exactly the sign keys (no `id`, `x`, `y`, `z`, `components`); banner update tag also has `components`.
7. `CustomName` (banner) versus `custom_name` (skull) spelled as above.
8. Skull animation only on client and only for the 4 dragon and piglin blocks; count not reset when power drops.
9. Pot: event id 1, data 0 or 1, durations 7 and 10; `item` key absent when a loot table is pending; cracking uses flags 260.
10. Shelf: 3 slots; `Items` always saved; `align_items_to_bottom` default false.
11. No bed block entity type; a stored `minecraft:bed` compound is skipped with a log message.
12. Colour table of section 8 reproduced exactly.

## 11. Open questions

1. The `SignText` stream layout is closed (section 2.2). Still open: the inner byte layouts of `ByteBufCodecs.GAME_PROFILE`, `ResolvableProfile.Partial.STREAM_CODEC` and `PlayerSkin.Patch.STREAM_CODEC`, which complete the `ResolvableProfile` stream form (section 4.2 states only the outer boolean and order). Searched: `ResolvableProfile`, `ByteBufCodecs` (`either`, `optional`).
2. Closed: the hanging sign ticker was read (section 2.9). Number kept so references stay stable.
3. Closed: `OUTLINE_RENDER_DISTANCE` = `Mth.square(16)` = 256 (section 2.11). Number kept so references stay stable.
4. Closed: the renderer draws at most 16 layers (private `MAX_PATTERNS` = 16 in `BannerRenderer`); the public 6 is tooltip-only (section 3.1). The pattern id list is closed (section 3.2, 43 files).
5. The validation predicate attached to `ExtraCodecs.PLAYER_NAME` (beyond the 0 to 16 length check) was not read; the stream layout of the profile is item 1.
6. Skull shape heights: only the widths (8, 10, 8, 8.5) were captured here; heights are in the block registry part.
7. The datafixer rules (`PotDecorationsBlockEntityUnflatteningFix`, `BlockEntitySignDoubleSidedEditableTextFix`, `SignTextStrictJsonFix`, `BannerPatternFormatFix`, `OminousBannerBlockEntityRenameFix`) were not specified; old-format worlds are out of scope until a datafixer round.
8. Closed: the sherd mapping is the `provides_pottery_pattern` component (section 5.2). Number kept so references stay stable.
9. Closed: the pot insert condition was read (section 5.3). Number kept so references stay stable.
10. Table-based `Mth.sin` and `Mth.cos` values (the wobble amplitude depends on them at the 1e-4 level); both are called with a double argument.
11. The shelf renderer's use of `align_items_to_bottom` and the item layout in the three slots.
12. Shelf side-chain logic (`getAllBlocksConnectedTo`, `getMaxChainLength`, `onPlace`, `neighborChanged`, comparator output), the hit slot geometry (`getHitSlot`).
13. Closed, as a fact: no code path in this jar un-waxes a sign (section 2.5; `setWaxed` is referenced only by `HoneycombItem` and `SignBlockEntity`, and there is no `AxeItem` class). The honeycomb block-to-waxed-block map used for other blocks is not part of this document.
14. The stored `components` key of every block entity (empty map encoding in `saveWithoutMetadata`): whether an empty compound or an absent key is written was not verified; shared with 31 part 1.
15. `ContainerSingleItem` maximum stack size and the pot's `canPlaceItem` rules (inferred 1 per insert; max from the item).
16. The note block override that reads `note_block_sound` was not read.
17. Whether the `EntityBlock`/`BlockBehaviour` default `getTicker` returns null (inferred: the three block classes declare none; the base class was not read).
18. `WallSignBlock` hit-box centre for facings other than the base orientation (rotation mapping of `Shapes.rotateHorizontal` not read).
19. Sign edit handler (section 2.8): the filtering branch is inferred to test the boolean parameter; the sign line-handling `(inferred)` marks elsewhere in 2.7 and 2.8 follow the same branch-layout reading.
