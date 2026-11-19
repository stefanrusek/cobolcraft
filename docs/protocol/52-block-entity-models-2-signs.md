# Block entity models, part 2: signs and hanging signs

| Item | Value |
|---|---|
| Covers | How the client draws the 52 sign blocks (13 woods: `<wood>_sign`, `<wood>_wall_sign`, `<wood>_hanging_sign`, `<wood>_wall_hanging_sign`): the two layers (the sign board as an ordinary block model in the chunk mesh, the text as a block entity renderer), the renderer classes and render states, the per-frame flow that concerns signs, the block models, textures and per-rotation transforms of the boards (cuboids, texture sizes, atlas, all 13 woods including bamboo, the attached ceiling hanging sign), the text plane transform of each of the four families (scale, translations, depth offset, rotations, back side, pose order, axes, the y flip), the line layout (line spacing, vertical and horizontal centring, wrapping, which lines are drawn), the glow outline and the colour rules, light, shadow, render types and draw phase, the distance and culling rules, the font, the facing-to-rotation mapping and hit-box centres (answering open question 18 of 31-3), worked numeric examples, and the item form. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in the README; protocol 777) |
| Method | Static reading of the shipped bytecode (`javap`), with no execution. `javap -c -p -constants` for classes; `unzip -p` for the JSON data files (block states, block models, item definitions, font definitions, the text shader). Texture pixel sizes were read from the PNG headers. The one image whose pixels were read is the default font page `textures/font/ascii.png` (decoded offline, to get the glyph advances of the worked examples). |
| Classes read | Renderers and states: `net.minecraft.client.renderer.blockentity.AbstractSignRenderer`, `StandingSignRenderer`, `HangingSignRenderer`, `WallAndGroundTransformations`, `BlockEntityRenderDispatcher`, `BlockEntityRenderer`, `BlockEntityRenderers`, `state.SignRenderState` (with `SignTransformations`), `state.StandingSignRenderState`, `state.HangingSignRenderState`, `state.BlockEntityRenderState`. Frame flow: `net.minecraft.client.renderer.extract.LevelExtractor`, `LevelRenderer` (the submit loop), `chunk.SectionCompiler`, `chunk.CompiledSectionMesh`. Block side: `world.level.block.StandingSignBlock`, `WallSignBlock`, `SignBlock`, `CeilingHangingSignBlock`, `WallHangingSignBlock`, `HangingSignBlock`, `PlainSignBlock`, `state.properties.RotationSegment`, `net.minecraft.util.SegmentedAnglePrecision`, `world.phys.shapes.Shapes`, `com.mojang.math.OctahedralGroup`, `world.level.block.entity.SignText` (`getRenderMessages`), `SignBlockEntity`. Colour: `world.item.DyeColor`, `net.minecraft.util.ARGB`. Text engine: `net.minecraft.client.gui.Font` (with `PreparedTextBuilder`), `net.minecraft.client.StringSplitter` (with `LineBreakFinder`, `WidthLimitedCharSink`), `net.minecraft.client.gui.font.FontSet`, `FontTexture`, `GlyphStitcher`, `GlyphRenderTypes`, `glyphs.BakedSheetGlyph`, `providers.BitmapProvider` (`Definition`, `Glyph`), `com.mojang.blaze3d.font.GlyphBitmap`, `GlyphInfo`, `net.minecraft.client.renderer.SubmitNodeCollection`, `feature.TextFeatureRenderer` (with `GlyphRenderer`, `Content`), `RenderPipelines`, `rendertype.RenderTypes`, `com.mojang.renderpearl.api.pipeline.DepthStencilState`, `world.entity.Entity.distanceToSqr`, `world.phys.Vec3.closerThan`; the editor screens `AbstractSignEditScreen`, `SignEditScreen`, `HangingSignEditScreen` (only to see which transforms they use). Data: `assets/minecraft/blockstates/*_sign.json`, `*_wall_sign`, `*_hanging_sign`, `*_wall_hanging_sign`; `models/block/template_*sign*.json` and the per-wood models; `items/*sign.json`, `models/item/*sign.json`; `font/default.json`, `font/include/*.json`; `shaders/core/text.vsh` and `text.fsh`. |
| Round | Clean-room round "signs" (part 2 of the block entity model family; part 1 is 52-1). Sections 1 to 11 are the specification, section 12 the corrections to earlier documents, section 13 the numbered open questions. |
| Related | 12 (client rendering; §5.10 text, which this document confirms), 31-3 §2 and §8 (sign data, dye table), 40-8 §5 and §6 (the sign editor, line metrics 90/10 and 60/9), 34-1 §1.1 and §1.3 (rotation conventions, cuboid unwrap), 52-1 (chests, shulkers, banners; same renderer framework), 51 (block shapes, rule R-C6 to R-C9), 24 part 3 (sign blocks), 14 §10.3 (font files in a pack) |

## 1. Summary and what an implementer needs to know first

