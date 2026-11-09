# Entity models and renderers, part 6: creeper, enderman, endermite, silverfish, spiders, slimes and sulfur cube, warden, breeze, phantom, guardians, shulker and shulker bullet

| Item | Value |
|---|---|
| Covers | Geometry (part trees, cuboids, texture offsets), per-frame animation formulas, keyframe animation tables, renderer behaviour (scale hooks, layers, render types, shadow, flip, overlay), render-state fields and the entity-side inputs that feed them, for: `creeper`, `enderman`, `endermite`, `silverfish`, `spider`, `cave_spider`, `slime`, `magma_cube`, `sulfur_cube`, `warden`, `breeze`, `phantom`, `guardian`, `elder_guardian`, `shulker`, `shulker_bullet`. Includes the guardian beam, the elder guardian apparition particle, and the two keyframe tables `WardenAnimation` (6 animations) and `BreezeAnimation` (6 animations). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for constant pools and bootstrap tables) with no execution. The two keyframe tables and the arrays `BODY_SIZES`, `BODY_TEXS`, `SPIKE_*` were extracted by a script that only parses `javap` output. In round RS17 fix both keyframe tables were re-extracted by a second script from the bytecode (animation length, looping flag, bone, channel, every keyframe time, vector and interpolation) and diffed against 8.6 and 9.5: all 482 warden channel keyframes plus all Breeze keyframes now agree exactly, after 9 Warden rows whose long values had been rounded to six significant digits were rewritten with the artifact's literals (for example 112.283 became 112.28261). PNG dimensions were read from the 24-byte file header with `unzip`-style access to the jar. A second RS17 fix pass re-read `SulfurCubeRenderer.extractRenderState`, the HEAD-slot code of `LivingEntityRenderer.extractRenderState`, `Sheets` and `ShulkerRenderer` (texture path), and the call sites of the client particle and sound code in `Warden`, `Breeze` and `Enderman`. File counts use `unzip -Z1 ... \| grep -v '/$'`. |
| Round | RS17, part 6 (GAP-25 of `../design/README.md` Part 5). Sibling parts: `34-entity-models-1-shared-model-and-framework.md` (framework, cited as "34-1 §N") and the other parts. |
| Data versus code | Textures (`textures/entity/**`) are DATA supplied by the pack tool (22); only their declared texel sizes and the rules that choose them are stated. All geometry, animation tables, renderer behaviour and the model-layer wiring are CODE and are specified completely below. |
| Generic per-entity attachments | Name tag position, passenger offsets and the mount point (for example a rider on the spider) are 18 section 1.1.1; name tag, leash and fire rendering are 34-1 sections 7.2 to 7.4; hitbox sizes and eye heights are 21 section 2. None of the sixteen types is described here for those points beyond what the sections below state, and none of them was read to differ from the generic rule (not traced per type). |
| Out of scope | Server-side behaviour of these mobs (20, 21, 18), the skull and head-item renderers (34-1 §8.4 gives the layer; the skull models are not part of this part), the generic render pipeline pieces (34-1 §6, §7), the particle engine apart from the elder guardian particle. |

Section references use "12 §7.4", "14 §5.3", "20", "21 §2" for other documents and "§3" for sections of this one. "Read" means read in the artifact this round. "(inferred)" marks values deduced from what was read. "(recalled, not verified)" marks statements not read; each is listed in Open questions. Class and method names in backticks say where a fact was read and are not a design.

## 0. Reader's map and relation to part 1

| Question | Section |
|---|---|
| What conventions do the part tables use, and what is shared? | 1 |
| Summary of all sixteen renderers (model layer, texture size, shadow, flip, layers) | 1.3 |
| Creeper (swell scale, white flash, charged swirl) | 2 |
| Enderman (humanoid-derived model, carried block, creepy head, shaking) | 3 |
| Endermite and silverfish (segment wave) | 4, 5 |
| Spider and cave spider (eight legs, scaled mesh) | 6 |
| Slime, magma cube, sulfur cube (size, squish, outer and inner layers, contained block) | 7 |
| Warden (model, walk, idle, tendrils, six keyframe animations, five emissive layers) | 8 |
| Breeze (model, three layer meshes, six keyframe animations, wind and eyes layers) | 9 |
| Phantom | 10 |
| Guardian, elder guardian, beam, apparition particle | 11 |
| Shulker | 12 |
| Shulker bullet | 13 |
| Render types and pipelines used here | 14 |
| Worked examples and checks | 15 |
| Gaps | 16 |

Allocation. The master index of 34-1 section 10 now lists all sixteen types under part 6 (breeze, cave_spider, creeper, elder_guardian, enderman, endermite, guardian, magma_cube, phantom, shulker, shulker_bullet, silverfish, slime, spider, sulfur_cube, warden); 34-1 section 5.6 says "breeze and warden in part 6" and 34-1 section 2.2 points to "34 part 6 section 6" for the cave spider. This document is the authoritative description of them (the earlier index mismatch is resolved).

---

## 1. Shared facts used by this part

### 1.1 Reading the part tables

The conventions of 34-1 §1 apply unchanged: lengths are pixels (1/16 block); model space has x towards the mob's left, y down, and the front of a cuboid is its minimum-z face (34-1 §1.1); rotations are radians; a part's rotation is built with `rotationZYX(zRot, yRot, xRot)` (34-1 §1.1, Open question 3 there); the box unwrap and mirror rule are 34-1 §1.3 (and 12 §7.4 for the face rectangles). `ModelPart$Cube` builds the face rectangles from u0 = u, u1 = u + d, u2 = u + d + w, u3 = u + 2d + w, u4 = u + 2d + 2w and v0 = v, v1 = v + d, v2 = v + d + h; the model-space faces `DOWN` and `UP` take u1..u2 and u2..u3 on rows v0..v1, `WEST` u0..u1, `NORTH` u1..u2, `EAST` u2..u3 and `SOUTH` u3..u4 on rows v1..v2, which agrees with 12 §7.4 because model +y is world down. Mirroring swaps the x extent of the box (and the polygon is built with the mirror flag).

Table columns: **pivot** = `PartPose.offset(x, y, z)` in pixels, **rot** = pose rotation in radians (0 when omitted), **box** = cuboid origin (ox, oy, oz) and size (w, h, d), **tex** = texture offset (u, v), **grow** = `CubeDeformation` (0 when omitted). A child part's pivot is relative to its parent. Model bake: `PartDefinition.bake(texW, texH)` (34-1 §2.1).

Every model's `setupAnim` first calls `Model.setupAnim`, which resets every part of the model to its initial pose (`resetPose` over `allParts`); then the formulas below add or assign (read). Keyframe animations are additive on top (34-1 §5).

Layer models (a second instance of a model class baked from another layer id) are posed by the feature renderer: `ModelFeatureRenderer` calls `Model.setupAnim(state)` on the model it is given when it draws it (read: an invoke of `Model.setupAnim` in `ModelFeatureRenderer`). So every layer model below runs the same `setupAnim` formulas on the same state as the main model.

`MeshTransformer.scaling(s)` (34-1 §2.2): only the root part's pose is changed: `pose.scaled(s)` (position and the three scale values multiplied by s; when s = 1 the pose is unchanged) then `translated(0, 24.016 x (1 - s), 0)`. Since a child inherits the root's matrix, the net effect is that every vertex moves to y' = 24.016 x (1 - s) + s x y (pixels) with x and z multiplied by s. Read: `MeshTransformer.lambda$scaling$1`, `PartDefinition.transformed` (it rebuilds the part with the transformed pose and copies the children map).

`PartDefinition.addOrReplaceChild(name, builder, pose)`: replacing an existing child keeps the old child's own children (`children.putAll`), only its cubes and pose change (read). This matters for the layer meshes of the warden and the breeze (8.5, 9.1).

`retainExactParts(names)` (warden layers): for each child c of a part with name k: if k is in `names`, `c.clearRecursively()` (every descendant of c is replaced by a part with the same pose and no cubes; c keeps its own cubes and pose); otherwise c is replaced by a part with the same pose and **no cubes** and the rule is applied to its children. Result: exactly the named parts keep their own cubes, except that a named part's descendants are always emptied, even when they are named too. `retainPartsAndChildren(names)` (breeze layers): for each child c with name k: if k is in `names` c is left untouched (cubes and the whole subtree); otherwise c is replaced by a part with no cubes and the rule is applied to its children. Read: `PartDefinition.retainExactParts`, `retainPartsAndChildren`, `clearRecursively`, `clearChild`.

### 1.2 Render-state fields used (inherited from 34-1 §6.3)

`LivingEntityRenderState`: `ageInTicks`, `walkAnimationPos`, `walkAnimationSpeed`, `yRot`, `xRot` (head angles in degrees relative to the body, after body-yaw handling), `yBodyRot`, `yHeadRot`, `bodyRot`, `isBaby`, `isInvisible`, `isInvisibleToPlayer`, `appearsGlowing`, `hasRedOverlay`, `deathTime`, `lightCoords`, `outlineColor`, `scale`, `eyeHeight`, `boundingBoxHeight`. The extra fields of each renderer are in the sections below. Degrees to radians uses the float constant 0.017453292 everywhere in this part (read).

### 1.3 Summary table (one row per renderer; read from the constructors)

Texture sizes are the `LayerDefinition.create(mesh, W, H)` arguments (confirmed equal to the PNG dimensions of the artifact, 15.7). "Flip" is `getFlipDegrees()` (the death roll about Z, 34-1 §6.5; default 90).

| Entity type | Renderer, state class | Main model layer (texture W x H) | Shadow radius | Flip | Layers added, in order |
|---|---|---|---|---|---|
| creeper | `CreeperRenderer`, `CreeperRenderState` (`swelling`, `isPowered`) | `CREEPER` = `CreeperModel.createBodyLayer(NONE)` (64 x 32) | 0.5 | 90 | `CreeperPowerLayer` (model `CREEPER_ARMOR` = grow 2.0) |
| enderman | `EndermanRenderer`, `EndermanRenderState` (humanoid state + `isCreepy`, `carriedBlock`) | `ENDERMAN` (64 x 32) | 0.5 | 90 | `EnderEyesLayer`, `CarriedBlockLayer` |
| endermite | `EndermiteRenderer`, plain `LivingEntityRenderState` | `ENDERMITE` (64 x 32) | 0.3 | 180 | none |
| silverfish | `SilverfishRenderer`, plain `LivingEntityRenderState` | `SILVERFISH` (64 x 32) | 0.3 | 180 | none |
| spider | `SpiderRenderer`, plain `LivingEntityRenderState` | `SPIDER` (64 x 32) | 0.8 | 180 | `SpiderEyesLayer` |
| cave spider | `CaveSpiderRenderer` (extends `SpiderRenderer`) | `CAVE_SPIDER` = spider mesh scaled 0.7 (64 x 32) | 0.8 then set to 0.56 | 180 | `SpiderEyesLayer` |
| slime | `SlimeRenderer`, `SlimeRenderState` (`squish`, `size`) | `SLIME` = `SlimeModel.createInnerBodyLayer()` (64 x 32) | 0.25 x size | 90 | `SlimeOuterLayer` (model `SLIME_OUTER`) |
| magma cube | `MagmaCubeRenderer`, `SlimeRenderState` | `MAGMA_CUBE` (64 x 64) | 0.25 x size | 90 | none |
| sulfur cube | `SulfurCubeRenderer`, `SulfurCubeRenderState` | `SULFUR_CUBE` (128 x 128) adult, `SULFUR_CUBE_SMALL` (64 x 64) baby | 0.25 x size | 90 | `SulfurCubeInnerLayer`, `CustomHeadLayer` |
| warden | `WardenRenderer`, `WardenRenderState` | `WARDEN` (128 x 128) | 0.9 | 90 | five `LivingEntityEmissiveLayer` (8.5) |
| breeze | `BreezeRenderer`, `BreezeRenderState` | `BREEZE` (32 x 32) | 0.5 | 90 | `BreezeWindLayer`, `BreezeEyesLayer` |
| phantom | `PhantomRenderer`, `PhantomRenderState` (`flapTime`, `size`) | `PHANTOM` (64 x 64) | 0.75 | 90 | `PhantomEyesLayer` |
| guardian | `GuardianRenderer`, `GuardianRenderState` | `GUARDIAN` (64 x 64) | 0.5 | 90 | none (the beam is drawn by `submit`) |
| elder guardian | `ElderGuardianRenderer` (extends `GuardianRenderer`) | `ELDER_GUARDIAN` = guardian mesh scaled 2.35 (64 x 64) | 1.2 | 90 | none |
| shulker | `ShulkerRenderer`, `ShulkerRenderState` | `SHULKER` (64 x 64) | 0 | 90 | none |
| shulker bullet | `ShulkerBulletRenderer` (plain entity renderer), `ShulkerBulletRenderState` | `SHULKER_BULLET` (64 x 32) | not set (0) | n/a | none |

Cube mob shadow: `AbstractCubeMobRenderer.getShadowRadius(state)` = `size` x 0.25, with base ctor value 0.25 (34-1 §6.6). Entity sizes: 21 §2.

---

## 2. Creeper (`CreeperModel`, `CreeperRenderer`, `CreeperPowerLayer`)

### 2.1 Geometry (64 x 32; layer parameter `d` = the `CubeDeformation` passed to `createBodyLayer`)

| Part | pivot | box (origin; size) | tex | grow |
|---|---|---|---|---|
| `head` | (0, 6, 0) | (-4, -8, -4); 8 x 8 x 8 | (0, 0) | d |
| `body` | (0, 6, 0) | (-4, 0, -2); 8 x 12 x 4 | (16, 16) | d |
| `right_hind_leg` | (-2, 18, 4) | (-2, 0, -2); 4 x 6 x 4 | (0, 16) | d |
| `left_hind_leg` | (2, 18, 4) | same box | (0, 16) | d |
| `right_front_leg` | (-2, 18, -4) | same box | (0, 16) | d |
| `left_front_leg` | (2, 18, -4) | same box | (0, 16) | d |

The four legs share one cuboid definition. Layers: `CREEPER` uses d = 0 (`CubeDeformation.NONE`); `CREEPER_ARMOR` uses d = 2.0 (a `CubeDeformation(2)`, read in `LayerDefinitions`), so every cuboid of the armor mesh is 2 pixels larger on every side while keeping the same texture rectangles. The constant `Y_OFFSET = 6` is declared in the class and equals the head and body pivot y. Feet: pivot y 18 + height 6 = 24.

### 2.2 `setupAnim`

Let w = `walkAnimationPos`, s = `walkAnimationSpeed`, theta = w x 0.6662.

- `head.yRot` = `yRot` x 0.017453292; `head.xRot` = `xRot` x 0.017453292 (assigned).
- Leg x rotations are assigned (not added). The constructor stores the children under crossed field names (the field named right hind leg reads child `left_hind_leg` and so on), and the formulas use those fields, so by child name: `left_hind_leg` and `right_front_leg`: cos(theta) x 1.4 x s; `right_hind_leg` and `left_front_leg`: cos(theta + 3.1415927) x 1.4 x s. (Diagonal pairs move together.) Implementer note: the crossing of field names and child names is deliberate in the artifact (verified again in round RS17 fix); do not "correct" it. Always key the leg rotations by child name as listed here.

### 2.3 Renderer

