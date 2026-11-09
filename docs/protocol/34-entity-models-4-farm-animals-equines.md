# 34 Entity models and renderers, part 4: farm and ridable land animals

| Item | Value |
|---|---|
| Covers | Round RS17 (GAP-25), part 4. Models (every part, cuboid, pivot, texture offset), baby models, saddle, armor and decoration layers, animation code and keyframe animations, renderers, render states and layers of: cow (warm, cold, baby), mooshroom, pig (cold, baby, saddle), sheep (wool, undercoat, dye and `jeb_` colours, baby), chicken (cold, baby), goat (baby), horse, donkey, mule, skeleton horse, zombie horse (all with baby models, markings, saddle and body armor), llama and trader llama (decor, baby), llama spit, camel and camel husk (baby, saddle, keyframe animations), happy ghast (baby, harness, ropes), rabbit (baby, keyframe animations). Siblings (cited as `34-1 §N` for `34-entity-models-1-shared-model-and-framework`, `34-3 §N` for part 3, and so on; not repeated here): the other parts of this round (`34-entity-models-1-shared-model-and-framework` = 34-1, and 34-2, 34-3, 34-5, 34-7; parts 6, 8 and 9 when they exist) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`), with no execution. Classes read: `net.minecraft.client.model.animal.{cow,pig,sheep,chicken,goat,equine,llama,camel,ghast,rabbit}.*`, `net.minecraft.client.model.{QuadrupedModel,BabyModelTransform,AdultAndBabyModelPair}`, `net.minecraft.client.model.geom.{LayerDefinitions,ModelLayers,PartPose,builders.*}`, `net.minecraft.client.animation.definitions.{CamelAnimation,CamelBabyAnimation,RabbitAnimation,BabyRabbitAnimation}`, `net.minecraft.client.renderer.entity.{Cow,MushroomCow,Pig,Sheep,Chicken,Goat,AbstractHorse,Horse,Donkey,UndeadHorse,Llama,LlamaSpit,Camel,CamelHusk,HappyGhast,Rabbit}Renderer` with their nested types, `...renderer.entity.layers.{SheepWool,SheepWoolUndercoat,MushroomCowMushroom,LlamaDecor,HorseMarking,Ropes,SimpleEquipment,RenderLayer}`, `...renderer.entity.state.*RenderState` of the covered animals, `net.minecraft.client.color.ColorLerper`, `net.minecraft.world.item.DyeColor` and the variant enums the renderers switch on. Geometry tables and keyframe tables were produced by a throw-away script that evaluates the model-building and animation static code (constants printed as read); the animation formulas were read from the `setupAnim` bytecode by hand. The script is not kept in the repository. The tables were machine-generated and spot-checked by the reader only; no per-cuboid cross-check was done for the layers named in Open question 16 |
| Scope rule | Standard Minecraft content is the target (CC-0001 decisions). Textures (PNG files) are data extracted by the tool (22) and are not tabulated: this document gives the texture paths the code asks for, the engines that choose among them, and every geometry, animation and layer constant, which is code. Variant registries (`cow_variant`, `pig_variant`, `chicken_variant`) are data; only the code that reads them is here |
| Evidence rule | Every number below was read from the artifact in this round. Items marked "(inferred)" were deduced; items marked "(recalled, not verified)" were not read. All are listed in Open questions (5, 14, 15). The generated tables carry the verification caveat of Open question 16 |

Notation. As in part 3: angles are radians unless "deg" is written; `D` = 0.017453292 (the float constant the code uses for degrees to radians), `pi` = 3.1415927; model lengths are pixels (1/16 block); cuboids are `tex (u, v)`, origin `o (ox, oy, oz)`, size `s (w, h, d)`, "grow g" enlarges every face by g pixels without changing the unwrap, "mirror" marks a mirrored cuboid, `[name]` is the optional cuboid name the code passes. A part path `a/b` is part `b` as a child of part `a`; a top-level path is a child of the model root. Pivot and rotation are the part's initial pose. `lerp(t, a, b)` = `a + t (b - a)` (`Mth.lerp`, read). Model space has x to the model's left, y down, z to the front (12 §7.4, part 1 §1.1).

---

## 0. How this document relates to part 1 and part 3

Cross-reference form: `part 1 §N` in this document means `34-1 §N` (`34-entity-models-1-shared-model-and-framework`), `part 3 §N` means `34-3 §N`; `45 part 4` is `45-entity-nbt-4-land-animals` and `44 part 4` is `44-residual-mob-questions-4-land-animals`. The targets `12 §7.4` (humanoid model parts, `12-client-rendering`) and `14 §5.1` (path rule, `14-texture-only-packs`) were checked to exist.

Part 1 (`34-entity-models-1-shared-model-and-framework`) specifies the engine pieces every model uses, and they are **not repeated here**: cuboid unwrap, deformation and mirror (part 1 §1.3), part drawing and pose stacking (§1.5), `MeshTransformer.scaling` and `BabyModelTransform` (§2.2, §2.3), `QuadrupedModel` and its `setupAnim` and `createBodyMesh` (§3.4), `AdultAndBabyModelPair` (§3.3), the keyframe animation engine (§5, same rules as part 3 §0.2), `AgeableMobRenderer` and `MobRenderer` (§6.6), shadows (§7.1), `SimpleEquipmentLayer` and `EquipmentLayerRenderer` (§8.2). This document supplies, for each covered animal, the content those engines run on. Facts from the shared classes that matter here and were re-read in this round are restated only in one line.

- **Reset before every pose.** `EntityModel.setupAnim` reloads every part's initial pose first (part 3 §0.1 item 3), so every formula below is relative to the initial pose in the tables, except where it names a part's current value (it says so: the sheep head, the equine head parts, legs and tail).
- **Baby model choice.** `AgeableMobRenderer.submit` sets the model to the baby model when `state.isBaby`, else the adult model, then runs the living-entity submit (part 1 §6.6). The renderers of mooshroom, sheep, goat, llama, camel, camel husk, rabbit, happy ghast, horse, donkey, mule, skeleton and zombie horse extend `AgeableMobRenderer` and do this. `CowRenderer`, `PigRenderer` and `ChickenRenderer` do **not** extend it (their class headers read `extends MobRenderer`; their `extractRenderState` calls `MobRenderer.extractRenderState`): each keeps a map of model pairs, picks the pair by the variant's model type (section 1.2), selects the model with `AdultAndBabyModelPair.getModel(isBaby)` in its own `submit` and then calls `MobRenderer.submit` directly. The behaviour is the same as the ageable submit.
- **Generic rules for name tag, leash, passenger offsets, fire.** None of the renderers of this document overrides name-tag position, leash, passenger offsets or fire. Their method lists define only `createRenderState`, `extractRenderState`, `getTextureLocation`, `submit` and (cow, pig, chicken) `bakeModels`; the extras are `getBoundingBoxForCulling` (happy ghast, section 11.1) and `createCamelSaddleLayer`, `extractAdditionalState` and `getJumpCooldown` (camel, section 10.1). The generic rules therefore apply: name tag per part 1 §7.2, hitbox and eye height per 18.
- **No global baby scale.** A baby animal is drawn with its own baby layer at the entity `scale`; there is no extra baby scale in the pose chain (part 1 §6.5). The baby shadow is smaller through `ageScale` (part 1 §7.1); `ageScale` per entity is in section 1.6.
- **Shadow radius.** The base radius each renderer passes to its constructor is listed in section 1.5; part 1 §7.1 gives the rule that multiplies it.

### 0.1 Scaling arithmetic used by several layers

`MeshTransformer.scaling(s)` changes only the root part: its pose becomes `pose.scaled(s)` (offset and scale multiplied by `s`) and then `translated(0, 24.016 (1 - s), 0)` (read in `MeshTransformer.lambda$scaling$*`). Applied to a root whose pose is offset `(0, y, 0)`, scale `S`, the result is offset `(0, y s + 24.016 (1 - s), 0)` and scale `S s`. A model part at pivot `(px, py, pz)` therefore lands at `(s px, s py + 24.016 (1 - s), s pz)`; the line `y = 24.016` is a fixed point (the feet of an unscaled model stand on it). Several scalings compose in order (the happy ghast uses two or three). The layers of this document that carry scaling are listed in section 1.5 with the resulting root pose; sections 8 and 11 give worked numbers.

---

## 1. Shared rules specific to these animals

### 1.1 Layer ids

Layer ids are the `ModelLayers` constants (part 1 §4). The ids used here, with the builder that makes each, are in the table of section 1.5; a layer id is baked once per renderer that asks for it, so two ids with the same builder (for example `cow` and `mooshroom`) are separate model instances with identical geometry.

### 1.2 Variants (cross-reference to RS3)

- `cow_variant`, `pig_variant` and `chicken_variant` are data-driven registry entries (schema: 04, entry layout `ModelAndTexture` plus a baby texture; loading: 23). Each entry has a **model type** (cow: `normal`, `warm`, `cold`; pig: `normal`, `cold`; chicken: `normal`, `cold`), an adult texture asset and a baby texture asset. The renderer reads exactly two things from the entry: the model type, to choose the model pair, and the texture path (adult asset, or baby asset when `isBaby`). A render state whose `variant` is null (the entity has no resolved variant yet) draws nothing at all for cow, pig and chicken (their `submit` returns immediately), and the texture lookup would return the missing-texture location.
- The variant is copied into the render state each frame from the entity's variant holder value (`getVariant().value()`): which variant an entity has, how it is chosen at spawn and stored in NBT is 45 part 4 and 44 part 4.
- Mooshroom, horse, llama and rabbit variants are **code enums** (this document, sections 3, 8.5, 9.1 and 12.3, with their numeric ids). Sheep colour is the 16-value dye enum (section 5.6). Camel, goat, happy ghast and the husk have no variants.

### 1.3 Equipment layers drawn with `SimpleEquipmentLayer` (restating part 1 §8.2 for this document)

`SimpleEquipmentLayer(parent, equipmentRenderer, layerType, itemGetter, adultModel, babyModel[, order])`: the item is `itemGetter(state)`; it must carry an `EQUIPPABLE` component with a present asset id (otherwise nothing); **when the entity is a baby and `babyModel` is null nothing is drawn**. Every layer of this document except the happy ghast harness passes a null baby model, so **babies of pig, horse, donkey, mule, skeleton horse, zombie horse and camel never show a saddle or body armor**, even if the state carries the item. The default `order` is 0; `HorseRenderer` passes 2 for its armor and saddle layers.

Layer types (`EquipmentClientInfo$LayerType`, values and their string ids read): `horse_body` (5), `llama_body` (6), `pig_saddle` (7), `camel_saddle` (9), `camel_husk_saddle` (10), `horse_saddle` (11), `donkey_saddle` (12), `mule_saddle` (13), `zombie_horse_saddle` (14), `skeleton_horse_saddle` (15), `happy_ghast_body` (16) (the ordinal in brackets; the string is the layer-type directory under `textures/entity/equipment/`, 14 §5.1). Which texture an item shows is data (`EquipmentClientInfo`, 22).

### 1.4 Layer render pose

Layers run after the body in registration order with the same pose stack, light, state and `(yRot, xRot)` (part 3 §0.3 item 4). A layer that draws a model with `submitModel(model, state, ...)` poses that model with `setupAnim(state)` itself (the state is the model's input), so wool, saddles, decor and ropes follow the same head turn, walk cycle and animation as the body.

### 1.5 Layer registry for this document and renderer constants

Per renderer: base shadow radius (constructor argument), model layers (adult / baby), layers added in order, texture rule. The geometry of each layer id is in the sections named.

| Entity type | Renderer (class) | Shadow | Layers in order after the body | Models (layer ids) |
|---|---|---|---|---|
| `cow` | `CowRenderer` | 0.7 | none | `cow` / `cow_baby`; `warm_cow` / `warm_cow_baby`; `cold_cow` / `cold_cow_baby` (by variant model type) |
| `mooshroom` | `MushroomCowRenderer` | 0.7 | `MushroomCowMushroomLayer` | `mooshroom` (geometry of `cow`) / `mooshroom_baby` (geometry of `cow_baby`) |
| `pig` | `PigRenderer` | 0.7 | saddle (`pig_saddle` layer type, model `pig_saddle`, no baby model) | `pig` / `pig_baby`; `cold_pig` / `pig_baby` |
| `sheep` | `SheepRenderer` | 0.7 | `SheepWoolUndercoatLayer`, then `SheepWoolLayer` | `sheep` / `sheep_baby` |
| `chicken` | `ChickenRenderer` | 0.3 | none | `chicken` / `chicken_baby`; `cold_chicken` / `chicken_baby` |
| `goat` | `GoatRenderer` | 0.7 | none | `goat` / `goat_baby` |
| `horse` | `HorseRenderer` (extends `AbstractHorseRenderer`) | 0.75 | `HorseMarkingLayer`, armor (`horse_body`, order 2), saddle (`horse_saddle`, order 2) | `horse` / `horse_baby`; armor model `horse_armor`; saddle model `horse_saddle` |
| `donkey` | `DonkeyRenderer` (`AbstractHorseRenderer`) | 0.75 | saddle (`donkey_saddle`) | `donkey` / `donkey_baby` |
| `mule` | `DonkeyRenderer` | 0.75 | saddle (`mule_saddle`) | `mule` / `mule_baby` |
| `skeleton_horse` | `UndeadHorseRenderer` (`AbstractHorseRenderer`) | 0.75 | armor (`horse_body`, model `undead_horse_armor`), saddle (`skeleton_horse_saddle`) | `skeleton_horse` / `skeleton_horse_baby` |
| `zombie_horse` | `UndeadHorseRenderer` | 0.75 | armor (`horse_body`, model `undead_horse_armor`), saddle (`zombie_horse_saddle`) | `zombie_horse` / `zombie_horse_baby` |
| `llama` | `LlamaRenderer` | 0.7 | `LlamaDecorLayer` | `llama` / `llama_baby` |
| `trader_llama` | `LlamaRenderer` | 0.7 | `LlamaDecorLayer` | `trader_llama` / `trader_llama_baby` (geometry of `llama` and `llama_baby`) |
| `llama_spit` | `LlamaSpitRenderer` | none (not a living renderer) | none | `llama_spit` |
| `camel` | `CamelRenderer` | 0.7 | saddle (`camel_saddle` layer type, model `camel_saddle`) | `camel` / `camel_baby` |
| `camel_husk` | `CamelHuskRenderer` | 0.7 | saddle (`camel_husk_saddle` layer type, model `camel_husk_saddle`, same geometry as `camel_saddle`) | `camel` only (no baby model) |
| `happy_ghast` | `HappyGhastRenderer` | 2 | harness (`happy_ghast_body`, adult and baby models), `RopesLayer` | `happy_ghast` / `happy_ghast_baby` |
| `rabbit` | `RabbitRenderer` | 0.3 | none | `rabbit` / `rabbit_baby` |

### 1.6 `ageScale` per entity and baby shadow radius

`LivingEntityRenderer.extractRenderState` copies the entity's `getAgeScale()` into `state.ageScale`. The `LivingEntity` default is 0.5 for a baby (read; adult value is the other branch, 1). Three covered entities override it (read in `Goat`, `Camel`, `HappyGhast`):

| Entity | Baby `ageScale` | Baby shadow radius (base x `ageScale` x `scale`, `scale` 1) |
|---|---|---|
| goat | 0.55 | 0.7 x 0.55 = 0.385 |
| camel (and camel husk, same entity base) | 0.6 | 0.7 x 0.6 = 0.42 |
| happy ghast | 0.2375 | 2 x 0.2375 = 0.475 |
| cow, mooshroom, pig, sheep, llama, trader llama, horse, donkey, mule, skeleton horse, zombie horse | 0.5 (default) | 0.7 x 0.5 = 0.35 (horse family 0.75 x 0.5 = 0.375) |
| chicken, rabbit | 0.5 (default) | 0.3 x 0.5 = 0.15 |

Inside the models `ageScale` is read directly from the render state, with no default substitution, in only two places: the equine tail (section 8.3 step 12) and the sheep head-eat offset (section 5.2). The value is 1 for an adult (the adult branch above) and 0.5 for a baby of these species (the override table above does not touch equines or sheep). So adult sheep use 9 x 1 and adult equines use the full `s` and 2 `s` tail offsets; 0.5 applies to babies only. Worked example, `headEatPositionScale` 0.8: adult sheep head y += 0.8 x 9 x 1 = 7.2; baby sheep head y += 0.8 x 9 x 0.5 = 3.6. Worked example, equine `s` 0.6: adult tail y += 0.6, z += 1.2; baby tail y += 0.3, z += 0.6.

The number of cuboids and parts each layer id produces (for validation, section "Validation") is in the first validation table.

---

## 2. Cow

### 2.1 Renderer and state (`CowRenderer`, `CowRenderState`)

- Class `CowRenderer` extends `MobRenderer` (not `AgeableMobRenderer`); shadow 0.7. At construction it bakes three model pairs, one per `CowVariant$ModelType`: `NORMAL` = (`cow`, `cow_baby`), `WARM` = (`warm_cow`, `warm_cow_baby`), `COLD` = (`cold_cow`, `cold_cow_baby`). Each model object is a `CowModel` (the cold, warm and baby classes only differ in the layer they bake: `ColdCowModel`, `WarmCowModel`, `BabyCowModel` extend `CowModel` and add no animation).
- State `CowRenderState` adds one field, `variant` (a `CowVariant`, null until resolved). Extraction copies `getVariant().value()`.
- Submit: if `variant` is null return; else `model = models[variant.modelAndTexture.model].getModel(isBaby)` and call `MobRenderer.submit` (no ageable submit).
- Texture: null variant gives the missing-texture location; baby gives `variant.babyTexture` path; adult gives `variant.modelAndTexture.asset` path.
- No layers.

### 2.2 `setupAnim`

`CowModel` extends `QuadrupedModel` and adds none: head `xRot`/`yRot` from the look angles and the four leg swings of part 1 §3.4 (leg amplitude 1.4, phase 0.6662). The parts `head`, `body`, `right_hind_leg`, `left_hind_leg`, `right_front_leg`, `left_front_leg` exist in all four cow layers.

`CowModel` also holds a static `BABY_TRANSFORMER` (a `BabyModelTransform` with scaleHead false, head y offset 8, head z offset 6, head part set {`head`}, defaults for the rest). **No layer of the registry applies it** (the registry's only uses of `BABY_TRANSFORMER` are the humanoid, elytra and happy ghast ones), so it has no effect on rendering (read; see Open question 5).

### 2.3 Geometry

Layer `cow` (also the `mooshroom` layer):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 4, -8 | 0, 0, 0 | tex (0, 0) o (-4, -4, -6) s (8, 8, 6)<br>tex (1, 33) o (-3, 1, -7) s (6, 3, 1)<br>tex (22, 0) o (-5, -5, -5) s (1, 3, 1) [right_horn]<br>tex (22, 0) o (4, -5, -5) s (1, 3, 1) [left_horn] |
| `body` | 0, 5, 2 | 1.5707964, 0, 0 | tex (18, 4) o (-6, -10, -7) s (12, 18, 10)<br>tex (52, 0) o (-2, 2, -8) s (4, 6, 1) |
| `right_hind_leg` | -4, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) |
| `left_hind_leg` | 4, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) mirror |
| `right_front_leg` | -4, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) |
| `left_front_leg` | 4, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) mirror |

Layer `cold_cow` (replaces `body` and `head`, adds the horn parts as children of `head`; the four legs are those of `cow`):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 4, -8 | 0, 0, 0 | tex (0, 0) o (-4, -4, -6) s (8, 8, 6)<br>tex (9, 33) o (-3, 1, -7) s (6, 3, 1) |
| `body` | 0, 5, 2 | 1.5707964, 0, 0 | tex (20, 32) o (-6, -10, -7) s (12, 18, 10) grow 0.5<br>tex (18, 4) o (-6, -10, -7) s (12, 18, 10)<br>tex (52, 0) o (-2, 2, -8) s (4, 6, 1) |
| `right_hind_leg` | -4, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) |
| `left_hind_leg` | 4, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) mirror |
| `right_front_leg` | -4, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) |
| `left_front_leg` | 4, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) mirror |
| `head/right_horn` | -4.5, -2.5, -3.5 | 1.5708, 0, 0 | tex (0, 40) o (-1.5, -4.5, -0.5) s (2, 6, 2) |
| `head/left_horn` | 5.5, -2.5, -5 | 1.5708, 0, 0 | tex (0, 32) o (-1.5, -3, -0.5) s (2, 6, 2) |

Layer `warm_cow` (replaces only `head`; `body` and legs as `cow`):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 4, -8 | 0, 0, 0 | tex (0, 0) o (-4, -4, -6) s (8, 8, 6)<br>tex (1, 33) o (-3, 1, -7) s (6, 3, 1)<br>tex (27, 0) o (-8, -3, -5) s (4, 2, 2)<br>tex (39, 0) o (-8, -5, -5) s (2, 2, 2)<br>tex (27, 0) o (4, -3, -5) s (4, 2, 2) mirror<br>tex (39, 0) o (6, -5, -5) s (2, 2, 2) mirror |
| `body` | 0, 5, 2 | 1.5707964, 0, 0 | tex (18, 4) o (-6, -10, -7) s (12, 18, 10)<br>tex (52, 0) o (-2, 2, -8) s (4, 6, 1) |
| `right_hind_leg` | -4, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) |
| `left_hind_leg` | 4, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) mirror |
| `right_front_leg` | -4, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) |
| `left_front_leg` | 4, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) mirror |

Layer `cow_baby` (also `cold_cow_baby`, `warm_cow_baby`, `mooshroom_baby`; separate baked instances):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 13.569, -5.1667 | 0, 0, 0 | tex (0, 18) o (-3, -4.569, -4.8333) s (6, 6, 5)<br>tex (8, 29) o (3, -5.569, -3.8333) s (1, 2, 1)<br>tex (4, 29) o (-4, -5.569, -3.8333) s (1, 2, 1) mirror<br>tex (12, 29) o (-2, -1.569, -5.8333) s (4, 3, 1) |
| `body` | 3, 19, -5 | 0, 0, 0 | tex (0, 0) o (-7, -7, -1) s (8, 6, 12) |
| `right_front_leg` | -2.5, 18, -3.5 | 0, 0, 0 | tex (22, 18) o (-1.5, 0, -1.5) s (3, 6, 3) |
| `left_front_leg` | 2.5, 18, -3.5 | 0, 0, 0 | tex (34, 18) o (-1.5, 0, -1.5) s (3, 6, 3) |
| `right_hind_leg` | -2.5, 18, 3.5 | 0, 0, 0 | tex (22, 27) o (-1.5, 0, -1.5) s (3, 6, 3) |
| `left_hind_leg` | 2.5, 18, 3.5 | 0, 0, 0 | tex (34, 27) o (-1.5, 0, -1.5) s (3, 6, 3) |

Note the cold cow's body carries an extra cuboid with grow 0.5 listed first (the shaggy coat), and the cold cow horns are separate child parts rotated 90 deg about x.

---

## 3. Mooshroom

### 3.1 Renderer (`MushroomCowRenderer`, `MushroomCowRenderState`)

- Extends `AgeableMobRenderer`; shadow 0.7; adult model layer `mooshroom`, baby `mooshroom_baby` (geometry of `cow` and `cow_baby`, section 2.3). One layer: `MushroomCowMushroomLayer`.
- State adds `variant` (`MushroomCow$Variant`) and `mushroomModel` (a `BlockModelRenderState`). Extraction: `variant = entity.getVariant()` and the block model resolver updates `mushroomModel` from the variant's block state with a fixed `BlockDisplayContext` (created once: `BlockDisplayContext.create()`). Block model rendering is 12 §8 and 14.
- Variant enum (`MushroomCow$Variant`): `RED` (ordinal 0, name `red`, block state: the default state of the red mushroom block, a second int 0), `BROWN` (ordinal 1, name `brown`, brown mushroom default state, second int 1); default `RED`; id map clamps out-of-range ids.
- Texture: a static table keyed by variant, each entry (adult, baby): `RED`: `textures/entity/cow/mooshroom_red.png`, `mooshroom_red_baby.png`; `BROWN`: `mooshroom_brown.png`, `mooshroom_brown_baby.png` (all in `textures/entity/cow/`). Adult or baby by `isBaby`.
- `setupAnim`: as the cow (section 2.2).

### 3.2 `MushroomCowMushroomLayer`

Drawn only when the mooshroom is **not a baby** and `mushroomModel` is not empty. Let `outlineOnly` = (the entity appears glowing and is invisible). If the entity is invisible and `outlineOnly` is false, draw nothing. Overlay coordinates are `LivingEntityRenderer.getOverlayCoords(state, 0)` (hurt flash only). Each of three copies of the block model is submitted with `submit(pose, collector, light, overlay, outlineColor)`, or, when `outlineOnly`, only its outline (`submitOnlyOutline`). The three copies, each between a push and a pop of the pose stack (all in the body space after the model's own flip, that is with the coordinate system of the parts):

| Copy | Pose operations, in order |
|---|---|
| 1 | translate (0.2, -0.35, 0.5); rotate -48 deg about Y; scale (-1, -1, 1); translate (-0.5, -0.5, -0.5) |
| 2 | translate (0.2, -0.35, 0.5); rotate 42 deg about Y; translate (0.1, 0, -0.6); rotate -48 deg about Y; scale (-1, -1, 1); translate (-0.5, -0.5, -0.5) |
| 3 | apply the `head` part's own transform of the parent model (`getHead().translateAndRotate`, so it follows head turns); translate (0, -0.7, -0.2); rotate -78 deg about Y; scale (-1, -1, 1); translate (-0.5, -0.5, -0.5) |

(the pose operations above, including translate -0.5 x3 and scale (-1, -1, 1), were read in the bytecode; only the stated purpose, that the scale undoes the living-entity flip for the block and the final translate centres the unit block on the pivot, is inferred, Open question 14). No further scale was found in the code read, so the block model is drawn at its own size.

---

## 4. Pig

### 4.1 Renderer (`PigRenderer`, `PigRenderState`)

- Extends `MobRenderer` (not `AgeableMobRenderer`); shadow 0.7. Model pairs by `PigVariant$ModelType`: `NORMAL` = (`pig`, `pig_baby`), `COLD` = (`cold_pig`, `pig_baby`). Models are `PigModel`, `ColdPigModel` and `BabyPigModel` (extends `PigModel`).
- State: `saddle` (an `ItemStack`), `variant` (`PigVariant`). Extraction: `saddle` = copy of the item in the `SADDLE` equipment slot; `variant` = `getVariant().value()`.
- Submit and texture: as the cow (null variant draws nothing; baby texture or adult texture path from the variant).
- Layer: `SimpleEquipmentLayer` with layer type `pig_saddle`, item getter = `state.saddle`, adult model = a `PigModel` baked from layer `pig_saddle` (the pig body mesh with every box grown by 0.5), baby model null. So a baby pig never shows a saddle.
- `setupAnim`: `QuadrupedModel` (part 1 §3.4); the saddle model is also a `PigModel` and is posed the same way.

The pig mesh is `QuadrupedModel.createBodyMesh(6, false, false, deformation)` followed by the head snout cuboid (read: the leg height argument is 6; the `deformation` argument is `NONE` for the body layer and a 0.5 grow for `pig_saddle`, applied to the head, snout, body and leg cuboids).

### 4.2 Geometry

Layer `pig` (texture 64 x 64):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 12, -6 | 0, 0, 0 | tex (0, 0) o (-4, -4, -8) s (8, 8, 8)<br>tex (16, 16) o (-2, 0, -9) s (4, 3, 1) |
| `body` | 0, 11, 2 | 1.5707964, 0, 0 | tex (28, 8) o (-5, -10, -7) s (10, 16, 8) |
| `right_hind_leg` | -3, 18, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) |
| `left_hind_leg` | 3, 18, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) mirror |
| `right_front_leg` | -3, 18, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) |
| `left_front_leg` | 3, 18, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) mirror |

Layer `pig_saddle`: the same parts and pivots as `pig`; every cuboid carries `grow 0.5` (the table follows):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 12, -6 | 0, 0, 0 | tex (0, 0) o (-4, -4, -8) s (8, 8, 8) grow 0.5<br>tex (16, 16) o (-2, 0, -9) s (4, 3, 1) grow 0.5 |
| `body` | 0, 11, 2 | 1.5707964, 0, 0 | tex (28, 8) o (-5, -10, -7) s (10, 16, 8) grow 0.5 |
| `right_hind_leg` | -3, 18, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) grow 0.5 |
| `left_hind_leg` | 3, 18, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) grow 0.5 mirror |
| `right_front_leg` | -3, 18, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) grow 0.5 |
| `left_front_leg` | 3, 18, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) grow 0.5 mirror |

Layer `cold_pig` (the body gains a second, grown coat cuboid):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 12, -6 | 0, 0, 0 | tex (0, 0) o (-4, -4, -8) s (8, 8, 8)<br>tex (16, 16) o (-2, 0, -9) s (4, 3, 1) |
| `body` | 0, 11, 2 | 1.5707964, 0, 0 | tex (28, 8) o (-5, -10, -7) s (10, 16, 8)<br>tex (28, 32) o (-5, -10, -7) s (10, 16, 8) grow 0.5 |
| `right_hind_leg` | -3, 18, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) |
| `left_hind_leg` | 3, 18, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) mirror |
| `right_front_leg` | -3, 18, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) |
| `left_front_leg` | 3, 18, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) mirror |

Layer `pig_baby` (`BabyPigModel`; note the smaller texture):

Texture size 32 x 32.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 19, 0.5 | 0, 0, 0 | tex (0, 0) o (-3.5, -3, -4.5) s (7, 6, 9) |
| `head` | 0, 19, -2 | 0, 0, 0 | tex (0, 15) o (-3.5, -5, -5) s (7, 6, 6) grow 0.025<br>tex (6, 27) o (-1.5, -1.975, -6) s (3, 2, 1) grow 0.015 |
| `left_front_leg` | 2.5, 22, -3 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 2, 2) |
| `right_front_leg` | -2.5, 22, -3 | 0, 0, 0 | tex (23, 0) o (-1, 0, -1) s (2, 2, 2) |
| `left_hind_leg` | 2.5, 22, 4 | 0, 0, 0 | tex (0, 4) o (-1, 0, -1) s (2, 2, 2) |
| `right_hind_leg` | -2.5, 22, 4 | 0, 0, 0 | tex (23, 4) o (-1, 0, -1) s (2, 2, 2) |

---

## 5. Sheep

### 5.1 Renderer (`SheepRenderer`, `SheepRenderState`)

- Extends `AgeableMobRenderer`; shadow 0.7; adult `sheep`, baby `sheep_baby` (`SheepModel` and `BabySheepModel`, which extends `SheepModel`).
- State fields: `headEatPositionScale`, `headEatAngleScale` (floats), `isSheared`, `woolColor` (`DyeColor`, default `WHITE`), `isJebSheep`. Extraction: `headEatAngleScale = entity.getHeadEatAngleScale(partial)`, `headEatPositionScale = entity.getHeadEatPositionScale(partial)`, `isSheared`, `woolColor = entity.getColor()`, `isJebSheep` = the entity's custom name string equals the text `jeb_` (the helper `checkMagicName`: a custom name must exist and equal the text).
- Texture: `textures/entity/sheep/sheep.png` adult, `sheep_baby.png` baby (`textures/entity/sheep/`).
- Layers in order: `SheepWoolUndercoatLayer`, then `SheepWoolLayer`.
- `state.getWoolColor()`: if `isJebSheep` the lerped colour of section 5.6 at `ageInTicks`; else the sheep colour of `woolColor` (section 5.6 table). The result is an ARGB tint.

### 5.2 `setupAnim` (`SheepModel`, also used by the wool layer models and the baby)

`SheepModel` and `SheepFurModel` both extend `QuadrupedModel` and run the same `setupAnim` after the quadruped one (the baby sheep model inherits it): head `y` += `headEatPositionScale` x 9 x `ageScale` (1 for an adult, 0.5 for a baby; added to the current value, the initial pose y), then head `xRot` = `headEatAngleScale` (this **replaces** the look pitch the quadruped step wrote; the head `yRot` from the quadruped step stays).

### 5.3 Wool layers

`SheepWoolUndercoatLayer` (model class `SheepFurModel` baked from layer `sheep_wool_undercoat`, whose geometry is the **full `sheep` body layer**, texture `textures/entity/sheep/sheep_wool_undercoat.png`): drawn when the sheep is not invisible **and** (it is a jeb sheep or its colour is not white) **and** it is not a baby. It is drawn even when sheared. It is a coloured cut-out draw: tint = `state.getWoolColor()`, sub-order 1.

`SheepWoolLayer`: draws nothing when the sheep is sheared. Otherwise model = the adult wool model (`SheepFurModel`, layer `sheep_wool`, texture `textures/entity/sheep/sheep_wool.png`) or, for a baby, the baby wool model (`SheepFurModel` baked from layer `sheep_baby_wool`, which has the **baby sheep geometry**, texture `textures/entity/sheep/sheep_wool_baby.png`). If the sheep is invisible: nothing unless it appears glowing, in which case the model is submitted once with the outline render type of the same texture, colour -16777216 (opaque black) and the entity outline colour. Else a coloured cut-out draw with tint `state.getWoolColor()`, sub-order 1 for a baby and 0 for an adult.

A "coloured cut-out draw" (`RenderLayer.coloredCutoutModelCopyLayerRender`) does nothing when the entity is invisible; otherwise it submits the model with `entityCutout(texture)`, the entity's light, overlay `getOverlayCoords(state, 0)`, the tint and the outline colour at the given order. The model is posed from the state as in section 1.4.

### 5.4 Geometry

Layer `sheep` (texture 64 x 32; also the undercoat layer):

Texture size 64 x 32.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 6, -8 | 0, 0, 0 | tex (0, 0) o (-3, -4, -6) s (6, 6, 8) |
| `body` | 0, 5, 2 | 1.5707964, 0, 0 | tex (28, 8) o (-4, -10, -7) s (8, 16, 6) |
| `right_hind_leg` | -3, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) mirror |
| `left_hind_leg` | 3, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) |
| `right_front_leg` | -3, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) mirror |
| `left_front_leg` | 3, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 12, 4) |

Layer `sheep_wool` (adult wool; grown cuboids, the legs are shorter):

Texture size 64 x 32.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 6, -8 | 0, 0, 0 | tex (0, 0) o (-3, -4, -4) s (6, 6, 6) grow 0.6 |
| `body` | 0, 5, 2 | 1.5707964, 0, 0 | tex (28, 8) o (-4, -10, -7) s (8, 16, 6) grow 1.75 |
| `right_hind_leg` | -3, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) grow 0.5 |
| `left_hind_leg` | 3, 12, 7 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) grow 0.5 |
| `right_front_leg` | -3, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) grow 0.5 |
| `left_front_leg` | 3, 12, -5 | 0, 0, 0 | tex (0, 16) o (-2, 0, -2) s (4, 6, 4) grow 0.5 |

Layer `sheep_baby` (also layer `sheep_baby_wool`; note texture size 64 x 32):

Texture size 64 x 32.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 17, 0.5 | 0, 0, 0 | tex (0, 10) o (-3, -2, -4.5) s (6, 4, 9) |
| `head` | 0, 15.5, -2.5 | 0, 0, 0 | tex (0, 0) o (-2.5, -4.5, -3.5) s (5, 5, 5) |
| `right_hind_leg` | -2, 19, 3 | 0, 0, 0 | tex (0, 23) o (-1, 0, -1) s (2, 5, 2) |
| `left_hind_leg` | 2, 19, 3 | 0, 0, 0 | tex (24, 12) o (-1, 0, -1) s (2, 5, 2) |
| `right_front_leg` | -2, 19, -2 | 0, 0, 0 | tex (8, 23) o (-1, 0, -1) s (2, 5, 2) |
| `left_front_leg` | 2, 19, -2 | 0, 0, 0 | tex (24, 5) o (-1, 0, -1) s (2, 5, 2) |

### 5.5 Dye ordinals and the sheep colour table

`DyeColor` enum order (ordinal = id; the texture diffuse colour is the code constant, made opaque; the sheep colour is `ColorLerper.getModifiedColor(dye, 0.75)`: white gives the fixed value -1644826 = 0xFFE6E6E6; any other dye gives alpha 255 and each of red, green, blue = `clamp(floor(channel x 0.75), 0, 255)`):

| Ordinal | Dye | Texture diffuse colour (RGB) | Sheep colour (ARGB, brightness 0.75) |
|---|---|---|---|
| 0 | white | 0xF9FFFE | 0xFFE6E6E6 |
| 1 | orange | 0xF9801D | 0xFFBA6015 |
| 2 | magenta | 0xC74EBD | 0xFF953A8D |
| 3 | light_blue | 0x3AB3DA | 0xFF2B86A3 |
| 4 | yellow | 0xFED83D | 0xFFBEA22D |
| 5 | lime | 0x80C71F | 0xFF609517 |
| 6 | pink | 0xF38BAA | 0xFFB6687F |
| 7 | gray | 0x474F52 | 0xFF353B3D |
| 8 | light_gray | 0x9D9D97 | 0xFF757571 |
| 9 | cyan | 0x169C9C | 0xFF107575 |
| 10 | purple | 0x8932B8 | 0xFF66258A |
| 11 | blue | 0x3C44AA | 0xFF2D337F |
| 12 | brown | 0x835432 | 0xFF623F25 |
| 13 | green | 0x5E7C16 | 0xFF465D10 |
| 14 | red | 0xB02E26 | 0xFF84221C |
| 15 | black | 0x1D1D21 | 0xFF151518 |

### 5.6 Jeb sheep colour (`ColorLerper$Type.SHEEP`, `ColorLerper.getLerpedColor`)

The `SHEEP` type has colour duration 25 (ticks per colour), brightness 0.75 and the colour list = all sixteen dyes in the ordinal order above, each already passed through the table of 5.5 (so the list holds the sheep colours). For a float time `a` (the render state `ageInTicks`): `i = floor(a)`, `step = i div 25` (integer division), `c0 = colours[step mod 16]`, `c1 = colours[(step + 1) mod 16]`, `t = ((i mod 25) + frac(a)) / 25` with `frac(a) = a - floor(a)`. The result is, per channel (alpha, red, green, blue): `c0 + floor(t (c1 - c0))` (`Mth.lerpInt`; floor of a negative number rounds toward minus infinity), no gamma conversion despite the method name `srgbLerp`. The colour changes continuously and cycles through all sixteen dyes in 400 ticks.

---

## 6. Chicken

### 6.1 Renderer (`ChickenRenderer`, `ChickenRenderState`)

- Extends `MobRenderer` (not `AgeableMobRenderer`); shadow 0.3. Model pairs by `ChickenVariant$ModelType`: `NORMAL` = (`chicken`, `chicken_baby`), `COLD` = (`cold_chicken`, `chicken_baby`). Models: `AdultChickenModel`, `ColdChickenModel` (extends `AdultChickenModel`), `BabyChickenModel`; the common base is `ChickenModel`.
- State: `flap`, `flapSpeed`, `variant`. Extraction: `flap = lerp(partial, entity.oFlap, entity.flap)`, `flapSpeed = lerp(partial, entity.oFlapSpeed, entity.flapSpeed)` (the entity fields are the previous and current values), `variant = getVariant().value()`.
- Submit and texture as the cow. No layers.

### 6.2 `setupAnim`

`ChickenModel.setupAnim` (all three models): with `p = walkAnimationPos`, `s = walkAnimationSpeed`, `w = (Mth.sin(flap) + 1) x flapSpeed`: `right_leg.xRot = cos(0.6662 p) x 1.4 s`; `left_leg.xRot = cos(0.6662 p + pi) x 1.4 s`; `right_wing.zRot = w`; `left_wing.zRot = -w`. `AdultChickenModel` (and the cold chicken) additionally sets `head.xRot = state.xRot x D` and `head.yRot = state.yRot x D`. `BabyChickenModel` has no `head` part (head and body are one cuboid group in `body`) and no head turn.

### 6.3 Geometry

Layer `chicken` (texture 64 x 32):

Texture size 64 x 32.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 15, -4 | 0, 0, 0 | tex (0, 0) o (-2, -6, -2) s (4, 6, 3) |
| `head/beak` | 0, 0, 0 | 0, 0, 0 | tex (14, 0) o (-2, -4, -4) s (4, 2, 2) |
| `head/red_thing` | 0, 0, 0 | 0, 0, 0 | tex (14, 4) o (-1, -2, -3) s (2, 2, 2) |
| `body` | 0, 16, 0 | 1.5707964, 0, 0 | tex (0, 9) o (-3, -4, -3) s (6, 8, 6) |
| `right_leg` | -2, 19, 1 | 0, 0, 0 | tex (26, 0) o (-1, 0, -3) s (3, 5, 3) |
| `left_leg` | 1, 19, 1 | 0, 0, 0 | tex (26, 0) o (-1, 0, -3) s (3, 5, 3) |
| `right_wing` | -4, 13, 0 | 0, 0, 0 | tex (24, 13) o (0, 0, -3) s (1, 4, 6) |
| `left_wing` | 4, 13, 0 | 0, 0, 0 | tex (24, 13) o (-1, 0, -3) s (1, 4, 6) |

Layer `cold_chicken` (head and body gain extra cuboids, the rest as `chicken`):

Texture size 64 x 32.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 15, -4 | 0, 0, 0 | tex (0, 0) o (-2, -6, -2) s (4, 6, 3)<br>tex (44, 0) o (-3, -7, -2.015) s (6, 3, 4) |
| `head/beak` | 0, 0, 0 | 0, 0, 0 | tex (14, 0) o (-2, -4, -4) s (4, 2, 2) |
| `head/red_thing` | 0, 0, 0 | 0, 0, 0 | tex (14, 4) o (-1, -2, -3) s (2, 2, 2) |
| `body` | 0, 16, 0 | 1.5707964, 0, 0 | tex (0, 9) o (-3, -4, -3) s (6, 8, 6)<br>tex (38, 9) o (0, 3, -1) s (0, 3, 5) |
| `right_leg` | -2, 19, 1 | 0, 0, 0 | tex (26, 0) o (-1, 0, -3) s (3, 5, 3) |
| `left_leg` | 1, 19, 1 | 0, 0, 0 | tex (26, 0) o (-1, 0, -3) s (3, 5, 3) |
| `right_wing` | -4, 13, 0 | 0, 0, 0 | tex (24, 13) o (0, 0, -3) s (1, 4, 6) |
| `left_wing` | 4, 13, 0 | 0, 0, 0 | tex (24, 13) o (-1, 0, -3) s (1, 4, 6) |

Layer `chicken_baby` (texture 16 x 16; zero-thickness cuboids, part 3 §0.1 item 4, for the feet and wings):

Texture size 16 x 16.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 20.25, -1.25 | 0, 0, 0 | tex (0, 0) o (-2, -2.25, -0.75) s (4, 4, 4)<br>tex (10, 8) o (-1, -0.25, -1.75) s (2, 1, 1) |
| `left_leg` | 1, 22, 0.5 | 0, 0, 0 | tex (2, 2) o (-0.5, 0, 0) s (1, 2, 0)<br>tex (0, 1) o (-0.5, 2, -1) s (1, 0, 1) |
| `right_leg` | -1, 22, 0.5 | 0, 0, 0 | tex (0, 2) o (-0.5, 0, 0) s (1, 2, 0)<br>tex (0, 0) o (-0.5, 2, -1) s (1, 0, 1) |
| `right_wing` | 2, 20, 0 | 0, 0, 0 | tex (6, 8) o (0, 0, -1) s (1, 0, 2) |
| `left_wing` | -2, 20, 0 | 0, 0, 0 | tex (4, 8) o (-1, 0, -1) s (1, 0, 2) |

---

## 7. Goat

### 7.1 Renderer (`GoatRenderer`, `GoatRenderState`)

- Extends `AgeableMobRenderer`; shadow 0.7; adult `goat`, baby `goat_baby` (`GoatModel`, and `BabyGoatModel` which extends it). No layers.
- State: `hasLeftHorn`, `hasRightHorn` (booleans), `rammingXHeadRot` (float). Extraction copies `hasLeftHorn()`, `hasRightHorn()` and `getRammingXHeadRot()` of the entity.
- Texture: `textures/entity/goat/goat.png`, baby `textures/entity/goat/goat_baby.png`.

### 7.2 `setupAnim`

`GoatModel` extends `QuadrupedModel` (head and legs as part 1 §3.4), then: the part `head/left_horn` is visible iff `hasLeftHorn`; `head/right_horn` visible iff `hasRightHorn`; when `rammingXHeadRot` is not exactly 0, `head.xRot = rammingXHeadRot` (replaces the look pitch). `BabyGoatModel` runs that, then, when `rammingXHeadRot` is exactly 0, sets `head.xRot = 0.3926991` (22.5 deg, a fixed downward tilt, overriding the look pitch). The ears and goatee are part of the head cuboids, not separate parts, in the adult; the baby has ear parts that keep their pose.

### 7.3 Geometry

Layer `goat` (texture 64 x 64):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 1, 14, 0 | 0, 0, 0 | tex (2, 61) o (-6, -11, -10) s (3, 2, 1) [right ear]<br>tex (2, 61) o (2, -11, -10) s (3, 2, 1) mirror [left ear]<br>tex (23, 52) o (-0.5, -3, -14) s (0, 7, 5) mirror [goatee] |
| `head/left_horn` | 0, 0, 0 | 0, 0, 0 | tex (12, 55) o (-0.01, -16, -10) s (2, 7, 2) |
| `head/right_horn` | 0, 0, 0 | 0, 0, 0 | tex (12, 55) o (-2.99, -16, -10) s (2, 7, 2) |
| `head/nose` | 0, -8, -8 | 0.9599, 0, 0 | tex (34, 46) o (-3, -4, -8) s (5, 7, 10) |
| `body` | 0, 24, 0 | 0, 0, 0 | tex (1, 1) o (-4, -17, -7) s (9, 11, 16)<br>tex (0, 28) o (-5, -18, -8) s (11, 14, 11) |
| `left_hind_leg` | 1, 14, 4 | 0, 0, 0 | tex (36, 29) o (0, 4, 0) s (3, 6, 3) |
| `right_hind_leg` | -3, 14, 4 | 0, 0, 0 | tex (49, 29) o (0, 4, 0) s (3, 6, 3) |
| `left_front_leg` | 1, 14, -6 | 0, 0, 0 | tex (49, 2) o (0, 0, 0) s (3, 10, 3) |
| `right_front_leg` | -3, 14, -6 | 0, 0, 0 | tex (35, 2) o (0, 0, 0) s (3, 10, 3) |

Layer `goat_baby`:

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `left_hind_leg` | 1.5, 19.5, 3 | 0, 0, 0 | tex (29, 12) o (-1, -0.5, -1) s (2, 5, 2) |
| `right_hind_leg` | -1.5, 19.5, 3 | 0, 0, 0 | tex (21, 12) o (-1, -0.5, -1) s (2, 5, 2) |
| `right_front_leg` | -1.5, 19.5, -2 | 0, 0, 0 | tex (21, 5) o (-1, -0.5, -1) s (2, 5, 2) |
| `left_front_leg` | 1.5, 19.5, -2 | 0, 0, 0 | tex (29, 5) o (-1, -0.5, -1) s (2, 5, 2) |
| `body` | 0, 17.8, 0 | 0, 0, 0 | tex (0, 10) o (-3, -2.3, -4.5) s (6, 5, 9)<br>tex (0, 24) o (-2.5, -2.2, -4) s (5, 4, 8) |
| `head` | 0, 15.5, -3 | 0.4363, 0, 0 | tex (0, 0) o (-2, -3.8126, -5.1548) s (4, 4, 6) |
| `head/right_horn` | -1.5, -1.5, -1 | -0.3926991, 0, 0 | tex (24, 0) o (0, -4.5, 0) s (1, 2, 1) mirror |
| `head/left_horn` | -1.5, -1.5, -1 | -0.3926991, 0, 0 | tex (24, 0) o (2, -4.5, 0) s (1, 2, 1) mirror |
| `head/right_ear` | -1.7, -2.3126, 0.1452 | 0, -0.5236, 0 | tex (0, 12) o (-2, -0.5, -0.5) s (2, 1, 1) mirror |
| `head/left_ear` | 1.7, -2.3126, 0.1452 | 0, 0.5236, 0 | tex (0, 12) o (0, -0.5, -0.5) s (2, 1, 1) |
| `head/HeadMain` | 0, -1.3126, -1.1548 | 0, 0, 0 | tex (0, 0) o (-2, -2.5, -4) s (4, 4, 6) |

---

## 8. Equines: horse, donkey, mule, skeleton horse, zombie horse

### 8.1 Renderers and states

- `AbstractHorseRenderer` (`AgeableMobRenderer`) has base shadow 0.75 and extracts, for every equine: `saddle` = copy of the `SADDLE` slot item, `bodyArmorItem` = copy of `getBodyArmorItem()`, `isRidden = isVehicle()`, `eatAnimation = getEatAnim(partial)`, `standAnimation = getStandAnim(partial)`, `feedingAnimation = getMouthAnim(partial)`, `animateTail = tailCounter > 0`. (`EquineRenderState`.) The values come from the entity and are 0..1 progress values (their dynamics are entity code, 19 and 44 part 4).
- `HorseRenderState` adds `variant` (`Horse` colour `Variant`) and `markings` (`Markings`); `DonkeyRenderState` adds `hasChest`. `HorseRenderer` extraction also copies `getVariant()` and `getMarkings()`; `DonkeyRenderer` copies `hasChest()`.
- **Model classes.** `HorseModel` (extends `AbstractEquineModel`), `BabyHorseModel` (extends `HorseModel`), `DonkeyModel` (extends `AbstractEquineModel`, used for donkey and mule), `BabyDonkeyModel` (extends `DonkeyModel`, used for baby donkey and baby mule), `EquineSaddleModel` (extends `AbstractEquineModel`, used by every saddle layer here). Skeleton and zombie horse use `HorseModel` and `BabyHorseModel` (layer ids `skeleton_horse`, `zombie_horse` and their `_baby`, section 8.4).

### 8.2 Renderer registrations

| Entity | Renderer | Saddle layer type, saddle model layer | Adult / baby model layer | Textures |
|---|---|---|---|---|
| horse | `HorseRenderer` | `horse_saddle` / `horse_saddle` (scaled 1.1) | `horse` / `horse_baby` | section 8.5 |
| donkey | `DonkeyRenderer` | `donkey_saddle` / `donkey_saddle` (scaled 0.87) | `donkey` / `donkey_baby` | `textures/entity/horse/donkey.png`, `donkey_baby.png` |
| mule | `DonkeyRenderer` | `mule_saddle` / `mule_saddle` (scaled 0.92) | `mule` / `mule_baby` | `textures/entity/horse/mule.png`, `mule_baby.png` |
| skeleton horse | `UndeadHorseRenderer` | `skeleton_horse_saddle` / `skeleton_horse_saddle` | `skeleton_horse` / `skeleton_horse_baby` | `textures/entity/horse/horse_skeleton.png`, `horse_skeleton_baby.png` |
| zombie horse | `UndeadHorseRenderer` | `zombie_horse_saddle` / `zombie_horse_saddle` | `zombie_horse` / `zombie_horse_baby` | `textures/entity/horse/horse_zombie.png`, `horse_zombie_baby.png` |

`DonkeyRenderer` and `UndeadHorseRenderer` take (layer type of the saddle, saddle model layer, adult `Type`, baby `Type`) as constructor arguments; each `Type` bundles a texture and a model layer (`DonkeyRenderer$Type`: `DONKEY`, `DONKEY_BABY`, `MULE`, `MULE_BABY`; `UndeadHorseRenderer$Type`: `SKELETON`, `SKELETON_BABY`, `ZOMBIE`, `ZOMBIE_BABY`). Texture rule: baby uses the baby `Type` texture, adult the adult one. Layers: `DonkeyRenderer` adds only the saddle layer (default order 0, `babyModel` null). `UndeadHorseRenderer` adds the body-armor layer first (layer type `horse_body`, item getter `bodyArmorItem`, model `UNDEAD_HORSE_ARMOR`, a `HorseModel` of the unscaled body mesh grown by 0.1, baby null, order 0) and then the saddle layer (item getter `saddle`, baby null, order 0). `HorseRenderer` adds, in order: `HorseMarkingLayer`; the body-armor layer (layer type `horse_body`, item `bodyArmorItem`, model `horse_armor` (body mesh grown by 0.1, scaled 1.1), baby null, order 2); the saddle layer (`horse_saddle`, model `horse_saddle` scaled 1.1, item `saddle`, baby null, order 2).

### 8.3 `setupAnim` of `AbstractEquineModel` (all equines, read in full)

Parts looked up at bake time: `body`, `head_parts`, `right_hind_leg`, `left_hind_leg`, `right_front_leg`, `left_front_leg` as children of the root, and `tail` as a child of `body`. (The baby donkey bakes with the legs and `head_parts` as children of `body`; see 8.7.)

Inputs: `yaw` = clamp(`state.yRot`, -20 deg, 20 deg) (in degrees); `pitch` = `state.xRot` x D; `s` = `walkAnimationSpeed`, `p` = `walkAnimationPos`; `eat`, `stand`, `feed` = `eatAnimation`, `standAnimation`, `feedingAnimation`; `age` = `ageInTicks`; `ageScale`. Steps:

1. If `s > 0.2`: `pitch` += `cos(0.8 p)` x 0.15 x `s`.
2. `water` = 0.2 if the entity is in water, else 1. `c` = `cos(water x p x 0.6662 + pi)`; `leg` = `c` x 0.8 x `s`.
3. `grazing = (1 - max(stand, eat)) x ((0.5235988 + pitch) + feed x sin(age) x 0.05)`.
4. `head_parts.xRot = stand x (0.2617994 + pitch) + eat x (2.1816616 + sin(age) x 0.05) + grazing`. (`sin` and `cos` are the table functions of part 3 §0.1 item 9.)
5. `head_parts.yRot = stand x yaw x D + (1 - max(stand, eat)) x (yaw x D)`: the code first stores `0.5235988 + pitch` in `xRot` and `yaw x D` in `yRot`, then recombines with the current `yRot`, so the second term uses `yaw x D`.
6. `animateHeadPartsPlacement(eat, stand)` (subclass hook, section 8.6).
7. `body.xRot = stand x (-0.7853982) + (1 - stand) x body.xRot` (the initial `xRot`, 0).
8. `left_front_leg.y` -= `getLegStandingYOffset()` x `stand`; `left_front_leg.z` += `getLegStandingZOffset()` x `stand`; `right_front_leg.y` and `.z` are set equal to the left ones (so the right front leg takes the left leg's pivot, an asymmetry of the code kept as is).
9. `a = getLegStandAngle() x stand`; `w = cos(age x 0.6 + pi)`; `x0 = getLegStandingXRotOffset()`; `fl = (x0 + w) x stand + leg x (1 - stand)`; `fr = (x0 - w) x stand - leg x (1 - stand)`.
10. `left_hind_leg.xRot = a - (c x 0.5 x s) x (1 - stand)`; `right_hind_leg.xRot = a + (c x 0.5 x s) x (1 - stand)`; `left_front_leg.xRot = fl`; `right_front_leg.xRot = fr`.
11. `offsetLegPositionWhenStanding(stand)` (subclass hook; no effect in the adult).
12. `tail.xRot = getTailXRotOffset() + 0.5235988 + s x 0.75`; `tail.y` += `s` x `ageScale`; `tail.z` += `s` x 2 x `ageScale`; (`ageScale` is 1 for an adult, 0.5 for a baby; see section 1.6) `tail.yRot` = `cos(age x 0.7)` when `animateTail`, else 0.

Argument order of `lerp` in the table below is `(t, a, b)` with the weight `t` first, so `lerp(eat, lerp(stand, 0, -8), 7)` means: inner `lerp(stand, 0, -8)` = `-8 x stand`, outer blends from that value to 7 by `eat`; do not swap `eat` and `stand`.

Subclass constants (the abstract class gives defaults; `BabyHorseModel` and `BabyDonkeyModel` override some):

| Hook | Default (adult horse, donkey, saddle) | `BabyHorseModel` | `BabyDonkeyModel` |
|---|---|---|---|
| `getLegStandAngle()` | 0.2617994 | default | 1.0471976 |
| `getLegStandingYOffset()` | 12 | 4 | 1 |
| `getLegStandingZOffset()` | 4 | 0 | 0.5 |
| `getLegStandingXRotOffset()` | -1.0471976 | default | 0 |
| `getTailXRotOffset()` | 0 | -1.5707964 | -0.7853982 |
| `animateHeadPartsPlacement(eat, stand)` | `head_parts.y` += `lerp(eat, lerp(stand, 0, -8), 7)`; `head_parts.z` = `lerp(stand, head_parts.z, -4)` | `head_parts.y` += `lerp(eat, lerp(stand, 0, -2), 2)`; `head_parts.z` = `lerp(stand, head_parts.z, -4)` | `head_parts.y` = `lerp(eat, head_parts.y, -1.2)`; `head_parts.z` = `lerp(stand, head_parts.z, -3.6)` (assignments from the current value, not additions) |
| `offsetLegPositionWhenStanding(stand)` | none | none | `left_hind_leg.y` = `lerp(stand, left_hind_leg.y, -0.3)`, then `right_hind_leg.y` = `lerp(stand, left_hind_leg.y, -0.3)` (reads the **left** leg's value) |

### 8.4 Overrides and extra parts

- `HorseModel`, `BabyHorseModel`: no more behaviour than the table above (`BabyHorseModel` extends `HorseModel` and overrides only the hooks).
- `DonkeyModel.setupAnim`: the abstract `setupAnim`, then `left_chest.visible = right_chest.visible = state.hasChest`. The chests are children of `body`.
- `BabyDonkeyModel.setupAnim` (read in full): run the `DonkeyModel` one (which already wrote `head_parts.xRot`), then **write `-30 deg` into the render state's `xRot`** (the code assigns -30.0 to `state.xRot`), `pitch2 = -30 x D = -0.5235988`, and set `head_parts.xRot = stand x (0.2617994 + pitch2) + eat x (1.5707964 + sin(age) x 0.05) + (1 - max(stand, eat)) x ((0.5235988 + pitch2) + feed x sin(age) x 0.05)`. So the baby donkey and baby mule head ignores the real pitch (fixed at -30 deg) and uses 90 deg (not 125 deg) for the eating dip; `head_parts.yRot` keeps the value of the abstract step. The write goes to the shared render state (read), not to a copy.
- `EquineSaddleModel.setupAnim`: the abstract `setupAnim`, then both parts `head_parts/left_saddle_line` and `head_parts/right_saddle_line` (the reins) are visible iff `isRidden`. The saddle model does **not** toggle the chests: for `donkey_saddle` and `mule_saddle` (which carry the `left_chest` and `right_chest` cuboids) the two chest cuboids are always drawn with the saddle texture, even when the animal has no chest (see Open question 17). All other parts of the saddle model stay visible: the saddle layer draws the **whole horse mesh plus the saddle cuboids** with the saddle texture (which is transparent where there is no saddle).

### 8.5 Variants, textures and markings

`Horse` colour `Variant` (`id` = ordinal, name): WHITE 0 `white`, CREAMY 1 `creamy`, CHESTNUT 2 `chestnut`, BROWN 3 `brown`, BLACK 4 `black`, GRAY 5 `gray`, DARK_BROWN 6 `dark_brown` (id map wraps).

Texture of the body (`HorseRenderer`), adult / baby (directory `textures/entity/horse/`): WHITE `horse_white.png` / `horse_white_baby.png`; CREAMY `horse_creamy.png` / `horse_creamy_baby.png`; CHESTNUT `horse_chestnut.png` / `_baby`; BROWN `horse_brown.png` / `_baby`; BLACK `horse_black.png` / `_baby`; GRAY `horse_gray.png` / `_baby`; DARK_BROWN `horse_darkbrown.png` / `horse_darkbrown_baby.png` (the file name has no underscore inside "darkbrown"). Baby by `isBaby`.

`Markings` (id, name): NONE 0, WHITE 1, WHITE_FIELD 2, WHITE_DOTS 3, BLACK_DOTS 4 (wraps). `HorseMarkingLayer` textures (adult / baby, `textures/entity/horse/`): NONE: none (a sentinel `invisible` identifier); WHITE `horse_markings_white.png` / `horse_markings_white_baby.png`; WHITE_FIELD `horse_markings_whitefield.png` / `..._baby.png`; WHITE_DOTS `horse_markings_whitedots.png` / `..._baby.png`; BLACK_DOTS `horse_markings_blackdots.png` / `..._baby.png`. The layer draws only when the chosen texture is not the sentinel and the horse is not invisible: it submits the **parent model as currently posed** (the body model, adult or baby) with `entityTranslucent(texture)`, the entity light, overlay `getOverlayCoords(state, 0)`, the outline colour, at sub-order 1. Donkeys, mules and undead horses have no marking layer.

### 8.6 Layer builders and geometry

The base mesh `AbstractEquineModel.createBodyMesh(deformation)` (texture 64 x 64) is shared by every equine layer. Its cuboids fall in two groups: the body (grow constant 0.05), the neck box of `head_parts` (no grow) and the two ears (grow constant -0.001) keep fixed values whatever the deformation argument is; the cuboids of `head`, `mane`, `upper_mouth`, the four legs and `tail` take the deformation argument (`NONE` = grow 0, shown as no grow in the tables, or 0.1 for the armor layers). Layer `horse` is that mesh with `MeshTransformer.scaling(1.1)`; layers `skeleton_horse`, `zombie_horse` are the same mesh unscaled; layer `horse_armor` is the mesh with deformation 0.1 and scaling 1.1; `undead_horse_armor` is deformation 0.1 unscaled.

Layer `horse` (and `skeleton_horse`, `zombie_horse` without the scaling):

Texture size 64 x 64. Scaling applied to the root in order 1.1: root pose offset (0, -2.4016, 0), scale 1.1.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 11, 5 | 0, 0, 0 | tex (0, 32) o (-5, -8, -17) s (10, 10, 22) grow 0.05 |
| `head_parts` | 0, 4, -12 | 0.5235988, 0, 0 | tex (0, 35) o (-2.05, -6, -2) s (4, 12, 7) |
| `head_parts/head` | 0, 0, 0 | 0, 0, 0 | tex (0, 13) o (-3, -11, -2) s (6, 5, 7) |
| `head_parts/mane` | 0, 0, 0 | 0, 0, 0 | tex (56, 36) o (-1, -11, 5.01) s (2, 16, 2) |
| `head_parts/upper_mouth` | 0, 0, 0 | 0, 0, 0 | tex (0, 25) o (-2, -11, -7) s (4, 5, 5) |
| `left_hind_leg` | 4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1) s (4, 11, 4) mirror |
| `right_hind_leg` | -4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1) s (4, 11, 4) |
| `left_front_leg` | 4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1.9) s (4, 11, 4) mirror |
| `right_front_leg` | -4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1.9) s (4, 11, 4) |
| `body/tail` | 0, -5, 2 | 0.5235988, 0, 0 | tex (42, 36) o (-1.5, 0, 0) s (3, 14, 4) |
| `head_parts/head/left_ear` | 0, 0, 0 | 0, 0, 0 | tex (19, 16) o (0.55, -13, 4) s (2, 3, 1) grow -0.001 |
| `head_parts/head/right_ear` | 0, 0, 0 | 0, 0, 0 | tex (19, 16) o (-2.55, -13, 4) s (2, 3, 1) grow -0.001 |

For `horse_armor` and `undead_horse_armor` (deformation 0.1) the cuboids of `head`, `mane`, `upper_mouth`, the legs and `tail` get `grow 0.1`; body, neck box and ears are unchanged (read: the `horse_armor` table below). The table of `horse_armor` follows in full.

Texture size 64 x 64. Scaling applied to the root in order 1.1: root pose offset (0, -2.4016, 0), scale 1.1.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 11, 5 | 0, 0, 0 | tex (0, 32) o (-5, -8, -17) s (10, 10, 22) grow 0.05 |
| `head_parts` | 0, 4, -12 | 0.5235988, 0, 0 | tex (0, 35) o (-2.05, -6, -2) s (4, 12, 7) |
| `head_parts/head` | 0, 0, 0 | 0, 0, 0 | tex (0, 13) o (-3, -11, -2) s (6, 5, 7) grow 0.1 |
| `head_parts/mane` | 0, 0, 0 | 0, 0, 0 | tex (56, 36) o (-1, -11, 5.01) s (2, 16, 2) grow 0.1 |
| `head_parts/upper_mouth` | 0, 0, 0 | 0, 0, 0 | tex (0, 25) o (-2, -11, -7) s (4, 5, 5) grow 0.1 |
| `left_hind_leg` | 4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1) s (4, 11, 4) grow 0.1 mirror |
| `right_hind_leg` | -4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1) s (4, 11, 4) grow 0.1 |
| `left_front_leg` | 4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1.9) s (4, 11, 4) grow 0.1 mirror |
| `right_front_leg` | -4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1.9) s (4, 11, 4) grow 0.1 |
| `body/tail` | 0, -5, 2 | 0.5235988, 0, 0 | tex (42, 36) o (-1.5, 0, 0) s (3, 14, 4) grow 0.1 |
| `head_parts/head/left_ear` | 0, 0, 0 | 0, 0, 0 | tex (19, 16) o (0.55, -13, 4) s (2, 3, 1) grow -0.001 |
| `head_parts/head/right_ear` | 0, 0, 0 | 0, 0, 0 | tex (19, 16) o (-2.55, -13, 4) s (2, 3, 1) grow -0.001 |

Layer `horse_saddle` (also `skeleton_horse_saddle`, `zombie_horse_saddle` without scaling): the base mesh again followed by the saddle parts.

Texture size 64 x 64. Scaling applied to the root in order 1.1: root pose offset (0, -2.4016, 0), scale 1.1.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 11, 5 | 0, 0, 0 | tex (0, 32) o (-5, -8, -17) s (10, 10, 22) grow 0.05 |
| `head_parts` | 0, 4, -12 | 0.5235988, 0, 0 | tex (0, 35) o (-2.05, -6, -2) s (4, 12, 7) |
| `head_parts/head` | 0, 0, 0 | 0, 0, 0 | tex (0, 13) o (-3, -11, -2) s (6, 5, 7) |
| `head_parts/mane` | 0, 0, 0 | 0, 0, 0 | tex (56, 36) o (-1, -11, 5.01) s (2, 16, 2) |
| `head_parts/upper_mouth` | 0, 0, 0 | 0, 0, 0 | tex (0, 25) o (-2, -11, -7) s (4, 5, 5) |
| `left_hind_leg` | 4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1) s (4, 11, 4) mirror |
| `right_hind_leg` | -4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1) s (4, 11, 4) |
| `left_front_leg` | 4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1.9) s (4, 11, 4) mirror |
| `right_front_leg` | -4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1.9) s (4, 11, 4) |
| `body/tail` | 0, -5, 2 | 0.5235988, 0, 0 | tex (42, 36) o (-1.5, 0, 0) s (3, 14, 4) |
| `head_parts/head/left_ear` | 0, 0, 0 | 0, 0, 0 | tex (19, 16) o (0.55, -13, 4) s (2, 3, 1) grow -0.001 |
| `head_parts/head/right_ear` | 0, 0, 0 | 0, 0, 0 | tex (19, 16) o (-2.55, -13, 4) s (2, 3, 1) grow -0.001 |
| `body/saddle` | 0, 0, 0 | 0, 0, 0 | tex (26, 0) o (-5, -8, -9) s (10, 9, 9) grow 0.5 |
| `head_parts/left_saddle_mouth` | 0, 0, 0 | 0, 0, 0 | tex (29, 5) o (2, -9, -6) s (1, 2, 2) |
| `head_parts/right_saddle_mouth` | 0, 0, 0 | 0, 0, 0 | tex (29, 5) o (-3, -9, -6) s (1, 2, 2) |
| `head_parts/left_saddle_line` | 0, 0, 0 | -0.5235988, 0, 0 | tex (32, 2) o (3.1, -6, -8) s (0, 3, 16) |
| `head_parts/right_saddle_line` | 0, 0, 0 | -0.5235988, 0, 0 | tex (32, 2) o (-3.1, -6, -8) s (0, 3, 16) |
| `head_parts/head_saddle` | 0, 0, 0 | 0, 0, 0 | tex (1, 1) o (-3, -11, -1.9) s (6, 5, 6) grow 0.22 |
| `head_parts/mouth_saddle_wrap` | 0, 0, 0 | 0, 0, 0 | tex (19, 0) o (-2, -11, -4) s (4, 5, 2) grow 0.2 |

Layer `horse_baby` (also `skeleton_horse_baby`, `zombie_horse_baby`):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 12.5, 0 | 0, 0, 0 | tex (0, 13) o (-4, -3.5, -7) s (8, 7, 14) |
| `body/tail` | 0, -1, 7 | -0.7418, 0, 0 | tex (24, 34) o (-1.5, -1.5, -1) s (3, 3, 8) |
| `left_hind_leg` | 2.4, 16, 5.4 | 0, 0, 0 | tex (12, 46) o (-1.5, -1, -1.5) s (3, 9, 3) |
| `right_hind_leg` | -2.4, 16, 5.4 | 0, 0, 0 | tex (0, 46) o (-1.5, -1, -1.5) s (3, 9, 3) |
| `left_front_leg` | 2.4, 16, -5.4 | 0, 0, 0 | tex (12, 34) o (-1.5, -1, -1.5) s (3, 9, 3) |
| `right_front_leg` | -2.4, 16, -5.4 | 0, 0, 0 | tex (0, 34) o (-1.5, -1, -1.5) s (3, 9, 3) |
| `head_parts` | 0, 10, -6 | 0.6109, 0, 0 | tex (30, 0) o (-2, -6, -2) s (4, 8, 4) |
| `head_parts/head` | 0, -6.0516, -0.2951 | 0, 0, 0 | tex (0, 0) o (-3, -3.9484, -6.705) s (6, 4, 9) |
| `head_parts/head/left_ear` | 2, -4.2484, 1.9451 | 0, 0, 0.2618 | tex (0, 4) o (-1, -2.5, -0.8) s (2, 3, 1) |
| `head_parts/head/right_ear` | -2, -4.2484, 1.645 | 0, 0, -0.2618 | tex (0, 0) o (-1, -2.5, -0.5) s (2, 3, 1) |

Layer `donkey` (the horse mesh with the chest parts added and the ears replaced by longer ones; scaling 0.87; layer `mule` is identical with scaling 0.92):

Texture size 64 x 64. Scaling applied to the root in order 0.87: root pose offset (0, 3.1221, 0), scale 0.87.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 11, 5 | 0, 0, 0 | tex (0, 32) o (-5, -8, -17) s (10, 10, 22) grow 0.05 |
| `head_parts` | 0, 4, -12 | 0.5235988, 0, 0 | tex (0, 35) o (-2.05, -6, -2) s (4, 12, 7) |
| `head_parts/head` | 0, 0, 0 | 0, 0, 0 | tex (0, 13) o (-3, -11, -2) s (6, 5, 7) |
| `head_parts/mane` | 0, 0, 0 | 0, 0, 0 | tex (56, 36) o (-1, -11, 5.01) s (2, 16, 2) |
| `head_parts/upper_mouth` | 0, 0, 0 | 0, 0, 0 | tex (0, 25) o (-2, -11, -7) s (4, 5, 5) |
| `left_hind_leg` | 4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1) s (4, 11, 4) mirror |
| `right_hind_leg` | -4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1) s (4, 11, 4) |
| `left_front_leg` | 4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1.9) s (4, 11, 4) mirror |
| `right_front_leg` | -4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1.9) s (4, 11, 4) |
| `body/tail` | 0, -5, 2 | 0.5235988, 0, 0 | tex (42, 36) o (-1.5, 0, 0) s (3, 14, 4) |
| `head_parts/head/left_ear` | 1.25, -10, 4 | 0.2617994, 0, 0.2617994 | tex (0, 12) o (-1, -7, 0) s (2, 7, 1) |
| `head_parts/head/right_ear` | -1.25, -10, 4 | 0.2617994, 0, -0.2617994 | tex (0, 12) o (-1, -7, 0) s (2, 7, 1) |
| `body/left_chest` | 6, -8, 0 | 0, -1.5707964, 0 | tex (26, 21) o (-4, 0, -2) s (8, 8, 3) |
| `body/right_chest` | -6, -8, 0 | 0, 1.5707964, 0 | tex (26, 21) o (-4, 0, -2) s (8, 8, 3) |

Layer `donkey_saddle` (`mule_saddle` with scaling 0.92): the saddle mesh of `horse_saddle` with the same chest and ear changes:

Texture size 64 x 64. Scaling applied to the root in order 0.87: root pose offset (0, 3.1221, 0), scale 0.87.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 11, 5 | 0, 0, 0 | tex (0, 32) o (-5, -8, -17) s (10, 10, 22) grow 0.05 |
| `head_parts` | 0, 4, -12 | 0.5235988, 0, 0 | tex (0, 35) o (-2.05, -6, -2) s (4, 12, 7) |
| `head_parts/head` | 0, 0, 0 | 0, 0, 0 | tex (0, 13) o (-3, -11, -2) s (6, 5, 7) |
| `head_parts/mane` | 0, 0, 0 | 0, 0, 0 | tex (56, 36) o (-1, -11, 5.01) s (2, 16, 2) |
| `head_parts/upper_mouth` | 0, 0, 0 | 0, 0, 0 | tex (0, 25) o (-2, -11, -7) s (4, 5, 5) |
| `left_hind_leg` | 4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1) s (4, 11, 4) mirror |
| `right_hind_leg` | -4, 14, 7 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1) s (4, 11, 4) |
| `left_front_leg` | 4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-3, -1.01, -1.9) s (4, 11, 4) mirror |
| `right_front_leg` | -4, 14, -10 | 0, 0, 0 | tex (48, 21) o (-1, -1.01, -1.9) s (4, 11, 4) |
| `body/tail` | 0, -5, 2 | 0.5235988, 0, 0 | tex (42, 36) o (-1.5, 0, 0) s (3, 14, 4) |
| `head_parts/head/left_ear` | 1.25, -10, 4 | 0.2617994, 0, 0.2617994 | tex (0, 12) o (-1, -7, 0) s (2, 7, 1) |
| `head_parts/head/right_ear` | -1.25, -10, 4 | 0.2617994, 0, -0.2617994 | tex (0, 12) o (-1, -7, 0) s (2, 7, 1) |
| `body/saddle` | 0, 0, 0 | 0, 0, 0 | tex (26, 0) o (-5, -8, -9) s (10, 9, 9) grow 0.5 |
| `head_parts/left_saddle_mouth` | 0, 0, 0 | 0, 0, 0 | tex (29, 5) o (2, -9, -6) s (1, 2, 2) |
| `head_parts/right_saddle_mouth` | 0, 0, 0 | 0, 0, 0 | tex (29, 5) o (-3, -9, -6) s (1, 2, 2) |
| `head_parts/left_saddle_line` | 0, 0, 0 | -0.5235988, 0, 0 | tex (32, 2) o (3.1, -6, -8) s (0, 3, 16) |
| `head_parts/right_saddle_line` | 0, 0, 0 | -0.5235988, 0, 0 | tex (32, 2) o (-3.1, -6, -8) s (0, 3, 16) |
| `head_parts/head_saddle` | 0, 0, 0 | 0, 0, 0 | tex (1, 1) o (-3, -11, -1.9) s (6, 5, 6) grow 0.22 |
| `head_parts/mouth_saddle_wrap` | 0, 0, 0 | 0, 0, 0 | tex (19, 0) o (-2, -11, -4) s (4, 5, 2) grow 0.2 |
| `body/left_chest` | 6, -8, 0 | 0, -1.5707964, 0 | tex (26, 21) o (-4, 0, -2) s (8, 8, 3) |
| `body/right_chest` | -6, -8, 0 | 0, 1.5707964, 0 | tex (26, 21) o (-4, 0, -2) s (8, 8, 3) |

Layer `donkey_baby` (also used for the mule: `mule_baby` is the same builder; no scaling; the legs and `head_parts` are children of `body`; the two chest parts carry no cuboids):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 1, 14, 0 | 0, 0, 0 | tex (0, 13) o (-5, -3, -7) s (8, 6, 14) |
| `body/tail` | 0, -1.5, 6.5 | 0, 0, 0 | (none) |
| `body/tail/tail_r1` | 0, 0, 0 | -0.7418, 0, 0 | tex (24, 33) o (-2.5, -1, -0.5) s (3, 3, 8) |
| `body/left_hind_leg` | 2.25, 3.5, 5.25 | 0, 0, 0 | tex (12, 44) o (-2.5, -1.5, -1.5) s (3, 8, 3) |
| `body/right_hind_leg` | -2.4, 3.5, 5.4 | 0, 0, 0 | tex (0, 44) o (-2.5, -1.5, -1.5) s (3, 8, 3) |
| `body/left_front_leg` | 2.4, 3.5, -5.3 | 0, 0, 0 | tex (12, 33) o (-2.5, -1.5, -1.5) s (3, 8, 3) |
| `body/right_front_leg` | -2.4, 3.5, -5.4 | 0, 0, 0 | tex (0, 33) o (-2.5, -1.5, -1.5) s (3, 8, 3) |
| `body/head_parts` | 0, -3, -5 | 0, 0, 0 | (none) |
| `body/head_parts/neck_r1` | 0, 0, 0 | 0.3927, 0, 0 | tex (30, 9) o (-3, -6, -3) s (4, 8, 4) |
| `body/head_parts/head` | 0, -5, -3 | 0, 0, 0 | (none) |
| `body/head_parts/head/head_r1` | 0, -1, 1 | 0.3927, 0, 0 | tex (0, 0) o (-4, -3.6, -8.4) s (6, 4, 9) |
| `body/head_parts/head/left_ear` | 2, -3.5, -1 | 0.48, 0, 0.48 | tex (0, 0) o (-2, -6.5, -0.3) s (2, 7, 1) |
| `body/head_parts/head/right_ear` | -2, -3.5, -1 | 0.48, 0, -0.48 | tex (22, 0) o (-2, -6.5, -0.3) s (2, 7, 1) mirror |
| `body/right_chest` | -1, 10, 0 | 0, 0, 0 | (none) |
| `body/left_chest` | -1, 10, 0 | 0, 0, 0 | (none) |

---

## 9. Llama and trader llama

### 9.1 Renderer (`LlamaRenderer`, `LlamaRenderState`)

- `LlamaRenderer(context, adultLayer, babyLayer)`: extends `AgeableMobRenderer`; shadow 0.7; models `LlamaModel` and `BabyLlamaModel` (extends `LlamaModel`). The llama is built with layers `llama` / `llama_baby`, the trader llama with `trader_llama` / `trader_llama_baby` (same geometry). One layer: `LlamaDecorLayer`.
- State: `variant` (`Llama$Variant`), `hasChest`, `bodyItem` (`ItemStack`), `isTraderLlama`. Extraction: `variant = getVariant()`; `hasChest = hasChest() and not isBaby()` (a baby never shows chests); `bodyItem = getBodyArmorItem()`; `isTraderLlama`.
- Variants (ordinal = id, name): CREAMY 0 `creamy`, WHITE 1 `white`, BROWN 2 `brown`, GRAY 3 `gray` (default CREAMY, id map clamps). Textures (`textures/entity/llama/`): adult `llama_creamy.png`, `llama_white.png`, `llama_brown.png`, `llama_gray.png`; baby the same names with `_baby` appended.

### 9.2 `setupAnim`

`LlamaModel` does **not** extend `QuadrupedModel`; it bakes `head`, `right_chest`, `left_chest` and the four legs and writes: `head.xRot = state.xRot x D`, `head.yRot = state.yRot x D`, the four leg swings exactly as part 1 §3.4 (hind legs and front legs, amplitude 1.4, phase 0.6662), then `right_chest.visible = left_chest.visible = state.hasChest`. The baby model inherits all of this (it also bakes the two chest parts).

### 9.3 `LlamaDecorLayer`

Two models baked from layers `llama_decor` (adult, grow 0.5 on every cuboid) and `llama_baby_decor` (baby, grow 0.2). Algorithm: let `item = state.bodyItem`.

1. If `item` has an `EQUIPPABLE` component with a present asset id **and the llama is not a baby**: draw that asset with layer type `llama_body` (the carpet).
2. Else, if the llama is a trader llama: draw the equipment asset resource key `trader_llama_baby` (when baby) or `trader_llama` (when adult) with layer type `llama_body` and an empty item stack (the trader's blue carpet, with no dye, trim or glint).
3. Else nothing.

So a baby llama never shows a player-put carpet; a baby trader llama still shows the trader carpet. The draw is `equipmentRenderer.renderLayers(llama_body, assetKey, model, state, item, ...)` with model = the adult decor model or, for babies, the baby decor model.

### 9.4 Geometry

Layer `llama` (texture 128 x 64; `trader_llama` identical):

Texture size 128 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 7, -6 | 0, 0, 0 | tex (0, 0) o (-2, -14, -10) s (4, 4, 9)<br>tex (0, 14) o (-4, -16, -6) s (8, 18, 6) [neck]<br>tex (17, 0) o (-4, -19, -4) s (3, 3, 2) [ear]<br>tex (17, 0) o (1, -19, -4) s (3, 3, 2) [ear] |
| `body` | 0, 5, 2 | 1.5707964, 0, 0 | tex (29, 0) o (-6, -10, -7) s (12, 18, 10) |
| `right_chest` | -8.5, 3, 3 | 0, 1.5707964, 0 | tex (45, 28) o (-3, 0, 0) s (8, 8, 3) |
| `left_chest` | 5.5, 3, 3 | 0, 1.5707964, 0 | tex (45, 41) o (-3, 0, 0) s (8, 8, 3) |
| `right_hind_leg` | -3.5, 10, 6 | 0, 0, 0 | tex (29, 29) o (-2, 0, -2) s (4, 14, 4) |
| `left_hind_leg` | 3.5, 10, 6 | 0, 0, 0 | tex (29, 29) o (-2, 0, -2) s (4, 14, 4) |
| `right_front_leg` | -3.5, 10, -5 | 0, 0, 0 | tex (29, 29) o (-2, 0, -2) s (4, 14, 4) |
| `left_front_leg` | 3.5, 10, -5 | 0, 0, 0 | tex (29, 29) o (-2, 0, -2) s (4, 14, 4) |

Layer `llama_decor` is the same parts with `grow 0.5` on every cuboid (`neck` and `ear` names included); layer `llama_baby_decor` is the baby parts with `grow 0.2`. Layer `llama_baby` (texture 64 x 64):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `head` | 0, 12, -4 | 0, 0, 0 | tex (0, 0) o (-3, -9, -4) s (6, 11, 4)<br>tex (0, 15) o (-1.5, -7, -7) s (3, 3, 3)<br>tex (20, 4) o (0.5, -11, -3) s (2, 2, 2)<br>tex (20, 0) o (-2.5, -11, -3) s (2, 2, 2) |
| `right_hind_leg` | -2.5, 16.5, 4.5 | 0, 0, 0 | tex (0, 45) o (-1.4, -0.5, -1.5) s (3, 8, 3) |
| `left_hind_leg` | 2.5, 16.5, 4.5 | 0, 0, 0 | tex (12, 45) o (-1.6, -0.5, -1.5) s (3, 8, 3) |
| `right_front_leg` | -2.5, 16.5, -3.5 | 0, 0, 0 | tex (0, 34) o (-1.4, -0.5, -1.5) s (3, 8, 3) |
| `left_front_leg` | 2.5, 16.5, -3.5 | 0, 0, 0 | tex (12, 34) o (-1.6, -0.5, -1.5) s (3, 8, 3) |
| `body` | 0, 14, 2.5 | 0, 0, 0 | tex (0, 15) o (-4, -3, -8.5) s (8, 6, 13) |
| `right_chest` | -8.5, 4, 3 | 0, 1.5707964, 0 | tex (45, 28) o (-3, 0, 0) s (8, 8, 3) |
| `left_chest` | 5.5, 4, 3 | 0, 1.5707964, 0 | tex (45, 41) o (-3, 0, 0) s (8, 8, 3) |

### 9.5 Llama spit (`LlamaSpitRenderer`, `LlamaSpitModel`, `LlamaSpitRenderState`)

- State adds `yRot` and `xRot` (degrees): extraction `xRot = entity.getXRot(partial)`, `yRot = entity.getYRot(partial)`.
- Submit: push; translate (0, 0.15, 0); rotate about Y by `yRot - 90` deg; rotate about Z by `xRot` deg; submit the model with the texture `textures/entity/llama/llama_spit.png`, the state's light, no overlay, the outline colour (render type: the model's default, `entityCutout`); pop; then the base entity submit. There is no living-entity flip `(-1, -1, 1)`, no `translate(0, -1.501, 0)` and no scale in this pose chain, so model +y is world up and the pivot is the projectile position raised 0.15 block (inferred from the absence of those operations, Open question 15; the operations themselves were read).
- The model `LlamaSpitModel` (texture 64 x 32) has one part `main` with seven 2 x 2 x 2 cuboids all at texture offset (0, 0): a small cross of cubes. It has no `setupAnim` behaviour.

Texture size 64 x 32.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `main` | 0, 0, 0 | 0, 0, 0 | tex (0, 0) o (-4, 0, 0) s (2, 2, 2)<br>tex (0, 0) o (0, -4, 0) s (2, 2, 2)<br>tex (0, 0) o (0, 0, -4) s (2, 2, 2)<br>tex (0, 0) o (0, 0, 0) s (2, 2, 2)<br>tex (0, 0) o (2, 0, 0) s (2, 2, 2)<br>tex (0, 0) o (0, 2, 0) s (2, 2, 2)<br>tex (0, 0) o (0, 0, 2) s (2, 2, 2) |

---

## 10. Camel and camel husk

### 10.1 Renderers (`CamelRenderer`, `CamelHuskRenderer`, `CamelRenderState`)

- `CamelRenderer` extends `AgeableMobRenderer`; shadow 0.7; adult model `AdultCamelModel` (layer `camel`), baby `BabyCamelModel` (layer `camel_baby`), both extending the abstract `CamelModel`. One layer: a `SimpleEquipmentLayer` built by `createCamelSaddleLayer(context, parent, layerType, modelLayer)`: item getter `state.saddle`, adult model `CamelSaddleModel` baked from the given layer, baby model null, order 0; for the camel `(camel_saddle, camel_saddle)`.
- `CamelHuskRenderer`: the same state and extraction (`extractAdditionalState`) but a single adult model `AdultCamelModel` (layer `camel`), shadow 0.7, the saddle layer with `(camel_husk_saddle, camel_husk_saddle)`, and the constant texture `textures/entity/camel/camel_husk.png`. It has no baby model (a baby husk would use the adult model: not reachable, since `isBaby` selects only in `AgeableMobRenderer`).
- Texture of the camel: `textures/entity/camel/camel.png`, baby `camel_baby.png`.
- State: `saddle`, `isRidden`, `jumpCooldown`, and five `AnimationState` objects `sitAnimationState`, `sitPoseAnimationState`, `sitUpAnimationState`, `idleAnimationState`, `dashAnimationState` (copied each frame from the entity's states with `copyFrom`; `AnimationState` rules in part 1 §5.5). Extraction: `saddle` = copy of the `SADDLE` slot item, `isRidden = isVehicle()`, `jumpCooldown = max(entity.getJumpCooldown() - partial, 0)` (ticks).

### 10.2 `setupAnim` (`CamelModel`, inherited by the adult, baby and saddle models)

Bake: `body`, `head` (a child of `body`, path `body/head`), and the six animations baked from the definitions of the model's subclass: `AdultCamelModel` (and `CamelSaddleModel`, which extends it) uses `CamelAnimation.CAMEL_WALK`, `CAMEL_SIT`, `CAMEL_SIT_POSE`, `CAMEL_STANDUP`, `CAMEL_IDLE`, `CAMEL_DASH`; `BabyCamelModel` uses `CamelBabyAnimation.CAMEL_BABY_WALK`, `_SIT`, `_SIT_POSE`, `_STANDUP`, `_IDLE`, `_DASH` (Appendix A). In order:

1. `applyHeadRotation(state, yaw, pitch)`: `yaw` = clamp(`state.yRot`, -30, 30), `pitch` = clamp(`state.xRot`, -25, 45) (degrees); when `jumpCooldown > 0`, `pitch` = clamp(`pitch + 45 x jumpCooldown / 55`, -25, 70); `head.yRot = yaw x D`, `head.xRot = pitch x D`.
2. Walk animation: `applyWalk(walkAnimationPos, walkAnimationSpeed, 2, 2.5)`.
3. In this order, each `apply(state, ageInTicks)` (only when that `AnimationState` is started): sit, sit pose, stand up, idle, dash.

Keyframe values are added to the pose (part 3 §0.2: additive; position y is negated by the engine when sampled; the tables of Appendix A print the arguments as written). The saddle model additionally sets `head/reins.visible = isRidden`; bridle, saddle and the other cuboids are always visible.

### 10.3 Geometry

Layer `camel` (texture 128 x 128; the husk uses it too):

Texture size 128 x 128.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 4, 9.5 | 0, 0, 0 | tex (0, 25) o (-7.5, -12, -23.5) s (15, 12, 27) |
| `body/hump` | 0, -12, -10 | 0, 0, 0 | tex (74, 0) o (-4.5, -5, -5.5) s (9, 5, 11) |
| `body/tail` | 0, -9, 3.5 | 0, 0, 0 | tex (122, 0) o (-1.5, 0, 0) s (3, 14, 0) |
| `body/head` | 0, -3, -19.5 | 0, 0, 0 | tex (60, 24) o (-3.5, -7, -15) s (7, 8, 19)<br>tex (21, 0) o (-3.5, -21, -15) s (7, 14, 7)<br>tex (50, 0) o (-2.5, -21, -21) s (5, 5, 6) |
| `body/head/left_ear` | 2.5, -21, -9.5 | 0, 0, 0 | tex (45, 0) o (-0.5, 0.5, -1) s (3, 1, 2) |
| `body/head/right_ear` | -2.5, -21, -9.5 | 0, 0, 0 | tex (67, 0) o (-2.5, 0.5, -1) s (3, 1, 2) |
| `left_hind_leg` | 4.9, 1, 9.5 | 0, 0, 0 | tex (58, 16) o (-2.5, 2, -2.5) s (5, 21, 5) |
| `right_hind_leg` | -4.9, 1, 9.5 | 0, 0, 0 | tex (94, 16) o (-2.5, 2, -2.5) s (5, 21, 5) |
| `left_front_leg` | 4.9, 1, -10.5 | 0, 0, 0 | tex (0, 0) o (-2.5, 2, -2.5) s (5, 21, 5) |
| `right_front_leg` | -4.9, 1, -10.5 | 0, 0, 0 | tex (0, 26) o (-2.5, 2, -2.5) s (5, 21, 5) |

Layer `camel_baby` (texture 64 x 64; note the legs are parts of the root here too, ears are added as `body/head` children):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 7, 0 | 0, 0, 0 | tex (0, 14) o (-4.5, -4, -8) s (9, 8, 16) |
| `body/tail` | 0, -1.5, 8.05 | 0, 0, 0 | tex (50, 38) o (-1.5, -0.5, 0) s (3, 9, 0) |
| `body/head` | 0, 1, -7.5 | 0, 0, 0 | tex (20, 0) o (-2.5, -3, -7.5) s (5, 5, 7)<br>tex (0, 0) o (-2.5, -12, -7.5) s (5, 9, 5)<br>tex (0, 14) o (-2.5, -12, -10.5) s (5, 4, 3) |
| `body/head/right_ear` | -2.5, -11, -4 | 0, 0, 0 | tex (37, 0) o (-3, -0.5, -1) s (3, 1, 2) |
| `body/head/left_ear` | 2.5, -11, -4 | 0, 0, 0 | tex (47, 0) o (0, -0.5, -1) s (3, 1, 2) |
| `right_front_leg` | -3, 11.5, -5.5 | 0, 0, 0 | tex (36, 14) o (-1.5, -0.5, -1.5) s (3, 13, 3) |
| `left_front_leg` | 3, 11.5, -5.5 | 0, 0, 0 | tex (48, 14) o (-1.5, -0.5, -1.5) s (3, 13, 3) |
| `left_hind_leg` | 3, 11.5, 5.5 | 0, 0, 0 | tex (12, 38) o (-1.5, -0.5, -1.5) s (3, 13, 3) |
| `right_hind_leg` | -3, 11.5, 5.5 | 0, 0, 0 | tex (0, 38) o (-1.5, -0.5, -1.5) s (3, 13, 3) |

Layer `camel_saddle` (also `camel_husk_saddle`): the adult camel mesh and animations, plus the saddle (`body/saddle`), reins (`body/head/reins`) and bridle (`body/head/bridle`) parts; grown cuboids use 0.05:

Texture size 128 x 128.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 4, 9.5 | 0, 0, 0 | tex (0, 25) o (-7.5, -12, -23.5) s (15, 12, 27) |
| `body/hump` | 0, -12, -10 | 0, 0, 0 | tex (74, 0) o (-4.5, -5, -5.5) s (9, 5, 11) |
| `body/tail` | 0, -9, 3.5 | 0, 0, 0 | tex (122, 0) o (-1.5, 0, 0) s (3, 14, 0) |
| `body/head` | 0, -3, -19.5 | 0, 0, 0 | tex (60, 24) o (-3.5, -7, -15) s (7, 8, 19)<br>tex (21, 0) o (-3.5, -21, -15) s (7, 14, 7)<br>tex (50, 0) o (-2.5, -21, -21) s (5, 5, 6) |
| `body/head/left_ear` | 2.5, -21, -9.5 | 0, 0, 0 | tex (45, 0) o (-0.5, 0.5, -1) s (3, 1, 2) |
| `body/head/right_ear` | -2.5, -21, -9.5 | 0, 0, 0 | tex (67, 0) o (-2.5, 0.5, -1) s (3, 1, 2) |
| `left_hind_leg` | 4.9, 1, 9.5 | 0, 0, 0 | tex (58, 16) o (-2.5, 2, -2.5) s (5, 21, 5) |
| `right_hind_leg` | -4.9, 1, 9.5 | 0, 0, 0 | tex (94, 16) o (-2.5, 2, -2.5) s (5, 21, 5) |
| `left_front_leg` | 4.9, 1, -10.5 | 0, 0, 0 | tex (0, 0) o (-2.5, 2, -2.5) s (5, 21, 5) |
| `right_front_leg` | -4.9, 1, -10.5 | 0, 0, 0 | tex (0, 26) o (-2.5, 2, -2.5) s (5, 21, 5) |
| `body/saddle` | 0, 0, 0 | 0, 0, 0 | tex (74, 64) o (-4.5, -17, -15.5) s (9, 5, 11) grow 0.05<br>tex (92, 114) o (-3.5, -20, -15.5) s (7, 3, 11) grow 0.05<br>tex (0, 89) o (-7.5, -12, -23.5) s (15, 12, 27) grow 0.05 |
| `body/head/reins` | 0, 0, 0 | 0, 0, 0 | tex (98, 42) o (3.51, -18, -17) s (0, 7, 15)<br>tex (84, 57) o (-3.5, -18, -2) s (7, 7, 0)<br>tex (98, 42) o (-3.51, -18, -17) s (0, 7, 15) |
| `body/head/bridle` | 0, 0, 0 | 0, 0, 0 | tex (60, 87) o (-3.5, -7, -15) s (7, 8, 19) grow 0.05<br>tex (21, 64) o (-3.5, -21, -15) s (7, 14, 7) grow 0.05<br>tex (50, 64) o (-2.5, -21, -21) s (5, 5, 6) grow 0.05<br>tex (74, 70) o (2.5, -19, -18) s (1, 2, 2)<br>tex (74, 70) o (-3.5, -19, -18) s (1, 2, 2) mirror |

---

## 11. Happy ghast

### 11.1 Renderer (`HappyGhastRenderer`, `HappyGhastRenderState`, `RopesLayer`)

- Extends `AgeableMobRenderer`; base shadow 2; adult model `HappyGhastModel` from layer `happy_ghast`, baby from `happy_ghast_baby`. Textures: `textures/entity/ghast/happy_ghast.png`, baby `textures/entity/ghast/happy_ghast_baby.png`. Culling box: the entity's bounding box for culling with its minimum y lowered by half the entity height (`getBoundingBoxForCulling`).
- State: `bodyItem` (copy of the `BODY` slot item), `isRidden = isVehicle()`, `isLeashHolder = isLeashHolder()`.
- Layers in order: (1) a `SimpleEquipmentLayer` of layer type `happy_ghast_body`, item getter `bodyItem`, adult model `HappyGhastHarnessModel` (layer `happy_ghast_harness`), baby model `HappyGhastHarnessModel` (layer `happy_ghast_baby_harness`), order 0; (2) `RopesLayer` with texture `textures/entity/ghast/happy_ghast_ropes.png`.
- `RopesLayer`: draws only when the state is a leash holder **and** `bodyItem` is in the item tag `harnesses`. It bakes `HappyGhastModel` from layers `happy_ghast_ropes` (adult) and `happy_ghast_baby_ropes` (baby) (the body mesh with every cuboid grown by 0.2), and submits the model (adult or baby by `isBaby`) with that texture, the entity's light, no overlay and the outline colour (model default render type).

### 11.2 `setupAnim`

`HappyGhastModel`: bakes `body` and the nine tentacles `body/tentacle0` .. `body/tentacle8` (names `tentacle` + index). If `bodyItem` is **not** empty (a harness is worn): `body.xScale = body.yScale = body.zScale = 0.9375` (so the body, with its children, shrinks to 15/16 of its size). Then the shared ghast tentacle animation (`GhastModel.animateTentacles`): for each tentacle index `i` from 0 to 8, `tentacle_i.xRot = 0.2 x sin(ageInTicks x 0.3 + i) + 0.4`.

`HappyGhastHarnessModel`: bakes `harness` and `goggles`. If `isRidden`: `goggles.xRot = 0`, `goggles.y = 14`; else `goggles.xRot = -0.7854` (-45 deg) and `goggles.y = 9` (the goggles are pushed up the forehead when nobody rides).

### 11.3 Geometry

All happy ghast layers pass through scaling (section 0.1): the adult layers are scaled by 4 (root offset (0, -72.048, 0), scale 4); the baby layers additionally by 0.2375 (`HappyGhastModel.BABY_TRANSFORMER`, a static `MeshTransformer.scaling(0.2375)`), the root becoming offset (0, 1.2008, 0), scale 0.95. A baby model has an extra `inner_body` part (the builder takes a baby flag). The ropes layers use deformation 0.2 on every cuboid. Root scaling of the ropes layers (read in `LayerDefinitions`): `happy_ghast_ropes` is the body builder with flag false and deformation 0.2, which applies scaling 4 inside the builder, so root offset (0, -72.048, 0), scale 4; `happy_ghast_baby_ropes` is the body builder with flag true and deformation 0.2, followed by `BABY_TRANSFORMER` once, so root offset (0, 1.2008, 0), scale 0.95, the same as `happy_ghast_baby` (not the double transform of the baby harness).

Layer `happy_ghast`:

Texture size 64 x 64. Scaling applied to the root in order 4: root pose offset (0, -72.048, 0), scale 4.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 16, 0 | 0, 0, 0 | tex (0, 0) o (-8, -8, -8) s (16, 16, 16) |
| `body/tentacle0` | -3.75, 7, -5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 5, 2) |
| `body/tentacle1` | 1.25, 7, -5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 7, 2) |
| `body/tentacle2` | 6.25, 7, -5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 4, 2) |
| `body/tentacle3` | -6.25, 7, 0 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 5, 2) |
| `body/tentacle4` | -1.25, 7, 0 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 5, 2) |
| `body/tentacle5` | 3.75, 7, 0 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 7, 2) |
| `body/tentacle6` | -3.75, 7, 5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 8, 2) |
| `body/tentacle7` | 1.25, 7, 5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 8, 2) |
| `body/tentacle8` | 6.25, 7, 5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 5, 2) |

Layer `happy_ghast_baby` (adds `body/inner_body`):

Texture size 64 x 64. Scaling applied to the root in order 4, 0.2375: root pose offset (0, 1.2008, 0), scale 0.95.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 16, 0 | 0, 0, 0 | tex (0, 0) o (-8, -8, -8) s (16, 16, 16) |
| `body/inner_body` | 0, 8, 0 | 0, 0, 0 | tex (0, 32) o (-8, -16, -8) s (16, 16, 16) grow -0.5 |
| `body/tentacle0` | -3.75, 7, -5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 5, 2) |
| `body/tentacle1` | 1.25, 7, -5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 7, 2) |
| `body/tentacle2` | 6.25, 7, -5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 4, 2) |
| `body/tentacle3` | -6.25, 7, 0 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 5, 2) |
| `body/tentacle4` | -1.25, 7, 0 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 5, 2) |
| `body/tentacle5` | 3.75, 7, 0 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 7, 2) |
| `body/tentacle6` | -3.75, 7, 5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 8, 2) |
| `body/tentacle7` | 1.25, 7, 5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 8, 2) |
| `body/tentacle8` | 6.25, 7, 5 | 0, 0, 0 | tex (0, 0) o (-1, 0, -1) s (2, 5, 2) |

Layer `happy_ghast_harness` (`createHarnessLayer(false)` then scaling 4):

Texture size 64 x 64. Scaling applied to the root in order 4: root pose offset (0, -72.048, 0), scale 4.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `harness` | 0, 24, 0 | 0, 0, 0 | tex (0, 0) o (-8, -16, -8) s (16, 16, 16) |
| `goggles` | 0, 14, -5.5 | 0, 0, 0 | tex (0, 32) o (-8, -2.5, -2.5) s (16, 5, 5) grow 0.15 |

Layer `happy_ghast_baby_harness`: the same two parts; the transformer list is 4 (inside the builder), 0.2375 (inside the builder, because its flag is true) and 0.2375 again (the registry applies `BABY_TRANSFORMER` to it a second time), so the root ends offset (0, 18.5974, 0), scale 0.225625 (the product 4 x 0.2375 x 0.2375). The baby ghast cannot wear a harness in play, so this is not visible in normal play (see Open question 2).

Texture size 64 x 64. Scaling applied to the root in order 4, 0.2375, 0.2375: root pose offset (0, 18.5974, 0), scale 0.225625.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `harness` | 0, 24, 0 | 0, 0, 0 | tex (0, 0) o (-8, -16, -8) s (16, 16, 16) |
| `goggles` | 0, 14, -5.5 | 0, 0, 0 | tex (0, 32) o (-8, -2.5, -2.5) s (16, 5, 5) grow 0.15 |

Layers `happy_ghast_ropes` and `happy_ghast_baby_ropes` have the part tree of `happy_ghast` and `happy_ghast_baby` with `grow 0.2` on every cuboid (and `grow -0.3` on `inner_body`: the baby `inner_body` is built with the deformation reduced by 0.5, so 0.2 - 0.5).

---

## 12. Rabbit

### 12.1 Renderer (`RabbitRenderer`, `RabbitRenderState`)

- Extends `AgeableMobRenderer`; shadow 0.3; adult `AdultRabbitModel` (layer `rabbit`), baby `BabyRabbitModel` (layer `rabbit_baby`), both extending `RabbitModel`. No layers.
- State: `jumpCompletion` (copied from `entity.getJumpCompletion(partial)`; no model code read here uses it), `isToast` (the custom name string equals the text `Toast`), `variant` (`Rabbit$Variant`), and the animation states `hopAnimationState`, `idleHeadTiltAnimationState` (copied with `copyFrom`).
- Texture: when `isToast`: `textures/entity/rabbit/rabbit_toast_baby.png` for a baby, `rabbit_toast.png` for an adult; else the variant table below, baby or adult (directory `textures/entity/rabbit/`).

### 12.2 `setupAnim` (`RabbitModel`)

Bake: `body`, `head` (child of `body`), plus two animations from `RabbitAnimation` (adult: `HOP`, `IDLE_HEAD_TILT`) or `BabyRabbitAnimation` (baby: `HOP`, `IDLE_HEAD_TILT`). In order: (1) when the idle head tilt animation state is **not** started: `head.yRot = state.yRot x D`, `head.xRot = state.xRot x D` (while the tilt plays the head is left to the animation); (2) `hopAnimation.apply(hopAnimationState, ageInTicks)`; (3) `idleHeadTiltAnimation.apply(idleHeadTiltAnimationState, ageInTicks)` (both only when started). Legs, ears, tail and haunches are moved by these keyframes only (Appendix A).

### 12.3 Variants

`Rabbit$Variant` (ordinal, id, name): BROWN 0 id 0 `brown`; WHITE 1 id 1 `white`; BLACK 2 id 2 `black`; WHITE_SPLOTCHED 3 id 3 `white_splotched`; GOLD 4 id 4 `gold`; SALT 5 id 5 `salt`; EVIL 6 id **99** `evil` (default BROWN; the id map is sparse: unknown ids give BROWN). Textures: BROWN `rabbit_brown.png`; WHITE `rabbit_white.png`; BLACK `rabbit_black.png`; WHITE_SPLOTCHED `rabbit_white_splotched.png`; GOLD `rabbit_gold.png`; SALT `rabbit_salt.png`; EVIL `rabbit_caerbannog.png`; the baby of each is the same name with `_baby` before `.png` (for EVIL `rabbit_caerbannog_baby.png`).

### 12.4 Geometry

Layer `rabbit` (texture 64 x 64; the root of the haunch chain is `backlegs`, a top-level part):

Texture size 64 x 64.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 23, 4 | -0.3927, 0, 0 | tex (0, 0) o (-4, -6, -9) s (8, 6, 10) |
| `body/tail` | 0, -4.9916, 0.0125 | 0, 0, 0 | tex (20, 16) o (-2, -3.0084, -1.0125) s (4, 4, 4) |
| `body/head` | 0, -5.2929, -8.1213 | 0.3927, 0, 0 | tex (0, 16) o (-2.5, -3, -4) s (5, 5, 5) |
| `body/head/left_ear` | 1.5, -3.7071, -0.8787 | 0, 0, 0 | tex (32, 0) o (-1, -4.2929, -0.1213) s (2, 5, 1) |
| `body/head/right_ear` | -1.5, -3.7071, -0.8787 | 0, 0, 0 | tex (26, 0) o (-1, -4.2929, -0.1213) s (2, 5, 1) |
| `body/frontlegs` | 0, -1.5349, -6.3108 | 0, 0, 0 | (none) |
| `body/frontlegs/right_front_leg` | -2, 1.9239, 0.3827 | 0.3927, 0, 0 | tex (36, 18) o (-0.9, -1, -0.9) s (2, 4, 2) |
| `body/frontlegs/left_front_leg` | 2, 1.9239, 0.4827 | 0.3927, 0, 0 | tex (44, 18) o (-1, -1, -1) s (2, 4, 2) |
| `backlegs` | 0, 23, 4 | 0, 0, 0 | (none) |
| `backlegs/right_hind_leg` | -3, 0.5, 0 | 0, 0, 0 | (none) |
| `backlegs/right_hind_leg/right_haunch` | 0, -0.5, 0 | 0, 0.3927, 0 | tex (20, 24) o (-1, 0, -5) s (2, 1, 6) |
| `backlegs/left_hind_leg` | 3, 0.5, 0 | 0, 0, 0 | (none) |
| `backlegs/left_hind_leg/left_haunch` | 0, -0.5, 0 | 0, -0.3927, 0 | tex (36, 24) o (-1, 0, -5) s (2, 1, 6) |

Layer `rabbit_baby` (texture 32 x 32; `_r1` parts are rotation holders):

Texture size 32 x 32.

| Part path | Pivot (x, y, z) | Rotation (x, y, z) | Cuboids |
|---|---|---|---|
| `body` | 0, 23, 1.6 | 0, 0, 0 | (none) |
| `body/body_r1` | 0, -2, -1.6 | -0.5236, 0, 0 | tex (0, 8) o (-2, -2, -3) s (4, 3, 6) |
| `body/tail` | 0, -2.2, 2 | 0, 0, 0 | (none) |
| `body/tail/tail_r1` | -0.1, 0, 0 | -0.5236, 0, 0 | tex (0, 21) o (-1.4, -2.0268, -1.0177) s (3, 3, 3) |
| `body/head` | 0, -5, -2.6 | 0, 0, 0 | tex (0, 0) o (-2.5, -3, -3) s (5, 4, 4) |
| `body/head/right_ear` | -1.5, -3.5, -0.5 | 0, 0, 0 | tex (18, 0) o (-1, -3.5, -0.5) s (2, 4, 1) |
| `body/head/left_ear` | 1.5, -3.5, -0.5 | 0, 0, 0 | tex (24, 0) o (-1, -3.5, -0.5) s (2, 4, 1) |
| `body/frontlegs` | 0, -2.5, -2.6 | 0, 0, 0 | (none) |
| `body/frontlegs/left_front_leg` | 1, 1, -0.5 | 0.3927, 0, 0 | (none) |
| `body/frontlegs/left_front_leg/left_front_leg_r1` | 0, 1, 0 | -0.3927, 0, 0 | tex (18, 8) o (-0.5, -1.5, -0.5) s (1, 3, 1) |
| `body/frontlegs/right_front_leg` | -1, 1, -0.5 | 0.3927, 0, 0 | (none) |
| `body/frontlegs/right_front_leg/right_front_leg_r1` | 0, 1, 0 | -0.3927, 0, 0 | tex (14, 8) o (-0.5, -1.5, -0.5) s (1, 3, 1) |
| `backlegs` | 0, 23, 2 | 0, 0, 0 | (none) |
| `backlegs/left_hind_leg` | 1.5, 0.5, 0.5 | 0, 3.1416, 0 | (none) |
| `backlegs/left_hind_leg/left_haunch` | 1, 0, 0.5 | 0, -0.7854, 0 | tex (10, 17) o (-2, -0.5, 0) s (2, 1, 3) |
| `backlegs/right_hind_leg` | -1.5, 0.5, 0.5 | 0, 3.1416, 0 | (none) |
| `backlegs/right_hind_leg/right_haunch` | 0.5, 0, -0.9 | 0, 0.7854, 0 | tex (0, 17) o (-2, -0.5, 0) s (2, 1, 3) |

---

## Appendix A. Keyframe data (code-defined)

Time in seconds; a keyframe is `time:(x, y, z)`; rotation channels are degrees, position channels pixels (the engine negates y, part 3 §0.2), scale channels are scale factors (the engine stores factor - 1). `~` after a keyframe marks `CATMULLROM`, unmarked keyframes are `LINEAR`. Every keyframe has equal pre and post vectors (the constructor takes one vector). Sampling, application and the walk-driven rule: part 1 §5 and part 3 §0.2. The tables were generated from the static initializers of the four definition classes; floats are printed to five significant digits. A line "length 0 s, looping" is an animation whose length constant is 0 (see Open question 6).

### A.1 `CamelAnimation` (used by `AdultCamelModel`, `CamelSaddleModel`)

#### CAMEL_WALK  length 1.5 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| root | ROTATION | 0:(0, 0, 2.5)~ 1:(0, 0, -2.5)~ 1.5:(0, 0, 2.5)~ |
| head | ROTATION | 0:(2.5, 0, 0)~ 0.375:(-2.5, 0, 0)~ 0.75:(2.5, 0, 0)~ 1.125:(-2.5, 0, 0)~ 1.5:(2.5, 0, 0)~ |
| right_front_leg | ROTATION | 0:(22.5, 0, 0)~ 0.75:(-22.5, 0, 0)~ 1.5:(22.5, 0, 0)~ |
| right_front_leg | POSITION | 0:(0, 0, 0)~ 0.4583:(0, 4, 0)~ 0.75:(0, 0, 0)~ 1.5:(0, 0, 0)~ |
| left_front_leg | ROTATION | 0:(-22.5, 0, 0)~ 0.75:(22.5, 0, 0)~ 1.5:(-22.5, 0, 0)~ |
| left_front_leg | POSITION | 0:(0, 0, 0)~ 0.75:(0, 0, 0)~ 1.2083:(0, 4, 0)~ 1.5:(0, 0, 0)~ |
| left_hind_leg | ROTATION | 0:(-20.4, 0, 0)~ 0.75:(22.5, 0, 0)~ 1.375:(-22.5, 0, 0) 1.5:(-20.4, 0, 0) |
| left_hind_leg | POSITION | 0:(0, -0.21, 0)~ 0.75:(0, 0, 0)~ 1.0833:(0, 4, 0)~ 1.375:(0, 0, 0) 1.5:(0, -0.21, 0) |
| right_hind_leg | ROTATION | 0:(22.5, 0, 0)~ 0.625:(-22.5, 0, 0)~ 1.5:(22.5, 0, 0)~ |
| right_hind_leg | POSITION | 0:(0, 0, 0)~ 0.375:(0, 4, 0)~ 0.625:(0, 0, 0)~ 1.5:(0, 0, 0)~ |
| left_ear | ROTATION | 0:(0, 0, 0)~ 0.375:(0, 0, -22.5)~ 0.75:(0, 0, 0)~ 1.125:(0, 0, -22.5)~ 1.5:(0, 0, 0)~ |
| right_ear | ROTATION | 0:(0, 0, 0)~ 0.375:(0, 0, 22.5)~ 0.75:(0, 0, 0)~ 1.125:(0, 0, 22.5)~ 1.5:(0, 0, 0)~ |
| tail | ROTATION | 0:(15.941, -8.4211, 20.941)~ 0.75:(15.941, 8.4211, -20.941)~ 1.5:(15.941, -8.4211, 20.941)~ |

#### CAMEL_SIT  length 2 s
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(0, 0, 0) 1.3:(30, 0, 0) 1.8:(24, 0, 0) 2:(0, 0, 0) |
| body | POSITION | 0:(0, 0, 0) 1.3:(0, 0, 1) 1.8:(0, -6, 1) 2:(0, -19.9, 0) |
| right_front_leg | ROTATION | 0:(0, 0, 0) 1:(-30, 0, 0) 1.5:(-30, 0, 0) 2:(-90, 10, 0) |
| right_front_leg | POSITION | 0:(0, 0, 0) 1:(0, -2, 11) 1.5:(0, -2, 11) 1.7:(0, -8.4, 11.4) 2:(0, -20.6, 12) |
| left_front_leg | ROTATION | 0:(0, 0, 0) 1:(-30, 0, 0) 1.5:(-30, 0, 0) 2:(-90, -10, 0) |
| left_front_leg | POSITION | 0:(0, 0, 0) 1:(0, -2, 11) 1.5:(0, -2, 11) 1.7:(0, -8.4, 11.4) 2:(0, -20.6, 12) |
| left_hind_leg | ROTATION | 0:(0, 0, 0) 0.5:(0, 0, 0) 1.5:(-10, 0, 0) 1.7:(-15, -3, 0) 1.9:(-65, -9, 0) 2:(-90, -15, 0) |
| left_hind_leg | POSITION | 0:(0, 0, 0) 0.5:(0, 0, 0) 1.5:(0, 0, 1) 1.7:(1, -0.62, 0.25) 1.9:(0.5, -11.25, 2.5) 2:(1, -20.5, 5) |
| right_hind_leg | ROTATION | 0:(0, 0, 0) 0.5:(0, 0, 0) 1.5:(-10, 0, 0) 1.7:(-15, 3, 0) 1.9:(-65, 9, 0) 2:(-90, 15, 0) |
| right_hind_leg | POSITION | 0:(0, 0, 0) 0.5:(0, 0, 0) 1.5:(0, 0, 1) 1.7:(-1, -0.62, 0.25) 1.9:(-0.5, -11.25, 2.5) 2:(-1, -20.5, 5) |
| head | ROTATION | 0:(0, 0, 0) 0.7:(-27.5, 0, 0) 1.5:(-21.25, 0, 0) 2:(0, 0, 0) |
| tail | ROTATION | 0:(5, 0, 0) 1.7:(5, 0, 0) 1.9:(80, 0, 0) 2:(50, 0, 0) |

#### CAMEL_SIT_POSE  length 1 s
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(0, 0, 0) 1:(0, 0, 0) |
| body | POSITION | 0:(0, -19.9, 0) 1:(0, -19.9, 0) |
| right_front_leg | ROTATION | 0:(-90, 10, 0) 1:(-90, 10, 0) |
| right_front_leg | POSITION | 0:(0, -20.6, 12) 1:(0, -20.6, 12) |
| left_front_leg | ROTATION | 0:(-90, -10, 0) 1:(-90, -10, 0) |
| left_front_leg | POSITION | 0:(0, -20.6, 12) 1:(0, -20.6, 12) |
| left_hind_leg | ROTATION | 0:(-90, -15, 0) 1:(-90, -15, 0) |
| left_hind_leg | POSITION | 0:(1, -20.5, 5) 1:(1, -20.5, 5) |
| right_hind_leg | ROTATION | 0:(-90, 15, 0) 1:(-90, 15, 0) |
| right_hind_leg | POSITION | 0:(-1, -20.5, 5) 1:(-1, -20.5, 5) |
| head | ROTATION | 0:(0, 0, 0) 1:(0, 0, 0) |
| tail | ROTATION | 0:(50, 0, 0) 1:(50, 0, 0) |

#### CAMEL_STANDUP  length 2.6 s
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(0, 0, 0) 0.7:(-17.5, 0, 0)~ 1.8:(-17.83, 0, 0)~ 2.3:(-5.83, 0, 0) 2.6:(0, 0, 0) |
| body | POSITION | 0:(0, -19.9, 0) 0.7:(0, -19.9, -3) 1.4:(0, -12.76, -4)~ 1.8:(0, -10.1, -4)~ 2.3:(0, -2.9, -2) 2.6:(0, 0, 0) |
| right_front_leg | ROTATION | 0:(-90, 10, 0) 0.5:(-90, 10, 0) 1.1:(-49.06, 10, 0) 1.8:(-22.5, 10, 0) 2.3:(-25, 10, 0) 2.6:(0, 0, 0) |
| right_front_leg | POSITION | 0:(0, -20.6, 12) 0.5:(0, -20.6, 8) 1.1:(0, -7.14, 4.42) 1.8:(0, -1.27, -1.33) 2.3:(0, -1.27, -0.33) 2.6:(0, 0, 0) |
| left_front_leg | ROTATION | 0:(-90, -10, 0) 0.5:(-90, -10, 0) 1.1:(-49.06, -10, 0) 1.8:(-22.5, -10, 0) 2.3:(-25, -10, 0) 2.6:(0, 0, 0) |
| left_front_leg | POSITION | 0:(0, -20.6, 12) 0.5:(0, -20.6, 8) 1.1:(0, -7.14, 4.42) 1.8:(0, -1.27, -1.33) 2.3:(0, -1.27, -0.33) 2.6:(0, 0, 0) |
| left_hind_leg | ROTATION | 0:(-90, -15, 0) 0.3:(-90, 0, 0) 0.6:(-90, 0, 0) 1.1:(-60, 0, 0) 1.9:(35, 0, 0) 2.2:(30, 0, 0) 2.6:(0, 0, 0) |
| left_hind_leg | POSITION | 0:(1, -20.5, 5) 0.3:(-2, -20.5, 3) 0.6:(-2, -20.5, 3) 1.1:(-2, -10.5, 2) 1.5:(-2, -0.4, -3.9) 1.9:(-2, -4.3, -9.8) 2.2:(-1, -2.5, -5) 2.6:(0, 0, 0) |
| right_hind_leg | ROTATION | 0:(-90, 15, 0) 0.3:(-90, 0, 0) 0.6:(-90, 0, 0) 1.1:(-60, 0, 0) 1.9:(35, 0, 0) 2.2:(30, 0, 0) 2.6:(0, 0, 0) |
| right_hind_leg | POSITION | 0:(-1, -20.5, 5) 0.3:(2, -20.5, 3) 0.6:(2, -20.5, 3) 1.1:(2, -10.5, 2) 1.5:(2, -0.4, -3.9) 1.9:(2, -4.3, -9.8) 2.2:(1, -2.5, -5) 2.6:(0, 0, 0) |
| head | ROTATION | 0:(0, 0, 0) 0.3:(0, 0, 0) 0.8:(55, 0, 0) 2:(65, 0, 0) 2.4:(0, 0, 0) |
| tail | ROTATION | 0:(50, 0, 0) 0.4:(55, 0, 0) 0.9:(55, 0, 0) 1.5:(17.5, 0, 0) 2.6:(5, 0, 0) |

#### CAMEL_DASH  length 0.5 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(5, 0, 0) 0.5:(5, 0, 0) |
| tail | ROTATION | 0:(67.5, 0, 0)~ 0.125:(112.5, 0, 0)~ 0.25:(67.5, 0, 0)~ 0.375:(112.5, 0, 0)~ 0.5:(67.5, 0, 0)~ |
| head | ROTATION | 0:(10, 0, 0)~ 0.125:(0, 0, 0)~ 0.25:(10, 0, 0)~ 0.375:(0, 0, 0)~ 0.5:(10, 0, 0)~ |
| right_front_leg | ROTATION | 0:(44.973, 1.7675, -1.7683)~ 0.125:(-90, 0, 0)~ 0.25:(44.973, 1.7675, -1.7683)~ 0.375:(-90, 0, 0)~ 0.5:(44.973, 1.7675, -1.7683)~ |
| left_front_leg | ROTATION | 0:(-90, 0, 0)~ 0.125:(44.973, -1.7675, 1.7683)~ 0.25:(-90, 0, 0)~ 0.375:(44.973, -1.7675, 1.7683)~ 0.5:(-90, 0, 0)~ |
| left_hind_leg | ROTATION | 0:(90, 0, 0)~ 0.125:(-45, 0, 0)~ 0.25:(90, 0, 0)~ 0.375:(-45, 0, 0)~ 0.5:(90, 0, 0)~ |
| right_hind_leg | ROTATION | 0:(-45, 0, 0)~ 0.125:(90, 0, 0)~ 0.25:(-45, 0, 0)~ 0.375:(90, 0, 0)~ 0.5:(-45, 0, 0)~ |
| left_ear | ROTATION | 0:(0, -67.5, 0) 0.5:(0, -67.5, 0) |
| right_ear | ROTATION | 0:(0, 67.5, 0) 0.5:(0, 67.5, 0) |

#### CAMEL_IDLE  length 4 s
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| tail | ROTATION | 0:(5, 0, 0)~ 1:(4.9811, 0.43523, -4.9811)~ 3:(4.9872, -0.29424, 3.3674)~ 4:(5, 0, 0)~ |
| head | ROTATION | 0:(0, 0, 0)~ 2:(-2.5, 0, 0)~ 4:(0, 0, 0)~ |
| left_ear | ROTATION | 2.5:(0, 0, -45)~ 2.625:(0, 0, 22.5)~ 2.75:(0, 0, -45)~ 2.875:(0, 0, 22.5)~ 3:(0, 0, -45)~ |
| right_ear | ROTATION | 2.5:(0, 0, 45)~ 2.625:(0, 0, -22.5)~ 2.75:(0, 0, 45)~ 2.875:(0, 0, -22.5)~ 3:(0, 0, 45)~ |



### A.2 `CamelBabyAnimation` (used by `BabyCamelModel`)

#### CAMEL_BABY_WALK  length 1.5 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| root | ROTATION | 0:(0, 0, 2.5) 0.75:(0, 0, -2.5)~ 1.5:(0, 0, 2.5) |
| head | ROTATION | 0:(2.5, 0, 0) 0.375:(-2.5, 0, 0)~ 0.75:(2.5, 0, 0)~ 1.125:(-2.5, 0, 0)~ 1.5:(2.5, 0, 0) |
| head | POSITION | 0:(0, 0, 0) 0.4583:(0, 0, 0.1) |
| right_front_leg | ROTATION | 0:(-22.5, 0, 0) 0.75:(22.5, 0, 0)~ 1.5:(-22.5, 0, 0) |
| right_front_leg | POSITION | 0:(0.075, 0, 0) 0.75:(0.075, 0, 0)~ 1.2083:(0.075, 4, 0)~ 1.5:(0.075, 0, 0) |
| left_front_leg | ROTATION | 0:(22.5, 0, 0) 0.75:(-22.5, 0, 0)~ 1.5:(22.5, 0, 0) |
| left_front_leg | POSITION | 0:(-0.1, 0, 0) 0.4583:(-0.1, 4, 0)~ 0.75:(-0.1, 0, 0)~ 1.5:(-0.1, 0, 0) |
| left_hind_leg | ROTATION | 0:(22.5, 0, 0) 0.375:(-9.49, 0, 0)~ 0.5833:(-17.5, 0, 0)~ 1.2083:(7.38, 0, 0) 1.5:(22.5, 0, 0) |
| left_hind_leg | POSITION | 0:(-0.1, 0, 0) 0.25:(-0.1, 5, 0)~ 0.5833:(-0.1, 0, -0.1)~ 1.5:(-0.1, 0, 0)~ |
| right_hind_leg | ROTATION | 0:(-15.83, 0, 0)~ 0.75:(22.5, 0, 0)~ 1:(-7.38, 0, 0)~ 1.25:(-21, 0, 0)~ 1.5:(-15.83, 0, 0)~ |
| right_hind_leg | POSITION | 0:(0.1, 0, 0) 0.6667:(0.1, 0, 0)~ 1:(0.1, 4, 0.17)~ 1.2083:(0.1, 0, -0.11)~ 1.5:(0.1, 0, 0) |
| left_ear | ROTATION | 0:(0, 0, 0) 0.375:(0, 0, 22.5)~ 0.75:(0, 0, 0)~ 1.125:(0, 0, 22.5)~ 1.5:(0, 0, 0) |
| right_ear | ROTATION | 0:(0, 0, 0) 0.375:(0, 0, -22.5)~ 0.75:(0, 0, 0)~ 1.125:(0, 0, -22.5)~ 1.5:(0, 0, 0) |
| tail | ROTATION | 0:(15.94, -8.42, 20.94) 0.75:(15.94, 8.42, -20.94)~ 1.5:(15.94, -8.42, 20.94) |
| body | POSITION | 0:(0, -0.6, 0) 0.4583:(0, -0.6, 0) |

#### CAMEL_BABY_STANDUP  length 2.6 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(2.5, 0, 0) 0.2:(2.5, 0, 0) 0.9:(-12.5, 0, 0) 1:(-12.6, 0, 0) 1.9:(0, 0, 0) 2.3:(0, 0, 0) 2.6:(0, 0, 0) |
| body | POSITION | 0:(0, -13.25, 0) 0.2:(0, -13.25, 0) 0.3:(0, -11.52, -0.85) 0.9:(0, -9.4335, -1.6246) 1:(0, -9.15, -1.58) 1.2:(0, -8.5, -1.3) 1.9:(0, -1.7, 0)~ 2.3:(0, -0.1, 0) 2.6:(0, 0, 0) |
| right_front_leg | ROTATION | 0:(-90, 10, 0) 0.2:(-75.21, 9.37, 2.45) 0.3:(-70.21, 9.37, 2.45) 0.8:(-40.55, 8.68, 1.23) 1:(-40.55, 8.68, 1.23) 1.2:(-20.45, 7.61, 0.74) 1.5:(-20.45, 7.61, 0.74) 1.6:(-20.45, 7.61, 0.74) 1.9:(0, 0, 0) 2.1:(0, 0, 0) 2.3:(0, 0, 0) 2.6:(0, 0, 0) |
| right_front_leg | POSITION | 0:(0.1, -11, 6) 0.2:(0.1, -8, 6) 0.3:(-0.12, -7.18, 5) 0.8:(-0.9942, -2.3474, 2.2929) 1:(-0.9942, -2.3474, 2.2929) 1.2:(-0.72, -0.6, 1.71) 1.5:(-0.72, -0.6, 1.71) 1.6:(-0.72, -0.6, 1.71) 1.7:(-0.21, -0.55, 1.05) 1.8:(-0.21, 0.73, 0.52) 1.9:(0.05, 0, 0) 2.1:(0.05, 0, 0) 2.2:(0, 0, 0) 2.3:(0, 0, 0) 2.6:(0, 0, 0) |
| left_front_leg | ROTATION | 0:(-90, -10, 0) 0.2:(-74.2, -9.3, -2.45) 0.3:(-69.2, -9.32, -2.4) 0.8:(-46.75, -10, 0) 1:(-46.75, -10, 0) 1.2:(-24.31, -9.2, 0) 1.5:(-24.31, -9.2, 0) 1.7:(-24.31, -9.2, 0) 1.9:(-12.15, -4.6, 0) 2:(-12.15, -4.6, 0) 2.2:(0, 0, 0) 2.5:(0, 0, 0) 2.6:(0, 0, 0) |
| left_front_leg | POSITION | 0:(0, -11, 6) 0.2:(0, -7.89, 4.96) 0.3:(0, -6.89, 4.96) 0.8:(0.65, -2.98, 3.56) 1:(0.65, -2.98, 3.56) 1.2:(0.5, -0.69, 2.47) 1.5:(0.5, -0.69, 2.47) 1.7:(0.5, -0.69, 2.47) 1.9:(0.4, 0, 0) 2.1:(0.2, 1, 0) 2.2:(-0.025, 0, 0) 2.3:(-0.02, 0, 0) 2.5:(0, 0, 0) 2.6:(0, 0, 0) |
| left_hind_leg | ROTATION | 0:(-90, -12, -0.5) 0.2:(-90, -12, -0.5) 0.5:(-89.79, -17.4, -0.8) 0.8:(-89.38, -11.59, -0.99) 0.9:(-89.09, -7.49, -0.98) 1:(-88.5, -4.3, -1) 1.2:(-79.5, -4.3, -1) 1.3:(-66.11, -4.19, -1.05) 1.5:(-47.51, -4.19, -1.05) 1.7:(-35.11, -4.19, -1.05) 1.8:(-20.63, 0, 0) 1.9:(5, 0, 0) 2.1:(0, 0, 0) 2.6:(0, 0, 0) |
| left_hind_leg | POSITION | 0:(1.5, -10.949, 1.9507) 0.2:(1.5, -10.949, 1.9507) 0.5:(1, -11, 1.75) 0.8:(0.16, -11.11, 0.49) 0.9:(-0.81, -10.95, -0.02) 1:(-0.77, -10.8, -0.94) 1.2:(-0.77, -8.7, -0.94) 1.3:(-1.6, -6.43, -1.59) 1.5:(-1.36, -3.37, -1.65) 1.7:(-1.2, -1.33, -1.69) 1.8:(-0.6, 2, -0.3) 1.9:(-0.2, 1.9, -1) 2.1:(0, 0, 0) 2.6:(0, 0, 0) |
| right_hind_leg | ROTATION | 0:(-90, 12, 0.5) 0.2:(-90, 12, 0.5) 0.5:(-90, 17.5, 1) 0.8:(-90, 8.5, 0.73) 0.9:(-90, 3, 0.37) 1:(-75.38, 0, 0) 1.3:(-56.38, 0, 0) 1.5:(-30.15, 0, 0) 1.6:(3.6, 0, 0) 1.7:(0, 0, 0) 1.9:(0, 0, 0) 2.1:(0, 0, 0) 2.6:(0, 0, 0) |
| right_hind_leg | POSITION | 0:(-1.3, -11, 1.95) 0.2:(-1.3, -11, 1.95) 0.5:(-0.7, -10.9, 1.8) 0.8:(-0.06, -11.2, 0.21) 0.9:(0.39, -11.2, -0.23) 1:(0.24, -8, -1.27) 1.3:(0.34, -4.53, -0.8) 1.4:(0.3, -1.88, -0.42) 1.5:(0.25, 0.18, 0.3) 1.6:(0.25, 1.48, -1.75) 1.7:(0.1, 0, -0.4) 1.9:(0.1, 0, 0) 2.1:(0, 0, 0) 2.6:(0, 0, 0) |
| head | ROTATION | 0:(-4.75, 0, 0) 0.2:(5.65, 0, 0) 0.5:(40, 0, 0) 1.5:(46.68, 0, 0)~ 1.6:(37.5, 0, 0)~ 2:(0, 0, 0) 2.6:(0, 0, 0) |
| head | POSITION | 0:(0, 0, 0) 0.5:(0, 0.8368, 1.9553) 1.8:(0, -0.95, 1.5) 2.3:(0, -0.95, 1.42) 2.6:(0, -0.95, 1.42) |
| tail | ROTATION | 0:(46.5, 0, 0) 0.2:(46.5, 0, 0) 0.3:(39, 0, 0) 0.5:(40.75, 0, 0) 0.7:(47, 0, 0) 0.8:(49.5, 0, 0) 0.9:(52.75, 0, 0) 1:(50.5, 0, 0) 1.1:(42.75, 0, 0) 1.3:(1.75, 0, 0) 1.4:(7, 0, 0) 1.8:(6, 0, 0) 2.3:(5, 0, 0) 2.6:(5, 0, 0) |
| tail | POSITION | 0:(0, 0, 0) 0.2:(0, 0, 0) 0.3:(0, 0, 0) 0.7:(0, 0, 0) 0.8:(0, 0, 0) 1:(0, 0, 0) 2.3:(0, 0, 0) 2.6:(0, 0, 0) |
| right_ear | ROTATION | 0:(0, 0, 15) 1:(0, 0, 15) 1.4:(0, 0, 15) 1.6:(0, 0, 5) 1.9:(0, 0, -23.75) 2.2:(0, 0, -23.75) 2.3:(0, 0, 12.5) 2.4:(0, 0, 67.5) 2.5:(0, 0, 45) 2.6:(0, 0, 45) |
| right_ear | POSITION | 2.3:(0, 0, 0) 2.4:(0, 0, 0) 2.5:(0, 0, 0) 2.6:(0, 0, 0) |
| left_ear | ROTATION | 0:(0, 0, -22.5) 1:(0, 0, -22.5) 1.4:(0, 0, -22.5) 1.6:(0, 0, -7.5) 1.9:(0, 0, 22.5) 2.2:(0, 0, 22.5) 2.3:(0, 0, -22.5) 2.4:(0, 0, -55) 2.5:(0, 0, -45) 2.6:(0, 0, -45) |
| left_ear | POSITION | 2.3:(0, 0, 0) 2.4:(0, 0, 0) 2.5:(0, 0, 0) 2.6:(0, 0, 0) |

#### CAMEL_BABY_DASH  length 0.5 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(5, 0, 0) 0.5:(5, 0, 0) |
| body | POSITION | 0:(0, -2.8, 0) |
| tail | ROTATION | 0:(67.5, 0, 0)~ 0.125:(112.5, 0, 0)~ 0.25:(67.5, 0, 0)~ 0.375:(112.5, 0, 0)~ 0.5:(67.5, 0, 0)~ |
| head | ROTATION | 0:(5, 0, 0)~ 0.125:(0, 0, 0)~ 0.25:(5, 0, 0)~ 0.375:(0, 0, 0)~ 0.5:(5, 0, 0)~ |
| head | POSITION | 0:(0, 0, 1) 0.5:(0, 0, 1) |
| right_front_leg | ROTATION | 0:(44.973, 1.7675, -1.7683)~ 0.125:(-90, 0, 0)~ 0.25:(44.973, 1.7675, -1.7683)~ 0.375:(-90, 0, 0)~ 0.5:(44.973, 1.7675, -1.7683)~ |
| right_front_leg | POSITION | 0:(0.05, 0, 0) |
| left_front_leg | ROTATION | 0:(-90, 0, 0)~ 0.125:(44.973, -1.7675, 1.7683)~ 0.25:(-90, 0, 0)~ 0.375:(44.973, -1.7675, 1.7683)~ 0.5:(-90, 0, 0)~ |
| left_front_leg | POSITION | 0:(-0.05, 0, 0) |
| left_hind_leg | ROTATION | 0:(90, 0, 0)~ 0.125:(-45, 0, 0)~ 0.25:(90, 0, 0)~ 0.375:(-45, 0, 0)~ 0.5:(90, 0, 0)~ |
| left_hind_leg | POSITION | 0:(-0.05, 0, 0) |
| right_hind_leg | ROTATION | 0:(-45, 0, 0)~ 0.125:(90, 0, 0)~ 0.25:(-45, 0, 0)~ 0.375:(90, 0, 0)~ 0.5:(-45, 0, 0)~ |
| right_hind_leg | POSITION | 0:(0.05, 0, 0) |
| left_ear | ROTATION | 0:(0, -67.5, 0) 0.5:(0, -67.5, 0) |
| right_ear | ROTATION | 0:(0, 67.5, 0) 0.5:(0, 67.5, 0) |

#### CAMEL_BABY_IDLE  length 4 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| tail | ROTATION | 0:(5, 0, 0)~ 1:(4.9811, 0.4352, -4.9811)~ 3:(4.9872, -0.2942, 3.3674)~ 4:(5, 0, 0)~ |
| head | ROTATION | 0:(0, 0, 0)~ 2:(-2.5, 0, 0)~ 4:(0, 0, 0)~ |
| left_ear | ROTATION | 0:(0, 0, -45)~ 2.5:(0, 0, -45)~ 2.625:(0, 0, 22.5)~ 2.75:(0, 0, -45)~ 2.875:(0, 0, 22.5)~ 3:(0, 0, -45)~ 4:(0, 0, -45)~ |
| right_ear | ROTATION | 0:(0, 0, 45)~ 2.5:(0, 0, 45)~ 2.625:(0, 0, -22.5)~ 2.75:(0, 0, 45)~ 2.875:(0, 0, -22.5)~ 3:(0, 0, 45)~ 4:(0, 0, 45)~ |
| body | POSITION | 0:(0, -0.1, 0) |

#### CAMEL_BABY_SIT  length 2 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(0, 0, 0) 0.4:(9.26, 0, 0) 0.6:(18.15, 0, 0) 0.9:(30, 0, 0)~ 1.2:(21.14, 0, 0) 1.3:(15, 0, 0) 1.4:(2.5, 0, 0) 1.6:(2.5, 0, 0) 1.7:(2.5, 0, 0) 2:(2.5, 0, 0) |
| body | POSITION | 0:(0, -0.1, 0) 0.2:(0, -1.5, 0) 0.4:(0, -2.21, 0.04) 0.6:(0, -2.21, 0.04) 1.1:(0, -5.23, 0.33) 1.2:(0, -6.06, 0.17) 1.3:(0, -11.7, 0) 1.4:(0, -13.35, 0) 1.6:(0, -13.25, 0) 1.7:(0, -13.25, 0) 2:(0, -13.25, 0) |
| right_front_leg | ROTATION | 0:(0, 0, 0) 0.5:(-2.5, 0, 0) 0.7:(-23, 0, 0) 1:(-30, 0, 0) 1.1:(-44.5, 0, 0) 1.3:(-73.25, 6.5, 0) 1.4:(-90, 10, 0) 1.7:(-90, 10, 0) 2:(-90, 10, 0) |
| right_front_leg | POSITION | 0:(0.125, -0.1, 0) 0.5:(0.125, -0.1, 0.4) 0.6:(0.12, -0.15, 2.5) 0.7:(0.12, -0.6, 4.6) 0.9:(0.12, -0.87, 5.97) 1:(0.125, -1, 6.9) 1.1:(0.325, -2.6, 7.6) 1.3:(-0.28, -7.45, 8.06) 1.4:(0.1, -11, 6) 1.7:(0.1, -11, 6) 2:(0.1, -11, 6) |
| left_front_leg | ROTATION | 0:(0, 0, 0) 0.5:(-2.5, 0, 0) 0.7:(-23, 0, 0) 1:(-30, 0, 0) 1.1:(-45.5, 0, 0) 1.3:(-73.5, -6.5, 0) 1.4:(-90, -10, 0) 1.7:(-90, -10, 0) 2:(-90, -10, 0) |
| left_front_leg | POSITION | 0:(-0.125, 0, 0) 0.5:(-0.125, 0, 0) 0.6:(-0.13, -0.18, 2.35) 0.7:(-0.13, -0.57, 4.7) 0.9:(-0.13, -0.86, 6.07) 1:(-0.125, -1, 6.8) 1.1:(-0.22, -2.7, 7.8) 1.3:(0.19, -7.5, 8.01) 1.4:(0, -11, 6) 1.7:(0, -10.9, 6) 2:(0, -11, 6) |
| left_hind_leg | ROTATION | 0:(0, 0, 0) 0.5:(0, 0, 0) 0.9:(-10, 0, 0) 1.1:(-31.47, -0.45, 1.29) 1.2:(-49.78, -10.29, -1.15) 1.3:(-79.21, -13.72, -1.53) 1.4:(-90, -11.88, -0.54) 2:(-90, -11.88, -0.54) |
| left_hind_leg | POSITION | 0:(-0.1, 0, 0) 0.5:(-0.1, 0, 0) 0.9:(-0.1, 0, 1) 1.1:(0.56, -3.49, 2.18) 1.3:(1.22, -8.72, 3) 1.4:(1.4, -10.95, 1.95) 2:(1.4, -10.95, 1.95) |
| right_hind_leg | ROTATION | 0:(0, 0, 0) 0.5:(0, 0, 0) 0.9:(-10, 0, 0) 1.1:(-31.13, 0.56, -1.3) 1.2:(-49.8, 10.3, 1.15) 1.3:(-79.21, 13.72, 1.53) 1.4:(-90, 11.89, 0.54) 2:(-90, 11.89, 0.54) |
| right_hind_leg | POSITION | 0:(0.1, 0, 0) 0.5:(0.1, 0, 0) 0.9:(0.1, 0, 1) 1.1:(0.2, -0.75, 1.5) 1.2:(-0.51, -3.49, 2.18) 1.3:(-1.22, -8.72, 3.1) 1.4:(-1.33, -11, 1.95) 2:(-1.33, -11, 1.95) |
| head | ROTATION | 0:(0, 0, 0) 0.1:(0, 0, 0) 0.4:(-20.42, 0, 0) 0.9:(-31.25, 0, 0) 1.1:(-26.5, 0, 0) 1.2:(-19.25, 0, 0) 1.3:(-14.5, 0, 0) 1.4:(-4.75, 0, 0) 1.6:(-4.75, 0, 0) 2:(-4.75, 0, 0) |
| head | POSITION | 0:(0, 0, 0) 0.1:(0, 0, 0) 0.4:(0, 0.38, 0.44) 0.9:(0, 0.35, 0.88) 1.1:(0, -0.3, 1.21) 1.3:(0, -0.3, 1.22) 1.6:(0, 0, 1.22) |
| tail | ROTATION | 0:(5, 0, 0) 0.9:(5, 0, 0) 1.2:(25, 0, 0) 1.4:(52.5, 0, 0) 1.6:(62.5, 0, 0) 1.8:(52.5, 0, 0) 2:(52.5, 0, 0) |
| tail | POSITION | 1.4:(0, 0, 0) 1.8:(0, 0, 0) 2:(0, 0, 0) |
| left_ear | ROTATION | 0:(0, 0, -45) 1.2:(0, 0, -45) 1.3:(0, 0, -62.5) 1.4:(0, 0, -45) 1.5:(0, 0, 20) 1.6:(0, 0, -22.5) 2:(0, 0, -22.5) |
| left_ear | POSITION | 1.2:(0, 0, 0) |
| right_ear | ROTATION | 0:(0, 0, 45) 1.2:(0, 0, 45) 1.3:(0, 0, 60) 1.4:(0, 0, 45) 1.5:(0, 0, -20) 1.6:(0, 0, 15) 2:(0, 0, 15) |
| right_ear | POSITION | 1.2:(0, 0, 0) |

#### CAMEL_BABY_SIT_POSE  length 0 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(2.5, 0, 0) |
| body | POSITION | 0:(0, -13.25, 0) |
| right_front_leg | ROTATION | 0:(-90, 10, 0) |
| right_front_leg | POSITION | 0:(0.1, -11, 6) |
| left_front_leg | ROTATION | 0:(-90, -10, 0) |
| left_front_leg | POSITION | 0:(0, -11, 6) |
| left_hind_leg | ROTATION | 0:(-90, -11.88, -0.54) |
| left_hind_leg | POSITION | 0:(1.4, -10.95, 1.95) |
| right_hind_leg | ROTATION | 0:(-90, 11.89, 0.54) |
| right_hind_leg | POSITION | 0:(-1.33, -11, 1.95) |
| head | ROTATION | 0:(-4.75, 0, 0) |
| head | POSITION | 0:(0, 0, 1.22) |
| tail | ROTATION | 0:(52.5, 0, 0) |
| tail | POSITION | 0:(0, 0, 0) |
| left_ear | ROTATION | 0:(0, 0, -22.5) |
| left_ear | POSITION | 0:(0, 0, 0) |
| right_ear | ROTATION | 0:(0, 0, 15) |
| right_ear | POSITION | 0:(0, 0, 0) |
| root | POSITION | 0:(0, 0, 0) |
| root | SCALE | 0:(1, 1, 1) |



### A.3 `RabbitAnimation` (used by `AdultRabbitModel`)

#### HOP  length 0.75 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.2083:(4, 0, 0)~ 0.2917:(32.5, 0, 0) 0.4167:(33, 0, 0)~ 0.5833:(18, 0, 0)~ 0.75:(0, 0, 0) |
| body | POSITION | 0:(0, 0, 0) 0.75:(0, 0, 0) |
| head | ROTATION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.2083:(-4, 0, 0) 0.2917:(-32.17, 0, 0) 0.375:(-34.58, 0, 0) 0.5833:(-20, 0, 0) 0.75:(0, 0, 0) |
| head | POSITION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.375:(0, 0, 0) 0.75:(0, 0, 0) |
| backlegs | ROTATION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.25:(125, 0, 0) 0.2917:(125, 0, 0) 0.375:(120, 0, 0) 0.4583:(95, 0, 0) 0.5417:(42, 0, 0) 0.6667:(0, 0, 0) 0.75:(0, 0, 0) |
| backlegs | POSITION | 0:(0, 0, 0) 0.6667:(0, 0, 0) 0.75:(0, 0, 0) |
| frontlegs | ROTATION | 0:(-0.17, 0, 0) 0.125:(-0.17, 0, 0) 0.2083:(25.25, 0, 0) 0.2917:(-65, 0, 0)~ 0.4583:(-67.5, 0, 0)~ 0.625:(-1.25, 0, 0) 0.749:(-1.25, 0, 0) 0.75:(0, 0, 0) |
| frontlegs | POSITION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.3333:(0, 0.5, 0.6) 0.4167:(0, 0.9, 0.4) 0.75:(0, 0, 0) |
| right_front_leg | ROTATION | 0:(0, 0, 0)~ 0.125:(0, 0, 0)~ 0.2083:(0, 0, 0)~ 0.3333:(0, 0, -17.5)~ 0.5:(0, 0, -17.5)~ 0.5833:(0, 0, -2)~ 0.75:(0, 0, 0)~ |
| right_front_leg | POSITION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.2083:(0, 0, 0) 0.75:(0, 0, 0) |
| left_front_leg | ROTATION | 0:(0, 0, 0)~ 0.125:(0, 0, 0)~ 0.2083:(0, 0, 0)~ 0.3333:(0, 0, 20)~ 0.5:(0, 0, 20)~ 0.5833:(0, 0, 2)~ 0.75:(0, 0, 0)~ |
| left_front_leg | POSITION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.2083:(0, 0, 0) 0.75:(0, 0, 0) |
| left_ear | ROTATION | 0:(0, 0, 0)~ 0.125:(2.5, 0, 0)~ 0.375:(-48.5, 0, 0)~ 0.5417:(-41.24, 0, 0)~ 0.75:(0, 0, 0) |
| left_ear | POSITION | 0:(-0.025, 0, 0)~ 0.2083:(-0.025, -0.2, 0)~ 0.375:(-0.02, -0.3, 0)~ 0.75:(-0.025, 0, 0)~ |
| right_ear | ROTATION | 0:(0, 0, 0)~ 0.125:(7.5, 0, 0)~ 0.375:(-31.5, 0, 0)~ 0.5:(-35.33, 0, 0)~ 0.75:(0, 0, 0)~ |
| right_ear | POSITION | 0:(0.025, 0, 0)~ 0.2083:(0.025, -0.3, 0)~ 0.375:(0.02, -0.23, 0)~ 0.75:(0.025, 0, 0)~ |
| right_hind_leg | ROTATION | 0:(0, -2.5, 0) 0.1667:(0, -2.5, 0) 0.2083:(47.5, 0, 0)~ 0.4167:(47.5, 0, 0)~ 0.4583:(0, 0, 0) 0.75:(0, -2.5, 0) |
| right_hind_leg | POSITION | 0:(0, 0, 0) 0.6667:(0, 0, 0) 0.75:(0, 0, 0) |
| left_hind_leg | ROTATION | 0:(0, 0, 0) 0.1667:(0, 0, 0) 0.2083:(47.5, 0, 0) 0.4167:(47.5, 0, 0)~ 0.4583:(0, 0, 0) 0.75:(0, 0, 0) |
| left_hind_leg | POSITION | 0:(0, 0, 0) 0.6667:(0, 0, 0) 0.75:(0, 0, 0) |
| tail | ROTATION | 0:(0, 0, 0) 0.125:(-25, 0, 0) 0.3333:(15, 0, 0) 0.375:(27.5, 0, 0) 0.75:(0, 0, 0) |
| tail | POSITION | 0:(0, 0, 0) 0.75:(0, 0, 0) |

#### IDLE_HEAD_TILT  length 4 s
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(0, 0, 0) 0.25:(-62, 0, 0) 0.3333:(-57, 0, 0) 0.7083:(-57, 0, 0) 0.875:(-57, 12, 2) 0.9583:(-57, 5, 1) 1.5417:(-57, 5, 1) 1.7083:(-56.5, -16, -3) 1.7917:(-57, -7.5, -1.5) 2.5417:(-57, -7.5, -1.5) 2.7083:(-57, 11, 2) 2.7917:(-57, 5, 1) 2.9583:(-57, 5, 1) 3.1667:(-57, 5, 1) 3.25:(-57.5, 5, 1) 3.4583:(-60, 5, 0.5) 3.5833:(-60, 5, 0.5) 3.6667:(-39.5, 3.5, 0.5) 3.8333:(10, 0, 0) 3.9167:(0, 0, 0) |
| body | POSITION | 0:(0, 0, 0) 0.1667:(0, 0.7, 0) 0.25:(0, 0, 0) 3.8333:(0, 0, 0) 3.9167:(0, 0, 0) |
| body | SCALE | 0:(1, 1, 1) 3.8333:(1, 1, 1) 3.9167:(1, 1, 1) |
| tail | ROTATION | 0:(0, 0, 0) 0.0833:(33, 0, 0)~ 0.2083:(54.5, 0, 0)~ 0.2917:(55, 0, 0)~ 0.375:(55, 0, 0) 0.7083:(55, 0, 0) 0.8333:(55, -3.5, -19.5)~ 0.9167:(55, -6, 7.5)~ 1.0417:(55, 0, 0) 1.5417:(55, 0, 0) 1.625:(55, 2.5, 12.5)~ 1.7083:(55, 4.5, 25.5)~ 1.7917:(55, 19.5, -16)~ 1.875:(55, 0, 0) 2.5417:(54.5, 0, 0) 3.5833:(54.5, 0, 0) 3.8333:(-46, 0, 0)~ 3.9167:(0, 0, 0)~ |
| tail | POSITION | 0:(0, 0, 0) 0.7083:(0, 0, 0) 0.8333:(0, 0, 0)~ 0.9167:(0, 0, 0)~ 1.0417:(0, 0, 0) 1.5417:(0, 0, 0) 3.8333:(0, 0, 0) 3.9167:(0, 0, 0) |
| head | ROTATION | 0:(0, 0, 0) 0.25:(54.5, 0, 0) 0.3333:(40, 0, 0) 0.75:(40, 0, 0) 0.9167:(40, 20.5, -11)~ 1:(39.5, 11.5, -6)~ 1.2917:(39.3, 11.5, -6) 1.75:(39.5, 11.5, -6) 1.9167:(36, -28.5, 16.5) 2:(38, -18.5, 10) 2.625:(38, -18.5, 10) 2.7083:(40, 0, 0) 2.7917:(40, 0, 0) 2.9583:(40, 0, 0) 3.1667:(40, 0, 0) 3.25:(42.5, -0.25, 0) 3.5833:(45.5, -0.5, 0) 3.8333:(-20, 0, 0)~ 3.9167:(0, 0, 0) |
| head | POSITION | 0:(0, 0, 0) 0.25:(0, 0, -2.5) 0.3333:(0, 0, -2) 0.5833:(0, 0, -2) 0.75:(0, 0, -2) 1.75:(0, 0, -2) 2.7083:(0, 0, -2) 3.5833:(0, 0, -2) 3.8333:(0, -1, 0)~ 3.9167:(0, 0, 0) |
| left_ear | ROTATION | 0:(0, 0, 0) 0.2083:(35, 0, 0) 0.2917:(19, 0, 0) 0.3333:(0, 0, 0) 0.75:(0, 0, 0) 0.9167:(-15, 0, 7.5) 1:(-7.5, 0, -5) 1.0833:(0, 0, 0) 1.6667:(0, 0, 0) 1.75:(-3, 1.5, -17) 1.8333:(0, 0, 0) 1.9167:(-48.75, 0, 5) 2:(-65, 2.5, 0.5) 2.0833:(-45, 0, 0) 2.1667:(-40, 0, 0) 2.5417:(-40, 0, 0) 2.625:(11, 0, 0) 2.7083:(23.25, 0, 3.75) 2.75:(25.5, 2, 6) 2.8333:(10, -0.5, 0.75) 3.625:(10, -0.5, 0.75) 3.7083:(-25, 0.25, -1) 3.7917:(-19, 0, -1) 3.8333:(2.5, 0.2, -0.5) 3.9167:(0, 0, 0) |
| left_ear | POSITION | 0:(-0.025, 0, 0) 0.2083:(-0.125, -0.6553, 0.1589) 0.3333:(-0.025, 0, 0) 0.75:(-0.025, 0, 0) 0.9167:(-0.0502, -0.1915, -0.0518) 1:(-0.2423, -0.1025, 0.0261) 1.0833:(-0.025, 0, 0) 1.6667:(-0.025, 0, 0) 1.75:(-0.3, -0.3, 0) 1.7917:(-0.095, -0.15, 0) 1.8333:(-0.025, 0, 0) 2:(-0.025, -0.575, 0) 2.0833:(-0.025, -0.575, 0) 2.1667:(-0.025, -0.575, 0) 2.5417:(-0.065, -0.575, 0) 2.625:(-0.025, -0.25, 0) 2.75:(-0.025, -0.25, 0.25) 2.7917:(-0.025, -0.25, 0) 2.8333:(-0.025, -0.25, 0) 3.625:(-0.025, -0.25, 0) 3.9167:(-0.025, 0, 0) |
| right_ear | ROTATION | 0:(0, 0, 0) 0.1667:(35, 0, 0) 0.3333:(0, 0, 0) 0.75:(0, 0, 0) 0.9167:(-22.342, -2.5587, 5.4476) 1:(-11.17, -1.28, -21.03) 1.0833:(-4.1101, 3.0703, -18.144) 1.125:(-0.0844, 3.027, -9.5338) 1.5417:(-0.0844, 3.027, -9.5338) 1.6667:(0, 0, 0) 1.75:(-1.5, 1, -14.5) 1.8333:(0, 0, 0) 1.9167:(-45, 0, 5) 2:(-60, 1, 5) 2.0833:(-50, 0, 0) 2.5417:(-50, 0, 0) 2.625:(16, 0, 0) 2.7083:(25.5, 0, 0) 2.7917:(5.25, 0.5, -2) 2.8333:(8.5, 1, -4) 3.625:(8.5, 1, -4) 3.7083:(-37.5, 0.25, -1.5) 3.7917:(-23.5, 0, -1) 3.8333:(10, 0.25, -0.5) 3.9167:(0, 0, 0) |
| right_ear | POSITION | 0:(0.025, 0, 0) 0.1667:(0.07, -0.59, 0.14) 0.2083:(0.075, -0.4587, 0.1769) 0.3333:(0.025, 0, 0) 0.75:(0.025, 0, 0) 0.875:(0.13, -0.15, 0) 0.9167:(0.125, -0.2, 0) 1:(0.0182, -0.4258, 0.0581) 1.0833:(0.02, -0.36, 0.02) 1.125:(0.025, -0.175, 0) 1.5417:(0.025, -0.175, 0) 1.6667:(0.025, 0, 0) 1.75:(0.025, 0, 0) 1.8333:(0.025, 0, 0) 2:(0.1, -0.55, 0) 2.0833:(0.025, -0.5, 0) 2.5417:(0.025, -0.5, 0) 2.5833:(0.025, -0.25, 0) 2.7083:(0.025, -0.25, 0) 2.8333:(0.025, -0.25, 0) 3.625:(0.025, -0.25, 0) 3.9167:(0.025, 0, 0) |
| right_front_leg | ROTATION | 0:(0, 0, 0) 0.1667:(0, 0, 0) 0.3333:(60, 0, 0) 0.4167:(40, 0, 0) 0.7083:(40, 0, 0) 0.8333:(38.5, 15, -9.5) 0.9167:(39.5, 7, -4.5) 1:(40, 0, 0) 1.6667:(40, 0, 0) 1.75:(36.5, 28.5, -16) 1.8333:(38.5, 20, -10.5) 3.5:(38.5, 20, -10.5) 3.5833:(40, 0, 0) 3.75:(12.5, 0, 0) 3.8333:(0, 0, 0) 3.9167:(0, 0, 0) |
| right_front_leg | POSITION | 0:(0, 0, 0) 0.1667:(0, 0, 0) 0.3333:(0, 0.6, 0) 0.4167:(0, 0.6, 0) 0.7083:(0, 0.6, 0) 1:(0, 0.6, 0) 1.6667:(0, 0.6, 0) 3.5833:(0, 0.6, 0) 3.75:(0, 0.5, 0.5) 3.8333:(0, 1, -0.5) 3.9167:(0, 0, 0) |
| left_front_leg | ROTATION | 0:(0, 0, 0) 0.2083:(0, 0, 0) 0.375:(70, 0, 0) 0.4583:(40, 0, 0) 0.7083:(40, 0, 0) 0.8333:(40, 9, -1) 0.9167:(39.5, 5, -4.5) 1:(40, 0, 0) 1.6667:(40, 0, 0) 1.75:(37.5, -24.5, 13) 1.8333:(39.5, -15.5, 8) 3.5:(39.5, -15.5, 8) 3.5833:(40, 0, 0) 3.75:(10.5, 0, 0) 3.8333:(0, 0, 0) 3.9167:(0, 0, 0) |
| left_front_leg | POSITION | 0:(0, 0, 0) 0.2083:(0, 0, 0) 0.375:(0, 0.8, 0) 0.4583:(0, 0.6, 0) 0.7083:(0, 0.6, 0) 1:(0, 0.6, 0) 1.6667:(0, 0.6, 0) 3.5833:(0, 0.6, 0) 3.75:(0, 0.5, 0) 3.8333:(0, 1, -0.5) 3.9167:(0, 0, 0) |
| frontlegs | POSITION | 0:(0, 0, 0) 0.2917:(0, 0.1981, 0.0278)~ 1.5:(0, 0.2, 0.03)~ 1.8333:(-0.0261, 0.005, -0.0061) 3.625:(-0.03, 0.01, -0.01) 3.9167:(0, 0, 0) |



### A.4 `BabyRabbitAnimation` (used by `BabyRabbitModel`)

#### HOP  length 0.75 s, looping
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(0, 0, 0.01) 0.125:(0, 0, 0.01) 0.2083:(3.75, 0, 0)~ 0.2917:(32.5, 0, 0) 0.4167:(33, 0, 0)~ 0.5833:(18, 0, 0)~ 0.75:(0, 0, 0.01) |
| body | POSITION | 0:(0, 0, 0) 0.75:(0, 0, 0) |
| head | ROTATION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.2083:(-5.25, 0, 0)~ 0.2917:(-32.17, 0, 0)~ 0.375:(-34.58, 0, 0)~ 0.5833:(-20, 0, 0)~ 0.75:(0, 0, 0) |
| head | POSITION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.375:(0, 0, 0) 0.75:(0, 0, 0) |
| backlegs | ROTATION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.25:(125, 0, 0)~ 0.375:(125.5, 0, 0)~ 0.4583:(95, 0, 0) 0.5417:(42, 0, 0) 0.6667:(0, 0, 0) 0.75:(0, 0, 0) |
| backlegs | POSITION | 0:(0, 0, 0) 0.6667:(0, 0, 0) 0.75:(0, 0, 0) |
| frontlegs | ROTATION | 0:(-0.17, 0, 0) 0.125:(-0.17, 0, 0) 0.2083:(14.61, 0, 0) 0.3333:(-74.37, 0, 0)~ 0.5:(-78.19, 0, 0)~ 0.5417:(-62.47, 0, 0)~ 0.625:(-1.25, 0, 0) 0.749:(-1.25, 0, 0) 0.75:(0, 0, 0) |
| frontlegs | POSITION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.2083:(0, -0.16, 0.16) 0.3333:(0, 0.1, -0.1)~ 0.75:(0, 0, 0) |
| right_front_leg | ROTATION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.375:(0, 0, -8.45)~ 0.4583:(0, 0, -8.48)~ 0.5833:(0, 0, -2)~ 0.75:(0, 0, 0)~ |
| right_front_leg | POSITION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.2083:(0, 0.5, -0.5)~ 0.75:(0, 0, 0) |
| left_front_leg | ROTATION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.375:(0, 0, 10.44)~ 0.4583:(0, 0, 10.61)~ 0.5833:(0, 0, 2)~ 0.75:(0, 0, 0)~ |
| left_front_leg | POSITION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.2083:(0, 0.5, -0.5)~ 0.75:(0, 0, 0) |
| left_ear | ROTATION | 0:(0, 0, 0) 0.1667:(0, 0, 0) 0.375:(-48.5, 0, 0)~ 0.5417:(-41.24, 0, 0)~ 0.75:(0, 0, 0) |
| left_ear | POSITION | 0:(-0.02, 0, 0) 0.1667:(-0.02, 0, 0) 0.375:(-0.025, -0.5, 0)~ 0.5417:(-0.02, -0.38, 0)~ 0.75:(-0.02, 0, 0)~ |
| right_ear | ROTATION | 0:(0, 0, 0) 0.1667:(0, 0, 0) 0.375:(-44.95, 0, 0)~ 0.75:(0, 0, 0)~ |
| right_ear | POSITION | 0:(0.05, 0, 0) 0.1667:(0.05, 0, 0) 0.3333:(0.05, -0.475, 0) 0.5417:(0.04, -0.385, 0)~ 0.75:(0.05, 0, 0)~ |
| right_hind_leg | ROTATION | 0:(0, -2.5, 0) 0.0833:(0, -2.5, 0) 0.25:(-25, -22.5, -17.5)~ 0.375:(-25, -22.5, -17.5)~ 0.5417:(0, -2.5, 0) 0.75:(0, -2.5, 0) |
| right_hind_leg | POSITION | 0:(0, 0, 0) 0.6667:(0, 0, 0) 0.75:(0, 0, 0) |
| left_hind_leg | ROTATION | 0:(0, 0, 0) 0.0833:(0, 0, 0) 0.25:(-25, 25, 22.5)~ 0.375:(-25, 25, 22.5)~ 0.5417:(0, 0, 0) 0.75:(0, 0, 0) |
| left_hind_leg | POSITION | 0:(0, 0, 0) 0.6667:(0, 0, 0) 0.75:(0, 0, 0) |
| tail | ROTATION | 0:(0, 0, 0) 0.125:(0, 0, 0) 0.3333:(15, 0, 0)~ 0.375:(47.5, 0, 0)~ 0.5:(43.33, 0, 0)~ 0.75:(0, 0, 0)~ |
| tail | POSITION | 0:(0, 0, 0) 0.75:(0, 0, 0) |

#### IDLE_HEAD_TILT  length 4 s
| Bone | Channel | Keyframes time:(x, y, z), ~ = CATMULLROM |
|---|---|---|
| body | ROTATION | 0:(0, 0, 0) 0.25:(-62, 0, 0) 0.3333:(-57, 0, 0) 0.7083:(-57, 0, 0) 0.875:(-57, 12, 2) 0.9583:(-57, 5, 1) 1.5417:(-57, 5, 1) 1.7083:(-56.5, -16, -3) 1.7917:(-57, -7.5, -1.5) 2.5417:(-57, -7.5, -1.5) 2.7083:(-57, 11, 2) 2.7917:(-57, 5, 1) 2.9583:(-57, 5, 1) 3.1667:(-57, 5, 1) 3.25:(-57.5, 5, 1) 3.4583:(-60, 5, 0.5) 3.5833:(-60, 5, 0.5) 3.6667:(-39.5, 3.5, 0.5) 3.8333:(10, 0, 0) 3.9167:(0, 0, 0) |
| body | POSITION | 0:(0, 0, 0) 0.1667:(0, 0.7, 0) 0.25:(0, 0, 0) 3.8333:(0, 0, 0) 3.9167:(0, 0, 0) |
| body | SCALE | 0:(1, 1, 1) 3.8333:(1, 1, 1) 3.9167:(1, 1, 1) |
| tail | ROTATION | 0:(55, 0, 0) 0.0833:(55, 0, 0)~ 0.2083:(37.5, 0, 0)~ 0.25:(72.25, 0, 0)~ 0.2917:(72.25, 0, 0) 0.375:(72.25, 0, 0) 0.7083:(72.25, 0, 0) 0.8333:(72.25, -3.5, -19.5)~ 0.9167:(72.25, 1.5, 15)~ 1.0417:(72.25, 0, 0) 1.5417:(72.25, 0, 0) 1.625:(72.25, 2.5, 12.5)~ 1.7083:(72.25, 4.5, 25.5)~ 1.7917:(72.25, -3, -26)~ 1.875:(72.25, 0, 0) 2.5417:(71.75, 0, 0) 2.7083:(71.75, 0, 0) 2.7917:(76.75, 17.5, 17.5) 2.875:(71.75, 0, 0) 3.5833:(71.75, 0, 0) 3.8333:(0, 0, 0) 3.9167:(32.5, 0, 0) 4:(55, 0, 0) |
| tail | POSITION | 0:(0, 0, 0) 0.25:(0, 0.4294, -0.6732) 0.7083:(0, 0.4294, -0.6732) 0.8333:(0, 0.4294, -0.6732) 0.9167:(0, 0.4294, -0.6732) 1.0417:(0, 0.4294, -0.6732) 1.5417:(0, 0.4294, -0.6732) 3.5833:(0, 0.4294, -0.6732) 3.8333:(0, 0, 0) 3.9167:(0, 0, 0) |
| head | ROTATION | 0:(0, 0, 0) 0.25:(54.5, 0, 0) 0.3333:(40, 0, 0) 0.75:(40, 0, 0) 0.9167:(40, 20.5, -11)~ 1:(39.5, 11.5, -6)~ 1.2917:(39.3, 11.5, -6) 1.75:(39.5, 11.5, -6) 1.9167:(36, -28.5, 16.5) 2:(38, -18.5, 10) 2.625:(38, -18.5, 10) 2.7083:(40, 0, 0) 2.7917:(40, 0, 0) 2.9583:(40, 0, 0) 3.1667:(40, 0, 0) 3.25:(42.5, -0.25, 0) 3.5833:(45.5, -0.5, 0) 3.8333:(-20, 0, 0)~ 3.9167:(0, 0, 0) |
| head | POSITION | 0:(0, 0, 0) 0.25:(0, -0.025, -1.975) 0.3333:(0, 0, -2) 0.5833:(0, 0, -2) 0.75:(0, 0, -2) 1.75:(0, 0, -2) 2.7083:(0, 0, -2) 3.5833:(0, 0, -2) 3.8333:(0, -1, 0)~ 3.9167:(0, 0, 0) |
| left_ear | ROTATION | 0:(0, 0, 0) 0.2083:(35, 0, 0) 0.2917:(19, 0, 0) 0.3333:(0, 0, 0) 0.75:(0, 0, 0) 0.9167:(-15, 0, 7.5) 1:(-7.5, 0, -5) 1.0833:(0, 0, 0) 1.6667:(0, 0, 0) 1.75:(-3, 1.5, -17) 1.8333:(0, 0, 0) 1.9167:(-48.75, 0, 5) 2:(-65, 2.5, 0.5) 2.0833:(-45, 0, 0) 2.1667:(-40, 0, 0) 2.5417:(-40, 0, 0) 2.625:(11, 0, 0) 2.7083:(23.25, 0, 3.75) 2.75:(25.5, 2, 6) 2.8333:(10, -0.5, 0.75) 3.625:(10, -0.5, 0.75) 3.7083:(-25, 0.25, -1) 3.7917:(-19, 0, -1) 3.8333:(2.5, 0.2, -0.5) 3.9167:(0, 0, 0) |
| left_ear | POSITION | 0:(-0.025, 0, 0) 0.2083:(-0.125, -0.6553, 0.4589) 0.3333:(-0.025, 0, 0) 0.75:(-0.025, 0, 0) 0.9167:(-0.0502, -0.1915, -0.0518) 1:(-0.2423, -0.1025, 0.0261) 1.0833:(-0.025, 0, 0) 1.6667:(-0.025, 0, 0) 1.75:(-0.125, -0.325, 0) 1.8333:(-0.025, 0, 0) 2:(-0.025, -0.75, 0) 2.0833:(-0.025, -0.75, 0) 2.1667:(-0.025, -0.75, 0) 2.4167:(-0.025, -0.75, 0) 2.5417:(-0.025, -0.75, 0) 2.625:(-0.025, -0.375, 0) 2.75:(-0.025, -0.375, 0.25) 2.7917:(-0.025, -0.375, 0) 2.8333:(-0.025, -0.125, 0) 3.625:(-0.025, -0.125, 0) 3.9167:(-0.025, 0, 0) |
| right_ear | ROTATION | 0:(0, 0, 0) 0.1667:(35, 0, 0) 0.3333:(0, 0, 0) 0.75:(0, 0, 0) 0.9167:(-22.342, -2.5587, 5.4476) 1:(-11.17, -1.28, -21.03) 1.0833:(-4.1101, 3.0703, -18.144) 1.125:(-0.0844, 3.027, -9.5338) 1.5417:(-0.0844, 3.027, -9.5338) 1.6667:(0, 0, 0) 1.75:(-1.5, 1, -14.5) 1.8333:(0, 0, 0) 1.9167:(-45, 0, 5) 2:(-60, 1, 5) 2.0833:(-50, 0, 0) 2.5417:(-50, 0, 0) 2.625:(16, 0, 0) 2.7083:(25.5, 0, 0) 2.7917:(5.25, 0.5, -2) 2.8333:(8.5, 1, -4) 3.625:(8.5, 1, -4) 3.7083:(-37.5, 0.25, -1.5) 3.7917:(-23.5, 0, -1) 3.8333:(10, 0.25, -0.5) 3.9167:(0, 0, 0) |
| right_ear | POSITION | 0:(0.025, 0, 0) 0.2083:(0.075, -0.3588, 0.1769) 0.3333:(0.025, 0, 0) 0.75:(0.025, 0, 0) 0.875:(0.13, -0.15, 0) 0.9167:(0.125, -0.2, 0) 1:(0.0182, -0.4258, 0.0581) 1.0833:(0.02, -0.34, 0.02) 1.125:(0.025, -0.175, 0) 1.5417:(0.025, -0.175, 0) 1.6667:(0.025, 0, 0) 1.75:(0.025, 0, 0) 1.8333:(0.025, 0, 0) 1.9167:(0.055, -0.5, 0) 2:(0.075, -0.75, 0) 2.0833:(0.025, -0.75, 0) 2.5417:(0.025, -0.75, 0) 2.5833:(0.025, -0.5, 0) 2.625:(0.025, 0, 0) 2.7083:(0.025, -0.25, 0) 2.7917:(0.025, 0, 0) 2.8333:(0.025, -0.25, 0) 3.625:(0.025, -0.25, 0) 3.9167:(0.025, 0, 0) |
| right_front_leg | ROTATION | 0:(0, 0, 0) 0.1667:(0, 0, 0) 0.3333:(60, 0, 0) 0.4167:(40, 0, 0) 0.7083:(40, 0, 0) 0.8333:(39, 12.5, 6.16) 0.9167:(39, 12.5, -21.34) 1:(40, 10, -7.5) 1.0833:(40, 0, 0) 1.6667:(40, 0, 0) 1.75:(36.5, 21.5, 1.5) 1.8333:(38.5, 20, -0.5) 1.875:(41, 20, -0.5) 3.5:(41, 20, -0.5) 3.5833:(40, 0, 0) 3.75:(12.5, 0, 0) 3.8333:(0, 0, 0) 3.9167:(0, 0, 0) |
| right_front_leg | POSITION | 0:(0, 0, 0) 0.1667:(0, 0, 0) 0.3333:(0, 0.6, 0) 0.4167:(0, 0.6, 0) 0.7083:(0, 0.6, 0) 1:(0, 0.6, 0) 1.0833:(0, 0.6, 0) 1.6667:(0, 0.6, 0) 3.5833:(0, 0.6, 0) 3.75:(0.0153, 0.3728, 0.0167) 3.8333:(0, 1, -0.5) 3.9167:(0, 0, 0) |
| left_front_leg | ROTATION | 0:(0, 0, 0) 0.2083:(0, 0, 0) 0.375:(52.5, 0, 0) 0.4583:(40, 0, 0) 0.7083:(40, 0, 0) 0.8333:(40, 9, -18.5) 0.9167:(39.5, 5, -14.5) 1:(40, 0, -10) 1.0833:(40, 0, 0) 1.6667:(40, 0, 0) 1.75:(40, -24.5, -7) 1.8333:(39.5, -15.5, 0.5) 1.875:(42, -15.5, 0.5) 3.5:(42, -15.5, 0.5) 3.5833:(40, 0, 0) 3.75:(15.5, 0, 0) 3.8333:(0, 0, 0) 3.9167:(0, 0, 0) |
| left_front_leg | POSITION | 0:(0, 0, 0) 0.2083:(0, 0, 0) 0.375:(0, 0.8, 0) 0.4583:(0, 0.6, 0) 0.7083:(0, 0.6, 0) 1:(0, 0.6, 0) 1.0833:(0, 0.6, 0) 1.6667:(0, 0.6, 0) 3.5833:(0, 0.6, 0) 3.75:(0, 0.5, 0) 3.8333:(0, 1, -0.5) 3.9167:(0, 0, 0) |
| frontlegs | POSITION | 0:(0, 0, 0) 0.3333:(0, -0.4193, -0.2723) 3.5833:(0, -0.4193, -0.2723) 4:(0, 0, 0) |
| right_hind_leg | ROTATION | 0:(0, -2.5, 0) |
| right_hind_leg | POSITION | 0:(0, 0, 0) |



---

## Worked examples

1. **Cow walk.** Adult cow, `walkAnimationPos` 2.0, `walkAnimationSpeed` 0.5: `cos(0.6662 x 2) x 1.4 x 0.5 = 0.1653`, so `right_hind_leg.xRot` = `left_front_leg.xRot` = 0.1653 and `left_hind_leg.xRot` = `right_front_leg.xRot` = -0.1653 (the phase pi flips the sign).
2. **Chicken wings.** `flap` = 0, `flapSpeed` = 1: `w = (sin 0 + 1) x 1 = 1`; `right_wing.zRot = 1`, `left_wing.zRot = -1`.
3. **Horse standing on its hind legs.** Adult horse, `stand` = 1, `eat` = 0, `feed` = 0, pitch 0, `state.yRot` = 10 deg, `walkAnimationSpeed` 0, `age` 0, `ageScale` 1, `animateTail` false, not in water. `yaw` = 10; `head_parts.xRot = 1 x 0.2617994 = 0.2617994`; `head_parts.yRot = 1 x 10 D = 0.1745329`; `head_parts.y = 4 + lerp(0, lerp(1, 0, -8), 7) = 4 + (-8) = -4`; `head_parts.z = lerp(1, -12, -4) = -4`; `body.xRot = -0.7853982`; `left_front_leg.y = 14 - 12 = 2`, `.z = -10 + 4 = -6` (and the right front leg takes the same y and z); `a = 0.2617994`, `w = cos(0 + pi) = -1`, `x0 = -1.0471976`: `fl = (-1.0471976 + -1) x 1 = -2.0471976`, `fr = (-1.0471976 - (-1)) x 1 = -0.0471976`; `left_hind_leg.xRot = right_hind_leg.xRot = 0.2617994`; `tail.xRot = 0 + 0.5235988 + 0 = 0.5235988`, `tail.yRot = 0`. These are pivots before the layer scaling of 1.1.
4. **Scaling.** The `donkey` layer is scaled 0.87: root offset (0, `24.016 x 0.13` = 3.12208, 0), scale 0.87. The body pivot (0, 11, 5) lands at (0, 11 x 0.87 + 3.12208, 5 x 0.87) = (0, 12.69208, 4.35). The `horse` layer (1.1): root offset (0, -2.4016, 0), body pivot y = 11 x 1.1 - 2.4016 = 9.6984.
5. **Baby donkey head.** `stand` = 0, `eat` = 0, `feed` = 0 for any `age`, `state.xRot` = 25 deg: the baby sets `state.xRot = -30`, `pitch2 = -0.5235988`; `head_parts.xRot = 0 + 0 + 1 x ((0.5235988 - 0.5235988) + 0) = 0`. With `stand` = 1: `1 x (0.2617994 - 0.5235988) = -0.2617994`.
6. **Camel head.** `state.yRot` = 40 deg, `state.xRot` = 10 deg, `jumpCooldown` = 22: `yaw` = clamp(40, -30, 30) = 30 deg, `head.yRot = 30 D = 0.5235988`; `pitch` = clamp(10, -25, 45) = 10; add `45 x 22 / 55` = 18, gives 28 (inside -25..70): `head.xRot = 28 D = 0.4886922`.
7. **Happy ghast tentacle.** `ageInTicks` = 10, tentacle index 2: `0.2 x sin(10 x 0.3 + 2) + 0.4 = 0.2 x sin(5) + 0.4 = 0.2082`. With no harness the body scale stays 1; with a harness it is 0.9375. Baby ghast root: `y = (-72.048 x 0.2375) + 24.016 x 0.7625 = 1.2008`, scale `4 x 0.2375 = 0.95`; its body pivot (0, 16, 0) lands at (0, 16 x 0.95 + 1.2008, 0) = (0, 16.4008, 0).
8. **Jeb sheep.** `ageInTicks` = 30.5: `i = 30`, `step = 30 div 25 = 1`, `c0` = colours[1] (orange, 0xFFBA6015), `c1` = colours[2] (magenta, 0xFF953A8D), `t = ((30 mod 25) + 0.5) / 25 = 0.22`. Red: 186 + floor(0.22 x (149 - 186)) = 186 + floor(-8.14) = 177 (0xB1); green: 96 + floor(0.22 x (58 - 96)) = 96 + floor(-8.36) = 87 (0x57); blue: 21 + floor(0.22 x (141 - 21)) = 21 + floor(26.4) = 47 (0x2F); alpha 255. Result 0xFFB1572F. A sheep dyed white draws the undercoat only when jeb; white wool is the fixed 0xFFE6E6E6.
9. **Baby pig with a saddle.** The state carries a saddle item with a present asset id; the layer finds `isBaby` true and `babyModel` null and draws nothing.
10. **Llama carpets.** Adult llama with a carpet item: layer type `llama_body`, asset of the item, adult decor model (grow 0.5). Baby llama with a carpet: step 1 fails (baby), step 2 fails (not a trader): nothing. Baby trader llama: asset `trader_llama_baby`, baby decor model (grow 0.2).

## Validation

Implementers can check the geometry tables against these counts (parts, cuboids, texture size) and the invariants below.

| Layer id | Parts | Cuboids | Texture (W x H) |
|---|---|---|---|
| `cow` | 6 | 10 | 64 x 64 |
| `cold_cow` | 8 | 11 | 64 x 64 |
| `warm_cow` | 6 | 12 | 64 x 64 |
| `cow_baby` | 6 | 9 | 64 x 64 |
| `pig` | 6 | 7 | 64 x 64 |
| `pig_saddle` | 6 | 7 | 64 x 64 |
| `cold_pig` | 6 | 8 | 64 x 64 |
| `pig_baby` | 6 | 7 | 32 x 32 |
| `sheep` | 6 | 6 | 64 x 32 |
| `sheep_wool` | 6 | 6 | 64 x 32 |
| `sheep_baby` | 6 | 6 | 64 x 32 |
| `chicken` | 8 | 8 | 64 x 32 |
| `cold_chicken` | 8 | 10 | 64 x 32 |
| `chicken_baby` | 5 | 8 | 16 x 16 |
| `goat` | 9 | 12 | 64 x 64 |
| `goat_baby` | 11 | 12 | 64 x 64 |
| `horse` | 12 | 12 | 64 x 64 |
| `horse_armor` | 12 | 12 | 64 x 64 |
| `horse_saddle` | 19 | 19 | 64 x 64 |
| `horse_baby` | 10 | 10 | 64 x 64 |
| `skeleton_horse`, `zombie_horse` (same builder) | 12 | 12 | 64 x 64 |
| `undead_horse_armor` | 12 | 12 | 64 x 64 |
| `skeleton_horse_saddle`, `zombie_horse_saddle` | 19 | 19 | 64 x 64 |
| `skeleton_horse_baby`, `zombie_horse_baby` | 10 | 10 | 64 x 64 |
| `donkey` | 14 | 14 | 64 x 64 |
| `mule` | 14 | 14 | 64 x 64 |
| `donkey_saddle` | 21 | 21 | 64 x 64 |
| `mule_saddle` | 21 | 21 | 64 x 64 |
| `donkey_baby` | 15 | 10 | 64 x 64 |
| `llama` | 8 | 11 | 128 x 64 |
| `llama_decor` | 8 | 11 | 128 x 64 |
| `llama_baby` | 8 | 11 | 64 x 64 |
| `llama_baby_decor` | 8 | 11 | 64 x 64 |
| `llama_spit` | 1 | 7 | 64 x 32 |
| `camel` | 10 | 12 | 128 x 128 |
| `camel_baby` | 9 | 11 | 64 x 64 |
| `camel_saddle` | 13 | 23 | 128 x 128 |
| `happy_ghast` | 10 | 10 | 64 x 64 |
| `happy_ghast_baby` | 11 | 11 | 64 x 64 |
| `happy_ghast_harness` | 2 | 2 | 64 x 64 |
| `happy_ghast_baby_harness` | 2 | 2 | 64 x 64 |
| `happy_ghast_ropes` | 10 | 10 | 64 x 64 |
| `happy_ghast_baby_ropes` | 11 | 11 | 64 x 64 |
| `rabbit` | 13 | 9 | 64 x 64 |
| `rabbit_baby` | 17 | 9 | 32 x 32 |

Invariants and checks:

1. **Part names.** Every model that extends `QuadrupedModel` (cow, pig, sheep, goat and their baby and cold, warm variants) must contain the six names `head`, `body`, `right_hind_leg`, `left_hind_leg`, `right_front_leg`, `left_front_leg` at the root; a missing name is an error at bake time (part 1 §1.5, §3.4). Equine models need `body`, `head_parts`, four legs and `body/tail` (the baby donkey differs, 8.3); camel `body`, `body/head`; rabbit `body`, `body/head`; happy ghast `body`, `body/tentacle0` .. `body/tentacle8`; llama `head`, `right_chest`, `left_chest` and four legs.
2. **Feet on the ground line.** For the unscaled quadrupeds the bottom of each leg cuboid (pivot y + origin y + height) is 24: cow 12 + 0 + 12 = 24, sheep 12 + 0 + 12 = 24, pig 18 + 0 + 6 = 24, llama 10 + 0 + 14 = 24, adult camel 1 + 2 + 21 = 24, baby camel 11.5 - 0.5 + 13 = 24, baby cow 18 + 0 + 6 = 24, baby pig 22 + 0 + 2 = 24, baby sheep 19 + 0 + 5 = 24, baby llama 16.5 - 0.5 + 8 = 24, baby goat 19.5 - 0.5 + 5 = 24, adult goat hind legs 14 + 4 + 6 = 24 (the front legs 14 + 0 + 10), chicken 19 + 0 + 5 = 24; the horse legs end at 14 - 1.01 + 11 = 23.99 (the cuboid origin is -1.01). Scaling keeps y = 24.016 fixed.
3. **Mirror pairs.** In the cow, pig and horse the right leg is not mirrored and the left leg is (part 1 §3.4 passes the flags); the **sheep** is the opposite (right legs mirrored); in the baby horse the left leg boxes are not mirrored and the texture offsets differ per leg (each baby leg has its own offset).
4. **Texture size.** Offsets plus extents must fit inside the layer texture: for each cuboid, `u + 2d + 2w <= W` and `v + d + h <= H` (a necessary check on the tables).
5. **Identical layers.** `cow` and `mooshroom`; `cow_baby`, `cold_cow_baby`, `warm_cow_baby` and `mooshroom_baby`; `llama` and `trader_llama`; `llama_baby` and `trader_llama_baby`; `camel_saddle` and `camel_husk_saddle`; `donkey_baby` and `mule_baby`; `sheep_baby` and `sheep_baby_wool`; `horse_baby`, `skeleton_horse_baby` and `zombie_horse_baby` (the baby horse mesh is built with `NONE` for each) have identical part trees; `donkey` and `mule` differ only in the scaling.
6. **Animation lengths.** `CAMEL_WALK` 1.5 s looping, `CAMEL_SIT` 2 s, `CAMEL_SIT_POSE` 1 s, `CAMEL_STANDUP` 2.6 s, `CAMEL_DASH` 0.5 s looping, `CAMEL_IDLE` 4 s; baby: walk 1.5, standup 2.6, dash 0.5, idle 4, sit 2, sit pose 0, **all looping**; rabbit and baby rabbit: `HOP` 0.75 s looping, `IDLE_HEAD_TILT` 4 s not looping.
7. **Worked examples** 1 to 10 are tests of the formulas.

## Open questions

1. **Rotation order and cuboid face orientation.** `ModelPart.translateAndRotate` composes `rotationZYX(zRot, yRot, xRot)`; the order in which it acts on vertices, and the exact face orientation of the unwrap, are open in parts 1 and 3 and affect every model here (notably the cold cow horns, the goat nose, the rabbit haunches and the baby donkey and camel pieces, which use two or three rotated axes). A reference render settles both.
2. **Baby happy ghast harness double transform.** `createHarnessLayer(true)` already applies `BABY_TRANSFORMER`, and the registry applies it again, giving a root scale 0.225625 instead of 0.95 (section 11.3). That is what the bytecode computes; whether it is intended is unknown. A harness cannot be put on a baby in the game logic read elsewhere (19, 44 part 4), so the layer is likely never visible.
3. **Entity-side animation inputs.** The meaning and ranges of `eatAnim`, `standAnim`, `mouthAnim`, `tailCounter`, `headEatAngleScale`, `headEatPositionScale`, `jumpCompletion`, the camel `jumpCooldown` units (ticks) and the entity `AnimationState` triggers were not read (entity classes are out of scope; see 19 and 44 part 4). The formulas here take them as inputs in [0, 1] (equine animations) and ticks (camel).
4. (Resolved: `ageScale` overrides were read, section 1.6.) Only the entity `scale` attribute value (1 unless changed by game logic) remains an input, not read here.
5. **`CowModel.BABY_TRANSFORMER` is unused.** The static field exists and no registry entry of this document applies it (read from `LayerDefinitions`); other code outside the artifact classes read could, but none was found. (inferred: unused)
6. **Looping animation of length 0.** `CAMEL_BABY_SIT_POSE` has length 0 and is marked looping. The sampling rule of part 1 §5 takes the time modulo the length for a looping animation; a modulo by 0 yields not-a-number in float arithmetic, and what the engine then displays (probably the first keyframe) was not read. The animation has a single keyframe set (a static pose), so the intended result is that pose.
7. **Variant data.** The set of `cow_variant`, `pig_variant`, `chicken_variant` entries, their model types, spawn conditions and texture assets are data (RS3, 22, 23); this document only reads their model type and texture paths.
8. **Texture files.** Existence and content of every texture path named here (including `horse_darkbrown*`, `rabbit_caerbannog*`, the equipment textures) belongs to the extraction tool (22). Layer-type directory names under `entity/equipment/` follow the string ids of section 1.3.
9. **Order argument.** The `order` integer (0, 1, 2) passed to the submit collector decides draw order of translucent and layered submissions within a frame; its exact semantics (sorting key within a batch) were not read; part 1 §8.1 treats it as a draw-order key.
10. **Mooshroom block rendering.** The `BlockModelRenderState` of the mushroom is produced by the block model resolver from the block state and a display context; its geometry (a standard mushroom cross model) comes from the block models (12, 14), not from this document. Whether the resolver applies a display transform for `BlockDisplayContext.create()` was not read.
11. **`ColorLerper` brightness for `MUSIC_NOTE`.** Not used here; the jeb sheep uses only the `SHEEP` type (read).
12. **Participation of `HorseModel` in `EquineSaddleModel` hiding.** Only the two rein lines are hidden when not ridden (read); everything else of the saddle mesh is drawn with the saddle texture. That the texture is transparent over the body is an assumption about the data (the PNG).
13. **Items not read.** Inferred items are exactly these: the unused status of `CowModel.BABY_TRANSFORMER` (question 5), the purpose of the Mooshroom mushroom scale and translate (14) and the llama spit pivot meaning (15). Nothing was taken from recall. Items read from the artifact but only through the generated tables are covered by question 16. Everything else not read is listed above as an open question.
14. **Mooshroom mushroom pose purpose (inferred).** The operations (scale -1,-1,1 and translate -0.5 x3) were read; that they cancel the entity flip and centre the block is deduced. Nothing in the classes read states the intent.
15. **Llama spit pivot (inferred).** The pose chain was read; that model +y is world up and the pivot is the projectile position plus 0.15 is deduced from no flip, offset or scale being present.
16. **Table verification coverage.** Geometry and keyframe tables came from a throw-away script (not in the repository). The tables were machine-generated and spot-checked by the reader. No per-cuboid cross-check was done for the `pig_saddle` and `sheep_wool` grow values, the donkey saddle table, or the camel saddle, reins and bridle tables; implementers should treat those as machine-generated and unverified by hand.
17. **Saddle texture over the chest area.** The `donkey_saddle` and `mule_saddle` layers always draw the chest cuboids (8.4). Whether the saddle texture is transparent over the chest unwrap area (so nothing shows on an animal without a chest) was not checked: the equipment texture images were not decoded in this round.
18. **Unverified by independent review.** A review pass did not cover: the Appendix A keyframes (CamelAnimation, CamelBabyAnimation, RabbitAnimation, BabyRabbitAnimation), per-layer geometry cross-checks of cold cow, warm cow, llama, llama_baby, camel, camel_saddle, rabbit and rabbit_baby (see question 16), the Mooshroom mushroom layer pose list, the llama decor layer rules, the layer-type ordinals in section 1.3 and the shadow radii in section 1.5. These remain owed to the next reviewer; this fix round re-read only the `ageScale` uses in `SheepModel` and `AbstractEquineModel` (state field read directly, not defaulted).
