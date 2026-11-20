# Block entity models, part 1: chests, shulker boxes, beds and banners

| Item | Value |
|---|---|
| Covers | How the client draws the blocks whose block model has no geometry and whose look comes from a block entity renderer: the chest family (`chest`, `trapped_chest`, `ender_chest` and the eight copper chests), the shulker boxes (17 blocks), the banners (base cloth and pole; 32 blocks), and the finding that beds are not block entities in this version (they are ordinary block models). For each: texture choice, model geometry (every cuboid with origin, size, texture offset), the transform from block space, light, render type, the lid animation and its inputs, and the item forms in inventories. A table of the block entity renderers not covered is in section 7. Section 8 adds the End portal and the End gateway (`end_portal`, `end_gateway`): slab and cube geometry, the face rules, the layered screen-space portal shader with its tint table, the pipeline state, the gateway beam, and what a minimal client may approximate. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in the README) |
| Method | Static reading of the shipped bytecode (`javap`), with no execution. `javap -c -p -constants` for classes and `unzip -p` for the JSON data files (block states, models, item definitions). Texture images were not read in sections 1 to 7; only their file names and, from the PNG header, their pixel sizes. Section 8 also read the shader text files and decoded the pixels of the three End textures (a throwaway decoder, outside the repository). |
| Classes read | `net.minecraft.client.renderer.blockentity.ChestRenderer`, `ShulkerBoxRenderer` (and its inner `ShulkerBoxModel`), `BannerRenderer`, `BlockEntityRenderers`, `BlockEntityRenderDispatcher`, `BrightnessCombiner`, `WallAndGroundTransformations`; `...blockentity.state.ChestRenderState` (and `ChestMaterialType`), `ShulkerBoxRenderState`, `BannerRenderState`; `net.minecraft.client.model.object.chest.ChestModel`, `net.minecraft.client.model.object.banner.BannerModel` and `BannerFlagModel`, `net.minecraft.client.model.monster.shulker.ShulkerModel` (its `createBoxLayer`), `net.minecraft.client.renderer.MultiblockChestResources`, `Sheets`, `SpriteMapper`, `special.ChestSpecialRenderer`, `special.ShulkerBoxSpecialRenderer`, `special.BannerSpecialRenderer`, `item.SpecialModelWrapper`, `item.ItemStackRenderState$LayerRenderState`, `resources.model.cuboid.ItemTransform`, `net.minecraft.util.SpecialDates`, `net.minecraft.util.LightCoordsUtil`, `net.minecraft.core.Direction`, `net.minecraft.world.item.DyeColor`, `LevelRenderer` (the block entity loop). |
| Round | Clean-room round "visual round 3" (chests, shulker boxes, beds, banners). Sections 1 to 6 are the specification, section 7 the renderers left for a later round (the End portal and the End gateway rows now point to section 8), section 8 the End portal and gateway (round "portalrender", task T46004), section 9 the numbered open questions. |
| Related | 31-5 §4 (the gateway block entity), 38 and 39 (the End and portals), 12 §3.3 (fog and the reversed-Z depth buffer), 50 §2.4 (the End-portal loading background, the same pipeline), 06 §3.2 (block entity list of the chunk packet), 34-1 §1.3 (cuboid unwrap, used here by reference), 34-1 §1.1 (rotation conventions), 31-1 §8.3, §10 and §13 (the server side of chests and shulker boxes: block events, lid controller, shulker progress), 05a (Block Event packet, id 7), 12 (client rendering), 51 (shapes) |

## 1. Summary and what an implementer needs to know first

1. A chest, trapped chest, ender chest, copper chest, shulker box and banner block has a block state file whose one model has **no elements** (only a particle texture). Chunk meshing therefore produces nothing for these blocks; the **block entity renderer** draws them every frame from the entity model described below. An implementer who wants them in a chunk mesher must emit the entity geometry as static quads at mesh time (lid closed) and treat the lid or flag animation separately (sections 3.8, 4.4, 6.5).
2. **Beds have no block entity and no renderer in this version.** `BlockEntityTypes` contains no bed type and `BlockEntityRenderers` registers none. All beds are plain JSON block models (section 5), meshed like any other block. The undyed-looking "bed texture" of older versions is replaced by per-colour 16 x 16 textures. There is also a 17th bed, `straw_bed`, with its own model.
3. Entity model geometry for chests and shulker boxes uses the cuboid rule of **34-1 §1.3** (corner letters A to H, texture strip U0..U5 and V0..V2, per-face rectangles, vertex texture coordinates, face visibility set). This document gives only the cuboids and the transforms. Nothing in the chest path flips the model: there is **no y or z mirror** between the model and the world (section 2.2); the shulker box path does flip (section 4.3).
4. The renderers draw with a **light** value sampled at the block entity's own position (section 2.3) and **no overlay**, white vertex colour (section 2.3).
5. **`end_portal` and `end_gateway` are the other kind of block entity block**: render shape `INVISIBLE`, an element-less model, and a block entity renderer that draws a slab (portal: y 0.375 to 0.75, top and bottom face only) or a cube (gateway) with a screen-space layered shader, no light and no overlay (section 8). The client draws them only when the chunk packet lists their block entities (section 8.1 point 2).

## 2. Common conventions

### 2.1 How block entity models reach the screen

- `LevelRenderer` loops over the block entity render states of the frame. For each it pushes the pose, translates by (block x − camera x, block y − camera y, block z − camera z) in doubles, calls `BlockEntityRenderDispatcher.submit` and pops. **No other translation, scale or flip is applied by the loop.** The renderer's own transform (sections 3.6, 4.3, 6.4) is therefore relative to the block's minimum corner (x, y, z of the block position).
- A renderer is chosen by the block entity **type** (`BlockEntityRenderers.register`). The registered renderers are listed in section 7; the three in this document are `chest`, `ender_chest`, `trapped_chest` (all `ChestRenderer`), `shulker_box` (`ShulkerBoxRenderer`) and `banner` (`BannerRenderer`).
- Model parts are drawn with the part pose of 34-1 §1.1 (translate by pivot / 16 blocks, then rotate by `rotationZYX(zRot, yRot, xRot)`, then scale) and vertices are emitted as in 34-1 §1.3 step 9. All lengths below are **pixels of 1/16 block** unless marked "blocks".

### 2.2 Orientation of the chest model (important)

The chest transform (section 3.6) is only a rotation about the vertical axis through the block centre. The model coordinates are therefore **block pixels with y up and z increasing to the south**, exactly like the block space of document 51. The default (`facing = south`) puts the front (the latch) at z = 16 (south side). The face names of 34-1 §1.3 are model-space names: `DOWN` is the face at minimum y (the **geometric bottom** of a cuboid in this model), `UP` at maximum y, `NORTH` at minimum z. Whether the chest's artwork has its top and bottom rectangles where 34-1 §1.3 puts them cannot be checked without reading pixels (Open question 1). Entity models of mobs, the shulker box and the banner, by contrast, are drawn with a y-down model and a flip (34-1 §1.1, sections 4.3 and 6.4).

### 2.3 Render types, light, overlay, colour

| Renderer | Render type function (read) | Meaning |
|---|---|---|
| Chest family (`ChestModel`) | `RenderTypes.entityCutoutCull` | alpha-tested (cutout), back faces culled |
| Shulker box (`ShulkerBoxModel`) | `RenderTypes.entityCutout` | alpha-tested, no culling |
| Banner pole and flag (`BannerModel`, `BannerFlagModel`) | `RenderTypes.entitySolid` | opaque |
| Banner pattern layers (`submitPatternLayer`) | `RenderTypes.bannerPattern` | not read further (patterns are out of scope) |

- All of them are submitted with vertex colour −1 (opaque white, no tint) except the banner base layer of section 6.3, and overlay `OverlayTexture.NO_OVERLAY` (no red hurt tint).
- **Light.** `BlockEntityRenderState.extractBase` stores `lightCoords = LightCoordsUtil.getLightCoords(level, blockPos)`: the packed brightness (block light and sky light) at the entity's own cell; if the cell's state renders emissively the value is full bright 15728880; otherwise, if the state's own light emission is greater than the sampled block light, the block-light component is raised to the emission. The packed form is sky light in bits 20 to 23 and block light in bits 4 to 7 (`pack(block, sky) = block << 4 | sky << 20`). Which getter supplies the packed brightness (the `BrightnessGetter.DEFAULT`) was not read (Open question 2). The whole model uses this single value (no per-face shading is added by the renderer beyond what the render pipeline does for entities).
- For a **double chest** the light is the per-component maximum of the light of both halves' cells (section 3.8).

### 2.4 Direction constants used below (read from `Direction`)

| Direction | `toYRot()` (degrees) | Notes |
|---|---|---|
| south | 0 | `data2d` 0 |
| west | 90 | `data2d` 1 |
| north | 180 | `data2d` 2 |
| east | 270 | `data2d` 3 |

Rotation about +Y by angle a (the helper `Axis.YP.rotationDegrees(a)`): x' = x cos a + z sin a, z' = −x sin a + z cos a (right-handed; checked below: a chest facing west with a = −90° puts its front toward −x).

## 3. The chest family

### 3.1 Blocks and block entity types

| Block entity type (registry id) | Blocks | Renderer |
|---|---|---|
| `chest` | `chest`, `copper_chest`, `exposed_copper_chest`, `weathered_copper_chest`, `oxidized_copper_chest`, `waxed_copper_chest`, `waxed_exposed_copper_chest`, `waxed_weathered_copper_chest`, `waxed_oxidized_copper_chest` (membership: 31-1 §3.1) | `ChestRenderer` |
| `trapped_chest` | `trapped_chest` | `ChestRenderer` |
| `ender_chest` | `ender_chest` | `ChestRenderer` |

