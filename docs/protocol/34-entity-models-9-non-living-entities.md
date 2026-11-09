# 34 Entity models and renderers, part 9: entities without a living-mob model

| Item | Value |
|---|---|
| Covers | Round RS17 (GAP-25), part 9. Models, poses, render states and renderers of: all minecart variants, arrows (plain, tipped, spectral), the trident and the riptide spin-attack effect, the wind charge, thrown-item entities (snowball, egg, ender pearl, splash and lingering potion, experience bottle, eye of ender, fireball, small fireball), the firework rocket, the fishing hook and its line, dropped items and item clusters, the item frame and glow item frame, the painting, the lead knot, falling blocks, primed TNT (and the TNT minecart flash), the experience orb, the lightning bolt, the ominous item spawner, the cushion, block, item and text displays, and the table of entity types that have a renderer that draws nothing. The elytra and the shield are listed as worn equipment only (cross-reference) |
| Siblings (not repeated) | The other parts of this round (documents `34-entity-models-1` to `-8`): the shared framework (renderer base classes, `ModelPart` mechanics, layer registry, lighting of entities, shadows, name tags, leash drawing), living mobs, boats, end crystal, evoker fangs, shulker bullet, llama spit, wither skull and dragon fireball renderers. 12 §7 (player model), 14 §5.3 (box unwrap), 41 (item entity physics), 44 part 9 §6 (display entity data and interpolation), 45 part 8 (NBT of vehicles, projectiles, items) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `net.minecraft.client.model.object.*` (`cart`, `projectile`, `cushion`, `leash`, `equipment`), `net.minecraft.client.model.effects.SpinAttackEffectModel`, `net.minecraft.client.model.geom.*` (`ModelPart$Cube`, `ModelPart$Polygon`, `PartPose`, `PartDefinition`, `CubeListBuilder`, `LayerDefinitions`), `net.minecraft.client.renderer.entity.*` (renderers, `state.*`, `layers.SpinAttackEffectLayer`, `EntityRenderers`), and, where a renderer reads a value from them, `Display`, `ItemEntity`, `ExperienceOrb`, `AbstractMinecart` and its subclasses, `PrimedTnt`, `LightCoordsUtil`, `OverlayTexture`, `RenderPipelines`/`BlendFunction`, `Direction` |
| Scope rule | Standard Minecraft content is the target (CC-0001 decisions). Textures, item models, block models, painting variants and map data are data extracted by the tool (22) and are not tabulated: this document gives the texture paths the code asks for and every geometry, pose, colour, ordering and random-number constant, which is code |
| Evidence rule | Every number below was read from the artifact in this round. Items marked "(inferred)" were deduced; items marked "(recalled, not verified)" were not read. All are listed in Open questions |

Notation. Angles are radians unless "deg" is written. `D` = 0.017453292 (the float constant the code uses for degrees to radians). `pi` = 3.1415927. Model lengths are pixels (1/16 block). Cuboids are written `origin (ox, oy, oz) size (w, h, d)`, texture offset `tex (u, v)`; "grow g" enlarges each face by g pixels. Part poses are `off (x, y, z)` (pixels) and `rot (xRot, yRot, zRot)`; an absent entry is zero, an absent scale is 1. "Pose stack" operations are written in the order the code issues them: each multiplies on the right, so the **last** listed acts first on vertices (as in 12 §7.3). `lightCoords` is the packed light of 12 §1.4 (block light in bits 4 to 7, sky light in bits 20 to 23, see §2.5). "Camera orientation" is the quaternion of the camera (`CameraRenderState.orientation`) that turns a +z facing quad to face the camera.

---

## 1. Ownership and the renderer registry

### 1.1 Registry facts read from `EntityRenderers`

The class registers a renderer provider for 159 entity types; `PLAYER` and `MANNEQUIN` are created by `createAvatarRenderers` (12 §7), giving all 161 types of `EntityTypes` (checked by listing the static fields of `EntityTypes`: 161; registered 159; the difference is exactly `MANNEQUIN` and `PLAYER`). `validateRegistrations` logs "No renderer registered for {}" for a type without a provider, so every type has one.

The types of this document and the renderer each is registered with:

| Entity type id | Renderer class | Constructor arguments |
|---|---|---|
| `minecart`, `chest_minecart`, `furnace_minecart`, `hopper_minecart`, `command_block_minecart`, `spawner_minecart` | `MinecartRenderer` | model layer of the same name (all six use one `MinecartModel` definition, §3.1) |
| `tnt_minecart` | `TntMinecartRenderer` | layer `TNT_MINECART` |
| `arrow` | `TippableArrowRenderer` | |
| `spectral_arrow` | `SpectralArrowRenderer` | |
| `trident` | `ThrownTridentRenderer` | |
| `wind_charge`, `breeze_wind_charge` | `WindChargeRenderer` | |
| `snowball`, `egg`, `ender_pearl`, `splash_potion`, `lingering_potion`, `experience_bottle` | `ThrownItemRenderer` | scale 1.0, full bright false |
| `eye_of_ender` | `ThrownItemRenderer` | scale 1.0, full bright true |
| `fireball` | `ThrownItemRenderer` | scale 3.0, full bright true |
| `small_fireball` | `ThrownItemRenderer` | scale 0.75, full bright true |
| `firework_rocket` | `FireworkEntityRenderer` | |
| `fishing_bobber` | `FishingHookRenderer` | |
| `item` | `ItemEntityRenderer` | |
| `item_frame`, `glow_item_frame` | `ItemFrameRenderer` (one class, the type decides the variant) | |
| `painting` | `PaintingRenderer` | |
| `leash_knot` | `LeashKnotRenderer` | |
| `falling_block` | `FallingBlockRenderer` | |
| `tnt` | `TntRenderer` | |
| `experience_orb` | `ExperienceOrbRenderer` | |
| `lightning_bolt` | `LightningBoltRenderer` | |
| `ominous_item_spawner` | `OminousItemSpawnerRenderer` | |
| `cushion` | `CushionRenderer` | |
| `block_display`, `item_display`, `text_display` | `DisplayRenderer$BlockDisplayRenderer`, `$ItemDisplayRenderer`, `$TextDisplayRenderer` | |
| `area_effect_cloud`, `interaction`, `marker` | `NoopRenderer` | §1.2 |

### 1.2 Entity types that draw nothing

Only three of the 159 provider registrations use `NoopRenderer`: **`area_effect_cloud`, `interaction`, `marker`**. `NoopRenderer` has the plain `EntityRenderState` and no `submit` override: the base `submit` draws only leashes, and none of the three can be leashed: the entity classes `AreaEffectCloud` (Entity, TraceableEntity), `Interaction` (Entity, Attackable, Targeting) and `Marker` (Entity) do not implement `Leashable` (read from the class declarations). The area effect cloud's particles are produced by the entity's own tick (44 part 9); the interaction entity and marker are data holders (44 part 9 §7).

Renderers that are registered but draw nothing under a condition read in this round:

| Renderer | Condition for drawing nothing |
|---|---|
| `ItemEntityRenderer`, `OminousItemSpawnerRenderer` | the item render state is empty (an empty stack) |
| `ItemFrameRenderer` | the frame model is skipped when the frame is invisible; the item is skipped when the stack is empty and no map id; a frame with nothing in it and visible draws only its frame model |
| `PaintingRenderer` | the variant is null (an unresolved variant holder) |
| `FallingBlockRenderer` | the block state's render shape is not `MODEL`, or `shouldRender` is false because the level already holds the same state at the entity's block position (§13.1) |
| `FishingHookRenderer` | `shouldRender` requires the hook's player owner to be non-null |
| `DisplayRenderer` (all three) | no render state yet, or no sub-state (nothing set); the item display with an empty stack; the text display with no lines (draws only a background, which needs a non-zero ARGB) |
| `LightningBoltRenderer` | never culled (`affectedByCulling` false) |

### 1.3 Shadow, hitbox, name tag, fire, passengers and leash for the types of this document

Shadow radius and strength are the `shadowRadius` and `shadowStrength` fields the renderer constructor sets (read by listing the `putfield` of both fields in each renderer class). `EntityRenderer`'s constructor sets strength 1.0 and leaves radius at its default 0; a renderer that sets neither draws no shadow (34 part 1 §7.1 owns the shadow drawing).

| Renderer (types) | Shadow radius | Shadow strength | Hitbox |
|---|---|---|---|
| `MinecartRenderer`, `TntMinecartRenderer` | 0.7 | 1.0 (default) | see below |
| `ItemEntityRenderer` | 0.15 | 0.75 | see below |
| `ExperienceOrbRenderer` | 0.15 | 0.75 | see below |
| `FallingBlockRenderer` | 0.5 | 1.0 | see below |
| `TntRenderer` | 0.5 | 1.0 | see below |
| `DisplayRenderer` (3) | from the render state, interpolated (§17.1) | likewise | see below |
| arrows, trident, wind charge, thrown items, firework rocket, fishing hook, item frame, painting, lead knot, lightning, ominous item spawner, cushion | 0 (no `putfield` of either field in the class) | 1.0 (default, unused) | see below |

**Hitbox and eye height** (read from the `EntityTypes` static initialiser: the `sized(width, height)` call, and the `eyeHeight(h)` call where one is present; width and height are blocks). Where no `eyeHeight` call exists the type uses the engine default, which was not read here ((recalled, not verified): a fraction of the height; Open question 17). 18 owns the general bounding-box rules; the renderer only copies `boundingBoxWidth`, `boundingBoxHeight` and `eyeHeight` into the render state (34 part 1 §6.3).

