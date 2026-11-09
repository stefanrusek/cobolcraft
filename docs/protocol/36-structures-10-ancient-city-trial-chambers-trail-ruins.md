# 36 Structures, part 10: ancient city, trial chambers, trail ruins, the remaining jigsaw structures, loot and spawn checklist

| Item | Value |
|---|---|
| Covers | Three jigsaw structures with special rules: the ancient city (`ancient_city`, deep dark, `beard_box`), the trial chambers (`trial_chambers`, pool aliases, dimension padding, `encapsulate`, ignore-waterlogging) and the trail ruins (`trail_ruins`, `bury`, heightmap projection, suspicious-gravel archaeology). It also states the jigsaw engine facts these three need and that were read in this round (start, child placement, queue priority, pools, pool elements, aliases, free space, the per-piece processor pipeline), the behaviour of every structure processor these structures use, a table of every other jigsaw structure and the jigsaw parameters it uses, and a closing checklist of structure loot table ids and spawn overrides. |
| Does not cover | Rows of data. The extraction tool copies `worldgen/structure`, `worldgen/structure_set`, `worldgen/template_pool`, `worldgen/processor_list`, `trial_spawner/*`, the loot tables and the structure `.nbt` files (22, 23 section 2.1). Template NBT geometry (which block is where) is data. The generic template loader, `placeInWorld`, the waterlogging fix-up pass and the rule-test catalogue (36-2); the generic jigsaw model written for all jigsaw structures (36-3); villages and outposts (36-9) and the bastion remnant (36-8) (36-8 and 36-9, see section 6); the model, placement engines, starts, `StructureStart`, `BoundingBox`, spawn-override query and the beardifier (36-1). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `JigsawStructure`, `JigsawPlacement` (and its inner `Placer`), `StructureTemplatePool`, `SinglePoolElement`, `ListPoolElement`, `FeaturePoolElement`, `EmptyPoolElement`, `PoolElementStructurePiece`, `DimensionPadding`, `PoolAliasLookup`, `PoolAliasBinding` and its three kinds, `LiquidSettings`, `StructureTemplate` (`placeInWorld`, `processBlockInfos`, `getJigsaws`), `JigsawBlock.canAttach`, `JigsawReplacementProcessor`, `BlockIgnoreProcessor`, `BlockRotProcessor`, `RuleProcessor`, `ProcessorRule`, `RandomBlockMatchTest`, `TagMatchTest`, `ProtectedBlockProcessor`, `CappedProcessor`, `AppendLoot`, `SequencedPriorityIterator`, `WeightedList`, `Util` (shuffle), `Mth.getSeed`, `LegacyRandomSource`, `SingleThreadedRandomSource`; and of the data files in the jar (`unzip -p`, JSON and gzip NBT decoded with scratch scripts, not part of the repository). No execution. |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engines (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"; design map `docs/design/README.md` GAP-12b, GAP-18, R4, R7, R10). |
| Status | Written by the reader for round RS20, part 10. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not
verified)" marks something not read; both are listed in the Open questions. Nothing in this document is taken from recall: every
value, ordering and formula was read from the artifact in this round. Cross-references: "36-1 section N" is
[36-structures-1-model-placement-starts.md](36-structures-1-model-placement-starts.md); "36-2 section N" is
[36-structures-2-templates-and-processors.md](36-structures-2-templates-and-processors.md) (template loading and block order, `placeInWorld`,
the waterlogging pass, processors); "36-3 section N" is [36-structures-3-jigsaw-assembly.md](36-structures-3-jigsaw-assembly.md) (the generic jigsaw
assembly: section 9 start, section 10 child placement, section 10.4 expansion hack, section 5 pool elements); 36-8 and 36-9 are
[nether and end](36-structures-8-nether-and-end.md) and [villages and outposts](36-structures-9-villages-outposts.md). Section 2 below restates only the
jigsaw facts these three structures use, as a reading aid; 36-2 and 36-3 are the authorities and were reconciled with this section (differences found
and fixed: the expansion hack, section 2.3 step 4.5.6, and the block order of section 2.5 step 1). Other documents: "10 section 2.6", "11 section 4"
(random sources and `WorldgenRandom`, not repeated), "23 section 7.3.2" (height providers), "26 section 11" (loot rolling),
"31-7 section 4 and 5" (trial spawner and vault block entities), "31-4 section 7" (brushable block), "31-8 section 6" and "30-8
section 6" (sculk shrieker), "35-6 section 8.3" (sculk patch feature), "44-2 section 4 and 8" (trial spawner engine, structure
spawn overrides), "20 section 15" (warden), "33" (game rules). Block coordinates are absolute unless stated. Integer division in
formulas is Java's (truncating towards zero).

---

## 1. Where the line is drawn for these three structures

| Item | Supplied by | Where specified |
|---|---|---|
| The `worldgen/structure` records `ancient_city`, `trial_chambers`, `trail_ruins` and their structure sets | data pack | schema 36-1 section 3; the parameters they use: section 2.1 and the per-structure sections |
| 7 + 47 + 7 template pools (ancient city, trial chambers, trail ruins), 333 structure NBT files (58 + 191 + 84), 7 processor lists, 28 trial spawner config files | data pack | schema and engine: sections 2 to 5 |
| The jigsaw engine, the pool alias engine, the pool element kinds, the processor kinds and their random-number use | code | section 2 |
| `sculk_patch_ancient_city` (the feature that places shriekers) | data pack (feature record) | engine 35-6 section 8.3 |
| Trial spawner, vault, decorated pot, chest, barrel, dispenser, brushable block behaviour | code | 31-1 section 9, 31-3, 31-4 section 7, 31-7 |
| Loot tables of the structures | data pack | rolling: 26 section 11; the id checklist: section 7 |

Rule for implementers, as in 36-1: never tabulate or hard-code a pool, a weight, a template or a probability from this document's
examples; read the loaded records. The numbers embedded in code are the constants of the formulas below.

---

## 2. The jigsaw engine facts these structures depend on

### 2.1 The `jigsaw` structure record (`JigsawStructure`)

Section 2 as a whole is a restatement for convenience; 36-3 sections 8 to 10 and 36-2 section 5 are the authorities.

Besides the common settings (36-1 section 3.1: `biomes`, `step`, `terrain_adaptation`, `spawn_overrides`):

| Field | Type, range, default | Meaning |
|---|---|---|
| `start_pool` | template pool reference | where the first piece is drawn from |
| `start_jigsaw_name` | optional identifier | the jigsaw block of the start piece that is placed on the start position; absent: the piece's own origin corner is placed there |
| `size` | int 0 to 20 | maximum depth of the piece tree (section 2.3) |
| `start_height` | height provider (23 section 7.3.2) | the y of the start position (before the shift of section 2.2 step 12) |
| `use_expansion_hack` | bool | when true, enlarges the child box used for collision and for the free-space update (section 2.3 step 4.5.6; 36-3 section 10.4). False in all three structures here |
| `project_start_to_heightmap` | optional heightmap type | when present, the start is lifted by the surface height (section 2.2 step 11) |
| `max_distance_from_center` | int 1 to 128 (both axes), or an object `{horizontal, vertical}`: `horizontal` int 1 to 128, `vertical` optional, int 1 to `DimensionType.Y_SIZE`, default `Y_SIZE` (the constant is `2^PACKED_Y_LENGTH - 32`, read as 4064: `PACKED_HORIZONTAL_LENGTH = 1 + log2(smallestEncompassingPowerOfTwo(30000000)) = 1 + 25 = 26`, `PACKED_Y_LENGTH = 64 - 2 * 26 = 12`, `Y_SIZE = 4096 - 32 = 4064`; the static initialisers of `BlockPos` and `DimensionType` were read, the power-of-two and log2 results are the arithmetic of the named helpers (inferred), so the default vertical max distance is 4064, with `MAX_Y = 2031`, `MIN_Y = -2032`; Open question 2) | half-extent of the box inside which every piece must lie (section 2.2 step 15) |
| `pool_aliases` | list of alias bindings, default empty | section 2.6 |
| `dimension_padding` | int (both), or object `{bottom, top}` (each optional, lenient, non-negative int, an omitted one is 0); default zero | keeps the structure away from the world's lowest and highest layers |
| `liquid_settings` | `apply_waterlogging` (default) or `ignore_waterlogging` | handed to every piece (section 2.8) |

Validation when the record loads: `max_distance_from_center.horizontal + e <= 128`, where `e = 0` for `terrain_adaptation = none` and
`e = 12` for every other mode (the 12 is the terrain-adaptation inflation of 36-1 section 5.6). The three structures: 116 + 12 = 128
(ancient city, trial chambers), 80 + 12 = 92 (trail ruins).