- `scale(state, pose)`: with k = `swelling`: f = 1 + sin(k x 100) x k x 0.01 (the sine takes radians); c = clamp(k, 0, 1); c4 = (c x c) x (c x c); scale by (x, y, z) = ((1 + c4 x 0.4) x f, (1 + c4 x 0.1) / f, (1 + c4 x 0.4) x f). Applied at step 5 of the pose order (34-1 §6.5).
- `getWhiteOverlayProgress(state)`: if trunc(k x 10) is even the value is 0; otherwise clamp(k, 0.5, 1). The overlay coordinates are built from this value: u = trunc(value x 15) in the white row (34-1 §6.9). So the creeper flashes on odd tenths of the swell: at k = 0.5 the value is 0.5 (u = 7), at k = 1.0 the value is 1.0 (u = 15).
- Texture: `textures/entity/creeper/creeper.png`.
- `extractRenderState`: `swelling` = `Creeper.getSwelling(partial)` = lerp(partial, oldSwell, swell) / (maxSwell - 2) (read; maxSwell default and the swell tick are 20 §creeper); `isPowered` = `Creeper.isPowered()`.

### 2.4 `CreeperPowerLayer` (an `EnergySwirlLayer`, 34-1 §8.5)

Drawn when `state.isPowered`. Model: a second `CreeperModel` baked from `CREEPER_ARMOR`. `xOffset(t)` = t x 0.01, so the texture offset is u = (age x 0.01) mod 1 and v = (age x 0.01) mod 1 where age = `ageInTicks` (the base class passes `xOffset(age) mod 1` and `(age x 0.01) mod 1`). Texture `textures/entity/creeper/creeper_armor.png` (64 x 32), render type `energySwirl` (additive blend, 14), tint ARGB -8355712 = 0xFF808080, no overlay, entity light, draw order 1 (after the base model).

---

## 3. Enderman (`EndermanModel`, `EndermanRenderer`, `EnderEyesLayer`, `CarriedBlockLayer`)

### 3.1 Geometry (64 x 32). The model extends `HumanoidModel` (12 §7.4, 34-1 §3.7); the mesh starts from `HumanoidModel.createMesh(NONE, -14)` and every humanoid part is replaced (replacement keeps old children, so only the parts below exist after replacement).

| Part | pivot | box (origin; size) | tex | grow / mirror |
|---|---|---|---|---|
| `head` | (0, -13, 0) | (-4, -8, -4); 8 x 8 x 8 | (0, 0) | none |
| `hat` (child of head) | (0, 0, 0) | (-4, -8, -4); 8 x 8 x 8 | (0, 16) | grow -0.5 on all axes |
| `body` | (0, -14, 0) | (-4, 0, -2); 8 x 12 x 4 | (32, 16) | none |
| `right_arm` | (-5, -12, 0) | (-1, -2, -1); 2 x 30 x 2 | (56, 0) | none |
| `left_arm` | (5, -12, 0) | (-1, -2, -1); 2 x 30 x 2 | (56, 0) | mirrored |
| `right_leg` | (-2, -5, 0) | (-1, 0, -1); 2 x 30 x 2 | (56, 0) | none |
| `left_leg` | (2, -5, 0) | (-1, 0, -1); 2 x 30 x 2 | (56, 0) | mirrored |

The leg bottom is at y = -5 + 30 = 25 pixels, one pixel below the nominal foot line of 24.

### 3.2 `setupAnim` (`EndermanModel.setupAnim`, run after the humanoid pose code of 12 §7.5)

1. `HumanoidModel.setupAnim(state)` (head angles, arm and leg swing, held-arm poses, per 12 §7.5).
2. `head.visible` = true.
3. `right_arm.xRot`, `left_arm.xRot`, `right_leg.xRot`, `left_leg.xRot` are each multiplied by 0.5, then each clamped to [-0.4, 0.4].
4. When `carriedBlock` is **not** empty: both arms `xRot` = -0.5; `right_arm.zRot` = 0.05; `left_arm.zRot` = -0.05 (assigned).
5. When `isCreepy`: `head.y` = `head.y` - 5 and `hat.y` = `hat.y` + 5 (the head rises 5 pixels; the hat, being a child, stays at its previous world height).

### 3.3 Renderer

- Texture `textures/entity/enderman/enderman.png`. Shadow 0.5, flip 90.
- `extractRenderState`: `HumanoidMobRenderer.extractHumanoidRenderState` (34-1 §6.6), then `isCreepy` = `Enderman.isCreepy()`, and `carriedBlock` is updated from `Enderman.getCarriedBlock()` through the block model resolver with the default `BlockDisplayContext` (`BLOCK_DISPLAY_CONTEXT = BlockDisplayContext.create()`), or cleared when no block is carried.
- `getRenderOffset(state)`: the base offset; when `isCreepy`, add (g1 x 0.02 x `scale`, 0, g2 x 0.02 x `scale`) where g1 and g2 are two successive `nextGaussian()` draws of the renderer's own `RandomSource` (created once with `RandomSource.create()`, so unseeded). x gets the first draw, z the second. The shake is therefore re-rolled every frame.
- Entity-side client effects (`Enderman.aiStep`, `onSyncedDataUpdated`): while on the client, each tick `aiStep` adds `PORTAL` particles spread about the entity (positions from `getRandomX(0.5)`, `getRandomY()` - 0.25, `getRandomZ(0.5)`, velocity from `(nextDouble - 0.5) x 2`; the count per tick and loop structure were not traced); a change of one synced data item on the client calls `playStareSound()` (a local sound at the entity, volume 2.5; which data item was not traced). Particle definitions belong to 42 (Open question 16).
- `EnderEyesLayer` (an `EyesLayer`, 34-1 §8.5): re-submits the parent's posed model at order 1 with `RenderTypes.eyes(textures/entity/enderman/enderman_eyes.png)`.
- `CarriedBlockLayer`: skip when the carried block is empty. Otherwise, in the parent's pose (after the renderer's flip and scale, not attached to any part), in stack order: translate (0, 0.6875, -0.75); rotate X by 20 degrees; rotate Y by 45 degrees; translate (0.25, 0.1875, 0.25); scale (-0.5, -0.5, 0.5); rotate Y by 90 degrees; then `carriedBlock.submit(pose, collector, light, NO_OVERLAY, outlineColor)` (the resolved block model state draws itself; Open question 10).

---

## 4. Endermite (`EndermiteModel`, `EndermiteRenderer`)

Plain `LivingEntityRenderState`; no layers. Texture `textures/entity/endermite/endermite.png`. Shadow 0.3, flip 180.

### 4.1 Geometry (64 x 32)

Four segments named `segment0` to `segment3`, children of the root. Constants (read): `BODY_COUNT` = 4; size table `BODY_SIZES[i]` = (w, h, d) and texture offsets `BODY_TEXS[i]` = (u, v):

| i | size (w, h, d) | tex |
|---|---|---|
| 0 | (4, 3, 2) | (0, 0) |
| 1 | (6, 4, 5) | (0, 5) |
| 2 | (3, 3, 1) | (0, 14) |
| 3 | (1, 2, 1) | (0, 18) |

Segment i: cuboid origin (-w x 0.5, 0, -d x 0.5), size (w, h, d), tex `BODY_TEXS[i]`; pivot (0, 24 - h, z_i). z_0 = -3.5 and z_(i+1) = z_i + (d_i + d_(i+1)) x 0.5. Result: z = (-3.5, 0, 3, 4); pivot y = (21, 20, 21, 22); the segment bottoms are all at y = 24.

### 4.2 `setupAnim`

For segment i (0 to 3) with a = `ageInTicks` x 0.9 + i x 0.15 x 3.1415927:
- `yRot` = cos(a) x 3.1415927 x 0.01 x (1 + |i - 2|)
- `x` (pivot x, assigned) = sin(a) x 3.1415927 x 0.1 x |i - 2|

Segment 2 never moves sideways (|i - 2| = 0 in the second formula).

---

## 5. Silverfish (`SilverfishModel`, `SilverfishRenderer`)

Plain `LivingEntityRenderState`; no layers. Texture `textures/entity/silverfish/silverfish.png`. Shadow 0.3, flip 180.

### 5.1 Geometry (64 x 32)

Seven body segments `segment0` to `segment6` and three layer boxes `layer0` to `layer2`, all children of the root. `BODY_COUNT` = 7.

| i | size (w, h, d) | tex | pivot y = 24 - h | z_i |
|---|---|---|---|---|
| 0 | (3, 2, 2) | (0, 0) | 22 | -3.5 |
| 1 | (4, 3, 2) | (0, 4) | 21 | -1.5 |
| 2 | (6, 4, 3) | (0, 9) | 20 | 1.0 |
| 3 | (3, 3, 3) | (0, 16) | 21 | 4.0 |
| 4 | (2, 2, 3) | (0, 22) | 22 | 7.0 |
| 5 | (2, 1, 2) | (11, 0) | 23 | 9.5 |
| 6 | (1, 1, 2) | (13, 4) | 23 | 11.5 |

Segment i: cuboid origin (-w x 0.5, 0, -d x 0.5), size (w, h, d), pivot (0, 24 - h, z_i); z_0 = -3.5, z_(i+1) = z_i + (d_i + d_(i+1)) x 0.5.

Layer boxes (the stripes on the back), as read (note the layer 2 box takes its origin z from segment 4 and its depth from segment 1):

| Part | tex | box (origin; size) | pivot |
|---|---|---|---|
| `layer0` | (20, 0) | (-5, 0, -1.5); 10 x 8 x 3 (-d_2 x 0.5, d_2) | (0, 16, z_2 = 1.0) |
| `layer1` | (20, 11) | (-3, 0, -1.5); 6 x 4 x 3 (-d_4 x 0.5, d_4) | (0, 20, z_4 = 7.0) |
| `layer2` | (20, 18) | (-3, 0, -1.5); 6 x 5 x 2 (origin z = -d_4 x 0.5, depth d_1) | (0, 19, z_1 = -1.5) |

### 5.2 `setupAnim`

For segment i (0 to 6) with a = `ageInTicks` x 0.9 + i x 0.15 x 3.1415927:
- `yRot` = cos(a) x 3.1415927 x 0.05 x (1 + |i - 2|)
- `x` = sin(a) x 3.1415927 x 0.2 x |i - 2|

Then the layers copy their segments: `layer0.yRot` = `segment2.yRot`; `layer1.yRot` = `segment4.yRot` and `layer1.x` = `segment4.x`; `layer2.yRot` = `segment1.yRot` and `layer2.x` = `segment1.x`. (`layer0.x` is not copied: segment 2 has x offset 0.)

---

## 6. Spider and cave spider (`SpiderModel`, `SpiderRenderer`, `CaveSpiderRenderer`, `SpiderEyesLayer`)

### 6.1 Geometry (64 x 32). One mesh, `SpiderModel.createSpiderBodyLayer()`; the cave spider layer is the same mesh through `MeshTransformer.scaling(0.7)`.

| Part | pivot | rot (x, y, z) | box (origin; size) | tex |
|---|---|---|---|---|
| `head` | (0, 15, -3) | 0 | (-4, -4, -8); 8 x 8 x 8 | (32, 4) |
| `body0` | (0, 15, 0) | 0 | (-3, -3, -3); 6 x 6 x 6 | (0, 0) |
| `body1` | (0, 15, 9) | 0 | (-5, -4, -6); 10 x 8 x 12 | (0, 12) |
| `right_hind_leg` | (-4, 15, 2) | (0, 0.7853982, -0.7853982) | right box: (-15, -1, -1); 16 x 2 x 2 | (18, 0) |
| `left_hind_leg` | (4, 15, 2) | (0, -0.7853982, 0.7853982) | left box: (-1, -1, -1); 16 x 2 x 2, mirrored | (18, 0) |
| `right_middle_hind_leg` | (-4, 15, 1) | (0, 0.3926991, -0.58119464) | right box | (18, 0) |
| `left_middle_hind_leg` | (4, 15, 1) | (0, -0.3926991, 0.58119464) | left box | (18, 0) |
| `right_middle_front_leg` | (-4, 15, 0) | (0, -0.3926991, -0.58119464) | right box | (18, 0) |
| `left_middle_front_leg` | (4, 15, 0) | (0, 0.3926991, 0.58119464) | left box | (18, 0) |
| `right_front_leg` | (-4, 15, -1) | (0, -0.7853982, -0.7853982) | right box | (18, 0) |
| `left_front_leg` | (4, 15, -1) | (0, 0.7853982, 0.7853982) | left box | (18, 0) |

Cave spider: root pose scale 0.7 and shift 24.016 x 0.3 = 7.2048 pixels (rule in 1.1): every vertex goes to (0.7 x, 7.2048 + 0.7 y, 0.7 z).

### 6.2 `setupAnim`

Let theta = `walkAnimationPos` x 0.6662, s = `walkAnimationSpeed`. Phases phi: hind 0, middle hind pi (3.1415927), middle front pi/2 (1.5707964), front 3 pi/2 (4.712389).

- `head.yRot` = `yRot` x 0.017453292, `head.xRot` = `xRot` x 0.017453292 (assigned).
- For each pair, with A(phi) = -(cos(2 x theta + phi) x 0.4) x s and B(phi) = |sin(theta + phi) x 0.4| x s: the right leg gets `yRot` += A, `zRot` += B; the left leg gets `yRot` -= A, `zRot` -= B (added to the pose angles of 6.1). Pairs: hind uses phi = 0, middle hind phi = pi, middle front phi = pi/2, front phi = 3 pi/2.

### 6.3 Renderer

- `SpiderRenderer(context, layer)` builds the model from the given layer, shadow 0.8, flip 180, and adds `SpiderEyesLayer`. `CaveSpiderRenderer` calls it with `CAVE_SPIDER`, then sets `shadowRadius` = 0.56 (read).
- Textures: spider `textures/entity/spider/spider.png`; cave spider `textures/entity/spider/cave_spider.png`. There is one eyes texture for both, `textures/entity/spider/spider_eyes.png` (read: `SpiderEyesLayer` has a single `RenderTypes.eyes(spider_eyes.png)`; there is no cave-spider eyes file in the artifact).
- `SpiderEyesLayer` (an `EyesLayer`): re-submits the parent's posed model (so the cave spider's eyes are scaled too) with the eyes render type, order 1.

---

## 7. Slime, magma cube and sulfur cube

### 7.1 Slime geometry (64 x 32). Two layer meshes, each with root pose zero.

`SLIME` (the base model, `createInnerBodyLayer`):

| Part | box (origin; size) | tex |
|---|---|---|
| `cube` | (-3, 17, -3); 6 x 6 x 6 | (0, 16) |
| `right_eye` | (-3.25, 18, -3.5); 2 x 2 x 2 | (32, 0) |
| `left_eye` | (1.25, 18, -3.5); 2 x 2 x 2 | (32, 4) |
| `mouth` | (0, 21, -3.5); 1 x 1 x 1 | (32, 8) |

`SLIME_OUTER` (`createOuterBodyLayer`): one part `cube`, box (-4, 16, -4); 8 x 8 x 8, tex (0, 0). All parts have pivot (0, 0, 0): the y values above are absolute pixels (feet at y = 24). `SlimeModel` has no `setupAnim` of its own (only the base pose reset).

### 7.2 Magma cube geometry (64 x 64)

