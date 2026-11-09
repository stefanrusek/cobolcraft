# 10 — World generation: overworld terrain

This document specifies how the vanilla integrated server generates the **terrain of the overworld**: random sources and seeding, the noise primitives, the climate parameters and the multi-noise biome source, the density functions that shape the ground, aquifers and fluid levels, the surface rules (grass, sand, bedrock, deepslate, badlands bands, snow and ice), and the order in which chunk stages run.

Caves, carvers, ore veins and decoration features are **not** covered here; they are specified in [11-world-generation-caves-and-ores.md](11-world-generation-caves-and-ores.md). Where terrain depends on a cave-related density function (the final density embeds them) this document says so and treats it as an input specified by document 11.

| Item | Value |
|---|---|
| Covers | Overworld terrain generation (noise settings `minecraft:overworld`, world preset `minecraft:normal`), with the differences of the amplified and large-biomes presets listed in §12 |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, world data version 5023) |
| Method | Static reading of the shipped bytecode (`javap`) of `net.minecraft.world.level.levelgen.*`, `net.minecraft.world.level.biome.*`, `net.minecraft.world.level.chunk.*` and `net.minecraft.util.*`, plus the data-generated JSON under `data/minecraft/worldgen/` and `data/minecraft/dimension_type/` inside the jar. No execution of the artifact. |
| Worked examples | Computed with a hand-written reference implementation of this document's own algorithms (scratch code, not part of the repository). They are consistency checks of the text, **not** values observed from the artifact; each is marked "(computed, unverified against the artifact)". |
| Operator decision | World generation is to be nearly identical to vanilla's, superseding feature 001 FR-015 for world generation (ticket CC-0001, "As a Player, I want worlds generated like vanilla's"). |

Sources cited by class name, as in the other documents: `RandomSupport`, `Xoroshiro128PlusPlus`, `XoroshiroRandomSource`, `LegacyRandomSource`, `WorldgenRandom$Algorithm`, `RandomState`, `Noises`, `GradientNoise`, `PerlinNoise`, `SmearedPerlinNoise`, `SimplexNoise`, `NoiseStack`, `NormalNoise`, `BlendedNoise`, `DensityFunctions`, `DensityFunction` and the `densityfunction.op` / `densityfunction.generator` classes, `CubicSpline`, `NoiseGeneratorSettings`, `NoiseRouter`, `NoiseChunk`, `NoiseBasedChunkGenerator`, `Aquifer$NoiseBasedAquifer`, `Climate`, `OverworldBiomeBuilder`, `MultiNoiseBiomeSource`, `BiomeManager`, `MaterialSystem`, `MaterialRuleContext`, the `material.condition.*` and `material.rule.*` classes, `ChunkPyramid`, `ChunkStatusTasks`, `Biome`.

---

## 1. Overview and reading guide

### 1.1 Pipeline at a glance

Generating one chunk column of the overworld is a pure function of the world seed and the chunk coordinates, apart from structures (which can add a density term, §11.2) and from the neighbour rules in §11:

1. **Seed**: the 64-bit world seed becomes a Xoroshiro128++ generator, then a master *positional factory* `P` (§2.5). Every named noise, every named random and the aquifer take their own deterministic random from `P` by hashing a name.
2. **Climate**: six smooth fields (temperature, humidity, continentalness, erosion, depth, weirdness) are evaluated from the noise router (§6). A nearest-neighbour search in 7-dimensional parameter space (§7) maps them to a biome at 4×4×4-block resolution. Biomes are stored per chunk **before** terrain (§11).
3. **Density**: the router's `final_density` is evaluated for every block of the 16×384×16 column (§6.5). Positive density is solid. The aquifer (§9) decides, for the non-solid cells, between air, water and lava.
4. **Surface rules**: a column pass replaces the default stone by grass, dirt, sand, terracotta bands, snow, deepslate, bedrock and so on (§10), looking at the biome at each block.
5. **Carvers** and later stages (outside this document) follow in the same stage (§11).

### 1.2 Number formats

- **All density and noise values are 32-bit IEEE floats** (Java `float`): the result of every noise `get`, every density function and every spline. Intermediate arithmetic inside the improved-noise gradient/lerp code is float as well. Coordinates and scale factors are doubles (64-bit) when they are multiplied by block coordinates; they are converted to float only where stated.
- The artifact is 26.3, a later generation of the code than the 1.18–1.21 era: noise evaluation is float-based, density functions are data (JSON) and there is a single `cache` node. Where this differs from what older documentation of vanilla says, this document follows the artifact.
- An implementation that uses 64-bit floats will drift from the reference by about 1e-7 per operation, which flips block boundaries rarely but not never. Reproduce the float steps where bit-exact terrain is required.

### 1.3 Conventions

- `floor` is the mathematical floor; `Mth.floor(double)` is `(int) Math.floor(d)`.
- `x`, `y`, `z` are block coordinates unless "quart" is stated. A *quart* is a 4-block unit: `quart = block >> 2` (arithmetic shift), `block = quart << 2`.
- `lerp(t, a, b) = a + t * (b - a)`. `clamp(v, lo, hi)` is the usual. `map(v, a0, a1, b0, b1) = lerp(inverseLerp(v, a0, a1), b0, b1)` with `inverseLerp(v, a, b) = (v - a) / (b - a)` (no clamp); `clampedMap` clamps the interpolation factor to [0, 1] first. `quantize(v, n) = floor(v / n) * n` (integer result).
- "Identifier hash name" means the string form of a resource identifier including the namespace, for example `minecraft:continentalness`.

---

## 2. Random sources and seeding

### 2.1 Xoroshiro128++ (the only generator the overworld uses)

`NoiseGeneratorSettings` for `minecraft:overworld` has `legacy_random_source = false`, so every random in this document is Xoroshiro128++ (`Xoroshiro128PlusPlus`, `XoroshiroRandomSource`). The legacy generator is described in §2.6 for completeness.

State: two unsigned 64-bit words `lo`, `hi`. If both are zero at construction they are replaced by `lo = 0x9E3779B97F4A7C15` (decimal -7046029254386353131, "golden ratio") and `hi = 0x6A09E667F3BCC909` (7640891576956012809, "silver ratio").

`nextLong()` (all arithmetic modulo 2^64, `rotl` = rotate left):

1. `result = rotl(lo + hi, 17) + lo`
2. `hi = hi xor lo`
3. `lo = rotl(lo, 49) xor hi xor (hi << 21)`
4. `hi = rotl(hi, 28)`
5. return `result`

### 2.2 Seeding from a 64-bit seed

`upgradeSeedTo128bit(seed)`:

1. `lo0 = seed xor 0x6A09E667F3BCC909`
2. `hi0 = lo0 + 0x9E3779B97F4A7C15` (mod 2^64)
3. `lo = mixStafford13(lo0)`, `hi = mixStafford13(hi0)`

`mixStafford13(z)`: `z = (z xor (z >>> 30)) * 0xBF58476D1CE4E5B9` (decimal -4658895280553007687); `z = (z xor (z >>> 27)) * 0x94D049BB133111EB` (decimal -7723592293110705685); return `z xor (z >>> 31)`. (`>>>` is the logical shift; multiplications mod 2^64.)

`new XoroshiroRandomSource(seed)` and `setSeed(seed)` use this seeding. A constructor taking an explicit `(lo, hi)` pair, or a 128-bit seed, uses the words **as given, without mixing** (this matters for `at` and `fromHashOf` below).

### 2.3 Derived operations

| Operation | Definition |
|---|---|
| `nextInt()` | the low 32 bits of `nextLong()`, as a signed int |
| `nextInt(bound)` (bound > 0) | Lemire's method on the unsigned low 32 bits: `r = unsigned(nextInt())`, `m = r * bound` (64-bit), `low = m & 0xFFFFFFFF`. If `low < bound`: `threshold = (2^32 - bound) mod bound` (computed as the unsigned remainder of `(~bound + 1)` by `bound`); while `low < threshold`, draw a new `r` and recompute `m`, `low`. Result `m >> 32`. |
| `nextInt(lo, hi)` | `lo + nextInt(hi - lo)` (requires `hi > lo`) |
| `nextIntBetweenInclusive(lo, hi)` | `nextInt(hi - lo + 1) + lo` |
| `nextLong()` | as §2.1 |
| `nextBoolean()` | `(nextLong() & 1) != 0` |
| `nextFloat()` | `(float)(nextLong() >>> 40) * 5.9604645E-8f` (24 bits; the multiplication is a float multiplication) |
| `nextDouble()` | `(double)(nextLong() >>> 11) * 1.1102230246251565E-16` (53 bits) |
| `fork()` | a new generator with `(lo, hi) = (nextLong(), nextLong())`, the first draw being `lo` |
| `forkPositional()` | a positional factory (§2.4) with `(lo, hi) = (nextLong(), nextLong())`, the first draw being `lo` |
| `nextGaussian()` | Marsaglia polar method; **not used** by terrain generation |

### 2.4 Positional random factories

A positional factory holds two words `(Flo, Fhi)` and creates generators by position or by name:

| Method | Result |
|---|---|
| `at(x, y, z)` | generator with `lo = getSeed(x, y, z) xor Flo`, `hi = Fhi` (no mixing) |
| `fromHashOf(name)` | `md5 = MD5(UTF-8 bytes of name)`; `a = bytes[0..7]` and `b = bytes[8..15]`, each read **big-endian** as a 64-bit word; generator with `lo = a xor Flo`, `hi = b xor Fhi` (no mixing) |
| `fromSeed(s)` | generator with `lo = s xor Flo`, `hi = s xor Fhi` |

`getSeed(x, y, z)` (`Mth.getSeed`), with 32-bit int arithmetic where stated, long (64-bit) otherwise:

1. `l = (int)(x * 3129871)` (32-bit overflowing multiply, then sign-extended to long) `xor` `(z * 116129781L)` `xor` `y`
2. `l = l * l * 42317861L + l * 11L` (64-bit wrapping)
3. return `l >> 16` (**arithmetic** shift)

### 2.5 From the world seed to named randoms

1. `master = new XoroshiroRandomSource(worldSeed)` (§2.2).
2. `P = master.forkPositional()`: `P.Flo = master.nextLong()`, then `P.Fhi = master.nextLong()`. This is `RandomState.random`.
3. Every named noise: `P.fromHashOf("<identifier>")`, for example `P.fromHashOf("minecraft:continentalness")`. The identifier is the resource key of the noise (§3.6).
4. The old-style blended 3D noise (§3.4): `P.fromHashOf("minecraft:terrain")`.
5. Named positional factories (`RandomState.getOrCreateRandomFactory(id)`): `P.fromHashOf(id).forkPositional()`. Used for the aquifer (`minecraft:aquifer`) and for the vertical-gradient surface conditions (`minecraft:bedrock_floor`, `minecraft:deepslate`).
6. The surface-depth random (§10.3) uses `P.at(x, 0, z)` directly (no hashed name).
7. The terracotta bands (§10.6) use `P.fromHashOf("minecraft:clay_bands")`.

### 2.6 Legacy generator (reference only)

`LegacyRandomSource` is the `java.util.Random` linear congruential generator: 48-bit state, `seed = (seed xor 0x5DEECE66D) & (2^48-1)` on `setSeed`, `next(bits)`: `seed = (seed * 0x5DEECE66D + 11) & (2^48-1)`, result `(int)(seed >>> (48 - bits))`. Defaults: `nextInt() = next(32)`; `nextInt(bound)`: if `bound` is a power of two `(int)((bound * (long)next(31)) >> 31)`, else the classic rejection loop on `next(31) % bound`; `nextLong() = ((long)next(32) << 32) + next(32)`; `nextFloat() = next(24) * 5.9604645E-8f`; `nextDouble() = (((long)next(26) << 27) + next(27)) * 1.1102230246251565E-16`. Its positional factory is `at(x,y,z) -> new Legacy(getSeed(x,y,z) xor seed)`. The overworld terrain does not use it except for three fixed-seed simplex noises in §10.8 (seeds 1234, 2345, 3456). For the `WorldgenRandom` wrapper around such sources (used by carvers and decoration) see [11-world-generation-caves-and-ores.md](11-world-generation-caves-and-ores.md) §4.

### 2.7 Worked examples (computed, unverified against the artifact)

| Item | Value |
|---|---|
| Seed 0 after `upgradeSeedTo128bit` | `lo = 0x3564B439CD1E1F16`, `hi = 0x63CFC62A2B097592` |
| First four `nextLong()` of `new XoroshiroRandomSource(0)` | 3038984756725240190, -3694039286755638414, 4633751808701151732, 2160572957309072155 |
| First five `nextInt(100)` of seed 0 | 96, 18, 15, 31, 88 |
| First two `nextDouble()` of seed 0 | 0.16474369376959186, 0.7997457290026366 |
| `P` for world seed 0 | `Flo = 0x2A2CA488F66F517E`, `Fhi = 0xCCBC22D72E97C372` |
| `P` for world seed 12345 | `Flo = 0x8F5558A8036890FB`, `Fhi = 0x725FE51AD193097E` |
| MD5 of `minecraft:continentalness` | `83886c9d0ae3a662afa638a61b42e8ad` (so `a = 0x83886C9D0AE3A662`, `b = 0xAFA638A61B42E8AD`) |
| Generator for noise `minecraft:continentalness`, seed 0 | `lo = 0xA9A4C815FC8CF71C`, `hi = 0x631A1A7135D52BDF` |
| `getSeed(1, 2, 3)` | -33674130277896 |

---

## 3. Noise primitives

### 3.1 Improved (gradient) noise: `PerlinNoise`

One instance is a single octave of 3D gradient noise with a 256-entry permutation table and three random offsets.

**Construction from a random source `r`** (call order is fixed):

1. `offsetX = r.nextDouble() * 256.0`, then `offsetY = r.nextDouble() * 256.0`, then `offsetZ = r.nextDouble() * 256.0` (three draws, in that order).
2. `perm[i] = i` for `i = 0..255`.
3. For `i = 0..255`: `j = r.nextInt(256 - i)`; swap `perm[i]` and `perm[i + j]`.

**Gradient table** (16 entries; the index is `hash & 15`):

| 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| (1,1,0) | (-1,1,0) | (1,-1,0) | (-1,-1,0) | (1,0,1) | (-1,0,1) | (1,0,-1) | (-1,0,-1) | (0,1,1) | (0,-1,1) | (0,1,-1) | (0,-1,-1) | (1,1,0) | (0,-1,1) | (-1,1,0) | (0,-1,-1) |

`gradDot(h, fx, fy, fz) = gx*fx + gy*fy + gz*fz` of entry `h & 15`, evaluated left to right in float.

**`wrap(d)`** (keeps coordinates precise far from the origin): if `-HALF <= d < HALF` with `HALF = nextDown(16777216.0) = 16777215.999999998`, return `d`; otherwise `d - floor(d / 33554432.0 + 0.5) * 33554432.0`.

**`get(x, y, z)`** (doubles in, float out):

1. `x' = wrap(x) + offsetX`, `y' = wrap(y) + offsetY`, `z' = wrap(z) + offsetZ` (doubles).
2. `ix = floor(x')`, `iy = floor(y')`, `iz = floor(z')`; `fx = (float)(x' - ix)`, `fy = (float)(y' - iy)`, `fz = (float)(z' - iz)`.
3. `A = perm(ix)`, `B = perm(ix + 1)`, `AA = perm(A + iy)`, `AB = perm(A + iy + 1)`, `BA = perm(B + iy)`, `BB = perm(B + iy + 1)`, where `perm(i) = perm[i & 255]`.
4. Eight corner gradients (float): `g000 = gradDot(perm(AA + iz), fx, fy, fz)`, `g100 = gradDot(perm(BA + iz), fx-1, fy, fz)`, `g010 = gradDot(perm(AB + iz), fx, fy-1, fz)`, `g110 = gradDot(perm(BB + iz), fx-1, fy-1, fz)`, `g001 = gradDot(perm(AA + iz + 1), fx, fy, fz-1)`, `g101 = gradDot(perm(BA + iz + 1), fx-1, fy, fz-1)`, `g011 = gradDot(perm(AB + iz + 1), fx, fy-1, fz-1)`, `g111 = gradDot(perm(BB + iz + 1), fx-1, fy-1, fz-1)`.
5. `sx = smooth(fx)`, `sy = smooth(fyS)`, `sz = smooth(fz)` with `smooth(t) = t*t*t*(t*(t*6 - 15) + 10)` (float). For the plain noise `fyS = fy`.
6. Result `lerp(sz, lerp(sy, lerp(sx, g000, g100), lerp(sx, g010, g110)), lerp(sy, lerp(sx, g001, g101), lerp(sx, g011, g111)))`, all float.

`get(x, z)` of the 2D form is `get(x, 0.0, z)`.

Standard deviation of one octave: 0.2702247831245211 (used by the normalisation in §3.3).

### 3.2 Octave stacks: `NoiseStack`

A stack is an ordered list of layers `(noise, frequency (double), amplitude (float))`. For `get(x, y, z)` (doubles in, float out):

`acc = 0f; for each layer in order: acc = acc + amplitude * noise.get(x * frequency, y * frequency, z * frequency)` (the inner product and the sum are float operations). The 2D form omits `y`.

### 3.3 Normal noise: `NormalNoise` and the noise JSON files

Every `data/minecraft/worldgen/noise/*.json` file has fields:

| Field | Meaning | Default |
|---|---|---|
| `base_octave` (int) | exponent of the first octave's frequency: `2^base_octave` | required |
| `octave_count` (int, 1..32) | number of octave slots | 1 |
| `base_amplitude` (double) | amplitude of the first slot before modifiers | required |
| `amplitude_modifiers` (list of `octave_count` doubles, each 0..1000000) | per-slot factors; an empty list means 1.0 for every slot | empty |
| `normalize` | `enabled`, `disabled` or `legacy` | `enabled` (no file in the overworld sets it) |

**Octave list** (`buildOctaves`): `freq = 2^base_octave`, `amp = base_amplitude`. If normalisation is not `disabled`: `amp = amp * 2^(n-1) / (2^n - 1)` where `n = octave_count`. For slot `i = 0..n-1`: `m = amplitude_modifiers[i]` (1.0 if the list is empty); **if `m != 0`** an octave `(index = base_octave + i, frequency = freq, amplitude = amp * m)` is added; then (always) `freq = freq * 2`, `amp = amp * 0.5`. Slots with modifier 0 therefore advance the frequency but produce no octave and **consume no random numbers**.

**Normalisation factor** `nf`: `sum = Σ amplitude_i` over the octaves, `dev = sqrt(Σ (0.2702247831245211 * |amplitude_i|)^2)`; if `dev = 0` then `nf = 0`, else `nf = (sum * 0.3333333333333333) / (dev * sqrt(2))`. (The `legacy` mode rescales with a different expectation and is not used by any overworld noise.)

**Instantiation** (`NormalNoise.create(r)`, where `r = P.fromHashOf(identifier)`; §2.5):

1. `A = r.forkPositional()`, then `B = r.forkPositional()` (two consecutive forks of the same `r`).
2. For each octave in list order: `noiseA = PerlinNoise(A.fromHashOf("octave_" + index))`, `noiseB = PerlinNoise(B.fromHashOf("octave_" + index))` (`index` is the signed decimal octave index, e.g. `octave_-9`), then `a = (float)(nf * amplitude)`.
3. Layers appended in this order for every octave: `(noiseA, frequency, a)` then `(noiseB, frequency * 1.0181268882175227, a)`.

The value of the normal noise at `(x, y, z)` is the `NoiseStack` value (§3.2) of those layers. So each octave contributes two independent improved-noise samples, the second at a 1.0181268882175227 times higher frequency, both weighted by the same `a`.

Checks: a one-octave noise has layer amplitude `5/6 = 0.8333333` (e.g. `aquifer_barrier`); `minecraft:offset` (octaves -3, -2, -1) has layer amplitudes 2/3, 1/3, 1/6 (§3.6 and §14).

### 3.4 Smeared noise and the old-style blended 3D noise (`old_blended_noise`)

`SmearedPerlinNoise(r, fudgeYScale)` is a `PerlinNoise` (same construction) whose `get(x, y, z)` differs in step 4: with `yFrac = y' - iy` kept as a double,

1. `base = y` (the unwrapped y argument of this call) if `0 <= y < yFrac`, otherwise `base = yFrac`;
2. `fudge = floor(base / fudgeYScale + 1.0000000116860974E-7) * fudgeYScale` (doubles);
3. the gradients use `fyG = (float)(yFrac - fudge)` in place of `fy` (for all `fy` terms, including `fy - 1`), but the smoothing in step 5 uses `fyS = (float) yFrac`.

`BlendedNoise` (density-function type `minecraft:old_blended_noise`, parameters `xz_scale`, `y_scale`, `xz_factor`, `y_factor`, `smear_scale_multiplier`). Constants: base scale 684.412, limit factor 0.9999847412109375 (= 65535/65536), main factor 12.75 (= 255/20), limit first octave -15, main first octave -7.

Derived: `xzMul = 684.412 * xz_scale`, `yMul = 684.412 * y_scale`, `smear = yMul * smear_scale_multiplier`.

1. Random: `r = P.fromHashOf("minecraft:terrain")` (§2.5).
2. Three octave stacks are built **in this order from the same `r`**: `minLimit = fbm(r, -15, smear, 0.9999847412109375)`, `maxLimit = fbm(r, -15, smear, 0.9999847412109375)`, `main = fbm(r, -7, smear / y_factor, 12.75)`.
3. `fbm(r, firstOctave, yScale, ampBase)`: `n = -firstOctave + 1`; `ampBase = ampBase / (2^n - 1)`; `freq = 1.0`; for `k = n - 1` down to `0` (so **highest frequency first**): add layer `(SmearedPerlinNoise(r, yScale * freq), frequency = freq, amplitude = (float) ampBase)`; then `freq = freq / 2`, `ampBase = ampBase * 2`. (16 layers for -15, 8 layers for -7; the first constructed noise is the layer with frequency 1.)
4. Value at `(x, y, z)`: `lo = minLimit.get(x * xzMul, y * yMul, z * xzMul)`, `hi = maxLimit.get(same)`, `m = main.get(x * xzMul / xz_factor, y * yMul / y_factor, z * xzMul / xz_factor)`; `t = clamp(m + 0.5f, 0, 1)`; result `lerp(t, lo, hi)` (float; evaluated lazily: if `t == 0` only `lo`, if `t == 1` only `hi`).

For the overworld (`overworld/base_3d_noise`): `xz_scale 0.25, y_scale 0.125, xz_factor 80.0, y_factor 160.0, smear_scale_multiplier 8.0`, i.e. `xzMul = 171.103`, `yMul = 85.5515`, `smear = 684.412`, main smear `4.277575`.

### 3.5 Simplex noise (frozen-ocean test only)

`SimplexNoise(r, true)` is built like `PerlinNoise` (three offset draws, then the permutation shuffle), but the three offsets are multiplied by 0 instead of 256 when the flag is true (the draws still happen). 2D `get(x, y)`: `x' = x + offsetX`, `y' = y + offsetY`; `s = (x' + y') * F2`, `i = floor(x' + s)`, `j = floor(y' + s)`, `F2 = 0.5 * (sqrt(3) - 1)`, `G2 = (3 - sqrt(3)) / 6`; `t = (i + j) * G2`; `x0 = x' - (i - t)`, `y0 = y' - (j - t)`; `(i1, j1) = (1, 0)` if `x0 > y0` else `(0, 1)`; `x1 = x0 - i1 + G2`, `y1 = y0 - j1 + G2`, `x2 = x0 - 1 + 2*G2`, `y2 = y0 - 1 + 2*G2`; `ii = i & 255`, `jj = j & 255`; gradient indices `g0 = perm(ii + perm(jj)) mod 12`, `g1 = perm(ii + i1 + perm(jj + j1)) mod 12`, `g2 = perm(ii + 1 + perm(jj + 1)) mod 12`; corner term `c = 0.5 - x^2 - y^2`, contribution `0` if `c < 0`, else `c^4 * (gradient[g] . (x, y, 0))` with the gradient table of §3.1 (first 12 entries); result `(float)(70.0 * (n0 + n1 + n2))`.

### 3.6 Table of all noise definitions in the jar

Normalisation factor `nf` is computed from the formulas of §3.3. Noises used only by caves, ores, nether or end are listed because the files exist; their use is specified elsewhere.