### 2.2 Creating a start (`JigsawStructure.findGenerationPoint`, `JigsawPlacement.addPieces`)

Inputs: the generation context of 36-1 section 5.1 (chunk, world seed, `random` = the per-chunk large-feature-seeded generator), the
record of section 2.1. Notation: `minY`, `maxY` = the level's lowest and highest block y (overworld -64 and 319, 10 section 7); `h`, `v` =
the horizontal and vertical `max_distance_from_center`; `bottom`, `top` = the dimension padding.

1. `y0 = start_height.sample(random)`. A constant draws nothing; `uniform` draws one `nextInt` (23 section 7.3.2).
2. `origin = (16 * chunkX, y0, 16 * chunkZ)` (the chunk's minimum block corner).
3. Build the alias lookup (section 2.6) from `pool_aliases`, `origin` and the world seed. It uses its own generator, never `random`.
4. `rotation = [NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90][random.nextInt(4)]`.
5. `pool = alias(start_pool)` looked up in the template pool registry; when the aliased key is not registered the declared pool is
   used.
6. `element = pool.getRandomTemplate(random)`: the weight-expanded element list (section 2.4) indexed by `random.nextInt(count)`;
   an empty pool or the empty element: no structure.
7. With `start_jigsaw_name`: take the element's jigsaw blocks placed at `origin` with `rotation`, shuffled and ordered by
   selection priority (section 2.3 step 3), and keep the first whose `name` equals the start name; none: log an error, no structure.
   Without it, `jigsawPos = origin`.
8. `offset = jigsawPos - origin`; `piecePos = origin - offset`. The piece's minimum-corner position is therefore chosen so that the
   chosen jigsaw block lands exactly on `origin`.
9. Create the start piece with `groundLevelDelta = 1`, `rotation`, box `element.getBoundingBox(piecePos, rotation)`.
10. `cx = (box.maxX + box.minX) / 2`, `cz = (box.maxZ + box.minZ) / 2` from that box (truncating division).
11. Surface y: with no `project_start_to_heightmap`, `ySurf = piecePos.y`. With it: if `couldStructureExistInColumn(cx, cz, minY, maxY)`
    (36-1 section 4 helper, true when a valid biome exists anywhere in the column) is false, no structure; else
    `ySurf = origin.y + getFirstFreeHeight(cx, cz, heightmap)` (36-1 section 5.4: `getBaseHeight`; note that the sampled start
    height is **added** to the surface height).
12. (Ground level delta.) The start piece's `groundLevelDelta` is the element's `getGroundLevelDelta()`: `StructurePoolElement` defines it as the constant 1, and
    `SinglePoolElement`, `LegacySinglePoolElement`, `ListPoolElement`, `FeaturePoolElement` and `EmptyPoolElement` declare no override (checked in the class method lists),
    so it is 1 for every element kind. Shift the piece (position and box) vertically by `ySurf - (box.minY + groundLevelDelta)`. After the shift
    `box.minY = ySurf - groundLevelDelta`, that is one below `ySurf` for a start piece.
13. Dimension padding: the start is rejected when `box.minY < minY + bottom` or `box.maxY > maxY - top` (never when the padding is the
    zero value).
14. The generation stub's position is `(cx, ySurf + offset.y, cz)`. It is the position whose biome is tested (36-1 section 5.3 step 2).
    Without a heightmap it equals `(cx, y0, cz)` for every rotation (the `offset.y` cancels `piecePos.y`).
15. The stub's consumer (run only after the biome check, 36-1 section 5.3 step 3) does the following. The piece list starts with the start piece.
    If `size <= 0` stop. Otherwise define the **free space** as the set of integer cells with
    `x in [cx - h, cx + h]`, `z in [cz - h, cz + h]`, `y in [max(cy - v, minY + bottom), min(cy + v, maxY - top)]` (`cy` = the stub's y),
    minus the cells of the start piece's box, and run the child placement (section 2.3) with the start piece at depth 0. The pieces,
    in creation order, are then appended to the start's builder.

Random draws of the start, in order: step 1 (0 or 1 draw), step 4 (1), step 6 (1), step 7 (when used: the shuffle of the element's
jigsaw blocks, `k - 1` draws for `k` blocks, section 2.3 step 3). Every later draw (the child placement) comes from the same
`random`, after the biome check.

### 2.3 Child placement (`JigsawPlacement$Placer`)

State: the piece list, a **queue** (`SequencedPriorityIterator`), the maximum depth `size`, the generation `random`. The queue returns
the entry with the **highest priority** first and entries of equal priority in insertion order. An entry is `(piece, free-space
holder, depth)`.

1. Place the children of the start piece (depth 0, the free space of section 2.2 step 15). Then, while the queue is not empty, pop an
   entry and place the children of its piece with its holder and depth.
Rules first, ordering constraints after. Rules: the child's target bottom is `t = B.minY + k` when both pieces are rigid, else `s - C.pos.y` (`s` the first free surface height); `k = relY - C.pos.y + f.stepY`; the vertical shift is `t - childBox.minY`; the child's delta is `gP - k` when rigid, else its element's own delta (default 1); a junction record on each side holds source x, source ground y, source z, delta y (`k` on the parent, `-k` on the child) and the other piece's projection. Ordering constraints: shuffle then stable priority sort of jigsaws; pool lookup before candidate lists; candidates tried in list order with a fresh rotation shuffle each; shift, optional expansion, collision test, then free-space removal, piece creation, junction records and enqueue, in that order, stopping at the first accepted candidate. The numbered steps below give the same behaviour with its inputs and constants.
2. **Placing the children of piece `P`** (box `B`, element projection `rigid(P)`, rotation, `groundLevelDelta` `gP`), with a fresh,
   initially unset local holder `L` created for this call:
3. List the jigsaw blocks of `P`'s element at `P`'s position and rotation. The element's jigsaw list is shuffled with `Util.shuffle`
   (for `i` from the size down to 2: `j = nextInt(i)`, swap entries `i - 1` and `j`) and then stably sorted by `selection_priority`,
   highest first (a block's `placement_priority` and `selection_priority` are int NBT keys of the jigsaw block entity, default 0).
4. For each jigsaw `J` of `P` in that order (`f` = its facing, `frontPos = J.pos + f`, `relY = J.pos.y - B.minY`, the surface cache
   unset):
   1. `poolKey = alias(J.pool)`. Look it up. Not registered, or empty (zero elements) and not the registry's `empty` pool: log "Empty or
      non-existent pool", go to the next `J`. The fallback pool of that pool (not aliased) gets the same check ("Empty or non-existent fallback
      pool").
   2. Choose the free space for `J`: when `B` contains `frontPos`, the local holder `L` (initialised on first use to the cells of `B`);
      otherwise the holder passed in. Consequence: a connection that points into the parent's own box can only use the parent's box,
      and does not consume the structure-wide free space.
   3. Candidates: when `depth != size`, the pool's shuffled element list; then, always, the fallback pool's shuffled list. At the
      maximum depth only the fallback list is used. (Shuffle as in step 3, one shuffle per list.)
   4. The priority of every piece created from `J` is `J.placement_priority`.
   5. For each candidate `E` in order: if `E` is the empty element, stop with `J` (nothing is placed for it, go to the next `J`).
      Otherwise for each rotation `R` in a freshly shuffled list of the four rotations (`Rotation.getShuffled`: a copy of the array
      [NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90], the same order as the start's `random.nextInt(4)` pick of section 2.2 step 4, shuffled
      with `Util.shuffle`; one shuffle per candidate `E`), and each jigsaw `C` of `E` at the zero origin with
      `R` (shuffled and priority-sorted as in step 3):
      1. `canAttach(J, C)` must hold (section 2.3.1), else try the next `C`.
      2. `childPos = frontPos - C.pos` (using `C`'s rotated local position); `childBox = E.getBoundingBox(childPos, R)`;
         `rigid(E)` = element projection is `rigid`.
      3. `k = relY - C.pos.y + f.stepY` (`f.stepY` is +1, -1 or 0).
      4. Target bottom `t`: when `rigid(P)` and `rigid(E)`, `t = B.minY + k`. Otherwise (terrain matching on either side) `t = s - C.pos.y`
         where `s = getFirstFreeHeight(J.pos.x, J.pos.z, WORLD_SURFACE_WG)`, computed once per `J` and cached.
      5. `shift = t - childBox.minY`; move `childBox` and `childPos` up by `shift`.
      6. Expansion hack (36-3 section 10.4; read in `Placer.tryPlacingChildren`): let `h` be 0 unless `use_expansion_hack` is true and the
         candidate's unshifted box (zero origin, rotation `R`) has Y-span <= 16. In that case `h` is the maximum, over those jigsaws of the candidate
         whose front cell lies inside the candidate's own box, of `max(maxSize(pool of that jigsaw after aliasing), maxSize(that pool's fallback))`, where
         `maxSize` is the largest Y-span of the pool's non-empty elements and an unregistered pool counts 0. When `h > 0`, the shifted box (the object
         produced by the shift of step 5) is extended in place: `kk = max(h + 1, box.maxY - box.minY)` and the box is encapsulated with the point
         `(minX, minY + kk, minZ)`, so `maxY` becomes `max(maxY, minY + h + 1)`. The enlarged box is the one tested in step 7, removed from the free space
         in step 8 and stored as the piece's box (so it also affects later collisions and beardifier inflation). The three structures here have the flag
         false (`h = 0`); villages, outposts and abandoned camps have it true (section 6).
      7. Collision: every cell of the shifted `childBox` must be inside the chosen free space (the artifact tests the box shrunk by
         0.25 on every side against the shape; for cell-aligned shapes that is the same as "no cell of the box lies outside the free
         space", inferred). Failing: try the next `C`.
      8. Accept: remove the cells of the shifted `childBox` from the chosen free space (the holder is updated in place).
      9. `gC = rigid(E) ? gP - k : E.groundLevelDelta` (the default delta is 1).
      10. Create the child piece (`E`, shifted position, `gC`, `R`, shifted box, the structure's liquid settings).
      11. Junction records for the beardifier (36-1 section 9.2): let `jy = rigid(P) ? J.pos.y : (rigid(E) ? t + C.pos.y : s + k / 2)`
          (`s` computed on demand). Add to `P`: `(frontPos.x, jy - relY + gP, frontPos.z, k, projection(E))`; add to the child:
          `(J.pos.x, jy - C.pos.y + gC, J.pos.z, -k, projection(P))` (fields: source x, source ground y, source z, delta y, destination
          projection).
      12. Append the child to the piece list. If `depth + 1 <= size`, enqueue `(child, the chosen holder, depth + 1)` with priority
          step 4.4.
      13. Stop with `J` (leave the loops over `C`, `R` and `E`).
   6. If no candidate fits, `J` produces nothing and generation continues with the next `J`.

#### 2.3.1 `canAttach(J, C)`

True when all hold: the facing of `J` is the opposite of the facing of `C`; `J`'s joint type is `rollable`, or the "top" orientations of
`J` and `C` are equal (an `aligned` joint needs the same top direction); and `C` has no name, or `J.target == C.name`. The orientation
property of the jigsaw block state is a front-and-top pair (`down_west` means front down, top west).

### 2.4 Template pools (`StructureTemplatePool`)

A pool record has `elements` (a list of `{element, weight}`, weight 1 to 150) and `fallback` (a pool reference, default the `empty` pool).
The weight-expanded list repeats each element `weight` times in declaration order. `getRandomTemplate(random)` returns `list[nextInt(n)]`
(the empty element when the list is empty). The shuffled list is a copy shuffled with `Util.shuffle`. Pool element kinds used here:

| Kind (`element_type`) | Box | Jigsaw blocks offered | Placement |
|---|---|---|---|
| `single_pool_element` | the rotated template's box at the piece position | the template's jigsaw blocks | section 2.5 |
| `list_pool_element` (ancient city camps and ice box) | the union of its non-empty members' boxes | those of the **first** member only | every member is placed at the piece's position and rotation in list order (a member that fails stops the rest) |
| `feature_pool_element` (ancient city sculk) | a single cell at the piece position (size zero, box minimum equals maximum) | one synthetic jigsaw: facing down, top south, `rollable`, no name, pool `empty`, priorities 0 | the placed feature (with its own placement modifiers) is placed at the piece position with the shared placement random |
| `empty_pool_element` | none | none | nothing |
| `legacy_single_pool_element` (villages, outposts, abandoned camps) | as single | as single | as single, except that the processor list ends with the structure-and-air ignore processor instead of the structure-block ignore at the front (36-3 section 5.2; not re-read here) |

Every element of the three structures here has projection `rigid`; the projection `terrain_matching` (a gravity processor on the
placed blocks, and the surface-following `t` of section 2.3 step 4.4) is not used by them.

### 2.5 Placing a single-pool piece (`SinglePoolElement.place`, `StructureTemplate.placeInWorld`)

When a chunk's decoration reaches the piece (36-1 section 8), `PoolElementStructurePiece.postProcess` ignores the chunk position and
places its element with: the piece position and rotation, the shared **pivot** of 36-1 section 8 step 2, the writable chunk box, the
shared placement `random`, the piece's liquid settings, and "keep jigsaws" false.

Settings built for the template: bounding box = the writable chunk box; rotation = the piece's; known-shape = true; ignore entities =
false; finalize entities = true; liquid settings = the element's override if present, else the piece's; **processors in this order**:

1. `BlockIgnoreProcessor` for `structure_block` (such blocks are not placed).
2. `JigsawReplacementProcessor` (unless "keep jigsaws"): a jigsaw block becomes the block state named by its `final_state` NBT string
   (default `minecraft:air`, parsed as a block-state string); a result of `structure_void` drops the block (nothing is placed there);
   a jigsaw without NBT is left unchanged (logged).
3. The element's processor list, in list order.
4. The projection's processors (none for `rigid`).

`placeInWorld(level, position, pivot, settings, random, flags = 18)`:

1. The blocks of the template's single palette (no template of these families has several palettes) are mapped through
   `processBlockInfos`, in the **loaded list order, not file order** (36-2 section 1.3 and its worked example): at load the blocks are split into
   three groups, (a) no NBT, collision shape a full cube and no dynamic shape, (b) other blocks without NBT, (c) blocks with NBT; each group is sorted by
   y, then x, then z ascending; the list is a, then b, then c. NBT-bearing blocks (chests, jigsaws, spawners, vaults) therefore come last. This order
   fixes the order of the `LootTableSeed` draws of step 2 and the indices the `capped` processor shuffles (example: in `city_center_1` the first NBT block
   is at file index 7951 of 7966, per 36-2). For each block in that order, its position is rotated and offset to the world; **unless** some processor
   reports that it evaluates the entire piece state, blocks outside the writable box are skipped before processing; the block then
   passes through the processors in order, and the first processor that returns nothing removes the block. After all blocks, each
   processor's `finalizeProcessing` runs over the whole list in processor order.
2. For each resulting block inside the writable box: when it has NBT, first place a `barrier` (flag value 820) to clear any old
   container contents; place the block state (mirrored and rotated) with flags 18; when it has NBT and the block entity exists:
   if the block entity is a `RandomizableContainer` (chest, barrel, dispenser, hopper, decorated pot; **not** the brushable block,
   vault or trial spawner), overwrite `LootTableSeed` in the NBT with `random.nextLong()` of the shared placement random, then load
   the NBT into the block entity.
3. Waterlogging: with `apply_waterlogging` the fluid state at every placed position is read first and a fix-up pass keeps water in
   waterloggable blocks and fixes flowing water next to source blocks (36-2 section 5.4); with `ignore_waterlogging` none of that bookkeeping
   runs: template blocks replace whatever fluid was there and carry only the waterlogged state their NBT states.
4. Then block updates and entity placement as in 36-2 sections 5.5 and 5.6.

### 2.6 Pool aliases

`PoolAliasLookup.create(bindings, origin, worldSeed)`: when the list is empty the lookup is the identity. Otherwise `F = LegacyRandom(worldSeed).nextLong()`
(a new generator seeded with the world seed, one draw), the alias generator is `LegacyRandom(Mth.getSeed(origin) XOR F)`, and each binding is resolved
in list order drawing from that one generator. The result maps alias keys to pool keys; `lookup(key)` returns the mapped key, or `key` itself when
unmapped. Aliases apply to the start pool and to the `pool` field of every jigsaw block, never to a fallback pool. Because the origin includes the
sampled start height, the mapping changes with the height draw.

`Mth.getSeed(x, y, z)`: `l = (int)(x * 3129871) XOR (z * 116129781L) XOR y` (the `x` product is computed in 32 bits and widened; the `z` product in 64);
result `(l * l * 42317861L + l * 11L) >> 16` (64-bit wrap, arithmetic shift). `LegacyRandom` and `SingleThreadedRandomSource` are the same
Java linear congruential stream (10 section 2.6); `forkPositional()` consumes one `nextLong()` as the factory seed `F` and `at(x, y, z)` is
`LegacyRandom(Mth.getSeed(x, y, z) XOR F)`.

| Binding `type` | Fields | Resolution (each uses the lookup's generator `r`) |
|---|---|---|
| `direct` | `alias`, `target` | maps `alias` to `target`; no draw |
| `random` | `alias`, `targets` (weighted list of pool keys) | one draw: `n = r.nextInt(totalWeight)`, the first target whose cumulative weight exceeds `n` (list order) |
| `random_group` | `groups` (weighted list; each group is a list of bindings) | one draw picks a group the same way; then each binding of the group is resolved in order (each may draw) |

### 2.7 The processors used by these structures

Shared random sources: **block random** = `LegacyRandom(Mth.getSeed(blockWorldPos))`, created fresh whenever a processor needs one for that block (so two
processors on the same block see the same sequence from its start); **capped random** = the positional generator of `SingleThreadedRandomSource(worldSeed)` taken at the piece's
final position (after the shift of section 2.2 step 12 or section 2.3 step 4.5).

| Processor (`processor_type`) | Fields | Behaviour |
|---|---|---|
| `block_rot` | `integrity` float 0 to 1, optional `rottable_blocks` (block set) | block random `r`; a block in the set (or any block when no set is given) is **removed** (not placed, the existing world block stays) when `r.nextFloat() > integrity`, kept otherwise; blocks outside the set are kept without a draw |
| `rule` | `rules` list | block random created once per block; rules are tried in order; for a rule, the **input predicate** is tested on the template block state, the **location predicate** on the world state at the position, the position predicate on positions; the first rule whose three tests pass replaces the block by `output_state`, with the block entity data from `block_entity_modifier`, and the processing of that processor ends; the input predicate `random_block_match` is true when the block is the given block **and then** `r.nextFloat() < probability` (a draw only for a matching block; draws continue along the same `r` across rules); `tag_match` is true for a block state in the tag (no draw); `always_true` is true |
| `block_entity_modifier` `append_loot` | `loot_table` | the new block entity data is the old data (or empty) plus `LootTable` = the key and `LootTableSeed` = `r.nextLong()` of that block's random |
| `protected_blocks` | `value` (block tag) | the world block at the position is read; when it is in the tag the template block is **not placed**, otherwise kept |
| `capped` | `delegate` (a processor), `limit` (int provider, a constant here) | evaluates the whole piece; works in `finalizeProcessing` over the already processed list: `limit` is sampled with the capped random (`n`, min with the list length); the indices of the list are shuffled (`Util.toShuffledList`: for `i` from the size down to 2, `j = nextInt(i)`, swap `i - 1` and `j`) with the same generator; in that order the delegate's `processBlock` is applied to each block (with the original and the current info) until `n` blocks were **changed** (delegate result present and not equal to the current block, state or NBT); a changed block replaces its list entry |

Tags used (data): `#minecraft:ancient_city_replaceable`, `#minecraft:features_cannot_replace`, `#minecraft:trail_ruins_replaceable`. The first is the
deepslate family plus `gray_wool` (the tool copies it); the second protects `bedrock`, `spawner`, `chest`, `end_portal_frame`, `reinforced_deepslate`,
`trial_spawner` and `vault`; the third is `gravel` only (this version's data; read from the tags in the jar).

Because the capped processor sets the "evaluates the entire piece state" flag, every block of the piece goes through the processors, not only the blocks of the
chunk being decorated. The limit therefore applies to the whole piece and the selection is identical in every chunk that the piece touches (a piece that spans
chunks is decorated chunk by chunk with the same result).

---

## 3. Ancient city

### 3.1 Parameters and the data it uses

| Parameter | Value | Effect |
|---|---|---|
| `start_pool` / `start_jigsaw_name` | the `ancient_city/city_center` pool, `minecraft:city_anchor` | three city centre templates (each 18 x 31 x 41), one drawn uniformly; the piece is placed so that the jigsaw named `city_anchor` (at local 13, 24, 20, front down) sits on the start position |
| `size` | 7 | depth 7 |
| `start_height` | constant -27 | no random draw |
| `project_start_to_heightmap` | absent | the start is not lifted; y is the height value alone (section 2.2 step 11) |
| `max_distance_from_center` | 116 | cell box half-extent 116 on every axis |
| `use_expansion_hack` | false | |
| `step` | `underground_decoration` | placed in that decoration step (36-1 section 8) |
| `terrain_adaptation` | `beard_box` | terrain is carved above and filled below the whole box of each piece (36-1 section 9, bounding box inflated by 12) |
| `biomes` | tag `has_structure/ancient_city` = `minecraft:deep_dark` | the biome at the stub position must be deep dark (the noise biome at the quart cell of `(cx, y0, cz)`, 36-1 section 5.1) |
| `dimension_padding`, `liquid_settings`, `pool_aliases` | absent (zero padding, apply waterlogging, none) | |
| structure set | `random_spread`, spacing 24, separation 8, salt 20083232 | 36-1 section 4.3 |
| `spawn_overrides` | all eight categories present with an empty spawn list and bounding box `full` | section 7 |

### 3.2 Pool graph (behaviour, not rows)

| Pool | Role | Elements (kinds) and processor list |
|---|---|---|
| `city_center` | the start pool | 3 single templates, processor list `ancient_city_start_degradation` |
| `city_center/walls` | the perimeter walls that grow from the four side jigsaws of the centre (jigsaws at each corner of the footprint, front pointing sideways, names `connect_bottom`, `connect_right`, `connect_left`, `connect_top` and the corner variants) | single templates `bottom_*`, `left`, `right`, `top`, corners; `ancient_city_generic_degradation` |
| `walls` and `walls/no_corners` | the wall ring continuing around the city (jigsaw names `connect_wall`) | intact and ruined wall segments with stairs and passages, weights 1 to 4; `ancient_city_walls_degradation` |
| `city/entrance` | the descending entrance paths (`entrance_start`, `entrance_middle` names) | 6 single templates (connector and 5 paths); `ancient_city_generic_degradation` |
| `structures` | buildings, ruins, statues, pillars, camps, ice box, hung on the `connect_structure` jigsaws of the walls | weights: empty 7, six buildings 4 each, ruins and pillars 1 or 2, one `list_pool_element` of the three camps, one `list_pool_element` of the ice box (processor list empty) |
| `sculk` | sculk and shrieker patches on the up-facing `bottom` jigsaws inside buildings | `feature_pool_element` of the placed feature `sculk_patch_ancient_city` weight 6, empty weight 1 |

All fallbacks are `empty`. The pools are consumed by the engine of section 2 with these facts:

1. The four side jigsaws of the centre point outwards from the footprint edge; each wall piece found in `city_center/walls` extends the ring
   (each has jigsaws whose names continue the chain), and the `walls` pools close it. Depth 7 bounds how far the chain goes.
2. The `structures` pool has weight 46 in total in this version's data, with 7 for the empty element (15.2 percent of draws place nothing;
   verify with the loaded record, this is a consistency check, not a constant).
3. `list_pool_element`s place their members at the same position and rotation; the camps are three templates stacked as one piece.
4. A `sculk` feature piece is a single cell one block in front of an up-facing `bottom` jigsaw (the synthetic jigsaw faces down, so the parent's
   front must be up). Such a cell usually lies inside the building's own box, so it is tested against the building's local free space (section
   2.3 step 4.2), not against the global one.

### 3.3 Degradation (processor lists)

| List | Processors in order |
|---|---|
| `ancient_city_start_degradation` (city centre) | `rule` [`deepslate_bricks` to `cracked_deepslate_bricks` at 0.3; `deepslate_tiles` to `cracked_deepslate_tiles` at 0.3; `soul_lantern` to `air` at 0.05], `protected_blocks` (`#features_cannot_replace`). No rot: the centre keeps all its blocks. |
| `ancient_city_generic_degradation` | `block_rot` (integrity 0.95, `#ancient_city_replaceable`), the same `rule` list, `protected_blocks` |
| `ancient_city_walls_degradation` | `block_rot` (0.95, same set), `rule` [the same three, plus `deepslate_tile_slab` to `air` at 0.3, in the order bricks, tiles, tile slab, soul lantern], `protected_blocks` |

Because `block_rot` and `rule` each start from a fresh block random of the same position (section 2.7), the first `nextFloat()` of a
position feeds both: a deepslate brick survives rot when that float is at most 0.95, and then cracks when the same float is below 0.3 (the rule's random
restarts at the same seed, so its first draw for a matching block is that same float). A block whose float is above 0.95 is
rotted away if it is in `#ancient_city_replaceable`.

### 3.4 Loot, sculk and warden interplay

Marking: the per-template counts in sections 3.4, 4.5 and 7.1 (chests, barrels, dispensers, pots, vaults, jigsaw blocks, sculk sensors) are tool output of the scratch NBT decoder (Open question 11) over the structure template files named in the rows, not re-verified by review. They are data and must not be hard-coded.

* **Chests**: 14 of the 15 chest block entities in the templates carry `LootTable` (one has none): `minecraft:chests/ancient_city` in nine templates (13 chests: barracks twice, the
  three chamber templates once each, sauna three times, tall ruins 1 to 4 once, twice, once, once) and `minecraft:chests/ancient_city_ice_box` in the ice box template (section 7).
  At placement each gets `LootTableSeed = random.nextLong()` of the shared placement random (section 2.5 step 2); rolling when the chest is opened
  is 26 section 11.6. The ice box and camp templates are placed through `list_pool_element`s.
* **Other block entities** in the templates (no loot): 157 jigsaw blocks (replaced by `final_state`, which for many is `reinforced_deepslate`,
  `cobbled_deepslate`, a wall block or `structure_void`), comparators, sculk sensors (10), lecterns, furnaces, campfires, two skeleton skulls.
  `reinforced_deepslate` is protected by `#features_cannot_replace`.
* **Sculk patches**: the `sculk` pool's feature `sculk_patch_ancient_city` (35-6 section 8.3) is a sequence: a `sculk_patch`,
  then an overlay that places a sculk catalyst (chance 0.5, needs a sturdy block below) and 1 to 3 sculk shriekers within +/-2 of the origin on
  air with a sturdy face below (parameters are data; the engine is 35-6). The shrieker block state it places has `can_summon = true`, `shrieking = false`, `waterlogged = false`.
* **Warden interplay**: the ancient city has no warden spawn data. A shrieker may respond to a vibration from a player: it raises the player's
  warning level, and at the top level, when `can_summon` is true, the `spawn_wardens` rule is on and the difficulty allows, it spawns a warden
  (31-8 section 6, 30-8 section 6, 20 section 15, game rule 33). The structure suppresses every natural spawn inside its box (all eight
  categories empty, `full` box: the start's adjusted box, inflated by 12 for `beard_box`), so the only warden source in the city is a shrieker.
* **Deep dark restriction**: the only mechanism is the biome tag on the stub position (section 3.1); pieces outside deep dark are possible
  after the check, there is no per-piece biome test.

### 3.5 Terrain adjustment and the vertical start

`beard_box` makes the beardifier (36-1 section 9) add terrain below and carve air above each rigid piece's box (junction records of section
2.3 step 4.11 also feed it). The start height is the constant -27, so the stub (the biome-test position) is always at y = -27, and the start piece is
shifted down by one (section 2.2 step 12): the city centre's bottom is at `-27 - 24 - 1 = -52` when `offset.y = 24`.

---

## 4. Trial chambers

### 4.1 Parameters

| Parameter | Value | Effect |
|---|---|---|
| `start_pool` | `trial_chambers/chamber/end`, no start jigsaw name | two end-corridor templates (each 19 x 20 x 19) chosen uniformly; the piece's minimum corner is placed at the start position |
| `size` | 20 | depth 20 (the deepest allowed) |
| `start_height` | uniform -40 to -20 (one `nextInt(21)` draw) | |
| `max_distance_from_center` | 116 | |
| `dimension_padding` | 10 (bottom and top) | the start piece must satisfy `box.minY >= -54` and `box.maxY <= 309`; every other piece must lie inside the free space of section 2.2 step 15 whose y range is `[max(cy - 116, -54), min(cy + 116, 309)]` |
| `liquid_settings` | `ignore_waterlogging` | section 2.5 step 3 |
| `terrain_adaptation` | `encapsulate` | a rounded shell of terrain around the whole box of every piece (36-1 section 9) |
| `step` | `underground_structures` | |
| `biomes` | tag `has_structure/trial_chambers` | the data lists many overworld biomes (including `dripstone_caves`, `lush_caves` and `sulfur_caves`); the test is at the stub position |
| `pool_aliases` | three entries (section 4.2) | |
| structure set | `random_spread`, spacing 34, separation 12, salt 94251327 | |
| `spawn_overrides` | all eight categories empty, bounding box `piece` | section 7 |

### 4.2 Pool aliases for the spawner variants

The spawner contents are chosen per structure, not per spawner, by aliasing four pool keys that no jigsaw block points to directly as a real pool: the
structure's pools contain no pool named `.../spawner/contents/ranged`, `.../slow_ranged`, `.../melee` or `.../small_melee` (only `contents/breeze`
exists as a real pool). Every spawner connector template has a jigsaw whose `pool` is one of those keys, so the alias bindings decide what it
becomes. Without the bindings those pools are not found (section 2.3 step 4.1) and no spawner would be built.

| Alias key (suffix after `trial_chambers/spawner/contents/`) | Binding kind | Resolves to (suffix after `trial_chambers/spawner/`) |
|---|---|---|
| `ranged` and `slow_ranged` | one `random_group` of three equal-weight groups, each containing two `direct` bindings | group 1: `ranged/skeleton` and `slow_ranged/skeleton`; group 2: `.../stray`; group 3: `.../poison_skeleton`. Both keys always resolve to the same mob |
| `melee` | `random`, three equal targets | `melee/zombie`, `melee/husk`, `melee/spider` |
| `small_melee` | `random`, four equal targets | `small_melee/slime`, `small_melee/cave_spider`, `small_melee/silverfish`, `small_melee/baby_zombie` |

Draw order from the alias generator (section 2.6): the group draw `nextInt(3)`, then the melee draw `nextInt(3)`, then the small-melee draw
`nextInt(4)`. The pool `spawner/contents/breeze` is a real pool and is not aliased.

Each target pool holds one template that contains one `trial_spawner` block entity whose NBT names two configs from the `trial_spawner` registry
by key (`normal_config`, `ominous_config`), for example `minecraft:trial_chamber/melee/zombie/normal` and `.../ominous`; 14 such templates exist, one for each
of the 14 choices (3 melee, 3 ranged, 3 slow ranged, 4 small melee, 1 breeze), and the 28 config files are data. The spawner behaviour and the config
schema are 31-7 section 4 and 44-2 section 4; this document adds only that the config is chosen by the alias, never by the engine. The templates set the
block state `trial_spawner_state = waiting_for_players` and `ominous = false`.

### 4.3 Pool graph (behaviour)

| Pool group | Purpose | Notes on the engine |
|---|---|---|
| `chamber/end` (start), `corridor` | end corridors and the corridor types: entrance (3 variants with chests), atrium, intersection (3), first and second plates, straight slices from `corridor/slices` (weights 1 and 2) | the jigsaws that lead on carry **placement priority** 1 (corridors, spawner connectors) or 2 (`in_connector` of the end piece, so that the big chamber is placed before the corridor) or 3 (the ominous vault) |
| `hallway` | hallway pieces between corridors and chambers | fallback `hallway/fallback` (rubble pieces): at depth `size` and when nothing else fits the fallback list is used; total weight of this pool in this version's data is 1231 with eight chamber templates at 150 each (97.5 percent of draws are chambers; consistency check, read the record) |
| `chambers/end`, `chamber/*` (assembly, eruption, pedestal, slanted, addon, entrance cap) | chamber interiors assembled from quadrants and slices (`center`, `quadrant`, `slice`, `upper_arm`, `lower_arm` ... jigsaws, many `aligned`) | placement priority 1 or 2 on the central jigsaws orders the assembly: centre before slices |
| `spawner/*` | `spawner/all` holds the three connectors (ranged, melee, small melee) at weight 1 each; `spawner/ranged`, `slow_ranged`, `melee`, `small_melee`, `breeze` give a specific connector | each connector's content jigsaw points at an alias key (section 4.2) or at `spawner/contents/breeze` |
| `reward/*` | `reward/all` and `reward/contents/default` give the vault template, `reward/ominous_vault` the ominous one | vaults: section 4.5 |
| `decor/*`, `chests/*`, `dispensers/chamber`, `corridors/addon/*` | pots, beds, candles, barrels, a supply chest, wall and floor dispensers, corridor add-ons | many pools have a large weight on the empty element (for example 22 on empty in `decor`) so most decor jigsaws place nothing |

The tuning that makes the structure fit: `size` 20 with padding 10 and horizontal distance 116. Because every jigsaw whose chosen element does not fit is
simply skipped (section 2.3 step 4.6), a given structure start has a variable number of pieces.

### 4.4 Processors and terrain

* `trial_chambers_copper_bulb_degradation` (used by 50 elements: corridors, intersections, chambers, hallways, entrance cap): `rule` with three rules for
  `waxed_copper_bulb`, in order `random_block_match` 0.1 to `waxed_oxidized_copper_bulb`, 0.33333334 to `waxed_weathered_copper_bulb`, 0.5 to
  `waxed_exposed_copper_bulb`, each with the output properties `lit = true`, `powered = false`; then `protected_blocks` (`#features_cannot_replace`).
  Draws run along one block random: the first float is tested against 0.1, a second one against 0.33333334 only if the first failed, a third against
  0.5. Resulting probabilities: oxidized 0.1, weathered 0.3, exposed 0.3, unchanged 0.3.
* The other 157 elements (spawner, vault, decor, dispenser, chest and corridor add-on templates) have an inline empty processor list: nothing but
  the jigsaw replacement and the structure-block ignore of section 2.5.
* `encapsulate` and `ignore_waterlogging` together with the padding place the structure in solid ground: the shell of terrain is added by the
  terrain stage (36-1 section 9), and the structure's own blocks replace water without waterlogging fix-ups.

### 4.5 Vaults, chests, dispensers, pots and other block entities

The counts below are tool output of the scratch NBT decoder over the trial chambers template files (not re-verified by review); they are data, not constants to hard-code.

| Block entity in templates | Count (block entities) | What it carries | Engine |
|---|---|---|---|
| `vault` | 2 | NBT `config` with `key_item` (`trial_key` or `ominous_trial_key`) and `loot_table` (`chests/trial_chambers/reward` or `.../reward_ominous`); block state `ominous`, `vault_state = inactive` | 31-7 section 5; rolling (set `vault`) 26 section 11.9; the NBT is loaded after the block is set, no `LootTableSeed` overwrite (not a randomizable container) |
| `trial_spawner` | 14 | section 4.2 | 31-7 section 4 |
| `chest` | 12 (all with `LootTable`: entrance, intersection, reward, supply) | `LootTable` | randomizable container: `LootTableSeed` overwritten |
| `barrel` | 4 (3 with `LootTable`: `corridor`, `intersection_barrel`) | `LootTable` | same |
| `dispenser` | 7 (6 with `LootTable`: `dispensers/trial_chambers/chamber` or `.../corridor`) | `LootTable` | same; filled when first triggered |
| `decorated_pot` | 5 (4 with `LootTable`) | `LootTable` of `pots/trial_chambers/corridor` | a decorated pot is a randomizable container here, so its seed is overwritten too; 31-3 |
| `structure_block` | 1 | ignored (the structure block never reaches the world) | section 2.5 step 1 |
| `hopper` | 1 | contents as stored | `HopperBlockEntity` extends `RandomizableContainerBlockEntity`, so it is a randomizable container: its `LootTableSeed` is overwritten with one `random.nextLong()` draw when it has NBT, which shifts the later seeds of the piece (section 2.5 step 2) |
| 834 jigsaw blocks | | replaced by `final_state` | section 2.5 |

---

## 5. Trail ruins

### 5.1 Parameters

| Parameter | Value | Effect |
|---|---|---|
| `start_pool` | `trail_ruins/tower`, no start jigsaw name | tower templates (the first is 5 x 13 x 5), one drawn uniformly; the piece's minimum corner is the start position |
| `size` | 7 | |
| `start_height` | constant -15 | |
| `project_start_to_heightmap` | `WORLD_SURFACE_WG` | the start is lifted by the surface height at the piece centre (section 2.2 step 11) |
| `max_distance_from_center` | 80 | |
| `terrain_adaptation` | `bury` | terrain is added in a rounded shell around each piece so that the ruin is buried (36-1 section 9) |
| `step` | `underground_structures` | |
| `biomes` | tag `has_structure/trail_ruins` (taiga, snowy taiga, old growth pine and spruce taiga, old growth birch forest, jungle) | tested at the stub position, whose y is `-15 + surface` |
| structure set | `random_spread`, spacing 34, separation 8, salt 83469867 | |
| `spawn_overrides` | the empty object (no category keys) | no override |

### 5.2 Buried placement and height

`ySurf = origin.y + firstFreeHeight` where `firstFreeHeight` is the first free y above the `WORLD_SURFACE_WG` height of the piece centre (36-1 section
5.4). Since the start y is -15, `ySurf = surface - 15`, and the start piece bottom is `ySurf - 1 = surface - 16` after the shift of section 2.2 step 12. The tower
is 13 tall, so the tower body is buried. Two jigsaw blocks make the top attach (read from the NBT, tower 1 and tower top 1): the tower's jigsaw at local
(4, 12, 0) has orientation `up_north` (front up), name `tower_bottom_1`, target `tower_top_1`, pool `trail_ruins/tower/tower_top`, joint `aligned`; the tower-top
template (5 x 4 x 5) has its jigsaw at local (4, 0, 0) with orientation `down_north` (front down), name `tower_top_1`, target `tower_bottom_1`, pool
`trail_ruins/tower`, joint `aligned`. The matching of the number N comes from `canAttach` (the parent's target equals the child's name, section 2.3.1), so a
tower N takes only top N. The top (height 4) therefore reaches the surface. The tower also has four horizontal `rollable` jigsaws at local y 1, one per side
(at (0, 1, 2) `west_up`, (2, 1, 0) `north_up`, (2, 1, 4) `south_up`, (4, 1, 2) `east_up`): two named `road_anchor` (targets `road_hall_anchor` and
`large_hall_connector`, pool `tower/additions`), `road_connector` (target `long_road_end`, pool `roads`) and `hall_road` (target `road_spacer`, pool `roads`).
All elements are `rigid`, so every other
piece keeps its vertical relation to its parent (`t = B.minY + k`, section 2.3 step 4.4) and nothing follows the terrain: roads, halls and decor are buried at
the tower's depth, which `bury` then surrounds with terrain.

Pool graph: `tower` (start) offers road and hall additions; `tower/additions` (halls, rooms, large halls), `roads` (road sections and ends, connectors, spacers,
decor anchors), `buildings` and `buildings/grouped` (group halls and rooms), `decor`, and `tower/tower_top`. Names and targets form pairs (`road_anchor` to
`road_hall_anchor`, `hall_room_anchor` to `room_anchor`, `building_anchor` to `road_anchor`, `decor_anchor`); all fallbacks are `empty`. The three tower-top, road and house
processor lists give the archaeology.

### 5.3 Archaeology processors

| List | Used by | Processors in order |
|---|---|---|
| `trail_ruins_houses_archaeology` | tower, additions, buildings, decor (72 elements) | `rule` [`gravel` to `dirt` at 0.2; `gravel` to `coarse_dirt` at 0.1; `mud_bricks` to `packed_mud` at 0.1]; `capped` limit 6 over a `rule` replacing `#trail_ruins_replaceable` by `suspicious_gravel` with `append_loot` `archaeology/trail_ruins_common`; `capped` limit 3 over the same with `archaeology/trail_ruins_rare` |
| `trail_ruins_roads_archaeology` | roads (7 elements) | the same first `rule`; one `capped` limit 2 with `trail_ruins_common` |
| `trail_ruins_tower_top_archaeology` | tower tops (5 elements) | one `capped` limit 2 with `trail_ruins_common` |

Behaviour: the first `rule` decays gravel by independent per-block draws (the first float of each block's random: below 0.2 dirt; otherwise, since draws continue
along one sequence, a second float below 0.1 coarse dirt). Then each `capped` replaces up to its limit of gravel blocks of the whole piece with suspicious gravel
carrying a loot table and a seed. The second `capped` sees the output of the first, whose converted blocks are no longer gravel, so the two caps never
convert the same block: a house-type piece gets at most 6 common and 3 rare suspicious gravel blocks (fewer when the piece has fewer gravel blocks left). Which
gravel blocks are chosen is by the shuffled order of the capped random of the piece position (section 2.7), the same for every chunk the piece touches.

The suspicious gravel's block entity (31-4 section 7) stores the key as `LootTable` and the seed as `LootTableSeed`; the seed is the first `nextLong()` of the
block's own random (section 2.7), and, because the brushable block entity is not a randomizable container, it is not overwritten at placement (section 2.5
step 2). The tables roll with the archaeology set (26 section 11.8).

