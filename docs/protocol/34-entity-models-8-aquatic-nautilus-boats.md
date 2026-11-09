# 34 Entity models and renderers, part 8: aquatic mobs, nautilus family and boats

This document specifies the client models, animations and renderers of the water-bound entities of the 26.3 client: squid and glow squid, dolphin, axolotl, the four fish (cod, salmon, pufferfish, tropical fish), the nautilus family (nautilus, zombie nautilus and their saddle, armor and coral layers) and the boats and rafts (all wood types, chest variants, and the water mask). Geometry, poses, animation formulas, render-state fields, layers, texture names and the per-frame transform of each entity are given completely. Textures themselves, the zombie nautilus variant data files and the equipment (armor, saddle) asset files are DATA and are only described by schema.

| Item | Value |
|---|---|
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3 (the artifact recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for constant pools and bootstrap methods), `unzip -Z1` for file families, and `unzip -p` for two small data files; no execution. Constants of the form `texOffs`, `addBox`, `PartPose` and `CubeDeformation` calls were read from the model classes' static builder methods |
| Classes read | `net.minecraft.client.model.animal.{squid,dolphin,axolotl,fish,nautilus}.*`, `...model.monster.nautilus.ZombieNautilusCoralModel`, `...model.object.boat.*`, `...client.animation.{definitions.BabyAxolotlAnimation, definitions.NautilusAnimation, KeyframeAnimation, AnimationChannel, Keyframe}`, `...renderer.entity.{Squid,GlowSquid,Dolphin,Axolotl,Cod,Salmon,Pufferfish,TropicalFish,Nautilus,ZombieNautilus,AbstractBoat,Boat,Raft}Renderer`, `...renderer.entity.layers.{DolphinCarryingItemLayer,TropicalFishPatternLayer,SimpleEquipmentLayer}`, the matching `...renderer.entity.state.*RenderState` classes, `LayerDefinitions`, `ModelLayers`, `EntityRenderers`, and, for inputs of the render states, `Squid.aiStep`, `Axolotl.baseTick` (animation state driver), `AbstractBoat`, `TropicalFish`, `Salmon$Variant`, `BinaryAnimator`, `Ease`, `DyeColor` |

Class names are cited in backticks to say where a fact was read; they are not the design. Every number below was read in this round; anything else is marked "(inferred)" and listed in Open questions.

**What this document does not repeat.** The model-building primitives (`PartPose`, `CubeDeformation`, box unwrap), the keyframe engine, and the living-entity render pipeline are stated once in [34-entity-models-3-villagers-illagers-golems-misc.md](34-entity-models-3-villagers-illagers-golems-misc.md) section 0.1 to 0.3 and in [14-texture-only-packs.md](14-texture-only-packs.md) section 5.3; this document cites them and adds only the facts those sections lack (section 0 below). The behaviour of the entities (movement, spawning, variants, damage) is in [21-mobs-aquatic-nether-end-bosses-and-entities.md](21-mobs-aquatic-nether-end-bosses-and-entities.md) section 4 and 8.8, [44-residual-mob-questions-7-aquatic.md](44-residual-mob-questions-7-aquatic.md) and [45-entity-nbt-7-aquatic-and-misc-mobs.md](45-entity-nbt-7-aquatic-and-misc-mobs.md); only the fields that a renderer reads are restated here.

## Contents

0. Conventions and engine facts used by every section
1. Family overview (renderers, layers, textures, shadows)
2. Squid and glow squid
3. Dolphin
4. Axolotl
5. Fish: cod, salmon, pufferfish, tropical fish
6. Nautilus and zombie nautilus
7. Boats and rafts
8. Worked examples
9. Validation
- Appendix A. Keyframe animation data (baby axolotl, nautilus)
- Open questions

---

## 0. Conventions and engine facts used by every section

### 0.1 Reading the model tables

Every model is a tree of parts. A part has a pose (offset, rotation, scale), zero or more boxes, and children. Tables below use:

| Column | Meaning |
|---|---|
| Part | the child name used by `getChild` and by the animation definitions |
| Parent | the part it is attached to (`root` = the mesh root, which has the identity pose unless noted) |
| Pose | `off(x,y,z)` offset in model pixels; `rot(x,y,z)` rotation in radians; both when both are given. No scale unless stated |
| Boxes | `tex(u,v) origin(x,y,z) size(w,h,d)` then optionally `grow g` (a `CubeDeformation`) and `mirror` |

Model space is in pixels (1/16 block). A part is drawn as: translate by (x, y, z) / 16, rotate by `rotationZYX(zRot, yRot, xRot)`, scale by (xScale, yScale, zScale) when any differs from 1; children are drawn inside that transform (`ModelPart.translateAndRotate`, `ModelPart.render`). A box of size (w, h, d) at origin (x, y, z) with grow g covers x-g to x+w+g (same for y and z); the texture rectangles come from the undeformed w, h, d (so growing never moves texture coordinates). The box unwrap is 14 section 5.3. A `mirror` box has the two x-corner values exchanged and the winding reversed (`ModelPart$Cube`, `ModelPart$Polygon.mirrorFacing`); the rectangles keep the numbers of the unmirrored layout (Open question 1 on pixel orientation).

`addOrReplaceChild(name, def)` when the name already exists replaces the part's own boxes and pose and **keeps the old part's children** (`PartDefinition.addOrReplaceChild`). This matters for the nautilus layers (section 6.3).

A texture of each layer definition has a declared size (width x height in texels). A pack texture that is a whole multiple of it lines up (14 section 5.2).

### 0.2 Pose scaling transformer

`MeshTransformer.scaling(s)` (used by `SalmonModel.SMALL_TRANSFORMER`, `LARGE_TRANSFORMER`, and declared but not referenced by a layer registration in `SquidModel.BABY_TRANSFORMER` and `DolphinModel.BABY_TRANSFORMER`, both `scaling(0.5)`): the mesh root pose becomes `pose.scaled(s).translated(0, 24.016 * (1 - s), 0)`. Only the root pose changes; the root has the identity pose, so the whole model is scaled by s about the model-space point y = 24.016 and every child inherits it. Values: s = 0.5 gives root scale 0.5 and y = +12.008; s = 1.5 gives scale 1.5 and y = -12.008.

### 0.3 Sine and cosine used by the models

`Mth.sin(x)` and `Mth.cos(x)` are table lookups: `SIN[i] = (float) Math.sin(i / 10430.378350470453)` for `i` in 0 to 65535; `sin(x) = SIN[(long)(x * 10430.378350470453) & 65535]`; `cos(x) = SIN[(long)(x * 10430.378350470453 + 16384.0) & 65535]` (`Mth`). Tolerances in tests should allow about 1e-4. `Math.cos` and `Math.sin` (full precision, on doubles) are used only where stated: the squid tentacle layout (section 2) and the boat bubble-column angle (section 7.3, `AbstractBoat.tickBubbleColumn`, read as a `Math.sin` call on a double, not the `Mth.sin` table).

### 0.4 Animation engine and living pipeline (cited)

The keyframe engine (`KeyframeAnimation.apply`, `applyWalk`, channel sampling, `LINEAR` and `CATMULLROM`, `posVec`, `degreeVec`, `scaleVec`, additive application on the current pose, looping) is 34-3 section 0.2; this round re-read the same classes and found them identical (note: `getTimeInMillis` is `(long)((ageInTicks - startTick) * 50)`; `applyWalk(pos, speed, a, b)` uses `ms = (long)(pos * 50 * a)` and strength `min(speed * b, 1)`). The living pipeline (push, scale, `setupRotations`, scale (-1,-1,1), translate (0,-1.501,0), `setupAnim` once on the renderer's current model, then layers in registration order with the same pose stack; the default model render type `entityCutout`) is 34-3 section 0.3; this round re-read `LivingEntityRenderer.submit` and `EntityModel` (default render function `RenderTypes.entityCutout`) and found the same. `Model.setupAnim` first calls `resetPose` on every part (load the part's initial pose), so every `setupAnim` below starts from the baked pose. **Every submitted model is posed at draw time**: `ModelFeatureRenderer.prepareModel` calls `model.setupAnim(state)` and then `renderToBuffer` for each submitted model with the state that was submitted with it (this was read in this round). So a layer's own model (the tropical pattern models, the nautilus saddle, armor and coral models, the boat water patch with its unit state) runs its own `setupAnim` with the entity's state just before it is drawn; the explicit `setupAnim` call in `LivingEntityRenderer.submit` before the layers only serves layers that read the main model's parts.

### 0.5 Render type and light

Unless a section says otherwise a model is drawn with `entityCutout(texture)` (alpha cutout), the entity's light coordinates, the overlay from `getOverlayCoords(state, 0)` and tint white. `AgeableMobRenderer.submit` swaps the renderer's current model to the baby model when `state.isBaby`, otherwise the adult model, before the common submit. Shadow radius = renderer base radius x `state.scale` (`LivingEntityRenderer.getShadowRadius`); 34-3 section 0.3 item 6 states the extra `ageScale` factor for mobs; both are in this document's tables only as the **base radius**.

---

## 1. Family overview

### 1.1 Entity type to renderer (`EntityRenderers`)

| Entity type | Renderer (constructor) | Model layer(s) baked | Base shadow radius |
|---|---|---|---|
| `squid` | `SquidRenderer` with two `SquidModel` instances | `squid` (adult), `squid_baby` (baby) | 0.7 |
| `glow_squid` | `GlowSquidRenderer` (extends `SquidRenderer`) with two `SquidModel` | `glow_squid`, `glow_squid_baby` (same definitions as the squid layers) | 0.7 |
| `dolphin` | `DolphinRenderer` | `dolphin`, `dolphin_baby`; layer `DolphinCarryingItemLayer` | 0.7 |
| `axolotl` | `AxolotlRenderer` | `axolotl` (`AdultAxolotlModel`), `axolotl_baby` (`BabyAxolotlModel`) | 0.5 |
| `cod` | `CodRenderer` | `cod` | 0.3 |
| `salmon` | `SalmonRenderer` | `salmon_small`, `salmon` (medium), `salmon_large` | 0.4 |
| `pufferfish` | `PufferfishRenderer` | `pufferfish_small`, `pufferfish_medium`, `pufferfish_big` | 0.1 + 0.1 x puffState (section 5.3); the constructor passes 0.2 to `MobRenderer` but `getShadowRadius` is overridden, so 0.2 is never used |
| `tropical_fish` | `TropicalFishRenderer` | `tropical_fish_small`, `tropical_fish_large`; layer `TropicalFishPatternLayer` with `tropical_fish_small_pattern`, `tropical_fish_large_pattern` | 0.15 |
| `nautilus` | `NautilusRenderer` | `nautilus`, `nautilus_baby`; layers body armor (`nautilus_armor`, adult only) and saddle (`nautilus_saddle`, adult only); both layers are built with a null baby model (`aconst_null` read in `NautilusRenderer` and `ZombieNautilusRenderer`) | 0.7 |
| `zombie_nautilus` | `ZombieNautilusRenderer` | `zombie_nautilus` (same definition as `nautilus`), `zombie_nautilus_coral`; the same two equipment layers | 0.7 |
| `<wood>_boat`, `<wood>_chest_boat` for `oak spruce birch jungle acacia cherry dark_oak pale_oak mangrove poplar` | `BoatRenderer(layer)` | `boat/<wood>`, `chest_boat/<wood>`, and the shared `boat#water_patch` | 0.8 |
| `bamboo_raft`, `bamboo_chest_raft` | `RaftRenderer(layer)` | `boat/bamboo`, `chest_boat/bamboo` | 0.8 |

Note: the registry builds the baby squid with the class `SquidModel` over the layer `squid_baby`; the class `BabySquidModel` (a subclass with no changes except its layer-building method) is used only through its static `createBodyLayer`, which defines the `squid_baby` and `glow_squid_baby` layers (`LayerDefinitions`). Likewise `BabyDolphinModel` defines `dolphin_baby`, and the renderer builds a plain `DolphinModel` over it.

### 1.2 Texture files named by the renderers (whole-image textures, ids in `minecraft:`; the files are data)

| Entity | Texture path rule |
|---|---|
| squid | `textures/entity/squid/squid.png`, baby `squid_baby.png` |
| glow squid | `textures/entity/squid/glow_squid.png`, baby `glow_squid_baby.png` |
| dolphin | `textures/entity/dolphin/dolphin.png`, baby `dolphin_baby.png` |
| axolotl | `textures/entity/axolotl/axolotl_<variant>.png` and `axolotl_<variant>_baby.png`, `<variant>` from `lucy wild gold cyan blue` (section 4.4) |
| cod | `textures/entity/fish/cod.png` |
| salmon | `textures/entity/fish/salmon.png` (all three sizes) |
| pufferfish | `textures/entity/fish/pufferfish.png` (all three states) |
| tropical fish | base `textures/entity/fish/tropical_a.png` (small) or `tropical_b.png` (large); pattern layer `tropical_a_pattern_1..6.png` and `tropical_b_pattern_1..6.png` (section 5.4) |
| nautilus | `textures/entity/nautilus/nautilus.png`, baby `nautilus_baby.png` |
| zombie nautilus | the variant's `asset_id` (section 6.5): `entity/nautilus/zombie_nautilus` and `entity/nautilus/zombie_nautilus_coral` in the shipped data |
| boats | `textures/entity/boat/<wood>.png` and `textures/entity/chest_boat/<wood>.png` where `<wood>` is the part after the slash of the model layer id (`boat/oak` gives `textures/entity/boat/oak.png`); the path is built by the `withPath` lambda in `BoatRenderer` (`lambda$new$0`), which concatenates the prefix, the layer path and the extension; the jar contains 11 files in each directory (the ten woods above and `bamboo`) |

(Counts read with `unzip -Z1 ... | grep -v '/$'`: 10 axolotl files (5 variants x 2); 17 files in `fish/` (cod, pufferfish, salmon, tropical_a, tropical_b and 12 pattern files); 4 nautilus files; 4 squid files; 2 dolphin files; 11 + 11 boat files.)

