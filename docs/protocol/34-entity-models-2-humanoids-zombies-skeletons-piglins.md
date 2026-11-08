# 34 part 2. Entity models and renderers: humanoid-base mobs (zombies, skeletons, piglins, armor stand)

| | |
|---|---|
| Covers | The models, layer definitions, render states, animation formulas and renderers of the humanoid-base entities other than the player: zombie, husk, drowned (with its outer layer), giant, baby zombie, baby husk and baby drowned; skeleton, stray, bogged, wither skeleton, parched (with the clothing layers); piglin, piglin brute, zombified piglin (adult and baby); armor stand (normal and small). Also the armor layer and the held-item layer as they apply to these mobs, the render-state fields, the texture paths and the transform pipeline of these renderers. Zombie villager, illagers, witch, vex (part 3) and undead horses (part 4) are excluded. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `HumanoidModel` (mesh, animation, arm poses, armor mesh sets, `BABY_TRANSFORMER`), `AnimationUtils`, `BabyModelTransform`, `MeshTransformer`, `PartPose`, `PartDefinition`, `CubeDeformation`, `LayerDefinitions.createRoots`, `ZombieModel`, `GiantZombieModel`, `DrownedModel`, `BabyZombieModel`, `BabyDrownedModel`, `SkeletonModel`, `BoggedModel`, `AbstractPiglinModel`, `AdultPiglinModel`, `PiglinModel`, `BabyPiglinModel`, `ZombifiedPiglinModel` and its adult and baby classes, `PlayerModel` (only the mesh and armor-set parts that piglins inherit), `ArmorStandModel`, `ArmorStandArmorModel`, `ArmorModelSet`, the renderers `HumanoidMobRenderer`, `AgeableMobRenderer`, `MobRenderer`, `LivingEntityRenderer`, `AbstractZombieRenderer`, `ZombieRenderer`, `HuskRenderer`, `DrownedRenderer`, `GiantMobRenderer`, `AbstractSkeletonRenderer`, `SkeletonRenderer`, `StrayRenderer`, `BoggedRenderer`, `ParchedRenderer`, `WitherSkeletonRenderer`, `PiglinRenderer`, `ZombifiedPiglinRenderer`, `ArmorStandRenderer`, `EntityRenderers`, the layers `HumanoidArmorLayer`, `EquipmentLayerRenderer`, `ItemInHandLayer`, `CustomHeadLayer`, `WingsLayer`, `DrownedOuterLayer`, `SkeletonClothingLayer`, `RenderLayer`, the render states of the scope, and `Piglin`, `PiglinBrute`, `PiglinArmPose`, `ArmorStand` for the values that feed the states. |
| Scope decisions | Standard Minecraft content is the target (ticket CC-0001; design README Parts 0, 1, 4; GAP-25). Textures, equipment asset JSON and item models are data (extracted by the tool into a resource pack, 22); this document gives only the texture paths the renderers ask for. Model geometry, animation, and the renderers are code and are given completely. The shared model framework (`ModelPart`, box UV unwrap, the pose stack) is cross-referenced: 14 §5.3 and 12 §7.4 for the box unwrap and the humanoid skin layout, 12 §7.3 for the player's transform; this document restates only what the mobs need. |

