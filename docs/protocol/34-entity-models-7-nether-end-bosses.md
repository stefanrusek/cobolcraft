# 34 part 7. Entity models and renderers: Nether and End mobs and bosses

| | |
|---|---|
| Covers | The models, layer definitions, render states, animation formulas and renderers of blaze, ghast, strider (adult, baby, saddle, cold shaking), hoglin and zoglin (adult and baby), the Wither (model, spawn-phase size and texture, power-swirl armor layer), the wither skull projectile, the end crystal (model, bobbing, beam), the Ender Dragon (model, neck and tail history, wings, jaw, death dissolve and rays, crystal beam) and the dragon fireball |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `BlazeModel`, `BlazeRenderer`, `GhastModel`, `GhastRenderer`, `GhastRenderState`, `StriderModel`, `AdultStriderModel`, `BabyStriderModel`, `StriderRenderer`, `StriderRenderState`, `HoglinModel`, `BabyHoglinModel`, `AbstractHoglinRenderer`, `HoglinRenderer`, `ZoglinRenderer`, `HoglinRenderState`, `WitherBossModel`, `WitherBossRenderer`, `WitherArmorLayer`, `EnergySwirlLayer`, `WitherRenderState`, `WitherSkullRenderer`, `WitherSkullRenderState`, `SkullModel`, `SkullModelBase`, `EnderDragonModel`, `EnderDragonRenderer`, `EnderDragonRenderState`, `DragonFlightHistory` (and `$Sample`), `EndCrystalModel`, `EndCrystalRenderer`, `EndCrystalRenderState`, `DragonFireballRenderer`, `SimpleEquipmentLayer`, `LayerDefinitions` (the entries of these models), `MeshTransformer`, `MeshDefinition`, `PartDefinition`, `PartPose`, `CubeListBuilder`, `CubeDefinition`, `CubeDeformation`, `ModelPart` (`Cube`, `Polygon`, `translateAndRotate`, `rotateBy`), `Model`, `EntityModel`, `LivingEntityRenderer`, `EntityRenderer`, `ModelFeatureRenderer`, `OverlayTexture`, `RenderTypes`, `RenderPipelines` and `BlendFunction` (the entries these renderers use), `Mth` (`sin`, `cos`, `wrapDegrees`, `rotLerp`, `lerp`), `SingleThreadedRandomSource`, `BitRandomSource`, `LightCoordsUtil`, and the shader `assets/minecraft/shaders/core/entity.fsh` (data, read for the dissolve branch). The `EnderDragon` and `Strider` entity classes were read only for the few values the renderers consume (sections 4.1 and 8.8) |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001; design README Parts 0, 1, 4; GAP-25). Textures, equipment asset JSON and item models are data that the extraction tool (22) copies into a resource pack; this document gives only the paths and image sizes the renderers ask for. Geometry, animation, render-state extraction and the renderers are code and are given completely. Entity behaviour, sizes, ids and metadata are not repeated: see 21 §5.1 (ghast), §5.2 (blaze), §5.6 (hoglin, zoglin), §5.7 (strider), §6.3 (end crystal), §6.4 (dragon), §7.2 (Wither) and 21 App A for metadata layouts. Pose-stack order for living entities is summarised in section 1.6 because every renderer here depends on it; it agrees with 34-1 section 6.5 (the shared framework: Y rotation by 180 minus body yaw, the (-1, -1, 1) flip and the -1.501 translate), and 12 §7.3 gives the same stack for the player |

Conventions. Model units are pixels (1/16 block), x to the model's left, y down, z to the front, angles in radians unless a
row says degrees. A box is written `origin (x, y, z), size (w, h, d), tex (u, v)`; "grow g" expands every face by g pixels
without changing the UV rectangle; "mirror" flips the box left to right (1.2). A part pose is
`pivot (x, y, z); rotation (x, y, z)`; scale is 1 unless stated. "Initial pose" is the pose a part is created with;
`Model.setupAnim` first resets every part to its initial pose (1.1), so every statement of the form "x = ..." below
overwrites the initial value and a part that is not mentioned keeps it. `DEG` is the single-precision constant
0.017453292 (degrees to radians). All floats were read as single-precision values. "State" is the render state the
renderer fills every frame; `ageInTicks` = entity `tickCount` + partial tick (`EntityRenderer.extractRenderState`).
Every `sin` and `cos` of the model code is `Mth.sin` / `Mth.cos`, a table lookup (1.4), not a library call.

---

## 1. Shared pieces read in this round

### 1.1 Part pose application and the animation cycle

- A part is drawn by: translate by (x, y, z) / 16; if any rotation angle is non-zero, rotate by the quaternion
  `rotationZYX(zRot, yRot, xRot)` (applied to vertices as: X first, then Y, then Z); if any scale is not 1, scale by
  (xScale, yScale, zScale); then draw the part's own boxes and then every child inside that transform. A part with no boxes
  and no children draws nothing. `visible = false` hides the part and its children.
- `ModelFeatureRenderer` calls `model.setupAnim(state)` at the moment a submitted model is drawn (not when it is
  submitted), then renders the root part. `Model.setupAnim` calls `resetPose`, which restores every part's initial pose
  (position, rotation, scale). Each submitted model object (the main model, the Wither armor model) is set up
  separately with the same state.
- `ModelPart.rotateBy(q)` (used by the end crystal): build the matrix of the part's current ZYX rotation, post-multiply by
  q (so q acts on vertices first), convert the result back to ZYX angles and store them. For a part whose current rotation is
  zero this is the rotation q itself.
- `PartPose.withScale(s)` replaces the three scale factors with s (position and rotation unchanged). `scaled(s)`
  multiplies position and the three scales by s. `translated(dx, dy, dz)` adds to the position only.

### 1.2 Boxes (`ModelPart$Cube`, `ModelPart$Polygon`)

A box `origin (x, y, z), size (w, h, d), grow (gx, gy, gz), tex (u, v), mirror` in a layer of texture size (W, H) has
six faces. Its corner coordinates are x0 = x - gx, x1 = x + w + gx, y0 = y - gy, y1 = y + h + gy, z0 = z - gz,
z1 = z + d + gz; when `mirror` is set x0 and x1 are exchanged. Face rectangles in texels (a face with a zero dimension
still produces its polygon):

| Face (direction name in the artifact) | Vertices | UV rectangle (u from .. to, v from .. to) |
|---|---|---|
| DOWN (the y0 side) | the four corners with y = y0 | u + d .. u + d + w, v .. v + d |
| UP (the y1 side) | the four corners with y = y1 | u + d + w .. u + d + 2w, v .. v + d |
| WEST (the x0 side) | the four corners with x = x0 | u .. u + d, v + d .. v + d + h |
| NORTH (the z0 side) | the four corners with z = z0 | u + d .. u + d + w, v + d .. v + d + h |
| EAST (the x1 side) | the four corners with x = x1 | u + d + w .. u + 2d + w, v + d .. v + d + h |
| SOUTH (the z1 side) | the four corners with z = z1 | u + 2d + w .. u + 2d + 2w, v + d .. v + d + h |

Vertex positions per face: label the eight corners (after the mirror swap) A = (x0, y0, z0), B = (x1, y0, z0), C = (x1, y1, z0),
D = (x0, y1, z0), E = (x0, y0, z1), F = (x1, y0, z1), G = (x1, y1, z1), H = (x0, y1, z1). The artifact stores the four vertices of each
face in this order (slot 0 to 3): DOWN F, E, A, B; UP C, D, H, G; WEST A, E, H, D; NORTH B, A, D, C; EAST F, B, C, G; SOUTH E, F, G, H.

Vertex UVs of a polygon: with (uMin, vMin, uMax, vMax) the rectangle divided by (W, H), the four vertices (in the order the
artifact stores them, which differs per face) receive, by vertex slot: slot 0 (uMax, vMin), slot 1 (uMin, vMin), slot 2
(uMin, vMax), slot 3 (uMax, vMax). The epsilon that vanilla could add to UVs is 0. When `mirror` is set the order of the four
vertices is reversed and the face normal is mirrored (the normal of an EAST or WEST face becomes the opposite
direction; other normals are unchanged). The normals are the unit vectors of the direction names (DOWN is (0, -1, 0),
UP (0, 1, 0), NORTH (0, 0, -1), SOUTH (0, 0, 1), WEST (-1, 0, 0), EAST (1, 0, 0) in model space). The model is drawn flipped by (-1, -1, 1)
(1.6), which turns the model-space DOWN face (smallest y) into the visible top face. This agrees with 14 §5.3 and
12 §7.4.

Note: `ModelPart$Cube` takes a set of visible faces and builds polygons only for the faces in that set (the polygon count is the set size). `CubeListBuilder` defaults to all six faces and also offers an `addBox` overload taking a face set. No model in this document uses that overload, so "six faces" holds for every box here but is not universal for the framework.

Builder rules used below: the `CubeListBuilder` keeps a current `texOffs` and a sticky `mirror` flag; `mirror()` sets the
flag to true (it does not toggle); a box added with the form `addBox(x, y, z, w, h, d, true)` is mirrored regardless of the
flag; `addBox(name, x, y, z, w, h, d, u, v)` sets `texOffs(u, v)` first and then adds the box with the current flag
(for the dragon's head this means every box after the first `mirror()` call is mirrored, because the second
`mirror()` call in the artifact is again `mirror()`, not `mirror(false)`).

### 1.3 Layer definitions and the scaling transformer

A layer definition is a mesh plus a texture size (W, H); UVs are divided by W and H, so a texture image of twice the size
(the jar ships end crystal and ghast images at 128 x 64 for a 64 x 32 layer) is sampled by the same fractions.
`MeshTransformer.scaling(s)` replaces the pose of the **root part only** (children are copied unchanged) by
`ZERO.scaled(s).translated(0, 24.016 x (1 - s), 0)`: the root gets position (0, 24.016(1 - s), 0) and scale s, so every
model point (x, y, z) becomes (s x, T + s y, s z) with T = 24.016(1 - s). This was read through `MeshTransformer.scaling`, `MeshDefinition.transformed` and `PartDefinition.transformed`: the transform is applied to the root pose and the children are copied by `putAll` unchanged, so a child keeps its own pivots (including absolute pivots set in `setupAnim`) and inherits the root scale. The sentence in 34-2 section 1.3 (the Scaling bullet) that every direct child of the root gets its pose replaced by `pose.scaled(s)` disagrees with the artifact; that sentence was still present in 34-2 when this document was last checked (2026-11-08), and this document keeps the disagreement visible until 34-2 is corrected by its owner.
`CubeDeformation(g)` is the "grow" of 1.2. `INNER_ARMOR_DEFORMATION` is 0.5.

### 1.4 Sine and cosine tables (`Mth`)

