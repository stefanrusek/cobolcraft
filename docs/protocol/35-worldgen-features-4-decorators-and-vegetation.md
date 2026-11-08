# World generation features, part 4: tree decorators and vegetation features

| Item | Value |
|---|---|
| Covers | The engines that place plants and plant-like content during decoration: the eleven tree decorators (`treedecorators.*`), the way "random patches" are expressed in 26.3, `simple_block`, `block_column`, `bamboo`, `single_block_pillar`, `vines`, `multiface_growth`, `random_neighbor_spread`, `vegetation_patch` and `waterlogged_vegetation_patch`, `root_system`, `huge_brown_mushroom`, `huge_red_mushroom`, `huge_fungus`, `overlay`, `replace_single_block` and `projected_random_patchy_square`, with the Nether vegetation built from them. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data JSON under `data/minecraft/worldgen/` in the jar, with no execution. Class names are not obfuscated. |
| Round | RS19 (GAP-12a), part 4 of the 35 series. Sibling parts: 1 framework and placement modifiers, 2 predicates and providers, 3 tree placers, 5 water and surface, 6 underground, 7 nether, end and misc. |
| Related | Decoration order, seeding and the placed-feature pipeline: [11-world-generation-caves-and-ores.md](11-world-generation-caves-and-ores.md) §6. Random primitives (`nextInt`, `nextFloat`, `nextBoolean`): 10 §2 and 11 §2.3, §4. Block rules the features call into (`canSurvive`, shapes): [24-block-registry-1-model-and-foundation.md](24-block-registry-1-model-and-foundation.md) and its siblings; block updates: [29-block-updates-and-placement.md](29-block-updates-and-placement.md). |

Scope rule (operator decisions in CC-0001 and `docs/design/README.md` R7): the configured features, placed features, block state
providers and tags are **data** that the extraction tool copies from the jar; this document does not tabulate them. It specifies the
code that interprets them. Data rows appear only as short worked examples, each tagged with the file it was read from.

## 1. Conventions

### 1.1 Random draws

Every feature below receives the single `RandomSource` of the placed feature that invoked it (11 §6.3) and draws from it in the order
written. "draw `nextInt(n)`" means one call with that bound, even when `n` is 1 (the generator consumes a value for every bound; 10 §2.3
gives `nextInt(bound)` for the Xoroshiro source, which always consumes). Derived calls used throughout, all read from the artifact:

| Call | Meaning |
|---|---|
| `nextIntBetweenInclusive(lo, hi)` | `nextInt(hi - lo + 1) + lo` (`RandomSource`) |
| `Mth.nextInt(r, lo, hi)` | `lo` when `lo >= hi`, otherwise `r.nextInt(hi - lo + 1) + lo` |
| `Mth.randomBetweenInclusive(r, lo, hi)` | `r.nextInt(hi - lo + 1) + lo` |
| shuffle of a list of size `n` (`Util.shuffle`) | for `i = n` down to `2`: `j = nextInt(i)`; swap elements `i-1` and `j`. A list of size 0 or 1 draws nothing. `Util.shuffledCopy` shuffles a copy; `Util.toShuffledList` collects a stream then shuffles |
| pick from a list (`Util.getRandom(list, r)`) | `list[nextInt(size)]` (always one draw, also for size 1). `Direction.Plane.getRandomDirection` picks from the plane's array with the same rule |
| `TrapezoidInt` sample (`min`, `max`, `plateau`) | see §2.2 |

`Direction` ordinals are DOWN 0, UP 1, NORTH 2, SOUTH 3, WEST 4, EAST 5 (`Direction.values()` and `Direction.allShuffled` use this
order). `Direction.Plane.HORIZONTAL` iterates NORTH, EAST, SOUTH, WEST. `getClockWise` on the horizontal plane is NORTH to EAST to SOUTH
to WEST to NORTH (read: `getClockWise` is a table switch on the ordinal, NORTH (2) to EAST, SOUTH (3) to WEST, WEST (4) to NORTH, EAST (5) to SOUTH, so the cycle N, E, S, W, N is confirmed). `Direction.from2DDataValue(i)` indexes an array sorted by the 2D data value (SOUTH 0, WEST 1, NORTH 2, EAST 3) with `|i mod 4|`, so its order is SOUTH, WEST, NORTH, EAST; `root_system.spaceForTree` uses it, and the order has no effect there because no random draws are made.

### 1.2 Block write flags

`setBlock(pos, state, flags)` flags that appear: `2` (send to clients, no neighbour updates: every plain vegetation write below),
`3` (`LevelWriter.setBlockAndUpdate`: the default of `Feature.setBlock`, used by huge fungus), `19` (= 16 + 2 + 1, the tree
placers and the tree decorators) and `260` (= 256 + 4, huge fungus clearing its own origin). Semantics of the bits: [29-block-updates-and-placement.md](29-block-updates-and-placement.md).
Reads in these features use the world-generation region (`WorldGenLevel`): the 3 x 3 chunk window of 11 §6.5 applies to every write.
`markPosForPostProcessing(pos)` records a position in its chunk for a later post-processing pass (11 §6.5 and the scheduler); multiface
growth and `Feature.markAboveForPostProcessing` (two cells upward, stopping at the first air) are the callers in this document.

### 1.3 How the pieces compose in 26.3

The 26.3 artifact has **no** `random_patch`, `flower`, `no_bonemeal_flower` or `vegetation` feature types (the registry in `FeatureTypes`
holds 58 types; §2 explains where patches went). In this version the feature classes are `record`s that carry their own configuration
(there is no separate `*Configuration` class for the features of this document), and every feature's `place` has the signature
`(level, generator, random, origin) -> boolean`. Use counts in the jar (240 files under `worldgen/feature/`, 47 distinct types;
273 files under `worldgen/placed_feature/`):

| Feature type (count of configured features of this type) | Examples (file stems under `worldgen/feature/`) |
|---|---|
| `simple_block` (37) | `grass`, `tall_grass`, `flower_plain`, `brown_mushroom`, `crimson_roots`, `nether_sprouts`, `moss_vegetation` |
| `block_column` (6) | `kelp`, `sugar_cane`, `cactus`, `cave_vine`, `cave_vine_in_moss`, `twisting_vines` |
| `bamboo` (2) | `bamboo_no_podzol`, `bamboo_some_podzol` |
| `vines` (1) | `vines` |
| `multiface_growth` (2) | `glow_lichen`, `sculk_vein` |
| `random_neighbor_spread` (1 top level, 2 files use it) | `glowstone_extra`, nested in `weeping_vines` |
| `vegetation_patch` (6), `waterlogged_vegetation_patch` (1) | `moss_patch`, `moss_patch_ceiling`, `pale_moss_patch`, `clay_with_dripleaves`, `clay_pool_with_dripleaves` |
| `root_system` (2) | `rooted_azalea_tree`, `rooted_sulfur_spring` |
| `huge_brown_mushroom`, `huge_red_mushroom` (1 each) | same names |
| `huge_fungus` (4) | `crimson_fungus`, `crimson_fungus_planted`, `warped_fungus`, `warped_fungus_planted` |
| `overlay` (11 files use it, 10 at top level) | `weeping_vines`, `basalt_pillar`, `coral/*`, `desert_well`, `nylium_bonemeal` |
| `single_block_pillar`, `projected_random_patchy_square` | only inside `basalt_pillar` (Open question 6) |
| `replace_single_block` | no configured feature in the jar uses it (Open question 7) |
| trees (`tree`, 45) with decorators | §3 lists the decorator JSON that occurs |

## 2. Random patches: `count`, `offset`, `block_predicate_filter`

### 2.1 The patch idiom

A "patch of grass, flowers, sugar cane, roots or mushrooms" is an ordinary placed feature whose configured feature is a single-block
feature (`simple_block`, `block_column`) and whose placement list contains the three modifiers
`count N`, `offset {x, y, z}` and `block_predicate_filter P`. 80 of the 273 placed features in the jar contain all three; 67 of those end with exactly that sequence (68 placed features end with `offset` then `block_predicate_filter`), and the rest have other modifiers before the final ones (for example `twisting_vines`, §11.6). The semantics
follow from the per-position pipeline of 11 §6.4 (depth first, each position finishes before its sibling starts):

1. `count N`: the incoming position is emitted `N` times (`N` is an int provider; a constant draws nothing). N is the number of **tries**.
2. `offset`: for each emitted position, draw the x offset from the `x` int provider, then the y offset from `y`, then the z offset from
   `z` (this order, read from `OffsetPlacement.modify`), and emit the position moved by the three values. The `xz` spread of the patch is
   the width of the `x` and `z` providers, the vertical spread the width of `y`.
