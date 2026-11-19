# 12 Client rendering behaviour

This document gives the numbers an implementer needs to make a client look finished: block lighting, texture
sampling, sky and fog, the break-crack overlay, the GUI, the first-person hand, the camera modes, the player model and
item drawing. It describes what the reference client does. CobolCraft may implement a simplified subset; where this
text says "the reference client" it is describing the artifact and not requiring the behaviour.

| Item | Value |
|---|---|
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3. This is the artifact already recorded in [README.md](README.md). |
| Method | Static reading of the shipped bytecode (`javap`), and of the text assets in the same jar (GLSL shaders under `assets/minecraft/shaders`, JSON under `data/minecraft` and `assets/minecraft`), with no execution. For the hand-pose additions (6.7 to 6.14, 8.5, 8.6, V21 to V26) also the pixel data of `textures/item/wooden_pickaxe.png` and the sizes of the shield textures; worked numbers there were computed by hand-written matrix arithmetic from the constants read |
| Related | [08-resource-packs.md](08-resource-packs.md) (pack format, models, atlases, block states), [06-chunk-format.md](06-chunk-format.md) (light data), [05a-play-clientbound-00-71.md](05a-play-clientbound-00-71.md) (Block Destruction), [04-registry-sync.md](04-registry-sync.md) (registries and ids), [18-mob-framework.md](18-mob-framework.md) (ground items), [../design/standin-content.md](../design/standin-content.md) (content of the cobolcraft world type only) |

Conventions in this document:

- Class names in backticks say where a fact was read. They are provenance, not design.
- Colours are written `#rrggbb` (or `#aarrggbb` where an alpha is part of the value). A colour used as a shader
  input is the same number divided by 255 per channel.
- "Linear interpolation" of a colour means componentwise linear interpolation of the 0..1 channel values as stored, with no
  sRGB conversion (`ARGB.srgbLerp` does exactly this despite its name), unless a section says otherwise.
- Directions: DOWN = −y, UP = +y, NORTH = −z, SOUTH = +z, WEST = −x, EAST = +x.
- Values the reference client derives from data (timelines, dimension attributes, biome attributes) are listed here in
  the form the 26.3 data files give them. A CobolCraft server decides what it sends; a CobolCraft client decides what
  it implements. Section 3.1 says which attributes exist and how they combine so either side can choose its own values.

Sections: 0 Resolved: the rules apply to both world types. 1 Block lighting. 2 Texture atlas sampling. 3 Sky, fog and clouds. 4 Block-break crack overlay.
5 The GUI. 6 First-person hand and item (6.7 to 6.14: the complete matrix chain, the item mesh, the hand pass projection and
render state, shading, block items, the shield, use-animation dispatch, and a checklist of what makes a naive client look
scrambled). 7 Third-person camera and the player model. 8 Item and block-in-hand
rendering (8.5 to 8.6: from item definition to quads, shading by context). 9 Validation (V21 to V26: worked numbers for the held pickaxe, the held block and the shield). 10 Open questions.

---

## 0. Resolved: the rules apply to both world types

This document describes the reference client. The game has two world types (the standard world type and the cobolcraft
world type; see [../design/README.md](../design/README.md), rules R1 and R2). The rendering rules of this document are
shared standard rules and apply in **both** world types: the world type selects the content set (blocks, items, mobs,
textures), not how light, sky, fog and the GUI are computed. Earlier drafts listed four decision points against
[standin-content.md](../design/standin-content.md); they are resolved as follows.

| Decision | Resolution |
|---|---|
| D1 light map | Adopt the formula of §1.8. The per-face directional factors of §1.1 (top 1.0, north and south 0.8, east and west 0.6, bottom 0.5) are the same numbers as the fixed table that standin-content §1.4.2 gave, so they agree; §1.2 to §1.7 (smooth lighting, shade of a block) refine them. |
| D2 sky model | Adopt §3: the sky, fog and clouds come from the environment attributes and the timeline of the dimension type (04, EnvironmentAttributeMap and the `timeline` registry). The simplified sky colours of standin-content §4.8 are retired. |
| D3 day length | The day is 24000 ticks, the `period_ticks` of the reference timeline (3.2, 3.2c), in both world types. |
| D4 night definition | The reference tracks of 3.2 apply: the sky darkens between about 11270 and 13140, stays dark until 22860 and brightens again until 24730 (730 of the next day), in a 24000-tick cycle. |

Sections that standin-content did not cover (§2 textures, §4 crack overlay, §5 GUI, §6 first-person hand, §7 camera and
model, §8 items) apply when a client implements the corresponding feature, subject to the pack rules in 08 and 14.

---

## 1. Block lighting

Source: `ModelBlockRenderer`, `BlockModelLighter` (and its nested `AdjacencyInfo`, `SizeInfo`, `AmbientVertexRemap`,
`Cache`), `LightCoordsUtil`, `CardinalLighting`, `LightmapRenderStateExtractor`, shaders `terrain.vsh`, `terrain.fsh`,
`lightmap.fsh`, `include/sample_lightmap.glsl`.

A block face is lit by three multiplications on its vertex colour:

1. **Directional brightness** (section 1.1), the same for the whole face.
2. **Ambient occlusion shade** per vertex (section 1.3), or a flat 1.0 when smooth lighting is not used.
3. **Light map** value looked up per vertex from a (block light, sky light) pair (sections 1.4, 1.5). The pair is
   per vertex and is smoothed when ambient occlusion is on.

The terrain vertex shader multiplies `vertexColor = Color × lightmap(UV2)` where `Color` already contains the
directional brightness, the AO shade (as a grey) and any biome tint. The fragment shader multiplies by the texture
sample, then applies fog (section 3.3).

### 1.1 Per-face directional brightness (`CardinalLighting`)