1. **A sign is drawn in two independent layers.** The board, post, hanging chains and bracket are an **ordinary block model** (JSON, in the chunk mesh, section 3). The sign block entity renderers (`StandingSignRenderer`, `HangingSignRenderer`) draw **only the text**; they have no model and no texture of their own. Unlike a chest (52-1), nothing of the board comes from an entity model.
2. `StandingSignRenderer` serves **both standing and wall signs** (block entity type `sign`); `HangingSignRenderer` serves **both ceiling and wall hanging signs** (type `hanging_sign`). The attached ceiling hanging sign differs only in its board model (chain geometry, section 3.6); the text transform is identical.
3. **All four families use the same recipe for the text plane**: one pose of the form `translate · rotate-about-vertical-axis · [translate toward the wall] · [turn 180 degrees for the back side] · translate (text offset) · scale (s, −s, s)`. The constants differ per family (section 4). The scale is **1/96 block per font pixel for standing and wall signs and 0.0140625 (= 9/640) block per font pixel for hanging signs**.
4. The **back side is not mirrored**: it is the front recipe with an extra rotation of 180 degrees about the vertical axis applied before the text offset, so the text reads left to right for a viewer standing on the back side.
5. The text plane stands a hair in front of the board face: **0.08 pixel** (0.005 block) for standing and wall signs and **0.168 pixel** (0.0105 block) for hanging signs. The front and back planes are mirror images about the board's centre plane (offset 0.74667 px from it for signs, 1.168 px for hanging signs); there is no per-side asymmetry.
6. **Font space is y down; the pose flips y** (scale −s), so font +y is world −y. Font +x is the reading direction. Block space is the block-min-corner space of 52-1 §2.1 (x east, y up, z south; right-handed).
7. **Line layout:** four lines, each split to the sign's width limit (90 or 60), only the first piece drawn, drawn at font y = `i × lineHeight − (4 × lineHeight) / 2` (integer division) and centred on its own width with the x origin `−width / 2` (integer division truncating toward zero).
8. **Colours:** the dye text colour (31-3 §8) is **opaque (alpha 0xFF)**. Non-glowing text is drawn in the **dye colour scaled by 0.4** (so white text is `0xFF666666`), with the block's light, no outline, no shadow. Glowing text is drawn in the **unscaled dye colour** at **full-bright light 15728880 (`0xF000F0`)** with an eight-neighbour outline in the 0.4-scaled colour (cream `0xFFF0EBCC` for black). The outline of **black** glowing text is always drawn; the outline of other glowing colours is drawn only when the camera entity's feet position is within 16 blocks of the block centre, or while scoping (section 6.3). 31-3 §2.11 states the black rule the other way round; section 12 corrects it.
9. **Distance:** the text itself has **no 16-block cutoff**. A sign block entity is extracted only if its block centre is within **64 blocks** of the camera (default renderer view distance; the sign renderers do not override it) and its chunk section is visible. The 16-block (squared 256) test applies only to the outline of coloured glowing text (measured from the camera entity's feet position to the block centre; 6.3).
10. There is **no render bounding box and no crosshair or looking-at test** for signs in this version. The `is_waxed` flag does not reach the renderer.
11. The font is the **default font** (`minecraft:default`), unless a line's own style names another font. Text is submitted with display mode **polygon offset**; when an outline exists the outline is drawn first in display mode normal and the fill is drawn second in polygon offset (section 6.4).

## 2. How a sign reaches the screen

### 2.1 Block entity types, blocks and renderers

| Block entity type | Blocks (13 woods: oak, spruce, birch, acacia, cherry, jungle, dark_oak, pale_oak, mangrove, poplar, bamboo, crimson, warped) | Renderer (registered in `BlockEntityRenderers`) | State class |
|---|---|---|---|
| `sign` | `<wood>_sign` (property `rotation` 0 to 15), `<wood>_wall_sign` (property `facing`) | `StandingSignRenderer` | `StandingSignRenderState` |
| `hanging_sign` | `<wood>_hanging_sign` (properties `rotation` 0 to 15, `attached`), `<wood>_wall_hanging_sign` (property `facing`) | `HangingSignRenderer` | `HangingSignRenderState` |

Every block also has `waterlogged`; no renderer or model reads it. The pairing is read from `BlockEntityRenderers`: its static initialiser registers `BlockEntityTypes.SIGN` with the provider of invokedynamic call site #2, whose bootstrap target is the `StandingSignRenderer` constructor, and `HANGING_SIGN` with call site #3, whose target is the `HangingSignRenderer` constructor; the render state classes and the block class tests inside each renderer agree with it.

### 2.2 Render state (`SignRenderState`)

Filled by `extractRenderState` every frame a sign is extracted. Fields: the common fields of `BlockEntityRenderState` (block position, block state, type, `lightCoords` as in 52-1 §2.3, the crumbling overlay which the sign renderers ignore), then:

| Field | Value |
|---|---|
| `frontText`, `backText` | `SignBlockEntity.getText(FRONT)` and `getText(BACK)` (31-3 §2.2); never null |
| `textLineHeight` | `SignBlockEntity.getTextLineHeight()`: 10 for a sign, 9 for a hanging sign (31-3 §2.1) |
| `maxTextLineWidth` | `getMaxTextLineWidth()`: 90 for a sign, 60 for a hanging sign |
| `isTextFilteringEnabled` | `Minecraft.isTextFilteringEnabled()` (31-3 §2.2 `filtering`) |
| `drawOutline` | the "outline visible" test of section 6.3, evaluated for the sign's position at extract time, for every sign (not only glowing ones) |
| `transformations` | a pair (front text pose, back text pose), chosen from a table built once per renderer class (section 2.4); identity until set |
| `attachmentType` (subclasses) | standing: `GROUND` (default) or `WALL`; hanging: `CEILING` (default), `CEILING_MIDDLE` or `WALL`. **Stored but not used by any transform** (the hanging attachment is read by the hanging sign editor only) |

The block entity's `is_waxed`, `allow_op_features` and the editor lock are not fields of the state: **waxing changes nothing in the render**.

### 2.3 Per-frame flow as far as it concerns signs

1. `LevelExtractor.extract` gives the dispatcher the camera position (`BlockEntityRenderDispatcher.prepare`).
2. `extractVisibleBlockEntities`: for every chunk section in the level renderer's visible-section list, take the list of **renderable block entities** of its compiled mesh (every block entity whose block state has a block entity, collected when the section was compiled by `SectionCompiler`). A section is skipped when its list is empty or its fade-in visibility is below **0.3**. For each block entity: if the level's destruction-progress map has an entry for the position, a crumbling overlay is built (ignored by signs); then `tryExtractRenderState(blockEntity, partialTick, crumbling, false)` is called and a non-null result is appended to the frame's list. A second loop handles the "globally rendered" block entities with the flag true (a renderer that returns true from `shouldRenderOffScreen`; the sign renderers do not, so no sign appears there).
3. `tryExtractRenderState` returns nothing (the sign is not drawn this frame) when: (a) there is no renderer for the block entity type; (b) the block entity has no level, or its type does not accept its current block state (`BlockEntityType.isValid`); (c) the renderer's `shouldRenderOffScreen` differs from the flag of the call (always false for signs, matching the first loop); (d) `shouldRender` is false: the renderer default is "the block centre is closer than `getViewDistance()` = **64** to the camera" (`Vec3.closerThan`: squared distance strictly less than 64² = 4096; the sign renderers declare no override). Otherwise a fresh state object is created, and `extractRenderState` fills it (section 2.2).
4. Submit stage (`LevelRenderer`): for every state in the list: push the pose, translate by (block x − camera x, block y − camera y, block z − camera z) as doubles, call `BlockEntityRenderDispatcher.submit` (which finds the renderer from the state's type and calls its `submit`; an exception is reported as the crash report "Rendering Block Entity"), pop. Nothing else is applied by the loop, so the renderer's own transform is relative to the block's minimum corner (52-1 §2.1).
5. `AbstractSignRenderer.submit`: **front text**: push, multiply the pose by `transformations.frontText`, `submitSignText(frontText)`, pop; then **back text** the same way with `transformations.backText`. Both sides are always submitted, in one call, whatever side the viewer is on.
6. `submitSignText` submits the four lines (section 5) through `SubmitNodeCollector.submitText`; the collected text nodes are drawn later in the frame by the text feature renderer (section 6.7).

### 2.4 The pose tables (`WallAndGroundTransformations`)

Each renderer class builds, once, two tables of (front pose, back pose) pairs: one for each of the six `Direction`s (the wall table; only the four horizontal directions can occur) and one for each of the 16 rotation values. The wall entry uses the angle `Direction.toYRot()` (south 0, west 90, north 180, east 270; 52-1 §2.4); the rotation entry uses `RotationSegment.convertToDegrees(rotation)` (section 4.3). The renderer picks the wall table when the block is a `WallSignBlock` (standing renderer) or `WallHangingSignBlock` (hanging renderer), else the rotation table using the block's `rotation` property.

### 2.5 Conventions

- **Block space** is the space of 52-1 §2.1: origin at the block's minimum corner, 1 unit = 1 block, x east, y up, z south, right-handed (looking north, x to the right, y up, z toward the viewer). Pixels (1/16 block) are used for the board models and are marked "px".
- **Pose composition.** `PoseStack.mulPose` and the `Matrix4f` calls used by the renderers **post-multiply**: a list "T1, R, T2, S" in this document means the matrix `T1 · R · T2 · S` and a font-space point is transformed by S first and T1 last. The rotation `R_y(a)` is the joml rotation about +Y by `a` degrees, which maps (x, z) to (x cos a + z sin a, −x sin a + z cos a) (the formula of 52-1 §2.4). All the renderers rotate by **−angle**.
- **Font space** (the coordinates passed to the text engine, called "font px"): x to the right along the reading direction, y downward, z toward the viewer of the front side (0 on the glyph plane). One font px is one pixel of the GUI font; the pose scales it to blocks.

## 3. The sign boards: block states, models, textures

### 3.1 Block state to model

Every wood has the same four block state files (checked for all 13: identical apart from the model and texture names).

| Block | Variant key | Model | Block state `y` |
|---|---|---|---|
| standing sign | `rotation=k`, k = 4q + r (r = 0..3, q = 0..3) | `block/<wood>_sign_rot_<r>` | `y` = 90 · q (key absent when q = 0) |
| wall sign | `facing=south` / `west` / `north` / `east` | `block/<wood>_wall_sign` | 0 (absent) / 90 / 180 / 270 |
| ceiling hanging sign | `attached=false,rotation=k` | `block/<wood>_hanging_sign_rot_<r>` | 90 · q |
| ceiling hanging sign, attached | `attached=true,rotation=k` | `block/<wood>_hanging_sign_attached_rot_<r>` | 90 · q |
| wall hanging sign | `facing=south` / `west` / `north` / `east` | `block/<wood>_wall_hanging_sign` | 0 / 90 / 180 / 270 |

The block state `y` rotation is the standard clockwise-from-above turn of the block-model rotation (a model authored facing south turned by `y` = 90 faces west). Examples read: `rotation=8` is `<wood>_sign_rot_0` with `y` 180; `rotation=10` is `rot_2` with `y` 180; `rotation=4` is `rot_0` with `y` 90. All these models have `ambientocclusion` false and the parent `block/block`.

### 3.2 Geometry of the standing sign (`template_sign_rot_0`..`rot_3`)

Cuboids in block pixels (px), y up, z south, in the model's own frame (before the block state `y` turn). `rot_r` rotates **both** cuboids by the element rotation angle **−22.5 × r degrees** about the vertical axis through (8, 0, 8) (r = 0: no rotation on the post, and an angle of 0.0001 on the board, which is practical no rotation).

| Part | From (x, y, z) | To (x, y, z) | Faces present |
|---|---|---|---|
| post | (7.33333, 0, 7.33333) | (8.66667, 9.33333, 8.66667) | north, east, south, west, down (the down face has `cullface` down); **no up face** |
| board | (0, 9.33333, 7.33333) | (16, 17.33333, 8.66667) | all six; no cull faces |

So the board is 16 × 8 × 1.33333 px, its centre is (8, 13.3333, 8), the front face (south) is at z = 8.66667 and the back face (north) at z = 7.33333; the post is 1.33333 px square and 9.33333 px high.

### 3.3 Geometry of the wall sign (`template_wall_sign`)

One cuboid, authored for `facing = south` (the sign is on the **north** wall of its cell): from (0, 4.33333, 0.33333) to (16, 12.33333, 1.66667); faces: all six; the east and west faces have `cullface` east and west. The front is the south face at z = 1.66667 px, the back the north face at z = 0.33333 px; the board centre is (8, 8.3333, 1). The block state `y` turn then gives the other facings (`facing=north` puts the board at z 14.33333..15.66667, front at z = 14.33333).

### 3.4 Geometry of the hanging signs

All pixels, rotation-0 frame. Parts of `template_hanging_sign_rot_0`:

| Part | From | To | Faces / notes |
|---|---|---|---|
| board | (1, 0, 7) | (15, 10, 9) | all six; the down face has `cullface` down |
| 4 chains (non-attached) | (2.96447, 10, 4.46447) to (5.96447, 16, 4.46447); (2.96447, 11, 11.53553) to (5.96447, 15, 11.53553); (10.03553, 10, 11.53553) to (13.03553, 16, 11.53553); (10.03553, 11, 4.46447) to (13.03553, 15, 4.46447) | flat quads (zero thickness), north and south faces only, rotated about the vertical axis through (8, 0, 8) by +45, −45, +45, −45 degrees respectively; they form two crossed chain pairs seen from above |

`template_hanging_sign_rot_1..3` rotate the board by −22.5, −45, −67.5 degrees about (8, 0, 8) (the same cuboid, only the rotation entry changes) and turn each chain quad about the same axis. In the order of the table above, the chain quads 1 and 3 (the "type A" quads, x 2.96447 and 10.03553 with y 10..16) take the angles +45, +22.5, 0 (no rotation entry), −22.5 for r = 0, 1, 2, 3, and the quads 2 and 4 (the "type B" quads, y 11..15) take −45, −67.5, −90 and, for r = 3, a three-axis rotation entry (x 180, y −67.5, z −180); the pattern of the other three values suggests −112.5 for it (inferred: for a flat two-faced quad a half turn about the vertical axis only swaps the faces). The chain quads keep their source positions; only their angle changes, so they stay on the corner chains of the board, which is turned by −22.5 × r.

### 3.5 The attached ceiling hanging sign (`template_attached_hanging_sign_rot_0..3`)

The `attached=true` state uses the same board cuboid (1, 0, 7) to (15, 10, 9) with the same rotations (0, −22.5, −45, −67.5 about (8, 0, 8)) but **replaces the four chain quads by one flat double-sided quad**: from (2, 10, 8) to (14, 16, 8), turned by the same angle as the board, with the texture rectangle (16, 0) to (10, 3) on the north face and (10, 0) to (16, 3) on the south face (model uv units, section 3.7). That is the "middle attachment" look: one wide chain plate instead of two chain pairs. **The text transform of an attached sign is exactly that of the plain ceiling hanging sign** (section 4); only `HangingSignBlock.getAttachmentPoint` (`CEILING_MIDDLE` instead of `CEILING`) differs, and it affects only the editor.

Placement rule that decides `attached` (read from `CeilingHangingSignBlock.getStateForPlacement`; the block documents own it): `attached` starts true when the block above has no full bottom face (collision shape) or the player is sneaking, and false otherwise; when the block above is a hanging sign and the player is not sneaking it is then forced false if that sign's axis equals the axis of the player's facing direction (for a wall hanging sign above: the axis of its `facing`; for a ceiling hanging sign above: the axis of its `rotation` when that is 0, 4, 8 or 12). The `rotation` value is the 16-step `round((playerYaw + 180) / 22.5) mod 16` when `attached` is true and the 4-step value of the opposite of the player's facing direction (0, 4, 8 or 12) when it is false.

### 3.6 Wall hanging sign (`template_wall_hanging_sign`)

Authored for `facing = south` (the sign's faces look south and north; the wall blocks are to the east and west of the cell). Cuboids in px:

| Part | From | To | Notes |
|---|---|---|---|
| board | (1, 0, 7) | (15, 10, 9) | all six; rotation entry of angle 0 about (1, 0, 7); down face `cullface` down |
| bracket bar | (0, 14, 6) | (16, 16, 10) | all six; east, west and up have `cullface` east, west, up |
| 4 chain quads | (1.5, 10, 8) to (4.5, 12, 8), turned +45 about (3, 11, 8); (1.5, 11, 8) to (4.5, 14, 8), turned −45 about (3, 12, 8); (11.5, 10, 8) to (14.5, 12, 8), +45 about (13, 11, 8); (11.5, 11, 8) to (14.5, 14, 8), −45 about (13, 12, 8) | flat, north and south faces |

The block state turns (`y` 0, 90, 180, 270 for facing south, west, north, east) place the other facings.

### 3.7 Textures

Texture file naming and sizes (all 13 woods checked: every file is **32 × 32** px; the item sprites are 16 × 16):

| Use | File (`assets/minecraft/textures/`) | Atlas |
|---|---|---|
| standing and wall sign board | `block/<wood>_sign.png`, texture variable `all` | block atlas |
| hanging and wall hanging sign | `block/<wood>_hanging_sign.png`, texture variable `all` | block atlas |
| item sprite | `item/<wood>_sign.png`, `item/<wood>_hanging_sign.png` | item atlas |
| editor background (not used here) | `gui/signs/<wood>.png`, `gui/hanging_signs/<wood>.png` | GUI |

The per-wood models differ only in the texture names and the `particle` texture:

| Wood | `all` (sign / hanging) | `particle` of the sign models | `particle` of the hanging models |
|---|---|---|---|
| oak, spruce, birch, acacia, cherry, jungle, dark_oak, pale_oak, mangrove, poplar | `block/<wood>_sign`, `block/<wood>_hanging_sign` | `block/<wood>_planks` | `block/stripped_<wood>_log` |
| bamboo | `block/bamboo_sign`, `block/bamboo_hanging_sign` | `block/bamboo_planks` | `block/bamboo_planks` |
| crimson, warped | `block/<wood>_sign`, `block/<wood>_hanging_sign` | `block/<wood>_planks` | `block/stripped_<wood>_stem` |

(Bamboo needs no special geometry: it uses the same templates as the other woods; only its hanging particle differs.) The 26 sign item definitions are all the plain `minecraft:model` form (section 11.1).

Model `uv` values are in 0..16 units over the whole texture, so on a 32 × 32 file **pixel = 2 × uv**. The rectangles (u1, v1, u2, v2 in uv units, then pixels) used by the boards:

| Face | Standing / wall board uv | pixels | Hanging board uv | pixels |
|---|---|---|---|---|
| front (south at rot 0) | (0, 1, 12, 7) | (0, 2) to (24, 14) | (1, 8, 8, 13) | (2, 16) to (16, 26) |
| back (north) | (0, 8, 12, 14) | (0, 16) to (24, 28) | (9, 8, 16, 13) | (18, 16) to (32, 26) |
| top | (0, 0, 12, 1) | (0, 0) to (24, 2) | (1, 7, 8, 8) | (2, 14) to (16, 16) |
| bottom | (0, 14, 12, 15) | (0, 28) to (24, 30) | (1, 13, 8, 14) | (2, 26) to (16, 28) |
| east | (12, 1, 13, 7) | (24, 2) to (26, 14) | (8, 8, 9, 13) | (16, 16) to (18, 26) |
| west | (12, 8, 13, 14) | (24, 16) to (26, 28) | (0, 8, 1, 13) | (0, 16) to (2, 26) |

The standing post uses (14, 8, 15, 15) north, (15, 0, 16, 7) east, (14, 0, 15, 7) south, (15, 8, 16, 15) west and (14, 15, 15, 16) down. The front rectangle of a standing or wall board is 24 × 12 px for a 16 × 8 px face and that of a hanging board 14 × 10 px for a 14 × 10 px face. The chain quads use the rectangles (12.5, 3.5, 11, 6.5) and (15.5, 4, 14, 6) (north) and their mirror (south) for the rotation-0 hanging sign, (12.5, 5.5, 11, 6.5) and (15.5, 4.5, 14, 6) for the wall hanging chains.

## 4. The text plane transform

All four recipes are `Matrix4f` operation chains on a fresh matrix, read from `StandingSignRenderer.textTransformation` and `HangingSignRenderer.textTransformation`. "angle" is the degrees of section 4.3 and `front` selects the side. Numbers are the float literals of the constants (as decimals).

### 4.1 The step lists

**Standing sign and wall sign** (`StandingSignRenderer`; ground attachment for a standing sign, wall attachment for a wall sign):

| Step | Operation | Value |
|---|---|---|
| 1 | translate | (0.5, 0.5, 0.5) |
| 2 | rotate about +Y | −angle degrees |
| 3 | translate, **wall attachment only** | (0, −0.3125, −0.4375) |
| 4 | rotate about +Y, **back side only** | 180 degrees |
| 5 | translate (the text offset) | (0, 0.33333334, 0.046666667) |
| 6 | scale | (0.010416667, −0.010416667, 0.010416667) |

**Hanging sign and wall hanging sign** (`HangingSignRenderer`; the same for ceiling, attached and wall):

| Step | Operation | Value |
|---|---|---|
| 1 | set the matrix to the translation | (0.5, 0.9375, 0.5) |
| 2 | rotate about +Y | −angle degrees |
| 3 | translate | (0, −0.3125, 0) |
| 4 | rotate about +Y, **back side only** | 180 degrees |
| 5 | translate (the text offset) | (0, −0.32, 0.073) |
| 6 | scale | (0.0140625, −0.0140625, 0.0140625) |

A font-space point (fx, fy, 0) goes through step 6 first. `0.010416667` is 1/96 (also = the declared constant 0.6666667 divided by 64, inferred) and `0.0140625` is 0.9/64 (the declared constant `TEXT_RENDER_SCALE` 0.9).

### 4.2 Closed forms (rotation angle 0, front side)

With s = 0.010416667 (standing, wall) or 0.0140625 (hanging), the block-space position of font point (fx, fy, 0) for angle 0 is X = 0.5 + s·fx, Y = Y0 − s·fy, Z = Z0, with:

| Family | Y0 | Z0 (front) | Z0 (back) | Text-origin in px (front) |
|---|---|---|---|---|
| standing sign | 0.5 + 0.33333334 = 0.8333333 | 0.5 + 0.046666667 = 0.5466667 | 0.5 − 0.0466667 = 0.4533333 | (8, 13.3333, 8.7467) |
| wall sign | 0.5 − 0.3125 + 0.33333334 = 0.5208333 | 0.5 − 0.4375 + 0.0466667 = 0.1091667 | 0.5 − 0.4375 − 0.0466667 = 0.0158333 | (8, 8.3333, 1.7467) |
| ceiling or wall hanging sign | 0.9375 − 0.3125 − 0.32 = 0.305 | 0.5 + 0.073 = 0.573 | 0.5 − 0.073 = 0.427 | (8, 4.88, 9.168) |

For the back side X = 0.5 − s·fx (the x axis is reversed) and the "back" column of Z0 applies. For the wall sign the wall translation (step 3) comes before the back turn (step 4), so the back plane is the mirror image of the front plane about the board's centre plane (z = 0.0625 block = 1 px for `facing = south`: 0.1091667 + 0.0158333 = 2 × 0.0625).

For another angle, the whole result (positions and axes) is turned about the vertical axis through the block centre (0.5, ·, 0.5) by −angle (section 4.3). In the sign's own frame (before step 2's rotation) the wall sign's text planes are at z_local = −0.3908333 (front) and −0.4841667 (back) measured from the block centre, that is 0.3908333 and 0.4841667 block toward the wall.

### 4.3 The angle: rotation values and facings

**Rotation property (standing sign, ceiling hanging sign; 16 values).** `angle` = `RotationSegment.convertToDegrees(rotation)` = 22.5 × rotation, with **360 subtracted when the result is 180 or more** (the `SegmentedAnglePrecision.toDegrees` rule), so 180 becomes −180 and the range is −180 to 157.5: rotations 8 to 15 give 22.5 × rotation − 360. R_y(−angle) turns the front normal (0, 0, +1) to (−sin angle, 0, cos angle):

| rotation | angle | front normal (x, z) | front faces |
|---|---|---|---|
| 0 | 0 | (0, +1) | south |
| 1 | 22.5 | (−0.3827, +0.9239) | south by west (SSW) |
| 2 | 45 | (−0.7071, +0.7071) | south-west |
| 3 | 67.5 | (−0.9239, +0.3827) | west by south (WSW) |
| 4 | 90 | (−1, 0) | west |
| 5 | 112.5 | (−0.9239, −0.3827) | WNW |
| 6 | 135 | (−0.7071, −0.7071) | north-west |
| 7 | 157.5 | (−0.3827, −0.9239) | NNW |
| 8 | −180 | (0, −1) | north |
| 9 | −157.5 | (+0.3827, −0.9239) | NNE |
| 10 | −135 | (+0.7071, −0.7071) | north-east |
| 11 | −112.5 | (+0.9239, −0.3827) | ENE |
| 12 | −90 | (+1, 0) | east |
| 13 | −67.5 | (+0.9239, +0.3827) | ESE |
| 14 | −45 | (+0.7071, +0.7071) | south-east |
| 15 | −22.5 | (+0.3827, +0.9239) | SSE |

(The rotation increases **clockwise seen from above**: south, west, north, east at 0, 4, 8, 12.) **Do not mirror `RotationSegment.convertToDirection`**: it maps 0 to north, 4 to east, 8 to south and 12 to west, which is *not* the inverse of `convertToSegment(Direction)` (south 0, west 4, north 8, east 12); it is used only to read the axis of a ceiling hanging sign (3.5). The render mapping comes only from `toDegrees` and the transform of 4.1. The back side faces the opposite way. This agrees with the block side: `RotationSegment.convertToSegment(Direction)` is `2D data value × 4` (south 0, west 4, north 8, east 12), the standing sign is placed with `round((placerYaw + 180) / 22.5) mod 16` (`Math.round`, ties up; so a player looking south, yaw 0, gets rotation 8 and the front faces north, toward the player), and the front/back test of 31-3 §2.4 (which compares `getYRotationDegrees` with the direction to the player) puts the player in front when he stands along (−sin angle, cos angle).

**Facing property (wall sign, wall hanging sign; 4 values).** `angle` = `Direction.toYRot()`: south 0, west 90, north 180, east 270. The front looks **toward the facing direction**: front normal south (0, +1), west (−1, 0), north (0, −1), east (+1, 0). The block is attached to the neighbour on the **opposite** side (`WallSignBlock.canSurvive` tests `pos.relative(facing.getOpposite())`). A wall hanging sign's `facing` is the direction of its faces; the wall blocks it hangs from are on the two sides along the other horizontal axis (the bracket bar spans the whole cell along that axis, section 3.6).

### 4.4 Text plane against the board (rotation 0 or `facing=south`, px)

| Family | Board (front face z, back face z, y range) | Text plane z, front / back | Gap to the face | Text-origin y vs board centre y |
|---|---|---|---|---|
| standing | 8.66667 / 7.33333, y 9.33333..17.33333 (centre 13.3333) | 8.74667 / 7.25333 | 0.08 px in front of each face | equal (13.3333) |
| wall sign | 1.66667 / 0.33333, y 4.33333..12.33333 (centre 8.3333) | 1.74667 / 0.25333 | 0.08 px | equal (8.3333) |
| hanging (ceiling, wall) | 9 / 7, y 0..10 (centre 5) | 9.168 / 6.832 | 0.168 px | 4.88 against 5 (0.12 px below the centre) |

The glyph cells of the four lines (section 5.3) span block y: standing 0.6458..1.0417 (px 10.33..16.67), wall sign 0.3333..0.7292 (px 5.33..11.67), hanging 0.0659..0.5581 (px 1.05..8.93), all inside the board (standing 9.33..17.33 px, wall sign 4.33..12.33 px, hanging 0..10 px).

### 4.5 Axis, handedness and the y flip

- Font +x maps to the sign's right-hand side as seen by a viewer on the side being drawn; font +y (down the line) maps to world **down** (the −s in step 6); font +z (the glyph plane's normal toward the viewer) maps to the outward normal of the drawn side.
- The matrix with one negative scale component has a negative determinant (a reflection of font space), but only the glyph plane z = 0 is drawn, so the visible result is not mirrored. Seen from the drawn side the glyph quad's four vertices (in the order of section 5.5: top-left, bottom-left, bottom-right, top-right) run **counter-clockwise** (inferred from the order and the flip; Open question 1 notes that the pipeline's cull mode was not read).
- At rotation 0 (front) font x = block x, so the text reads left to right when looking north from the south side of the sign; the back side reads along block −x.

