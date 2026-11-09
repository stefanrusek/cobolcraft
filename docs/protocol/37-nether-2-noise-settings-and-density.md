# 37-2 The Nether: noise settings, density pipeline, legacy seeding, fill and lava level

| Item | Value |
|---|---|
| Covers | The terrain-shaping pipeline of the Nether (`minecraft:the_nether`, noise settings `minecraft:nether`): every field of the noise settings, the eight-entry noise router, the density tree of `final_density` (sloping gradients, the old blended 3D noise with the Nether parameters, the 0.64 factor, the 4 x 8 x 4 interpolation, `squeeze`), the **legacy random source** that this dimension turns on (it changes how the 3D noise and the two climate noises are seeded, and every named random of the surface pass), the fill without aquifers (lava below sea level 32), the climate wiring used for the biome lookup, the numeric bedrock floor and roof thresholds as an index, and worked values. |
| Does not cover | Data rows: the extraction tool copies `data/minecraft/worldgen/noise_settings`, `density_function`, `noise` and `material_rule` (22, 23); they are cited to show wiring. The node semantics, noise primitives and chunk stages shared with the overworld are in 10 and are not repeated; this document says what differs. The dimension type values and dimension-driven behaviours (bed_rule, respawn_anchor_works, fast_lava, ambient light, fog, monster_spawn_light_level and the rest: 37-nether-1 sections 2 and 3), the Nether biome parameter table (37-nether-3 section 2), the surface rules and carvers (37-nether-4 sections 5 and 6), features (37-nether-5 section 2) and structures and spawns (37-nether-6 sections 2 and 9) are cross-referenced by those section references. The structure terrain adaptation term (`beardifier`) is only hooked here (section 10). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the classes named in each section and of the JSON under `data/minecraft/` in the jar, with no execution of the artifact. Values marked "(computed)" were produced by applying this document's own text with a throwaway reference script written for the round (it uses 32-bit float rounding after every float operation); they are **not** observed from the artifact. |
| Round | RS21, part 2 (GAP-13a of [../design/README.md](../design/README.md)) |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engine (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"). Code-defined content is specified completely. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not verified)" a statement not read in this round; both are listed in the Open questions. Section references such as "10 section 4.2" are to documents of this directory. Float means IEEE single precision and double means IEEE double precision; to be vanilla-identical an implementation rounds to single precision at every step named float. The legacy generator is the Java-LCG of 10 section 2.6; its draw primitives are repeated in section 4.1 because this dimension depends on them.

---

## 1. Overview and differences from the overworld

The Nether is an ordinary noise-generated dimension: world preset `normal` (read from `worldgen/world_preset/normal.json`) maps `minecraft:the_nether` to dimension type `minecraft:the_nether`, generator `minecraft:noise`, noise settings `minecraft:nether` and the multi-noise biome source with preset `minecraft:nether`. Chunk stages are those of 10 section 11.1. What changes against the overworld pipeline of 10:

| Aspect | Overworld (10) | Nether (this document) |
|---|---|---|
| Column | y -64 to 319, cells 4 x 8 x 4 | **y 0 to 127** (noise settings `min_y 0`, `height 128`); cells 4 x 8 x 4; the dimension column itself is y 0 to 255 (section 3) |
| Random source | Xoroshiro128++ | **legacy LCG** for the blended 3D noise, the two climate noises and every named random (section 4) |
| Router | eight real functions | `continents`, `erosion`, `depth`, `ridges`, `chunk_surface_level` are the constant 0.0; only `temperature`, `vegetation`, `final_density` are non-trivial (section 2.2) |
| Density | spline-driven surface, caves, noodle | one 3D noise blended towards constants at the top and the bottom (section 5); no caves in the density, no noodle |
| Aquifer | noise aquifer | **none**: below y 32 every empty cell is lava (section 7) |
| Ore veins | in the material rule | none: the Nether material rule has no `ore_vein` rule (section 9) |
| Node types | the set of 10 section 4.2 | **no new node type**: the Nether uses `add`, `mul`, `lerp`, `gradient`, `squeeze`, `interpolated`, `blend_density`, `beardifier`, `noise`, `old_blended_noise` and constants, all in 10 section 4.2 (section 5.3 lists the exact formulas that matter, and one correction to 10 section 4.1, section 6.2) |

Names in the round brief that do not exist in this artifact: the `NoiseSettings` record has only `min_y` and `height` (no `size_horizontal` / `size_vertical`: the cell sizes come from the `interpolated` nodes, section 5.1); `NoiseGeneratorSettings` has no `aquifers_enabled` / `ore_veins_enabled` flags (an absent optional `aquifers` field means no aquifer, section 2.1) and `NoiseRouter` has eight entries, not the older fifteen (`barrier`, `fluid_level_floodedness`, `fluid_level_spread`, `lava`, `vein_toggle`, `vein_ridged`, `vein_gap`, `initial_density_without_jaggedness` do not exist; section 2.2).

---

## 2. Noise settings `minecraft:nether`

### 2.1 Fields (`NoiseGeneratorSettings.nether`, `worldgen/noise_settings/nether.json`)

The jar holds 7 files under `data/minecraft/worldgen/noise_settings/` (`overworld`, `large_biomes`, `amplified`, `nether`, `end`, `caves`, `floating_islands`; counted with `unzip -Z1 | grep -v '/$'`). The record's codec fields are `noise`, `default_block`, `default_fluid`, `noise_router`, `material_rule`, `spawn_target`, `sea_level`, `disable_mob_generation`, `aquifers` (optional), `legacy_random_source` and `debug_functions` (optional). The Nether values:

| Field | Value | Meaning here |
|---|---|---|
| `noise.min_y` / `noise.height` | 0 / 128 | the generated column is y 0 .. 127 (`NoiseSettings.NETHER_NOISE_SETTINGS`) |
| `default_block` | `minecraft:netherrack` | the block for a cell with density > 0 |
| `default_fluid` | `minecraft:lava` | the fluid of the sea-level fill (section 7) |
| `sea_level` | 32 | lava fills empty cells below y 32 |
| `aquifers` | absent | no aquifer: `Aquifer.createDisabled` (section 7) |
| `legacy_random_source` | true | section 4 |
| `disable_mob_generation` | false | |
| `spawn_target` | empty list | `getOrigin` falls back to the generic chunk-generator origin (not specified here) |
| `material_rule` | `minecraft:nether` | the surface rule (37-nether-4 section 5; the numeric bedrock part is section 9) |
| `noise_router` | section 2.2 | |
| `debug_functions` | three entries labelled `N` (= `final_density`), `T` (= `temperature`), `V` (= `vegetation`) | only for the debug overlay; has no effect on generation |

`NoiseSettings` validation (`guardY`, the codec ranges): `min_y` is an integer in `[-2032, 2031]` (`DimensionType.MIN_Y`, `MAX_Y`, derived in 10 section 5), `height` is in `[0, 4064]`, `min_y + height <= 2032`, and both are multiples of 16. `clampToHeightAccessor(accessor)` returns a settings pair `(max(min_y, accessor.minY), min(min_y + height, accessor.maxY + 1) - that)`; the chunk-building code (`buildTerrain`) uses the clamped pair and does nothing when its height is 0 or less. For the Nether, with the dimension column y 0 .. 255, the clamp returns `(0, 128)` unchanged.

Generator Y limits (`NoiseBasedChunkGenerator.getMinY / getGenDepth / getSeaLevel`) are the unclamped settings: min 0, depth 128, sea level 32. The vertical anchors of the material rule do not resolve against these directly: the context used (`WorldGenerationContext(ChunkGenerator, LevelHeightAccessor)`, built from `MaterialRuleContext`) takes `minGenY = max(accessor.minY, generator.getMinY())` and `genDepth = min(accessor.height, generator.getGenDepth())` (same form as 37-nether-4 section 3). For the Nether that is `max(0, 0) = 0` and `min(256, 128) = 128` (section 9).

`buildTerrain` also returns early when `SharedConstants.debugVoidTerrain(chunkPos)` is set (a debug switch, off in release), and it clamps the settings against `ChunkAccess.getHeightAccessorForGeneration`, not against the plain level accessor; for the Nether the result is the same `(0, 128)`. Besides `nether`, the only other noise settings built with `slideNetherLike` is `caves` (section 5.1). The rule itself is built by `NetherMaterialRules.NETHER` (section 9).

### 2.2 The noise router (`NoiseRouterData.nether`)

The router record has eight entries, in this order of its constructor: `temperature`, `vegetation`, `continents`, `erosion`, `depth`, `ridges`, `chunk_surface_level`, `final_density`. The Nether builds them as:

| Entry | Value |
|---|---|
| `temperature` | `noise` node: noise `minecraft:nether/temperature`, `xz_scale 0.25`, `y_scale 0.0`, both shifts the constant 0 (`DensityFunctions.shiftedNoise2d(zero, zero, 0.25, noise)`) |
| `vegetation` | the same with noise `minecraft:nether/vegetation` |
| `continents`, `erosion`, `depth`, `ridges` | the constant 0.0 (`DensityFunctions.zero`) |
| `chunk_surface_level` | the constant 0.0 (used by the surface pass condition `above_preliminary_surface` and by `minSurfaceLevel`, 10 section 10.2; the Nether rule uses neither, 37-nether-4 section 4) |
| `final_density` | `add( squeeze( interpolated[cell_size_xz 4, cell_size_y 8]( mul( blend_density( S ), 0.64 ) ) ), beardifier )` with `S` of section 5.1 |

The JSON sorts the entries alphabetically; the data file is the same tree (the jar's `nether.json` expresses `final_density` inline, with the reference `minecraft:nether/base_3d_noise` for the blended noise).

---

## 3. Dimension values (index only)

`data/minecraft/dimension_type/the_nether.json`, read for the facts this document depends on: `min_y 0`, `height 256`, `logical_height 128`, `coordinate_scale 8.0`, `has_ceiling true`, `has_skylight false`, `has_fixed_time true`, `ambient_light 0.1`, `has_ender_dragon_fight false`, `infiniburn #minecraft:infiniburn_nether`. The full table and the attribute map are in 37-nether-1 section 2 (its table lists `gameplay/bed_rule`, `fast_lava`, `respawn_anchor_works`, `visual/ambient_light_color #302821`, `monster_spawn_light_level` 7 and the others; confirmed present). Consequences for generation:

- The chunk has 16 sections (y 0 .. 255). Terrain exists only at y 0 .. 127 (sections 0 .. 7); sections 8 .. 15 stay air through generation, because the density sampler volume is `16 x 128 x 16` (`chunkVolume` uses the clamped `height`).
- `logical_height 128` is a gameplay limit (portals, chorus teleports); it does not change generation.

---

## 4. Random sources: what `legacy_random_source = true` changes

`RandomState.create` selects `WorldgenRandom$Algorithm.LEGACY` when the settings flag is true, creates `LegacyRandomSource(worldSeed)` and takes its positional factory as the master factory `P` (the Nether analogue of `RandomState.random`, 10 section 2.5). The density compile context (`RandomState$1`) adds two special cases that do not depend on the flag's value.

### 4.1 The legacy generator, restated for this dimension

`LegacyRandomSource(seed)`: the 48-bit LCG of 10 section 2.6: state `(seed xor 0x5DEECE66D) & (2^48 - 1)`; `next(bits)`: `state = (state * 0x5DEECE66D + 11) & (2^48 - 1)`, result `(int)(state >>> (48 - bits))` (a signed int; for `bits = 32` the top 32 bits of the state). The derived operations are the defaults of `BitRandomSource` (read here):

| Operation | Definition |
|---|---|
| `nextInt()` | `next(32)` |
| `nextInt(bound)` | if `bound` is a power of two: `(int)((bound * (long)next(31)) >> 31)`; otherwise loop: `bits = next(31)`, `val = bits mod bound`, accept `val` when `bits - val + (bound - 1)` (32-bit int arithmetic) is not negative, else draw again |
| `nextLong()` | `((long)next(32) << 32) + next(32)` (the second `next(32)` is signed and is **added**, so a negative second value borrows from the first) |
| `nextFloat()` | `next(24) * 5.9604645E-8f` (float multiplication) |
| `nextDouble()` | `a = next(26)`, `b = next(27)`, `(double)(((long)a << 27) + b) * 1.1102230246251565E-16` |
| `consumeCount(n)` (`RandomSource` default) | `n` calls of `nextInt()` (so `n` LCG steps) |
| `forkPositional()` | a legacy positional factory whose seed is `nextLong()` |

Legacy positional factory with seed `Fs` (`LegacyRandomSource$LegacyPositionalRandomFactory`):

| Method | Result |
|---|---|
| `at(x, y, z)` | `LegacyRandomSource(getSeed(x, y, z) xor Fs)` (`getSeed` of 10 section 2.4, then the full constructor, i.e. the scramble with `0x5DEECE66D`) |
| `fromHashOf(name)` | `LegacyRandomSource((long)hash(name) xor Fs)` where `hash` is the Java `String.hashCode` of the name: `h = 31 * h + c` over the UTF-16 code units, 32-bit wrapping, sign-extended to long when used. An identifier argument is converted to its string form first (`PositionalRandomFactory.fromHashOf(Identifier)` calls `Identifier.toString`, so the string is `minecraft:netherrack`, with the namespace) |
| `fromSeed(s)` | `LegacyRandomSource(s)` |

(The Xoroshiro factory hashes with MD5 and mixes; the legacy one hashes with `String.hashCode` and does not mix. A noise name therefore costs one cheap hash here.)

The perlin sampler `PerlinNoise(r)` is the same code for both generators (10 section 3.1): three `nextDouble() * 256.0` offset draws, then the 256-step shuffle with `nextInt(256 - i)`. With the legacy generator that is 6 `next()` calls for the offsets, plus at least one `next(31)` per shuffle step (exactly one for each power-of-two bound; non-power-of-two bounds may reject and draw again).

### 4.2 Table of consumers

| Consumer | Random used in the Nether |
|---|---|
| `old_blended_noise` (the 3D noise `minecraft:nether/base_3d_noise`, section 5.2) | `RandomState$1.createRandom(minecraft:terrain)`: when the flag is true and the requested identifier equals `BlendedNoise.NOISE_SEED` (`minecraft:terrain`) the result is `LegacyRandomSource(worldSeed + 0)`, i.e. the plain seed; every other identifier would use `P.fromHashOf(id)`. (Identical to the End, 38 section 3.) |
| `nether/temperature` climate noise (section 8) | `RandomState$1.createNoiseSampler`: for the noise key `minecraft:nether/temperature` a **dedicated legacy construction** (section 4.3) from `LegacyRandomSource(worldSeed + 0)` |
| `nether/vegetation` climate noise | the same construction from `LegacyRandomSource(worldSeed + 1)` |
| every other named normal noise (`RandomState.getOrCreateNoise`: surface-rule noises such as `netherrack`, `nether_wart`, `nether_state_selector`, `patch`, `soul_sand_layer`, `gravel_layer`; feature noises) | the standard `NormalNoise.create` of 10 section 3.3 fed with `P.fromHashOf("minecraft:<name>")`, where `P` is the legacy master factory: `P = LegacyRandomSource(worldSeed).forkPositional()` (`Fs = nextLong()` of that fresh source) |
| named positional factories (`RandomState.getOrCreateRandomFactory(id)`, used by the `vertical_gradient` condition: `minecraft:bedrock_floor`, `minecraft:bedrock_roof`) | `P.fromHashOf(id).forkPositional()`: the legacy source `LegacyRandomSource(hash(id) xor Fs)`, then `forkPositional` of it (its first `nextLong()` becomes the new factory's seed); the per-position random is `.at(x, y, z)` of that factory, and the condition draws one `nextFloat()` |
| surface depth (`R = P.at(x, 0, z)`, 10 section 10.3) | `LegacyRandomSource(getSeed(x, 0, z) xor Fs)`, then `nextDouble()` |

`createEndIslandRandom` is the End's (38 section 4.3) and is not used here. The Nether has no aquifer random.

### 4.3 The legacy Nether-biome noise (`NormalNoise.createForLegacyNetherBiome`, `LegacyFbmInitializer.createForLegacyNetherBiome`)

Applies to the two noises `nether/temperature` and `nether/vegetation`. Their JSON (`worldgen/noise/nether/temperature.json`, `vegetation.json`) is identical: `base_octave -7`, `octave_count 2`, `base_amplitude 0.9494731054427981`, no `amplitude_modifiers` (every modifier 1.0), no `normalize` (default `enabled`, read from the codec's `optionalFieldOf` default). The construction differs from 10 section 3.3 in the **order the perlin samplers are created and in the random sequence they consume**. Inputs: the random `r` (`LegacyRandomSource(seed')`, `seed' = worldSeed + 0` or `worldSeed + 1`), `base_octave = -7`, the modifier list `m` (its length `n = 2`, filled with 1.0 when the JSON list is empty), `k = -base_octave = 7`.

**Stack construction** (performed twice in a row from the same `r`, giving stack 1 and stack 2):

1. Create one perlin sampler `p0 = PerlinNoise(r)` first (this always happens). If `0 <= k < n` and `m[k] != 0`, `p0` becomes the sampler of octave slot `k`; otherwise it is discarded (for the Nether `k = 7 >= n = 2`, so it is **discarded**, but its draws were consumed).
2. For slot `i = k - 1` down to `0`: if `i < n` and `m[i] != 0`, create `PerlinNoise(r)` for slot `i`; otherwise (`i >= n`, or `m[i] == 0`) call `r.consumeCount(262)`, which advances the generator by exactly 262 LCG steps and creates nothing. For the Nether: `i = 6, 5, 4, 3, 2` skip 262 steps each (5 x 262 = 1310 steps); then `i = 1` creates the sampler of slot 1; then `i = 0` creates the sampler of slot 0. **The high slots are created first**, so slot 1 is drawn before slot 0.
3. The number of created samplers must equal the number of non-zero modifiers (else an error; not an issue for the Nether). If `k < n - 1` an error ("positive octaves are temporarily disabled") is thrown; not an issue here.
4. The stack's layers, in slot order `i = 0 .. n - 1`, skipping empty slots: starting with `freq = 2^(-k)` (double, `Math.pow`) and `amp = 2^(n-1) / (2^n - 1)` (double: `2/3` for `n = 2`): layer `(sampler_i, frequency = freq, amplitude = (float)(amp * m[i]))`; after each slot (also an empty one) `freq = freq * 2` and `amp = amp / 2`.

For the Nether this gives, for each stack, layer 0 = (slot 0 sampler, frequency 2^-7 = 0.0078125, amplitude `(float)(2/3)`) and layer 1 = (slot 1 sampler, frequency 2^-6 = 0.015625, amplitude `(float)(1/3)`).

**Combination.** `nf` is the normalisation factor of 10 section 3.3 computed for the JSON parameters (octave list from `buildOctaves`: two octaves, octave 0 with amplitude `0.9494731054427981 * 2^(n-1)/(2^n-1) = 0.6329820702951987`, octave 1 with half of it; `dev = sqrt(sum((0.2702247831245211 * amp_j)^2))`, `nf = (sum * 0.3333333333333333) / (dev * sqrt(2))`; result `nf = 1.1702396884564004`, the same value 10 section 3.6 lists for the other two-octave noise files). Let `a = (float)(nf * base_amplitude)` = `1.1111111640930176` (float of 10/9). The final sampler is a flat `NoiseStack` whose layers are, in this order:

| Layer | Sampler | Frequency | Amplitude |
|---|---|---|---|
| 1 | stack 1, layer 0 | `2^-7` | `(float)(2/3) * a` (float product) |
| 2 | stack 1, layer 1 | `2^-6` | `(float)(1/3) * a` |
| 3 | stack 2, layer 0 | `2^-7 * 1.0181268882175227` | `(float)(2/3) * a` |
| 4 | stack 2, layer 1 | `2^-6 * 1.0181268882175227` | `(float)(1/3) * a` |

(`NoiseStack$Builder.addStack` multiplies the frequencies as doubles and the amplitudes as floats and flattens; the same float products of 10 section 3.2 then apply.) Evaluation is 10 section 3.2: `acc = 0f; acc = acc + amp * sampler.get(x * freq, y * freq, z * freq)` per layer in the order above.

Difference to the standard `NormalNoise.create` (10 section 3.3): the standard one derives each octave's sampler from `fromHashOf("octave_<index>")` of two forked positional factories, so octaves are independent of each other; the legacy construction draws **all samplers from one continuing sequence**, so changing the number of slots or skipping one shifts every later sampler. Values (computed) in section 12.1.

### 4.4 Other named noises in the Nether (standard construction, legacy factory)

The standard construction of 10 section 3.3 with the legacy master factory: `r = P.fromHashOf("minecraft:<name>")` is a `LegacyRandomSource`; `A = r.forkPositional()`, `B = r.forkPositional()` are two legacy positional factories whose seeds are the next two `nextLong()` values of `r`; octave sampler `A.fromHashOf("octave_<index>")` is `LegacyRandomSource(hash("octave_<index>") xor A.seed)`, and likewise for `B`. Layer amplitude and frequency rules are unchanged. Examples (computed) in section 12.2.

### 4.5 Seeds and the biome zoom seed

The biome zoom seed (`obfuscateSeed(worldSeed)`, 10 section 7.7) does not depend on the flag. The world seed enters this section only through `LegacyRandomSource(worldSeed + c)`, `c` = 0 (terrain, temperature), 1 (vegetation), and through `P`.

---

## 5. The density tree of `final_density`

### 5.1 Structure (`slideNetherLike(base_3d_noise_nether, 0, 128)`, `postProcess(.., 4, 8)`)

```
final_density = add( squeeze( interpolated[4, 8]( mul( blend_density( S ), 0.64 ) ) ), beardifier )

S = lerp( alpha = gradient_y(from y -8, value 0.0  ->  to y 24, value 1.0),
          first  = 2.5,
          second = lerp( alpha  = gradient_y(from y 104, value 1.0  ->  to y 128, value 0.0),
                         first  = 0.9375,
                         second = nether/base_3d_noise ) )
```

The numbers come from `NoiseRouterData.slideNetherLike(functions, minY, height)`: it calls `slide(df, minY, height, 24, 0, 0.9375, -8, 24, 2.5)`, whose parameters are `topStart = 24`, `topEnd = 0` (the top blend runs from `minY + height - 24` to `minY + height - 0`, value 1 at the lower end and 0 at the upper end; first value `0.9375`) and `bottomStart = -8`, `bottomEnd = 24` (the bottom blend runs from `minY - 8` to `minY + 24`, value 0 at the lower end and 1 at the upper end; first value `2.5`). The call `slideNetherLike(.., 0, 128)` gives the anchors 104 / 128 and -8 / 24. (The same helper with `minY -64`, `height 192` builds the `caves` noise settings; with different arguments the End and the overworld use `slide`; those are not used by the Nether.) `postProcess(df, 4, 8)` is `squeeze(interpolated(mul(blend_density(df), 0.64), 4, 8))`; `0.64` is the float constant `0.64f`.

Cells: `interpolated` has `cell_size_xz 4` and `cell_size_y 8` (the JSON fields). They are the only source of the cell sizes. Section 6 gives the grid.

### 5.2 `minecraft:nether/base_3d_noise` (`worldgen/density_function/nether/base_3d_noise.json`)

A single `old_blended_noise` node (10 section 3.4) with parameters:

| `xz_scale` | `y_scale` | `xz_factor` | `y_factor` | `smear_scale_multiplier` |
|---|---|---|---|---|
| 0.25 | 0.375 | 80.0 | 60.0 | 8.0 |

(The overworld's differ in `y_scale 0.125` and `y_factor 160.0`; the End's file is read in 38 section 4.4.) Constants of the node (10 section 3.4: base 684.412, limit factor 0.9999847412109375, main factor 12.75, limit first octave -15, main first octave -7), derived for the Nether:

| Quantity | Value |
|---|---|
| `xzMul = 684.412 * xz_scale` | 171.103 |
| `yMul = 684.412 * y_scale` | 256.6545 |
| `smear = yMul * smear_scale_multiplier` | 2053.236 |
| min / max limit stacks | `fbm(r, -15, smear, 0.9999847412109375)`, twice |
| main stack | `fbm(r, -7, smear / y_factor = 34.2206, 12.75)` |
| limit coordinates | `(x * 171.103, y * 256.6545, z * 171.103)` |
| main coordinates | `(x * 171.103 / 80, y * 256.6545 / 60, z * 171.103 / 80)` = `(2.1387875 x, 4.277575 y, 2.1387875 z)` |

The three stacks are built from one `r = LegacyRandomSource(worldSeed)` in the order min limit (16 smeared samplers), max limit (16), main (8), each sampler constructed with the perlin draws of 4.1; the sampler objects are `SmearedPerlinNoise(r, smear_layer)` where `smear_layer = stack smear scale * layer frequency` (10 section 3.4). The smear branch of 10 section 3.4 step 1 is **conditional**: `SmearedPerlinNoise.computeFudgeY(rawY, yFrac)` uses `base = rawY` only when `0 <= rawY < yFrac`, where `yFrac` is the fractional part of (wrapped y plus the sampler's random y offset); otherwise `base = yFrac`. For the layer of frequency `2^-15`, `rawY = y * 256.6545 * 2^-15` lies in [0, 0.995] for y in 0 .. 127, so whether it is below `yFrac` depends on the fractional part of that sampler's random y offset (a per-seed value, not a constant); layers of higher frequency have `rawY >= 1` over most of the range and take the other branch. The fudge scale of that layer is `2053.236 * 2^-15 = 0.06266` (computed from the stated constants). The formula is applied exactly as 10 section 3.4 gives it; there is no Nether-specific branch.

Evaluation of the node at a position is 10 section 3.4 step 4 (`t = clamp(main + 0.5f, 0, 1)`, result `lerp(t, lo, hi)`, with the lazy shortcut for `t == 0` and `t == 1`).

### 5.3 Node semantics used (formulas read, to be applied with 10 section 4.2)

| Node | Formula (float) | Read from |
|---|---|---|
| `gradient` (axis `y`, tiling clamp) | `factor = (to_value - from_value) / (float)(to_coordinate - from_coordinate)`; `c = clamp(y, min(from_c, to_c), max(from_c, to_c))` (integer clamp); result `from_value + (float)(c - from_coordinate) * factor` (float multiply, then float add). The data requires `from_coordinate != to_coordinate`. | `GradientFunction`, `GradientFunction$ClampedSampler.compute` |
| `lerp` with constant first (`first` is 2.5 or 0.9375) | `a = alpha`; if `a == 0` return `first`; if `a == 1` return `second` (point sampler only: the second child is evaluated lazily; the volume sampler of 6.1 evaluates it eagerly for every corner and then picks per alpha, with identical values); else `Mth.lerp(a, first, second) = first + a * (second - first)` (float) | `LerpFunction$ConstFirstSampler` (`sampleValue` and `sampleVolume`), `Mth.lerp(float, float, float)` |
| `mul(x, constant)` | `x * constant` | `BinaryFunction$ConstMulSampler` |
| `squeeze` | `c = clamp(v, -1.0f, 1.0f)`; result `c / 2.0f - (c * c * c) / 24.0f` (float; `Mth.cube(c)` = `c * c * c`); range of the result [-0.4583333, 0.4583333], value at `c = 1` is `0.5 - 1/24` | `UnaryFunction$SqueezeSampler.apply` |
| `blend_density` | identity when the sampler context carries no blender or an empty blender (fresh world; section 6.4) | `BlendDensityFunction$Sampler` |
| `interpolated` | section 6 | `InterpolatedFunction$Sampler` |
| `beardifier` | section 10 | |
| `noise` (climate) | `Noise.get(x * xz_scale + shift_x, y * y_scale + shift_y, z * xz_scale + shift_z)` with the three scales as doubles; when both shifts are the constant 0 the compile step drops them and uses the plain form `noise.get(x * xz_scale, y * y_scale, z * xz_scale)` (so `y_scale 0.0` gives a y argument of 0.0, or -0.0 for a negative y, with no effect on the noise) | `NoiseFunction.compileSampler`, `NoiseFunction$Sampler` |

### 5.4 Closed form of the corner values

Writing `N` for the blended noise at a corner and `gt(y)`, `gb(y)` for the two gradient values (`gt` is 1 at `y <= 104`, falls linearly to 0 at `y = 128`, so `gt(y) = (128 - y) / 24` for `104 <= y <= 128`; `gb(y) = (y + 8) / 32` for `-8 <= y <= 24`, 1 above), the corner value that is interpolated is `0.64 * S` with:

| Corner y (multiples of 8) | `S` | Corner value `0.64 * S` | Corner is solid (> 0) when |
|---|---|---|---|
| 0 | `lerp(0.25, 2.5, N) = 1.875 + 0.25 N` | `1.2 + 0.16 N` | `N > -7.5` |
| 8 | `lerp(0.5, 2.5, N) = 1.25 + 0.5 N` | `0.8 + 0.32 N` | `N > -2.5` |
| 16 | `lerp(0.75, 2.5, N) = 0.625 + 0.75 N` | `0.4 + 0.48 N` | `N > -0.8333` |
| 24 .. 104 | `N` | `0.64 N` | `N > 0` |
| 112 | `0.9375 + (2/3)(N - 0.9375) = 0.3125 + 0.6667 N` | `0.2 + 0.42667 N` | `N > -0.46875` |
| 120 | `0.9375 + (1/3)(N - 0.9375) = 0.625 + 0.3333 N` | `0.4 + 0.21333 N` | `N > -1.875` |
| 128 | `0.9375` (alpha 0: first value; `N` is discarded, and not evaluated by the point sampler, 6.1) | `0.6` (float `0.9375f * 0.64f` = 0.59999996) | always |

(computed from the node semantics above; the squeeze is applied **after** the interpolation, section 6, so the table is about corner values, not about blocks.) Consequences: the floor is solid for any realistic noise value near y 0 (a block row at y 0 saturates the squeeze at +0.4583 whenever `N > -1.25`); the roof is solid for `N > -0.47` at the y 112 corner and for almost any `N` above; the free space of the Nether is (inferred from the table) the band between about y 24 and y 112 where the sign of the noise decides, and every empty cell below y 32 becomes lava (section 7). The noise `N` is the unscaled blended-noise value of 5.2. Its declared range is read: `BlendedNoise.range()` is `computeFbmRange(-15, smear, 0.9999847412109375)` with `smear = 2053.236`, i.e. the sum over the 16 layers `j = 0 .. 15` of `(smear * 2^-j + 2) * amp_j` with `amp_j = 0.9999847412109375 * 2^j / 65535` (each layer's range is `|fudge| + 2`, `SmearedPerlinNoise.range`). It is symmetric: `0.9999847412109375 * (16 * 2053.236 / 65535 + 2) = 2.5012478` (computed), so `N` lies in about [-2.5012, +2.5012]. Consequences for the corner table: the y 0 corner (`N > -7.5`) is always solid, the y 8 corner (`N > -2.5`) is solid for any `N` within the declared range (the margin is 0.0012), and the y 128 corner is always solid; the rows where noise can open space are y 16 (`N > -0.8333`), 24 .. 104, y 112 (`N > -0.46875`) and y 120 (`N > -1.875`). The declared range is a bound, not an observed extreme.

---

## 6. Interpolation and fill at height 128

### 6.1 Grid for one chunk

The terrain volume is `DensityVolume(16, 128, 16)` anchored at `(chunkMinX, 0, chunkMinZ)` with block step 1 (`NoiseBasedChunkGenerator.chunkVolume`). For an `interpolated[4, 8]` node the engine builds a corner volume with cell edges at world multiples of 4 (x, z) and 8 (y): the corner columns are `x0, x0 + 4, .., x0 + 16` (5 positions) and the same for z; the corner rows are `y = 0, 8, .., 128` (17 rows, **including y = 128**, one row above the highest block, because the number of corners is the number of cells plus one when the volume's max block is not a cell multiple: `floorMod(127, 8) != 0` and `floorMod(15, 4) != 0`). The input of the node (`mul(blend_density(S), 0.64)`) is evaluated once per corner: 5 x 17 x 5 = 425 corner evaluations per chunk, each costing one blended noise value (up to 40 perlin samples, section 5.2; fewer when the lazy `lerp` of the limit noises stops at `t == 0` or `t == 1`). The chunk path samples the 5 x 17 x 5 corner volume with `LerpFunction$ConstFirstSampler.sampleVolume` (read), which evaluates both children over the whole volume, so the blended noise **is** evaluated at the y = 128 row too (its alpha is 0 there, so the result is the first value `0.9375` and the noise value is discarded); only the point sampler (`sampleValue`) skips the second child when alpha is 0 or 1. Values are identical either way; only the cost differs.

`InterpolatedFunction$Sampler.sampleVolume` first chooses among branches: a pass-through that samples the input directly with no interpolation (the review found that it applies when the volume's block step already equals the cell sizes or its size is 1 and the min corner is cell-aligned; its exact condition was not re-read in this round, Open question 12), `sampleWithNonBlockStep`, and `sampleWithBlockStep`. The chunk fill (volume 16 x 128 x 16, step 1) and the 1 x 128 x 1 column volume of 6.5 do not take the pass-through.

### 6.2 The fill interpolation (the production path) and a correction to 10 section 4.1

For a block-step volume (the chunk fill and the column queries of section 6.5) `InterpolatedFunction$Sampler.sampleWithBlockStep` / `fillCell` interpolate each cell in this order, with the eight corner values `c(a, b, d)` (`a` = x index 0/1, `b` = y index 0/1, `d` = z index 0/1), the cell-relative block offsets `dx, dz` in 0..3 and `dy` in 0..7, `fx = (float)dx * 0.25f`, `fz = (float)dz * 0.25f` (multiplication by the float reciprocal `1/4`, exact):

1. Along **z** first (four values, float `Mth.lerp`): `u00 = lerp(fz, c(0,0,0), c(0,0,1))`, `u01 = lerp(fz, c(0,1,0), c(0,1,1))`, `u10 = lerp(fz, c(1,0,0), c(1,0,1))`, `u11 = lerp(fz, c(1,1,0), c(1,1,1))` (the first index of `u` is x, the second y).
2. Along **x**: `p0 = lerp(fx, u00, u10)` (lower y corner row), `p1 = lerp(fx, u01, u11)` (upper row).
3. Along **y** by a **per-block increment**: `step = (p1 - p0) * 0.125f` (float, `0.125f` is `1/8`); the value at offset `dy` is obtained by starting at `p0 + step * (float)dy0` (`dy0` = the first y offset written for this cell, 0 for a full cell) and **adding `step` once per block** going up (`v = v + step`, float, one rounding per block), not by evaluating `p0 + step * dy` for each block.

The `squeeze` of the router is applied to every interpolated value afterwards (element by element), then `beardifier` is added (section 10).

This differs from 10 section 4.1, which states the point-sample `lerp3` in the order x, then y, then z for **every** use of `interpolated`. The point sampler (`InterpolatedFunction$Sampler.sampleValue`: used for single-position queries, e.g. the debug overlay) does follow 10 section 4.1: it returns the input directly when `floorMod` of all three coordinates is 0 and otherwise does the eight-corner trilinear lerp. The block-step volume path is the one `doFill` uses (it reads its values from `sampleVolume`). The two differ by float rounding only: in the reference script (computed) the largest difference over a 128-block column is 9e-8 and no block changes sign in the three columns tried (section 12.4). An implementation that wants bit-identical results uses the order of this section for fills. The same applies to the overworld; 10 is not edited by this document (Open question 1).

### 6.3 Which blocks are solid

A block is solid iff the interpolated, squeezed, beardifier-added value is strictly greater than 0 (the disabled aquifer's `computeSubstance`, section 7). With no structure nearby the beardifier is 0, and then `squeeze(v) > 0` iff `v > 0` (`squeeze` is odd and strictly increasing on [-1, 1] and saturates outside it). The block value is therefore determined by the sign of the interpolated corner values.

### 6.4 Blending

`blend_density` returns its input unchanged unless the sampler context holds a non-empty `Blender` (`Blender.CONTEXT_KEY`). A freshly created chunk next to no legacy-format chunk has none. Blending of chunks that come from an older game version is not specified (Open question 3).

### 6.5 Column queries (`getBaseHeight`, `getBaseColumn`)

`iterateNoiseColumn(x, z, predicate)` builds a one-column volume (`1 x height x 1`, anchored at `(x, minY, z)`), samples `final_density` through the same interpolation, and walks from the top block down; for each y it takes `computeSubstance` of the (disabled) aquifer, replaces a null result by the default block, and returns `y + 1` for the first block that satisfies the heightmap predicate. `getBaseHeight(x, z, type)` uses the predicate of the heightmap type (`Heightmap$Types.isOpaque`) and returns `minY` of the height accessor when nothing matches; `getBaseColumn` returns the block array of the column. Because the Nether's top rows are solid, the base height of every opaque heightmap at a column is about 128 (the roof), not the height of a cavern floor. No surface rule, bedrock rule, carver or structure is applied in this path.

---

## 7. The sea-level fill: lava and no aquifer

`NoiseChunk` creates the aquifer from the settings' `aquifers` field; for the Nether the field is absent, so it uses `Aquifer.createDisabled(fluidPicker)`. The fluid picker is the generator's global one (`NoiseBasedChunkGenerator.createFluidPicker`):

- two fluid statuses: a **sea** status `(level = sea_level = 32, fluid = default_fluid = lava)` and a **deep** status `(level = -54, fluid = lava)` (the constant -54 is in the code; it is part of the generator's global picker, not of the Nether settings);
- `computeFluid(x, y, z)`: if `y < min(-54, sea_level)` return the deep status, otherwise the sea status. For the Nether `min(-54, 32) = -54` and the column starts at 0, so **every position uses the sea status**;
- a debug switch (`SharedConstants.DEBUG_DISABLE_FLUID_GENERATION`) returns an air status (level `2 * DimensionType.MIN_Y`, air) instead; it is off in release.

A status answers `at(y)`: the fluid block if `y < level`, else air. The disabled aquifer's `computeSubstance(x, y, z, density)`:

1. if `density > 0` return "none" (the fill then places the default block, netherrack);
2. otherwise return `status.at(y)` for the status of `computeFluid(x, y, z)`: **lava for `y <= 31`, air for `y >= 32`**.

`shouldScheduleFluidUpdate` is false, so no lava position is queued for a post-generation fluid tick (contrast the overworld aquifer, 10 section 9). The fill loop is 10 section 8.1 with `y` from 127 down to 0; for a block it sets the state, updates the two heightmaps (`WORLD_SURFACE_WG` takes lava as non-air, `OCEAN_FLOOR_WG` does not, 10 section 8.1) and skips air.

Lava surface rule note: the material rule can also place lava itself, separately from this fill. In `material_rule/nether.json` this is a **generic, biome-independent** rule inside a top-level `on_floor` branch of the sequence, after the `basalt_deltas` and `soul_sand_valley` biome branches and before the `nether_wastes` branch: if `y` is not above absolute 32 (`y_above`, `add_stone_depth false`, so `y <= 31`) and the `hole` condition holds, the block becomes lava. The same `on_floor` branch also holds the warped and crimson forest nylium and wart rules (both are wrapped in `not(noise_threshold netherrack, min 0.54, max +infinity)`: netherrack noise **below** 0.54 enters the `y_above` absolute 31 test and the wart/nylium choice, noise at or above 0.54 is excluded and falls through to the later branches; wart noise at least 1.17 gives wart block, else nylium). Full tree: 37-nether-4 section 5.

---

## 8. Climate wiring for the biome lookup

The Nether biome source is `multi_noise` with `preset: "minecraft:nether"` (`worldgen/multi_noise_biome_source_parameter_list/nether.json`; the parameter table is 37-nether-3 section 2). It uses the router's climate entries (`NoiseRouter.createClimateSampler`: the six sampler entries in the order temperature, vegetation, continents, erosion, depth, ridges), sampled per 10 section 7.1: at the block position `(4 qx, 4 qy, 4 qz)` of a quart cell, each value quantised as `(long)(v * 10000.0f)`.

| Climate parameter | Nether value at quart `(qx, qy, qz)`, block `(x, z) = (4 qx, 4 qz)` |
|---|---|
| temperature | `Ntemp.get(0.25 x, 0, 0.25 z)` = `Ntemp.get(qx, 0, qz)` (y_scale 0, so **independent of y**), `Ntemp` the legacy construction of 4.3 with seed `worldSeed + 0` |
| humidity (`vegetation`) | the same with `nether/vegetation`, seed `worldSeed + 1` |
| continentalness, erosion, depth, weirdness (`ridges`) | the constant 0.0, quantised 0 |

The horizontal noise coordinates are the **quart coordinates themselves**, because `x * 0.25 = qx` exactly at `x = 4 qx`; the noise frequencies of 4.3 (`2^-7`, `2^-6`) are therefore per quart. The amplitude of the combined climate noise is about `a * (2/3 + 1/3) * 2 = 2.22` times the amplitude of one perlin sample, (the examples of section 12.1 lie in (-0.7, 0.5); the bounds were not read, Open question 7). Biome selection from these values is 37-nether-3 section 4.

---

## 9. Bedrock floor, bedrock roof and the netherrack cap (index of the numbers)

The jar's `material_rule/nether.json` is a sequence whose first three entries are, in order: `minecraft:bedrock_floor`, `minecraft:bedrock_roof`, a `y_above` rule that makes netherrack, followed by the biome and floor rules (37-nether-4 section 5): the `basalt_deltas` branch, the `soul_sand_valley` branch, the generic `on_floor` branch (lava for `y <= 31` where `hole` holds, then the forest nylium/wart rules), the `nether_wastes` branch, and as the **final unconditional fallback a `block` rule giving netherrack**. Because the netherrack cap precedes every biome rule, it wins for `y >= 122` (the fallback only matters below y 122 where no earlier rule matched). There is no `ore_vein` rule (the Nether has no ore-vein terrain pass). The rule tree is built by `NetherMaterialRules.NETHER` (`net.minecraft.data.worldgen.material`). Vertical anchors resolve against the generation context (`VerticalAnchor$AboveBottom.resolveY = minGenY + n`, `VerticalAnchor$BelowTop.resolveY = genDepth - 1 + minGenY - n`, `MaterialRuleContext.resolveAnchorY`), where `minGenY = max(accessor.minY, generator.getMinY())` and `genDepth = min(accessor.height, generator.getGenDepth())` (2.1; 37-nether-4 section 3); here `minGenY = 0`, `genDepth = 128`: `above_bottom n` is `n`, `below_top n` is `127 - n`.

| Rule | Definition read | Resolved |
|---|---|---|
| `bedrock_floor` | condition `vertical_gradient`: `true_at_and_below = above_bottom 0`, `false_at_and_above = above_bottom 5`, `random_name = minecraft:bedrock_floor`; then the block `bedrock` | gradient true for `y <= 0`, false for `y >= 5` |
| `bedrock_roof` | condition `not(vertical_gradient)` with `true_at_and_below = below_top 5`, `false_at_and_above = below_top 0`, `random_name = minecraft:bedrock_roof`; then `bedrock` | gradient true for `y <= 122`, false for `y >= 127`; the rule places bedrock where the gradient is **false** |
| netherrack cap | `y_above` with `anchor below_top 5`, `surface_depth_multiplier 0`, `add_stone_depth false`, result `netherrack` | `y >= 122`: every block y 122 .. 127 that reaches this rule becomes netherrack, ahead of any biome rule |

The `vertical_gradient` condition (the engine is in 10 section 10.4): if `y <= true_at_and_below` true; if `y >= false_at_and_above` false; otherwise `t = map(y, trueAt, falseAt, 1.0, 0.0)` (linear: `1 - (y - trueAt) / (falseAt - trueAt)`) and the condition is true iff `F.at(x, y, z).nextFloat() < t` (a float converted to double compared with the double `t`), where `F = P.fromHashOf(random_name).forkPositional()` (section 4.2 for the legacy `P`).

Probability of bedrock by layer (derived from the above; the actual blocks follow the random draws):

| y | Floor: gradient true probability `t` = P(bedrock) | y | Roof: gradient true probability `t`, P(bedrock) = `1 - t` |
|---|---|---|---|
| 0 | 1 (always bedrock) | 122 and below | `t = 1`, no bedrock |
| 1 | 0.8 | 123 | `t = 0.8`, P = 0.2 |
| 2 | 0.6 | 124 | `t = 0.6`, P = 0.4 |
| 3 | 0.4 | 125 | `t = 0.4`, P = 0.6 |
| 4 | 0.2 | 126 | `t = 0.2`, P = 0.8 |
| 5 and above | 0 | 127 | `t = 0`, always bedrock |

The roof is the mirror image of the floor in y (floor y `k` has the probability of roof y `127 - k`, aside from the different random streams). The rules run for every non-air, non-fluid block of the column (10 section 10.1 step 6), so the top block of the terrain (y 127) is always bedrock and the bottom row (y 0) always bedrock. Examples (computed) in section 12.5.

---

## 10. Hook: the beardifier in the Nether

`beardifier` is 0 unless structures with terrain adaptation start near the chunk (10 section 11.2). The Nether structure files read (`worldgen/structure/*.json`): `fortress` and `ruined_portal_nether` have no `terrain_adaptation` key; `bastion_remnant` (a jigsaw structure) has none either; `nether_fossil` has `"terrain_adaptation": "beard_thin"`. The value `beard_thin` is the structure's own adaptation mode; the term's formula (and whether jigsaw junctions of the bastion contribute) is the structure engine's, not read here (Open question 2). Fortress and ruined portals do not modify the density.

---

## 11. Noise definitions used by the Nether (index)

| File (`data/minecraft/worldgen/noise/`) | Parameters | Used by |
|---|---|---|
| `nether/temperature.json` | `base_octave -7`, `octave_count 2`, `base_amplitude 0.9494731054427981` | the router `temperature`, via 4.3 |
| `nether/vegetation.json` | the same | the router `vegetation`, via 4.3 |
| `netherrack.json` | `base_octave -3`, 4 octaves, `base_amplitude 1.4659491761370222`, modifiers [1, 0, 0, 0.35] | the nether material rule (netherrack threshold 0.54, warped and crimson forests), 4.4 |
| `nether_wart.json` | `-3`, 4, `1.3827102115748344`, [1, 0, 0, 0.9] | wart block threshold 1.17 |
| `nether_state_selector.json` | `-4`, 1 octave, `0.955388882960065` | basalt / blackstone and soul sand / soul soil choice |
| `patch.json`, `soul_sand_layer.json`, `gravel_layer.json` | see 10 section 3.6 | the nether material rule |

The other noise files of 10 section 3.6 are overworld or End consumers. The jar has exactly 2 files under `worldgen/noise/nether/` and no `_large` or amplified variant of the Nether noises (`temperature_large`, `vegetation_large` are the overworld's), 1 file under `worldgen/density_function/nether/` (`base_3d_noise.json`) and 1 file `worldgen/material_rule/nether.json` (counts with `unzip -Z1 | grep -v '/$'`). The density function registry does not hold the Nether's `final_density` as a separate file: it is built inline in `nether.json` and by `NoiseRouterData.nether` (the same tree).

---

## 12. Worked examples (computed with a reference script; not observed from the artifact)

### 12.1 Legacy Nether-biome noise, seed 0 and 12345

Layer table of 4.3 (identical for both seeds and both noises): `nf = 1.1702396884564004`, `a = 1.1111111640930176`; layers (frequency, amplitude): (0.0078125, 0.7407407760620117), (0.015625, 0.37037038803100586), (0.007954116314199396, 0.7407407760620117), (0.015908232628398793, 0.37037038803100586).

Sampled at quart cells (noise argument = quart coordinates, y argument 0), the quantised value is `(long)(v * 10000.0f)`:

| World seed | Quart `(qx, qz)` | temperature | quantised T | humidity | quantised H |
|---|---|---|---|---|---|
| 0 | (0, 0) | 0.11738119 | 1173 | -0.04563980 | -456 |
| 0 | (1, 0) | 0.12658289 | 1265 | -0.03776854 | -377 |
| 0 | (16, 16) | 0.28345785 | 2834 | 0.05019493 | 501 |
| 0 | (-25, 40) | 0.17457777 | 1745 | -0.33932492 | -3393 |
| 0 | (100, -100) | -0.10093555 | -1009 | -0.68186665 | -6818 |
| 12345 | (0, 0) | 0.06201173 | 620 | -0.09361492 | -936 |
| 12345 | (16, 16) | 0.17012885 | 1701 | 0.07248280 | 724 |
| 12345 | (100, -100) | -0.13491207 | -1349 | 0.47298706 | 4729 |

(The temperature uses the generator seeded with `worldSeed`, the humidity the one seeded with `worldSeed + 1`.)

Generator self-checks (computed): `LegacyRandomSource(0)` produces `nextInt()` values -1155484576, -723955400, then `nextLong()` 4437113781045784766 and `nextDouble()` 0.6374174253501083 for the following draws; `String.hashCode("minecraft:terrain") = 1657813608`; `getSeed(1, 2, 3) = -33674130277896` (matches 10 section 2.7).

### 12.2 Standard named noises under the legacy master factory, seed 0

`P = LegacyRandomSource(0).forkPositional()` has `Fs = -4962768465676381896`. For noise `minecraft:netherrack`: `hash = 303935260`, `r` seed state `198299045337161` (`(hash xor Fs)` then the constructor scramble `(seed xor 0x5DEECE66D) and (2^48 - 1)`; recomputed in this fix round); layers (frequency, amplitude): (0.125, 0.7111111283), (0.127266, 0.7111111283), (1.0, 0.0311111119), (1.018127, 0.0311111119). Values: `get(0, 0, 0) = -0.12841822`, `get(10, 0, -7) = 0.25088963`, `get(123, 0, 456) = 0.54354382`. Noise `minecraft:nether_state_selector` (`hash = -1772810105`): layers (0.0625, 0.8333333), (0.063633, 0.8333333); `get(0, 0, 0) = -0.21776724`, `get(10, 0, -7) = 0.14769292`, `get(123, 0, 456) = -0.37847722`. Noise `minecraft:nether_wart` (`hash = 815165382`): `get(0, 0, 0) = -0.02168596`, `get(10, 0, -7) = 0.16548175`.

### 12.3 Blended noise and corner values, seed 0, column `x = 0, z = 0`

`N` is the `old_blended_noise` value of 5.2 (random `LegacyRandomSource(0)`). The corner value is `0.64 * S` of 5.4:

| y | `N(0, y, 0)` | gradient `gt` | corner value |
|---|---|---|---|
| 0 | 0.31377053 | 1 | 1.25020325 (= 1.2 + 0.16 N) |
| 8 | 0.22254033 | 1 | 0.87121290 |
| 16 | 0.20367675 | 1 | 0.49776480 |
| 24 | 0.15913247 | 1 | 0.10184477 (= 0.64 N) |
| 32 | 0.19103166 | 1 | 0.12226027 |
| 64 | 0.07341935 | 1 | 0.04698838 |
| 96 | 0.03751202 | 1 | 0.02400769 |
| 104 | 0.11772104 | 1 | 0.07534146 |
| 112 | -0.05728182 | 0.6666667 | 0.17555980 (= 0.2 + 0.42667 N) |
| 120 | 0.19323659 | 0.3333333 | 0.44122383 (= 0.4 + 0.21333 N) |
| 128 | not evaluated | 0 | 0.59999996 |

### 12.4 Filled column, seed 0

With the fill of section 6.2 and `squeeze`, the density of the column `(x, z) = (0, 0)`: y 0 and 1 are 0.45833334 (saturated), y 7 is 0.42699736, y 8 is 0.40805390, y 31 is 0.05978268, y 32 is 0.06105399, y 63 is 0.03319364, y 64 is 0.02348987, y 100 is 0.02483218, y 127 is 0.28194040. Solid runs of the column: y 0 .. 75 solid, y 76 .. 94 air (above y 32, so air and not lava), y 95 .. 127 solid. For `(x, z) = (5, 2)`: solid 0 .. 75, air 76 .. 95, solid 96 .. 127 (y 0 is 0.4583333, y 8 is 0.40819821, y 50 is 0.09641185, y 100 is 0.01997016, y 127 is 0.28214008), 108 solid blocks. Fill versus the point-sample order of 10 section 4.1: for `(5, 2)`, `(10, 13)`, `(-3, 7)` the largest absolute difference over y 0 .. 127 is 5.96e-8, 2.98e-8 and 8.94e-8, with no sign change (solid counts 108, 110, 110).

(These columns are mostly solid because the noise is mostly positive at those positions; the cavern layout depends on the noise sign, section 5.4. No claim is made about the proportion of air over a region.)

### 12.5 Bedrock draws, seed 0

`P = LegacyRandomSource(0).forkPositional()`, `F_floor = P.fromHashOf("minecraft:bedrock_floor").forkPositional()` (seed -7693059141002965223) and `F_roof` (seed 4929288967059825655). Bedrock at `x = 0 .. 7`, `z = 0` (B = bedrock, . = not):

| Layer | x = 0 .. 7 |
|---|---|
| floor y 0 | BBBBBBBB |
| floor y 1 (t 0.8) | BBBBB.BB |
| floor y 2 (t 0.6) | BB..B.BB |
| floor y 3 (t 0.4) | B.B.B..B |
| floor y 4 (t 0.2) | ........ |
| roof y 123 (t 0.8) | .....B.. |
| roof y 124 (t 0.6) | B....B.. |
| roof y 125 (t 0.4) | BB.BBB.. |
| roof y 126 (t 0.2) | .BB...BB |
| roof y 127 | BBBBBBBB |

### 12.6 Arithmetic checks of section 5

- Slide anchors from `slide(df, 0, 128, 24, 0, 0.9375, -8, 24, 2.5)`: top gradient from y `0 + 128 - 24 = 104` to `0 + 128 - 0 = 128`, bottom gradient from `0 - 8 = -8` to `0 + 24 = 24`.
- `gt(120) = 1 + (120 - 104) * (0 - 1)/24 = 0.33333334` (float); `S(y = 120) = 0.9375 + 0.33333334 * (N - 0.9375)`.
- Top row: `S(128) = 0.9375`, `0.64 * 0.9375 = 0.6` (float 0.59999996). The block at y 127 interpolates the corners 0.44122383 (y 120) and 0.59999996 (y 128): `0.44122383 + 7 * (0.59999996 - 0.44122383)/8 = 0.44122383 + 7 * 0.15877613/8 = 0.580153`, and `squeeze(0.580153) = 0.2900765 - 0.195269/24 = 0.281940`, matching the 0.28194040 of 12.4 (with no beardifier and the per-block increment of 6.2 in place of the direct formula, the two agree to the printed digits).

---

## 13. Behaviour summary for implementers

1. Read `noise_settings/nether.json`: `min_y 0`, `height 128`, `sea_level 32`, lava default fluid, netherrack default block, legacy random on, no aquifer.
2. Build `P = LegacyRandomSource(worldSeed).forkPositional()` (section 4.1). Build the blended 3D noise from `LegacyRandomSource(worldSeed)` (minLimit, maxLimit, main stacks, in that order). Build temperature from `LegacyRandomSource(worldSeed)` and vegetation from `LegacyRandomSource(worldSeed + 1)` with the legacy Nether-biome construction (4.3).
3. For every chunk: evaluate `0.64 * S` at the 5 x 17 x 5 corners (section 5.4, 6.1), fill in the order of 6.2, `squeeze`, add the beardifier.
4. For every block, top to bottom: density > 0 gives netherrack; otherwise lava below y 32 and air from y 32 (section 7). Update both heightmaps; no fluid ticks.
5. The surface pass (37-nether-4 section 4) then applies the material rule with bedrock at y 0 (always) and y 1 .. 4 (probabilistic), bedrock at y 127 (always) and y 123 .. 126 (probabilistic), netherrack at y 122 .. 127 (section 9).
6. Biomes come from the quart-resolution multi-noise search with temperature and humidity from section 8 and four zero parameters (37-nether-3 section 3).

---

## 14. Validation (checkable facts)

1. `noise_settings/nether.json`: `noise` = `{min_y 0, height 128}`, `default_block netherrack`, `default_fluid lava`, `sea_level 32`, `legacy_random_source true`, `disable_mob_generation false`, `spawn_target []`, `material_rule minecraft:nether`, no `aquifers` field, `debug_functions` with labels N, T, V.
2. The router holds eight entries; `continents`, `erosion`, `depth`, `ridges`, `chunk_surface_level` are 0.0; `temperature` and `vegetation` are `noise` nodes with `xz_scale 0.25`, `y_scale 0.0` and noises `nether/temperature`, `nether/vegetation`.
3. `final_density`: `add(squeeze(interpolated(cell_size_xz 4, cell_size_y 8, mul(blend_density(lerp(gradient y -8 -> 24 (0 -> 1), 2.5, lerp(gradient y 104 -> 128 (1 -> 0), 0.9375, nether/base_3d_noise))), 0.64))), beardifier)`.
4. `nether/base_3d_noise`: `old_blended_noise`, `smear_scale_multiplier 8.0`, `xz_factor 80.0`, `xz_scale 0.25`, `y_factor 60.0`, `y_scale 0.375`.
5. `nether/temperature` and `nether/vegetation` noise: `base_octave -7`, `octave_count 2`, `base_amplitude 0.9494731054427981`, no modifiers.
6. Legacy seeding: terrain noise from `LegacyRandomSource(seed)`; temperature from `LegacyRandomSource(seed + 0)`, vegetation from `LegacyRandomSource(seed + 1)`; `consumeCount(262)` used for skipped slots; `LegacyFbmInitializer` creates the sampler for slot `i` from `i = k - 1` down to 0 after one discarded `PerlinNoise` for slot `k`.
7. Fluid: sea status level 32 lava; deep status level -54 lava; disabled aquifer returns lava for density <= 0 and `y < 32`, air above; no fluid update is scheduled.
8. Bedrock: floor gradient `above_bottom 0` .. `above_bottom 5`; roof gradient `below_top 5` .. `below_top 0` negated; netherrack cap at `below_top 5` (y 122).
9. Corner table of 5.4 at `N = 0`: y 0 gives 1.2, y 8 gives 0.8, y 16 gives 0.4, y 112 gives 0.2, y 120 gives 0.4, y 128 gives 0.6.
10. Counts from the archive (`unzip -Z1 | grep -v '/$'`): 7 files under `worldgen/noise_settings/`, 2 under `worldgen/noise/nether/`, 1 under `worldgen/density_function/nether/`, 1 `worldgen/material_rule/nether.json`.
11. Cell grid per chunk: 4 x 16 x 4 cells, 5 x 17 x 5 corners, corner rows y 0, 8, .., 128.

---

## 15. Open questions

1. **Interpolation order in 10 section 4.1.** This document reads (6.2) that the block-step volume path interpolates z, then x, then by per-block increments in y, while 10 section 4.1 gives the x, y, z `lerp3` order for every use. Results differ only by float rounding (largest difference found 9e-8, no sign change in three columns), but bit-exact terrain needs 6.2. 10 should be amended; the point-sampler path was read only in its first branch (direct evaluation at cell multiples) and the `lerp3` order was taken from 10.
2. **Beardifier in the Nether.** `nether_fossil` has `terrain_adaptation beard_thin`; the beard shapes and any bastion jigsaw junction term were not read (10 section 11.2 only says the term is 0 without structures). 37-nether-6 section 3 and the structure engine must close this; the noise settings give no other source of structure-dependent density.
3. **Blending of old chunks.** A non-empty `Blender` changes `blend_density`, `blend_alpha`, `blend_offset` and the biome resolver (`decorateBiomeResolver`); not read. Applies only to chunks adjacent to legacy-format data.
4. **Specialised stack classes.** `NoiseStack$Perlin` and `NoiseStack$SmearedPerlin` (the classes `NoiseStack$Builder.build` picks when all layers are plain or all smeared) were not read; the examples assume they compute the same value as the generic `NoiseStack` of 10 section 3.2, and the `PerlinNoise` / `SmearedPerlinNoise` arithmetic of 10 section 3.1 and 3.4 (the smeared `get` and `computeFudgeY` were re-read here and match 10; `sampleAndLerp`'s gradient table and `smoothstep` were taken from 10).
5. **Worked examples are computed.** Sections 12.1 to 12.6 come from a reference script written from this text (float rounding after each operation); they have not been compared with a run of the artifact. A mismatch would point at a misread detail of 4.3 (draw order) or 6.2.
6. **Who else asks for `nether/temperature`.** `RandomState$1.createNoiseSampler` special-cases the two Nether climate noises; any other caller that requests these keys through `RandomState.getOrCreateNoise` would get the standard construction. No such caller was searched for.
7. **Noise range (closed for the blended noise).** `BlendedNoise.range()` was read (5.4): about +-2.5012. Still open: the bounds of the two climate noises of 4.3 (section 8 gives only example values); `NormalNoise` range was not searched.
8. **`getOrigin` with an empty `spawn_target` (closed).** The base `ChunkGenerator.getOrigin` was read: it returns `ChunkPos.ZERO`, so the Nether's origin chunk is (0, 0). The non-empty case (`NoiseSpawnFinder.findSpawnPosition`) is unused here and was not read.
9. **Debug functions.** The `debug_functions` entries `N`, `T`, `V` are only named; the overlay that consumes them was not read.
10. **Surface pass and heightmap detail.** The Nether surface rules (37-nether-4 section 4) depend on `WORLD_SURFACE_WG` starting at y 128 (the roof is the highest non-air block) and on the surface pass walking down to y 0; the interplay was not traced here.
11. **Recalled, not verified.** Nothing in this document was taken from memory without being read; the self-check value `LegacyRandomSource(0).nextInt() = -1155484576` agrees with a remembered value but is listed only as a computed check.
12. **Pass-through condition of `InterpolatedFunction$Sampler.sampleVolume`.** Section 6.1 gives the condition as reported by the review; the branch's bytecode was located (three target methods) but its comparison chain was not traced in this round.
13. **README.** `docs/protocol/README.md` has no row for the 37-nether-* documents and no updated scope sentence; the round owner adds both when the round closes (this document may not edit it).
14. **Unmarked deductions.** Section 3 ("sections 8 .. 15 stay air through generation") follows from the 16 x 128 x 16 volume and is not separately observed; the free-space band of 5.4 is marked inferred.