---

## 6. All jigsaw structures in this version and the parameters they use

The data pack holds 52 structure records: 28 of type `jigsaw`, 24 of other types (buried treasure, desert pyramid, end city, fortress, igloo, jungle
pyramid, mansion, 2 mineshafts, monument, nether fossil, 2 ocean ruins, 7 ruined portals, 2 shipwrecks, stronghold, swamp hut: 36-4 to 36-9). The villages (five records) and the pillager outpost are specified in 36-9 (field use in its section 2.1, start piece in its section 5); the bastion remnant is in
36-8; they are not repeated here. Of the 28 jigsaw records, 3 are the structures of this document, 5 + 1 are 36-9, 1 is 36-8, and the 18 abandoned camps are the
table below (28 = 3 + 6 + 1 + 18).

| Structure (records) | `start_pool` | `size` | `start_height` | Heightmap | Max distance | `step` | Adaptation | Hack | Spawn overrides | Pools and engine features used |
|---|---|---|---|---|---|---|---|---|---|---|
| `abandoned_camp_<biome>` (18 records: bamboo jungle, birch forest, cherry grove, dappled forest, flower forest, forest, meadow, old growth birch forest, old growth pine taiga, old growth spruce taiga, pale garden, savanna, snowy taiga, sparse jungle, swamp, taiga, windswept forest, wooded badlands) | `abandoned_camp/tent/<biome>` | 2 | constant 0 | `WORLD_SURFACE_WG` | 80 | `surface_structures` | `beard_thin` | true | none | one structure set `abandoned_camp` (`random_spread`, spacing 37, separation 8, salt 91231127) with the 18 records at weight 1; per biome a tent pool of 10 `legacy_single_pool_element`s, a camp pool of 49 and tree pools (21 `trees/*` pools, each one `feature_pool_element`) |