## 5. Line layout

### 5.1 Which lines are drawn

`submitSignText` loops over the render-message array of the side: **exactly four entries** (a `SignText` always has 4 lines; 31-3 §2.2). All four are submitted in order, line 0 first, **even when empty** (an empty line submits an empty character sequence that draws nothing). There is no line skipping, no scrolling and no clipping of lines.

The array comes from `SignText.getRenderMessages(filtering, splitFunction)`: it builds one `FormattedCharSequence` per line from `getMessages(filtering)` (the filtered lines when `isTextFilteringEnabled`, else the raw lines; 31-3 §2.2) and **caches the array inside the `SignText` object**, keyed only by the filtering flag. The cache lives as long as that `SignText` instance (a new instance replaces it on every edit; the width limit and font are fixed per sign type).

### 5.2 Splitting one line to the width limit

The function applied to each line component is `Font.split(component, maxTextLineWidth)` (the integer limit 90 or 60), then `Language.getVisualOrder` (identity for left-to-right languages; reordering for bidirectional text, not traced, Open question 5). Only the **first** piece of the result is used; **an empty result gives the empty sequence**; every further piece is silently dropped. `Font.split` uses `StringSplitter.splitLines(text, width, Style.EMPTY)`:

1. The component is flattened into styled text runs (empty runs dropped). Widths come from the font: the advance of a code point in its style's font (section 5.5), plus 1.0 when the style is bold.
2. Let `W = max(width, 1.0)` (float). Scan the code points from the start of the remaining text, with a running width (float, the sum of advances), a flag "some earlier character had non-zero advance" and the position of the last space seen. For each code point `c`:
   - if `c` is a line feed (10) the line ends here, at this character;
   - if `c` is a space (32) remember its position as the last space (the space is then measured like any other character);
   - add the advance of `c` to the width; **if the flag is set and the width is greater than W** (strictly) the line ends at the last remembered space when there is one, else at the current character;
   - otherwise the character is accepted and the flag is updated (set when the advance is not 0).
   The **first character with a non-zero advance is always accepted**, even when it alone is wider than W.
