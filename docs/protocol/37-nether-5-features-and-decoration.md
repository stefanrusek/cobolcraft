# 37 The Nether, part 5: features and decoration

| Item | Value |
|---|---|
| Covers | How the five Nether biomes are decorated: the per-biome, per-step list of placed features, the placement-modifier chain of every Nether placed feature, the configured feature each one runs, the global order the sorter gives them in the Nether (with the feature index and the random seed of each), what the shared engines do in a 128-block-high roofed dimension, the `nether_fossil` structure hook (position search, template choice, the dried ghast), and the Nether ore targets and tags. |
| Does not cover | The engines themselves. Placement modifiers, `scattered_ore`, `ore`, `random_neighbor_spread`, `block_column`, `simple_block`, `spring_feature`, `huge_fungus`, `delta_feature`, `stepped_column_cluster`, `overlay`, `netherrack_replace_blobs` are specified in documents 35-1 to 35-7 and are cross-referenced, not repeated. The data rows (JSON under `worldgen/` and `tags/`) are copied by the extraction tool (22, 23): this document shows only the wiring needed to apply the engines. Noise, biome parameters, surface rules and carvers (siblings 37 parts 1 to 4), fortress and bastion structures (sibling 37 part 6). `ruined_portal_nether` (structure set `ruined_portals`, random_spread spacing 40, separation 15, salt 34222645; one of 7 equally weighted structures, weight 1 each; step `surface_structures`) is a structure hook not specified here (Open question 4). The planted-fungus features `crimson_fungus_planted`, `warped_fungus_planted` (`huge_fungus` with `planted true`) and `nylium_bonemeal` exist in the data but are placed by no biome; they are invoked by bone meal and fungus growth and belong to 29b (fungi section), not to the seed table here. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `FeatureSorter`, `Graph`, `BiomeSource`, `MultiNoiseBiomeSourceParameterList$Preset$1`, `GenerationStep$Decoration`, `WorldGenerationContext`, `NoiseBasedChunkGenerator`, `NetherFossilStructure`, `NetherFossilPieces` (and its piece class), `SingleThreadedRandomSource`, `RandomSource`, `Rotation`, `Util`; and of the JSON under `data/minecraft/worldgen/{biome,placed_feature,feature,structure,structure_set,noise_settings,multi_noise_biome_source_parameter_list}`, `data/minecraft/tags/block`, `data/minecraft/dimension_type/the_nether.json` and the 14 files `data/minecraft/structure/nether_fossils/*.nbt` (parsed with a throwaway reader written for the round). No execution of the artifact. Values marked "(computed)" come from applying the text of section 3 with a throwaway script; they were not observed from the artifact. |
| Round | RS21 (GAP-13a of [../design/README.md](../design/README.md)), scope "Part 5" |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies engines and wiring (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"). |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not verified)" marks
something not read; both are listed in the Open questions. "11 section n" is [11-world-generation-caves-and-ores.md](11-world-generation-caves-and-ores.md),
"10 section n" is [10-world-generation-terrain.md](10-world-generation-terrain.md), "35-n section m" is part n of
[35-worldgen-features-1-model-and-placement.md](35-worldgen-features-1-model-and-placement.md) (and its siblings 35-2 to 35-7 in the same directory).

---

## 1. Read first: what is different in 26.3, and what the Nether data contains

1. **There are no Nether-only feature classes beyond those of 35.** Glowstone clusters are `random_neighbor_spread` (35-4 section 7.3), weeping vines are an `overlay` of
   `random_neighbor_spread` and `block_column` (35-4 section 11.6), twisting vines are a `block_column`, the Nether forest vegetation, nether sprouts, roots and fire
   are `simple_block` (35-4 section 4), the springs are `spring_feature` (35-5 section 4), the ores are `ore` and `scattered_ore` (11, 35-1 section 13), and
   the basalt features are `delta_feature`, `stepped_column_cluster`, `overlay`, `single_block_pillar`, `projected_random_patchy_square`, `netherrack_replace_blobs`
   (35-7). Only `huge_fungus` (35-4 section 11.5) is specific to the Nether and it is specified there. There is no `GlowstoneBlobFeature`,
   `NetherForestVegetationFeature`, `WeepingVinesFeature` or `TwistingVinesFeature` feature type in this artifact (the 58 feature types are listed in 35-7 section 12.1).
2. **The Nether noise settings** (`noise_settings/nether.json`, read for what the decoration needs): `noise.min_y 0`, `noise.height 128`, `sea_level 32`, `default_block netherrack`,
   `default_fluid lava`, `legacy_random_source true`. The dimension type `the_nether.json` has `min_y 0`, `height 256`, `logical_height 128`, `has_ceiling true`, `has_skylight false`, `coordinate_scale 8.0`.
3. **Generation context for height anchors.** `WorldGenerationContext` takes `minY = max(level minY, generator minY)` and `depth = min(level height, generator getGenDepth)` and the noise
   generator's `getGenDepth` is `noise.height`. So in the Nether `minY = 0`, `depth = min(256, 128) = 128`, sea level 32 (35-1 section 8.3). Anchors (`above_bottom n` = `minY + n`,
   `below_top n` = `minY + depth - 1 - n`): `above_bottom 4` is y 4, `below_top 4` is y 123, `above_bottom 10` is y 10, `below_top 10` is y 117, `below_top 0` is y 127, `below_top 8` is y 119.
   The build range of the dimension (256 tall) is taller than the generated range: a feature that reads or writes above y 127 sees air.
