# 43 Tint sources

| Item | Value |
|---|---|
| Covers | Every colour that the client multiplies into a face or an item layer, and where it comes from: the block tint sources (`BlockColors`, `BlockTintSources`) with their exact constants, the stem and redstone-wire formulas, the biome colour resolvers (grass, foliage, dry foliage, water), the grass colour modifiers, the biome blend average and its cache, the colormap lookup, the water fluid tint, the terrain-particle tint, the item tint sources (`ItemTintSources`: constant, dye, grass, firework, potion, team, custom model data) with their defaults, leather dye mixing, the 16 dye colours, the 40 mob effect colours used by potions, the 16 team colours, the biome JSON fields that carry colours and the colour attributes (fog, water fog, sky), banner layer colour, and the map colour pipeline (brightness choice per pixel, packed id, texture colour) |
| Does not cover | Rows of data: which item definition lists which tint (item definitions are data, a shipped sample is cited only as a cross-check, 22), the per-biome values (biome JSON, data), the colormap PNG pixels, the per-block map colour (code, in 24), the `MapColor` base table (24-1 §8.1). The attribute layering and fog maths that consume the fog, water fog and sky colours (12 §3). Entity colour layers (sheep wool, collars, shulker, tropical fish, wolf armour dye use the dye table of section 8 but their rendering belongs to the entity documents) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md); version 26.3) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of data files with `unzip -p`, with no execution. Files counted with `unzip -Z1 ... \| grep -v '/$' \| wc -l`. Colours that the bytecode holds as signed 32-bit integers are given here as ARGB hex (the conversion was done by arithmetic, not by running the game) |
| Status | Round RS25 (GAP-29 of [../design/README.md](../design/README.md)). Operator decisions "Vanilla assets and data" and "Vanilla client" in `tickets/CC-0001-client-polish.md` |

Class names in backticks say where a fact was read. They are not the design. "ARGB" means 0xAARRGGBB; a colour written as six hex digits is RGB with no alpha. Cross-references: "24-1 §9" is the first part of the block registry (which already holds the block-to-source table; this document agrees with it and fills its "not read" cells, see section 12), "14 §9" the colormap section of the texture-only packs, "12 §3" the environment attributes, "10 §3.5 and §7.7" simplex noise and the biome zoom, "08 §6.4" the item tint source type ids. Statements marked "(inferred)" and "(recalled, not verified)" are listed in the Open questions.

---

## 1. Model in one page

1. A quad of a block model may carry a `tintindex` (data, 08 §5.5). Index -1 means no tint.
2. `BlockColors` maps a block (not a state) to an ordered list of tint sources. A block that is not in the map has an empty list. Index *i* of a face selects element *i* of the list. An index at or beyond the list length gives the colour -1 (opaque white: no effect), not an error (`ModelBlockRenderer.computeTintColor`).
3. A tint source has three outputs: `color(state)` (items, in-hand), `colorInWorld(state, level, pos)` (placed block; defaults to `color`), `colorAsTerrainParticle(state, level, pos)` (defaults to `colorInWorld`).
4. For a placed block, the client computes the colour per block and per tint index once and multiplies it into the vertex colour of every quad that uses that index (`QuadInstance.multiplyColor`, a per-channel multiplication including alpha). All shipped sources return alpha 255.
5. Biome-dependent sources call `BiomeColors.getAverage*Color(level, pos)`, which asks the level for the block tint of one of four resolvers (grass, foliage, dry foliage, water). The level averages the resolver's colour over a square of columns (section 4).
6. Items use a different, data-driven mechanism: the item definition lists `tints` (an array of `ItemTintSource`), and layer *i* of the model uses `tints[i]` (08 §6.4). A layer index beyond the array is untinted (inferred, not read).

---

## 2. Block tint sources (`BlockTintSources`)

Twelve source kinds (`BlockTintSources` has twelve public factory methods: `constant(int)`, `constant(int, int)`, `doubleTallGrass`, `grass`, `grassBlock`, `sugarCane`, `foliage`, `dryFoliage`, `water`, `waterParticles`, `redstone`, `stem`; the class file holds eleven anonymous classes plus one lambda for `constant(int)`). Colours are ARGB. "In hand" is `color(state)`.

| Source | In hand | In world | Terrain particle |
|---|---|---|---|
| `constant(c)` | c | c | c |
| `constant(inHand, inWorld)` | inHand | inWorld | inWorld |
| `grass()` | `GrassColor.getDefaultColor()` = colormap lookup (0.5, 1.0) | average grass colour at pos | same as in world |
| `grassBlock()` | `GrassColor.getDefaultColor()` | average grass colour at pos | `FFFFFFFF` (the break particles of a grass block are not tinted) |
| `doubleTallGrass()` | `GrassColor.getDefaultColor()` | average grass colour at pos, or at pos moved one block down when the state's `half` is `upper` | same as in world |
| `sugarCane()` | `FFFFFFFF` | average grass colour at pos | same as in world |
| `foliage()` | `FF48B518` (-12012264) | average foliage colour at pos | same as in world |
| `dryFoliage()` | `FF5C3C32` (-10732494) | average dry foliage colour at pos | same as in world |
| `water()` | `FFFFFFFF` | average water colour at pos | same as in world |
| `waterParticles()` | `FFFFFFFF` | `FFFFFFFF` (the default of the in-world colour is the in-hand colour) | average water colour at pos |
| `redstone()` | section 2.2 table, by `power` | same | same |
| `stem()` | section 2.3, by `age` | same | same |

Relevant properties (used for cache keys): `doubleTallGrass` depends on `half`, `redstone` on `power`, `stem` on `age`; every other source has none.

### 2.1 Registration (`BlockColors.createDefault`)

The registration list below was read in full; it is the same table as 24-1 §9.3, with the constants verified.

| Blocks | Source list (index 0 first) |
|---|---|
| `tall_grass`, `large_fern` | `doubleTallGrass()` |
| `fern`, `short_grass`, `potted_fern`, `bush` | `grass()` |
| `grass_block` | `grassBlock()` |
| `pink_petals`, `wildflowers` | [blank layer = `constant(FFFFFFFF)`, `grass()`]: index 0 untinted, index 1 grass |
| `spruce_leaves` | `constant(FF619961)` |
| `birch_leaves` | `constant(FF80A755)` |
| `oak_leaves`, `jungle_leaves`, `acacia_leaves`, `dark_oak_leaves`, `vine`, `mangrove_leaves` | `foliage()` |
| `leaf_litter` | `dryFoliage()` |
| `water_cauldron` | `water()` |
| `water`, `bubble_column` | `waterParticles()` |
| `redstone_wire` | `redstone()` |
| `sugar_cane` | `sugarCane()` |
| `attached_melon_stem`, `attached_pumpkin_stem` | `constant(FFE0C71C)` |
| `melon_stem`, `pumpkin_stem` | `stem()` |
| `lily_pad` | `constant(inHand FF71C35C, inWorld FF208030)` (`LILY_PAD_DEFAULT`, `LILY_PAD_IN_WORLD`) |

