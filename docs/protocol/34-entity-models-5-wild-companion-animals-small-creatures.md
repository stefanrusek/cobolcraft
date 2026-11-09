# 34 part 5. Entity models and renderers: wild and companion animals and small creatures

| | |
|---|---|
| Covers | The models (mesh, texture size, baby variant), per-frame pose formulas, keyframe animations, render-state extraction, texture selection rules, layers and renderer constants of: wolf (adult, baby, collar layer, armor layer), cat and ocelot (adult, baby, collar layer), fox (adult, baby, held item), panda (adult, baby, held item, roll and sit transforms), polar bear (adult, baby), parrot (including the on-shoulder layer), bat, bee (adult, baby), armadillo (adult, baby), frog, tadpole, turtle (adult, baby) and sniffer (adult, snifflet). Also the entity-side interpolation helpers that feed the render states of these mobs. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: the model classes of `net.minecraft.client.model.animal.{wolf,feline,fox,panda,polarbear,parrot,bee,armadillo,frog,sniffer,turtle}` and `...model.ambient.BatModel`; `LayerDefinitions.createRoots`; the animation classes `FoxBabyAnimation`, `BatAnimation`, `FrogAnimation`, `ArmadilloAnimation`, `BabyArmadilloAnimation`, `SnifferAnimation` and the framework classes `AnimationDefinition`, `AnimationChannel`, `Keyframe`, `KeyframeAnimation`, `KeyframeAnimations`, `AnimationState`; the renderers, layers and render states of the same mobs; the base classes `ModelPart`, `PartPose`, `CubeListBuilder`, `CubeDefinition`, `PartDefinition`, `MeshTransformer`, `QuadrupedModel`, `LivingEntityRenderer`, `AgeableMobRenderer`, `Mth`; and the entity classes only for the helpers that the render states call. Keyframe tables and mesh tables were produced from the bytecode by a script that evaluates the constant pushes and the builder calls (a scratch tool of this round, not part of the repository), and the keyframe and channel counts of every table were checked against the bytecode counts (see Validation). |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001; design README Parts 0, 1, 4; GAP-25). Texture files, equipment asset JSON, cat and frog variant JSON are **data** (extracted by the tool into a resource pack, 22): this document gives the code-defined texture selection rules and path names, never pixels. Everything that is code (meshes, formulas, keyframes, constants) is complete here. |

