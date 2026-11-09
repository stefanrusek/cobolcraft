# 12 Client rendering behaviour

This document gives the numbers an implementer needs to make a client look finished: block lighting, texture
sampling, sky and fog, the break-crack overlay, the GUI, the first-person hand, the camera modes, the player model and
item drawing. It describes what the reference client does. CobolCraft may implement a simplified subset; where this
text says "the reference client" it is describing the artifact and not requiring the behaviour.

| Item | Value |
|---|---|
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d`, version 26.3. This is the artifact already recorded in [README.md](README.md). |
| Method | Static reading of the shipped bytecode (`javap`), and of the text assets in the same jar (GLSL shaders under `assets/minecraft/shaders`, JSON under `data/minecraft` and `assets/minecraft`), with no execution |
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
5 The GUI. 6 First-person hand and item. 7 Third-person camera and the player model. 8 Item and block-in-hand
rendering. 9 Validation. 10 Open questions.

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
| LEVEL, default dimension | normalize(0.2, 1.0, −0.7) | normalize(−0.2, 1.0, 0.7) | camera/world |
| LEVEL, nether | normalize(0.2, 1.0, −0.7) | normalize(−0.2, −1.0, 0.7) | camera/world |
| ENTITY_IN_UI, PLAYER_SKIN (inventory entity preview) | normalize(0.2, −1.0, 1.0) | normalize(−0.2, −1.0, 0.0) | view |
| ITEMS_FLAT | the default pair rotated by Ry(−0.3927 rad) then Rx(2.3562 rad) | same rotation | GUI |
| ITEMS_3D | the default pair transformed by scale(1, −1, 1), then rotateYXZ(1.0821, 3.2376, 0), then rotateYXZ(−0.3927, 2.3562, 0) | same | GUI |

Item and entity vertices are additionally multiplied by the light map using the entity's light coordinate (full
bright in the GUI: the `UiLightmap`). A flat item (a plain textured quad such as a tool) is drawn with `ITEMS_FLAT`
and appears unshaded; a 3D block item uses `ITEMS_3D`, which gives the three visible faces different brightness
(see section 8).

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

- **Texture**: `textures/environment/clouds.png`, 256 × 256, 1-bit greyscale. Each pixel is a cell; a cell is empty when its
  alpha is below 10 (otherwise solid).
- **Cell size**: 12 × 4 × 12 blocks (x, y, z). The pattern wraps every 256 cells (3072 blocks) in x and z.
- **Height**: the cloud layer's bottom is at world y = `visual/cloud_height` (192.33 in the overworld); its top is 4 blocks higher.
- **Movement**: with t = (gameTime mod (256 × 400)) + partialTick, the camera's cloud-space x = cameraX + t × 0.03, z = cameraZ + 3.96. One
  cell therefore passes in 400 ticks (0.6 blocks per second, `BLOCKS_PER_SECOND`). A cloud feature drifts toward −x (inferred from the sign).
- **Colour**: the `visual/cloud_color` attribute (ARGB; the overworld base `#ccffffff`, alpha 0.8; multiplied by the day track, darker at night). Each face's colour is the cloud colour times a face brightness:
  bottom 0.7, top 1.0, north 0.8, south 0.8, west 0.9, east 0.9. A flat cloud (see below) uses the top brightness.
