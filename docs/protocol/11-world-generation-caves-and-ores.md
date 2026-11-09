# World generation: caves, carvers, ore veins, ores and decoration

This document specifies the underground half of Java Edition 26.3 world generation for the overworld: the three
noise cave kinds (cheese, spaghetti, noodle) and how they enter the final density, the classic carvers (cave and
canyon), the noise-router ore veins, the ore and blob features (configured feature, placed feature, placement
algorithm), decoration seeding and chunk-border rules, and the drops of the ore blocks. It is written in prose, tables
and formulas only. Terrain shaping, density-function operators, noise primitives, interpolation, aquifers and surface
rules belong to [10-world-generation-terrain.md](10-world-generation-terrain.md); this document cites it as "10 §n" and says
explicitly where it relies on it.

| Item | Value |
|---|---|
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap`) and of the data-generated JSON under `data/minecraft/` in the jar, with no execution. The class names are not obfuscated. |
| Scope | Overworld only (`worldgen/noise_settings/overworld.json`, the `minecraft:overworld` biome source). Nether and End carvers and ores are not specified. |
| Operator decision | Worlds generated nearly identical to vanilla (ticket CC-0001, "worlds generated like vanilla's"). |

Conventions. "Float" means IEEE single precision, "double" means IEEE double precision; where a step says float, an
implementation that wants vanilla-identical caves must round to single precision at that step. World height is
`minY = -64`, `height = 384` (so the top block is y = 319), `seaLevel = 63`. A vertical anchor in a JSON file resolves
as: `{"absolute": n}` is n; `{"above_bottom": n}` is `-64 + n`; `{"below_top": n}` is `319 - n`. Values marked
"(inferred)" were deduced rather than read directly. Worked examples marked "(computed)" were calculated by applying
the rules in this document, not observed from running the artifact.

## 1. Where these systems run

The stage order, the chunk statuses and their neighbour requirements are specified in 10 §11.1; the fill is 10 §8.1, the
aquifer 10 §9 and the surface rules 10 §10. This document adds what the carvers and features need on top of them:

| # | Stage | What matters here |
|---|---|---|
| 1 | Fill (`doFill`, 10 §8.1) | The final density is sampled over the chunk; where it is above 0 the block is the default block (stone), otherwise the aquifer decides air, water or lava (10 §9.2). Cheese, spaghetti and noodle caves exist only as non-positive regions of this density (§2). |
| 2 | Surface (`buildSurface`, 10 §10.1) | The material rule `minecraft:overworld` is applied to every non-air, non-fluid block of each column. It is a sequence: bedrock floor, **copper ore vein, iron ore vein** (§3), then the surface rule (which runs only above the preliminary surface, `above_preliminary_surface`, 10 §10.9), then the deepslate transition (10 §10.5, §10.9). The first rule that returns a block wins, so a vein block overrides the surface block at the same position. |
| 3 | Carvers (`generateCarvers`) | The classic cave and canyon carvers (§5) mark positions in a carving mask, which is then applied. Carvers therefore run after the surface rules and after ore veins. |
| 4 | Features (`applyBiomeDecoration`) | Ores, blobs and everything else are placed (§6, §7, §8). |

Stages 1 to 3 are the chunk status `TERRAIN` (write radius 0), stage 4 is `FEATURES`, which requires every chunk within radius 1
to have reached `TERRAIN` and may write blocks in the 3x3 chunks around the chunk being decorated (write radius 1) (10 §11.1,
§11.2; §6.5 here).

## 2. Caves in the noise router

`worldgen/noise_settings/overworld.json` names the router functions `final_density`, `continents`, `erosion`,
`ridges`, `temperature`, `vegetation`, `depth`, `chunk_surface_level`; there is no separate "noise caves" object. The
caves live inside `minecraft:overworld/final_density` and in the helper functions under
`worldgen/density_function/overworld/caves/`. Density above 0 is solid, 0 or below is open.

### 2.1 Structure of final density

Using the operator names of 10 §4.2 (`add`, `min`, `max`, `mul`, `lerp`, `gradient`, `range_choice`, `interpolated`,
`squeeze`, `blend_density`, `cache`, `clamp`, `abs`, `square`, `cube`, `interval_select`, `noise`):

```
final_density = min( squeeze( interpolated[4,8]( blend_density( BASE ) * 0.64 ) ), caves/noodle ) + beardifier
BASE          = lerp( gradient_y(-64 -> 0, -40 -> 1),  0.1171875,
                      lerp( gradient_y(240 -> 1, 256 -> 0),  -0.078125,  CAVE_STAGE ) )
```

`lerp(alpha, first, second)` yields `first` at alpha 0 and `second` at alpha 1; a `gradient` clamps outside its
two coordinates. So below y = -40 the density blends toward the constant 0.1171875 (a solid floor: the cheese,
spaghetti and entrance caves fade out toward y = -64, only noodles and carvers still cut there), above y = 240 it blends
to the constant -0.078125 (open air at y >= 256), and `CAVE_STAGE` applies in between. (`blend_density`: 10 §4.2.) `interpolated[4,8]` means the argument is evaluated on the
4 (x,z) by 8 (y) cell lattice and trilinearly interpolated (10 §4.1).

```
CAVE_STAGE = range_choice( input = overworld/sloped_cheese,  [-1000000, 1.5625) )
    in range  (near the surface):  min( sloped_cheese,  caves/entrances * 5 )
    out of range (deep solid):     max( min( min( CHEESE, caves/entrances ),  caves/spaghetti_2d + caves/spaghetti_roughness_function ),
                                         PILLARS )
CHEESE  = 4 * square( noise cave_layer[xz 1, y 8] )
          + clamp( noise cave_cheese[xz 1, y 0.6666667] + 0.27, -1, 1 )
          + clamp( sloped_cheese * -0.64 + 1.5, 0, 0.5 )
PILLARS = range_choice( input = caves/pillars, [-1000000, 0.03) ):  in range -> -1000000, otherwise -> caves/pillars
```

`sloped_cheese` is the terrain density (10 §6.2). It is below 1.5625 near the surface and above it deep inside rock, so
only `entrances` (and the terrain itself) can open the surface layer. Cheese and spaghetti 2D are deep-rock only; spaghetti 3D acts
through `entrances` (so it also reaches the near-surface branch); noodles are a separate term with their own y range (-60..320, §2.5). A value of `CHEESE` (or the spaghetti sum, or `entrances`) at or below 0 makes the block open, because the
outer `min` takes the smallest; `PILLARS` raises the result back above 0 by the `max` where a pillar exists.

The `noodle` term is outside the `squeeze(interpolated(...))` part and applies at all depths in its y range (§2.5).

### 2.2 Cheese caves (large caverns)

Two noises. `cave_layer` (sampled with y scale 8, so it varies fast vertically) squared times 4 creates
horizontally layered cavern floors and ceilings; `cave_cheese` (xz scale 1, y scale 0.6666667) plus 0.27, clamped to
[-1, 1], is the cavern body; the third term, `clamp(-0.64 * sloped_cheese + 1.5, 0, 0.5)`, adds up to 0.5 of
solidity close to the terrain surface and nothing once `sloped_cheese >= 2.34375`, so caverns thin out toward the
surface. A cheese cavern is open where the sum `CHEESE` is at most 0 and the min with `entrances` and the spaghetti
sum does not raise it; since `4 * cave_layer^2 >= 0` and the third term is `>= 0`, an open block needs
`clamp(cave_cheese + 0.27, -1, 1) <= -(the other two)`; in the deepest rock (third term 0, `cave_layer` near 0) that
is `cave_cheese <= -0.27`.

### 2.3 Spaghetti caves (long winding tunnels)

Two families, both inside the deep-rock `max/min` chain above.

**Spaghetti 3D** is the second operand of `caves/entrances`:

```
SPAG3D = spaghetti_roughness_function
       + clamp( max( | pick1 | , | pick2 | ) + ( spaghetti_3d_thickness * -0.011500001 + -0.0765 ),  -1, 1 )
pick_k = interval_select( input = cache( noise spaghetti_3d_rarity[xz 2, y 1] ),  thresholds [-0.5, 0.0, 0.5] )
         selects (the others are not evaluated):
           input <  -0.5          : noise spaghetti_3d_k[xz 1.3333333, y 1.3333333] * 0.75
           -0.5 <= input < 0.0    : noise spaghetti_3d_k[xz 1, y 1]                 * 1.0
            0.0 <= input < 0.5    : noise spaghetti_3d_k[xz 0.6666667, y 0.6666667] * 1.5
            0.5 <= input          : noise spaghetti_3d_k[xz 0.5, y 0.5]            * 2.0
```

for k = 1 and 2 (noises `spaghetti_3d_1`, `spaghetti_3d_2`). `interval_select` (read from `IntervalSelectFunction`, both its general and its single-threshold sampler) evaluates the input and then only the selected function: the
first function `i` whose `thresholds[i]` is strictly greater than the input, or the last function when the input is at or above every threshold.
`squeeze` is `c/2 - c^3/24` with `c = clamp(v, -1, 1)`; `range_choice` takes `when_in_range` for `min_inclusive <= v < max_exclusive` (10 §4.2). The
tunnel is the set where both |pick1| and |pick2| are small; the tube thickness is the constant
`0.0765 + 0.0115 * spaghetti_3d_thickness` (about 0.065 to 0.088 in noise units). The rarity noise changes the scale
of both picks (smaller scale gives wider, lazier tunnels), which is why tunnel width varies from region to region.

**Spaghetti 2D** (flat, sheet-like tunnels at a varying altitude), also a `max/min` operand:

```
SPAGHETTI_2D = clamp( max( | interval_select(input = noise spaghetti_2d_modulator[xz 2, y 1],
                                              thresholds [-0.75, -0.5, 0.5, 0.75]) |  +  THICKMOD * 0.083 ,
                           cube( | cache( noise spaghetti_2d_elevation[xz 1, y 0] * 8 )
                                     + gradient_y(-64 -> 8.0, 320 -> -40.0) | + THICKMOD ) ),
                      -1, 1 )