4. **Decoration steps in the Nether.** Four biome `features` arrays have **10** lists (steps 0 to 9) and `basalt_deltas` has **8** (steps 0 to 7, read as list lengths; it has no step 8 and no step 9 list). Step 10 `TOP_LAYER_MODIFICATION` has no list in any biome, and 35-1 section 6 runs `max(11, size)` steps so
   step 10 still runs structures only). Of the 11 steps only these have features in any Nether biome: step 2 `LOCAL_MODIFICATIONS` (soul sand valley), step 4 `SURFACE_STRUCTURES` (basalt deltas),
   step 7 `UNDERGROUND_DECORATION` (almost everything), step 9 `VEGETAL_DECORATION`. The ores of the Nether are in step 7, not in step 6. Steps 0, 1, 3, 5, 6 are empty lists in all five biomes; step 8 is an empty list in the four biomes that have one and absent in `basalt_deltas`. The structures that share these steps (read from `structure/*.json`): `fortress` and `nether_fossil` are in step 7 (`underground_decoration`); `bastion_remnant` and `ruined_portal_nether` are in step 4 (`surface_structures`). In step 4 the structure reseed `decorationSeed + n + 10000 * 4` therefore collides with the `delta` feature indices 0 to 2 in the same way as the fossil collides in step 7 (section 3; Open question 4).
5. **`spring_lava` in the Nether biomes (observation).** Four biomes (`nether_wastes`, `soul_sand_valley`, `crimson_forest`, `warped_forest`) list the placed feature `spring_lava` (the overworld one: `spring_lava_overworld`, count 20, y `very_biased_to_bottom` between
   above_bottom 0 and below_top 8) in **step 9**, not in step 8; `basalt_deltas` has no step 9 list and so no `spring_lava`. Its `valid_blocks` are stone, granite, diorite, andesite, deepslate, tuff, calcite and dirt (35-5 section 4), none of which is generated in the
   Nether by terrain, so on ordinary Nether terrain it places nothing; it still occupies a feature index and a seed (section 3). It is listed in the data, so it is kept.
6. Count (read with `unzip -Z1 ... | grep -v '/$'`): `structure/nether_fossils/` holds 14 files.

## 2. Per-biome decoration lists (as read from `worldgen/biome/*.json`)

The lists are in source order; the order within a step matters only for the sorter (section 3). Step numbers as 11 section 6.2. A dash means an empty list.

| Step | `nether_wastes` | `soul_sand_valley` | `crimson_forest` | `warped_forest` | `basalt_deltas` |
|---|---|---|---|---|---|
| 2 | - | `basalt_pillar` | - | - | - |
| 4 | - | - | - | - | `delta`, `small_basalt_columns`, `large_basalt_columns` |
| 7 | `spring_open`, `patch_fire`, `patch_soul_fire`, `glowstone_extra`, `glowstone`, `brown_mushroom_nether`, `red_mushroom_nether`, `ore_magma`, `spring_closed`, `ore_gravel_nether`, `ore_blackstone`, `ore_gold_nether`, `ore_quartz_nether`, `ore_ancient_debris_large`, `ore_debris_small` | `spring_open`, `patch_fire`, `patch_soul_fire`, `glowstone_extra`, `glowstone`, `patch_crimson_roots`, `ore_magma`, `spring_closed`, `ore_soul_sand`, `ore_gravel_nether`, `ore_blackstone`, `ore_gold_nether`, `ore_quartz_nether`, `ore_ancient_debris_large`, `ore_debris_small` | `spring_open`, `patch_fire`, `glowstone_extra`, `glowstone`, `ore_magma`, `spring_closed`, `ore_gravel_nether`, `ore_blackstone`, `ore_gold_nether`, `ore_quartz_nether`, `ore_ancient_debris_large`, `ore_debris_small` | `spring_open`, `patch_fire`, `patch_soul_fire`, `glowstone_extra`, `glowstone`, `ore_magma`, `spring_closed`, `ore_gravel_nether`, `ore_blackstone`, `ore_gold_nether`, `ore_quartz_nether`, `ore_ancient_debris_large`, `ore_debris_small` | `basalt_blobs`, `blackstone_blobs`, `spring_delta`, `patch_fire`, `patch_soul_fire`, `glowstone_extra`, `glowstone`, `brown_mushroom_nether`, `red_mushroom_nether`, `ore_magma`, `spring_closed_double`, `ore_gold_deltas`, `ore_quartz_deltas`, `ore_ancient_debris_large`, `ore_debris_small` |
| 9 | `spring_lava`, `brown_mushroom_normal`, `red_mushroom_normal` | `spring_lava` | `spring_lava`, `brown_mushroom_normal`, `red_mushroom_normal`, `weeping_vines`, `crimson_fungi`, `crimson_forest_vegetation` | `spring_lava`, `brown_mushroom_normal`, `red_mushroom_normal`, `warped_fungi`, `warped_forest_vegetation`, `nether_sprouts`, `twisting_vines` | - |

Carvers: every Nether biome lists the single carver `nether_cave` (sibling part 4). Every Nether biome has temperature 2.0, downfall 0.0, no precipitation (10 section 7 for climate use).

Differences between biomes that a decoration implementer needs: only soul sand valley has `ore_soul_sand`, `basalt_pillar` and `patch_crimson_roots` (no other biome lists it); the two
fungal forests lack the nether mushrooms (`brown/red_mushroom_nether`) but keep the `normal` mushrooms of step 9; crimson forest lacks `patch_soul_fire`; basalt deltas replaces the
open spring with `spring_delta`, doubles the closed springs (`spring_closed_double`), doubles gold and quartz (`ore_gold_deltas`, `ore_quartz_deltas`), and has no `spring_open` and no `ore_gravel_nether`, `ore_blackstone`.

## 3. Global order, feature indices and seeds in the Nether

The order is produced exactly as 11 section 6.2 describes (`FeatureSorter.buildFeaturesPerStep`); this section records what was confirmed in the bytecode for the Nether and the result.

