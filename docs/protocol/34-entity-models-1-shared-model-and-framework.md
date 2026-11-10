# Entity models and renderers, part 1: shared model, framework classes, animation engine, render pipeline and the master index

| Item | Value |
|---|---|
| Covers | (a) How a model is documented in parts 2 to 9 (part tree, cuboids, UV unwrap, pose pivots, mirror, deformation, scale), the per-entity record schema, the stable ids of model layers, animations and textures, and the master index of all 161 entity types mapped to the part (2 to 9) that documents each. (b) The framework classes: `net.minecraft.client.model` root, `model.geom` and `model.geom.builders`, the keyframe animation engine `net.minecraft.client.animation`, and the entity renderer framework in `renderer.entity` (dispatcher, registration table, base renderers, render states, generic layers) together with the generic pipeline pieces the entity renderers submit to: model submission, hurt and death, shadow, name tag, leash, fire and hitbox. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in the README) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of shader text with `unzip -p`, with no execution. The registration table (6.2) and the model-layer table (Appendix A) were extracted from the static initializers by a script that only reads `javap` output. File counts use `unzip -Z1 ... \| grep -v '/$'`. |
| Packages | Read from the class names of the artifact: `BabyModelTransform`, `HumanoidModel`, `QuadrupedModel`, `AnimationUtils`, `ArmedModel`, `HeadedModel`, `AdultAndBabyModelPair` and `Model`/`EntityModel` are in `net.minecraft.client.model`; `ModelPart`, `PartPose`, `ModelLayers`, `LayerDefinitions`, `EntityModelSet` in `model.geom`; `MeshDefinition`, `PartDefinition`, `CubeListBuilder`, `CubeDefinition`, `CubeDeformation`, `LayerDefinition`, `MeshTransformer` in `model.geom.builders`; `SpearAnimations` in `model.effects`; the per-entity model classes in subpackages (`model.animal.*`, `model.monster.*`, `model.npc`, `model.object.*`, `model.player`, `model.effects`); `ArmorModelSet` and the renderers in `renderer.entity` (layers in `renderer.entity.layers`, render states in `renderer.entity.state`); the keyframe engine in `animation` and the keyframe tables (`*Animation` classes of 5.6) in `animation.definitions`. |
| Round | RS17, part 1 of 9 (GAP-25 of `../design/README.md` Part 5). Parts 2 to 9 (`34-entity-models-2-...` to `34-entity-models-9-...`) hold the per-entity geometry; the allocation of the 161 entity types to them is in section 10 (part 2 humanoid-base mobs, 3 villagers, illagers, golems and miscellaneous, 4 farm and ridable land animals, 5 wild and companion animals and small creatures, 6 creeper, enderman, arthropods, slimes, warden, breeze, phantom, guardians and shulker, 7 Nether and End mobs and bosses, 8 aquatic mobs, nautilus family and boats, 9 entities without a living-mob model). |
| Data versus code | Textures (`textures/entity/**`, 759 files in the artifact), equipment assets (`equipment/*.json`, 45 files) and `items`/`models` JSON are DATA extracted by the tool (22). This document specifies the engines that interpret them and every piece of CODE-defined content: geometry, animation, renderer behaviour and the model-layer registry. It does not tabulate data rows. |
| Out of scope | The player model and `AvatarRenderer` (12 §7), `CapeLayer` and `Deadmau5EarsLayer` (12 §7.6 only), the block-entity renderers, the item renderer (12 §8) and the particle engine. `HumanoidModel` geometry and pose code is in 12 §7.4 and §7.5; this document adds only what 12 does not state (3.7) and `SpearAnimations` (3.8). |

Section references use "12 §7.4", "14 §5.3", "18 §2", "21 §2", "22", "23" for other documents, and "§3.2" for sections of this one. "Read" means read in the artifact this round. "(inferred)" marks values deduced from what was read. "(recalled, not verified)" marks statements not read; each is listed in Open questions. Class and method names in backticks say where a fact was read and are not a design.

## 0. Reader's map

| Question | Section |
|---|---|
| What are the axes and units of a model, and how does a cuboid become six textured faces? | 1.1 to 1.4 |
| How are parts posed, scaled and drawn? | 1.5 |
| How do the builders compose a model, and what do deformation, baby transform and scaling do? | 2 |
| What do the shared model base classes (quadruped, headed, armed, humanoid constants) do? | 3 |
| How are model layers named and counted, and how do ids work? | 4 |
| How does keyframe animation work, with exact interpolation? | 5 |
| How is an entity turned into pixels: dispatch, render state, pose order, death, baby, overlay, light? | 6 |
| Shadow, name tag, leash, fire, hitbox | 7 |
| Generic layers: equipment, held item, head, emissive, energy swirl, stuck items | 8 |
| What does the per-entity record look like, and which part documents which entity? | 9 and 10 |
| Worked examples and checks | 11 |
| Gaps | 12 |

---

## 1. Model conventions

### 1.1 Axes and units

- A model is a tree of **parts**. All lengths in a model definition are in **pixels** (1/16 block). A vertex is divided by 16 when it is drawn (`ModelPart$Vertex` scale constant 16, `ModelPart.translateAndRotate` divides the part position by 16).
- **Model space** (the space of a root part, before the renderer's flip): x grows towards the mob's **left**, y grows **down**, z grows towards the **back**: the front of a cuboid is its minimum-z face. This corrects the wording "z towards the front" in 12 §7.4: the face that carries the "front" texture rectangle is the `NORTH` face, which is the minimum-z side (1.3), and the entity looks towards model −z.
- The renderer turns model space into world space by the sequence in 6.5: rotate about Y by 180° minus the body yaw, scale by (−1, −1, 1), then translate by (0, −1.501, 0) blocks (`EntityModel.MODEL_Y_OFFSET` = −1.501; 1.501 blocks = 24.016 model pixels). A model point at model height y_m (pixels) therefore sits at 1.501 − y_m/16 blocks above the entity's feet (times the entity scale). The feet of a standard mob model are at y_m = 24.
- Angles: all rotations in a model (`xRot`, `yRot`, `zRot`) are radians. A part's rotation is the quaternion `rotationZYX(zRot, yRot, xRot)` (read: `ModelPart.translateAndRotate` builds it that way and multiplies it into the pose). The order in which the three axis rotations act on a vector is not stated here: the only thing read is that `ModelPart.rotateBy` pairs `Matrix3f.rotationZYX` with `getEulerAnglesZYX` (the joml library is not in the artifact; Open question 3). Implementers settle the order with a reference render of a part with two non-zero angles; see 1.5 for the stacking.
- Degrees in code: the helper `KeyframeAnimations.degreeVec` converts degrees to radians with the constant 0.017453292.

### 1.2 How a model is documented (template for parts 2 to 9)

Each model in the sibling documents gives:

1. **Header row**: model class, layer id (4.2), texture size (width x height) from `LayerDefinition.create(mesh, w, h)`, any `MeshTransformer` applied (baby transform, scaling), and whether the mesh is shared with another layer (for example an adult and its baby share nothing; a saddle layer reuses the body mesh with a deformation).
2. **Part tree table**, one row per part in creation order, with columns: part path (`root/body/head`), pose pivot (x, y, z) in pixels, pose rotation (x, y, z) in radians, pose scale if not 1, then for each cuboid of the part: texture offset (u, v), origin (ox, oy, oz) relative to the part pivot, size (w, h, d), deformation grow (gx, gy, gz) if not 0, mirror flag, texture scale if not 1, and the visible-face set if not all six.
3. **Animation notes**: which parts `setupAnim` drives and the formula (angles in radians, inputs from the render state, 6.3), and which keyframe animation definitions apply (5).
4. **Layers and variants**: the layer list of the renderer (8), variant textures, baby model, saddle or armor models.

Part names are looked up by string from the parent (`getChild`), and a missing name is an error (`NoSuchElementException`); the names used by the shared code are in 2.6.

### 1.3 A cuboid: origin, size, deformation, mirror, UV (`ModelPart$Cube`, `CubeDefinition`)

A cuboid is defined by: texture offset (u, v) (integers after conversion), origin (x, y, z) and size (w, h, d) in pixels relative to the part pivot, a **deformation** (gx, gy, gz), a **mirror** flag, a **texture scale** (su, sv, default 1, 1) and a set of **visible faces** (default all six). It is baked against the layer's texture size (W, H):

1. Texture divisor: Tw = W x su, Th = H x sv. The offset (u, v) is the integer part (truncation) of the authored value. (`CubeDefinition.bake`: it passes `W x su` and `H x sv` as the size the polygon divides by.)
2. Geometry: x0 = x − gx, y0 = y − gy, z0 = z − gz, x1 = x + w + gx, y1 = y + h + gy, z1 = z + d + gz. If mirror, x0 and x1 are swapped. (The unexpanded `minX..maxZ` fields kept for picking are x, y, z and x + w, y + h, z + d, **without** the grow.)
3. Eight corners: A = (x0, y0, z0), B = (x1, y0, z0), C = (x1, y1, z0), D = (x0, y1, z0), E = (x0, y0, z1), F = (x1, y0, z1), G = (x1, y1, z1), H = (x0, y1, z1).
4. Texture strip coordinates (pixels): U0 = u, U1 = u + d, U2 = u + d + w, U3 = u + d + 2w, U4 = u + 2d + w, U5 = u + 2d + 2w; V0 = v, V1 = v + d, V2 = v + d + h. (U3 and U4 are different values unless d = w.)
5. Faces, in this creation order, each only if its direction is in the visible set. A face is listed with its four corners in vertex order, then its rectangle (minU, minV, maxU, maxV):

| Direction | Corners (vertex 0..3) | minU | minV | maxU | maxV | Role in the standard unwrap |
|---|---|---|---|---|---|---|
| `DOWN` (min y, i.e. the **top** of a part because y is down) | F, E, A, B | U1 | V0 | U2 | V1 | top rectangle |
| `UP` (max y, the **bottom**) | C, D, H, G | U2 | V1 | U3 | V0 | bottom rectangle; the rectangle is read from V1 up to V0 (flipped vertically) |
| `WEST` (min x) | A, E, H, D | U0 | V1 | U1 | V2 | side on the part's own right (model −x) |
| `NORTH` (min z) | B, A, D, C | U1 | V1 | U2 | V2 | **front** |
| `EAST` (max x) | F, B, C, G | U2 | V1 | U4 | V2 | side on the part's left (model +x) |
| `SOUTH` (max z) | E, F, G, H | U4 | V1 | U5 | V2 | **back** |

6. Texture coordinates of a face's four vertices: vertex 0 = (maxU / Tw, minV / Th), vertex 1 = (minU / Tw, minV / Th), vertex 2 = (minU / Tw, maxV / Th), vertex 3 = (maxU / Tw, maxV / Th). (The polygon constructor computes an inset of 0 / Tw and 0 / Th, which is zero in this build, so faces use their rectangles exactly.)
7. Mirror (`mirror` true): each face's four vertices are reversed in order (swap 0 with 3 and 1 with 2) so winding stays correct, and for faces on the X axis (`WEST`, `EAST`) the stored normal is replaced by the opposite direction's normal. Mirroring only swaps the x0/x1 coordinates of the corners; the texture rectangles of the six faces do not move. Hence a mirrored cuboid shows the same texture region as an unmirrored one with the image flipped left to right (inferred from the geometry).
8. Normals: the unit vector of the face direction (`DOWN` (0, −1, 0), `UP` (0, 1, 0), `NORTH` (0, 0, −1), `SOUTH` (0, 0, 1), `WEST` (−1, 0, 0), `EAST` (1, 0, 0)), transformed by the part's pose matrix when drawn.
9. Draw: each vertex is `pose matrix x (x/16, y/16, z/16)`, sent with colour, texture (u, v), overlay, light and the transformed normal (`ModelPart$Cube.compile`).

Strip size: a cuboid occupies 2d + 2w pixels horizontally and d + h vertically from (u, v), matching 14 §5.3 (whose face names use the opposite vertical convention: the "top (+y)" rectangle of 14 §5.3 is the `DOWN` face above). The table above is the authoritative orientation; 14 §5.3 Open question 4 is answered by it.

Worked example (V1 in 11): the humanoid head, texture 64 x 64, offset (0, 0), origin (−4, −8, −4), size 8 x 8 x 8: U0..U5 = 0, 8, 16, 24, 24, 32; V0..V2 = 0, 8, 16. Faces: `DOWN` = (8, 0)-(16, 8); `UP` = (16, 8)-(24, 0) read upward; `WEST` = (0, 8)-(8, 16); `NORTH` (front) = (8, 8)-(16, 16); `EAST` = (16, 8)-(24, 16); `SOUTH` (back) = (24, 8)-(32, 16). The front's vertex at model x = +4, y = −8 (a top corner on the mob's left) has texture (16/64, 8/64) = (0.25, 0.125); the vertex at x = −4, y = 0 has (8/64, 16/64) = (0.125, 0.25).

### 1.4 Cuboid builder entry points (`CubeListBuilder`)

A `CubeListBuilder` keeps a **current texture offset** (default (0, 0)) and a **current mirror flag** (default false); `texOffs(u, v)` sets the offset, `mirror(b)` (or `mirror()` = true) sets the flag, and both stay in force for later `addBox` calls on the same builder. Every `addBox` form appends one cuboid built with the current offset and mirror. The forms differ only in what they let the author specify; unspecified values are: deformation = none (0, 0, 0), texture scale (1, 1), faces = all six, comment = none.

