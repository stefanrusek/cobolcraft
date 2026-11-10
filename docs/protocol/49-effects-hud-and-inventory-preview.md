# 49. Status-effect HUD, effects panel, inventory player preview, heart-row details

| Item | Value |
|---|---|
| Covers | (1) the status-effect icons of the in-game HUD (Update Mob Effect 05b 0x87 and 09, Remove Mob Effect) and the effects panel of the inventory screens: anchors, spacing, ordering, sprites, duration text, blinking, amplifier names, tooltips, visibility rules; (2) the player-model preview of the inventory screen (12 §5.6a): box, scale, mouse following, lighting, which render-state fields are overridden; (3) the details of the health, armour, food, air and mount-health rows that 12 §5.4 does not state (blink timing, sprite tables, draw order, random-number use, rows of the air bubbles). Where this document differs from 12 §5.4 or §5.6a the difference is listed in section 6 and this document wins |
| Source artifact | `minecraft-26.3-client.jar`, version 26.3, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the jar's data files (`unzip -p`: sprite sizes and `.mcmeta`, `en_us.json`), with no execution. Classes read: `Hud`, `Hud$HeartType`, `Gui`, `EffectsInInventory`, `InventoryScreen`, `CreativeModeInventoryScreen` (only `showsActiveEffects`), `Screen`, `GuiGraphicsExtractor.entity`, `GuiEntityRenderer`, `PictureInPictureRenderer`, `MobEffect`, `MobEffects`, `MobEffectInstance`, `MobEffectUtil`, `StringUtil`, `Mth.cos`, `LivingEntity` (damage event, cooldown tick, effect tick), `LocalPlayer.hurtTo`. Review round (clean-room reviewer) re-read all of these and corrected the table row D = 95, the damage-cooldown rules and the open questions |
| Conventions | W, H = GUI-scaled window size (12 §5.1). "Tick" = a client HUD tick (20 per second, not advanced while the game is paused). All sprite coordinates are GUI pixels, 1 sprite pixel = 1 GUI pixel (12 §5.1). Values marked "(inferred)" were deduced; unread items are in section 7 |

## 1. Inputs and where they come from

| Input | Source |
|---|---|
| Active effects of the local player | the effect instances created from Update Mob Effect (09: Entity id, Effect id, Amplifier, Duration (-1 = infinite), Flags 0x01 ambient, 0x02 visible, 0x04 show icon, 0x08 blend) and removed by Remove Mob Effect. The HUD reads `getActiveEffects()` of the local player; the entry holds: effect, amplifier, remaining duration in ticks (-1 infinite), ambient flag, show-icon flag |
| Effect category | a property of each effect type (table in 2.4). "Beneficial" means category Beneficial exactly (`MobEffect.isBeneficial`); Harmful and Neutral are both "not beneficial" |
| Effect colour | the integer RGB property of each effect type (table in 2.4); used only as a sort key (2.2) |
| Sprite of an effect | the GUI sprite `mob_effect/<path of the effect's registry key>` in the namespace of the key (`Hud.getMobEffectSprite`); so `minecraft:speed` is `minecraft:mob_effect/speed`, file `textures/mob_effect/speed.png`, 18 x 18 pixels (read: speed and poison are 18 x 18 PNGs; the jar holds one file for each of the 40 effects of 2.4). The atlas rule for these sprites is in 14 §7.5 |
| Tick rate | `tickRateManager.tickrate()` of the client level, 20.0 normally (used for the duration text) |

## 2. The in-game HUD effect icons (`Hud.extractEffects`)

### 2.1 When the icons are drawn

The icon block is drawn, in the HUD layer order of `Hud.extractRenderState`, after the hotbar and its decorations and before the boss bars, and only when the GUI is not hidden (the F1 toggle `Hud.isHidden`: the whole block of camera overlays, crosshair, hotbar, effects and boss bars is skipped).

| Condition (all must hold) | Source |
|---|---|
| the player has at least one active effect | first test of the method |
| no screen is open, OR the open screen's `showsActiveEffects()` is false | `Screen.showsActiveEffects` returns false by default; only `InventoryScreen` and `CreativeModeInventoryScreen` override it, and they return `EffectsInInventory.canSeeEffects()` (3.1). So while the inventory (survival or creative) is open and wide enough for the panel, the HUD icons are NOT drawn (the panel replaces them); with any other screen (chest, chat, pause, crafting table, ...) open the HUD icons keep being drawn; with the inventory open in a window too narrow for the panel they are drawn |
| the individual effect has its show-icon flag | per-effect test in the loop; an effect without it takes no slot and does not advance the counters of 2.2 |