3. `block_predicate_filter P`: the position survives only if the predicate (sibling part 2) is true there. It draws nothing itself.
4. The configured feature runs at the surviving position with the same random source.

So a try costs the draws of step 2, then (if the filter passes) the feature's own draws; the next try starts after that. A feature that
fails (a `simple_block` whose block cannot survive) simply consumes its draws and the patch moves on. There is no per-patch bookkeeping and
no limit other than N. Typical shapes in the data: grass `count 32`, x and z `trapezoid -7..7 plateau 0`, y `trapezoid -3..3 plateau 0`;
plain flowers `count 64`, `trapezoid -6..6`, y `-2..2`; sugar cane `count 20`, x and z `trapezoid -4..4`, y `trapezoid 0..0`, filter
`air AND would_survive(sugar_cane) AND water next to the block below`. The Nether vegetation is three-level: see §11.6.

### 2.2 `TrapezoidInt` (used by every patch offset)

`TrapezoidInt(min, max, plateau)`; `triangle(m) = (-m, m, 0)`. Sampling (read from `TrapezoidInt.sample`):

| Case | Draws and result |
|---|---|
| `plateau == 0` and `max == -min` | `a = nextInt(max + 1)`, then `b = nextInt(max + 1)`; result `a - b` |
| `plateau == max - min` | `Mth.randomBetweenInclusive(min, max)`: one draw |
| otherwise | `span = max - min`; `lo = (span - plateau) / 2` (integer division); `hi = span - lo`; result `min + randomBetweenInclusive(0, hi) + randomBetweenInclusive(0, lo)` (draws in that order: the `hi` one first) |

Examples: `trapezoid -7..7 plateau 0` is `nextInt(8) - nextInt(8)`; `trapezoid -4..1 plateau 3` (the vertical offset of the weeping-vine
overlay, §11.6) has `span 5`, `lo = 1`, `hi = 4`: result `-4 + nextInt(5) + nextInt(2)`, range -4..1. The other int providers are in sibling part 2.

## 3. Tree decorators

### 3.1 Registry and shared context

`TreeDecoratorType` registers eleven codecs, in this order (the registry order sets numeric ids; they are not synchronized to clients):
`trunk_vine`, `leave_vine`, `pale_moss`, `creaking_heart`, `cocoa`, `shelf_mushroom`, `beehive`, `alter_ground`, `attached_to_leaves`,
`place_on_ground`, `attached_to_logs`. A tree feature carries `decorators`, an ordered list, run **in list order** after the tree itself
(`TreeFeature.place`; tree placers are sibling part 3). Steps in `TreeFeature.place` that matter here:

1. Three position sets collect what the placers wrote: roots (root placer output), logs (trunk placer output) and foliage (leaves). A
   fourth set collects what decorators write. All are Java `HashSet`s of immutable `BlockPos` (Open question 1).
2. If the placement failed, or logs and foliage are both empty, the feature returns false and no decorator runs.
3. If the decorator list is not empty, a `TreeDecorator.Context` is built with the level, a setter, the feature random source, the log
   list, the leaf list and the root list. The constructor copies each set into a list and **sorts each list by Y ascending** (a stable
   sort; positions of equal Y keep the order the set iteration gave them, Open question 1). The decorators run one after another with
   this one context.
4. The setter used by decorators writes with flags `19` and also records the position in the fourth set. The bounding box of all four
   sets is afterwards used to refresh leaf distances and neighbour shapes (sibling part 3), so decorator writes take part in that
   refresh.

Context helper predicates (read from `TreeDecorator$Context`):

| Helper | Meaning |
|---|---|
| `isAir(p)` | the state at `p` is air |
| `isReplaceable(p)` | the state's `canBeReplaced()` is true |
| `isWaterOrWaterNearby(p)` | the block at `p`, or at one of the four horizontal neighbours of `p`, is the block `minecraft:water` |
| `checkBlock(p, predicate)` | the predicate holds on the state at `p` |
| `placeVine(p, face)` | set `minecraft:vine` with the one given face property true at `p` |
| `getLowestTrunkOrRootOfTree` (`TreeFeature`) | if the root list is empty: the log list; else if the log list is not empty and the first root and first log have the same Y: the log list followed by the root list; otherwise: the root list. The result is consumed as "the lowest layer" by taking `first.y` and filtering by that Y |

### 3.2 Order of the early exits and draws

The decorators differ in whether the probability draw comes before or after the "no logs" exit; an implementation that reorders these
changes the random stream of every later feature.

| Decorator | First steps |
|---|---|
| `trunk_vine` | no probability; no empty check; per-log draws only (§3.3) |
| `leave_vine` | no empty check; per-leaf draws |
| `cocoa` | draws `nextFloat()` first; returns if `value >= probability`; then returns if there are no logs |
| `shelf_mushroom` | draws `nextFloat()` first; returns if `value >= probability`; then returns if there are no logs |
| `beehive` | returns if there are no logs (leaves may be empty); then draws `nextFloat()`; returns if `value >= probability` |
| `creaking_heart` | returns if there are no logs; then draws `nextFloat()`; returns if `value >= probability` |
| `pale_moss` | shuffled copy of the logs (draws); returns if empty; then draws as in §3.3 |
| `alter_ground`, `place_on_ground` | return if the lowest-layer list (§3.1) is empty; otherwise as in §3.3 |
| `attached_to_logs`, `attached_to_leaves` | shuffled copy of logs or leaves first (draws), then per element |

### 3.3 Each decorator

Fields and defaults are read from the codecs. `probability`-style floats are 0..1. "Provider" is a block state provider (sibling part 2);
`getState` always yields a state, `getOptionalState` may yield nothing.

**`trunk_vine`** (no fields). For every log in sorted order, four tests in the order west, east, north, south: draw `nextInt(3)`; when
the value is above 0 (probability 2/3) and the neighbour on that side of the log is air, place a vine at the neighbour with the face
that points back at the log: the west neighbour gets EAST, the east neighbour WEST, the north neighbour SOUTH, the south neighbour
NORTH. The draw happens whether or not the neighbour is air.

**`leave_vine`** (`probability`). For every leaf in sorted order, four tests in the order west, east, north, south: draw `nextFloat()`;
when `value < probability` and the neighbour on that side is air, place a *hanging vine* at that neighbour with the face that points at
the leaf (west neighbour: EAST face, east: WEST, north: SOUTH, south: NORTH). Hanging vine: set the vine at the neighbour; then the
cell below, repeated at most 4 more times: while the cell is air, set a vine with the same face there and step down (so 1 to 5 vines).
No random draw inside the hanging step.

**`cocoa`** (`probability`). After the exits of §3.2: `y0 = ` Y of the first (lowest) log. For every log with `log.y - y0 <= 2` (so at
most the three lowest layers), for each horizontal direction `d` in the order NORTH, EAST, SOUTH, WEST: draw `nextFloat()`; when
`value <= 0.25` let `p = log + (opposite(d).stepX, 0, opposite(d).stepZ)`; if `p` is air set `minecraft:cocoa` with `age = nextInt(3)`
(draw only then) and `facing = d` at `p`. So the pod sits on the side opposite to `d` and faces `d`, back toward the log. Note the
comparison is `<=` here.

**`creaking_heart`** (`probability`). After the exits: copy the logs, shuffle the copy (draws), take the first log (in shuffled order)
whose six face neighbours are all in the block tag `minecraft:logs`; if none, stop. Replace that log with `minecraft:creaking_heart`
with `state = dormant` and `natural = true`.

**`beehive`** (`probability`). After the exits (§3.2):

1. Choose the Y of the nest: if the leaf list is not empty, `y = max(lowestLeaf.y - 1, lowestLog.y + 1)`; otherwise
   `y = min(lowestLog.y + 1 + nextInt(3), highestLog.y)` (one draw only in this case). "Lowest" is the first of the sorted list.
2. Candidates: for every log at exactly that Y (sorted order), the three cells EAST, SOUTH and WEST of the log in this order (NORTH is
   excluded because `WORLDGEN_FACING` is SOUTH and the excluded direction is its opposite). If there are none, stop.
3. Shuffle the candidate list (draws); the first candidate `p` with `p` air and `p + south` air wins; if none, stop.
4. Set `minecraft:bee_nest` with `facing = south` at `p`. If a beehive block entity exists at `p`, fill it: `n = 2 + nextInt(2)`
   occupants, each created with `ticksInHive = nextInt(599)` (the draw happens per occupant, in order).

