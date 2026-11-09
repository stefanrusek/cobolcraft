# 34 Entity models and renderers, part 3: villagers, illagers, golems and miscellaneous mobs

| Item | Value |
|---|---|
| Covers | Round RS17 (GAP-25), part 3. Models, animations, renderers and render layers of: villager, baby villager, wandering trader, zombie villager (and baby), witch, pillager, vindicator, evoker, illusioner, evoker fangs, ravager, vex, iron golem, snow golem, copper golem (entity and statue block), creaking, allay. Item-in-hand and arm-pose rules for these entities. Siblings (not repeated here): the other parts of this round (documents `34-entity-models-1`, `-2`, `-4` to `-9`); the shared framework (renderer base classes, humanoid model, layer registry, keyframe engine) is specified there (34-1) and in 12 §7. Cross-references use the form `NN §x.y` (`§x.y` alone is this document) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `net.minecraft.client.model.*` (`npc`, `monster.*`, `animal.golem`, `animal.allay`, `effects`, `object.statue`, `geom.*`), `net.minecraft.client.animation.*`, `net.minecraft.client.renderer.entity.*` (renderers, `layers`, `state`), and the entity classes only where a renderer reads a value from them (`AbstractIllager`, `SpellcasterIllager`, `EvokerFangs`, `Crackiness`, `CopperGolemOxidationLevels`, `AnimationState`) |
| Scope rule | Standard Minecraft content is the target (CC-0001 decisions). Textures (the PNG images and their `.mcmeta` files) are data extracted by the tool of 22 and are not tabulated; this document gives the texture paths the code asks for, the engines that interpret them, and every geometry, animation and layer constant, which is code |
| Evidence rule | Every number below was read from the artifact in this round. Items marked "(inferred)" were deduced; items marked "(recalled, not verified)" were not read. All are listed in Open questions |

Notation. Angles are radians unless a "deg" is written. Model lengths are pixels (1/16 block). `D` = 0.017453292 (the float constant the code uses for degrees to radians). `pi` = 3.1415927. Cuboids are written `origin (ox, oy, oz) size (w, h, d)`, texture offset `tex (u, v)`; "grow g" enlarges every face of the cuboid by g pixels without changing the texture unwrap (the unwrap uses the ungrown w, h, d); "mirror" marks a cuboid built with the mirror flag. Model space has x to the model's left, y down, z to the front, as in 12 §7.4. Part poses are written `off (x, y, z)` and `rot (xRot, yRot, zRot)`; a pose with no entry is zero.

---

## 0. Engine pieces these models rely on

### 0.1 Model building (`geom.builders.*`, `ModelPart`)

The part tree, the pose and drawing rules (34-1 §1.5), the cuboid and its unwrap (34-1 §1.3, 12 §7.4), the definition objects with the replace-and-merge rule and the clear and retain operations (34-1 §2.1) and `MeshTransformer.scaling` (34-1 §2.2) are specified in 34-1 and are not repeated here. The numbered items keep only what this document adds, because later sections cite them by number.

1. **Mesh and layer.** A layer is a part tree plus a texture size `(W, H)` (34-1 §2.1); the texture coordinates of a cuboid are divided by `(W, H)`.
2. **Drawing a part.** As 34-1 §1.5. The order in which the Z-Y-X rotation quaternion acts on a vertex is not settled here: the quaternion class is not in the artifact (Open question 1).
3. **Initial pose.** `EntityModel.setupAnim` first calls `resetPose` (34-1 §1.5). Everything a `setupAnim` writes below is therefore relative to the initial pose, except where it reads the part's current value (those places say so).
4. **Cuboid.** Geometry, grow and mirror are those of 34-1 §1.3. A cuboid with a zero extent on any of the three axes (`w`, `h` or `d` equal to 0) is a plane and produces faces of zero extent on that axis; only the faces of non-zero area show anything. Planes here: the vex and allay wings (`w` = 0), the creaking head planes (`d` = 0) and the creaking foot plates `left_leg (b)` and `right_leg (b)`, size (5, 0, 9) (`h` = 0).
5. **Replace-and-merge (matters for the witch).** Re-defining a named part keeps the old part's sub-parts (34-1 §2.1). This is how the witch inherits the villager's `nose` and `hat_rim` (3.1).
6. **Clearing.** `clearChild` and `clearRecursively` (34-1 §2.1) are used for the no-hat variants (the `head` part keeps its pose and children, with no cuboids); `retainPartsAndChildren` for the copper golem eyes layer (9.1) and `retainExactParts` for the creaking eyes layer (10).
7. **Scaling by 0.9375.** `scaling(0.9375)` (34-1 §2.2) makes the root pose offset `(0, 1.501, 0)` with scale 0.9375 in all axes, so the whole model is drawn 0.9375 times as large on the same ground line. `LayerDefinitions.createRoots` creates one transformer and applies it to exactly **eight** layers: `VILLAGER`, `VILLAGER_NO_HAT`, `WANDERING_TRADER` (the same `LayerDefinition` object as `VILLAGER`), the four illager layers `PILLAGER`, `VINDICATOR`, `EVOKER` and `ILLUSIONER` (all built from `IllagerModel.createBodyLayer`), and `WITCH` (built from `WitchModel.createBodyLayer`). The baby villager and every zombie villager layer are not scaled. Nothing else in this document is scaled.
8. **Where a vertex lands.** With the standard living-entity pipeline (0.3) the entity-space height of model y `y_m` is, for an unscaled model, `1.501 - y_m / 16` blocks above the entity origin (feet at `y_m = 24` give 0.001); for a 0.9375 model (the eight layers of item 7, the witch included) it is `1.4071875 - 0.05859375 * y_m` (feet 0.0009375, top of the villager or witch head at `y_m = -10` gives 1.993125).
9. **Sine table.** `Mth.sin` and `Mth.cos` read a table of 65536 floats; both have a float and a double parameter overload that read the same table (the renderers here widen floats and call the double overload). Double-precision `Math.cos` and `Math.sin` are used in exactly two places, both named below: the allay root bob (`Math.cos`, 11) and the ravager stun sway (`Math.sin`, 5). The difference is below 1e-4 and does not change the picture.

### 0.2 Keyframe animation engine (`net.minecraft.client.animation.*`)

Used by the copper golem and the creaking (Appendix A has every keyframe, printed as authored: degrees, pixels, scale factors). The data model and vector builders (34-1 §5.1), the additive target application, bone lookup, channel sampling with `LINEAR` and `CATMULLROM`, the end-of-animation behaviour and looping (34-1 §5.2) and `applyWalk` and the speed rule (34-1 §5.3) are specified there and not repeated. What this round adds:

| Element | Rule (read) |
|---|---|
| `AnimationState` timing | `getTimeInMillis(age)` = `(long)((age - startTick) * 50)`, a truncation to a long. A state with `startTick = Integer.MIN_VALUE` is stopped; `apply` does nothing for it. This answers 34-1 §5.5 (its Open question 8) |
| Speed | `apply(state, age, speed)` converts that long to a float, multiplies by `speed` and truncates again to a long, then applies with scale 1 (34-1 §5.3). Two truncations: they equal one truncation only for `speed = 1`. Every use in this document has `speed = 1` |
| `fastForward(ticks, speed)` | when the state is started, `startTick = startTick - (int)(ticks * speed)` (the product truncated toward zero): the start moves earlier, so the elapsed time grows by that many ticks |
| `start`, `stop`, `startIfStopped`, `animateWhen` | driven by the client entity (copper golem 44-3 §8; creaking 20 §17); the renderer copies the 32-bit `startTick` into the render state each frame |
| Walk-driven calls here | copper golem `applyWalk(walkPos, walkSpeed, 2, 2.5)` (9.2); creaking `applyWalk(walkPos, walkSpeed, 1, 1)` (10) |

Worked example (walk driven). Copper golem, no item, `walkPos = 1.0`, `walkSpeed = 0.2`: `ms = (long)(1.0 * 50 * 2) = 100`, `k = min(0.2 * 2.5, 1) = 0.5`, `t = 0.1`. Right arm rotation channel (keys 0:(70,0,0) 0.4167:(-80,0,0) 0.8333:(70,0,0), all CATMULLROM): `F = 1`, `i = 0`, `j = 1`, `p = 0.1 / 0.4167 = 0.24`; x component with `p0 = p1 = 70`, `p2 = -80`, `p3 = 70` gives `0.5 * (140 - 36 - 34.56 + 6.2208) = 0.5 * 75.6608 = 37.8304` degrees; times `k` = 18.9152 degrees = 0.3301 rad added to the arm's xRot.

### 0.3 The living-entity pipeline these renderers share (`LivingEntityRenderer`, `MobRenderer`, 12 §7.3)

Stated here once because the numbers below build on it; 34-1 §6.5 and §6.6 are the reference for the generic pose order and the renderer base classes, and the rest (death flip, sleeping, name tags) is in 34-1 §7.

1. Per frame, the render state holds: `yRot` = wrapDegrees(head yaw - body yaw), `xRot` = pitch, `bodyRot`, `walkAnimationPos`, `walkAnimationSpeed`, `ageInTicks`, `scale`, `ageScale`, `isBaby`, `isInvisible`, `deathTime`, `hasRedOverlay`, light coordinates, outline colour.
2. Pose stack order: translate to the entity; scale by `scale` (uniform); `setupRotations` (rotate Y by `180 - bodyRot` degrees, then the death roll about Z by `min(1, sqrt((deathTime - 1) / 20 * 1.6)) * 90` degrees when `deathTime > 0` (`getFlipDegrees` = 90 for every renderer of this document), the other pose cases); scale `(-1, -1, 1)`; `scale()` hook (empty for every renderer here); translate `(0, -1.501, 0)`.
3. The model is posed with `setupAnim(state)` and drawn with `getRenderType`. With `visible` = `isBodyVisible` and `translucent` = (not visible and not `isInvisibleToPlayer`): `translucent` selects `entityTranslucentCull(texture)` with tint 0x26FFFFFF (alpha 38); else `visible` selects the model's own render type with tint white (the renderer's `getModelTint`, -1 for all renderers here); else an outlined entity that is glowing draws the outline render type; else nothing. The overlay is `getOverlayCoords(state, getWhiteOverlayProgress)` (hurt flash from `hasRedOverlay`). Model render types: default `entityCutout(texture)`; the vex and the allay use `entityTranslucent(texture)`; the statue model uses `entityCutout`.
4. Layers run after the body, in registration order, with the same pose stack, light coordinates, the state, and `(yRot, xRot)`.
5. `renderColoredCutoutModel(model, texture, ..., tint, order)` (used by the profession and crack layers) draws the given model with `entityCutout(texture)`, the entity's light, the overlay of `getOverlayCoords(state, 0)`, tint white (-1), at sub-order `order`.
6. Shadow radius = renderer base radius times `scale` (`LivingEntityRenderer`) times, for mobs, `ageScale` (`MobRenderer`; read); renderer base radii are in the master table (§12). `ageScale` is `LivingEntity.getAgeScale()`, which is 0.5 when `isBaby` and 1 otherwise, copied by `LivingEntityRenderer.extractRenderState`.
7. `isBodyVisible` = not invisible (the illusioner overrides it to always true).

---

## 1. Villager, baby villager and wandering trader

### 1.1 `VillagerModel` (adult), texture 64 x 64, root scaled by 0.9375 (0.1 item 7)

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| head | root | 0 | tex (0, 0), origin (-4, -10, -4), size (8, 10, 8) |
| hat | head | 0 | tex (32, 0), origin (-4, -10, -4), size (8, 10, 8), grow 0.51 |
| hat_rim | hat | rot (-1.5707964, 0, 0) | tex (30, 47), origin (-8, -8, -6), size (16, 16, 1) |
| nose | head | off (0, -2, 0) | tex (24, 0), origin (-1, -1, -6), size (2, 4, 2) |
| body | root | 0 | tex (16, 20), origin (-4, 0, -3), size (8, 12, 6) |
| jacket | body | 0 | tex (0, 38), origin (-4, 0, -3), size (8, 20, 6), grow 0.5 |
| arms | root | off (0, 3, -1), rot (-0.75, 0, 0) | (a) tex (44, 22), origin (-8, -2, -2), size (4, 8, 4); (b) tex (44, 22), origin (4, -2, -2), size (4, 8, 4), mirror; (c) tex (40, 38), origin (-4, 2, -2), size (8, 4, 4) |
| right_leg | root | off (-2, 12, 0) | tex (0, 22), origin (-2, 0, -2), size (4, 12, 4) |
| left_leg | root | off (2, 12, 0) | tex (0, 22), origin (-2, 0, -2), size (4, 12, 4), mirror |

11 cuboids. The crossed arms are one part, `arms` (cuboid c is the bar between the two hands); there are no separate arm parts.

**No-hat variant** (`createNoHatModel`, layer `VILLAGER_NO_HAT`, also scaled 0.9375): the same tree after `clearChild("head")` then `clearRecursively()`: every cuboid under `head` (head, hat, hat_rim, nose) is removed, the parts remain. The variant therefore draws body, jacket, arms and legs only: despite its name it has **no head at all**. The profession layer uses it (1.4).

### 1.2 `BabyVillagerModel`, texture 64 x 64, not scaled

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| arms | root | off (0, 17.5, 0) | none |
| right_hand | arms | off (-3, 1.4025, -0.9599), rot (-1.0472, 0, 0) | (a) tex (36, 15), origin (-1, -2.4925, -1.8401), size (2, 4, 2); (b) tex (16, 15), origin (5, -2.4925, -1.8401), size (2, 4, 2) |
| middlearm_r1 | right_hand | off (0, 0.9024, -1.8175), rot (-1.0472, 0, 0) | tex (24, 17), origin (-2, -0.9924, -0.9825), size (4, 2, 2) |
| right_leg | root | off (-1, 21.5, 0) | tex (8, 23), origin (-1, -0.5, -1), size (2, 3, 2) |
| left_leg | root | off (1, 21.5, 0) | tex (0, 23), origin (-1, -0.5, -1), size (2, 3, 2) |
| head | root | off (0, 16, 0) | tex (0, 0), origin (-4, -8, -3.5), size (8, 8, 7) |
| hat | head | off (0, -4, 0) | tex (0, 30), origin (-4, -4, -3.5), size (8, 8, 7), grow 0.3 |
| hat_rim | head | off (0, -4.5, 0) | tex (0, 45), origin (-7, -0.5, -6), size (14, 1, 12) |
| nose | head | off (0, -2, -4) | tex (23, 0), origin (-1, 0, -0.5), size (2, 2, 1) |
| body | root | off (0, 18.75, 0) | tex (0, 15), origin (-2, -2.75, -1.5), size (4, 5, 3) |
| bb_main | root | off (0.5, 24, 0) | tex (16, 21), origin (-2.5, -8, -1.5), size (4, 6, 3), grow 0.2 |

11 cuboids. `BabyVillagerModel` extends the adult class (same field names and the same `setupAnim`), so `arms`, `head`, `right_leg`, `left_leg` exist by those names. Its no-hat variant (`VILLAGER_BABY_NO_HAT`) is `clearChild("head").clearRecursively()` as above (not scaled).

### 1.3 `VillagerModel.setupAnim` (also the baby)

1. Reset pose (0.1 item 3).
2. `head.yRot = state.yRot * D`, `head.xRot = state.xRot * D`.
3. If the villager is unhappy (`Villager.getUnhappyCounter() > 0`): `head.zRot = 0.3 * sin(0.45 * ageInTicks)` and `head.xRot = 0.4` (overrides step 2's xRot); else `head.zRot = 0`.
4. `right_leg.xRot = cos(walkPos * 0.6662) * 1.4 * walkSpeed * 0.5`; `left_leg.xRot = cos(walkPos * 0.6662 + pi) * 1.4 * walkSpeed * 0.5`; both legs `yRot = 0`.

The `arms` part keeps its initial pose: villagers never swing their arms.

`VillagerModel` implements `HeadedModel` (head part for the head layer) and `VillagerLikeModel.translateToArms(state, pose)`: apply the root part's translate-and-rotate (this includes the 0.9375 scale of the adult), then the `arms` part's.

### 1.4 `VillagerRenderer`

| Item | Value |
|---|---|
| Models | adult layer `VILLAGER`, baby layer `VILLAGER_BABY` (chosen per frame by `AgeableMobRenderer`: `isBaby` selects the baby model) |
| Shadow | base 0.5; the mob rule (0.5 * `scale` * `ageScale`) is multiplied by 0.5 more by `VillagerRenderer.getShadowRadius` when `isBaby`. `ageScale` is 0.5 for a baby (read, 0.3 item 6). Example: baby villager at scale 1: 0.5 * 1 * 0.5 * 0.5 = 0.125; adult 0.5 |
| Texture | `textures/entity/villager/villager.png` (adult), `textures/entity/villager/villager_baby.png` (baby) |
| Layers, in order | (1) `CustomHeadLayer` with transforms (yOffset -0.1171875, skullYOffset -0.07421875, horizontalScale 1, verticalScale 1); (2) `VillagerProfessionLayer` (1.5) with path name `villager`; (3) `CrossedArmsItemLayer` (1.6) |
| Render state | `VillagerRenderState` (a holding-entity state): the living fields, `heldItem` (main hand item resolved with display context `GROUND`), `isUnhappy`, `villagerData`; implements `VillagerDataHolderRenderState` whose only member is `getVillagerData()` returning `VillagerData` (type holder, profession holder, level integer) |

`CustomHeadLayer` (shared): when the state has a head item or a worn skull type, push; scale `(horizontalScale, verticalScale, horizontalScale)`; apply the model's root translate-and-rotate and its `translateToHead` (head part's translate-and-rotate); for a skull: translate `(0, skullYOffset, 0)`, scale 1.1875 and draw the skull model; for an item: translate `(0, -0.25 + yOffset, 0)`, rotate Y 180 deg, scale `(0.625, -0.625, -0.625)` and draw the head item model with overlay `NO_OVERLAY`. The default transform set is `(0, 0, 1, 1)`.

**`CrossedArmsItemLayer`** (villager, wandering trader; the witch subclass changes it, 3.3): when `heldItem` is not empty: push; `model.translateToArms(state, pose)`; rotate X by 0.75 rad (about 43 deg); scale 1.07 in all axes; translate `(0, 0.13, -0.34)`; rotate X by pi; draw the item model with overlay `NO_OVERLAY` and the state's outline colour; pop.

### 1.5 `VillagerProfessionLayer` (profession, type and level overlays)