How the jigsaw parameters of section 2.1 are used across them, in terms of behaviour:

* `start_height` constant 0 with a heightmap: the start is exactly the surface (camps; villages and outposts per 36-9); a positive constant without a heightmap
  (bastion remnant, 36-8); negative constants (ancient city, trail ruins) or a `uniform` provider without a heightmap (trial chambers).
* `use_expansion_hack` true appears on the surface structures (villages, outposts, camps) and has an effect: the child's box is enlarged as in section 2.3
  step 4.5.6 when the candidate is at most 16 tall (36-3 section 10.4).
* `dimension_padding` and `liquid_settings` appear only on the trial chambers; `pool_aliases` only on the trial chambers; `start_jigsaw_name` only on the ancient
  city. Everything else uses the defaults.
* The `abandoned_camp` structures are new in the data of this artifact; they are plain jigsaw structures with their own 18 biome tags, with no code beyond the
  legacy element (36-3 section 5.2) and the feature element (no `abandoned_camp` class exists in the structure packages). Their pools, loot and processors are data.

---

## 7. Closing checklist: loot tables and spawn overrides

### 7.1 Loot table ids referenced by the structure NBT and processors

| Structure | Loot table id (type) | Where it is attached | Rolled by |
|---|---|---|---|
| ancient city | `minecraft:chests/ancient_city` (chest) | 9 templates, 13 chests | 26 section 11.6 (open or break) |
| ancient city | `minecraft:chests/ancient_city_ice_box` (chest) | the ice box template, 1 chest | same |
| trial chambers | `minecraft:chests/trial_chambers/entrance` | 3 entrance corridor templates (2, 2 and 3 chests) | same |
| trial chambers | `minecraft:chests/trial_chambers/intersection` | the second end corridor, 1 chest | same |
| trial chambers | `minecraft:chests/trial_chambers/intersection_barrel` | 2 intersection templates, 1 barrel each | same |
| trial chambers | `minecraft:chests/trial_chambers/corridor` | the barrel decor template | same |
| trial chambers | `minecraft:chests/trial_chambers/reward` | the first entrance, the rubble and rubble-chamber hallway templates (3 chests) and the normal vault `config` | chest 26 section 11.6; vault 26 section 11.9 |
| trial chambers | `minecraft:chests/trial_chambers/reward_ominous` | the ominous vault `config` | 26 section 11.9 |
| trial chambers | `minecraft:chests/trial_chambers/supply` | the supply chest template | same as chests |
| trial chambers | `minecraft:dispensers/trial_chambers/chamber`, `.../corridor` | 3 and 2 templates | dispenser opening |
| trial chambers | `minecraft:pots/trial_chambers/corridor` | decorated pots (flow, guster, scrape, undecorated) | pot break |
| trial chambers | the `reward_common`, `reward_rare`, `reward_unique` and the three `reward_ominous_*` tables | sub-tables of the two reward tables above (chest tables in the same directory) | via the vault roll |
| trial chambers (spawners) | `spawners/trial_chamber/*` and `spawners/ominous/trial_chamber/*` tables | the trial spawner configs (44-2 section 4.2, 4.8), not the structure NBT | 44-2 section 4.8 |
| trail ruins | `minecraft:archaeology/trail_ruins_common`, `minecraft:archaeology/trail_ruins_rare` | the processor lists of section 5.3 (not the NBT) | 26 section 11.8 |

