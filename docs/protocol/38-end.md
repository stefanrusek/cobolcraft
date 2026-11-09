# 38 The End: generation and mechanics

| Item | Value |
|---|---|
| Covers | The End dimension as the game builds it: the dimension type values, the noise settings and the whole density pipeline (the central island, the outer islands, the vertical profile, the 3D base noise), the fill without aquifers, the surface rule, the End biome source (`the_end` preset, biome by position), the biome feature lists and the placed-feature wiring of the End (island, spikes, platform, gateway, chorus), the player arrival at the obsidian platform and the exit-portal return, the End sky and flash, and void behaviour. |
| Does not cover | Data rows (the extraction tool copies `data/minecraft/dimension_type`, `worldgen/noise_settings`, `worldgen/density_function`, `worldgen/biome`, `worldgen/placed_feature` and the rest, see 22 and 23): they are cited only to show wiring. The engines that are specified elsewhere are cross-referenced and not repeated: the dragon fight, the exit portal and gateway placement calls, the pillars (21 section 6.4.5 and 6.4.6), the feature classes `end_island`, `end_platform`, `end_podium`, `end_gateway` and `chorus_plant` (35 part 7 sections 9 and 10), the chorus block behaviour (29b part 4 section 8), the gateway block entity (31 part 5 section 4), the density-node model, noise primitives, surface-rule engine and chunk stages (10), decoration order (11 section 4 and 35-1), the End city pieces and structure placement engine (RS20 structure documents; only the hooks are here), the portal travel framework (RS23). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the classes named in each section and of the JSON under `data/minecraft/` in the jar, with no execution. Examples marked "(computed)" were produced by applying this document's text with a throwaway reference script written for the round; they are not read from the artifact. |
| Round | RS22 (GAP-13b of [../design/README.md](../design/README.md)) |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engine (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"). Code-defined content is specified completely. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not verified)" a
statement not read in this round; both are listed in the Open questions. Section references such as "10 section 4.2" are to documents of this
directory; for multi-part documents the form is "NN part K section S" (35 part 7 = 35-worldgen-features-7-nether-end-misc.md, 31 part 5 = 31-block-entities-5-beacon-conduit-end-piston-creaking.md, 29b part 4 = 29b-falling-growth-fire-4-growing-plants.md). Float means IEEE single precision and double means IEEE double precision; to be vanilla-identical an implementation rounds to single
precision at every step named float. `nextInt(n)`, `nextDouble()` of the legacy generator are as in 10 section 2.6.

---

## 1. Overview

The End is an ordinary noise-generated dimension (world preset `normal`, dimension `minecraft:the_end`: dimension type `the_end`, generator `noise`, biome
source `{"type": "minecraft:the_end"}`, noise settings `minecraft:end`, all read from `worldgen/world_preset/normal.json`). Its terrain is a
density field with three ingredients: one big central island (a smooth cone, section 4.1), a field of smaller "outer islands" that begins 1024 blocks
out (section 4.2) and a 3D noise that roughens both (section 4.4). Chunk stages are those of 10 section 11.1; the differences are: no aquifer, no
carvers (every End biome has an empty `carvers` list), a surface rule that changes nothing, and `disable_mob_generation` true.

| Stage fact | Value |
|---|---|
| Fill | section 5; blocks only at `y` 0 to 127; everything else air |
| Surface pass | no-op (section 6) |
| Carvers | none (all five End biomes list none) |
| Biome features | section 8 |
| Structures | `end_city` only (section 10) |

---

## 2. Dimension type `minecraft:the_end` (`data/minecraft/dimension_type/the_end.json`)

| Field | Value |
|---|---|
| `min_y`, `height`, `logical_height` | 0, 256, 256 (sections 0 to 15) |
| `coordinate_scale` | 1.0 |
| `has_skylight`, `has_ceiling` | true, false |
| `has_fixed_time` | true |
| `has_ender_dragon_fight` | true (creates the fight controller, 21 section 6.4.5; `ServerLevel` initialises it with seed and origin `(0, 0, 0)`) |
| `ambient_light` | 0.25 |
| `infiniburn` | tag `#minecraft:infiniburn_end` = `#minecraft:infiniburn_overworld` plus `bedrock` |
| `monster_spawn_light_level`, `monster_spawn_block_light_limit` | 15, 0 |
| `default_clock` | `minecraft:the_end` (the `world_clock` file is `{}`: a clock that exists but has no configuration) |
| `timelines` | tag `#minecraft:in_end` = `#minecraft:universal` = `minecraft:villager_schedule` only. The End has none of the day, moon or early-game timelines. |
| `skybox` | `end` |

Attributes (the `attributes` map; 12 section 3 explains how the client reads the visual ones):

| Attribute | Value |
|---|---|
| `visual/sky_color` | `#000000` |
| `visual/fog_color` | `#181318` |
| `visual/ambient_light_color` | `#3f473f` |
| `visual/sky_light_color` | `#ac60cd` |
| `visual/sky_light_factor` | 0.0 |
| `gameplay/bed_rule`, `gameplay/straw_bed_rule` | `can_set_spawn` never, `can_sleep` never, `destroy_on_use` true (a bed used here is destroyed; the destruction mechanics are in the bed documents, not here) |
| `gameplay/respawn_anchor_works` | false |
| `audio/background_music` | default `music.end`, delays 6000 to 24000, `replace_current_music` true |
| `audio/ambient_sounds` | mood: sound `ambient.cave`, tick delay 6000, block search extent 8, offset 2.0 |

Consequences: the sky colour is black and the fog colour dark purple-grey, so clear colour and fog use `#181318`; time never advances
visibly (no sun, moon or stars, `has_fixed_time`); beds and
anchors cannot set a spawn here. The `the_end.json` file has no `cardinal_light` key, so the dimension type field `cardinalLightType` takes its codec default (the default value itself was not read, Open question 10).
Two statements often made about the End were not read in this round: that the `/time` command needs a clock and that death in the End sends the player to the level respawn position (both recalled, not verified; Open question 11). Section 9.2 describes the portal exit only, not death.

---

## 3. Noise settings `minecraft:end` (`worldgen/noise_settings/end.json`)

| Field | Value |
|---|---|
| `noise.min_y`, `noise.height` | 0, 128 (the density volume of a chunk is 16 x 128 x 16 starting at `y = 0`; read from `NoiseBasedChunkGenerator.chunkVolume`) |
| `default_block` | `minecraft:end_stone` |
| `default_fluid` | `minecraft:air` |
| `sea_level` | 0 |
| `legacy_random_source` | true |
| `disable_mob_generation` | true (no mobs are spawned at chunk generation; natural spawning is separate, 18) |
| `aquifers` | absent |
| `material_rule` | `minecraft:end` (section 6) |
| `spawn_target` | empty list |
| `noise_router` | `final_density` = section 5.1; `erosion` = `minecraft:end/islands`; `continents`, `depth`, `chunk_surface_level`, `ridges`, `temperature`, `vegetation` all the constant 0.0 |
| `debug_functions` | two labelled debug functions (`N` and `IS`); no effect on generation |

`legacy_random_source` true changes only random seeding of the density nodes that ask for it (`RandomState$1.createRandom`): the node that asks for the
`minecraft:terrain` random (the old blended noise, section 4.4) receives `LegacyRandomSource(worldSeed + 0)`, that is `LegacyRandomSource(worldSeed)`, instead of the
positional hash of 10 section 2.5 item 4. (Read: `createRandom` tests the flag and the identifier `minecraft:terrain`; any other identifier would still use the
Xoroshiro positional factory, but the End uses no other.) The End island node has its own seeding (section 4.3).

The `erosion` router entry is the value the biome source reads (section 7).

---

## 4. The density functions (`worldgen/density_function/end/*`)

Node semantics (`add`, `mul`, `sub`, `max`, `clamp`, `lerp`, `gradient`, `squeeze`, `interpolated`, `cache`, `blend_density`, `beardifier`) are those of 10 section 4. Three
node types that 10 section 4.2 lists as unused are used here and specified in sections 4.1 to 4.3.

### 4.1 `distance_to_point` and `slice` (`DistanceToPointFunction`, `SliceFunction`, `DistanceMetric`)

- `distance_to_point` (`metric`, `point [px, py, pz]` integers): value at `(x, y, z)` is the metric of the float differences `(px - x, py - y, pz - z)` (each integer difference converted to float). Metrics (`DistanceMetric.compute`): `euclidean` = float `sqrt(dx*dx + dy*dy + dz*dz)` computed as the double square root of the float sum of squares, then rounded to float (`Mth.length`); `euclidean_squared` = the float sum of squares; `manhattan` = `|dx| + |dy| + |dz|`; `chebyshev` = `max(|dx|, |dy|, |dz|)`.
- `slice` (`axis`, `coordinate` int, `input`): value at a point is the input evaluated with the coordinate of `axis` replaced by `coordinate` (the other two axes are unchanged). With `axis y`, `coordinate 0` the input is evaluated at `y = 0` for every `y`.

### 4.2 `end/islands` (data file) and the central island

`end/islands` = `cache( max( slice_y0( (clamp(100.0 - distance_to_point_euclid((0, 0, 0)), min -100.0, max 80.0) - 8.0) * 0.0078125 ), end_outer_islands ) )`,
where `slice_y0` evaluates its input at `y = 0`. So with `d = float sqrt(x*x + z*z)` (the distance to the origin in the horizontal plane, as the slice sets `y = 0`):

`central(x, z) = (clamp(100 - d, -100, 80) - 8) * 0.0078125`   (all float; `0.0078125 = 1/128`).

| `d` | `central` |
|---|---|
| 0 to 20 | 0.5625 (the clamp holds 80; `(80 - 8)/128`) |
| 100 | -0.0625 |
| 160 | -0.53125 |
| 200 or more | -0.84375 (the clamp holds -100) |

It falls linearly (slope `-1/128` per block) between `d = 20` and `d = 200`. `end/islands` is the larger of this and the outer-island value, and does not depend on `y`.

### 4.3 `end_outer_islands` (`EndIslandFunction`, `EndIslandFunction$Sampler`)

The node has no parameters. Its value at block `(x, y, z)` (independent of `y`) is `(H(x / 8, z / 8) - 8.0) / 128.0` in float, where `/` is Java integer division on the **block**
coordinates (truncation toward zero; every position at which the game samples it is a multiple of 8, so the division is exact, see 4.5) and `H` is below. Range of the node: -0.84375 to 0.5625 (`H` from -100 to 80).

**Seeding** (`RandomState$1.createEndIslandRandom`, `EndIslandFunction.compileSampler`): `r = LegacyRandomSource(worldSeed)` (the plain seed, no offset); then `17292` calls of `r.nextInt()` (each is `next(32)`, 10 section 2.6) are made and
discarded (`consumeCount`); then `N = SimplexNoise(r, true)` is constructed from `r`. The `true` flag multiplies the three offsets by 0 instead of 256 (the three `nextDouble()` draws
still happen); the permutation table is shuffled as in 10 section 3.1 steps 2 and 3 (`perm[i]` swapped with `perm[i + nextInt(256 - i)]` for `i` 0 to 255). The 2D simplex `N.get(x, y)` is that of 10 section 3.5 (re-read here against
`SimplexNoise`: corners use `c = 0.5 - x^2 - y^2`, contribution `c^4 * dot(gradient[g], (x, y, 0))`, `g = perm(...) mod 12`, result `(float)(70.0 * (n0 + n1 + n2))`; the lattice indices are masked: `i & 255` and `j & 255` are taken before the permutation lookups and `permute` masks with 255 again, so the noise is periodic in **skewed lattice space**, not along the input axes: `i` and `j` are the floors of the skewed coordinates, with `F2 = 0.5 * (sqrt(3) - 1)` and `G2 = (3 - sqrt(3)) / 6` read from the class initialiser. A shift of the input that adds 256 to `i` and 0 to `j` is `(256 * (1 - G2), -256 * G2)`, about `(201.9, -54.1)` in the input units (px, pz, cells of 16 blocks, about `(3230, -866)` blocks); the other period vector is about `(-54.1, 201.9)`. A plain shift of 256 along one axis is not a period (the period vectors are derived from the masking and the skew constants, inferred, not tested against the game); this agrees with 10 section 3.5 `ii = i & 255`). A different world seed therefore
gives a different permutation; the sampler is created once per generator (the same noise serves terrain and biome source, section 7).

**`H(ix, iz)`** (`EndIslandFunction.getHeightValue`, inputs `ix = x / 8`, `iz = z / 8` as ints):

1. `hx = ix / 2`, `hz = iz / 2` (Java integer division, truncating toward zero), `sx = ix % 2`, `sz = iz % 2` (Java remainder: the sign of the dividend, so -1, 0 or 1).
2. `best = -100.0` (float).
3. For `ox` from -12 to 12 (outer) and `oz` from -12 to 12 (inner): `px = hx + ox`, `pz = hz + oz` (as 64-bit integers).
   1. Skip unless `px*px + pz*pz > 4096` **and** `N.get((double) px, (double) pz) < -0.9f` (float comparison). The first test removes every candidate within 64 units of the origin (in units of 16 blocks: 1024 blocks), so no outer island exists inside that disc.
   2. `w = ((|(float) px| * 3439.0f + |(float) pz| * 147.0f) % 13.0f) + 9.0f` (float; `%` is Java float remainder; `w` lies in [9, 22)). `w` is the island's "steepness".
   3. `ddx = (float)(sx - ox * 2)`, `ddz = (float)(sz - oz * 2)`.
   4. `v = 100.0f - sqrt_f(ddx*ddx + ddz*ddz) * w` where `sqrt_f` is the double square root rounded to float; then `v = clamp(v, -100.0f, 80.0f)` (`Mth.clamp`: below -100 gives -100, else `min(v, 80)`).
   5. `best = max(best, v)`.
4. Return `best`.

So each candidate cell `(px, pz)` whose noise is below -0.9 (a rare minority of cells) is an island centre. The distance unit of `ddx`, `ddz` is one `ix` step, that is **8 blocks** (they are built from `sx - ox * 2` with `sx` in -1..1). The value is `100 - dist * w`, clamped to [-100, 80]: a cone with a flat top at 80 of radius `20 / w` units (`160 / w` blocks), crossing zero at `100 / w` units (`800 / w` blocks) and reaching -100 at `200 / w` units (`1600 / w` blocks, about 73 to 178 blocks for `w` in [9, 22)), which is the island's largest extent. The `% 13`, `3439`, `147` terms make `w` pseudo-random per cell (a hash, not a random draw).

### 4.4 `end/base_3d_noise` and `end/sloped_cheese`

`end/base_3d_noise` is `old_blended_noise` with `xz_scale 0.25`, `y_scale 0.25`, `xz_factor 80.0`, `y_factor 160.0`, `smear_scale_multiplier 4.0`. Its engine is 10 section 3.4. For these values: `xzMul = 684.412 * 0.25 = 171.103`,
`yMul = 171.103`, `smear = yMul * 4 = 684.412`, the main stack uses scales `xzMul / 80 = 2.1387875` horizontally and `yMul / 160 = 1.0693937` vertically with smear `684.412 / 160 = 4.277575`. The random is the legacy one of
section 3: `r = LegacyRandomSource(worldSeed)`; `PerlinNoise` constructions inside the three octave stacks draw `nextDouble` and `nextInt(bound)` from it in the order of 10 section 3.4 step 3. (The overworld's `old_blended_noise` has
`y_scale 0.125` and `smear 8`; the End's differ, which is why the End's `y` variation is steeper.)

`end/sloped_cheese` = `add(end/islands, end/base_3d_noise)`; call it `S(x, y, z)`.

### 4.5 Where `S` is sampled (inferred)

The claim below that corner x and z are multiples of 8 is **(inferred)**: `EndIslandFunction$Sampler.sampleVolume` calls `sampleValue(ctx, blockX, 0, blockZ)` per volume column and `sampleValue` divides by 8; whether `DensityVolume.blockX` steps by 8 was not read (Open question 2). The biome source samples at `(2s + 1) * 8`, a multiple of 8, so only the terrain case is affected.

`S` is only ever read at the corner points of the 8 x 4 x 8 cells of the `interpolated` node (section 5.1) and, for the island part alone, by the biome source (section 7). Corner x and z are multiples of 8, so the `/ 8` of section 4.3 is exact for terrain;
the only non-trivial case of truncation (negative odd `ix`) is therefore `ix / 2` and `ix % 2` inside `H`, e.g. `ix = -3` gives `hx = -1`, `sx = -1`.

---

## 5. Terrain fill

### 5.1 `final_density`

```
final_density = add( squeeze( interpolated( cell_size_xz 8, cell_size_y 4,
                         mul( blend_density( A_blend ), 0.64 ) ) ),
                     beardifier )

A_blend = lerp( alpha = grad_lo(y),
                first  = -0.234375,
                second = lerp( alpha = grad_hi(y), first = -23.4375, second = end/sloped_cheese ) )

grad_lo(y) = gradient on y, from_coordinate 4 (value 0.0) to_coordinate 32 (value 1.0), clamped
grad_hi(y) = gradient on y, from_coordinate 56 (value 1.0) to_coordinate 312 (value 0.0), clamped
```

`gradient` and `lerp` are as 10 section 4.2: `factor = (to_value - from_value) / (float)(to_coordinate - from_coordinate)` and
`from_value + (float)(c - from_coordinate) * factor` with `c` clamped to the coordinate range; `lerp` returns `first` exactly when alpha is 0 and `second` when it is 1. For a world without older chunks `blend_density` is the identity (10 section 4.1).
`squeeze(v)` is `c/2 - c^3/24` with `c = clamp(v, -1, 1)`. `interpolated` is the trilinear interpolation of 10 section 4.1 over cells of 8 (x and z) by 4 (y), world-aligned; the corner values are `0.64 * A_blend` there.

The vertical profile `A_blend(y)` (computed from the two gradients):

| `y` | `grad_lo` | `grad_hi` | `A_blend` |
|---|---|---|---|
| 0 to 4 | 0 | 1 | -0.234375 (constant: air; there is no terrain at the bottom of the End) |
| 18 | 0.5 | 1 | halfway between -0.234375 and `S` |
| 32 to 56 | 1 | 1 | `S` unchanged |
| 62 | 1 | 0.9765625 | `S * 0.9765625 - 23.4375 * 0.0234375 = 0.9765625 S - 0.549316...` (see example 13.1) |
| 184 | 1 | 0.5 | halfway between `S` and -23.4375 (not reached: the volume stops at y = 127) |
| 312 and up | 1 | 0 | -23.4375 |

For `y` between 56 and 127 the weight of the large negative constant grows by `1/256` per block, so every island has an upper surface that the 3D noise cannot push above roughly `y = 70` to 90; the cell grid makes the profile a
piecewise-linear function between cell corners at `y` = multiples of 4.

The `beardifier` is 0 unless structures with terrain adaptation lie near the chunk (10 section 11.2). The `end_city` structure has no `terrain_adaptation` entry (read from `worldgen/structure/end_city.json`), so in the End the beardifier is always 0.

### 5.2 Fill (`NoiseBasedChunkGenerator.doFill` without aquifers)

The procedure is that of 10 section 8.1 with these differences:

1. The volume is 16 x 128 x 16 (`y` 0 to 127), so the column loop starts at `y = 127` and ends at 0; blocks at `y` 128 to 255 are never written (air).
2. `NoiseChunk` builds `Aquifer.createDisabled(fluidPicker)` because `aquifers` is absent. `computeSubstance(x, y, z, d)`: when `d > 0` return "none" (the caller uses the default block `end_stone`); otherwise ask the fluid picker. The picker (`createFluidPicker`) returns the status with level `-54` and lava when `y < min(-54, seaLevel) = -54`, else the sea status with level `seaLevel = 0` and the default fluid (air). `createFluidPicker` also builds a third status (level `2 * MIN_Y`, air) that is unreachable in the End and harmless. The substance is that status's `at(y)`: the fluid type when `y < level`, else air. In the End `y >= 0`, so the lava branch is never taken and the result is always **air**. `shouldScheduleFluidUpdate` is false.
3. So every cell with `final_density > 0` becomes `end_stone`; every other cell stays unset (air). The heightmap updates are as in 10 section 8.1 (an `end_stone` column top is `WORLD_SURFACE_WG` and `OCEAN_FLOOR_WG`).
4. There is no bedrock floor, no deepslate and no ore: all of them come from the overworld `material_rule` only.

---

## 6. Surface rule `minecraft:end` (`worldgen/material_rule/end.json`)

The rule is the single node `{"type": "block", "result_state": "end_stone"}`, which yields `end_stone` for every position it is asked about. The surface pass (10 section 10.1) asks for every solid non-fluid block of every column;
each already is `end_stone`, so the pass changes nothing. A reimplementation may skip the surface pass in the End; the result is identical. (Because it runs, the heightmaps of the pass are still created by the fill.)

---

## 7. The End biome source (`TheEndBiomeSource`)

Biomes held, in the constructor order: `the_end`, `end_highlands`, `end_midlands`, `small_end_islands`, `end_barrens` (all five at `minecraft:`; `collectPossibleBiomes` lists them in this order). The source has no
parameters beyond these references (the world preset writes only `{"type": "minecraft:the_end"}`).

**Lookup** `getNoiseBiome(qx, qy, qz, sampler)` (quart coordinates; 10 section 7.6 says how the chunk's biome palette is filled from per-quart lookups):

1. `bx = qx * 4`, `by = qy * 4`, `bz = qz * 4` (block coordinates of the quart; `QuartPos.toBlock`).
2. `sx = bx >> 4`, `sz = bz >> 4` (section coordinates, arithmetic shift).
3. When `sx*sx + sz*sz <= 4096` (64-bit): return `the_end`. (A disc of radius 64 chunks = 1024 blocks around the origin; the boundary is inclusive.)
4. Otherwise `xx = (sx * 2 + 1) * 8`, `zz = (sz * 2 + 1) * 8` (the block coordinates of the centre of the chunk's column, rounded to a multiple of 8: `16 sx + 8`), `e = erosion(xx, by, zz)` as a double, where `erosion` is the router entry `end/islands`
   (section 4.2), evaluated at that point: `e = max(central(xx, zz), outer(xx, zz))`.
5. `e > 0.25`: `end_highlands`; else `e >= -0.0625`: `end_midlands`; else `e < -0.21875`: `small_end_islands`; else `end_barrens`.

Notes: the result depends only on the chunk (`sx`, `sz`), not on `y` or on the position within the chunk, outside the central disc; the thresholds map the island field so that the highest ground (values above 0.25, cone cores near an outer island centre) is
highlands, a ring around it midlands, a surrounding band barrens and the rest (value below -0.21875, including the empty void between islands: the minimum value of the field is -0.84375) `small_end_islands`. Every position beyond the disc has a biome, including void.
Block-position lookups (`Level.getBiome(pos)`, used by placed-feature `biome` filters and by 29-style checks) go through the fuzzy zoom of 10 section 7.7 with the world's obfuscated seed, as in the overworld.

Biome properties of the five (`worldgen/biome/*.json`, all read): temperature 0.5, downfall 0.5, no precipitation, water colour `#3f76e4`, no carvers, natural monster spawns overlay `enderman` count 4, weight 10 (monster category; the mob rules are 18 and 21 section 3.4). Their feature lists:

| Biome | `features` (index = generation step, 11 steps as 11 section 4) |
|---|---|
| `the_end` | step 4: `end_spike`; step 10: `end_platform` |
| `end_highlands` | step 4: `end_gateway_return`; step 9: `chorus_plant` |
| `end_midlands` | none |
| `small_end_islands` | step 0: `end_island_decorated` |
| `end_barrens` | none |

Tag `is_end` holds all five; tag `has_structure/end_city` holds `end_highlands` and `end_midlands`.

Worked examples with world seed 0 (computed): block `(1023, 0)` and `(1024, 0)`: section x 63 and 64, `sx*sx = 3969` and `4096` both `<= 4096`: `the_end`. Block `(1040, 0)` is section 65 (`4225 > 4096`) and
therefore leaves the disc; the other probes are in section 13.2.

---

## 8. Features of the End: wiring and where each is specified

| Placed feature (or configured feature where marked) | Feature | Placement modifiers (data, read) | Engine |
|---|---|---|---|
| `end_spike` | `end_spike` with an empty `spikes` list (the ten pillars are computed from the world seed) | `biome` only | pillars: 21 section 6.4.6 and 35 part 7 section 8 |
| `end_platform` | `end_platform` | `fixed_placement [[100, 49, 0]]`, `biome` | 35 part 7 section 10.2; the arrival platform of section 9 |
| `end_island_decorated` | `end_island` | `rarity_filter 14`, `count` weighted list (1 with weight 3, 2 with weight 1), `in_square`, `height_range` uniform 55 to 70 inclusive (absolute), `biome` | 35 part 7 section 10.1 |
| `end_gateway_return` (the placed feature references the configured feature `end_gateway_return`, which holds `exact true`, `exit [100, 50, 0]`) | `end_gateway` | `rarity_filter 700`, `in_square`, `heightmap MOTION_BLOCKING`, `offset y uniform 3 to 9` (x, z 0), `biome` | 35 part 7 section 10.4 |
| `chorus_plant` | `chorus_plant` | `count` uniform 0 to 4, `in_square`, `heightmap MOTION_BLOCKING`, `biome` | 35 part 7 section 9 |
| configured feature only (no placed_feature file) `end_gateway_delayed` | `end_gateway`, `exact false`, no exit | placed by the dragon fight at each kill | 21 section 6.4.5 |
| configured features only (no placed_feature file) `end_podium_active`, `end_podium_inactive` (the latter is `{type end_podium}` with `active` defaulted) | `end_podium` | placed by the fight controller | 35 part 7 section 10.3, 21 section 6.4.5 |

Notes on the wiring:

- The pillars and the obsidian platform are generated by the `the_end` biome only, hence within the central disc (the pillars are at radius 42, `EndSpikeFeature.SPIKE_DISTANCE`, see 21 section 6.4.6, and the platform at `x = 100`, both inside radius 1024).
- `end_island_decorated` is generated in `small_end_islands` columns at step 0 (raw generation, before the terrain stage's surface features), with an end-stone stack placed at a height between 55 and 70; since `small_end_islands` is the lowest-value band (void
  between the outer islands) these are the tiny floating islands of the void. The island engine is the upside-down disc stack of 35 part 7 section 10.1.
- The gateway return portals appear in `end_highlands` columns: one per chunk with probability 1/700, on the surface (`MOTION_BLOCKING` heightmap) plus 3 to 9 blocks. Each leads (when used) to the position `(100, 50, 0)`; the block entity travel rules are 31 part 5 section 4.
  The data placement `exit [100, 50, 0]`, `exact true` is for `end_gateway_return` and `exact false`, no exit for `end_gateway_delayed`. **Discrepancy with 31 part 5 section 4.2**, whose last paragraph states the two the other way round; the jar's `end_gateway_return.json` and `end_gateway_delayed.json` are as written here (and agree with 35 part 7 section 10.4).
- Chorus plants: 0 to 4 attempts per chunk (uniform inclusive), at a random column in the chunk, at the `MOTION_BLOCKING` surface; the feature then requires an `end_stone` block below the air block (35 part 7 section 9). Growth and breaking of chorus blocks at runtime is 29b part 4 section 8.
- Feature decoration order, seeds and the write window are 11 section 4 and 35-1 sections 4 to 6; this document does not change them.
- Features never run in `end_midlands` or `end_barrens`: those two have empty lists. End cities (below) are structures, not biome features.

---

## 9. Player arrival, the obsidian platform, the return, void and falling

### 9.1 Entering the End (`EndPortalBlock.getPortalDestination` with the destination End)

Triggered by an entity standing inside an end portal block in any other dimension (`entityInside`: the entity must pass `canUsePortal(false)`, then `setAsInsidePortal`; the transit delay and portal cooldown belong to RS23). When the destination is the End (`source != End`):

1. Target level = `minecraft:the_end` (when it is not loaded or does not exist the portal does nothing).
2. Target point `P = END_SPAWN_POINT` = block `(100, 50, 0)` (read from the `ServerLevel` static initialiser), as bottom-centre `(100.5, 50.0, 0.5)`.
3. The obsidian platform is (re)built before the move: `EndPlatformFeature.createEndPlatform(level, centre = containing(P).below() = (100, 49, 0), dropBlocks = true)`: floor of obsidian at `y = 48` for `x` 98 to 102 and `z` -2 to 2, air for `y` 49 to 51 above it; each changed block is destroyed with item drops first (35 part 7 section 10.2). It happens on **every** entry, not only the first: blocks the player placed or removed in that 5 x 5 x 4 volume are reset (items drop).
4. For a **player** the arrival position is `P - (0, 1, 0)` = `(100.5, 49.0, 0.5)` (the player stands on the top face of the obsidian at y 49). For a **non-player** entity the arrival position is `P` unchanged, `(100.5, 50.0, 0.5)`: when the source is not the End, `adjustSpawnLocation` is not called at all, so there is no heightmap lookup and the level respawn position `R` is not read for the position (read in the bytecode: only the `instanceof ServerPlayer` test subtracts 1.0 from y). `adjustSpawnLocation` is called only in the leaving case (section 9.2). The platform has just been built regardless.
5. Rotation: yaw = `Direction.WEST.toYRot()` = 90.0 degrees (looking west), pitch 0; the transition keeps velocity relative (`Relative.DELTA`) and the pitch relative (`Relative.X_ROT`), so the pitch the entity had is kept and the yaw is set to 90 degrees.
6. Post-transition actions: play the portal sound, then place a portal chunk ticket (`PLAY_PORTAL_SOUND` then `PLACE_PORTAL_TICKET`).

The first entry also loads the End: the fight controller of 21 section 6.4.5 starts when the first valid player is near (recalled, not verified). What was read about the fight: `ServerLevel` creates `EnderDragonFight` at level construction when `has_ender_dragon_fight` is true and calls `init(level, seed, BlockPos.ZERO)`. The central island and the pillars are generated by normal chunk generation when the chunks around `(100, 0)` are requested; the platform at `z` -2 to 2 straddles chunks `(6, -1)` and `(6, 0)` (`z` -2 to -1 lie in chunk row -1, `z` 0 to 2 in row 0), so both chunks are touched by the `end_platform` placed feature of section 8.

### 9.2 Leaving the End

For `source == End` the portal acts with the level's respawn data `R` (`ServerLevel.getRespawnData()`: dimension, position, yaw, pitch):

- A **player** gets `ServerPlayer.findRespawnPositionAndUseSpawnBlock(false, DO_NOTHING)`: the player's personal respawn rule (bed or anchor spawn, else the world spawn) applies; that routine is outside this document (RS23, with the respawn block rules). The same call is not used in the End for a non-player.
- A non-player entity goes to `R.dimension` at `adjustSpawnLocation(that level, R.pos)` with yaw `R.yaw` and pitch `R.pitch` taken as relative (`Relative.ROTATION`, `Relative.DELTA`).
- Before that, in the End a player who has not seen the credits (`seenCredits` false) gets the credits screen instead of the transition: `entityInside` calls `showEndCredits()` and does not call `setAsInsidePortal` (the transition happens when the credits finish; not read further).

### 9.3 Void and falling

`checkBelowWorld` applies at `y < minY - 64` (18 section 5 step 4, 17 damage table): in the End `minY = 0`, so below `y = -64` plain entities are discarded and living entities take 4.0 `fell_out_of_world` damage each tick. Because the density at `y <= 4` is a constant air value and
terrain exists only for `y` 0 to 127, falling off an island is a fall of at least tens of blocks to the void, with no ground at all outside islands. Blocks above `y = 255` do not exist and building stops at `y = 255` (`min_y + height - 1`, 06). Falling-block entities and items obey 29b-1 and 41; nothing End-specific was found.

### 9.4 Initial spawn

The End has no `spawn_target` (empty list), and a player never spawns here at world creation. Natural spawning in the End: the dimension values `monster_spawn_light_level 15`, `monster_spawn_block_light_limit 0` mean monsters spawn regardless of light (inferred from the values, not read in the spawn code); mobs by biome are the enderman overlay of section 7.

---

## 10. End city hooks (cross-reference only)

`worldgen/structure/end_city.json`: type `end_city`, biomes tag `has_structure/end_city` (`end_highlands`, `end_midlands`), `spawn_overrides` empty, step `surface_structures` (generation step index 4 of 11 section 4), no terrain adaptation.
`worldgen/structure_set/end_cities.json`: `random_spread`, `spacing 20`, `separation 11`, `spread_type triangular`, `salt 10387313`, a single entry `end_city` weight 1. The placement engine (`random_spread` position in region of 20 x 20 chunks, triangular spread) and the pieces of the city
(ship, tower, bridge and house pieces, loot chests, elytra frame) are the structure documents of RS20 and the template (structure NBT) loader; the dependency of start location on the terrain height at the city position is read there. This document gives only the biome and placement data.

---

## 11. The End sky and the end flash (client; completes the gap of 12 section 3.4)

When the dimension's `skybox` is `end` (`SkyRenderer.render`) the sky pass draws the **end sky box** first, then the **end flash** when its intensity exceeds `1.0E-5`; the overworld disc, sun, moon and stars are not drawn.

**End sky box** (`SkyRenderer.buildEndSky`, `END_SKY_QUAD_COUNT` 6): six quads (a cube) with half-size 100 centred on the camera (the buffer is drawn with the camera's orientation but not its position, as the sky disc of 12 section 3.4a, inferred from the shared drawing code),
texture `textures/environment/end_sky.png`, colour `0xFF282828` (opaque dark grey, 40, 40, 40, the vertex colour multiplies the texture), texture coordinates run 0 to 16 across each face (the texture repeats 16 times on a face if the sampler wraps; the wrap mode was not read).
The six faces are the six rotations (identity and rotations by +/- 90 degrees about X and Z and 180 degrees, read as the six constants `1.5707964`, `-1.5707964`, `3.1415927` in the builder; the exact assignment is not recorded here, Open question 5).
The per-face vertex order is `(-100, -100, -100) uv (0, 0)`, `(-100, -100, 100) uv (0, 16)`, `(100, -100, 100) uv (16, 16)`, `(100, -100, -100) uv (16, 0)` for the first face.

**End flash** (`EndFlashState`, exists only when `DimensionType.hasEndFlashes()` is true, which is `skybox == end`; `ClientLevel.tick` calls `EndFlashState.tick(getDefaultClockTime())`, so `t` is the **tick count of the dimension's default world clock** (`minecraft:the_end`, `Level.getClockTimeTicks`), and 0 when the dimension has no clock, not the level game time):

1. `window = t / 600` (integer division), `phase = t % 600`. The parameters are recomputed only when `window != flashSeed`, and the field `flashSeed` starts at 0 (`EndFlashState.calculateFlashParameters`). **Window 0** (`t < 600` on a fresh state) therefore never computes them: `offset = duration = 0`, `xAngle = yAngle = 0`, and the intensity is 0 for every phase above 0 and `sin(0) = 0` at phase 0, so there is no flash in the first 600 ticks. For other windows the parameters are recomputed when `window` changes: `r = RandomSource.createThreadLocalInstance(window)` (the Java LCG of 10 section 2.6, seeded with `window`); one `nextFloat()` is drawn and discarded; `offset = randomBetweenInclusive(r, 0, 200)` (`nextInt(201)`); `duration = randomBetweenInclusive(r, 100, min(380, 600 - offset))` (`100 + nextInt(min(380, 600 - offset) - 99)`); `xAngle = randomBetween(r, -60.0, 10.0)` (`nextFloat() * 70 + -60`, float); `yAngle = randomBetween(r, -180.0, 180.0)`.
2. `intensity = 0` when `phase < offset` or `phase > offset + duration`, else `sin(arg)` with `arg = (float)(phase - offset) * 3.1415927f / (float)duration` computed in float, widened to double and passed to the table `Mth.sin(double)` (the half-wave from 0 up to 1 and back to 0).
3. The previous tick's intensity is kept; the rendered intensity is `lerp(partialTick, old, new)`. The flash "starts this tick" when the new intensity is above 0 and the old is not; `ClientLevel` then plays a `DirectionalSoundInstance` (built with the camera, `xAngle` and `yAngle`) through `SoundManager.playDelayed` with a delay of `SOUND_DELAY_IN_TICKS = 30` ticks (the sound itself is out of scope). The `sin` of item 2 is `Mth.sin(double)`, a table lookup: index `(long)(x * 10430.378350470453) & 65535` into a 65536-entry float table, so intensity uses the table sine and not the double function.
4. Drawn (`SkyRenderer.renderEndFlash`) with the `end_flash` sprite (64 x 64) of the celestials atlas. Transform order: first a rotation about the Y axis of `(180 - yAngle)` degrees, then a rotation about the X axis of `(-90 - xAngle)` degrees, then `applyCelestialBodyTransform` with height `END_FLASH_HEIGHT = 100` and scale `END_FLASH_SCALE = 60` (quad of size 60 at distance 100). The draw colour is the four-channel vector `(i, i, i, i)` with `i` the rendered intensity, so the intensity multiplies the red, green and blue channels as well as alpha (the pipeline is the additive celestial blend of 12 section 3.4c). The sky pass draws the flash only when the intensity exceeds `1.0E-5`.
5. Lightmap and fog use (`LightmapRenderStateExtractor`): `getIntensity(partialTick)` is added to the `skyFactor` of the lightmap state (that intensity is first divided by 3 when `BossHealthOverlay.shouldCreateWorldFog()` is true). The addition is skipped when the `hideLightningFlash` option is set. 12 section 3 mentions this only in part. (The fog part beyond this addition was not read.)

---

## 12. Behaviour summary for implementers

1. World seed `S`: `rIsland = LegacyRandomSource(S)`; skip 17292 `nextInt()`; `N = SimplexNoise(rIsland, true)`; `rTerrain = LegacyRandomSource(S)` for the blended noise (three stacks from one random).
2. Terrain at corners `(8a, 4b, 8c)` of cells: `S = max(central, outer(N)) + blended(rTerrain)`; apply the vertical profile (section 5.1), multiply 0.64, interpolate trilinearly, squeeze, add 0; `> 0` is `end_stone` for `y` 0 to 127.
3. Biomes: chunk disc radius 64 chunks `the_end`; beyond, by `end/islands` at the chunk's 8-offset centre with thresholds 0.25, -0.0625 and -0.21875.
4. Decoration: biome feature lists of section 7 through the engines of 35.
5. Arrival: platform at `(98..102, 48, -2..2)` rebuilt each entry; player at `(100.5, 49, 0.5)`, yaw 90.
6. No sun, moon or stars; fog and sky colours of section 2; end sky box and flash of section 11.

---

## 13. Worked examples

### 13.1 Central island at the world origin (computed, arithmetic from section 4 and 5.1)

At `x = z = 0`: `d = 0`, `central = (80 - 8) / 128 = 0.5625` and `outer` is below this (it is at most 0.5625 and, in the disc, equals -0.84375 or the value of an island beyond 64 chunks). Take `base_3d_noise = 0` (illustration; the real
noise varies). Then `S = 0.5625` for all `y`. Corner values `0.64 * A_blend`:

| corner `y` | `grad_lo` | `grad_hi` | `A_blend = lerp(grad_hi, -23.4375, S)` | times 0.64 |
|---|---|---|---|---|
| 0 | 0 | 1 | -0.234375 (first) | -0.15 |
| 4 | 0 | 1 | -0.234375 | -0.15 |
| 32 | 1 | 1 | 0.5625 | 0.36 |
| 56 | 1 | 1 | 0.5625 | 0.36 |
| 60 | 1 | 0.984375 | `-23.4375 + 0.984375 * 24 = 0.1875` | 0.12 |
| 64 | 1 | 0.96875 | `-23.4375 + 0.96875 * 24 = -0.1875` | -0.12 |

Between the corners at `y = 60` and 64 the interpolated value changes sign at `y = 62` (`grad_hi = 0.9765625`, `A_blend = 0`): for zero base noise the central island's top surface at the origin is at `y = 61` (the topmost solid block is 61, the first air block 62), apart
from `squeeze` (monotonic, sign-preserving). The island underside: `A_blend` rises from -0.234375 at `y = 4` to 0.5625 at `y = 32`, crossing zero at `y = 4 + 28 * 0.234375 / 0.796875 = 12.2` in the continuous formula, so (with zero base noise) the continuous underside is at `y = 12.2`; the 4-block cell interpolation makes it piecewise linear between the corners at `y = 12` and `y = 16`: the corner values `0.64 * A_blend` are -0.004286 at `y = 12` (`A_blend = -0.006696`) and +0.068571 at `y = 16` (`A_blend = 0.107143`), so the linear zero lies at `y = 12.235`. With the same convention as the top surface above (the first block whose interpolated value is positive is solid) the lowest solid block of the island is `y = 13`.

### 13.2 Island noise and biomes, seed 0 (computed with a reference script; the `outer` column uses 4.3, the biome the rules of 7)

| Block `(x, z)` | `central` at the sample point | `outer` at the sample point | Result |
|---|---|---|---|
| `(0, 0)`, `(16, 0)` (terrain sample) | 0.5625 | -0.84375 | island cone core |
| `(160, 0)` | -0.53125 | -0.84375 | island slope |
| `(800, 0)` | -0.84375 | -0.84375 | void |
| `(1500, 0)` | -0.84375 | -0.1279246 | outer value from the field |
| `(-1200, 900)` | -0.84375 | 0.1752335 | outer island flank |
| `(3000, -1000)` | -0.84375 | 0.3602252 | outer island |
| `(2000, 2000)` | -0.84375 | -0.6070752 | far void |

Biome of a block (chunk-centre sample, 7): `(0, 0)`, `(1023, 0)`, `(1024, 0)`: `the_end` (inside the disc); `(1500, 0)`: erosion value -0.0829359 (sample `(1496, 8)`) gives `end_barrens`; `(-1200, 900)`: 0.1110801 gives `end_midlands`;
`(3000, -1000)`: 0.3602252 gives `end_highlands`; `(1008, 1008)`: -0.1142252 gives `end_barrens`; `(-1200, -900)`: 0.0017004 gives `end_midlands`; `(2000, 2000)`: -0.5320311 gives `small_end_islands`; `(1200, 1200)`: -0.6173931 gives `small_end_islands`;
`(3000, 3000)`: 0.5625 gives `end_highlands`. (The first noise draws at seed 0: `N.get(0, 0) = 0` because the offsets are zero; `N.get(70, 3) = 0.4381723`, `N.get(-66, -70) = 0.4260233`; at seed 12345 `N.get(65, 0) = -0.8321315`.)

### 13.3 Arrival (read values)

A player entering from the Overworld via an end portal ends at `(100.5, 49.0, 0.5)` facing yaw 90 on the obsidian at `y = 48`; blocks `(98..102, 49..51, -2..2)` are air, `(98..102, 48, -2..2)` obsidian (25 blocks).

### 13.4 Flash

For default clock time `t = 1234` (a later window than 0, so parameters are computed) (ticks of the `minecraft:the_end` world clock): `window = 2`, `phase = 34`; the parameters come from `createThreadLocalInstance(2)` (the first float discarded, then `offset` from `nextInt(201)`). The flash is visible only if `offset <= 34 <= offset + duration`; its peak intensity (1.0) is at `phase = offset + duration/2`.

---

## 14. Validation (checkable facts)

1. Dimension type: `min_y 0`, `height 256`, `ambient_light 0.25`, `has_fixed_time` true, `skybox` end, fog `#181318`, sky `#000000`.
2. Noise settings: `noise` `min_y 0` / `height 128`, `sea_level 0`, `default_block end_stone`, `default_fluid air`, `legacy_random_source` true, no aquifers, `disable_mob_generation` true.
3. `end/islands` tree: central island clamp bounds -100 and 80, the constants 100.0, 8.0 and 0.0078125; max with `end_outer_islands`; slice at `y = 0`.
4. `end_outer_islands`: seed = world seed, 17292 skipped `nextInt()`, simplex with zero offsets, threshold -0.9, `4096` radius test, window 25 x 25 cells of 16 blocks (`ox`, `oz` from -12 to 12 inclusive), constants 3439, 147, 13, 9, 100, -100, 80, 8, 128.
5. `final_density`: gradients 4 to 32 and 56 to 312, constants -0.234375 and -23.4375, multiplier 0.64, cells 8 x 4 x 8, no beardifier contribution.
6. Biome source: disc test `sx*sx + sz*sz <= 4096`, sample point `(2 sx + 1) * 8`, thresholds 0.25, -0.0625, -0.21875, biome mapping.
7. The surface rule is `end_stone` and changes no block.
8. Platform arrival `(100.5, 49, 0.5)`, yaw 90; platform 5 x 5 obsidian at `y = 48` with air at `y` 49 to 51 (three layers).
9. Placed features: `end_island_decorated` rarity 14, `end_gateway_return` rarity 700, chorus count 0 to 4.
10. Counts (from the archive with `unzip -Z1 | grep -v '/$'`): the jar holds 3 files under `data/minecraft/worldgen/density_function/end/`, 5 End biome files (`the_end`, `end_highlands`, `end_midlands`, `small_end_islands`, `end_barrens`).

---

## 15. Open questions

1. **Float fidelity of `H`.** The `H` algorithm (4.3) was transcribed from bytecode; the reference script used to produce the examples of 13.2 rounds to single precision at each stated step but was not compared with a game run. Worked values are therefore "computed", not read.
2. **Interpolated corner positions of `S`.** 4.5 states that terrain samples `S` only at multiples of 8 horizontally; the density sampler (`sampleVolume`) builds volumes with a step; the step values were not read separately (the cell sizes come from the JSON `interpolated` node).
3. **Credits.** `showEndCredits` and the `seenCredits` flag (9.2) are only named; the packet and the screen are not covered here (the game-event packet is in 05a/05b, outside this round).
4. **Player respawn** (`findRespawnPositionAndUseSpawnBlock`) is cross-referenced to RS23 and not read here.
5. **End sky details**: which rotation belongs to which cube face, the texture wrap mode and whether `0xFF282828` is multiplied with the texture were not fully read (11). The flash transform order and colour are now read (11 item 4).
6. **End city details**: the structure start's dependence on terrain height and the pieces are in RS20; only the structure and structure-set JSON were read here.
7. **Discrepancy 31 part 5 section 4.2** about which gateway feature has `exact true` (8): the jar's JSON contradicts 31-5; the owner of 31-5 should correct it.
8. **Gateway runtime** (teleport destination search for `exact false`, the "gateway" chunk generation around `(100, 0)`) is 31 part 5 section 4 and was not re-read.
9. **Void and falling**: no End-specific rule was found beyond `checkBelowWorld`; whether the fight's dragon despawns when it leaves the arena was not read.
10. **`cardinalLightType` default.** The `the_end` dimension type JSON has no `cardinal_light` key; the codec default value was not read.
11. **Not read in this round** (recalled, not verified): that `/time` needs a world clock, and that death in the End sends the player to the level respawn position. Searched: only `EndPortalBlock` and the sky classes, not the respawn or command code.
12. **`Entity.canTeleport(level, level)`** refuses the End-to-Overworld move for a passenger player who has not seen the credits; cross-reference RS23, not read here.
13. **The fight controller start** ("when the first valid player is near") was not read (9.1); only the construction call was.
14. **End city placement vs terrain height** (`has_structure/end_city`) is deferred to RS20. The class-level behaviour of `EndSpikeFeature`, `EndGatewayFeature`, `ChorusPlantFeature`, `EndIslandFeature` and `EndPodiumFeature` is only cross-referenced to 35 part 7 sections 8 to 10 and is acceptable only if 35-7 is complete.