Observations (all read): the mangrove leaves use the plain `foliage()` source, so their colour is the biome's foliage colour (the mangrove swamp biome overrides foliage, section 5). Cherry, pale oak, azalea and the other leaf blocks are not in the map, so their quads are untinted. The `mangrove` constant `FF92C648` (-7158200) exists as `FoliageColor.FOLIAGE_MANGROVE` and is used by the item definition of the mangrove leaves (section 7.2) and not by `BlockColors`. The four fixed foliage constants of `FoliageColor` are evergreen `FF619961`, birch `FF80A755`, default `FF48B518`, mangrove `FF92C648`.

**Water.** The placed water block (`water`) uses `waterParticles()` whose in-world colour is white: the visible water surface is not coloured through `BlockColors`. The fluid renderer (`FluidRenderer.tesselate`) asks the fluid's model (`FluidStateModelSet`) for its tint source: the water and flowing water models carry `water()`, the lava models carry none (colour -1). The colour is `colorInWorld` of the fluid block's position and applies to the whole fluid mesh of that block (top, sides, overlay), multiplied by the face shade (`ARGB.scaleRGB` of the colour by the directional brightness, 12 §4).

### 2.2 Redstone wire colour by power

For power p in 0..15, with f = p / 15 (single precision): red = f x 0.6 + (0.4 if f > 0 else 0.3); green = clamp(f x f x 0.7 - 0.5, 0, 1); blue = clamp(f x f x 0.6 - 0.7, 0, 1); each channel becomes floor(value x 255) (`ARGB.as8BitChannel`, no clamp: the values above stay within 0..1.0 so no wrap happens), alpha 255. Computed with single-precision steps (the table was derived by arithmetic, not by running the client; all 16 rows were re-derived independently with single-precision arithmetic and agree; Open question 1, resolved):

| p | RGB | p | RGB | p | RGB | p | RGB |
|---|---|---|---|---|---|---|---|
| 0 | 4C0000 | 4 | 8E0000 | 8 | B70000 | 12 | E00000 |
| 1 | 700000 | 5 | 990000 | 9 | C10000 | 13 | EA0600 |
| 2 | 7A0000 | 6 | A30000 | 10 | CC0000 | 14 | F41B00 |
| 3 | 840000 | 7 | AD0000 | 11 | D60000 | 15 | FF3200 |

### 2.3 Stem colour by age

Age a in 0..7 (`StemBlock.AGE`): red = a x 32, green = 255 - a x 8, blue = a x 4, alpha 255. a = 0 gives `00FF00`, a = 7 gives `E0C71C`, which equals the constant of the attached stems.

| a | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| RGB | 00FF00 | 20F704 | 40EF08 | 60E70C | 80DF10 | A0D714 | C0CF18 | E0C71C |

### 2.4 Terrain particles

A block-break (terrain) particle starts with colour 0.6, 0.6, 0.6 (`TerrainParticle`). If tint index 0 of the block has a source, the particle's red, green and blue are each multiplied by the corresponding byte of `colorAsTerrainParticle(state, level, pos)` divided by 255, where pos is the block position containing the particle. The falling-dust particle and the falling-leaves particle use the same lookup of index 0 (`FallingDustParticle$Provider`, `ClientLevel.getClientLeafTintColor`: colour of source 0 in the world at the block, or -1 when there is no source). Consequence: grass block break particles are 0.6 grey (not green); water splash particles use the biome water colour.

---

## 3. Colormaps and the biome colour of one position

### 3.1 Lookup (`ColorMapColorUtil.get`, cross-reference 14 §9)

Inputs: temperature t and downfall d as doubles, a 65536-entry ARGB array, a default colour. 14 §9 already gives the formula; restated for completeness: d' = d x t; x = truncate((1 - t) x 255); y = truncate((1 - d') x 255); index = y x 256 + x; if index >= array length, return the default, else the array entry. The arrays are the raw pixels of `textures/colormap/grass.png`, `foliage.png`, `dry_foliage.png` (`LegacyStuffWrapper.getPixels`, row-major, 256 stride, the three vanilla files are 256 x 256 RGB). The alpha of the result is the alpha of the PNG pixel (255 for the vanilla files); a pack that ships colormaps with transparency would give transparent colours when the radius is 0 (section 4).

Defaults when the index is out of range: grass `FFFF00FF`, foliage `FF48B518`, dry foliage `FF5C3C32`. Before any pack is loaded the arrays are 65536 zeros (colour 0).

### 3.2 From a biome to a colour (`Biome`)

Temperature t and downfall d are the biome's `temperature` and `downfall` (climate settings), each clamped to 0..1 as a single-precision float, then widened to double. (So 0.8f widens to 0.800000011920929, 14 §9 V6.)

| Colour | Rule |
|---|---|
| Foliage | the biome's `foliage_color` if present, else the foliage colormap at (t, d) |
| Dry foliage | the biome's `dry_foliage_color` if present, else the dry foliage colormap at (t, d) |
| Water | the biome's `water_color` (required field, no colormap) |
| Grass | base = the biome's `grass_color` if present, else the grass colormap at (t, d); then the biome's `grass_color_modifier` is applied to base (section 3.3), receiving the block's x and z |

### 3.3 Grass colour modifiers (`BiomeSpecialEffects$GrassColorModifier`)

Serialised names `none`, `dark_forest`, `swamp` (default `none`).

| Modifier | Result |
|---|---|
| `none` | base unchanged |
| `dark_forest` | `opaque(((base AND 0xFEFEFE) + 0x28340A) >> 1)` (alpha forced to 255) |
| `swamp` | n = `Biome.BIOME_INFO_NOISE.get(x x 0.0225, z x 0.0225)` (a 2D simplex noise, specified in 10 §3.5 and 10 Open question 8: `SimplexNoise(WorldgenRandom(LegacyRandomSource(2345)), true)`); `Noise.get` returns a float; it is widened to double and compared strictly (`dcmpg`) with the double constant -0.1 (NaN gives "not less"). If n < -0.1 the result is `FF4C763C` (-11766212), otherwise `FF6A7039` (-9801671). A float noise value of -0.1f widens to about -0.10000000149 and is therefore below -0.1, selecting `FF4C763C`. The base colour is not used by the swamp modifier. |