3. If the scan reaches the end of the text, the rest is the last line. Otherwise a line is cut at the break position `p`: the piece is the text before `p`; if the character at `p` is a line feed or a space it is **consumed** (the next line starts after it), otherwise the next line starts at `p` (a hard break inside a word). The scan restarts with width 0 for the remainder.
4. An empty component gives no line at all. A text ending in a line feed yields one extra empty last line. (Only the first piece of line `i` is ever drawn.)

So a long line is not clipped: its overflow is dropped. The limit is on advance sums, not on blocks or pixels of the final quad: a line whose width is exactly W fits (the test is strictly greater).

Example (default font, advances of section 5.5): "Hello World Hello" has width 24 + 4 + 27 + 4 + 24 = 83. On a standing sign (limit 90) it stays one piece of width 83. On a hanging sign (limit 60): after "Hello World" the width is 55; the next space brings it to 59 (not over 60) and is remembered; the next 'H' (6) brings it to 65 (over 60), so the line ends at that space: the piece is "Hello World" (width 55) and "Hello" is dropped.

### 5.3 Vertical placement

Let `h` = `textLineHeight` (10 sign, 9 hanging sign). The block's half height `H2 = (4 × h) / 2` (integer division) is **20** for signs and **18** for hanging signs. Line `i` (0..3) is drawn with its glyph origin at font y = `i × h − H2`:

| Sign type | line 0 | line 1 | line 2 | line 3 |
|---|---|---|---|---|
| standing, wall (h 10) | −20 | −10 | 0 | 10 |
| hanging (h 9) | −18 | −9 | 0 | 9 |

The text origin of the pose (font y = 0) is the vertical centre of the four-line block (the block spans font y from −H2 to +H2 in line pitch). Because the glyph cell is 8 font px high and the pitch is 10 (or 9), the visible glyph box of line `i` is `[i·h − H2, i·h − H2 + 8]`.

