# 57-1. Client closures, part 1: rendering and animation (first-person fire overlay, walk animation check, piglin crossbow arms, leather overlay layer, camera bob and damage tilt)

| Item | Value |
|---|---|
| Covers | Closures of five client-side gaps recorded on task lines of `specs/002-client-polish/tasks.md`: the first-person fire overlay (T11106, §1: where it is drawn, when, geometry, colour, sprite and its animation, order against the other screen overlays); a verification of the walk animation of 54 §1 (T7502, §2); the piglin crossbow arm poses and the state that drives them (T9508, §3); the second (overlay) layer of dyed leather armour (T9901, §4); camera view bobbing and the hurt and death tilt of the camera, with four corrections to 12 §6.1 and one closed question of 53 (§5) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the jar's data files (`unzip -p`), with no execution; clean-room reader round "57-1" (reader only; a reviewer follows) |
| Extends or corrects | 12 §6.1 (camera set-up: order and one wrong sentence corrected in §5), 12 §7.5 (crossbow rows: one operator corrected in §3), 34-2 §1.5 and §4.9, 43 §7.2, 53 §15 (Open questions 13 and 16 closed in §5.5), 54 §1 (one wording correction in §2), 14 §11 rules 3 and 5 (animated sprites: "ticks" and "uploaded each frame" refined in §1.4: the atlas clock is per rendered frame with a game tick due) |

All angles are radians unless a value is followed by "degrees". All numbers are Java `float` unless stated. Each section starts with a "Gap closed" line.
Artifact class names are cited in backticks only to say where a fact was read.

---

## 1. First-person fire overlay (T11106)

**Gap closed:** what is drawn on the screen of the local player when it is on fire: sprite, layers, transform, colour, condition, the frame of the animated sprite, the draw order against the water, in-wall, pumpkin, powder-snow and totem overlays, and the third-person case. Nothing in 12, 13, 14, 34, 49, 53 or 54 described it (grep of those documents for the overlay, `ScreenEffectRenderer`, `fire_1` found only the entity-flame remark of 34-8 Open question 14, which is a different feature, see §1.8).

### 1.1 Where the pass runs

`GameRenderer.renderLevel` ends with `render3dHud`. In that method, in this order: (1) the "hand" projection is set up: a perspective projection with near plane 0.05, far plane `depthFar` and the field of view `hudFov` (`Camera.BASE_HUD_FOV` = 70 degrees with the death and fluid adjustments of 53 §8.2), the window's aspect ratio; (2) the depth texture is cleared to 0 (the reversed depth buffer of 12 §4); (3) the first-person hands and items are submitted (12 §6); (4) the screen effects are submitted by `ScreenEffectRenderer.submit`; (5) all submitted geometry of this pass is drawn into the main colour target with the depth texture. The screen effects are therefore **in the 3D hand pass, drawn after the hand, before any GUI**: in-wall, water and fire are camera-space quads, not GUI sprites. The pose stack of the effects starts as the identity (nothing of the camera, the bobbing or the hurt tilt is applied to them), so every number below is in the camera space of the hand projection: +x right, +y up, the viewer looks along −z, units blocks.

### 1.2 Condition

Two stages, both must pass.

| Stage | Rule (all read) |
|---|---|
| Extraction (`LevelExtractor.extractPlayerState`) | Nothing is extracted when there is no local player or level. After the common part, extraction **stops before the fire and water fields when the camera entity is a living entity that is sleeping**, and also when the option camera type is not first person (`CameraType.isFirstPerson`: only the first-person type). Otherwise `isOnFire` = `LocalPlayer.isOnFire()` and the water overlay is built when the eyes are in a water fluid (`isEyeInFluid(water)`). |
| `LocalPlayer.isOnFire()` (`Entity.isOnFire`) | True when the entity type is **not** fire immune (`EntityType.fireImmune`; the player type is not) and either `remainingFireTicks` is above 0, or the level is the client level and the shared entity flag bit 0 (`FLAG_ONFIRE`, entity metadata index 0, bit 0x01, 00) is set. The server sets bit 0 each tick as `remainingFireTicks > 0` (`Entity.baseTick`) and replicates it through Set Entity Data; the server also decrements `remainingFireTicks` once per tick and, when it is a multiple of 20 and the entity is not in lava, deals 1 point of on-fire damage (the server rule is 18 §2.5; here only the replicated flag matters). |
| Draw (`ScreenEffectRenderer.submit`) | The fire quads are submitted when the camera entity is not sleeping, a local player and its avatar state exist, the camera type is first person, **the avatar is not a spectator** (`AvatarRenderState.isSpectator`), and `isOnFire` was extracted. Fire immunity needs no extra test (a fire-immune type never reports on fire). Creative mode needs no test of its own, but `Player.setRemainingFireTicks` caps the server value at 1 for a player whose abilities have `invulnerable` set (`GameType.updatePlayerAbilities`, read: set for CREATIVE and SPECTATOR, clear for the other modes), so a creative player shows the overlay only for the tick after each ignition and for as long as something keeps re-igniting it. Being in water needs no test either: the server clears fire for an entity that is extinguished (read in `Entity.applyEffectsFromBlocks`: `clearFire` when `isInRain`; 24-8 names the inside-block `EXTINGUISH` effect; that water and fluid contact reach it was not read here, and 18 Open question 7 records the same gap), and the replicated flag then goes; while the flag is still set the overlay draws, **together with** the water overlay (§1.6). |
| Hidden HUD | The last argument of `submit` is `isHudHidden`; it gates only the totem activation animation. The in-wall, water and fire overlays are drawn with the HUD hidden (F1) (read: the flag is tested only before `renderItemActivationAnimation`). |

### 1.3 Geometry, transform and colour

One flame sprite, **two quads**, each a unit square in the xy plane at z = −0.5 before its transform. Quad vertex order and texture coordinates (`buildFireQuad`, `buildSpriteQuad`, `buildQuad`): the corners are (x0, y0), (x1, y0), (x1, y1), (x0, y1) with x0 = y0 = −0.5, x1 = y1 = 0.5, and z = −0.5; the texture coordinates are (u1, v1), (u0, v1), (u0, v0), (u1, v0) of the sprite, where (u0, v0) is the upper left and (u1, v1) the lower right corner of the sprite's region in its atlas. So the image is **mirrored horizontally** (the right edge of the sprite is on the left of the quad) and upright vertically (the top of the sprite is on the top edge, y = +0.5).

