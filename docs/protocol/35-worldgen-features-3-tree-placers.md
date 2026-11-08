# 35 World generation features, part 3: the tree feature and its placers

| Item | Value |
|---|---|
| Covers | `TreeFeature` (place pipeline, height and bounds checks, feature-size clipping rule, root origin, trunk then foliage then decorators ordering, leaf distance update, shape update step), `FallenTreeFeature`, the 10 trunk placers, the 12 foliage placers and their shared helpers, the mangrove root placer and the above-root placement, and the 2 feature sizes. |
| Does not cover | Tree decorators (35 p4 §3), block predicates and state providers (35 p2 §3 and §4), the feature and placement-modifier framework (35 p1), `CoralTreeFeature` and `CoralClawFeature` (35 p5 §14.1; they are feature classes of the same package but not trees in this sense), configured and placed feature rows (DATA, extracted by the tool, 22). `IntProvider` semantics beyond the draws used here. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, `javap -v` for one bootstrap method) and of `data/minecraft/worldgen/feature/*.json` for examples and counts only, with no execution. Worked examples marked "(computed)" apply this document's rules by hand; they were not observed. |
| Round | RS19 (GAP-12a), scope "Part 3" |

Cross-references to the sibling parts use "35 pN §x", N being the part number of `35-worldgen-features-N-*.md` (p1 model and placement, p2 predicates and providers, p4 decorators and vegetation, p5 water and surface); "NN §x" is any other numbered document. Class names in backticks say where a fact was read. "(inferred)" marks a deduction (none remain in sections 5.1 and 6.1) and "(recalled, not verified)" a
statement not read; both are listed in the Open questions. Random numbers: every `nextInt(n)`, `nextBoolean()`,
`nextFloat()` is a draw from the feature's random source (10 §2.1 for the primitives, 11 §4 and §6 for the
`WorldgenRandom` that decoration uses and how it is seeded). **Draw order is part of the result**; every algorithm below
lists draws in the order they happen. "Float" is single precision. `Direction` ordinals are DOWN 0, UP 1, NORTH 2,
SOUTH 3, WEST 4, EAST 5; steps are NORTH z-1, SOUTH z+1, WEST x-1, EAST x+1. `Direction.Plane.HORIZONTAL` is the array
[NORTH, EAST, SOUTH, WEST]; `getRandomDirection(r)` = `array[r.nextInt(4)]`.

## 1. Shared helpers

| Helper | Meaning (read) |
|---|---|
| `validTreePos(p)` | state at `p` is air, or in block tag `replaceable_by_trees` |
| `isAirOrLeaves(p)` | air or tag `leaves` |
| `isVine(p)` | block is `vine` |
| `TrunkPlacer.isFree(p)` | `validTreePos(p)` or state in tag `logs`. `validTreePos` is virtual: the upwards-branching placer overrides it (4.8) and `isFree` and `placeLog` use the override |
| `placeLog(p, f)` | if `validTreePos(p)`: `state = trunk_provider.getState(level, r, p)` (one provider draw, 35 p2 §4), apply optional state modifier `f`, hand `(p, state)` to the **trunk setter**, return true; else return false and draw nothing |
| `placeLogIfFree(p)` | if `isFree(p)` then `placeLog(p)` (so `validTreePos` is tested twice) |
| `placeBelowTrunkBlock(p)` | `s = below_trunk_provider.getOptionalState(level, r, p)`; if non-null hand `(p, s)` to the trunk setter. The only caller of `getOptionalState` in this document (35 p2 §4); the data uses the `soil_beneath_tree` provider |
| sideways modifier(d) | `state.trySetValue(axis, d.getAxis())` (no-op for states without `axis`) |
| `getTreeHeight(r)` | `base_height + r.nextInt(height_rand_a + 1) + r.nextInt(height_rand_b + 1)` (both draws always happen, even for bound 1) |
| waterlogged(p, s) (roots, leaves) | if `s` has `waterlogged`, set it to whether the fluid at `p` is in fluid tag `water` (roots) or is a water source (leaves, 5.1); else `s` |

Trunk placer codec common fields: `base_height` 0..32, `height_rand_a` 0..24, `height_rand_b` 0..24 (static field `TrunkPlacer.MAX_HEIGHT = 80`, read in the class; beside `MAX_BASE_HEIGHT = 32` and `MAX_RAND = 24`, which are the codec maxima above. Which code consumes `MAX_HEIGHT` was not traced, Open question 9).
Registered type names (registry order): trunk `straight_trunk_placer`, `forking_trunk_placer`, `giant_trunk_placer`,
`mega_jungle_trunk_placer`, `dark_oak_trunk_placer`, `fancy_trunk_placer`, `bending_trunk_placer`,
`upwards_branching_trunk_placer`, `cherry_trunk_placer`, `poplar_trunk_placer`; foliage `blob_foliage_placer`,
`spruce_foliage_placer`, `pine_foliage_placer`, `acacia_foliage_placer`, `bush_foliage_placer`, `fancy_foliage_placer`,
`jungle_foliage_placer` (class `MegaJungleFoliagePlacer`), `mega_pine_foliage_placer`, `dark_oak_foliage_placer`,
`random_spread_foliage_placer`, `cherry_foliage_placer`, `poplar_foliage_placer`; root `mangrove_root_placer`; sizes
`two_layers_feature_size`, `three_layers_feature_size`.

### 1.1 FoliageAttachment

A trunk placer returns a list of attachments, each a record `(pos, radiusOffsetXZ, foliageHeightOffset, sizeX, sizeZ)`.
The constructor `(pos, radiusOffset, doubleTrunk)` stores `foliageHeightOffset = 0` and `sizeX = sizeZ = 2` when
`doubleTrunk` else 1. `doubleTrunk()` is `sizeX == 2 and sizeZ == 2`. No placer in this document builds any other size;
`foliageHeightOffset` is always 0 here.

## 2. TreeFeature