Eight slices `cube0` to `cube7` plus `inside_cube`, all with pivot (0, 0, 0). Slice i (0 to 7): box origin (-4, 16 + i, -4), size 8 x 1 x 8; texture offset (u, v): for i = 0: (0, 0); for 0 < i < 4: (0, 9 i); for i >= 4: (32, 9 i - 36). So the offsets are (0, 0), (0, 9), (0, 18), (0, 27), (32, 0), (32, 9), (32, 18), (32, 27). `inside_cube`: box (-2, 18, -2); 4 x 4 x 4, tex (24, 40). Constant `SEGMENT_COUNT` = 8.

`setupAnim(state)`: for each slice i: `y` = (-(4 - i)) x max(0, `squish`) x 1.7 (assigned; the pivot y is otherwise 0). With `squish` = 0.5 the slice pivots are y = -3.4, -2.55, -1.7, -0.85, 0, 0.85, 1.7, 2.55 pixels. `inside_cube` does not move.

### 7.3 Sulfur cube geometry (class `SulfurCubeModel`, `SmallSulfurCubeModel`; both implement `HeadedModel` with `getHead()` = child `cube`)

| Layer | Texture W x H | `cube` box (origin; size) | tex |
|---|---|---|---|
| `SULFUR_CUBE` (outer, adult) | 128 x 128 | (-9, -9, -9); 18 x 18 x 18 | (0, 0) |
| `SULFUR_CUBE_INNER` (adult inner) | 128 x 128 | (-8, -8, -8); 16 x 16 x 16 | (0, 36) |
| `SULFUR_CUBE_SMALL` (outer, baby) | 64 x 64 | (-5, -5, -5); 10 x 10 x 10 | (0, 0) |
| `SULFUR_CUBE_SMALL_INNER` | 64 x 64 | (-4, -4, -4); 8 x 8 x 8 | (0, 20) |

Pivot (0, 0, 0); the cube is centred on the part origin (unlike the slime, which is absolute). The model has no `setupAnim`. Its base render function is `entityTranslucent` (read), and `SmallSulfurCubeModel` extends `SulfurCubeModel`.

### 7.4 Common renderer behaviour (`AbstractCubeMobRenderer`; 34-1 §6.6 states the same formula)

- `extractRenderState`: `squish` = lerp(partial, `oSquish`, `squish`) of the entity; `size` = `getSize()` (the Size data value, clamped to 1..127 by `setSize`; saved as Size - 1).
- `scale(state, pose)`: the super hook (nothing), then `applySizeAndSquish`: n = `size`; q = `squish` / (n x 0.5 + 1); r = 1 / (q + 1); scale (r x n, n / r, r x n).
- `downscaleSlightly(pose)`: scale (0.999, 0.999, 0.999) then translate (0, 0.001, 0) (stack order).
- `getShadowRadius` = n x 0.25.
- Entity-side squish tick (`AbstractCubeMob.tick`, read): `oSquish` = `squish`; `squish` += (`targetSquish` - `squish`) x 0.5; run the normal tick; when the entity is on the ground and `wasOnGround` was false (landing): spawn the particles, play the squish sound, `targetSquish` = -0.5; when it is off the ground and `wasOnGround` was true (take-off): `targetSquish` = 1; `wasOnGround` = on ground; `decreaseSquish()` (read): the base implementation, used unchanged by `Slime` and `SulfurCube` (neither overrides it), multiplies `targetSquish` by 0.6; `MagmaCube` overrides it and multiplies `targetSquish` by 0.9. Size data and sizes: 20 and 45.

### 7.5 Slime renderer

- Scale hook: `downscaleSlightly`, then the common `scale` (so the outer layer, drawn under the same pose, is also shrunk by 0.999).
- Texture `textures/entity/slime/slime.png`.
- `SlimeOuterLayer` (model `SLIME_OUTER`, a `SlimeModel`): let outlineOnly = `appearsGlowing` and `isInvisible`. If `isInvisible` and not outlineOnly: draw nothing. Otherwise submit the outer model at order 1 with `entityTranslucent(slime.png)` (or `outline(slime.png)` when outlineOnly), overlay `getOverlayCoords(state, 0)`, no tint, entity light.

### 7.6 Magma cube renderer

- Texture `textures/entity/slime/magmacube.png`; no layers; the common scale hook only (no `downscaleSlightly`).
- `getBlockLightLevel` = 15: the block-light part of the entity's light is always full (34-1 §6.9 `withBlock`).

### 7.7 Sulfur cube renderer

- Before submit: the `model` of the renderer is switched to the small model when `isBaby`, else the normal model (the "baby" of this mob is the small sulfur cube; `isBaby` is the age-based baby flag, since `AbstractCubeMob.tick` calls `AgeableMob.tick`). `SulfurCube.isPrimed()` is `getFuse() >= 0`, which the `fuseRemainingTicks` rule below relies on. Texture: baby `textures/entity/sulfur_cube/sulfur_cube_outer_small.png`, adult `.../sulfur_cube_outer.png`.
- `extractRenderState` additions (`SulfurCubeRenderer`, run after the common cube-mob extraction): `fuseRemainingTicks` = (`getFuse()` - partial + 1) when `isPrimed()` else 0. Then the BODY-slot item (`getBodyArmorItem`) is read: when the stack is empty nothing is written (the method returns; `containedBlock`, `wornHeadType` and `wornHeadProfile` are not cleared by this code). When it is not empty and the item is a `BlockItem` whose block is an `AbstractSkullBlock`: `wornHeadType` = the skull type and `wornHeadProfile` = the item's profile component. For every other non-empty stack (not only block items): the block-state component (default empty) is applied to `Block.byItem(item).defaultBlockState()` and the result is resolved into `containedBlock` with the default `BlockDisplayContext`. For a non-block item `Block.byItem` yields the air default state; whether `BlockModelResolver.update` then leaves `containedBlock` empty was not read (Open question 9). Head-slot fields: `headItem`, `wornHeadType`, `wornHeadProfile` and `wornHeadAnimationPos` are fields of `LivingEntityRenderState`, filled by the generic `LivingEntityRenderer.extractRenderState` from the HEAD slot: a skull block item sets `wornHeadType` and `wornHeadProfile` and clears `headItem`; any other item sets `wornHeadType` and `wornHeadProfile` to null and then, only when `HumanoidArmorLayer.shouldRender(stack, HEAD)` is false, fills `headItem` through `ItemModelResolver.updateForLiving` with display context HEAD (when it is true, `headItem` is cleared, the armor layer draws the item instead). `wornHeadAnimationPos` = the vehicle's walk-animation position when the entity rides a living entity, else its own (the exact source branch was read as two `WalkAnimationState.position` calls; which branch is which was not traced further). Because the sulfur cube's own extraction calls the common extraction first (read: an invoke of the cube-mob super method; that it reaches the generic living extraction is inferred), then writes the BODY values, a skull in the BODY slot overrides the HEAD-slot values of `wornHeadType` and `wornHeadProfile`, and a non-skull BODY item leaves the HEAD-derived values in place.
- `applySizeAndSquish` override: q = (`containedBlock` empty ? `squish` / (n x 0.5 + 1) : 0); r = 1 / (q + 1); scale (r x n, n / r, r x n). A cube holding a block does not squish.
- Scale hook, in stack order (each step acts after the ones listed below it on a vertex, 34-1 §6.5): (1) `downscaleSlightly`; (2) the common scale; (3) when 0 < `fuseRemainingTicks` < 10: uniform scale 1 + swell(f) with swell(f) = 0.3 x clamp(1 - f / 10, 0, 1)^4 (read in `TntRenderer.getSwellAmount`: two squarings then x 0.3); (4) (in code order the scale call comes first and the translate call second, so a model point is translated first and then scaled; re-verified) with y0 = (baby ? 1.24 : 0.98), s = (baby ? 1.0 : 0.5) and h = (invisible ? 0 : 1) / 16: scale (s, s, s) then translate (0, y0 - h, 0) (the x and z translations are -0.0). The model then draws at the usual translate (0, -1.501, 0). Example (adult, visible, size n, no squish, no fuse): the model point y_m = 0 (the cube centre) is at world height n x 0.5 x (1.501 - 0.98 + 0.0625) = 0.29175 n above the entity position, before the 0.999 and 0.001 adjustment.
- Layer order in the renderer constructor (re-read in round RS17 fix): `SulfurCubeInnerLayer` is added first, `CustomHeadLayer` second. The adult/baby choice is made per frame from `isBaby` for the main model and texture (renderer), and independently for the inner model, inner texture, block scale 0.5 and inner overlay (layer); both read the same state flag. The `containedBlock` is submitted with the state's `lightCoords`, whereas the inner model uses the light handed to the layer.
- `SulfurCubeInnerLayer` (model `SULFUR_CUBE_INNER` or `SULFUR_CUBE_SMALL_INNER`): skip when `wornHeadType` is set. Overlay coordinates: when `fuseRemainingTicks` > 0 and `TntRenderer.isLit(fuse)` (fuse >= 0 and trunc(fuse / 5) even), `OverlayTexture.pack(u(1.0), 10)` (the white row at its full-white column, u = 15 by 34-1 §6.9); otherwise `getOverlayCoords(state, 0)`. If `containedBlock` is not empty: push; rotate X by 180 degrees; when baby scale (0.5, 0.5, 0.5); translate (-0.5, -0.518, -0.5); `containedBlock.submit(pose, collector, lightCoords, overlay, outlineColor)`; pop (the block is drawn instead of the inner cube). Else, when not invisible: submit the inner model (small when baby) at order **-1** (before the outer shell) with `entityTranslucent(sulfur_cube_inner[_small].png)`, the overlay above, tint -1 (white, no alpha).
- `CustomHeadLayer` with `CUSTOM_HEAD_TRANSFORMS` = (yOffset 0, skullYOffset 0.625, horizontalScale 0.84210527, verticalScale 0.84210527, cutout player-skin resolver); the layer algorithm is 34-1 §8.4 (`COUNTER_SKULL_SCALE` = 0.84210527 is declared in the renderer; 0.84210527 x 1.1875 = 1.0). The head part used is the model's `getHead()` (child `cube`).
- The outer shell is the main model: translucent render function, tint from `getModelTint` = -1.

---

## 8. Warden (`WardenModel`, `WardenRenderer`, `WardenRenderState`, `WardenAnimation`)

### 8.1 Geometry (128 x 128)

| Part path | pivot | box (origin; size) | tex | notes |
|---|---|---|---|---|
| `bone` | (0, 24, 0) | none | | container |
| `bone/body` | (0, -21, 0) | (-9, -13, -4); 18 x 21 x 11 | (0, 0) | |
| `bone/body/right_ribcage` | (-7, -2, -4) | (-2, -11, -0.1); 9 x 21 x 0 | (90, 11) | zero-depth plane |
| `bone/body/left_ribcage` | (7, -2, -4) | (-7, -11, -0.1); 9 x 21 x 0 | (90, 11) | mirrored |
| `bone/body/head` | (0, -13, 0) | (-8, -16, -5); 16 x 16 x 10 | (0, 32) | |
| `.../head/right_tendril` | (-8, -12, 0) | (-16, -13, 0); 16 x 16 x 0 | (52, 32) | zero depth |
| `.../head/left_tendril` | (8, -12, 0) | (0, -13, 0); 16 x 16 x 0 | (58, 0) | zero depth |
| `bone/body/right_arm` | (-13, -13, 1) | (-4, 0, -4); 8 x 28 x 8 | (44, 50) | |
| `bone/body/left_arm` | (13, -13, 1) | (-4, 0, -4); 8 x 28 x 8 | (0, 58) | |
| `bone/right_leg` | (-5.9, -13, 0) | (-3.1, 0, -3); 6 x 13 x 6 | (76, 48) | |
| `bone/left_leg` | (5.9, -13, 0) | (-2.9, 0, -3); 6 x 13 x 6 | (76, 76) | |

Constants declared: `DEFAULT_ARM_X_Y` = 13.0, `DEFAULT_ARM_Z` = 1.0. The model looks up its parts by these names; its own parts are exposed as `bone`, `body`, `head`, `rightTendril`, `leftTendril`, `leftLeg`, `leftArm`, `leftRibcage`, `rightArm`, `rightLeg`, `rightRibcage`. The default pose has the feet at y = 24 + (-13 + 13) = 24.

### 8.2 `setupAnim` (in this order)

1. `head.xRot` = `xRot` x 0.017453292; `head.yRot` = `yRot` x 0.017453292 (assigned).
2. Walk. Let p = `walkAnimationPos` x 0.8662, m = min(0.5, 3 x `walkAnimationSpeed`), m2 = min(0.35, m).
   - `head.zRot` += 0.3 x sin(p) x m
   - `head.xRot` += 1.2 x cos(p + 1.5707964) x m2
   - `body.zRot` = 0.1 x sin(p) x m (assigned)
   - `body.xRot` = 1.0 x cos(p) x m2 (assigned)
   - `left_leg.xRot` = cos(p) x m (assigned)
   - `right_leg.xRot` = cos(p + 3.1415927) x m (assigned)
   - `left_arm.xRot` = -(0.8 x cos(p) x m); `left_arm.zRot` = 0 (assigned)
   - `right_arm.xRot` = -(0.8 x sin(p) x m); `right_arm.zRot` = 0 (assigned)
   - arm pose reset: both arms `yRot` = 0, `z` = 1; left arm `x` = 13, `y` = -13; right arm `x` = -13, `y` = -13.
3. Idle. Let a = `ageInTicks` x 0.1. `head.zRot` += 0.06 x cos(a); `head.xRot` += 0.06 x sin(a); `body.zRot` += 0.025 x sin(a); `body.xRot` += 0.025 x cos(a).
4. Tendrils. v = `tendrilAnimation` x (cos(`ageInTicks` x 2.25) x 3.141592653589793 x 0.10000000149011612) (the cosine and product are in double precision, then narrowed to float): `left_tendril.xRot` = v; `right_tendril.xRot` = -v (assigned).
5. Keyframe animations, in this order, each applied only when its state has started (34-1 §5.3): attack, sonic boom, dig, emerge, roar, sniff.

### 8.3 Render state and entity inputs

`WardenRenderState` fields: `tendrilAnimation`, `heartAnimation` (0..1), six `AnimationState`s (`roarAnimationState`, `sniffAnimationState`, `emergeAnimationState`, `diggingAnimationState`, `attackAnimationState`, `sonicBoomAnimationState`). `extractRenderState`: `tendrilAnimation` = `Warden.getTendrilAnimation(partial)` = lerp(partial, `tendrilAnimationO`, `tendrilAnimation`) / 10; `heartAnimation` = lerp(partial, `heartAnimationO`, `heartAnimation`) / 10; the six animation states are copied from the entity (`AnimationState.copyFrom` copies the start tick).