The debug screen (F3) does not hide the icons: the effects method contains no test of it (the debug text is drawn later by `Gui` through `Hud.extractDebugOverlay`, over the icons). The spectator game mode is not tested either (inferred from the absence of a test; the tests of the hotbar are separate). The whole HUD (this block included) is also skipped while the open screen is the level-loading screen (`Hud.extractRenderState` returns at once for it, read), and when `Gui.extractRenderState` is called with its "render HUD" flag false (Open question 1).

### 2.2 Order, anchor, columns, rows

- Effects are sorted with the effect instance's natural order (`MobEffectInstance.compareTo`) and iterated in **descending** order (reverse of 2.3). Two counters are kept, b for beneficial and h for not beneficial, both starting at 0, each incremented only for an effect that has its icon shown.
- The anchor is the **top-right corner** of the GUI. There is no wrapping and no second column: all beneficial effects form one horizontal row, all other effects form a second horizontal row below it, each growing leftwards. A row is not limited in length (inferred from the absence of any count or width test; with enough effects the row runs off the left edge).

| Effect kind | x (left edge of the 24 x 24 background) | y (top edge) |
|---|---|---|
| beneficial, the b-th one (b = 1, 2, ...) | W − 25 × b | 1 |
| not beneficial, the h-th one (h = 1, 2, ...) | W − 25 × h | 1 + 26 = 27 |

In the Demo mode (`Minecraft.isDemo`) both rows start 15 pixels lower (y + 15). Spacing: a 24-pixel sprite on a 25-pixel pitch, so 1 pixel between neighbours. The right-most icon's right edge is at W − 25 × 1 + 24 = W − 1 (1 pixel from the window edge).

**Example.** W = 427, effects Speed (beneficial), Haste (beneficial), Poison (harmful). Descending natural order gives some order of the first two; the first beneficial is at x = 402, y = 1, the second at x = 377, y = 1; Poison is at x = 402, y = 27.

### 2.3 Natural order of two effect instances (`MobEffectInstance.compareTo`)

Let D be the remaining duration (-1 when infinite), amb the ambient flag, col the effect's colour (integer compare).

- Rule A applies when (both D are greater than 32147) or (both effects are ambient). Compare amb (false before true), then col.
- Otherwise rule B: compare amb (false before true), then "infinite" (false before true), then D (smaller first), then col.

The HUD uses the reverse of this order (greatest first = nearest the right edge): ambient effects first, then infinite, then longer duration, then larger colour value. The inventory panel uses the order itself (3.2). Example: two non-ambient finite effects with 600 and 1200 ticks left: rule B puts 600 first; in the HUD the 1200-tick effect is nearer the right edge.

### 2.4 Effect table (name, category, colour)

Names are the `en_us.json` values of `effect.minecraft.<id>`; category and colour are the constructor arguments read from `MobEffects` (the same 40 ids as the 40 icon files; the count of 40 icon files counts PNG files only, not the directory entry). The rows are in registration order; the wire id of an effect is its registry id, see 46 §4. "Beneficial" = top row of 2.2; Harmful and Neutral = second row.

| Id | English name | Category | Colour (hex RGB) |
|---|---|---|---|
| `speed` | Speed | Beneficial | 33EBFF |
| `slowness` | Slowness | Harmful | 8BAFE0 |
| `haste` | Haste | Beneficial | D9C043 |
| `mining_fatigue` | Mining Fatigue | Harmful | 4A4217 |
| `strength` | Strength | Beneficial | FFC700 |
| `instant_health` | Instant Health | Beneficial | F82423 |
| `instant_damage` | Instant Damage | Harmful | A9656A |
| `jump_boost` | Jump Boost | Beneficial | FDFF84 |
| `nausea` | Nausea | Harmful | 551D4A |
| `regeneration` | Regeneration | Beneficial | CD5CAB |
| `resistance` | Resistance | Beneficial | 9146F0 |
| `fire_resistance` | Fire Resistance | Beneficial | FF9900 |
| `water_breathing` | Water Breathing | Beneficial | 98DAC0 |
| `invisibility` | Invisibility | Beneficial | F6F6F6 |
| `blindness` | Blindness | Harmful | 1F1F23 |
| `night_vision` | Night Vision | Beneficial | C2FF66 |
| `hunger` | Hunger | Harmful | 587653 |
| `weakness` | Weakness | Harmful | 484D48 |
| `poison` | Poison | Harmful | 87A363 |
| `wither` | Wither | Harmful | 736156 |
| `health_boost` | Health Boost | Beneficial | F87D23 |
| `absorption` | Absorption | Beneficial | 2552A5 |
| `saturation` | Saturation | Beneficial | F82423 |
| `glowing` | Glowing | Neutral | 94A061 |
| `levitation` | Levitation | Harmful | CEFFFF |
| `luck` | Luck | Beneficial | 59C106 |
| `unluck` | Bad Luck | Harmful | C0A44D |
| `slow_falling` | Slow Falling | Beneficial | F3CFB9 |
| `conduit_power` | Conduit Power | Beneficial | 1DC2D1 |
| `dolphins_grace` | Dolphin's Grace | Beneficial | 88A3BE |
| `bad_omen` | Bad Omen | Neutral | 0B6138 |
| `hero_of_the_village` | Hero of the Village | Beneficial | 44FF44 |
| `darkness` | Darkness | Harmful | 292721 |
| `trial_omen` | Trial Omen | Neutral | 16A6A6 |
| `raid_omen` | Raid Omen | Neutral | DE4058 |
| `wind_charged` | Wind Charged | Harmful | BDC9FF |
| `weaving` | Weaving | Harmful | 78695A |
| `oozing` | Oozing | Harmful | 99FFA3 |
| `infested` | Infested | Harmful | 8C9B8C |
| `breath_of_the_nautilus` | Breath of the Nautilus | Beneficial | 00FFEE |