**Confirmed from the artifact:**
1. The biome list is `possibleBiomes()`, which is `collectPossibleBiomes()` with `distinct()` collected through Guava `ImmutableSet`, so it keeps first-encounter order (this closes the "inferred" of 11 section 6.2 for this dimension).
2. The Nether biome source is the multi-noise preset `minecraft:nether` (`multi_noise_biome_source_parameter_list/nether.json` is `{"preset": "minecraft:nether"}`), whose parameter list (read from `MultiNoiseBiomeSourceParameterList$Preset$1`) is, in order, with parameter order temperature, humidity, continentalness, erosion, depth, weirdness, offset:
   `nether_wastes` (0, 0, 0, 0, 0, 0, 0); `soul_sand_valley` (0, -0.5, 0, 0, 0, 0, 0); `crimson_forest` (0.4, 0, 0, 0, 0, 0, 0); `warped_forest` (0, 0.5, 0, 0, 0, 0, 0.375); `basalt_deltas` (-0.5, 0, 0, 0, 0, 0, 0.175).
   So the biome order for numbering is **nether_wastes, soul_sand_valley, crimson_forest, warped_forest, basalt_deltas**.
3. `FeatureData` is `(featureIndex, step, feature)`; the comparator is `step` first, then `featureIndex`. The `featureIndex` is assigned from one counter in first-appearance order over all biomes, each biome's steps in order and each step's features in order; identity is the placed-feature object, so two placed features with equal content but different names (for example `glowstone_extra` and `glowstone`) are different features.
4. Edges are built from a **flat per-biome list across steps** (the entries of step 0, then step 1, and so on), an edge from each entry to the next one in that flat list, including from the last entry of one step to the first of the next non-empty step. 11 section 6.2 says "each step"; the flat form is what the code does. For the five Nether biomes both readings give the same result (checked, computed).
5. The depth-first search starts from every node in ascending (step, index) order, visits successors in ascending order, emits a node after its successors, and the emitted list is reversed. A cycle raises an error (there is none in these five biomes).

**Result (computed).** Per-step list, its `featureIndex` within the step (the `index` of 35-1 section 5.1 item 2), the seed offset `index + 10000 * step` that is added to `decorationSeed`, and which biomes carry it (W nether_wastes, S soul_sand_valley, C crimson_forest, P warped_forest, D basalt_deltas). The position in the first-appearance numbering is not needed at run time.

| Step | Index | Placed feature | Seed offset | Biomes |
|---|---|---|---|---|
| 2 | 0 | `basalt_pillar` | 20000 | S |
| 4 | 0 | `delta` | 40000 | D |
| 4 | 1 | `small_basalt_columns` | 40001 | D |
| 4 | 2 | `large_basalt_columns` | 40002 | D |
| 7 | 0 | `basalt_blobs` | 70000 | D |
| 7 | 1 | `blackstone_blobs` | 70001 | D |
| 7 | 2 | `spring_delta` | 70002 | D |
| 7 | 3 | `spring_open` | 70003 | W S C P |
| 7 | 4 | `patch_fire` | 70004 | W S C P D |
| 7 | 5 | `patch_soul_fire` | 70005 | W S P D |
| 7 | 6 | `glowstone_extra` | 70006 | W S C P D |
| 7 | 7 | `glowstone` | 70007 | W S C P D |
| 7 | 8 | `patch_crimson_roots` | 70008 | S |
| 7 | 9 | `brown_mushroom_nether` | 70009 | W D |
| 7 | 10 | `red_mushroom_nether` | 70010 | W D |
| 7 | 11 | `ore_magma` | 70011 | W S C P D |
| 7 | 12 | `spring_closed_double` | 70012 | D |
| 7 | 13 | `ore_gold_deltas` | 70013 | D |
| 7 | 14 | `ore_quartz_deltas` | 70014 | D |
| 7 | 15 | `spring_closed` | 70015 | W S C P |
| 7 | 16 | `ore_soul_sand` | 70016 | S |
| 7 | 17 | `ore_gravel_nether` | 70017 | W S C P |
| 7 | 18 | `ore_blackstone` | 70018 | W S C P |
| 7 | 19 | `ore_gold_nether` | 70019 | W S C P |
| 7 | 20 | `ore_quartz_nether` | 70020 | W S C P |
| 7 | 21 | `ore_ancient_debris_large` | 70021 | W S C P D |
| 7 | 22 | `ore_debris_small` | 70022 | W S C P D |
| 9 | 0 | `spring_lava` | 90000 | W S C P |
| 9 | 1 | `brown_mushroom_normal` | 90001 | W C P |
| 9 | 2 | `red_mushroom_normal` | 90002 | W C P |
| 9 | 3 | `warped_fungi` | 90003 | P |
| 9 | 4 | `warped_forest_vegetation` | 90004 | P |
| 9 | 5 | `nether_sprouts` | 90005 | P |
| 9 | 6 | `twisting_vines` | 90006 | P |
| 9 | 7 | `weeping_vines` | 90007 | C |
| 9 | 8 | `crimson_fungi` | 90008 | C |
| 9 | 9 | `crimson_forest_vegetation` | 90009 | C |

At run time the decoration seed of chunk (cx, cz) is `decorationSeed = setDecorationSeed(worldSeed, 16 cx, 16 cz)` (35-1 section 5.1) and the random is re-seeded to `decorationSeed + offset` before each placed feature. The Nether chunk generator uses `legacy_random_source true` for terrain; the decoration random is the Xoroshiro-backed `WorldgenRandom` of 11 section 6.1 in every dimension (35-1 section 5.1). Read: `ChunkGenerator.applyBiomeDecoration` always builds the decoration `WorldgenRandom` over a `XoroshiroRandomSource` and then calls `setDecorationSeed` and `setFeatureSeed`, with no reference to the noise-settings `legacy_random_source` flag, so the flag has no effect on decoration.

