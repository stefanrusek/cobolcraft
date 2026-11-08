# 35 World generation features, part 6: underground features (geodes, dripstone, sculk, dungeons, fossils, templates)

| Item | Value |
|---|---|
| Covers | The engines of the underground feature types: `geode` (amethyst geodes: layers, crack, noise offsets, budding amethyst, buds), `speleothem` (one pointed-dripstone column), `speleothem_cluster` (dripstone clusters and pools), `large_dripstone`, `sculk_patch` with the sculk spreader and the two block behaviours it drives (`SculkBlock`, `SculkVeinBlock`, plus the default behaviour of every other block), `monster_room` (dungeons), `fossil` (template loading, rotation, overlay, integrity), `template` (the generic template feature), the helper classes `SpeleothemUtils` and `Column`, and the part of the structure-template engine that these features call (template file format, ordering of placed blocks, transforms, `StructurePlaceSettings`, `placeInWorld`, the processors `block_rot`, `protected_blocks`, `rule`). `CuboidPlacement` is a placement modifier and is specified in part 1 section 7.14. |
| Does not cover | Rows of data (the extraction tool copies `worldgen/feature`, `worldgen/placed_feature`, `worldgen/processor_list`, the block tags and the structure NBT files, see 22 and 23). Glow lichen and moss (part 4); deltas, basalt and nether/end features (part 7); water and surface features (part 5). The ticking behaviour of the blocks these features place (budding amethyst growth, pointed dripstone dripping and growth, sculk catalyst spread at runtime, spawner spawning). The structure and jigsaw systems (round RS20); only what the three template-based features call is written here. The processors other than the three listed above. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.level.levelgen.feature.{GeodeFeature, SpeleothemFeature, SpeleothemClusterFeature, SpeleothemUtils, LargeDripstoneFeature (+ $LargeDripstone, $WindOffsetter), SculkPatchFeature, MonsterRoomFeature, FossilFeature, TemplateFeature (+ $TemplateEntry)}`, `...levelgen.{Column (+ $Range, $Ray, $Line), GeodeBlockSettings, GeodeLayerSettings, GeodeCrackSettings}`, `...levelgen.synth.NormalNoise (+ $Builder, $OctaveInfo)`, `...block.{SculkSpreader (+ $ChargeCursor), SculkBehaviour (+ $1), SculkBlock, SculkVeinBlock (+ $SculkVeinSpreaderConfig), MultifaceBlock, MultifaceSpreader (+ nested), BuddingAmethystBlock, RotatedPillarBlock}`, `...levelgen.structure.StructurePiece.reorient`, `...levelgen.structure.templatesystem.{StructureTemplate, StructurePlaceSettings, StructureTemplateManager, BlockRotProcessor, ProtectedBlockProcessor, RuleProcessor, ProcessorRule, BlockMatchTest, rule.blockentity.AppendLoot}`, `...blockscan.{BlockMatcher, BoxBlockMatcher}`, `net.minecraft.util.{Mth, Util, RandomSource, valueproviders.ClampedNormalFloat}`, `net.minecraft.core.{Direction, BlockPos}`, `net.minecraft.world.level.block.Rotation`, `net.minecraft.server.level.WorldGenRegion.getBlockEntity`; and of data files of the jar (feature, placed-feature, processor-list JSON, block tags, structure NBT) read as data only. No execution. |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engine (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"; design map `docs/design/README.md` GAP-12a, Part 6 row RS19). |
| Status | Written by the reader for round RS19, part 6. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not
verified)" marks something not read; both are listed in the Open questions. Every value below was read from the artifact in this round.
References use "10 section 2" for other documents and "section 5" for this one. Part 1 (`35-worldgen-features-1-model-and-placement.md`) is
cited as "35-1", part 2 as "35-2", part 4 as "35-4". Coordinates are block coordinates; `y` is the vertical axis; the overworld has
`minY = -64`, top block 319 (10 section 5).

---

## 1. Reader's map

| Feature type (registry name) | Class | Section | Randomness | Reads outside the feature's own writes |
|---|---|---|---|---|
| `geode` | `GeodeFeature` | 4 | the feature random for sampling; a **separate** fixed noise for shape | the 33 x 33 x 33 box around the origin |
| `speleothem` | `SpeleothemFeature` | 5 | the feature random | 1 column |
| `speleothem_cluster` | `SpeleothemClusterFeature` | 6 | the feature random (uses `nextGaussian`) | per column: scan up and down (at most the configured range) |
| `large_dripstone` | `LargeDripstoneFeature` | 7 | the feature random | a vertical scan, a circle test, heightmap `WORLD_SURFACE_WG` |
| `sculk_patch` | `SculkPatchFeature` | 8 | the feature random | the neighbourhood of every cursor |
| `monster_room` | `MonsterRoomFeature` | 9 | the feature random | an 8 x 6 x 9 (at most) box |
| `fossil` | `FossilFeature` | 10 | the feature random | the template box, heightmap `OCEAN_FLOOR_WG` |
| `template` | `TemplateFeature` | 10 | the feature random | the template box |

Sections 2 and 3 give what several of these share (enumerations, random helpers, column scans, block-entity access). Section 10
also gives the template engine. Section 11 holds worked examples, section 12 the checks an implementation must pass.

### 1.1 What the data does with them (counts read from the jar; data is not tabulated beyond this)

| Placed feature (file in `worldgen/placed_feature`) | Feature | Placement list (modifier types in order) | Decoration step (index) and number of biomes listing it |
|---|---|---|---|
| `amethyst_geode` | `amethyst_geode` (`geode`) | `rarity_filter` 24, `in_square`, `height_range` uniform `above_bottom 6` to `absolute 30`, `biome` | 2 `LOCAL_MODIFICATIONS`, 56 biomes |
| `monster_room` | `monster_room` | `count` 10, `in_square`, `height_range` uniform `absolute 0` to `below_top 0`, `biome` | 3 `UNDERGROUND_STRUCTURES`, 56 biomes |
| `monster_room_deep` | `monster_room` | `count` 4, `in_square`, `height_range` uniform `above_bottom 6` to `absolute -1`, `biome` | 3, 56 biomes |
| `fossil_upper` | `fossil_coal` (`fossil`) | `rarity_filter` 64, `in_square`, `height_range` uniform `absolute 0` to `below_top 0`, `biome` | 3, 3 biomes (`desert`, `mangrove_swamp`, `swamp`) |
| `fossil_lower` | `fossil_diamonds` (`fossil`) | `rarity_filter` 64, `in_square`, `height_range` uniform `above_bottom 0` to `absolute -8`, `biome` | 3, the same 3 biomes |
| `large_dripstone` | `large_dripstone` | `count` uniform 10 to 48, `in_square`, `height_range` uniform from `above_bottom 0` to `absolute 256` (read from the placed-feature data file; never starts above y = 256), `biome` | 2, 1 biome (`dripstone_caves`) |
| `dripstone_cluster` | `dripstone_cluster` (`speleothem_cluster`) | `count` uniform 48 to 96, `in_square`, `height_range` uniform from `above_bottom 0` to `absolute 256` (read from the placed-feature data file; never starts above y = 256), `biome` | 7 `UNDERGROUND_DECORATION`, 1 biome (`dripstone_caves`) |
| `pointed_dripstone` | `pointed_dripstone` (`simple_random_selector` of two placed `speleothem` features) | `count` uniform 192 to 256, `in_square`, `height_range` uniform from `above_bottom 0` to `absolute 256` (read from the placed-feature data file; never starts above y = 256), `count` uniform 1 to 5, `offset` (clamped normal x 0/3.0 in -10..10, y 0/0.6 in -2..2, z as x), `biome`; each of the two selector entries has `environment_scan` (allowed: air tag or water, target `solid`, `max_steps` 12, direction `down` then `offset (0, +1, 0)`, or direction `up` then `offset (0, -1, 0)`) | 7, 1 biome (`dripstone_caves`) |
| `sculk_patch_deep_dark` | `sculk_patch_deep_dark` (`sequence`: a `sculk_patch` with no modifiers, then a `simple_block` sculk catalyst with `random_chance` 0.5 and `block_predicate_filter has_sturdy_face up` at offset (0,-1,0)) | `count` 256, `in_square`, `height_range` uniform from `above_bottom 0` to `absolute 256` (read from the placed-feature data file; never starts above y = 256), `biome` | 7, 1 biome (`deep_dark`) |
| `sculk_patch_ancient_city` | `sculk_patch_ancient_city` (as above plus an `overlay` of a catalyst and 1 to 3 shriekers) | none (it is invoked by the ancient city structure, RS20) | not in any biome |
| `desert_well` | `desert_well` (`overlay` of three `template` features) | `rarity_filter` 1000, `in_square`, `heightmap MOTION_BLOCKING`, `offset (0,-1,0)`, `block_predicate_filter` (sand at the position, and a `volume_match` of "not air" over the box (-2,-2,-2) to (2,-1,2)), `biome` | 4 `SURFACE_STRUCTURES`, 1 biome (`desert`) |

The three `sculk_patch` records that exist use the same fields: `charge_count` 10, `amount_per_charge` 32, `spread_attempts` 64, `growth_rounds` 0,
`spread_rounds` 1. The amethyst geode record uses all defaults of section 4.1 except the ones named there.

---

## 2. Shared enumerations and helper functions

### 2.1 Directions and rotations

| Name | Order and values (read) |
|---|---|
| `Direction.values()` (the "all six" order used wherever this document says "the six directions in order") | DOWN (0), UP (1), NORTH (2), SOUTH (3), WEST (4), EAST (5). `Direction.stream()`, `Direction.allShuffled(random)` and every array named `DIRECTIONS` use this order (a shuffle starts from it). Unit steps: DOWN (0,-1,0), UP (0,1,0), NORTH (0,0,-1), SOUTH (0,0,1), WEST (-1,0,0), EAST (1,0,0) |
| `Direction.Plane.HORIZONTAL` | NORTH, EAST, SOUTH, WEST (in that order) |
| `Direction.getClockWise()` for a horizontal direction | NORTH to EAST, EAST to SOUTH, SOUTH to WEST, WEST to NORTH |
| `Direction.Axis.getNegative()` | X to WEST, Y to DOWN, Z to NORTH |
| `Direction.getRandom(random)` | the element of the six-direction array at `random.nextInt(6)` (`Util.getRandom` on an array: one `nextInt(length)` draw) |
| `Rotation` (ordinal order) | NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90. `Rotation.getRandom(random)` is `values()[random.nextInt(4)]` |
| `Rotation.rotate(Direction)` | a vertical direction is unchanged; CLOCKWISE_90 uses `getClockWise`, CLOCKWISE_180 the opposite, COUNTERCLOCKWISE_90 `getCounterClockWise` |
| `Util.shuffle(list, random)` | for `i` from `size` down to 2: `j = random.nextInt(i)`; swap the elements at `i - 1` and `j`. `Util.shuffledCopy` copies first (one draw per step, none for a list of one) |
| `Util.getRandom(list or array, random)` | the element at `random.nextInt(size)` (one draw even for one element, see 35-1 section 5.2) |

### 2.2 Numeric helpers (`Mth`)

| Helper | Definition (read) |
|---|---|
| `Mth.randomBetweenInclusive(random, lo, hi)` | `random.nextInt(hi - lo + 1) + lo` |
| `Mth.randomBetween(random, lo, hi)` (float) | `random.nextFloat() * (hi - lo) + lo`, single precision |
| `Mth.clampedLerp(t, a, b)` | `a` when `t < 0`, `b` when `t > 1`, else `a + t * (b - a)` |
| `Mth.inverseLerp(v, lo, hi)` | `(v - lo) / (hi - lo)` |
| `Mth.clampedMap(v, inLo, inHi, outLo, outHi)` | `clampedLerp(inverseLerp(v, inLo, inHi), outLo, outHi)`; a `double` version and a `float` version exist (each in its own precision) |
| `Mth.normal(random, mean, deviation)` (float) | `mean + (float) random.nextGaussian() * deviation` (35-1 section 5.3 for `nextGaussian`) |
| `ClampedNormalFloat.sample(random, mean, deviation, min, max)` | `Mth.clamp(Mth.normal(random, mean, deviation), min, max)` |
| `Mth.sin(d)`, `Mth.cos(d)` (float) | table lookups, **not** `Math.sin`: `SIN[i] = (float) Math.sin(i / 10430.378350470453)` for `i = 0..65535` (a 65536-entry table); `sin(d) = SIN[(int)(long)(d * 10430.378350470453) & 65535]` (the cast is `d2l` truncation toward zero, the mask keeps the low 16 bits); `cos(d)` uses `(long)(d * 10430.378350470453 + 16384.0)` instead |
| `Mth.sqrt(float)` | `(float) Math.sqrt((double) x)` |
| `Mth.invSqrt(double)` | calls `org.joml.Math.invsqrt(double)`, a library that is **not inside the jar**; `1.0 / Math.sqrt(x)` (recalled, not verified, Open question 1) |
| `Mth.getSeed(x, y, z)` and `Mth.getSeed(Vec3i)` | as 10 section 2.4 (`getSeed`) |
| `RandomSource.create(long)` | a `LegacyRandomSource` (the Java LCG of 10 section 2.6) seeded with the value |

### 2.3 Fluid-aware block tests of `SpeleothemUtils` and others

| Name | Meaning (read) |
|---|---|
| `isEmptyOrWater(state)` | `state.isAir()` (air, cave air, void air) or the block is `minecraft:water` (any level) |
| `isNeitherEmptyNorWater(state)` | the negation |
| `isEmptyOrWaterOrLava(state)` | `isEmptyOrWater(state)` or the block is `minecraft:lava` |
| `isBase(state, baseBlock, replaceable)` | `state` is `baseBlock` or in the block set `replaceable` |
| `isBaseOrLava(state, baseBlock, replaceable)` | `isBase` or the block is `minecraft:lava` |
| position forms of the above (`isEmptyOrWater(level, pos)` ...) | `level.isStateAtPosition(pos, predicate)`; on the world-generation level this is the predicate applied to `getBlockState(pos)` (read: `WorldGenRegion.isStateAtPosition` applies the predicate to `getBlockState(pos)`) |
| `placeBaseBlockIfPossible(level, pos, baseBlock, replaceable)` | if the state at `pos` is in `replaceable`: `setBlock(pos, baseBlock.defaultBlockState(), 2)` and return true; else false. **A state that already is `baseBlock` is not in the set (data: `dripstone_replaceable_blocks` is `#base_stone_overworld`) and is left alone, returning false** |
| `LevelReader.isWaterAt(pos)` | the fluid state at `pos` is in the fluid tag `water` |