### 2.5 Sprites, background, icon alpha

Each drawn effect is two sprites:

| Layer | Sprite | Size and position |
|---|---|---|
| Background, effect not ambient | `hud/effect_background` (24 x 24, plain sprite: no `.mcmeta`) | (x, y) of 2.2, drawn 24 x 24, no tint |
| Background, effect ambient | `hud/effect_background_ambient` (24 x 24, plain sprite) | same |
| Icon | `mob_effect/<id>` (18 x 18) | (x + 3, y + 3), drawn 18 x 18, tinted white with alpha `a` (below) |

There is **no duration text, no amplifier text and no name** on the HUD icons: the method draws only these two sprites per effect (read in full). Duration, amplifier and name appear only in the inventory panel (section 3). The background is always opaque; only the icon fades.

**Alpha `a` of the icon.** `a = 1.0` unless the effect is not ambient and `endsWithin(200)` is true (not infinite and D ≤ 200 ticks, i.e. the last 10 seconds). In that case, with D the remaining ticks (integer):

- k = 10 − (D div 20) (integer division; k = 0 at D = 200, k = 10 for D below 20);
- base = clamp(D / 10 / 5 × 0.5, 0, 0.5) = min(0.5, 0.01 × D);
- swing = cos(D × π / 5) × clamp(k / 10 × 0.25, 0, 0.25) = cos(D × π / 5) × min(0.25, 0.025 × k);
- a = clamp(base + swing, 0, 1).

