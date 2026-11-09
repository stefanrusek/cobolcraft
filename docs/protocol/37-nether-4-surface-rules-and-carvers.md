# 37-4 The Nether: surface rules and carvers

| Item | Value |
|---|---|
| Covers | Part 4 of the Nether round (RS21, GAP-13a of [../design/README.md](../design/README.md)): the `minecraft:nether` material rule (the Nether surface rules) as a complete tree with the decisions it makes, the noises and conditions it uses, the bedrock floor and roof, the Nether cave carver (`minecraft:nether_cave`) with its configuration, seeding, draw order, geometry and application, the lava level of carved caves, and the Nether's place in the chunk generation order |
| Does not cover | Noise router and terrain fill (sibling 37-2), the biome list and climate preset (37-3), features (37-5, [35-worldgen-features-7-nether-end-misc.md](35-worldgen-features-7-nether-end-misc.md)), structures and spawns (37-6). The dimension type is in [37-nether-1-model-and-dimension-rules.md](37-nether-1-model-and-dimension-rules.md). The engines this part reuses are specified in [10-world-generation-terrain.md](10-world-generation-terrain.md) (material rule engine §10, random sources §2, stage order §11) and [11-world-generation-caves-and-ores.md](11-world-generation-caves-and-ores.md) (cave carver §5): this document gives only the Nether instances and the differences |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `NoiseBasedChunkGenerator`, `RandomState`, `MaterialSystem`, the `material/condition` classes, `CaveWorldCarver`, `WorldCarver`, `Carvers`, `WorldCarverTypes`, `Aquifer`, `NetherMaterialRules` (`net/minecraft/data/worldgen/material/`, the code-defined origin of `nether.json`), `LegacyRandomSource` and its positional factory, `VerticalAnchor`, `WorldGenerationContext`, and of the JSON under `data/minecraft/` in the jar (`worldgen/material_rule/nether.json`, `bedrock_floor.json`, `bedrock_roof.json`, `worldgen/carver/nether_cave.json`, `worldgen/noise_settings/nether.json` (it carries an extra `debug_functions` field with no effect on these rules; 37-2 documents it), `worldgen/noise/*.json`, `worldgen/biome/*.json`, `tags/block/uncarvable.json`), with no execution |
| Operator decisions | Standard Minecraft content is the target; the extraction tool supplies data rows (22, 23), and engines and code-defined content are specified completely (ticket CC-0001, Decisions "World scope", "Vanilla assets and data") |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction, "(recalled, not verified)" a statement not read this round; both are listed in the Open questions. "Worked examples (computed)" were calculated by applying the rules of this document and of 10 and 11 (including a small reference implementation of the Java LCG written for this round); they were not observed from a run of the artifact. Section references "NN section" are to documents in this directory.

---

## 1. Findings in one page, and where this artifact differs from what the round brief assumed

1. **There is no Nether-specific carver class.** `WorldCarverTypes` registers two carver types only, `cave` and `canyon`. `minecraft:nether_cave` is an instance of the same cave carver type as the overworld `minecraft:cave`, with different configuration numbers (section 6.1). Everything in 11 section 5.3 (the draw order, the tunnel walker, the room, the branches) therefore applies unchanged; this document supplies the Nether numbers and what they imply.
2. **There is no carve replaceable tag, no debug state and no "next to liquid" test in this version.** The classic carvers of 11 section 5 never had them here either: the only block test while applying a carving mask is membership in the block tag `minecraft:uncarvable` (the tag holds only `minecraft:bedrock`). The "carver replaceable blocks" tag, the "carve next to liquid" test and the carver debug state named in the round brief are not in the artifact (no class, no tag file, no JSON field). They are recorded here as absent, not as unread.
3. **The lava level of carved Nether caves is the sea level 32, not -10 and not -54.** Carved blocks take the state the (disabled) aquifer returns, which is the global fluid: lava at `y <= 31` and air at `y >= 32` (section 7). A "lava level of -10 absolute" appears nowhere in the artifact's carver code or data.
4. **The Nether has no aquifer.** `noise_settings/nether.json` has no `aquifers` field, so the chunk's aquifer is the disabled one (section 7.1).
5. **Everything random in the Nether is the legacy generator.** `legacy_random_source` is true, so the surface-depth random, the bedrock vertical gradients and all named noises seed from the Java LCG factory, not from Xoroshiro (section 2). The carvers use the LCG in every dimension.
6. **The Nether material rule has no `above_preliminary_surface` and no lava-level condition of its own.** Its lava comes from a single `on_floor` + `hole` rule below y 32 (section 5). Its three vertical limits are `below_top 5` (netherrack roof band) and the two bedrock gradients; with the generation height of 128 those anchors resolve to y 122 and 123..127 (section 3).

---

## 2. Random sources in the Nether

`RandomState` builds its root positional factory `P` as `Algorithm.LEGACY.newInstance(worldSeed).forkPositional()` when the noise settings say `legacy_random_source` (the Nether does), else with Xoroshiro (the overworld). The world seed passed in is taken to be the level seed, the same numeric seed as the overworld's (inferred: one `RandomState.create(seed)` per level; the seed argument was not traced further, Open question 2). The worked examples (for instance F = -4962768465676381896 for seed 0) assume that the argument seed is the level seed; they hold for "seed 0 as a raw `LegacyRandomSource`" and carry over to a level only if Open question 2 holds.

| Operation | Legacy definition (`LegacyRandomSource`, `LegacyPositionalRandomFactory`) |
|---|---|
| root `P` | `LegacyRandomSource(worldSeed)`; `P = new factory(nextLong())` where `nextLong()` is the first LCG draw pair (10 section 2.6, 11 section 4). Reference: world seed 0 gives `F = -4962768465676381896` |
| `P.at(x, y, z)` | `LegacyRandomSource(getSeed(x, y, z) XOR F)`, with `getSeed` as in 10 section 2.4 (the same function; `Mth.getSeed`) |
| `P.fromHashOf(name)` | `LegacyRandomSource( (long)(int) javaStringHash(name) XOR F )`. `javaStringHash` is Java's `String.hashCode`: `h = 0; for each UTF-16 char c: h = 31*h + c` in 32-bit wrapping arithmetic; the int is sign-extended to long before the XOR. The name is the full text `namespace:path`, because `fromHashOf(Identifier)` calls the string form with `Identifier.toString()` |
| `P.fromSeed(s)` | `LegacyRandomSource(s)` |
| `forkPositional()` on a legacy source | a new factory whose seed is that source's `nextLong()` |
| `RandomState.getOrCreateRandomFactory(id)` | `P.fromHashOf(id).forkPositional()` (so the gradient factories are `LegacyPositionalRandomFactory(first nextLong() of LegacyRandomSource(hash(id) XOR F))`) |
| named noise `id` (`Noises.instantiate`) | `NormalNoise.create(P.fromHashOf(id))`: the octave noises are built exactly as 10 section 3.3 says (two `forkPositional()` forks `A`, `B` of the named random, then `fromHashOf("octave_" + index)` of each), with every factory now a legacy factory. `NormalNoise.create` has no legacy branch; the separate `createForLegacyNetherBiome` method is the biome source's business (sibling 37-3) |