`Mth.sin(x)` = SIN[ floor-toward-zero(x x 10430.378350470453) AND 65535 ] and `Mth.cos(x)` = SIN[ floor-toward-zero(x x
10430.378350470453 + 16384.0) AND 65535 ], where the argument is a double, the product is converted to a 64-bit
integer by truncation toward zero (so negative products truncate toward zero before the AND), and SIN[i] = float(sin(i / 10430.378350470453)) for i
in 0 to 65535 (10430.378350470453 = 65536 / 2 pi). Results differ from a true sine by up to about 1e-4 (inferred: the table step is 2 pi / 65536, about 1e-4 rad, so the error is at most about 5e-5); tests that compare
poses should use a 1e-3 tolerance (inferred margin). `Mth.wrapDegrees(x)` (float): r = x remainder 360 (sign of x); if r >= 180 then r = r - 360;
if r < -180 then r = r + 360. `Mth.rotLerp(t, a, b)` = a + t x wrapDegrees(b - a). `Mth.lerp(t, a, b)` = a + t (b - a).

### 1.5 Random numbers used by model construction and the death rays

`RandomSource.createThreadLocalInstance(seed)` is a `SingleThreadedRandomSource`: a 48-bit linear congruential generator.
`setSeed(s)`: state = (s XOR 25214903917) AND (2^48 - 1). `next(bits)`: state = (state x 25214903917 + 11) AND (2^48 - 1);
result = the top `bits` bits of the 48-bit state as a 32-bit signed integer (`state >> (48 - bits)`).
`nextFloat()` = next(24) x 5.9604645E-8. `nextInt(bound)` (bound > 0): if bound is a power of two the result is
(bound x next(31)) >> 31 (64-bit product); otherwise repeat { r = next(31); m = r mod bound } until r - m + (bound - 1) does not overflow
to a negative 32-bit value, and return m.

### 1.6 The living-entity render sequence (`LivingEntityRenderer.submit`) and what the renderers here add

Pose stack, in order (each step multiplies on the right; the last listed acts first on vertices):