THICKMOD     = cache( noise spaghetti_2d_thickness[xz 2, y 1] * -0.34999996 + -0.95 )
interval_select functions (5, in this order):
    noise spaghetti_2d[xz 2, y 2] * 0.5 ;  [1.3333333] * 0.75 ;  [1] * 1.0 ;  [0.5] * 2.0 ;  [0.3333333] * 3.0
```

The first operand of `max` is the thin 2D tube (an `abs` of the selected spaghetti noise plus a thickness term);
the second is a vertical "distance from the elevation surface" term: the elevation noise has y scale 0, so it is a
function of x and z only (a wobbling altitude, times 8) added to a linear slope that goes from +8 at y = -64 to -40
at y = 320; the cube of its absolute value plus `THICKMOD` is small only close to that altitude. The result is
open only close to the elevation surface and inside the tube, i.e. a sheet cave whose altitude depends on (x, z).

**Roughness** (`caves/spaghetti_roughness_function`), added to both spaghetti kinds:

```
spaghetti_roughness_function = cache( (noise spaghetti_roughness_modulator * -0.05 + -0.05) * ( | noise spaghetti_roughness | + -0.4 ) )
```

(both noises xz 1, y 1). It is a small bumpy term (about +/-0.04) that roughens tunnel walls.

### 2.4 Cave entrances

`caves/entrances` is

```
cache( min( noise cave_entrance[xz 0.75, y 0.5] + 0.37 + gradient_y(-10 -> 0.3, 30 -> 0.0),
            SPAG3D ) )
```

It is the only cave function that also acts near the surface (§2.1: `entrances * 5` in the near-surface branch). The
cave_entrance noise gives wide open mouths, whose threshold rises as y drops below 30 (the gradient adds up to 0.3
at y <= -10, i.e. makes them rarer deep down), and `SPAG3D` supplies the tunnels that connect to them.

### 2.5 Noodle caves (thin passages)

`caves/noodle` is applied outside the squeezed terrain: `final_density = min( terrain_with_caves, noodle ) + beardifier`.

```
noodle = range_choice( input = interpolated[4,8]( YGATE( noise noodle[xz 1, y 1] , else -1 ) ),  [-1000000, 0.0) )
   in range   (noodle noise < 0)  : 64.0                        (a large positive value: solid, no effect on the min)
   out of range                   : interpolated[4,8]( YGATE( noise noodle_thickness * -0.025 + -0.075 , else 0 ) )
                                    + 1.5 * max( | interpolated[4,8]( YGATE( noise noodle_ridge_a[xz 2.6666667, y 2.6666667] , else 0 ) ) | ,
                                                 | interpolated[4,8]( YGATE( noise noodle_ridge_b[xz 2.6666667, y 2.6666667] , else 0 ) ) | )