LCG primitives are those of 11 section 4 (all read in `BitRandomSource`: `nextFloat` is `next(24)` times 5.9604645E-8 (2^-24), a float; `nextDouble` is `((long) next(26) << 27) + next(27)` times 1.1102230246251565E-16 (2^-53); `nextLong` is `((long) next(32) << 32) + next(32)`; `nextInt(bound)` is `(bound * next(31)) >> 31` (computed in 64 bits) when the bound is a power of two, else a modulo loop with rejection of overflowing draws; the reference values for seed 0 in 11 section 4 were reproduced by the reference implementation used for this document: `nextLong` -4962768465676381896, `nextInt()` -1155484576, `nextFloat` 0.7309678).

---

## 3. Generation context numbers for the Nether

The Nether level is 256 high (dimension type, 37-1 section 2) but its noise settings say `min_y 0`, `height 128`. Every vertical anchor in a material rule or a carver is resolved against a `WorldGenerationContext`, whose two numbers are read from the class:

| Quantity | Definition (`WorldGenerationContext`, `NoiseBasedChunkGenerator.getMinY/getGenDepth`) | Nether value |
|---|---|---|
| `minGenY` | `max(levelMinY, noise settings min_y)` | `max(0, 0) = 0` |
| `genDepth` | `min(levelHeight, noise settings height)` | `min(256, 128) = 128` |
| anchor `absolute n` | `n` | `n` |
| anchor `above_bottom n` | `minGenY + n` | `n` |
| anchor `below_top n` (`VerticalAnchor$BelowTop`) | `genDepth - 1 + minGenY - n` | `127 - n` |
| sea level | noise settings `sea_level` | 32 |

So in the Nether `below_top 5` is y 122 and `below_top 1` is y 126 and `below_top 0` is y 127. The overworld statement "below_top n = 319 - n" of 10 section 10.4 is the same formula with the overworld's numbers. The surface and carver stages touch only blocks the terrain fill produced (y 0..127, 37-2) plus the bedrock rules below: nothing in this document writes above y 127 (37-1 section 6.9 now lists the rule order consistently with this; see Open question 6).

---

## 4. The surface pass as it applies to the Nether

The engine is the material rule engine of 10 section 10 (`MaterialSystem.buildSurface`), run in the `TERRAIN` stage after the fill and before the carvers (section 9). The Nether instance differs from the overworld instance only in the data it is given and in these points:

1. The rule is `minecraft:nether` (`noise_settings/nether.json`, `material_rule`), not `minecraft:overworld`; section 5 lists it completely.
2. The column procedure of 10 section 10.1 is used unchanged: start at the first block above the `WORLD_SURFACE_WG` height of the column, walk down, track `stoneDepthAbove`, `stoneDepthBelow` and `waterHeight`, evaluate the rule at every solid block. "Solid" means non-air with an empty fluid state, so **lava counts as fluid, not stone**: a lava lake bottom has `stoneDepthAbove = 1` for the first solid block under the lava, and `waterHeight` (misnamed; it is the height above the first fluid block of any kind) is set. The Nether rule never reads `waterHeight` (no `water` condition), so the only effect of lava is that it ends the stone run for the depth counters.
3. The eroded-badlands and frozen-ocean column extensions are biome tests that the Nether biomes never satisfy.
4. `steep`, `above_preliminary_surface`, `temperature`, `water`, `bandlands` and `ore_vein` are never evaluated by the Nether rule. The `chunk_surface_level` router entry is constant 0.0 (37-1 section 6.9), so `minSurfaceLevel` is `floor(0) + surfaceDepth - 8` and is unused.
5. The biome condition samples `BiomeManager.getBiome(x, y, z)` at the current y (10 sections 7.7 and 10.1), but the Nether biome source does **not** vary with y: in `noise_settings/nether.json` the router entry `depth` is the constant 0.0 and the `temperature` and `vegetation` noises have `y_scale` 0.0 (all read), so the biome is one value per (x, z) column, and a ceiling block and a floor block of one column lie in the same biome ([37-nether-3-biome-source-and-climate.md](37-nether-3-biome-source-and-climate.md) section 5.1, "No y dependence"). The rule is still evaluated per block, but with one biome for the whole column.
6. `surfaceDepth(x, z)` is `(int)(surface.get(x,0,z) * 2.75 + 3.0 + R.nextDouble() * 0.25)` with `R = P.at(x, 0, z)` (10 section 10.3), where `P` and the `minecraft:surface` noise are the **legacy** ones of section 2. The surface noise is sampled through `Noise.get`, which returns a **float**; it is widened to double (`f2d`) before the multiplication and the `(int)` truncation (`MaterialSystem.getSurfaceDepth`). `R` is made by the root positional factory `P` itself (`noiseRandom`, read), so it is the legacy `P.at(x, 0, z)`. Noise `minecraft:surface`: `base_octave -6`, `octave_count 3`, `base_amplitude 0.9381732587751008`, no modifiers (the same file as the overworld).

### 4.1 Condition kinds used by the Nether rule, with every Nether instance