The copper chests exist in this version. Their block state files are one variant each (`""` mapping to the block model of the same weathering stage; the four waxed blocks map to the unwaxed stage's model, for example `waxed_oxidized_copper_chest` to `block/oxidized_copper_chest`). Every one of these block models has no `elements` key, only a `particle` texture: `block/oak_planks` (chest, trapped chest), `block/obsidian` (ender chest), `block/copper_block`, `block/exposed_copper`, `block/weathered_copper`, `block/oxidized_copper` (copper stages).

### 3.2 What the renderer reads from the block state (`ChestRenderer.extractRenderState`)

| Field | Source |
|---|---|
| `facing` | block state property `facing` (horizontal: north, south, west, east). Default of a fresh render state: south. |
| `type` | block state property `type` (values `single`, `left`, `right`; `ChestType`) when the state has it; **otherwise `single`** (the ender chest has no `type`). |
| `material` | section 3.3 |
| `open` | section 3.7 |
| `lightCoords` | section 2.3, replaced for a non-single chest by the double-chest light (3.8) |

A double chest is recognised only by the `type` property of **its own half**: `left` or `right` means this half draws the double-chest half model of section 3.5. Each half is its own block entity and is drawn separately; nothing is drawn "for the pair". The partner cell is the one in `ChestBlock.getConnectedDirection` (31-1 §10.2: the facing rotated clockwise for `left`, counter-clockwise for `right`).

### 3.3 Texture choice (`getChestMaterial`, `Sheets.chooseSprite`)

The material is decided by this ordered test on the **block** and the **block entity class** (first match wins):

1. The block is a `CopperChestBlock`: the material is the copper stage of the block's weathering state (`unaffected`, `exposed`, `weathered`, `oxidized`). Waxing is not distinguished (the eight blocks share four sets of textures).
2. The block entity is an `EnderChestBlockEntity`: `ender`.
3. The **christmas flag** is set (below): `christmas`. (This overrides `trapped_chest`.)
4. The block entity is a `TrappedChestBlockEntity`: `trapped`.
5. Otherwise `normal` (called REGULAR).

**Christmas flag.** `ChestRenderer.xmasTextures()` = `SpecialDates.isExtendedChristmas()`: true when today's month and day in the client's **local time zone** (`ZonedDateTime.now()`) is December 24, 25 or 26. The renderer reads it **once, in its constructor**, so the choice is fixed until the renderers are rebuilt (a resource reload or client restart). It never applies to copper or ender chests.

**Texture ids and paths.** A sprite id is the prefix `entity/chest/` plus the id below; the texture file is `textures/<sprite id>.png` of the atlas `textures/atlas/chest.png`. Every chest texture is **64 x 64** pixels. The three variants per material are the file `<id>.png`, `<id>_left.png`, `<id>_right.png` (`createDefaultTextures` appends `_left` and `_right`), chosen by `type` (`single`, `left`, `right`):

| Material | Single | Left half | Right half |
|---|---|---|---|
| normal | `textures/entity/chest/normal.png` | `normal_left.png` | `normal_right.png` |
| trapped | `trapped.png` | `trapped_left.png` | `trapped_right.png` |
| christmas | `christmas.png` | `christmas_left.png` | `christmas_right.png` |
| copper (unaffected, waxed or not) | `copper.png` | `copper_left.png` | `copper_right.png` |
| copper exposed | `copper_exposed.png` | `copper_exposed_left.png` | `copper_exposed_right.png` |
| copper weathered | `copper_weathered.png` | `copper_weathered_left.png` | `copper_weathered_right.png` |
| copper oxidized | `copper_oxidized.png` | `copper_oxidized_left.png` | `copper_oxidized_right.png` |
| ender | `textures/entity/chest/ender.png` for every `type` (no left or right file exists) | same | same |

All 22 chest files (three single/left/right sets for normal, trapped and christmas, four for the copper stages, 21 files, and `ender.png`) exist in the artifact under `textures/entity/chest/`.

### 3.4 Models and layers

| Layer (registered) | Mesh builder | Texture size | Used when |
|---|---|---|---|
| `CHEST` | `ChestModel.createSingleBodyLayer` | 64 x 64 | `type = single` |
| `DOUBLE_CHEST_LEFT` | `createDoubleBodyLeftLayer` | 64 x 64 | `type = left` |
| `DOUBLE_CHEST_RIGHT` | `createDoubleBodyRightLayer` | 64 x 64 | `type = right` |

(`MultiblockChestResources.select(type)`: single, left, right.) The same single layer is shared by the chest minecart renderer (not covered).

### 3.5 Geometry of the three models

Every model has the root with three children, in creation order **bottom, lid, lock**. Pixel units, y up. "Pivot" is the part's pose offset (rotation zero); the cuboid origin is relative to the pivot. Texture offset is (u, v). No mirror flag, no deformation, texture scale 1. "Faces" lists the visible set (default all six).

**Single chest** (`createSingleBodyLayer`)

| Part | Pivot (x, y, z) | Texture offset | Origin (ox, oy, oz) | Size (w, h, d) | Faces | Block-space box when closed (x1,y1,z1)-(x2,y2,z2) |
|---|---|---|---|---|---|---|
| bottom | (0, 0, 0) | (0, 19) | (1, 0, 1) | 14 x 10 x 14 | all 6 | (1,0,1)-(15,10,15) |
| lid | (0, 9, 1) | (0, 0) | (1, 0, 0) | 14 x 5 x 14 | all 6 | (1,9,1)-(15,14,15) |
| lock | (0, 9, 1) | (0, 0) | (7, −2, 14) | 2 x 4 x 1 | all 6 | (7,7,15)-(9,11,16) |

**Double chest, right half** (`createDoubleBodyRightLayer`; partner cell on the counter-clockwise side, the seam is on the +x side)

| Part | Pivot | Texture offset | Origin | Size | Faces | Closed box |
|---|---|---|---|---|---|---|
| bottom | (0, 0, 0) | (0, 19) | (1, 0, 1) | 15 x 10 x 14 | all except `EAST` | (1,0,1)-(16,10,15) |
| lid | (0, 9, 1) | (0, 0) | (1, 0, 0) | 15 x 5 x 14 | all except `EAST` | (1,9,1)-(16,14,15) |
| lock | (0, 9, 1) | (0, 0) | (15, −2, 14) | 1 x 4 x 1 | all except `EAST` | (15,7,15)-(16,11,16) |

**Double chest, left half** (`createDoubleBodyLeftLayer`; partner cell on the clockwise side, the seam is on the −x side)

| Part | Pivot | Texture offset | Origin | Size | Faces | Closed box |
|---|---|---|---|---|---|---|
| bottom | (0, 0, 0) | (0, 19) | (0, 0, 1) | 15 x 10 x 14 | all except `WEST` | (0,0,1)-(15,10,15) |
| lid | (0, 9, 1) | (0, 0) | (0, 0, 0) | 15 x 5 x 14 | all except `WEST` | (0,9,1)-(15,14,15) |
| lock | (0, 9, 1) | (0, 0) | (0, −2, 14) | 1 x 4 x 1 | all except `WEST` | (0,7,15)-(1,11,16) |

The face sets are `Util.allOfEnumExcept(EAST)` and `allOfEnumExcept(WEST)`: the omitted face is the one at the seam. In a facing = south frame the right half's partner is at +x (counter-clockwise from south is east) and the left half's partner at −x (clockwise from south is west), consistent with the omitted faces (the doubled chest has no 1-pixel gap at the seam). The lid of the double halves is 15 wide so the two lids meet. The lock (latch) of a double chest is 1 pixel wide at the seam edge of each half, so the two halves together form the 2-pixel latch.

Texture strips (34-1 §1.3 step 4), for the documented cuboids:

| Cuboid (w x h x d at offset) | U0..U5 | V0..V2 |
|---|---|---|
| single bottom 14 x 10 x 14 at (0, 19) | 0, 14, 28, 42, 42, 56 | 19, 33, 43 |
| single lid 14 x 5 x 14 at (0, 0) | 0, 14, 28, 42, 42, 56 | 0, 14, 19 |
| double bottom 15 x 10 x 14 at (0, 19) | 0, 14, 29, 44, 43, 58 | 19, 33, 43 |
| double lid 15 x 5 x 14 at (0, 0) | 0, 14, 29, 44, 43, 58 | 0, 14, 19 |
| single lock 2 x 4 x 1 at (0, 0) | 0, 1, 3, 5, 4, 6 | 0, 1, 5 |
| double lock 1 x 4 x 1 at (0, 0) | 0, 1, 2, 3, 3, 4 | 0, 1, 5 |

The face rectangles follow from 34-1 §1.3 step 5 (`DOWN` (U1, V0)-(U2, V1), `UP` (U2, V1)-(U3, V0), `WEST` (U0, V1)-(U1, V2), `NORTH` (U1, V1)-(U2, V2), `EAST` (U2, V1)-(U4, V2), `SOUTH` (U4, V1)-(U5, V2)); the `EAST` rectangle ends at U4, not U3.

### 3.6 Transform from block space (`ChestRenderer.submit`, `createModelTransformation`)

For the entity's `facing`, the pose is multiplied by the matrix that rotates about the vertical axis through the point (0.5, 0, 0.5) blocks by the angle **−`toYRot(facing)`** degrees (`Matrix4f.rotationAround(YP.rotationDegrees(−yRot), 0.5, 0, 0.5)`). There is no translation otherwise, no scale and no flip. A model point (x, y, z) pixels becomes, in block coordinates relative to the block's minimum corner, with (X, Y, Z) = (x, y, z) / 16:

| facing | angle a | x' | z' | y' |
|---|---|---|---|---|
| south | 0° | X | Z | Y |
| west | −90° | 1 − Z | X | Y |
| north | −180° | 1 − X | 1 − Z | Y |
| east | −270° (= +90°) | Z | 1 − X | Y |

Check: the lock of a single chest at facing = west sits at X in [7/16, 9/16], Z in [15/16, 1], so x' = 1 − Z is in [0, 1/16] (the west side): the front faces west. ✓

### 3.7 Lid animation (client)

1. **Source of openness.** The server sends block event id 1 with the opener count as its parameter (31-1 §8.3; packet: Clientbound Block Event, 05a id 7). The client chest and ender chest entities set `shouldBeOpen = (count > 0)` on their `ChestLidController`. Each client tick (every loaded chest entity ticks on the client only, 31-1 §10.4) the controller runs 31-1 §10.3: `oldOpenness = openness`; if `shouldBeOpen`: `openness = min(openness + 0.1, 1)`, else `openness = max(openness − 0.1, 0)`. The value for the frame is `p = lerp(partialTick, oldOpenness, openness)`. A full open or close therefore lasts 10 ticks, linear in time.
2. **Double chests share the lid.** `ChestBlock.combine(state, level, pos, ignoreBlocked = true)` is evaluated with the `opennessCombiner`: for a double chest `p = max(p_first, p_second)` of the two halves' `p` (31-1 §10.2); a single chest uses its own `p`. Because the client combine passes `ignoreBlocked = true`, a chest with a block above it still animates. Both halves therefore draw the same lid angle. A render state built without a level (no block entity level) uses its own `p` and a default chest state facing south.
3. **Smoothing to angle.** `ChestRenderer.submit` computes `e = 1 − (1 − p)^3` (an ease-out cubic: the lid opens fast at first). `ChestModel.setupAnim(e)` sets, on **both the lid part and the lock part**, `xRot = −e × 1.5707964` radians (−90° at full open). The pivot of both is (0, 9, 1) (the hinge line at height 9 px, 1 px from the north edge in the model frame, before the facing rotation), so the lid and lock rotate together about the X axis through that pivot.
4. Direction check: a point at pivot-relative (y, z) = (0, 14) goes to y' = −14 sin(xRot), z' = 14 cos(xRot); with xRot = −90° that is y' = +14, z' = 0, so the front edge rises. At full open the lid occupies (block pixels) y in [9, 23] and z in [−4, 1] (the lid box y 0..5, z 0..14 relative to the pivot maps to y' = z_rel in [0, 14] and z' = −y_rel in [−5, 0]), i.e. it leaves the block cell on the north side.

| p | e | lid xRot (rad) | degrees |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0.1 | 0.271 | −0.4257 | −24.39 |
| 0.25 | 0.578125 | −0.9081 | −52.03 |
| 0.5 | 0.875 | −1.3744 | −78.75 |
| 0.75 | 0.984375 | −1.5462 | −88.59 |
| 1 | 1 | −1.5707964 | −90 |

(The numbers follow from the formula; e = 1 − (1 − p)^3.)

### 3.8 Light of a double chest

For `type` other than `single`, the renderer replaces `lightCoords` by the result of `DoubleBlockCombiner.NeighborCombineResult.apply(new BrightnessCombiner())` (computed with `ignoreBlocked = true`): for a double result, `LightCoordsUtil.max(light(first cell), light(second cell))`, where `max` takes the larger block-light component and the larger sky-light component separately and repacks them; for a single or none result the entity's own value is kept. Both halves of a pair therefore use the same light.

### 3.9 Differences between chest, trapped chest, ender chest and copper chests

| Aspect | normal | trapped | ender | copper |
|---|---|---|---|---|
| Geometry | single model, double halves | same | **single model only** (no `type` property, `type` forced to single) | same as normal |
| Texture | `normal*.png` | `trapped*.png` | `ender.png` | `copper*.png` by weathering stage |
| christmas | yes (Dec 24 to 26) | yes (christmas overrides trapped) | no | no |
| Lid animation | block event 1 | block event 1 (inherits chest) | block event 1 (own lid controller, 31-1 §11) | block event 1 |

The ender chest renders the same single model and the same `facing` rotation.

### 3.10 Item form in inventories

The items `chest`, `trapped_chest`, `ender_chest` and the eight copper chests use **`special` item models** whose `model.type` is `minecraft:chest` (`ChestSpecialRenderer`), not the block model.

| Item | Item definition structure | `base` model | `texture` id |
|---|---|---|---|
| `chest` | `select` on property `minecraft:local_time`, pattern `MM-dd`; cases `12-24`, `12-25`, `12-26` use `christmas`, fallback uses `normal` | `minecraft:item/chest` | `minecraft:christmas` (those three dates), else `minecraft:normal` |
| `trapped_chest` | same select | `minecraft:item/trapped_chest` | `minecraft:christmas` (those dates), else `minecraft:trapped` |
| `ender_chest` | plain special | `minecraft:item/ender_chest` | `minecraft:ender` |
| `copper_chest`, `waxed_copper_chest` | plain special | `minecraft:item/copper_chest` | `minecraft:copper` |
| `exposed_copper_chest`, `waxed_exposed_copper_chest` | plain special | `minecraft:item/exposed_copper_chest` | `minecraft:copper_exposed` |
| `weathered_copper_chest`, `waxed_weathered_copper_chest` | plain special | `minecraft:item/weathered_copper_chest` | `minecraft:copper_weathered` |
| `oxidized_copper_chest`, `waxed_oxidized_copper_chest` | plain special | `minecraft:item/oxidized_copper_chest` | `minecraft:copper_oxidized` |

(The waxed items share the base model and texture id of the unwaxed ones; the item definition files were read for the first, exposed, weathered, oxidized and the waxed and waxed-oxidized stages; the waxed exposed and weathered files were not opened, Open question 8.) The special renderer's codec has optional fields `openness` (default 0) and `chest_type` (default `single`); no item definition sets them, so the item shows the **single closed chest** model (type `single`, `xRot = 0`; `ChestSpecialRenderer` draws the model with the sprite `entity/chest/<texture id>` and **no facing rotation, no extra transformation**: the item definitions have no `transformation` entry). The texture id maps to the chest sprite file by the prefix rule of 3.3 (for example `minecraft:normal` to `textures/entity/chest/normal.png`).

Placement in the item frame: the item is drawn with the model at its default (south-facing) block-space position. `ItemStackRenderState$LayerRenderState` applies, in order, the **display transform** `D` of the `base` model for the display context (`ItemTransform.apply`: translate by `translation` × 0.0625, rotate by `rotationXYZ(rx, ry, rz)` degrees × 0.017453292, scale by `scale`, then translate by (−0.5, −0.5, −0.5)) and then the item definition's own local `transformation` matrix (none for chests). The translation's scaling and a clamp to ±5 are applied when the JSON is read (`ItemTransform$Deserializer`: constants 0.0625 and ±5 present, their exact order not re-read; the scale is clamped to ±4). For the chest, trapped chest, ender chest and every copper chest the `base` models have parent `minecraft:item/template_chest`, with these display entries:

| Context | rotation (x, y, z) | translation (x, y, z) | scale |
|---|---|---|---|
| `gui` | (30, 45, 0) | (0, 0, 0) | 0.625 |
| `ground` | (0, 0, 0) | (0, 3, 0) | 0.25 |
| `head` | (0, 180, 0) | (0, 0, 0) | 1 |
| `fixed` | (0, 180, 0) | (0, 0, 0) | 0.5 |
| `thirdperson_righthand` | (75, 315, 0) | (0, 2.5, 0) | 0.375 |
| `firstperson_righthand` | (0, 315, 0) | (0, 0, 0) | 0.4 |

(`translation` values are in 1/16 block; `template_chest` has no `gui_light` entry, Open question 4.) `template_shulker_box` has exactly the same six entries. For the GUI the composed matrix maps a chest model pixel (x, y, z) to: T(0) · R_XYZ(30°, 45°, 0°) · S(0.625) · T(−0.5, −0.5, −0.5) · (x/16, y/16, z/16), applied in the GUI's own projection. The item chest is therefore the block-space chest rotated 30° about X and 45° about Y about the cell centre and scaled to 0.625.

### 3.11 Worked examples

**E1 single chest, closed, facing south. Body cuboid.** Texture 64 x 64, offset (0, 19), origin (1, 0, 1), size 14 x 10 x 14, pivot (0, 0, 0).
Corners in model pixels (34-1 §1.3 step 3): A (1,0,1), B (15,0,1), C (15,10,1), D (1,10,1), E (1,0,15), F (15,0,15), G (15,10,15), H (1,10,15). Block space (divide by 16, facing south = identity): A (0.0625, 0, 0.0625), B (0.9375, 0, 0.0625), C (0.9375, 0.625, 0.0625), D (0.0625, 0.625, 0.0625), E (0.0625, 0, 0.9375), F (0.9375, 0, 0.9375), G (0.9375, 0.625, 0.9375), H (0.0625, 0.625, 0.9375).
Strip: U0..U5 = 0, 14, 28, 42, 42, 56; V0..V2 = 19, 33, 43. Face rectangles in pixels and in normalised texture coordinates (divide by 64; u/64: 14 = 0.21875, 28 = 0.4375, 42 = 0.65625, 56 = 0.875; v/64: 19 = 0.296875, 33 = 0.515625, 43 = 0.671875):

| Face | Pixel rectangle (minU, minV)-(maxU, maxV) | Normalised |
|---|---|---|
| `DOWN` (y = 0) | (14, 19)-(28, 33) | (0.21875, 0.296875)-(0.4375, 0.515625) |
| `UP` (y = 10) | (28, 33)-(42, 19) read upward | (0.4375, 0.515625)-(0.65625, 0.296875) |
| `WEST` (x = 1) | (0, 33)-(14, 43) | (0, 0.515625)-(0.21875, 0.671875) |
| `NORTH` (z = 1) | (14, 33)-(28, 43) | (0.21875, 0.515625)-(0.4375, 0.671875) |
| `EAST` (x = 15) | (28, 33)-(42, 43) | (0.4375, 0.515625)-(0.65625, 0.671875) |
| `SOUTH` (z = 15) | (42, 33)-(56, 43) | (0.65625, 0.515625)-(0.875, 0.671875) |

**E2 the same body, facing west.** Apply the west row of 3.6 to E1's block-space corners: A (0.0625, 0, 0.0625) goes to x' = 1 − 0.0625 = 0.9375, z' = 0.0625; B (0.9375, 0, 0.0625) to (0.9375, 0, 0.9375); E (0.0625, 0, 0.9375) to (0.0625, 0, 0.0625); F (0.9375, 0, 0.9375) to (0.0625, 0, 0.9375). The `SOUTH` face (z = 15) becomes the west face (x' = 0.0625): the front faces west. ✓