Entity side (client ticks and events, `Warden`):
- Client particles: `clientDiggingParticles` is called every client tick while the pose is EMERGING (with the emerge `AnimationState`) or DIGGING (with the dig state); it was read only far enough to see that it takes the animation state, compares `getTimeInMillis` with 4500.0, and spawns `BLOCK` particles (block state under the warden, skipped when its render shape is INVISIBLE) at x and z offsets drawn from [-0.7, 0.7] around the entity. The full spawn rule belongs with the particle document (42) and was not traced (Open question 16).
- Each client tick: when `tickCount` mod `getHeartBeatDelay()` is 0 the heart counter `heartAnimation` is set to 10 and, unless silent, the heartbeat sound is played at the entity (volume 5.0, pitch = voice pitch); `tendrilAnimationO` = `tendrilAnimation` and the counter is decremented when above 0; same for the heart. `getHeartBeatDelay()` = 40 - floor(clamp(`clientAngerLevel` / 80, 0, 1) x 30) (80 = the minimum anger of `AngerLevel.ANGRY`; `AGITATED` is 40).
- Entity events (`handleEntityEvent`): id 4: stop the roar state and start the attack state at `tickCount`; id 61: `tendrilAnimation` = 10; id 62: start the sonic boom state at `tickCount`.
- Pose changes (`onSyncedDataUpdated` of the pose data): EMERGING starts the emerge state, DIGGING starts the dig state, ROARING starts the roar state, SNIFFING starts the sniff state (each at `tickCount`).
- `AnimationState` (`net.minecraft.world.entity`): `startTick` = -2147483648 means stopped; `start(t)` sets it; `startIfStopped(t)` starts only when stopped; `stop()` resets; `isStarted()` is `startTick` not -2147483648; `getTimeInMillis(age)` = trunc((age - startTick) x 50) as a long; `fastForward(n, speed)` subtracts trunc(n x speed) from `startTick` when started; `animateWhen(b, t)` starts-if-stopped when b else stops. This completes 34-1 §5.5.

### 8.4 Renderer

Texture `textures/entity/warden/warden.png`; shadow 0.9; flip 90; no scale hook.

### 8.5 Layers (five `LivingEntityEmissiveLayer`s, in this order; 34-1 §8.5 gives the layer rule)

All five use the render type function `RenderTypes.entityTranslucentEmissive` (14), `alwaysVisible` = false, and a model baked from a layer id whose mesh is the warden mesh passed through `retainExactParts` (1.1):

| # | Model layer | Parts that keep cubes | Texture | Alpha |
|---|---|---|---|---|
| 1 | `WARDEN_BIOLUMINESCENT` | `head`, `left_arm`, `right_arm`, `left_leg`, `right_leg` (no body; tendrils and ribcages empty) | `warden_bioluminescent_layer.png` | 1.0 |
| 2 | `WARDEN_PULSATING_SPOTS` | named: `body`, `head`, `left_arm`, `right_arm`, `left_leg`, `right_leg`; see the note below | `warden_pulsating_spots_1.png` | max(0, cos(`ageInTicks` x 0.045) x 0.25) |
| 3 | `WARDEN_PULSATING_SPOTS` (the same model class instance as 2) | as 2 | `warden_pulsating_spots_2.png` | max(0, cos(`ageInTicks` x 0.045 + 3.1415927) x 0.25) |
| 4 | `WARDEN_TENDRILS` | `left_tendril`, `right_tendril` | `warden.png` (the main texture) | `tendrilAnimation` |
| 5 | `WARDEN_HEART` | `body` | `warden_heart.png` | `heartAnimation` |

Note for rows 2 and 3 (consequence of the rule read in 1.1): `body` is named, so `clearRecursively` empties all of its descendants, which include `head`, `left_arm`, `right_arm` and both ribcages; only `body` and the two legs (children of `bone`) keep cubes. Whether that is the intended look was not verified by rendering (Open question 4).

Layer rule (read in `LivingEntityEmissiveLayer.submit`, checked in this order): (1) skip when the state's `isInvisible` is true and the layer's `alwaysVisible` is false, so none of the five warden layers (all `alwaysVisible` = false) is drawn on an invisible warden; (2) evaluate the alpha function; (3) skip when the alpha is at most 0.00001; the tint is white with that alpha (`ARGB.white(alpha)`), overlay `getOverlayCoords(state, 0)`, entity light, order 1. The layer models run the same `setupAnim` (1.1), so all animations, including keyframes, apply to them.

### 8.6 Keyframe animations (`WardenAnimation`, six definitions; all `looping` false)

Reading the tables: times in seconds; the three numbers are the authored x, y, z; rotation channels are in **degrees** (stored as radians), position channels in pixels with the authored y **negated** when stored (`posVec`: stored = (x, -y, z)), scale channels are not used by the warden. A keyframe marked `L` uses linear interpolation; unmarked keyframes use Catmull-Rom. The interpolation used on a segment is that of the later keyframe (34-1 §5.2). All keyframes are continuous (pre = post). The interpolation marker, the channel kinds (rotation = `degreeVec`, position = `posVec`, scale = `scaleVec`) and the y negation of `posVec` were re-read in `KeyframeAnimations` and in the table extraction: `degreeVec` multiplies each component by 0.017453292, `posVec` negates only y, `scaleVec` takes three doubles and stores each minus 1 (narrowed to float). In the Breeze `JUMP` table the scale values 1.3 and 1.1 are written in the artifact as the doubles 1.2999999523162842 and 1.100000023841858, that is the float values 1.3 and 1.1 widened. Targets add to the part's pose, so a position value of authored y = -63 moves a part 63 pixels **down**.

**WARDEN_EMERGE**: length 6.68 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | rotation | 0: 0, 0, 0; 0.52: 0, 0, -22.5; 1.2: 0, 0, -7.5; 1.68: 0, 0, 10; 1.8: 0, 0, 10; 2.28: 0, 0, 10; 2.88: 0, 0, 10; 3.76: 25, 0, -7.5; 3.92: 35, 0, -7.5; 4.08: 25, 0, -7.5; 4.44: 47.5, 0, 0; 4.56: 47.5, 0, 0; 4.68: 47.5, 0, 0; 5: 70, 0, 2.5; 5.8: 70, 0, 2.5; 6.64: 0, 0, 0 |
| `body` | position | 0: 0, -63, 0; 0.52: 0, -56, 0; 1.2: 0, -32, 0; 1.68: 0, -32, 0; 1.8: 0, -32, 0; 2.28: 0, -32, 0; 2.88: 0, -32, 0; 3.16: 0, -27, 0; 3.76: 0, -14, 0; 3.92: 0, -11, 0; 4.08: 0, -14, 0; 4.44: 0, -6, -3; 4.56: 0, -4, -3; 4.68: 0, -6, -3; 5: 0, -3, -4; 5.8: 0, -3, -4; 6.64: 0, 0, 0 |
| `head` | rotation | 0: 0, 0, 0; 0.52: 0, 0, 0; 0.92: 0.74, 0, -40.38; 1.16: -67.5, 0, -2.5; 1.24: -67.5, 0, -2.5; 1.32: -47.5, 0, -2.5; 1.4: -67.5, 0, -2.5; 1.68: -67.5, 0, 15; 1.76: -67.5, 0, -5; 1.84: -52.5, 0, -5; 1.92: -67.5, 0, -5; 2.64: -17.5, 0, -10; 3.76: 70, 0, 12.5; 4.04: 70, 0, 12.5; 4.12: 80, 0, 12.5; 4.24: 70, 0, 12.5; 5: 77.5, 0, -2.5; 6.64: 0, 0, 0 |
| `head` | position | 0: 0, 0, 0; 0.52: -8, -11, 0; 0.92: 0, 0, 0; 1.24: 0, 0.47, -0.95; 1.32: 0, 0.47, -0.95; 1.4: 0, 0.47, -0.95; 1.68: 0, 1, -2; 1.76: 0, 1, -2; 1.84: 0, 1, -2; 1.92: 0, 1, -2; 2.64: 0, -2, -2; 3.76: 0, -4, 1; 4.04: 0, -1, 1; 4.12: 0, -1, 1; 4.24: 0, -1, 1; 5: 0, -1, 1; 6.64: 0, 0, 0 |
| `right_arm` | rotation | 0: 0, 0, 0; 0.52: 0, 0, 0; 1.2: -152.5, 2.5, 7.5; 1.68: -180, 12.5, -10; 1.8: -90, 12.5, -10; 2.28: -90, 12.5, -10; 2.88: -90, 12.5, -10; 3.08: -95, 12.5, -10; 3.24: -83.93, 3.93, 5.71; 3.36: -80, 7.5, 17.5; 3.76: -67.5, 2.5, 0; 4.08: -67.5, 2.5, 0; 4.44: -55, 2.5, 0; 4.56: -60, 2.5, 0; 4.68: -55, 2.5, 0; 5: -67.5, 0, 0; 5.56: -50.45, 0, 2.69; 6.08: -62.72, 0, 4.3; 6.64: 0, 0, 0 |
| `right_arm` | position | 0: 0, 0, 0; 0.52: 0, 0, 0; 1.2: 0, -21, 9; 1.68: 2, -2, 0; 1.8: 2, 0, 0; 2.28: 2, 0, 0; 2.88: 2, 0, 0; 3.08: 2, -2, 0; 3.24: 2, 2.71, 3.86; 3.36: 2, 1, 5; 3.76: 2, 3, 3; 4.08: 2, 3, 3; 4.44: 2.67, 4, 0; 4.56: 2.67, 0, 0; 4.68: 2.67, 4, 0; 5: 0.67, 3, 4; 6.64: 0, 0, 0 |
| `left_arm` | rotation | 0: 0, 0, 0; 0.12: -167.5, -17.5, -7.5; 0.6: -167.5, -17.5, -7.5; 0.88: -175, -17.5, 15; 1.16: -190, -17.5, 5; 1.28: -90, -5, 5; 1.68: -90, -17.5, -12.5; 1.8: -90, -17.5, -12.5; 2.28: -90, -17.5, -12.5; 2.88: -90, -17.5, -12.5; 3.04: -81.29, -10.64, -14.21; 3.16: -83.5, -5.5, -15.5; 3.76: -62.5, -7.5, 5; 3.92: -58.75, -3.75, 5; 4.08: -55, 0, 0; 4.44: -52.5, 0, 5; 4.56: -50, 0, 5; 4.68: -52.5, 0, 5; 5: -72.5, -2.5, 5; 5.56: -57.5, -4.54, 2.99; 6.08: -70.99, -5.77, 1.78; 6.64: 0, 0, 0 |
| `left_arm` | position | 0: 0, 0, 0; 0.12: 0, -8, 0; 0.6: 0, -8, 0; 0.88: 0, 0, 0; 1.2: -2, 0, 0; 1.68: -4, 3, 0; 1.8: -4, 3, 0; 2.28: -4, 3, 0; 2.88: -4, 3, 0; 3.04: -3.23, 5.7, 4.97; 3.16: -1.49, 2.22, 5.25; 3.76: -1.14, 1.71, 1.86; 3.92: -1.14, 1.21, 3.86; 4.08: -1.14, 2.71, 4.86; 4.44: -1, 1, 3; 4.56: 0, 1, 1; 4.68: 0, 1, 3; 5: -2, 0, 4; 6.64: 0, 0, 0 |
| `right_leg` | rotation | 0: 0, 0, 0; 0.52: 0, 0, 0; 2.28: 0, 0, 0; 2.88: 0, 0, 0; 3.36: 0, 0, 0; 4.32: 0, 0, 0; 4.48: 55, 0, 0; 4.6: 0, 0, 0; 5: 0, 0, 0; 5.8: 0, 0, 0; 6.64: 0, 0, 0 |
| `right_leg` | position | 0: 0, -63, 0; 0.52: 0, -56, 0; 1.2: 0, -32, 0; 1.68: 0, -32, 0; 1.8: 0, -32, 0; 2.28: 0, -32, 0; 2.88: 0, -32, 0; 3.36: 0, -22, 0; 3.76: 0, -12.28, 2.48; 3.92: 0, -9.28, 2.48; 4.08: 0, -12.28, 2.48; 4.32: 0, -4.14, 4.14; 4.48: 0, -0.57, -8.43; 4.6: 0, 0, 0; 5: 0, 0, 0; 5.8: 0, 0, 0; 6.64: 0, 0, 0 |
| `left_leg` | rotation | 0: 0, 0, 0; 0.52: 0, 0, 0; 2.28: 0, 0, 0; 2.88: 0, 0, 0; 3.36: 0, 0, 0; 3.84: 20, 0, -17.5; 4: 0, 0, 0; 4.68: 20, 0, 0; 4.84: 10, 0, 0; 5: 0, 0, 0; 5.8: 0, 0, 0; 6.64: 0, 0, 0 |
| `left_leg` | position | 0: 0, -63, 0; 0.52: 0, -56, 0; 1.2: 0, -32, 0; 1.68: 0, -32, 0; 1.8: 0, -32, 0; 2.28: 0, -32, 0; 2.88: 0, -32, 0; 3.36: 0, -22, 0; 3.84: -4, 2, -7; 4: -4, 0, -5; 4.68: -4, 0, -9; 4.84: -2, 2, -3.5; 5: 0, 0, 0; 5.8: 0, 0, 0; 6.64: 0, 0, 0 |

**WARDEN_DIG**: length 5.0 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | rotation | 0: 0, 0, 0; 0.25: 4.13441, 0.94736, 1.2694; 0.5: 50, 0, 0; 0.7083: 54.45407, -13.53935, -18.14183; 1.0417: 59.46442, -10.8885, 35.7954; 1.3333: 82.28261, 0, 0; 1.625: 53.23606, 10.04715, -29.72932; 2.2083: -17.71739, 0, 0; 2.5417: 112.28261, 0, 0; 2.6667: 116.06889, 5.11581, -24.50117; 2.8333: 121.56244, -4.17248, 19.57737; 3.0417: 138.5689, 5.11581, -24.50117; 3.25: 144.06244, -4.17248, 19.57737; 3.375: 147.28261, 0, 0; 3.625: 147.28261, 0, 0; 3.875: 134.36221, 8.81113, -8.90172; 4.0417: 132.05966, -8.35927, 9.70506; 4.25: 134.36221, 8.81113, -8.90172; 4.5: 147.5, 0, 0 L |
| `body` | position | 0: 0, 0, 0; 0.5: 0, -16.48454, -6.5784; 0.7083: 0, -16.48454, -6.5784; 1.0417: 0, -16.97, -7.11; 1.625: 0, -13.97, -7.11; 2.2083: 0, -11.48454, -0.5784; 2.5417: 0, -16.48454, -6.5784; 2.6667: 0, -20.27, -5.42; 3.375: 0, -21.48454, -5.5784; 4.0417: 0, -22.48454, -5.5784; 4.5: 0, -40, -8 L |
| `head` | rotation | 0: 0, 0, 0; 0.6667: 12.5, 0, 0; 1.2083: 12.5, 0, 0; 1.75: 45, 0, 0; 2.375: -22.5, 0, 0; 2.5417: 67.5, 0, 0; 4.375: 67.5, 0, 0 |
| `head` | position | 0: 0, 0, 0; 4.375: 0, 0, 0 L |
| `right_arm` | rotation | 0: 0, 0, 0; 0.5: -101.8036, -21.29587, 30.61478; 0.7083: -101.8036, -21.29587, 30.61478; 1: 48.7585, -17.61941, 9.9865; 1.1667: 48.7585, -17.61941, 9.9865; 1.4583: -101.8036, -21.29587, 30.61478; 1.75: -89.04994, -4.19657, -1.47845; 2.2083: -158.30728, 3.7152, -1.52352; 2.5417: -89.04994, -4.19657, -1.47845; 4.375: -120, 0, 0 |
| `right_arm` | position | 0: 0, 0, 0; 0.7083: 2.22, 0, 0.86; 1: 3.12, 0, 4.29; 2.2083: 1, 0, 4; 4.375: 0, 0, 4 |
| `left_arm` | rotation | 0: 0, 0, 0; 0.2917: -63.89288, -0.52011, 2.09491; 0.5: -63.89288, -0.52011, 2.09491; 0.7083: -62.87857, 15.15061, 9.97445; 0.9167: -86.93642, 17.45026, 4.05284; 1.1667: -86.93642, 17.45026, 4.05284; 1.4583: -86.93642, 17.45026, 4.05284; 1.6667: 63.0984, 8.83573, -8.71284; 1.8333: 35.5984, 8.83573, -8.71284; 2.2083: -153.27473, -0.02953, 3.5235; 2.5417: -87.07754, -0.02625, 3.132; 4.375: -120, 0, 0 L |
| `left_arm` | position | 0: 0, 0, 0; 0.5: -0.28, 5, 10; 0.7083: -1.51, 4.35, 4.33; 0.9167: -0.6, 3.61, 4.63; 1.1667: -0.6, 3.61, 0.63; 1.6667: -2.85, -0.1, 3.33; 2.2083: -1, 0, 4; 4.375: 0, 0, 4 L |
| `right_leg` | rotation | 0: 0, 0, 0; 0.5: 113.27, 0, 0; 0.7083: 113.27, 0, 0; 3.3333: 113.27, 0, 0; 3.5833: 182.5, 0, 0; 3.8333: 120, 0, 0; 4.0833: 182.5, 0, 0; 4.2917: 120, 0, 0; 4.5: 90, 0, 0 L |
| `right_leg` | position | 0: 0, 0, 0; 0.5: 0, -13.98, -2.37; 0.7083: 0, -13.98, -2.37; 3.3333: 0, -13.98, -2.37; 3.5833: 0, -7, -3; 3.8333: 0, -9, -3; 4.0833: 0, -16.71, -3.69; 4.2917: 0, -28, -5 L |
| `left_leg` | rotation | 0: 0, 0, 0; 0.5: 114.98, 0, 0; 0.7083: 114.98, 0, 0; 3.3333: 114.98, 0, 0; 3.5833: 90, 0, 0; 3.8333: 172.5, 0, 0; 4.0833: 90, 0, 0; 4.2917: 197.5, 0, 0; 4.5: 90, 0, 0 L |
| `left_leg` | position | 0: 0, 0, 0; 0.5: 0, -14.01, -2.35; 0.7083: 0, -14.01, -2.35; 3.3333: 0, -14.01, -2.35; 3.5833: 0, -5, -4; 3.8333: 0, -7, -4; 4.0833: 0, -15.5, -3.76; 4.2917: 0, -28, -5 L |