| Kind (10 section 10.4) | Instances in `minecraft:nether` |
|---|---|
| `vertical_gradient` | `bedrock_floor`: random name `minecraft:bedrock_floor`, true at and below `above_bottom 0` (y 0), false at and above `above_bottom 5` (y 5). `bedrock_roof`: random name `minecraft:bedrock_roof`, true at and below `below_top 5` (y 122), false at and above `below_top 0` (y 127), used under `not` |
| `y_above` | `below_top 5` (y >= 122), multiplier 0, `add_stone_depth` false; `absolute 30`, `absolute 31`, `absolute 32`, `absolute 35` (all multiplier 0) with `add_stone_depth` true for 30 and 35 in the gradient bands and false for 31 and 32 in the on-floor tests, exactly as the tree of section 5 shows |
| `noise_threshold` (2D: `is_3d` absent, so `N.get(x, 0, z)`) | `patch >= -0.012`, `nether_state_selector >= 0.0`, `soul_sand_layer >= -0.012`, `gravel_layer >= -0.012`, `netherrack` (as `not` of `>= 0.54`), `nether_wart >= 1.17`. Every upper bound is `Double.MAX_VALUE` (1.7976931348623157E308), i.e. unbounded. The sampled value is the float returned by the noise widened to double, and the test is **inclusive on both sides**: `min <= v <= max` (read in `NoiseThresholdCondition`) |
| `stone_depth` | the three named conditions: `on_floor` (floor, offset 0, add_surface_depth **false**, secondary range 0), `under_floor` (floor, offset 0, add_surface_depth true, range 0), `under_ceiling` (ceiling, offset 0, add_surface_depth true, range 0). The secondary range is 0 in all of them, so `surface_secondary` is never sampled. They are true when `stoneDepthAbove <= 1 + surfaceDepth` (floor, with surface depth) , `stoneDepthAbove <= 1` (on_floor) or `stoneDepthBelow <= 1 + surfaceDepth` (ceiling) |
| `biome` | `basalt_deltas`, `soul_sand_valley`, `warped_forest`, `crimson_forest`, `nether_wastes` (each a single id) |
| `hole` | `surfaceDepth <= 0` (read: `HoleCondition`), used as a plain test (lava rule, nylium-free floors) and under `not` (wastes) |
| `not` | around `y_above`, `noise_threshold`, `hole` and the roof gradient |
| `steep`, `water`, `above_preliminary_surface`, `temperature` | not used |

The noise parameters needed to build the six threshold noises are data in `worldgen/noise/*.json` (extracted by the tool); they are repeated here because the surface rule cannot be verified without them. All noises are `NormalNoise` per 10 section 3.3 (`normalize` default `enabled`, `octave_count` default 1, empty modifier list means all 1.0).

| Noise id | `base_octave` | `octave_count` | `base_amplitude` | `amplitude_modifiers` |
|---|---|---|---|---|
| `minecraft:surface` | -6 | 3 | 0.9381732587751008 | none |
| `minecraft:nether_state_selector` | -4 | 1 | 0.955388882960065 | none |
| `minecraft:netherrack` | -3 | 4 | 1.4659491761370222 | 1.0, 0.0, 0.0, 0.35 |
| `minecraft:nether_wart` | -3 | 4 | 1.3827102115748344 | 1.0, 0.0, 0.0, 0.9 |
| `minecraft:soul_sand_layer` | -8 | 9 | 1.0569606747151457 | 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.013333333333333334 |
| `minecraft:gravel_layer` | -8 | 9 | 1.0569606747151457 | same as `soul_sand_layer` |
| `minecraft:patch` | -5 | 6 | 1.637127519350388 | 1.0, 0.0, 0.0, 0.0, 0.0, 0.013333333333333334 |

(Slots with modifier 0.0 advance the frequency and add no octave, 10 section 3.3.)

---

## 5. The complete `minecraft:nether` material rule tree

Read from `material_rule/nether.json`, with `bedrock_floor`, `bedrock_roof` and the three named stone-depth conditions inlined (`[name]`). The tree was printed from the JSON by a script, so the nesting is exact. A `SEQ` takes the first child that yields a block; an `IF` yields its child's result or nothing. Anchors are the raw JSON values; section 3 resolves them. `noise(N) >= a` stands for `noise_threshold` with `min_threshold a` and an unbounded maximum.

```
[nether]  SEQ
  1  IF vgrad(random "minecraft:bedrock_floor", true <= above_bottom 0, false >= above_bottom 5)    -> bedrock
  2  IF NOT vgrad(random "minecraft:bedrock_roof", true <= below_top 5, false >= below_top 0)       -> bedrock
  3  IF y_above(below_top 5, mult 0, add_stone_depth false)                                          -> netherrack
  4  IF biome(basalt_deltas)  SEQ
       4a IF under_ceiling                                                                           -> basalt
       4b IF under_floor  SEQ
            IF noise(patch) >= -0.012
               IF y_above(absolute 30, add_stone_depth true)
                  IF NOT y_above(absolute 35, add_stone_depth true)                                  -> gravel
            IF noise(nether_state_selector) >= 0.0                                                   -> basalt
            (always)                                                                                 -> blackstone
  5  IF biome(soul_sand_valley)  SEQ
       5a IF under_ceiling  SEQ
            IF noise(nether_state_selector) >= 0.0                                                   -> soul_sand
            (always)                                                                                 -> soul_soil
       5b IF under_floor  SEQ
            IF noise(patch) >= -0.012
               IF y_above(absolute 30, add_stone_depth true)
                  IF NOT y_above(absolute 35, add_stone_depth true)                                  -> gravel
            IF noise(nether_state_selector) >= 0.0                                                   -> soul_sand
            (always)                                                                                 -> soul_soil
  6  IF on_floor  SEQ
       6a IF NOT y_above(absolute 32, add_stone_depth false)
             IF hole                                                                                 -> lava
       6b IF biome(warped_forest)
             IF NOT noise(netherrack) >= 0.54
                IF y_above(absolute 31, add_stone_depth false)  SEQ
                   IF noise(nether_wart) >= 1.17                                                     -> warped_wart_block
                   (always)                                                                          -> warped_nylium
       6c IF biome(crimson_forest)
             IF NOT noise(netherrack) >= 0.54
                IF y_above(absolute 31, add_stone_depth false)  SEQ
                   IF noise(nether_wart) >= 1.17                                                     -> nether_wart_block
                   (always)                                                                          -> crimson_nylium
  7  IF biome(nether_wastes)  SEQ
       7a IF under_floor
             IF noise(soul_sand_layer) >= -0.012  SEQ
                IF NOT hole
                   IF y_above(absolute 30, add_stone_depth true)
                      IF NOT y_above(absolute 35, add_stone_depth true)                              -> soul_sand
                (always)                                                                             -> netherrack
       7b IF on_floor
             IF y_above(absolute 31, add_stone_depth false)
                IF NOT y_above(absolute 35, add_stone_depth true)
                   IF noise(gravel_layer) >= -0.012  SEQ
                      IF y_above(absolute 32, add_stone_depth false)                                 -> gravel
                      IF NOT hole                                                                    -> gravel
  8  (always)                                                                                        -> netherrack
```

All block results use default block states (the nylium, wart blocks, basalt (axis `y`), soul sand, gravel and blackstone have no non-default properties in the rule). `basalt` therefore is the default state of `minecraft:basalt`, whose `axis` property default is read from the block registry (24 block registry documents), not set here.

### 5.1 What each rule does, in numbers

Let `sd = surfaceDepth`, `sda = stoneDepthAbove`, `sdb = stoneDepthBelow`, `y` the block's y.