A chunk uses only the features of the biomes present in its 3 x 3 neighbourhood, but the indices above do not change (they come from the whole biome set). Structures of a step run before the features of that step and reseed with `decorationSeed + n + 10000 * step` for the n-th structure of the step (35-1 section 5.1 item 3); the `nether_fossil` structure is in step 7 (section 6), so its n collides with the feature index n of the same step when equal (Open question 4: n is a sibling-part fact). The same holds in step 4 for `bastion_remnant` and `ruined_portal_nether` against the `delta` indices 0 to 2.

**Worked example (computed).** Basalt deltas chunk, world seed S: `ore_magma` runs with seed `decorationSeed + 70011`; `delta` with `decorationSeed + 40000`; in a crimson-forest-only neighbourhood the features that run, in order, are step 7 indices 3, 4, 6, 7, 11, 15, 17, 18, 19, 20, 21, 22, then step 9 indices 0, 1, 2, 7, 8, 9 (`spring_open`, `patch_fire`, `glowstone_extra`, `glowstone`, `ore_magma`, `spring_closed`, `ore_gravel_nether`, `ore_blackstone`, `ore_gold_nether`, `ore_quartz_nether`, `ore_ancient_debris_large`, `ore_debris_small`, `spring_lava`, the two normal mushrooms, `weeping_vines`, `crimson_fungi`, `crimson_forest_vegetation`).

## 4. Placed features: modifier chains and what they run

Modifier semantics are in 35-1 section 7 (count, in_square, biome, block_predicate_filter, rarity_filter, count_on_every_layer, environment_scan, heightmap, height_range, offset). Abbreviations used below: **sq** = `in_square`; **bio** = `biome`; **air** = block tag `minecraft:air` (air, void_air, cave_air); **patch idiom P** = `count 96`, then `offset` x trapezoid -7..7 plateau 0, y trapezoid -3..3 plateau 0, z trapezoid -7..7 plateau 0 (trapezoid draws: 35-4 section 2.2), then a `block_predicate_filter` (given per feature). **Whole column** = `height_range uniform above_bottom 0 .. below_top 0` = y 0..127 here.
`uniform(a, b)` is inclusive. A modifier chain is applied left to right, depth first per position (11 section 6.4).

### 4.1 Fire, mushrooms, roots, sprouts (patches)

| Placed feature | Modifier chain | Configured feature |
|---|---|---|
| `patch_fire` | `count uniform 0..5`, sq, `height_range uniform above_bottom 4 .. below_top 4` (y 4..123), bio, P with filter (air at the cell AND `netherrack` at offset (0,-1,0)) | `simple_block` fire, state `age 0`, all of east/north/south/west/up false (read in `feature/patch_fire.json`) |
| `patch_soul_fire` | same as `patch_fire` but the filter requires `soul_soil` below | `simple_block` `soul_fire` |
| `brown_mushroom_nether` | `rarity_filter 2`, sq, whole column, bio, P with filter air | `brown_mushroom` (a `simple_block`/random patch config of 35-4; the data file `feature/brown_mushroom.json` is the extracted data) |
| `red_mushroom_nether` | as `brown_mushroom_nether` | `red_mushroom` |
| `patch_crimson_roots` | whole column (no count, no sq), bio, P with filter air | `simple_block` `crimson_roots` |
| `nether_sprouts` | `count_on_every_layer 4`, bio, filter (`#nylium` at offset (0,-1,0)), `count 64`, offset trapezoids as in P but x/z -7..7 and y -3..3, filter air | `simple_block` `nether_sprouts` |
| `crimson_forest_vegetation` | `count_on_every_layer 6`, bio, filter (nylium below), `count 64`, the same offset, filter air | `simple_block` with a `weighted` provider: `crimson_roots` 87, `crimson_fungus` (the plant block) 11, `warped_fungus` (the plant block) 1 |
| `warped_forest_vegetation` | as above with `count_on_every_layer 5` | `simple_block` weighted: `warped_roots` 85, `crimson_roots` 1, `warped_fungus` 13, `crimson_fungus` 1 |
| `brown_mushroom_normal` | `rarity_filter 256`, sq, `heightmap MOTION_BLOCKING`, bio, P with filter air | `brown_mushroom` |
| `red_mushroom_normal` | `rarity_filter 512`, sq, `heightmap MOTION_BLOCKING`, bio, P with filter air | `red_mushroom` |

`#nylium` is the block tag `minecraft:nylium` = {`crimson_nylium`, `warped_nylium`}. `brown_mushroom` and `red_mushroom` are plain `simple_block` configured features whose `to_place` is the mushroom block (read from `feature/brown_mushroom.json`, `feature/red_mushroom.json`); they are not a random patch config. The patch idiom draws, per attempt: x trapezoid, y trapezoid, z trapezoid (35-4 section 2.1). The `normal` mushrooms use the surface heightmap, which in the Nether (a bedrock roof at y 127) lies at the top of the roof, so the cell it checks is air above the roof (y 128); the offset y -3..3 puts attempts at 125..131 and the air filter passes only above the roof.

**Survival test (read).** `simple_block` calls the state's `canSurvive` before it places anything (the call precedes the `setBlock` in `SimpleBlockFeature.place`). For a mushroom, `MushroomBlock.canSurvive` reads the block directly below: (1) if it is in the block tag `overrides_mushroom_light_requirement` = {`mycelium`, `podzol`, `crimson_nylium`, `warped_nylium`} the mushroom survives; (2) otherwise it survives only when the raw brightness at the cell (called with sky darkening 0) is below 13 and the block below satisfies `mayPlaceOn`, which is "the block below renders as a solid full block". So a roof attempt places a mushroom on the bedrock exactly when the raw brightness of the air cell at y 128 is below 13 (bedrock is not in the tag; whether bedrock counts as solid-render and the light value above a roof in a dimension without skylight were not followed: Open question 1). The feature does perform a support check; it is the one above, not none.

