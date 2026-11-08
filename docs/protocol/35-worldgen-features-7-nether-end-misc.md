# 35 World generation features, part 7: nether, end and miscellaneous features, coverage audit

| Item | Value |
|---|---|
| Covers | The code of these feature types: `delta_feature` (`DeltaFeature`), `stepped_column_cluster` (`SteppedColumnClusterFeature`, the basalt columns), `single_block_pillar` (`SingleBlockPillarFeature`), `overlay` (`OverlayFeature`) and `projected_random_patchy_square` (`ProjectedRandomPatchySquare`) as they compose the basalt pillar (the three engines themselves are 35-4 section 7; this part holds the composition), `netherrack_replace_blobs`, `replace_single_block` and `spike` (the ice spike) (cross-references only: 35-5 sections 7 and 16, 35-4 section 7.5), `end_spike` (`EndSpikeFeature`, `EndSpike`, `SpikeCacheLoader`: obsidian pillars, cages, crystals, the seeded spike list), `chorus_plant` (`ChorusPlantFeature` and the chorus growth code of `ChorusFlowerBlock` it calls), `end_island`, `end_platform`, `end_podium`, `end_gateway`, `void_start_platform`; `template` (cross-reference only: 35-6 section 10.1 and 35-5 section 17; section 11.3 keeps the independent reading), and cross-references for `bonus_chest` and `fill_layer` (35-5 sections 18 and 11); the three block-position iterators these features depend on; a closing coverage audit of all 58 feature types and of every helper class of `levelgen.feature.*` against the parts of document 35; the index of open questions of this part. |
| Does not cover | Rows of data (the extraction tool copies `worldgen/feature`, `worldgen/placed_feature` and the rest, see 22 and 23 section 2.1): this part specifies engines, and the data it names is cited only to show how an engine is wired. The feature framework, placement modifiers and generic features (35 part 1), predicates and providers (35 part 2), tree placers (35 part 3), and the vegetation, water, surface and underground features (parts 4 to 6). The structure template engine behind `template` (`StructureTemplate.placeInWorld`: 35-6 sections 10.4 and 10.5; the desert well overlay: 35-5 section 17); the processor and RuleTest families (not read, Open question 4). The ender dragon fight and the entities (21). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the classes named in each section, and of the JSON under `data/minecraft/worldgen/` and `data/minecraft/tags/block/` in the jar for wiring and examples only, with no execution. Worked examples marked "(computed)" were produced by applying this document's text with a throwaway reference script written for the round; they were not observed from the artifact. |
| Round | RS19 (GAP-12a of [../design/README.md](../design/README.md)), scope "Part 7" |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engine (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"). |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not
verified)" marks something not read; both are listed in the Open questions. Section references "10 section n", "11 section n",
"21 section n", "23 section n", "29 section n", "35-1 section n" (part 1: [35-worldgen-features-1-model-and-placement.md](35-worldgen-features-1-model-and-placement.md)),
"35-2 section n" (part 2: [35-worldgen-features-2-predicates-and-providers.md](35-worldgen-features-2-predicates-and-providers.md)), "35-3" (part 3, trees), "35-4" (decorators and vegetation), "35-5" ([water and surface](35-worldgen-features-5-water-and-surface.md)) and "35-6" ([underground](35-worldgen-features-6-underground.md))
are to the documents of this directory; "section n" alone is this document. Float means IEEE single precision and double means IEEE
double precision; where an arithmetic step below says float, an implementation that wants vanilla-identical output must round to
single precision at that step. Coordinates are block coordinates, `y` is vertical. A "draw" is one call on the feature's random
source; `nextInt(n)`, `nextFloat()`, `nextLong()` are the plain Java linear congruential draws of 10 section 3 (the
`LegacyRandomSource` paragraph) and 11 section 4; 35-1 section 5 says which generator a feature receives. Block writes use the
flag value named in each section: `setBlock(pos, state)` of the `Feature` interface is `setBlockAndUpdate`, flags 3 (35-1 section 2.2);
`level.setBlock(pos, state, 2)` is flag 2 only.

---

## 1. Wiring: where these features are reached

The engine of each feature is in the sections below; this table only records how the data pack reaches it (read from
`placed_feature/*.json` and `biome/*.json`). The step names are those of 11 section 6.2 (index 4 `SURFACE_STRUCTURES`, 7
`UNDERGROUND_DECORATION`, 9 `VEGETAL_DECORATION`, 10 `TOP_LAYER_MODIFICATION`).

| Feature (data element) | Placed with | Biome (step) |
|---|---|---|
| `delta` (`delta_feature`) | `count_on_every_layer 40`, `biome` | `basalt_deltas` (4) |
| `small_basalt_columns`, `large_basalt_columns` (`weighted_random_selector` of two `stepped_column_cluster` each, weights 9 and 1) | `count_on_every_layer` 4 and 2, `biome` | `basalt_deltas` (4) |
| `basalt_pillar` (`overlay`) | `count 10`, `in_square`, `height_range` over the whole column, `block_predicate_filter` (air at the position and not air at `y+1`), `biome` | `soul_sand_valley` (2, `LOCAL_MODIFICATIONS`) |
| `basalt_blobs`, `blackstone_blobs` (`netherrack_replace_blobs`, radius `uniform 3..7`, target `netherrack`) | `count 75` and `count 25`, `in_square`, `height_range` whole column, `biome` | `basalt_deltas` (7) |
| `ice_spike` (`spike`, state `packed_ice`, place on `snow_block`) | `count 3`, `in_square`, `heightmap MOTION_BLOCKING`, `biome` | `ice_spikes` (4) |
| `end_spike` (`end_spike`, empty `spikes` list) | `biome` only | `the_end` (4) |
| `end_platform` | `fixed_placement [[100,49,0]]`, `biome` | `the_end` (10) |
| `end_gateway_return` (`end_gateway`, `exact` true, `exit [100,50,0]`) | `rarity_filter 700`, `in_square`, `heightmap MOTION_BLOCKING`, `offset y uniform 3..9`, `biome` | `end_highlands` (4) |
| `chorus_plant` | `count uniform 0..4`, `in_square`, `heightmap MOTION_BLOCKING`, `biome` | `end_highlands` (9) |
| `end_island_decorated` (`end_island`) | `rarity_filter 14`, `count weighted {1 weight 3, 2 weight 1}`, `in_square`, `height_range uniform 55..70`, `biome` | `small_end_islands` (0) |
| `void_start_platform` | `biome` only | `the_void` (10) |
| `end_podium_active`, `end_podium_inactive`, `end_gateway_delayed`, `bonus_chest` | no placed feature (the four are data features under `worldgen/feature/`; `end_podium_active` and `end_podium_inactive` are two files of type `end_podium`, with `active` true and absent; no file under `worldgen/placed_feature/` names any of the four, so only code reaches them) | called by code: the dragon fight for the podium and delayed gateway (21 section 6.4.5, see section 8.2 and 10), the spawn logic for `bonus_chest` (35-5 section 18) |

Counts read with `unzip -Z1`, directory entries excluded: `worldgen/feature/` 240 files, `worldgen/placed_feature/` 273 files.
Of the types of this part, only `fill_layer` and `replace_single_block` are used by no feature or placed feature of the data pack
(including nested elements).

## 2. Helpers the features depend on

Three `BlockPos` iterators are used by features of this part and by many of the others. They are specified here because no
other document specifies their order (35-1 does not).

### 2.1 `BlockPos.betweenClosed(min, max)` (the "box" iterator)

Visits every position of the box with `min <= p <= max` per axis (both ends inclusive), the x coordinate varying fastest, then y,
then z (slowest). With `w = maxX - minX + 1`, `h = maxY - minY + 1` the n-th position (n from 0) is
`(minX + n mod w, minY + (n div w) mod h, minZ + (n div w) div h)`. The six-integer overload `(x1,y1,z1,x2,y2,z2)` and the
two-position overload are the same. Class `BlockPos$4`.

### 2.2 `BlockPos.randomBetweenClosed(random, count, minX, minY, minZ, maxX, maxY, maxZ)`