Each table's contents are data. Table `type` strings (`chest`, `archaeology`, `vault` set) are 26.

### 7.2 Spawn overrides (36-1 section 10 gives the query; 44-2 section 8.3 lists all 52 records)

| Structure | Overrides in the data | Box | Meaning |
|---|---|---|---|
| ancient city | all eight categories (`ambient`, `axolotls`, `creature`, `misc`, `monster`, `underground_water_creature`, `water_ambient`, `water_creature`), each an empty spawn list | `full` | no natural spawn of any category anywhere inside the start's adjusted box (inflated by 12 for `beard_box`) |
| trial chambers | the same eight categories, each empty | `piece` | no natural spawn inside any piece's own box, including all pieces' decor; air gaps between pieces use the biome's list (the structure is encapsulated, so gaps are in solid terrain) |
| trail ruins | the empty object | none | none |
| pillager outpost (for completeness) | `monster`, one entry | `full` | 18 section 7 and 44-2 section 8 |

Cross-references: mob categories and the lookup 18 section 7 and 21 (structure overrides, spawn placement); the warden and shrieker 20 section 15; the trial spawner
engine 44-2 section 4; the gamerule `spawn_wardens` 33.

---

## 8. Worked examples

All random values below were computed with a scratch implementation of the formulas of section 2 (`Mth.getSeed`, the Java LCG, the shuffle); they check the text, they are
not observed game values.