| Noise (`minecraft:` id) | `base_octave` | `octave_count` | `base_amplitude` | `amplitude_modifiers` | Normalisation factor | Used by |
|---|---|---|---|---|---|---|
| `aquifer_barrier` | -3 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | aquifer barrier (§9) |
| `aquifer_fluid_level_floodedness` | -7 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | aquifer (§9) |
| `aquifer_fluid_level_spread` | -5 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | aquifer (§9) |
| `aquifer_lava` | -1 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | aquifer lava choice (§9) |
| `badlands_pillar` | -2 | 4 | 0.939546696581729 | (none: all 1.0) | 1.4191240714 | eroded badlands pillars (§10.7) |
| `badlands_pillar_roof` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | eroded badlands pillars (§10.7) |
| `badlands_surface` | -6 | 3 | 0.9381732587751008 | (none: all 1.0) | 1.3323764969 | eroded badlands pillars (§10.7) |
| `calcite` | -9 | 4 | 0.939546696581729 | (none: all 1.0) | 1.4191240714 | surface rule stony_peaks |
| `cave_cheese` | -8 | 9 | 0.8361300524356068 | [0.5, 1, 2, 1, 2, 1, 0, 2, 0] | 1.7718314001 | caves / ores / other (doc 11) or non-overworld |
| `cave_entrance` | -7 | 3 | 0.8500634887071167 | [0.4, 0.5, 1] | 1.4704784014 | caves / ores / other (doc 11) or non-overworld |
| `cave_layer` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `clay_bands_offset` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | badlands bands (§10.6) |
| `continentalness` | -9 | 9 | 0.8880832896205223 | [1, 1, 2, 2, 2, 1, 1, 1, 1] | 1.6890307672 | climate (§6.1) |
| `continentalness_large` | -11 | 9 | 0.8880832896205223 | [1, 1, 2, 2, 2, 1, 1, 1, 1] | 1.6890307672 | large_biomes preset |
| `erosion` | -9 | 5 | 1.063180125160734 | [1, 1, 0, 1, 1] | 1.3063533225 | climate (§6.1) |
| `erosion_large` | -11 | 5 | 1.063180125160734 | [1, 1, 0, 1, 1] | 1.3063533225 | large_biomes preset |
| `gravel` | -8 | 4 | 0.939546696581729 | (none: all 1.0) | 1.4191240714 | surface rule stony_shore |
| `gravel_layer` | -8 | 9 | 1.0569606747151457 | [1, 1, 1, 1, 0, 0, 0, 0, 0.013333333333333334] | 1.4191634901 | caves / ores / other (doc 11) or non-overworld |
| `ice` | -4 | 4 | 0.939546696581729 | (none: all 1.0) | 1.4191240714 | surface rule frozen_peaks |
| `iceberg_pillar` | -6 | 4 | 0.939546696581729 | (none: all 1.0) | 1.4191240714 | frozen ocean icebergs (§10.8) |
| `iceberg_pillar_roof` | -3 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | frozen ocean icebergs (§10.8) |
| `iceberg_surface` | -6 | 3 | 0.9381732587751008 | (none: all 1.0) | 1.3323764969 | frozen ocean icebergs (§10.8) |
| `jagged` | -16 | 16 | 1.0383104856073737 | (none: all 1.0) | 1.5107498891 | sloped cheese (§6.2) |
| `nether_state_selector` | -4 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `nether_wart` | -3 | 4 | 1.3827102115748344 | [1, 0, 0, 0.9] | 0.9642897855 | caves / ores / other (doc 11) or non-overworld |
| `netherrack` | -3 | 4 | 1.4659491761370222 | [1, 0, 0, 0.35] | 0.9095358523 | caves / ores / other (doc 11) or non-overworld |
| `noodle` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `noodle_ridge_a` | -7 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `noodle_ridge_b` | -7 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `noodle_thickness` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `offset` | -3 | 4 | 0.9381732587751005 | [1, 1, 1, 0] | 1.3323764969 | shift_a / shift_b (§4.2) |
| `ore_gap` | -5 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `ore_vein_a` | -7 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `ore_vein_b` | -7 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `ore_veininess` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `packed_ice` | -7 | 4 | 0.939546696581729 | (none: all 1.0) | 1.4191240714 | surface rule frozen_peaks |
| `patch` | -5 | 6 | 1.637127519350388 | [1, 0, 0, 0, 0, 0.013333333333333334] | 0.8726085242 | (not referenced by overworld terrain data read; features) |
| `pillar` | -7 | 2 | 0.9494731054427981 | (none: all 1.0) | 1.1702396885 | caves / ores / other (doc 11) or non-overworld |
| `pillar_rareness` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `pillar_thickness` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `powder_snow` | -6 | 4 | 0.939546696581729 | (none: all 1.0) | 1.4191240714 | surface rule snowy_slopes / grove |
| `ridge` | -7 | 6 | 0.9147152149950137 | [1, 2, 1, 0, 0, 0] | 1.3665455428 | climate (§6.1) |
| `small_patch` | -3 | 1 | 0.955388882960065 | [3] | 0.8722451645 | surface rule dappled_forest |
| `soul_sand_layer` | -8 | 9 | 1.0569606747151457 | [1, 1, 1, 1, 0, 0, 0, 0, 0.013333333333333334] | 1.4191634901 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_2d` | -7 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_2d_elevation` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_2d_modulator` | -11 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_2d_thickness` | -11 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_3d_1` | -7 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_3d_2` | -7 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_3d_rarity` | -11 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_3d_thickness` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_roughness` | -5 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `spaghetti_roughness_modulator` | -8 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | caves / ores / other (doc 11) or non-overworld |
| `sulfur_cave_gradient` | -5 | 3 | 1.1817507833955654 | [1, 0, 1] | 1.0577526307 | surface rule sulfur_caves |
| `surface` | -6 | 3 | 0.9381732587751008 | (none: all 1.0) | 1.3323764969 | surface depth, surface rules |
| `surface_secondary` | -6 | 4 | 1.0582769165096106 | [1, 1, 0, 1] | 1.2599096820 | surface rule secondary depth |
| `surface_swamp` | -2 | 1 | 0.955388882960065 | (none: all 1.0) | 0.8722451645 | surface rule swamp |
| `temperature` | -10 | 6 | 1.2453007926713473 | [1.5, 0, 1, 0, 0, 0] | 1.0037735520 | climate (§6.1) |
| `temperature_large` | -12 | 6 | 1.2453007926713473 | [1.5, 0, 1, 0, 0, 0] | 1.0037735520 | large_biomes preset |
| `vegetation` | -8 | 6 | 0.9494731054427978 | [1, 1, 0, 0, 0, 0] | 1.1702396885 | climate (humidity) (§6.1) |
| `vegetation_large` | -10 | 6 | 0.9494731054427978 | [1, 1, 0, 0, 0, 0] | 1.1702396885 | large_biomes preset |

---

## 4. Density functions: the evaluation model

### 4.1 Model

A **density function** maps an integer block position `(x, y, z)` to a float. The overworld's router (`noise_settings` → `noise_router`) names eight functions; each is a JSON tree in `data/minecraft/worldgen/density_function/`. A string where a function is expected means "the function with that identifier" (a reference). A bare number means a constant. The evaluation order of children is irrelevant except where stated (lazy `lerp`, `range_choice`).

Cells and caches (the semantics an implementation must reproduce):

- **`cache`**: identity. It only memoises the exact value at a block position; wrapping or not wrapping changes no result. (In older versions of the game, comparable "flat cache" nodes sampled at quart resolution; in this artifact the climate noises are evaluated at exact block coordinates.)
- **`interpolated`** (`cell_size_xz`, `cell_size_y`, `input`): the value at `(x, y, z)` is the **trilinear interpolation** of the input evaluated at the eight corner positions of the cell containing the point. The cell grid is anchored at world coordinates multiples of the cell sizes: `fx = floorMod(x, cell_size_xz) / cell_size_xz`, `fy = floorMod(y, cell_size_y) / cell_size_y`, `fz = floorMod(z, cell_size_xz) / cell_size_xz`; the corners are `(x - floorMod(x,cs_xz), y - floorMod(y,cs_y), z - floorMod(z,cs_xz))` plus 0 or the cell size in each axis. Float `lerp3` in the order `c000, c100, c010, c110, c001, c101, c011, c111` (first index x, second y, third z): `lerp(fz, lerp(fy, lerp(fx, c000, c100), lerp(fx, c010, c110)), lerp(fy, lerp(fx, c001, c101), lerp(fx, c011, c111)))`. When all three offsets in the cell are 0 the input is evaluated directly. There is **no smoothing** of the factors.
- **`blend_density`, `blend_alpha`, `blend_offset`**: used for blending with chunks generated by older game versions. For a freshly generated world without blending data: `blend_alpha = 1.0`, `blend_offset = 0.0`, and `blend_density(f) = f`.
- **`beardifier`**: `0.0` unless structures with terrain adaptation are present in the chunk's neighbourhood (§11.2).

### 4.2 Node types used by the overworld

Fields in `monospace` are JSON keys. All results are floats; `l` and `r` are the evaluated children.

| `type` | Parameters | Value |
|---|---|---|
| `constant` / bare number | value | the value |
| `add`, `sub`, `mul`, `div` | `left`, `right` | `l + r`, `l - r`, `l * r`, `l / r` |
| `min`, `max` | `left`, `right` | `min(l, r)`, `max(l, r)` |
| `abs`, `square`, `cube`, `negate`, `sqrt`, `reciprocal`, `log`, `sign` | `input` | usual meaning of `abs(v)`, `v*v`, `v*v*v`, `-v`, ... |
| `half_negative` | `input` | `v` if `v > 0`, else `v * 0.5` |
| `quarter_negative` | `input` | `v` if `v > 0`, else `v * 0.25` |
| `squeeze` | `input` | `c = clamp(v, -1, 1)`; `c / 2 - c*c*c / 24` |
| `clamp` | `input`, `min`, `max` | `clamp(v, min, max)` |
| `lerp` | `alpha`, `first`, `second` | `a = alpha`; if `a == 0` then `first`; if `a == 1` then `second`; else `lerp(a, first, second)` (children evaluated lazily) |
| `range_choice` | `input`, `min_inclusive`, `max_exclusive`, `when_in_range`, `when_out_of_range` | `v = input`; if `min_inclusive <= v < max_exclusive` then `when_in_range` else `when_out_of_range` |
| `gradient` | `axis`, `from_coordinate`, `to_coordinate`, `from_value`, `to_value` (optional `tiling`, default clamp-to-edge) | `c = clamp(coord_on_axis, min(from,to), max(from,to))`; `factor = (to_value - from_value) / (float)(to_coordinate - from_coordinate)` (float); result `from_value + (float)(c - from_coordinate) * factor` (float) |
| `noise` | `noise`, `xz_scale`, `y_scale`, optional `shift_x`, `shift_y`, `shift_z` (default constant 0) | `N.get(x * xz_scale + shift_x(x,y,z), y * y_scale + shift_y(x,y,z), z * xz_scale + shift_z(x,y,z))` with `N` the normal noise of §3.3 (doubles for the argument arithmetic; the shifts are floats converted to double); result float |
| `shift_a` | `noise` | `4f * N.get(x * 0.25, 0.0, z * 0.25)` |
| `shift_b` | `noise` | `4f * N.get(z * 0.25, x * 0.25, 0.0)` |
| `shift` (generic) | `noise` | `4f * N.get(x * 0.25, y * 0.25, z * 0.25)` (unused by the overworld) |
| `spline` | `spline` (§4.3) | see §4.3 |
| `old_blended_noise` | see §3.4 | see §3.4 |
| `find_top_surface` | `density`, `upper_bound`, `lower_bound` (int), `cell_height` (int) | the y of the highest cell-aligned sample whose density is positive, as a float (§4.4) |
| `interpolated`, `cache` | see §4.1 | |
| `blend_alpha`, `blend_offset`, `blend_density`, `beardifier` | | see §4.1 |

Types that exist in the artifact but have no use in the overworld terrain data read: `interval_select`, `slice`, `pow`, `end_outer_islands`, `distance_to_point` (see Open questions).

`noise` nodes named `shift_x` and `shift_z` are the data functions `minecraft:shift_x = cache(shift_a(noise "minecraft:offset"))` and `minecraft:shift_z = cache(shift_b(noise "minecraft:offset"))`. `minecraft:y` is the gradient function from y = -4064 (value -4064) to y = 4062 (value 4062) on the y axis.

### 4.3 Splines

A spline node holds a tree. A **spline** is either a float constant or `{ coordinate: <density function>, points: [ { location, value (spline), derivative }, ... ] }` with strictly increasing `location`. Evaluation at a position (float arithmetic):

1. `c = coordinate(x, y, z)`.
2. `i = (index of the first point with c < location) - 1`; if no point satisfies it, `i = last index`. (`c` equal to a location belongs to the interval that starts there.)
3. If `i < 0` (left of the first point): `v0 = value of the first point`, `d0 = its derivative`; result `v0` if `d0 == 0`, else `v0 + d0 * (c - location0)` (linear extension). If `i == last`: the same with the last point.
4. Otherwise with `p0 = points[i]`, `p1 = points[i+1]`: `dx = loc1 - loc0`, `t = (c - loc0) / dx`, `y0`, `y1` = the evaluated values (recursively, same position), `d0`, `d1` the derivatives; `a = d0 * dx - (y1 - y0)`, `b = -d1 * dx + (y1 - y0)`; result `lerp(t, y0, y1) + t * (1 - t) * lerp(t, a, b)`.

(Cubic Hermite form. `t(1-t)` and the products are float operations.) The spline is **not** clamped to its range.

### 4.4 `find_top_surface`

`find_top_surface(density, upper_bound, lower_bound, cell_height)` at `(x, z)` (it ignores y: it is sampled at y = 0):

1. `u = upper_bound(x, 0, z)` (a float).
2. `y = floor(u / cell_height) * cell_height`. If `y <= lower_bound` return `lower_bound`.
3. While `y >= lower_bound`: if `density(x, y, z) > 0` return `y`; else `y = y - cell_height`.
4. Return `lower_bound`.

The result is a float holding an integer.

---

## 5. Noise settings and dimension values

`data/minecraft/worldgen/noise_settings/overworld.json` (world preset `minecraft:normal`, dimension type `minecraft:overworld`):

| Field | Value |
|---|---|
| `sea_level` | 63 |
| `noise.min_y` / `noise.height` | -64 / 384 (the column spans y -64 .. 319; 24 sections of 16) |
| `default_block` | `minecraft:stone` |
| `default_fluid` | `minecraft:water` |
| `legacy_random_source` | false |
| `disable_mob_generation` | false |
| `material_rule` | `minecraft:overworld` (§10.9) |
| `aquifers` | see §9.1 |
| `noise_router` | `chunk_surface_level` = `overworld/chunk_surface_level`; `continents` = `overworld/continents`; `depth` = `overworld/depth`; `erosion` = `overworld/erosion`; `final_density` = `overworld/final_density`; `ridges` = `overworld/ridges`; `temperature` = `overworld/temperature`; `vegetation` = `overworld/vegetation` |
| `spawn_target` | two parameter boxes (used by the spawn search, outside this document): all with continentalness [-0.11, 1.0], erosion [-1.0, 1.0], temperature [-1.0, 1.0], vegetation [-1.0, 1.0]; the first with ridges [-1.0, -0.16], the second with ridges [0.16, 1.0] |

Dimension type `minecraft:overworld`: `min_y -64`, `height 384`, `logical_height 384`, `coordinate_scale 1.0`, `has_skylight true`, `has_ceiling false`, `ambient_light 0.0`. The generator's Y limits are the same as the noise settings (`getMinGenY = -64`, `getGenDepth = 384`).

Block-coordinate derivations used elsewhere (read from the static initialisers of `BlockPos` and `DimensionType`): `PACKED_HORIZONTAL_LENGTH = 1 + log2(smallestEncompassingPowerOfTwo(30000000)) = 1 + 25 = 26`; `PACKED_Y_LENGTH = 64 - 2 * 26 = 12`; `Y_SIZE = 2^12 - 32 = 4064`; `MAX_Y = Y_SIZE/2 - 1 = 2031`; `MIN_Y = MAX_Y - Y_SIZE + 1 = -2032`; `WAY_ABOVE_MAX_Y = MAX_Y << 4 = 32496`; `WAY_BELOW_MIN_Y = MIN_Y << 4 = -32512`. (These are computed in the static initialisers, not stored as literals; the formulas are read, the arithmetic is mine.)

---

## 6. The overworld density functions

### 6.1 The six climate functions

All noises are evaluated through the `noise` node of §4.2 with `xz_scale = 0.25`, `y_scale = 0.0` and shifts where listed. Writing `sx = minecraft:shift_x(x,y,z)` and `sz = minecraft:shift_z(x,y,z)` (§4.2):

| Router entry | Definition |
|---|---|
| `continents` | `cache(noise "minecraft:continentalness", shift_x = shift_x, shift_z = shift_z, xz_scale 0.25, y_scale 0)` = `Ncont.get(0.25 x + sx, 0, 0.25 z + sz)` |
| `erosion` | same with noise `minecraft:erosion` |
| `ridges` ("weirdness", ridge noise) | same with noise `minecraft:ridge` |
| `temperature` | same shape with `minecraft:temperature` (no `cache` wrapper; irrelevant) |
| `vegetation` (humidity) | same shape with `minecraft:vegetation` |
| `depth` | `depth(x,y,z) = gradient_y(from y=-64 value 1.5, to y=320 value -1.5)(y) + offset(x,y,z)`; the gradient is clamped to y in [-64, 320], so it is 1.5 at and below y = -64, 0 at y = 128 and -1.5 at and above y = 320 |
| `ridges_folded` (helper) | `((|(|ridges| + (-0.6666667))| + (-0.33333334)) * (-3.0)`; ranges from -1 to 1; "peaks and valleys" |

The three shaping functions (`offset`, `factor`, `jaggedness`) each have the form `cache(lerp(blend_alpha, <blend branch>, <value branch>))`; without blending `blend_alpha = 1` so only the value branch applies:

- `offset` = `-0.50375 + SPLINE_offset`
- `factor` = `SPLINE_factor`
- `jaggedness` = `SPLINE_jaggedness`

The three spline trees are tabulated in full in Appendix A. They use `continents`, `erosion`, `ridges` and `ridges_folded` as coordinates (not y).

### 6.2 The 3D shape: `sloped_cheese`

```
sloped_cheese = cache( 4.0 * quarter_negative( (depth + J) * factor ) + base_3d_noise )
J             = cache( jaggedness * half_negative( noise "minecraft:jagged" at (x*1500, 0, z*1500), no shifts ) )
base_3d_noise = old_blended_noise (§3.4), xz_scale 0.25, y_scale 0.125, xz_factor 80, y_factor 160, smear 8
```

(The product is `mul(quarter_negative(mul(add(depth, J), factor)), 4.0)` then `add(..., base_3d_noise)`.) `jagged` is the 16-octave noise of §3.6 (`base_octave -16`).

### 6.3 `preliminary_surface_level` and `chunk_surface_level`

```
preliminary_surface_level = find_top_surface(
    density     = lerp(alpha = gradient_y(-64 -> 0.0, -40 -> 1.0),
                       first = 0.1171875,
                       second = lerp(alpha = gradient_y(240 -> 1.0, 256 -> 0.0),
                                     first = -0.078125,
                                     second = clamp( 4.0 * quarter_negative((gradient_y(-64 -> 1.5, 320 -> -1.5) + offset) * factor) + (-0.703125), -64, 64)))
                + (-0.390625),
    lower_bound = -64,
    upper_bound = clamp( (0.2734375 / factor - offset) * (-128.0) + 128.0, -40, 320 ),
    cell_height = 8 )
```

Written as the data has it: the `density` is `add(lerp(...), -0.390625)`, and the inner `clamp` input is `add(mul(quarter_negative(mul(add(gradient_y, offset), factor)), 4.0), -0.703125)`; `upper_bound` is `clamp(add(mul(sub(div(0.2734375, factor), offset), -128.0), 128.0), -40, 320)`.

`chunk_surface_level = interpolated(cell_size_xz 16, cell_size_y 1, input = preliminary_surface_level)`; because the input ignores y this is a **bilinear interpolation in x and z** between values of `preliminary_surface_level` at block coordinates that are multiples of 16.

Two users, with different sampling (see §9 and §10):

- The aquifer samples `preliminary_surface_level` itself, at quart-aligned columns.
- The surface rules use `chunk_surface_level` (the 16-block bilinear version) in the "above preliminary surface" test.

### 6.4 Caves terms inside `final_density`

`overworld/final_density` embeds the cave density functions `overworld/caves/entrances`, `overworld/caves/spaghetti_2d`, `overworld/caves/spaghetti_roughness_function`, `overworld/caves/pillars`, `overworld/caves/noodle` and the noises `cave_layer`, `cave_cheese`. Their definitions belong to [11-world-generation-caves-and-ores.md](11-world-generation-caves-and-ores.md).

### 6.5 `final_density`

Structure, with `SC = overworld/sloped_cheese`:

```
final_density = add( min( squeeze( interpolated(cell_size_xz 4, cell_size_y 8,
                                      mul( blend_density( L ), 0.64 ) ) ),
                           caves/noodle ),
                     beardifier )

L  = lerp(alpha = gradient_y(-64 -> 0.0, -40 -> 1.0),
          first = 0.1171875,
          second = lerp(alpha = gradient_y(240 -> 1.0, 256 -> 0.0),
                        first = -0.078125,
                        second = RC))

RC = range_choice(input = SC, min_inclusive = -1000000.0, max_exclusive = 1.5625,
        when_in_range     = min(SC, caves/entrances * 5.0),
        when_out_of_range = max( min( min( 4.0 * square(noise cave_layer, xz_scale 1, y_scale 8)
                                           + ( clamp(noise cave_cheese(xz 1, y 0.6666666666666666) + 0.27, -1, 1)
                                               + clamp(SC * -0.64 + 1.5, 0, 0.5) ),
                                           caves/entrances ),
                                      caves/spaghetti_2d + caves/spaghetti_roughness_function ),
                                 range_choice(input = caves/pillars, min_inclusive = -1000000.0, max_exclusive = 0.03,
                                              when_in_range = -1000000.0, when_out_of_range = caves/pillars) )
```

In words: below y = -64 the inner value is the constant 0.1171875 (solid), between -64 and -40 it blends towards the terrain value, above y = 256 it is -0.078125 (air), between 240 and 256 it blends from the terrain value to that constant. The terrain value is `RC`; where `SC` is below 1.5625 it is `min(SC, 5 * entrances)`; where it is at least 1.5625 (deep solid) the cave densities carve spaghetti, cheese and pillars. The blended value is multiplied by 0.64 **before** the 4×8×4 interpolation; the interpolated result is passed through `squeeze` (a soft clamp to about [-0.4583, 0.4583]), then combined with the noodle caves by `min`, then the structure beardifier is added.

A block is **solid** if `final_density(x, y, z) > 0` (§8).

**Cell grid**: horizontally 4×4, vertically 8, anchored at multiples of 4 / 8 in world coordinates (e.g. y = -64, -56, ..., 312, 320). Corner values are evaluated at those block positions (the corner at y = 320 is evaluated although y = 320 is outside the column).

---

## 7. Biomes: the multi-noise biome source

### 7.1 Climate sampling

`Climate.Sampler.sample(qx, qy, qz)` (quart coordinates) evaluates, at the block position `(4*qx, 4*qy, 4*qz)` (**no half-quart offset**), the router functions `temperature`, `vegetation` (humidity), `continents`, `erosion`, `depth` and `ridges` (weirdness), in that order, and **quantises** each: `quantize(v) = (long)(v * 10000.0f)` with a float multiplication and truncation toward zero (so `-0.78f` gives -7799, not -7800). The result is the *target point* `(T, H, C, E, D, W)` of six longs.

### 7.2 Parameter points and distance

A **parameter** is an interval `[min, max]` of quantised longs. A **parameter point** is seven parameters: temperature, humidity, continentalness, erosion, depth, weirdness, and an **offset** (a single quantised value). `Climate.parameters(...)` builds points from `Parameter.span(a, b)` (both ends quantised) and `Parameter.point(v)` (`span(v, v)`).

Distance of a value `v` to a parameter: `d = v - max` if `v > max`, else `max(min - v, 0)`.

`fitness(point, target) = Σ over the six climate parameters of distance(point.param, target.param)^2 + point.offset^2` (a long).

### 7.3 Lookup

`findValue(target)` returns the biome of the parameter point with the **smallest fitness**. The reference definition (`findValueBruteForce`) scans the list in registration order and replaces the best only on a **strictly smaller** fitness, so on ties the earlier entry wins. The game uses an R-tree to accelerate the search; the R-tree starts from the previous result of the same thread and also replaces only on strictly smaller distance, so on exact ties its answer can depend on history (Open question 1). Use the brute-force definition for reproducible results.

### 7.4 Overworld parameter table (`OverworldBiomeBuilder`)

The preset `minecraft:overworld` (file `multi_noise_biome_source_parameter_list/overworld.json` just names the preset) is built by `OverworldBiomeBuilder.addBiomes`. The order of insertion is: off-coast biomes, then the inland slices, then the underground biomes. The list order is the tie-break order of §7.3.

**Threshold constants** (decimal as in the code; the quantised value follows the §7.1 rule):

| Name | Spans (min, max) -> quantised |
|---|---|
| `FULL_RANGE` | -1.0 .. 1.0 -> -10000 .. 10000 |
| `temperatures[0..4]` | [-1.0,-0.45] -> [-10000,-4500]; [-0.45,-0.15] -> [-4500,-1500]; [-0.15,0.2] -> [-1500,2000]; [0.2,0.55] -> [2000,5500]; [0.55,1.0] -> [5500,10000] |
| `humidities[0..4]` | [-1.0,-0.35] -> [-10000,-3500]; [-0.35,-0.1] -> [-3500,-1000]; [-0.1,0.1] -> [-1000,1000]; [0.1,0.3] -> [1000,3000]; [0.3,1.0] -> [3000,10000] |
| `erosions[0..6]` | [-1.0,-0.78] -> [-10000,-7799]; [-0.78,-0.375] -> [-7799,-3750]; [-0.375,-0.2225] -> [-3750,-2225]; [-0.2225,0.05] -> [-2225,500]; [0.05,0.45] -> [500,4500]; [0.45,0.55] -> [4500,5500]; [0.55,1.0] -> [5500,10000] |
| `FROZEN_RANGE` | `temperatures[0]` |
| `UNFROZEN_RANGE` | span of `temperatures[1]` to `temperatures[4]` (-4500 .. 10000) |
| `mushroomFieldsContinentalness` | [-1.2,-1.05] -> [-12000,-10500] |
| `deepOceanContinentalness` | [-1.05,-0.455] -> [-10500,-4550] |
| `oceanContinentalness` | [-0.455,-0.19] -> [-4550,-1900] |
| `coastContinentalness` | [-0.19,-0.11] -> [-1900,-1100] |
| `inlandContinentalness` | [-0.11,0.55] -> [-1100,5500] |
| `nearInlandContinentalness` | [-0.11,0.03] -> [-1100,300] |
| `midInlandContinentalness` | [0.03,0.3] -> [300,3000] |
| `farInlandContinentalness` | [0.3,1.0] -> [3000,10000] |

`span(A, B)` of two parameters is `[min(A.min,B.min), max(A.max,B.max)]`.

**Biome matrices** (indexed `[temperature index][humidity index]`, both 0..4):

`OCEANS` (2 rows: deep, normal; indexed by temperature index only): deep = `deep_frozen_ocean, deep_cold_ocean, deep_ocean, deep_lukewarm_ocean, warm_ocean`; normal = `frozen_ocean, cold_ocean, ocean, lukewarm_ocean, warm_ocean`.

`MIDDLE_BIOMES`:

| t \ h | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| 0 | snowy_plains | snowy_plains | snowy_plains | snowy_taiga | taiga |
| 1 | plains | plains | forest | taiga | old_growth_spruce_taiga |
| 2 | flower_forest | plains | forest | birch_forest | dark_forest |
| 3 | savanna | savanna | forest | jungle | jungle |
| 4 | desert | desert | desert | desert | desert |

`MIDDLE_BIOMES_VARIANT` (`-` = none, use the middle biome):

| t \ h | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| 0 | ice_spikes | - | snowy_taiga | - | - |
| 1 | dappled_forest | - | - | - | old_growth_pine_taiga |
| 2 | sunflower_plains | - | - | old_growth_birch_forest | - |
| 3 | - | - | plains | sparse_jungle | bamboo_jungle |
| 4 | - | - | - | - | - |

`PLATEAU_BIOMES`:

| t \ h | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| 0 | snowy_plains | snowy_plains | snowy_plains | snowy_taiga | snowy_taiga |
| 1 | meadow | meadow | forest | taiga | old_growth_spruce_taiga |
| 2 | meadow | meadow | meadow | meadow | pale_garden |
| 3 | savanna_plateau | savanna_plateau | forest | forest | jungle |
| 4 | badlands | badlands | badlands | wooded_badlands | wooded_badlands |

`PLATEAU_BIOMES_VARIANT`:

| t \ h | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| 0 | ice_spikes | - | - | - | - |
| 1 | cherry_grove | - | meadow | meadow | old_growth_pine_taiga |
| 2 | cherry_grove | cherry_grove | forest | birch_forest | - |
| 3 | - | - | - | - | - |
| 4 | eroded_badlands | eroded_badlands | - | - | - |

`SHATTERED_BIOMES`:

| t \ h | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| 0 | windswept_gravelly_hills | windswept_gravelly_hills | windswept_hills | windswept_forest | windswept_forest |
| 1 | windswept_gravelly_hills | windswept_gravelly_hills | windswept_hills | windswept_forest | windswept_forest |
| 2 | windswept_hills | windswept_hills | windswept_hills | windswept_forest | windswept_forest |
| 3 | - | - | - | - | - |
| 4 | - | - | - | - | - |

**Selector functions** (inputs: temperature index `t`, humidity index `h`, weirdness parameter `w`; `w.max` is its upper quantised bound):

| Function | Result |
|---|---|
| `pickMiddle(t,h,w)` | if `w.max < 0`: `MIDDLE[t][h]`; else `MIDDLE_VARIANT[t][h]` if present, else `MIDDLE[t][h]` |
| `pickBadlands(h,w)` | if `h < 2`: `badlands` if `w.max < 0` else `eroded_badlands`; else if `h < 3`: `badlands`; else `wooded_badlands` |
| `pickMiddleOrBadlandsIfHot(t,h,w)` | `pickBadlands(h,w)` if `t == 4`, else `pickMiddle(t,h,w)` |
| `pickSlope(t,h,w)` | if `t >= 3`: `pickPlateau(t,h,w)`; else `snowy_slopes` if `h <= 1` else `grove` |
| `pickMiddleOrBadlandsIfHotOrSlopeIfCold(t,h,w)` | `pickSlope(t,h,w)` if `t == 0`, else `pickMiddleOrBadlandsIfHot(t,h,w)` |
| `pickPlateau(t,h,w)` | if `w.max >= 0` and `PLATEAU_VARIANT[t][h]` exists: that; else `PLATEAU[t][h]` |
| `pickShattered(t,h,w)` | `SHATTERED[t][h]` if present, else `pickMiddle(t,h,w)` |
| `windswept(t,h,w,base)` | `windswept_savanna` if `t > 1` and `h < 4` and `w.max >= 0`, else `base` |
| `pickBeach(t,h)` | `snowy_beach` if `t == 0`; `desert` if `t == 4`; else `beach` |
| `pickShatteredCoast(t,h,w)` | `base = pickMiddle(t,h,w)` if `w.max >= 0` else `pickBeach(t,h)`; result `windswept(t,h,w,base)` |
| `pickPeak(t,h,w)` | if `t <= 2`: `jagged_peaks` if `w.max < 0` else `frozen_peaks`; if `t == 3`: `stony_peaks`; else `pickBadlands(h,w)` |

**Emitting a surface point** `addSurfaceBiome(T, H, C, E, W, offset, biome)` adds **two** parameter points: one with depth `point(0.0)` and one with depth `point(1.0)`, otherwise identical (`offset` is always 0.0 for the overworld). An underground point uses depth `span(0.2, 0.9)`; the bottom point uses depth `point(1.1)`. Throughout, "[a..b]" means `span(a, b)`; `T[i]`, `H[j]`, `E[k]` are the matrices' parameter ranges above and `FULL = FULL_RANGE`.

**Step 1: off-coast.**

1. `(FULL, FULL, mushroomFields, FULL, FULL, 0)` -> `mushroom_fields`.
2. For each temperature index `i` = 0..4: `(T[i], FULL, deepOcean, FULL, FULL, 0)` -> `OCEANS[0][i]`; then `(T[i], FULL, ocean, FULL, FULL, 0)` -> `OCEANS[1][i]`.

**Step 2: inland slices.** Weirdness ranges, in this order: mid [-1.0, -0.93333334]; high [-0.93333334, -0.7666667]; peaks [-0.7666667, -0.56666666]; high [-0.56666666, -0.4]; mid [-0.4, -0.26666668]; low [-0.26666668, -0.05]; valleys [-0.05, 0.05]; low [0.05, 0.26666668]; mid [0.26666668, 0.4]; high [0.4, 0.56666666]; peaks [0.56666666, 0.7666667]; high [0.7666667, 0.93333334]; mid [0.93333334, 1.0].

For the slice builders `w` is the slice's weirdness range, offset is 0, and the loops are `for t in 0..4: for h in 0..4:` (outer t, inner h) with biomes computed from `(t, h, w)`. Naming: `M = pickMiddle`, `Mb = pickMiddleOrBadlandsIfHot`, `Mc = pickMiddleOrBadlandsIfHotOrSlopeIfCold`, `Pl = pickPlateau`, `Sh = pickShattered`, `Sl = pickSlope`, `Pk = pickPeak`, `Be = pickBeach(t,h)`, `Ws = windswept(t,h,w, M)` (base = middle), `WsSh = windswept(t,h,w, Sh)` (base = shattered), `ShC = pickShatteredCoast`. Continentalness names: `coast`, `near`, `mid`, `far` (the `farInland`), spans `[a..b]`.

*Peaks slice* (entries per `(t,h)`, in order; format `continentalness | erosion -> biome`):

1. `[coast..far] | E0 -> Pk`
2. `[coast..near] | E1 -> Mc`
3. `[mid..far] | E1 -> Pk`
4. `[coast..near] | [E2..E3] -> M`
5. `[mid..far] | E2 -> Pl`
6. `mid | E3 -> Mb`
7. `far | E3 -> Pl`
8. `[coast..far] | E4 -> M`
9. `[coast..near] | E5 -> WsSh`
10. `[mid..far] | E5 -> Sh`
11. `[coast..far] | E6 -> M`

*High slice*:

1. `coast | [E0..E1] -> M`
2. `near | E0 -> Sl`
3. `[mid..far] | E0 -> Pk`
4. `near | E1 -> Mc`
5. `[mid..far] | E1 -> Sl`
6. `[coast..near] | [E2..E3] -> M`
7. `[mid..far] | E2 -> Pl`
8. `mid | E3 -> Mb`
9. `far | E3 -> Pl`
10. `[coast..far] | E4 -> M`
11. `[coast..near] | E5 -> Ws`
12. `[mid..far] | E5 -> Sh`
13. `[coast..far] | E6 -> M`

*Mid slice* (before the loops, three fixed entries with temperature/humidity as stated, offset 0):

- `(FULL, FULL, coast, [E0..E2], w, 0)` -> `stony_shore`
- `([T1..T2], FULL, [near..far], E6, w, 0)` -> `swamp`
- `([T3..T4], FULL, [near..far], E6, w, 0)` -> `mangrove_swamp`

then per `(t,h)`:

1. `[near..far] | E0 -> Sl`
2. `[near..mid] | E1 -> Mc`
3. `far | E1 -> Sl if t == 0 else Pl`
4. `near | E2 -> M`
5. `mid | E2 -> Mb`
6. `far | E2 -> Pl`
7. `[coast..near] | E3 -> M`
8. `[mid..far] | E3 -> Mb`
9. if `w.max < 0`: `coast | E4 -> Be` then `[near..far] | E4 -> M`; else: `[coast..far] | E4 -> M`
10. `coast | E5 -> ShC`
11. `near | E5 -> Ws`
12. `[mid..far] | E5 -> Sh`
13. if `w.max < 0`: `coast | E6 -> Be`; else `coast | E6 -> M`
14. if `t == 0`: `[near..far] | E6 -> M`

*Low slice* (same three fixed entries as the mid slice first), then per `(t,h)`:

1. `near | [E0..E1] -> Mb`
2. `[mid..far] | [E0..E1] -> Mc`
3. `near | [E2..E3] -> M`
4. `[mid..far] | [E2..E3] -> Mb`
5. `coast | [E3..E4] -> Be`
6. `[near..far] | E4 -> M`
7. `coast | E5 -> ShC`
8. `near | E5 -> Ws`
9. `[mid..far] | E5 -> M`
10. `coast | E6 -> Be`
11. if `t == 0`: `[near..far] | E6 -> M`

*Valleys* (weirdness `w` = [-0.05, 0.05], so `w.max = 500 >= 0` and entries 1 and 2 give the river biomes, never `stony_shore`); fixed entries (temperature | humidity FULL | continentalness | erosion -> biome):

1. `FROZEN | coast | [E0..E1] -> stony_shore if w.max < 0 else frozen_river`
2. `UNFROZEN | coast | [E0..E1] -> stony_shore if w.max < 0 else river`
3. `FROZEN | near | [E0..E1] -> frozen_river`
4. `UNFROZEN | near | [E0..E1] -> river`
5. `FROZEN | [coast..far] | [E2..E5] -> frozen_river`
6. `UNFROZEN | [coast..far] | [E2..E5] -> river`
7. `FROZEN | coast | E6 -> frozen_river`
8. `UNFROZEN | coast | E6 -> river`
9. `[T1..T2] | [inland..far] | E6 -> swamp`
10. `[T3..T4] | [inland..far] | E6 -> mangrove_swamp`
11. `FROZEN | [inland..far] | E6 -> frozen_river`

then per `(t,h)`: `[mid..far] | [E0..E1] -> Mb` (humidity H[h], temperature T[t] for the per-`(t,h)` entries; the fixed entries use FULL humidity).

**Step 3: underground.** Offset 0:

1. `(FULL, FULL, [0.8..1.0], FULL, FULL)` with depth `[0.2..0.9]` -> `dripstone_caves` (the **continentalness** range is [0.8, 1.0]).
2. `(FULL, [0.7..1.0], FULL, FULL, FULL)`, depth `[0.2..0.9]` -> `lush_caves` (humidity [0.7, 1.0]).
3. `(FULL, FULL, [coast..inland], [E5..E6], weirdness [-1.1..-0.85])`, depth `[0.2..0.9]` -> `sulfur_caves` (continentalness -1900 .. 5500, erosion 4500 .. 10000, weirdness -11000 .. -8500).
4. `(FULL, FULL, FULL, [E0..E1], FULL)`, depth `point(1.1)` -> `deep_dark`.

**Counts**: total 7594 parameter points = 3795 with depth point 0 + 3795 with depth point 1.0 + 3 underground + 1 bottom. **Provenance:** the matrices, selector functions and slice entry lists in §7.4 were first transcribed by the reader from the bytecode of `OverworldBiomeBuilder` (the jar has no data file for the point list: `multi_noise_biome_source_parameter_list/overworld.json` only names the preset). A later review then executed the artifact's own builder bytecode and confirmed the matrices, all selector functions, the full ordered list of the 3795 surface entries, the 3 underground and 1 bottom entries, the per-biome counts and the 7594 total. Per biome:

| Biome | Parameter points |
|---|---|
| `badlands` | 282 |
| `bamboo_jungle` | 104 |
| `beach` | 330 |
| `birch_forest` | 100 |
| `cherry_grove` | 60 |
| `cold_ocean` | 2 |
| `dappled_forest` | 92 |
| `dark_forest` | 172 |
| `deep_cold_ocean` | 2 |
| `deep_dark` | 1 |
| `deep_frozen_ocean` | 2 |
| `deep_lukewarm_ocean` | 2 |
| `deep_ocean` | 2 |
| `desert` | 708 |
| `dripstone_caves` | 1 |
| `eroded_badlands` | 144 |
| `flower_forest` | 80 |
| `forest` | 588 |
| `frozen_ocean` | 2 |
| `frozen_peaks` | 120 |
| `frozen_river` | 10 |
| `grove` | 312 |
| `ice_spikes` | 102 |
| `jagged_peaks` | 120 |
| `jungle` | 248 |
| `lukewarm_ocean` | 2 |
| `lush_caves` | 1 |
| `mangrove_swamp` | 14 |
| `meadow` | 180 |
| `mushroom_fields` | 2 |
| `ocean` | 2 |
| `old_growth_birch_forest` | 76 |
| `old_growth_pine_taiga` | 112 |
| `old_growth_spruce_taiga` | 100 |
| `pale_garden` | 40 |
| `plains` | 494 |
| `river` | 8 |
| `savanna` | 356 |
| `savanna_plateau` | 128 |
| `snowy_beach` | 110 |
| `snowy_plains` | 388 |
| `snowy_slopes` | 208 |
| `snowy_taiga` | 310 |
| `sparse_jungle` | 86 |
| `stony_peaks` | 80 |
| `stony_shore` | 12 |
| `sulfur_caves` | 1 |
| `sunflower_plains` | 76 |
| `swamp` | 14 |
| `taiga` | 352 |
| `warm_ocean` | 4 |
| `windswept_forest` | 142 |
| `windswept_gravelly_hills` | 96 |
| `windswept_hills` | 114 |
| `windswept_savanna` | 216 |
| `wooded_badlands` | 284 |
| **Total** | **7594** |

### 7.5 Deep-dark region test (also used by the aquifer)

`OverworldBiomeBuilder.deepDarkRegion(erosion, depth) = min(-0.225 - erosion, max(depth - 0.9, 0.0))`. The aquifer's `exclusion` function (§9.1) is this expression; it is positive only where erosion < -0.225 and depth > 0.9.

### 7.6 From noise to stored biomes

When a chunk reaches the *biomes* stage (§11), for every 16-block section `sy` from the minimum section (-4) to the maximum (19), a palette container of 4×4×4 entries is filled: for local `(lx, ly, lz)` in 0..3 (loops: `lx` outer, `ly`, `lz` inner), `biome = source.getNoiseBiome(chunkMinQuartX + lx, sy*4 + ly, chunkMinQuartZ + lz)`, i.e. `findValue(Climate.Sampler.sample(...))` of §7.1–§7.3. The biome stored for a block is therefore the climate biome of its quart cell. Terrain queries by the surface rules use the zoomed lookup of §7.7, not the raw cell.

### 7.7 `BiomeManager.getBiome(x, y, z)` (fuzzy zoom)

`BiomeManager` holds `biomeZoomSeed = obfuscateSeed(worldSeed)` where `obfuscateSeed(s)` is the first 8 bytes of SHA-256 of the 8 little-endian bytes of `s`, read as a little-endian 64-bit integer (`Hashing.sha256().hashLong(s).asLong()`). (Read: `WorldGenRegion` constructs its `BiomeManager` with `obfuscateSeed(this.seed)` where `this.seed` is `ServerLevel.getSeed()`, and `ServerLevel.getSeed()` returns `MinecraftServer.getWorldGenSettings().options().seed()`, the world seed. The terrain stage obtains its `BiomeManager` from the `WorldGenRegion` (`getBiomeManager()`), so the surface rules use this seed. `MinecraftServer` and `ServerPlayer` also call `obfuscateSeed` with the same world seed for other purposes.)

`getBiome(x, y, z)`:

1. `x1 = x - 2`, `y1 = y - 2`, `z1 = z - 2`; `qx = x1 >> 2`, `qy = y1 >> 2`, `qz = z1 >> 2`; `fx = (x1 & 3) / 4.0`, `fy = (y1 & 3) / 4.0`, `fz = (z1 & 3) / 4.0`.
2. For `c = 0..7` (bit 2 = x, bit 1 = y, bit 0 = z of `c`: `cx = (c & 4) == 0`, `cy = (c & 2) == 0`, `cz = (c & 1) == 0`): cell `(ax, ay, az) = (cx ? qx : qx + 1, cy ? qy : qy + 1, cz ? qz : qz + 1)`, offsets `ox = cx ? fx : fx - 1`, `oy = cy ? fy : fy - 1`, `oz = cz ? fz : fz - 1`; distance `d = fiddledDistance(biomeZoomSeed, ax, ay, az, ox, oy, oz)`. Keep the **first** cell with the smallest `d` (replace only on strictly smaller).
3. Result: the stored biome at the winning cell, `getNoiseBiome(ax, ay, az)` (a chunk's stored 4×4×4 value; this can read the neighbouring chunk's cell at the chunk border).

`fiddledDistance(seed, ax, ay, az, ox, oy, oz)`: `s = seed`; apply `s = lcg(s, ax)`, `s = lcg(s, ay)`, `s = lcg(s, az)` twice in turn: the sequence is `lcg(·, ax), lcg(·, ay), lcg(·, az), lcg(·, ax), lcg(·, ay), lcg(·, az)` (six steps); then `fx = fiddle(s)`, `s = lcg(s, seed)`, `fy = fiddle(s)`, `s = lcg(s, seed)`, `fz = fiddle(s)`; result `(oz + fz)^2 + (oy + fy)^2 + (ox + fx)^2` (doubles; the sum order is z, y, x as written). `lcg(s, inc) = s * (s * 6364136223846793005 + 1442695040888963407) + inc` (64-bit wrapping); `fiddle(s) = ((floorMod(s >> 24, 1024)) / 1024.0 - 0.5) * 0.9`.

### 7.8 Biome climate values

From the biome JSON (`temperature`, `downfall`, `has_precipitation`, `temperature_modifier`). These are used by surface-level decisions in this document only for `frozen_ocean` and `deep_frozen_ocean` (§10.8); the other uses (precipitation, grass colour) belong to other documents.

| Biome | temperature | downfall | has_precipitation | temperature_modifier |
|---|---|---|---|---|
| `badlands` | 2.0 | 0.0 | false | none |
| `bamboo_jungle` | 0.95 | 0.9 | true | none |
| `basalt_deltas` | 2.0 | 0.0 | false | none |
| `beach` | 0.8 | 0.4 | true | none |
| `birch_forest` | 0.6 | 0.6 | true | none |
| `cherry_grove` | 0.5 | 0.8 | true | none |
| `cold_ocean` | 0.5 | 0.5 | true | none |
| `crimson_forest` | 2.0 | 0.0 | false | none |
| `dappled_forest` | 0.6 | 0.6 | true | none |
| `dark_forest` | 0.7 | 0.8 | true | none |
| `deep_cold_ocean` | 0.5 | 0.5 | true | none |
| `deep_dark` | 0.8 | 0.4 | true | none |
| `deep_frozen_ocean` | 0.5 | 0.5 | true | frozen |
| `deep_lukewarm_ocean` | 0.5 | 0.5 | true | none |
| `deep_ocean` | 0.5 | 0.5 | true | none |
| `desert` | 2.0 | 0.0 | false | none |
| `dripstone_caves` | 0.8 | 0.4 | true | none |
| `end_barrens` | 0.5 | 0.5 | false | none |
| `end_highlands` | 0.5 | 0.5 | false | none |
| `end_midlands` | 0.5 | 0.5 | false | none |
| `eroded_badlands` | 2.0 | 0.0 | false | none |
| `flower_forest` | 0.7 | 0.8 | true | none |
| `forest` | 0.7 | 0.8 | true | none |
| `frozen_ocean` | 0.0 | 0.5 | true | frozen |
| `frozen_peaks` | -0.7 | 0.9 | true | none |
| `frozen_river` | 0.0 | 0.5 | true | none |
| `grove` | -0.2 | 0.8 | true | none |
| `ice_spikes` | 0.0 | 0.5 | true | none |
| `jagged_peaks` | -0.7 | 0.9 | true | none |
| `jungle` | 0.95 | 0.9 | true | none |
| `lukewarm_ocean` | 0.5 | 0.5 | true | none |
| `lush_caves` | 0.5 | 0.5 | true | none |
| `mangrove_swamp` | 0.8 | 0.9 | true | none |
| `meadow` | 0.5 | 0.8 | true | none |
| `mushroom_fields` | 0.9 | 1.0 | true | none |
| `nether_wastes` | 2.0 | 0.0 | false | none |
| `ocean` | 0.5 | 0.5 | true | none |
| `old_growth_birch_forest` | 0.6 | 0.6 | true | none |
| `old_growth_pine_taiga` | 0.3 | 0.8 | true | none |
| `old_growth_spruce_taiga` | 0.25 | 0.8 | true | none |
| `pale_garden` | 0.7 | 0.8 | true | none |
| `plains` | 0.8 | 0.4 | true | none |
| `river` | 0.5 | 0.5 | true | none |
| `savanna` | 2.0 | 0.0 | false | none |
| `savanna_plateau` | 2.0 | 0.0 | false | none |
| `small_end_islands` | 0.5 | 0.5 | false | none |
| `snowy_beach` | 0.05 | 0.3 | true | none |
| `snowy_plains` | 0.0 | 0.5 | true | none |
| `snowy_slopes` | -0.3 | 0.9 | true | none |
| `snowy_taiga` | -0.5 | 0.4 | true | none |
| `soul_sand_valley` | 2.0 | 0.0 | false | none |
| `sparse_jungle` | 0.95 | 0.8 | true | none |
| `stony_peaks` | 1.0 | 0.3 | true | none |
| `stony_shore` | 0.2 | 0.3 | true | none |
| `sulfur_caves` | 0.8 | 0.4 | true | none |
| `sunflower_plains` | 0.8 | 0.4 | true | none |
| `swamp` | 0.8 | 0.9 | true | none |
| `taiga` | 0.25 | 0.8 | true | none |
| `the_end` | 0.5 | 0.5 | false | none |
| `the_void` | 0.5 | 0.5 | false | none |
| `warm_ocean` | 0.5 | 0.5 | true | none |
| `warped_forest` | 2.0 | 0.0 | false | none |
| `windswept_forest` | 0.2 | 0.3 | true | none |
| `windswept_gravelly_hills` | 0.2 | 0.3 | true | none |
| `windswept_hills` | 0.2 | 0.3 | true | none |
| `windswept_savanna` | 2.0 | 0.0 | false | none |
| `wooded_badlands` | 2.0 | 0.0 | false | none |

---

## 8. Terrain fill

### 8.1 Procedure (`NoiseBasedChunkGenerator.doFill`)

Inputs: the chunk column (x, z range of 16×16; y -64..319), the final density function with its per-chunk sampler context, the aquifer (§9). Heightmaps `OCEAN_FLOOR_WG` and `WORLD_SURFACE_WG` of the chunk are created empty.

1. Sample `final_density` for every block of the column (16 × 384 × 16) at **block resolution** (the `interpolated` node of §4.1 does the 4×8×4 interpolation).
2. For each column `(z, x)` (z outer, x inner) and for `y` from 319 **down** to -64, with `d = final_density(x, y, z)`:
   1. `state = aquifer.computeSubstance(x, y, z, d)` (§9.2). If it returns "none" the block is the **default block** (`stone`).
   2. If `state` is `air`: leave the block unset and continue.
   3. Otherwise set the block in its section, update both heightmaps with the block, and if the aquifer asked for it (`shouldScheduleFluidUpdate`) and the block has a non-empty fluid state, mark the position for post-processing (a fluid tick scheduled later).

Ore veins, bedrock, deepslate and the surface rules are **not** applied in this pass; they come in §10. (The material rule contains the ore-vein rule; it is applied by the same pass as the surface rules.)

Heightmaps (read from `Heightmap$Types`, `Heightmap` and `ChunkAccess`): `WORLD_SURFACE_WG` records a block iff it is **not air** (`!isAir()`); `OCEAN_FLOOR_WG` records a block iff it is in the block tag `#minecraft:blocks_motion_in_heightmap`, which the jar's tag file defines as exactly `#minecraft:blocks_motion` (the 26.3 name for the vanilla "motion blocking material" set; a fluid alone does not qualify). Each map stores, per column, the first available y (highest recorded y + 1; `update` raises it when a qualifying block is placed at or above it, and rescans downward when the top block is replaced by a non-qualifying one); `ChunkAccess.getHeight(type, x, z)` returns that value minus 1, i.e. the **absolute y of the highest recorded block** (minY - 1 for an empty column). The surface pass (§10.1) adds 1 to start one block above it.

---

## 9. Aquifers

### 9.1 Configuration

From `noise_settings/overworld.json`, `aquifers`:

| Entry | Definition |
|---|---|
| `barrier` | `noise "minecraft:aquifer_barrier"`, `xz_scale 1.0`, `y_scale 0.5` |
| `fluid_level_floodedness` | `noise "minecraft:aquifer_fluid_level_floodedness"`, `xz_scale 1.0`, `y_scale 0.67` |
| `fluid_level_spread` | `noise "minecraft:aquifer_fluid_level_spread"`, `xz_scale 1.0`, `y_scale 0.7142857142857143` |
| `lava` | `noise "minecraft:aquifer_lava"`, `xz_scale 1.0`, `y_scale 1.0` |
| `exclusion` | `min(sub(-0.225, overworld/erosion), max(sub(overworld/depth, 0.9), 0.0))` (§7.5) |
| `surface_level` | `overworld/preliminary_surface_level` (§6.3) |

These are plain `noise` nodes without shifts (`N.get(x * xz_scale, y * y_scale, z * xz_scale)`). Noise definitions are in §3.6 (`aquifer_barrier` octave -3, `aquifer_fluid_level_floodedness` -7, `aquifer_fluid_level_spread` -5, `aquifer_lava` -1, each a single octave).

The aquifer's position random is the positional factory `P.fromHashOf("minecraft:aquifer").forkPositional()` (§2.5).

**Global fluid picker** (`createFluidPicker`): with `sea = 63`: `lavaStatus = (level -54, lava)`, `seaStatus = (level 63, water)`; `picker(x, y, z) = lavaStatus if y < min(-54, sea) else seaStatus`. A **fluid status** is `(fluidLevel, fluidType)`, with `at(y) = fluidType if y < fluidLevel else air`. Two statuses are equal if both level and type are equal.

### 9.2 `computeSubstance(x, y, z, density)`

Constants: grid cell size 16 (x), 12 (y), 16 (z); `gridX(v) = v >> 4`, `gridZ(v) = v >> 4`, `gridY(v) = floorDiv(v, 12)`; `fromGridX(g, o) = (g << 4) + o` (same for z), `fromGridY(g, o) = g * 12 + o`; sample offsets (-5, +1, -5); `similarity(a, b) = 1 - (b - a) / 25.0`; `FLOWING = similarity(10², 12²) = -0.76`.

1. If `density > 0`: `shouldScheduleFluidUpdate = false`; return **none** (solid, default block).
2. `global = picker(x, y, z)`. If `y > skipSamplingAboveY` (§9.4): `shouldSchedule = false`; return `global.at(y)`.
3. If `global.at(y)` is lava: `shouldSchedule = false`; return lava.
4. **Find the four nearest aquifer centres.** `gx0 = gridX(x - 5)`, `gy0 = gridY(y + 1)`, `gz0 = gridZ(z - 5)`. For `dx = 0..1` (outer), `dy = -1..1`, `dz = 0..1` (inner): cell `(cx, cy, cz) = (gx0+dx, gy0+dy, gz0+dz)`; its **centre** (cached per cell) is `R = P_aquifer.at(cx, cy, cz)`; `px = fromGridX(cx, R.nextInt(10))`, `py = fromGridY(cy, R.nextInt(9))`, `pz = fromGridZ(cz, R.nextInt(10))` (draws in this order); `dist² = (px-x)² + (py-y)² + (pz-z)²` (integers). Maintain the four smallest in ascending order `(d1,c1) <= (d2,c2) <= (d3,c3) <= (d4,c4)`; a new candidate is inserted **before** the first existing entry whose distance is **>=** it (so on equal distance the newer candidate ranks first), shifting the others down; if it is larger than all four it is dropped.
5. `s1 = status(c1)` (§9.3), `sim12 = similarity(d1, d2)`, `block = s1.at(y)`.
6. If `sim12 <= 0`: `shouldSchedule = (sim12 >= FLOWING) and s1 != status(c2)`; return `block`.
7. If `block` is water and `picker(x, y - 1, z).at(y - 1)` is lava: `shouldSchedule = true`; return `block`.
8. `s2 = status(c2)`; `p12 = sim12 * pressure(x,y,z, s1, s2)`. If `density + p12 > 0`: `shouldSchedule = false`; return none (solid).
9. `s3 = status(c3)`; `sim13 = similarity(d1, d3)`. If `sim13 > 0`: `p13 = sim12 * sim13 * pressure(s1, s3)`; if `density + p13 > 0`: `shouldSchedule = false`; return none.
10. `sim23 = similarity(d2, d3)`. If `sim23 > 0`: `p23 = sim12 * sim23 * pressure(s2, s3)`; if `density + p23 > 0`: `shouldSchedule = false`; return none.
11. `shouldSchedule = (s1 != s2) or (sim23 >= FLOWING and s2 != s3) or (sim13 >= FLOWING and s1 != s3)`; if that is false and `sim13 >= FLOWING` and `similarity(d1, d4) >= FLOWING` and `s1 != status(c4)` then `shouldSchedule = true` (when the first test is true it stays true).
12. Return `block`.

`pressure(x, y, z, sA, sB)` (the barrier noise is sampled at most once per call, lazily):

1. `a = sA.at(y)`, `b = sB.at(y)`. If `{a, b}` is lava and water (either order): return `2.0`.
2. `diff = |sA.level - sB.level|`; if `diff == 0` return `0.0`.
3. `mid = 0.5 * (sA.level + sB.level)`; `off = (y + 0.5) - mid`; `half = diff / 2.0`; `k = half - |off|`.
4. If `off > 0`: `v = 0 + k`; `q = v / 1.5` if `v > 0` else `v / 2.5`. Else: `v = 3.0 + k`; `q = v / 3.0` if `v > 0` else `v / 10.0`.
5. If `q < -2.0` or `q > 2.0`: `barrier = 0`; else `barrier = barrierNoise(x, y, z)` (as a double).
6. Return `2.0 * (barrier + q)`.

### 9.3 Status of a cell: `status(index)`

Computed once per grid cell from the cell's centre `(px, py, pz)` (the same centre as step 4); the cache key is the cell. `computeFluid(px, py, pz)`:

1. `global = picker(px, py, pz)`; `minSurface = +infinity`; `above = py + 12`; `below = py - 12`; `flag = false`.
2. For each chunk offset `(ox, oz)` of the list in §9.5, in order: `bx = px + (ox << 4)`, `bz = pz + (oz << 4)`; `raw = surfaceLevel(bx, bz)` (§9.4); `adj = raw + 8`; `isCentre = (ox == 0 and oz == 0)`.
   - If `isCentre` and `below > adj`: return `global` (the cell is entirely above the ground).
   - `high = above > adj`.
   - If `high` or `isCentre`: `f = picker(bx, adj, bz)`; if `f.at(adj)` is not air: if `isCentre` then `flag = true`; if `high` then **return `f`**.
   - `minSurface = min(minSurface, raw)` (the **raw** value).
3. `level = computeSurfaceLevel(px, py, pz, global, minSurface, flag)`; return `(level, computeFluidType(px, py, pz, global, level))`.

`computeSurfaceLevel(x, y, z, global, minRaw, flag)`:

1. `e = exclusion(x, y, z)`. If `e > 0`: `d7 = -1`, `d9 = -1`. Else:
   - `depthTerm = (minRaw + 8) - y`; `w = clampedMap(depthTerm, 0.0, 64.0, 1.0, 0.0)` if `flag` else `0.0`;
   - `f = clamp(floodedness(x, y, z), -1, 1)`;
   - `lo = map(w, 1.0, 0.0, -0.3, 0.8)` and `hi = map(w, 1.0, 0.0, -0.8, 0.4)`;
   - `d7 = f - hi`, `d9 = f - lo`.
2. If `d9 > 0`: `level = global.level` (63 near the sea, -54 in the lava band). Else if `d7 > 0`: `level = randomizedLevel(x, y, z, minRaw)`. Else `level = WAY_BELOW_MIN_Y` (no fluid).

`randomizedLevel(x, y, z, minRaw)`: `gx = floorDiv(x, 16)`, `gy = floorDiv(y, 40)`, `gz = floorDiv(z, 16)`; `base = gy * 40 + 20`; `n = spread(gx, gy, gz) * 10.0f` (the noise function evaluated with the grid indices as the block position, float multiply); `quantised = quantize(n, 3)`; `level = base + quantised`; return `min(minRaw, level)`.

`computeFluidType(x, y, z, global, level)`: `type = global.type`; if `level <= -10` and `level != WAY_BELOW_MIN_Y` and `global.type` is not lava: `gx = floorDiv(x, 64)`, `gy = floorDiv(y, 40)`, `gz = floorDiv(z, 64)`; if `|lavaNoise(gx, gy, gz)| > 0.3` then `type = lava`. Return `type`.

### 9.4 Surface level and `skipSamplingAboveY`

- `surfaceLevel(x, z)`: `qx = (x >> 2) << 2`, `qz = (z >> 2) << 2`; the cached value `floor(preliminary_surface_level(qx, 0, qz))`.
- The aquifer constructor derives, from the chunk's block range, `minGridX = gridX(chunkMinX - 5)` and `maxGridX = gridX(chunkMaxX - 5) + 1` (z likewise with `-5`; the grid arrays are sized from these and only cache values, so their sizes do not affect results). It computes `maxSurface` as the maximum of `floor(preliminary_surface_level)` over every quart-aligned column in the block rectangle from `(fromGridX(minGridX, 0), fromGridZ(minGridZ, 0))` to `(fromGridX(maxGridX, 9), fromGridZ(maxGridZ, 9))` (inclusive of the quart cells containing those corners). Then `skipSamplingAboveY = fromGridY(gridY(maxSurface + 8 + 12) - 1, 11) - 1`. Above that y the aquifer does nothing except return `global.at(y)`.

### 9.5 Chunk offsets for the surface scan

13 offsets `(ox, oz)`, in this order: (0,0), (-2,-1), (-1,-1), (0,-1), (1,-1), (-3,0), (-2,0), (-1,0), (1,0), (-2,1), (-1,1), (0,1), (1,1).

### 9.6 Worked examples (hand arithmetic from the formulas)

- `similarity(36, 50) = 1 - 14/25 = 0.44`; `FLOWING = 1 - (144 - 100)/25 = -0.76`.
- `pressure` with `sA = (63, water)`, `sB = (45, water)`, `y = 50`: `mid = 54`, `off = 50.5 - 54 = -3.5`, `half = 9`, `k = 5.5`; `off <= 0`, `v = 3 + 5.5 = 8.5`, `q = 8.5/3 = 2.8333`; `q > 2` so `barrier = 0`; result `2 * 2.8333 = 5.6667`.
- `pressure` with `sA = (63, water)`, `sB = (60, water)`, `y = 62`: `mid = 61.5`, `off = 1.0`, `half = 1.5`, `k = 0.5`; `off > 0`, `v = 0.5`, `q = 0.5/1.5 = 0.3333`; the barrier noise is sampled: result `2 * (barrier + 0.3333)`.
- `randomizedLevel` at `(x, y, z) = (100, 30, -50)`: `gx = 6`, `gy = 0`, `gz = -4`; `base = 20`; with a spread-noise value `n = 7.3` (assumed), `quantize(7.3, 3) = 6`, level 26, then `min` with `minRaw`.

---

## 10. Surface rules (`MaterialSystem`, `material_rule` data)

The surface pass (`MaterialSystem.buildSurface`) runs after the fill for every column of the chunk. It evaluates the data-driven **material rule** `minecraft:overworld` at every non-fluid, non-air block going downward.

### 10.1 Column procedure

For each column `(lx, lz)` (lx outer, lz inner), with block coordinates `x = chunkMinX + lx`, `z = chunkMinZ + lz`:

1. `startHeight = heightmap(WORLD_SURFACE_WG).getHeight(lx, lz) + 1` (`getHeight` is the absolute y of the highest non-air block the fill recorded, §8.1; so the loop starts at the first free block above it).
2. `biome = BiomeManager.getBiome(x, startHeight, z)` (§7.7).
3. If `biome` is `eroded_badlands`: apply the pillar extension (§10.7) with `(x, z, startHeight)`, then recompute `startHeight = getHeight(...) + 1`.
4. Compute `gradX = H(min(lx+1, 15), lz) - H(max(lx-1, 0), lz)` and `gradZ = H(lx, min(lz+1, 15)) - H(lx, max(lz-1, 0))` where `H` is `WORLD_SURFACE_WG`'s `getHeight` (so gradients never leave the chunk). *Steep* is true when `gradX <= -4` or `gradZ >= 4`.
5. Compute the column state (§10.3): `surfaceDepth` from the surface noise; reset `stoneDepthAbove = 0`, `waterHeight = none`, `lowerStone = unset`.
6. For `y` from `startHeight` **down** to the minimum y (-64): `block = column[y]`.
   - If `block` is air: `stoneDepthAbove = 0`, `waterHeight = none`; continue.
   - Else if `block` has a non-empty fluid state (water or lava): if `waterHeight` is none then `waterHeight = y + 1`; continue.
   - Else (solid): `stoneDepthAbove = stoneDepthAbove + 1`. If `lowerStone >= y` (it starts as +infinity, so the first solid block always triggers this): scan `y' = y - 1, y - 2, ...` for the first block that is not "stone" (non-air with an empty fluid state), and set `lowerStone = y' + 1`; if the scan passes `minY`, the block below the column counts as non-stone, so `lowerStone = minY`. `stoneDepthBelow = y - lowerStone + 1`. Set the context to `(stoneDepthAbove, stoneDepthBelow, waterHeight, y)`. If `minY <= y <= maxY`: `result = rule(x, y, z)`; if non-null, set `column[y] = result`.
7. After the column: if `biome` is `frozen_ocean` or `deep_frozen_ocean`: apply the iceberg extension (§10.8) with `(minSurfaceLevel, biome, x, z, startHeight)`.

`stoneDepthAbove` is 1 for the first solid block under air or water; `stoneDepthBelow` is 1 for the lowest block of an unbroken solid run. Fluid blocks do not count as solid and reset nothing except through the air test; `waterHeight` is the y one above the **first** (highest) fluid block met since the last air block.

Within a column the biome used by the `biome` condition is `BiomeManager.getBiome(x, y, z)` at the **current y** (re-evaluated per y, cached within the y step); caves therefore get their cave biome.

### 10.2 Surface-depth context values

| Value | Definition |
|---|---|
| `surfaceDepth` | §10.3, per column |
| `surfaceSecondary` | `surface_secondary.get(x, 0, z)` (double of the float) |
| `minSurfaceLevel` | `floor(chunk_surface_level(x, 0, z)) + surfaceDepth - 8` (§6.3) |
| `waterHeight`, `stoneDepthAbove`, `stoneDepthBelow`, `y` | §10.1 |
| noise samplers | a 2D threshold condition samples `N.get(x, 0, z)`; a 3D one (`is_3d`) samples `N.get(x, y, z)` |

### 10.3 Surface depth

`surfaceDepth(x, z) = (int)( surface.get(x, 0, z) * 2.75 + 3.0 + R.nextDouble() * 0.25 )` where `surface` is the normal noise `minecraft:surface` (float result converted to double) and `R = P.at(x, 0, z)` (§2.5 item 6). The cast truncates toward zero (a negative argument rounds toward zero).

### 10.4 Conditions

| `type` | Parameters | True when |
|---|---|---|
| `biome` | `biome_is` (one id or a list) | the biome at `(x, y, z)` (§10.1) is one of them |
| `above_preliminary_surface` | none | `y >= minSurfaceLevel` |
| `stone_depth` | `surface_type` (`floor` or `ceiling`), `offset`, `add_surface_depth` (bool), `secondary_depth_range` (int) | `d <= 1 + offset + (add_surface_depth ? surfaceDepth : 0) + s`, where `d = stoneDepthAbove` for `floor` and `stoneDepthBelow` for `ceiling`, and `s = 0` if `secondary_depth_range == 0`, else `(int) map(surfaceSecondary, -1.0, 1.0, 0.0, secondary_depth_range)` |
| `water` | `offset`, `surface_depth_multiplier` (-20..20), `add_stone_depth` (bool) | `waterHeight == none`, or `y + (add_stone_depth ? stoneDepthAbove : 0) >= waterHeight + offset + surfaceDepth * surface_depth_multiplier` |
| `y_above` | `anchor`, `surface_depth_multiplier` (-20..20), `add_stone_depth` (bool) | `y + (add_stone_depth ? stoneDepthAbove : 0) >= anchorY + surfaceDepth * surface_depth_multiplier` |
| `steep` | none | §10.1 step 4 |
| `hole` | none | `surfaceDepth <= 0` |
| `noise_threshold` | `noise`, `min_threshold`, `max_threshold`, optional `is_3d` (default false) | `min_threshold <= N.get(...) <= max_threshold` (both ends inclusive; the noise is the normal noise of that id, §3.3; double value) |
| `vertical_gradient` | `random_name`, `true_at_and_below`, `false_at_and_above` | if `y <= trueAt` true; if `y >= falseAt` false; else `t = map(y, trueAt, falseAt, 1.0, 0.0)` and true iff `F.at(x, y, z).nextFloat() < t`, where `F = P.fromHashOf(random_name).forkPositional()` |
| `not` | `invert` | the inner condition is false |
| `temperature` | none | (exists in the artifact; unused by the overworld rules read) |

**Anchors**: `{"absolute": n}` = `n`; `{"above_bottom": n}` = `minY + n` (`-64 + n`); `{"below_top": n}` = `minY + height - 1 - n` (`319 - n`). A fourth anchor type, `VerticalAnchor$RelativeToSeaLevel` (JSON key `relative_to_sea_level`; value `seaLevel + offset`), exists in the jar; the overworld material rules, material conditions, noise settings and density functions read use only `absolute` (24 uses), `above_bottom` (2) and `below_top` (3), so it is unused here.

Named conditions in `data/.../material_condition/` (used by the rule tree):

| Name | Definition |
|---|---|
| `on_floor` | `stone_depth(floor, offset 0, add_surface_depth false, secondary 0)` |
| `under_floor` | `stone_depth(floor, offset 0, add_surface_depth true, secondary 0)` |
| `deep_under_floor` | `stone_depth(floor, offset 0, add_surface_depth true, secondary 6)` |
| `very_deep_under_floor` | `stone_depth(floor, offset 0, add_surface_depth true, secondary 30)` |
| `on_ceiling` | `stone_depth(ceiling, offset 0, add_surface_depth false, secondary 0)` |
| `under_ceiling` | `stone_depth(ceiling, offset 0, add_surface_depth true, secondary 0)` |
| `not_underwater` | `water(offset -1, surface_depth_multiplier 0, add_stone_depth false)` |
| `not_under_deep_water` | `water(offset -6, surface_depth_multiplier -1, add_stone_depth true)` |

### 10.5 Rules

| `type` | Result |
|---|---|
| `sequence` | try each rule in order; the first non-null result wins; null if none |
| `condition` | `then_run` if `if_true` holds, else null |
| `block` | the block state `result_state` (a block name, with properties where listed) |
| `bandlands` (sic, the artifact spells the id this way) | the terracotta band block of §10.6 at `(x, y, z)` |
| `ore_vein` | ore veins; specified in document 11 |

A column position that no rule matches keeps the block placed by the fill (stone, or deepslate/bedrock if a rule matched).

### 10.6 Terracotta bands

`clayBands` is an array of 192 block states, built once per world from `r = P.fromHashOf("minecraft:clay_bands")`:

1. Fill all 192 with `terracotta`.
2. `i = 0`; while `i < 192`: `i = i + r.nextInt(5) + 1`; if `i < 192` set `bands[i] = orange_terracotta`; `i = i + 1`.
3. `makeBands(1, yellow_terracotta)`, `makeBands(2, brown_terracotta)`, `makeBands(1, red_terracotta)`, where `makeBands(width, state)`: `count = r.nextIntBetweenInclusive(6, 15)`; repeat `count` times: `w = width + r.nextInt(3)`, `start = r.nextInt(192)`; for `k = 0 .. w-1` while `start + k < 192`: `bands[start + k] = state`.
4. `count = r.nextIntBetweenInclusive(9, 15)`; `pos = 0`; for `j = 0 .. count-1` while `pos < 192`: `bands[pos] = white_terracotta`; if `pos - 1 > 0` and `r.nextBoolean()` then `bands[pos-1] = light_gray_terracotta`; if `pos + 1 < 192` and `r.nextBoolean()` then `bands[pos+1] = light_gray_terracotta`; `pos = pos + r.nextInt(16) + 4`. (The `nextBoolean` is evaluated only when the position test passes.)

Band lookup: `getBand(x, y, z) = bands[(y + round(clay_bands_offset.get(x, 0, z) * 4.0f) + 192) mod 192]` where `round` is Java `Math.round(float)`: exactly floor(v + 1/2) in infinite precision, ties toward positive infinity, NOT a float add followed by floor (see §16.2 `round_f32`), and the noise value is a float.

### 10.7 Eroded badlands pillars (`erodedBadlandsExtension`)

Applies in §10.1 step 3 to a column whose biome is `eroded_badlands`, with `(x, z, startHeight)`:

1. `s = |badlands_surface.get(x, 0, z) * 8.25|`; `p = badlands_pillar.get(x * 0.2, 0, z * 0.2) * 15.0f`; `m = min(s, p)` (double). If `m <= 0` do nothing.
2. `roof = |badlands_pillar_roof.get(x * 0.75, 0, z * 0.75) * 1.5|`; `top = 64.0 + min(m*m * 2.5, ceil(roof * 50.0) + 24.0)`; `topY = floor(top)`.
3. If `startHeight > topY` do nothing.
4. Scan `y` from `topY` down to the minimum: if the block is the default block (stone), stop the scan; if it is water, **return** without changes.
5. From `topY` down: while the block at `y` is air, set it to the default block and decrease `y`.

### 10.8 Frozen-ocean icebergs (`frozenOceanExtension`)

Applies after the column of §10.1 for `frozen_ocean` / `deep_frozen_ocean`, with `(minSurfaceLevel, x, z, startHeight)` and `sea = 63`:

1. `m = min(|iceberg_surface.get(x, 0, z) * 8.25|, iceberg_pillar.get(x * 1.28, 0, z * 1.28) * 15.0f)`. If `m <= 1.8` do nothing.
2. `roof = |iceberg_pillar_roof.get(x * 1.17, 0, z * 1.17) * 1.5|`; `h = min(m*m * 1.2, ceil(roof * 40.0) + 14.0)`.
3. If the biome's *melt test* at `(x, sea, z)` holds (below), `h = h - 2.0`. If `h <= 2.0` do nothing.
4. `lowWater = sea - h - 7.0`; `h = h + sea`; `topIce = h`.
5. `R = P.at(x, 0, z)`; `snowCount = 0`; `maxSnow = 2 + R.nextInt(4)`; `snowAbove = sea + 18 + R.nextInt(10)` (draws in that order).
6. For `y` from `max(startHeight, (int)topIce + 1)` down to `minSurfaceLevel`:
   - **place** if (`block(y)` is air and `y < (int) topIce` and `R.nextDouble() > 0.01`) or (`block(y)` is water and `y > (int) lowWater` and `y < sea` and `R.nextDouble() > 0.15`) (the `nextDouble` is drawn only when the preceding tests hold; the water branch is tried only if the air branch's tests did not hold);
   - a placed block is `snow_block` if `snowCount <= maxSnow` and `y > snowAbove` (then `snowCount = snowCount + 1`), else `packed_ice`.

*Melt test* (`Biome.shouldMeltFrozenOceanIcebergSlightly(pos, sea)`): `getTemperature(pos) > 0.1`. For positions at or below `y = sea + 17 = 80` the height adjustment of the biome temperature is zero, so the value is the biome base temperature passed through the biome's temperature modifier. For `frozen` modifier biomes: `f = FROZEN_TEMPERATURE_NOISE.get(x * 0.05, z * 0.05) * 7.0f`, `info = BIOME_INFO_NOISE.get(x * 0.2, z * 0.2)`; if `f + info < 0.3` and `BIOME_INFO_NOISE.get(x * 0.09, z * 0.09) < 0.8` the temperature is `0.2` (melt test true), else the base temperature (0.0 for `frozen_ocean`, 0.5 for `deep_frozen_ocean`; note 0.5 > 0.1 so the deep frozen ocean always melts). The noises are fixed-seed simplex noises (§3.5): `BIOME_INFO_NOISE` = one `SimplexNoise(r, true)` with `r = WorldgenRandom(LegacyRandomSource(2345))`; `FROZEN_TEMPERATURE_NOISE` = a stack of three `SimplexNoise(r, true)` built in order from one `r = WorldgenRandom(LegacyRandomSource(3456))` with layers (frequency 1.0, amplitude 0.14285715f), (0.5, 0.2857143f), (0.25, 0.5714286f). (`WorldgenRandom` extends `LegacyRandomSource` and delegates `next(bits)` to the wrapped legacy source, read from its bytecode, so the sequence is the plain legacy one (the `WorldgenRandom` wrapper as used by carvers and decoration is described in [11-world-generation-caves-and-ores.md](11-world-generation-caves-and-ores.md) §4). All seeds and amplitudes in this paragraph were read directly from `Biome`'s static initialiser.)

### 10.9 The overworld material rule tree

The tree below is the data of `material_rule/overworld.json` with every referenced rule and condition inlined by name (a reference printed as `[name]` shows its definition at the first use and `-> name (defined above)` afterwards). `noise(x) in [a, b]` is the `noise_threshold` condition; the huge upper bound 1.7976931348623157e+308 is `Double.MAX_VALUE`. `vgrad(name, true<=A, false>=B)` is the vertical gradient condition. Blocks have default properties unless shown.

```
[overworld]
  SEQUENCE (first rule that yields a block wins):
    [bedrock_floor]
      IF vgrad(bedrock_floor, true<=bottom+0, false>=bottom+5) THEN
        BLOCK bedrock
    [overworld/copper_ore_vein]
      ORE_VEIN {"density": "overworld/ore_vein/copper_density", "filler_block": "granite", "filler_gap": "overworld/ore_vein/gap", "ore_block": "copper_ore", "raw_ore_block": "raw_copper_block", "raw_ore_chance": 0.02, "richness": "overworld/ore_vein/richness"}
    [overworld/iron_ore_vein]
      ORE_VEIN {"density": "overworld/ore_vein/iron_density", "filler_block": "tuff", "filler_gap": "overworld/ore_vein/gap", "ore_block": "deepslate_iron_ore", "raw_ore_block": "raw_iron_block", "raw_ore_chance": 0.02, "richness": "overworld/ore_vein/richness"}
    IF above_preliminary_surface THEN
      [overworld/surface]
        SEQUENCE (first rule that yields a block wins):
          IF on_floor THEN
            SEQUENCE (first rule that yields a block wins):
              IF biome in {wooded_badlands} THEN
                IF y_above(anchor=97, stone_depth_mult=2, add_stone_depth=false) THEN
                  SEQUENCE (first rule that yields a block wins):
                    IF noise(surface) in [-0.909, -0.5454] THEN
                      BLOCK coarse_dirt
                    IF noise(surface) in [-0.1818, 0.1818] THEN
                      BLOCK coarse_dirt
                    IF noise(surface) in [0.5454, 0.909] THEN
                      BLOCK coarse_dirt
                    [overworld/biome_surface/default]
                      SEQUENCE (first rule that yields a block wins):
                        IF not_underwater THEN
                          BLOCK grass_block
                        BLOCK dirt
              IF biome in {swamp} THEN
                IF y_above(anchor=62, stone_depth_mult=0, add_stone_depth=false) THEN
                  IF NOT y_above(anchor=63, stone_depth_mult=0, add_stone_depth=false) THEN
                    IF noise(surface_swamp) in [0.0, 1.7976931348623157e+308] THEN
                      BLOCK water
              IF biome in {mangrove_swamp} THEN
                IF y_above(anchor=60, stone_depth_mult=0, add_stone_depth=false) THEN
                  IF NOT y_above(anchor=63, stone_depth_mult=0, add_stone_depth=false) THEN
                    IF noise(surface_swamp) in [0.0, 1.7976931348623157e+308] THEN
                      BLOCK water
          IF biome in {badlands,eroded_badlands,wooded_badlands} THEN
            SEQUENCE (first rule that yields a block wins):
              IF on_floor THEN
                SEQUENCE (first rule that yields a block wins):
                  IF y_above(anchor=256, stone_depth_mult=0, add_stone_depth=false) THEN
                    BLOCK orange_terracotta
                  IF y_above(anchor=74, stone_depth_mult=1, add_stone_depth=true) THEN
                    SEQUENCE (first rule that yields a block wins):
                      IF noise(surface) in [-0.909, -0.5454] THEN
                        BLOCK terracotta
                      IF noise(surface) in [-0.1818, 0.1818] THEN
                        BLOCK terracotta
                      IF noise(surface) in [0.5454, 0.909] THEN
                        BLOCK terracotta
                      BADLANDS_BANDS
                  IF not_underwater THEN
                    SEQUENCE (first rule that yields a block wins):
                      IF on_ceiling THEN
                        BLOCK red_sandstone
                      BLOCK red_sand
                  IF NOT hole THEN
                    BLOCK orange_terracotta
                  IF not_under_deep_water THEN
                    BLOCK white_terracotta
                  [overworld/gravel_or_stone_if_ceiling]
                    SEQUENCE (first rule that yields a block wins):
                      IF on_ceiling THEN
                        BLOCK stone
                      BLOCK gravel
              IF y_above(anchor=63, stone_depth_mult=-1, add_stone_depth=true) THEN
                SEQUENCE (first rule that yields a block wins):
                  IF y_above(anchor=63, stone_depth_mult=0, add_stone_depth=false) THEN
                    IF NOT y_above(anchor=74, stone_depth_mult=1, add_stone_depth=true) THEN
                      BLOCK orange_terracotta
                  BADLANDS_BANDS
              IF under_floor THEN
                IF not_under_deep_water THEN
                  BLOCK white_terracotta
          IF on_floor THEN
            IF not_underwater THEN
              SEQUENCE (first rule that yields a block wins):
                IF biome in {frozen_ocean,deep_frozen_ocean} THEN
                  IF hole THEN
                    BLOCK air
                [overworld/biome_surface]
                  SEQUENCE (first rule that yields a block wins):
                    IF biome in {frozen_peaks} THEN
                      [overworld/biome_surface/frozen_peaks]
                        SEQUENCE (first rule that yields a block wins):
                          IF steep THEN
                            BLOCK packed_ice
                          IF noise(packed_ice) in [0.0, 0.2] THEN
                            BLOCK packed_ice
                          IF noise(ice) in [0.0, 0.025] THEN
                            BLOCK ice
                          IF not_underwater THEN
                            BLOCK snow_block
                    IF biome in {snowy_slopes} THEN
                      [overworld/biome_surface/snowy_slopes]
                        SEQUENCE (first rule that yields a block wins):
                          IF steep THEN
                            BLOCK stone
                          [overworld/powder_snow_surface]
                            IF noise(powder_snow) in [0.35, 0.6] THEN
                              IF not_underwater THEN
                                BLOCK powder_snow
                          IF not_underwater THEN
                            BLOCK snow_block
                    IF biome in {jagged_peaks} THEN
                      [overworld/biome_surface/jagged_peaks]
                        SEQUENCE (first rule that yields a block wins):
                          IF steep THEN
                            BLOCK stone
                          IF not_underwater THEN
                            BLOCK snow_block
                    IF biome in {grove} THEN
                      [overworld/biome_surface/grove]
                        SEQUENCE (first rule that yields a block wins):
                          -> overworld/powder_snow_surface (defined above)
                          IF not_underwater THEN
                            BLOCK snow_block
                    SEQUENCE (first rule that yields a block wins):
                      IF biome in {stony_peaks} THEN
                        [overworld/biome_surface/stony_peaks]
                          SEQUENCE (first rule that yields a block wins):
                            IF noise(calcite) in [-0.0125, 0.0125] THEN
                              BLOCK calcite
                            BLOCK stone
                      IF biome in {stony_shore} THEN
                        [overworld/biome_surface/stony_shore]
                          SEQUENCE (first rule that yields a block wins):
                            IF noise(gravel) in [-0.05, 0.05] THEN
                              -> overworld/gravel_or_stone_if_ceiling (defined above)
                            BLOCK stone
                      IF biome in {windswept_hills} THEN
                        [overworld/biome_surface/windswept_hills]
                          IF noise(surface) in [0.12121212121212122, 1.7976931348623157e+308] THEN
                            BLOCK stone
                      IF biome in {warm_ocean,beach,snowy_beach} THEN
                        [overworld/sand_or_sandstone_if_ceiling]
                          SEQUENCE (first rule that yields a block wins):
                            IF on_ceiling THEN
                              BLOCK sandstone
                            BLOCK sand
                      IF biome in {desert} THEN
                        -> overworld/sand_or_sandstone_if_ceiling (defined above)
                      IF biome in {dripstone_caves} THEN
                        [overworld/biome_surface/dripstone_caves]
                          BLOCK stone
                      IF biome in {sulfur_caves} THEN
                        [overworld/biome_surface/sulfur_caves]
                          SEQUENCE (first rule that yields a block wins):
                            [overworld/sulfur_cave_bands]
                              SEQUENCE (first rule that yields a block wins):
                                IF noise3D(sulfur_cave_gradient) in [-0.4000000059604645, -0.10000000149011612] THEN
                                  BLOCK cinnabar
                                IF noise3D(sulfur_cave_gradient) in [0.0, 0.4000000059604645] THEN
                                  BLOCK sulfur
                                IF noise3D(sulfur_cave_gradient) in [0.4000000059604645, 1.7976931348623157e+308] THEN
                                  BLOCK cinnabar
                            BLOCK stone
                      IF biome in {mangrove_swamp} THEN
                        [overworld/biome_surface/mangrove_swamp]
                          BLOCK mud
                    IF biome in {windswept_savanna} THEN
                      [overworld/biome_surface/windswept_savanna]
                        SEQUENCE (first rule that yields a block wins):
                          IF noise(surface) in [0.21212121212121213, 1.7976931348623157e+308] THEN
                            BLOCK stone
                          IF noise(surface) in [-0.06060606060606061, 1.7976931348623157e+308] THEN
                            BLOCK coarse_dirt
                    IF biome in {windswept_gravelly_hills} THEN
                      [overworld/biome_surface/windswept_gravelly_hills]
                        SEQUENCE (first rule that yields a block wins):
                          IF noise(surface) in [0.24242424242424243, 1.7976931348623157e+308] THEN
                            -> overworld/gravel_or_stone_if_ceiling (defined above)
                          IF noise(surface) in [0.12121212121212122, 1.7976931348623157e+308] THEN
                            BLOCK stone
                          IF noise(surface) in [-0.12121212121212122, 1.7976931348623157e+308] THEN
                            -> overworld/biome_surface/default (defined above)
                          -> overworld/gravel_or_stone_if_ceiling (defined above)
                    IF biome in {old_growth_pine_taiga,old_growth_spruce_taiga} THEN
                      [overworld/biome_surface/old_growth_pine_taiga]
                        SEQUENCE (first rule that yields a block wins):
                          IF noise(surface) in [0.21212121212121213, 1.7976931348623157e+308] THEN
                            BLOCK coarse_dirt
                          IF noise(surface) in [-0.11515151515151514, 1.7976931348623157e+308] THEN
                            BLOCK podzol
                    IF biome in {ice_spikes} THEN
                      [overworld/biome_surface/ice_spikes]
                        IF not_underwater THEN
                          BLOCK snow_block
                    IF biome in {mushroom_fields} THEN
                      [overworld/biome_surface/mushroom_fields]
                        BLOCK mycelium
                    IF biome in {dappled_forest} THEN
                      [overworld/biome_surface/dappled_forest]
                        IF noise(small_patch) in [1.2000000476837158, 1.7976931348623157e+308] THEN
                          BLOCK coarse_dirt
                    -> overworld/biome_surface/default (defined above)
          IF not_under_deep_water THEN
            SEQUENCE (first rule that yields a block wins):
              IF on_floor THEN
                IF biome in {frozen_ocean,deep_frozen_ocean} THEN
                  IF hole THEN
                    BLOCK water
              IF under_floor THEN
                [overworld/under_biome_surface]
                  SEQUENCE (first rule that yields a block wins):
                    IF biome in {frozen_peaks} THEN
                      [overworld/under_biome_surface/frozen_peaks]
                        SEQUENCE (first rule that yields a block wins):
                          IF steep THEN
                            BLOCK packed_ice
                          IF noise(packed_ice) in [-0.5, 0.2] THEN
                            BLOCK packed_ice
                          IF noise(ice) in [-0.0625, 0.025] THEN
                            BLOCK ice
                          IF not_underwater THEN
                            BLOCK snow_block
                    IF biome in {snowy_slopes} THEN
                      [overworld/under_biome_surface/snowy_slopes]
                        SEQUENCE (first rule that yields a block wins):
                          IF steep THEN
                            BLOCK stone
                          [overworld/powder_snow_under_surface]
                            IF noise(powder_snow) in [0.45, 0.58] THEN
                              IF not_underwater THEN
                                BLOCK powder_snow
                          IF not_underwater THEN
                            BLOCK snow_block
                    IF biome in {jagged_peaks} THEN
                      [overworld/under_biome_surface/jagged_peaks]
                        BLOCK stone
                    IF biome in {grove} THEN
                      [overworld/under_biome_surface/grove]
                        SEQUENCE (first rule that yields a block wins):
                          -> overworld/powder_snow_under_surface (defined above)
                          BLOCK dirt
                    SEQUENCE (first rule that yields a block wins):
                      IF biome in {stony_peaks} THEN
                        -> overworld/biome_surface/stony_peaks (defined above)
                      IF biome in {stony_shore} THEN
                        -> overworld/biome_surface/stony_shore (defined above)
                      IF biome in {windswept_hills} THEN
                        -> overworld/biome_surface/windswept_hills (defined above)
                      IF biome in {warm_ocean,beach,snowy_beach} THEN
                        -> overworld/sand_or_sandstone_if_ceiling (defined above)
                      IF biome in {desert} THEN
                        -> overworld/sand_or_sandstone_if_ceiling (defined above)
                      IF biome in {dripstone_caves} THEN
                        -> overworld/biome_surface/dripstone_caves (defined above)
                      IF biome in {sulfur_caves} THEN
                        -> overworld/biome_surface/sulfur_caves (defined above)
                      IF biome in {mangrove_swamp} THEN
                        -> overworld/biome_surface/mangrove_swamp (defined above)
                    IF biome in {windswept_savanna} THEN
                      [overworld/under_biome_surface/windswept_savanna]
                        IF noise(surface) in [0.21212121212121213, 1.7976931348623157e+308] THEN
                          BLOCK stone
                    IF biome in {windswept_gravelly_hills} THEN
                      [overworld/under_biome_surface/windswept_gravelly_hills]
                        SEQUENCE (first rule that yields a block wins):
                          IF noise(surface) in [0.24242424242424243, 1.7976931348623157e+308] THEN
                            -> overworld/gravel_or_stone_if_ceiling (defined above)
                          IF noise(surface) in [0.12121212121212122, 1.7976931348623157e+308] THEN
                            BLOCK stone
                          IF noise(surface) in [-0.12121212121212122, 1.7976931348623157e+308] THEN
                            BLOCK dirt
                          -> overworld/gravel_or_stone_if_ceiling (defined above)
                    [overworld/under_biome_surface/default]
                      BLOCK dirt
              IF biome in {warm_ocean,beach,snowy_beach} THEN
                IF deep_under_floor THEN
                  BLOCK sandstone
              IF biome in {desert} THEN
                IF very_deep_under_floor THEN
                  BLOCK sandstone
          IF on_floor THEN
            SEQUENCE (first rule that yields a block wins):
              IF biome in {frozen_peaks,jagged_peaks} THEN
                BLOCK stone
              IF biome in {warm_ocean,lukewarm_ocean,deep_lukewarm_ocean} THEN
                -> overworld/sand_or_sandstone_if_ceiling (defined above)
              -> overworld/gravel_or_stone_if_ceiling (defined above)
    [overworld/underground]
      SEQUENCE (first rule that yields a block wins):
        IF biome in {sulfur_caves} THEN
          -> overworld/sulfur_cave_bands (defined above)
        IF vgrad(deepslate, true<=0, false>=8) THEN
          BLOCK deepslate
```

**Reading the top of the tree**: at every solid block, in order: (1) bedrock with a 5-block probabilistic floor (`y = -64` always; `-63..-60` with probability 0.8, 0.6, 0.4, 0.2 per block from the position random of §10.4); (2) the two ore-vein rules (document 11); (3) if the block is at or above `minSurfaceLevel`: the *surface* rule; (4) otherwise the *underground* rule: sulfur-cave bands in `sulfur_caves`, then deepslate with a probabilistic transition from y = 0 (always deepslate at or below 0) to y = 8 (never at or above 8): probability `map(y, 0, 8, 1, 0)` = 0.875, 0.75, ..., 0.125 at y = 1..7.

---

## 11. Generation stages and chunk-border rules

### 11.1 Stage order

`ChunkPyramid.GENERATION_PYRAMID`:

| # | Stage (`ChunkStatus`) | Needs from neighbours | What it does for terrain |
|---|---|---|---|
| 1 | `EMPTY` | none | creates the empty proto-chunk |
| 2 | `STRUCTURE_STARTS` | none | places structure start records (outside this document) |
| 3 | `STRUCTURE_REFERENCES` | `STRUCTURE_STARTS` within radius 8 | collects references to starts of nearby chunks |
| 4 | `BIOMES` | `STRUCTURE_STARTS` within radius 8 | fills the chunk's biome palettes (§7.6) |
| 5 | `TERRAIN` | `STRUCTURE_STARTS` within radius 8, `BIOMES` within radius 1; block writes only inside the chunk (write radius 0) | `doFill` (§8), then the surface pass (§10), then carvers (document 11) |
| 6 | `FEATURES` | `STRUCTURE_STARTS` within 8, `TERRAIN` within radius 1; may write blocks in neighbours (write radius 1) | decoration (document 11) |
| 7-10 | `INITIALIZE_LIGHT`, `LIGHT`, `SPAWN`, `FULL` | light within radius 1 | lighting, mob spawn, finalisation |

(The requirements per stage were read from the ten step lambdas of `ChunkPyramid` taken in builder order; matching lambdas to stages by that order is inferred.) Within the `TERRAIN` stage the order is exactly: create the noise chunk (sampler context, aquifer, beardifier for structures) -> fill -> surface rules -> carvers.

### 11.2 Chunk-border rules

- **Density, aquifer and surface-level values are pure functions of the world seed and absolute coordinates.** Neighbouring chunks agree on every shared value without exchanging data: the `interpolated` cell grid is world-aligned (§4.1); aquifer centres derive from `P.at(cell)` (§9.2); the aquifer's surface-level scan reads `preliminary_surface_level` at columns up to three chunks away, computed directly from the functions, not from chunk data.
- The terrain fill writes only the chunk's own 16×16 column.
- The surface pass uses the chunk's own heightmaps; the gradient taps clamp to the chunk (`min(lx+1, 15)`, `max(lx-1, 0)`), so *steep* at a chunk edge looks at a one-sided difference.
- The surface pass's biome lookup (§7.7) can read the stored biome of the **neighbouring chunk** across a border (it samples cells at quart offsets up to +1 beyond the chunk), which is why `TERRAIN` requires `BIOMES` of the 3×3 neighbourhood.
- The only cross-chunk term in the density is the **beardifier** (§4.1): a sum of contributions of structures whose starts lie in the neighbourhood (`STRUCTURE_STARTS` within radius 8). Without structures it is exactly 0, and then terrain is independent of every neighbour.
- Decoration (`FEATURES`) may modify blocks in the 3×3 neighbourhood, so a chunk's final blocks are only fixed once its neighbours have reached `FEATURES`.

---

## 12. Other noise presets

`minecraft:amplified` and `minecraft:large_biomes` world presets use `noise_settings/amplified.json` and `large_biomes.json`: identical scalar settings (sea level 63, min_y -64, height 384, same default block, same material rule `minecraft:overworld`), and routers pointing at different density-function files:

| Preset | Router differences vs `overworld` |
|---|---|
| `large_biomes` | `continents`, `erosion`, `temperature`, `vegetation` use the `*_large` noises (`continentalness_large` base_octave -11, `erosion_large` -11, `temperature_large` -12, `vegetation_large` -10; otherwise equal in the §3.6 table); `depth`, `final_density`, `chunk_surface_level` come from `overworld_large_biomes/`, whose `factor`, `offset`, `jaggedness` are the **same spline trees** as Appendix A with the coordinate functions replaced by the large-biome `continents`/`erosion`; `ridges` is shared |
| `amplified` | `depth`, `final_density`, `chunk_surface_level` from `overworld_amplified/`: `offset`: the same spline as Appendix A.1 with 126 of its 201 leaf values doubled (e.g. 0.044 -> 0.088, 0.69000006 -> 1.3800001) and every location, slope and the other 75 leaf values unchanged; `jaggedness`: the spline of A.3 with the 14 non-zero leaf values doubled (0.63 -> 1.26, 0.3 -> 0.6, 0.315 -> 0.63, 0.15 -> 0.3); `factor`: a different table, Appendix A.4; in `preliminary_surface_level` and `final_density` the constant 0.1171875 is 0.4 and the second gradient runs from y 304 to 320 instead of 240 to 256 |

The amplified `offset` and `jaggedness` are fully determined by A.1 and A.3 plus the doubling rule; the amplified `factor` is tabulated in A.4. The amplified `sloped_cheese` is the same expression as §6.2 with the amplified `depth`, `jaggedness` and `factor`. Both presets share the climate-to-biome table of §7.4.

---

## 13. Worked examples (computed, unverified against the artifact)

**Every value in this section is computed, not read from the artifact (unverified).** In particular the climate values and biomes at seeds 0 and 12345 (§13.2) and the shaping-function and surface-level values (§13.3) depend on the biome-table transcription of §7.4, which has no data file to check against, and on the reference implementation of this document's own text. Block coordinates are given; `y` is the y at which the quantity is sampled.

### 13.1 A named noise (seed 0, `minecraft:continentalness`)

- `P`, md5 and generator state: see §2.7. Forks: `A = (lo 0x6EB32CDA42831099, hi 0xF7E4A592E7138F42)`, `B = (lo 0x6F3D4198B2BED34F, hi 0xA176D90985E60C61)`.
- Generator for octave -9 of noise A: `lo = 0x669CCE8FBA3D76A8`, `hi = 0xB972B40CC5CD53C3`. Its Perlin offsets: `offsetX = 107.83518441372479`, `offsetY = 250.9820076676574`, `offsetZ = 65.88805370474378`; the first eight permutation entries are 254, 118, 111, 215, 206, 135, 96, 9.
- `PerlinNoise.get(0.5, 0.5, 0.5)` of that octave = -0.06469294428825378; `get(3.2, -1.7, 10.9)` = -0.24498175084590912 (float results printed as doubles).
- `nf` for continentalness = 1.6890307671940874; the layer amplitudes `(float)(nf * amp)` for the nine octaves (-9..-1) are 0.7514677, 0.3757339, 0.3757339, 0.1878669, 0.0939335, 0.0234834, 0.0117417, 0.0058708, 0.0029354; the layer frequencies are `2^-9 .. 2^-1` and each multiplied by 1.0181268882175227 for the second noise of the pair.
- Raw `continentalness` noise (no shifts, no scale) at `(0, 0, 0)` = -0.027066009119153023; at `(100, 0, -200)` = 0.015725092962384224.

### 13.2 Shift and climate at seed 0 and seed 12345

Seed 0:

| Block (x, y, z) | shift_x | shift_z |
|---|---|---|
| (0, 64, 0) | -2.174344539642334 | -2.174344539642334 |
| (100, 64, -200) | 0.029261112213134766 | -0.86368727684021 |

Climate (temperature, humidity, continentalness, erosion, depth, weirdness) at quart cells `(qx, qy, qz)`, i.e. block `(4qx, 4qy, 4qz)`:

| Seed | Quart | T | H | C | E | D | W | Biome |
|---|---|---|---|---|---|---|---|---|
| 0 | (0, 16, 0) | 0.11823774 | -0.00136023 | -0.00817188 | -0.10391065 | -0.08811796 | 0.01111024 | `river` (fitness 776161) |
| 0 | (25, 16, -50) | 0.12612928 | 0.05341838 | -0.03081860 | 0.02062055 | 0.08067334 | -0.55306470 | `forest` (649636) |
| 0 | (-40, 10, 60) | 0.13765390 | -0.05116245 | 0.16867512 | 0.05599257 | 0.19496506 | 0.27155048 | `forest` (3798601) |
| 12345 | (0, 16, 0) | -0.02158737 | 0.67213786 | -0.39912370 | -0.72940190 | -0.12375003 | 0.15691625 | `ocean` (1530169) |
| 12345 | (25, 16, -50) | -0.05287030 | 0.74938870 | 0.07884901 | -0.62757623 | 0.27907765 | 0.29169118 | `lush_caves` (0) |
| 12345 | (-40, 10, 60) | 0.01013047 | 0.30342054 | -0.18338949 | -0.78593713 | 0.06374997 | -0.13597381 | `stony_shore` (405769) |

Quantised target of the first row: `(1182, -13, -81, -1039, -881, 111)`.

### 13.3 Terrain shaping functions at block columns (seed 0)

| (x, z) | continents | erosion | ridges | offset | factor | jaggedness | preliminary_surface_level |
|---|---|---|---|---|---|---|---|
| (0, 0) | -0.00817188 | -0.10391065 | 0.01111024 | -0.58811796 | 5.08120489 | 0.0 | 40 |
| (100, -200) | -0.03081860 | 0.02062055 | -0.55306470 | -0.41932666 | 6.24603844 | 0.0 | 64 |
| (-160, 240) | 0.16867512 | 0.05599257 | 0.27155048 | -0.49253494 | 4.69000006 | 0.0 | 56 |
| (1000, 1000) | -0.18554875 | -0.16899239 | 0.22494069 | -0.62375003 | 4.03006983 | 0.0 | 32 |

(The `ridges` values equal the weirdness column of §13.2 at the same positions.)

### 13.4 Parameter-point count and quantisation

`quantize(-0.78f) = -7799`; `quantize(-0.2225f) = -2225`; `quantize(0.05f) = 500`; `quantize(-0.7666667f) = -7666`; `quantize(-0.26666668f) = -2666`; `quantize(0.93333334f) = 9333`.

---

## 14. Validation checklist (checkable facts)

1. `new XoroshiroRandomSource(0)` has `(lo, hi) = (0x3564B439CD1E1F16, 0x63CFC62A2B097592)`; its first `nextLong()` is 3038984756725240190.
2. `mixStafford13` uses shifts 30, 27, 31 and the two constants of §2.2.
3. `Mth.getSeed(1, 2, 3) = -33674130277896`.
4. `fromHashOf` reads MD5 bytes big-endian; `at(x,y,z)` does not mix the seed.
5. A normalised one-octave noise has layer amplitude 5/6; `minecraft:offset` has layers 2/3, 1/3, 1/6 (each twice, the second set at frequency × 1.0181268882175227).
6. Normalisation factors: `aquifer_barrier` 0.8722451644522289, `continentalness` 1.6890307671940874, `offset` 1.3323764968871814, `surface` 1.3323764968871816, `jagged` 1.51074988909777 (§3.6 lists all).
7. Biome table: 7594 parameter points; 3795 + 3795 surface points, 3 underground, 1 bottom; per-biome counts as in §7.4.
8. `quantize(-0.78f) = -7799` (not -7800).
9. `FLOWING_UPDATE_SIMULARITY = -0.76`; aquifer grid 16 × 12 × 16 with sample offsets (-5, +1, -5); lava below y = -54, water at 63.
10. In `final_density`: bottom blend gradient -64..-40, top blend gradient 240..256, the `0.64` multiplier, the `1.5625` range cut and the cells 4×8×4.
11. Surface-depth formula `(int)(n * 2.75 + 3.0 + r * 0.25)`; `y_above(anchor 256)` gives orange terracotta cap in badlands; bedrock gradient from y -64 (certain) to y -59 (never).
12. Terracotta bands: 192 entries, base `terracotta`.
13. Steep: `gradX <= -4 || gradZ >= 4` with the chunk-clamped differences of §10.1.
14. `DimensionType.WAY_BELOW_MIN_Y = -32512` (`MIN_Y << 4`, from the read initialisers in §5).

---

## 15. Open questions

1. **R-tree tie-breaking.** The runtime biome search is an R-tree that starts from the thread's previous result and replaces only on strictly smaller distance; the reference brute force (first minimum in list order) can differ on exact fitness ties. The reader did not trace the tree construction. Ties are rare but occur on parameter-space boundaries (e.g. exactly equal quantised values).
2. **Cave densities.** `overworld/caves/*` and the `cave_layer` / `cave_cheese` uses are specified in document 11; this document only gives where they plug into `final_density` (§6.4, §6.5). A terrain-only implementation cannot omit them without changing the ground.
3. **Structures and the beardifier.** The structure terrain-adaptation term and `STRUCTURE_STARTS` are outside this round.
4. **Amplified and large-biomes presets.** Their relation to Appendix A (§12) was derived from a structural diff of the JSON files, not by reading each value in context: for large biomes only the coordinate function references differ; for amplified the stated leaf values differ. The nether and end noise settings are not covered.
5. **Unused density node types.** `interval_select`, `slice`, `pow`, `distance_to_point` and the end-only `end_outer_islands` are in the artifact; the overworld JSON data read here does not use them (`interval_select` and `slice` do appear in cave data; see document 11). Their semantics were not documented.
6. **Heightmap definitions.** Closed: read from `Heightmap$Types` (§8.1). Remaining detail not traced: the contents of the `#minecraft:blocks_motion` block tag beyond the fact that the heightmap tag delegates to it.
7. **Biome zoom seed.** Closed: the argument is `WorldOptions.seed()` via `ServerLevel.getSeed()` (§7.7), read from the call chain. Not traced: whether the `obfuscateSeed` call in `MinecraftServer` is used by generation (it supplies other state).
8. **`FROZEN` temperature modifier.** Read from the bytecode of `Biome`'s static initialiser: `TEMPERATURE_NOISE` = `SimplexNoise(WorldgenRandom(LegacyRandomSource(1234)), true)`; `BIOME_INFO_NOISE` = `SimplexNoise(WorldgenRandom(LegacyRandomSource(2345)), true)`; `FROZEN_TEMPERATURE_NOISE` = stack of three `SimplexNoise(r, true)` from one `r = WorldgenRandom(LegacyRandomSource(3456))`, layers (freq 1.0, amp 0.14285715f), (0.5, 0.2857143f), (0.25, 0.5714286f). `WorldgenRandom` extends `LegacyRandomSource` and its `next(bits)` delegates to the wrapped legacy source (read), so the draw sequence is the plain legacy one. See 11 §4 for the wrapper in its other uses. Still inferred: nothing in this item; the 1234 noise is used by the height adjustment above y = 80 only, which iceberg generation never reaches.
9. **`DimensionType` constants.** Closed: derived from the static initialisers (§5).
10. **Float behaviour of `Math.pow`/`Math.sqrt`** in `NormalNoise` setup is IEEE double; all of those values (frequencies, normalisation factors) are computed once per noise at start-up and rounded to float only where §3.3 says so. Closed by §16: the `pow` calls there have integer exponents with bases 2.0 and 0.5, so each result is an exact power of two (`Math.sqrt` is correctly rounded); remaining libm dependencies are listed in §16.7.
11. **Aquifer `shouldScheduleFluidUpdate`.** Its effect after generation (fluid ticks) is outside this document.
12. **Worked examples and counts.** §13, §2.7's derived values, and the per-biome counts in §7.4 come from a hand-written reference of this text and have not been compared against a run of the artifact; the biome table transcription has no data file to check against (see §7.4).
13. **Snow layers and top-layer freezing** (the `freeze_top_layer` feature) are decoration and belong to document 11; the surface rules here only place blocks (snow_block, packed_ice, powder_snow, ice).

---

## 16. Floating-point function set (libm-style functions and rounding rules; the `cc_f64_*` table)

Scope: every arithmetic step on `float`/`double` that documents 10, 11, 15 and 18 call for and that is not plain add, subtract, multiply, divide, `floor` (as an exact IEEE operation), `sqrt` or text conversion. Source: artifact `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md), version 26.3; class files are Java 25, major version 69). Method: static reading (`javap -c`) of `net.minecraft.util.Mth`, `net.minecraft.world.level.levelgen.*`, `net.minecraft.world.level.biome.*`, `net.minecraft.world.entity.*`, `net.minecraft.commands.*`, `net.minecraft.server.commands.*`; every call to `java.lang.Math`, `Mth`, `org.joml.Math` in the 6618 classes of `net/minecraft/{world,commands,util,core,server,network/protocol/game}` was enumerated. The JDK's own semantics (for `Math.round` and `Math.min`/`Math.max`) were read from the JDK 21 `Math.java` source on the analysis machine, not from the artifact (marked "JDK"). Worked examples were computed with a throwaway `python3 -I` script (scratch only); hex values are IEEE-754 bit patterns.

### 16.1 Findings in one list

1. The artifact contains **no call to `StrictMath`** anywhere in the enumerated classes; all libm-style calls are `java.lang.Math` (0 `StrictMath` invocations).
2. There is **no `tan`, `exp`, `cbrt`, `toDegrees` or `fmod` (as a method) call** in scope. `Math.log10` appears only in client option code (out of scope). `Math.log1p` (sculk), `Math.toRadians`, `Math.nextUp`, `Math.copySign` appear and have rows in §16.2 (all outside documents 10/11/15/18 except `toRadians` in entity position handling). `Math.random` appears only in a latency simulator (out of scope).
3. `Mth.sin` and `Mth.cos` are **table lookups** (65536 floats), not libm calls (§16.3). `Mth.atan2` is a **custom approximation** (two 257-entry double tables, one Newton step of an inverse square root, a cubic correction), not libm (§16.4). It is not exact: it differs from true `atan2` by up to about 8e-6 radian in 200000 random samples.
4. All float (`binary32`) arithmetic in the artifact is plain IEEE single precision with **no fused multiply-add** (no `Math.fma` call in scope) and each operation rounded to float before the next. It is reproduced exactly by doing the operation in double and rounding the result to float (§16.2, row `f32_round`).
5. The only places that genuinely need libm functions that plain IEEE operations cannot give are listed in §16.7.

### 16.2 The function table

Column "Prec" is the precision of the artifact call. "Suffix" is the proposed name suffix (`cc_f64_<suffix>`; every function takes and returns IEEE doubles; float values travel as doubles that are exactly representable in float). Rows marked "table" or "poly" replace a libm call in the artifact.

| Suffix | Artifact method | Prec | Exact semantics needed | Call sites in scope (class `method`) |
|---|---|---|---|---|
| `f32_round` | JVM `d2f` / `f2d` pair | f64 to f32 | Round a double to the nearest binary32, ties to even; magnitude above the float maximum becomes infinity; NaN stays NaN; subnormals are kept. Applied after **every** float add, subtract, multiply, divide, sqrt (reproduces binary32 exactly; tested 0 mismatches in 60000 random operand pairs per operation, checked against exact rational rounding) and wherever the artifact narrows (`(float)` casts, `d2f`). | everywhere float arithmetic occurs: `PerlinNoise`, `Mth.lerp(FFF)`, `Mth.smoothstep`, density-function samplers, `CubicSpline$Multipoint.sample`, carvers, `LivingEntity`, `Entity`, `LookControl`, etc. |
| `to_i32` | JVM `d2i` (and `f2i`) | f64 to i32 | Truncate toward zero; NaN gives 0; values at or above 2147483647 give 2147483647; at or below -2147483648 give -2147483648 (saturating, never wraps). A float is widened to double first (exact). | `Mth.floor`, `Mth.ceil`, `Mth.packDegrees`, `Climate.quantizeCoord` (long form), `BlockPos.containing`, every `(int)` cast of a double |
| `to_i64` | JVM `d2l` (and `f2l`) | f64 to i64 | As `to_i32` with the limits of 64 bits (+/-9223372036854775807/-9223372036854775808). Never wraps. | `Mth.sin`/`Mth.cos` table index, `Mth.lfloor`, `Mth.ceilLong`, `Climate.quantizeCoord`, `Math.round(D)` |
| `i32_to_f32` | JVM `i2f` | i32 to f32 | Nearest float, ties to even (integers above 2^24 lose low bits). `l2f`, `l2d` likewise (`l2d` rounds to nearest double above 2^53). | `Mth.unpackDegrees`, `Mth.lerpInt`, `GradientFunction` factor, `RoundFunction` |
| `floor` | `Math.floor(D)` | f64 | Exact IEEE floor (largest integral double not above x); -0.0 and NaN and infinities unchanged. Any C library gives the identical result. | `Mth.floor(D)`, `Mth.floor(F)` (widen first), `Mth.lfloor`, `GradientNoise.wrap`, `RoundFunction`, `MaterialSystem.erodedBadlandsExtension` etc. |
| `ceil` | `Math.ceil(D)` | f64 | Exact IEEE ceiling; same remarks. `Mth.ceil(F)` widens first then `to_i32`. | `Mth.ceil`, `OreFeature.place` (four `Mth.ceil(F)`), `MaterialSystem` extensions, `RoundFunction` |
| `round_f32` | `Math.round(F)` returning int | f32 | **Exact** floor(x + 1/2) in infinite precision (JDK): ties go toward positive infinity, so round(2.5)=3, round(-2.5)=-2, round(-0.5)=0; NaN gives 0; out-of-range saturates (as `to_i32`). **Not** "float add 0.5 then floor": for the float 0.49999997 (0x3EFFFFFF) the float sum 0.49999997+0.5 rounds to 1.0, but the correct result is 0. An implementation may take `r = floor(x)`, then `r + 1` if `x - r >= 0.5` (the difference is exact in double). | `MaterialSystem.getBand`, `RoundFunction` (type round), `TimeArgument.parse`, `LivingEntity.actuallyHurt`/`getDamageAfterMagicAbsorb`/`hurtServer`, `Player.actuallyHurt`/`damageStatsAndHearts`, `ServerPlayer.checkMovementStatistics`/`checkRidingStatistics`, `EnchantmentHelper.selectEnchantment`, `ApplyMobEffect.apply`, `BlocksAttacks`, `Item.getBarWidth` |
| `round_f64` | `Math.round(D)` returning long | f64 | Same rule on doubles (floor(x + 1/2) exactly), result `to_i64` saturating, NaN gives 0. | `VecDeltaCodec.encode` (value times 4096.0), `Player.causeFallDamage`, `ServerPlayer.checkMovementStatistics`, `RemoveBinomial.process` (these are the in-scope sites; other `Math.round(D)` callers `Shapes.create` (6), `Shapes.findBits` (2) and `ChunkGeneratorStructureState.generateRingPositions` (2) belong to other documents) |
| `abs_f32`, `abs_f64` | `Math.abs(F)` / `(D)`, `Mth.abs(F)` | f32 / f64 | Clear the sign bit: abs(-0.0) = +0.0, abs(-inf) = +inf, NaN stays NaN (payload kept). `abs_i32` (`Math.abs(I)`, `Mth.abs(I)`) is integer: abs(-2147483648) = -2147483648 (no libm; may be inlined). | `NormalNoise$OctaveInfo.absAmplitude`, `UnaryFunction$AbsSampler` (density node `abs`), `MaterialSystem` extensions, `Mth.absMax`, `Mth.equal`, `Mth.triangleWave`, `Aquifer$NoiseBasedAquifer.calculatePressure`/`computeFluidType`, `WorldCarver.carveEllipsoid`, `CanyonWorldCarver.updateVerticalRadius`, the carver width term of 11 (the `1 - |0.5 - step/maxSteps| * 2` factor), most mob controls |
| `log1p` | `Math.log1p(D)` | f64 | libm `log(1 + x)` accurate near 0; no exact IEEE replacement (`log(1+x)` loses precision). Single call: `SculkSpreader.updateCursors` (sculk spreading, specified in 29b part 6 and 31 part 8, not in 10/11/15/18). Out of scope here; the owning document must decide; exactness risk is last-bit only. | |
| `to_radians`, `next_up`, `copysign`, `inv_sqrt` | `Math.toRadians(D)`, `Math.nextUp(D)`, `Math.copySign(F,F)`, `Mth.invSqrt(D)` | f64 / f32 | `toRadians(x)` = `x * 0.017453292519943295` (double constant pi/180; (JDK) read from the JDK 21 `Math.java`, not the artifact); there is **no `toDegrees` call** in the enumerated classes. `nextUp` = C `nextafter(x, +inf)` (pairs with `next_down`); its only sites are the three in `AABB.nextDeflated` (no `MapItemSavedData` call exists), not in 10/11/15/18. `Mth.invSqrt(D)` calls `org.joml.Math.invsqrt` (a library outside the jar, so its definition is not available here; presumably `1.0 / sqrt(x)`, inferred); its two calls are in `GeodeFeature.place`, document 35. `copySign(a, b)` = magnitude of a with sign bit of b (used by `util.Interval`, not in scope). `toRadians` is used by `PositionMoveRotation.calculateAbsolute` (entity position/rotation, document 18 context). | |
| `fmod` | JVM `frem` / `drem` (Java `%`) | f32 / f64 | C `fmod`: result has the sign of the dividend and magnitude below the divisor; x % 0 and inf % y are NaN; x % inf is x; exact (no rounding), identical in every C library. For floats: widen, fmod in double, the result is exactly a float. | `Mth.wrapDegrees(F/D)` (divisor 360), `Mth.wrapDegrees90` (90), `Mth.positiveModulo(F/D)`, `Mth.triangleWave` |
| `min_j`, `max_j` | `Math.min/max(F/D)` | f32 / f64 | If either argument is NaN the result is NaN; -0.0 is smaller than +0.0 (min(-0.0, 0.0) = -0.0, max(-0.0, 0.0) = 0.0) (JDK). C `fmin`/`fmax` differ (they return the non-NaN argument). | `BinaryFunction$MinSampler`/`MaxSampler`, `CubicSpline$Multipoint.range`, `Mth.clamp`, `Mth.absMax`, `MaterialSystem` |
| `clamp_f32`, `clamp_f64` | `Mth.clamp(FFF)` / `(DDD)` | f32 / f64 | If `v < lo` return `lo`, otherwise return `min_j(v, hi)`. So a NaN `v` stays NaN (the comparison is false, then `min_j` propagates NaN), and if `lo > hi` the result is `lo` when `v < lo` and `hi` otherwise. | `ClampFunction`, `Blender`, `Aquifer$NoiseBasedAquifer.computeSurfaceLevel`, `Entity.setXRot` (uses `Math.clamp(FFF)`, JDK 21: throws if `lo > hi` or either is NaN) |
| `signum` | `Math.signum(F)` / `(D)` | f32 / f64 | -1.0, 0.0 or 1.0; zero and NaN are returned unchanged (including -0.0). | `UnaryFunction$SignSampler`, `Bat.customServerAiStep`, `Player.maybeBackOffFromEdge`, `AbstractArrow.onHitBlock`, `Fox$FoxPounceGoal.tick` |
| `nextdown` | `Math.nextDown(D)` | f64 | Largest double below x (C `nextafter(x, -inf)`). Six call sites in the enumerated classes: `GradientNoise` (the constant `HALF = nextDown(16777216.0)`, §3.1; the only one in scope of 10/11/15/18), three in `AABB.nextDeflated` and two in `Cushion.hasAnchorBelow` (bounding-box and entity placement code, not specified by 10/11/15/18). | `GradientNoise` static initialiser |
| `sqrt` | `Math.sqrt(D)`; `Mth.sqrt(F)` = widen, sqrt, narrow | f64 / f32 | Correctly rounded IEEE square root (any C `sqrt`); the float version narrows with `f32_round`, which equals the correctly rounded float sqrt (tested 0 mismatches). Negative gives NaN. `Mth.length(F..)` = `Mth.sqrt` of the float sum of squares; `Mth.length(D..)` = `Math.sqrt` of the double sum. | `NormalNoise`, `SimplexNoise`, `Vec3.length`/`distanceTo`/`normalize`, `Entity.distanceTo`, `Node.distanceTo`, `LocateCommand`, `CommandSourceStack.facing`, `MoveControl.tick`, many mob goals |
| `pow` | `Math.pow(D,D)` | f64 | libm `pow`. Terrain use is **exact** (powers of two, see below). Gameplay use (below) needs a correctly rounded or at least identical `pow`. | `NormalNoise.buildOctaves` (3 calls: `2^firstOctave`, `0.5^(-(n-1))`, `0.5^(-n)`, all integer exponents so every result is an exact power of two; `ldexp` is identical), `BlendedNoise.createFbm`/`computeFbmRange`, `PowFunction$*Sampler` (density node `pow`, unused by overworld data), `Player.getDestroySpeed` (`0.3^(level+1)` as double, then narrowed), `Entity.playAmethystStepSound` (`0.997^(ticks since last)`, narrowed), `ShufflingList$WeightedEntry.setRandom` (`-pow(random, 1/weight)`), `NoteBlock.getPitchFromNote` (`2^((note-12)/12)`, narrowed), `LevelBasedValue$Exponent.calculate`, `ScaleExponentially.process`, `Power` loot number providers, `NaturalSpawner` static lambda, `MaceItem` (`3.5` vs `pow(distance, 2.0)` compare), `EnderDragon.aiStep` (`pow(y, 2.0)` form), `Climate$RTree.bucketize` (below) |
| `log` | `Math.log(D)` | f64 | libm natural logarithm; log(0) = -inf, log(x<0) = NaN. | `UnaryFunction$LogSampler` (density node `log`: widen the float, `log`, narrow), `Climate$RTree.bucketize` (below), `MarsagliaPolarGaussian.nextGaussian`, `SpeleothemUtils.getSpeleothemHeight` (document 35), `SculkSpreader.updateCursors` (`log1p`) |
| `sin`, `cos` | `Math.sin(D)`, `Math.cos(D)` | f64 | libm. In the artifact used (a) to **build** the sine table (§16.3) and the `COS_TAB`/`ASIN_TAB` tables of `Mth.atan2` (§16.4); (b) directly by `OreFeature.place` for the blob axis (argument = a float expression widened with `f2d`); also `Ravager.stunEffect`, `PrimedTnt`, `Guardian$GuardianMoveControl.tick`, `LivingEntity.createItemStackToDrop`/`updateFallFlyingMovement`, `RandomLookAroundGoal.start`, `RandomPos.generateRandomDirectionWithinRadians`, `Fox$PerchAndSearchGoal.resetLook`, `LongJumpUtil`, `EndSpikeFeature`, `IcebergFeature`, `NoiseSpawnFinder` (the last four belong to other documents). | |
| `asin`, `acos` | `Math.asin(D)`, `Math.acos(D)` | f64 | libm. `asin` builds `ASIN_TAB`; also `Vec3.rotation`, `LivingEntity.applyItemBlocking`, `Fox$FoxPounceGoal.tick`, `Player.getRopeHoldPosition`, `DragonStrafePlayerPhase`, `DragonSittingScanningPhase`. | |
| `atan2_lib` | `Math.atan2(D,D)` | f64 | libm `atan2`. Only 9 call sites, none in terrain: `Vec3.rotation` (command rotation from a direction), `DolphinJumpGoal.tick`, `SulfurCube`, `NewMinecartBehavior`, `LongJumpUtil`. | |
| `atan2_mth` | `Mth.atan2(D,D)` | f64 | The custom routine of §16.4 (30+ call sites: look/move controls, `Entity.lookAt`, `Mob.lookAt`, `CommandSourceStack.facing`, `Projectile.shoot`/`updateRotation`, `AbstractArrow.tick`, `Rabbit.facePoint`, `Ghast.faceMovementDirection`, `ServerPlayer.indicateDamage`, `ServerPlayer$RespawnPosAngle.calculateLookAtYaw`). | |
| `sin_tab`, `cos_tab` | `Mth.sin(D)`, `Mth.cos(D)` return float | table | §16.3. 59 call sites in scope (view vectors, `LocalCoordinates.apply`, carvers, `OreFeature.doPlace`, knockback, jump, swim and flying movement, `Direction.orderedByNearest`). | |
| `f64_bits`, `f64_from_bits` | `Double.doubleToRawLongBits`, `longBitsToDouble` | f64 | Reinterpret the 64 bits; no NaN canonicalisation (raw). Used by `Mth.atan2`, `Mth.fastInvSqrt` (§16.4). | |
| `fast_inv_sqrt` | `Mth.fastInvSqrt(D)` | f64 | §16.4 formula. | `Mth.atan2`; `Beardifier` (document 36) |
| `lerp_f32`, `lerp_f64` | `Mth.lerp(FFF)` / `(DDD)` | f32 / f64 | `a + t * (b - a)` with the order: difference first, then times `t`, then add `a`; each step rounded (float for the float form, no FMA). The float form is not symmetric: `lerp(1, a, b)` may differ from `b` by an ulp. `lerp2`, `lerp3` nest `lerp`: x first, then y, then z (see 3.1). | `PerlinNoise`, `InterpolatedFunction`, `CubicSpline$Multipoint.sample`, `LerpFunction`, `Entity` interpolation, `OreFeature.doPlace` (double form), `Level.getRainLevel`/`getThunderLevel` |

These rows are the proposed `cc_f64_*` set: `f32_round`, `to_i32`, `to_i64`, `i32_to_f32`, `floor`, `ceil`, `round_f32`, `round_f64`, `abs_f32`, `abs_f64`, `log1p`, `to_radians`, `next_up`, `copysign`, `inv_sqrt`, `fmod`, `min_j`, `max_j`, `clamp_f32`, `clamp_f64`, `signum`, `nextdown`, `sqrt`, `pow`, `log`, `sin`, `cos`, `asin`, `acos`, `atan2_lib`, `atan2_mth`, `sin_tab`, `cos_tab`, `f64_bits`, `f64_from_bits`, `fast_inv_sqrt`, `lerp_f32`, `lerp_f64`. The last seven are built from the first ones and the three libm functions `sin`, `cos`, `asin`; an implementer may instead implement them in COBOL from IEEE operations, but then the tables must come from `sin`, `cos`, `asin` anyway (§16.7).

#### 16.2.1 Small `Mth` helpers (all exact compositions of the rows above; read from `Mth`)

Every helper is a fixed order of IEEE operations; the order matters for bit-exactness.

| Helper | Value (float helpers: each operation rounded to float) |
|---|---|
| `smoothstep(t)` (float) | `(t*t*t) * (t * (t*6 - 15) + 10)` evaluated as `t*t`, times `t`, then `t*6`, minus 15, times `t`, plus 10, then the product of the two parts |
| `smoothstepDerivative(t)` | `30 * t * t * (t - 1) * (t - 1)` evaluated left to right: `((((30*t)*t)*(t-1))*(t-1))` |
| `inverseLerp(v, a, b)` | `(v - a) / (b - a)` (float or double form) |
| `map(v, a, b, c, d)` | `lerp(inverseLerp(v, a, b), c, d)`; `clampedMap` uses `clampedLerp`, which returns `c` if the fraction is below 0, `d` if above 1, else `lerp` (NaN fraction falls through to `lerp`) |
| `square`, `cube` | `x*x`; `(x*x)*x` (float or double) |
| `wrapDegrees(float)` | `r = a fmod 360`; if `r >= 180` then `r - 360`; if `r < -180` then `r + 360` (float steps). `wrapDegrees(double)` likewise in double. `wrapDegrees90` uses 90, 45. |
| `wrapDegrees(long)` | `r = (float)(a % 360L)` (long remainder, truncating, then `l2f`), then the same steps: if `r >= 180` then `r - 360`; if `r < -180` then `r + 360` (float) |
| `wrapDegrees(int)` | `r = a % 360` (int remainder, truncating); if `r >= 180` then `r - 360`; if `r < -180` then `r + 360` (int); returns int |
| `degreesDifference(a, b)` | `wrapDegrees(b - a)`; `rotLerp(t, a, b) = a + t * wrapDegrees(b - a)`; `rotateIfNecessary(a, b, m) = b - clamp(degreesDifference(a, b), -m, m)` |
| `positiveModulo(float)` | `((a fmod b) + b) fmod b` (double: same) |
| `packDegrees(a)` | `to_i32(floor(f32(f32(a*256)/360)))` then Java `i2b` (keep the low 8 bits as a signed byte, wraps): 90 gives 64; -1 gives -1 (0xFF); 180 gives -128 (0x80); 359.9 gives -1. `unpackDegrees(b) = f32(f32(b*360) / 256)` with `b*360` an exact integer |
| `quantize(v, n)` | `to_i32(floor(v / n)) * n` (int multiply, wraps) |
| `length`, `lengthSquared` | sums in the order x, y, z; float forms in float, double forms in double |
| `nextDouble(r, a, b)` | `a` if `a >= b`, else `r.nextDouble() * (b - a) + a` (multiply then add; no FMA) |
| `randomBetween(r, a, b)` (float) | `r.nextFloat() * (b - a) + a` in float |
| `sign(double)` | 0 if `x == 0` (including -0.0), 1 if `x > 0`, else -1 (NaN is neither, so it gives -1) |
| `lerpInt(t, a, b)` | `a + floor(f32(t * (float)(b - a)))` (int add) |
| `getSeed(x, y, z)` | integer only; see §2.4 |
| other helpers | Not used by 10/11/15/18 by method; owners: `frac(D)` (`BlockGetter.traverseBlocks`/`addCollisionsAlongTravel`, `TargetBlock.getRedstoneStrength`) and `frac(F)` (`AbstractFurnaceBlockEntity.createExperience`): block/furnace documents; `approach`, `approachDegrees`, `degreesDifferenceAbs` (`Phantom$PhantomMoveControl.tick`, `SignBlockEntity.getSlotPlayerIsFacing`): mob and sign documents; `normal` (`ClampedNormalFloat/Int.sample`): value providers; `lerpDiscrete` (`AbstractContainerMenu.getRedstoneSignalFromContainer`): menus; `positiveModulo(DD)` (`Blender.heightToOffset`, world blending, not specified here); `positiveModulo(II)` is `floorMod`. Definitions read from `Mth`: `frac(x) = x - floor(x)` (double form uses the long floor then `l2d`); `approach(a, b, d)`: with `d = abs(d)`, if `a < b` then `clamp(a + d, a, b)` else `clamp(a - d, b, a)`; `approachDegrees(a, b, d) = approach(a, a + degreesDifference(a, b), d)`; `degreesDifferenceAbs = abs(degreesDifference)`; `normal(r, mean, sd) = mean + (float) r.nextGaussian() * sd`; `lerpDiscrete(t, a, b) = a + floor(t * (float)(b - a - 1)) + (t > 0 ? 1 : 0)`. |

### 16.3 `Mth.sin` and `Mth.cos` (lookup table)

Read from `Mth.sin`, `Mth.cos` and the table initialiser `Mth.lambda$static$0`.

- Table `SIN` has 65536 float entries: `SIN[i] = (float) Math.sin(i / 10430.378350470453)` (division in double, `Math.sin` in double, narrowed).
- `sin(x) = SIN[ to_i64(x * 10430.378350470453) AND 65535 ]`; `cos(x) = SIN[ to_i64(x * 10430.378350470453 + 16384.0) AND 65535 ]`. `x` is a double (callers widen a float; the float product `angle * 0.017453292f` is computed in float first, then widened). The multiplication and the addition are separate double operations (no FMA). The `AND` is on the two's-complement 64-bit value, so negative arguments index from the top: `sin(-1.0)` uses index 55106, giving the negated value of `sin(1.0)`.
- Argument handling: `to_i64` saturates and maps NaN to 0, so NaN gives `SIN[0] = 0.0`, and an argument of magnitude beyond about 8.8e14 saturates at 9223372036854775807, giving index 65535.
- Result is a float. Resolution is 2*pi/65536 = about 9.59e-5 rad, so the table is a coarse approximation of sine; callers get quantised angles.
- The class constants: `PI = 3.1415927f`, `HALF_PI = 1.5707964f`, `TWO_PI = 6.2831855f`, `DEG_TO_RAD = 0.017453292f` (0x3C8EFA35), `RAD_TO_DEG = 57.295776f` (widened exactly to the double 57.2957763671875, which is the literal the callers use).
- Table check value: the SHA-256 of the 65536 entries written as big-endian IEEE floats (index 0 first) computed with the scratch machine's libm is `87a67a39fff59636acb04edcda4ef622831037291f11fb61586c57596771dac2`. Reproduce the table and compare this hash. The same hash resulted from correctly rounded sine (50-digit decimal evaluation): of 65536 entries, 0 differ as floats between the system `sin` and the exactly rounded value, although 2527 of the intermediate doubles differ in the last bit. So any `sin` accurate to under 1 double ulp gives this table (the float narrowing hides the difference).

### 16.4 `Mth.atan2` (custom approximation, read from `Mth.atan2`, `Mth.fastInvSqrt`, static initialiser)

Constants: `FRAC_BIAS = longBitsToDouble(4805340802404319232)` = 2^44 = 17592186044416.0 (0x42B0000000000000). Tables (257 doubles each, built in the static initialiser): `ASIN_TAB[i] = Math.asin(i / 256.0)`, `COS_TAB[i] = Math.cos(ASIN_TAB[i])`, `i = 0..256`.

`fastInvSqrt(x)`: `h = 0.5 * x`; `bits = doubleToRawLongBits(x)`; `bits = 6910469410427058090 - (bits >> 1)` (arithmetic shift, 64-bit); `y = longBitsToDouble(bits)`; result `y * (1.5 - h * y * y)` evaluated as `1.5 - ((h * y) * y)`. One Newton step only, so the result has a relative error up to about 0.2 percent (it is **not** `1/sqrt(x)`).

`atan2(y, x)` (arguments in the order y, x):
1. `d = x*x + y*y`. If `d` is NaN return NaN.
2. `ny = (y < 0)`; if `ny`, `y = -y`. `nx = (x < 0)`; if `nx`, `x = -x`. `sw = (y > x)`; if `sw`, swap `x` and `y`. (-0.0 is not less than 0, so negative zero is treated as positive.)
3. `inv = fastInvSqrt(d)`; `x = x * inv`; `y = y * inv`.
4. `t = FRAC_BIAS + y`; `idx = low 32 bits of doubleToRawLongBits(t)` as a signed int (this equals `y` times 256 rounded to the nearest integer, because the ulp of 2^44 is 1/256; after the swap `y <= x`, so `y` is about 0.7071 at most and `idx` is at most about 181, inside the 257-entry tables); `a = ASIN_TAB[idx]`; `c = COS_TAB[idx]`; `b = t - FRAC_BIAS` (exactly `idx / 256`).
5. `e = y * c - x * b`; `p = (6.0 + e*e) * e * 0.16666666666666666` evaluated as `(((6.0 + (e*e)) * e) * 0.16666666666666666)`; `r = a + p`.
6. If `sw`: `r = 1.5707963267948966 - r`. If `nx`: `r = 3.141592653589793 - r`. If `ny`: `r = -r`.

Edge cases: `atan2(0, 0)` returns 0 (the inverse square root of 0 is a huge finite number and `0 * huge = 0`); `atan2(0, -1) = pi`; infinite arguments give `d = inf`, `inv = 0` (bit trick on infinity), then `x*0` and `y*0`: infinity times 0 is NaN, so the result is NaN (inferred from the arithmetic; not executed).

Accuracy: against libm `atan2`, the difference was 2.7e-8 at (1, 1), 4.5e-6 at (3, -4) and up to 7.8e-6 over 200000 random inputs in [-100, 100]. An implementation using libm `atan2` instead would drift from vanilla angles by that much; the routine above must be used.

Callers apply it as follows (all read): `Mth.atan2(dz, dx) * 57.2957763671875`, narrowed to float, minus `90.0f` for yaw (`LookControl.getYRotD`, `CommandSourceStack.facing`); pitch is `-(Mth.atan2(dy, horizontalDistance) * 57.2957763671875)` narrowed to float (`LookControl.getXRotD`, `facing`); `facing` then applies `Mth.wrapDegrees(float)` to both. `Vec3.rotation` (used for command rotations from vectors) instead uses libm `Math.atan2` and `Math.asin`, narrowed to float and multiplied by `57.295776f` in float.

### 16.5 Casts, narrowing and widening: rules for every site

| Operation | Rule |
|---|---|
| `(float) double` | `f32_round` (nearest, ties to even; overflow to infinity) |
| `(double) float` | exact |
| `(int) double`, `(int) float` | `to_i32`: truncate toward zero, saturate, NaN gives 0 |
| `(long) double` | `to_i64` |
| `(byte) int` | keep low 8 bits, signed |
| `(float) int`, `(float) long` | nearest float, ties to even |
| `Mth.floor(float)` | widen, `floor`, `to_i32` |
| float `%` | `fmod` |
| int `%`, `/` | not libm (truncate toward zero); `Math.floorDiv`/`floorMod` (int/long) round toward negative infinity and the result of `floorMod` has the sign of the divisor |
| integer overflow | Java wraps (two's complement) for `+ - *` on int/long; `Math.abs(int)` of -2147483648 stays -2147483648; `Math.absExact`/`subtractExact`/`toIntExact`/`powExact` throw (see loot number providers and `TimeCommand.wrapTime`) |

`Climate.quantizeCoord(f) = to_i64(f32(f * 10000.0f))` (float product, then `f2l`): for the float 0.3 (0x3E99999A) the product is 3000.0000 and the result 3000.

### 16.6 Call sites by document (what each document needs)

- **10 (terrain).** `GradientNoise.wrap` (`floor`, `nextdown` constant, divisions by 33554432.0); `PerlinNoise.get`/`sampleAndLerp`, `SmearedPerlinNoise` (`to_i32`/`floor`, `f32_round` on `x - floor(x)`, `smoothstep`, `lerp3` of floats); `SimplexNoise.get` (`sqrt`, `floor`); `NormalNoise` (`pow` exact, `sqrt`, `Mth.square`, `Math.abs`); `BlendedNoise` (`pow`); density nodes `abs`, `square`, `cube`, `sqrt`, `log`, `sign`, `squeeze` (`clamp`, `cube`), `round` (types floor, round, ceiling, truncate-toward-zero: `RoundFunction$Type` ordinals 0..3: 0 gives `f32(floor(x))`, 1 gives the float of `round_f32(x)`, 2 gives `f32(ceil(x))`, 3 gives floor for positive and ceiling for non-positive), `pow` (`pow` of widened floats, narrowed), `lerp`, `clamp`, `min`, `max`, `interpolated` (`lerp`, `lerp3`), spline (`Mth.lerp(FFF)`; the `findIntervalStart` search is pure comparison); `Climate.quantizeCoord`, `ParameterPoint.fitness` (long `Mth.square`); `RTree.bucketize` (below); `BiomeManager.getFiddle` (`floorMod(long, int)`, int to double, divide by 1024.0, minus 0.5, times 0.9) and `getFiddledDistance` (`Mth.square(double)`); `Aquifer` (`Mth.map`, `clampedMap`, `quantize`, `floorDiv`, `abs`, NaN test); `MaterialSystem` (`getBand` `round_f32`; `erodedBadlandsExtension`: `abs`, `min` (double), `ceil`, `floor`; `frozenOceanExtension`: `abs`, `ceil`, `min`, `max`); `StoneDepthCondition`/`VerticalGradientCondition` (`Mth.map` double). §3.3 line "`Math.pow`/`Math.sqrt` is IEEE double" is confirmed (Open question 10 below).
  - `RTree.bucketize(list, b)` (tree construction only, `b` = per-node child limit passed down; its value was not traced here): the bucket size is `to_i32( pow(b, floor( log(n - 0.01) / log(b) )) )` with `n` the list size. For integer `n >= 2` this equals the largest power of `b` strictly below `n` (checked for base 6 and `n` in 2..99999: 0 mismatches against an exact integer rule), so an implementation can use integers and avoid `log`/`pow` here.
- **11 (caves and ores).** `Mth.sin`/`Mth.cos` (carvers: `CaveWorldCarver.createTunnel`/`createRoom`, `CanyonWorldCarver.doCarve`: float arguments widened; the room uses `Mth.sin(1.5707963705062866)` = `sin_tab` of the widened `HALF_PI`, giving `1.5 + sin(...) * ...`); `WorldCarver.carveEllipsoid` (`Mth.floor(D)`, `Math.abs(D)`, int min/max, `+ 0.5` offsets); `OreFeature.place` (float `PI` times a float, `Mth.ceil(F)`, then `Math.sin`/`Math.cos` on a float widened with `f2d` times a float widened), `OreFeature.doPlace` (`Mth.lerp(DDD)`, `Mth.sin(D)` for the radius, `Mth.floor(D)`), `Block.popResource` (`Mth.nextDouble`).
- **15 (commands).** `LocalCoordinates.apply` (`Mth.cos`/`Mth.sin` of `f32(f32(yaw + 90.0f) * 0.017453292f)` and of `f32(-pitch * 0.017453292f)` widened; the vectors are combined in double: mixed float/double rounding matters), `CommandSourceStack.facing` (above), `Vec3.rotation` (libm), `TimeArgument.parse` (`round_f32(readFloat * (float) unitTicks)`; a trailing unit multiplies in float), `EntitySelectorParser.createRotationPredicate` and `AngleArgument$SingleAngle.getAngle`, `TeleportCommand.performTeleport`, `SetSpawnCommand` (`wrapDegrees`, `clamp`), `DataCommands.getNumeric`/`getData` and `ExecuteCommand` store (`Mth.floor(D)` of a double product with the scale), `ExperienceCommand`, `LocateCommand` (`Mth.sqrt(F)`, `Mth.floor(F)`), `PlaySoundCommand` (`Math.sqrt`), `SpreadPlayersCommand` (`Math.sqrt`, `Mth.floor(D)`, `randomize` with `Mth.nextDouble`), `WorldBorderCommand` (`Mth.floor`, `Math.abs(F)`), `ScheduleCommand`/`TimeCommand` (long `floorMod`, `toIntExact`), `OperationArgument` (integer `floorDiv`, `positiveModulo`).
- **18 (mobs).** All of the controls and goals use only: `sin_tab`/`cos_tab`, `atan2_mth`, `wrapDegrees`, `rotLerp`, `rotateIfNecessary`, `lerp`, `sqrt`, `abs`, `min`/`max`, `to_i32` (floor/ceil), `round_f32` (damage, armour absorb, statistics) and `packDegrees`/`unpackDegrees` (`ServerEntity.sendChanges`, add-entity packets). Libm `sin`/`cos`/`acos`/`atan2_lib`/`pow`/`signum` appear in: `Guardian$GuardianMoveControl.tick` (`Math.sin`/`cos`), `LivingEntity.updateFallFlyingMovement` and `createItemStackToDrop` (`Math.sin`/`cos`), `LivingEntity.applyItemBlocking` (`acos`), `Fox$FoxPounceGoal.tick` (`acos`, `signum`), `DolphinJumpGoal.tick` (`atan2_lib`), `RandomLookAroundGoal.start`, `RandomPos.generateRandomDirectionWithinRadians`, `Bat.customServerAiStep` (`signum`), `Player.getRopeHoldPosition` (`acos`), `Player.maybeBackOffFromEdge` (`signum`), `AbstractArrow.onHitBlock` (`signum`); `pow` rows above (destroy speed with Mining Fatigue, amethyst chime volume decay, enchantment exponents, shuffling weights). A frequently used literal: `57.2957763671875` (the double value of the float `RAD_TO_DEG`).

### 16.7 Can the artifact's arithmetic be reproduced with plain IEEE-754 double operations?

Yes, for everything except the following, which need a libm-quality implementation of the named function:

1. `sin` (table build, 65536 evaluations, narrowed to float): any implementation within 1 ulp of correct gives the identical table (measured: 0 float differences against exactly rounded values on the scratch machine). Safe.
2. `asin`/`cos` at 257 points (`ASIN_TAB`, `COS_TAB`): the tables are doubles and are used at full precision. On the scratch machine's libm, 21 of the 257 `asin` entries and 9 of the 257 `cos` entries differ from the correctly rounded value in the last bit. The effect on `atan2_mth` is at most about 1e-16 radian and almost never changes the float after the final narrowing, but bit-exact doubles cannot be promised (Open question 16.8-1).
3. `Math.sin`/`Math.cos`/`Math.asin`/`Math.acos`/`Math.atan2`/`Math.pow` (non-power-of-two)/`Math.log` calls in gameplay (listed in §16.2): bit-exactness relies on the same libm results as the JVM that produced the reference (last-bit differences between JVM and C libm implementations: recalled, not verified; Open question 16.9-1). Narrowing to float (most call sites narrow) hides last-bit differences except very rarely.
4. `Math.log` in `bucketize` and `Math.pow` in `NormalNoise`/`BlendedNoise`: replaceable by exact integer or power-of-two operations (verified above).

Everything else (float arithmetic, casts, `floor`, `ceil`, `round_f32`/`round_f64`, `fmod`, `sqrt`, `min`/`max`, `clamp`, `lerp`, `smoothstep`, `signum`, `nextdown`, the sine table lookup, the arctangent routine, bit reinterpretation) is reproduced exactly by IEEE double operations plus the rules of §16.2 and §16.5. The C wrappers must be compiled without floating-point contraction (no FMA fusion) and without fast-math.

### 16.8 Worked examples (computed with a scratch script; hex is IEEE bit patterns)

| Function | Input (bits) | Result (bits) |
|---|---|---|
| `sin_tab` | 1.0 (0x3FF0000000000000): index `to_i64(10430.378...) = 10430` | float 0x3F57695C |
| `sin_tab` | -1.0 (0xBFF0000000000000): index 55106 | float 0xBF57695C |
| `cos_tab` | 0.0: index 16384 | float 0x3F800000 (1.0) |
| `cos_tab` | float `pi/3` (0x3F860A92) widened: index 27306 | float 0x3F0003A1 |
| `cos_tab` arg | yaw 30.0f in `LocalCoordinates`: `f32(f32(30+90) * 0x3C8EFA35)` = 0x40060A92 (as float), index 38229 | table entry 38229 |
| `f32_round` | 0.1 (0x3FB999999999999A) | 0x3DCCCCCD (widened back 0x3FB99999A0000000) |
| `f32_round` | 1e40 | 0x7F800000 (+infinity) |
| `to_i32` | 3e10 / -3e10 / NaN / -2.5 floor | 2147483647 / -2147483648 / 0 / -3 |
| `round_f32` | 0x3EFFFFFF (0.49999997) | 0 (naive float `x + 0.5` then floor gives 1: wrong) |
| `round_f32` | 2.5, -2.5, -0.5 | 3, -2, 0 |
| `wrapDegrees` (float) | 190.0 (0x43390000) / -190.0 / 540.0 / 180.0 / -10.0 | 0xC32A0000 (-170.0) / 170.0 / -180.0 / -180.0 / -10.0 |
| `packDegrees` | 90 / -1 / 180 / 359.9 / -90 | 64 / -1 / -128 / -1 / -64 |
| `lerp_f32` | t = 0x3E99999A (0.3), a = 0x3DCCCCCD (0.1), b = 0x3F333333 (0.7) | 0x3E8F5C29 |
| `smoothstep` | 0x3E99999A | 0x3E26FE73 |
| `atan2_mth` | (y, x) = (1.0, 1.0) | 0x3FE921FB45E6D12F (libm gives 0x3FE921FB54442D18) |
| `atan2_mth` | (3.0, -4.0) | 0x4003FC19CD3C7E4C (libm 0x4003FC176B7A8560) |
| `atan2_mth` | (-2.0, 0.5) | 0xBFF5368CCF5A6268 (libm 0xBFF5368C951E9CFD) |
| `atan2_mth` | (0.0, -1.0) / (0.0, 0.0) | 0x400921FB54442D18 (pi) / 0.0 |
| `sin` (libm) | 0.5 | 0x3FDEAEE8744B05F0 (`cos` 0.5: 0x3FEC1528065B7D50) |
| `pow` | `pow(2, -9)` | exactly 2^-9 (0x3F60000000000000) |
| `quantizeCoord` | 0.3f times 10000.0f | 3000 |

The `atan2_mth` values depend on the `asin`/`cos` table entries of the scratch machine's libm; only the leading 15 digits are reliable until tested against the artifact's own library.

### 16.9 Open questions for this section

1. **Which `sin`/`cos`/`asin`/`pow`/`log` the reference JVM computes.** The artifact calls `Math.*`, never `StrictMath`. In the JDK 21 source `Math.sin` delegates to `StrictMath.sin` (read), but whether the HotSpot virtual machine of the reference replaces `Math.sin`, `Math.cos`, `Math.pow`, `Math.log` by processor-specific intrinsics with different last-bit behaviour was not read (recalled, not verified). The 257-entry `ASIN_TAB`/`COS_TAB` could therefore differ in the last bit from this document's tables; this would move `atan2_mth` only at the 1e-16 level.
2. **`bucketize` child limit.** The base `b` passed to `bucketize` (the R-tree's per-node child count) was not traced; it affects only tie-breaking among equal-fitness biome points (§7.3).
3. **Out-of-scope call sites seen but not specified:** `Beardifier`, `IcebergFeature`, `SpeleothemUtils`, `FancyTrunkPlacer`, `EndSpikeFeature`, `ChunkGeneratorStructureState.generateRingPositions` (stronghold rings), `NoiseSpawnFinder`, `LegacyFbmInitializer`, `NoiseUtils.biasTowardsExtreme`, `MarsagliaPolarGaussian`. They use `sin`, `cos`, `pow`, `log`, `Math.round(D)` from the same set above, and belong to documents 35, 36, 37, 38.
4. **Infinite and NaN inputs to `atan2_mth`** were derived from the arithmetic, not read from a result.

---

## Appendix A. Spline trees

Each tree is the `spline` of the named function. Points are listed as `at <location> (slope <derivative>)`; an indented tree follows when the value is a nested spline, else `-> value`. `SPLINE on X` names the coordinate function: `continents`, `erosion`, `ridges`, `ridges_folded` of §6.1. Locations are floats; values are shown with the shortest decimal that round-trips the stored float.

### A.1 `overworld/offset`  (value = -0.50375 + this spline)

```
first (blend branch) = {"type": "minecraft:blend_offset"}; alpha = blend_alpha
second = add(constant -0.50375, spline)
SPLINE on continents:
  at -1.1 (slope 0.0) -> 0.044
  at -1.02 (slope 0.0) -> -0.2222
  at -0.51 (slope 0.0) -> -0.2222
  at -0.44 (slope 0.0) -> -0.12
  at -0.18 (slope 0.0) -> -0.12
  at -0.16 (slope 0.0):
    SPLINE on erosion:
      at -0.85 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.38940096) -> -0.08880186
          at 1.0 (slope 0.38940096) -> 0.69000006
      at -0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.37788022) -> -0.115760356
          at 1.0 (slope 0.37788022) -> 0.6400001
      at -0.4 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.2222
          at -0.75 (slope 0.0) -> -0.2222
          at -0.65 (slope 0.0) -> 0.0
          at 0.5954547 (slope 0.0) -> 2.9802322e-08
          at 0.6054547 (slope 0.2534563) -> 2.9802322e-08
          at 1.0 (slope 0.2534563) -> 0.100000024
      at -0.35 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.3
          at -0.4 (slope 0.0) -> 0.05
          at 0.0 (slope 0.0) -> 0.05
          at 0.4 (slope 0.0) -> 0.05
          at 1.0 (slope 0.007000001) -> 0.060000002
      at -0.1 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.15
          at -0.4 (slope 0.0) -> 0.0
          at 0.0 (slope 0.0) -> 0.0
          at 0.4 (slope 0.1) -> 0.05
          at 1.0 (slope 0.007000001) -> 0.060000002
      at 0.2 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.15
          at -0.4 (slope 0.0) -> 0.0
          at 0.0 (slope 0.0) -> 0.0
          at 0.4 (slope 0.0) -> 0.0
          at 1.0 (slope 0.0) -> 0.0
      at 0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.02
          at -0.4 (slope 0.0) -> -0.03
          at 0.0 (slope 0.0) -> -0.03
          at 0.4 (slope 0.06) -> 0.0
          at 1.0 (slope 0.0) -> 0.0
  at -0.15 (slope 0.0):
    SPLINE on erosion:
      at -0.85 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.38940096) -> -0.08880186
          at 1.0 (slope 0.38940096) -> 0.69000006
      at -0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.37788022) -> -0.115760356
          at 1.0 (slope 0.37788022) -> 0.6400001
      at -0.4 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.2222
          at -0.75 (slope 0.0) -> -0.2222
          at -0.65 (slope 0.0) -> 0.0
          at 0.5954547 (slope 0.0) -> 2.9802322e-08
          at 0.6054547 (slope 0.2534563) -> 2.9802322e-08
          at 1.0 (slope 0.2534563) -> 0.100000024
      at -0.35 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.3
          at -0.4 (slope 0.0) -> 0.05
          at 0.0 (slope 0.0) -> 0.05
          at 0.4 (slope 0.0) -> 0.05
          at 1.0 (slope 0.007000001) -> 0.060000002
      at -0.1 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.15
          at -0.4 (slope 0.0) -> 0.0
          at 0.0 (slope 0.0) -> 0.0
          at 0.4 (slope 0.1) -> 0.05
          at 1.0 (slope 0.007000001) -> 0.060000002
      at 0.2 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.15
          at -0.4 (slope 0.0) -> 0.0
          at 0.0 (slope 0.0) -> 0.0
          at 0.4 (slope 0.0) -> 0.0
          at 1.0 (slope 0.0) -> 0.0
      at 0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.02
          at -0.4 (slope 0.0) -> -0.03
          at 0.0 (slope 0.0) -> -0.03
          at 0.4 (slope 0.06) -> 0.0
          at 1.0 (slope 0.0) -> 0.0
  at -0.1 (slope 0.0):
    SPLINE on erosion:
      at -0.85 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.38940096) -> -0.08880186
          at 1.0 (slope 0.38940096) -> 0.69000006
      at -0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.37788022) -> -0.115760356
          at 1.0 (slope 0.37788022) -> 0.6400001
      at -0.4 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.2222
          at -0.75 (slope 0.0) -> -0.2222
          at -0.65 (slope 0.0) -> 0.0
          at 0.5954547 (slope 0.0) -> 2.9802322e-08
          at 0.6054547 (slope 0.2534563) -> 2.9802322e-08
          at 1.0 (slope 0.2534563) -> 0.100000024
      at -0.35 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.25
          at -0.4 (slope 0.0) -> 0.05
          at 0.0 (slope 0.0) -> 0.05
          at 0.4 (slope 0.0) -> 0.05
          at 1.0 (slope 0.007000001) -> 0.060000002
      at -0.1 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.1
          at -0.4 (slope 0.01) -> 0.001
          at 0.0 (slope 0.01) -> 0.003
          at 0.4 (slope 0.094000004) -> 0.05
          at 1.0 (slope 0.007000001) -> 0.060000002
      at 0.2 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.1
          at -0.4 (slope 0.0) -> 0.01
          at 0.0 (slope 0.0) -> 0.01
          at 0.4 (slope 0.04) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
      at 0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.02
          at -0.4 (slope 0.0) -> -0.03
          at 0.0 (slope 0.0) -> -0.03
          at 0.4 (slope 0.12) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
  at 0.25 (slope 0.0):
    SPLINE on erosion:
      at -0.85 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> 0.20235021
          at 0.0 (slope 0.5138249) -> 0.7161751
          at 1.0 (slope 0.5138249) -> 1.23
      at -0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> 0.2
          at 0.0 (slope 0.43317974) -> 0.44682026
          at 1.0 (slope 0.43317974) -> 0.88
      at -0.4 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> 0.2
          at 0.0 (slope 0.3917051) -> 0.30829495
          at 1.0 (slope 0.3917051) -> 0.70000005
      at -0.35 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.25
          at -0.4 (slope 0.0) -> 0.35
          at 0.0 (slope 0.0) -> 0.35
          at 0.4 (slope 0.0) -> 0.35
          at 1.0 (slope 0.049000014) -> 0.42000002
      at -0.1 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.1
          at -0.4 (slope 0.07) -> 0.0069999998
          at 0.0 (slope 0.07) -> 0.021
          at 0.4 (slope 0.658) -> 0.35
          at 1.0 (slope 0.049000014) -> 0.42000002
      at 0.2 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.1
          at -0.4 (slope 0.0) -> 0.01
          at 0.0 (slope 0.0) -> 0.01
          at 0.4 (slope 0.04) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
      at 0.4 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.1
          at -0.4 (slope 0.0) -> 0.01
          at 0.0 (slope 0.0) -> 0.01
          at 0.4 (slope 0.04) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.1
          at -0.4 (slope 0.0):
            SPLINE on ridges_folded:
              at -1.0 (slope 0.5) -> -0.1
              at -0.4 (slope 0.0) -> 0.01
              at 0.0 (slope 0.0) -> 0.01
              at 0.4 (slope 0.04) -> 0.03
              at 1.0 (slope 0.049) -> 0.1
          at 0.0 (slope 0.0) -> 0.17
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.1
          at -0.4 (slope 0.0):
            SPLINE on ridges_folded:
              at -1.0 (slope 0.5) -> -0.1
              at -0.4 (slope 0.0) -> 0.01
              at 0.0 (slope 0.0) -> 0.01
              at 0.4 (slope 0.04) -> 0.03
              at 1.0 (slope 0.049) -> 0.1
          at 0.0 (slope 0.0) -> 0.17
      at 0.58 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.1
          at -0.4 (slope 0.0) -> 0.01
          at 0.0 (slope 0.0) -> 0.01
          at 0.4 (slope 0.04) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
      at 0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.02
          at -0.4 (slope 0.0) -> -0.03
          at 0.0 (slope 0.0) -> -0.03
          at 0.4 (slope 0.12) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
  at 1.0 (slope 0.0):
    SPLINE on erosion:
      at -0.85 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> 0.34792626
          at 0.0 (slope 0.5760369) -> 0.9239631
          at 1.0 (slope 0.5760369) -> 1.5
      at -0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> 0.2
          at 0.0 (slope 0.4608295) -> 0.5391705
          at 1.0 (slope 0.4608295) -> 1.0
      at -0.4 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> 0.2
          at 0.0 (slope 0.4608295) -> 0.5391705
          at 1.0 (slope 0.4608295) -> 1.0
      at -0.35 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.2
          at -0.4 (slope 0.0) -> 0.5
          at 0.0 (slope 0.0) -> 0.5
          at 0.4 (slope 0.0) -> 0.5
          at 1.0 (slope 0.070000015) -> 0.6
      at -0.1 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.05
          at -0.4 (slope 0.099999994) -> 0.01
          at 0.0 (slope 0.099999994) -> 0.03
          at 0.4 (slope 0.94) -> 0.5
          at 1.0 (slope 0.070000015) -> 0.6
      at 0.2 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.05
          at -0.4 (slope 0.0) -> 0.01
          at 0.0 (slope 0.0) -> 0.01
          at 0.4 (slope 0.04) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
      at 0.4 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.05
          at -0.4 (slope 0.0) -> 0.01
          at 0.0 (slope 0.0) -> 0.01
          at 0.4 (slope 0.04) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.05
          at -0.4 (slope 0.0):
            SPLINE on ridges_folded:
              at -1.0 (slope 0.5) -> -0.05
              at -0.4 (slope 0.0) -> 0.01
              at 0.0 (slope 0.0) -> 0.01
              at 0.4 (slope 0.04) -> 0.03
              at 1.0 (slope 0.049) -> 0.1
          at 0.0 (slope 0.0) -> 0.17
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.0) -> -0.05
          at -0.4 (slope 0.0):
            SPLINE on ridges_folded:
              at -1.0 (slope 0.5) -> -0.05
              at -0.4 (slope 0.0) -> 0.01
              at 0.0 (slope 0.0) -> 0.01
              at 0.4 (slope 0.04) -> 0.03
              at 1.0 (slope 0.049) -> 0.1
          at 0.0 (slope 0.0) -> 0.17
      at 0.58 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.5) -> -0.05
          at -0.4 (slope 0.0) -> 0.01
          at 0.0 (slope 0.0) -> 0.01
          at 0.4 (slope 0.04) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
      at 0.7 (slope 0.0):
        SPLINE on ridges_folded:
          at -1.0 (slope 0.015) -> -0.02
          at -0.4 (slope 0.0) -> 0.01
          at 0.0 (slope 0.0) -> 0.01
          at 0.4 (slope 0.04) -> 0.03
          at 1.0 (slope 0.049) -> 0.1