Codec (`TreeFeature` is a record): `trunk_provider`, `trunk_placer`, `foliage_provider`, `foliage_placer`, optional
`root_placer`, `minimum_size`, `decorators` (list), `ignore_vines` (default false), `below_trunk_provider` (required).
Provider fields are state providers (35 p2 §4); Holder wrappers are resolved by 23.

### 2.1 place

Four position sets are kept (hash sets): **roots**, **logs**, **foliage**, **decorations**. Their setters add the position
to the set and call `setBlock(pos, state, 19)` (flags 1 + 2 + 16: update neighbours, send, skip shape updates, 29 §2).
The foliage setter also offers `isSet(pos)` (membership in the foliage set).

1. `doPlace` (2.2) with the trunk setter feeding **logs**, the root setter feeding **roots**, the foliage setter. If it returns false, return false.
2. If **logs** and **foliage** are both empty, return false (roots alone do not count).
3. If `decorators` is not empty: build a decorator context `(level, decoration setter, random, logs, foliage, roots)` and call each decorator's `place(context)` in list order, same random source (35 p4 §3). The decoration setter feeds **decorations**, flags 19.
4. Bounding box `B` = smallest box containing every position of roots, logs, foliage and decorations.
5. Leaf update (2.4), then shape-edge update (2.5) with flags 3, return true.

### 2.2 doPlace (origin `pos`)

1. `H = trunk_placer.getTreeHeight(r)` (two draws).
2. `FH = foliage_placer.foliageHeight(r, H, config)` (draws only where section 5 says).
3. `leafRadius = foliage_placer.foliageRadius(r, H - FH)` = `radius.sample(r)`; pine overrides (5.3).
4. `rootOrigin` = with a root placer `pos.above(trunk_offset_y.sample(r))`, else `pos`.
5. `minY = min(pos.y, rootOrigin.y)`, `maxY = max(pos.y, rootOrigin.y) + H + 1`. If `minY < level.minY + 1` or `maxY > level.maxY + 1` return false (`level.maxY` is the top block index).
6. `free = getMaxFreeTreeHeight(H, rootOrigin)` (2.3). If `free < H` and (`min_clipped_height` absent or `free < min_clipped_height`) return false.
7. With a root placer: `placeRoots(level, rootSetter, r, pos, rootOrigin, config)`; false aborts. Roots draw **before** the trunk.
8. `attachments = trunk_placer.placeTrunk(level, trunkSetter, r, free, rootOrigin, config)` (the trunk gets the clipped height `free`).
9. For each attachment in list order: `foliage_placer.createFoliage(level, foliageSetter, r, config, free, attachment, FH, leafRadius)`; this draws `off = offset.sample(r)` once per attachment before any row. Return true.

Ordering: height draws, foliage height and radius, root origin, roots, trunk (with below-trunk block), foliage per
attachment, decorators, leaf distances, shape updates.

### 2.3 getMaxFreeTreeHeight(H, o)

For `y = 0 .. H + 1` inclusive: `s = minimum_size.getSizeAtHeight(H, y)`; for `dx = -s .. s`, `dz = -s .. s` (x outer): `p = o + (dx, y, dz)`; if `not trunk_placer.isFree(p)`, or (`ignore_vines` false and `p` is a vine), return `y - 2`. Otherwise return `H`.

### 2.4 Leaf distance update

Inputs: box `B`, the logs, decorations and roots sets. Seven layers `L0..L6` of position sets; a voxel shape `S` the size of `B`.

1. Every decoration and root position inside `B` is marked full in `S`.
2. `L0` gets all logs. Cursor `i = 0`.
3. Loop: while `i < 7` and `L[i]` is empty, `i += 1`; stop when `i >= 7`. Remove one element `p` of `L[i]` (set order unspecified). If `p` is outside `B`, continue. If `i != 0`, set the block at `p` to its state with `distance = i` (flags 19). Mark `p` full. For each direction in `Direction.values()` order, `n = p + d`: skip if outside `B` or already full; `dist = getOptionalDistanceAt(state(n))` (a block in tag `prevents_nearby_leaf_decay` gives 0; a state with a `distance` property gives it; otherwise none and the neighbour is skipped); `nd = min(dist, i + 1)`; if `nd < 7`: add `n` to `L[nd]` and `i = min(i, nd)`.

Container and order assumption. The layers `L0..L6` and the four position sets are `java.util.HashSet` instances (created with Guava `Sets.newHashSet`, read); the pop is "take the iterator's first element, then remove it" (read). `BlockPos` hashes as `((y + z * 31) * 31 + x)` in 32-bit signed arithmetic (read in `Vec3i.hashCode`; `BlockPos` does not override it). The iteration order of a `HashSet` is a JDK behaviour and the JDK is not in the artifact: for a bit-exact reproduction assume the usual open-hashing table (recalled, not verified): table size a power of two starting at 16 and doubling when the count exceeds three quarters of it, bucket index `(h ^ (h >>> 16)) & (size - 1)`, buckets visited in index order, elements of one bucket in insertion order. (Inferred) the written distances are in practice independent of the order inside one layer, because a position popped from layer `i` can only enqueue neighbours at `i + 1` or higher and a neighbour already written is full and skipped; the final value of a doubly queued leaf is the highest layer it was queued in. An implementation that does not reproduce hash order should therefore give the same distances in ordinary trees; a ticket may accept any residual difference, since the tick of 2.5 recomputes distances.

Observation read from the bytecode: a popped position is not re-checked for being full, so a leaf queued in two layers can be written twice, the later (higher) layer overwriting the lower; set iteration order could in principle change stored distances (see the assumption above). The scheduled leaf tick (2.5) repairs them. A freshly placed leaf has `distance 7, persistent false, waterlogged false` (`LeavesBlock` default state).

### 2.5 Shape update at the edge