### 8.1 Ancient city start

Chunk (10, -7), `origin = (160, -27, -112)` (constant height, no draw), rotation NONE (the draw is arbitrary), element `city_center_1` (18 x 31 x 41) whose
`city_anchor` jigsaw is at local (13, 24, 20). Were the template placed with its minimum corner at `origin`, the jigsaw would be at `(173, -3, -92)`, so `offset = (13, 24, 20)`, `piecePos = (160 - 13, -27 - 24, -112 - 20) =
(147, -51, -132)`. Box `(147, -51, -132)` to `(164, -21, -92)` (minimum corner plus size minus one). Centre `cx = (164 + 147) / 2 = 155`, `cz = (-92 + -132) / 2 = -112`.
No heightmap: `ySurf = -51`; shift `= -51 - (-51 + 1) = -1`, so the box becomes y -52 to -22 and the piece position y -52. Stub position `(155, -51 + 24, -112) = (155, -27, -112)`:
the biome is tested at y = -27, which must be deep dark.

### 8.2 Trail ruins start

Chunk origin `(x0, z0)`, `origin.y = -15`, rotation NONE, element `tower_1` (5 x 13 x 5), no start jigsaw: `offset = 0`, `piecePos = (x0, -15, z0)`, box
`(x0, -15, z0)` to `(x0 + 4, -3, z0 + 4)`, centre `(x0 + 2, z0 + 2)`. Suppose (illustrative input, not a read value) the first free surface height there is 72: `ySurf = -15 + 72 = 57`; shift `= 57 - (-15 + 1) = 71`:
box y 56 to 68 (bottom is `ySurf - 1 = 56`). The stub y is `57 + 0 = 57`. The tower top (front up, aligned) is placed with `k = relY - C.pos.y + 1`: the tower's jigsaw is at local
y 12 (world 68, `relY = 12`) and the top template's jigsaw at its local y 0, so `k = 12 - 0 + 1 = 13` and `t = 56 + 13 = 69`: the top's box is y 69 to 72, reaching the surface.

