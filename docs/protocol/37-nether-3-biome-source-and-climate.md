# 37-3 The Nether: biome source, climate sampling and the five biome definitions

| Item | Value |
|---|---|
| Covers | Part 3 of the Nether round (RS21, GAP-13a of [../design/README.md](../design/README.md)): the `minecraft:nether` multi-noise preset (five parameter points, tabulated in full), how the two Nether climate noises are built and sampled (this is a **legacy** construction that differs from the overworld's, section 3), the nearest-point search as it behaves for exactly five points including its tie-breaking (section 4), quart-resolution sampling and the (absent) y dependence (section 5), and the definitions of the five Nether biomes: climate settings, effects, environment attributes (sounds, music, fog, ambient particles, spawner lists), carver, and per-step feature name lists (section 6) |
| Does not cover | Dimension type and shared model ([37-1](37-nether-1-model-and-dimension-rules.md)), noise router, density and terrain (part 2), surface rules and the `nether_cave` carver algorithm (part 4), feature algorithms (part 5, and [35](35-worldgen-features-1-model-and-placement.md) to 35-7), structures and full spawn tables (part 6, [21](21-mobs-aquatic-nether-end-bosses-and-entities.md)). Shared multi-noise code is in [10](10-world-generation-terrain.md) section 7 and is only restated where the Nether differs |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `MultiNoiseBiomeSourceParameterList`, `...$Preset`, `...$Preset$1`, `MultiNoiseBiomeSourceParameterLists`, `MultiNoiseBiomeSource`, `Climate` and its nested `Parameter`, `ParameterPoint`, `ParameterList`, `TargetPoint`, `Sampler`, `RTree` classes, `RandomState` and `RandomState$1`, `NormalNoise`, `LegacyFbmInitializer`, `NoiseStack` and `NoiseStack$Builder`, `PerlinNoise`, `GradientNoise`, `LegacyRandomSource`, `BitRandomSource`, `NetherBiomes`, `Biome`, `BiomeSpecialEffects`, `MobSpawnSettings`, `MobSpawnSettingsModifier$Overlay`, `AmbientMoodSettings`, `AmbientAdditionsSettings`, `BackgroundMusic`, and of the JSON files `data/minecraft/worldgen/biome/{nether_wastes,soul_sand_valley,crimson_forest,warped_forest,basalt_deltas}.json`, `worldgen/multi_noise_biome_source_parameter_list/nether.json`, `worldgen/noise/nether/{temperature,vegetation}.json`, `worldgen/noise_settings/nether.json` and `dimension_type/the_nether.json`. No execution. Worked examples marked "(computed)" come from a scratch reference implementation of this document's own text (not part of the repository); they are consistency checks, not values observed from the artifact |
| Operator decisions | Standard Minecraft content is the target; the extraction tool supplies data rows (biome JSON, noise JSON), engines and code-defined content are specified completely (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"). The five points of section 2 are **code** (`Preset$1`), not data: the data file only names the preset |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction, "(recalled, not verified)" a statement
not read this round; both are listed in the Open questions. "NN section" is a section of document NN in this directory.

---

## 1. Pipeline at a glance

For one Nether chunk column the biome stage does the following (the stage order is in [10](10-world-generation-terrain.md) section 11 and 37-1 section 6.9):

1. The dimension `minecraft:the_nether` has the biome source `multi_noise` with the preset `minecraft:nether` (section 2).
2. For every quart cell `(qx, qy, qz)` of the chunk, the climate **target point** `(T, H, C, E, D, W)` is the quantised result of six router functions at
   the block position `(4 qx, 4 qy, 4 qz)` (section 3). In the Nether only `T` and `H` vary; `C`, `E`, `D`, `W` are constant 0.
3. The biome of the cell is the biome of the preset point with the smallest fitness (section 4).
4. Biomes are stored per 4x4x4 cell (section 5). Gameplay lookups use the fuzzy zoom of [10](10-world-generation-terrain.md) section 7.7.

Because the climate does not depend on y (section 5.1), every Nether column has exactly one biome in all 64 cells of the column.

---

## 2. The preset `minecraft:nether`

### 2.1 Where it is defined

| Piece | Value (read) |
|---|---|
| Data file | `data/minecraft/worldgen/multi_noise_biome_source_parameter_list/nether.json` is exactly `{"preset": "minecraft:nether"}`; the sibling `overworld.json` is `{"preset": "minecraft:overworld"}` ([10](10-world-generation-terrain.md) section 7.4) |
| Registry key | `MultiNoiseBiomeSourceParameterLists.NETHER` = `minecraft:nether` in the registry `multi_noise_biome_source_parameter_list` (the class registers two entries, `nether` then `overworld`, each built from `Preset.NETHER` / `Preset.OVERWORLD`) |
| Preset record | `Preset(id, provider)`; `Preset.NETHER` has id `minecraft:nether` and provider `Preset$1`; `Preset.OVERWORLD` has id `minecraft:overworld` and provider `Preset$2`. The preset codec accepts only these two ids (a lookup in a two-entry map; an unknown id is an error whose text is `Unknown preset: <id>`) |
| Provider contract | the provider receives a function from biome key to value and returns a `Climate.ParameterList` of `(ParameterPoint, value)` pairs **in a fixed order**; for the Nether it builds the list from five hard-coded points (no builder class, no loops) |
| Used biomes | `Preset.usedBiomes` is the distinct set of the biome keys of the list: the five Nether biomes |

The preset is code. The extraction tool therefore does **not** copy it from data; an implementation hard-codes section 2.2. (The data file may be
emitted as the literal text above.)

### 2.2 The five parameter points (full rows, in list order)

Each point is built with the seven-float form `Climate.parameters(temperature, humidity, continentalness, erosion, depth, weirdness, offset)`: every
climate parameter is a **point** interval (`Parameter.point(v) = span(v, v)`, min = max = `quantize(v)`), and the offset is a single quantised long.
The seven floats of each row were read as the constants pushed before the call (an `fconst_0` is 0.0).

| # (list index) | Biome | T | H | C | E | D | W | offset | quantised row `(T, H, C, E, D, W, offset)` |
|---|---|---|---|---|---|---|---|---|---|
| 0 | `minecraft:nether_wastes` | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | (0, 0, 0, 0, 0, 0, 0) |
| 1 | `minecraft:soul_sand_valley` | 0.0 | -0.5 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | (0, -5000, 0, 0, 0, 0, 0) |
| 2 | `minecraft:crimson_forest` | 0.4 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | (4000, 0, 0, 0, 0, 0, 0) |
| 3 | `minecraft:warped_forest` | 0.0 | 0.5 | 0.0 | 0.0 | 0.0 | 0.0 | 0.375 | (0, 5000, 0, 0, 0, 0, 3750) |
| 4 | `minecraft:basalt_deltas` | -0.5 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.175 | (-5000, 0, 0, 0, 0, 0, 1750) |

Quantisation (`Climate.quantizeCoord`): `q(v) = (long)(v * 10000.0f)`, a **float** multiplication then truncation toward zero. Computed for the constants
above: `q(0.4f) = 4000`, `q(0.375f) = 3750`, `q(0.175f) = 1750` (the float product rounds to exactly 1750.0), `q(-0.5f) = -5000`, `q(0.5f) = 5000`. The
points have no interval width; a Nether point is a single location in the 7-D space, and the offset is a pure additive handicap
(section 4.1): `warped_forest` and `basalt_deltas` lose ground by `3750^2 = 14 062 500` and `1750^2 = 3 062 500` respectively.

The same five points are the only `ParameterList` the Nether uses. The list is built **once** per biome source, in this order (the order matters for
section 4.3).

---

## 3. Climate sampling in the Nether

### 3.1 The router functions

The Nether noise settings (`noise_settings/nether.json`, `noise_router`) define the six climate functions as follows (read; the rest of the router is part 2):

| Router field | Value |
|---|---|
| `temperature` | density function `noise` with noise `minecraft:nether/temperature`, `xz_scale` 0.25, `y_scale` 0.0 |
| `vegetation` (humidity) | density function `noise` with noise `minecraft:nether/vegetation`, `xz_scale` 0.25, `y_scale` 0.0 |
| `continents` | constant 0.0 |
| `erosion` | constant 0.0 |
| `depth` | constant 0.0 |
| `ridges` (weirdness) | constant 0.0 |

The `noise` node evaluates `N.get(x * 0.25, y * 0.0, z * 0.25)` (10 section 4.2: doubles for the argument arithmetic, float result, no shifts). With `y_scale = 0` the y
argument is exactly 0.0 for every y, so the value is a **2-D function of (x, z)** only.

### 3.2 The two noise definitions (data)

`worldgen/noise/nether/temperature.json` and `.../vegetation.json` are identical:
`{"base_amplitude": 0.9494731054427981, "base_octave": -7, "octave_count": 2}`. There is no `amplitude_modifiers` (so the modifier of both slots is 1.0)
and no `normalize` field (the default `enabled`).

### 3.3 These two noises use a legacy construction, always

The router is compiled with a context (`RandomState$1`) whose `createNoiseSampler(holder)` is asked for every `noise` node. It checks the noise key **before** any other
rule and, **independent of the `legacy_random_source` flag**:

* if the key is `minecraft:nether/temperature`, the noise is `NormalNoise.createForLegacyNetherBiome(LegacyRandomSource(worldSeed + 0))`;
* if the key is `minecraft:nether/vegetation`, the noise is `NormalNoise.createForLegacyNetherBiome(LegacyRandomSource(worldSeed + 1))`;
* otherwise the ordinary `RandomState.getOrCreateNoise(key)`, which uses the named-hash construction of [10](10-world-generation-terrain.md) section 3.3.

`worldSeed` is the 64-bit world seed (`RandomState.seed`, the value `RandomState.create` is given; the sum wraps as a 64-bit integer). The generator is the
`java.util.Random`-compatible `LegacyRandomSource` ([10](10-world-generation-terrain.md) section 2.6: `setSeed(s)`: state `= (s xor 0x5DEECE66D) & (2^48 - 1)`; `next(bits)`:
`state = (state * 0x5DEECE66D + 11) & (2^48 - 1)`, result `(int)(state >>> (48 - bits))`), with the derived operations read in `BitRandomSource`:

| Operation | Definition (read) |
|---|---|
| `nextInt()` | `next(32)` |
| `nextInt(bound)` | if `bound` is a power of two: `(int)((bound * (long)next(31)) >> 31)`; otherwise loop: `b = next(31)`, `v = b mod bound`, accept `v` when `b - v + (bound - 1)` does not overflow int (is non-negative as a 32-bit int), else draw again |
| `nextDouble()` | `a = next(26)`, `b = next(27)`, `(((long)a << 27) + b) * 1.1102230246251565E-16` (two draws) |
| `consumeCount(n)` | `n` consecutive `nextInt()` calls |

### 3.4 `createForLegacyNetherBiome` step by step

`createForLegacyNetherBiome` is an **instance method of the `NormalNoise` object** taken from the noise holder (not a static factory on `NormalNoise`). It reads that object's `Parameters` (`baseOctave`, `baseAmplitude`, `octaveCount`, `amplitudeModifiers`) and that object's own `normalizationFactor` field, so the `nf` below is the object's stored value. `Parameters.normalize` has three states: `DISABLED`, `ENABLED` and `LEGACY`; the JSON default is `ENABLED` (read), and neither Nether noise JSON sets `normalize`, so both are `ENABLED`. The base-amplitude rescaling `2^(n-1) / (2^n - 1)` applies to the octave list whenever the state is not `DISABLED`; the `LEGACY` branch (which recomputes `nf` from a parity factor) is not taken for the Nether noises.

Inputs: the random `r` (seeded as in 3.3), `baseOctave = -7`, the amplitude list `[1.0, 1.0]` (an empty `amplitude_modifiers` list is replaced by `octave_count`
copies of 1.0; here `octave_count = 2`), `baseAmplitude = 0.9494731054427981`.

**Normalisation factor `nf`.** The `NormalNoise` object's own `normalizationFactor` is computed as for any normal noise ([10](10-world-generation-terrain.md) section 3.3): build the
octave list (`amp = baseAmplitude * 2^(n-1) / (2^n - 1)` for `n = 2`, i.e. `0.9494731054427981 * 2/3 = 0.6329820702951987` for slot 0, halving per slot, so slot 1 is
`0.31649103514759935`), `sum` = sum of the octave amplitudes (= 0.9494731054427981), `dev = sqrt(sum_i (0.2702247831245211 * |a_i|)^2)`, and
`nf = (sum * 0.3333333333333333) / (dev * sqrt(2))`. Computed: **`nf = 1.1702396884564004`**. The legacy path then uses `f = (float)(nf * baseAmplitude)`
= `(float)(1.1702396884564004 * 0.9494731054427981)` = **1.1111111640930176** (computed).

**Building one octave stack** (`LegacyFbmInitializer.createForLegacyNetherBiome(r, firstOctave = -7, amplitudes)`), with `n = 2` (the list size), `idx = -firstOctave = 7`:

1. Create one `PerlinNoise` from `r` (call it the *zero-octave noise*). It consumes random numbers exactly as a normal `PerlinNoise` construction ([10](10-world-generation-terrain.md) section 3.1:
   three `nextDouble() * 256.0` offsets x, y, z, then the 256-entry permutation shuffle, `perm[i] <-> perm[i + nextInt(256 - i)]` for `i = 0..255`). It is used only when `0 <= idx < n`
   and its amplitude is non-zero; here `idx = 7 >= n`, so it is **discarded** (only its random consumption matters).
2. For `i = idx - 1` down to 0 (that is `i = 6, 5, 4, 3, 2, 1, 0`):
   * if `i < n` and `amplitudes[i] != 0`: create a new `PerlinNoise` from `r` and store it in slot `i`;
   * if `i < n` and `amplitudes[i] == 0`, or `i >= n`: **skip** by `r.consumeCount(262)` (262 `nextInt()` calls).
   For the Nether this means: the five skips for `i = 6, 5, 4, 3, 2` (5 x 262 draws), then a new `PerlinNoise` in slot 1 (`i = 1`), then a new `PerlinNoise` in slot 0 (`i = 0`).
   (Note: 262 is the draw count of a `PerlinNoise` built on the legacy generator when no `nextInt(bound)` rejection happens: 3 doubles x 2 draws + 256 draws.
   A rejection loop in the real construction would consume more, which the skip does not model; the skip is a constant 262. Open question 3.)
3. Consistency checks the class performs: the number of created non-null slots must equal the number of non-zero amplitudes (else an error), and `idx` must be at least `n - 1`
   (else "Positive octaves are temporarily disabled"). Both hold here.
4. `inputFactor = 2^(-idx) = 2^-7 = 0.0078125`; `valueFactor = 2^(n-1) / (2^n - 1) = 2/3`. For each slot `i = 0, 1` in order with a non-null noise: add the layer
   `(noise_i, frequency = inputFactor, amplitude = (float)(valueFactor * amplitudes[i]))`, then `inputFactor *= 2`, `valueFactor /= 2`.
   Result: slot 0 `(noise_0, 0.0078125, (float)(2/3) = 0.6666666865348816)`, slot 1 `(noise_1, 0.015625, (float)(1/3) = 0.3333333432674408)`.

**Two stacks and the final noise.** `createForLegacyNetherBiome` builds stack A and then stack B from the **same** `r`, A first (so B continues the stream where A stopped;
the zero-octave noise, the skips and the two real octaves are consumed twice in total, in the order A then B). It then composes one flat `NoiseStack`
(`NoiseStack.Builder.addStack` copies the layers of the argument stack: **frequency multiplied by the factor (double), amplitude multiplied by the factor (float)**):

| Final layer # | Noise | Frequency (double product) | Amplitude (float product) |
|---|---|---|---|
| 0 | A slot 0 | `0.0078125 * 1.0` = 0.0078125 | `0.6666666865348816f * f` = 0.7407407760620117 (computed) |
| 1 | A slot 1 | `0.015625 * 1.0` = 0.015625 | `0.3333333432674408f * f` = 0.37037038803100586 (computed) |
| 2 | B slot 0 | `0.0078125 * 1.0181268882175227` | same as layer 0 |
| 3 | B slot 1 | `0.015625 * 1.0181268882175227` | same as layer 1 |

and the value of the stack at `(x, y, z)` is the `NoiseStack.get` of [10](10-world-generation-terrain.md) section 3.2: `acc = 0f`; for each layer in order
`acc = acc + amplitude * noise.get(x * frequency, y * frequency, z * frequency)` (float multiplications and additions; the products `x * frequency` are doubles).

Differences from the overworld-style construction of [10](10-world-generation-terrain.md) section 3.3, in one place: the two `PerlinNoise` octave sets are not made by
hashing names (`octave_-7`) from forked positional factories; they come from one **sequential** legacy stream, with a discarded noise first and five skipped slots; and
the amplitudes use `2/3, 1/3` times `f` rather than `nf * amp` per octave (the numeric result of the two ways is not the same).

### 3.5 What the climate sampler does with the values

`Climate.Sampler.sample(qx, qy, qz)` evaluates the six functions at block position `(QuartPos.toBlock(qx), QuartPos.toBlock(qy), QuartPos.toBlock(qz))` = `(4 qx, 4 qy, 4 qz)` (no
half-quart offset; 10 section 7.1), in the order temperature, humidity (vegetation), continentalness, erosion, depth, weirdness, quantises each by `q(v)` of section 2.2, and returns the target
point. The chunk-level resolver (`createResolverForChunk`) samples the same six functions over a volume at quart-to-block positions with cell size 4x4x4 blocks, which is the same set of
points (read for the volume set-up; Open question 4).

For the Nether the target is therefore `(q(T(4qx, 4qz)), q(H(4qx, 4qz)), 0, 0, 0, 0)`, with `T` = the `nether/temperature` value and `H` = the `nether/vegetation` value of 3.1.

---

## 4. Nearest-point search for the Nether

### 4.1 Fitness (the metric)

`ParameterPoint.fitness(target) = sum over the six climate parameters of distance(param, target)^2 + offset^2` (long arithmetic, `Mth.square`). The distance of a value `v` to a
parameter `[min, max]` is `v - max` if `v > max`, else `max(min - v, 0)` ([10](10-world-generation-terrain.md) section 7.2). For the five Nether points the intervals are points, `C = E = D = W = 0` in the
target and in every point, so those four terms are 0 and

`F_i(T, H) = (T - T_i)^2 + (H - H_i)^2 + offset_i^2`  (all in quantised units, T and H integers).

| Biome | `F_i(T, H)` |
|---|---|
| nether_wastes | `T^2 + H^2` |
| soul_sand_valley | `T^2 + (H + 5000)^2` |
| crimson_forest | `(T - 4000)^2 + H^2` |
| warped_forest | `T^2 + (H - 5000)^2 + 14 062 500` |
| basalt_deltas | `(T + 5000)^2 + H^2 + 3 062 500` |

The result is a biome (the minimum `F_i`); the minimum value itself is not used.

### 4.2 Decision boundaries against `nether_wastes` (computed from 4.1)

Setting `F_i = F_nether_wastes`:

| Challenger | It beats `nether_wastes` strictly when | Boundary |
|---|---|---|
| soul_sand_valley | `H < -2500` | `10000 H + 25 000 000 < 0` (a tie at `H = -2500`) |
| crimson_forest | `T > 2000` | a tie at `T = 2000` |
| warped_forest | `H > 3906.25`, i.e. `H >= 3907` for integers | `10000 H > 39 062 500` |
| basalt_deltas | `T < -2806.25`, i.e. `T <= -2807` for integers | `10000 T < -28 062 500` |

The four challengers also compete with one another (for example soul_sand_valley against crimson_forest: equal when `10000 H + 8000 T = -9 000 000`); the winner is always
the global minimum of the five `F_i`. In unit terms (value `/ 10000`): soul_sand_valley needs humidity below -0.25, crimson_forest needs temperature above 0.2,
warped_forest needs humidity above 0.390625, basalt_deltas needs temperature below -0.280625; where none applies the biome is `nether_wastes`.

### 4.3 Which search runs, and its tie-breaking

`MultiNoiseBiomeSource.getNoiseBiome(target)` calls `Climate.ParameterList.findValue(target)`, which calls `findValueIndex`, the **R-tree** search (`Climate.RTree`). (`findValueBruteForce`
is a reference method that is not called by the game.) The three behaviours differ only on **exact ties** of `F`, which happen on the quantised integer grid (for example `(T, H) = (0, -2500)`).

**R-tree construction** (`RTree.create(list, childrenPerNode = 19)`): `ParameterList` builds the tree with 19 children per node. Every list entry becomes a leaf whose box is the point's seven
parameters (the six plus the offset as an interval `[offset, offset]`). `RTree.build` receives 5 leaves; because 5 is greater than 1 and **not greater than 19**, it does **not** bucketize: it sorts the leaves in
place by a **cost** and wraps them in a single `SubTree` (the root), whose children are the five leaves. So the whole tree is one node with five leaf children.

* **Sort key (cost)** of a leaf: `sum over the 7 parameters of |(min + max) / 2|` (integer division truncating toward zero, absolute value, summed). Computed for the Nether rows:

| Leaf | per-parameter midpoints (T, H, C, E, D, W, offset) | cost |
|---|---|---|
| nether_wastes | (0, 0, 0, 0, 0, 0, 0) | 0 |
| crimson_forest | (4000, 0, 0, 0, 0, 0, 0) | 4000 |
| soul_sand_valley | (0, -5000, 0, 0, 0, 0, 0) | 5000 |
| basalt_deltas | (-5000, 0, 0, 0, 0, 0, 1750) | 6750 |
| warped_forest | (0, 5000, 0, 0, 0, 0, 3750) | 8750 |

  The sort is ascending and stable (all costs differ here). **Sorted order of the tree: nether_wastes, crimson_forest, soul_sand_valley, basalt_deltas, warped_forest.** This differs from
  the registration order of section 2.2 (nether_wastes, soul_sand_valley, crimson_forest, warped_forest, basalt_deltas).

**Search** (`RTree.search(target, metric)`): the target is converted to a 7-long array `(T, H, C, E, D, W, 0)` (the seventh entry, the offset slot, is 0 for a target). The metric is the node's
`distance(array)`, `sum over 7 parameters of Parameter.distance(value)^2`; for a leaf this equals `fitness` (the leaf's offset parameter is `[offset, offset]` against the target's 0, which
adds `offset^2`). The search starts with `best = lastResult` (a **thread-local** leaf remembered from the previous search on the same thread; `null` on a fresh thread, in which case
`bestDistance = Long.MAX_VALUE`), then visits the root's children in sorted order: for each child it computes the child's distance and **only if `bestDistance` is strictly greater than it**
descends into it (for a leaf: itself) and replaces `best` when the leaf's distance is **strictly smaller** than `bestDistance`. The leaf of the final `best` is stored as the new `lastResult`.

Consequences, stated as rules:

1. If there is a unique minimum, every method returns it.
2. On an exact tie among the minimum-fitness points, the R-tree returns **`lastResult` if it is among the tied points**; otherwise the **first tied point in the sorted order** above.
3. `lastResult` is per thread and per tree and depends on the history of calls (which chunk a worker thread generated before), so tie results are **not reproducible** across runs on the vanilla server.
   For a deterministic implementation, treat `lastResult` as `null` (a fresh thread): **among tied points choose the first in the sorted order nether_wastes, crimson_forest,
   soul_sand_valley, basalt_deltas, warped_forest.** (The brute-force reference would choose by registration order; the two differ only for a tie between two points that are ordered differently in the two orders, for example soul_sand_valley vs crimson_forest or warped_forest vs basalt_deltas.)
4. Ties with `nether_wastes` (cost 0) always go to `nether_wastes` in both orders unless `lastResult` is the tied challenger.

Tie example (computed): `(T, H) = (3000, -3300)`: `F` = nether_wastes 19 890 000, soul_sand_valley 11 890 000, crimson_forest 11 890 000, warped_forest 91 952 500, basalt_deltas 77 952 500. A fresh-thread R-tree
returns `crimson_forest` (earlier in the sorted order); the brute-force reference would return `soul_sand_valley` (earlier in registration order). The deterministic rule above gives `crimson_forest`.

### 4.4 Statistical shape (computed, informative)

With the noise scale of section 3.4 the values `T`, `H` are of order 0.1 to 0.7 in magnitude (the section 8 samples span -0.24 to +0.72), so `nether_wastes` is the most common biome and the other four
appear where the noise reaches the boundaries of 4.2; `warped_forest` and `basalt_deltas` need values near the tails (the offsets act as penalties). No frequency was measured.

---

## 5. Sampling resolution and y handling

### 5.1 No y dependence

* The two noise functions evaluate at `y * 0.0 = 0.0` (section 3.1); the four other parameters are constants. A target point therefore depends on `(qx, qz)` only; `qy` does not enter.
* The Nether dimension is 256 blocks high from `min_y = 0` (37-1 section 2.1: `min_y` 0, `height` 256, `logical_height` 128), that is **16 sections** (`sy = 0..15`) of 64 cells, and **64 cell rows** `qy = 0..63`. The
  noise grid height 128 of the noise settings (`noise.height`) concerns density, not biomes; biomes are stored for the full 256 blocks.
* The biome stage fills, for each section `sy` and local `(lx, ly, lz)` in 0..3 (order `lx` outer, `ly`, `lz` inner; [10](10-world-generation-terrain.md) section 7.6), `getNoiseBiome(chunkMinQuartX + lx, sy * 4 + ly, chunkMinQuartZ + lz)`. Since the result is
  independent of `qy`, all 64 vertical cells of a column hold the same biome (an implementation may compute only the 4 x 4 = 16 column values per chunk and replicate them over all 64 cell rows).

### 5.2 Block queries (fuzzy zoom)

Lookups by block position in gameplay and decoration use `BiomeManager.getBiome(x, y, z)` ([10](10-world-generation-terrain.md) section 7.7): a three-dimensional fuzzy choice among eight neighbour cells with a hash-jittered distance. In the Nether
every cell in a column is identical, so the **y** component never changes the biome of the winning cell, **but y still takes part in the jittered distance** (the cell coordinate `ay` is part of the hash), so the chosen
**xz** cell for a block can differ between y values of the same column. An implementation must keep the full 3-D procedure of section 7.7 and cannot simplify it to a 2-D one without changing which neighbour column wins at
column borders.

**Vertical ends (read).** With block y in 0..255 the winning cell `ay` can be -1 (y < 2) or 64 (y >= 254). `BiomeManager.getBiome` does not clamp: it passes the winning cell straight to the resolver. The clamp is in `ChunkAccess.getNoiseBiome`, which clamps the quart y to `[QuartPos.fromBlock(minY), QuartPos.fromBlock(minY) + QuartPos.fromBlock(height) - 1]` = 0..63 for the Nether. (When the chunk is not loaded to the biome status, `getUncachedNoiseBiome` is used with the unclamped value; for the Nether it yields the same biome since qy does not enter.) The replicate-column shortcut is therefore exact.

### 5.3 Where the biome of a position matters in the Nether

The biome controls: the surface rules (part 4: `nether` material rule uses biome conditions for `basalt_deltas`, `soul_sand_valley` and the forests), the decoration (section 6.5 here, algorithms in part 5 and 35), spawning (section 6.6), fog colour and ambient
particles (section 7), ambient sounds and music (section 6.4), and the sky-related attribute defaults. This document gives only the biome; the consumers are cross-referenced.

---

## 6. The five biome definitions

The biome files are **data** (extracted by the tool); this section specifies the schema and records the values of the five files so an implementation can validate and so the engines know what the fields mean. Values were read from the JSON and, for the numeric
constants, cross-checked in `NetherBiomes` (`ldc` constants: water 4159204, fog colours as ARGB ints, probabilities as floats).

### 6.1 Schema of a biome file (26.3)

| Field | Type | Presence | Meaning |
|---|---|---|---|
| `temperature` | float | required | base temperature (`Biome$ClimateSettings`) |
| `downfall` | float | required | base downfall |
| `has_precipitation` | boolean | required | whether the biome has rain or snow weather (the Nether has no weather: 37-1 section 5.5) |
| `temperature_modifier` | enum `none` / `frozen` | optional, default `none` | absent in all five Nether files |
| `effects` | object | required | `BiomeSpecialEffects`: `water_color` (int or colour string, required), optional `foliage_color`, `dry_foliage_color`, `grass_color`, `grass_color_modifier`. The five Nether files set **only** `water_color` |
| `attributes` | map attribute id -> value or `{argument, modifier}` | optional (default empty) | the biome's environment-attribute layer ([23](23-registry-loading.md) section 8; layering in [12](12-client-rendering.md) section on attributes) |
| `carvers` | carver list (a single id string or a list) | required | the carvers of this biome |
| `features` | list of lists of placed-feature ids | required | per decoration step, in step order (6.5) |

Note: in 26.3 the fog colour, water fog colour, sky colour, ambient sounds, music, particles and mob spawns are **attributes** (`visual/*`, `audio/*`, `gameplay/natural_mob_spawns`) rather than fields of `effects`.
There is no `creature_spawn_probability` field in these files and there are no `effects.fog_color`, `effects.sky_color`, `effects.water_fog_color`, `effects.ambient_sound`, `effects.mood_sound`, `effects.additions_sound`, `effects.music`
or `effects.particle` fields (they are not read in the five files; the layout differs from older versions).

### 6.2 Climate settings and effects (all five)

| Biome | temperature | downfall | has_precipitation | temperature_modifier | `effects.water_color` |
|---|---|---|---|---|---|
| `nether_wastes` | 2.0 | 0.0 | false | none (absent) | `#3f76e4` (= 4159204) |
| `soul_sand_valley` | 2.0 | 0.0 | false | none (absent) | `#3f76e4` |
| `crimson_forest` | 2.0 | 0.0 | false | none (absent) | `#3f76e4` |
| `warped_forest` | 2.0 | 0.0 | false | none (absent) | `#3f76e4` |
| `basalt_deltas` | 2.0 | 0.0 | false | none (absent) | `#3f76e4` |

`NetherBiomes.baseBiome()` builds all five from the same base: no precipitation, temperature 2.0, downfall 0.0, water colour 4159204. The five files set no grass or foliage colour override (consumers of the biome colour maps, [43](43-tint-sources.md),
use the defaults for the 2.0 / 0.0 climate; not repeated here).

### 6.3 Attributes common to all five

| Attribute | Value | Same in all? |
|---|---|---|
| `audio/ambient_sounds` | `{loop, mood, additions}` objects (6.4), sound ids differ per biome | structure same, ids differ |
| `audio/background_music` | `{"default": {sound, min_delay 12000, max_delay 24000}}` (`replace_current_music` not set) | same delays, sound differs |
| `gameplay/natural_mob_spawns` | `{argument: {spawns_by_category, spawn_costs}, modifier: "overlay"}` | structure same |
| `visual/fog_color` | colour | differs (7) |
| `visual/ambient_particles` | `{argument: [{particle: {type: <id>}, probability}], modifier: "append"}` (`particle` is a particle-options object with a `type` field, not a bare id) | **absent in `nether_wastes`**; present in the other four |

The five biome files set **only** `audio/ambient_sounds`, `audio/background_music`, `gameplay/natural_mob_spawns`, `visual/fog_color` and (not `nether_wastes`) `visual/ambient_particles`. They set no `gameplay/increased_fire_burnout`, `gameplay/water_evaporates` or `gameplay/snow_golem_melts` themselves. The Nether values of the last two come from the **dimension layer**: the Nether dimension type JSON sets `gameplay/water_evaporates` = true and `gameplay/snow_golem_melts` = true (read; these match the tables of [37-1](37-nether-1-model-and-dimension-rules.md) section 3.1 and its attribute table, against a default of false). Only `gameplay/increased_fire_burnout` is unset in both layers, so it alone takes its default (false).

The Nether dimension type sets none of the `audio/*` attributes and no `visual/fog_color` (37-1 section 2.2), so these biome layers are the only source for them in the Nether.

### 6.4 Sounds and music (values)

Ambient loop, mood and additions, music. `loop` is a sound-event id string; `mood` is `{sound, tick_delay, block_search_extent, offset}`; `additions` is `{sound, tick_chance}` (field names read from the codecs `AmbientMoodSettings`
and `AmbientAdditionsSettings`; types: `tick_delay` int, `block_search_extent` int, `offset` double, `tick_chance` double).

| Biome | loop | mood sound | additions sound | music sound |
|---|---|---|---|---|
| nether_wastes | `ambient.nether_wastes.loop` | `ambient.nether_wastes.mood` | `ambient.nether_wastes.additions` | `music.nether.nether_wastes` |
| soul_sand_valley | `ambient.soul_sand_valley.loop` | `ambient.soul_sand_valley.mood` | `ambient.soul_sand_valley.additions` | `music.nether.soul_sand_valley` |
| crimson_forest | `ambient.crimson_forest.loop` | `ambient.crimson_forest.mood` | `ambient.crimson_forest.additions` | `music.nether.crimson_forest` |
| warped_forest | `ambient.warped_forest.loop` | `ambient.warped_forest.mood` | `ambient.warped_forest.additions` | `music.nether.warped_forest` |
| basalt_deltas | `ambient.basalt_deltas.loop` | `ambient.basalt_deltas.mood` | `ambient.basalt_deltas.additions` | `music.nether.basalt_deltas` |

(All ids are in the `minecraft:` namespace; the sound-event ids are in [46](46-registry-ids.md).) Parameters, identical in all five files:

| Parameter | Value |
|---|---|
| `mood.tick_delay` | 6000 |
| `mood.block_search_extent` | 8 |
| `mood.offset` | 2.0 |
| `additions.tick_chance` | 0.0111 |
| `background_music.default.min_delay` | 12000 |
| `background_music.default.max_delay` | 24000 |

The `Music` codec (the value type of `default`) has four fields: `sound`, `min_delay`, `max_delay` (all required) and the **optional** boolean `replace_current_music` (codec default false, read as `optionalFieldOf` with false); the Nether files do not set it, so it is false.

The `background_music` object has the three optional keys `default`, `creative`, `underwater` (`BackgroundMusic` codec); the Nether files set only `default`. Which entry plays is chosen by `select(creative, underwater)`: the underwater entry when present and
the player is underwater, else the creative entry when present and the player is in creative, else the default (read: the three field reads in `select`; the exact precedence of the two checks was read as above, with the
underwater check first).

The sound engine that consumes these (the client `BiomeAmbientSoundsHandler`, `MusicManager`) is outside this round: it keeps a per-player "moodiness" counter and plays loops and additions with probabilities. Its algorithm and the music scheduler are
**not specified here** (sounds are out of scope per the design README; Open question 5). A server needs none of these values; they matter only for the client-side data.

### 6.5 Carvers and feature lists

**Carvers.** All five biomes: `"carvers": "minecraft:nether_cave"` (one carver). The carver algorithm is part 4; its step is the single carving step ([11](11-world-generation-caves-and-ores.md)).

**Feature lists.** `features` is a list with one list per decoration step, up to 11 steps (the enum has eleven constants; overworld biome files such as plains carry 11 lists); the five Nether files carry 10 lists (`basalt_deltas` 8) and missing trailing steps are empty. The steps are in the order of `GenerationStep.Decoration` (read from its constants): index 0 `raw_generation`, 1 `lakes`, 2 `local_modifications`, 3 `underground_structures`,
4 `surface_structures`, 5 `strongholds`, 6 `underground_ores`, 7 `underground_decoration`, 8 `fluid_springs`, 9 `vegetal_decoration`, 10 `top_layer_modification` (no entry in the Nether files). A list shorter than eleven means
the missing trailing steps are empty (`basalt_deltas` has eight lists, steps 0 to 7; the others have ten). The order inside a list is the order of the entries; the global ordering of features across biomes within a step follows from the sort of [11](11-world-generation-caves-and-ores.md) section 6.2 (35 Open question 14 states that the feature index follows from that sort), which takes the dimension's biome list as input: the Nether's biome list is the five biomes of the preset in section 2 (their order there is the order that sort sees), and the resulting index is what the decoration driver of [35](35-worldgen-features-1-model-and-placement.md) section 6 uses. This document does not restate either rule. Only names are given here; the algorithms are in part 5 and 35.

Entries are `minecraft:` placed-feature ids. Empty lists omitted; "step 7" = `underground_decoration`, "step 9" = `vegetal_decoration`.

**nether_wastes**
* step 7 (15): `spring_open`, `patch_fire`, `patch_soul_fire`, `glowstone_extra`, `glowstone`, `brown_mushroom_nether`, `red_mushroom_nether`, `ore_magma`, `spring_closed`, `ore_gravel_nether`, `ore_blackstone`, `ore_gold_nether`, `ore_quartz_nether`, `ore_ancient_debris_large`, `ore_debris_small`
* step 9 (3): `spring_lava`, `brown_mushroom_normal`, `red_mushroom_normal`

**soul_sand_valley**
* step 2 (1): `basalt_pillar`
* step 7 (15): `spring_open`, `patch_fire`, `patch_soul_fire`, `glowstone_extra`, `glowstone`, `patch_crimson_roots`, `ore_magma`, `spring_closed`, `ore_soul_sand`, `ore_gravel_nether`, `ore_blackstone`, `ore_gold_nether`, `ore_quartz_nether`, `ore_ancient_debris_large`, `ore_debris_small`
* step 9 (1): `spring_lava`

**crimson_forest**
* step 7 (12): `spring_open`, `patch_fire`, `glowstone_extra`, `glowstone`, `ore_magma`, `spring_closed`, `ore_gravel_nether`, `ore_blackstone`, `ore_gold_nether`, `ore_quartz_nether`, `ore_ancient_debris_large`, `ore_debris_small`
* step 9 (6): `spring_lava`, `brown_mushroom_normal`, `red_mushroom_normal`, `weeping_vines`, `crimson_fungi`, `crimson_forest_vegetation`

**warped_forest**
* step 7 (13): `spring_open`, `patch_fire`, `patch_soul_fire`, `glowstone_extra`, `glowstone`, `ore_magma`, `spring_closed`, `ore_gravel_nether`, `ore_blackstone`, `ore_gold_nether`, `ore_quartz_nether`, `ore_ancient_debris_large`, `ore_debris_small`
* step 9 (7): `spring_lava`, `brown_mushroom_normal`, `red_mushroom_normal`, `warped_fungi`, `warped_forest_vegetation`, `nether_sprouts`, `twisting_vines`

**basalt_deltas**
* step 4 (3): `delta`, `small_basalt_columns`, `large_basalt_columns`
* step 7 (15): `basalt_blobs`, `blackstone_blobs`, `spring_delta`, `patch_fire`, `patch_soul_fire`, `glowstone_extra`, `glowstone`, `brown_mushroom_nether`, `red_mushroom_nether`, `ore_magma`, `spring_closed_double`, `ore_gold_deltas`, `ore_quartz_deltas`, `ore_ancient_debris_large`, `ore_debris_small`

Counts (tallied from the lists): nether_wastes 15 + 3 = 18, soul_sand_valley 1 + 15 + 1 = 17, crimson_forest 12 + 6 = 18, warped_forest 13 + 7 = 20, basalt_deltas 3 + 15 = 18 placed features. Notes read from the lists:
`patch_soul_fire` is absent from crimson_forest; `patch_crimson_roots` appears only in soul_sand_valley; the two nether mushrooms (`*_nether`) appear in nether_wastes and basalt_deltas, the `*_normal` mushrooms (step 9) in the other three; `ore_gold_deltas` and `ore_quartz_deltas` replace the plain
variants only in basalt_deltas; basalt_deltas lists `spring_closed_double` where the others list `spring_closed`, and `spring_delta` where the others list `spring_open`. `basalt_deltas` has no step 9 list, so no `spring_lava` there (read).

### 6.6 Mob spawner lists (`gameplay/natural_mob_spawns`)

The attribute value is `{argument: MobSpawnSettings, modifier: overlay}`. `MobSpawnSettings` has two fields: `spawns_by_category` (map category -> list of `{type, weight, count}`; `count` is an int or an int provider such as `{type: uniform, min_inclusive, max_inclusive}`) and `spawn_costs` (map entity
type -> `{charge, energy_budget}`, doubles). Rows below are the values in the five files; the semantics of weight, count and cost are [18](18-mob-framework.md) section 6 and part 6.

**`overlay` modifier** (`MobSpawnSettingsModifier$Overlay.apply(subject, argument)`): if the subject defines no category and no cost, the result is the argument; if the argument defines none, the subject; if the argument's categories and cost keys
already include the subject's, the argument. Otherwise a new settings object is built: for each mob category in order, the **argument's list replaces the subject's list** when the argument defines that category (else the subject's list is kept); the cost maps are then merged (read: the subject's cost map is added first, then the argument's, so the last write wins on a key; a category defined by neither side is skipped, `getMobsInCategory` returning null and nothing being added, so the result has **no entry** and not an empty list). The categories are visited in the order of `MobCategory.values()` (`ALL_CATEGORIES`): monster, creature, ambient, axolotls, underground_water_creature, water_creature, water_ambient, misc. The Nether dimension type has no spawn attribute, so the subject is the default (empty) and the biome's settings apply unchanged (37-1 section 6.1).

| Biome | Category | Entity | Weight | Count |
|---|---|---|---|---|
| all five | creature | `strider` | 60 | uniform 1 to 2 |
| nether_wastes | monster | `ghast` | 50 | 4 |
| nether_wastes | monster | `zombified_piglin` | 100 | 4 |
| nether_wastes | monster | `magma_cube` | 2 | 4 |
| nether_wastes | monster | `enderman` | 1 | 4 |
| nether_wastes | monster | `piglin` | 15 | 4 |
| soul_sand_valley | monster | `skeleton` | 20 | 5 |
| soul_sand_valley | monster | `ghast` | 50 | 4 |
| soul_sand_valley | monster | `enderman` | 1 | 4 |
| crimson_forest | monster | `zombified_piglin` | 1 | uniform 2 to 4 |
| crimson_forest | monster | `hoglin` | 9 | uniform 3 to 4 |
| crimson_forest | monster | `piglin` | 5 | uniform 3 to 4 |
| warped_forest | monster | `enderman` | 1 | 4 |
| basalt_deltas | monster | `ghast` | 40 | 1 |
| basalt_deltas | monster | `magma_cube` | 100 | uniform 2 to 5 |

Spawn costs (`spawn_costs`; empty `{}` in nether_wastes, crimson_forest, basalt_deltas):

| Biome | Entity | charge | energy_budget |
|---|---|---|---|
| soul_sand_valley | `enderman`, `ghast`, `skeleton`, `strider` | 0.7 each | 0.15 each |
| warped_forest | `enderman` | 1.0 | 0.12 |

Only the categories `creature` and `monster` are listed; the other categories are not defined in these files (the biome has none of them: ambient, axolotls, underground water creature, water creature, water ambient, misc).

---

## 7. Fog, sky and ambient particles

### 7.1 Fog colour (`visual/fog_color`, a biome attribute)

| Biome | `visual/fog_color` | RGB | In `NetherBiomes` (ARGB int) |
|---|---|---|---|
| nether_wastes | `#330808` | (51, 8, 8) | -13432824 |
| soul_sand_valley | `#1b4745` | (27, 71, 69) | -14989499 |
| crimson_forest | `#330303` | (51, 3, 3) | -13434109 |
| warped_forest | `#1a051a` | (26, 5, 26) | -15071974 |
| basalt_deltas | `#685f70` | (104, 95, 112) | -9937040 |

How the colour is blended between biomes by the camera (the biome blend radius, Gaussian) and how the fog start and end distances apply (the Nether sets `fog_start_distance` 10 and `fog_end_distance` 96 in the dimension type, 37-1 section 2.2) is in [12](12-client-rendering.md) (attribute layers and fog); it is not repeated.
The `visual/fog_color` default is `#000000` and the Nether dimension type sets none, so these values are the whole of the fog colour in the Nether.

Biome tags touching the Nether biomes (pointers only): `spawns_warm_variant_farm_animals` and `spawns_warm_variant_frogs` both contain `#minecraft:is_nether` (covered in [19](19-mobs-land-friendly-and-neutral.md)), and the `has_structure/*` tags and `is_nether` are covered in 37-6 (section on tags).

### 7.2 Sky and water fog

* **Sky colour**: none of the five biome files sets `visual/sky_color` or any `visual/*` attribute except `fog_color` and `ambient_particles`; the Nether dimension type sets none either and its `skybox` is `none` (37-1 section 2.1), so there is no sky dome to colour in the Nether
  (the default `sky_color` `#000000` of [12](12-client-rendering.md) applies to any consumer that reads it). **Water fog colour**: not set, so the default `#050533` of 12 would apply to underwater fog (whether a player can be underwater in the Nether is not analysed; Open question 7).
* The Nether biomes set **no** `visual/water_fog_color`, `visual/sky_color`, `visual/cloud_color`, `visual/sunrise_sunset_color`.

### 7.3 Ambient particles (`visual/ambient_particles`, modifier `append`)

The value is `{argument: [{particle: {type: <particle id>}, probability}], modifier: append}`; `particle` is a particle-options object whose `type` field holds the id (the ids in the table below are those `type` values); the `append` modifier of the attribute type concatenates the argument list after the running list ([23](23-registry-loading.md) section 8.4). The consumer (`ClientLevel.doAnimateTick` step) is [42](42-particles-4-block-item-dust-ambient.md) section 4.

| Biome | particle | probability |
|---|---|---|
| nether_wastes | none | none |
| soul_sand_valley | `minecraft:ash` | 0.00625 |
| crimson_forest | `minecraft:crimson_spore` | 0.025 |
| warped_forest | `minecraft:warped_spore` | 0.01428 |
| basalt_deltas | `minecraft:white_ash` | 0.118093334 |

---

## 8. Worked examples (computed)

Computed with the scratch reference implementation of sections 3.3, 3.4, 3.5 and 4 (a `PerlinNoise` and a `LegacyRandomSource` written from this document's text). They check the text against itself; they were not observed from the game.

**8.1 Constants.**

| Item | Value |
|---|---|
| `nf` | 1.1702396884564004 |
| `f = (float)(nf * 0.9494731054427981)` | 1.1111111640930176 |
| Layer amplitudes, A0/B0 and A1/B1 | 0.7407407760620117 and 0.37037038803100586 |
| `LegacyRandomSource(0)` first three `nextInt()` | -1155484576, -723955400, 1033096058 |
| `LegacyRandomSource(0)` first two `nextDouble()` | 0.730967787376657, 0.24053641567148587 |
| temperature noise, world seed 0: offsets of slot 0 `PerlinNoise` (x, y, z) | 133.81694437294942, 197.47238661190704, 128.37566681302854 |
| temperature noise, world seed 0: offsets of slot 1 `PerlinNoise` (x, y, z) | 201.36938074760664, 194.97118104245908, 149.07128561683226 |

(The offsets are those of stack A of the temperature noise: the zero-octave noise, five skips of 262 draws, slot 1, then slot 0.)

**8.2 Biome at a block column, deterministic tie rule.** World seed 0 (temperature seed `0 + 0`, vegetation seed `0 + 1`):

| Block (x, z) | Quart (qx, qz) | Sample position `(4 qx, 4 qz)` | T value | H value | Quantised (T, H) | Winner |
|---|---|---|---|---|---|---|
| (0, 0) | (0, 0) | (0, 0) | 0.1173812747001648 | -0.045639894902706146 | (1173, -456) | nether_wastes |
| (100, -200) | (25, -50) | (100, -200) | -0.10468057543039322 | -0.022082790732383728 | (-1046, -220) | nether_wastes |
| (1000, 1000) | (250, 250) | (1000, 1000) | -0.06238699331879616 | -0.23839247226715088 | (-623, -2383) | nether_wastes |
| (-333, 512) | (-84, 128) | (-336, 512) | -0.2108910083770752 | 0.4453885555267334 | (-2108, 4453) | warped_forest |

**8.3 Same positions, world seed 12345** (temperature seed 12345, vegetation seed 12346):

| Block (x, z) | Quantised (T, H) | `F` (wastes, soul, crimson, warped, basalt) | Winner |
|---|---|---|---|
| (0, 0) | (620, -936) | 1 260 496; 16 900 496; 12 300 496; 49 682 996; 35 522 996 | nether_wastes |
| (100, -200) | (241, 7195) | 51 826 106; 148 776 106; 65 898 106; 18 938 606; 82 298 606 | warped_forest |
| (1000, 1000) | (2535, -4985) | 31 276 450; 6 426 450; 26 996 450; 120 188 950; 84 688 950 | soul_sand_valley |
| (-333, 512) | (-1198, -729) | 1 966 645; 19 676 645; 27 550 645; 48 319 145; 18 049 145 | nether_wastes |

**8.4 Fitness by hand.** Target `(T, H) = (-3000, 0)`: wastes `9 000 000`; basalt `(−3000+5000)^2 + 0 + 3 062 500 = 4 000 000 + 3 062 500 = 7 062 500`: basalt_deltas wins (consistent with the boundary `T <= -2807`).

**8.5 Boundary values** (computed): `(0, -2500)`: wastes = soul = 6 250 000 (tie, wastes first in both orders); `(2000, 0)`: wastes = crimson = 4 000 000 (tie); `(0, 3906)`: wastes 15 256 836 < warped 15 259 336 (wastes wins); `(0, 3907)`: warped 15 257 149 < wastes 15 264 649;
`(-2806, 0)`: wastes 7 873 636 < basalt 7 876 136; `(-2807, 0)`: basalt 7 871 749 < wastes 7 879 249.

---

## 9. Validation (checkable facts)

| # | Check | Expected |
|---|---|---|
| V1 | `nether.json` of the preset list | `{"preset": "minecraft:nether"}` |
| V2 | preset rows | 5 points in the order nether_wastes, soul_sand_valley, crimson_forest, warped_forest, basalt_deltas; offsets 0, 0, 0, 3750, 1750 (quantised) |
| V3 | every point | all of C, E, D, W are the point 0; T and H as in section 2.2 |
| V4 | router | `continents`, `erosion`, `depth`, `ridges` constant 0.0; `temperature` and `vegetation` are `noise` nodes with `xz_scale` 0.25, `y_scale` 0.0 |
| V5 | noise files | both `nether/temperature` and `nether/vegetation`: `base_octave` -7, `octave_count` 2, `base_amplitude` 0.9494731054427981 |
| V6 | noise seeding | `LegacyRandomSource(worldSeed + 0)` temperature, `worldSeed + 1` vegetation; stream order per 3.4 (A then B); both noises `normalize = ENABLED`, the `LEGACY` branch is not taken; the method is an instance method using the holder object's own `nf` |
| V7 | `nf` and `f` | 1.1702396884564004 and 1.1111111640930176 |
| V8 | search | 5 leaves, one root node, sorted order wastes, crimson, soul, basalt, warped; strict-less replacement |
| V9 | biome count | each biome file has `temperature` 2.0, `downfall` 0.0, `has_precipitation` false, `water_color` `#3f76e4`, carvers `minecraft:nether_cave` |
| V10 | `features` lists | lengths 10, 10, 10, 10 and 8 (basalt_deltas); non-empty steps as in 6.5; placed-feature counts 18, 17, 18, 20, 18 |
| V11 | fog colours | `#330808`, `#1b4745`, `#330303`, `#1a051a`, `#685f70` |
| V12 | particles | none, ash 0.00625, crimson_spore 0.025, warped_spore 0.01428, white_ash 0.118093334 |
| V13 | spawns | per 6.6: every biome has the strider creature entry (60, uniform 1 to 2); monster lists as in the table |
| V14 | stored biomes | per chunk 16 sections x 64 cells, all cells of a column equal |
| V15 | tie rule | `(3000, -3300)` gives crimson_forest under the deterministic rule of 4.3 |

---

## Open questions

1. **R-tree history dependence.** On exact ties the vanilla result depends on the thread-local `lastResult`. Section 4.3 recommends treating it as null. Whether a vanilla chunk generated on a worker thread can yield a different tie result than a fresh single-threaded run (surely yes in principle) has not been measured; no vanilla world was compared (no execution).
2. **Sampling order and caches.** Read: `createResolverForChunk` fills six buffers through `sampleVolume`; for the Nether `NoiseFunction$Sampler.sampleVolume` zero-fills the buffer and calls `Noise.addToVolume` with the xz scale, y scale and amplitude 1.0, and `NoiseStack.addToVolume` adds per layer using frequency times scale and layer amplitude times the incoming amplitude, in the same layer order and float accumulation as `NoiseStack.get` (the 0.25 scale is a power of two, so the product is exact). `PerlinNoise.addToVolume` was **not** read, so whether it matches a direct per-point evaluation in the last bit stays open for that class only.
3. **The 262 skip.** `skipOctave` consumes exactly 262 draws. That this equals the draw count of a real `PerlinNoise` construction on the legacy generator when `nextInt(bound)` never rejects (3 doubles x 2 draws + 256 draws) is a deduction (inferred). Whether a rejection can occur in the real construction (making a real octave longer than 262 draws) was not checked; the skip is a constant either way, and the stream after it is the one the artifact uses.
4. **Chunk resolver equality.** `createResolverForChunk` builds a `DensityVolume` at `QuartPos.toBlock(origin)` with cell size 4,4,4 (read), so the sample points are `(4 qx, 4 qy, 4 qz)`; only the equality of the values with `Sampler.sample` depends on Open question 2 (`PerlinNoise.addToVolume`).
5. **Sound and music engines.** The client behaviour of `ambient_sounds` (loop selection, mood checks with `block_search_extent`, `offset`, `tick_delay`, additions with `tick_chance`) and of `MusicManager` (delays, interruption) is not specified here; only the parameters. A later audio round can read `BiomeAmbientSoundsHandler` and `MusicManager`.
6. **`overlay` details.** Closed by reading (section 6.6). Whether the spawner treats a missing category differently from an empty list is part 6 / 18 business.
7. **Water fog.** The default `visual/water_fog_color` applies in the Nether biomes (not set); whether anything in the Nether can show water-fog (a player in a water cell, such as via a bucket placing water inside the Nether where it evaporates) was not analysed.
8. **Biome registry ids.** The numeric ids of the five biomes in the `worldgen/biome` registry (needed for chunk palettes) are in [46](46-registry-ids.md) / [04](04-registry-sync.md); they were not re-derived here.
9. **Statistical distribution.** The share of each Nether biome was not measured; only the boundaries (4.2) are derived.
10. **Count check.** The feature counts of 6.5 were tallied by hand from the JSON lists; a mechanical recount by the reviewer is welcome.
11. **Seed-dependent worked values.** The `LegacyRandomSource` draws, Perlin offsets and the T and H samples in sections 8.2 and 8.3 are marked (computed): they come from a scratch implementation and were not independently re-derived in review. `BiomeManager.getBiome` (the quart-resolution lookup used in section 5) was not re-read in the fix round either; searched: the section 5 statements rest on the first-round read only.
