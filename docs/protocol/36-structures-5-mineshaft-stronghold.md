# 36 Structures, part 5: mineshaft and stronghold (the recursive code-generated corridor structures)

| Item | Value |
|---|---|
| Covers | The two structures whose pieces are assembled recursively by code and whose blocks are written by code: the **mineshaft** (`MineshaftStructure`, `MineshaftPieces`: room, corridor, crossing, stairs; types `normal` and `mesa`) and the **stronghold** (`StrongholdStructure`, `StrongholdPieces`: start, straight, chest corridor, filler corridor, left and right turn, room crossing, five-way crossing, prison hall, library, portal room, straight and spiral stairs, the weighted piece table, the small-door types). For each: the start (what the structure's own `findGenerationPoint` does), the random-number order, the assembly algorithm, every piece's box, fields, saved keys, children and block layout, the vertical placement, the chests, spawners and minecarts, and test vectors. |
| Does not cover | Anything shared by every structure (registries, element schemas, placement engines and the concentric-ring list, start creation, the piece base class, `BoundingBox`, the block-writing helpers, chunk integration, the decoration step) is in [36-structures-1-model-placement-starts.md](36-structures-1-model-placement-starts.md) and is cited as "36-1 section N", not repeated. Rows of data (the `structure`, `structure_set` and tag JSON, loot tables, biome tags) are not tabulated: the extraction tool copies them (22, 23); this document names the files and states the few values the code and the data agree on. Loot rolling is 26. Block-entity behaviour of the spawner, chest and end portal frame is 31 and 24. The eye of ender is 25 section 6.3 and 21 section 8.12. Other structures are sibling parts (36-2 to 36-4, 36-6 to 36-10). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.level.levelgen.structure.structures.{MineshaftStructure, MineshaftStructure$Type, MineshaftPieces and its nested classes, StrongholdStructure, StrongholdPieces and its nested classes}` and of `StructurePiece`, `StructurePiecesBuilder`, `BoundingBox`, `ChunkGeneratorStructureState`, `WorldgenRandom`, `Direction$Plane`, `Util.getRandom`, `RandomSource`; and of the data files `data/minecraft/worldgen/structure/{mineshaft, mineshaft_mesa, stronghold}.json`, `worldgen/structure_set/{mineshafts, strongholds}.json` and the tag files named in section 1. A small stack-summarising script was used to read the bytecode; no execution of the artifact. |
| Operator decisions | Standard Minecraft content is the target; the tool extracts the data pack and this document specifies the engines (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"; design map `docs/design/README.md` GAP-12b, rule R7). |
| Status | Written by the reader for round RS20, part 5. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not
verified)" marks something not read; both are listed in the Open questions (none of the latter was needed). Every value, ordering
and block layout below was read from the artifact in this round. References use "10 section 2.6" for other documents and
"36-1 section N" for part 1.

**Notation.** `box(x0,y0,z0 .. x1,y1,z1)` is an inclusive box in the **piece-local** frame of 36-1 section 6.4 (local x along the
piece's width, local z along its depth, local y up from the piece's box floor; world conversion by the orientation table there)
unless a table says "world". A piece whose orientation is **null** (the mineshaft room and crossing) has no local frame: its
coordinates are absolute and `worldY(y) = y`. "Place" means `placeBlock` (36-1 section 6.5: skipped outside the chunk write box and
where `canBeReplaced` is false; the state is mirrored and rotated by the piece's mirror and rotation, so every directional state below
is written **as it is in the NORTH-oriented frame**). "Gen box(skip)" means the `generateBox` form of 36-1 section 6.5 with
fixed states; "Gen sel(skip)" the selector form. `AIR*` is cave air (`Blocks.CAVE_AIR`). "Draw" is one call on the piece's `random`
(`WorldgenRandom` over the Java LCG, 10 section 2.6; `nextInt(n)`, `nextBoolean`, `nextFloat`, `nextLong` as defined there).

---

## 1. Data, placement and what the code receives

| Fact | Value | Read from |
|---|---|---|
| Structure set `mineshafts` | placement `random_spread`, `spacing 1`, `separation 0`, `salt 0`, `frequency 0.004`, `frequency_reduction_method legacy_type_3`; two entries, `mineshaft` weight 1 and `mineshaft_mesa` weight 1 | `worldgen/structure_set/mineshafts.json` |
| Structure `mineshaft` | type `mineshaft`, `mineshaft_type normal`, biomes `#minecraft:has_structure/mineshaft`, `spawn_overrides {}`, `step underground_structures`, no `terrain_adaptation` (none) | `worldgen/structure/mineshaft.json` |
| Structure `mineshaft_mesa` | type `mineshaft`, `mineshaft_type mesa`, biomes `#minecraft:has_structure/mineshaft_mesa`, same step | `worldgen/structure/mineshaft_mesa.json` |
| Structure set `strongholds` | placement `concentric_rings`, `distance 32`, `spread 3`, `count 128`, `preferred_biomes #minecraft:stronghold_biased_to`, `salt 0`; one entry `stronghold` weight 1 | `worldgen/structure_set/strongholds.json` |
| Structure `stronghold` | type `stronghold`, biomes `#minecraft:has_structure/stronghold` (which is `#minecraft:is_overworld`), `spawn_overrides {}`, `step surface_structures`, `terrain_adaptation bury` | `worldgen/structure/stronghold.json` |
| Tags used by code | `#minecraft:mineshaft_blocking` (biome tag, contents `deep_dark`), `#minecraft:structure/eye_of_ender_located` (contents `stronghold`), `#minecraft:structure/mineshaft` (both mineshafts), `#minecraft:structure/on_mineshaft_maps` (contents: `minecraft:mineshaft` only; consumer and search are Open question 15) | `tags/worldgen/...` |
| Chest loot tables | `abandoned_mineshaft` (mineshaft chests and chest minecarts), `stronghold_corridor`, `stronghold_crossing`, `stronghold_library` | `loot_table/chests/*.json` |
| Built-in datapack variant | `abandoned_mineshaft.json` exists a second time at `data/minecraft/datapacks/trade_rebalance/data/minecraft/loot_table/chests/abandoned_mineshaft.json` (the optional built-in `trade_rebalance` datapack, found by listing the jar; contents not compared with the base table). The extraction tool must copy it as a separate datapack file; which table applies depends on whether that datapack is enabled (Open question 14) | jar listing |

How the data meets the engines: with `spacing 1` and `separation 0` every chunk is a potential start chunk (36-1 section 4.3 draws
`nextInt(1)` twice, always 0). `legacy_type_3` then keeps a chunk when, after `setLargeFeatureSeed(levelSeed, cx, cz)`,
`nextDouble() < (double) 0.004f` (36-1 section 4.4); `0.004f` widened to double is `0.004000000189989805`. The surviving chunk
picks `mineshaft` or `mineshaft_mesa` among the structures whose biome tag accepts the biome at the start position (36-1 section 5.2).
The stronghold's chunks are the 128 ring chunks of 36-1 section 4.6 (worked ring numbers in section 4.1 below). Mineshaft pieces are
placed in the `underground_structures` decoration step, strongholds in `surface_structures` (36-1 section 8); strongholds additionally
bury terrain (`bury`, the beardifier of 36-1 section 9), mineshafts do not adapt terrain. Biome membership of the tags is data.

---

## 2. Mineshaft

### 2.1 The two types (`MineshaftStructure$Type`)

| Id (ordinal) | Name | Wood (log) | Planks | Fence |
|---|---|---|---|---|
| 0 | `normal` | oak log | oak planks | oak fence |
| 1 | `mesa` | dark oak log | dark oak planks | dark oak fence |

The serialised name is the `mineshaft_type` field of the structure JSON. Every mineshaft piece stores its type under the integer key
`MST` (the ordinal; loading maps an out-of-range value to ordinal 0). The "wood" state is the default state of the log block (axis
`y`), used for support pillars; the "planks" state for floors and beams; the "fence" state for posts. Nothing else differs between the
types except the vertical placement of section 2.3.

### 2.2 Constants and the piece-type ids

`MineshaftPieces` constants: `MAX_DEPTH = 8`, `MAGIC_START_Y = 50`, default shaft width 3, height 3, length 5 (a corridor section),
`MAX_PILLAR_HEIGHT = 20`, `MAX_CHAIN_HEIGHT = 50`. Piece ids (36-1 section 2.4; the artifact's code strings are `MSCorridor`, `MSCrossing`, `MSRoom`, `MSStairs`, and for the stronghold `SHCC`, `SHFC`, `SH5C`, `SHLT`, `SHLi`, `SHPR`, `SHPH`, `SHRT`, `SHRC`, `SHSD`, `SHStart`, `SHS`, `SHSSD`; the registration helper lower-cases them with `Locale.ROOT`, read, so the saved `id` is the lower-case namespaced key): `mscorridor` 0, `mscrossing` 1, `msroom` 2,
`msstairs` 3.

### 2.3 Start: `MineshaftStructure.findGenerationPoint`

The context random is the one seeded for the chunk (36-1 section 5.1: legacy `WorldgenRandom` with `setLargeFeatureSeed(levelSeed,
chunkX, chunkZ)`).

1. **One `nextDouble()` is drawn and discarded** (the structure mirrors the placement's `legacy_type_3` test).
2. Stub base position `P = (chunk.middleBlockX, 50, chunk.minBlockZ)`, that is `(16*cx + 8, 50, 16*cz)` (note: x is the chunk's
   middle, z its minimum).
3. Build the pieces (`generatePiecesAndAdjust`, below), which returns a vertical shift `dy`.
4. The stub position is `P + (0, dy, 0)`. The stub holds the **ready** builder (read: it is built from `Either.right(builder)`, the
   second form of 36-1 section 5.3), so all draws of steps 1 to 3 happen **before** the biome check of 36-1 section 5.3, which then
   tests the noise biome at the stub position; they are spent even when the check fails. (The stronghold, section 3.2, supplies a
   consumer instead, which runs after its check.)

**`generatePiecesAndAdjust`:**

1. Create the root `MineShaftRoom(genDepth 0, random, chunk.getBlockX(2), chunk.getBlockZ(2), type)`, that is at `(16*cx + 2, 16*cz + 2)`;
   add it to the builder.
2. Call `room.addChildren(room, builder, random)` directly (the recursion of section 2.4 runs depth first from here).
3. Vertical placement by type, with `seaLevel = chunkGenerator.getSeaLevel()`:
   * **normal:** `dy = builder.moveBelowSeaLevel(seaLevel, chunkGenerator.getMinY(), random, 10)` (36-1 section 6.6). The pieces move
     down so that the whole structure's top lies at most `seaLevel - 10`, with the draw `random.nextInt(cap - top)` when there is slack.
   * **mesa:** `c` = centre of the builder's union box (36-1 section 6.3, `getCenter`); `h = chunkGenerator.getBaseHeight(c.x, c.z,
     WORLD_SURFACE_WG, heightAccessor, randomState)` (10); `target = seaLevel` if `h <= seaLevel`, else `target = seaLevel +
     random.nextInt(h - seaLevel + 1)` (`Mth.randomBetweenInclusive(random, seaLevel, h)`); `dy = target - c.y`; `offsetPiecesVertically(dy)`.
     So a mesa mineshaft is centred between sea level and the surface height at its centre, an offset that can put it above ground.
4. Return `dy`.

### 2.4 The recursive assembly

**`generateAndAddPiece(parent, builder, random, x, y, z, direction, depth)`**: returns null when `depth > 8`; returns null when
`|x - parent.box.minX| > 80` or `|z - parent.box.minZ| > 80` (the distance limit is to the **parent** piece's minimum corner, not the
root); otherwise `piece = createRandomShaftPiece(builder, random, x, y, z, direction, depth + 1, parent.type)`; if non-null:
`builder.addPiece(piece)` then **immediately** `piece.addChildren(parent, builder, random)` (so assembly is depth first, each
subtree finishing before the next sibling is tried, and a new piece is visible to later collision tests as soon as it is added);
return the piece. The type of the new piece is the parent's type.

**`createRandomShaftPiece`:** one draw `r = nextInt(100)`.

| `r` | Piece | If the box search fails |
|---|---|---|
| 80 to 99 (20 %) | crossing: `MineShaftCrossing.findCrossing` then the constructor | return null (no fallback) |
| 70 to 79 (10 %) | stairs: `MineShaftStairs.findStairs` | return null |
| 0 to 69 (70 %) | corridor: `MineShaftCorridor.findCorridorSize`, constructor with `random` | return null |

The `genDepth` stored on the new piece is the `depth + 1` passed down. All children of a piece are tried with the piece's own
`genDepth` (as `depth`), except the corridor's side branches which pass `genDepth + 1` (below), so the effective depth limit is
`MAX_DEPTH = 8` counted in `generateAndAddPiece` calls.

All four `find*` helpers build a candidate box from the table of the piece, translate it by `(x, y, z)`, and succeed only if
`builder.findCollisionPiece(box)` (36-1 section 6.6) finds no piece; the room has no search (it is the root).

### 2.5 `MineShaftRoom` (piece id `msroom`, orientation null)

| Item | Value |
|---|---|
| Fields | `childEntranceBoxes` (list of boxes) |
| Saved keys | `Entrances`: list of boxes (the box codec of 36-1 section 6.3, six ints each); `MST` |
| Box (constructor draws, in this order) | `(x, 50, z)` to `(x + 7 + nextInt(6), 54 + nextInt(6), z + 7 + nextInt(6))`: three draws, x extent first. So the room is 8 to 13 wide in x, 5 to 10 high (`y` 50 to 54..59), 8 to 13 deep in z. |
| `move(dx, dy, dz)` | moves the box and every entrance box |

**`addChildren`:** `depth = genDepth`; `h = ySpan - 3 - 1`, raised to 1 if it is 0 or less (`ySpan = maxY - minY + 1`, so `h` is `1 + (the y draw)`).
Four sweeps in the fixed order **north, south, west, east**. In each sweep an offset `i` starts at 0 and the loop is: `i += nextInt(span)`
(span = the room's x span for north and south, z span for west and east); stop if `i + 3 > span`; try the child; `i += 4`; repeat while `i < span`.
(Order inside one iteration: the `i` draw, then the child's own draws.) The child call is `generateAndAddPiece(room, builder, random, ...,
depth)` with:

| Sweep | x | y | z | Direction | Entrance box recorded when a child exists (child box `c`) |
|---|---|---|---|---|---|
| north | `minX + i` | `minY + nextInt(h) + 1` | `minZ - 1` | NORTH | `(c.minX, c.minY, room.minZ) .. (c.maxX, c.maxY, room.minZ + 1)` |
| south | `minX + i` | `minY + nextInt(h) + 1` | `maxZ + 1` | SOUTH | `(c.minX, c.minY, room.maxZ - 1) .. (c.maxX, c.maxY, room.maxZ)` |
| west | `minX - 1` | `minY + nextInt(h) + 1` | `minZ + i` | WEST | `(room.minX, c.minY, c.minZ) .. (room.minX + 1, c.maxY, c.maxZ)` |
| east | `maxX + 1` | `minY + nextInt(h) + 1` | `minZ + i` | EAST | `(room.maxX - 1, c.minY, c.minZ) .. (room.maxX, c.maxY, c.maxZ)` |

The `nextInt(h)` for `y` is drawn for every attempt that passes the `i + 3 > span` test, before the child is created.

**`postProcess`:**
1. If `isInInvalidLocation` (section 2.9) is true, place nothing.
2. Gen box(no skip) `(minX, minY + 1, minZ .. maxX, min(minY + 3, maxY), maxZ)` with `AIR*`: world coordinates (orientation null).
3. For each entrance box `e`: Gen box `(e.minX, e.maxY - 2, e.minZ .. e.maxX, e.maxY, e.maxZ)` with `AIR*`.
4. `generateUpperHalfSphere(minX, minY + 4, minZ .. maxX, maxY, maxZ, AIR*, skipAir false)` (36-1 section 6.5).

The room has no floor, no supports and no loot.

### 2.6 `MineShaftCorridor` (piece id `mscorridor`, orientation set)

| Item | Value |
|---|---|
| Fields | `hasRails`, `spiderCorridor`, `hasPlacedSpider` (booleans), `numSections` (int) |
| Saved keys | `hr`, `sc`, `hps`, `Num`; `MST` |
| Constructor draws, in order | `hasRails = (nextInt(3) == 0)`; then **only if not `hasRails`**: `spiderCorridor = (nextInt(23) == 0)`, else false. `numSections = zSpan / 5` for a NORTH or SOUTH piece, `xSpan / 5` otherwise (integer division). |

**`findCorridorSize`** (candidate): `len = nextInt(3) + 2` (2 to 4 sections), then try `len`, `len - 1`, ... down to 1: the local box
is `L = 5 * len` long: NORTH `(0,0,-(L-1) .. 2,2,0)`, SOUTH `(0,0,0 .. 2,2,L-1)`, WEST `(-(L-1),0,0 .. 0,2,2)`, EAST `(0,0,0 .. L-1,2,2)`;
translate by `(x, y, z)`; the first length with no collision is used; if none, null. (The box is 3 wide, 3 high, `L` long; the
direction table is the switch of `MineshaftPieces$1`: NORTH 1, SOUTH 2, WEST 3, EAST 4.)

**`addChildren`:** `depth = genDepth`, `r = nextInt(4)`, `d = orientation`. If `d` is null nothing happens. Otherwise **one forward or lateral
child** by `r` (each child call is `generateAndAddPiece(this, builder, random, x, y, z, dir, depth)` with `y = minY - 1 + nextInt(3)`, the
draw made when that branch is taken):

| Orientation | `r` 0 or 1 | `r` 2 | `r` 3 |
|---|---|---|---|
| NORTH | `(minX, y, minZ - 1)` direction `d` | `(minX - 1, y, minZ)` WEST | `(maxX + 1, y, minZ)` EAST |
| SOUTH | `(minX, y, maxZ + 1)` direction `d` | `(minX - 1, y, maxZ - 3)` WEST | `(maxX + 1, y, maxZ - 3)` EAST |
| WEST | `(minX - 1, y, minZ)` direction `d` | `(minX, y, minZ - 1)` NORTH | `(minX, y, maxZ + 1)` SOUTH |
| EAST | `(maxX + 1, y, minZ)` direction `d` | `(maxX - 3, y, minZ - 1)` NORTH | `(maxX - 3, y, maxZ + 1)` SOUTH |

Then, **only if `depth < 8`**, side branches along the corridor: for a NORTH or SOUTH piece, `i` from `minZ + 3` while `i + 3 <= maxZ`,
step 5: `s = nextInt(5)`; `s = 0` gives a child at `(minX - 1, minY, i)` WEST, `s = 1` a child at `(maxX + 1, minY, i)` EAST, any other `s`
nothing; both with depth `depth + 1`. For an EAST or WEST piece, `i` from `minX + 3` while `i + 3 <= maxX`, step 5: `s = 0` gives
`(i, minY, minZ - 1)` NORTH, `s = 1` gives `(i, minY, maxZ + 1)` SOUTH, depth `depth + 1`. (One draw `s` per step whether or not a child results.)

**`postProcess`** (let `len = 5 * numSections - 1`, the last local z; `planks` and `fence` and `wood` from the type):
1. If `isInInvalidLocation`, return.
2. Gen box(no skip) `box(0,0,0 .. 2,1,len)` `AIR*`.
3. `generateMaybeBox(chance 0.8, box(0,2,0 .. 2,2,len), AIR*, AIR*, skipAir false, requireInterior false)`: the ceiling row is opened
   in 80 % of cells (36-1 section 6.5: one `nextFloat` per cell in y, x, z loop order, a cell is processed when the draw is at most 0.8).
4. If `spiderCorridor`: `generateMaybeBox(chance 0.6, box(0,0,0 .. 2,1,len), edge COBWEB, fill AIR*, skipAir false, requireInterior true)`
   (every cell of that two-layer box is an edge cell, so cobweb fills 60 % of the interior cells).
5. For each section `k = 0 .. numSections - 1`, `z = 2 + 5k`, in this order:
   1. `placeSupport(0, 0, z, 2, 2)` (section 2.7);
   2. eight `maybePlaceCobWeb` calls (section 2.8), all at local y 2: `(0,2,z-1)`, `(2,2,z-1)`, `(0,2,z+1)`, `(2,2,z+1)` with chance 0.1, then
      `(0,2,z-2)`, `(2,2,z-2)`, `(0,2,z+2)`, `(2,2,z+2)` with chance 0.05;
   3. `if nextInt(100) == 0`: `createChest(2, 0, z - 1, abandoned_mineshaft)` (the minecart form, section 2.10);
   4. `if nextInt(100) == 0`: `createChest(0, 0, z + 1, abandoned_mineshaft)`;
   5. if `spiderCorridor` and not `hasPlacedSpider`: `sz = (z - 1) + nextInt(3)`; `p = worldPos(1, 0, sz)`; if `p` is inside the write box and
      `isInterior(1, 0, sz)`: set `hasPlacedSpider = true`, `setBlock(p, spawner, flags 2)`, and if the block entity is a spawner,
      `setEntityId(cave_spider, random)` (31 section 7).
6. Floor: for `x` 0 to 2, for `z` 0 to `len`: `setPlanksBlock(planks, x, -1, z)` (section 2.7).
7. `placeDoubleLowerOrUpperSupport(0, -1, 2)`; if `numSections > 1`: `placeDoubleLowerOrUpperSupport(0, -1, len - 2)`.
8. If `hasRails`: for `z` 0 to `len`: let `b = getBlock(1, -1, z)`; if `b` is not air and `b` renders solid: chance = 0.7 if `isInterior(1, 0, z)` else 0.9;
   `maybeGenerateBlock(chance, (1, 0, z), rail with shape north_south)`.

### 2.7 Supports and floors (corridor helpers)

* **`placeSupport(level, box, x0, y0, z, y1, x1)`** called as `(0, 0, z, 2, 2)`, so `x0 = 0`, `y1 = 2`, `x1 = 2`: proceeds only if
  `isSupportingBox(x0, x1, y1, z)` (below). Then, in order: Gen box `(x0, y0, z .. x0, y1 - 1, z)` of the fence state with `west = true`
  and `AIR*` as fill (a post on the west wall, local y 0 to 1); the same at `x1` with `east = true`; then one draw `nextInt(4)`:
  **if it is 0** two separate plank blocks at `(x0, y1, z)` and `(x1, y1, z)`; **otherwise** a plank beam Gen box `(x0, y1, z .. x1, y1, z)`
  followed by `maybeGenerateBlock(0.05, (x0 + 1, y1, z - 1), wall torch facing SOUTH)` and `maybeGenerateBlock(0.05, (x0 + 1, y1, z + 1),
  wall torch facing NORTH)` (local frame).
* **`isSupportingBox(level, box, x0, x1, y, z)`:** true iff for every `x` from `x0` to `x1` the block `getBlock(x, y + 1, z)` is **not** air
  (there is a ceiling above the beam).
* **`setPlanksBlock(level, box, state, x, y, z)`:** if `isInterior(x, y, z)` is false do nothing; else `p = worldPos(x, y, z)`; if the block at `p`
  is **not** face-sturdy on its up face, `setBlock(p, state, 2)` (no `canBeReplaced` test, no box test beyond `isInterior`'s own).
* **`placeDoubleLowerOrUpperSupport(level, box, x, y, z)`:** if `getBlock(x, y, z)` is the planks block of the type, `fillPillarDownOrChainUp(wood, x, y, z)`;
  then if `getBlock(x + 2, y, z)` is the planks block, `fillPillarDownOrChainUp(wood, x + 2, y, z)`.
* **`fillPillarDownOrChainUp(level, state, x, y, z, box)`:** does nothing when `worldPos(x,y,z)` is outside the box. Otherwise, with `Y0` the world y of the start cell: (1) look down for up to 20 cells (never below `minY + 2`) through cells that are "free" (`isReplaceableByStructures` and not lava); the first non-free cell whose up face is sturdy gets a pillar of `state` filling every cell from just above it to `Y0 - 1`; (2) otherwise look up for up to 50 cells (never reaching `maxY`) through free cells; the first non-free cell that can hang a chain (its down face supports a centre, and it is not a falling block) gets the type's fence state at `Y0 + 1` and iron chain (default state) from `Y0 + 2` up to just below that cell; (3) otherwise nothing. A downward hit wins over an upward one, and when both are possible in the same step the downward is tested first. Writes use flags 2. Worked example: a plank at `Y0 = 40` with free air to y 36 and a stone floor at y 35 gets wood at y 36 to 39; with no floor within 20 cells and a stone ceiling at y 46 it gets a fence at y 41 and chain at y 42 to 45.

### 2.8 Cobwebs

`maybePlaceCobWeb(level, box, random, chance, x, y, z)`: if `isInterior(x, y, z)` and `random.nextFloat() < chance` (draw only when interior) and `hasSturdyNeighbours(x, y, z, 2)`,
place cobweb. `hasSturdyNeighbours` counts, over the six directions in the order DOWN, UP, NORTH, SOUTH, WEST, EAST (`Direction.values`),
the neighbours of the world position that are inside the write box and whose block is face-sturdy towards the cell; it returns true as soon as the count reaches 2.

### 2.9 `isInInvalidLocation` (every mineshaft piece's first test) and `canBeReplaced`

Let `W` be the chunk write box and `B` the piece box. `x0 = max(B.minX - 1, W.minX)`, `y0 = max(B.minY - 1, W.minY)`, `z0 = max(B.minZ - 1, W.minZ)`,
`x1 = min(B.maxX + 1, W.maxX)`, `y1 = min(B.maxY + 1, W.maxY)`, `z1 = min(B.maxZ + 1, W.maxZ)`. The piece is **invalid** (nothing placed in this chunk) when:

1. the biome at the integer midpoint `((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2)` is in `#minecraft:mineshaft_blocking`; or
2. any block on the six faces of the clipped box is a **liquid** (`BlockState.liquid()`): the scan order is the y0 and y1 layers over all x, z; then the z0 and z1 faces over all x, y; then the x0 and x1 faces over all z, y.

`MineShaftPiece.canBeReplaced`: false when the existing block (at the cell, or air outside the write box) is the planks block, the wood block, the fence block of the piece's type,
or an iron chain; true otherwise. So a piece never overwrites the planks, logs, fences and chains of its own type that are already there (a mesa piece does overwrite oak blocks and the reverse).

### 2.10 `MineShaftCorridor.createChest`: chest minecarts

This override replaces the base `createChest` for corridor chests. Arguments: local `(x, y, z)` and a loot table key. Let `p = worldPos(x, y, z)`.
It succeeds only if `p` is inside the write box, the block at `p` is air, and the block below `p` is not air. Then:

1. `shape = nextBoolean() ? north_south : east_west` (one draw, `true` gives north_south); place a rail with that shape at `p` (flags via `placeBlock`).
2. Create an entity of type `chest_minecart` with spawn reason chunk generation; if created: set its initial position to `(p.x + 0.5, p.y + 0.5, p.z + 0.5)`, set its
   loot table to the key with seed `random.nextLong()` (second draw), add it to the level.
3. Return true.

(When it fails, no draw is made.) Entities and minecart data: 21, 45.

### 2.11 `MineShaftCrossing` (piece id `mscrossing`, orientation null)

| Item | Value |
|---|---|
| Fields | `isTwoFloored` (bool), `direction` (the entry direction) |
| Saved keys | `tf`; `D` (direction, the legacy 2D data value of 36-1 section 6.7, default SOUTH); `MST` |
| Constructor | `direction` is the construction direction; `isTwoFloored = (box.ySpan > 3)`. No random. |

**`findCrossing`:** `h = (nextInt(4) == 0) ? 6 : 2` (so a quarter of crossings are 7 high, two-floored); local box by direction: NORTH `(-1,0,-4 .. 3,h,0)`,
SOUTH `(-1,0,0 .. 3,h,4)`, WEST `(-4,0,-1 .. 0,h,3)`, EAST `(0,0,-1 .. 4,h,3)`; translate by `(x,y,z)`; null on collision. (5 by 5 footprint.)

**`addChildren`** (`depth = genDepth`; every child is `generateAndAddPiece(this, builder, random, x, y, z, dir, depth)`): lower level, in the listed order,
by `direction`:

| `direction` | Children (x, y, z, dir) in order |
|---|---|
| NORTH | `(minX+1, minY, minZ-1, N)`, `(minX-1, minY, minZ+1, W)`, `(maxX+1, minY, minZ+1, E)` |
| SOUTH | `(minX+1, minY, maxZ+1, S)`, `(minX-1, minY, minZ+1, W)`, `(maxX+1, minY, minZ+1, E)` |
| WEST | `(minX+1, minY, minZ-1, N)`, `(minX+1, minY, maxZ+1, S)`, `(minX-1, minY, minZ+1, W)` |
| EAST | `(minX+1, minY, minZ-1, N)`, `(minX+1, minY, maxZ+1, S)`, `(maxX+1, minY, minZ+1, E)` |

If `isTwoFloored`, then four upper-level children, each guarded by its **own** `nextBoolean()` (all four draws are made, in this order, whatever the results), at
`y = minY + 4`: `(minX+1, y, minZ-1, N)`, `(minX-1, y, minZ+1, W)`, `(maxX+1, y, minZ+1, E)`, `(minX+1, y, maxZ+1, S)`.

**`postProcess`** (world coordinates, `planks` of the type): return if `isInInvalidLocation`. If two-floored: Gen box `(minX+1, minY, minZ .. maxX-1, minY+2, maxZ)`, `(minX, minY, minZ+1 .. maxX, minY+2, maxZ-1)`,
`(minX+1, maxY-2, minZ .. maxX-1, maxY, maxZ)`, `(minX, maxY-2, minZ+1 .. maxX, maxY, maxZ-1)`, `(minX+1, minY+3, minZ+1 .. maxX-1, minY+3, maxZ-1)`, all `AIR*`. Otherwise two boxes:
`(minX+1, minY, minZ .. maxX-1, maxY, maxZ)` and `(minX, minY, minZ+1 .. maxX, maxY, maxZ-1)`, `AIR*`. Then four support pillars at `(minX+1, minZ+1)`, `(minX+1, maxZ-1)`, `(maxX-1, minZ+1)`,
`(maxX-1, maxZ-1)`: `placeSupportPillar(x, minY, z, maxY)` = if `getBlock(x, maxY + 1, z)` is not air, Gen box `(x, minY, z .. x, maxY, z)` planks (fill `AIR*`, but a one-column box
has only edge cells). Then the floor: for `x` `minX` to `maxX`, `z` `minZ` to `maxZ`: `setPlanksBlock(planks, x, minY - 1, z)`.

### 2.12 `MineShaftStairs` (piece id `msstairs`, orientation set)

Saved keys: `MST` only. No fields. No random in the constructor.

**`findStairs`:** local box by direction: NORTH `(0,-5,-8 .. 2,2,0)`, SOUTH `(0,-5,0 .. 2,2,8)`, WEST `(-8,-5,0 .. 0,2,2)`, EAST `(0,-5,0 .. 8,2,2)`; translate by `(x,y,z)`; null on collision.
(3 wide, 8 high, 9 long; the stairs descend away from the entry.)

**`addChildren`:** one child in the piece's own direction: NORTH `(minX, minY, minZ-1)`, SOUTH `(minX, minY, maxZ+1)`, WEST `(minX-1, minY, minZ)`, EAST `(maxX+1, minY, minZ)`, direction = the orientation, depth `genDepth`.

**`postProcess`:** return if `isInInvalidLocation`. Gen box(no skip) `box(0,5,0 .. 2,7,1)` `AIR*`; `box(0,0,7 .. 2,2,8)` `AIR*`; then for `i` 0 to 4:
`box(0, 5 - i - (i < 4 ? 1 : 0), 2 + i .. 2, 7 - i, 2 + i)` `AIR*`. (A diagonal air tunnel; no blocks are placed, there are no rails, supports or stairs.)

### 2.13 Loot, spawners, summary of mineshaft random draws

Chests exist only as chest minecarts (section 2.10), 1 % per side per corridor section, loot `abandoned_mineshaft`, rolled by 26 when the minecart is opened. The only spawner is the
cave spider spawner of a spider corridor (one per such corridor, 1 in 23 of non-rail corridors). Draw order inside one `postProcess` is the order of the numbered steps above. `postProcess` runs once per chunk the piece touches, with the
shared per-structure `random` of that chunk (36-1 section 8: seeded once per structure per chunk, every piece touching the chunk drawing from it in list order); cells outside the chunk's write
box are skipped by `placeBlock` but their draws (`generateMaybeBox`, cobweb and torch chances) are still consumed.

---

## 3. Stronghold

### 3.1 Placement recap and ring sizes

Placement is `concentric_rings` (36-1 section 4.6) with `distance 32`, `spread 3`, `count 128`. The ring sequence follows from that rule: ring `r` (0 based) has `S_r` positions, `S_0 = 3`,
`S_{r+1} = S_r + (2 * S_r) / (r + 2)` (integer division), additionally capped by `128 - i` at the moment the ring completes. The result is the ring sizes
**3, 6, 10, 15, 21, 28, 36, 9** (sum 128: the eighth ring is cut by the cap to 10 and only 9 of its positions are reached). The unjittered ring radius, in chunks, is `4 * 32 + 32 * r * 6 = 128 + 192 r`
(ring 0: 128 chunks, ring 7: 1472), jittered by `(nextDouble - 0.5) * 80`, that is by up to 40 chunks either way. Draw order per position: radius jitter `nextDouble`, then the fork `nextLong`; and once per completed ring one extra `nextDouble() * 2 pi` is added to the running angle after that ring's last position (36-1 section 4.6 step 2.6), so the radius of the first position of ring `r + 1` follows one more draw than a within-ring step. The start chunk of each stronghold is the ring chunk chosen by the biome search
of 36-1 section 4.6.1 (a chunk whose biome is in `stronghold_biased_to`, else the raw ring chunk).

### 3.2 Start: `StrongholdStructure.findGenerationPoint` and `generatePieces`

The stub position is `(chunk.minBlockX, 0, chunk.minBlockZ)` (`ChunkPos.getWorldPosition`); the biome check of 36-1 section 5.3 tests the biome at that position (`#is_overworld`). The builder consumer then runs
`generatePieces`, which **retries** until a portal room exists:

1. `attempt = 0`. Repeat:
   1. `builder.clear()`.
   2. Reseed the context random with `setLargeFeatureSeed(levelSeed + attempt, chunkX, chunkZ)`, then `attempt += 1`. (The value added is the attempt number **before** the increment: the first
      attempt uses `levelSeed + 0`, the second `levelSeed + 1`, and so on. Read: the counter is loaded, then incremented, then widened.)
   3. `StrongholdPieces.resetPieces()` (section 3.3).
   4. Create `StartPiece(random, chunk.getBlockX(2), chunk.getBlockZ(2))`, that is at `(16*cx + 2, 16*cz + 2)`, add it to the builder, and call `start.addChildren(start, builder, random)`.
   5. While `start.pendingChildren` is not empty: `idx = random.nextInt(pending.size())`; remove that element; call `piece.addChildren(start, builder, random)`. (Pieces are expanded in a **random** order; each new
      piece appended by `generateAndAddPiece` joins `pendingChildren`.)
   6. `builder.moveBelowSeaLevel(seaLevel, chunkGenerator.getMinY(), random, 10)` (36-1 section 6.6).
2. The loop ends when the builder is not empty **and** `start.portalRoomPiece` is not null. There is no attempt cap in the artifact.

Because the retry reseeds from `levelSeed + attempt`, a world seed fixes the number of attempts and the layout.

### 3.3 The weighted piece table (`StrongholdPieces`)

`STRONGHOLD_PIECE_WEIGHTS` is built once with 11 entries (class, weight, `maxPlaceCount`; a `maxPlaceCount` of 0 means unlimited). `resetPieces()` clears the working list `currentPieces`, sets every entry's `placeCount` to 0, adds all 11 in this
order, and clears `imposedPiece`:

| # | Piece class | Weight | Max count | Extra condition (`doPlace(depth)`) |
|---|---|---|---|---|
| 0 | `Straight` | 40 | unlimited | |
| 1 | `PrisonHall` | 5 | 5 | |
| 2 | `LeftTurn` | 20 | unlimited | |
| 3 | `RightTurn` | 20 | unlimited | |
| 4 | `RoomCrossing` | 10 | 6 | |
| 5 | `StraightStairsDown` | 5 | 5 | |
| 6 | `StairsDown` | 5 | 5 | |
| 7 | `FiveCrossing` | 5 | 4 | |
| 8 | `ChestCorridor` | 5 | 4 | |
| 9 | `Library` | 10 | 2 | `depth > 4` |
| 10 | `PortalRoom` | 20 | 1 | `depth > 5` |

Total weight of the full table is 145. `PieceWeight.doPlace(depth)` is true when `maxPlaceCount == 0` or `placeCount < maxPlaceCount`, and (for Library and PortalRoom) `depth` exceeds the listed bound. `isValid()` is the
count test alone. `updatePieceWeight()` recomputes `totalWeight` as the sum of the weights of every entry in `currentPieces` and returns true iff some entry has `maxPlaceCount > 0` and `placeCount < maxPlaceCount`.

### 3.4 Choosing the next piece (`generatePieceFromSmallDoor`)

Inputs: the start piece `S`, builder, random, the candidate entry position `(x, y, z)`, direction, `depth` (already incremented by the caller).

1. If `updatePieceWeight()` is false (no limited entry has quota left), return null. (So generation ends once all limited pieces are used up; unlimited pieces alone never keep it going.)
2. If `imposedPiece` is set: build that class's piece with the factory of section 3.5, clear `imposedPiece`; if the piece exists return it (no count changes).
3. Up to **5 tries**, each: `v = random.nextInt(totalWeight)`; walk `currentPieces` in order subtracting each weight from `v`; at the first entry where `v < 0`:
   * if `!entry.doPlace(depth)` or the entry equals `S.previousPiece`: abandon this try (next try, a new draw);
   * else build the piece with the factory; if it exists: `entry.placeCount += 1`, `S.previousPiece = entry`, and if `!entry.isValid()` remove the entry from `currentPieces`; return the piece;
   * if the factory returned null: continue the walk with the **next entry** (`v` stays negative, so the next entry also qualifies).
4. If all 5 tries fail: `box = FillerCorridor.findPieceBox(...)`; if `box != null` and `box.minY > 1` return `new FillerCorridor(depth, box, direction)`; otherwise null.

(`previousPiece` prevents the same class twice in a row, across the whole structure in call order, not per branch.)

**`generateAndAddPiece(S, builder, random, x, y, z, direction, depth)`:** null if `depth > 50`; null if `|x - S.box.minX| > 112` or `|z - S.box.minZ| > 112`; else `piece = generatePieceFromSmallDoor(..., depth + 1)`; if
non-null: `builder.addPiece(piece)`, append it to `S.pendingChildren`; return it. (Unlike the mineshaft, the new piece is **not** expanded here: it waits in the pending list for the random pick of section 3.2.) The piece's `genDepth` is `depth + 1`; its children
call with the piece's `genDepth`.

### 3.5 The factories (`findAndCreatePieceFactory`) and the shared piece rules

Each class's `createPiece(builder, random, x, y, z, direction, genDepth)` computes `box = orientBox(x, y, z, offX, offY, offZ, width, height, depth, direction)` (36-1 section 6.3) and returns the piece only if
`isOkBox(box)` (**`box.minY > 10`**) and `builder.findCollisionPiece(box)` is null; **otherwise null with no draw consumed** (the constructor, which draws, is not called). The parameters:

| Class | `offX, offY, offZ` | `width x height x depth` | Constructor draws (in order) |
|---|---|---|---|
| `Straight` | -1, -1, 0 | 5 x 5 x 7 | `entryDoor = nextInt(5)` (below); `leftChild = (nextInt(2) == 0)`; `rightChild = (nextInt(2) == 0)` |
| `PrisonHall` | -1, -1, 0 | 9 x 5 x 11 | `entryDoor` |
| `LeftTurn` | -1, -1, 0 | 5 x 5 x 5 | `entryDoor` |
| `RightTurn` | -1, -1, 0 | 5 x 5 x 5 | `entryDoor` |
| `RoomCrossing` | -4, -1, 0 | 11 x 7 x 11 | `entryDoor`; `type = nextInt(5)` |
| `StraightStairsDown` | -1, -7, 0 | 5 x 11 x 8 | `entryDoor` |
| `StairsDown` | -1, -7, 0 | 5 x 11 x 5 | `entryDoor`; `isSource = false` |
| `FiveCrossing` | -4, -3, 0 | 10 x 9 x 11 | `entryDoor`; `leftLow = nextBoolean`; `leftHigh = nextBoolean`; `rightLow = nextBoolean`; `rightHigh = (nextInt(3) > 0)` |
| `ChestCorridor` | -1, -1, 0 | 5 x 5 x 7 | `entryDoor` |
| `Library` | -4, -1, 0 | 14 x 11 x 15, **else** 14 x 6 x 15 (the 11-high box is tried first; on `isOkBox` or collision failure the 6-high box is tried; both failing gives null) | `entryDoor`; `isTall = (box.ySpan > 6)` (no draw) |
| `PortalRoom` | -4, -1, 0 | 11 x 8 x 16 | none (no random parameter, no entry door) |
| `FillerCorridor` (separate `findPieceBox`, below) | -1, -1, 0 | 5 x 5 x variable | none |

All draws happen only after the box test passed. **`entryDoor`** = `randomSmallDoor`: `n = nextInt(5)`; `0` or `1` gives OPENING, `2` WOOD_DOOR, `3` GRATES, `4` IRON_DOOR (so OPENING is 40 %, the others 20 %).
Small door types by ordinal: OPENING 0, WOOD_DOOR 1, GRATES 2, IRON_DOOR 3; saved under `EntryDoor` through a legacy enum codec (encoding not traced, Open question 5).

**`FillerCorridor.findPieceBox(builder, random, x, y, z, direction)`:** `box = orientBox(x, y, z, -1, -1, 0, 5, 5, 4, direction)`; `c = findCollisionPiece(box)`; if null return null. If `c.box.minY == box.minY`:
for `d = 2` down to 1: `b = orientBox(x, y, z, -1, -1, 0, 5, 5, d, direction)`; if `c.box` does not intersect `b` return `orientBox(..., 5, 5, d + 1, ...)`; if the loop ends return null. (A corridor that
plugs the gap up to the blocking piece.) The piece: `FillerCorridor(genDepth, box, direction)`, `steps` = the box's z span for NORTH or SOUTH, else its x span; saved key `Steps`.

**Child helpers** (methods of `StrongholdPiece`; `a`, `b` are the two offsets; each returns `StrongholdPieces.generateAndAddPiece(S, builder, random, ..., this.genDepth)`, null if the orientation is null):

| Helper | NORTH | SOUTH | WEST | EAST |
|---|---|---|---|---|
| Forward `(a, b)` | `(minX + a, minY + b, minZ - 1)` dir `d` | `(minX + a, minY + b, maxZ + 1)` dir `d` | `(minX - 1, minY + b, minZ + a)` dir `d` | `(maxX + 1, minY + b, minZ + a)` dir `d` |
| Left `(a, b)` | `(minX - 1, minY + a, minZ + b)` WEST | same as NORTH | `(minX + b, minY + a, minZ - 1)` NORTH | same as WEST |
| Right `(a, b)` | `(maxX + 1, minY + a, minZ + b)` EAST | same as NORTH | `(minX + b, minY + a, maxZ + 1)` SOUTH | same as WEST |

(`d` is the piece's own orientation. For Forward, `a` is the offset along the width, `b` the height; for Left and Right, `a` is the **height** offset and `b` the offset along the depth axis **measured from the
box's minimum corner in world terms**, not in the local frame. "Left" always means the local `x = 0` side and "Right" the local maximum-x side (read from the orientation table of 36-1 section 6.4).)

**`SmoothStoneSelector`** (used by every `Gen sel` call): `next(random, x, y, z, isEdge)`: if not an edge cell, the selected state is cave air (no draw); if an edge cell, `f = nextFloat()`:
`f < 0.2` cracked stone bricks; `f < 0.5` mossy stone bricks; `f < 0.55` infested stone bricks; otherwise stone bricks. Probabilities: 20 %, 30 %, 5 %, 45 %. Initial selected state: cave air.

**`generateSmallDoor(level, random, box, type, x, y, z)`** (the door occupies local x to x+2, y to y+2, at depth z; "SB" is stone bricks; `placeBlock` each):

| Type | Blocks |
|---|---|
| OPENING | Gen box(no skip) `(x, y, z .. x+2, y+2, z)` `AIR*` |
| WOOD_DOOR | SB at `(x,y)`, `(x,y+1)`, `(x,y+2)`, `(x+1,y+2)`, `(x+2,y+2)`, `(x+2,y+1)`, `(x+2,y)` (all at depth z); oak door (default state) at `(x+1, y, z)`, its `half = upper` copy at `(x+1, y+1, z)` |
| GRATES | `AIR*` at `(x+1, y, z)` and `(x+1, y+1, z)`; iron bars with `west` at `(x,y)` and `(x,y+1)`; iron bars with `east` and `west` at `(x,y+2)`, `(x+1,y+2)`, `(x+2,y+2)`; iron bars with `east` at `(x+2,y+1)` and `(x+2,y)` |
| IRON_DOOR | the seven SB blocks of WOOD_DOOR; iron door (default state) at `(x+1, y, z)` and its `half = upper` copy at `(x+1, y+1, z)`; stone button facing NORTH at `(x+2, y+1, z+1)`; stone button facing SOUTH at `(x+2, y+1, z-1)` |

### 3.6 `StartPiece` and `StairsDown`

`StartPiece` extends `StairsDown` with `isSource = true`, orientation `Plane.HORIZONTAL.getRandomDirection(random)` (one draw `nextInt(4)` into the array NORTH, EAST, SOUTH, WEST), no entry-door draw (entry door is OPENING),
box `makeBoundingBox(x, 64, z, direction, 5, 11, 5)` (36-1 section 6.1: for a NORTH or SOUTH piece `(x, 64, z .. x+4, 74, z+4)`; for WEST or EAST the same footprint, 5 by 5), `genDepth 0`. Extra fields (not
saved): `pendingChildren` (list), `previousPiece`, `portalRoomPiece`. `getLocatorPosition()` returns the portal room's box centre when `portalRoomPiece` is set, else the start's own centre. (No caller of
`getLocatorPosition` exists in this artifact, see section 3.10.)

`StairsDown.addChildren`: if `isSource`, **set `imposedPiece` to the `FiveCrossing` class** (so the first piece after the start is always a five-way crossing, created without drawing a table index); then
`Forward(1, 1)`. Saved key `Source`.

### 3.7 Pieces: layout of each class

All stone is "SB" (stone bricks) when written explicitly. `Gen sel(skip)` = shell with the selector; the shell of the eleven rooms below uses `skipAir true` ("skip") except the portal room. Doors listed use
`generateSmallDoor`. Torch states are wall torches, `facing` in the local frame. The saved keys not listed are only the base keys (`id`, `BB`, `O`, `GD`) and `EntryDoor` (every stronghold piece except portal room, filler corridor
and the start).

**`Straight`** (keys: `Left`, `Right`, `EntryDoor`): children `Forward(1, 1)`; if `leftChild` `Left(1, 2)`; if `rightChild` `Right(1, 2)`. Layout: Gen sel(skip) `box(0,0,0 .. 4,4,6)`; door `entryDoor` at `(1,1,0)`; OPENING at `(1,1,6)`; torches
facing EAST at `(1,2,1)` and `(1,2,5)`, facing WEST at `(3,2,1)` and `(3,2,5)`, each by `maybeGenerateBlock(0.1)` in the order `(1,2,1)`, `(3,2,1)`, `(1,2,5)`, `(3,2,5)`; if `leftChild` Gen box `(0,1,2 .. 0,3,4)` `AIR*`; if `rightChild`
Gen box `(4,1,2 .. 4,3,4)` `AIR*`.

**`ChestCorridor`** (keys: `Chest`, `EntryDoor`): children `Forward(1, 1)`. Layout: Gen sel(skip) `box(0,0,0 .. 4,4,6)`; door `entryDoor` at `(1,1,0)`; OPENING at `(1,1,6)`; Gen box `(3,1,2 .. 3,1,4)` SB; stone brick slabs (bottom) at `(3,1,1)`, `(3,1,5)`,
`(3,2,2)`, `(3,2,4)`; slabs at `(2,1,z)` for `z` 2 to 4; then if not `hasPlacedChest` and the world position of `(3,2,3)` is inside the write box: `hasPlacedChest = true`, `createChest((3,2,3), stronghold_corridor)`.

**`FillerCorridor`** (key `Steps`): for `z` 0 to `steps - 1`: SB at `(0..4, 0, z)`; for `y` 1 to 3: SB at `(0,y,z)` and `(4,y,z)`, `AIR*` at `(1..3,y,z)`; SB at `(0..4, 4, z)`. (Placed block by block; no random.)

**`LeftTurn`** and **`RightTurn`** (`EntryDoor`): `LeftTurn.addChildren`: NORTH or EAST orientation: `Left(1, 1)`, else `Right(1, 1)`; `RightTurn`: NORTH or EAST: `Right(1, 1)`, else `Left(1, 1)`.
Layout (both): Gen sel(skip) `box(0,0,0 .. 4,4,4)`; door `entryDoor` at `(1,1,0)`; for `LeftTurn` Gen box `(0,1,1 .. 0,3,3)` `AIR*` when the orientation is NORTH or EAST, `(4,1,1 .. 4,3,3)` otherwise; `RightTurn` the opposite
(`(4,1,1 .. 4,3,3)` for NORTH or EAST, `(0,1,1 .. 0,3,3)` otherwise).

**`RoomCrossing`** (`Type`, `EntryDoor`): children `Forward(4, 1)`, `Left(1, 4)`, `Right(1, 4)`. Layout: Gen sel(skip) `box(0,0,0 .. 10,6,10)`; door `entryDoor` at `(4,1,0)`; Gen box `AIR*` `(4,1,10 .. 6,3,10)`, `(0,1,4 .. 0,3,6)`,
`(10,1,4 .. 10,3,6)`; then by `type`:

| `type` | Contents |
|---|---|
| 0 | SB at `(5,1,5)`, `(5,2,5)`, `(5,3,5)`; wall torches facing WEST at `(4,3,5)`, EAST at `(6,3,5)`, SOUTH at `(5,3,4)`, NORTH at `(5,3,6)`; bottom smooth-stone slabs at `(4,1,4)`, `(4,1,5)`, `(4,1,6)`, `(6,1,4)`, `(6,1,5)`, `(6,1,6)`, `(5,1,4)`, `(5,1,6)` |
| 1 | for `k` 0 to 4: SB at `(3,1,3+k)`, `(7,1,3+k)`, `(3+k,1,3)`, `(3+k,1,7)`; SB at `(5,1,5)`, `(5,2,5)`, `(5,3,5)`; water (default state) at `(5,4,5)` |
| 2 | for `k` 1 to 9: cobblestone at `(1,3,k)`, `(9,3,k)`; for `k` 1 to 9: cobblestone at `(k,3,1)`, `(k,3,9)`; cobblestone at `(5,1,4)`, `(5,1,6)`, `(5,3,4)`, `(5,3,6)`, `(4,1,5)`, `(6,1,5)`, `(4,3,5)`, `(6,3,5)`; for `k` 1 to 3: cobblestone at `(4,k,4)`, `(6,k,4)`, `(4,k,6)`, `(6,k,6)`; wall torch (default facing) at `(5,3,5)`; for `k` 2 to 8: oak planks at `(2,3,k)`, `(3,3,k)`, and at `(4,3,k)`, `(5,3,k)`, `(6,3,k)` only when `k <= 3` or `k >= 7`, and `(7,3,k)`, `(8,3,k)`; ladders facing WEST at `(9,1,3)`, `(9,2,3)`, `(9,3,3)`; `createChest((3,4,8), stronghold_crossing)` |
| 3 or 4 | nothing more |

**`FiveCrossing`** (keys `leftLow`, `leftHigh`, `rightLow`, `rightHigh`, `EntryDoor`): `a = 3`, `b = 5`; if the orientation is WEST or NORTH: `a = 5`, `b = 3` (`8 - 3`, `8 - 5`). Children in order: `Forward(5, 1)`; if `leftLow` `Left(a, 1)`; if `leftHigh` `Left(b, 7)`;
if `rightLow` `Right(a, 1)`; if `rightHigh` `Right(b, 7)`. Layout: Gen sel(skip) `box(0,0,0 .. 9,8,10)`; door `entryDoor` at `(4,3,0)`; air boxes `AIR*`: if `leftLow` `(0,3,1 .. 0,5,3)`; if `rightLow` `(9,3,1 .. 9,5,3)`; if `leftHigh`
`(0,5,7 .. 0,7,9)`; if `rightHigh` `(9,5,7 .. 9,7,9)`; always `(5,1,10 .. 7,3,10)`. Then Gen sel (no skip) boxes: `(1,2,1 .. 8,2,6)`, `(4,1,5 .. 4,4,9)`, `(8,1,5 .. 8,4,9)`, `(1,4,7 .. 3,4,9)`, `(1,3,5 .. 3,3,6)`; bottom smooth
stone slabs (Gen box, fill the same state) `(1,3,4 .. 3,3,4)`, `(1,4,6 .. 3,4,6)`; Gen sel(no skip) `(5,1,7 .. 7,1,8)`; slabs `(5,1,9 .. 7,1,9)`, `(5,2,7 .. 7,2,7)`, `(4,5,7 .. 4,5,9)`, `(8,5,7 .. 8,5,9)`; **double** smooth stone slabs
`(5,5,7 .. 7,5,9)`; wall torch facing SOUTH at `(6,5,6)`. (36-1 section 6.5 order for the loops is y outermost, then x, then z.)

**`PrisonHall`** (`EntryDoor`): children `Forward(1, 1)`. Layout: Gen sel(skip) `box(0,0,0 .. 8,4,10)`; door `entryDoor` at `(1,1,0)`; Gen box `AIR*` `(1,1,10 .. 3,3,10)`; Gen sel(no skip) `(4,1,1 .. 4,3,1)`, `(4,1,3 .. 4,3,3)`, `(4,1,7 .. 4,3,7)`, `(4,1,9 .. 4,3,9)`;
then for `y` 1 to 3, in this order: iron bars (north and south connected) at `(4,y,4)`; (north, south, east) at `(4,y,5)`; (north, south) at `(4,y,6)`; (west, east) at `(5,y,5)`, `(6,y,5)`, `(7,y,5)`; iron bars (north, south) at `(4,3,2)` and `(4,3,8)`;
iron doors facing WEST: lower at `(4,1,2)`, upper half at `(4,2,2)`, lower at `(4,1,8)`, upper half at `(4,2,8)`.

**`StraightStairsDown`** (`EntryDoor`): children `Forward(1, 1)`. Layout: Gen sel(skip) `box(0,0,0 .. 4,10,7)`; door `entryDoor` at `(1,7,0)`; OPENING at `(1,1,7)`; for `k` 0 to 5: cobblestone stairs facing SOUTH at `(1..3, 6 - k, 1 + k)`, and when `k < 5` SB at `(1..3, 5 - k, 1 + k)`.

**`StairsDown`** (`EntryDoor`, `Source`): children as in section 3.6 (`Forward(1,1)`). Layout: Gen sel(skip) `box(0,0,0 .. 4,10,4)`; door `entryDoor` at `(1,7,0)` (for the start piece the door type is OPENING); OPENING at `(1,1,4)`; then SB and smooth-stone slabs
(bottom) as a spiral, in order: SB `(2,6,1)`; SB `(1,5,1)`; slab `(1,6,1)`; SB `(1,5,2)`; SB `(1,4,3)`; slab `(1,5,3)`; SB `(2,4,3)`; SB `(3,3,3)`; slab `(3,4,3)`; SB `(3,3,2)`; SB `(3,2,1)`; slab `(3,3,1)`; SB `(2,2,1)`; SB `(1,1,1)`; slab `(1,2,1)`;
SB `(1,1,2)`; slab `(1,1,3)`.

**`Library`** (`Tall`, `EntryDoor`): no `addChildren` (dead end). `H = 11` if `isTall` else 6. Layout, in order: Gen sel(skip) `box(0,0,0 .. 13,H-1,14)`; door `entryDoor` at `(4,1,0)`; `generateMaybeBox(0.07, (2,1,1 .. 11,4,13), cobweb, cobweb, false, false)`;
for `z` 1 to 13: if `(z - 1) % 4 == 0`: planks Gen box `(1,1,z .. 1,4,z)` and `(12,1,z .. 12,4,z)`, torches facing EAST at `(2,3,z)` and WEST at `(11,3,z)` (direct place), and when tall planks `(1,6,z .. 1,9,z)` and `(12,6,z .. 12,9,z)`;
else bookshelves in the same four boxes (`(1,1,z..1,4,z)`, `(12,1,z..12,4,z)`, and when tall `(1,6,z..1,9,z)`, `(12,6,z..12,9,z)`); for `z` 3, 5, 7, 9, 11: bookshelf boxes `(3,1,z .. 4,3,z)`, `(6,1,z .. 7,3,z)`, `(9,1,z .. 10,3,z)`.
If `isTall`: planks `(1,5,1 .. 3,5,13)`, `(10,5,1 .. 12,5,13)`, `(4,5,1 .. 9,5,2)`, `(4,5,12 .. 9,5,13)`, planks at `(9,5,11)`, `(8,5,11)`, `(9,5,10)`; fences (state `W` = east+west connected, `V` = north+south connected): Gen box `V`
`(3,6,3 .. 3,6,11)`, `V` `(10,6,3 .. 10,6,9)`, `W` `(4,6,2 .. 9,6,2)`, `W` `(4,6,12 .. 7,6,12)`; fence (north, east) at `(3,6,2)`; (south, east) at `(3,6,12)`; (north, west) at `(10,6,2)`; for `k` 0 to 2: fence (south, west)
at `(8+k, 6, 12-k)` and, when `k != 2`, fence (north, east) at `(8+k, 6, 11-k)`; ladders facing SOUTH at `(10, 1..7, 13)`; a chandelier of fences and torches: fence (east) at `(6,9,7)`, fence (west) at `(7,9,7)`, fence (east) at `(6,8,7)`,
fence (west) at `(7,8,7)`, fence (north, south, east, west) at `(6,7,7)` and `(7,7,7)`, fence (east) at `(5,7,7)`, fence (west) at `(8,7,7)`, fence (east, north) at `(6,7,6)`, (east, south) at `(6,7,8)`, (west, north) at `(7,7,6)`,
(west, south) at `(7,7,8)`; torches (upright) at `(5,8,7)`, `(8,8,7)`, `(6,8,6)`, `(6,8,8)`, `(7,8,6)`, `(7,8,8)`. Finally (tall or not): `createChest((3,3,5), stronghold_library)`; if tall: `AIR*` at `(12,9,1)` and `createChest((12,8,1), stronghold_library)`.

**`PortalRoom`** (key `Mob`; no `EntryDoor`; no ordinary children; `addChildren(start, ...)` sets `start.portalRoomPiece = this` when `start` is not null): Layout in order:
1. Gen sel **(no skip)** `box(0,0,0 .. 10,7,15)`; GRATES door at `(4,1,0)`.
2. Gen sel(no skip): `(1,6,1 .. 1,6,14)`, `(9,6,1 .. 9,6,14)`, `(2,6,1 .. 8,6,2)`, `(2,6,14 .. 8,6,14)`, `(1,1,1 .. 2,1,4)`, `(8,1,1 .. 9,1,4)`.
3. Lava Gen box `(1,1,1 .. 1,1,3)`, `(9,1,1 .. 9,1,3)`; Gen sel(no skip) `(3,1,8 .. 7,1,12)`; lava `(4,1,9 .. 6,1,11)`.
4. Iron bars (north, south) for `z` 3, 5, ..., 13: Gen box `(0,3,z .. 0,4,z)` and `(10,3,z .. 10,4,z)`; iron bars (west, east) for `x` 2, 4, 6, 8: Gen box `(x,3,15 .. x,4,15)`.
5. Stairs (stone brick stairs facing NORTH): Gen sel(no skip) `(4,1,5 .. 6,1,7)`, `(4,2,6 .. 6,2,7)`, `(4,3,7 .. 6,3,7)`; for `x` 4 to 6: stairs at `(x,1,4)`, `(x,2,5)`, `(x,3,6)`.
6. **Eyes:** **12 draws** `nextFloat()` in order, `eye[i] = (draw > 0.9)` (so each frame has an eye with probability 10 %, the comparison is strict; the draws happen before any frame is placed); `allEyes` = all twelve true.
7. **Frames** (`end_portal_frame`, default state with the facing and the `eye` value of its index), placed in index order: indices 0 to 2: facing NORTH at `(4,3,8)`, `(5,3,8)`, `(6,3,8)`; 3 to 5: facing SOUTH at `(4,3,12)`, `(5,3,12)`, `(6,3,12)`; 6 to 8: facing EAST at `(3,3,9)`, `(3,3,10)`, `(3,3,11)`; 9 to 11: facing WEST at `(7,3,9)`, `(7,3,10)`, `(7,3,11)`.
8. If `allEyes`: `end_portal` blocks (default state) at `(4,3,9)`, `(5,3,9)`, `(6,3,9)`, `(4,3,10)`, `(5,3,10)`, `(6,3,10)`, `(4,3,11)`, `(5,3,11)`, `(6,3,11)`.
9. If not `hasPlacedSpawner`: `p = worldPos(5, 3, 6)`; if inside the write box: `hasPlacedSpawner = true`, `setBlock(p, spawner, 2)`, and if the block entity is a spawner `setEntityId(silverfish, random)` (31 section 7).

The eye draws, like every draw in `postProcess`, come from the chunk's shared `random` (36-1 section 8) and are made in every chunk that writes the piece, so the eye pattern is a function of the chunk's stream, not stored in the piece (Open question 7).

### 3.8 Child coordinates: a note on the five-way crossing

The Left and Right helpers use world offsets from the minimum corner while the carved openings use the local frame, and the orientation-dependent swap of `a` and `b` for WEST and NORTH is the only compensation. Working it out for
a NORTH piece (local z grows towards -Z): the opening carved for `leftLow` is at world depth `minZ + 7 .. minZ + 9`, y `minY + 3 .. minY + 5`, while the child requested for `leftLow` is at `(y = minY + 5, z = minZ + 1)`: that is
the location of the **high** opening. So for NORTH and WEST pieces a child spawned for a flag does not sit at the opening carved for the same flag (inferred from the arithmetic of this section and 36-1 section 6.4; whether it is intended
is not known). The implementation reproduces the coordinates as given.

### 3.9 NBT keys by piece (stronghold)

| Piece (id) | Keys beyond `id`, `BB`, `O`, `GD` |
|---|---|
| `shs` Straight | `EntryDoor`, `Left` (bool), `Right` (bool) |
| `shcc` ChestCorridor | `EntryDoor`, `Chest` (bool) |
| `shfc` FillerCorridor | `Steps` (int) |
| `sh5c` FiveCrossing | `EntryDoor`, `leftLow`, `leftHigh`, `rightLow`, `rightHigh` |
| `shlt`, `shrt` turns; `shph` PrisonHall; `shssd` StraightStairsDown | `EntryDoor` |
| `shli` Library | `EntryDoor`, `Tall` (bool) |
| `shpr` PortalRoom | `Mob` (bool) |
| `shrc` RoomCrossing | `EntryDoor`, `Type` (int) |
| `shsd` StairsDown and `shstart` Start | `EntryDoor`, `Source` (bool) |

A loaded piece has no `previousPiece`, `pendingChildren` or `portalRoomPiece` (they are generation-time only). Mineshaft keys are in sections 2.5, 2.6, 2.11, 2.12. (Piece ids: 36-1 section 2.4; they are the lower-cased code strings listed in section 2.2.)

### 3.10 The eye of ender and the stronghold

`#minecraft:structure/eye_of_ender_located` contains `stronghold` only. The eye of ender item uses `findNearestMapStructure` with that tag, radius 100, over the **ring chunk list** (36-1 section 11 step 3): the answer is the locate position of the nearest
ring chunk's start, `(chunk.minBlockX, 0, chunk.minBlockZ)` of that start's chunk, not the portal room (25 section 6.3, 21 section 8.12 for the entity). `StartPiece.getLocatorPosition` (the portal room's centre) exists, but no class of this artifact
calls `getLocatorPosition`, so the item does not use it (read by searching the constant pools of all `net.minecraft` classes: the method is defined in `StructurePiece` and overridden in `StartPiece` and referenced nowhere else).
The portal room is the only place the frames matter: an eye used on a frame is handled by `EnderEyeItem.useOn` (25 section 6.3), which matches the 3 by 3 pattern and turns it into portal blocks; with all twelve generated eyes present the room already
contains the portal (section 3.7 step 8).

---

## 4. Worked examples and test vectors

Numbers marked "computed" were produced by a short script that applied the rules of this document and of 10 section 2.6 and 36-1 section 4; they are test vectors, **not values observed from the artifact** (nothing was executed). Implementers must treat every "computed" value (start angle, raw ring chunks, state `198298811348821`, first double, the `nextInt(6)` values) as unverified until a test confirms it; they were not re-derived by an independent method in this review round, and Open question 13 (ring seed equals level seed) stays open.

### 4.1 Ring sizes (section 3.1)

Ring sizes 3, 6, 10, 15, 21, 28, 36, 9 (computed; cumulative 3, 9, 19, 34, 55, 83, 119, 128). Ring 0 mean radius 128 chunks, ring 1 320, ring 2 512 (jitter at most 40 chunks either way).
For the level seed 0 (assuming `concentricRingsSeed` equals the level seed, not separately confirmed, Open question 13), before the biome search (computed with the Java LCG, re-checked in this round): start angle `4.592806061666583`; positions `i = 0 .. 2` (ring 0, base radius 128 chunks) have radius `107.2429...`, `132.0349...`, `114.6574...` chunks and raw ring chunks `(-13,-106)`, `(121,52)`, `(-92,69)`. Each position uses one `nextDouble` (radius jitter) and then one `nextLong` (the fork seed) of `R`; the angle step inside a ring is `2 pi / S`. When a ring completes (here after position 2) one **more** `nextDouble() * pi * 2` is added to the angle, drawn after that position's fork draw and before the next ring's first radius draw (section 3.1). Position 3 is therefore the first of ring 1 (base radius `4*32 + 32*1*6 = 320`) with radius `350.3346...` and raw ring chunk `(-75,-342)`; position 4 has radius `301.9963...` and raw ring chunk `(223,-203)`. The biome search may move each chunk.

### 4.2 Seeding (`setLargeFeatureSeed`)

Level seed 0, chunk (1, 0) (computed): `a` and `b` are the first two `nextLong` of the LCG seeded with 0; the new state is `(1 * a) xor (0 * b) xor 0 = a`, i.e. the internal 48-bit state after seeding is `198298811348821`
(this is the state after `setSeed(a)`, i.e. `(a xor 0x5DEECE66D) & (2^48 - 1)`). First `nextDouble()`: `0.26044200501959935` (above 0.004, so no mineshaft for the `legacy_type_3` test at chunk (1,0)). With
the first double discarded (the mineshaft start, section 2.3), the next three `nextInt(6)` are `4, 3, 5`: the root room is the box `(18, 50, 2 .. 18 + 7 + 4, 54 + 3, 2 + 7 + 5)` = `(18, 50, 2) .. (29, 57, 14)`, 12 by 8 by 13 blocks. For the stronghold at the same
chunk and seed (attempt 0), the first draw `nextInt(4)` is 1: the start piece faces EAST (array index 1), box `makeBoundingBox(18, 64, 2, EAST, 5, 11, 5)` = `(18, 64, 2) .. (22, 74, 6)`.

### 4.3 First stronghold child

Continuing 4.2: `StartPiece.addChildren` sets the imposed class `FiveCrossing` and calls `Forward(1, 1)` with orientation EAST: position `(maxX + 1, minY + 1, minZ + 1) = (23, 65, 3)`, direction EAST, depth 0. `generateAndAddPiece`: depth 0 is not above 50; the distance from
the start's minimum corner is `|23 - 18| = 5`, `|3 - 2| = 1`, fine; `generatePieceFromSmallDoor(depth 1)`: `updatePieceWeight()` is true; the imposed class is built: `orientBox(23, 65, 3, -4, -3, 0, 10, 9, 11, EAST)` with the EAST branch of 36-1 section 6.3:
`x0 = 23 + 0 = 23`, `y0 = 65 - 3 = 62`, `z0 = 3 - 4 = -1`, `x1 = 23 + 11 - 1 + 0 = 33`, `y1 = 62 + 9 - 1 = 70`, `z1 = 3 + 10 - 1 - 4 = 8`: box `(23, 62, -1) .. (33, 70, 8)`; `minY 62 > 10`; it does not intersect `(18,64,2)..(22,74,6)`; so the
constructor draws `nextInt(5)`, three `nextBoolean`, `nextInt(3)`. (The vertical shift of `moveBelowSeaLevel` is applied only at the end.)

### 4.4 Choosing from the table

Full table total 145. A draw `v = 93`: running subtraction 93 - 40 = 53, 53 - 5 = 48, 48 - 20 = 28, 28 - 20 = 8, 8 - 10 = -2: the entry is `RoomCrossing` (index 4). If its box fails the factory the walk continues to the next entry, `StraightStairsDown`, with the same
negative running value. A draw `v = 140`: the cumulative upper bounds of the table are 40, 45, 65, 85, 95, 100, 105, 110, 115, 125, 145, so 140 falls in `PortalRoom` (index 10, covering 125 to 144). It is rejected by `doPlace` while `depth <= 5`, which abandons that try.

### 4.5 Local to world (section 3.7 and 36-1 section 6.4)

A `Straight` piece with box `(100, 40, 200) .. (104, 44, 206)` and orientation NORTH: local `(1, 2, 1)` is world `(minX + 1, minY + 2, maxZ - 1) = (101, 42, 205)`. The same piece oriented EAST with box `(100, 40, 200) .. (106, 44, 204)`: local `(1, 2, 1)` is `(minX + z, ..., minZ + x) = (101, 42, 201)`.

### 4.6 A corridor box

NORTH corridor, `len = 3`, anchor `(100, 40, 200)`: `L = 15`, local box `(0,0,-14 .. 2,2,0)`, world box `(100, 40, 186) .. (102, 42, 200)`; `numSections = 15 / 5 = 3`, `len_local = 14`; the section centres are local `z = 2, 7, 12`. The side-branch scan (`i` from `minZ + 3 = 189`, step 5, condition `i + 3 <= maxZ = 200`): `i = 189` (192 <= 200) and `i = 194` (197 <= 200) draw `nextInt(5)`; `i = 199` (202 > 200) stops. Two draws.

### 4.7 Eyes

The probability that a generated portal room is already complete is `0.1^12 = 1e-12`; the expected number of eyes is 1.2.

---

## 5. Validation (checks an implementation should pass)

1. **Ring list:** 128 chunks in the order of generation; ring sizes 3, 6, 10, 15, 21, 28, 36, 9; the `R` stream consumed exactly as in 36-1 section 4.6 (the angle and the position 0 to 4 vectors of section 4.1 reproduce for seed 0).
2. **Mineshaft depth and reach:** no piece has `genDepth > 9` (the room is 0; `generateAndAddPiece` rejects `depth > 8` before adding 1); no corridor, crossing or stairs piece starts farther than 80 blocks in x or z from its parent's minimum corner.
3. **Mineshaft mix:** over many `createRandomShaftPiece` calls the attempted classes are 70 % corridor, 10 % stairs, 20 % crossing; corridors have 2 to 4 sections; a corridor has rails with probability 1/3 and, among those without, a spider with probability 1/23.
4. **Mineshaft box:** the root room is `(16cx+2, 50, 16cz+2)` to `(+7..12 in x, 54..59, +7..12 in z)` before the vertical shift; after `normal` placement the structure's top is at most `seaLevel - 10`.
5. **Mesa:** the centre of the union box lands in `[seaLevel, max(seaLevel, surface)]` after the shift.
6. **Stronghold counts:** each of `PrisonHall`, `StraightStairsDown`, `StairsDown` has at most 5 pieces, `RoomCrossing` at most 6, `FiveCrossing` and `ChestCorridor` at most 4 (the imposed first five-crossing is not counted), `Library` at most 2, `PortalRoom` exactly 1 in a finished structure.
7. **Stronghold geometry:** every piece box satisfies `minY > 10` (filler corridors `minY > 1`); `Library` is 14 by 11 or 14 by 6 by 15; the start box is 5 by 11 by 5 at y 64 before the shift; no two boxes of one structure intersect except through a filler corridor's constraint; no piece starts farther than 112 blocks (x or z) from the start piece's minimum corner; `genDepth <= 51`.
8. **Order independence of pending pieces:** the expansion order is the random pick of section 3.2; a test fixing the draws can reproduce a layout.
9. **Block level:** a stronghold shell is bricks only where terrain was solid (`skipAir`), except the portal room; selector percentages 20/30/5/45 over edge cells; a portal room has 12 frames at the listed cells, a spawner at local `(5,3,6)`, lava in three places.
10. **Per-chunk rebuild:** a piece's blocks in a chunk depend only on the piece, the chunk write box and the shared per-structure random stream of that chunk (36-1 section 8); every box helper skips cells outside the write box but still consumes its draws.

---

## 6. Open questions

1. **Rotation and mirror of block properties.** Every directional state in this document is the NORTH-frame state; `placeBlock` then mirrors and rotates it (36-1 section 6.5). How a fence's four connection booleans, an iron bars' booleans, a wall torch's facing, a stairs' facing and shape, a ladder, a door's facing and a stone button's facing and face transform under mirror and rotation is the block's rotate and mirror rule. This round located the rules in 24: fence and iron bars (`CrossCollisionBlock`) in 24-4 section 6.2 (rotation permutation table; `LEFT_RIGHT` swaps `north` and `south`, `FRONT_BACK` swaps `east` and `west`); stairs in 24-5 section 7.10 (facing rotates; mirror rotates 180 degrees and replaces the shape by the table there); ladder in 24-3 section 7.1 ("rotate and mirror act on `facing`", the mapping not tabulated). Not found in 24: the door's (`facing`, `hinge`), the wall torch's `facing` and the stone button's (`face`, `facing`) transforms. For a horizontal `facing` property the assumption is that rotation turns `facing` by the rotation and mirror maps it as in the stair row (inferred, not read in this round); a door's `hinge` swap under mirror is unread. These three remain to be covered by a block registry addendum.
2. **`getLocatorPosition`.** No class of the artifact calls it (section 3.10); a server-side caller outside this jar cannot be excluded (inferred).
3. **`Math.cos` and `Math.sin` precision.** The ring list (36-1 section 4.6) rounds `cos * radius`; a platform whose `cos` differs in the last bit can change a ring chunk at a rounding boundary. The reference results were not verified against the artifact.
4. **Block entity details.** The spawner configuration after `setEntityId(type, random)` (spawn data, delays, ranges), the chest block entity loot-table seed handling and the end portal frame's block-entity-free state are 31 and 24.
5. **`EntryDoor` encoding.** The type is saved through a legacy enum codec; whether it writes the ordinal or an upper-case name, and what it reads for an unknown value, was not traced.
6. **Chest minecart entity setup.** `chest_minecart` creation with the chunk-generation spawn reason, its initial position and loot table fields are read; the entity's NBT and tracking are 21 and 45.
7. **Per-chunk eye draws in the portal room.** The 12 eye draws are made inside `postProcess` from the chunk's shared random stream, and the room is 11 by 16 blocks, so it can touch up to four chunks; each chunk draws its own twelve values, and the frames inside each chunk take that chunk's values. No state in the piece records the pattern (read: only `Mob` is saved). The consequence (a frame's eye state depends on which chunk's stream placed it; the all-eyes portal condition is evaluated per chunk) follows from the code but was not examined further.
8. **Mineshaft `isInInvalidLocation` liquids.** `BlockState.liquid()` is used as read; its definition (fluid state not empty versus a liquid material) is in 24.
9. **Stronghold generation loop has no cap.** If a seed never produces a portal room the loop does not terminate; an implementation should bound it and document the bound (the artifact states none).
10. **`FiveCrossing` child mismatch** (section 3.8) is derived by arithmetic, not by observation of generated structures.
11. **Beardifier for `bury`.** The terrain-adaptation effect of the stronghold's boxes is 36-1 section 9; the contribution of `FillerCorridor` and `Library` boxes as pieces with `bury` was not separately traced.
12. **Biome tags.** The contents of `has_structure/mineshaft` (including the newest cave biomes), `has_structure/mineshaft_mesa`, `is_overworld` and `stronghold_biased_to` are data; the tool must copy them.
13. **Ring seed.** `concentricRingsSeed` equal to the level seed (assumed in section 4.1) was not separately confirmed.
14. **`trade_rebalance` loot table.** The datapack copy of `abandoned_mineshaft` was listed but not compared with the base table, and its enable conditions (datapack pack metadata, feature flags) were not read here.
15. **`on_mineshaft_maps` consumer.** The tag contains `minecraft:mineshaft`; the only reference found by grepping the jar's `data/` text is the `exploration_map` modifier of `abandoned_camp_secret_chest` (a loot table of another structure, not owned by this document). No villager trade refers to it. Whether code refers to the tag by a constant was not searched in bytecode. How `exploration_map` locates the structure (26, 36-1 section 11) is not repeated here.
16. **Unconfirmed stronghold details.** An independent review checked the mineshaft and the top-level stronghold mechanics, but not the per-block layouts of `Library`, `PrisonHall`, `RoomCrossing`, `FiveCrossing` and `PortalRoom` (section 3.7), the 5-try walk's branch where a piece factory returns null and the walk continues with the next entry (`generatePieceFromSmallDoor`), the Left and Right helper offsets, or the `FillerCorridor.findPieceBox` and beardifier details. They are not shown wrong; a later reviewer should spot-check them against the artifact before they are relied on.