Block y of the top and bottom of the cell of each line for angle 0 (Y = Y0 − s·fy):

| Family | line 0 top / bottom | line 1 | line 2 | line 3 |
|---|---|---|---|---|
| standing (Y0 0.8333333, s 1/96) | 1.0416667 / 0.9583333 | 0.9375000 / 0.8541667 | 0.8333333 / 0.7500000 | 0.7291667 / 0.6458333 |
| wall sign (Y0 0.5208333) | 0.7291667 / 0.6458333 | 0.6250000 / 0.5416667 | 0.5208333 / 0.4375000 | 0.4166667 / 0.3333333 |
| hanging (Y0 0.305, s 0.0140625) | 0.5581250 / 0.4456250 | 0.4315625 / 0.3190625 | 0.3050000 / 0.1925000 | 0.1784375 / 0.0659375 |

(Computed: Y_top = Y0 − s·(i·h − H2); Y_bottom = Y_top − 8·s.)

### 5.4 Horizontal centring

For each line the width is `Font.width(sequence)` = `Mth.ceil` of the float sum of the advances (the advances of the default font are integers, so this is the integer sum). The x origin passed to the text engine is the float of the integer expression **(−width) / 2 with Java integer division** (truncation toward zero): for even width `−width/2`, for odd width `−(width − 1)/2` (27 gives −13, 83 gives −41). The pen then advances by each glyph's advance, so the line occupies font x from `x0` to `x0 + width` and is centred on font x = 0, except that an odd width leaves the extra pixel on the right (the line's centre is half a font pixel right of 0). An empty line has width 0 and x origin 0.

### 5.5 The glyph quads (default bitmap font, no style)

For a glyph at pen position (x, y) in font px, the quad (no bold, no italic, no shadow) has these font-space corners, in this vertex order: (x, y) top-left, (x, y + 8) bottom-left, (x + 8, y + 8) bottom-right, (x + 8, y) top-right, all at z = 0. The 8 × 8 box comes from `GlyphBitmap` defaults for a bitmap-font glyph: left = bearing left 0, right = left + cell width / oversample (the 8-pixel cell at scale 1), top = 7 − ascent (the bitmap provider's ascent 7 for the ascii page) = 0, bottom = top + cell height = 8. The ink sits inside the cell; the baseline is at y + 7. Texture coordinates run (u0, v0), (u0, v1), (u1, v1), (u1, v0) over the cell in the font atlas (a dynamic 256 × 256 atlas; the rectangle is inset by 0.01 texel on each side).

Advance of a bitmap glyph (`BitmapProvider.Definition.load`; confirms 12 §5.10): `advance = floor(0.5 + w × scale) + 1`, where `w` is the 1-based index of the rightmost cell column that contains a non-transparent pixel (0 for an empty cell) and `scale` is the provider `height` divided by the cell height in pixels (8 / 8 = 1 for `ascii.png`). A glyph with no ink gets advance 1, except where a `space` provider overrides it (below). Bold adds 1.0 to the advance (`GlyphInfo.getBoldOffset`), shadow offset is 1.0.

`textures/font/ascii.png` is 128 × 128 pixels, a 1-bit palette PNG (two palette entries, both white; the transparency chunk marks index 0 transparent), a 16 × 16 grid of 8 × 8 cells; row r, column c holds the code point 16r + c for rows 2 to 7 (verified for all of 32..126 against the `chars` strings of `font/include/default.json`; rows 0 and 1 are unused). Advances read from the pixels this round:

| Glyph | Rightmost ink column w | Advance | Ink box inside the cell (columns, rows) |
|---|---|---|---|
| H | 5 | 6 | cols 0..4, rows 0..6 |
| W | 5 | 6 | cols 0..4, rows 0..6 |
| e | 5 | 6 | cols 0..4, rows 2..6 |
| o | 5 | 6 | cols 0..4, rows 2..6 |
| r | 5 | 6 | cols 0..4, rows 2..6 |
| d | 5 | 6 | cols 0..4, rows 0..6 |
| l | 2 | 3 | cols 0..1, rows 0..6 |
| space | (bitmap cell empty: 1) | **4** from the `space` provider (the earlier provider wins) | none |

Widths used below: "Hello" = 6 + 6 + 3 + 3 + 6 = **24**; "World" = 6 + 6 + 6 + 3 + 6 = **27**. (The nominal 8 × 8 cell box is exact for the quad; only the ink pixels inside it are narrower. Nothing in this section is nominal.)

## 6. Colour, glow, outline, light, shadow, render types

### 6.1 Colour rules

Inputs: the side's dye colour `c` and the glow flag. `DyeColor.getTextColor()` is the 24-bit value of 31-3 §8 stored with **alpha 0xFF** (the constructor applies `ARGB.opaque`; the black entry is **0x000000**, i.e. `0xFF000000`; the values 0x1E1B1B and 0x1D1D21 that appear next to it in the table are the firework and the texture-diffuse colour of black, not its text colour).

| Quantity | Rule |
|---|---|
| `dark(c)` (`AbstractSignRenderer.getDarkColor`) | if `textColor(c)` equals black's text colour and the text is glowing: **0xFFF0EBCC**; else each of red, green, blue of `textColor(c)` times 0.4 (float multiply), truncated toward zero, clamped to 0..255; alpha kept (0xFF) |
| fill colour, non-glowing | `dark(c)` (the dye colour at 40 %) |
| fill colour, glowing | `textColor(c)` unscaled |
| outline colour, glowing and outline drawn | `dark(c)` |
| outline colour otherwise | 0 (no outline pass) |
| a component's own colour (`Style.color`) | replaces the RGB of the fill colour for those glyphs, **at full intensity** (it is not scaled by 0.4); the alpha stays that of the base colour (0xFF). In the outline pass every glyph, whatever its own colour, is drawn in the outline colour |

All 16 dyes (ARGB, alpha FF everywhere):

| Dye | glowing fill = `textColor` | non-glowing fill = glowing outline = `dark` |
|---|---|---|
| white | FFFFFF | 666666 |
| orange | FF681F | 66290C |
| magenta | FF00FF | 660066 |
| light_blue | 9AC0CD | 3D4C52 |
| yellow | FFFF00 | 666600 |
| lime | BFFF00 | 4C6600 |
| pink | FF69B4 | 662A48 |
| gray | 808080 | 333333 |
| light_gray | D3D3D3 | 545454 |
| cyan | 00FFFF | 006666 |
| purple | A020F0 | 400C60 |
| blue | 0000FF | 000066 |
| brown | 8B4513 | 371B07 |
| green | 00FF00 | 006600 |
| red | FF0000 | 660000 |
| black | 000000 | 000000 for non-glowing text; **F0EBCC** for glowing text |

(The default black sign text is therefore pure black, `0xFF000000`.)

### 6.2 Light

- Non-glowing: the state's `lightCoords` (the packed brightness of the sign's own cell, 52-1 §2.3; 15728880 when the block entity has no level).
- Glowing: the constant **15728880 = `0xF000F0`** (block light 15, sky light 15), for both the outline and the fill.
- The packed value is the vertex light attribute; the text shader multiplies the glyph colour by the lightmap sample at that light (`sample_lightmap`), so full-bright is the lightmap's (15, 15) texel, whose value depends on dimension, gamma and effects (not traced, Open question 6).

### 6.3 When the outline is drawn

The outline is drawn when **the text is glowing and (the dye text colour is black, or the state's `drawOutline` is true)**:

- **Black glowing text always has its outline** (cream `0xFFF0EBCC`).
- For every other dye, the outline is drawn only if `drawOutline` is true. `drawOutline` is computed at extract time by `isOutlineVisible(blockPos)`:
  1. if there is a local player, the camera type is first person **and the player is scoping** (`LocalPlayer.isScoping`, the spyglass): true;
  2. else if there is a camera entity: true when the camera entity's squared distance to the **block centre** (`Vec3.atCenterOf`; `Entity.distanceToSqr(Vec3)` measures from the entity's **feet position** `getX/getY/getZ`, not the eye, a 3D distance in doubles) is **strictly less than `OUTLINE_RENDER_DISTANCE` = `Mth.square(16)` = 256** (16 blocks);
  3. else false.
- Non-glowing text never has an outline whatever the flag.
- There is **no crosshair, hit-result or "is looking at" test** anywhere in the sign path.

### 6.4 How the outline and the fill are drawn

One call per line: `submitText(pose, x, y, sequence, dropShadow = false, displayMode = POLYGON_OFFSET, lightCoords, color = fill, backgroundColor = 0, outlineColor)`. When the feature renderer draws it (`TextFeatureRenderer.renderText`):