- **Fog**: the face alpha is multiplied by 1 − value(distance, 0, cloudEnd), distance = spherical distance to the vertex.
- **Modes** (option `cloudStatus`): off; `FAST` = one flat quad per solid cell: the DOWN face of the cell at the layer's bottom, drawn without culling, with the top colour factor 1.0; `FANCY` = a box per solid cell, 12 × 4 × 12 blocks. Let (dx, dz) be the cell's offset from the camera's cell in cells, and d = cloud_height − cameraY. The camera is *below* the layer when d > 0, *above* it when d + 4 < 0, and *inside* it otherwise. A fancy cell emits: its UP face unless the camera is below; its DOWN face unless the camera is above; its NORTH face when the north neighbour cell is empty and dz > 0; SOUTH when the south neighbour is empty and dz < 0; WEST when the west neighbour is empty and dx > 0; EAST when the east neighbour is empty and dx < 0 (so side faces are only built on the camera-facing side). In addition, for cells with |dx| ≤ 1 and |dz| ≤ 1 (the camera's own cell and its 8 neighbours) all six faces are emitted again with the inside flag (reversed winding), so the camera can sit inside a cloud.
- **Range and shape**: with the option `cloudRange` c (2–128; the default 128 is the value following the range in the option's constructor, Open question 10) the meshed radius is r = ceil(c × 16 / 12) cells. A cell at offset (dx, dz) from the camera's cell is meshed when dx² + dz² ≤ r² (a disc: the build loop visits dz ≥ 0 rows in a diamond-shaped scan, tests dx² + dz² against r² and mirrors each row to −dz). The texture index of a cell is ((cameraCellX + dx) mod 256, (cameraCellZ + dz) mod 256).
- **Blend**: `TRANSLUCENT`, depth test default, written with depth.

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

### 6.1 Per-frame set-up

1. View bobbing (`bobView`, applied when the camera entity is a player) with w = the interpolated walk distance (blocks, backwards-interpolated) and b = the bobbing amount (0..1):
   translate (sin(w·π) × b × 0.5, −|cos(w·π) × b|, 0); rotate Z by sin(w·π) × b × 3 degrees; rotate X by |cos(w·π − 0.2) × b| × 5 degrees.
   (The option `bobView` turns this off; b is then 0.)
2. Hurt tilt (`bobHurt`), applied to living camera entities. While dying: rotate Z by 40 − 8000 / (min(deathTime, 20) + 200) degrees and stop. Otherwise, with t = hurtTime / hurtDuration (it counts down from 1 to 0 and the effect only runs while hurtTime ≥ 0): k = sin(t⁴ × π); rotate Y by −hurtDir degrees; rotate Z by −k × 14 × damageTiltStrength degrees (the option, default 1.0); rotate Y by +hurtDir degrees.
3. Hand sway: rotate X by (cameraPitch − xBob) × 0.1 degrees, then Y by (cameraYaw − yBob) × 0.1 degrees, where xBob/yBob are the smoothed view angles that lag the real ones.

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
3. Draw the item with the model's display transform for `firstperson_righthand` (s = +1) or `firstperson_lefthand` (s = −1), see 8.2. (The item is drawn using the item model resolved for the context `FIRST_PERSON_*_HAND`.)

At rest (p = 0, E = 0) a right-hand item is at (0.56, −0.52, −0.72) in front of the camera.

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
- **Blocking with an item that is not a shield** (the `block` use animation): step 1, then translate (s × (−0.14142136), 0.08, 0.14142136); rotate X by −102.25; rotate Y by s × 13.365; rotate Z by s × 78.05. A shield item is only given step 1 (its model is posed by its own display transform).
- **Brush**: `applyBrushTransform` (not reproduced; Open question 6). **Spear/thrust items**: `SpearAnimations` (not reproduced; Open question 6).
- **Spyglass**: while scoping, neither hand is drawn at all (`isScoping` returns early); the spyglass overlay takes over the screen.
- A use animation that matches none of the above gets only step 1; the individual mapping of the toot-horn, bundle and none animations to the two remaining branches (one that does nothing, one that applies the swing of 6.3 step 2) was not separated (Open question 6).
- **Auto spin attack** (riptide): step 1, then translate (s × (−0.4), 0.8, 0.3); rotate Y by s × 65; rotate Z by s × (−85).

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

The camera's field of view is the option `fov` (30–110, default 70), modified by `fovEffectScale` (details not traced); see Open question 9.

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
| BLOCK (`poseBlockingArm`) | xRot = xRot × 0.5 − 0.9424779 + clamp(head.xRot, −1.3962634, 0.43633232); yRot = (−30° for the right arm, +30° for the left, in radians) + clamp(head.yRot, −0.5235988, 0.5235988) |
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

Not covered (capes, elytra, armour layers, held-item layer in third person). Third-person held items use the item's `thirdperson_righthand`/`lefthand` display transform (8.2) attached to the arm pivot.

---

## 8. Items and blocks as items

### 8.1 Item in a GUI slot (`GuiGraphicsExtractor.item`)

A GUI item is rendered with the display context `GUI` into an off-screen item atlas cell of 16 × guiScale pixels square and then blitted to the 16 × 16 GUI-pixel cell at (x, y) with nearest filtering and premultiplied alpha (`GUI_TEXTURED_PREMULTIPLIED_ALPHA`). The view is orthographic: the model's unit cube space [0, 1]³ (before the display transform, centre (0.5, 0.5, 0.5)) maps onto the 16 × 16 cell (1 block = 16 GUI pixels), y up, with the display transform applied. Items whose model extends beyond the cell are drawn larger ("oversized") without clipping to the cell.

**Flat items** (models derived from `builtin/generated`, 08 §5.7; most tools, foods, materials): the generated model's `gui_light` is `front`, the transform for `gui` is identity (the default `item/generated` has no `gui` entry), and the lighting setup is `ITEMS_FLAT`, so the quad is shaded as an unrotated sprite (effectively full brightness with the formula of 1.9 for a normal facing the camera). The 16 × 16 texture fills the cell exactly.
**Block items** (models derived from `block/block` with `gui_light: side`): the `gui` transform is rotation (30, 225, 0), translation (0, 0, 0), scale (0.625, 0.625, 0.625), lighting `ITEMS_3D`. The cube is seen from above-left: the visible faces are UP (brightest), the face towards the viewer on the left (NORTH or WEST depending on the 225° yaw) and on the right.
The shading of those three faces comes from the `ITEMS_3D` light directions of 1.9 using the formula `min(1, (max(0, n·L0) + max(0, n·L1)) × 0.6 + 0.4)`.

### 8.2 Display transforms (`ItemTransform.apply`)

For a context the model's `display` entry (08 §5.6) gives rotation (degrees, X, Y, Z), translation (sixteenths of a block, clamped to ±80) and scale (clamped to ±4). The pose is modified as:

1. translate by (tx, ty, tz) / 16 (for left-hand contexts tx is negated);
2. rotate by the Euler angles (rx, ry, rz) in degrees, applied as `rotationXYZ(rx, ry, rz)` (for left-hand contexts ry and rz are negated);
3. scale by (sx, sy, sz);
4. translate by (−0.5, −0.5, −0.5), moving the model's centre to the origin.

A model with no entry for a context uses no transform at all (only the −0.5 translate). The context list is in 08 §5.6; the left hand falls back to the right-hand entry mirrored as above.

Vanilla defaults (`models/item/generated.json`, `handheld.json`, `block/block.json`) for reference: `item/generated` thirdperson_righthand rot (0,0,0) tr (0,3,1) sc 0.55; firstperson_righthand rot (0,−90,25) tr (1.13,3.2,1.13) sc 0.68; ground tr (0,2,0) sc 0.5; head rot (0,180,0) tr (0,13,7); fixed rot (0,180,0).
`item/handheld` thirdperson_righthand rot (0,−90,55) tr (0,4,0.5) sc 0.85 (lefthand rot (0,90,−55)); firstperson_righthand rot (0,−90,25) tr (1.13,3.2,1.13) sc 0.68 (lefthand rot (0,90,−25)).
`block/block`: gui rot (30,225,0) sc 0.625; ground tr (0,3,0) sc 0.25; fixed sc 0.5; on_shelf rot (0,180,0); thirdperson_righthand rot (75,45,0) tr (0,2.5,0) sc 0.375; firstperson_righthand rot (0,45,0) sc 0.4; firstperson_lefthand rot (0,225,0) sc 0.4.

### 8.3 Enchantment glint

Items with the glint flag are drawn a second time with the `GLINT` blend (source colour factor SRC_COLOR, destination factor ONE: additive, alpha factors ZERO and ONE) using `textures/misc/enchanted_glint_item.png` (128 × 128; armour uses `enchanted_glint_armor.png`).
The texture coordinates are transformed (`TextureTransform.setupGlintTexturing(scale)`): t = (milliseconds × glintSpeed option × 8); translate (−(t mod 110000) / 110000, (t mod 30000) / 30000, 0), rotate Z by 0.17453292 rad (10°), scale by `scale` (8 for items; 0.16 for entity glint and 0.5 for armour entity glint per the lambdas). The fragment shader (`glint.fsh`) outputs texture × colour modulator × fade, with fade = (1 − fog) × `GlintAlpha` (the option glint strength), discarding alpha < 0.1.

### 8.4 Items in the world (summary)

Dropped items and items in item frames use the `ground` and `fixed` display transforms. Their lifetime, pickup delay and merge rules are in 18 §6.11; their motion and pickup box are in 41-item-entity-physics.md.

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

---

## 10. Open questions

1. **Quad triangulation.** The lighter has no flip rule. Which of the two index generators in `RenderSystem$AutoStorageIndexBuffer` the terrain pipeline uses (triangles 0-1-2 and 2-3-0, or 0-1-2 and 3-2-1) was not traced to the pipeline's primitive topology (1.3c).
2. **Blindness and the void-darkness value.** What `BlindnessFogEnvironment.getModifiedDarkness` returns during the last 19 ticks of the effect (3.3).
3. **Weather layers.** The grey brightness of `blend_to_gray` and the colour blended into `visual/sky_light_color` in rain and thunder, the exact meaning of the layer weight (assumed equal to the smoothed rain and thunder levels), and the star-brightness layer (3.5).
4. **Crumbling depth bias.** Whether the 10.0 passed to the crumbling pipeline's depth state is a slope-scaled or a constant bias (4.3).
5. **Disabled button text colour** and the over-wide label scrolling rule (5.9).
6. **Item-use arm poses not reproduced.** Brush (`applyBrushTransform`), spear (`SpearAnimations` first and third person), and which of the toot-horn, bundle and none use animations map to the two unseparated first-person branches (6.6, 7.5).
7. **Third-person arm animation.** The `stab` swing and the last statements of the `whack` branch of `setupAttackAnimation`; swimming, elytra and crawling poses; the cape, elytra and armour layers; the skin-parts bits other than the listed layers (7.5, 7.6).
8. **Biome colour tinting** (grass, foliage, water, the `tintindex` sources for blocks, and the `biomeBlendRadius` averaging) is not covered here; 08 has the item tint sources.
9. **Camera and field of view.** The default of the `camera_distance` attribute for the player (4.0 inferred), `fovEffectScale` handling, the near plane and the far plane (7.2).
10. **Option defaults read indirectly.** `cloudRange` default 128, `textureFiltering` default RGSS and `maxAnisotropyBit` default 2 (value 2^bit) were taken from the order of constructor arguments, not from named constants (2.1, 3.6).
11. **Default values of** `chunkSectionFadeInTime`, the glint strength and glint speed options, and the `UiLightmap` values used for GUI items.
12. **Text colour with alpha 0.** How `Font` treats a text colour whose alpha is 0 (5.10).
13. **Italic shear.** How the shear constants (0.25) combine with the glyph's vertical extent into x offsets (5.10).
14. **End skybox and end flash** (`skybox` = `end`) are not covered.
15. **Skin conversion.** The conversion of legacy 64 × 32 skins to the 64 × 64 layout (7.4).
16. **Vanilla player dimensions** (hitbox 0.6 × 1.8, eye height 1.62) quoted in V20 and 7.3 were not read in this round.