Constructed with a path name (`villager` for the villager, `zombie_villager` for the zombie villager) and two *no-hat* models (adult and baby). It draws overlay textures on the entity's own model. The textures are data of the resource pack (22); the layer defines which files are looked up and how.

**Texture file names.** Let `P` be the path name. For a registry key `ns:name` and a folder `F`, the texture is `ns:textures/entity/P/F/name.png`. Folders: `type` (biome clothing; for a baby, the folder is `baby` instead of `type`), `profession`, `profession_level`. Level names: level 1 `stone`, 2 `iron`, 3 `gold`, 4 `emerald`, 5 `diamond` (namespace `minecraft`); the level is clamped to 1..5. A key that cannot be resolved falls back to the missing-texture image.

**Hat metadata.** For the type texture and the profession texture the layer reads the `villager` section of the texture's `.mcmeta` (`VillagerMetadataSection`): an optional field `hat` with the string values `none` (default), `partial`, `full`. The `.mcmeta` of the type texture is read from the `type` folder (not `baby`), that of the profession from `profession`. Results are cached per key. A holder without a key, or a missing file or section, gives `none`.

**Per frame** (all draws use `renderColoredCutoutModel`, tint white):
1. Return immediately if the entity is invisible or has no `villagerData`.
2. Let `typeHat` and `profHat` be the hat values above (type texture, profession texture).
3. **Type overlay, sub-order 1**: texture = `type` (or `baby`) folder entry for the villager type. The model used is the **parent (full) model** when `profHat == none`, or when `profHat == partial` and `typeHat != full`; otherwise the **no-hat model** (adult or baby by `isBaby`), which has no head cuboids (1.1). In words: a profession texture that covers the head ("full", or "partial" paired with a "full" type texture) stops the type overlay from drawing the head.
4. **Profession overlay, sub-order 2**: only when the profession is not `minecraft:none` and the entity is not a baby: texture = `profession` folder entry, parent (full) model.
5. **Level overlay, sub-order 3**: only when the profession is neither `minecraft:none` nor `minecraft:nitwit` and not a baby: texture = `profession_level` folder, level name above, parent (full) model.

Villager types and professions are registry entries (data); only the two special professions `none` and `nitwit` are named by code.

### 1.6 `WanderingTraderRenderer`

`MobRenderer` with the **adult** villager layer (`WANDERING_TRADER`, identical in definition to `VILLAGER`, scaled 0.9375), shadow 0.5, texture `textures/entity/wandering_trader/wandering_trader.png`, layers `CustomHeadLayer` (default transforms, no villager offset) and `CrossedArmsItemLayer`. No baby model, no profession layer. State `VillagerRenderState` with `isUnhappy = (WanderingTrader.getUnhappyCounter() > 0)`; held item as for the villager.

---

## 2. Zombie villager

`ZombieVillagerRenderer` extends the humanoid mob renderer (`HumanoidMobRenderer`, which adds the custom-head, wings and item-in-hand layers and the humanoid arm-pose extraction) with the adult model `ZOMBIE_VILLAGER`, baby model `ZOMBIE_VILLAGER_BABY`, shadow 0.5, and the same custom-head transforms as the villager (-0.1171875, -0.07421875, 1, 1). Neither zombie villager layer is scaled by 0.9375.

| Item | Value |
|---|---|
| Layers (after the humanoid ones) | `HumanoidArmorLayer` with armor model sets `ZOMBIE_VILLAGER_ARMOR` (adult) and `ZOMBIE_VILLAGER_BABY_ARMOR` (2.4); then `VillagerProfessionLayer` with path name `zombie_villager` and the two zombie no-hat models |
| Textures | `textures/entity/zombie_villager/zombie_villager.png`, `textures/entity/zombie_villager/zombie_villager_baby.png`; overlays under `textures/entity/zombie_villager/{type,baby,profession,profession_level}/` |
| State | `ZombieVillagerRenderState` (zombie state): `isConverting`, `villagerData`, `isAggressive` |
| Shaking | the entity shakes (body yaw jitter of `setupRotations`: `bodyRot += cos(floor(ageInTicks) * 3.25) * pi * 0.4`, degrees) when the base shaking test is true or `isConverting` |
| Arm animation | `HumanoidModel.setupAttackAnimation`, then `AnimationUtils.animateZombieArms(leftArm, rightArm, isAggressive, state)` (2.3) |

### 2.1 `ZombieVillagerModel` (adult), texture 64 x 64

Starts from `HumanoidModel.createMesh(NONE, 0)` (12 §7.4) and re-defines every humanoid part (old sub-parts are kept by the merge rule but all are redefined or empty):

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| head | root | 0 | (a) tex (0, 0), origin (-4, -10, -4), size (8, 10, 8); (b) tex (24, 0), origin (-1, -3, -6), size (2, 4, 2) (the nose is in the head part) |
| hat | head | 0 | tex (32, 0), origin (-4, -10, -4), size (8, 10, 8), grow 0.5 |
| hat_rim | hat | rot (-1.5707964, 0, 0) | tex (30, 47), origin (-8, -8, -6), size (16, 16, 1) |
| body | root | 0 | (a) tex (16, 20), origin (-4, 0, -3), size (8, 12, 6); (b) tex (0, 38), origin (-4, 0, -3), size (8, 20, 6), grow 0.05 |
| right_arm | root | off (-5, 2, 0) | tex (44, 22), origin (-3, -2, -2), size (4, 12, 4) |
| left_arm | root | off (5, 2, 0) | tex (44, 22), origin (-1, -2, -2), size (4, 12, 4), mirror |
| right_leg | root | off (-2, 12, 0) | tex (0, 22), origin (-2, 0, -2), size (4, 12, 4) |
| left_leg | root | off (2, 12, 0) | tex (0, 22), origin (-2, 0, -2), size (4, 12, 4), mirror |

10 cuboids. The no-hat layer (`ZOMBIE_VILLAGER_NO_HAT`) is `clearChild("head")` + `clearRecursively()`: no head cuboids.

### 2.2 `BabyZombieVillagerModel`, texture 64 x 64

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| body | root | off (0, 18.75, 0) | (a) tex (0, 15), origin (-2, -2.75, -1.5), size (4, 5, 3); (b) tex (16, 22), origin (-2, -2.75, -1.5), size (4, 6, 3), grow 0.1 |
| head | root | off (0, 16, 0) | tex (0, 0), origin (-4, -8, -3.5), size (8, 8, 7) |
| hat | head | off (0, -4, 0) | tex (0, 31), origin (-4, -4, -3.5), size (8, 8, 7), grow 0.3 |
| hat_rim | head | off (0, -4.5, 0) | tex (0, 46), origin (-7, -0.5, -6), size (14, 1, 12) |
| nose | head | off (0, -1, -4) | tex (23, 0), origin (-1, -1, -0.5), size (2, 2, 1) |
| right_arm | root | off (-3, 15.5, 0) | tex (24, 15), origin (-1, -0.5, -1), size (2, 5, 2), grow 0 |
| left_arm | root | off (3, 15.5, 0) | tex (16, 15), origin (-1, -0.5, -1), size (2, 5, 2), grow 0 |
| right_leg | root | off (-1, 21.5, 0) | tex (8, 23), origin (-1, -0.5, -1), size (2, 3, 2) |
| left_leg | root | off (1, 21.5, 0) | tex (0, 23), origin (-1, -0.5, -1), size (2, 3, 2) |

10 cuboids; no-hat variant as above.

### 2.3 `AnimationUtils.animateZombieArms(leftArm, rightArm, attacking, state)`

Used by the zombie villager and by the illager `ATTACKING` pose with an empty hand.

1. If either arm pose of the state is `SPEAR`, do nothing.
2. `empty` = the state is a baby, or its main-hand item stack is `ItemStack.EMPTY`.
3. `base` = if `empty`: `-pi / (attacking ? 1.5 : 2.25)`, else 0. `s` = the swing progress (`swingAnimation`). `a` = `(empty ? 1 : -1) * sin(s * pi)`. `b` = `sin((1 - (1 - s)^2) * pi)`.
4. `x = base + a * 1.2 - b * 0.4`, `y = 0.1 - a * 0.6`.
5. Right arm (unless its pose is `THROW_TRIDENT`): `xRot = x`, `yRot = empty ? -y : y`, `zRot = 0`. Left arm (unless `THROW_TRIDENT`): `xRot = x`, `yRot = empty ? y : -y`, `zRot = 0`.

Example: an attacking zombie villager with an empty hand and `s = 0`: `base = -2.0944`, `a = 0`, `b = 0`, so both arms `xRot = -2.0944` (raised 120 deg), right `yRot = -0.1`, left `yRot = +0.1`.

### 2.4 Zombie villager armor layers (`ZombieVillagerModel.createArmorLayerSet`)

The adult set `ZOMBIE_VILLAGER_ARMOR` has the four layers helmet, chestplate, leggings and boots, each **64 x 32**. Every slot is built from `createBaseArmorMesh(g)` with `g` the slot's deformation (head, chest and feet use the outer 1.0; legs use the inner 0.5; constants 34-1 §2.4), then trimmed to the slot's retained parts by the humanoid rule `ADULT_ARMOR_PARTS_PER_SLOT` (34-2 §1.4: head = `head` and its children; chest = `body`, `left_arm`, `right_arm`; legs = `left_leg`, `right_leg`, `body`; feet = `left_leg`, `right_leg`). The base mesh starts from `HumanoidModel.createMesh(g, 0)` (12 §7.4) and then re-defines:

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| head | root | 0 | tex (0, 0), origin (-4, -10, -4), size (8, 8, 8), grow `g` |
| hat (kept from the humanoid mesh, child of `head`) | head | 0 | tex (32, 0), origin (-4, -8, -4), size (8, 8, 8), grow `g + 0.5` |
| hat_rim | hat | 0 | none (re-defined empty) |
| body | root | 0 | tex (16, 16), origin (-4, 0, -2), size (8, 12, 4), grow `g + 0.1` |
| right_leg | root | off (-2, 12, 0) | tex (0, 16), origin (-2, 0, -2), size (4, 12, 4), grow `g + 0.1` |
| left_leg | root | off (2, 12, 0) | the same box, mirror, grow `g + 0.1` |
| right_arm, left_arm | root | as 12 §7.4 | not re-defined: the humanoid arms with grow `g` (12 §7.4) |

Resulting grows: helmet, head 1.0 and hat 1.5; chestplate, body 1.1 and arms 1.0; leggings, body 0.6 and legs 0.6; boots, legs 1.1. (Unlike the generic humanoid armor of 34-2 §1.4, which builds the legs at `g - 0.1`, the zombie villager legs and body are at `g + 0.1`; the head box is 8 high, not the 10 of the body model, and has no nose.) The hat is the only part of the armor head with a child; its brim is empty. Only `hat_rim` is emptied; the `hat` box is the humanoid one.

The baby set `ZOMBIE_VILLAGER_BABY_ARMOR` is `createBabyArmorMeshSet` with the baby inner and outer deformations and arm offset (0, 0, 0): the baby armor mesh and its slot parts are in 34-2 §1.4 (64 x 64). The equipment texture of each piece is data (22).

---

## 3. Witch

### 3.1 `WitchModel`, texture 64 x 128

Built from the villager body mesh (1.1) and then re-defining `head` and `hat` and adding the tail of the hat and the mole. By the merge rule (0.1 item 5) the villager's `head` children `nose` and, below `hat`, `hat_rim` survive. The resulting tree:

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| head | root | 0 | tex (0, 0), origin (-4, -10, -4), size (8, 10, 8) |
| hat | head | off (-5, -10.03125, -5) | tex (0, 64), origin (0, 0, 0), size (10, 2, 10) |
| hat_rim (inherited) | hat | rot (-1.5707964, 0, 0) | tex (30, 47), origin (-8, -8, -6), size (16, 16, 1); the villager brim, kept unchanged (Open question 2) |
| hat2 | hat | off (1.75, -4, 2), rot (-0.05235988, 0, 0.02617994) | tex (0, 76), origin (0, 0, 0), size (7, 4, 7) |
| hat3 | hat2 | off (1.75, -4, 2), rot (-0.10471976, 0, 0.05235988) | tex (0, 87), origin (0, 0, 0), size (4, 4, 4) |
| hat4 | hat3 | off (1.75, -2, 2), rot (-0.20943952, 0, 0.10471976) | tex (0, 95), origin (0, 0, 0), size (1, 2, 1), grow 0.25 |
| nose (inherited) | head | off (0, -2, 0) | tex (24, 0), origin (-1, -1, -6), size (2, 4, 2) |
| mole | nose | off (0, -2, 0) | tex (0, 0), origin (0, 3, -6.75), size (1, 1, 1), grow -0.25 |
| body, jacket, arms, right_leg, left_leg | as 1.1 | as 1.1 | as 1.1 (the robe `jacket` and the crossed `arms` part are present) |

6 cuboids defined in the witch method plus the inherited ones. The finished witch layer is then scaled by 0.9375 like the villager (0.1 item 7: `LayerDefinitions` applies the same transformer to `WITCH`), so the witch stands with its feet at 0.0009375 above the entity origin and its head top at 1.993125 (0.1 item 8). `WitchModel` is a `HeadedModel` with accessors `getHead()` and `getNose()`.

### 3.2 `WitchModel.setupAnim`