| Entity types | Width x height | Eye height call |
|---|---|---|
| `minecart`, `chest_minecart`, `furnace_minecart`, `hopper_minecart`, `tnt_minecart`, `spawner_minecart`, `command_block_minecart` | 0.98 x 0.7 | none; `passengerAttachments` one point at y 0.1875 (below) |
| `arrow`, `spectral_arrow`, `trident` | 0.5 x 0.5 | 0.13 |
| `wind_charge`, `breeze_wind_charge` | 0.3125 x 0.3125 | 0 |
| `snowball`, `egg`, `ender_pearl`, `splash_potion`, `lingering_potion`, `experience_bottle`, `eye_of_ender`, `firework_rocket`, `fishing_bobber`, `ominous_item_spawner` | 0.25 x 0.25 | none |
| `fireball` | 1 x 1 | none |
| `small_fireball` | 0.3125 x 0.3125 | none |
| `item` | 0.25 x 0.25 | 0.2125 |
| `item_frame`, `glow_item_frame` | 0.5 x 0.5 (placeholder: the frame sets its own box from its position and facing) | 0 |
| `painting` | 0.5 x 0.5 (placeholder likewise) | none |
| `leash_knot` | 0.375 x 0.5 | 0.0625 |
| `falling_block` | 0.98 x 0.98 | none |
| `tnt` | 0.98 x 0.98 (and the type is fire immune: the only type in this list with that call) | 0.15 |
| `experience_orb` | 0.5 x 0.5 | none |
| `lightning_bolt`, `block_display`, `item_display`, `text_display` | 0 x 0 | none |

The "frame and painting set their own box" remark is (inferred) from the placeholder size, not read.

Name tag position and distance: 34 part 1 §7.2 (non-living entities use the squared compare with 64 squared; position is the `NAME_TAG` attachment, else the bounding height); item frame is the only renderer here that overrides `shouldShowName` (§10). Fire overlay (`displayFireAnimation`): 34 part 1 §7.4, applied by the dispatcher to every type here without a renderer override (none of the renderers of this document was read to override it).

**Minecart passengers** (read): `AbstractMinecart.getPassengerAttachmentPoint(passenger, dimensions, scale)` returns the constant `LOWERED_PASSENGER_ATTACHMENT = (0, 0, 0)` when the passenger is a villager or a wandering trader; for every other passenger it calls the `VehicleEntity` / `Entity` default, which resolves the type's `passengerAttachments` (one point at y 0.1875 for all seven minecarts, above); how that default turns the attachment into a position (clamping, rotation by yaw, scale) was not read (Open question 18). `Minecart.positionRider` first runs the common rider placement, then, on the client only, when the rider is a player whose `shouldRotateWithMinecart` is true and the experimental-movement check holds, sets the player's yaw to `yaw - (offset - playerRotationOffset)` where `offset = rotLerp(0.5, playerRotationOffset, rotationOffset)` and stores `offset` as the new `playerRotationOffset`; `playerRotationOffset` and `rotationOffset` are fields whose update path was not read.

**Leash** (read): none of the 74 classes of the packages `vehicle.minecart`, `projectile`, `item`, `decoration`, and of `Display`, `ExperienceOrb`, `LightningBolt`, `OminousItemSpawner`, `Interaction`, `Marker`, `AreaEffectCloud` names `Leashable` in its class header, and the `Entity` header does not either (while `Mob` does), so none of the types of this document can be leashed. The lead knot is the holder entity (§12), drawing: 34 part 1 §7.3. (Inheritance through intermediate classes was checked only by the headers listed; `Leashable` as an interface with default methods could in principle be inherited through a super-interface, which was not checked: Open question 19.)

---

## 2. Conventions this document relies on

**Sine and cosine.** Every `sin` and `cos` below (shake, hurt tilt, bob, orb colour, fishing hand angle) is `Mth.sin` / `Mth.cos`, the game's table-based functions (see 15). Read here: `sin(x)` returns `SIN[(long)(x * 10430.378350470453) & 65535]` (the double product is cast to long, which truncates toward zero, then masked, so negative arguments wrap); `cos(x)` returns `SIN[(long)(x * 10430.378350470453 + 16384.0) & 65535]`. `SIN` has 65536 float entries and entry `i` is the exact `Math.sin(i / 10430.378350470453)` narrowed to float (the table-fill loop was read). The argument is therefore quantised to a step of 1 / 10430.378350470453 = 9.59e-5 rad (2*pi / 65536), and truncation toward zero makes the error up to one step; the resulting value error bound of about 1e-4 is (inferred) from that step, not measured. The worked examples (the orb colours r = 127, b = 3 and 12, among others) were computed with the exact sine; their integer truncations can differ at boundaries.

These facts were read here because every model below needs them. The framework part (34 part 1) is the owner of the general statement; this section is what part 9 actually depends on.

### 2.1 How a model part is placed (`ModelPart.translateAndRotate`)

For a part with pose `off (x, y, z)`, `rot (xRot, yRot, zRot)`, `scale (sx, sy, sz)` the code does, in this order on the pose stack: translate by `(x/16, y/16, z/16)`; if any rotation is non-zero, rotate by the quaternion `rotationZYX(zRot, yRot, xRot)` (the call to `rotationZYX` was read; that it applies x first, then y, then z to vertices is JOML library semantics, (recalled, not verified), Open question 21); if any scale differs from 1, scale by `(sx, sy, sz)`. Children are drawn inside the parent's transform. `PartPose.offsetAndRotation(...)` has scale 1; `PartPose.offset`, `rotation` likewise; `withScale(s)` sets all three scales to `s` and keeps offset and rotation; `scaled(s)` multiplies offset and scale by `s` and leaves rotation.

`PartDefinition.transformed(op)` replaces **only that part's own pose** by `op(pose)`; children are carried over unchanged. `MeshDefinition.transformed(op)` does this to the root part only. So `ArrowModel`'s `transformed(scaled 0.9)` (§4.1) gives the root a scale of 0.9 and leaves the children's poses as defined, and the whole model ends up 0.9 times its defined size, including the child offsets.

### 2.2 Cuboid unwrap with texture scale (`ModelPart$Cube`, `Polygon`)

A cuboid built with `addBox(x, y, z, w, h, d)` at texture offset (u, v) has six faces. The constructor's texture rectangles in pixels, with `x1 = u + d`, `x2 = u + d + w`, `x3 = u + d + 2w`, `x4 = u + 2d + w`, `x5 = u + 2d + 2w` and `y0 = v`, `y1 = v + d`, `y2 = v + d + h`:

| Face (constructor name) | u range | v range |
|---|---|---|
| `DOWN` (the face at the minimum model y, which is the visual top because model y points down) | `x1 .. x2` | `y0 .. y1` |
| `UP` (maximum model y, visual bottom) | `x2 .. x3` | `y1 .. y0` (v range given in reverse order, so the face reads upright) |
| `WEST` | `u .. x1` | `y1 .. y2` |
| `NORTH` | `x1 .. x2` | `y1 .. y2` |
| `EAST` | `x2 .. x4` | `y1 .. y2` |
| `SOUTH` | `x4 .. x5` | `y1 .. y2` |

This agrees with the 14 §5.3 table (top at `u + d`, bottom at `u + d + w`). This section adds only the two facts that table does not state:

1. **Texture scale.** `addBox(..., deformation, uScale, vScale)` divides pixel coordinates by `texWidth * uScale` and `texHeight * vScale` instead of by the layer's texture size (`CubeDefinition.bake` multiplies the layer size by the scale before the cube is built). Only the arrow's two cross planes use a scale other than 1 (§4.1).
2. **Zero-depth or zero-width boxes** (the arrow back plane and cross planes, d = 0 or w = 0) are built the same way: the two big faces coincide in space, the thin faces are degenerate. The faces with a zero extent sample a zero-area texture rectangle.

The `mirror` flag swaps the x extents of the cuboid and reverses the vertex order of every polygon.

### 2.3 Render types named in this document

`RenderTypes.entityCutout(tex)`: alpha-tested, **not** back-face culled. `entityCutoutCull(tex)`: alpha-tested, culled. `entitySolid(tex)`: opaque. `entitySolidGlint(tex)`: opaque plus the enchantment glint (12 §8.3). `entitySolidZOffsetForward(tex)`: opaque, depth pushed slightly toward the viewer. `entityTranslucent(tex)` (argument 1: affects outline): blended translucent. `lightning()`: pipeline `lightning`, blend function `LIGHTNING`: colour factors (source alpha, one), i.e. `dst + src * srcAlpha` (read from `BlendFunction`; only the colour factors were read). `breezeWind(tex, uOffset, vOffset)`: pipeline `breeze_wind`, translucent blend (source alpha, one minus source alpha), alpha cut-out, texture matrix offset `(uOffset, vOffset)`, no overlay, no cardinal lighting, no culling. A model's default render type (class `EntityModel`, one-argument constructor) is `entityCutout`.

### 2.4 Submitting a model

`SubmitNodeCollector.submitModel(model, state, pose, texture-or-rendertype, lightCoords, overlay, outlineColor)` runs `model.setupAnim(state)` (which first resets every part to its definition pose) and then draws the root part with the current pose stack. The overlay argument in all renderers below is `OverlayTexture.NO_OVERLAY` unless said otherwise.

### 2.5 Light coordinates and the overlay texture

`LightCoordsUtil.pack(block, sky) = (block << 4) | (sky << 20)`; `block(l) = (l >> 4) & 15`; `sky(l) = (l >> 20) & 15`. Constants used here: **15728880** = block 15, sky 15 (full bright); **15728850** = 15728640 + 210: sky 15, block field 13, plus a 2 in the unused low nibble (only the block and sky fields are read by the light map).