Per-pass transforms (`submitFire`'s custom-geometry lambda; each starts from a copy of the identity pose matrix; a translation then a rotation about the y axis, so a vertex is rotated first and translated second):

| Quad | Translation (x, y, z) | Rotation about y | Resulting x range | Resulting z range | y range |
|---|---|---|---|---|---|
| first | (+0.24, −0.3, 0) | −0.17453292 (−10 degrees) | −0.1656 to +0.8192 | −0.5792 (at the left edge) to −0.4056 (at the right edge) | −0.8 to +0.2 |
| second | (−0.24, −0.3, 0) | +0.17453292 (+10 degrees) | −0.8192 to +0.1656 | −0.4056 (at the left edge) to −0.5792 (at the right edge) | −0.8 to +0.2 |

(The x and z ranges are computed here from the read constants: a vertex (x, y, −0.5) of the first quad becomes x' = 0.98481 x − 0.5 × sin(−10 degrees) = 0.98481 x + 0.0868 and z' = 0.17365 x − 0.4924, then +0.24 in x; the second quad mirrors it.) The two quads therefore face each other like a shallow V opening towards the viewer, overlap in the middle of the screen, and each reaches past one screen edge.

Colour: one packed ARGB value, the int −436207617 = `0xE5FFFFFF`, on all four vertices of both quads: **white, alpha 229/255 = 0.898**. There is no light, brightness or fog term (no lightmap in the render type). The shader (`core/position_tex_color`, a jar data file) multiplies the texel by the vertex colour, **discards the fragment when the product's alpha is exactly 0**, and multiplies the result by the pipeline's colour modulator (`ColorModulator`, not read; the GUI default is white, Open question 5).

Blend (render type `fire_screen_effect`, built on the shared GUI textured pipeline snippet): colour = source rgb × source alpha + destination rgb × (1 − source alpha); alpha = source alpha + destination alpha × (1 − source alpha) (`BlendFunction.TRANSLUCENT`). The vertex format is position, texture coordinate, colour; primitive: quads; sampler 0 = the atlas texture that holds the sprite. No depth, cull or fog setting is made in the snippet (Open question 1).

Screen coverage (inferred arithmetic, vertical field of view 70 degrees, 16:9): the upper edge of the quads is at y = +0.2, which is NDC y = +0.49 where it meets the screen at z = −0.58 and +0.70 at z = −0.41, so the flame's top edge slopes up from the middle towards the left and right screen edges, from about 75 percent to about 85 percent of the screen height. The lower part of each quad (down to y = −0.8) is below the screen: the visible part is about the upper 55 percent of the sprite (the screen's lower edge is at y ≈ −0.35 for z = −0.5). Each quad covers from just left (first quad) or right (second quad) of the screen centre to beyond the opposite screen edge.

### 1.4 The sprite and its frame

- Sprite: `ModelBakery.FIRE_1`, the sprite id `fire_1` of the **blocks atlas** (the `Sheets.BLOCKS_MAPPER` prefix is `block`): the file `assets/minecraft/textures/block/fire_1.png`. Size 16 × 512 pixels = 32 frames of 16 × 16.
- Its `fire_1.png.mcmeta` is exactly `{"animation": {}}`: no `frames`, no `frametime`, no `width` or `height`. By 14 §11 (and read in `AnimationMetadataSection`: `frametime` default 1, the frame count from the image) it is an animation of 32 frames in image order 0 to 31, each lasting 1 tick, looping: a period of 32 ticks (1.6 s). (For contrast `fire_0.png.mcmeta` lists the frames explicitly in the order 16 to 31 then 0 to 15; the overlay does not use `fire_0`.)
- Frame choice: there is none made by the overlay. The quad uses the sprite's whole region (u0, v0, u1, v1 are the constant region of the frame-sized sprite in the atlas, 14 §11 rule 5: "the atlas holds only the visible frame"); the visible frame is the one the atlas last uploaded. Refinement of 14 §11 rules 3 and 5 ("frametime counts ticks", "uploaded each frame"): the atlas is a ticking texture, but its clock is **per rendered frame that has game ticks due, not per game tick**, so a frame time of 1 is exactly one game tick only at the rates given below: in `Minecraft.runTick(boolean)`, whose whole advance-and-tick block runs only when its parameter is true (the main loop `run` passes true on every iteration until an `OutOfMemoryError` is caught; the flag that handler sets is never reset, so every later iteration passes false and skips the block, and a second `OutOfMemoryError` is rethrown), the delta tracker reports how many game ticks are due (`advanceGameTime`: it accumulates the elapsed real time over the tick length into a fractional residual and returns its whole part, the count n; it does not look at the pause flag); if n > 0 and `isLevelRunningNormally` holds, `TextureManager.tick` is called **once**, before the per-tick loop that then runs min(n, 10) client ticks. `isLevelRunningNormally` is true when there is no client level, and otherwise equals `TickRateManager.runsNormally()`, which returns the field `runGameElements`; `TickRateManager.tick()` (called once per client tick from `Minecraft.tick` when a level exists and the game is not paused) sets it to (not frozen) or (`frozenTicksToRun` > 0) and counts `frozenTicksToRun` down. So it is false for a frozen level that is not stepping (`/tick freeze`), and true again during the ticks of a `/tick step` (the effect on the frame timing of stepping was not otherwise read, Open question 11). Each animated sprite's ticker increments its sub-frame counter on that call and, when the counter reaches the current frame's time (here 1), advances the frame index modulo 32 and resets the counter; a changed frame is re-uploaded into the atlas region. So the flame advances one frame (of 32) for each rendered frame in which at least one game tick is due: 20 frames per second only when the frame rate is at least 20 and never more than one tick is due per frame; at a lower frame rate it advances once per rendered frame (slower than 20 per second), at a higher frame rate it still advances only at the game-tick rate (20 per second, spread over the frames in which a tick is due). It stands still while the level is frozen. The pause flag (`Minecraft.pause`, set on a paused single-player game) does not gate the texture tick: `advanceGameTime` still returns the due ticks and only `isLevelRunningNormally` is tested, so the atlas keeps animating on a pause screen (the pause field is used elsewhere: `runTick` reads and writes it for the sound manager's pause (`pauseAllExcept`) and passes it to `DeltaTracker.updatePauseState`, and `Minecraft.tick` uses it to gate `TickRateManager.tick` and the game-mode tick; nothing gates `TextureManager.tick` on it). With no level the atlas keeps ticking (and the fire overlay is not drawn anyway, there being no local player).
- All pack textures follow 14: a pack's own `fire_1.png` replaces the image; its `.mcmeta` is searched per the rule of 14 §2.3.

### 1.5 Draw order of the screen overlays

| Order | Overlay | Pass | Condition (in short) | Source |
|---|---|---|---|---|
| 1 | in-wall block texture | 3D hand pass | a view-blocking block at the eye (§1.6) | `ScreenEffectRenderer.submit` first branch |
| 2 | water (`textures/misc/underwater.png`) | 3D hand pass | first person, not spectator, eyes in water (§1.6) | second branch |
| 3 | **fire** | 3D hand pass | §1.2 | third branch |
| 4 | totem activation item | 3D hand pass | `itemActivation` active and HUD not hidden | after the three above |
| 5 | vignette | GUI pass (`Hud.extractCameraOverlays`) | option `vignette` on | first statement |
| 6 | spyglass scope, or the equipped item's camera overlay (the carved pumpkin's `textures/misc/pumpkinblur.png`) | GUI pass | first person only; the scope when scoping, else for each equipment slot in `EquipmentSlot.values()` order: the item in that slot with an `equippable` component whose **own slot equals the slot being iterated** (worn in its proper slot) and that has a `camera_overlay`, drawn at opacity 1; an item that is only held (a pumpkin in the hand) or sits in another slot draws nothing | same method |
| 7 | powder-snow outline (`textures/misc/powder_snow_outline.png`) | GUI pass | `getTicksFrozen() > 0`, opacity = `getPercentFrozen()` | same method |
| 8 | portal overlay, else nausea (confusion) overlay | GUI pass | portal intensity above 0; else nausea blend above 0 and the Distortion Effects option below 1 (13 §7) | same method |