**WARDEN_ROAR**: length 4.2 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | rotation | 0: 0, 0, 0; 1.24: -25, 0, 0; 1.6: 32.5, 0, -7.5; 1.84: 38.33, 0, 2.99; 2.08: 40.97, 0, -4.3; 2.36: 44.41, 0, 6.29; 3: 47.5, 0, 0; 4.2: 0, 0, 0 |
| `body` | position | 0: 0, 0, 0; 1.24: 0, -1, 3; 1.6: 0, -3, -6; 3: 0, -3, -6; 4.2: 0, 0, 0 |
| `head` | rotation | 0: 0, 0, 0; 1.24: -32.5, 0, 0; 1.6: -32.5, 0, -27.5; 1.8: -32.5, 0, 26; 2.04: -32.5, 0, -27.5; 2.44: -32.5, 0, 26; 2.84: -5, 0, -12.5; 4.2: 0, 0, 0 |
| `head` | position | 0: 0, 0, 0; 1.24: 0, 0, 0; 1.6: 0, -2, -6; 2.2: 0, -2, -6; 2.48: 0, -2, -6; 4.2: 0, 0, 0 |
| `right_arm` | rotation | 0: 0, 0, 0; 0.72: -120, 0, -20; 1.24: -77.5, 3.75, 15; 1.48: 67.5, -32.5, 20; 2.48: 37.5, -32.5, 25; 2.88: 27.6, -17.1, 32.5; 4.2: 0, 0, 0 |
| `right_arm` | position | 0: 0, 0, 0; 0.72: 3, -2, 0; 1.48: 4, -2, 0; 2.48: 4, -2, 0; 4.2: 0, 0, 0 |
| `left_arm` | rotation | 0: 0, 0, 0; 0.72: -125, 0, 20; 1.24: -76.25, -17.5, -7.5; 1.48: 62.5, 42.5, -12.5; 2.48: 37.5, 27.5, -27.5; 2.88: 25, 18.4, -30; 4.2: 0, 0, 0 |
| `left_arm` | position | 0: 0, 0, 0; 0.72: -3, -2, 0; 1.48: -4, -2, 0; 2.48: -4, -2, 0; 4.2: 0, 0, 0 |

**WARDEN_SNIFF**: length 4.16 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | rotation | 0: 0, 0, 0; 0.56: 17.5, 32.5, 0; 0.96: 0, 32.5, 0; 2.2: 10, 0, 0; 2.8: 10, -30, 0; 3.32: 0, 0, 0 |
| `head` | rotation | 0: 0, 0, 0; 0.68: 0, 40, 0; 0.96: -22.5, 40, 0; 1.24: 0, 20, 0; 1.52: -35, 20, 0; 1.76: 0, 20, 0; 2.28: 0, -20, 0; 2.88: 0, -20, 0; 3.32: 0, 0, 0 |
| `right_arm` | rotation | 0: 0, 0, 0; 0.96: 17.5, 0, 0; 2.2: 0, 0, 0; 2.76: -15, 0, 0; 3.32: 0, 0, 0 |
| `left_arm` | rotation | 0: 0, 0, 0; 0.96: -15, 0, 0; 2.2: 0, 0, 0; 2.76: 17.5, 0, 0; 3.32: 0, 0, 0 |

**WARDEN_ATTACK**: length 0.33333 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | rotation | 0: 0, 0, 0; 0.0417: -22.5, 0, 0; 0.2083: 22.5, 0, 0; 0.3333: 0, 0, 0 |
| `body` | position | 0: 0, 0, 0; 0.0417: 0, 0, 0; 0.2083: 0, -1, -2; 0.3333: 0, 0, 0 |
| `head` | rotation | 0: 0, 0, 0; 0.0417: 22.5, 0, 0; 0.25: -30.17493, 0, 0; 0.3333: 0, 0, 0 |
| `head` | position | 0: 0, 0, 0; 0.0417: 0, 0, 0; 0.25: 0, -2, -2; 0.3333: 0, 0, 0 |
| `right_arm` | rotation | 0: 0, 0, 0; 0.0417: -120.36119, 40.78947, -20.94102; 0.1667: -90, -45, 0; 0.3333: 0, 0, 0 |
| `right_arm` | position | 0: 0, 0, 0; 0.0417: 4, 0, 5; 0.1667: 0, 0, 0; 0.3333: 0, 0, 0 |
| `left_arm` | rotation | 0: 0, 0, 0; 0.0417: -120.36119, -40.78947, 20.94102; 0.1667: -61.1632, 42.85882, 11.52421; 0.3333: 0, 0, 0 |
| `left_arm` | position | 0: 0, 0, 0; 0.0417: -4, 0, 5; 0.1667: 0, 0, 0; 0.3333: 0, 0, 0 |

**WARDEN_SONIC_BOOM**: length 3.0 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | rotation | 0: 0, 0, 0; 1.0833: 47.5, 0, 0; 1.625: 55, 0, 0; 1.9167: 0, 0, 0; 2: -32.5, 0, 0; 2.4583: -32.5, 0, 0; 2.7083: 0, 0, 0; 2.875: 0, 0, 0 |
| `body` | position | 0: 0, 0, 0; 1.0833: 0, -3, 0; 1.625: 0, -4, -1; 1.9167: 0, 0, 0; 2.7083: 0, 0, 0; 2.875: 0, 0, 0 |
| `right_ribcage` | rotation | 0: 0, 0, 0; 1.5417: 0, 0, 0; 1.7917: 0, 0, 0; 1.875: 0, 125, 0; 2.5: 0, 125, 0; 2.6667: 0, 0, 0 |
| `left_ribcage` | rotation | 0: 0, 0, 0; 1.5417: 0, 0, 0; 1.7917: 0, 0, 0; 1.875: 0, -125, 0; 2.5: 0, -125, 0; 2.6667: 0, 0, 0 |
| `head` | rotation | 0: 0, 0, 0; 1: 67.5, 0, 0; 1.75: 80, 0, 0; 1.9167: -45, 0, 0; 2.5: -45, 0, 0; 2.7083: -45, 0, 0; 2.875: 0, 0, 0 |
| `head` | position | 0: 0, 0, 0; 1.9167: 0, 0, -3; 2.5: 0, 0, -3; 2.7083: 0, 0, -3; 2.875: 0, 0, 0 |
| `right_arm` | rotation | 0: 0, 0, 0; 0.875: -42.28659, -32.69813, -5.00825; 1.1667: -29.83757, -35.39626, -45.28089; 1.3333: -29.83757, -35.39626, -45.28089; 1.6667: -72.28659, -32.69813, -5.00825; 1.8333: 35.26439, -30, 35.26439; 1.9167: 73.75484, -13.0931, 19.20518; 2.5: 73.75484, -13.0931, 19.20518; 2.75: 58.20713, -21.1064, 28.7261; 3: 0, 0, 0 |
| `right_arm` | position | 0: 0, 0, 0; 1.8333: 3, 0, 0; 2.75: 3, 0, 0; 3: 0, 0, 0 |
| `left_arm` | rotation | 0: 0, 0, 0; 0.875: -33.80694, 32.31058, 6.87997; 1.1667: -17.87827, 34.62115, 49.02433; 1.3333: -17.87827, 34.62115, 49.02433; 1.6667: -51.30694, 32.31058, 6.87997; 1.8333: 35.26439, 30, -35.26439; 1.9167: 73.75484, 13.0931, -19.20518; 2.5: 73.75484, 13.0931, -19.20518; 2.75: 58.20713, 21.1064, -28.7261; 3: 0, 0, 0 |
| `left_arm` | position | 0: 0, 0, 0; 1.8333: -3, 0, 0; 2.75: -3, 0, 0; 3: 0, 0, 0 |

### 8.7 Bone name resolution

The bone names used by the tables are `body`, `head`, `right_arm`, `left_arm`, `right_leg`, `left_leg`; they are resolved against the model's flat name map (34-1 §5.3), which is why a part reached through `bone/body/...` is addressed by its leaf name.

---

## 9. Breeze (`BreezeModel`, `BreezeRenderer`, `BreezeEyesLayer`, `BreezeWindLayer`, `BreezeAnimation`)

### 9.1 Geometry. One base mesh `createBaseMesh()` is built three times with different part filters (`retainPartsAndChildren`, 1.1) and different texture sizes.