```

### A.2 `overworld/factor`

```
first (blend branch) = 10.0; alpha = blend_alpha
second = spline
SPLINE on continents:
  at -0.19 (slope 0.0) -> 3.95
  at -0.15 (slope 0.0):
    SPLINE on erosion:
      at -0.6 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 6.25
      at -0.5 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 6.3
          at 0.05 (slope 0.0) -> 2.67
      at -0.35 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 6.25
      at -0.25 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 6.25
      at -0.1 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 2.67
          at 0.05 (slope 0.0) -> 6.3
      at 0.03 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 6.25
      at 0.35 (slope 0.0) -> 6.25
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 6.25
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 6.25
              at 0.1 (slope 0.0) -> 0.625
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 6.25
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 6.25
              at 0.1 (slope 0.0) -> 0.625
      at 0.62 (slope 0.0) -> 6.25
  at -0.1 (slope 0.0):
    SPLINE on erosion:
      at -0.6 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 5.47
      at -0.5 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 6.3
          at 0.05 (slope 0.0) -> 2.67
      at -0.35 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 5.47
      at -0.25 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 5.47
      at -0.1 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 2.67
          at 0.05 (slope 0.0) -> 6.3
      at 0.03 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 5.47
      at 0.35 (slope 0.0) -> 5.47
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 5.47
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 5.47
              at 0.1 (slope 0.0) -> 0.625
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 5.47
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 5.47
              at 0.1 (slope 0.0) -> 0.625
      at 0.62 (slope 0.0) -> 5.47
  at 0.03 (slope 0.0):
    SPLINE on erosion:
      at -0.6 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 5.08
      at -0.5 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 6.3
          at 0.05 (slope 0.0) -> 2.67
      at -0.35 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 5.08
      at -0.25 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 5.08
      at -0.1 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 2.67
          at 0.05 (slope 0.0) -> 6.3
      at 0.03 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 5.08
      at 0.35 (slope 0.0) -> 5.08
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 5.08
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 5.08
              at 0.1 (slope 0.0) -> 0.625
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 5.08
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 5.08
              at 0.1 (slope 0.0) -> 0.625
      at 0.62 (slope 0.0) -> 5.08
  at 0.06 (slope 0.0):
    SPLINE on erosion:
      at -0.6 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 4.69
      at -0.5 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 6.3
          at 0.05 (slope 0.0) -> 2.67
      at -0.35 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 4.69
      at -0.25 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 4.69
      at -0.1 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 2.67
          at 0.05 (slope 0.0) -> 6.3
      at 0.03 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 4.69
      at 0.05 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.45 (slope 0.0):
            SPLINE on ridges:
              at -0.2 (slope 0.0) -> 6.3
              at 0.2 (slope 0.0) -> 4.69
          at 0.7 (slope 0.0) -> 1.56
      at 0.4 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.45 (slope 0.0):
            SPLINE on ridges:
              at -0.2 (slope 0.0) -> 6.3
              at 0.2 (slope 0.0) -> 4.69
          at 0.7 (slope 0.0) -> 1.56
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.7 (slope 0.0):
            SPLINE on ridges:
              at -0.2 (slope 0.0) -> 6.3
              at 0.2 (slope 0.0) -> 4.69
          at -0.15 (slope 0.0) -> 1.37
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.7 (slope 0.0):
            SPLINE on ridges:
              at -0.2 (slope 0.0) -> 6.3
              at 0.2 (slope 0.0) -> 4.69
          at -0.15 (slope 0.0) -> 1.37
      at 0.58 (slope 0.0) -> 4.69