The factor that multiplies a face's colour depends on the face's direction (the direction the quad faces after any
model rotation, or the quad's `shade direction override` if the model sets one). Two tables exist, chosen by the
dimension type's `cardinal_light` field (`default` or `nether`, 04 §dimension_type):

| Face | `default` | `nether` |
|---|---|---|
| DOWN | 0.5 | 0.9 |
| UP | 1.0 | 0.9 |
| NORTH | 0.8 | 0.8 |
| SOUTH | 0.8 | 0.8 |
| WEST | 0.6 | 0.6 |
| EAST | 0.6 | 0.6 |

A model element with `shade: false` (08 §5.4) skips this factor and uses 1.0 (inferred from the model schema; the
lighter itself only reads the table through the quad's flag).

### 1.2 Which blocks use smooth lighting (ambient occlusion)

`ModelBlockRenderer.tesselateBlock` renders a block's quads with the smooth (ambient occlusion) path when all of
these hold: the user option `ambientOcclusion` is on (default on), the block state's light emission is 0, and the
model's first part has ambient occlusion enabled (the model key `ambientocclusion`, default true). Otherwise it uses the
flat path (section 1.6).

Faces are skipped before lighting when the face has a `cullface` and the neighbouring block hides it (`Block.shouldRenderFace`).
Neighbour hiding rules are in 08 and are not repeated.

### 1.3 Smooth lighting algorithm (`BlockModelLighter.prepareQuadAmbientOcclusion`)

Inputs per quad: the block position P, the quad's face direction F, and the quad's bounding box inside the block.
Outputs: for each of the quad's 4 vertices, one shade value (0..1, applied as a grey multiplier) and one light
coordinate pair (block, sky).

**Step 1: the face shape flags.** Take the minimum and maximum x, y and z over the quad's 4 vertices (block-local 0..1 units): minX, minY, minZ, maxX, maxY, maxZ.

- `facePartial` is true unless the quad covers the whole face area in the two axes perpendicular to F. For F = DOWN or UP the quad is "full" when minX < 1e-4, minZ < 1e-4, maxX > 0.9999 and maxZ > 0.9999. For NORTH or SOUTH the same test uses x and y. For WEST or EAST it uses y and z.
- `faceCubic` is true when the quad is flat in its own axis and either sits on the block boundary or the block is a full cube. Per direction:

| F | flat test | boundary test | `faceCubic` |
|---|---|---|---|
| DOWN | minY == maxY | minY < 1e-4 | flat and (boundary or the block's collision shape is a full block) |
| UP | minY == maxY | maxY > 0.9999 | same |
| NORTH | minZ == maxZ | minZ < 1e-4 | same |
| SOUTH | minZ == maxZ | maxZ > 0.9999 | same |
| WEST | minX == maxX | minX < 1e-4 | same |
| EAST | minX == maxX | maxX > 0.9999 | same |

**Step 2: the sampling base.** The *base cell* B is the neighbour of P in direction F when `faceCubic`, else P itself.

**Step 3: samples.** The 4 *edge directions* for F are given by `AdjacencyInfo` (this table is the corner list):

| F | edge directions c0, c1, c2, c3 | Face direction factor stored in `AdjacencyInfo` (not used for output; the output uses 1.1) |
|---|---|---|
| DOWN | WEST, EAST, NORTH, SOUTH | 0.5 |
| UP | EAST, WEST, NORTH, SOUTH | 1.0 |
| NORTH | UP, DOWN, EAST, WEST | 0.8 |
| SOUTH | WEST, EAST, DOWN, UP | 0.8 |
| WEST | UP, DOWN, NORTH, SOUTH | 0.6 |
| EAST | DOWN, UP, NORTH, SOUTH | 0.6 |

For i in 0..3 sample the cell E_i = B + c_i: its *light coordinate* L_i (section 1.7) and its *shade* S_i (section 1.8).

Then for each of the four corner cells decide whether the diagonal cell is used. Let T_i be true when the cell
B + c_i + F (the cell one step further out in the face direction, beyond the edge cell) is *light permeable*
(`BlockState.isLightPermeable`: not (opaque full-render block with light dampening ≠ 0)). The four diagonal cells are:

| Diagonal | cell | Used if | Otherwise |
|---|---|---|---|
| D02 | B + c0 + c2 | T2 or T0 | copy S0 and L0 |
| D03 | B + c0 + c3 | T3 or T0 | copy S0 and L0 |
| D12 | B + c1 + c2 | T2 or T1 | copy S1 and L1 |
| D13 | B + c1 + c3 | T3 or T1 | copy S1 and L1 |

(When the diagonal is "used" its S and L come from sampling that cell. When both blocking conditions hold, the
diagonal is replaced by edge cell c0 or c1 respectively, which prevents light leaking through a diagonal gap and
produces the standard dark inner corner.)

The *centre* sample C: L_C = light coordinate of cell P+F **if** (`faceCubic` or the cell P+F is not a solid-render block), else
light coordinate of P itself. S_C = shade of cell P+F when `faceCubic`, else the shade of P.

**Step 4: the four corner groups.** Define 4 groups; each averages a centre, two edge cells and one diagonal:

| Group | shade members | light members (in `smoothBlend` argument order) |
|---|---|---|
| g0 | S3, S0, D03, S_C | L3, L0, LD03, L_C |
| g1 | S2, S0, D02, S_C | L2, L0, LD02, L_C |
| g2 | S2, S1, D12, S_C | L2, L1, LD12, L_C |
| g3 | S3, S1, D13, S_C | L3, L1, LD13, L_C |

**Step 5: full faces (`facePartial` is false).** (`AdjacencyInfo` carries a flag `doNonCubicWeight` that is true for all six directions, so the weighted path of step 6 is taken exactly when `facePartial` is true.) The shade of group g is the arithmetic mean of its four shade members. The
light coordinate of the group is `LightCoordsUtil.smoothBlend` of its light members (section 1.7).

**Step 6: partial faces (`facePartial`).** The group values from step 4 are first computed as in step 5. Then the
vertex value is a weighted sum: each of the 4 groups g contributes with weight w_g, where weights depend on the position
of the vertex within the block face. For vertex v the 4 weights are products of 2 of the 12 `faceShape` values
(table 1.3b; the table columns are the output slots 0..3 of step 7, so slot k is the vertex that group gk is assigned to). The shade of the vertex is the sum of the four (weight × group shade), clamped to 0..1. The vertex light
is `smoothWeightedBlend(L_g0..L_g3, w0..w3)` (section 1.7).

**Step 7: assign groups to vertices.** Group gi goes to the quad vertex given by the remap table
(`AmbientVertexRemap`). The vertex numbering is the baked-quad vertex order of 1.3c.

| F | g0 → vertex | g1 → vertex | g2 → vertex | g3 → vertex |
|---|---|---|---|---|
| DOWN | 0 | 1 | 2 | 3 |
| UP | 2 | 3 | 0 | 1 |
| NORTH | 3 | 0 | 1 | 2 |
| SOUTH | 0 | 1 | 2 | 3 |
| WEST | 3 | 0 | 1 | 2 |
| EAST | 1 | 2 | 3 | 0 |

**Step 8.** Finally the vertex colours are multiplied by the directional brightness of 1.1. The shade is applied as
colour (shade, shade, shade); the light coordinates go to the vertex's light attribute.

#### 1.3b Partial-face weights

`faceShape` has 12 entries indexed by `SizeInfo`: 0 DOWN = min y, 1 UP = max y, 2 NORTH = min z, 3 SOUTH = max z,
4 WEST = min x, 5 EAST = max x, 6 FLIP_DOWN = 1 − min y (stored as 1 − value), 7 FLIP_UP = 1 − max y, 8 FLIP_NORTH = 1 − min z,
9 FLIP_SOUTH = 1 − max z, 10 FLIP_WEST = 1 − min x, 11 FLIP_EAST = 1 − max x. (The `faceShape` values are the quad's block-local
extents.) For quad vertex output slot k (k = 0..3, the g-groups of step 4 with their vertex assignment), the weight of group
j is the product of four pairs, written below as the pairs of `faceShape` indices (a,b) meaning `faceShape[a] × faceShape[b]`.
In `AdjacencyInfo` each of the 4 output vertices has 8 `SizeInfo` entries, grouped as 4 pairs; the pairs are the weights of
the groups g0, g1, g2, g3 in this order.

| F | slot 0 weights (for g0, g1, g2, g3) | slot 1 | slot 2 | slot 3 |
|---|---|---|---|---|
| DOWN | (FLIP_WEST,SOUTH), (FLIP_WEST,FLIP_SOUTH), (WEST,FLIP_SOUTH), (WEST,SOUTH) | (FLIP_WEST,NORTH), (FLIP_WEST,FLIP_NORTH), (WEST,FLIP_NORTH), (WEST,NORTH) | (FLIP_EAST,NORTH), (FLIP_EAST,FLIP_NORTH), (EAST,FLIP_NORTH), (EAST,NORTH) | (FLIP_EAST,SOUTH), (FLIP_EAST,FLIP_SOUTH), (EAST,FLIP_SOUTH), (EAST,SOUTH) |
| UP | (EAST,SOUTH), (EAST,FLIP_SOUTH), (FLIP_EAST,FLIP_SOUTH), (FLIP_EAST,SOUTH) | (EAST,NORTH), (EAST,FLIP_NORTH), (FLIP_EAST,FLIP_NORTH), (FLIP_EAST,NORTH) | (WEST,NORTH), (WEST,FLIP_NORTH), (FLIP_WEST,FLIP_NORTH), (FLIP_WEST,NORTH) | (WEST,SOUTH), (WEST,FLIP_SOUTH), (FLIP_WEST,FLIP_SOUTH), (FLIP_WEST,SOUTH) |
| NORTH | (UP,FLIP_WEST), (UP,WEST), (FLIP_UP,WEST), (FLIP_UP,FLIP_WEST) | (UP,FLIP_EAST), (UP,EAST), (FLIP_UP,EAST), (FLIP_UP,FLIP_EAST) | (DOWN,FLIP_EAST), (DOWN,EAST), (FLIP_DOWN,EAST), (FLIP_DOWN,FLIP_EAST) | (DOWN,FLIP_WEST), (DOWN,WEST), (FLIP_DOWN,WEST), (FLIP_DOWN,FLIP_WEST) |
| SOUTH | (UP,FLIP_WEST), (FLIP_UP,FLIP_WEST), (FLIP_UP,WEST), (UP,WEST) | (DOWN,FLIP_WEST), (FLIP_DOWN,FLIP_WEST), (FLIP_DOWN,WEST), (DOWN,WEST) | (DOWN,FLIP_EAST), (FLIP_DOWN,FLIP_EAST), (FLIP_DOWN,EAST), (DOWN,EAST) | (UP,FLIP_EAST), (FLIP_UP,FLIP_EAST), (FLIP_UP,EAST), (UP,EAST) |
| WEST | (UP,SOUTH), (UP,FLIP_SOUTH), (FLIP_UP,FLIP_SOUTH), (FLIP_UP,SOUTH) | (UP,NORTH), (UP,FLIP_NORTH), (FLIP_UP,FLIP_NORTH), (FLIP_UP,NORTH) | (DOWN,NORTH), (DOWN,FLIP_NORTH), (FLIP_DOWN,FLIP_NORTH), (FLIP_DOWN,NORTH) | (DOWN,SOUTH), (DOWN,FLIP_SOUTH), (FLIP_DOWN,FLIP_SOUTH), (FLIP_DOWN,SOUTH) |
| EAST | (FLIP_DOWN,SOUTH), (FLIP_DOWN,FLIP_SOUTH), (DOWN,FLIP_SOUTH), (DOWN,SOUTH) | (FLIP_DOWN,NORTH), (FLIP_DOWN,FLIP_NORTH), (DOWN,FLIP_NORTH), (DOWN,NORTH) | (FLIP_UP,NORTH), (FLIP_UP,FLIP_NORTH), (UP,FLIP_NORTH), (UP,NORTH) | (FLIP_UP,SOUTH), (FLIP_UP,FLIP_SOUTH), (UP,FLIP_SOUTH), (UP,SOUTH) |

Reading the table: each slot has 8 `SizeInfo` entries in `AdjacencyInfo`; entries (0,1), (2,3), (4,5), (6,7) are four pairs, the weight of the group g0..g3 is the product `faceShape[first] × faceShape[second]` of its pair, the vertex shade is the sum over the four groups of (weight × group shade) clamped to 0..1, and the vertex light is `smoothWeightedBlend(blend(g0), blend(g1), blend(g2), blend(g3), w0, w1, w2, w3)`, with blend(gk) = `smoothBlend` of the group's four light members. All of this (table entries, pairing, products, group order, and which output vertex each slot writes) was read directly from the bytecode; none of it is inferred.

#### 1.3c Baked quad vertex order (`FaceInfo`)

The vertex index used by step 7 is the order in which the baked quad lists its corners, fixed per face direction. The
corner is named by which extent of the element it uses on each axis:

| F | vertex 0 | vertex 1 | vertex 2 | vertex 3 |
|---|---|---|---|---|
| DOWN | (min x, min y, max z) | (min x, min y, min z) | (max x, min y, min z) | (max x, min y, max z) |
| UP | (min x, max y, min z) | (min x, max y, max z) | (max x, max y, max z) | (max x, max y, min z) |
| NORTH | (max x, max y, min z) | (max x, min y, min z) | (min x, min y, min z) | (min x, max y, min z) |
| SOUTH | (min x, max y, max z) | (min x, min y, max z) | (max x, min y, max z) | (max x, max y, max z) |
| WEST | (min x, max y, min z) | (min x, min y, min z) | (min x, min y, max z) | (min x, max y, max z) |
| EAST | (max x, max y, max z) | (max x, min y, max z) | (max x, min y, min z) | (max x, max y, min z) |

Element and variant rotations (08 §5.4, §4.3) rotate the geometry; the lighter works from the quad's final face direction and
its final vertex positions, so a rotated element is lit as the face it ends up facing. The per-vertex
association follows the final quad's vertex slots (the shape flags use min/max over all four positions).

**Quad triangulation.** The lighter has no rule that flips the quad's diagonal according to the AO values. No
"flip when the sums differ" rule exists in `BlockModelLighter`. Quads are drawn from the sequential quad index buffer; of the
two index generators in `RenderSystem$AutoStorageIndexBuffer` the quad one emits triangles (0,1,2) and (2,3,0)
(inferred which of the two generators the terrain pipeline selects; the other emits (0,1,2) and (3,2,1)). An implementer
may use the vertex 0–2 diagonal.

### 1.4 Light coordinates and the light-map index

A *light coordinate* packs two levels: `pack(block, sky) = block << 4 | sky << 20` (block and sky are 0..15). Helper
accessors (`LightCoordsUtil`): `block(c) = (c >> 4) & 15`, `sky(c) = (c >> 20) & 15`. `FULL_BRIGHT` = 15728880 (block 15, sky 15). `FULL_SKY` = 15728640 (sky 15, block 0).

The light of a block position for rendering (`LightCoordsUtil.getLightCoords(BrightnessGetter, getter, state, pos)`):

- If the block state has `emissiveRendering`, the result is `FULL_BRIGHT`.
- Otherwise take the stored packed brightness of the position (block level and sky level from the light data of
  06 §7). If the state's light emission is greater than the stored block level, replace the block level by the emission.

Smooth lighting uses a second "smooth" packing in which each level has 4 extra fractional bits: `smoothBlock(c) = c & 255`
(block level × 16), `smoothSky(c) = (c >> 16) & 255` (sky level × 16), `smoothPack(block, sky) = (block & 255) | (sky & 255) << 16`.
Each level uses 0..240 (15 × 16). The vertex shader receives these two numbers as the vertex light attribute `UV2`.

### 1.5 `smoothBlend` and `smoothWeightedBlend`

`smoothBlend(a, b, c, d)` combines the four light coordinates of a group, with d the centre sample:

1. If `sky(d) > 2` or `block(d) > 2`: for each of a, b and c in turn: if the value is exactly 0 (a position with no light, such as inside
   an opaque block) replace it by d; else if `sky(value) == 0`, replace its sky bits by those of d (value |= d & 0xFF0000, the whole smooth sky field, bits 16–23).
   If both `sky(d) <= 2` and `block(d) <= 2` this repair is skipped.
2. Result = `((a + b + c + d) >> 2) & 0x00FF00FF`. This averages the four packed numbers: the block level ends up in
   bits 0–7 and the sky level in bits 16–23, each as level × 16 plus a fraction, which is the smooth packing above.

`smoothWeightedBlend(a, b, c, d, wa, wb, wc, wd)` (partial faces): sky = trunc(smoothSky(a)·wa + smoothSky(b)·wb + smoothSky(c)·wc + smoothSky(d)·wd);
block likewise; result `smoothPack(block, sky)`. (No zero repair; the arguments are the four already-blended groups of step 4.)

### 1.6 Flat lighting path

When smooth lighting is not used (`prepareQuadFlat`): the whole quad gets one light coordinate and no AO. The light
coordinate is that of the neighbouring cell P+F when the quad is `faceCubic`, else that of P itself (computed with
the same `getLightCoords`, then `pack` form); the colour is grey = the directional brightness (1.1). A caller may
supply a fixed light value instead (used by blocks with their own light, e.g. block entities). The flat path uses the packed (not smooth)
format: levels 0..15 exactly.

### 1.7 Shade of a block ("shade brightness")

`BlockState.getShadeBrightness` returns **0.2** if the block's collision shape is a full block, else **1.0** (`Block.getShadeBrightness`).
Overrides read (a search of every class in the jar that defines `getShadeBrightness`; this list is complete): `TransparentBlock` 1.0 (inherited by its subclasses, among them `StainedGlassBlock`, `TintedGlassBlock` and `WaterloggedTransparentBlock`), `LightBlock` 1.0, `BarrierBlock` 1.0, `StructureVoidBlock` 1.0,
`MudBlock` 0.2, `SoulSandBlock` 0.2, and `SnowLayerBlock`: 0.2 when its `layers` property equals 8, else 1.0. Which block uses which class is part of the block registry (04 §5 and 24-block-registry-1-model-and-foundation.md with its series 24-block-registry-2 to -8 for the standard world type, and standin-content §1 for the cobolcraft world type); the lighter only calls the method. The shade of an air cell is 1.0 (`Block` default: not a full collision shape).

### 1.8 The light map texture

The light map is a 16 × 16 texture computed by `lightmap.fsh` and rebuilt whenever the inputs change (every client
tick, since block-light flicker changes each tick). Texel (x, y) holds the colour for block level x and sky level y.
The terrain shader samples it with the smooth vertex value: `uv = clamp(UV2 / 256 + 0.5/16, 0.5/16, 15.5/16)` with
`UV2 = (smoothBlock, smoothSky)`. The sampler is bilinear (inferred; this is what gives smooth
fractional levels), so a smooth value of 120 (level 7.5) falls between texels 7 and 8.

Computation per texel, with

- block_level = x / 15, sky_level = y / 15 (the shader uses `floor(texCoord × 16) / 15`);
- `get_brightness(l) = l / (4 − 3 l)` (this is 0 at 0 and 1 at 1; it is the light curve);
- `BlockFactor`, `SkyFactor`, `NightVisionFactor`, `DarknessScale`, `BossOverlayWorldDarkeningFactor`, `BrightnessFactor`
  and the colours `BlockLightTint`, `SkyLightColor`, `AmbientColor`, `NightVisionColor` from table 1.8b:

1. block_b = get_brightness(block_level) × BlockFactor; sky_b = get_brightness(sky_level) × SkyFactor.
2. color = max(AmbientColor, NightVisionColor × NightVisionFactor), componentwise.
3. color += SkyLightColor × sky_b.
4. mixf = 0.9 × (2·block_level − 1)²; BlockLightColor = lerp(BlockLightTint, (1,1,1), mixf); color += BlockLightColor × block_b.
5. color = lerp(color, color × (0.7, 0.6, 0.6), BossOverlayWorldDarkeningFactor).
6. color −= DarknessScale (all three channels).
7. color = clamp(color, 0, 1).
8. `notGamma`: m = max(r, g, b); s = 1 − (1 − m)⁴; ng = color × (s / m). (If m = 0 the result is 0.)
9. color = lerp(color, ng, BrightnessFactor). Alpha = 1.

So the "brightness" option (called gamma in the client, default 0.5, range 0..1) controls how strongly the dark levels
are lifted: 0 leaves the raw value, 1 uses the fully lifted curve.

#### 1.8b Inputs to the light map

Extracted each frame by `LightmapRenderStateExtractor.extract` (values re-extracted when `needsUpdate`, which is set every tick):

| Input | Value |
|---|---|
| BlockFactor | 1.4 + `blockLightFlicker`. The flicker is a per-client-tick random walk: flicker += (r1 − r2) × r3 × r4 × 0.1, then flicker *= 0.9 (r1..r4 four successive `nextFloat()` draws; an unseeded random source). It stays near 0. |
| BlockLightTint | environment attribute `visual/block_light_tint`, default `#ffd88c` (1.0, 0.847, 0.549) |
| SkyFactor | environment attribute `visual/sky_light_factor` (default 1.0). When the dimension has an end flash, plus the flash intensity (÷ 3 when a boss bar makes world fog). |
| SkyLightColor | attribute `visual/sky_light_color`, default `#ffffff` |
| AmbientColor | attribute `visual/ambient_light_color`, default `#000000` |
| NightVisionColor | attribute `visual/night_vision_color`, default `#999999` |
| NightVisionFactor | the player's Night Vision effect: `nightVisionScale` = 1.0 while the effect has more than 200 ticks left, else 0.7 + 0.3 × sin((remainingTicks − partialTick) × π × 0.2) (a flash during the last 10 seconds); else the player's "water vision" value when the player has Conduit Power and water vision > 0; else 0 |
| BrightnessFactor | max(0, gamma − B), where B = (the player's Darkness effect blend factor) × (the option `darknessEffectScale`) |
| DarknessScale | max(0, cos((tickCount − partialTick) × π × 0.025) × 0.45 × B) × (the option `darknessEffectScale`). B already contains the option once (it is the value passed into the helper `calculateDarknessScale`, which multiplies it by 0.45), and the helper's result is multiplied by the option again; so the option enters this term twice (read from `LightmapRenderStateExtractor.extract`: the same local, blend × option, is the argument of the helper and of the `BrightnessFactor` subtraction, and the helper's result is then multiplied by the option) |
| BossOverlayWorldDarkeningFactor | lerp of the boss-bar world-darkening value from the previous to the current frame (0 with no darkening boss bar) |

The environment attributes come from section 3.1. In the overworld the attribute values over a day are the timeline
tracks in 3.2: sky_light_factor 1.0 by day and 0.24 at night; sky_light_color white by day and `#7a7aff` at night;
ambient_light_color `#0a0a0a`. Nether: `#302821` ambient, sky_light_factor 0. End: `#3f473f` ambient, `#ac60cd` sky light colour, factor 0.

### 1.9 Entity, item and GUI lighting (non-block)

Entities, held items and GUI items use a two-light diffuse formula (`include/light.glsl`) rather than the face table:
`light = min(1, (max(0, n·L0) + max(0, n·L1)) × 0.6 + 0.4)`, colour × light, where n is the surface normal in the space the
light directions are given in. The light directions (`Lighting`) are:

| Setup | L0 | L1 | Space |
|---|---|---|---|
| LEVEL, default dimension | normalize(0.2, 1.0, −0.7) | normalize(−0.2, 1.0, 0.7) | world |
| LEVEL, nether | normalize(0.2, 1.0, −0.7) | normalize(−0.2, −1.0, 0.7) | world |
| ENTITY_IN_UI, PLAYER_SKIN (inventory entity preview) | normalize(0.2, −1.0, 1.0) | normalize(−0.2, −1.0, 0.0) | view |
| ITEMS_FLAT | the default pair rotated by Ry(−0.3927 rad) then Rx(2.3562 rad) | same rotation | GUI |
| ITEMS_3D | the default pair transformed by scale(1, −1, 1), then rotateYXZ(1.0821, 3.2376, 0), then rotateYXZ(−0.3927, 2.3562, 0) | same | GUI |

Item and entity vertices are additionally multiplied by the light map using the entity's light coordinate (full
bright in the GUI: the `UiLightmap`). **In the GUI** a flat item (a tool: an extruded sprite, 6.8, not a single quad) is drawn
with `ITEMS_FLAT` and its front face appears unshaded; a 3D block item uses `ITEMS_3D`, which gives the three visible faces
different brightness (see section 8). **A held item in the first-person hand pass is not lit with either of these.** It uses
the `LEVEL` pair of the table above, and its normals are in world orientation (the camera rotation is removed from them, 6.7.2),
so a held tool or block is shaded by the sky-light direction and the shade changes with the camera yaw and pitch (6.10).

---

## 2. Texture atlas sampling

Source: `SpriteLoader`, `Stitcher`, `TextureAtlasSprite`, `SpriteContents`, `MipmapGenerator`, `MipmapStrategy`, `TextureFilteringMethod`,
`LevelRenderer` (chunk-layer sampler), `Options`, shaders `terrain.fsh`, `include/texture_sampling.glsl`,
`animate_sprite.vsh`, `animate_sprite_blit.fsh`.

### 2.1 Options that matter

| Option | Range / values | Default |
|---|---|---|
| `mipmapLevels` | 0–4 | 4 |
| `textureFiltering` (`TextureFilteringMethod`) | NONE (id 0), RGSS (id 1), ANISOTROPIC (id 2) | RGSS (inferred from the constructor's default id 1) |
| `maxAnisotropyBit` | 1–3; the sampler value is 2^bit (inferred) | 2 (so 4×, inferred) |
| `biomeBlendRadius` | 0–7 | 2 |
| `ambientOcclusion` | boolean | true |

### 2.2 Atlas packing and padding (`Stitcher`)

Each sprite is stitched into the atlas with a border of padding on all four sides so that bilinear and mipmapped sampling cannot read
a neighbouring sprite.

- Let M = the atlas mip level used = min(option `mipmapLevels`, log2 of the smallest sprite dimension, taking the lowest set bit of each sprite's width and height).
- Let A = the anisotropy bit: 0 when the filtering method is not ANISOTROPIC, else the `maxAnisotropyBit` option.
- **padding = (1 << M) << clamp(A − 1, 0, 4)** pixels on each side of every sprite.
- A sprite of w × h occupies a slot of (w + 2·padding) × (h + 2·padding), each dimension rounded up to a multiple of 2^M.
- With defaults (M = 4, no anisotropy): padding = 16 pixels. With ANISOTROPIC at bit 2: 32 pixels.
- The sprite's UV rectangle is the inner w × h area: u0 = (x + padding) / atlasWidth, u1 = (x + padding + w) / atlasWidth, and
  likewise v.

The padding is filled by drawing the sprite into its slot with the slot extended by `padding / size` beyond the 0..1 range
(`animate_sprite.vsh`: `texCoord = uv + padding × (2·uv − 1)`), sampling the sprite texture at the given mip level
(`textureLod`, `animate_sprite_blit.fsh`). With a clamp-to-edge sprite sampler (inferred) this repeats the sprite's edge
pixels outward. Each atlas mip level is produced the same way from the matching level of the sprite's own mip chain.

### 2.3 Mip chain generation (`MipmapGenerator`)

Each sprite has its own chain of up to M extra levels; level n+1 is half the size of level n.

- Each output pixel is the mean of a 2 × 2 block of the previous level. Colour channels are averaged in linear light
  (convert each sRGB channel to linear using a lookup table, average, convert back; `ARGB.meanLinear`); alpha is the
  integer mean (sum / 4).
- `MipmapStrategy` (from the texture's `.mcmeta`, 08 §7.4, default `auto`): `auto` means `cutout` when the texture has any
  transparent pixel and `mean` otherwise. `cutout` and `strict_cutout` first make fully transparent pixels in level 0 take
  neighbouring colour (`TextureUtil.solidify`), and after generating each level rescale the alpha so the fraction of pixels above the alpha
  cutoff stays equal to level 0's (alpha test coverage); the cutoff is 0.5 for `cutout` and 0.3 for `strict_cutout`.
  `dark_cutout` fills empty areas with a dark colour instead and uses a darkening alpha blend. `mean` does none of this.
- A sprite whose name starts with `item/` and that has only one level skips the solidify step (inferred from the prefix test).

### 2.4 The chunk-layer sampler and the shader

The terrain sampler (`LevelRenderer.chunkLayerSampler`) uses clamp-to-edge addressing in both axes, linear
minification and magnification, and the anisotropy value 2^bit when the method is ANISOTROPIC, else 1. It is
recreated when options change.

`terrain.fsh` then samples in one of two ways, chosen by the uniform `UseRgss` (1 when the method is RGSS):

- **Nearest-with-edge-blend (`sampleNearest`)**. This makes texels look crisp (nearest-neighbour) while hiding aliasing. Let
  the UV in texel units be t = uv / pixelSize. Compute the texel centre c = round(t) − 0.5 and the offset o = t − c.
  Shrink the offset towards the centre by the on-screen size of a texel: o' = clamp((o − 0.5) × pixelSize / texelScreenSize + 0.5, 0, 1),
  where texelScreenSize = sqrt(dFdx(uv)² + dFdy(uv)²) per axis. The sample is `textureGrad` at (c + o') × pixelSize using the original
  derivatives. When a texel covers many screen pixels, o' is clamped to 0 or 1 and the look is pure nearest; when a texel is smaller than a pixel, o' = 0.5
  and the result is the box-filtered mip sample.
- **RGSS** (rotated grid super-sampling): compute the exact mip level = max(0, log2(sqrt(minDerivative × maxDerivative) / min(pixelSize)));
  take 4 samples at offsets (0.125, 0.375), (−0.125, −0.375), (0.375, −0.125), (−0.375, 0.125) texels at the two neighbouring mip levels
  with `textureLod`, average (×0.25) per level, blend the two levels by the fraction of the exact level, then blend with the
  nearest-with-edge-blend result by `smoothstep(minPixelSize, 2·minPixelSize, maxTexelSize)`, so close-up pixels stay crisp.

pixelSize = 1 / atlas size. The fragment colour is texture × vertexColor (section 1), then fogged.

Alpha-tested layers discard fragments whose alpha (texture × vertex colour × chunk fade mix) is below the pipeline's `ALPHA_CUTOUT` define. Read from `RenderPipelines`: **0.5** for the terrain cutout pipelines (`cutout_block`, `cutout_terrain`, `cutout_terrain_multidraw`); **0.1** for every other pipeline that defines it (terrain translucent and solid snippets, entities, items, armour, the glint pipelines).
Terrain fades in over `chunkSectionFadeInTime` (an option): the fragment blends from the fog colour to the final colour by `chunkVisibility`
(for fragments more than 16 blocks from the camera; `terrain.vsh`: `mix(1, ChunkVisibility, clamp((dist − 16) / 16, 0, 1))`).

---

## 3. Sky, fog and clouds

Source: `SkyRenderer`, `FogRenderer`, `FogData`, fog environments (`AtmosphericFogEnvironment`, `WaterFogEnvironment`,
`LavaFogEnvironment`, `PowderedSnowFogEnvironment`, `BlindnessFogEnvironment`, `DarknessFogEnvironment`),
`CloudRenderer`, `EnvironmentAttributes`, `EnvironmentAttributeSystem`, `WeatherAttributes`, `Timeline`/`KeyframeTrackSampler`,
`data/minecraft/dimension_type/*.json`, `data/minecraft/timeline/day.json`, shaders `sky`, `stars`, `clouds`, `include/fog.glsl`.

### 3.1 Environment attributes: where the values come from

Sky, fog and cloud values are *environment attributes* (04 §EnvironmentAttributeMap). A value at the camera is the result
of applying **layers in this order** to the attribute's default: (1) the dimension type's `attributes`; (2) the biome
`attributes`, spatially blended around the camera (the `biomeBlendRadius` option, Gaussian); (3) every timeline listed in the
dimension type's `timelines`, in order, sampled at the clock time; (4) the weather layers when the dimension can have
weather. Each layer's value is combined with the running value by its modifier: `override` (replace; the default),
`multiply` (componentwise for colours and numbers), `add`, `subtract`, `alpha_blend` (lerp by the layer's alpha),
`blend_to_gray` (RGB: lerp towards a grey of brightness b by factor f, see below), `minimum`, `maximum`, `and`, `nand`, `or`, `nor`, `xor`, `xnor` for booleans.

Attribute defaults used by rendering (`EnvironmentAttributes`):

| Attribute | Type | Default | Notes |
|---|---|---|---|
| `visual/fog_color` | RGB | `#000000` | spatially interpolated between biomes |
| `visual/fog_start_distance` | float | 0 | |
| `visual/fog_end_distance` | float | 1024 | |
| `visual/sky_fog_end_distance` | float | 512 | |
| `visual/cloud_fog_end_distance` | float | 2048 | |
| `visual/water_fog_color` | RGB | `#050533` | biomes override (e.g. `#041633`, `#5db7ef`) |
| `visual/water_fog_start_distance` | float | −8 | |
| `visual/water_fog_end_distance` | float | 96 | |
| `visual/sky_color` | RGB | `#000000` | |
| `visual/sunrise_sunset_color` | ARGB | `#00000000` | alpha is the strength of the sunrise glow |
| `visual/cloud_color` | ARGB | `#00000000` | |
| `visual/cloud_height` | float | 192.33 | |
| `visual/sun_angle`, `visual/moon_angle`, `visual/star_angle` | degrees | 0 | |
| `visual/moon_phase` | enum | `full_moon` (first constant, inferred) | |
| `visual/star_brightness` | float | 0 | |
| `visual/block_light_tint` | RGB | `#ffd88c` | |
| `visual/sky_light_color` | RGB | `#ffffff` | |
| `visual/sky_light_factor` | float | 1.0 | |
| `visual/night_vision_color` | RGB | `#999999` | |
| `visual/ambient_light_color` | RGB | `#000000` | |

`blend_to_gray(brightness b, factor f)` on an RGB colour c with alpha α: g = (b, b, b); result = lerp(c, g, f × α) (inferred
from the constants and the name; the weather layer uses α = the weather level).

**Overworld (`dimension_type/overworld.json`) attribute map**: `ambient_light_color` `#0a0a0a`, `cloud_color` `#ccffffff`,
`cloud_height` 192.33, `fog_color` `#c0d8ff`, `sky_color` `#78a7ff`. Nether: `ambient_light_color` `#302821`, `fog_end_distance` 96, `fog_start_distance` 10, `sky_light_color` `#7a7aff`,
`sky_light_factor` 0, `cardinal_light` nether. End: `ambient_light_color` `#3f473f`, `fog_color` `#181318`, `sky_color` `#000000`,
`sky_light_color` `#ac60cd`, `sky_light_factor` 0 (and `skybox` `end`). The dimension type field `ambient_light` (overworld 0.0, nether 0.1, end 0.25, read from the three JSON files) is a separate float field; the renderer reads
`ambient_light_color`, not that float (inferred: the lightmap shader has no use of it).

### 3.2 The overworld day timeline (`timeline/day.json`, clock `minecraft:overworld`, period 24000 ticks)

Each track is a list of (tick, value) keyframes. The value at world-clock tick t (taken modulo the period) is
found by locating the segment between the two keyframes that surround t cyclically (the segment from the last keyframe
to the first wraps through the period), u = (t − from) / (to − from) (in ticks, with the wrap handled by adding the period), eased by the track's `ease`
(default `linear`; `constant` holds the earlier value), and interpolated by lerp of the value. The result is applied to
the running value with the track's modifier.

Tracks that affect rendering:

| Track | Modifier | Keyframes (tick: value) |
|---|---|---|
| `visual/sky_color` | multiply | 133: `#ffffff`; 11867: `#ffffff`; 13670: `#000000`; 22330: `#000000` |
| `visual/fog_color` | multiply | 133: `#ffffff`; 11867: `#ffffff`; 13670: `#0f0f16`; 22330: `#0f0f16` |
| `visual/cloud_color` | multiply | 133: `#ffffffff`; 11867: `#ffffffff`; 13670: `#ff191926`; 22330: `#ff191926` |
| `visual/sky_light_color` | multiply | 730: `#ffffff`; 11270: `#ffffff`; 13140: `#7a7aff`; 22860: `#7a7aff` |
| `visual/sky_light_factor` | multiply | 730: 1.0; 11270: 1.0; 13140: 0.24; 22860: 0.24 |
| `visual/star_brightness` | maximum | 92: 0.037; 627: 0.0; 11373: 0.0; 11732: 0.016; 11959: 0.044; 12399: 0.143; 12729: 0.258; 13228: 0.5; 22772: 0.5; 23032: 0.364; 23356: 0.225; 23758: 0.101 |
| `visual/sun_angle` | override, ease cubic-bezier(0.362, 0.241, 0.638, 0.759) | two keyframes on the same tick 6000, the file order being value 360 then value 0: the value runs 0 → 360 over one full period starting at tick 6000 |
| `visual/moon_angle` | override, same ease | two keyframes on tick 6000, 540 then 180: runs 180 → 540 over one period starting at tick 6000 |
| `visual/star_angle` | override, same ease | two keyframes on tick 6000, 360 then 0: runs 0 → 360 over one period starting at tick 6000 |
| `visual/sunrise_sunset_color` | override (linear) | see 3.2b |
| `gameplay/sky_light_level` | multiply | 133: 1.0; 11867: 1.0; 13670: 0.26666668; 22330: 0.26666668 (gameplay, not rendering; used for spawn/sleep rules) |

Interpretation of the same-tick pair: the sampler takes the segment whose tick range contains t. With period 24000 the two keyframes at tick 6000 make one segment that runs from tick 6000 (value 0) around the period to tick 30000 (value 360, the same moment next day), eased by the cubic bezier. So the sun angle is 0 (straight overhead after the transform of 3.4c) at tick 6000, passes about 90° near tick 12000 (the ease makes it not exactly linear), and about 180° near tick 18000. The moon angle runs 180 → 540 and the star angle 0 → 360 the same way. (inferred from the keyframe layout and the segment rule.)

#### 3.2b `sunrise_sunset_color` keyframes (ARGB; linear interpolation of all four channels)

71: `#5fefa333`, 310: `#29f5ba33`, 565: `#06fbd433`, 730: `#00ffe533`, 11270: `#00ffe533`, 11397: `#04fcd833`, 11522: `#0ff9cb33`, 11690: `#29f5ba33`,
11929: `#5fefa333`, 12243: `#b1e78733`, 12358: `#cce47e33`, 12512: `#e9e07233`, 12613: `#f6dd6b33`, 12732: `#feda6333`, 12841: `#fed75c33`,
13035: `#ecd25133`, 13252: `#c1cc4733`, 13775: `#36be3733`, 13888: `#1fbb3533`, 14039: `#09b73333`, 14192: `#00b33333`, 21807: `#00b23333`,
21961: `#09b73333`, 22112: `#1fbb3533`, 22225: `#36be3733`, 22748: `#c1cc4733`, 22965: `#ecd25133`, 23159: `#fed75c33`,
23272: `#feda6333`, 23488: `#e9e07233`, 23642: `#cce47e33`, 23757: `#b1e78733`.

The strings are `#aarrggbb`: the entry `#e9e07233` has alpha 0xe9, red 0xe0, green 0x72, blue 0x33. At ticks 730 and 11270 the alpha is 0 (no glow). The glow is strongest near tick 12732 (alpha 0xfe, orange-yellow) and again near tick 23272.

#### 3.2c Time source

The timeline uses the dimension type's `default_clock` (a `world_clock` registry entry, 04) and its total ticks, which the
server updates with Set Time (05b). The reference `minecraft:overworld` timeline has `period_ticks` 24000.

### 3.3 Fog (`FogRenderer`)

Fog is applied per fragment by `include/fog.glsl`:

`value(d, s, e) = 0 if d ≤ s; 1 if d ≥ e; else (d − s) / (e − s)`.
`total = max(value(spherical, envStart, envEnd), value(cylindrical, rdStart, rdEnd))`.
`color = lerp(color.rgb, FogColor.rgb, total × FogColor.a)`, alpha unchanged.

spherical = length of the camera-relative position. cylindrical = max(length of (x, z), |y|). The fog uniform holds
FogColor (rgba, alpha 1), the environmental start/end, the render-distance start/end, the sky end and the clouds end.

**Render-distance fog** (always present): `rdEnd = renderDistanceChunks × 16`; `rdStart = rdEnd − clamp(rdEnd / 10, 4, 64)`. With
the default render distance of 12 chunks: end 192, start 172.8.

**Environmental fog** is set by the first applicable environment, tested in this order: lava, powdered snow, blindness, darkness, water, atmospheric.
(The first applicable environment in the list sets the distances (the loop stops there). The colour comes from the first applicable environment that provides one (lava, powdered snow, water, atmospheric; never blindness or darkness), and the darkness value from the first that modifies it (blindness, darkness).)

| Environment | Applies when | envStart | envEnd | skyEnd, cloudEnd |
|---|---|---|---|---|
| Lava | camera in lava | spectator: −8; with Fire Resistance: 0; else 0.25 | spectator: 0.5 × R; with Fire Resistance: 5; else 1.0 | = envEnd |
| Powdered snow | camera in powder snow | spectator: −8; else 0 | spectator: 0.5 × R; else 2.0 | = envEnd |
| Blindness | the camera entity has Blindness (no colour of its own) | 0.25 × L | L | 0.8 × L |
| Darkness | the camera entity has Darkness (no colour of its own) | 0.75 × L | L | L |
| Water | camera in water | `visual/water_fog_start_distance` | `visual/water_fog_end_distance`, times max(0.25, waterVision) for the local player | = envEnd |
| Atmospheric | otherwise | `visual/fog_start_distance` − 160 × rainMul | max(min(96, E), E − 256 × rainMul) with E = `visual/fog_end_distance` | skyEnd = min(`visual/sky_fog_end_distance`, R); cloudEnd = min(cloudRange × 16, `visual/cloud_fog_end_distance`) |

R = the render distance in blocks (chunks × 16). For Blindness, x = 5.0 when the effect is infinite, else min(1, remaining ticks / 20), and
L = lerp(x, R, 5.0) = R + x × (5 − R); so at full effect the visible range is 5 blocks and it widens back to R during the last second.
For Darkness, L = lerp(blendFactor, R, 15.0) with blendFactor the effect's smoothed 0..1 intensity, so at full effect the range is 15 blocks.
The darkness value v of step 2 below is passed through the first darkness-modifying environment: Darkness returns max(v, blendFactor); Blindness changes it only during the last 19 ticks of the effect (its exact form was not fully read, Open question 2).

`rainMul` for the atmospheric environment: target = rainLevel × clamp((skyLightAtCamera − 8) / 7, 0, 1) × (1 if the biome has
precipitation else 0.5); each tick rainMul += (target − rainMul) × 0.2 × deltaTicks. If a boss bar with "create fog" is
shown, envStart = min(envStart, 10), envEnd = min(envEnd, 96), skyEnd = cloudEnd = envEnd.

**Fog colour** (`FogRenderer.computeFogColor`, the `FogData.color`):

1. Base colour from the colour-providing environment:
   - lava: `#991900`.
   - powdered snow: `#9fbbcc`.
   - water: `visual/water_fog_color`.
   - atmospheric: `visual/fog_color`; then (only when the render distance ≥ 4 chunks) if the camera looks towards the sun (dot of the camera
     forward vector with (±1, 0, 0), sign chosen by the sign of sin(sunAngle), is > 0) and the sunrise/sunset alpha α > 0:
     colour = lerp(dot × α, colour, sunriseRGB). Then colour = lerp(k, colour, weatherDarkenedSkyColor) where
     k = 1 − (lerp(clamp01(t / 32), 0.25, 1))^0.25 and t = min(`visual/sky_fog_end_distance` / 16, renderDistanceChunks) (so the horizon fog fades
     towards the sky colour more strongly for larger render distances). The sky colour used is `visual/sky_color` with weather darkening: if rain > 0 multiply (r, g, b) by (1 − 0.5·rain, 1 − 0.5·rain, 1 − 0.4·rain); if thunder > 0 multiply all channels by (1 − 0.5·thunder) (channel assignment inferred).
2. Void darkness: v = clamp((onset + minY − cameraY) / onset, 0, 1), onset = 32 (1 on flat worlds); the darkness environment may change v. When v > 0 and the camera is not in lava or powder snow, multiply the colour by (1 − v)².
3. If the boss overlay darkens the world (factor d > 0): colour = lerp(d, colour, colour × (0.7, 0.6, 0.6)).
4. Night vision or water vision lift: w = the player's water vision when in water; else the night-vision scale when the entity has Night Vision and not Darkness; else 0. If all three channels are nonzero, colour = lerp(w, colour, colour / max(r, g, b)) (brighten to full intensity).

The colour constants are lava `#991900` and powdered snow `#9fbbcc`.

**Clear colour.** `GameRenderer` passes the final `FogData.color` to `LevelRenderer.render`, which clears the main colour target to (fog colour r, g, b, alpha 0) and the depth target to 0.0 (a reversed-Z depth buffer; the `GREATER_THAN_OR_EQUAL` depth tests in this document are in that convention) at the start of the level pass. Anything not covered by the sky disc (for example the far side of the disc when the camera is far above it) therefore shows the fog colour.

### 3.4 Sky drawing order (`SkyRenderer.render`)

For dimension `skybox` = `overworld` (default): 1. the sky disc (section 3.4a) in `visual/sky_color` (weather-darkened by the weather layers of 3.1); 2. the sunrise/sunset fan (3.4b);
3. sun, moon and stars (3.4c); 4. the dark disc (3.4d). `skybox` = `none` draws nothing; `end` draws the end sky box and the end flash (not covered).

#### 3.4a Sky disc

Two triangle fans of 10 vertices each (a centre and 9 ring points at 45° steps), drawn with the camera's orientation but not its position (the disc stays centred on the camera). The top fan has height h = +16, the bottom fan h = −16. Centre (0, h, 0). Ring point for a = −180°, −135°, …, +180°: (sign(h) × 512 × cos a, h, 512 × sin a), so the ring radius is 512 and the winding flips between the two fans. Colour = ColorModulator = the sky colour. Pipeline `SKY`: no blending; fog is applied with an environmental range (0, `skyEnd`) and a render-distance range (`skyEnd`, `skyEnd`), so the disc fades to the fog colour towards its rim.

#### 3.4b Sunrise and sunset fan

Drawn when the sunrise/sunset alpha α is above 0.001. An 18-vertex triangle fan: centre (0, 100, 0) with colour white, alpha 1; then 17 ring points for k = 0..16, a = k × 2π / 16, at (120 × sin a, 120 × cos a, −40 × cos a) with colour white, alpha 0.
Transform: rotate X by 90°; then rotate Z by 90° + (180° if sin(sunAngle) < 0 else 0); then scale (1, 1, α). The fan's vertex colour is multiplied by the sunrise colour (rgb, and the colour's alpha as modulator alpha). Pipeline `SUNRISE_SUNSET` (shader `position_color`), blend `TRANSLUCENT` (SRC_ALPHA, ONE_MINUS_SRC_ALPHA; alpha ONE, ONE_MINUS_SRC_ALPHA).

#### 3.4c Sun, moon, stars

The celestial sprites come from the `celestials` atlas (14 §3.1, the `celestials` atlas row): `sun`, `moon/<phase>` and `end_flash`, from `textures/environment/celestial/`. In the jar `sun.png` and each of the 8 moon images are 32 × 32, `end_flash.png` is 64 × 64.
Pipeline `CELESTIAL` (shader `position_tex`: fragment = texture × ColorModulator, discarded where the texture alpha is 0): blend `OVERLAY` = (source colour factor SRC_ALPHA, destination factor ONE; alpha factors ONE, ZERO), so each pixel adds its rgb × alpha × (modulator alpha) to what is already there.
Order: rotate Y by −90°; sun: rotate X by `visual/sun_angle` (in radians) and draw; moon: rotate X by `visual/moon_angle` and draw; stars, only if the star brightness is above 0: rotate X by `visual/star_angle` and draw. The attribute angles are in degrees and are multiplied by π/180.

- **Sun.** One quad. Its corners are (−1, 0, −1), (1, 0, −1), (1, 0, 1), (−1, 0, 1) of a unit quad, scaled by 30 in x and z, then translated to y = 100. So **30 is the half-size and the quad's edge is 60**. In the unrotated frame the quad lies in the horizontal plane at y = 100 (straight above the camera, 100 blocks); the X rotation tilts it across the sky. UV: corner 1 → (u0, v0), 2 → (u1, v0), 3 → (u1, v1), 4 → (u0, v1) of the sprite rectangle. Colour modulator (1, 1, 1, rainBrightness) with rainBrightness = 1 − rainLevel.
- **Moon.** The same unit quad scaled by 20: **half-size 20, edge 40**, at y = 100. The sprite is the one for the current phase; the phase index (0 to 7) picks one of 8 pre-built quads. UV is the sun's pattern rotated by 180°: corner 1 → (u1, v1), 2 → (u0, v1), 3 → (u0, v0), 4 → (u1, v0). Modulator (1, 1, 1, rainBrightness). Phase order (`MoonPhase`): `full_moon`, `waning_gibbous`, `third_quarter`, `waning_crescent`, `new_moon`, `waxing_crescent`, `first_quarter`, `waxing_gibbous`. The phase comes from the `visual/moon_phase` attribute; the vanilla `moon` timeline steps through the eight phases, one per 24000 ticks (period 192000).
- **Stars.** Up to 1500 quads built once, using the Java linear congruential generator (`RandomSource.createThreadLocalInstance(10842)`, a `SingleThreadedRandomSource`: the same LCG as `LegacyRandomSource`, the generator is specified in [10-world-generation-terrain.md](10-world-generation-terrain.md) §2.6, and 11 §5.3.1 states that `SingleThreadedRandomSource` is the same LCG) seeded with 10842. For each of 1500 iterations in order: draw `nextFloat` three times for x, y, z, each mapped to 2r − 1; draw a fourth `nextFloat` for size = 0.15 + 0.1 × r; if the squared length x² + y² + z² is not strictly between 0.01 and 1 the candidate is dropped (the four draws were already consumed) and the loop goes on; otherwise p = normalize(x, y, z) × 100, draw `nextDouble` for the angle = nextDouble × π × 2, and emit a quad. The quad's four corners are p + R × (s, −s, 0), p + R × (s, s, 0), p + R × (−s, s, 0), p + R × (−s, −s, 0) with s = size, R = a rotation that turns the +z axis to point towards the origin (`rotateTowards(−p, up = (0, 1, 0))`) followed by a rotation about z by −angle. The quad therefore has edge 2 × size = 0.3 to 0.5 blocks at distance 100. Pipeline `STARS` (colour = the modulator only, no texture), blend `OVERLAY`, colour modulator (b, b, b, b) with b = `visual/star_brightness`. Because the blend multiplies by source alpha, a star adds b × b to the sky colour (for b = 0.5 that is 0.25). The star positions are cosmetic; a fixed seed of any kind is acceptable for CobolCraft.

Weather: the rain and thunder layers drive `visual/star_brightness` towards 0 (3.5, Open question 3).

#### 3.4d Dark disc ("void horizon")

A black fan of 10 vertices with the same shape as the bottom sky fan (y = −16), translated by +12 in y, so it sits 4 blocks below the camera. Drawn only when
(player eye y − horizon height) < 0 and the player is not underwater. Horizon height = the dimension's minY for flat worlds (the "is flat" flag of the spawn info, 05) else 63.0.

### 3.5 Weather attribute layers (`WeatherAttributes`)

When the dimension can have weather, two layers are added: one weighted by the rain level and one by the thunder level (each level 0..1, smoothed by the client):

| Attribute | Rain layer | Thunder layer |
|---|---|---|
| `visual/sky_color` | blend_to_gray(brightness 0.6, factor 0.75) | blend_to_gray(0.24, 0.94) |
| `visual/fog_color` | multiply (0.5, 0.5, 0.6) | multiply (0.25, 0.25, 0.3) |
| `visual/cloud_color` | blend_to_gray (0.24, 0.5) | blend_to_gray (0.095, 0.94) |
| `visual/sunrise_sunset_color` | multiply (0.5, 0.5, 0.6) | multiply (0.25, 0.25, 0.3) |
| `visual/sky_light_factor` | alpha_blend to 0.24 with alpha 0.3125 | alpha_blend to 0.24 with alpha 0.52734375 |
| `visual/sky_light_color` | alpha_blend with a colour at alpha 0.3125 | alpha_blend with a colour at alpha 0.52734375 |
| `visual/star_brightness` | set towards 0 | |

The grey brightness and the colour of the sky-light blend are the constants listed in the bytecode; the blend colour for
`sky_light_color` was not read (Open question 3). Weights are scaled by the weather level.

### 3.6 Clouds (`CloudRenderer`)

- **Texture**: `textures/environment/clouds.png`, 256 × 256, 1-bit greyscale with a `tRNS` entry that makes black transparent. Each pixel is a cell; a cell is empty when its
  alpha is below 10 (otherwise solid); only alpha is read (3.7f).
- **Cell size**: 12 × 4 × 12 blocks (x, y, z). The pattern wraps every 256 cells (3072 blocks) in x and z.
- **Height**: the cloud layer's bottom is at world y = `visual/cloud_height` (192.33 in the overworld); its top is 4 blocks higher.
- **Movement**: with t = (gameTime mod (256 × 400)) + partialTick, the camera's cloud-space x = cameraX + t × 0.03, z = cameraZ + 3.96. One
  cell therefore passes in 400 ticks (0.6 blocks per second, `BLOCKS_PER_SECOND`). A cloud feature drifts toward −x (inferred from the sign).
- **Colour**: the `visual/cloud_color` attribute (ARGB; the overworld base `#ccffffff`, alpha 0.8; multiplied by the day track, darker at night). Each face's colour is the cloud colour times a face brightness:
  bottom 0.7, top 1.0, north 0.8, south 0.8, west 0.9, east 0.9. A flat cloud (see below) uses the top brightness.
- **Fog**: the face alpha is multiplied by 1 − value(distance, 0, cloudEnd), distance = spherical distance to the vertex.
- **Modes** (option `cloudStatus`): off; `FAST` = one flat quad per solid cell: the DOWN face of the cell at the layer's bottom, drawn without culling, with the top colour factor 1.0; `FANCY` = a box per solid cell, 12 × 4 × 12 blocks. Let (dx, dz) be the cell's offset from the camera's cell in cells, and d = cloud_height − cameraY. The camera is *below* the layer when d > 0, *above* it when d + 4 < 0, and *inside* it otherwise. A fancy cell emits: its UP face unless the camera is below; its DOWN face unless the camera is above; its NORTH face when the north neighbour cell is empty and dz > 0; SOUTH when the south neighbour is empty and dz < 0; WEST when the west neighbour is empty and dx > 0; EAST when the east neighbour is empty and dx < 0 (so side faces are only built on the camera-facing side). In addition, for cells with |dx| ≤ 1 and |dz| ≤ 1 (the camera's own cell and its 8 neighbours) all six faces are emitted again with the inside flag (reversed winding), so the camera can sit inside a cloud.
- **Range and shape**: with the option `cloudRange` c (2–128; default 128, read in 3.7f) the meshed radius is r = ceil(c × 16 / 12) cells. A cell at offset (dx, dz) from the camera's cell is meshed when dx² + dz² ≤ r² (a disc: the build loop visits dz ≥ 0 rows in a diamond-shaped scan, tests dx² + dz² against r² and mirrors each row to −dz). The texture index of a cell is ((cameraCellX + dx) mod W, (cameraCellZ + dz) mod H) with W, H the image size (256 for the vanilla image; corrected in 3.7f, which also states the time wrap).
- **Blend**: `TRANSLUCENT`, depth test default, written with depth.
- **See also**: exact build, offset and shading rules, the vanilla image structure, the corrections to the 256-cell wrap and the neighbour wrap, and the built-in art recipes are in 3.7.

### 3.7 Sun, moon and cloud art: exact geometry, phase selection, image rules and built-in art recipes

Source: the same artifact as the rest of this document (`minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3, the artifact recorded in [README.md](README.md)). Method: static reading of the bytecode (`SkyRenderer`, `CloudRenderer`, `RenderPipelines`, `BlendFunction`, `DepthStencilState`, `MoonPhase`, `AttributeTypes`, `AttributeType`, `LerpFunction`, `CloudStatus`, `Options`, `LevelExtractor`, `LevelRenderer`, `AtmosphericFogEnvironment`), the shaders `clouds`, `position_tex`, `stars`, `sky`, the JSON files `timeline/moon.json`, `dimension_type/*.json`, `atlases/celestials.json`, and a pixel-level analysis of the shipped images `textures/environment/celestial/sun.png`, `.../moon/*.png` and `textures/environment/clouds.png` (these are the vanilla jar's own images, not a resource pack), with no execution. 3.4c and 3.6 above state the main rules; this subsection confirms them, corrects two details, and adds what a replacement ("built-in art") needs. Where a statement of 3.4c or 3.6 was re-read and agrees, it is not repeated.

#### 3.7a What is in the jar (files, sizes, how they are loaded)

| Item | Path in the jar | Format | Size |
|---|---|---|---|
| Sun | `assets/minecraft/textures/environment/celestial/sun.png` | 8-bit palette PNG, no transparency chunk, every pixel alpha 255 | 32 × 32 |
| Moon, 8 phases | `assets/minecraft/textures/environment/celestial/moon/<phase>.png` for `full_moon`, `waning_gibbous`, `third_quarter`, `waning_crescent`, `new_moon`, `waxing_crescent`, `first_quarter`, `waxing_gibbous` | the same, every pixel alpha 255 | 32 × 32 each |
| End flash (not covered) | `.../celestial/end_flash.png` | palette PNG | 64 × 64 |
| Clouds | `assets/minecraft/textures/environment/clouds.png` | 1-bit greyscale PNG with a `tRNS` chunk that makes grey value 0 transparent | 256 × 256 |

There is **no moon atlas image**: each phase is its own file (the answer to "how are the phase cells arranged": they are not; there is nothing to arrange). The engine builds the `celestials` atlas itself: `atlases/celestials.json` has one source, a directory source with prefix `""` over `environment/celestial`, so the sprite ids are `minecraft:sun`, `minecraft:moon/<phase>` (the phase quad of `SkyRenderer.buildMoonPhases` asks for `moon/` + the serialized phase name) and `minecraft:end_flash`. The atlas is registered with `AtlasConfig.createMipmaps` = false (`AtlasManager.KNOWN_ATLASES`, the entry for `Sheets.CELESTIAL_SHEET`), and `TextureAtlas` samples with the nearest-neighbour filter and clamp-to-edge addressing (`SamplerCache.getClampToEdge(FilterMode.NEAREST …)`, read in the constructor; the upload path passes the same filter with a boolean that is taken to be the mipmap flag, inferred), so the sun and moon are point-sampled with no mip levels. A pack that supplies a larger image (any square size) works unchanged: the sprite rectangle is stretched over the same quad (3.4c).

The cloud image is **not** a GPU texture. `CloudRenderer.prepare(ResourceManager, …)` reads `textures/environment/clouds.png` with `NativeImage.read` and turns it into a CPU table of one record per pixel; the shader never samples it (`clouds.fsh` has no sampler). A failure to read logs "Failed to load cloud texture" and the renderer then draws no clouds.

#### 3.7b Sun and moon: placement formulas (confirms 3.4c, adds the sky-space mapping)

Confirmed by re-reading `SkyRenderer.renderSunMoonAndStars`, `renderSun`, `renderMoon`, `applyCelestialBodyTransform` and `buildCelestialQuad`:

- Matrix order for a body: M = R_y(−90°) · R_x(ψ) · T(0, 100, 0) · S(h, 1, h) with ψ the body's angle in radians (`visual/sun_angle` for the sun, `visual/moon_angle` for the moon), h = 30 (sun) or 20 (moon). The quad's local corners (before M) are (±1, 0, ±1); a vertex with local coordinates (lx, lz) ∈ [−1, 1]² therefore has the pre-rotation position (30·lx, 100, 30·lz) for the sun (20 for the moon). Axis conventions are right-handed (rotation about +X turns +y towards +z; about +Y turns +z towards +x, as `Axis.XP`/`Axis.YP` do).
- Resulting world-aligned position (camera at the origin, +x east, +z south, +y up; the sky is drawn with the camera's rotation but not its position, 3.4a), with Lx = h·lx and Lz = h·lz:

  P(ψ, Lx, Lz) = ( −(100·sin ψ + Lz·cos ψ), 100·cos ψ − Lz·sin ψ, Lx ).

  The body centre is (−100 sin ψ, 100 cos ψ, 0): it moves in the x–y plane, **due east to due west through the zenith**, at distance 100. At ψ = 0 it is at the zenith; at ψ = 90° at the western horizon; at ψ = 180° at the nadir; at ψ = 270° at the eastern horizon. The quad is always tangent to the sphere of radius 100 (its normal points at the camera).
- Direction of the image axes on the sky (u = texture x, v = texture y, both increasing towards the sprite's U1 and V1 edges):

  | Body | UV assignment of corners 1..4 = (−1,−1), (1,−1), (1,1), (−1,1) | image +u points towards | image +v points towards (in the x–y plane) |
  |---|---|---|---|
  | Sun | (u0,v0), (u1,v0), (u1,v1), (u0,v1) | world +z (south), at every angle | (−cos ψ, −sin ψ): west at ψ = 0, down at ψ = 90°, east at ψ = 180°, up at ψ = 270° |
  | Moon | (u1,v1), (u0,v1), (u0,v0), (u1,v0) | world −z (**north**), at every angle | (+cos ψ, +sin ψ): east at ψ = 0, up at ψ = 90°, west at ψ = 180°, down at ψ = 270° |

  Consequence for the moon art: the image's right-hand side (large u) always faces **north** in the sky and its left-hand side faces south, whatever the time; the lit side of a phase is not turned towards the sun. The `waxing_*` images (lit part on the right, 3.7e) are lit on the north side of the moon, the `waning_*` images on the south side. Both quads wind counter-clockwise as seen from the camera at the origin (the camera is below the quad at ψ = 0), so back-face culling keeps them.
- Angles at selected ticks, from the tracks of 3.2 (the cubic-bezier ease of those tracks was evaluated as control points (0.362, 0.241) and (0.638, 0.759) with endpoints (0, 0) and (1, 1), x taken as the independent variable; the parameter order is inferred, Open question 28): the bezier is point-symmetric, so at 18000 the sun angle is exactly 180° and the moon angle 360°; at tick 6000 sun 0°, moon 180°. At tick 0 (u = 0.75) the eased fraction is 0.78436, so the sun angle is 282.4° and the moon angle 462.4° (equivalent to 102.4°); at tick 12000 (u = 0.25) the fraction is 0.21564, sun angle 77.6°, moon angle 257.6°.

Worked examples (centre positions from the formula):

| Tick | Sun ψ | Sun centre | Moon ψ | Moon centre |
|---|---|---|---|---|
| 6000 | 0° | (0, 100, 0) overhead | 180° | (0, −100, 0) below |
| 18000 | 180° | (0, −100, 0) below | 360° | (0, 100, 0) overhead |
| 0 | 282.4° | (97.7, 21.47, 0) east, 21.5 above the horizon plane | 102.4° | (−97.7, −21.47, 0) west, below the horizon plane |
| 12000 | 77.6° | (−97.7, 21.47, 0) west, above | 257.6° | (97.7, −21.47, 0) east, below |

The moon image changes at tick 0 of each day (3.7d), when the moon is below the horizon plane, so the change is not visible (computed from the table above).

**Blend and alpha, exact arithmetic.** Pipeline `CELESTIAL` (shader `position_tex`): fragment colour = texel × `ColorModulator`, discarded when the texel alpha is exactly 0; blend `OVERLAY` = colour factors (SRC_ALPHA, ONE), alpha factors (ONE, ZERO), op ADD (read from `BlendFunction`). The modulator is (1, 1, 1, rainBrightness) for sun and moon, where rainBrightness = 1 − `ClientLevel.getRainLevel(partialTick)` (the rain level; whether `getRainLevel` already includes the thunder level was not traced, Open question 29). So the framebuffer colour after the body is **dst.rgb + texel.rgb × texel.a × rainBrightness** (texel alpha as 0..1), and the destination alpha is replaced by texel.a × rainBrightness. Black texels therefore add nothing and the quad's rectangle is invisible against the sky; light texels brighten the sky and saturate at 1. Neither pipeline applies fog (their depth and cull state is the builder default, Open question 30). The sun and the moon both draw every frame (no visibility test was found in `SkyRenderer`; a body below the horizon plane is covered by the terrain drawn afterwards, inferred). Draw order: sky disc, sunrise fan, sun, moon, stars, dark disc (3.4), in the sky pass at the start of the level pass (3.3).

Sun and moon are drawn only when the dimension's `skybox` is `overworld` (the default). `skybox: none` (the nether) draws nothing and `skybox: end` draws the end sky (not covered): neither the nether nor the end has a sun, moon or clouds.

#### 3.7c Sun and moon images: what the vanilla art contains (basis for built-in art)

Both images are 32 × 32 and are drawn at 60 and 40 blocks, so one image pixel is 1.875 blocks of sun and 1.25 blocks of moon. Coordinates below are pixel indices (0 to 31, x to the right, y down); the centre of symmetry is between pixels 15 and 16, so a pixel (x, y) has the distance d = √((x − 15.5)² + (y − 15.5)²) from the centre.

**Glow (halo).** Every image has a soft round glow around a central 8 × 8 square. Its brightness for a pixel outside the square (x or y outside 12..19) is

v(d) = round( 40 · min(1, (16.7 − d) / 11.8)^1.6 ), and 0 once d ≥ 16.7,

(a fit to the shipped pixels: maximum error 2 levels on the sun's red channel and the moon's blue channel, all 960 halo pixels; the true values are not a closed formula). v is at most 40 (about 0.157) and is 14 at d ≈ 10.5, 5 at d ≈ 13.5, 1 at d ≈ 15.5. The shipped sun glow is symmetric under mirroring in x and y and under swapping x and y. Beyond d ≈ 16.7 the fit gives 0, while the shipped images still hold the value 1 (sun (1, 1, 0), moon (0, 0, 1)) out to d ≈ 18.4, for example at (1, 5), (2, 3) and (5, 1); the pixels farther out, in the four corner regions, are 0. The fit differs from the shipped pixels by at most 1 level beyond d = 16.7 (60 pixels in all).

| Image | Halo colour (r, g, b) as a function of v | Examples at v = 40 |
|---|---|---|
| Sun | (v, v, round(0.38·v)) (blue/red ratio 0.30 to 0.41 over the rows read) | (40, 40, 16) |
| Moon (all 8 phases, identical) | (round(0.38·v), round(0.57·v), v) | (16, 23, 40) |

The sun's halo red channel equals the moon's halo blue channel in 958 of the 960 halo pixels (largest difference 2). The halo is the same in the eight moon images (0 differing pixels).

**Sun core.** An 8 × 8 square at x, y = 12..19, fully opaque, three tones: the outer ring of 28 pixels `#ffd54a` (255, 213, 74); the next ring of 20 pixels `#ffffaa` (255, 255, 170); the central 4 × 4 (16 pixels) `#ffffd9` (255, 255, 217).

**Moon core.** The same 8 × 8 square at x, y = 12..19 replaces the glow; it holds the phase (3.7e). Tones used:

| Role | Colour |
|---|---|
| Unlit part (the dark side) | `#0c121f` (12, 18, 31) |
| Terminator pixel (one pixel wide) and, for `new_moon`, the outline ring | `#2b2f38` (43, 47, 56) |
| Lit surface, six tones from brightest to darkest | `#d9e4ff` (217, 228, 255), `#afb8cc` (175, 184, 204), `#9097a5` (144, 151, 165), `#747d93` (116, 125, 147), `#5f677a` (95, 103, 122), `#505666` (80, 86, 102) |

The unlit tone is not black: it adds (12, 18, 31)/255 to the sky inside the 8 × 8 square, so the dark side shows as a slightly blue disc and a new moon is a faint disc with a lighter outline. In the `full_moon` image the brightest tone `#d9e4ff` fills the upper-left of the disc, marked with darker crater pixels (`#afb8cc`, `#9097a5`), and the tones fall off to `#5f677a`/`#505666` along the lower two rows and the right two columns (18 pixels `#d9e4ff`, 18 `#5f677a`, 12 `#afb8cc`, 6 `#9097a5`, 6 `#505666`, 4 `#747d93`). The lit pixels of the other phases are drawn per phase and are not a mask of the full-moon image (for example 7 of the 32 lit pixels of `first_quarter` equal the full-moon pixel at the same place), so only the tone set and the shape rules of 3.7e are required.

#### 3.7d Moon phase selection from the day count

- The attribute `visual/moon_phase` has type `moon_phase`, an enum of `MoonPhase` with the eight values in the order of 3.4c (index 0 `full_moon` to 7 `waxing_gibbous`; `MoonPhase.PHASE_LENGTH` = 24000). Its attribute type is `AttributeType.ofNotInterpolated`: **no interpolation**; between two keyframes the earlier value holds until the next keyframe's tick (the keyframe lerp is `LerpFunction.ofStep(1.0)`, which returns the earlier value for every fraction below 1; the state-change lerp is `ofStep(0)` (the new value at once), the spatial lerp `ofStep(0.5)`).
- Source of the value: the `minecraft:moon` timeline (`data/minecraft/timeline/moon.json`, in the tag `#minecraft:in_overworld`, which also lists `#minecraft:universal`, `minecraft:day` and `minecraft:early_game`), clock `minecraft:overworld`, `period_ticks` 192000, a track `minecraft:visual/moon_phase` with eight keyframes, tick 0 `full_moon`, 24000 `waning_gibbous`, 48000 `third_quarter`, 72000 `waning_crescent`, 96000 `new_moon`, 120000 `waxing_crescent`, 144000 `first_quarter`, 168000 `waxing_gibbous`. (The same file has a second track, `minecraft:gameplay/surface_slime_spawn_chance`, ease `constant`, modifier `maximum`, keyframes 0.5, 0.375, 0.25, 0.125, 0.0, 0.125, 0.25, 0.375 at the same eight ticks; it is gameplay, not rendering.)
- Rule: let T be the clock's total ticks (3.2c). **phase index = floor((T mod 192000) / 24000)**, so the phase is constant for each 24000-tick day, changes at T ≡ 0 (mod 24000) and repeats every 8 days; the moon seen in the night of day k (ticks 12000 to 24000 of that day) is phase k mod 8. The day count is T / 24000 rounded down, counted from the clock's zero, not the player's days played.
- Worked examples: T = 0 to 23999 gives `full_moon`; T = 121000 gives index floor(121000 / 24000) = 5, `waxing_crescent`; T = 222000: 222000 mod 192000 = 30000, index 1, `waning_gibbous`; T = 191999 gives index 7, `waxing_gibbous`, and T = 192000 returns to `full_moon`.
- The dimension types `overworld` and `overworld_caves` both have `timelines: #minecraft:in_overworld` (both files read); the nether and end have `has_fixed_time` true and `skybox` of `none` and `end` respectively, and their `timelines` are the tags `#minecraft:in_nether` and `#minecraft:in_end`, each of which lists only `#minecraft:universal` (that tag holds `minecraft:villager_schedule`), so they have no moon timeline.
- A server that does not use the vanilla timeline can supply any phase by a different `visual/moon_phase` value (the data-driven attribute, 3.1); the renderer only needs the index 0..7.

#### 3.7e Moon phase images: the shape of each 8 × 8 core

Classes: L lit (any lit tone), r terminator or outline pixel `#2b2f38`, D unlit `#0c121f`. Columns are 0..7 within the core (core x = 12 + column), rows 0..7 (core y = 12 + row). "Rim column" is the column of the pixel `r` in each row; every pixel to the lit side of it is L and every pixel on the other side is D.

| Phase (index) | Lit side | Rim column for rows 0 to 7 | Lit pixels |
|---|---|---|---|
| `full_moon` (0) | all | none | 64 |
| `waning_gibbous` (1) | left (low u) | 4, 5, 6, 6, 6, 6, 5, 4 | 42 |
| `third_quarter` (2) | left | 4 in every row | 32 |
| `waning_crescent` (3) | left | 3, 2, 1, 1, 1, 1, 2, 3 | 14 |
| `new_moon` (4) | none | outline: the whole outer ring of the 8 × 8 is `r`; the inner 6 × 6 is D | 0 |
| `waxing_crescent` (5) | right (high u) | 4, 5, 6, 6, 6, 6, 5, 4 | 14 |
| `first_quarter` (6) | right | 3 in every row | 32 |
| `waxing_gibbous` (7) | right | 3, 2, 1, 1, 1, 1, 2, 3 | 42 |

For the left-lit phases the lit pixels are columns 0 up to rim − 1 and D is columns rim + 1 to 7; for the right-lit phases D is columns 0 up to rim − 1 and lit is rim + 1 to 7. Measured against the quarter's rim (column 4 for the left-lit quarter, column 3 for the right-lit one), a gibbous rim lies further out by 0, 1, 2, 2, 2, 2, 1, 0 columns for rows 0 to 7, and a crescent rim lies further in by 1, 2, 3, 3, 3, 3, 2, 1 columns; the right-lit phases are the exact mirror (column c to 7 − c) of the left-lit ones. Left means the image's left half (low u); with 3.7b it is the south side of the sky moon for the waning phases, and the north side for the waxing ones.

#### 3.7f Clouds: what the image means, and the exact build, offset and shading rules (confirms 3.6, adds detail and two corrections)

**How the image is read** (`CloudRenderer.prepare` and `isCellEmpty`, `packCellData`): for each pixel (x, y), x from 0 to width − 1 and y from 0 to height − 1, the **alpha** byte of the decoded RGBA is the only datum used. The cell is empty when alpha < 10 and solid otherwise; the colour channels are never used (the cloud colour comes from `visual/cloud_color`, 3.6). The 1-bit PNG of the jar has a `tRNS` chunk naming grey 0 transparent, so its black pixels decode with alpha 0 (empty) and its white pixels with alpha 255 (solid): 47433 empty pixels and 18103 solid pixels (27.6 %), every alpha either 0 or 255. Each solid cell also records which of its four neighbours are empty: north is the pixel (x, y − 1), south (x, y + 1), west (x − 1, y), east (x + 1, y), looked up with wrap-around. **Correction to 3.6:** the wrap uses the image's own dimensions, not a fixed 256: the cell grid has width columns (x) and height rows (z), the pattern repeats every width × 12 blocks in x and height × 12 blocks in z, and the scroll time wraps at width × 400 ticks (below). The east and west neighbour lookups wrap with the image **height** where the width would be correct (the bytecode takes `floorMod(x ± 1, height)`), so the renderer is only exact for square images; a built-in image must be square. Texel axes: image x is world x, image y is world z.

**Cell and layer size, scroll and offset** (`CloudRenderer.prepare(int cloudColor, CloudStatus, float cloudHeight, int cloudRange, Vec3 camera, long gameTime, float partialTick)`; the arguments come from `LevelExtractor`: `cloudColor` = the `visual/cloud_color` attribute at the camera for the partial tick as ARGB, `cloudHeight` = `visual/cloud_height`, read only when the colour's alpha is above 0). With W, H the image width and height:

1. t = (gameTime mod (W × 400)) + partialTick.
2. cloud-space x = camera.x + t × 0.030000001, cloud-space z = camera.z + 3.96 (the double constant 3.9600000381…).
3. x := x − floor(x / (W × 12)) × (W × 12) and z := z − floor(z / (H × 12)) × (H × 12), the reduction into 0 ≤ x < 12W, 0 ≤ z < 12H.
4. camera cell cx = floor(x / 12), cz = floor(z / 12); fractions fx = x − 12·cx, fz = z − 12·cz (0 ≤ fx, fz < 12).
5. Uniforms for the shader: CloudColor = the ARGB colour as (r, g, b, a) in 0..1; CloudOffset = (−fx, cloudHeight − camera.y, −fz); CellSize = (12, 4, 12).
6. A cell at offset (dx, dz) from the camera's cell is the image pixel ((cx + dx) mod W, (cz + dz) mod H). In camera-relative coordinates its box spans x from 12·dx − fx to 12·dx − fx + 12, y from cloudHeight − camera.y to that + 4 and z from 12·dz − fz to 12·dz − fz + 12.
7. Because the sampling position is camera.x + 0.03 t, a feature stored at image column i sits at world x = 12·i − 0.03·t (modulo the period): the clouds **drift towards −x (west) at 0.03 blocks per tick** (read, not inferred; the other axis is fixed, a constant +3.96 offset shifts the grid by 3.96 blocks in z only: a feature at image row j sits at world z = 12·j − 3.96).
   - The time wrap W × 400 ticks equals one full period of the pattern at 12 × 0.03 per cell: 400 ticks move the pattern by exactly one cell (0.03 × 400 = 12), so after W × 400 ticks it has moved W cells = one pattern period and the wrap is invisible.

**Worked example.** Image 256 × 256, `gameTime` 1000, partial tick 0.5, camera (100.0, 70.0, −50.0), `cloud_height` 192.33: t = 1000.5; x = 100 + 1000.5 × 0.030000001 = 130.015; z = −50 + 3.96 = −46.04, which reduces by one period of 3072 to 3025.96. cx = floor(130.015 / 12) = 10, cz = floor(3025.96 / 12) = 252; fx = 10.015, fz = 1.96. CloudOffset = (−10.015, 122.33, −1.96); the camera cell is image pixel (10, 252); the cell (dx, dz) = (2, −1) is pixel (12, 251) and spans camera-relative x from 13.985 to 25.985. Since 122.33 > 0 the camera is below the layer.

**Layer position and the camera's state.** d = cloudHeight − camera.y; the camera is above the layer when d + 4 < 0, below when d > 0, inside otherwise (confirms 3.6). The layer spans y in [cloudHeight, cloudHeight + 4]. The mesh is rebuilt when the camera cell, the camera state (above, inside, below), the cloud status or the loaded image changes, not every frame; the offset uniform is updated every frame.

**Mesh build** (`buildMesh`, `tryBuildCell`, `buildFlatCell`, `buildExtrudedCell`, `encodeFace`): r = ceil(cloudRange × 16 / 12). The cells visited are all (dx, dz) with dx² + dz² ≤ r² (3.6; rings of increasing |dx| + |dz| up to 2r, the loop bound being 2r and the per-ring check |dz| ≤ r): the order in which cells are emitted does not change the picture, since the pipeline is translucent with depth, but is a diamond-ring order with each row emitted for −dz then +dz. A cell is skipped if its record is empty. For a solid cell:
- FAST: one face, direction DOWN, the "use top colour" flag set (colour factor 1.0). The face is drawn by the pipeline `FLAT_CLOUDS`, which is `CLOUDS` with culling disabled.
- FANCY: faces as in 3.6 (UP unless the camera is below; DOWN unless the camera is above; a side face only when that neighbour is empty and the cell is on the camera side; plus all six faces with the inside flag for the camera's 3 × 3 cells). The inside flag reverses the vertex order of the quad (the shader uses vertex 3 − k for the k-th vertex), turning the winding inside out so back-face culling shows the inside to a camera in a cloud. `CLOUDS` has the default culling (only `FLAT_CLOUDS` switches it off, `withCull(false)`), which culls back faces.

**Vertex positions and face colours** (shader `clouds.vsh`): the six faces are listed in `Direction` data order DOWN 0, UP 1, NORTH 2, SOUTH 3, WEST 4, EAST 5, each four corners in the cell's unit box:

| Direction | Corners (x, y, z) in cell units, in drawing order | Factor (r = g = b; alpha factor 1) |
|---|---|---|
| DOWN | (1,0,0), (1,0,1), (0,0,1), (0,0,0) | 0.7 |
| UP | (0,1,0), (0,1,1), (1,1,1), (1,1,0) | 1.0 |
| NORTH (−z) | (0,0,0), (0,1,0), (1,1,0), (1,0,0) | 0.8 |
| SOUTH (+z) | (1,0,1), (1,1,1), (0,1,1), (0,0,1) | 0.8 |
| WEST (−x) | (0,0,1), (0,1,1), (0,1,0), (0,0,0) | 0.9 |
| EAST (+x) | (1,0,0), (1,1,0), (1,1,1), (1,0,1) | 0.9 |

(A corner (a, b, c) is placed at a·12, b·4, c·12 plus the cell origin and CloudOffset.) The vertex colour is (factor, factor, factor, 1) × CloudColor componentwise, so the **alpha is not shaded**: a face's alpha is the cloud colour's alpha. The shading never touches alpha. The fragment multiplies alpha by 1 − value(spherical distance of the vertex, 0, FogCloudsEnd) (value as in 3.3, interpolated across the face) and writes no fog colour: fog fades clouds out, it does not tint them.

**Fog end** (`AtmosphericFogEnvironment`): `cloudEnd` = min(cloudRange option × 16, `visual/cloud_fog_end_distance`) in the atmospheric environment (default 2048), so the default option 128 gives 2048 blocks (confirms 3.3). The meshed disc has a radius of r = ceil(128 × 16 / 12) = 171 cells, i.e. 2052 blocks, so the mesh slightly outruns the fog end.

**Pipelines.** `CLOUDS` (fancy) and `FLAT_CLOUDS` (fast), shaders `core/clouds`, blend `TRANSLUCENT` = colour (SRC_ALPHA, ONE_MINUS_SRC_ALPHA), alpha (ONE, ONE_MINUS_SRC_ALPHA); depth test `GREATER_THAN_OR_EQUAL` with depth write enabled (`DepthStencilState.DEFAULT`, reversed depth, 3.3); topology quads. Clouds are drawn after the translucent terrain and the translucent features, before precipitation. There is also an order-independent-transparency variant (`OIT_CLOUDS`, `OIT_FLAT_CLOUDS`, `renderOit`) of the same shader and geometry, used when the improved-transparency option is on (below). In the normal path the clouds are drawn before the precipitation; in the OIT path the precipitation (`WeatherEffectRenderer.renderOit`) is drawn before the clouds within each OIT stage. Clouds are drawn only when the status is not `OFF` and the colour's alpha is above 0.

**Improved transparency** (`Options.improvedTransparency`, saved as `improvedTransparency`, a boolean with default **false**; `GameRenderer.useImprovedTransparency` is true when the option is on and the terrain is not drawn as a wireframe): `LevelRenderer` runs `executeClassicTransparency` (the normal path of this subsection) when it is false and `executeOit` (the OIT path: `CloudRenderer.renderOit`) when it is true. So the normal path is the default; the OIT path is only partly traced (Open question 27).

**Options** (`Options`, `CloudStatus`): `cloudStatus` (saved as `renderClouds`; the serialized names are `false` for `OFF`, `fast` for `FAST` and `true` for `FANCY`; a boolean is also accepted through an alternative codec, whose mapping function was not read, so `true` = FANCY and `false` = OFF is inferred; **default FANCY**); `cloudRange` (saved as `cloudRange`, an integer slider from 2 to 128 inclusive, **default 128**; read from the constructor argument `Integer.valueOf(128)` after the `IntRange(2, 128, …)`, which closes the "default 128" part of Open question 10). A status change forces a mesh rebuild (3.7f); whether the option listener of a range change forces one was not traced (the mesh radius is taken at build time).

**Colour by weather and time.** Unchanged from 3.5 and 3.2: base `#ccffffff` (alpha 0.8), multiplied by the day track (`#ffffffff` by day, `#ff191926` at night, interpolated linearly with the keyframes of 3.2), and by the rain and thunder layers of 3.5. Examples: noon (tick 6000, no weather): colour (1, 1, 1, 0.8), so the top face is (1, 1, 1, 0.8), bottom (0.7, 0.7, 0.7, 0.8), north and south (0.8, 0.8, 0.8, 0.8), west and east (0.9, 0.9, 0.9, 0.8). Night (tick 18000): colour = (1, 1, 1, 0.8) × (0.098, 0.098, 0.149, 1.0) = (0.098, 0.098, 0.149, 0.8), top face the same, bottom (0.069, 0.069, 0.104, 0.8). In FAST mode every cloud cell is one quad with the top factor, so the cloud shows (1, 1, 1, 0.8) by day, brighter than the FANCY underside (0.7).
- Face selection, worked example: the camera is below the layer and a solid cell lies at the offset (dx, dz) = (2, −1) from the camera's cell, with all four neighbour cells empty. In FANCY mode it emits DOWN (the camera is not above), SOUTH (the south neighbour is empty and dz < 0) and WEST (the west neighbour is empty and dx > 0): three faces. It emits no UP (the camera is below), no NORTH (dz is not > 0) and no EAST (dx is not < 0). The camera's own cell, (0, 0), emits DOWN plus all six inside-flag faces, each with its direction's colour factor and the reversed winding; its outward UP face is not emitted because the camera is below.

#### 3.7g Built-in art recipes: what a replacement must provide

**Sun image** (`minecraft:sun`, path `assets/minecraft/textures/environment/celestial/sun.png`).
- Format and size requirements imposed by the renderer: a PNG that the texture loader accepts; any size is accepted by the atlas and scaled onto the 60 × 60 block quad, a **square** image keeps the shape round; no power-of-two requirement (inferred: the stitcher of 2.2 packs arbitrary sizes, and with `createMipmaps` false the padding of 2.2 is the minimum); the rgb channels are what is added to the sky (additive blend, 3.7b), the alpha channel only masks (a pixel with alpha exactly 0 is skipped, any other alpha scales the pixel's contribution, and the vanilla image is fully opaque with a black background). A black or alpha 0 background is therefore equivalent; a non-black background would add a visible square.
- Role of each region (for a 32 × 32 image; scale linearly for other sizes): the glow is a soft round halo, 40/255 at its brightest next to the core, falling smoothly to 0 at 16.7 pixels from the centre, coloured (v, v, 0.38 v) (a warm yellow tint) by the formula of 3.7c; the core is a hard-edged 8 × 8 square of three bright tones (a `#ffd54a` outline of 28 pixels, a `#ffffaa` ring of 20, a `#ffffd9` centre of 16), centred on the image. The image is symmetric, so its orientation on the sky (3.7b) does not matter.
- Test values for an original recipe: pixel (16, 16) is `#ffffd9`; pixel (12, 12) is `#ffd54a`; pixel (13, 13) is `#ffffaa`; pixel (0, 16) is (1, 1, 0); pixel (11, 16) is (40, 40, 16); pixel (5, 5) (d = 14.85) is (3, 3, 0), where the fit gives 2; the four image corner pixels are black.

**Moon images** (`minecraft:moon/<phase>`, paths `.../celestial/moon/<phase>.png`, eight files; all must exist or the quad buffer is built for all eight phases when the sky renderer is created, `SkyRenderer.buildMoonPhases`; a phase with no image gets the atlas's missing-texture sprite, standard atlas behaviour, inferred).
- The same format rules as the sun. The image is 32 × 32 at 40 blocks (1.25 blocks per pixel).
- Glow: identical to the sun's shape, with the colour (0.38 v, 0.57 v, v) (a cold blue tint), identical in all eight images.
- Core: the 8 × 8 square of 3.7c with the phase pattern of 3.7e; unlit `#0c121f`, terminator `#2b2f38`, lit tones the six of 3.7c; orientation on the sky per 3.7b (waxing phases lit on the high-u side, which is the sky's north side).
- Test values: `new_moon` pixel (16, 16) is `#0c121f`, pixel (12, 12) is `#2b2f38`; `first_quarter` pixel (15, 16) is `#2b2f38` (core column 3), pixel (16, 16) is a lit tone, pixel (14, 16) is `#0c121f`; `third_quarter` pixel (16, 16) is `#2b2f38` (core column 4), pixel (15, 16) lit.

**Clouds image** (`minecraft:environment/clouds`, path `assets/minecraft/textures/environment/clouds.png`).
- Renderer constraints: PNG readable by the `NativeImage` loader; **only the alpha channel is used**, a cell is solid iff alpha ≥ 10, so a replacement can be any 8-bit RGBA or palette PNG with alpha 0 and 255 (the vanilla image gets the same effect with a 1-bit greyscale PNG and a `tRNS` entry for black); no power-of-two requirement (the image is not a GPU texture); **square** (3.7f: the east and west neighbours wrap with the height) and, for an unbroken drift, any width W, since the pattern then repeats every 12 W blocks and the clock wraps at 400 W ticks; the table costs 8 bytes per pixel in memory (inferred from the `long` per cell), so 256 × 256 = 512 KiB. Larger images give a longer pattern period, not larger cells: the cell size is fixed at 12 × 4 × 12 blocks.
- Visual role: each pixel is one solid cloud cell or empty sky; solid cells touching form clouds. There is no softness, no shading and no per-pixel colour in the image: shading comes only from the face factors of 3.7f and the colour from `visual/cloud_color`.
- Statistics of the vanilla image, to match when generating a lookalike: 256 × 256; 18103 of 65536 cells solid (27.6 %); the solid cells form 596 clumps under 4-neighbour connectivity with wrap-around (largest 628 cells, then 503, 423, 305, 297; median size 7; 139 single-cell clumps); the empty cells form one connected sea of 47310 cells plus 50 small holes (the next largest 26); each row has 7 to 134 solid cells and each column 20 to 101; horizontal runs of solid cells are 1 to 34 cells long (the most common run lengths are 3 (421 runs), 2 (313) and 4 (279)); the image is not seamless in the strict sense (43 of 256 left-right and 53 of 256 top-bottom edge pixel pairs differ), which does no harm since the renderer wraps.
- Recipe for an original image (a design choice; the requirements above are the only hard ones): generate a seamless blob mask, for example by thresholding wrapped smooth noise so that about 28 % of the cells are solid, with clump widths from 1 to about 30 cells and a few large clumps of several hundred cells. With W = 256 the clouds repeat every 3072 blocks.

#### 3.7h Not in the jar, or not answered here

- There is no cloud "alpha from rain" code in `CloudRenderer`: rain and thunder change the cloud colour only through the layers of 3.5 (the alpha of `visual/cloud_color` is part of that colour).
- There is no per-pixel cloud colour and no cloud animation other than the drift of 3.7f (no vertical movement, no per-cell variation).
- The `end_sky.png` and `end_flash.png` images are not covered (3.4, Open question 14).

---

## 4. Block-break crack overlay

Source: `ClientLevel.destroyBlockProgress`, `BlockDestructionProgress`, `LevelExtractor.extractBlockDestroyAnimation`,
`LevelRenderer.submitBlockDestroyAnimation`, `ModelBakery` (`DESTROY_STAGES`), `SheetedDecalTextureGenerator`,
`RenderPipelines.CRUMBLING`, `MultiPlayerGameMode`, shader `rendertype_crumbling`.

### 4.1 Stages and textures

There are **10** destroy stages, 0 to 9. The textures are `textures/block/destroy_stage_0.png` … `destroy_stage_9.png`
(16 × 16, 8-bit grey with alpha); a second set `destroy_oit_stage_0..9.png` exists for the order-independent-transparency path (same stage numbering).

### 4.2 Progress to stage

- **Local player** (`MultiPlayerGameMode`): while the player holds the break button on a block, `destroyProgress`
  accumulates the block state's destroy progress each tick (the per-tick fraction from the mining-speed rules; the block breaks when it reaches ≥ 1.0).
  The stage shown = `destroyProgress > 0 ? (int)(destroyProgress × 10) : −1`, so stages 0..9 appear for progress in [0, 1) (stage 0 for 0 < progress < 0.1).
  The client reports its own stage to its level with the player's entity id as the breaker id.
- **Remote players and server-driven breaking**: the clientbound Block Destruction packet (05a id 0x05: breaker entity id, position, stage byte) calls the same
  `destroyBlockProgress(breakerId, pos, stage)`. A stage outside 0..9 (including 255, i.e. −1) **removes** that breaker's entry. The server
  chooses the stage (for example `floor(progress × 10)` for its own progress computation). Sending the same breaker id with a new position replaces the entry (the old
  position's entry is removed).
- **Storage**: one entry per breaker id, plus per-position sorted sets (ordered by stage, then id). If several breakers are on one block, the entry with the
  **highest stage** is drawn.
- **Expiry**: an entry whose last update is more than **400 game ticks** old is removed (inferred from the tick-difference comparison with 400 in `ClientLevel`'s per-tick cleanup).
- **Range**: only blocks whose centre is within 32 blocks of the camera (distance² ≤ 1024) are drawn.

### 4.3 Drawing

For each block to be drawn whose render shape is `MODEL` (blocks drawn by a model; not invisible or entity-rendered blocks), the block state's model parts are submitted
again, translated to the block's position, through the `crumbling` render type of the stage's texture.

- **UV generation** (`SheetedDecalTextureGenerator`, scale 1.0): the model's own UVs are ignored. For each vertex, take its position and the quad's normal; choose the face direction nearest to the
  normal; rotate the position into that face's frame (rotate Y by π, rotate X by −π/2, then rotate by the face direction's rotation quaternion), and set u = −x × scale, v = −y × scale. So the crack texture is projected flat onto each face and repeats once per block (the texture wraps).
  Thus every face of a block shows the full 16 × 16 crack texture once, in the face's own plane.
- **Blend**: source colour factor DST_COLOR, destination colour factor SRC_COLOR, alpha factors ONE and ZERO (`RenderPipelines.CRUMBLING`): result.rgb = src.rgb × dst.rgb + dst.rgb × src.rgb = 2 × src × dst. Mid-grey (0.5) texels leave the block unchanged, darker texels darken it, lighter ones brighten.
- **Alpha test**: fragments with texture alpha × vertex alpha < 0.1 are discarded.
- **Depth**: test `GREATER_THAN_OR_EQUAL`, with a depth bias (the pipeline passes 10.0 as a bias argument; whether it is the slope-scaled or the constant part was not read, Open question 4) and no depth write (inferred). The depth buffer is reversed (cleared to 0, 3.3), so "greater or equal" means "at least as near", which lets the overlay draw on the very surface it decorates. The overlay is fogged like terrain.

---

## 5. The GUI

Source: `Window` (scale), `GuiGraphicsExtractor`, `Hud`, `ContextualBar` / `ExperienceBar`, `AbstractContainerScreen`,
`InventoryScreen`, `CraftingScreen`, `InventoryMenu`, `CraftingMenu`, `AbstractContainerMenu`, `Screen`, `AbstractButton`,
`TooltipRenderUtil`, `DefaultTooltipPositioner`, `Font` and `Font$PreparedTextBuilder`, `BitmapProvider`, the sprite files under
`assets/minecraft/textures/gui/sprites`.

### 5.1 GUI scale (`Window.calculateScale`, `setGuiScale`)

The GUI is laid out in "GUI pixels"; every GUI pixel is `scale` framebuffer pixels in each direction. Let fbW × fbH be the
framebuffer size in pixels.

- The option `guiScale` is an integer; 0 means automatic.
- `calculateScale(requested, forceUnicode)`: start with s = 1. While s ≠ requested and s < fbW and s < fbH and
  floor(fbW / (s + 1)) ≥ 320 and floor(fbH / (s + 1)) ≥ 240: s += 1. Then, if `forceUnicode` is true and s is odd,
  s += 1. (`requested` = 0 never matches, so automatic picks the largest s that leaves at least a 320 × 240 GUI. A non-zero request
  stops the loop at that value if the limits allow, else at the largest value the limits allow.)
- GUI width and height: guiW = ceil(fbW / s), guiH = ceil(fbH / s). Every coordinate below is in GUI pixels with the origin at the top-left, x right, y down.

Worked: fb 1920 × 1080: s grows while 1920/(s+1) ≥ 320 and 1080/(s+1) ≥ 240: s = 4 passes (1920/5 = 384, 1080/5 = 216 < 240 fails at s+1 = 5), so s = 4, guiW = 480, guiH = 270.

All HUD sprites below are 1 GUI pixel = 1 sprite pixel. They are drawn from the GUI sprite atlas by id (`minecraft:hud/hotbar` →
`textures/gui/sprites/hud/hotbar.png`). A sprite with a `.mcmeta` `gui.scaling` of type `nine_slice` is stretched by its borders (5.9); a plain sprite is drawn at 1:1.

### 5.2 Hotbar, selection frame and off-hand slot (`Hud.extractItemHotbar`)

W = guiW, H = guiH. Positions are the sprite's top-left.

| Element | Sprite (size) | x | y |
|---|---|---|---|
| Hotbar | `hud/hotbar` (182 × 22) | W/2 − 91 (integer division) | H − 22 |
| Selection frame | `hud/hotbar_selection` (24 × 23) | W/2 − 91 − 1 + 20 × selectedSlot | H − 22 − 1 |
| Off-hand backing, when the off-hand stack is non-empty and the main arm is RIGHT | `hud/hotbar_offhand_left` (29 × 24) | W/2 − 91 − 29 | H − 23 |
| Off-hand backing, when the main arm is LEFT | `hud/hotbar_offhand_right` (29 × 24) | W/2 + 91 | H − 23 |

The off-hand is on the side opposite the main arm. Item icons (16 × 16 cell, see 5.7):

| Item | x | y |
|---|---|---|
| Hotbar slot i (0..8) | W/2 − 90 + 20·i + 2 | H − 16 − 3 |
| Off-hand item, off-hand on the left | W/2 − 91 − 26 | H − 16 − 3 |
| Off-hand item, off-hand on the right | W/2 + 91 + 10 | H − 16 − 3 |

At scale 1 with guiW = 320, guiH = 240: hotbar at (69, 218); slot 0 item at (71, 221); slot 8 item at (231, 221); the selection frame for slot 0 at (68, 217).
**Pop animation** (`extractSlot`): when the stack's pop time minus partialTick is positive (set when items are picked up or changed), p = 1 + pop/5; the icon is scaled about the cell
point (x + 8, y + 12) by (1/p, (p + 1)/2) for that frame (x scale 1/p, y scale (p+1)/2); then item decorations (5.7) are drawn unscaled.
**Attack indicator** (option `attackIndicator` = hotbar): when the attack strength scale is < 1, a small progress sprite is drawn beside the hotbar; not detailed here.

### 5.3 Crosshair

Sprite `hud/crosshair` (15 × 15) at ((W − 15) / 2, (H − 15) / 2), drawn with the `CROSSHAIR` pipeline (an inverting blend, so the cross shows against any background; the exact blend of that pipeline was not read, but the artifact defines an `INVERT` blend of source factor ONE_MINUS_DST_COLOR and destination factor ONE_MINUS_SRC_COLOR: inferred). It is drawn only in first-person view (not in third-person, 7.1), and for spectators only when they look at an entity or container. With the attack indicator option set to crosshair and a cooldown below 1, a 16 × 16 indicator is drawn at (W/2 − 8, H/2 − 7 + 16) using `hud/crosshair_attack_indicator_background`, `_progress` and `_full`.

### 5.4 Health, armour, food, air (`Hud.extractPlayerHealth` and helpers)

Drawn only when the game mode can hurt the player (survival/adventure). Let left = W/2 − 91, right = W/2 + 91, baseY = H − 39. All of these sprites are 9 × 9.

**Hearts.**

- maxHealth M = max(maxHealthAttribute, displayHealth, ceil(health)); absorption A = ceil(absorption).
- Heart slots numbered 0..(ceil(M/2) + ceil(A/2) − 1), laid out in rows of 10: slot k is at column k mod 10, row k div 10.
- rows R = ceil((M + A) / 2 / 10); rowHeight = max(10 − (R − 2), 3).
- Heart k: x = left + (k mod 10) × 8; y = baseY − (k div 10) × rowHeight.
- Jitter: if (health + absorption) ≤ 4 (the artifact tests `displayHealth + absorption ≤ 4`), y += random(0..1) (a random source seeded each frame from tickCount × 312871).
  Regeneration bounce: when the player has Regeneration, one heart index (tickCount mod ceil(maxHealth + 5)) has y −= 2.
- Each slot draws first its container sprite (`hud/heart/container`, or `container_blinking` while the damage-blink flag is on; hardcore uses `container_hardcore`), then the filled part: absorption hearts use `absorbing_*`; health hearts use `full` or `half` (plus `_blinking` for the hurt flash). Hardcore worlds use `hardcore_full`/`hardcore_half`; the effects Poison, Wither and Freezing use `poisoned_*`, `withered_*`, `frozen_*`.
  Health hearts: the last heart is `half` when health is odd. A previously higher health value is drawn as the blinking "ghost" under the current value.
- The hurt blink lasts 10 ticks (health decreased) or 6 ticks (health increased) from the change (`healthBlinkTime`), alternating each 3 ticks.

**Armour** (`extractArmor`): shown when the armour value N > 0. Row y = baseY − (R − 1) × rowHeight − 10. For i = 0..9: x = left + 8 × i; sprite `hud/armor_full` if 2i + 1 < N, `hud/armor_half` if 2i + 1 == N, else `hud/armor_empty`.

**Food** (`extractFood`): for i = 0..9: x = right − 8 × i − 9, y = baseY (= H − 39). Sprite `hud/food_empty` always, then `hud/food_full` if 2i + 1 < food, `hud/food_half` if 2i + 1 == food (Hunger effect uses the `_hunger` variants). When saturation ≤ 0, every `tickCount mod (food × 3 + 1) == 0` tick the row gets a random y offset in −1..+1.
Food is not drawn while riding a mount that has health (the mount's hearts take that slot).

**Air bubbles** (`extractAirBubbles`): drawn when the camera is in water or air supply < max. Row y = baseY − 10 = H − 49 (minus the mount-heart rows). Bubble n = 1..10: x = right − (n − 1) × 8 − 9. With air a, max m: full bubbles = ceil(a × 10 / m); a bubble n ≤ full draws `hud/air`; the bubble that just burst draws `hud/air_bursting`; empty ones draw `hud/air_empty` with a small random y offset (0 or 1) at certain ticks.

**Experience bar** (`ExperienceBar`, part of the contextual-bar slot): left = (W − 182) / 2, top = H − 24 − 5 = H − 29. Background `hud/experience_bar_background` (182 × 5) at (left, top). The progress width w = (int)(progress × 183) (clamped by the sprite to 182);
when w > 0, `hud/experience_bar_progress` is drawn clipped to its left w pixels at (left, top). The level number (when level > 0) is the text of the translation `gui.experience.level` (the number as text), centred at x = (W − textWidth) / 2, y = H − 24 − 9 − 2 = H − 35: first drawn four times in black (`#000000`) at offsets (+1, 0), (−1, 0), (0, +1), (0, −1) without shadow, then once in `#80ff20` (the int −8323296) without shadow.
Other occupants of the same slot (the jump bar `hud/jump_bar_*`, the locator bar `hud/locator_bar_*`) use the same left and top.

### 5.5 Selected item name (`extractSelectedItemName`)

When the selected hotbar stack changes (a different item or a different name), the timer is set to 40 × option `notificationDisplayTime` ticks (default option value 1.0, so 40 ticks); it counts down once per tick while the same item stays selected.
While timer > 0 and the stack is non-empty, the name is drawn centred: x = (W − textWidth) / 2, y = H − 59 (plus 14 when no health bar is shown, e.g. creative), with a backdrop. Alpha = min(255, (int)(timer × 256 / 10)), so it fades during the last 10 ticks.
The text colour is the item's rarity colour (white for common) with alpha applied; custom names are italic. The backdrop (`textWithBackdrop`) is a rectangle from (x − 2, y − 2) to (x + textWidth + 2, y + 9 + 2) filled with black at the option `textBackgroundOpacity` (default 0.5) times the alpha.

### 5.6 Container screens

`AbstractContainerScreen` default image size 176 × 166; leftPos = (guiW − imageWidth) / 2, topPos = (guiH − imageHeight) / 2 (integer division). All slot coordinates below are relative to (leftPos, topPos). A slot's item cell is 16 × 16 at the slot's (x, y); the slot's background art is 18 × 18 and is part of the screen background texture (the cell has a 1 pixel margin).

- **Background**: the in-game screens (`isInGameUi`) first draw `extractTransparentBackground`: a full-screen vertical gradient from `#c0101010` (top) to `#d0101010` (bottom) (the ints −1072689136 and −804253680). Menu screens opened without a level instead tile `textures/gui/menu_background.png` (a 32 × 32 tile) over the screen (optionally over the panorama and a blur).
- Then the container texture: a 256 × 256 texture blitted at (leftPos, topPos) taking the region (0, 0, imageWidth, imageHeight): `textures/gui/container/inventory.png` for the inventory, `textures/gui/container/crafting_table.png` for the crafting table (for the table the y is computed as (guiH − imageHeight) / 2, the same as topPos).
- **Labels**: the title at (titleLabelX, titleLabelY) = (8, 6) by default, the player-inventory label at (8, imageHeight − 94) = (8, 72); colour `#404040` (the int −12566464), no shadow. The inventory screen overrides titleLabelX to 97 (title text "Crafting"), has no inventory label; the crafting table overrides titleLabelX to 29.
- **Slot highlight** (`slot_highlight_back` / `slot_highlight_front`, 24 × 24 sprites): when the pointer is over a highlightable slot, the back sprite is drawn before the slots' items and the front sprite after, both at (slot.x − 4, slot.y − 4).
- **Drag-split preview**: while quick-crafting across slots, a hovered slot that will receive items is overlaid with a 16 × 16 white rectangle `#80ffffff` (the int −2130706433).
- **Carried item**: the cursor stack is drawn with its decorations at (mouseX − 8, mouseY − 8), above everything except the tooltip.
- **Tooltip**: see 5.8.

#### 5.6a Inventory menu (the 2 × 2 crafting inventory, `InventoryMenu`), image 176 × 166

Menu slot ids (as in the Set Container Content / Click Container packets, 05):

| Slot ids | Meaning | Position (x, y) |
|---|---|---|
| 0 | Crafting result | (154, 28) |
| 1–4 | 2 × 2 crafting grid, row-major: id 1 + col + 2 × row | (98 + 18 × col, 18 + 18 × row) → (98,18), (116,18), (98,36), (116,36) |
| 5–8 | Armour: head, chest, legs, feet | (8, 8 + 18 × i) for i = 0..3, i.e. (8,8), (8,26), (8,44), (8,62). Menu id 5 + i; the player's equipment slot index for armour is 39 − i |
| 9–35 | Main inventory, 3 rows of 9, id 9 + col + 9 × row | (8 + 18 × col, 84 + 18 × row) |
| 36–44 | Hotbar | (8 + 18 × i, 142) |
| 45 | Off-hand | (77, 62) |

The inventory screen also draws the player's model as a preview in the rectangle from (leftPos + 26, topPos + 8) to (leftPos + 75, topPos + 78), at model scale 30, with the head and body following the mouse with a factor 0.0625 (the mouse offset multiplied by 0.0625 enters the yaw and pitch of the preview). Lighting for the preview: the `PLAYER_SKIN`/`ENTITY_IN_UI` setup of 1.9.
When the recipe book is open, leftPos is shifted right; the recipe book itself is not covered here.

#### 5.6b Crafting table menu (`CraftingMenu`), image 176 × 166

| Slot ids | Meaning | Position (x, y) |
|---|---|---|
| 0 | Crafting result | (124, 35) |
| 1–9 | 3 × 3 grid, row-major: id 1 + col + 3 × row | (30 + 18 × col, 17 + 18 × row) |
| 10–36 | Main inventory | (8 + 18 × col, 84 + 18 × row) |
| 37–45 | Hotbar | (8 + 18 × i, 142) |

The 3 × 3 result slot arrow and the slot art are in the background texture. The "inventory" label is at (8, 72).

### 5.7 Item decorations (`GuiGraphicsExtractor.itemDecorations`)

For a stack drawn at cell (x, y), after the icon, in this order:

1. **Durability bar** (`itemBar`), shown when the stack is damaged (damage > 0): a black rectangle (`#000000`) covering x + 2 .. x + 15 (13 wide) and y + 13 .. y + 15 (2 tall); over it a coloured bar from x + 2 for w pixels, 1 pixel tall, at y + 13: `w = clamp(round(13 − damage × 13 / maxDamage), 0, 13)` and colour = opaque `hsv(max(0, (maxDamage − damage) / maxDamage) / 3, 1, 1)` (hue 0.333 = green when new, towards red when worn).
2. **Cooldown overlay** (`itemCooldown`): with a cooldown fraction c > 0: a white rectangle `#7fffffff` (the int 2147483647) covering x .. x + 16 horizontally and from y + floor(16 × (1 − c)) down for ceil(16 × c) pixels.
3. **Count** (`itemCount`): when the count ≠ 1 (or the caller supplies a string), the text is drawn white (`#ffffff`) with a shadow at x + 19 − 2 − textWidth, y + 6 + 3. So the right edge of the digits is at x + 17 and the text baseline box top at y + 9.

The icon itself is drawn first (see 8). Decorations never scale with the pop animation.

### 5.8 Tooltips (`GuiGraphicsExtractor.tooltip`, `DefaultTooltipPositioner`, `TooltipRenderUtil`)

- Each line is a component; a text line has width = text width and height 10. The block's width is the widest line; its height is the sum of the line heights (plus 2 extra pixels after the first line when the tooltip has a title spacing, i.e. for item tooltips).
- Position: start at (mouseX + 12, mouseY − 12). If x + width > guiW then x = max(x − 24 − width, 4). If y + height + 3 > guiH then y = guiH − height − 3.
- Background: a nine-slice drawn with `tooltip/background` and then `tooltip/frame`, each covering the rectangle with top-left (x − 3 − 9, y − 3 − 9) and size (width + 3 + 3 + 18, height + 3 + 3 + 18); the sprites are nine-slice (100 × 100, border 9), so there is a 3-pixel padding between text and the inner border.
- Text lines are drawn from (x, y), each line y += its height, with white text and shadow (`ClientTextTooltip.extractText` passes colour −1 and shadow on).

### 5.9 Sprites, buttons and screen backgrounds

- **Nine-slice** (`blitNineSlicedSprite`): the sprite's `.mcmeta` `gui.scaling` gives `type: nine_slice`, `width`, `height` (the source size) and `border` (single number or left/top/right/bottom). The destination rectangle is split with the four borders each clamped to at most half the destination size; corners are copied unscaled; edges and centre are stretched (or tiled when `stretch_inner` is false) to fill. When the destination equals the source size the sprite is blitted 1:1.
- **Buttons** (`AbstractButton`, `Button`): default height 20, widths 150 (default), 120 (small) or 200 (big). The background sprite is `widget/button` (normal), `widget/button_highlighted` (hovered or focused) or `widget/button_disabled` (inactive); the three are nine-slice 200 × 20 with border 3 (border 1 for disabled). The label is centred in the button (it scrolls if wider than the button minus a margin), drawn with shadow in the text colour of the widget (white; the disabled colour was not traced, see Open question 5). Sprite alpha is the widget alpha.
- **Slots and widgets** use sprites under `textures/gui/sprites/widget`, `container`, `hud`, `tooltip`, `boss_bar`, `toast` and others, all through this same sprite mechanism.
- **Fill helpers**: `fill(x0, y0, x1, y1, argb)` fills the half-open rectangle; `fillGradient` interpolates linearly top to bottom; `outline` draws a 1-pixel rectangle outline; `horizontalLine`/`verticalLine` draw 1-pixel lines.

### 5.10 Text rendering (`Font`, `Font$PreparedTextBuilder`, `BitmapProvider`)

- **Line height**: 9 pixels (`Font.lineHeight`). A glyph cell is 8 × 8 with ascent 7 for the default bitmap fonts (08 §10.10 (the stand-in font) documents the file layout and CobolCraft's own advance rule: the column of the rightmost ink pixel plus 2; a space advances 4).
- **Shadow**: when drawn with shadow, each glyph is drawn twice: first the shadow at an offset of +1.0 GUI pixel in x and in y (`GlyphInfo.getShadowOffset` = 1.0), coloured `scaleRGB(textColour, 0.25)` (each of r, g, b multiplied by 0.25, alpha unchanged, or the style's explicit shadow colour), then the glyph itself on top. The shadow sits slightly behind (depth difference 0.03).
- **Bold** (`Style.isBold`): the advance grows by 1.0 (`getBoldOffset` = 1.0) and the glyph is drawn twice, offset by 1.0 in x (the second draw at x + 1).
- **Italic**: the glyph quad is sheared horizontally; `BakedSheetGlyph.shearTop` and `shearBottom` return the constant 0.25, but how they combine with the glyph top and bottom positions into the x offsets was not traced (Open question 13).
- **Underline**: a 1-pixel line from the text's x − 1 (when not first) to x + advance, at y + 9 − 1 to y + 9. **Strikethrough**: a 1-pixel line at y + 4.5 − 1 to y + 4.5 (both lines are `EffectGlyph`s of depth 0.01 in front of the glyph).
- **Colour**: ARGB; text is the glyph's ink colour multiplied by the colour. The treatment of a colour whose alpha is 0 was not traced (Open question 12).
- **Provider types** in a font definition (`providers` list, `GlyphProviderType`): `bitmap` (image atlas of `chars` strings with `height`, `ascent`), `ttf` (fields `file`, `size`, `oversample`, `shift`, `skip`), `space` (an `advances` map from character to advance), `unihex` (fields `hex_file` and `size_overrides`) and `reference` (includes another font by `id`; entries may carry a `filter` object such as `{"uniform": false}`). The built-in `default` font references `include/space`, `include/default` (bitmap files `ascii.png`, `accented.png`, `nonlatin_european.png`, filtered off when the "uniform" option is on) and `include/unifont`. The earlier providers win for a character they define.
- **Bitmap glyph width**: a glyph's advance is the rightmost non-transparent column of its cell (counted from 0) plus 1, scaled by `height` / cell height and rounded to the nearest integer (+0.5 then truncated), plus 1 pixel of spacing.

---

## 6. First-person hand and held item

Source: `FirstPersonHandsAndItemsRenderer`, `FirstPersonHandsAndItems` (client state), `GameRenderer.bobView`, `bobHurt`, `LivingEntity$SwingState`,
`SwingAnimation`, `ItemTransform`, `AvatarRenderer`.

All transforms are applied to a pose stack whose starting frame is the camera space after the view bobbing (6.1): +x right, +y up, −z forward (into the screen), units = blocks.
Each transform call multiplies on the right (the first listed is applied outermost, i.e. first in the chain, to the model last).
**Sections 6.1 to 6.6 give the arm and item placement; they are complete only together with 6.7 to 6.14**, which add what the
placement text left out: the exact matrix product and the model's own transform order (6.7), the mesh of a flat item (6.8), the
projection, depth range and render state of the hand pass (6.9), the shading (6.10), block items (6.11), the shield (6.12) and
the use-animation dispatch (6.13). A client that implements only 6.1 to 6.6 with 8.2 gets the pose right and still renders a
wrong image (6.14).

### 6.1 Per-frame set-up

The order below is the order of the calls in `GameRenderer.renderItemInHand` (hurt tilt `bobHurt`, then view bobbing `bobView`) followed by the sway inside `submitHandsWithItems`.

1. Hurt tilt (`bobHurt`), applied to living camera entities. While dying: rotate Z by 40 − 8000 / (min(deathTime, 20) + 200) degrees, and then continue with the hurt test below (the function returns early only when hurtTime < 0). Otherwise, with t = hurtTime / hurtDuration (it counts down from 1 to 0 and the effect only runs while hurtTime ≥ 0): k = sin(t⁴ × π); rotate Y by −hurtDir degrees; rotate Z by −k × 14 × damageTiltStrength degrees (the option, default 1.0); rotate Y by +hurtDir degrees.
2. View bobbing (`bobView`, applied only when the option `bobView` is on and the camera entity is a player) with w = the interpolated walk distance (blocks, backwards-interpolated) and b = the bobbing amount (0..1):
   translate (sin(w·π) × b × 0.5, −|cos(w·π) × b|, 0); rotate Z by sin(w·π) × b × 3 degrees; rotate X by |cos(w·π − 0.2) × b| × 5 degrees.
   (With the option off the step is skipped, as if b = 0.)
3. Hand sway: rotate X by (cameraPitch − xBob) × 0.1 degrees, then Y by (cameraYaw − yBob) × 0.1 degrees, where xBob/yBob are the smoothed view angles that lag the real ones.

At rest (no hurt, no bobbing, no mouse movement) steps 1 to 3 are the identity and the chain of 6.3 starts from the camera frame itself.

### 6.2 Equip animation (`FirstPersonHandsAndItems.tick`)

State per hand: the displayed stack and a height h in 0..1 with previous value oh.
Each client tick: oh = h. The wanted height is 1 if the displayed stack is the player's current stack in that hand (the same item), else 0; for the main hand the wanted value is multiplied by cube(attackStrengthScale) when it is 1 (so the held item drops while the attack cooldown recharges: wanted = s³).
h += clamp(wanted − h, −0.4, 0.4). When h < 0.1 the displayed stack is replaced by the real one (so the item swaps at the bottom of the dip). If the hands are busy (riding a boat etc.) h −= 0.4 per tick instead (clamped to 0..1).
The equip offset used for drawing is E = swapScale × (1 − lerp(partialTick, oh, h)) (the swap scale is 1 normally).

### 6.3 Item in hand (the common path)

For a hand with side s = +1 for the right arm and −1 for the left (the arm is the main arm for the main hand, the opposite arm for the off hand), a swing progress p (0 for the non-swinging hand) and equip offset E:

1. **Arm transform** (`applyItemArmTransform`): translate (s × 0.56, −0.52 + E × (−0.6), −0.72).
2. **Swing** (`swingArm`), only for the swinging hand with the default `whack` swing type (6.4):
   a. translate (s × (−0.4 × sin(√p × π)), 0.2 × sin(√p × 2π), −0.2 × sin(p × π));
   b. rotate Y by s × (45 + sin(p² × π) × (−20)) degrees;
   c. rotate Z by s × sin(√p × π) × (−20) degrees;
   d. rotate X by sin(√p × π) × (−80) degrees;
   e. rotate Y by s × (−45) degrees.
3. Draw the item with the model's display transform for `firstperson_righthand` (s = +1) or `firstperson_lefthand` (s = −1), see 8.2, then the item definition's own `transformation` (identity for ordinary models), and then the item's quads (6.8). (The item is drawn using the item model resolved for the context `FIRST_PERSON_*_HAND`: the main hand uses the right context when the player's main arm is right and the left context when it is left; the off hand uses the other one, `FirstPersonHandsAndItems`.) The exact product, with all constants, is in 6.7.2; the "model's display transform" is **not** just a placement: it carries a −90° turn about the vertical axis for tools (6.7.3), which is why a tool is seen edge-on from the side and not face-on.

At rest (p = 0, E = 0) a right-hand item is at (0.56, −0.52, −0.72) in front of the camera. That is the position of the origin of the display transform (the item model's centre before the display translation), not of any corner of the sprite.

### 6.4 Swing (`LivingEntity$SwingState`, `SwingAnimation`)

- Default swing: type `whack`, duration **6 ticks** (`SwingAnimation.DEFAULT`). Duration modifiers (`getModifiedSwingDuration`): Haste with amplifier a: duration − (1 + a); Mining Fatigue with amplifier a: duration + (1 + a) × 2.
- State per tick: if a swing is active, `animation` = min(ticks / duration, 1), then ticks += 1; the swing ends (animation reset to 0) once ticks exceeds the duration.
- Value used for drawing: lerp(partialTick, previous animation, animation) (when animation wrapped to a smaller value, lerp towards animation + 1).
- Swing types: `none` (no arm motion), `whack` (above), `stab` (spear thrust, a separate animation not covered here).

### 6.5 Empty hand (`renderPlayerArm`)

With an empty main hand (and the player visible) the right/left arm model is drawn. Let s = +1 for the right arm, −1 for left, p the swing progress, E the equip offset, q = √p:

1. translate (s × (−0.3 × sin(q × π) + 0.64), 0.4 × sin(q × 2π) − 0.6 + E × (−0.6), −0.4 × sin(p × π) − 0.72);
2. rotate Y by s × 45 degrees;
3. rotate Y by s × sin(q × π) × 70 degrees, then rotate Z by s × sin(p² × π) × (−20) degrees;
4. translate (s × (−1), 3.6, 3.5); rotate Z by s × 120; rotate X by 200; rotate Y by s × (−135); translate (s × 5.6, 0, 0);
5. draw the player's arm model part (right or left hand: the `rightArm`/`leftArm` mesh plus its sleeve overlay when the corresponding skin layer is enabled), using the skin texture (7.4), with the light coordinate of the player.

### 6.6 Using items (`submitArmWithItem`)

While the local player uses an item with that hand (and the use has ticks remaining), the arm transform is chosen by the item's use animation. All use-poses start from the arm transform of 6.3 step 1 (`applyItemArmTransform`) except where noted, and the item is then drawn as in 6.3 step 3. Notation: s = +1 for the right arm and −1 for the left; u = remaining use ticks; f = the frame's partial tick; d = the total use duration; e = d − (u − f + 1) = elapsed use time in ticks. "Bob" below means the chain B(h): when h > 0.1, with k = sin((e − 0.1) × 1.3) × (h − 0.1), translate (0, k × 0.004, 0).

- **Eating and drinking** (`applyEatTransform`): a = u − f + 1; t = a / d. When t < 0.8 translate (0, |cos(a / 4 × π) × 0.1|, 0). Then k = 1 − t^27: translate (s × k × 0.6, k × (−0.5), 0); rotate Y by s × k × 90; rotate X by k × 10; rotate Z by s × k × 30. Then 6.3 step 1.
- **Bow**: step 1, then translate (s × (−0.2785682), 0.18344387, 0.15731531); rotate X by −13.935; rotate Y by s × 35.3; rotate Z by s × (−9.785). Let h = min(1, (m² + 2m) / 3) with m = e / 20. Apply B(h); translate (0, 0, h × 0.04); scale (1, 1, 1 + h × 0.2); rotate Y by −s × 45.
- **Crossbow, charging** (the crossbow while it is not charged and being used): step 1, then translate (s × (−0.4785682), −0.094387, 0.05731531); rotate X by −11.935; rotate Y by s × 65.3; rotate Z by s × (−9.785). Let h = min(1, e / chargeDuration). Apply B(h); translate (0, 0, h × 0.04); scale (1, 1, 1 + h × 0.2); rotate Y by −s × 45.
- **Crossbow, not being used**: step 1, then the swing of 6.3 step 2 for the swinging hand; when the crossbow is charged and the swing progress p < 0.001 and this is the main hand: translate (s × (−0.641864), 0, 0) and rotate Y by s × 10.
- **Trident** (thrown, charging): step 1, then translate (s × (−0.5), 0.7, 0.1); rotate X by −55; rotate Y by s × 35.3; rotate Z by s × (−9.785). Let h = min(1, e / 10). Apply B(h); translate (0, 0, h × 0.2); scale (1, 1, 1 + h × 0.2); rotate Y by −s × 45.
- **Blocking with an item that is not a shield** (the `block` use animation): step 1, then translate (s × (−0.14142136), 0.08, 0.14142136); rotate X by −102.25; rotate Y by s × 13.365; rotate Z by s × 78.05. A shield item (the test is `instanceof ShieldItem`) is only given step 1 (its model is posed by its own display transform, 6.12).
- **Brush**: `applyBrushTransform` (not reproduced; Open question 6). **Spear/thrust items**: `SpearAnimations` (`firstPersonUse` and `firstPersonAttack` are written in 34-1 §3.8; Open question 6 lists only the brush). The spear animation is flagged as having a custom arm transform, so the step 1 translate is not applied before the switch; its branch itself translates by (s × 0.56, −0.52, −0.72) (no equip term) and then calls `SpearAnimations.firstPersonUse` (6.13).
- **Spyglass**: while scoping, neither hand is drawn at all (`isScoping` returns early); the spyglass overlay takes over the screen.
- A use animation that matches none of the above gets only step 1. The mapping of the use animations to the branches is resolved in 6.13: `none`, `spyglass`, `toot_horn` and a crossbow-animation item that is not the crossbow item get nothing beyond step 1; `bundle` gets the swing of 6.3 step 2.
- **Auto spin attack** (riptide): step 1, then translate (s × (−0.4), 0.8, 0.3); rotate Y by s × 65; rotate Z by s × (−85).

### 6.7 The complete matrix chain of the hand pass

**Provenance of 6.7 to 6.14, 8.5, 8.6 and V21 to V26.** They were added in a later clean-room round about the held item. Source:
the same artifact as the README (`minecraft-26.3-client.jar`, SHA-256
`4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`). Method: static reading of the bytecode (`javap`), of the
JSON, GLSL and PNG assets in the jar, with no execution. The libraries JOML and LWJGL are **not** inside the jar, so any rule that
depends on how `org.joml` composes a rotation or builds a projection is library behaviour that was not read; each such rule is
marked "(recalled, not verified)" and listed in Open question 17, together with the plausibility checks inside the artifact that point the same way. Numbers in the
worked examples were computed from the constants below with ordinary matrix arithmetic.

#### 6.7.1 Conventions

| Topic | Rule |
|---|---|
| Vectors and products | Points are column vectors. A pose is a 4 × 4 matrix M. Every `translate`, `scale`, `rotate` and `mulPose` call of `PoseStack$Pose` replaces M by **M · X** (right multiplication). Only the call sequence was read (which `PoseStack$Pose` method calls which `Matrix4f` or `Matrix3f` method on the pose and normal matrices); that `Matrix4f.translate/scale/rotate/mul` post-multiply is library behaviour (recalled, not verified). A vertex is transformed as M · v, so the call that is made **last** acts **first** on the vertex. |
| Translation vs rotation | `translate` is a pure translation matrix T(t) placed in the product at that position. In M · T · R · S the vertex is scaled first, then rotated, then translated, and the translation is expressed in the axes of the frame M, not in the rotated axes. |
| Axes and handedness | Right-handed. View space: +x right, +y up, −z forward (into the screen). Model space of an item: the 16-pixel cube, +x = east, +y = up, +z = south; the front (SOUTH) face of a flat item looks towards +z (6.8). (recalled, not verified) The matrices Rx, Ry, Rz of `Axis.XP`, `YP`, `ZP` (`Matrix4f.rotateX/Y/Z`) are the standard active rotations: Rx(a) maps +y towards +z, Ry(a) maps +z towards +x (so +x towards −z), Rz(a) maps +x towards +y. `Axis.XN`, `YN`, `ZN` use the negated angle. |
| Euler composition | (recalled, not verified) `Quaternionf.rotationXYZ(rx, ry, rz)` (used by `ItemTransform.apply`) gives **R = Rx(rx) · Ry(ry) · Rz(rz)**: on a column vector Rz acts first, then Ry, then Rx; all three about the fixed axes of the frame (extrinsic Z, Y, X; the same matrix as intrinsic X, Y, Z). `rotationZYX(z, y, x)` (used by `ModelPart.translateAndRotate`) gives Rz · Ry · Rx. `rotationYXZ(y, x, z)` gives Ry · Rx · Rz. The reversed products are wrong (inferred, plausibility only): with Rz · Ry · Rx the third-person blocking display of the shield (6.12) puts the plate centre at head-top height with its face pointing upwards, whereas Rx · Ry · Rz puts an upright plate in front of the chest. |
| Units | The pose stack is in blocks. Item model vertices are divided by 16 when they are baked, so an item model is the unit cube [0, 1]³ (6.8). The JSON `translation` of a display transform is divided by 16 when it is loaded and then clamped to ±5 blocks (8.2). Rotations are degrees in JSON and in `rotateDegrees`; the display transform multiplies by 0.017453292 first. |
| Window coordinates | After the projection (6.9): ndc = (clip.x / w, clip.y / w), y up. Window fraction from the top-left corner: fx = (ndc_x + 1) / 2, fy = (1 − ndc_y) / 2. Pixels = fraction × framebuffer size. |

#### 6.7.2 The chain, in order

Per frame the hand pass (`GameRenderer.renderItemInHand`, called from `render3dHud` after the world has been drawn) builds one pose
stack P and one model-view matrix V, and draws with the hand projection (6.9). A vertex of the item's mesh, in item model units
(pixels / 16), reaches the screen as

**clip = Proj_hand · V · P · v**, with **V = Q⁻¹ and P = Q · H** at the moment the item is submitted, where Q = the camera's rotation
and H is the hand placement. Therefore V · P = H and the view-space position of a vertex is simply **H · v**.

Q is the camera rotation quaternion. Read: `Camera.setRotation(yaw, pitch)` builds it with `Quaternionf.rotationYXZ(π − yaw·0.017453292, −pitch·0.017453292, 0)` (yaw and pitch in radians; yaw 0 = looking south, positive pitch = looking down). Recalled, not verified: that this call equals Ry(π − yaw) · Rx(−pitch), so Q = Ry(π − yaw) · Rx(−pitch). V is `CameraRenderState.viewRotationMatrix`, the conjugate (inverse) of Q (`Camera.getViewRotationMatrix`). The pose stack starts as the identity, is multiplied by Q (= the inverse of V) first, and V is pushed on the model-view stack (`RenderSystem.getModelViewStack`), which the draw reads when it writes the dynamic-transform uniform (`RenderType.draw` uses `getModelViewMatrixCopy`). **The Q · … · Q⁻¹ sandwich matters for the normal vector (the purpose is inferred):** the pose stack's normal matrix does not contain V, so the normals that leave the pose stack are in world orientation (6.10). Positions are unaffected, because V cancels Q exactly.

H, as a left-to-right product (leftmost acts last on the vertex), for a flat item in the right hand (s = +1) at rest or swinging:

| # | Factor | Value | Section |
|---|---|---|---|
| 1 | Hurt tilt BH | 6.1 step 1 (identity when not hurt and not dying) | 6.1 |
| 2 | View bobbing BV | 6.1 step 2 (identity when the option is off) | 6.1 |
| 3 | Sway, X | Rx((viewXRot − xBob) × 0.1°) | 6.1 |
| 4 | Sway, Y | Ry((viewYRot − yBob) × 0.1°) | 6.1 |
| 5 | Arm transform A | T(s × 0.56, −0.52 + E × (−0.6), −0.72) | 6.3 step 1 |
| 6 | Swing (only the swinging hand, `whack` type) | T(s × (−0.4 × sin(√p π)), 0.2 × sin(√p 2π), −0.2 × sin(p π)) · Ry(s × (45 + sin(p² π) × (−20))) · Rz(s × sin(√p π) × (−20)) · Rx(sin(√p π) × (−80)) · Ry(s × (−45)) (`swingArm` then `applyItemArmAttackTransform`) | 6.3 step 2 |
| 7 | Display transform D | T(t) · Rxyz(rx, ry, rz) · S(k) · T(−½, −½, −½); t = translation / 16, left hand mirrored (8.2) | 8.2, 6.7.3 |
| 8 | Item transformation L | the `transformation` of the item definition, composed down the definition tree (identity for an ordinary `minecraft:model`; scale (1, −1, −1) for the shield) | 8.5 |
| 9 | Vertex | position / 16 of the baked quad (6.8) | 6.8 |

Factors 7 to 9 are exactly what `ItemStackRenderState$LayerRenderState.submit` does: it pushes the pose, applies `ItemTransform.apply(leftHand, pose)` (factor 7), multiplies by the layer's local transform (factor 8) and submits the quads. The swing is only applied to the hand whose swing is running (`SwingDescription.hand`), for the `whack` type; for other use animations 6.6 and 6.13 apply.

There is **no** extra rotation, translation or scale for "tool", "handheld" or "sword" items between factors 6 and 7: the difference between `item/generated` and `item/handheld` is only their `display` data (8.2, 6.7.3). Nothing in the hand renderer depends on the item type except the use-animation branches (6.6, 6.13) and the map and empty-hand branches.

#### 6.7.3 What the display transform contains for a flat item

For a model that reaches `item/generated` or `item/handheld` (a tool, sword, stick, food, material) the right-hand first-person entry is
(`models/item/handheld.json`, and the same numbers in `generated.json`): rotation (0, −90, 25), translation (1.13, 3.2, 1.13) (sixteenths), scale (0.68, 0.68, 0.68).
So D = T(0.070625, 0.2, 0.070625) · (Ry(−90°) · Rz(25°)) · S(0.68) · T(−0.5, −0.5, −0.5) (Rx(0) is the identity). Multiplied out:

| D (right hand, rows = view x, y, z) | model x | model y | model z | constant |
|---|---|---|---|---|
| view x | 0 | 0 | −0.68 | 0.410625 |
| view y | 0.28738 (= 0.68 sin 25°) | 0.61629 (= 0.68 cos 25°) | 0 | −0.251835 |
| view z | 0.61629 (= 0.68 cos 25°) | −0.28738 (= −0.68 sin 25°) | 0 | −0.093830 |

and with the arm transform at rest (A = T(0.56, −0.52, −0.72)) the whole placement is **M = A · D**: the same 3 × 3 block and the constant column
(0.970625, −0.771835, −0.813830). Reading it:

- **The sprite's horizontal axis (model +x, left to right in the picture) points towards the camera and up**: (0, 0.423, 0.906) × 0.68 blocks per 16 pixels. The sprite's vertical axis (model +y, up in the picture) points up and slightly forward: (0, 0.906, −0.423) × 0.68. The sprite's front normal (model +z) is view −x: the front face looks to the left.
- **The sprite is therefore a vertical plate in the plane x = const that runs along the line of sight, seen obliquely.** It sits to the right of the camera (x ≈ +0.61) and spans view depth from about 0.2 to 1.1 blocks. At rest it is **not** edge-on: the cosine between the front normal and the line of sight is 0.64 at the plate centre, 0.77 at the top-right corner and 0.48 at the bottom-left corner. It is foreshortened horizontally and stretched by perspective at its near end. **Orientation consequence (inferred, it depends on the composition order of Open question 17):** the head end of the sprite (high x and y) is nearer to the camera than the handle end; for example texel (10, 3) of the pickaxe is at view depth 0.634 and texel (2, 14) at 0.745. The picture is an oblique view in the lower right, handle off the bottom edge, head near the right edge. Only in the mid-swing frame of V22 (p = 0.5) is the plate close to edge-on. This is the picture that the artifact's own data produce (V21): it was computed from the read constants and not compared with a rendering, and it depends on the library rules of Open question 17. A plate seen this obliquely is therefore not by itself a sign of a client error.
- The model's own centre (0.5, 0.5, 0.5) lands at view (0.63, −0.32, −0.65) (= A applied to the display translation).

The **left hand** uses the same matrices with s = −1 in A and with the mirrored display data (rotation y and z negated, translation x negated). Which entry gets mirrored depends on the model file. **`item/handheld`** (tools, swords, the stick; the pickaxe's chain reaches it first) has its own `firstperson_lefthand` entry (0, 90, −25) with the same translation as the right hand; the mirroring is applied to it **again**, giving rotation (0, −90, 25) and translation x −1.13: the same rotation as the right hand with a mirrored position. The visible face is the back quad of the sprite (normal view +x, the camera is at x < 0). Its u still grows with +x (6.8), which seen from behind is the reversed picture; the plate is also the mirror of the right-hand plate, and the two reversals combine into an exact mirror image of the right-hand picture: a texel at model (x, y) lands at ndc (−X, Y) when the right hand's front-quad texel at the same (x, y) lands at (X, Y) (checked at three texels, e.g. (10.5, 12.5): (0.7722, −0.2293) right, (−0.7722, −0.2293) left). **`item/generated`** (the apple and other non-tool items) has **no** `firstperson_lefthand` entry (`models/item/generated.json` lists only the right-hand one), so its left hand uses the right-hand entry mirrored **once**: rotation (0, 90, −25), translation x −1.13, with the 3 × 3 block ((0, 0, 0.68), (−0.28738, 0.61629, 0), (−0.61629, −0.28738, 0)) and the constant (−0.97063, −0.48445, −0.19754) in A · D. Here the front quad is the visible one (front normal view +x) and the result is **not** an exact mirror of the right-hand picture: the same sample texel (10.5, 12.5) lands at (−0.5923, −0.3310) on the front quad (the handheld left hand gives (−0.7722, −0.2293) on the back quad). If a model's own chain has no `firstperson_lefthand` anywhere, the right-hand entry is used and mirrored once (8.2).

### 6.8 The mesh of a flat item (`builtin/generated`, `ItemModelGenerator`)

A flat item is **not** one quad. For every texture layer `layer0` … `layer4` (read in order, stopping at the first missing slot) the generator bakes (`ItemModelGenerator.bakeExtrudedSprite`, `getSideFaces`):

1. one **front quad** (facing SOUTH, +z), 2. one **back quad** (facing NORTH, −z), and 3. one **side quad** for every edge between an opaque texel and a transparent neighbour (or the sprite border). A texel is transparent when its alpha is 0 (`SpriteContents.isTransparent`); a position outside the sprite counts as transparent; for an animated sprite the union over its unique frames is used. All quads of one layer have the same `MaterialInfo`; all quads are "unculled" (they are never removed by face culling of neighbouring blocks, which has no meaning for items).

Model space is in pixels here (0 … 16 in x and y, y up; the divide by 16 happens at the end). z runs from **7.5 to 8.5**: the plate is exactly 1 pixel thick and is centred on z = 8, i.e. on the model centre. `s_x = 16 / spriteWidth`, `s_y = 16 / spriteHeight` scale a sprite pixel to model pixels (1 for a 16 × 16 sprite). A sprite pixel (x, y) is counted from the **top-left** of the image (y down); its model rectangle is x · s_x … (x + 1) · s_x and 16 − (y + 1) · s_y … 16 − y · s_y.

**Front and back quad** (vertex order is the canonical order of the quad's final facing, 1.3c; the same order defines which texture coordinate each vertex gets):

| Quad | Vertex 0 | Vertex 1 | Vertex 2 | Vertex 3 |
|---|---|---|---|---|
| Front (SOUTH, z = 8.5), position | (0, 16) | (0, 0) | (16, 0) | (16, 16) |
| Front, texture coordinate (fraction of the sprite) | (0, 0) | (0, 1) | (1, 1) | (1, 0) |
| Back (NORTH, z = 7.5), position | (16, 16) | (16, 0) | (0, 0) | (0, 16) |
| Back, texture coordinate | (1, 0) | (1, 1) | (0, 1) | (0, 0) |

On both quads the texture coordinate u grows with +x, so the front shows the sprite upright and un-mirrored when looked at from +z, and the back shows it **left-right reversed** (a mirror image) when looked at from −z: seen from behind, +x is on the viewer's left. Texture coordinates are fractions of the sprite (0 = top/left of the image, v grows downwards) and are mapped into the atlas rectangle of the sprite by `TextureAtlasSprite.getU(f) = u0 + (u1 − u0) · f` (and the same for v).

**Side quads.** For the opaque pixel (x, y) and each of the four neighbours that is transparent, one quad, with the sprite pixel coordinates (x, y) and the model pixel rectangle above (the quad spans z 7.5 … 8.5 and one pixel edge). The final facing is the outward normal of the edge:

| Neighbour that is transparent | Final facing | Plane | Vertex 0 | Vertex 1 | Vertex 2 | Vertex 3 | Texture coordinates of vertices 0 to 3 (pixel units; divide by sprite width and height) |
|---|---|---|---|---|---|---|---|
| above (y − 1) | UP | y = 16 − y · s_y | (min x, min z) | (min x, max z) | (max x, max z) | (max x, min z) | (x + 0.1, y + 0.1), (x + 0.1, y + 0.9), (x + 0.9, y + 0.9), (x + 0.9, y + 0.1) |
| below (y + 1) | DOWN | y = 16 − (y + 1) · s_y | (min x, max z) | (min x, min z) | (max x, min z) | (max x, max z) | (x + 0.1, y + 0.1), (x + 0.1, y + 0.9), (x + 0.9, y + 0.9), (x + 0.9, y + 0.1) |
| left (x − 1) | WEST | x = x · s_x | (max y, min z) | (min y, min z) | (min y, max z) | (max y, max z) | (x + 0.9, y + 0.1), (x + 0.9, y + 0.9), (x + 0.1, y + 0.9), (x + 0.1, y + 0.1) |
| right (x + 1) | EAST | x = (x + 1) · s_x | (max y, max z) | (min y, max z) | (min y, min z) | (max y, min z) | (x + 0.9, y + 0.1), (x + 0.9, y + 0.9), (x + 0.1, y + 0.9), (x + 0.1, y + 0.1) |

("min" and "max" are the true extremes on the model axes, y up; max z = 8.5, min z = 7.5.) All texture coordinates of a side quad lie **inside the pixel**, 0.1 of a pixel away from its edges, so every side wall is the flat colour of the edge texel and bilinear filtering cannot bleed a neighbour into it. Worked check, pixel (6, 2) with a transparent left neighbour: WEST quad at x = 6, y from 14 to 13, vertices (6, 14, 7.5) uv (6.9, 2.1); (6, 13, 7.5) uv (6.9, 2.9); (6, 13, 8.5) uv (6.1, 2.9); (6, 14, 8.5) uv (6.1, 2.1).

**Order.** The vertex order and texture-coordinate pairing in the table above are canonical (the order of 1.3c for the quad's final facing); an implementation may emit the four corners in any order as long as each corner keeps its texture coordinate and the quad's winding follows 6.9.

**Counts.** 2 + the number of exposed edges. The wooden pickaxe sprite (`textures/item/wooden_pickaxe.png`, 16 × 16, alpha only 0 or 255, 7 opaque colours) has 74 quads: 1 front, 1 back, 18 UP, 18 DOWN, 18 WEST, 18 EAST. A sprite with partially transparent texels still counts a texel as opaque when alpha ≠ 0; such a sprite is classified translucent (6.9).

**Layers, tint and material.** Layer n gets tint index n. The quad colour is the item's tint list entry n when the item definition has one (08 §6.4), else white. Generated quads have no shade override and no light emission. The transparency class of a layer is computed from its sprite: opaque / transparent (alpha only 0 or 255) / translucent (other alpha values); a translucent layer is drawn in the translucent phase with blending, the others in the solid phase with a cut-off (6.9). All quads of one item model must be in one atlas, either the items atlas or the blocks atlas.

**Which atlas.** A generated item's sprite is looked up in the **items atlas** (`textures/atlas/items.png`, built from `atlases/items.json`: the directory `textures/item` with prefix `item/`, plus the armour-trim permutations). `item/wooden_pickaxe` is in that atlas. The sprites of block models (6.11) are in the **blocks atlas** (`atlases/blocks.json`: `textures/block` with prefix `block/` and a few entity sprites). Each baked quad carries its own sprite and therefore its atlas; sampling a tool's UV rectangle in the blocks atlas returns unrelated block texels.

### 6.9 Projection, depth range and render state of the hand pass

The hand is drawn by its own pass with its own projection and a freshly cleared depth buffer, after the world and before the GUI.

| Item | Value (source) |
|---|---|
| When | The hand is drawn only for a local player in first-person view who is awake, with the HUD shown, not in spectator mode and not in panoramic mode. |
| Order in the frame | `renderLevel` draws the world (`LevelRenderer.render`) and then calls `render3dHud`, so the hand is drawn before `applyPostEffects`: set the hand projection, clear the depth texture to **0.0**, draw the hand's submit nodes, draw the screen effects (fire, underwater overlay) with the same projection, set the fog uniform to "none", draw the 3-D crosshair if enabled; later the GUI is drawn (after clearing the main depth to 0.0 again). When post effects are active (`appliedPostEffects` not empty) the hand is drawn with the depth attachment of a separate `hud3DTarget` and its depth is afterwards merged into the main depth by `integrate3DHudDepth`; otherwise it is drawn with the main target's depth, which was just cleared. In both cases the hand pass does **not** depth-test against the world: the world's depth is gone (or never present) and the hand always overdraws it. |
| Colour target | the main render target's colour texture, not cleared (the world picture stays) |
| Projection | perspective, vertical field of view `hudFov`, aspect = window width / height in pixels (`WindowRenderState`), near plane 0.05 (the literal 0.05 passed to `Projection.setupPerspective`; `Camera.PROJECTION_Z_NEAR` is 0.05), far plane `depthFar` |
| `hudFov` | `Camera.calculateHudFov`: the constant **70.0** (`Camera.BASE_HUD_FOV`), modified only by `modifyFovBasedOnDeathOrFluid`. **It does not use the `fov` option and it ignores the sprint/speed/bow field-of-view modifier.** Modifiers: (a) when the camera entity is living and dead or dying: fov / (2 × (1 − 500 / (min(deathTime + partialTick, 20) + 500)) + 1); (b) when the camera is in lava or water: fov × (1 + fovEffectScale × (0.85714287 − 1)) (`Mth.lerp(fovEffectScale, 1, 0.85714287)`), which is × 0.857 with the option's default 1.0. Normal play: exactly 70°. |
| `depthFar` | `Camera.update`: max(effectiveRenderDistance × 16 × 4, cloudRange × 16) blocks; the render-distance term is 768 at the default render distance 12, and 2048 if the default cloud range is 128 (read indirectly, Open questions 10 and 20), so the far plane is 2048 at default settings (inferred). The same value is the far plane of the world projection. The far plane only affects the depth values, never the x and y of a vertex. |
| World projection, for contrast | the same near and far, vertical fov = `fov` option (30 … 110, default 70) × lerp(partial, previous, current `fovModifier`), then the same death/fluid modification (`Camera.calculateFov`); `fovModifier` is updated each tick by fovModifier += 0.5 × (target − fovModifier), clamped to 0.1 … 1.5, with target from `AbstractClientPlayer.getFieldOfViewModifier(firstPerson, fovEffectScale)` (not traced). The hand does not follow it. |
| Matrix | Read: `Projection.getMatrix` calls `Matrix4f.setPerspective(fov·0.017453292, width/height, zFar, zNear, zZeroToOne)`, that is, with the **far value loaded before the near value** (the parameters of the library method are named zNear, zFar in that order), and `render3dHud` passes (near 0.05, far `depthFar`, `hudFov`, window width, window height) to `Projection.setupPerspective`. Recalled, not verified: the library's formula for that call, which makes it a reversed depth range. With f = 1 / tan(fov / 2), a = aspect, n = 0.05, F = far, w = −z_view: clip.x = (f / a) · x_view, clip.y = f · y_view, clip.w = w, and the window depth is d(w) = n · (F − w) / (w · (F − n)) for the zero-to-one convention (d(n) = 1, d(F) = 0). At the defaults f = 1.428148 and f / a = 0.803333 for 16:9. x and y are independent of n and F. |
| Depth state | all item pipelines use the default depth state: compare **greater-or-equal** (reversed depth: nearer fragments have larger d) with **depth write on** (`DepthStencilState.DEFAULT`). Equality passes: coplanar layers of one item (the layers of `layer0`…`layer4` share z 7.5 … 8.5) are resolved by draw order, later wins. A client with a conventional depth range uses "less-or-equal" and clears to the far value. |
| Face culling | A client that uses only OpenGL (or a GL-style software rasteriser) should enable back-face culling with **counter-clockwise front faces** and apply a depth convention consistently: either the reversed one stated above (clear 0, greater-or-equal) or its conventional equivalent (clear to the far value, less-or-equal) with the same ordering (nearer wins, equal passes). **Back-face culling is on** for item pipelines (`RenderPipeline` cull defaults to true and the item snippet does not change it). Front faces are those whose projected vertices, in the y-up NDC of the table above, run **counter-clockwise** in the order the quad lists them (GL backend: no front-face call, so the default counter-clockwise; Vulkan backend: `frontFace` clockwise with back culling, where the y flip of that API is applied elsewhere and was not traced, Open question 18). The canonical vertex order of 6.8 and 1.3c is counter-clockwise seen from outside the face. |
| Pipeline of ordinary quads | `ITEM_CUTOUT` (`item_cutout`): shaders `core/item`, vertex format `ENTITY` (position, colour, uv, overlay uv, light uv, normal), quads, **no blending**, colour write all four channels, shader constant `ALPHA_CUTOUT` = 0.1: a fragment whose texture alpha < 0.1 is discarded. |
| Pipeline of translucent quads | `ITEM_TRANSLUCENT` (`item_translucent`): the same plus blending with colour factors (source alpha, 1 − source alpha) and alpha factors (1, 1 − source alpha), results sorted on upload; the same 0.1 cut-off still discards. Also see this document's Open question 23 (order-independent transparency pipelines exist; not traced). |
| Draw order | the quads of an item are split by `ItemQuads.split` into a translucent list and a solid list (`SubmitNodeCollection.submitItem`); the solid list goes to the solid phase and the translucent list to the translucent phase of the collector; the translucent phase is drawn after the solid one (inferred from the phase names). |
| Textures and uniforms | sampler 0 = the atlas of the quad's sprite (6.8); sampler 1 = the overlay texture, always sampled at the `NO_OVERLAY` texel (no tint); sampler 2 = the **level** light map (1.8), not the GUI's `UiLightmap`; uniform blocks Projection (the hand projection above), DynamicTransforms (ModelViewMat = the camera view rotation V, TextureMat, ColorModulator (taken as 1, 1, 1, 1), ModelOffset), Fog, Lighting (6.10), Globals. |
| Fog | the fog uniform that is bound when the hand is drawn was not traced (the "none" setting is installed only after the hand and the screen effects); at one block distance the world fog has no visible effect except in water, lava or blindness (Open question 19). |

### 6.10 Shading of a held item (`core/item` shader, `Lighting`)

Per vertex (`item.vsh`): lightAccum = min(1, (max(0, n · L0) + max(0, n · L1)) × 0.6 + 0.4); vertexColor = (colour.rgb × lightAccum, colour.a), where colour is the quad colour (white or the tint, 6.8) and n is the vertex normal that `VertexConsumer.putBakedQuad` produces: the **unit vector of the quad's final facing** transformed by the pose's normal matrix (which for rotation and uniform positive scale is just the rotation part, no renormalisation needed). Per fragment (`item.fsh`): c = texture(sampler 0); discard if c.a < 0.1; c ×= vertexColor × ColorModulator; c.rgb = mix(overlay.rgb, c.rgb, overlay.a) (identity for `NO_OVERLAY`); c ×= lightMapColor; then fog.

| Quantity | Value |
|---|---|
| Light directions during the hand pass | the **`LEVEL`** entry of `Lighting`, set by `LevelRenderer` before the hand and not changed until the GUI sets `ITEMS_3D`: in a dimension with the default cardinal-lighting type L0 = normalize(0.2, 1.0, −0.7) = (0.16169, 0.80845, −0.56592) and L1 = normalize(−0.2, 1.0, 0.7) = (−0.16169, 0.80845, 0.56592); in the Nether type L0 as above and L1 = normalize(−0.2, −1.0, 0.7) (`Lighting.updateLevel`; the dimension type picks it). These are **world** directions. |
| Normal space | world orientation: n_world = Q · (rotation part of H) · n_model, with Q = Ry(π − yaw) · Rx(−pitch) (6.7.2). For the pickaxe's front face n_view = R_D · (0, 0, 1) = (−1, 0, 0), so n_world = Q · (−1, 0, 0). A client that keeps normals in view space and uses the world directions above shades the item wrongly and does not change with the camera angle. |
| Light coordinate | one value for every quad: the avatar's `lightCoords` = pack(block, sky) = block × 16 + sky × 16 × 65536 of the block that contains the player's eye position (`getLightProbePosition`, 34-1; block light forced to 15 while the player is on fire), then `QuadInstance.getLightCoordsWithEmission` with the quad's emission (0 for generated quads, the face's `light_emission` for block models). The vertex shader reads it as the two integers (block × 16, sky × 16) and samples the level light map at clamp(light / 256 + 1/32, 1/32, 31/32) on both axes (`sample_lightmap`, the same index as 1.4 and 1.8). |
| Not used | no per-face constant table (1.1), no ambient occlusion, no `ITEMS_FLAT` and no `ITEMS_3D`. |

Brightness examples (L as above, n_world as defined, camera yaw 0 = looking south, pitch 0): the pickaxe's front face 0.4970; its upward-facing edge walls 1.0; its downward-facing edge walls 0.4000; its sprite-right edge walls (view normal (0, 0.423, 0.906)) 0.9127. The front-face brightness changes with the camera: 0.4970 at yaw 0 and 180, 0.7395 at yaw 90 and 270. These factors multiply a sprite whose own colours are dark browns (the opaque texels of the wooden pickaxe range from (32, 24, 10) to (136, 102, 38)), so a correctly lit held wooden pickaxe is a **dark brown** object by design; V21, V22 and V26 give more values.

### 6.11 Block items in the hand

A block item (`items/<block>.json` with `minecraft:model` naming the block model, for example `block/crafting_table` or `block/dirt`) is the block model's own elements baked the usual way (08 §5): each element becomes up to six quads with the face-table order of 1.3c and the texture coordinates of the face, model positions divided by 16, with the **cull-face restriction ignored** (every face of the cube is present, `QuadCollection.getAll`); the sprites are in the blocks atlas (6.8). `block/block` supplies `firstperson_righthand`: rotation (0, 45, 0), translation (0, 0, 0), scale (0.40, 0.40, 0.40) and `firstperson_lefthand`: rotation (0, 225, 0) with the same translation and scale; the left entry is mirrored a second time on use (rotation y = −225° ≡ 135°) (8.2). A cube model (parent chain `block/cube` → `block/block`, `elements` from 0 to 16) therefore has D = T(0) · Ry(45°) · S(0.4) · T(−½, −½, −½): the cube centre sits at the arm anchor and the cube is 0.4 blocks wide. With A at rest the matrix is M = A · D:

| M (right hand, rows = view x, y, z) | model x | model y | model z | constant |
|---|---|---|---|---|
| view x | 0.28284 | 0 | 0.28284 | 0.27716 |
| view y | 0 | 0.40000 | 0 | −0.72000 |
| view z | −0.28284 | 0 | 0.28284 | −0.72000 |

The eight corners, their view-space positions, NDC and the visible faces are in V23. At rest the faces that face the camera are UP and WEST; SOUTH, NORTH, EAST and DOWN are back-facing and culled (SOUTH is a marginal case: the camera is just on its back side, dot −0.087). Shading uses 6.10 (LEVEL lights, world normals): at yaw 0, pitch 0 the UP face is 1.0000 and the WEST face 0.7087; the same two faces at yaw 90 are 1.0000 and 0.5715. The six faces of a cube are never lit by the per-face table of 1.1 in the hand.

### 6.12 The shield (closes Open question 23 of 34-1 and the shield item of 6.6 and 7.5)

**Item definition** (`items/shield.json`): a `minecraft:condition` on the property `minecraft:using_item` with `on_false` = a `minecraft:special` item whose `base` is `item/shield` and `on_true` = a `minecraft:special` item whose `base` is `item/shield_blocking`, both with the special renderer `minecraft:shield`; the condition carries the `transformation` {scale (1, −1, −1), translation 0, rotations identity}. The `base` model supplies the display data and the particle sprite; the special renderer draws the geometry. The chain is the one of 6.7.2: … · D(base model, context) · L · (the shield model's parts). L = scale(1, −1, −1) is applied **once**, and it comes from the item definition. Read: `items/shield.json` carries the transformation (scale (1, −1, −1)); `ShieldSpecialRenderer.submit` (the draw path) contains no transform call and does not touch `DEFAULT_TRANSFORMATION`, whose only occurrence in that class is its own definition; the constant is read by the data generators (`ItemModelGenerators` reads the shield's and the trident's, `BlockModelGenerators` and `BuiltInBlockModels` read the conduit's), which is where the same value gets written into the JSON; the conduit and trident renderers define their own constants. So the draw path never applies the constant a second time. The blocking model is chosen while the player is using the item.

**Display data** (`models/item/shield.json` and `shield_blocking.json`; `gui_light` front; the contexts not listed are absent in `shield_blocking`; neither model has a parent, so an absent context means no display transform at all, only the −0.5 recentring of 8.2):

| Context | `item/shield` rotation / translation / scale | `item/shield_blocking` |
|---|---|---|
| firstperson_righthand | (0, 180, 5) / (−10, 1.75, −10) / 1.25 | (0, 180, −5) / (−15, 3.25, −11) / 1.25 |
| firstperson_lefthand | (0, 180, 5) / (10, 0, −10) / 1.25 | (0, 180, −5) / (5, 5, −11) / 1.25 |
| thirdperson_righthand | (0, 90, 0) / (10, 6, −4) / 1 | (45, 155, 0) / (−3.49, 11, −2) / 1 |
| thirdperson_lefthand | (0, 90, 0) / (10, 6, 12) / 1 | (45, 155, 0) / (11.51, 7, 2.5) / 1 |
| gui | (15, −25, −5) / (2, 3, 0) / 0.65 | the same |
| fixed | (0, 180, 0) / (−4.5, 4.5, −5) / 0.55 | none |
| on_shelf | (0, 0, 0) / (11, 18.5, 8.7) / 1.4 | none |
| ground | (0, 0, 0) / (2, 4, 2) / 0.25 | none |

The left-hand entries are mirrored once more on use (8.2): translation x and rotation y, z negated.

**Geometry** (`ShieldModel.createLayer`, 64 × 64 texture, an ordinary entity model, parts in pixels, entity model space y down): part `plate`: texture offset (0, 0), one cuboid origin (−6, −11, −2), size (12, 22, 1); part `handle`: texture offset (26, 0), one cuboid origin (−1, −3, −1), size (2, 6, 6); both with the zero pose. The cuboids use the face layout of 7.4 (the front is the face at the smallest z). Texture: `entity/shield/shield_base_nopattern.png` when the item has neither banner patterns nor a base colour, otherwise `entity/shield/shield_base.png` (both 64 × 64, in the `shield_patterns` atlas, directory `textures/entity/shield`), drawn with the entity-solid render type (pipeline `entity_solid`: shaders `core/entity`, the default depth state of 6.9 (greater-or-equal, depth write), culling **not** disabled, no blending, overlay input `NO_OVERLAY`; the pipeline and its snippet define neither `PER_FACE_LIGHTING` nor `NO_CARDINAL_LIGHTING`, so the vertex stage applies the same two-light mix as 6.10 with the `LEVEL` lights, read from `entity.vsh` and the snippet definitions); with patterns or a base colour the banner pattern layers are drawn over the plate by `BannerRenderer.submitPatterns` (patterns themselves are not covered here). An enchanted shield adds the glint. Quad colour white, light = 6.10.

After L the plate occupies z from +1 to +2 and the handle z from −5 to +1, y is up, and the decorated front face (originally at z = −2) looks towards +z.

**First person.** The chain is 6.7.2 with the items above and the arm transform A of 6.3 step 1 (the shield has no swing branch of its own; a shield swing, if any, comes from 6.3 step 2 for the hand that swings). While blocking the `block` use animation gives a shield only step 1 (6.6). Numbers for the right hand at rest and blocking (16:9, E = 0; the full tables are in V24):

- not blocking: M = A · D · L has the 3 × 3 block ((−1.24524, −0.10894, 0), (0.10894, −1.24524, 0), (0, 0, 1.25)) and the constant (0.50315, −1.08772, −0.72000); the decorated front looks away from the player (view −z) and the player sees the inner face and the handle, which sticks out towards the camera; the plate's top edge is at view y ≈ −0.19 … −0.27, i.e. window fy 0.66 … 0.74, and the shield rises from the bottom edge, its x range about 0.48 … 1.03 of the width (cut by the right edge);
- blocking: 3 × 3 block ((−1.24524, 0.10894, 0), (−0.10894, −1.24524, 0), (0, 0, 1.25)), constant (0.29959, −0.88502, −0.78250); the plate's top edge is at fy 0.49 … 0.56 (just below the screen centre) and its x range is 0.39 … 0.89 of the width: raised and moved towards the centre.

**Third person** (`ItemInHandLayer.submitArmWithItem`): for the arm that holds the item, with the entity placement of 7.3 already applied: (1) `translateToHand`: translate/rotate by the model's root part (`root.translateAndRotate`), then by the arm part (`translateAndRotate`: translate(x/16, y/16, z/16) then the quaternion rotationZYX(zRot, yRot, xRot) = Rz · Ry · Rx; the arm pivot is (−5, 2, 0) for the right arm and (5, 2, 0) for the left; for a slim arm the part's x is moved by +0.5 (right) or −0.5 (left) pixel during this call, so the pivot is (−4.5, 2, 0) or (4.5, 2, 0), `PlayerModel.translateToHand`); (2) Rx(−90°) then Ry(180°); (3) translate(k × 1/16, 2/16, −10/16) with k = +1 for the right arm and −1 for the left (adult; a baby uses k = 0, y = 1/16 and z = −4.5/16); (4) the display transform D of the item model for the context `THIRD_PERSON_RIGHT_HAND` / `LEFT_HAND` (left mirrored again); (5) L; (6) the shield parts. Three special cases leave a held shield unchanged: a stab-type swing adjustment (spears only; a shield swings with the default whack type), the use-animation hook of the arm pose (a no-op except for the `SPEAR` pose, so nothing for `ITEM` and `BLOCK`), and a "held to the eye" replacement of the whole placement used only for the spyglass (`heldOnHead`, set by `AvatarRenderer` for the spyglass; it needs the avatar to be using an item with this arm and a swing animation below 1e-5). The arm's rotation is the arm pose of 7.5: **not blocking**, a non-empty hand has the `ITEM` pose (xRot = xRot × 0.5 − 0.31415927, yRot = 0; with the walk term zero this is xRot = −0.31416, arm raised 18° forwards); **blocking** (the hand is using an item whose use animation is `block`, `AvatarRenderer.getArmPose`) the `BLOCK` pose.

The blocking pose (`HumanoidModel.poseBlockingArm(arm, isRight)`): xRot = xRot × 0.5 − 0.9424779 + clamp(head.xRot, −1.3962634, 0.43633232); yRot = (−30° for the right arm, +30° for the left, in radians: ∓0.5235988) + clamp(head.yRot, −0.5235988, 0.5235988). The three shield constants of `HumanoidModel` are exactly these clamp bounds: `HIGHEST_SHIELD_BLOCKING_ANGLE` = −1.3962634 (lower bound of the head pitch term), `LOWEST_SHIELD_BLOCKING_ANGLE` = 0.43633232 (upper bound of the head pitch term) and `HORIZONTAL_SHIELD_MOVEMENT_LIMIT` = 0.5235988 (± bound of the head yaw term). `DUCK_WALK_ROTATION` = 0.005 has nothing to do with shields: `HumanoidModel.setupAnim` assigns it to the legs after the walk swing, right leg yRot = +0.005 and zRot = +0.005, left leg yRot = −0.005 and zRot = −0.005 (rad), every frame (the constant itself is inlined as a literal).

Worked third-person numbers (recomputed a second time by a point-wise method, which agrees with the matrix product to four decimals; adult wide arm, not slim; head angles 0 so the clamp terms are 0; walk term and idle bob omitted; model space in blocks = pixels / 16, y down, front = −z; conversion to the world for a body yaw of 0, i.e. facing south: offset from the feet = (0.9375 x, 0.9375 (1.501 − y), −0.9375 z), 7.3):

| Case | Plate centre, model space | Plate centre, offset from the feet | Direction of the plate's long axis (top of the plate) | Outward (decorated) normal, model space |
|---|---|---|---|---|
| Right arm, not blocking, ITEM pose (xRot −0.31416) | (−0.5938, 0.4816, −0.1159) | (−0.557, 0.956, +0.109) | along the arm's forward direction, the top edge forward and slightly up | (−1, 0, 0): away from the body |
| Right arm, blocking, xRot −0.9424779, yRot −0.5235988 | (−0.1264, 0.4930, −0.5740) | (−0.119, 0.945, +0.538) | nearly vertical: top edge at height 1.58, bottom edge at 0.31, i.e. an upright plate in front of the body | (0.0816, −0.1418, −0.9865): forwards |
| Left arm, blocking, xRot −0.9424779, yRot +0.5235988 | (0.1319, 0.4638, −0.6268) | (0.124, 0.972, +0.588) | the same, upright, top 1.61, bottom 0.34 | (−0.0816, −0.1418, −0.9865): forwards |

The blocking numbers describe a plate about 1.29 blocks tall standing in front of the chest and facing forwards, which is the expected look of a raised shield; the non-blocking case was computed from the same read constants and was not compared with a rendering (Open question 24). The plate is 12 pixels = 0.75 model block wide and 22 pixels = 1.375 model blocks tall, i.e. 0.703 by 1.289 blocks after the 0.9375 body scale.

### 6.13 Use-animation dispatch of the first-person renderer (`FirstPersonHandsAndItemsRenderer.submitArmWithItem`)

The item stack decides in this order (this resolves the mapping that Open question 6 left open for toot-horn, bundle and none):

1. empty stack: the arm model (6.5) for the main hand when the player is visible; nothing for the off hand;
2. a stack with the `map_id` component: the map renderers (not covered); 3. the crossbow item: the crossbow branches of 6.6;
4. otherwise, if the avatar is using an item (`isUsingItem`, `useItemRemainingTicks` > 0) in this hand: let u = the stack's use animation. `ItemUseAnimation.hasCustomArmTransform()` is true for `eat`, `drink` and `spear` only; for all others step 1 of 6.3 is applied **before** the switch. The switch then does: `none` nothing more; `eat` and `drink` the eat transform of 6.6 and then step 1; `block` the non-shield transform of 6.6 (nothing for `ShieldItem`); `bow` the bow pose of 6.6; `trident` the trident pose of 6.6; `brush` `applyBrushTransform`; `bundle` the swing of 6.3 step 2 with the hand's swing progress; `spear` translate(s × 0.56, −0.52, −0.72) then `SpearAnimations.firstPersonUse`; `spyglass`, `toot_horn` and `crossbow` (for a non-crossbow item) nothing more;
5. otherwise, if the player is in the auto-spin (riptide) state: step 1 and the translate/rotate of 6.6;
6. otherwise step 1, and the swing: if the avatar's current swing belongs to this hand: `none` type nothing, `whack` type the swing of 6.3 step 2, `stab` type `SpearAnimations.firstPersonAttack`.

Then the item is submitted with the transform of 6.7.2 (the render state of the hand's item: the `ItemStackRenderState` built for the context of 6.3 step 3) with the light coordinate of 6.10.

### 6.14 What makes a naive implementation of 6.1 to 6.6 look scrambled

Checklist, each row stating the rule of the artifact:

| Mistake | Rule |
|---|---|
| Drawing the item as one 16 × 16 quad, or as a stack of unrelated quads | The mesh is the 74-quad extrusion of 6.8 for the wooden pickaxe (2 + exposed edges); front at z = 8.5/16, back at z = 7.5/16, edge walls in between. |
| Wrong winding or inverted culling | Item pipelines cull back faces; counter-clockwise (y-up NDC) is the front. With culling inverted the client draws the back quad (the sprite left-right reversed, 6.8) and the far edge walls and discards the front: a mirrored, scrambled brown shape of the right colours. With culling off but a working depth test the nearer front quad hides the back quad (they are 0.0425 block apart), so that setting is harmless; with culling off and no depth test the reversed back quad overdraws the front. |
| Pixel units instead of blocks | Quad positions are divided by 16 (unit cube). The display translation is divided by 16 and the arm translation is in blocks. A client that feeds 0 … 16 positions into the 0.68 scale draws an 11-block plate. |
| Euler order | R = Rx · Ry · Rz (Z first); the display `rotation` (0, −90, 25) turns the sprite plane about the vertical axis by −90° and tilts it **within its own plane** by 25°. With Rz · Ry · Rx the 25° becomes a roll of the whole picture and the shape is at the wrong angle. |
| Translation order | The display translation is applied **after** rotation and scale (outermost), in the axes of the arm frame; the −½ recentring is innermost. The arm translation A is outside D. |
| UV orientation | v = 0 is the top of the sprite and grows downwards; the front quad's vertex 0 is the top-left corner with uv (0, 0). A bottom-up convention mirrors the picture vertically. |
| Using the world FOV or projection | The hand uses vertical fov 70° (death/fluid modifications only), near 0.05, aspect = window width / height and its own cleared depth range (6.9). With a different fov the plate, which spans view depth 0.2 … 1.1 blocks at x ≈ 0.6 to the right of the axis, changes its apparent shape strongly. With the world depth buffer the hand is partly hidden or clipped by world geometry. |
| Skipping the cleared depth, or the equal-depth rule | Clear depth before the hand; let equal depth pass (coplanar layers). |
| Normals in view space, flat lighting, or the GUI lights | Normals in world orientation, `LEVEL` lights, brightness 0.4 … 1.0 per face (6.10). Sprite colours are dark, so a held wooden tool is genuinely dark brown. |
| Wrong atlas | Items use the items atlas, block models the blocks atlas (6.8). |
| Expecting the tool to be face-on | The picture computed from the artifact's data (V21): the plate is seen obliquely (cosine to the line of sight about 0.65 at its centre) from its left side in the lower right of the window; about 60 % of the opaque texel centres (41 of 68) are on screen, the handle runs off the bottom edge and the head lies near and partly beyond the right edge in 16:9. Only mid-swing (p ≈ 0.5) is the plate nearly edge-on. |
| Missing equip or swing terms | At rest E = 0 and p = 0. The attack-strength drop (6.2) lowers the item while the cooldown recharges. |

---

## 7. Third-person camera (F5) and the player model

### 7.1 The three modes (`CameraType`)

`CameraType` values: `FIRST_PERSON` (ordinal 0), `THIRD_PERSON_BACK` (1), `THIRD_PERSON_FRONT` (2). The key `F5` (the "toggle perspective" key) cycles in order FIRST_PERSON → THIRD_PERSON_BACK → THIRD_PERSON_FRONT → FIRST_PERSON.
`isFirstPerson` is true for 0 only; `isMirrored` is true for FRONT only.
In the two third-person modes the camera is "detached": the local player model is drawn, the first-person hand is not, and the crosshair is not drawn.

### 7.2 Camera placement (`Camera.alignWithEntity`, `getMaxZoom`)

1. Start at the entity's eye position (interpolated position plus the interpolated eye height) with the entity's view yaw and pitch.
2. If mirrored (FRONT): yaw += 180° and pitch = −pitch (the camera looks back at the player).
3. Distance d = max(entityScale × cameraDistance, vehicleScale × vehicleCameraDistance), where `camera_distance` is the entity attribute `Attributes.CAMERA_DISTANCE`. The code starts from d = 4.0 for a non-living entity; for a living entity it is its scale times the attribute value. The attribute's default for a player was not read in this round (it is 4.0 for the vanilla player: inferred from the initial value); with scale 1, d = 4 blocks.
4. Collision pull-in (`getMaxZoom(d)`): let m = d. For each of the 8 corner offsets o = (ox, oy, oz) with each component either −0.1 or +0.1 (loop counter bit 0 gives x, bit 1 gives y, bit 2 gives z; bit set means +0.1, clear means −0.1; offsets are in world axes, not camera axes): start = eye + o; end = start + (−forward) × d, where forward is the camera's look direction. Cast a ray from start to end with the clip mode `VISUAL` for blocks (shapes that block vision) and no fluids. If the ray hits something, take the hit point's distance q to the **eye position** (not to start); if q² < m² then m = q. After all 8 rays the camera is moved backwards along its own forward axis by m.
   Thus the camera never goes through a vision-blocking block and keeps 0.1 block of clearance on each side. A hit never increases m.
5. The distance computation is the same for FRONT (mirrored) and BACK modes.
6. While sleeping the camera is placed at the bed with yaw = the bed direction's yaw − 180° and pitch 0, then moved 0.15 blocks.

The world camera's vertical field of view is the option `fov` (30–110, default 70) × the smoothed field-of-view modifier of the player (speed, drawn bow; `fovEffectScale` scales it; the modifier's own computation was not traced), then the death and fluid modification of 6.9. The near plane is 0.05 and the far plane is max(effective render distance × 64, cloud range × 16) blocks (6.9). **The first-person hand does not use this field of view**: it has its own fixed 70° (6.9). Open question 9 now only concerns the player's field-of-view modifier.

### 7.3 Where the player model is drawn (`LivingEntityRenderer`, `AvatarRenderer`)

For a player at entity position P with body yaw θ (degrees), the pose stack is built in this order (each step multiplies on the right, so the last listed acts first on model vertices):

1. translate to P (camera-relative);
2. rotate Y by 180° − θ (when not sleeping);
3. scale by (−1, −1, 1);
4. scale by 0.9375 in all axes (`AvatarRenderer`);
5. translate by (0, −1.501, 0).

Model vertices are in pixels, y pointing down; the part renderer multiplies them by 1/16. A vertex at model height y_m (pixels) lands at world height P.y + 0.9375 × (1.501 − y_m / 16) above the entity position, because of the two scales by −1 in y and by 0.9375 and the translate of 5, which is in the scaled space. The feet are at y_m = 24, giving P.y + 0.9375 × (1.501 − 1.5) = P.y + 0.0009375: the model's soles sit 0.001 × 0.9375 above the entity's feet (the 1.501 is the 24 / 16 = 1.5 of the model's foot line plus a 0.001 offset against depth fighting with the ground). The head top at y_m = −8 gives P.y + 0.9375 × 2.001 = P.y + 1.8759. So the drawn model, feet to head top, is 32 × 0.9375 / 16 = 1.875 blocks tall (the hat layer adds 0.5 pixel: 1.9 blocks at most), measured against the vanilla standing hitbox of 1.8 (vanilla value, not read in this round), so the head reaches 0.075 blocks above the hitbox top.

### 7.4 Humanoid model parts (`HumanoidModel.createMesh`, `PlayerModel.createMesh`)

Model space: x to the model's left (the player's right arm is at negative x), y down, z towards the front. All numbers in pixels (1/16 block). Cuboid = origin (ox, oy, oz) relative to the part pivot and size (w, h, d). `tex` = the texture offset (u, v) in the 64 × 64 skin. "Grow g" expands each side of the cuboid by g pixels.

| Part | Pivot (x, y, z) | Cuboid origin | Size (w, h, d) | tex (u, v) | grow |
|---|---|---|---|---|---|
| head | (0, 0, 0) | (−4, −8, −4) | (8, 8, 8) | (0, 0) | 0 |
| hat (overlay) | (0, 0, 0) (child of head) | (−4, −8, −4) | (8, 8, 8) | (32, 0) | 0.5 |
| body | (0, 0, 0) | (−4, 0, −2) | (8, 12, 4) | (16, 16) | 0 |
| jacket (overlay) | child of body | (−4, 0, −2) | (8, 12, 4) | (16, 32) | 0.25 |
| right arm, wide | (−5, 2, 0) | (−3, −2, −2) | (4, 12, 4) | (40, 16) | 0 |
| right arm, slim | (−5, 2, 0) | (−2, −2, −2) | (3, 12, 4) | (40, 16) | 0 |
| left arm, wide | (5, 2, 0) | (−1, −2, −2) | (4, 12, 4) | (32, 48) | 0 |
| left arm, slim | (5, 2, 0) | (−1, −2, −2) | (3, 12, 4) | (32, 48) | 0 |
| right sleeve (overlay) | child of right arm | as the arm | as the arm | (40, 32) | 0.25 |
| left sleeve (overlay) | child of left arm | as the arm | as the arm | (48, 48) | 0.25 |
| right leg | (−1.9, 12, 0) | (−2, 0, −2) | (4, 12, 4) | (0, 16) | 0 |
| left leg | (1.9, 12, 0) | (−2, 0, −2) | (4, 12, 4) | (16, 48) | 0 |
| right pants (overlay) | child of right leg | (−2, 0, −2) | (4, 12, 4) | (0, 32) | 0.25 |
| left pants (overlay) | child of left leg | (−2, 0, −2) | (4, 12, 4) | (0, 48) | 0.25 |

The 64 × 64 skin format has separate left arm and left leg regions at (32, 48) and (16, 48), as listed. The pivot y offsets are the base humanoid values plus `yOffset` (0 for the player).
Idle pivots: head, body at y = 0; so the shoulders are at y = 2 (arms) and hips at y = 12 (legs). Body bottom y = 12 equals the hip pivot, the feet at y = 24.

**Skin texture layout** (the cuboid with texture offset (u, v) and size (w, h, d) occupies 2d + 2w pixels in x and d + h in y; the faces, in the model's own labels): the area from the cuboid's tex offset is divided as follows (`ModelPart$Cube`):

| Face | x range | y range |
|---|---|---|
| top of the head/body (visible above the part) | u + d .. u + d + w | v .. v + d |
| bottom | u + d + w .. u + d + 2w | v .. v + d (v flipped) |
| right side (the part's −x side) | u .. u + d | v + d .. v + d + h |
| front | u + d .. u + d + w | v + d .. v + d + h |
| left side (the part's +x side) | u + d + w .. u + 2d + w | v + d .. v + d + h |
| back | u + 2d + w .. u + 2d + 2w | v + d .. v + d + h |

Worked: the head (u, v) = (0, 0), (8, 8, 8): top (8..16, 0..8), bottom (16..24, 0..8), right (0..8, 8..16), front (8..16, 8..16), left (16..24, 8..16), back (24..32, 8..16). The hat overlay: the same at (32, 0): front (40..48, 8..16).
Texture UVs are divided by 64 (the model's texture size); the skin texture is 64 × 64, with legacy 64 × 32 skins converted by copying the right arm and leg regions to the left (conversion not traced). The skin texture is looked up from the player's profile `textures` property (02), else the default skin (`textures/entity/player/wide/steve.png`, `slim/alex.png` and others).
Overlay layers are drawn only when the corresponding "skin parts" bit (cape, jacket, left sleeve, right sleeve, left pants, right pants, hat) is on (the client option, also sent to the server in Client Information, 03).

### 7.5 Pose animation (`HumanoidModel.setupAnim`, `AnimationUtils`)

All angles in radians; walkPos = the walk animation position, walkSpeed = the walk animation speed (0..1); speedValue is 1 for normal walking.

- Head: xRot = pitch × π/180, yRot = headYaw × π/180 (relative to the body).
- Right arm xRot = cos(walkPos × 0.6662 + π) × 2.0 × walkSpeed × 0.5 / speedValue; left arm xRot = cos(walkPos × 0.6662) × 2.0 × walkSpeed × 0.5 / speedValue.
- Right leg xRot = cos(walkPos × 0.6662) × 1.4 × walkSpeed / speedValue; left leg xRot = cos(walkPos × 0.6662 + π) × 1.4 × walkSpeed / speedValue. Legs also get yRot ±0.005 and zRot ±0.005 (right +, left −).
- Crouching: body xRot 0.5; arms xRot += 0.4; legs z += 4; head y += 4.2; body and arms y += 3.2.
- Riding: arms xRot += −0.62831855 (−π/5); legs xRot −1.4137167, yRot ±0.31415927, zRot ±0.07853982 (right +, left −).
- **Idle arm bob** (`AnimationUtils.bobModelPart(part, ageInTicks, sign)`), applied after the poses to both arms (right sign +1, left sign −1) unless that arm holds a spyglass: part.zRot += sign × (cos(age × 0.09) × 0.05 + 0.05); part.xRot += sign × sin(age × 0.067) × 0.05.
- **Arm poses by held-item state** (`poseRightArm` / `poseLeftArm`, chosen from the arm's `ArmPose`; head is the head part's current rotation; the left arm mirrors the sign of yRot terms):

| ArmPose | Effect on the posed arm |
|---|---|
| EMPTY | yRot = 0 |
| ITEM | xRot = xRot × 0.5 − 0.31415927 (π/10); yRot = 0 |
| BLOCK (`poseBlockingArm`) | xRot = xRot × 0.5 − 0.9424779 + clamp(head.xRot, −1.3962634, 0.43633232); yRot = (−30° for the right arm, +30° for the left, in radians) + clamp(head.yRot, −0.5235988, 0.5235988) (the named constants and the shield placement: 6.12) |
| BOW_AND_ARROW | right arm: yRot = −0.1 + head.yRot; left arm: yRot = 0.1 + head.yRot + 0.4; both arms xRot = −π/2 + head.xRot |
| THROW_TRIDENT | xRot = xRot × 0.5 − π; yRot = 0 |
| CROSSBOW_CHARGE (`animateCrossbowCharge`, with right = the holding arm) | holding arm: yRot = −0.8 (right) or +0.8 (left), xRot = −0.97079635; other arm: xRot = the holding arm's xRot, then with d = clamp(ticksUsing, 0, maxCharge) / maxCharge: other.yRot = lerp(d, 0.4, 0.85) × (+1 for right, −1 for left) and other.xRot = lerp(d, other.xRot, −π/2) |
| CROSSBOW_HOLD (`animateCrossbowHold`) | holding arm: yRot += head.yRot + (−0.3 right, +0.3 left); other arm: yRot += head.yRot + (0.6 right-holding, −0.6 left-holding); holding arm xRot = −π/2 + head.xRot + 0.1; other arm xRot = −1.5 + head.xRot |
| SPYGLASS | xRot = clamp(head.xRot − 1.9198622 − (0.2617994 when crouching, else 0), −2.4, 3.3); yRot = head.yRot − 0.2617994 |
| TOOT_HORN | xRot = clamp(head.xRot, −1.2, 1.2) − 1.4835298; yRot = head.yRot − 0.5235988 |
| BRUSH | xRot = xRot × 0.5 − 0.62831855 (π/5); yRot = 0 |
| SPEAR | `SpearAnimations.thirdPersonHandUse` (not reproduced; Open question 6) |

  In `CROSSBOW_HOLD` the first branch of the bytecode uses the arm named "holding"; the rows above state the effect for a right-hand hold and mirror it for a left-hand hold.
- Attack swing in third person (`setupAttackAnimation`), progress p, swing arm = the arm of the swinging hand: body yRot = sin(√p × 2π) × 0.2 (negated when the swinging arm is the left). The arms' pivots then follow the body turn with radius 5 × ageScale: right arm z = sin(bodyYRot) × 5 × ageScale, x = −cos(bodyYRot) × 5 × ageScale; left arm z = −sin(bodyYRot) × 5 × ageScale, x = cos(bodyYRot) × 5 × ageScale. Both arms yRot += bodyYRot and the left arm xRot += bodyYRot. For the `whack` swing type the swinging arm then has: xRot −= sin(easeOutQuart(p) × π) × 1.2 + sin(p × π) × (−(head.xRot − 0.7)) × 0.75, yRot += bodyYRot × 2, zRot += sin(p × π) × (−0.4). The remaining steps of this function (the `stab` swing and the last lines of `whack`) were not traced: Open question 7.

### 7.6 Cape, ears and other layers

Not covered (capes, elytra, armour layers, held-item layer in third person). Third-person held items use the item's `thirdperson_righthand`/`lefthand` display transform (8.2) attached to the arm pivot; the exact chain from the arm part to the item model (`ItemInHandLayer`: arm part, Rx(−90°), Ry(180°), translate (±1, 2, −10)/16, display transform, item transformation) is in 6.12.

---

## 8. Items and blocks as items

### 8.1 Item in a GUI slot (`GuiGraphicsExtractor.item`)

A GUI item is rendered with the display context `GUI` into an off-screen item atlas cell of 16 × guiScale pixels square and then blitted to the 16 × 16 GUI-pixel cell at (x, y) with nearest filtering and premultiplied alpha (`GUI_TEXTURED_PREMULTIPLIED_ALPHA`). The view is orthographic: the model's unit cube space [0, 1]³ (before the display transform, centre (0.5, 0.5, 0.5)) maps onto the 16 × 16 cell (1 block = 16 GUI pixels), y up, with the display transform applied. Items whose model extends beyond the cell are drawn larger ("oversized") without clipping to the cell.

**Flat items** (models derived from `builtin/generated`, 08 §5.7; most tools, foods, materials): the generated model's `gui_light` is `front`, the transform for `gui` is identity (the default `item/generated` has no `gui` entry), and the lighting setup is `ITEMS_FLAT`, so the front face is shaded as an unrotated sprite (effectively full brightness with the formula of 1.9 for a normal facing the camera). The 16 × 16 texture fills the cell exactly. The geometry is the extruded sprite of 6.8 (front and back quad and edge walls, 1 pixel thick), not a single quad; seen straight from the front only the front quad is visible, which is why the GUI icon looks flat.
**Block items** (models derived from `block/block` with `gui_light: side`): the `gui` transform is rotation (30, 225, 0), translation (0, 0, 0), scale (0.625, 0.625, 0.625), lighting `ITEMS_3D`. The cube is seen from above-left: the visible faces are UP (brightest), the face towards the viewer on the left (NORTH or WEST depending on the 225° yaw) and on the right.
The shading of those three faces comes from the `ITEMS_3D` light directions of 1.9 using the formula `min(1, (max(0, n·L0) + max(0, n·L1)) × 0.6 + 0.4)`.

### 8.2 Display transforms (`ItemTransform.apply`)

For a context the model's `display` entry (08 §5.6) gives rotation (degrees, X, Y, Z), translation (sixteenths of a block) and scale. At load (`ItemTransform$Deserializer`) the translation is multiplied by 1/16 and each component is clamped to ±5 blocks (= ±80 sixteenths), and each scale component is clamped to ±4; absent fields default to rotation 0, translation 0, scale 1. The pose M is modified by four right multiplications, in this order (6.7.1; the first one is the outermost, so on a vertex the last acts first):

M ← M · T(tx, ty, tz) · R · S(sx, sy, sz) · T(−0.5, −0.5, −0.5)

1. translate by (tx, ty, tz) (already in blocks; for left-hand contexts tx is negated);
2. rotate by R = `rotationXYZ(rx, ry, rz)` with the angles in radians (degrees × 0.017453292); (recalled, not verified) R = Rx(rx) · Ry(ry) · Rz(rz), that is, on a vertex first about z, then y, then x, all about the fixed axes of the current frame (6.7.1); for left-hand contexts ry and rz are negated before the call;
3. scale by (sx, sy, sz) (the normal matrix of the pose is unchanged for a uniform positive scale, multiplied by the signs for a uniform scale with negative components, and divided by the scale and renormalised for a non-uniform scale: `PoseStack$Pose.scale`);
4. translate by (−0.5, −0.5, −0.5), moving the model's centre (0.5, 0.5, 0.5) to the origin.

So the model's centre is scaled and rotated about itself and then moved by the display translation; the translation is **not** rotated by R and **not** scaled by S. "Left-hand context" means `THIRD_PERSON_LEFT_HAND` or `FIRST_PERSON_LEFT_HAND` (`ItemDisplayContext.leftHand()`).

**Which entry is used** (`ItemTransforms`, `ResolvedModel.findTopTransform`):

- Each model file's `display` is read into nine entries. An entry that is absent is the shared "no transform" sentinel; an entry that is present counts as defined even if all its values are the defaults. If a model's own `thirdperson_lefthand` (or `firstperson_lefthand`) is the sentinel, the model's own right-hand entry is used in its place (per file, at load).
- For a context the client takes, **independently for each context**, the first model along the chain model → parent → grandparent … whose entry for that context is not the sentinel. Nothing found: no transform, only step 4 above (the −0.5 translate): the model is just centred on the origin, unscaled, at the hand frame's origin.
- The chosen entry is applied with the leftHand flag of the **context**: so an **explicit** left-hand entry in a file is mirrored again (translation x negated, rotation y and z negated), and a left entry that was filled in from the right entry is mirrored once. For `item/handheld` (its own firstperson_lefthand (0, 90, −25) with translation x +1.13) the entry is therefore used as rotation (0, −90, 25) and translation x −1.13, the same rotation as the right hand; for those tools that is the exact mirror image (the back quad is seen, 6.7.3). `item/generated` has no left entry of its own, so its left hand is the right entry mirrored once: rotation (0, 90, −25), translation x −1.13, front quad visible, not an exact mirror (6.7.3). The entries of other models, for example the shield's, are written to be applied with the double mirror (6.12).

Vanilla defaults (`models/item/generated.json`, `handheld.json`, `block/block.json`) for reference: `item/generated` thirdperson_righthand rot (0,0,0) tr (0,3,1) sc 0.55; firstperson_righthand rot (0,−90,25) tr (1.13,3.2,1.13) sc 0.68; ground tr (0,2,0) sc 0.5; head rot (0,180,0) tr (0,13,7); fixed rot (0,180,0).
`item/handheld` thirdperson_righthand rot (0,−90,55) tr (0,4,0.5) sc 0.85 (lefthand rot (0,90,−55)); firstperson_righthand rot (0,−90,25) tr (1.13,3.2,1.13) sc 0.68 (lefthand rot (0,90,−25)).
`block/block`: gui rot (30,225,0) sc 0.625; ground tr (0,3,0) sc 0.25; fixed sc 0.5; on_shelf rot (0,180,0); thirdperson_righthand rot (75,45,0) tr (0,2.5,0) sc 0.375; firstperson_righthand rot (0,45,0) sc 0.4; firstperson_lefthand rot (0,225,0) sc 0.4.

### 8.3 Enchantment glint

Items with the glint flag are drawn a second time with the `GLINT` blend (source colour factor SRC_COLOR, destination factor ONE: additive, alpha factors ZERO and ONE) using `textures/misc/enchanted_glint_item.png` (128 × 128; armour uses `enchanted_glint_armor.png`).
The texture coordinates are transformed (`TextureTransform.setupGlintTexturing(scale)`): t = (milliseconds × glintSpeed option × 8); translate (−(t mod 110000) / 110000, (t mod 30000) / 30000, 0), rotate Z by 0.17453292 rad (10°), scale by `scale` (8 for items; 0.16 for entity glint and 0.5 for armour entity glint per the lambdas). The fragment shader (`glint.fsh`) outputs texture × colour modulator × fade, with fade = (1 − fog) × `GlintAlpha` (the option glint strength), discarding alpha < 0.1.

### 8.4 Items in the world (summary)

Dropped items and items in item frames use the `ground` and `fixed` display transforms. Their lifetime, pickup delay and merge rules are in 18 §6.11; their motion and pickup box are in 41-item-entity-physics.md.

### 8.5 From item definition to the render state (`ItemModelResolver`, `ItemStackRenderState`)

Source and method as in the provenance note of 6.7.

1. **Definition tree.** The item definition (08 §6) is baked into an `ItemModel` tree. Each branching node (`condition`, `select`, `range_dispatch`, `composite`) and each leaf has an optional `transformation`; a node composes it with the matrix it received from its parent and hands the product to its children (`Transformation.compose(parentMatrix, optional own)`; the product is parent × own, inferred). The matrix that reaches a leaf is that leaf's **local transform L** (6.7.2 factor 8). A `minecraft:model` leaf becomes a `CuboidItemModelWrapper` (the quads of the model, baked once); a `minecraft:special` leaf becomes a `SpecialModelWrapper` (a code-drawn renderer, such as the shield's) whose `base` model supplies the display data, the gui-light setting and the particle sprite.
2. **Update.** For one stack and one `ItemDisplayContext` the resolver fills an `ItemStackRenderState` with one layer per leaf. A layer holds: the quads split into solid and translucent lists (6.9), the tint colours (one per entry of the leaf's `tints`), the foil type (none, standard, or the special foil of a special renderer), L, the **item transform** (the display entry chosen for the context, 8.2) and the `usesBlockLight` flag (the model's `gui_light` is `side`: used by the GUI only).
3. **Submit.** Each layer is placed with the item transform for the context (8.2), then its local transform L; a special renderer draws it directly, otherwise the quads go to the submit-node collector with a copy of the pose, the light coordinate, the overlay (`NO_OVERLAY` for held items), the tints and the foil type.
4. **Render.** `ItemFeatureRenderer` writes each quad through its own render type (the quad's material info chooses `itemCutout`, `itemTranslucent` or their glint variants for the sprite's atlas, 6.8 and 6.9), with the tint colour of the quad's tint index (white when it has none) and the pose's normal matrix (6.10). With the glint type the item is drawn a second time as in 8.3; for a special foil the decal pose is the item pose with every matrix entry multiplied by 0.5 in the GUI and by 0.75 in first-person contexts (`computeFoilDecalPose`).

### 8.6 Light, normal space and depth by display context

| Context | Lighting entry | Normal space | Light map | Projection and depth |
|---|---|---|---|---|
| GUI (the item atlas cell, 8.1) | `ITEMS_FLAT` for `gui_light` front, `ITEMS_3D` for side | GUI space | `UiLightmap` (full bright) | orthographic cell, own depth |
| First-person hand (6.9, 6.10) | `LEVEL` | world orientation (the camera rotation is removed by the pose stack, 6.7.2) | level light map at the player's light coordinate | `hudFov` 70°, near 0.05, its own cleared depth |
| Third-person hand, ground, fixed, head, shelf | not read item by item; the level pass keeps `LEVEL` active (inferred) | world orientation (inferred, as for entities, 1.9) | level light map at the carrier's light coordinate | the world projection and depth |

---

## 9. Validation (checkable facts and worked examples)

Each item can be checked by a test that needs no jar.

**V1 Directional table.** `default`: DOWN 0.5, UP 1.0, N/S 0.8, W/E 0.6; `nether`: DOWN/UP 0.9, N/S 0.8, W/E 0.6.

**V2 AO, open flat ground (UP face).** Block P at (0,0,0) is full stone; the layer y = 1 is all air with sky light 15, block light 0 everywhere. Then all samples have shade 1.0 and light (block 0, sky 15). Every vertex shade = (1+1+1+1)/4 = 1.0, every vertex light is smooth sky 240, block 0. Colour factor = 1.0 × 1.0 = 1.0.

**V3 AO, wall beside ground.** As V2 but the cell (1, 1, 0) (EAST of the sampling cell) is solid stone (shade 0.2, light 0). UP face: corner order c0..c3 = EAST, WEST, NORTH, SOUTH.
- T0 = light-permeable of (1, 2, 0) = air → true; T1..T3 true. So all diagonals are sampled.
- Group g0 = (S3 south, S0 east, D03 = cell (1,1,1), centre): shades (1.0, 0.2, 1.0, 1.0) → 0.8. g1 = (north 1.0, east 0.2, D02 = cell (1,1,−1) 1.0, centre 1.0) → 0.8. g2 = (north, west, D12, centre) = 1.0. g3 = 1.0.
- The UP remap (g0→2, g1→3, g2→0, g3→1) gives vertex shades: vertex 0 = 1.0, 1 = 1.0, 2 = 0.8, 3 = 0.8. By 1.3c, vertices 2 and 3 are the +x (east) corners: vertex 2 = (max x, max y, max z), vertex 3 = (max x, max y, min z). The two east corners are darkened, as expected beside a wall.
- Lights: for g0 the blend inputs are L3 = sky 15 block 0, L0 = 0 (inside stone), LD03 = sky 15, centre = sky 15. Centre sky > 2, so the repair replaces L0's 0 by the centre light: all four equal, and the blended light stays (block 0, sky 15 → smooth sky 240). Final colour of vertex 2 = 0.8 × 1.0 (UP) × lightmap(0, 240) .

**V4 AO, inner corner.** A cell where both the cell beyond-edge cells are opaque: if T2 = false and T0 = false for diagonal D02 (both edge cells have an opaque block behind them), D02's shade and light are replaced by S0 and L0 (the edge cell's), not sampled.

**V5 `smoothBlend`.** a = pack(block 0, sky 15), b = 0, c = a, d = a: sky(d) = 15 > 2 so repair: b := d. Sum = 4 × pack(0, 15) = 4 × 15728640 = 62914560; >> 2 = 15728640; & 0x00FF00FF = 15728640 & 16711935 = 15728640 (sky field bits 16–23 = 0xF0 = 240). So the result is smooth sky 240, block 0.
Without repair it would be (3 × 15728640) >> 2 = 11796480 → sky field 0xB4 = 180 (a visibly darker corner).

**V6 Light map values** (overworld day, SkyFactor 1, BlockFactor 1.4 (flicker 0), ambient `#0a0a0a`, sky light white, block tint `#ffd88c`, night vision 0, darkness 0, boss 0):

| (block, sky) | gamma 0 | gamma 0.5 | gamma 1 |
|---|---|---|---|
| (0, 0) | 0.0392 each | 0.0935 each | 0.1479 each |
| (0, 7) | 0.2187 each | 0.4230 each | 0.6274 each |
| (0, 15) | 1, 1, 1 | 1, 1, 1 | 1, 1, 1 |
| (8, 0) | 0.3503, 0.3029, 0.2106 | 0.5861, 0.5068, 0.3523 | 0.8219, 0.7107, 0.4940 |
| (15, 0) | 1, 1, 1 | 1, 1, 1 | 1, 1, 1 |
Night (sky 15, block 0): SkyFactor 0.24, sky light colour `#7a7aff`, gamma 0.5: (0.2784, 0.2784, 0.5047).
Nether darkest cell (ambient `#302821`, SkyFactor 0, gamma 0.5): (0.3770, 0.3142, 0.2592).
Check of one value: (0, 0), gamma 0: colour = ambient = 10/255 = 0.0392. notGamma: m = 0.0392, (1 − m)⁴ = 0.8522, s = 0.1478, ng = 0.1478; gamma 0.5 → 0.0392 + 0.5 × (0.1478 − 0.0392) = 0.0935.

**V7 Atlas padding.** Default options (mip 4, bilinear no anisotropy): padding = 1 << 4 = 16. A 16 × 16 sprite occupies 48 × 48 (16 + 2 × 16), already a multiple of 16. With ANISOTROPIC and `maxAnisotropyBit` 2: padding = 16 << 1 = 32, slot 80 × 80. For a 16 × 16 sprite at slot (x, y) the UV rectangle is ((x + p) / W, (y + p) / H) to ((x + p + 16) / W, (y + p + 16) / H).

**V8 Mip means.** Four texels with sRGB red 255, 255, 0, 0: the linear red mean = 0.5 in linear light → sRGB 188 (0.5^(1/2.2) ≈ 0.73 → 188), not 128. Alpha is the integer mean of the four alphas.

**V9 Fog.** Render distance 12: rdEnd = 192, rdStart = 192 − clamp(19.2, 4, 64) = 172.8. A fragment at cylindrical distance 182.4 gets value (182.4 − 172.8) / 19.2 = 0.5, i.e. half fog colour (assuming the environmental fog is further). Underwater (water fog default): start −8, end 96 (× max(0.25, waterVision)): a fragment 44 blocks away: (44 + 8) / 104 = 0.5 (for water vision 1).
Atmospheric rain: rainMul 1 gives start 0 − 160 = −160 and end max(min(96, E), E − 256 × 1) with E = 1024, which is max(96, 768) = 768.

**V10 Sky angle.** At clock tick 6000 the sun angle is 0° (sun at zenith); at tick 18000 (midnight, the sun below) the sun angle is about 180°; with the ease the exact values at 12000 and 0 differ slightly from 90° and 270°.
Sky colour at tick 6000: base `#78a7ff` × track `#ffffff` = `#78a7ff` = (0.4706, 0.6549, 1.0). At tick 18000: × `#000000` = black. At tick 12768 (halfway 11867 → 13670 is 12768.5): track = lerp(0.5) of white and black = (0.5, 0.5, 0.5) → sky (0.2353, 0.3275, 0.5).

**V11 Day timeline sky light.** At tick 13140 sky_light_factor 0.24 and sky_light_color `#7a7aff` (a step down within 730 → 13140 for the factor, 11270 → 13140 for the colour).

**V12 Clouds.** The cloud texture 256 × 256 with a cell size of 12 blocks: the pattern period is 3072 blocks. Drift 0.03 blocks per tick = 0.6 blocks per second; one cell in 400 ticks. Layer bottom 192.33, top 196.33 (overworld).

**V13 Crack stages.** A progress packet with stage 0..9 shows `destroy_stage_<stage>`; stage 10 or 255 removes it. A local progress of 0.55 shows stage 5 (`(int)(5.5)`); 0.99 shows stage 9; 1.0 breaks the block.

**V14 GUI scale.** Each step from s to s + 1 is taken while floor(fbW / (s + 1)) ≥ 320 and floor(fbH / (s + 1)) ≥ 240.
- 854 × 480: s = 1 → 2 (854/2 = 427, 480/2 = 240 both pass); at s = 2: 854/3 = 284 < 320 stops. s = 2, guiW = ceil(854/2) = 427, guiH = 240.
- 1280 × 720: s = 1 → 2 (640, 360); s = 2 → 3 (1280/3 = 426 ≥ 320, 720/3 = 240 ≥ 240); at s = 3: 1280/4 = 320 passes but 720/4 = 180 < 240 stops. s = 3, guiW = ceil(1280/3) = 427, guiH = ceil(720/3) = 240.
- 1920 × 1080: s = 1 → 2 → 3 → 4 (1920/4 = 480, 1080/4 = 270 pass); at s = 4: 1080/5 = 216 < 240 stops. s = 4, guiW = 480, guiH = 270 (as in 5.1).

**V15 Hotbar at 427 × 240.** Hotbar x = 427 / 2 − 91 = 213 − 91 = 122 (integer division), y = 218; slot 0 item at (124, 221); selection frame slot 4 at x = 122 − 1 + 80 = 201, y = 217. Crosshair at ((427 − 15) / 2, (240 − 15) / 2) = (206, 112).

**V16 Heart rows.** Health 20, max 20, no absorption: 10 hearts, R = 1; the heart at slot k is at x = left + 8 × (k mod 10), y = H − 39. With 20 hearts of health plus absorption (R = 2) rowHeight = max(10 − (2 − 2), 3) = 10 and the second row is at y = H − 49; with R = 3, rowHeight 9. Armour N = 20 is 10 full icons at x = left + 8i, y = H − 39 − (R − 1) × rowHeight − 10. Food 20 is 10 full icons, the first at x = right − 9, each next 8 pixels to the left, y = H − 39.

**V17 Item bar.** Damage 25 of 100: width = round(13 − 25 × 13 / 100) = round(9.75) = 10; hue = 0.75 / 3 = 0.25 → a yellow-green. Damage 0: no bar. Damage 100 (max): width 0, hue 0 (red).

**V18 Swing.** Right hand (s = +1), p = 0.5, E = 0, q = √p = 0.7071, sin(q × π) = 0.7955: the arm transform gives (0.56, −0.52, −0.72). The swing translate is (−0.4 × 0.7955, 0.2 × sin(q × 2π), −0.2 × sin(0.5π)) = (−0.3183, −0.1928, −0.2), so the item origin is at (0.2417, −0.7128, −0.92) in the hand frame. Then rotate Y by 45 + sin(0.25π) × (−20) = 30.86°; Z by 0.7955 × (−20) = −15.91°; X by −80 × 0.7955 = −63.64° (−63.66° with unrounded values); Y by −45°.

**V19 Camera distance.** Camera looking along +z (south), a flat vertical wall 2.5 blocks behind the eye at z = eye.z − 2.5, nothing else in range. Each of the 8 rays starts at eye + (±0.1, ±0.1, ±0.1) and runs 4 blocks in −z, so every ray hits the wall at z = eye.z − 2.5; the hit point is at (eye.x ± 0.1, eye.y ± 0.1, eye.z − 2.5), whose distance to the eye is √(0.1² + 0.1² + 2.5²) = √6.27 = 2.50400. That is less than 4, so m = 2.50400 and the camera is moved back 2.504 blocks, which is 0.004 behind the wall plane (which the near plane would hide (inferred; the near plane was not traced, Open question 9)). Open air: m stays 4.0.

**V20 Player model.** The right-arm pivot is (−5, 2, 0) (2 pixels below the neck line, y down). The head's front face is skin texels (8..16, 8..16). The model spans y_m = −8 (head top) to y_m = 24 (soles) = 32 pixels. World height of a vertex above the entity position: 0.9375 × (1.501 − y_m / 16). Soles: 0.9375 × (1.501 − 1.5) = 0.0009375. Head top: 0.9375 × (1.501 + 0.5) = 1.8759. Height from soles to head top = 0.9375 × 32 / 16 = 1.875 blocks. Against a standing hitbox of 1.8 (vanilla value, not read in this round) the head top is 0.075 above the hitbox top. The 1.501 is the 24 / 16 = 1.5 foot line plus 0.001.

**V21 The wooden pickaxe at rest (right hand), 16:9.** Inputs: window 1920 × 1080 (any 16:9 size gives the same fractions), `fov` option irrelevant (hand fov 70°), camera at rest (no bobbing, hurt or sway), swing p = 0, equip E = 0, main arm right. The sprite is `textures/item/wooden_pickaxe.png` (16 × 16). Chain: M = A · D (6.7.3) with the 3 × 3 block and constant given there: view = M · (x/16, y/16, z/16) for a model-pixel point (x, y, z); that is

view x = −0.68 · z/16 + 0.970625; view y = 0.28738 · x/16 + 0.61629 · y/16 − 0.771835; view z = 0.61629 · x/16 − 0.28738 · y/16 − 0.813830.

Projection: f = 1.428148, f / aspect = 0.803333, near 0.05, far F = 768 for the depth column below (with F = 2048, 6.9, the depth values change by less than 4 × 10⁻⁵; x, y, ndc and fractions do not depend on F). ndc_x = 0.803333 · view x / (−view z), ndc_y = 1.428148 · view y / (−view z). Quick check of the projection: the view point (1, 0, −1) gives ndc (0.8033, 0) and depth 0.04994 (n (F − 1) / (F − n) = 0.05 × 767 / 767.95).

Front quad (model z = 8.5; vertex order 6.8: v0 = top-left, v1 = bottom-left, v2 = bottom-right, v3 = top-right of the sprite):

| Corner (x, y px) | view (x, y, z) | −z (= clip w) | ndc | window fraction (fx, fy from the top) | pixel at 1920 × 1080 | depth (F = 768) |
|---|---|---|---|---|---|---|
| v0 top-left (0, 16) | (0.60938, −0.15555, −1.10121) | 1.10121 | (0.44454, −0.20173) | (0.7223, 0.6009) | (1386.8, 648.9) | 0.045342 |
| v1 bottom-left (0, 0) | (0.60938, −0.77183, −0.81383) | 0.81383 | (0.60152, −1.35445) | (0.8008, 1.1772) | (1537.5, 1271.4) | 0.061377 |
| v2 bottom-right (16, 0) | (0.60938, −0.48445, −0.19754) | 0.19754 | (2.47814, −3.50244) | (1.7391, 2.2512) | (3339.0, 2431.3) | 0.253064 |
| v3 top-right (16, 16) | (0.60938, 0.13183, −0.48492) | 0.48492 | (1.00951, 0.38827) | (1.0048, 0.3059) | (1929.1, 330.3) | 0.103051 |

Back quad (model z = 7.5; 0.0425 block further along view +x; listed in the same corner order, its own vertex order is v0 = (16, 16), v1 = (16, 0), v2 = (0, 0), v3 = (0, 16)):

| Corner | view (x, y, z) | ndc | window fraction | pixel | depth |
|---|---|---|---|---|---|
| top-left (0, 16) | (0.65187, −0.15555, −1.10121) | (0.47554, −0.20173) | (0.7378, 0.6009) | (1416.5, 648.9) | 0.045342 |
| bottom-left (0, 0) | (0.65187, −0.77183, −0.81383) | (0.64347, −1.35445) | (0.8217, 1.1772) | (1577.7, 1271.4) | 0.061377 |
| bottom-right (16, 0) | (0.65188, −0.48445, −0.19754) | (2.65097, −3.50244) | (1.8255, 2.2512) | (3504.9, 2431.3) | 0.253064 |
| top-right (16, 16) | (0.65188, 0.13183, −0.48492) | (1.07991, 0.38827) | (1.0400, 0.3059) | (1996.7, 330.3) | 0.103051 |

Which quads are drawn: with counter-clockwise front faces the front quad has a positive signed ndc area (+2.445) and is drawn; the back quad has −2.616 and is culled. Of the 72 edge walls 30 face the camera and are drawn: 18 EAST (the right-hand edges of the opaque texels), 6 UP and 6 DOWN; no WEST wall. (1 + 30 = 31 quads are rasterised.)

Where the opaque texels land (front plane, texel centres, same corner convention; the sprite row counts from the top):

| Texel (column, row) | Opaque | ndc | window fraction |
|---|---|---|---|
| (2, 14) handle end | yes | (0.6576, −1.2837) | (0.8288, 1.1418) off the bottom edge |
| (5, 11) | yes | (0.7169, −1.0452) | (0.8585, 1.0226) just below the bottom edge |
| (8, 8) | yes | (0.7881, −0.7594) | (0.8941, 0.8797) |
| (11, 5) | yes | (0.8750, −0.4106) | (0.9375, 0.7053) |
| (6, 2) head, left tip | yes | (0.6074, −0.2394) | (0.8037, 0.6197) |
| (10, 3) head, top | yes | (0.7722, −0.2293) | (0.8861, 0.6146) |
| (13, 8) head, right | yes | (1.1423, −0.8014) | (1.0712, 0.9007) off the right edge |
| (13, 10) | yes | (1.2468, −1.1549) | (1.1234, 1.0775) off both edges |

The bounding box of all opaque texels of the front quad is fx 0.7864 … 1.2511, fy 0.5276 … 1.2551 of the window. The on-screen part is therefore the **right 21.4 % of the width and the lower 47.2 % of the height**: the handle runs off the bottom edge, the head lies near and partly beyond the right edge, and the whole picture is a foreshortened plate seen obliquely from its left side. 41 of the 68 opaque texel centres (about 60 %) are inside the window. The sprite's transparent bottom-right corner (16, 0) is the point nearest to the camera (view depth 0.1975, ndc (2.48, −3.50)): it is never visible because that texel is transparent, but any code that clips or sorts by it must not fail on a vertex that far outside the screen (near plane 0.05 is not crossed).

Changing a term: with equip offset E the whole picture moves down by 0.6 E blocks in view y (E = 0.5: ndc_y of v3 becomes −0.49527, fy 0.7476). With the **wrong** Euler order R = Rz · Ry · Rx the front quad's corners become (0, 16) → ndc (0.37973, −0.03008), (0, 0) → (0.61308, −0.91968), (16, 0) → (1.96060, −2.94112), (16, 16) → (1.21438, −0.09618): a different picture.

**V22 The pickaxe in mid-swing.** Right hand, E = 0, swing progress p = 0.5 (6.3 step 2; q = √p = 0.70711, sin(q π) = 0.79547, sin(q 2π) = −0.96400). The swing frame origin (A · swing translate): (0.24172, −0.71278, −0.92000), the value of V18. The rotations then are Ry(30.86°), Rz(−15.91°), Rx(−63.64°), Ry(−45°) (V18), followed by D of 6.7.3. Front quad of the pickaxe, same corner convention, 16:9:

| Corner | view (x, y, z) | ndc | window fraction |
|---|---|---|---|
| v0 top-left (0, 16) | (0.26072, −0.84294, −1.43311) | (0.14615, −0.84002) | (0.5731, 0.9200) |
| v1 bottom-left (0, 0) | (0.40098, −0.87511, −0.76851) | (0.41915, −1.62624) | (0.7096, 1.3131) |
| v2 bottom-right (16, 0) | (0.13026, −0.25742, −0.68148) | (0.15355, −0.53947) | (0.5768, 0.7697) |
| v3 top-right (16, 16) | (−0.01000, −0.22526, −1.34608) | (−0.00597, −0.23899) | (0.4970, 0.6195) |

The front quad's signed area is positive at p = 0, 0.25, 0.5, 0.75 and 1 (2.445, 0.234, 0.069, 0.050, 2.445): the front face stays the visible one through the swing and is nearly edge-on at p = 0.5. The opaque texels at p = 0.5 cover fx 0.516 … 0.680, fy 0.679 … 1.211 of the window.

**V23 A held cube: the crafting table (`block/crafting_table`, parent `block/cube`) at rest, right hand, 16:9.** M = A · D with the table of 6.11; model corner (x, y, z) ∈ {0, 1}³ (x east, y up, z south), view = M · corner, depth with F = 768:

| Corner (x, y, z) | view (x, y, z) | ndc | window fraction | depth |
|---|---|---|---|---|
| (0, 0, 0) | (0.27716, −0.72000, −0.72000) | (0.30924, −1.42815) | (0.6546, 1.2141) | 0.069384 |
| (0, 0, 1) | (0.56000, −0.72000, −0.43716) | (1.02907, −2.35217) | (1.0145, 1.6761) | 0.114318 |
| (0, 1, 0) | (0.27716, −0.32000, −0.72000) | (0.30924, −0.63473) | (0.6546, 0.8174) | 0.069384 |
| (0, 1, 1) | (0.56000, −0.32000, −0.43716) | (1.02907, −1.04541) | (1.0145, 1.0227) | 0.114318 |
| (1, 0, 0) | (0.56000, −0.72000, −1.00284) | (0.44859, −1.02535) | (0.7243, 1.0127) | 0.049796 |
| (1, 0, 1) | (0.84284, −0.72000, −0.72000) | (0.94039, −1.42815) | (0.9702, 1.2141) | 0.069384 |
| (1, 1, 0) | (0.56000, −0.32000, −1.00284) | (0.44859, −0.45571) | (0.7243, 0.7279) | 0.049796 |
| (1, 1, 1) | (0.84284, −0.32000, −0.72000) | (0.94039, −0.63473) | (0.9702, 0.8174) | 0.069384 |

Face visibility (view-space unit normal, dot of the normal with the vector from the face centre to the camera): UP (0, 1, 0), +0.32, drawn; WEST (−0.7071, 0, 0.7071), +0.705, drawn; SOUTH (0.7071, 0, 0.7071), −0.087, culled; NORTH (−0.7071, 0, −0.7071), −0.313, culled; EAST (0.7071, 0, −0.7071), −1.105, culled; DOWN (0, −1, 0), −0.72, culled. The cube centre is at view (0.56, −0.52, −0.72), ndc (0.625, −1.0316), fy 1.016: just below the bottom edge. The visible region is the top face (fx 0.65 … 1.01, fy 0.73 … 1.02) and the upper part of the west face (fx 0.65 … 1.01, fy 0.82 … 1.0 on screen); for the crafting table the top face shows `crafting_table_top` and the west face shows `crafting_table_front` (its model assigns `north` and `west` the front texture, `east` and `south` the side texture, `down` the oak planks). A dirt block (`block/dirt`) has the same geometry with one texture. Brightness: V26.

**V24 The shield in the first-person hand (right hand, E = 0, 16:9).** M = A · D · L (6.12), model pixel (x, y, z) of the plate; the decorated front face is z = −2 and the inner face z = −1 (the camera sees the inner face and the handle). Inner face z = −1:

| Corner (x, y) | not blocking: view (x, y, z) | ndc | window fraction | blocking: view (x, y, z) | ndc | window fraction |
|---|---|---|---|---|---|---|
| (−6, −11) | (1.0450, −0.2725, −0.7981) | (1.0518, −0.4875) | (1.0259, 0.7438) | (0.6917, 0.0119, −0.8606) | (0.6456, 0.0198) | (0.8228, 0.4901) |
| (6, −11) | (0.1111, −0.1908, −0.7981) | (0.1118, −0.3413) | (0.5559, 0.6707) | (−0.2423, −0.0698, −0.8606) | (−0.2261, −0.1158) | (0.3869, 0.5579) |
| (6, 11) | (−0.0387, −1.9030, −0.7981) | (−0.0390, −3.4051) | (0.4805, 2.2026) | (−0.0925, −1.7820, −0.8606) | (−0.0863, −2.9571) | (0.4568, 1.9785) |
| (−6, 11) | (0.8952, −1.9847, −0.7981) | (0.9011, −3.5513) | (0.9505, 2.2757) | (0.8415, −1.7003, −0.8606) | (0.7854, −2.8215) | (0.8927, 1.9107) |

The outer face (z = −2) has the same view x and y and view z −0.8762 (not blocking) and −0.9387 (blocking). Both matrices have the constant column given in 6.12; the 3 × 3 block maps model x to view −x, model y to view −y (model y is down) and model z to view +z (0.0781 view units per model pixel of z: the handle end at z = 5 px is 0.469 closer to the camera than the inner face, at view z −0.329). Left hand (entries (0, 180, 5) / (10, 0, −10) not blocking and (0, 180, −5) / (5, 5, −11) blocking, mirrored once more on use; note the not-blocking left entry has ty = 0 where the right entry has 1.75, so the left hand is not an exact mirror of the right): not blocking, M has the 3 × 3 block ((−1.24524, 0.10894, 0), (−0.10894, −1.24524, 0), (0, 0, 1.25)) and the constant (−0.50791, −1.08815, −0.72000); the inner face (z = −1) spans fx −0.028 … 0.517 and its top edge is at fy 0.671 … 0.744; blocking: constant (−0.30435, −0.88459, −0.78250), inner face fx 0.105 … 0.611, top edge fy 0.490 … 0.558.

**V25 The mesh of tiny sprites (the generator's unit test).** A 1 × 1 fully opaque sprite (w = h = 1, s = 16) gives 6 quads (front, back and one wall per side). In the format "vertex: position (x, y, z in model pixels), texture coordinate (fraction of the sprite)":

| Quad | v0 | v1 | v2 | v3 |
|---|---|---|---|---|
| front (SOUTH) | (0, 16, 8.5) (0, 0) | (0, 0, 8.5) (0, 1) | (16, 0, 8.5) (1, 1) | (16, 16, 8.5) (1, 0) |
| back (NORTH) | (16, 16, 7.5) (1, 0) | (16, 0, 7.5) (1, 1) | (0, 0, 7.5) (0, 1) | (0, 16, 7.5) (0, 0) |
| UP | (0, 16, 7.5) (0.1, 0.1) | (0, 16, 8.5) (0.1, 0.9) | (16, 16, 8.5) (0.9, 0.9) | (16, 16, 7.5) (0.9, 0.1) |
| DOWN | (0, 0, 8.5) (0.1, 0.1) | (0, 0, 7.5) (0.1, 0.9) | (16, 0, 7.5) (0.9, 0.9) | (16, 0, 8.5) (0.9, 0.1) |
| WEST (left wall) | (0, 16, 7.5) (0.9, 0.1) | (0, 0, 7.5) (0.9, 0.9) | (0, 0, 8.5) (0.1, 0.9) | (0, 16, 8.5) (0.1, 0.1) |
| EAST (right wall) | (16, 16, 8.5) (0.9, 0.1) | (16, 0, 8.5) (0.9, 0.9) | (16, 0, 7.5) (0.1, 0.9) | (16, 16, 7.5) (0.1, 0.1) |

A fully opaque 16 × 16 sprite gives 2 + 4 × 16 = 66 quads; the wooden pickaxe 74 (6.8). Two opaque texels that touch get no wall between them.

**V26 Brightness of held items (the item shade of 6.10, no light-map factor).** Light directions L0 = (0.16169, 0.80845, −0.56592), L1 = (−0.16169, 0.80845, 0.56592); n_world = Ry(π − yaw) · Rx(−pitch) · n_view.

| Face (pickaxe, right hand at rest) | n_view | yaw 0 / pitch 0 | yaw 90 / 0 | yaw 180 / 0 | yaw 270 / 0 | yaw 0 / pitch 45 | yaw 0 / pitch −45 |
|---|---|---|---|---|---|---|---|
| front (+z, drawn) | (−1, 0, 0) | 0.4970 | 0.7395 | 0.4970 | 0.7395 | 0.4970 | 0.4970 |
| back (−z, culled) | (1, 0, 0) | 0.4970 | 0.7395 | 0.4970 | 0.7395 | 0.4970 | 0.4970 |
| wall UP | (0, 0.9063, −0.4226) | 1.0000 | 1.0000 | 1.0000 | 1.0000 | 0.8850 | 1.0000 |
| wall DOWN | (0, −0.9063, 0.4226) | 0.4000 | 0.4000 | 0.4000 | 0.4000 | 0.5532 | 0.4000 |
| wall EAST (sprite right edge) | (0, 0.4226, 0.9063) | 0.9127 | 0.8100 | 0.9127 | 0.8100 | 1.0000 | 0.5532 |
| wall WEST (sprite left edge) | (0, −0.4226, −0.9063) | 0.5027 | 0.4000 | 0.5027 | 0.4000 | 0.4000 | 0.8850 |

| Face (held cube, right hand at rest) | n_view | yaw 0 / 0 | yaw 90 / 0 | yaw 180 / 0 | yaw 270 / 0 | yaw 0 / pitch 45 |
|---|---|---|---|---|---|---|
| UP (drawn) | (0, 1, 0) | 1.0000 | 1.0000 | 1.0000 | 1.0000 | 1.0000 |
| WEST (drawn) | (−0.7071, 0, 0.7071) | 0.7087 | 0.5715 | 0.7087 | 0.5715 | 0.8851 |
| SOUTH (culled) | (0.7071, 0, 0.7071) | 0.5715 | 0.7087 | 0.5715 | 0.7087 | 0.8851 |
| NORTH (culled) | (−0.7071, 0, −0.7071) | 0.5715 | 0.7087 | 0.5715 | 0.7087 | 0.4000 |
| EAST (culled) | (0.7071, 0, −0.7071) | 0.7087 | 0.5715 | 0.7087 | 0.5715 | 0.4000 |
| DOWN (culled) | (0, −1, 0) | 0.4000 | 0.4000 | 0.4000 | 0.4000 | 0.4000 |

The final colour of a texel is texture × tint × this brightness × the light-map colour of the player's light coordinate (1.8): in full sky light (block 0, sky 15) the light map is white. Example: the texel (106, 80, 30) of the wooden pickaxe on its front face at yaw 0, pitch 0 in full daylight: (106, 80, 30) × 0.4970 = (52.7, 39.8, 14.9) before the display gamma.

---

## 10. Open questions

1. **Quad triangulation.** The lighter has no flip rule. Which of the two index generators in `RenderSystem$AutoStorageIndexBuffer` the terrain pipeline uses (triangles 0-1-2 and 2-3-0, or 0-1-2 and 3-2-1) was not traced to the pipeline's primitive topology (1.3c).
2. **Blindness and the void-darkness value.** What `BlindnessFogEnvironment.getModifiedDarkness` returns during the last 19 ticks of the effect (3.3).
3. **Weather layers.** The grey brightness of `blend_to_gray` and the colour blended into `visual/sky_light_color` in rain and thunder, the exact meaning of the layer weight (assumed equal to the smoothed rain and thunder levels), and the star-brightness layer (3.5).
4. **Crumbling depth bias.** Whether the 10.0 passed to the crumbling pipeline's depth state is a slope-scaled or a constant bias (4.3).
5. **Disabled button text colour** and the over-wide label scrolling rule (5.9).
6. **Item-use arm poses not reproduced.** Brush (`applyBrushTransform`) was not read. The spear animations are written in 34-1 §3.8. The mapping of the toot-horn, bundle and none animations to the first-person branches is given in 6.13.
7. **Third-person arm animation.** The `stab` swing and the last statements of the `whack` branch of `setupAttackAnimation`; swimming, elytra and crawling poses; the cape, elytra and armour layers; the skin-parts bits other than the listed layers (7.5, 7.6).
8. **Biome colour tinting** (grass, foliage, water, the `tintindex` sources for blocks, and the `biomeBlendRadius` averaging) is not covered here; 08 has the item tint sources.
9. **Camera and field of view.** The default of the `camera_distance` attribute for the player (4.0 inferred) and the player's field-of-view modifier (`AbstractClientPlayer.getFieldOfViewModifier`, 6.9) were not read. Given in 6.9: the near plane (0.05), the far plane, the death and fluid modification, and the fixed 70° hand field of view.
10. **Option defaults read indirectly.** `textureFiltering` default RGSS and `maxAnisotropyBit` default 2 (value 2^bit) were taken from the order of constructor arguments, not from named constants (2.1). The `cloudRange` part is answered: `IntRange(2, 128)`, default 128 (3.7f).
11. **Default values of** `chunkSectionFadeInTime`, the glint strength and glint speed options, and the `UiLightmap` values used for GUI items.
12. **Text colour with alpha 0.** How `Font` treats a text colour whose alpha is 0 (5.10).
13. **Italic shear.** How the shear constants (0.25) combine with the glyph's vertical extent into x offsets (5.10).
14. **End skybox and end flash** (`skybox` = `end`) are not covered.
15. **Skin conversion.** The conversion of legacy 64 × 32 skins to the 64 × 64 layout (7.4).
16. **Vanilla player dimensions** (hitbox 0.6 × 1.8, eye height 1.62) quoted in V20 and 7.3 were not read in this round.

Open questions of 6.7 to 6.14, 8.5, 8.6 and V21 to V26:

17. **Library semantics (JOML, LWJGL; not inside the jar).** Marked "(recalled, not verified)" in 6.7 to 6.9 and 8.2: that `Matrix4f.rotateX/Y/Z` are the standard right-handed rotations; that `Quaternionf.rotationXYZ(x, y, z)` is Rx · Ry · Rz (and `rotationZYX` Rz · Ry · Rx, `rotationYXZ` Ry · Rx · Rz); that `Matrix4f.setPerspective(fov, aspect, zNear, zFar, zZeroToOne)` with swapped near and far is the reversed depth matrix of 6.9; that `Matrix4f.translate/scale/rotate` post-multiply. All were recalled from the libraries' documented behaviour and were not verified against library code. Evidence inside the artifact is plausibility only, not proof: (a) the right-handed reading puts the arm raised by a negative `xRot` towards the player's front (−z) and the first-person and third-person shield poses in plausible places (6.12, V24) (inferred); (b) the reversed Euler products put the blocking shield at head height facing upwards (inferred); (c) the clear value 0.0 of the depth texture and the greater-or-equal depth compare are consistent with the reversed matrix (inferred). 34-1 Open question 3 asks the same about `rotationZYX`.
18. **Winding and y flip.** The GL backend sets no front-face state (default counter-clockwise); the Vulkan backend sets back culling with a clockwise front face and a positive-height viewport, and the y flip that makes the two agree was not traced (the projection matrix is the plain y-up OpenGL form). The rule of 6.9 (counter-clockwise in y-up NDC is the front face) is inferred from that. Read: when the extension `GL_ARB_clip_control` exists the GL backend calls `glClipControl` with the lower-left origin and the zero-to-one depth range, and neither a front-face call nor a cull-face call appears anywhere in the GL backend. A client without clip control gets the [−1, 1] depth mapping, which orders depth the same way (so the ordering rules of 6.9 hold); the exact `isZZeroToOne` plumbing into the projection was not traced further.
19. **Fog and colour modulator during the hand pass.** Which fog uniform is bound while the hand is drawn, and the value of `ColorModulator` for item draws (taken as 1, 1, 1, 1), were not traced (6.9).
20. **`cloudRange` default and `depthFar`.** `depthFar = max(effective render distance × 64, cloudRange × 16)`; at the default render distance 12 the first term is 768. The default of the cloud-range option is read indirectly (Open question 10: 128, which would give 2048). Only the depth column of the examples depends on it.
21. **`AbstractClientPlayer.getFieldOfViewModifier(firstPerson, fovEffectScale)`** (the sprint, speed and bow factor of the world field of view, 6.9) was not read; the hand does not use it.
22. **The shield model's drawing.** The banner pattern layers (`BannerRenderer.submitPatterns`, patterns drawn over the plate) were not covered, and the path from `submitModel` to the entity pipeline was not followed beyond the render type (6.12).
23. **Translucent item sprites.** `ITEM_TRANSLUCENT` and the order-independent-transparency item pipelines (`OIT_ITEM`) exist; which one is used for the hand and how they sort translucent quads was not traced (6.9).
24. **Third-person non-blocking shield.** 6.12 computes the plate's pose from the read constants; the result (the plate carried at the side with its long axis along the arm's forward direction and its decorated face away from the body) was not compared with an actual rendering. If it disagrees with an observed render, suspect Open question 17 first. The first-person shield claim of 6.12 and V24 (the camera sees the inner face and the handle, the decorated face points away) is likewise computed and not compared with a render; that visible face follows from the data (the Ry(180) of the display rotation and the z flip of L), not from the Euler order of Open question 17.
25. **Shade of a held block with light emission and the `shade` flag.** `BakedQuad$MaterialInfo.shadeDirectionOverride` and `lightEmission` of block-model quads in the hand (6.10 uses the emission only through the light coordinate) were not followed further.
26. **Inferred items of 6.7 to 8.6 not listed above.** (a) 8.5: a definition-tree node hands its children parent matrix × own transformation (the product order was inferred from the compose call). (b) 8.6: for the third-person hand, ground, fixed, head and shelf contexts the `LEVEL` setting stays active and normals are in world orientation (inferred; not read item by item). (c) 6.9: the translucent phase is drawn after the solid phase (inferred from the phase names). (d) The far plane of 2048 at default settings: Open question 20. (e) The counter-clockwise front-face rule: Open question 18. (f) The orientation consequence of 6.7.3 (head nearer than handle) and every use of the Euler order: Open question 17.
27. **Improved-transparency details.** The OIT cloud path (`renderOit`, 3.7f) was traced only as far as its selection by the `improvedTransparency` option; the OIT shader stages and the resulting blend of clouds, weather and water were not read, so the picture of that path is not specified.
28. **Sun and moon angle ease.** The cubic-bezier control point order of the `visual/sun_angle` and `visual/moon_angle` tracks (3.2) was read as (x1, y1, x2, y2) = (0.362, 0.241, 0.638, 0.759) (inferred from the symmetry x1 + x2 = 1 and y1 + y2 = 1, which makes the ease point-symmetric about (0.5, 0.5); the constructor's argument order was not read); the angles at ticks other than 6000 and 18000 (3.7b) depend on it.
29. **Rain level.** Whether `ClientLevel.getRainLevel` (the source of the sun and moon alpha, 3.7b) already includes the thunder level was not traced.
30. **Sky pipeline depth and cull state.** The depth-test and culling state of the `CELESTIAL`, `STARS`, `SUNRISE_SUNSET` and `SKY` pipelines is the builder's default (no explicit state was set); the default was not read (3.7b).
31. **Cloud option listeners.** Whether changing `cloudRange` forces an immediate mesh rebuild (3.7f).