`cos` takes radians and is `Mth.cos`, a table lookup: the argument x (double) is turned into the table index (floor(x × 10430.378350470453 + 16384)) mod 65536 and the entry is returned, so the result is the cosine quantised to steps of about 0.0001 rad, as exact as a 65536-entry sine table allows (the table's own contents were not read, Open question 9; the index rule was read). The cosine has a period of 10 ticks in D: it is +1 when D is a multiple of 10 and −1 when D is an odd multiple of 5. So during the last 10 seconds the icon flickers at 2 Hz, with an amplitude that grows from 0 (D = 200) to 0.25 (D < 20), around a base that falls from 0.5 to 0. An ambient effect never fades (its background is drawn and nothing else is tested).

| D (ticks) | k | base | swing | a |
|---|---|---|---|---|
| 200 | 0 | 0.5 | 0 | 0.500 |
| 190 | 1 | 0.5 | +0.025 | 0.525 |
| 185 | 1 | 0.5 | −0.025 | 0.475 |
| 100 | 5 | 0.5 | +0.125 | 0.625 |
| 95 | 6 | 0.5 | −0.150 | 0.350 |
| 45 | 8 | 0.45 | −0.200 | 0.250 |
| 10 | 10 | 0.1 | +0.25 | 0.350 |
| 5 | 10 | 0.05 | −0.25 | 0 (clamped from −0.200) |

D is the effect's remaining duration as counted by the client: the packet sets it, and each client tick of the entity (the effect tick of `LivingEntity`, `MobEffectInstance.tickClient`) lowers it by exactly 1 while it is infinite or above 0, never below 0 (read). An effect that reaches D = 0 stays listed, with D = 0, until a Remove Mob Effect packet arrives.

## 3. The effects panel of the inventory screens (`EffectsInInventory`)

Used by the survival inventory screen (12 §5.6a) and the creative inventory screen (only the visibility test `canSeeEffects` was read there, Open question 3). Sprite constants: `ICON_SIZE` 18, `SPACING` 7, `TEXT_X_OFFSET` 32, `SPRITE_SQUARE_SIZE` 32.

### 3.1 Visibility and geometry

| Quantity | Value |
|---|---|
| x0 (left of every row) | leftPos + imageWidth + 2 (to the right of the 176-wide container image; leftPos is shifted by the recipe book when it is open, 12 §5.6a) |
| avail (space to the right) | W − x0 (W = the screen's width) |
| `canSeeEffects` | avail ≥ 32. This is also the value of the screen's `showsActiveEffects()`, so it is what switches the HUD icons of 2.1 off |
| Drawn only when | the player has at least one active effect and avail ≥ 32 |
| Row width `rw` | avail − 7 when avail ≥ 120; otherwise 32 ("compact": icon only) |
| Row pitch (stride) | 33; when the player has more than 5 effects: 132 div (count − 1) (so 26 for 6 effects, 22 for 7; rows then overlap, later rows drawn over earlier ones) |
| y of row j (j = 0 ...) | topPos + j × stride |
| Which effects | **all** active effects: neither the show-icon flag nor the beneficial/harmful split is tested; one single column |
| Order, top to bottom | ascending natural order of 2.3 (the opposite of the HUD) |
| Draw order | the panel is drawn before the container screen's own render call in `InventoryScreen.extractRenderState` (under the container; the container image does not overlap it); the creative screen does the same (panel first, then its container render, read). Within the panel each row is drawn completely, in the order background, name and duration text, icon, before the next row starts, so with overlapping rows (stride below 32) a later row's background covers the text and icon of the row above |

### 3.2 One row

Let nameW and durW be the pixel widths (font of the screen) of the name text and the duration text (3.3, 3.4).

| Part | Value |
|---|---|
| Background width `bw` | min(rw, max(32 + nameW + 7, 32 + durW + 7)) |
| Background sprite | `container/inventory/effect_background` (32 x 32), or `container/inventory/effect_background_ambient` (32 x 32) when the effect is ambient; both are nine-slice (`.mcmeta`: type `nine_slice`, width 32, height 32, border 4) |
| Background rectangle | (x0, y), size bw x 32 (height 32, not the stride) |
| Icon | `mob_effect/<id>` at (x0 + 7, y + 7), 18 x 18, no alpha change (no blink in the panel) |
| Text area | avail_text = bw − 32 − 7; text is drawn only when avail_text > 0 (so never in compact mode, where bw = 32) |
| Name | the name text (3.3) at (x0 + 32, y + 7), colour white (-1) with shadow (the overload used passes shadow true). When nameW > avail_text it is clipped to avail_text pixels (`ComponentRenderUtils.clipText`; whether an ellipsis is added was not read, Open question 4) |
| Duration | the duration text (3.4) at (x0 + 32, y + 7 + 9), colour -8355712 = `#808080`, with shadow |

### 3.3 Name text

The name is the translated display name of the effect (the key `effect.<namespace>.<path>`, e.g. `effect.minecraft.speed`; English values in 2.4), followed, when the amplifier A satisfies 1 ≤ A ≤ 9, by a space and the translation of the key `enchantment.level.<A + 1>`. So A = 0 shows no suffix, A = 1 shows " II", A = 2 " III", ..., A = 9 " X"; **A ≥ 10 shows no suffix** (and the display name stays the plain name). English values of the keys, read: `enchantment.level.1` I, 2 II, 3 III, 4 IV, 5 V, 6 VI, 7 VII, 8 VIII, 9 IX, 10 X. (Level 1 is never shown, since A = 0 has no suffix.)

### 3.4 Duration text (`MobEffectUtil.formatDuration`, `StringUtil.formatTickDuration`)

| Case | Text |
|---|---|
| infinite (D = -1) | the translation of `effect.duration.infinite`, English "∞" (U+221E) |
| otherwise | T = floor(D × 1.0) ticks; s = floor(T / tickrate) with float division by the tick rate (20.0 normally); then m = s div 60, s = s mod 60, h = m div 60, m = m mod 60. When h > 0: `%02d:%02d:%02d` (h:m:s), otherwise `%02d:%02d` (m:s) |

There is no blink and no colour change in the panel text. Examples: D = 3600 -> "03:00"; D = 1199 -> "00:59"; D = 20 -> "00:01"; D = 19 -> "00:00"; D = 72000 -> "01:00:00" (h = 1); D = 1200000 -> "16:40:00". Speed with A = 1, D = 3600 shows the name line "Speed II" and the second line "03:00".

### 3.5 Hover tooltip

A row has a tooltip when (compact mode, or the name was clipped, i.e. nameW > avail_text) and the mouse position (mx, my) satisfies x0 ≤ mx ≤ x0 + bw and y ≤ my ≤ y + stride (the vertical test uses the stride, not 32). Its content is two plain text lines: the name text (3.3), then the duration text (3.4), no title spacing. It is queued as the frame's tooltip at the mouse position, so it is positioned and drawn by the common tooltip rules (12 §5.8: origin (mx + 12, my − 12) with the right and bottom flips, drawn after everything else). When the full text fits in a wide row no tooltip is shown.

### 3.6 Worked example

W = 427, H = 240, survival inventory, no recipe book: leftPos = (427 − 176) div 2 = 125 (assuming the container's `leftPos` is that centring, see 12 §5.6a), x0 = 125 + 176 + 2 = 303, avail = 124 (≥ 120), rw = 117. Three effects: rows at y = topPos, topPos + 33, topPos + 66; each background is 32 tall, 1 pixel gap. With W = 330: avail = 330 − 303 = 27 < 32: no panel, `showsActiveEffects()` is false and the HUD icons of section 2 are drawn instead. With W = 400: avail = 97, 32 ≤ avail < 120: compact column of 32 x 32 icon boxes, text only as tooltips.

## 4. The player-model preview of the inventory screen (`InventoryScreen.extractEntityInInventoryFollowsMouse`)

### 4.1 Box, scale, offset

Drawn in `InventoryScreen.extractBackground`, right after the 176 x 166 container texture (12 §5.6a), with the arguments:

| Argument | Value |
|---|---|
| box (x0, y0, x1, y1) | (leftPos + 26, topPos + 8, leftPos + 75, topPos + 78): 49 x 70 GUI pixels |
| scale | 30 (GUI pixels per block of model space; the renderer multiplies it by the GUI scale factor, so 1 block = 30 × guiScale device pixels) |
| "yOffset" | 0.0625 (a vertical offset in **blocks** added to the model's translation, 4.3; NOT the mouse factor that 12 §5.6a calls it) |
| mouse | xMouse, yMouse: the mouse position (GUI coordinates, integers converted to float) as stored by the **previous** call of the screen's `extractRenderState`; they are stored after the container has been rendered, so the model follows the mouse one frame late (and is at (0, 0) on the first frame) |
| entity | the local player |

### 4.2 Mouse to angles

Let cx = (x0 + x1) / 2 = leftPos + 50.5 and cy = (y0 + y1) / 2 = topPos + 43 (float division of the integer sums). Then, with `atan` in radians:

- a = atan((cx − xMouse) / 40)
- b = atan((cy − yMouse) / 40)

Values written into the player's render state (the numbers a × 20 and b × 20 are used as **degrees** although a and b are radians, so the range is about ±31.4 degrees, reached asymptotically):

| Field | Value |
|---|---|
| `bodyRot` (body yaw) | 180 + a × 20 |
| `yRot` (head yaw) | a × 20 |
| `xRot` (head pitch) | −b × 20, but 0 when the pose is `FALL_FLYING` |
| `boundingBoxWidth`, `boundingBoxHeight` | each divided by the state's `scale`, then `scale` is set to 1 (so the model is drawn at scale 1 whatever the entity's size scale) |

Two quaternions are passed: the model rotation `Rz(π) × Rx(b × 20 × 0.017453292)` (the X angle is b × 20 degrees converted to radians) and the "camera angle override" `Rx(b × 20 × 0.017453292)`. The renderer applies translate, then the model rotation, and sets the camera orientation to the conjugate of the override rotated by π about Y (the camera state is only used to place the entity renderer's billboards and lighting view; its other fields stay default). The effect is a whole-figure tilt about X by b × 20 degrees in addition to the head pitch; sideways mouse movement sets the body yaw to 180 + a × 20 and the head yaw field to a × 20 (12 §7.3 gives how the body yaw and the head yaw enter the model; that the head yaw field is relative to the body yaw is inferred, which would make the head turn up to about 62 degrees in total).

### 4.3 Placement in the box

The preview is rendered into an off-screen texture of (x1 − x0) × (y1 − y0) GUI pixels (times the GUI scale) and blitted back into the box (premultiplied-alpha blend, nearest filtering, clipped to the current scissor, none in the inventory screen). In the texture: the pose origin is at (width / 2, height / 2), and the pose is scaled by (s, s, −s) with s = guiScale × 30 (30 is the scale argument of 4.1; the entity render state's own `scale` was set to 1 in 4.2, so it contributes nothing); the entity is translated by (0, boundingBoxHeight / 2 + 0.0625, 0) blocks before the rotation. For a standing player with bounding-box height 1.8 (the value assumed in 12 §7.3, Open question 8) the feet are (1.8 / 2 + 0.0625) × 30 = 28.9 GUI pixels below the box centre and the head top (1.8 − 0.9625) × 30 = 25.1 pixels above it, so the model spans about topPos + 17.9 to topPos + 71.9 around the centre topPos + 43 (inferred from the translation and the Z rotation; the direction of the 0.0625 shift is inferred).

### 4.4 Lighting and render-state

- The render state's light coordinate is set to 15728880 (0xF000F0: block light 15, sky light 15), so the full-bright light map value is used; the diffuse lighting is the `ENTITY_IN_UI` setup of 12 §1.9 (light directions normalize(0.2, −1.0, 1.0) and normalize(−0.2, −1.0, 0.0) in view space, the formula of 12 §1.9).
- The state is created by the normal player renderer for the local player with partial tick 1.0 (`EntityRenderer.createRenderState(entity, 1.0)`), so every pose-related field is the live one: sneaking, using-item arm poses (12 §7.5), swing, held items in both hands, armour, cape, elytra, skin parts of 47, and the walking animation as of the last tick. Only the fields of 4.2 are overridden, `shadowPieces` is cleared (no shadow) and `outlineColor` is set to 0 (no glow outline). Whether the name tag is drawn was not read (Open question 5).

## 5. Heart row, armour, food, air and mount-health details (adds to 12 §5.4)

All sprites are 9 x 9 and drawn from the GUI atlas with `hud/...` ids. left = W/2 − 91, right = W/2 + 91, baseY = H − 39 (12 §5.4). The rows are drawn when the game mode can hurt the player (survival, adventure; `canHurtPlayer`); the mount-health row is drawn in all game modes while the camera player rides a living entity that shows vehicle health. The camera entity must be a player (otherwise nothing is drawn). Order of drawing and of random-number use inside `extractPlayerHealth`: armour, hearts, food (only when not riding a vehicle with hearts), air.

### 5.1 Per-frame state and the blink flag

State kept by the HUD between frames: `lastHealth`, `displayHealth`, `healthBlinkTime` (a tick count), `lastHealthTime` (milliseconds), and the HUD tick counter `tickCount`. Per frame, with health h = ceil(player health):

1. Blink flag B = (healthBlinkTime > tickCount) and ((healthBlinkTime − tickCount) div 3) is odd. It is computed first, from the values of the previous frame.
2. If h < lastHealth and the player's `damageCooldownTime` > 0: lastHealthTime = now, healthBlinkTime = tickCount + **20**. Else if h > lastHealth and `damageCooldownTime` > 0: lastHealthTime = now, healthBlinkTime = tickCount + **10**.
3. If now − lastHealthTime > 1000 ms: displayHealth = h and lastHealthTime = now. Then lastHealth = h.
4. The random source used by the rows is seeded with tickCount × 312871 (int multiplication, then widened to long) once per call, so the jitters of one frame are the same for equal tickCount.

`damageCooldownTime` is a field of the living entity, lowered by 1 per entity tick while above 0 (for every living entity except a server-side player, so for the local player on the client). It is written, on the client, by two paths: the Damage Event packet (05a 0x19, `LivingEntity.handleDamageEvent`) sets it to 20; and the Set Health packet (05b 0x6A) calls `LocalPlayer.hurtTo(newHealth)`, which behaves as follows. The first Set Health received by a given local player object only stores the health and arms a "flash" flag (no cooldown, no blink). Every later one, with delta = old health − new health: delta > 0 (health fell) sets the cooldown to 20 and then stores the health; delta < 0 (health rose) stores the health and sets the cooldown to 10; delta = 0 only stores the health. Hence a normal heal reported by Set Health starts the increase blink (5.1 step 2) as long as the HUD sees the new health while the cooldown is still above 0 (it stays above 0 for 10 ticks); a decrease reported by Set Health starts the decrease blink even when no Damage Event came. Whether the flash flag is re-armed on respawn (a new local player object) is not traced (Open question 6).

Blink phases (B true), with t = healthBlinkTime − tickCount counting down: for a decrease (start t = 20): B on at t = 17, 16, 15, then 11, 10, 9, then 5, 4, 3 (three ticks on, three off, so it starts off). For an increase (start t = 10): on at t = 10, 9 and 5, 4, 3. (First frame after the change has t = start; the flag was computed before the trigger in that frame, so the first drawn flag is for the frame after.)

### 5.2 Heart slots and sprite choice

Let M = max(max health attribute, max(displayHealth, h)) (float), A = ceil(absorption), Hh = ceil(M / 2) health hearts, Ah = ceil(A / 2) absorption hearts; rows R = ceil((M + A) / 2 / 10); rowHeight = max(10 − (R − 2), 3) (as 12 §5.4). Slots i run from Hh + Ah − 1 **down** to 0 (drawing order and random-number order are descending), with x = left + 8 × (i mod 10), y = baseY − (i div 10) × rowHeight, then:

1. if h + A ≤ 4 (ceil health plus ceil absorption; NOT displayHealth, see 6): y += random.nextInt(2) (one call per slot);
2. if i < Hh and i equals the regeneration index (tickCount mod ceil(M + 5), only while the player has Regeneration): y −= 2.

Draws per slot, in this order, each at (x, y):

| Step | Condition | Sprite id (all under `hud/heart/`) |
|---|---|---|
| Container | always | `container` / `container_blinking` (B) ; hardcore: `container_hardcore` / `container_hardcore_blinking` |
| Absorption heart | i ≥ Hh and u = 2i − 2 × Hh satisfies u < A: half when u + 1 == A, else full; never the blinking variant | type X_ABSORB below |
| Blinking "ghost" | B and 2i < displayHealth: half when 2i + 1 == displayHealth, else full; blinking variant | type X below |
| Current health | 2i < h: half when 2i + 1 == h, else full; plain variant | type X below |

Heart type X (checked in this priority): Poison -> `poisoned`; else Wither -> `withered`; else the player is fully frozen (`isFullyFrozen`) -> `frozen`; else normal (`full`, `half`, no prefix). The absorption hearts are `withered` when the type is withered, otherwise always `absorbing` (poison and frozen do not change them). Sprite name = `<type>_<full|half>[_blinking]` for a non-hardcore world and `<type>_hardcore_<full|half>[_blinking]` for a hardcore world (the normal type is `full`, `half`, `hardcore_full`, `hardcore_half`, with `_blinking`). Every type has the full and half sprite, each in plain and blinking form, each in non-hardcore and hardcore form (counted in the jar, PNG files only: 5 types x 8 files = 40 heart sprite files, plus 4 container files, plus the 3 vehicle files of 5.6; 47 PNG files in `hud/heart/`). "Hardcore" is the hardcore flag of the world (Login / Respawn, 05a).

So with a hurt blink the container and the ghost heart flash while the real heart (drawn last) shows the lower value; the part between the new health and the old (display) health is the visible flash.

### 5.3 Armour row

Drawn before the hearts only when the armour value N > 0. y = baseY − (R − 1) × rowHeight − 10; x = left + 8i for i = 0..9; i-th icon: `hud/armor_full` when 2i + 1 < N, `hud/armor_half` when 2i + 1 == N, `hud/armor_empty` when 2i + 1 > N (so a row of empty icons backs a partly filled one). Armour N up to 20 fills the row. No animation, no jitter.

### 5.4 Food row

For i = 0..9: x = right − 8i − 9, y = baseY, with `hud/food_empty`, `hud/food_half`, `hud/food_full`, or while the player has Hunger `hud/food_empty_hunger`, `hud/food_half_hunger`, `hud/food_full_hunger`. Draw the empty icon always, then the full icon when 2i + 1 < food level, or the half icon when 2i + 1 == food level. Saturation jitter: when saturation ≤ 0 and tickCount mod (food × 3 + 1) == 0, **each** icon gets y += random.nextInt(3) − 1 (one call per icon, i = 0 first, continuing the random sequence after the heart row's calls). Not drawn when a mount with hearts is ridden. The air row (5.5) draws its own random numbers from the same source, after the food row's.

### 5.5 Air bubbles

Drawn (after the food row) when the player's eyes are in water or the air supply is below the maximum. Let m = the player's max air supply, a = air supply clamped to 0..m, inWater = eye in water. y of the row = H − 49 − 10 × (mountRows − 1) when riding a mount with hearts (mountRows = ceil(mountHearts / 10) ≥ 1), and H − 49 when not riding (the food row is below at y = H − 39). Bubble n = 1..10 at x = right − 8 × (n − 1) − 9. Define c(e) = ceil((a + e) × 10 / m) as a float-division ceiling.

| Quantity | Value |
|---|---|
| full | c(−2) |
| popping index | c(0) |
| delay | 1 when a == 0 and inWater, else 0 |
| empty count | 10 − c(delay) |

For n = 1..10, the first matching rule: n ≤ full -> `hud/air`; (full != popping index) and n == popping index and inWater -> `hud/air_bursting` (and the pop sound, below); n > 10 − empty count -> `hud/air_empty`, drawn at y + random.nextInt(2) when the empty count is 10 and tickCount is even, else at y; otherwise nothing is drawn for that n. Pop sound: `bubble_pop` played at the player when the popping index differs from the last played one, volume 0.5 + 0.1 × max(0, empty count − 3 + 1), pitch 1.0 + 0.1 × max(0, empty count − 5 + 1). When the player's eyes are out of water the last-played memory is reset to 0.

Example: m = 300, a = 300 in water: full = ceil(298 × 10 / 300) = 10 bubbles; a = 150: full = ceil(1480 / 300) = 5, popping index = 5, empty count 10 − ceil(1500 / 300) = 5, so bubbles 1..5 are `air` (n ≤ 5) and bubbles 6..10 are `air_empty` (n > 10 − 5), with no bursting bubble because full equals the popping index.

### 5.6 Mount-health row (`extractVehicleHealth`)

Drawn when the camera player's vehicle is a living entity whose `showVehicleHealth` is true; mountHearts = min(30, floor(maxHealth + 0.5) div 2). mountHealth = ceil(vehicle health). Rows of up to 10 hearts, right-aligned: for row r = 0, 1, 2 (each of up to 10 hearts) y = baseY − 10 × r, x = right − 8 × j − 9 for j = 0..9; offset o = 20 × r; each heart draws `hud/heart/vehicle_container`, then `hud/heart/vehicle_full` if 2j + 1 + o < mountHealth, else `hud/heart/vehicle_half` if 2j + 1 + o == mountHealth. No blinking or jitter. While this row exists the food row is not drawn. Which entities set `showVehicleHealth` was not read (Open question 7).

## 6. Differences from document 12

| Where in 12 | 12 says | Read in this round |
|---|---|---|
| §5.4 hurt blink | lasts 10 ticks (decrease) or 6 ticks (increase), alternating each 3 ticks | `healthBlinkTime` is set to tickCount + 20 on a decrease and + 10 on an increase; the flag is on when (blinkTime − tickCount) div 3 is odd (5.1) |
| §5.4 jitter | the test uses `displayHealth + absorption ≤ 4` | the arguments passed are the ceil of the current health and the ceil of absorption (5.2); displayHealth is used only for the ghost heart and for M |
| §5.4 hearts "previously higher health value is drawn as the blinking ghost" | stated | confirmed, but the ghost exists only while the blink flag is on and is a blinking sprite of the current heart type under the real heart (5.2) |
| §5.6a preview | "head and body following the mouse with a factor 0.0625" | 0.0625 is a vertical offset in blocks; the mouse enters through atan(delta / 40) × 20 (4.2) |
| §5.4 air row y | H − 49 (minus mount rows) | H − 49 not riding and H − 49 − 10 × (rows − 1) riding; agrees |
| §5.4 heart ghost / blink trigger | silent on what starts the blink | the trigger needs `damageCooldownTime` > 0, which the Damage Event packet (20) and Set Health (`LocalPlayer.hurtTo`: 20 on a fall, 10 on a rise) set (5.1); a heal reported by Set Health does blink |

## 7. Open questions

1. Which caller passes `false` for the "render HUD" flag of `Gui.extractRenderState` (not read; only F1 and the level-loading screen are known to hide the HUD block).
2. The behaviour when the Update Mob Effect packet arrives for an effect the player already has (replacement, the hidden-effect downgrade at D = 0, the blend state and the blend flag) was not read. The plain per-tick countdown is read (2.5).
3. `CreativeModeInventoryScreen`: only the call order (panel first) and `showsActiveEffects` were read; its `leftPos`, `imageWidth` and `topPos` values, which fix the panel position there, were not.
4. Whether `ComponentRenderUtils.clipText` appends an ellipsis (the name text and the duration text are both drawn with shadow: read).
5. Whether the player name tag is drawn in the inventory preview (the name-tag fields of the render state were not examined), and the value of `GuiRenderer.CLEAR_COLOR` of the preview texture.
6. Whether `LocalPlayer`'s "flash on Set Health" flag starts false again after a respawn or dimension change (that depends on whether a new local player object is created, not traced), which decides whether the first health report after it can blink.
7. Which entity types return true from `showVehicleHealth`, the player's max air supply (`getMaxAirSupply`) and the threshold of `isFullyFrozen` (ticks frozen) were not read.
8. The vanilla bounding-box height of the standing, sneaking and swimming player used in 4.3 (stated 1.8 as in 12 §7.3, "vanilla value, not read").
9. The 65536 entries of the sine table behind `Mth.cos` (2.5) were not read; the index rule was. Taking them as the sine of index × 2π / 65536 is (inferred, the usual construction, not read here).