- **No outline** (`outlineColor` 0): one pass, the text prepared with the fill colour, no shadow, no background, drawn in display mode **polygon offset**.
- **With outline** (`outlineColor` non-zero): first the **outline pass**, drawn with display mode **normal**; then the **fill pass** in display mode **polygon offset**. The fill therefore comes second and wins at equal depth.
  The outline pass (`Font.prepare8xTextOutline`) draws the whole line eight times, once for each offset (dx, dy) with dx and dy in {−1, 0, +1} except (0, 0), in the order dx = −1: dy = −1, 0, +1; dx = 0: dy = −1, +1; dx = +1: dy = −1, 0, +1. Each copy is the line at x + dx × 1.0 and y + dy × 1.0 font px (the glyph's shadow offset, 1.0), every glyph in the outline colour (the style colour replaced by it, alpha from the outline colour), with the normal advances and no shadow or effects. In blocks the offset is one `s` (1/96 block = 0.1667 px for signs, 0.225 px for hanging signs).
- All quads of both passes are at font z = 0 (the same plane as the pose gives). The fill pass is pulled toward the camera by the polygon-offset pipeline (section 6.6).

### 6.5 Shadow and styled glyphs

`dropShadow` is false: **no shadow** is drawn (the builder's shadow colour is 0). The exception is a style that carries an explicit shadow colour (a component with a shadow colour): then a shadow quad is created at +1.0, +1.0 font px with that colour (alpha multiplied by the text alpha) and the glyph itself is moved +0.03 toward the viewer in z. Styles of a line's components change the glyph quads as follows (all read in `Font.PreparedTextBuilder` and `BakedSheetGlyph`; they apply to sign text like any other text):

- **Bold.** The advance grows by 1.0 and the glyph is drawn twice, the second copy 1.0 font px to the right and 0.001 nearer in z. The quad-building routine takes an "extra thickness" argument that is **0.1 when it is called for a bold glyph (the call sites pass the style's bold flag, true for the second bold copy) and 0 otherwise**; it enlarges the quad by 0.1 font px on every side (left and top minus 0.1, right and bottom plus 0.1).
- **Italic.** The top edge of the quad is shifted in x by `1 − 0.25 × up` and the bottom edge by `1 − 0.25 × down`, where `up` and `down` are the glyph's top and bottom offsets within its box (0 and 8 for the ascii page: the top edge moves +1 font px to the right, the bottom edge moves 1 font px to the left). This answers 12 §5.10 open question 13.
- **Underline and strikethrough.** 1-pixel effect quads, as in 12 §5.10.
- **Obfuscated.** Each non-space character is replaced, every time the glyph is looked up (every frame), by a random code point whose rounded-up non-bold advance equals the rounded-up advance of the real character: the font keeps, for each rounded-up advance, the list of code points it supports (the first provider that defines each one, glyphs of the missing kind excluded), and the pick is uniform (`RandomSource.nextInt(size)`); with no such list the missing glyph is used. The space is not replaced. The wrapping width is measured with the real characters (the splitter uses the unobfuscated advances).

### 6.6 Render types and pipelines

The glyph quads use the glyph sheet's `GlyphRenderTypes`. Because `ascii.png` is a palette PNG with a transparency chunk (the decoded image has more than one component, inferred; `isColored` tests for more than one component), its glyphs use the **colour** variants (`RenderTypes.text` for normal, `textSeeThrough`, `textPolygonOffset` for polygon offset), not the grayscale ones.

| Display mode | Pipeline | Notes |
|---|---|---|
| normal | `pipeline/text`: vertex shader and fragment shader `core/text`, vertex format position, texture coordinate, lightmap, colour; quads; translucent blend; depth state (compare greater-than-or-equal, write on, no bias); light map on | outline pass |
| polygon offset | `pipeline/text_polygon_offset`: as above with depth state (compare greater-than-or-equal, write on, **bias scale factor 1.0, bias constant 10.0**) | fill pass; the render type uses the lightmap and sorts its quads on upload (the normal type does not) |
| see-through | not used by signs | |

Read: the pipeline names, the shader names, the vertex format, the blend function (translucent), the depth-state constants (compare greater-than-or-equal and depth write for both; scale factor 1.0 and constant 10.0 for the polygon-offset one) and the render-type setup. Both render types also name an order-independent-transparency pipeline variant (`OIT_TEXT`, `OIT_TEXT_POLYGON_OFFSET`); that the variants exist was read, their contents were not (Open question 8). The fragment shader (`core/text.fsh`, read) multiplies the texel by the vertex colour (which already contains the lightmap factor) and the colour modulator, **discards fragments with alpha below 0.1**, and applies fog (spherical and cylindrical distance) unless the pipeline is the GUI or see-through variant. That the compare "greater than or equal" together with the positive bias means a reversed depth buffer in which the bias moves the fill toward the camera is **(inferred)**; Open question 2.

### 6.7 Draw phase

`SubmitNodeCollection.submitText`: display mode see-through goes to the translucent see-through phase; otherwise, if the content is a plain text whose **fill colour alpha is 255**, whose background alpha is 0, and the level is being rendered, it goes to the **solid** phase; any other case goes to the `texts` phase. Sign text always satisfies the solid-phase test (alpha FF, no background), so **sign text is drawn with the opaque geometry of the level**, with alpha testing by the shader (section 6.6) and blending as set by the pipeline.

## 7. Visibility, distance and culling

| Test | Where | Rule |
|---|---|---|
| Section visible | `extractVisibleBlockEntities` | the chunk section is in the level renderer's visible list (frustum plus occlusion graph) and its fade-in visibility is at least 0.3 |
| Renderer view distance | `BlockEntityRenderer.shouldRender`, default | block centre closer than `getViewDistance()` = **64** blocks (squared distance < 4096, camera position, full 3D); the sign renderers do not override `shouldRender` or `getViewDistance` |
| Valid state, has level | `tryExtractRenderState` | see 2.3 |
| Text distance | none | the text is drawn at any distance within the above |
| Outline distance | `AbstractSignRenderer.isOutlineVisible` | 16 blocks (squared 256) from the camera entity's feet position to the block centre, or scoping in first person; gates only the outline of **coloured** glowing text |
| Render bounding box | none | this version has no `getRenderBoundingBox` anywhere (no class refers to it); culling is by chunk section only |
| Looking-at / crosshair | none | not used |

At the first-person scoping condition (`isScoping`, first-person camera) the outline of every glowing sign in the frame is drawn regardless of distance; this changes only `drawOutline`, not the transform or the text.

## 8. Font

- The renderer takes the game's main `Font` from `BlockEntityRendererProvider.Context.font()`. A line's glyphs come from the font named by each character's `Style`; the sign supplies `Style.EMPTY` to the splitter and the text sequences carry the component's own style, so the font is **`minecraft:default`** unless a component sets a `font` (then e.g. `minecraft:alt`, `minecraft:illageralt`, `minecraft:uniform`, whose files exist under `font/`).
- `font/default.json` is three `reference` providers in this order: `include/space`, `include/default` (with the filter `uniform: false`, so the bitmap sheets are skipped when the "uniform" font option is on), `include/unifont`.
  - `include/space`: a `space` provider, advance 4 for the space and 0 for U+200C.
  - `include/default`: three bitmap providers in the order `font/nonlatin_european.png` (ascent 7), `font/accented.png` (`height` 12, ascent 10), `font/ascii.png` (ascent 7, height 8 by default).
  - `include/unifont`: an **empty provider list** in this artifact (it defines no glyph; the jar contains no `.hex` font file, checked by the file listing).
- The glyph for a code point is the one of the **first provider that defines it** and whose advance is within 0..32 (a negative advance or one above 32 is skipped). Code points defined by no provider get the missing glyph (not traced, Open question 4).
- Display mode: **polygon offset** (and **normal** for the outline pass). Line height of the font itself (9, `Font.lineHeight`) is not used: the sign supplies its own line height (10 or 9).
- Text render types: section 6.6.

## 9. Rotation mapping, shapes and hit-box centres (open question 18 of 31-3)

### 9.1 What the "hit-box centre" is used for

`SignBlock.getSignHitboxCenterPosition(state)` is called only from `SignBlockEntity.getSlotPlayerIsFacing` (31-3 §2.4), which decides whether a click or an application of dye, ink or honeycomb concerns the front or the back (`getSlotPlayerIsFacing` is itself called from `SignBlock`, `CeilingHangingSignBlock` and `WallHangingSignBlock`). No other code in the artifact calls it: it is not used for the editor (the editor needs only the block position), for particles, for the text distance or for the click position. The centre is a **block-relative position (0..1)**; it is added to the block position and the player's x and z differences from it feed the angle `atan2(dz, dx) × 57.2957763671875 − 90` of 31-3 §2.4.

### 9.2 Shapes

| Block | Shape (block pixels (x1, y1, z1)-(x2, y2, z2)) | Source |
|---|---|---|
| standing sign | one box (4, 0, 4)-(12, 16, 12) for every rotation | `SignBlock` constant `Block.column(8, 0, 16)`; 51 R-C6 |
| wall sign, authored for `facing = north` | (0, 4.5, 14)-(16, 12.5, 16) (`Block.boxZ(16, 4.5, 12.5, 14, 16)`) | `WallSignBlock` |
| wall sign, the four facings (`Shapes.rotateHorizontal`: north = as authored, east = a turn of the group element `BLOCK_ROT_Y_90` (the negative quarter turn about Y), south = 180, west = 270) | north (0, 4.5, 14)-(16, 12.5, 16); east (0, 4.5, 0)-(2, 12.5, 16); south (0, 4.5, 0)-(16, 12.5, 2); west (14, 4.5, 0)-(16, 12.5, 16) | 51 R-C7; consistent with `canSurvive` (the box is on the side of the supporting block) |
| ceiling and wall hanging signs | see 51 R-C8 and R-C9 | their hit-box centre is the constant below, not the shape |

(The east, south, west boxes are the rotation of the authored box about the block centre; their placement against the supporting neighbour agrees with `WallSignBlock.canSurvive`.)

### 9.3 Hit-box centre per block

| Block | `getSignHitboxCenterPosition` (block-relative) |
|---|---|
| standing sign, ceiling hanging sign, wall hanging sign | the constant (0.5, 0.5, 0.5) (the base method; none of these classes overrides it) |
| wall sign, `facing = north` | centre of the shape bounds: (0.5, 0.53125, 0.9375) |
| wall sign, `facing = east` | (0.0625, 0.53125, 0.5) |
| wall sign, `facing = south` | (0.5, 0.53125, 0.0625) |
| wall sign, `facing = west` | (0.9375, 0.53125, 0.5) |

(The wall sign overrides the method with the centre of `VoxelShape.bounds()` of the facing's shape: the y centre is (4.5 + 12.5)/2/16 = 0.53125 for all facings; x and z follow the boxes of 9.2.)

### 9.4 Facing-to-rotation mapping, summary

Standing sign and ceiling hanging sign: the `rotation` property 0..15 gives the front direction of section 4.3 (22.5 degrees per step, clockwise from above, 0 = front toward south, 4 = west, 8 = north, 12 = east); the model turns by the block state `y` = 90 × (rotation div 4) plus the element rotation −22.5 × (rotation mod 4), and the text turns by −angle (angle as in 4.3); the stored degrees used by the block code (`getYRotationDegrees`) are the same angle. Wall sign and wall hanging sign: `facing` gives the front direction directly, the block state `y` = toYRot of the facing (south 0, west 90, north 180, east 270) and the text turns by −toYRot.

`RotationSegment.convertToDirection` (0 north, 4 east, 8 south, 12 west) is not the inverse of `convertToSegment(Direction)` (south 0, west 4, north 8, east 12) and must not be used to derive the front direction; it only yields an axis (section 4.3).

## 10. Worked examples

Constants: s = 0.010416667 (1/96) for standing and wall signs, 0.0140625 for hanging signs. The default font, advances of section 5.5, black dye, **not glowing**. Fill colour = `dark(black)` = `0xFF000000`; no outline pass; light = the block's light; display mode polygon offset; one fill pass. Line 0 = "Hello" (width 24, x origin −12), line 1 = "World" (width 27, x origin −13); glyph x of each letter (font px): Hello: H −12, e −6, l 0, l 3, o 6 (ends at 12); World: W −13, o −7, r −1, l 5, d 8 (ends at 14). Font y origins: standing and wall −20 (line 0) and −10 (line 1); hanging −18 (line 0). Coordinates are block space (px = 16 × block).

### 10.1 Standing sign, rotation 0, front side

Pose: translate (0.5, 0.5, 0.5); rotate by 0; translate (0, 0.33333334, 0.046666667); scale (s, −s, s). Mapping: X = 0.5 + s·fx; Y = 0.8333333 − s·fy; Z = 0.5466667 (8.7467 px).

- Line 0, glyph box of "H": font quad (−12, −20), (−12, −12), (−4, −12), (−4, −20) (top-left, bottom-left, bottom-right, top-right) gives block space
  (0.3750000, 1.0416667, 0.5466667), (0.3750000, 0.9583333, 0.5466667), (0.4583333, 0.9583333, 0.5466667), (0.4583333, 1.0416667, 0.5466667) = px (6.0000, 16.6667, 8.7467), (6.0000, 15.3333, 8.7467), (7.3333, 15.3333, 8.7467), (7.3333, 16.6667, 8.7467).
- Line 1, glyph box of "W": font quad (−13, −10), (−13, −2), (−5, −2), (−5, −10) gives
  (0.3645833, 0.9375000, 0.5466667), (0.3645833, 0.8541667, 0.5466667), (0.4479167, 0.8541667, 0.5466667), (0.4479167, 0.9375000, 0.5466667) = px (5.8333, 15.0000, 8.7467), (5.8333, 13.6667, 8.7467), (7.1667, 13.6667, 8.7467), (7.1667, 15.0000, 8.7467).

Where it ends up: the board front face (south) is at z = 8.66667 px, so the quads are 0.08 px south of it, on the **south** side, reading **left to right in the +x direction** for a viewer on the south side looking north. The whole "Hello" line (24 font px) spans X 0.375 to 0.625 (px 6 to 10, 4 px wide) and the "World" line (27 font px) spans X 0.3645833 to 0.6458333 (px 5.8333 to 10.3333). The glyph cells sit inside the board's y range (px 9.33..17.33): line 0 cell px 15.33..16.67, line 1 cell px 13.67..15.00, line 3 cell down to px 10.33.

Check: line 0 top Y = 0.8333333 + 20/96 = 1.0416667; bottom = 0.8333333 + 12/96 = 0.9583333; X(−12) = 0.5 − 12/96 = 0.375; X(−4) = 0.5 − 4/96 = 0.4583333.

**Back side variant** (steps 1 to 6 with the extra rotation by 180 degrees before the text offset): Z = 0.5 − 0.0466667 = 0.4533333 (7.2533 px, 0.08 px north of the back face at 7.33333), X = 0.5 − s·fx, Y unchanged. The "H" box becomes (0.6250000, 1.0416667, 0.4533333), (0.6250000, 0.9583333, 0.4533333), (0.5416667, 0.9583333, 0.4533333), (0.5416667, 1.0416667, 0.4533333); the "W" box (0.6354167, 0.9375000, 0.4533333), (0.6354167, 0.8541667, 0.4533333), (0.5520833, 0.8541667, 0.4533333), (0.5520833, 0.9375000, 0.4533333). A viewer north of the sign (looking south) sees the text running left to right toward −x.

**Rotation 4 (angle 90, front toward west), front side, for the same "H" box**: X = 0.4533333 (7.2533 px), Z = 0.375, 0.375, 0.4583333, 0.4583333 for top-left, bottom-left, bottom-right, top-right (the text runs along +z), Y as above. **Rotation 8 (angle −180, front toward north)** gives the same four corners as the back side of rotation 0 listed above (the "H" box at X 0.625 and 0.5416667, Z = 0.4533333); the back side of rotation 8 is the front side of rotation 0.

### 10.2 Wall sign, facing north, front side

angle = 180 (`Direction.NORTH.toYRot()`). Pose: translate (0.5, 0.5, 0.5); rotate by −180; translate (0, −0.3125, −0.4375); translate (0, 0.33333334, 0.046666667); scale (s, −s, s). Rotation by −180 maps (x, z) to (−x, −z), so X = 0.5 − s·fx, Y = 0.5208333 − s·fy, Z = 0.5 + 0.4375 − 0.0466667 = 0.8908333 (14.2533 px).

- "H" box: (0.6250000, 0.7291667, 0.8908333), (0.6250000, 0.6458333, 0.8908333), (0.5416667, 0.6458333, 0.8908333), (0.5416667, 0.7291667, 0.8908333) = px (10.0000, 11.6667, 14.2533), (10.0000, 10.3333, 14.2533), (8.6667, 10.3333, 14.2533), (8.6667, 11.6667, 14.2533).
- "W" box: (0.6354167, 0.6250000, 0.8908333), (0.6354167, 0.5416667, 0.8908333), (0.5520833, 0.5416667, 0.8908333), (0.5520833, 0.6250000, 0.8908333) = px (10.1667, 10.0000, 14.2533), (10.1667, 8.6667, 14.2533), (8.8333, 8.6667, 14.2533), (8.8333, 10.0000, 14.2533).

The board for `facing = north` is at z 14.33333..15.66667 px (front = north face at 14.33333): the quads are 0.08 px north of the front; the text runs toward **−x** (a viewer on the north side looking south has west on his right). The glyph cells of the four lines span Y 0.3333..0.7292 against the board's 0.2708..0.7708.

**Back side variant**: the rotation of −180 followed by 180 cancels, the wall translation stays: X = 0.5 + s·fx, Y = 0.5208333 − s·fy, Z = 0.5 + 0.4375 + 0.0466667 = 0.9841667 (15.7467 px, 0.08 px south of the back face at 15.66667). "H" box (0.3750000, 0.7291667, 0.9841667), (0.3750000, 0.6458333, 0.9841667), (0.4583333, 0.6458333, 0.9841667), (0.4583333, 0.7291667, 0.9841667); "W" box (0.3645833, 0.6250000, 0.9841667), (0.3645833, 0.5416667, 0.9841667), (0.4479167, 0.5416667, 0.9841667), (0.4479167, 0.6250000, 0.9841667).

The other facings, "H" box of line 0, front side (the plane is 0.3908333 block from the block centre toward the wall, as in 4.2): `facing = south` (angle 0): Z = 0.1091667 (1.7467 px), X = 0.375 (left) to 0.4583333 (right), text runs toward +x; `facing = east` (angle 270): X = 0.1091667 (1.7467 px), Z = 0.625 at the left edge and 0.5416667 at the right edge, so the text runs toward −z; `facing = west` (angle 90): X = 0.8908333 (14.2533 px), Z = 0.375 at the left edge and 0.4583333 at the right edge, text runs toward +z. Y values are those of the north example (0.7291667 top, 0.6458333 bottom).

### 10.3 Ceiling hanging sign, rotation 0, one line

Line 0 = "Hello" (width 24), h = 9, font y origin −18, x origin −12. Pose: set translation (0.5, 0.9375, 0.5); rotate by 0; translate (0, −0.3125, 0); translate (0, −0.32, 0.073); scale (0.0140625, −0.0140625, 0.0140625). X = 0.5 + 0.0140625·fx, Y = 0.305 − 0.0140625·fy, Z = 0.573 (9.168 px).

"H" box: font quad (−12, −18), (−12, −10), (−4, −10), (−4, −18) gives (0.3312500, 0.5581250, 0.5730000), (0.3312500, 0.4456250, 0.5730000), (0.4437500, 0.4456250, 0.5730000), (0.4437500, 0.5581250, 0.5730000) = px (5.3000, 8.9300, 9.1680), (5.3000, 7.1300, 9.1680), (7.1000, 7.1300, 9.1680), (7.1000, 8.9300, 9.1680).

The board front (south) is at z = 9 px: 0.168 px in front, south side, text reading +x. Back side (rotate 180 before the offset): Z = 0.427 (6.832 px, 0.168 px north of the back face at 7 px), X = 0.5 − s·fx: "H" box (0.6687500, 0.5581250, 0.4270000), (0.6687500, 0.4456250, 0.4270000), (0.5562500, 0.4456250, 0.4270000), (0.5562500, 0.5581250, 0.4270000). The attached variant has identical numbers.

### 10.4 Wall hanging sign, facing north, one line

angle 180. Pose: set translation (0.5, 0.9375, 0.5); rotate by −180; translate (0, −0.3125, 0); translate (0, −0.32, 0.073); scale (0.0140625, −0.0140625, 0.0140625): X = 0.5 − 0.0140625·fx, Y = 0.305 − 0.0140625·fy, Z = 0.5 − 0.073 = 0.427 (6.832 px).

"H" box (line 0, "Hello"): (0.6687500, 0.5581250, 0.4270000), (0.6687500, 0.4456250, 0.4270000), (0.5562500, 0.4456250, 0.4270000), (0.5562500, 0.5581250, 0.4270000). With `facing=north` the block state turns the model by 180 degrees, so the board is at z 7..9 px still (the board is centred in the cell); the north face is at z = 7 px and the text is 0.168 px north of it, reading toward −x for a viewer on the north side. **Back side**: Z = 0.573 (south side), X = 0.5 + 0.0140625·fx: "H" box (0.3312500, 0.5581250, 0.5730000), (0.3312500, 0.4456250, 0.5730000), (0.4437500, 0.4456250, 0.5730000), (0.4437500, 0.5581250, 0.5730000).

### 10.5 A glowing example (colours only)

Red, glowing, standing sign, coloured outline drawn (camera 10 blocks away): fill `0xFFFF0000`, outline `0xFF660000`, light 15728880. The outline pass draws "Hello" at the eight offsets (±1, ±1 except (0, 0)) font px in `0xFF660000` in display mode normal, then the fill pass in `0xFFFF0000` in polygon offset. Black glowing: fill `0xFF000000`, outline `0xFFF0EBCC` always. Non-glowing white: fill `0xFF666666`.

## 11. Other facts

1. **Item form.** All 26 sign items (13 woods, standing sign and hanging sign) are the plain item definition `{"model": {"type": "minecraft:model", "model": "minecraft:item/<name>"}}` and the model `item/<name>` has the parent `minecraft:item/generated` with `layer0` = `minecraft:item/<name>`: a flat 16 × 16 sprite (`textures/item/<wood>_sign.png`, `<wood>_hanging_sign.png`) shaded with the `generated` display table (`gui_light` front). There is no special model, no 3D board and no text in the inventory. (Checked for all 26.) The wall variants have no item.
2. **The editor does not use this transform path.** `AbstractSignEditScreen`, `SignEditScreen` and `HangingSignEditScreen` draw in 2D GUI space with `Matrix3x2fStack` (scales 3.9 and 0.9765628 for signs, 4.5 for hanging signs; 40-8 §6.6). They share only `AbstractSignRenderer.getDarkColor`.
3. **Text on both sides in one pass.** One `submit` call draws the front text and then the back text, each in its own push/pop of the pose; there is no check of which side the viewer is on.
4. **Waxed and glowing.** Waxing has no render effect (section 2.2). Glowing changes the fill colour, adds the outline (section 6) and the light.
5. **Crumbling overlay.** The state carries the overlay of block breaking but the sign renderers ignore it; the board's crack overlay belongs to the chunk-mesh path (12).
6. **Line components.** A line is a Text Component; its styling (colour, bold, italic, underlined, strikethrough, obfuscated, font) affects the glyphs as in 12 §5.10. Click events do not affect the render.
7. **Facing and the pose tables are built once** (section 2.4): the float angle values are the constants of the table, not recomputed per frame.
8. **Block mesh lighting** of the board is the normal chunk mesher path (12, 43), with `ambientocclusion` false in every sign model.

## 12. Corrections to earlier documents

Each statement below was rewritten in place in the named document (not only pointed to) in the review round after this one.

| Document | Former statement | Reading in this round |
|---|---|---|
| 31-3 §2.11 | "the outline is drawn when the colour is not black or when the 'outline visible' flag is true"; "dark colour used for the non-glowing text outline" | The test is **colour is black, or the flag is true** (`drawOutline = (textColor == black's textColor) || state.drawOutline`, glowing text only): black glowing text always has its outline, other colours only near or while scoping (section 6.3). `dark(c)` is the **fill colour of non-glowing text** (which has no outline) and the **outline colour of glowing text** (section 6.1). Both bullets were rewritten. |
| 31-3 §2.4 | the centres for the other three facings "inferred; the facing-to-rotation mapping was not read, Open question 18" | read: the rotated boxes and centres of section 9 are now stated there; Open question 18 is closed (section 9). |
| 40-8 §6.1 step 3 and open question 4 | dye text colours "carry alpha 0"; black glowing preview colour "0x1E1B1B" | `DyeColor.textColor` is stored with alpha 0xFF (`ARGB.opaque`); black's text colour is 0x000000 (0xFF000000); 0x1E1B1B is black's firework colour (section 6.1). The alpha-0 font question (12 §5.10 open question 12) does not arise for sign text; open question 4 is closed. |
| 12 §5.10 | bitmap advance rule; italic shear "not traced" (open question 13) | the advance rule is confirmed (section 5.5; it also holds for `ascii.png`, scale 1); the bold thickness (0.1) and the italic shear amounts are read in section 6.5, and the Bold and Italic bullets and open question 13 of 12 §5.10 were rewritten in place (question 13 closed). The question of a text colour with alpha 0 stays open for other callers. |
| design/faithful-pack-mapping.md §9.6 | the jar "has sign textures only under `gui/signs/` and `gui/hanging_signs/`", so the pack's `entity/signs/*` look like an older location | the jar has the board textures at `textures/block/<wood>_sign.png` and `textures/block/<wood>_hanging_sign.png` (32 x 32, 13 woods; section 3.7); the pack's `entity/signs/*` files sit at a path this jar never loads. Guess removed. |

## 13. Open questions

1. **Cull mode and winding of the text pipelines.** The pipeline definitions read set shader, vertex format, blend and depth state, and none sets the face-culling flag (the builder's default `cull` was not read). Whether the quad winding of section 4.5 matters (front faces only) was not determined.
2. **Polygon-offset sign.** The depth state of `TEXT_POLYGON_OFFSET` is (compare greater-than-or-equal, write on, bias scale 1.0, bias constant 10.0); that the offset moves the fill toward the camera in this reversed-looking depth convention is inferred.
3. Closed. The model-file rotation sense: `CuboidRotation$SingleAxisRotation.transformation` builds a matrix with the joml `rotation(angle × 0.017453292, +Y axis)`, the same sense as the text's R_y(−angle) (a rotation of −22.5 maps the south normal to (−0.3827, 0, +0.9239), the front direction of text rotation 1), so board and text turn together (read).
4. **Glyphs outside the bitmap sheets.** `include/unifont` is an empty provider list in this jar; the missing-glyph shape and advance for code points defined by no provider were not read.
5. **Bidirectional text.** `Language.getVisualOrder` was not read; left-to-right identity is inferred for the default language.
6. **Lightmap, fog and colour modulator.** The shader multiplies by `sample_lightmap` and `ColorModulator` and applies fog; the lightmap values at (15, 15), the modulator value and the fog parameters were not traced.
7. **Glyph selection details.** Only the first-provider rule with the advance range 0..32 was read; the second "render source" of `FontSet$SelectedGlyphs` (used when an earlier glyph has a fishy advance) was not followed.
8. **Draw order inside the solid phase and the OIT variants.** The order of the text nodes against other solid geometry, the ordering of the two render types of the outline and fill passes inside the phase, and the order-independent-transparency pipeline variants of both text render types were not traced (the bias makes the fill win either way).
9. **Chain quad angles of `template_hanging_sign_rot_1..3`.** Section 3.4 gives the pattern and the three-axis form of rot_3 but not an exhaustive per-quad table (the files are the source).
10. **`Style` shadow colour on a sign line** (section 6.5): the creation of the shadow quad was read; whether any normal sign content can set it (a component with a shadow colour) was not checked.
11. **Placement rule of the hanging sign `attached` property** (section 3.5) is owned by the block documents; it is repeated here from `CeilingHangingSignBlock.getStateForPlacement` only as far as the bytes were read (the forced-false condition for a hanging sign above).
12. **Wall hanging sign hit-box centre** is the base constant (0.5, 0.5, 0.5) although its shape is a plank plus board (51 R-C9): the class does not override the method (read), nothing else was assumed.
13. Closed. Renderer registration pairing: `SIGN` is registered with the `StandingSignRenderer` constructor and `HANGING_SIGN` with the `HangingSignRenderer` constructor (read from the invokedynamic call sites and the bootstrap method table of `BlockEntityRenderers`, section 2.1).