**E3 lid, closed, single chest.** Pivot (0, 9, 1), origin (1, 0, 0), size 14 x 5 x 14: model box x 1..15, y 9..14, z 1..15. Strip: U0..U5 = 0, 14, 28, 42, 42, 56; V0..V2 = 0, 14, 19. `NORTH` (14, 14)-(28, 19), `SOUTH` (42, 14)-(56, 19), `DOWN` (14, 0)-(28, 14), `UP` (28, 14)-(42, 0).

**E4 lock.** Pivot (0, 9, 1), origin (7, −2, 14), size 2 x 4 x 1: box x 7..9, y 7..11, z 15..16. Strip: U0..U5 = 0, 1, 3, 5, 4, 6; V0..V2 = 0, 1, 5. `SOUTH` (the face at z = 16, the front at facing south) = (U4, V1)-(U5, V2) = (4, 1)-(6, 5); `NORTH` = (1, 1)-(3, 5) (the artwork's orientation is Open question 1).

**E5 right half of a double chest, facing south.** Bottom: box x 1..16, y 0..10, z 1..15; faces without `EAST`; strip: U0..U5 = 0, 14, 29, 44, 43, 58. `SOUTH` rectangle (U4, V1)-(U5, V2) = (43, 33)-(58, 43); `WEST` (0, 33)-(14, 43).

**E6 lid angle.** `p` = 0.5: `e` = 0.875, `xRot` = −1.3744 rad, the lid front-top corner (x 1, y 14, z 15 pixels at p = 0): relative to pivot (y 5, z 14): y' = 5 cos(−1.3744) − 14 sin(−1.3744) = 0.975 + 13.731 = 14.707; z' = 5 sin(−1.3744) + 14 cos(−1.3744) = −4.904 + 2.731 = −2.173; in block pixels y = 9 + 14.707 = 23.707, z = 1 − 2.173 = −1.173.

## 4. Shulker boxes

### 4.1 Blocks, state and texture

The 17 blocks of 31-1 §3.1 id 24 (`shulker_box` and the 16 dyed `<colour>_shulker_box`). Block state files: one variant `""` to the block model of the same name, which has no elements (particle `block/<colour>_shulker_box` or `block/shulker_box`). The renderer reads: `direction` from the block state property `facing` (six values; default **up** when absent), `color` from `ShulkerBoxBlockEntity.getColor()` (a `DyeColor` or none; none for the undyed block), `progress` from `ShulkerBoxBlockEntity.getProgress(partialTick)` (31-1 §13.2: `lerp(partialTick, progressOld, progress)`, 0 to 1).

Texture: sprite id `entity/shulker/shulker_<colour name>` for a colour and `entity/shulker/shulker` for none, in the atlas `textures/atlas/shulker_boxes.png`; files `textures/entity/shulker/shulker.png` and `shulker_<name>.png`, all **64 x 64**. Colour names in `DyeColor` order (id 0 to 15): white, orange, magenta, light_blue, yellow, lime, pink, gray, light_gray, cyan, purple, blue, brown, green, red, black. (The file `textures/entity/shulker/spark.png` belongs to the bullet, not used here.)

### 4.2 Model (`ShulkerModel.createBoxLayer`, texture 64 x 64)

The block layer is the shell mesh of the mob without the head. Two children in creation order **lid, base**, y down (a mob-style model; 4.3 flips it):

| Part | Pivot | Texture offset | Origin | Size | Faces |
|---|---|---|---|---|---|
| lid | (0, 24, 0) | (0, 0) | (−8, −16, −8) | 16 x 12 x 16 | all 6 |
| base | (0, 24, 0) | (0, 28) | (−8, −8, −8) | 16 x 8 x 16 | all 6 |

Strips: lid U0..U5 = 0, 16, 32, 48, 48, 64; V0..V2 = 0, 16, 28. Base: U as lid; V0..V2 = 28, 44, 52. The lid shell (12 tall, y 8..20 in model pixels) overlaps the 8-pixel base (y 16..24) by 4 pixels.

### 4.3 Transform (`ShulkerBoxRenderer.createModelTransform`)

The pose is multiplied by `M = T(0.5, 0.5, 0.5) · S(0.9995) · R(direction.getRotation()) · S(1, −1, −1) · T(0, −1, 0)` (translations in blocks; applied to the vector (x, y, z) / 16, rightmost first). A model pixel (x, y, z) (after the part pose of 4.4) therefore becomes

P = (0.5, 0.5, 0.5) + 0.9995 · R · (x/16, 1 − y/16, −z/16).

`R` is the rotation of `Direction.getRotation()` (quaternion constants read: down = X by π; up = identity; north = X(π/2), Y(0), Z(π) via `rotationXYZ`; south = X by π/2; west = XYZ(π/2, 0, π/2); east = XYZ(π/2, 0, −π/2)). Taking `rotationXYZ(a, b, c)` as the matrix Rx(a) · Ry(b) · Rz(c) (inferred: it is the order for which the image of +Y equals the facing direction in every row), the 3 x 3 matrices (rows) are:

| direction | R | image of local +Y (the open direction) |
|---|---|---|
| up | identity | (0, 1, 0) |
| down | (1,0,0), (0,−1,0), (0,0,−1) | (0, −1, 0) |
| south | (1,0,0), (0,0,−1), (0,1,0) | (0, 0, 1) |
| north | (−1,0,0), (0,0,−1), (0,−1,0) | (0, 0, −1) |
| west | (0,−1,0), (0,0,−1), (1,0,0) | (−1, 0, 0) |
| east | (0,1,0), (0,0,−1), (−1,0,0) | (1, 0, 0) |

(Each row of R is a matrix row: the first number triple is the row giving the new x, and so on.) The scale 0.9995 shrinks the box by 0.0005 blocks on each side (anti z-fighting with neighbours).

### 4.4 Lid animation (`ShulkerBoxModel.setupAnim`)

With `progress` p from 4.1 (31-1 §13.2: linear 0.1 per tick over 10 ticks, interpolated by partial tick; both client and server tick it, status changes from block event 1: n = 1 opens, n = 0 closes, 31-1 §13.3):

| Lid property | Value |
|---|---|
| position (x, y, z) | (0, 24 − p × 0.5 × 16, 0) = (0, 24 − 8p, 0) model pixels (so the lid rises by 0.5 block × p × 0.9995 along the open direction) |
| `yRot` | p × 270 × 0.017453292 radians (= p × 4.7124) about the model Y axis through the lid pivot; since the model is flipped by S(1, −1, −1), the rotation as seen in the world has the opposite sense (inferred) |
| base | unchanged |

At p = 0 the lid is at pivot (0, 24, 0); at p = 1 at (0, 16, 0) rotated 270°. Item forms: 4.5.

### 4.5 Light and item form

Light: section 2.3 (own cell), render type `entityCutout`. Item: items `shulker_box` and `<colour>_shulker_box` are `special` models of type `minecraft:shulker_box` with `texture` `minecraft:shulker` (undyed) or `minecraft:shulker_<colour>` and the `base` model `minecraft:item/shulker_box` or `minecraft:item/<colour>_shulker_box` (parent `item/template_shulker_box`, display entries identical to the table in 3.10). The special renderer has `openness` (default 0, not set by any item) and draws the **raw** model (no `facing` rotation, no `M` of 4.3) using the item definition's own **local transformation**: translation (0.5, 1.4995, 0.5), left rotation quaternion (x 1, y 0, z 0, w 0) (180° about X: (x, y, z) to (x, −y, −z)), scale 0.9995. This equals the block transform for `facing = up`: P = (0.5, 1.4995, 0.5) + 0.9995 · (x/16, −y/16, −z/16), whose y for model y = 24 is 0.00025. The display transform of 3.10 is then applied on top (D · local).

### 4.6 Worked example (facing up, closed)

Base cuboid: model box x −8..8, y 16..24 (pivot 24 + origin −8 .. 0), z −8..8. P_x = 0.5 + 0.9995 × x/16 = 0.00025 .. 0.99975; P_y = 0.5 + 0.9995 × (1 − y/16): y = 16 gives 0.5, y = 24 gives 0.00025; P_z = 0.5 − 0.9995 × z/16 = 0.99975 .. 0.00025. So the base spans block y 0.00025 .. 0.5. Lid box: model y 8..20 (pivot 24 + origin −16..−4): P_y = 0.5 + 0.9995 × (1 − 8/16) = 0.99975 at the top and 0.5 + 0.9995 × (1 − 20/16) = 0.250125 at the bottom (the shell overlaps the base between y 0.25 and 0.5). In the standard entity unwrap (34-1 §1.3), the model `DOWN` face (minimum model y) is now the top: the lid top uses `DOWN` = (16, 0)-(32, 16), the base bottom uses `UP` = (32, 44)-(48, 28) read upward.
At p = 1, facing up: lid pivot (0, 16, 0): lid box model y 0..12 and the lid has risen by 8 model pixels (0.4998 block) and is turned 270° about the vertical axis.

## 5. Beds: ordinary block models (no block entity)

### 5.1 Findings

- `BlockEntityTypes` has 49 types and none is a bed; `BlockEntityRenderers` registers none for beds; `BedBlock` has no render-state or block-entity hook. A class `BedRenderState` exists in `...blockentity.state` but no renderer registered in this artifact uses it (it is unreferenced by the registration table; Open question 9).
- Every bed block draws from its block state file and block model, in the chunk mesh. 17 bed blocks: `white_bed`, `orange_bed`, `magenta_bed`, `light_blue_bed`, `yellow_bed`, `lime_bed`, `pink_bed`, `gray_bed`, `light_gray_bed`, `cyan_bed`, `purple_bed`, `blue_bed`, `brown_bed`, `green_bed`, `red_bed`, `black_bed` and `straw_bed`. The block state properties used are `facing` (the direction from the foot toward the head) and `part` (`head` or `foot`); `occupied` and others are ignored by the model selection.

### 5.2 Block state selection (all 16 coloured beds; the same file shape for each colour `<c>`)

| `facing` | `part=head` model | `part=foot` model | y rotation (clockwise from above, blockstate `y`) |
|---|---|---|---|
| north | `block/<c>_bed_head` | `block/<c>_bed_foot` | 0 (key absent) |
| east | same | same | 90 |
| south | same | same | 180 |
| west | same | same | 270 |

Verified for all 16 colours. The `straw_bed` file uses the same keys with models `block/straw_bed_head` / `block/straw_bed_foot` but a **different rotation table**: facing south 0 (absent), west 90, north 180, east 270.

### 5.3 Models of the coloured beds

`block/<c>_bed_head` has parent `block/template_bed_head` with textures `east` = `block/<c>_bed_head_east`, `up` = `block/<c>_bed_head_up`, `west` = `block/<c>_bed_head_west`; `block/<c>_bed_foot` has parent `block/template_bed_foot` with `east`, `south`, `up`, `west` = `block/<c>_bed_foot_<side>`. The template fills `north` (head only) = `block/bed_head_north` and `down` = `block/bed_down` (shared by all colours). All these textures are **16 x 16** (JSON model uv values are in 0..16, one unit per pixel). All 16 colours' files were verified to follow this naming exactly.

**`template_bed_head`** (parent `block/template_bed`; elements, `from`-`to` in pixels, `uv` = (u1, v1, u2, v2), `cull` = cullface):

| # | from | to | down | up | north | south | west | east |
|---|---|---|---|---|---|---|---|---|
| 1 mattress | (0, 3, 0) | (16, 9, 16) | uv (0,0,16,16) `#down` | (0,0,16,16) `#up` | (0,7,16,13) `#north` cull north | none | (0,7,16,13) `#west` cull west | (0,7,16,13) `#east` cull east |
| 2 leg (north-west) | (0, 0, 0) | (3, 3, 3) | (6,13,9,16) `#west` cull down | none | (13,13,16,16) `#north` cull north | (3,13,6,16) `#west` | (0,13,3,16) `#west` cull west | (10,13,13,16) `#north` |
| 3 leg (north-east) | (13, 0, 0) | (16, 3, 3) | (7,13,10,16) `#east` cull down | none | (0,13,3,16) `#north` cull north | (10,13,13,16) `#east` | (3,13,6,16) `#north` | (13,13,16,16) `#east` cull east |

**`template_bed_foot`**:

| # | from | to | down | up | north | south | west | east |
|---|---|---|---|---|---|---|---|---|
| 1 mattress | (0, 3, 0) | (16, 9, 16) | (0,0,16,16) `#down` | (0,0,16,16) `#up` | none | (0,7,16,13) `#south` cull south | (0,7,16,13) `#west` cull west | (0,7,16,13) `#east` cull east |
| 2 leg (south-west) | (0, 0, 13) | (3, 3, 16) | (7,13,10,16) `#west` cull down | none | (10,13,13,16) `#west` | (0,13,3,16) `#south` cull south | (13,13,16,16) `#west` cull west | (3,13,6,16) `#south` |
| 3 leg (south-east) | (13, 0, 13) | (16, 3, 16) | (6,13,9,16) `#east` cull down | none | (3,13,6,16) `#east` | (13,13,16,16) `#south` cull south | (10,13,13,16) `#south` | (0,13,3,16) `#east` cull east |

Neither template sets `rotation` or `shade`. At `facing = north`: the head cell is the one to the north of the foot cell (head end faces north: the head model has the north end texture, the foot model the south one), so `facing` points from the foot to the head (inferred from the models and the item composite below; the partner placement belongs to the block documents). The bed has a 3-pixel-high leg row, mattress y 3..9, no pillow geometry: the pillow is texture only. Display transforms (`block/template_bed`; the item composite below takes them from its child models):

| Context | rotation | translation | scale |
|---|---|---|---|
| `thirdperson_righthand` | (30, 340, 0) | (0, 3, −2) | 0.23 |
| `firstperson_righthand` | (30, 340, 0) | (0, 3, 0) | 0.375 |
| `gui` | (30, 340, 0) | (2, 3, 0) | 0.5325 |
| `ground` | (0, 180, 0) | (0, 1, 2) | 0.25 |
| `head` | (0, 0, 0) | (0, 10, −8) | 1 |
| `fixed` | (270, 180, 0) | (0, 4, −2) | 0.5 |
| `on_shelf` | (90, 0, 0) | (0, 14.5, 2.5) | 0.9375 |

### 5.4 Item form of the coloured beds

`<c>_bed` is a `composite` item model with two `model` children: (1) `block/<c>_bed_head` with no transformation, (2) `block/<c>_bed_foot` with the transformation translation (0, 0, 1), identity rotations, scale (1, 1, 1) (one block to the south). So the item shows the head model in cell (0, 0, 0) and the foot model in cell (0, 0, 1): the whole bed is a two-block-long object along z, head end at z = 0 (north). The display table of 5.3 is applied on top.

### 5.5 `straw_bed`

Textures `block/straw_bed` (**64 x 64**, all faces of both models use texture variable `all`) and the particle `block/straw_bed_particle`. JSON uv values are in 0..16 for the whole 64 x 64 texture, so pixel = uv × 4. Elements (pixels; `uv` per face; `c` = has a cullface; `r180` = face rotation 180):

`block/straw_bed_head` (12 elements):

| name | from | to | faces (uv) |
|---|---|---|---|
| base | (0,0,0) | (16,4,8) | north (2,5.25,6,6.25) c; east (0,5.25,2,6.25) c; south (8,5.25,12,6.25); west (6,5.25,8,6.25) c; up (6,5.25,2,3.25); down (10,3.25,6,5.25) c |
| pillow_frills_01 | (−2,0.065,8) | (0,0.065,16) | up (1.5,8.25,1,6.25) c; down (2,6.25,1.5,8.25) c |
| pillow_frills_02 | (−2,4.96,8) | (0,4.96,16) | up (10.5,2,10,0) c; down (11,0,10.5,2) c |
| pillow_frills_03 | (−2,0.065,8.025) | (0,4.95,8.025) | north (1,8.25,1.5,9.48125) c; south (2,8.25,1.5,9.48125) c |
| pillow_frills_04 | (−2,0.065,15.985) | (0,4.95,15.985) | north (10,3.25,10.5,4.48125) c; south (10.5,3.25,11,4.48125) c |
| pillow_frills_05 | (16,0.05,8) | (18,0.05,16) | up (0.5,8.25,0,6.25) c; down (0.5,6.25,1,8.25) c |
| pillow_frills_06 | (16,4.975,8) | (18,4.975,16) | up (0.5,2,0,0) c; down (0.5,0,1,2) c |
| pillow_frills_07 | (16,0.05,8) | (18,4.975,8) | north (0,8.25,0.5,9.48125) c; south (1,8.25,0.5,9.48125) c |
| pillow_frills_08 | (16,0.05,15.975) | (18,4.975,15.975) | north (0,3.25,0.5,4.48125) c; south (1,3.25,0.5,4.48125) c |
| pillow | (0,0,8) | (16,5,16) | north (2,2,6,3.25); east (0,2,2,3.25) c; south (8,2,12,3.25) c; west (6,2,8,3.25) c; up (6,2,2,0); down (10,0,6,2) c |
| frills_02 | (16,0.05,0) | (19,0.05,8) | up (12.75,6.25,12,4.25) c; down (13.5,4.25,12.75,6.25) c |
| frills_03 | (−3,0.065,0) | (0,0.065,8) | up (14.25,6.25,13.5,4.25) c; down (15,4.25,14.25,6.25) c |

`block/straw_bed_foot` (4 elements): base (0,0,0)-(16,4,16): north (4,10.25,8,11.25) c; east (0,10.25,4,11.25) c; west (8,10.25,12,11.25) c; up (8,10.25,4,6.25); down (12,6.25,8,10.25) c (no south face). frills_03 (0,0.125,−3)-(16,0.125,0): up (0,11.25,4,12) r180 c; down (0,12.75,4,12) r180 c. frills_04 (16,0.105,0)-(19,0.105,16): up (12,6.25,12.75,10.25) r180 c; down (12.75,10.25,13.5,6.25) r180 c. frills_05 (−3,0.115,0)-(0,0.115,16): up (13.5,10.25,14.25,6.25) r180 c; down (14.25,6.25,15,10.25) r180 c.

(The straw-bed element values in the file contain float noise such as 11.999999999999998; read as 12.) The frills are zero-thickness horizontal quads that extend 2 to 3 pixels outside the block cell (x −3 and x 19) and the pillow frills use cullface west or east. The straw bed's `display` entries equal the table of 5.3 except `head` (translation (0, 10, −8), no rotation or scale entry given) and `fixed` (translation (0, 4, −3)). The `straw_bed` item is a `composite` of the two models, each with left rotation (0, 1, 0, 0) (180° about Y) and translations: head (1, 0, 1), foot (1, 0, 2).

## 6. Banners

### 6.1 Blocks and what the renderer reads

32 blocks (31-1 id 20): `<colour>_banner` (standing, property `rotation` 0..15) and `<colour>_wall_banner` (property `facing`). Every one of the 32 block state files has a single variant `""` to `block/banner`, a model with no elements (particle `block/oak_planks`). `BannerRenderer.extractRenderState` reads: `baseColor` (`BannerBlockEntity.getBaseColor()`), the pattern layers, and:

| Block | Attachment | Transformation |
|---|---|---|
| standing banner (class `BannerBlock`) | ground | `freeTransformations(rotation)`: degrees = `RotationSegment.convertToDegrees(rotation)` = rotation × 22.5 (16 segments of 360/16) |
| wall banner (`WallBannerBlock`) | wall | `wallTransformation(facing)`: degrees = `facing.toYRot()` (2.4) |

`phase` (flag wave) = (floorMod(x × 7 + y × 9 + z × 13 + gameTime, 100) + partialTick) / 100 for the block position (x, y, z) and the level game time (0 without a level).

### 6.2 Transform (`BannerRenderer.modelTransformation`)

The pose is multiplied by `T(0.5, 0, 0.5) · R_y(−degrees) · S(2/3, −2/3, −2/3)` (`Transformation(translation (0.5, 0, 0.5), left rotation YP.rotationDegrees(−degrees), scale (0.6666667, −0.6666667, −0.6666667))`, constants `MODEL_TRANSLATION` and `MODEL_SCALE`). A model pixel (x, y, z) becomes (x', y', z') = (0.5, 0, 0.5) + R_y(−degrees) · ((2/3) x / 16, −(2/3) y / 16, −(2/3) z / 16), where R_y(a) is as in 2.4. So the model is y-down and z-flipped (mob style): the flag's low `z` side (its `NORTH` face, the pattern side) is toward the world +z at degrees = 0, i.e. a standing banner with `rotation` 0 shows its front to the south, the way chests at `facing = south` do.

### 6.3 Layers and textures

Two models per banner, both drawn each frame: `BannerModel` (pole and bar; **no animation**, `Unit` state) and `BannerFlagModel` (the flag; `setupAnim(phase)`). Layers: `STANDING_BANNER` and `WALL_BANNER` (`createBodyLayer(true or false)`), `STANDING_BANNER_FLAG` and `WALL_BANNER_FLAG` (`createFlagLayer(true or false)`), all **64 x 64**.

1. The pole/bar model and the flag model are drawn with the sprite `Sheets.BANNER_BASE` = sprite id `entity/banner/banner_base` (file `textures/entity/banner/banner_base.png`, 64 x 64, atlas `textures/atlas/banner_patterns.png`), colour −1 (white), render type `entitySolid`.
2. On top, with the **flag model only** (`bannerPattern` render type, order after the base), the first pattern layer is the sprite `Sheets.BANNER_PATTERN_BASE` = `entity/banner/base` (file `textures/entity/banner/base.png`, 64 x 64) **tinted by the banner's base colour**: `DyeColor.getTextureDiffuseColor()` (the table below). The visible cloth colour is therefore this layer. Pattern layers (up to 16, sprites `entity/banner/<pattern asset id>`) follow, each tinted by its dye colour; they are out of scope (the files are under `textures/entity/banner/`).

| Colour (id) | `getTextureDiffuseColor` (RGB hex) |
|---|---|
| white (0) | F9FFFE |
| orange (1) | F9801D |
| magenta (2) | C74EBD |
| light_blue (3) | 3AB3DA |
| yellow (4) | FED83D |
| lime (5) | 80C71F |
| pink (6) | F38BAA |
| gray (7) | 474F52 |
| light_gray (8) | 9D9D97 |
| cyan (9) | 169C9C |
| purple (10) | 8932B8 |
| blue (11) | 3C44AA |
| brown (12) | 835432 |
| green (13) | 5E7C16 |
| red (14) | B02E26 |
| black (15) | 1D1D21 |

(Whether the integer is used as opaque RGB or carries alpha was not read, Open question 5.)

### 6.4 Geometry (`BannerModel.createBodyLayer`, `BannerFlagModel.createFlagLayer`; `BANNER_WIDTH` 20, `BANNER_HEIGHT` 40)

Pixels, y down, then transformed by 6.2. "S" = standing layer, "W" = wall layer.

| Model | Part | Pivot | Texture offset | Origin | Size | Faces |
|---|---|---|---|---|---|---|
| `BannerModel` | pole (S only) | (0, 0, 0) | (44, 0) | (−1, −42, −1) | 2 x 42 x 2 | all 6 |
| `BannerModel` | bar | (0, 0, 0) | (0, 42) | S: (−10, −44, −1); W: (−10, −20.5, 9.5) | 20 x 2 x 2 | all 6 |
| `BannerFlagModel` | flag | S: (0, −44, 0); W: (0, −20.5, 10.5) | (0, 0) | (−10, 0, −2) | 20 x 40 x 1 | all 6 |

Strips (34-1 §1.3 step 4): flag U0..U5 = 0, 1, 21, 41, 22, 42 and V0..V2 = 0, 1, 41, so the pattern face (`NORTH`) is (1, 1)-(21, 41); pole (44, 0): U0..U5 = 44, 46, 48, 50, 50, 52, V0..V2 = 0, 2, 44; bar (0, 42): U0..U5 = 0, 2, 22, 42, 24, 44, V0..V2 = 42, 44, 46.

### 6.5 Flag animation

`BannerFlagModel.setupAnim(phase)`: flag `xRot` = (−0.0125 + 0.01 × cos(2π × phase)) × π radians (a rotation about the model X axis through the flag pivot; `phase` as in 6.1, cycle 100 ticks, phase increments with game time and the block position gives each banner its own offset). The range is from −0.0225 π = −0.0707 rad (cos = −1) to −0.0025 π = −0.00785 rad (cos = 1). For the item form the phase is 0: `xRot` = −0.0025 π = −0.00785 rad.

### 6.6 Worked examples (rotation 0, standing banner, in block space of the cell)

World = (0.5 + (2/3) x/16, −(2/3) y/16, 0.5 − (2/3) z/16):

| Part | x range | y range | z range |
|---|---|---|---|
| pole (x −1..1, y −42..0, z −1..1) | 0.4583..0.5417 | 0 .. 1.75 | 0.4583..0.5417 |
| bar (x −10..10, y −44..−42, z −1..1) | 0.0833..0.9167 | 1.75 .. 1.8333 | 0.4583..0.5417 |
| flag (x −10..10, y −44..−4, z −2..−1; at xRot 0) | 0.0833..0.9167 | 0.1667 .. 1.8333 | 0.5417..0.5833 |

(The flag is therefore in front (south) of the pole.) Wall banner, facing south (degrees 0): flag pivot z 10.5, box z 8.5..9.5 gives world z 0.1458..0.1042; bar z 9.5..11.5 gives 0.1042..0.0208; y: bar −20.5..−18.5 gives 0.8542..0.7708; flag y −20.5..19.5 gives 0.8542 down to −0.8125, i.e. the flag hangs about 0.81 below the block. `rotation` 4 (90°): R_y(−90°) maps (dx, dz) to (−dz, dx) (2.4 formula with a = −90°).

### 6.7 Item form

`<colour>_banner` items are `special` models of type `minecraft:banner` with `color` = the colour name, `base` model `minecraft:item/template_banner` and the local transformation: translation (0.5, 0, 0.5), identity left rotation, scale (0.6666667, −0.6666667, −0.6666667): this equals the standing transform 6.2 at degrees 0. The special renderer draws pole, bar and flag with phase 0 and the pattern layers read from the item's banner patterns component (`BannerSpecialRenderer.extractArgument`), attachment as set by its codec (the default was not read, Open question 5). Display transforms of `template_banner` (and `gui_light` = `front`):

| Context | rotation | translation | scale |
|---|---|---|---|
| `thirdperson_righthand` | (0, 90, 0) | (0, 2, 0.5) | 0.375 |
| `firstperson_righthand` | (0, 90, 0) | (0, 0, 0) | 0.375 |
| `gui` | (30, 20, 0) | (0, −3.25, 0) | 0.5325 |
| `ground` | (0, 0, 0) | (0, 1, 0) | 0.25 |
| `head` | (0, 180, 0) | (0, 16, 7) | 1.5 |
| `fixed` | (0, 180, 0) | (0, 0, 0) | 0.5 |

## 7. Block entity renderers not covered in this round

Registered in `BlockEntityRenderers` (read) and not described here, except `end_portal` and `end_gateway`, which section 8 describes. Block ids come from 31-1 §3.1 (sign and shelf and skull sets are summarised there).

| Block entity type | Blocks | Renderer class |
|---|---|---|
| `sign` | the 26 standing and wall signs of 13 woods | `StandingSignRenderer` / `AbstractSignRenderer`; specified in [52-block-entity-models-2-signs.md](52-block-entity-models-2-signs.md) (text only; the boards are block models) |
| `hanging_sign` | the 26 hanging and wall hanging signs | `HangingSignRenderer`; specified in [52-block-entity-models-2-signs.md](52-block-entity-models-2-signs.md) |
| `mob_spawner` | `spawner` | `SpawnerRenderer` |
| `piston` | `moving_piston` | `PistonHeadRenderer` |
| `enchanting_table` | `enchanting_table` | `EnchantTableRenderer` |
| `lectern` | `lectern` | `LecternRenderer` |
| `end_portal` | `end_portal` | `TheEndPortalRenderer`; **specified in section 8** |
| `end_gateway` | `end_gateway` | `TheEndGatewayRenderer` (cube and beam); **specified in section 8** |
| `beacon` | `beacon` | `BeaconRenderer` |
| `skull` | the 14 skull and head blocks | `SkullBlockRenderer` |
| `structure_block` | `structure_block` | `BlockEntityWithBoundingBoxRenderer` |
| `test_instance_block` | `test_instance_block` | `TestInstanceRenderer` |
| `conduit` | `conduit` | `ConduitRenderer` |
| `bell` | `bell` | `BellRenderer` |
| `campfire` | `campfire`, `soul_campfire` | `CampfireRenderer` |
| `brushable_block` | `suspicious_sand`, `suspicious_gravel` | `BrushableBlockRenderer` |
| `decorated_pot` | `decorated_pot` | `DecoratedPotRenderer` |
| `trial_spawner` | `trial_spawner` | `TrialSpawnerRenderer` |
| `vault` | `vault` | `VaultRenderer` |
| `copper_golem_statue` | the 8 copper golem statue blocks | `CopperGolemStatueBlockRenderer` |
| `shelf` | the 13 shelf blocks | `ShelfRenderer` |

(The registration list was read through the `SHELF` entry; the class `BlockEntityRenderers` has no `BED`, `FURNACE`, `BARREL` or `HOPPER` entry. Block entity types without a renderer, such as the furnaces, hopper, barrel, jukebox, are drawn from their block models only.) Not covered here either: the break (crumbling) overlay on chests, shulker boxes and banners, `ChestRenderer`'s use for the chest minecart, the shulker mob (34), and banner pattern composition.

## 8. End portal and end gateway

Round "portalrender" (task T46004: a client drew nothing for `end_portal` and `end_gateway`, so an opened portal looked like a hole). Same artifact as the header (SHA-256 `4508d006...9a2d`). Besides `javap` this section read the shader files `rendertype_end_portal.vsh` and `.fsh` and the includes `fog.glsl`, `globals.glsl`, `matrix.glsl`, `projection.glsl` (text data, described here in formulas), `rendertype_beacon_beam.vsh` and `.fsh`, and decoded the pixels of `textures/environment/end_sky.png`, `textures/entity/end_portal/end_portal.png` and `end_gateway_beam.png` with a throwaway decoder. Classes read: `AbstractEndPortalRenderer`, `TheEndPortalRenderer`, `TheEndGatewayRenderer`, `EndPortalRenderState`, `EndGatewayRenderState`, `TheEndPortalBlockEntity`, `TheEndGatewayBlockEntity`, `EndPortalBlock`, `EndGatewayBlock`, `Blocks` (the two registrations), `BlockBehaviour` and `BlockStateBase` (default shape, occlusion), `Block.shouldRenderFace`, `FaceInfo` (and `FaceInfo$Extent`), `RenderPipelines`, `RenderTypes`, `RenderSetup` (and its builder), `AbstractTexture`, `ReloadableTexture`, `TextureContents`, `SamplerCache`, `GlobalSettingsUniform`, `GameRenderer` (the uniform update), `LevelExtractor` (block entity extraction and `gameTime`), `BlockEntityRenderDispatcher`, `BlockEntityRenderer` (interface defaults), `SectionCompiler` (block entity hand-off), `SubmitNodeCollection` and `FeatureRenderDispatcher` (phase choice and order), `BeaconRenderer` (the beam routine), `DyeColor`, `ARGB`, `Mth.frac`, `LevelLoadingScreen` (its End-portal use), `BuiltInBlockModels`, `EndCubeSpecialRenderer`, `LevelChunk` (client creation of block entities), `RenderPipeline$Builder`, `ColorTargetState`, `DepthStencilState`, `BlendFunction`, `VulkanRenderPipeline` (front face and cull mode).

### 8.1 Summary: what a client needs first

1. **Why the hole.** `EndPortalBlock.getRenderShape` and `EndGatewayBlock.getRenderShape` return `INVISIBLE`, and both block state files map to a model with no elements (only a particle texture `block/obsidian`). The chunk mesher (`SectionCompiler`) draws nothing for them. Everything visible comes from the block entity renderers `TheEndPortalRenderer` (block entity type `end_portal`, registry id 14) and `TheEndGatewayRenderer` (type `end_gateway`, id 22; both ids from 31-1 §3.1 and 46). Both extend `AbstractEndPortalRenderer`.
2. **The block entity must exist on the client.** A client creates a block entity only (a) for each entry of the **block entity list of a chunk packet** (06 §3.2: packed XZ, Y, type id, optional NBT), or (b) when it applies a block change packet to a state that has a block entity (`LevelChunk.setBlockState` creates it with the block's `newBlockEntity`). A chunk packet that lists no entry for an `end_portal` or `end_gateway` block leaves the client with no block entity there, and nothing is drawn (section 8.3). A server must therefore list every such block in the chunk's block entity list, with the type id above and an empty tag (an empty compound is sent as absent, 06 §3.2); for the gateway the tag carries `Age` (31-5 §4). The gateway's update tag is the custom-only save: always `Age`, `ExactTeleport` when true and `exit_portal` when set (31-5 §4.2); **only `Age` matters for drawing** (it drives the spawn beam), the other two do not.
3. **Portal geometry.** A flat slab: x and z from 0 to 1, y from **0.375 to 0.75** of the cell; only the **top** (y = 0.75) and the **bottom** (y = 0.375) face are drawn, always, with no neighbour test; the four side faces are never drawn (section 8.4). The outline of the block (`getShape`) is the same slab, 16 x 6 x 16 pixels at y 6 to 12; the block has no collision box (`noCollision`).
4. **Gateway geometry.** A full unit cube (no squash); each of its six faces is drawn unless a neighbour hides it (`Block.shouldRenderFace`, section 8.5), plus the beam of section 8.9 while the gateway is spawning or cooling down.
5. **Surface.** One custom shader, no vertex colour, no UV, no light. The texture coordinates are computed per pixel from the **screen position** (a projective texture lookup of the clip-space position), not from the world position or the cell. The colour is the sum of the `end_sky` texture (once, unrotated) and 15 (portal) or 16 (gateway) layers of the `end_portal` texture, each layer scaled, rotated and scrolled by time, each multiplied by a per-layer tint (section 8.7). Alpha is 1.
6. **Pipeline state.** No blending, depth test "greater or equal" (reversed-Z buffer, 12 §3.3) with depth write, colour write RGBA, back-face culling, **fog applied**, solid phase (section 8.6).
7. **Time.** The animation input is `GameTime`, a uniform equal to `((gameTime mod 24000) + partialTick) / 24000`, and 0 when the level is not being rendered (section 8.7.3).

### 8.2 Block-side facts

| Item | `end_portal` | `end_gateway` |
|---|---|---|
| Block entity class and type | `TheEndPortalBlockEntity`, `end_portal` | `TheEndGatewayBlockEntity` (extends the portal entity), `end_gateway` |
| Block state file | one variant `""`, model `block/end_portal` | one variant `""`, model `block/end_gateway` |
| Block model | no elements; `textures.particle` = `minecraft:block/obsidian` | same |
| `getRenderShape` | `INVISIBLE` | `INVISIBLE` |
| `getShape` (outline) | box (0, 6, 0)-(16, 12, 16) pixels = (0, 0.375, 0)-(1, 0.75, 1) blocks (`Block.column(16, 6, 12)`: width 16, from y 6 to y 12) | not overridden: the base default, the full cube (0, 0, 0)-(1, 1, 1) (`BlockBehaviour.getShape` returns `Shapes.block()`) |
| Collision | `noCollision()` (no collision box) | `noCollision()` |
| Other registration properties | map colour black, `strength(-1.0, 3600000.0)`, `noLootTable`, push reaction `IMMOVEABLE`, `lightLevel` = a function that returns the constant **15** for every state (the registration lambda is `bipush 15; ireturn`) | the same list, `lightLevel` constant **15** |
| Occlusion | `noCollision()` is called, and `Properties.noCollision()` sets **both** `hasCollision` = false and `canOcclude` = false. `BlockStateBase.initCache` then stores the **empty shape** as the state's occlusion shape (and the empty array for the per-face occlusion shapes) whenever `canOcclude` is false. So the portal has an empty occlusion shape, although its `getShape` is the slab | the same: an **empty occlusion shape** and empty per-face shapes, although `getShape` is the full cube. The gateway is therefore **not** an occluder: neighbours are not culled against it, and it does not hide its neighbours' faces (section 8.5) |
| `getCloneItemStack` | empty | empty |
| `canBeReplaced(state, fluid)` | overridden; the body returns **false** (never replaceable by a fluid; 24 part 4 §6.19 agrees) | overridden; the body returns **false** |
| Entity-inside rule | `getEntityInsideCollisionShape` = `getShape` (the slab); `entityInside` starts the portal transition, 39 | cooldown trigger, 31-5 §4.3 |
| Particles | `animateTick`: one `smoke` particle with a random position over the cell and y offset 0.8 (presentation) | `portal` particles, 31-5 §4.3 |

Pointers only: 39 covers the dimension travel and the transition, 31-5 §4 the gateway block entity (fields, tick, destination), 38 the End.

### 8.3 Which renderer draws, when, and how far

1. **Registration.** `BlockEntityRenderers` maps type `end_portal` to `TheEndPortalRenderer` and `end_gateway` to `TheEndGatewayRenderer` (section 7). The block entity needs the block state to be valid for its type (`BlockEntityType.isValid`), otherwise `tryExtractRenderState` returns nothing.
2. **Extraction path.** `LevelExtractor.extractVisibleBlockEntities` walks the **visible render sections** (the sections that survived the view frustum and occlusion graph), and for each section whose mesh visibility is at least **0.3** (the fade rule of 50 §7.2) takes the block entities that `SectionCompiler.handleBlockEntity` stored in that mesh. The compiler stores every block entity it finds for the section's blocks that `hasBlockEntity`, looked up in the section copy the mesher works on: `RenderRegionCache` builds one `SectionCopy` per section of the region, and each `SectionCopy` holds an **immutable snapshot** (`ImmutableMap.copyOf`) of the whole chunk's block entity map taken when the copy is constructed; `RenderSectionRegion.getBlockEntity` is a plain `Map.get` on that snapshot and never creates a block entity. Only the chunk-packet loader creates one on lookup (mode `IMMEDIATE`). Two consequences: a block with no block entity entry stays undrawn (point 2 of section 8.1), and **a block entity that comes into existence after a section was compiled is not drawn until that section is rebuilt**, so a client that creates the block entity after a block change must mark the section dirty (the snapshot time within the rebuild task was not traced more finely, Open question 20). The second list, `ClientLevel.getGloballyRenderedBlockEntities`, is used only for renderers whose `shouldRenderOffScreen()` is true; neither End renderer overrides it (default false), so **both End blocks are drawn only when their own section is visible**. No bounding-box (`getRenderBoundingBox`) test was found on this path (Open question 24). Consequence for the gateway: its beam disappears when the section holding the gateway block is not visible, however tall the beam is.
3. **Distance.** `BlockEntityRenderer.shouldRender(entity, cameraPos)` is true when the distance from the block's centre (x + 0.5, y + 0.5, z + 0.5) to the camera position is **less than** `getViewDistance()` blocks, a true 3D distance (`Vec3.closerThan`; the strict comparison is inferred from its name, Open question 31). `TheEndPortalRenderer` keeps the interface default **64**; `TheEndGatewayRenderer.getViewDistance()` returns **256**. (The beacon renderer, by contrast, ignores y and uses 16 x the render distance, and is off-screen; it is not used here.)
4. **State extraction per frame.** `AbstractEndPortalRenderer.extractRenderState` first fills the common block entity state (52 §2.3), then clears `facesToShow` and, for every `Direction`, adds it when the **block entity's** `shouldRenderFace(direction)` is true (section 8.5). `TheEndGatewayRenderer` then fills the beam fields (section 8.9). Nothing is cached between frames.
5. **Pose.** The level loop (52 §2.1) translates by (block - camera) in doubles. `TheEndPortalRenderer.submit` then multiplies the pose by the fixed transformation of section 8.4; `TheEndGatewayRenderer.submit` applies none.
6. **Phase and order.** The cube is submitted with `submitCustomGeometry` and render type `endPortal` or `endGateway`. `SubmitNodeCollection` puts a custom-geometry submit whose render type has **no blending** into the `solid` phase, one with blending into `translucentCustomGeometry`, and outline types into `outline`. The End render types have no blending, so the cube is in the **solid phase**. `FeatureRenderDispatcher.renderAllFeatures` executes the phases in this order: solid, translucent, translucent-after-terrain, see-through, always-on-top. Within a phase submits are batched by render type (the render type is the batch key).

### 8.4 Geometry

**Vertex format and topology.** The pipeline binds the format `POSITION` only (three 32-bit floats; no colour, UV, normal, light or overlay) with primitive topology `QUADS`. `AbstractEndPortalRenderer.submitCube` emits, for each face of `facesToShow` in `Direction` ordinal order (**DOWN, UP, NORTH, SOUTH, WEST, EAST**), four vertices transformed by the current pose. The vertex list per face comes from `FaceInfo` applied to the unit cube from (0, 0, 0) to (1, 1, 1):

| Face | Vertex 0 | Vertex 1 | Vertex 2 | Vertex 3 |
|---|---|---|---|---|
| DOWN | (0, 0, 1) | (0, 0, 0) | (1, 0, 0) | (1, 0, 1) |
| UP | (0, 1, 0) | (0, 1, 1) | (1, 1, 1) | (1, 1, 0) |
| NORTH | (1, 1, 0) | (1, 0, 0) | (0, 0, 0) | (0, 1, 0) |
| SOUTH | (0, 1, 1) | (0, 0, 1) | (1, 0, 1) | (1, 1, 1) |
| WEST | (0, 1, 0) | (0, 0, 0) | (0, 0, 1) | (0, 1, 1) |
| EAST | (1, 1, 1) | (1, 0, 1) | (1, 0, 0) | (1, 1, 0) |

(Read from the `FaceInfo` extents: `MIN_X` = 0 and `MAX_X` = 1 for x, likewise y and z.) Every face is **counter-clockwise when seen from outside** (checked with the cross product of the first two edges: outward normals (0, -1, 0), (0, 1, 0), (0, 0, -1), (0, 0, 1), (-1, 0, 0), (1, 0, 0)). There are no normals and no UV in the vertex data.

**End portal transformation** (`TheEndPortalRenderer.TRANSFORMATION`, `BOTTOM` 0.375, `TOP` 0.75): translation (0, 0.375, 0), no rotation, scale (1, 0.375, 1). A unit-cube point (x, y, z) goes to block coordinates (x, 0.375 + 0.375 y, z), so the cube becomes the slab y in [0.375, 0.75]. With `facesToShow` = {DOWN, UP} the portal draws exactly these two quads (block coordinates, relative to the block's minimum corner):

| Face | Vertices in order |
|---|---|
| UP (top, y = 0.75) | (0, 0.75, 0), (0, 0.75, 1), (1, 0.75, 1), (1, 0.75, 0) |
| DOWN (bottom, y = 0.375) | (0, 0.375, 1), (0, 0.375, 0), (1, 0.375, 0), (1, 0.375, 1) |

Back faces are culled (section 8.6): the top is seen only from above (camera y > 0.75 above the cell floor), the bottom only from below; a camera inside the slab sees neither. The slab matches the outline and `getShape` of section 8.2; its **y offset** is 0.375 above the cell floor and its thickness 0.375.

**End gateway.** No transformation: the unit cube, x, y and z from 0 to 1, all six faces eligible.

**Built-in block model path (not the chunk mesh).** `BuiltInBlockModels` also registers for `end_portal` a `special` block model of type `EndCubeSpecialRenderer.Type.PORTAL` with the portal transformation above, and for `end_gateway` the type `GATEWAY` with none. This model is used wherever the game draws a block state through the block model system outside chunk meshing (for example blocks drawn as entities or items; the callers were not traced, Open question 26). `EndCubeSpecialRenderer.submit` draws **all six faces** (`ALL_FACES`) with `endPortal` (PORTAL) or `endGateway` (GATEWAY), without a neighbour test. `AbstractEndPortalRenderer.submitSpecial` takes a fourth, integer argument (`EndCubeSpecialRenderer.submit` passes its last integer parameter): when it is non-zero the six faces are submitted a second time with the render type's `outline()` variant, each vertex carrying UV (0, 0) and that integer as its colour (the outline pass, Open question 33). The chunk mesh path ignores it (render shape `INVISIBLE`).

### 8.5 Which faces are drawn

| Block | Rule (`shouldRenderFace(direction)` of the block entity) |
|---|---|
| `end_portal` (`TheEndPortalBlockEntity`) | true if and only if the direction's axis is Y: **UP and DOWN always**, NORTH, SOUTH, WEST, EAST never. No neighbour is consulted: a block above or below the portal does not hide the faces. |
| `end_gateway` (`TheEndGatewayBlockEntity`, overrides it) | `Block.shouldRenderFace(gateway state, state of the neighbour cell in that direction, direction)`, the same test the chunk mesher applies to ordinary blocks. |

`Block.shouldRenderFace(self, neighbour, d)` as read, in this order (the first rule that applies decides). **Net effect for the gateway:** a face is hidden only when the neighbour's face occlusion shape toward it is the full-block shape constant (rule 1, an identity comparison with `Shapes.block()`) or `skipRendering` is true (never); every other neighbour leaves the face drawn.

1. Let `n` be the neighbour's **occlusion shape of the face toward the gateway** (`neighbour.getFaceOcclusionShape(d.opposite)`). If `n` is the full-block shape constant, the face is **not** drawn. (A full opaque block, such as bedrock, hides it; a neighbour with `canOcclude` false has the empty shape here.)
2. If `self.skipRendering(neighbour, d)`: not drawn. For the gateway this is the base default, **false** (the method was not overridden in `EndGatewayBlock`).
3. If `n` is empty: **drawn** (air, glass, plants, any non-occluding block, and a missing block).
4. Let `m` be the gateway's own occlusion shape of the face (`self.getFaceOcclusionShape(d)`). It is **always empty** (8.2: `noCollision()` cleared `canOcclude`), so this rule always fires: **drawn**.
5. (Unreachable for the gateway: the shape comparison that would follow rule 4 is never reached because rule 4 always returns first.)

Each frame the test reads the client level's block state of the neighbour cell (`level.getBlockState(pos.relative(d))`); a cell in a chunk that is not loaded gives air in the usual client behaviour (inferred, Open question 30). The gateway's `getParticleAmount` counts the faces for which this test is true (31-5 §4.3).

| Neighbour of a gateway | Face toward it |
|---|---|
| air, glass, leaves, plants, any block with an empty occlusion shape | drawn (rule 3) |
| bedrock, stone, any full opaque cube (face shape = the full-block constant) | not drawn (rule 1) |
| slab, stairs, any partial opaque shape | drawn (rule 4: the gateway's own face shape is empty) |
| another gateway | **drawn** (its occlusion shape is empty, rule 3) |
| `end_portal` | **drawn in all six directions** (its occlusion shape is empty, rule 3) |

### 8.6 Render type and pipeline state

`RenderTypes.endPortal()` is the render type named `end_portal` built from the pipeline `RenderPipelines.END_PORTAL` (location `pipeline/end_portal`); `RenderTypes.endGateway()` is named `end_gateway` and uses `END_GATEWAY` (`pipeline/end_gateway`). Both come from one snippet; they differ only in the shader define `PORTAL_LAYERS`.

| Property | Value (read) |
|---|---|
| Vertex shader, fragment shader | `core/rendertype_end_portal` (the same pair for both) |
| Shader define `PORTAL_LAYERS` | **15** for `END_PORTAL`, **16** for `END_GATEWAY` |
| Vertex format | `POSITION` (3 floats) |
| Primitive topology | `QUADS` |
| Textures | `Sampler0` = `textures/environment/end_sky.png`, `Sampler1` = `textures/entity/end_portal/end_portal.png`, for **both** render types (the gateway does not use `end_gateway_beam.png` for its cube) |
| Uniform blocks | `Globals` (`GameTime`), `Projection`, `DynamicTransforms` (model-view matrix), `Fog` |
| Blend | **none** (the colour target state has no blend function; the shader's alpha 1 overwrites) |
| Colour target | RGBA8 unorm, write mask 15 (red, green, blue and alpha all written) |
| Depth | test `GREATER_THAN_OR_EQUAL` (reversed-Z, 12 §3.3), depth **write on**; the depth state has only the compare function and the write flag (no bias, no stencil) |
| Cull | **on** (the builder default; the snippet does not change it); polygon mode fill. Winding: faces are counter-clockwise from outside (8.4); the OpenGL backend leaves the front face at its default (counter-clockwise); the Vulkan backend sets `VK_FRONT_FACE_CLOCKWISE` with back-face culling, which is the same convention under the flipped y of Vulkan clip space (inferred, Open question 14) |
| Light, overlay | not used: `useLightmap` and `useOverlay` are not set on the render setup, the format has no light or colour, the shader has no light-map or overlay lookup |
| Fog | **applied** in the fragment shader (8.7.5) |
| Outline | `AFFECTS_OUTLINE` (the type takes part in the entity outline pass; not read further, Open question 22) |
| Phase | solid (8.3 point 6) |

### 8.7 The portal surface shader

#### 8.7.1 Inputs

The vertex shader outputs `gl_Position = ProjMat * ModelViewMat * Position` and three varyings:

- `texProj0` = (0.5 x + 0.5 w, 0.5 y + 0.5 w, z, w) of the clip-space position (x, y, z, w) (`projection_from_position`). After the perspective divide by w this is the **screen position mapped to 0..1**: `uv0` = (0.5 ndc.x + 0.5, 0.5 ndc.y + 0.5), where ndc is the normalised device position of the pixel. (The fragment shader reads these as a projective coordinate, `textureProj`: it divides the first two components by the fourth.)
- `sphericalVertexDistance` = length(Position) and `cylindricalVertexDistance` = max(length(Position.xz), |Position.y|). `Position` is taken to be in camera-relative world coordinates because the CPU applies the pose to every vertex (8.3 point 5), so these would be the distances from the camera (inferred: the contents of the model-view matrix were not read, Open question 32).

So **texture coordinates come from the screen position of each pixel, not from the world position of the surface**: the world position only decides where on the screen the surface lies. A portal seen from a different camera position shows a different part of the pattern; the pattern does not stick to the block. The sign of ndc.y relative to image rows depends on the backend clip space (Open question 15).

#### 8.7.2 Per-layer coordinate

For layer number L = 1 to N (N = `PORTAL_LAYERS`; the shader's loop index is L - 1), the coordinate used to read the `end_portal` texture is obtained from the screen coordinate `uv0` of 8.7.1 in this order: rotate and scale about the origin, then translate, then halve and add 0.25. The closed forms are:

| Quantity | Closed form |
|---|---|
| k(L), scale factor | 9 - L / 2 |
| theta(L), rotation in degrees | 8642 L^2 + 18 L (reduced modulo 360 for use; table below) |
| t(L), translation | (17 / L, (3 + L) * GameTime) |

R(theta) is the counter-clockwise rotation (x, y) -> (x cos theta - y sin theta, x sin theta + y cos theta). The values are not clamped: coordinates far outside 0..1 wrap (8.8).

Combined: **UV(L) = (4.5 - L/4) * R(theta(L)) * (u0, v0) + (8.5 / L + 0.25, 0.5 * (3 + L) * GameTime + 0.25)**, with (u0, v0) = `uv0` (the scale is k / 2, the offset is t / 2 + 0.25).

| L | k = 9 - L/2 | k / 2 | theta mod 360 (deg) | t.x = 17/L | x offset 8.5/L + 0.25 | tint R | tint G | tint B |
|---|---|---|---|---|---|---|---|---|
| 1 | 8.5 | 4.2500 | 20 | 17.000000 | 8.750000 | 0.022087 | 0.098399 | 0.110818 |
| 2 | 8.0 | 4.0000 | 44 | 8.500000 | 4.500000 | 0.011892 | 0.095924 | 0.089485 |
| 3 | 7.5 | 3.7500 | 72 | 5.666667 | 3.083333 | 0.027636 | 0.101689 | 0.100326 |
| 4 | 7.0 | 3.5000 | 104 | 4.250000 | 2.375000 | 0.046564 | 0.109883 | 0.114838 |
| 5 | 6.5 | 3.2500 | 140 | 3.400000 | 1.950000 | 0.064901 | 0.117696 | 0.097189 |
| 6 | 6.0 | 3.0000 | 180 | 2.833333 | 1.666667 | 0.063761 | 0.086895 | 0.123646 |
| 7 | 5.5 | 2.7500 | 224 | 2.428571 | 1.464286 | 0.084817 | 0.111994 | 0.166380 |
| 8 | 5.0 | 2.5000 | 272 | 2.125000 | 1.312500 | 0.097489 | 0.154120 | 0.091064 |
| 9 | 4.5 | 2.2500 | 324 | 1.888889 | 1.194444 | 0.106152 | 0.131144 | 0.195191 |
| 10 | 4.0 | 2.0000 | 20 | 1.700000 | 1.100000 | 0.097721 | 0.110188 | 0.187229 |
| 11 | 3.5 | 1.7500 | 80 | 1.545455 | 1.022727 | 0.133516 | 0.138278 | 0.148582 |
| 12 | 3.0 | 1.5000 | 144 | 1.416667 | 0.958333 | 0.070006 | 0.243332 | 0.235792 |
| 13 | 2.5 | 1.2500 | 212 | 1.307692 | 0.903846 | 0.196766 | 0.142899 | 0.214696 |
| 14 | 2.0 | 1.0000 | 284 | 1.214286 | 0.857143 | 0.047281 | 0.315338 | 0.321970 |
| 15 | 1.5 | 0.7500 | 0 | 1.133333 | 0.816667 | 0.204675 | 0.390010 | 0.302066 |
| 16 (gateway only) | 1.0 | 0.5000 | 80 | 1.062500 | 0.781250 | 0.080955 | 0.314821 | 0.661491 |

The 16 tints are the shader's constant array `COLORS[0..15]`: layer L uses `COLORS[L - 1]`, and the sky term uses `COLORS[0]`. The portal (N = 15) never reads `COLORS[15]`. The y translation per tick (in UV units after the final halving) is 0.5 * (3 + L) / 24000 = (1.5 + 0.5 L) / 24000, so layer 1 moves 8.3e-5 and layer 16 moves 3.96e-4 of a texture repeat per tick (all in the +v direction of the coordinate).

#### 8.7.3 Time source

`GameTime` is a member of the `Globals` uniform block, written each frame by `GlobalSettingsUniform.update` from `GameRenderer`: `GameTime = (float)((levelRenderState.gameTime mod 24000) + worldPartialTicks) / 24000.0`. `levelRenderState.gameTime` is `ClientLevel.getGameTime()` (the level game time of 33; not the day time), set at extraction (`LevelExtractor.extract`); `worldPartialTicks` is the frame's partial tick (0 to 1, fractional part of the tick, **included**). When the game is not rendering the level (`shouldRenderLevel` false, for example on the loading screens) both terms are 0 and `GameTime` = 0 (inferred as the loading screen's value; Open question 27). Units: fraction of a 24000-tick day, so t.y of 8.7.2 grows by (3 + L) / 24000 per tick. `GameTime` jumps back to 0 when `gameTime mod 24000` wraps (every 20 minutes of game time), which makes the scroll jump once. The jump of layer L is (3 + L) / 2 UV units in the final coordinate (a drop of `GameTime` from just below 1 to 0): for odd L this is almost exactly a whole number of texture repeats (no visible change), for even L it is a half-integer, so the even layers visibly pop (consequence of the formulas; no smoothing was found).

#### 8.7.4 Combination

With `T0(uv)` the RGB (0..1) of `end_sky.png` and `T1(uv)` that of `end_portal.png` (texel fetch, 8.8):

**colour = T0(uv0) * COLORS[0] + sum over L = 1..N of T1(UV(L)) * COLORS[L - 1]**, component-wise, N = 15 (portal) or 16 (gateway).

The sky term uses the **unrotated** screen coordinate `uv0` once, so the end-sky image is stretched over the whole screen (it does not repeat or move). The `end_portal` image supplies all the moving layers. The alpha of both textures is ignored; the output alpha is 1.0.

#### 8.7.5 Fog and output

After the sum, `apply_fog` is called with colour (rgb, 1.0), the two distances of 8.7.1, and the `Fog` uniform members (`FogEnvironmentalStart`, `FogEnvironmentalEnd`, `FogRenderDistanceStart`, `FogRenderDistanceEnd`, `FogColor`; values per frame from 12 §3.3):

- `linear(d, s, e)` = 0 if d <= s; 1 if d >= e; else (d - s) / (e - s);
- `fogValue` = max(`linear`(spherical, EnvironmentalStart, EnvironmentalEnd), `linear`(cylindrical, RenderDistanceStart, RenderDistanceEnd));
- output rgb = mix(colour, `FogColor`.rgb, `fogValue` * `FogColor`.a) = colour + (`FogColor`.rgb - colour) * (`fogValue` * `FogColor`.a); output alpha = 1.0 (the input alpha is kept).

The fragment colour is written to an RGBA8 unorm target: each channel is **clamped to 0..1** and rounded to the nearest of 255 steps by the hardware (the sum can exceed 1: with every texel at 255 the layer sums are 1.275, 2.348, 2.499 for 15 layers and 1.356, 2.663, 3.161 for 16 layers, plus the sky term; for real textures it rarely does, section 8.8). No gamma conversion is applied by the shader.

#### 8.7.6 Worked example (portal block, one pixel)

Setup: the shader depends only on the pixel's screen coordinate `uv0` and on `GameTime`, so the example takes an **arbitrary screen position that the portal is assumed to cover**: ndc = (0.05, 0.725), giving `uv0` = (0.525, 0.8625). No camera pose is given and none is implied: a 1 x 1 slab seen from a few blocks away covers only part of the screen, and the pixel is chosen to exercise the arithmetic, not to lie on a particular slab. Level game time 1000, partial tick 0.5, so `GameTime` = 1000.5 / 24000 = **0.0416875**. The pipeline is `END_PORTAL` (N = 15). Fog value 0 (distance below the fog start). The arithmetic is exact: the angle is reduced modulo 360 degrees and sine and cosine are taken in double precision. The GPU's 32-bit arithmetic gives slightly different coordinates (Open question 16).

Sky term: texel = (floor(0.525 x 128), floor(0.8625 x 128)) = (67, 110) of `end_sky.png`, pixel value (94, 68, 131). Contribution = (94, 68, 131) / 255 x `COLORS[0]` (0.022087, 0.098399, 0.110818) = (0.008142, 0.026240, 0.056930).

Layers (texel = floor(UV x 256) mod 256 in `end_portal.png`; the value is the grey level read, used for red, green and blue alike):

| L | UV (u, v) | texel (x, y) | value |
|---|---|---|---|
| 1 | (9.592972, 4.541068) | (151, 138) | 0 |
| 2 | (3.614042, 4.294724) | (157, 75) | 0 |
| 3 | (0.615637, 3.246932) | (157, 63) | **4** |
| 4 | (-0.998612, 1.448523) | (0, 114) | 0 |
| 5 | (-1.158877, -0.633812) | (215, 93) | **1** |
| 6 | (0.091667, -2.149906) | (23, 217) | 0 |
| 7 | (2.073382, -2.250660) | (18, 191) | 0 |
| 8 | (3.513242, -0.757167) | (131, 62) | 0 |
| 9 | (3.290767, 1.375802) | (74, 96) | 0 |
| 10 | (1.496693, 2.501060) | (127, 128) | 0 |
| 11 | (-0.304178, 1.708705) | (178, 181) | 0 |
| 12 | (-0.439215, -0.021129) | (143, 250) | 0 |
| 13 | (0.918634, -0.678561) | (235, 82) | **4** |
| 14 | (1.821032, 0.303596) | (210, 77) | 0 |
| 15 | (1.210417, 1.272063) | (53, 69) | 0 |

Check of one coordinate, layer 1: k / 2 = 4.25, theta = 20 degrees, R(20 degrees) (0.525, 0.8625) = (0.525 x 0.939693 - 0.8625 x 0.342020, 0.525 x 0.342020 + 0.8625 x 0.939693) = (0.198346, 0.990045); times 4.25 = (0.842971, 4.207693); plus (8.75, 0.25 + 0.5 x 4 x 0.0416875 = 0.333375) = (9.592971, 4.541068). ✓ (the table row).

Non-zero layers: L3 = 4/255 x (0.027636, 0.101689, 0.100326) = (0.000434, 0.001595, 0.001574); L5 = 1/255 x (0.064901, 0.117696, 0.097189) = (0.000255, 0.000462, 0.000381); L13 = 4/255 x (0.196766, 0.142899, 0.214696) = (0.003086, 0.002242, 0.003368). Total = sky + L3 + L5 + L13 = (0.011917, 0.030539, 0.062253). Times 255 = (3.04, 7.79, 15.88); rounded to nearest: **(3, 8, 16)**, alpha **255**, no clamping needed.

Clamp case: with every sampled `end_portal` texel at 255 the 15-layer sum of the blue channel is 2.499272, so blue clamps to 255. At the other extreme, all texels 0 and the darkest sky texel (15, 11, 20) give (15, 11, 20) x `COLORS[0]` = (0.33, 1.08, 2.22) in 0..255 units, which rounds to (0, 1, 2).

### 8.8 Textures and sampler

| Texture | File in the jar | Format and size | Content summary |
|---|---|---|---|
| Sampler0, sky | `assets/minecraft/textures/environment/end_sky.png` | PNG, 8-bit palette (colour type 3), **128 x 128**, every pixel alpha 255 | the End sky; per-channel maxima 224, 216, 235; mean colour (115.3, 87.7, 155.8) |
| Sampler1, portal | `assets/minecraft/textures/entity/end_portal/end_portal.png` | PNG, 8-bit **greyscale** (colour type 0), **256 x 256** | stars on black: 7890 of 65536 texels are non-zero (12.0 %), 80 texels are 255, mean 2.858; the first 255 texel in row-major order is (x 17, y 1) |

(The Faithful pack mapping lists a 256 x 256 `end_sky` for the pack; the jar's own file is 128 x 128, and every sampling computation must use the size of the texture actually bound.) Neither file has a `.mcmeta` in the jar.

**Sampler.** `RenderSetup.withTexture` binds each texture with no explicit sampler, so the texture's own sampler is used. `TextureManager.getTexture` supplies these textures (the loader class used for an identifier that is not pre-registered was not opened and is inferred to be the plain `SimpleTexture` with `TextureContents.load`, Open question 18); a reloadable texture chooses its sampler in `ReloadableTexture.setSampler`: address mode **repeat** on both axes (clamp only when the `.mcmeta` `texture.clamp` is true), filter **nearest** for minification and magnification (linear only when `texture.blur` is true), and a fifth sampler-request argument that is false (its meaning, anisotropy or mipmapping, was not decoded). Both flags default to false, so with the jar files: **nearest filtering, repeat wrapping, one mip level** (`createTexture` is called with a mip level count of 1; no mipmaps are generated). A texel is selected as `floor(UV * size) mod size` per axis (mathematical modulo, so negative coordinates wrap). Texel values are read as unsigned normalised bytes, value / 255, in a format named `RGBA8_UNORM`; no sRGB decode is applied by the sampler. Which image row is v = 0 follows the upload order of `NativeImage` (row 0 first; inferred, Open question 15). A resource pack that supplies a `.mcmeta` with `blur` or `clamp` changes the sampling of both textures.

### 8.9 The end gateway beam

**Block entity fields.** `age` (long, ticks since placement, saved as `Age`), `teleportCooldown` (int, client and server); constants `SPAWN_TIME` = 200, `COOLDOWN_TIME` = 40 (31-5 §4.2 and §4.3 give the tick, the block event 1 that sets `teleportCooldown` to 40 on clients, and the update tag that carries `Age`). Client tick (`beamAnimationTick`): `age += 1`, and `teleportCooldown -= 1` while it is above 0. `isSpawning` = age < 200; `isCoolingDown` = teleportCooldown > 0.

**Per frame (`TheEndGatewayRenderer.extractRenderState`).** If `isSpawning`, or (`isCoolingDown` and the block entity has a level), compute the beam; otherwise `height` = 0 and no beam is submitted.

| Field | Value |
|---|---|
| `scale0` | spawning: `getSpawnPercent(partial)` = clamp((age + partial) / 200, 0, 1); cooling: `getCooldownPercent(partial)` = 1 - clamp((teleportCooldown - partial) / 40, 0, 1) |
| `maxY` | spawning: `level.getMaxY()` (the highest block y of the dimension; 255 in the End, whose `min_y` is 0 and `height` 256, 38; `Level.getMaxY` itself was not read, Open question 25); cooling: **50.0** |
| `scale` (render state field) | `Mth.sin(scale0 * pi)` (the table sine of 10 §16.3), a hump from 0 to 1 to 0 |
| `height` | floor(`scale` * `maxY`), an int |
| `color` | spawning: `DyeColor.MAGENTA.getTextureDiffuseColor()` = **0xFFC74EBD**; cooling: `DyeColor.PURPLE...` = **0xFF8932B8** (opaque ARGB: `ARGB.opaque` of 13061821 and 8991416) |
| `animationTime` | level present: `floorMod(gameTime, 40)` + partial (a float in [0, 41)); no level: 0 |

**Submission.** `submit` first calls the beacon beam routine when `height` > 0, then the cube of 8.4 and 8.5 with render type `endGateway`. The call is `BeaconRenderer.submitBeaconBeam(pose, collector, texture, scale, animationTime, yStart, length, color, solidRadius, glowRadius)` with: texture = `textures/entity/end_portal/end_gateway_beam.png` (16 x 16, 8-bit palette, 10 distinct colours, all opaque, light blue-grey; for example texel (0, 0) = (148, 183, 180)); `scale` = the `scale` field above; `yStart` = **-height**; `length` = **2 x height**; `color` as above; `solidRadius` = **0.15**; `glowRadius` = **0.175**. The beam therefore runs from y = -height to y = +height relative to the **gateway block's floor** (y offsets in blocks from the block's minimum corner; the beam also extends below the cell), centred on the block (x and z at 0.5). The beacon itself uses the other overload that has the constants `SOLID_BEAM_RADIUS` 0.2, `BEAM_GLOW_RADIUS` 0.25 multiplied by its scale, the texture `textures/entity/beacon/beacon_beam.png`, `MAX_RENDER_Y` 2048 and `BEAM_SCALE_THRESHOLD` 96; those belong to the beacon renderer (31-5 cites it as not specified); the shared routine below is specified in full.

**The beam routine** (`submitBeaconBeam`, public overload). Let `r` = solidRadius, `g` = glowRadius, `s` = scale, `t` = animationTime, `y0` = yStart, `len` = length, `y1` = y0 + len. For the gateway y1 = +height.

All geometry is relative to the pose translated by (0.5, 0, 0.5) (the column of the block, x and z at its centre). With `f` = -t when `len` >= 0 (always, for the gateway) the texture scroll is `v0` = -1 + frac(0.2 f - floor(0.1 f)), which equals -1 + frac(0.2 f) because the floor term is an integer (`Mth.frac(x)` = x - floor(x)); the texture scrolls once per 5 ticks of `t`. Two prisms are drawn, each as four side quads (no top or bottom cap), u running from 0 to 1 across every side and the texture repeating along v:

| Part | Pose | Corner points in (x, z) and the side quads, in drawing order (A to B) | v at y0 | v at y1 | Vertex colour | Render type |
|---|---|---|---|---|---|---|
| core | rotated about +Y by **2.25 t - 45 degrees** (`Axis.YP.rotationDegrees`) | P1 = (0, r), P2 = (r, 0), P3 = (-r, 0), P4 = (0, -r); quads P1 to P2, P4 to P3, P2 to P4, P3 to P1 | `v0` | `v0 + len * s * (0.5 / r)` (gateway: `v0 + 3.333 * len * s`) | `color`, alpha 255 | `beaconBeam(texture, false)` |
| glow | not rotated (the rotation is popped first) | Q1 = (-g, -g), Q2 = (g, -g), Q3 = (-g, g), Q4 = (g, g); quads Q1 to Q2, Q4 to Q3, Q2 to Q4, Q3 to Q1 | `v0` | `v0 + len * s` (no division by the radius) | `color` with alpha replaced by **32** (`ARGB.color(32, color)`; 32/255 = 0.1255) | `beaconBeam(texture, true)` |

Vertex order of every side quad from A to B, with (u0, u1) = (0, 1):

| Vertex | Position | (u, v) |
|---|---|---|
| 1 | (A.x, y1, A.z) | (u1, v at y1) |
| 2 | (A.x, y0, A.z) | (u1, v at y0) |
| 3 | (B.x, y0, B.z) | (u0, v at y0) |
| 4 | (B.x, y1, B.z) | (u0, v at y1) |

Every vertex also stores overlay `NO_OVERLAY`, light **15728880** (full bright: sky 15, block 15) and the normal (0, 1, 0), but the beam shader reads only position, colour and UV0.

Winding: seen from outside, the glow quads are **clockwise** and the core quads **counter-clockwise** (computed from the vertex orders; the corner order of the glow runs clockwise seen from above). With back-face culling (both beam pipelines use the default cull), the core is visible from outside and the glow shell shows its far, inner walls from outside (inferred from the winding and the front-face convention of 8.6, Open question 14).

**Beam render types** (`RenderTypes.beaconBeam`, name `beacon_beam`, both with `sortOnUpload`, `Sampler0` = the texture, texture sampler as in 8.8, so nearest and repeat):

| Pass | Pipeline | Format | Blend | Depth | Phase |
|---|---|---|---|---|---|
| core | `BEACON_BEAM_OPAQUE` (`pipeline/beacon_beam_opaque`) | `BLOCK` (shader reads position, colour, UV0) | none, RGBA write | `GREATER_THAN_OR_EQUAL`, write on | solid |
| glow | `BEACON_BEAM_TRANSLUCENT` (`pipeline/beacon_beam_translucent`) | `BLOCK` | colour: source factor SRC_ALPHA, destination ONE_MINUS_SRC_ALPHA; alpha: source ONE, destination ONE_MINUS_SRC_ALPHA | `GREATER_THAN_OR_EQUAL`, write **off** | `translucentCustomGeometry` (the type has blending); with the improved-transparency option the OIT pipeline set `beacon_beam` replaces it (not read further, Open question 21) |

**Beam fragment shader.** colour = `Sampler0`(uv) * vertexColor * `ColorModulator` (a `DynamicTransforms` uniform, assumed (1, 1, 1, 1), Open question 19), then fog with `fragmentDistance` = 1 / `gl_FragCoord.w` (the eye-space depth) used for both distances in the same `apply_fog` of 8.7.5. No light map is used. The core's alpha is 1 times the texture alpha (255); the glow's alpha is 32/255 times the texture alpha.

**Worked example (spawn).** age = 60, partial = 0.25, level game time 1003, End level: `scale0` = (60 + 0.25) / 200 = 0.30125; `scale` = sin(0.30125 pi) = 0.81132; `maxY` 255; `height` = floor(0.81132 x 255 = 206.88) = **206**; `color` 0xFFC74EBD; `animationTime` = floorMod(1003, 40) + 0.25 = 3.25. The beam spans y from -206 to +206 around the block floor (len = 412); core rotation 2.25 x 3.25 - 45 = -37.6875 degrees; f = -3.25, `v0` = -1 + frac(-0.65 - floor(-0.325)) = -1 + frac(0.35) = **-0.65**; core v at the top = -0.65 + 412 x 0.81132 x 3.3333 = **1113.56**; glow v at the top = -0.65 + 412 x 0.81132 = 333.61; core colour (199, 78, 189, 255); glow colour (199, 78, 189, alpha 32). (`Mth.sin` is a table sine: the fifth decimal can differ.) **Cooling:** `teleportCooldown` = 20, partial 0.5: `scale0` = 1 - clamp(19.5 / 40) = 0.5125; `scale` = sin(0.5125 pi) = 0.99923; `height` = floor(50 x 0.99923 = 49.96) = **49**; colour purple 0xFF8932B8 (137, 50, 184).

### 8.10 How the portal and the gateway relate

- **Shared:** the renderer base class, the face-list submit routine, the shader pair, the two textures, the `Fog`, `Globals` and `Projection` uniforms, the pipeline snippet. Different: layer count (15 against 16, hence the extra tint `COLORS[15]`), the pose transformation (squash against none), the face rule (Y axis only against neighbour test), the view distance (64 against 256), and the beam (gateway only).
- **No interaction.** Each block entity is drawn on its own; a portal next to a gateway has no effect on the gateway's face test (the portal's occlusion shape is empty, so the gateway's face toward it is drawn, 8.5) and matters only through the beam, which overlaps any block in its column. The portal's top is not hidden by the gateway's glow or core (the glow is translucent with depth write off; the core writes depth).
- **Level-loading screen.** `LevelLoadingScreen` draws the End-portal background with the **same `END_PORTAL` pipeline** (15 layers, both textures with their own samplers), as one `fill` of the rectangle (0, 0, width, height) of the screen in GUI coordinates (50 §2.4). The shader maths is the same with the screen as the projected surface: `uv0` is the position on the screen. `GameTime` there is the uniform of 8.7.3 (0 while the level is not rendered). `WinScreen` (the credits) references the same two texture constants (its pipeline use was not confirmed).

### 8.11 What a minimal client may approximate (design choice, not vanilla)

- **Must keep:** create the block entity from the chunk list (8.1 point 2), draw the top face at y = 0.75 (and the bottom face at 0.375 if the camera can go below), with depth write, so the portal occludes what is behind it. A cell with no drawing is the bug of task T46004.
- **May simplify (a design choice):** replace the 16 or 17 texture fetches with a flat colour or a small fixed pattern. The expected value of the true output, taken as the mean of the two images times the tints (the mean texel of `end_portal.png` 2.858 / 255, the mean of `end_sky.png`), is about **RGB (6, 15, 24)** for the portal and **(6, 16, 26)** for the gateway: a very dark teal. Real pixels are dominated by 0 texels and scattered brighter stars (8.8). Any flat approximation near these numbers is far darker than a typical "portal" art guess; the vanilla look is dark with sparse speckles.
- **May skip:** fog (a small error), the outline pass, the `special` block model path.
- **Gateway:** may omit the glow (a thin translucent shell) and keep the core; the beam must still stop at `height` 0 when neither spawning nor cooling down. The gateway cube may reuse the portal approximation.
- **Do not:** treat the portal as a full cube or draw its side faces; use the cell position for texture coordinates when implementing the vanilla look (the vanilla pattern follows the screen).

### 8.12 Implementer summary

| Item | Value |
|---|---|
| Block entity type ids | `end_portal` 14, `end_gateway` 22 (chunk packet block entity list, empty tag; gateway `Age`) |
| Portal slab | x, z 0..1; y 0.375..0.75; faces UP and DOWN only |
| Gateway cube | 0..1 in all axes; faces by `Block.shouldRenderFace`; beam while spawning (age < 200) or cooling (cooldown > 0) |
| Vertex order, winding | per 8.4 table; counter-clockwise from outside; back faces culled |
| View distance | portal 64 blocks, gateway 256 blocks, 3D distance block centre to camera, strict less-than; needs the section visible (mesh visibility >= 0.3) |
| Layers | portal 15, gateway 16; sky term uses `COLORS[0]` and the screen coordinate `uv0` |
| Layer coordinate | UV(L) = (4.5 - L/4) R(theta(L)) uv0 + (8.5/L + 0.25, 0.5 (3 + L) GameTime + 0.25); theta(L) = 8642 L^2 + 18 L degrees |
| Tint table | 8.7.2 (16 rows) |
| `GameTime` | ((gameTime mod 24000) + partial) / 24000; 0 when the level is not rendered |
| Textures | sky 128 x 128 palette; portal 256 x 256 greyscale; nearest, repeat, 1 mip level |
| Output | rgb sum clamped to 0..1, fog by `apply_fog`, alpha 1; no blend; depth GE and write on; colour mask RGBA |
| Beam | y from -h to +h, h = floor(sin(pi p) x (maxY or 50)); core radius 0.15, glow radius 0.175; core colour 0xFFC74EBD (spawn) or 0xFF8932B8 (cooldown), glow alpha 32; rotation 2.25 t - 45 degrees; t = floorMod(gameTime, 40) + partial; v scroll frac(-0.2 t); core v length 3.333 len s, glow v length len s |
| Beam textures and types | `end_gateway_beam.png` (16 x 16); opaque pipeline for the core, translucent (SRC_ALPHA, ONE_MINUS_SRC_ALPHA; alpha ONE, ONE_MINUS_SRC_ALPHA; no depth write) for the glow |

### 8.13 Validation (checkable facts)

| # | Check |
|---|---|
| E1 | A world with an `end_portal` block whose chunk packet lists no block entity for it shows no portal; with the entry (type 14, empty tag) the top face appears at y + 0.75 |
| E2 | The portal quad corners at cell (0, 64, 0) are (0, 64.75, 0), (0, 64.75, 1), (1, 64.75, 1), (1, 64.75, 0) in the order of 8.4, and the bottom ones at y 64.375 |
| E3 | No side face of the portal is drawn at any camera position; the top face is invisible from below and the bottom face invisible from above |
| E4 | With the camera at distance 63.9 blocks from the block centre the portal is drawn; at 64.1 it is not; for the gateway the limits are 255.9 and 256.1 |
| E5 | A gateway with a stone block on all six sides draws no face of the cube; with air above it the UP face is drawn |
| E6 | At `GameTime` = 0 the layer-1 coordinate of the screen point uv0 = (0.5, 0.5) is 4.25 R(20 degrees) (0.5, 0.5) + (8.75, 0.25) = (8.75 + 4.25 x 0.5 (cos 20 - sin 20), 0.25 + 4.25 x 0.5 (sin 20 + cos 20)) = (10.0201, 2.9736) |
| E7 | Section 8.7.2: theta(15) mod 360 = 0 and theta(16) mod 360 = 80; k(16) = 1; `COLORS[15]` = (0.080955, 0.314821, 0.661491) is read only by the gateway |
| E8 | The worked example of 8.7.6 gives (3, 8, 16, 255) (exact arithmetic; a 32-bit GPU may give (2, 7, 15), Open question 16) |
| E9 | Gateway beam: age 60, partial 0.25: height 206; cooldown 20, partial 0.5: height 49; at age >= 200 with no cooldown no beam |
| E10 | The glow's fragment alpha is 32/255 times the beam texture alpha; the core is opaque |

## 9. Open questions

1. **Chest artwork orientation.** The chest path applies no y or z flip (section 2.2), so by 34-1 §1.3 the cuboid's `DOWN` rectangle (the "top" rectangle of the standard strip) lands on the geometric bottom of each box and the `SOUTH` rectangle (not `NORTH`) on the front of the lock. Whether the 64 x 64 chest textures are authored for that orientation was not checked (pixels were not read). An implementer should render once and compare with a reference screenshot; if the lid top shows the wrong rectangle, exchange `DOWN` and `UP` rectangles and the front/back lock rectangles.

   *Implementation finding (a rendering check by the implementer, not read from the artifact):* with the spec'd unwrap applied to a y-up model the side faces came out upside down and the lid top showed the wrong rectangle. The client therefore builds the cuboid corners with the two ends of y exchanged (the standard unwrap as for a y-down model: the table's `DOWN` rectangle on the top face, `UP` on the bottom, side faces upright), which gave upright artwork with the lid top, the latch and the bottom edge in their natural places (client `models-chest.cob`, T5001). The no-flip statement of 2.2 is thus likely to describe the model before an unrecorded flip; it remains open until the artifact is read for it.
2. The `LightCoordsUtil$BrightnessGetter.DEFAULT` (the packed brightness of a cell) was not read; assumed to combine the cell's block light and sky light (and the dimension's ambient rules). The light of a block that is not transparent (a chest is not a full cube) is taken at the chest's own cell.
3. `ItemTransform$Deserializer` multiplies translations by 0.0625 and clamps to ±5 and clamps scales to ±4; the order of multiplication and clamp for translation was not decoded (no value in the tables here is near a clamp).
4. `gui_light` / block-light usage of the item base models `template_chest` and `template_shulker_box` (neither has the key) was not traced; the default of `ModelRenderProperties.usesBlockLight` was not read. `template_banner` sets `gui_light` = `front`.
5. Banner: whether `getTextureDiffuseColor` is applied as RGB with full alpha; the default attachment type of the banner special model (no item definition sets it); whether the `bannerPattern` render type is cutout or translucent; the ordering `order(n)` used between layers (the base layers draw first, patterns after) was only read as call sequence.
6. `ChestBlock` and `CopperChestBlock` weathering: the copper material is read from `CopperChestBlock.getState()`; that the four waxed blocks are instances of the same class (so that waxing leaves the texture unchanged) is inferred from the item definitions and from 31-1 (not read in this round).
7. `BlockEntityRenderer.shouldRender` (the draw distance of block entities) and frustum culling for the chest, shulker box and banner renderers were not read. For the End portal and gateway renderers the draw distance is read (64 and 256 blocks, 8.3 point 3); the frustum and bounding-box part is open for all renderers (Open question 24).
8. The item definitions `waxed_exposed_copper_chest` and `waxed_weathered_copper_chest` were not opened; inferred from the pattern of the other six.
9. `BedRenderState` exists in the artifact; no registered renderer constructs it (the registration table lists none). It may be a leftover. A bed block entity type is absent from `BlockEntityTypes`, so any bed NBT seen in saves (document 31 or 45) has no client counterpart.
10. `Direction.getRotation` uses `rotationXYZ`; its order (Rx·Ry·Rz) is inferred from the property that the image of +Y matches each direction.
11. The rotation sense of the shulker lid in world space (4.4) is inferred from the S(1, −1, −1) flip; the sense of the flag tilt (6.5) is the sense of a model-space X rotation under the flip of 6.2.
12. The bed's `part` and `facing` partner geometry (head cell at foot cell + facing) is inferred from the model and item composites; the placement rules are in the block documents.
13. Whether the chest atlas stitches the textures with a different internal size than the file size (all files are 64 x 64) is not read; the model divides by the layer's 64 x 64.

Questions 14 to 33 belong to section 8 (End portal and End gateway).

14. **Front-face convention.** The faces are counter-clockwise from outside (read) and culling is on (read). The Vulkan backend sets front face clockwise with back-face culling (read); the OpenGL backend was searched for a front-face call and none was found, so the default (counter-clockwise) is assumed. The consequence for the gateway glow (only its far inner walls show from outside) rests on this (8.9, the winding paragraph).
15. **Orientation of the screen coordinate.** Which image row is v = 0 (row 0 of the PNG first, as `NativeImage` uploads) and the sign of ndc.y in the Vulkan clip space were not traced. The effect is a vertical flip of a noise pattern, not observable; the worked example of 8.7.6 assumes row 0 = v 0.
16. **32-bit precision.** The shader works in 32-bit floats with angles up to 2.2 million degrees (L = 16) converted to radians before `cos` and `sin`; the 32-bit angle error is about 0.004 radian, shifting the layer coordinate by up to about 2 texels of the 256 texture in the largest layers. The documented example uses exact angle reduction; an emulation of 32-bit arithmetic gave (2, 7, 15) instead of (3, 8, 16) for that pixel (one texel in layer 13 moved). A client may reduce the angle exactly (the result is the mathematically intended one) or reproduce the 32-bit loss; neither is observable.
17. (Closed.) The `lightLevel` lambdas of both blocks were read: each returns the constant 15 for every state (8.2); this agrees with 24 part 4 §6.19 (variant list V8) and 24 part 6 §6.9.
18. **Texture loading.** The class that loads `end_sky.png` and `end_portal.png` for an identifier that is not pre-registered (inferred `SimpleTexture`), whether palette PNGs are expanded to RGBA with no colour conversion (`NativeImage` was not opened), and whether the sampler returns raw values (the format is RGBA8 unorm; no sRGB format was seen) were not traced.
19. **`ColorModulator`.** The default of the `DynamicTransforms` uniform used by the beam shader is assumed (1, 1, 1, 1); not read.
20. **All-invisible sections and snapshot timing.** Whether a section whose blocks are all invisible (a portal-only section, in the End mostly air) still yields a visible `SectionMesh` that carries its block entities (the extraction needs mesh visibility >= 0.3; the same gap as 50 Open question 3), and the exact moment within a rebuild at which `RenderRegionCache` constructs the `SectionCopy` snapshot, were not traced. (That the mesher's block-entity lookup is a non-creating map get on an immutable snapshot was read, 8.3 point 2.)
21. **Improved transparency.** The OIT pipeline sets (`OIT_BEACON_BEAM`) that replace the translucent glow pipeline when the improved-transparency option is on were not read.
22. **Outline pass.** The portal render types have `AFFECTS_OUTLINE`; the effect on the spectator and glowing outline passes was not read.
23. (Closed.) Both `canBeReplaced` bodies were read: each returns false (8.2).
24. **Bounding box.** No call of `getRenderBoundingBox` was found in `LevelExtractor`, `BlockEntityRenderDispatcher` or `LevelRenderer`; the visibility of a block entity rests on its section's visibility and on `shouldRender` (distance). Other callers were not searched.
25. **`Level.getMaxY` in the End.** The body was not read; 255 is the value implied by `min_y` 0 and `height` 256 (38).
26. **Built-in block models of the End blocks.** `BuiltInBlockModels` gives `end_portal` and `end_gateway` a special block model drawing all six faces; which game paths draw block states through it (falling blocks, displays, pistons, items) was not traced.
27. **`GameTime` on screens.** That the uniform is 0 whenever the level is not rendered (loading screens) follows from the `GameRenderer` code read; whether the loading screen can be shown while the level is rendered behind it was not traced.
28. (Closed.) The gateway calls `Mth.sin(double)` returning float; 10 §16.3 and its call-site table list this overload as the 65536-entry table lookup.
29. (Closed.) The portal's occlusion shape is empty because `noCollision()` clears `canOcclude` (8.2), so its face shapes toward the gateway are empty in every direction and the gateway's face toward a portal is drawn (8.5). The earlier assumption about `Shapes.getFaceShape` is no longer needed.
30. **Unloaded neighbours.** The gateway face test reads the neighbour's block state; the value for a cell in an unloaded chunk (assumed air) was not read.
31. **Distance comparison.** The body of `Vec3.closerThan` (strict less-than assumed) was not read.
32. **Model-view matrix contents.** That `Position` reaches the vertex shader in camera-relative world coordinates (so the fog distances are from the camera) follows from the CPU pose of 8.3 point 5; the `ModelViewMat` uniform (assumed to hold only the camera rotation) was not read.
33. **Outline colour argument.** `submitSpecial`'s integer argument (a non-zero value adds an outline submit with that colour) is passed by `EndCubeSpecialRenderer.submit` from its last parameter; which caller supplies a non-zero value (for example an item or block-display outline) was not traced.