YGATE(f, other) = range_choice( input = y, [-60, 321) ): in range -> f, else -> other
```

So noodles exist only for -60 <= y < 321 (y <= 320), and only in the region where the `noodle` noise is at least 0
(roughly half of the world). In that region the value is
`-(0.075 + 0.025 * t) + 1.5 * max(|ridge_a|, |ridge_b|)` with `t = noodle_thickness` in about [-1, 1], and the block
is open where this is <= 0, i.e. where `max(|ridge_a|, |ridge_b|) <= (0.075 + 0.025 * t) / 1.5`. That bound is
between 0.0333 (t = 1) and 0.0667 (t = -1) in noise units, a thin tube around the zero set of both ridge noises.
All four noise samples are interpolated on the 4x8 cell lattice; this is what makes them thin and slightly blocky.

### 2.6 Pillars

`caves/pillars = cache( ( noise pillar[xz 25, y 0.3] * 2 + ( noise pillar_rareness * -1 + -1 ) ) * cube( noise pillar_thickness * 0.55 + 0.55 ) )`.
Where this value is at least 0.03 it is the `max` operand in §2.1 and forces the cheese/spaghetti region solid
(rock pillars inside caverns); below 0.03 it is replaced by -1000000 and has no effect.

### 2.7 Noise parameters used by the caves and ore veins

The `worldgen/noise/*.json` fields (`base_octave`, `octave_count` default 1, `base_amplitude`, `amplitude_modifiers`, normalisation) are defined in
10 §3.3, and the values of every noise used here (`cave_cheese`, `cave_entrance`, `cave_layer`, `pillar*`, `noodle*`, `spaghetti_*`,
`ore_veininess`, `ore_vein_a`, `ore_vein_b`, `ore_gap`) are tabulated in 10 §3.6; this document does not repeat them. Each noise is created from
the world seed by name (10 §2.5, §3.3). The sampling scales in the formulas above are the `xz_scale` and `y_scale` of the `noise` density-function
node (the position is multiplied by them before the lookup; 10 §4.2).

### 2.8 Thresholds, in one place

| Kind | Open where | Y range | Notes |
|---|---|---|---|
| Cheese | `4*cave_layer^2 + clamp(cave_cheese + 0.27, -1, 1) + clamp(1.5 - 0.64*sloped_cheese, 0, 0.5) <= 0` and the other chain members not smaller | deep rock only (`sloped_cheese >= 1.5625`), floor blend fades it out below y = -40 | In the deepest rock this is `cave_cheese <= -0.27`. |
| Spaghetti 3D | `SPAG3D <= 0`, i.e. both picks within `0.0765 + 0.0115 * spaghetti_3d_thickness` of 0 (before the small roughness term) | everywhere the final-density blend allows | Also the connector of cave entrances. |
| Spaghetti 2D | `SPAGHETTI_2D + roughness <= 0` | deep rock only | Altitude set by `spaghetti_2d_elevation`. |
| Noodle | `max(|ridge_a|,|ridge_b|) <= (0.075 + 0.025*t)/1.5` and `noodle >= 0` | -60 <= y <= 320 | Not limited to deep rock. |
| Entrance | `cave_entrance + 0.37 + gradient <= 0` (or SPAG3D) | any y; `entrances*5` also in the near-surface branch | Rarer below y = -10. |

## 3. Ore veins (noise-router veins of copper and iron)

Ore veins are material-rule entries, not features. `worldgen/material_rule/overworld.json` lists, in order:
`bedrock_floor`, `overworld/copper_ore_vein`, `overworld/iron_ore_vein`, then the surface rule, then `underground`.

| Vein | `ore_block` | `raw_ore_block` | `filler_block` | `raw_ore_chance` | Density function |
|---|---|---|---|---|---|
| Copper | `copper_ore` | `raw_copper_block` | `granite` | 0.02 | `overworld/ore_vein/copper_density`, y in [0, 50) |
| Iron | `deepslate_iron_ore` | `raw_iron_block` | `tuff` | 0.02 | `overworld/ore_vein/iron_density`, y in [-60, -8) |

Both use the shared functions `ore_vein/richness` and `ore_vein/gap`.

### 3.1 The vein functions

```
toggle  T = cache( interpolated[4,8]( range_choice(y in [-64, 57): noise ore_veininess[xz 1.5, y 1.5],  else 0) ) )
mask    M = cache( range_choice( input T, [-0.4, 0.4) ):
              in range     -> -1
              out of range -> 0.08 - max( | interpolated[4,8]( range_choice(y in [-64,57): noise ore_vein_a[xz 4, y 4], else 1.0) ) | ,
                                          | interpolated[4,8]( range_choice(y in [-64,57): noise ore_vein_b[xz 4, y 4], else 1.0) ) | ) )
richness R = clamp( | T | , 0.4, 0.6 ) * 1.0 + -0.3                    (0.1 at |T| = 0.4, 0.3 at |T| >= 0.6)
gap     G = -0.3 - noise ore_gap[xz 1, y 1]
copper_density = y in [0,50)    ? ( M in [0, 1e6)  ? ( (T - 0.4) + (clamp(min(50 - y, y - 0),    0, 20) * 0.01 - 0.2) >= 0 ? 0.7 : -1 ) : -1 ) : -1
iron_density   = y in [-60,-8)  ? ( M in [0, 1e6)  ? ( (-T - 0.4) + (clamp(min(-8 - y, y + 60), 0, 20) * 0.01 - 0.2) >= 0 ? 0.7 : -1 ) : -1 ) : -1
```

(The `? :` notation here stands for `range_choice`; "in range" includes the lower bound and excludes the upper.)
So a vein cell needs `|T| >= 0.4` (the toggle sign picks the metal: positive T copper, negative T iron), the two
vein noises both small (`M >= 0` means `max(|a|, |b|) <= 0.08`, a thin worm-like tube), and the edge roundoff to pass:
the bracket `clamp(...) * 0.01 - 0.2` is -0.2 at the vein's top and bottom faces and rises to 0 for the 20 blocks
nearest the middle of the y range, so the toggle must exceed 0.6 at the faces and only 0.4 in the middle. The result
of the density function is therefore 0.7 (inside a vein) or -1 (outside).

`T`, `M`, the two `ore_vein_*` samples and the richness are `interpolated`/`cache` nodes: they are evaluated for the
chunk over the 4x8 cell lattice and trilinearly interpolated, and the rule reads the interpolated value at each block
(10 §4.1, §6.5). `G` is evaluated directly at the block position, not interpolated.

### 3.2 What the rule does at one block

At each solid block that reaches the rule (§1 stage 2):

1. Read the vein density `d` at the block. If `d <= 0` the rule returns nothing (the next rule runs).
2. Take a random source from the positional factory named `minecraft:ore` (§4) at the
   block coordinates (x, y, z). All draws below use this one source in this order.
3. Draw a float `f1`. If `f1 > d` (that is, with probability 0.3 since d = 0.7) the block is left to the next rule (no
   ore, no filler).
4. Read richness `R`. Draw a float `f2`. If `f2 < R` and `G < 0` (that is `ore_gap > -0.3`): draw a float `f3`; the
   block becomes `raw_ore_block` if `f3 < 0.02`, otherwise `ore_block`. The `G` check is made after `f2` is drawn
   (so `f2` is always consumed), and `f3` is drawn only on this branch.
5. Otherwise the block becomes `filler_block`.

Result: inside a vein tube, 70% of cells are replaced; of those, `R` (10% to 30%) are ore (2% of which are raw-metal
blocks) and the rest granite (copper) or tuff (iron). Veins are rare large worms of mostly filler with ore speckles.

## 4. Random primitives this document relies on

The generators and positional factories are specified in 10 §2.1-2.6: Xoroshiro128++ and its seeding (10 §2.1, §2.2), the derived operations
`nextInt`, `nextFloat`, `nextDouble` (10 §2.3), positional factories, `fromHashOf` and `getSeed` (10 §2.4), the root and named factories (10 §2.5)
and the Java LCG (10 §2.6). The named factory `minecraft:ore` of §3.2 is `P.fromHashOf("minecraft:ore").forkPositional()` (10 §2.5 item 5). The
carvers use the **Java LCG**; reference values: seed 0 gives `nextInt()` = -1155484576, `nextLong()` = -4962768465676381896, `nextFloat()` = 0.7309678.
The rest of this section adds what 10 does not give: the `WorldgenRandom` wrapper, the seeding helpers, the table trigonometry, and the value and height providers.

**`WorldgenRandom`** wraps another source. `setSeed` re-seeds the wrapped source. Its `next(bits)` is the wrapped
LCG's `next` when the wrapped source is the Java LCG; for a Xoroshiro-wrapped instance it is `(int)(wrapped.nextLong()
>>> (64 - bits))`. Its `nextInt(n)`, `nextFloat`, `nextDouble`, `nextLong` are the Java-LCG definitions above built on that `next`
(they are not overridden), so a Xoroshiro-wrapped `WorldgenRandom` consumes one Xoroshiro `nextLong` per `next` call: `nextInt(n)` is the Java-LCG
algorithm on `next(31)` (not the Xoroshiro multiply-high method), `nextLong()` is two such draws (`next(32) << 32` plus `next(32)`, i.e. the high halves of two
Xoroshiro outputs), and `nextDouble()` is two draws (`next(26)`, `next(27)`). For a `WorldgenRandom` that wraps the Java LCG, `next` is exactly the LCG's. (This supplements 10 §2.6 and 10 §15 item 8: 10 describes the wrapper over a legacy source, which is what the carvers use; decoration instead wraps a Xoroshiro source, and the rule above is how that case behaves.)
Seeding helpers used in this document:

| Helper | Definition |
|---|---|
| `setLargeFeatureSeed(s, cx, cz)` | `setSeed(s)`; `a = nextLong()`; `b = nextLong()`; `setSeed( (cx * a) XOR (cz * b) XOR s )` (64-bit products). Used by the carvers on a Java-LCG-wrapped instance. |
| `setDecorationSeed(s, bx, bz)` | `setSeed(s)`; `a = nextLong() OR 1`; `b = nextLong() OR 1`; `r = (bx * a + bz * b) XOR s`; `setSeed(r)`; returns r. Used by decoration on a Xoroshiro-wrapped instance. |
| `setFeatureSeed(d, index, step)` | `setSeed( d + index + 10000 * step )` (64-bit). |

**Trigonometry.** Vanilla uses a lookup table: `sin(x) = TABLE[(long)(x * 10430.378350470453) AND 65535]` and
`cos(x) = TABLE[((long)(x * 10430.378350470453 + 16384.0)) AND 65535]`, with `TABLE[i] = (float) Math.sin(i /
10430.378350470453)` (the table fill formula was read from the table-building loop: divisor 10430.378350470453, cast to float; the sample count 65536 and the masks were read directly; the table values themselves were not compared), result float. The carvers use
this `sin`/`cos`; the ore feature uses `Math.sin`/`Math.cos` (double) for the blob axis and the table `sin` for the
ball radii (§7.1).

**Value providers.** `uniform` float: `nextFloat() * (max - min) + min` (float arithmetic). `trapezoid` float
(`min`, `max`, `plateau`): `range = max - min`, `slopeWidth = (range - plateau) / 2`, `slope = range - slopeWidth`; value =
`min + nextFloat() * slope + nextFloat() * slopeWidth` (draw order as written). `uniform` int (inclusive bounds): `min +
nextInt(max - min + 1)`. `very_biased_to_bottom` int (inclusive bounds): `a = nextInt(max - min + 1)`, `b = nextInt(a +
1)`, `c = nextInt(b + 1)`, value `min + c`. `constant` consumes no random numbers.

**Height providers** (for `y` fields; anchors resolved first, `lo`/`hi` inclusive). `uniform`: if `lo > hi` return `lo`
(no draw), else `lo + nextInt(hi - lo + 1)`. `trapezoid` with `plateau` (default 0, in all ore files): `range = hi - lo`; if
`plateau >= range` act as uniform (read: the normal branch is taken only when `plateau < range`, so `plateau == range` is the uniform case and draws one `nextInt(range + 1)`); else `slopeWidth = (range - plateau) / 2` (integer division), `slope = range -
slopeWidth`; value = `lo + nextInt(slope + 1) + nextInt(slopeWidth + 1)` (two draws, in that order). The triangle peaks at
`(lo + hi) / 2` and is 0 at both ends. For `plateau = 0` and `hi - lo` even the two draws are uniform on [0, range/2].

## 5. Classic carvers (cave and canyon)

### 5.1 Configured carvers

`worldgen/carver/*.json`, overworld ones (the nether cave carver is not specified here):

| Carver | `type` | `probability` | `y` (uniform, inclusive) | Other parameters |
|---|---|---|---|---|
| `minecraft:cave` | cave | 0.15 | above_bottom 8 .. absolute 180 (-56 .. 180) | `count` very_biased_to_bottom 0..14; `floor_level` uniform [-1.0, -0.4); `horizontal_radius_multiplier` uniform [0.7, 1.4); `vertical_radius_multiplier` uniform [0.8, 1.3); `room_vertical_radius_multiplier` uniform [0.1, 0.9); `thickness` trapezoid min 0, max 3, plateau 1; `weird_thickness_bias` true; `start_vertical_radius_multiplier` absent (default constant 1.0) |
| `minecraft:cave_extra_underground` | cave | 0.07 | above_bottom 8 .. absolute 47 (-56 .. 47) | same as `cave` except the `y` range |
| `minecraft:canyon` | canyon | 0.01 | absolute 10 .. absolute 67 (uniform) | `vertical_rotation` uniform [-0.125, 0.125); shape: `distance_factor` uniform [0.75, 1.0), `horizontal_radius_factor` uniform [0.75, 1.0), `thickness` trapezoid 0..6 plateau 2, `vertical_radius_center_factor` 0.0, `vertical_radius_default_factor` 1.0, `width_smoothness` 3, `y_scale` 3.0 |

Both carver types have `getRange()` = 4 (chunks): the walk length is limited to `(4*2 - 1) * 16 = 112` blocks (see
below), and chunk generation considers every source chunk within 8 chunks of the chunk being generated. The `probability` fields are chances per
source chunk. Every biome that has carvers uses the list `[cave, cave_extra_underground, canyon]` in that order,
except the Nether and End biomes. The biomes are in §8.5.

### 5.2 Which carvers, and in which order

For the chunk T being generated, and for every source chunk S = (T.x + dx, T.z + dz) with dx from -8 to 8 (outer loop)
and dz from -8 to 8 (inner loop):

1. The carver list is that of the biome found by the biome source (the climate lookup of 10 §7.1-7.3, read at the stored noise-biome resolution, 10 §7.6; not the fuzzy zoom of 10 §7.7) at the **noise-biome
   position of S's lowest corner**: quart coordinates `(S.minBlockX >> 2, 0, S.minBlockZ >> 2)`, i.e. y quart 0
   (block y 0 to 3). It is one biome per source chunk, not per block.
2. For each carver in the list, with `i` its zero-based position in the list (0 cave, 1 cave_extra_underground, 2
   canyon), a Java-LCG `WorldgenRandom` is seeded with `setLargeFeatureSeed(worldSeed + i, S.x, S.z)`.
   `i` increments for every carver in the list, whether or not it starts.
3. `isStartChunk`: draw `nextFloat()`; the carver runs when the value is `<= probability`.
4. If it runs, the carver's `carve` method (§5.3, §5.4) is called with this same random source, continuing from the
   draw in step 3, and marks positions of the **target** chunk T in a carving mask.

The `worldSeed` here is the numeric world seed (not hashed, not a Xoroshiro derivative). The same S and the same
seed always produce the same carve geometry, whichever chunk T is being generated: neighbouring chunks therefore
agree on cave shapes across chunk borders.

### 5.3 Cave carver

Per source chunk S that passes step 3:

1. `count = very_biased_to_bottom(0, 14)` sample (3 draws, §4); the mean is 1.75 and the value is 0 with probability about 0.42 (computed).
2. For each of the `count` caves, in order, draw:
   1. `x = S.minBlockX + nextInt(16)`;
   2. `y` = the `y` height provider (uniform; one `nextInt`);
   3. `z = S.minBlockZ + nextInt(16)`;
   4. `hMul` (horizontal radius multiplier, one float draw);
   5. `vMul` (vertical radius multiplier, one float draw);
   6. `yScaleStart` (`start_vertical_radius_multiplier`, constant 1.0, no draw);
   7. `floor` (floor level, one float draw);
   the skip rule uses `floor` (below).
3. `tunnels = 1`. Draw `nextInt(4)`; if it is 0 the cave has a **room**:
   1. `roomV` = room vertical radius multiplier (one float draw);
   2. `roomR = 1.0 + nextFloat() * 6.0` (float);
   3. carve one ellipsoid at `(x + 1.0, y, z)` with horizontal radius `1.5 + roomR` and vertical radius `(1.5 + roomR) * roomV`
      (the sin(pi/2) factor is 1.0 in the table; the `hMul` is not applied to a room);
   4. `tunnels = tunnels + nextInt(4)` (one more draw).
4. For each tunnel in `0 .. tunnels - 1`, draw in this order: `yaw = nextFloat() * 6.2831855` (float); `pitch = (nextFloat()
   - 0.5) / 4.0` (float); `thickness` (the thickness provider: trapezoid 0, 3, plateau 1 (two float draws); then `if
   nextInt(10) == 0` multiply thickness by `(nextFloat() * nextFloat() * 3.0 + 1.0)` - the "weird thickness bias",
   two more draws only in that case); `maxSteps = 112 - nextInt(112 / 4)`, i.e. `112 - nextInt(28)`; then draw one `nextLong()`
   as the seed of the tunnel walker and run the walker (§5.3.1) with start step 0, the cave's x, y, z, `hMul`, `vMul`,
   `thickness`, `yaw`, `pitch`, `maxSteps` and `yScale = yScaleStart`.

#### 5.3.1 Tunnel walker

A new Java-LCG source is created from the tunnel seed (a `SingleThreadedRandomSource`; same LCG). Constants used:
`range = 4`, `L = (2*range - 1) * 16 = 112`. Before the loop, draw `branchStep = nextInt(maxSteps / 2) + maxSteps / 4` (integer
division) and `steep = (nextInt(6) == 0)`. Two float state variables start at 0: `dPitch` and `dYaw`. For `step` from
`startStep` up to `maxSteps - 1`:

1. `r = 1.5 + sin(pi * step / maxSteps) * thickness` (float sine, double sum); `rv = r * yScale`.
2. `cp = cos(pitch)` (table cosine, float). Move: `x += cos(yaw) * cp`; `y += sin(pitch)`; `z += sin(yaw) * cp` (each term
   computed in float then added as double).
3. `pitch *= (steep ? 0.92 : 0.7)`; `pitch += dPitch * 0.1`; `yaw += dYaw * 0.1`; `dPitch *= 0.9`; `dYaw *= 0.75`;
   `dPitch += (nextFloat() - nextFloat()) * nextFloat() * 2.0`; `dYaw += (nextFloat() - nextFloat()) * nextFloat() * 4.0`
   (six draws, in the order written, with `dPitch` first).
4. If `step == branchStep` and the tunnel's initial `thickness > 1.0`: draw `nextLong()` and `nextFloat()` for the first branch and
   `nextLong()` and `nextFloat()` for the second; each branch is a new walker with a fresh seed, the same x, y, z, `hMul`, `vMul`, the
   branch thickness `nextFloat() * 0.5 + 0.5`, yaw `yaw -/+ pi/2` (first minus, second plus, using `1.5707964`), pitch `pitch / 3.0`,
   the same `step` as start step, the same `maxSteps` and `yScale = 1.0`; then **this walker ends** (returns). The draws happen
   in the order seed1, thickness1 (branch 1 runs in full), then seed2, thickness2 (branch 2 runs in full).
5. If `nextInt(4) == 0`, skip carving for this step (go to the next step).
6. If the walker can no longer reach the target chunk T (the `canReach` test below), the walker ends.
7. Otherwise carve an ellipsoid (§5.5) at the current (x, y, z) with horizontal radius `r * hMul` and vertical radius `rv * vMul`.

`canReach(T, x, z, step, maxSteps, thickness)`: with `(mx, mz)` the middle block of T (minBlock + 8), `dx = x - mx`,
`dz = z - mz`, `left = maxSteps - step`, `reach = (double)(thickness + 2.0 + 16.0)`, it is true when `dx*dx + dz*dz - left*left <= reach*reach`.

The carve skip test for the cave carver (applied inside the ellipsoid loop, §5.5): with normalised offsets `(xd, yd, zd)`, a
block is **skipped** when `yd <= floor` or when `xd*xd + yd*yd + zd*zd >= 1`. The `floor` value is in [-1.0, -0.4): the
bottom 0 to 30 percent of every ellipsoid is cut flat, so cave floors are flat.

### 5.4 Canyon carver

Per source chunk S that passes step 3 (one canyon per start, no count):

1. Draw `x = S.minBlockX + nextInt(16)`; `y` = the height provider (uniform 10..67, one `nextInt`); `z = S.minBlockZ + nextInt(16)`; `yaw =
   nextFloat() * 6.2831855`; `pitch` = `vertical_rotation` (uniform float); `yScale = y_scale.sample()` (constant 3.0);
   `thickness` = shape thickness (trapezoid 0..6 plateau 2, two draws); `maxSteps = (int)(112 * distance_factor sample)`;
   then one `nextLong()` as the walker seed.
2. Width factors: with the walker's own source, build an array of `384` floats indexed `0 .. 383` (one per y layer above
   `minY`): `f = 1.0`; for index `i` from 0: if `i == 0` or `nextInt(width_smoothness = 3) == 0`, `f = 1.0 + nextFloat() *
   nextFloat()`; store `f*f` (the `i == 0` case draws no `nextInt`). The factors are generated before the walk.
3. For `step` from 0 to `maxSteps - 1`:
   1. `r = 1.5 + sin(pi * step / maxSteps) * thickness`; `rv = r * yScale`.
   2. `r = r * horizontal_radius_factor` (one float draw); then `rv = (vertDefault + vertCenter * t) * rv * randomBetween(0.75, 1.0)`
      where `t = 1.0 - | 0.5 - step / maxSteps | * 2.0` (float; vertDefault 1.0, vertCenter 0.0, so the multiplier is
      1.0) and `randomBetween` is one float draw.
   3. `cp = cos(pitch)`; `x += cos(yaw) * cp`; `y += sin(pitch)`; `z += sin(yaw) * cp`.
   4. `pitch *= 0.7`; `pitch += dPitch * 0.05`; `yaw += dYaw * 0.05`; `dPitch *= 0.8`; `dYaw *= 0.5`; `dPitch += (nextFloat() - nextFloat()) *
      nextFloat() * 2.0`; `dYaw += (nextFloat() - nextFloat()) * nextFloat() * 4.0`.
   5. If `nextInt(4) == 0`, skip carving for this step.
   6. If `canReach` (as in §5.3.1, with this canyon's `thickness`) is false, end the walk.
   7. Carve an ellipsoid at (x, y, z) with radii `(r, rv)` and the canyon skip test.
4. The canyon skip test for a block at world y: let `idx = y - minY(-64)`; skip when `(xd*xd + zd*zd) * widthFactor[idx - 1] +
   yd*yd / 6.0 >= 1.0`. The per-layer factor gives the canyon its ragged walls; the `yd*yd/6` term makes the canyon a tall
   slot (vertical radius = 3 x the horizontal one, then divided by sqrt(6) by the test).

A canyon therefore starts in about 1 chunk in 100, at y 10 to 67, 84 to 111 blocks long (`112 * [0.75, 1.0)`), with a horizontal
radius of 1.5 at the ends and `1.5 + thickness` (up to 7.5) at the middle, each step then multiplied by a factor in [0.75, 1.0).

### 5.5 The ellipsoid and the carving mask

`carveEllipsoid(T, cx, cy, cz, hR, vR, skip)` marks positions of the target chunk T in the carving mask:

1. Return at once when `| cx - T.middleX | > 16 + hR * 2` or `| cz - T.middleZ | > 16 + hR * 2` (T.middle is `minBlock + 8`).
2. Bounds (blocks; the first two relative to T): `xLo = max(floor(cx - hR) - T.minX - 1, 0)`, `xHi = min(floor(cx + hR) - T.minX,
   15)`, the same for z; `yLo = max(floor(cy - vR) - 1, maskMinY)`, `yHi = min(floor(cy + vR) + 1, maskMaxY)`, with
   `maskMinY = -63` and `maskMaxY = 312` (`minY + 1` and `minY + height - 1 - 7`).
3. For each (x, z) in the bounds, `xd = (blockX + 0.5 - cx) / hR`, `zd = (blockZ + 0.5 - cz) / hR`; skip the column when `xd*xd +
   zd*zd >= 1`. For each y from `yHi` down to `yLo + 1` (so `y > yLo`; the lowest carvable y is -62): `yd = (y - 0.5 - cy) / vR`;
   unless the carver's skip test (§5.3.1, §5.4) says skip, mark (x, z, y) in the mask.

The mask only records positions; no block changes yet.

### 5.6 Applying the mask

After all 17 x 17 source chunks and their carvers are processed, every marked position is visited **column by column**:
the marks are scanned in increasing index (read from `CarvingMask`; index = `(y - maskMinY) + (z + 16 * x) * maskHeight`, with `maskHeight = maskMaxY - maskMinY + 1 = 312 - (-63) + 1 = 376`), contiguous runs of
marked y in one (x, z) column are each processed from the highest y of the run downward:

1. A block whose state is in the block tag `minecraft:uncarvable` (the tag contains only `minecraft:bedrock`) is skipped.
2. If the block is `grass_block` or `mycelium`, remember "grassy" for the rest of this run.
3. The replacement is whatever the aquifer returns for this position with density 0.0: `computeSubstance(x, y, z, 0.0)`
   (10 §9.2). If it returns nothing (a barrier), the block is left as it is. Otherwise the block is replaced by the returned
   state (air, water or lava). The cases that this document pins down:
   - the **global fluid** at (x, y, z) is lava when `y < min(-54, seaLevel)`, i.e. `y <= -55`; at `y < 63` otherwise it is water;
     above, air; a global fluid at level L covers `y < L`;
   - if `y` is above the aquifer's `skipSamplingAboveY` (10 §9.4), the result is simply the global fluid at that y (air above sea level, water at or below y = 62 in the open);
   - if the global fluid at y is lava, the result is lava, whatever the aquifers say;
   - otherwise the per-cell aquifer computation (10 §9.2, §9.3) can return air, water, lava or nothing.
   Whenever the result is a fluid, the position is queued for fluid ticking afterwards.
4. If the run was "grassy" and the block directly below the carved block is `dirt`, that dirt block is replaced by the
   surface material that the surface rules (10 §10.1, §10.5) give for that column (so a carved-away dirt-and-grass edge is regrassed).

The carved blocks are air at and above the aquifer's fluid level and lava below y = -54: **the classic carver lava level
is -54** (lava lakes in carved caves appear for y <= -55). (Aquifer cells can also produce water-filled and
lava-filled pockets in the noise caves of §2; that is the aquifer, 10 §9.)

### 5.7 Interaction with noise caves

Carvers run after the fill, the surface rules and the vein rule (§1), so they cut both stone and ore veins; they do
not cut bedrock. Carvers are independent of the noise caves: the two systems overlap freely.

## 6. Decoration: seeding, ordering and chunk borders

### 6.1 Per-chunk seeding

Decoration of chunk C (chunk coordinates `cx`, `cz`):

1. Create a `WorldgenRandom` wrapping a Xoroshiro source (the unique wrapped seed is immediately replaced, §4).
2. `origin = (cx * 16, -64, cz * 16)`, the minimum corner of the lowest section.
3. `decorationSeed = setDecorationSeed(worldSeed, origin.x, origin.z)` (§4). It uses the block coordinates, i.e. `16 * cx`
   and `16 * cz`.
4. For each placed feature to run: `setFeatureSeed(decorationSeed, featureIndex, stepIndex)`, then run the placed feature (§6.4) with
   this random source and the origin. `featureIndex` is the feature's index in the global ordered list of its step (§6.2),
   `stepIndex` is 0 to 10.

The random source is re-seeded per feature, so a feature's output depends only on (worldSeed, cx, cz, step, index) and on
the world contents it reads, never on how many other features ran.

### 6.2 Steps and global feature order

There are 11 decoration steps, in this order: 0 `RAW_GENERATION`, 1 `LAKES`, 2 `LOCAL_MODIFICATIONS`, 3
`UNDERGROUND_STRUCTURES`, 4 `SURFACE_STRUCTURES`, 5 `STRONGHOLDS`, 6 `UNDERGROUND_ORES`, 7 `UNDERGROUND_DECORATION`, 8
`FLUID_SPRINGS`, 9 `VEGETAL_DECORATION`, 10 `TOP_LAYER_MODIFICATION`. Each biome JSON's `features` is an array of 11 lists, one
per step, in the step order above. All ores and blobs of this document are in step 6 (`UNDERGROUND_ORES`) except
`ore_infested`, which is step 7.

Within a step, features run in **ascending global index**. The global index list per step is built once for the
dimension from the biome source's full biome set (`possibleBiomes`, in its enumeration order) like this
(`FeatureSorter.buildFeaturesPerStep`):

1. Number every distinct placed feature, in order of first appearance while walking the biomes in order, each biome's steps in
   order and each step's features in order (one counter for all steps: its `featureIndex`).
2. Build a directed graph on (step, feature) nodes: for each biome and each step, an edge from each feature to the one that
   follows it in that biome's list (consecutive pairs only).
3. Visit the nodes in ascending order of (step, `featureIndex`) with a depth-first search that follows the edges and emits a node
   after its successors; reverse the emitted list. A cycle is an error (the vanilla data has none).
4. The features of step s are the emitted nodes whose step is s, in emitted order; the position in that per-step list is the
   `featureIndex` that §6.1 uses.

For a chunk being decorated, only features that appear in at least one biome present in the 3x3 chunks around it (every
section palette of those nine chunks, intersected with the dimension's biome set) are candidates; the candidate indices of a
step are the sorted, de-duplicated indices. Candidates run once each, in ascending index order. Structures of the step
are generated first within each step (the structure placement itself is outside this document). Which biome's list a
feature came from does not matter at run time: the per-position `biome` filter (§6.4) decides.

Consequence for ores: in every overworld biome the ores are listed in the same relative order (§8.3), so the global order of
the step-6 features is, up to biome-specific insertions, the common order `ore_dirt`, `ore_gravel`, `ore_granite_upper`,
`ore_granite_lower`, `ore_diorite_upper`, `ore_diorite_lower`, `ore_andesite_upper`, `ore_andesite_lower`, `ore_tuff`,
`ore_coal_upper`, `ore_coal_lower`, `ore_iron_upper`, `ore_iron_middle`, `ore_iron_small`, `ore_gold`, `ore_gold_lower`, `ore_redstone`,
`ore_redstone_lower`, `ore_diamond`, `ore_diamond_medium`, `ore_diamond_large`, `ore_diamond_buried`, `ore_lapis`,
`ore_lapis_buried`, `ore_copper`, `underwater_magma`, `disk_sand`, `disk_clay`, `disk_gravel`; the biome-specific extras
(`ore_emerald`, `ore_gold_extra`, `ore_copper_large`, `ore_clay`, `disk_grass`) are spliced in by the sort at the position given by their
neighbours in the biome that has them (§8.3).

The biome enumeration order that step 1 above needs is the order of the multi-noise parameter list (`MultiNoiseBiomeSource.collectPossibleBiomes` maps
the list in order), which is the insertion order of `OverworldBiomeBuilder` given in 10 §7.4, each biome counted at its first appearance (the
set is assumed to keep encounter order: inferred). With that list the absolute `featureIndex` of every feature follows from the four steps above and the
per-biome tables of §8.3; this document does not tabulate the resulting numbers (Open question 2). Where an implementation uses another
enumeration order, the world is still vanilla-like; only the pseudo-random detail of every blob differs.

### 6.3 Where the random comes from while placing

The feature's random source is the same `WorldgenRandom` across the whole run of one placed feature (all its count repeats),
consumed in the order of §6.4 and §7. It is re-seeded at the start of the next placed feature (§6.1).

### 6.4 Placed feature pipeline

A placed feature is a configured feature plus an ordered list of placement modifiers, all of the overworld ores having
`[count or rarity_filter, in_square, height_range, biome]` (`count` or `rarity_filter` is first, `height_range` is third, and
`biome` is last). The evaluation is depth-first and per position (a position goes through all the remaining modifiers and the
feature before the next sibling position starts):

| Modifier | Effect on one input position |
|---|---|
| `count` | `n = sample(count provider)` (a constant count draws nothing; `uniform` draws `nextInt`); emit the same position `n` times |
| `rarity_filter` (`chance`) | draw `nextFloat()`; pass the position when `value < 1.0 / chance` (float), otherwise drop it |
| `in_square` | `x' = x + nextInt(16)`, then `z' = z + nextInt(16)` (draw order x then z); the position keeps its y |
| `height_range` | `y' = sample(height provider)` (§4); x, z unchanged |
| `biome` | pass the position only if the biome at the position (the level's `getBiome(x, y, z)` with the fuzzy zoom of 10 §7.7) lists this placed feature in its generation settings |

After the last modifier the configured feature's `place` runs at the position with the same random source. So a `count 7`
placed feature draws, per repeat: `nextInt(16)` (x), `nextInt(16)` (z), the height draw(s), and then the feature's own draws; the
next repeat starts after that. The `rarity_filter` first draws a float; if it fails nothing else is drawn.

### 6.5 Chunk-border rules for features

- Candidate positions are always inside the chunk C being decorated (origin plus 0 to 15 in x and z, then y from the height
  provider), but a feature's blocks may extend outside C: an ore blob can reach up to about
  `ceil(size/8) + ceil((size/16*2 + 1)/2)` blocks beyond the origin column (for size 64: 13), a size-9 blob up to 4 blocks.
- Block writes are accepted only when the block lies within 1 chunk (a 3 x 3 chunk window) of C; a write outside this window is
  refused and that block is skipped (not an error for ores: the blob simply is not completed there). The neighbours in that window are
  guaranteed to have completed `TERRAIN` (§1) but may or may not have been decorated yet; features read the current state of the
  neighbour chunks.
- The ore blob placement additionally skips positions outside the world's build height.
- Blobs from neighbouring chunks can overlap; a blob only replaces blocks its targets accept, so the result depends on which chunk
  was decorated first. The decoration order of chunks is a property of the scheduler, not of this document.

## 7. The ore feature (blobs)

Every ore, dirt, gravel, granite, diorite, andesite and tuff blob of the overworld uses the feature type `minecraft:ore`
(`OreFeature`). Parameters: `size` (int), `discard_chance_on_air_exposure` (float 0..1) and `targets` (an ordered list of
`{ state, target rule }`).

### 7.1 Blob geometry

`place(origin = (ox, oy, oz))`, with a random source:

1. `angle = nextFloat() * 3.1415927` (float). `fs = size / 8.0` (float). `rr = ceil( (size / 16.0 * 2.0 + 1.0) / 2.0 )` (integer,
   float arithmetic).
2. The blob axis runs between the two end points
   `x0 = ox + sin(angle) * fs`, `x1 = ox - sin(angle) * fs`, `z0 = oz + cos(angle) * fs`, `z1 = oz - cos(angle) * fs` (double `Math.sin`/`Math.cos`
   of the float angle).
3. `y0 = oy + nextInt(3) - 2`, then `y1 = oy + nextInt(3) - 2` (two draws, in this order).
4. Bounding box: `startX = ox - ceil(fs) - rr`, `startY = oy - 2 - rr`, `startZ = oz - ceil(fs) - rr`; `width = 2 * (ceil(fs) + rr)`, `height = 2 * (2 + rr)`.
5. Scan the columns `x` in `startX .. startX + width`, `z` in `startZ .. startZ + width` (x outer, z inner, both inclusive). At the first
   column whose `OCEAN_FLOOR_WG` heightmap value is at least `startY` (i.e. `startY <= height(x, z)`, the heightmap
   value being the y of the highest movement-blocking block plus one, 10 §8.1, with the caveat of 10 §15 item 6), run the blob fill (§7.2) and return its result;
   if no column qualifies, place nothing and return false. (In practice the first column almost always qualifies.)

### 7.2 Blob fill

1. **Balls.** For `i` from 0 to `size - 1`, `t = i / size` (float): the ball centre is the linear interpolation at `t` of the axis
   (`x = lerp(t, x0, x1)`, `y = lerp(t, y0, y1)`, `z = lerp(t, z0, z1)` with `lerp(t, a, b) = a + t*(b - a)`); draw `d = nextDouble() * size / 16.0`;
   the ball radius is `r_i = ( (sin(pi * t) + 1.0) * d + 1.0 ) / 2.0` (table `sin`, float argument `3.1415927 * t`). Store (x, y, z, r).
   `size` `nextDouble()` draws in total, in index order, and no others in this phase.
2. **Overlap removal.** For `i` from 0 to `size - 2`: if `r_i <= 0` skip it. For `j` from `i + 1` to `size - 1`: if `r_j <= 0` skip. Let `(dx, dy, dz, dr)` =
   ball i minus ball j. If `dr*dr > dx*dx + dy*dy + dz*dz` then: if `dr > 0` set `r_j = -1`, otherwise set `r_i = -1` (and the scan of j
   continues). That is, a ball wholly inside a bigger ball is dropped.
3. **Fill.** A bit set of `width * height * width` positions records which positions have been handled. For each ball i in order
   with `r_i >= 0` (balls with `r_i < 0` are skipped; a ball with `r_i == 0` is processed and has no extent):
   - `xLo = max(floor(x_i - r_i), startX)`, `yLo = max(floor(y_i - r_i), startY)`, `zLo = max(floor(z_i - r_i), startZ)`, `xHi = max(floor(x_i + r_i), xLo)`, `yHi =
     max(floor(y_i + r_i), yLo)`, `zHi = max(floor(z_i + r_i), zLo)`;
   - for `x` from `xLo` to `xHi`, `xd = (x + 0.5 - x_i) / r_i`; if `xd*xd >= 1` skip; for `y` from `yLo` to `yHi`, `yd = (y + 0.5 - y_i) / r_i`; if `xd*xd + yd*yd
     >= 1` skip; for `z` from `zLo` to `zHi`, `zd = (z + 0.5 - z_i) / r_i`; if `xd*xd + yd*yd + zd*zd >= 1` skip;
   - for each remaining position: skip if outside the build height (y < -64 or y > 319); compute the bit index `(x - startX) + (y - startY) * width + (z - startZ) *
     width * height`; skip (and do not re-handle) if its bit is set; set the bit; skip if the position is not writable (§6.5) or its
     chunk section does not exist; read the current block; then go through the targets **in list order** and for the **first** target that accepts
     (§7.3) place its `state` and count one; stop trying other targets at this position.
4. The feature returns true if at least one block was placed.

Note the loop order: x outermost, then y, then z innermost; the bit index is shared by all balls so a position is
changed at most once per blob.

### 7.3 Target test and air exposure

A target accepts a position when (a) its **rule** matches the current block at that position and (b) the air-exposure test passes.

(b) is evaluated only if (a) accepted the block: when the rule rejects, nothing is drawn. With `c = discard_chance_on_air_exposure`: if `c <= 0` the test passes without drawing; if `c >= 1` the test is "not adjacent to
air" without drawing; otherwise draw `nextFloat()` and, when the value is `>= c`, pass without looking at the neighbours,
and when it is `< c` pass only if no neighbour is air. "Adjacent to air" is: any of the 6 face neighbours of the position is air
(`isAir`, so `air`, `cave_air`, `void_air`). The neighbour state is read from the level, including blocks in neighbouring
chunks of the 3x3 window.

(a) the rule kinds in the overworld ore files are:

| Rule | Meaning |
|---|---|
| `tag_match tag` | the block is in the block tag |
| `block_match block` | the block is this block |
| `height_match min..max` | the position's y is in `[min, max]` inclusive |
| `all_of`, `any_of`, `not` | logical combinations; `any_of` is true when any child is |

The block tags used (`data/minecraft/tags/block/`): `base_stone_overworld` = stone, granite, diorite, andesite, tuff, deepslate;
`stone_ore_replaceables` = stone, granite, diorite, andesite; `deepslate_ore_replaceables` = deepslate;
`height_specific_ore_replaceables` = tuff.

All metal and gem ores (every `targets` list with two entries) use the same two-entry pattern:

| Entry | State | Rule |
|---|---|---|
| 1 | the stone-variant ore (e.g. `coal_ore`) | `( tuff and y in [0, 2031] )` or `( not tuff and block in stone_ore_replaceables )` |
| 2 | the deepslate-variant ore (e.g. `deepslate_coal_ore`) | `( tuff and y in [-2032, 8] )` or `( not tuff and block is deepslate )` |

So: stone, granite, diorite and andesite become the stone variant at any height; deepslate becomes the deepslate variant at any
height; **tuff** becomes the stone variant at y >= 0 and the deepslate variant at y <= 8 (entry 1 is tried first, so tuff at
y in [0, 8] becomes the stone variant). The blob ores without variants (dirt, gravel, granite, diorite, andesite, tuff, clay)
use the single rule `tag_match base_stone_overworld`: they can replace any of the six base stones including tuff and
deepslate (and a granite blob can replace tuff, deepslate or other granite). Vein-ore targets use `infested_stone` /
`infested_deepslate` with the same two-entry pattern for `ore_infested`.

### 7.4 Worked example: blob geometry (computed)

Take `size = 9` at origin (100, 12, -40) with draws `nextFloat() = 0.5`, then `nextInt(3) = 1` and `nextInt(3) = 0`.

- `angle = 0.5 * 3.1415927 = 1.57079635`; `fs = 9/8 = 1.125`; `rr = ceil((9/16*2 + 1)/2) = ceil(1.0625) = 2`.
- `x0 = 100 + sin(angle)*1.125 = 101.125` (sin is 1.0 to float precision), `x1 = 98.875`; `z0 = -40 + cos(angle)*1.125 = -40.00000005` (cos is about -4.37e-8), `z1 = -39.99999995`.
- `y0 = 12 + 1 - 2 = 11`, `y1 = 12 + 0 - 2 = 10`.
- `startX = 100 - ceil(1.125) - 2 = 96`, `startY = 12 - 2 - 2 = 8`, `startZ = -44`; `width = 2 * (2 + 2) = 8`, `height = 2 * (2 + 2) = 8`.
- Ball 0 (`t = 0`) has its centre at (101.125, 11, -40.00000005); with `nextDouble() = 0.5` the radius is `d = 0.5 * 9/16 = 0.28125`,
  `r_0 = ((sin 0 + 1) * 0.28125 + 1)/2 = 0.640625`; a ball at `t = 0.5` with the same `d` has
  `sin(pi/2) = 1`, so `r = (2 * 0.28125 + 1)/2 = 0.78125`.
- The blob is at most 9 balls of radius 0.64 to 0.78 along a short line, about 9 blocks of ore, each ball covering 1 to 2 blocks.

## 8. The ore and blob features of the overworld

### 8.1 Configured features (`worldgen/feature/*.json`, type `minecraft:ore`)

`air` is `discard_chance_on_air_exposure` (§7.3). "Variants" refers to the two-entry rule pattern of §7.3 with the named
stone and deepslate states.

| Configured feature | Size | air | Block (stone variant / deepslate variant) |
|---|---|---|---|
| `ore_coal` | 17 | 0.0 | `coal_ore` / `deepslate_coal_ore` |
| `ore_coal_buried` | 17 | 0.5 | same |
| `ore_iron` | 9 | 0.0 | `iron_ore` / `deepslate_iron_ore` |
| `ore_iron_small` | 4 | 0.0 | same |
| `ore_copper_small` | 10 | 0.0 | `copper_ore` / `deepslate_copper_ore` |
| `ore_copper_large` | 20 | 0.0 | same |
| `ore_gold` | 9 | 0.0 | `gold_ore` / `deepslate_gold_ore` |
| `ore_gold_buried` | 9 | 0.5 | same |
| `ore_redstone` | 8 | 0.0 | `redstone_ore` / `deepslate_redstone_ore` |
| `ore_lapis` | 7 | 0.0 | `lapis_ore` / `deepslate_lapis_ore` |
| `ore_lapis_buried` | 7 | 1.0 | same |
| `ore_diamond_small` | 4 | 0.5 | `diamond_ore` / `deepslate_diamond_ore` |
| `ore_diamond_medium` | 8 | 0.5 | same |
| `ore_diamond_large` | 12 | 0.7 | same |
| `ore_diamond_buried` | 8 | 1.0 | same |
| `ore_emerald` | 3 | 0.0 | `emerald_ore` / `deepslate_emerald_ore` |
| `ore_infested` | 9 | 0.0 | `infested_stone` / `infested_deepslate` |
| `ore_dirt` | 33 | 0.0 | `dirt` (single rule `base_stone_overworld`) |
| `ore_gravel` | 33 | 0.0 | `gravel` (same) |
| `ore_granite` | 64 | 0.0 | `granite` (same) |
| `ore_diorite` | 64 | 0.0 | `diorite` (same) |
| `ore_andesite` | 64 | 0.0 | `andesite` (same) |
| `ore_tuff` | 64 | 0.0 | `tuff` (same) |
| `ore_clay` | 33 | 0.0 | `clay` (same; lush caves only) |

(The air value is the
probability of **applying** the exposure test: `ore_lapis_buried` and `ore_diamond_buried` have 1.0 and never touch air; `ore_coal_buried` and
`ore_gold_buried` skip any block touching air in half of the cases.)

### 8.2 Placed features (`worldgen/placed_feature/*.json`)

All have the modifiers `in_square`, `height_range`, `biome` after their first modifier. Heights are resolved at `minY = -64`,
top block 319; "triangle" = `trapezoid` with plateau 0; the peak of a triangle is the middle of its range; "valid" is the
part of the range inside the world.

| Placed feature | Configured feature | First modifier | Height provider, resolved y range | Triangle peak / note |
|---|---|---|---|---|
| `ore_dirt` | `ore_dirt` | count 7 | uniform 0 .. 160 | |
| `ore_gravel` | `ore_gravel` | count 14 | uniform above_bottom 0 .. below_top 0 = -64 .. 319 | |
| `ore_granite_upper` | `ore_granite` | rarity_filter 1/6 | uniform 64 .. 128 | |
| `ore_granite_lower` | `ore_granite` | count 2 | uniform 0 .. 60 | |
| `ore_diorite_upper` | `ore_diorite` | rarity_filter 1/6 | uniform 64 .. 128 | |
| `ore_diorite_lower` | `ore_diorite` | count 2 | uniform 0 .. 60 | |
| `ore_andesite_upper` | `ore_andesite` | rarity_filter 1/6 | uniform 64 .. 128 | |
| `ore_andesite_lower` | `ore_andesite` | count 2 | uniform 0 .. 60 | |
| `ore_tuff` | `ore_tuff` | count 2 | uniform above_bottom 0 .. absolute 0 = -64 .. 0 | |
| `ore_coal_upper` | `ore_coal` | count 30 | uniform 136 .. below_top 0 = 136 .. 319 | |
| `ore_coal_lower` | `ore_coal_buried` | count 20 | triangle 0 .. 192 | peak 96 |
| `ore_iron_upper` | `ore_iron` | count 90 | triangle 80 .. 384 | peak 232; only the part up to 319 is inside the world |
| `ore_iron_middle` | `ore_iron` | count 10 | triangle -24 .. 56 | peak 16 |
| `ore_iron_small` | `ore_iron_small` | count 10 | uniform above_bottom 0 .. 72 = -64 .. 72 | |
| `ore_gold` | `ore_gold_buried` | count 4 | triangle -64 .. 32 | peak -16 |
| `ore_gold_lower` | `ore_gold_buried` | count uniform 0..1 | uniform -64 .. -48 | the count draws `nextInt(2)` |
| `ore_gold_extra` | `ore_gold` | count 50 | uniform 32 .. 256 | badlands only |
| `ore_redstone` | `ore_redstone` | count 4 | uniform above_bottom 0 .. 15 = -64 .. 15 | |
| `ore_redstone_lower` | `ore_redstone` | count 8 | triangle above_bottom -32 .. above_bottom 32 = -96 .. -32 | peak -64; the part below -64 is outside the world |
| `ore_lapis` | `ore_lapis` | count 2 | triangle -32 .. 32 | peak 0 |
| `ore_lapis_buried` | `ore_lapis_buried` | count 4 | uniform above_bottom 0 .. 64 = -64 .. 64 | |
| `ore_diamond` | `ore_diamond_small` | count 7 | triangle above_bottom -80 .. above_bottom 80 = -144 .. 16 | peak -64; half the range is below the world |
| `ore_diamond_medium` | `ore_diamond_medium` | count 2 | uniform -64 .. -4 | |
| `ore_diamond_large` | `ore_diamond_large` | rarity_filter 1/9 | triangle -144 .. 16 | peak -64 |
| `ore_diamond_buried` | `ore_diamond_buried` | count 4 | triangle -144 .. 16 | peak -64 |
| `ore_emerald` | `ore_emerald` | count 100 | triangle -16 .. 480 | peak 232; only the part up to 319 is inside the world |
| `ore_copper` | `ore_copper_small` | count 16 | triangle -16 .. 112 | peak 48 |
| `ore_copper_large` | `ore_copper_large` | count 16 | triangle -16 .. 112 | peak 48; dripstone caves instead of `ore_copper` |
| `ore_infested` | `ore_infested` | count 14 | uniform above_bottom 0 .. 63 = -64 .. 63 | step 7 |
| `ore_clay` | `ore_clay` | count 46 | uniform above_bottom 0 .. 256 | lush caves only |

Positions whose y comes out outside `-64 .. 319` are drawn and then simply do nothing useful: the blob fill skips every block outside the build
height, and the heightmap column test (§7.1 step 5) can also reject. These wasted attempts are part of vanilla's frequencies (for instance
half of the `ore_diamond` triangle is below the world).

A trapezoid with `plateau = 0` and `range = hi - lo` has `slopeWidth = range / 2`, so the value is `lo + nextInt(range - range/2 + 1) +
nextInt(range/2 + 1)`: for `ore_copper`, `range = 128`: `-16 + nextInt(65) + nextInt(65)`, range -16 .. 112, peak 48.

### 8.3 Per-biome differences (step 6)

All overworld biomes list the common sequence of §6.2, followed by `underwater_magma`, `disk_sand`, `disk_clay`, `disk_gravel`
(the last three and `underwater_magma` are not ores and are not specified here, apart from their position in the order),
except these:

| Biomes | Difference |
|---|---|
| `cherry_grove`, `frozen_peaks`, `grove`, `jagged_peaks`, `meadow`, `snowy_slopes`, `stony_peaks`, `windswept_forest`, `windswept_gravelly_hills`, `windswept_hills` | add `ore_emerald` at the end of step 6, and `ore_infested` in step 7 |
| `badlands`, `eroded_badlands`, `wooded_badlands` | add `ore_gold_extra` after `underwater_magma` (before the `disk_*` features) |
| `dripstone_caves` | `ore_copper_large` instead of `ore_copper` |
| `lush_caves` | adds `ore_clay` after `underwater_magma` |
| `mangrove_swamp` | no `disk_sand`/`disk_gravel`, `disk_grass` instead (and `disk_clay`) |
| `swamp` | `disk_clay` only after `underwater_magma` |
| all others (plains, forests, deserts, oceans, rivers, taigas, jungles, savannas, beaches, `deep_dark`, `sulfur_caves`, ...) | the common sequence |

The 10 emerald biomes are the mountain-type biomes listed; emeralds do not generate elsewhere.

### 8.4 Expected frequencies (computed)

Attempts per chunk (not ore blocks): coal 30 + 20; iron 90 + 10 + 10; copper 16; gold 4 + 0.5 (+ 50 in badlands); redstone 4 + 8; lapis 2 + 4; diamond 7 + 2 + 4 + 1/9;
emerald 100 (emerald biomes only); each attempt makes a blob of up to `size` blocks, with the air-exposure rule discarding some blocks
(buried variants discard every exposed block at 1.0).

### 8.5 Carver biome lists

Every overworld biome JSON has `carvers = ["minecraft:cave", "minecraft:cave_extra_underground", "minecraft:canyon"]`; the Nether biomes have
`["minecraft:nether_cave"]` and the End biomes none (this includes `the_void`).

## 9. Ore drops, tools and experience (survival)

Ore blocks drop through their block loot tables (`data/minecraft/loot_table/blocks/*.json`); the drops require a correct tool.

### 9.1 Which tool breaks which ore

All the ores in this section are in the block tag `mineable/pickaxe` and have `requiresCorrectToolForDrops`. The tier is
set by the block tags `needs_stone_tool`, `needs_iron_tool` and `needs_diamond_tool`; a tool tier can not correctly
harvest a block in the tag `incorrect_for_<tier>_tool`, which lists:

| Tool tier | Cannot correctly harvest blocks tagged |
|---|---|
| wooden, gold | `needs_stone_tool`, `needs_iron_tool`, `needs_diamond_tool` |
| stone, copper | `needs_iron_tool`, `needs_diamond_tool` |
| iron | `needs_diamond_tool` |
| diamond, netherite | (none) |

So with a wooden or golden pickaxe only coal (and the stone-type blocks) can be harvested; with a stone or copper pickaxe also iron, copper and lapis ores and
the raw copper/iron blocks; with an iron pickaxe also gold, redstone, diamond, emerald ores and raw gold block. Breaking never drops anything in creative mode (the break path returns before the drop step when the player `preventsBlockDrops`; out of scope here). Broken without the correct tool a block
drops nothing (and gives no experience) (inferred from the break path: the player's `hasCorrectToolForDrops` gates the drop).

Hardness (`strength`, destroy time / blast resistance): stone-variant ores 3.0 / 3.0; deepslate variants 4.5 / 3.0; the three `raw_*_block` 5.0 / 6.0;
`stone`, `granite`, `diorite`, `andesite`, `tuff` 1.5 / 6.0 (the base stone blocks also need a pickaxe), `deepslate` 3.0 / 6.0, `dirt` 0.5, `gravel` 0.6.
(The deepslate variants copy the stone variant's properties and override the strength; `copper_ore` copies `iron_ore`; that the copy carries the
requires-correct-tool flag is inferred.)

### 9.2 Loot

Every ore table has one pool with one roll and a single `alternatives` entry whose first child is the ore block itself under the condition `tool/can_silk_touch`
(the tool has the `silk_touch` enchantment at level 1 or more), and whose second child is the drop below (reached when the tool has no silk touch). The
drop's functions are applied in the order listed; the count starts at 1 unless a `set_count` precedes. `explosion_decay` only matters for explosions.

| Ore (and its deepslate variant) | Drop | Base count | Fortune formula |
|---|---|---|---|
| `coal_ore` | `coal` | 1 | `ore_drops` |
| `iron_ore` | `raw_iron` | 1 | `ore_drops` |
| `gold_ore` | `raw_gold` | 1 | `ore_drops` |
| `copper_ore` | `raw_copper` | uniform 2 .. 5 | `ore_drops` (applied to the sampled count) |
| `lapis_ore` | `lapis_lazuli` | uniform 4 .. 9 | `ore_drops` |
| `redstone_ore` | `redstone` | uniform 4 .. 5 | `uniform_bonus_count`, `bonusMultiplier` 1 |
| `diamond_ore` | `diamond` | 1 | `ore_drops` |
| `emerald_ore` | `emerald` | 1 | `ore_drops` |
| `raw_iron_block`, `raw_copper_block`, `raw_gold_block` | themselves | 1 | none |
| `infested_stone` | nothing, or `stone` with silk touch | | silverfish mechanics are not specified here |

Fortune (`enchantment/fortune`, max level 3). With the tool's fortune level `L`:

- `ore_drops`: if `L > 0`, `m = nextInt(L + 2) - 1`, `m = max(m, 0)`, and the count becomes `count * (m + 1)`; if `L == 0` the count is unchanged. So fortune
  III gives multipliers 1 (with probability 2/5), 2 (1/5), 3 (1/5), 4 (1/5): `nextInt(5)` gives -1, 0, 1, 2, 3 and negative is floored to 0.
- `uniform_bonus_count` (redstone): the count becomes `count + nextInt(bonusMultiplier * L + 1)`.
- Silk touch drops the block itself instead (condition first) and its `block_experience` effect (below) sets experience to 0.

The random source for the loot rolls is the loot context's (seeded from the block's `random_sequence`, e.g. `minecraft:blocks/coal_ore`); the exact
generator is not needed for survival (any uniform source is a faithful implementation).

### 9.3 Experience

The experience is dropped when a player breaks the ore with the correct tool (inferred from the break path, as in §9.1), and is a uniform integer in
the block's range, then multiplied by the tool's block-experience effects; silk touch sets it to 0 (`enchantment/silk_touch`:
`block_experience` set 0.0), fortune does not change it.

| Ore (and its deepslate variant) | XP range (uniform, inclusive) |
|---|---|
| `coal_ore` | 0 .. 2 |
| `lapis_ore` | 2 .. 5 |
| `redstone_ore` | 1 .. 5 |
| `diamond_ore` | 3 .. 7 |
| `emerald_ore` | 3 .. 7 |
| `iron_ore`, `gold_ore`, `copper_ore` | 0 (constant) |

(The constants for iron, gold and copper were read as a constant-int block constructor with the value 0.)

## 10. Worked examples

### 10.1 Carver start and cave parameters for a source chunk (computed)

World seed 0, source chunk S = (-2, -2), carver `cave` (index 0, seed `0 + 0`): `setLargeFeatureSeed(0, -2, -2)`. First draw
`nextFloat() = 0.116262` which is `<= 0.15`, so the cave carver starts. Count: `nextInt(15) = 6`, `nextInt(7) = 1`, `nextInt(2) = 1`, so `count = 1`.
The cave: `x = -32 + nextInt(16) = -29`, `y = -56 + nextInt(237) = 96`, `z = -32 + nextInt(16) = -18`, `hMul = 1.2275`, `vMul = 0.9986`, `floor = -0.5688`;
`nextInt(4) == 0`, so a room: `roomV = 0.6578`, `roomR = 4.6286` (room horizontal radius 6.1286 at (-28, 96, -18), vertical radius 4.031), then `tunnels = 1 + nextInt(4) = 3`.
Tunnel 0: `yaw = 1.4454`, `pitch = -0.03018`, `thickness = 1.0539`, `maxSteps = 112 - nextInt(28) = 91`, walker seed -1474232536740074715. Tunnel 1: yaw 2.0769, pitch 0.07364, thickness
1.4324, 88 steps. Tunnel 2: yaw 1.7918, pitch 0.04765, thickness 1.9627, 89 steps. (Values to about 4 digits.)

For comparison, `setLargeFeatureSeed(0, 1, 0)` followed by `nextFloat()` is 0.260442; the `cave` (index 0) needs `<= 0.15`, so it does not start, while index 1
(`cave_extra_underground`, seed 1) gives 0.017425 `<= 0.07`, so it does start; its count is 0 (`nextInt(15) = 0`), so it carves nothing.

### 10.2 Height providers (computed)

`trapezoid -16 .. 112` (copper): `slopeWidth = 128/2 = 64`, `slope = 64`; with the draws `nextInt(65) = 20` and `nextInt(65) = 31` the height is `-16 + 20 + 31 = 35`.
`uniform -64 .. -4` (diamond medium): `-64 + nextInt(61)`.
`trapezoid` anchors above_bottom -80 .. 80 = -144 .. 16 (diamond): `range = 160`, `slopeWidth = 80`, `slope = 80`, height `-144 + nextInt(81) + nextInt(81)`, i.e. -144 to 16 with
the peak at -64.

### 10.3 Ore vein cell (computed)

At a cell with y = -30: copper does not apply (y not in [0, 50)); iron does (y in [-60, -8)). The edge term is `clamp(min(-8 - (-30), -30 + 60), 0, 20) * 0.01 - 0.2 =
clamp(min(22, 30), 0, 20) * 0.01 - 0.2 = 20 * 0.01 - 0.2 = 0`. With `T = -0.55`: `(-T - 0.4) + 0 = 0.15 >= 0` so the iron density is 0.7 provided the mask `M >= 0`;
if `max(|a|, |b|) = 0.05` then `M = 0.08 - 0.05 = 0.03 >= 0`. Richness `R = clamp(0.55, 0.4, 0.6) - 0.3 = 0.25`. The block is replaced only with probability 0.7;
then with probability 0.25 (and `ore_gap > -0.3`) it is ore: `deepslate_iron_ore`, with 2% of those `raw_iron_block`; otherwise `tuff`.

### 10.4 Chunk decoration seed (computed relations)

For world seed `s` and chunk (3, -2): origin = (48, -64, -32). `decorationSeed` is `setDecorationSeed(s, 48, -32)`. The seed given to the feature at global index 11 of step 6 (the
12th) is `decorationSeed + 11 + 10000 * 6 = decorationSeed + 60011`.

## 11. Validation: checkable facts

Facts an implementation or test can check against this document without the jar:

1. `final_density` is `min(squeeze(interpolated(blend_density(BASE) * 0.64)), noodle) + beardifier`, with the BASE blend constants 0.1171875 (floor, y -64 to -40) and
   -0.078125 (sky, y 240 to 256).
2. The cave threshold between near-surface and deep branches is `sloped_cheese` = 1.5625.
3. Noodles exist only for y in [-60, 320]; they are open where `max(|ridge_a|,|ridge_b|) <= (0.075 + 0.025 t)/1.5` and `noodle_noise >= 0`.
4. Spaghetti 3D thickness constants are -0.011500001 (times thickness noise) and -0.0765; `interval_select` thresholds are -0.5, 0.0, 0.5 and scales 1.3333333, 1, 0.6666667, 0.5
   with multipliers 0.75, 1, 1.5, 2.
5. Spaghetti 2D thresholds -0.75, -0.5, 0.5, 0.75; scales 2, 1.3333333, 1, 0.5, 0.3333333; multipliers 0.5, 0.75, 1, 2, 3; `THICKMOD = n * -0.34999996 - 0.95`; the factor 0.083;
   the elevation gradient is 8 at y = -64 to -40 at y = 320.
6. Ore veins: copper y [0, 50), iron y [-60, -8); toggle band 0.4; mask `0.08 - max(|a|,|b|)`; density 0.7; richness range 0.1 to 0.3; raw chance 0.02; filler granite (copper) and tuff (iron).
7. Carvers: `cave` p 0.15, y -56..180; `cave_extra_underground` p 0.07, y -56..47; `canyon` p 0.01, y 10..67; seeds `worldSeed + i` with `setLargeFeatureSeed`; source chunks within +/-8; `range` 4, walker length at most 112.
8. Carver lava level -54 (lava for y <= -55); `uncarvable` = bedrock only; carvable y range -62 .. 312.
9. Java `Random(0)`: `nextInt()` = -1155484576, `nextLong()` = -4962768465676381896, `nextFloat()` = 0.7309678, `nextInt(10)` = 0.
10. `setLargeFeatureSeed(0, 0, 0)` gives the same stream as a plain seed 0 (both products are 0); `setLargeFeatureSeed(0, 1, 0)` first `next(32)` = 1118589937 (computed).
11. Decoration: 11 steps; ores in step 6 (`ore_infested` in step 7); seed `decorationSeed + index + 10000*step`; the placed ore feature list is `[count|rarity, in_square, height_range, biome]`.
12. Ore blob: angle `nextFloat * pi`, axis half length `size/8`, `size` balls, one `nextDouble` per ball, overlap removal as §7.2, first-matching-target rule, 6-neighbour air test.
13. Ore tables of §8.1 and §8.2: for instance `ore_diamond` = count 7, size 4, triangle -144..16; `ore_emerald` = count 100, size 3, triangle -16..480; `ore_iron_upper` = count 90, size 9, triangle 80..384; `ore_coal_upper` = count 30, size 17, uniform 136..319.
14. Drops: fortune `ore_drops` multiplies by `max(0, nextInt(L+2) - 1) + 1`; redstone drops 4 to 5 plus `nextInt(L + 1)`; lapis 4 to 9; copper 2 to 5; XP ranges of §9.3; pickaxe tiers of §9.1.
15. Tuff is replaced by the stone-variant ore at y >= 0 and by the deepslate variant at y <= 8, the stone variant winning in [0, 8].

## Open questions

1. **Aquifers.** Resolved by reference: the full aquifer is specified in 10 §9.1-9.5; §5.6 only fixes how the carver uses it (density 0.0) and the lava level.
2. **Absolute feature index.** The global order is derived by the algorithm of §6.2 from the biome enumeration order (parameter-list order, 10 §7.4); this document does not
   tabulate the resulting indices, and that the possible-biome set keeps encounter order is inferred.
3. **Noise representation.** Resolved by reference: the noise JSON format is 10 §3.3 and the parameter values are 10 §3.6.
4. **Biome lookup at placement.** Resolved by reference: the fuzzy zoom is 10 §7.7. Which of the two lookups the carver biome uses (§5.2: stored-resolution climate lookup, not the zoom)
   was read from the call (`getNoiseBiome` on the uncached resolver) and is not exercised by an example.
5. **Heightmap definition.** `OCEAN_FLOOR_WG` is described by its name only (highest movement-blocking block plus one); its exact predicate was not traced (10 §15 item 6).
6. **Sulfur caves.** This version contains a `sulfur_caves` biome and a `sulfur_cave_bands` material rule and a `sulfur_cave_gradient` noise; they are underground
   biome material, not carvers or ores, and are not specified here.
7. **Loot random source.** The loot-table random sequence seeding is not specified; any uniform source matches survival behaviour but not vanilla's exact per-block rolls.
8. **Experience and drop gating.** That a wrong-tool break gives neither drops nor experience, and that experience is dropped only on a player break, is inferred from the break
   path (`hasCorrectToolForDrops`, `playerDestroy`), not traced to the experience call.
9. **Property copies.** That the deepslate ore variants inherit `requiresCorrectToolForDrops` from the stone variants through the property copy was inferred; the tier tags apply to the block either way.
10. **Trig table.** The sine table fill (`sin(i / 10430.378350470453)` cast to float) was read from the table size and scale constants and the fill loop's divisor; tabulated values were not compared.
11. **Silverfish blocks.** `infested_stone` and `infested_deepslate` behaviour (silverfish spawning) is not specified.