| Form | Arguments |
|---|---|
| `addBox(x, y, z, w, h, d)` | float origin and size |
| `addBox(x, y, z, w, h, d, deformation)` | adds a `CubeDeformation` |
| `addBox(x, y, z, w, h, d, mirror)` | per-cuboid mirror override (does not change the builder's flag) |
| `addBox(x, y, z, w, h, d, deformation, su, sv)` | adds a texture scale pair |
| `addBox(x, y, z, w, h, d, faceSet)` | restricts to the given directions |
| `addBox(comment, x, y, z, w, h, d[, deformation])` | same with a name (the comment is not used when drawing) |
| `addBox(comment, x, y, z, w_int, h_int, d_int, deformation, u, v)` and the no-deformation int form | integer sizes with an explicit offset, which also **sets** the current offset |

`CubeDeformation(g)` = (g, g, g); `CubeDeformation(gx, gy, gz)`; `extend(e)` returns a new deformation with e added to each component; `NONE` = 0. Deformation grows the box on both sides of each axis (1.3 step 2) and does not move the texture rectangles.

### 1.5 Parts: pose, transform stacking and drawing (`PartPose`, `ModelPart`)

A `PartPose` has nine floats: position (x, y, z), rotation (xRot, yRot, zRot) and scale (xScale, yScale, zScale). Constructors: `offset(x, y, z)` (rotation 0, scale 1), `rotation(rx, ry, rz)` (position 0), `offsetAndRotation(x, y, z, rx, ry, rz)` (scale 1), `ZERO`. `translated(dx, dy, dz)` adds to the position only; `scaled(s)` (returns the same pose when s = 1) and `scaled(sx, sy, sz)` multiply the **position** and the **scale** components by the factors (rotation unchanged); `withScale(s)` replaces the scale values.

A baked `ModelPart` holds a list of cuboids, a map of named children, the current pose fields (x, y, z, xRot, yRot, zRot, xScale, yScale, zScale, all public and writable), `visible` (default true) and `skipDraw` (default false) and the **initial pose** (the definition's pose). `resetPose()` copies the initial pose into the current fields; `Model.resetPose()` does this for every part of the tree. The default `Model.setupAnim(state)` just calls `resetPose()`; every model's `setupAnim` therefore starts from the definition pose and overwrites or adds to it each frame, so animation is stateless.

Drawing a part (`ModelPart.render`): if not `visible`, nothing (children included). If the part has no cuboids and no children, nothing. Otherwise: push the matrix, apply **translateAndRotate**, draw the part's own cuboids unless `skipDraw` (children still draw), draw each child recursively, pop. **translateAndRotate** multiplies, in order on the current matrix: translate by (x/16, y/16, z/16); if any rotation is non-zero, rotate by the quaternion `rotationZYX(zRot, yRot, xRot)`; if any scale is not 1, scale by (xScale, yScale, zScale). Because matrices stack on the right, a vertex is scaled first, then rotated (about the pivot), then translated, then moved by the parent's chain. The part's own pivot is the origin of its cuboids' coordinates. The order in which sibling parts are drawn follows the baked child map. The definition (`PartDefinition`) keeps its children in a hash map keyed by name; baking builds the runtime child map as an array-backed map (`Object2ObjectArrayMap`) from the stream of that hash map's entries, so the runtime iteration order is the definition's hash-iteration order (not an insertion order). (inferred) The drawing order of siblings has no visual effect for opaque cutout geometry because the depth buffer decides.

Other `ModelPart` helpers read: `getChild(name)`, `hasChild`, `setPos`, `setRotation`, `offsetPos/offsetRotation/offsetScale(v)` (add a vector to the current fields; used by animation, 5), `rotateBy(quaternion)` (compose an extra rotation with the current Euler angles and store back as Euler angles in Z-Y-X order), `getAllParts()` (the root, then for each node its direct children followed by the descendants of each child; an immutable copy), `createPartLookup()` (a name to part map, a plain hash map, that holds the key `root` for the root and then every descendant at any depth by its own child name, so animation bone names are **flat names**, not paths; when two parts anywhere in the tree have the same child name the one visited last silently overwrites the earlier one, read: it is a plain `put`), `getRandomCube(random)` (picks a uniformly random cuboid from the part's own list, used by stuck arrows, 8.7), `storePose()`.

### 1.6 Part names defined in `PartNames` (code constants)

These strings are shared by many models; a model may add others. (All constants read.)

| Group | Names |
|---|---|
| Body | `head`, `hat`, `body`, `upper_body`, `inner_body`, `waist`, `jacket`, `neck`, `mane`, `jaw`, `nose`, `beak`, `mouth`, `upper_mouth`, `inner_mouth`, `lower_mouth`, `tail`, `tongue`, `tongue_r1`, `cube`, `shell`, `harness`, `goggles`, `hat_rim`, `root`, `bone`, `bottom`, `feet`, `eyes`, `rods`, `mushrooms`, `arms`, `croaking_body` |
| Limbs | `left_arm`, `right_arm`, `left_leg`, `right_leg`, `left_hind_leg`, `right_hind_leg`, `left_mid_leg`, `right_mid_leg`, `left_front_leg`, `right_front_leg`, `left_hind_foot`, `right_hind_foot`, `left_front_foot`, `right_front_foot`, `left_hind_leg_tip`, `right_hind_leg_tip`, `left_front_leg_tip`, `right_front_leg_tip`, `left_hand`, `right_hand`, `left_foot`, `right_foot` |
| Head parts | `left_ear`, `right_ear`, `left_horn`, `right_horn`, `left_eye`, `right_eye`, `left_lid`, `right_lid`, `left_tendril`, `right_tendril` |
| Wings and fins | `left_wing`, `right_wing`, `left_wing_base`, `right_wing_base`, `left_wing_tip`, `right_wing_tip`, `left_fin`, `right_fin`, `top_fin`, `bottom_fin`, `tail_fin`, `back_fin`, `left_blue_fin`, `right_blue_fin`, `left_paddle`, `right_paddle`, `top_gills`, `left_gills`, `right_gills` |
| Other | `left_chest`, `right_chest`, `left_ribcage`, `right_ribcage`, `wind_body`, `wind_top`, `wind_mid`, `wind_bottom`, `chest_bottom`, `chest_lid`, `chest_lock`, `yellow_coral`, `yellow_coral_first`, `yellow_coral_second`, `pink_coral`, `pink_coral_second`, `blue_coral`, `blue_first`, `blue_second`, `red_coral`, `red_coral_first`, `red_coral_second` |

Note: the strings for `BLUE_CORAL_FIRST` and `BLUE_CORAL_SECOND` are `blue_first` and `blue_second` (not `blue_coral_first`).

---

## 2. Building a model: definitions, deformation, baby transform and scaling

### 2.1 Definition objects (`MeshDefinition`, `PartDefinition`, `LayerDefinition`, `MaterialDefinition`)

- A `MeshDefinition` owns an empty **root** `PartDefinition` (no cuboids, pose `ZERO`). Models add children to the root with `addOrReplaceChild(name, cubeListBuilder, pose)`, which returns the new child so that children can be nested.
- **Replace rule**: adding a child under a name that already exists replaces it **but keeps the old child's own children** (they are copied into the new definition). This is how a later layer can swap a part's cuboids without redoing its subtree.
- `clearChild(name)` replaces the child by one with the same pose and **no cuboids** (it errors if the name is missing); by the replace rule the child's own children survive it. `clearRecursively()` applies this to every descendant, so afterwards the whole subtree has its poses and no cuboids. `retainPartsAndChildren(set)` empties the cuboids of every part whose name is not in `set` and recurses into those parts (a named part is left untouched with its whole subtree); `retainExactParts(set)` keeps the cuboids of the named parts but empties every descendant of a named part, and empties and recurses into the unnamed ones. These are used to derive overlay layers (a layer that draws only some parts) from a full mesh.
- `PartDefinition.transformed(op)` returns a copy whose own pose is `op(pose)` and whose children are **shared unchanged** (so a transformer applied to the root applies only to the root's direct pose; `BabyModelTransform` therefore rebuilds the root's children one level at a time, 2.3).
- A `LayerDefinition` = mesh + `MaterialDefinition(textureWidth, textureHeight)`. `bakeRoot()` bakes the mesh's root with the texture size into a `ModelPart` tree; `apply(transformer)` returns a new layer with the mesh transformed.
- `EntityModelSet.bakeLayer(location)` bakes the layer definition registered for the `ModelLayerLocation` (an `IllegalArgumentException` for an unknown location). `EntityModelSet.vanilla()` is built from `LayerDefinitions.createRoots()`; `EMPTY` has no layers.

### 2.2 `MeshTransformer.scaling(s)`

A transformer used for per-entity-type model scale of a whole mesh (for example the illager layer: `LayerDefinitions.createRoots` applies `MeshTransformer.scaling(0.9375)` to the `IllagerModel` layer, read; the illager geometry is in part 3). Let k = 24.016 x (1 − s). The root's pose becomes `pose.scaled(s)` then `translated(0, k, 0)`. Since the root is only the container, this scales every child (the scale factor multiplies child positions through the root's scale in the matrix chain) and moves the whole model down by k so the feet stay on the ground: for s = 0.9375, k = 1.5010 pixels. `IDENTITY` returns the mesh unchanged.

`LayerDefinitions.createRoots` calls `MeshTransformer.scaling` six times (read), once per factor below. Each transformer object is then applied to every layer listed in its row (call sites read in `createRoots` and its lambdas):

| Layers the transformer is applied to | Factor s | k = 24.016 (1 − s) |
|---|---|---|
| Illager-style: the 0.9375 transformer is applied to the `IllagerModel` body layer (the scaled result is shared by `EVOKER`, `ILLUSIONER`, `PILLAGER` and `VINDICATOR`), to the villager body mesh (64 x 64) giving `VILLAGER` (also reused by `WANDERING_TRADER`) and to the no-hat villager mesh giving `VILLAGER_NO_HAT`, and to `WITCH` (the `WitchModel` body layer). The baby villager layers are not given this transformer in `createRoots` (not seen applied) | 0.9375 | 1.5010 |
| `CAVE_SPIDER`: applied to the spider body layer, the same layer definition that `SPIDER` registers unscaled | 0.7 | 7.2048 |
| `GIANT` (zombie-style body layer) and `GIANT_ARMOR` (the zombie armor set passed through `ArmorModelSet.map`, so all of its layers are scaled) | 6.0 | −120.08 |
| `HORSE` (adult equine body), `HORSE_ARMOR` (the equine body mesh built with `CubeDeformation(0.1)`, 64 x 64) and `HORSE_SADDLE` (the same transformer object is applied to all three; `HORSE_BABY` and the unscaled saddle definition are created before it and `HORSE_BABY` is registered without it) | 1.1 | −2.4016 |
| `HUSK` and `HUSK_ARMOR` (armor set mapped through the transformer). `HUSK_BABY` and `HUSK_BABY_ARMOR` are registered separately (no transformer seen) | 1.0625 | −1.5010 |
| `WITHER_SKELETON` and `WITHER_SKELETON_ARMOR` (armor set mapped through the transformer) | 1.2 | −4.8032 |

An implementer must therefore scale the armor layers of giant, husk and wither skeleton with the same factor as their body; drawing them unscaled misplaces the armor.

The k column is computed from the formula above, not read. Husk, giant and wither skeleton are in part 2, illager and villager in part 3, horse and saddle in part 4, and the cave spider (spider mesh scaled 0.7, 7.2048 pixel shift) in 34 part 6 section 6. The transformer-to-layer mapping above is read from `createRoots`; whether witch and villager shares were already described in parts 3 and 5 was not checked.

### 2.3 `BabyModelTransform` (record with seven fields)

Fields: `scaleHead` (boolean), `babyYHeadOffset`, `babyZHeadOffset`, `babyHeadScale`, `babyBodyScale`, `bodyYOffset`, `headParts` (set of child names). Constructors and defaults: with only a head-part set: scaleHead = false, yHeadOffset = 5, zHeadOffset = 2, headScale = 2, bodyScale = 2, bodyYOffset = 24. With (scaleHead, yHeadOffset, zHeadOffset, headParts): headScale = 2, bodyScale = 2, bodyYOffset = 24.

Applying it to a mesh: build a new mesh; for every **direct child of the root**, copy it with a pose transform chosen by name:
- **head parts** (names in `headParts`): `pose.translated(0, yHeadOffset, zHeadOffset)` then `.scaled(hf)`, where hf = 1.5 / headScale if `scaleHead`, else 1.
- **all other children**: `pose.translated(0, bodyYOffset, 0)` then `.scaled(1 / bodyScale)`.

(The assignment of the two lambdas to head and body was read from which one uses the head offsets.) Because `scaled` multiplies position and scale, a child at pivot (px, py, pz) with scale 1 ends at ((px) x f, (py + yOffset) x f, (pz + zOffset) x f) with scale f; children of that child are untouched and inherit through the matrix chain. The humanoid baby transformer is (scaleHead true, yHeadOffset 16, zHeadOffset 0, headScale 2, bodyScale 2, bodyYOffset 24, head parts {`head`}), so the head factor is 1.5 / 2 = 0.75 and the body factor 0.5 (3.7). Worked example V4 in 11.

### 2.4 Deformation constants in `LayerDefinitions` (read)

| Constant | Value | Use |
|---|---|---|
| `FISH_PATTERN_DEFORMATION` | 0.008 on all axes | tropical fish pattern overlay |
| `OUTER_ARMOR_DEFORMATION` | 1.0 | outer armor layers (helmet, chestplate, boots) |
| `INNER_ARMOR_DEFORMATION` | 0.5 | inner armor layer (leggings) |
| `BABY_OUTER_ARMOR_DEFORMATION` | (−0.1, 0.5, 0.3) | baby humanoid outer armor |
| `BABY_INNER_ARMOR_DEFORMATION` | (−0.1, 0.3, 0.3) | baby humanoid inner armor |
| `BABY_PIGLIN_INNER_ARMOR_DEFORMATION`, `BABY_PIGLIN_OUTER_ARMOR_DEFORMATION` | 0.7 each | baby piglin armor |
| `BABY_PIGLIN_ARMOR_ARM_OFFSET` | pose offset (0.5, −0.5, 0) | baby piglin armor arms |
| piglin adult armor | inner 0.5 and a second deformation 1.02 | `PiglinModel.createArmorMeshSet(0.5, 1.02)` |

`LayerDefinitions.createRoots()` builds the full map of `ModelLayerLocation` to `LayerDefinition` for all 361 layers (4.3); the geometry of each layer is in the sibling documents. At the end it builds the immutable map, filters the locations returned by `ModelLayers.getKnownLocations()` that are **absent** from it and, if that list is not empty, throws `IllegalStateException` with the list as the message (read), so a missing definition is a load-time failure. Texture sizes of each layer are given by the sibling documents (`LayerDefinition.create(mesh, w, h)` in `createRoots` uses 64 x 64 and 64 x 32 for the shared definitions read here).

### 2.5 `ArmorModelSet`

A record of four values (`head`, `chest`, `legs`, `feet`) with `get(EquipmentSlot)`, `map(fn)` and `putFrom`. `bake(layerSet, modelSet, constructor)` bakes the four layer locations of a set and wraps each root in a `HumanoidModel` subclass. `ModelLayers.registerArmorSet(name)` registers four locations named `<name>` with layer strings `helmet`, `chestplate`, `leggings`, `boots` (4.1).

---

## 3. Shared model base classes

### 3.1 `Model<S>` and `EntityModel<S>`

`Model` keeps the root part, a function from texture `Identifier` to `RenderType`, and the flat list of all parts (computed once from `getAllParts`). `renderToBuffer(pose, consumer, light, overlay, colour)` draws the root. `setupAnim(state)` resets the pose (3.2). `EntityModel` extends it with the default render type function `RenderTypes.entityCutout(texture)` (6.7) and defines `MODEL_Y_OFFSET` = −1.501. A model whose renderer wants another render type passes its own function (translucent outer layers, eyes, swirl).

### 3.2 `HeadedModel`, `ArmedModel`, `VillagerLikeModel`

- `HeadedModel.getHead()` returns the head part; `translateToHead(pose)` applies that part's `translateAndRotate` (used by head items and skulls, 8.4).
- `ArmedModel.translateToHand(state, arm, pose)` positions the matrix at the given hand (used by `ItemInHandLayer`, 8.3).
- `VillagerLikeModel.translateToArms(state, pose)` positions the matrix at the crossed arms (used by the villager held-item layer, part 3).

### 3.3 `AdultAndBabyModelPair<T>`

A record (`adultModel`, `babyModel`) with `getModel(isBaby)`. `AgeableMobRenderer` holds the two models and selects per frame (6.6).

### 3.4 `QuadrupedModel` (the shared four-legged base)

Child names required in the baked root: `head`, `body`, `right_hind_leg`, `left_hind_leg`, `right_front_leg`, `left_front_leg`. `setupAnim`: head `xRot` = state pitch x π/180, head `yRot` = relative yaw x π/180 (`LivingEntityRenderState.xRot` and `yRot`, 6.3); with p = `walkAnimationPos`, s = `walkAnimationSpeed`:

| Leg | xRot |
|---|---|
| right hind | cos(0.6662 p) x 1.4 x s |
| left hind | cos(0.6662 p + π) x 1.4 x s |
| right front | cos(0.6662 p + π) x 1.4 x s |
| left front | cos(0.6662 p) x 1.4 x s |

`createBodyMesh(legHeight, mirrorLeft, mirrorRight, deformation)` builds the standard mesh (all values read):

| Part | Pivot | Texture offset | Cuboid origin | Size | Notes |
|---|---|---|---|---|---|
| `head` | (0, 18 − legHeight, −6) | (0, 0) | (−4, −4, −8) | 8 x 8 x 8 | `deformation` applied |
| `body` | (0, 17 − legHeight, 2) | (28, 8) | (−5, −10, −7) | 10 x 16 x 8 | pose rotation xRot = 1.5707964 (90° about X); `deformation` applied |
| `right_hind_leg` | (−3, 24 − legHeight, 7) | (0, 16) | (−2, 0, −2) | 4 x legHeight x 4 | mirror = `mirrorRight` |
| `left_hind_leg` | (3, 24 − legHeight, 7) | (0, 16) | (−2, 0, −2) | 4 x legHeight x 4 | mirror = `mirrorLeft` |
| `right_front_leg` | (−3, 24 − legHeight, −5) | (0, 16) | (−2, 0, −2) | 4 x legHeight x 4 | mirror = `mirrorRight` |
| `left_front_leg` | (3, 24 − legHeight, −5) | (0, 16) | (−2, 0, −2) | 4 x legHeight x 4 | mirror = `mirrorLeft` |

`createLegs(parent, mirrorLeft, mirrorRight, legHeight, deformation)` adds only the four leg rows, and the leg cuboids take the deformation too. Individual animals (pig, sheep, cow, ...) call these with their own leg height and then add or replace parts (parts 2 and 3). The pig, for instance, uses leg height 6 (documented in part 2).

### 3.5 `AnimationUtils` (shared pose helpers read)

All angles radians; `age` = `ageInTicks`.

| Helper | Effect |
|---|---|
| `bobModelPart(part, age, sign)` | part.zRot += sign x (cos(0.09 age) x 0.05 + 0.05); part.xRot += sign x sin(0.067 age) x 0.05 |
| `bobArms(right, left, age)` | `bobModelPart(right, age, +1)` then `bobModelPart(left, age, −1)` |
| `animateZombieArms(left, right, flag, state)` | zombie-style raised arms, below |
| `animateCrossbowHold`, `animateCrossbowCharge` | 12 §7.5 (rows `CROSSBOW_HOLD`, `CROSSBOW_CHARGE`); constants confirmed: hold: yRot adds ∓0.3 / ±0.6 (by hand), xRot adds −π/2 + 0.1 and −1.5; charge: holding arm yRot ∓0.8, xRot −0.97079635; the other arm lerps yRot from 0.4 to 0.85 and xRot to −π/2 with charge fraction clamp(ticksUsing, 0, max) / max |
| `swingWeaponDown(rightArm, leftArm, mainArm, attackTime, age)` | the vindicator/pillager raised-axe swing, below |

`animateZombieArms` (re-read in round Z against the bytecode: this condition is correct, no change; its state parameter type is `UndeadRenderState`, the flag is `isAggressive` for zombie, husk, drowned, giant, zombie villager and zombified piglin, and the constant true for the illager ATTACKING pose; each caller passes `(leftArm, rightArm, flag, state)` from `setupAttackAnimation`, not `setupAnim`): return immediately when either arm pose is `SPEAR`. Let `R` = true when the mob is **not** a baby, or is a baby whose main-hand item is empty. base = R ? −π / (flag ? 1.5 : 2.25) : 0 (`flag` is `ZombieRenderState.isAggressive`, passed by `ZombieModel.setupAttackAnimation`: true selects the divisor 1.5, false selects 2.25; read). With a = `swingAnimation` (0 to 1): s1 = (R ? 1 : −1) x sin(a π); s2 = sin((1 − (1 − a)²) π); x = base + s1 x 1.2 − s2 x 0.4; y = 0.1 − s1 x 0.6. The **right** arm (unless its pose is `THROW_TRIDENT`): xRot = x, yRot = R ? −y : y, zRot = 0. The **left** arm (unless its pose is `THROW_TRIDENT`): xRot = x, yRot = R ? y : −y, zRot = 0.

`swingWeaponDown`: with s1 = sin(attackTime π) and s2 = sin((1 − (1 − attackTime)²) π): right.zRot = 0, left.zRot = 0, right.yRot = 0.15707964, left.yRot = −0.15707964. The **main** arm: xRot = −1.8849558 + cos(0.09 age) x 0.15, then += s1 x 2.2 − s2 x 0.4. The **other** arm: xRot = cos(0.19 age) x 0.5, then += s1 x 1.2 − s2 x 0.4. Then `bobArms`. (Which arm receives which pair was read from the two branches of the main-arm test; the constants are exact.)

### 3.6 `HumanoidModel.ArmPose` (enum, read)

`EMPTY, ITEM, BLOCK, BOW_AND_ARROW, THROW_TRIDENT, CROSSBOW_CHARGE, CROSSBOW_HOLD, SPYGLASS, TOOT_HORN, BRUSH, SPEAR` (11 values). The pose formulas are in 12 §7.5. The enum also has `isTwoHanded()`, `affectsOffhandPose()` and `animateUseItem(state, pose, ticks, arm, item)` used by `ItemInHandLayer` (8.3). `HumanoidMobRenderer.getArmPose` returns `SPEAR` when the held item in that arm "uses the spear pose" and `EMPTY` otherwise; "uses the spear pose" is true when the mob's current swing is by that arm's hand and its swing animation type is `STAB`, or the stack has item tag `spears`.

### 3.7 `HumanoidModel` constants beyond 12 §7.4

12 §7.4 and §7.5 specify the parts and the pose code. Additional constants read here: `BABY_TRANSFORMER` = `BabyModelTransform` (true, 16, 0, 2, 2, 24, {`head`}). The armor mesh sets use the deformation table 2.4 (adult 0.5 inner and 1.0 outer; baby sets as listed); the humanoid armor texture layouts are in the equipment assets (DATA). The retained-parts sets `ADULT_ARMOR_PARTS_PER_SLOT` and `BABY_ARMOR_PARTS_PER_SLOT` (protected static maps from slot to part-name set) are given in 34 part 2 §1.4 and not repeated.

Other `HumanoidModel` constants read: `OVERLAY_SCALE` 0.25 (public), `HAT_OVERLAY_SCALE` 0.5 (public), `LEGGINGS_OVERLAY_SCALE` −0.1 (public), `DUCK_WALK_ROTATION` 0.005 (private), spyglass arm constants `SPYGLASS_ARM_ROT_Y` 0.2617994, `SPYGLASS_ARM_ROT_X` 1.9198622, `SPYGLASS_ARM_CROUCH_ROT_X` 0.2617994, shield constants `HIGHEST_SHIELD_BLOCKING_ANGLE` −1.3962634, `LOWEST_SHIELD_BLOCKING_ANGLE` 0.43633232, `HORIZONTAL_SHIELD_MOVEMENT_LIMIT` 0.5235988, and toot-horn constants `TOOT_HORN_XROT_BASE` 1.4835298 and `TOOT_HORN_YROT_BASE` 0.5235988. The spyglass and toot-horn constants match the pose rows of 12 §7.5. Where the duck-walk and shield constants are applied was not read in this round (Open question 23).

### 3.8 `SpearAnimations` (`net.minecraft.client.model.effects`)

Called by `ItemInHandLayer` (8.3) and by the `SPEAR` arm pose (3.6, 12 §7.5). Notation: `D` = 0.017453292; `progress(v, a, b)` = clamp((v − a) / (b − a), 0, 1) (`Mth.inverseLerp` then clamp). A kinetic weapon is the item component `KINETIC_WEAPON` (its fields `delayTicks`, `forwardMovement` and the three optional condition records are data of the item, 22). Easing functions (`net.minecraft.util.Ease`, all read unless said): inQuad(x) = x²; outCubic(x) = 1 − (1 − x)³; outQuart(x) = 1 − (1 − x)⁴; inOutSine(x) = −(cos(πx) − 1) / 2; inOutExpo(x) = 0 at x = 0, 1 at x = 1, 2^(20x − 10) / 2 for x < 0.5, (2 − 2^(−20x + 10)) / 2 above; outBack(x) = 1 + 2.70158 (x − 1)³ + 1.70158 (x − 1)²; outCirc(x) = sqrt(1 − (x − 1)²); inCirc(x) = 1 − sqrt(1 − x²); inOutBack for x < 0.5 = 4x² (7.189819 x − 2.5949094) / 2, and for x >= 0.5, with w = 2x − 2, (w² (3.5949094 w + 2.5949094) + 2) / 2 (both halves read); inOutElastic is 0 at 0 and 1 at 1; with S = sin((20x − 11.125) x 1.3962634801864624) computed once for both halves (in double), x < 0.5 gives −2^(20x − 10) S / 2 and x >= 0.5 gives 2^(−20x + 10) S / 2 + 1 (both read).

| Function | Effect (arguments: s = `swingAnimation`, sign = +1 right arm, −1 left arm) |
|---|---|
| `thirdPersonAttackItem(state, pose)` | nothing when s <= 0. fwd = `forwardMovement` of the kinetic weapon in the main-hand stack (0 when none). a = inQuad(progress(s, 0.05, 0.2)), b = inOutExpo(progress(s, 0.4, 1)). Rotate about the point (0, −0.125, 0.125) by 70 (a − b) degrees about the −X axis, then translate (0, fwd (a − b), 0) (acts first on the item) |
| `thirdPersonAttackHand(model, s, arm)` | right arm yRot −= body yRot; left arm yRot −= body yRot; left arm xRot −= body yRot (read exactly so: the left arm's xRot subtracts the body's yRot). With c = inOutSine(progress(s, 0, 0.05)), a and b as above: the swinging arm xRot += (90 c − 120 a + 30 b) D |
| `hitFeedbackAmount(t)` | 0.4 (outQuart(progress(t, 1, 3)) − inOutSine(progress(t, 3, 10))), t = `ticksSinceKineticHitFeedback` |
| `thirdPersonHandUse(arm, head, side, stack, state)` | arm yRot = −0.1 sign + head yRot; arm xRot = −π/2 + head xRot + 0.8, minus 0.9599311 when fall flying or `swimAmount` > 0; then yRot = D clamp(57.295776 yRot, −60, 60) and xRot = D clamp(57.295776 xRot, −120, 30). Then return unless `ticksUsingItem` > 0 and the state is using an item with the use hand converted to an arm (by the main arm) equal to `side`; return when the stack has no kinetic weapon. With the use parameters P (below): yRot += −sign P.swayScaleFast D P.swayIntensity; zRot += −sign P.swayScaleSlow D P.swayIntensity 0.5; xRot += D (−40 P.raiseStart + 30 P.raiseMiddle − 20 P.raiseEnd + 20 P.lower + 10 P.raiseBack + 0.6 P.swayScaleSlow P.swayIntensity) |
| `thirdPersonUseItem(state, pose, ticks, arm, stack)` | nothing without a kinetic weapon or when ticks = 0. a, b as in `thirdPersonAttackItem`; P from (weapon, ticks); g = 1 − outBack(1 − P.raise); hit = `hitFeedbackAmount`. Translate (0, −0.4 hit, −fwd (g − P.raiseBack) + hit); rotate about (0, −0.03125, 0.125) by 70 (P.raise − P.raiseBack) − 40 (a − b) degrees about −X; rotate about (0, 0, 0.125) by sign x 90 (P.raise − P.sway + 3 b + a) degrees about +Y (the last operation listed acts first) |
| `firstPersonUse(hitTicks, pose, ticks, arm, stack)` | nothing without a kinetic weapon. Translate (sign (0.15 raise − 0.05 raiseEnd − 0.1 sway + 0.005 swayScaleSlow), −0.075 raise + 0.075 raiseMiddle + 0.01 swayScaleFast, 0.05 raiseStart − 0.05 raiseEnd + 0.005 swayScaleSlow); rotate about (0, 0.1, 0) by −65 inOutBack(raise) − 35 lower + 100 raiseBack − 0.5 swayScaleFast degrees about +X; rotate about (sign 0.15, 0, 0) by sign (−90 progress(raise, 0.5, 0.55) + 90 sway + 2 swayScaleSlow) degrees about −Y; translate (0, −`hitFeedbackAmount`(hitTicks), 0) |
| `firstPersonAttack(s, pose, sign, arm)` | a = inOutSine(progress(s, 0, 0.05)), b = outBack(progress(s, 0.05, 0.2)), c = inOutExpo(progress(s, 0.4, 1)): translate (0.1 sign (a − b), −0.075 (a − c), 0.65 (a − b)); rotate about +X by −70 (a − c) degrees; translate (0, 0, −0.25 (c − b)) |

Use parameters `UseParams.fromKineticWeapon(weapon, t)` (t = ticks using the item): d = `delayTicks`; E = d + (the dismount condition's value, 0 when absent); knock = d + (the knockback condition's value, 0 when absent); dmg = d + (the damage condition's value, 0 when absent) (the value mapped from each condition record is its `maxDurationTicks`: inferred from the record's field list; the `Optional.map` lambdas are invokedynamic and were not disassembled; the window structure below was read: Open question 25). Then: raise = progress(t, 0, d); raiseStart = progress(raise, 0, 0.5); raiseMiddle = progress(raise, 0.5, 0.8); raiseEnd = progress(raise, 0.8, 1); sway = progress(t, E − 20, E); lower = outCubic(inOutElastic(progress(t − 20, knock − 40, knock))); raiseBack = progress(t, dmg − 5, dmg); swayIntensity = 2 outCirc(sway) − 2 inCirc(raiseBack); swayScaleSlow = sin(19 t D) swayIntensity; swayScaleFast = sin(30 t D) swayIntensity.

---
## 4. Model layers, ids and the layer registry

### 4.1 `ModelLayerLocation` and `ModelLayers`

A `ModelLayerLocation` is a record (model `Identifier`, layer string). Its text form is `<model id>#<layer>` (for example `minecraft:allay#main`). `ModelLayers` registers every location through two helpers: `register(name)` = location (`minecraft:<name>`, layer `main`) and `register(name, layer)`. Registering the same location twice throws. `registerArmorSet(name)` registers four locations (`minecraft:<name>` with layers `helmet`, `chestplate`, `leggings`, `boots`) and returns an `ArmorModelSet`. `ModelLayers.getKnownLocations()` streams every registered location.

### 4.2 Counts and naming rules (read)

- `ModelLayers` has 292 public fields: **269 single layers and 23 armor sets**, i.e. 269 + 23 x 4 = **361 model layers**. Appendix A lists all 292 fields.
- Names are lower-case paths, `/` separates a family from a variant (`boat/oak`, `chest_boat/oak`), a `_baby` suffix names the baby geometry (`cow_baby`-style names: `armadillo_baby`, `axolotl_baby`), a `_armor` suffix field is an armor set whose model id is the base name, and the banner flag layers use the layer string `flag` (`standing_banner#flag`, `wall_banner#flag`). The layer string is `main` unless given.
- **Stable layer id** (for implementations): the text form `<model id>#<layer>` of the location; for the 23 armor sets the four ids `<model id>#helmet`, `#chestplate`, `#leggings`, `#boots`.

### 4.3 What the layer registry maps to

`LayerDefinitions.createRoots()` maps each of the 361 locations to a `LayerDefinition` (mesh plus texture size), by calling the model classes' `createBodyLayer`, `createBodyMesh`, `createArmorMeshSet` and similar static methods, sometimes with a `MeshTransformer` (baby, scaling) or a different deformation (2.4). A known location without a definition makes `createRoots` throw `IllegalStateException` (2.4). The baked parts are created each time `bakeLayer` is called, so every renderer owns its own `ModelPart` instances.

### 4.4 Stable ids of animations and textures

| Kind | Id rule | Notes |
|---|---|---|
| Model layer | `<namespace>:<model>#<layer>` (4.2) | the key of the geometry; documented in parts 2 to 9 per entity |
| Animation definition | `<Class>.<FIELD>` of the definitions class in `net.minecraft.client.animation.definitions` (class list in 5.6) | each is a static final `AnimationDefinition`; the 16 classes of the artifact are listed in 5.6 |
| Bone name | the child name inside the model (1.5: flat names) | an animation channel set refers to a part by this name; the engine does not check uniqueness, so authors must keep names unique within a model and, if a name repeats, the part visited last wins |
| Texture | the `Identifier` the renderer passes (`getTextureLocation`) | a path under `assets/<ns>/textures/`, e.g. `minecraft:textures/entity/bee/bee_stinger.png`; the files are DATA and supplied by the resource pack (22, 14 §5.2); the renderer family documents give the path rules (variants by id, by profession, by pattern) |
| Equipment layer texture | `EquipmentClientInfo.Layer.getTextureLocation(layerType)` | from the equipment asset JSON (DATA, `assets/minecraft/equipment/*.json`, 45 files) |

---

## 5. Keyframe animation engine (`net.minecraft.client.animation`)

### 5.1 Data model

- `AnimationDefinition` (record): `lengthInSeconds` (float), `looping` (boolean), `boneAnimations` (map from bone name to a list of `AnimationChannel`). The builder `withLength(len)` + `addAnimation(bone, channel)` (channels of one bone accumulate in a list in insertion order) + `looping()` + `build()` produces it.
- `AnimationChannel` (record): a `Target` and an array of `Keyframe` (sorted by timestamp, authored that way; the engine does not sort).
- `Keyframe` (record): `timestamp` (seconds), `preTarget` and `postTarget` (3-vectors), `interpolation`. The three-argument constructor uses the same vector for pre and post (continuous keyframe); the four-argument constructor allows a jump at that time (different `preTarget` and `postTarget`).
- `Target` (functional): `apply(part, vector)`. Three targets: `POSITION` = `part.offsetPos(vector)` (adds to x, y, z, in pixels), `ROTATION` = `part.offsetRotation(vector)` (adds to xRot, yRot, zRot, radians), `SCALE` = `part.offsetScale(vector)` (adds to the three scale values). All three are **additive** on the current pose.
- Authoring helpers (`KeyframeAnimations`): `posVec(x, y, z)` = (x, **−y**, z) (the authoring tool's Y is up, the model's is down); `degreeVec(x, y, z)` = each component x 0.017453292 (degrees to radians); `scaleVec(x, y, z)` = (x − 1, y − 1, z − 1) as doubles narrowed to float (scale is additive to 1).
- `Interpolation` (functional): `apply(dest, alpha, keyframes, i, j, scale)` returns `dest`, and there are two: `LINEAR` and `CATMULLROM`.

### 5.2 Evaluating one channel at time t (seconds) (`KeyframeAnimation$Entry.apply`)

1. Find the index `f` = the first keyframe whose timestamp is **greater than or equal to** t (a binary search over [0, n); n if none). Let `i = max(0, f − 1)` and `j = min(n − 1, i + 1)`.
2. `alpha` = 0 when `i = j`; otherwise `alpha = clamp((t − ts[i]) / (ts[j] − ts[i]), 0, 1)`.
3. The interpolation used is the one stored on **keyframe j** (the later one).
4. `LINEAR`: result = `lerp(post[i], pre[j], alpha)` x `scale` (component-wise linear interpolation, then multiplied by the animation's scale factor).
5. `CATMULLROM`: for each component, with `p0 = post[max(0, i − 1)]`, `p1 = post[i]`, `p2 = post[j]`, `p3 = post[min(n − 1, j + 1)]` (note: post targets of all four) and a = alpha: value = 0.5 x (2 p1 + (p2 − p0) a + (2 p0 − 5 p1 + 4 p2 − p3) a² + (3 p1 − p0 − 3 p2 + p3) a³), x `scale`. (`Mth.catmullrom(a, p0, p1, p2, p3)`; all four terms read in the bytecode.)
6. Apply the target to the bone's part with the result.

Behaviour at the ends (the search predicate is "t <= timestamp", read): t before the first timestamp, or equal to it, gives `f = 0`, `i = 0`, `j = 1` (when n > 1), `alpha` 0 and the value is `post[0]` (linear). t **equal to the last** timestamp gives `f = n − 1`, `i = n − 2`, `j = n − 1` and `alpha` = 1, so the linear value is `pre[n − 1]` (not `post[n − 1]`; the two differ only for a keyframe whose pre and post targets differ). t **strictly greater** than the last timestamp gives `f = n`, `i = j = n − 1`, `alpha` = 0 and the value `post[n − 1]`. With a single keyframe, `i = j = 0`.

### 5.3 Running an animation (`KeyframeAnimation`)

An `AnimationDefinition` is baked against a model's root with `bake(root)`: each bone name is looked up in the model's flat name map (1.5), a missing name throws (`IllegalArgumentException`), and the result is a list of (part, target, keyframes) entries in map-iteration order. Running:

| Entry point | Time and scale |
|---|---|
| `apply(AnimationState, ageInTicks[, speed = 1])` | if the state has started: time in ms = `state.getTimeInMillis(ageInTicks)` x speed truncated to a long; scale = 1 |
| `applyWalk(walkPos, walkSpeed, timeFactor, speedFactor)` | time in ms = trunc(walkPos x 50 x timeFactor); scale = min(walkSpeed x speedFactor, 1) |
| `applyStatic()` | time 0, scale 1 |
| `apply(ms, scale)` (the common core) | seconds = ms / 1000; if the definition loops: seconds = seconds mod `lengthInSeconds` (floating remainder); then evaluate every entry (5.2) with that time and `scale` |

A non-looping animation clamps naturally at its last keyframe (5.2). Because `scale` multiplies the interpolated offset (not the weight between poses), a walk animation at low speed just has smaller offsets. Animations are applied **after** `resetPose()` and after the model's own formulas; all three targets add to what is already there.

### 5.4 Worked example

Channel `ROTATION` on a part with keyframes k0 = (t 0, (0, 0, 0), linear) and k1 = (t 1.0, `degreeVec(0, 90, 0)` = (0, 1.5707964, 0), linear). At t = 0.25 (scale 1): f = 1, i = 0, j = 1, alpha = 0.25, value = (0, 0.3926991, 0); the part's `yRot` increases by 0.3926991 on top of its pose. With `applyWalk(walkPos = 10, walkSpeed = 0.5, 1, 1)` time = trunc(10 x 50) = 500 ms and scale 0.5: t = 0.5 s, alpha 0.5, value = (0, 0.7853982, 0) x 0.5 = (0, 0.3926991, 0).

### 5.5 `AnimationState`

`AnimationState` (`net.minecraft.world.entity`, read) keeps one integer `startTick`; the value −2147483648 (`Integer.MIN_VALUE`) is the stopped sentinel, and a new state is stopped. `start(tick)` sets `startTick`; `startIfStopped(tick)` starts only when stopped; `stop()` restores the sentinel; `animateWhen(flag, tick)` = `startIfStopped(tick)` when flag else `stop()`; `isStarted()` = `startTick` is not the sentinel; `ifStarted(consumer)` runs the consumer only when started; `fastForward(n, rate)` (when started) subtracts trunc(n x rate) from `startTick`; `copyFrom` copies `startTick`. `getTimeInMillis(ageInTicks)` = trunc((ageInTicks − startTick) x 50) as a long (float arithmetic, truncation toward zero). Which entity code starts and stops each state is in the sibling parts.

### 5.6 Definition classes in the artifact

`ArmadilloAnimation`, `BabyArmadilloAnimation`, `BabyAxolotlAnimation`, `BabyRabbitAnimation`, `BatAnimation`, `BreezeAnimation`, `CamelAnimation`, `CamelBabyAnimation`, `CopperGolemAnimation`, `CreakingAnimation`, `FoxBabyAnimation`, `FrogAnimation`, `NautilusAnimation`, `RabbitAnimation`, `SnifferAnimation`, `WardenAnimation` (16 classes). Their keyframe tables are CODE and are given by the sibling documents of the owning mobs, by the allocation of 10: armadillo and baby armadillo, fox baby, frog, sniffer, bat in part 5; rabbit, baby rabbit, camel and camel baby in part 4; nautilus and baby axolotl in part 8; breeze and warden in part 6; creaking and copper golem in part 3 (the keyframe tables are in the document of the owning mob: the sibling documents are authoritative).

---

## 6. The entity renderer framework

### 6.1 Pipeline in one picture (this build is two-phase)

1. **Extract** (per entity per frame): `EntityRenderDispatcher.extractEntity(entity, partialTick)` finds the renderer, creates a fresh render state and fills it (`createRenderState` = `createRenderState()` then `extractRenderState(entity, state, partialTick)` then `finalizeRenderState`). The state is plain data (6.3); nothing after this reads the entity.
2. **Submit**: `EntityRenderDispatcher.submit(state, cameraState, camX, camY, camZ, poseStack, collector)` computes the render offset, translates to the entity position, calls `renderer.submit(...)`, then adds fire, shadow, and restores. Submitting hands model, shadow, flame, leash and text to a `SubmitNodeCollector`; the actual drawing is done later by the feature renderers (7).
3. Models are animated with `model.setupAnim(state)` at draw time (the collector calls it when it draws a submitted model: inferred from `submitModel` receiving the model and the state object); `LivingEntityRenderer.submit` calls `setupAnim` itself again before the layers when there are layers.

### 6.2 Dispatcher and registration (`EntityRenderDispatcher`, `EntityRenderers`, `EntityRendererProvider`)

- `EntityRendererProvider<T>.create(context)` builds a renderer. The `Context` carries the dispatcher, the block model resolver, the item model resolver, the map renderer, the resource manager, the `EntityModelSet`, the equipment asset manager and `EquipmentLayerRenderer`, the atlas manager, the font, the player-skin cache and the paletted texture manager. `context.bakeLayer(location)` = `EntityModelSet.bakeLayer`.
- `EntityRenderers` keeps a static map `PROVIDERS` from `EntityType` to provider, filled by 159 `register` calls (6.4). `createEntityRenderers(context)` instantiates all of them once per resource reload (a failure to create one throws naming the type). `createAvatarRenderers(context)` creates two `AvatarRenderer`s keyed by `PlayerModelType` (`WIDE` = argument false, `SLIM` = argument true). `validateRegistrations()` logs "No renderer registered for <key>" for every entity type that has no provider and returns true when there was at least one such type; `player` and `mannequin` are the only types exempt (they are drawn by avatar renderers).
- The dispatcher holds the renderer map, a player-renderer map and a **separate mannequin-renderer map**, each built on `onResourceManagerReload`. Lookup `getRenderer(entity)`: an `AbstractClientPlayer` uses the player map and a `ClientMannequin` the mannequin map, both keyed by the entity's skin `PlayerModelType` (fallback `WIDE` if absent); every other entity uses the type map. `getRenderer(state)` does the same from the state (`AvatarRenderState.skin().model()` for avatars, `state.entityType` otherwise).
- `prepare(camera, crosshairPickEntity)` stores the camera and the entity under the crosshair (used by name-tag rules, 7.2). `distanceToSqr(entity)` = squared distance from the camera position to the entity position.
- `shouldRender(entity, frustum, camX, camY, camZ, partial)` delegates to the renderer (6.8).

### 6.3 Render states (fields read)

`EntityRenderState` (all entities): `entityType`, position `x, y, z` (**interpolated**: lerp(partial, old, current) per axis), `ageInTicks` = tickCount + partial, `boundingBoxWidth`, `boundingBoxHeight`, `eyeHeight` (current bounding values), `distanceToCameraSq`, `isInvisible`, `isDiscrete`, `displayFireAnimation`, `lightCoords` (6.9), `outlineColor` (team colour with opaque alpha when the entity "appears glowing", else 0), `passengerOffset` (only when riding a minecart that uses the new interpolating behaviour: cart interpolated position minus the entity's interpolated position; else none), `nameTag` and `nameTagAttachment` and `scoreText` (7.2), `leashStates` (7.3), `shadowRadius` and `shadowPieces` (7.1).

`LivingEntityRenderState` adds: `bodyRot`, `yRot` (head yaw relative to the body, wrapped to [−180, 180)), `xRot` (pitch), `deathTime`, `walkAnimationPos`, `walkAnimationSpeed`, `scale`, `ageScale`, `ticksSinceKineticHitFeedback`, `isUpsideDown`, `isFullyFrozen`, `isBaby`, `isInWater`, `isAutoSpinAttack`, `hasRedOverlay`, `isInvisibleToPlayer`, `bedOrientation`, `pose`, `headItem` (an item render state), `wornHeadAnimationPos`, `wornHeadType` and `wornHeadProfile` (skull worn on the head).

Extraction rules of `LivingEntityRenderer.extractRenderState`:
- head yaw h = `rotLerp(partial, yHeadRotO, yHeadRot)` where `rotLerp(t, a, b)` = a + t x wrapDegrees(b − a) and `wrapDegrees(x)` maps to [−180, 180) (x mod 360, then −360 if ≥ 180, +360 if < −180).
- `bodyRot` = `solveBodyRot`: if the vehicle is a `LivingEntity`: b = `rotLerp(partial, yBodyRotO, yBodyRot)`; d = clamp(wrapDegrees(h − b), −85, 85); b' = h − d; if |d| > 50 then b' += d x 0.2; result b'. Otherwise `rotLerp(partial, yBodyRotO, yBodyRot)`.
- `yRot` = wrapDegrees(h − bodyRot). `xRot` = interpolated pitch. If the entity is "upside down" (`isEntityUpsideDown`: custom name equals `Dinnerbone` or `Grumm`), both `xRot` and `yRot` are negated.
- walk: when the entity is not a passenger and is alive: `walkAnimationPos` = `walkAnimation.position(partial)` and `walkAnimationSpeed` = `walkAnimation.speed(partial)`, else both 0. `wornHeadAnimationPos` = the vehicle's walk position if the vehicle is a living entity, else its own.
- `scale` = the `scale` attribute value (`getScale()`); `ageScale` = `LivingEntity.getAgeScale()`: the base returns 0.5 for a baby and 1 otherwise, and six entity classes override it (read): the baby value is 0.3 for the turtle, 0.65 for the dolphin, 0.6 for the camel, 0.55 for the goat, 0.2375 for the happy ghast and 0.6 for the armadillo (adult 1 in every case). `ArmorStand` and `Sniffer` only call `getAgeScale` (the sniffer uses it to scale its digging dimensions); `pose`, `bedOrientation` (and if it exists, `eyeHeight` is replaced by the **standing** eye height), `isFullyFrozen`, `isBaby`, `isInWater`, `isAutoSpinAttack`.
- `hasRedOverlay` = (`hurtTime` > 0 or `deathTime` > 0). `deathTime` (state) = `deathTime + partial` when `deathTime` > 0, else 0.
- worn head: when the head item is a block item whose block is a skull (`AbstractSkullBlock`): `wornHeadType` = the skull type, `wornHeadProfile` = the item's profile component, and `headItem` is cleared; otherwise `wornHeadType` and profile null and `headItem` is filled by the item model resolver with the `HEAD` display context unless the stack is rendered by the armor layer (`HumanoidArmorLayer.shouldRender`).
- `isInvisibleToPlayer` = invisible and invisible to the local player.

`HumanoidRenderState` (extends `ArmedEntityRenderState`, which extends `LivingEntityRenderState`; `AvatarRenderState` and `UndeadRenderState` extend it): `swimAmount`, `speedValue`, `maxCrossbowChargeDuration`, `ticksUsingItem`, `useItemHand`, `isCrouching`, `isFallFlying`, `isVisuallySwimming`, `isPassenger`, `isUsingItem`, `elytraRotX/Y/Z`, and four equipment stacks (`headEquipment`, `chestEquipment`, `legsEquipment`, `feetEquipment`, each a **copy** of the slot's stack when it is renderable by the armor layer, else empty). Extraction (`HumanoidMobRenderer.extractHumanoidRenderState`): `speedValue` = 1; when fall flying: v = |deltaMovement|² / 0.2, then v = v x v x v, and v < 1 becomes 1; `swimAmount` = `getSwimAmount(partial)`; `ticksUsingItem` = `getTicksUsingItem(partial)`; `maxCrossbowChargeDuration` = the crossbow charge duration of the used item (as a float); elytra angles from the entity's elytra animation state. `HumanoidMobRenderer.extractRenderState` then sets `leftArmPose` and `rightArmPose` from `getArmPose` (3.6).

`ArmedEntityRenderState` fields: `mainArm`, `rightArmPose`, `rightHandItemState`, `rightHandItemStack`, `leftArmPose`, `leftHandItemState`, `leftHandItemStack`, `currentSwing`, `swingAnimation`; with `ticksUsingItem(arm)`. `HoldingEntityRenderState`: `heldItem`. `UndeadRenderState` (zombie family) adds no fields in this build; its subclass `ZombieRenderState` adds two booleans, `isAggressive` (the `animateZombieArms` flag, 3.5) and `isConverting`; `SlimeRenderState`: `squish` (float), `size` (int). `HitboxRenderState` is a record of a box (x0..z1), an offset and an RGB colour; in this build **no class in the jar creates it** (the F3+B hitbox display is the debug renderer, 7.5).

### 6.4 Registration table (159 types; 2 more in 6.2)

The master index in 10 shows the renderer class for every one of the 161 types. Facts shared by all rows:
- `area_effect_cloud`, `interaction` and `marker` use `NoopRenderer` (an `EntityRenderer` that creates a bare `EntityRenderState` and draws nothing; it still gets the base `EntityRenderer.submit`, so its name tag can show).
- `arrow` uses `TippableArrowRenderer`, `spectral_arrow` `SpectralArrowRenderer`.
- Throwables use `ThrownItemRenderer`: `snowball`, `egg`, `ender_pearl`, `experience_bottle`, `splash_potion`, `lingering_potion` with the default constructor; the constructor is `(context, scale, fullBright)` and the one-argument form means (1.0, false). Registrations read as (scale, fullBright): `snowball`, `egg`, `ender_pearl`, `experience_bottle`, `splash_potion`, `lingering_potion` = (1.0, false); `eye_of_ender` = (1.0, true); `fireball` = (3.0, true); `small_fireball` = (0.75, true). `fullBright` true makes `getBlockLightLevel` return 15; false uses the base rule (on fire gives 15, else the level's block brightness). `submit` pushes the pose, scales uniformly by `scale`, rotates by the camera orientation (billboard), submits the item render state (display context GROUND, extracted from the entity's `getItem`) with `lightCoords`, `NO_OVERLAY` and `outlineColor`, pops, then runs the base `EntityRenderer.submit`.
- `giant` uses `GiantMobRenderer` with scale 6.0.
- Boats: `BoatRenderer(layer)` for the ten wood types (`acacia`, `birch`, `cherry`, `dark_oak`, `jungle`, `mangrove`, `oak`, `pale_oak`, `poplar`, `spruce`; boat and chest boat = 20 types), `RaftRenderer(layer)` for bamboo (raft and chest raft); minecarts `MinecartRenderer(layer)` for minecart, chest, command block, furnace, hopper and spawner, `TntMinecartRenderer` for the TNT cart.
- Mobs with an adult and a baby model carry both layer constants in the registration lambda (`llama`, `trader_llama`, `squid`, `glow_squid`, `piglin`, `piglin_brute` (the same layer for adult and baby), `zombified_piglin`, `donkey`, `mule`, and the three undead horses) or inside the renderer constructor (all others).

### 6.5 The generic living-entity pose order (`LivingEntityRenderer.submit`)

All matrices stack on the right (the convention of 12 §7.3): the **last** operation listed acts **first** on a model vertex. With the entity-relative origin already set by the dispatcher (translation by the interpolated position plus `getRenderOffset(state)` = `passengerOffset` or zero):

1. If the pose is `SLEEPING` and a bed orientation exists: translate by (−stepX x (eyeHeight − 0.1), 0, −stepZ x (eyeHeight − 0.1)) where (stepX, stepZ) is the bed direction's unit step and `eyeHeight` is the standing eye height from 6.3.
2. Scale uniformly by `state.scale`.
3. `setupRotations(state, bodyRot, scale)` (below).
4. Scale by (−1, −1, 1).
5. The renderer's `scale(state, pose)` hook (default nothing; slime-like and others override).
6. Translate by (0, −1.501, 0).
7. Draw the model (and layers) at this pose.

`setupRotations` (default; subclasses may override or extend):
- If `isShaking(state)` (default: `isFullyFrozen`): bodyRot += cos(floor(ageInTicks) x 3.25) x π x 0.4000000059604645 (degrees).
- If the pose is not `SLEEPING`: rotate about Y by (180 − bodyRot) degrees.
- Then one of, tested in this order:
  - `deathTime` > 0: f = (deathTime − 1) / 20 x 1.6; f = sqrt(f); f = min(f, 1); rotate about Z by f x `getFlipDegrees()` (default 90°; a renderer may return another value).
  - `isAutoSpinAttack`: rotate about X by (−90 − `xRot`)°, then about Y by `ageInTicks` x (−75)°.
  - pose `SLEEPING`: rotate about Y by (bed direction yaw: SOUTH 90, WEST 0, NORTH 270, EAST 180; or `bodyRot` when no bed), then about Z by `getFlipDegrees()`, then about Y by 270.
  - `isUpsideDown`: translate by (0, (boundingBoxHeight + 0.1) / scale, 0), then rotate about Z by 180°.

After step 7, a body-visibility check chooses the render type for the base model (6.7) and submits the model; then, when the renderer says layers should render (`shouldRenderLayers`, default true) and the list is not empty, `model.setupAnim(state)` is called and each layer is submitted in list order with (pose, collector, light, state, yRot, xRot).

Baby rule in this version: there is **no global baby scale** in the pose chain. A baby differs by (a) the renderer choosing the baby model (`AgeableMobRenderer`, 6.6) whose geometry is separate or comes from a `BabyModelTransform`; (b) the shadow radius multiplied by `ageScale` (7.1; the factor is 0.5 for a baby except for the six overrides of 6.3); (c) a few layers' offsets (`ItemInHandLayer` baby offset, 8.3). The attribute-based `scale` still scales everything.

### 6.6 `MobRenderer`, `AgeableMobRenderer`, `AbstractCubeMobRenderer`, `HumanoidMobRenderer`

- `LivingEntityRenderer(context, model, shadowRadius)` stores the model, the item model resolver, an empty layer list (`addLayer` appends) and the base shadow radius; `getModel()` implements `RenderLayerParent`.
- `MobRenderer`: name tag rule (7.2): the living rule must pass and (`Mob.shouldShowName()` (always-show-name) or (has custom name and is the entity under the crosshair)); shadow radius = living radius x `ageScale`. `checkMagicName(entity, text)` = custom name equals text.
- `AgeableMobRenderer(context, adultModel, babyModel, shadowRadius)`: before the living submit sets `model` to the baby model when `state.isBaby` else the adult model.
- `AbstractCubeMobRenderer` (slime, magma cube, sulfur cube): the constructor's base shadow radius 0.25 is never used by this class; its `getShadowRadius` returns only `size` x 0.25 (it does not call the parent method, so `scale` and `ageScale` are not applied); `scale` hook: `applySizeAndSquish`: with n = `size`, q = `squish` / (n x 0.5 + 1), r = 1 / (q + 1), scale (r x n, n / r, r x n); `downscaleSlightly` scales by 0.999 and translates (0, 0.001, 0) (used by overlay models to avoid z-fighting). State: `squish` = lerp(partial, oSquish, squish); `size` = `getSize()`.
- `HumanoidMobRenderer(context, adultModel[, babyModel], shadowRadius[, headTransforms])`: an `AgeableMobRenderer` that adds three layers in this order: `CustomHeadLayer` (8.4), `WingsLayer` (elytra, equipment), `ItemInHandLayer` (8.3).

### 6.7 Render types (what the shared code selects)

`LivingEntityRenderer.getRenderType(state, bodyVisible, translucent, glowing)` chooses, in this order: if `translucent`, `entityTranslucentCull(texture)`; else if `bodyVisible`, the model's own function (`entityCutout(texture)` by default); else if `glowing`, `outline(texture)`; else no render type, and then the base model is not drawn (layers still are). The caller computes `bodyVisible` = not `isInvisible`; `translucent` = not `bodyVisible` and not `isInvisibleToPlayer` (an invisible entity the local player may still see, for example a teammate); `glowing` = `appearsGlowing`. The colour passed to the model is `multiply(translucent ? 654311423 : −1, getModelTint(state))` where 654311423 = 0x26FFFFFF (white at alpha 38 / 255, about 15%) and `getModelTint` is −1 (white) unless a renderer overrides it. The overlay passed is `getOverlayCoords(state, getWhiteOverlayProgress(state))` (6.9). The submission also carries `state.lightCoords` and `state.outlineColor`.

Pipelines read (`RenderPipelines`):

| Render type | Pipeline facts read |
|---|---|
| `entityCutout` | shader `entity`; discard fragments with alpha < 0.1; **per-face lighting** (the back faces are lit with the negated light dot products); culling **off** |
| `entityCutoutCull` | alpha cutout 0.1; culling default (on); standard lighting |
| `entityTranslucent` | alpha cutout 0.1; per-face lighting; TRANSLUCENT blend; culling off |
| `entityTranslucentCull` | alpha cutout 0.1; TRANSLUCENT blend; no per-face lighting; culling default (on) |
| `entity_cutout_z_offset` | same state as `entityCutout` (alpha cutout 0.1, per-face lighting, culling off) |
| `entity_cutout_dissolve` | alpha cutout 0.1; per-face lighting; define `DISSOLVE`; second sampler for the dissolve mask |
| `armorCutoutNoCull` and its glint variant | alpha cutout 0.1; `NO_OVERLAY`; per-face lighting; culling off (the glint variant adds the `GLINT` snippet) |
| `eyes` | TRANSLUCENT blend; depth test GREATER_THAN_OR_EQUAL; depth write off; no lightmap snippet (`entity` no-lightmap family) |
| `energySwirl` | ADDITIVE blend; default depth state |
| `entity_translucent_emissive` | alpha cutout 0.1; per-face lighting; TRANSLUCENT blend; culling off; depth GREATER_THAN_OR_EQUAL; depth write off; `EMISSIVE` snippet |
| `entityShadow` | TRANSLUCENT blend (entity-shadow snippet) |
| `leash` | shader `core/rendertype_leash`; vertex format POSITION_COLOR_LIGHTMAP; topology TRIANGLE_STRIP; culling off; default depth |
| `entity_solid_offset_forward`, `entity_solid_glint` | exist as `RenderPipelines` fields (names read; state not read: Open question 9) |
| `entitySolid`, `armorTrim`, `trimmedArmorGlint`, `outline` | named by the shared code; pipeline details not read (Open question 9) |

Shader defines of `entity.fsh` and `entity.vsh` (read): `ALPHA_CUTOUT = v` discards texels with alpha < v; `PER_FACE_LIGHTING` computes a front colour and a back colour in the vertex stage (the back uses the negated light terms) and the fragment stage picks by facing; without it, `NO_CARDINAL_LIGHTING` uses the vertex colour unlit by the two light directions, else the colour is mixed with the cardinal light; `NO_OVERLAY` removes the overlay mix; `EMISSIVE` removes the lightmap multiply; `DISSOLVE` discards when the vertex colour alpha is below the dissolve-mask alpha at the same texel and then forces the vertex alpha to 1 (dissolve replaces translucency); `GLINT` adds `GlintAlpha x glint texture` squared per channel to rgb after the lightmap and raises alpha to at least `GlintAlpha`; `OIT_ADDITIVE` caps texture alpha at 0.99 before the cutout test; `OIT_ACCUMULATE` converts the colour with the accumulation sampler and premultiplies the fog colour by alpha; `OIT_ALPHA_ONLY` skips colour output and only runs the alpha-only phase with the fragment depth and final alpha (the order-independent-transparency helper itself, `oit.glsl`, was not read).

The entity fragment stage (`entity.fsh`): colour = texture x lighting colour x `ColorModulator`; the **overlay** mixes: rgb = mix(overlay.rgb, colour.rgb, overlay.a); then x light map; then fog. The vertex stage: `Light0_Direction` and `Light1_Direction` dot the normal, `lightAccum = min(1, (max(0, d0) + max(0, d1)) x 0.6 + 0.4)` (the same formula as 12 §1.9); the light directions per setup are in 12 §1.9.

### 6.8 Culling

`EntityRenderer.shouldRender(entity, frustum, camX, camY, camZ, partial)`: false if `entity.shouldRender(camX, camY, camZ)` (distance rule of the entity class, 18) is false; true when the renderer says the entity is not affected by culling; else take the entity's interpolated bounding box inflated by 0.5 (living renderers inflate by a further 0.5 on all axes when the head slot holds a dragon head item); if that box has NaN or zero size use a 4-block cube around the entity position; visible if the frustum sees it; for a leashed entity (`Leashable` with a holder) visible when the frustum sees the holder's box or the union of both boxes.

### 6.9 Light and overlay coordinates

- `lightCoords` = pack(blockLight, skyLight) of the block containing the entity's light-probe position (`getLightProbePosition(partial)`, whose position rule was not traced). Block light = 15 when the entity is on fire, else the level's block brightness; sky light = the level's sky brightness. `LightCoordsUtil.pack(block, sky)` = (block << 4) | (sky << 20); `withBlock(coords, b)` = (coords AND 0x00FF0000) | (b << 4); full bright = 15728880 (0xF000F0).
- `getOverlayCoords(state, whiteProgress)` = pack(u, v): u = trunc(whiteProgress x 15), v = 3 when `hasRedOverlay` else 10; `OverlayTexture.pack(u, v)` = u | (v << 16). The 16 x 16 overlay texture: rows y 0 to 7 are the **red** overlay (ARGB 0xB2FF0000 for every column); rows 8 to 15 are **white** with alpha = floor((1 − (x / 15) x 0.75) x 255) in column x (x = 0 is alpha 255, no change; x = 15 is alpha 63). With the mix rule of 6.7, the red row tints 30% red (alpha 178 / 255 keeps 70% of the colour) and white column x mixes in `1 − alpha/255` white: column 15 is 75% white. `NO_OVERLAY` = pack(0, 10) (white row, no tint). `getWhiteOverlayProgress(state)` is 0 by default and overridden by creeper-like swell and others (the sibling parts 3 to 7).

---
## 7. Generic pipeline pieces submitted by the entity renderers

### 7.1 Shadow (`EntityRenderer.extractShadow`, `ShadowFeatureRenderer`)

Applies to every entity with a renderer. In `EntityRenderer`: `shadowRadius` (set by the constructor of a living renderer from its argument; 0 by default for others) and `shadowStrength` (default 1).

1. Radius R = `getShadowRadius(state)`, capped at 32. `LivingEntityRenderer` multiplies the base radius by `state.scale`; `MobRenderer` multiplies that by `state.ageScale` (so a baby has half the shadow of an adult, a scaled mob its scale); `AbstractCubeMobRenderer` replaces it entirely with `size` x 0.25 (int converted to float; no multiplication by `scale` or `ageScale`: the method does not call the parent). A baby has half the shadow of an adult only for mobs that keep the base `getAgeScale` (the turtle, dolphin, camel, goat, happy ghast and armadillo use the factors of 6.3). The stored `state.shadowRadius` = R. No shadow when the option `entityShadows` is off, when the entity is invisible, or when R is not positive.
2. Strength s = (1 − `distanceToCameraSq` / 256) x `getShadowStrength(state)` (default 1): shadows fade out linearly until 16 blocks and are absent beyond. Nothing when s is not positive.
3. Column range: x from floor(x − R) to floor(x + R), z from floor(z − R) to floor(z + R). Vertical range: m = min(s / 0.5 − 1, R); y from floor(y − m) to floor(y) inclusive. The loops run z outermost, x next and y innermost, each ascending.
4. For each cell (bx, by, bz), with `below` the block at (bx, by − 1, bz) in the chunk of that column, `extractShadowPiece(state, level, s, cell, chunk)`:
   - f = s − (y − by) x 0.5 (the stronger, the closer the cell's floor is to the entity's feet).
   - Skip when `below`'s render shape is `INVISIBLE`; when the **maximum local raw brightness** at the cell is 3 or less (dark places have no shadow); when `below`'s collision shape is not a full block; or when its (outline) shape is empty.
   - alpha = clamp(f x 0.5 x `Lightmap.getBrightness(dimensionType, brightness)`, 0, 1). `Lightmap.getBrightness(dimensionType, level)` (read): a = level / 15; b = a / (4 − 3a); result = lerp(`ambientLight`, b, 1) = b + ambientLight (1 − b). The dimension type `ambient_light` is 0.0 for `overworld` and `overworld_caves`, 0.1 for `the_nether` and 0.25 for `the_end` (read from `data/minecraft/dimension_type/*.json`; the same values as 12). Examples: level 15 gives 1 in every dimension; level 7 in the overworld gives a = 0.46667, b = 0.46667 / 2.6 = 0.17949; level 7 in the End gives 0.17949 + 0.25 x 0.82051 = 0.38462.
   - A piece = (bx − x, by − y, bz − z, the below shape, alpha), with the entity's interpolated position x, y, z.
5. Drawing (`ShadowFeatureRenderer`): one quad per piece, in the entity-relative frame (the dispatcher has translated to the entity position, and for the avatar the render offset is undone around the shadow). With bounds = the below shape's bounding box: x0 = relX + minX, x1 = relX + maxX, y = relY + minY, z0 = relZ + minZ, z1 = relZ + maxZ. Texture `textures/misc/shadow.png`; for a corner at (x, z): u = −x / 2 / R + 0.5, v = −z / 2 / R + 0.5. Vertices in order: (x0, y, z0; u(x0), v(z0)), (x0, y, z1; u(x0), v(z1)), (x1, y, z1; u(x1), v(z1)), (x1, y, z0; u(x1), v(z0)). Colour = white with alpha = the piece alpha (as `ARGB.white(float)`: alpha byte = floor(alpha x 255)), light = 15728880 (full bright), overlay none, normal (0, 1, 0). Render type `entityShadow` with that texture.

### 7.2 Name tag (`EntityRenderer.extractNameTags`, `submitNameDisplay`, `SubmitNodeCollection.submitNameTag`)

Extraction: two distances: the **name distance** (squared compare with 64² for non-living entities; for living entities the `name_tag_distance` attribute, default 64, 18 framework) and the **score distance** (10, or the `below_name_distance` attribute for living entities, default 10). With d² = `distanceToCameraSq`: the name is extracted when d² < nameDistance² and `shouldShowName(entity, d²)`; the score text (`Entity.belowNameDisplay()`) when d² < scoreDistance². The name text is `getNameTag(entity)` = the entity's display name; its position is the `NAME_TAG` entity attachment at index 0 rotated by the entity yaw, i.e. (0, `nameTagOffset` y, 0) when the entity type set a name-tag offset (18 framework gives the values) and otherwise (0, bounding height, 0) (the fallback `AT_HEIGHT`).

Show rules: `EntityRenderer.shouldShowName`: `Entity.shouldShowName()` (always show) or (has custom name and this entity is the one under the crosshair). `LivingEntityRenderer`: if the entity is discrete (sneaking) and d² ≥ 1024 then no; let v = not invisible to the local player; if the entity is not the local player and has a team (the test is the identity of the entity versus the local player and the presence of a team, not whether the two teams differ), the entity's team name-tag visibility decides: team visibility `ALWAYS` gives v, `NEVER` gives false, `HIDE_FOR_OTHER_TEAMS` gives (local player has no team ? v : (allied to the local player's team and (the team can see friendly invisibles or v))), `HIDE_FOR_OWN_TEAM` gives (local player has no team ? v : (not allied and v)) (read: a teammate takes this branch and returns the value directly, never reaching the generic test below; the local player's team is null-checked only inside the `HIDE_*` cases); otherwise (the entity is the local player or has no team): the HUD is not hidden, the entity is not the camera entity, v, and the entity is not a vehicle. `MobRenderer` additionally requires the always-show or crosshair rule above.

Submission (`submitNameDisplay`): push; if score text exists: submit it at the attachment (y argument 0) then translate by (0, 9 x 1.15 x 0.025, 0) (9 = font line height in pixels, 0.025 = `NAMETAG_SCALE`); then submit the name; pop. `submitNameTag(pose, point, y, text, seeThrough, light, camera)`: push; translate to (point.x, point.y + 0.5, point.z); rotate by the camera orientation (billboard); scale (0.025, −0.025, 0.025); x = −(text width)/2 pixels, y as given. Let o = the options' background opacity (default argument 0.25); background = `ARGB.color(o, black)`; alpha a = max((o + 0.75) x 0.5, 0.5); text colour = white with alpha a. `seeThrough` = not `isDiscrete`. When see-through: two text submissions: first a normal depth-tested text with colour −1 (opaque white), background 0 and light = `lightCoordsWithEmission(light, 2)`; then a see-through (translucent phase) text with the alpha colour and the background. When not see-through (sneaking): one normal submission with the alpha colour and background and the plain light.

### 7.3 Leash (`EntityRenderer.extractRenderState`, `LeashFeatureRenderer`)

Extraction (only for a `Leashable` entity with a holder): rotation angle r = precise body rotation x 0.017453292; `getLeashOffset(partial)` rotated about Y by −r gives the attachment offset on the leashed entity; block lights at the eye positions of leashed entity and holder (block light uses the renderer's rule 6.9) and sky lights likewise. If both support **quad leashes** (`supportQuadLeashAsHolder` and `supportQuadLeash`): 4 leash states, one per pair of offsets (`getQuadLeashOffsets` of the leashed entity rotated by −r; `getQuadLeashHolderOffsets` of the holder rotated by the holder's −rotation, added to the holder position); `slack` false. Otherwise one state: start = entity position + rotated offset, end = holder's `getRopeHoldPosition(partial)`.

Drawing (per state): d = end − start; k = invSqrt(dx² + dz²) x 0.05 / 2; (sx, sz) = (dz x k, dx x k) (a horizontal vector perpendicular to the leash with length 0.025); translate by the state's `offset`; then 25 vertex pairs i = 0..24 in a **forward pass** (half-thickness argument 0.05) followed by a **backward pass** i = 24..0 (argument 0), t = i / 24; per pair: block light = int(lerp(t, startBlock, endBlock)) and sky light likewise, packed as in 6.9; shade = 0.7 when (i mod 2) equals (backward pass ? 1 : 0), else 1.0; colour (0.5, 0.4, 0.3) x shade, alpha 1; point P(t) = (dx t, dy t, dz t) where, if `slack`, dy t is replaced by dy t² (dy > 0) or dy − dy (1 − t)² (dy ≤ 0). Vertex A = P + (−sx, +w, +sz) and vertex B = P + (+sx, 0.05 − w, −sz) where w is the pass argument (0.05 forward, 0 backward). The render type is `leash` (a strip with no texture). The leash is therefore a ribbon 0.05 wide and 0.05 thick, twisted in two passes, brown (0.5, 0.4, 0.3) alternating with 0.7 darker segments of length 1/24.

### 7.4 Fire (`EntityRenderDispatcher.submit`, `FlameFeatureRenderer`)

When `displayFireAnimation` (the entity is burning and not fire-immune: `Entity.displayFireAnimation()`), the dispatcher submits a flame after the model: pose = entity origin; rotation = the camera orientation reduced to a rotation about the Y axis (`Mth.rotationAroundAxis(Y_AXIS, cameraOrientation)`; the meaning of the helper was not traced). The flame uses the **block atlas** sprites `FIRE_0` and `FIRE_1` with render type `entityCutoutCull`, and the following geometry (all numbers read):

1. s = `boundingBoxWidth` x 1.4; scale the pose by (s, s, s). Half width w = 0.5, z-shift zs = 0, rise m = 0, remaining height h = `boundingBoxHeight` / s, quad index i = 0.
2. Rotate by the camera's Y rotation; then translate by (0, 0, 0.3 − int(h) x 0.02) (`int(h)` truncates toward zero).
3. Light = `withBlock(lightCoords, 15)`: block light forced to 15.
4. While h > 0: the sprite is `FIRE_0` when i is even and `FIRE_1` when odd (the even/odd assignment follows the order in which the two sprites are fetched: inferred); let (uA, vA, uB, vB) = the sprite's (u0, v0, u1, v1) and, when floor(i / 2) is even, swap uA and uB. Emit one quad with vertices (x, y, z; u, v): (−w, 0 − m, zs; uB, vB), (w, 0 − m, zs; uA, vB), (w, 1.4 − m, zs; uA, vA), (−w, 1.4 − m, zs; uB, vA), each white (−1), overlay (0, 10), normal (0, 1, 0). Then h −= 0.45, m −= 0.45, w x= 0.9, zs −= 0.03, i += 1. Because m becomes more negative, each later quad sits 0.45 higher, narrower (x0.9) and 0.03 nearer to the camera-facing plane than the one before.

### 7.5 Hitbox display (`EntityHitboxDebugRenderer`, the F3+B debug entry)

Not part of normal rendering. For each non-invisible entity that is visible to the frustum and is not the first-person camera entity: a cuboid outline of the entity's bounding box (white, ARGB −1) and a point of size 2 at the entity position; if the entity has a vehicle: a small yellow (ARGB 0xFFFFFF00) cuboid of half-width min(width, vehicle width)/2 and height 0.0625 at the vehicle's passenger riding position; for a living entity: a red (ARGB 0xFFFF0000) thin box at the eye height (box spanning eyeHeight ± 0.01 above the minimum y); for the ender dragon: the boxes of its sub-entities. The local-server comparison (green, ARGB 0xFF00FF00) is only when a debug constant is on. The view-direction line and any remaining items of the method were not read (Open question 13). `HitboxRenderState` (6.3) is unused in this build.

---

## 8. Generic layers

### 8.1 `RenderLayer<S, M>`

A layer holds its `RenderLayerParent` and exposes `getParentModel()`. `submit(pose, collector, light, state, yRot, xRot)` is called once per layer per frame in the order of the renderer's layer list, after the base model, with the same pose stack as the model (6.5 steps 1 to 6 applied). Two shared helpers: `coloredCutoutModelCopyLayerRender(model, texture, pose, collector, light, state, colour, order)` does nothing when the entity is invisible, else calls `renderColoredCutoutModel`, which submits `model` with render type `entityCutout(texture)`, the given light, overlay `getOverlayCoords(state, 0)` (so the red hurt tint applies but not the white flash) and the given colour on submission order `order`. The `order(n)` of a collector sorts submissions: n = 0 for the base model, so layers with n >= 1 draw later (this build's ordering semantics were not traced further: Open question 12).

### 8.2 Equipment (`EquipmentLayerRenderer`, `SimpleEquipmentLayer`)

`SimpleEquipmentLayer(parent, equipmentRenderer, layerType, itemGetter, adultModel, babyModel[, order])` draws one equipment item: take the stack from `itemGetter(state)`; require the `EQUIPPABLE` component with a present `assetId`; when the entity is a baby and no baby model was given, draw nothing; pick the baby or adult model and call `renderLayers(layerType, assetId, model, state, stack, pose, collector, light, outlineColor, order)`.

`renderLayers`: look up the `EquipmentClientInfo` for the asset key and take the list of layers for the layer type (empty: return; data and schema in 22). Let dye = the stack's dyed colour (0 when none), foil = the stack has the enchantment glint, trim = the `TRIM` component present and the layer type is not `HUMANOID_BABY`. Glint is drawn on the base layers only when foil and no trim (and only on the first layer: the flag is cleared after the first submission). For each layer in order: colour = `getColorForLayer`: if the layer is dyeable, the dye colour when it is non-zero, else the layer's `colorWhenUndyed` (opaque) or 0; not dyeable gives −1 (white). A colour of 0 skips the layer. The texture is the layer's texture location for the layer type, or the player's own texture when the layer says `usePlayerTexture` and one is supplied. Render type `armorCutoutNoCullGlint(texture)` for the glinted first layer, else `armorCutoutNoCull(texture)`; submission order = the running order (starts at `order`, +1 per submission); light = the entity light; overlay = none; colour as computed. Then, with a trim: look up the trim texture (a paletted texture produced from the trim pattern and material by the paletted texture manager: DATA and tool, 22) and submit it with `armorTrim(texture, decal)` in white; then if foil, one more submission with `trimmedArmorGlint`.

### 8.3 `ItemInHandLayer` (needs `ArmedModel`)

Draws the right hand item then the left hand item: `submitArmWithItem(state, itemState, stack, arm, pose, collector, light)`, skipped when the item render state is empty:
1. push; `model.translateToHand(state, arm, pose)`.
2. rotate about X by −90°, about Y by 180°.
3. translate by (±x/16, y/16, z/16) with x sign −1 for the left arm and +1 for the right: **adult**: (±1, 2, −10) x 1/16; **baby** (`useBabyOffset`: the state is a baby and the entity type is not `armor_stand`): (0, 1, −4.5) x 1/16. (The x component is `sign x (baby ? 0 : 1)`; y = baby ? 1 : 2; z = baby ? −4.5 : −10.)
4. If a swing exists, the swing's hand converted to an arm using the state's main arm (`InteractionHand.asArm(mainArm)`) equals the arm being drawn, and the swing animation type is `STAB`: `SpearAnimations.thirdPersonAttackItem` (3.8).
5. If `ticksUsingItem(arm)` is non-zero: `armPose.animateUseItem(state, pose, ticks, arm, stack)` with the arm pose of that side (right pose for the right arm); for the `SPEAR` pose this is the spear use animation (3.8).
6. Submit the item render state with light, no overlay, outline colour; pop.

### 8.4 `CustomHeadLayer` (helmet block, skull and head item)

Constants: `ITEM_SCALE` 0.625, `SKULL_SCALE` 1.1875. A `Transforms` record (yOffset, skullYOffset, horizontalScale, verticalScale, player-skin render type resolver); `DEFAULT` = (0, 0, 1, 1) (the humanoid renderer's default). Applies when `headItem` is not empty or `wornHeadType` is set (6.3):
1. push; scale by (horizontalScale, verticalScale, horizontalScale).
2. Apply the **model root's** `translateAndRotate`, then `translateToHead` (the head part's).
3. Skull: translate (0, skullYOffset, 0); scale by 1.1875; render the skull model for the skull type with `wornHeadAnimationPos`, with the player-skin render type for a player skull that has a profile (translucent or cutout resolver), else the type's own skull render type.
4. Other head item: `translateToHead(pose, transforms)`: translate (0, −0.25 + yOffset, 0); rotate about Y by 180°; scale (0.625, −0.625, −0.625); submit the item render state with light and no overlay.
5. pop.

### 8.5 `EyesLayer`, `LivingEntityEmissiveLayer`, `EnergySwirlLayer`

- `EyesLayer`: an abstract layer whose subclass gives a render type (a texture drawn bright). It submits the **parent's own model** (the same baked parts, already posed) at order 1 with that render type, the entity light, no overlay and no tint. (Spider, enderman, phantom, breeze eyes: the textures and render types in parts 6 and 7.)
- `LivingEntityEmissiveLayer(parent, textureFn, alphaFn, model, renderTypeFn, alwaysVisible)`: skip when the entity is invisible unless `alwaysVisible`; a = `alphaFn(state, ageInTicks)`; skip when a <= 1.0E-5; submit the layer's own model (`model`, posed by the renderer) at order 1 with `renderTypeFn(textureFn(state))`, the entity light, overlay `getOverlayCoords(state, 0)` and tint = white with alpha a (`ARGB.white(float)`).
- `EnergySwirlLayer` (charged creeper, wither armor): skip when `isPowered(state)` is false; t = `ageInTicks`; submit `model()` at order 1 with `energySwirl(texture, xOffset(t) mod 1, t x 0.01 mod 1)` (the two numbers are the scrolling texture offsets), light = entity light, no overlay, tint ARGB −8355712 (0xFF808080: grey 50%). `xOffset`, `isPowered`, `model` and the texture are supplied by the subclass.

### 8.6 Layers whose behaviour is in other documents

| Layer class | Used by | Documented in |
|---|---|---|
| `HumanoidArmorLayer`, `WingsLayer` | `HumanoidMobRenderer`, `ArmorStandRenderer` (and `WingsLayer`) | part 2 (armor on zombies, skeletons, piglins, giant, and the armor stand); player: 12 §7 |
| `CapeLayer`, `Deadmau5EarsLayer`, `PlayerItemInHandLayer`, `SpinAttackEffectLayer`, `ParrotOnShoulderLayer` | player | 12 §7.6 (cape and ears only); the rest is player-only and not in the 161 non-player renderers' lists (no top-level class of `renderer.entity` references `ParrotOnShoulderLayer` or `SpinAttackEffectLayer`; the avatar renderer in `renderer.entity.player` was not read here) |
| `CrossedArmsItemLayer`, `VillagerProfessionLayer`, `WitchItemLayer`, `SkeletonClothingLayer`, `DrownedOuterLayer` | villager and trader, villager, witch, stray and bogged, drowned | part 3 (villagers, witch), part 2 (skeleton clothing, drowned outer) |
| `CarriedBlockLayer`, `EnderEyesLayer`, `IronGolemCrackinessLayer`, `IronGolemFlowerLayer`, `SnowGolemHeadLayer`, `WitherArmorLayer`, `BlockDecorationLayer` (copper golem) | enderman, iron golem, snow golem, wither, copper golem | part 6 (enderman), part 3 (golems), part 7 (wither) |
| `CreeperPowerLayer`, `SlimeOuterLayer`, `SulfurCubeInnerLayer`, `SpiderEyesLayer`, `PhantomEyesLayer`, `BreezeEyesLayer`, `BreezeWindLayer` | creeper, slime and magma cube, sulfur cube, spider, phantom, breeze | part 6 |
| `SheepWoolLayer`, `SheepWoolUndercoatLayer`, `MushroomCowMushroomLayer`, `LlamaDecorLayer`, `HorseMarkingLayer` | sheep, mooshroom, llama, horse | part 4 |
| `CatCollarLayer`, `WolfCollarLayer`, `WolfArmorLayer`, `FoxHeldItemLayer`, `PandaHoldsItemLayer`, `RopesLayer` (happy ghast) | cat, wolf, fox, panda, happy ghast | part 5 (cat, wolf, fox, panda), part 4 (happy ghast) |
| `DolphinCarryingItemLayer`, `TropicalFishPatternLayer` | dolphin, tropical fish | part 8 |
| `StuckInBodyLayer`, `ArrowLayer`, `BeeStingerLayer` | player only | 8.7 |

### 8.7 `StuckInBodyLayer`, `ArrowLayer`, `BeeStingerLayer` (player layers, `AvatarRenderState`)

`StuckInBodyLayer<M extends PlayerModel, S>` draws N small models stuck in the body, where N = `numStuck(state)`: `ArrowLayer` uses `AvatarRenderState.arrowCount` with the `ArrowModel` (layer `minecraft:arrow#main`) and the arrow texture `TippableArrowRenderer.NORMAL_ARROW_LOCATION` with placement style `IN_CUBE`; `BeeStingerLayer` uses `stingerCount` with `BeeStingerModel` (layer `minecraft:bee_stinger#main`), texture `textures/entity/bee/bee_stinger.png` and placement `ON_SURFACE`. The layer returns when N <= 0. It creates a thread-local random source seeded with the entity id (`RandomSource.createThreadLocalInstance(id)`: the same stuck items every frame). For k in 0..N−1: push; pick a random body part (`PlayerModel.getRandomBodyPart(random)`) then a random cuboid of it (`ModelPart.getRandomCube`); apply that part's `translateAndRotate`; draw three random floats a, b, c in [0, 1); for `ON_SURFACE`: draw `nextInt(3)`: 0 snaps a, 1 snaps b, otherwise c, where snap(f) = (f > 0.5 ? 1 : 0.5); translate by (lerp(a, minX, maxX), lerp(b, minY, maxY), lerp(c, minZ, maxZ)) / 16 using the cuboid's un-grown bounds; then with (ax, ay, az) = (−(2a − 1), −(2b − 1), −(2c − 1)) (the direction from the cuboid centre to the point): r = sqrt(ax² + az²), yaw = atan2(ax, az) in degrees (using the constant 57.2957763671875), pitch = atan2(ay, r) in degrees; rotate about Y by (yaw − 90) and about Z by pitch; submit the model (with its own state object) with the texture, the entity light, no overlay and the outline colour; pop. (Exact random generator algorithm: Open question 14.)

---

## 9. The per-entity record (schema for parts 2 to 9)

Every entity type documented in parts 2 to 9 gets one record (part numbering as in section 10). Fields, with the source in the artifact:

| Field | Type | Meaning and source |
|---|---|---|
| `registry_name` | `Identifier` | the entity type key from 21 §2 (for example `minecraft:cow`) |
| `numeric_id` | int | the Add Entity id (21 §2, the "inferred" id order of 04 §5.1) |
| `renderer` | class name + constructor arguments | the row of the master index (10); `NoopRenderer` means nothing is drawn |
| `state_class` | class | the render state class (`CowRenderState` ...) with its extra fields (6.3 gives the bases) |
| `model_layers` | list of layer ids | `ModelLayers` locations the renderer bakes (4.2), with role (`main`, `baby`, `armor`, `saddle`, `outer`) |
| `texture_ids` | list of `Identifier` | texture paths by variant and the rule selecting them (DATA, supplied by the pack) |
| `shadow_radius` | float | the base radius argument passed to `LivingEntityRenderer` (blocks); final radius per 7.1 |
| `shadow_strength` | float | default 1 unless the renderer sets it |
| `name_tag_offset` | float | the builder's `nameTagOffset` y, else the bounding height (7.2; values in 18 framework) |
| `hitbox`, `eye_height` | floats | `sized(w, h)` and `eyeHeight` in 21 §2 (the same numbers feed `state.boundingBoxWidth`, `boundingBoxHeight`, `eyeHeight`) |
| `baby_rule` | enum | one of: `none` (no baby), `separate_model` (adult/baby pair, 3.3), `transform` (`BabyModelTransform` over the adult mesh, 2.3), `shared_model_scaled` (a model that scales itself by `ageScale`: given by the owning part); plus the baby shadow factor `ageScale` |
| `layers` | ordered list | `RenderLayer`s added by the constructor, in order, with parameters (8) |
| `model_class` | class | the `EntityModel` subclass and its constructor-read part names |
| `parts` | table | the part tree (1.2) |
| `animation` | text | the `setupAnim` formulas and the keyframe definitions used (5) |
| `render_state_fields` | list | fields the state carries and the entity inputs that feed them |
| `render_type` | text | any non-default render type (translucent outer layer, eyes, swirl) |
| `scale_hooks` | text | `scale(state, pose)`, `getFlipDegrees`, `getWhiteOverlayProgress`, `isShaking`, `shouldShowName` overrides |
| `ids` | list | stable ids of the layers and animation definitions the record uses (4.2, 4.4) |

---

## 10. Master index: 161 entity types, renderer, documenting part

Parts, regenerated from the sibling documents' Covers sections: 2 humanoid-base mobs (zombies, skeletons, piglins, armor stand); 3 villagers, illagers, golems and miscellaneous (witch, vex, ravager, evoker fangs, creaking, allay, copper, iron and snow golems); 4 farm and ridable land animals (including llama spit, happy ghast and rabbit); 5 wild and companion animals and small creatures; 6 creeper, enderman, endermite, silverfish, spiders, slimes and sulfur cube, warden, breeze, phantom, guardians, shulker and shulker bullet; 7 Nether and End mobs and bosses (with the wither skull, end crystal and dragon fireball); 8 aquatic mobs, nautilus family and boats and rafts; 9 entities without a living-mob model (minecarts, projectiles, thrown items, items, frames, paintings, displays, effects, the no-op renderers). Projectiles, minecarts, item entities and displays are in part 9 (not part 8, which is boats and aquatic mobs); `breeze_wind_charge` is allocated to part 9 with `wind_charge` (part 9 lists both). Types whose renderer sits with a sibling are placed by that sibling's Covers text: evoker fangs (part 3), shulker bullet (part 6), llama spit (part 4), wither skull, end crystal and dragon fireball (part 7). In the renderer column `ML.` abbreviates `ModelLayers.` and `LT.` the equipment `LayerType`. Counts per part: 2: 13, 3: 16, 4: 18, 5: 14, 6: 16, 7: 10, 8: 32 (10 aquatic and nautilus, 20 boats, 2 rafts), 9: 42 (total 161). `player` and `mannequin` are listed under part 9 as cross-references to 12 §7 only (part 9 mentions both). The id order is the initializer order of the static `EntityType` fields of `EntityTypes` (read: 161 fields, 0 to 160, identical to the table); that the numeric id equals the registration order is the registry's rule (inferred from 21 §2).

| Id | Registry key | Renderer (constructor arguments read) | Part |
|---|---|---|---|
| 0 | `acacia_boat` | BoatRenderer(ML.ACACIA_BOAT) | 8 |
| 1 | `acacia_chest_boat` | BoatRenderer(ML.ACACIA_CHEST_BOAT) | 8 |
| 2 | `allay` | AllayRenderer | 3 |
| 3 | `area_effect_cloud` | NoopRenderer | 9 |
| 4 | `armadillo` | ArmadilloRenderer | 5 |
| 5 | `armor_stand` | ArmorStandRenderer | 2 |
| 6 | `arrow` | TippableArrowRenderer | 9 |
| 7 | `axolotl` | AxolotlRenderer | 8 |
| 8 | `bamboo_chest_raft` | RaftRenderer(ML.BAMBOO_CHEST_RAFT) | 8 |
| 9 | `bamboo_raft` | RaftRenderer(ML.BAMBOO_RAFT) | 8 |
| 10 | `bat` | BatRenderer | 5 |
| 11 | `bee` | BeeRenderer | 5 |
| 12 | `birch_boat` | BoatRenderer(ML.BIRCH_BOAT) | 8 |
| 13 | `birch_chest_boat` | BoatRenderer(ML.BIRCH_CHEST_BOAT) | 8 |
| 14 | `blaze` | BlazeRenderer | 7 |
| 15 | `block_display` | DisplayRenderer.BlockDisplayRenderer | 9 |
| 16 | `bogged` | BoggedRenderer | 2 |
| 17 | `breeze` | BreezeRenderer | 6 |
| 18 | `breeze_wind_charge` | WindChargeRenderer | 9 |
| 19 | `camel` | CamelRenderer | 4 |
| 20 | `camel_husk` | CamelHuskRenderer | 4 |
| 21 | `cat` | CatRenderer | 5 |
| 22 | `cave_spider` | CaveSpiderRenderer | 6 |
| 23 | `cherry_boat` | BoatRenderer(ML.CHERRY_BOAT) | 8 |
| 24 | `cherry_chest_boat` | BoatRenderer(ML.CHERRY_CHEST_BOAT) | 8 |
| 25 | `chest_minecart` | MinecartRenderer(ML.CHEST_MINECART) | 9 |
| 26 | `chicken` | ChickenRenderer | 4 |
| 27 | `cod` | CodRenderer | 8 |
| 28 | `copper_golem` | CopperGolemRenderer | 3 |
| 29 | `command_block_minecart` | MinecartRenderer(ML.COMMAND_BLOCK_MINECART) | 9 |
| 30 | `cow` | CowRenderer | 4 |
| 31 | `creaking` | CreakingRenderer | 3 |
| 32 | `creeper` | CreeperRenderer | 6 |
| 33 | `cushion` | CushionRenderer | 9 |
| 34 | `dark_oak_boat` | BoatRenderer(ML.DARK_OAK_BOAT) | 8 |
| 35 | `dark_oak_chest_boat` | BoatRenderer(ML.DARK_OAK_CHEST_BOAT) | 8 |
| 36 | `dolphin` | DolphinRenderer | 8 |
| 37 | `donkey` | DonkeyRenderer(LT.DONKEY_SADDLE, ML.DONKEY_SADDLE, DonkeyRenderer.Type.DONKEY, DonkeyRenderer.Type.DONKEY_BABY) | 4 |
| 38 | `dragon_fireball` | DragonFireballRenderer | 7 |
| 39 | `drowned` | DrownedRenderer | 2 |
| 40 | `egg` | ThrownItemRenderer(1.0, false) | 9 |
| 41 | `elder_guardian` | ElderGuardianRenderer | 6 |
| 42 | `enderman` | EndermanRenderer | 6 |
| 43 | `endermite` | EndermiteRenderer | 6 |
| 44 | `ender_dragon` | EnderDragonRenderer | 7 |
| 45 | `ender_pearl` | ThrownItemRenderer(1.0, false) | 9 |
| 46 | `end_crystal` | EndCrystalRenderer | 7 |
| 47 | `evoker` | EvokerRenderer | 3 |
| 48 | `evoker_fangs` | EvokerFangsRenderer | 3 |
| 49 | `experience_bottle` | ThrownItemRenderer(1.0, false) | 9 |
| 50 | `experience_orb` | ExperienceOrbRenderer | 9 |
| 51 | `eye_of_ender` | ThrownItemRenderer(1.0, true) | 9 |
| 52 | `falling_block` | FallingBlockRenderer | 9 |
| 53 | `fireball` | ThrownItemRenderer(3.0, true) | 9 |
| 54 | `firework_rocket` | FireworkEntityRenderer | 9 |
| 55 | `fox` | FoxRenderer | 5 |
| 56 | `frog` | FrogRenderer | 5 |
| 57 | `furnace_minecart` | MinecartRenderer(ML.FURNACE_MINECART) | 9 |
| 58 | `ghast` | GhastRenderer | 7 |
| 59 | `happy_ghast` | HappyGhastRenderer | 4 |
| 60 | `giant` | GiantMobRenderer(6.0f) | 2 |
| 61 | `glow_item_frame` | ItemFrameRenderer | 9 |
| 62 | `glow_squid` | GlowSquidRenderer(ML.GLOW_SQUID, ML.GLOW_SQUID_BABY) | 8 |
| 63 | `goat` | GoatRenderer | 4 |
| 64 | `guardian` | GuardianRenderer | 6 |
| 65 | `hoglin` | HoglinRenderer | 7 |
| 66 | `hopper_minecart` | MinecartRenderer(ML.HOPPER_MINECART) | 9 |
| 67 | `horse` | HorseRenderer | 4 |
| 68 | `husk` | HuskRenderer | 2 |
| 69 | `illusioner` | IllusionerRenderer | 3 |
| 70 | `interaction` | NoopRenderer | 9 |
| 71 | `iron_golem` | IronGolemRenderer | 3 |
| 72 | `item` | ItemEntityRenderer | 9 |
| 73 | `item_display` | DisplayRenderer.ItemDisplayRenderer | 9 |
| 74 | `item_frame` | ItemFrameRenderer | 9 |
| 75 | `jungle_boat` | BoatRenderer(ML.JUNGLE_BOAT) | 8 |
| 76 | `jungle_chest_boat` | BoatRenderer(ML.JUNGLE_CHEST_BOAT) | 8 |
| 77 | `leash_knot` | LeashKnotRenderer | 9 |
| 78 | `lightning_bolt` | LightningBoltRenderer | 9 |
| 79 | `llama` | LlamaRenderer(ML.LLAMA, ML.LLAMA_BABY) | 4 |
| 80 | `llama_spit` | LlamaSpitRenderer | 4 |
| 81 | `magma_cube` | MagmaCubeRenderer | 6 |
| 82 | `mangrove_boat` | BoatRenderer(ML.MANGROVE_BOAT) | 8 |
| 83 | `mangrove_chest_boat` | BoatRenderer(ML.MANGROVE_CHEST_BOAT) | 8 |
| 84 | `mannequin` | AvatarRenderer (WIDE / SLIM; mannequin map; 12 §7) | 9 |
| 85 | `marker` | NoopRenderer | 9 |
| 86 | `minecart` | MinecartRenderer(ML.MINECART) | 9 |
| 87 | `mooshroom` | MushroomCowRenderer | 4 |
| 88 | `mule` | DonkeyRenderer(LT.MULE_SADDLE, ML.MULE_SADDLE, DonkeyRenderer.Type.MULE, DonkeyRenderer.Type.MULE_BABY) | 4 |
| 89 | `nautilus` | NautilusRenderer | 8 |
| 90 | `oak_boat` | BoatRenderer(ML.OAK_BOAT) | 8 |
| 91 | `oak_chest_boat` | BoatRenderer(ML.OAK_CHEST_BOAT) | 8 |
| 92 | `ocelot` | OcelotRenderer | 5 |
| 93 | `ominous_item_spawner` | OminousItemSpawnerRenderer | 9 |
| 94 | `painting` | PaintingRenderer | 9 |
| 95 | `pale_oak_boat` | BoatRenderer(ML.PALE_OAK_BOAT) | 8 |
| 96 | `pale_oak_chest_boat` | BoatRenderer(ML.PALE_OAK_CHEST_BOAT) | 8 |
| 97 | `panda` | PandaRenderer | 5 |
| 98 | `parched` | ParchedRenderer | 2 |
| 99 | `parrot` | ParrotRenderer | 5 |
| 100 | `phantom` | PhantomRenderer | 6 |
| 101 | `pig` | PigRenderer | 4 |
| 102 | `piglin` | PiglinRenderer(ML.PIGLIN, ML.PIGLIN_BABY, ML.PIGLIN_ARMOR, ML.PIGLIN_BABY_ARMOR) | 2 |
| 103 | `piglin_brute` | PiglinRenderer(ML.PIGLIN_BRUTE, ML.PIGLIN_BRUTE, ML.PIGLIN_BRUTE_ARMOR, ML.PIGLIN_BRUTE_ARMOR) | 2 |
| 104 | `pillager` | PillagerRenderer | 3 |
| 105 | `polar_bear` | PolarBearRenderer | 5 |
| 106 | `poplar_boat` | BoatRenderer(ML.POPLAR_BOAT) | 8 |
| 107 | `poplar_chest_boat` | BoatRenderer(ML.POPLAR_CHEST_BOAT) | 8 |
| 108 | `splash_potion` | ThrownItemRenderer(1.0, false) | 9 |
| 109 | `lingering_potion` | ThrownItemRenderer(1.0, false) | 9 |
| 110 | `pufferfish` | PufferfishRenderer | 8 |
| 111 | `rabbit` | RabbitRenderer | 4 |
| 112 | `ravager` | RavagerRenderer | 3 |
| 113 | `salmon` | SalmonRenderer | 8 |
| 114 | `sheep` | SheepRenderer | 4 |
| 115 | `shulker` | ShulkerRenderer | 6 |
| 116 | `shulker_bullet` | ShulkerBulletRenderer | 6 |
| 117 | `silverfish` | SilverfishRenderer | 6 |
| 118 | `skeleton` | SkeletonRenderer | 2 |
| 119 | `skeleton_horse` | UndeadHorseRenderer(LT.SKELETON_HORSE_SADDLE, ML.SKELETON_HORSE_SADDLE, UndeadHorseRenderer.Type.SKELETON, UndeadHorseRenderer.Type.SKELETON_BABY) | 4 |
| 120 | `slime` | SlimeRenderer | 6 |
| 121 | `small_fireball` | ThrownItemRenderer(0.75, true) | 9 |
| 122 | `sniffer` | SnifferRenderer | 5 |
| 123 | `snowball` | ThrownItemRenderer(1.0, false) | 9 |
| 124 | `snow_golem` | SnowGolemRenderer | 3 |
| 125 | `spawner_minecart` | MinecartRenderer(ML.SPAWNER_MINECART) | 9 |
| 126 | `spectral_arrow` | SpectralArrowRenderer | 9 |
| 127 | `spider` | SpiderRenderer | 6 |
| 128 | `spruce_boat` | BoatRenderer(ML.SPRUCE_BOAT) | 8 |
| 129 | `spruce_chest_boat` | BoatRenderer(ML.SPRUCE_CHEST_BOAT) | 8 |
| 130 | `squid` | SquidRenderer(ML.SQUID, ML.SQUID_BABY) | 8 |
| 131 | `stray` | StrayRenderer | 2 |
| 132 | `strider` | StriderRenderer | 7 |
| 133 | `sulfur_cube` | SulfurCubeRenderer | 6 |
| 134 | `tadpole` | TadpoleRenderer | 5 |
| 135 | `text_display` | DisplayRenderer.TextDisplayRenderer | 9 |
| 136 | `tnt` | TntRenderer | 9 |
| 137 | `tnt_minecart` | TntMinecartRenderer | 9 |
| 138 | `trader_llama` | LlamaRenderer(ML.TRADER_LLAMA, ML.TRADER_LLAMA_BABY) | 4 |
| 139 | `trident` | ThrownTridentRenderer | 9 |
| 140 | `tropical_fish` | TropicalFishRenderer | 8 |
| 141 | `turtle` | TurtleRenderer | 5 |
| 142 | `vex` | VexRenderer | 3 |
| 143 | `villager` | VillagerRenderer | 3 |
| 144 | `vindicator` | VindicatorRenderer | 3 |
| 145 | `wandering_trader` | WanderingTraderRenderer | 3 |
| 146 | `warden` | WardenRenderer | 6 |
| 147 | `wind_charge` | WindChargeRenderer | 9 |
| 148 | `witch` | WitchRenderer | 3 |
| 149 | `wither` | WitherBossRenderer | 7 |
| 150 | `wither_skeleton` | WitherSkeletonRenderer | 2 |
| 151 | `wither_skull` | WitherSkullRenderer | 7 |
| 152 | `wolf` | WolfRenderer | 5 |
| 153 | `zoglin` | ZoglinRenderer | 7 |
| 154 | `zombie` | ZombieRenderer | 2 |
| 155 | `zombie_horse` | UndeadHorseRenderer(LT.ZOMBIE_HORSE_SADDLE, ML.ZOMBIE_HORSE_SADDLE, UndeadHorseRenderer.Type.ZOMBIE, UndeadHorseRenderer.Type.ZOMBIE_BABY) | 4 |
| 156 | `zombie_nautilus` | ZombieNautilusRenderer | 8 |
| 157 | `zombie_villager` | ZombieVillagerRenderer | 3 |
| 158 | `zombified_piglin` | ZombifiedPiglinRenderer(ML.ZOMBIFIED_PIGLIN, ML.ZOMBIFIED_PIGLIN_BABY, ML.ZOMBIFIED_PIGLIN_ARMOR, ML.ZOMBIFIED_PIGLIN_BABY_ARMOR) | 2 |
| 159 | `player` | AvatarRenderer (WIDE / SLIM; 12 §7) | 9 |
| 160 | `fishing_bobber` | FishingHookRenderer | 9 |

---

## 11. Validation: worked examples and checks

Each item can be checked by a test that needs no jar.

**V1 Cuboid unwrap (1.3).** Humanoid head: texture 64 x 64, offset (0, 0), origin (−4, −8, −4), size 8 x 8 x 8, no deformation, no mirror. U0..U5 = 0, 8, 16, 24, 24, 32; V0..V2 = 0, 8, 16. Face rectangles in pixels (minU, minV)-(maxU, maxV): `DOWN` (8, 0)-(16, 8); `UP` (16, 8)-(24, 0) read from V1 up to V0; `WEST` (0, 8)-(8, 16); `NORTH` (8, 8)-(16, 16); `EAST` (16, 8)-(24, 16); `SOUTH` (24, 8)-(32, 16). The `NORTH` face has vertices B = (4, −8, −4) with (16/64, 8/64) = (0.25, 0.125); A = (−4, −8, −4) with (0.125, 0.125); D = (−4, 0, −4) with (0.125, 0.25); C = (4, 0, −4) with (0.25, 0.25). Faces drawn: 6; polygon creation order `DOWN, UP, WEST, NORTH, EAST, SOUTH`.

**V2 Mirror and strip arithmetic.** Cuboid with offset (32, 48), origin (−1, −2, −2), size 4 x 12 x 4 (a humanoid left arm region), mirror = true: x0 = 3, x1 = −1 (swapped). Strip: U0..U5 = 32, 36, 40, 44, 44, 48; V0..V2 = 48, 52, 64. `NORTH` rectangle (36, 52)-(40, 64); `EAST` (40, 52)-(44, 64); `SOUTH` (44, 52)-(48, 64); `WEST` (32, 52)-(36, 64); `DOWN` (36, 48)-(40, 52); `UP` (40, 52)-(44, 48). Each face's vertex order is reversed relative to V1 and the `WEST` and `EAST` normals are exchanged.

**V3 Deformation.** Head with deformation 0.5: x0 = −4.5, x1 = 4.5, y0 = −8.5, y1 = 0.5, z0 = −4.5, z1 = 4.5; the texture rectangles are those of V1 (unchanged); the strip uses the **undeformed** w, h, d.

**V4 Baby transform on the humanoid mesh (2.3).** (scaleHead true, yHead 16, zHead 0, headScale 2, bodyScale 2, bodyYOffset 24, heads {`head`}); head factor 0.75, body factor 0.5. Head pivot (0, 0, 0) becomes (0, 12, 0), scale 0.75. Body (0, 0, 0) becomes (0, 12, 0), scale 0.5. Right arm (−5, 2, 0) becomes (−2.5, 13, 0), scale 0.5. Right leg (−1.9, 12, 0) becomes (−0.95, 18, 0), scale 0.5: the leg (12 tall, drawn 6 tall) still ends at y = 18 + 6 = 24, the ground. Children (the hat) are unchanged and ride on the matrix chain.

**V5 Mesh scaling (2.2).** `scaling(0.9375)`: k = 24.016 x 0.0625 = 1.5010; root pose becomes position (0, 1.5010, 0), scale (0.9375, 0.9375, 0.9375).

**V6 Quadruped walk (3.4).** With walk position p = 0 and speed s = 1: right hind leg xRot = 1.4, left hind = cos(π) x 1.4 = −1.4, right front = −1.4, left front = 1.4. With s = 0 all four are 0. With p = π / 0.6662 (about 4.716) and s = 0.5: right hind = cos(π) x 1.4 x 0.5 = −0.7.

**V7 Quadruped mesh (3.4).** `createBodyMesh(12, false, false, none)`: head pivot (0, 6, −6); body pivot (0, 5, 2), xRot 1.5707964; right hind leg pivot (−3, 12, 7), box (−2, 0, −2) of 4 x 12 x 4; front legs z = −5. `createBodyMesh(6, ...)`: head y = 12, body y = 11, legs y = 18 (the legs end at 18 + 6 = 24).

**V8 Death rotation (6.5).** deathTime (state) 1: f = 0, rotation 0. deathTime 11: f = (10 / 20) x 1.6 = 0.8, sqrt = 0.8944, Z rotation 80.50° (with the default flip of 90°). deathTime 21.5: f = (20.5 / 20) x 1.6 = 1.64, sqrt = 1.2806, clamped to 1: 90°. Shaking, ageInTicks = 10.7: floor = 10, bodyRot += cos(32.5) x π x 0.4 = +0.5878°.

**V9 Animation interpolation (5.4).** Linear: k0 (t 0, 0), k1 (t 1, 1.5707964): t = 0.25 gives 0.3926991; t = 1.5 (past the end) gives 1.5707964 (alpha 0); t = −1 gives 0. Catmull-Rom with post values (0, 0, 1, 1) at keyframes 0..3 evaluated on the segment k1 to k2 (i = 1, j = 2, neighbours k0 and k3): alpha 0.5 gives 0.5 and alpha 0.25 gives 0.203125. t equal to the last timestamp of a linear channel with k0 (t 0, 0) and k1 (t 1, 1.5707964) gives alpha 1 and `pre` of k1. A looping animation of length 2 s at 5500 ms evaluates at 1.5 s. `applyWalk(10, 0.5, 1, 1)`: time 500 ms, scale 0.5.

**V10 Shadow (7.1).** Entity at (10.5, 65.0, 10.5) standing on a full block whose top is y = 65, R = 0.5, camera distance 8 blocks (d² = 64), strength 1: s = 1 − 64/256 = 0.75; m = min(0.75/0.5 − 1, 0.5) = 0.5; y range floor(64.5) = 64 to 65; columns x = 10 and 11 (floor(10.0) to floor(11.0)) and z = 10 and 11, so 4 columns. In the column (10, 10): cell y = 65: f = 0.75 − (65.0 − 65) x 0.5 = 0.75, alpha = 0.75 x 0.5 x brightness = 0.375 x brightness; cell y = 64: below = block y = 63; f = 0.75 − 0.5 = 0.25, alpha = 0.125 x brightness (drawn only when the block at y = 63 is a full block and the cell at y = 64 has brightness above 3). Quad of the first piece: relX = 10 − 10.5 = −0.5, bounds 0..1: x0 = −0.5, x1 = 0.5; u(x0) = 0.5 / 2 / 0.5 + 0.5 = 1.0, u(x1) = 0.0; alpha byte floor(0.375 x 255) = 95 for brightness 1.

**V11 Light packing (6.9).** pack(15, 15) = (15 << 4) | (15 << 20) = 15728880 = 0xF000F0; pack(7, 3) = 112 | 3145728 = 3145840; `withBlock(pack(0, 15), 15)` = 0x00F00000 | 0xF0 = 15728880.

**V12 Overlay (6.9).** Hurt, white progress 0: u = 0, v = 3: coords = 3 x 65536 = 196608. Creeper-style flash with white progress 0.5 and no hurt: u = trunc(7.5) = 7, v = 10: coords = 7 | (10 << 16) = 655367; texture alpha at column 7 = floor((1 − 7/15 x 0.75) x 255) = 165, so the colour keeps 165/255 = 65% and gains 35% white. `NO_OVERLAY` = 0 | (10 << 16) = 655360.

**V13 Fire (7.4).** Width 0.6, height 1.8: s = 0.84, h = 2.1429, initial z translate 0.3 − 2 x 0.02 = 0.26. Quads: five. i = 0: w 0.5, rise 0, zs 0; i = 1: w 0.45, rise 0.45, zs −0.03; i = 2: w 0.405, rise 0.9, zs −0.06; i = 3: w 0.3645, rise 1.35, zs −0.09; i = 4: w 0.3281, rise 1.8, zs −0.12 (h after each: 1.6929, 1.2429, 0.7929, 0.3429, −0.1071 stops). Mirror (swap u) for i = 0, 1 and not for i = 2, 3, and again for i = 4.

**V14 Cube-mob scale (6.6).** size 2, squish 0.5: q = 0.5 / (2 x 0.5 + 1) = 0.25, r = 1 / 1.25 = 0.8, scale (1.6, 2.5, 1.6); shadow radius = 2 x 0.25 = 0.5 and that is final (no `scale` or `ageScale` factor, 7.1).

**V15 Name tag gate (7.2).** Zombie at distance 70: d² = 4900 > 64² = 4096: no name. At distance 30 with a custom name and under the crosshair: shown. At distance 30, sneaking: d² = 900 < 1024 so the sneaking cutoff does not apply; at distance 33 (d² = 1089) sneaking: hidden. Text alpha with default background opacity 0.25: a = max((0.25 + 0.75) x 0.5, 0.5) = 0.5, background alpha byte floor(0.25 x 255) = 63.

**V16 Registration counts (6.2, 10).** 159 registered providers plus `player` and `mannequin` = 161 = the entity type count in 21 §2; part counts 13, 16, 18, 14, 16, 10, 32, 42 sum to 161 (2: 13, 3: 16, 4: 18, 5: 14, 6: 16, 7: 10, 8: 32, 9: 42). 361 model layers = 269 + 23 x 4.

---

## 12. Open questions

1. **Per-entity geometry, textures and layer lists** are in parts 2 to 9; this document gives only the engines and the registration table. Texture paths (DATA, 759 files under `textures/entity`) are not tabulated here by design.
2. **Allocation of the 161 types to parts 2 to 9** (section 10) was regenerated from the Covers sections of the sibling documents; the placement of `breeze_wind_charge` (part 9) and of `player` and `mannequin` (part 9, cross-reference only) rests on part 9's text, and the final allocation is whatever the sibling documents' contents say.
3. **Rotation order of `Quaternionf.rotationZYX`** was not read (the joml library is not in the artifact); the document no longer states an order. Recollection of the library is contradictory between readers (Z first versus X first, both recalled, not verified). Only read: `ModelPart.rotateBy` pairs `rotationZYX` with `getEulerAnglesZYX`. A reference render of a part with two non-zero rotations decides.
4. **Sibling draw order** of parts inside a model is the iteration order of a hash map; it does not matter for opaque cutout geometry but could matter for translucent overlays.
5. **When `setupAnim` runs**: `LivingEntityRenderer.submit` calls it before the layers, and the collector is given the model and the state; the doc infers that the collector also calls it when it draws. Not traced in `ModelFeatureRenderer`.
6. **`Entity.getLightProbePosition(partial)`** is read: the base implementation returns `getEyePosition(partial)`; `EntityRenderer` takes `BlockPos.containing` of it (floor per axis) for both light lookups. Subclass overrides were not enumerated (searched: only `Entity` and `EntityRenderer`). Pack is (block << 4) | (sky << 20), `withBlock` masks 0x00FF0000, block light is forced to 15 when on fire (`ThrownItemRenderer` with `fullBright` forces 15 always), full bright is 15728880.
7. **Per-renderer overrides** of `getFlipDegrees`, `getWhiteOverlayProgress`, `isShaking`, `getModelTint` and `scale` were not enumerated here; each sibling part lists those of its renderers, and a completeness cross-check against the final siblings is outstanding. The `getAgeScale` overrides are resolved (6.3: turtle, dolphin, camel, goat, happy ghast, armadillo).
8. **`AnimationState`** is resolved (5.5). Nothing outstanding.
9. **Render pipelines** still unread: `entitySolid`, `entity_solid_offset_forward`, `entity_solid_glint`, `armorTrim`, `trimmedArmorGlint`, `outline_cull` / `outline_no_cull`; the exact snippet contents (`ENTITY_SNIPPET`, `EYES_SNIPPET`, `ENTITY_SHADOW_SNIPPET`, `ENERGY_SWIRL_SNIPPET`, `OIT_ENTITY_SNIPPET`, depth-write flags of the cutout family) and `oit.glsl` were not read. The pipelines listed in 6.7 were read in this round.
10. **`Lightmap.getBrightness`** is resolved (7.1). `LightCoordsUtil.lightCoordsWithEmission(light, 2)` (used by the see-through name tag), `Mth.floor` rounding of negative values and `ARGB.white(float)` clamping are not specified here beyond what 12 §2 gives for light.
11. **`Mth.rotationAroundAxis(Y_AXIS, cameraOrientation)`** (the fire billboard rotation): meaning inferred as "the camera's rotation about the Y axis".
12. **Collector ordering**: how `SubmitNodeCollector.order(n)` sorts submissions (ties, translucent phase) was not read. Searched again in this round: not read.
13. **Hitbox display**: the view-direction line, the dragon sub-box style and everything after the eye-height box of `EntityHitboxDebugRenderer.showHitboxes` were not read. Searched again in this round: not read.
14. **`RandomSource.createThreadLocalInstance(seed)`**: the generator algorithm (needed to place stuck arrows identically) and `PlayerModel.getRandomBodyPart` were not read (player layers, 12 §7).
15. **`animateZombieArms` flag**: resolved (3.5, 6.3): `ZombieRenderState.isAggressive`. Where `isAggressive` is set on extraction was not read (part 2).
16. **Equipment asset schema** (`EquipmentClientInfo`: layers per `LayerType`, `dyeable`, `usePlayerTexture`) is DATA read by `EquipmentLayerRenderer`; its JSON schema is for the extraction document (22).
17. **`createRoots` shapes**: the 361 layer definitions are referenced by name only; each sibling part documents its own, and a completeness check (every row of Appendix A has a documented mesh) is for the reviewer.
18. **`SpearAnimations`** is documented in 3.8 (all six public functions read); the remaining gap is Open question 25.
19. **Catmull-Rom**: resolved (5.2); `Mth.catmullrom` and the point selection in `AnimationChannel$Interpolations` were fully read. Nothing outstanding.
20. **Entity numeric ids**: the order is read (the `EntityTypes` initializer, 161 fields); the equality of the id with that order is the registry's rule and the Add Entity id was not read from the client.
21. **`EntityRenderState.passengerOffset`** is described only for the minecart rule; other riding offsets (boats, horses) are applied by the vehicle and passenger attachment code (18 framework).
22. **Font rendering** of name tags (`Font.width`, `prepareText`, `SEE_THROUGH` and `POLYGON_OFFSET` display modes) is outside this document; the gap list of the design README covers the font engine.
23. **`HumanoidModel` duck-walk and shield constants** (3.7): where `DUCK_WALK_ROTATION` and the three shield angles are applied was not read here (12 §7.5 covers the arm poses).
24. **`Ease.inOutBack` and `Ease.inOutElastic`**: resolved (3.8), both halves read. Nothing outstanding.
25. **`UseParams` condition mapping** (3.8): the structure (E, knock and dmg as delay plus condition value; the sway, lower and raiseBack windows; the intensity and scale formulas) was read; only the `Optional.map` lambdas (invokedynamic, not disassembled) that map each condition record to a value remain inferred as `maxDurationTicks`. Searched again in this round: the lambda bodies were not disassembled.
26. **Verification coverage**: a review of 2.2 found the transformer table incomplete; it was re-read in this round (illager 0.9375 is also applied to villager, villager no-hat and witch layers; cave spider 0.7 only to `CAVE_SPIDER`). The `CustomHeadLayer` constants (`ITEM_SCALE` 0.625, `SKULL_SCALE` 1.1875, translate −0.25, rotate 180 about Y, scale (0.625, −0.625, −0.625)) were spot-checked and match 6.x. Sections 6.7, 7.1 to 7.5, 8.2 to 8.5, 8.7, 3.8 and Appendix A (shadow alpha and vertex order, leash vertex pairs and 0.7 shade, fire quad geometry, `ItemInHandLayer` offsets) were not re-verified in this round.

---

## Appendix A. `ModelLayers` fields (292 fields, 361 layers)

Model id is `minecraft:<name>`; the layer id is `<model id>#<layer>` (4.1). Rows with an armor set register four layers.

| Field | Model name | Layer |
|---|---|---|
| `ACACIA_BOAT` | `boat/acacia` | main |
| `ACACIA_CHEST_BOAT` | `chest_boat/acacia` | main |
| `ALLAY` | `allay` | main |
| `ARMADILLO` | `armadillo` | main |
| `ARMADILLO_BABY` | `armadillo_baby` | main |
| `ARMOR_STAND` | `armor_stand` | main |
| `ARMOR_STAND_ARMOR` | `armor_stand` | helmet, chestplate, leggings, boots (4 layers) |
| `ARMOR_STAND_SMALL` | `armor_stand_small` | main |
| `ARMOR_STAND_SMALL_ARMOR` | `armor_stand_small` | helmet, chestplate, leggings, boots (4 layers) |
| `ARROW` | `arrow` | main |
| `AXOLOTL` | `axolotl` | main |
| `AXOLOTL_BABY` | `axolotl_baby` | main |
| `BAMBOO_CHEST_RAFT` | `chest_boat/bamboo` | main |
| `BAMBOO_RAFT` | `boat/bamboo` | main |
| `STANDING_BANNER` | `standing_banner` | main |
| `STANDING_BANNER_FLAG` | `standing_banner` | flag |
| `WALL_BANNER` | `wall_banner` | main |
| `WALL_BANNER_FLAG` | `wall_banner` | flag |
| `BAT` | `bat` | main |
| `BEE` | `bee` | main |
| `BEE_BABY` | `bee_baby` | main |
| `BEE_STINGER` | `bee_stinger` | main |
| `BELL` | `bell` | main |
| `BIRCH_BOAT` | `boat/birch` | main |
| `BIRCH_CHEST_BOAT` | `chest_boat/birch` | main |
| `BLAZE` | `blaze` | main |
| `BOAT_WATER_PATCH` | `boat` | water_patch |
| `BOGGED` | `bogged` | main |
| `BOGGED_ARMOR` | `bogged` | helmet, chestplate, leggings, boots (4 layers) |
| `BOGGED_OUTER_LAYER` | `bogged` | outer |
| `BOOK` | `book` | main |
| `BREEZE` | `breeze` | main |
| `BREEZE_WIND` | `breeze` | wind |
| `BREEZE_EYES` | `breeze` | eyes |
| `CAMEL` | `camel` | main |
| `CAMEL_BABY` | `camel_baby` | main |
| `CAMEL_SADDLE` | `camel` | saddle |
| `CAMEL_HUSK_SADDLE` | `camel_husk` | saddle |
| `CAT` | `cat` | main |
| `CAT_BABY` | `cat_baby` | main |
| `CAT_BABY_COLLAR` | `cat_baby` | collar |
| `CAT_COLLAR` | `cat` | collar |
| `CAVE_SPIDER` | `cave_spider` | main |
| `CHERRY_BOAT` | `boat/cherry` | main |
| `CHERRY_CHEST_BOAT` | `chest_boat/cherry` | main |
| `CHEST` | `chest` | main |
| `CHEST_MINECART` | `chest_minecart` | main |
| `CHICKEN` | `chicken` | main |
| `CHICKEN_BABY` | `chicken_baby` | main |
| `COD` | `cod` | main |
| `COLD_CHICKEN` | `cold_chicken` | main |
| `COLD_COW` | `cold_cow` | main |
| `COLD_COW_BABY` | `cold_cow_baby` | main |
| `COLD_PIG` | `cold_pig` | main |
| `COMMAND_BLOCK_MINECART` | `command_block_minecart` | main |
| `CONDUIT_CAGE` | `conduit` | cage |
| `CONDUIT_EYE` | `conduit` | eye |
| `CONDUIT_SHELL` | `conduit` | shell |
| `CONDUIT_WIND` | `conduit` | wind |
| `COPPER_GOLEM` | `copper_golem` | main |
| `COPPER_GOLEM_EYES` | `copper_golem` | eyes |
| `COPPER_GOLEM_RUNNING` | `copper_golem_running` | main |
| `COPPER_GOLEM_SITTING` | `copper_golem_sitting` | main |
| `COPPER_GOLEM_STAR` | `copper_golem_star` | main |
| `ZOMBIE_NAUTILUS_CORAL` | `zombie_nautilus_coral` | main |
| `COW` | `cow` | main |
| `COW_BABY` | `cow_baby` | main |
| `CREAKING` | `creaking` | main |
| `CREAKING_EYES` | `creaking` | eyes |
| `CREEPER` | `creeper` | main |
| `CREEPER_ARMOR` | `creeper` | armor |
| `CREEPER_HEAD` | `creeper_head` | main |
| `CUSHION` | `cushion` | main |
| `DARK_OAK_BOAT` | `boat/dark_oak` | main |
| `DARK_OAK_CHEST_BOAT` | `chest_boat/dark_oak` | main |
| `DECORATED_POT_BASE` | `decorated_pot_base` | main |
| `DECORATED_POT_SIDES` | `decorated_pot_sides` | main |
| `DOLPHIN` | `dolphin` | main |
| `DOLPHIN_BABY` | `dolphin_baby` | main |
| `DONKEY` | `donkey` | main |
| `DONKEY_BABY` | `donkey_baby` | main |
| `DONKEY_SADDLE` | `donkey` | saddle |
| `DOUBLE_CHEST_LEFT` | `double_chest_left` | main |
| `DOUBLE_CHEST_RIGHT` | `double_chest_right` | main |
| `DRAGON_SKULL` | `dragon_skull` | main |
| `DROWNED` | `drowned` | main |
| `DROWNED_BABY` | `drowned_baby` | main |
| `DROWNED_BABY_ARMOR` | `drowned_baby` | helmet, chestplate, leggings, boots (4 layers) |
| `DROWNED_BABY_OUTER_LAYER` | `drowned_baby` | outer |
| `DROWNED_ARMOR` | `drowned` | helmet, chestplate, leggings, boots (4 layers) |
| `DROWNED_OUTER_LAYER` | `drowned` | outer |
| `ELDER_GUARDIAN` | `elder_guardian` | main |
| `ELYTRA` | `elytra` | main |
| `ELYTRA_BABY` | `elytra_baby` | main |
| `ENDERMAN` | `enderman` | main |
| `ENDERMITE` | `endermite` | main |
| `ENDER_DRAGON` | `ender_dragon` | main |
| `END_CRYSTAL` | `end_crystal` | main |
| `EVOKER` | `evoker` | main |
| `EVOKER_FANGS` | `evoker_fangs` | main |
| `FOX` | `fox` | main |
| `FOX_BABY` | `fox_baby` | main |
| `FROG` | `frog` | main |
| `FURNACE_MINECART` | `furnace_minecart` | main |
| `GHAST` | `ghast` | main |
| `GIANT` | `giant` | main |
| `GIANT_ARMOR` | `giant` | helmet, chestplate, leggings, boots (4 layers) |
| `GLOW_SQUID` | `glow_squid` | main |
| `GLOW_SQUID_BABY` | `glow_squid_baby` | main |
| `GOAT` | `goat` | main |
| `GOAT_BABY` | `goat_baby` | main |
| `GUARDIAN` | `guardian` | main |
| `HAPPY_GHAST` | `happy_ghast` | main |
| `HAPPY_GHAST_BABY` | `happy_ghast_baby` | main |
| `HAPPY_GHAST_HARNESS` | `happy_ghast_harness` | main |
| `HAPPY_GHAST_BABY_HARNESS` | `happy_ghast_baby_harness` | main |
| `HAPPY_GHAST_ROPES` | `happy_ghast_ropes` | main |
| `HAPPY_GHAST_BABY_ROPES` | `happy_ghast_baby_ropes` | main |
| `HOGLIN` | `hoglin` | main |
| `HOGLIN_BABY` | `hoglin_baby` | main |
| `HOPPER_MINECART` | `hopper_minecart` | main |
| `HORSE` | `horse` | main |
| `HORSE_ARMOR` | `horse_armor` | main |
| `HORSE_SADDLE` | `horse` | saddle |
| `HORSE_BABY` | `horse_baby` | main |
| `HUSK` | `husk` | main |
| `HUSK_BABY` | `husk_baby` | main |
| `HUSK_BABY_ARMOR` | `husk_baby` | helmet, chestplate, leggings, boots (4 layers) |
| `HUSK_ARMOR` | `husk` | helmet, chestplate, leggings, boots (4 layers) |
| `ILLUSIONER` | `illusioner` | main |
| `IRON_GOLEM` | `iron_golem` | main |
| `JUNGLE_BOAT` | `boat/jungle` | main |
| `JUNGLE_CHEST_BOAT` | `chest_boat/jungle` | main |
| `LEASH_KNOT` | `leash_knot` | main |
| `LLAMA` | `llama` | main |
| `LLAMA_BABY` | `llama_baby` | main |
| `LLAMA_BABY_DECOR` | `llama_baby` | decor |
| `LLAMA_DECOR` | `llama` | decor |
| `LLAMA_SPIT` | `llama_spit` | main |
| `MAGMA_CUBE` | `magma_cube` | main |
| `MANGROVE_BOAT` | `boat/mangrove` | main |
| `MANGROVE_CHEST_BOAT` | `chest_boat/mangrove` | main |
| `MINECART` | `minecart` | main |
| `MOOSHROOM` | `mooshroom` | main |
| `MOOSHROOM_BABY` | `mooshroom_baby` | main |
| `MULE` | `mule` | main |
| `MULE_BABY` | `mule_baby` | main |
| `MULE_SADDLE` | `mule` | saddle |
| `NAUTILUS` | `nautilus` | main |
| `NAUTILUS_BABY` | `nautilus_baby` | main |
| `NAUTILUS_SADDLE` | `nautilus` | saddle |
| `NAUTILUS_ARMOR` | `nautilus_armor` | main |
| `OAK_BOAT` | `boat/oak` | main |
| `OAK_CHEST_BOAT` | `chest_boat/oak` | main |
| `OCELOT` | `ocelot` | main |
| `OCELOT_BABY` | `ocelot_baby` | main |
| `PALE_OAK_BOAT` | `boat/pale_oak` | main |
| `PALE_OAK_CHEST_BOAT` | `chest_boat/pale_oak` | main |
| `PANDA` | `panda` | main |
| `PANDA_BABY` | `panda_baby` | main |
| `PARCHED` | `parched` | main |
| `PARCHED_ARMOR` | `parched` | helmet, chestplate, leggings, boots (4 layers) |
| `PARCHED_OUTER_LAYER` | `parched` | outer |
| `PARROT` | `parrot` | main |
| `PHANTOM` | `phantom` | main |
| `PIG` | `pig` | main |
| `PIGLIN` | `piglin` | main |
| `PIGLIN_BABY` | `piglin_baby` | main |
| `PIGLIN_BABY_ARMOR` | `piglin_baby` | helmet, chestplate, leggings, boots (4 layers) |
| `PIGLIN_BRUTE` | `piglin_brute` | main |
| `PIGLIN_BRUTE_ARMOR` | `piglin_brute` | helmet, chestplate, leggings, boots (4 layers) |
| `PIGLIN_HEAD` | `piglin_head` | main |
| `PIGLIN_ARMOR` | `piglin` | helmet, chestplate, leggings, boots (4 layers) |
| `PIG_BABY` | `pig_baby` | main |
| `PIG_SADDLE` | `pig` | saddle |
| `PILLAGER` | `pillager` | main |
| `PLAYER` | `player` | main |
| `PLAYER_CAPE` | `player` | cape |
| `PLAYER_EARS` | `player` | ears |
| `PLAYER_HEAD` | `player_head` | main |
| `PLAYER_ARMOR` | `player` | helmet, chestplate, leggings, boots (4 layers) |
| `PLAYER_SLIM` | `player_slim` | main |
| `PLAYER_SLIM_ARMOR` | `player_slim` | helmet, chestplate, leggings, boots (4 layers) |
| `PLAYER_SPIN_ATTACK` | `spin_attack` | main |
| `POLAR_BEAR` | `polar_bear` | main |
| `POLAR_BEAR_BABY` | `polar_bear_baby` | main |
| `POPLAR_BOAT` | `boat/poplar` | main |
| `POPLAR_CHEST_BOAT` | `chest_boat/poplar` | main |
| `PUFFERFISH_BIG` | `pufferfish_big` | main |
| `PUFFERFISH_MEDIUM` | `pufferfish_medium` | main |
| `PUFFERFISH_SMALL` | `pufferfish_small` | main |
| `RABBIT` | `rabbit` | main |
| `RABBIT_BABY` | `rabbit_baby` | main |
| `RAVAGER` | `ravager` | main |
| `SALMON` | `salmon` | main |
| `SALMON_LARGE` | `salmon_large` | main |
| `SALMON_SMALL` | `salmon_small` | main |
| `SHEEP` | `sheep` | main |
| `SHEEP_BABY` | `sheep_baby` | main |
| `SHEEP_BABY_WOOL` | `sheep_baby` | wool |
| `SHEEP_WOOL` | `sheep` | wool |
| `SHEEP_WOOL_UNDERCOAT` | `sheep` | wool_undercoat |
| `SHIELD` | `shield` | main |
| `SHULKER` | `shulker` | main |
| `SHULKER_BOX` | `shulker_box` | main |
| `SHULKER_BULLET` | `shulker_bullet` | main |
| `SILVERFISH` | `silverfish` | main |
| `SKELETON` | `skeleton` | main |
| `SKELETON_HORSE` | `skeleton_horse` | main |
| `SKELETON_HORSE_BABY` | `skeleton_horse_baby` | main |
| `SKELETON_HORSE_SADDLE` | `skeleton_horse` | saddle |
| `SKELETON_ARMOR` | `skeleton` | helmet, chestplate, leggings, boots (4 layers) |
| `SKELETON_SKULL` | `skeleton_skull` | main |
| `SLIME` | `slime` | main |
| `SLIME_OUTER` | `slime` | outer |
| `SNIFFER` | `sniffer` | main |
| `SNIFFER_BABY` | `sniffer_baby` | main |
| `SNOW_GOLEM` | `snow_golem` | main |
| `SPAWNER_MINECART` | `spawner_minecart` | main |
| `SPIDER` | `spider` | main |
| `SPRUCE_BOAT` | `boat/spruce` | main |
| `SPRUCE_CHEST_BOAT` | `chest_boat/spruce` | main |
| `SQUID` | `squid` | main |
| `SQUID_BABY` | `squid_baby` | main |
| `STRAY` | `stray` | main |
| `STRAY_ARMOR` | `stray` | helmet, chestplate, leggings, boots (4 layers) |
| `STRAY_OUTER_LAYER` | `stray` | outer |
| `STRIDER` | `strider` | main |
| `STRIDER_SADDLE` | `strider` | saddle |
| `STRIDER_BABY` | `strider_baby` | main |
| `SULFUR_CUBE` | `sulfur_cube` | main |
| `SULFUR_CUBE_INNER` | `sulfur_cube` | inner |
| `SULFUR_CUBE_SMALL` | `sulfur_cube_small` | main |
| `SULFUR_CUBE_SMALL_INNER` | `sulfur_cube_small` | inner |
| `TADPOLE` | `tadpole` | main |
| `TNT_MINECART` | `tnt_minecart` | main |
| `TRADER_LLAMA` | `trader_llama` | main |
| `TRADER_LLAMA_BABY` | `trader_llama_baby` | main |
| `TRIDENT` | `trident` | main |
| `TROPICAL_FISH_LARGE` | `tropical_fish_large` | main |
| `TROPICAL_FISH_LARGE_PATTERN` | `tropical_fish_large` | pattern |
| `TROPICAL_FISH_SMALL` | `tropical_fish_small` | main |
| `TROPICAL_FISH_SMALL_PATTERN` | `tropical_fish_small` | pattern |
| `TURTLE` | `turtle` | main |
| `TURTLE_BABY` | `turtle_baby` | main |
| `UNDEAD_HORSE_ARMOR` | `undead_horse_armor` | main |
| `VEX` | `vex` | main |
| `VILLAGER` | `villager` | main |
| `VILLAGER_NO_HAT` | `villager_no_hat` | main |
| `VILLAGER_BABY` | `villager_baby` | main |
| `VILLAGER_BABY_NO_HAT` | `villager_baby_no_hat` | main |
| `VINDICATOR` | `vindicator` | main |
| `WANDERING_TRADER` | `wandering_trader` | main |
| `WARDEN` | `warden` | main |
| `WARDEN_BIOLUMINESCENT` | `warden` | bioluminescent |
| `WARDEN_PULSATING_SPOTS` | `warden` | pulsating_spots |
| `WARDEN_TENDRILS` | `warden` | tendrils |
| `WARDEN_HEART` | `warden` | heart |
| `WARM_COW` | `warm_cow` | main |
| `WARM_COW_BABY` | `warm_cow_baby` | main |
| `WIND_CHARGE` | `wind_charge` | main |
| `WITCH` | `witch` | main |
| `WITHER` | `wither` | main |
| `WITHER_ARMOR` | `wither` | armor |
| `WITHER_SKELETON` | `wither_skeleton` | main |
| `WITHER_SKELETON_ARMOR` | `wither_skeleton` | helmet, chestplate, leggings, boots (4 layers) |
| `WITHER_SKELETON_SKULL` | `wither_skeleton_skull` | main |
| `WITHER_SKULL` | `wither_skull` | main |
| `WOLF` | `wolf` | main |
| `WOLF_ARMOR` | `wolf_armor` | main |
| `WOLF_BABY` | `wolf_baby` | main |
| `ZOGLIN` | `zoglin` | main |
| `ZOGLIN_BABY` | `zoglin_baby` | main |
| `ZOMBIE` | `zombie` | main |
| `ZOMBIE_BABY` | `zombie_baby` | main |
| `ZOMBIE_BABY_ARMOR` | `zombie_baby` | helmet, chestplate, leggings, boots (4 layers) |
| `ZOMBIE_HEAD` | `zombie_head` | main |
| `ZOMBIE_HORSE` | `zombie_horse` | main |
| `ZOMBIE_HORSE_BABY` | `zombie_horse_baby` | main |
| `ZOMBIE_HORSE_SADDLE` | `zombie_horse` | saddle |
| `ZOMBIE_ARMOR` | `zombie` | helmet, chestplate, leggings, boots (4 layers) |
| `ZOMBIE_VILLAGER` | `zombie_villager` | main |
| `ZOMBIE_VILLAGER_NO_HAT` | `zombie_villager_no_hat` | main |
| `ZOMBIE_VILLAGER_BABY` | `zombie_villager_baby` | main |
| `ZOMBIE_VILLAGER_BABY_NO_HAT` | `zombie_villager_baby_no_hat` | main |
| `ZOMBIE_VILLAGER_BABY_ARMOR` | `zombie_villager_baby` | helmet, chestplate, leggings, boots (4 layers) |
| `ZOMBIE_VILLAGER_ARMOR` | `zombie_villager` | helmet, chestplate, leggings, boots (4 layers) |
| `ZOMBIFIED_PIGLIN` | `zombified_piglin` | main |
| `ZOMBIFIED_PIGLIN_BABY` | `zombified_piglin_baby` | main |
| `ZOMBIFIED_PIGLIN_BABY_ARMOR` | `zombified_piglin_baby` | helmet, chestplate, leggings, boots (4 layers) |
| `ZOMBIFIED_PIGLIN_ARMOR` | `zombified_piglin` | helmet, chestplate, leggings, boots (4 layers) |
| `ZOMBIE_NAUTILUS` | `zombie_nautilus` | main |