```

### A.3 `overworld/jaggedness`

```
first (blend branch) = 0.0; alpha = blend_alpha
second = spline
SPLINE on continents:
  at -0.11 (slope 0.0) -> 0.0
  at 0.03 (slope 0.0):
    SPLINE on erosion:
      at -1.0 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.19999999 (slope 0.0) -> 0.0
          at 0.44999996 (slope 0.0) -> 0.0
          at 1.0 (slope 0.0):
            SPLINE on ridges:
              at -0.01 (slope 0.0) -> 0.63
              at 0.01 (slope 0.0) -> 0.3
      at -0.78 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.19999999 (slope 0.0) -> 0.0
          at 0.44999996 (slope 0.0) -> 0.0
          at 1.0 (slope 0.0):
            SPLINE on ridges:
              at -0.01 (slope 0.0) -> 0.315
              at 0.01 (slope 0.0) -> 0.15
      at -0.5775 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.19999999 (slope 0.0) -> 0.0
          at 0.44999996 (slope 0.0) -> 0.0
          at 1.0 (slope 0.0):
            SPLINE on ridges:
              at -0.01 (slope 0.0) -> 0.315
              at 0.01 (slope 0.0) -> 0.15
      at -0.375 (slope 0.0) -> 0.0
  at 0.65 (slope 0.0):
    SPLINE on erosion:
      at -1.0 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.19999999 (slope 0.0) -> 0.0
          at 0.44999996 (slope 0.0):
            SPLINE on ridges:
              at -0.01 (slope 0.0) -> 0.63
              at 0.01 (slope 0.0) -> 0.3
          at 1.0 (slope 0.0):
            SPLINE on ridges:
              at -0.01 (slope 0.0) -> 0.63
              at 0.01 (slope 0.0) -> 0.3
      at -0.78 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.19999999 (slope 0.0) -> 0.0
          at 0.44999996 (slope 0.0) -> 0.0
          at 1.0 (slope 0.0):
            SPLINE on ridges:
              at -0.01 (slope 0.0) -> 0.63
              at 0.01 (slope 0.0) -> 0.3
      at -0.5775 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.19999999 (slope 0.0) -> 0.0
          at 0.44999996 (slope 0.0) -> 0.0
          at 1.0 (slope 0.0):
            SPLINE on ridges:
              at -0.01 (slope 0.0) -> 0.63
              at 0.01 (slope 0.0) -> 0.3
      at -0.375 (slope 0.0) -> 0.0