### 8.3 Pool aliases of a trial chamber

World seed 0, start at `(0, -30, 0)`. `F = LegacyRandom(0).nextLong() = -4962768465676381896`; `Mth.getSeed(0, -30, 0) = 581147`; the alias generator is
`LegacyRandom(581147 XOR F)`. Its first three draws are `nextInt(3) = 0`, `nextInt(3) = 0`, `nextInt(4) = 1`. So group 1 (skeleton): `contents/ranged` becomes
`ranged/skeleton` and `contents/slow_ranged` becomes `slow_ranged/skeleton`; melee: `melee/zombie`; small melee: `small_melee/cave_spider`.

### 8.4 Copper bulb degradation

A `waxed_copper_bulb` at `(0, 0, 0)`: the block random `LegacyRandom(Mth.getSeed(0, 0, 0))` gives floats 0.730968, 0.831441, 0.240536. The first rule (0.1) fails,
the second (0.33333334) fails, the third (0.5) succeeds: the block becomes `waxed_exposed_copper_bulb` with `lit = true`, `powered = false`. At `(5, -40, 7)` the floats are
0.418422, 0.575941, 0.468312: again the third rule succeeds.

### 8.5 Ancient city rot and cracking

Deepslate bricks at `(160, -45, -112)` to `(167, -45, -112)` (eight consecutive x): the first float of each block's random is 0.402315, 0.00861, 0.228814, 0.426746, 0.034039,
0.070538, 0.602948, 0.990674. With generic degradation: the last (0.9907 > 0.95) is rotted away; x = 161, 162, 164, 165 (below 0.3) become `cracked_deepslate_bricks`; x = 160, 163, 166 stay
`deepslate_bricks`.