**`shelf_mushroom`** (`probability`, called `placementProbability` in the class). After the exits: if the logs all have the same Y
(first and last log of the sorted list have equal Y) the tree is a *fallen log*, otherwise *standing*.

Standing tree:

1. Draw the direction pair: one `getRandomDirection` draw over HORIZONTAL (`d`), pair = [`d`, `clockwise(d)`].
2. `base = ` Y of the first log. For each log in sorted order whose `log.y - base` is in 1..4: for each direction of the pair in order:
   draw `nextFloat()`; when `value <= 0.25` try to place; stop trying further directions for this log as soon as one placement
   succeeds (a failed attempt does not stop the loop).
3. Attempt at `(log, dir)`: `p = log + (dir.stepX, 0, dir.stepZ)`. Fails when `p` is not *shelf-replaceable* (`isReplaceable(p)` and not
   `isWaterOrWaterNearby(p)`) or when `p.below` is a `shelf_mushroom` block. Otherwise set `minecraft:shelf_mushroom` with `age = nextInt(2)`
   and `facing = dir` at `p`; success.

Fallen log (all logs level):

1. The pair is perpendicular to the log: if the first and last log differ in X the log lies along X and the pair is [NORTH, SOUTH];
   otherwise [EAST, WEST].
2. For each log in sorted order, for each direction of the pair: draw `nextFloat()`; when `value <= 0.25` attempt (no early stop).
3. Attempt: `p` as above; fails when `p` is not shelf-replaceable, or when any of the four horizontal neighbours of `p` or of the log is a
   `shelf_mushroom`. Otherwise place as in the standing case.

**`alter_ground`** (`provider`). Let `L` be the lowest layer of `getLowestTrunkOrRootOfTree` (all positions with `y == first.y`).
For every position `p` of `L` in list order:

1. Four *circles* centred at `p + (-1, 0, -1)`, `p + (+2, 0, -1)`, `p + (-1, 0, +2)`, `p + (+2, 0, +2)` in this order.
2. Then five times: draw `r = nextInt(64)`, `a = r mod 8`, `b = r div 8`; if `a` is 0 or 7, or `b` is 0 or 7, a circle centred at
   `p + (a - 3, 0, b - 3)`.

Circle at `c`: for `dx` in -2..2 (outer), `dz` in -2..2 (inner) skipping the four cells with `|dx| = |dz| = 2`: *ground column at*
`c + (dx, 0, dz)`. Ground column at `q`: for `dy = 2, 1, 0, -1, -2, -3`: `t = q + (0, dy, 0)`; ask the provider `getOptionalState(level, random, t)`;
if it yields a state set it at `t` and stop the column; otherwise, if `t` is not air and `dy < 0`, stop the column; else continue down.
(Used by `mega_pine` and `mega_spruce` with the provider `podzol_beneath_tree`.)

**`attached_to_logs`** (`probability`, `block_provider`, `directions` non-empty). Shuffled copy of the logs (draws). For each log in
that order: draw `d = ` pick from `directions` (`nextInt(size)`); `p = log + d`; draw `nextFloat()`; when `value <= probability` and `p`
is air, set `block_provider.getState(level, random, p)` at `p`. Both draws happen for every log.

**`attached_to_leaves`** (`probability`, `exclusion_radius_xz` 0..16, `exclusion_radius_y` 0..16, `block_provider`,
`required_empty_blocks` 1..16, `directions` non-empty). Keep a set `X` of excluded positions, initially empty. Shuffled copy of the
leaves (draws). For each leaf in that order:

1. Draw `d` = pick from `directions`; `p = leaf + d`.
2. If `p` is in `X`, go to the next leaf (no further draw).
3. Draw `nextFloat()`; when `value < probability` (strict, unlike `attached_to_logs`) and cells `leaf + d*1 .. leaf + d*required_empty_blocks`
   are all air: add every position of the box `p - (rxz, ry, rxz)` to `p + (rxz, ry, rxz)` to `X`, then set
   `block_provider.getState(level, random, p)` at `p`.

Used by the mangrove: `{probability 0.14, directions [down], exclusion_radius_xz 1, exclusion_radius_y 0, required_empty_blocks 2, block_provider propagule}`.

**`place_on_ground`** (`tries` positive int, default 128; `radius` non-negative, default 2; `height` non-negative, default 1; `block_state_provider`).
Let `L` be the lowest layer as above. Box `B`: X and Z extent = the min and max X and Z over the positions of `L` with `y == first.y`
(taking the min/max over those only), Y = that Y, then inflated by `radius` in X and Z and `height` in Y both ways (so Y from `y - height` to `y + height`).
Repeat `tries` times: draw X, then Y, then Z, each `nextIntBetweenInclusive(box.min, box.max)` (this order). At `q`: let `a = q + up`.
Place `provider.getState(level, random, a)` at `a` iff all of: the state at `a` is air or a vine; the state at `q` has a solid render (`isSolidRender`);
and the heightmap `MOTION_BLOCKING_NO_LEAVES` position at `q` (sibling part 1: the first free Y) has `y <= a.y`, i.e. nothing that blocks motion
and is not a leaf lies at or above `a`. Used for leaf litter: `{tries 150, height 2}` or `{tries 96, radius 4, height 2}` with a weighted
`leaf_litter` provider.

**`pale_moss`** (`leaves_probability`, `trunk_probability`, `ground_probability`). Steps in order:

1. `shuffled = ` shuffled copy of the logs (draws); if empty, stop. `lowest =` the log with the smallest Y in `shuffled` (the first one
   met on ties).
2. Draw `nextFloat()`; when `value < ground_probability`, place the configured feature `minecraft:pale_moss_patch` (key
   `VegetationFeatures.PALE_MOSS_PATCH`, looked up in the feature registry; absent means nothing) at `lowest + up` using the level's
   generator and the context random (a vegetation patch, §9).
3. For each log in sorted order: draw `nextFloat()`; when `value < trunk_probability` and `log.below` is air, run the *moss hanger* at `log.below`.
4. For each leaf in sorted order: the same with `leaves_probability`.

Moss hanger at `p`: while `p.below` is air: draw `nextFloat()`; if `value < 0.5` leave the loop; otherwise set
`minecraft:pale_hanging_moss` with `tip = false` at `p` and move `p` down. After the loop set `pale_hanging_moss` with `tip = true` at `p`.
(The first condition is tested before the draw, so no draw happens when `p.below` is not air.) Data in the jar:
`{leaves_probability 0.15, trunk_probability 0.4, ground_probability 0.8}` on `pale_oak` and `pale_oak_creaking`.

### 3.4 Decorator JSON that occurs in the jar

`attached_to_leaves` (mangrove, above); `place_on_ground` (the two leaf-litter forms above, 10 features each); `pale_moss` (above);
`beehive` with probability 0.002, 0.01, 0.02, 0.05, 1.0; `leave_vine` 0.125 (mangroves) and 0.25 (jungle, mega jungle, swamp oak); `cocoa 0.2`
(jungle tree only); `shelf_mushroom 0.4` (the poplar trees); `creaking_heart 1.0` (`pale_oak_creaking`); `alter_ground` with
`podzol_beneath_tree` (mega pine, mega spruce); `trunk_vine` (jungle, mega jungle). `attached_to_logs` occurs nested in the fallen-tree
features (sibling part 3), not in the `decorators` list of a `tree`.

## 4. `simple_block`

Fields: `to_place` (provider), `schedule_tick` (bool, default false). `place(origin)`:

1. `state = to_place.getOptionalState(level, random, origin)`; nothing: return false.
2. If `state.canSurvive(level, origin)` is false: return false.
3. By block class:
   - **double plant** (`DoublePlantBlock`): `above = state at origin + up`. Proceed when `above` is air, or when `above` has the same
     fluid state as `state` **and** `above.canBeReplaced()`; otherwise return false. Place both halves with flags 2 (below).
   - **mossy carpet** (`MossyCarpetBlock`; in `Blocks` only `minecraft:pale_moss_carpet` is constructed with `MossyCarpetBlock`, while `minecraft:moss_carpet` is an ordinary `CarpetBlock` and takes the "anything else" branch): run the mossy-carpet placement (below) with the **level's own** random
     source (`level.getRandom()`, not the feature's) and flags 2.
   - anything else: `setBlock(origin, state, 2)`.
4. If `schedule_tick`: schedule a tick (delay 1) for the block now at `origin`.
5. Return true.

Double plant placement `DoublePlantBlock.placeAt(level, state, pos, flags)`: write `state` with `half = lower` at `pos` and with `half = upper`
at `pos + up`; each with `waterlogged` copied from the fluid already at that cell (`copyWaterloggedFrom`: when the state has the `waterlogged` property, set `waterlogged` to the result of `LevelReader.isWaterAt(pos)` for that cell; otherwise return the state unchanged),
the lower first.

Mossy carpet placement `MossyCarpetBlock.placeAt(level, pos, random, flags)` (read; the block is the pale moss carpet): (a) `s1` = default
pale moss carpet state with its sides recomputed (`getUpdatedState`, with the "base" flag forced true): a side (NORTH, EAST, SOUTH, WEST)
becomes `low` when the neighbour in that direction can support it (`MultifaceBlock.canAttachTo`, never UP), `tall` when the block above is a
pale moss carpet with `base = false` that already has that side; set `s1` at `pos`; (b) `topper`: nothing (air) when the block above is a
pale moss carpet with `base = true`, or when it is not a pale moss carpet and is not replaceable; otherwise a pale moss carpet with
`base = false` whose sides are recomputed against `pos + up` and then each non-`none` side is cleared when `random.nextBoolean()` is false
(one draw per non-`none` side, in the order N, E, S, W); the topper is kept only if it has any side and differs from the state above; (c) when the topper is not
air, set it at `pos + up` and recompute and re-set the lower carpet. The intermediate branch targets of `createTopperWithSideChance` were
partly read from a flattened listing (Open question 9).

## 5. `block_column`

Fields: `layers` (list of `{height: non-negative int provider, provider: block state provider}`), `direction`, `allowed_placement`
(block predicate), `prioritize_tip` (bool). Used for kelp, sugar cane, cactus, cave vines, twisting vines. `place(origin)`:

1. For every layer in order, draw its height (`IntProvider.sample`); `total` is the sum. If `total == 0`: return false.
2. Walk `i = 0 .. total-1` over test cells `origin + direction * (i + 1)`: **the test starts one cell beyond the origin** (a copy of the origin
   moved one step is the test cursor; the write cursor starts at the origin itself; read from the bytecode and unlike the origin-based test one
   might expect, Open question 2). At the first cell where `allowed_placement.test(level, cell)` is false: truncate (step 3) with `kept = i`, and stop walking.
3. *Truncation* removes `total - kept` blocks from the layer heights: with `prioritize_tip = true` it removes from the first layer toward the
   last (the tip layer keeps its blocks longest); with `false` from the last layer toward the first. For each layer in that order,
   `take = min(height, remaining)`, subtract it, until `remaining` is 0. When every test passes, nothing is removed.
4. Write: starting at the origin, for each layer in order and each of its (possibly truncated) blocks, `setBlock(cursor, layer.provider.getState(level, random, cursor), 2)`
   and step `direction`. Return true (also when truncation reduced the column to nothing but earlier layers, since `total > 0`).

The provider is asked per block (a `randomized_int` provider, as kelp's `age 20..23`, draws per block).

Worked example, kelp (`kelp.json`: direction up; layer 0 `uniform 0..9` of `kelp_plant`; layer 1 height 1 of kelp with `age` uniform 20..23;
`prioritize_tip true`; allowed: water here and water one above): origin at Y 40, draws give `h0 = 7`, `h1 = 1` (the constant height draws
nothing; Open question 10 asks for the int provider table), `total = 8`. The tests at Y 41..45 pass, the one at Y 46 fails (`i = 5`).
`kept = 5`: `remaining = 3`, first layer: `take = 3`, heights become `[4, 1]`. Written: `kelp_plant` at Y 40, 41, 42, 43, then the kelp head at
Y 44 (5 blocks, one fewer than the passing tests because the test cursor runs one cell ahead). Sugar cane (`prioritize_tip false`, one layer of
`biased_to_bottom 2..4`): `h = 4`, test at `i = 1` fails: `kept = 1`, one block.

## 6. `bamboo`

Field `probability` (0..1; `bamboo_no_podzol` 0.0, `bamboo_some_podzol` 0.2 in the jar, but the code reads the field). Fixed states
(read from the class initializer): `TRUNK` = bamboo, `age 1`, `leaves none`, `stage 0`; `FINAL_LARGE` = `TRUNK` with `leaves large`, `stage 1`;
`TOP_LARGE` = `TRUNK` with `leaves large`; `TOP_SMALL` = `TRUNK` with `leaves small`. `place(origin)`:

1. Fail (return false) unless `origin` is empty (air) and the default bamboo state `canSurvive` at `origin`.
2. Draw `n = 5 + nextInt(12)` (5..16 stalk cells). Draw `nextFloat()`; if `value < probability`:
   draw `r = 1 + nextInt(4)`; for `x` in `ox - r .. ox + r` (outer), `z` in `oz - r .. oz + r` (inner), with `dx = x - ox`, `dz = z - oz`,
   when `dx*dx + dz*dz <= r*r`: take `y = WORLD_SURFACE height(x, z) - 1`; when the block at `(x, y, z)` is in the block tag
   `beneath_bamboo_podzol_replaceable`, set `podzol` there (flags 2). No draw inside the loop.
3. Trunk: `cursor = origin`; repeat up to `n` times while `cursor` is empty: set `TRUNK` (flags 2), `cursor` moves up one.
4. If `cursor.y - origin.y >= 3` (at least three stalk cells were placed): set `FINAL_LARGE` at `cursor`, then `TOP_LARGE` one below it, then
   `TOP_SMALL` one below that (all flags 2). Otherwise the stalk keeps no leaves.
5. Return true iff step 1 passed (the success counter is 1).

Example: draws `n = 12`, clear air to Y +20: trunk at origin+0 .. origin+11, `cursor` at origin+12: `FINAL_LARGE` at +12,
`TOP_LARGE` at +11, `TOP_SMALL` at +10. Eleven stalk cells keep plain `TRUNK` below +10, so the stalk is 13 blocks tall.

## 7. `vines`, `single_block_pillar`, `random_neighbor_spread`, `overlay`, `replace_single_block`, `projected_random_patchy_square`

### 7.1 `vines` (no fields)

If the origin is not air: return false. Otherwise for the directions in `Direction.values()` order (DOWN skipped, so UP, NORTH, SOUTH, WEST,
EAST): if `VineBlock.isAcceptableNeighbour(level, origin + d, d)` (= `MultifaceBlock.canAttachTo(level, d, neighbourPos, neighbourState)`, §8.1),
set `minecraft:vine` with only the face `d` true at the origin (flags 2) and return true. No draws. If no direction qualifies return false.

### 7.2 `single_block_pillar`

Fields: `block` (provider), `can_replace` (block predicate, default always true), `direction` (UP or DOWN only), `chance_to_continue`
(0..1, default 1.0), `cap_feature` (optional placed feature). `place(origin)`: `cursor = origin`; while `can_replace.test(level, cursor)`:
draw `nextFloat()`; stop unless `value < chance_to_continue` (the draw happens only after the predicate passed); stop if `cursor` is outside
the build height; else set `block.getState(level, random, cursor)` (flags 2) and move `cursor` one step in `direction`. After the loop move one step
**back** (opposite direction) and, if `cap_feature` exists, place that placed feature at `cursor`. Always returns true, also when nothing was placed
(the cap then runs one cell behind the origin). Only `basalt_pillar` uses it.

### 7.3 `random_neighbor_spread`

Fields: `block` (provider), `accepted_neighbors` (block set), `can_replace` (predicate), `attempts` (int provider, minimum 1),
`xz_offset` and `y_offset` (int providers, each -16..16). `place(origin)`:

1. Set `block.getState(level, random, origin)` at the origin (flags 2), unconditionally.
2. `n = attempts.sample`. Repeat `n` times: `q = origin + (xz_offset.sample, y_offset.sample, xz_offset.sample)` (draws in that x, y, z order,
   the xz provider sampled twice). If `can_replace` fails at `q`, continue. Count the six neighbours of `q` whose block is in `accepted_neighbors`
   (stop counting once the count exceeds 1). If the count is **exactly 1**, set `block.getState(...)` at `q` (flags 2).
3. Return true.

Jar data: `glowstone_extra` (accepts glowstone, `attempts 1500`, xz `trapezoid -7..7`, y `uniform -11..0`) and the nether wart block spread in
`weeping_vines` (§11.6).

### 7.4 `overlay`

Field `features`: a list of placed features. Place each placed feature, in order, at the **same** origin with the same random source (through
the placed-feature pipeline, sibling part 1); the result is true when at least one of them returned true. Every entry runs, there is no early exit.

### 7.5 `replace_single_block`

Field `targets`: a list of `{target: rule test, state}`. At the origin, in list order, the first entry whose rule test accepts the current state
(rule tests need `(state, pos, random)`; sibling part 2) has its `state` set at the origin (flags 2) and the loop ends. Always returns true.
No configured feature in the jar uses it, so no vegetation instance exists (Open question 7).

### 7.6 `projected_random_patchy_square`

Fields: `block` (provider), `project_through` (predicate), `size` (int provider 1..16), `max_projection_height` (non-negative). `place(origin)`:

1. `s = size.sample`; `cap = s*s + 1`.
2. For `dx` in `-s .. s` (outer), `dz` in `-s .. s` (inner): `w = |dx| * |dz|`; draw `nextInt(cap)` (a draw for **every** cell); proceed only
   when the value is `< cap - w` (so cells far from both axes are less likely: the corner cell `(±s, ±s)` has weight `w = s*s` and survives with
   probability `1/(s*s+1)`).
3. Project: `cursor = origin + (dx, 0, dz)`, `k = max_projection_height`. While `project_through.test(level, cursor + down)`: move down, decrement `k`, stop
   when `k <= 0`. (The test looks at the cell below.)
4. `state = block.getOptionalState(level, random, cursor)`; when present set it at `cursor` (flags 2).
5. Return true.

It appears only in `basalt_pillar` (`size 3`, `max_projection_height 3`, `project_through` air, offset `(0,-1,0)`), which uses a `rule_based` provider.

## 8. `multiface_growth` (glow lichen, sculk veins)

Fields: `block` (must be a `MultifaceSpreadeableBlock`, else the codec rejects it), `search_range` (1..64, default 10),
`can_place_on_floor`, `can_place_on_ceiling`, `can_place_on_wall` (bools, default false), `chance_of_spreading` (0..1, default 0.5),
`can_be_placed_on` (a block set).

### 8.1 Block-level pieces the feature calls

| Piece | Rule (read from `MultifaceBlock`, `MultifaceSpreader`) |
|---|---|
| `canAttachTo(level, dir, pos, state)` | `state.getBlockSupportShape(level, pos)` has a full face toward `opposite(dir)`, **or** `state.getCollisionShape(level, pos)` has a full face toward `opposite(dir)` |
| `hasFace(state, dir)` | the state's face property for `dir` is true (absent counts as false) |
| `isValidStateForPlacement(level, state, pos, dir)` | false when the block does not support face `dir` at all, or when `state` is already this block with `hasFace(state, dir)`; otherwise `canAttachTo(level, dir, pos + dir, state at pos + dir)` |
| `getStateForPlacement(state, level, pos, dir)` | `null` when not valid; else the base state: `state` itself if it already is this block, else the default state with `waterlogged = true` when the cell holds a water **source** and with `waterlogged` at its default otherwise; result = base with the face property of `dir` set true |
| `validDirections` (feature) | UP when `can_place_on_ceiling`, then DOWN when `can_place_on_floor`, then NORTH, EAST, SOUTH, WEST when `can_place_on_wall` |
| `isAirOrWater(state)` | air, or the block `minecraft:water` |

Spreader (`MultifaceSpreader`) with the default config of the block:

| Term | Rule |
|---|---|
| spread types, in order | `SAME_POSITION`: `(pos, dir)`; `SAME_PLANE`: `(pos + dir, face)`; `WRAP_AROUND`: `(pos + dir + face, opposite(dir))`, where `face` is the source face and `dir` the spread direction |
| `canSpreadFrom(state, face)` | `hasFace(state, face)` (the default config treats no other block as a valid source) |
| `canSpreadInto(level, source, spreadPos)` | the state at `spreadPos.pos` is air, or this block, or a water source block; **and** `isValidStateForPlacement` holds for that state at `spreadPos.pos` and `spreadPos.face` |
| `placeBlock` | `getStateForPlacement` for the target; if non-null, mark the position for post-processing (when asked) and `setBlock(pos, newState, 2)`; success iff non-null |
| `getSpreadFromFaceTowardDirection(state, level, pos, face, dir)` | empty when `dir` and `face` are on the same axis; empty when `hasFace(state, face)` is false or `hasFace(state, dir)` is true; else the first type in order whose spread position satisfies `canSpreadInto` |
| `spreadFromFaceTowardRandomDirection(state, level, pos, face, random, postProcess)` | `Direction.allShuffled(random)` (a shuffle of the six, draws); for each direction in that order try `getSpreadFromFaceTowardDirection` and then `placeBlock`; the first success ends the search (a direction that yields a position whose placement fails is skipped and the search continues) |

### 8.2 The feature

`place(origin)`:

1. If the state at the origin is not air or water: return false. If `block` is not a spreadable multiface block: return false.
2. `dirs =` shuffled copy of `validDirections` (draws).
3. `placeGrowthIfPossible(origin, state at origin, dirs)`; if it returns true: return true.
4. For each `d` in `dirs`: `dirs2 =` the `validDirections` without `opposite(d)`, shuffled (draws, one shuffle per `d`);
   repeat `search_range` times: `cursor = origin + d` (**reset every iteration, not accumulated**; Open question 3), `s =` state at `cursor`; if `s` is not air,
   not water and not `block`, leave the repetition; else if `placeGrowthIfPossible(cursor, s, dirs2)` return true.
5. Return false.

`placeGrowthIfPossible(pos, state, directions)`: for each `d` in `directions` in order: if the block at `pos + d` is in `can_be_placed_on`:
`new = block.getStateForPlacement(state, level, pos, d)`; **if `new` is null return false** (the whole call, not just this direction);
otherwise `setBlockAndUpdate(pos, new)`, mark `pos` for post-processing, draw `nextFloat()`, and when `value < chance_of_spreading`
run `spreadFromFaceTowardRandomDirection(new, level, pos, d, random, postProcess = true)`; return true. If no direction matched return false.

Consequence (inferred from step 4): because `cursor` is recomputed from the origin each pass, the `search_range` repetitions all test the same cell with the same `dirs2`;
a second pass can change nothing, so the effective search is "the six cells next to the origin in `dirs` order".
Jar data: `glow_lichen` (`search_range 20`, floor false, ceiling and wall true, spreading 0.5, placed on stone, andesite, diorite, granite, dripstone block,
calcite, tuff, deepslate, sulfur, cinnabar) with a placed feature `count uniform 104..157`, `height_range 0..256`, `in_square`,
`surface_relative_threshold_filter OCEAN_FLOOR_WG max -13`; `sculk_vein` (all three placements, `chance_of_spreading 1.0`, `search_range 20`).

## 9. `vegetation_patch` and `waterlogged_vegetation_patch`

Fields (read from the codec): `replaceable` (block set), `ground_state` (provider), `vegetation_feature` (placed feature), `surface`
(`floor` or `ceiling`: direction DOWN or UP, id strings `floor` and `ceiling`), `depth` (int provider 1..128), `extra_bottom_block_chance` (0..1),
`vertical_range` (1..256), `vegetation_chance` (0..1), `xz_radius` (int provider), `extra_edge_column_chance` (0..1). Write `D` for the surface direction
(DOWN for `floor`) and `O = opposite(D)`.

`place(origin)`:

1. `rx = xz_radius.sample + 1`, then `rz = xz_radius.sample + 1` (two draws, in that order).
2. `ground = placeGroundPatch(...)` (§9.1); then `distributeVegetation(ground)` (§9.2). Return true iff `ground` is not empty.

### 9.1 Ground patch

For `dx` in `-rx .. rx` (outer), `dz` in `-rz .. rz` (inner):

1. `edgeX = (|dx| == rx)`, `edgeZ = (|dz| == rz)`. Corners (both) are skipped. A column on exactly one edge draws `nextFloat()` when
   `extra_edge_column_chance != 0` and is skipped when the value is `> extra_edge_column_chance` (so it survives when `<=`); when the chance is 0 it is skipped without a draw.
   Interior columns are always processed.
2. `cursor = origin + (dx, 0, dz)`. Move along `D` while the cell is air, at most `vertical_range` steps; then move along `O` while the cell is not air, at most `vertical_range` steps
   (the first pass finds the surface, the second steps back to the first air cell above the surface for `floor`).
3. `below = cursor + D`. The column is skipped unless `cursor` is air and `below`'s state has a **sturdy** face toward `O`.
4. `layers = depth.sample`, plus 1 when `extra_bottom_block_chance > 0` and a drawn `nextFloat() < extra_bottom_block_chance` (the depth draw first;
   no second draw when the chance is 0).
5. `placeGround(below, layers)`: for `i` in `0 .. layers-1` at a cursor that starts at `below`: `g = ground_state.getState(level, random, cursor)`, `cur =` the state there.
   If `g` has the same block as `cur`: this layer is skipped **and the cursor does not move**. Else if `cur` is not in `replaceable`: stop; the column counts as
   placed iff `i > 0`. Else set `g` (flags 2) and move the cursor along `D`. If the loop ends the column counts as placed.
6. When the column counts as placed, add the position `below` (the first ground block) to the result set.

The result is a `HashSet<BlockPos>`; the next step iterates it (Open question 1: the iteration order decides which positions get which draws).

### 9.2 Vegetation

For each ground position `g` in set iteration order: if `vegetation_chance > 0` draw `nextFloat()` and when `value < vegetation_chance` place the vegetation placed feature at `g + O`
(for floor: the air cell above the ground block). No other draw happens in this step.

### 9.3 Waterlogged variant

`waterlogged_vegetation_patch` computes the ground set with step 9.1 and then keeps only the **unexposed** positions: a ground position is *exposed* when,
for some `d` in NORTH, EAST, SOUTH, WEST, DOWN, the neighbour `g + d` has no sturdy face toward `opposite(d)` (the check reads the world; the set argument is not used).
Every unexposed position is replaced by the default `minecraft:water` state (flags 2), and the unexposed set is the result handed to the vegetation step. Its vegetation
placement is the vegetation feature of the parent run one cell lower (the placed feature runs at `g`, the former ground block, now water); afterwards, if the
block at `g` has a `waterlogged` property that is false, set it to true (flags 2); the call returns true when the vegetation placed.

Worked example (`moss_patch.json`: floor, `depth 1`, `extra_bottom_block_chance 0`, `extra_edge_column_chance 0.3`, `vegetation_chance 0.8`, `vertical_range 5`,
`xz_radius uniform 4..7`, ground `moss_block`, replaceable `#moss_replaceable`): draws `rx = 5`, `rz = 5` (the samples 4 and 4). The 11 x 11 square has 4 corners
skipped, 36 edge columns that each survive with probability 0.3, 81 interior columns always, so about 81 + 10.8 = 91.8 candidate columns; each column that finds air above a sturdy
floor becomes one moss block (`depth 1`), and each such block gets a vegetation placement with probability 0.8, which places `moss_vegetation` (a weighted `simple_block`:
flowering azalea 4, azalea 7, moss carpet 25, short grass 50, tall grass 10). `minecraft:moss_carpet` is an ordinary carpet block (not the mossy-carpet class, see section 4), so it is placed by the plain `setBlock(origin, state, 2)` path with no side or topper logic and no extra random draws.

## 10. `root_system` (azalea trees)

Fields: `feature` (placed feature, the tree), `required_vertical_space_for_tree` (1..64), `level_test_distance` (0..16), `max_level_deviation` (0..64),
`root_radius` (1..64), `root_replaceable` (block set), `root_state_provider`, `root_placement_attempts` (>= 1), `root_column_max_height` (>= 1),
`hanging_root_radius` (1..64), `hanging_roots_vertical_span` (1..16), `hanging_root_state_provider`, `hanging_root_placement_attempts` (>= 1),
`allowed_vertical_water_for_tree` (1..64), `allowed_tree_position` (predicate). `place(origin)`:

1. If the state at the origin is not air: return false. `cursor = origin`.
2. `placeDirtAndTree` (below); on success `placeRoots`. Return true regardless of the outcome of step 2 once the origin was air.

`placeDirtAndTree(cursor, origin)`: for `i = 0 .. root_column_max_height - 1`: move `cursor` up one; if the world-surface height at `cursor` is lower than `cursor.y` return false;
if `allowed_tree_position` holds at `cursor` **and** `spaceForTree(cursor)` holds: if the fluid below `cursor` is lava or the block below is not solid return false;
otherwise place the tree placed feature at `cursor`; on success run `placeDirt(origin, maxY = origin.y + i)` and return true. If anything failed continue the loop. After the
loop return false. The tree is thus placed at the first position above the origin that passes, and the dirt column fills `origin.y .. origin.y + i - 1`.

`spaceForTree(pos)`: for `i = 1 .. required_vertical_space_for_tree`: the cell `pos + up*i` must be air or (when `i + 1 <= allowed_vertical_water_for_tree`) a cell whose fluid is in
the water tag. Then, when `level_test_distance > 0`, for each of the four horizontal directions: let `c = pos + dir * level_test_distance`; the state at `c - up*max_level_deviation` must not be air and the
state at `c + up*max_level_deviation` must be air. All checks must hold.

`placeDirt(origin, maxY)`: for `y = origin.y .. maxY - 1`, run `placeRootedDirt` in the column `(origin.x, y, origin.z)`.
`placeRootedDirt(x, y, z)`: repeat `root_placement_attempts` times: `q = (x, y, z) + (a1 - a2, 0, b1 - b2)` where the draws are `nextInt(root_radius)`, `nextInt(root_radius)`,
`nextInt(root_radius)`, `nextInt(root_radius)` in that order (`a1`, `a2`, `b1`, `b2`); when the block at `q` is in `root_replaceable`, set `root_state_provider.getState(level, random, q)` (flags 2). (The working position is reset to `(x, y)` after
every attempt, so offsets never accumulate.)

`placeRoots(origin)` (hanging roots, run once after the tree): repeat `hanging_root_placement_attempts` times: `q = origin + (nextInt(r) - nextInt(r), nextInt(v) - nextInt(v), nextInt(r) - nextInt(r))`
with `r = hanging_root_radius`, `v = hanging_roots_vertical_span`, the draws in x, y, z order (each pair first minus second); when `q` is air, `s = hanging_root_state_provider.getState(level, random, q)`,
`s.canSurvive(level, q)` and the cell above `q` has a sturdy DOWN face: set `s` (flags 2).

Jar data (`rooted_azalea_tree.json`): `required_vertical_space_for_tree 3`, `allowed_vertical_water_for_tree 2`, `level_test_distance 0`, `max_level_deviation 0`, `root_radius 3`,
`root_placement_attempts 20`, `root_column_max_height 100`, `hanging_root_radius 3`, `hanging_roots_vertical_span 2`, `hanging_root_placement_attempts 20`, the roots `rooted_dirt` and
`hanging_roots`, allowed position `(air or replaceable_by_trees) at the cell and azalea_grows_on one below`, tree `azalea_tree`.

## 11. Huge mushrooms and huge fungus

### 11.1 Shared mushroom flow (`AbstractHugeMushroomFeature`)

Fields: `cap_provider`, `stem_provider`, `foliage_radius` (int, default 2), `can_place_on` (predicate). `place(origin)`:

1. Height `H = 4 + nextInt(3)`; then draw `nextInt(12)`; when it is 0, `H = H * 2`. So `H` is 4..6, or 8..12 with probability 1/12 (`MIN_MUSHROOM_HEIGHT` is 4).
2. `isValidPosition`: `origin.y >= minY + 1` and `origin.y + H + 1 <= maxY`; `can_place_on` holds at `origin + down`; and for every layer `y` in `0 .. H`, with
   `r = getTreeRadiusForHeight(-1, -1, foliage_radius, y)` (both leading arguments are -1 here; Brown returns 0 for `y <= 3` and `foliage_radius` above that; Red
   returns 0 for every `y` because neither of its conditions can hold with a -1 argument), every cell `origin + (dx, y, dz)` with `|dx|, |dz| <= r` is air or in the block tag `leaves`.
   Any failure returns false before any further draw.
3. `makeCap` (§11.2, §11.3), then `placeTrunk`, then return true.

`placeTrunk`: for `i = 0 .. H-1`: `placeMushroomBlock(origin + up*i, stem_provider.getState(level, random, origin))` (the provider is asked about the **origin**, once per cell).
`placeMushroomBlock(pos, state)` sets `state` (through the feature's default write, flags 3) only when the existing block is air or in the block tag `replaceable_by_mushrooms`.
For caps the same function is used, so caps never overwrite solid blocks.

Both cap builders use `cap_provider.getState(level, random, origin)` per cell and, **only when the state has all of the properties** west, east, north, south
(and up for red), overwrite them as below; otherwise the provider's state is placed as is.

### 11.2 Brown cap (`R = foliage_radius`)

One layer at `y = H`. For `dx` in `-R .. R` (outer), `dz` in `-R .. R` (inner): `xMin = dx == -R`, `xMax = dx == R`, `zMin = dz == -R`, `zMax = dz == R`,
`onX = xMin or xMax`, `onZ = zMin or zMax`. Skip the cell when `onX and onZ` (corners). Else
`west = xMin or (onZ and dx == 1 - R)`, `east = xMax or (onZ and dx == R - 1)`, `north = zMin or (onX and dz == 1 - R)`, `south = zMax or (onX and dz == R - 1)`.
(Brown mushroom blocks have no up/down in this assignment: only the four sides are set.)

### 11.3 Red cap (`R = foliage_radius`)

For `y` from `H - 3` to `H` (four layers): `r = R` when `y < H`, else `R - 1`; `inner = R - 2`. For `dx` in `-r .. r` (outer), `dz` in `-r .. r` (inner): `onX = |dx| == r`,
`onZ = |dz| == r`; when `y < H` skip cells with `onX == onZ` (corners and interior: the lower layers are a hollow ring without corners); the top layer `y == H` is the full square.
Properties: `up = (y >= H - 1)`, `west = dx < -inner`, `east = dx > inner`, `north = dz < -inner`, `south = dz > inner`.

### 11.4 Worked examples

Brown (`huge_brown_mushroom.json`: `foliage_radius 3`), `H = 6`: cap at layer 6 over the 7 x 7 square minus its four corners (45 cells). Cell `(-3, 0)`: `xMin`, so west only. Cell `(-2, -3)`:
`zMin` (`onZ`), `dx == 1 - R = -2`: west and north both true. Cell `(0, 0)`: all four false. Cell `(-3, -2)`: `onX`, `dz == 1 - R`: west and north. Red (default `R = 2`), `H = 5`:
layers `y = 2, 3, 4` have `r = 2` and 12 cells each (the 5 x 5 ring minus corners), `up` true only at `y = 4` (`>= H - 1`); cell `(-2, 0)` has west true, `(-2, -1)` west and north true;
layer `y = 5` has `r = 1` and the full 3 x 3 (9 cells), cell `(0, 0)` has `up` and no side, `(-1, -1)` has `up`, west, north (with `inner = 0`).

### 11.5 `huge_fungus`

Fields: `valid_base_block` (block state; only its block matters), `stem_state`, `hat_state`, `decor_state` (states), `replaceable_blocks` (predicate), `planted` (default false).
`place(origin)`:

1. The block at `origin + down` must equal the `valid_base_block` block; else return false.
2. `H = Mth.nextInt(4, 13)` (draw `nextInt(10)`, range 4..13). Draw `nextInt(12)`; when 0, `H = H * 2`.
3. When not `planted`: return false when `origin.y + H + 1 >= generator.getGenDepth()` (the generation depth of the dimension settings).
4. `thick = not planted and nextFloat() < 0.06` (the draw is made only when not planted).
5. Set `origin` to air with flags 260. Then `placeStem` and `placeHat`; return true.

`isReplaceable(pos, withPredicate)`: true when the state `canBeReplaced()`, else `withPredicate and replaceable_blocks.test(pos)` (false otherwise).

`placeStem(base, H, thick)`: `r = 1` if thick else 0. For `dx` in `-r .. r` (outer), `dz` in `-r .. r`, `corner = thick and |dx| == r and |dz| == r`; for `dy` in `0 .. H-1`:
`p = base + (dx, dy, dz)`; skip unless `isReplaceable(p, true)`. If `planted`: when the cell below `p` is **not** air, destroy the block at `p` (dropping items), then `setBlockAndUpdate(p, stem_state)`.
If not planted: a `corner` cell draws `nextFloat()` and sets the stem only when the value is `< 0.1`; any other cell sets the stem (flags 3).

`placeHat(base, H, thick)`: `wart = hat_state.block == nether_wart_block`. `hatHeight = min(nextInt(1 + H / 3) + 5, H)` (integer division); `bottom = H - hatHeight`. For `y` from `bottom` to `H`:

1. `r = 2` when `y < H - nextInt(3)` (one draw per layer), else `1`. When `hatHeight > 8` and `y < bottom + 4`, `r = 3`. When `thick`, `r = r + 1`.
2. For `dx` in `-r .. r` (outer), `dz` in `-r .. r` (inner): `edgeX = |dx| == r`, `edgeZ = |dz| == r`; `inner = not edgeX and not edgeZ and y != H`; `corner = edgeX and edgeZ`;
   `lowRing = y < bottom + 3`. `p = base + (dx, y, dz)`.
3. Skip unless `isReplaceable(p, false)` (only `canBeReplaced`). If `planted` and the cell below `p` is not air, destroy the block at `p` (with drops).
4. Then exactly one branch of an exclusive chain runs for the cell, and each branch ends the cell (read from the jumps; the branches are not cumulative):
   a. If `lowRing` (`y < bottom + 3`): when `inner` the cell is skipped; otherwise only `placeHatDropBlock(p)` runs, and none of the later branches.
   b. Else if `inner`: only `placeHatBlock(p, decor 0.1, hat 0.2, vine wart ? 0.1 : 0)`.
   c. Else if `corner`: only `placeHatBlock(p, 0.01, 0.7, wart ? 0.083 : 0)`.
   d. Otherwise: `placeHatBlock(p, 0.0005, 0.98, wart ? 0.07 : 0)`.

`placeHatBlock(p, cDecor, cHat, cVine)`: draw `nextFloat()`; when `< cDecor` set `decor_state` at `p` and stop (no hat draw, no vine draw). Otherwise draw `nextFloat()` again; when `< cHat` set `hat_state` at `p` and then draw a third `nextFloat()`;
when `< cVine` run `tryPlaceWeepingVines(p)`. So the call makes 1 draw when the decor wins, 2 draws when the hat misses and 3 draws when the hat is placed; the decor and hat are alternatives, a hat never overwrites a decor.
`placeHatDropBlock(p)`: an either/or. When the block at `p.below` is the hat block, set `hat_state` at `p` and stop (no 0.15 draw, no `nextInt(11)`). Only when it is not the hat block, draw `nextFloat()` (compared as a double): when `< 0.15` set `hat_state` at `p` and, when `wart`, draw `nextInt(11)` and
on 0 run `tryPlaceWeepingVines(p)`. All sets here use `setBlockAndUpdate` (flags 3).

`tryPlaceWeepingVines(p)`: `start = p + down`; require it to be air. `L = Mth.nextInt(1, 5)` (draw `nextInt(5)`, so 1..5); draw `nextInt(7)`, when 0, `L = L * 2`. Column: for `i = 0 .. L` (inclusive), `cursor` starting at `start` and moving down once per
step **whether or not it was empty**: when the cell is air: if `i == L` or the cell below is not air, set `weeping_vines` (head) with `age = Mth.nextInt(23, 25)` (draw `nextInt(3) + 23`, flags 2) and stop; otherwise set `weeping_vines_plant` (flags 2). A non-air cell is skipped
without stopping. A column over air thus has `L` plant cells and a head, `L + 1` blocks.

Jar data: `crimson_fungus` (`valid_base_block crimson_nylium`, `stem crimson_stem`, `hat nether_wart_block`, `decor shroomlight`, `planted false`), `warped_fungus` (`warped_nylium`, `warped_stem`, `warped_wart_block`, `shroomlight`), the `_planted` forms with `planted true`;
`replaceable_blocks` is a long `matching_blocks` list of saplings, flowers, crops, mushrooms, vines and similar plants (data; the extraction tool copies it).

### 11.6 Nether vegetation as composed in the data

No Nether-specific code exists beyond `huge_fungus` and the weeping-vine helpers above; the plants are `simple_block`s and placement chains:

- `crimson_forest_vegetation` and `warped_forest_vegetation`: `simple_block` with a `weighted` provider (crimson: roots 87, crimson fungus 11, warped fungus 1; warped: warped roots 85, crimson roots 1, warped fungus 13, crimson fungus 1;
  the fungus entries are the saplings-like `minecraft:crimson_fungus`/`warped_fungus` blocks, not the huge feature). Placement: `count_on_every_layer 6` (5 for warped), `biome`, `block_predicate_filter(nylium below)`, then the patch idiom of §2 (`count 64`, trapezoid `-7..7`/`-3..3`, filter air).
- `patch_crimson_roots` (and the other root patches): `height_range`, `biome`, `count 96`, offset, air filter (the patch idiom).
- `nether_sprouts`: `count_on_every_layer 4`, `biome`, nylium below, `count 64`, offset, air.
- `weeping_vines`: an `overlay` of (a) `random_neighbor_spread` of `nether_wart_block` (accepts netherrack or nether wart block, `attempts 200`, xz trapezoid `-5..5`, y trapezoid `-4..1 plateau 3`, replaces air), with no placement list, and (b) a `block_column`
  (direction down, `prioritize_tip true`, plant layer of `weighted_list` heights `uniform 1..8` weight 10, `uniform 2..17` weight 2, constant 1 weight 3, then one head with `age uniform 17..25`) placed `count 100`, offset (x and z trapezoid `-7..7`, y trapezoid `-4..1 plateau 3`) and a filter
  `air at the cell and netherrack or wart block above`. The overlay runs (a) then (b) at the same origin and random (§7.4). The outer placed feature: `count 10`, `in_square`, `height_range` (whole column), `biome`, filter (air with netherrack or wart block above).
- `twisting_vines`: a `block_column` (direction up, tip priority, heights `uniform 0..7` weight 10, `uniform 1..15` weight 2, constant 0 weight 3; head age `uniform 17..25`) with the placement list, as read from `placed_feature/twisting_vines`: (1) `count 10`; (2) `in_square`; (3) `height_range` uniform from above-bottom 0 to below-top 0; (4) `biome`; (5) filter: air at the cell and netherrack, warped nylium or warped wart block below; (6) `count 64`; (7) `offset` with x uniform -8..8, y uniform -4..4, z uniform -8..8; (8) `offset (0, -1, 0)`; (9) `environment_scan` (direction down, `max_steps 32`, target condition "not air"); (10) `offset (0, 1, 0)`; (11) the same filter as (5). Modifier semantics are in sibling part 1.

## 12. Validation

An implementation is conformant to this document when the following checks hold.

1. Registry facts: eleven tree decorator types in the order of §3.1; the `FeatureTypes` registry has 58 entries and none named `random_patch`, `flower` or `vegetation`; 240 configured and 273 placed feature files in the jar.
2. Draw-order unit tests (each with a scripted random source that records the calls): `trunk_vine` draws four `nextInt(3)` per log; `leave_vine` four `nextFloat` per leaf; `cocoa` draws one `nextFloat` before inspecting logs and, per log within 2 layers of the lowest, four
   `nextFloat` plus one `nextInt(3)` per placed pod; `beehive` with empty logs draws nothing and with a leaf-bearing tree draws `nextFloat`, then the shuffle, then 1 + n `nextInt` calls for the occupants (n = 2 or 3 after one `nextInt(2)`).
3. `block_column` truncation table: heights `[7, 1]`, `total 8`: `kept 5` gives `[4, 1]` and `kept 7` gives `[6, 1]` with `prioritize_tip true`; `kept 5` gives `[5, 0]` with `prioritize_tip false`; heights `[0, 1]` with `kept 0` give `[0, 0]`.
4. `TrapezoidInt`: `(-7, 7, 0)` consumes exactly two `nextInt(8)` calls; `(-4, 1, 3)` consumes `nextInt(5)` then `nextInt(2)`; the result range of each is the declared range.
5. `bamboo`: with `n = 5` the three-cell crown rule (`cursor.y - origin.y >= 3`) places `FINAL_LARGE` at `+5`, `TOP_LARGE` at `+4`, `TOP_SMALL` at `+3`; with a blocked cell at `+2` (stalk of 2 cells) no crown is placed.
6. `vegetation_patch` with `rx = rz = 2`, `extra_edge_column_chance 1.0`, `depth 1`, flat floor: 21 columns (25 minus 4 corners) get ground, in the order `dx` outer, `dz` inner; with chance 0.0: 9.
7. Huge mushrooms: for `H = 6`, `R = 3` the brown cap has 45 blocks; for `H = 5`, `R = 2` the red cap has `3 * 12 + 9 = 45` cap blocks; a stalk of `H` cells; validity check passes on air but fails when a cell inside the radius at layer `y > 3` (brown) is stone.
8. `huge_fungus` over `planted = false`: `H` is in 4..13 or doubled; the hat of `H = 8` has `hatHeight` in 5..8 and never exceeds `H`.
9. Multiface: from an origin in air next to stone on its `down` side with `can_place_on_floor` only, the first call sets exactly one face (`down`) and a spreading draw follows; `getStateForPlacement` returns null when the face already exists.
10. Cross-check with the vanilla client (R8): none of these features changes a registry or a chunk encoding; a reference client accepts the resulting chunks when the blocks and states used exist in its registry.

## Open questions

1. **Hash-set order.** The tree sets (roots, logs, leaves, decoration) and the vegetation-patch ground set are `HashSet<BlockPos>`s, and several draws depend on iteration order (ties of equal Y in the sorted tree lists; the order in which patch ground positions receive their vegetation
   draw). `BlockPos.hashCode()` is read and matched against the jar: `(y + z * 31) * 31 + x` in 32-bit arithmetic. `Context.getLowestTrunkOrRootOfTree` and the Context constructor (three sorted `ObjectArrayList`s) were also matched against 3.1. The remaining part is the behaviour of Java's `HashSet` (bucket index `(h ^ (h >>> 16)) & (n - 1)`, initial table 16, load factor 0.75, resize doubling, iteration by bucket then insertion order) which is **(recalled, not verified)**, not read from this artifact.
   An implementation that iterates in another order produces vanilla-like but not seed-identical trees and patches.
2. **`block_column` test cursor.** The bytecode starts the allowed-placement test one cell beyond the origin (and writes from the origin). This differs from the origin-based test recalled from older versions. It is written as read; no cell at the origin is ever tested by this feature (the placed feature filters of the data test the origin).
3. **`multiface_growth` search range.** The search cursor is recomputed as `origin + d` on every repetition, so `search_range` has no effect (§8.2). Written as read; recorded here because it contradicts the field's apparent purpose.
4. **`attached_to_logs` and `cocoa` use `<=`, `attached_to_leaves`, `leave_vine`, `pale_moss` and the shelf mushroom top-level test use `<` / `>=`** as listed in each section; all read from the compare instructions. A boundary equal to the probability cannot occur for `nextFloat() <= p` with p 0 or 1 except at the exact float value, so the difference only shows in seed-exact tests.
5. **Clockwise order.** Closed: `getClockWise` was matched case by case (see 1.1) and `Direction.Plane.HORIZONTAL` is NORTH, EAST, SOUTH, WEST.
6. **`single_block_pillar` and `projected_random_patchy_square`.** Their only user is `basalt_pillar` (Nether, sibling part 7); the `rule_based` provider and the nested overlay there are data and provider topics (sibling part 2).
7. **`replace_single_block`.** The engine is specified (§7.5) but no configured feature in the jar uses it; its `RuleTest` forms belong to sibling part 2.
8. **`copyWaterloggedFrom`.** Closed: read, the rule is in section 4 (`isWaterAt` for the cell when the state has `waterlogged`).
9. **Pale moss carpet topper.** The final `return` conditions of `createTopperWithSideChance` were read from a listing without the branch targets for two jumps; §4's description of "kept only if it has any side and differs from the state above" is partly inferred. The block rules of the pale moss carpet belong to the block-registry documents.
10. **Int providers.** `ConstantInt` drawing nothing, the `weighted_list` and `biased_to_bottom` providers and the `uniform` provider's draw (assumed `nextIntBetweenInclusive`) are in sibling part 2 and were not re-read here. `getOptionalState` versus `getState` semantics of the block state providers likewise.
11. **`MossyCarpetBlock` identity.** Closed: in `Blocks`, `minecraft:moss_carpet` is built with the ordinary `CarpetBlock` constructor and only `minecraft:pale_moss_carpet` with `MossyCarpetBlock`; `moss_vegetation` therefore places `moss_carpet` through plain `setBlock(origin, state, 2)` with no side or topper logic and no extra random draws (section 9).
12. **Beehive block entity.** The occupant record created with `Occupant.create(ticks)` has default entity data; its NBT form belongs to the block-entity round (RS13), not here.
13. **`getGenDepth`.** `huge_fungus` compares against `ChunkGenerator.getGenDepth()`; the value per dimension comes from the noise settings (384 for the overworld in the data of 10 §5; Nether value in part 7 / 37) and was not re-read here.
14. **Placed-feature entry for the pale-moss ground patch.** `pale_moss` looks the patch feature up by registry key at run time and silently does nothing when it is absent; the key's resolution happens through the data pack and is covered by the registry loader (23).