Yields exactly `count` positions. Each position is produced lazily, when the consumer asks for it, by three draws in this
order: `nextInt(maxX - minX + 1)` for x, then `nextInt(maxY - minY + 1)` for y, then `nextInt(maxZ - minZ + 1)` for z, each added to the
corresponding minimum. Positions may repeat. Because the draws happen as the consumer iterates, any draw the consumer makes
between two positions (for example the column reach in section 4) is interleaved with them. Class `BlockPos$2`.

### 2.3 `BlockPos.withinBoxByManhattanDistance(origin, rx, ry, rz)` (the "diamond" iterator)

Yields the offsets `(x, y, z)` with `|x| <= rx`, `|y| <= ry`, `|z| <= rz` (added to `origin`), ordered by increasing Manhattan
distance `d = |x| + |y| + |z|`, from `d = 0` up to `d = rx + ry + rz`. It is the method `manhattanOrdered(origin, rx, ry, rz,
rx + ry + rz)`, class `BlockPos$3`. Order inside one depth `d`:

1. for `x` from `-min(rx, d)` to `min(rx, d)` ascending;
2. for `y` from `-min(ry, d - |x|)` to `min(ry, d - |x|)` ascending;
3. `dz = d - |x| - |y|`; when `dz <= rz` the offset `(x, y, +dz)` is yielded, and when `dz != 0` the offset `(x, y, -dz)` is yielded
   immediately after it.

Total count is `(2 rx + 1)(2 ry + 1)(2 rz + 1)`. A consumer that stops at the first position with `d > limit` therefore visits
exactly the positions with `d <= limit`, nearest first. `Vec3i.distManhattan(a, b)` is `|dx| + |dy| + |dz|`.

---

## 3. `delta_feature` (`DeltaFeature`)

Record fields (JSON keys): `contents` (a block state, required), `rim` (a block state, required), `size` (an `IntProvider`
restricted by the codec to the range 0 to 16, required), `rim_size` (an `IntProvider`, range 0 to 16, required). Constant
`RIM_SPAWN_CHANCE = 0.9`.

Block list `CANNOT_REPLACE` (read from the static initialiser): `bedrock`, `nether_bricks`, `nether_brick_fence`,
`nether_brick_stairs`, `nether_wart`, `chest`, `spawner`.

**`isClear(level, p)`** is true when all of: the block at `p` is not the block of `contents` (compared by block, ignoring
properties); the block at `p` is not in `CANNOT_REPLACE`; and for each of the six directions the block next to `p` satisfies
"horizontal and downward neighbours are not air, the upward neighbour is air" (a non-air upward neighbour or an air
horizontal or downward neighbour makes it false). So a clear position is a block whose top is exposed and whose sides and
bottom are all solid or fluid (air meaning only `isAir`).

**Place** (inputs `level`, `random`, `origin`):

1. `useRim = nextDouble() < 0.9` (draw 1, always).
2. `rimX = useRim ? rimSize.sample : 0`, then `rimZ = useRim ? rimSize.sample : 0` (draws 2 and 3 only when `useRim`).
3. `rimActive = useRim and rimX != 0 and rimZ != 0`.
4. `sizeX = size.sample`, then `sizeZ = size.sample` (two more draws); `maxDist = max(sizeX, sizeZ)`.
5. Walk the diamond iterator (section 2.3) `withinBoxByManhattanDistance(origin, sizeX, 0, sizeZ)`. Stop at the first position
   whose Manhattan distance from `origin` exceeds `maxDist`. For each position `p` before that:
   a. if `isClear(p)`: if `rimActive`, set `rim` at `p` (flags 3) and note that something was placed;
   b. then (still inside the same `isClear(p)` branch, even when no rim was placed) let `q = p + (rimX, 0, rimZ)`; if `isClear(q)`,
      set `contents` at `q` (flags 3) and note that something was placed.
6. Return true when anything was placed.

Every check reads the live world, so a block set earlier in the walk changes later `isClear` results. The footprint is at most
`sizeX + sizeZ` blocks from `origin` in Manhattan terms before the cut by `maxDist`, so with the maximum sizes it reaches 16 blocks,
and `contents` may land `rimX`, `rimZ` (at most 16) further, which is why this feature runs with the 3 x 3 chunk write window
(35-1 section 4.1). The data element `delta` uses `contents lava`, `rim magma_block`, `size uniform 3..7`, `rim_size uniform 0..2`.

Example (computed): `size` draws give `sizeX = 2`, `sizeZ = 1`, so `maxDist = 2`. The diamond iterator would yield 15 offsets `(dx, dz)`: `(0,0)`, `(-1,0)`, `(0,1)`, `(0,-1)`, `(1,0)`,
`(-2,0)`, `(-1,1)`, `(-1,-1)`, `(1,1)`, `(1,-1)`, `(2,0)`, then at distance 3 `(-2,1)`, `(-2,-1)`, `(2,1)`, `(2,-1)`. The walk stops at the first offset with distance above 2, so only the first 11 are
visited (the four distance-3 offsets are never reached).

## 4. `stepped_column_cluster` (`SteppedColumnClusterFeature`): basalt columns

Record fields: `block` (a `Holder<BlockStateProvider>` in the jar, decoded with `BlockStateProvider.CODEC`: an inline provider value or a registry reference; for the inline forms, including a bare block state, see 35-2 section 4. The same field type is used by `single_block_pillar` and `projected_random_patchy_square`. The data of this round uses inline `{id, properties}` states), `continue_through` (a block
predicate), `can_replace` (a block predicate), `cannot_place_on` (a block holder set, tag or list), `cluster_reach` (`IntProvider`
range 0 to 13), `column_count` (`IntProvider` range 1 to 150), `column_reach` (`IntProvider` range 0 to 3), `height`
(`IntProvider` range 1 to 10). All eight are required. Predicates are evaluated as 35-2 section 3 says, with the position tested as
the origin of the predicate.

**Place** (inputs `level`, `generator`, `random`, `origin`):

1. `sea = generator.getSeaLevel()`. (The value is passed on but no step below uses it.)
2. If `canPlaceAt(origin)` is false return false (the helper is defined below).
3. Draw in this order: `height = height.sample`, then `reach = min(height, clusterReach.sample)`, then `count = columnCount.sample`.
4. Visit `count` positions from `randomBetweenClosed(random, count, ox - reach, oy, oz - reach, ox + reach, oy, oz + reach)` (section 2.2:
   the y range has one value). For each position `p`: `remaining = height - distManhattan(p, origin)`. If `remaining >= 0`,
   draw `r = columnReach.sample` (this draw happens only when the column is built) and run `placeColumn(p, remaining, r)`; OR
   its result into the answer. Return the answer.

**`canPlaceAt(pos)`**: `canReplace(pos)` is true, and the block directly below `pos` is neither air nor in `cannotPlaceOn`.

**`placeColumn(center, h, r)`**: visit the box iterator (section 2.1) over `(cx - r, cy, cz - r) .. (cx + r, cy, cz + r)`. For each cell
`q` with `dist = distManhattan(q, center)` (0 to `2r`):

1. If `canReplace(q)` then `start = findSurface(q, dist)` else `start = findAir(q, dist)`. When `start` is null go to the next cell.
2. `n = h - dist div 2` (integer division). Set a cursor at `start`. While `n >= 0`: if `canReplace(cursor)` set the block provider's
   state at `cursor` (flags 3; the provider is asked with the world, the random and the position), move the cursor up one and
   record that something was placed; otherwise, if `continueThrough(cursor)` move the cursor up one; otherwise stop this cell.
   Then `n = n - 1`.