Conventions. Model units are pixels (1/16 block), x to the model's left, y down, z to the front, angles in radians unless
a row says degrees. A box is written `origin (x, y, z), size (w, h, d), tex (u, v)`; "grow g" expands every face by g
pixels without changing the UV rectangle (the UV size stays w, h, d, 14 §5.3); "mirror" flips the box left to right
(`CubeListBuilder.mirror`, used for left limbs that reuse the right limb's texture region). A part pose is
`(pivot x, y, z; rotation x, y, z; scale)`. All float constants below were read as single-precision values.
"State" is the render state the renderer fills each frame (7).

---

## 1. Shared pieces

### 1.1 Part pose application (`ModelPart.translateAndRotate`)

For a part, in this order on the pose stack: translate by (x, y, z) / 16; rotate by the quaternion built with
`rotationZYX(zRot, yRot, xRot)` (Z applied first to model vertices, then Y, then X) when any angle is non-zero; scale by
(xScale, yScale, zScale) when any is not 1. Children are drawn inside the parent's transform, so a scale on a part scales
its children. `Model.setupAnim` first calls `resetPose` on every part (restores the initial pose of 3 below), so all
adjustments in 4 and 5 are relative to the initial pose: "+=" means "initial value plus".

### 1.2 The base humanoid mesh (`HumanoidModel.createMesh(grow, yOffset)`)

Non-player humanoids use the **64 x 32 style left limbs**: the left arm and left leg are *mirrored copies of the right
limb texture regions*, not the separate left regions of the 64 x 64 player skin (12 §7.4 lists the player). Every part
except `hat` has its pivot y increased by `yOffset` (0 for every model in this document); `grow` applies to every cuboid
below, and the hat cuboid gets `grow + 0.5`.

| Part | Pivot (x, y, z) | Cuboid origin | Size | tex (u, v) | Mirror |
|---|---|---|---|---|---|
| head | (0, 0, 0) | (-4, -8, -4) | 8, 8, 8 | (0, 0) | no |
| hat (child of head) | (0, 0, 0) | (-4, -8, -4), grow + 0.5 | 8, 8, 8 | (32, 0) | no |
| body | (0, 0, 0) | (-4, 0, -2) | 8, 12, 4 | (16, 16) | no |
| right_arm | (-5, 2, 0) | (-3, -2, -2) | 4, 12, 4 | (40, 16) | no |
| left_arm | (5, 2, 0) | (-1, -2, -2) | 4, 12, 4 | (40, 16) | yes |
| right_leg | (-1.9, 12, 0) | (-2, 0, -2) | 4, 12, 4 | (0, 16) | no |
| left_leg | (1.9, 12, 0) | (-2, 0, -2) | 4, 12, 4 | (0, 16) | yes |

Layer sizes used with this mesh: 64 x 64 for zombie, husk, giant, drowned and the armor-stand family (3); 64 x 32 for
the stray, bogged and parched outer layers and for adult armor.

### 1.3 Mesh transformers

- **Scaling** (`MeshTransformer.scaling(s)`): every direct child of the root gets its pose replaced by `pose.scaled(s)`
  (multiply pivot x, y, z and the three scales by s) and then translated by `(0, 24.016 × (1 − s), 0)`. This keeps the
  feet line near y = 24 (feet at 24.016 − 0.016 s). Values used: s = 6 gives dy = −120.08; s = 1.0625 gives dy = −1.501;
  s = 1.2 gives dy = −4.8032.
- **Baby transform** (`HumanoidModel.BABY_TRANSFORMER`, `BabyModelTransform(scaleHead = true, headYOffset = 16.0,
  headZOffset = 0, headScale = 2, bodyScale = 2, bodyYOffset = 24, headParts = {head})`): head factor f_h = 1.5 /
  headScale = 0.75, body factor f_b = 1 / bodyScale = 0.5. For each direct child of the root: the `head` pose becomes
  `pose.translated(0, 16, 0).scaled(0.75)`, every other part `pose.translated(0, 24, 0).scaled(0.5)` (translate first, then
  scale, so the translation is also scaled). Children (the hat) are not changed but inherit the scale at draw time.
  Used only by the small armor stand and its armor (3.9).

### 1.4 Armor mesh sets (`HumanoidModel.createArmorMeshSet`, `createBabyArmorMeshSet`)

An armor set has four layer definitions (head, chest, legs, feet), built from copies of one base mesh with some parts
kept and the rest removed; each model that wears armor has its own set (`ModelLayers.X_ARMOR`). The `inner` and `outer`
grows are the constants of the call site.

- Base adult armor mesh (`createBaseArmorMesh(g)`): the base humanoid mesh (1.2) with grow g, except that both legs are
  rebuilt with grow `g − 0.1` (right leg tex (0, 16); left leg tex (0, 16) mirrored; boxes as 1.2, pivots (−1.9, 12, 0) and
  (1.9, 12, 0)).
- Slot to retained parts (`ADULT_ARMOR_PARTS_PER_SLOT`): head = `head` and its children (so the hat); chest = exactly
  `body`, `left_arm`, `right_arm`; legs = exactly `left_leg`, `right_leg`, `body`; feet = exactly `left_leg`, `right_leg`.
- Grow per slot: head, chest and feet use the **outer** grow; legs use the **inner** grow. (Call `createArmorMeshSet(inner,
  outer)`: legs from inner, the other three from outer.)
- Constants (`LayerDefinitions`): outer 1.0 (`OUTER_ARMOR_DEFORMATION`), inner 0.5 (`INNER_ARMOR_DEFORMATION`), baby outer
  (−0.1, 0.5, 0.3) (grow x, y, z), baby inner (−0.1, 0.3, 0.3), baby piglin inner 0.7 and outer 0.7, baby piglin arm offset
  pose (0.5, −0.5, 0), piglin outer 1.02 (the piglin armor passes inner 0.5 and outer 1.02).
- Resulting grows for an adult humanoid: helmet and chestplate 1.0 on all cuboids, boots 0.9 on the legs, leggings 0.5 on
  the body and 0.4 on the legs.
- Layer sizes: adult armor sets are 64 x 32; baby sets 64 x 64; piglin armor 64 x 32; baby piglin armor 64 x 64; armor-stand
  armor 64 x 32.
- Baby armor mesh (`createBabyArmorMesh(g, armOffset)`), 64 x 64, parts (boxes with grow g unless stated):
  head tex (0, 0) box (−4.5, −7, −4.5) size 9, 8, 8 at pivot (0, 15, 0), with an empty child `hat`;
  body tex (0, 17) box (−3, −3, −1.5) size 6, 5, 3 at (0, 18, 0);
  waist tex (0, 36) box (−3, −1.2, −1.49) size 5.9, 2, 2.9, grow g − 0.1, at (0, 19, 0);
  right_arm tex (30, 25) box (−1, 0, −1.53) size 2, 5, 3 at (−3.5 − ox, 15.5 + oy, 0 + oz);
  left_arm tex (30, 17) box (−1, 0, −1.53) size 2, 5, 3 at (3.5 + ox, 15.5 + oy, oz);
  inner_body tex (0, 17) box as the body at (0, 18, 0);
  left_leg tex (18, 24) box (−2, −0.2, −2) size 3, 4, 3, grow g − 0.1, at (1.5, 20, 0.5), with child left_foot;
  right_leg tex (18, 17) box (−1, −0.2, −2) size 3, 4, 3, grow g − 0.1, at (−1.5, 20, 0.5), with child right_foot;
  right_foot tex (0, 25) box (−2, 2.9, −2) size 3, 1, 3 and left_foot tex (0, 29), mirrored, box (−1, 2.9, −2) size 3, 1, 3,
  both with pivot (0, 0, 0) and no grow adjustment beyond g; (ox, oy, oz) is the arm offset argument.
  Baby slot parts (`BABY_ARMOR_PARTS_PER_SLOT`): head = `head`; chest = `body`, `left_arm`, `right_arm`; legs = `left_leg`,
  `right_leg`, `waist`; feet = `left_foot`, `right_foot`. The offset (ox, oy, oz) is (0, 0, 0) for the baby zombie family and
  (0.5, −0.5, 0) for baby piglins.

### 1.5 Equipment layers on these mobs (`HumanoidArmorLayer`, `EquipmentLayerRenderer`)

Per frame, after the model is posed from the state, the layer draws four pieces in this fixed order: chest, legs, feet, head.
For a piece: skip when the slot's stack has no equippable component, no asset id, or its slot differs from the slot being
drawn (`shouldRender`). The state carries a copy of the stack only when `shouldRender` held at extraction (otherwise empty).

1. Model: `isBaby` selects the baby set, else the adult set, and then the slot's model (`ArmorModelSet.get`).
2. Layer type: baby and entity type not armor stand: `humanoid_baby`; else legs: `humanoid_leggings`; else `humanoid`.
3. For each layer of the equipment asset for that type (data: `EquipmentClientInfo`; schema and the asset JSON are data),
   the texture is `textures/entity/equipment/<layer type>/<layer texture path>.png` (namespace of the layer's texture id kept).
4. Colour: if the layer is dyeable, the colour is the stack's dyed colour when non-zero, else the layer's `colorWhenUndyed`
   (or 0 when absent); a non-dyeable layer uses −1 (white, no tint). A layer whose resolved colour is 0 is skipped. A layer flagged
   `usePlayerTexture` uses the supplied player texture when the caller gives one (not for these mobs), else its own texture.
5. Render type per layer: `armorCutoutNoCull`, or its glint variant for the first layer only when the stack has foil and has
   no trim; overlay is "no overlay"; layers are submitted in list order.
   Order values (read): the base layer of 1.5 is submitted through `order(n)` with a counter that starts at 1 for the armor
   layer (`HumanoidArmorLayer` uses the overload that passes 1; the wings layer passes 0), increments by one per submission
   (base layers in list order, then the trim, then the trim glint). `SkeletonClothingLayer` and `DrownedOuterLayer` call the
   shared coloured copy-layer render with colour −1 (no tint) and order 1: the model, posed like the parent, is submitted
   through `order(1)` with render type `entityCutout` of the layer texture, skipped when the entity is invisible.
6. Trim (not for `humanoid_baby`): after the base layers, the trim texture is the pattern's asset id with path
   `trims/entity/<layer type>/<pattern path>`; the pattern texture is recolored by the palette of the trim material (`paletteId`,
   palette mechanism 14 §7.4) unless a matching trim override of the asset replaces the texture id or palette; with no palette
   the file `textures/<that path>.png` is used as is. It is drawn with render type `armorTrim` (the pattern's `decal` flag),
   then, if the stack has foil and a trim, once more with `trimmedArmorGlint`.

The model used for each piece is the whole armor model of the slot posed by the same `setupAnim` as the body, so an armor piece
follows every animation in 4 and 5 (the body-part subset of each slot is in 1.4).

### 1.6 Held item and head layers

`ItemInHandLayer` draws the right-hand then the left-hand item. For an item with a non-empty render state: push; apply the
model's `translateToHand(state, arm, stack)` (the posed arm part's transform after the model root's; the skeleton overrides it
in 4.8); rotate X by −90°; rotate Y by 180°; translate by `((left ? −1 : 1) × bx, by, bz) / 16`, where adult (and every armor
stand, including a small one) uses (bx, by, bz) = (1, 2, −10) and a baby (not an armor stand) uses (0, 1, −4.5); if the current
swing is the stab type of the matching hand, `SpearAnimations.thirdPersonAttackItem` adjusts the stack (34 part 1 section 3.8 gives all six `SpearAnimations` functions, and part 1 section 8.3 the layer steps that call them); if the arm is using an item (`ticksUsingItem` > 0) the arm pose's `animateUseItem` adjusts it (only the SPEAR pose does
anything); then the item model is submitted with the display context `THIRD_PERSON_RIGHT_HAND` or `THIRD_PERSON_LEFT_HAND`
(12 §8.2); pop. `CustomHeadLayer` (skull or head item): scale `(hs, vs, hs)`; the model root's and head's transforms; for a skull
block: translate (0, skullYOffset, 0), scale 1.1875, draw the skull model; for any other head item: translate (0, −0.25 +
yOffset, 0), rotate Y 180°, scale (0.625, −0.625, −0.625), submit the head item model. The transforms are (yOffset, skullYOffset,
hs, vs) = (0, 0, 1, 1) by default and (0, 0, 1.0019531, 1) for all piglin family renderers. `WingsLayer` (read this round; it is present on the humanoid mob renderers and the armor stand): reads the chest stack; returns
when it has no equippable component or the component has no asset id. The model is the baby elytra model when `isBaby`, else
the adult one (layers `ELYTRA_BABY`, `ELYTRA`; mesh and animation: 34 part 9, and 47 section 6.3). The texture override is
the player skin's elytra or cape texture, which only a player state can supply, so for every mob here the equipment asset's own texture is
used. Steps: push; translate (0, 0, 0.125); `EquipmentLayerRenderer.renderLayers` with layer type `wings`, the state's outline
colour and the order counter start 0; pop. (The armor layer of 1.5 starts its counter at 1; see the order values in 1.5 step 5.)
Skull and head-block models drawn by `CustomHeadLayer` for these mobs (`SKELETON_SKULL`, `WITHER_SKELETON_SKULL`,
`ZOMBIE_HEAD`, `PIGLIN_HEAD` / `PiglinHeadModel`, and the skull render types): the `SkullModel` mesh pattern is in 34 part 7
(the wither skull); the per-type skull meshes and `PiglinHeadModel` are not specified in any document (Open question 2).

---

## 2. Renderer pipeline of these mobs

### 2.1 Common (`LivingEntityRenderer.submit`)

The pose stack for the body, in order of application on model vertices last to first (the stack is built top to bottom):

1. translate to the entity's interpolated position (camera-relative);
2. scale by `state.scale` (the attribute scale; 1 for these mobs unless a scale attribute is set);
3. `setupRotations(state, stack, bodyRot, scale)` (2.2);
4. scale by (−1, −1, 1);
5. `scale()` hook (empty for every renderer here);
6. translate by (0, −1.501, 0).

A model vertex at y_m (pixels) therefore lies at height P.y + 1.501 − y_m/16 above the position when `state.scale` = 1; the sole
at y_m = 24 is 0.001 above the feet (the same offset as 12 §7.3, without the player's 0.9375 factor).

Visibility: `isBodyVisible = !state.isInvisible`; a ghost draw (`translucent`) happens when the entity is invisible but not
invisible to the local player: model tint 0x26FFFFFF (654311423) with render type `entityTranslucentCull`; else the model's own
render type (cutout; piglin model translucent, see 2.6) when visible; else `outline` when it appears glowing; else nothing.
The overlay texture value is `getOverlayCoords(state, whiteOverlayProgress = 0)`: the red flash when `hasRedOverlay` (hurt or
dying). The layers are then drawn in the order they were added (`model.setupAnim(state)` has already run), then the name tag.

Shadow radius = renderer constant × `state.scale` (`LivingEntityRenderer.getShadowRadius`), and for the `MobRenderer` family
also × `state.ageScale` (0.5 for a baby, 1 otherwise: `LivingEntity.getAgeScale`).

### 2.2 `setupRotations` (`LivingEntityRenderer`, with the armor stand, drowned overrides)

1. If `isShaking(state)`: bodyRot += cos(floor(ageInTicks) × 3.25) × π × 0.4 (degrees added; the cosine argument is radians).
2. If not sleeping: rotate Y by (180 − bodyRot) degrees.
3. If `deathTime` > 0: t = sqrt((deathTime − 1) / 20 × 1.6), capped at 1; rotate Z by t × 90 degrees (`getFlipDegrees` = 90).
   Else if auto-spin attack: rotate X by (−90 − xRot) and Y by ageInTicks × −75 (players only in practice). Else if sleeping:
   rotate Y by A, Z by `getFlipDegrees` (90), Y by 270, where A is read from the state's bed orientation: SOUTH 90, WEST 0, NORTH 270, EAST 180, any other direction 0;
   with no bed orientation, A is the (shake-adjusted) bodyRot of step 1. Else if `isUpsideDown` (custom name
   "Dinnerbone" or "Grumm"): translate (0, (boundingBoxHeight + 0.1) / scale, 0) and rotate Z by 180.
4. For an upside-down entity the extraction also negates `xRot` and `yRot` of the state.

`isShaking`: base = `isFullyFrozen`. Zombie family and piglin: base or `isConverting`. Skeleton family: replaced by the state's
`isShaking`. Armor stand: base.

Overrides. **Armor stand**: rotate Y by (180 − bodyRot) always, then if `wiggle` < 5, rotate Y by sin(wiggle / 1.5 × π) × 3
degrees (no step 1, 3 or 4). **Drowned**: the base steps, then if `swimAmount` > 0: a = lerp(swimAmount, 0, −10 − xRot) degrees; rotate
about X by a around the point (0, boundingBoxHeight / 2 / scale, 0).

### 2.3 Body rotation and head yaw (`extractRenderState`)

yHead = lerp of the entity's head yaw over the partial tick; `bodyRot` = (not riding a living mount) lerp of the body yaw;
`state.yRot` = wrapDegrees(yHead − bodyRot); `state.xRot` = the pitch; the head part uses yRot and xRot in radians (4.1).
Riding a living mount: bodyRot from the mount's body yaw: let d = clamp(wrapDegrees(yHead − mountBodyYaw), −85, 85);
bodyRot = yHead − d, and when |d| > 50, bodyRot += d × 0.2. Walk position and speed come from the entity's walk animation at
the partial tick (zero while riding or dead); `scale` = the scale attribute, `ageScale` as above; `swimAmount`, crouching,
passenger, using-item and the four equipment stacks as in `extractHumanoidRenderState` (7).

---

## 3. Layer definitions (what each entity's model is)

`LayerDefinitions.createRoots` binds a model layer (mesh + texture size) to each entity model. For the scope:

| Layer | Mesh | Texture size | Notes |
|---|---|---|---|
| ZOMBIE | base humanoid mesh, grow 0 (1.2) | 64 x 64 | model class `ZombieModel` |
| ZOMBIE_BABY | baby zombie mesh (3.1), grow 0 | 64 x 64 | `BabyZombieModel` |
| HUSK | the ZOMBIE mesh through scaling 1.0625 | 64 x 64 | adult husk is 6.25% larger |
| HUSK_BABY | the ZOMBIE_BABY mesh, no scaling | 64 x 64 | |
| GIANT | the ZOMBIE mesh through scaling 6.0 | 64 x 64 | `GiantZombieModel` |
| DROWNED | drowned mesh (3.2), grow 0 | 64 x 64 | |
| DROWNED_BABY | the baby zombie mesh, grow 0 | 64 x 64 | `BabyDrownedModel` |
| DROWNED_OUTER_LAYER | drowned mesh, grow 0.25 | 64 x 64 | |
| DROWNED_BABY_OUTER_LAYER | baby zombie mesh, grow 0.25 | 64 x 64 | |
| SKELETON, STRAY | skeleton mesh (3.4), grow 0 | 64 x 32 | |
| WITHER_SKELETON | the skeleton mesh through scaling 1.2 | 64 x 32 | |
| BOGGED | skeleton mesh plus mushrooms (3.5) | 64 x 32 | |
| PARCHED | dual-body skeleton mesh (3.6) | 64 x 64 | |
| STRAY_OUTER_LAYER | base humanoid mesh, grow 0.25 | 64 x 32 | clothes layer |
| BOGGED_OUTER_LAYER | base humanoid mesh, grow 0.2 | 64 x 32 | clothes layer |
| PARCHED_OUTER_LAYER | base humanoid mesh, grow 0.25 | 64 x 32 | clothes layer |
| PIGLIN, PIGLIN_BRUTE, ZOMBIFIED_PIGLIN | adult piglin mesh (3.7) | 64 x 64 | |
| PIGLIN_BABY, ZOMBIFIED_PIGLIN_BABY | baby piglin mesh (3.8) | 64 x 64 | |
| ARMOR_STAND | armor stand mesh (3.9) | 64 x 64 | |
| ARMOR_STAND_SMALL | the ARMOR_STAND mesh through the baby transform (1.3) | 64 x 64 | |
| `*_ARMOR` sets | 1.4, sizes there | | giant, husk and wither skeleton armor sets are the adult set through the same scaling (6.0, 1.0625, 1.2); husk baby armor is the baby set unscaled; the small armor-stand armor is the adult armor-stand armor through the baby transform |

The piglin brute binds PIGLIN_BRUTE for both the adult and the baby slots of its renderer (a brute is never a baby).

### 3.1 Baby zombie mesh (`BabyZombieModel.createBodyLayer(grow)`; grow = 0 or 0.25)

| Part | Pivot (x, y, z) | Cuboids | tex (u, v) | Size | Notes |
|---|---|---|---|---|---|
| body | (0, 17.5, 0) | origin (−2, −2.5, −1) | (16, 16) | 4, 5, 2 | grow |
| head | (0, 15.25, 0) | origin (−3, −6.25, −3), grow 0 | (3, 3) | 6, 6, 6 | |
| | | origin (−3, −6.15, −3), grow 0.25 | (35, 3) | 6, 6, 6 | the head's overlay cube, part of `head` itself |
| hat | child of head, ZERO pose | none | | | empty (keeps the humanoid part list) |
| right_arm | (−3, 15.5, 0) | origin (−1, −0.5, −1) | (36, 16) | 2, 5, 2 | grow |
| left_arm | (3, 15.5, 0) | origin (−1, −0.5, −1) | (28, 16) | 2, 5, 2 | grow |
| right_leg | (−1, 20, 0) | origin (−1, 0, −1) | (8, 16) | 2, 4, 2 | grow |
| left_leg | (1, 20, 0) | origin (−1, 0, −1) | (0, 16) | 2, 4, 2 | grow |

(The head's two cuboids ignore the grow argument and use 0 and 0.25. No part is mirrored.) Heights: head spans y 9 to 15,
body 15 to 20, legs 20 to 24.

### 3.2 Drowned mesh (`DrownedModel.createBodyLayer(grow)`)

The base humanoid mesh with grow `g` (1.2), then two parts are replaced by the 64 x 64 player-style left regions, with the same
pivots: `left_arm`: tex (32, 48), box (−1, −2, −2), size 4, 12, 4, pivot (5, 2, 0), not mirrored; `left_leg`: tex (16, 48), box
(−2, 0, −2), size 4, 12, 4, pivot (1.9, 12, 0), not mirrored. The hat child is kept (grow g + 0.5).

### 3.3 Zombie and husk and giant

The ZOMBIE mesh is 1.2 with grow 0 as is (right arm (40, 16); the left arm is the mirror of it). `ZombieModel` and
`GiantZombieModel` add only the attack animation of 4.3; there are no extra parts.

### 3.4 Skeleton mesh (`SkeletonModel.createBodyLayer`)

The base humanoid mesh with grow 0 (1.2), then the four limbs are replaced by 2-wide limbs (same pivots, same tex origins
as 1.2, mirrored where 1.2 mirrors): right_arm box (−1, −2, −1) size 2, 12, 2 tex (40, 16) pivot (−5, 2, 0); left_arm same
box, tex (40, 16) mirrored, pivot (5, 2, 0); right_leg box (−1, 0, −1) size 2, 12, 2 tex (0, 16) pivot (−2, 12, 0); left_leg same
box tex (0, 16) mirrored, pivot (2, 12, 0). Head, hat and body stay as 1.2 (the leg pivots are −2 and +2, not ±1.9).
Wither skeleton and stray use this mesh (the wither skeleton scaled by 1.2).

### 3.5 Bogged mesh (`BoggedModel.createBodyLayer`)

The skeleton mesh (3.4) plus a child `mushrooms` of `head` (ZERO pose) holding six flat planes (zero thickness along z):

| Part | tex (u, v) | Box origin | Size (w, h, d) | Pivot (x, y, z) | Rotation (x, y, z) |
|---|---|---|---|---|---|
| red_mushroom_1 | (50, 16) | (−3, −3, 0) | 6, 4, 0 | (3, −8, 3) | (0, π/4, 0) |
| red_mushroom_2 | (50, 16) | (−3, −3, 0) | 6, 4, 0 | (3, −8, 3) | (0, 3π/4, 0) |
| brown_mushroom_1 | (50, 22) | (−3, −3, 0) | 6, 4, 0 | (−3, −8, −3) | (0, π/4, 0) |
| brown_mushroom_2 | (50, 22) | (−3, −3, 0) | 6, 4, 0 | (−3, −8, −3) | (0, 3π/4, 0) |
| brown_mushroom_3 | (50, 28) | (−3, −4, 0) | 6, 4, 0 | (−2, −1, 4) | (−π/2, 0, π/4) |
| brown_mushroom_4 | (50, 28) | (−3, −4, 0) | 6, 4, 0 | (−2, −1, 4) | (−π/2, 0, 3π/4) |

(π/4 = 0.7853982, 3π/4 = 2.3561945, π/2 = 1.5707964.) `mushrooms.visible = !state.isSheared` each frame.

### 3.6 Parched mesh (`SkeletonModel.createSingleModelDualBodyLayer`)

A skeleton in which the outer layer is part of the same model (64 x 64, no hat part is declared except an empty `hat` child of
the head). Every part has two cuboids drawn together:

| Part | Pivot | Cuboid A | Cuboid B | Cuboid C |
|---|---|---|---|---|
| body | (0, 0, 0) | tex (16, 16) box (−4, 0, −2) size 8, 12, 4 | tex (28, 0) box (−4, 10, −2) size 8, 1, 4 | tex (16, 48) box (−4, 0, −2) size 8, 12, 4, grow 0.025 |
| head | (0, 0, 0) | tex (0, 0) box (−4, −8, −4) size 8, 8, 8 | tex (0, 32) box (−4, −8, −4) size 8, 8, 8, grow 0.2 | |
| right_arm | (−5.5, 2, 0) | tex (40, 16) box (−1, −2, −1) size 2, 12, 2 | tex (42, 33) box (−1.55, −2.025, −1.5) size 3, 12, 3 | |
| left_arm | (5.5, 2, 0) | tex (56, 16) box (−1, −2, −1) size 2, 12, 2 | tex (40, 48) box (−1.45, −2.025, −1.5) size 3, 12, 3 | |
| right_leg | (−2, 12, 0) | tex (0, 16) box (−1, 0, −1) size 2, 12, 2 | tex (0, 49) box (−1.5, 0, −1.5) size 3, 12, 3 | |
| left_leg | (2, 12, 0) | tex (0, 16) box (−1, 0, −1) size 2, 12, 2 | tex (4, 49) box (−1.5, 0, −1.5) size 3, 12, 3 | |

No part is mirrored here. The parched model class is `SkeletonModel`, so its animation is 4.7.

### 3.7 Adult piglin mesh (`AdultPiglinModel.createBodyLayer`, also zombified piglin)

Start from `PlayerModel.createMesh(grow 0, slim = false)`: the base humanoid mesh (1.2) plus the player extras: left_arm tex (32, 48)
box (−1, −2, −2) size 4, 12, 4 pivot (5, 2, 0) (not mirrored); left_leg tex (16, 48) box (−2, 0, −2) size 4, 12, 4 pivot (1.9, 12, 0);
child overlays (grow 0.25): left_sleeve tex (48, 48) and right_sleeve tex (40, 32) on the arms with the arm's box (right arm
box (−3, −2, −2)), left_pants tex (0, 48) and right_pants tex (0, 32) on the legs, jacket tex (16, 32) box (−4, 0, −2) size 8, 12, 4
on the body. Then:

- `body` is replaced by tex (16, 16) box (−4, 0, −2) size 8, 12, 4 at ZERO (replacing a part keeps its children, so the jacket
  child remains);
- `head` is replaced by the piglin head (below) at ZERO and its `hat` child is replaced by an empty one at the same pose.

Piglin head (`AbstractPiglinModel.addHead(grow)`): cuboids of `head`: tex (0, 0) box (−5, −8, −4) size 10, 8, 8; tex (31, 1) box
(−2, −4, −5) size 4, 4, 1 (snout); tex (2, 4) box (2, −2, −5) size 1, 2, 1 (right tusk); tex (2, 0) box (−3, −2, −5) size 1, 2, 1 (left
tusk). Children: `left_ear` tex (51, 6) box (0, 0, −2) size 1, 5, 4 at (4.5, −6, 0) rotation z = −0.5235988 (−π/6); `right_ear` tex (39, 6)
box (−1, 0, −2) size 1, 5, 4 at (−4.5, −6, 0) rotation z = +0.5235988. Whether the second-layer cuboids sample opaque texels is
texture data. The render type of every piglin-family model is `entityTranslucent` (2.6), the others use `entityCutout`.

Piglin armor (`AbstractPiglinModel.createArmorMeshSet`): `PlayerModel.createArmorMeshSet` (the armor set of 1.4 with empty
sleeve, pants and jacket children added) with two empty children `left_ear` and `right_ear` added to the head, so the armor model
satisfies the piglin constructor; the piglin armor head has the plain 8 x 8 x 8 humanoid head, no snout or ears.

### 3.8 Baby piglin mesh (`BabyPiglinModel.createBodyLayer`), 64 x 64

| Part | Pivot (x, y, z) | Cuboids | Notes |
|---|---|---|---|
| body | (0, 18, −0.5) | tex (0, 13) box (−3, −3, −1) size 6, 5, 3 | |
| head | (0, 15, 0) | tex (21, 30) box (−1.5, −3, −4.5) size 3, 3, 1; tex (0, 0) box (−4.5, −6, −3.5) size 9, 6, 7 | |
| hat | child of head, (0, 0, 0) | none | empty |
| left_ear | child of head, (4.2, −4, 0) | none | has child `left_ear_r1`: tex (0, 21) box (−0.5, −3, −2) size 1, 6, 4 at (1, 1.75, 0) rotation z = −0.6109 |
| right_ear | child of head, (−4.2, −4, 0) | none | child `right_ear_r1`: tex (18, 13) same box at (−1, 1.75, 0), rotation z = +0.6109 |
| left_arm | (4, 15, 0) | tex (28, 13) box (−1, 0, −1.5) size 2, 5, 3 | |
| right_arm | (−4, 15, 0) | tex (10, 30) box (−1, 0, −1.5) size 2, 5, 3 | |
| right_leg | (−1.5, 20, 0) | tex (22, 23) box (−1.5, 0, −1.5) size 3, 4, 3 | |
| left_leg | (1.5, 20, 0) | tex (10, 23) box (−1.5, 0, −1.5) size 3, 4, 3 | |

The zombified baby piglin uses this same layer (`BabyZombifiedPiglinModel.createBodyLayer` returns it).

### 3.9 Armor stand mesh (`ArmorStandModel.createBodyLayer`), 64 x 64

Start from the base humanoid mesh (1.2, grow 0) and replace or add (all unmirrored unless stated):

| Part | Pivot | Cuboid | tex (u, v) |
|---|---|---|---|
| head | (0, 1, 0) | origin (−1, −7, −1) size 2, 7, 2 | (0, 0) |
| body | (0, 0, 0) | origin (−6, 0, −1.5) size 12, 3, 3 | (0, 26) |
| right_arm | (−5, 2, 0) | origin (−2, −2, −1) size 2, 12, 2 | (24, 0) |
| left_arm | (5, 2, 0) | origin (0, −2, −1) size 2, 12, 2, mirrored | (32, 16) |
| right_leg | (−1.9, 12, 0) | origin (−1, 0, −1) size 2, 11, 2 | (8, 0) |
| left_leg | (1.9, 12, 0) | origin (−1, 0, −1) size 2, 11, 2, mirrored | (40, 16) |
| right_body_stick | (0, 0, 0) | origin (−3, 3, −1) size 2, 7, 2 | (16, 0) |
| left_body_stick | (0, 0, 0) | origin (1, 3, −1) size 2, 7, 2 | (48, 16) |
| shoulder_stick | (0, 0, 0) | origin (−4, 10, −1) size 8, 2, 2 | (0, 48) |
| base_plate | (0, 12, 0) | origin (−6, 11, −6) size 12, 1, 12 | (0, 32) |

The replaced `head` keeps its `hat` child (the base hat cuboid), which the model hides at construction (`hat.visible = false`
for the stand's own model; the armor model does not hide it, so a helmet draws its hat cuboid). The plate lies at world height
(12 + 11)/16 to (12 + 12)/16 above the model origin, i.e. y 23 to 24 in model units, the sole line.

Armor-stand armor (`ArmorStandArmorModel.createArmorLayerSet(inner, outer)`): the sets of 1.4 built from a different base mesh:
the base humanoid mesh (1.2) with `head` replaced by tex (0, 0) box (−4, −8, −4) size 8, 8, 8 (grow g) at (0, 1, 0) with hat tex (32, 0)
box (−4, −8, −4) size 8, 8, 8 grow g + 0.5 as child, and `right_leg` tex (0, 16) / `left_leg` tex (0, 16) mirrored, box (−2, 0, −2)
size 4, 12, 4, grow g − 0.1, pivots (∓1.9, 11, 0). Constants of the call: inner 0.5, outer 1.0.

---

## 4. Animation (`setupAnim`)

### 4.1 Base order (`HumanoidModel.setupAnim`)

Notation: R = right arm, L = left arm, state fields are in 7. 12 §7.5 gives the player's use of the same function; the steps and
constants below were re-read for this document and agree with it, and add the swim and ordering rules.

1. `resetPose` (every part to its initial pose).
2. head.xRot = state.xRot × 0.017453292; head.yRot = state.yRot × 0.017453292. If `isFallFlying`, head.xRot = −0.7853982
   (only the head is set; the rest continues).
3. With wp = walkAnimationPos, ws = walkAnimationSpeed, sv = speedValue:
   R.xRot = cos(wp × 0.6662 + π) × 2 × ws × 0.5 / sv; L.xRot = cos(wp × 0.6662) × 2 × ws × 0.5 / sv;
   rightLeg.xRot = cos(wp × 0.6662) × 1.4 × ws / sv; leftLeg.xRot = cos(wp × 0.6662 + π) × 1.4 × ws / sv;
   rightLeg.yRot = 0.005, leftLeg.yRot = −0.005, rightLeg.zRot = 0.005, leftLeg.zRot = −0.005.
4. If `isPassenger`: both arms xRot += −0.62831855; rightLeg xRot = −1.4137167, yRot = 0.31415927, zRot = 0.07853982; leftLeg xRot =
   −1.4137167, yRot = −0.31415927, zRot = −0.07853982.
5. Arm poses (4.2).
6. `setupAttackAnimation` (4.4, replaced by the zombie and piglin variants).
7. If `isCrouching`: body.xRot = 0.5; both arms xRot += 0.4; both legs z += 4; head.y += 4.2; body.y += 3.2; both arms y += 3.2.
8. Arm bob (unless that arm's pose is SPYGLASS): R.zRot += cos(ageInTicks × 0.09) × 0.05 + 0.05; R.xRot += sin(ageInTicks × 0.067) ×
   0.05; L.zRot −= the same zRot term and L.xRot −= the same xRot term (`AnimationUtils.bobModelPart(part, age, sign)`, sign +1 for
   R, −1 for L).
9. If `swimAmount` > 0: swim animation (4.5; the drowned replaces it, 4.6).

### 4.2 Arm poses (selection and ordering)

For these mobs the arm pose comes from the renderer (`HumanoidMobRenderer.getArmPose`): SPEAR when the hand's stack is a spear item
(tag `spears`) or the entity is mid-swing of the stab type with that hand (12 §7.5 lists the effect as an open question here too),
else EMPTY; skeletons return BOW_AND_ARROW for the main arm when aggressive and the main-hand stack is a bow; the drowned returns
THROW_TRIDENT for the main arm when aggressive and holding a trident. The piglin crossbow and weapon poses are not arm poses; they
are in 4.9.

Flags per pose (constructor argument pairs `(twoHanded, affectsOffhandPose)`): EMPTY (no, no), ITEM (no, no), BLOCK (no, no),
BOW_AND_ARROW (yes, yes), THROW_TRIDENT (no, yes), CROSSBOW_CHARGE (yes, yes), CROSSBOW_HOLD (yes, yes), SPYGLASS, TOOT_HORN, BRUSH, SPEAR
(all no, no).

Order: let A = (isUsingItem ? the arm of `useItemHand` : the opposite of the main arm); if pose(A) is twoHanded, A = the main arm.
Pose arm A first; then pose the other arm unless pose(A).affectsOffhandPose. Because a bow or crossbow pose sets both arms in one
call, the other arm's pose is not applied after it.

Arm pose effects (head = the head part after step 2; the left arm mirrors the sign where marked): EMPTY: yRot = 0. ITEM: xRot = xRot × 0.5
− 0.31415927; yRot = 0. BOW_AND_ARROW (right-handed): R.yRot = −0.1 + head.yRot, L.yRot = 0.1 + head.yRot + 0.4, both xRot = −1.5707964
+ head.xRot (left-handed: L.yRot = 0.1 + head.yRot, R.yRot = −0.1 + head.yRot − 0.4, both xRot the same). THROW_TRIDENT: xRot = xRot × 0.5 −
3.1415927; yRot = 0. CROSSBOW_CHARGE and CROSSBOW_HOLD, SPYGLASS, TOOT_HORN, BRUSH, BLOCK: as 12 §7.5 (the CROSSBOW pair, which the piglin
also uses, is in 4.9). SPEAR: `SpearAnimations.thirdPersonHandUse` (34 part 1 section 3.8); `animateZombieArms` returns without
changing anything when either arm is SPEAR.

### 4.3 Zombie arms (`AnimationUtils.animateZombieArms(left, right, aggressive, state)`; zombie, husk, drowned, giant, zombified piglin)

Called after the base attack animation, with `swing` = `state.swingAnimation` (0 to 1) and `agg` = the state's aggressive flag.

1. If either arm pose is SPEAR: do nothing.
2. raised = (not baby) or (the main-hand stack is empty).
3. base = raised ? −π / (agg ? 1.5 : 2.25) : 0, i.e. −2.0943952 aggressive, −1.3962634 not aggressive, 0 not raised.
4. a = (raised ? +1 : −1) × sin(swing × π); b = sin((1 − (1 − swing)²) × π).
5. x = base + a × 1.2 − b × 0.4; y = 0.1 − a × 0.6.
6. Right arm (skipped when its pose is THROW_TRIDENT): xRot = x; yRot = raised ? −y : +y; zRot = 0. Left arm (skipped when THROW_TRIDENT): xRot
   = x; yRot = raised ? +y : −y; zRot = 0.

The base attack animation (4.4) has already run, so the arm pivots it moved stay moved. The arm bob of 4.1 step 8 is added afterwards.

**Drowned attack animation**: `DrownedModel.setupAttackAnimation` calls the zombie version (base swing 4.4, then this section) and then calls the zombie-arms routine a second time with the same arguments (left arm, right arm, `isAggressive`, state). The second call assigns the same values as the first, so the arms are animated once in effect and the result equals the zombie's.

### 4.4 Base swing (`HumanoidModel.setupAttackAnimation`)

Applies only when `swingAnimation` > 0 and a current swing exists. p = swingAnimation; swingArm = the swinging hand's arm.
body.yRot = sin(sqrt(p) × 2π) × 0.2, negated when swingArm is the left arm. With ageScale k (state.ageScale): R.z = sin(body.yRot) × 5k;
R.x = −cos(body.yRot) × 5k; L.z = −sin(body.yRot) × 5k; L.x = cos(body.yRot) × 5k (assigned, replacing the pivot values); R.yRot += body.yRot;
L.yRot += body.yRot; L.xRot += body.yRot. If the swing animation type is `whack`: u = sin(easeOutQuart(p) × π); v = sin(p × π) × −(head.xRot −
0.7) × 0.75; the swinging arm: xRot −= u × 1.2 + v; yRot += body.yRot × 2; zRot += sin(p × π) × −0.4. If the type is `stab`: `SpearAnimations.
thirdPersonAttackHand` (not read, Open question 1). Other types: nothing further. Zombies, piglins and skeletons override this function
(4.3, 4.7, 4.9) but call it first.

### 4.5 Swim (`HumanoidModel.setupSwimAnimation`, swim amount s = `swimAmount` > 0, wp = walk position)

1. Unless the state field `isFallFlying` is set (not ordinary falling): head.xRot = rotLerpRad(s, head.xRot, −0.7853982). (`rotLerpRad(t, a, b)` = a + t × d, d = b − a wrapped to
   [−π, π).)
2. t = wp mod 26. Swing arm = the hand of the current swing as an arm, if any. For the right arm, sr = 0 when the right pose is SPEAR or the swing arm is
   the right, else s; for the left arm, sl = 0 when the left pose is SPEAR or the swing arm is the left, else s. Skip steps 3 to 5 when
   `isUsingItem`.
3. Let q(x) = −65x + x². t < 14: L.xRot = rotLerpRad(sl, L.xRot, 0); R.xRot = lerp(sr, R.xRot, 0); both yRot toward π (L with rotLerpRad, R with lerp);
   L.zRot = rotLerpRad(sl, L.zRot, π + 1.8707964 × q(t) / q(14)); R.zRot = lerp(sr, R.zRot, π − 1.8707964 × q(t) / q(14)).
4. 14 ≤ t < 22: u = (t − 14) / 8; both xRot toward 1.5707964 × u; yRot toward π; L.zRot toward 5.012389 − 1.8707964 u; R.zRot toward 1.2707963 +
   1.8707964 u.
5. 22 ≤ t < 26: u = (t − 22) / 4; both xRot toward 1.5707964 − 1.5707964 u; both yRot and zRot toward π.
6. Always: leftLeg.xRot = lerp(s, leftLeg.xRot, 0.3 × cos(wp × 0.33333334 + π)); rightLeg.xRot = lerp(s, rightLeg.xRot, 0.3 × cos(wp × 0.33333334)).

### 4.6 Drowned swim (`DrownedModel.setupSwimAnimation(state, wp, s)`, replaces 4.5)

R.xRot = rotLerpRad(s, R.xRot, −2.5132742) + s × 0.35 × sin(0.1 × ageInTicks); L.xRot = rotLerpRad(s, L.xRot, −2.5132742) − s × 0.35 ×
sin(0.1 × ageInTicks); R.zRot = rotLerpRad(s, R.zRot, −0.15); L.zRot = rotLerpRad(s, L.zRot, 0.15); leftLeg.xRot −= s × 0.55 × sin(0.1 ×
ageInTicks); rightLeg.xRot += s × 0.55 × sin(0.1 × ageInTicks); head.xRot = 0. (−2.5132742 = −0.8π.)

### 4.7 Skeleton (`SkeletonModel.setupAnim`)

Base animation (4.1) first. Then when `isAggressive` and not `isHoldingBow`: a = sin(swing × π); b = sin((1 − (1 − swing)²) × π); both zRot = 0;
R.yRot = −(0.1 − a × 0.6); L.yRot = 0.1 − a × 0.6; both xRot = −1.5707964; then both xRot −= (a × 1.2 − b × 0.4); then both arms are
bobbed (`bobArms`: the same zRot and xRot adds as 4.1 step 8). The bogged adds only the mushroom
visibility. The clothing layer is a second `SkeletonModel` baked from the outer layer, animated by the same `setupAnim(state)`.

### 4.8 Skeleton `translateToHand(arm)`

The root's transform, then the arm part moved by x += (right arm ? +1 : −1), its transform applied, then the pivot restored (the 2-wide arm sits one pixel
outward for held items; the base humanoid `translateToHand` is the root transform then the arm transform, with no shift).

### 4.9 Piglin (`AbstractPiglinModel.setupAnim`, `PiglinModel.setupAnim`, `setupAttackAnimation`)

Ears (every piglin-family model): base = defaultEar × 0.017453292 where defaultEar = 30 degrees for the adult piglin and zombified piglin and
5 degrees for the baby piglin and baby zombified piglin; t = ageInTicks × 0.1 + wp × 0.5; amp = 0.08 + ws × 0.4; leftEar.zRot = −base −
cos(t × 1.2) × amp; rightEar.zRot = base + cos(t) × amp. (The baby ears are the parent parts `left_ear` and `right_ear`; their children carry the
fixed tilt.)

`PiglinModel` (piglin, brute, and baby), after the above, by the state's `armPose`:

| armPose | Effect |
|---|---|
| DANCING | u = ageInTicks / 60. rightEar.zRot = 0.5235988 + 0.017453292 × sin(u × 30) × 10; leftEar.zRot = −0.5235988 − 0.017453292 × cos(u × 30) × 10; head.x += sin(u × 10); head.y += sin(u × 40) + 0.4; R.zRot = 0.017453292 × (70 + cos(u × 40) × 10); L.zRot = −R.zRot; R.y += sin(u × 40) × 0.5 − 0.5; L.y += sin(u × 40) × 0.5 + 0.5; body.y += sin(u × 40) × 0.35 |
| ATTACKING_WITH_MELEE_WEAPON, `swingAnimation` = 0 | the main-hand arm xRot = −1.8 (left arm when the main arm is left, else right) |
| CROSSBOW_HOLD | `animateCrossbowHold(R, L, head, mainArm == right)` (12 §7.5 gives the formula) |
| CROSSBOW_CHARGE | `animateCrossbowCharge(R, L, maxCrossbowChageDuration, ticksUsingItem, mainArm == right)` (12 §7.5) |
| ADMIRING_ITEM | head.xRot = 0.5; head.yRot = 0; if the main arm is left: R.yRot = −0.5, R.xRot = −0.9; else L.yRot = 0.5, L.xRot = −0.9 |
| DEFAULT | none |

`PiglinModel.setupAttackAnimation`: when `swingAnimation` > 0 and armPose is ATTACKING_WITH_MELEE_WEAPON: `AnimationUtils.swingWeaponDown(R, L, mainArm,
swing, ageInTicks)`; otherwise the base swing (4.4) (the weapon-down animation then replaces the body twist).

`swingWeaponDown(R, L, mainArm, swing, age)`: a = sin(swing × π); b = sin((1 − (1 − swing)²) × π); both zRot = 0; R.yRot = 0.15707964; L.yRot =
−0.15707964. Main arm right: R.xRot = −1.8849558 + cos(age × 0.09) × 0.15; L.xRot = cos(age × 0.19) × 0.5; then R.xRot += a × 2.2 − b × 0.4; L.xRot += a ×
1.2 − b × 0.4. Main arm left: the same with the arms swapped (L gets −1.8849558 + cos(age × 0.09) × 0.15 and the 2.2 term; R gets cos(age × 0.19) ×
0.5 and the 1.2 term). Then both arms bobbed (4.1 step 8 terms).

`ZombifiedPiglinModel.setupAttackAnimation`: the base swing (4.4), then `animateZombieArms(L, R, isAggressive, state)` (4.3). It has no `armPose` handling.

### 4.10 Armor stand (`ArmorStandArmorModel.setupAnim`, `ArmorStandModel.setupAnim`)

The base animation (4.1) runs first and is then overwritten: for head, body, left arm, right arm, left leg and right leg, `xRot`, `yRot`, `zRot`
= the matching state `Rotations` (x, y, z in degrees) × 0.017453292 (only the three angles are assigned; pivots are not changed). The stand's own model
then additionally: base_plate.yRot = 0.017453292 × −state.yRot; both arms' `visible` = `showArms`; base_plate.visible = `showBasePlate`; the three
sticks (`right_body_stick`, `left_body_stick`, `shoulder_stick`) copy the body rotations (x, y, z of `bodyPose` × 0.017453292). `translateToHand(arm)`
forces the arm visible for the call, applies the humanoid transform and restores the flag. Default poses (degrees, `ArmorStand.DEFAULT_*_POSE`): head (0, 0,
0), body (0, 0, 0), left arm (−10, 0, −10), right arm (−15, 0, 10), left leg (−1, 0, −1), right leg (1, 0, 1).

---

## 5. Renderers

### 5.1 `HumanoidMobRenderer` (base of zombie, skeleton, piglin families)

Constructor `(context, adultModel, babyModel, shadowRadius, headTransforms)`; `AgeableMobRenderer.submit` selects the baby model when `isBaby` else the adult
model. Layers added in the constructor, in order: `CustomHeadLayer`, `WingsLayer`, `ItemInHandLayer`; each subclass then appends its own. Extraction:
`extractHumanoidRenderState` (7), then `leftArmPose` and `rightArmPose` from `getArmPose` (4.2).

### 5.2 Table of renderers

| Entity | Renderer | Adult model layer | Baby model layer | Shadow radius | Extra layers after Armor | Texture (adult / baby) |
|---|---|---|---|---|---|---|
| zombie | `ZombieRenderer` | ZOMBIE | ZOMBIE_BABY | 0.5 | none | `textures/entity/zombie/zombie.png` / `zombie_baby.png` |
| husk | `HuskRenderer` (a `ZombieRenderer`) | HUSK | HUSK_BABY | 0.5 | none | `.../zombie/husk.png` / `husk_baby.png` |
| drowned | `DrownedRenderer` (`AbstractZombieRenderer`) | DROWNED | DROWNED_BABY | 0.5 | `DrownedOuterLayer` | `.../zombie/drowned.png` / `drowned_baby.png` |
| giant | `GiantMobRenderer(context, 6.0)` | GIANT | (none) | 0.5 × 6.0 = 3.0 | none | `.../zombie/zombie.png` |
| skeleton | `SkeletonRenderer` | SKELETON | same | 0.5 | none | `textures/entity/skeleton/skeleton.png` |
| stray | `StrayRenderer` | STRAY | same | 0.5 | `SkeletonClothingLayer` (STRAY_OUTER_LAYER) | `.../skeleton/stray.png`, clothes `stray_overlay.png` |
| bogged | `BoggedRenderer` | BOGGED (`BoggedModel`) | same | 0.5 | `SkeletonClothingLayer` (BOGGED_OUTER_LAYER) | `.../skeleton/bogged.png`, clothes `bogged_overlay.png` |
| wither skeleton | `WitherSkeletonRenderer` | WITHER_SKELETON | same | 0.5 | none | `.../skeleton/wither_skeleton.png` |
| parched | `ParchedRenderer` | PARCHED | same | 0.5 | none | `.../skeleton/parched.png` |
| piglin | `PiglinRenderer` | PIGLIN | PIGLIN_BABY | 0.5 | none | `textures/entity/piglin/piglin.png` / `piglin_baby.png` |
| piglin brute | `PiglinRenderer` (brute layers) | PIGLIN_BRUTE | PIGLIN_BRUTE | 0.5 | none | `.../piglin/piglin_brute.png` |
| zombified piglin | `ZombifiedPiglinRenderer` | ZOMBIFIED_PIGLIN | ZOMBIFIED_PIGLIN_BABY | 0.5 | none | `.../piglin/zombified_piglin.png` / `zombified_piglin_baby.png` |
| armor stand | `ArmorStandRenderer` | ARMOR_STAND | ARMOR_STAND_SMALL | 0 | none (layers order below) | `textures/entity/armorstand/armorstand.png` |

Piglin texture choice: brute (state `isBrute`) first, else baby, else adult. Zombie, husk, drowned, zombified piglin: baby flag decides. The skeleton family has one
texture per renderer. The shadow radius is then scaled as in 2.1. The renderers are registered by entity type: `armor_stand`, `bogged`, `drowned`, `giant`, `husk`,
`parched`, `piglin`, `piglin_brute`, `skeleton`, `stray`, `wither_skeleton`, `zombie`, `zombified_piglin` each to the renderer of this table (`EntityRenderers`).

Layer order. Zombie family and skeleton family and piglin family: custom head, wings, item in hand, armor, then the extra layer of the table (outer or clothing layer).
Giant (a `MobRenderer`, no head or wings layers): item in hand, armor. Armor stand (a `LivingEntityRenderer`): armor, item in hand, wings, custom head.

### 5.3 `AbstractZombieRenderer`

Adds `HumanoidArmorLayer(ZOMBIE-family armor set, baby set)`. `extractRenderState` additionally sets `isAggressive` (the zombie's aggressive flag) and `isConverting` (the zombie is
converting under water to a drowned). `isShaking` = base or `isConverting`. Texture by `isBaby` (5.2). **Drowned**: `getArmPose` returns THROW_TRIDENT for the main arm when the
drowned is aggressive and holds a trident; `setupRotations` as 2.2; `DrownedOuterLayer` (below). **Giant**: `extractRenderState` fills only the humanoid state (no aggressive flag, so
`isAggressive` stays false: the giant's raised arms use −π/2.25); its model is the GIANT layer already scaled by 6.

`DrownedOuterLayer` and `SkeletonClothingLayer` (`RenderLayer.coloredCutoutModelCopyLayerRender`): a second model baked from the outer layer (DROWNED_OUTER_LAYER or the baby
variant by `isBaby`; STRAY, BOGGED or PARCHED outer layer), posed by the same `setupAnim(state)`, drawn with render type `entityCutout` of the layer texture
(`textures/entity/zombie/drowned_outer_layer.png` or `drowned_outer_layer_baby.png`; the clothes texture of the table), color −1, overlay value `getOverlayCoords(state, 0)`, and
not drawn when the entity is invisible. The clothes models are the base humanoid mesh with grow 0.25 (bogged 0.2), hence 4-wide limbs and a hat grown by 0.75 (bogged 0.7), unlike the
2-wide skeleton limbs; the stray, bogged and parched clothing textures are 64 x 32 images (parched's second layer is inside its own 64 x 64 model, and its clothing layer
exists in the definitions with grow 0.25 but the parched renderer does not add a clothing layer).

### 5.4 `AbstractSkeletonRenderer`

Adds the armor layer for the skeleton family, shadow 0.5. `extractRenderState`: `isAggressive` (the mob's aggressive flag), `isShaking` (the skeleton's shaking flag, the freezing conversion of a stray), `isHoldingBow`
(the main-hand stack is a bow). Arm pose BOW_AND_ARROW per 4.2.

### 5.5 `PiglinRenderer` and `ZombifiedPiglinRenderer`

`PiglinRenderer` (constructor: adult, baby, adult armor set, baby armor set; head transform 1.0019531 in x and z): `extractRenderState` sets `isBrute` (the entity type is the brute),
`armPose` (6), `maxCrossbowChageDuration` (the use item's crossbow charge duration), `isConverting`; `isShaking` = base or `isConverting`. The armor layer uses the piglin armor sets
(1.4 piglin constants). `ZombifiedPiglinRenderer` extracts `isAggressive` only and uses the same head transform.

### 5.6 `ArmorStandRenderer`

`LivingEntityRenderer(context, model ARMOR_STAND, shadowRadius 0)`; `submit` selects the small model when `isSmall`. Extraction: `yRot` = lerp(partial, previous, current stand yaw) (this is
the value `base_plate` counter-rotates by), `isMarker`, `isSmall`, `showArms`, `showBasePlate`, the six `Rotations`, `wiggle` = gameTime − lastHit + partial. Entity flags (the client-flags byte
`DATA_CLIENT_FLAGS`): bit 1 small, bit 4 show arms, bit 8 no base plate (so `showBasePlate` = bit 8 clear), bit 16 marker; `isBaby` of a stand = `isSmall`. `getTextureLocation`: the one
texture above. `shouldShowName`: only when the custom name is visible. Render type: a marker stand uses `entityTranslucent` (ghost) or `entityCutout` (visible) of the texture, or nothing; a
normal stand uses the base rule (2.1). `setupRotations` per 2.2. For armor on a stand the baby layer type is not used (1.5 step 2) and the held item uses the adult offsets (1.6), even for a small
stand; the small stand's `isBaby` still selects its baby armor set (the small armor set, 3).

---

## 6. State values (what the server-side entity supplies)

`extractHumanoidRenderState` (all of the scope): `isCrouching`, `isFallFlying`, `isVisuallySwimming`, `isPassenger` from the entity; `speedValue` = 1, but when fall flying: v = |velocity|² / 0.2, then v = v × (v × v) (the cube), and then v = 1 when v < 1; `swimAmount` = the entity's
swim amount at the partial tick; `useItemHand`, `ticksUsingItem` (at the partial tick), `isUsingItem`, `maxCrossbowChargeDuration` (the use item's charge duration); the elytra rotation triple; the four
equipment stacks (copies when renderable, else empty). Armed state: `mainArm`, `currentSwing`, `swingAnimation` (progress at the partial tick), the item render states and stacks of both hands (display contexts
third person right and left hand).

`PiglinArmPose` (`Piglin.getArmPose`, an enum of six values in this order: ATTACKING_WITH_MELEE_WEAPON, CROSSBOW_HOLD, CROSSBOW_CHARGE, ADMIRING_ITEM, DANCING, DEFAULT), evaluated in this
order: dancing flag → DANCING; off-hand stack is a loved item → ADMIRING_ITEM; aggressive and holding a melee weapon → ATTACKING_WITH_MELEE_WEAPON; charging flag → CROSSBOW_CHARGE; holding a
crossbow that is charged → CROSSBOW_HOLD; else DEFAULT. The piglin brute: aggressive and holding a melee weapon → ATTACKING_WITH_MELEE_WEAPON, else DEFAULT. (The entity's metadata and the loved-item
test are in 19 to 21 and 45.)

---

## 7. Render state fields

| State | Fields (all public) | Defaults |
|---|---|---|
| `HumanoidRenderState` (extends armed state) | `swimAmount`, `speedValue`, `maxCrossbowChargeDuration`, `ticksUsingItem`, `useItemHand`, `isCrouching`, `isFallFlying`, `isVisuallySwimming`, `isPassenger`, `isUsingItem`, `elytraRotX/Y/Z`, `headEquipment`, `chestEquipment`, `legsEquipment`, `feetEquipment` | `speedValue` 1; `useItemHand` main hand; stacks empty |
| armed state | `mainArm`, `rightArmPose`, `leftArmPose`, `rightHandItemState`, `rightHandItemStack`, `leftHandItemState`, `leftHandItemStack`, `currentSwing`, `swingAnimation` | main arm right; poses EMPTY |
| `UndeadRenderState` | none; `getUseItemStackForArm` returns the main-hand stack | |
| `ZombieRenderState` | `isAggressive`, `isConverting` | false |
| `SkeletonRenderState` | `isAggressive`, `isShaking`, `isHoldingBow` | false |
| `BoggedRenderState` | `isSheared` | false |
| `ZombifiedPiglinRenderState` | `isAggressive` | false |
| `PiglinRenderState` | `isBrute`, `isConverting`, `maxCrossbowChageDuration`, `armPose` | false; DEFAULT |
| `ArmorStandRenderState` | `yRot`, `wiggle`, `isMarker`, `isSmall`, `showArms`, `showBasePlate`, `headPose`, `bodyPose`, `leftArmPose`, `rightArmPose`, `leftLegPose`, `rightLegPose` | |

`HumanoidRenderState.ticksUsingItem(arm)` returns `ticksUsingItem` only when the entity is using an item with the hand that maps to that arm, else 0; the armed state returns 0.

---

## 8. Worked examples

All numbers are computed from the formulas above (double arithmetic, rounded); tolerate 1e-5.

1. **Standing zombie, age 0, not walking, not aggressive, no swing**: arms raised: base = −1.3962634 (= −π/2.25); a = b = 0 so x = −1.3962634, y = 0.1: R.xRot = −1.3962634, R.yRot = −0.1,
   L.yRot = +0.1, zRot = 0; then the bob adds R.zRot = +0.05, L.zRot = −0.05, R.xRot += 0, L.xRot −= 0 (age 0). Final R = (−1.3962634, −0.1, 0.05), L = (−1.3962634, 0.1, −0.05).
2. **The same zombie at the middle of a swing (p = 0.5), age 100**: a = sin(0.5π) = 1; b = sin(0.75π) = 0.7071068; x = −1.3962634 + 1.2 − 0.2828427 = −0.4791061; y = 0.1 − 0.6 = −0.5, so
   R.yRot = +0.5, L.yRot = −0.5 (before the bob). Body yaw (swinging right): sin(sqrt(0.5) × 2π) × 0.2 = −0.1927805; R pivot z = sin(−0.1927805) × 5 = −0.9579432, R pivot x = −cos(−0.1927805) × 5 =
   −4.9073766 (the pivot x of a baby zombie's arm is computed with ageScale 0.5 and so becomes −2.4536883 instead of the rest value −3). Bob at age 100: R.zRot += cos(9) × 0.05 + 0.05 = 0.0044435,
   R.xRot += sin(6.7) × 0.05 = 0.0202425 (and L subtracts both).
3. **Aggressive zombie, no swing**: base = −π / 1.5 = −2.0943952; arms point higher (R.xRot = −2.0943952 before the bob).
4. **Baby zombie holding an item, swing 0**: raised = false, so base = 0, a = −sin(0) = 0, x = 0, y = 0.1; right yRot = +0.1 and left yRot = −0.1 (the sign is reversed relative to example 1); the arms hang.
5. **Skeleton aggressive without a bow, swing 0.5**: a = 1, b = 0.7071068; both xRot = −1.5707964 − (1.2 − 0.2828427) = −2.4879536; R.yRot = −(0.1 − 0.6) = +0.5; L.yRot = −0.5.
6. **Piglin ears at age 40, not walking** (adult): base = 0.5235988; t = 4; amp = 0.08; leftEar.zRot = −0.5235988 − cos(4.8) × 0.08 = −0.5305987; rightEar.zRot = 0.5235988 + cos(4) × 0.08 = 0.4713073.
7. **Piglin melee swing**, right-handed, swing 0.5, age 0: a = 1, b = 0.7071068; R.xRot = −1.8849558 + 0.15 + (2.2 − 0.2828427) = 0.1822015; L.xRot = 0.5 + (1.2 − 0.2828427) = 1.4171573.
8. **Scaling constants**: giant (s = 6): every root-child pivot becomes 6 × pivot + (0, −120.08, 0); the head pivot (0, 0, 0) becomes (0, −120.08, 0) with scale 6, so the head top is at 6 × (−8) − 120.08 = −168.08;
   the leg pivot y = 12 becomes 72 − 120.08 = −48.08 and the leg bottom is at −48.08 + 72 = 23.92. Husk (s = 1.0625): head pivot (0, −1.501, 0), leg pivot 12.75 − 1.501 = 11.249, foot line 11.249 + 12.75 = 23.999.
   Wither skeleton (s = 1.2): head pivot (0, −4.8032, 0), leg pivot 14.4 − 4.8032 = 9.5968, foot line 9.5968 + 14.4 = 23.9968.
9. **Small armor stand**: baby transform: head pivot (0, 1, 0) becomes (0, (1 + 16) × 0.75, 0) = (0, 12.75, 0) scale 0.75, so the head spans 12.75 − 7 × 0.75 = 7.5 to 12.75; body (0, 0, 0) becomes (0, 12, 0)
   scale 0.5; arms (±5, 2, 0) become (±2.5, 13, 0); legs (±1.9, 12, 0) become (±0.95, 18, 0), so the leg bottom is at 18 + 11 × 0.5 = 23.5; base plate pivot (0, 12, 0) becomes (0, 18, 0), the plate spans y
   18 + 11 × 0.5 = 23.5 to 24 (plate cuboid y 11 to 12, scaled 0.5).
10. **Armor on an adult zombie (full diamond-like set)**: helmet and chestplate grow 1.0, leggings body grow 0.5 and leg cuboids 0.4, boots leg cuboids 0.9; the draw order is chest, legs, feet, head; each piece
    uses texture `textures/entity/equipment/humanoid/<asset>.png` (chest, feet, head) or `humanoid_leggings/<asset>.png` (legs) for each layer of the asset.
11. **Ghost draw**: an invisible zombie seen by a spectator whose own body is visible to him: the whole model is drawn with render type `entityTranslucentCull` and tint 0x26FFFFFF; the armor still draws.

---

## 9. Validation

A reimplementer can check these without a reference client:

1. The mesh of every model in 3 has its feet line at y = 24 (leg pivot + leg box height: 12 + 12 humanoid, 12 + 12 skeleton, 20 + 4 baby zombie and baby piglin), except the armor stand: its own legs (pivot 12, height 11) and its armor legs (pivot 11, height 12) end at 23, and only the base plate (y 11 to 12 below pivot 12) reaches the 24 line (3.9). Wither skeleton: 23.9968,
   husk: 23.999, giant: 23.92 (1.3 formula 24.016 − 0.016 s).
2. Model height from head top to feet line before grow: zombie, drowned, skeleton, stray, bogged, adult piglin 32 px (head top −8, feet 24); baby zombie 15 px (head top 9, feet 24); parched 32 px.
3. UV rectangles: for any box of size (w, h, d) at (u, v) the unfolded rectangle spans 2d + 2w by d + h inside the declared texture size (14 §5.3): zombie body 16 + 16 = 32 wide from u = 16 (to 48) and 16 tall from v = 16
   (to 32); baby zombie head cuboid 1: tex (3, 3) size 6, 6, 6 spans u 3 to 27, v 3 to 15; the baby piglin snout cuboid (21, 30) size 3, 3, 1 spans u 21 to 29, v 30 to 34.
4. Cuboid counts: zombie 7 (head, hat, body, 4 limbs); skeleton 7; bogged 7 plus 6 planes; parched 13 (body 3, head 2, four limbs 2 each); adult piglin 4 (head) + 2 (ears) + body, 4 limbs, jacket,
   4 sleeve and pants overlays = 16; baby piglin 2 (head) + 2 (ear boxes) + body, 4 limbs = 9; armor stand 10 plus the hidden hat.
5. Animation sanity: at age 0, walk speed 0, swing 0, every humanoid in this document stands with legs zRot = ±0.005 and yRot = ±0.005 (step 3), arms from 4.3, the skeleton arms from 4.1 steps 3 and 8 only
   (R.zRot = 0.05, L.zRot = −0.05, xRot 0).
6. A zombie and a zombified piglin with the same state produce the same arm angles for the same animation inputs (they share 4.3 and 4.4).
7. A small armor stand has head scale 0.75 and every other part scale 0.5.
8. Layer order and armor order (chest, legs, feet, head) are testable by drawing sequence.

---

## Open questions

1. (Resolved.) `SpearAnimations` and the `SPEAR` arm pose are documented in 34 part 1 section 3.8 and section 8.3; nothing here remains unread for them. 12 §7.5 Open question 6 is covered by the same sections.
2. The per-type skull and head-block meshes that `CustomHeadLayer` draws on these mobs (`SKELETON_SKULL`, `WITHER_SKELETON_SKULL`, `ZOMBIE_HEAD`, `PIGLIN_HEAD` with `PiglinHeadModel`) and `SkullBlockRenderer`'s render types were not read. Searched: the docs of 34 parts 1 and 7 and 47 (only the wither skull `SkullModel` and the default player skull texture appear).
3. The equipment asset schema (`EquipmentClientInfo`, layer lists, dyeable defaults, `trim_overrides`) is data; its loader is in the extraction and resource-pack rounds, and `EquipmentLayerRenderer`'s palette handling
   (`PalettedTextureManager`) was read only for the identifier rules of 1.5; the recoloring algorithm itself is 14 §7.4.
4. The entity-side producers of `isAggressive`, `isShaking`, `isConverting`, `isSheared`, `isDancing`, the charging-crossbow flag and the loved-item test are documented (or not) in 19 to 21 and 45; this document names the
   state fields only.
5. `speedValue` for a fall-flying humanoid (6) is read as the cube of (|velocity|² / 0.2) floored at 1; it affects only elytra gliding and has no worked example in this document (the formula itself was read from `HumanoidMobRenderer.extractHumanoidRenderState`: v = |velocity|² / 0.2, v = v × (v × v), v = 1 when v < 1, with no other case).
6. Texture contents: whether the second-layer UV regions of `piglin.png`, `zombified_piglin.png` and the zombie textures hold opaque pixels (jacket, sleeve and pants overlays of the piglin; hat overlay of the zombie family)
   is texture data and was not read.
7. The `PlayerModel.createMesh` slim branch (not used by any mob here) was not described; `PlayerModel` ears and cloak parts were not read. 12 §7.4 covers the player.
8. Name tags (`extractNameTags`, `shouldShowName` conditions) and the shadow rendering itself (shape, alpha) are in the framework part and were not repeated; only the shadow radius is given here.
9. The `ModelPart.Cube` face winding, normals and the mirror flag's exact vertex swap were read only to confirm that mirroring swaps the x extent of the cuboid; the pixel-exact orientation check against a reference render
   remains 14 Open question 4.
10. Scale attribute values of these mobs (for example a husk or giant with a `scale` attribute other than 1) enter through `state.scale`, which multiplies the whole model in 2.1 step 2; their sources are in 18 to 21.