Re-traced in this round (`StructureTemplate.updateShapeAtEdge`, `DiscreteVoxelShape.forAllFaces` and `forAllAxisFaces`, `AxisCycle` and its three constants, the edge lambda). Result: **confirmed**, with one precision about how the passes are built.

`StructureTemplate.updateShapeAtEdge(level, 3, S, B.min)` calls `S.forAllFaces(consumer)`, which runs three passes in this order: `AxisCycle.NONE`, `FORWARD`, `BACKWARD`. Each pass scans lines of cells; the line length is the shape size along the pass axis and the line index runs `k = 0 .. size` **inclusive**, the cell at `k = size` counting as empty and the cell before `k = 0` counting as empty. A step is judged by comparing the previous cell on the line with the current one:

| Pass | Cycle | Outer index | Middle index | Line runs along | Negative / positive direction |
|---|---|---|---|---|---|
| 1 | NONE | x | y | z | NORTH / SOUTH |
| 2 | FORWARD | z | x | y | DOWN / UP |
| 3 | BACKWARD | y | z | x | WEST / EAST |

(The table follows from `AxisCycle`: the cycle applied to the loop indices `(i, j, k)` is the identity for NONE, maps `(x, y, z)` to `(j, k, i)` for the inverse of FORWARD, and to `(k, i, j)` for the inverse of BACKWARD; the face axis is the inverse cycle applied to Z.) Rules on a line: previous empty and current full at `k`: report cell `k` with the negative direction; previous full and current empty at `k`: report cell `k - 1` with the positive direction. The first report of a pass appears before the second of the same line, lines in outer-then-middle order.