```

### A.4 `overworld_amplified/factor`

Same structure as A.2 with the leaf values below (used only by the amplified preset).

```
first (blend branch) = 10.0; alpha = blend_alpha
second = spline
SPLINE on continents:
  at -0.19 (slope 0.0) -> 3.95
  at -0.15 (slope 0.0):
    SPLINE on erosion:
      at -0.6 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 6.25
      at -0.5 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 6.3
          at 0.05 (slope 0.0) -> 2.67
      at -0.35 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 6.25
      at -0.25 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 6.25
      at -0.1 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 2.67
          at 0.05 (slope 0.0) -> 6.3
      at 0.03 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 6.3
          at 0.2 (slope 0.0) -> 6.25
      at 0.35 (slope 0.0) -> 6.25
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 6.25
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 6.25
              at 0.1 (slope 0.0) -> 0.625
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 6.25
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 6.25
              at 0.1 (slope 0.0) -> 0.625
      at 0.62 (slope 0.0) -> 6.25
  at -0.1 (slope 0.0):
    SPLINE on erosion:
      at -0.6 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6530563
      at -0.5 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 0.6969027
          at 0.05 (slope 0.0) -> 0.4351369
      at -0.35 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6530563
      at -0.25 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6530563
      at -0.1 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 0.4351369
          at 0.05 (slope 0.0) -> 0.6969027
      at 0.03 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6530563
      at 0.35 (slope 0.0) -> 0.6530563
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 0.6530563
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 0.6530563
              at 0.1 (slope 0.0) -> 0.13888884
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 0.6530563
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 0.6530563
              at 0.1 (slope 0.0) -> 0.13888884
      at 0.62 (slope 0.0) -> 0.6530563
  at 0.03 (slope 0.0):
    SPLINE on erosion:
      at -0.6 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6299603
      at -0.5 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 0.6969027
          at 0.05 (slope 0.0) -> 0.4351369
      at -0.35 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6299603
      at -0.25 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6299603
      at -0.1 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 0.4351369
          at 0.05 (slope 0.0) -> 0.6969027
      at 0.03 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6299603
      at 0.35 (slope 0.0) -> 0.6299603
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 0.6299603
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 0.6299603
              at 0.1 (slope 0.0) -> 0.13888884
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.9 (slope 0.0) -> 0.6299603
          at -0.69 (slope 0.0):
            SPLINE on ridges:
              at 0.0 (slope 0.0) -> 0.6299603
              at 0.1 (slope 0.0) -> 0.13888884
      at 0.62 (slope 0.0) -> 0.6299603
  at 0.06 (slope 0.0):
    SPLINE on erosion:
      at -0.6 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6050052
      at -0.5 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 0.6969027
          at 0.05 (slope 0.0) -> 0.4351369
      at -0.35 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6050052
      at -0.25 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6050052
      at -0.1 (slope 0.0):
        SPLINE on ridges:
          at -0.05 (slope 0.0) -> 0.4351369
          at 0.05 (slope 0.0) -> 0.6969027
      at 0.03 (slope 0.0):
        SPLINE on ridges:
          at -0.2 (slope 0.0) -> 0.6969027
          at 0.2 (slope 0.0) -> 0.6050052
      at 0.05 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.45 (slope 0.0):
            SPLINE on ridges:
              at -0.2 (slope 0.0) -> 0.6969027
              at 0.2 (slope 0.0) -> 0.6050052
          at 0.7 (slope 0.0) -> 0.2972561
      at 0.4 (slope 0.0):
        SPLINE on ridges_folded:
          at 0.45 (slope 0.0):
            SPLINE on ridges:
              at -0.2 (slope 0.0) -> 0.6969027
              at 0.2 (slope 0.0) -> 0.6050052
          at 0.7 (slope 0.0) -> 0.2972561
      at 0.45 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.7 (slope 0.0):
            SPLINE on ridges:
              at -0.2 (slope 0.0) -> 0.6969027
              at 0.2 (slope 0.0) -> 0.6050052
          at -0.15 (slope 0.0) -> 0.2688383
      at 0.55 (slope 0.0):
        SPLINE on ridges_folded:
          at -0.7 (slope 0.0):
            SPLINE on ridges:
              at -0.2 (slope 0.0) -> 0.6969027
              at 0.2 (slope 0.0) -> 0.6050052
          at -0.15 (slope 0.0) -> 0.2688383
      at 0.58 (slope 0.0) -> 0.6050052
```