### 4.2 Fungi, vines, glowstone

| Placed feature | Modifier chain | Configured feature |
|---|---|---|
| `crimson_fungi` | `count_on_every_layer 8`, bio | `huge_fungus` crimson (35-4 section 11.5; base `crimson_nylium`, stem `crimson_stem`, hat `nether_wart_block`, decor `shroomlight`, `planted` false) |
| `warped_fungi` | `count_on_every_layer 8`, bio | `huge_fungus` warped (base `warped_nylium`, stem `warped_stem`, hat `warped_wart_block`, decor `shroomlight`) |
| `weeping_vines` | `count 10`, sq, whole column, bio, filter (air at the cell AND `netherrack` or `nether_wart_block` at (0,1,0)) | `overlay` of `random_neighbor_spread` (nether wart block, `accepted_neighbors` {`netherrack`, `nether_wart_block`}, `can_replace` air, `attempts 200`, xz trapezoid -5..5, y trapezoid -4..1 plateau 3; it has no placement modifiers of its own) and a `block_column` (direction down) placed `count 100` with offset (x,z trapezoid -7..7, y trapezoid -4..1 plateau 3) and the same filter (the placed feature's own modifier chain and the inner `block_column` chain carry the identical air-and-above filter; the offset-above (0,1,0) test is in both). Column layer heights and the tip age 17..25 are left to 35-4 section 11.6 |
| `twisting_vines` | `count 10`, sq, whole column, bio, filter (air and `netherrack`/`warped_nylium`/`warped_wart_block` below), `count 64`, offset x uniform -8..8, y uniform -4..4, z uniform -8..8, offset (0,-1,0), `environment_scan` (down, 32 steps, target "not air"), offset (0,1,0), the same filter | `block_column` direction up (35-4 section 11.6) |
| `glowstone_extra` | `count biased_to_bottom 0..9`, sq, `height_range uniform above_bottom 4 .. below_top 4`, filter (air at the cell AND `netherrack`, `basalt` or `blackstone` at (0,1,0)), bio | `random_neighbor_spread`: block `glowstone`, accepted neighbour `glowstone`, `attempts 1500`, xz offset trapezoid -7..7 plateau 0, y offset uniform -11..0, can replace air (35-4 section 7.3) |
| `glowstone` | `count 10`, sq, whole column (above_bottom 0 to below_top 0), filter as above, bio | the same configured feature `glowstone_extra` |

The two glowstone placed features differ only in count and height range: `glowstone_extra` is thinly spread (the count is a biased-to-bottom draw over 0..9, whose expected value was not computed here (inferred to be below the unbiased mean; distribution in 35-1 section 10)) between y 4 and y 123, `glowstone` is ten attempts anywhere in the column. Both start a cluster only where the origin is air with a netherrack, basalt or blackstone ceiling, set the origin to glowstone unconditionally, and grow by 1500 random attempts, each placing a glowstone block in air that touches **exactly one** existing glowstone block. The growth is therefore a hanging, branching blob below the ceiling and never fills solid holes. Note that nothing in the chain requires the origin to be the ceiling of a *cave*: any air cell under netherrack, basalt or blackstone qualifies, including the cell under the roof.

### 4.3 Ores, springs

| Placed feature | Modifier chain | Configured feature |
|---|---|---|
| `ore_magma` | `count 4`, sq, `height_range uniform absolute 27..36`, bio | `ore`, size 33, `magma_block` replacing `netherrack` (`block_match`), `discard_chance_on_air_exposure 0.0` |
| `ore_gravel_nether` | `count 2`, sq, `uniform absolute 5..41`, bio | `ore`, size 33, `gravel` replacing `netherrack` |
| `ore_blackstone` | `count 2`, sq, `uniform absolute 5..31`, bio | `ore`, size 33, `blackstone` replacing `netherrack` |
| `ore_soul_sand` | `count 12`, sq, `uniform above_bottom 0 .. absolute 31`, bio | `ore`, size 12, `soul_sand` replacing `netherrack` |
| `ore_gold_nether` | `count 10`, sq, `uniform above_bottom 10 .. below_top 10` (y 10..117), bio | `ore_nether_gold`: `ore`, size 10, `nether_gold_ore` replacing `netherrack` |
| `ore_gold_deltas` | as `ore_gold_nether` with `count 20` | `ore_nether_gold` |
| `ore_quartz_nether` | `count 16`, sq, y 10..117, bio | `ore_quartz`: `ore`, size 14, `nether_quartz_ore` replacing `netherrack` |
| `ore_quartz_deltas` | as `ore_quartz_nether` with `count 32` | `ore_quartz` |
| `ore_ancient_debris_large` | sq, `height_range trapezoid absolute 8..24` (no count: one attempt per chunk), bio | `scattered_ore`, size 3, `ancient_debris` replacing the tag `base_stone_nether`, `discard_chance_on_air_exposure 1.0` |
| `ore_debris_small` | sq, `uniform above_bottom 8 .. below_top 8` (y 8..119), bio | `scattered_ore`, size 2, `ancient_debris`, same tag, discard 1.0 |
| `spring_open` | `count 8`, sq, `uniform above_bottom 4 .. below_top 4` (y 4..123), bio | `spring_nether_open`: lava (falling), `valid_blocks netherrack`, `requires_block_below false`, default `rock_count 4`, `hole_count 1` |
| `spring_closed` | `count 16`, sq, `uniform above_bottom 10 .. below_top 10`, bio | `spring_nether_closed`: lava, netherrack, `requires_block_below false`, `rock_count 5`, `hole_count 0` |
| `spring_closed_double` | as `spring_closed` with `count 32` | `spring_nether_closed` |
| `spring_delta` | `count 16`, sq, y 4..123, bio | `spring_lava_nether`: lava, `valid_blocks` {netherrack, soul_sand, gravel, magma_block, blackstone}, defaults (`rock_count 4`, `hole_count 1`, below required) |

`ore` is the generic ore engine of 11 section 8 and `scattered_ore` that of 35-1 section 13. Nether ore targets are the single rule "block is netherrack" (all vein ores except ancient debris) and the tag `minecraft:base_stone_nether` = {`netherrack`, `basalt`, `blackstone`} (ancient debris; so debris can replace basalt and blackstone in the deltas and blackstone blobs). Because the vein ores match **only netherrack**, an ore vein does not replace basalt, blackstone, soul sand, gravel or magma already present: this matters in basalt deltas, where the step-4 `delta` and columns and the step-7 `basalt_blobs`/`blackstone_blobs` run before the ores (indices 0 and 1 of step 7, then ores at 11 and above), so the blobs have already turned netherrack into basalt or blackstone and the ores see less netherrack.

The y distribution `trapezoid absolute 8..24` of the large debris is, in 35-1 section 10, the triangular distribution on 8..24 with its peak at 16. The magma ore range 27..36 straddles the lava sea level (32).

### 4.4 Basalt, deltas and the soul-sand-valley pillar

| Placed feature | Modifier chain | Configured feature |
|---|---|---|
| `delta` | `count_on_every_layer 40`, bio | `delta_feature`: contents `lava`, rim `magma_block`, size uniform 3..7, rim size uniform 0..2 (35-7 section 3) |
| `small_basalt_columns` | `count_on_every_layer 4`, bio | `weighted_random_selector`: `stepped_column_cluster` with `cluster_reach 5`, `column_count 50`, `column_reach 1`, height uniform 1..4 (weight 9) or `cluster_reach 8`, `column_count 15`, `column_reach 1` (weight 1) |
| `large_basalt_columns` | `count_on_every_layer 2`, bio | the same selector with `column_reach uniform 2..3` and height uniform 5..10 (weights 9 and 1, the same two cluster shapes) |
| `basalt_blobs` | `count 75`, sq, whole column, bio | `netherrack_replace_blobs`, state `basalt`, target `netherrack`, radius uniform 3..7 |
| `blackstone_blobs` | `count 25`, sq, whole column, bio | the same with state `blackstone` |
| `basalt_pillar` | `count 10`, sq, whole column, filter (air at the cell AND not air at (0,1,0)), bio | `overlay` composition of `single_block_pillar` and the cap overlay (35-7 section 5.2) |

All columns use `basalt` with `axis y`; `can_replace` is "air, or lava at or below sea level (y <= 32 here)"; `continue_through` is `basalt`; `cannot_place_on` is the block tag `cannot_place_basalt_pillar_on` = {lava, bedrock, magma_block, soul_sand, nether_bricks, nether_brick_fence, nether_brick_stairs, nether_wart, chest, spawner}. The engines are in 35-7 sections 3 to 6; the `delta` placement loop and its geometry are 35-7 section 3.

`basalt_pillar` uses the filter "air with a non-air block above": it is a hanging pillar built **downward from a ceiling cell** (the origin is the air cell directly below a solid block); the data of the pillar block is in 35-7 section 5.

## 5. What the layer modifier does in the Nether

`count_on_every_layer` (35-1 section 7.11) finds, for each random column, "floors" of successive cave layers: a floor is a non-empty, non-bedrock block with an empty (air, water or lava) block above it. The scan starts at the heightmap value. In the Nether with its bedrock roof the first candidate (the roof) is bedrock and is never counted, so layer 0 in a column is the highest floor under the roof, layer 1 the next floor below, and so on. **Lava counts as empty**: the bottom of the lava sea (y below 32) is a floor, so layer numbers increase down to it, and so features like `delta` and fungi have attempts on the sea floor under lava as well (a fungus fails there, because the block below must be its nylium; basalt columns accept lava at or below sea level in `can_replace`).

Each layer re-draws `x` and `z` for every attempt, so with `count_on_every_layer 40` for `delta` each layer gives up to 40 attempts across the chunk; the loop ends at the first layer where no attempt found a floor.

**Worked example (computed).** One column with this layout: bedrock at 127, air 100..126, netherrack 95..99, lava 33..94, netherrack 32 and below. The scan starts at 128. The roof bedrock is never counted as a floor (bedrock is excluded). Layer 0: the netherrack at y 99 has air at y 100 above it, so it is a floor and the emitted y is 100 (the empty cell above the floor, as in the worked example of 35-1 section 7.11). The netherrack slab 95..99 has lava directly under it, so below y 95 the cells are empty (lava counts as empty) and the next floor is the netherrack at y 32 under the lava; layer 1 therefore emits y = 33.

## 6. The `nether_fossil` structure hook

The soul sand valley is the only biome of the tag `has_structure/nether_fossil`. The structure is generated in the `UNDERGROUND_DECORATION` step (7). It is not a feature; it is reached from the structure set `nether_fossils` and implemented by `NetherFossilStructure` and `NetherFossilPieces`.

**Placement (data).** `structure_set/nether_fossils`: `random_spread`, `spacing 2`, `separation 1`, `salt 14357921`, one structure, weight 1 (the placement engine is a sibling part and 10 section 7 does not cover it). `structure/nether_fossil`: `biomes #has_structure/nether_fossil`, `height uniform absolute 32 .. below_top 2`, `step underground_decoration`, `terrain_adaptation beard_thin`, no spawn overrides.

**Finding the generation point** (with the structure's own `WorldgenRandom`):
1. `x = chunk min x + nextInt(16)`; then `z = chunk min z + nextInt(16)`.
2. `seaLevel` = 32 (the generator's sea level). `y = height.sample(random, context)`: with `uniform 32 .. below_top 2` and the Nether's depth 128 that is a draw in 32..125.
3. Take the generator's base column at (x, z) (the blocks the noise terrain would give, no features). Scan downward from the sampled y, while y is above the sea level, for the highest air cell that sits directly on either a soul sand block or a block whose top face is sturdy when judged on an empty block getter. The scan stops at the first such pair.
4. If the final `y <= seaLevel`, there is no structure at this point. Otherwise the generation point is `(x, y, z)` where `y` is the y of the **solid block** that was found (the loop decrements before testing `below`).
5. The piece builder is called with that position.

**Pieces** (`NetherFossilPieces.addPieces`, with the structure random continuing the same stream): first `rotation = Rotation.getRandom(random)`, which is `nextInt(4)` indexing the enum values in order NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90 (read from the `$values` array, which has 4 entries); then the template is chosen by `Util.getRandom(array, random)` = `nextInt(14)` over `nether_fossils/fossil_1` to `fossil_14` (read in that order); one piece is added at the generation point with mirror NONE and the processor `BlockIgnoreProcessor.STRUCTURE_AND_AIR` (template air and structure-void blocks are skipped, so existing terrain shows through the template's air cells).

**Templates** (14 files, parsed): every one holds only `bone_block` and air (`axis` y or x in 13 files; `fossil_2` uses `axis` x and z, 5 blocks each, and no y), no soul sand, no entities, no block entities:

| File | Size (x, y, z) | Bone blocks | File | Size | Bone blocks |
|---|---|---|---|---|---|
| fossil_1 | 4, 4, 5 | 10 | fossil_8 | 3, 5, 1 | 6 |
| fossil_2 | 5, 1, 5 | 10 | fossil_9 | 3, 5, 5 | 15 |
| fossil_3 | 3, 4, 2 | 6 | fossil_10 | 3, 7, 1 | 8 |
| fossil_4 | 3, 4, 1 | 6 | fossil_11 | 5, 5, 7 | 24 |
| fossil_5 | 2, 5, 1 | 5 | fossil_12 | 4, 4, 3 | 11 |
| fossil_6 | 7, 5, 5 | 21 | fossil_13 | 4, 5, 6 | 17 |
| fossil_7 | 4, 6, 5 | 18 | fossil_14 | 7, 7, 6 | 26 |

The "soul sand and bone block" fossils of the scope are therefore bone blocks in the template, placed on soul sand or other sturdy ground by the search above. The template engine (placement, rotation about the piece position, processors, flags) is 35-6 sections 10.4 and 10.5.

**Post-processing.** Before it places the template and before the ghast step, the piece's post-process method calls `BoundingBox.encapsulate` on the chunk box it was given, with the template's placed bounding box. That method mutates the chunk box in place (min and max fields), so the `chunkBox` handed to both the template placement and the ghast step already includes the whole template box: the piece is **not** clipped to the chunk. The ghast step then runs on every chunk-piece placement call:
1. The random is built from the world seed: `SingleThreadedRandomSource(seed)` (the same linear congruential generator as `LegacyRandomSource`, 10 section 2.6), its `forkPositional()` (a legacy positional factory seeded with the first `nextLong()`), then `at(center)` where `center` is the centre block of the template's bounding box (10 section 2.4 for `at`, `getSeed`).
2. Draw `nextFloat()`; only when `< 0.5` continue.
3. `x = box.minX + nextInt(xSpan)`, `y = box.minY`, `z = box.minZ + nextInt(zSpan)` (draw order x then z) where the box is the template's placed bounding box.
4. If the block at (x, y, z) is air (the "inside `chunkBox`" test is always true because the position is drawn from the template box, which the chunk box now contains): set `dried_ghast` there with a random rotation (`Rotation.getRandom` of the same random, one `nextInt(4)`), flag 2.

Because the random depends only on world seed and the box centre, every chunk-piece placement call evaluates the same 50 % decision and the same position. The first call that finds air there places the ghast; a later call finds the ghast already in the cell and does nothing. No chunk is singled out as the one that contains the position.

**Worked example (computed).** A point (x, y) = (23, 60, 41), rotation index 1, template `fossil_2` (5 x 1 x 5): the piece is placed with its position at (23, 60, 41), rotated 90 degrees clockwise about it; the ghast, when the 50 % draw succeeds, goes at `y = minY` of the box (a layer of height 1 here), so it replaces an air cell on the bottom layer of the box.

## 7. Worked examples

1. **Heights.** `ore_ancient_debris_large`: one attempt per chunk, `y` triangular on 8..24 with its peak at 16; `ore_debris_small`: one attempt, `y` uniform 8..119; `scattered_ore` discards (chance 1.0) a block that touches air, so debris is hidden. Seed offsets: 70021 and 70022 (section 3).
2. **Spring open.** 8 attempts per chunk, y 4..123, each tests the spring rule of 35-5 section 4 with `valid_blocks` = netherrack: needs netherrack at (0,1,0), the target cell air or netherrack, and exactly 4 of the five lower/side neighbours netherrack and exactly 1 air (no below requirement). A lava source is written with flag 2 and a fluid tick scheduled.
3. **Spring closed.** 16 attempts per chunk (32 in basalt deltas), y 10..117, needs five netherrack neighbours (4 sides and below), no holes, and netherrack above: that replaces a fully enclosed netherrack block by a lava source with no opening.
4. **Weeping vines count.** One placed attempt is 10 positions (`count 10`) each doing up to 100 vine attempts after a spread of up to 200 attempts: draws per run are therefore a function of how many origins pass the filter; with the reseed per placed feature (section 3) the draw count of earlier features does not matter.
5. **Crimson-forest fungus**: `crimson_fungi` has `count_on_every_layer 8`: up to 8 origins per layer; each origin that sits on `crimson_nylium` runs the `huge_fungus` of 35-4 section 11.5. With `genDepth` 128 the check `origin.y + H + 1 >= 128` fails when the origin y is 100 and H is 27 or more (the largest `H` is `13 * 2 = 26`, so an origin at y 100 never fails; at y 110 an `H` of 17 or more fails).

## 8. Validation (checkable facts)

- `nether_wastes`, `soul_sand_valley`, `crimson_forest` and `warped_forest` have 10 feature lists and `basalt_deltas` has 8 (lengths 0,0,0,0,3,0,0,15). Lists 0, 1, 3, 5, 6 are empty in all five; list 8 is empty in the four biomes that have it and absent in `basalt_deltas`; list 9 is absent in `basalt_deltas`. Entries per biome: nether_wastes 15 + 3 = 18, soul_sand_valley 1 + 15 + 1 = 17, crimson_forest 12 + 6 = 18, warped_forest 13 + 7 = 20, basalt_deltas 3 + 15 = 18 (91 in all).
- The order table of section 3 has 1 entry in step 2, 3 in step 4, 23 in step 7 and 10 in step 9: 37 distinct placed features (the first-appearance counter ends at 36).
- Seed offsets of step 7 range from 70000 to 70022 and of step 9 from 90000 to 90009.
- `basalt_deltas` carries step 4 features and no other biome does; `soul_sand_valley` alone has step 2.
- `glowstone` and `glowstone_extra` are distinct placed features with the same configured feature and so take indices 7 and 6.
- Fossil templates: 14 files; total blocks per file = x * y * z (for example 4 * 4 * 5 = 80); bone-block counts as the table of section 6.
- Anchor values: with depth 128, `below_top 4` = 123, `below_top 10` = 117, `below_top 0` = 127.

## 9. Open questions

1. Section 4.1 reads the mushroom survival test (tag `overrides_mushroom_light_requirement`, else raw brightness below 13 and `mayPlaceOn` = solid render). **Prominent: an implementer cannot yet say whether the `normal` mushrooms ever place in the Nether.** Read in this round: `MushroomBlock.canSurvive` checks the tag `overrides_mushroom_light_requirement` (mycelium, podzol, crimson_nylium, warped_nylium), else raw brightness (sky darkening 0) below 13 and `mayPlaceOn`; `SimpleBlockFeature` calls `canSurvive` before `setBlock`. Not followed: the raw brightness value of the air cell above the Nether roof (y 128, dimension without skylight), whether bedrock is solid-render, and the `crimson_roots`/`warped_roots` survival rules. Whether the `normal` mushroom features place anything on the roof is therefore open (searched: the mushroom block class and tag, not the lighting engine for a skylight-less dimension with sky_light_level 4.0). The `crimson_roots`/`warped_roots` survival rules are marked (recalled, not verified) wherever stated.
2. Closed: the decoration random does not depend on `legacy_random_source` (section 3, read in `ChunkGenerator.applyBiomeDecoration`).
3. Survival and placement predicates of the plant blocks (`nether_sprouts`, roots, fungus blocks, mushrooms) when written by `simple_block` are owned by the block-update documents (29 section n) and were not re-read here.
4. The index `n` of `nether_fossil` among the structures of step 7 (for the structure reseed `decorationSeed + n + 10000 * 7`) depends on the Nether structure list and belongs to the structures sibling part. Read: `fortress` and `nether_fossil` are in step 7, `bastion_remnant` and `ruined_portal_nether` in step 4; the `nether_complexes` set (random_spread spacing 27, separation 4, salt 30084232, fortress weight 2, bastion remnant weight 3) was read as data only. The `ruined_portals` set (spacing 40, separation 15) and the planted-fungus features are cross-referenced in the Does-not-cover row. The numbering n within each step was not determined.
5. The random-spread structure placement for `nether_fossils` (spacing 2, separation 1, salt 14357921) was read as data only; its engine is outside this part.
6. The numeric draw counts of the `heightmap MOTION_BLOCKING` result on the Nether roof (section 4.1) and the effect of the generated height (128) versus the dimension height (256) on the heightmap were not traced at class level; section 5 follows 35-1 sections 4.2 and 7.11 as written.
7. The `Rotation` order is read (section 6); only the template rotation and mirror maths remain with 35-6. The `docs/protocol/README.md` Documents table does not yet list the `37-nether-*` documents; the orchestrator must add them (this file may not edit it).
8. The "expected count" remark for `biased_to_bottom 0..9` in section 4.2 was not computed; see 35-1 section 10 for the distribution.
9. The `beard_thin` terrain adaptation of the fossil structure (a density contribution of the structure to the noise) was read as a data field only; its density effect is a sibling-part (noise) matter.
10. The worked examples of sections 5 to 7 and the sums of section 8 were computed by hand or by script and not observed from the artifact.
11. Dimension-type behaviours seen in `the_nether.json` but outside this part (fast_lava, piglins_zombify false, respawn_anchor_works true, water_evaporates true, bed rules, snow_golem_melts, can_start_raid false, ambient_light 0.1, cardinal_light nether, fog 10/96, sky_light_level 4.0, monster_spawn_light_level 7) are not described in this part (section 1 item 2 lists only the extents); the sibling parts 37-1 to 37-4 and 37-6 are expected to cover them and this was not confirmed.