1. translate to the entity position (done by the dispatcher);
2. scale by `state.scale` (the entity's scale attribute) uniformly;
3. `setupRotations`: when the entity is "shaking" add `cos(floor(ageInTicks) x 3.25) x pi x 0.4` degrees to the body yaw
   (double-precision `cos` of the integer product, then narrowed to float; the 0.4 is the double 0.4000000059604645, the float 0.4 widened, multiplied by pi in double precision, as in 34-1 section 6.5; the worked values below are unaffected within 1e-3); when not sleeping rotate about Y by
   180 - bodyYaw degrees; when `deathTime > 0` rotate about Z by `min(1, sqrt((deathTime - 1) / 20 x 1.6)) x 90`
   degrees (90 is `getFlipDegrees`, not overridden by any renderer here); (spin-attack, sleeping and "upside down" name
   cases are the player's and are not used by these mobs);
4. scale by (-1, -1, 1);
5. the renderer's own `scale(state)` hook (only the Wither overrides it, 6.2);
6. translate by (0, -1.501, 0) (`EntityModel.MODEL_Y_OFFSET`).

Then the model is submitted with: render type = `entityTranslucentCull(texture)` when the body is translucent (invisible
but visible to the local player; tint 0x26FFFFFF instead of white), else `model.renderType(texture)` (default for
`EntityModel`: `entityCutout`, alpha cut 0.1) when the body is visible, else the outline type when glowing, else nothing;
light = `state.lightCoords`; overlay = `OverlayTexture.pack(u, v)` with u = floor(whiteOverlayProgress x 15) (0 for every
renderer here) and v = 3 (red) when `hasRedOverlay` (hurtTime > 0 or deathTime > 0) else 10; then every layer's `submit`
is called in registration order. `getShadowRadius` = constructor radius x `state.scale`.
Light: `lightCoords = (blockLight << 4) | (skyLight << 20)` read at the entity's light probe position; blaze, Wither,
wither skull, and dragon fireball override the block-light level to 15 (blaze, Wither, wither skull, fireball: 2.1, 6.2, 6.3, 9).

`OverlayTexture`: a 16 x 16 texture. Rows 0 to 7, every column: ARGB 0xB2FF0000 (red, alpha 178; the int is -1291911168). Rows 8 to 15, column c: `ARGB.white(alpha)` (alpha in the top byte) with alpha int((1 - c / 15 x 0.75) x 255). The entity shader mixes `rgb = mix(overlay.rgb, color.rgb, overlay.a)`, so the red
row keeps 178/255 = 0.698 of the texel colour and adds 0.302 red (`NativeImage.setPixel(x, y, argb)` converts with `ARGB.toABGR`, swapping the red and blue bytes, before `setPixelABGR`, so 0xB2FF0000 is alpha 0xB2, red 0xFF, green 0, blue 0: a red flash).

The common state fields the models below read: `ageInTicks`; `yRot` (head yaw relative to the body in degrees, wrapped
to -180..180) and `xRot` (head pitch in degrees); `walkAnimationPos`, `walkAnimationSpeed` (from the entity's walk animation
at the partial tick, both 0 when the entity is a passenger or not alive); `bodyRot`; `isBaby`; `deathTime`;
`hasRedOverlay` (hurtTime > 0 OR deathTime > 0, read in `LivingEntityRenderer.extractRenderState`); `scale`.

---

## 2. Blaze (`BlazeModel`, `BlazeRenderer`)

Layer `ModelLayers.BLAZE`, texture size 64 x 32, no transformer. Render state: plain `LivingEntityRenderState`.
Renderer: model `BLAZE`, shadow radius 0.5, block-light level 15, texture `textures/entity/blaze/blaze.png` (64 x 32 in the jar).
No layers.

### 2.1 Parts

| Part | Pivot | Box | tex |
|---|---|---|---|
| `head` | (0, 0, 0) | (-4, -4, -4), 8 x 8 x 8 | (0, 0) |
| `part0` .. `part11` ("part" + index) | see below | (0, 0, 0), 2 x 8 x 2 (one shared box) | (0, 16) |

Pivots of the twelve rods at creation (and the formulas the animation re-evaluates). Let q = pi/2 = 1.5707964.

| Ring | Rods | Start angle a0 | Radius R | x | y | z |
|---|---|---|---|---|---|---|
| 1 | 0..3 | 0 | 9 | cos(a) R | -2 + cos(2 i x 0.25) | sin(a) R |
| 2 | 4..7 | 0.7853982 (pi/4) | 7 | cos(a) R | 2 + cos(2 i x 0.25) | sin(a) R |
| 3 | 8..11 | 0.47123894 | 5 | cos(a) R | 11 + cos(1.5 i x 0.5) | sin(a) R |

with a = a0 + k q where k = 0, 1, 2, 3 is the rod's index within its ring, and i the rod's overall index.

### 2.2 `setupAnim`

With t = `ageInTicks`: for each ring the angle starts at a different base and advances q per rod:

| Ring | Base angle | x | y | z |
|---|---|---|---|---|
| 1 (i = 0..3) | t x pi x (-0.1) | cos(a) x 9 | -2 + cos((2 i + t) x 0.25) | sin(a) x 9 |
| 2 (i = 4..7) | 0.7853982 + t x pi x 0.03 | cos(a) x 7 | 2 + cos((2 i + t) x 0.25) | sin(a) x 7 |
| 3 (i = 8..11) | 0.47123894 + t x pi x (-0.05) | cos(a) x 5 | 11 + cos((1.5 i + t) x 0.5) | sin(a) x 5 |

(a = base + k q within the ring, k as in 2.1.) The head: `yRot = state.yRot x DEG`, `xRot = state.xRot x DEG`. Nothing else moves.

---

## 3. Ghast (`GhastModel`, `GhastRenderer`, `GhastRenderState`)

Layer `ModelLayers.GHAST`: `createBodyLayer()`, texture size 64 x 32, then the **scaling transformer with s = 4.5** (1.3;
T = 24.016 x (1 - 4.5) = -84.056). Render state `GhastRenderState` = `LivingEntityRenderState` + `isCharging` (boolean,
`Ghast.isCharging()`). Renderer: shadow radius 1.5, no layers, no scale hook.

Textures: `textures/entity/ghast/ghast.png`, and `textures/entity/ghast/ghast_shooting.png` when `isCharging`
(both 128 x 64 in the jar). The "charging texture" is selected only by this flag.

### 3.1 Parts

| Part | Pivot | Box | tex |
|---|---|---|---|
| `body` | (0, 17.6, 0) | (-8, -8, -8), 16 x 16 x 16 | (0, 0) |
| `tentacle0` .. `tentacle8` ("tentacle" + index) | (x_i, 24.6, z_i) | (-1, 0, -1), 2 x len_i x 2 | (0, 0) |

For tentacle i (0 to 8): x_i = ((i mod 3) - ((i div 3) mod 2) x 0.5 + 0.25 - 1) x 5 (the artifact computes it as
((... + 0.25) / 2 x 2 - 1) x 5), z_i = ((i div 3) - 1) x 5, and len_i = nextInt(7) + 8 (a float box height, 8 to 14), drawn from
`RandomSource.createThreadLocalInstance(1660)` (1.5), one call per tentacle in index order 0 to 8, calls made in the
loop between computing the position and adding the box. The result (computed from the generator of 1.5; the numbers
are fixed for every client):

| i | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|
| x_i | -3.75 | 1.25 | 6.25 | -6.25 | -1.25 | 3.75 | -3.75 | 1.25 | 6.25 |
| z_i | -5 | -5 | -5 | 0 | 0 | 0 | 5 | 5 | 5 |
| len_i | 8 | 13 | 9 | 11 | 11 | 10 | 12 | 9 | 12 |

After the root scaling every pose is multiplied by 4.5 and the whole model is moved by T: the body centre sits at
model y = T + 4.5 x 17.6 = -4.856, i.e. 1.501 + 4.856/16 = 1.8045 blocks above the entity origin in world space, and its
box is 72 px = 4.5 blocks wide.

### 3.2 `setupAnim` (`animateTentacles`, also used by the happy ghast)

For tentacle i: `xRot = 0.2 x sin(ageInTicks x 0.3 + i) + 0.4`. Nothing else is animated (the body does not turn:
the entity's body yaw rotates the whole model through 1.6).

---

## 4. Strider (`StriderModel`, `AdultStriderModel`, `BabyStriderModel`, `StriderRenderer`)

### 4.1 Renderer and state

`StriderRenderer` extends the ageable renderer: adult model from `ModelLayers.STRIDER`, baby model from `STRIDER_BABY`
(`AgeableMobRenderer.submit` picks the baby model when `state.isBaby`), shadow radius 0.5 (multiplied by a further 0.5
for a baby, in addition to `state.scale`). State `StriderRenderState` = living state + `saddle` (copy of the item in the
SADDLE slot), `isSuffocating` (`Strider.isSuffocating()`), `isRidden` (`Strider.isVehicle()`).

Texture by (`isSuffocating`, `isBaby`): (no, no) `textures/entity/strider/strider.png` (64 x 128 in the jar); (no, yes)
`strider_baby.png` (32 x 32); (yes, no) `strider_cold.png` (64 x 128); (yes, yes) `strider_cold_baby.png` (32 x 32).
**Cold shaking**: `isShaking(state)` is true when the base rule (`isFullyFrozen`) holds or `isSuffocating` is true; in that
case `setupRotations` adds the body-yaw wobble of 1.6 step 3 (so a cold strider shivers about the vertical axis).

**Saddle layer**: one `SimpleEquipmentLayer` with layer type `STRIDER_SADDLE`, item = `state.saddle`, adult model =
`AdultStriderModel` baked from `ModelLayers.STRIDER_SADDLE`, baby model = null, order 0. `LayerDefinitions` registers
`STRIDER_SADDLE` with the **same layer definition as `STRIDER`** (`AdultStriderModel.createBodyLayer()`, no grow).
The layer draws nothing when the item has no `EQUIPPABLE` component, when that component has no asset id, or when the
strider is a baby (no baby model). Otherwise it draws the adult mesh again with the equipment texture of the asset id
for layer type `strider_saddle`: the data file `assets/minecraft/equipment/saddle.json` maps the layer key
`strider_saddle` to texture `minecraft:saddle`, which is the image `textures/entity/equipment/strider_saddle/saddle.png`
(64 x 128; the file `assets/minecraft/textures/entity/equipment/strider_saddle/saddle.png` is present in the jar). Dye, glint and cutout handling of
`EquipmentLayerRenderer` are in the shared equipment framework, not read here (Open question 1).

### 4.2 Shared animation (`StriderModel.setupAnim`)

Let p = `walkAnimationPos`, s = min(`walkAnimationSpeed`, 0.25), t = `ageInTicks`. The model has three direct parts
`body`, `right_leg`, `left_leg`.

1. If `isRidden` is false: body.xRot = state.xRot x DEG and body.yRot = state.yRot x DEG; else body.xRot = body.yRot = 0.
2. body.zRot = 0.1 x sin(1.5 p) x 4 x s.
3. left_leg.xRot = sin(1.5 p x 0.5) x 2 x s; right_leg.xRot = sin(1.5 p x 0.5 + pi) x 2 x s.
4. left_leg.zRot = 0.17453292 x cos(1.5 p x 0.5) x s; right_leg.zRot = 0.17453292 x cos(1.5 p x 0.5 + pi) x s.
5. The subclass `customAnimations(p, s, t)` (4.3, 4.4).

`animateBristle(t, base, top, middle, bottom, apply)` where `apply(part, v)` adds v to one rotation component of the part
(zRot for the adult, xRot for the baby): top += 0.6 x base; middle += 1.2 x base; bottom += 1.3 x base; then top += 0.1 x sin(0.4 t);
middle += 0.1 x sin(0.2 t); bottom += 0.05 x sin(-0.4 t). `base` is cos(1.5 p + pi) x s.

### 4.3 Adult (`AdultStriderModel`, layer 64 x 128)

| Part | Parent | Pivot | Rotation | Box | tex | Mirror |
|---|---|---|---|---|---|---|
| `right_leg` | root | (-4, 8, 0) | 0 | (-2, 0, -2), 4 x 16 x 4 | (0, 32) | no |
| `left_leg` | root | (4, 8, 0) | 0 | (-2, 0, -2), 4 x 16 x 4 | (0, 55) | no |
| `body` | root | (0, 1, 0) | 0 | (-8, -6, -8), 16 x 14 x 16 | (0, 0) | no |
| `right_bottom_bristle` | body | (-8, 4, -8) | z -1.2217305 | (-12, 0, 0), 12 x 0 x 16 | (16, 65) | yes |
| `right_middle_bristle` | body | (-8, -1, -8) | z -1.134464 | (-12, 0, 0), 12 x 0 x 16 | (16, 49) | yes |
| `right_top_bristle` | body | (-8, -5, -8) | z -0.87266463 | (-12, 0, 0), 12 x 0 x 16 | (16, 33) | yes |
| `left_top_bristle` | body | (8, -6, -8) | z 0.87266463 | (0, 0, 0), 12 x 0 x 16 | (16, 33) | no |
| `left_middle_bristle` | body | (8, -2, -8) | z 1.134464 | (0, 0, 0), 12 x 0 x 16 | (16, 49) | no |
| `left_bottom_bristle` | body | (8, 3, -8) | z 1.2217305 | (0, 0, 0), 12 x 0 x 16 | (16, 65) | no |

`customAnimations(p, s, t)` (after 4.2): (1) the six bristle zRot values are set to their initial rotations listed above
(top -0.87266463, middle -1.134464, bottom -1.2217305 on the right; the opposite signs on the left); (2) with
base = cos(1.5 p + pi) x s, `animateBristle(t, base, ...)` is applied to the right (top, middle, bottom) and to the left
(top, middle, bottom) groups, adding to zRot; (3) body.y = 2 - 2 cos(1.5 p) x 2 x s (the initial body y of 1 is replaced
by 2 first); (4) left_leg.y = 8 + 2 sin(1.5 p x 0.5 + pi) x 2 x s; right_leg.y = 8 + 2 sin(1.5 p x 0.5) x 2 x s.

### 4.4 Baby (`BabyStriderModel`, layer 32 x 32)

| Part | Parent | Pivot | Box | tex |
|---|---|---|---|---|
| `body` | root | (0, 16.75, 0) | (-3.5, -3.75, -4), 7 x 7 x 8 | (0, 0) |
| `right_leg` | root | (-1.5, 20, 0) | (-1, 0, -1), 2 x 4 x 2 | (0, 24) |
| `left_leg` | root | (1.5, 20, 0) | (-1, 0, -1), 2 x 4 x 2 | (8, 24) |
| `bristle0` (back) | body | (0, -4.25, 2) | (-3.5, -2.5, 0), 7 x 3 x 0 | (0, 21) |
| `bristle1` (middle) | body | (0, -4.25, 0) | (-3.5, -2.5, 0), 7 x 3 x 0 | (0, 18) |
| `bristle2` (front) | body | (0, -4.25, -2) | (-3.5, -2.5, 0), 7 x 3 x 0 | (0, 15) |

`customAnimations(p, s, t)`: body.y = 17.25 - 2 x cos(1.5 p) x s (worked value 16.75 at p = 0, s = 0.25);
left_leg.y = 20 + 2 sin(1.5 p x 0.5 + pi) x 2 x s; right_leg.y = 20 + 2 sin(1.5 p x 0.5) x 2 x s; `animateBristle(t, base,
bristle2 (front, "top"), bristle1 (middle), bristle0 (back, "bottom"))` adding to **xRot** with base = cos(1.5 p + pi) x s.

---

## 5. Hoglin and zoglin (`HoglinModel`, `BabyHoglinModel`, `AbstractHoglinRenderer`, `HoglinRenderer`, `ZoglinRenderer`)

### 5.1 Renderers and state

`AbstractHoglinRenderer` is an ageable renderer whose adult model is `HoglinModel` (layer given by the subclass) and
baby model `BabyHoglinModel`; shadow radius is the constructor argument, 0.7 for both subclasses; no layers. State
`HoglinRenderState` = living state + `attackAnimationRemainingTicks` (int, from `HoglinBase.getAttackAnimationRemainingTicks`;
not interpolated) + `isConverting` (boolean, hoglin only).

| Renderer | Layers | Textures |
|---|---|---|
| `HoglinRenderer` | `HOGLIN`, `HOGLIN_BABY` | `textures/entity/hoglin/hoglin.png` (128 x 64), `hoglin_baby.png` (64 x 64) |
| `ZoglinRenderer` | `ZOGLIN`, `ZOGLIN_BABY` | `textures/entity/hoglin/zoglin.png` (128 x 64), `zoglin_baby.png` (64 x 64) |

`LayerDefinitions` registers `ZOGLIN` with the same layer definition as `HOGLIN` and `ZOGLIN_BABY` as `HOGLIN_BABY`
(`HoglinModel.createBodyLayer()` and `BabyHoglinModel.createBodyLayer()`, no transformer). Only the textures differ.
`HoglinRenderer.isShaking` is true when the base rule holds or `isConverting` is true (a hoglin about to turn into a
zoglin shivers, 1.6 step 3); the zoglin never shakes for conversion.

### 5.2 Adult mesh (layer 128 x 64)

| Part | Parent | Pivot | Rotation | Box | tex |
|---|---|---|---|---|---|
| `body` | root | (0, 7, 0) | 0 | (-8, -7, -13), 16 x 14 x 26 | (1, 1) |
| `mane` | body | (0, -14, -7) | 0 | (0, 0, -9), 0 x 10 x 19, grow 0.001 | (90, 33) |
| `head` | root | (0, 2, -12) | x 0.87266463 | (-7, -3, -19), 14 x 6 x 19 | (61, 1) |
| `right_ear` | head | (-6, -2, -3) | z -0.6981317 | (-6, -1, -2), 6 x 1 x 4 | (1, 1) |
| `left_ear` | head | (6, -2, -3) | z 0.6981317 | (0, -1, -2), 6 x 1 x 4 | (1, 6) |
| `right_horn` | head | (-7, 2, -12) | 0 | (-1, -11, -1), 2 x 11 x 2 | (10, 13) |
| `left_horn` | head | (7, 2, -12) | 0 | (-1, -11, -1), 2 x 11 x 2 | (1, 13) |
| `right_front_leg` | root | (-4, 10, -8.5) | 0 | (-3, 0, -3), 6 x 14 x 6 | (66, 42) |
| `left_front_leg` | root | (4, 10, -8.5) | 0 | (-3, 0, -3), 6 x 14 x 6 | (41, 42) |
| `right_hind_leg` | root | (-5, 13, 10) | 0 | (-2.5, 0, -2.5), 5 x 11 x 5 | (21, 45) |
| `left_hind_leg` | root | (5, 13, 10) | 0 | (-2.5, 0, -2.5), 5 x 11 x 5 | (0, 45) |

No box is mirrored. The mane is a zero-width box (two big faces).

### 5.3 Baby mesh (`BabyHoglinModel`, layer 64 x 64)

| Part | Parent | Pivot | Rotation | Boxes (origin, size, tex, grow) |
|---|---|---|---|---|
| `head` | root | (0, 13, -7) | x 0.8727 | (-5, -2.2605, -10.547), 10 x 4 x 12, tex (0, 0); (-7, -4.0981, -8.4879), 2 x 5 x 2, tex (44, 29); (5, -4.0981, -8.4879), 2 x 5 x 2, tex (52, 29) (the two small boxes are the horns) |
| `body` | root | (0, 24, 0) | 0 | (-4, -14, -7), 8 x 8 x 14, tex (0, 16), grow 0.02; (0, -18, -8), 0 x 6 x 11, tex (24, 39), grow 0.02 (mane) |
| `right_ear` | head | (-5, -1, -1.5) | z -0.8727 | (-5.1, -0.5, -2), 6 x 1 x 4, tex (32, 5) |
| `left_ear` | head | (5, -1, -1.5) | z 0.8727 | (-0.9, -0.5, -2), 6 x 1 x 4, tex (32, 0), **mirrored** |
| `right_hind_leg` | root | (-2.5, 18, 4.5) | 0 | (-1.5, 0, -1.5), 3 x 6 x 3, tex (0, 47) |
| `left_hind_leg` | root | (2.5, 18, 4.5) | 0 | (-1.5, 0, -1.5), 3 x 6 x 3, tex (12, 47) |
| `right_front_leg` | root | (-2.5, 18, -4.5) | 0 | (-1.5, 0, -1.5), 3 x 6 x 3, tex (0, 38) |
| `left_front_leg` | root | (2.5, 18, -4.5) | 0 | (-1.5, 0, -1.5), 3 x 6 x 3, tex (12, 38) |

(The baby has no horn parts; `HoglinModel`'s constructor looks up `right_ear`, `left_ear` under `head` and the four legs,
which exist.)

### 5.4 `setupAnim` (shared by adult and baby)

With s = `walkAnimationSpeed` (not clamped), p = `walkAnimationPos`, a = `attackAnimationRemainingTicks`:

1. right_ear.zRot = -0.6981317 - s sin(p); left_ear.zRot = 0.6981317 + s sin(p) (both mesh constants, even for the baby whose
   initial ear rotation is 0.8727: the baby's ears therefore use the adult base angle in this formula).
2. head.yRot = state.yRot x DEG.
3. Headbutt factor f = 1 - |10 - 2a| / 10 (integer absolute value; a = 0 or 10 gives 0, a = 5 gives 1).
   `animateHeadbutt(f)`: head.xRot = lerp(f, 0.87266463, -0.34906584) (so the head rotates from 0.8727 at rest to -0.349 at the
   peak of the attack). The **baby** override additionally does head.y += f x 2.5 (after the base behaviour).
4. right_front_leg.xRot = cos(p) x 1.2 x s; left_front_leg.xRot = cos(p + pi) x 1.2 x s; right_hind_leg.xRot = the left front
   leg's xRot; left_hind_leg.xRot = the right front leg's xRot (diagonal pairs move together).

---

## 6. The Wither (`WitherBossModel`, `WitherBossRenderer`, `WitherArmorLayer`, wither skull)

### 6.1 Model (`WitherBossModel.createBodyLayer(CubeDeformation grow)`, layer 64 x 64)

`LayerDefinitions`: `WITHER` = `createBodyLayer(NONE)`; `WITHER_ARMOR` = `createBodyLayer(0.5)` (every box below, including
the heads, gets the grow). Let c0 = 0.20420352 (= 0.065 pi) and the pose angle constants as read.

| Part | Pivot | Rotation | Boxes (origin, size, tex) |
|---|---|---|---|
| `shoulders` | (0, 0, 0) | 0 | (-10, 3.9, -0.5), 20 x 3 x 3, tex (0, 16) |
| `ribcage` | (-2, 6.9, -0.5) | x 0.20420352 | tex (0, 22): (0, 0, 0), 3 x 10 x 3; tex (24, 22): (-4, 1.5, 0.5), 11 x 2 x 2; (-4, 4, 0.5), 11 x 2 x 2; (-4, 6.5, 0.5), 11 x 2 x 2 |
| `tail` | (-2, 6.9 + cos(c0) x 10, -0.5 + sin(c0) x 10) = (-2, 16.692, 1.528) | x 0.83252203 | (0, 0, 0), 3 x 6 x 3, tex (12, 22) |
| `center_head` | (0, 0, 0) | 0 | (-4, -4, -4), 8 x 8 x 8, tex (0, 0) |
| `right_head` | (-8, 4, 0) | 0 | (-4, -4, -4), 6 x 6 x 6, tex (32, 0) |
| `left_head` | (10, 4, 0) | 0 | (-4, -4, -4), 6 x 6 x 6, tex (32, 0) (same builder as the right head) |

`setupAnim(state)`: with c = cos(`ageInTicks` x 0.1) (`Mth.cos`):

1. right_head: yRot = (yHeadRots[0] - bodyRot) x DEG; xRot = xHeadRots[0] x DEG. left_head: the same with index 1.
2. ribcage.xRot = (0.065 + 0.05 c) x pi.
3. tail position = (-2, 6.9 + cos(ribcage.xRot) x 10, -0.5 + sin(ribcage.xRot) x 10); tail.xRot = (0.265 + 0.1 c) x pi.
4. center_head: yRot = state.yRot x DEG, xRot = state.xRot x DEG.

(The shoulders and the ribcage's own pivot x of -2 are constants; the three heads are separate parts: the model has no neck.)

### 6.2 Renderer (`WitherBossRenderer`) and state

State `WitherRenderState` = living state + `xHeadRots[2]`, `yHeadRots[2]` (float arrays, copied from
`WitherBoss.getHeadXRots/getHeadYRots`), `invulnerableTicks` (float), `isPowered` (`WitherBoss.isPowered()`).
The renderer copies the arrays as they are (no partial-tick interpolation in the renderer; the entity keeps previous-tick copies, `xRotOHeads` and `yRotOHeads`, which this renderer does not consume). Entity side, per tick, for head i = 0 and 1 (read from `WitherBoss.aiStep`; the owner is 21 §7.2): the previous arrays are saved, then if the alternative target of head i+1 is a living entity: with (dx, dy, dz) = (target X, target eye Y, target Z) minus the head position (`getHeadX/Y/Z(i + 1)`), yaw = narrow-to-float(Mth.atan2(dz, dx) x 57.2957763671875) - 90.0f (the double product is narrowed to float first, then 90.0f is subtracted) and pitch = narrow-to-float(-(Mth.atan2(dy, sqrt(dx^2 + dz^2)) x 57.2957763671875)); the pitch is negated, so a target above the head gives a negative xRot. Both use `Mth.atan2`, not `Math.atan2`. Then xRotHeads[i] = rotlerp(xRotHeads[i], pitch, 40) and yRotHeads[i] = rotlerp(yRotHeads[i], yaw, 10); otherwise yRotHeads[i] = rotlerp(yRotHeads[i], bodyYaw, 10) and xRotHeads[i] is unchanged. `rotlerp(a, b, maxStep)` (read): d = wrapDegrees(b - a) (1.4), clamped to the range [-maxStep, +maxStep], result a + d. The body-turn path in `aiStep` (yaw set from atan2 of the horizontal motion when the horizontal speed squared exceeds 0.05) is entity behaviour, deferred to 21 §7.2.
`invulnerableTicks` = `getInvulnerableTicks()` - partialTick when that integer is above 0, else 0.
Renderer: model `WITHER`, shadow radius 1.0, block-light level 15, one layer (6.3).

- **Size**: the `scale` hook (called after the (-1, -1, 1) flip, 1.6 step 5) scales uniformly by
  S = 2.0, reduced by `invulnerableTicks / 220 x 0.5` when `invulnerableTicks > 0`. So S is linear in the state value: 2.0 at 0,
  1.75 at 110, 1.5 at 220 (the value is `getInvulnerableTicks()` minus the partial tick; which direction it counts during the
  spawn phase is entity behaviour, 21 §7.2).
- **Texture** (n = floor(`invulnerableTicks`)): n <= 0 gives `wither.png`; n > 80 gives `wither_invulnerable.png`; for
  1 <= n <= 80, `wither.png` when (n div 5) is odd and `wither_invulnerable.png` when it is even. So while the value is in
  1..80 the texture alternates every 5 units (n = 76..80: n div 5 = 15 or 16; n = 80 gives 16, even, invulnerable; n = 75..79 gives 15, odd, normal). Paths: `textures/entity/wither/wither.png`, `wither_invulnerable.png`, `wither_armor.png`
  (all 64 x 64).

### 6.3 Power swirl (`WitherArmorLayer` over `EnergySwirlLayer`)

The layer holds its own `WitherBossModel` baked from `WITHER_ARMOR` (the 0.5-grown mesh). Draw condition:
`state.isPowered`. When it holds, with t = `ageInTicks`: draw that model (set up with the same state, 6.1) with texture
`wither_armor.png`, the render type `energySwirl(texture, u, v)` where u = (cos(0.02 t) x 3) mod 1 (float remainder, `Mth.cos`),
v = (0.01 t) mod 1, overlay none, tint ARGB -8355712 = 0xFF808080 (grey: half-bright), submit order 1 (after the main model).
The `energySwirl` pipeline (`RenderPipelines.ENERGY_SWIRL`): entity shader with defines ALPHA_CUTOUT 0.1, EMISSIVE (no
lightmap), NO_OVERLAY, NO_CARDINAL_LIGHTING, APPLY_TEXTURE_MATRIX; culling off; blend ADDITIVE (source one, destination one);
the texture matrix is a translation by (u, v) (`TextureTransform$OffsetTextureTransform(u, v)`: read, its matrix is a plain translation by (u, v, 0); `entity.vsh` under APPLY_TEXTURE_MATRIX computes texCoord0 = (TextureMat x (UV0, 0, 1)).xy, so the sampled coordinate is UV + (u, v): the image content appears to move by (-u, -v) as u and v grow. The cos term makes the u scroll oscillate; the v term scrolls steadily). The pipeline also uses `DepthStencilState.DEFAULT`, topology QUADS and the ENTITY vertex format. `RenderPipelines` additionally registers an order-independent-transparency variant `OIT_ENERGY_SWIRL` (shader define OIT_ADDITIVE) that `RenderTypes.energySwirl` references; that path is not specified here and plain blending with the stated function is the assumed equivalent (Open question 4).

### 6.4 Wither skull (`WitherSkullRenderer`, `WitherSkullRenderState`)

Layer `WITHER_SKULL` = `WitherSkullRenderer.createSkullLayer()`, texture size 64 x 64: one part `head`, pivot (0, 0, 0),
box (-4, -8, -4), 8 x 8 x 8, tex (0, 35). The model class is `SkullModel` (a `SkullModelBase`, whose constructor passes `Model` the function `RenderTypes.entityTranslucent(Identifier)` (read: a direct method-handle argument), so the model's default render type is `entityTranslucent`; `WitherSkullRenderer` calls the `submitModel(model, state, pose, texture, light, overlay, outlineColour)` overload, read in `OrderedSubmitNodeCollector`: it forwards to the render-type overload with `model.renderType(texture)`, tint -1 (white), no UV mapping and the outline colour argument, so the skull is drawn with `entityTranslucent(texture)`: resolved). `SkullModel.setupAnim`: head.yRot = state.yRot x DEG, head.xRot = state.xRot x DEG.
State `WitherSkullRenderState` = entity state + `isDangerous` (`WitherSkull.isDangerous()`) + a model state
(`animationPos` 0, `yRot` = entity `getYRot(partial)`, `xRot` = entity `getXRot(partial)`, both in degrees).

Renderer: no shadow set, block-light level 15. The skull model is not part of the living-entity sequence, so it has no name tag, leash or fire handling of its own (see 10.1). Pose: only scale (-1, -1, 1) (no 1.501 translate, no 180 - yaw rotation: the
model's own yRot/xRot orient it); submit the model with texture `wither_invulnerable.png` when `isDangerous` (the blue
skull) else `wither.png`, light = `lightCoords`, no overlay. The 8 x 8 x 8 box spans model y -8..0, so after the flip it
spans world y 0..0.5 above the entity origin.

---

## 7. End crystal (`EndCrystalModel`, `EndCrystalRenderer`, `EndCrystalRenderState`)

### 7.1 Model (layer `END_CRYSTAL`, 64 x 32; the jar's image is 128 x 64)

Let G be the glass box (-4, -4, -4), 8 x 8 x 8 at tex (0, 0). The two scale constants are 0.875 and 0.765625 (= 0.875 squared).

| Part | Parent | Pose | Box |
|---|---|---|---|
| `outer_glass` | root | pivot (0, 24, 0) | G, tex (0, 0) |
| `inner_glass` | outer_glass | pivot 0, **scale 0.875** | G, tex (0, 0) |
| `cube` | inner_glass | pivot 0, **scale 0.765625** | (-4, -4, -4), 8 x 8 x 8, tex (32, 0) |
| `base` | root | pivot 0 | (-6, 0, -6), 12 x 4 x 12, tex (0, 16) |

Scales nest: the inner glass is 0.875 of the outer, the cube 0.765625 x 0.875 = 0.6699 of the outer.

### 7.2 State, bobbing and `setupAnim`

State `EndCrystalRenderState` = entity state + `showsBottom` (default true; `EndCrystal.showsBottom()`) + `beamOffset`
(Vec3 or null). `extractRenderState`: `ageInTicks` = `EndCrystal.time` + partial (the crystal's own counter, not `tickCount`);
`showsBottom`; if `getBeamTarget()` is not null then `beamOffset` = (block centre of the target) - (the crystal's position at the
partial tick), else null.

`EndCrystalRenderer.getY(a)`: f = sin(0.2 a) / 2 + 0.5; f = (f x f + f) x 0.4; result = f - 1.4. The result is in
-1.4 (f = 0) to -0.6 (f = 1); at a = 0 it is -1.1.

`setupAnim` (with R = ageInTicks x 3 degrees, S45 = float(sin(pi/4)) = 0.70710677, axis = (S45, 0, S45), angle 60 degrees = 1.0471976):
1. `base.visible` = `showsBottom`.
2. outer_glass.y += getY(ageInTicks) x 16 / 2 (so y = 24 + 8 getY).
3. outer_glass is rotated (`rotateBy`) by Q1 = RotY(R degrees) x Rot(axis, 60 degrees) (matrix product: the axis rotation acts on
   vertices first, then the Y rotation).
4. inner_glass and cube are each rotated by Q2 = Rot(axis, 60 degrees) x RotY(R degrees) (the Y rotation acts first, then the axis
   rotation). Since they are nested, the cube's world rotation is Q1 x Q2 x Q2.

### 7.3 Renderer

Shadow radius 0.5. Pose: scale (2, 2, 2), translate (0, -0.5, 0); submit the model with texture
`textures/entity/end_crystal/end_crystal.png`, light, no overlay (this renderer does not use the 1.6 sequence: no
entity yaw, no flip, no 1.501 translate). `shouldRender` is true when the base test (frustum, distance) passes **or** the
crystal has a beam target (the beam must not vanish when the crystal body is off screen). If `beamOffset` is not null: with
(bx, by, bz) = `beamOffset` as floats and y = getY(ageInTicks), translate by (bx, by, bz), then call the beam routine (8.7) with the
vector (-bx, -by + y, -bz), `ageInTicks`, light = `lightCoords`. So the beam is drawn from the beam target back toward the
crystal's bobbing centre. `EndCrystalRenderer` translates the beam by a `Vec3` (doubles), not floats, which makes no practical difference. `EndCrystalItem.useOn` creates the entity at the empty block above the clicked block (x + 0.5, that block's y, z + 0.5) and then calls `setShowBottom(false)`, so a player-placed crystal never draws the base slab (see Open question 10).

---

## 8. Ender Dragon (`EnderDragonModel`, `EnderDragonRenderer`, `EnderDragonRenderState`, `DragonFlightHistory`)

### 8.1 Flight history (`DragonFlightHistory`, 64 samples)

The entity owns the ring: 64 samples (y: double, yRot: float degrees), `head` index starting at -1. `record(y, yRot)`: build a
sample; if `head < 0` fill all 64 slots with it; `head` = `head + 1`, wrapped to 0 when it reaches 64; store the sample at
`head`. `get(n)` = sample[(head - n) AND 63] (n ticks ago; n may exceed 63 by wrapping). `get(n, t)` (interpolated) = sample with
y = lerp(t, get(n + 1).y, get(n).y) and yRot = rotLerp(t, get(n + 1).yRot, get(n).yRot). The initial 64 samples are (0, 0).
`copyFrom` copies the 64 slots and `head`. The entity records once per `aiStep` with `getY()` and `getYRot()` (after wrapping
yaw to -180..180), except that (a) an entity with no AI sets `flapTime` = 0.5 and returns before recording, and (b) while `isDeadOrDying()` the step spawns explosion particles and returns before the `flapTime` update and before `record`: a dying dragon changes neither `flapTime` nor the history (consistent with the renderer using partialTicks = 0 for a dying dragon). `oFlapTime` is still set to `flapTime` early in the step.

### 8.2 State (`EnderDragonRenderState`) and `extractRenderState`

Fields: `flapTime`, `deathTime`, `hasRedOverlay`, `beamOffset` (Vec3 or null), `isLandingOrTakingOff`, `isSitting`,
`distanceToEgg` (double), `partialTicks`, and a private copy of the flight history. Extraction:

- `flapTime` = lerp(partial, `oFlapTime`, `flapTime`);
- `deathTime` = `dragonDeathTime` + partial when `dragonDeathTime > 0`, else 0;
- `hasRedOverlay` = `hurtTime > 0`;
- `beamOffset` = (nearest crystal position at the partial tick + (0, getY(crystal.time + partial), 0)) - (dragon position at the
  partial tick) when `nearestCrystal` is not null, else null;
- `isLandingOrTakingOff` = current phase is LANDING or TAKEOFF; `isSitting` = `phase.isSitting()`;
- `distanceToEgg` = squared distance from the block position `getHeightmapPos(MOTION_BLOCKING_NO_LEAVES, podium location of the
  fight origin)` (centre of that block) to the dragon's position (`BlockPos.distToCenterSqr`);
- `partialTicks` = 0 when the dragon is dead or dying, else the partial tick (so a dying dragon does not interpolate);
- the flight history is copied.

`getHistoricalPos(n)` = history.get(n, partialTicks). `getHeadPartYOffset(i, a, b)` (a, b samples; result converted to float):
landing or taking off: i / max(distanceToEgg / 4, 1); else sitting: i; else i = 6: 0; else b.y - a.y.

### 8.3 Model parts (layer `ENDER_DRAGON`, 256 x 256, no transformer)

All boxes below are not mirrored unless stated; "M" marks a mirrored box. Pivots are relative to the parent part.

| Part | Parent | Pivot | Rotation | Boxes (name: origin, size, tex) |
|---|---|---|---|---|
| `head` | root | (0, 20, -62) | 0 | upperlip: (-6, -1, -24), 12 x 5 x 16, (176, 44); upperhead: (-8, -8, -10), 16 x 16 x 16, (112, 30); **M** scale: (-5, -12, -4), 2 x 4 x 6, (0, 0); **M** nostril: (-5, -3, -22), 2 x 2 x 4, (112, 0); **M** scale: (3, -12, -4), 2 x 4 x 6, (0, 0); **M** nostril: (3, -3, -22), 2 x 2 x 4, (112, 0) |
| `jaw` | head | (0, 4, -8) | 0 | jaw: (-6, 0, -16), 12 x 4 x 16, (176, 65) |
| `neck0` .. `neck4` | root | (0, 20, -12 - 10 i) | 0 | box: (-5, -5, -5), 10 x 10 x 10, (192, 104); scale: (-1, -9, -3), 2 x 4 x 6, (48, 0) |
| `tail0` .. `tail11` | root | (0, 10, 60 + 10 i) | 0 | the same two boxes as the neck parts |
| `body` | root | (0, 20, 8) | 0 | body: (-12, -16, -16), 24 x 24 x 64, (0, 0); scale: (-1, -22, -10), 2 x 6 x 12, (220, 53); scale: (-1, -22, 10), 2 x 6 x 12, (220, 53); scale: (-1, -22, 30), 2 x 6 x 12, (220, 53) |
| `left_wing` | body | (12, -15, -6) | 0 | **M** bone: (0, -4, -4), 56 x 8 x 8, (112, 88); **M** skin: (0, 0, 2), 56 x 0 x 56, (-56, 88) |
| `left_wing_tip` | left_wing | (56, 0, 0) | 0 | **M** bone: (0, -2, -2), 56 x 4 x 4, (112, 136); **M** skin: (0, 0, 2), 56 x 0 x 56, (-56, 144) |
| `left_front_leg` | body | (12, 0, -6) | x 1.3 | main: (-4, -4, -4), 8 x 24 x 8, (112, 104) |
| `left_front_leg_tip` | left_front_leg | (0, 20, -1) | x -0.5 | main: (-3, -1, -3), 6 x 24 x 6, (226, 138) |
| `left_front_foot` | left_front_leg_tip | (0, 23, 0) | x 0.75 | main: (-4, 0, -12), 8 x 4 x 16, (144, 104) |
| `left_hind_leg` | body | (16, -4, 34) | x 1.0 | main: (-8, -4, -8), 16 x 32 x 16, (0, 0) |
| `left_hind_leg_tip` | left_hind_leg | (0, 32, -4) | x 0.5 | main: (-6, -2, 0), 12 x 32 x 12, (196, 0) |
| `left_hind_foot` | left_hind_leg_tip | (0, 31, 4) | x 0.75 | main: (-9, 0, -20), 18 x 6 x 24, (112, 0) |
| `right_wing` | body | (-12, -15, -6) | 0 | bone: (-56, -4, -4), 56 x 8 x 8, (112, 88); skin: (-56, 0, 2), 56 x 0 x 56, (-56, 88) |
| `right_wing_tip` | right_wing | (-56, 0, 0) | 0 | bone: (-56, -2, -2), 56 x 4 x 4, (112, 136); skin: (-56, 0, 2), 56 x 0 x 56, (-56, 144) |
| `right_front_leg` .. `right_hind_foot` | as the left | as the left with pivot x negated (front legs (-12, 0, -6), hind legs (-16, -4, 34)) | as the left | the same boxes as the left, **not** mirrored |

The skin boxes are flat (height 0): each is a 56 x 56 px membrane whose two big faces use UV rectangles
(0..56, 88..144) and (56..112, 88..144) for the wing (and rows 144..200 for the tip), because the tex origin u is -56
and the depth is 56 (1.2). Rotations are about the x axis for the legs; the wing and head rotations are set every frame (8.4).
`leftRearLeg` etc. in the class are the `left_hind_*` parts.

### 8.4 `setupAnim`

Let w = `flapTime` x 2 pi; P(n) = `getHistoricalPos(n)` with y(n) and yaw(n); `wrap` = `Mth.wrapDegrees`;
`offset(i, a, b)` = `getHeadPartYOffset` of 8.2.

1. jaw.xRot = (sin w + 1) x 0.2.
2. s = sin(w - 1) + 1; f = (s x s + 2 s) x 0.05.
3. The model **root** part is moved: root.y = (f - 2) x 16; root.z = -48; root.xRot = f x 2 x DEG.
4. (x, y, z) = the initial pivot of `neck0` = (0, 20, -12). A = P(6); d = wrap(yaw(5) - yaw(10)); ref = wrap(yaw(5) + d / 2).
5. For i = 0 to 4 (neck parts, in order): B = P(5 - i); wob = cos(i x 0.45 + w) x 0.15;
   neck_i.yRot = wrap(yaw(B) - yaw(A)) x DEG x 1.5;
   neck_i.xRot = wob + offset(i, A, B) x DEG x 1.5 x 5;
   neck_i.zRot = -wrap(yaw(B) - ref) x DEG x 1.5;
   neck_i.pivot = (x, y, z); then advance:
   x = x - sin(neck_i.yRot) cos(neck_i.xRot) x 10; y = y + sin(neck_i.xRot) x 10; z = z - cos(neck_i.yRot) cos(neck_i.xRot) x 10.
6. head.pivot = (x, y, z) (the point after the last neck part); C = P(0);
   head.yRot = wrap(yaw(C) - yaw(A)) x DEG; head.xRot = wrap(offset(6, A, C)) x DEG x 1.5 x 5;
   head.zRot = -wrap(yaw(C) - ref) x DEG.
7. body.zRot = -d x 1.5 x DEG.
8. Left wing: xRot = 0.125 - cos w x 0.2; yRot = -0.25; zRot = -(sin w + 0.125) x 0.8. Left wing tip: zRot = (sin(w + 2) + 0.5) x 0.75.
   Right wing: xRot = the left wing's xRot; yRot = -(left yRot) = 0.25; zRot = -(left zRot); right tip zRot = -(left tip zRot).
9. Limbs, with the function `poseLimbs(f, frontLeg, frontTip, frontFoot, hindLeg, hindTip, hindFoot)` applied to the left set
   and then to the right set (same f of step 2): hindLeg.xRot = 1.0 + f x 0.1; hindTip.xRot = 0.5 + f x 0.1; hindFoot.xRot =
   0.75 + f x 0.1; frontLeg.xRot = 1.3 + f x 0.1; frontTip.xRot = -0.5 - f x 0.1; frontFoot.xRot = 0.75 + f x 0.1.
10. Tail: acc = 0; (x, y, z) = the initial pivot of `tail0` = (0, 10, 60); T = P(11). For i = 0 to 11 (tail parts, in order): B = P(12 + i);
    acc = acc + sin(i x 0.45 + w) x 0.05;
    tail_i.yRot = (wrap(yaw(B) - yaw(T)) x 1.5 + 180) x DEG;
    tail_i.xRot = acc + (y(B) - y(T)) x DEG x 1.5 x 5;
    tail_i.zRot = wrap(yaw(B) - ref) x DEG x 1.5;
    tail_i.pivot = (x, y, z); then advance: y = y + sin(tail_i.xRot) x 10; z = z - cos(tail_i.yRot) cos(tail_i.xRot) x 10;
    x = x - sin(tail_i.yRot) cos(tail_i.xRot) x 10.
    (The 180 degree term turns the tail parts to face backward, so z grows toward the tail.)

The main body, wings and legs inherit the root's transform (step 3). The jaw is a child of the head.

### 8.5 Renderer: pose and passes (`EnderDragonRenderer.submit`)

Shadow radius 0.5; `affectedByCulling` is false (the dragon is never culled by the frustum test). Pose, in order (last acts first):
translate to the entity position; rotate about Y by -yaw(7) degrees; rotate about X by (y(5) - y(10)) x 10 degrees (P(n) as in 8.4:
`getHistoricalPos`); translate (0, 0, 1); scale (-1, -1, 1); translate (0, -1.501, 0). (There is no `setupRotations` and no scale
hook; no death flip.) Overlay v = 3 when `hasRedOverlay` else 10, u = 0.

Passes, in this order:
1. If `deathTime > 0`: submit the model with the **dissolve render type** `entityCutoutDissolve(dragon.png, dragon_exploding.png)`,
   light, no overlay, tint white with alpha 1 - `deathTime` / 200 (so the vertex alpha runs from 1 down to 0 over the 200 ticks
   of the death animation). Else submit the model with `textures/entity/enderdragon/dragon.png` and the overlay above.
2. Always: submit the model again with `RenderTypes.eyes(textures/entity/enderdragon/dragon_eyes.png)`, light, no overlay (the
   glowing eyes pass; it is also drawn while dying).
3. If `deathTime > 0`: with p = `deathTime` / 200, inside the same pose translate (0, -1, -2) and draw the death rays (8.6) with
   `RenderTypes.dragonRays()`.
4. The pose is restored; if `beamOffset` is not null draw the crystal beam (8.7) with the vector (beamOffset.x, y, z as floats),
   `ageInTicks`, `lightCoords`, in the entity pose (translate to the entity position only).

Pipelines: `entityCutoutDissolve` = entity shader with ALPHA_CUTOUT 0.1, PER_FACE_LIGHTING, DISSOLVE, culling off, the texture
and a second sampler `DissolveMaskSampler` (the mask image), lightmap, overlay. The fragment rule of `entity.fsh` under DISSOLVE:
sample the mask at the same UV; if the vertex alpha < the mask's alpha channel, discard the fragment; otherwise
the vertex alpha is replaced by 1 (the dissolve entirely replaces translucency) and the colour is texel x vertex colour.
`eyes` = translucent blend (source alpha, one minus source alpha for colour; one, one minus source alpha for alpha), depth state `DepthStencilState(GREATER_THAN_OR_EQUAL, depthWrite = false)` (compare "greater or equal", reverse depth, and depth writes off), EMISSIVE, NO_OVERLAY, NO_CARDINAL_LIGHTING. `OIT_EYES` is the registered order-independent-transparency variant; see the OIT note in 6.3 and Open question 4.
Texture sizes: `dragon.png`, `dragon_exploding.png`, `dragon_eyes.png` are 256 x 256 (equal to the layer).

### 8.6 Death rays (`submitRays`, the lambda)

Inputs: p = `deathTime` / 200 (0 to 1). Steps:

1. g = (p - 0.8) / 0.2 when p > 0.8, else 0; g = min(g, 1).
2. Centre colour = ARGB with alpha 1 - g and red, green, blue 1 (white, fading to transparent by the end);
   edge colour = 16711935 = 0x00FF00FF (alpha 0, magenta).
3. rng = `RandomSource.createThreadLocalInstance(432)` (1.5).
4. n = floor(((p + p x p) / 2) x 60) rays (n = 22 at p = 0.5, 51 at p = 0.9, 60 at p = 1).
5. For each ray, in order: q = rotationXYZ(r1 2pi, r2 2pi, r3 2pi) then rotateXYZ(r4 2pi, r5 2pi, r6 2pi + p x pi/2), where r1 to r6 are
   six consecutive `nextFloat()` values (quaternion of the first call replaced, the second post-multiplied); then **multiply
   the running pose matrix by q** (the rotation accumulates from ray to ray: the pose is one object mutated in place);
   length L = r7 x 20 + 5 + g x 10; width W = r8 x 2 + 1 + g x 2 (r7, r8 the next two `nextFloat()` values).
6. Vertices of the ray in the current pose: centre O = (0, 0, 0); A = (-(sqrt(3)/2) W, L, -0.5 W); B = ((sqrt(3)/2) W, L, -0.5 W);
   C = (0, L, W). Three triangles (nine vertices, in this order, colours: O centre colour, A B C edge colour): (O, A, B),
   (O, B, C), (O, C, A).

`RenderTypes.dragonRays()`: pipeline `dragon_rays` (`RenderPipelines.DRAGON_RAYS_SNIPPET` plus blend): shader pair `core/rendertype_lightning`, the matrices-and-fog snippet (so fog applies), vertex format POSITION_COLOR, topology TRIANGLES (so the nine vertices form three triangles, read), `DepthStencilState.DEFAULT` (the rays are depth-tested and write depth normally), and blend `BlendFunction.LIGHTNING` = (SRC_ALPHA, ONE) (additive by alpha). `OIT_DRAGON_RAYS` (define OIT_ADDITIVE) is the OIT variant (Open question 4). Light is not used.

### 8.7 Crystal beam (`EnderDragonRenderer.submitCrystalBeams(x, y, z, age, pose, collector, light)`)

Used by the end crystal (7.3) and by the dragon (8.5 pass 4). Inputs: the vector (x, y, z) from the beam's origin to its end,
`age` = `ageInTicks`.

1. h = sqrt(x x x + z x z); len = sqrt(x x x + y x y + z x z).
2. Pose: translate (0, 2, 0); rotate about Y by (-atan2(z, x) - pi/2) **radians**; rotate about X by (-atan2(h, y) - pi/2) radians
   (`Math.atan2`). After these the local +z axis points along (x, y, z): for (1, 0, 0) the Y angle is -pi/2 and the X angle is -pi, which
   maps (0, 0, 1) to (1, 0, 0).
3. v0 = -age x 0.01; v1 = len / 32 - age x 0.01. Render type `endCrystalBeam(textures/entity/end_crystal/end_crystal_beam.png)`
   (16 x 256 in the jar; pipeline: ALPHA_CUTOUT 0.1, NO_OVERLAY, culling off, default blend, lightmap).
4. An octagonal tube: for k = 1 to 8, with angle a = k x 2pi / 8, (X, Y) = (sin a, cos a) x 0.75, u = k / 8, and the previous k's
   (X', Y', u') (for k = 1 the previous values are (0, 0.75, 0)), emit one quad of four vertices (position; colour; UV):
   (X' x 0.2, Y' x 0.2, 0; opaque black 0xFF000000; u', v0), (X', Y', len; white 0xFFFFFFFF; u', v1), (X, Y, len; white; u, v1),
   (X x 0.2, Y x 0.2, 0; black; u, v0). Every vertex: overlay none, light = `light`, normal (0, -1, 0).
So the beam is a tube of radius 0.75 that is tapered to radius 0.15 and tinted black at the origin end, white at the far end, whose
texture scrolls along its length (period 32 length units) at 0.01 per tick.

### 8.8 Entity-side inputs the renderer needs (read for completeness; the behaviour belongs to 21 §6.4)

- `flapTime` per tick (client and server entity): `oFlapTime` = `flapTime` at the start of the step; while the dragon is dying the step ends right after the particle spawn, before the following update (8.1); otherwise let f = 0.2 / (horizontal speed x 10 + 1) and
  f = f x 2^(vertical velocity); if the current phase `isSitting` then `flapTime += 0.1`, else if `inWall` then `flapTime += f x 0.5`, else
  `flapTime += f`. A no-AI dragon sets `flapTime` = 0.5 and returns before recording history.
- `dragonDeathTime` counts up while dying; `nearestCrystal` is the healing crystal (the beam is drawn only while it is not null).

---

## 9. Dragon fireball (`DragonFireballRenderer`)

No model, no layers. Block-light level 15. State: the plain `EntityRenderState` (the dispatcher fills position, `lightCoords`,
`outlineColor`). Pose: push; scale (2, 2, 2); rotate by the camera's orientation quaternion (`CameraRenderState.orientation`; a
billboard that faces the camera); draw one quad with render type `entityCutout(textures/entity/enderdragon/dragon_fireball.png)`
(a 16 x 16 image): four vertices (position (px - 0.5, py - 0.25, 0); colour white; UV (u, v); no overlay; light = `lightCoords`;
normal (0, 1, 0)), in this order:

| Vertex | px | py | u | v |
|---|---|---|---|---|
| 1 | 0 | 0 | 0 | 1 |
| 2 | 1 | 0 | 1 | 1 |
| 3 | 1 | 1 | 1 | 0 |
| 4 | 0 | 1 | 0 | 0 |

The quad is 1 x 1 block before the scale of 2 (so 2 x 2 blocks), centred horizontally on the entity and spanning y from -0.25 to
0.75 (before scaling: -0.5 to +1.5 above the origin). When `outlineColor` is non-zero (glowing outline) the same quad is also
submitted in the outline render type of `entityCutout` with the outline colour as the vertex colour.

**Shadow.** `DragonFireballRenderer`'s constructor only calls the `EntityRenderer` super constructor and assigns no `shadowRadius`; the `EntityRenderer` constructor assigns only `shadowStrength` (1.0), and the `shadowRadius` field has no initialiser, so it keeps the field default 0 and no shadow is drawn. The value 0 is inferred from reading those two constructors, not from a read initialiser.

---

## 10. Layer and texture summary

| Entity | `ModelLayers` entry | Texture size in the layer | Texture images (`textures/entity/...`, size in the jar) |
|---|---|---|---|
| blaze | `BLAZE` | 64 x 32 | `blaze/blaze.png` (64 x 32) |
| ghast | `GHAST` | 64 x 32, scaled 4.5 | `ghast/ghast.png`, `ghast/ghast_shooting.png` (128 x 64 each) |
| strider | `STRIDER`, `STRIDER_SADDLE` (same mesh), `STRIDER_BABY` | 64 x 128; 32 x 32 | `strider/strider.png`, `strider_cold.png` (64 x 128); `strider_baby.png`, `strider_cold_baby.png` (32 x 32); `equipment/strider_saddle/saddle.png` (64 x 128) |
| hoglin, zoglin | `HOGLIN`, `HOGLIN_BABY`, `ZOGLIN`, `ZOGLIN_BABY` | 128 x 64; 64 x 64 | `hoglin/hoglin.png`, `hoglin/zoglin.png` (128 x 64); `hoglin_baby.png`, `zoglin_baby.png` (64 x 64) |
| Wither | `WITHER`, `WITHER_ARMOR` (grow 0.5) | 64 x 64 | `wither/wither.png`, `wither_invulnerable.png`, `wither_armor.png` (64 x 64) |
| wither skull | `WITHER_SKULL` | 64 x 64 | `wither/wither.png`, `wither_invulnerable.png` |
| end crystal | `END_CRYSTAL` | 64 x 32 | `end_crystal/end_crystal.png` (128 x 64), `end_crystal_beam.png` (16 x 256) |
| Ender Dragon | `ENDER_DRAGON` | 256 x 256 | `enderdragon/dragon.png`, `dragon_exploding.png` (dissolve mask), `dragon_eyes.png` (256 x 256) |
| dragon fireball | none | n/a | `enderdragon/dragon_fireball.png` (16 x 16) |

The dragon head block (`DRAGON_SKULL`, `DragonHeadModel`) and the skull block entities belong to the block-entity renderers,
not to this document.

### 10.1 Shadow, name tag, leash, fire, hitbox and eye height, and equipment

These behaviours are shared by every entity and are specified once, not per model: the shadow drawing, name tag, leash and fire rendering are in 34-1 section 7; the generic layers (equipment, energy swirl, emissive) are in 34-1 section 8; hitbox size, eye height, name tag offset and passenger attachments per entity type are in 18 (entity type table and attachments section). What this document adds per entity is only the values below (all read in the sections cited).

| Entity | Shadow radius (x `state.scale`) | Block light | Extra layers | Hitbox, eye, name tag |
|---|---|---|---|---|
| blaze | 0.5 (read) | 15 | none | 18 |
| ghast | 1.5 (read) | state default | none | 18 |
| strider | 0.5, x 0.5 more for a baby (read in `StriderRenderer.getShadowRadius`) | state default | saddle equipment layer (4.1; path and flags: 34-1 section 8) | 18 |
| hoglin, zoglin | 0.7 (read) | state default | none | 18 |
| Wither | 1.0 | 15 | power swirl (6.3) | 18 |
| wither skull | none | 15 | none | 18 (projectile) |
| end crystal | 0.5 | state default | none (beam, 7.3) | 18 |
| Ender Dragon | 0.5 (read) | state default | eyes and dissolve passes (8.5) | 18 |
| dragon fireball | 0 (no shadow; inferred from the constructor, see 9) | 15 | none | 18 (projectile) |

No renderer in this document overrides the name tag attachment (searched each renderer class for a name tag method: none), so the name tag position is the generic one from 34-1 section 7 and 18. Eye heights and hitboxes are deferred to 18.

The saddle's dye, glint and cutout flags and the energy-swirl and OIT generalisation belong to 34-1 section 8; this document states only the strider's layer wiring and the Wither swirl's concrete arguments.

---

## 11. Worked examples

Tolerance for all numeric examples: 1e-3 (the sine table, 1.4).

### 11.1 Blaze at `ageInTicks` = 0 and 10

At t = 0 every rod is at its creation pivot. Ring 1: rod 0 (9, -1.000, 0); rod 1 (0, -1.122, 9); rod 2 (-9, -1.460, 0); rod 3 (0, -1.929, -9).
Ring 2: rod 4 (4.950, 1.584, 4.950); rod 5 (-4.950, 1.199, 4.950); rod 6 (-4.950, 1.010, -4.950); rod 7 (4.950, 1.064, -4.950).
Ring 3: rod 8 (4.455, 11.960, 2.270); rod 9 (-2.270, 11.893, 4.455); rod 10 (-4.455, 11.347, -2.270); rod 11 (2.270, 10.614, -4.455).
At t = 10: the ring 1 base angle is 10 pi x (-0.1) = -pi, so rod 0 is at (-9, -2.801, 0), rod 1 (0, -2.990, -9),
rod 2 (9, -2.936, 0), rod 3 (0, -2.654, 9).

### 11.2 Ghast

The tentacle table of 3.1. After scaling the tentacle 4 (x -1.25, z 0, length 11) has its pivot at model (-5.625, -84.056 + 4.5 x 24.6 =
26.644, 0) and its box is 9 px wide and 49.5 px long. A charging ghast (`isCharging` true) uses the `ghast_shooting.png` image with an identical pose.

### 11.3 Strider

p = 1, s = 0.25 (a clamped speed): body.zRot = 0.1 sin(1.5) x 4 x 0.25 = 0.0997; left_leg.xRot = sin(0.75) x 2 x 0.25 = 0.341; right_leg.xRot = -0.341;
left_leg.zRot = 0.17453 cos(0.75) x 0.25 = 0.0319; adult body.y = 2 - 4 x cos(1.5) x 0.25 = 1.929; left_leg.y = 8 + 4 sin(0.75 + pi) x 0.25 = 7.318;
right_leg.y = 8.682. At p = 0: body.y = 2 - 4 x 1 x 0.25 = 1.0; both legs y 8; left_leg.zRot = +0.0436; right_leg.zRot = -0.0436. A baby at p = 0, s = 0.25:
body.y = 17.25 - 0.5 = 16.75 and legs y = 20.

### 11.4 Hoglin headbutt

head.xRot by `attackAnimationRemainingTicks` a = 0 to 10: 0.873, 0.628, 0.384, 0.140, -0.105, -0.349, -0.105, 0.140, 0.384, 0.628, 0.873 (f = 0, 0.2, 0.4, 0.6, 0.8, 1, 0.8, ...).
For a baby the head also drops by f x 2.5 px (a = 5: y = 13 + 2.5 = 15.5).

### 11.5 Wither

At `ageInTicks` = 0: c = 1; ribcage.xRot = 0.115 pi = 0.3613; tail position (-2, 6.9 + cos(0.3613) x 10 = 16.254, -0.5 + sin(0.3613) x 10 = 3.035);
tail.xRot = 0.365 pi = 1.1467. At t = 15.7 (cos(1.57) near 0): ribcage.xRot = 0.065 pi = 0.2042, tail (-2, 16.692, 1.528), tail.xRot = 0.265 pi = 0.8326.
Size: `invulnerableTicks` = 220 gives S = 2 - 0.5 = 1.5; 110 gives 1.75; 1 gives 1.9977; 0 gives 2.0 (hook not reduced). Texture by n: n = 0 normal;
n = 1..4 invulnerable; 5..9 normal; 10..14 invulnerable; 75..79 normal; 80 and every n > 80 invulnerable (80 div 5 = 16, even).

### 11.6 End crystal

getY: a = 0: -1.100; a = 5: -0.693; a = 10: -0.654 (close to, not at, the maximum: the true maximum -0.6 occurs where 0.2a = pi/2, a about 7.85); the extremes are -1.4 and -0.6. At a = 0 the outer glass pivot is y = 24 + (-1.1 x 16)/2 = 15.2.
Orientation at a = 0: R = 0, so Q1 = Rot(axis, 60 degrees) and Q2 = the same; the glass diamond sits tilted 60 degrees about the horizontal diagonal axis (1, 0, 1)/sqrt(2).
The pose is scale 2 followed by translate (0, -0.5, 0) (7.3): the translate acts inside the scaled frame, so it moves the model by -1 block in world units; the crystal model is not flipped, so model +y is world +y. By this arithmetic the glass centre is 15.2 px x 2 / 16 - 1 = 0.90 block above the entity origin at a = 0 and the base slab spans -1.0 to -0.5 (Open question 10; a player-placed crystal has `showsBottom` false, so the slab is not drawn for it).

### 11.7 Dragon at `flapTime` = 0 in straight, level flight

All 64 samples equal (y = 64, yRot = 0), partial tick 0, not sitting, not landing: every wrapped difference is 0 and every `offset` is 0.
w = 0: jaw.xRot = 0.2; s = 1 - sin(1) = 0.1585; f = (0.02513 + 0.31706) x 0.05 = 0.01711; root.y = -31.726; root.xRot = 0.000597;
left wing xRot -0.075, yRot -0.25, zRot -0.1; left tip zRot 1.0570; right wing xRot -0.075, yRot 0.25, zRot 0.1; right tip zRot -1.0570;
left (and right) hind leg xRot 1.0017, tip 0.5017, foot 0.7517; front leg 1.3017, tip -0.5017, foot 0.7517.
Neck (xRot = 0.15 cos(0.45 i); zero yaw): neck0 pivot (0, 20, -12), xRot 0.150; neck1 (0, 21.494, -21.888), xRot 0.135; neck2 (0, 22.841, -31.797), xRot 0.093;
neck3 (0, 23.772, -41.753), 0.033; neck4 (0, 24.101, -51.748), -0.034; head pivot (0, 23.760, -61.742).
Tail (yRot = pi; xRot = running sum of 0.05 sin(0.45 i)): tail0 pivot (0, 10, 60), xRot 0; tail1 (0, 10.000, 70.000), 0.0218; tail2 (0, 10.218, 79.998), 0.0609; tail3
(0, 10.826, 89.979), 0.1097; tail6 (0, 15.459, 119.600), 0.2187; tail11 (0, 24.378, 168.752), 0.0592. (The dragon's tail therefore curves back down.)

### 11.8 Death rays

n(p) = floor((p + p x p) x 30): p = 0.5 gives 22, p = 0.9 gives 51, p = 1.0 gives 60. g(p): 0 up to p = 0.8, 0.5 at p = 0.9, 1 at p = 1.
At p = 0.9 the ray centre colour is alpha 0.5 white; every ray has length 5 + r7 x 20 + 5 = 10 to 30 (g x 10 = 5 added) and width 1 + r8 x 2 + 1 = 2 to 4.
The first six floats of the generator seeded 432 (1.5) are 0.7639, 0.8276, 0.8482, 0.8035, 0.7680, 0.7050 (so the first ray's first rotation is rotationXYZ(4.800, 5.200, 5.329) radians).

### 11.9 Crystal beam

Vector (4, 6, -3): h = 5, len = sqrt(61) = 7.810; Y angle = -atan2(-3, 4) - pi/2 = 0.6435 - 1.5708 = -0.9273; X angle = -atan2(5, 6) - pi/2 = -0.6947 - 1.5708 = -2.2655.
At age 50 the texture v range of the tube is -0.5 to 7.810 / 32 - 0.5 = -0.256.

### 11.10 Dragon fireball

At the entity position, a camera-facing quad of 2 x 2 blocks; vertex 1 is at local (-0.5 x 2, -0.25 x 2) = (-1, -0.5) with UV (0, 1); vertex 3 at (1, 1.5) with UV (1, 0).

---

## 12. Validation (checkable facts)

1. Part counts: blaze 13 parts (head + 12 rods); ghast 10 (body + 9 tentacles); adult strider 9 (3 + 6 bristles), baby strider 6; adult hoglin 11 (body, mane, head, 2 ears, 2 horns, 4 legs), baby hoglin 8 (body, head, 2 ears, 4 legs); Wither 6 (`shoulders`, `ribcage`, `tail`, 3 heads); end crystal 4; dragon 36 (head, jaw = 2; neck0 to neck4 = 5; tail0 to tail11 = 12; body = 1; the two wings and two wing tips = 4; six leg parts per side = 12).
2. A box of size w x h x d at tex (u, v) occupies a rectangle 2d + 2w wide and d + h tall starting at (u, v); check the dragon's `body` box at (0, 0): 2 x 64 + 2 x 24 = 176 wide and 64 + 24 = 88 tall (inside 256 x 256).
3. `Mth.sin` table: SIN[0] = 0, SIN[16384] = 1.0 (rounded to float), `cos(0)` = SIN[16384] = 1; `wrapDegrees(190)` = -170; `wrapDegrees(-190)` = 170; `wrapDegrees(180)` = -180; `rotLerp(0.5, 350, 10)` = 350 + 0.5 x 20 = 360 (not 180).
4. Generator: `createThreadLocalInstance(1660)` followed by nine `nextInt(7)` + 8 gives the lengths 8, 13, 9, 11, 11, 10, 12, 9, 12 (3.1). `createThreadLocalInstance(432)` `nextFloat()` gives 0.76393 as the first value.
5. Flight history: after `record` of values v1, v2, v3 into a fresh ring, `get(0)` = v3, `get(1)` = v2, `get(2)` = v1, `get(3)` = v1 (the initial fill); `get(0, 0.5)` = the midpoint between v3 and v2 (yaw by `rotLerp`).
6. Ghast body centre world height 1.8045 blocks above the entity origin (3.1); dragon pose has translate (0, 0, 1) before the flip; Wither scale 2 (1.5 when `invulnerableTicks` is 220); end crystal drawn at scale 2 and shifted -0.5.
7. Render types: blaze, ghast, strider, hoglin, zoglin, Wither main pass: `entityCutout` with alpha cut 0.1; wither skull `entityTranslucent` (model default and the `submitModel` overload both read, 6.4); dragon main pass `entityCutout` (or the dissolve type while dying) + `eyes`; swirl `energySwirl`; fireball `entityCutout`; beam `endCrystalBeam`.
8. Texture selection fixtures: ghast `isCharging` true selects `ghast_shooting.png`; strider (`isSuffocating`, `isBaby`) (true, true) selects `strider_cold_baby.png`; hoglin and zoglin baby select `*_baby.png`; Wither n = 80 selects the invulnerable image, n = 79 the normal image.
9. Strider cold shaking and hoglin conversion shaking add the yaw wobble cos(floor(ageInTicks) x 3.25) x pi x 0.4 degrees: at `ageInTicks` 0 to 0.99 the wobble is cos(0) x 0.4 pi = 1.2566 degrees; at 1.x it is cos(3.25) x 0.4 pi = -1.2494 degrees (cos(3.25) = -0.99413).

---

## 13. Open questions

Resolved items of earlier drafts were moved into the sections that state them: the scaling transformer applies to the root pose only (1.3; 34-2 section 1.3 still states otherwise and is the document to correct); the `dragon_rays` pipeline (8.6); the strider saddle image path (4.1); `NativeImage.setPixel` red-flash conversion (1.6); the skull render type (6.4); the swirl texture offset convention (6.3).

1. `EquipmentLayerRenderer.renderLayers` (dye colour, glint, cutout flags, the layer type's directory name) and the `Equippable` component of the saddle item were not read in this round; they are assigned to 34-1 section 8 and to 22 (extraction). The strider saddle's wiring (4.1) is stated here; an implementer needs that section for the remaining flags. Searched: the call sites in `StriderRenderer` and `SimpleEquipmentLayer` only.
2. `ARGB.white(alpha)` was read as used for the overlay's second row (1.6); `ARGB.colorFromFloat` and `ARGB.multiply` were treated as the obvious packers and not read.
3. Draw order between the main model, the energy swirl (order 1) and the equipment layer (order 0) across the translucent and opaque passes was not traced. (The Wither head pitch sign and `rotlerp` body are resolved in 6.2.)
4. The order-independent-transparency variants (`OIT_EYES`, `OIT_ENERGY_SWIRL`, `OIT_DRAGON_RAYS`, shader define OIT_ADDITIVE for the last two, referenced by `RenderTypes.eyes`, `energySwirl` and `dragonRays`) are not specified; plain blending with the blend functions stated in 6.3, 8.5 and 8.6 is the assumed equivalent (inferred). Searched: `RenderPipelines` registrations only.
5. Entity-side formulas were read only where renderers consume them (`flapTime`, flight history recording, `Strider.isSuffocating`'s derivation: cold when not on or in a warm block (tag), not in lava and not riding a strider that is warm, summarised from `Strider.tick`). Their full ownership is 21 §6.4 and §5.7. The wither skull's rotation interpolation (entity `getYRot(partial)` and `getXRot(partial)` are read) and the skull entity's own tick were not read.
6. Shadow drawing, name tag, leash and bounding-box culling code of `EntityRenderer` is outside this round (10.1 assigns it to 34-1 section 7); only the radius values were read.
7. The dragon `DRAGON_SKULL` layer and the skull block entity renderer (`DragonHeadModel`) were not read.
8. `Mth.sin`/`Mth.cos` tables: only the table index formula and the table fill expression were read; the float rounding of `float(sin(...))` is assumed to be the usual round-to-nearest.
9. The `WitherBoss` flicker (`n div 5` odd/even) and the 220 / 80 tick constants of the spawn phase were read from the renderer only; the entity's own `invulnerableTicks` countdown is 21 §7.2.
10. The end crystal pose arithmetic of 11.6 puts the base slab below the entity origin (-1.0 to -0.5 block) and the glass 0.4 to 1.4 above it. The renderer was read exactly; `EndCrystalItem.useOn` spawns at the empty block above the clicked block and sets `showBottom` false, so placed crystals do not draw the base slab; crystals spawned otherwise (for example by the dragon fight) were not checked against 21 §6.3.
11. Coverage note (2026-11-08): a fresh review re-read the `ModelPart$Cube` corner definitions and face count, the `MeshTransformer.scaling` behaviour, the fireball shadow default and the blaze t = 10 values against the jar. The per-face UV rectangles and vertex slot tables of 1.2 were not individually re-derived in that review; they agree with the existing 12 and 14 references and should be confirmed by the next reviewer. The OIT items (Open question 4) and the draw order (Open question 3) remain unspecified. Not covered by this document: the Wither Skeleton (34-2), the happy ghast (reuses the tentacle animation, 34-4) and the `DRAGON_SKULL` block-entity model (Open question 7).