`OverlayTexture` is a 16 x 16 texture. Rows 0 to 7: colour `0xB2FF0000` (hurt red, ARGB -1291911168). Rows 8 to 15 (v = 10 is "not hurt"): white with alpha `int((1 - (u/15) * 0.75) * 255)` at column u. `u(f) = int(f * 15)`, `v(hurt) = 3 if hurt else 10`, `pack(u, v) = u | (v << 16)`. `NO_OVERLAY = pack(0, 10)`: pixel (0, 10) is alpha 255 white (no tint). The TNT flash uses `pack(u(1.0) = 15, 10)`: pixel (15, 10), alpha `int(0.25 * 255) = 63`. How the shader mixes the overlay texel into the colour was not read (Open question 5); the intent is "blend towards white" (inferred).

---

## 3. Minecarts

### 3.1 `MinecartModel` (layer definition shared by all seven minecarts, texture 64 x 32)

`LayerDefinitions` registers one `MinecartModel.createBodyLayer()` result under `MINECART`, `CHEST_MINECART`, `COMMAND_BLOCK_MINECART`, `FURNACE_MINECART`, `HOPPER_MINECART`, `SPAWNER_MINECART` and `TNT_MINECART` alike. Parts (all children of the root, root pose zero):

| Part | tex | Cuboid origin | Size (w, h, d) | Pose offset | Pose rotation |
|---|---|---|---|---|---|
| `bottom` | (0, 10) | (-10, -8, -1) | 20 x 16 x 2 | (0, 4, 0) | xRot = 1.5707964 |
| `front` | (0, 0) | (-8, -9, -1) | 16 x 8 x 2 | (-9, 4, 0) | yRot = 4.712389 |
| `back` | (0, 0) | (-8, -9, -1) | 16 x 8 x 2 | (9, 4, 0) | yRot = 1.5707964 |
| `left` | (0, 0) | (-8, -9, -1) | 16 x 8 x 2 | (0, 4, -7) | yRot = 3.1415927 |
| `right` | (0, 0) | (-8, -9, -1) | 16 x 8 x 2 | (0, 4, 7) | none |

(The four side walls share one texture rectangle.) `MinecartModel.setupAnim` adds nothing. Texture path: `textures/entity/minecart/minecart.png`.

### 3.2 Renderer (`AbstractMinecartRenderer`, `MinecartRenderer`, `TntMinecartRenderer`)

Shadow radius 0.7 (`shadowRadius` field, default shadow strength 1.0).

**Render state** (`MinecartRenderState`, extends `EntityRenderState`): `isNewRender` (bool), `renderPos` (Vec3 or null), `xRot`, `yRot`, `posOnRail`, `frontPos`, `backPos` (Vec3 or null), `offsetSeed` (long), `hurtTime`, `hurtDir`, `damageTime`, `displayOffset` (int), `displayBlockModel` (a block model render state, empty by default). `MinecartTntRenderState` adds `fuseRemainingInTicks` (float, default -1.0).

**Extraction** (`extractRenderState(entity, state, partialTick pt)`), in order:

1. Base fields (position lerp, ageInTicks, lightCoords, ...) as the base renderer does (framework).
2. If the entity's movement behaviour is the new behaviour (`NewMinecartBehavior`): `isNewRender = true`; if the cart has a position/rotation lerp (`cartHasPosRotLerp`): `renderPos = getCartLerpPosition(pt)`, `xRot = getCartLerpXRot(pt)`, `yRot = getCartLerpYRot(pt)`; else `renderPos = null`, `xRot = entity.getXRot()`, `yRot = entity.getYRot()`.
3. Else if the behaviour is the old one (`OldMinecartBehavior`): `isNewRender = false`; `xRot = getXRot(pt)`, `yRot = getYRot(pt)`; with `(x, y, z)` = the state's interpolated position: `posOnRail = getPos(x, y, z)`; if it is non-null, `frontPos = getPosOffs(x, y, z, +0.3)` and `backPos = getPosOffs(x, y, z, -0.3)`, each replaced by `posOnRail` when null (the constant is the float 0.3 widened: 0.30000001192092896); otherwise all three are null.
4. `offsetSeed`: with `s = id * 493286711` (64-bit signed, wrapping, `id` the entity id), `offsetSeed = s * s * 4392167121 + s * 98761` (64-bit wrapping).
5. `hurtTime = entity.getHurtTime() - pt`; `hurtDir = entity.getHurtDir()` (an int, +1 or -1); `damageTime = max(entity.getDamage() - pt, 0)`; `displayOffset = entity.getDisplayOffset()`; the display block model is resolved from `getDisplayBlockState()` with block display context.
6. TNT minecart: `fuse = entity.getFuse()`; `fuseRemainingInTicks = (fuse > -1) ? (fuse - pt + 1.0) : -1.0`.

**Render offset** (`getRenderOffset`): the base offset, plus, when `renderPos` is non-null, `renderPos - (x, y, z)` (the new behaviour places the cart at its own lerped position). **Culling box**: the base box, expanded toward +y (x and z unchanged) by `displayOffset * 0.75 / 16` (float arithmetic) whenever `getDisplayBlockState()` is **not air** (read from `getBoundingBoxForCulling`). The default display counts: the chest, furnace, hopper, spawner, command-block and TNT carts are all expanded; only the plain minecart, whose default display is air, returns the unchanged box; a custom display state set on any cart counts too.

**Submit** (one pass, pose stack starting at the entity position plus render offset):

1. Base submit (leashes).
2. push. Translate by `(ox, oy, oz)` where for the three offsets with shifts 16, 20, 24: `o = ((((offsetSeed >> shift) & 7) + 0.5) / 8 - 0.5) * 0.004` (so each is one of eight values in [-0.00175, +0.00175] in steps of 0.0005); this separates overlapping carts' z-fighting surfaces.
3. If `isNewRender`: rotate Y by `yRot` deg, rotate Z by `-xRot` deg, translate `(0, 0.375, 0)`.
   Else (old): with `(x, y, z)` the state position: if `posOnRail`, `frontPos`, `backPos` are all non-null: translate by `(posOnRail.x - x, (front.y + back.y)/2 - y, posOnRail.z - z)`; let `v = back - front`; if `|v| != 0`: `v` normalised, `yaw = atan2(v.z, v.x) * 180 / pi` (degrees, double precision), `pitch = atan(v.y) * 73.0` (degrees; the factor 73 is a read constant), replacing the state's `yRot` and `xRot`. Then in all old cases: translate `(0, 0.375, 0)`, rotate Y by `180 - yaw` deg, rotate Z by `-pitch` deg (yaw and pitch are the possibly replaced values).
4. If `hurtTime > 0`: rotate X by `sin(hurtTime) * hurtTime * damageTime / 10 * hurtDir` degrees (`Mth.sin` of the float, radians in, i.e. a sine of the tick count).
5. If the display block model is non-empty: push; scale 0.75; translate `(-0.5, (displayOffset - 8) / 16, 0.5)`; rotate Y 90 deg; call `submitMinecartContents(state, blockModel, pose, collector, lightCoords)`; pop. The base `submitMinecartContents` submits the block model with `NO_OVERLAY`. (Display offsets, read from `getDefaultDisplayOffset`: `AbstractMinecart` returns 6, `MinecartChest` overrides it to 8, `MinecartHopper` to 1; `MinecartFurnace`, `MinecartSpawner`, `MinecartCommandBlock`, `MinecartTNT` and `Minecart` declare no override, so they use 6. The effective offset is `getDisplayOffset()`, the integer synched-data accessor `DATA_ID_DISPLAY_OFFSET`, initialised in `defineSynchedData` from `getDefaultDisplayOffset()`.)
6. Scale `(-1, -1, 1)` and submit the minecart model with texture `minecart.png`, `lightCoords`, `NO_OVERLAY`.
7. pop.

**Display block per type** (`getDefaultDisplayBlockState`): `minecart` air (nothing drawn); `chest_minecart` chest facing north; `furnace_minecart` furnace facing north, `lit` = the cart's `hasFuel()` (set in the same method that sets FACING = NORTH); `hopper_minecart` hopper; `spawner_minecart` spawner (a plain block model, **no spinning mob** is drawn by this renderer); `command_block_minecart` command block; `tnt_minecart` TNT. Each default was read from the `getDefaultDisplayBlockState` method of the named class: `AbstractMinecart` (and so `Minecart`) returns the default state of air; `MinecartChest` sets the chest `FACING` to `Direction.NORTH`; `MinecartFurnace` sets the furnace `FACING` to `NORTH` and `LIT` to `hasFuel()`; `MinecartHopper`, `MinecartSpawner`, `MinecartCommandBlock` and `MinecartTNT` return the default state of their block (no property set). The effective state, `getDisplayBlockState()`, is the content of the synched-data accessor `DATA_ID_CUSTOM_DISPLAY_BLOCK` (an `Optional` of a block state) when present, else the default; which commands or NBT set the custom accessor is the server side (45 part 8) and was not read here.

**TNT minecart contents** (`TntMinecartRenderer.submitMinecartContents`, called in step 5 with the 0.75 scale already applied): `f = fuseRemainingInTicks`; if `-1 < f < 10`: `a = swell(f)`, translate `(-a * 0.5, 0, -a * 0.5)` then scale by `1 + a` uniformly. Then `submitWhiteSolidBlock(blockModel, pose, collector, light, isLit(f), outlineColor)` (§13.2): overlay `pack(15, 10)` when lit, else `NO_OVERLAY`.

---

## 4. Arrows

### 4.1 `ArrowModel` (texture 32 x 32; layer `ARROW`)

Root pose: scale 0.9 (from `transformed(scaled 0.9)`, §2.1). Children:

| Part | tex | Cuboid origin | Size | Texture scale (u, v) | Pose |
|---|---|---|---|---|---|
| `back` | (0, 0) | (0, -2.5, -2.5) | 0 x 5 x 5 | (1, 1) | off (-11, 0, 0), rot xRot = 0.7853982, scale 0.8 |
| `cross_1` | (0, 0) | (-12, -2, 0) | 16 x 4 x 0 | (1, 0.8) | rot xRot = 0.7853982 |
| `cross_2` | (0, 0) | (-12, -2, 0) | 16 x 4 x 0 | (1, 0.8) | rot xRot = 2.3561945 |

(`cross_1` and `cross_2` share one cuboid definition.) Because the cross planes use v scale 0.8, their effective texture height for the divide is 32 * 0.8 = 25.6: the north face samples pixel rows 0 to 4 as `v = row / 25.6` (so 0 to 0.15625), the south face the same rows 0 to 4 at u offset 16 to 32 (the `x4 .. x5` span, §2.2). Because the cuboids have depth 0 the faces visible are the two big ones (north and south).

`setupAnim(ArrowRenderState)`: after the reset, if `shake > 0`: `root.zRot += -sin(shake * 3) * shake * D` (the sine in radians of `shake * 3`).

### 4.2 Renderers