Base mesh (parts and boxes; tex is the texture offset, boxes' grow is `CubeDeformation(0)`):

| Part path | pivot | rot (x, y, z) | boxes (origin; size; tex) |
|---|---|---|---|
| `body` | (0, 0, 0) | 0 | none |
| `body/rods` | (0, 8, 0) | 0 | none |
| `body/rods/rod_1` | (2.5981, -3, 1.5) | (-2.7489, -1.0472, 3.1416) | (-1, 0, -3); 2 x 8 x 2; tex (0, 17) |
| `body/rods/rod_2` | (-2.5981, -3, 1.5) | (-2.7489, 1.0472, 3.1416) | same box |
| `body/rods/rod_3` | (0, -3, -3) | (0.3927, 0, 0) | same box |
| `body/head` | (0, 4, 0) | 0 | (-5, -5, -4.2); 10 x 3 x 4; tex (4, 24) and (-4, -8, -4); 8 x 8 x 8; tex (0, 0) |
| `body/head/eyes` | (0, 0, 0) | 0 | the same two boxes as the head |
| `wind_body` | (0, 0, 0) | 0 | none |
| `wind_body/wind_bottom` | (0, 24, 0) | 0 | (-2.5, -7, -2.5); 5 x 7 x 5; tex (1, 83) |
| `.../wind_bottom/wind_mid` | (0, -7, 0) | 0 | (-6, -6, -6); 12 x 6 x 12; tex (74, 28); (-4, -6, -4); 8 x 6 x 8; tex (78, 32); (-2.5, -6, -2.5); 5 x 6 x 5; tex (49, 71) |
| `.../wind_mid/wind_top` | (0, -6, 0) | 0 | (-9, -8, -9); 18 x 8 x 18; tex (0, 0); (-6, -8, -6); 12 x 8 x 12; tex (6, 6); (-2.5, -8, -2.5); 5 x 8 x 5; tex (105, 57) |

Layers:

| Layer id | Filter | Texture size | Meaning |
|---|---|---|---|
| `BREEZE` | `retainPartsAndChildren({head, rods})` | 32 x 32 | `head` (with its child `eyes`) and `rods` untouched; `body` and the wind parts emptied. The `eyes` boxes are the same as the head boxes (same texture rectangles), so they are drawn twice in the body pass with identical pixels. |
| `BREEZE_WIND` | `retainPartsAndChildren({wind_body})` | 128 x 128 | wind parts only (poses of the emptied body, rods and head kept) |
| `BREEZE_EYES` | `retainPartsAndChildren({eyes})` | 32 x 32 | the `eyes` boxes only |

The model class resolves `wind_body` > `wind_bottom` > `wind_mid` > `wind_top`, `body` > `head` > `eyes`, `body` > `rods`. Declared constants `WIND_TOP_SPEED` 0.6, `WIND_MIDDLE_SPEED` 0.8, `WIND_BOTTOM_SPEED` 1.0 are not used by any method that was read. The base render function of the model is `entityTranslucent`.

### 9.2 `setupAnim`

No procedural formula. After the pose reset, the six keyframe animations are applied, each only when its state has started, in this order: idle (`idle`), shoot (`shoot`), slide (`slide`), slide back (`slideBack`), inhale (`inhale`), jump (`longJump` state with `JUMP`). Each uses `ageInTicks`.

### 9.3 Render state and entity inputs

`BreezeRenderState`: six `AnimationState`s: `idle`, `shoot`, `slide`, `slideBack`, `inhale`, `longJump`, copied from the entity in `extractRenderState`. Entity side (`Breeze`, client):
- Client effects in the same `tick` (particles and sound, not animation; the particle definitions belong to 42): in the pose switch over the pose ordinal map, case 3 calls `emitGroundParticles(20)`; cases 1, 2 and 4 call `resetJumpTrail()` then `emitGroundParticles(1 + nextInt(1))` (the argument is 1); the long-jump case also calls `emitJumpTrailParticles()`; a `soundTick` counter, when it reaches zero, is reseeded with `nextIntBetweenInclusive(1, 80)` and `playWhirlSound()` is called (the branch around the counter was read only partly: Open question 16). Which Pose each switch ordinal maps to was not read beyond case 5 = LONG_JUMPING.
- Pose data change (client only): all of `shoot`, `idle`, `inhale`, `longJump` are stopped (`slide` is not), then SHOOTING starts `shoot`, INHALING starts `inhale`, SLIDING starts `slide` (each `startIfStopped(tickCount)`).
- Every tick: LONG_JUMPING (the fifth case of the pose switch) calls `longJump.startIfStopped(tickCount)`; `idle.startIfStopped(tickCount)` always; when the pose is not SLIDING and `slide` is started: `slideBack.start(tickCount)` and `slide.stop()`.

### 9.4 Renderer and layers

Texture `textures/entity/breeze/breeze.png`; shadow 0.5; flip 90.
- `BreezeWindLayer`: submit the wind model (`BREEZE_WIND`, a `BreezeModel`) at order 1 with `RenderTypes.breezeWind(textures/entity/breeze/breeze_wind.png, u, 0)` where u = (`ageInTicks` x 0.02) mod 1 and the second offset is 0; the texture scrolls in u. No overlay, entity light, tint none.
- `BreezeEyesLayer`: submit the eyes model (`BREEZE_EYES`) at order 1 with `RenderTypes.breezeEyes(textures/entity/breeze/breeze_eyes.png)`; no overlay.
- The base model is drawn first; layers in the order wind then eyes.

### 9.5 Keyframe animations (`BreezeAnimation`)

Same reading rules as 8.6. Additionally, scale channels hold the authored multiplier m; the stored value is m - 1 (`scaleVec`), added to the part's scale 1. `IDLE` loops (time taken modulo its length, 34-1 §5.3).

**IDLE**: length 2.0 s, looping true.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `wind_top` | position | 0: 0.5, 0, 0 L; 0.25: 0.5, 0, -0.5 L; 0.75: -0.5, 0, -0.5 L; 1.25: -0.5, 0, 0.5 L; 1.75: 0.5, 0, 0.5 L; 2: 0.5, 0, 0 L |
| `wind_mid` | position | 0: 0.5, 0, -0.5 L; 0.5: -0.5, 0, -0.5 L; 1: -0.5, 0, 0.5 L; 1.5: 0.5, 0, 0.5 L; 2: 0.5, 0, -0.5 L |
| `head` | position | 0: 0, 0, 0; 1: 0, 1, 0; 2: 0, 0, 0 |
| `rods` | rotation | 0: 0, 0, 0 L; 2: 0, 1080, 0 L |
| `rods` | position | 0: 0, 0, 0 L; 1: 0, -1, 0 L; 2: 0, 0, 0 L |

**SHOOT**: length 1.125 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `head` | rotation | 0: 0, 0, 0 L; 0.25: -12.5, 0, 0 L; 0.75: -12.5, 0, 0 L; 0.9167: 5, 0, 0 L; 1.125: 0, 0, 0 L |
| `head` | position | 0: 0, 0, 0 L; 0.25: 0, -2, 0 L; 0.7917: 0, -1, 2 L; 0.9583: 0, -1, 0 L; 1.125: 0, 0, 0 L |
| `wind_bottom` | rotation | 0: 0, 0, 0 L |
| `wind_mid` | rotation | 0: 0, 0, 0 L; 0.25: 12.5, 0, 0 L; 0.75: 12.5, 0, 0 L; 0.9167: -10, 0, 0 L; 1.125: 0, 0, 0 L |
| `wind_mid` | position | 0: 0, 0, 0 L; 0.25: 0, 0, 5 L; 0.75: 0, 0, 6 L; 0.9167: 0, 0, -2 L; 1.125: 0, 0, 0 L |
| `wind_top` | rotation | 0: 0, 0, 0 L; 0.25: 15, 0, 0 L; 0.75: 15, 0, 0 L; 0.9167: -10, 0, 0 L; 1.125: 0, 0, 0 L |
| `wind_top` | position | 0: 0, 0, 0 L; 0.25: 0, 0, 3 L; 0.8333: 0, 0, 4 L; 0.9583: 0, 0, -2 L; 1.125: 0, 0, 0 L |
| `body` | rotation | 0: 0, 0, 0 L; 0.25: 12.5, 0, 0 L; 0.75: 12.5, 0, 0 L; 0.9167: -2.5, 0, 0 L; 1.125: 0, 0, 0 L |
| `body` | position | 0: 0, 0, 0 L; 0.25: 0, 3, 5 L; 0.8333: 0, 3, 6 L; 0.9583: 0, 3, -1 L; 1.125: 0, 0, 0 L |
| `rods` | rotation | 0: 0, 0, 0 L; 1: 0, 360, 0 L |

**JUMP**: length 0.5 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | position | 0: 0, -10, 0 L; 0.125: 0, 11, 0 L; 0.5: 0, 0, 0 L |
| `head` | rotation | 0: 22.5, 0, 0 L; 0.2083: -19.25, 0, 0 L; 0.5: 0, 0, 0 L |
| `wind_body` | scale | 0: 1, 1, 1 L; 0.125: 1, 1.3, 1 L; 0.5: 1, 1, 1 L |
| `wind_bottom` | rotation | 0: 0, 90, 0 L; 0.5: 0, 360, 0 L |
| `wind_bottom` | scale | 0: 1, 1, 1 L; 0.125: 1, 1.1, 1 L; 0.5: 1, 1, 1 L |
| `wind_mid` | rotation | 0: 0, 0, 0 L; 0.5: 0, 180, 0 L |
| `wind_mid` | position | 0: 0, -6, 0 L; 0.125: 0, 2, 0 L; 0.5: 0, 0, 0 L |
| `wind_top` | rotation | 0: 0, 0, 0 L; 0.5: 0, 90, 0 L |
| `wind_top` | position | 0: 0, -5, 0 L; 0.125: 0, 2, 0 L; 0.5: 0, 0, 0 L |
| `rods` | rotation | 0: 0, 0, 0 L; 0.5: 0, 360, 0 L |

**INHALE**: length 2.0 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | position | 0: 0, 0, 0 L; 0.5: 0, -10, 0 L; 0.625: 0, -10, 0 L |
| `head` | rotation | 0: 0, 0, 0 L; 0.5: 22.5, 0, 0 L; 0.625: 22.5, 0, 0 L |
| `wind_body` | scale | 0: 1, 1, 1 L; 0.5: 1, 1, 1 L; 0.625: 1, 1, 1 L |
| `wind_bottom` | rotation | 0: 0, 0, 0 L; 0.625: 0, 90, 0 L |
| `wind_bottom` | scale | 0: 1, 1, 1 L; 0.5: 1, 1, 1 L; 0.625: 1, 1, 1 L |
| `wind_mid` | rotation | 0: 0, 0, 0 L; 0.625: 0, 0, 0 L |
| `wind_mid` | position | 0: 0, 0, 0 L; 0.5: 0, -6, 0 L; 0.625: 0, -6, 0 L |
| `wind_top` | rotation | 0: 0, 0, 0 L; 0.625: 0, 0, 0 L |
| `wind_top` | position | 0: 0, 0, 0 L; 0.5: 0, -5, 0 L; 0.625: 0, -5, 0 L |
| `rods` | rotation | 0: 0, 0, 0 L; 0.625: 0, 360, 0 L |

**SLIDE**: length 0.2 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | position | 0: 0, 0, 0 L; 0.2: 0, 0, -6 L |
| `wind_mid` | position | 0: 0, 0, 0 L; 0.2: 0, 0, -3 L |
| `wind_top` | position | 0: 0, 0, 0 L; 0.2: 0, 0, -2 L |

**SLIDE_BACK**: length 0.1 s, looping false.

| Bone | Channel | Keyframes (time s: x, y, z) |
|---|---|---|
| `body` | position | 0: 0, 0, -6 L; 0.1: 0, 0, 0 L |
| `wind_mid` | position | 0: 0, 0, -3 L; 0.1: 0, 0, 0 L |
| `wind_top` | position | 0: 0, 0, -2 L; 0.1: 0, 0, 0 L |

---

## 10. Phantom (`PhantomModel`, `PhantomRenderer`, `PhantomEyesLayer`)

### 10.1 Geometry (64 x 64)

| Part path | pivot | rot (x, y, z) | box (origin; size) | tex |
|---|---|---|---|---|
| `body` | (0, 0, 0) | (-0.1, 0, 0) | (-3, -2, -8); 5 x 3 x 9 | (0, 8) |
| `body/tail_base` | (0, -2, 1) | 0 | (-2, 0, 0); 3 x 2 x 6 | (3, 20) |
| `body/tail_base/tail_tip` | (0, 0.5, 6) | 0 | (-1, 0, 0); 1 x 1 x 6 | (4, 29) |
| `body/left_wing_base` | (2, -2, -8) | (0, 0, 0.1) | (0, 0, 0); 6 x 2 x 9 | (23, 12) |
| `body/left_wing_base/left_wing_tip` | (6, 0, 0) | (0, 0, 0.1) | (0, 0, 0); 13 x 1 x 9 | (16, 24) |
| `body/right_wing_base` | (-3, -2, -8) | (0, 0, -0.1) | (-6, 0, 0); 6 x 2 x 9, mirrored | (23, 12) |
| `body/right_wing_base/right_wing_tip` | (-6, 0, 0) | (0, 0, -0.1) | (-13, 0, 0); 13 x 1 x 9, mirrored | (16, 24) |
| `body/head` | (0, 1, -7) | (0.2, 0, 0) | (-4, -2, -5); 7 x 3 x 5 | (0, 0) |

### 10.2 `setupAnim`

Let t = `flapTime` x 7.448451 x 0.017453292 (radians).
- `left_wing_base.zRot` = `left_wing_tip.zRot` = cos(t) x 16 x 0.017453292 (assigned, replacing the pose angle of +0.1).
- `right_wing_base.zRot` = -`left_wing_base.zRot`, `right_wing_tip.zRot` = -`left_wing_tip.zRot`.
- `tail_base.xRot` = `tail_tip.xRot` = -(5 + cos(2 t) x 5) x 0.017453292.

### 10.3 Renderer

- Texture `textures/entity/phantom/phantom.png`; shadow 0.75; flip 90.
- `extractRenderState`: `flapTime` = (`getUniqueFlapTickOffset()` + `ageInTicks`) as float, where `getUniqueFlapTickOffset()` = entity network id x 3; `size` = `getPhantomSize()` (an entity data int; attack damage = 6 + size on the server).
- `scale(state, pose)`: s = 1 + 0.15 x `size`: scale (s, s, s) then translate (0, 1.3125, 0.1875).
- `setupRotations(state, pose, bodyRot, scale)`: the base rotations (34-1 §6.5), then rotate X by `state.xRot` degrees (the pose pitches with the head pitch).
- `PhantomEyesLayer`: `EyesLayer` with `RenderTypes.eyes(textures/entity/phantom/phantom_eyes.png)` over the parent's posed model.

World height of the body pivot (size 0, scale 1): model point y_m = 0 sits at 1.3125 - 1.501 = -0.1885 in the flipped frame, i.e. 0.1885 blocks above the entity position (see 15.5).

---

## 11. Guardian and elder guardian (`GuardianModel`, `GuardianRenderer`, `ElderGuardianRenderer`, `GuardianParticleModel`)

### 11.1 Geometry (64 x 64)

| Part path | pivot | rot | boxes (origin; size; tex) |
|---|---|---|---|
| `head` | (0, 0, 0) | 0 | (-6, 10, -8); 12 x 12 x 16; tex (0, 0). (-8, 10, -6); 2 x 12 x 12; tex (0, 28). (6, 10, -6); 2 x 12 x 12; tex (0, 28), mirrored. (-6, 8, -6); 12 x 2 x 12; tex (16, 40). (-6, 22, -6); 12 x 2 x 12; tex (16, 40) |
| `head/spike0` ... `head/spike11` | see 11.2 | see 11.2 | (-1, -4.5, -1); 2 x 9 x 2; tex (0, 0) (one shared box) |
| `head/eye` | (0, 0, -8.25) | 0 | (-1, 15, 0); 2 x 2 x 1; tex (8, 0) |
| `head/tail0` | (0, 0, 0) | 0 | (-2, 14, 7); 4 x 4 x 8; tex (40, 0) |
| `head/tail0/tail1` | (-1.5, 0.5, 14) | 0 | (0, 14, 0); 3 x 3 x 7; tex (0, 54) |
| `head/tail0/tail1/tail2` | (0.5, 0.5, 6) | 0 | (0, 14, 0); 2 x 2 x 6; tex (41, 32). (1, 10.5, 3); 1 x 9 x 9; tex (25, 19) (the tail fin) |

Elder guardian layer: `createElderGuardianLayer` = the same mesh through `MeshTransformer.scaling(2.35)` (`ELDER_GUARDIAN_SCALE`): vertex y' = 24.016 x (1 - 2.35) + 2.35 y = -32.4216 + 2.35 y, x and z multiplied by 2.35.

### 11.2 Spikes

Twelve spikes. Arrays (read), by index i = 0..11, in units: `SPIKE_X_ROT`, `SPIKE_Y_ROT`, `SPIKE_Z_ROT` are multiples of pi; `SPIKE_X`, `SPIKE_Y`, `SPIKE_Z` are pixels:

| i | X_ROT | Y_ROT | Z_ROT | SPIKE_X | SPIKE_Y | SPIKE_Z |
|---|---|---|---|---|---|---|
| 0 | 1.75 | 0 | 0 | 0 | -8 | 8 |
| 1 | 0.25 | 0 | 0 | 0 | -8 | -8 |
| 2 | 0 | 0 | 0.25 | 8 | -8 | 0 |
| 3 | 0 | 0 | 1.75 | -8 | -8 | 0 |
| 4 | 0.5 | 0.25 | 0 | -8 | 0 | -8 |
| 5 | 0.5 | 1.75 | 0 | 8 | 0 | -8 |
| 6 | 0.5 | 1.25 | 0 | 8 | 0 | 8 |
| 7 | 0.5 | 0.75 | 0 | -8 | 0 | 8 |
| 8 | 1.25 | 0 | 0 | 0 | 8 | 8 |
| 9 | 0.75 | 0 | 0 | 0 | 8 | -8 |
| 10 | 0 | 0 | 0.75 | 8 | 8 | 0 |
| 11 | 0 | 0 | 1.25 | -8 | 8 | 0 |

Spike offset function o(i, a, e) = 1 + cos(a x 1.5 + i) x 0.01 - e. Position: x = SPIKE_X[i] x o, y = 16 + SPIKE_Y[i] x o, z = SPIKE_Z[i] x o. The part's pose rotation is (pi x X_ROT, pi x Y_ROT, pi x Z_ROT), fixed. At bake time the pose position uses a = 0, e = 0 (so the initial pivots are, for example, i = 0: (0, 7.92, 8.08) and i = 2: (7.9667, 8.0333, 0)); each frame `setupSpikes(age, extend)` assigns the part's x, y, z from o(i, `ageInTicks`, extend). The spike parts are named `spike<i>`.

### 11.3 `setupAnim`

1. `head.yRot` = `yRot` x 0.017453292, `head.xRot` = `xRot` x 0.017453292.
2. extend = (1 - `spikesAnimation`) x 0.55; spikes positioned as above with a = `ageInTicks`. (`spikesAnimation` = 1: spikes fully out; 0: pulled in by 0.55 of their length factor.)
3. Eye. When both `lookAtPosition` and `lookDirection` are non-null: dy = `lookAtPosition.y` - `eyePosition.y`; `eye.y` = 0 when dy > 0 else 1. Let L = (`lookDirection.x`, 0, `lookDirection.z`); R = normalize((`eyePosition.x` - `lookAtPosition.x`, 0, `eyePosition.z` - `lookAtPosition.z`)) rotated about Y by pi/2 (`Vec3.yRot(1.5707964)`); d = L . R; `eye.x` = sqrt(|d|) x 2 x sign(d). The eye is a 2 x 2 pixel pupil that slides sideways (up to 2 pixels) and up or down by one pixel to track the look target. `eye.visible` = true always.
4. Tail: `tail0.yRot` = sin(`tailAnimation`) x pi x 0.05; `tail1.yRot` = sin(`tailAnimation`) x pi x 0.1; `tail2.yRot` = sin(`tailAnimation`) x pi x 0.15 (assigned). (`Mth.sin` takes radians.)

### 11.4 Render state

`GuardianRenderState`: `spikesAnimation`, `tailAnimation`, `eyePosition` (default `Vec3.ZERO`), `lookDirection`, `lookAtPosition`, `attackTargetPosition` (each nullable), `attackTime`, `attackScale`. `extractRenderState`:
- `spikesAnimation` = `Guardian.getSpikesAnimation(partial)` = lerp of the client-side spikes value; `tailAnimation` = `getTailAnimation(partial)` likewise; `eyePosition` = `getEyePosition(partial)`.
- Look target: the entity to look at is the active attack target when there is one, otherwise the **camera entity** (`Minecraft.getCameraEntity()`). When it exists: `lookDirection` = `getViewVector(partial)` of the guardian and `lookAtPosition` = that entity's eye position at the partial; else both null.
- Beam inputs: when the guardian has an active attack target: `attackScale` = `getAttackAnimationScale(partial)` = (`clientSideAttackTime` + partial) / `getAttackDuration()` (`Guardian.getAttackDuration()` = 80 ticks; `ElderGuardian` overrides it to 60, so the elder guardian's beam colour ramp completes in 60 ticks); `attackTime` = `clientSideAttackTime` + partial; `attackTargetPosition` = the target's interpolated position (lerp of old and current x, y, z by partial) plus (0, 0.5 x the target's bounding-box height, 0). Else `attackTargetPosition` = null.

Guardian client particles and sounds (bubbles, flop sound) in the same method are not described here: see 42 and Open question 6. Entity-side client animation values (`Guardian.aiStep`, branch structure and constants read). Each client tick the old tail and spikes values are saved first. Tail speed `clientSideTailAnimationSpeed` (v), exactly one row applies:

| Condition (tested in order) | Update of v |
|---|---|
| not in water | v = 2 |
| in water and `isMoving()` and v < 0.5 | v = 4.0 |
| in water and `isMoving()` and v >= 0.5 | v += (0.5 - v) x 0.1 |
| in water and not moving | v += (0.125 - v) x 0.2 |

Then `clientSideTailAnimation` += v. Spikes value `clientSideSpikesAnimation` (k), exactly one row applies:

| Condition | Update of k |
|---|---|
| not in water | k = `random.nextFloat()` |
| in water and `isMoving()` | k += (0 - k) x 0.25 |
| in water and not moving | k += (1 - k) x 0.06 |

(The 0.06 approach towards 1 is the not-moving branch of the water case, not a step applied after the moving case; the artifact's branch structure was followed.) `clientSideAttackTime` increases by 1 per tick while an attack target is active and it is below `getAttackDuration()`.

### 11.5 Renderer

- `GuardianRenderer(context, shadow, layer)`: shadow 0.5 (elder 1.2), flip 90, no layers. Textures: guardian `textures/entity/guardian/guardian.png`, elder `textures/entity/guardian/guardian_elder.png` (a public constant of `ElderGuardianRenderer`), beam `textures/entity/guardian/guardian_beam.png` (32 x 32).
- `shouldRender`: true when the base test passes; else, when the guardian has an active attack target, the guardian is still drawn if the frustum sees the AABB spanned by its (interpolated) eye position and the target's (interpolated) centre position (the target position plus 0.5 x its bounding height); otherwise false. Positions use `lerp(1, old, current)`, that is, the current position.
- Elder guardian: no `scale` hook; its size comes from the mesh transform (11.1).

### 11.6 The beam (`GuardianRenderer.submit` and `renderBeam`)

After the base submit, when `attackTargetPosition` is non-null: let ph = (`attackTime` x 0.5) mod 1; push; translate (0, `eyeHeight`, 0) (entity-relative; `eyeHeight` is the state's standing eye height); `renderBeam(pose, collector, delta, attackTime, attackScale, ph)` with delta = `attackTargetPosition` - `eyePosition`; pop.

`renderBeam`:
1. L = |delta| + 1; n = normalize(delta); a = acos(n.y); b = pi/2 - atan2(n.z, n.x).
2. Rotate Y by b x 57.295776 degrees, then rotate X by a x 57.295776 degrees (the beam's local +y axis then points along delta, inferred from the vertex layout in step 6).
3. th = `attackTime` x 0.05 x -1.5; c = `attackScale`^2; red = 64 + trunc(c x 191), green = 32 + trunc(c x 191), blue = 128 - trunc(c x 64); alpha 255 (the colour goes from (64, 32, 128) to (255, 223, 64)).
4. Points (x, z) in the local xz plane: inner radius 0.2 at angles th + pi, th, th + pi/2, th + 3 pi/2 named A, B, C, D; outer radius 0.282 at th + 3 pi/4, th + pi/4, th + 7 pi/4, th + 5 pi/4 named P1, P2, P3, P4 in that order. (x = r cos(angle), z = r sin(angle).) Re-verified in round RS17 fix: the constants are loaded in the order 3 pi/4, pi/4, 5 pi/4, 7 pi/4, but they are handed to the vertex routine in the order 3 pi/4, pi/4, 7 pi/4, 5 pi/4, and quad 3 below emits the points in that handed-over order; so P3 is the 7 pi/4 point and P4 the 5 pi/4 point exactly as named here (no swap, no winding change). A reader comparing only the load order would think P3 and P4 are exchanged.
5. v0 = -1 + ph; v1 = v0 + L x 2.5.
6. Geometry (render type `entityCutout(guardian_beam.png)`), vertices written as (x, y, z; u, v), colour as in 3, full-bright light 15728880, no overlay, normal (0, 1, 0), 12 vertices as three quads:
   - quad 1: (A.x, L, A.z; 0.4999, v1), (A.x, 0, A.z; 0.4999, v0), (B.x, 0, B.z; 0, v0), (B.x, L, B.z; 0, v1);
   - quad 2: (C.x, L, C.z; 0.4999, v1), (C.x, 0, C.z; 0.4999, v0), (D.x, 0, D.z; 0, v0), (D.x, L, D.z; 0, v1);
   - quad 3 (end cap at y = L, the sparkle): with f = 0.5 when floor(`attackTime`) is even else 0: (P1.x, L, P1.z; 0.5, f + 0.5), (P2.x, L, P2.z; 1, f + 0.5), (P3.x, L, P3.z; 1, f), (P4.x, L, P4.z; 0.5, f).
   Quads 1 and 2 are two crossing planes of width 0.4 (the diameters A to B and C to D) that rotate with time; the texture u covers 0 to 0.4999 and v scrolls by 2.5 per block of length.

### 11.7 Elder guardian apparition (`ElderGuardianParticle`, `GuardianParticleModel`)

The particle uses a `GuardianParticleModel` (a `Model<Unit>` over the baked `ELDER_GUARDIAN` layer, so it is the scaled elder mesh) with render type `entityTranslucent(guardian_elder.png)`; lifetime 30 ticks, gravity 0; particle group `ELDER_GUARDIANS`. Each frame, with f = (age + partial) / lifetime: alpha = 0.05 + 0.5 x sin(f x 3.1415927) (white, `ARGB.colorFromFloat(alpha, 1, 1, 1)`); a fresh pose: rotate by the camera rotation quaternion; rotate X by (60 - 150 f) degrees; scale (0.42553192, -0.42553192, -0.42553192); translate (0, -0.56, 3.5); drawn with light 15728880, no overlay. Who spawns it and when is the server's business (21).

---

## 12. Shulker (`ShulkerModel`, `ShulkerRenderer`, `ShulkerRenderState`)

### 12.1 Geometry (64 x 64)

| Part | pivot | box (origin; size) | tex |
|---|---|---|---|
| `lid` | (0, 24, 0) | (-8, -16, -8); 16 x 12 x 16 | (0, 0) |
| `base` | (0, 24, 0) | (-8, -8, -8); 16 x 8 x 16 | (0, 28) |
| `head` | (0, 12, 0) | (-3, 0, -3); 6 x 6 x 6 | (0, 52) |

`SHULKER_BOX` (`createBoxLayer`, for the block entity) is the `lid` and `base` only. The model's render function is `entityCutoutZOffset`.

### 12.2 `setupAnim`

Let p = `peekAmount`, f2 = (0.5 + p) x 3.1415927, f3 = -1 + sin(f2), f4 = 0, and when f2 > 3.1415927 (p > 0.5): f4 = sin(`ageInTicks` x 0.1) x 0.7.
- `lid` position assigned: (0, 16 + sin(f2) x 8 + f4, 0).
- `lid.yRot` = (f3^4) x 3.1415927 x 0.125 when p > 0.3, else 0 (assigned). The factor f3^4 is f3 x f3 x f3 x f3.
- `head.xRot` = `xRot` x 0.017453292; `head.yRot` = ((`yHeadRot` - 180) - `yBodyRot`) x 0.017453292 (assigned).

Closed (p = 0): lid y = 24 (on the base), rotation 0. Fully open (p = 1): lid y = 8 + 0.7 sin(0.1 x `ageInTicks`) (the f4 term is added for p > 0.5), which is 8 only when sin(0.1 x age) = 0, for example at age 0; `yRot` = 2 pi (a full turn that is visually the identity). 15.13 gives the same cases.

### 12.3 Render state and renderer

- `ShulkerRenderState`: `renderOffset` (default `Vec3.ZERO`), `attachFace` (default `DOWN`), `color` (nullable dye), `peekAmount`, `yHeadRot`, `yBodyRot`.
- `extractRenderState`: `renderOffset` = `Shulker.getRenderPosition(partial)` or zero when null; `color` = `getColor()` (the data byte is a dye id, 16 means none; `getVariant` maps the byte through `orElse(16)`: inferred, Open question 7); `peekAmount` = `getClientPeekAmount(partial)` = lerp(partial, `currentPeekAmountO`, `currentPeekAmount`); `yHeadRot`, `yBodyRot` from the entity; `attachFace` = `getAttachFace()`.
- `getRenderOffset(state)` = `renderOffset`. `getRenderPosition(partial)` (read): null when there is no old attach position or `clientSideTeleportInterpolation` <= 0; otherwise e = ((`clientSideTeleportInterpolation` - partial) / 6)^2 x `scale`, and the offset is -(e x (block position - old attach block position)) per axis. `clientSideTeleportInterpolation` is set to 6 when the attach position changes on the client and counts down by 1 per tick; the shulker therefore slides from the old position to the new one over 6 ticks, quadratically.
- `shouldRender`: the base test, or else visible when the frustum sees the AABB spanned by the render position (when not null; otherwise false) and the bottom centre of the entity's block position, both lifted by half the entity height, inflated by (half width, half height, half width).
- Peek amount data: `currentPeekAmount` moves towards (raw byte x 0.01) by 0.05 per tick (clamped to [raw x 0.01, 1] when above and [0, raw x 0.01] when below).
- `setupRotations(state, pose, bodyRot, scale)`: the base rotations with bodyRot + 180 degrees (34-1 §6.5), then rotate about the point (0, 0.5, 0) by the quaternion `attachFace.getOpposite().getRotation()` (`PoseStack.rotateAround`). Quaternion by direction (read from `Direction.getRotation`): `UP` identity; `DOWN` rotationX(pi); `NORTH` rotationXYZ(pi/2, 0, pi); `SOUTH` rotationX(pi/2); `WEST` rotationXYZ(pi/2, 0, pi/2); `EAST` rotationXYZ(pi/2, 0, -pi/2). So by attach face: DOWN uses identity (the usual upright shulker), UP uses rotationX(pi), NORTH uses rotationX(pi/2), SOUTH rotationXYZ(pi/2, 0, pi), WEST rotationXYZ(pi/2, 0, -pi/2), EAST rotationXYZ(pi/2, 0, pi/2). The component order of `rotationXYZ` is Open question 3.
- Texture: `ShulkerRenderer.getTextureLocation(color)`: a null colour gives the default sprite; otherwise the entry of a table sorted by `DyeColor.getId`. Read in `Sheets`: `SHULKER_MAPPER` is a `SpriteMapper` with the prefix `entity/shulker`; the default sprite id is `shulker`; `colorToShulkerSprite(color)` is the string `shulker_` followed by `DyeColor.getName()`; `SHULKER_TEXTURE_LOCATION` is the list of those sprites sorted by `DyeColor.getId`; `ShulkerRenderer` turns each sprite id into `textures/<path>.png` by string concatenation. So the files are `textures/entity/shulker/shulker.png` and `textures/entity/shulker/shulker_<name>.png`. The dye ids (`DyeColor`, read) are: 0 white, 1 orange, 2 magenta, 3 light_blue, 4 yellow, 5 lime, 6 pink, 7 gray, 8 light_gray, 9 cyan, 10 purple, 11 blue, 12 brown, 13 green, 14 red, 15 black. The artifact contains the file for exactly those sixteen names plus `shulker.png`. Shadow 0, flip 90, no layers.

---

## 13. Shulker bullet (`ShulkerBulletModel`, `ShulkerBulletRenderer`)

Geometry (64 x 32): one part `main` (pivot 0) with three boxes: (-4, -4, -1); 8 x 8 x 2; tex (0, 0). (-1, -4, -4); 2 x 8 x 8; tex (0, 10). (-4, -1, -4); 8 x 2 x 8; tex (20, 0). `setupAnim`: `main.yRot` = `yRot` x 0.017453292, `main.xRot` = `xRot` x 0.017453292 (state `yRot`/`xRot` = `ShulkerBullet.getYRot(partial)`, `getXRot(partial)`).

`ShulkerBulletRenderer` is a plain `EntityRenderer`: `getBlockLightLevel` = 15 (full block light). `submit(state, pose, collector, camera)`, with a = `ageInTicks`: push; translate (0, 0.15, 0); rotate Y by sin(a x 0.1) x 180 degrees; rotate X by cos(a x 0.1) x 180; rotate Z by sin(a x 0.15) x 360; scale (-0.5, -0.5, 0.5); submit the model with texture `textures/entity/shulker/spark.png` (the model's `entityCutout`), entity light, no overlay; then scale (1.5, 1.5, 1.5) on top and submit the model again at order 1 with `RenderTypes.entityTranslucent(spark.png)` and tint 654311423 (0x26FFFFFF, about 15% alpha); pop; then the base entity submit (name tag and so on). The second pass is a 1.5 times larger translucent halo of the same model.

---

## 14. Render types and pipelines used by this part

Read from `RenderTypes` and `RenderPipelines`. The fragment code and the snippets named (`ENTITY_SNIPPET`, `ENTITY_NO_LIGHTMAP_SNIPPET`, `EYES_SNIPPET`) were not read (Open question 2); 34-1 §6.7 lists `entityCutout`.

| Render type | Used by | Facts read |
|---|---|---|
| `entityCutout(tex)` | main models of creeper, enderman, silverfish, endermite, spider, slime, magma cube, warden, shulker bullet pass 1, guardian | (34-1 §6.7) alpha cutout 0.1, per-face lighting, no culling |
| `entityCutoutZOffset(tex)` | shulker | named by `ShulkerModel`; pipeline not traced |
| `entityTranslucent(tex)` | breeze body, slime outer, sulfur cube (all), elder guardian particle, shulker bullet halo | pipeline `entity_translucent`: shader define ALPHA_CUTOUT 0.1, PER_FACE_LIGHTING, sampler 1 bound, blend `TRANSLUCENT`, culling off |
| `eyes(tex)` | spider, enderman, phantom eyes layers | pipeline `eyes`: snippets `ENTITY_NO_LIGHTMAP` and `EYES`, blend `TRANSLUCENT`, depth test `GREATER_THAN_OR_EQUAL` with depth writes off |
| `entityTranslucentEmissive(tex)` | warden layers; `breezeEyes` uses the same function with its boolean argument false | pipeline `entity_translucent_emissive`: ALPHA_CUTOUT 0.1, PER_FACE_LIGHTING, sampler 1, blend `TRANSLUCENT`, culling off, depth test `GREATER_THAN_OR_EQUAL` with writes off |
| `energySwirl(tex, u, v)` | creeper power layer | pipeline `energy_swirl`: blend `ADDITIVE`, default depth state; the render type uses an `OffsetTextureTransform(u, v)`, the lightmap, the overlay, `sortOnUpload` |
| `breezeWind(tex, u, v)` | breeze wind layer | pipeline `breeze_wind`: ALPHA_CUTOUT 0.1, APPLY_TEXTURE_MATRIX, NO_OVERLAY, NO_CARDINAL_LIGHTING, blend `TRANSLUCENT`, culling off; offset texture transform (u, v), lightmap, `sortOnUpload` |
| `outline(tex)` | slime outer layer when glowing and invisible | named only |

(`GREATER_THAN_OR_EQUAL` as a depth comparison suggests a reversed depth buffer; not verified.)

---

## 15. Validation: worked examples and checks

All numbers below were computed from the formulas of this document. In round RS17 fix examples 15.1, 15.2, 15.3, 15.5, 15.8, 15.9, 15.10, 15.11 (both channels), 15.12, 15.13 and 15.14 were recomputed independently and all agree to the digits printed; 15.4, 15.6, 15.7, 15.15 and 15.16 were not recomputed in that round.

15.1 **Creeper scale.** k = 1: f = 1 + sin(100) x 0.01 = 0.994936 (sin 100 rad = -0.506366); c4 = 1; scale = (1.392911, 1.105598, 1.392911). k = 0.5: f = 1 + sin(50) x 0.5 x 0.01 = 0.998688 (sin 50 rad = -0.262375), c4 = 0.0625, scale = (1.025 x f, 1.00625 / f, 1.025 x f) = (1.023655, 1.007572, 1.023655). k = 0: (1, 1, 1) exactly. Flash: k = 0.05 gives trunc(0.5) = 0, even, progress 0; k = 0.15 gives trunc(1.5) = 1, odd, progress clamp(0.15, 0.5, 1) = 0.5; k = 0.55 gives 5, odd, progress 0.55. With progress 0.5 the overlay column is u = trunc(0.5 x 15) = 7, white alpha floor((1 - 7/15 x 0.75) x 255) = 165 (34-1 §6.9).

15.2 **Creeper legs.** w = 1.0, s = 1.0: theta = 0.6662; `left_hind_leg.xRot` = `right_front_leg.xRot` = cos(0.6662) x 1.4 = 1.1006; `right_hind_leg.xRot` = `left_front_leg.xRot` = -1.1006.

15.3 **Cube mob scale.** Slime size 2, `squish` 0.5: q = 0.5 / 2 = 0.25, r = 0.8: scale (1.6, 2.5, 1.6) (agrees with 34-1 §11 V14). Size 4, `squish` -0.3: q = -0.3 / 3 = -0.1, r = 1 / 0.9 = 1.1111: scale (4.4444, 3.6, 4.4444). Size 1, squish 0: (1, 1, 1), shadow radius 0.25.

15.4 **Magma cube slices.** `squish` 0.5: pivot y = (-3.4, -2.55, -1.7, -0.85, 0, 0.85, 1.7, 2.55); `squish` <= 0: all 0. Slice texture offsets (0, 0), (0, 9), (0, 18), (0, 27), (32, 0), (32, 9), (32, 18), (32, 27).

15.5 **Phantom height.** Size 0 (s = 1): the body pivot (model y_m = 0) is at world y = -(y_m/16 - 1.501 + 1.3125) = 0.1885 above the entity position; the wing and tail formulas at `flapTime` = 3: t = 3 x 7.448451 x 0.017453292 = 0.39000 rad; wing `zRot` = cos(0.39) x 16 x 0.017453292 = 0.25828 rad; tail `xRot` = -(5 + cos(0.78) x 5) x 0.017453292 = -0.14931 rad (the numbers printed are for t as computed; cos(0.78) = 0.7109).

15.6 **Silverfish and endermite pivots.** Silverfish z = (-3.5, -1.5, 1.0, 4.0, 7.0, 9.5, 11.5) and pivot y = (22, 21, 20, 21, 22, 23, 23); endermite z = (-3.5, 0, 3, 4), pivot y = (21, 20, 21, 22). At `ageInTicks` = 0 the silverfish `yRot` per segment = (0.47124, 0.27992, 0.09233, 0.04915, -0.14562, -0.44429, -0.74696) rad and `x` = (0, 0.28525, 0, 0.62058, 1.19513, 1.33286, 0.77664) pixels; the endermite `yRot` = (0.09425, 0.05598, 0.01847, 0.00983) rad and `x` = (0, 0.14263, 0, 0.31029).

15.7 **Texture sizes.** The declared sizes agree with the artifact's PNGs: creeper, enderman, endermite, silverfish, slime, spider (and eyes) 64 x 32; magma cube, guardian (both), phantom (and eyes), shulker (all 17) 64 x 64; breeze body and eyes 32 x 32, breeze wind 128 x 128; warden (all five) 128 x 128; sulfur cube outer and inner 128 x 128, small 64 x 64; shulker spark 64 x 32; guardian beam 32 x 32 (sampled by fractions in the beam code, not by model texels).

15.8 **Spider legs.** w = 1.0, s = 1.0: theta = 0.6662; for the hind pair A(0) = -(cos(1.3324) x 0.4) = -0.09446 and B(0) = |sin(0.6662) x 0.4| = 0.24720, so `right_hind_leg.yRot` = 0.7853982 - 0.09446 and `left_hind_leg.yRot` = -0.7853982 + 0.09446; the front pair (phi = 3 pi/2): A = -0.38869, B = 0.31447.

15.9 **Warden walk.** `walkAnimationPos` 1.0, `walkAnimationSpeed` 0.2: p = 0.8662, m = 0.5 (3 x 0.2 = 0.6 clamps to 0.5), m2 = 0.35; `head.zRot` += 0.11428; `head.xRot` += -0.31999; `body.zRot` = 0.03809; `body.xRot` = 0.22670; `left_leg.xRot` = 0.32386; `right_leg.xRot` = -0.32386; `left_arm.xRot` = -0.25909; `right_arm.xRot` = -0.30475.

15.10 **Warden layer alphas.** `ageInTicks` 0: spots 1 alpha = 0.25, spots 2 alpha = 0 (cos(pi) x 0.25 < 0 clamps to 0, the layer is skipped); at 20: spots 1 alpha = cos(0.9) x 0.25 = 0.1554.

15.11 **Keyframe check.** `WARDEN_EMERGE` `body` rotation channel at t = 0.26 s: first key with timestamp >= 0.26 is the key at 0.52, so i = 0, j = 1, alpha = 0.26 / 0.52 = 0.5; Catmull-Rom with p0 = p1 = key 0 (z = 0) , p2 = key 1 (z = -22.5), p3 = key 2 (z = -7.5): 0.5 x (0 + (-22.5) x 0.5 + (0 - 0 - 90 + 7.5) x 0.25 + (0 - 0 + 67.5 - 7.5) x 0.125) = -12.1875 degrees = -0.212712 rad added to the part's `zRot`. The `body` position channel at the same time: authored y keys -63, -63, -56, -32: value -61 authored, stored y = +61 pixels (the body is still 61 pixels below its resting pose). With an `AnimationState` started at tick 60 and `ageInTicks` 100: time = trunc((100 - 60) x 50) = 2000 ms = 2.0 s.

15.12 **Guardian spikes.** `spikesAnimation` 0 (pulled in): extend = 0.55; spike 2 at age 0: o = 1 + cos(2) x 0.01 - 0.55 = 0.44584; position (3.567, 12.433, 0). With `spikesAnimation` 1 (extend 0): o(2, 0, 0) = 1 + cos(2) x 0.01 = 0.995839; position (7.9667, 8.0333, 0). Beam colour at `attackScale` 0, 0.5, 1: (64, 32, 128), (111, 79, 112), (255, 223, 64).

15.13 **Shulker lid.** p = 0: lid y 24, yRot 0; p = 0.3: y = 16 + sin(0.8 pi) x 8 = 20.702, yRot 0 (p is not above 0.3); p = 0.5: y = 16, yRot = (-1 + sin(pi))^4 x pi x 0.125 = 0.3927; p = 1.0: yRot = 6.2832 and y = 8 + f4 with f4 = sin(`ageInTicks` x 0.1) x 0.7, so y = 8 only at `ageInTicks` 0 (or when sin(0.1 x age) = 0); the other cases have p not above 0.5 and f4 = 0.

15.14 **Sulfur cube.** Adult visible, no fuse: translate y = 0.98 - 0.0625 = 0.9175 then scale 0.5; baby: 1.24 - 0.0625 = 1.1775 with scale 1.0; swell at fuse 5: 0.3 x (1 - 0.5)^4 = 0.01875, at fuse 1: 0.3 x 0.9^4 = 0.19683, at fuse 9: 0.00003. `isLit`: fuse 3.2 gives trunc(0.64) = 0 even, lit; fuse 7.3 gives 1, not lit.

15.15 **Scaled meshes.** Cave spider shift 7.2048 px (scale 0.7); elder guardian shift -32.4216 px (scale 2.35); in both the y = 24 foot line maps to 24.016 - 0.016 s (about 24).

15.16 **Eyes and layers.** Spider: the parent model's posed parts are re-submitted, so a cave spider's eyes inherit the 0.7 scale. Breeze body pass draws the `eyes` boxes together with the head boxes (identical geometry), the eyes pass draws them again with the emissive translucent texture.

---

## 16. Open questions

1. (Resolved: the 34-1 master index now lists all sixteen types under part 6; see the Allocation paragraph in section 0.)
2. **Pipelines.** The shader programs (`entity`, `eyes`, `energy_swirl`, `breeze_wind`), the snippets `ENTITY_SNIPPET`, `ENTITY_NO_LIGHTMAP_SNIPPET`, `EYES_SNIPPET`, the exact blend equations of `TRANSLUCENT` and `ADDITIVE`, the meaning of the depth compare `GREATER_THAN_OR_EQUAL` (reversed depth?) and the order-independent-transparency variants (`OIT_*`) were not traced. `entityCutoutZOffset` was not traced. The face and light behaviour of `eyes` (no lightmap) is read only as a snippet name.
3. **Quaternion composition order.** The order in which `Quaternionf.rotationXYZ(ax, ay, az)` applies the three axis rotations (used by the shulker attach rotations) and `rotationZYX` (34-1 Open question 3) were not read in the JOML library; recalled, not verified: the stated convention applies the rightmost axis first.
4. **Warden pulsating-spots layer.** By the rule read in `retainExactParts` the head and arms of the pulsating-spots mesh lose their cubes because their parent `body` is named. Whether the game really draws only body and legs in that layer was not verified by a render. The same rule leaves the heart layer as `body` alone and the tendril layer as the two tendrils.
5. **`KeyframeAnimation` bake lookup.** The creation of the flat name map and its behaviour for duplicate leaf names (the warden and breeze use unique names) is as in 34-1 §5.3 and was not re-read.
6. **Guardian client animation.** The branch structure of `Guardian.aiStep` is read (11.4 tables); the particle spawning, bubble particles and flop sound in the same method were not described. The attack durations were read (80 and 60, 11.4). Who spawns the apparition particle and when was not read.
7. **Shulker colour byte.** The colour byte 16 meaning "none" is inferred from `orElse(16)`. The texture path rule is now read (12.3: `SHULKER_MAPPER` prefix `entity/shulker`, `shulker_` + dye name, `textures/<path>.png`).
8. **Slime and magma cube sizes, creeper swell tick, phantom id.** The size sets, creeper `maxSwell` and tick, and the network entity id source of the phantom flap offset belong to 20 and 45; they were not re-read. The `decreaseSquish` overrides were looked for and read (7.4: only `MagmaCube` overrides, 0.9).
9. **Sulfur cube contained block for a non-block BODY item.** The cube-specific extraction resolves `containedBlock` for every non-empty, non-skull BODY stack, using `Block.byItem(item).defaultBlockState()`; for a non-block item that is the air state, and whether `BlockModelResolver.update` leaves the render state empty for air was not read. The head-slot fields are now read (7.7). Body-armor slot semantics for a mob (which items the server accepts) belong to 20 and were not traced.
10. **Block display for carried blocks.** The effect of the default `BlockDisplayContext` on the enderman and sulfur cube block drawing (the block model's display transform) and `BlockModelRenderState.submit` were not read (12 §8).
11. **Entity sizes.** Hitbox sizes and eye heights of the sixteen entities are in 21 §2 and were not re-read here (the guardian look-at and the sulfur-cube fit depend on them).
12. **Face orientation.** The exact UV orientation (which edge of each rectangle is up) of every cuboid face and the polygon mirror's u reversal are as in 34-1 §1.3; only the rectangle layout was re-verified here.
13. **`BreezeModel` constants.** `WIND_TOP_SPEED`, `WIND_MIDDLE_SPEED` and `WIND_BOTTOM_SPEED` are declared and not used in any method read; they may be unused leftovers (inferred) or used by a method not looked at.
14. **`CustomHeadLayer` on the sulfur cube.** The head-slot field source is read (7.7) and the inner layer returns early when `wornHeadType` is set (read). Not traced: whether the generic layer ignores `headItem` for this model beyond 34-1 section 8.4.

15. (Closed: examples 15.4, 15.6, 15.7 and 15.15 re-derive correctly from the formulas and values of this document; 15.16 is descriptive.)
16. **Client particles and sounds of the mobs.** Warden `clientDiggingParticles` (spawn rule beyond what 8.3 states), Breeze `emitGroundParticles`, `emitJumpTrailParticles`, `resetJumpTrail`, `playWhirlSound` and the `soundTick` branch (9.3), Guardian bubble and flop effects, and Enderman portal particle count and stare sound data item (3.3) were read only as call sites; the particle types, counts and sound events are for 42 and were not traced here.
17. **Verification coverage of parts 4 and 5.** Sections 7.4 to 7.7, 11.4 to 11.7 and 13 were checked in review only against this document's own formulas and were not re-read against the artifact in that review. Examples 15.4, 15.6, 15.7 and 15.15 were re-derived from this document's formulas only (see 15 and Open question 15), not from the artifact. Example 15.1 (creeper scale and flash) was recomputed from the formulas (sin 100 rad = -0.506366 gives f = 0.994936) with no artifact re-read of its constants beyond section 2.
18. **34-1 section 8.5 cross-reference.** The invisibility skip of the emissive layer rule (8.5 above) belongs in 34-1 section 8.5 too; that file is outside this part's edit scope and is flagged for its owner.