x and z are the integer block coordinates of the column being sampled, converted to double. In the shipped data the dark forest biome uses `dark_forest`, the swamp and the mangrove swamp use `swamp` (64 biomes use `none`).

---

## 4. Biome blend (`ClientLevel.calculateBlockTint`, `BlockTintCache`)

Inputs: a block position and a resolver. The option `biomeBlendRadius` r is an integer 0..7, default 2 (`Options`, saved in `options.txt` under the key `biomeBlendRadius`; the slider shows the box width 2r + 1 using the language keys `options.biomeBlendRadius.1`, `.3`, ... `.15`, "OFF (Fastest)" for 1, "3x3 (Fast)", "5x5 (Normal)", ... "15x15 (Maximum)"). The graphics presets set it: fast 1, fancy 2, fabulous 2 (`GraphicsPreset`), and changing it re-meshes the world.

| Case | Result |
|---|---|
| r = 0 | the resolver's colour for the biome at the position, using the position's x and z, unaveraged (its alpha is whatever the resolver returns) |
| r > 0 | the box average below, opaque |

Box average (r > 0): the set of columns is every (x', z') with x - r <= x' <= x + r and z - r <= z' <= z + r at the **same y** as the query (`Cursor3D` is created with equal minimum and maximum y), so (2r + 1)^2 positions. For each, the biome is `getBiome` of that position and the colour is the resolver's colour for that biome with (x', z'). The three channels are summed separately (`ARGB.red`, `green`, `blue`), each sum is divided by (2r + 1)^2 with integer division (truncation), and the colour is `ARGB.color(r, g, b)`, alpha 255. There is no weighting and no gamma step. (The Gaussian blur in 12 §3.1 belongs to the environment attributes, a different mechanism with the same option.)

`getBiome` is the level's `BiomeManager.getBiome` (the fuzzy 4 x 4 x 4 zoom of 10 §7.7). The client's `BiomeManager` seed is the `seed` field of the spawn info of the Login and Respawn packets (read: `ClientPacketListener` passes `CommonPlayerSpawnInfo.seed()` to the `ClientLevel` constructor, which builds `BiomeManager(this, seed)`). For the client's grass and water edges to follow the server's biome boundaries exactly, the server should send `obfuscateSeed(worldSeed)` of 10 §7.7 there (05b says the packet field is presumably that hashed seed). Where a cell is not available the level's uncached biome is the plains biome (`ClientLevel.getUncachedNoiseBiome` returns `minecraft:plains`).

Cache (`BlockTintCache`, one per resolver): entries are per chunk column and per y, each a 16 x 16 int layer; at most 256 chunk entries; a layer entry is filled lazily with the average above. It is an optimisation: the colour must equal the uncached computation as long as no block changed biome. It is invalidated for a chunk and its eight neighbours when a chunk is loaded (`invalidateForChunk`), and wholly by `clearTintCaches`. A newly loaded neighbour chunk therefore changes the colours of border blocks after the load.

---

## 5. Biome JSON fields that carry colours (schema, data not tabulated)

A biome file (`data/minecraft/worldgen/biome/*.json`, 67 files) has `temperature`, `downfall`, `has_precipitation`, an `effects` object and an `attributes` map. The top-level keys of the 67 shipped files are `attributes`, `carvers`, `downfall`, `effects`, `features`, `has_precipitation`, `temperature`; two files also have `temperature_modifier`. No file has a spawn key: mob spawn data sits inside `attributes` (for example `minecraft:gameplay/natural_mob_spawns`, read in the swamp file), and carvers and features are for other documents. The colormap lookups (`Biome.getGrassColorFromTexture`, `getFoliageColorFromTexture`, `getDryFoliageColorFromTexture`) use only the raw climate `temperature` and `downfall`, each clamped to 0..1; `temperature_modifier` is not applied to them.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `effects.water_color` | colour | yes | water tint, section 3.2 |
| `effects.foliage_color` | colour | no | foliage override (8 biomes in the shipped data) |
| `effects.dry_foliage_color` | colour | no | dry foliage override (5 biomes) |
| `effects.grass_color` | colour | no | grass base override (7 biomes) |
| `effects.grass_color_modifier` | `none` / `dark_forest` / `swamp` | no | default `none` (3 biomes) |
| `attributes."minecraft:visual/sky_color"` | colour | no | environment attribute (57 biomes set it) |
| `attributes."minecraft:visual/fog_color"` | colour | no | (9 biomes) |
| `attributes."minecraft:visual/water_fog_color"` | colour | no | (9 biomes) |
| `attributes."minecraft:visual/water_fog_end_distance"` | `{modifier, argument}` | no | the two biomes that set it use modifier `multiply`, argument 0.85 |

Colour field syntax (`ExtraCodecs.STRING_RGB_COLOR`, used by `effects`): a string `#RRGGBB` (six hex digits, parsed and made opaque), or an integer (kept as written), or a list of three floats [r, g, b] in 0..1 (converted with floor(v x 255) per channel, alpha 255). Item tint colours (`RGB_COLOR_CODEC`) accept the integer and the float-list forms (same floor rule, alpha 255). `ARGB_COLOR_CODEC` accepts an integer or a list of four floats [r, g, b, a] (alpha from the fourth element, same floor rule). The statics `RGB_COLOR_VEC3_CODEC` and `ARGB_COLOR_VEC4_CODEC` prefer the list form with the integer as alternative. In an `ARGB` string field (`STRING_ARGB_COLOR`) `#AARRGGBB` or an integer is read. The values of `attributes` that are colours use the same attribute colour codecs of 12 §3.1; their defaults, spatial blend and consumers are in 12 §3.1 and §5. The attribute defaults: fog `#000000`, water fog `#050533`, sky `#000000` (12 §3.1).

The dimension type's own attributes (overworld fog `#c0d8ff`, sky `#78a7ff`; Nether and End values) are in 12 §3.1 and are not repeated.

---

## 6. Banner, map and other code-defined colour users

### 6.1 Banner layers

`BannerRenderer.submitPatternLayer` is the only place in that class that calls `DyeColor.getTextureDiffuseColor()` (section 8 column "diffuse"); it uses the result as the model colour of one layer. A banner is drawn in this order:

1. The pole and flag models are drawn untinted (colour -1) with the sprite `Sheets.BANNER_BASE`.
2. The base colour (the `base_color` dye of the block entity, or the item's) is applied by a first pattern layer: the sprite `Sheets.BANNER_PATTERN_BASE` (for a shield, `Sheets.SHIELD_PATTERN_BASE`) drawn through `submitPatternLayer` with the base dye, so it is tinted by that dye's diffuse colour. It is submitted at order 1.
3. Then up to 16 pattern layers of the `banner_patterns` component, in list order, each with the sprite of its pattern and the diffuse colour of the layer's own dye, at order 2 + index.

So the base colour does go through the diffuse colour, by a tinted base-pattern layer (read in `submitPatterns`). Which texture files those sprite ids name is data (the atlas) and was not traced (Open question 4).

### 6.2 Map colours

A map pixel is one byte, the **packed id**: `packed = baseColorId x 4 + brightnessId`, where `baseColorId` is the `MapColor` id (0 to 61; table 24-1 §8.1) and `brightnessId` the ordinal of `MapColor$Brightness`: 0 `LOW` (modifier 180), 1 `NORMAL` (220), 2 `HIGH` (255), 3 `LOWEST` (135). The client draws a map by converting each byte (masked to 0..255) with `MapColor.getColorFromPackedId`: base id = packed >> 2, brightness = packed & 3; base id 0 (`NONE`) gives 0 (transparent); any other gives `opaque(base)` with each of r, g, b multiplied by modifier / 255 using integer division (`calculateARGBColor`, 24-1 §8.1), and the result is the pixel (`MapTextureManager$MapInstance`). Ids that are not defined give `NONE`.

Which base colour a block contributes is the block's map colour function (`BlockState.getMapColor(level, pos)`, the `mapColor` setting of the block registry, 24). Dye-coloured blocks use the dye's map colour of section 8.

**Server-side pixel computation** (`MapItem.update`, run for each map a player holds, for the holder only when the holder is in the map's dimension). The result is, per map pixel (i, j) in 0..127 (row j = -1 is computed only as a reference), a packed id; only which pixels are refreshed and how the packed id is derived matter here.

Definitions: map scale s (0..4), centre (cx, cz), `S = 1 << s` blocks per pixel along one axis. The holder's pixel is `px = floor(entity.x - cx) / S + 64`, `pz = floor(entity.z - cz) / S + 64` (integer division truncating toward zero). Update radius `R = 128 / S`, halved (integer) when the dimension type has a ceiling.

**Which pixels are refreshed.** A pixel (i, j) is a candidate when `px - R + 1 <= i < px + R`, `pz - R - 1 <= j < pz + R`, `0 <= i < 128` and `-1 <= j < 128`. With `d2 = (i - px)^2 + (j - pz)^2`, it is written only when `d2 < R^2`, and, inside the rim `d2 > (R - 2)^2`, only when `(i + j)` is odd (a dithered edge). Row j = -1 is never written. Columns are throttled: each holder keeps a counter that rises by 1 per update, and a column i is recomputed in a given update when `(i AND 15)` equals `(counter AND 15)` (so each column is refreshed once per 16 updates), or immediately after a column in the same update that actually changed a pixel. A pixel whose cell lies in a chunk that is empty is skipped. Writing a packed id that equals the stored one changes nothing.

**Cell origin.** `bx = (cx / S + i - 64) x S`, `bz = (cz / S + j - 64) x S` (`cx / S` integer division); the cell covers the S x S block columns from (bx, bz).

**Cell colour and height.**
- Dimension with a ceiling: `h = bx + bz x 231871`; `h = h x h x 31287121 + h x 11` (32-bit integer arithmetic). If bit 20 of h is 0 the cell is the map colour of the default dirt state with weight 10, otherwise of the default stone state with weight 100. Average height 100.0, water depth 0.
- Otherwise, for each column in the cell, visiting dx from 0 to S - 1 as the outer loop and dz from 0 to S - 1 as the inner loop (so the order is x-major, z varying fastest; the position is (bx + dx, bz + dz)): the walk below (read in `MapItem.update` and `getCorrectStateForFluidBlock`). Let H be the `WORLD_SURFACE` heightmap value of the column and `minY` the level's minimum build height.
  1. y = H + 1. If y is at or below `minY` already, the block of this column is bedrock (the default bedrock state) and steps 2 to 4 are skipped. This is the only case in which bedrock is substituted.
  2. Sink through colourless blocks. The loop is decrement-first: y is decreased by 1, then the block at the new y is read, so the first block read is the one at y = H (the surface block, not the block above it). It repeats while that block's map colour is `NONE` and y is above `minY`. It therefore ends either on a block with a map colour, or with y <= `minY`; in the second case the block read at that y is used as it is (no bedrock substitution, and no fluid handling in step 3).
  3. Fluid depth. Only when y is above `minY` and the block found has a non-empty fluid state: the depth counter starts at 0; a second cursor starts at y - 1 (the block directly below the found block) and moves down one block per iteration. Each iteration reads the block at the cursor, adds 1 to the depth (including the iteration whose block has no fluid), then lowers the cursor. The loop stops after an iteration that read a fluid-free block, or when the lowered cursor is at or below `minY` (so the block at `minY` itself is never visited by this loop). The depth is thus the number of blocks visited: for a column with the found water block on top and n further water blocks below it, ending on a fluid-free block, the depth is n + 1, which equals the total number of water blocks in the column counting the top one. After the walk, if the found state holds a fluid and is not up-face sturdy, the fluid's legacy block state replaces it as the block whose map colour counts.
  4. The column contributes the map colour of the resulting block state (read at the block position (x, y, z) of the sink end).

  Each column adds weight 1 to its block's map colour and `y / (S x S)` to the average height (double). The depth sum is divided by `S x S` with integer division. (A banner at the column also registers a banner marker, a side effect not described further.)

**Winning colour.** The colour with the highest total weight. The counts are held in an insertion-ordered multiset (a Guava `LinkedHashMultiset`), then sorted highest count first (`Multisets.copyHighestCountFirst`), and the first entry is taken (`NONE` when empty). Entries therefore sit in first-inserted order before the sort, so a tie is resolved by the colour that was inserted first, which is the colour of the first column in the dx-outer, dz-inner order above (the sort's stability for equal counts is a property of the library, recalled, not verified: Open question 2). For the ceiling case there is a single entry and no tie.

**Brightness.** `par = (i + j) AND 1`; all arithmetic in double precision, thresholds compared as doubles.
- Colour `WATER`: `v = depth x 0.1 + par x 0.2`; `HIGH` if `v < 0.5`, `LOW` if `v > 0.9`, else `NORMAL`.
- Any other colour: `v = ((avgHeight - prevAvg) x 4.0) / (S + 4) + (par - 0.5) x 0.4`, where `prevAvg` is the previous row's average height in the same column. It is reset to 0 at the start of each column (so the first candidate row, j = -1, is compared against 0 and only seeds the value) and is updated, after the brightness is chosen, only for cells that passed the range check (`0 <= i < 128`, `-1 <= j < 128`) and the empty-chunk check. A cell skipped because it is out of range or lies in an empty chunk leaves `prevAvg` unchanged, so the next processed row of the column is compared with the last processed row, not with 0. The update happens before the circle and dither tests of "Which pixels are refreshed": a cell that is processed but then not written (outside `R^2`, in the dither gap, or row -1) still updates `prevAvg`. The water branch also performs this update, with the cell's average height. `HIGH` if `v > 0.6`, `LOW` if `v < -0.6`, else `NORMAL`. `LOWEST` is never produced here.
- The order of operations matters because the boundary cases are exact in decimal and inexact in binary: divide (4 x height difference) by (S + 4) first, and add the dither term `(par - 0.5) x 0.4` afterwards. An implementation using a different order or decimal arithmetic gets different pixels.

Packed id: `baseColorId x 4 + brightnessId`.

Worked examples (S = 1, double precision): flat land, i + j even: v = 0 + (0 - 0.5) x 0.4 = -0.2, NORMAL. Terrain rising by 1 from the previous row, i + j odd: v = 4.0 / 5 + 0.5 x 0.4 = 0.8 + 0.2 = 1.0, HIGH. Rising by 1, i + j even: 0.8 + (-0.2) evaluates to 0.6000000000000001 in IEEE double, which is greater than 0.6, so the pixel is HIGH (not NORMAL as exact decimal arithmetic would suggest). Falling by 1, i + j odd: -0.8 + 0.2 = -0.6000000000000001, below -0.6, so LOW; falling by 1, i + j even: -1.0, LOW; rising by 1 with par 1 gives 1.0 as above. Water of depth 5, i + j even: v = 0.5, not below 0.5, NORMAL (exact in binary); depth 4: 0.4, HIGH; depth 8, i + j odd: 1.0, LOW. A grass block (`GRASS`, id 1) at NORMAL has packed id 1 x 4 + 1 = 5 and colour `FF6D9930` (0x7F, 0xB2, 0x38 scaled by 220 / 255 with truncation: 109, 153, 48).

---

## 7. Item tint sources (`ItemTintSources`, package `net.minecraft.client.color.item`)

An item tint source computes an ARGB colour from the stack, the client level and the holding entity (`calculate(stack, level, entity)`). Seven types, ids in the `minecraft` namespace, selected by the `type` field of a `tints` element. `ItemTintSources` registers them in the order `custom_model_data`, `constant`, `dye`, `grass`, `firework`, `potion`, `team` into a late-bound id mapper with no numeric ids; that order has no meaning on the wire or in data. The table below uses the order of 08 §6.4 (`constant` first, `custom_model_data` last), which is a presentation choice:

| Type | Fields | Result |
|---|---|---|
| `constant` | `value` (RGB colour codec) | `opaque(value)` |
| `dye` | `default` (RGB colour codec) | the `dyed_color` component of the stack as `opaque(rgb)`, else `default` unchanged (the default keeps its own alpha) |
| `grass` | `temperature`, `downfall` (floats 0..1; defaults 0.5 and 1.0 when the type is built without fields, the codec has both fields required) | the grass colormap at (temperature, downfall) (section 3.1; no biome, no modifier) |
| `firework` | `default` (default `FF8A8A8A` = -7697782) | from the `firework_explosion` component's colour list: empty or no component gives `default`; one colour gives `opaque(colour)`; more give the per-channel integer mean of all colours (sum of each of r, g, b divided by the count, truncating), alpha 255 |
| `potion` | `default` (default `FF385DC6` = -13083194) | `opaque(PotionContents.getColorOr(default))` when the stack has `potion_contents`, else `opaque(default)`; see 7.3 |
| `team` | `default` | the colour of the holding entity's team if the entity exists and its team has a colour (`TeamColor.rgb`, section 9), as `opaque(rgb)`, else `opaque(default)` |
| `custom_model_data` | `index` (non-negative int, default 0), `default` | `opaque(colour at index)` from the `custom_model_data` component's `colors` list when present at that index, else `opaque(default)` |

### 7.1 Which items use which tint in the shipped item definitions (data cross-check, not normative)

Read from `assets/minecraft/items/*.json` (1658 files, 26 of them contain `tints`; counted from the archive). This list lets an implementation test its parser; the extraction tool copies the files and nothing here needs to be re-keyed.

| Items | Tints, by layer index |
|---|---|
| `oak_leaves`, `acacia_leaves`, `dark_oak_leaves`, `jungle_leaves`, `vine` | [constant `FF48B518`] |
| `spruce_leaves` | [constant `FF619961`] |
| `birch_leaves` | [constant `FF80A755`] |
| `mangrove_leaves` | [constant `FF92C648`] |
| `lily_pad` | [constant `FF71C35C`] |
| `grass_block`, `short_grass`, `fern`, `tall_grass`, `large_fern`, `bush` | [grass 0.5, 1.0] |
| `leather_helmet`, `leather_chestplate`, `leather_leggings`, `leather_boots`, `leather_horse_armor` (all trim variants too) | [dye default `FFA06540` = -6265536] |
| `wolf_armor` | a `condition` on the `has_component` property for `dyed_color`: when absent, the plain model `item/wolf_armor` with no tints; when present, the model `item/wolf_armor_dyed` with tints [constant -1 (white), dye default 0]. In the dyed case the dye source returns the component's colour (opaque), the default 0 is not reached |
| `potion`, `splash_potion`, `lingering_potion`, `tipped_arrow` | [potion default `FF385DC6`] |
| `firework_star` | [constant `FFFFFFFF`, firework default `FF8A8A8A`] |

Spawn eggs have no tints (the item definition of `pig_spawn_egg` and the like is a plain model; the egg colours are in the textures). Items that are not listed have no tints: for example `sugar_cane`, `leaf_litter`, `pink_petals`, `wildflowers`, `water_bucket`, `filled_map` (map texture) and banners (their colour is a layer colour, 6.1). The block items of the leaves list above use constants equal to the in-hand colours of `BlockColors`, except that the item `oak_leaves` etc. use `FF48B518` for all five foliage blocks and the mangrove item uses `FF92C648`.

### 7.2 Worn leather armour (data field, engine rule)

An equipment asset layer (`assets/minecraft/equipment/*.json`, 45 files) may carry `dyeable`, an object whose only field `color_when_undyed` is **optional** (`EquipmentClientInfo$Dyeable` holds an `Optional` integer, an RGB colour codec field). Per-layer colour rule (read in `EquipmentLayerRenderer.renderLayers` and `getColorForLayer`):

1. The stack's dye colour is `DyedItemColor.getOrDefault(stack, 0)`: the `dyed_color` component as `opaque(rgb)`, else 0.
2. A layer with no `dyeable` entry is drawn with colour -1 (white, unaffected by dye), whatever the stack's dye.
3. A layer with `dyeable`: if the dye colour is non-zero it is used; otherwise the colour is `color_when_undyed` when present, else 0. The `color_when_undyed` Optional goes through a mapping step that is `ARGB.opaque` (read: the only non-lambda method handle in `EquipmentLayerRenderer`'s bootstrap table), then `orElse(0)`. A present value is therefore forced to alpha FF; an absent one stays 0, which is why such a layer (the scute overlay) is skipped (step 4). The shipped value -6265536 already has alpha FF, so the shipped output is unchanged.
4. A layer whose resulting colour is 0 is skipped: it is not drawn at all.

Shipped cases: `leather.json` has four layer types (`horse_body`, `humanoid`, `humanoid_baby`, `humanoid_leggings`), each with two layers: the first with `dyeable` and `color_when_undyed` -6265536 (`FFA06540`), the second (the overlay) with no `dyeable` entry, so the overlay is always white. `armadillo_scute.json` has one layer type, `wolf_body`, with two layers: the base layer has no `dyeable` entry (white), and the overlay layer has `dyeable: {}` with no `color_when_undyed`. So a dyeable layer without a default exists in the shipped data: wolf armour dyeing goes through this path, an undyed scute overlay has colour 0 and is not drawn, and a dyed one is drawn in the dye colour.

### 7.3 Potion colour (`PotionContents`)

1. If the component has a `custom_color`, that colour.
2. Otherwise the effects considered are the potion's own effect list followed by the component's custom effects (if no potion: the custom effects only).
3. Only visible effects count (`MobEffectInstance.isVisible`). Each contributes its mob effect colour (section 10) with weight w = amplifier + 1. Sum the weighted red, green and blue; total weight W. If W = 0 there is no colour (the caller's default, `FF385DC6` for the shipped items, applies; a water bottle has no effects and is therefore this blue). Else each channel is its sum divided by W (integer division, truncating) and the colour is `ARGB.color(r, g, b)`.
4. The `potion` item tint source applies `opaque` to the result.

Worked example: Speed II (amplifier 1, weight 2, colour `33EBFF`) plus Strength I (weight 1, `FFC700`): r = (2 x 0x33 + 0xFF) / 3 = (102 + 255) / 3 = 119 (0x77); g = (2 x 0xEB + 0xC7) / 3 = (470 + 199) / 3 = 223 (0xDF); b = (2 x 0xFF + 0x00) / 3 = 170 (0xAA); colour `77DFAA`, item tint `FF77DFAA`.

### 7.4 Leather dye mixing (`DyedItemColor.applyDyes`)

Inputs: the stack's current `dyed_color` (absent when undyed) and a list of dyes; the result is the `rgb` stored in the component with alpha 0 (the alpha is added when it is read, 7 `dye` source).

1. Let n = 0, sums sr = sg = sb = 0 and `maxSum = 0`. If the item has a dyed colour: add its r, g, b to the sums, add max(r, g, b) to `maxSum`, n = 1.
2. For each dye in the list: take its **diffuse** colour (section 8, the `textureDiffuseColor`, stored internally as opaque ARGB; only its r, g, b bytes are used here) and do the same: add r, g, b, add max(r, g, b) to `maxSum`, n = n + 1.
3. `ar = sr / n`, `ag = sg / n`, `ab = sb / n` (integer division). `avgMax = maxSum / n` (single-precision float division). `top = max(ar, ag, ab)` as a float.
4. Each channel becomes truncate(`a` x `avgMax` / `top`) in single precision (`top` = 0 gives 0 after the float-to-int conversion of NaN, which needs all-black input and does not occur with the 16 dyes).
5. Result: alpha 0, the three channels.

Worked example, undyed leather with Red (`B02E26`) then Blue (`3C44AA`): sums r = 176 + 60 = 236, g = 46 + 68 = 114, b = 38 + 170 = 208; n = 2; `maxSum` = 176 + 170 = 346; averages 118, 57, 104; `avgMax` = 173.0; `top` = 118; r = 118 x 173 / 118 = 173; g = 57 x 173 / 118 = 83.57 -> 83; b = 104 x 173 / 118 = 152.47 -> 152; result `AD5398`.

---

## 8. Dye colours (`DyeColor`, 16, in declaration order)

Columns: id, name, **diffuse** (`textureDiffuseColor`: leather dye mixing, banner and pattern layers), map colour (`getMapColor`, and its terracotta variant `getTerracottaColor`), **firework** colour, **text** colour (signs). `DyeColor` stores the diffuse and the text colour through `ARGB.opaque`, so internally they are opaque ARGB (alpha 255); the firework colour is stored raw, as RGB without alpha. The columns below give the RGB part of all three.

| id | name | diffuse | map colour | terracotta map colour | firework | text |
|---|---|---|---|---|---|---|
| 0 | white | F9FFFE | `SNOW` | `TERRACOTTA_WHITE` | F0F0F0 | FFFFFF |
| 1 | orange | F9801D | `COLOR_ORANGE` | `TERRACOTTA_ORANGE` | EB8844 | FF681F |
| 2 | magenta | C74EBD | `COLOR_MAGENTA` | `TERRACOTTA_MAGENTA` | C354CD | FF00FF |
| 3 | light_blue | 3AB3DA | `COLOR_LIGHT_BLUE` | `TERRACOTTA_LIGHT_BLUE` | 6689D3 | 9AC0CD |
| 4 | yellow | FED83D | `COLOR_YELLOW` | `TERRACOTTA_YELLOW` | DECF2A | FFFF00 |
| 5 | lime | 80C71F | `COLOR_LIGHT_GREEN` | `TERRACOTTA_LIGHT_GREEN` | 41CD34 | BFFF00 |
| 6 | pink | F38BAA | `COLOR_PINK` | `TERRACOTTA_PINK` | D88198 | FF69B4 |
| 7 | gray | 474F52 | `COLOR_GRAY` | `TERRACOTTA_GRAY` | 434343 | 808080 |
| 8 | light_gray | 9D9D97 | `COLOR_LIGHT_GRAY` | `TERRACOTTA_LIGHT_GRAY` | ABABAB | D3D3D3 |
| 9 | cyan | 169C9C | `COLOR_CYAN` | `TERRACOTTA_CYAN` | 287697 | 00FFFF |
| 10 | purple | 8932B8 | `COLOR_PURPLE` | `TERRACOTTA_PURPLE` | 7B2FBE | A020F0 |
| 11 | blue | 3C44AA | `COLOR_BLUE` | `TERRACOTTA_BLUE` | 253192 | 0000FF |
| 12 | brown | 835432 | `COLOR_BROWN` | `TERRACOTTA_BROWN` | 51301A | 8B4513 |
| 13 | green | 5E7C16 | `COLOR_GREEN` | `TERRACOTTA_GREEN` | 3B511A | 00FF00 |
| 14 | red | B02E26 | `COLOR_RED` | `TERRACOTTA_RED` | B3312C | FF0000 |
| 15 | black | 1D1D21 | `COLOR_BLACK` | `TERRACOTTA_BLACK` | 1E1B1B | 000000 |

The ids are the ordinals (the values 11 and 11 of the first two integer arguments of BLUE in the constructor call confirm id = ordinal, read for BLUE). The map colour column agrees with 24-2 §2.8.

---

## 9. Team colours (`TeamColor`, 16)

The `team` item tint source and scoreboard text use `TeamColor.rgb`, which is the value of the matching chat text colour (`TextColor`): black 000000, dark_blue 0000AA, dark_green 00AA00, dark_aqua 00AAAA, dark_red AA0000, dark_purple AA00AA, gold FFAA00, gray AAAAAA, dark_gray 555555, blue 5555FF, green 55FF55, aqua 55FFFF, red FF5555, light_purple FF55FF, yellow FFFF55, white FFFFFF (the enum order is this order, ids 0 to 15).

---

## 10. Mob effect colours (40, in registration order; used by potions and tipped arrows)

RGB, as stored (the integer without alpha). The order is the registration order of `MobEffects` and agrees with the 40 entries of 46 §4.1.

| # | Effect | RGB | # | Effect | RGB |
|---|---|---|---|---|---|
| 0 | speed | 33EBFF | 20 | health_boost | F87D23 |
| 1 | slowness | 8BAFE0 | 21 | absorption | 2552A5 |
| 2 | haste | D9C043 | 22 | saturation | F82423 |
| 3 | mining_fatigue | 4A4217 | 23 | glowing | 94A061 |
| 4 | strength | FFC700 | 24 | levitation | CEFFFF |
| 5 | instant_health | F82423 | 25 | luck | 59C106 |
| 6 | instant_damage | A9656A | 26 | unluck | C0A44D |
| 7 | jump_boost | FDFF84 | 27 | slow_falling | F3CFB9 |
| 8 | nausea | 551D4A | 28 | conduit_power | 1DC2D1 |
| 9 | regeneration | CD5CAB | 29 | dolphins_grace | 88A3BE |
| 10 | resistance | 9146F0 | 30 | bad_omen | 0B6138 |
| 11 | fire_resistance | FF9900 | 31 | hero_of_the_village | 44FF44 |
| 12 | water_breathing | 98DAC0 | 32 | darkness | 292721 |
| 13 | invisibility | F6F6F6 | 33 | trial_omen | 16A6A6 |
| 14 | blindness | 1F1F23 | 34 | raid_omen | DE4058 |
| 15 | night_vision | C2FF66 | 35 | wind_charged | BDC9FF |
| 16 | hunger | 587653 | 36 | weaving | 78695A |
| 17 | weakness | 484D48 | 37 | oozing | 99FFA3 |
| 18 | poison | 87A363 | 38 | infested | 8C9B8C |
| 19 | wither | 736156 | 39 | breath_of_the_nautilus | 00FFEE |

---

## 11. Worked examples and validation

Colormap values below were read from the three vanilla PNGs (256 x 256, 8-bit RGB), using t and d clamped to 0..1 in single precision and widened (section 3.2). They check a lookup implementation against the vanilla pack and are not normative for another pack.

| Case | t, d | (x, y) | grass | foliage | dry foliage |
|---|---|---|---|---|---|
| plains | 0.8, 0.4 | (50, 173) | 91BD59 | 77AB2F | A37546 |
| forest, dark forest (before modifier) | 0.7, 0.8 | (76, 112) | 79C05A | 59AE30 | A36D46 |
| swamp | 0.8, 0.9 | (50, 71) | 6AC44E | 45B421 | A36946 |
| taiga | 0.25, 0.8 | (191, 203) | 86B783 | 68A464 | 9A764F |
| snowy plains | 0.0, 0.5 | (255, 255) | 80B497 | 60A17B | 8F7A5A |
| jungle | 0.95, 0.9 | (12, 36) | 59C93C | 30BB0B | A36346 |
| desert (2.0 clamps to 1.0) | 1.0, 0.0 | (0, 255) | BFB755 | AEA42A | A38046 |
| item default (grass source) | 0.5, 1.0 | (127, 127) | 7CBD6B | 5BAB46 | A37146 |

The foliage and dry foliage columns are raw colormap lookups. A biome `foliage_color` or `dry_foliage_color` replaces them (section 3.2): the shipped swamp uses foliage `6A7039` and dry foliage `7B5334`, and the dark forest uses dry foliage `7B5334`, so do not use the colormap value 45B421 for the swamp (the mangrove swamp also overrides foliage with `8DB127`).

| # | Case | Expected |
|---|---|---|
| V1 | Dark forest grass at the forest climate: base 79C05A | (0x79C05A AND 0xFEFEFE) = 78C05A; + 28340A = A0F464; >> 1 = 507A32; result `FF507A32` |
| V2 | Swamp grass, noise value -0.3 at the column | `FF4C763C`; a float noise value of -0.1f (widens to about -0.10000000149) is below the double -0.1 and also gives `FF4C763C`; a float of -0.09f or above gives `FF6A7039` (strict comparison of the widened float with the double -0.1) |
| V3 | Radius 1 water blend: 6 of the 9 columns plains (`3F76E4` = 63, 118, 228) and 3 swamp (`617B64` = 97, 123, 100) | sums 669, 1077, 1668; divided by 9: 74, 119, 185; result `FF4A77B9` |
| V4 | Radius 0 water in plains | `3F76E4` exactly as in the biome (opaque because the hex string form made it so) |
| V5 | Stem age 3 | `FF60E70C`; attached stem `FFE0C71C` |
| V6 | Redstone power 15, power 0 | `FFFF3200`, `FF4C0000` |
| V7 | Tall grass upper half at (10, 65, 10) | grass colour at (10, 64, 10) |
| V8 | A face with `tintindex` 1 on `oak_leaves` | no source at index 1: colour -1, untinted |
| V9 | `pink_petals` face with `tintindex` 0 and 1 | index 0 untinted, index 1 biome grass colour |
| V10 | Break particle of a grass block | 0.6, 0.6, 0.6 times white = 0.6 grey |
| V11 | Break particle of a water block in a biome with water `3F76E4` | 0.6 x (63, 118, 228) / 255 per channel |
| V12 | Leather boots undyed in hand | item tint layer 0 = dye default `FFA06540`; dyed with one red dye: `dyed_color` B02E26 becomes `FFB02E26` |
| V13 | Water bottle (potion contents without effects) | `FF385DC6` |
| V14 | Firework star with colours `FF0000` and `0000FF` | mean (127, 0, 127) = `FF7F007F`; with none: `FF8A8A8A` |
| V15 | Wolf armour item, undyed / dyed with `dyed_color` B02E26 | undyed: the plain model, no tints at all; dyed: the `wolf_armor_dyed` model, layer 0 `FFFFFFFF` (constant -1), layer 1 `FFB02E26` |
| V16 | Map pixel `NONE` / base 7 `PLANT` at HIGH | transparent / packed 7 x 4 + 2 = 30, colour `FF007C00` (modifier 255) |
| V17 | `biomeBlendRadius` 7 | box 15 x 15 = 225 columns, divisor 225 |

---

## 12. Reconciliation with earlier documents

| Document | Statement | Status |
|---|---|---|
| 24-1 §9.1 | cells "not read" for in-hand colour of `sugarCane`, `dryFoliage`, `water`, `redstone`, `stem`; terrain particle colours | filled by section 2 (in-hand `FFFFFFFF` for sugar cane and water; dry foliage `FF5C3C32`; the terrain particle colour defaults to the in-world colour except `grassBlock` and `waterParticles`) |
| 24-1 §9.2 | "blend radius and cache belong to RS25" | section 4 |
| 24-1 §9.3 | block to source table | agrees with section 2.1 (read again) |
| 14 §9 | lookup formula, defaults | agrees (section 3.1), and adds the biome-level rules (3.2) |
| 14 Open question 7 | "which source the shipped item definitions use for the grass block icon" | grass source with temperature 0.5 and downfall 1.0 (7.1) |
| 08 §6.4 | tint source type list | agrees; fields and results in section 7 |
| 12 §3.1 | defaults of fog, water fog and sky | agrees; the biome fields that set them are in section 5 |
| 12 Open question 8 (biome colour tinting not covered) | | covered here |

---

## Open questions

1. Resolved: the redstone colour table (2.2) was re-derived independently for all 16 rows with single-precision steps and `ARGB.as8BitChannel` (floor of value x 255); every row matches, including 13 = EA0600, 14 = F41B00 and 15 = FF3200. It remains an arithmetic derivation, not a run of the client; a reference screenshot would only confirm it.
2. Tie order for map colours: the counts are held in an insertion-ordered multiset and then sorted highest count first (read, 6.2), and the insertion order follows the dx-outer, dz-inner scan (read). That equal counts keep their insertion order through `Multisets.copyHighestCountFirst` is a property of the Guava library, which is not in the client jar and was not read (recalled, not verified).
3. The worn-armour dyeable rule (7.2) was read in `EquipmentLayerRenderer` (`renderLayers`, `getColorForLayer`). The mapping function of the `color_when_undyed` Optional is `ARGB.opaque` (read, 7.2). Not inspected: the trim and glint branches of the same method.
4. Banner (6.1): the draw order and the diffuse tint of the base-pattern layer and pattern layers were read in `BannerRenderer`. Not read: the texture files behind `Sheets.BANNER_BASE`, `BANNER_PATTERN_BASE` and `SHIELD_PATTERN_BASE`, the shield and banner item special renderers (they were searched only through the shared `submitPatterns`), and the crumbling-overlay branch of `submitBanner`.
5. The block-entity and entity colour users of `DyeColor` were located but not specified here. Callers of `DyeColor.getTextureDiffuseColor` in the jar: `ColorLerper`, `TropicalFishRenderer`, `BannerRenderer` (6.1), `TheEndGatewayRenderer`, `DyedItemColor` (7.4), `WolfCollarLayer`, `CatCollarLayer`, `LoomScreen` and `BeaconBlockEntity`. `ColorLerper` is also used by `SheepRenderState` and `NowPlayingToast`. Callers of `getFireworkColor`: `FireworkParticles$Starter`, `FireworkStarRecipe`, `FireworkStarFadeRecipe`, `CelebrateVillagersSurvivedRaid`. Of these only banner and dye mixing are specified here. Item definitions with `tints` total 26 files, all covered in 7.1.
6. Which callers invoke `ClientLevel.clearTintCaches` (resource reload, option change, dimension change) was not traced; only that the blend option change calls a level-extractor operation and presets exist (section 4).
7. (Still untraced: the item model layer code was not read for this round; the block-side rule, index at or beyond the list size gives -1, is verified in `ModelBlockRenderer.computeTintColor`, section 1 item 2.) How the item layer index relates to `tints[i]` when the model has more layers than tints (08 §5.8 says layer n uses tint index n; the overflow behaviour was not read).
8. The environment attribute blend (Gaussian) of 12 §3.1 was not re-read here; this document only separates it from the box average of the block tints.
9. Resolved: `NativeImage.getPixel` and `setPixel` convert through `ARGB.fromABGR` and `ARGB.toABGR` (`getPixelABGR` and `setPixelABGR` are the raw forms), so the API is ARGB and storage is ABGR. `MapTextureManager$MapInstance` calls `setPixel` with `MapColor.getColorFromPackedId` (ARGB). `MapColor.calculateARGBColor` is `ARGB.scaleRGB(ARGB.opaque(col), modifier)`, and `scaleRGB(int, int)` computes channel x modifier / 255 with a 64-bit multiply and truncating division, then clamps to 0..255, matching the integer-division statement in 6.2.
10. Falling-leaves and other particle tints beyond index 0 of the block (section 2.4) were read only for the terrain and falling-dust particles and `getClientLeafTintColor`.
11. The hex string codecs accept only `#RRGGBB`; whether lower-case hex digits and a missing `#` are rejected beyond the message "Hex color must begin with #" was not read in full.
12. `ClientLevel.getUncachedNoiseBiome` returns the `Biomes.PLAINS` holder of the biome registry (read); `calculateBlockTint` confirms r = 0 (one resolver call, no averaging) and r > 0 (`Cursor3D` with equal min and max y, per-channel sums, integer division by (2r + 1)^2, opaque `ARGB.color`); `Options.biomeBlendRadius` is an IntRange 0..7, default 2. Not traced: when the uncached path is taken versus the stored cell of the chunk.
13. Resolved in 6.2 (decrement-first sink walk). Residual: the legacy fluid block state and `getCorrectStateForFluidBlock` were read only for the fluid-and-not-up-face-sturdy test; the map colour of each fluid's legacy block state is not tabulated here (24).