`ArrowRenderer` (base of the two below): model layer `ARROW`; render type `entityCutoutCull` (the model's constructor function). **Extraction**: `xRot = entity.getXRot(pt)`, `yRot = entity.getYRot(pt)`, `shake = entity.shakeTime - pt`. **Submit**: push; rotate Y by `yRot - 90` deg; rotate Z by `xRot` deg; submit the model with the renderer's texture; pop. Model space here is not flipped (no `(-1, -1, 1)` scale); the shaft lies along the model x axis, nock at x = -12, so the tip points along +x before the rotations.

| Renderer | Texture |
|---|---|
| `TippableArrowRenderer` | `textures/entity/projectiles/arrow.png`, or `.../arrow_tipped.png` when `isTipped` |
| `SpectralArrowRenderer` | `textures/entity/projectiles/arrow_spectral.png` |

`isTipped = (arrow.getColor() > 0)` (the tipped-arrow potion colour; extraction of `TippableArrowRenderState`).

---

## 5. Trident and the spin-attack effect

### 5.1 `TridentModel` (texture 32 x 32; layer `TRIDENT`)

The `pole` part is a child of the root (pose zero); the four heads are children of `pole` with zero pose:

| Part | tex | Cuboid origin | Size | Mirror |
|---|---|---|---|---|
| `pole` | (0, 6) | (-0.5, 2, -0.5) | 1 x 25 x 1 | no |
| `base` | (4, 0) | (-1.5, 0, -0.5) | 3 x 2 x 1 | no |
| `left_spike` | (4, 3) | (-2.5, -3, -0.5) | 1 x 4 x 1 | no |
| `middle_spike` | (0, 0) | (-0.5, -4, -0.5) | 1 x 4 x 1 | no |
| `right_spike` | (4, 3) | (1.5, -3, -0.5) | 1 x 4 x 1 | yes |

Render type `entitySolid` (the constructor function). No `setupAnim`.

### 5.2 `ThrownTridentRenderer`

State: `xRot`, `yRot`, `isFoil`. Extraction: `yRot = getYRot(pt)`, `xRot = getXRot(pt)`, `isFoil = entity.isFoil()`. Culling box inflated by 1.5 in all directions. Submit: push; rotate Y by `yRot - 90` deg; rotate Z by `xRot + 90` deg; submit the model with texture `textures/entity/trident/trident.png`, using `entitySolidGlint` when `isFoil`; pop. There is no y flip: with xRot = 0 the 90 deg z rotation lays the pole (which extends toward +y in model space) along the horizontal; the spikes (negative y) end up at the front (inferred from the signs).

### 5.3 `SpinAttackEffectModel` (riptide effect; layer `PLAYER_SPIN_ATTACK`, texture 64 x 64)

Two parts named `box0` and `box1` (the name is `"box" + i`), children of the root. For `i` = 0 and 1: `offset = -3.2 + 9.6 * (i + 1)`, `scale = 0.75 * (i + 1)`; cuboid origin `(-8, -16 + offset, -8)`, size 16 x 32 x 16, tex (0, 0); pose zero with scale `scale` on all axes. `setupAnim(AvatarRenderState)`: `box[i].yRot = wrapDegrees(ageInTicks * -(45 + (i + 1) * 5)) * D`, so box0 spins at -50 deg per tick, box1 at -55 deg per tick.

Its layer (`SpinAttackEffectLayer`, a render layer of the player renderer, 12 §7.6) draws only when `isAutoSpinAttack`; texture `textures/entity/trident/trident_riptide.png`; it submits with the player's pose stack as it stands for layers.

---

## 6. Wind charge

### 6.1 `WindChargeModel` (texture 64 x 32; layer `WIND_CHARGE`)

Root child `bone` (pose zero), with two children:

| Part | tex | Cuboids | Pose |
|---|---|---|---|
| `wind` | (15, 20) then (0, 9) | origin (-4, -1, -4) size 8 x 2 x 8; origin (-3, -2, -3) size 6 x 4 x 6 (deformation 0 on both) | rot yRot = -0.7854 |
| `wind_charge` | (0, 0) | origin (-2, -2, -2) size 4 x 4 x 4 | none |

`setupAnim(EntityRenderState)`: `wind_charge.yRot = -ageInTicks * 16 * D`; `wind.yRot = +ageInTicks * 16 * D`. These are assignments, so the `-0.7854` pose rotation of `wind` is **replaced** (not added to).

### 6.2 `WindChargeRenderer`

Plain `EntityRenderState`. Submit: no extra transform; submit the model with render type `breezeWind(texture, u, 0)` where `u = (ageInTicks * 0.03) mod 1.0`, texture `textures/entity/projectiles/wind_charge.png`; the texture matrix offset scrolls the u coordinate (§2.3).

---

## 7. Thrown items and the firework rocket

### 7.1 `ThrownItemRenderer` (scale s, full bright flag)

Used by the types and arguments of §1.1. `ThrownItemRenderState` holds an `ItemStackRenderState item`. Extraction: the item is resolved from `entity.getItem()` for display context `GROUND` (so the item model's `ground` display transform applies, 12 §8.2). Block light: if `fullBright`, the block light level is **15** (`getBlockLightLevel` returns 15), else the normal block light; the sky light is normal.

Submit: push; scale `(s, s, s)`; rotate by the camera orientation (the item always faces the camera, no spin, no bob); submit the item model with `lightCoords`, `NO_OVERLAY`, `outlineColor`; pop. There is no shadow radius set (0, no shadow).

### 7.2 `FireworkEntityRenderer`

State: `isShotAtAngle` (bool), `item`. Extraction: `isShotAtAngle = entity.isShotAtAngle()`; item for `GROUND` context from `getItem()`. Submit: push; rotate by the camera orientation; if `isShotAtAngle`: rotate Z by 180 deg, then Y by 180 deg, then X by 90 deg (applied in this order on the stack); submit the item with `lightCoords`; pop. (No scale; the item model's ground transform supplies the size.)

---

## 8. Fishing hook (`FishingHookRenderer`)

Texture `textures/entity/fishing/fishing_hook.png`, render type `entityCutoutCull`. `shouldRender` is true only when the base test passes and `getPlayerOwner() != null`; `affectedByCulling` is false (never frustum-culled by the box).

**Extraction** (`FishingHookRenderState.lineOriginOffset`, a Vec3, default zero): if the owner is null the offset is zero. Else with `swing = owner.getSwingAnimation(pt)`, `f = sin(sqrt(swing) * pi)`: `hand = getPlayerHandPos(owner, f, pt)`; `hook = entity.getPosition(pt) + (0, 0.25, 0)`; `lineOriginOffset = hand - hook`.

`getHoldingArm(player)`: the main arm when the main-hand item is a fishing rod, else the opposite arm. `side = +1` when that arm is RIGHT, else `-1`. `getPlayerHandPos`:

* **Third person** (the camera is not first-person, or the player is not the local player): `a = lerp(pt, yBodyRotO, yBodyRot) * D`; `s = side * 0.35 * scale`, `fw = 0.8 * scale` (`scale` = `player.getScale()`); `dy = isCrouching ? -0.1875 : 0`; result = `eyePosition(pt) + (-cos(a) * s - sin(a) * fw, dy - 0.45 * scale, -sin(a) * s + cos(a) * fw)`.
* **First person, local player**: `fov` = the option `fov` (integer degrees); `k = 960 / fov` (double); `v = camera.getNearPlane(fov).getPointOnPlane(side * 0.525, -0.1)` (`getPointOnPlane(x, y)` = `forward + up * y - left * x`, read), scaled by `k`, rotated about y by `f * 0.5` and about x by `-f * 0.7` (radians); result = `eyePosition(pt) + v`. (`Camera.getNearPlane(fov)` was read: aspect = projection width / height; half-height = `tan(fov * 0.017453292 / 2) * zNear`; half-width = half-height * aspect; the plane is centred `zNear` along the camera forward vector and spans the camera left and up vectors. The body of `getPointOnPlane` was not read: Open question 12.)

**Submit** (two pieces, pose origin = hook position):

1. push; scale 0.5; rotate by the camera orientation; draw a quad with render type `entityCutoutCull(fishing_hook.png)`, four vertices in this order, each `(px - 0.5, py - 0.5, 0)` with colour white, overlay `NO_OVERLAY`, light `lightCoords`, normal (0, 1, 0), and uv `(u, v)`: `(px, py, u, v)` = (0, 0, 0, 1), (1, 0, 1, 1), (1, 1, 1, 0), (0, 1, 0, 0). The quad is one block wide, the whole texture. pop.
2. The line: with `(dx, dy, dz) = lineOriginOffset` and `lw` = the window's `appropriateLineWidth`, render type `lines`, in the same outer pose (not scaled or billboarded): for `i` = 0 to 15: with `t0 = i / 16`, `t1 = (i + 1) / 16` emit two vertices, first for `(t0, t1)` then for `(t1, t0)`. A vertex for `(t, tNext)` is at `P(t) = (dx * t, dy * (t * t + t) * 0.5 + 0.25, dz * t)`, colour `0xFF000000` (opaque black), line width `lw`, normal = `normalize(P(tNext) - P(t))` (length from the three differences). So the string leaves the hook 0.25 above its origin and ends at the hand, sagging along the parabola `t^2 + t`.

---

## 9. Dropped items, item clusters and the ominous item spawner

### 9.1 `ItemClusterRenderState` (shared by `ItemEntityRenderer` and `OminousItemSpawnerRenderer`)

Fields: `item` (item render state), `count` (int), `seed` (int). `extractItemGroupRenderState(entity, stack, resolver)`: item for display context `GROUND` (entity as owner); `count = renderedAmount(stack.getCount())`; `seed = seedFor(stack)`.

| Stack count n | Rendered copies `renderedAmount` |
|---|---|
| n <= 1 | 1 |
| 2 to 16 | 2 |
| 17 to 32 | 3 |
| 33 to 48 | 4 |
| 49 and above | 5 |

`seedFor(stack)` = 187 for an empty stack, else `registryId(item) + damageValue` (`Item.getId`, the raw registry id of the item, see 25 for the item registry order, plus the stack's damage value).

### 9.2 `ItemEntityRenderer`

Shadow radius 0.15, shadow strength 0.75. State adds `bobOffset = entity.bobOffs` (a float fixed at entity creation: `nextFloat() * pi * 2`, 41). The renderer owns a `RandomSource.create()` (unseeded; it is reseeded on every draw, below).

Submit: if the item state is empty, return. Else with `bb = item.getModelBoundingBox()` (the union of the item model's extents in block units; an empty model yields a zero-size box at the origin; Open question 4):

1. push. `base = -bb.minY + 0.0625`; `bob = sin(ageInTicks / 10 + bobOffset) * 0.1 + 0.1`; translate `(0, bob + base, 0)`.
2. rotate about Y by `spin = ageInTicks / 20 + bobOffset` **radians** (`ItemEntity.getSpin`).
3. `submitMultipleFromCount(pose, collector, lightCoords, state, random, bb)`.
4. pop.

**`submitMultipleFromCount`** (also used by the ominous spawner): `n = state.count` (0 draws nothing); `random.setSeed(seed)` (an `Random` LCG, 10 §2.6); `zs = bb.zSize`.

* **Thick model** (`zs > 0.0625`): submit the item once unshifted; then for each of the other `n - 1` copies: push, translate by `((r1 * 2 - 1) * 0.15, (r2 * 2 - 1) * 0.15, (r3 * 2 - 1) * 0.15)` where `r1, r2, r3` are three consecutive `nextFloat()` calls in the order x, y, z, submit, pop.
* **Flat model** (`zs <= 0.0625`): `step = zs * 1.5`; translate `(0, 0, -(step * (n - 1)) / 2)`; submit the item; translate `(0, 0, step)`; then for each of the other `n - 1` copies: push, translate `((r1 * 2 - 1) * 0.15 * 0.5, (r2 * 2 - 1) * 0.15 * 0.5, 0)` (two draws, x then y), submit, pop, translate `(0, 0, step)`. So flat copies stack along z (toward the viewer at spin 0) with a small random x, y scatter.

Each submit is `item.submit(pose, collector, lightCoords, NO_OVERLAY, outlineColor)`. The renderer class also contains a second, equivalent routine `renderMultipleFromCount` with the same arithmetic (only the order of reading the bounding box differs).

### 9.3 `OminousItemSpawnerRenderer`

Own `RandomSource.create()`. Extraction: `item` group state from `entity.getItem()`. Submit: if the item state is empty, return. push; `age = ageInTicks`; if `age <= 50`: scale by `age / 50` uniformly (so the item grows over 50 ticks, then stays 1); rotate about Y by `wrapDegrees(age * 40)` **degrees**; `submitMultipleFromCount(pose, collector, 15728880, state, random)` (fixed full-bright light, **no** bob and no base offset); pop.

---

## 10. Item frame and glow item frame (`ItemFrameRenderer`)

State (`ItemFrameRenderState`): `direction`, `item`, `rotation`, `isGlowFrame`, `mapId` (nullable), `mapRenderState`, `frameModel` (a block model render state). Extraction: `direction = entity.getDirection()`; item for display context `FIXED`; `rotation = entity.getRotation()`; `isGlowFrame = (type == glow_item_frame)`; `mapId = null`; if the stack is non-empty and `getFramedMapId(stack)` is non-null and the level has the map data, the map renderer extracts `mapRenderState` and `mapId` is set. Frame model: if the entity is invisible, cleared; else the fake block state of the frame (`BlockStateDefinitions.getItemFrameFakeState(glow, hasMap)`: the item frame or glow item frame block with the boolean property `map` set to `hasMap`), resolved with block display context. `hasMap` is `mapId != null`.

Block light: for a glow frame `max(5, blockLight)`, else the normal level. `getRenderOffset` = `(stepX * 0.3, -0.25, stepZ * 0.3)` with the direction's horizontal step; the submit undoes it (first step below).

**Submit** (pose origin = entity position plus render offset): base submit (leashes); push; translate by `-renderOffset`; translate by `step * 0.46875` per axis (the direction's unit step); then:

* horizontal direction: `xRot = 0`, `yRot = 180 - direction.toYRot()` deg;
* vertical (UP or DOWN): `xRot = -90 * axisDirectionStep` deg (UP: -90, DOWN: +90), `yRot = 180` deg;

rotate X by `xRot`, then Y by `yRot` (this order on the stack).

1. If the frame model is non-empty: push; translate `(-0.5, -0.5, -0.5)`; submit the frame block model with a z offset (`submitWithZOffset`, depth bias toward the viewer to avoid z-fighting with the wall), `lightCoords`, `NO_OVERLAY`; pop.
2. Translate `(0, 0, 0.5)` if the entity is invisible, else `(0, 0, 0.4375)`.
3. If `mapId != null` (a map): rotate Z by `(rotation mod 4) * 2 * 360 / 8` deg, i.e. a multiple of 90 deg; rotate Z by 180 deg; scale 0.0078125 (1/128) uniformly; translate `(-64, -64, 0)`; translate `(0, 0, -1)`; light = `isGlowFrame ? 15728850 : lightCoords`; call the map renderer with `mapRenderState`, the pose, collector, flag 1 and that light. (The 128 x 128 map image is therefore drawn on the pixel grid of one block, 1/128 per map pixel, rotated by quarter turns.)
4. Else if the item is non-empty: rotate Z by `rotation * 360 / 8` deg (45 deg steps, 8 positions); light = `isGlowFrame ? 15728880 : lightCoords`; scale 0.5 uniformly; submit the item (display context FIXED) with `NO_OVERLAY`.
5. pop.

**Name tag**: `shouldShowName` is true only when the HUD is not hidden, the entity is the crosshair target, and the stack has a custom name; the text is the stack's hover name (the name tag drawing itself is the framework).

Worked example: a frame on the north face (`direction` NORTH, step (0, 0, -1), `toYRot` 180, read: NORTH has 2D data value 2 and `toYRot` is `(data2D & 3) * 90`): translate `(0, 0, -0.46875)`, `yRot = 180 - 180 = 0`, then the item is drawn at `z = -0.46875 + 0.4375 = -0.03125` in the pose's own axes for a visible frame, at a 0.5 scale; that this lies on the room side of the wall plane is deduced from the direction step and is not read (inferred).

---

## 11. Painting (`PaintingRenderer`)

State: `direction`, `variant` (width and height in blocks, an asset id), `lightCoordsPerBlock` (int array, length `width * height`). Texture atlas: the painting atlas (`AtlasIds.PAINTINGS`); the front sprite is the variant's asset id and the back sprite is the sprite named `back` (namespace `minecraft`).

**Extraction**: `direction = entity.getDirection()`, `variant = entity.getVariant().value()`; `w`, `h` = variant size; the light array is re-allocated when its length is not `w * h`. For `j` = 0 to h-1 (rows), `i` = 0 to w-1: `ox = (i + (-w / 2)) + 0.5`, `oy = (j + (-h / 2)) + 0.5` (`-w / 2` is a float division); the block position is `(blockX, floor(y + oy), blockZ)` with the axis along the wall replaced:

| Direction | Block x | Block z |
|---|---|---|
| NORTH | `floor(x + ox)` | entity block z |
| WEST | entity block x | `floor(z - ox)` |
| SOUTH | `floor(x - ox)` | entity block z |
| EAST | entity block x | `floor(z + ox)` |

`lightCoordsPerBlock[i + j * w] = LightCoordsUtil.getLightCoords(level, pos)` (the level's brightness at that block; a block with emissive rendering gives 15728880; otherwise the packed brightness with the block part raised to the block's light emission when that is higher).

**Submit**: if the variant is null, return. push; rotate Y by `180 - data2D(direction) * 90` deg (`get2DDataValue`: SOUTH 0, WEST 1, NORTH 2, EAST 3, all read from the `Direction` initialiser); draw with render type `entitySolidZOffsetForward(back sprite atlas texture)`; pop.

**Geometry** (`renderPainting`, per cell `(i, j)`, `w x h` cells; `z = 0.03125`): `x1 = -w/2 + i + 1`, `x0 = -w/2 + i`, `y1 = -h/2 + j + 1`, `y0 = -h/2 + j`; the painting sprite uv for the cell: `uA = painting.getU((w - i) / w)`, `uB = painting.getU((w - i - 1) / w)`, `vA = painting.getV((h - j) / h)`, `vB = painting.getV((h - j - 1) / h)` (`getU(f)`/`getV(f)` interpolate between the sprite's u0..u1, v0..v1); back-sprite constants `u0, u1, v0, v1` = the back sprite's full rectangle, `uS = back.getU(0.0625)`, `vS = back.getV(0.0625)`. Each vertex: position `(x, y, zz)`, colour white, overlay `NO_OVERLAY`, light = `lightCoordsPerBlock[i + j * w]`, with the listed normal. Vertex order per face:

| Face | Normal | Vertices `(x, y, zz, u, v)` in order | Sprite |
|---|---|---|---|
| front | (0, 0, -1) | `(x1, y0, -z, uB, vA)`, `(x0, y0, -z, uA, vA)`, `(x0, y1, -z, uA, vB)`, `(x1, y1, -z, uB, vB)` | painting |
| back | (0, 0, +1) | `(x1, y1, +z, u1, v0)`, `(x0, y1, +z, u0, v0)`, `(x0, y0, +z, u0, v1)`, `(x1, y0, +z, u1, v1)` | back |
| top edge (only `j = h - 1`) | (0, 1, 0) | `(x1, y1, -z, u0, v0)`, `(x0, y1, -z, u1, v0)`, `(x0, y1, +z, u1, vS)`, `(x1, y1, +z, u0, vS)` | back |
| bottom edge (only `j = 0`) | (0, -1, 0) | `(x1, y0, +z, u0, v0)`, `(x0, y0, +z, u1, v0)`, `(x0, y0, -z, u1, vS)`, `(x1, y0, -z, u0, vS)` | back |
| edge at `x1` (only `i = w - 1`) | (-1, 0, 0) | `(x1, y1, +z, uS, v0)`, `(x1, y0, +z, uS, v1)`, `(x1, y0, -z, u0, v1)`, `(x1, y1, -z, u0, v0)` | back |
| edge at `x0` (only `i = 0`) | (1, 0, 0) | `(x0, y1, -z, uS, v0)`, `(x0, y0, -z, uS, v1)`, `(x0, y0, +z, u0, v1)`, `(x0, y1, +z, u0, v0)` | back |

(Here `uS` and `u0` in the side-edge rows are `back.getU(0.0625)` and `back.getU0`.) The slab is 0.0625 thick (z from -0.03125 to +0.03125), centred on the entity position, and is `w` by `h` blocks.

---

## 12. Lead knot (`LeashKnotModel`, `LeashKnotRenderer`)

Model (texture 32 x 32; layer `LEASH_KNOT`): one part `knot`: tex (0, 0), cuboid origin (-3, -8, -3) size 6 x 8 x 6, pose zero. Renderer: plain `EntityRenderState`; submit: push; scale `(-1, -1, 1)`; submit the model with texture `textures/entity/lead_knot/lead_knot.png` (render type `entityCutout`), `lightCoords`; pop. No shadow. (The leash rope between a holder and a leashed entity is drawn by the base renderer's `submitLeash` for every entity with leash states, framework part.)

---

## 13. Falling blocks and primed TNT

### 13.1 `FallingBlockRenderer`

Shadow radius 0.5. `shouldRender` = base test passes **and** the entity's block state is **not identical** to the state the level currently holds at the entity's block position (while the landed block is visible the entity is skipped). State holds a `MovingBlockRenderState` (`randomSeedPos` = the entity's start position, `blockPos` = `BlockPos.containing(x, boundingBox.maxY, z)`, `blockState`, and on a client level also the biome at `blockPos`, the cardinal lighting and the light engine). Submit: if the state's render shape is not `MODEL` return; push; translate `(-0.5, 0, -0.5)`; `submitMovingBlock(pose, state, outlineColor)` (draws the block model with the per-block lighting of 12 §1 evaluated at `blockPos`); pop.

### 13.2 `TntRenderer` (primed TNT) and the white flash

Shadow radius 0.5. State: `fuseRemainingInTicks = fuse - pt + 1.0`, `blockState` (the block state resolved with block display context; the default is TNT).

`swell(f) = clamp(1 - f / 10, 0, 1)`; `swell = swell * swell; swell = swell * swell; result = swell * 0.3` (the fourth power of the clamped value, times 0.3). `isLit(f) = f >= 0 and (int(f / 5)) is even` (the integer part, `% 2 == 0`).

Submit: push; translate `(0, 0.5, 0)`; if `f < 10`: `s = 1 + swell(f)`, scale `(s, s, s)`; rotate Y by -90 deg; translate `(-0.5, -0.5, 0.5)`; rotate Y by 90 deg; if the block model is non-empty: `submitWhiteSolidBlock(model, pose, collector, lightCoords, isLit(f), outlineColor)`; pop. `submitWhiteSolidBlock` submits the block model with overlay `pack(u(1.0) = 15, 10)` when lit (the white flash), else `NO_OVERLAY`.

Worked values: `f = 9`: `1 - 0.9 = 0.1`, `0.1^4 * 0.3 = 3.0e-5`, scale 1.00003; `f = 5`: `0.5^4 * 0.3 = 0.01875`, scale 1.01875, `int(5 / 5) = 1`, odd, not lit; `f = 4.9`: `int(0.98) = 0`, even, lit; `f = 0`: swell 0.3, scale 1.3, lit (int 0 even); `f = -1` (negative): not lit.

---

## 14. Experience orb (`ExperienceOrbRenderer`)

Shadow radius 0.15, strength 0.75. State: `icon = entity.getIcon()`. `getIcon()` from the orb's value `v`: v >= 2477: 10; >= 1237: 9; >= 617: 8; >= 307: 7; >= 149: 6; >= 73: 5; >= 37: 4; >= 17: 3; >= 7: 2; >= 3: 1; else 0. Block light for the orb = `clamp(blockLight + 7, 0, 15)`.

Submit: push; with `i = icon`: `u0 = ((i mod 4) * 16) / 64`, `u1 = ((i mod 4) * 16 + 16) / 64`, `v0 = ((i / 4) * 16) / 64`, `v1 = ((i / 4) * 16 + 16) / 64` (integer division by 4; the sheet is 64 x 64 holding 4 x 4 icons of 16 px, the texture `textures/entity/experience/experience_orb.png`, whose used icon count is not read; `getIcon` returns 0 to 10, so at most 11 icons are used (inferred); the texture contents are data for the tool in 22). `t = ageInTicks / 2`; `r = int((sin(t) + 1) * 0.5 * 255)`; `g = 255`; `b = int((sin(t + 4.1887903) + 1) * 0.1 * 255)` (4.1887903 is a read constant); alpha is 128 for every vertex. Translate `(0, 0.1, 0)`; rotate by the camera orientation; scale 0.3; draw one quad with render type `entityTranslucent(experience_orb.png)`; pop. Quad vertices `(x, y, u, v)` in order: `(-0.5, -0.25, u0, v1)`, `(0.5, -0.25, u1, v1)`, `(0.5, 0.75, u1, v0)`, `(-0.5, 0.75, u0, v0)`, each with colour `(r, g, b, 128)`, light `lightCoords`, overlay `NO_OVERLAY`, normal (0, 1, 0), z = 0.

Worked example: value 20 gives icon 3: `u0 = 0.75, u1 = 1.0, v0 = 0, v1 = 0.25`. At `ageInTicks = 0`: `t = 0`: `r = int(0.5 * 255) = 127`, `b = int((sin(4.1887903) + 1) * 0.1 * 255) = 3`. At `ageInTicks = 3.1415927` (`t = pi/2`): `r = 255`, `b = 12`.

---

## 15. Lightning bolt (`LightningBoltRenderer`)

State: `seed` (long) from the entity (`entity.seed`, set when the entity is created; cosmetic). Never culled by the box. Render type `lightning()` (§2.3). The pose origin is the entity position; no transform is applied.

All random numbers come from `RandomSource.createThreadLocalInstance(seed)`, a `SingleThreadedRandomSource`, the Java LCG of 10 §2.6; `nextInt(11)` is the bounded draw there. A **fresh** source with the same `seed` is created for the path table and again at the start of each of the four passes.

**Path table**: arrays `xs[8]`, `zs[8]`; `x = z = 0`; for `i` = 7 down to 0: `xs[i] = x; zs[i] = z; x += nextInt(11) - 5; z += nextInt(11) - 5` (the x draw first). The final `(x, z)` is `(endX, endZ)`.

**Geometry**: for pass `j` = 0 to 3, a fresh source with the same seed; for branch `k` = 0 to 2:

* `main = (k == 0)`; `startLayer = 7 - k`; `endLayer = main ? 0 : startLayer - 3 + 1` (the main trunk runs layers 7 down to 0; branch 1 runs 6 down to 4; branch 2 runs 5 down to 3);
* `px = xs[startLayer] - endX`, `pz = zs[startLayer] - endZ`;
* for `layer` = `startLayer` down to `endLayer` (inclusive): `prevX = px; prevZ = pz`; main trunk: `px += nextInt(11) - 5; pz += nextInt(11) - 5`; branches: `px += nextInt(31) - 15; pz += nextInt(31) - 15` (x draw first);
  `wTop = wBot = 0.1 + j * 0.2`; for the main trunk only: `wTop *= layer * 0.1 + 1`, `wBot *= (layer - 1) * 0.1 + 1`; then four quads with `quad(m, vc, px, pz, prevX, prevZ, layer, wTop, wBot, f1, f2, f3, f4)` for flag sets `(f1, f2, f3, f4)` = (false, false, true, false), (true, false, true, true), (true, true, false, true), (false, true, false, false).

The parameter order of `quad` is `(x_new, z_new, x_prev, z_prev, layer, w7, w8, ...)`: **w7 (= `wTop`) applies to the prev (upper) point, w8 (= `wBot`) to the new (lower) point**. A `quad` emits four vertices, each with colour `(0.45, 0.45, 0.5, 0.3)` (r, g, b, a floats), in this order, where `sgn(f, w) = f ? +w : -w`:

1. `(x_new + sgn(f1, wBot), layer * 16, z_new + sgn(f2, wBot))`
2. `(x_prev + sgn(f1, wTop), (layer + 1) * 16, z_prev + sgn(f2, wTop))`
3. `(x_prev + sgn(f3, wTop), (layer + 1) * 16, z_prev + sgn(f4, wTop))`
4. `(x_new + sgn(f3, wBot), layer * 16, z_new + sgn(f4, wBot))`

So every layer is a 16-block tall slab (the bolt is 128 blocks tall), drawn as four quads forming a four-sided tube whose sides are offset by `w`; because the four passes use the same seed, they trace the **same** path with widths `0.1, 0.3, 0.5, 0.7` (times the trunk taper), layered additively.

Worked example (seed 0, LCG of 10 §2.6, derived by applying that generator, not read from a run): the first eight `nextInt(11)` values are 0, 6, 8, 5, ... giving `xs = [-13, -10, -7, -4, -1, -2, -5, 0]`, `zs = [-9, -9, -6, -1, -2, 1, 1, 0]` and `(endX, endZ) = (-16, -13)`; the trunk's first point is `(0 + 16, 0 + 13) = (16, 13)` relative to the end.

---

## 16. Cushion (`CushionModel`, `CushionRenderer`)

Model (texture 64 x 64; layer `CUSHION`): part `cushion`: tex (0, 0), cuboid origin (-31, -4, -1) size 16 x 4 x 16 with deformation **-0.005** (each face moved in by 0.005 px), pose off (23, 4, -7). Renderer: extraction `direction = Direction.fromYRot(entity.getYRot())`; texture by the cushion's dye colour: `textures/entity/cushion/<colour>_cushion.png` for each of the 16 `DyeColor` names (`DyeColor.getName()`). Submit: push; rotate Y by `180 - direction.toYRot()` deg; rotate X by 180 deg; translate `(0, -0.25, 0)`; submit the model with the model's render type for that texture (`entityCutout`), `lightCoords`; pop. Cushion data and size: 44 part 9 §8.1.

---

## 17. Display entities (`DisplayRenderer`)

Data, defaults, interpolation and the entity side: 44 part 9 §6 (fields, `calculateInterpolationProgress`, `teleport_duration`). This section is the renderer.

### 17.1 Shared part (`DisplayRenderer`)

`DisplayEntityRenderState`: `renderState` (the entity's current interpolated `Display$RenderState`, null until set), `interpolationProgress` (float), `entityYRot`, `entityXRot` (the entity's interpolated yaw and pitch), `cameraXRot`, `cameraYRot` (the camera's pitch and yaw in degrees). Extraction sets these from `entity.renderState()`, `entity.calculateInterpolationProgress(pt)`, `entity.getYRot(pt)`, `entity.getXRot(pt)`, `camera.xRot()`, `camera.yRot()`.

* **Culling**: the box is `entity.getInterpolatedBoundingBox(pt)` (44 part 9 §6.1: width x height around the position, shifted by the position lerp); `affectedByCulling` = the entity's `affectedByCulling()` (false when width or height is 0: such a display is never culled).
* **Brightness override**: if `renderState.brightnessOverride()` is not -1 (the packed value), the block and sky light used for the entity are the override's `block(packed)` and `sky(packed)` (unpacked as in §2.5; `Brightness.pack` calls `LightCoordsUtil.pack(block, sky)` and `unpack` calls `LightCoordsUtil.block` and `sky`, read; both classes are in `net.minecraft.util`, not the client renderer package); otherwise the level's values.
* **Shadow**: radius and strength are `renderState.shadowRadius().get(progress)` and `shadowStrength().get(progress)` (the interpolators of 44 part 9); 0 when there is no render state.
* **Submit**: if there is no render state or no sub-state (the subclass has nothing to show), draw nothing. Else: base submit; push; rotate by the billboard orientation quaternion (below); apply the render state's transformation `transformation().get(progress)` as a matrix multiply (translation, left rotation, scale, right rotation, 44 part 9 §6.1); call `submitInner(state, pose, collector, lightCoords, progress)`; pop.

**Billboard orientation**: `q = rotationYXZ(yaw, pitch, 0)` (the composition order of JOML's `rotationYXZ` is library behaviour, not read from this artifact: (recalled, not verified) that it applies Z, then X, then Y to a vertex; the call itself was read in `DisplayRenderer`, Open question 21), with `yaw` and `pitch` radians chosen by the render state's billboard constraint, where `camY' = cameraYRot - 180` and `camX' = -cameraXRot`:

| Constraint (id, 44 part 9) | yaw | pitch |
|---|---|---|
| fixed (0) | `-D * entityYRot` | `D * entityXRot` |
| vertical (1) | `-D * (cameraYRot - 180)` | `D * entityXRot` |
| horizontal (2) | `-D * entityYRot` | `D * (-cameraXRot)` |
| center (3) | `-D * (cameraYRot - 180)` | `D * (-cameraXRot)` |

(The constraint names are the enum constants `FIXED`, `VERTICAL`, `HORIZONTAL`, `CENTER`: "vertical" turns about the vertical axis to face the camera, "horizontal" about the horizontal axis.)

### 17.2 Block display

Extraction: when `blockRenderState` exists, resolve its block state with block display context into `blockModel`; else clear it. `submitInner`: submit the block model with `lightCoords`, `NO_OVERLAY`. No extra offset: the block's origin (the corner) is at the entity position, before the billboard and the transformation.

### 17.3 Item display

Extraction: when `itemRenderState` exists, resolve `itemStack()` with the display context `itemTransform()` (the byte of 44 part 9 §6.3: none, thirdperson_lefthand, ..., gui, ground, fixed, on_shelf), else clear. `submitInner`: if the item is empty return; **rotate about Y by pi**; submit the item with `lightCoords`, `NO_OVERLAY`. The context selects the item model's `display` transform (12 §8.2), data of the item model.

### 17.4 Text display

State: `textRenderState` (the entity's text state: `flags` byte, `textOpacity` and `backgroundColor` interpolators, `lineWidth`), `cachedInfo` (the split lines and the maximum width, built once per render state through `entity.cacheDisplay`).

**Line splitting** (`splitLines(component, maxWidth)`): `Font.split(component, maxWidth)` gives wrapped lines; for each line, `w = font.width(line)`; the info holds the list of `(line, w)` and `max(w)`. (The wrap algorithm is the framework's text splitter, 12 §5.10, Open question 2.)

**`submitInner`**: let `flags` be the style byte (44 part 9 §6.3: shadow = bit 1, see-through = bit 2, default background = bit 4, align left = bit 8, align right = bit 16).

1. `mode = (flags & 2) ? SEE_THROUGH : POLYGON_OFFSET` (the font display mode; see-through text is drawn through blocks).
2. `shadow = (flags & 1) != 0`.
3. `opacity = (byte) textOpacity(progress)` (interpolated integer, narrowed to a byte).
4. `background`: if `(flags & 4)`: `int(optionsBackgroundOpacity(0.25) * 255) << 24` (black at the player's "background opacity" option, where the argument 0.25 is the default passed to the option reader; 13 for the option), else `backgroundColor(progress)` (ARGB interpolated by `srgbLerp`).
5. Pose matrix: rotate by pi about y; scale by `-0.025` on all three axes (so one font pixel is 0.025 block, mirrored in all axes, undoing the model flip).
6. `lh = fontHeight + 1 = 10` (font height 9 plus 1); `width = cachedInfo.width`; `height = lines * lh - 1`. Translate by `(1 - width / 2, -height, 0)` in that scaled space (the translate is issued after the rotate and scale, so it is in text pixels). Net effect on a text-space point `(x, y)`: the scale by -0.025 and the rotation by pi about Y (which negates x again) give world `x = +0.025 * x` and `y = -0.025 * y`; so text-space y from `-height` to 0 maps to world y from `+0.025 * height` down to 0, that is, the block lies above the entity origin with its bottom edge at the origin, and the first line is at the top.
7. If `background != 0`: `submitTextBackground(pose, -1, -1, width, height, background, mode, lightCoords)`.
8. For each line in order, with running `y` starting at 0 and increasing by `lh` per line: `x = 0` for left alignment; `width - lineWidth` for right; `width / 2 - lineWidth / 2` for centre (floats); `submitText(pose, x, y, line, shadow, mode, lightCoords, color = (opacity << 24) | 0xFFFFFF, 0, 0)`.

The alignment is read from the bits by `TextDisplay.getAlign` (left tested first, then right, else centre, 44 part 9 §6.3). The text component is already resolved by the server at load (44 part 9).

Worked example: two lines of pixel widths 40 and 60 with centre alignment, defaults: `width = 60`, `height = 2 * 10 - 1 = 19`; translate `(1 - 30, -19) = (-29, -19)`; the first line `x = 30 - 20 = 10`, `y = 0`; the second `x = 0`, `y = 10`. In world units after the 0.025 scale: the block spans world x from -0.725 to +0.775 (the two mirrors cancel) and world y from 0 to +0.475, above the entity origin (before the billboard rotation and the display transformation). (Derived arithmetic; the pose order, the -0.025 scale and the translate were read.)

---

## 18. Worn equipment (cross-reference only)

`ElytraModel` (texture 64 x 32, layer `ELYTRA`; the `ELYTRA_BABY` layer is the same definition passed through `ElytraModel.BABY_TRANSFORMER`): parts `left_wing` tex (22, 0) cuboid origin (-10, 0, 0) size 10 x 20 x 2, deformation 1.0, pose off (5, 0, 0), rot (0.2617994, 0, -0.2617994); `right_wing` tex (22, 0) mirrored, origin (0, 0, 0), size 10 x 20 x 2, deformation 1.0, pose off (-5, 0, 0), rot (0.2617994, 0, 0.2617994). `setupAnim(HumanoidRenderState)` (read): the left wing gets `y = 3.0` when the state's `isCrouching` is set and `y = 0` otherwise; it then always takes `xRot = elytraRotX`, `zRot = elytraRotZ`, `yRot = elytraRotY` from the state (there is no flying flag in this method; the state fields are filled by the caller). The right wing is always the mirror: `yRot = -left.yRot`, `y = left.y`, `xRot = left.xRot`, `zRot = -left.zRot`. `ELYTRA_BABY` uses `BABY_TRANSFORMER`, whose whole static initialiser was read: it is exactly `MeshTransformer.scaling(0.5)` (no other transform). How a mesh scaling transformer rewrites cuboids and poses was not read ((recalled, not verified): it scales the whole mesh about the origin; 34 part 1 owns the mesh transformers); the elytra layer's shadow is not tabulated (Open question 9). `ShieldModel` (texture 64 x 64, layer `SHIELD`): `plate` tex (0, 0) origin (-6, -11, -2) size 12 x 22 x 1; `handle` tex (26, 0) origin (-1, -3, -1) size 2 x 6 x 6. Where and how they are drawn belongs to the equipment layer part (34 part 1 and the player document 12 §7.6).

---

## 19. Validation

Checkable facts:

1. The registry has 161 entity types, 159 provider registrations and 2 avatar renderers (`PLAYER`, `MANNEQUIN`); `NoopRenderer` is the provider of exactly `area_effect_cloud`, `interaction`, `marker`.
2. `ThrownItemRenderer` scales: `small_fireball` 0.75, `fireball` 3.0, everything else 1.0; only `eye_of_ender`, `fireball`, `small_fireball` use block light 15.
3. Minecart offsets: entity id 1: `s = 493286711`, `offsetSeed = -4132653469018943280`; the three 3-bit fields (shifts 16, 20, 24) are 7, 5, 7 and the offsets `(0.00175, 0.00075, 0.00175)`. Id 2: seed `1916032762656048354`, offsets `(0.00175, -0.00125, 0.00025)`. Id 100: seed `-6310268219801383060`, offsets `(0.00075, 0.00025, -0.00125)`. (Computed from the read formula with 64-bit wrapping arithmetic.)
4. Item cluster: a stack of 40 renders 4 copies; a stack of 1 renders 1; a stack of 64 renders 5.
5. TNT swell: `f = 5` gives scale 1.01875; `f = 0` gives 1.3; `isLit(4.9)` true, `isLit(5.0)` false, `isLit(10.0)` true, `isLit(-0.5)` false.
6. Experience orb: value 1237 gives icon 9, uv `u0 = 0.25, v0 = 0.5`; value 2 gives icon 1.
7. Fishing line: with offset `(dx, dy, dz) = (4, 0, 0)` the vertex at `t = 0.5` is `P(0.5) = (2, 0 * 0.75 * 0.5 + 0.25, 0) = (2, 0.25, 0)`; with `(4, -2, 0)`: `P(1) = (4, -2 * 2 * 0.5 + 0.25, 0) = (4, -1.75, 0)`.
8. Item frame on UP: `xRot = -90`, `yRot = 180`; on DOWN: `xRot = +90`.
9. Painting 2 x 1 (w = 2, h = 1): cell (0, 0) has `x0 = -1, x1 = 0`, `y0 = -0.5, y1 = 0.5`, `uA = getU(1)`, `uB = getU(0.5)`, `vA = getV(1)`, `vB = getV(0)`; cell (1, 0) has `x0 = 0, x1 = 1`, `uA = getU(0.5)`, `uB = getU(0)`. Both cells have the top and bottom edge strips (h = 1); only cell (0, 0) has the `x0` edge and only cell (1, 0) the `x1` edge.
10. Lightning with seed 0 reproduces the worked example of §15. The generator vectors for that seed, computed here from the read LCG (setSeed scramble, `next(31)`, rejection loop): first five `nextInt(100)` are 60, 48, 29, 47, 15; first eight `nextInt(11)` are 0, 6, 8, 5, 6, 2, 2, 6.
11. Display orientation: `fixed` with `entityYRot = 90`, `entityXRot = 0`: `yaw = -D * 90 = -1.5707964`, `pitch = 0`.


---

## 20. Open questions

1. **Face orientation of boxes.** 14 Open question 4 (which edge of each face is "up" in the unwrap) is not closed here; the arrow cross planes and the arrow back plane are depth-0 boxes whose degenerate faces were not traced individually (§2.2).
2. **Text display line wrapping.** `Font.split(component, width)` and `font.width` are the framework's text engine (12 §5.10); the wrap rule and the width of each glyph were not read in this round (44 part 9 Open question 1 asked for it and the answer is the font engine's, not display-specific).
3. **`submitTextBackground` rectangle.** The call receives `(-1, -1, width, height)`; whether the rectangle covers `[-1, width - 1]` by `[-1, height - 1]` (so that after the translate it is centred) or a different extent was not read (the vertex code of the text collector was not traced).
4. **Item model bounding box.** `getModelBoundingBox` is the union of the model layers' extents (`visitExtents`); the per-model extents come from the item model JSON and the model baking (12 §8, 08 §5.3); thick versus flat (`zSize > 0.0625`) therefore depends on pack data.
5. **Overlay application and `NO_OVERLAY` in shaders.** The shader's mix of the overlay texel is not read; "blend towards white" is inferred from the texel contents (§2.5).
6. **Lightning shader and flash.** The `lightning` pipeline's fragment output, the order-independent-transparency variant (`OIT_ADDITIVE`) and the level's sky flash (`skyFlashTime`) were not traced here; the additive blend factors were read (§2.3).
7. (Closed.) The minecart culling-box condition was read: the display state is not air (§3.2). Number kept so later references stay valid.
8. **Map rendering in item frames.** `MapRenderer.render` (map pixel colours, decorations) was not read.
9. **Elytra baby transformer.** (Mostly closed.) `BABY_TRANSFORMER` is `MeshTransformer.scaling(0.5)` and nothing else (read, §18); the effect of that transformer on cuboids and poses and the elytra layer's shadow were not read.
10. (Closed.) `Direction` 2D data values read: DOWN -1, UP -1, NORTH 2, SOUTH 0, WEST 1, EAST 3; `toYRot = (data2D & 3) * 90` read (§10, §11, §16). Number kept so later references stay valid.
11. (Closed.) `Brightness.pack` calls `LightCoordsUtil.pack(block, sky)` and `unpack` uses `LightCoordsUtil.block` and `sky` (read), so the override is packed like the light coordinates of §2.5. Number kept so later references stay valid.
12. (Closed.) `getPointOnPlane(x, y)` = `forward + up * y - left * x` (read, §8). Number kept so later references stay valid.
13. **Default render type per model.** `entityCutout` (non-culled) is the one-argument `EntityModel` default and `ArrowModel` uses `entityCutoutCull`, `TridentModel` `entitySolid` (from the constructor method handles); the exact pipeline flags of those render types are the framework's (12 §2.4 for the entity sampler).
14. **Registry id of items for the cluster seed.** The seed uses `Item.getId` (raw registry id); the id table is in 25 and depends on the registry order of the data pack.
15. **Hurt shake source fields.** `getHurtTime`, `getHurtDir`, `getDamage` of the vehicle entities (set by the damage path) are not specified here.
16. **Recall.** Marked "(recalled, not verified)": the JOML rotation composition order (§2.1, §17.1, question 21), the engine default eye height (§1.3, question 17), the effect of the scaling mesh transformer (§18). Everything else was read from the bytecode of this artifact in this round. The "(inferred)" items are: question 5 and its sentence in §2.5 ("blend towards white"); the trident spike orientation in §5.2; the icon count of at most 11 in §14; the "room side of the wall plane" remark in the §10 worked example; the 1e-4 sine error bound (§2); the frame and painting placeholder boxes (§1.3). The worked-example numbers derived by arithmetic are labelled as such.
17. **Default eye height.** Types without an `eyeHeight` call (§1.3 table) use the engine default, which was not read in this round (the `EntityDimensions` default eye-height rule).
18. **Minecart attachment default.** The constant lowered point for villagers and wandering traders and the one `passengerAttachments` point (y 0.1875) were read (§1.3); the `Entity` default that converts an attachment into a rider position, and the update path of `rotationOffset` and `playerRotationOffset`, were not.
19. **Leashable by inheritance.** Class headers of the 74 entity classes of the listed packages and of `Entity` do not name `Leashable` (§1.3); a super-interface or a super-class outside the checked packages that carries it was not searched for.
20. **Cross-document defect, 10 §2.6.** `10-world-generation-terrain.md` §2.7 table row "First five `nextInt(100)` of seed 0" lists 96, 18, 15, 31, 88; the LCG read in this round gives 60, 48, 29, 47, 15 (§19 item 10). That file is outside this document's edit scope and must be corrected by its owner; no source was found that gives the old values.
21. **JOML semantics.** The calls `rotationYXZ` (§17.1) and `rotationZYX` (§2.1, `translateAndRotate`) were read in the bytecode; the order in which JOML applies the three axis rotations to a vertex is library behaviour of a jar outside this artifact's game classes, and is (recalled, not verified). Every rotation of this document that depends on it is flagged.
22. **README entry.** `README.md` has no row for any part of document 34 (a search for `34-entity` found nothing); reviewers and fixers do not edit it, so the orchestrator must add the Documents row and scope sentence for part 9 and the other parts.