### 2.4 `Column` and `Column.scan`

A `Column` is one of: a **range** (`floor` and `ceiling` both known: `Range(floor, ceiling)`, `height = ceiling - floor - 1`, and constructing one with a negative height
throws `IllegalArgumentException`), a **ray** up from a floor (`getFloor` present, `getCeiling` empty), a **ray** down from a ceiling (the reverse), or a **line** (neither).
`Column.create(floor, ceiling)` (each an optional int) builds the matching kind (both present: range; only floor: ray up; only ceiling: ray down; neither: line).
`withFloor(f)` is `create(f, ceiling)`; `getHeight()` is present only for a range.

`Column.scan(level, pos, maxSteps, allowed, target)` returns an optional column:

1. If `allowed` is false for the state at `pos`: empty.
2. `ceiling = scanDirection(UP)` and `floor = scanDirection(DOWN)`, each an optional y.
3. Result `Column.create(floor, ceiling)` (so a missing end gives a ray or a line, never an empty optional).

`scanDirection(direction)`: start at `pos` (same x, z, y = `pos.y`); for `i` from 1 while `i < maxSteps` and `allowed(state at cursor)`: move one block in the direction.
After that loop: if `target(state at cursor)` the answer is the cursor's `y`, else "none". The cursor therefore ends on the first block that is not allowed, or after `maxSteps - 1`
moves; the returned `y` is the y of **that block** (the ceiling or floor block itself, not the last free cell). No random draws.

### 2.5 Block entities during generation (supplements 35-1 section 4.1)

`WorldGenRegion.getBlockEntity(pos)` (read) is not a plain read of the chunk. It: (1) returns the chunk's live block entity when there is one; (2) otherwise takes
the chunk's pending block-entity NBT for `pos`; if that NBT has `id == "DUMMY"` (the stub written by `setBlock`, 35-1 section 4.1 step 4): when the block state has no block entity
return null, else create a fresh entity with `EntityBlock.newBlockEntity(pos, state)`; a non-stub NBT is loaded with `BlockEntity.loadStatic`; the entity found is
stored on the chunk (`setBlockEntity`) and returned; (3) with no NBT and a block state that has a block entity, log a warning and return null. A feature that
writes a spawner or chest and then calls `getBlockEntity` therefore gets a usable entity (sections 9 and 10 use this).

---

## 3. Position conventions used below

`origin` is the `pos` argument of `place`. "Write" means `level.setBlock(pos, state, 2)` unless a flag is given; `safeSetBlock(level, pos, state, filter)` is as 35-1 section 2.2
(writes only when `filter` accepts the current state). "Draw" always means a draw on the feature random of 35-1 section 5 (the table of 35-1 section 5.2 defines `nextInt`,
`nextFloat`, `nextDouble`, `nextBoolean`, `nextLong`, `nextGaussian` on that source).

---

## 4. `geode` (`GeodeFeature`)

### 4.1 JSON fields (record `GeodeFeature`)

| Field | Type, range | Default | Used for |
|---|---|---|---|
| `blocks` | record `GeodeBlockSettings` (below) | required | blocks |
| `layers` | record `GeodeLayerSettings` (below) | required (`{}` allowed: all defaults) | layer thresholds |
| `crack` | record `GeodeCrackSettings` (below) | required (`{}` allowed) | crack |
| `use_potential_placements_chance` | double 0 to 1 | 0.35 | chance an inner-layer block can host a bud |
| `use_alternate_layer0_chance` | double 0 to 1 | 0.0 | chance an inner-layer block is the alternate (budding) block |
| `placements_require_layer0_alternate` | boolean | true | whether only alternate blocks can host buds |
| `outer_wall_distance` | `IntProvider` bounded 1 to 20 | uniform 4 to 5 | offsets of the sampling points |
| `distribution_points` | `IntProvider` bounded 1 to 20 | uniform 3 to 4 | number of sampling points |
| `point_offset` | `IntProvider` bounded 0 to 10 | uniform 1 to 2 | per-point offset added to the squared distance |
| `min_gen_offset` | int | -16 | lower corner of the scanned box |
| `max_gen_offset` | int | 16 | upper corner |
| `noise_multiplier` | double | 0.05 | weight of the shape noise |
| `invalid_blocks_threshold` | int | required | how many invalid sample points are tolerated |

`GeodeBlockSettings` fields (all required): `filling_provider`, `inner_layer_provider`, `alternate_inner_layer_provider`, `middle_layer_provider`,
`outer_layer_provider` (each a block state provider, 35-2 section 4; the data uses the simple provider written as `{"id": "minecraft:..."}`), `inner_placements` (a list of block states),
`cannot_replace` (a block set), `invalid_blocks` (a block set).
`GeodeLayerSettings`: `filling` (double 0.01 to 50, default 1.7), `inner_layer` (2.2), `middle_layer` (3.2), `outer_layer` (4.2), same range.
`GeodeCrackSettings`: `generate_crack_chance` (double 0 to 1, default 1.0), `base_crack_size` (double 0 to 5, default 2.0), `crack_point_offset` (int 0 to 10, default 2).

Data in the jar (`amethyst_geode`): filling air, inner `amethyst_block`, alternate inner `budding_amethyst`, middle `calcite`, outer `smooth_basalt`;
`inner_placements` = `small_amethyst_bud`, `medium_amethyst_bud`, `large_amethyst_bud`, `amethyst_cluster`; `cannot_replace` = tag `features_cannot_replace`
(bedrock, spawner, chest, end portal frame, reinforced deepslate, trial spawner, vault); `invalid_blocks` = tag `geode_invalid_blocks` (bedrock, water, lava, ice, packed ice, blue ice);
`invalid_blocks_threshold` 1; `outer_wall_distance` uniform 4 to 6; `use_alternate_layer0_chance` 0.083; `crack` `generate_crack_chance` 0.95; `layers` `{}`.
All other fields take the defaults above (so `use_potential_placements_chance` 0.35, `placements_require_layer0_alternate` true, `distribution_points` uniform 3 to 4, `point_offset` uniform 1 to 2).

### 4.2 The shape noise (`NOISE_PARAMETERS`)

The static field is `NormalNoise.createParity(-4, [1.0])`. As a noise it is one octave with first octave -4 (frequency 2^-4 = 0.0625) and the amplitude list `[1.0]`.
`create(random)` (read in `NormalNoise.create`, the same routine as 10 section 3.3) is applied to a source built **per feature call** from the world seed:
`src = WorldgenRandom(LegacyRandomSource(worldSeed))` (`WorldGenLevel.getSeed()`); the result depends only on the world seed, so an implementation may build it once per world.

1. `A = src.forkPositional()`; `B = src.forkPositional()`. The wrapper delegates to the wrapped `LegacyRandomSource`, whose `forkPositional()` is a factory holding one `nextLong()` of the Java LCG (10 section 2.6). So `A.seed = src.nextLong()`, then `B.seed = src.nextLong()`.
2. The legacy factory's `fromHashOf(name)` is a `LegacyRandomSource` seeded with `(long) name.hashCode() xor factory.seed` (the 32-bit Java `String.hashCode`, sign-extended; read in `LegacyPositionalRandomFactory`).
3. One octave, index -4, seed string `"octave_-4"`: `noiseA = PerlinNoise(A.fromHashOf("octave_-4"))`, `noiseB = PerlinNoise(B.fromHashOf("octave_-4"))` (construction of 10 section 3.1 driven by those two LCG sources).
4. Layers: `(noiseA, frequency 0.0625, amplitude a)` and `(noiseB, frequency 0.0625 * 1.0181268882175227, amplitude a)` with `a = (float)(normalizationFactor * octaveAmplitude)`.
5. The value of `a` for this noise: `createParity` sets the base amplitude to `parityNF / nf0`, where `nf0` is the ordinary normalisation factor of the one-octave noise
   (10 section 3.3: `(sum / 3) / (0.2702247831245211 * |amp| * sqrt 2)`) and `parityNF = (1.0 * 0.5 * (1/3)) / parityExpectedDeviation(0)`, with
   `parityExpectedDeviation(k) = 0.1 * (1 + 1 / (k + 1))` and `k` the spread between the highest and lowest octave slots with a non-zero modifier (here 0). Hence
   `parityNF = (1/6) / 0.2 = 0.8333333...`, and because the ordinary factor cancels, **a = (float) 5/6 = 0.8333333f** (inferred from the read formulas; the cancellation was
   computed by hand, Open question 3).
6. `noise.get(x, y, z)` is the `NoiseStack` value of 10 section 3.2: `acc = 0f; acc = acc + a * noiseA.get(x * 0.0625, y * 0.0625, z * 0.0625)` then the same with `noiseB` and its frequency (float arithmetic).

### 4.3 Placement (numbered, in draw order)

`place(level, generator, random, origin)`:

1. `P = distribution_points.sample(random)` (the number of sampling points).
2. Build the noise of section 4.2 (no draw).
3. Scale constants (doubles): `D = P / outer_wall_distance.maxInclusive()` (the provider's maximum, not a sample);
   `fillT = 1 / sqrt(layers.filling)`; `innerT = 1 / sqrt(layers.inner_layer + D)`; `middleT = 1 / sqrt(layers.middle_layer + D)`; `outerT = 1 / sqrt(layers.outer_layer + D)`;
   `crackT = 1 / sqrt(crack.base_crack_size + r / 2 + X)` with `r = random.nextDouble()` (**one draw**, always) and `X = D` when `P > 3`, else `0`.
4. `crackFlag = random.nextFloat() < crack.generate_crack_chance` (one draw, always; `nextFloat` widened to double).
5. For `i` in `0 .. P - 1`: draw `dx`, `dy`, `dz` = three successive `outer_wall_distance.sample(random)`; `p = origin + (dx, dy, dz)`; read the state at `p`;
   if it is air (`isAir`) or in `invalid_blocks`: increase the invalid count and **return false** when the count exceeds `invalid_blocks_threshold`; then draw `pointOffset.sample(random)`
   and append `(p, that offset)` to the point list.
6. If `crackFlag`: `rr = random.nextInt(4)` (one draw) and `S = 2 * P + 1`; the crack point list gets three positions by `rr`:

   | rr | crack points (each `origin + (...)`, in this order) |
   |---|---|
   | 0 | (S, 7, 0), (S, 5, 0), (S, 1, 0) |
   | 1 | (0, 7, S), (0, 5, S), (0, 1, S) |
   | 2 | (S, 7, S), (S, 5, S), (S, 1, S) |
   | 3 | (0, 7, 0), (0, 5, 0), (0, 1, 0) |

7. Visit every position `q` of the box `origin + (min_gen_offset, min_gen_offset, min_gen_offset)` to `origin + (max_gen_offset, ...)` inclusive, **x fastest, then y, then z slowest** (`BlockPos.betweenClosed`, read in `BlockPos$4`:
   `x = index mod width`, `y = (index / width) mod height`, `z = index / (width * height)`). For each `q`:
   1. `n = (double)(float) noise.get(q.x, q.y, q.z) * noise_multiplier`.
   2. `S1 = sum over the point list of (invSqrt(distSqr(q, point) + (double) pointOffset) + n)`, the points in list order; `distSqr` is the double squared Euclidean distance. **The noise term is added once per point.**
   3. If `S1 < outerT`: skip `q` (nothing written, no draw).
   4. If `S1 >= fillT`: `safeSetBlock(q, filling_provider.getState(level, random, q), state is not in cannot_replace)` and continue.
   5. `S2 = sum over the crack points of (invSqrt(distSqr(q, crackPoint) + (double) crack_point_offset) + n)` (zero when the list is empty).
   6. If `crackFlag` and `S2 >= crackT`: `safeSetBlock(q, air (the default state of minecraft:air), filter)`, then for each of the six directions in order (section 2.1): if the fluid state at `q + direction` is not empty, schedule a tick of that fluid type at that position with delay 0 (`scheduleTick(pos, fluid, 0)`). Continue.
   7. Else if `S1 >= innerT`: `useAlt = random.nextFloat() < use_alternate_layer0_chance` (**one draw**); write `alternate_inner_layer_provider.getState(...)` when `useAlt`, else `inner_layer_provider.getState(...)`, with `safeSetBlock`/`cannot_replace`.
      Then, **only if** `(not placements_require_layer0_alternate) or useAlt` (short-circuit, the next draw happens only then): `random.nextFloat() < use_potential_placements_chance` (one draw); when true append `q` (immutable) to the "potential placements" list.
   8. Else if `S1 >= middleT`: write `middle_layer_provider.getState(...)`.
   9. Else (`S1 >= outerT` holds): write `outer_layer_provider.getState(...)`.
8. For each position `pp` of the potential-placement list in order: `state = innerPlacements[random.nextInt(size)]` (one draw per position, `Util.getRandom`); then for each of the six directions `d` in order:
   1. if `state` has the property `facing`, set it to `d`;
   2. `np = pp + d`; `ns = state at np`;
   3. if `state` has `waterlogged`, set it to "`ns` has a **source** fluid" (`ns.getFluidState().isSource()`);
   4. if `canClusterGrowAtState(ns)` (`BuddingAmethystBlock`: the state is air, or it is the block `minecraft:water` and its fluid state is full, i.e. a source): `safeSetBlock(np, state, not cannot_replace)` and **stop the direction loop for this position**.
9. Return true.

The block states that the `filling`/layer providers return are those of 35-2 section 4. The geode never touches the heightmaps. Block updates and light are not run (35-1 section 4.1).

Notes for implementers:
- The reads of step 7 cover the 33 x 33 x 33 box around the origin, up to 16 blocks beyond the origin column: this exceeds one chunk of margin only when the origin is within 16 blocks of the edge of the writable 3 x 3 window, which the placement (`in_square`) can produce; writes outside the window are rejected by the level (35-1 section 4.1) so the geode is clipped there, silently.
- Budding amethyst growth and the bud growth stages are block behaviour (random ticks) and are not part of generation; the generator only places the blocks.
- With the data (`placements_require_layer0_alternate` true) buds are attempted only next to the alternate (budding) blocks; with `use_alternate_layer0_chance` 0.083 and `use_potential_placements_chance` 0.35, a given inner-layer block becomes a bud host with probability 0.083 * 0.35 (draws: one `nextFloat` per inner block, a second one only for the alternate ones).

---

## 5. `speleothem` (`SpeleothemFeature`) and `SpeleothemUtils`

### 5.1 Fields

| Field | Type | Default |
|---|---|---|
| `base_block` | block state | required (data: `dripstone_block`, given as a bare id string) |
| `pointed_block` | block state | required (data: `pointed_dripstone`) |
| `replaceable_blocks` | block set | required (data: tag `dripstone_replaceable_blocks`, which is `#base_stone_overworld`: stone, granite, diorite, andesite, tuff, deepslate) |
| `chance_of_taller_generation` | float 0 to 1 | 0.2 |
| `chance_of_directional_spread` | float 0 to 1 | 0.7 |
| `chance_of_spread_radius2` | float 0 to 1 | 0.5 |
| `chance_of_spread_radius3` | float 0 to 1 | 0.5 |

The pointed block's properties (24 section for `pointed_dripstone`, id 1223): `thickness` (`tip_merge`, `tip`, `frustum`, `middle`, `base`), `vertical_direction` (the tip direction, `up` or `down`), `waterlogged`.

### 5.2 Placement (`place(level, generator, random, origin)`)

1. `tip = getTipDirection(origin)`: `aboveBase = isBase(state at origin + up, base_block's block, replaceable_blocks)`, `belowBase = isBase(state at origin - up, ...)`.
   Both true: `tip = DOWN` when `random.nextBoolean()` else `UP` (one draw); only `aboveBase`: DOWN (a stalactite hangs from above); only `belowBase`: UP; neither: **return false**.
2. `basePos = origin + opposite(tip)` (the base cell: above the origin for DOWN, below it for UP).
3. `createPatchOfBaseBlocks(basePos)`:
   1. `placeBaseBlockIfPossible(basePos)` (section 2.3).
   2. For each horizontal direction `h` in order (NORTH, EAST, SOUTH, WEST): draw `nextFloat()`; if it is **greater than** `chance_of_directional_spread` go to the next `h`.
      `p1 = basePos + h`; `placeBaseBlockIfPossible(p1)`; draw `nextFloat()`; if greater than `chance_of_spread_radius2` next `h`;
      `p2 = p1 + Direction.getRandom(random)` (one `nextInt(6)` draw); `placeBaseBlockIfPossible(p2)`; draw `nextFloat()`; if greater than `chance_of_spread_radius3` next `h`;
      `p3 = p2 + Direction.getRandom(random)` (one `nextInt(6)` draw); `placeBaseBlockIfPossible(p3)`.
4. `height = 2` when (`random.nextFloat() < chance_of_taller_generation` (one draw, always) **and** the state at `origin + tip` is air or water (`isEmptyOrWater`)), else `1`.
5. `growSpeleothem(level, origin, tip, height, mergedTip = false, base block, pointed block, replaceable_blocks)` (section 5.3).
6. Return true. (The feature returns true even when step 5 wrote nothing.)

### 5.3 `SpeleothemUtils.growSpeleothem` and `buildBaseToTipColumn`

`growSpeleothem(level, pos, tip, height, merge, baseBlock, pointedBlock, replaceable)`:

1. If the state at `pos + opposite(tip)` is **not** `isBase(baseBlock, replaceable)`: do nothing and return.
2. Build the column of `height` pointed blocks starting at `pos` and moving in the direction `tip` one block per piece. The pieces in order (`buildBaseToTipColumn`):
   `height >= 3`: one `base` piece, then `height - 3` `middle` pieces; `height >= 2`: one `frustum` piece; `height >= 1`: one `tip` piece (`tip_merge` instead when `merge`).
   So height 1 is `[tip]`, 2 is `[frustum, tip]`, 3 is `[base, frustum, tip]`, 4 is `[base, middle, frustum, tip]`.
3. Each piece is the pointed block's default state with `vertical_direction = tip` and `thickness = piece`; if the block is the pointed block, `waterlogged = isWaterAt(position)`; it is written with flags 2; then the cursor moves one block in `tip`. **No emptiness test is made**: the pieces overwrite whatever is there. Callers make sure the space is free.

---

## 6. `speleothem_cluster` (`SpeleothemClusterFeature`)

### 6.1 Fields (all required)

`base_block`, `pointed_block`, `replaceable_blocks` (as section 5.1), `floor_to_ceiling_search_range` (int 1 to 512), `height` (IntProvider 1 to 128), `radius` (IntProvider 1 to 128),
`max_stalagmite_stalactite_height_diff` (int 0 to 64), `height_deviation` (int 1 to 64), `speleothem_block_layer_thickness` (IntProvider 0 to 128), `density` (FloatProvider 0 to 2), `wetness` (FloatProvider 0 to 2),
`chance_of_speleothem_at_max_distance_from_center` (float 0 to 1), `max_distance_from_edge_affecting_chance_of_speleothem` (int 1 to 64), `max_distance_from_center_affecting_height_bias` (int 1 to 64).
Data (`dripstone_cluster`): range 12, height uniform 3 to 6, radius uniform 2 to 8, diff 1, deviation 3, layer thickness uniform 2 to 4, density uniform 0.3 to 0.7, wetness clamped normal (mean 0.1, deviation 0.3, min 0.1, max 0.9),
chance at max distance 0.1, edge distance 3, center distance 8.

### 6.2 `place(level, generator, random, origin)`

1. If the state at `origin` is not air or water: return false.
2. Draw, in this order: `height = height.sample` (one cluster value), `wetness = wetness.sample` (float), `density = density.sample` (float), `rx = radius.sample`, `rz = radius.sample`.
3. For `dx` from `-rx` to `rx` (outer) and `dz` from `-rz` to `rz` (inner): `chance = getChanceOfStalagmiteOrStalactite(rx, rz, dx, dz)` and `placeColumn(origin + (dx, 0, dz), dx, dz, wetness, chance, height, density)`.
4. Return true.

`getChanceOfStalagmiteOrStalactite(rx, rz, dx, dz)`: `e = min(rx - |dx|, rz - |dz|)` (ints); result `Mth.clampedMap((float) e, 0, max_distance_from_edge_affecting_chance_of_speleothem, chance_of_speleothem_at_max_distance_from_center, 1.0)` in **float**, widened to double.

`getSpeleothemHeight(random, dx, dz, density, cap)` (the per-column height):
1. Draw `nextFloat()`; if it is **greater than** `density`: return 0.
2. `dist = |dx| + |dz|`; `mean = (float) Mth.clampedMap((double) dist, 0, max_distance_from_center_affecting_height_bias, cap / 2.0, 0.0)` (double arithmetic, then cast to float).
3. `h = ClampedNormalFloat.sample(random, mean, height_deviation, 0, cap)` (mean, deviation, min 0, max `cap`; one `nextGaussian`, section 2.2), cast to int by truncation toward zero.

`placeColumn(level, random, pos, dx, dz, wetness, chance, height, density)`:

1. `Column.scan(level, pos, floor_to_ceiling_search_range, allowed = isEmptyOrWater, target = isBaseOrLava(base_block, replaceable_blocks))` (section 2.4). Empty: return (no draw). Let `ceiling` and `floor` be the optional y values; both absent: return.
2. **Pool.** `poolFlag = random.nextFloat() < wetness` (one draw, always at this point). When `poolFlag` and `floor` is present and `canPlacePool(pos at y = floor)` holds: write `water` (the default state of `minecraft:water`) at `pos.y = floor` (flags 2) and the working column becomes `withFloor(floor - 1)`; otherwise the working column is the scanned one. `floor2` denotes the working column's floor (absent, or `floor - 1`, or `floor`).
   `canPlacePool(p)`: false when the state at `p` is the block `minecraft:water`, the base block or the pointed block; false when the state at `p + up` has a water fluid (fluid tag `water`); otherwise true only when each of the four horizontal neighbours of `p` and the block below `p` "can be adjacent to water": the state is in the block tag `base_stone_overworld` **or** has a water fluid.
3. `stalactiteFlag = random.nextDouble() < chance` (one draw).
4. Stalactite height `hA`: if `ceiling` present and `stalactiteFlag` and the block at `pos.y = ceiling` is not lava: `t = speleothem_block_layer_thickness.sample(random)`; `replaceBlocksWithBaseBlocks(pos at ceiling, t, UP)`; `cap = min(height, ceiling - floor2)` when `floor2` is present, else `height`; `hA = getSpeleothemHeight(random, dx, dz, density, cap)`. Otherwise `hA = 0`.
   `replaceBlocksWithBaseBlocks(p, t, dir)`: for `i` in `0 .. t - 1`: `placeBaseBlockIfPossible(p)`; stop at the first one that returns false; move `p` one block in `dir`.
5. `stalagmiteFlag = random.nextDouble() < chance` (one draw, always, independent of step 4).
6. Stalagmite height `hB`: if `floor2` present and `stalagmiteFlag` and the block at `floor2` is not lava: `t = layer thickness sample`; `replaceBlocksWithBaseBlocks(pos at floor2, t, DOWN)`;
   `hB = max(0, hA + Mth.randomBetweenInclusive(random, -max_stalagmite_stalactite_height_diff, +max_stalagmite_stalactite_height_diff))` when `ceiling` is present, else `getSpeleothemHeight(random, dx, dz, density, height)`. Otherwise `hB = 0`.
7. **Meeting.** If `ceiling` and `floor2` are both present and `ceiling - hA <= floor2 + hB`: `lo = max(ceiling - hA, floor2 + 1)`, `hi = min(floor2 + hB, ceiling - 1)`;
   `meet = Mth.randomBetweenInclusive(random, lo, hi + 1)` (one draw); `hA' = ceiling - meet`; `hB' = (meet - 1) - floor2`. Otherwise `hA' = hA`, `hB' = hB`.
8. `merge = random.nextBoolean()` (**one draw, always**) `and hA' > 0 and hB' > 0 and` the working column has a height (is a range) `and hA' + hB' == that height` (`ceiling - floor2 - 1`).
9. If `ceiling` present: `growSpeleothem(level, pos at y = ceiling - 1, DOWN, hA', merge, ...)` (section 5.3).
10. If `floor2` present: `growSpeleothem(level, pos at y = floor2 + 1, UP, hB', merge, ...)`.

Draw order per column is therefore: (scan: none), `nextFloat` pool, `nextDouble` stalactite flag, [`layer thickness`, per-column height draws], `nextDouble` stalagmite flag, [layer thickness, height draws], [meeting `nextInt`], `nextBoolean`.

---

## 7. `large_dripstone` (`LargeDripstoneFeature`)

### 7.1 Fields

| Field | Type | Default |
|---|---|---|
| `replaceable_blocks` | block set | required (data: `#dripstone_replaceable_blocks`) |
| `floor_to_ceiling_search_range` | int 1 to 512 | 30 |
| `column_radius` | IntProvider 1 to 16 | required; **only its `minInclusive` and `maxInclusive` are used, the provider is never sampled** (data: clamped, min 3, max 16) |
| `height_scale` | FloatProvider 0 to 20 | required (data: uniform 0.4 to 2.0 exclusive) |
| `max_column_radius_to_cave_height_ratio` | float 0.1 to 1 | required (data 0.33) |
| `stalactite_bluntness` | FloatProvider 0.1 to 10 | required (data uniform 0.3 to 0.9) |
| `stalagmite_bluntness` | FloatProvider 0.1 to 10 | required (data uniform 0.4 to 1.0) |
| `wind_speed` | FloatProvider 0 to 2 | required (data uniform 0.0 to 0.3) |
| `min_radius_for_wind` | int 0 to 100 | required (data 4) |
| `min_bluntness_for_wind` | float 0 to 5 | required (data 0.6) |

### 7.2 Height function (`SpeleothemUtils.getSpeleothemHeight(d, radius, scale, bluntness)`, doubles)

Inputs: `d` the horizontal distance from the column axis, `radius` the column radius, `scale`, `bluntness`.

1. `d' = max(d, bluntness)` (if `d < bluntness` use `bluntness`).
2. `t = d' / radius * 0.384`.
3. `a = 0.75 * t^(4/3)` (`Math.pow(t, 1.3333333333333333)`), `b = t^(2/3)` (`Math.pow(t, 0.6666666666666666)`), `c = (1/3) * ln t` (`Math.log`, `0.3333333333333333 * ln t`).
4. `v = scale * (a - b - c)`; `v = max(v, 0)`.
5. Result `v / 0.384 * radius`.

`LargeDripstone.getHeightAtRadius(f)` (f a float) is `(int) getSpeleothemHeight((double) f, (double) radius, scale, bluntness)` (truncation toward zero); `getHeight() = getHeightAtRadius(0.0f)`.

### 7.3 `isCircleMostlyEmbeddedInStone(level, center, radius)`

False when `center` is empty, water or lava (`isEmptyOrWaterOrLava`). Otherwise `step = 6.0f / (float) radius` and for `angle = 0.0f; angle < 6.2831855f; angle += step` (float): `x = (int)(Mth.cos(angle) * radius)`, `z = (int)(Mth.sin(angle) * radius)` (float products truncated toward zero; `Mth.cos`/`sin` are the table functions of section 2.2);
false as soon as `center + (x, 0, z)` is empty, water or lava. If no sample fails: true.

### 7.4 `place(level, generator, random, origin)`

1. If `isEmptyOrWater(origin)` is false: return false.
2. `col = Column.scan(level, origin, floor_to_ceiling_search_range, isEmptyOrWater, isBaseOrLava(dripstone_block, replaceable_blocks))` (the base block is **hard-wired to dripstone block**, not configurable). It must be a range (both ends found), else return false.
3. If `col.height() < 4` (the free cells between floor and ceiling): return false.
4. `maxR = (int)((float) height * max_column_radius_to_cave_height_ratio)` (float product, truncated); `maxR' = clamp(maxR, column_radius.minInclusive(), column_radius.maxInclusive())`;
   `radius = Mth.randomBetweenInclusive(random, column_radius.minInclusive(), maxR')` (**one draw**).
5. Stalactite: root `origin` at `y = col.ceiling - 1`, pointing down; draw `stalactite_bluntness.sample` then `height_scale.sample` (in that order, floats widened to double). Stalagmite: root at `y = col.floor + 1`, pointing up; draw `stalagmite_bluntness.sample`, then `height_scale.sample`. The stalactite object is built first.
6. Wind: if **both** the stalactite and the stalagmite are suitable (`radius >= min_radius_for_wind` and `bluntness >= min_bluntness_for_wind`, comparing the current radius and the bluntness as double): draw `wind_speed.sample` (float `s`) and an angle `phi = Mth.randomBetween(random, 0, 3.1415927f)` (`nextFloat() * pi`, float);
   the wind vector is `(cos(phi) * s, 0, sin(phi) * s)` with `Mth.cos`/`Mth.sin` (section 2.2) and float products widened to double; `originY = origin.y`; `maxOffset = 16 - radius` (the sampled radius). Otherwise no wind: `offset(p) = p`.
   With wind, `offset(p)`: `dy = originY - p.y` (int); `w = windVector * (double) dy` (component-wise); `ox = clamp(floor(w.x), -maxOffset, maxOffset)`, `oz = clamp(floor(w.z), -maxOffset, maxOffset)`; result `p + (ox, 0, oz)`.
7. `okA = stalactite.moveBack(level, offsetter)` then `okB = stalagmite.moveBack(level, offsetter)` (section 7.5, no draws).
8. If `okA`: `stalactite.placeBlocks(level, random, offsetter)`; then if `okB`: `stalagmite.placeBlocks(...)` (section 7.6).
9. Return true (even when neither was placed).

### 7.5 `moveBackUntilBaseIsInsideStoneAndShrinkRadiusIfNecessary`

While `radius > 1`: `cursor = root`; `n = min(10, getHeight())`; for `i` in `0 .. n - 1`:
if the block at `cursor` is lava: return false; if `isCircleMostlyEmbeddedInStone(level, offset(cursor), radius)`: set `root = cursor` and return true; otherwise move `cursor` one block **down** for a stalagmite (pointing up) or **up** for a stalactite.
After the loop, `radius = radius / 2` (integer division) and repeat. When `radius <= 1`: return false. (The object's radius is modified only here.)

### 7.6 `placeBlocks(level, random, offsetter)`

Debug flag (ignored): `SharedConstants.DEBUG_LARGE_DRIPSTONE`, when set, switches the placed block from dripstone block to glass and adds diamond and gold marker blocks (`placeDebugMarkers`). It is false in normal play and an implementation ignores it.

For `dx` from `-radius` to `radius` (outer), `dz` from `-radius` to `radius` (inner):
1. `dist = (float) sqrt(dx * dx + dz * dz)` (float); skip when `dist > radius`.
2. `h = getHeightAtRadius(dist)`; skip when `h <= 0`.
3. Draw `nextFloat()`; if it is `< 0.2`: `h = (int)((float) h * Mth.randomBetween(random, 0.8f, 1.0f))` (a second draw, float product truncated).
4. `cursor = root + (dx, 0, dz)`; `placedAny = false`; `limit` = for a stalagmite the `WORLD_SURFACE_WG` height at that column (`level.getHeight(WORLD_SURFACE_WG, x, z)`, 35-1 section 4.2: the first free y above the terrain; it is **not** updated by feature writes), for a stalactite `Integer.MAX_VALUE`.
5. Repeat `h` times, stopping early when `cursor.y >= limit`: `wp = offset(cursor)`; if `isEmptyOrWaterOrLava(wp)`: `placedAny = true`, write `dripstone_block` at `wp` (flags 2); else if `placedAny` and the state at `wp` is in the block tag `base_stone_overworld`: stop this column. Then move `cursor` one block **up** for a stalagmite, **down** for a stalactite.

Draw count per column: one `nextFloat`, plus one more when the first is below 0.2. Columns with `h <= 0` draw nothing.

---

## 8. `sculk_patch` (`SculkPatchFeature`) and the sculk spreader

### 8.1 Fields (all required)

`charge_count` (int 1 to 32), `amount_per_charge` (int 1 to 500), `spread_attempts` (1 to 64), `growth_rounds` (0 to 8), `spread_rounds` (0 to 8).

### 8.2 `place(level, generator, random, origin)`

1. `canSpreadFrom(origin)` must hold, else return false. `canSpreadFrom`: the block at `origin` is a `SculkBehaviour` block (`sculk` or `sculk_vein`: the only two block classes that implement it, read from their class headers), **or**
   the state is air, or is a water **source** block (`minecraft:water` with a source fluid) **and** at least one of the six neighbours (`Direction.stream()` order) has a state whose collision shape is a full block (`isCollisionShapeFullBlock`).
2. `spreader = SculkSpreader.createWorldGenSpreader()` (section 8.3). `rounds = spread_rounds + growth_rounds`.
3. For `round` from 0 to `rounds - 1`:
   1. `charge_count` times: `spreader.addCursors(origin, amount_per_charge)` (adds cursors until `amount` is used up: each call adds `ceil(amount / 1000)` cursors with `min(1000, remaining)` charge; with `amount_per_charge` at most 500 that is **one cursor of that charge** per call; a cursor is dropped when the list already holds 32).
   2. `spreadFlag = round < spread_rounds`.
   3. `spread_attempts` times: `spreader.updateCursors(level, origin, random, spreadFlag)`.
   4. `spreader.clear()` (drops every cursor).
4. Return true.

Consequence for the data records (`charge_count` 10, `amount_per_charge` 32, `growth_rounds` 0, `spread_rounds` 1, `spread_attempts` 64): one round, ten cursors of charge 32 at `origin`, 64 update passes with the spread flag set.

### 8.3 `SculkSpreader`

| Property | World-generation spreader (`createWorldGenSpreader`) | Level spreader (`createLevelSpreader`, for reference) |
|---|---|---|
| `isWorldGeneration` | true | false |
| replaceable block tag | `sculk_replaceable_world_gen` | `sculk_replaceable` |
| `growthSpawnCost` | 50 | 10 |
| `noGrowthRadius` | 1 | 4 |
| `chargeDecayRate` | 5 | 10 |
| `additionalDecayRate` | 10 | 5 |

Constants: at most 32 cursors; a cursor's charge is at most 1000; a cursor farther than 1024 blocks (Chebyshev distance, `distChessboard`) from the origin passed to `updateCursors` is discarded without being updated.
Tag data (read): `sculk_replaceable` = `#base_stone_overworld`, `#substrate_overworld`, `#terracotta`, `#nylium`, `#base_stone_nether`, sand, red sand, gravel, soul sand, soul soil, calcite, smooth basalt, clay, dripstone block, end stone, red sandstone, sandstone, sulfur, cinnabar;
`sculk_replaceable_world_gen` = `#sculk_replaceable` plus deepslate bricks, deepslate tiles, cobbled deepslate, cracked deepslate bricks, cracked deepslate tiles, polished deepslate; `sculk_growth_inhibitors` = sculk sensor, sculk shrieker.

`updateCursors(level, origin, random, spreadFlag)`:

1. If there are no cursors: return.
2. Process the cursors **in list order**. For each cursor `c`: if `c.pos` is more than 1024 away (Chebyshev) from `origin`: drop it. Else `c.update(level, origin, random, this, spreadFlag)` (section 8.4); then if `c.charge <= 0` drop it (a client-only "discharge" level event 3006 is sent in the live game); else keep it in the new list. In the **live** spreader (not world generation) two kept cursors on the same position are merged when their charges add to at most 1000 (the merged cursor takes the sum and the smaller update delay); **in world generation cursors are never merged**.
3. The cursor list becomes the new list. (A second pass computes level events from the summed charge per position and the facings; it only sends client visuals.)

### 8.4 `ChargeCursor` (fields: `pos`, `charge`, `updateDelay`, `decayDelay`, `facings` as a set of directions or null)

A new cursor from `addCursors` has `decayDelay = 1`, `updateDelay = 0`, `facings = null`.

`update(level, origin, random, spreader, spreadFlag)`:

1. If `charge <= 0`: return. (In world generation there is no other condition; the live game also requires the position to be in a ticking area.)
2. If `updateDelay > 0`: decrement it and return.
3. `state = block at pos`; `behaviour =` the block if it is a `SculkBehaviour`, else the **default behaviour** (section 8.5).
4. If `spreadFlag` and `behaviour.attemptSpreadVein(level, pos, state, facings, isWorldGeneration)` returns true: if `behaviour.canChangeBlockStateOnSpread()` re-read `state` and `behaviour` from the world; (a sound is played, not part of generation).
5. `charge = behaviour.attemptUseCharge(this, level, origin, random, spreader, spreadFlag)`.
6. If `charge <= 0`: `behaviour.onDischarged(level, state, pos, random)`; return.
7. `next = getValidMovementPos(level, pos, random, origin, spreader)` (below). If `next` is not null: `behaviour.onDischarged(level, state, pos, random)`; `pos = next`; `state = block at the new pos`.
   Else if world generation: `behaviour.onDischarged(...)`; `charge = 0`; return (the cursor dies).
8. If the **current** `state` is a `SculkBehaviour` block: `facings = MultifaceBlock.availableFaces(state)` (the set of faces set to true for a vein, the empty set for any other block).
9. `decayDelay = behaviour.updateDecayDelay(decayDelay)` and `updateDelay = behaviour.getSculkSpreadDelay()`, **using the behaviour read in step 3 (the block the cursor stood on before moving)**.

`getValidMovementPos(level, pos, random, origin, spreader)`:
1. `result = pos`. `offsets =` the 18 non-corner neighbour offsets, shuffled with `random` (`Util.shuffledCopy`, draws `nextInt(18)` down to `nextInt(2)`, 17 draws).
   The base list, in order (`BlockPos.betweenClosed((-1,-1,-1), (1,1,1))`, x fastest then y then z, keeping offsets with at least one zero coordinate and excluding (0,0,0)):
   (0,-1,-1); (-1,0,-1), (0,0,-1), (1,0,-1); (0,1,-1); (-1,-1,0), (0,-1,0), (1,-1,0); (-1,0,0), (1,0,0); (-1,1,0), (0,1,0), (1,1,0); (0,-1,1); (-1,0,1), (0,0,1), (1,0,1); (0,1,1).
2. For each offset in shuffled order: `cand = pos + offset`. Skip when `not canMoveToPos(cand, origin, spreader)`: in world generation `(cand.x - origin.x)^2 + (cand.z - origin.z)^2 <= 144` is required (always true outside world generation).
   Read the state at `cand`. If its block is a `SculkBehaviour` **and** `isMovementUnobstructed(level, pos, cand)`: set `result = cand`; if additionally `SculkVeinBlock.hasSubstrateAccess(level, state, cand)` stop the search; else continue (a later candidate may overwrite `result`).
3. Return `null` when `result` equals `pos`, else `result`.

`isMovementUnobstructed(level, a, b)`: true when the Manhattan distance of `a` and `b` is 1. Otherwise `diff = b - a`; `dX = WEST if diff.x < 0 else EAST`, `dY = DOWN if diff.y < 0 else UP`, `dZ = NORTH if diff.z < 0 else SOUTH`.
`isUnobstructed(a, dir)` is "the state at `a + dir` is **not** sturdy on its face toward `opposite(dir)`" (`isFaceSturdy(level, a + dir, opposite(dir))` is false). Result: when `diff.x == 0`: `isUnobstructed(a, dY) or isUnobstructed(a, dZ)`; when `diff.y == 0` (and `diff.x != 0`): `isUnobstructed(a, dX) or isUnobstructed(a, dZ)`; otherwise `isUnobstructed(a, dX) or isUnobstructed(a, dY)`.

`SculkVeinBlock.hasSubstrateAccess(level, state, pos)`: the state is a `sculk_vein` and, for some direction `d` in the six-direction order, the vein has the face `d` and the block at `pos + d` is in the tag `sculk_replaceable` (the level tag, even in world generation).

### 8.5 Block behaviours

**Default behaviour** (every block that is not `sculk` or `sculk_vein`, e.g. air, stone):

| Method | Behaviour |
|---|---|
| `getSculkSpreadDelay()` | 1 |
| `canChangeBlockStateOnSpread()` | true |
| `updateDecayDelay(d)` | `max(d - 1, 0)` |
| `attemptUseCharge(cursor, ...)` | `cursor.charge` when `cursor.decayDelay > 0`, else 0 (the cursor dies) |
| `onDischarged(...)` | nothing |
| `attemptSpreadVein(level, pos, state, facings, worldgen)` | `facings == null`: `veinBlock.sameSpaceSpreader.spreadAll(level.getBlockState(pos), level, pos, worldgen) > 0` (section 8.6). `facings` non-empty: false unless the state is air or its fluid state is the source water fluid object (`Fluids.WATER`, still water; flowing water fails, the fluid tag `water` is not used); then `SculkVeinBlock.regrow(level, pos, state, facings)`. `facings` empty (and non-null): the interface default: `veinBlock.spreader.spreadAll(state, level, pos, worldgen) > 0` |

Pass versus effective update: step 9 of `ChargeCursor.update` sets `updateDelay` to `getSculkSpreadDelay`, which is 1 for the default behaviour, `sculk` and `sculk_vein`. So after every effective update the next spreader pass only decrements `updateDelay` and returns (step 2) without drawing or placing anything: a cursor is effectively updated on every second pass only, at most 32 effective updates in the 64 passes. A cursor standing on a block that is not sculk or vein, with `decayDelay` 1 (its start value): if it has no movement target (step 7) it dies in that same update in world generation; if it moved, `decayDelay` becomes 0 after the first effective update, and `attemptUseCharge` zeroes the charge on its second effective update (the third pass), unless it has moved onto a sculk or vein block, whose `updateDecayDelay` returns 1. When the current block (step 8) is not a `SculkBehaviour` block, `facings` is left unchanged.

**`SculkBlock`** (`sculk`): defaults for delay (1), `updateDecayDelay` (returns 1), `onDischarged` (nothing), `attemptSpreadVein` (the interface default: `veinBlock.spreader.spreadAll(state, level, pos, worldgen) > 0`);
`canChangeBlockStateOnSpread()` is **false**; `attemptUseCharge(cursor, level, origin, random, spreader, spreadFlag)`:
1. `c = cursor.charge`. If `c == 0` or `random.nextInt(spreader.chargeDecayRate) != 0`: return `c` (the draw happens only for `c != 0`).
2. `cp = cursor.pos`; `near = cp.closerThan(origin, noGrowthRadius)` (`distSqr(cp, origin) < noGrowthRadius^2`, doubles).
3. If `near` **or not** `canPlaceGrowth(cp)`: draw `random.nextInt(spreader.additionalDecayRate)`; if non-zero return `c`; else return `c - (near ? 1 : decayPenalty(spreader, origin, cp, c))`.
4. Otherwise (growth): `cost = growthSpawnCost`; draw `random.nextInt(cost)`; if it is `< c`: `above = cp + up`; `state = getRandomGrowthState(level, above, random, spreader.isWorldGeneration)` and `setBlockAndUpdate(above, state)` (flags 3; a sound is played). Return `max(0, c - cost)` (whether or not the draw succeeded).

`canPlaceGrowth(cp)`: the state at `cp + up` is air, or the block `minecraft:water` with a source fluid; **and** `BoxBlockMatcher` over `cp + (-4, 0, -4)` to `cp + (4, 2, 4)` filtered by "the state is in tag `sculk_growth_inhibitors`" matches **at most 2** positions (`atMostMatched(2)` is `not atLeastMatched(3)`).
`decayPenalty(spreader, origin, cp, c)`: `r = noGrowthRadius`; `t = square((float) sqrt(distSqr(origin, cp)) - (float) r)` (float); `m = (24 - r)^2` (int, then float); `f = min(1.0f, t / (float) m)`; result `max(1, (int)((float) c * f * 0.5f))`.
`getRandomGrowthState(level, pos, random, worldgen)`: `random.nextInt(11) == 0` (one draw) gives `sculk_shrieker` with `can_summon = worldgen`, else `sculk_sensor`; if the state has `waterlogged` and the fluid at `pos` is not empty, `waterlogged = true`.

**`SculkVeinBlock`** (`sculk_vein`; a multiface block with six face booleans and `waterlogged`; `DIRECTIONS` is the six-direction order): delay 1, `updateDecayDelay` 1, `canChangeBlockStateOnSpread` true, `attemptSpreadVein` the interface default (spreader over all three spread types, section 8.6).
- `attemptUseCharge(cursor, level, origin, random, spreader, spreadFlag)`: if `spreadFlag` and `attemptPlaceSculk(spreader, level, cursor.pos, random)`: return `charge - 1`. Otherwise: `random.nextInt(chargeDecayRate) == 0 ? floor((float) charge * 0.5f) : charge` (the draw happens in this branch only).
- `attemptPlaceSculk(spreader, level, pos, random)`: `state` = the block at `pos`. For `dir` in `Direction.allShuffled(random)` (a shuffle, 5 draws): skip unless `state` has face `dir`; `p = pos + dir`; skip unless the state at `p` is in `spreader.replaceableBlocks`;
  write `sculk` (default state) at `p` with `setBlockAndUpdate` (flags 3; entities are pushed up by `Block.pushEntitiesUp`, irrelevant during generation; a sound is played); then `veinBlock.spreader.spreadAll(sculkState, level, p, spreader.isWorldGeneration)` (the result is ignored);
  then for each `d2` in the six-direction order except `opposite(dir)`: `q = p + d2`; if the state at `q` is a `sculk_vein`: `onDischarged(level, thatState, q, random)`. Return true after the first direction that worked; return false if none did.
- `onDischarged(level, state, pos, random)`: nothing unless the state is a `sculk_vein`. For each `d` in the six-direction order: if the vein has face `d` and the block at `pos + d` is `sculk`, clear that face (`false`). If **no** face is left: replace the vein by air, or by `water` (the block, default state) when the fluid state at `pos` is non-empty. Write the resulting state with `setBlockAndUpdate`.
- `regrow(level, pos, state, directions)`: start from the default `sculk_vein` state; for each direction in the given collection: if `MultifaceBlock.canAttachTo(level, pos, dir)` (the neighbour at `pos + dir` has a full face toward `opposite(dir)` in its support or collision shape, 35-4 section 8.1) set that face and remember success. If none succeeded: false. When the state at `pos` has a fluid, set `waterlogged = true`. `setBlockAndUpdate(pos, newState)`; true.

### 8.6 The vein spreaders (`MultifaceSpreader`)

The generic pieces (`SpreadType`, `canAttachTo`, `hasFace`, `isValidStateForPlacement`, `getStateForPlacement`, `getSpreadFromFaceTowardDirection`, `placeBlock`) are those of 35-4 section 8.1; this part adds what sculk needs.
Spread types, ordered: `SAME_POSITION` gives `(pos, dir)`, `SAME_PLANE` gives `(pos + dir, face)`, `WRAP_AROUND` gives `(pos + dir + face, opposite(dir))` where `face` is the source face and `dir` the spread direction (`SpreadPos` is a position and a face).
`SculkVeinBlock` owns two spreaders built on `SculkVeinSpreaderConfig`: `spreader` (the three types in the order SAME_POSITION, SAME_PLANE, WRAP_AROUND) and `sameSpaceSpreader` (only SAME_POSITION).

| Config term (`SculkVeinSpreaderConfig`) | Rule (read) |
|---|---|
| `isOtherBlockValidAsSource(state)` | true when the state is **not** `sculk_vein` (so a sculk block, air, or stone can act as a source of veins) |
| `canSpreadFrom(state, face)` | `isOtherBlockValidAsSource(state) or hasFace(state, face)` |
| `getSpreadFromFaceTowardDirection(state, level, pos, face, dir)` (generic) | empty when `dir` and `face` share an axis; empty when `isOtherBlockValidAsSource(state)` is false and (`hasFace(state, face)` is false or `hasFace(state, dir)` is true); else the first spread type (in the spreader's order) whose spread position passes `canSpreadInto` |
| `canSpreadInto(level, source, spreadPos)` | `stateCanBeReplaced(level, source, spreadPos.pos, spreadPos.face, state at spreadPos.pos)` and `block.isValidStateForPlacement(level, state, spreadPos.pos, spreadPos.face)` |
| `stateCanBeReplaced(level, A, B, dir, state)` | (1) let `n` be the state at `B + dir`; false when `n` is `sculk`, `sculk_catalyst` or `moving_piston`. (2) when the Manhattan distance of `A` and `B` is 2: `c = A + opposite(dir)`; false when the state at `c` is sturdy on its face `dir` (`isFaceSturdy(level, c, dir)`). (3) false when `state` has a non-empty fluid that is not source water (compared with `Fluids.WATER`, the still fluid; flowing water therefore counts as non-water and replacement is refused). (4) false when `state` is in the block tag `fire`. (5) otherwise true when `state.canBeReplaced()` or when the default multiface rule holds (air, or this block, or a water source block) |

`spreadAll(state, level, pos, postProcess)`: for each direction `face` of the six (order) for which `canSpreadFrom(state, face)`: `spreadFromFaceTowardAllDirections(state, level, pos, face, postProcess)`;
the return value is the sum. `spreadFromFaceTowardAllDirections` tries every `dir` of the six (order) with `spreadFromFaceTowardDirection(state, level, pos, face, dir, postProcess)` (find the spread position as above, then place the block with `placeBlock`: write the vein state with flags 2) and counts the successes.
The `state` argument is the **source's** state, fixed for the whole call; the world changes between the attempts. No random draws.

### 8.7 What a patch does (summary, inferred from the rules above)

Cursors start at `origin` with charge 32. A cursor on air first plants veins in its own cell (the same-space spreader) on every face that touches a block with a full face; it then needs a neighbouring `sculk` or `sculk_vein` cell reachable without a blocking sturdy face to move to
(within 12 blocks horizontally of the origin); otherwise, with no movement target, it dies in that same update (step 7). On a vein with the spread flag set it converts an adjacent `sculk_replaceable_world_gen` block to `sculk` (charge minus 1) and spreads veins from the new block;
on a `sculk` block it decays or, when the area has at most two sensors/shriekers within the 9 x 3 x 9 box and the cell above is air or water, grows a sensor or (1 in 11) a shrieker above it at the cost of `growthSpawnCost` charge.

---

## 9. `monster_room` (`MonsterRoomFeature`)

No fields (the codec is a unit codec). The filter used for every `safeSetBlock` of this feature is "the state is **not** in the block tag `features_cannot_replace`". Air written by this feature is **cave air** (`minecraft:cave_air`).
The spawner mobs array is `[skeleton, zombie, zombie, spider]`.

`place(level, generator, random, origin)`, with `solid(p)` meaning `state.isSolid()` (the legacy "solid" flag of 24 section 5.2, not `isSolidRender`) and `empty(p)` meaning `isEmptyBlock` (the state is air):

1. `rx = random.nextInt(2) + 2` (2 or 3); `xMin = -rx - 1`, `xMax = rx + 1`. `rz = random.nextInt(2) + 2`; `zMin = -rz - 1`, `zMax = rz + 1`. The y range is `-1 .. 4`. (x is drawn first.) The box is `(2 * rx + 3)` by 6 by `(2 * rz + 3)` cells.
2. **Check pass**: `count = 0`; for `x` from `xMin` to `xMax` (outer), `y` from -1 to 4, `z` from `zMin` to `zMax` (inner): `p = origin + (x, y, z)`, `s = solid(p)`.
   If `y == -1` and not `s`: **return false**. If `y == 4` and not `s`: **return false**.
   If (`x` is `xMin` or `xMax`, or `z` is `zMin` or `zMax`) and `y == 0` and `empty(p)` and `empty(p + up)`: `count = count + 1`.
   After the loops: if `count < 1` or `count > 5`: **return false**.
3. **Carve pass**: for `x` from `xMin` to `xMax` (outer), `y` from **3 down to -1**, `z` from `zMin` to `zMax` (inner): `p`, `st = state at p`:
   - If `x` is `xMin` or `xMax`, or `y == -1`, or `y == 4` (never reached here: the loop starts at 3), or `z` is `zMin` or `zMax` (a wall, floor or ceiling cell, in practice a wall or floor cell):
     - if `p.y >= level.getMinY()` and the block below `p` is **not** solid: write cave air at `p` with flags 2 and **no filter** (this removes wall cells that have nothing under them, so the room never has a floating wall);
     - else if `st` is solid and `st` is not a chest: if `y == -1` and `random.nextInt(4) != 0` (draw only when `y == -1`): `safeSetBlock(p, mossy_cobblestone)`; otherwise `safeSetBlock(p, cobblestone)`;
     - else nothing.
   - Otherwise (an interior cell): if `st` is neither a chest nor a spawner: `safeSetBlock(p, cave air)`.
4. **Chests**: repeat 2 times (`k`): up to 3 attempts (`t`):
   `cx = origin.x + random.nextInt(2 * rx + 1) - rx`; `cy = origin.y`; `cz = origin.z + random.nextInt(2 * rz + 1) - rz` (x drawn before z); `p = (cx, cy, cz)`;
   if not `empty(p)` go to the next attempt; `solidNeighbours` = the number of the four horizontal neighbours (NORTH, EAST, SOUTH, WEST) of `p` with `solid`; if it is not exactly 1 go to the next attempt;
   otherwise `safeSetBlock(p, StructurePiece.reorient(level, p, chestDefaultState))` (section 9.1), then set the chest's loot table `minecraft:chests/simple_dungeon` with seed `random.nextLong()` (`RandomizableContainer.setBlockEntityLootTable`: the block entity is obtained as in section 2.5, and `nextLong` is **two** wrapper draws, 35-1 section 5.2), and stop the attempts of this `k` (go to the next `k`).
5. **Spawner**: `safeSetBlock(origin, spawner default state)`; `be = getBlockEntity(origin)` (section 2.5); if it is a spawner entity: `entity = MOBS[random.nextInt(4)]`; `setEntityId(entity, random)`, which writes `id = <entity type key>` into the spawner's current spawn data; the spawner's potential-spawn list is initially empty so **no further draw** is made (`WeightedList.getRandom` of an empty list returns empty without drawing); otherwise log an error. Return true.

Defaults of a freshly created spawner (not changed by this feature): spawn delay 20, min spawn delay 200, max spawn delay 800, spawn count 4, max nearby entities 6, required player range 16, spawn range 4 (`BaseSpawner` constants).

### 9.1 `StructurePiece.reorient(level, pos, chestState)` (chest orientation)

1. For each horizontal direction `d` in order (NORTH, EAST, SOUTH, WEST): `n = state at pos + d`; if `n` is a chest: **return `chestState` unchanged**. If `n.isSolidRender()`: when no candidate is held, hold `d`; when one is already held, drop it (set to none) and stop scanning.
2. If a candidate `d` is held: return `chestState` with `facing = opposite(d)`.
3. Otherwise `dir =` the `facing` of `chestState` (the default chest faces NORTH; read in `ChestBlock`, default state FACING = NORTH); if the block at `pos + dir` is `isSolidRender`: `dir = opposite(dir)`; if the block at `pos + dir` is then `isSolidRender`: `dir = clockwise(dir)`; if the block at `pos + dir` is then `isSolidRender`: `dir = opposite(dir)`; return `chestState` with `facing = dir`.

---

## 10. Templates: `fossil`, `template` and the engine they call

### 10.1 `template` (`TemplateFeature`) fields and placement

Fields: `templates` (a weighted list of entries, written `[{"data": {"id": "<template id>", "rotations": [..optional..]}, "weight": n}, ...]`; `rotations` defaults to all four rotations in the order of section 2.1), `processors` (an optional processor list).

`place(level, generator, random, origin)`:
1. `entry = templates.getRandomOrThrow(random)` (`random.nextInt(totalWeight)` then the weighted pick; one draw even for one entry); `rotation = rotations[random.nextInt(size)]` (`Util.getRandom` on the list).
2. `template = structureTemplateManager.getOrCreate(entry.id)` (section 10.3; an unknown id gives an empty template).
3. `offX = rotation.rotate(WEST).unitVector * (template.size.x / 2)` and `offZ = rotation.rotate(NORTH).unitVector * (template.size.z / 2)` (integer division, the **unrotated** size); `pos = origin + offX + offZ`.
4. `settings = StructurePlaceSettings` with `rotation`, `random` = the feature random, and (when `processors` is present) every processor of the list added in order.
5. Return `template.placeInWorld(level, pos, pos, settings, random, flags = 3)` (section 10.5): the `pos` is both the placement origin and the pivot, and the rotation pivot of the settings is the template's own (0,0,0).

Effect (computed): a template of size (X, Y, Z) is centred on `origin` in x and z for every rotation (worked example in section 11.6).

### 10.2 `fossil` fields and placement

Fields: `fossil_structures` (non-empty list of template ids), `overlay_structures` (non-empty list, **the same length**: "Fossil structure lists must be equal lengths"), `fossil_processors` and `overlay_processors` (a processor list: a registry id or an inline `{"processors": [...]}`), `max_empty_corners_allowed` (int 0 to 7).
Data: both records list `spine_1..4` and `skull_1..4`; overlays `spine_1_coal .. skull_4_coal` (the diamond fossil also uses the coal overlay templates); `fossil_processors` = `fossil_rot`; `overlay_processors` = `fossil_coal` or `fossil_diamonds`; `max_empty_corners_allowed` 4.

`place(level, generator, random, origin)`:
1. `rotation = Rotation.getRandom(random)` (`nextInt(4)`); `idx = random.nextInt(fossil_structures.size())`.
2. `fossil = getOrCreate(fossil_structures[idx])`, `overlay = getOrCreate(overlay_structures[idx])`.
3. `chunk = ChunkPos.containing(origin)`; `bounds` = the box with min corner `(chunkMinX - 16, level.minY, chunkMinZ - 16)` and max corner `(chunkMaxX + 16, level.maxY, chunkMaxZ + 16)` (the 3 x 3 chunks around the origin's chunk, full height).
4. `settings = new StructurePlaceSettings().setRotation(rotation).setBoundingBox(bounds).setRandom(random)` (mirror none, pivot (0,0,0), liquid setting `APPLY_WATERLOGGING`, `ignoreEntities` false, known shape false, finalize entities false).
5. `size = fossil.getSize(rotation)` (section 10.4: x and z swap for the two quarter turns). `corner = origin + (-size.x / 2, 0, -size.z / 2)` (integer division truncating toward zero, `(-sx) / 2`).
6. `y = origin.y`; for `i` in `0 .. size.x - 1` (outer) and `j` in `0 .. size.z - 1`: `y = min(y, level.getHeight(OCEAN_FLOOR_WG, corner.x + i, corner.z + j))` (35-1 section 4.2).
7. `base = max(y - 15 - random.nextInt(10), level.getMinY() + 10)` (one draw, evaluated after the rotation and index draws).
8. `zero = fossil.getZeroPositionWithTransform(corner at y = base, Mirror.NONE, rotation)` (section 10.4).
9. `box = fossil.getBoundingBox(settings, zero)`; `countEmptyCorners(box)` counts the 8 corners of the box whose block is air, lava or water (`isAir`, or the blocks `lava`, `water`); if the count is greater than `max_empty_corners_allowed`: **return false**.
10. `settings.clearProcessors()`, add every processor of `fossil_processors` in order, `fossil.placeInWorld(level, zero, zero, settings, random, flags = 260)`.
11. `settings.clearProcessors()`, add every processor of `overlay_processors`, `overlay.placeInWorld(level, zero, zero, settings, random, 260)` (the same `zero`, rotation and bounds, so the overlay lines up with the fossil).
12. Return true.

Flags 260 are `UPDATE_NONE` (4 + 256, 29 section 1). The template draws on the feature random are those of section 10.5 (palette choice, `block_rot`).

### 10.3 Template files and the manager

`StructureTemplateManager.getOrCreate(id)`: returns the cached template; otherwise tries the template sources in order (the data pack resource `data/<namespace>/structure/<path>.nbt`, a world folder, ...) and caches the result; **when none has it an empty template is created and cached** (no palette, size (0,0,0)); placing an empty template returns false without writing.
File format (gzip-compressed NBT; read from the jar's files and from `StructureTemplate.load`): root compound with `DataVersion` (ignored here), `size` (list of three ints x, y, z), `blocks` (list of compounds `{pos: [x, y, z], state: int index into the palette, nbt: optional compound}`),
`palette` (a list of block states, each `{id: "minecraft:...", properties: {name: "value" (strings)}}`; properties are strings) **or** `palettes` (a list of such lists, several variants), `entities` (a list; empty in every template used by this document's features).
When both exist `palettes` wins. The `nbt` compound of a block is the block entity's data (`{id: ..., components: ...}` for the desert-well sand).

Order of the blocks of a palette (`buildInfoList`): the blocks are split into three lists: **(A)** blocks without `nbt` whose block has no dynamic shape and whose state's collision shape (queried against an empty level at (0,0,0)) is a full block; **(B)** blocks with `nbt`; **(C)** every other block.
Each list is sorted by `y`, then `x`, then `z` (ascending, `y` the primary key). The palette's block list is **A, then C, then B**. This order is the placement order and also the order in which `block_rot` draws.

### 10.4 Geometry (`StructureTemplate`)

| Function | Definition (read; block coordinates; `pivot` the settings' rotation pivot) |
|---|---|
| `getSize(rotation)` | `(size.z, size.y, size.x)` for CLOCKWISE_90 and COUNTERCLOCKWISE_90, else `size` |
| `transform(pos, mirror, rotation, pivot)` | first mirror: LEFT_RIGHT negates `z`, FRONT_BACK negates `x`, NONE nothing (`pos` is relative, so the negation is about 0). Then rotate about `(px, pz)`: NONE: unchanged; CLOCKWISE_90: `(px + pz - z, y, pz - px + x)`; CLOCKWISE_180: `(2 px - x, y, 2 pz - z)`; COUNTERCLOCKWISE_90: `(px - pz + z, y, px + pz - x)`. With pivot (0,0,0): CLOCKWISE_90 is `(x, z) to (-z, x)`, COUNTERCLOCKWISE_90 is `(x, z) to (z, -x)` |
| `getZeroPositionWithTransform(pos, mirror, rotation)` | with `sx = size.x - 1`, `sz = size.z - 1` (of the **unrotated** template), `dx = sx` when mirror is FRONT_BACK else 0, `dz = sz` when mirror is LEFT_RIGHT else 0: NONE: `pos + (dx, 0, dz)`; CLOCKWISE_90: `pos + (sz - dz, 0, dx)`; CLOCKWISE_180: `pos + (sx - dx, 0, sz - dz)`; COUNTERCLOCKWISE_90: `pos + (dz, 0, sx - dx)`. The result is the placement origin that makes the transformed template's minimum corner sit at `pos` |
| `getBoundingBox(settings, origin)` | the box with corners `transform((0,0,0))` and `transform((size.x - 1, size.y - 1, size.z - 1))` (settings' mirror, rotation, pivot), normalised (min/max per axis), then moved by `origin` |
| world position of a template block | `origin + transform(block.pos, mirror, rotation, pivot)` |

Block-state rotation (`BlockState.rotate(rotation)`, then `mirror`): block-specific (24). For the pillar blocks used by the fossils (`bone_block` with `axis`), `rotatePillar`: for CLOCKWISE_90 and COUNTERCLOCKWISE_90 the axis `x` becomes `z` and `z` becomes `x`; `y` and the 180 degree rotation leave it unchanged.

### 10.5 `StructureTemplate.placeInWorld(level, origin, pivot, settings, random, flags)` (as the features call it)

Returns false at once when the template has no palette, or when the chosen palette has no blocks and (entities are ignored, or there are no entities, or the size has a component below 1).

1. `palette =` `settings.getRandomPalette(palettes, origin)`: `random' = settings.random` when set (the feature's random), otherwise a fresh `RandomSource` from `Mth.getSeed(origin)` (a Java-LCG source; when the pos argument is null the source is seeded from the current time, `Util.getMillis`, a case the three features here never reach since they always set the random); the palette index is `random'.nextInt(paletteCount)` (**one draw even when there is one palette**).
2. `blocks = processBlockInfos(level, origin, pivot, settings, palette.blocks)` (below), `bounds = settings.boundingBox` (may be null).
3. Walk the processed blocks in order. For each block `b` at world position `wp`: skip it when `bounds` is set and `wp` is outside it. Remember `fluid = level.getFluidState(wp)` when waterlogging is applied (default).
   `state = b.state.mirror(settings.mirror).rotate(settings.rotation)`.
   If `b` has `nbt`: first write `barrier` at `wp` with flags 820 (clears a container there; an implementation without containers may skip this write).
   Write `state` at `wp` with `flags`. If the write succeeded: extend the written-region extent; record `(wp, nbt)`; when `nbt` is present: take the block entity at `wp` (section 2.5); if it is a `RandomizableContainer` (and the debug edit-mode flag is off) set `nbt.LootTableSeed = random.nextLong()` (**two draws**, before loading), then load the block entity from `nbt`.
   Waterlogging (default `APPLY_WATERLOGGING`): when `fluid` was recorded: if `state`'s fluid is a source, add `wp` to the "source" list; else if the block can hold liquid (`LiquidBlockContainer`): place the liquid into it and, if the old fluid was not a source, add `wp` to the "flowing" list. After the walk, repeat while something changed and the flowing list is non-empty: for each position in it, take its fluid, and (for the neighbours UP, NORTH, EAST, SOUTH, WEST while the fluid is not a source) adopt a neighbouring **source** fluid that is not in the source list; when the position then holds a source fluid and its block is a `LiquidBlockContainer`, place the liquid and remove the position from the list.
4. If the written extent is non-empty and the shape is not "known" (`flags` bit 16 clear, the settings' known-shape flag false): build a bit set of the written positions and call `updateShapeAtEdge`: for every boundary face between a written cell and an unwritten cell, run `updateShape` on both blocks toward each other (35-1 section 4.1: the world-generation level treats the flags as 35-1 section 4.1 step 8; 29 section 3.2 for `updateShape`) writing the results with `flags & ~2`.
   Then, for every written block, `Block.updateFromNeighbourShapes(state, level, pos)`; when it differs write it with `(flags & ~2) | 16` and update the neighbours; mark the block entities changed.
5. Entities of the template are placed unless the settings ignore entities (none of the templates used by these features has any).
6. Return true.

`processBlockInfos(level, origin, pivot, settings, blocks)`:
1. `evaluatesEntirePiece = any processor reports it` (the three processors of this document report false).
2. For each template block in order: `wp = origin + transform(b.pos, mirror, rotation, rotationPivot)`; when no processor evaluates the entire piece and the settings' bounding box is set and `wp` is outside it: **skip the block before any processor runs** (no draws are consumed for it). Otherwise `info = (wp, b.state, copy of b.nbt)`; run the processors in order: `info = processor.processBlock(level, origin, pivot, rawBlock, info, settings)` until one returns null (the block is dropped).
3. Then every processor's `finalizeProcessing` runs on the lists; the three processors here do nothing in it.

Processors (`processor_type`):

| Type | Fields | Behaviour (read) |
|---|---|---|
| `minecraft:block_rot` (`BlockRotProcessor`) | `integrity` (float 0 to 1, required), `rottable_blocks` (optional block set) | `random' = settings.getRandom(info.pos)` (the settings' random when set). If `rottable_blocks` is present and the block's state is **not** in it: keep the block (no draw). Otherwise draw `random'.nextFloat()`: when it is **greater than** `integrity` the block is **dropped** (null), else kept. So a block survives with probability `integrity` |
| `minecraft:protected_blocks` (`ProtectedBlockProcessor`) | `value` (block set, required) | drop the block when the state **currently in the world** at `info.pos` is in the set, else keep. No draw |
| `minecraft:rule` (`RuleProcessor`) | `rules` (list of rules) | `random'' = RandomSource.create(Mth.getSeed(info.pos))` (a new Java-LCG source per block, **not** the feature random). For each rule in order: if `rule.test(...)` passes, return a block at the same position with `rule.outputState` and `rule.getOutputTag(random'', info.nbt)`; the first matching rule wins; with no match the block is unchanged |

`ProcessorRule` fields: `input_predicate` (a rule test, tested on the template block's state), `location_predicate` (a rule test, tested on the state **currently in the world** at the position), `position_predicate` (optional, default `always_true`), `output_state` (a block state), `block_entity_modifier` (optional, default `passthrough`).
A rule passes when all three predicates pass. The rule tests that the data uses here: `block_match` (`block`: the state is that block), `always_true`; position test `always_true`.
Block-entity modifiers: `passthrough` (the nbt unchanged); `append_loot` (`loot_table`): a copy of the nbt (an empty compound when none) with `LootTable = <the key>` and `LootTableSeed = random''.nextLong()` (the legacy source of the `rule` processor; one `nextLong` of the Java LCG, 10 section 2.6).
Processor lists of the data (read): `fossil_rot` = `[block_rot 0.9, protected_blocks #features_cannot_replace]`; `fossil_coal` = `[block_rot 0.1, protected_blocks #features_cannot_replace]`;
`fossil_diamonds` = `[block_rot 0.1, rule (coal_ore, always_true, always_true) to deepslate_diamond_ore, protected_blocks #features_cannot_replace]`.
Other processors and rule tests exist in the jar (`block_ignore`, `block_age`, `blackstone_replace`, `capped`, `gravity`, `jigsaw_replacement`, `lava_submerged_block`, `nop`, `random_block_match`, `block_state_match`, `tag_match`, `all_of`, `any_of`, `not`, `height_match`, `linear_pos`, `axis_aligned_linear_pos`, ...): they are part of the structure round (RS20) and are not read here.

---

## 11. Worked examples

### 11.1 Geode thresholds (computed from section 4.3 step 3, default layers)

| P | `outer_wall_distance.max` | D | `fillT` | `innerT` | `middleT` | `outerT` | `crackT` for `r = 0.5` (`base 2.0`) |
|---|---|---|---|---|---|---|---|
| 3 | 6 | 0.5 | 0.766965 | 0.608581 | 0.519875 | 0.461266 | `1 / sqrt(2.25 + 0)` = 0.666667 |
| 4 | 6 | 0.666667 | 0.766965 | 0.590624 | 0.508548 | 0.453298 | `1 / sqrt(2.25 + 0.666667)` = 0.585540 |

With `P = 3`, noise 0 and every point offset 2: a block whose squared distance to all three points is 16: `3 * invSqrt(18)` = 0.707107, which is below `fillT` and at least `innerT`: **inner layer**. Squared distance 25: `3 * invSqrt(27)` = 0.577350: at least `middleT`, below `innerT`: **middle layer** (calcite).
Squared distance 36: `3 * invSqrt(38)` = 0.486664: at least `outerT`, below `middleT`: **outer layer** (smooth basalt). A block at distance 0 with offset 1 to all three points: `3 * invSqrt(1)` = 3.0, at least `fillT`: filling (air). The outer-layer cutoff is where `3 / sqrt(d + 2) < outerT` = 0.461266, i.e. `d + 2 > 42.30`, a squared distance of about 40 (between 40 and 41): `d = 40` gives 0.4629 (still outer layer), `d = 41` gives 0.4575 (untouched). The sample value 0.4201 (`d = 49`) is below `outerT`, so it is untouched, but 49 is not the boundary.

### 11.2 `speleothem` on a stone floor (section 5)

`origin` is the air cell at `y = 11` above stone at `y = 10`, with stone also at `y = 12 + k` unreachable. `aboveBase` false (air), `belowBase` true: `tip = UP`, `basePos = (x, 10, z)`.
The base becomes dripstone block; neighbours are converted by the draw rules; then, with `nextFloat = 0.9` (not below 0.2): `height = 1`, `growSpeleothem(origin, UP, 1)`: the cell below `origin` is now dripstone, a `[tip]` piece is written at `y = 11` (`thickness = tip`, `vertical_direction = up`).
With `nextFloat = 0.1` and air at `y = 12`: `height = 2`: `frustum` at `y = 11`, `tip` at `y = 12`.

### 11.3 `getSpeleothemHeight` of the large dripstone (section 7.2, computed with doubles)

| `d` | `radius` | `scale` | `bluntness` | result | `(int)` |
|---|---|---|---|---|---|
| 0 | 6 | 1.0 | 0.5 | 16.4713 | 16 |
| 3 | 6 | 1.0 | 0.5 | 4.6929 | 4 |
| 6 | 6 | 1.0 | 0.5 | 0.00096 | 0 |
| 0 | 10 | 1.0 | 0.3 | 37.4696 | 37 |
| 5 | 10 | 1.0 | 0.3 | 7.8215 | 7 |
| 0 | 6 | 2.0 | 0.5 | 32.9427 | 32 |
| 0 | 3 | 0.4 | 0.4 | 2.7095 | 2 |

The column height is clamped by the walk of section 7.6 (to the cave and the heightmap limit); a column of the data's radius range (3 to 16) is therefore as tall as `scale` and `bluntness` make it, bounded by the cave.
Wind example: `windSpeed 0.3`, `phi = 0`, `originY = 70`, `radius = 6` so `maxOffset = 10`: for a cell at `y = 65`, `dy = 5`, `w = (cos 0 * 0.3 * 5, 0, 0) = (1.5, 0, 0)` (using the table `cos(0) = 1`), `floor` gives `ox = 1`, `oz = 0`.

### 11.4 Cluster probabilities and heights (section 6.2)

`chance` for `rx = rz = 5`, `chance at max distance` 0.1, `edge distance` 3: `dx = 0, dz = 0`: `e = 5`, `clampedMap(5, 0, 3, 0.1, 1.0) = 1.0`; `dx = 4, dz = 0`: `e = 1`, `0.1 + 0.9 / 3 = 0.4`; `dx = dz = 5`: `e = 0`, `0.1`; for `rx = 5, rz = 3, dx = 2, dz = 1`: `e = min(3, 2) = 2`, `0.1 + 0.9 * 2 / 3 = 0.7`.
Height mean (`height_bias distance` 8, `cap` 3, `dist = 4`): `clampedMap(4, 0, 8, 1.5, 0) = 0.75`; at `dist = 0`, `cap = 6`: mean 3.0 (then the clamped normal with deviation `height_deviation`, truncated).
Meeting: `ceiling = 20`, `floor2 = 10`, `hA = 6`, `hB = 5`: `20 - 6 = 14 <= 10 + 5 = 15`, `lo = max(14, 11) = 14`, `hi = min(15, 19) = 15`, `meet` is drawn in `[14, 16]`: `meet = 15` gives `hA' = 5` (cells 19..15) and `hB' = 4` (cells 11..14), touching at 14|15; `meet = 14` gives 6 and 3; `meet = 16` gives 4 and 5. In all three the two columns fill the free span `11..19` exactly (9 cells), so `merge` can be true.

### 11.5 Monster room dimensions and checks (section 9)

`rx = 2`, `rz = 3`: `x` from -3 to 3 (7 cells), `z` from -4 to 4 (9 cells), `y` from -1 to 4: the shell is the cells at the box faces; the room interior is `x` -2..2, `z` -3..3, `y` 0..3 (5 x 7 x 4 = 140 cells). `rx = rz = 3` gives interior 7 x 7 x 4. A room passes the check pass when the whole floor row `y = -1` and ceiling row `y = 4` are solid and between 1 and 5 wall-adjacent cells at `y = 0` are open (air with air above).
A chest attempt succeeds only on an air cell at `origin.y` with exactly one solid horizontal neighbour (an interior cell next to a wall, not in a corner).

### 11.6 Fossil and template geometry (sections 10.2 and 10.4)

Fossil `spine_1` has size (3, 3, 13); the origin is (100, 20, 200); rotation CLOCKWISE_90. `getSize` gives (13, 3, 3). `corner = (100 - 6, 20, 200 - 1) = (94, 20, 199)` (`-13 / 2 = -6`, `-3 / 2 = -1`).
Suppose the minimum of `OCEAN_FLOOR_WG` heights over the 13 x 3 footprint is 64 and `nextInt(10)` gave 4: `base = max(64 - 15 - 4, -64 + 10) = 45`. `zero = (94, 45, 199) + (sz - dz, 0, dx)` with `sx = 2`, `sz = 12`, `dx = dz = 0` (no mirror): `(94 + 12, 45, 199) = (106, 45, 199)`.
The bounding box: corners `transform((0,0,0)) = (0,0,0)` and `transform((2,2,12))` with CLOCKWISE_90 about (0,0,0) `(x, z) to (-z, x)` = `(-12, 2, 2)`; the box is x -12..0, y 0..2, z 0..2, moved by `zero`: x 94..106, y 45..47, z 199..201. It covers exactly the corner's 13 x 3 footprint in x and z.
Block rotation for these templates: a bone block with `axis = z` becomes `axis = x` under CLOCKWISE_90.

Template feature (desert well well of size (5, 7, 5)): `size / 2 = (2, 3, 2)` so the offsets use 2: rotation NONE: `offX = WEST * 2 = (-2, 0, 0)`, `offZ = NORTH * 2 = (0, 0, -2)`, `pos = origin + (-2, 0, -2)`;
CLOCKWISE_90: `WEST` rotates to `NORTH`, `NORTH` to `EAST`: `offX = (0, 0, -2)`, `offZ = (2, 0, 0)`, `pos = origin + (2, 0, -2)`; a block at local (x, z) goes to `pos + (-z, z', x)`, so the local x range 0..4 maps to z `origin.z - 2 .. origin.z + 2` and local z 0..4 maps to x `origin.x - 2 .. origin.x + 2`: centred. CLOCKWISE_180: `pos = origin + (2, 0, 2)`; COUNTERCLOCKWISE_90: `pos = origin + (-2, 0, 2)`.

### 11.7 Sculk numbers (section 8)

Decay penalty with `noGrowthRadius = 1` and charge 32 (`m = 23^2 = 529`): distance 1, 3, 5 from the origin: penalty 1; distance 10: `t = 81`, `f = 0.153`, penalty `max(1, (int)(32 * 0.153 * 0.5)) = 2`; distance 20: `t = 361`, `f = 0.682`, penalty 10; distance 30: `t = 841 > 529`, `f = 1`, penalty 16.
A cursor on a `sculk` block with charge 32 in world generation: with probability 1/5 per update (`nextInt(5) == 0`) it does something: if the cell above is air and at most two inhibitors are near and the cell is farther than 1 from the origin, it draws `nextInt(50)`; the draw is below 32 with probability 0.64, in which case a sensor (10/11) or shrieker (1/11) is placed above; the charge then drops by 50 to `max(0, 32 - 50) = 0`: **the cursor dies after one growth** in the world-generation spreader.

---

## 12. Validation: checkable facts

An implementation must reproduce these (each is computed from the rules above or read directly):

1. `Direction.values()` order DOWN, UP, NORTH, SOUTH, WEST, EAST; horizontal plane NORTH, EAST, SOUTH, WEST; `Rotation` order NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90.
2. `Mth.sin(1000 / 10430.378350470453 ...)`: `SIN[1000] = (float) sin(1000 / 10430.378350470453) = 0.095727` (0.09572699149930716 as a double before the float cast); `cos(0) = SIN[16384] = 1.0f`.
3. Geode with defaults: step-3 constants of section 11.1 (all six decimals); `fillT` is independent of `P`; `crackT` adds `D` only when `P > 3`.
4. Geode draw order: `distribution_points`, one `nextDouble` (crack size), one `nextFloat` (crack flag), then per point three `outer_wall_distance` samples and one `point_offset` sample, `nextInt(4)` for the crack only when the flag is set.
5. Geode box iteration order: x fastest, y, z slowest, 33 x 33 x 33 = 35 937 positions for the default offsets.
6. Geode layer test order: below `outerT` nothing; at least `fillT` filling; then crack; then inner (with its `nextFloat` draws), middle, outer. The crack can cut the middle and outer layers.
7. `inner_placements` growth: one `nextInt(size)` draw per potential position; the first direction (DOWN, UP, NORTH, SOUTH, WEST, EAST) whose neighbour is air or a water source wins.
8. `speleothem`: the draw sequence of section 5.2 (tip direction `nextBoolean` only with base on both sides; per horizontal direction one `nextFloat`, then optionally a `nextFloat` and a `nextInt(6)`, then optionally a `nextFloat` and a `nextInt(6)`; a final `nextFloat` for the taller column).
9. `buildBaseToTipColumn` heights 1 to 4 give `[tip]`, `[frustum, tip]`, `[base, frustum, tip]`, `[base, middle, frustum, tip]`; merged tips use `tip_merge`.
10. `Column.scan` returns the **block** y of the floor and ceiling; `Range.height = ceiling - floor - 1`.
11. Cluster: the per-column draw order of section 6.2 and the table of section 11.4.
12. Large dripstone: radius drawn from `[column_radius.min, clamp(floor(height * ratio), min, max)]`; the column-radius provider's own distribution is never used; bluntness is drawn before the height scale for each of the two objects; the stalactite object is built and placed first.
13. Large dripstone height examples of section 11.3; the circle test samples at angle steps `6 / radius` up to 6.2831855.
14. Sculk patch: ten cursors of charge 32, 64 passes, one round for the data; a cursor on a non-sculk block with no movement target dies in the same update, and one that moved is zeroed on its second effective update (third pass; effective updates occur every second pass); a cursor never merges in world generation.
15. `getValidMovementPos`: 18 offsets in the listed base order, shuffled by 17 draws; 12-block horizontal limit in world generation.
16. Monster room: the check pass has no draws after the two size draws; the carve pass runs `y` downward; the mossy floor probability is 3/4 per floor cell (`nextInt(4) != 0`).
17. Monster room chest: x draw then z draw, up to 3 attempts, 2 chests at most, a chest needs exactly one solid horizontal neighbour; the loot table is `chests/simple_dungeon`.
18. Fossil: draw order `nextInt(4)`, `nextInt(count)`, `nextInt(10)`; then one `nextInt(1)` palette draw and one `nextFloat` per template block (`block_rot` without a block set, in the order A, C, B of section 10.3) for the fossil, then the same for the overlay.
19. `getZeroPositionWithTransform` and `getBoundingBox` examples of section 11.6; for every rotation `getBoundingBox(settings, zero)` has its minimum corner at the position passed to `getZeroPositionWithTransform`.
20. Template feature centring for the four rotations (section 11.6).
21. `block_rot` keeps a block with probability exactly `integrity` (the test is `nextFloat() > integrity` drops).
22. A template id that does not exist gives an empty template, and `placeInWorld` of an empty template writes nothing and returns false (`template` therefore returns false; the result of `fossil` in that case is untraced, Open question 8).

---

## Open questions

1. **`org.joml.Math.invsqrt(double)`** (used by `Mth.invSqrt` in the geode sums) is in a library that is not part of the client jar. `1.0 / Math.sqrt(x)` is written from recall (recalled, not verified). A different formula (for example a fast approximation) would change the layer boundaries slightly.
2. **`LevelAccessor.isStateAtPosition(pos, predicate)` on the world-generation level.** Closed: `WorldGenRegion.isStateAtPosition` was read and applies the predicate to `getBlockState(pos)`. Only the behaviour for a position outside the loaded window remains untraced (see 35-1 section 4.1).
3. **Value of the geode noise amplitude `a`.** The formulas of `createParity`, `computeParityBaseAmplitude`, `computeParityNormalizationFactor`, `parityExpectedDeviation` and `NormalNoise.create` were read; the conclusion `a = (float) 5/6` rests on a hand cancellation of the ordinary normalisation factor (inferred). A reference value of `noise.get(...)` was not computed.
4. **Fluid ticks of geode cracks.** `WorldGenLevel.scheduleTick(pos, fluid, 0)` is written as "schedule a fluid tick with delay 0"; how the world-generation level stores that tick (chunk tick container) and whether a delay of 0 is bumped was not read.
5. **Sounds, level events, `pushEntitiesUp`** during sculk generation (`playSound`, `levelEvent` 3006, `Block.pushEntitiesUp`) are client or entity effects; they are assumed to do nothing in the world-generation level (inferred).
6. **`BlockScanUtils.findBlocks`** (behind `BoxBlockMatcher.atLeastMatched`) was not read; `canPlaceGrowth` assumes it counts matching block states over the 9 x 3 x 9 box without any chunk-boundary effect (inferred). Reads of chunks outside the world-generation window are discussed in 35-1 section 4.1.
7. **`DiscreteVoxelShape.forAllFaces` order** and the exact `Block.updateFromNeighbourShapes` calls of the template engine's step 4 (section 10.5) were read only at the call level; they matter for blocks whose `updateShape` depends on the order of neighbour updates (29 section 3.2 describes `updateShape`).
8. **A missing template id in `fossil`.** The reading of `getOrCreate` (empty template) is certain; the consequence (`getSize` of an empty template, `getBoundingBox`, the empty `countEmptyCorners` loop) was derived, not traced end to end (inferred). The data names only templates that exist (16 fossil files).
9. **`StructureTemplate.placeInWorld` waterlogging and liquid details** (section 10.5 step 3) were read from a flat listing; the exact list-removal conditions of the second pass are partly inferred. The templates of the three features here contain almost no liquid-holding blocks (the desert well palette has five entries: sandstone, sand, water level 0, `sandstone_slab` type bottom waterlogged false, air; no palette state is waterlogged).
10. **Block-entity creation timing for the spawner and chests** relies on `WorldGenRegion.getBlockEntity` (section 2.5, read). The initial contents of a new `SpawnerBlockEntity` (which `SpawnData` the first `setEntityId` writes into: the data of `getOrCreateNextSpawnData` with an empty potential list) beyond the `id` string were not expanded (inferred: an otherwise empty entity compound).
11. **Which block states `BlockState.rotate` changes** for every block that appears in templates is block-specific and belongs to the block registry (24); only `RotatedPillarBlock` was read here.
12. **The `rule` processor's other rule tests and position tests** (`always_true` and `block_match` only were read in the data used by these three features) and the other processors are left to RS20.
13. **`MultifaceSpreader` helper behaviour** is shared with 35-4 section 8.1; this document relies on that section for `canAttachTo` and `isValidStateForPlacement`, which reference block support shapes (24).
14. **Worked-example numbers** for the geode noise value, the clamped normal samples of the cluster and the positions of a complete feature run (a seed to blocks table) were not produced; only the formulas and the computed tables of section 11 are provided.