### 1.3 Hitbox, eye height, baby rule and name tag (cross-reference)

Hitbox and eye height are entity data and live in [18-mob-framework.md](18-mob-framework.md) (the type table). Values read there, repeated for convenience (width x height, eye height, in blocks):

| Entity | w x h | Eye |
|---|---|---|
| squid | 0.8 x 0.8 | 0.4 |
| glow_squid | 0.8 x 0.8 | 0.4 |
| dolphin | 0.9 x 0.6 | 0.3 |
| axolotl | 0.75 x 0.42 | 0.2751 |
| cod | 0.5 x 0.3 | 0.195 |
| salmon | 0.7 x 0.4 | 0.26 |
| pufferfish | 0.7 x 0.7 | 0.455 |
| tropical_fish | 0.5 x 0.4 | 0.26 |
| nautilus, zombie_nautilus | 0.875 x 0.95 | 0.2751 |
| every boat, chest boat, bamboo raft and bamboo chest raft | 1.375 x 0.5625 | 0.5625 |

- **Baby rule.** `SquidRenderer`, `DolphinRenderer`, `AxolotlRenderer` and `NautilusRenderer` declare no `scale` override (their method lists were read). A baby is therefore drawn only by swapping to the baby model (section 1.1, `AgeableMobRenderer.submit`), which is built smaller; the pipeline scale is `state.scale` (the entity's `scale` attribute via `getScale`) for adult and baby alike. The only age factor that reaches these renderers is `ageScale` (0.5 for a baby), which multiplies the shadow radius (section 0.5). The unused `BABY_TRANSFORMER` constants (section 0.2) do not take part.
- **Name tag.** The renderers read here override no name tag code; they use the common path (`EntityRenderer.extractNameTags`: the attachment is taken from the entity's attachment table, `EntityAttachment.NAME_TAG`, index 0, with the entity's yaw). The type table of 18 section 1.1.1 declares no name tag attachment for these types, so the fallback of the `NAME_TAG` attachment applies, which is `AT_HEIGHT` = the point (0, h, 0) with h the entity's box height (read in `EntityAttachment` and `EntityAttachment$Fallback`): squid and glow squid 0.8, dolphin 0.6, axolotl 0.42, cod 0.3, salmon 0.4, pufferfish 0.7, tropical fish 0.4, nautilus and zombie nautilus 0.95, boats and rafts 0.5625 (blocks above the entity position; the dimensions are the table above, whether the attachment is built from the scaled dimensions was not traced). The additional lift and scale applied by `submitNameTag` itself belong to the text drawing path and were not read here (Open question 13). For other fallbacks: `AT_FEET` = (0,0,0), `AT_CENTER` = (0, h/2, 0) (the lambda shows height and 2.0; the division is inferred).
- **Passenger seats and leash of boats**: section 7.5. The nautilus and zombie nautilus rider seat (y 1.1375) is an attachment entry of the entity type table in 18 section 1.1.1 and is not repeated here; the squid, dolphin and fish rows have no attachment entry there.

---

## 2. Squid and glow squid

Behaviour: 21 section 4.5. Rendering reads these entity fields (`SquidRenderer.extractRenderState`): `tentacleAngle` = lerp(partial, `oldTentacleAngle`, `tentacleAngle`); `xBodyRot` and `zBodyRot` = lerp(partial, old, current) of the entity's `xBodyRot`, `zBodyRot` (degrees). The state also holds the standard living fields (`bodyRot`, `isBaby`, ...). The squid's `aiStep` also drives them (read here because the renderer needs their meaning):

Per tick order of `Squid.aiStep` (read in full from the bytecode; `pi` = 3.1415927, `2 pi` = 6.2831855):

1. Save the old values: `xBodyRotO`, `zBodyRotO`, `oldTentacleMovement`, `oldTentacleAngle`.
2. `tentacleMovement += tentacleSpeed`. If `tentacleMovement > 2 pi` (compared in double): on the client set it to `2 pi`; on the server subtract `2 pi`, then, **only the re-roll is gated** by a chance of 1 in 10 (`nextInt(10) == 0`): `tentacleSpeed = (1 / (random + 1)) x 0.2` (`random` = `nextFloat`, 0 to 1, so the speed is 0.1 to 0.2). After that, whether or not the re-roll happened, the server broadcasts entity event 19 (the squid animation sync event of 18 section 9): the broadcast is unconditional on every wrap past `2 pi` (read in the bytecode: the 1-in-10 test branches past the re-roll only, to the broadcast).
3. **In water**, two cases on `tentacleMovement`:
   - `tentacleMovement < pi`: `p = tentacleMovement / pi`; `tentacleAngle = sin(p x p x pi) x pi x 0.25`. Then, if `p > 0.75`: when the entity is locally authoritative (`isLocalInstanceAuthoritative`) the delta movement is set to the entity's stored movement vector (21 section 4.5), and in either case `rotateSpeed = 1`; otherwise (`p <= 0.75`) `rotateSpeed = rotateSpeed x 0.8`.
   - `tentacleMovement >= pi`: `tentacleAngle = 0`; when locally authoritative the delta movement is scaled by 0.9; `rotateSpeed = rotateSpeed x 0.99` (also when not authoritative).
   - After either case, every tick in water, with `v` = the delta movement and `h` = its horizontal length: `yBodyRot += (-atan2(vx, vz) x 57.295776 - yBodyRot) x 0.1` and then `yRot = yBodyRot`; `zBodyRot += pi x rotateSpeed x 1.5`; `xBodyRot += (-atan2(h, vy) x 57.295776 - xBodyRot) x 0.1`. (`Mth.atan2`, results cast to float; the rotateSpeed rules that set the stored movement vector are in 21 section 4.5.)
4. **Out of water**: `tentacleAngle = |sin(tentacleMovement)| x pi x 0.25`. Server only: `dy` = the current vertical delta; if the entity has levitation, `dy = 0.05 x (amplifier + 1)` (the old value is replaced, not added to); otherwise `dy = dy - gravity`; then the delta movement is set to `(0, dy x airDrag, 0)` (`getGravity`, `getAirDrag`). Both sides: `xBodyRot += (-90 - xBodyRot) x 0.02` (the squid settles belly up).

(A review note proposed "vy = gravity x airDrag" and "vy - 0.05 x (amplifier + 1)" for the out-of-water case; the artifact disagrees: levitation assigns `0.05 x (amplifier + 1)`, the non-levitating case subtracts gravity, and the air drag factor multiplies the result in both.)

### 2.1 Models (`SquidModel`, layer `squid`; `BabySquidModel.createBodyLayer`, layer `squid_baby`)

| Layer | Texture size | Part | Parent | Pose | Boxes |
|---|---|---|---|---|---|
| adult | 64 x 32 | `body` | root | off(0, 8, 0) | tex(0,0) origin(-6,-8,-6) size(12,16,12) grow 0.02 |
| adult | | `tentacle0` .. `tentacle7` | root | off(cx, 15, cz) rot(0, ry, 0), see below | tex(48,0) origin(-1,0,-1) size(2,18,2) |
| baby | 32 x 32 | `body` | root | off(0, 13, 0) | tex(0,0) origin(-4,-5,-4) size(8,10,8) |
| baby | | `tentacle0` .. `tentacle7` | root | off(cx, 18.5, cz) rot(0, ry, 0) | tex(0,18) origin(-1,-0.5,-1) size(2,6,2) |

Tentacle `i` (0 to 7), with full-precision `Math.cos`/`Math.sin` in double and then cast to float: `a = i x pi x 2 / 8`; `cx = cos(a) x R`; `cz = sin(a) x R`; `ry = i x pi x (-2) / 8 + pi / 2`. `R` = 5 (adult), 3 (baby). The part name is `tentacle` followed by the decimal index (`SquidModel.createTentacleName`).

Table of the eight adult tentacles (R = 5): i=0 (5, 15, 0) ry 1.5708; i=1 (3.5355, 15, 3.5355) ry 0.7854; i=2 (0, 15, 5) ry 0; i=3 (-3.5355, 15, 3.5355) ry -0.7854; i=4 (-5, 15, 0) ry -1.5708; i=5 (-3.5355, 15, -3.5355) ry -2.3562; i=6 (0, 15, -5) ry -3.1416; i=7 (3.5355, 15, -3.5355) ry -3.9270. (cos(pi/2) in double is 6.1e-17, not exactly 0.)

`setupAnim`: after the reset, every tentacle part's `xRot` is **set** (not added) to `state.tentacleAngle`.

### 2.2 Renderer (`SquidRenderer`)

- Texture: baby ? baby file : adult file (section 1.2). Glow squid: its own two files.
- `setupRotations(state, poseStack, bodyRot, scale)` replaces the default completely (no death flip and no other cases): in order, translate (0, 0.5, 0) (baby: (0, 0.25, 0)); rotate about Y by `180 - bodyRot` degrees; rotate about X by `xBodyRot` degrees; rotate about **Y** by `zBodyRot` degrees (the field named z is applied about the Y axis); translate (0, -1.2, 0) (baby: (0, -0.6, 0)). Then the pipeline's scale(-1,-1,1) and translate(0,-1.501,0) follow.
- Glow squid (`GlowSquidRenderer.getBlockLightLevel`): `i = (int) clampedLerp(1 - darkTicksRemaining / 10, 0, 15)` (clampedLerp(t, a, b) = a if t < 0, b if t > 1, else a + (b - a) t; the cast truncates). If `i == 15` the block light is 15; otherwise it is `max(i, normal block light at the position)`. `darkTicksRemaining` is the entity's counter (21 section 4.5: 100 after a hit, decrementing). Example: counter 5 gives `i = 7`; counter 0 gives 15; counter 10 or more gives 0 (then the normal light applies).

---

## 3. Dolphin

### 3.1 Models (texture 64 x 64 for both)

Adult (`DolphinModel.createBodyLayer`, layer `dolphin`):

| Part | Parent | Pose | Boxes |
|---|---|---|---|
| `body` | root | off(0, 22, -5) | tex(22,0) origin(-4,-7,0) size(8,7,13) |
| `back_fin` | body | rot(1.0471976, 0, 0) | tex(51,0) origin(-0.5,0,8) size(1,4,5) |
| `left_fin` | body | off(2,-2,4) rot(1.0471976, 0, 2.0943952) | tex(48,20) origin(-0.5,-4,0) size(1,4,7) mirror |
| `right_fin` | body | off(-2,-2,4) rot(1.0471976, 0, -2.0943952) | tex(48,20) origin(-0.5,-4,0) size(1,4,7) |
| `tail` | body | off(0,-2.5,11) rot(-0.10471976, 0, 0) | tex(0,19) origin(-2,-2.5,0) size(4,5,11) |
| `tail_fin` | tail | off(0, 0, 9) | tex(19,20) origin(-5,-0.5,0) size(10,1,6) |
| `head` | body | off(0,-4,-3) | tex(0,0) origin(-4,-3,-3) size(8,7,6) |
| `nose` | head | identity | tex(0,13) origin(-1,2,-7) size(2,2,4) |

Baby (`BabyDolphinModel.createBodyLayer`, layer `dolphin_baby`; every box grow 0):

| Part | Parent | Pose | Boxes |
|---|---|---|---|
| `body` | root | off(0, 21.5, 0) | tex(20,0) origin(-3,-2.5,-4) size(6,5,8) |
| `head` | body | off(0, 1, -4) | tex(0,0) origin(-3,-3.5,-4) size(6,5,4) |
| `nose` | head | off(0, 0.5, -4) | tex(0,9) origin(-1,-1,-2) size(2,2,2) |
| `left_fin` | body | off(1.8, 0.85, -2.6) rot(0.8727, 0, 1.7017) | tex(34,18) origin(-0.5,-1.5,-0.5) size(1,3,6) |
| `right_fin` | body | off(-1.8, 0.85, -2.6) rot(0.8727, 0, -1.7017) | tex(48,18) origin(-0.5,-1.5,-0.5) size(1,3,6) mirror |
| `tail` | body | off(0, 1, 4) | tex(0,13) origin(-2,-1.5,0) size(4,3,7) |
| `tail_fin` | tail | off(0, 0, 6) | tex(22,13) origin(-4,-0.5,-1) size(8,1,4) |
| `back_fin` | body | off(0,-1,-2.7) rot(0.8727, 0, 0) | tex(42,0) origin(-0.5,-1,1) size(1,3,4) |

Note that the adult head is a child of the body (it follows body rotation), and that the baby's head is a child of the body, the nose of the head.

### 3.2 `setupAnim` (both ages; names `body`, `tail` = body child `tail`, `tail_fin` = tail child `tail_fin`)

State fields: `xRot`, `yRot` (degrees, the standard living fields: pitch and head-minus-body yaw), `isMoving`, `ageInTicks`. Let `c = Mth.cos(0.3 x ageInTicks)`.

1. `body.xRot = xRot x 0.017453292`; `body.yRot = yRot x 0.017453292`.
2. If `isMoving`: `body.xRot += -0.05 - 0.05 x c`; `tail.xRot = -0.1 x c`; `tail_fin.xRot = -0.2 x c`. Otherwise the tail parts keep the baked pose.

`isMoving` (extraction) = (horizontal squared length of the delta movement) > 1.0E-7.

### 3.3 Renderer and carried item layer

- Texture: baby ? `dolphin_baby.png` : `dolphin.png`.
- Extraction also stores `heldItem` = the entity's main-hand item resolved with display context `GROUND` (`HoldingEntityRenderState.extractHoldingEntityRenderState`).
- `DolphinCarryingItemLayer` (registered once): if `heldItem` is empty nothing is drawn. Otherwise, with `p = |state.xRot| / 60` and the pose stack as left by the pipeline (model space after scale(-1,-1,1) and translate(0,-1.501,0)): translate by (0, 1 - 0.5 p, -1 + 0.5 p) when `state.xRot < 0`, else by (0, 1 + 0.8 p, -1 + 0.2 p) (xRot = 0 takes the else branch); draw the item with the overlay `NO_OVERLAY`, the entity light and outline colour. The whole item draw is wrapped in a pose push and pop, so the translate does not leak into later layers; the layer applies no rotation or scale of its own, and the item's `GROUND` display transform (12 section 8) applies.

---

## 4. Axolotl

### 4.1 Adult model (`AdultAxolotlModel.createBodyLayer`, layer `axolotl`, texture 64 x 64)

`G` = a grow of 0.001 on every box marked "G" (exactly six boxes: the head, the top, left and right gill boxes, and the two leg boxes, each of which is shared by its left and right pair; the two body boxes and the tail box use the plain `addBox` and have no grow).

| Part | Parent | Pose | Boxes |
|---|---|---|---|
| `body` | root | off(0, 19.5, 5) | tex(0,11) origin(-4,-2,-9) size(8,4,10); tex(2,17) origin(0,-3,-8) size(0,5,9) |
| `head` | body | off(0, 0, -9) | tex(0,1) origin(-4,-3,-5) size(8,5,5) G |
| `top_gills` | head | off(0, -3, -1) | tex(3,37) origin(-4,-3,0) size(8,3,0) G |
| `left_gills` | head | off(-4, 0, -1) | tex(0,40) origin(-3,-5,0) size(3,7,0) G |
| `right_gills` | head | off(4, 0, -1) | tex(11,40) origin(0,-5,0) size(3,7,0) G |
| `right_hind_leg` | body | off(-3.5, 1, -1) | tex(2,13) origin(-2,0,0) size(3,5,0) G |
| `left_hind_leg` | body | off(3.5, 1, -1) | tex(2,13) origin(-1,0,0) size(3,5,0) G |
| `right_front_leg` | body | off(-3.5, 1, -8) | tex(2,13) origin(-2,0,0) size(3,5,0) G |
| `left_front_leg` | body | off(3.5, 1, -8) | tex(2,13) origin(-1,0,0) size(3,5,0) G |
| `tail` | body | off(0, 0, 1) | tex(2,19) origin(0,-3,0) size(0,5,12) |

(The left gill part sits at x = -4 and the right at x = +4 as read; the box offsets are in the table. Boxes of width or depth 0 are flat quads.)

### 4.2 Adult `setupAnim`

Inputs from the state: `playingDeadFactor` (pd), `inWaterFactor` (iw), `onGroundFactor` (og), `movingFactor` (mv), `ageInTicks` (A), `xRot`, `yRot` (degrees). All factors are in 0 to 1 (section 4.5). Define `nm = 1 - mv`, `lay = 1 - min(og, mv)`.

1. `body.yRot += yRot x 0.017453292`.
2. `swim(A, xRot, min(mv, iw))`, `hover(A, min(nm, iw))`, `crawl(A, min(mv, og))`, `layStill(A, min(nm, og))`, `playDead(pd)`, then `mirrorLegs(lay)`. Every sub-animation returns immediately when its weight w is <= 1.0E-5. All additions are to the current value (the poses are cumulative: later steps add onto earlier ones). `s(.)` and `c(.)` are the table sine and cosine of 0.3.

**swim(A, pitchDeg, w)**: `t = A x 0.33`, `S = sin(t)`, `C = cos(t)`, `k = 0.13 S`.
`body.xRot += (pitchDeg x 0.017453292 + k) w`; `head.xRot -= (k x 1.8) w`; `body.y -= (0.45 C) w`; `top_gills.xRot += (-0.5 S - 0.8) w`; `g = (0.3 S + 0.9) w`: `left_gills.yRot += g`, `right_gills.yRot -= g`; `tail.yRot += (0.3 x cos(t x 0.9)) w`; `left_hind_leg`: xRot += 1.8849558 w, yRot += (-0.4 S) w, zRot += 1.5707964 w; `left_front_leg`: xRot += 1.8849558 w, yRot += (-0.2 C - 0.1) w, zRot += 1.5707964 w.

**hover(A, w)**: `t = A x 0.075`, `C = cos(t)`, `Sd = sin(t) x 0.15`, `h = (-0.15 + 0.075 C) w`.
`body.xRot += h`; `body.y -= Sd w`; `head.xRot -= h`; `top_gills.xRot += (0.2 C) w`; `g = (-0.3 C - 0.19) w`: `left_gills.yRot += g`, `right_gills.yRot -= g`; `left_hind_leg`: xRot += (2.3561945 - 0.11 C) w, yRot += 0.47123894 w, zRot += 1.7278761 w; `left_front_leg`: xRot += (0.7853982 - 0.2 C) w, yRot += 2.042035 w; `tail.yRot += (0.5 C) w`.

**crawl(A, w)**: `t = A x 0.11`, `C = cos(t)`, `q = (C x C - 2 C) / 5`, `r = 0.7 C`, `hy = (0.09 C) w`.
`head.yRot += hy`; `tail.yRot += hy`; `g = (0.6 - 0.08 (C x C + 2 sin(t))) w`: `top_gills.xRot += g`, `left_gills.yRot -= g`, `right_gills.yRot += g`; `u = 0.9424779 w`, `v = 1.0995574 w`:
`left_hind_leg`: xRot += u, yRot += (1.5 - q) w, zRot += -0.1 w; `left_front_leg`: xRot += v, yRot += (1.5707964 - r) w; `right_hind_leg`: xRot += u, yRot += (-1 - q) w; `right_front_leg`: xRot += v, yRot += (-1.5707964 - r) w.

**layStill(A, w)**: `t = A x 0.09`, `S = sin(t)`, `C = cos(t)`, `m = S x S - 2 S`, `n = C x C - 3 S`.
`head.xRot += (-0.09 m) w`; `head.zRot += -0.2 w`; `tail.yRot += (-0.1 + 0.1 m) w`; `g = (0.6 + 0.05 n) w`: `top_gills.xRot += g`, `left_gills.yRot -= g`, `right_gills.yRot += g`; `left_hind_leg`: xRot += 1.1 w, yRot += 1 w; `left_front_leg`: xRot += 0.8 w, yRot += 2.3 w, zRot -= 0.5 w.

**playDead(w = pd)**: `left_hind_leg`: xRot += 1.4137167 w, yRot += 1.0995574 w, zRot += 0.7853982 w; `left_front_leg`: xRot += 0.7853982 w, yRot += 2.042035 w; `body.xRot += -0.15 w`; `body.zRot += 0.35 w`.

**mirrorLegs(w = lay)** (runs last): for each of hind and front: `right.xRot += left.xRot x w`; `right.yRot += -left.yRot x w`; `right.zRot += -left.zRot x w` (the left leg's value at that moment, which already includes everything above; the right leg's own earlier additions stay).

### 4.3 Baby model (`BabyAxolotlModel.createBodyLayer`, layer `axolotl_baby`, texture 32 x 32; boxes have grow 0)

| Part | Parent | Pose | Boxes |
|---|---|---|---|
| `root` | root | off(0, 24, 0) | none |
| `body` | `root` | off(0, -1.25, 1.75) | tex(0,0) origin(-2,-0.75,-2.75) size(4,2,6); tex(0,12) origin(0,-1.75,-2.75) size(0,3,5) |
| `right_front_leg` | body | off(-2, 0.25, -1.25) | tex(20,16) origin(-3,0,-0.5) size(3,0,1) |
| `right_hind_leg` | body | off(-2, 0.25, 1.75) rot(0, 1.5708, 1.5708) | none |
| `right_leg_r1` | right_hind_leg | rot(-1.5708, 0, 1.5708) | tex(20,14) origin(0,0,-0.5) size(3,0,1) |
| `left_front_leg` | body | off(2, 0.25, -1.25) | tex(20,13) origin(0,0,-0.5) size(3,0,1) |
| `left_hind_leg` | body | off(2, 0.25, 1.75) | tex(20,14) origin(0,0,-0.5) size(3,0,1) |
| `tail` | body | off(0, -0.25, 3.25) | tex(10,9) origin(0,-1.5,-1) size(0,3,8) |
| `head` | body | off(0, 0.25, -2.75) | tex(0,8) origin(-3,-2,-4) size(6,3,4) |
| `left_gills` | head | off(3, -0.5, -2) | tex(20,8) origin(0,-3.5,0) size(3,5,0) |
| `right_gills` | head | off(-3, -0.5, -2) | tex(20,3) origin(-3,-3.5,0) size(3,5,0) |
| `top_gills` | head | off(0, -2, -2) | tex(20,0) origin(-3,-3,0) size(6,3,0) |

### 4.4 Baby `setupAnim`, renderer, variants

Seven animations are baked from `BabyAxolotlAnimation` (Appendix A.1): `swim` (`BABY_AXOLOTL_SWIM`), `walk` (`AXOLOTL_WALK_FLOOR`), `walkUnderwater` (`WALK_FLOOR_UNDERWATER`), `idleUnderWater` (`IDLE_UNDERWATER`), `idleOnGroundUnderWater` (`IDLE_FLOOR_UNDERWATER`), `idleOnGround` (`BABY_AXOLOTL_IDLE_FLOOR`), `playDead` (`BABY_AXOLOTL_PLAY_DEAD`). After the reset, in this order:

1. If the render state's `walkAnimationState` is started: `walk.applyWalk(walkAnimationPos, walkAnimationSpeed, 15, 30)` (so `ms = (long)(pos x 50 x 15)`, strength `min(speed x 30, 1)`).
2. `swim.apply(state.swimAnimation, A)`; 3. `walkUnderwater.apply(state.walkAnimationState, A)` (the field read is the **same** `walkAnimationState` as in step 1; see Open question 3); 4. `idleOnGround.apply(state.idleOnGroundAnimationState, A)`; 5. `idleUnderWater.apply(state.idleUnderWaterAnimationState, A)`; 6. `idleOnGroundUnderWater.apply(state.idleUnderWaterOnGroundAnimationState, A)`; 7. `playDead.apply(state.playDeadAnimationState, A)`. A stopped state applies nothing.

Renderer `AxolotlRenderer` (`AgeableMobRenderer`, base shadow 0.5): texture = lookup of `state.variant` in a table built at class load from `Axolotl$Variant.values()`: `textures/entity/axolotl/axolotl_<name>.png` and `..._<name>_baby.png`. Variants (`Axolotl$Variant`): id 0 `lucy`, 1 `wild`, 2 `gold`, 3 `cyan`, 4 `blue` (the enum's last constructor argument is the boolean field `common`: true for `lucy`, `wild`, `gold`, `cyan`, false for `blue`; `getCommonSpawnVariant` and `getRareSpawnVariant` filter the values on it, the spawn rules are in 44 section 8.1). `DEFAULT` is `lucy` (assigned in the static initializer). The id lookup `byId` is a continuous id map with the out-of-bounds strategy ZERO, so an id outside 0 to 4 gives `lucy`.

### 4.5 Where the animation inputs come from (`Axolotl.baseTick`, client side only; `AxolotlRenderer.extractRenderState`)

On the client, once per `baseTick` the entity runs `tickBabyAnimations` (baby) or `tickAdultAnimations` (adult). Four `BinaryAnimator`s exist (`playingDead`, `inWater`, `onGround`, `moving`), each with length 10 and easing `IN_OUT_SINE`. `BinaryAnimator.tick(flag)`: `ticksOld = ticks`; if `flag` and `ticks < 10` then `ticks++`; else if not `flag` and `ticks > 0` then `ticks--`. `getFactor(partial) = ease(lerp(partial, ticksOld, ticks) / 10)` with `ease(x) = -(cos(pi x) - 1) / 2` (`Ease.inOutSine`, `Mth.cos`). `moving` flag = `walkAnimation.isMoving()` or `xRot != xRotO` or `yRot != yRotO`.

Adult: the exclusive state is, by priority, PLAYING_DEAD (`isPlayingDead`), IN_WATER (`isInWater`), ON_GROUND (`onGround`), otherwise IN_AIR; the `playingDead`, `inWater`, `onGround` animators tick with the flag "the exclusive state equals mine"; the `moving` animator ticks with the moving flag. (No `AnimationState` is driven for adults.)

Baby: the `moving` animator ticks as above; then exactly one `AnimationState` is chosen and started with `startIfStopped(tickCount)` (all others in the list `swim, walk, walkUnderWater, idleUnderWater, idleUnderWaterOnGround, idleOnGround, playDead` are stopped, `soloAnimation`): if playing dead then `playDead`; else if moving: (in water and not on ground) `swim`, else (not in water and on ground) `walk`, else `walkUnderWater`; else (not moving): (in water and not on ground) `idleUnderWater`, else (in water and on ground) `idleUnderWaterOnGround`, else `idleOnGround`.

Extraction copies the four factors (`getFactor(partial)`), the variant and every `AnimationState`'s start tick into the render state. Initial render-state values: `inWaterFactor = 1`, the variant `DEFAULT` (that is `lucy`), all states stopped.

---

## 5. Fish

All four fish renderers extend `MobRenderer` (no baby models). Behaviour and variants: 21 section 4.2 to 4.4.

### 5.1 Cod (`CodModel`, layer `cod`, texture 32 x 32)

| Part | Parent | Pose | Boxes |
|---|---|---|---|
| `body` | root | off(0, 22, 0) | tex(0,0) origin(-1,-2,0) size(2,4,7) |
| `head` | root | off(0, 22, 0) | tex(11,0) origin(-1,-2,-3) size(2,4,3) |
| `nose` | root | off(0, 22, -3) | tex(0,0) origin(-1,-2,-1) size(2,3,1) |
| `right_fin` | root | off(-1, 23, 0) rot(0, 0, -0.7853982) | tex(22,1) origin(-2,0,-1) size(2,0,2) |
| `left_fin` | root | off(1, 23, 0) rot(0, 0, 0.7853982) | tex(22,4) origin(0,0,-1) size(2,0,2) |
| `tail_fin` | root | off(0, 22, 7) | tex(22,3) origin(0,-2,0) size(0,4,4) |
| `top_fin` | root | off(0, 20, 0) | tex(20,-6) origin(0,-1,-1) size(0,1,6) |

`setupAnim`: `f = 1` if `isInWater`, else 1.5; `tail_fin.yRot = (-f x 0.45) x sin(0.6 x ageInTicks)` (set, not added).
Renderer: texture `fish/cod.png`; shadow 0.3. `setupRotations`: default super, then rotate about Y by `4.3 x sin(0.6 x ageInTicks)` degrees; when not in water, additionally translate (0.1, 0.1, -0.1) and rotate about Z by 90 degrees (the fish lies on its side).

### 5.2 Salmon (`SalmonModel`, layers `salmon`, `salmon_small`, `salmon_large`, texture 32 x 32)

| Part | Parent | Pose | Boxes |
|---|---|---|---|
| `body_front` | root | off(0, 20, -7.2) | tex(0,0) origin(-1.5,-2.5,0) size(3,5,8) |
| `body_back` | root | off(0, 20, 0.8000002) | tex(0,13) origin(-1.5,-2.5,0) size(3,5,8) |
| `head` | root | off(0, 20, -7.2) | tex(22,0) origin(-1,-2,-3) size(2,4,3) |
| `back_fin` | body_back | off(0, 0, 8) | tex(20,10) origin(0,-2.5,0) size(0,5,6) |
| `top_front_fin` | body_front | off(0, -4.5, 5) | tex(2,1) origin(0,0,0) size(0,2,3) |
| `top_back_fin` | body_back | off(0, -4.5, -1) | tex(0,2) origin(0,0,0) size(0,2,4) |
| `right_fin` | root | off(-1.5, 21.5, -7.2) rot(0, 0, -0.7853982) | tex(-4,0) origin(-2,0,0) size(2,0,2) |
| `left_fin` | root | off(1.5, 21.5, -7.2) rot(0, 0, 0.7853982) | tex(0,0) origin(0,0,0) size(2,0,2) |

`salmon_small` is the same mesh with `MeshTransformer.scaling(0.5)`, `salmon_large` with `scaling(1.5)` (section 0.2); `salmon` is the unscaled medium. `setupAnim`: `a = 1, b = 1` in water, `a = 1.3, b = 1.7` out of water; `body_back.yRot = (-a x 0.25) x sin(b x 0.6 x ageInTicks)`.
Renderer (`SalmonRenderer`): state field `variant` (`Salmon$Variant`: `SMALL` 0 "small" box scale 0.5, `MEDIUM` 1 "medium" 1.0, `LARGE` 2 "large" 1.5; default `MEDIUM`); each `submit` sets the current model to the small, medium or large model by the variant before the common submit. The id map `Salmon$Variant.BY_ID` is continuous with out-of-bounds strategy CLAMP: an id above 2 gives LARGE, below 0 gives SMALL. Texture `fish/salmon.png`; shadow 0.4. `setupRotations`: super; with `a, b` as above, rotate about Y by `(a x 4.3) x sin(b x 0.6 x ageInTicks)` degrees; when not in water translate (0.2, 0.1, 0) then rotate about Z by 90 degrees.

### 5.3 Pufferfish (`PufferfishSmallModel`, `PufferfishMidModel`, `PufferfishBigModel`; layers `pufferfish_small`, `pufferfish_medium`, `pufferfish_big`; all texture 32 x 32)

**Small** (`PufferfishSmallModel`), parent root for all:

| Part | Pose | Boxes |
|---|---|---|
| `body` | off(0, 23, 0) | tex(0,27) origin(-1.5,-2,-1.5) size(3,2,3) |
| `right_eye` | off(0, 20, 0) | tex(24,6) origin(-1.5,0,-1.5) size(1,1,1) |
| `left_eye` | off(0, 20, 0) | tex(28,6) origin(0.5,0,-1.5) size(1,1,1) |
| `back_fin` | off(0, 22, 1.5) | tex(-3,0) origin(-1.5,0,0) size(3,0,3) |
| `right_fin` | off(-1.5, 22, -1.5) | tex(25,0) origin(-1,0,0) size(1,0,2) |
| `left_fin` | off(1.5, 22, -1.5) | tex(25,0) origin(0,0,0) size(1,0,2) |

**Medium** (`PufferfishMidModel`), parent root:

| Part | Pose | Boxes |
|---|---|---|
| `body` | off(0, 22, 0) | tex(12,22) origin(-2.5,-5,-2.5) size(5,5,5) |
| `right_blue_fin` | off(-2.5, 18, -1.5) | tex(24,0) origin(-2,0,0) size(2,0,2) |
| `left_blue_fin` | off(2.5, 18, -1.5) | tex(24,3) origin(0,0,0) size(2,0,2) |
| `top_front_fin` | off(0, 17, -2.5) rot(0.7853982, 0, 0) | tex(19,17) origin(-2.5,-1,0) size(5,1,0) |
| `top_back_fin` | off(0, 17, 2.5) rot(-0.7853982, 0, 0) | tex(11,17) origin(-2.5,-1,0) size(5,1,0) |
| `right_front_fin` | off(-2.5, 22, -2.5) rot(0, -0.7853982, 0) | tex(5,17) origin(-1,-5,0) size(1,5,0) |
| `right_back_fin` | off(-2.5, 22, 2.5) rot(0, 0.7853982, 0) | tex(9,17) origin(-1,-5,0) size(1,5,0) |
| `left_back_fin` | off(2.5, 22, 2.5) rot(0, -0.7853982, 0) | tex(1,17) origin(0,-5,0) size(1,5,0) |
| `left_front_fin` | off(2.5, 22, -2.5) rot(0, 0.7853982, 0) | tex(1,17) origin(0,-5,0) size(1,5,0) |
| `bottom_back_fin` | off(-2.5, 22, 2.5) rot(0.7853982, 0, 0) | tex(18,20) origin(0,0,0) size(5,1,0) |
| `bottom_front_fin` | off(0, 22, -2.5) rot(-0.7853982, 0, 0) | tex(17,19) origin(-2.5,0,0) size(5,1,1) |

**Big** (`PufferfishBigModel`), parent root:

| Part | Pose | Boxes |
|---|---|---|
| `body` | off(0, 22, 0) | tex(0,0) origin(-4,-8,-4) size(8,8,8) |
| `right_blue_fin` | off(-4, 15, -2) | tex(24,0) origin(-2,0,-1) size(2,1,2) |
| `left_blue_fin` | off(4, 15, -2) | tex(24,3) origin(0,0,-1) size(2,1,2) |
| `top_front_fin` | off(0, 14, -4) rot(0.7853982, 0, 0) | tex(15,17) origin(-4,-1,0) size(8,1,0) |
| `top_middle_fin` | off(0, 14, 0) | tex(14,16) origin(-4,-1,0) size(8,1,1) |
| `top_back_fin` | off(0, 14, 4) rot(-0.7853982, 0, 0) | tex(23,18) origin(-4,-1,0) size(8,1,0) |
| `right_front_fin` | off(-4, 22, -4) rot(0, -0.7853982, 0) | tex(5,17) origin(-1,-8,0) size(1,8,0) |
| `left_front_fin` | off(4, 22, -4) rot(0, 0.7853982, 0) | tex(1,17) origin(0,-8,0) size(1,8,0) |
| `bottom_front_fin` | off(0, 22, -4) rot(-0.7853982, 0, 0) | tex(15,20) origin(-4,0,0) size(8,1,0) |
| `bottom_middle_fin` | off(0, 22, 0) | tex(15,20) origin(-4,0,0) size(8,1,0) |
| `bottom_back_fin` | off(0, 22, 4) rot(0.7853982, 0, 0) | tex(15,20) origin(-4,0,0) size(8,1,0) |
| `right_back_fin` | off(-4, 22, 4) rot(0, 0.7853982, 0) | tex(9,17) origin(-1,-8,0) size(1,8,0) |
| `left_back_fin` | off(4, 22, 4) rot(0, -0.7853982, 0) | tex(9,17) origin(0,-8,0) size(1,8,0) |

`setupAnim` (all three; the fins named `right_fin`/`left_fin` in the small model and `right_blue_fin`/`left_blue_fin` in the others): `rightFin.zRot = -0.2 + 0.4 x sin(0.2 x ageInTicks)`; `leftFin.zRot = 0.2 - 0.4 x sin(0.2 x ageInTicks)` (set, not added).

Renderer (`PufferfishRenderer`): `puffState` = the entity's `getPuffState()` (0, 1, 2); `submit` picks the model: 0 small, 1 medium, any other value big. Texture `fish/pufferfish.png`; shadow radius `0.1 + 0.1 x puffState`. `setupRotations`: **first** translate (0, `cos(0.05 x ageInTicks)` x 0.08, 0) (a bobbing, before the default rotation), then super. No fish-style Y wiggle and no lying on the side.

### 5.4 Tropical fish (`TropicalFishSmallModel`, `TropicalFishLargeModel`; layers `tropical_fish_small`, `tropical_fish_large` with grow 0, and `..._pattern` with grow 0.008 (`LayerDefinitions.FISH_PATTERN_DEFORMATION`); texture 32 x 32). Every box below takes the layer's `CubeDeformation` (0 for the base layer, 0.008 for the pattern layer).

**Small**, parent root:

| Part | Pose | Boxes |
|---|---|---|
| `body` | off(0, 22, 0) | tex(0,0) origin(-1,-1.5,-3) size(2,3,6) |
| `tail` | off(0, 22, 3) | tex(22,-6) origin(0,-1.5,0) size(0,3,6) |
| `right_fin` | off(-1, 22.5, 0) rot(0, 0.7853982, 0) | tex(2,16) origin(-2,-1,0) size(2,2,0) |
| `left_fin` | off(1, 22.5, 0) rot(0, -0.7853982, 0) | tex(2,12) origin(0,-1,0) size(2,2,0) |
| `top_fin` | off(0, 20.5, -3) | tex(10,-5) origin(0,-3,0) size(0,3,6) |

**Large**, parent root:

| Part | Pose | Boxes |
|---|---|---|
| `body` | off(0, 19, 0) | tex(0,20) origin(-1,-3,-3) size(2,6,6) |
| `tail` | off(0, 19, 3) | tex(21,16) origin(0,-3,0) size(0,6,5) |
| `right_fin` | off(-1, 20, 0) rot(0, 0.7853982, 0) | tex(2,16) origin(-2,0,0) size(2,2,0) |
| `left_fin` | off(1, 20, 0) rot(0, -0.7853982, 0) | tex(2,12) origin(0,0,0) size(2,2,0) |
| `top_fin` | off(0, 16, -3) | tex(20,11) origin(0,-4,0) size(0,4,6) |
| `bottom_fin` | off(0, 22, -3) | tex(20,21) origin(0,0,0) size(0,4,6) |

`setupAnim` (both sizes): `f = 1` in water, 1.5 out; `tail.yRot = (-f x 0.45) x sin(0.6 x ageInTicks)`.

**Variant fields (`TropicalFish`)**: the entity stores one 32-bit packed variant. `pattern = Pattern.byId(packed & 0xFFFF)`, `baseColor = DyeColor.byId((packed >> 16) & 255)`, `patternColor = DyeColor.byId((packed >> 24) & 255)`. Each `Pattern` has a `base` (SMALL id 0 or LARGE id 1) and an index `n` (0 to 5) and `packedId = base | (n << 8)`. The 12 patterns in enum order (ordinal; serialized name; base; index): 0 `kob` SMALL 0; 1 `sunstreak` SMALL 1; 2 `snooper` SMALL 2; 3 `dasher` SMALL 3; 4 `brinely` SMALL 4; 5 `spotty` SMALL 5; 6 `flopper` LARGE 0; 7 `stripey` LARGE 1; 8 `glitter` LARGE 2; 9 `blockfish` LARGE 3; 10 `betty` LARGE 4; 11 `clayfish` LARGE 5. So `packedId` values: small 0, 256, 512, 768, 1024, 1280; large 1, 257, 513, 769, 1025, 1281. Packing: `packed = (packedId & 0xFFFF) | ((baseColorId & 255) << 16) | ((patternColorId & 255) << 24)`. Extraction stores the colors as the dye's **texture diffuse color** (opaque ARGB), not the dye's text or firework color (`DyeColor.getTextureDiffuseColor`). Default state: pattern `flopper`, both colors -1 (white). **Decode fallbacks (read)**: `Pattern.byId` is a sparse map with default `kob` (SMALL, index 0), so any `packed & 0xFFFF` that is not one of the 12 packed ids (for example 2) decodes to `kob`; `DyeColor.byId` is a continuous map with out-of-bounds strategy ZERO, so a colour id outside the dye range decodes to white (id 0).

Dye texture diffuse colors (id: name = RGB; alpha is 0xFF): 0 white F9FFFE, 1 orange F9801D, 2 magenta C74EBD, 3 light_blue 3AB3DA, 4 yellow FED83D, 5 lime 80C71F, 6 pink F38BAA, 7 gray 474F52, 8 light_gray 9D9D97, 9 cyan 169C9C, 10 purple 8932B8, 11 blue 3C44AA, 12 brown 835432, 13 green 5E7C16, 14 red B02E26, 15 black 1D1D21.

**Renderer (`TropicalFishRenderer`)**: model by `pattern.base()`: SMALL gives the small model and texture `fish/tropical_a.png`, LARGE the large model and `fish/tropical_b.png`. `getModelTint` = `state.baseColor` (the whole base texture is multiplied by the base color, so the base PNG is grayscale-like data). Shadow 0.15. `setupRotations`: super, then Y rotation `4.3 x sin(0.6 x ageInTicks)` degrees; when not in water translate (0.2, 0.1, 0) and rotate about Z by 90 degrees.

**Pattern layer (`TropicalFishPatternLayer`, registered once)**: chooses `modelSmall` or `modelLarge` by `pattern.base()` (these are separate model instances baked from the `_pattern` layers with grow 0.008), picks the texture from the pattern: 0 `kob` `tropical_a_pattern_1`, 1 `sunstreak` `_2`, 2 `snooper` `_3`, 3 `dasher` `_4`, 4 `brinely` `_5`, 5 `spotty` `_6`, 6 `flopper` `tropical_b_pattern_1`, 7 `stripey` `_2`, 8 `glitter` `_3`, 9 `blockfish` `_4`, 10 `betty` `_5`, 11 `clayfish` `_6`; and draws it with `coloredCutoutModelCopyLayerRender(model, texture, ..., tint = state.patternColor, order 1)`: nothing is drawn if the entity is invisible; otherwise the model is drawn with `entityCutout(texture)` at sub-order 1, entity light, tint = the pattern color. The layer does not pose its models itself, but each submitted model is posed at draw time (section 0.4), so the pattern model runs the same `setupAnim` (tail wag, factor 1 in water and 1.5 out) as the base model and the pattern follows the tail exactly; the base and pattern meshes have the same part names and poses and differ only in grow.

---

## 6. Nautilus and zombie nautilus

### 6.1 Adult model (`NautilusModel.createBodyLayer` / `createBodyMesh`, layers `nautilus` and `zombie_nautilus`, texture 128 x 128; all boxes grow 0 unless stated)

| Part | Parent | Pose | Boxes |
|---|---|---|---|
| `root` | root | off(0, 29, -6) | none |
| `shell` | `root` | off(0, -13, 5) | tex(0,0) origin(-7,-10,-7) size(14,10,16); tex(0,26) origin(-7,0,-7) size(14,8,20); tex(48,26) origin(-7,0,6) size(14,8,0) |
| `body` | `root` | off(0, -8.5, 12.3) | tex(0,54) origin(-5,-4.51,-3) size(10,8,14); tex(0,76) origin(-5,-4.51,7) size(10,8,0) |
| `upper_mouth` | body | off(0, -2.51, 7) | tex(54,54) origin(-5,-2,0) size(10,4,4) grow -0.001 |
| `inner_mouth` | body | off(0, -0.51, 7.5) | tex(54,70) origin(-3,-2,-0.5) size(6,4,4) |
| `lower_mouth` | body | off(0, 1.49, 7) | tex(54,62) origin(-5,-1.98,0) size(10,4,4) grow -0.001 |

### 6.2 Baby model (`NautilusModel.createBabyBodyLayer`, layer `nautilus_baby`, texture 64 x 64)

| Part | Parent | Pose | Boxes |
|---|---|---|---|
| `root` | root | off(-0.5, 28, -0.5) | none |
| `shell` | `root` | off(3, -8, -2) | tex(0,0) origin(-6,-4,-1) size(7,4,7); tex(0,11) origin(-6,0,-1) size(7,4,9); tex(23,11) origin(-6,0,5) size(7,4,0) |
| `body` | `root` | off(0.5, -5, 3) | tex(0,24) origin(-2.5,-3.01,-1) size(5,4,7); tex(0,35) origin(-2.5,-3.01,4.1) size(5,4,0) |
| `upper_mouth` | body | off(0, -2.01, 3.9) | tex(24,24) origin(-2.5,-1,0) size(5,2,2) grow -0.001 |
| `inner_mouth` | body | off(0, -1.01, 4.9) | tex(24,32) origin(-1.5,-1,-1) size(3,2,2) |
| `lower_mouth` | body | off(0, -0.01, 3.9) | tex(24,28) origin(-2.5,-1,0) size(5,2,2) grow -0.001 |

### 6.3 `setupAnim`, the swim animation and the layer models

`NautilusModel` finds `root` (child of the mesh root), `body` (child of `root`) and bakes `NautilusAnimation.SWIMMING` (Appendix A.2). `setupAnim(state)`:

1. `body.yRot = clamp(yRot, -10, 10) x 0.017453292`; `body.xRot = clamp(xRot, -10, 10) x 0.017453292` (state `yRot`, `xRot` in degrees; set, not added).
2. `SWIMMING.applyWalk(walkAnimationPos + ageInTicks / 5, walkAnimationSpeed + 0.2, 2, 3)`: `ms = (long)((pos + A/5) x 50 x 2)`, strength `min((speed + 0.2) x 3, 1)`, the definition loops with length 1 s.

The layer models are `NautilusModel` subclasses (the saddle layer is built by `NautilusSaddleModel.createSaddleLayer`, the armor layer by `NautilusArmorModel.createBodyLayer`) whose layer definitions are built from the adult mesh **and keep the old children** (section 0.1), so each draws the whole adult hierarchy with a replaced `shell`:

| Class / layer | Texture size | Changes to the adult mesh |
|---|---|---|
| `NautilusSaddleModel`, `nautilus_saddle` | 128 x 128 | `root` replaced with off(0, 29, -6) and no boxes; `shell` replaced with off(0, -13, 5) and one box tex(0,0) origin(-7,-10,-7) size(14,10,16) grow 0.2 (the shell's other two boxes are gone); `body` and its three mouth children are kept unchanged |
| `NautilusArmorModel`, `nautilus_armor` | 128 x 128 | `root` as above; `shell` replaced with the three adult shell boxes, the first two with grow 0.01 and the third (the 14 x 8 x 0 back plate at tex(48,26)) with grow 0; `body` subtree kept |
| `ZombieNautilusCoralModel`, `zombie_nautilus_coral` | 128 x 128 | the unchanged adult mesh plus a `corals` child of `shell` (table 6.4) |

Because `body` and the mouths are kept as full boxes, the layer texture decides what shows: the saddle and armor equipment textures are expected to paint only the shell region (inferred; the texture files are data, Open question 6). Each of these models is the full `NautilusModel` machinery (`NautilusSaddleModel`, `NautilusArmorModel` and `ZombieNautilusCoralModel` extend `NautilusModel`), so each runs `NautilusModel.setupAnim` with the entity's state at draw time (section 0.4): the shell, which carries the armor or saddle boxes, follows the same body animation as the base. These layers are adult-only: the equipment layers are registered with a null baby model and `SimpleEquipmentLayer.submit` draws nothing when the entity is a baby and no baby model exists, so **baby nautiluses show no armor and no saddle**.

### 6.4 Coral layer parts (`ZombieNautilusCoralModel.createBodyLayer`)

`corals` is a child of `shell` (the shell's pose is off(0,-13,5)), with off(8, 4.5, -8), no boxes.

| Part | Parent | Pose | Boxes |
|---|---|---|---|
| `yellow_coral` | corals | off(0, -11, 11) | none |
| `yellow_coral_second` | yellow_coral | off(0, 0, 2) rot(0, -0.7854, 0) | tex(0,85) origin(-4.5,-3.5,0) size(6,8,0) |
| `yellow_coral_first` | yellow_coral | rot(0, 0.7854, 0) | tex(0,85) origin(-4.5,-3.5,0) size(6,8,0) |
| `pink_coral` | corals | off(-12.5, -18, 11) | tex(-8,94) origin(-4.5,4.5,0) size(6,0,8) |
| `pink_coral_second` | pink_coral | off(-1.5, 4.5, 4) rot(0, 0, 1.5708) | tex(-8,94) origin(-3,0,-4) size(6,0,8) |
| `blue_coral` | corals | off(-14, 0, 5.5) | none |
| `blue_second` | blue_coral | off(0, 0, -2) rot(0, 0.7854, 0) | tex(0,102) origin(-3.5,-5.5,0) size(5,10,0) |
| `blue_first` | blue_coral | rot(0, -0.7854, 0) | tex(0,102) origin(-3.5,-5.5,0) size(5,10,0) |
| `red_coral` | corals | identity | none |
| `red_coral_second` | red_coral | off(-0.5, -1, 1.5) rot(0, -0.829, 0) | tex(0,112) origin(-2.5,-5.5,0) size(4,10,0) |
| `red_coral_first` | red_coral | rot(0, 0.7854, 0) | tex(0,112) origin(-4.5,-5.5,0) size(6,10,0) |

`ZombieNautilusCoralModel.setupAnim`: after the nautilus animation, `corals.visible = state.bodyArmorItem.isEmpty()` (the coral decoration hides when body armor is worn).

### 6.5 Renderers

`NautilusRenderer` (`AgeableMobRenderer`, base shadow 0.7): texture baby ? `nautilus_baby.png` : `nautilus.png`; extraction adds `saddle` = copy of the SADDLE slot item and `bodyArmorItem` = copy of the body armor item. Two equipment layers, in order: body armor (`EquipmentClientInfo$LayerType.NAUTILUS_BODY`, model `nautilus_armor`) then saddle (`NAUTILUS_SADDLE`, model `nautilus_saddle`), each with sub-order 0 and each reading its item (`bodyArmorItem`, `saddle`). `SimpleEquipmentLayer.submit`: needs the item to have an `equippable` component with an asset id; otherwise nothing; baby with no baby model: nothing; then the equipment renderer draws the layer's model with the equipment asset textures of that layer type (the equipment asset system is 08 / 14 section 2.1; the nautilus layer types are `nautilus_body` and `nautilus_saddle`).

**Equipment ids (read from the jar)**: the equipment assets `assets/minecraft/equipment/{copper,diamond,gold,iron,netherite}.json` map the layer `nautilus_body` to the texture id `minecraft:<name>` (same name), and `equipment/saddle.json` maps `nautilus_saddle` to `minecraft:saddle`. The files present are `textures/entity/equipment/nautilus_body/{copper,diamond,gold,iron,netherite}.png` and `textures/entity/equipment/nautilus_saddle/saddle.png` (6 files). Which texels they paint is still data not examined (Open question 6).

`ZombieNautilusRenderer` (base shadow 0.7, no baby): the same two layers. Extraction adds saddle, body armor and `variant = entity.getVariant().value()` (a `ZombieNautilusVariant`). `submit` first reads `state.variant`; **when it is null it returns at once: nothing is drawn (no model, no layers, no shadow, no name tag) and no model swap happens**. Otherwise it selects the model from a map keyed by the variant's model type (`normal` gives a `NautilusModel` over `zombie_nautilus`; `warm` gives a `ZombieNautilusCoralModel` over `zombie_nautilus_coral`) and runs the common submit. Texture = the variant's `asset_id` as `textures/<asset path>.png`. The missing-texture fallback exists only in `getTextureLocation` for a null variant and is unreachable from `submit`.

Zombie nautilus variant data (`data/minecraft/zombie_nautilus_variant/<name>.json`, 2 files in the jar): fields `asset_id` (a texture id without `textures/` and `.png`), optional `model` (`normal` default or `warm`), and `spawn_conditions` (a list of `{condition?, priority}`; the condition shape `{type: "minecraft:biome", biomes: <list or tag>}`). The shipped `temperate` uses `entity/nautilus/zombie_nautilus` with priority 0, and `warm` uses `entity/nautilus/zombie_nautilus_coral` with `model: warm`, biome condition tag `#minecraft:spawns_coral_variant_zombie_nautilus` and priority 1.

---

## 7. Boats and rafts

### 7.1 Models (`BoatModel`, `RaftModel`, base `AbstractBoatModel`)

Parts are children of the root. The `boat/<wood>` layers (`createBoatModel`, texture 128 x 64) and the `chest_boat/<wood>` layers (`createChestBoatModel`, texture 128 x 128) share the common parts; the 10 wood layers of each kind are identical meshes (only the texture file differs).

**Boat common parts** (`BoatModel.addCommonParts`):

| Part | Pose | Boxes |
|---|---|---|
| `bottom` | off(0, 3, 1) rot(1.5707964, 0, 0) | tex(0,0) origin(-14,-9,-3) size(28,16,3) |
| `back` | off(-15, 4, 4) rot(0, 4.712389, 0) | tex(0,19) origin(-13,-7,-1) size(18,6,2) |
| `front` | off(15, 4, 0) rot(0, 1.5707964, 0) | tex(0,27) origin(-8,-7,-1) size(16,6,2) |
| `right` | off(0, 4, -9) rot(0, 3.1415927, 0) | tex(0,35) origin(-14,-7,-1) size(28,6,2) |
| `left` | off(0, 4, 9) | tex(0,43) origin(-14,-7,-1) size(28,6,2) |
| `left_paddle` | off(3, -5, 9) rot(0, 0, 0.19634955) | tex(62,0) origin(-1,0,-5) size(2,2,18); origin(-1.001,-3,8) size(1,6,7) (second box, same texture offset) |
| `right_paddle` | off(3, -5, -9) rot(0, 3.1415927, 0.19634955) | tex(62,20) origin(-1,0,-5) size(2,2,18); origin(0.001,-3,8) size(1,6,7) |

**Chest boat extra parts** (`createChestBoatModel`): `chest_bottom` off(-2,-5,-6) rot(0,-1.5707964,0), tex(0,76) origin(0,0,0) size(12,8,12); `chest_lid` off(-2,-9,-6) rot(0,-1.5707964,0), tex(0,59) origin(0,0,0) size(12,4,12); `chest_lock` off(-1,-6,-1) rot(0,-1.5707964,0), tex(0,59) origin(0,0,0) size(2,4,1).

**Raft common parts** (`RaftModel.addCommonParts`, layers `boat/bamboo` 128 x 64 and `chest_boat/bamboo` 128 x 128):

| Part | Pose | Boxes |
|---|---|---|
| `bottom` | off(0, -2.1, 1) rot(1.5708, 0, 0) | tex(0,0) origin(-14,-11,-4) size(28,20,4); tex(0,0) origin(-14,-9,-8) size(28,16,4) |
| `left_paddle` | off(3, -4, 9) rot(0, 0, 0.19634955) | tex(0,24) origin(-1,0,-5) size(2,2,18); origin(-1.001,-3,8) size(1,6,7) |
| `right_paddle` | off(3, -4, -9) rot(0, 3.1415927, 0.19634955) | tex(40,24) origin(-1,0,-5) size(2,2,18); origin(0.001,-3,8) size(1,6,7) |

Raft chest extras: `chest_bottom` off(-2,-10.1,-6), `chest_lid` off(-2,-14.1,-6), `chest_lock` off(-1,-11.1,-1), each with rot(0,-1.5707964,0) and the same boxes as the boat's chest parts.

**Water patch** (`BoatModel.createWaterPatch`, layer `boat#water_patch`, texture size 0 x 0): one part `water_patch`, off(0, -3, 1) rot(1.5707964, 0, 0), box tex(0,0) origin(-14,-9,-3) size(28,16,3) (the same box as the boat `bottom`, 6 pixels higher).

### 7.2 Paddle animation (`AbstractBoatModel.setupAnim`)

For the left paddle `t = state.rowingTimeLeft`, for the right paddle `t = state.rowingTimeRight`. Each paddle is **set** (not added): `xRot = clampedLerp((sin(-t) + 1) / 2, -1.0471976, -0.2617994)` and `yRot = clampedLerp((sin(-t + 1) + 1) / 2, -0.7853982, 0.7853982)`, and for the right paddle `yRot = 3.1415927 - yRot`. (`clampedLerp(f, a, b)` returns a when f < 0, b when f > 1, else a + (b - a) f: read in `Mth.clampedLerp`, which delegates to `Mth.lerp(t, a, b) = a + t x (b - a)`.) The paddle's baked zRot (0.19634955) and its position are unchanged.

### 7.3 Render state extraction (`AbstractBoatRenderer.extractRenderState`)

| Field | Value |
|---|---|
| `yRot` | `entity.getYRot(partial)` (degrees, interpolated) |
| `hurtTime` | `entity.getHurtTime() - partial` |
| `hurtDir` | `entity.getHurtDir()` (+1 or -1) |
| `damageTime` | `max(entity.getDamage() - partial, 0)` |
| `bubbleAngle` | `lerp(partial, bubbleAngleO, bubbleAngle)` degrees |
| `isUnderWater` | status is `UNDER_WATER` or `UNDER_FLOWING_WATER` |
| `rowingTimeLeft`, `rowingTimeRight` | `getRowingTime(side, partial)` |

`getRowingTime(side, partial)`: when the paddle state of that side is true, `clampedLerp(partial, paddlePositions[side] - 0.3926991, paddlePositions[side])`, else 0. `paddlePositions[side]` advances in `tick` (both client and server run it): for each of the two sides, if the paddle state is true then `paddlePositions[side] += 0.3926991` (pi/8) else it resets to 0 (the paddle sound rules are in 21 section 8.8 and are not a render matter). Bubble column visuals (client only): each tick, with `bt` the bubble time counter, `bubbleMultiplier += 0.05` when `bt > 0` else `-= 0.1`, clamped to 0..1; `bubbleAngleO = bubbleAngle`; `bubbleAngle = 10 x sin(0.5 x tickCount) x bubbleMultiplier` (degrees); the sine is the full-precision `Math.sin` on a double (read in `tickBubbleColumn`), not the `Mth.sin` table of section 0.3.

### 7.4 Renderer pose and drawing (`AbstractBoatRenderer.submit`; it does not use the living pipeline)

1. Push; translate (0, 0.375, 0).
2. Rotate about Y by `180 - yRot` degrees.
3. If `hurtTime > 0`: rotate about X by `sin(hurtTime) x hurtTime x damageTime / 10 x hurtDir` degrees.
4. If not `isUnderWater` and `bubbleAngle` is not (about) 0 (`Mth.equal`, tolerance 1.0E-5): rotate by `bubbleAngle` degrees about the axis (1, 0, 1) (the bytecode builds a `Quaternionf` with `setAngleAxis(angle, 1, 0, 1)`; the vector library is not in the jar, so whether the axis is normalized is not read: implementers should normalize (1, 0, 1) to unit length, (inferred), Open question 5).
5. Scale (-1, -1, 1); rotate about Y by 90 degrees. (There is no translate of 1.501 here.)
6. Submit the boat model (`BoatModel` or `RaftModel`, root pose identity) with the renderer's texture, the entity light, `NO_OVERLAY` and the outline color; the model is posed with `AbstractBoatModel.setupAnim` (7.2) at draw time (section 0.4).
7. `submitTypeAdditions` (empty for rafts): `BoatRenderer` draws the water patch model, **only when not under water**, in the same pose and with the same texture id, with the render type `RenderTypes.waterMask()` (below).
8. Pop; then the common entity submit (shadow, name tag). Shadow radius 0.8.

**Water mask render type**: `waterMask` returns the pipeline `WATER_MASK` (or `OIT_WATER_MASK` when the "improved transparency" setting is in use). `WATER_MASK` is a position-only vertex format, quad topology, vertex and fragment shader `core/rendertype_water_mask`, default depth-stencil state (depth test and write enabled), and a color target declared as translucent blend function, RGBA8 format (`RGBA8_UNORM`) and write mask 0 (no color is written; the blend and format do not matter while the mask is 0). Effect: the patch writes depth only, so water that is drawn later and lies inside the boat hull fails the depth test and the boat interior stays dry; the patch is at the box position of the hull's bottom, 6 model pixels above it. The OIT variant has the same shaders and depth state with the default color target (the `OIT_WATER_MASK` definition omits the explicit color target call that `WATER_MASK` makes). The pass order relative to the water layer is part of the world render order (12) and not re-derived here (Open question 8).

### 7.5 Passenger seats, leash points, fire and outline

**Passenger seat** (`AbstractBoat.getPassengerAttachmentPoint`, seat in boat-local space before rotation): `(0, rideHeight, xo)`, then rotated about Y by `-yRot x 0.017453292` (the boat's `yRot` in degrees; the sign and handedness of that vector rotation are the vector library's and are not read here). `rideHeight` = `height / 3` for a boat (`Boat`: 1.375 x 0.5625 gives 0.1875) and `height x 0.8888889` for a raft (`Raft`: 0.5). `xo` is `getSinglePassengerXOffset`, which depends on the type: **0 for a boat and a raft** (`AbstractBoat`) and **0.15 for a chest boat and a chest raft** (`AbstractChestBoat` override, constant 0.15). It is used when the boat holds one passenger or fewer, so a chest boat or chest raft (maximum 1 passenger) seats its rider at `(0, rideHeight, 0.15)` before the Y rotation. With more than one passenger: the passenger at index 0 in the passenger list gets `xo = 0.2`, any other gets `xo = -0.6`; and if the passenger is an `Animal`, 0.2 is added to its `xo`. Maximum passengers: 2 for `AbstractBoat`, 1 for chest boats and chest rafts (`AbstractChestBoat.getMaxPassengers`); chest boats therefore differ from plain boats in both the maximum (1) and the single-passenger offset (0.15 instead of 0). Seat constants by type: boat (0, 0.1875, 0), raft (0, 0.5, 0), chest boat (0, 0.1875, 0.15), chest raft (0, 0.5, 0.15), each before the Y rotation and, with two passengers, `xo` replaced by the 0.2 / -0.6 rule (the chest types never reach it). This closes the first Open question of 18 for boats (the player's own seat adjustment is not covered).

**Leash** (`AbstractBoat.getLeashOffset`): `(0, 0.88 x bbHeight, 0.64 x bbWidth)` where `bbHeight` and `bbWidth` are the entity's current box size (0.495 and 0.88 for the 1.375 x 0.5625 box). The boat also supports quad leashes (`supportQuadLeash` true) with offsets built from the constants (0.64, 0.382, 0.88) (`Leashable.createQuadLeashOffsets`, whose formula was not read).

**Fire and outline.** `AbstractBoatRenderer.submit` ends with `EntityRenderer.submit` (shadow, name tag and the other common parts of the entity submit); the boat model is submitted with the render state's outline colour (the glowing outline colour). The burning flame overlay is a common `EntityRenderer` feature that this renderer neither suppresses nor changes; its drawing was not traced here (Open question 14).

---

## 8. Worked examples

All trig of the models is the table `Mth.sin` and `Mth.cos` (section 0.3); results below use exact trig, so allow about 1e-4.

**E1. Adult squid tentacle layout.** Tentacle 2: `a = 2 x pi x 2 / 8 = pi/2`, position (cos x 5, 15, sin x 5) = (3.1e-16, 15, 5), `ry = 2 x pi x (-2) / 8 + pi/2 = 0`. Tentacle 4: position (-5, 15, 6.1e-16), `ry = -pi/2`. Baby tentacle 1: `R = 3`, y 18.5, position (2.1213, 18.5, 2.1213), `ry = 0.7854`.

**E2. Squid pose.** Adult, `bodyRot = 30`, `xBodyRot = 10`, `zBodyRot = 90`: translate (0, 0.5, 0); Y rotation 150 degrees; X rotation 10; Y rotation 90; translate (0, -1.2, 0); then (-1,-1,1) scale and (0,-1.501,0). Baby: translates (0, 0.25, 0) and (0, -0.6, 0).

**E3. Glow squid light.** `darkTicksRemaining = 5`: `t = 0.5`, `i = (int)7.5 = 7`; the block light is `max(7, world block light)`. Counter 0: 15 regardless of the world.

**E4. Dolphin swimming.** `isMoving`, `ageInTicks = 10`: `c = cos(3) = -0.98999`; `body.xRot = xRotDeg x 0.017453292 + (-0.05 - 0.05 x -0.98999) = xRotDeg x 0.017453292 - 0.000500`; `tail.xRot = 0.098999`; `tail_fin.xRot = 0.197998`. Carrying an item at `xRot = -30` : `p = 0.5`, translate (0, 0.75, -0.75); at `xRot = +30`: translate (0, 1.4, -0.9).

**E5. Axolotl blends.** Adult in water, still: `iw = 1`, `og = 0`, `mv = 0`, `pd = 0`: weights: swim `min(0, 1) = 0` (skipped); hover `min(1, 1) = 1`; crawl 0; layStill `min(1, 0) = 0`; playDead 0; `lay = 1 - min(0, 0) = 1`. With `A = 10`: `t = 0.75`, `cos = 0.7317`, `h = -0.15 + 0.075 x 0.7317 = -0.095123`; `body.xRot = -0.095123` (+ nothing else); `head.xRot = +0.095123`; `body.y = 19.5 - 0.15 x sin(0.75) = 19.5 - 0.10225 = 19.39775`; `left_hind_leg.xRot = 2.3561945 - 0.11 x 0.7317 = 2.2757`; `mirrorLegs(1)` then sets `right_hind_leg.xRot = 0 + 2.2757`, `right_hind_leg.yRot = -0.47124`, `right_hind_leg.zRot = -1.72788`. A `BinaryAnimator` with `ticks = 5` of 10 and `ticksOld = 4`, partial 0.5: `lerp = 4.5`, `x = 0.45`, factor `-(cos(0.45 pi) - 1) / 2 = 0.4218`.

**E6. Baby axolotl clock.** A baby starting `idleOnGround` at tick 100; at `ageInTicks = 102.5`: `ms = (long)(2.5 x 50) = 125`, `t = 0.125 s` of length 2.88 s looping. The `tail` rotation track (Appendix A.1): keys at 0 (0,10,0), 0.72 (0,-14,0): `i = 0, j = 1`, `p = 0.125 / 0.72 = 0.1736`; the interpolation of key `j` is LINEAR, so the y component is `10 + (-14 - 10) x 0.1736 = 5.833` degrees, i.e. 0.10181 rad added to the tail's yRot.

**E7. Cod out of water.** `ageInTicks = 5`: on land `f = 1.5`, `tail_fin.yRot = -1.5 x 0.45 x sin(3) = -0.09526`; in water `-0.06350`. Body wiggle 4.3 x sin(3) = 0.6068 degrees; out of water also translate (0.1, 0.1, -0.1) and Z rotation 90.

**E8. Salmon sizes.** `salmon_small`: mesh root scale 0.5, y offset +12.008 model pixels (0.7505 blocks before the pipeline's flip). `salmon_large`: scale 1.5, y -12.008. Out of water at `ageInTicks = 5`: `a = 1.3`, `b = 1.7`: `body_back.yRot = -1.3 x 0.25 x sin(1.7 x 0.6 x 5 = 5.1) = +0.3009`.

**E9. Tropical fish packing.** Pattern `stripey` (LARGE index 1: `packedId = 1 | (1 << 8) = 257`), base color red (id 14), pattern color white (id 0): `packed = 257 | (14 << 16) | (0 << 24) = 917761`. Decoding: `917761 & 0xFFFF = 257` is `stripey`; `(917761 >> 16) & 255 = 14` red; `(917761 >> 24) & 255 = 0` white. Rendering: large model, texture `tropical_b.png` tinted `0xFFB02E26`; pattern layer texture `tropical_b_pattern_2.png` with the large pattern model (grow 0.008) tinted `0xFFF9FFFE`.

**E10. Pufferfish.** `puffState = 1`: medium model; shadow `0.1 + 0.1 = 0.2`; at `ageInTicks = 20` the pose is translated by `cos(1.0) x 0.08 = 0.04322` blocks in y before the Y rotation; fins: `right_blue_fin.zRot = -0.2 + 0.4 x sin(4) = -0.5027`, `left_blue_fin.zRot = +0.5027`.

**E11. Nautilus swim.** `walkAnimationPos = 1`, `walkAnimationSpeed = 0`, `ageInTicks = 10`: position `1 + 10/5 = 3`; `ms = (long)(3 x 50 x 2) = 300`, `t = 0.3 s`; strength `min((0 + 0.2) x 3, 1) = 0.6`. Body scale channel keys 0:(1,1,1), 0.5:(1,1,1.2) LINEAR (the track stores the offsets x-1, so (0,0,0) and (0,0,0.2)): `p = 0.6`, sampled z offset `0.2 x 0.6 = 0.12`, times strength 0.6 gives 0.072: the body's zScale becomes `1 + 0.072 = 1.072`. Upper mouth rotation: keys 0:(0,0,0), 0.5:(30,0,0): at `p = 0.6`, `18 x 0.6 = 10.8` degrees about X.

**E12. Boat paddles at rest.** `rowingTime = 0` both sides: `left.xRot = clampedLerp((sin(0) + 1)/2 = 0.5, -1.0471976, -0.2617994) = -0.6544985`; `left.yRot = clampedLerp((sin(1) + 1)/2 = 0.920735, -0.7853982, 0.7853982) = 0.66089`; `right.yRot = 3.1415927 - 0.66089 = 2.48070`. (Rest means a paddle state false, where `getRowingTime` is 0.)

**E13. Boat transform.** Entity `yRot = 90`, undamaged, not in a bubble column: translate (0, 0.375, 0); rotate Y by `180 - 90 = 90`; scale (-1,-1,1); rotate Y by 90. A damaged boat with `hurtTime = 5`, `damageTime = 20`, `hurtDir = 1`: X rotation `sin(5) x 5 x 20 / 10 x 1 = -9.589` degrees (sin(5 rad) = -0.9589).

---

## 9. Validation

The implementer's checks, each from the numbers above:

| Check | Expected |
|---|---|
| Squid adult mesh | 9 parts under root: `body` and `tentacle0` to `tentacle7`; texture 64 x 32; baby texture 32 x 32 |
| Tentacle 1 pose (adult) | off(3.5355, 15, 3.5355), yRot 0.7854 |
| Glow squid with counter 5 | block light = max(7, world light) |
| Dolphin adult | 8 parts: body, back_fin, left_fin (mirror), right_fin, tail, tail_fin (child of tail), head, nose (child of head); texture 64 x 64 |
| Dolphin `isMoving` false | tail and tail fin keep the baked pose, body only takes pitch and yaw |
| Axolotl adult sum of weights | with `iw = 1, og = 0, mv = 0`: only `hover` and `mirrorLegs` (w = 1) act |
| Axolotl weights | swim `min(mv, iw)`, hover `min(1 - mv, iw)`, crawl `min(mv, og)`, layStill `min(1 - mv, og)`, mirror `1 - min(og, mv)` |
| Baby axolotl | seven bakeable animations, one `AnimationState` active at a time; walk (ground) plays both `AXOLOTL_WALK_FLOOR` (walk-clock) and `WALK_FLOOR_UNDERWATER` (state-clock) |
| Fish tail wag | in water factor 1, out 1.5 (cod and tropical); salmon uses 1/1 in water and 1.3/1.7 out |
| Pufferfish models | puffState 0 small (6 parts), 1 medium (11 parts), 2 big (13 parts) |
| Tropical fish tint | base tint = base color, pattern layer tint = pattern color, pattern grow 0.008 |
| Nautilus | adult texture 128 x 128, baby 64 x 64; baby shows no armor or saddle |
| Zombie nautilus | variant `warm` selects the coral model; coral hidden when body armor worn |
| Boat | translate y 0.375 (not 1.501); water patch drawn only when the boat is not under water |
| Raft | `bottom` has two boxes, paddles at y -4, chest parts at y -10.1 / -14.1 / -11.1 |

---

## Appendix A. Keyframe animation data

Notation: a track is `bone | target | keyframes`; a keyframe is `time (s) : (x, y, z) interpolation` with `L` = LINEAR and `C` = CATMULLROM. Values are the **arguments** of the vector builders (the stored vectors follow 34-3 section 0.2): rotation tracks are in **degrees** (`degreeVec`), position tracks are `posVec` arguments in model pixels (the stored y is negated), scale tracks are `scaleVec` arguments (factors; the stored offset is the factor minus 1). Each keyframe has its pre and post targets equal. A track with a single keyframe yields that value at every time (sampling rule: `i = j`, `p = 0`).

### A.1 `BabyAxolotlAnimation`

The class defines eight definitions; `BabyAxolotlModel` bakes seven. The one it does not bake is the lowercase-named `baby_axolotl_dash` (1.04 s, looping), given for completeness.

**`BABY_AXOLOTL_IDLE_FLOOR`** — length 2.88 s, looping

| Bone | Target | Keyframes: time s : (x, y, z) interpolation |
|---|---|---|
| `body` | rotation | 0 : (0, 0, 0) C; 2.8 : (0, 0, 0) C |
| `right_front_leg` | rotation | 0 : (160, -10, -37.5) C |
| `right_front_leg` | position | 0 : (0.2, 0, 0) L |
| `right_hind_leg` | rotation | 1.72 : (360, 0, -45) C |
| `left_front_leg` | rotation | 0 : (160, 10, 37.5) C |
| `left_front_leg` | position | 0 : (-0.2, 0, 0) L |
| `left_hind_leg` | rotation | 0 : (0, 0, 37.5) C |
| `tail` | rotation | 0 : (0, 10, 0) C; 0.72 : (0, -14, 0) L; 0.96 : (0, -21, 0) L; 1.4 : (0, -25, 0) C; 2.04 : (0, -16.75, 0) C; 2.84 : (0, 10, 0) C |
| `head` | rotation | 0.04 : (0, 0, -6) C; 1.32 : (-6.45, -1.45, -6.5) L; 1.48 : (-6.45, -1.45, -6.5) L; 2.84 : (0, 0, -6) C |
| `left_gills` | rotation | 0 : (0, 38, 0) C; 1.28 : (0, 45.5, 0) C; 1.64 : (0, 45.5, 0) C; 2.8 : (0, 38, 0) C |
| `right_gills` | rotation | 0.04 : (0, -50, 0) C; 1.32 : (0, -59, 0) C; 1.6 : (0, -59, 0) C; 2.84 : (0, -50, 0) C |
| `top_gills` | rotation | 0 : (33, 0, 0) C; 1.28 : (47.4, 0, 0) C; 1.64 : (47.4, 0, 0) C; 2.8 : (33, 0, 0) C |

**`IDLE_FLOOR_UNDERWATER`** — length 5.12 s, looping

| Bone | Target | Keyframes: time s : (x, y, z) interpolation |
|---|---|---|
| `body` | rotation | 0 : (0, 0, 0) C; 5.12 : (0, 0, 0) C |
| `body` | position | 0 : (0, 1.5, 0) C; 5.12 : (0, 1.5, 0) C |
| `right_front_leg` | rotation | 5.04 : (190, -15, -30) C |
| `right_front_leg` | position | 0 : (0.3, 0, 0.5) C; 5.12 : (0.3, 0, 0.5) C |
| `right_hind_leg` | rotation | 0 : (360, 0, -30) C |
| `right_hind_leg` | position | 0 : (0.18, 0, 0) L; 5.12 : (0.18, 0, 0) L |
| `left_front_leg` | rotation | 5.04 : (190, 18, 30) C |
| `left_front_leg` | position | 0 : (-0.1, 0, 0.5) C; 5.12 : (-0.1, 0, 0.5) C |
| `left_hind_leg` | rotation | 5.04 : (180, 0, 30) C |
| `left_hind_leg` | position | 0 : (-0.2, 0, 0) L; 5.12 : (-0.2, 0, 0) L |
| `tail` | rotation | 0.04 : (0, -12, 0) C; 2.56 : (0, 12, 0) C; 5.12 : (0, -12, 0) C |
| `left_gills` | rotation | 0 : (0, 10, 0) C; 3.12 : (0, -16, 0) C; 5.12 : (0, 10, 0) C |
| `right_gills` | rotation | 0 : (0, -16, 0) C; 2.08 : (0, 12, 0) C; 5.12 : (0, -16, 0) C |
| `top_gills` | rotation | 0 : (10, 0, 0) C; 2.56 : (-16, 0, 0) C; 5.12 : (10, 0, 0) C |

**`IDLE_UNDERWATER`** — length 5.2 s, looping

| Bone | Target | Keyframes: time s : (x, y, z) interpolation |
|---|---|---|
| `body` | rotation | 0 : (-8.9, 0, 0) C; 2.6 : (-2.6, 0, 0) C; 5.2 : (-8.9, 0, 0) C |
| `body` | position | 0 : (0, 0, 0) C; 2.6 : (0, -0.5, 0) C; 5.2 : (0, 0, 0) C |
| `right_front_leg` | rotation | 0 : (-5, -20, -55) C; 2.6 : (1, -20, -65) C; 5.2 : (-5, -20, -55) C |
| `right_front_leg` | position | 0 : (0.15, -0.3391, 0.0876) C |
| `right_hind_leg` | rotation | 0 : (60, -60, 15) C; 2.6 : (75, -60, 0) C; 5.2 : (60, -60, 15) C |
| `right_hind_leg` | position | 5.2 : (0, -0.4, 0) C |
| `left_front_leg` | rotation | 0 : (0, 20, 50) C; 2.6 : (0, 20, 60) C; 5.2 : (0, 20, 50) C |
| `left_front_leg` | position | 2.68 : (-0.15, -0.4, 0.3) C |
| `left_hind_leg` | rotation | 0 : (-135, -50, -330) C; 2.6 : (-160, -60, -295) C; 5.2 : (-135, -50, -330) C |
| `left_hind_leg` | position | 5.2 : (0, -0.5, 0) C |
| `tail` | rotation | 0 : (0, 15, 0) C; 2.6 : (0, -32, 0) C; 5.2 : (0, 15, 0) C |
| `head` | rotation | 0 : (11.7, 0, 0) C; 2.6 : (2.4, 0, 0) C; 5.2 : (11.7, 0, 0) C |
| `left_gills` | rotation | 0 : (0, -25.6, 0) C; 3.12 : (0, 16, 0) C; 5.2 : (0, -25.6, 0) C |
| `right_gills` | rotation | 0 : (0, 23, 0) C; 2.08 : (0, -26, 0) C; 5.2 : (0, 23, 0) C |
| `top_gills` | rotation | 0 : (-19.2, 0, 0) C; 2.6 : (12.3, 0, 0) C; 5.2 : (-19.2, 0, 0) C |

**`BABY_AXOLOTL_SWIM`** — length 1 s, looping

| Bone | Target | Keyframes: time s : (x, y, z) interpolation |
|---|---|---|
| `body` | rotation | 0 : (8, 0, 0) C; 0.24 : (12, 0, 0) C; 0.68 : (-7.5, 0, 0) C; 1 : (8, 0, 0) L |
| `body` | position | 0 : (0, 0, 0) C; 0.52 : (0, -1, 0) C; 0.96 : (0, -0.05, 0) C |
| `right_front_leg` | rotation | 0 : (310, 70, 400) C; 0.24 : (330, 70, 420) C; 0.52 : (290, 65, 384) C; 0.76 : (290, 70, 380) C; 0.96 : (310, 70, 400) C |
| `right_hind_leg` | rotation | 0 : (105, -95, 180) C; 0.28 : (105, -85, 180) C; 0.52 : (105, -80, 180) C; 0.76 : (105, -95, 180) C; 0.96 : (105, -95, 180) C |
| `left_front_leg` | rotation | 0 : (-50, -70, -40) C; 0.52 : (-60, -68, -30) C; 0.76 : (-55, -70, -30) C; 0.96 : (-50, -70, -40) C |
| `left_hind_leg` | rotation | 0 : (70, -80, 15) C; 0.28 : (130, -80, -45) C; 0.52 : (120, -70, -35) C; 0.76 : (80, -70, 5) C; 0.96 : (70, -80, 15) C |
| `tail` | rotation | 0 : (0, 15, 0) C; 0.52 : (0, -15, 0) C; 0.96 : (0, 13.36, 0) C |
| `head` | rotation | 0 : (-7.5, 0, 0) C; 0.28 : (-13.9, 0, 0) C; 0.72 : (14.23, 0, 0) C; 1 : (-7.5, 0, 0) C |
| `left_gills` | rotation | 0 : (0, -72, 0) C; 0.2 : (0, -79.9, 0) C; 0.64 : (0, -38.1, 0) C; 0.96 : (0, -72, 0) C |
| `right_gills` | rotation | 0 : (0, 72, 0) C; 0.2 : (0, 86.5, 0) C; 0.64 : (0, 26.7, 0) C; 0.96 : (0, 72, 0) C |
| `top_gills` | rotation | 0 : (-57, 0, 0) C; 0.2 : (-68.7, 0, 0) C; 0.64 : (-24.2, 0, 0) C; 0.96 : (-57, 0, 0) C |

**`baby_axolotl_dash`** — length 1.04 s, looping

| Bone | Target | Keyframes: time s : (x, y, z) interpolation |
|---|---|---|
| `body` | rotation | 0 : (8, 0, 0) C; 0.24 : (15.5, 0, 0) C; 0.68 : (-12, 0, 0) C; 1.04 : (8, 0, 0) L |
| `body` | position | 0 : (0, 0, 0) C; 0.52 : (0, -1, 0) C; 0.96 : (0, -0.05, 0) C |
| `right_front_leg` | rotation | 0 : (310, 70, 400) C; 0.52 : (290, 65, 384) C; 0.76 : (290, 70, 380) C; 1.04 : (311, 70, 400) C |
| `right_hind_leg` | rotation | 0 : (100, -85, -170) C; 0.28 : (105, -70, -175) C; 0.52 : (105, -80, -180) C; 0.64 : (105, -90, -180) C; 1.04 : (100, -85, -170) C |
| `left_front_leg` | rotation | 0 : (-50, -70, -40) C; 0.52 : (-56, -68, -30) C; 0.76 : (-65, -70, -30) C; 1.04 : (-50, -70, -40) C |
| `left_hind_leg` | rotation | 0 : (70, -80, 15) C; 0.28 : (130, -80, -45) C; 0.52 : (120, -70, -35) C; 0.76 : (65, -65, 25) C; 1.04 : (69, -80, 15) C |
| `tail` | rotation | 0 : (-15, 10, 0) C; 0.24 : (-5, 5.75, 0) C; 0.36 : (8.5, -2.0242, 0.3582) C; 0.48 : (22.5, -10, 0) C; 0.64 : (8.74, -8.7, -0.02) C; 0.76 : (-5, -3.25, 0) C; 1.04 : (-15, 10, 0) C |
| `head` | rotation | 0 : (-7.5, 0, 0) C; 0.28 : (-22.5, 0, 0) C; 0.72 : (18.73, 0, 0) C; 1.04 : (-7.5, 0, 0) C |
| `left_gills` | rotation | 0 : (0, -72, 0) C; 0.2 : (0, -79.9, 0) C; 0.64 : (0, -38.1, 0) C; 1.04 : (0, -72, 0) C |
| `right_gills` | rotation | 0 : (0, 72, 0) C; 0.2 : (0, 86.5, 0) C; 0.64 : (0, 26.7, 0) C; 1.04 : (0, 72, 0) C |
| `top_gills` | rotation | 0 : (-57, 0, 0) C; 0.2 : (-68.7, 0, 0) C; 0.44 : (-64, 0, 0) C; 0.64 : (-40, 0, 0) C; 0.84 : (-40, 0, 0) C; 1.04 : (-57, 0, 0) C |

**`AXOLOTL_WALK_FLOOR`** — length 2.72 s, looping

| Bone | Target | Keyframes: time s : (x, y, z) interpolation |
|---|---|---|
| `body` | rotation | 0 : (0, 0, 0) L; 2.72 : (0, 0, 0) L |
| `right_front_leg` | rotation | 0 : (2.5, 10, -30) C; 1.32 : (2.5, -22.5, -30) C; 2.72 : (2.5, 10, -30) C |
| `right_front_leg` | position | 1.92 : (0.5, 0, 0.8) C |
| `right_hind_leg` | rotation | 0 : (260, -10, 230) C; 1.32 : (90, -20, 50) C; 2.72 : (260, -10, 230) C |
| `right_hind_leg` | position | 0 : (0.5, 0, 0) C; 2.72 : (0.5, 0, 0) C |
| `left_front_leg` | rotation | 0 : (-2.5, 32.5, 30) C; 1.32 : (-2.5, -12, 30) C; 2.72 : (-2.5, 32.5, 30) C |
| `left_front_leg` | position | 0 : (-0.5, 0, 0.7) C |
| `left_hind_leg` | rotation | 0 : (-2.5, -30, 30) C; 1.32 : (2.5, 12, 30) C; 2.72 : (-2.5, -30, 30) C |
| `left_hind_leg` | position | 0 : (-0.5, 0, 0) C; 2.72 : (-0.5, 0, 0) C |
| `tail` | rotation | 0 : (0, -10, 0) C; 1.32 : (0, 10, 0) C; 2.72 : (0, -10, 0) C |
| `head` | rotation | 0 : (0, -7.5, 0) C; 1.32 : (0, 6.7, 0) C; 2.72 : (0, -7.5, 0) C |
| `left_gills` | rotation | 0 : (0, 38.1, 0) C; 1.08 : (0, 45.6, 0) C; 1.44 : (0, 45.6, 0) C; 2.72 : (0, 38.1, 0) C |
| `right_gills` | rotation | 0 : (0, -50, 0) C; 1.08 : (0, -59, 0) C; 1.36 : (0, -59, 0) C; 2.72 : (0, -50, 0) C |
| `top_gills` | rotation | 0 : (33, 0, 0) C; 1.08 : (47.4, 0, 0) C; 1.44 : (47.4, 0, 0) C; 2.72 : (33, 0, 0) C |

**`WALK_FLOOR_UNDERWATER`** — length 2.04 s, looping

| Bone | Target | Keyframes: time s : (x, y, z) interpolation |
|---|---|---|
| `body` | rotation | 0 : (0, -5, 6) C; 1.04 : (0, 5, -4) C; 2.04 : (0, -5, 6) C |
| `body` | position | 0 : (0, 1.5, 0) C; 2.04 : (0, 1.5, 0) C |
| `right_front_leg` | rotation | 0 : (0, -15, -30) C; 0.72 : (0, 9, -30) C; 1.12 : (0, 13, -24) C; 1.44 : (0, 9, -30) C; 2.04 : (0, -15, -30) C |
| `right_front_leg` | position | 0 : (0, 0, 0) C; 0.96 : (0.4, 0, 0) C; 2.04 : (0, 0, 0) C |
| `right_hind_leg` | rotation | 0 : (95, -20, 70) C; 0.68 : (255, -20, 230) C; 1.12 : (280, -25, 255) C; 1.52 : (255, -20, 230) C; 2.04 : (95, -20, 70) C |
| `right_hind_leg` | position | 0 : (0.5, 0, 0) C; 0.96 : (0.5, 0, 0) C; 2.04 : (0.5, 0, 0) C |
| `left_front_leg` | rotation | 0 : (-5, -20, 30) C; 0.72 : (0, 10, 25) C; 1.44 : (0, 10, 25) C; 2.04 : (-5, -20, 30) C |
| `left_front_leg` | position | 0 : (-0.5, 0, 0) C; 0.96 : (0, 0, 0) C; 2.04 : (-0.5, 0, 0) C |
| `left_hind_leg` | rotation | 0 : (5, 15, 25) C; 0.72 : (-10, -20, 35) C; 1.44 : (-10, -20, 35) C; 2.04 : (5, 15, 25) C |
| `left_hind_leg` | position | 0 : (-0.7, 0, 0) C; 0.96 : (-0.4, 0, 0) C; 2.04 : (-0.7, 0, 0) C |
| `tail` | rotation | 0 : (0, 16.5, 0) C; 0.56 : (0, 1.12, 0) C; 1.44 : (0, 17.5, 0) C; 2.04 : (0, 16.5, 0) C |
| `head` | rotation | 0 : (0, 4, -5.8) C; 1.04 : (0, -4, 5) C; 2.04 : (0, 4, -5.8) C |
| `left_gills` | rotation | 0 : (0, -60, 0) C; 1.24 : (0, -45, 0) C; 2.04 : (0, -60, 0) C |
| `right_gills` | rotation | 0 : (0, 38, 0) C; 0.64 : (0, 53, 0) C; 2.04 : (0, 38, 0) C |
| `top_gills` | rotation | 0 : (-34, 0, 0) C; 1.04 : (-41.5, 0, 0) C; 2.04 : (-34, 0, 0) C |

**`BABY_AXOLOTL_PLAY_DEAD`** — length 0.04 s, not looping (clamps at the last keyframe)

| Bone | Target | Keyframes: time s : (x, y, z) interpolation |
|---|---|---|
| `body` | rotation | 0 : (0, 0, 30) C |
| `body` | position | 0 : (0, 0, 0) L |
| `body` | scale | 0 : (1, 1, 1) L |
| `right_front_leg` | rotation | 0 : (202.35, -30.33, -40.82) C |
| `right_front_leg` | position | 0 : (0.2, 0, 0) L |
| `right_front_leg` | scale | 0 : (1, 1, 1) L |
| `right_hind_leg` | rotation | 0 : (418, -50, 35.8) C |
| `right_hind_leg` | position | 0 : (0, 0, 0) L |
| `right_hind_leg` | scale | 0 : (1, 1, 1) L |
| `left_front_leg` | rotation | 0 : (177, 22.76, 15.9) C |
| `left_front_leg` | position | 0 : (-0.2, 0, 0) L |
| `left_front_leg` | scale | 0 : (1, 1, 1) L |
| `left_hind_leg` | rotation | 0 : (16.4287, -37.6467, 16.9822) C |
| `left_hind_leg` | position | 0 : (0, 0, 0) L |
| `left_hind_leg` | scale | 0 : (1, 1, 1) L |
| `tail` | rotation | 0 : (0, -18.67, 0) L |
| `tail` | position | 0 : (0, 0, 0) L |
| `tail` | scale | 0 : (1, 1, 1) L |
| `head` | rotation | 0 : (-4.21, -0.95, -6.33) L |
| `head` | position | 0 : (0, 0, 0) L |
| `head` | scale | 0 : (1, 1, 1) L |
| `left_gills` | rotation | 0 : (0, 43.21, 0) C |
| `left_gills` | position | 0 : (0, 0, 0) L |
| `left_gills` | scale | 0 : (1, 1, 1) L |
| `right_gills` | rotation | 0 : (0, -55.87, 0) C |
| `right_gills` | position | 0 : (0, 0, 0) L |
| `right_gills` | scale | 0 : (1, 1, 1) L |
| `top_gills` | rotation | 0 : (43, 0, 0) C |
| `top_gills` | position | 0 : (0, 0, 0) L |
| `top_gills` | scale | 0 : (1, 1, 1) L |
| `root` | rotation | 0 : (0, 0, 0) L |
| `root` | position | 0 : (0, 0, 0) L |
| `root` | scale | 0 : (1, 1, 1) L |


### A.2 `NautilusAnimation`


**`SWIMMING`** — length 1 s, looping

| Bone | Target | Keyframes: time s : (x, y, z) interpolation |
|---|---|---|
| `body` | scale | 0 : (1, 1, 1) L; 0.5 : (1, 1, 1.2) L; 0.75 : (1, 1, 0.9) L; 0.875 : (1, 1, 1) L; 1 : (1, 1, 1) L |
| `upper_mouth` | rotation | 0 : (0, 0, 0) L; 0.5 : (30, 0, 0) L; 0.75 : (0, 0, 0) L; 0.875 : (0, 0, 0) L; 1 : (0, 0, 0) L |
| `upper_mouth` | scale | 0 : (1, 1, 1) L; 0.5 : (1, 1, 1.4) L; 0.75 : (1, 1, 0.9) L; 0.875 : (1, 1, 1) L; 1 : (1, 1, 1) L |
| `inner_mouth` | scale | 0 : (1, 1, 1) L; 0.5 : (0.8, 0.8, 1) L; 0.75 : (1, 1, 0.9) L; 0.875 : (1, 1, 1) L; 1 : (1, 1, 1) L |
| `lower_mouth` | rotation | 0 : (0, 0, 0) L; 0.5 : (-30, 0, 0) L; 0.75 : (0, 0, 0) L; 0.875 : (0, 0, 0) L; 1 : (0, 0, 0) L |
| `lower_mouth` | scale | 0 : (1, 1, 1) L; 0.5 : (1, 1, 1.4) L; 0.75 : (1, 1, 0.9) L; 0.875 : (1, 1, 1) L; 1 : (1, 1, 1) L |


---

## Open questions

1. **Mirrored boxes, pixel orientation.** Section 0.1 states what `ModelPart$Cube` and `Polygon` do with `mirror` (x corners exchanged, winding reversed, east and west facing exchanged). The exact orientation of each mirrored face's texture (which edge is up and left) was not worked out vertex by vertex; an implementer should compare one mirrored box (the dolphin's `left_fin`) with a reference render. (inferred)
2. **(Closed.)** Squid `aiStep` grouping was read cleanly and is stated in section 2; nothing remains open. (Number kept so that other references stay valid.)
3. **Baby axolotl `walkUnderwater` reads `walkAnimationState`.** `BabyAxolotlModel.setupAnim` drives `WALK_FLOOR_UNDERWATER` from the render state's `walkAnimationState`, the same state that starts the floor walk, while the entity starts a separate `walkUnderWaterAnimationState` for underwater walking, whose render-state copy is not read by the model. Read literally, underwater walking plays no keyframes and ground walking plays both animations. This is as read; whether it is intended was not determined.
4. **(Closed.)** The axolotl variant flag is `common` and `DEFAULT` is `lucy` (section 4.4). Number kept.
5. **Boat bubble-column rotation axis.** The rotation about (1, 0, 1) uses a quaternion built from an angle and an axis; whether the library normalizes the axis cannot be read here (the library is not in the jar). Implementers should normalize (1, 0, 1) to unit length before building the rotation, so the rotation angle is `bubbleAngle` degrees about the diagonal; this is (inferred), not read.
6. **Equipment textures of the nautilus saddle and armor.** Section 6.3 says the layers keep the `body` and mouth boxes of the base mesh; the texture ids were read (section 6.5) but whether the shipped saddle and armor textures leave those regions transparent was not checked (pixel data). The equipment renderer's texture path rule is 14 section 2.1 (inferred there, not traced end to end).
7. **Equipment layer draw path.** `SimpleEquipmentLayer.submit` hands the model to an equipment renderer (`renderLayers`); that this path ends in the same `submitModel` and so the same draw-time `setupAnim` as other layers was not traced into `EquipmentLayerRenderer`. (inferred)
8. **Water mask order.** The pipeline definition (depth only) was read; its place in the frame relative to the water and translucent passes was not traced (12 covers the main passes).
9. **(Closed.)** A null `variant` makes `ZombieNautilusRenderer.submit` return immediately; the entity is not rendered (section 6.5). Number kept.
10. **(Closed.)** `MobRenderer.getShadowRadius` returns the `LivingEntityRenderer` radius (base radius x `state.scale`) multiplied by `state.ageScale` (read); `LivingEntity.getAgeScale` returns 0.5 when `isBaby`, else 1 (as reported by review, matching sections 0.5 and 1.3). Number kept.
11. **`BabySquidModel` and the unused `BABY_TRANSFORMER` constants.** `SquidModel.BABY_TRANSFORMER` and `DolphinModel.BABY_TRANSFORMER` (`scaling(0.5)`) are declared and no layer registration read here uses them. Read in `LayerDefinitions`: its only `BABY_TRANSFORMER` references are `HumanoidModel`, `ElytraModel` and `HappyGhastModel`; `SquidModel` and `DolphinModel` are not referenced there, and the baby squid, glow squid and dolphin layers are built from `BabySquidModel` and `BabyDolphinModel` mesh definitions. So the constants are unused for layer registration; whether another class uses them was not searched jar-wide (narrowed, not closed).
12. **Pose-order detail of `rotationZYX`.** Read: `ModelPart.translateAndRotate` translates by (x, y, z) / 16 and then rotates by a quaternion built with `Quaternionf.rotationZYX(zRot, yRot, xRot)` (arguments in that order, only when any rotation is non-zero), and `rotateBy` uses the matching `Matrix3f.rotationZYX`. The semantics of that joml call (which axis is applied first to a point) is in the library, which is not in the jar; the name implies a rotation about X applied first to the vertex, then Y, then Z. (recalled, not verified)
13. **Name tag lift.** The attachment point (0, h, 0) is read (section 1.3); the constant lift and scale applied inside `submitNameTag` (`EntityRenderer.NAMETAG_SCALE` is the field 0.025f; `extractNameTags` holds float constants 9.0 and 1.15 and distance constants 64.0 and 10.0, read as constants only, their roles not traced) and whether the attachment uses scaled dimensions were not traced.
14. **Fire overlay of boats.** `EntityRenderer.submit` draws the flame when the render state says the entity is burning; the exact conditions and geometry belong to 12 or the entity render base and were not traced for boats here.
15. **(Closed.)** `Mth.clampedLerp(t, a, b)` was re-read: below 0 returns a, above 1 returns b, otherwise `lerp` = a + t (b - a). Number kept.