### 8.6 Capped suspicious gravel

World seed 0, a piece at `(100, -20, 100)` with 5 blocks in its processed list. The capped random is `LegacyRandom(Mth.getSeed(100, -20, 100) XOR F)` with `F` the first draw of
`LegacyRandom(0)`. The shuffle of the indices 0 to 4 gives order `[0, 1, 3, 2, 4]`; the delegate is tried on block 0, then 1, then 3, and so on until the limit is reached or the
list is exhausted. A suspicious gravel's seed at `(1000, 60, -2000)` is `LegacyRandom(Mth.getSeed(1000, 60, -2000)).nextLong() = -3470385864024313068` (`getSeed` is 40551906004761).

### 8.7 Child placement arithmetic

Parent `P` with `B.minY = 56`, `gP = 1`, rigid; a jigsaw at world y 68 facing up: `relY = 12`, `f.stepY = 1`. Child `E` rigid whose matching jigsaw is at local y 0: `k = 12 - 0 + 1 = 13`,
`t = 56 + 13 = 69`; the child's box is shifted so that its `minY` is 69 (its own local y 0 is the block above the parent's jigsaw), `gC = gP - k = -12`. Junction records:
`jy = J.pos.y = 68`; parent gets `(frontX, 68 - 12 + 1 = 57, frontZ, 13, rigid)`; child gets `(J.x, 68 - 0 + (-12) = 56, J.z, -13, rigid)`.

---

## 9. Validation

1. Counts in the jar (archive file entries without directories): structure records 52 (28 jigsaw, 24 other); template pools: 7 ancient city, 7 trail ruins, 47 trial chambers;
   structure NBT: 58, 84, 191; processor lists of these three: 3 (ancient city), 3 (trail ruins), 1 (trial chambers); `trial_spawner` configs 28 (14 variants, normal and ominous);
   pool weights between 1 and 150.
2. A start for any of the three never has a piece outside the free-space box; every piece has `box.minY >= -54` in the trial chambers; the start piece's `box.minY = ySurf - 1`.
3. For the ancient city the stub y is -27 for every rotation and chunk; for the trial chambers it is the sampled y; for trail ruins it is `surface - 15`.
4. Pool resolution: a jigsaw with the pool `.../spawner/contents/melee` resolves to exactly one of three pools, identical for all jigsaws of that structure start; `ranged` and `slow_ranged`
   always name the same mob.
5. The queue processes a priority-3 jigsaw before a priority-2 one before a priority-1 one before priority 0, and equal priorities in the order they were created.
6. At depth equal to `size` only fallback pools provide elements: for the trial chambers' `hallway` pool that is the rubble pieces.
7. Processors: the probabilities of section 4.4 (0.1, 0.3, 0.3, 0.3) hold over many positions; a block never gets two replacements from one `rule` processor; `block_rot` removes about 5 percent
   of rottable blocks; a house piece has at most 6 common and 3 rare suspicious gravel blocks.
8. A chest, barrel, dispenser or pot from these structures has a `LootTableSeed` that changes with the world seed and chunk; a suspicious gravel and a vault keep the seed from their processor
   or NBT.
9. The ancient city's chests: 14 of the 15 chest block entities carry one of the two ids of section 7.1; the trial chambers' vaults carry the two reward tables; no trail ruins block entity carries a loot
   table in the NBT (only the processors add them).
10. No natural spawn of any category inside the ancient city box (`full`) nor inside any trial chamber piece box (`piece`); none changed for the trail ruins.

---

## Open questions

1. (Closed.) `use_expansion_hack` was re-read in `Placer.tryPlacingChildren`: the box is extended in place and the enlarged box is the collision, free-space and piece box
   (section 2.3 step 4.5.6). Not verified by comparing generated output.
2. `DimensionPadding` and `MaxDistance` were read: an omitted `bottom` or `top` is 0 (lenient optional, non-negative int), the int form sets both; the padding check
   is skipped only for the shared zero instance and otherwise uses `minY + bottom` and `maxY - top` as in section 2.2 step 13. `MaxDistance.horizontal` is int 1 to 128 and
   `vertical` is an optional int 1 to `DimensionType.Y_SIZE` with default `Y_SIZE`; `Y_SIZE` is `2^BlockPos.PACKED_Y_LENGTH - 32` = 4064 (closed, section 2.1: the
   static initialisers of `BlockPos` and `DimensionType` were read).
3. The collision test was read: the shifted (possibly enlarged) child box, as an AABB shrunk by 0.25 on every side, must have an empty "only second" difference against the free-space
   shape; the free space is built from the AABB `[cx-h, cx+h+1) x [max(cy-v, minY+bottom), min(cy+v+1, maxY+1-top)) x [cz-h, cz+h+1)` minus the start box, so the cell-aligned
   reading of section 2.2 step 15 holds (reported by the reviewer from the artifact; step 15 here was not re-read for the half-open upper bounds).
4. The waterlogging pass, block entity load order and entity placement are owned by 36-2 sections 5.4 to 5.6 and were not re-read here.
5. (Closed by 36-3 section 5.2.) `legacy_single_pool_element` is the plain element with the structure-and-air ignore processor appended instead of the structure-block ignore
   at the front. The abandoned camp templates, pools and loot were not examined beyond structure records, pool counts and the set (section 6).
6. (Closed.) Villages and outposts are 36-9, the bastion remnant is 36-8; their rows were removed from section 6. 36-1 does not record the split; that is not an error here.
7. Sections 2.2 to 2.5 remain a restatement of 36-2 and 36-3. They were reconciled in this pass; the two differences found are fixed above. Any future difference is a bug
   in one of them; 36-2 and 36-3 win.
8. The random-number algorithms (`nextInt(bound)`, `nextFloat`, `nextLong`) are cited from 10 section 2.6, not re-read here; the examples of section 8 use the standard Java LCG formulas, which
   10 section 2.6 defines. `RandomSource.create(seed)` is the legacy LCG and `createThreadLocalInstance(seed)` the single-threaded LCG; both were read to have identical seeding and
   `forkPositional`.
9. Position and rotation handling inside `StructureTemplate.getBoundingBox`, `getJigsaws` and `calculateRelativePosition` (how a rotation maps local positions and sizes) is cited from 36-2
   section 3 and 36-1 section 6.4 and not re-read; section 8.1 and 8.2 use the unrotated case.
10. The heights used (overworld min y -64, max y 319) are from 10 section 7; the paddings and bounds of section 4.1 follow from them.
11. The per-template counts and jigsaw positions, orientations and final states quoted (city anchor at local (13, 24, 20), the tower jigsaws of section 5.2) were read from the NBT files with a scratch
    decoder; the tool, not this document, is their source.
12. The `trial_chambers` biome tag contains a biome (`sulfur_caves`) and the structure `abandoned_camp` set exists in this artifact; whether 04 and 46 list the corresponding registry entries was not
    checked here.
13. The brushable block entity uses the keys `LootTable` and `LootTableSeed` (read), and is not a randomizable container (read from its class declaration); `DecoratedPotBlockEntity` is a randomizable
    container and `HopperBlockEntity` a `RandomizableContainerBlockEntity` (read). That the same holds for every block entity type in all 333 templates was checked only by listing block entity ids.