**`findSurface(q, range)`**: starting at `q` and moving down one block at a time, examine at most `range` positions (stop also
when the position's y is at most `minY + 1`); return the first position where `canPlaceAt` is true, else null. A `range` of 0 examines
nothing.

**`findAir(q, range)`**: starting at `q` and moving up one block at a time, examine at most `range` positions (stop also when y
exceeds the level's maximum y): if the block is in `cannotPlaceOn` return null; if it is air (`isAir`) return that position; else move
up. Returns null when nothing qualifies.

Consequences read from the code: the cell with `dist = 0` (the column centre itself) never produces anything, whichever branch it
takes, because both searches examine zero positions; columns therefore come from their neighbours, and heights fall off by one
block every two steps of Manhattan distance from the column centre. The random draws are only the three of step 3, the `count x 3`
position draws and one `columnReach` draw per built column, interleaved as step 4 says.

Data (not tabulated; shown to give the shape). `small_basalt_columns` and `large_basalt_columns` are `weighted_random_selector`
features (35-1 section 9.5) with weight 9 and 1; the variants are `{cluster_reach 5, column_count 50}` and `{cluster_reach 8,
column_count 15}`; small columns use `column_reach 1` and `height uniform 1..4`, large ones `column_reach uniform 2..3` and
`height uniform 5..10`; all use `block basalt[axis=y]`, `continue_through matching basalt`, `cannot_place_on #cannot_place_basalt_pillar_on`
(the tag lists `lava`, `bedrock`, `magma_block`, `soul_sand`, `nether_bricks`, `nether_brick_fence`, `nether_brick_stairs`,
`nether_wart`, `chest`, `spawner`), and `can_replace` equal to "block tag `air` (`air`, `void_air`, `cave_air`), or lava with `y` between
`minY` and sea level".

Worked example (computed). Flat floor of solid blocks with its top at `y = 0`, air above; `origin = (0, 1, 0)`; the small variant
with `height = 3`, `reach = min(3, 5) = 3`. A drawn position `p = (1, 1, 0)` has `remaining = 3 - 1 = 2`; with `r = 1` the
nine cells around it are examined. Cell `q = (2, 1, 0)` has `dist = 1`: `canReplace` (air) is true, `findSurface(q, 1)` examines `q`
only, `canPlaceAt` is true (air above a solid block), `n = 2 - 0 = 2`, so basalt is set at `y = 1, 2, 3` (three blocks, `n` = 2, 1, 0).
Cell `q = (2, 1, 1)` has `dist = 2`: `findSurface(q, 2)` examines `q` (succeeds at once), `n = 2 - 1 = 1`, so two blocks. The centre cell `(1, 1, 0)`
has `dist = 0` and is skipped.

## 5. `single_block_pillar`, `overlay`, `projected_random_patchy_square`: the basalt pillar

### 5.1 The three engines, by reference

`single_block_pillar`, `overlay` and `projected_random_patchy_square` are specified in 35-4 section 7.2, section 7.4 and section 7.6 (part 4 took them with the
vegetation features). They were also read independently for this part and the two readings agree on every point; the facts section 5.2 relies on are repeated here
in one line each so that this section can be followed without a second document:

| Engine | Facts used by the basalt pillar |
|---|---|
| `single_block_pillar` | loop while `can_replace` holds at the cursor: draw `nextFloat()` (only after the predicate passed), stop unless it is `< chance_to_continue` (default 1.0), stop outside the build height, set the provider state with flags 2, step in `direction`; afterwards step back once and run the optional `cap_feature` at the cursor; result always true |
| `overlay` | runs every placed feature of `features` in order at the same origin with the same random; result is the OR; no early exit. Part 1 section 9 does not list it; 35-4 section 7.4 specifies it |
| `projected_random_patchy_square` | `s = size.sample`, `N = s*s + 1`; for `dx`, `dz` in `-s..s` (x outer) draw `nextInt(N)` for every cell and keep the cell when the draw is `< N - |dx|*|dz|`; project the cell down through `project_through` (tested on the block below, at most `max_projection_height` steps); set the provider's optional state with flags 2; result always true |

### 5.2 The `basalt_pillar` composition (data) and its order of effect

`basalt_pillar` is an `overlay` of five inline placed features, run in this order at the origin `O` (an air block with a non-air block above,
see section 1):

1. A pillar of `basalt[axis=y]` going down from `O` through air (`can_replace` is the block tag `air`), `chance_to_continue` 1.0, with a `cap_feature`
   that is itself an `overlay`: (a) a patchy square, `size 3`, `max_projection_height 3`, `project_through` air, placed with an `offset` of `y - 1`
   (so its origin is the block the pillar stopped at, the first non-air block below it), whose provider is `rule_based` with one rule "if NOT air at
   offset `(0,-1,0)` then `basalt[axis=y]`" (35-2 section 4); then (b) four `simple_block` (35-4 section 4) features placing `basalt[axis=y]`, each with a `rarity_filter` of
   chance 2 and an `offset` of `(+1,0,0)`, `(-1,0,0)`, `(0,0,+1)`, `(0,0,-1)` from the lowest pillar block, in that order. A `simple_block` places its state when
   the state can survive there (basalt always can) with flags 2, replacing whatever is there.
2. Four more pillars, each with `chance_to_continue 0.9`, direction down, `can_replace` air, no cap, placed with an `offset` of `(+1,0,0)`, `(-1,0,0)`,
   `(0,0,+1)`, `(0,0,-1)` from `O`, in that order. At each block the pillar continues with probability 0.9.

Effect: a basalt column from the ceiling down to the first solid block or lava; a scattered basalt skirt on the floor under it (cells at the floor level of the
patchy square become basalt wherever the block below them is not air, after projecting down through up to 3 air blocks); up to four basalt blocks beside
its lowest block; and up to four thinner side pillars (each ends with probability 0.1 per block).

## 6. `netherrack_replace_blobs` (`ReplaceBlobsFeature`) and `replace_single_block` (`ReplaceBlockFeature`)

### 6.1 `netherrack_replace_blobs`

Specified in 35-5 section 7 (target search downward from the clamped origin, three radius draws in the order x, y, z, the Manhattan-clipped box walk of section 2.3 here, data `basalt_blobs` and `blackstone_blobs`). This part read it independently and the two texts agree; 35-5 owns it and it is not repeated here. The diamond iterator it uses is section 2.3.

### 6.2 `replace_single_block`

Specified in 35-4 section 7.5 (fields `targets`, a list of `{target: RuleTest, state}` (class `BlockReplacement`); the first entry whose RuleTest accepts the block at the
origin has its state set there with flags 2; the result is always true). It was read independently and agrees. No element of the data pack uses it (section 1). The RuleTest
family is not read (Open question 4); the structure engine is 35-6 section 10.

---

## 7. `spike` (`SpikeFeature`): ice spike

Specified in 35-5 section 16 (ground search, the draw order for height `H` and width, the cone with the rim lottery, the mirrored downward cone, the pillar base with the fixed absolute `y > 50` limit, and a worked example for `H = 8`). This part read it independently and the two texts agree on every draw and constant; 35-5 owns it and it is not repeated here. Data wiring: section 1.

---

## 8. `end_spike` (`EndSpikeFeature`): obsidian pillars, cages and crystals

### 8.1 Fields and the spike list

Record fields: `spikes` (list of `EndSpike`, required; the data element uses an empty list), `crystal_invulnerable` (boolean, default false),
`crystal_beam_target` (optional block position, `[x, y, z]`). An `EndSpike` is `{centerX, centerZ, radius, height, guarded}`, all optional in the codec with
defaults 0, 0, 0, 0, false (field names exactly `centerX`, `centerZ`, `radius`, `height`, `guarded`). Constants `NUMBER_OF_SPIKES = 10`, `SPIKE_DISTANCE = 42`.

**When the `spikes` list is empty** the feature uses `getSpikesForLevel(level)`:

1. `r0` = a plain Java LCG (10 section 3) seeded with `level.getSeed()` (the world seed: `ServerLevel.getSeed` returns the world options' seed and the generation region copies it when it is constructed). `key = r0.nextLong() & 0xFFFF` (a value 0 to 65535).
2. The list is cached by `key` for five minutes (a cache is an implementation detail; the list is a pure function of `key`).
3. **Building the list for `key`**: `r1` = a Java LCG seeded with `key`. Make the int list `[0, 1, ..., 9]` and shuffle it with the **descending Fisher-Yates**
   of `Util.toShuffledList`: for `i` from 10 down to 2 draw `j = r1.nextInt(i)` and swap the elements at positions `i - 1` and `j`. Call the result `order`.
4. For `i` from 0 to 9, with `k = order[i]`:
   - `centerX = floor(42.0 * cos(2.0 * (-pi + (pi / 10) * i)))` and `centerZ = floor(42.0 * sin(2.0 * (-pi + (pi / 10) * i)))` in double arithmetic, where `pi` is
     `3.141592653589793` and `pi / 10` is the literal `0.3141592653589793` (the product `0.3141592653589793 * i` is added to `-3.141592653589793`, then doubled). So spike `i` lies on the
     angle `i * 36` degrees at distance 42, and `floor` is the mathematical floor (towards minus infinity): spike 5 has `centerZ = -1` because `sin(-pi)` is a tiny negative number;
     spike 0 has `centerZ = 0`;
   - `radius = 2 + k div 3`; `height = 76 + 3 k`; `guarded = (k == 1 or k == 2)`.

A spike also has a `topBoundingBox`, the box `(cx - r, DimensionType.MIN_Y, cz - r) .. (cx + r, DimensionType.MAX_Y, cz + r)` (used by the dragon fight, 21; not by placement).
`isCenterWithinChunk(pos)` is true when `pos` and the spike centre are in the same chunk (compare `x div 16` and `z div 16` with floor division).

### 8.2 Place

Input `origin` (in decoration the chunk's min corner, 35-1 section 6). `spikes = config.spikes`, or `getSpikesForLevel` when empty. For each spike in list order, when
`isCenterWithinChunk(origin)`, run `placeSpike`. Return true. (The feature runs once per chunk; a spike is built by the chunk that contains its centre, which writes up to
`radius + 1 <= 6` blocks into neighbours, inside the write window.)

**`placeSpike(spike)`** with `r = radius`, `(cx, cz)` the centre, `H = height`:

1. **Pillar.** Visit the box iterator (section 2.1) over `(cx - r, minY, cz - r) .. (cx + r, H + 10, cz + r)` (here `minY` is the level's minimum y; the End has `minY = 0`).
   For each position `p`: when `(p.x - cx)^2 + (p.z - cz)^2 <= r*r + 1` (the y term of `distToLowCornerSqr` is zero because the call passes `p.y`) **and** `p.y < H`, set `obsidian`
   (flags 3). Otherwise, when `p.y > 65`, set `air`. (So above y = 65 the whole square above the pillar and around it is cleared up to `H + 10`; positions at or below 65 outside the
   pillar are left alone.)
2. **Cage** (only when `guarded`). For `x` from -2 to 2 (outer), `z` from -2 to 2, `y` from 0 to 3 (inner): `edgeX = |x| = 2`, `edgeZ = |z| = 2`, `top = (y = 3)`. Skip unless
   `edgeX or edgeZ or top`. Then `a = (x = -2 or x = 2 or top)` and `b = (z = -2 or z = 2 or top)`. Place `iron_bars` at `(cx + x, H + y, cz + z)` (flags 3) with
   `north = a and z != -2`, `south = a and z != 2`, `west = b and x != -2`, `east = b and x != 2` (other properties default, so not waterlogged). The cage is a 5 x 5 ring of walls three
   blocks high (y offsets 0 to 2) with a solid roof at offset 3; each bar connects along the wall and the roof but not outward.
3. **Crystal.** Create an `end_crystal` entity (spawn reason `STRUCTURE`); when creation succeeds: set its beam target to `crystal_beam_target` (absent means none), set
   permanently-invulnerable to `crystal_invulnerable`, place it with `snapTo(cx + 0.5, H + 1, cz + 0.5, yaw = nextFloat() * 360.0f, pitch = 0)` (one float draw per spike, always,
   after the cage), add it to the world. Let `c` be the crystal's block position (`(cx, H + 1, cz)`): set `bedrock` at `c - (0,1,0)` and then, at `c`, the state of
   `FireBlock.getState(level, c)` (the call site names `FireBlock`; the only static `getState` is the one inherited from `BaseFireBlock`, flags 3 for both), read in full: `below` is the state at `c - (0,1,0)`. If `below` is in the block tag `soul_fire_base_blocks` (`SoulFireBlock.canSurviveOnBlock`; the jar's tag contains `soul_sand` and `soul_soil`) the result is the default `soul_fire` state. Otherwise it is `FireBlock.getStateForPlacement(level, c)`: the default `fire` state when `below` satisfies `FireBlock.canBurn` or has a sturdy `up` face; if neither holds, the default state with each of the `up`, `north`, `east`, `south`, `west` flags set to `canBurn` of the neighbour on that side (the loop covers every direction through `PROPERTY_BY_DIRECTION`, which has no entry for `down`). The constructor's default `fire` state is `age` 0 with all five flags false. For the crystal base (`bedrock`, not in the soul tag, sturdy `up` face) the result is therefore plain `fire`, `age` 0, no flags: read, not inferred. The entity itself: 21 section 6.3.

So a spike of height `H` is obsidian for `y < H`, a bedrock cap at `y = H`, fire and the crystal at `y = H + 1`, and (guarded) bars from `H` to `H + 3`.

Worked example (computed) of the spike list for world seed 0: `key = 20792`, the shuffled order is `[6, 5, 1, 7, 3, 9, 0, 2, 4, 8]`, giving:

| i | centre (x, z) | k | radius | height | guarded |
|---|---|---|---|---|---|
| 0 | (42, 0) | 6 | 4 | 94 | no |
| 1 | (33, 24) | 5 | 3 | 91 | no |
| 2 | (12, 39) | 1 | 2 | 79 | yes |
| 3 | (-13, 39) | 7 | 4 | 97 | no |
| 4 | (-34, 24) | 3 | 3 | 85 | no |
| 5 | (-42, -1) | 9 | 5 | 103 | no |
| 6 | (-34, -25) | 0 | 2 | 76 | no |
| 7 | (-13, -40) | 2 | 2 | 82 | yes |
| 8 | (12, -40) | 4 | 3 | 88 | no |
| 9 | (33, -25) | 8 | 4 | 100 | no |

The ten centres are the same for every seed; only the assignment of `k` (hence radius, height, guards) changes. World seed 1 gives `key = 40152` and order `[3, 6, 0, 2, 8, 5, 9, 4, 7, 1]`.
Cell counts of the pillar disc (`dx^2 + dz^2 <= r^2 + 1`): `r = 2`: 21; `r = 3`: 37; `r = 4`: 57; `r = 5`: 89.

---

## 9. `chorus_plant` (`ChorusPlantFeature`) and the chorus growth code

**Place** (`origin`): when the block at `origin` is air (`isEmptyBlock`) and the block directly below is in the block tag `supports_chorus_plant` (the jar's tag contains only `end_stone`), call
`ChorusFlowerBlock.generatePlant(level, origin, random, 8)` and return true; otherwise return false.

**`generatePlant(level, pos, random, maxDistance)`**: set the chorus plant state computed by `getStateWithConnections` at `pos` (flags 2), then `growTreeRecursive(level, pos, random, pos, maxDistance, 0)` (the
third and fourth arguments are the base and the origin of the whole plant; the last is the depth).

**`getStateWithConnections(level, pos, plantState)`** (defined in `ChorusPlantBlock`, not in `ChorusFlowerBlock`; it sets each flag with `trySetValue`) returns `plantState` with these boolean properties set from the neighbours at that moment (a property the state lacks is left alone):
`down` when the block below is a chorus plant, a chorus flower, or in the tag `supports_chorus_plant`; `up` when the block above is a chorus plant or a chorus flower; `north`, `east`, `south`, `west`
when the neighbour on that side is a chorus plant or a chorus flower. Placement never updates a neighbour, so a plant block sets only its own flags; the code below re-sets the block under
the new one so its `up` flag becomes true.

**`allNeighborsEmpty(level, pos, except)`**: true when every one of the four horizontal neighbours of `pos`, other than the direction `except` (null means none is excepted), is air.

**`growTreeRecursive(level, base, random, origin, maxDistance, depth)`**:

1. `h = nextInt(4) + 1` (draw); when `depth = 0`, `h = h + 1`. (`h` is the trunk height of this segment.)
2. Trunk: for `i` from 0 to `h - 1`: `p = base + (0, i + 1, 0)`; when `allNeighborsEmpty(p, null)` is false, **return** (nothing further is done for this segment: no branches and
   no flower); else set a chorus plant at `p` and then set a chorus plant at `p - (0,1,0)` again (both with `getStateWithConnections`, flags 2).
3. `grew = false`. When `depth < 4`: `n = nextInt(4)` (draw), and `n = n + 1` when `depth = 0`. Repeat `n` times: `dir` = one of the horizontal directions drawn with
   `nextInt(4)` over the order north, east, south, west (the order of `Direction.Plane.HORIZONTAL`); `q = base + (0, h, 0) + dir`. When all of: `|q.x - origin.x| < maxDistance`,
   `|q.z - origin.z| < maxDistance`, `q` is air, the block below `q` is air, `allNeighborsEmpty(q, opposite(dir))`: then `grew = true`, set a chorus plant at `q`, set a chorus plant at
   `q - dir` (the trunk top it connects to), and run `growTreeRecursive(level, q, random, origin, maxDistance, depth + 1)` at once (the recursion's draws happen before the next branch's draw).
4. When `grew` is false set a `chorus_flower` with `age = 5` (the dead flower, `ChorusFlowerBlock.DEAD_AGE`) at `base + (0, h, 0)` (flags 2).

The max horizontal distance of the whole plant from its origin is therefore at most 7 blocks (strict `< 8`), the depth at most 4 (depths 0 to 4: depth 4 never branches).

Worked example (computed with a reference script; ground of end stone below `y = 0`, empty space around, random = Java LCG seeded with 1, `origin = (0, 0, 0)`). Draw log: depth 0:
`nextInt(4)` gives 2, so `h = 2 + 1 + 1 = 4` (the trunk loop sets plants at `y = 1..4`); branch count `nextInt(4)` gives 0, so `n = 1`; the direction draw gives east, `q = (1, 4, 0)` passes all
tests, so plants are set at `(1, 4, 0)` and `(0, 4, 0)` and the recursion runs with depth 1: `nextInt(4)` gives 1, so `h = 2` (plants at `(1, 5, 0)` and `(1, 6, 0)`); `nextInt(4)` gives 0, so
no branch attempt; nothing grew, so a dead flower is set at `base + (0, h, 0) = (1, 6, 0)`, **replacing the top trunk plant**. Final blocks: plants at `(0, 0..4, 0)`, `(1, 4, 0)`, `(1, 5, 0)`
and a flower `age 5` at `(1, 6, 0)`: 8 blocks. (The flower always replaces the highest block the trunk loop wrote, because the loop writes `base + 1 .. base + h` and the flower goes at `base + h`.)


---

## 10. End features: island, platform, podium, gateway, and the void platform

### 10.1 `end_island` (`EndIslandFeature`)

No fields. **Place** (`origin`): `r = (float)nextInt(3) + 4.0f` (draw 1: 4.0, 5.0 or 6.0) and `dy = 0`. While `r > 0.5f`:

1. for `x` from `floor(-r)` to `ceil(r)` (outer) and `z` from `floor(-r)` to `ceil(r)` (inner), both float-to-int conversions; when `(float)(x*x + z*z) <= (r + 1.0f) * (r + 1.0f)` (float) set
   `end_stone` at `origin + (x, dy, z)` (flags 3);
2. `r = r - ((float)nextInt(2) + 0.5f)` (one draw per layer: subtract 0.5 or 1.5), `dy = dy - 1`.

Return true. The island is an upside-down stack of discs under the origin, the top layer largest. Because `r` decreases by at least 0.5 per layer there are at most
`ceil((r0 - 0.5) / 0.5)` layers; the last layer is the one whose `r` is still above 0.5.

Cell counts per layer radius (computed): `r = 6.0`: 145; `5.5`: 137; `5.0`: 109; `4.5`: 97; `4.0`: 77; `3.5`: 69; `3.0`: 45; `2.5`: 37; `2.0`: 25; `1.5`: 21; `1.0`: 9; `0.5` ends the loop.
Example (computed): `nextInt(3)` gives 1 (`r = 5.0`), and the first four per-layer draws of `nextInt(2)` are 0, 1, 0, 1 (so subtract 0.5, 1.5, 0.5, 1.5; a fifth draw is made after the last layer and does not matter): layers are `r = 5.0` (109 blocks, `dy = 0`),
`4.5` (97, `dy = -1`), `3.0` (45, `dy = -2`), `2.5` (37, `dy = -3`), `1.0` (9, `dy = -4`), then `r = -0.5` stops: 297 blocks in five layers.

### 10.2 `end_platform` (`EndPlatformFeature`)

No fields. **Place** (`origin`) calls the static `createEndPlatform(level, origin, dropBlocks = false)` and returns true. **`createEndPlatform(level, centre, dropBlocks)`**: for `dz` from -2 to 2
(outer), `dx` from -2 to 2, `dy` from -1 to 2 (inner): `p = centre + (dx, dy, dz)`; the wanted block is `obsidian` when `dy = -1` and `air` otherwise; when the block at `p` is not already the wanted block:
when `dropBlocks` is true first `destroyBlock(p, dropItems = true, no entity)`; then `setBlockAndUpdate(p, wanted)` (flags 3). Result: a 5 x 5 obsidian floor at `centre.y - 1` with a 5 x 5 x 3 volume of air above it
(`centre.y` to `centre.y + 2`). The data placement is `fixed_placement [[100, 49, 0]]` in the End (35-1 section 7.18: only positions in the chunk being decorated), so the platform is obsidian at `y = 48`,
`x` 98 to 102, `z` -2 to 2, air at `y = 49 .. 51`; it is built by chunk (6, 0) and writes into chunk (6, -1) (inside the write window). The static method is public and the `true` form has other callers (Open question 5).

### 10.3 `end_podium` (`EndPodiumFeature`)

Field: `active` (boolean, optional, default false). Constants in the class: `PODIUM_RADIUS = 4`, `PODIUM_PILLAR_HEIGHT = 4`, `RIM_RADIUS = 1`, `CORNER_ROUNDING = 0.5f` (the last two are not read by the placement code).
**Place** (`P` = origin): visit the box iterator (section 2.1) over `(Px - 4, Py - 1, Pz - 4) .. (Px + 4, Py + 32, Pz + 4)`. For each cell `q`:
`inner = distSqr(q, P) < 2.5^2`, `outer = distSqr(q, P) < 3.5^2` (`Vec3i.closerThan` compares the squared 3D distance with the squared limit; the y difference counts). Skip the cell unless `inner or outer`. Otherwise:

| Cell relative to `P.y` | `inner` | not `inner` (only `outer`) |
|---|---|---|
| `q.y < P.y` | `bedrock` | `end_stone` |
| `q.y = P.y` | `end_portal` when `active`, else `air` | `bedrock` |
| `q.y > P.y` | `air` | `air` |

For the `active` form the writes of `end_stone`, `air` and `end_portal` go through `dropPreviousAndSetBlock`: when the current block is not already the target block, `destroyBlock(q, dropItems = true, no entity)` and then
a plain `setBlock` (flags 3); the bedrock writes and all writes of the inactive form are plain `setBlock`. After the loop: set `bedrock` at `P`, `P + 1`, `P + 2`, `P + 3` (the pillar, 4 blocks, overwriting the portal at `P`),
then at `T = P + (0, 2, 0)` for each horizontal direction `d` in the order north, east, south, west set `wall_torch[facing = d]` at `T + d` (flags 3). Return true.

Cells per layer relative to `P.y` (computed): `dy = -1, 0, +1`: 21 inner and 16 outer-only; `dy = +2`: 9 inner and 16 outer-only; `dy = +3`: 0 inner and 9 outer-only; nothing at `dy >= 4`. So below and at `P.y` the podium is a disc of radius about 2.5
(bedrock, or the portal layer) inside a ring to about 3.5 (end stone below, bedrock rim at the portal layer), above it a sphere of air up to `P.y + 3`, the 4-high bedrock pillar and four torches. The call sites of the exit portal and the delayed gateway are in 21 section 6.4.5 (the inactive form when the portal is first built, the active form when the dragon dies, a gateway per kill); the remaining call site of `createEndPlatform(..., true)` is Open question 5.

### 10.4 `end_gateway` (`EndGatewayFeature`)

Fields: `exit` (optional block position), `exact` (boolean, required). **Place** (`G` = origin): visit the box iterator over `(Gx - 1, Gy - 2, Gz - 1) .. (Gx + 1, Gy + 2, Gz + 1)`. For each cell `q`:
`sx = (q.x = G.x)`, `sy = (q.y = G.y)`, `sz = (q.z = G.z)`, `edge = (|q.y - G.y| = 2)`. First matching rule wins (flags 3 everywhere):

1. `sx and sy and sz`: set `end_gateway`; then, when `exit` is present and the block entity at `q` is an end gateway, call `setExitPosition(exit, exact)` on it (stores the position and the exact flag and marks the entity changed);
2. `sy`: `air`;
3. `edge and sx and sz`: `bedrock`;
4. `sx or sz`: `air` when `edge`, otherwise `bedrock`;
5. otherwise: `air`.

Return true. Layers (computed; `G` centre, `B` bedrock, `.` air; rows are `z = -1, 0, +1`, columns `x = -1, 0, +1`): `dy = +-2`: `...`/`.B.`/`...`; `dy = +-1`: `.B.`/`BBB`/`.B.`; `dy = 0`: `...`/`.G.`/`...`. Total 3 x 5 x 3 = 45 cells written. The data element `end_gateway_return` has
`exact` true and `exit [100, 50, 0]`; `end_gateway_delayed` has `exact` false and no exit. The block entity's own behaviour (teleport target selection, cooldown) is not part of this document (Open question 6).

### 10.5 `void_start_platform` (`VoidStartPlatformFeature`)

No fields. Constants: `PLATFORM_OFFSET = (8, 3, 8)`, `PLATFORM_ORIGIN_CHUNK` = the chunk containing `PLATFORM_OFFSET` = chunk (0, 0), `PLATFORM_RADIUS = 16`, `PLATFORM_RADIUS_CHUNKS = 1`.
`checkerboardDistance(a, b, c, d) = max(|a - c|, |b - d|)`. **Place** (`origin`): `chunk` = the chunk containing `origin`. When the chunk's checkerboard distance from chunk (0, 0) is greater than 1, return true and do nothing.
Otherwise `centre = (8, origin.y + 3, 8)`. For `z` from the chunk's minimum block z to its maximum, `x` from its minimum block x to its maximum (x inner): skip when `checkerboardDistance(centre.x, centre.z, x, z) > 16`; else
set `cobblestone` when `(x, centre.y, z)` equals `centre`, `stone` otherwise, at `(x, centre.y, z)` with flags 2. Return true. In decoration `origin.y` is the level's minimum y (35-1 section 6), so in a void world of
`minY = -64` the platform would be at `y = -61` (illustrative: no dimension using the `the_void` biome was identified, Open question 13; the formula `origin.y + 3` is read); it spans `x, z` from -8 to 24 (33 x 33 blocks, built chunk by chunk by the nine chunks (-1..1, -1..1)), with a single cobblestone block at `(8, y, 8)`.

---

## 11. `bonus_chest`, `fill_layer` (by reference) and `template`

### 11.1 `bonus_chest` (`BonusChestFeature`)

Specified in 35-5 section 18 (two 16-value shuffles, the heightmap position per column, the chest, the loot table `chests/spawn_bonus_chest` with one `nextLong` draw, the four torches). 35-5 section 18 also names the caller: the server's world-initialisation code, once, when the world option "bonus chest" is set, after the world spawn is chosen. This part read the feature independently and agrees; it is not repeated here.

### 11.2 `fill_layer` (`FillLayerFeature`)

Specified in 35-5 section 11 (the 16 x 16 columns from the origin's x and z, the layer at `minY + height`, writes only into air with flag 2, no draws). It agrees with this part's reading; not repeated here. No data element uses it (section 1).

### 11.3 `template` (`TemplateFeature`)

Specified in 35-6 section 10.1 (fields and placement), 10.4 (geometry) and 10.5 (`StructureTemplate.placeInWorld`); the desert well, the main data user, in 35-5 section 17. This part read the feature independently; the text below agrees and is kept as a cross-check, not as the owner.

Fields: `templates` (a weighted list, 23 section 7, of `TemplateEntry = {id: identifier, rotations: list of rotations, default all four in the order none, clockwise_90, 180, counterclockwise_90}`),
`processors` (optional structure processor list). **Place** (`origin`):

1. `entry = templates.getRandomOrThrow(random)` (one draw, the weighted pick of 23 section 7), then `rotation` = a uniform pick from the entry's `rotations` with `nextInt(size)` (`Util.getRandom(list)`).
2. Fetch the structure template of `entry.id` from the server's template manager (the NBT of `data/<namespace>/structure/<path>.nbt`, a data file the tool extracts; the engine is 35-6 section 10).
3. Offsets: `offX = unit(rotation.rotate(WEST)) * (sizeX div 2)` and `offZ = unit(rotation.rotate(NORTH)) * (sizeZ div 2)`, where `size` is the template's unrotated size, `div` is integer division, and `rotation.rotate`
   turns a horizontal direction about the vertical axis (`none`: unchanged; `clockwise_90`: north to east to south to west; `180`: opposite; `counterclockwise_90`: the inverse of clockwise). `anchor = origin + offX + offZ`.
4. Settings: rotation `rotation`, the feature's random as the settings' random, then each processor of the optional list added in order.
5. Place with `StructureTemplate.placeInWorld(level, anchor, anchor, settings, random, flags 3)` and return its result.

Example (computed): a template of size (7, h, 7) with rotation `none` is anchored at `origin + (-3, 0, -3)`; with `clockwise_90`, `offX = north * 3 = (0, 0, -3)` and `offZ = east * 3 = (3, 0, 0)`, so the anchor is `origin + (3, 0, -3)`
(the rotation pivot is the anchor itself). The data uses `template` for `desert_well` (35-5 section 17) and for the sulfur springs.

---

## 12. Coverage audit of `net.minecraft.world.level.levelgen.feature.*`

Counts read with `unzip -Z1`, directory entries excluded: the package `levelgen.feature` has 67 top-level classes, plus 12 nested; the 58 registered feature types account for 58 of them and nine are helpers; the sub-packages
`featuresize` (4), `foliageplacers` (14 top-level, 2 nested), `rootplacers` (5), `stateproviders` (13 top-level, 2 nested), `treedecorators` (13, 1 nested), `trunkplacers` (12, 1 nested) are counted without `package-info`; the
sibling packages `levelgen.placement` (25) and `levelgen.blockpredicates` (20) are included for completeness.

### 12.1 The 58 feature types in registry order (`FeatureTypes`; ids as 35-1 section 3.1, confirmed against the order of the type names in `FeatureTypes`)

Owner is the document section that specifies the engine. "35-n" is another part of document 35. Parts 5 and 6 now exist; every owner below was confirmed by searching them for the class name (headings of 35-5 and 35-6 read this round).

| id | name | class | Owner |
|---|---|---|---|
| 0 | `bamboo` | `BambooFeature` | 35-4 section 6 |
| 1 | `block_blob` | `BlockBlobFeature` | 35-5 section 6 (forest rock) |
| 2 | `block_column` | `BlockColumnFeature` | 35-4 section 5 |
| 3 | `block_pile` | `BlockPileFeature` | 35-5 section 12 |
| 4 | `blue_ice` | `BlueIceFeature` | 35-5 section 10 |
| 5 | `bonus_chest` | `BonusChestFeature` | 35-5 section 18 (section 11.1 here is a cross-reference) |
| 6 | `chorus_plant` | `ChorusPlantFeature` | section 9 |
| 7 | `coral_claw` | `CoralClawFeature` | 35-5 section 14.2 |
| 8 | `coral_tree` | `CoralTreeFeature` | 35-5 section 14.1 |
| 9 | `delta_feature` | `DeltaFeature` | section 3 |
| 10 | `disk` | `DiskFeature` | 35-5 section 5 |
| 11 | `end_gateway` | `EndGatewayFeature` | section 10.4 |
| 12 | `end_island` | `EndIslandFeature` | section 10.1 |
| 13 | `end_platform` | `EndPlatformFeature` | section 10.2 |
| 14 | `end_podium` | `EndPodiumFeature` | section 10.3 |
| 15 | `end_spike` | `EndSpikeFeature` | section 8 |
| 16 | `fallen_tree` | `FallenTreeFeature` | 35-3 |
| 17 | `fill_layer` | `FillLayerFeature` | 35-5 section 11 (section 11.2 here is a cross-reference) |
| 18 | `fossil` | `FossilFeature` | 35-6 section 10 |
| 19 | `freeze_top_layer` | `SnowAndFreezeFeature` | 35-5 section 8 |
| 20 | `geode` | `GeodeFeature` | 35-6 section 4 |
| 21 | `huge_brown_mushroom` | `HugeBrownMushroomFeature` | 35-4 section 11 |
| 22 | `huge_fungus` | `HugeFungusFeature` | 35-4 section 11.5 |
| 23 | `huge_red_mushroom` | `HugeRedMushroomFeature` | 35-4 section 11 |
| 24 | `iceberg` | `IcebergFeature` | 35-5 section 9 |
| 25 | `lake` | `LakeFeature` | 35-5 section 3 |
| 26 | `large_dripstone` | `LargeDripstoneFeature` | 35-6 section 7 |
| 27 | `monster_room` | `MonsterRoomFeature` | 35-6 section 9 |
| 28 | `multiface_growth` | `MultifaceGrowthFeature` | 35-4 section 8 |
| 29 | `netherrack_replace_blobs` | `ReplaceBlobsFeature` | 35-5 section 7 (section 6.1 here is a cross-reference) |
| 30 | `no_op` | `NoOpFeature` | 35-1 section 9.1 |
| 31 | `ore` | `OreFeature` | 11 section 7 |
| 32 | `overlay` | `OverlayFeature` | 35-4 section 7.4 (and section 5.1 here) |
| 33 | `projected_random_patchy_square` | `ProjectedRandomPatchySquare` | 35-4 section 7.6 (composition: section 5.2 here) |
| 34 | `random_boolean_selector` | `RandomBooleanSelectorFeature` | 35-1 section 9.4 |
| 35 | `random_neighbor_spread` | `RandomNeighborSpreadFeature` | 35-4 section 7.3 |
| 36 | `random_selector` | `RandomSelectorFeature` | 35-1 section 9.2 |
| 37 | `replace_single_block` | `ReplaceBlockFeature` | 35-4 section 7.5 (section 6.2 here) |
| 38 | `root_system` | `RootSystemFeature` | 35-4 section 10 |
| 39 | `scattered_ore` | `ScatteredOreFeature` | **gap: named in no part** (11 section 7 specifies only `ore`; used by data, Open question 2) |
| 40 | `sculk_patch` | `SculkPatchFeature` | 35-6 section 8 |
| 41 | `sequence` | `SequenceFeature` | 35-1 section 9.6 |
| 42 | `simple_block` | `SimpleBlockFeature` | 35-4 section 4 |
| 43 | `simple_random_selector` | `SimpleRandomSelectorFeature` | 35-1 section 9.3 |
| 44 | `single_block_pillar` | `SingleBlockPillarFeature` | 35-4 section 7.2 (composition: section 5.2 here) |
| 45 | `speleothem` | `SpeleothemFeature` | 35-6 section 5 |
| 46 | `speleothem_cluster` | `SpeleothemClusterFeature` | 35-6 section 6 |
| 47 | `spike` | `SpikeFeature` | 35-5 section 16 (section 7 here is a cross-reference) |
| 48 | `spring_feature` | `SpringFeature` | 35-5 section 4 |
| 49 | `stepped_column_cluster` | `SteppedColumnClusterFeature` | section 4 |
| 50 | `template` | `TemplateFeature` | 35-6 section 10.1 (owner; the engine is 35-6 sections 10.4 and 10.5, the desert well 35-5 section 17); section 11.3 is an independent reading |
| 51 | `tree` | `TreeFeature` | 35-3 |
| 52 | `underwater_magma` | `UnderwaterMagmaFeature` | 35-5 section 15 |
| 53 | `vegetation_patch` | `VegetationPatchFeature` | 35-4 section 9 |
| 54 | `vines` | `VinesFeature` | 35-4 section 7.1 |
| 55 | `void_start_platform` | `VoidStartPlatformFeature` | section 10.5 |
| 56 | `waterlogged_vegetation_patch` | `WaterloggedVegetationPatchFeature` | 35-4 section 9.3 |
| 57 | `weighted_random_selector` | `WeightedRandomSelectorFeature` | 35-1 section 9.5 |

### 12.2 Helper classes of the package and its sub-packages

| Class or group | Owner |
|---|---|
| `Feature`, `FeatureTypes`, `FeatureCountTracker` (3 nested), `WeightedPlacedFeature`, `CuboidPlacement` (a placement modifier) | 35-1 (sections 2, 3.1, 2.4, 9.7, 7.14) |
| `AbstractOreFeature`, `OreFeature` | 11 section 7 |
| `AbstractHugeMushroomFeature` | 35-4 section 11.1 |
| `BlockReplacement` (record of `replace_single_block`) | 35-4 section 7.5 (read here, section 6.2) |
| `SpeleothemUtils` | 35-6 sections 2.3 and 5.3 |
| `BlockColumnFeature$Layer`, `FallenTreeFeature$Builder`, `TreeFeature$Builder`, `TreeFeature$1`, `LargeDripstoneFeature$LargeDripstone` and `$WindOffsetter` | with their outer class |
| `EndSpikeFeature$EndSpike`, `$SpikeCacheLoader` | section 8.1 |
| `TemplateFeature$TemplateEntry` | 35-6 section 10.1 (section 11.3) |
| `featuresize.*` (4), `trunkplacers.*`, `foliageplacers.*`, `rootplacers.*` | 35-3 |
| `treedecorators.*` (13 top-level classes: 11 concrete decorators, the base `TreeDecorator` and `TreeDecoratorType`; plus the nested `TreeDecorator$Context`) | 35-4 section 3 |
| `stateproviders.*`, `blockpredicates.*` | 35-2 |
| `placement.*` (25: 17 concrete modifier classes plus 8 helpers `PlacedFeature`, `FeaturePlacer`, `PlacementContext`, `PlacementModifier`, `PlacementModifierTypes`, `PlacementFilter`, `RepeatingPlacement`, `CaveSurface`; the 18th modifier, `CuboidPlacement`, is in the `levelgen.feature` package, row above) | 35-1 (sections 7 and 8) |

### 12.3 Findings of the audit

1. `overlay` is not in the list of generic features of 35-1 section 9 although it is a combinator; 35-4 section 7.4 specifies it and section 5.1 here repeats the facts: covered twice, consistent.
2. `bonus_chest`, `fill_layer`, `netherrack_replace_blobs` and `spike` are owned by 35-5 (sections 18, 11, 7 and 16); this part keeps cross-references only. `template` is owned by 35-6 section 10.1 (the engine: 10.4 and 10.5; the desert well: 35-5 section 17); section 11.3 repeats it as an independent reading.
3. `single_block_pillar`, `overlay`, `projected_random_patchy_square` and `replace_single_block` are specified by both 35-4 and this part (read independently; they agree on every statement). The basalt pillar's composition,
   the only user of the first three, is section 5.2.
4. `ChorusFlowerBlock.generatePlant` and `growTreeRecursive`, which 24-6 (its Open question 6) deferred to document 35, are section 9.
5. `block_blob` (35-5 section 6), `block_pile` (35-5 section 12) and `underwater_magma` (35-5 section 15) are owned; `scattered_ore` is the one type named in no part (grep over docs/protocol finds it only in 35-1's type table and here). The data uses it for `ore_ancient_debris_large` and `ore_ancient_debris_small` (the only two files under `worldgen/` that name it), so it is a real gap.
6. `StructureTemplate.placeInWorld` is covered by 35-6 section 10.5. The RuleTest family and the structure processor list (used by `replace_single_block` and `template`) remain unread by this part (Open question 4).
7. Of the 58 types, the data pack uses 56; `fill_layer` and `replace_single_block` have no element (checked over `feature/` including `coral/`, and over `placed_feature/`). `end_podium_active`, `end_podium_inactive`, `end_gateway_delayed` and `bonus_chest` are data features with no placed feature (section 1).

---

## 13. Worked examples (computed)

All examples were produced by a throwaway reference script applying the rules above (Java LCG as in 10 section 3). They are validation fixtures, not observations of the artifact.

| Example | Where |
|---|---|
| Diamond iterator order for reach `(2, 0, 1)`: 15 offsets listed in section 3 | section 3 and 2.3 |
| Basalt column heights on a flat floor | section 4 |
| Ice spike cone layers for `H = 8`, `W = 2` | 35-5 section 16 |
| End spike list for world seeds 0 and 1 | section 8.2 |
| Chorus plant for random seed 1 | section 9 |
| End island layers and counts | section 10.1 |
| Podium, gateway layouts | sections 10.3 and 10.4 |
| Template anchor offsets | section 11.3 |

Two more fixtures for the Java generator (computed): world seed 12345 gives `key = 45873` and spike order `[7, 9, 5, 0, 6, 8, 1, 4, 3, 2]` (spike 0 at (42, 0) with radius 4 and height 97, spike 5 at (-42, -1) with radius 4
and height 100; guarded spikes are `i = 6` and `i = 9`); the shuffle `Util.toShuffledList` of `[0..9]` consumes the draws `nextInt(10)`, `nextInt(9)`, ..., `nextInt(2)` (nine draws).

---

## 14. Validation

An implementation of this part is checked by these tests, each derived from the text above.

1. **Iterators.** `betweenClosed` over `(0,0,0)..(1,1,1)` yields `(0,0,0), (1,0,0), (0,1,0), (1,1,0), (0,0,1) ...`. The diamond iterator with reach `(2, 0, 1)` yields exactly the 15 offsets of section 3 in that order; with reach `(1, 1, 1)`
   yields 27 offsets, the first being the origin, the next six those of distance 1.
2. **Spike list.** For world seed 0 the table of section 8.2; the ten centres are the same for every seed; spike 5 has `centerZ = -1` and spike 0 `centerZ = 0`; the multiset of `(radius, height, guarded)` over the ten spikes is
   `{(2,76,no), (2,79,yes), (2,82,yes), (3,85,no), (3,88,no), (3,91,no), (4,94,no), (4,97,no), (4,100,no), (5,103,no)}` for every seed.
3. **End island.** With `nextInt(3) = 1` and layer draws 0, 1, 0, 1 the five layers have 109, 97, 45, 37, 9 blocks (297 in total).
4. **Gateway.** Layout of section 10.4: exactly one `end_gateway`; 12 bedrock cells (five at `dy = +1`, five at `dy = -1` in the plus pattern, one each at `dy = +2` and `dy = -2`); all other cells of the 3 x 5 x 3 box are air
   (count check: 45 cells = 1 gateway + 12 bedrock + 32 air).
5. **Podium.** Layer counts of section 10.3; the pillar is 4 bedrock blocks at `P .. P + 3`; torches at `P + (0,2,0) + d` for four directions, facing `d`.
6. **Platform.** `createEndPlatform` at `(100, 49, 0)`: 25 obsidian at `y = 48`, 75 air at `y = 49 .. 51`, from `x = 98 .. 102`, `z = -2 .. 2`.
7. **Void platform.** Chunk (2, 0) writes nothing; chunk (1, 1) writes `x` 16 to 24 and `z` 16 to 24 (81 stone blocks); the whole platform is 1089 blocks of which one is cobblestone.
8. **Chorus plant.** Draw log of section 9 reproduces the 8-block plant for seed 1 (including the flower replacing the trunk top); no plant block ever lies `>= 8` blocks from the origin horizontally, and depth never exceeds 4.
9. **Delta.** `isClear` is false for `bedrock`, `nether_bricks`, `nether_brick_fence`, `nether_brick_stairs`, `nether_wart`, `chest`, `spawner`, for the contents block itself, for a block with air beside or below it, and for a block with a non-air block above.
10. **Stepped columns.** The column centre cell never produces blocks; `findSurface` with range 0 returns nothing.

---

## 15. Open questions

1. **(Resolved.)** Ownership of parts 5 and 6 rows was confirmed by grepping both parts (section 12.1).
2. **`scattered_ore` is specified nowhere.** `ScatteredOreFeature` (used by `ore_ancient_debris_large` and `ore_ancient_debris_small`, nether ancient debris) is named only in 35-1's table and here; `OreFeature` (11 section 7) does not cover it. Searched: every file of docs/protocol and docs/design by class and type name. A round must read it before document 35 is complete.
3. **Sine and cosine at the edge of `floor`.** The spike centres of section 8.1 use the double results of `Math.sin` and `Math.cos`. They were computed with IEEE double arithmetic; the two values that decide a `floor` by their sign
   (`sin(-2 pi)` giving a tiny positive number and `sin(-pi)` a tiny negative one) agree with a correctly rounded result (inferred: Java's `Math.sin` may differ from a correctly rounded value in the last unit, which cannot change the sign
   of a value of magnitude 1e-16). An implementation may simply tabulate the ten centres of section 8.2.
4. **RuleTests and processors.** The RuleTest family (needed by `replace_single_block`, no data user) and the structure processor family used by `template` were not read in this part; `StructureTemplate.placeInWorld` is 35-6 section 10.5. Check 35-6 section 10 and the structure documents for the processor semantics before relying on them.
5. **Callers with other arguments.** `EndPlatformFeature.createEndPlatform(level, pos, true)` (destroy with drops), `end_podium` (inactive and active), and `end_gateway_delayed` have no placed feature; the callers of `end_podium` and `end_gateway_delayed` are in 21 section 6.4.5 (exit portal location rule, gateway positions and the kill sequence). Still not read: the caller of `createEndPlatform(level, pos, true)` (the player's arrival in the End; searched 21 and 35-5), so it is the only open part.
6. **End gateway block entity.** Only `setExitPosition(exit, exact)` was read (it stores the two values and marks the entity changed). The teleport target logic, cooldown and the entity's NBT are not specified in this part.
7. **Bonus chest and the spawn logic.** The caller is given in 35-5 section 18 (world initialisation with the bonus-chest option, after the spawn is set); the loot table is extracted data (35-5 section 18). Remaining: `setBlockEntityLootTable` applies only if a block entity exists when it is called
   (inferred: a chest placed with `setBlock` flags 2 has one).
8. **(Resolved.)** Fire state above the crystal base: read in section 8.2 step 3 (`BaseFireBlock.getState`, `FireBlock.getStateForPlacement`, the soul tag contents, the constructor default).
9. **(Resolved.)** Iron bars properties: the `IronBarsBlock` constructor registers a default state with `north`, `east`, `south`, `west` and `waterlogged` all false; the cage sets the four side flags only (section 8.2 step 2), so `waterlogged` is false.
10. **Heightmap position semantics for `bonus_chest`.** `getHeightmapPos(MOTION_BLOCKING_NO_LEAVES, ...)` is specified in 35-1 section 4.2; this part relies on it without re-reading.
11. **Placed-feature `biome` modifier for nested placed features.** The cap feature and the overlay children of the basalt pillar are run through fresh placers that carry no top feature (35-1 section 8.1); none of them contains a `biome`
    modifier, so the behaviour of that filter without a top feature (35-1 section 7.3) does not matter here.
12. **Effect of `permanentlyInvulnerable`.** Only the setter call was read here; the effect is described in 21 section 6.3 ("invulnerable to base damage").
13. **Dimension using `void_start_platform`.** The `y = -61` example of section 10.5 assumes a void world of `minY = -64`. Searched: the End dimension type (`min_y` 0) and the overworld; no dimension or world preset using the `the_void` biome was identified in the extracted data.