| Rule | True region | Result |
|---|---|---|
| 1 floor bedrock | y 0 always; y 1..4 with probability 0.8, 0.6, 0.4, 0.2; y >= 5 never | bedrock |
| 2 roof bedrock | y 127 always; y 126, 125, 124, 123 with probability 0.8, 0.6, 0.4, 0.2; y <= 122 never | bedrock |
| 3 | every solid block at y >= 122 not already bedrock | netherrack: the roof band is plain netherrack in every biome, so basalt, soul soil and the ceiling rules never act at y >= 122 |
| 4a basalt ceiling | `sdb <= 1 + sd` (the lowest `1 + sd` blocks of a solid run, counted from the bottom of the run, over air or fluid, **or at the bottom of the world**: see the bottom-of-world rule below) | basalt, no noise |
| 4b basalt floor | `sda <= 1 + sd`: first `sd + 1` solid blocks below the surface. Within it: `patch >= -0.012` and `30 <= y + sda <= 34` gives gravel; else `nether_state_selector >= 0` gives basalt; else blackstone | gravel, basalt, blackstone |
| 5a soul valley ceiling | `sdb <= 1 + sd` (same bottom-of-world rule) | soul sand where `nether_state_selector >= 0`, else soul soil |
| 5b soul valley floor | `sda <= 1 + sd` | gravel under the same patch band as 4b; else soul sand where `nether_state_selector >= 0`, else soul soil |
| 6a lava | `sda <= 1` (top block of a solid run), `y <= 31`, and `sd <= 0` (a "hole" in the surface-depth noise) | lava replaces the top block: lava pools in dips of the floor |
| 6b, 6c forests | top block (`sda <= 1`), `netherrack` noise `< 0.54`, `y >= 31` | wart block where `nether_wart >= 1.17`, else nylium of the biome. If any test fails the sequence yields nothing and the next rules apply |
| 7a wastes soul-sand patch | `sda <= 1 + sd` and `soul_sand_layer >= -0.012`: then soul sand where `sd > 0` and `30 <= y + sda <= 34`, else netherrack | soul sand or netherrack |
| 7b wastes gravel | top block, `y >= 31`, `y + sda <= 34` (that is `y <= 33`), `gravel_layer >= -0.012`: gravel if `y >= 32`, else (y = 31) gravel only where `sd > 0` | gravel |
| 8 fallthrough | everything else | netherrack (also the default block, so nothing visible changes) |

Consequences worth testing:
- `y + sda` for a floor block is one above its top face when `sda = 1`. The band `30 <= y + sda <= 34` therefore selects columns whose surface (top solid block) is between y 29 and y 33 for the top block, and the same band for deeper blocks of the same column: the soul sand, gravel patch layer is as thick as `sd + 1` blocks but only for surfaces in that height band; a surface at y 34 or higher is never sand or gravel (the `NOT y_above(35)` test fails) and a surface below y 29 is neither.
- Rule 6a is not specific to a biome. In `basalt_deltas` and `soul_sand_valley` it is reached only by top blocks with `sd < 0` (every top block with `sd >= 0` is caught by `under_floor` of 4b or 5b first); in the other biomes it applies to any top block at `y <= 31` with `sd <= 0` (and in the forests it precedes 6b/6c). Lava is therefore not a feature of the valley's floor branch.
- Rules 4b, 5b and 7a use `under_floor`, which includes the top block, so the floor material rules cover the top block too; rule 6 (`on_floor`, top block only) is reached in `basalt_deltas` and `soul_sand_valley` only when 4b/5b did not apply, which happens only when `1 + sd < sda`, i.e. never for the top block unless `sd < 0` (then `1 + sd <= 0 < 1` and `under_floor` is false for every block). For a column with `sd < 0` the biome floor rules of 4b, 5b and 7a are all skipped and rule 6a (lava below 32) and the fallthrough decide.
- **Bottom of the world.** In the column procedure (10 section 10.1), when the scan for the end of a solid run passes `minY` (0 here), the block below the column counts as non-stone and `lowerStone = minY`, so at the bottom of an unbroken run `sdb = y + 1`. In `basalt_deltas` and `soul_sand_valley` therefore every block that the bedrock rules did not take and that has `y + 1 <= 1 + sd` takes the ceiling result: rule 4a basalt, or rule 5a soul sand / soul soil. This is independent of any air above or below the block: it is a property of the world floor. `nether_wastes` has no ceiling rule and is unaffected (its rules 7a/7b use `sda` only). Example 12 of section 9 works one column.
- Ceilings are tested before floors inside 4 and 5 (4a before 4b, 5a before 5b), so a one-block-thick solid layer (both `sda = 1` and `sdb = 1`) takes the ceiling material.
- The biome is constant along a column (item 5 of section 4), so the biome-specific rules never change mid-column at a biome boundary; a column changes material only through the depth counters, the y tests and the noise tests.

### 5.2 Bedrock probabilities

For a vertical gradient with `trueAt`, `falseAt` the test is true when `y <= trueAt`, false when `y >= falseAt`, and otherwise true when a fresh `nextFloat()` is below `t = map(y, trueAt, falseAt, 1.0, 0.0)` (10 section 10.4). The random comes from `F.at(x, y, z)` where `F = getOrCreateRandomFactory("minecraft:bedrock_floor")` (respectively `..._roof`), a legacy factory (section 2); one fresh `at(x, y, z)` generator and its **first** `nextFloat()` per tested block (the `vertical_gradient` result is cached per block, not re-drawn).

| y | floor: `t` (bedrock when float `< t`) | roof: `t` (bedrock when NOT (float `< t`), i.e. float `>= t`) |
|---|---|---|
| 0 | n/a, `y <= trueAt`, certain | n/a (< 122, never) |
| 1, 2, 3, 4 | 0.8, 0.6, 0.4, 0.2 | n/a |
| 5.. 122 | never (`y >= falseAt`) for floor; never for roof up to 122 (`y <= trueAt` true, inverted false) | n/a |
| 123, 124, 125, 126 | n/a | `t` = 0.8, 0.6, 0.4, 0.2, so bedrock probability 0.2, 0.4, 0.6, 0.8 |
| 127 | n/a | certain (`y >= falseAt` false, inverted true) |

---

## 6. The Nether cave carver

### 6.1 Configuration (`worldgen/carver/nether_cave.json`, `Carvers`)

The JSON and the `Carvers` bootstrap code agree (both read). Type `minecraft:cave`; the carver `CaveWorldCarver` of 11 section 5.3 with:

| Parameter | Nether value | Overworld `cave` (11 section 5.1) |
|---|---|---|
| `probability` | 0.2 | 0.15 |
| `y` (uniform height provider) | min `absolute 0` (y 0), max `below_top 1` (y 126); one `nextInt(127)` | min anchor `above_bottom 8` (y -56 once resolved against the overworld's minimum y), max `absolute 180` |
| `count` | `very_biased_to_bottom`, 0 to 9 inclusive: `a = nextInt(10)`, `b = nextInt(a + 1)`, `c = nextInt(b + 1)`, count = `min + c` with `min` 0 (three draws; `sample` is `min + nextInt(nextInt(nextInt(max - min + 1) + 1) + 1)`, read from `VeryBiasedToBottomInt`) | 0..14 |
| `floor_level` | constant -0.7 (no draw) | uniform [-1.0, -0.4) |
| `horizontal_radius_multiplier` | constant 1.0 (no draw) | uniform [0.7, 1.4) |
| `vertical_radius_multiplier` | constant 1.0 (no draw) | uniform [0.8, 1.3) |
| `room_vertical_radius_multiplier` | constant 0.5 (no draw) | uniform [0.1, 0.9) |
| `start_vertical_radius_multiplier` | constant **5.0** (no draw) | absent, default constant 1.0 |
| `thickness` | `trapezoid` min 0.0, max 6.0, plateau 2.0 (two float draws: 0 + `nextFloat()*4.0` + `nextFloat()*2.0`, 11 section 4) | trapezoid 0..3 plateau 1 |
| `weird_thickness_bias` | absent: the codec default is **false** (read), so no `nextInt(10)` and no extra float draws in the thickness | true |

A JSON number where a float provider is expected is a constant provider; a constant draws nothing from the random source (11 section 4).

Which biomes use it: all five Nether biomes (`nether_wastes`, `soul_sand_valley`, `crimson_forest`, `warped_forest`, `basalt_deltas`) have the biome field `carvers` equal to the single carver `minecraft:nether_cave`; the six End biomes have an empty carver list; the 56 other (overworld) biomes use `[cave, cave_extra_underground, canyon]` (the Nether biomes use the bare-string form of `carvers`, `"carvers":"minecraft:nether_cave"`, not a list, so a data-driven parser must accept a string as well as a list; counted by script over the 67 files under `data/minecraft/worldgen/biome/`: 5 + 6 + 56). Because the carver list is the same in every Nether biome, **the biome found at a source chunk does not matter for the Nether**, and the carver index `i` in the seeding of section 6.2 is always 0.

### 6.2 Which source chunks, which seed

The procedure of 11 section 5.2 applies without change (`NoiseBasedChunkGenerator.generateCarvers`): for the chunk T being generated, every source chunk S = (T.x + dx, T.z + dz) with dx outer and dz inner from -8 to 8; the carver list of S is found from the biome at quart `(S.minBlockX >> 2, 0, S.minBlockZ >> 2)` (here: the one-entry list); for each carver at list index `i`: `WorldgenRandom(LegacyRandomSource)` re-seeded with `setLargeFeatureSeed(worldSeed + i, S.x, S.z)` (11 section 4: with s = worldSeed + i, `setSeed(s)`, a = `nextLong()`, b = `nextLong()`, then `setSeed((S.x * a) XOR (S.z * b) XOR s)`, 64-bit products), then `isStartChunk`: `nextFloat() <= 0.2`. If true, `carve` continues with the same generator.

Differences caused by the Nether data only:
- The carver list has length 1, so the only seed per source chunk is `setLargeFeatureSeed(worldSeed, S.x, S.z)`. For S = (0, 0) the seed is `worldSeed` itself (both products vanish), so for world seed 0 the first draw is `nextFloat() = 0.7309678 > 0.2`: no cave starts at chunk (0, 0).
- The carvers draw nothing from the aquifer or from the noise: every carved shape is a pure function of (world seed, S), so neighbouring chunks agree (as in 11 section 5.2).

### 6.3 Per-start procedure with the Nether numbers

The draw order is that of 11 section 5.3 (read again from `CaveWorldCarver.carve` for this round; it matches). With the Nether configuration:

1. `count` (3 draws, section 6.1). The count is `min_inclusive + c` with `min_inclusive` 0 here. The mean count is exactly 1.125 (computed: `E[nextInt(n)] = (n - 1) / 2` at each of the three levels gives `E[a] = 4.5`, `E[b] = 2.25`, `E[c] = 1.125`). The expected number of caves per source chunk is therefore `0.2 * 1.125 = 0.225`.
2. For each cave, in this order: `x = S.minBlockX + nextInt(16)`; `y = nextInt(127)` (height provider uniform on [0, 126]); `z = S.minBlockZ + nextInt(16)`; then the four constant providers consume nothing: `hMul = 1.0`, `vMul = 1.0`, `yScaleStart = 5.0`, `floor = -0.7`.
3. `nextInt(4)`: if 0 the cave has a **room**: no draw for `roomV` (constant 0.5); `roomR = 1.0 + nextFloat() * 6.0` (one float draw, range [1, 7)); one ellipsoid at `(x + 1.0, y, z)` with horizontal radius `h = 1.5 + roomR` (range [2.5, 8.5)) and vertical radius `h * 0.5`; then `tunnels = 1 + nextInt(4)` (one more draw). Without a room `tunnels = 1`.
4. For each tunnel: `yaw = nextFloat() * 6.2831855`; `pitch = (nextFloat() - 0.5) / 4.0`; `thickness` (two float draws: `nextFloat() * 4.0 + nextFloat() * 2.0`, range [0, 6), mean 3.0); no weird-bias draws; `maxSteps = 112 - nextInt(28)` (range 85..112); `nextLong()` as the walker seed; walk (11 section 5.3.1) with `yScale = 5.0`.

The cave walker's own rules (a new `SingleThreadedRandomSource` from the walker seed, `branchStep = nextInt(maxSteps/2) + maxSteps/4`, `steep = nextInt(6) == 0`, per-step radius `r = 1.5 + sin(pi * step / maxSteps) * thickness`, step skipping with `nextInt(4) == 0`, `canReach`, the two branches at `branchStep` when `thickness > 1.0`) are those of 11 section 5.3.1; this was re-read from `createTunnel` and agrees, including the constants 0.92 / 0.7, 0.1, 0.9, 0.75, 1.5707964, and the branch thickness `nextFloat() * 0.5 + 0.5`. What the Nether numbers change:

| Effect | Value | Why |
|---|---|---|
| Vertical radius of a main tunnel ellipsoid | `rv * vMul = r * 5.0 * 1.0`, so up to `7.5 * 5 = 37.5` and at least `1.5 * 5 = 7.5` at the tunnel ends | `start_vertical_radius_multiplier` 5.0 is the tunnel's `yScale` |
| Vertical radius of a branch | `r * 1.0 * 1.0` (branches are started with `yScale` 1.0) | read in `createTunnel` (the recursive call passes 1.0) |
| Horizontal radius | `r * 1.0` | `hMul` 1.0 |
| Fraction of tunnels that branch | those with initial `thickness > 1.0`: `P(thickness > 1)` is exactly 0.9375 (computed: `thickness = 4u + 2v` with u, v uniform on [0, 1); the region `4u + 2v < 1` is a triangle of area 1/16) | the Nether trapezoid reaches up to 6 |
| Cave floor | blocks with `yd <= -0.7` are skipped: the lower 15 percent of the ellipsoid's height (`(1 - 0.7) / 2`) is flat | `floor_level -0.7` constant; 11 section 5.3.1 skip test |
| Room | horizontal radius `1.5 + roomR`, vertical half of it | `room_vertical_radius_multiplier` 0.5 constant |

With `roomR` in [1, 7) the room's horizontal radius is in [2.5, 8.5) and its vertical radius in [1.25, 4.25).

### 6.4 Ellipsoid, mask range and mask application in the Nether

`WorldCarver.carveEllipsoid` is the generic one of 11 section 5.5 (re-read; same constants). The Nether values of its inputs, read from `NoiseBasedChunkGenerator.generateCarvers`:

| Quantity | Formula | Nether value |
|---|---|---|
| mask lowest y (`CarverOutput.minY`) | `minGenY + 1` | 1 |
| mask highest y (`CarverOutput.maxY`) | `minGenY + genDepth - 1 - 7` (7 when the chunk is not being upgraded) | 120 |
| mask height | `maxY - minY + 1` (the constructor `CarvingMask(minY, maxY)` takes the lowest and highest y in that order and derives the height; its bit set has `256 * height` bits) | 120 (when the chunk is being upgraded the 7 is 0, so `maxY` 127 and height 127) |
| mask index | `getIndex(x, y, z) = (y - minY) + (z + (x << 4)) * height` (read) | `(y - 1) + (z + 16 * x) * 120` |
| lowest y that can be carved | `yLo = max(floor(cy - vR) - 1, 1)`; the loop runs `y` from `yHi` down to `yLo + 1` | 2 |
| highest y that can be carved | `yHi = min(floor(cy + vR) + 1, 120)` | 120 |

So a Nether cave never removes y 0 or 1 (bedrock floor and the layer above it) nor anything at y >= 121 (the netherrack roof band and the bedrock roof): the roof band 121..127 is untouched, and carved space can reach at most y 120.

Applying the mask (`applyCarvingMask`, per column from the highest marked y of each run downward) is the procedure of 11 section 5.6 with these Nether specifics:

1. A block in the tag `minecraft:uncarvable` is skipped: only `bedrock`. Every other block state, including netherrack, basalt, blackstone, soul sand, soul soil, gravel, nylium, wart blocks, lava, glowstone and ore, is replaced. There is no replaceable-blocks filter.
2. The "grassy" regrowth step (block was `grass_block` or `mycelium`, then a dirt block below is re-surfaced) cannot trigger in generated Nether terrain (the rule of section 5 never places those blocks); it is described in 11 section 5.6 step 4.
3. The replacement state is `aquifer.computeSubstance(x, y, z, 0.0)` of the **disabled aquifer** (section 7): lava at `y <= 31`, air at `y >= 32`, never null (a null result, "barrier", is impossible for the disabled aquifer at density 0).
4. Because the disabled aquifer's `shouldScheduleFluidUpdate` is false, carved lava is **not** queued for post-processing fluid ticks (read: the call is guarded by that flag): lava produced by carving does not flow until something updates it (inferred consequence).

---

## 7. Fluid in carved Nether caves

### 7.1 The disabled aquifer

`NoiseChunk` builds a real aquifer only when the noise settings carry an `aquifers` field; otherwise it builds `Aquifer.createDisabled(fluidPicker)`. The Nether has no such field (read from `nether.json`), so its aquifer is the disabled one:

- `computeSubstance(x, y, z, density)`: if `density > 0` return nothing; otherwise return `fluidPicker.computeFluid(x, y, z).at(y)`.
- `shouldScheduleFluidUpdate()`: false.

### 7.2 The global fluid picker

`NoiseBasedChunkGenerator.createFluidPicker(settings)` builds three statuses: lava at level -54, the sea-level status (level `seaLevel`, block `default_fluid`) and a third of air at level `2 * DimensionType.MIN_Y`. The third is returned for every position only when the constant `SharedConstants.DEBUG_DISABLE_FLUID_GENERATION` is set (a debug path, read in the lambda; ignored below). With the flag off the pick is by y:

| Condition | Fluid level | Fluid block |
|---|---|---|
| `y < min(-54, seaLevel)` | -54 | lava (hard-coded) |
| otherwise | `seaLevel` | the noise settings `default_fluid` |

`FluidStatus.at(y)` returns the fluid block when `y < fluidLevel`, else air. For the Nether, `min(-54, 32) = -54` and every Nether y is >= 0, so the second row always applies: the fluid level is **32** and the block is `minecraft:lava`.

| y of a carved block | Result |
|---|---|
| 0 .. 31 (only 2..31 is carvable) | lava |
| 32 .. 120 | air |

The same global fluid decides what the terrain fill puts in empty space below y 32 (lava sea, sibling 37-2), so carved caves below y 32 are lava-filled the same way and are visually part of the lava sea.

---

## 8. Chunk generation order as it applies to the Nether

The stages of 10 section 11.1 are the same for every noise-based dimension. The Nether instance of the `TERRAIN` stage is, in this order: create the noise chunk (no aquifer, no ore veins, the Nether router, the beardifier for structures), fill (37-2), surface rules (section 5), carvers (section 6), then `FEATURES` (decoration, 37-5) which can write into neighbours. The carvers see the surface-pass result, so they also cut basalt, soul sand and nylium, and they run once per chunk over the 17 x 17 source chunks. The surface pass biome lookups read the 3 x 3 neighbourhood of stored biomes (10 section 11.2); the carvers read only the one-entry carver list so they never depend on neighbouring biomes in the Nether.

---

## 9. Worked examples (computed)

All values below are computed from the rules in this document with the reference implementation of the Java LCG (checked against 11 section 4's reference values) and are not observed from the artifact. World seed 0 unless said otherwise.

1. **Legacy factory seeds.** `F = P.seed = -4962768465676381896`. `javaStringHash("minecraft:bedrock_floor") = 2042456806`, `("minecraft:bedrock_roof") = 343340730`, `("minecraft:patch") = -1137280965`. The factory for `minecraft:bedrock_floor`: `G = LegacyRandomSource(2042456806 XOR F).nextLong() = -7693059141002965223`.
2. **Bedrock floor at (0, 1, 0).** `getSeed(0, 1, 0) XOR G` seeds an LCG whose first `nextFloat()` is 0.65342617. `t = 0.8` at y 1, `0.65342617 < 0.8`: bedrock. At (5, 2, 7): float 0.54224592, `t = 0.6`: bedrock.
3. **Bedrock roof.** `G` for `minecraft:bedrock_roof` from `F` and hash 343340730. At (0, 125, 0): float 0.79000527; `t = map(125, 122, 127, 1, 0) = 0.4`; the gradient is false (0.79 is not below 0.4) so the inverted condition holds: bedrock. At (3, 124, 9): float 0.48437124, `t = 0.6`: gradient true, inverted false: not bedrock (netherrack from rule 3, since y >= 122).
4. **Surface depth random.** `R = P.at(0, 0, 0)`: first `nextDouble()` = 0.26044200501959935 (so `R * 0.25 = 0.0651`); `P.at(16, 0, -3)`: 0.3851230705401715. With a surface-noise value of the float 0.2f (assumed; widened it is 0.20000000298023224) at (0, 0): `(int)(0.20000000298 * 2.75 + 3.0 + 0.0651) = (int)3.6151 = 3`.
5. **Wastes soul sand, `sd = 3`** (assumed noise values: `soul_sand_layer = 0.1`). A column whose top solid block is at y 33 under air: the blocks y 33, 32, 31, 30 have `sda` 1, 2, 3, 4, so `y + sda = 34` for all four; `under_floor` holds for `sda <= 4`; rule 7a: layer passes, `NOT hole` (sd 3), `34 >= 30`, `NOT (34 >= 35)`: soul sand for all four. y 29 has `sda = 5 > 4`: rule 7a no, 7b no (`sda > 1`), rule 8: netherrack. A column whose top is y 34 under the same conditions: top block `y + sda = 35`: 7a's inner sequence yields nothing, then `(always) netherrack` of 7a: netherrack, so no sand.
6. **Wastes gravel.** Top block at y 33 (`sda = 1`), `sd = 3`, `soul_sand_layer = -0.5` (fails 7a's noise), `gravel_layer = 0.2`: 7b: `y_above(31)` true; `NOT y_above(35, add_stone_depth)`: `33 + 1 = 34 < 35` true; gravel noise true; `y_above(32)` true: gravel. At y 31 with `sd = 0`: the first gravel branch fails (`31 < 32`), second needs `NOT hole`, `sd <= 0` is a hole: nothing, the block is netherrack.
7. **Lava pool.** Crimson forest, top block at y 30 (`sda = 1`), `sd = 0` (hole): rules 1 to 5 do not apply (not at the edges, biome not delta or valley), 6a: `NOT y_above(32)` (30 < 32) true, `hole` true: lava. With `sd = 2`: no lava; 6c: `netherrack = 0.3 < 0.54` passes, but `y_above(31)` fails at y 30: nothing; 7 is not the biome; rule 8: netherrack. At y 31 with `sd = 2`: 6a `NOT y_above(32)` true but not a hole, 6c: `y_above(31)` true: nylium (wart block if `nether_wart >= 1.17`).
8. **Basalt deltas ceiling.** A solid run from y 80 to y 90 under a lava sea below, open air above and below the run (a floating island): the block at y 80 has `sdb = 1`: `under_ceiling` (`1 <= 1 + sd`): basalt (4a, before the floor rules); y 90 has `sda = 1`: `sdb = 11`: not ceiling; 4b: floor: gravel needs `y + sda` in [30, 34] (91 fails), then `nether_state_selector >= 0` basalt else blackstone.
9. **A carver start (seed 0).** Source chunk (-2, -2): `setLargeFeatureSeed(0, -2, -2)`; first `nextFloat()` 0.11626184 <= 0.2: starts. Count draws: `nextInt(10) = 6`, `nextInt(7) = 1`, `nextInt(2) = 1`: count 1. Cave: `x = -32 + 3 = -29`, `y = nextInt(127) = 78`, `z = -32 + 14 = -18`; `nextInt(4) = 3`: no room. Tunnel: `yaw = 2.4950655`, `pitch = 0.0546752`, `thickness = 2.2020168`, `maxSteps = 112 - nextInt(28) = 96`, walker seed `-7856524665581999152`; the walker's first draws: `branchStep = nextInt(48) + 24 = 70`, `steep = false`. Other source chunks with starts at seed 0 (first draws only): (-3, -1) count 0; (-1, 2) count 3 with first cave at local (9, 3) y 70; (-1, 3) count 3 with first cave local (6, 1) y 29. Seed 12345: (-3, 2) count 1, local (1, 6) y 52.
10. **Tunnel step geometry.** For example 9 at `step = 48` (mid-walk): `r = 1.5 + sin(pi/2) * 2.2020168 = 3.7020`; `hR = 3.7020`, `vR = 3.7020 * 5.0 = 18.51`. If the walker is at `cy = 78`: `yLo = max(floor(78 - 18.51) - 1, 1) = 58`, `yHi = min(floor(96.51) + 1, 120) = 97`; a block is skipped by the floor test when `(y - 0.5 - 78) / 18.51 <= -0.7`, i.e. `y <= 65`; so the carved column at the ellipsoid axis spans y 66..97, a 32 block tall cavern with a flat floor, all air (y >= 32). The top block counts: `carveEllipsoid` loops `y` from `yHi` down to `yLo + 1` and carves at `y` itself with `yd = (y - 0.5 - cy) / vR`; at y 97, `yd = 18.5 / 18.510 = 0.99945`, below 1, so y 97 is carved.
11. **A low cave.** The same ellipsoid at `cy = 20`: `yLo = max(floor(1.49) - 1, 1) = 1`, `yHi = 39`; loop y 39 down to 2; floor skip at `y - 0.5 - 20 <= -12.96`, `y <= 7`; carved 8..39 (y 39: `yd = 18.5 / 18.510 = 0.99946`, below 1). Those at y 8..31 become lava, y 32..39 air: a lava lake topped by an eight block air pocket from y 32.
12. **Bottom of the world (basalt deltas, `sd = 3`).** A column of unbroken solid blocks from y 0 up to a surface at y 60 (so no air or fluid below). At y 0 `lowerStone = 0`, so `sdb = y + 1`: y 0 is 1, y 1 is 2, y 2 is 3, y 3 is 4, y 4 is 5. The ceiling test is `sdb <= 1 + sd = 4`, true for y 0..3. y 0 is bedrock (rule 1). For y 1, y 2 and y 3, if the bedrock gradient did not fire (section 5.2: the first float is at or above 0.8, 0.6, 0.4 respectively), rule 4a gives basalt without any noise test; y 4 has `sdb = 5`, fails 4a, fails 4b (`sda` is large), reaches rule 8: netherrack. In `soul_sand_valley` the same blocks y 1..3 take rule 5a: soul sand where `nether_state_selector >= 0`, else soul soil. In `nether_wastes` nothing changes: y 1..3 stay netherrack.

---

## 10. Validation checklist (checkable facts)

| # | Fact | Source read |
|---|---|---|
| V1 | `WorldCarverTypes` registers only `cave` and `canyon`; `nether_cave` is a `cave`-type configured carver | `WorldCarverTypes`, `nether_cave.json` |
| V2 | `nether_cave`: probability 0.2; y uniform 0 .. `below_top 1`; count `very_biased_to_bottom` 0..9; thickness trapezoid 0, 6, plateau 2; floor -0.7; horizontal 1.0; vertical 1.0; room vertical 0.5; start vertical 5.0; no weird bias | `nether_cave.json`, `Carvers` |
| V3 | the five Nether biomes list the carver `minecraft:nether_cave`; the six End biomes list none; all other biomes list the three overworld carvers | biome JSON, counted by script |
| V4 | disabled aquifer in the Nether; global fluid lava below y 32, air at or above | `nether.json` (no `aquifers`), `Aquifer$1`, `createFluidPicker` (`-54` and `seaLevel`, `min`) |
| V5 | `minGenY` 0, `genDepth` 128; `below_top n` is `127 - n` | `WorldGenerationContext`, `NoiseBasedChunkGenerator.getGenDepth`, `VerticalAnchor$BelowTop` |
| V6 | carving mask y range 1..120 (lowest carved 2); carved blocks skip only the `uncarvable` tag (bedrock) | `generateCarvers`, `applyCarvingMask` lambdas, `uncarvable.json` |
| V7 | the Nether rule order: bedrock floor, bedrock roof, y >= 122 netherrack, basalt deltas, soul sand valley, on-floor lava and forests, nether wastes, netherrack | `material_rule/nether.json` |
| V8 | bedrock probabilities 1.0 / 0.8 / 0.6 / 0.4 / 0.2 for y 0..4 and 1.0 at y 127, 0.8 / 0.6 / 0.4 / 0.2 for y 126..123 | gradient anchors and `VerticalGradientCondition` |
| V9 | legacy factory: `at` is `getSeed XOR factorySeed`; `fromHashOf` is `javaStringHash XOR factorySeed` | `LegacyPositionalRandomFactory` |
| V10 | seed 0: first `nextFloat()` of chunk (0, 0) 0.7309678 (no start); chunk (-2, -2) starts with count 1, cave at (-29, 78, -18) | computed (section 9, examples 9) |
| V11 | surface noise thresholds: patch, soul_sand_layer, gravel_layer -0.012; nether_state_selector 0.0; netherrack 0.54; nether_wart 1.17 | `nether.json` |

---

## 11. Open questions

1. **Noise primitives under the legacy factory.** Resolved. `NormalNoise.create` has no legacy branch; it builds one `PerlinNoise(factory.fromHashOf(octave name))` per octave (read). The `GradientNoise` constructor takes only a `RandomSource`: it draws `nextDouble() * 256.0` three times (offsets x, y, z), then shuffles the 256-entry permutation with `nextInt(256 - i)`. This is exactly 10 section 3.1, so a legacy source plugs in unchanged. The second octave stack of a `NormalNoise` has its input frequency multiplied by 1.0181268882175227 (read as `INPUT_FACTOR`). Nothing remains open.
2. **World seed for the Nether.** That the Nether `RandomState` receives the same numeric seed as the overworld (so `F` is derived from the same `worldSeed`) is inferred from one `RandomState.create(seed)` per level; the caller was not traced.
3. **`nextDouble` and the other primitives.** Resolved: all four definitions were read in `BitRandomSource` (section 2) and the reference values reproduce with exactly these definitions. Nothing remains open.
4. **Carving mask constructor.** Resolved: `CarvingMask(int, int)` takes (minY, maxY) and derives `height = maxY - minY + 1` (read in the constructor bytecode); `generateCarvers` passes `minGenY + 1` and `minGenY + genDepth - 1 - d` with `d` 7 or, for an upgrading chunk, 0 (section 6.4). The index formula was read from `getIndex`. Nothing remains open.
5. **Surface-pass y limits.** The column loop bounds `minY <= y <= maxY` come from `ChunkAccess.getHeightAccessorForGeneration()`; for the Nether chunk (height 256) these were not read separately. This does not change the result as the fill produces nothing above y 127 and the rule is only evaluated at solid blocks.
6. **A sentence in 37-1.** Closed. An earlier draft of this document disputed a sentence of 37-1 section 6.9 about the column above y 128; the current 37-1 text lists the rule order correctly and describes the netherrack cap and fallback, so no correction is owed. By the anchors of section 3 and the rule tree, no rule in this document writes above y 127. Whether the terrain fill reaches y 127 is 37-2's.
7. **Count of biome files in section 6.1.** "5 + 6 + 56 = 67" counts every JSON file under `worldgen/biome/` by its `carvers` field; the biome list itself belongs to 37-3 (and to 10 section 7.4 for the overworld). The five Nether biomes' `nether_cave` entry was read per biome.
8. **Expectation of the cave count.** Resolved: the sampling formula was read (section 6.1) and the mean 1.125 and `P(thickness > 1) = 0.9375` are exact consequences of it. Nothing remains open.
9. **Absent items of the brief.** The carver replaceable tag, the carve-next-to-liquid test, the carver debug state and the lava level -10 were searched for in `Carvers`, `CaveWorldCarver`, `WorldCarver`, `CanyonWorldCarver`, `NoiseBasedChunkGenerator`, the tag directory (`tags/block/*carver*`, `*replaceable*`) and the carver JSON; none exists. If another jar version carries them, this document needs a new round.
10. **Fluid behaviour after carving.** That carved lava is never scheduled for a fluid tick (section 6.4 item 4) follows from the disabled aquifer's `shouldScheduleFluidUpdate()` returning false and the guard in `applyCarvingMask`; what the first neighbour update then does is the fluid engine's ([29a-fluids.md](29a-fluids.md)).
11. **Biome in the surface-rule `biome` condition.** The biome is the fuzzy-zoomed biome at the block (10 section 7.7); it is constant along a column (section 4 item 5, read from the router's constant `depth` and the `y_scale` 0.0 of `temperature` and `vegetation`); the five biomes' parameter table is sibling 37-3's. Examples 5 to 8 assume the stated biome.
12. **Worked examples 9 to 11** use a hand implementation of the walker's first draws; the float rounding of `thickness` (`nextFloat()*4.0 + nextFloat()*2.0` in float arithmetic, per the order given in 11 section 4's trapezoid description) was not compared to a run.
13. **Sibling wording about lava.** Closed. 37-2 now describes lava as the generic, biome-independent `on_floor` rule and cites section 5 of this document; nothing is owed.