For a reported face `(p, d)` (`p` = box origin + cell), `n = p + d`: `s = state(p)`, `ns = state(n)`; `s' = s.updateShape(level, level, p, d, n, ns, random)` (the level is both reader and scheduled-tick access, the random is the level's); if `s' != s`, `setBlock(p, s', 3 & ~1 = 2)`; then `ns' = ns.updateShape(level, level, n, d.opposite, p, s', random)` (receiving the already updated `s'`); if `ns' != ns`, `setBlock(n, ns', 2)`. A leaf's `updateShape` only schedules a 1-tick tick (unless neighbour distance + 1 equals 1 and its stored distance is already 1; waterlogged leaves also schedule a water tick); `LeavesBlock.tick` sets `distance = min over the 6 neighbours of (getDistanceAt + 1)`, non-leaf neighbours counting 7, stopping at 1 (29, 33 §2.4).

Timing of those ticks (read): during generation the level is a `WorldGenRegion`, whose block and fluid tick accessors (`WorldGenTickAccess`) forward `schedule` to the tick container of the chunk that owns the position (`ChunkAccess.getBlockTicks` and `getFluidTicks`). So the tick is stored with the chunk and not run inside the generation step. That it runs when the chunk is first ticked after loading is (inferred); the ticking code was not traced.

## 3. Feature sizes

| Type | Codec (defaults) | `getSizeAtHeight(H, y)` |
|---|---|---|
| `two_layers_feature_size` | `limit` 0..81 (1), `lower_size` 0..16 (0), `upper_size` 0..16 (1) | `lower_size` if `y < limit` else `upper_size` |
| `three_layers_feature_size` | `limit` 0..80 (1), `upper_limit` 0..80 (1), `lower_size` 0..16 (0), `middle_size` 0..16 (1), `upper_size` 0..16 (1) | `lower_size` if `y < limit`; else `upper_size` if `y >= H - upper_limit`; else `middle_size` |

Both take an optional `min_clipped_height` (0..80), absent by default.

## 4. Trunk placers

`H` is the height passed in (2.2 step 8), `o` the root origin. `placeLog` failures are ignored unless stated.

### 4.1 straight_trunk_placer

`placeBelowTrunkBlock(o.below())`; for `i = 0..H-1`: `placeLog(o.above(i))`. One attachment `(o.above(H), 0, false)`. No draws.

### 4.2 forking_trunk_placer

1. `placeBelowTrunkBlock(o.below())`. `dir = getRandomDirection(r)`; `lean = H - nextInt(4) - 1`; `steps = 3 - nextInt(3)` (this order).
2. `(x, z) = (o.x, o.z)`, `top` none. For `i = 0..H-1`: `y = o.y + i`; if `i >= lean` and `steps > 0`: `x += dir.stepX`, `z += dir.stepZ`, `steps -= 1`. `placeLog((x,y,z))`; if placed `top = y + 1`.
3. If `top` set add `((x, top, z), 1, false)`.
4. Reset `(x, z)` to the origin. `dir2 = getRandomDirection(r)`. If `dir2 != dir`: `j0 = lean - nextInt(2) - 1`, `len = 1 + nextInt(3)`, `top` none; for `j = j0; j < H and len > 0; j += 1, len -= 1`: if `j < 1` skip the body (counters still advance); else `y = o.y + j`, `x += dir2.stepX`, `z += dir2.stepZ`, `placeLog((x,y,z))`, if placed `top = y + 1`. If `top` set add `((x, top, z), 0, false)`.

### 4.3 giant_trunk_placer (2x2)

`placeBelowTrunkBlock` at `o.below()`, its east, its south, its south-east (this order). For `i = 0..H-1`: `placeLogIfFree(o + (0,i,0))`; if `i < H - 1`: `placeLogIfFree(o + (1,i,0))`, `(1,i,1)`, `(0,i,1)`. Attachment `(o.above(H), 0, true)`. No draws.

### 4.4 mega_jungle_trunk_placer

1. The giant trunk (4.3); its attachment is first in the list.
2. `y = H - 2 - nextInt(4)`. While `y > H / 2` (integer division): `a = nextFloat() * 6.2831855f`; for `k = 0..4`: `ix = (int)(1.5f + cos(a) * k)`, `iz = (int)(1.5f + sin(a) * k)` (`Mth.cos`/`Mth.sin` of `(double)a`, table based, 11 §4; float multiply and add; `(int)` truncates toward zero); `placeLog(o + (ix, y - 3 + k / 2, iz))`. After the five add attachment `(o + (ix, y, iz), -2, false)` with the last `ix, iz`. Then `y -= 2 + nextInt(4)`.

### 4.5 dark_oak_trunk_placer

1. `placeBelowTrunkBlock` at the four cells as 4.3. `dir = getRandomDirection(r)`; `lean = H - nextInt(4)`; `steps = 2 - nextInt(3)`.
2. `(cx, cz) = (o.x, o.z)`, `top = o.y + H - 1`. For `i = 0..H-1`: if `i >= lean` and `steps > 0`: move `(cx, cz)` by `dir`, `steps -= 1`. `p = (cx, o.y + i, cz)`. If `isAirOrLeaves(p)`: `placeLog(p)`, `p.east`, `p.south`, `p.east.south`.
3. Add `((cx, top, cz), 0, true)`.
4. For `a = -1..2` (outer), `b = -1..2` (inner), around the **origin** column: skip when `a` in 0..1 and `b` in 0..1. Otherwise draw `nextInt(3)`; skip unless it is 0 (kept with probability 1/3). Kept: `n = nextInt(3) + 2`; for `k = 0..n-1` `placeLog((o.x + a, top - k - 1, o.z + b))`; then add `((o.x + a, top, o.z + b), 0, false)`.

### 4.6 fancy_trunk_placer (large oak)

Doubles use `java.lang.Math` (`pow`, `sin`, `cos`, `sqrt`), **not** the table trigonometry.

1. `T = H + 2`. `trunkTop = floor(T * 0.618)`. `clusters = min(1, floor(1.382 + pow(T / 13.0, 2.0)))` (always 1 for `T >= 0`). `ty = o.y + trunkTop`. `placeBelowTrunkBlock(o.below())`.
2. Coordinates list starts with `(attachment (o.above(T - 5), 0, false), branchBase ty)`.
3. For `y = T - 5` down to 0 inclusive: `sh = treeShape(T, y)`; if `sh < 0` next. For `c = 0..clusters-1`:
   - `rad = (double)sh * ((double)nextFloat() + 0.328)` (first draw);
   - `ang = (double)(nextFloat() * 2f) * PI` (second draw);
   - `fx = rad * sin(ang) + 0.5`, `fz = rad * cos(ang) + 0.5`;
   - `end = o + (floor(fx), y - 1, floor(fz))`, `top = end.above(5)`;
   - if `makeLimb(end, top, false)`: `dx = o.x - end.x`, `dz = o.z - end.z`; `by = end.y - sqrt(dx*dx + dz*dz) * 0.381`; `bi = by > (double)ty ? ty : (int)by`; `base = (o.x, bi, o.z)`; if `makeLimb(base, end, false)` append `(attachment (end, 0, false), branchBase base.y)`.
4. `makeLimb(o, o.above(trunkTop), true)`.
5. For each coords entry in order: `base = (o.x, entry.branchBase, o.z)`; if `base != entry.attachment.pos` and `trimBranches(T, entry.branchBase - o.y)`: `makeLimb(base, entry.attachment.pos, true)`.
6. Result: attachments of entries with `trimBranches(T, branchBase - o.y)` true, in list order.

`trimBranches(T, rel)` = `(double)rel >= (double)T * 0.2`. `treeShape(T, y)`: if `(float)y < (float)T * 0.3f` return `-1.0f`; `half = (float)T / 2f`; `d = half - (float)y`; `v = sqrt(half*half - d*d)` (float); if `d == 0` then `v = half`, else if `|d| >= half` return `0f`; return `v * 0.5f`.

`makeLimb(a, b, place)`: if not `place` and `a == b` return true. `n = max(|dx|,|dy|,|dz|)` of `b - a`; `sx = (float)dx / (float)n` (likewise `sy`, `sz`; `n = 0` gives NaN and `floor(NaN)` is 0). For `j = 0..n`: `p = a + (floor(0.5f + j*sx), floor(0.5f + j*sy), floor(0.5f + j*sz))` (float math). If `place`: `placeLog(p)` with modifier `axis`: `m = max(|p.x-a.x|, |p.z-a.z|)`; if `m > 0` the axis is X when `|p.x-a.x| == m` else Z; if `m == 0` Y. Else (check mode): if not `isFree(p)` return false. Return true.

### 4.7 bending_trunk_placer

Extra fields: `min_height_for_leaves` (positive int, default 1), `bend_length` (int provider 1..64).
1. `dir = getRandomDirection(r)`; `n = H - 1`; cursor `c = o`; `placeBelowTrunkBlock(c.below())`.
2. For `i = 0..n` inclusive: draw `nextInt(2)` each iteration; if `(i + 1) >= n + draw` then `c += dir`. If `validTreePos(c)`: `placeLog(c)`. If `i >= min_height_for_leaves` add `(c, 0, false)`. `c += UP`.
3. `len = bend_length.sample(r)`; for `j = 0..len` inclusive: if `validTreePos(c)` `placeLog(c)`; add `(c, 0, false)`; `c += dir`.

### 4.8 upwards_branching_trunk_placer (mangrove)

Fields: `extra_branch_steps` (positive int provider), `place_branch_per_log_probability` (float 0..1), `extra_branch_length` (non-negative int provider), `can_grow_through` (block set). `validTreePos` is overridden: base rule **or** state in `can_grow_through`. No `placeBelowTrunkBlock` call.
1. For `i = 0..H-1`: `y = o.y + i`; if `placeLog((o.x, y, o.z))` and `i < H - 1` and `nextFloat() < probability` (short-circuit order): `d = getRandomDirection(r)`; `l1 = extra_branch_length.sample(r)`; `start = max(0, l1 - extra_branch_length.sample(r) - 1)`; `steps = extra_branch_steps.sample(r)`; `placeBranch(y, d, start, steps)`.
2. If `i == H - 1` (whether or not a log was placed) add `((o.x, y + 1, o.z), 0, false)`.

`placeBranch(logY, d, start, steps)` (behaviour: a diagonal staircase of logs leaving the trunk in direction `d`, one cell outward and one up per step, after skipping the first `start` steps and never below trunk level 1; attachments go on every cell and, if the branch rose, at its tip; the exact counters follow): `lastY = logY + start`, `(x, z) = (o.x, o.z)`. For `k = start; k < H and steps > 0; k += 1, steps -= 1`: if `k < 1` continue (counters still advance); `y = logY + k`; `x += d.stepX`, `z += d.stepZ`; `lastY = y`; if `placeLog((x,y,z))` then `lastY += 1`; add `((x,y,z), 0, false)` (added whether or not placed). After the loop, if `lastY - logY > 1`: `q = (x, lastY, z)`; add `(q, 0, false)` and `(q.below(2), 0, false)`.

### 4.9 cherry_trunk_placer

Fields: `branch_count` (int provider 1..3), `branch_horizontal_length` (2..16), `branch_start_offset_from_top` (UniformInt within -16..0, max minus min at least 1), `branch_end_offset_from_top` (-16..16). The placer derives `second_start` = UniformInt(min, max - 1) of the start range.
1. `placeBelowTrunkBlock(o.below())`. `s1 = max(0, H - 1 + start.sample(r))`; `s2 = max(0, H - 1 + second_start.sample(r))`; if `s2 >= s1` then `s2 += 1`. `count = branch_count.sample(r)`; `three = count == 3`; `two = count >= 2`.
2. Trunk height `T = H` if `three`, else `max(s1, s2) + 1` if `two`, else `s1 + 1`. `placeLog(o.above(i))` for `i = 0..T-1`.
3. If `three` add `(o.above(T), 0, false)`.
4. `dir = getRandomDirection(r)`. Branch 1: `generateBranch(dir, s1, s1 < T - 1)`; if `two`, branch 2: `generateBranch(dir.opposite, s2, s2 < T - 1)`. Each adds one attachment.

`generateBranch(d, startY, flag)` (behaviour: a log path from the trunk at height `startY` to a tip `len` cells out horizontally and at height `endY`, each step randomly choosing vertical or horizontal in proportion to the remaining vertical share; the exact constants follow): `c = o.above(startY)`; `endY = H - 1 + branch_end_offset.sample(r)`; `long = flag or endY < startY`; `len = branch_horizontal_length.sample(r) + (long ? 1 : 0)`; `end = o.relative(d, len).above(endY)`. Move `c` by `d` once (twice when `long`), `placeLog` after each move with the axis modifier of `d`. Then loop: `vd = UP` if `end.y > c.y` else `DOWN`; `m = manhattan(c, end)`; stop when `m == 0`; `p = |end.y - c.y| / (float)m`; `b = nextFloat() < p`; `c += (b ? vd : d)`; `placeLog(c)` with identity modifier if `b`, else the axis modifier of `d`. Attachment `(end.above(), 0, false)`.

### 4.10 poplar_trunk_placer

Fields: `trunk_height_above_branches` (int provider 0..8), `branch_amount` (1..4).
1. `placeBelowTrunkBlock(o.below())`. `by = H - trunk_height_above_branches.sample(r)`.
2. For `i = 0..H-1`: `placeLog(o.above(i))`; then **every iteration** shuffle the directions: the list `Direction.values()` (DOWN, UP, NORTH, SOUTH, WEST, EAST) shuffled by `for n = 6 down to 2: j = nextInt(n); swap(list[j], list[n-1])` (5 draws), then the vertical ones removed keeping order. If `by - 1 == i`: `cnt = branch_amount.sample(r)`; for `k = 0..cnt-1`: `placeLog(o.above(i).relative(list[k]))` with the sideways modifier of that direction.
3. Attachment `(o.above(by), 0, false)`.

## 5. Foliage placers

Common codec: `radius` int provider 0..16, `offset` int provider 0..16. In the tables `rO` is `att.radiusOffsetXZ`, `hO` is `att.foliageHeightOffset` (0 here), `off` the offset draw, `rad` the row radius, `ax`, `az` the folded absolute offsets of 5.1.

### 5.1 Row helpers

`placeLeavesRow(center, radius, y, double)`: `e = double ? 1 : 0`; for `dx = -radius .. radius + e` (outer), `dz = -radius .. radius + e`: if `shouldSkipLocationSigned(r, dx, y, dz, radius, double)` skip; else `tryPlaceLeaf(center + (dx, y, dz))`. The skip test draws (when the placer's does) before the leaf's provider draw.

`shouldSkipLocationSigned`: with `double`, `ax = min(|dx|, |dx-1|)`, `az = min(|dz|, |dz-1|)`, else `ax = |dx|`, `az = |dz|`; result is the placer's `shouldSkipLocation(r, ax, y, az, radius, double)`. Dark oak and poplar override.

`tryPlaceLeaf(p)`: fail if the state at `p` has `persistent = true`, or `validTreePos(p)` is false. Else `s = foliage_provider.getState(level, r, p)`; if `s` has `waterlogged`, set it to "the fluid at `p` is a water source"; foliage setter `set(p, s)`; true.

`placeLeavesRowWithHangingLeavesBelow(center, radius, y, double, p1, p2)` (defined in `FoliagePlacer` as a protected final method, with a private static `tryPlaceExtension`; only the cherry placer calls it): first `placeLeavesRow(...)`. `e = double ? 1 : 0`, `ref = center.below()`. For each `d` in HORIZONTAL (array order; `Direction.Plane.iterator()` iterates the array, read): `cw = d.getClockWise()` (`Direction.getClockWise()` read: NORTH to EAST, EAST to SOUTH, SOUTH to WEST, WEST to NORTH); `shift = radius + e` if `cw` points to a positive direction (EAST, SOUTH) else `radius`; `c = center + (0, y - 1, 0)` moved by `cw * shift`, then by `d * (-radius)`. For `k = -radius .. radius + e - 1`: if the foliage set holds `c.above()`: when `tryExt(c, p1)` succeeds: `c.down`, `tryExt(c, p2)` (result ignored), `c.up`. Then `c += d`. `tryExt(c, p)`: false if `manhattan(c, ref) >= 7`; draw `nextFloat()`, false if greater than `p`; else `tryPlaceLeaf(c)`.

### 5.2 Table of placers

| Placer | Extra fields | foliageHeight(r, H) | Rows and skip test |
|---|---|---|---|
| blob | `height` int 0..16 | `height` | `hh = FH + hO`; for `y = off` down to `off - hh`: `rad = max(leafRadius + rO - 1 - y / 2, 0)` (Java `/`, truncating toward zero: `-3 / 2 = -1`); `placeLeavesRow(att.pos, rad, y)`. Skip: `ax == rad and az == rad and (nextInt(2) == 0 or y == 0)`; the draw happens whenever `ax == az == rad`, before the `y == 0` test |
| bush | as blob | `height` | same loop, `rad = leafRadius + rO - 1 - y`; skip: `ax == rad and az == rad and nextInt(2) == 0` |
| spruce | `trunk_height` int 0..24 | `max(4, H - trunk_height.sample(r))` | `c = att.pos`; `rad = nextInt(2)` (draw), `hi = 1`, `lo = 0`; for `y = off` down to `-(FH + hO)`: `placeLeavesRow(c, rad, y)`; then if `rad >= hi`: `rad = lo`, `lo = 1`, `hi = min(hi + 1, leafRadius + rO)`; else `rad += 1`. Skip: `ax == rad and az == rad and rad > 0` |
| pine | `height` int 0..24 | `height.sample(r)` | `rad = 0`; for `y = off` down to `off - (FH + hO)`: `placeLeavesRow(att.pos, rad, y)`; if `rad >= 1` and `y == off - (FH + hO) + 1`: `rad -= 1`; else if `rad < leafRadius + rO`: `rad += 1`. Skip as spruce |
| acacia | none | `0` | `c = att.pos.above(off)`, `hh = FH + hO`; rows `(rad = leafRadius + rO, y = -1 - hh)`, `(rad = leafRadius - 1, y = -hh)`, `(rad = leafRadius + rO - 1, y = 0)`. Skip: if `y == 0`: `(ax > 1 or az > 1) and ax != 0 and az != 0`; else `ax == rad and az == rad and rad > 0` |
| fancy | `height` 0..16 | `height` | for `y = off` down to `off - FH` (`hO`, `rO` unused): `rad = leafRadius + (y == off or y == off - FH ? 0 : 1)`; `placeLeavesRow(att.pos, rad, y)`. Skip: `(float)(ax) + 0.5f` squared plus `(float)(az) + 0.5f` squared is greater than `(float)(rad*rad)` |
| jungle (mega jungle) | `height` 0..16 | `height` | `hh = (double ? FH : 1 + nextInt(2)) + hO` (the draw only for a single trunk); for `y = off` down to `off - hh`: `rad = leafRadius + rO + 1 - y`; `placeLeavesRow(att.pos, rad, y)`. Skip: `ax + az >= 7` or `ax*ax + az*az > rad*rad` |
| mega pine | `crown_height` int 0..24 | `crown_height.sample(r)` | `c = att.pos`, `prev = 0`, `hh = FH + hO`; for `yy = c.y - hh + off` to `c.y + off` inclusive: `d = c.y - yy`; `rad = leafRadius + rO + floor((float)d / (float)hh * 3.5f)`; `use = (d > 0 and rad == prev and (yy & 1) == 0) ? rad + 1 : rad`; `placeLeavesRow((c.x, yy, c.z), use, 0)`; `prev = rad`. Skip as jungle |
| dark oak | none | `4` | `c = att.pos.above(off)`; double trunk: rows `(leafRadius + 2, -1)`, `(leafRadius + 3, 0)`, `(leafRadius + 2, 1)`, then if `nextBoolean()` `(leafRadius, 2)`; single trunk: `(leafRadius + 2, -1)`, `(leafRadius + 1, 0)`. Signed override: `y == 0 and double and (dx == -rad or dx >= rad) and (dz == -rad or dz >= rad)` skips; otherwise the base folding. Skip: `y == -1 and not double: ax == rad and az == rad`; `y == 1`: `ax + az > rad*2 - 2`; else keep |
| random spread | `foliage_height` int 1..512, `leaf_placement_attempts` int 0..256 | `foliage_height.sample(r)` | `c = att.pos` (offset unused); repeat `attempts` times: `p = c + (nextInt(leafRadius) - nextInt(leafRadius), nextInt(FH) - nextInt(FH), nextInt(leafRadius) - nextInt(leafRadius))` (draws in written order); `tryPlaceLeaf(p)` |
| cherry | `height` 4..16, floats 0..1: `wide_bottom_layer_hole_chance`, `corner_hole_chance`, `hanging_leaves_chance`, `hanging_leaves_extension_chance` | `height.sample(r)` | `c = att.pos.above(off)`, `r0 = leafRadius + rO - 1`, `hh = FH + hO`; rows `(r0 - 2, hh - 3)`, `(r0 - 1, hh - 4)`; for `y = hh - 5` down to 0: `(r0, y)`; then hanging rows `(r0, -1)` and `(r0 - 1, -2)` via `placeLeavesRowWithHangingLeavesBelow(.., hanging_leaves_chance, hanging_leaves_extension_chance)`. Skip, in draw order: (1) `y == -1 and (ax == rad or az == rad) and nextFloat() < wide_bottom` skips; (2) `corner = ax == rad and az == rad`, `wide = rad > 2`; wide: skip `corner or ((ax + az > 2*rad - 2) and nextFloat() < corner_hole)`; not wide: skip `corner and nextFloat() < corner_hole` |
| poplar | `height` 5..16, `side_hole_chance` float 0..1 | `height.sample(r)` | 5.4 |

### 5.3 Pine radius

Pine overrides `foliageRadius(r, n)` with `n = H - FH`: `radius.sample(r) + nextInt(max(n + 1, 1))` (sample first).

### 5.4 Poplar foliage

`c = att.pos.above(off)`, `r0 = leafRadius + rO - 1`, `flip = nextBoolean()` (first draw), `hh = FH + hO`. Rows with the poplar row routine (5.5), in order: `(r0 - 2, hh - 1)`, `(r0 - 1, hh - 2)`, `(r0 - 1, hh - 3)`, then `y = hh - 4` down to 1: `(r0, y)`; then `replaceLeavesWithLog(c, r0, hh - 4)`; then `(r0 - 1, 0)` and `(clamp(r0 - 2, 1, 2), -1)`.

### 5.5 Poplar row and log replacement

`partial(y) = (hh - 1 == y) or (hh - 2 == y)`. `cut(x, z, rad, p)` is `rad - 1` if `corner`, else `rad + 1` if `p`, else `rad`; `corner` for `flip == false` is "x and z non-zero with opposite signs", for `flip == true` "non-zero with equal signs". `inside(rad, ax, az, cutv, hole)` = `ax + az <= 2*rad - (cutv + hole)`.
Row routine: for `x = -rad .. rad + e`, `z = -rad .. rad + e` (x outer, **signed** values, no folding): `p = partial(y)`; `edge = |x| == rad or |z| == rad`; if `p and edge` skip (no draw); else `hole = nextFloat() <= side_hole_chance ? 1 : 0` (draw), skip when not `inside(rad, |x|, |z|, cut(x, z, rad, p), hole)`. Else `tryPlaceLeaf`.
`replaceLeavesWithLog(c, rad, y)`: for `x`, `z` as above: when `inside(rad, |x|, |z|, cut(x, z, rad, partial(y)), 2)` and `((|z| == 0 and rad - |x| >= 4) or (|x| == 0 and rad - |z| >= 4))`: `tryPlaceLog(c + (x, y, z), axis = X if |z| == 0 else Z)`. `tryPlaceLog` acts only if the block at `p` equals `foliage_provider.getState(level, r, p)` (a provider draw if random), then sets `sidewaysModifier(axis)(trunk_provider.getState(level, r, p))` through the foliage setter.

## 6. Root placers

Common codec: `trunk_offset_y` (int provider), `root_provider` (state provider), optional `above_root_placement` = `{above_root_provider, above_root_placement_chance 0..1}`. `getTrunkOrigin(pos, r)` = `pos.above(trunk_offset_y.sample(r))`. Base `canPlaceRoot` = `validTreePos`. Base `placeRoot(p)`: if not `canPlaceRoot(p)` return; set `p` to `waterlogged(root_provider.getState(...))`; if above-placement is present: draw `nextFloat()`; when it is below the chance and `p.above()` is air, set it to `waterlogged(above_root_provider.getState(...))` (the draw happens whenever the field is present, before the air test).

### 6.1 mangrove_root_placer

Extra codec `mangrove_root_placement`: `can_grow_through`, `muddy_roots_in` (block sets), `muddy_roots_provider`, `max_root_width` 1..12, `max_root_length` 1..64, `random_skew_chance` 0..1. `canPlaceRoot` = base or state in `can_grow_through`. `placeRoot(p)`: if the state at `p` is in `muddy_roots_in`: set `p` to `waterlogged(muddy_roots_provider.getState)` (no `canPlaceRoot` test); else the base rule.
`placeRoots(level, setter, r, pos, trunkOrigin)`:
1. For `c = pos` upward while `c.y < trunkOrigin.y`: if not `canPlaceRoot(c)` return false.
2. `list = [trunkOrigin.below()]`.
3. For each `d` in HORIZONTAL: `start = trunkOrigin.relative(d)`; `sub = []`; if not `simulate(start, d, 0, sub)` return false; append `sub`, then append `trunkOrigin.relative(d)`.
4. `placeRoot` for each list position in order (duplicates allowed); return true.
`simulate(cur, d, depth, sub)` (behaviour: a depth-first walk that lays out the roots of one direction, and fails the whole tree when a root path reaches the length limit): if `depth == max_root_length` or `sub.size() > max_root_length` return **false** (a root that never ends fails the tree); for each `q` in `potential(cur, d)`: if `canPlaceRoot(q)`: append `q`; if not `simulate(q, d, depth + 1, sub)` return false. Return true.
`potential(cur, d)`: `below = cur.below()`, `side = cur.relative(d)`, `m = manhattan(cur, trunkOrigin)`, `W = max_root_width`, `sk = random_skew_chance`. If `m > W - 3` and `m <= W`: `[below, side.below()]` when `nextFloat() < sk`, else `[below]`. Else if `m > W`: `[below]` (no draw). Else: `[below]` when `nextFloat() < sk`; otherwise `[side]` when `nextBoolean()`, else `[below]`.

## 7. FallenTreeFeature

Methods read for this section (all of `FallenTreeFeature` bytecode, steps traced in full): `place`, `placeFallenTree`, `setGroundHeightForFallenLogStartPos`, `placeStump`, `canPlaceEntireFallenLog`, `placeFallenLog`, `mayPlaceOn` (= `validTreePos` and `isOverSolidGround`), `isOverSolidGround` (block below, `isFaceSturdy(level, pos, UP)` with `pos` the cell tested), `placeLogBlock`, `decorateLogs`, the sideways modifier (sets the `axis` property to the axis of `dir`), the decoration setter (`setBlock` flags 19), plus `Feature.markAboveForPostProcessing` (up to 2 cells above, stopping at the first air cell). Draw order read: stump decorators, `getRandomDirection`, `log_length.sample`, `nextInt(2)`.

Codec: `trunk_provider`, `log_length` (int provider 0..16), `stump_decorators`, `log_decorators`. `place` always returns true.
1. Stump: `placeLogBlock(o)` unconditionally (no validity test; `setBlockAndUpdate` with the trunk provider state), then mark up to 2 cells above (stopping at air) for post-processing; then the stump decorators on {o} (context logs = {o}, leaves and roots empty, decoration setter flags 19).
2. `dir = getRandomDirection(r)`; `len = log_length.sample(r) - 2`; `start = o.relative(dir, 2 + nextInt(2))`.
3. Ground search: `c = start + UP`; for `i = 0..5`: if `validTreePos(c)` and the block below `c` is face-sturdy on UP, stop; else `c += DOWN`. After six misses the cursor is at `start.y - 5`.
4. Fit test: walking `len` cells along `dir` from `c`: each must satisfy `validTreePos`; a cell without a sturdy block below adds 1 to a gap counter, a supported cell resets it; more than 2 fails. If it fails nothing more is placed.
5. Place `len` logs along `dir` from `c`, each with the sideways modifier of `dir` (`setBlockAndUpdate`, post-processing mark), then the log decorators on the set of placed positions.
With `len <= 0` no log is placed and the stump remains. The sturdy test passes the log position (not the support position) to `isFaceSturdy`.

## 8. Worked examples (computed)

1. **Oak** (data `oak`: straight trunk 4/2/0, blob foliage height 3 radius 2 offset 0, two-layers size with defaults). Draws `nextInt(3)`, `nextInt(1)`; if the first is 1, `H = 5`, `FH = 3`, `leafRadius = 2`. Logs `o+0 .. o+4`, attachment `o+5`. Rows `y = 0, -1, -2, -3` around `o+5` have radii `1, 1, 2, 2` (`y / 2` is `0, 0, -1, -1`). The `y = 0` row skips its four corners (each corner draws `nextInt(2)` first): 5 leaves.
2. **Spruce foliage**: `FH = 5`, `leafRadius = 2`, `off = 1`, first draw `rad = 0`: rows `y = 1 .. -5` have radii `0, 1, 0, 1, 2, 1, 2`.
3. **Fancy** (data `fancy_oak`): `H = 10`, `T = 12`, `trunkTop = floor(7.416) = 7`, `clusters = 1`, start `y = 7`. `treeShape(12, 7)`: `half = 6`, `d = -1`, `sqrt(35) * 0.5 = 2.958`. `y = 3` gives `-1` (3 is below 3.6). `trimBranches(12, rel)` needs `rel >= 2.4`.
4. **Forking** (acacia): `H = 6`, `dir = EAST`, `nextInt(4) = 1` gives `lean = 4`, `nextInt(3) = 0` gives `steps = 3`. Columns for `i = 0..3` at x; `i = 4, 5` at x+1, x+2; attachment `(x+2, y+6)` with radius offset 1.
5. **Mangrove potential**: `W = 8`, `m = 6`: with `nextFloat() < sk` the result is `[below, side.below()]`, else `[below]`.

## 9. Validation

- Counts from the artifact: `data/minecraft/worldgen/feature` holds 240 files; 45 are `minecraft:tree` (trunk: 19 straight, 6 fancy, 6 poplar, 5 dark oak, 2 cherry, 2 giant, 2 upwards branching, 1 each forking, bending, mega jungle; foliage: 16 blob, 6 fancy, 6 poplar, 5 dark oak, 3 random spread, 2 cherry, 2 mega pine, 1 each acacia, bush, jungle, pine, spruce; sizes 40 two-layers and 5 three-layers; 2 mangrove root placers) and 6 are `fallen_tree`.
- Tests should fix a random source (10 §2.1 fixtures) on a flat grass world and assert: log positions of 4.1 to 4.3 for known `H`; the per-row leaf count of example 1; no write outside `[minY + 1, maxY]`; a tree blocked at `y = 3` of `H = 5` fails without `min_clipped_height` and, with `min_clipped_height <= 3`, is built with `free = 3`.

## Open questions

1. Stored leaf distances after 2.4 depend on hash-set iteration order. The `BlockPos` hash and the `HashSet` container are read; the JDK table behaviour used to turn them into an order is (recalled, not verified), and the claim that in-layer order does not change the written distances is (inferred). That the scheduled leaf ticks run at first chunk ticking and not during generation is (inferred) from the read fact that they are stored in the chunk tick container (2.5).
2. Int providers other than constant and uniform are not described here (provider sibling).
3. The decorator `Context` constructor's treatment of the three position sets (sorting) is 35 p4 §3.1 and was not read here.
4. The contents of `soil_beneath_tree`, `replaceable_by_trees`, `logs`, `leaves` and `prevents_nearby_leaf_decay` are DATA and were not tabulated.
5. Chunk-border behaviour of `setBlock` when a tree straddles chunks (35 p1 §4, 11 §6.5) is not restated.
6. The `Mth.sin` table size (65536) is recorded as read from the static initialiser in 34 p5 §1.1 (`34-entity-models-5-...`, closed item 4), not re-read here; the mega jungle trunk (4.4) depends on it.
7. The mega-jungle and mangrove example numbers are computed by hand, not checked against a running game.
8. Section 2.5 is now traced in full (face scan, pass order, directions, update flags, leaf `updateShape`); what remains open is only the point in Open question 1 (when the scheduled ticks run).
9. `TrunkPlacer.MAX_HEIGHT = 80` is a read static field; its consumers (a height clamp, a codec bound or neither) were searched only in `TreeFeature` and `TrunkPlacer`, where no use was found. Sections 3 and 4 do not depend on it; the data feature sizes (0..80) are separate constants.
10. Sections 4.10, 5.4, 5.5, 6 base and above-root, 7 and the cherry and dark oak foliage rows were checked by the earlier reading only and were not independently re-verified by a second reader.