So the fire is drawn **over** the water, in-wall and hand layers it shares a pass with (it is submitted later) and **under** the pumpkin, powder snow, portal and vignette overlays, which are GUI sprites drawn afterwards; items 5 to 8 are outside T11106 and are listed only for the order. The pumpkin path (`camera_overlay` component data on the carved pumpkin) was not traced to the item data (Open question 4).

### 1.6 The two overlays that share the pass (for tests of the order)

- **In-wall** (`blockOverlay`): extraction runs after the sleeping check, **before** the camera-type check, so it is also built in third person. `getViewBlockingState` returns null when the player has `noPhysics`; otherwise it probes 8 points: for i = 0 to 7, x = playerX + (bit0(i) − 0.5) × bbWidth × 0.8, y = eyeY + (bit1(i) − 0.5) × 0.1 × scale, z = playerZ + (bit2(i) − 0.5) × bbWidth × 0.8, and the first block whose render shape is not invisible and for which `isViewBlocking(level, pos, nearPlaneBoundsMovedToTheEye)` holds is chosen (its rules are 51 and the block documents; not traced here, Open question 6). The quad is the block's particle sprite (the region of that sprite in its atlas), a full-screen quad x, y from −1 to 1 at z = −0.5, colour `0xFF191919` (the int −15132391: dark grey, opaque), render type `block_screen_effect` (same blend). It is submitted when the avatar exists and the player is not sleeping, in first person or not.
- **Water** (`waterOverlay`): first person only, not spectator. Colour: alpha 0.1 and r = g = b = b0, where b0 = `Lightmap.getBrightness(dimensionType, level.getMaxLocalRawBrightness(eye block))` (the conversion of the four floats to an int is `ARGB.colorFromFloat`, not read); a full-screen quad x, y from −1 to 1 at z = −0.5 with the 16 × 16 texture `textures/misc/underwater.png` repeated 4 times in each direction (texture coordinates from (uO + 4, vO + 4) to (uO, vO)) and scrolled by uO = −yaw/64, vO = pitch/64 (the entity's own `getYRot`, `getXRot`).

### 1.7 Worked examples

1. Standing in a fire block in survival, first person, level running: the server sets flag 0, the client's `isOnFire` is true, the avatar is not a spectator, so two quads of `fire_1` with colour `0xE5FFFFFF` are submitted after the hand; the visible frame advances one of 32 per tick. When the player steps into water the server clears fire and the flag falls with the next metadata update; until then the water quad (alpha 0.1) is drawn under the fire quads.
2. The same player switching to third person (F5): nothing extracted (`isOnFire` false), nothing drawn; the player model's own flame is a world-space entity effect (§1.8).
3. The local player in spectator mode: the on-fire flag extracted is the **local player's** (`LocalPlayer.isOnFire`), and the spectator test is on the local player's avatar render state (`AvatarRenderState.isSpectator`), not on the camera entity; a spectating local player therefore draws neither the water nor the fire overlay, even while it is looking through a burning entity's eyes (the burning entity's fire is not the local player's fire and is never extracted for this overlay).
4. Game frozen by `/tick freeze` (a level exists, its tick-rate manager is frozen and not stepping): the overlay stays, showing whichever frame was uploaded last (the atlas stops ticking). At 10 frames per second with 20 ticks per second, two ticks are due per frame but the atlas still advances one frame per rendered frame, i.e. 10 frames of the 32 per second.

### 1.8 What is not covered

The flame that a burning entity (the local player seen in third person, other players, mobs, boats) carries in the world is a different mechanism (`EntityRenderState.displayFireAnimation` = `Entity.displayFireAnimation()` = on fire and not a spectator; geometry in `FlameFeatureRenderer`, which uses the sprites `fire_0` and `fire_1`); it was not read (Open question 3, the same gap as 34-8 Open question 14).

---

## 2. Walk animation: verification of 54 §1 (T7502)

**Gap closed:** whether 54 §1 is correct. **Result: every value of 54 §1.1 to §1.5 is confirmed against the jar**, with one wording correction (§2.2) and two additions (§2.3). Nothing of 54 §1 is rewritten.

### 2.1 Confirmed

| Statement of 54 §1 | Read in | Result |
|---|---|---|
| State: four floats, `positionScale` initial 1, the others 0 | `WalkAnimationState` constructor | confirmed |
| `update(target, smoothing, scale)`: speedOld = speed; speed += (target − speed) × smoothing; position += speed (the new speed); positionScale = scale | `update` | confirmed (position adds the **updated** speed) |
| `stop()`: speedOld = speed = position = 0, scale unchanged | `stop` | confirmed |
| `setSpeed(v)` sets only `speed` | `setSpeed` | confirmed |
| `speed(pt)` = min(lerp(pt, speedOld, speed), 1); `position(pt)` = (position − speed × (1 − pt)) × positionScale; `isMoving` = speed > 1.0e-5 | the methods | confirmed (the 1 clamp is only in the interpolated speed; `position(pt)` uses the unclamped speed, so a speed of 1.5 after a hit also advances the position at 1.5 per tick) |
| default driver: target = min(d × 4, 1), smoothing 0.4, scale 3 baby else 1 | `LivingEntity.updateWalkAnimation` | confirmed |
| camel: target min(d × 6, 1) when pose STANDING and dash animation not started, else 0; smoothing 0.2; scale 3 baby else 1 | `Camel.updateWalkAnimation` | confirmed |
| frog: target 0 while the jump animation state is started, else min(d × 25, 1); smoothing 0.4; scale baby 3 else 1 | `Frog.updateWalkAnimation` | confirmed |
| creaking: target min(d × 25, 3), smoothing 0.4, scale 1 | `Creaking.updateWalkAnimation` | confirmed |
| these four are the only overrides | scan of every class of the jar's `net/minecraft/world/entity/**` for the method name | confirmed: `LivingEntity`, `Camel`, `Frog`, `Creaking` only (the axolotl and strider read the state but do not write it) |
| d = length of (x − xo, dy, z − zo) with dy = (y − yo) only when the flag is true | `calculateEntityAnimation` | confirmed (`Mth.length` of the three doubles, then cast to float) |
| passenger or not alive: `stop()`, else `updateWalkAnimation(d)` | same | confirmed |
| client only, in the client branch of `LivingEntity.aiStep` after movement | `aiStep` (`level.isClientSide` test, then `calculateEntityAnimation(omnidirectionalAirMover())`, after `travel` and `applyEffectsFromBlocks`) | confirmed |
| flag = `omnidirectionalAirMover()`: false by default, true for bee and parrot, sulfur cube = has a body item | `Entity` (false), `Bee` (true), `Parrot` (true), `SulfurCube` (`hasBodyItem`) | confirmed; no other class overrides it |
| Damage Event sets speed to 1.5 | `LivingEntity.handleDamageEvent` | confirmed (the only `setSpeed` call site); the same method also sets `damageCooldownTime` = 20 and `hurtDuration` = `hurtTime` = 10 (used in §5) |
| renderer: `walkAnimationPos` = `position(pt)`, `walkAnimationSpeed` = `speed(pt)` when not a passenger and alive, else both 0; `wornHeadAnimationPos` = the vehicle's `position(pt)` when the vehicle is living, else own `walkAnimationPos` | `LivingEntityRenderer.extractRenderState` | confirmed |
| worked examples 1 to 3 | recomputed | confirmed: speeds 0.32, 0.512, 0.6272; position 1.4592 (adult) and 4.3776 (baby) after three ticks; decay factor 0.6 per tick (0.37632 next) |

The humanoid consumers of the two values (12 §7.5: right arm xRot = cos(pos × 0.6662 + π) × 2.0 × speed × 0.5 / speedValue, left arm the same without + π, right leg cos(pos × 0.6662) × 1.4 × speed / speedValue, left leg with + π, legs yRot and zRot ± 0.005, riding and crouching offsets) were re-read in `HumanoidModel.setupAnim` and are correct.

### 2.2 Wording correction

54 §1.2 says that `RemotePlayer.tick` "additionally" calls `calculateEntityAnimation(false)`. Read: `RemotePlayer.aiStep` does **not** call the living-entity `aiStep` (it only lerps the head rotation, applies its delta-movement tweak, calls `updateBob` and `pushEntities`), so for a remote player the call in `RemotePlayer.tick` (after `AbstractClientPlayer.tick`, argument false) is the **only** one, once per tick. For the local player the one call is in `LivingEntity.aiStep`. Neither is called twice per tick.

### 2.3 Additions

- The two parameterless accessors `speed()` (the raw `speed`) and `position()` (`position × positionScale`) exist; they are read by the strider model state and by the axolotl (`isMoving`), and are not used by the renderer path above.
- The interpolation partial tick `pt` is the entity-extraction partial tick of the frame (the same for all fields of one render state).

---

## 3. Piglin crossbow arm poses (T9508)

**Gap closed:** the arm rotations of the piglin model while it holds a crossbow, charges it, or has it ready, with every constant, the state that drives them and the way the charge progress and the head enter. 34-2 §4.9 and 12 §7.5 already give the pose choice and the two formulas; they are **confirmed** here with one correction (the hold pose assigns, it does not add) and the pieces they lacked: the order against the other arm animations, which fields stay untouched, the drivers, the timeline and worked values.

Already documented: the six poses and their selection order (34-2 §6, §4.9 table), the pose-flag set (34-2 §4.2: CROSSBOW_CHARGE and CROSSBOW_HOLD are also two-handed arm poses of the humanoid model; the piglin does not use that path, it calls the routines from its own `armPose` switch), the `AnimationUtils` formulas (12 §7.5), metadata 16 immune, 17 baby, 18 charging crossbow, 19 dancing for the piglin (21, the all-entities metadata table).

### 3.1 Order of the animation steps (new)

`PiglinModel.setupAnim(state)` (the model of the adult piglin, the brute, the baby piglin: `AdultPiglinModel` and `BabyPiglinModel` both extend `PiglinModel`) runs, in this order:

1. `AbstractPiglinModel.setupAnim`, which runs `HumanoidModel.setupAnim`: head from the look angles; the walk swing of arms and legs (§2); the item arm poses (`poseRightArm`, `poseLeftArm`); `setupAttackAnimation` (the swing, 34-2 §4.4); crouch offsets; the idle arm bob (12 §7.5); then the ear animation (34-2 §4.9).
2. The `armPose` switch of 34-2 §4.9. For CROSSBOW_HOLD and CROSSBOW_CHARGE the `AnimationUtils` routine is called **after** all of step 1 and therefore overwrites what the walk swing, the item pose and the attack swing wrote into the arms' `xRot` and `yRot`.

Consequences: (1) while a crossbow pose is active the arms do **not** swing with the walk (the xRot of both arms is assigned); (2) the arms' `zRot` is not touched by either routine, so it keeps its value from step 1: the idle bob, zRot = sign × (cos(age × 0.09) × 0.05 + 0.05) with sign +1 for the right arm and −1 for the left (12 §7.5), plus anything the swing animation set (a piglin with a crossbow does not normally swing); the arm bob's xRot term (sign × sin(age × 0.067) × 0.05) is overwritten; (3) pivots (`x`, `y`, `z` of the arms) are not touched.

### 3.2 CROSSBOW_HOLD (`AnimationUtils.animateCrossbowHold(right arm, left arm, head, mainArmIsRight)`)

Let H = the holding arm: the right arm when `mainArm == RIGHT`, else the left arm; O = the other arm. The routine **assigns** (correction of 12 §7.5, which writes `yRot +=`; the bytecode builds the value from the head angle and a constant and stores it, with no read of the arm's previous `yRot`):

| Arm | yRot | xRot |
|---|---|---|
| H, right-handed (main arm right) | −0.3 + head.yRot | −1.5707964 + head.xRot + 0.1 |
| H, left-handed | +0.3 + head.yRot | −1.5707964 + head.xRot + 0.1 |
| O, when H is the right arm | +0.6 + head.yRot | −1.5 + head.xRot |
| O, when H is the left arm | −0.6 + head.yRot | −1.5 + head.xRot |

head.yRot and head.xRot are the head part's current values: the look angles of the render state times 0.017453292, as set in step 1 (so the arms follow where the piglin looks; the head's own pivot offsets do not matter). The model does not test which **hand** (main or off) physically holds the crossbow: only the mob's main arm (`state.mainArm`, from the left-handed mob flag, 18) chooses H.

### 3.3 CROSSBOW_CHARGE (`AnimationUtils.animateCrossbowCharge(right, left, maxCharge, ticksUsing, mainArmIsRight)`)

H and O as above, `maxCharge` = the state's `maxCrossbowChageDuration` (§3.4), `ticksUsing` = the state's `ticksUsingItem` (a float, §3.4). The routine assigns:

1. H.yRot = −0.8 (H right) or +0.8 (H left); H.xRot = −0.97079635.
2. O.xRot = H.xRot (= −0.97079635 for the moment).
3. d = clamp(ticksUsing, 0, maxCharge) / maxCharge.
4. O.yRot = lerp(d, 0.4, 0.85) × (+1 when H is the right arm, −1 when H is the left arm), that is (0.4 + 0.45 d) with the sign.
5. O.xRot = lerp(d, O.xRot, −1.5707964) = −0.97079635 + d × (−0.6f), the factor being the float difference −1.5707964f − (−0.97079635f) = −1.5707963705 + 0.9707963467 = −0.6000000238, which is exactly the float −0.6f (−0.60000002 at 8 decimals); the end point at d = 1 is −1.5707964, and the values quoted below are rounded to 8 decimals.

The head does **not** enter the charge pose (no head term); the head's own rotation is the look angle only. During the charge the holding arm is fixed; the other arm sweeps from the rest values at d = 0 to its final values at d = 1 (the hand moving along the string).

`maxCharge` of 0 would divide 0 by 0; the vanilla value is never 0 for a crossbow (Quick Charge 5 or more would clamp the duration to 0, 44-5 §2.3, which a piglin does not carry).

### 3.4 What drives the pose and the two numbers

| Input | Source |
|---|---|
| `armPose` | `Piglin.getArmPose` order (34-2 §6): dancing flag, loved item in the off hand, aggressive with a melee weapon, **charging flag → CROSSBOW_CHARGE**, **holding a crossbow whose `charged_projectiles` is non-empty (`CrossbowItem.isCharged(getWeaponItem)`) → CROSSBOW_HOLD**, else DEFAULT; verified against the jar. The charging flag is `DATA_IS_CHARGING_CROSSBOW` (metadata index 18, boolean, set by `setChargingCrossbow`) |
| `maxCrossbowChageDuration` (float) | `CrossbowItem.getChargeDuration(entity.getUseItem(), entity)` cast to float: 25, 20, 15, 10 for Quick Charge 0 to 3 (44-5 §2.3; also 17 §3.9 and 25-7); read at extraction, each frame |
| `ticksUsingItem` (float) | `LivingEntity.getTicksUsingItem(partialTick)` = 0 when not using an item, else (use duration of the used stack − remaining use ticks) + partialTick; the crossbow's use duration is 72000 (44-5 §2.3), so this is the number of ticks since use started plus the partial tick |
| `mainArm` | the mob's main arm (left-handed flag) |

Note `ticksUsingItem` is 0 whenever the piglin's "using item" state is off. On the client the using-item state comes from the living-entity flags metadata (the same replication as any entity; 18 §1); it is **only** true during the charge, because the brain behaviour (§3.5) starts using the item at the beginning of the charge and releases it at its end.

### 3.5 The state machine that drives it (closes the `CrossbowAttack` half of 44-6 Open question 5)

Brain behaviour `CrossbowAttack` (memory `attack_target` required, `look_target` registered; maximum run time 1200 ticks; runs `lookAtTarget` every tick, setting the look-target memory to the attack target with eye tracking, then the attack step). It starts only when the mob is holding a crossbow, can see the target (`BehaviorUtils.canSee`) and is within attack range (`isWithinAttackRange(mob, target, 0)`); it continues while the attack target memory is present and those conditions hold. Its state, initially UNCHARGED, advances once per tick:

| State | Step in that tick | Next state |
|---|---|---|
| UNCHARGED | `startUsingItem(hand holding the crossbow)`; set the charging flag true | CHARGING |
| CHARGING | if the mob is not using an item: state back to UNCHARGED (and the rest of the step still runs); `ticksUsing` = `getTicksUsingItem()` (int); if `ticksUsing >= getChargeDuration(useItem, mob)`: `releaseUsingItem`, set the charging flag false, `attackDelay` = 20 + `nextInt(20)` (20 to 39) | CHARGED when the threshold is reached; UNCHARGED when the mob was not using an item (`getTicksUsingItem` is then 0, so the threshold test cannot pass); otherwise CHARGING |
| CHARGED | `attackDelay` −= 1; when it reaches 0 | READY_TO_ATTACK |
| READY_TO_ATTACK | `performRangedAttack(target, 1.0)` (shoots) | UNCHARGED |

On `stop` (target lost, out of range, expired): stop using the item if the mob is using one (`stopUsingItem` replaces the mob's `useItem` field with the empty stack); then, when holding a crossbow, set the charging flag false and set `charged_projectiles` to empty **on `getUseItem()`**, which returns that `useItem` field. Because the field was just emptied (or was already empty, since the mob had released the item or never used it), the write lands on the empty stack and **the held crossbow is not touched** (read: `stopUsingItem`, `getUseItem`, `CrossbowAttack.stop`; what the write does to the shared empty-stack instance was not read). So a crossbow that was already loaded stays loaded and the piglin stays in CROSSBOW_HOLD when the behaviour stops in CHARGED or READY_TO_ATTACK (the pose is DEFAULT only when it stops during CHARGING, before the load: the flag is cleared and nothing is loaded yet). With this the render fields run as follows (worked timeline at 20 ticks per second, Quick Charge 0): ticks 0 to 24 of the charge the pose is CROSSBOW_CHARGE with ticksUsing 0 to 24 (d = 0 to 0.96); from tick 25 the pose is CROSSBOW_HOLD for the `attackDelay` of 20 to 39 ticks plus one tick (READY), then the shot, after which the pose is DEFAULT until the next charge starts (`CrossbowItem.performShooting`, called from `performCrossbowAttack`, sets `charged_projectiles` to empty, so the hold condition fails).

Why the stack is charged when the behaviour releases it (read in the jar): `LivingEntity.tick` runs `updatingUsingItem` (which calls the item's `onUseTick`, then decrements the remaining use ticks) **before** `aiStep`, and the brain, hence `CrossbowAttack`, runs inside `aiStep` (`serverAiStep`, `Brain.tick`). So when the behaviour reads `getTicksUsingItem()` the value already includes this tick's decrement: at the tick it first reads 25, that tick's `onUseTick` saw progress 24/25 and loaded nothing. The load happens **inside `releaseUsingItem`**: `LivingEntity.releaseUsingItem` calls `CrossbowItem.releaseUsing` (which loads nothing, 25-7) and then, because `CrossbowItem.useOnRelease` is true for a crossbow, runs `updatingUsingItem` once more, whose `onUseTick` sees progress 25/25 = 1 and calls `tryLoadProjectiles` (storing `charged_projectiles`) before `stopUsingItem`. `detectEquipmentUpdates` runs earlier in the tick than `aiStep`, so the new stack state is most likely first broadcast one tick later than the charging-flag change; a client may therefore show one tick of DEFAULT between CHARGE and HOLD (inferred from the order of calls, Open question 7).

### 3.6 Worked examples

1. Hold, right-handed, head yaw 20 degrees (0.34906585), pitch −10 degrees (−0.17453293): right arm yRot = −0.3 + 0.34906585 = 0.04906585, xRot = −1.5707964 − 0.17453293 + 0.1 = −1.6453293; left arm yRot = 0.6 + 0.34906585 = 0.94906585, xRot = −1.5 − 0.17453293 = −1.6745329. With the head straight (0, 0): right arm (−0.3, −1.4707964), left arm (0.6, −1.5).
2. Charge, right-handed, maxCharge 25: ticksUsing 0 → right arm (yRot −0.8, xRot −0.97079635), left arm (0.4, −0.97079635); 12.5 (d = 0.5) → left arm (0.625, −1.2707964); 25 or more (d = 1) → left arm (0.85, −1.5707964); ticksUsing 6.25 (d = 0.25) → left arm (0.5125, −1.1207964).
3. Charge, left-handed, d = 1: left arm (H) yRot +0.8, xRot −0.97079635; right arm (O) yRot −0.85, xRot −1.5707964.

---

## 4. Second (overlay) layer of dyed leather armour (T9901)

**Gap closed:** the texture files and layers of leather armour on the body, which layer is tinted and how, and the equipment asset JSON. The rule per layer (dyeable layer takes the dye colour else its default, a layer without `dyeable` is white, a zero colour skips the layer, foil on the first drawn layer only) is **already documented** in 43 §7.2 and 34-2 §1.5; this section adds the asset's contents, the file inventory with sizes, and the per-slot mapping, all read from the jar.

### 4.1 The equipment asset (`assets/minecraft/equipment/leather.json`, one of 45 files)

Schema of an equipment asset (read from the codecs `EquipmentClientInfo`, `EquipmentClientInfo$Layer`, `EquipmentClientInfo$Dyeable`):

| Member | Kind | Required | Meaning |
|---|---|---|---|
| `layers` | object: layer type name → non-empty list of layer objects | yes | the layer types are `humanoid`, `humanoid_leggings`, `humanoid_baby`, `wings`, `wolf_body`, `horse_body`, `llama_body`, `pig_saddle`, `strider_saddle`, `camel_saddle`, `camel_husk_saddle`, `horse_saddle`, `donkey_saddle`, `mule_saddle`, `zombie_horse_saddle`, `skeleton_horse_saddle`, `happy_ghast_body`, `nautilus_saddle`, `nautilus_body` (the 19 serialized names of `LayerType`, in the order of the enum, read from the class) |
| `trim_overrides` | object | no | trim texture overrides, 34-2 §1.5 step 6 |
| layer: `texture` | identifier | yes | texture id; the file is `<namespace>:textures/entity/equipment/<layer type>/<path>.png` (the recipe `textures/entity/equipment/%s/%s.png` read in `Layer.getTextureLocation`) |
| layer: `dyeable` | object, member `color_when_undyed` (integer, RGB, optional) | no | present = the layer takes the dye colour |
| layer: `use_player_texture` | boolean | no, default false | the caller's player texture replaces the layer texture when it supplies one (capes and wings) |

`leather.json` has four layer types, each with the **same two layers in the same order**: layer 0 `{"dyeable": {"color_when_undyed": -6265536}, "texture": "minecraft:leather"}`, layer 1 `{"texture": "minecraft:leather_overlay"}`. -6265536 = `0xFFA06540` (red 160, green 101, blue 64, the brown of undyed leather).

### 4.2 Files and sizes (counted from the archive)

| Layer type | Used for | Layer 0 file | Layer 1 file | Size (both) |
|---|---|---|---|---|
| `humanoid` | helmet, chestplate, boots of an adult humanoid (read: `HumanoidArmorLayer` is referenced by the renderers of the humanoid mob base, zombies and zombie villagers, skeletons, piglins and zombified piglins, the giant, the armor stand and the player avatar; layer-type choice per 34-2 §1.5 step 2) | `textures/entity/equipment/humanoid/leather.png` | `.../humanoid/leather_overlay.png` | 64 × 32, 4-bit palette PNG |
| `humanoid_leggings` | leggings of an adult (same consumers, 34-2 §1.5 step 2) | `.../humanoid_leggings/leather.png` | `.../humanoid_leggings/leather_overlay.png` | 64 × 32, 4-bit palette PNG |
| `humanoid_baby` | every slot of a baby humanoid (34-2 §1.5 step 2: baby and not an armor stand) | `.../humanoid_baby/leather.png` | `.../humanoid_baby/leather_overlay.png` | 64 × 64, 8-bit palette PNG |
| `horse_body` | the horse body armor layer (read: `HorseRenderer` and `UndeadHorseRenderer` use `LayerType.HORSE_BODY`; `Item.Properties.horseArmor(material)` sets an equippable body-slot component with the material's asset id; that `leather_horse_armor` uses the leather material, hence this asset, is inferred from the item name and 25-4's `leather` row) | `.../horse_body/leather.png` | `.../horse_body/leather_overlay.png` | 64 × 64 (base: 8-bit grey; overlay: 8-bit palette) |

Eight files in all. There are **no per-slot file names**: the slot only selects the model piece and the layer type (`humanoid_leggings` for legs, `humanoid` for chest, feet and head, 34-2 §1.5 step 2); each file holds the texture for all pieces of its layer type at the armor-mesh UVs of 34-1.

### 4.3 What is drawn and how it is tinted

For one worn piece the layer renderer draws **two** passes, in list order, with the same model, pose and light: the model pass for layer 0 with colour C0, then for layer 1 with colour −1 (`0xFFFFFFFF`, white: the layer has no `dyeable` entry). C0 is the result of `getColorForLayer(layer 0, dye)` with dye = `DyedItemColor.getOrDefault(stack, 0)`: the dye colour when it is non-zero, else the layer's own `color_when_undyed` (here −6265536, from `leather.json`; it is data, not a constant of the renderer). `getOrDefault` returns the `dyed_color` component's rgb forced opaque (`ARGB.opaque`) **whenever the component exists**, so it is never 0 for a dyed stack (black dye is `0xFF000000`, not 0), and returns the default 0 only when the component is absent. The per-layer fallback (`getColorForLayer`) is then: a dyeable layer uses the dye colour if non-zero, else its `color_when_undyed` (forced opaque) or 0 if that is absent; a layer without `dyeable` is −1. The skip-layer case (colour 0, the layer is not drawn) therefore arises **only** for a dyeable layer on an undyed stack whose `dyeable` has no `color_when_undyed`; it never occurs for the shipped leather asset (both of its layers always have a non-zero colour). The colour is the vertex tint of the model submission (a multiplication of texel and colour, render type `armorCutoutNoCull`, overlay "none"), so:

- an undyed piece: layer 0 is drawn in the brown `FFA06540`, layer 1 untouched (white) on top;
- a dyed piece: layer 0 in the dye colour (the three channels multiply the grey-brown base texture; the alpha is forced to FF), layer 1 still white: **the overlay layer is never tinted**; it carries the details that must stay undyed (stitching, buckles, rivets);
- order values: the two submissions get consecutive order numbers starting at 1 for armor layers (34-2 §1.5), the trim and trim glint, if any, follow with the next numbers;
- foil: when the stack has foil and no trim, the glint render type replaces the plain one for the **first drawn** layer only, i.e. layer 0 (layer 1 is never glinted); with a trim the glint is applied after the trim instead;
- trims (not for `humanoid_baby`) are drawn after both layers (34-2 §1.5 step 6).

The overlay layer exists separately for every layer type, so leggings and boots (and the baby set) each have their own overlay: the leggings overlay is in the `humanoid_leggings` file, the boots overlay in the `humanoid` file, as for the base layer.

The inventory icon of the item has two layers as well (a tinted base and an untinted overlay): see 43 §7.1 (`leather_helmet`, `leather_chestplate`, `leather_leggings`, `leather_boots`, `leather_horse_armor`, dye default `FFA06540`).

Worked example: a chestplate dyed `FF3F76E4` (blue): pass 1 uses `humanoid/leather.png` with tint `0xFF3F76E4`; pass 2 uses `humanoid/leather_overlay.png` with tint `0xFFFFFFFF`. An undyed leather helmet on a baby zombie: pass 1 `humanoid_baby/leather.png` tinted `0xFFA06540`; pass 2 `humanoid_baby/leather_overlay.png` white.

---

## 5. Camera view bobbing and damage tilt

**Gap closed:** the exact order and conditions of the camera effects of `GameRenderer.bobHurt` and `bobView`, the hurt and death tilt in full, the origin of every input (`hurtTime`, `hurtDuration`, `hurtDir`, `deathTime`), and three questions left open in 12 and 53. The bobbing formulas and the amplitude chain of 12 §6.1 step 1 and 53 §15.2 were **re-read and are correct**; this section is a verification note plus the corrections of §5.1.

### 5.1 Corrections to 12 §6.1

1. **Order.** Both the world view (`renderLevel`: the projection matrix is multiplied by the pose stack after these two calls) and the hand pass (`renderItemInHand`) call **`bobHurt` first, then `bobView`** (the latter only when the option View Bobbing is on, `OptionsRenderState.bobView`). 12 §6.1 lists the bobbing as step 1 and the hurt tilt as step 2; by that document's own rule that the first listed is outermost, the order must be: **hurt tilt (outermost), view bobbing, hand sway**. For the small angles involved the difference is slight, but the order is as stated here.
2. **Dying does not stop the hurt tilt.** 12 §6.1 says that while dying the death roll is applied "and stop". Read: after the death roll the method continues; the hurt tilt runs as well whenever the hurt value is not negative (§5.2). A dying camera entity that was hit in the last 10 ticks therefore has both.
3. **Hurt value and the direction.** The hurt value is not an integer ratio: the render state stores `hurtTime` (int) **minus the partial tick** (`Camera`, `cameraEntityPartialTicks`), and `deathTime` **plus** the partial tick. `hurtDir` is not always 0: see §5.3.
4. **Range of b.** 12 §6.1 calls b "0..1"; 53 §15.2 gives 0 to 0.1 and is right (read again: `AbstractClientPlayer.updateBob` target = min(0.1, horizontal speed), `ClientAvatarState.updateBob`: bob += (target − bob) × 0.4).

### 5.2 Hurt tilt and death tilt (`GameRenderer.bobHurt`)

Applies when the camera entity is a living entity (`CameraEntityRenderState.isLiving`); otherwise nothing. Inputs (all from `Camera.extractRenderState`, read): `hurtTime` = entity `hurtTime` (int) − partial; `hurtDuration` = entity `hurtDuration` (int); `deathTime` = entity `deathTime` + partial; `isDeadOrDying`; `hurtDir` (§5.3). Steps in order:

1. If the entity is dead or dying: rotate about the z axis by (40 − 8000 / (min(deathTime, 20) + 200)) degrees (positive angle). It runs from 0 degrees at deathTime 0 to 3.636 degrees at 20 or more; the full-table is in the worked examples.
2. If `hurtTime` < 0: end. (The value is negative in the frame after the hurt time reached 0 with a partial tick above 0.)
3. t = hurtTime / hurtDuration (a float division by the int); k = sin(t⁴ × π).
4. rotate about y by −hurtDir degrees; rotate about z by (−k × 14 × `damageTiltStrength`) degrees (the option, 0.0 to 1.0, default 1.0, 13 §7: computed in double and then narrowed to float); rotate about y by +hurtDir degrees.

The constants 40, 8000, 200, 20, 14 and the exponent 4 were all read. With `damageTiltStrength` 0 the tilt is exactly 0 (the death roll is not scaled by the option and stays).

Sign (inferred): the camera pose is multiplied into the projection (P × M × view), so M acts on the view-space world; z points to the viewer; a negative z rotation of the world is clockwise on the screen as seen by the viewer. The hurt roll is therefore a clockwise turn of the picture of up to 14 degrees; the death roll is a counter-clockwise turn of up to 3.64 degrees.

### 5.3 Where the inputs come from

| Input | Set by | Value |
|---|---|---|
| `hurtDuration`, `hurtTime` | `LivingEntity.handleDamageEvent` (Damage Event packet, 05a 0x19) and `LivingEntity.animateHurt` (Hurt Animation packet, 05a 0x2B) | both set `hurtDuration` = 10 and `hurtTime` = `hurtDuration` = 10. Entity Event status 2 is **no longer the hurt event** in 26.3: in `LivingEntity.handleEntityEvent` status 2 calls `onKineticHit` (read; 18 already says hurt feedback is the two packets) |
| `hurtTime` decrement | `LivingEntity.baseTick`, on **both** sides (it sits after the server-only block): `hurtTime` −= 1 each tick while above 0 | so the effect lasts 10 ticks, 0.5 s |
| `deathTime` | `LivingEntity.tickDeath`, called from `baseTick` when the entity is dead or dying and `Level.shouldTickDeath`: `deathTime` += 1 per tick | the server removes the entity at 20; the camera clamps to 20 |
| `hurtDir` for a **player** camera | `Player.animateHurt(yaw)` stores the packet's yaw (the Hurt Animation packet's float, which the server computes in `ServerPlayer.indicateDamage` as atan2(dz, dx) × 57.2957763671875 − the player's yaw, from the hit direction, 17 §4.4 step 9, and sends only to that player) | the angle in degrees (for a projectile hit the (dx, dz) given to `indicateDamage` is the negated pair of `Projectile.calculateHorizontalHurtKnockbackDirection`, read in `dealDefaultKnockback`, not in `hurtServer`); **set only on this path**: `Player.animateHurt` is the only writer of the client player's `hurtDir` (read: one `putfield` in `Player`). The Damage Event path (`handleDamageEvent`) sets `hurtTime` and `hurtDuration` but **not** `hurtDir`, so a tilt started by a Damage Event alone uses the stale last `hurtDir` (initially 0) |
| `hurtDir` for any other living entity (a spectated mob) | `LivingEntity.getHurtDir()` returns the constant 0 and no living class but `Player` overrides it | 0 |

So for a player camera the Y rotations of step 4 are real: the composite is a z roll about an axis turned by `hurtDir` around the vertical, M = Ry(−h) · Rz(θ) · Ry(+h) with h = `hurtDir`, θ = −14 k s. For h = 0 or 180 degrees the tilt is a pure roll; for h = ±90 degrees (a hit from straight ahead or behind in the server's convention) the same angle appears as a pitch about the view x axis (inferred from the composition; the sign of the pitch was not worked out). For a spectated mob (h = 0) it is always the plain roll.

### 5.4 View bobbing (`bobView`) re-checked

Applies only when the camera entity is an `AbstractClientPlayer` (`isPlayer`) and the option is on. With w = `getBackwardsInterpolatedWalkDistance(pt)` = −(`walkDist` + (`walkDist` − `walkDistO`) × pt) and b = `getInterpolatedBob(pt)` = lerp(pt, `bobO`, `bob`): translate (sin(w π) × b × 0.5, −|cos(w π) × b|, 0), then rotate about z by sin(w π) × b × 3 degrees, then about x by |cos(w π − 0.2) × b| × 5 degrees. Confirmed against the bytecode (including 0.2, 0.5, 3, 5). 53 §15.2's worked example (b = 0.1, w = −10.1: translation (−0.0155, −0.0951, 0), z rotation −0.093 degrees, x rotation 0.435 degrees) was recomputed and is right.

### 5.5 Questions closed

- **53 Open question 16 (view bob in third person).** In `renderLevel` the sequence is: new pose stack; `bobHurt`; `bobView` if the option is on; multiply the projection. There is no camera-type test between them (read, not inferred), and `bobView` itself tests only that the camera entity is a client player. So the world shakes in third person exactly as in first person.
- **53 Open question 13 (walk distance of a spectated remote player).** The only caller of `AbstractClientPlayer.addWalkedDistance` (which feeds `ClientAvatarState.walkDist`) in the whole client is `LocalPlayer.move` (0.6 × the horizontal distance moved, as 53 §15.2 says). A `RemotePlayer` therefore keeps `walkDist` = `walkDistO` = 0 forever: spectating a remote player gives w = 0, so the bob is a **constant** offset, not a sway: translate (0, −b, 0), rotate about x by |cos(−0.2) × b| × 5 = 4.9 × b degrees (0.98007 × 5 × b), where b is that player's own bob value (`RemotePlayer.aiStep` calls `updateBob`: target min(0.1, horizontal length of its delta movement) while on the ground and not swimming or dying, from the velocity the movement packets give it).
- The local player's bob and the rest of 53 §15 stand as written.

### 5.6 Worked examples

1. Hurt tilt (strength 1, `hurtDuration` 10, `hurtDir` 0). Roll angle = −14 × sin(t⁴ π) degrees with t = (hurtTime − partial) / 10:

| hurtTime − partial | t | angle (degrees) |
|---|---|---|
| 10 | 1.0 | 0 (the frame of the hit) |
| 9.5 | 0.95 | −7.70 |
| 9 | 0.9 | −12.35 |
| 8.409 (peak) | 0.8409 | −14.00 |
| 8 | 0.8 | −13.44 |
| 7 | 0.7 | −9.59 |
| 6 | 0.6 | −5.54 |
| 5 | 0.5 | −2.73 |
| 3 | 0.3 | −0.36 |
| 1 | 0.1 | −0.004 |
| 0 or below | | none (below 0: returns) |

   The peak is where t⁴ = 0.5, t = 0.8409. With strength 0.5 every angle halves.
2. Death roll (applied once the entity is dying): deathTime + partial = 0 → 0 degrees; 1 → 0.199; 5 → 0.976; 10 → 1.905; 15 → 2.791; 19.5 → 3.554; 20 or more → 3.636.
3. A player hit from the east while facing south (yaw 0): hit direction vector from the victim to the source (dx, dz) = (1, 0); `indicateDamage` sends hurtDir = atan2(0, 1) × 57.2957763671875 − 0 = 0, so the tilt is a plain roll; the same hit while facing west (yaw 90) sends −90, a tilt about the view x axis (the hit now comes from straight ahead or behind in the camera's frame).

---

## Open questions

1. **Depth state and phase of the screen effects.** The shared GUI textured pipeline snippet used by `fire_screen_effect` and `block_screen_effect` sets no depth, cull or stencil state (read); the defaults of `RenderPipeline.Builder` were not read, so whether the fire quads are depth tested against the first-person hand, and in which feature phase (`executeSolid`, `executeTranslucent`, always-on-top) the custom-geometry submissions of the hand pass run relative to the hand models, was not traced. The code submits the hand first and the effects after it, and the fire is described above as drawn over the hand; that is by submission order only. The jar could not answer this from the classes read in this round.
2. **Client-side ignition.** In `Entity.baseTick` a level that is not a server level calls `clearFire` every tick (read: the else branch of the server-level test), which sets a positive `remainingFireTicks` back to 0, so on the client the count does not persist from tick to tick and the replicated flag (bit 0) is the effective source. Whether a client-side ignition (for example `lavaIgnite` during movement) can raise the count again after that call within the same tick, and so make `isOnFire` true for the extraction of that frame, was not traced.
3. **World-space flame of burning entities** (third-person local player, other players and mobs): `FlameFeatureRenderer` geometry, transforms and colour were not read (same gap as 34-8 Open question 14).
4. **Pumpkin overlay data.** That the carved pumpkin's equippable component names `misc/pumpkinblur` as `camera_overlay` is not read here; only the HUD code that draws any equippable's `camera_overlay` and the existence of the file `textures/misc/pumpkinblur.png` are.
5. **Colour modulator.** The default value of the `ColorModulator` uniform in the hand pass was not read (assumed white).
6. **`BlockState.isViewBlocking` rules** for the in-wall overlay (which blocks count) are in the block documents, not re-read here.
7. **Crossbow state on the client.** That the client sees `charged_projectiles` on the held crossbow when the charging flag falls (so that CROSSBOW_HOLD shows at once) (and whether the stack change reaches the client one tick after the flag, as the call order of §3.5 suggests) was not traced through the Set Equipment and Set Entity Data packets; inferred from the server's order of operations in §3.5.
8. **Piglin crossbow item pose in the hand.** How `ItemInHandLayer` transforms the crossbow item for the piglin while it charges or holds it was not read.
9. **Sign of the pitch form of the hurt tilt** (§5.3, hit from ahead or behind) was not worked out, and the clockwise and counter-clockwise statements of §5.2 are from the rotation convention, not from a rendered frame.
10. **Fire sprite filtering.** The sampler (filter, mip) of the blocks atlas for this pass was not read; the quad is large on screen, so the magnification filter matters visually.
11. **`/tick step` and the atlas clock.** `runGameElements` is recomputed per client tick (§1.4); how the texture clock behaves across a `/tick step` (frames in which `frozenTicksToRun` is above 0 versus the frames between steps) was derived only from that rule, not from a run, and the pause screen with a frozen level was not examined.