1. Reset; `head.yRot = yRot * D`, `head.xRot = xRot * D`.
2. Legs as the villager (1.3 step 4: `cos(walkPos * 0.6662) * 1.4 * walkSpeed * 0.5` right, `+ pi` left), no `yRot` assignment.
3. `f = 0.01 * (entityId mod 10)` (integer remainder, converted to float). `nose.xRot = sin(ageInTicks * f) * 4.5 * D`, `nose.zRot = cos(ageInTicks * f) * 2.5 * D` (table functions).
4. If the witch holds an item (`mainHandItem` not empty): `nose.setPos(0, 1, -1.5)` (replaces the nose's offset; the mole follows) and `nose.xRot = -0.9`.

Worked example: entity id 7, age 10 ticks, no item: `f = 0.07`, `nose.xRot = sin(0.7) * 4.5 D = 0.0506` rad, `nose.zRot = cos(0.7) * 2.5 D = 0.0334` rad. Holding a potion: nose at (0, 1, -1.5), xRot -0.9.

### 3.3 `WitchRenderer` and `WitchItemLayer`

| Item | Value |
|---|---|
| Renderer | `MobRenderer`, shadow 0.5, texture `textures/entity/witch/witch.png`, one layer `WitchItemLayer` (no custom-head layer) |
| State | `WitchRenderState`: `entityId`, `isHoldingItem` (main hand not empty), `isHoldingPotion` (main hand is the potion item), `heldItem` (GROUND context) |
| `WitchItemLayer` | extends `CrossedArmsItemLayer`. If the held item is a potion: root translate-and-rotate; `translateToHead` (head part); the nose part's translate-and-rotate; translate `(0.0625, 0.25, 0)`; rotate Z 180 deg, X 140 deg, Z 10 deg, X 180 deg (in that order); then the item is drawn as in 1.4. Any other item: the crossed-arms transform of 1.4 |

---

## 4. Illagers

### 4.1 `IllagerModel` (pillager, vindicator, evoker, illusioner), texture 64 x 64, root scaled by 0.9375

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| head | root | 0 | tex (0, 0), origin (-4, -10, -4), size (8, 10, 8) |
| hat | head | 0 | tex (32, 0), origin (-4, -10, -4), size (8, 12, 8), grow 0.45. `visible = false` by default; the illusioner renderer sets it visible |
| nose | head | off (0, -2, 0) | tex (24, 0), origin (-1, -1, -6), size (2, 4, 2) |
| body | root | 0 | (a) tex (16, 20), origin (-4, 0, -3), size (8, 12, 6); (b) tex (0, 38), origin (-4, 0, -3), size (8, 20, 6), grow 0.5 |
| arms (crossed) | root | off (0, 3, -1), rot (-0.75, 0, 0) | (a) tex (44, 22), origin (-8, -2, -2), size (4, 8, 4); (b) tex (40, 38), origin (-4, 2, -2), size (8, 4, 4) |
| left_shoulder | arms | 0 | tex (44, 22), origin (4, -2, -2), size (4, 8, 4), mirror |
| right_leg | root | off (-2, 12, 0) | tex (0, 22), origin (-2, 0, -2), size (4, 12, 4) |
| left_leg | root | off (2, 12, 0) | tex (0, 22), origin (-2, 0, -2), size (4, 12, 4), mirror |
| right_arm | root | off (-5, 2, 0) | tex (40, 46), origin (-3, -2, -2), size (4, 12, 4) |
| left_arm | root | off (5, 2, 0) | tex (40, 46), origin (-1, -2, -2), size (4, 12, 4), mirror |

12 cuboids. The model implements `HeadedModel` (head), `ArmedModel` (`translateToHand(state, arm, pose)`: root translate-and-rotate, then that arm part's) and exposes `getHat()`.

### 4.2 `IllagerModel.setupAnim`

1. Reset; `head.yRot = yRot * D`, `head.xRot = xRot * D`.
2. If `isRiding` (the entity is a passenger): both arms `xRot = -0.62831855`, `yRot = 0`, `zRot = 0`; right leg `xRot = -1.4137167`, `yRot = 0.31415927`, `zRot = 0.07853982`; left leg `xRot = -1.4137167`, `yRot = -0.31415927`, `zRot = -0.07853982`.
3. Else (walking): with `v` = `walkAnimationSpeed`, `w` = `walkAnimationPos`: right arm `xRot = cos(w * 0.6662 + pi) * 2 * v * 0.5`; left arm `xRot = cos(w * 0.6662) * 2 * v * 0.5`; right leg `xRot = cos(w * 0.6662) * 1.4 * v * 0.5`; left leg `xRot = cos(w * 0.6662 + pi) * 1.4 * v * 0.5`; the `yRot` and `zRot` of all four are set to 0.
4. Then by `armPose` (4.3), after steps 2 or 3:

| `armPose` | Effect |
|---|---|
| `CROSSED`, `NEUTRAL` | nothing further (walk or ride pose only) |
| `ATTACKING` | if the main-hand item state is empty: `animateZombieArms(leftArm, rightArm, true, state)` (2.3), then `bobArms(rightArm, leftArm, age)`; else `swingWeaponDown(rightArm, leftArm, mainArm, swingAnimation, age)` (4.4) |
| `SPELLCASTING` | right arm: `z = 0`, `x = -5`; left arm: `z = 0`, `x = 5` (part positions); both `xRot = cos(age * 0.6662) * 0.25`; right `zRot = 2.3561945`, left `zRot = -2.3561945`; both `yRot = 0` |
| `BOW_AND_ARROW` | right arm `yRot = -0.1 + head.yRot`, `xRot = -pi/2 + head.xRot`; left arm `xRot = -0.9424779 + head.xRot`, `yRot = head.yRot - 0.4`, `zRot = pi/2` (head values are the head part's current rotation, set in step 1) |
| `CROSSBOW_HOLD` | `animateCrossbowHold(rightArm, leftArm, head, true)` (12 §7.5, `CROSSBOW_HOLD`, right hand holding) |
| `CROSSBOW_CHARGE` | `animateCrossbowCharge(rightArm, leftArm, maxCrossbowChargeDuration, ticksUsingItem, true)` (12 §7.5) |
| `CELEBRATING` | right arm: `z = 0`, `x = -5`, `xRot = cos(age * 0.6662) * 0.05`, `zRot = 2.670354`, `yRot = 0`; left arm: `z = 0`, `x = 5`, `xRot = cos(age * 0.6662) * 0.05`, `zRot = -2.3561945`, `yRot = 0` |

5. Visibility: `arms` (the crossed part) is visible exactly when `armPose == CROSSED`; `left_arm` and `right_arm` are visible exactly when it is not.

(`age` = `ageInTicks`; cosines are table functions; `bobArms` is 4.4.)

### 4.3 Which pose each illager has (`getArmPose`, read from the entity classes)

| Entity | Rule, first match wins |
|---|---|
| Pillager | charging its crossbow: `CROSSBOW_CHARGE`; holding a crossbow: `CROSSBOW_HOLD`; aggressive: `ATTACKING`; else `NEUTRAL` |
| Vindicator | aggressive: `ATTACKING`; celebrating (raid won): `CELEBRATING`; else `CROSSED` |
| Evoker (`SpellcasterIllager`) | casting a spell: `SPELLCASTING`; celebrating: `CELEBRATING`; else `CROSSED` |
| Illusioner | casting: `SPELLCASTING`; aggressive: `BOW_AND_ARROW`; else `CROSSED` |
| Any other `AbstractIllager` | `CROSSED` |

The enum order is `CROSSED, ATTACKING, SPELLCASTING, BOW_AND_ARROW, CROSSBOW_HOLD, CROSSBOW_CHARGE, CELEBRATING, NEUTRAL`. `isCastingSpell` is, on the client, "the synched spell byte is greater than 0".

### 4.4 `AnimationUtils.swingWeaponDown` and `bobArms`

`swingWeaponDown(rightArm, leftArm, mainArm, s, age)` with `s` the swing progress:
1. `a = sin(s * pi)`, `b = sin((1 - (1 - s)^2) * pi)`.
2. Both arms `zRot = 0`; right `yRot = 0.15707964`, left `yRot = -0.15707964`.
3. If `mainArm == RIGHT`: right `xRot = -1.8849558 + cos(age * 0.09) * 0.15`, left `xRot = cos(age * 0.19) * 0.5`; then right `xRot += a * 2.2 - b * 0.4`, left `xRot += a * 1.2 - b * 0.4`. If `mainArm == LEFT`: right `xRot = cos(age * 0.19) * 0.5`, left `xRot = -1.8849558 + cos(age * 0.09) * 0.15`; then right `xRot += a * 1.2 - b * 0.4`, left `xRot += a * 2.2 - b * 0.4`.
4. `bobArms(rightArm, leftArm, age)`.

`bobArms(first, second, age)`: `bobModelPart(first, age, +1)` and `bobModelPart(second, age, -1)`; `bobModelPart(part, age, sign)`: `part.zRot += sign * (cos(age * 0.09) * 0.05 + 0.05)`; `part.xRot += sign * sin(age * 0.067) * 0.05` (12 §7.5).

Example: a vindicator with an axe, main arm right, swing 0.5, age 0: `a = 1.0`, `b = 0.7071`; right `xRot = -1.8849558 + 0.15 + 2.2 - 0.2828 = 0.1822` before the bob, left `xRot = 0.5 + 1.2 - 0.2828 = 1.4172`.

### 4.5 `IllagerRenderer` and the four mobs

Base (`IllagerRenderer`): `MobRenderer` with the illager model, base shadow 0.5 for all four, a `CustomHeadLayer` (default transforms). Extraction fills the armed state (arm, hand item states with `THIRD_PERSON_RIGHT_HAND` / `THIRD_PERSON_LEFT_HAND`, hand stacks, swing progress), then `isRiding = isPassenger`, `mainArm`, `armPose`, `maxCrossbowChargeDuration` (the crossbow charge duration of the used item when the pose is `CROSSBOW_CHARGE`, else 0), `ticksUsingItem` (with partial tick), `isAggressive`. `IllagerRenderState` extends the undead/humanoid state (so `swingAnimation`, arm poses default `EMPTY`, `isBaby` false).

| Mob | Texture | Extra layer (`ItemInHandLayer` unless noted) | Other |
|---|---|---|---|
| Pillager | `textures/entity/illager/pillager.png` | item in hand always | |
| Vindicator | `textures/entity/illager/vindicator.png` | item in hand only when `isAggressive` | |
| Evoker | `textures/entity/illager/evoker.png` | item in hand only when `isCastingSpell` (`EvokerRenderState` adds `isCastingSpell`) | |
| Illusioner | `textures/entity/illager/illusioner.png` | item in hand when `isCastingSpell` or `isAggressive` | hat visible; double rendering when invisible (4.6) |

**`ItemInHandLayer`** (shared; the third-person held item of every armed model): for the right hand then the left hand: skip if that hand's item state is empty; push; `model.translateToHand(state, arm, pose)`; rotate X -90 deg; rotate Y 180 deg; translate `(side * 1 / 16, 2 / 16, -10 / 16)` for an adult, or `(0, 1 / 16, -4.5 / 16)` when `useBabyOffset` (the state is a baby and not an armor stand), with `side = -1` for the left hand and `+1` for the right; when the swing is a spear stab by this hand `SpearAnimations.thirdPersonAttackItem` adjusts the pose (Open question 5); when the arm is using an item (`ticksUsingItem(arm) > 0`) the arm pose's `animateUseItem` adjusts it (illagers: their state shadows `ticksUsingItem` with its own field, which the illager extraction does not set, and does not set `isUsingItem`, so they yield 0; vex, allay and copper golem use the armed-entity state whose `ticksUsingItem(arm)` returns 0; the zombie villager goes through `HumanoidMobRenderer.extractHumanoidRenderState`, which stores `isUsingItem` and `ticksUsingItem` from the entity, and `HumanoidRenderState.ticksUsingItem(arm)` returns the stored ticks for the arm of the using hand, so a non-zero value for a zombie villager that uses an item is possible (inferred; the `animateUseItem` effect for its arm pose was not read, Open question 5)); draw the item model with `NO_OVERLAY`; pop.

### 4.6 Illusioner specifics

- `IllusionerRenderState` adds `illusionOffsets` (an array of 3-vectors copied from `Illusioner.getIllusionOffsets(partial)`) and `isCastingSpell`.
- `isBodyVisible` is always true; the culling box is the base box inflated by `(3, 0, 3)`.
- When the state is invisible: for each offset `i` (index from 0): push; translate by `(o.x + cos(i + age * 0.5) * 0.025, o.y + cos(i + age * 0.75) * 0.0125, o.z + cos(i + age * 0.7) * 0.025)`; draw the whole mob (model and layers) as usual; pop. When visible: draw once with no offset. Arithmetic: the argument `i + age * k` (k = 0.5, 0.75, 0.7 for x, y, z) is formed in float and widened; the table cosine `Mth.cos` (double overload, float result) is applied three times; each result is widened and multiplied by the double constants 0.025, 0.0125, 0.025 and added to the offset component in double. (Not `Math.cos`.)

### 4.7 Spellcasting particles (client side of `SpellcasterIllager.tick`)

In `SpellcasterIllager.tick`, right after the superclass (`AbstractIllager`) tick returns, and only when the level is client-side and `isCastingSpell` holds (client: the synched spell byte is greater than 0; on the server `isCastingSpell` is `spellCastingTickCount > 0`), the client spawns two `entity_effect` particles at the entity every tick: with `c` = the current spell's colour `(r, g, b)` (0..1) and `phi = yBodyRot * D + cos(tickCount * 0.6662) * 0.25`, `dx = cos(phi) * 0.6 * scale`, `dz = sin(phi) * 0.6 * scale`, `dy = 1.8 * scale`: one at `(x + dx, y + dy, z + dz)` and one at `(x - dx, y + dy, z - dz)`, velocity 0. The `cos` and `sin` of `phi` are the table functions. Spell colours (id, r, g, b): NONE 0 (0, 0, 0); SUMMON_VEX 1 (0.7, 0.7, 0.8); FANGS 2 (0.4, 0.3, 0.35); WOLOLO 3 (0.7, 0.5, 0.2); DISAPPEAR 4 (0.3, 0.3, 0.8); BLINDNESS 5 (0.1, 0.1, 0.2).

### 4.8 Evoker fangs

**`EvokerFangsModel`**, texture 64 x 32. The model root is the layer root.

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| base | root | off (-5, 24, -5) | tex (0, 0), origin (0, 0, 0), size (10, 12, 10) |
| upper_jaw | base | off (6.5, 0, 1), rot (0, 0, 2.042035) | tex (40, 0), origin (0, 0, 0), size (4, 14, 8) |
| lower_jaw | base | off (3.5, 0, 9), rot (0, 3.1415927, 4.2411504) | tex (40, 0), origin (0, 0, 0), size (4, 14, 8) |

3 cuboids. `setupAnim` with `p` = `biteProgress` (0..1):
1. `q = min(p * 2, 1)`; `q = 1 - q^3`.
2. `upper_jaw.zRot = pi - q * 0.35 * pi`; `lower_jaw.zRot = pi + q * 0.35 * pi`.
3. `base.y = base.y - (p + sin(p * 2.7)) * 7.2` (current value 24, table sine).
4. `r = 1`; if `p > 0.9`: `r = (1 - p) / 0.1`.
5. `root.y = 24 - 20 * r`; `root.xScale = root.yScale = root.zScale = r`.

**Renderer** (`EvokerFangsRenderer`, an `EntityRenderer`, no shadow, texture `textures/entity/illager/evoker_fangs.png`): state `yRot` = the entity's yaw, `biteProgress` = `EvokerFangs.getAnimationProgress(partial)`. Skip drawing when `biteProgress == 0`. Else: push; rotate Y by `90 - yRot` degrees; scale `(-1, -1, 1)`; translate `(0, -1.501, 0)`; submit the model with the state's light, `NO_OVERLAY`, outline colour; pop. `getAnimationProgress`: 0 until entity event 4 sets `clientSideAttackStarted`; then with `t = lifeTicks - 2`: 1 when `t <= 0`, else `1 - (t - partial) / 20`.

**Client counters** (`EvokerFangs`, read). `lifeTicks` starts at 22. Entity event 4 sets `clientSideAttackStarted` and, unless the entity is silent, plays the fangs attack sound at the entity (volume 1, pitch `0.85 + 0.2 * r`, `r` a random float in [0, 1)). From then on every client tick decrements `lifeTicks` by 1. Progress therefore rises linearly from 0 at `t = 20` (`lifeTicks` 22) to 1 at `t = 0` (`lifeTicks` 2): a 20-tick bite, and it stays 1 afterwards until the entity is discarded. On the client tick in which `lifeTicks`, after that decrement, equals 14, a burst of 12 `crit` particles is spawned. Each particle draws six random doubles `r1..r6` in [0, 1) from the entity's random source in this order and spawns at `x = X + (2 r1 - 1) * width * 0.5`, `y = Y + 0.05 + r2 + 1`, `z = Z + (2 r3 - 1) * width * 0.5` (width 0.5) with velocity `((2 r4 - 1) * 0.3, 0.3 + r5 * 0.3, (2 r6 - 1) * 0.3)`. The server's warm-up counters, the damage and the event 4 broadcast are in 20 §13.3 (Fangs).

Worked examples (`p` -> jaw zRot upper / lower, `base.y`, `root.y`, root scale):

| p | q | upper | lower | base.y | root.y | root scale |
|---|---|---|---|---|---|---|
| 0.1 | 0.992 | 2.0508 | 4.2324 | 21.3595 | 4 | 1 |
| 0.5 | 0 | 3.1416 | 3.1416 | 13.3748 | 4 | 1 |
| 0.95 | 0 | 3.1416 | 3.1416 | 13.2348 | 14 | 0.5 |

---

## 5. Ravager

`RavagerModel`, texture 128 x 128, layer unscaled, root pose zero.

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| neck | root | off (0, -7, 5.5) | tex (68, 73), origin (-5, -1, -18), size (10, 10, 18) |
| head | neck | off (0, 16, -17) | (a) tex (0, 0), origin (-8, -20, -14), size (16, 20, 16); (b) tex (0, 0), origin (-2, -6, -18), size (4, 8, 4) |
| right_horn | head | off (-10, -14, -8), rot (1.0995574, 0, 0) | tex (74, 55), origin (0, -14, -2), size (2, 14, 4) |
| left_horn | head | off (8, -14, -8), rot (1.0995574, 0, 0) | tex (74, 55), origin (0, -14, -2), size (2, 14, 4), mirror |
| mouth | head | off (0, -2, 2) | tex (0, 36), origin (-8, 0, -16), size (16, 3, 16) |
| body | root | off (0, 1, 2), rot (1.5707964, 0, 0) | (a) tex (0, 55), origin (-7, -10, -7), size (14, 16, 20); (b) tex (0, 91), origin (-6, 6, -7), size (12, 13, 18) |
| right_hind_leg | root | off (-8, -13, 18) | tex (96, 0), origin (-4, 0, -4), size (8, 37, 8) |
| left_hind_leg | root | off (8, -13, 18) | tex (96, 0), origin (-4, 0, -4), size (8, 37, 8), mirror |
| right_front_leg | root | off (-8, -13, -5) | tex (64, 0), origin (-4, 0, -4), size (8, 37, 8) |
| left_front_leg | root | off (8, -13, -5) | tex (64, 0), origin (-4, 0, -4), size (8, 37, 8), mirror |

12 cuboids.

**State** (`RavagerRenderer`, shadow 1.1, texture `textures/entity/illager/ravager.png`, no extra layers): `stunnedTicksRemaining = stunnedTick > 0 ? stunnedTick - partial : 0`; `attackTicksRemaining` likewise from `getAttackTick`; `roarAnimation = roarTick > 0 ? (20 - roarTick + partial) / 20 : 0`.

**`setupAnim`** (`T(x, p)` = `Mth.triangleWave(x, p) = (|x mod p - p / 2| - p / 4) / (p / 4)`, `x mod p` the float remainder):
1. Reset. Let `S` = stunnedTicksRemaining, `A` = attackTicksRemaining.
2. If `A > 0`: `f = (1 + T(A, 10)) * 0.5`; `g = f^3 * 12`; `neck.z = -6.5 + g`; `neck.y = -7 - g * sin(neck.xRot)` (the neck's `xRot` is its reset value 0 here, so `neck.y = -7`); if `A > 5`: `mouth.xRot = sin((-4 + A) / 4) * pi * 0.4`; else `mouth.xRot = 0.15707964 * sin(pi * A / 10)`.
3. Else: `neck.x = 0`; `neck.y = -7 + sin(neck.xRot)` (the neck's `xRot` is its reset value 0 at that moment, so -7); `neck.z = 5.5`; `stunned = S > 0`; `neck.xRot = stunned ? 0.21991149 : 0`; `mouth.xRot = pi * (stunned ? 0.05 : 0.01)`; if `stunned`: `neck.x = sin(S / 40 * 10) * 3` (double `Math.sin`); else if `roarAnimation > 0`: `mouth.xRot = 1.5707964 * sin(roarAnimation * pi * 0.25)`.
4. `head.xRot = xRot * D`, `head.yRot = yRot * D`.
5. With `w = walkAnimationPos`, `v = 0.4 * walkAnimationSpeed`: `right_hind_leg.xRot = cos(w * 0.6662) * v`; `left_hind_leg.xRot = cos(w * 0.6662 + pi) * v`; `right_front_leg.xRot = cos(w * 0.6662 + pi) * v`; `left_front_leg.xRot = cos(w * 0.6662) * v`.

Examples: attack just started (`A = 10`): `T = 1`, `f = 1`, `g = 12`, `neck.z = 5.5`, `mouth.xRot = sin(1.5) * pi * 0.4 = 1.2535`. At `A = 5`: `T = -1`, `g = 0`, `neck.z = -6.5`, `mouth.xRot = 0.15708`. Stunned with `S = 20`: `neck.xRot = 0.2199`, `mouth.xRot = 0.157`, `neck.x = sin(5) * 3 = -2.877`.

---

## 6. Vex

`VexModel`, texture 32 x 32, render type `entityTranslucent`. The model root is the layer's child `root`.

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| root | layer root | off (0, -2.5, 0) | none |
| head | root | off (0, 20, 0) | tex (0, 0), origin (-2.5, -5, -2.5), size (5, 5, 5) |
| body | root | off (0, 20, 0) | (a) tex (0, 10), origin (-1.5, 0, -1), size (3, 4, 2); (b) tex (0, 16), origin (-1.5, 1, -1), size (3, 5, 2), grow -0.2 |
| right_arm | body | off (-1.75, 0.25, 0) | tex (23, 0), origin (-1.25, -0.5, -1), size (2, 4, 2), grow -0.1 |
| left_arm | body | off (1.75, 0.25, 0) | tex (23, 6), origin (-0.75, -0.5, -1), size (2, 4, 2), grow -0.1 |
| left_wing | body | off (0.5, 1, 1) | tex (16, 14), origin (0, 0, 0), size (0, 5, 8), mirror |
| right_wing | body | off (-0.5, 1, 1) | tex (16, 14), origin (0, 0, 0), size (0, 5, 8) |

7 cuboids.

**`setupAnim`**: head `yRot`, `xRot` from the state (times D). `b = cos(age * 5.5 * D) * 0.1`; `right_arm.zRot = 0.62831855 + b`; `left_arm.zRot = -(0.62831855 + b)`. If `isCharging`: `body.xRot = 0` and `setArmsCharging(rightHasItem, leftHasItem, b)` (a hand has an item when its hand item state is not empty); else `body.xRot = 0.15707964`. Always: `left_wing.yRot = 1.0995574 + cos(age * 45.836624 * D) * D * 16.2`; `right_wing.yRot = -left_wing.yRot`; `left_wing.xRot = 0.47123888`, `left_wing.zRot = -0.47123888`; `right_wing.xRot = 0.47123888`, `right_wing.zRot = 0.47123888`.

`setArmsCharging(R, L, b)`: if neither hand has an item: right arm `xRot = -1.2217305`, `yRot = 0.2617994`, `zRot = -0.47123888 - b`; left arm `xRot = -1.2217305`, `yRot = -0.2617994`, `zRot = 0.47123888 + b`. Otherwise: if `R`: right arm `xRot = 3.6651914`, `yRot = 0.2617994`, `zRot = -0.47123888 - b`; if `L`: left arm `xRot = 3.6651914`, `yRot = -0.2617994`, `zRot = 0.47123888 + b`.

**`translateToHand(state, arm, pose)`**: root, body and the chosen arm part translate-and-rotate; scale 0.55; then translate by `(+0.046875, -0.15625, 0.078125)` for the right arm or `(-0.046875, -0.15625, 0.078125)` for the left (doubles).

**`VexRenderer`**: shadow 0.3; layer `ItemInHandLayer`; texture `textures/entity/illager/vex.png`, or `vex_charging.png` when `isCharging`; the block-light level is always 15 (`getBlockLightLevel`). State: armed state plus `isCharging`.

Example: age 0: `b = 0.1`, arms `zRot = 0.7283` and `-0.7283`; `left_wing.yRot = 1.0995574 + 0.28274 = 1.3823`, `right_wing.yRot = -1.3823`.

---

## 7. Iron golem

`IronGolemModel`, texture 128 x 128, unscaled, root pose zero.

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| head | root | off (0, -7, -2) | (a) tex (0, 0), origin (-4, -12, -5.5), size (8, 10, 8); (b) tex (24, 0), origin (-1, -5, -7.5), size (2, 4, 2) |
| body | root | off (0, -7, 0) | (a) tex (0, 40), origin (-9, -2, -6), size (18, 12, 11); (b) tex (0, 70), origin (-4.5, 10, -3), size (9, 5, 6), grow 0.5 |
| right_arm | root | off (0, -7, 0) | tex (60, 21), origin (-13, -2.5, -3), size (4, 30, 6) |
| left_arm | root | off (0, -7, 0) | tex (60, 58), origin (9, -2.5, -3), size (4, 30, 6) |
| right_leg | root | off (-4, 11, 0) | tex (37, 0), origin (-3.5, -3, -3), size (6, 16, 5) |
| left_leg | root | off (5, 11, 0) | tex (60, 0), origin (-3.5, -3, -3), size (6, 16, 5), mirror |

8 cuboids.

**State** (`IronGolemRenderer`, shadow 0.7, texture `textures/entity/iron_golem/iron_golem.png`): `attackTicksRemaining = attackAnimationTick > 0 ? tick - partial : 0`; `offerFlowerTick` (integer, `IronGolem.getOfferFlowerTick`); `flowerBlock` = the default state of the poppy block when `offerFlowerTick > 0`, else cleared; `crackiness` = `IronGolem.getCrackiness()`.

**`setupAnim`** (`T` as in §5; `A` attack, `F` offerFlowerTick, `w` walkPos, `v` walkSpeed):
1. If `A > 0`: right and left arm `xRot = -2 + 1.5 * T(A, 10)`.
2. Else if `F > 0`: right arm `xRot = -0.8 + 0.025 * T(F, 70)`; left arm `xRot = 0`.
3. Else: right arm `xRot = (-0.2 + 1.5 * T(w, 13)) * v`; left arm `xRot = (-0.2 - 1.5 * T(w, 13)) * v`.
4. `head.yRot`, `head.xRot` from the state (times D). `right_leg.xRot = -1.5 * T(w, 13) * v`; `left_leg.xRot = 1.5 * T(w, 13) * v`; both legs `yRot = 0`.

**`setupRotations`** override (the walk roll): after the base rotations, if `walkAnimationSpeed >= 0.01`: `u = (walkPos + 6) mod 13`; `roll = (|u - 6.5| - 3.25) / 3.25`; rotate about Z by `6.5 * roll` degrees. (No roll when `walkAnimationSpeed < 0.01`, compared as a double.)

**Layers**, in order:
- `IronGolemCrackinessLayer`: draws the golem's own model with a crack texture, via `renderColoredCutoutModel`, sub-order 1, unless the state is invisible or `crackiness == NONE`. Textures: LOW `textures/entity/iron_golem/iron_golem_crackiness_low.png`, MEDIUM `..._medium.png`, HIGH `..._high.png`. `Crackiness.byFraction(f)` with `f = health / maxHealth` and the golem thresholds (low 0.75, medium 0.5, high 0.25): `f < 0.25` HIGH; else `f < 0.5` MEDIUM; else `f < 0.75` LOW; else NONE. (The wolf-armor table of the same class is `0.95, 0.69, 0.32`, used elsewhere.) Taking damage that changes the level plays the golem damage sound on the server.
- `IronGolemFlowerLayer`: when `flowerBlock` is not empty: push; the right arm's translate-and-rotate; translate `(-1.1875, 1.0625, -0.9375)`; translate `(0.5, 0.5, 0.5)`; scale 0.5; rotate X -90 deg; translate `(-0.5, -0.5, -0.5)`; draw the block model with `NO_OVERLAY`; pop.

Examples (`v = 1`): `w = 0`: `T(0, 13) = 1`, right leg `xRot = -1.5`, left leg 1.5, right arm 1.3, left arm -1.7; roll: `u = 6`, `(0.5 - 3.25) / 3.25 = -0.846`, rotation -5.5 deg. `w = 6.5`: `T = -1`: right leg 1.5, left leg -1.5, right arm -1.7, left arm 1.3; roll `u = 12.5`, `+0.846`, +5.5 deg. Offering a flower: `F = 35` gives `T(35, 70) = -1` and right arm `xRot = -0.825`; `F = 70` gives `T = 1` and `xRot = -0.775`.

---

## 8. Snow golem

`SnowGolemModel`, texture 64 x 64, unscaled, root pose zero. All cuboids carry grow -0.5.

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| head | root | off (0, 4, 0) | tex (0, 0), origin (-4, -8, -4), size (8, 8, 8) |
| left_arm | root | off (5, 6, 1), rot (0, 0, 1) | tex (32, 0), origin (-1, 0, -1), size (12, 2, 2) |
| right_arm | root | off (-5, 6, -1), rot (0, 3.1415927, -1) | tex (32, 0), origin (-1, 0, -1), size (12, 2, 2) |
| upper_body | root | off (0, 13, 0) | tex (0, 16), origin (-5, -10, -5), size (10, 10, 10) |
| lower_body | root | off (0, 24, 0) | tex (0, 36), origin (-6, -12, -6), size (12, 12, 12) |

5 cuboids (the arm stick is built once and used by both arms).

**`setupAnim`** (the state is a plain `LivingEntityRenderState`): `head.yRot`, `head.xRot` from the state; `upper_body.yRot = yRot * D * 0.25`; with `s = sin(upper_body.yRot)`, `c = cos(upper_body.yRot)`: `left_arm.yRot = upper_body.yRot`; `right_arm.yRot = upper_body.yRot + pi`; `left_arm.x = c * 5`, `left_arm.z = -s * 5`; `right_arm.x = -c * 5`, `right_arm.z = s * 5`.

**`SnowGolemRenderer`**: shadow 0.5, texture `textures/entity/snow_golem/snow_golem.png`; state adds `headBlock` = the default state of the carved pumpkin when `SnowGolem.hasPumpkin()`, else cleared. **`SnowGolemHeadLayer`**: skip when `headBlock` is empty, or when the state is invisible and not glowing. Push; the head part's translate-and-rotate; translate `(0, -0.34375, 0)`; rotate Y 180 deg; scale `(0.625, -0.625, -0.625)`; translate `(-0.5, -0.5, -0.5)`; draw the block model with the entity's overlay (`getOverlayCoords(state, 0)`), outline only when glowing and invisible; pop. The model is a `HeadedModel` (head part).

Example: head yaw 40 deg relative to the body: `upper_body.yRot = 40 D * 0.25 = 0.17453`, `left_arm.x = 4.924`, `left_arm.z = -0.868`, `right_arm.x = -4.924`, `right_arm.z = 0.868`, right arm `yRot = 3.3161`.

---

## 9. Copper golem

### 9.1 `CopperGolemModel` meshes, texture 64 x 64

The entity layer (`COPPER_GOLEM`) is built with the root pose translated by `(0, 24, 0)`. The three statue pose layers have their root translated by `(0, 0, 0)` (no translation: their coordinates are absolute).

**Standing / entity layer** (also `COPPER_GOLEM`, statue `STANDING`):

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| body | root | off (0, -5, 0) | tex (0, 15), origin (-4, -6, -3), size (8, 6, 6) |
| head | body | off (0, -6, 0) | (a) tex (0, 0), origin (-4, -5, -5), size (8, 5, 10), grow 0.015; (b) tex (56, 0), origin (-1, -2, -6), size (2, 3, 2) (nose); (c) tex (37, 8), origin (-1, -9, -1), size (2, 4, 2), grow -0.015 (antenna stem); (d) tex (37, 0), origin (-2, -13, -2), size (4, 4, 4), grow -0.015 (antenna knob) |
| right_arm | body | off (-4, -6, 0) | tex (36, 16), origin (-3, -1, -2), size (3, 10, 4) |
| left_arm | body | off (4, -6, 0) | tex (50, 16), origin (0, -1, -2), size (3, 10, 4) |
| right_leg | root | off (0, -5, 0) | tex (0, 27), origin (-4, 0, -2), size (4, 5, 4) |
| left_leg | root | off (0, -5, 0) | tex (16, 27), origin (0, 0, -2), size (4, 5, 4) |

9 cuboids. The model has the walk, walk-with-item, idle and four chest-interaction keyframe animations baked at construction (9.2).

**Running pose layer** (`COPPER_GOLEM_RUNNING`), root offset 0:

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| body | root | off (-1.064, -5, 0) | none |
| body_r1 | body | off (1.1, 0.1, 0.7), rot (0.1204, -0.0064, -0.0779) | tex (0, 15), origin (-4.02, -6.116, -3.5), size (8, 6, 6) |
| head | body | off (0.7, -5.6, -1.8) | (a) tex (0, 0), origin (-4, -5.1, -5), size (8, 5, 10); (b) tex (56, 0), origin (-1.02, -2.1, -6), size (2, 3, 2); (c) tex (37, 8), origin (-1.02, -9.1, -1), size (2, 4, 2), grow -0.015; (d) tex (37, 0), origin (-2, -13.1, -2), size (4, 4, 4), grow -0.015 |
| right_arm | body | off (-4, -6, 0) | none |
| right_arm_r1 | right_arm | off (0.7, -0.248, -1.62), rot (1.0036, 0, 0) | tex (36, 16), origin (-3.052, -1.11, -2.036), size (3, 10, 4) |
| left_arm | body | off (4, -6, 0) | none |
| left_arm_r1 | left_arm | off (0.732, 0, 0), rot (-0.8715, -0.0535, -0.0449) | tex (50, 16), origin (0.032, -1.1, -2), size (3, 10, 4) |
| right_leg | root | off (-3.064, -5, 0) | none |
| right_leg_r1 | right_leg | off (1.048, 0, -0.9), rot (-0.8727, 0, 0) | tex (0, 27), origin (-1.856, -0.1, -1.09), size (4, 5, 4) |
| left_leg | root | off (0.936, -5, 0) | none |
| left_leg_r1 | left_leg | off (1, 0, 0), rot (0.7854, 0, 0) | tex (16, 27), origin (-2.088, -0.1, -2), size (4, 5, 4) |

**Sitting pose layer** (`COPPER_GOLEM_SITTING`), root offset 0:

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| body | root | off (0, -3, 2.325) | (a) tex (3, 19), origin (-3, -4, -4.525), size (6, 1, 6); (b) tex (0, 15), origin (-4, -3, -3.525), size (8, 6, 6) |
| body_r1 | body | off (0, -1, -4.325), rot (0, 0, -3.1416) | tex (3, 18), origin (-4, -3, -2.2), size (8, 6, 3) |
| head | body | off (0, -6, -0.2) | (a) tex (37, 8), origin (-1, -7, -3.3), size (2, 4, 2), grow -0.015; (b) tex (37, 0), origin (-2, -11, -4.3), size (4, 4, 4), grow -0.015; (c) tex (0, 0), origin (-4, -3, -7.325), size (8, 5, 10); (d) tex (56, 0), origin (-1, 0, -8.325), size (2, 3, 2) |
| right_arm | body | off (-4, -5.6, -1.8), rot (0.4363, 0, 0) | none |
| right_arm_r1 | right_arm | off (0, 0.0893, 0.1198), rot (-1.0472, 0, 0) | tex (36, 16), origin (-3.075, -0.9733, -1.9966), size (3, 10, 4) |
| left_arm | body | off (4, -5.6, -1.7), rot (0.4363, 0, 0) | none |
| left_arm_r1 | left_arm | off (0, -0.0015, -0.0808), rot (-1.0472, 0, 0) | tex (50, 16), origin (0.075, -1.0443, -1.8997), size (3, 10, 4) |
| right_leg | root | off (-2.1, -2.1, -2.075) | none |
| right_leg_r1 | right_leg | off (0.05, -1.9, 1.075), rot (-1.5708, 0, 0) | tex (0, 27), origin (-2, 0.975, 0), size (4, 5, 4) |
| left_leg | root | off (2, -2, -2.075) | none |
| left_leg_r1 | left_leg | off (0.05, -2, 1.075), rot (-1.5708, 0, 0) | tex (16, 27), origin (-2, 0.975, 0), size (4, 5, 4) |

**Star pose layer** (`COPPER_GOLEM_STAR`), root offset 0:

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| body | root | off (0, -5, 0) | tex (0, 15), origin (-4, -6, -3), size (8, 6, 6) |
| head | body | off (0, -6, 0) | (a) tex (0, 0), origin (-4, -5, -5), size (8, 5, 10); (b) tex (56, 0), origin (-1, -2, -6), size (2, 3, 2); (c) tex (37, 8), origin (-1, -9, -1), size (2, 4, 2), grow -0.015; (d) tex (37, 0), origin (-2, -13, -2), size (4, 4, 4), grow -0.015 |
| right_arm | body | off (-4, -6, 0) | none |
| right_arm_r1 | right_arm | off (1, 1, 0), rot (0, 0, 1.9199) | tex (36, 16), origin (-1.5, -5, -2), size (3, 10, 4) |
| rightItem | right_arm_r1 | off (-1, 7.4, -1) | none |
| left_arm | body | off (4, -6, 0) | none |
| left_arm_r1 | left_arm | off (-1, 1, 0), rot (0, 0, -1.9199) | tex (50, 16), origin (-1.5, -5, -2), size (3, 10, 4) |
| right_leg | root | off (-3, -5, 0) | none |
| right_leg_r1 | right_leg | off (0.35, 2, 0.01), rot (0, 0, 0.2618) | tex (0, 27), origin (-2, -2.5, -2), size (4, 5, 4) |
| left_leg | root | off (1, -5, 0) | none |
| left_leg_r1 | left_leg | off (1.65, 2, 0), rot (0, 0, -0.2618) | tex (16, 27), origin (-2, -2.5, -2), size (4, 5, 4) |

Cuboid counts: running 9, sitting 11, star 9. The layer `COPPER_GOLEM_EYES` is the entity layer after `retainPartsAndChildren({eyes})`; the entity layer has no part named `eyes`, so that layer would be empty; the renderer does not use it (9.4, Open question 7).

### 9.2 `CopperGolemModel.setupAnim` and the animation set

Animations (`CopperGolemAnimation`, Appendix A) baked on the entity layer: walk (`COPPER_GOLEM_WALK`), walk-with-item (`COPPER_GOLEM_WALK_ITEM`), idle (`COPPER_GOLEM_IDLE`), and four interaction animations: `interactionGetItem` = `COPPER_GOLEM_CHEST_INTERACTION_NOITEM_GET`, `interactionGetNoItem` = `..._NOITEM_NOGET`, `interactionDropItem` = `..._ITEM_DROP`, `interactionDropNoItem` = `..._ITEM_NODROP`.

1. Reset; `head.xRot = xRot * D`, `head.yRot = yRot * D`.
2. If both hand item states are empty: walk animation `applyWalk(walkPos, walkSpeed, 2, 2.5)` (`ms = walkPos * 100`, scale `min(walkSpeed * 2.5, 1)`). Else: walk-with-item `applyWalk(..., 2, 2.5)`, then `poseHeldItemArmsIfStill`: `right_arm.xRot = min(right_arm.xRot, -0.87266463)`, `left_arm.xRot = min(left_arm.xRot, -0.87266463)`, `right_arm.yRot = min(right_arm.yRot, -0.1134464)`, `left_arm.yRot = max(left_arm.yRot, 0.1134464)`, `right_arm.zRot = min(right_arm.zRot, -0.064577185)`, `left_arm.zRot = max(left_arm.zRot, 0.064577185)` (raises the arms so a carried item shows even when still).
3. Then the five state-driven animations in the order idle, get-item, get-no-item, drop-item, drop-no-item, each `apply(state, ageInTicks)`; the states are copies of the entity's animation states (which of them runs is driven by the entity, 44-3 §8).

### 9.3 Hand, head and antenna transforms

- `translateToHand(state, arm, pose)`: root, body, then the chosen arm part translate-and-rotate; then if the golem state is `IDLE`: rotate Y by -90 deg (right) or +90 deg (left), translate `(0, 0, 0.125)`; otherwise scale 0.55 and translate `(-0.125, 0.3125, -0.1875)`.
- `translateToHead(pose)` (used by the custom-head layer): body, head translate-and-rotate; translate `(0, 0.125, 0)`; scale 1.0625.
- `applyBlockOnAntennaTransform(pose)`: root, body, head translate-and-rotate; translate `(0, -1.75, 0)` (blocks; model y is down, so 1.75 blocks up from the head pivot).

### 9.4 `CopperGolemRenderer`

| Item | Value |
|---|---|
| Base | `MobRenderer`, shadow 0.5 |
| Texture | by the weathering state of the golem (`WeatheringCopper` UNAFFECTED, EXPOSED, WEATHERED, OXIDIZED), from `CopperGolemOxidationLevels`: `textures/entity/copper_golem/copper_golem.png`, `..._exposed.png`, `..._weathered.png`, `..._oxidized.png`. Eye textures: `copper_golem_eyes.png`, `copper_golem_eyes_exposed.png`, `..._weathered.png`, `..._oxidized.png`. The same table gives four sounds per level (spin head, hurt, death, step); UNAFFECTED and EXPOSED share the unweathered sounds, WEATHERED and OXIDIZED have their own |
| State | armed state + `weathering`, `copperGolemState` (default `IDLE`), five animation states, `blockOnAntenna` |
| `blockOnAntenna` | the block item in the antenna equipment slot; when it is a block item: its block's default state with the item's `BLOCK_STATE` component properties applied; else cleared |
| Layers, in order | (1) emissive eyes: `LivingEntityEmissiveLayer` with a **second instance of the body model (`COPPER_GOLEM` layer, not the eyes layer)**, the eye texture of the weathering level, alpha 1 constant, render type `eyes(texture)`, drawn at order 1 with overlay `getOverlayCoords(state, 0)`, skipped when the state is invisible; (2) `ItemInHandLayer`; (3) `BlockDecorationLayer` (the antenna block); (4) `CustomHeadLayer` (default transforms) |
| `BlockDecorationLayer` | when the block state is not empty: push; apply `applyBlockOnAntennaTransform`; multiply by the fixed matrix `M` = translation `(-0.5, 0, -0.5)` composed with a 180 deg rotation about Z around the centre `(0.5, 0.5, 0.5)` (so a unit-cube point `(x, y, z)` goes to `(0.5 - x, 1 - y, z - 0.5)`); draw the block model with `NO_OVERLAY`; pop. Net effect: the block stands on the antenna knob, about 1 pixel overlapping it |

### 9.5 Statue (`CopperGolemStatueBlockRenderer`, `CopperGolemStatueModel`, `CopperGolemStatueSpecialRenderer`)

The block entity renderer holds four models, keyed by the block's `POSE` property: STANDING (`COPPER_GOLEM` layer), RUNNING, SITTING, STAR (the pose layers above). Each is a plain `Model` whose `setupAnim` sets `root.y = 0` and `root.zRot = 3.1415927` (the statue is flipped upside down about Z in model space, which, with the flipped y axis of the entity convention, appears upright). Drawing: push; multiply by the facing transform (translation `(0.5, 0, 0.5)` then a rotation about Y by the negative (a float negation) of `toYRot()` of the opposite of the block's FACING, in degrees). `Direction.toYRot()` is `(data2d & 3) * 90` with `data2d` SOUTH 0, WEST 1, NORTH 2, EAST 3 (read), i.e. south 0, west 90, north 180, east 270 degrees. Examples: FACING north, opposite south, rotation 0 degrees; FACING east, opposite west, -90; FACING south, opposite north, -180; FACING west, opposite east, -270; draw the model with the texture of the oxidation level (the same `texture()` as the entity, from the block's weathering state, UNAFFECTED when the block is not a weathering statue), the block's light, `NO_OVERLAY`; if a break-progress overlay exists, draw the crumbling overlay at order 1; pop. The item form uses the special renderer with the standing model and a texture chosen by the item model (data), drawn with the supplied light/overlay.

---

## 10. Creaking

`CreakingModel`, texture 64 x 64, unscaled. The model root is the layer root; the part tree is `root > upper_body > head, body, right_arm, left_arm` and `root > left_leg, right_leg`.

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| root | layer root | off (0, 24, 0) | none |
| upper_body | root | off (-1, -19, 0) | none |
| head | upper_body | off (-3, -11, 0) | (a) tex (0, 0), origin (-3, -10, -3), size (6, 10, 6); (b) tex (28, 31), origin (-3, -13, -3), size (6, 3, 6); (c) tex (12, 40), origin (3, -13, 0), size (9, 14, 0); (d) tex (34, 12), origin (-12, -14, 0), size (9, 14, 0) |
| body | upper_body | off (0, -7, 1) | (a) tex (0, 16), origin (0, -3, -3), size (6, 13, 5); (b) tex (24, 0), origin (-6, -4, -3), size (6, 7, 5) |
| right_arm | upper_body | off (-7, -9.5, 1.5) | (a) tex (22, 13), origin (-2, -1.5, -1.5), size (3, 21, 3); (b) tex (46, 0), origin (-2, 19.5, -1.5), size (3, 4, 3) |
| left_arm | upper_body | off (6, -9, 0.5) | (a) tex (30, 40), origin (0, -1, -1.5), size (3, 16, 3); (b) tex (52, 12), origin (0, -5, -1.5), size (3, 4, 3); (c) tex (52, 19), origin (0, 15, -1.5), size (3, 4, 3) |
| left_leg | root | off (1.5, -16, 0.5) | (a) tex (42, 40), origin (-1.5, 0, -1.5), size (3, 16, 3); (b) tex (45, 55), origin (-1.5, 15.7, -4.5), size (5, 0, 9) |
| right_leg | root | off (-1, -17.5, 0.5) | (a) tex (0, 34), origin (-3, -1.5, -1.5), size (3, 19, 3); (b) tex (45, 46), origin (-5, 17.2, -4.5), size (5, 0, 9); (c) tex (12, 34), origin (-3, -4.5, -1.5), size (3, 3, 3) |

16 cuboids. Cuboids (c) and (d) of the head and the foot plates are zero-thickness planes (the "wooden wings" and feet).

**Eyes layer** (`CREAKING_EYES`): the same mesh after `retainExactParts({head})`: only the head's own cuboids remain.

**`setupAnim`**: `head.xRot = xRot * D`, `head.yRot = yRot * D`. If `canMove`: `walkAnimation.applyWalk(walkPos, walkSpeed, 1, 1)` (so `ms = walkPos * 50`, scale `min(walkSpeed, 1)`). Always: attack, invulnerable and death animations applied by their states (`apply(state, ageInTicks)`). The animations (`CreakingAnimation`, Appendix A): `CREAKING_WALK` (1.125 s, looping), `CREAKING_ATTACK` (0.7083 s), `CREAKING_INVULNERABLE` (0.2917 s, not looping), `CREAKING_DEATH` (2.25 s, not looping).

**`CreakingRenderer`**: shadow 0.6, texture `textures/entity/creaking/creaking.png`, eyes texture `textures/entity/creaking/creaking_eyes.png`. One layer: `LivingEntityEmissiveLayer` with the eyes model, eyes texture, render type `eyes(texture)`, `alwaysVisible = true`, order 1, and an alpha function that returns 1 when `eyesGlowing` else 0 (the layer draws nothing for alpha <= 1e-5). State: three animation states copied from the entity; `canMove`; `eyesGlowing = isTearingDown ? hasGlowingEyes : isActive`; when `isTearingDown`, `deathTime = 0` and `hasRedOverlay = false` (no death roll and no red flash: the creaking dies by its own animation).

---

## 11. Allay

`AllayModel`, texture 32 x 32, render type `entityTranslucent`. The model root is the layer's child `root`.

| Part | Parent | Pose | Cuboids |
|---|---|---|---|
| root | layer root | off (0, 23.5, 0) | none |
| head | root | off (0, -3.99, 0) | tex (0, 0), origin (-2.5, -5, -2.5), size (5, 5, 5) |
| body | root | off (0, -4, 0) | (a) tex (0, 10), origin (-1.5, 0, -1), size (3, 4, 2); (b) tex (0, 16), origin (-1.5, 0, -1), size (3, 5, 2), grow -0.2 |
| right_arm | body | off (-1.75, 0.5, 0) | tex (23, 0), origin (-0.75, -0.5, -1), size (1, 4, 2), grow -0.01 |
| left_arm | body | off (1.75, 0.5, 0) | tex (23, 6), origin (-0.25, -0.5, -1), size (1, 4, 2), grow -0.01 |
| right_wing | body | off (-0.5, 0, 0.6) | tex (16, 14), origin (0, 1, 0), size (0, 5, 8) |
| left_wing | body | off (0.5, 0, 0.6) | tex (16, 14), origin (0, 1, 0), size (0, 5, 8) (not mirrored) |

7 cuboids.

**`setupAnim`** (`v` = walkAnimationSpeed, `w` = walkAnimationPos, `age`; `Mth.cos` table unless said):
1. `f4 = age * 20 * D + w`; `flap = cos(f4) * pi * 0.15 + v`; `bob = age * 9 * D`; `m = min(v / 0.3, 1)` (movement factor); `r = 1 - m` (rest factor); `h` = `holdingAnimationProgress` (0..1).
2. If dancing: `d = age * 8 * D + v`; `rootZ = cos(d) * 16 * D`; `sp` = `spinningProgress`; `headZ = cos(d) * 14 * D`; `headY = cos(d) * 30 * D`; `root.yRot = isSpinning ? 12.566371 * sp : (its reset value 0)`; `root.zRot = rootZ * (1 - sp)`; `head.yRot = headY * (1 - sp)`; `head.zRot = headZ * (1 - sp)`. Else: `head.xRot = xRot * D`, `head.yRot = yRot * D`.
3. `right_wing.xRot = 0.43633232 * (1 - m)`, `right_wing.yRot = -0.7853982 + flap`; `left_wing.xRot = 0.43633232 * (1 - m)`, `left_wing.yRot = 0.7853982 - flap`.
4. `body.xRot = m * 0.7853982`.
5. `armX = h * lerp(m, -1.0471976, -1.134464)` (`lerp(t, a, b) = a + t (b - a)`); `root.y = root.y + Math.cos(bob) * 0.25 * r`; both arms `xRot = armX`.
6. `k = r * (1 - h)`; `z = 0.43633232 - cos(bob + 4.712389) * pi * 0.075 * k`; `left_arm.zRot = -z`, `right_arm.zRot = z`; `right_arm.yRot = 0.27925268 * h`, `left_arm.yRot = -0.27925268 * h`.

**`translateToHand(state, arm, pose)`**: root, body translate-and-rotate; translate `(0, 0.0625, 0.1875)`; rotate X by the **right arm's current `xRot`** (for either hand); scale 0.7; translate `(0.0625, 0, 0)`.

**`AllayRenderer`**: shadow 0.4, layer `ItemInHandLayer`, texture `textures/entity/allay/allay.png`, block-light level always 15. State: armed state + `isDancing`, `isSpinning`, `spinningProgress(partial)`, `holdingAnimationProgress(partial)` (entity values, 19 §15).

Examples. Hovering at rest (`age = 0`, `v = 0`, `h = 0`, not dancing): `f4 = 0`, `flap = 0.4712`, so `right_wing.yRot = -0.3142`, `left_wing.yRot = 0.3142`; `m = 0`, `r = 1`: `body.xRot = 0`, `root.y = 23.5 + 0.25 = 23.75`; `k = 1`, `z = 0.43633232 - cos(4.712389) * pi * 0.075 = 0.4363` (cos of 3 pi / 2 is 0), so the arms' `zRot` is +0.4363 (right) and -0.4363 (left). Flying fast (`v = 0.3` or more): `m = 1`: `body.xRot = 0.7854`, wings `xRot = 0`, with `h = 1` the arms `xRot = -1.134464`.

---

## 12. Master table and arm/item rules

| Entity type | Renderer | Layer(s) of the model | Shadow | Texture (code asks for) | Item layer |
|---|---|---|---|---|---|
| `villager` | `VillagerRenderer` | adult `VILLAGER`, baby `VILLAGER_BABY`; overlay models `VILLAGER_NO_HAT`, `VILLAGER_BABY_NO_HAT` | 0.5 (baby x 0.5 more) | `villager/villager.png`, `villager/villager_baby.png` + overlays | `CrossedArmsItemLayer` (GROUND item), `CustomHeadLayer` |
| `wandering_trader` | `WanderingTraderRenderer` | `WANDERING_TRADER` | 0.5 | `wandering_trader/wandering_trader.png` | `CrossedArmsItemLayer`, `CustomHeadLayer` |
| `zombie_villager` | `ZombieVillagerRenderer` | adult / baby / no-hat variants / armor sets | 0.5 | `zombie_villager/zombie_villager.png`, `..._baby.png` + overlays | humanoid `ItemInHandLayer`, wings, custom head |
| `witch` | `WitchRenderer` | `WITCH` (villager mesh edited, scaled 0.9375) | 0.5 | `witch/witch.png` | `WitchItemLayer` |
| `pillager` | `PillagerRenderer` | `PILLAGER` (= illager mesh x 0.9375) | 0.5 | `illager/pillager.png` | `ItemInHandLayer` always |
| `vindicator` | `VindicatorRenderer` | `VINDICATOR` | 0.5 | `illager/vindicator.png` | when aggressive |
| `evoker` | `EvokerRenderer` | `EVOKER` | 0.5 | `illager/evoker.png` | when casting |
| `illusioner` | `IllusionerRenderer` | `ILLUSIONER` (hat visible) | 0.5 | `illager/illusioner.png` | when casting or aggressive |
| `evoker_fangs` | `EvokerFangsRenderer` | `EVOKER_FANGS` | none | `illager/evoker_fangs.png` | none |
| `ravager` | `RavagerRenderer` | `RAVAGER` | 1.1 | `illager/ravager.png` | none |
| `vex` | `VexRenderer` | `VEX` | 0.3 | `illager/vex.png`, `illager/vex_charging.png` | `ItemInHandLayer` |
| `iron_golem` | `IronGolemRenderer` | `IRON_GOLEM` | 0.7 | `iron_golem/iron_golem.png` + 3 crack textures | none (flower layer) |
| `snow_golem` | `SnowGolemRenderer` | `SNOW_GOLEM` | 0.5 | `snow_golem/snow_golem.png` | none (head block layer) |
| `copper_golem` | `CopperGolemRenderer` | `COPPER_GOLEM` (+ 3 statue pose layers) | 0.5 | `copper_golem/copper_golem*.png` (8 files) | `ItemInHandLayer`, antenna block, custom head |
| `creaking` | `CreakingRenderer` | `CREAKING`, `CREAKING_EYES` | 0.6 | `creaking/creaking.png`, `creaking/creaking_eyes.png` | none |
| `allay` | `AllayRenderer` | `ALLAY` | 0.4 | `allay/allay.png` | `ItemInHandLayer` |

(All texture paths are under `textures/entity/`.)

### 12.1 Per-entity record fields (34-1 §9)

Read in `EntityTypes` (the registration of each type) and the renderer classes this round; ids, boxes and eye heights agree with 21 §2. Eye height "default" is the builder default, 0.85 times the box height (21 §2).

| Entity type | numeric_id | hitbox (w x h) | eye_height | riding offset | passenger attachments |
|---|---|---|---|---|---|
| `villager` | 143 | 0.6 x 1.95 | 1.62 | none set | none set |
| `wandering_trader` | 145 | 0.6 x 1.95 | 1.62 | none set | none set |
| `zombie_villager` | 157 | 0.6 x 1.95 | 1.74 | -0.7 | one value, 2.125 |
| `witch` | 148 | 0.6 x 1.95 | 1.62 | none set | one value, 2.2625 |
| `pillager` | 104 | 0.6 x 1.95 | default (1.6575) | -0.6 | one value, 2.0 |
| `vindicator` | 144 | 0.6 x 1.95 | default | -0.6 | one value, 2.0 |
| `evoker` | 47 | 0.6 x 1.95 | default | -0.6 | one value, 2.0 |
| `illusioner` | 69 | 0.6 x 1.95 | default | -0.6 | one value, 2.0 |
| `evoker_fangs` | 48 | 0.5 x 0.8 | default (0.68) | none set | none set |
| `ravager` | 112 | 1.95 x 2.2 | default (1.87) | none set | one vector (0, 2.2625, -0.0625) |
| `vex` | 142 | 0.4 x 0.8 | 0.51875 | 0.04 | one value, 0.7375 |
| `iron_golem` | 71 | 1.4 x 2.7 | default (2.295) | none set | none set |
| `snow_golem` | 124 | 0.7 x 1.9 | 1.7 | none set | none set |
| `copper_golem` | 28 | 0.49 x 0.98 | 0.8125 | none set | none set |
| `creaking` | 31 | 0.9 x 2.7 | 2.3 | none set | none set |
| `allay` | 2 | 0.35 x 0.6 | 0.36 | 0.04 | none set |

- `passengerAttachments` is given as a one-element float array for most types and as a `Vec3` for the ravager. The convention is that of 18 §1.1.1 (read there from the same builder calls): a float is the height of one seat at `(0, y, 0)` above the entity origin, the `Vec3` form is a full (x, y, z) seat offset with z positive toward the entity's front, and `ridingOffset` is added to the y of the riding entity's own position when it rides (vehicle seat y plus `ridingOffset`). Worked example: a pillager (`ridingOffset` -0.6) seated on a zombie villager (seat 2.125) standing at feet height Y has its feet at Y + 2.125 - 0.6 = Y + 1.525; a zombie villager on a vehicle whose seat is at height S has its feet at S - 0.7. The riding code itself is specified in 18 and not repeated here. Baby villager and baby zombie villager boxes are in 19 §22 and 20 §4.2 (not re-read).
- `name_tag_offset`: no `nameTagOffset`, `vehicleAttachment` or `attach` call is made in the registration of any of these 16 types, so the generic name tag rule of 34-1 §7.2 applies. The `ridingOffset` column is the builder value in blocks, applied as described above.
- `shadow_strength`: none of the 17 renderers of this document (the 16 above plus the shared `IllagerRenderer`) sets a shadow strength, so the default of 34-1 §9 applies; base radii are in the table above. The baby villager's extra 0.5 is in 1.4.
- Leash and fire: no renderer of this document overrides the leash offset or the fire (flame) handling, so 34-1 §7.3 and §7.4 apply unchanged. The renderer overrides that were read are exactly those named in this document: `getShadowRadius` (villager), `isShaking` (zombie villager), `isBodyVisible` and `getBoundingBoxForCulling` (illusioner), `getBlockLightLevel` (vex, allay), `setupRotations` (iron golem), besides the state creation and extraction methods.
- Ids: model layers are the `ModelLayers` names of the master table, in the stable text form of 34-1 §4.2 (full list in 34-1 Appendix A); animation definitions are `CopperGolemAnimation.<FIELD>` and `CreakingAnimation.<FIELD>` (names in Appendix A below; 34-1 §4.4).

Item and arm rules, in one place:

| Model | Held-item transform | Arm pose source |
|---|---|---|
| Villager, wandering trader | crossed-arms layer: `translateToArms` (root, `arms`), rotX 0.75 rad, scale 1.07, translate (0, 0.13, -0.34), rotX pi | none (arms fixed) |
| Witch | potion: head and nose chain (3.3); other items: as the villager | none |
| Illagers | `ItemInHandLayer` with `translateToHand` = root + arm part | 4.2, 4.3 |
| Vex | root, body, arm, scale 0.55, translate (+-0.046875, -0.15625, 0.078125) | charging pose 6 |
| Copper golem | root, body, arm, then the IDLE or non-IDLE branch of 9.3 | animations |
| Allay | 11 | wing/arm math of 11 |
| Zombie villager | humanoid hand transform (12 §7.5, framework sibling) | zombie arms 2.3 |

---

## 13. Worked examples (collected)

1. **Entity-space heights.** Villager (0.9375 model): head top `1.4071875 + 0.05859375 * 10 = 1.993125` above the entity origin; feet `0.0009375`. The witch has the same figures (its layer is scaled, 0.1 item 7). Baby villager (unscaled): head top `1.501 - (16 - 8) / 16 = 1.001` (pivot y 16, cuboid top at -8).
2. **Profession overlay choice.** Profession smith with `hat: none`: type overlay uses the full model (the type texture's head shows); profession overlay and level overlay follow. Profession with `hat: full`: the type overlay uses the no-hat model (no head), the profession texture draws the head. Baby: the type overlay only, with the `baby` folder, and no profession or level overlay.
3. **Evoker fangs** table in 4.8; **ravager**, **iron golem**, **snow golem**, **vex**, **allay**, **witch**, **swingWeaponDown** examples in their sections; the keyframe sampling example in 0.2.
4. **Creaking walk at `walkPos = 1`, `walkSpeed = 1`**: `ms = 50`, `t = 0.05`, `k = 1`. `upper_body` rotation channel (first keys 0:(26.8802, -23.399, -9.0616) and 0.125:(-2.2093, 5.9119, 0.0675); every keyframe of `CreakingAnimation` is `LINEAR`, as Appendix A shows): `F = 1`, `i = 0`, `j = 1`, `p = 0.05 / 0.125 = 0.4`. Added rotation in degrees: `(26.8802 + 0.4 * (-2.2093 - 26.8802), -23.399 + 0.4 * (5.9119 + 23.399), -9.0616 + 0.4 * (0.0675 + 9.0616)) = (15.244, -11.675, -5.410)`, times `k` = 1, converted to radians by the engine (the vector is stored by `degreeVec`).
5. **Illusioner invisible**: for offsets `(0, 0, 0)` and `(1, 0, 0)` at age 0 the mob is drawn twice, translated by `(cos(0) * 0.025, cos(0) * 0.0125, cos(0) * 0.025) = (0.025, 0.0125, 0.025)` (table cosine) and `(1 + cos(1) * 0.025, cos(1) * 0.0125, cos(1) * 0.025)`.

---

## 14. Validation

A reference render is the final test; these checks can be made from the document alone.

| # | Check | Expected |
|---|---|---|
| 1 | Cuboid counts of the layer methods | villager 11, baby villager 11, zombie villager 10, baby zombie villager 10, witch own 6 (+ inherited nose and hat_rim), illager 12, fangs 3 (two jaws share one box), ravager 12, vex 7, iron golem 8, snow golem 5, copper golem 9 (running 9, sitting 11, star 9), creaking 16, allay 7 |
| 2 | Texture sizes | villager family 64x64; witch 64x128; fangs 64x32; ravager 128x128; vex 32x32; iron golem 128x128; snow golem 64x64; copper golem 64x64; creaking 64x64; allay 32x32 |
| 3 | Scaled layers | exactly eight layers: `VILLAGER`, `VILLAGER_NO_HAT`, `WANDERING_TRADER`, `PILLAGER`, `VINDICATOR`, `EVOKER`, `ILLUSIONER` and `WITCH` carry the 0.9375 root (offset y 1.501); the baby villager and all zombie villager layers do not |
| 4 | Feet on the ground | a standing villager's or witch's leg soles (model y 24) are at 0.0009375 above the origin |
| 5 | No-hat model | draws no head cuboid; hat visibility of the illager model is false except the illusioner |
| 6 | `triangleWave(0, 13)` | 1; `(3.25, 13)` 0; `(6.5, 13)` -1 |
| 7 | Fangs at `p = 0` | not drawn; at `p = 0.5` jaw angles both pi |
| 8 | Keyframe sampling at a keyframe time | the value of that keyframe (times the scale) |
| 9 | Copper golem walk with equal `walkPos` | `ms = walkPos * 100`; creaking `ms = walkPos * 50` |
| 10 | Eyes layers | creaking: head cuboids only, draws only while `eyesGlowing`; copper golem: whole body with the eye texture, render type eyes |
| 11 | Arm visibility (illager) | `CROSSED`: only `arms`; any other pose: only `left_arm` and `right_arm` |
| 12 | Crack levels | health fraction 0.24 HIGH, 0.49 MEDIUM, 0.74 LOW, 0.75 NONE |
| 13 | Block light | vex and allay always use block light 15 |

---

## Appendix A. Keyframe data (code-defined)

Time in seconds; a keyframe is `time:(x, y, z)`. Rotation channels are degrees, position channels are pixels (the engine negates y), scale channels are scale factors (the engine stores factor - 1). `~` after a keyframe marks `CATMULLROM`; unmarked keyframes are `LINEAR`. All keyframes have equal pre and post vectors. Sampling and application rules: §0.2. The tables were generated from the static initializers of `CopperGolemAnimation` and `CreakingAnimation` (float constants printed as read; values like `-4.4E-4f` are written as -0.00044).


**`COPPER_GOLEM_WALK`**: length 0.8333 s, looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| body | rotation | 0:(10,15,0)~; 0.2083:(10,-1.87,-10)~; 0.4167:(10,-15,0)~; 0.625:(10,-0.82,10)~; 0.8333:(10,15,0)~ |
| head | rotation | 0:(-10,0,0)~; 0.2083:(-10,1.87,10)~; 0.4167:(-10,0,0)~; 0.625:(-10,0.82,-10)~; 0.8333:(-10,0,0)~ |
| right_arm | rotation | 0:(70,0,0)~; 0.4167:(-80,0,0)~; 0.8333:(70,0,0)~ |
| left_arm | rotation | 0:(-80,0,0)~; 0.4167:(70,0,0)~; 0.8333:(-80,0,0)~ |
| right_leg | rotation | 0:(-60,0,0)~; 0.4167:(60,0,0)~; 0.8333:(-60,0,0)~ |
| left_leg | rotation | 0:(60,0,0)~; 0.4167:(-60,0,0)~; 0.8333:(60,0,0)~ |

**`COPPER_GOLEM_IDLE`**: length 3.5 s, not looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| body | rotation | 0:(0,0,0); 0.125:(0,-35,0); 0.5:(0,-35,0); 0.625:(0,35,0); 1.2083:(0,35,0); 2.7083:(0,35,0); 3:(0,0,0); 3.5:(0,0,0) |
| head | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.5:(0,0,0); 0.625:(0,0,0); 1.2083:(0,0,0); 1.5:(0,300,0); 1.6667:(0,300,0); 1.75:(-25,300,0); 2.7083:(-25,300,0); 3:(0,360,0); 3.5:(0,360,0) |

**`COPPER_GOLEM_WALK_ITEM`**: length 0.8333 s, looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| body | rotation | 0:(10,7.5,0)~; 0.2083:(10,-1.87,-5)~; 0.4167:(10,-7.5,0)~; 0.625:(10,-0.82,5)~; 0.8333:(10,7.5,0)~ |
| head | rotation | 0:(-10,0,0)~; 0.2083:(-10,1.87,10)~; 0.4167:(-10,0,0)~; 0.625:(-10,0.82,-10)~; 0.8333:(-10,0,0)~ |
| right_arm | rotation | 0:(-59.78638,-6.49053,-3.76613) |
| left_arm | rotation | 0:(-59.78638,6.49053,3.76613) |
| left_arm | position | 0:(-0.21129,-0.0212,-0.07004) |
| right_leg | rotation | 0:(-30,0,0)~; 0.4167:(30,0,0)~; 0.8333:(-30,0,0)~ |
| left_leg | rotation | 0:(30,0,0)~; 0.4167:(-30,0,0)~; 0.8333:(30,0,0)~ |

**`COPPER_GOLEM_CHEST_INTERACTION_ITEM_DROP`**: length 3 s, looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| body | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(18,0,0); 0.2917:(24,0,0); 0.375:(15,0,0); 0.4167:(12.5,0,0); 0.5833:(12.5,0,0); 0.75:(12.5,0,0); 0.8333:(14.72765,-31.63886,-7.85085); 0.9167:(14.72765,-31.63886,-7.85085); 1.0417:(14.72765,-31.63886,-7.85085); 1.125:(12.40525,-0.00044,0.00829); 1.2083:(12.40525,-0.00044,0.00829); 1.2917:(13.92716,26.80536,6.38918); 1.625:(13.93,26.81,6.39); 1.6667:(21.43,26.81,6.39); 1.7917:(21.43,26.81,6.39); 1.8333:(13.93,26.81,6.39); 2.0417:(13.93,26.81,6.39); 2.125:(12.40725,0,0.00783); 2.1667:(0,0,0); 2.2917:(0,0,0); 2.375:(-7.5,0,0); 2.4167:(-10,0,0); 2.4583:(-10,0,0); 2.5417:(0,0,0); 2.625:(15,0,0); 2.6667:(17.5,0,0); 2.7083:(22.5,0,0); 2.875:(0,0,0); 3:(0,0,0) |
| body | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0.6,0); 0.4167:(0,0.5,0); 1.625:(0,0.4,0); 1.6667:(-0.01805,0.88303,-0.09783); 1.7917:(-0.01805,0.88303,-0.09783); 1.8333:(0,0.6,0); 2.0417:(0,0.6,0); 2.1667:(0,0,0); 2.2917:(0,0,0); 2.375:(0,0,-1); 2.4583:(0,0,-1); 2.5417:(0,0,0); 2.875:(0,0,0); 3:(0,0,0) |
| head | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(-20,0,0); 0.2083:(-20,0,0); 0.25:(-2.5,0,0); 0.2917:(-5,0,0); 0.375:(0,0,0); 0.4167:(0,0,0); 0.5833:(0,0,0); 0.6667:(0,-20,0); 0.75:(0,-20,0); 0.8333:(0,10,0); 1.0417:(0,10,0); 1.1667:(0,10,0); 1.2083:(0,27.5,0); 1.2917:(0,0,0); 1.4167:(0,0,0); 1.4583:(0,0,0); 1.5:(0,-2.5,0); 1.625:(0,-2.5,0); 1.6667:(9.73588,-1.93433,-3.73384); 1.7083:(9.73588,-1.93433,-3.73384); 1.7917:(10.15255,-1.93433,-3.73384); 1.8333:(17.86088,-1.93433,-3.73384); 1.875:(17.23588,-1.93433,-3.73384); 1.9167:(17.23588,-1.93433,-3.73384); 2.0417:(17.23588,-1.93433,-3.73384); 2.0833:(-0.26,-1.93,-3.73); 2.1667:(0,0,0); 2.4583:(-10,0,0); 2.5417:(-15,0,0); 2.6667:(-15,0,0); 2.7083:(-5,0,0); 2.875:(0,0,0); 3:(0,0,0) |
| head | position | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(0,-0.15451,0.47553); 0.25:(0,0,0); 0.4167:(0,0,0); 1.0417:(0,0,0); 1.1667:(0,0,0); 1.2917:(0,0,0); 1.4167:(0,0,0); 1.4583:(0,0,0); 1.5:(0,0,0); 1.625:(0,0,0); 1.6667:(-0.22438,0.82319,-1.27252); 1.875:(-0.22438,0.82319,-1.27252); 1.9167:(-0.22438,0.82319,-1.27252); 2.0417:(-0.22438,0.82319,-1.27252); 2.0833:(-0.39,0.52,-2.21); 2.1667:(0,0,0); 2.4583:(0,0,0); 2.6667:(0,0,0); 2.875:(0,0,0); 3:(0,0,0) |
| right_arm | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(-7.38733,1.29876,9.91615); 0.2917:(-7.38733,1.29876,9.91615); 0.375:(10,0,32.5); 0.4167:(-34.55418,11.73507,36.8361); 0.4583:(-117.82767,2.94538,0.22703); 0.5417:(-97.7902,0.73403,1.39387); 0.5833:(-92.79,0.73,1.39); 0.75:(-92.79,0.73,1.39); 0.8333:(-95.83405,33.18639,-0.40081); 1.5:(-95.83,33.19,-0.4); 1.5833:(-44.60123,10.14454,8.66307); 1.8333:(-4.31506,6.54961,13.21388); 2.0833:(-4.31506,6.54961,13.21388); 2.125:(-4.31506,6.54961,13.21388); 2.2083:(-113.7629,21.38835,15.48184); 2.4583:(-113.76,21.39,15.48); 2.5417:(-39.99304,7.3511,14.05666); 2.625:(68.07913,-3.61348,1.39182); 2.6667:(193.16708,-1.90441,-0.43495); 2.7083:(250.66708,-1.90441,-0.43495); 2.7917:(264.19006,-4.41519,-0.66792); 2.8333:(270.53693,16.03493,0.47968); 2.875:(319.31668,17.97846,1.34328); 2.9167:(0,-5,0); 3:(0,0,0) |
| right_arm | position | 0:(0,0,0); 0.125:(0,0,0); 0.2917:(0,0,0); 0.375:(0,0,0); 0.5833:(0,0,0); 0.75:(0,0,0); 0.8333:(0.25358,-0.20153,2.21248); 1.5:(0.25,-0.2,2.21); 1.5417:(-0.79739,-0.10573,1.70592); 1.5833:(-0.26323,-1.46323,0.66566); 1.8333:(-0.51052,-0.38088,0.79745); 2.0833:(-0.51052,-0.38088,0.79745); 2.125:(-0.51052,-0.38088,0.79745); 2.4583:(-0.51,-0.38,0.8); 2.875:(0,0,0); 3:(0,0,0) |
| left_arm | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(25,0,-37.5); 0.25:(-21.59341,-12.60837,-45.69252); 0.2917:(-120.7755,-5.21988,-2.02064); 0.375:(-98.27419,-1.79323,-1.15048); 0.4167:(-93.27,-1.79,-1.15); 0.5417:(-93.27419,-1.79323,-1.15048); 0.5833:(-93.55693,-22.3224,3.64383); 0.7083:(-93.55693,-22.3224,3.64383); 1.1667:(-93.55693,-22.3224,3.64383); 1.2083:(-95.75,-2.42,5.97); 1.25:(-98.4029,-17.39503,6.85104); 1.2917:(-101.24523,-29.87096,7.69993); 1.5833:(-101.25,-29.87,7.7); 1.6667:(-88.17772,-42.09094,10.96195); 1.8333:(-88.17772,-42.09094,10.96195); 2.0417:(-88.17772,-42.09094,10.96195); 2.25:(-88.17772,-42.09094,10.96195); 2.2917:(-88.17772,-42.09094,10.96195); 2.3333:(-88.58526,-17.10045,11.7676); 2.4583:(-88.59,-17.1,11.77); 2.5417:(-46.59531,-16.13694,-3.85578); 2.875:(0,0,0); 3:(0,0,0) |
| left_arm | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 0.4167:(0,0,0); 1.2083:(0,0,0); 1.5833:(0,0,0); 1.6667:(-0.00677,-0.76064,3.19059); 2.4583:(0.0512,-0.76176,3.12882); 2.875:(0,0,0); 3:(0,0,0) |
| right_leg | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(7.5,0,0); 2.125:(7.5,0,0); 2.1667:(0,0,0); 2.2917:(0,0,0); 2.375:(2.5,0,0); 2.4583:(5,0,0); 2.5417:(5,0,0); 2.5833:(5,0,0); 2.625:(0,0,0); 2.875:(0,0,0); 3:(0,0,0) |
| right_leg | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 2.125:(0,0,0); 2.1667:(0,0,0); 2.2917:(0,0,0); 2.375:(0,0.0909,-0.10834); 2.4583:(0,0.09,-0.11); 2.5417:(0,0.09,-0.11); 2.875:(0,0,0); 3:(0,0,0) |
| left_leg | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(-10,0,0); 2.125:(-10,0,0); 2.1667:(0,0,0); 2.2917:(0,0,0); 2.375:(2.5,0,0); 2.4583:(5,0,0); 2.5417:(5,0,0); 2.5833:(5,0,0); 2.625:(0,0,0); 3:(0,0,0) |
| left_leg | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 2.125:(0,0,0); 2.1667:(0,0,0); 2.2917:(0,0,0); 2.375:(0,0.0909,-0.10834); 2.4583:(0,0.09,-0.11); 2.5417:(0,0.09,-0.11); 3:(0,0,0) |

**`COPPER_GOLEM_CHEST_INTERACTION_ITEM_NODROP`**: length 3 s, looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| body | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(18,0,0); 0.2917:(24,0,0); 0.375:(15,0,0); 0.4167:(12.5,0,0); 0.5833:(12.5,0,0); 0.75:(12.5,0,0); 0.8333:(14.72765,-31.63886,-7.85085); 0.9167:(14.72765,-31.63886,-7.85085); 1.0417:(14.72765,-31.63886,-7.85085); 1.125:(12.40525,-0.00044,0.00829); 1.2083:(12.40525,-0.00044,0.00829); 1.2917:(13.92716,26.80536,6.38918); 1.625:(13.93,26.81,6.39); 1.6667:(21.43,26.81,6.39); 1.7917:(21.43,26.81,6.39); 1.8333:(13.93,26.81,6.39); 2.0417:(13.93,26.81,6.39); 2.1667:(12.40725,0,0.00783); 2.25:(0,0,0); 2.3333:(-2.5,0,0); 2.5:(0,0,0); 2.875:(0,0,0); 3:(0,0,0) |
| body | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0.6,0); 0.4167:(0,0.5,0); 1.625:(0,0.4,0); 1.6667:(-0.01805,0.88303,-0.09783); 1.7917:(-0.01805,0.88303,-0.09783); 1.8333:(0,0.6,0); 2.0417:(0,0.6,0); 2.25:(0,0,0); 2.3333:(0,0,0); 2.5:(0,0,0); 2.875:(0,0,0); 3:(0,0,0) |
| head | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(-20,0,0); 0.2083:(-20,0,0); 0.25:(-2.5,0,0); 0.2917:(-5,0,0); 0.375:(0,0,0); 0.4167:(0,0,0); 0.5833:(0,0,0); 0.6667:(0,-20,0); 0.75:(0,-20,0); 0.8333:(0,10,0); 1.0417:(0,10,0); 1.1667:(0,10,0); 1.2083:(0,27.5,0); 1.2917:(0,0,0); 1.4167:(0,0,0); 1.4583:(0,0,0); 1.5:(0,-2.5,0); 1.625:(0,-2.5,0); 1.6667:(9.73588,-1.93433,-3.73384); 1.7083:(9.73588,-1.93433,-3.73384); 1.7917:(10.15255,-1.93433,-3.73384); 1.8333:(17.86088,-1.93433,-3.73384); 1.875:(17.23588,-1.93433,-3.73384); 1.9167:(17.23588,-1.93433,-3.73384); 2.0417:(17.23588,-1.93433,-3.73384); 2.0833:(-0.26,-1.93,-3.73); 2.25:(0,0,0); 2.2917:(1.25,0,0); 2.3333:(2.5,0,0); 2.6667:(0,0,0); 2.9583:(0,-360,0); 3:(0,0,0) |
| head | position | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(0,-0.15451,0.47553); 0.25:(0,0,0); 0.4167:(0,0,0); 1.0417:(0,0,0); 1.1667:(0,0,0); 1.2917:(0,0,0); 1.4167:(0,0,0); 1.4583:(0,0,0); 1.5:(0,0,0); 1.625:(0,0,0); 1.6667:(-0.22438,0.82319,-1.27252); 1.875:(-0.22438,0.82319,-1.27252); 1.9167:(-0.22438,0.82319,-1.27252); 2.0417:(-0.22438,0.82319,-1.27252); 2.0833:(-0.39,0.52,-2.21); 2.25:(0,0,0.5); 2.2917:(0,-0.01091,-0.02988); 2.3333:(0,-0.01,-0.03); 2.6667:(0,-0.01,-0.03); 2.9583:(0,-0.01,-0.03); 3:(0,0,0) |
| right_arm | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(-7.38733,1.29876,9.91615); 0.2917:(-7.38733,1.29876,9.91615); 0.375:(10,0,32.5); 0.4167:(-34.55418,11.73507,36.8361); 0.4583:(-117.82767,2.94538,0.22703); 0.5417:(-97.7902,0.73403,1.39387); 0.5833:(-92.79,0.73,1.39); 0.75:(-92.79,0.73,1.39); 0.8333:(-95.83405,33.18639,-0.40081); 1.5:(-95.83,33.19,-0.4); 1.5833:(-44.60123,10.14454,8.66307); 1.8333:(-4.31506,6.54961,13.21388); 2.0833:(-4.31506,6.54961,13.21388); 2.1667:(-4.31506,6.54961,13.21388); 2.25:(-6.53898,13.96898,14.34786); 2.3333:(3.50393,-4.70737,8.3608); 2.4583:(3.50393,-4.70737,8.3608); 2.5:(3.90089,-4.3843,3.35549); 2.5417:(3.9,-4.38,3.36); 2.9167:(3.9,-4.38,3.36); 2.9583:(3.90089,-4.3843,3.35549); 3:(0,0,0) |
| right_arm | position | 0:(0,0,0); 0.125:(0,0,0); 0.2917:(0,0,0); 0.375:(0,0,0); 0.5833:(0,0,0); 0.75:(0,0,0); 0.8333:(0.25358,-0.20153,2.21248); 1.5:(0.25,-0.2,2.21); 1.5417:(-0.79739,-0.10573,1.70592); 1.5833:(-0.26323,-1.46323,0.66566); 1.8333:(-0.51052,-0.38088,0.79745); 2.0833:(-0.51052,-0.38088,0.79745); 2.1667:(-0.51052,-0.38088,0.79745); 2.25:(-0.46,-0.34,0.72); 2.3333:(-0.46,0.1159,-0.30086); 2.4583:(-0.46,0.1159,-0.30086); 2.5:(-0.46,0.1159,-0.30086); 2.5417:(-0.46,-0.88,-0.3); 2.9167:(-0.46,-0.88,-0.3); 2.9583:(-0.46,0.1159,-0.30086); 3:(0,0,0) |
| left_arm | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(25,0,-37.5); 0.25:(-21.59341,-12.60837,-45.69252); 0.2917:(-120.7755,-5.21988,-2.02064); 0.375:(-98.27419,-1.79323,-1.15048); 0.4167:(-93.27,-1.79,-1.15); 0.5417:(-93.27419,-1.79323,-1.15048); 0.5833:(-93.55693,-22.3224,3.64383); 0.7083:(-93.55693,-22.3224,3.64383); 1.1667:(-93.55693,-22.3224,3.64383); 1.2083:(-95.75,-2.42,5.97); 1.25:(-98.4029,-17.39503,6.85104); 1.2917:(-101.24523,-29.87096,7.69993); 1.5833:(-101.25,-29.87,7.7); 1.6667:(-88.17772,-42.09094,10.96195); 1.8333:(-88.17772,-42.09094,10.96195); 2.0417:(-88.17772,-42.09094,10.96195); 2.25:(0,0,-20); 2.3333:(2.47864,-0.32621,-12.50706); 2.4583:(2.47864,-0.32621,-12.50706); 2.5:(2.41492,-0.64686,-5.01363); 2.5417:(2.41,-0.65,-5.01); 2.9167:(2.41,-0.65,-5.01); 2.9583:(2.41492,-0.64686,-5.01363); 3:(0,0,0) |
| left_arm | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 0.4167:(0,0,0); 1.2083:(0,0,0); 1.5833:(0,0,0); 1.6667:(-0.00677,-0.76064,3.19059); 1.8333:(-0.00677,-0.76064,3.19059); 2.0417:(-0.00677,-0.76064,3.19059); 2.25:(0.03,-0.76,0.45); 2.3333:(0.03,-0.28229,-0.07133); 2.4583:(0.03,-0.28229,-0.07133); 2.5:(0.03,-0.28229,-0.07133); 2.5417:(0.03,-1.28,-0.07); 2.9167:(0.03,-1.28,-0.07); 2.9583:(0.03,-0.28229,-0.07133); 3:(0,0,0) |
| right_leg | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(7.5,0,0); 2.1667:(7.5,0,0); 2.25:(0,0,0); 2.3333:(0,0,0); 2.5:(0,0,0); 2.875:(0,0,0); 3:(0,0,0) |
| right_leg | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 2.1667:(0,0,0); 2.25:(0,0,0); 2.3333:(0,0,0); 2.5:(0,0,0); 2.875:(0,0,0); 3:(0,0,0) |
| left_leg | rotation | 0.125:(0,0,0); 0.2083:(-10,0,0); 2.1667:(-10,0,0); 2.25:(0,0,0) |
| left_leg | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 2.1667:(0,0,0); 2.25:(0,0,0); 3:(0,0,0) |
| left_leg | scale | 0:(1,1,1); 3:(1,1,1) |

**`COPPER_GOLEM_CHEST_INTERACTION_NOITEM_GET`**: length 3 s, looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| body | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(18,0,0); 0.2917:(24,0,0); 0.375:(15,0,0); 0.4167:(12.5,0,0); 0.5833:(12.5,0,0); 0.75:(12.5,0,0); 0.8333:(14.72765,-31.63886,-7.85085); 0.9167:(14.72765,-31.63886,-7.85085); 1.0417:(14.72765,-31.63886,-7.85085); 1.125:(12.40525,-0.00044,0.00829); 1.2083:(12.40525,-0.00044,0.00829); 1.2917:(13.92716,26.80536,6.38918); 1.625:(13.93,26.81,6.39); 1.6667:(21.43,26.81,6.39); 1.7917:(21.43,26.81,6.39); 1.8333:(13.93,26.81,6.39); 2.0417:(13.93,26.81,6.39); 2.125:(12.40725,0,0.00783); 2.1667:(0,0,0); 2.25:(0,0,0); 2.2917:(0,0,0); 2.375:(15,0,0); 2.4167:(17.5,0,0); 2.4583:(22.5,0,0); 2.625:(24.14867,-20.70481,-9.00717); 2.7083:(24.14867,-20.70481,-9.00717); 2.75:(22.5,0,0); 2.7917:(0,0,0); 2.9583:(0,0,0) |
| body | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0.6,0); 0.4167:(0,0.5,0); 1.625:(0,0.4,0); 1.6667:(-0.01805,0.88303,-0.09783); 1.7917:(-0.01805,0.88303,-0.09783); 1.8333:(0,0.6,0); 2.0417:(0,0.6,0); 2.1667:(0,0,0); 2.25:(0,0,0); 2.2917:(0,0,0); 2.625:(0,0.46194,-0.19134); 2.7083:(0,0.46194,-0.19134); 2.7917:(0,0,0); 2.9583:(0,0,0) |
| head | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(-20,0,0); 0.2083:(-20,0,0); 0.25:(-2.5,0,0); 0.2917:(-5,0,0); 0.375:(0,0,0); 0.4167:(0,0,0); 0.5833:(0,0,0); 0.6667:(0,-20,0); 0.75:(0,-20,0); 0.8333:(0,10,0); 1.0417:(0,10,0); 1.1667:(0,10,0); 1.2083:(0,27.5,0); 1.2917:(0,0,0); 1.4167:(0,0,0); 1.4583:(0,0,0); 1.5:(0,0,0); 1.5833:(0,0,0); 1.625:(0,-2.5,0); 1.6667:(10.16381,-16.71134,-6.35306); 1.8333:(10.16381,-16.71134,-6.35306); 1.9167:(10.16381,-16.71134,-6.35306); 1.9583:(10.16381,-16.71134,-6.35306); 2:(5.16381,-16.71134,-6.35306); 2.0417:(0.16381,-16.71134,-6.35306); 2.0833:(0.15732,-4.21139,-6.31751); 2.125:(0.07901,5.3943,-3.15187); 2.1667:(0,7.5,0); 2.2917:(4.53867,7.47675,0.59181); 2.3333:(-2.53852,9.99038,-0.44067); 2.4167:(-12.68664,9.76061,-2.18558); 2.625:(-15.19938,22.36971,-3.52259); 2.6667:(-3.02173,22.37156,-2.41802); 2.7083:(-0.52173,22.37156,-2.41802); 2.75:(-12.40598,-0.4674,-1.79838); 2.8333:(0,0,0); 2.9583:(0,0,0) |
| head | position | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(0,-0.15451,0.47553); 0.25:(0,0,0); 0.4167:(0,0,0); 1.0417:(0,0,0); 1.1667:(0,0,0); 1.2917:(0,0,0); 1.4167:(0,0,0); 1.4583:(0,0,0); 1.5:(0,0,0); 1.5833:(0,0,0); 1.625:(0,0,0); 1.6667:(-0.22438,0.82319,-1.27252); 1.8333:(-0.22438,0.82319,-1.27252); 1.9167:(-0.22438,0.82319,-1.27252); 1.9583:(-0.52521,0.96725,-0.32978); 2:(-0.52521,0.96725,-0.32978); 2.0417:(-0.5345,1.16541,-0.37206); 2.0833:(-0.5345,1.16541,-0.37206); 2.1667:(0,0,0); 2.3333:(0,0,0); 2.625:(0,0,0); 2.8333:(0,0,0); 2.9583:(0,0,0) |
| right_arm | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(-7.38733,1.29876,9.91615); 0.2917:(-7.38733,1.29876,9.91615); 0.375:(10,0,32.5); 0.4167:(-34.55418,11.73507,36.8361); 0.4583:(-82.47403,17.82361,2.17224); 0.5:(-85.08388,14.26971,1.99595); 0.5417:(-85.16266,13.19102,2.43976); 0.5833:(-92.79,0.73,1.39); 0.75:(-92.79,0.73,1.39); 0.8333:(-95.83405,33.18639,-0.40081); 1.25:(-95.83,33.19,-0.4); 1.2917:(-98.33,33.19,-0.4); 1.5417:(-56.46674,3.3853,14.45894); 1.6667:(-56.46674,3.3853,14.45894); 1.8333:(-56.46674,3.3853,14.45894); 2:(-56.46674,3.3853,14.45894); 2.0417:(-56.46674,3.3853,14.45894); 2.1667:(-84.12204,8.95753,14.11779); 2.2083:(-84.12204,8.95753,14.11779); 2.25:(-93.6065,13.90544,15.98524); 2.3333:(-124.48661,66.29146,-7.28605); 2.375:(-129.4866,66.29146,-7.28605); 2.4167:(-108.91607,1.79762,20.93924); 2.5:(-102.18303,4.35881,17.40962); 2.5417:(-98.33642,-0.70114,4.09322); 2.625:(-98.39385,6.71929,3.00137); 2.6667:(-98.33981,1.77244,3.7307); 2.7083:(-100.70987,3.48829,7.1138); 2.75:(-97.95,6.92,13.88); 2.7917:(-87.95,6.92,13.88); 2.8333:(-97.95,6.92,13.88); 2.875:(-102.95,6.92,13.88); 2.9167:(-76.475,3.46,6.94); 2.9583:(-26.475,3.46,6.94); 3:(0,0,0) |
| right_arm | position | 0:(0,0,0); 0.125:(0,0,0); 0.2917:(0,0,0); 0.375:(0,0,0); 0.5833:(0,0,0); 0.75:(0,0,0); 0.8333:(0.25358,-0.20153,2.21248); 1.25:(0.25,-0.2,2.21); 1.2917:(0.25,-0.2,2.21); 1.5417:(-0.26323,-1.46323,0.66566); 1.6667:(-0.26323,-1.46323,0.66566); 1.8333:(-0.26323,-1.46323,0.66566); 2:(-0.26323,-1.46323,0.66566); 2.0417:(-0.26323,-1.46323,0.66566); 2.25:(-0.51,-0.38,0.8); 2.3333:(-0.51,-0.38,0.8); 2.375:(-0.51,-0.38,0.8); 2.4167:(-2.14094,0.69619,1.23422); 2.4583:(-0.97932,0.38244,0.12884); 2.5417:(-1.55232,1.79904,0.37956); 2.625:(-1.53125,1.64598,1.41168); 2.6667:(-1.57256,1.05375,1.32469); 2.75:(-1.33,0.16,1.02); 2.7917:(-1.33,0.16,1.02); 2.8333:(-1.33,0.16,1.02); 2.875:(-1.33,0.16,1.02); 2.9167:(-0.5748,0.38848,1.45646); 2.9583:(-0.67,0.08,0.51); 3:(0,0,0) |
| left_arm | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(25,0,-37.5); 0.25:(-21.59341,-12.60837,-45.69252); 0.2917:(-120.7755,-5.21988,-2.02064); 0.375:(-98.27419,-1.79323,-1.15048); 0.4167:(-93.27,-1.79,-1.15); 0.5417:(-93.27419,-1.79323,-1.15048); 0.5833:(-93.55693,-22.3224,3.64383); 0.7083:(-93.55693,-22.3224,3.64383); 1.1667:(-93.55693,-22.3224,3.64383); 1.2083:(-95.75,-2.42,5.97); 1.25:(-98.4029,-17.39503,6.85104); 1.2917:(-101.24523,-29.87096,7.69993); 1.5833:(-101.25,-29.87,7.7); 1.6667:(-88.17772,-42.09094,10.96195); 1.8333:(-88.17772,-42.09094,10.96195); 1.9583:(-88.17772,-42.09094,10.96195); 2.1667:(-88.17772,-42.09094,10.96195); 2.2083:(-88.58526,-17.10045,11.7676); 2.3333:(-88.59,-17.1,11.77); 2.4167:(-46.59531,-16.13694,-3.85578); 2.5:(-24.5317,-19.0214,-13.70805); 2.8333:(0,0,0); 2.9583:(0,0,0) |
| left_arm | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 0.4167:(0,0,0); 1.2083:(0,0,0); 1.5833:(0,0,0); 1.6667:(-0.00677,-0.76064,3.19059); 2.3333:(0.0512,-0.76176,3.12882); 2.8333:(0,0,0); 2.9583:(0,0,0) |
| right_leg | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(7.5,0,0); 2.2917:(7.5,0,0); 2.7083:(7.5,0,0); 2.7917:(5,0,0); 2.8333:(5,0,0); 2.875:(0,0,0); 2.9583:(0,0,0) |
| right_leg | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 2.2917:(0,0,0); 2.7083:(0,0,0); 2.7917:(0,0.09,-0.11); 2.8333:(0,0,0); 2.9583:(0,0,0) |
| left_leg | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(-10,0,0); 2.0417:(-10,0,0); 2.25:(-10,0,0); 2.3333:(-10,0,0); 2.4167:(-10,0,0); 2.4583:(-10,0,0); 2.5:(-10,0,0); 2.625:(-10,0,0); 2.9583:(0,0,0) |
| left_leg | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 2.0417:(0,0,0); 2.25:(0,0,0); 2.3333:(0,0,0); 2.4167:(0,0,0); 2.4583:(0,0,0); 2.5:(0,0,0); 2.625:(0,0,0); 2.9583:(0,0,0) |

**`COPPER_GOLEM_CHEST_INTERACTION_NOITEM_NOGET`**: length 3 s, looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| body | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(18,0,0); 0.2917:(24,0,0); 0.375:(15,0,0); 0.4167:(12.5,0,0); 0.5833:(12.5,0,0); 0.75:(12.5,0,0); 0.8333:(14.72765,-31.63886,-7.85085); 0.9167:(14.72765,-31.63886,-7.85085); 1.0417:(14.72765,-31.63886,-7.85085); 1.125:(12.40525,-0.00044,0.00829); 1.2083:(12.40525,-0.00044,0.00829); 1.2917:(13.92716,26.80536,6.38918); 1.625:(13.93,26.81,6.39); 1.7083:(12.40725,0.00444,0.00783); 2.0417:(12.40725,0.00444,0.00783); 2.125:(12.40725,0,0.00783); 2.25:(0,0,0); 2.4583:(0,0,0); 2.5:(0,0,0); 2.6667:(0,0,0); 2.9583:(0,0,0) |
| body | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0.6,0); 0.4167:(0,0.5,0); 1.625:(0,0.4,0); 1.7083:(0,0.34,0); 2.0417:(0,0.34,0); 2.25:(0,0,0); 2.4583:(0,0,0); 2.5:(0,0,0); 2.6667:(0,0,0); 2.9583:(0,0,0) |
| head | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(-20,0,0); 0.2083:(-20,0,0); 0.25:(-2.5,0,0); 0.2917:(-5,0,0); 0.375:(0,0,0); 0.4167:(0,0,0); 0.5833:(0,0,0); 0.6667:(0,-20,0); 0.75:(0,-20,0); 0.8333:(0,10,0); 1.0417:(0,10,0); 1.1667:(0,10,0); 1.2083:(0,27.5,0); 1.2917:(0,0,0); 1.4167:(0,0,0); 1.4583:(0,0,0); 1.5:(0,0,0); 1.5833:(0,0,0); 1.625:(0,-2.5,0); 1.7083:(0.57,-1.25,0.07); 1.75:(0.89798,-18.12465,-0.16276); 1.7917:(1.21328,-21.15422,-0.2148); 1.875:(1.21328,-21.15422,-0.2148); 2:(1.21328,-21.15422,-0.2148); 2.0417:(2.56546,0.76525,0.57246); 2.2917:(4.53867,7.47675,0.59181); 2.5:(4.53867,7.47675,0.59181); 2.5417:(0,0,0); 2.9583:(0,-360,0); 3:(0,0,0) |
| head | position | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(0,-0.15451,0.47553); 0.25:(0,0,0); 0.4167:(0,0,0); 1.0417:(0,0,0); 1.1667:(0,0,0); 1.2917:(0,0,0); 1.4167:(0,0,0); 1.4583:(0,0,0); 1.5:(0,0,0); 1.5833:(0,0,0); 1.625:(0,0,0); 1.7083:(0,0,0); 2.5417:(0,0,0); 2.9583:(0,-0.01,-0.03); 3:(0,0,0) |
| right_arm | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.1667:(-7.38733,1.29876,9.91615); 0.2917:(-7.38733,1.29876,9.91615); 0.375:(10,0,32.5); 0.4167:(-34.55418,11.73507,36.8361); 0.4583:(-82.47403,17.82361,2.17224); 0.5:(-85.08388,14.26971,1.99595); 0.5417:(-85.16266,13.19102,2.43976); 0.5833:(-92.79,0.73,1.39); 0.75:(-92.79,0.73,1.39); 0.8333:(-95.83405,33.18639,-0.40081); 1.25:(-95.83,33.19,-0.4); 1.2917:(-98.33,33.19,-0.4); 1.5417:(-56.46674,3.3853,14.45894); 1.6667:(-56.46674,3.3853,14.45894); 1.8333:(-56.46674,3.3853,14.45894); 2:(-56.46674,3.3853,14.45894); 2.0417:(-56.46674,3.3853,14.45894); 2.1667:(0,0,0); 2.5:(0,0,0); 2.5417:(3.9,-4.38,3.36); 2.9167:(3.9,-4.38,3.36); 2.9583:(3.90089,-4.3843,3.35549); 3:(0,0,0) |
| right_arm | position | 0:(0,0,0); 0.125:(0,0,0); 0.2917:(0,0,0); 0.375:(0,0,0); 0.5833:(0,0,0); 0.75:(0,0,0); 0.8333:(0.25358,-0.20153,2.21248); 1.25:(0.25,-0.2,2.21); 1.2917:(0.25,-0.2,2.21); 1.5417:(-0.26323,-1.46323,0.66566); 1.6667:(-0.26323,-1.46323,0.66566); 1.8333:(-0.26323,-1.46323,0.66566); 2:(-0.26323,-1.46323,0.66566); 2.0417:(-0.26323,-1.46323,0.66566); 2.1667:(0,0,0); 2.5:(0,0,0); 2.5417:(-0.46,-0.88,-0.3); 2.9167:(-0.46,-0.88,-0.3); 2.9583:(-0.46,0.1159,-0.30086); 3:(0,0,0) |
| left_arm | rotation | 0:(-2.5,0,0); 0.125:(0,0,0); 0.2083:(25,0,-37.5); 0.25:(-21.59341,-12.60837,-45.69252); 0.2917:(-120.7755,-5.21988,-2.02064); 0.375:(-98.27419,-1.79323,-1.15048); 0.4167:(-93.27,-1.79,-1.15); 0.5417:(-93.27419,-1.79323,-1.15048); 0.5833:(-93.55693,-22.3224,3.64383); 0.7083:(-93.55693,-22.3224,3.64383); 1.1667:(-93.55693,-22.3224,3.64383); 1.2083:(-95.75,-2.42,5.97); 1.25:(-98.4029,-17.39503,6.85104); 1.2917:(-101.24523,-29.87096,7.69993); 1.5833:(-101.25,-29.87,7.7); 1.6667:(-88.17772,-42.09094,10.96195); 1.8333:(-88.17772,-42.09094,10.96195); 2.0833:(-88.17772,-42.09094,10.96195); 2.1667:(-88.17772,-42.09094,10.96195); 2.2083:(-88.58526,-17.10045,11.7676); 2.3333:(-88.59,-17.1,11.77); 2.4167:(-46.59531,-16.13694,-3.85578); 2.4583:(-24.5317,-19.0214,-13.70805); 2.5:(-24.5317,-19.0214,-13.70805); 2.5417:(2.41,-0.65,-5.01); 2.9167:(2.41,-0.65,-5.01); 2.9583:(2.41492,-0.64686,-5.01363); 3:(0,0,0) |
| left_arm | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 0.4167:(0,0,0); 1.2083:(0,0,0); 1.5833:(0,0,0); 1.6667:(-0.00677,-0.76064,3.19059); 2.3333:(0.0512,-0.76176,3.12882); 2.4583:(0.03,-0.51,2.09); 2.5:(0.03,-0.51,2.09); 2.5417:(0.03,-1.28,-0.07); 2.9167:(0.03,-1.28,-0.07); 2.9583:(0.03,-0.28229,-0.07133); 3:(0,0,0) |
| right_leg | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(7.5,0,0); 2.2917:(7.5,0,0); 2.3333:(0,0,0); 2.9583:(0,0,0) |
| right_leg | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 2.2917:(0,0,0); 2.3333:(0,0,0); 2.9583:(0,0,0) |
| left_leg | rotation | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(-10,0,0); 2.0417:(-10,0,0); 2.2917:(-10,0,0); 2.3333:(0,0,0); 2.9583:(0,0,0) |
| left_leg | position | 0:(0,0,0); 0.125:(0,0,0); 0.2083:(0,0,0); 2.0417:(0,0,0); 2.2917:(0,0,0); 2.3333:(0,0,0); 2.9583:(0,0,0) |

**`CREAKING_WALK`**: length 1.125 s, looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| upper_body | rotation | 0:(26.8802,-23.399,-9.0616); 0.125:(-2.2093,5.9119,0.0675); 0.5417:(23.0778,14.2906,4.6066); 0.7083:(-10,0,0); 0.875:(7.5,0,0); 1.125:(26.8802,-23.399,-9.0616) |
| head | rotation | 0:(0,0,0); 0.0417:(-17.5,-62.5,0); 0.0833:(0,0,0); 0.4167:(0,0,0); 0.4583:(0,15,0); 0.5:(0,0,0); 1.0417:(0,0,0); 1.0833:(-37.1532,81.1131,-28.3621); 1.125:(0,0,0) |
| right_arm | rotation | 0:(12.5,0,0); 0.25:(-32,0,0); 0.875:(12,0,0); 1.125:(-15,0,0) |
| left_arm | rotation | 0:(-15,0,0); 0.125:(10,0,0); 0.5417:(-25,0,0); 0.75:(-9.0923,0,0); 0.7917:(-15.137,-66.7758,13.9603); 0.8333:(-9.0923,0,0); 1:(10,0,0); 1.125:(-15,0,0) |
| left_leg | rotation | 0:(0,0,0); 0.25:(30,0,0); 0.375:(49.8924,-3.8282,3.2187); 0.5:(17.5,0,0); 0.625:(-56.5613,-12.2403,-8.7374); 0.9167:(0,0,0); 1.125:(0,0,0) |
| left_leg | position | 0:(0,0,2); 0.25:(0,0.1846,0.5979); 0.375:(0,-0.0665,-2.2177); 0.5:(0,1.3563,-4.3474); 0.625:(0,0.1047,-1.6556); 0.9167:(0,0,-1); 1.125:(0,0,2) |
| right_leg | rotation | 0:(25.5305,11.3125,5.3525); 0.125:(-49.5628,7.3556,6.7933); 0.25:(0,0,0); 0.4583:(0,0,0); 0.9167:(30,0,0); 1.0417:(55,0,0); 1.125:(25.5305,11.3125,5.3525) |
| right_leg | position | 0:(0,0.9674,-3.6578); 0.125:(0,-0.2979,-0.9411); 0.25:(0,-0.3,-0.94); 0.4583:(0,-0.3,1.06); 1.125:(0,0.9674,-3.6578) |

**`CREAKING_ATTACK`**: length 0.7083 s, looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| upper_body | rotation | 0:(0,0,0); 0.0833:(0,45,0); 0.1667:(-115,67.5,-90); 0.375:(67.5,0,0); 0.5417:(0,45,0); 0.7083:(0,0,0) |
| upper_body | position | 0:(0,0,0); 0.0833:(0,0,0); 0.2917:(0,-2.7716,-1.1481); 0.375:(0,0,0); 0.5417:(0,0,0); 0.7083:(0,0,0) |
| upper_body | scale | 0:(1,1,1); 0.7083:(1,1,1) |
| head | rotation | 0:(0,0,0); 0.1667:(0,-45,0); 0.25:(-11.25,-45,0); 0.2917:(-117.3939,76.6331,-130.1483); 0.4167:(-45,-45,0); 0.5:(60,-45,0); 0.5833:(60,-45,0); 0.625:(0,-45,0); 0.7083:(0,0,0) |
| head | position | 0:(0,0,0); 0.1667:(0,0,0); 0.4167:(0,0,0); 0.5:(0.3827,0.5133,-0.7682); 0.5833:(0.3827,0.5133,-0.7682); 0.625:(0,0,0); 0.7083:(0,0,0) |
| head | scale | 0.1667:(1,1,1); 0.4167:(1,1,1); 0.5:(1,1.3,1); 0.625:(1,1,1) |
| right_arm | rotation | 0:(0,0,0); 0.1667:(0,0,0); 0.25:(7.5,0,0); 0.4583:(55,0,0); 0.625:(0,0,0); 0.7083:(0,0,0) |
| right_arm | position | 0:(0,0,0); 0.1667:(0,0,0); 0.625:(0,0,0); 0.7083:(0,0,0) |
| left_leg | rotation | 0:(0,0,0); 0.1667:(0,0,0); 0.625:(0,0,0); 0.7083:(0,0,0) |
| left_leg | position | 0:(0,0,0); 0.1667:(0,0,-2); 0.625:(0,0,-2); 0.7083:(0,0,0) |
| right_leg | rotation | 0:(0,0,0); 0.1667:(0,45,0); 0.625:(0,45,0); 0.7083:(0,0,0) |
| right_leg | position | 0:(0,0,0); 0.1667:(0.7071,0,0); 0.625:(0.7071,0,0); 0.7083:(0,0,0) |
| left_arm | rotation | 0:(0,0,0); 0.1667:(0,0,0); 0.25:(10.3453,14.7669,2.664); 0.4583:(57.5,0,0); 0.625:(0,0,0); 0.7083:(0,0,0) |
| left_arm | position | 0:(0,0,0); 0.7083:(0,0,0) |

**`CREAKING_INVULNERABLE`**: length 0.2917 s, not looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| upper_body | rotation | 0:(0,0,0); 0.0833:(-5,0,0); 0.1667:(5,0,0); 0.25:(0,0,0) |
| upper_body | position | 0:(0,0,0); 0.0833:(0,0,0); 0.25:(0,0,0) |
| right_arm | rotation | 0:(0,0,0); 0.0833:(17.5,0,0); 0.1667:(-15,0,0); 0.25:(0,0,0) |
| right_arm | position | 0:(0,0,0); 0.25:(0,0,0) |
| left_arm | rotation | 0:(0,0,0); 0.0833:(20,0,0); 0.1667:(-15,0,0); 0.25:(0,0,0) |
| left_arm | position | 0:(0,0,0); 0.25:(0,0,0) |

**`CREAKING_DEATH`**: length 2.25 s, not looping.

| Bone | Channel | Keyframes: time s : (x, y, z); `~` marks CATMULLROM, no mark LINEAR |
|---|---|---|
| upper_body | rotation | 0:(0,0,0); 0.0833:(-40,0,0); 0.1667:(-5,0,0); 0.2917:(7.5,0,0); 0.5833:(16.25,0,0); 0.6667:(29.0814,62.5516,26.5771); 0.75:(12.2115,0,0); 1:(10.25,0,0); 1.0417:(-47.64,0,0); 1.125:(21.96,0,0); 1.25:(12.5,0,0); 2.25:(17.3266,7.9022,-0.1381) |
| upper_body | position | 0:(0,0,0); 0.0833:(0,0.557,1.2659); 0.1667:(0,-2.0889,-0.3493); 0.2917:(0,0,0) |
| upper_body | scale | 0:(1,1,1); 0.0833:(1,1.1,1); 0.1667:(1,0.9,1); 0.2917:(1,1,1) |
| right_arm | rotation | 0:(0,0,0); 0.2917:(-10,0,0); 0.5:(0,0,0); 1.25:(-10,0,0); 1.5417:(-10,0,0); 1.5833:(-12.1479,-34.3927,6.9326); 1.6667:(-10,0,0) |
| right_arm | position | 0:(0,0,0); 0.2917:(0,0,0) |
| left_arm | rotation | 0:(0,0,0); 0.2917:(-10,0,0); 0.5:(0,0,0); 0.8333:(-4.4444,0,0); 0.875:(-26.7402,-78.831,26.3025); 0.9583:(-5.5556,0,0); 1.25:(-10,0,0) |
| left_arm | position | 0:(0,0,0); 0.2917:(0,0,0) |
| head | rotation | 0:(0,0,0); 0.0833:(-5,0,0); 0.2917:(10,0,0); 0.5:(2.5,0,0); 0.5417:(5.5,0,0); 0.5833:(-67.4168,-12.9552,-8.0231); 0.6667:(8.5,0,0); 1:(10.773,-29.5608,-5.3627); 1.25:(10,0,0); 1.7917:(10,0,0); 1.8333:(12.9625,39.2735,8.2901); 1.9167:(10,0,0) |
| head | position | 0:(0,0,0); 0.2917:(0,0,0) |


---

## Open questions

1. **Rotation composition order.** `ModelPart.translateAndRotate` rotates by `Quaternionf.rotationZYX(zRot, yRot, xRot)` (read, bytecode: the three angles are pushed in the order z, y, x). Which axis acts first on a vertex is defined by the `org.joml.Quaternionf` class, which is not part of the artifact: `unzip -Z1` of the client jar lists 0 entries containing "joml" and 0 nested jars, and the only other archive in the working area (the Brigadier jar) does not contain it either. The order is therefore not read and stays (recalled, not verified). It affects the two-axis poses (illager arms, copper golem and creaking keyframes, witch hat chain); a reference render of a part with two non-zero angles settles it, or a round given the joml library as a second artifact.
2. **Witch hat brim.** The witch inherits the villager's `hat_rim` cuboid (merge rule) at tex (30, 47) of a 64x128 texture. Whether the witch texture leaves that region transparent (so it is invisible) is texture data, not checked.
3. **Illager zombie arms.** In `ATTACKING` with an empty main hand, `animateZombieArms` tests the main-hand stack for identity with `ItemStack.EMPTY` after the extraction copied the stack; that an empty copy is the shared empty instance is (inferred).
4. **Baby villager type textures.** The folder `baby` replaces `type` for the type overlay of a baby, while hat metadata is read from `type`. The existence of `textures/entity/villager/baby/<type>.png` in the vanilla resource pack is data (tool, 22) and was not checked.
5. **Spear and using-item arm animations.** `ItemInHandLayer` calls `SpearAnimations.thirdPersonAttackItem` for a stabbing swing and `ArmPose.animateUseItem` for a used item; neither is traced here. Illager, vex, allay and copper golem states yield `ticksUsingItem(arm) = 0` (read, 4.5). The zombie villager uses `HumanoidMobRenderer.extractHumanoidRenderState`, which stores `isUsingItem` and `ticksUsingItem` from the entity, so a non-zero value is possible for it (inferred); what `animateUseItem` does for its arm pose (the pose is `EMPTY` or `SPEAR`, 34-1 §3.6) was not read. A spear-wielding humanoid is the framework sibling's case (34-1 §8.3).
6. **Left-handed illagers.** `mainArm` comes from the entity (`getMainArm`); which illagers can be left-handed is mob data (20 §13).
7. **Copper golem eyes layer.** `COPPER_GOLEM_EYES` is registered (the body layer after `retainPartsAndChildren({eyes})`, which empties everything because no part is named `eyes`), but the renderer's emissive layer bakes `COPPER_GOLEM` instead. Whether the unused layer is intentional is unknown; the document follows the renderer.
8. **Block and item model submission.** The flower, pumpkin and antenna-block layers submit `BlockModelRenderState` objects whose geometry comes from the block model resolver (12 §8, 14); only the pose transforms around them are specified here.
9. **Emissive layer alpha.** `LivingEntityEmissiveLayer` converts the alpha function's value to an opaque-white colour with that alpha (`ARGB.white(alpha)`) and passes it as the model tint; the exact blend of `RenderTypes.eyes` is a render-type matter of the framework sibling.
10. **Animation state driving.** Which entity events start the copper golem and creaking animation states, and with which start ticks, is entity logic; copper golem in 44-3 §8, creaking in 20 §17; not re-read here.
11. **`Math.cos` versus table `Mth.cos`.** Reproducing 1-ulp differences is not required. Double-precision `Math` functions are used in two places only: the allay root bob (`Math.cos`) and the ravager stun sway (`Math.sin`); the illusioner offsets, the spellcaster particle angle and the fangs base height use the table functions (0.1 item 9).
12. **Spot-check coverage.** The review of this document did not independently re-verify the renderer classes (shadow radii, texture paths, layer order, head and held-item layers, profession layer file-name rules), the copper golem and creaking mesh tables, the Appendix A keyframe tables, the section 12.1 and 14 tables, the snow golem, zombie villager and baby models, or the spellcaster colours against the jar. A later pass should spot-check these, Appendix A first, as it holds the most transcribed data.