Conventions. They are those of 34-entity-models-1 section 1 (model conventions) and 34-entity-models-2 section 1.1 (pose application): model units are pixels (1/16 block), x to the model's left,
y down, z to the front, angles in radians unless a row says degrees. A cuboid is written `[u,v] (x,y,z) w×h×d`: texture
offset, origin and size; `grow g` expands every face by g pixels without changing the UV rectangle (14 §5.3); `grow D`
means "the deformation passed to the mesh function" (see the mesh function's row); `mirror` flips the cuboid left to right.
A part pose is `pos(x,y,z) rot(rx,ry,rz)` and the part scale is 1 unless a row says otherwise. All float constants were
read as single-precision values. "State" is the render state the renderer fills each frame. Part paths are written from
the model root (`head/real_head` is the child `real_head` of the root child `head`). A cuboid with a quoted name carries
that name in the artifact (the name has no effect on rendering).

---

## 1. Shared facts used by every model below

### 1.1 What 34-entity-models-1 and 34-entity-models-2 already specify

The pose application order (translate by pos/16, rotate with Z first then Y then X, then scale), `resetPose` at the start of
every `setupAnim` (so every "+=" below is relative to the part's initial pose from the mesh), `visible` and `skipDraw`
semantics, and the box unwrap (14 §5.3) are in 34-entity-models-2 section 1.1, 34-entity-models-1 section 1.5 and 14 §5.3. This document does not repeat them. Facts read
again in this round that those documents may not state:

| Fact | Detail (read from) |
|---|---|
| Pose scale and mesh scaling | `MeshTransformer.scaling(s)` replaces only the **root** part's pose by `scaled(s)` then `translated(0, 24.016 x (1 - s), 0)`: the root position is multiplied by s, the root scale becomes s, then y is increased by 24.016 x (1 - s). Child poses are not touched. The effect is that the whole model is scaled by s about the ground point (y = 24.016 texels). Used by the adult cat (0.8), the cat collar layer (0.8), the baby cat collar layer (1.01) and the adult polar bear (1.2). (`MeshTransformer`, `PartDefinition.transformed`) |
| Part pose scale | `PartPose.scaled(sx,sy,sz)` multiplies position and scale; rotation unchanged. `translated` adds to position only. |
| Cuboid unwrap | Faces are generated in the order down, up, west, north, east, south and the texture rectangles are those of 14 §5.3. Mirroring swaps the two x extents of the box and reverses the vertex order of each face, and flips the normals of the x-facing faces; the six texture rectangles are the same as without mirroring (inferred from the constructors; no reference render was made, Open question 2). (`ModelPart$Cube`, `ModelPart$Polygon`) |
| Texture UV | A vertex's U = texel x / declared texture width, V = texel y / declared texture height, with the width and height of the `LayerDefinition` (`LayerDefinition.create(mesh, w, h)`). Texture offsets are integers; negative offsets occur (baby bee wing, baby turtle legs) and simply index outside the image to the left or top (an implementation must wrap or clamp as the engine's texture sampler does, 14 §5.2; Open question 1). |
| Builder state | `CubeListBuilder` keeps a current texture offset and a mirror flag that apply to every later `addBox` on the same builder until changed; a builder variable reused for several parts shares its cuboids (the right and left leg of most models). The default texture offset is (0, 0). `addBox(name, x,y,z, w,h,d, u,v)` sets the texture offset to (u, v) as it adds. |
| Model-to-world frame | The renderer applies, in order: the entity's scale; the entity rotation (body yaw, `setupRotations`); scale (-1, -1, 1); the renderer's own `scale` hook (no-op for every mob in this document); a translation of (0, -1.501, 0) blocks. Model y therefore grows downward and the model's ground plane is y = 24 texels (1.5 blocks) below the entity origin. (`LivingEntityRenderer.submit`) |
| Name tag, hitbox, eye height, leash, fire | Generic: name tag position, leash drawing and fire are in 34-entity-models-1 sections 7.2, 7.3 and 7.4; bounding box, eye height and name tag offsets of every entity type are in 18 section 1 (for example the sniffer name tag y). The renderer classes of all 14 mobs here override none of scale, name tag, leash, fire or `shouldShowName` (Open question 7, closed as read); per-mob leash offsets in the entity classes remain unenumerated. |
| No scale hook | Among the mobs of this document no renderer overrides the `scale` hook: the model-to-world frame row above states it for all of them, and the bat renderer class (`BatRenderer`) was read for this round and declares only its constructor (shadow radius 0.25), texture and state extraction, so the bat has no fixed scale. The same holds for every renderer table below, which lists only shadow radius and texture. |
| Shadow radius | `getShadowRadius(state)` = renderer radius x `state.scale`. Per-mob radii are in each section's renderer table. Among the mobs of this document only the turtle overrides it (baby x 0.83). |
| Baby selection | `AgeableMobRenderer.submit` swaps `model` to the baby model when `state.isBaby` and to the adult model otherwise, then draws. Adult and baby are different layer definitions (different meshes), not a scaled adult. |
| `ageScale` | `state.ageScale` = 0.5 when the entity `isBaby`, otherwise 1 (`LivingEntity.getAgeScale`). Several pose formulas multiply their y/z offsets by it. `isBaby` = the mob can be a baby and its age is negative. |
| Head look | `state.yRot` = wrapDegrees(head yaw - body yaw) (negated when upside down), `state.xRot` = pitch in degrees. Models convert with x 0.017453292 (degrees to radians). |
| Walk values | `walkAnimationPos` and `walkAnimationSpeed` come from the entity's walk animator (position and speed at the partial tick); both are 0 while the entity is a passenger or dead. |
| `rotLerp` quirk | `Mth.rotLerp(t, a, b)` = a + t x wrapDegrees(b - a) with the wrap done in **degrees** (to within +-180) even where a and b are radians. Every use below passes radian values whose difference is far below 180, so it behaves as the plain lerp a + t(b - a). `Mth.rotLerpRad(t, a, b)` wraps the difference to (-pi, pi). `Mth.lerp(t, a, b)` = a + t(b - a). |
| `Mth.sin`, `Mth.cos` | Table based: the table entry i holds sin(i / 10430.378350470453); `sin(x)` reads entry (int)(x x 10430.378350470453) AND 65535 and `cos(x)` reads entry (int)(x x 10430.378350470453 + 16384.0) AND 65535. The table has **65536** entries (read: `Mth`'s static initialiser allocates a float array of 65536; constants SIN_QUANTIZATION 65536, SIN_MASK 65535, COS_OFFSET 16384, SIN_SCALE 10430.378350470453) Results equal the true functions to about 1e-4; the worked examples quote true values and say so. |

### 1.2 Keyframe animation engine (`KeyframeAnimation`, `AnimationChannel`, `Keyframe`, `AnimationState`)

Used by the fox baby, bat, frog, armadillo and sniffer. Data shape: an `AnimationDefinition` has a length in seconds, a
looping flag, and a map from **part name** to a list of channels. A channel has a target (position, rotation or scale) and
an ordered list of keyframes (time in seconds, value vector, interpolation). Part names are looked up in a table built by
`ModelPart.createPartLookup`: the name `root` is the model root and every other name is a part's own child name
anywhere in the tree (not a path); a missing name is an error.

Authoring conventions (`KeyframeAnimations`): rotation values are authored in **degrees** and converted (x pi/180);
position values are authored in texels with the **y component negated** when stored (authored y +1 moves the part up one
texel on screen, which is model y minus 1); scale values are authored as the final scale factor and stored as
(factor - 1), because every channel is applied **additively**: after `resetPose`, a channel adds its sampled vector to
the part's position, rotation or scale (`ModelPart.offsetPos`, `offsetRotation`, `offsetScale`). The tables in this document §15 list
the authored values.

Sampling a channel at elapsed seconds t with a scale factor k:

1. If the definition loops, t is replaced by t modulo the length; otherwise it is used as is (it may exceed the last
   keyframe, which then holds).
2. i = (number of leading keyframes whose time is strictly less than t) - 1, but at least 0; j = min(last, i + 1). So at t
   before the first keyframe, i = j = 0, and past the last keyframe i = j = last.
3. f = clamp((t - time_i) / (time_j - time_i), 0, 1); f = 0 when i = j.
4. The interpolation of the **later** keyframe j selects the method. LINEAR: value = lerp(f, post_i, pre_j) per component.
   CATMULLROM: for each component, the Catmull-Rom spline with f and the four values post of the keyframes
   max(0, i-1), i, j, min(last, j+1): 0.5 x (2 p1 + (p2 - p0) f + (2 p0 - 5 p1 + 4 p2 - p3) f^2 + (3 p1 - p0 - 3 p2 + p3) f^3).
   In this artifact's tables the "pre" and "post" vectors of every keyframe are equal.
5. The sampled vector is multiplied by k and added to the part's pose through the target.

Entry points:

| Call | Elapsed time t (seconds) and k |
|---|---|
| `applyStatic()` | t = 0, k = 1 |
| `applyWalk(pos, speed, posFactor, speedFactor)` | t = (long)(pos x 50 x posFactor) / 1000 (a whole number of milliseconds), k = min(speed x speedFactor, 1). The result is wrapped by the loop rule of step 1 (the walk animations loop). |
| `apply(AnimationState s, ageInTicks)` and the 3-argument form | nothing when the state is not started; otherwise t = (long)((ageInTicks - startTick) x 50) / 1000 and k = 1 (the 3-argument form multiplies the milliseconds by its factor, not used here). |

`AnimationState`: `startTick` is "stopped" (value -2147483648) until `start(tick)`; `startIfStopped`, `stop`, `animateWhen(flag, tick)`
(start-if-stopped when true, stop when false) and `fastForward(ticks, speed)` (moves the start back by (int)(ticks x speed)
ticks, only when started) are the operations. The render state copies the entity's states each frame (`copyFrom`), so the
time base is the entity's `tickCount` (set when the entity starts the state) against the render state's `ageInTicks`.

### 1.3 Quadruped base (`QuadrupedModel`) as used by the polar bear, panda and turtle

Parts read: `head`, `body`, `right_hind_leg`, `left_hind_leg`, `right_front_leg`, `left_front_leg`. Base `setupAnim` (after
`resetPose`): `head.xRot = state.xRot x 0.017453292`, `head.yRot = state.yRot x 0.017453292`; with p = walkAnimationPos and
s = walkAnimationSpeed: right hind leg xRot = cos(0.6662 p) x 1.4 s; left hind leg xRot = cos(0.6662 p + pi) x 1.4 s;
right front leg xRot = cos(0.6662 p + pi) x 1.4 s; left front leg xRot = cos(0.6662 p) x 1.4 s. The base mesh builder
`QuadrupedModel.createBodyMesh` is not used by these three (each has its own mesh below).

### 1.4 Dye colours used by collars

`DyeColor.getTextureDiffuseColor()` returns the stored field `textureDiffuseColor`, which the `DyeColor` constructor builds from the constant's first int through `ARGB.opaque` (alpha forced to 255); the RGB values of this table are those first ints (RGB hex). The wolf and cat collar
layers tint their collar texture with it.

| id | name | RGB | id | name | RGB |
|---|---|---|---|---|---|
| 0 | white | F9FFFE | 8 | light_gray | 9D9D97 |
| 1 | orange | F9801D | 9 | cyan | 169C9C |
| 2 | magenta | C74EBD | 10 | purple | 8932B8 |
| 3 | light_blue | 3AB3DA | 11 | blue | 3C44AA |
| 4 | yellow | FED83D | 12 | brown | 835432 |
| 5 | lime | 80C71F | 13 | green | 5E7C16 |
| 6 | pink | F38BAA | 14 | red | B02E26 |
| 7 | gray | 474F52 | 15 | black | 1D1D21 |

---

## 2. Wolf (`WolfModel`, `AdultWolfModel`, `BabyWolfModel`, `WolfRenderer`, `WolfCollarLayer`, `WolfArmorLayer`, `WolfRenderState`)

### 2.1 Meshes

Adult: `AdultWolfModel.createBodyLayer(D)`, texture size **64 x 32**, deformation D = none for the body layer
(`ModelLayers.WOLF`) and D = 0.2 for the armor layer (`ModelLayers.WOLF_ARMOR`, same mesh grown by 0.2 on every cuboid
that carries `grow D`; every cuboid of the adult wolf does).

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `head` | pos(-1,13.5,-7) | (no cubes) |
| `head/real_head` | - | [0,0] (-2,-3,-2) 6×6×4 grow D; [16,14] (-2,-5,0) 2×2×1 grow D; [16,14] (2,-5,0) 2×2×1 grow D; [0,10] (-0.5,-0.001,-5) 3×3×4 grow D |
| `body` | pos(0,14,2) rot(1.5707964,0,0) | [18,14] (-3,-2,-3) 6×9×6 grow D |
| `upper_body` | pos(-1,14,-3) rot(1.5707964,0,0) | [21,0] (-3,-3,-3) 8×6×7 grow D |
| `right_hind_leg` | pos(-2.5,16,7) | [0,18] (0,0,-1) 2×8×2 grow D mirror |
| `left_hind_leg` | pos(0.5,16,7) | [0,18] (0,0,-1) 2×8×2 grow D |
| `right_front_leg` | pos(-2.5,16,-4) | [0,18] (0,0,-1) 2×8×2 grow D mirror |
| `left_front_leg` | pos(0.5,16,-4) | [0,18] (0,0,-1) 2×8×2 grow D |
| `tail` | pos(-1,12,8) rot(0.62831855,0,0) | (no cubes) |
| `tail/real_tail` | - | [9,18] (0,0,-1) 2×8×2 grow D |

The root children read by `WolfModel` are `head`, `body`, `right_hind_leg`, `left_hind_leg`, `right_front_leg`,
`left_front_leg`, `tail`; the adult adds `real_head` (child of `head`), `upper_body` (a root child) and `real_tail` (child
of `tail`). `head` and `tail` are empty pivots; the visible head and tail are their children. The wolf's own head cuboid
list has the three cuboids at the head (skull, two ears) and the snout (the 4th); the first leg builder is the left one
(not mirrored) and the right legs use a mirrored copy.

Baby: `BabyWolfModel.createBodyLayer()`, texture **32 x 32**, no deformation parameter (the `0.025` and `0` grows are
literal):

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `head` | pos(0,18.25,-4) | [0,12] (-2.99,-3.25,-3) 6×5×5 grow 0.025; [17,12] (-1.5,-0.24,-5) 3×2×2 |
| `head/right_ear` | pos(-2,-4.25,-0.5) | [0,5] (-1,-1,-0.5) 2×2×1 |
| `head/left_ear` | pos(2,-4.25,-0.5) | [20,5] (-1,-1,-0.5) 2×2×1 |
| `body` | pos(0,19,0) | [0,0] (-3,-2,-4) 6×4×8 |
| `right_hind_leg` | pos(-1.5,21,3) | [0,22] (-1,0,-1) 2×3×2 |
| `left_hind_leg` | pos(1.5,21,3) | [8,22] (-1,0,-1) 2×3×2 |
| `right_front_leg` | pos(-1.5,21,-3) | [0,0] (-1,0,-1) 2×3×2 |
| `left_front_leg` | pos(1.5,21,-3) | [20,0] (-1,0,-1) 2×3×2 |
| `tail` | pos(0,19,3) rot(-0.5236,0,0) | (no cubes) |
| `tail/tail_r1` | pos(0,-0.6,0.2) rot(-3.1,0,0) | [22,16] (-1,-5.7,-1) 2×6×2 |

The baby has no `real_head`, `upper_body` or `real_tail` parts (its `head` and `tail` carry the cuboids or the
`tail_r1` child). The baby has no armor layer rendering (this document §2.4).

### 2.2 Per-frame pose (`WolfModel.setupAnim`)

After `resetPose`, with p = walkAnimationPos, s = walkAnimationSpeed:

1. `tail.yRot` = 0 when the state is angry, otherwise cos(0.6662 p) x 1.4 s.
2. If sitting: the sitting pose of step 3. Otherwise the four legs: right hind xRot = cos(0.6662 p) x 1.4 s; left hind =
   cos(0.6662 p + pi) x 1.4 s; right front = cos(0.6662 p + pi) x 1.4 s; left front = cos(0.6662 p) x 1.4 s.
3. Shake-off roll (`shakeOffWater`, always, called after the legs and before the head look): see this document §2.3. It writes only `zRot` values, so its position in the order does not change the result.
4. `head.xRot` = state.xRot x 0.017453292, `head.yRot` = state.yRot x 0.017453292 (on `head`, not `real_head`).
5. `tail.xRot` = state.tailAngle (the angry or tame tail angle of §2.5; the sitting pose does not write `tail.xRot`, it only offsets the tail y and z).

Sitting pose, with a = ageScale. Common part (both ages): body y += 4a, body z -= 2a, body xRot = 0.7853982;
tail y += 9a, tail z -= 2a; right and left hind leg y += 6.7a, z -= 5a, xRot = 4.712389; right and left front leg
xRot = 5.811947, right front leg x += 0.01a, left front leg x -= 0.01a, both front legs y += 1a. Then per age:

| Age | Extra |
|---|---|
| Adult | `upper_body.y += 2` (not scaled by a), `upper_body.xRot` = 1.2566371, `upper_body.yRot` = 0 |
| Baby | `body.xRot` = (the 0.7853982 set by the common part) - 1.5707964 = -0.7853982 |

### 2.3 Shake-off roll (`shakeOffWater`)

`getBodyRollAngle(extra)`: u = clamp((shakeAnim + extra) / 1.8, 0, 1); result = sin(u pi) x sin(u pi x 11) x 0.15 x pi.
`shakeAnim` is the state's shake counter (0 when not shaking).

| Age | Writes |
|---|---|
| Both (base) | `body.zRot` = rollAngle(-0.16) |
| Adult | in addition `real_head.zRot` = headRollAngle + rollAngle(0), `upper_body.zRot` = rollAngle(-0.08), `real_tail.zRot` = rollAngle(-0.2) |
| Baby | `head.zRot` = headRollAngle + rollAngle(0), `tail.zRot` = rollAngle(-0.2) |

(`headRollAngle` is the interested-head tilt of §2.6.)

### 2.4 Renderer and layers

| Item | Value |
|---|---|
| Models | `ModelLayers.WOLF` (adult), `WOLF_BABY` (baby), shadow radius 0.5 |
| Texture | `state.texture` = `Wolf.getTexture()` (§2.5); the renderer itself does not choose. Selection rule, read from `Wolf.getTexture`: take the wolf's variant; use its **baby** asset set when the wolf is a baby, else its adult asset set; from that set return the `tame` texture if the wolf is tamed, else the `angry` texture if it is angry, else the `wild` texture (so tame wins over angry). Each of the three entries is an asset id from the variant data (`data/minecraft/wolf_variant/*.json`, **9** variants in the artifact: ashen, black, chestnut, pale, rusty, snowy, spotted, striped, woods), fields `assets` and `baby_assets`, each with `angry`, `tame` and `wild`; the texture file is `textures/<asset id path>.png`. Example, pale: adult `entity/wolf/wolf` (wild), `wolf_tame`, `wolf_angry`; baby `entity/wolf/wolf_baby`, `wolf_tame_baby`, `wolf_angry_baby`; ashen: `entity/wolf/wolf_ashen`, `wolf_ashen_tame`, `wolf_ashen_angry` and the `_baby` forms (`wolf_ashen_baby`, `wolf_ashen_tame_baby`, `wolf_ashen_angry_baby`). `textures/entity/wolf/wolf.png` is only the default value of the render-state field, overwritten every frame |
| Model tint | `state.wetShade` (§2.6) as grey: ARGB (1, w, w, w); when w = 1 the tint is "white" (no tint) |
| Collar layer | drawn when `collarColor` is set (the wolf is tamed) and the entity is not invisible: texture `textures/entity/wolf/wolf_collar.png` (baby: `textures/entity/wolf/wolf_collar_baby.png`), the **parent model in its current pose** (adult or baby), cutout render type, tinted with the dye's diffuse colour (§1.4), no overlay, layer order 1 |
| Armor layer | skipped when the body armor item has no `equippable` component, the component has no asset id, or the wolf is a baby. Otherwise: render the equipment layers of type `WOLF_BODY` for the item's asset id with the **adult armor model** (`ModelLayers.WOLF_ARMOR`, grown 0.2) posed from the same state (the armor model runs its own `setupAnim`, with the adult formulas of §2.2 and §2.3); dyed leather is the equipment renderer's business (34-entity-models-1 section 8.2). Then the crack overlay: level = `Crackiness.WOLF_ARMOR.byDamage(item)`; none for non-damageable items; the overlay texture is `textures/entity/wolf/wolf_armor_crackiness_{low,medium,high}.png`, drawn with the armor model in the "wolf armor cracks" render type. The overlay is submitted on its own ordered submit node with **order 1** (read: the constant pushed before the `order` call in `WolfArmorLayer.maybeRenderCracks`), i.e. after the order-0 equipment layers drawn by the same layer |
| Crackiness | fraction f = (maxDamage - damage) / maxDamage as a float; level = HIGH when f < 0.32, else MEDIUM when f < 0.69, else LOW when f < 0.95, else NONE (`Crackiness.WOLF_ARMOR` fractions low 0.95, medium 0.69, high 0.32; the golem's are 0.75, 0.5, 0.25) |

### 2.5 State extraction (`WolfRenderer.extractRenderState`)

| Field | Source |
|---|---|
| `isAngry` | `Wolf.isAngry()` |
| `isSitting` | `isInSittingPose()` |
| `tailAngle` | `Wolf.getTailAngle()`: 1.5393804 when angry; else when tamed (maxHealth - health) / maxHealth = d and the angle is (0.55 - 0.4 d) x pi; else 0.62831855 (the default of the field too) |
| `headRollAngle` | `getHeadRollAngle(t)` = lerp(t, interestedAngleO, interestedAngle) x 0.15 x pi |
| `shakeAnim` | `getShakeAnim(t)` = lerp(t, shakeAnimO, shakeAnim) |
| `texture` | `Wolf.getTexture()` |
| `wetShade` | `getWetShade(t)`: 1 when the wolf is not wet; else min(0.75 + (lerp(t, shakeAnimO, shakeAnim) / 2) x 0.25, 1) |
| `collarColor` | the collar dye when tamed, otherwise none |
| `bodyArmorItem` | a copy of the body armor stack |

### 2.6 Entity-side counters feeding §2.5 (`Wolf.tick`, `handleEntityEvent`)

Every tick of a living wolf: `interestedAngleO` = `interestedAngle`; `interestedAngle` moves 0.4 of the way to 1 when the wolf
is interested (head tilted) and 0.4 of the way to 0 otherwise. Wetness (each tick): if in water or rain, `isWet` is set; if a shake was in progress, the server (only) broadcasts entity event 56 and cancels the shake. Otherwise, if `isWet` or `isShaking`, and `isShaking` is true (the per-tick shake block runs only under that gate): the first tick (shakeAnim = 0) plays the shake sound;
each tick `shakeAnimO` = `shakeAnim`, `shakeAnim` += 0.05; when `shakeAnimO` >= 2 the wolf becomes dry and the counters reset to 0;
while `shakeAnim` > 0.4 the client spawns (int)(sin((shakeAnim - 0.4) pi) x 7) splash particles per tick at height y + 0.8
within +-0.5 body width (uniform). The shake starts server side in `aiStep` when wet, not shaking, not path-finding and on the
ground (counters 0, event 8 broadcast); event 8 starts the shake on clients, event 56 cancels it.

---

## 3. Cat and ocelot (`AbstractFelineModel`, `AdultFelineModel`, `BabyFelineModel`, `AdultCatModel`, `AdultOcelotModel`, `BabyCatModel`, `BabyOcelotModel`, `CatRenderer`, `OcelotRenderer`, `CatCollarLayer`, `FelineRenderState`, `CatRenderState`)

### 3.1 Meshes

All feline models read the root children `head`, `body`, `tail1`, `tail2`, `left_hind_leg`, `right_hind_leg`, `left_front_leg`,
`right_front_leg` (`AbstractFelineModel`).

Adult mesh `AdultFelineModel.createBodyMesh(D)`, texture **64 x 32**. Layer definitions: ocelot = D none, no transformer;
cat = D none then `MeshTransformer.scaling(0.8)` (`AdultCatModel.CAT_TRANSFORMER`); cat collar =
D = `CubeDeformation(0.01)` (`AdultCatModel.COLLAR_DEFORMATION`) then scaling 0.8. The `tail2` cuboid uses its own grow of
-0.02 regardless of D.

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `head` | pos(0,15,-9) | [0,0] (-2.5,-2,-3) 5×4×5 grow D "main"; [0,24] (-1.5,-0.001,-4) 3×2×2 grow D "nose"; [0,10] (-2,-3,0) 1×1×2 grow D "ear1"; [6,10] (1,-3,0) 1×1×2 grow D "ear2" |
| `body` | pos(0,12,-10) rot(1.5707964,0,0) | [20,0] (-2,3,-8) 4×16×6 grow D |
| `tail1` | pos(0,15,8) rot(0.9,0,0) | [0,15] (-0.5,0,0) 1×8×1 grow D |
| `tail2` | pos(0,20,14) | [4,15] (-0.5,0,0) 1×8×1 grow -0.02 |
| `left_hind_leg` | pos(1.1,18,5) | [8,13] (-1,0,1) 2×6×2 grow D |
| `right_hind_leg` | pos(-1.1,18,5) | [8,13] (-1,0,1) 2×6×2 grow D |
| `left_front_leg` | pos(1.2,14.1,-5) | [40,0] (-1,0,0) 2×10×2 grow D |
| `right_front_leg` | pos(-1.2,14.1,-5) | [40,0] (-1,0,0) 2×10×2 grow D |

Baby mesh `BabyFelineModel.createBabyLayer()`, texture **32 x 32**, shared by `BabyCatModel` and `BabyOcelotModel` (no
deformation). `tail2` is an empty part. Baby cat collar layer = the same mesh with `MeshTransformer.scaling(1.01)`
(`BabyCatModel.COLLAR_TRANSFORMER`).

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `head` | pos(0,20,-3.125) | [0,0] (-2.5,-3,-2.875) 5×4×4; [18,0] (-2,-4,-0.875) 1×1×2; [24,0] (1,-4,-0.875) 1×1×2; [18,3] (-1.5,-1,-3.875) 3×2×1 |
| `left_front_leg` | pos(1,22,-1.5) | [18,18] (-0.5,0,-1) 1×2×2 |
| `right_front_leg` | pos(-1,22,-1.5) | [12,18] (-0.5,0,-1) 1×2×2 |
| `left_hind_leg` | pos(1,22,2.5) | [18,22] (-0.5,0,-1) 1×2×2 |
| `body` | pos(0,20.5,0.5) | [0,8] (-2,-1.5,-3.5) 4×3×7 |
| `right_hind_leg` | pos(-1,22,2.5) | [12,22] (-0.5,0,-1) 1×2×2 |
| `tail1` | pos(0,19.107,3.9151) rot(-0.567232,0,0) | [0,18] (-0.5,-0.107,0.0849) 1×1×5 |
| `tail2` | - | (no cubes) |

### 3.2 Per-frame pose, adult (`AdultFelineModel.setupAnim`)

Let a = ageScale, p = walkAnimationPos, s = walkAnimationSpeed, and c(x) = cos(x).

1. Crouching: body y += 1a; head y += 2a; tail1 y += 1a; tail2 y += -4a; tail2 z += 2a; tail1.xRot = tail2.xRot = 1.5707964.
   Else if sprinting: tail2.y = tail1.y (the **current** value, after reset); tail2 z += 2a; tail1.xRot = tail2.xRot = 1.5707964.
2. `head.xRot` = state.xRot x 0.017453292, `head.yRot` = state.yRot x 0.017453292.
3. If not sitting: `body.xRot` = 1.5707964, and the legs and tail tip by gait:
   - sprinting: left hind xRot = c(0.6662 p) s; right hind = c(0.6662 p + 0.3) s; left front = c(0.6662 p + pi + 0.3) s;
     right front = c(0.6662 p + pi) s; tail2.xRot = 1.7278761 + 0.31415927 c(p) s.
   - otherwise: left hind = c(0.6662 p) s; right hind = c(0.6662 p + pi) s; left front = c(0.6662 p + pi) s; right front =
     c(0.6662 p) s; and, only when **not** crouching, tail2.xRot = 1.7278761 + 0.7853982 c(p) s; when crouching tail2.xRot =
     1.7278761 + 0.47123894 c(p) s.
4. If sitting: body.xRot = 0.7853982; body y += -4a, z += 5a; head y += -3.3a, z += 1a; tail1 y += 8a, z += -2a; tail2 y += 2a,
   z += -0.8a; tail1.xRot = 1.7278761; tail2.xRot = 2.670354; each front leg: xRot = -0.15707964, y += 2a, z -= 2a; each hind
   leg: xRot = -1.5707964, y += 3a, z -= 4a.
5. Lying (lieDownAmount L > 0): head.zRot = rotLerp(L, head.zRot, -1.2707963); head.yRot = rotLerp(L, head.yRot, 1.2707963);
   left front xRot = -1.2707963; right front xRot = -0.47079635, zRot = -0.2, x += a; left hind xRot = -0.4; right hind
   xRot = 0.5, zRot = -0.5, x += 0.8a, y += 2a; tail1.xRot = rotLerp(Lt, tail1.xRot, 0.8); tail2.xRot = rotLerp(Lt, tail2.xRot,
   -0.4) where Lt = `lieDownAmountTail`.
6. Relaxed (relaxStateOneAmount R > 0): head.xRot = rotLerp(R, head.xRot, -0.58177644).

### 3.3 Per-frame pose, baby (`BabyFelineModel.setupAnim`)

Steps 1 and 2 are those of §3.2. Then, if not sitting: the gait of §3.2 step 3 (legs and tail2.xRot only; the baby does
not set `body.xRot`). If sitting: body.xRot += -0.43633232; body y += 1.25; head z += 0.75; tail1.xRot += 0.5454154; tail1 y +=
4.0; tail1 z -= 0.9; both hind legs z -= 0.9 (no scaling by a). Lying (L > 0): body x += 1; head.xRot = rotLerp(L, head.xRot,
0.17453292); head.zRot = rotLerp(L, head.zRot, -1.3089969); head x += 1.5, y += 0.75, z -= 0.5; right front xRot = -0.7853982,
x += 3.5, y -= 0.5; left front xRot = -1.5707964, x += 1.5, y -= 1, z -= 2; right hind xRot = 0.6981317, yRot = 0.34906584,
zRot = -0.34906584, x += 2.5, y -= 0.25, z += 0.5; left hind x += 1.5, z -= 1; tail1.xRot += rotLerp(Lt, tail1.xRot,
-0.5235988) (the baby **adds** the interpolated value to the current xRot), tail1.yRot += rotLerp(Lt, tail1.yRot, 0),
tail1.zRot += rotLerp(Lt, tail1.zRot, -0.17453292), tail1 x += 1, y += 0.5, z -= 0.25. Relaxed: head.xRot = rotLerp(R,
head.xRot, -0.58177644).

### 3.4 Renderers and layers

| Item | Cat | Ocelot |
|---|---|---|
| Models | `ModelLayers.CAT` / `CAT_BABY` | `OCELOT` / `OCELOT_BABY` |
| Shadow radius | 0.4 | 0.4 |
| Texture | `state.texture` = the cat variant's `assetInfo(isBaby).texturePath()` (data, from the cat variant registry: the variant JSON fields `asset_id` and `baby_asset_id`, for example `entity/cat/cat_tabby` and `entity/cat/cat_tabby_baby`, 11 variants, path `textures/<id>.png`; default `textures/entity/cat/cat_tabby.png`) | adult `textures/entity/cat/ocelot.png`, baby `textures/entity/cat/ocelot_baby.png` |
| Layers | collar layer (below) | none |
| Extra body transform (`setupRotations`) | when lieDownAmount L > 0: translate (0.4 L, 0.15 L, 0.1 L) blocks, then rotate about Z by rotLerp(L, 0, 90) degrees; and when the cat lies on top of a sleeping player, an additional translate (0.15 L, 0, 0) | none |

Cat collar layer: drawn when `collarColor` is set; model = a separate collar model baked from `CAT_COLLAR` (adult) or
`CAT_BABY_COLLAR` (baby), posed by the same state (`coloredCutoutModelCopyLayerRender`); texture
`textures/entity/cat/cat_collar.png` (baby `textures/entity/cat/cat_collar_baby.png`); tinted with the dye's diffuse colour
(§1.4); the collar model is the cat mesh grown by 0.01 (adult) or scaled by 1.01 (baby) so that it covers the body.

State extraction. Ocelot: `isCrouching`, `isSprinting` (the other feline fields keep their defaults: not sitting, no lying,
no relax). Cat: `texture`, `isCrouching`, `isSprinting`, `isSitting` (= `isInSittingPose`), `lieDownAmount`
= `getLieDownAmount(t)` = lerp(t, O, current), `lieDownAmountTail`, `relaxStateOneAmount` (same lerp form),
`isLyingOnTopOfSleepingPlayer`, and `collarColor` (set only when tamed).

### 3.5 Cat counters feeding §3.4 (`Cat.handleLieDown`)

(Read in review: `Cat.handleLieDown`, `updateLieDownAmount`, `updateRelaxStateOneAmount`.) Each tick the cat stores the old values and then moves: `lieDownAmount` += 0.15 (max 1) while lying else -= 0.22 (min 0);
`lieDownAmountTail` += 0.08 (max 1) while lying else -= 0.13 (min 0); `relaxStateOneAmount` += 0.1 (max 1) while the relax-one flag
is set else -= 0.13 (min 0). `isLyingOnTopOfSleepingPlayer` is recomputed each tick: true when the cat is lying and any sleeping
player is within the block position inflated by 2 on each axis. While lying or relaxed, a purr sound plays every 5th tick
(`tickCount` modulo 5 = 0).

---

## 4. Fox (`FoxModel`, `AdultFoxModel`, `BabyFoxModel`, `FoxBabyAnimation`, `FoxRenderer`, `FoxHeldItemLayer`, `FoxRenderState`)

### 4.1 Meshes

Both models read root children `head`, `body`, `right_hind_leg`, `left_hind_leg`, `right_front_leg`, `left_front_leg` and
`tail` as the child `tail` of `body`.

Adult `AdultFoxModel.createBodyLayer()`, texture **48 x 32**:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `head` | pos(-1,16.5,-3) | [1,5] (-3,-2,-5) 8×6×6 |
| `head/right_ear` | - | [8,1] (-3,-4,-4) 2×2×1 |
| `head/left_ear` | - | [15,1] (3,-4,-4) 2×2×1 |
| `head/nose` | - | [6,18] (-1,2.01,-8) 4×2×3 |
| `body` | pos(0,16,-6) rot(1.5707964,0,0) | [24,15] (-3,3.999,-3.5) 6×11×6 |
| `right_hind_leg` | pos(-5,17.5,7) | [13,24] (2,0.5,-1) 2×6×2 grow 0.001 |
| `left_hind_leg` | pos(-1,17.5,7) | [4,24] (2,0.5,-1) 2×6×2 grow 0.001 |
| `right_front_leg` | pos(-5,17.5,0) | [13,24] (2,0.5,-1) 2×6×2 grow 0.001 |
| `left_front_leg` | pos(-1,17.5,0) | [4,24] (2,0.5,-1) 2×6×2 grow 0.001 |
| `body/tail` | pos(-4,15,-1) rot(-0.05235988,0,0) | [30,0] (2,0,-1) 4×9×5 |

Baby `BabyFoxModel.createBodyLayer()`, texture **32 x 32**; `babyWalkAnimation` = `FOX_BABY_WALK` (§15.1):

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `head` | pos(0,18.125,0.125) | [0,0] (-3,-2.125,-5.125) 6×5×5; [18,20] (-1,0.875,-7.125) 2×2×2; [22,8] (-3,-4.125,-4.125) 2×2×1; [22,11] (1,-4.125,-4.125) 2×2×1 |
| `right_hind_leg` | pos(-1.5,22,4) | [22,4] (-1,0,-1) 2×2×2 |
| `left_hind_leg` | pos(1.5,22,4) | [22,0] (-1,0,-1) 2×2×2 |
| `right_front_leg` | pos(-1.5,22,0) | [22,4] (-1,0,-1) 2×2×2 |
| `left_front_leg` | pos(1.5,22,0) | [22,0] (-1,0,-1) 2×2×2 |
| `body` | pos(0,20,2) | [0,10] (-2.5,-2,-3) 5×4×6 |
| `body/tail` | pos(0,-0.5,3) | [0,20] (-1.5,-1.48,-1) 3×3×6 |

### 4.2 Per-frame pose (`FoxModel.setupAnim`)

Let p = walkAnimationPos, s = walkAnimationSpeed, a = ageScale, A = ageInTicks, C = crouchAmount (0 to 5).

1. Walking pose (always first): `head.zRot` = state.headRollAngle; the four legs `visible` = true. Adult: right hind leg xRot =
   cos(0.6662 p) x 1.4 s; left hind = cos(0.6662 p + pi) x 1.4 s; right front = cos(0.6662 p + pi) x 1.4 s; left front =
   cos(0.6662 p) x 1.4 s. Baby: `FOX_BABY_WALK.applyWalk(p, s, 1, 2.5)`.
2. Exactly one of (priority order) crouching, sleeping, sitting:
   - Crouching (both ages): body.xRot += 0.10471976; head y += C a; and with w = cos(A) x 0.05: body.yRot = w; right and left hind leg
     zRot = w; right and left front leg zRot = w / 2. Adult in addition: body y += C. Baby in addition: body y += C / 6.
   - Sleeping: the four legs are hidden (`visible` = false). Adult: body.zRot = -1.5707964; body y += 5; tail.xRot = -2.6179938; head x +=
     2, y += 2.99, yRot = -2.0943952, zRot = 0. Baby: body.zRot = -1.5707964, body.xRot = -0.17453292; body y += 1.5, z -= 1.5, x -= 1.5;
     tail.xRot = -2.1816616 (an earlier write of -2.6179938 is overwritten); tail x -= 0.7, z += 0.6, y += 0.9; head x -= 2, y += 2.8,
     z -= 4, yRot = -2.0943952, zRot = 0.
   - Sitting: first `head.xRot` = 0, `head.yRot` = 0 (both ages), then adult: body.xRot = 0.5235988; body y -= 7, z += 3; tail.xRot =
     0.7853982; head y -= 6.5, z += 2.75; both front legs xRot = -0.2617994; both hind legs xRot = -1.3089969, y += 4, z -= 0.25; tail z -= 1.
     Baby: body.xRot = -0.959931; body z -= 4.5a, y += 3a; tail y -= 0.6, z -= 2a, xRot = 0.95993114; head y -= 0.75; front legs xRot =
     -0.2617994, z -= 1.5, right front x += 0.01, left front x -= 0.01; hind legs z -= 3.75, right hind x += 0.01, left hind x -= 0.01.
3. Pouncing (can combine with 2): adult: with h = C / 2: body y -= h, head y -= h. Baby: no change.
4. Head look: unless sleeping, faceplanted or crouching: head.xRot = state.xRot x 0.017453292, head.yRot = state.yRot x 0.017453292.
5. Sleeping again: head.xRot = 0, head.yRot = -2.0943952, head.zRot = cos(0.027 A) / 22.
6. Faceplanted: the model's own counter `legMotionPos` (starts 0, persists across frames, 1 per model instance) increases by 0.67
   **each time setupAnim runs**, then each leg's xRot is overwritten: right hind = cos(0.4662 m) x 0.1; left hind = cos(0.4662 m + pi) x
   0.1; right front = cos(0.4662 m + pi) x 0.1; left front = cos(0.4662 m) x 0.1 where m = legMotionPos.

### 4.3 Renderer, texture, layer

| Item | Value |
|---|---|
| Models, shadow | `ModelLayers.FOX` / `FOX_BABY`, shadow radius 0.4 |
| Body transform | when pouncing or faceplanted: rotate about X by -state.xRot degrees (after the common rotation) |
| Texture rule | variant (red or snow): sleeping state picks the sleep file, else the idle file; baby picks the baby file. Files (all `textures/entity/fox/`): red `fox.png`, `fox_sleep.png`, baby `fox_baby.png`, `fox_sleep_baby.png`; snow `fox_snow.png`, `fox_snow_sleep.png`, baby `fox_snow_baby.png`, `fox_snow_sleep_baby.png`. A variant with no entry falls back to the red adult idle file regardless of age or sleep |
| Held item layer | see §4.4 |

State extraction: held item (the standard holding-entity extraction, main-hand item), `headRollAngle` = `Fox.getHeadRollAngle(t)` =
lerp(t, interestedAngleO, interestedAngle) x 0.11 x pi, `isCrouching` (flag 4), `crouchAmount` = lerp(t, crouchAmountO, crouchAmount),
`isSleeping` (flag 32), `isSitting` (flag 1), `isFaceplanted` (flag 64), `isPouncing` (flag 16), `variant`.

Entity counters (`Fox.tick`, read in review; flag values sitting 1, crouching 4, interested 8, pouncing 16, sleeping 32, faceplanted 64): `interestedAngle` approaches 1 by 0.4 of the remainder per tick when the interested flag (flag 8) is
set, else approaches 0 the same way; `crouchAmount` += 0.2 per tick while crouching (clamped to 5), set to 0 the tick it is not
crouching; both stored as old and current values each tick.

### 4.4 `FoxHeldItemLayer`

Nothing is drawn when the held item is empty. Otherwise, on the pose stack: translate by the **head part's current** (x, y, z) / 16
(so it follows the head pose); baby: scale 0.75 on all axes; rotate about Z by `headRollAngle` (radians), about Y by the layer's yaw
argument (state.yRot, degrees) and about X by the layer's pitch argument (state.xRot, degrees); then translate by:

| | Not sleeping | Sleeping |
|---|---|---|
| Adult | (0.06, 0.27, -0.5) | (0.46, 0.26, 0.22) |
| Baby | (0.06, 0.26, -0.5) | (0.4, 0.26, 0.15) |

then rotate about X by 90 degrees, and, when sleeping, about Z by 90 degrees; then submit the item's model (no overlay).

---

## 5. Panda (`PandaModel`, `BabyPandaModel`, `PandaRenderer`, `PandaHoldsItemLayer`, `PandaRenderState`)

### 5.1 Meshes

Adult `PandaModel.createBodyLayer()`, texture **64 x 64** (a quadruped: `QuadrupedModel` parts, 1.3):

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `head` | pos(0,11.5,-17) | [0,6] (-6.5,-5,-4) 13×10×9; [45,16] (-3.5,0,-6) 7×5×2 "nose"; [52,25] (3.5,-8,-1) 5×4×1 "left_ear"; [52,25] (-8.5,-8,-1) 5×4×1 "right_ear" |
| `body` | pos(0,10,0) rot(1.5707964,0,0) | [0,25] (-9.5,-13,-6.5) 19×26×13 |
| `right_hind_leg` | pos(-5.5,15,9) | [40,0] (-3,0,-3) 6×9×6 |
| `left_hind_leg` | pos(5.5,15,9) | [40,0] (-3,0,-3) 6×9×6 |
| `right_front_leg` | pos(-5.5,15,-9) | [40,0] (-3,0,-3) 6×9×6 |
| `left_front_leg` | pos(5.5,15,-9) | [40,0] (-3,0,-3) 6×9×6 |

Baby `BabyPandaModel.createBodyLayer()`, texture **64 x 64**:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `body` | pos(0,18.5,2.5) | [0,11] (-4.5,-3.5,-5.5) 9×7×11 |
| `head` | pos(0,19,-3) | [0,0] (-3.5,-3,-5) 7×6×5; [24,6] (-2,1,-6) 4×2×1; [24,0] (-4.5,-4,-3.5) 3×3×1; [33,0] (1.5,-4,-3.5) 3×3×1 |
| `right_hind_leg` | pos(-3,22,6.5) | [0,34] (-1.5,0,-1.5) 3×2×3 |
| `left_hind_leg` | pos(3,22,6.5) | [12,34] (-1.5,0,-1.5) 3×2×3 |
| `right_front_leg` | pos(-3,22,-1.5) | [0,29] (-1.5,0,-1.5) 3×2×3 |
| `left_front_leg` | pos(3,22,-1.5) | [12,29] (-1.5,0,-1.5) 3×2×3 |

### 5.2 Per-frame pose (`PandaModel.setupAnim`, runs after the quadruped base of §1.3)

A = ageInTicks. Steps in order:

1. Unhappy: head.yRot = 0.35 sin(0.6 A); head.zRot = 0.35 sin(0.6 A); right front xRot = -0.75 sin(0.3 A); left front xRot =
   0.75 sin(0.3 A). Not unhappy: head.zRot = 0.
2. Sneezing: with n = `sneezeTime` (an integer): if n < 15: head.xRot = (-0.7853982 n) / 14; else if n < 20: head.xRot = -0.7853982 +
   0.7853982 x q where q = integer division (n - 15) / 5 (which is 0 for every n from 15 to 19, so the head holds at -0.7853982 for
   those ticks; read as an integer division in the bytecode).
3. If `sitAmount` S > 0: sitting animation (below); if eating: head.xRot = 1.5707964 + 0.2 sin(0.6 A); both front legs xRot = -0.4 -
   0.2 sin(0.6 A); if scared: head.xRot = 2.1707964, both front legs xRot = -0.9. Else (S = 0): all four leg zRot = 0.
   (The eating and scared overrides are inside the S > 0 branch.)
4. `lieOnBackAmount` B > 0: right hind xRot = -0.6 sin(0.15 A); left hind = 0.6 sin(0.15 A); right front = 0.3 sin(0.25 A); left front =
   -0.3 sin(0.25 A); head.xRot = rotLerpRad(B, head.xRot, 1.5707964).
5. `rollAmount` R > 0: head.xRot = rotLerpRad(R, head.xRot, 2.0561945); right hind = -0.5 sin(0.5 A); left hind = 0.5 sin(0.5 A); right
   front = 0.5 sin(0.5 A); left front = -0.5 sin(0.5 A).

Sitting animation: adult: body.xRot = rotLerpRad(S, body.xRot, 1.7407963); head.xRot = rotLerpRad(S, head.xRot, 1.5707964);
right front zRot = -0.27079642; left front zRot = 0.27079642; right hind zRot = 0.5707964; left hind zRot = -0.5707964. Baby:
body.xRot = rotLerpRad(S, body.xRot, 0.17453292); body z = lerp(S, body.z, -1.5); head z = lerp(S, head.z, -11.5); head y = lerp(S,
head.y, 17.5); both front legs z = lerp(S, z, -5); both hind legs z = lerp(S, z, 3); the four zRot values as for the adult (the baby
does not set head.xRot here).

### 5.3 Body transform (`PandaRenderer.setupRotations`), applied after the common rotation

Let h = 0.3 for a baby and 0.8 for an adult.

1. Roll (`rollTime` r > 0): k = floor(r), f = r - k, k1 = k + 1. An angle function g(a0, a1, limit) = lerp(f, a0, a1) when k1 < limit,
   else a0. Four phases by k:

   | k | a0 | a1 | limit | translate y (blocks) | rotate about X |
   |---|---|---|---|---|---|
   | 0 to 7 | 90 k / 7 | 90 k1 / 7 | 8 | (h + 0.2) x (g / 90) | -g degrees |
   | 8 to 15 | 90 + 90 (k - 8) / 7 | 90 + 90 (k1 - 8) / 7 | 16 | (h + 0.2) + (h - 0.2)(g - 90) / 90 | -g |
   | 16 to 23 | 180 + 90 (k - 16) / 7 | 180 + 90 (k1 - 16) / 7 | 24 | h + h (270 - g) / 90 | -g |
   | 24 to 31 | 270 + 90 (k - 24) / 7 | 270 + 90 (k1 - 24) / 7 | 32 | h (360 - g) / 90 | -g |

   For k >= 32 nothing is applied.
2. Sitting (S > 0): translate (0, 0.8 S, 0); rotate about X by lerp(S, xRot, xRot + 90) degrees; translate (0, -1.0 S, 0); if scared:
   rotate about Y by cos(1.25 A) x pi x 0.05 degrees, and only in that scared case, for a baby, additionally translate (0, 0.8, 0.55) (the translate sits inside the scared branch; a sitting baby that is not scared gets no such translate).
3. Lying on back (B > 0): translate (0, c B, 0) with c = 0.5 (baby) or 1.3 (adult); rotate about X by lerp(B, xRot, xRot + 180) degrees.

### 5.4 Renderer, textures, layer, state

| Item | Value |
|---|---|
| Models, shadow | `PANDA` / `PANDA_BABY`, 0.9 |
| Texture | `state.variant` (a gene) selects from the adult or baby map; an unknown gene uses NORMAL's entry. Adult files in `textures/entity/panda/`: `panda.png` (normal), `panda_lazy.png`, `panda_worried.png`, `panda_playful.png`, `panda_brown.png`, `panda_weak.png`, `panda_aggressive.png`. Baby files: `panda_baby.png` (normal), `lazy_panda_baby.png`, `worried_panda_baby.png`, `playful_panda_baby.png`, `brown_panda_baby.png`, `weak_panda_baby.png`, `aggressive_panda_baby.png` |
| Held item layer | drawn when the held item is non-empty, the panda is sitting and **not** scared: translate (0.1, y, z) blocks with z = -0.6 and y = 1.4, except while eating, z = -0.6 - (0.2 sin(0.6 A) + 0.2) and y = 1.4 - 0.09 sin(0.6 A); then submit the item (no overlay) |

State extraction: held item; `variant` = `Panda.getVariant()` (the gene from the main and hidden genes); `isUnhappy` = unhappy counter > 0;
`isSneezing`; `sneezeTime` = the sneeze counter; `isEating` = eat counter > 0; `isScared` = worried and thundering; `isSitting`;
`sitAmount` = lerp(t, old, current); `lieOnBackAmount` likewise; `rollAmount` = 0 for babies else lerp(t, old, current); `rollTime`
= (rollCounter + t) when rollCounter > 0 else 0.

Entity counters (`Panda.tick`, read in review): `sitAmount` += 0.15 (max 1) while sitting else -= 0.19 (min 0); `onBackAmount` the same constants while on
its back; `rollAmount` the same constants while rolling. Unhappy counter counts down 1 per tick and the sneeze counter counts up per tick, the sneeze ending (`sneeze(false)`, then the after-sneeze step) when the counter is above 20 (read in `Panda.tick`).

---

## 6. Polar bear (`PolarBearModel`, `BabyPolarBearModel`, `PolarBearRenderer`, `PolarBearRenderState`)

Quadruped base (§1.3). Adult `PolarBearModel.createBodyLayer()`, texture **128 x 64**, then `MeshTransformer.scaling(1.2)` (§1.1). Baby
`BabyPolarBearModel.createBodyLayer()`, texture **64 x 64**, no scaling. The baby uses the same `PolarBearModel` pose code (the
renderer instantiates `PolarBearModel` for both layers).

Adult:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `head` | pos(0,10,-16) | [0,0] (-3.5,-3,-3) 7×7×7; [0,44] (-2.5,1,-6) 5×3×3 "mouth"; [26,0] (-4.5,-4,-1) 2×2×1 "right_ear"; [26,0] (2.5,-4,-1) 2×2×1 mirror "left_ear" |
| `body` | pos(-2,9,12) rot(1.5707964,0,0) | [0,19] (-5,-13,-7) 14×14×11; [39,0] (-4,-25,-7) 12×12×10 |
| `right_hind_leg` | pos(-4.5,14,6) | [50,22] (-2,0,-2) 4×10×8 |
| `left_hind_leg` | pos(4.5,14,6) | [50,22] (-2,0,-2) 4×10×8 |
| `right_front_leg` | pos(-3.5,14,-8) | [50,40] (-2,0,-2) 4×10×6 |
| `left_front_leg` | pos(3.5,14,-8) | [50,40] (-2,0,-2) 4×10×6 |

Baby:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `body` | pos(0,17.5,0) | [0,9] (-4,-3.5,-6) 8×7×12 |
| `head` | pos(0,18.625,-5.75) | [0,0] (-3,-2.625,-4.25) 6×5×4; [20,3] (-2,0.375,-6.25) 4×2×2; [20,0] (-4,-3.625,-2.75) 2×2×1; [26,0] (2,-3.625,-2.75) 2×2×1 |
| `right_hind_leg` | pos(-2.5,21.5,4.5) | [0,34] (-1.5,-0.5,-1.5) 3×3×3 |
| `left_hind_leg` | pos(2.5,21.5,4.5) | [12,34] (-1.5,-0.5,-1.5) 3×3×3 |
| `right_front_leg` | pos(-2.5,21.5,-4.5) | [0,28] (-1.5,-0.5,-1.5) 3×3×3 |
| `left_front_leg` | pos(2.5,21.5,-4.5) | [12,28] (-1.5,-0.5,-1.5) 3×3×3 |

Pose (after the quadruped base): with e = standScale x standScale and a = ageScale:
body.xRot -= e pi 0.35; body y += e a 2; right front leg y -= e a 20, z += e a 4, xRot -= e pi 0.45; left front leg y = right front y, z =
right front z, xRot -= e pi 0.45; head y -= e 24, z += e 13, xRot += e pi 0.15. (The head offsets are not scaled by a.)

State: `standScale` = `PolarBear.getStandingAnimationScale(t)` = lerp(t, clientStandOld, clientStand) / 6, where the entity's client counter moves
by 1 per tick toward 6 while standing and toward 0 otherwise, clamped to 0..6 (read in `PolarBear.tick`, client side only).

Renderer: shadow radius 0.9; textures `textures/entity/bear/polarbear.png` (adult) and `textures/entity/bear/polarbear_baby.png` (baby). No layers.

---

## 7. Parrot (`ParrotModel`, `ParrotRenderer`, `ParrotOnShoulderLayer`, `ParrotRenderState`)

### 7.1 Mesh

`ParrotModel.createBodyLayer()`, texture **32 x 32**, root children `body`, `tail`, `left_wing`, `right_wing`, `head`, `left_leg`,
`right_leg`:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `body` | pos(0,16.5,-3) rot(0.4937,0,0) | [2,8] (-1.5,0,-1.5) 3×6×3 |
| `tail` | pos(0,21.07,1.16) rot(1.015,0,0) | [22,1] (-1.5,-1,-1) 3×4×1 |
| `left_wing` | pos(1.5,16.94,-2.76) rot(-0.6981,-3.1415927,0) | [19,8] (-0.5,0,-1.5) 1×5×3 |
| `right_wing` | pos(-1.5,16.94,-2.76) rot(-0.6981,-3.1415927,0) | [19,8] (-0.5,0,-1.5) 1×5×3 |
| `head` | pos(0,15.69,-2.76) | [2,2] (-1,-1.5,-1) 2×3×2 |
| `head/head2` | pos(0,-2,-1) | [10,0] (-1,-0.5,-2) 2×1×4 |
| `head/beak1` | pos(0,-0.5,-1.5) | [11,7] (-0.5,-1,-0.5) 1×2×1 |
| `head/beak2` | pos(0,-1.75,-2.45) | [16,7] (-0.5,0,-0.5) 1×2×1 |
| `head/feather` | pos(0,-2.15,0.15) rot(-0.2214,0,0) | [2,18] (0,-4,-2) 0×5×4 |
| `left_leg` | pos(1,22,-1.05) rot(-0.0299,0,0) | [14,18] (-0.5,0,-0.5) 1×2×1 |
| `right_leg` | pos(-1,22,-1.05) rot(-0.0299,0,0) | [14,18] (-0.5,0,-0.5) 1×2×1 |

### 7.2 Poses (`ParrotModel.getPose`, `prepare`, `setupAnim`)

Pose choice for a parrot entity: party (a jukebox is playing within range) first, else sitting, else flying (`isFlying`), else standing.
The on-shoulder pose is set only by the shoulder layer. Enum order: FLYING, STANDING, SITTING, PARTY, ON_SHOULDER.

`prepare(pose)` (after `resetPose`, before the common code), additive to the initial pose:

| Pose | Writes |
|---|---|
| FLYING | both legs xRot += 0.6981317 |
| STANDING, ON_SHOULDER | nothing |
| SITTING | head, tail, body, both wings, both legs: y += 1.9; tail.xRot += 0.5235988; left wing zRot = -0.0873; right wing zRot = 0.0873; both legs xRot += 1.5707964 |
| PARTY | left leg zRot = -0.34906584; right leg zRot = 0.34906584 |

Then `head.xRot` = state.xRot x 0.017453292 and `head.yRot` = state.yRot x 0.017453292, and by pose (F = state.flapAngle, p, s as before, A = ageInTicks):

| Pose | Writes |
|---|---|
| SITTING | nothing more |
| PARTY | with cs = cos(A), sn = sin(A): head x += cs, y += sn, xRot = 0, yRot = 0, zRot = sin(A) x 0.4; body, tail: x += cs, y += sn; left wing zRot = -0.0873 - F, x += cs, y += sn; right wing zRot = 0.0873 + F, x += cs, y += sn |
| STANDING | first both legs: left leg xRot += cos(0.6662 p) x 1.4 s; right leg xRot += cos(0.6662 p + pi) x 1.4 s; then the common block |
| FLYING, ON_SHOULDER | the common block |

Common block, with v = F x 0.3: head y += v; tail xRot += cos(0.6662 p) x 0.3 s; tail y += v; body y += v; left wing zRot = -0.0873 - F, y += v; right wing zRot =
0.0873 + F, y += v; both legs y += v.

### 7.3 Renderer, state, shoulder layer

| Item | Value |
|---|---|
| Model, shadow | `ModelLayers.PARROT`, 0.3 |
| Texture | by variant: red_blue `textures/entity/parrot/parrot_red_blue.png`, blue `parrot_blue.png`, green `parrot_green.png`, yellow_blue `parrot_yellow_blue.png`, gray `parrot_grey.png` (note the spelling `grey` in the file name); the mapping is exhaustive for the five variants |
| `flapAngle` | (sin(lerp(t, oFlap, flap)) + 1) x lerp(t, oFlapSpeed, flapSpeed) |
| `pose` | `ParrotModel.getPose(entity)` |

Entity flap counters (`Parrot.calculateFlapping`, each tick of `aiStep`): old values stored; `flapSpeed` += f x 0.3 where f = -1 when on the ground
or riding, else 4, then clamped to [0, 1]; `flapping` is raised to 1 when airborne and below 1, then multiplied by 0.9; while airborne and falling
(delta movement y < 0) the delta movement y is multiplied by 0.6; `flap` += `flapping` x 2.

Shoulder layer (`ParrotOnShoulderLayer`, a layer of the player renderer): for each parrot on the left then the right shoulder, a parrot render state is built
with pose ON_SHOULDER, the player's `ageInTicks`, walk position and speed, and the layer's yaw and pitch arguments as the head look. The layer does **not** set `flapAngle`, so F of §7.2 is the field default 0 (the field has no initialiser; read from the render-state class and the layer) and the common block reads v = 0. The
`ParrotModel` is drawn with the variant's texture, with the pose stack translated by (x, y, 0) blocks where x = 0.4 for the left shoulder and -0.4
for the right, and y = -1.3 when the player is crouching, else -1.5.

---

## 8. Bat (`BatModel`, `BatAnimation`, `BatRenderer`, `BatRenderState`)

Mesh `BatModel.createBodyLayer()`, texture **32 x 32**; root children `body`, `head`; `right_wing` (child of body) has child `right_wing_tip`;
`left_wing` / `left_wing_tip` likewise; `feet` is a child of body. Zero-thickness cuboids (depth 0) are flat quads:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `body` | pos(0,17,0) | [0,0] (-1.5,0,-1) 3×5×2 |
| `head` | pos(0,17,0) | [0,7] (-2,-3,-1) 4×3×2 |
| `head/right_ear` | pos(-1.5,-2,0) | [1,15] (-2.5,-4,0) 3×5×0 |
| `head/left_ear` | pos(1.1,-3,0) | [8,15] (-0.1,-3,0) 3×5×0 |
| `body/right_wing` | pos(-1.5,0,0) | [12,0] (-2,-2,0) 2×7×0 |
| `body/right_wing/right_wing_tip` | pos(-2,0,0) | [16,0] (-6,-2,0) 6×8×0 |
| `body/left_wing` | pos(1.5,0,0) | [12,7] (0,-2,0) 2×7×0 |
| `body/left_wing/left_wing_tip` | pos(2,0,0) | [16,8] (0,-2,0) 6×8×0 |
| `body/feet` | pos(0,5,0) | [16,16] (-1.5,0,0) 3×2×0 |

Pose (`BatModel.setupAnim`): if resting, `head.yRot` = state.yRot x 0.017453292; then `BAT_FLYING.apply(flyAnimationState, ageInTicks)` and
`BAT_RESTING.apply(restAnimationState, ageInTicks)` (§1.2; tables in §15.2).

Renderer: shadow radius 0.25; texture `textures/entity/bat/bat.png`; state `isResting` plus copies of the two animation states. Entity side (`Bat.tick`,
`setupAnimationStates`): resting stops the fly state and starts the rest state if stopped (start tick = `tickCount`); not resting does the opposite. A
resting bat also has its delta movement zeroed and its y set to (floor(y) + 1 - bbHeight); a flying bat's delta y is multiplied by 0.6 each tick (entity-side details read in review).

---

## 9. Bee (`BeeModel`, `AdultBeeModel`, `BabyBeeModel`, `BeeStingerModel`, `BeeRenderer`, `BeeRenderState`)

### 9.1 Meshes

Both models read root child `bone`, and from it `body` (with child `stinger`), `right_wing`, `left_wing`, `front_legs`, `middle_legs`,
`back_legs`; the adult also reads `left_antenna` and `right_antenna` (children of `body`). The three leg parts and the wings are
flat (zero thickness) cuboids.

Adult `AdultBeeModel.createBodyLayer()`, texture **64 x 64**:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `bone` | pos(0,19,0) | (no cubes) |
| `bone/body` | - | [0,0] (-3.5,-4,-5) 7×7×10 |
| `bone/body/stinger` | - | [26,7] (0,-1,5) 0×1×2 |
| `bone/body/left_antenna` | pos(0,-2,-5) | [2,0] (1.5,-2,-3) 1×2×3 |
| `bone/body/right_antenna` | pos(0,-2,-5) | [2,3] (-2.5,-2,-3) 1×2×3 |
| `bone/right_wing` | pos(-1.5,-4,-3) rot(0,-0.2618,0) | [0,18] (-9,0,0) 9×0×6 grow 0.001 |
| `bone/left_wing` | pos(1.5,-4,-3) rot(0,0.2618,0) | [0,18] (0,0,0) 9×0×6 grow 0.001 mirror |
| `bone/front_legs` | pos(1.5,3,-2) | [26,1] (-5,0,0) 7×2×0 "front_legs" |
| `bone/middle_legs` | pos(1.5,3,0) | [26,3] (-5,0,0) 7×2×0 "middle_legs" |
| `bone/back_legs` | pos(1.5,3,2) | [26,5] (-5,0,0) 7×2×0 "back_legs" |

Baby `BabyBeeModel.createBodyLayer()`, texture **32 x 32**. The baby's `bone` pivot itself carries two cuboids (the eyes); the baby's
left wing was built with the mirror flag on and switched off after that one cuboid:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `bone` | pos(0,19.6667,-1.8567) | [6,12] (1,-1.6667,-2.1633) 1×2×2; [0,12] (-2,-1.6667,-2.1933) 1×2×2 |
| `bone/body` | pos(0,1.3333,2.3567) | [0,0] (-2,-2,-2.5) 4×4×5 |
| `bone/body/stinger` | pos(0,0.5,2.5) | [13,2] (0,-0.5,0) 0×1×1 |
| `bone/right_wing` | pos(-1,-0.6667,0.8567) rot(0.2182,0.3491,0) | [3,9] (-3,0,0) 3×0×3 |
| `bone/left_wing` | pos(1,-0.6667,0.8567) rot(0.2182,-0.3491,0) | [-3,9] (0,0,0) 3×0×3 mirror |
| `bone/front_legs` | pos(0,3.3333,1.8567) | [13,0] (-1.5,0,0) 3×1×0 |
| `bone/middle_legs` | pos(0,3.3333,2.8567) | [13,1] (-1.5,0,0) 3×1×0 |
| `bone/back_legs` | pos(0,3.3333,3.8567) | [13,2] (-1.5,0,0) 3×1×0 |

Stinger model `BeeStingerModel.createBodyLayer()` (`ModelLayers.BEE_STINGER`), texture **16 x 16**, two crossed flat quads. It is **not** used on the bee:
it is the model of the stingers stuck in a player (the player renderer's `BeeStingerLayer`, placed on the surface, count =
`stingerCount`, texture `textures/entity/bee/bee_stinger.png`; the stuck-in-body placement rules belong to the player layer document):

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `cross_1` | rot(0.7853982,0,0) | [0,0] (-1,-0.5,0) 2×1×0 |
| `cross_2` | rot(2.3561945,0,0) | [0,0] (-1,-0.5,0) 2×1×0 |

### 9.2 Per-frame pose (`BeeModel.setupAnim`, shared by both ages)

Let A = ageInTicks.

1. `stinger.visible` = state.hasStinger.
2. If not on the ground: w = A x 120.32113 x 0.017453292 (about 2.1 radians per tick); right wing yRot = 0; right wing zRot =
   cos(w) x pi x 0.15; left wing xRot = right wing xRot; left wing yRot = right wing yRot (= 0, so the initial +-0.2618 wing yaw
   of the mesh is **replaced** by 0 on both wings); left wing zRot = -(right wing zRot); front, middle and back legs xRot = 0.7853982.
3. If neither angry nor on the ground: c = cos(0.18 A); bob: bone.xRot = 0.1 + c x pi x 0.025; bone y -= cos(0.18 A) x 0.9;
   front legs xRot = -c x pi x 0.1 + 0.3926991; back legs xRot = -c x pi x 0.05 + 0.7853982 (the middle legs keep 0.7853982
   from step 2). Adult only: both antennae xRot = c x pi x 0.03.
4. If `rollAmount` R > 0: bone.xRot = rotLerpRad(R, bone.xRot, 3.0915928).

### 9.3 Renderer and state

| Item | Value |
|---|---|
| Models, shadow | `BEE` / `BEE_BABY`, shadow radius 0.4 |
| Texture | files in `textures/entity/bee/`; angry and nectar: `bee_angry_nectar.png`; angry only: `bee_angry.png`; nectar only: `bee_nectar.png`; neither: `bee.png`; every one has a baby file with `_baby` before the extension (`bee_angry_nectar_baby.png`, `bee_angry_baby.png`, `bee_nectar_baby.png`, `bee_baby.png`) |
| State | `rollAmount` = lerp(t, old, current) of the bee's roll counter; `hasStinger` = not `hasStung()` (flag 4); `isOnGround` = on the ground **and** squared speed < 1e-7; `isAngry`; `hasNectar` (flag 8) |

Entity counter (`Bee.updateRollAmount`): `rollAmount` += 0.2 (max 1) while rolling, else -= 0.24 (min 0); stored old and current each tick.

---

## 10. Armadillo (`ArmadilloModel`, `AdultArmadilloModel`, `BabyArmadilloModel`, `ArmadilloAnimation`, `BabyArmadilloAnimation`, `ArmadilloRenderer`, `ArmadilloRenderState`)

### 10.1 Meshes

Both models read root children `body`, `right_hind_leg`, `left_hind_leg`, `cube` (the rolled-up ball), and `head` and `tail` as children of
`body`. The four animation definitions are passed to the constructor in the order walk, roll out, roll up, peek: adult `ARMADILLO_WALK`,
`ARMADILLO_ROLL_OUT`, `ARMADILLO_ROLL_UP`, `ARMADILLO_PEEK`; baby `ARMADILLO_BABY_WALK`, `ARMADILLO_BABY_ROLL_OUT`,
`ARMADILLO_BABY_ROLL_UP`, `ARMADILLO_BABY_PEEK` (§15.4, §15.5).

Adult `AdultArmadilloModel.createBodyLayer()`, texture **64 x 64**. (The adult body has two overlapping cuboids at the same origin: the first with grow 0.3, the
second plain. The ears are children of `head`, each with a flat cube child.)

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `body` | pos(0,21,4) | [0,20] (-4,-7,-10) 8×8×12 grow 0.3; [0,40] (-4,-7,-10) 8×8×12 |
| `body/tail` | pos(0,-3,1) rot(0.5061,0,0) | [44,53] (-0.5,-0.0865,0.0933) 1×6×1 |
| `body/head` | pos(0,-2,-11) | (no cubes) |
| `body/head/head_cube` | pos(0,0,0) rot(-0.3927,0,0) | [43,15] (-1.5,-1,-1) 3×5×2 |
| `body/head/right_ear` | pos(-1,-1,0) | (no cubes) |
| `body/head/right_ear/right_ear_cube` | pos(-0.5,0,-0.6) rot(0.1886,-0.3864,-0.0718) | [43,10] (-2,-3,0) 2×5×0 |
| `body/head/left_ear` | pos(1,-2,0) | (no cubes) |
| `body/head/left_ear/left_ear_cube` | pos(0.5,1,-0.6) rot(0.1886,0.3864,0.0718) | [47,10] (0,-3,0) 2×5×0 |
| `right_hind_leg` | pos(-2,21,4) | [51,31] (-1,0,-1) 2×3×2 |
| `left_hind_leg` | pos(2,21,4) | [42,31] (-1,0,-1) 2×3×2 |
| `right_front_leg` | pos(-2,21,-4) | [51,43] (-1,0,-1) 2×3×2 |
| `left_front_leg` | pos(2,21,-4) | [42,43] (-1,0,-1) 2×3×2 |
| `cube` | pos(0,24,0) | [0,0] (-5,-10,-6) 10×10×10 |

Baby `BabyArmadilloModel.createBodyLayer()`, texture **64 x 64**. Quirks read as is: the baby's `tail` part holds a child named `right_ear_cube` (that
cuboid is the tail), the baby's ears are children of `head/head_cube`, and the baby's right-named front leg sits at +1.5 x (the left side) while the left-named front
leg sits at -1.5 (mirror flags are set on the right hind and left front legs only):

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `body` | pos(0,20,0.5) | [0,0] (-2.5,-2,-3.5) 5×4×7 grow 0.3; [0,11] (-2.5,-2,-3) 5×4×6 |
| `body/tail` | pos(0,0,3.4) | (no cubes) |
| `body/tail/right_ear_cube` | pos(0,1.5,1) rot(-1.0472,0,0) | [22,11] (-0.5,-0.5,-2) 1×1×4 |
| `body/head` | pos(0,0,-3.2) | (no cubes) |
| `body/head/head_cube` | pos(0,0,0) rot(0.7417649,0,0) | [20,17] (-1,-2,-4) 2×2×4 |
| `body/head/head_cube/right_ear` | pos(-1,-2,-0.3) rot(-0.4363,-0.1134,0.0524) | [28,8] (-1.8,-2,0) 2×3×0 mirror |
| `body/head/head_cube/left_ear` | pos(1,-2,-0.3) rot(-0.4363,0.1134,-0.0524) | [28,8] (-0.2,-2,0) 2×3×0 |
| `right_hind_leg` | pos(-1.5,22,2.5) | [20,27] (-1,0,-1) 2×2×2 mirror |
| `left_hind_leg` | pos(1.5,22,2.5) | [20,27] (-1,0,-1) 2×2×2 |
| `right_front_leg` | pos(1.5,22,-1.5) | [20,23] (-1,0,-1) 2×2×2 |
| `left_front_leg` | pos(-1.5,22,-1.5) | [24,0] (-1,0,-1) 2×2×2 mirror |
| `cube` | pos(0,20.7,0.5) | [0,25] (-3,-3,-3) 6×6×6 grow 0.3 |

### 10.2 Per-frame pose (`ArmadilloModel.setupAnim`)

1. If `isHidingInShell`: `body.skipDraw` = true (the body's own cuboids are not drawn, its children still are); left and right hind legs and `tail`
   `visible` = false; `cube.visible` = true. Otherwise: `body.skipDraw` = false; legs and tail visible; `cube.visible` = false;
   `head.xRot` = clamp(state.xRot, -22.5, 25) x 0.017453292; `head.yRot` = clamp(state.yRot, -32.5, 32.5) x 0.017453292.
2. When not hiding: `walk.applyWalk(p, s, 16.5, 2.5)`.
3. In order: roll-out `apply(rollOutState, ageInTicks)`, roll-up `apply(rollUpState, ...)`, peek `apply(peekState, ...)`.

### 10.3 Renderer, state, entity states

| Item | Value |
|---|---|
| Models, shadow | `ARMADILLO` / `ARMADILLO_BABY`, shadow radius 0.4 |
| Texture | `textures/entity/armadillo/armadillo.png`, baby `textures/entity/armadillo/armadillo_baby.png` |
| State | `isHidingInShell` = `Armadillo.shouldHideInShell()`; copies of the `rollOut`, `rollUp` and `peek` animation states |

Entity side (`Armadillo` state machine; the state enum and `shouldHideInShell` thresholds were confirmed in review). State enum (id, serialized name, threatened flag, animation duration in ticks): IDLE (0, "idle", no, 0), ROLLING (1, "rolling", yes, 10), SCARED (2, "scared", yes, 50), UNROLLING
(3, "unrolling", yes, 30). `shouldHideInShell(inStateTicks)`: IDLE never; ROLLING when inStateTicks > 5; SCARED always; UNROLLING when inStateTicks < 26.
`setupAnimationStates` each tick: IDLE stops all three animation states; ROLLING starts roll-up if stopped and stops the others; UNROLLING starts roll-out if stopped and
stops the others; SCARED stops roll-out and roll-up, clears a pending peek (when the client received entity event 64 it stops the peek state and clears the flag), then: if
`inStateTicks` = 0 starts the peek state at the current tick and fast-forwards it by SCARED's duration (50 ticks, factor 1); otherwise starts the peek state if stopped.
Entity event 64 on the client sets that "peek received" flag and plays the peek sound locally.

---

## 11. Frog (`FrogModel`, `FrogAnimation`, `FrogRenderer`, `FrogRenderState`)

Mesh `FrogModel.createBodyLayer()`, texture **48 x 48**. The model's own root is the child `root` of the mesh root (`FrogModel` passes `getChild("root")` to its base class), while the animations are baked against the whole mesh root, so their part names resolve anywhere in the tree. Parts read:
`root/body`, `root/body/head`, `.../head/eyes`, `body/tongue`, `body/left_arm`, `body/right_arm`, `root/left_leg`, `root/right_leg`, `body/croaking_body`.

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `root` | pos(0,24,0) | (no cubes) |
| `body` | pos(0,-2,4) | [3,1] (-3.5,-2,-8) 7×3×9; [23,22] (-3.5,-1,-8) 7×0×9 |
| `body/head` | pos(0,-2,-1) | [23,13] (-3.5,-1,-7) 7×0×9; [0,13] (-3.5,-2,-7) 7×3×9 |
| `body/head/eyes` | pos(-0.5,0,2) | (no cubes) |
| `body/head/eyes/right_eye` | pos(-1.5,-3,-6.5) | [0,0] (-1.5,-1,-1.5) 3×2×3 |
| `body/head/eyes/left_eye` | pos(2.5,-3,-6.5) | [0,5] (-1.5,-1,-1.5) 3×2×3 |
| `body/croaking_body` | pos(0,-1,-5) | [26,5] (-3.5,-0.1,-2.9) 7×2×3 grow -0.1 |
| `body/tongue` | pos(0,-1.01,1) | [17,13] (-2,0,-7.1) 4×0×7 |
| `body/left_arm` | pos(4,-1,-6.5) | [0,32] (-1,0,-1) 2×3×3 |
| `body/left_arm/left_hand` | pos(0,3,-1) | [18,40] (-4,0.01,-4) 8×0×8 |
| `body/right_arm` | pos(-4,-1,-6.5) | [0,38] (-1,0,-1) 2×3×3 |
| `body/right_arm/right_hand` | pos(0,3,0) | [2,40] (-4,0.01,-5) 8×0×8 |
| `left_leg` | pos(3.5,-3,4) | [14,25] (-1,0,-2) 3×3×4 |
| `left_leg/left_foot` | pos(2,3,0) | [2,32] (-4,0.01,-4) 8×0×8 |
| `right_leg` | pos(-3.5,-3,4) | [0,25] (-2,0,-2) 3×3×4 |
| `right_leg/right_foot` | pos(-2,3,0) | [18,32] (-4,0.01,-4) 8×0×8 |

Pose (`FrogModel.setupAnim`), in order: `jump.apply(jumpState, A)`, `croak.apply(croakState, A)`, `tongue.apply(tongueState, A)`; if `isSwimming`: `swim.applyWalk(p, s, 1, 2.5)`,
else `walk.applyWalk(p, s, 1.5, 2.5)`; `idleWater.apply(swimIdleState, A)`; `croaking_body.visible` = the croak state is started. Tables in §15.3.

Renderer: shadow 0.3; texture `state.texture` = the frog variant's texture path (variant data: one `asset_id` per variant, for example `entity/frog/frog_cold`, 3 variants, path `textures/<id>.png`; default `textures/entity/frog/frog_temperate.png`); `isSwimming` = the frog is in water; four copied
animation states (jump, croak, tongue, swim-idle).

---

## 12. Tadpole (`TadpoleModel`, `TadpoleRenderer`)

Mesh `TadpoleModel.createBodyLayer()`, texture **16 x 16**:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `body` | pos(0,22,-3) | [0,0] (-1.5,-1,0) 3×2×3 |
| `tail` | pos(0,22,0) | [0,0] (0,-1,0) 0×2×7 |

Pose: `tail.yRot` = -f x 0.25 x sin(0.3 A) with f = 1 in water, 1.5 out of water (the state is a plain `LivingEntityRenderState`: `isInWater`, `ageInTicks`). Renderer: shadow radius 0.14,
texture `textures/entity/tadpole/tadpole.png`, no other state.

---

## 13. Turtle (`TurtleModel`, `AdultTurtleModel`, `BabyTurtleModel`, `TurtleRenderer`, `TurtleRenderState`)

### 13.1 Meshes

Quadruped base (§1.3) for both. Adult `AdultTurtleModel.createBodyLayer()`, texture **128 x 64**:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `head` | pos(0,19,-10) | [3,0] (-3,-1,-3) 6×5×6 |
| `body` | pos(0,11,-10) rot(1.5707964,0,0) | [7,37] (-9.5,3,-10) 19×20×6 "shell"; [31,1] (-5.5,3,-13) 11×18×3 "belly" |
| `egg_belly` | pos(0,11,-10) rot(1.5707964,0,0) | [70,33] (-4.5,3,-14) 9×18×1 |
| `right_hind_leg` | pos(-3.5,22,11) | [1,23] (-2,0,0) 4×1×10 |
| `left_hind_leg` | pos(3.5,22,11) | [1,12] (-2,0,0) 4×1×10 |
| `right_front_leg` | pos(-5,21,-4) | [27,30] (-13,0,-2) 13×1×5 |
| `left_front_leg` | pos(5,21,-4) | [27,24] (0,0,-2) 13×1×5 |

Baby `BabyTurtleModel.createBodyLayer()`, texture **16 x 16** (the baby has no egg belly part):

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `body` | pos(0,22.9,1) | [0,0] (-2,-1,-2) 4×2×4 |
| `head` | pos(0,22.9,-1) | [0,6] (-1.5,-2,-3) 3×3×3 |
| `right_hind_leg` | pos(-2,23.9,2.5) | [-1,0] (-2,0,-0.5) 2×0×1 |
| `left_hind_leg` | pos(2,23.9,2.5) | [-1,1] (0,0,-0.5) 2×0×1 |
| `right_front_leg` | pos(-2,23.9,-0.5) | [8,6] (-2,0,-0.5) 2×0×1 |
| `left_front_leg` | pos(2,23.9,-0.5) | [8,7] (0,0,-0.5) 2×0×1 |

### 13.2 Per-frame pose

After the quadruped base (head look and the cos leg swing of §1.3, written to every leg's xRot), `TurtleModel.setupAnim` continues. With p, s as before:

- On land (`isOnLand`): f1 = 4 when laying an egg, else 1; f2 = 2 when laying an egg, else 1; q = 5 p; c1 = cos(f1 q); c2 = cos(q). Right front leg yRot = -c1 x 8 x s x f2; left front leg yRot = +c1 x 8 x s x f2;
  right hind yRot = -c2 x 3 x s; left hind yRot = +c2 x 3 x s. (The leg xRot values of the base remain.)
- In water: m = 0.5 s; u = cos(0.6662 x 0.6 p) x m. Right hind leg xRot = u; left hind xRot = -u; right front leg zRot = -u; left front leg zRot = +u. (This replaces the hind-leg xRot of the base; the front-leg xRot of the base remains.)
- Adult only afterwards: `egg_belly.visible` = state.hasEgg; when visible, `root.y` -= 1.

### 13.3 Renderer, state

| Item | Value |
|---|---|
| Models, shadow | `TURTLE` / `TURTLE_BABY`; shadow radius 0.7 x scale, **baby x 0.83** |
| Texture | `textures/entity/turtle/turtle.png`, baby `textures/entity/turtle/turtle_baby.png` |
| State | `isOnLand` = not in water **and** on the ground; `isLayingEgg`; `hasEgg` = not a baby **and** `hasEgg()` |

---

## 14. Sniffer and snifflet (`SnifferModel`, `SniffletModel`, `SnifferAnimation`, `SnifferRenderer`, `SnifferRenderState`)

### 14.1 Meshes

`SnifferModel` reads `bone/body/head` as its head; every part name used by the animations exists in both meshes. Adult `SnifferModel.createBodyLayer()`, texture **192 x 192**:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `bone` | pos(0,5,0) | (no cubes) |
| `bone/body` | pos(0,0,0) | [62,68] (-12.5,-14,-20) 25×29×40; [62,0] (-12.5,-14,-20) 25×24×40 grow 0.5; [87,68] (-12.5,12,-20) 25×0×40 |
| `bone/right_front_leg` | pos(-7.5,10,-15) | [32,87] (-3.5,-1,-4) 7×10×8 |
| `bone/right_mid_leg` | pos(-7.5,10,0) | [32,105] (-3.5,-1,-4) 7×10×8 |
| `bone/right_hind_leg` | pos(-7.5,10,15) | [32,123] (-3.5,-1,-4) 7×10×8 |
| `bone/left_front_leg` | pos(7.5,10,-15) | [0,87] (-3.5,-1,-4) 7×10×8 |
| `bone/left_mid_leg` | pos(7.5,10,0) | [0,105] (-3.5,-1,-4) 7×10×8 |
| `bone/left_hind_leg` | pos(7.5,10,15) | [0,123] (-3.5,-1,-4) 7×10×8 |
| `bone/body/head` | pos(0,6.5,-19.48) | [8,15] (-6.5,-7.5,-11.5) 13×18×11; [8,4] (-6.5,7.5,-11.5) 13×0×11 |
| `bone/body/head/left_ear` | pos(6.51,-7.5,-4.51) | [2,0] (0,0,-3) 1×19×7 |
| `bone/body/head/right_ear` | pos(-6.51,-7.5,-4.51) | [48,0] (-1,0,-3) 1×19×7 |
| `bone/body/head/nose` | pos(0,-4.5,-11.5) | [10,45] (-6.5,-2,-9) 13×2×9 |
| `bone/body/head/lower_beak` | pos(0,2.5,-12.5) | [10,57] (-6.5,-7,-8) 13×12×9 |

Baby: `SniffletModel.createBodyLayer()` is the baby's **mesh** (`ModelLayers.SNIFFER_BABY`), texture **128 x 128**:

| Part path | Pose (offset in texels, rotation in rad) | Cubes: [u,v] origin(x,y,z) size(w,h,d), grow, mirror, name |
|---|---|---|
| `bone` | pos(0,24,0) | (no cubes) |
| `bone/body` | pos(6,-3,-9.5) | [0,35] (-13,-14,-0.5) 14×14×20 grow 0.25; [0,0] (-13,-14,-0.5) 14×15×20; [68,0] (-13,0,-0.5) 14×0×20 |
| `bone/body/head` | pos(-6,-4.75,0) | [68,20] (-5,-4.25,-7.5) 10×9×9; [88,20] (-5,3.75,-7.5) 10×0×9 |
| `bone/body/head/left_ear` | pos(5,-4.25,-1.5) | [104,38] (0,0,-2) 1×11×3 |
| `bone/body/head/right_ear` | pos(-5,-4.25,-1.5) | [96,38] (-1,0,-2) 1×11×3 |
| `bone/body/head/nose` | pos(0,-1.25,-9.5) | [68,47] (-5,-3,-2) 10×3×4 |
| `bone/body/head/lower_beak` | pos(0,1.25,-9.5) | [68,38] (-5,-2.5,-2) 10×5×4 |
| `bone/right_front_leg` | pos(-4,-4,-7) | [0,69] (-2,-1,-2) 4×5×4 |
| `bone/right_mid_leg` | pos(-4,-4,0) | [0,78] (-2,-1,-2) 4×5×4 |
| `bone/right_hind_leg` | pos(-4,-4,7) | [0,87] (-2,-1,-2) 4×5×4 |
| `bone/left_front_leg` | pos(4,-4,-7) | [16,69] (-2,-1,-2) 4×5×4 |
| `bone/left_mid_leg` | pos(4,-4,0) | [16,78] (-2,-1,-2) 4×5×4 |
| `bone/left_hind_leg` | pos(4,-4,7) | [16,87] (-2,-1,-2) 4×5×4 |

The renderer instantiates the plain `SnifferModel` class for both the adult and the baby layer; nothing in the client instantiates `SniffletModel` (only its
`createBodyLayer` is called from `LayerDefinitions`, verified by a search of the client classes). The `SniffletModel` constructor and `setupAnim`, which would apply
`BABY_TRANSFORM` (head scale 1.2, head position offset; §15.6) with `applyStatic`, are therefore **not** run by the standard client. Read, not inferred: across every class of `net/minecraft/client/*`, only `LayerDefinitions` (calling `SniffletModel.createBodyLayer`) and `SniffletModel` itself reference `SniffletModel`; `SnifferRenderer` calls `SnifferModel.<init>` for both `SNIFFER` and `SNIFFER_BABY`, and `SnifferModel` never references `BABY_TRANSFORM`. The baby sniffer therefore renders without the head scale 1.2 (static reading only, no execution).

### 14.2 Per-frame pose (`SnifferModel.setupAnim`)

1. `head.xRot` = state.xRot x 0.017453292, `head.yRot` = state.yRot x 0.017453292.
2. If `isSearching`: `SNIFFER_SNIFF_SEARCH.applyWalk(p, s, 9, 100)`; else `SNIFFER_WALK.applyWalk(p, s, 9, 100)`. (The speed factor 100 saturates k to 1 for any s >= 0.01.)
3. In order, with the state's animation states and ageInTicks: `SNIFFER_DIG` (digging), `SNIFFER_LONGSNIFF` (sniffing), `SNIFFER_STAND_UP` (rising), `SNIFFER_HAPPY` (feeling happy), `SNIFFER_SNIFFSNIFF` (scenting).
   The definition `SNIFFER_BABY_FALL` is defined but not referenced by the model class.

### 14.3 Renderer

Shadow radius 1.1; textures `textures/entity/sniffer/sniffer.png` and `textures/entity/sniffer/snifflet.png`; the culling box of the entity is inflated by 0.6 on every axis. State:
`isSearching` and copies of five animation states (digging, sniffing, rising, feeling happy, scenting).

---

## 15. Keyframe tables

Reading rules: the tables come from the static initialisers of the animation classes. Each row is a part name (§1.2), the channel target (`rot` in degrees, `pos` in texels with the
authored y, `scale` as the final factor), then keyframes `time:(x,y,z)I` with I = L (linear) or C (Catmull-Rom). Doubles that were float constants widened to double (for example
1.149999976158142) are shown as the float's value (1.15); `1` means 1.0. Every definition's length is in seconds. A part with several channels lists each channel as its own row.

### 15.1 `FoxBabyAnimation`

**`FOX_BABY_WALK`**: length 0.5 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0:(0,0,0)L |
| `body` | pos | 0:(0,0,0)L |
| `head` | rot | 0:(0,0,0)L |
| `head` | pos | 0:(0,-1.025,0)L |
| `right_hind_leg` | rot | 0:(-35.0,0,0)C 0.25:(35.0,0,0)L 0.5:(-35.0,0,0)C |
| `right_hind_leg` | pos | 0:(0.05,0.6,-0.02)L 0.25:(0.05,0.6,-0.02)L 0.5:(0.05,0.6,-0.02)L |
| `right_hind_leg` | scale | 0:(1,1.15,1)L |
| `left_hind_leg` | rot | 0:(35.0,0,0)C 0.25:(-35.0,0,0)L 0.5:(35.0,0,0)C |
| `left_hind_leg` | pos | 0:(-0.05,0.6,-0.02)L 0.25:(-0.05,0.6,-0.02)L 0.5:(-0.05,0.6,-0.02)L |
| `left_hind_leg` | scale | 0:(1,1.15,1)L |
| `right_front_leg` | rot | 0:(35.0,0,0)C 0.25:(-35.0,0,0)L 0.5:(35.0,0,0)C |
| `right_front_leg` | pos | 0:(0.05,0.6,-0.4)L |
| `right_front_leg` | scale | 0:(1,1.15,1)L |
| `left_front_leg` | rot | 0:(-35.0,0,0)C 0.25:(35.0,0,0)L 0.5:(-35.0,0,0)C |
| `left_front_leg` | pos | 0:(-0.05,0.6,-0.4)L |
| `left_front_leg` | scale | 0:(1,1.15,1)L |
| `tail` | rot | 0:(-2.5,0,0)C |
| `tail` | pos | 0:(0,-0.05,0)C |

### 15.2 `BatAnimation`

**`BAT_RESTING`**: length 0.5 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `head` | rot | 0:(180.0,0,0)L |
| `head` | pos | 0:(0,0.5,0)L |
| `body` | rot | 0:(180.0,0,0)L |
| `body` | pos | 0:(0,0.5,0)L |
| `feet` | rot | 0:(0,0,0)L |
| `right_wing` | rot | 0:(0,-10.0,0)L |
| `right_wing` | pos | 0:(0,0,1)L |
| `right_wing_tip` | rot | 0:(0,-120.0,0)L |
| `left_wing` | rot | 0:(0,10.0,0)L |
| `left_wing` | pos | 0:(0,0,1)L |
| `left_wing_tip` | rot | 0:(0,120.0,0)L |

**`BAT_FLYING`**: length 0.5 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `head` | rot | 0:(0,0,0)L 0.125:(20.0,0,0)L 0.5:(0,0,0)L |
| `head` | pos | 0:(0,0,0)L 0.125:(0,2,0)L 0.25:(0,1,0)L 0.375:(0,0,0)L 0.4583:(0,-1.0,0)L 0.5:(0,0,0)L |
| `body` | rot | 0:(40.0,0,0)L 0.25:(52.5,0,0)L 0.5:(40.0,0,0)L |
| `body` | pos | 0:(0,0,0)L 0.125:(0,2,0)L 0.25:(0,1,0)L 0.375:(0,0,0)L 0.4583:(0,-1.0,0)L 0.5:(0,0,0)L |
| `feet` | rot | 0:(10.0,0,0)L 0.125:(-21.25,0,0)L 0.25:(-12.5,0,0)L 0.5:(10.0,0,0)L |
| `right_wing` | rot | 0:(0,85.0,0)L 0.125:(0,-55.0,0)L 0.25:(0,50.0,0)L 0.375:(0,70.0,0)L 0.5:(0,85.0,0)L |
| `right_wing_tip` | rot | 0:(0,10.5,0)L 0.0417:(0,65.5,0)L 0.2083:(0,-135.0,0)L 0.5:(0,10.5,0)L |
| `left_wing` | rot | 0:(0,-85.0,0)L 0.125:(0,55.0,0)L 0.25:(0,-50.0,0)L 0.375:(0,-70.0,0)L 0.5:(0,-85.0,0)L |
| `left_wing_tip` | rot | 0:(0,-10.5,0)L 0.0417:(0,-65.5,0)L 0.2083:(0,135.0,0)L 0.5:(0,-10.5,0)L |

### 15.3 `FrogAnimation`

**`FROG_CROAK`**: length 3.0 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `croaking_body` | pos | 0:(0,0,0)L 0.375:(0,0,0)L 0.4167:(0,0,0)L 0.4583:(0,1,0)L 2.9583:(0,1,0)L 3.0:(0,0,0)L |
| `croaking_body` | scale | 0:(0,0,0)L 0.375:(0,0,0)L 0.4167:(1,1,1)L 0.4583:(1,1,1)L 0.5417:(1.3,2.1,1.6)L 0.625:(1.3,2.1,1.6)L 0.7083:(1,1,1)L 2.25:(1,1,1)L 2.3333:(1.3,2.1,1.6)L 2.4167:(1.3,2.1,1.6)L 2.5:(1,1,1)L 2.5833:(1,1,1)L 2.6667:(1.3,2.1,1.6)L 2.875:(1.3,2.1,1.6)L 2.9583:(1,1,1)L 3.0:(0,0,0)L |

**`FROG_WALK`**: length 1.25 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `left_arm` | rot | 0:(0,-5.0,0)L 0.2917:(7.5,-2.67,-7.5)L 0.625:(0,0,0)L 0.7917:(22.5,0,0)L 1.125:(-45.0,0,0)L 1.25:(0,-5.0,0)L |
| `left_arm` | pos | 0:(0,0.1,-2.0)L 0.2917:(-0.5,-0.25,-0.13)L 0.625:(-0.5,0.1,2)L 0.9583:(0.5,1,-0.11)L 1.25:(0,0.1,-2.0)L |
| `right_arm` | rot | 0:(0,0,0)L 0.125:(22.5,0,0)L 0.4583:(-45.0,0,0)L 0.625:(0,5.0,0)L 0.9583:(7.5,2.33,7.5)L 1.25:(0,0,0)L |
| `right_arm` | pos | 0:(0.5,0.1,2)L 0.2917:(-0.5,1,0.12)L 0.625:(0,0.1,-2.0)L 0.9583:(0.5,-0.25,-0.13)L 1.25:(0.5,0.1,2)L |
| `left_leg` | rot | 0:(0,0,0)L 0.1667:(0,0,0)L 0.2917:(45.0,0,0)L 0.625:(-45.0,0,0)L 0.7917:(0,0,0)L 1.25:(0,0,0)L |
| `left_leg` | pos | 0:(0,0.1,1.2)L 0.1667:(0,0.1,2)L 0.4583:(0,2,1.06)L 0.7917:(0,0.1,-1.0)L 1.25:(0,0.1,1.2)L |
| `right_leg` | rot | 0:(-33.75,0,0)L 0.0417:(-45.0,0,0)L 0.1667:(0,0,0)L 0.7917:(0,0,0)L 0.9583:(45.0,0,0)L 1.25:(-33.75,0,0)L |
| `right_leg` | pos | 0:(0,1.14,0.11)L 0.1667:(0,0.1,-1.0)L 0.7917:(0,0.1,2)L 1.125:(0,2,0.95)L 1.25:(0,1.14,0.11)L |
| `body` | rot | 0:(0,5.0,0)L 0.2917:(-7.5,0.33,7.5)L 0.625:(0,-5.0,0)L 0.9583:(-7.5,0.33,-7.5)L 1.25:(0,5.0,0)L |

**`FROG_JUMP`**: length 0.5 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0:(-22.5,0,0)L 0.5:(-22.5,0,0)L |
| `body` | pos | 0:(0,0,0)L 0.5:(0,0,0)L |
| `left_arm` | rot | 0:(-56.14,0,0)L 0.5:(-56.14,0,0)L |
| `left_arm` | pos | 0:(0,1,0)L 0.5:(0,1,0)L |
| `right_arm` | rot | 0:(-56.14,0,0)L 0.5:(-56.14,0,0)L |
| `right_arm` | pos | 0:(0,1,0)L 0.5:(0,1,0)L |
| `left_leg` | rot | 0:(45.0,0,0)L 0.5:(45.0,0,0)L |
| `left_leg` | pos | 0:(0,0,0)L 0.5:(0,0,0)L |
| `right_leg` | rot | 0:(45.0,0,0)L 0.5:(45.0,0,0)L |
| `right_leg` | pos | 0:(0,0,0)L 0.5:(0,0,0)L |

**`FROG_TONGUE`**: length 0.5 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `head` | rot | 0:(0,0,0)L 0.0833:(-60.0,0,0)L 0.4167:(-60.0,0,0)L 0.5:(0,0,0)L |
| `head` | scale | 0:(1,1,1)L 0.0833:(0.998,1,1)L 0.4167:(0.998,1,1)L 0.5:(1,1,1)L |
| `tongue` | rot | 0:(0,0,0)L 0.0833:(0,0,0)L 0.4167:(-18.0,0,0)L 0.5:(0,0,0)L |
| `tongue` | scale | 0.0833:(1,1,1)L 0.1667:(0.5,1,5.0)L 0.4167:(1,1,1)L |

**`FROG_SWIM`**: length 1.04167 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0:(0,0,0)C 0.3333:(10.0,0,0)C 0.6667:(-10.0,0,0)C 1.0417:(0,0,0)C |
| `left_arm` | rot | 0:(90.0,22.5,0)C 0.4583:(45.0,22.5,0)C 0.6667:(-22.5,-22.5,-22.5)C 0.875:(-45.0,-22.5,0)C 0.9583:(22.5,0,22.5)C 1.0417:(90.0,22.5,0)C |
| `left_arm` | pos | 0:(0,-0.64,2)C 0.4583:(0,-0.64,0)C 0.6667:(0,0,0)C 0.875:(0,-0.27,-1.14)C 0.9583:(0,-1.45,0.43)C 1.0417:(0,-0.64,2)C |
| `right_arm` | rot | 0:(90.0,-22.5,0)C 0.4583:(45.0,-22.5,0)C 0.6667:(-22.5,22.5,22.5)C 0.875:(-45.0,22.5,0)C 0.9583:(22.5,0,-22.5)C 1.0417:(90.0,-22.5,0)C |
| `right_arm` | pos | 0:(0,-0.64,2)C 0.4583:(0,-0.64,0)C 0.6667:(0,0,0)C 0.875:(0,-0.27,-1.14)C 0.9583:(0,-1.45,0.43)C 1.0417:(0,-0.64,2)C |
| `left_leg` | rot | 0:(90.0,0,0)C 0.25:(90.0,0,0)C 0.4583:(67.5,-45.0,0)C 0.7917:(90.0,45.0,0)C 0.9583:(90.0,0,0)C 1.0417:(90.0,0,0)C |
| `left_leg` | pos | 0:(-2.5,0,1)C 0.25:(-2.0,0,1)C 0.4583:(1,-2.0,-1.0)C 0.7917:(0.58,0,-2.83)C 0.9583:(-2.5,0,1)C 1.0417:(-2.5,0,1)C |
| `right_leg` | rot | 0:(90.0,0,0)C 0.25:(90.0,0,0)C 0.4583:(67.5,45.0,0)C 0.7917:(90.0,-45.0,0)C 0.9583:(90.0,0,0)C 1.0417:(90.0,0,0)C |
| `right_leg` | pos | 0:(2.5,0,1)C 0.25:(2,0,1)C 0.4583:(-1.0,-2.0,-1.0)C 0.7917:(-0.58,0,-2.83)C 0.9583:(2.5,0,1)C 1.0417:(2.5,0,1)C |

**`FROG_IDLE_WATER`**: length 3.0 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0:(0,0,0)C 1.625:(-10.0,0,0)C 3.0:(0,0,0)C |
| `left_arm` | rot | 0:(0,0,-22.5)C 2.2083:(0,0,-45.0)C 3.0:(0,0,-22.5)C |
| `left_arm` | pos | 0:(-1.0,0,0)C 2.2083:(-1.0,-0.5,0)C 3.0:(-1.0,0,0)C |
| `right_arm` | rot | 0:(0,0,22.5)C 2.2083:(0,0,45.0)C 3.0:(0,0,22.5)C |
| `right_arm` | pos | 0:(1,0,0)C 2.2083:(1,-0.5,0)C 3.0:(1,0,0)C |
| `left_leg` | rot | 0:(22.5,-22.5,0)C 1:(22.5,-22.5,-45.0)C 3.0:(22.5,-22.5,0)C |
| `left_leg` | pos | 0:(0,0,1)C 1:(0,-1.0,1)C 3.0:(0,0,1)C |
| `right_leg` | rot | 0:(22.5,22.5,0)C 1:(22.5,22.5,45.0)C 3.0:(22.5,22.5,0)C |
| `right_leg` | pos | 0:(0,0,1)C 1:(0,-1.0,1)C 3.0:(0,0,1)C |

### 15.4 `ArmadilloAnimation` (adult)

**`ARMADILLO_ROLL_UP`**: length 0.5 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0:(0,0,0)L 0.1667:(0,0,0)L |
| `body` | pos | 0:(0,0,0)L 0.1667:(0,5.0,0)L 0.2083:(0,6.0,-1.0)L 0.25:(0,6.0,-1.0)L 0.375:(0,-1.0,-1.0)L |
| `tail` | rot | 0:(0,0,0)L 0.1667:(0,0,0)L |
| `tail` | pos | 0:(0,0,0)L 0.1667:(0,0,0)L 0.2083:(0,0,-2.0)L 0.25:(0,0,-2.0)L |
| `head` | rot | 0:(0,0,0)L 0.1667:(17.5,0,0)L 0.25:(-72.5,0,0)L |
| `head` | pos | 0:(0,0,0)L 0.1667:(0,-1.0,0)L 0.2083:(0,2,1)L 0.25:(0,2,1)L 0.2917:(0,2,6.0)L 0.375:(0,2,7.0)L |
| `right_hind_leg` | rot | 0:(0,0,0)L 0.1667:(-35.0,0,0)L |
| `right_hind_leg` | pos | 0:(0,0,0)L 0.1667:(0,5.0,-2.0)L 0.1875:(0,8.0,-3.0)L 0.2083:(0,8.0,-2.0)L 0.25:(0,8.0,-2.0)L 0.375:(1,3.0,-6.0)L |
| `left_hind_leg` | rot | 0:(0,0,0)L 0.1667:(-45.0,0,0)L |
| `left_hind_leg` | pos | 0:(0,0,0)L 0.1667:(0,5.0,-2.0)L 0.1875:(0,8.0,-3.0)L 0.2083:(0,8.0,-2.0)L 0.25:(0,8.0,-2.0)L 0.375:(-1.0,3.0,-6.0)L |
| `right_front_leg` | rot | 0:(0,0,0)L 0.1667:(-27.5,0,0)L 0.2083:(-32.5,0,0)L 0.25:(-85.0,0,0)L |
| `right_front_leg` | pos | 0:(0,0,0)L 0.1667:(0,5.0,0)L 0.1875:(-0.5,11.5,0.5)L 0.2083:(-1.0,9.0,-1.0)L 0.25:(-1.0,9.0,-1.0)L 0.375:(-1.0,2,3.0)L |
| `left_front_leg` | rot | 0:(0,0,0)L 0.1667:(-12.5,0,0)L 0.2083:(-35.0,0,0)L 0.25:(-85.0,0,0)L |
| `left_front_leg` | pos | 0:(0,0,0)L 0.1667:(0,5.0,0)L 0.1875:(0.5,11.5,0.5)L 0.2083:(1,9.0,-1.0)L 0.25:(1,9.0,-1.0)L 0.375:(1,2,3.0)L |
| `cube` | rot | 0:(0,0,0)L 0.1667:(0,0,0)L 0.4167:(-2.5,0,0)L 0.4583:(5.0,0,0)L 0.5:(0,0,0)L |
| `cube` | pos | 0:(0,3.0,0)L 0.1667:(0,8.0,0)L 0.2083:(0,7.0,0)L 0.25:(0,7.0,0)L 0.375:(0,0,0)L 0.4167:(0,1,0)L 0.4583:(0,0.6,0)L 0.5:(0,0,0)L |

**`ARMADILLO_WALK`**: length 1.4583 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0:(0,0,0)C 0.25:(0,0,4.6)C 0.2917:(0,0,6.81)C 0.5:(0,0,0)C 0.7083:(0,0,0)C 0.9583:(0,0,-4.6)C 1:(0,0,-6.89)C 1.25:(0,0,0)C 1.4583:(0,0,0)C |
| `body` | pos | 0:(0,0,0)C 0.25:(0,-0.2,0)C 0.5:(0,0,0)C 0.7083:(0,0,0)C 0.9583:(0,-0.2,0)C 1.25:(0,0,0)C 1.4583:(0,0,0)C |
| `tail` | rot | 0:(0,0,0)L 0.5:(-9.17,0,0)L 0.75:(5.0,0,0)L 1.2083:(-8.24,0,0)L 1.4583:(0,0,0)L |
| `right_hind_leg` | rot | 0:(-50.0,0,0)L 0.25:(0,0,0)L 0.5:(0,0,0)L 0.75:(50.0,0,0)L 1:(50.0,0,0)L 1.2917:(-20.0,0,0)L 1.4583:(-50.0,0,0)L |
| `right_hind_leg` | pos | 0:(0,0,0)L 0.25:(0,0,-0.5)L 0.5:(0,0,0)L 1:(0,0,-0.5)L 1.2917:(0,1,-0.18)L 1.4583:(0,0,0)L |
| `left_hind_leg` | rot | 0:(50.0,0,0)L 0.25:(50.0,0,0)L 0.5417:(-20.0,0,0)L 0.7083:(-50.0,0,0)L 0.9583:(0,0,0)L 1.2083:(0,0,0)L 1.4583:(50.0,0,0)L |
| `left_hind_leg` | pos | 0:(0,0,-0.25)L 0.25:(0,0,-0.5)L 0.5417:(0,1,-0.18)L 0.7083:(0,0,0)L 0.9583:(0,0,-0.5)L 1.2083:(0,0,0)L 1.4583:(0,0,-0.25)L |
| `right_front_leg` | rot | 0:(50.0,0,0)L 0.2917:(50.0,0,0)L 0.5417:(-20.0,0,0)L 0.7083:(-50.0,0,0)L 0.9583:(0,0,0)L 1.2083:(0,0,0)L 1.4583:(50.0,0,0)L |
| `right_front_leg` | pos | 0:(0,0,-0.25)L 0.25:(0,0,-0.5)L 0.5417:(0,1,-0.18)L 0.7083:(0,0,0)L 0.9583:(0,0,-0.5)L 1.2083:(0,0,0)L 1.4583:(0,0,-0.25)L |
| `left_front_leg` | rot | 0:(-50.0,0,0)L 0.25:(0,0,0)L 0.5:(0,0,0)L 0.75:(50.0,0,0)L 1:(50.0,0,0)L 1.2917:(-20.0,0,0)L 1.4583:(-50.0,0,0)L |
| `left_front_leg` | pos | 0:(0,0,0)L 0.25:(0,0,-0.5)L 0.5:(0,0,0)L 1:(0,0,-0.5)L 1.2917:(0,1,-0.18)L 1.4583:(0,0,0)L |
| `head` | rot | 0:(0,0,0)L 0.25:(0,0,-2.5)L 0.5:(0,0,0)L 0.7083:(0,0,0)L 1:(0,0,2.5)L 1.25:(0,0,0)L 1.4583:(0,0,0)L |

**`ARMADILLO_PEEK`**: length 2.5 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `head` | rot | 0:(-70.0,0,0)L 0.15:(-65.0,0,0)L 0.4:(-50.0,0,0)L 0.5:(0,0,0)L 0.7:(0,0,0)L 0.9:(-7.5,0,45.0)C 1.15:(-7.5,0,45.0)L 1.3:(-0.8639,-1.4959,-39.1287)C 1.6:(-0.8639,-1.4959,-39.1287)L 1.75:(0,0,0)L 1.8:(-25.0,0,0)L 1.85:(-70.0,0,0)L |
| `head` | pos | 0:(0,1,7.0)L 0.05:(0,1,4.0)L 0.15:(0,1,4.0)L 0.25:(0,1,5.0)L 0.35:(0,1,0.2)L 0.4:(0,1,0.2)L 0.5:(0,2.1,1.2)L 0.6:(0,1.1,0.2)L 0.7:(0,1.1,0.2)L 1.75:(0,1.1,0.2)L 1.8:(0,0.1,0.2)L 1.95:(0,0.1,5.2)L 2:(0,0.1,7.2)L 2.15:(0,0.1,8.2)L 2.3:(0,0.1,5.2)L |
| `right_hind_leg` | pos | 0:(0,3.0,-2.0)L |
| `left_hind_leg` | pos | 0:(0,3.0,-2.0)L |
| `right_front_leg` | rot | 0:(-90.0,0,0)L 0.5833:(-90.0,0,0)C 0.8333:(-45.0,0,0)C 1:(-45.0,0,0)C 1.75:(-45.0,0,0)C 1.8:(-90.0,0,0)C 1.95:(-90.0,0,0)C |
| `right_front_leg` | pos | 0:(-1.0,2,2)L 0.5833:(-1.0,2,2)C 0.6667:(-1.0,2,-2.0)C 0.8333:(-1.0,2,-1.0)C 1:(-1.0,2,-1.0)C 1.75:(-1.0,2,-1.0)C 1.95:(-1.0,2,-1.0)C 2:(-1.0,2,3.0)C 2.15:(-1.0,3.0,4.0)C |
| `left_front_leg` | rot | 0:(-90.0,0,0)L 0.6667:(-90.0,0,0)C 0.8333:(-45.0,0,0)C 1:(-45.0,0,0)C 1.75:(-45.0,0,0)C 1.8:(-90.0,0,0)C 1.95:(-90.0,0,0)C |
| `left_front_leg` | pos | 0:(1,2,2)L 0.6667:(1,2,2)C 0.75:(1,2,-2.0)C 0.8333:(1,2,-1.0)C 1:(1,2,-1.0)C 1.75:(1,2,-1.0)C 1.95:(1,2,-1.0)C 2:(1,2,3.0)C 2.15:(1,3.0,4.0)C |
| `cube` | rot | 0:(0,0,0)L 0.25:(0,0,0)L 0.35:(15.0,0,0)L 0.5:(-7.5,0,0)L 0.6:(0,0,0)L 2:(0,0,0)L 2.05:(-17.5,0,0)L 2.15:(-25.0,0,0)L 2.25:(0,0,0)L 2.3:(12.5,0,0)L 2.5:(0,0,0)L |
| `cube` | pos | 0.25:(0,0,0)L 0.35:(0,1.6,0)L 0.5:(0,0.5,0)L 0.6:(0,0,0)L 2:(0,0,0)L 2.05:(0,1.2,0)L 2.15:(0,1.7,0)L 2.25:(0,0,0)L 2.3:(0,1.3,0)L 2.5:(0,0,0)L |

**`ARMADILLO_ROLL_OUT`**: length 1.5 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `head` | rot | 0.1:(-50.0,0,0)L 0.15:(0,0,0)L 0.25:(0,0,0)L 0.4:(0,0,0)L 0.65:(0,0,0)L 0.7:(0,0,0)L 0.85:(-2.5,0,0)L 0.9:(0,0,0)L 0.95:(-7.5,0,0)L 1.05:(0,0,0)L 1.1:(7.5,0,0)L |
| `head` | pos | 0:(0,1,5.0)L 0.05:(0,1,0.2)L 0.1:(0,1,0.2)L 0.15:(0,2.1,1.2)L 0.25:(0,1.03,0.13)L 0.4:(0,1.03,0.13)L 0.65:(0,1.03,0.13)L 0.7:(0,1.1,0.2)L 0.75:(0,4.1,2.2)L 0.85:(0,5.1,3.2)L 0.9:(0,0.1,0.2)L 0.95:(0,0.9,-0.8)L 1.05:(0,0.9,0)L 1.1:(0,2.6,0.2)L 1.15:(0,2.4,0.2)L 1.2:(0,0,0.2)L 1.25:(0,0,0.2)L 1.3:(0,0,0.2)L |
| `right_hind_leg` | rot | 1.1:(0,0,0)L 1.3:(0,0,30.0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `right_hind_leg` | pos | 1.1:(0,3.0,-2.0)L 1.2:(0,8.0,-2.0)L 1.3:(-1.0,3.0,0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `left_hind_leg` | rot | 1.1:(0,0,0)L 1.3:(0,0,-30.0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `left_hind_leg` | pos | 1.1:(0,3.0,-2.0)L 1.2:(0,8.0,-2.0)L 1.3:(1,3.0,0)L 1.35:(1,3.0,0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `right_front_leg` | rot | 0:(-90.0,0,0)C 0.05:(-90.0,0,0)C 0.25:(-45.0,0,0)L 0.55:(-45.0,0,0)L 0.6:(-92.5,0,0)C 1.1:(-90.0,0,0)C 1.3:(0,0,30.0)C 1.4:(0,0,0)C 1.45:(0,0,0)L 1.5:(0,0,0)C |
| `right_front_leg` | pos | 0:(-1.0,2,2)L 0.05:(-1.0,2,2)C 0.25:(-1.0,2,-1.0)L 0.55:(-1.0,2,-1.0)L 0.7:(-1.0,2,2.63)C 1.1:(-1.0,2,2)L 1.2:(-1.0,7.0,2)L 1.3:(-1.0,3.0,0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `left_front_leg` | rot | 0:(-90.0,0,0)C 0.05:(-90.0,0,0)C 0.25:(-45.0,0,0)L 0.55:(-45.0,0,0)L 0.6:(-87.5,0,0)C 1.1:(-90.0,0,0)C 1.3:(0,0,-30.0)C 1.4:(0,0,0)C 1.45:(0,0,0)L 1.5:(0,0,0)C |
| `left_front_leg` | pos | 0:(1,2,2)C 0.05:(1,2,2)C 0.15:(1,2,0)C 0.25:(1,2,-1.0)L 0.55:(1,2,-1.0)L 0.7:(1,2,1.88)C 0.75:(1,2,2.67)C 1.1:(1,2,2)C 1.2:(1,8.0,2)C 1.25:(1.06,5.06,1)C 1.3:(1,3.0,0)C 1.4:(0,0,0)C 1.45:(0,0,0)L 1.5:(0,0,0)C |
| `cube` | rot | 0:(0,0,0)L 0.05:(15.0,0,0)L 0.15:(-7.5,0,0)L 0.25:(0,0,0)L 0.7:(0,0,0)L 0.75:(-17.5,0,0)L 0.85:(-25.0,0,0)L 0.9:(0,0,0)L 0.95:(12.5,0,0)L 1.05:(0,0,0)L 1.1:(0,0,0)L |
| `cube` | pos | 0:(0,0,0)L 0.05:(0,1.6,0)L 0.15:(0,0.5,0)L 0.25:(0,0,0)L 0.7:(0,0,0)L 0.75:(0,1.2,0)L 0.85:(0,1.7,0)L 0.9:(0,0,0)L 0.95:(0,1.3,0)L 1.05:(0,0,0)L 1.2:(0,5.0,0)L 1.25:(0,8.0,0)L 1.5:(0,1,0)L |
| `body` | pos | 1.1:(0,0,0)L 1.2:(0,4.0,0)L 1.25:(0,5.0,0)L 1.3:(0,4.0,0)L 1.4:(0,-1.0,0)L 1.5:(0,0,0)L |

### 15.5 `BabyArmadilloAnimation`

**`ARMADILLO_BABY_ROLL_UP`**: length 0.5 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0:(0,0,0)L 0.15:(0,0,0)L |
| `body` | pos | 0:(0,0,0)L 0.15:(0,5.0,0)L 0.2:(0,6.0,-1.0)L 0.25:(0,6.0,-1.0)L 0.4:(0,-1.0,-1.0)L |
| `tail` | rot | 0:(0,0,0)L 0.15:(0,0,0)L |
| `tail` | pos | 0:(0,0,0)L 0.15:(0,0,0)L 0.2:(0,1,-3.0)L 0.25:(0,1,-3.0)L 0.4:(0,2,-3.0)L |
| `head` | rot | 0:(0,0,0)L 0.15:(17.5,0,0)L 0.25:(-72.5,0,0)L |
| `head` | pos | 0:(0,0,0)L 0.15:(0,-1.0,0)L 0.2:(0,0,1)L 0.25:(0,0,1)L 0.3:(0,0,5.0)L 0.4:(0,0,5.0)L 0.5:(0,-0.25,5.0)L |
| `right_hind_leg` | rot | 0:(0,0,0)L 0.15:(-35.0,0,0)L |
| `right_hind_leg` | pos | 0:(0,0,0)L 0.15:(0,5.0,-2.0)L 0.2:(0,8.0,-2.0)L 0.25:(0,8.0,-2.0)L 0.4:(1,3.0,-2.0)L |
| `left_hind_leg` | rot | 0:(0,0,0)L 0.15:(-45.0,0,0)L |
| `left_hind_leg` | pos | 0:(0,0,0)L 0.15:(0,5.0,-2.0)L 0.2:(0,8.0,-2.0)L 0.25:(0,8.0,-2.0)L 0.4:(-1.0,3.0,-3.0)L |
| `right_front_leg` | rot | 0:(0,0,0)L 0.15:(-27.5,0,0)L 0.2:(-32.5,0,0)L 0.25:(-85.0,0,0)L |
| `right_front_leg` | pos | 0:(0,0,0)L 0.15:(0,5.0,0)L 0.2:(-1.0,8.0,-1.0)L 0.25:(-1.0,9.0,-1.0)L 0.4:(-1.0,2,3.0)L |
| `left_front_leg` | rot | 0:(0,0,0)L 0.15:(-12.5,0,0)L 0.2:(-35.0,0,0)L 0.25:(-85.0,0,0)L |
| `left_front_leg` | pos | 0:(0,0,0)L 0.15:(0,5.0,0)L 0.2:(1,8.0,-1.0)L 0.25:(1,9.0,-1.0)L 0.4:(1,2,3.0)L |
| `cube` | rot | 0:(0,0,0)L 0.15:(0,0,0)L 0.4:(-2.5,0,0)L 0.45:(5.0,0,0)L 0.5:(0,0,0)L |
| `cube` | pos | 0:(0,3.0,0)L 0.15:(0,8.0,0)L 0.2:(0,7.0,0)L 0.25:(0,7.0,0)L 0.4:(0,1,0)L 0.45:(0,0.6,0)L 0.5:(0,0,0)L |

**`ARMADILLO_BABY_WALK`**: length 1.4583 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0:(0,0,0)C 0.25:(0,0,4.6)C 0.3:(0,0,6.81)C 0.5:(0,0,0)C 0.7:(0,0,0)C 0.95:(0,0,-4.6)C 1:(0,0,-6.89)C 1.25:(0,0,0)C 1.45:(0,0,0)C |
| `body` | pos | 0:(0,0,0)C 0.25:(0,-0.2,0)C 0.5:(0,0,0)C 0.7:(0,0,0)C 0.95:(0,-0.2,0)C 1.25:(0,0,0)C 1.45:(0,0,0)C |
| `tail` | rot | 0:(0,0,0)L 0.5:(-9.17,0,0)L 0.75:(5.0,0,0)L 1.2:(-8.24,0,0)L 1.45:(0,0,0)L |
| `right_hind_leg` | rot | 0:(-50.0,0,0)L 0.25:(0,0,0)L 0.5:(0,0,0)L 0.75:(50.0,0,0)L 1:(50.0,0,0)L 1.3:(-20.0,0,0)L 1.45:(-50.0,0,0)L |
| `right_hind_leg` | pos | 0:(0,0,0)L 0.25:(0,0,-0.5)L 0.5:(0,0,0)L 1:(0,0,-0.5)L 1.3:(0,1,-0.18)L 1.45:(0,0,0)L |
| `left_hind_leg` | rot | 0:(50.0,0,0)L 0.25:(50.0,0,0)L 0.55:(-20.0,0,0)L 0.7:(-50.0,0,0)L 0.95:(0,0,0)L 1.2:(0,0,0)L 1.45:(50.0,0,0)L |
| `left_hind_leg` | pos | 0:(0,0,-0.25)L 0.25:(0,0,-0.5)L 0.55:(0,1,-0.18)L 0.7:(0,0,0)L 0.95:(0,0,-0.5)L 1.2:(0,0,0)L 1.45:(0,0,-0.25)L |
| `right_front_leg` | rot | 0:(50.0,0,0)L 0.3:(50.0,0,0)L 0.55:(-20.0,0,0)L 0.7:(-50.0,0,0)L 0.95:(0,0,0)L 1.2:(0,0,0)L 1.45:(50.0,0,0)L |
| `right_front_leg` | pos | 0:(0,0,-0.25)L 0.25:(0,0,-0.5)L 0.55:(0,1,-0.18)L 0.7:(0,0,0)L 0.95:(0,0,-0.5)L 1.2:(0,0,0)L 1.45:(0,0,-0.25)L |
| `left_front_leg` | rot | 0:(-50.0,0,0)L 0.25:(0,0,0)L 0.5:(0,0,0)L 0.75:(50.0,0,0)L 1:(50.0,0,0)L 1.3:(-20.0,0,0)L 1.45:(-50.0,0,0)L |
| `left_front_leg` | pos | 0:(0,0,0)L 0.25:(0,0,-0.5)L 0.5:(0,0,0)L 1:(0,0,-0.5)L 1.3:(0,1,-0.18)L 1.45:(0,0,0)L |
| `head` | rot | 0:(0,0,0)L 0.25:(0,0,-2.5)L 0.5:(0,0,0)L 0.7:(0,0,0)L 1:(0,0,2.5)L 1.25:(0,0,0)L 1.45:(0,0,0)L |

**`ARMADILLO_BABY_ROLL_OUT`**: length 1.5 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `head` | rot | 0.1:(-50.0,0,0)L 0.15:(0,0,0)L 0.25:(0,0,0)L 0.4:(0,0,0)L 0.65:(0,0,0)L 0.7:(0,0,0)L 0.85:(-2.5,0,0)L 0.9:(0,0,0)L 0.95:(-7.5,0,0)L 1.05:(0,0,0)L 1.1:(7.5,0,0)L |
| `head` | pos | 0:(0,-1.9,5.0)L 0.05:(0,-1.0,0.2)L 0.1:(0,0,0.2)L 0.15:(0,2.1,1.2)L 0.25:(0,0.03,0.13)L 0.4:(0,0.03,0.13)L 0.65:(0,0.03,0.13)L 0.7:(0,0.1,0.2)L 0.75:(0,3.1,2.2)L 0.85:(0,4.1,2.2)L 0.9:(0,0.1,0.2)L 0.95:(0,0.9,-0.8)L 1.05:(0,0.9,0)L 1.1:(0,2.6,0.2)L 1.15:(0,2.4,0.2)L 1.2:(0,0,0.2)L 1.25:(0,0,0.2)L 1.3:(0,0,0.2)L |
| `right_hind_leg` | rot | 1.1:(0,0,0)L 1.3:(0,0,30.0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `right_hind_leg` | pos | 1.1:(0,3.0,-2.0)L 1.2:(0,8.0,-2.0)L 1.3:(-1.0,3.0,0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `left_hind_leg` | rot | 1.1:(0,0,0)L 1.3:(0,0,-30.0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `left_hind_leg` | pos | 1.1:(0,3.0,-2.0)L 1.2:(0,8.0,-2.0)L 1.3:(1,3.0,0)L 1.35:(1,3.0,0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `right_front_leg` | rot | 0:(-90.0,0,0)C 0.05:(-90.0,0,0)C 0.25:(-45.0,0,0)L 0.55:(-45.0,0,0)L 0.6:(-92.5,0,0)C 1.1:(-90.0,0,0)C 1.3:(0,0,30.0)C 1.4:(0,0,0)C 1.45:(0,0,0)L 1.5:(0,0,0)C |
| `right_front_leg` | pos | 0:(-1.0,2,2)L 0.05:(-1.0,2,2)C 0.25:(0,2,-1.0)L 0.55:(0,2,-1.0)L 0.7:(-1.0,2,2.63)C 1.1:(-1.0,2,2)L 1.2:(-1.0,7.0,2)L 1.3:(-1.0,3.0,0)L 1.4:(0,0,0)L 1.45:(0,0,0)L 1.5:(0,0,0)L |
| `left_front_leg` | rot | 0:(-90.0,0,0)C 0.05:(-90.0,0,0)C 0.25:(-45.0,0,0)L 0.55:(-45.0,0,0)L 0.6:(-87.5,0,0)C 1.1:(-90.0,0,0)C 1.3:(0,0,-30.0)C 1.4:(0,0,0)C 1.45:(0,0,0)L 1.5:(0,0,0)C |
| `left_front_leg` | pos | 0:(1,2,2)C 0.05:(1,2,2)C 0.15:(1,2,0)C 0.25:(0,2,-1.0)L 0.55:(0,2,-1.0)L 0.7:(1,2,1.88)C 0.75:(1,2,2.67)C 1.1:(1,2,2)C 1.2:(1,8.0,2)C 1.25:(1.06,5.06,1)C 1.3:(1,3.0,0)C 1.4:(0,0,0)C 1.45:(0,0,0)L 1.5:(0,0,0)C |
| `body` | pos | 1.1:(0,0,0)L 1.2:(0,4.0,0)L 1.25:(0,5.0,0)L 1.3:(0,4.0,0)L 1.4:(0,-1.0,0)L 1.5:(0,0,0)L |
| `left_ear` | rot | 0:(0,0,0)L 0.25:(0,0,0)L |
| `left_ear` | pos | 0:(0,0,0)L 0.15:(0,-1.4129,0.0617)L 0.25:(0,0,0)L |
| `right_ear` | rot | 0:(0,0,0)L 0.25:(0,0,0)L |
| `right_ear` | pos | 0:(0,0,0)L 0.15:(0,-1.4129,0.0617)L 0.25:(0,0,0)L |
| `cube` | rot | 0:(0,0,0)L 0.05:(15.0,0,0)L 0.15:(-7.5,0,0)L 0.25:(0,0,0)L 0.7:(0,0,0)L 0.75:(-17.5,0,0)L 0.85:(-25.0,0,0)L 0.9:(0,0,0)L 0.95:(12.5,0,0)L 1.05:(0,0,0)L 1.1:(0,0,0)L |
| `cube` | pos | 0:(0,0,0)L 0.05:(0,1.6,0)L 0.15:(0,0.5,0)L 0.25:(0,0,0)L 0.7:(0,0,0)L 0.75:(0,1.2,0)L 0.85:(0,1.7,0)L 0.9:(0,0,0)L 0.95:(0,1.3,0)L 1.05:(0,0,0)L 1.2:(0,5.0,0)L 1.25:(0,8.0,0)L 1.5:(0,1,0)L |

**`ARMADILLO_BABY_PEEK`**: length 2.5 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `head` | rot | 0:(-70.0,0,0)L 0.15:(-65.0,0,0)L 0.4:(-50.0,0,0)L 0.5:(0,0,0)L 0.7:(0,0,0)L 0.9:(-7.5,0,45.0)C 1.15:(-7.5,0,45.0)L 1.3:(-0.8639,-1.4959,-39.1287)C 1.6:(-0.8639,-1.4959,-39.1287)L 1.75:(0,0,0)L 1.8:(-25.0,0,0)L 1.85:(-70.0,0,0)L |
| `head` | pos | 0:(0,-1.25,4.0)L 0.1:(0,-1.0,4.0)L 0.15:(0,-1.0,4.0)L 0.25:(0,-1.0,5.0)L 0.35:(0,0,0.2)L 0.4:(0,0,0.2)L 0.45:(0,0.05,0.7)L 0.5:(0,1.1,1.2)L 0.6:(0,0.1,0.8)L 0.7:(0,0.1,0.7)L 1.75:(0,0.1,0.7)L 1.8:(0,0.1,0.2)L 1.9:(0,-1.2,3.53)L 1.95:(0,-1.2,3.53)L 2:(0,-1.2,3.53)L 2.15:(0,-0.9,4.2)L 2.3:(0,-0.9,3.4)L 2.5:(0,-1.9,4.1)L |
| `right_hind_leg` | pos | 0:(0,3.0,-2.0)L |
| `left_hind_leg` | pos | 0:(0,3.0,-2.0)L |
| `right_front_leg` | rot | 0:(-90.0,0,0)L 0.6:(-90.0,0,0)C 0.85:(-45.0,0,0)C 1:(-45.0,0,0)C 1.75:(-45.0,0,0)C 1.8:(-90.0,0,0)C 1.95:(-90.0,0,0)C |
| `right_front_leg` | pos | 0:(-1.0,2,2)L 0.6:(-1.0,2,2)C 0.65:(-1.0,2,1)C 0.85:(0,1,-0.5)C 1:(0,1,-0.5)C 1.75:(0,1,-0.5)C 1.95:(0,1,3.0)C 2:(-1.0,2,3.0)C 2.15:(-1.0,3.0,4.0)C |
| `left_front_leg` | rot | 0:(-90.0,0,0)L 0.65:(-90.0,0,0)C 0.85:(-45.0,0,0)C 1:(-45.0,0,0)C 1.75:(-45.0,0,0)C 1.8:(-90.0,0,0)C 1.95:(-90.0,0,0)C |
| `left_front_leg` | pos | 0:(1,2,2)L 0.65:(1,2,2)C 0.85:(0,1,-0.4)C 1:(0,1,-0.4)C 1.75:(0,1,-0.4)C 1.95:(1,1,2)C 2:(1,2,3.0)C 2.15:(1,3.0,4.0)C |
| `left_ear` | rot | 0:(0,0,0)L 0.4:(0,0,0)L 0.5:(-15.0,0,0)L 0.6:(0,0,0)L 1.8:(0,0,0)L 1.85:(-10.0,0,0)L 2.5:(0,0,0)L |
| `left_ear` | pos | 0:(0,0,0)L 0.4:(0,-1.13,1.05)L 0.5:(0,-1.4129,0.0617)L 0.6:(0,0,0)L |
| `right_ear` | rot | 0:(0,0,0)L 0.4:(0,0,0)L 0.5:(-15.0,0,0)L 0.6:(0,0,0)L 1.8:(0,0,0)L 1.85:(-10.0,0,0)L 2.5:(0,0,0)L |
| `right_ear` | pos | 0:(0,0,0)L 0.4:(0,-1.13,1.05)L 0.5:(0,-1.4129,0.0617)L 0.6:(0,0,0)L |
| `cube` | rot | 0:(0,0,0)L 0.25:(0,0,0)L 0.35:(15.0,0,0)L 0.5:(-7.5,0,0)L 0.6:(0,0,0)L 2:(0,0,0)L 2.05:(-17.5,0,0)L 2.15:(-25.0,0,0)L 2.25:(0,0,0)L 2.3:(12.5,0,0)L 2.5:(0,0,0)L |
| `cube` | pos | 0.25:(0,0,0)L 0.35:(0,1.6,0)L 0.5:(0,0.5,0)L 0.6:(0,0,0)L 2:(0,0,0)L 2.05:(0,1.2,0)L 2.15:(0,1.7,0)L 2.25:(0,0,0)L 2.3:(0,1.3,0)L 2.5:(0,0,0)L |

### 15.6 `SnifferAnimation` (including the unused-by-renderer `BABY_TRANSFORM` and `SNIFFER_BABY_FALL`)

**`BABY_TRANSFORM`**: length 0.0 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `head` | scale | 0:(1.2,1.2,1.2)L |
| `head` | pos | 0:(0,1,1)L |

**`SNIFFER_SNIFFSNIFF`**: length 8.0 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `nose` | scale | 0:(1,1,1)L 0.5417:(1,1,1)L 0.5833:(1,0.5,1)C 0.6667:(1,2.5,1)C 0.7917:(1,1,1)C 0.9167:(1,1,1)C 1:(1,3.0,1)C 1.125:(1,1,1)L 2:(1,1,1)L |

**`SNIFFER_LONGSNIFF`**: length 1.0 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `nose` | scale | 0:(1,1,1)C 0.0833:(1,0.7,1)C 0.125:(1,3.0,1)C 0.25:(1,3.0,1)C 0.7083:(1,4.0,1)C 0.8333:(1,1,1)C 1:(1,1,1)C |
| `head` | rot | 0:(0,0,0)L 0.125:(-5.0,0,0)L 0.875:(-20.0,0,0)L 1:(0,0,0)L |

**`SNIFFER_WALK`**: length 2.0 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `right_front_leg` | rot | 0:(0,0,0)L 0.5833:(35.0,0,0)L 1:(-35.0,0,0)L 1.1667:(0,0,0)L 2:(0,0,0)L |
| `right_front_leg` | pos | 0:(0,0,3.0)L 0.75:(0,4.0,-1.0)L 1:(0,0,0)L 1.1667:(0,0,-1.0)L 2:(0,0,3.0)L |
| `right_mid_leg` | rot | 0:(-7.0,0,0)L 0.1667:(-35.0,0,0)L 0.3333:(0,0,0)L 1:(0,0,0)L 1.1667:(0,0,0)L 1.75:(35.0,0,0)L 2:(-7.0,0,0)L |
| `right_mid_leg` | pos | 0:(0,2.67,-0.67)L 0.1667:(0,0,0)L 0.3333:(0,0,-2.0)L 1:(0,0,2)L 1.1667:(0,0,3.0)L 1.9167:(0,4.0,-1.0)L 2:(0,2.67,-0.67)L |
| `right_hind_leg` | rot | 0:(0,0,0)L 0.5833:(0,0,0)L 1:(25.0,0,0)L 1.1667:(35.0,0,0)L 1.5833:(-35.0,0,0)L 1.75:(0,0,0)L 2:(0,0,0)L |
| `right_hind_leg` | pos | 0:(0,0,-0.5)L 0.5833:(0,0,2)L 1:(0,2.22,0.78)L 1.3333:(0,4.0,-1.0)L 1.5833:(0,0,0)L 1.75:(0,0,-2.0)L 2:(0,0,-0.5)L |
| `left_front_leg` | rot | 0:(-35.0,0,0)L 0.1667:(0,0,0)L 1:(0,0,0)L 1.5833:(35.0,0,0)L 2:(-35.0,0,0)L |
| `left_front_leg` | pos | 0:(0,0,0)L 0.1667:(0,0,-1.0)L 1:(0,0,3.0)L 1.75:(0,4.0,-1.0)L 2:(0,0,0)L |
| `left_mid_leg` | rot | 0:(0,0,0)L 0.1667:(0,0,0)L 0.75:(35.0,0,0)L 1.1667:(-35.0,0,0)L 1.3333:(0,0,0)L 2:(0,0,0)L |
| `left_mid_leg` | pos | 0:(0,0,2)L 0.1667:(0,0,3.0)L 0.9167:(0,4.0,-1.0)L 1.1667:(0,0,0)L 1.3333:(0,0,-2.0)L 2:(0,0,2)L |
| `left_hind_leg` | rot | 0:(25.0,0,0)L 0.1667:(35.0,0,0)L 0.5833:(-35.0,0,0)L 0.75:(0,0,0)L 1:(0,0,0)L 1.5833:(0,0,0)L 2:(25.0,0,0)L |
| `left_hind_leg` | pos | 0:(0,2.22,0.78)L 0.3333:(0,4.0,-1.0)L 0.5833:(0,0,0)L 0.75:(0,0,-2.0)L 1:(0,0,-0.5)L 1.5833:(0,0,2)L 2:(0,2.22,0.78)L |
| `body` | rot | 0:(1,0,-2.5)L 0.5:(-1.0,0,0)L 1:(1,0,2.5)L 1.5:(-1.0,0,0)L 2:(1,0,-2.5)L |
| `body` | pos | 0:(0,0,0)L 0.2083:(0,0,0)L 0.375:(0,-1.0,0)L 1:(0,0,0)L 1.2083:(0,0,0)L 1.375:(0,-1.0,0)L 2:(0,0,0)L |
| `head` | rot | 0:(7.5,0,0)C 0.1667:(9.0,0,0)C 0.875:(-1.0,0,0)C 1.25:(7.0,0,0)C 1.75:(5.0,0,0)C 2:(7.5,0,0)C |
| `left_ear` | rot | 0:(0,0,-2.5)C 0.5:(0,0,-7.5)C 1:(0,0,-2.5)C 1.5:(0,0,-7.5)C 2:(0,0,-2.5)C |
| `right_ear` | rot | 0:(0,0,2.5)C 0.5:(0,0,7.5)C 1:(0,0,2.5)C 1.5:(0,0,7.5)C 2:(0,0,2.5)C |

**`SNIFFER_SNIFF_SEARCH`**: length 2.0 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `right_front_leg` | rot | 0:(0,0,0)L 0.5833:(35.0,0,0)L 1:(-35.0,0,0)L 1.1667:(0,0,0)L 2:(0,0,0)L |
| `right_front_leg` | pos | 0:(0,0,3.0)L 0.75:(0,4.0,-1.0)L 1:(0,0,0)L 1.1667:(0,0,-1.0)L 2:(0,0,3.0)L |
| `right_mid_leg` | rot | 0:(-7.0,0,0)L 0.1667:(-35.0,0,0)L 0.3333:(0,0,0)L 1:(0,0,0)L 1.1667:(0,0,0)L 1.75:(35.0,0,0)L 2:(-7.0,0,0)L |
| `right_mid_leg` | pos | 0:(0,2.67,-0.67)L 0.1667:(0,0,0)L 0.3333:(0,0,-2.0)L 1:(0,0,2)L 1.1667:(0,0,3.0)L 1.9167:(0,4.0,-1.0)L 2:(0,2.67,-0.67)L |
| `right_hind_leg` | rot | 0:(0,0,0)L 0.5833:(0,0,0)L 1:(25.0,0,0)L 1.1667:(35.0,0,0)L 1.5833:(-35.0,0,0)L 1.75:(0,0,0)L 2:(0,0,0)L |
| `right_hind_leg` | pos | 0:(0,0,-0.5)L 0.5833:(0,0,2)L 1:(0,2.22,0.78)L 1.3333:(0,4.0,-1.0)L 1.5833:(0,0,0)L 1.75:(0,0,-2.0)L 2:(0,0,-0.5)L |
| `left_front_leg` | rot | 0:(-35.0,0,0)L 0.1667:(0,0,0)L 1:(0,0,0)L 1.5833:(35.0,0,0)L 2:(-35.0,0,0)L |
| `left_front_leg` | pos | 0:(0,0,0)L 0.1667:(0,0,-1.0)L 1:(0,0,3.0)L 1.75:(0,4.0,-1.0)L 2:(0,0,0)L |
| `left_mid_leg` | rot | 0:(0,0,0)L 0.1667:(0,0,0)L 0.75:(35.0,0,0)L 1.1667:(-35.0,0,0)L 1.3333:(0,0,0)L 2:(0,0,0)L |
| `left_mid_leg` | pos | 0:(0,0,2)L 0.1667:(0,0,3.0)L 0.9167:(0,4.0,-1.0)L 1.1667:(0,0,0)L 1.3333:(0,0,-2.0)L 2:(0,0,2)L |
| `left_hind_leg` | rot | 0:(25.0,0,0)L 0.1667:(35.0,0,0)L 0.5833:(-35.0,0,0)L 0.75:(0,0,0)L 1:(0,0,0)L 1.5833:(0,0,0)L 2:(25.0,0,0)L |
| `left_hind_leg` | pos | 0:(0,2.22,0.78)L 0.3333:(0,4.0,-1.0)L 0.5833:(0,0,0)L 0.75:(0,0,-2.0)L 1:(0,0,-0.5)L 1.5833:(0,0,2)L 2:(0,2.22,0.78)L |
| `body` | rot | 0:(2.5,0,0)L 0.5:(1.25,0,0)L 1.5:(0,0,0)L 2:(2.5,0,0)L |
| `head` | rot | 0:(35.0,0,0)L 0.125:(33.61503,11.46526,9.803)L 0.875:(34.71128,17.67415,14.15251)L 1.125:(37.21128,-17.67415,-14.15251)L 1.875:(38.30529,-21.62827,-17.40292)L 2:(35.0,0,0)L |
| `head` | pos | 0:(0,-2.0,0)L 2:(0,-2.0,0)L |
| `left_ear` | rot | 0:(0,0,-2.5)L 0.25:(0,0,-15.0)L 0.5:(0,0,-2.5)L 0.75:(0,0,-15.0)L 1:(0,0,-2.5)L 1.25:(0,0,-15.0)L 1.5:(0,0,-2.5)L 1.75:(0,0,-15.0)L 2:(0,0,-2.5)L |
| `right_ear` | rot | 0:(0,0,2.5)L 0.25:(0,0,15.0)L 0.5:(0,0,2.5)L 0.75:(0,0,15.0)L 1:(0,0,2.5)L 1.25:(0,0,15.0)L 1.5:(0,0,2.5)L 1.75:(0,0,15.0)L 2:(0,0,2.5)L |
| `nose` | scale | 0:(1,1,1)C 0.0833:(1,1.5,1)C 0.2083:(1,1,1)C 0.375:(1,1,1)C 0.4583:(1,2.5,1)C 0.625:(1,1,1)C 0.8333:(1,1,1)C 0.9167:(1,2.5,1)C 1.0833:(1,1,1)C 1.2917:(1,1,1)C 1.3333:(1,2.5,1)C 1.5:(1,1,1)C 1.625:(1,1,1)C 1.6667:(1,3.5,1)C 1.8333:(1,1,1)C 2:(1,1,1)C |

**`SNIFFER_DIG`**: length 8.0 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0:(0,0,0)L 0.5:(1.5,0,0)L 1.3333:(-5.0,0,0)L 1.5:(0,0,0)L 2:(0,0,0)L 2.5:(2.5,0,0)L 3.0:(0,0,0)L 3.5:(2.5,0,0)L 4.0:(0,0,0)L 4.5:(2.5,0,0)L 5.6667:(5.0,0,0)L 5.8333:(-2.5,0,0)L 6.0:(0,0,0)L |
| `body` | pos | 0:(0,0,0)L 1.3333:(0,1,0)L 1.5:(0,-7.0,0)L |
| `body` | scale | 0:(1,1,1)L 1.5:(1,1,1)L 1.5417:(1.04,0.98,1.02)L 1.5833:(1,1,1)L |
| `head` | rot | 0:(0,0,0)C 1.1667:(10.0,0,0)C 1.4167:(-10.0,0,0)C 1.5:(0,0,0)C 1.5833:(0,0,0)C 1.875:(0,0,0)C 2.0833:(0,0,0)C 2.5:(47.5,0,0)C 2.6667:(38.44,0,0)C 2.875:(10.95951,13.57454,-14.93501)C 3.2083:(47.5,0,0)C 3.5833:(55.0,0,0)C 3.7917:(4.2932,-16.187,10.90042)C 4.125:(47.5,0,0)C 4.4167:(54.71135,7.98009,-5.56662)C 4.5:(55.72895,-6.77684,4.46197)C 4.5833:(54.71135,7.98009,-5.56662)C 4.6667:(55.72895,-6.77684,4.46197)C 4.75:(54.71135,7.98009,-5.56662)C 4.8333:(55.72895,-6.77684,4.46197)C 5.0:(65.0,0,0)C 5.75:(65.0,0,0)C 5.9167:(-32.5,0,0)C 6.25:(0,0,0)L |
| `head` | pos | 0:(0,0,0)L 0.625:(0,0,0)L 1.375:(0,1,0)L 1.5:(0,1,0)L 1.5833:(0,1,0)L 1.875:(0,1,0)L 2.0833:(0,3.0,0)L 2.2917:(0,6.0,0)L 2.6667:(0,0,0)L 3.2083:(0,4.0,0)L 3.5833:(0,0,0)L 4.125:(0,4.0,0)L 5.0:(0,0,0)L 5.75:(0,1,0)L 6.0:(0,1.5,0)L 6.25:(0,1,0)L |
| `left_ear` | rot | 0:(0,0,-2.5)L 1.25:(0,0,-2.5)L 1.4167:(0,0,-50.0)L 1.5833:(0,0,-30.0)L 5.9167:(0,0,-30.0)L 6.0833:(0,0,-65.0)L 6.3333:(0,0,-30.0)L |
| `right_ear` | rot | 0:(0,0,2.5)L 1.25:(0,0,2.5)L 1.4167:(0,0,50.0)L 1.5833:(0,0,30.0)L 5.9167:(0,0,30.0)L 6.0833:(0,0,65.0)L 6.3333:(0,0,30.0)L |
| `right_front_leg` | rot | 0:(0,0,0)L 1.2083:(0,0,0)L 1.375:(0,0,90.0)L |
| `right_front_leg` | pos | 0:(0,0,0)L 1.2083:(0,0,0)L 1.2917:(-2.0,-0.75,0)L 1.375:(-4.0,-5.5,0)L |
| `right_mid_leg` | rot | 0:(0,0,0)L 1.25:(0,0,0)L 1.4167:(0,0,90.0)L |
| `right_mid_leg` | pos | 0:(0,0,0)L 1.25:(0,0,0)L 1.3333:(-2.0,-0.75,0)L 1.4167:(-4.0,-5.5,0)L |
| `right_hind_leg` | rot | 0:(0,0,0)L 1.3333:(0,0,0)L 1.5:(0,0,90.0)L |
| `right_hind_leg` | pos | 0:(0,0,0)L 1.3333:(0,0,0)L 1.4167:(-2.0,-0.75,0)L 1.5:(-4.0,-5.5,0)L |
| `left_front_leg` | rot | 0:(0,0,0)L 1.2083:(0,0,0)L 1.375:(0,0,-90.0)L |
| `left_front_leg` | pos | 0:(0,0,0)L 1.2083:(0,0,0)L 1.2917:(2,-0.75,0)L 1.375:(4.0,-5.5,0)L |
| `left_mid_leg` | rot | 0:(0,0,0)L 1.25:(0,0,0)L 1.4167:(0,0,-90.0)L |
| `left_mid_leg` | pos | 0:(0,0,0)L 1.25:(0,0,0)L 1.3333:(2,-0.75,0)L 1.4167:(4.0,-5.5,0)L |
| `left_hind_leg` | rot | 0:(0,0,0)L 1.3333:(0,0,0)L 1.5:(0,0,-90.0)L |
| `left_hind_leg` | pos | 0:(0,0,0)L 1.3333:(0,0,0)L 1.4167:(2,-0.75,0)L 1.5:(4.0,-5.5,0)L |

**`SNIFFER_STAND_UP`**: length 3.0 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `body` | rot | 0.25:(0,0,0)L 0.75:(2.5,0,0)L 1.5:(-2.5,0,0)L 1.7083:(0,0,0)L |
| `body` | pos | 0.25:(0,-7.0,0)L 0.75:(0,-7.0,0)L 1.5:(0,0,0)L 1.7083:(0,0,0)L |
| `head` | rot | 0:(0,0,0)L 0.3333:(-5.0,0,0)L 0.7083:(0,0,0)L 1:(10.0,0,0)L 1.375:(0,0,0)L |
| `head` | pos | 0:(0,1,0)L 1.375:(0,1,0)L |
| `left_ear` | rot | 0:(0,0,-30.0)L 0.9167:(0,0,-30.0)L 1.2083:(0,0,-5.0)L |
| `right_ear` | rot | 0:(0,0,30.0)L 0.9167:(0,0,30.0)L 1.2083:(0,0,5.0)L |
| `right_front_leg` | rot | 0:(0,0,90.0)C 0.4583:(0,0,0)C |
| `right_front_leg` | pos | 0:(-4.0,-5.5,0)C 0.2083:(6.0,-5.5,0)C 0.4583:(0,0,0)C |
| `right_mid_leg` | rot | 0.0833:(0,0,90.0)C 0.5833:(0,0,0)C |
| `right_mid_leg` | pos | 0.0833:(-4.0,-5.5,0)C 0.3333:(6.0,-5.5,0)C 0.5833:(0,0,0)C |
| `right_hind_leg` | rot | 0.1667:(0,0,90.0)C 0.6667:(0,0,0)C |
| `right_hind_leg` | pos | 0.1667:(-4.0,-5.5,0)C 0.4167:(6.0,-5.5,0)C 0.6667:(0,0,0)C |
| `left_front_leg` | rot | 0:(0,0,-90.0)C 0.4583:(0,0,0)C |
| `left_front_leg` | pos | 0:(4.0,-5.5,0)C 0.2083:(-6.0,-5.5,0)C 0.4583:(0,0,0)C |
| `left_mid_leg` | rot | 0.0833:(0,0,-90.0)C 0.5833:(0,0,0)C |
| `left_mid_leg` | pos | 0.0833:(4.0,-5.5,0)C 0.3333:(-6.0,-5.5,0)C 0.5833:(0,0,0)C |
| `left_hind_leg` | rot | 0.1667:(0,0,-90.0)C 0.6667:(0,0,0)C |
| `left_hind_leg` | pos | 0.1667:(4.0,-5.5,0)C 0.4167:(-6.0,-5.5,0)C 0.6667:(0,0,0)C |

**`SNIFFER_BABY_FALL`**: length 4.0 s, looping no.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `bone` | rot | 1:(-90.0,0,0)C 1.5:(-98.91,0,0)C 1.9583:(-90.0,0,0)C 2.7083:(-68.28,0,0)C 2.9583:(0,0,0)C |
| `bone` | pos | 1:(0,20.0,17.0)C 1.5:(0,25.19,20.37)C 1.9583:(0,20.0,17.0)C 2.7083:(0,17.06,11.25)C 2.8333:(0,9.85,2.2)C 2.9583:(0,0,0)C |
| `body` | scale | 1:(1,1,1)L 1.9583:(1,1,1)L 2.9167:(1,1,1)L 3.0:(1.05,0.95,1.05)L 3.0833:(1,1,1)L |
| `head` | rot | 1:(0,0,0)L 1.2917:(17.5,0,0)L 1.9583:(-10.0,0,0)L 2.75:(35.0,0,0)L 2.9167:(-30.0,0,0)L 3.0417:(7.5,0,0)L 3.125:(0,0,0)L |
| `head` | pos | 1:(0,7.0,19.0)L 1.5:(0,7.0,0)L 1.9583:(0,7.0,0)L 2.75:(0,7.0,0)L 2.9583:(0,0,0)L |
| `left_ear` | rot | 1:(0,0,-5.0)L 1.9583:(0,0,-5.0)L 2.7083:(0,0,-5.0)L 2.9167:(0,0,-90.0)C 3.125:(0,0,-5.0)C |
| `right_ear` | rot | 1:(0,0,5.0)L 1.9583:(0,0,5.0)L 2.7083:(0,0,5.0)L 2.9167:(0,0,90.0)C 3.125:(0,0,5.0)C |
| `right_front_leg` | rot | 1:(0,0,0)L 1.5:(0,0,0)L 1.75:(-15.0,0,0)L 2:(15.0,0,0)L 2.25:(-15.0,0,0)L 2.5:(15.0,0,0)L 2.75:(-15.0,0,0)L 3.0:(0,0,0)L |
| `right_front_leg` | pos | 1:(0,4.0,0)L 1.5:(0,0,0)L |
| `right_mid_leg` | rot | 1:(0,0,0)L 1.375:(0,0,0)L 1.625:(15.0,0,0)L 1.875:(-15.0,0,0)L 2.125:(15.0,0,0)L 2.375:(-15.0,0,0)L 2.625:(15.0,0,0)L 3.0:(0,0,0)L |
| `right_mid_leg` | pos | 1:(0,4.0,0)L 1.5:(0,0,0)L |
| `right_hind_leg` | rot | 1:(0,0,0)L 1.25:(0,0,0)L 1.5:(-15.0,0,0)L 1.75:(15.0,0,0)L 2:(-15.0,0,0)L 2.25:(15.0,0,0)L 2.5:(-15.0,0,0)L 3.0:(0,0,0)L |
| `right_hind_leg` | pos | 1:(0,4.0,0)L 1.5:(0,0,0)L |
| `left_front_leg` | rot | 1:(0,0,0)L 1.5:(0,0,0)L 1.75:(15.0,0,0)L 2:(-15.0,0,0)L 2.25:(15.0,0,0)L 2.5:(-15.0,0,0)L 2.75:(15.0,0,0)L 3.0:(0,0,0)L |
| `left_front_leg` | pos | 1:(0,4.0,0)L 1.5:(0,0,0)L |
| `left_mid_leg` | rot | 1:(0,0,0)L 1.375:(0,0,0)L 1.625:(-15.0,0,0)L 1.875:(15.0,0,0)L 2.125:(-15.0,0,0)L 2.375:(15.0,0,0)L 2.625:(-15.0,0,0)L 3.0:(0,0,0)L |
| `left_mid_leg` | pos | 1:(0,4.0,0)L 1.5:(0,0,0)L |
| `left_hind_leg` | rot | 1:(0,0,0)L 1.25:(0,0,0)L 1.5:(15.0,0,0)L 1.75:(-15.0,0,0)L 2:(15.0,0,0)L 2.25:(-15.0,0,0)L 2.5:(15.0,0,0)L 3.0:(0,0,0)L |
| `left_hind_leg` | pos | 1:(0,4.0,0)L 1.5:(0,0,0)L |

**`SNIFFER_HAPPY`**: length 2.0 s, looping yes.

| Part | Channel | Keyframes (time: x,y,z; interpolation) |
|---|---|---|
| `head` | rot | 0:(0,0,0)L 0.5:(-32.00206,19.3546,-11.70092)C 1:(0,0,0)C 1.5:(-32.00206,-19.3546,11.70092)C 2:(0,0,0)C |
| `left_ear` | rot | 0.5:(0,0,0)C 0.75:(0,0,-67.5)C 0.9583:(0,0,0)C 1.125:(0,0,-67.5)C 1.2917:(0,0,0)C |
| `right_ear` | rot | 0.5:(0,0,0)C 0.75:(0,0,67.5)C 0.9583:(0,0,0)C 1.125:(0,0,67.5)C 1.2917:(0,0,0)C |



---

## 16. Worked examples

| # | Input | Expected |
|---|---|---|
| E1 | Adult wolf walking, p = 1.0, s = 0.5, not angry, not sitting | right hind and left front legs xRot = cos(0.6662) x 1.4 x 0.5 = 0.5503; left hind and right front = -0.5503; tail yRot = 0.5503 (not angry: cos(0.6662) x 1.4 x 0.5). Values with the table cosine differ by about 1e-4 |
| E2 | Wolf shaking, shakeAnim = 0.9, extra = 0 | u = 0.9 / 1.8 = 0.5; sin(0.5 pi) = 1; sin(5.5 pi) = -1; roll = -0.15 pi = -0.4712 |
| E3 | Wolf wet shade, wet, shakeAnim lerped to 1.0 | min(0.75 + (1.0 / 2) x 0.25, 1) = 0.875; the model tint is ARGB (1, 0.875, 0.875, 0.875) |
| E4 | Armor crackiness, max durability 100, damage 40 | f = 0.6 -> below 0.69 and not below 0.32: MEDIUM. Damage 0: f = 1 -> NONE. Damage 70: f = 0.3 -> HIGH |
| E5 | Adult cat sitting, ageScale 1 | body xRot 0.7853982, body y = 12 - 4 = 8, z = -10 + 5 = -5; head y = 15 - 3.3 = 11.7, z = -9 + 1 = -8; tail1 y = 15 + 8 = 23, z = 8 - 2 = 6, xRot 1.7278761 |
| E6 | Adult cat sprinting (not sitting, not crouching), ageScale 1, p = 2.0, s = 0.5 | tail1 xRot = 1.5707964 (step 1; the gait does not rewrite it); tail2 y = tail1 y = 15 (initial), tail2 z = 14 + 2 = 16; tail2 xRot = 1.7278761 + 0.31415927 x cos(2.0) x 0.5 = 1.6625 |
| E7 | Fox baby walking, p = 0.5 | elapsed ms = (long)(0.5 x 50 x 1) = 25 -> t = 0.025 s; loop modulo 0.5 s leaves 0.025. Right hind leg rot channel: keyframes 0 (-35 deg, C), 0.25 (35 deg, L): the later keyframe is index 1 (linear), f = 0.025 / 0.25 = 0.1 -> -35 + 0.1 x 70 = -28 deg; k = min(s x 2.5, 1) |
| E8 | Frog walking, p = 2.0, s = 0.4 | ms = (long)(2.0 x 50 x 1.5) = 150, t = 0.15 s, k = min(0.4 x 2.5, 1) = 1. `left_arm` rot channel between keyframes 0 (0,-5,0) and 0.2917 (7.5,-2.67,-7.5): f = 0.15 / 0.2917 = 0.5142 -> (3.857, -3.802, -3.857) degrees = (0.0673, -0.0664, -0.0673) rad added to the part's rotation |
| E9 | Bat resting, rest state started, ageInTicks - startTick = 0 | t = 0 (clamped to the single keyframe): head rot (180, 0, 0) deg -> xRot += pi; head pos authored (0, 0.5, 0) -> applied (0, -0.5, 0) texels; feet rot 0 |
| E10 | Panda roll, adult, rollTime = 3.5 | k = 3, f = 0.5, k1 = 4 < 8: g = lerp(0.5, 90 x 3 / 7, 90 x 4 / 7) = lerp(0.5, 38.571, 51.429) = 45; translate y = (0.8 + 0.2) x (45 / 90) = 0.5 blocks; rotate about X by -45 degrees. Baby: h = 0.3, translate y = 0.5 x 0.5 = 0.25 |
| E11 | Panda sneezing, sneezeTime = 7 | head xRot = (-0.7853982 x 7) / 14 = -0.3927; sneezeTime = 17: q = 2 / 5 = 0 (integer division) -> -0.7853982; sneezeTime = 20: not < 20, nothing set |
| E12 | Polar bear fully standing (standScale 1), adult, ageScale 1 | e = 1; body xRot -= 1.0996; body y += 2; right and left front leg y -= 20, z += 4, xRot -= 1.4137; head y -= 24, z += 13, xRot += 0.4712 |
| E13 | Turtle on land, p = 1, s = 1, not laying | q = 5; c1 = c2 = cos 5 = 0.2837; right front yRot = -0.2837 x 8 = -2.269; right hind yRot = -0.2837 x 3 = -0.851. Laying: c1 = cos 20 = 0.4081, f2 = 2: right front yRot = -0.4081 x 8 x 2 = -6.529 |
| E14 | Armadillo ROLLING state | at inStateTicks = 5 the animal is not yet hidden; at 6 it hides (body skipped, legs and tail hidden, `cube` shown); UNROLLING hides it for inStateTicks 0 to 25 |
| E15 | Bee flying in air | wing flap angle w = A x 120.32113 x 0.017453292 radians; with A = 1: w = 2.1 -> right wing zRot = cos(2.1) x pi x 0.15 = -0.2379; left wing = +0.2379; both wing yRot = 0 |
| E16 | Parrot flapAngle, flap = 0, oFlap = 0, flapSpeed = 0.5, oFlapSpeed = 0.5 | (sin(0) + 1) x 0.5 = 0.5 |
| E17 | Cat collar tint | dye red -> RGB B02E26 with alpha 255; texture `cat_collar.png` adult, `cat_collar_baby.png` baby |
| E18 | Polar bear adult model scaling | root pose becomes pos(0, 0 + 24.016 x (1 - 1.2) = -4.8032, 0), scale 1.2: a point at the ground plane y = 24.016 texels maps to 24.016 x 1.2 - 4.8032 = 24.016 |

---

## 17. Validation

| Check | Result |
|---|---|
| Keyframe counts | the number of `Keyframe` constructor calls in the bytecode of each animation class equals the number parsed into the tables of 15: fox baby 30, bat 51, frog 185, armadillo adult 362, armadillo baby 393, sniffer 524; channel counts 18, 20, 43, 51, 59, 99 |
| Mesh tables | every `addOrReplaceChild` of every `create*` mesh method is a row; the number of rows equals the number of such calls in each method (wolf 10, wolf baby 10, feline 8, feline baby 8, fox 10, fox baby 7, panda 6, panda baby 6, polar bear 6, polar bear baby 6, parrot 11, bat 9, bee 10, bee baby 8, bee stinger 2, armadillo 13, armadillo baby 12, frog 16, tadpole 2, turtle 7, turtle baby 6, sniffer 13, snifflet 13) |
| Animation part names | every part name used by every animation table exists as a part name in the mesh table of the model that plays it (checked by script for all six animation classes against their meshes; the sniffer animations against both the adult and the snifflet mesh) |
| Where a ternary of two constants appears in the bytecode | the branch assignment was resolved from the branch condition (for example the cat collar texture, panda `rollTime`, parrot shoulder offsets), not from operand order alone |
| Implementer checks | build each mesh, apply E1 to E18, and compare the part transforms; compare model silhouettes against a reference render of the extracted vanilla pack textures (Open question 2) |

---

## Open questions

1. Texture offsets can be negative (baby bee left wing u = -3, baby turtle legs u = -1): the model reads texels left of the image. Not traced: the texture sampler's wrap or clamp rule for entity textures (14 §5.2 says the client samples by fraction); the faces affected are tiny wing and leg quads.
2. Pixel-exact face orientation (which edge of each face rectangle is up, and the mirrored-box result) was inferred from the `Cube` and `Polygon` constructors and 14 §5.3, not checked against a rendered reference.
3. Entity classes were read only for the helpers called by the render states. The logic that starts the frog, sniffer and armadillo (peek) animation states, the pose choice of the parrot (party jukebox range) and the pose logic beyond the counters read here belongs to the mob documents (19 sections for the land animals, 44-residual-mob-questions-4 sections 4 to 10 for fox, wolf, cat, panda, polar bear, goat and frog) and was not re-read here except where stated. The entity-side counters of sections 3.5, 4.3, 5.4, 6, 8 and 10.3 (and the bee, wolf and parrot counters) were read from the entity classes in the review round and match; no counter is left unread.
4. Variant data fields were read: wolf (`assets`, `baby_assets`, each `angry`/`tame`/`wild`; 9 variant files, see §2.4), cat (`asset_id`, `baby_asset_id`, for example `entity/cat/cat_tabby` and `entity/cat/cat_tabby_baby`; 11 variant files) and frog (single `asset_id`, for example `entity/frog/frog_cold`; 3 variant files). The panda gene to texture mapping is code, not data, and is resolved in §5.4 (14 fixed paths). Still open: the spawn-condition and variant-selection data of those JSON files (biome conditions, priorities) belongs to the mob documents and the data extraction (22, 23) and was not specified here.
5. The equipment renderer (`EquipmentLayerRenderer.renderLayers`) and the `StuckInBodyLayer` placement used by the bee stinger layer are framework or player-layer pieces and are not specified here (34-entity-models-1 section 8.2 for the equipment renderer; the player-layer placement of the bee stinger is not specified in any part of 34 read for this round).
6. The `Mth.rotLerp` degrees quirk of §1.1 means that a pose lerp spanning more than pi radians would behave differently from a plain lerp; no call here spans that much, but this was checked only by reading the constants.
7. Closed as read: the renderer classes of all 14 mobs declare only these methods beyond the constructor, texture lookup and `extractRenderState`: wolf `getModelTint`; cat, fox and panda `setupRotations` (panda also `getAngle`); turtle `getShadowRadius`; sniffer `getBoundingBoxForCulling` (box inflated by 0.6). None overrides scale, name tag, leash, fire or `shouldShowName`, so the generic rules of 34-entity-models-1 sections 7.2 to 7.4 apply. Still open: per-mob leash offsets live in the entity classes and are not enumerated (18 section 1 for bounding box, eye height and name tag offsets).
