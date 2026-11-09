# 36 Structures, part 8: Nether fortress, End city and bastion remnant

| Item | Value |
|---|---|
| Covers | The three structures of the Nether and the End whose generation is partly or wholly code: (A) the **Nether fortress** (`NetherFortressStructure`, `NetherFortressPieces` with its 15 piece classes: start, bridge crossing, bridge straight, bridge end filler, room crossing, stairs room, monster throne, castle entrance, castle stalk room, four small-corridor pieces, corridor stairs, corridor T balcony; the two weighted piece tables, the growth procedure with its limits and random draws, the child-anchor rules, every piece's box and block geometry, the chest and blaze spawner placement, the loot table and the spawn list); (B) the **End city** (`EndCityStructure`, `EndCityPieces`: the start rule, the recursive section generators for the house tower, the tower, the tower bridge and the fat tower, the template piece with its data markers, the shulker, chest and elytra handling, the template list and the loot table shape); (C) the **bastion remnant**, a jigsaw structure: how it uses the jigsaw engine of 36-3, the four variants (housing units, hoglin stable, treasure room, bridge), the pool graph as the engine sees it, the mob and block connectors, the preplaced piglin, piglin brute and hoglin placement odds, the magma cube spawner, the loot tables, the processor lists and the spawn overrides. |
| Does not cover | Rows of data (the extraction tool copies `worldgen/structure`, `worldgen/structure_set`, `worldgen/template_pool`, `worldgen/processor_list`, `loot_table`, `tags` and the structure NBT; 22, 23): they are cited for wiring and summarised in shape, never tabulated. The shared structure model, placement engines, start creation, piece base class, block-writing helpers and chunk integration (36-1), the template system, processors and `TemplateStructurePiece` (36-2), the jigsaw assembler (36-3), the other structure families (36-4 to 36-10), the Nether and End dimension data (37, 38: the structure sets `nether_complexes`, `end_cities`, biome tags, noise), natural spawning and the fortress bounding-box rule (44-2), spawner block entities (31-7), the loot engine (26), mob behaviour of piglins, hoglins and shulkers (19 to 21, 44-6, 45). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of `net.minecraft.world.level.levelgen.structure.structures.NetherFortress*`, `EndCity*`, `JigsawStructure`, `structure.StructurePiece`, `BoundingBox`, `TemplateStructurePiece`, `Structure`, `pools.JigsawPlacement`, `StructurePoolElement`, `SinglePoolElement`, `templatesystem.StructureTemplate`, `BlockIgnoreProcessor`, `world.level.block.Rotation`, `Mirror`, `core.Direction`, `entity.monster.piglin.Piglin`, `PiglinBrute`, `hoglin.Hoglin`, `Shulker`, `Mob`, and of the JSON and structure NBT data inside the jar (read with a small NBT reader written for this round, outside the repository), with no execution. Every value is read from the artifact unless marked "(inferred)" or "(recalled, not verified)"; every such mark is listed in the Open questions. |
| Round | RS20 (GAP-12b and GAP-18 of [../design/README.md](../design/README.md)), part 8 |
| Operator decisions | Standard Minecraft content is the target; a COBOL tool extracts a vanilla resource pack and data pack from the user's jar, so data rows are not tabulated here. This document specifies the engines and the code-defined content completely. Ticket CC-0001, Decisions "World scope" and "Vanilla assets and data". |
| Status | Written by the reader for round RS20, part 8. |

Class names in backticks say where a fact was read; they are not the design. References: "36-n section m" is another part of the structures
document (36-1 `36-structures-1-model-placement-starts.md`, 36-2 `36-structures-2-templates-and-processors.md`, 36-3 `36-structures-3-jigsaw-assembly.md`), "37-6
section m" is `37-nether-6-structures-spawns-hooks.md`, "38 section m" is `38-end.md`, "44-2 section m" is
`44-residual-mob-questions-2-spawning-structures.md`, "10 section m" is `10-world-generation-terrain.md`. Block coordinates are absolute unless a
section says "piece-local". All random draws use the structure random of 36-1 section 5.1 (a `WorldgenRandom` over the legacy Java
generator, 10 section 2.6): `nextInt(n)` is the bounded draw, `nextInt()` the full 32-bit draw, `nextBoolean()` and `nextLong()` as in 10 section 2.6.

## Contents

1. Reading guide: what is data, what is code, and the notation of the geometry lists
2. A. Nether fortress: structure, start and growth
3. A. The piece tables, selection and limits
4. A. Child anchors and the piece catalogue
5. A. Piece geometry (block lists)
6. A. Chests, the blaze spawner, loot and spawns
7. A. Worked examples
8. B. End city: structure and start
9. B. The template piece, connection arithmetic and data markers
10. B. The section generators
11. B. Templates, markers, loot, spawns
12. B. Worked examples
13. C. Bastion remnant: use of the jigsaw engine
14. C. The four variants and their pool graphs
15. C. Mobs, blocks, spawner, loot
16. C. Processors
17. C. Worked examples
18. Validation
19. Open questions

---

## 1. Reading guide

### 1.1 Data versus code

| Item | Kind | Where specified |
|---|---|---|
| Fortress piece classes, weight tables, growth, geometry, chest and spawner code | **code** | sections 2 to 6 |
| `worldgen/structure/fortress.json`, structure set `nether_complexes`, biome tags, `chests/nether_bridge` | data | 37-6 sections 2, 3, 8; shape in section 6 |
| End city start rule, generators, piece class, marker handling | **code** | sections 8 to 11 |
| `worldgen/structure/end_city.json`, structure set `end_cities`, the 20 `structure/end_city/*.nbt` templates, `chests/end_city_treasure` | data | 38 section 10; list and shape in section 11 |
| Bastion: `JigsawStructure` and `JigsawPlacement` | **code** | 36-3 (cited in section 13) |
| Bastion: structure JSON, 60 template pools, 167 templates, 12 processor lists, 4 loot tables | data | 37-6 section 5; shape and derived facts in sections 13 to 16 |
| Bastion piece classes | none (the data generator classes `BastionPieces`, `BastionHousingUnitsPools` and siblings only wrote the JSON at build time; the runtime reads the JSON) | 37-6 section 1 |

### 1.2 Notation of the fortress geometry lists (section 5)

Every list is in **execution order** (a later operation overwrites an earlier one). All coordinates are **piece-local** `(x, y, z)` with local
`y = 0` the bottom layer of the piece box. The conversion to world coordinates and the writing helpers are 36-1 sections 6.3 to 6.5; the
rules the lists rely on:

* `fill (x0,y0,z0)-(x1,y1,z1) B`: `generateBox` with edge state and fill state both `B` and `skipAir` false: every cell of the inclusive box is
  written, so the order of cells does not matter (loop order y, x, z only fixes side effects).
* `put (x,y,z) B`: `placeBlock`.
* `col (x,-1,z)`: `fillColumnDown` with nether bricks from local `(x, -1, z)`: starting one layer under the piece, nether bricks are placed
  downward while the cell is air, a liquid, glow lichen, seagrass or tall seagrass and its y is above the dimension minimum y plus 1. It fills
  the gap between the piece floor and the ground below.
* Block names: `NB` nether bricks, `AIR`, `FENCE(sides)` the nether brick fence with exactly the listed sides connected (`N`, `E`, `S`, `W`; `FENCE()` has none);
  `STAIRS(d)` nether brick stairs with `facing = d` and the other properties at their defaults (bottom half, straight shape, not waterlogged),
  `SOUL_SAND`, `NETHER_WART` (age 0), `LAVA` (the default state of lava, level 0), `SPAWNER`.
* **Reference frame.** Every facing and fence side in the lists is written for the reference orientation `NORTH` (local +x is east, local +z is
  north). For another orientation `placeBlock` applies the piece's mirror and then its rotation to the state (36-1 section 6.4: `SOUTH` mirror
  `LEFT_RIGHT`; `WEST` mirror `LEFT_RIGHT` and `CLOCKWISE_90`; `EAST` `CLOCKWISE_90`). `Mirror.LEFT_RIGHT` turns a north direction into south and
  the reverse and leaves east and west alone; `Rotation.CLOCKWISE_90` turns north into east, east into south, south into west, west into north (read
  from `Mirror.mirror(Direction)` and `Direction.getClockWise`). Example: `FENCE(E,W)` in a piece facing `EAST` becomes the fence with sides `S,N`.
* The nether brick fence is one of the 12 **shape-check blocks** (36-1 section 6.5): each fence placed is marked for post-processing, so its
  connection flags are recomputed from the neighbours after generation (35 section 4.3). The side lists above are the initial states.
* Writing is clipped to the chunk write box (36-1 section 8), so every chunk that a piece touches replays the whole list and keeps only its own cells. Every `put`, `fill`
  and `col` uses `canBeReplaced` = true: a fortress overwrites whatever is in the box.

---

## 2. A. Nether fortress: structure, start and growth

### 2.1 Definition and start

`fortress.json` (37-6 section 3.1): type `fortress`, biomes tag `has_structure/nether_fortress`, step `underground_decoration`, no terrain
adaptation, `spawn_overrides.monster` with `bounding_box` = `piece` and five entries (section 6.3). The structure set `nether_complexes` is 37-6
section 2. The type is a `StructureType.FORTRESS` simple codec with no extra fields.

`NetherFortressStructure.findGenerationPoint(ctx)`:

1. `chunk = ctx.chunkPos()`. The stub position is `(chunk.minBlockX, 64, chunk.minBlockZ)`. There is **no biome pre-check** and no height rule: a
   stub is always produced. (`ctx.isValidBiome(stub)` of 36-1 section 5.3 then tests the biome at that position, quart coordinates, y = 64.)
2. The pieces are built by the consumer of the stub (run after the biome check), `generatePieces(builder, ctx)`:
   1. Create the **start piece** at `(chunk.getBlockX(2), chunk.getBlockZ(2))` = `(minBlockX + 2, minBlockZ + 2)` (section 4.2).
   2. Add it to the builder and call its `addChildren` once (section 4.1), which creates up to three children.
   3. While the start piece's `pendingChildren` list is not empty: `i = random.nextInt(size)`; remove element `i`; call that piece's
      `addChildren(start, builder, random)`. (Pieces created by those calls are appended to the same list.)
   4. `builder.moveInsideHeights(random, 48, 70)` (36-1 section 6.6): `room = 70 - 48 + 1 - ySpan = 23 - ySpan`; the new minimum y is `48 + random.nextInt(room)` when `room > 1`,
      else `48`; every piece is moved by `newMin - box.minY`. This draw is the last use of the random in generation.

All pieces are created at a working height around y = 64 (the start's y) and the final vertical placement is the single shift of step 4; pieces
never read terrain heights. The spawn check of 44-2 section 8.1 uses the stored piece boxes.

### 2.2 Constants (`NetherFortressPieces`)

| Constant | Value | Meaning |
|---|---|---|
| `MAX_DEPTH` | 30 | a piece of generation depth greater than 30 is never chosen from a table (the end filler is used instead) |
| `LOWEST_Y_POSITION` | 10 | `isOkBox(box)` is `box.minY > 10` |
| `MAGIC_START_Y` | 64 | working y of the start piece |
| distance limit | 112 | a new piece anchor whose x differs from the start box `minX` by more than 112, or whose z differs from the start box `minZ` by more than 112, is replaced by a filler that is not even added (section 3.3 step 1) |
| `generationDepth` of the start | 0 | children take parent depth + 1 |

---

## 3. A. The piece tables, selection and limits

### 3.1 The two tables

Each entry is `(class, weight, maxPlaceCount, allowInRow)`; `maxPlaceCount` 0 means unlimited. The tables are the same as 37-6 section 4 (re-read here
entry by entry); the sums are new.

| Table | Entries in order (weight / max count, `*` = allow in row) | Weight sum | Sum of the limited maxima |
|---|---|---|---|
| bridge (`BRIDGE_PIECE_WEIGHTS`) | `BridgeStraight` 30 / unlimited `*`; `BridgeCrossing` 10 / 4; `RoomCrossing` 10 / 4; `StairsRoom` 10 / 3; `MonsterThrone` 5 / 2; `CastleEntrance` 5 / 1 | 70 | 14 |
| castle (`CASTLE_PIECE_WEIGHTS`) | `CastleSmallCorridorPiece` 25 / unlimited `*`; `CastleSmallCorridorCrossingPiece` 15 / 5; `CastleSmallCorridorRightTurnPiece` 5 / 10; `CastleSmallCorridorLeftTurnPiece` 5 / 10; `CastleCorridorStairsPiece` 10 / 3 `*`; `CastleCorridorTBalconyPiece` 7 / 2; `CastleStalkRoom` 5 / 2 | 72 | 32 |

Cumulative weights (the order is the draw order): bridge 30, 40, 50, 60, 65, 70; castle 25, 40, 45, 50, 60, 67, 72.

The entry objects are shared static objects whose `placeCount` fields are reset to 0 by the start piece's constructor, which also copies the two
tables (entries in order) into `availableBridgePieces` and `availableCastlePieces`; those lists shrink during one generation, the static tables do not.

### 3.2 Per-structure state

The `StartPiece` holds: the two available lists, `pendingChildren` (initially empty), and `previousPiece` (the entry of the last successfully
created table piece, initially none; it is shared by both tables).

### 3.3 `generateAndAddPiece(start, builder, random, x, y, z, direction, genDepth, isCastle)`

`(x, y, z)` is the **anchor** of the new piece (sections 4.1 and 4.2), `genDepth` the parent's depth.

1. If `|x - start.box.minX| > 112` or `|z - start.box.minZ| > 112`: return `BridgeEndFiller.createPiece(builder, random, x, y, z, direction, genDepth)`
   **without adding it to the builder or to `pendingChildren`**. (A filler that is created still consumed one `nextInt()` for its seed, section 4.3; the
   result is discarded by every caller.)
2. `list` = `availableCastlePieces` when `isCastle`, else `availableBridgePieces`.
3. `piece = generatePiece(start, list, builder, random, x, y, z, direction, genDepth + 1)` (section 3.4).
4. If `piece` is not null: `builder.addPiece(piece)` and append it to `pendingChildren`. Return `piece` (callers ignore it).

### 3.4 `generatePiece(start, list, ..., genDepth)` (the weighted choice)

1. `total` = the sum of the weights of **all entries still in `list`** if at least one entry has `maxPlaceCount > 0` and `placeCount < maxPlaceCount`; otherwise
   `-1`. (Consequence: once every limited entry is exhausted the list holds only the unlimited entry, `total` is -1 and no table piece is chosen any more:
   only fillers are produced. Section 7.3.)
2. The table may be tried only if `total > 0` and `genDepth <= 30` (this `genDepth` is the parent's depth plus 1).
3. Up to **5 attempts**, while the table may be tried:
   1. `r = random.nextInt(total)`.
   2. Walk the entries of `list` in order; for each entry `e`: `r = r - e.weight`; if `r < 0` then `e` is **selected** and, for this entry and **every later entry of the list**
      (the walk continues with `r` still negative after a failed creation), apply:
      * if `!e.doPlace` (that is `maxPlaceCount != 0` and `placeCount >= maxPlaceCount`): this attempt ends with no piece (go to the next attempt);
      * if `e` is `start.previousPiece` and `!e.allowInRow`: this attempt ends with no piece;
      * otherwise call the entry's factory (`findAndCreateBridgePieceFactory`, section 4.3) with `(builder, random, x, y, z, direction, genDepth)`. If it returns a piece:
        `e.placeCount += 1`; `start.previousPiece = e`; if `!e.isValid` (limited and `placeCount >= maxPlaceCount`) remove `e` from `list`; return the piece. If it
        returns null (the box is not ok or collides) continue with the next entry of the list without a new draw.
4. If no attempt produced a piece: return `BridgeEndFiller.createPiece(builder, random, x, y, z, direction, genDepth)` (may be null; when it is created it is added by step 4 of 3.3).

`isOkBox(box)` is `box.minY > 10`. Every `createPiece` of a piece class (section 4.3) returns null unless `isOkBox` holds **and** `builder.findCollisionPiece(box)` is null (no piece already in the builder
intersects the new box, a 3-D inclusive test, 36-1 section 6.3); a successful `createPiece` constructs the piece (consuming the random draws of its constructor, section 4.3). A failed one consumes no random.

### 3.5 What the quirks mean

* `previousPiece` is global to the structure and tracks creation order, not tree adjacency: two `RoomCrossing` pieces cannot be created one after the other even in different branches
  (a pending piece expanded next may be from a different branch). `BridgeStraight`, `CastleSmallCorridorPiece` and `CastleCorridorStairsPiece` may repeat.
* The 5 attempts and the walk-on after a failed creation mean a collision does not reduce the number of draws below one per attempt; a collision on a high-weight piece usually ends with the next
  entry of the table being tried at the same anchor.
* The castle table is used for the children of the castle entrance, the stalk room and the castle corridor pieces (the `isCastle` argument, section 4.1), except that the T balcony chooses the
  table for each of its two children separately (castle with probability 7 in 8). Every bridge-level piece passes the bridge table. `CastleEntrance` is a member of the **bridge** table (weight 5,
  at most once) and is the bridge level's only gateway to the castle level.

---

## 4. A. Child anchors and the piece catalogue

### 4.1 The three child helpers (`NetherBridgePiece`)

Let `box` be the parent's box and `o` its orientation (a horizontal direction; the pieces always have one). The three helpers compute an anchor and a direction and call
`generateAndAddPiece(start, builder, random, ax, ay, az, dir, parent.genDepth, isCastle)`.

| Helper (arguments `p, q, castle`) | `o` = NORTH | `o` = SOUTH | `o` = WEST | `o` = EAST |
|---|---|---|---|---|
| `generateChildForward(p, q, castle)`: `p` = sideways offset, `q` = height offset | `(minX+p, minY+q, minZ-1)` dir `NORTH` | `(minX+p, minY+q, maxZ+1)` dir `SOUTH` | `(minX-1, minY+q, minZ+p)` dir `WEST` | `(maxX+1, minY+q, minZ+p)` dir `EAST` |
| `generateChildLeft(p, q, castle)`: `p` = height offset, `q` = lateral offset | `(minX-1, minY+p, minZ+q)` dir `WEST` | `(minX-1, minY+p, minZ+q)` dir `WEST` | `(minX+q, minY+p, minZ-1)` dir `NORTH` | `(minX+q, minY+p, minZ-1)` dir `NORTH` |
| `generateChildRight(p, q, castle)`: `p` = height offset, `q` = lateral offset | `(maxX+1, minY+p, minZ+q)` dir `EAST` | `(maxX+1, minY+p, minZ+q)` dir `EAST` | `(minX+q, minY+p, maxZ+1)` dir `SOUTH` | `(minX+q, minY+p, maxZ+1)` dir `SOUTH` |

Notes: "left" and "right" are named for the reference frame of a north-oriented piece and are the world directions in the table (a piece facing south has its "left" child on the west side). The forward child takes
the parent's own orientation. The forward helper's `p` is measured from the box's minimum corner along the axis perpendicular to the facing (x for a north- or south-facing parent, z for a west- or east-facing one);
the lateral offset `q` of left and right is measured from the minimum corner along the facing axis (z for a north- or south-facing parent, x for a west- or east-facing one). The height offset is added to the parent's
`minY`. A parent with a null orientation returns null (not occurring).

The anchor `(ax, ay, az)` is the point from which the child's own `orientBox` places its box (section 4.2), so the child box touches the parent box on the exit side.

### 4.2 Piece boxes

A piece class's `createPiece` computes `box = BoundingBox.orientBox(ax, ay, az, offX, offY, offZ, width, height, depth, dir)` (36-1 section 6.3) with the class's constants of the table below and then applies the
test of section 3.4. The local frame of the finished piece is 36-1 section 6.4 with the piece's orientation = `dir`. Width is the local x extent, depth the local z extent; local z increases away from the entrance side
(for `dir` NORTH, local z 0 is at the box's `maxZ` and the child "forward" exit is beyond local z = depth - 1).

The start piece is created differently: `BridgeCrossing(x, z, dir)` with `dir = Direction.Plane.HORIZONTAL.getRandomDirection(random)` (one `nextInt(4)` over the order NORTH, EAST, SOUTH, WEST; the first draw
of the whole generation) and box `makeBoundingBox(x, 64, z, dir, 19, 10, 19)`: because width and depth are both 19 the box is `(x, 64, z)` to `(x + 18, 73, z + 18)` whatever the direction. Its generation depth is 0 and its saved id is `NeStart`.

### 4.3 The catalogue

| Class (registered id, 36-1 section 2.4) | Box constants `offX, offY, offZ; w, h, d` | `addChildren` (helper `(p, q, castle)`) | Draws in the constructor | Notes |
|---|---|---|---|---|
| `StartPiece` (`NeStart`) | `BridgeCrossing`'s | as `BridgeCrossing` | 1 (`nextInt(4)`, the orientation) | extends `BridgeCrossing`; geometry of `BridgeCrossing` |
| `BridgeCrossing` (`NeBCr`) | -8, -3, 0; 19, 10, 19 | Forward(8, 3, bridge); Left(3, 8, bridge); Right(3, 8, bridge) | 0 | table: bridge |
| `BridgeStraight` (`NeBS`) | -1, -3, 0; 5, 10, 19 | Forward(1, 3, bridge) | 0 | table: bridge |
| `BridgeEndFiller` (`NeBEF`) | -1, -3, 0; 5, 10, 8 | none | 1 (`nextInt()` stored as `Seed`) | not in a table; closes an open end |
| `RoomCrossing` (`NeRC`) | -2, 0, 0; 7, 9, 7 | Forward(2, 0, bridge); Left(0, 2, bridge); Right(0, 2, bridge) | 0 | table: bridge |
| `StairsRoom` (`NeSR`) | -2, 0, 0; 7, 11, 7 | Right(6, 2, bridge) | 0 | table: bridge |
| `MonsterThrone` (`NeMT`) | -2, 0, 0; 7, 8, 9 | none (a dead end) | 0 | blaze spawner; saved `Mob` flag |
| `CastleEntrance` (`NeCE`) | -5, -3, 0; 13, 14, 13 | Forward(5, 3, castle) | 0 | table: bridge |
| `CastleStalkRoom` (`NeCSR`) | -5, -3, 0; 13, 14, 13 | Forward(5, 3, castle); Forward(5, 11, castle) | 0 | table: castle; nether wart |
| `CastleSmallCorridorPiece` (`NeSC`) | -1, 0, 0; 5, 7, 5 | Forward(1, 0, castle) | 0 | table: castle |
| `CastleSmallCorridorCrossingPiece` (`NeSCSC`) | -1, 0, 0; 5, 7, 5 | Forward(1, 0, castle); Left(0, 1, castle); Right(0, 1, castle) | 0 | table: castle |
| `CastleSmallCorridorLeftTurnPiece` (`NeSCLT`) | -1, 0, 0; 5, 7, 5 | Left(0, 1, castle) | 1 (`nextInt(3)`: chest when 0; saved `Chest`) | table: castle |
| `CastleSmallCorridorRightTurnPiece` (`NeSCRT`) | -1, 0, 0; 5, 7, 5 | Right(0, 1, castle) | 1 (`nextInt(3)`: chest when 0; saved `Chest`) | table: castle |
| `CastleCorridorStairsPiece` (`NeCCS`) | -1, -7, 0; 5, 14, 10 | Forward(1, 0, castle) | 0 | table: castle |
| `CastleCorridorTBalconyPiece` (`NeCTB`) | -3, 0, 0; 9, 7, 9 | special (below) | 0 | table: castle |

`CastleCorridorTBalconyPiece.addChildren`: `k = 5` when the orientation is `WEST` or `NORTH`, else `k = 1`. Then, in this order: draw `a = random.nextInt(8)`; `generateChildLeft(0, k, castle = (a > 0))`; draw
`b = random.nextInt(8)`; `generateChildRight(0, k, castle = (b > 0))`. Each draw happens before its own helper call (so before the draws the child creation makes).

Factory (`findAndCreateBridgePieceFactory`): maps the selected entry's class to the `createPiece` of the same class with the arguments of 3.4. Its constructors: only `BridgeStraight`, `BridgeEndFiller`, `CastleEntrance` and the two turn
pieces take the random; only `BridgeEndFiller` (a seed) and the turn pieces (the chest roll) draw from it.

Saved piece data (`addAdditionalSaveData`): the base keys of 36-1 section 6.7 (`id`, `BB`, `O`, `GD`); `BridgeEndFiller` adds `Seed` (int); `MonsterThrone` adds `Mob` (boolean, the spawner flag); the two turn pieces add `Chest`
(boolean, the pending chest flag). The generation depth `GD` is stored. All other fortress pieces add nothing.

---

## 5. A. Piece geometry (block lists)

Notation of section 1.2. Each piece's local box is `width x height x depth` as in the catalogue; the floor layer is local y 0. Every list ends with the supporting columns. The lists are **ordered operation tables** (data), not prose about control flow: where a later operation overlaps an earlier one the later one wins, so the order is part of the specification; the repetition markers (`loop`, `for i`) and guard markers (`[only when ...]`) only compress identical operations over a parameter and carry no other meaning.

### 5.1 `BridgeCrossing` and `StartPiece` (19 x 10 x 19)

```
fill (7,3,0)-(11,4,18) NB
fill (0,3,7)-(18,4,11) NB
fill (8,5,0)-(10,7,18) AIR
fill (0,5,8)-(18,7,10) AIR
fill (7,5,0)-(7,5,7) NB
fill (7,5,11)-(7,5,18) NB
fill (11,5,0)-(11,5,7) NB
fill (11,5,11)-(11,5,18) NB
fill (0,5,7)-(7,5,7) NB
fill (11,5,7)-(18,5,7) NB
fill (0,5,11)-(7,5,11) NB
fill (11,5,11)-(18,5,11) NB
fill (7,2,0)-(11,2,5) NB
fill (7,2,13)-(11,2,18) NB
fill (7,0,0)-(11,1,3) NB
fill (7,0,15)-(11,1,18) NB
col  for x 7..11, z 0..2: col(x,-1,z) then col(x,-1,18-z)
fill (0,2,7)-(5,2,11) NB
fill (13,2,7)-(18,2,11) NB
fill (0,0,7)-(3,1,11) NB
fill (15,0,7)-(18,1,11) NB
col  for x 0..2, z 7..11: col(x,-1,z) then col(18-x,-1,z)
```

The deck is two crossing 5-wide strips of nether brick (y 3 to 4) with a 3-wide corridor of air above (y 5 to 7) and 1-high low walls at y 5 along both sides of every arm.

### 5.2 `BridgeStraight` (5 x 10 x 19)

```
fill (0,3,0)-(4,4,18) NB
fill (1,5,0)-(3,7,18) AIR
fill (0,5,0)-(0,5,18) NB
fill (4,5,0)-(4,5,18) NB
fill (0,2,0)-(4,2,5) NB
fill (0,2,13)-(4,2,18) NB
fill (0,0,0)-(4,1,3) NB
fill (0,0,15)-(4,1,18) NB
col  for x 0..4, z 0..2: col(x,-1,z) then col(x,-1,18-z)
fill (0,1,1)-(0,4,1) FENCE(N,E,S)
fill (0,3,4)-(0,4,4) FENCE(N,E,S)
fill (0,3,14)-(0,4,14) FENCE(N,E,S)
fill (0,1,17)-(0,4,17) FENCE(N,E,S)
fill (4,1,1)-(4,4,1) FENCE(N,S,W)
fill (4,3,4)-(4,4,4) FENCE(N,S,W)
fill (4,3,14)-(4,4,14) FENCE(N,S,W)
fill (4,1,17)-(4,4,17) FENCE(N,S,W)
```

### 5.3 `BridgeEndFiller` (5 x 10 x 8)

The only piece that draws random numbers while placing. It builds a private source `RandomSource.createThreadLocalInstance(Seed)` (a Java-LCG source, 10 section 2.6) from the stored `Seed` and draws from it in this order (so the result is the same in every chunk):

1. For `x` in 0..4, for `y` in 3..4: `n = nextInt(8)`; `fill (x,y,0)-(x,y,n) NB` (a strip of 1 to 8 cells along z: the floor stub; the draw is made per (x, y) pair with x outer, y inner).
2. `n = nextInt(8)`; `fill (0,5,0)-(0,5,n) NB`; then `n = nextInt(8)`; `fill (4,5,0)-(4,5,n) NB` (the two rail stubs).
3. For `x` in 0..4: `n = nextInt(5)`; `fill (x,2,0)-(x,2,n) NB`.
4. For `x` in 0..4, for `y` in 0..1: `n = nextInt(3)`; `fill (x,y,0)-(x,y,n) NB`.

That is 10 + 2 + 5 + 10 = 27 draws. No air is carved and no columns are filled: the piece is a ragged stub that ends a bridge arm.

### 5.4 `RoomCrossing` (7 x 9 x 7)

```
fill (0,0,0)-(6,1,6) NB
fill (0,2,0)-(6,7,6) AIR
fill (0,2,0)-(1,6,0) NB
fill (0,2,6)-(1,6,6) NB
fill (5,2,0)-(6,6,0) NB
fill (5,2,6)-(6,6,6) NB
fill (0,2,0)-(0,6,1) NB
fill (0,2,5)-(0,6,6) NB
fill (6,2,0)-(6,6,1) NB
fill (6,2,5)-(6,6,6) NB
fill (2,6,0)-(4,6,0) NB
fill (2,5,0)-(4,5,0) FENCE(E,W)
fill (2,6,6)-(4,6,6) NB
fill (2,5,6)-(4,5,6) FENCE(E,W)
fill (0,6,2)-(0,6,4) NB
fill (0,5,2)-(0,5,4) FENCE(N,S)
fill (6,6,2)-(6,6,4) NB
fill (6,5,2)-(6,5,4) FENCE(N,S)
col  for x 0..6, z 0..6: col(x,-1,z)
```

### 5.5 `StairsRoom` (7 x 11 x 7)

```
fill (0,0,0)-(6,1,6) NB
fill (0,2,0)-(6,10,6) AIR
fill (0,2,0)-(1,8,0) NB
fill (5,2,0)-(6,8,0) NB
fill (0,2,1)-(0,8,6) NB
fill (6,2,1)-(6,8,6) NB
fill (1,2,6)-(5,8,6) NB
fill (0,3,2)-(0,5,4) FENCE(N,S)
fill (6,3,2)-(6,5,2) FENCE(N,S)
fill (6,3,4)-(6,5,4) FENCE(N,S)
put (5,2,5) NB
fill (4,2,5)-(4,3,5) NB
fill (3,2,5)-(3,4,5) NB
fill (2,2,5)-(2,5,5) NB
fill (1,2,5)-(1,6,5) NB
fill (1,7,1)-(5,7,4) NB
fill (6,8,2)-(6,8,4) AIR
fill (2,6,0)-(4,8,0) NB
fill (2,5,0)-(4,5,0) FENCE(E,W)
col  for x 0..6, z 0..6: col(x,-1,z)
```

### 5.6 `MonsterThrone` (7 x 8 x 9)

```
fill (0,2,0)-(6,7,7) AIR
fill (1,0,0)-(5,1,7) NB
fill (1,2,1)-(5,2,7) NB
fill (1,3,2)-(5,3,7) NB
fill (1,4,3)-(5,4,7) NB
fill (1,2,0)-(1,4,2) NB
fill (5,2,0)-(5,4,2) NB
fill (1,5,2)-(1,5,3) NB
fill (5,5,2)-(5,5,3) NB
fill (0,5,3)-(0,5,8) NB
fill (6,5,3)-(6,5,8) NB
fill (1,5,8)-(5,5,8) NB
put (1,6,3) FENCE(W)
put (5,6,3) FENCE(E)
put (0,6,3) FENCE(N,E)
put (6,6,3) FENCE(N,W)
fill (0,6,4)-(0,6,7) FENCE(N,S)
fill (6,6,4)-(6,6,7) FENCE(N,S)
put (0,6,8) FENCE(E,S)
put (6,6,8) FENCE(S,W)
fill (1,6,8)-(5,6,8) FENCE(E,W)
put (1,7,8) FENCE(E)
fill (2,7,8)-(4,7,8) FENCE(E,W)
put (5,7,8) FENCE(W)
put (2,8,8) FENCE(E)
put (3,8,8) FENCE(E,W)
put (4,8,8) FENCE(W)
spawner  once: if not yet placed and world pos of local (3,5,5) is inside the chunk box: set flag, set block SPAWNER (flags 2), setEntityId(blaze, random)
col  for x 0..6, z 0..6: col(x,-1,z)
```

The last three `put` rows (`y = 8`) lie one layer **above** the piece box (height 8, local y 0..7): the writing helpers clip to the chunk box, not to the piece box, so they are placed. The spawner sits at local `(3, 5, 5)`: the `Mob` flag is saved so the spawner is placed once even though every chunk replays the list; the test "world position inside the chunk box" makes only the chunk that holds
that block place it. The spawner is a vanilla `spawner` block entity set to the blaze entity with `setEntityId(blaze, random)` (the random is the generation random of the chunk pass; spawner state and rules: 31-7, 44-2 section 10.2).

### 5.7 `CastleEntrance` (13 x 14 x 13)

```
fill (0,3,0)-(12,4,12) NB
fill (0,5,0)-(12,13,12) AIR
fill (0,5,0)-(1,12,12) NB
fill (11,5,0)-(12,12,12) NB
fill (2,5,11)-(4,12,12) NB
fill (8,5,11)-(10,12,12) NB
fill (5,9,11)-(7,12,12) NB
fill (2,5,0)-(4,12,1) NB
fill (8,5,0)-(10,12,1) NB
fill (5,9,0)-(7,12,1) NB
fill (2,11,2)-(10,12,10) NB
fill (5,8,0)-(7,8,0) FENCE()
loop A, for k = 1, 3, 5, 7, 9, 11 (k+1 only when k < 11):
  fill (k,10,0)-(k,11,0) FENCE(E,W)
  fill (k,10,12)-(k,11,12) FENCE(E,W)
  fill (0,10,k)-(0,11,k) FENCE(N,S)
  fill (12,10,k)-(12,11,k) FENCE(N,S)
  put (k,13,0) NB
  put (k,13,12) NB
  put (0,13,k) NB
  put (12,13,k) NB
  [only when k != 11]
  put (k+1,13,0) FENCE(E,W)
  put (k+1,13,12) FENCE(E,W)
  put (0,13,k+1) FENCE(N,S)
  put (12,13,k+1) FENCE(N,S)
put (0,13,0) FENCE(N,E)
put (0,13,12) FENCE(E,S)
put (12,13,12) FENCE(S,W)
put (12,13,0) FENCE(N,W)
loop B, for k = 3, 5, 7, 9:
  fill (1,7,k)-(1,8,k) FENCE(N,S,W)
  fill (11,7,k)-(11,8,k) FENCE(N,E,S)
fill (4,2,0)-(8,2,12) NB
fill (0,2,4)-(12,2,8) NB
fill (4,0,0)-(8,1,3) NB
fill (4,0,9)-(8,1,12) NB
fill (0,0,4)-(3,1,8) NB
fill (9,0,4)-(12,1,8) NB
col  for x 4..8, z 0..2: col(x,-1,z) then col(x,-1,12-z); then for x 0..2, z 4..8: col(x,-1,z) then col(12-x,-1,z)
fill (5,5,5)-(7,5,7) NB
fill (6,1,6)-(6,4,6) AIR
put (6,0,6) NB
put (6,5,6) LAVA
lava tick  if world pos of local (6,5,6) is inside the chunk box: schedule a lava fluid tick there (delay 0)
```

A tall hall with a lava well in the middle (a lava source at `(6,5,6)` on a nether brick cell at `(6,0,6)`, the column `(6,1..4,6)` cleared). Placing the lava source already schedules a fluid tick through `placeBlock` (36-1 section 6.5); the explicit tick is a second, later one.

### 5.8 `CastleStalkRoom` (13 x 14 x 13) (the nether wart room)

```
fill (0,3,0)-(12,4,12) NB
fill (0,5,0)-(12,13,12) AIR
fill (0,5,0)-(1,12,12) NB
fill (11,5,0)-(12,12,12) NB
fill (2,5,11)-(4,12,12) NB
fill (8,5,11)-(10,12,12) NB
fill (5,9,11)-(7,12,12) NB
fill (2,5,0)-(4,12,1) NB
fill (8,5,0)-(10,12,1) NB
fill (5,9,0)-(7,12,1) NB
fill (2,11,2)-(10,12,10) NB
loop A, for k = 1, 3, 5, 7, 9, 11:
  fill (k,10,0)-(k,11,0) FENCE(E,W)
  fill (k,10,12)-(k,11,12) FENCE(E,W)
  fill (0,10,k)-(0,11,k) FENCE(N,S)
  fill (12,10,k)-(12,11,k) FENCE(N,S)
  put (k,13,0) NB
  put (k,13,12) NB
  put (0,13,k) NB
  put (12,13,k) NB
  [only when k != 11]
  put (k+1,13,0) FENCE(E,W)
  put (k+1,13,12) FENCE(E,W)
  put (0,13,k+1) FENCE(N,S)
  put (12,13,k+1) FENCE(N,S)
put (0,13,0) FENCE(N,E)
put (0,13,12) FENCE(E,S)
put (12,13,12) FENCE(S,W)
put (12,13,0) FENCE(N,W)
loop B, for k = 3, 5, 7, 9:
  fill (1,7,k)-(1,8,k) FENCE(N,S,W)
  fill (11,7,k)-(11,8,k) FENCE(N,E,S)
loop C, for i = 0..6 (z = i + 4):
  for x = 5..7:
    put (x,(5 + i),z) STAIRS(NORTH)
  [only when 5 <= z <= 8]
  fill (5,5,z)-(7,(i + 4),z) NB
  [only when 9 <= z <= 10]
  fill (5,8,z)-(7,(i + 4),z) NB
  [only when i >= 1]
  fill (5,(6 + i),z)-(7,(9 + i),z) AIR
loop D, for x = 5..7:
  put (x,12,11) STAIRS(NORTH)
fill (5,6,7)-(5,7,7) FENCE(N,E,S)
fill (7,6,7)-(7,7,7) FENCE(N,S,W)
fill (5,13,12)-(7,13,12) AIR
fill (2,5,2)-(3,5,3) NB
fill (2,5,9)-(3,5,10) NB
fill (2,5,4)-(2,5,8) NB
fill (9,5,2)-(10,5,3) NB
fill (9,5,9)-(10,5,10) NB
fill (10,5,4)-(10,5,8) NB
put (4,5,2) STAIRS(WEST)
put (4,5,3) STAIRS(WEST)
put (4,5,9) STAIRS(WEST)
put (4,5,10) STAIRS(WEST)
put (8,5,2) STAIRS(EAST)
put (8,5,3) STAIRS(EAST)
put (8,5,9) STAIRS(EAST)
put (8,5,10) STAIRS(EAST)
fill (3,4,4)-(4,4,8) SOUL_SAND
fill (8,4,4)-(9,4,8) SOUL_SAND
fill (3,5,4)-(4,5,8) NETHER_WART
fill (8,5,4)-(9,5,8) NETHER_WART
fill (4,2,0)-(8,2,12) NB
fill (0,2,4)-(12,2,8) NB
fill (4,0,0)-(8,1,3) NB
fill (4,0,9)-(8,1,12) NB
fill (0,0,4)-(3,1,8) NB
fill (9,0,4)-(12,1,8) NB
col  for x 4..8, z 0..2: col(x,-1,z) then col(x,-1,12-z); then for x 0..2, z 4..8: col(x,-1,z) then col(12-x,-1,z)
```

Loops A and B and the first eleven fills equal the castle entrance's (the entrance has the lava well where the stalk room has the wart beds). Loop C builds the staircase of nether brick stairs facing north rising in the
middle of the north half (x 5..7); the two `fill` rows below it fill the stair body: for `z` 5 to 8 up to height `i + 4`, for `z` 9 and 10 from y 8 up to `i + 4`; the AIR row clears the headroom above each step. The beds are
two soul sand strips `(3..4, 4, 4..8)` and `(8..9, 4, 4..8)` topped by nether wart at `y = 5`, flanked by stairs facing inward.

### 5.9 `CastleSmallCorridorPiece` (5 x 7 x 5)

```
fill (0,0,0)-(4,1,4) NB
fill (0,2,0)-(4,5,4) AIR
fill (0,2,0)-(0,5,4) NB
fill (4,2,0)-(4,5,4) NB
fill (0,3,1)-(0,4,1) FENCE(N,S)
fill (0,3,3)-(0,4,3) FENCE(N,S)
fill (4,3,1)-(4,4,1) FENCE(N,S)
fill (4,3,3)-(4,4,3) FENCE(N,S)
fill (0,6,0)-(4,6,4) NB
col  for x 0..4, z 0..4: col(x,-1,z)
```

(The roof row `fill (0,6,0)-(4,6,4)` precedes the columns.)

### 5.10 `CastleSmallCorridorCrossingPiece` (5 x 7 x 5)

```
fill (0,0,0)-(4,1,4) NB
fill (0,2,0)-(4,5,4) AIR
fill (0,2,0)-(0,5,0) NB
fill (4,2,0)-(4,5,0) NB
fill (0,2,4)-(0,5,4) NB
fill (4,2,4)-(4,5,4) NB
fill (0,6,0)-(4,6,4) NB
col  for x 0..4, z 0..4: col(x,-1,z)
```

### 5.11 `CastleSmallCorridorLeftTurnPiece` (5 x 7 x 5)

```
fill (0,0,0)-(4,1,4) NB
fill (0,2,0)-(4,5,4) AIR
fill (4,2,0)-(4,5,4) NB
fill (4,3,1)-(4,4,1) FENCE(N,S)
fill (4,3,3)-(4,4,3) FENCE(N,S)
fill (0,2,0)-(0,5,0) NB
fill (0,2,4)-(3,5,4) NB
fill (1,3,4)-(1,4,4) FENCE(E,W)
fill (3,3,4)-(3,4,4) FENCE(E,W)
chest  if needs-chest and world pos of local (3,2,3) is inside the chunk box: clear flag, createChest(loot nether_bridge) at (3,2,3)
fill (0,6,0)-(4,6,4) NB
col  for x 0..4, z 0..4: col(x,-1,z)
```

### 5.12 `CastleSmallCorridorRightTurnPiece` (5 x 7 x 5)

```
fill (0,0,0)-(4,1,4) NB
fill (0,2,0)-(4,5,4) AIR
fill (0,2,0)-(0,5,4) NB
fill (0,3,1)-(0,4,1) FENCE(N,S)
fill (0,3,3)-(0,4,3) FENCE(N,S)
fill (4,2,0)-(4,5,0) NB
fill (1,2,4)-(4,5,4) NB
fill (1,3,4)-(1,4,4) FENCE(E,W)
fill (3,3,4)-(3,4,4) FENCE(E,W)
chest  if needs-chest and world pos of local (1,2,3) is inside the chunk box: clear flag, createChest(loot nether_bridge) at (1,2,3)
fill (0,6,0)-(4,6,4) NB
col  for x 0..4, z 0..4: col(x,-1,z)
```

### 5.13 `CastleCorridorStairsPiece` (5 x 14 x 10)

For `i` in 0..9 (`z = i`) with `a = max(1, 7 - i)` and `b = min(max(a + 5, 14 - i), 13)`, in this order:

```
fill (0,0,z)-(4,a,z) NB
fill (1,(a + 1),z)-(3,(b - 1),z) AIR
[only when i <= 6]
  put (1,(a + 1),z) STAIRS(SOUTH)
  put (2,(a + 1),z) STAIRS(SOUTH)
  put (3,(a + 1),z) STAIRS(SOUTH)
fill (0,b,z)-(4,b,z) NB
fill (0,(a + 1),z)-(0,(b - 1),z) NB
fill (4,(a + 1),z)-(4,(b - 1),z) NB
[only when i is even]
  fill (0,(a + 2),z)-(0,(a + 3),z) FENCE(N,S)
  fill (4,(a + 2),z)-(4,(a + 3),z) FENCE(N,S)
col  for x 0..4: col(x,-1,z)
```

The floor fill, the air fill, the roof row, the side walls and the columns run for every `i` from 0 to 9. Only the `STAIRS(SOUTH)` row (three stairs at x 1..3, y `a + 1`) is guarded by `i <= 6`; only the two fence fills are guarded by `i` being even (`(i & 1) == 0`). The values per `i` are: `a` = 7, 6, 5, 4, 3, 2, 1, 1, 1, 1 and `b` = 13, 13, 12, 11, 10, 9, 8, 7, 6, 6. So the floor top falls by one per cell from y 7 at
`z = 0` to y 1 at `z = 6` and stays at 1 for `z = 7..9`, while the ceiling falls from 13 to 6. The corridor is entered at its high end (`z = 0`); its forward child anchor is at the box's `minY + 0`, the low end, and the box's
`offY` is -7, so each stairs piece lowers the corridor by 7 blocks relative to the corridor before it.

### 5.14 `CastleCorridorTBalconyPiece` (9 x 7 x 9)

```
fill (0,0,0)-(8,1,8) NB
fill (0,2,0)-(8,5,8) AIR
fill (0,6,0)-(8,6,5) NB
fill (0,2,0)-(2,5,0) NB
fill (6,2,0)-(8,5,0) NB
fill (1,3,0)-(1,4,0) FENCE(E,W)
fill (7,3,0)-(7,4,0) FENCE(E,W)
fill (0,2,4)-(8,2,8) NB
fill (1,1,4)-(2,2,4) AIR
fill (6,1,4)-(7,2,4) AIR
fill (1,3,8)-(7,3,8) FENCE(E,W)
put (0,3,8) FENCE(E,S)
put (8,3,8) FENCE(S,W)
fill (0,3,6)-(0,3,7) FENCE(N,S)
fill (8,3,6)-(8,3,7) FENCE(N,S)
fill (0,3,4)-(0,5,5) NB
fill (8,3,4)-(8,5,5) NB
fill (1,3,5)-(2,5,5) NB
fill (6,3,5)-(7,5,5) NB
fill (1,4,5)-(1,5,5) FENCE(E,W)
fill (7,4,5)-(7,5,5) FENCE(E,W)
col  for z 0..5, x 0..8: col(x,-1,z)
```

---

## 6. A. Chests, the blaze spawner, loot and spawns

### 6.1 Chests (the two turn pieces)

The constructor draws `nextInt(3)`; the chest flag is true when the result is 0 (one in three). During `postProcess`, after the walls and before the roof, if the flag is set and the world position of the chest cell lies inside the chunk
write box, the flag is cleared and `createChest(level, box, random, x, y, z, chests/nether_bridge)` places the chest (36-1 section 6.5: nothing happens if the cell holds a chest already; the state is a chest oriented by `reorient`; `setBlock(..., 2)`;
if the block entity is a chest its loot table is set with seed `random.nextLong()`). Cells: left turn local `(3,2,3)`, right turn local `(1,2,3)`. Because the flag is saved, a chest straddling no chunk border is placed exactly once.

### 6.2 Loot (`chests/nether_bridge`, data)

Shape (read): a `chest` loot table (`random_sequence` `minecraft:chests/nether_bridge`) with two pools. Pool 1: `rolls` uniform 2 to 4, 13 item entries of total weight 78 (diamond 5, iron ingot 5, gold ingot 15, golden sword 5, golden chestplate 5, flint and steel 5, nether wart 5, saddle 10, golden/copper/iron/diamond horse armor 8/5/5/3, obsidian 2; five entries carry a `set_count` uniform modifier). Pool 2: 1 roll over an empty entry of weight 14 and one
`rib_armor_trim_smithing_template` entry of weight 1 (a one in 15 chance). (The roller is 26.)

### 6.3 Spawns

* The fortress definition's `spawn_overrides.monster` (`bounding_box` `piece`, five entries: blaze weight 10 count uniform 2 to 3, zombified piglin 5 count 4, wither skeleton 8 count 5, skeleton 2 count 5, magma cube 3 count 4), read from
  `fortress.json`, is identical to the hard-coded `NetherFortressStructure.FORTRESS_ENEMIES` list (entries and weights compared). 44-2 sections 8.1 and 8.4 define when each list applies: the hard-coded list is used when the block under the spawn
  position is nether bricks and the position is inside the **whole** fortress box; otherwise the override applies inside any **piece** box.
* The throne's blaze spawner: section 5.6. No other fortress piece holds a spawner or entity.

---

## 7. A. Worked examples

### 7.1 Start piece and its three exits (orientation NORTH)

Chunk (0, 0): the start anchor is `(2, 64, 2)`; the box is `(2,64,2)-(20,73,20)`. Suppose the random gave orientation NORTH. `addChildren` calls Forward(8, 3, bridge), Left(3, 8, bridge), Right(3, 8, bridge):

| Child | Anchor and direction (section 4.1) | If it is a `BridgeStraight` (offsets -1, -3, 0; 5, 10, 19; section 4.2) |
|---|---|---|
| Forward | `(2+8, 64+3, 2-1)` = `(10, 67, 1)`, `NORTH` | `orientBox(10,67,1,-1,-3,0,5,10,19,NORTH)`: x 9..13, z `1-19+1` = -17 .. 1, y 64..73: box `(9,64,-17)-(13,73,1)` |
| Left | `(2-1, 64+3, 2+8)` = `(1, 67, 10)`, `WEST` | `orientBox(1,67,10,-1,-3,0,5,10,19,WEST)`: x `1-19+1` = -17 .. 1, z `10-1` = 9 .. 13: box `(-17,64,9)-(1,73,13)` |
| Right | `(20+1, 64+3, 2+8)` = `(21, 67, 10)`, `EAST` | `orientBox(21,67,10,-1,-3,0,5,10,19,EAST)`: x 21..39, z 9..13: box `(21,64,9)-(39,73,13)` |

Each new box touches the start box (z = 1 against 2; x = 1 against 2; x = 21 against 20) and does not intersect it. The same start with orientation EAST gives the forward child at `(21, 67, 10)` direction EAST (the same box as the NORTH right child), the left child (north of an east-facing piece): Left(3, 8)
with orientation EAST is `(minX+q, minY+p, minZ-1)` with `p = 3`, `q = 8`: `(10, 67, 1)` direction NORTH, and Right is `(minX+8, minY+3, maxZ+1)` = `(10, 67, 21)` direction SOUTH.

Local-to-world check for the NORTH forward `BridgeStraight` (box x 9..13, z -17..1): `worldX = minX + x = 9 + x`, `worldZ = maxZ - z = 1 - z`; the local cell (2, 3, 18) of the first `fill` is `(11, 67, -17)`, the far end of the deck, and the forward child of
this piece (Forward(1, 3)) is anchored at `(9+1, 64+3, -17-1)` = `(10, 67, -18)` direction NORTH.

### 7.2 The first draws of a generation

`start = BridgeCrossing(...)`: draw 1 `nextInt(4)` (orientation). Then the three children: for each, `generatePiece` computes `total = 70` (all five limited entries have room), draws `nextInt(70)`: values 0..29 select `BridgeStraight`, 30..39
`BridgeCrossing`, 40..49 `RoomCrossing`, 50..59 `StairsRoom`, 60..64 `MonsterThrone`, 65..69 `CastleEntrance`. A selected piece whose box fails the test passes to the next table entry without a draw.

### 7.3 Table exhaustion

After 4 bridge crossings, 4 room crossings, 3 stairs rooms, 2 thrones and 1 entrance have been created (14 limited pieces) the bridge list holds only `BridgeStraight`; `total` is -1; every further child anchor
on the bridge level becomes a `BridgeEndFiller` (still consuming one `nextInt()` each time one is created). Likewise the castle list after 5 crossings, 10 + 10 turns, 3 stairs, 2 balconies and 2 stalk rooms.

### 7.4 Vertical placement

If the grown fortress has a box of height 28, `room = 23 - 28 = -5` (not > 1), so the new minimum y is 48 and the fortress spans 48..75; if the height is 20, `room = 3` and the minimum y is `48 + nextInt(3)`, one of 48, 49, 50.

---

## 8. B. End city: structure and start

### 8.1 Definition (data, 38 section 10)

`worldgen/structure/end_city.json`: type `end_city`, biomes tag `has_structure/end_city` (`end_highlands`, `end_midlands`), `spawn_overrides` empty, step `surface_structures`, no `terrain_adaptation` (the beardifier is
0 in the End). Structure set `end_cities`: `random_spread`, `spacing` 20, `separation` 11, `spread_type` triangular, `salt` 10387313, one entry of weight 1 (36-1 section 4.3 for the placement; 38 section 10).

### 8.2 `EndCityStructure.findGenerationPoint(ctx)`

1. `chunk = ctx.chunkPos()`; `x = chunk.minBlockX + 7`, `z = chunk.minBlockZ + 7` (`getBlockX(7)`, `getBlockZ(7)`).
2. If `ctx.couldValidBiomeExistInTerrainColumn(x, z)` is false, no structure. That test (36-1 section 5.1) samples the noise biome at quart `(x >> 2, z >> 2)` for every quart `y` from `fromBlock(minY - 1)` to
   `fromBlock(maxY)` of the dimension, and passes if any sampled biome satisfies the structure's biome predicate.
3. `rotation = Rotation.getRandom(ctx.random())`: one `nextInt(4)` over the order `NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90` (read from `Rotation.$values`). This is the first random draw.
4. `pos = (x, lowestY, z)` where `lowestY = Structure.getLowestY(ctx, x, z, sx, sz)` with `(sx, sz)` = `(5, 5)`, `(-5, 5)`, `(-5, -5)`, `(5, -5)` for the rotations `NONE`, `CLOCKWISE_90`, `CLOCKWISE_180`, `COUNTERCLOCKWISE_90`
   (36-1 section 5.4 `getLowestYIn5by5Box`): the minimum of the four `WORLD_SURFACE_WG` first-occupied heights at the corners `(x, z)`, `(x, z + sz)`, `(x + sx, z)`, `(x + sx, z + sz)`.
5. If `lowestY < 60`, no structure (so a city is never built on or under a low island edge).
6. Otherwise the stub position is `pos` and its consumer is `generatePieces(builder, pos, rotation, ctx)`: it calls `EndCityPieces.startHouseTower(ctx.structureTemplateManager(), pos, rotation, list, ctx.random())` with a
   fresh list and then adds every piece of that list to the builder in list order. The biome check of the stub (36-1 section 5.3) is made on `pos` before this consumer runs.

No terrain adaptation and no vertical shift follow: the first piece sits with its template origin on `pos`.

---

## 9. B. The template piece, connection arithmetic and data markers

### 9.1 `EndCityPiece` (registered id `ecp`, 36-1 section 2.4)

A `TemplateStructurePiece` (36-2) with: template `minecraft:end_city/<name>` (default namespace, the string `end_city/` followed by the short name), generation depth 0 at creation, orientation `NORTH`
(the base constructor calls `setOrientation(NORTH)`; the piece's `rotation`/`mirror` fields come from the place settings), and the place settings made by `makeSettings(overwrite, rotation)`:

| Setting | Value |
|---|---|
| `ignoreEntities` | true |
| processors | exactly one block-ignore processor: `BlockIgnoreProcessor.STRUCTURE_BLOCK` (ignores `structure_block` cells only) when `overwrite` is true, `STRUCTURE_AND_AIR` (ignores `air` and `structure_block` cells) when `overwrite` is false |
| rotation | the piece's rotation |
| mirror, pivot | defaults (mirror `NONE`, pivot `(0, 0, 0)`) |

So **`overwrite = true` means template air is written** (the piece carves its volume empty), **`false` means template air is skipped** (what is already there stays). The structure blocks (data markers) are never written in
either case. Saved data (36-1 section 6.7 base keys, plus the template-piece keys of 36-2: `Template` (the short name), `TPX`, `TPY`, `TPZ`) and: `Rot` (the rotation, legacy codec) and `OW` (boolean, true when the first processor is `STRUCTURE_BLOCK`).
The box is recomputed from the template when the piece is loaded.

### 9.2 `addPiece(manager, parent, offset, name, rotation, overwrite)`

1. Create a new piece with template `name`, template position = the **parent's template position**, place settings `makeSettings(overwrite, rotation)`.
2. `connected = calculateConnectedPosition(parent.placeSettings, offset, newPiece.placeSettings, (0,0,0))` = `T(offset, parent.rotation) - T((0,0,0), new.rotation)` where `T(p, r)` is `StructureTemplate.transform` with
   mirror `NONE` and pivot `(0,0,0)` (36-2): the second term is always `(0,0,0)`.
3. Move the new piece by `connected` (its template position and its box).

So **`newPos = parent.templatePosition + R(parent.rotation, offset)`**, where the rotation about the origin (looking down with +z south) is, from `StructureTemplate.transform` with pivot 0:

| Rotation | `(x, y, z)` becomes |
|---|---|
| `NONE` | `(x, y, z)` |
| `CLOCKWISE_90` | `(-z, y, x)` |
| `CLOCKWISE_180` | `(-x, y, -z)` |
| `COUNTERCLOCKWISE_90` | `(z, y, -x)` |

The new piece's own rotation does not enter the position. Its box is `getBoundingBox` of the template: with `s` the template size, the two corners `T((0,0,0))` = `(0,0,0)` and `T((s.x-1, s.y-1, s.z-1))`, made into a box by per-axis
min and max and moved by `newPos`. Rotation composition: `a.getRotated(b)` adds the quarter turns clockwise modulo 4 (`NONE` 0, `CLOCKWISE_90` 1, `CLOCKWISE_180` 2, `COUNTERCLOCKWISE_90` 3).

### 9.3 Writing (`TemplateStructurePiece.postProcess`)

1. Set the place settings' bounding box to the chunk write box and recompute the piece box.
2. `template.placeInWorld(level, pos, pos, settings, random, 2)` (36-2). If it placed something: take every `structure_block` of the template with its NBT (`filterBlocks`, cells inside the settings box after the transform);
   for each whose `mode` is `DATA` call `handleDataMarker(metadata, markerPos, level, random, box)`. Jigsaw blocks (none in the End city templates) would be replaced by their `final_state`.

### 9.4 Data markers (`EndCityPiece.handleDataMarker`)

The metadata string is tested by **prefix**, in this order:

| Prefix | Effect |
|---|---|
| `Chest` | `p = markerPos.below()`; if `p` is inside the chunk box: `RandomizableContainer.setBlockEntityLootTable(level, random, p, chests/end_city_treasure)`: if the block entity at `p` is a lootable container, set its loot table and the seed `random.nextLong()`. (The template holds a chest block under the marker; the marker itself is not placed.) |
| `Sentry` | only if `markerPos` is inside the chunk box and `Level.isInSpawnableBounds(markerPos)`: create a `shulker` with reason `STRUCTURE`, `setPos(x + 0.5, y, z + 0.5)`, add it to the world. **No `finalizeSpawn`, no persistence flag**: the shulker has default attach face and colour, and its ordinary despawn rule applies (`Mob.removeWhenFarAway` is true and `Shulker` does not override it; 18 section 6). |
| `Elytra` | same position tests: create an `ItemFrame` at `markerPos` facing `rotation.rotate(Direction.SOUTH)` of the piece (clockwise-90 turns south into west) holding one `elytra` (`setItem(stack, false)`), add it to the world. |
| anything else | nothing |

The `Chest` test is made first, so a marker named `Chest...` never reaches the entity branches. Each marker is handled by the chunk pass whose box contains it; the frame and shulker are therefore created once.

---

## 10. B. The section generators

### 10.1 Static state and the group rule

Four anonymous `SectionGenerator`s (`HOUSE_TOWER_GENERATOR`, `TOWER_GENERATOR`, `TOWER_BRIDGE_GENERATOR`, `FAT_TOWER_GENERATOR`) and two bridge tables:

| Table | Entries `(rotation, offset)` in order |
|---|---|
| `TOWER_BRIDGES` | `(NONE, (1,-1,0))`, `(CLOCKWISE_90, (6,-1,1))`, `(COUNTERCLOCKWISE_90, (0,-1,5))`, `(CLOCKWISE_180, (5,-1,6))` |
| `FAT_TOWER_BRIDGES` | `(NONE, (4,-1,0))`, `(CLOCKWISE_90, (12,-1,4))`, `(COUNTERCLOCKWISE_90, (0,-1,8))`, `(CLOCKWISE_180, (8,-1,12))` |

`startHouseTower` first calls `init()` on the four generators; only `TOWER_BRIDGE_GENERATOR` has state (`shipCreated`, reset to false: at most one ship per city).

`recursiveChildren(manager, generator, depth, parent, offset, list, random)` returns a boolean:

1. If `depth > 8` return false.
2. `group` = a new empty list. If `generator.generate(manager, depth, parent, offset, group, random)` returns false, return false: **the whole group is dropped** (the draws it made stay consumed).
3. `id = random.nextInt()` (drawn after the group is generated). For each piece of `group` in order: `piece.setGenDepth(id)`; `hit = first piece of list whose box intersects piece.box` (first in list order, via
   `StructurePiece.findCollisionPiece`); if `hit` exists and `hit.genDepth != parent.genDepth` (compared now), mark the group rejected and stop checking.
4. If rejected return false; else append all of `group` to `list` in order and return true.

The generation depth field therefore serves as a **group identifier**: a new group may overlap pieces of the parent's own group, but if the **first** colliding piece found belongs to another group the whole group is rejected (a later colliding piece of another
group is not examined: a quirk of using only the first hit). Nested groups are added into the enclosing group's list and take the enclosing group's id when that group is finished (step 3 runs again over all of its pieces, including the nested ones).
Pieces created by `startHouseTower` itself (not through `recursiveChildren`) keep generation depth 0.

### 10.2 `startHouseTower(manager, pos, rotation, list, random)`

All pieces share `rotation` = the structure rotation (section 8.2). `addPiece` offsets are relative to the previous piece (section 9.2). The flags are `overwrite`.

| # | Piece | Offset from the previous piece | overwrite |
|---|---|---|---|
| 1 | `base_floor` | at `pos` itself (no parent) | true |
| 2 | `second_floor_1` | `(-1, 0, -1)` | false |
| 3 | `third_floor_1` | `(-1, 4, -1)` | false |
| 4 | `third_roof` | `(-1, 8, -1)` | true |

Then `recursiveChildren(TOWER_GENERATOR, depth 1, parent = third_roof, offset = none, list, random)` (its result is ignored: a city may stop at the house). No random is drawn before step 5.

### 10.3 `HOUSE_TOWER_GENERATOR.generate(manager, depth, parent, offset, group, random)`

(`offset` is the position passed by `TOWER_BRIDGE_GENERATOR`; `rot` = the parent's rotation.) If `depth > 8` return false. Then:

1. Piece `base_floor` at `offset` relative to `parent`, overwrite true; `k = random.nextInt(3)`.
2. `k = 0`: add `base_roof` at `(-1, 4, -1)` (overwrite true). No recursion.
3. `k = 1`: add `second_floor_2` at `(-1, 0, -1)` (false), then `second_roof` at `(-1, 8, -1)` (false), then `recursiveChildren(TOWER_GENERATOR, depth + 1, second_roof, none, group, random)` (result ignored).
4. `k = 2`: add `second_floor_2` at `(-1, 0, -1)` (false), `third_floor_2` at `(-1, 4, -1)` (false), `third_roof` at `(-1, 8, -1)` (true), then `recursiveChildren(TOWER_GENERATOR, depth + 1, third_roof, none, group, random)` (ignored).
5. Return true.

### 10.4 `TOWER_GENERATOR.generate`

(`rot` = parent rotation; every added piece uses overwrite true.) In this order of random draws:

1. `tower_base` at `(3 + nextInt(2), -3, 3 + nextInt(2))` (the x draw first, then z). Then `tower_piece` at `(0, 7, 0)`.
2. `bridgeParent = (nextInt(3) == 0) ? the current piece (the tower_piece) : none`.
3. `n = 1 + nextInt(3)`.
4. For `i` = 0 .. n-1: add `tower_piece` at `(0, 4, 0)`; if `i < n - 1` **and** `nextBoolean()` is true, `bridgeParent = that new piece`. (The boolean is not drawn for the last `i`.)
5. If `bridgeParent` is set: for each `(r, off)` of `TOWER_BRIDGES` in order: if `nextBoolean()`: `bridge = addPiece(bridgeParent, off, "bridge_end", rot.getRotated(r), true)` and
   `recursiveChildren(TOWER_BRIDGE_GENERATOR, depth + 1, bridge, none, group, random)` (ignored). After the loop add `tower_top` at `(-1, 4, -1)` (relative to the **last** `tower_piece` added in step 4, not to the bridge parent) and return true.
6. Else (no bridge parent): if `depth == 7` add `tower_top` at `(-1, 4, -1)` and return true; otherwise return `recursiveChildren(FAT_TOWER_GENERATOR, depth + 1, last piece, none, group, random)` (its value is the generator's value: a failed fat tower drops this whole tower group).

### 10.5 `TOWER_BRIDGE_GENERATOR.generate`

(`parent` is a `bridge_end`; `rot` its rotation; `y` is a running height offset, initially 0.)

1. `n = nextInt(4) + 1`.
2. `p = addPiece(parent, (0, 0, -4), "bridge_piece", rot, true)`; `p.setGenDepth(-1)`.
3. Repeat `n` times: if `nextBoolean()`: `p = addPiece(p, (0, y, -4), "bridge_piece", rot, true)` and `y = 0`. Otherwise: if `nextBoolean()`: `p = addPiece(p, (0, y, -4), "bridge_steep_stairs", rot, true)`, else `p = addPiece(p, (0, y, -8), "bridge_gentle_stairs", rot, true)`;
   then `y = 4` in both stairs cases. (The first draw of each repetition chooses flat; stairs always raise the later pieces by 4.)
4. If `shipCreated` is false **and** `nextInt(10 - depth) == 0`: add `ship` (relative to `p`) at `(-8 + nextInt(8), y, -70 + nextInt(10))` (x draw first), `rot`, overwrite true, and set `shipCreated`. Otherwise
   (including when a ship exists already, in which case `nextInt` is not drawn): `recursiveChildren(HOUSE_TOWER_GENERATOR, depth + 1, p, (-3, y + 1, -11), group, random)`; if that returns false, **return false** (the whole bridge group is dropped).
5. `p = addPiece(p, (4, y, 0), "bridge_end", rot.getRotated(CLOCKWISE_180), true)`; `p.setGenDepth(-1)`. Return true. (`bridge_piece` first and last `bridge_end` carry depth -1 only until the caller's group step 3 of 10.1 overwrites it, but during step 4 the -1 of the first piece makes a house that touches
   it first be rejected.)

`10 - depth` is positive for every reachable depth (`depth <= 8`). A ship branch has no recursion: the ship is a dead end.

### 10.6 `FAT_TOWER_GENERATOR.generate`

(`rot` = parent rotation; overwrite true throughout.)

1. `fat_tower_base` at `(-3, 4, -3)`, then `fat_tower_middle` at `(0, 4, 0)`.
2. For `i` = 0 and 1: if `nextInt(3) == 0` leave the loop; else add `fat_tower_middle` at `(0, 8, 0)` and for each `(r, off)` of `FAT_TOWER_BRIDGES` in order: if `nextBoolean()`: `bridge = addPiece(last middle, off, "bridge_end", rot.getRotated(r), true)`,
   `recursiveChildren(TOWER_BRIDGE_GENERATOR, depth + 1, bridge, none, group, random)` (ignored).
3. `fat_tower_top` at `(-2, 8, -2)` relative to the last middle piece. Return true.

(So a fat tower has 1 to 3 middle pieces; each of the optional two has a 2 in 3 chance given the previous, and they stop at the first failure.)

### 10.7 Depth map and termination

`recursiveChildren` refuses depth 9 and above. Depth 1 is the first tower. Depth increments along a branch (read from the generators): a tower at depth `d` with a bridge parent calls the bridge generator at `d + 1`, whose house tower is at `d + 2`, whose tower is at `d + 3`; a tower with **no** bridge parent (and `d != 7`) calls the fat tower at `d + 1`, whose bridge generators get `d + 2`, so the house is at `d + 3` and the next tower at `d + 4`. The tower depths reachable from depth 1 are therefore 1, 4 and 5 (first step: +3 or +4), then 7 and 8 (from 4: +3 or +4) and 8 (from 5: +3); the set is {1, 4, 5, 7, 8} (computed). A branch holds at most three towers (for example 1, 4, 7 or 1, 5, 8). A tower at depth 7 with no bridge parent ends with `tower_top` instead of a fat tower. A tower at depth 8 with a bridge parent still ends in `tower_top` (its bridge calls are at depth 9, fail, and their results are ignored); a tower at depth 8 with **no** bridge parent drops its whole group, because the fat tower call at depth 9 fails and its value is returned. Every bridge group requires a successful house tower or ship; a failed house tower group (collision or depth) removes the bridge, so a bridge never ends in nothing.

---

## 11. B. Templates, markers, loot, spawns

### 11.1 The 20 files of `data/minecraft/structure/end_city/` (counted with `unzip -Z1 | grep -v '/$'`), sizes `x y z`, and data markers (local positions)

Block counts equal the volume (air cells are stored) in every file except `tower_base`, which stores 202 of its 343 cells (the missing cells are never written). 19 names are referenced by the code; `tower_floor` (7 x 4 x 7) is not referenced by any end city class.

| Template | Size | Markers |
|---|---|---|
| `base_floor` | 10 x 4 x 10 | Sentry (3,2,9), Sentry (6,2,9) |
| `base_roof` | 12 x 2 x 12 | none |
| `second_floor_1` | 12 x 8 x 12 | none |
| `second_floor_2` | 12 x 8 x 12 | Sentry (8,5,6) |
| `second_roof` | 14 x 2 x 14 | none |
| `third_floor_1` | 14 x 8 x 14 | none |
| `third_floor_2` | 14 x 8 x 14 | Sentry (2,5,2), Sentry (11,5,2), Chest (6,6,2) |
| `third_roof` | 16 x 2 x 16 | none |
| `tower_base` | 7 x 7 x 7 | none |
| `tower_piece` | 7 x 4 x 7 | none |
| `tower_top` | 9 x 5 x 9 | Sentry (4,3,4) |
| `fat_tower_base` | 13 x 4 x 13 | none |
| `fat_tower_middle` | 13 x 8 x 13 | Sentry (2,2,6), (10,2,6), (6,6,2), (6,6,10) |
| `fat_tower_top` | 17 x 6 x 17 | Chest (3,2,11), Chest (5,2,13) |
| `bridge_end` | 5 x 6 x 2 | none |
| `bridge_piece` | 5 x 6 x 4 | none |
| `bridge_steep_stairs` | 5 x 7 x 4 | none |
| `bridge_gentle_stairs` | 5 x 7 x 8 | none |
| `ship` | 13 x 24 x 29 | Sentry (6,4,8), Chest (5,5,7), Elytra (6,5,7), Chest (7,5,7), Sentry (8,6,27), Sentry (4,11,27) |
| `tower_floor` | 7 x 4 x 7 | none (unused) |

Totals over all templates: 13 `Sentry`, 5 `Chest`, 1 `Elytra` markers (agrees with 44-2 section 10.9). The block directly below every `Chest` marker is a chest block in the template (no loot table stored in the template); the block below a `Sentry` marker is air, a purpur block or a purpur stair or slab depending on the marker, and the block below the
`Elytra` marker is air. The ship also holds one brewing stand and one dragon wall head. No template holds an entity; no template holds a jigsaw block.

### 11.2 Loot (`chests/end_city_treasure`, data)

A `chest` table with two pools. Pool 1: `rolls` uniform 2 to 6, 25 entries of total weight 89 (diamonds, iron and gold ingots, emeralds and beetroot seeds with `set_count` uniform modifiers; a saddle; four kinds of horse armor; 15 entries with the
`enchant_with_levels` modifier, `levels` uniform 20 to 39, options tag `on_random_loot`: the sword, pickaxe, shovel and four armor pieces in iron and in diamond, plus a diamond spear, each of weight 3). Pool 2: 1 roll over an empty entry of weight 14 and a `spire_armor_trim_smithing_template` of weight 1
(a one in 15 chance). (The entry names are data; the roller and the modifier are 26 and 28.)

### 11.3 Spawns

`spawn_overrides` is empty: the End city has no natural-spawn override. Its shulkers come only from the `Sentry` markers (section 9.4); the elytra from the one frame on the ship.

---

## 12. B. Worked examples

### 12.1 The deterministic house (stub `(100, 60, 200)`)

The pieces chain by `newPos = parentPos + R(parentRotation, offset)` (section 9.2) and the box is the transformed template box (section 9.2; computed by hand and cross-checked with a script outside the repository):

| Piece | rotation `NONE`: template pos, box | rotation `CLOCKWISE_90`: template pos, box |
|---|---|---|
| `base_floor` (10x4x10) | `(100,60,200)`; `(100,60,200)-(109,63,209)` | `(100,60,200)`; `(91,60,200)-(100,63,209)` |
| `second_floor_1` (12x8x12) | `(99,60,199)`; `(99,60,199)-(110,67,210)` | `(101,60,199)`; `(90,60,199)-(101,67,210)` |
| `third_floor_1` (14x8x14) | `(98,64,198)`; `(98,64,198)-(111,71,211)` | `(102,64,198)`; `(89,64,198)-(102,71,211)` |
| `third_roof` (16x2x16) | `(97,72,197)`; `(97,72,197)-(112,73,212)` | `(103,72,197)`; `(88,72,197)-(103,73,212)` |

The `CLOCKWISE_90` column: the template corner `(s.x-1, s.z-1)` = `(9, 9)` becomes `(-9, 9)`, so the box extends from `pos.x - 9` to `pos.x`.

### 12.2 A tower on that house

`TOWER_GENERATOR` at depth 1 with parent `third_roof`, draws `nextInt(2)` = 0 for x and 0 for z (rotation `NONE`): `tower_base` at `(3,-3,3)` from the roof: `(100,69,200)`, box `(100,69,200)-(106,75,206)`; `tower_piece` (0,7,0): `(100,76,200)` box `(100,76,200)-(106,79,206)`; a second
`tower_piece` (0,4,0): `(100,80,200)` box `(100,80,200)-(106,83,206)`; `tower_top` (-1,4,-1): `(99,84,199)` box `(99,84,199)-(107,88,207)`. With `CLOCKWISE_90` the positions of `tower_base`, the first `tower_piece` and the second `tower_piece` are the same as for `NONE`, but `tower_top` differs: its offset is relative to the last `tower_piece` and is rotated by `(x,z) -> (-z,x)`, so `(-1,4,-1)` becomes `(1,4,-1)` and the position is `(101,84,199)`. The boxes are `(94,69,200)-(100,75,206)`, `(94,76,200)-(100,79,206)`, `(94,80,200)-(100,83,206)`, `(93,84,199)-(101,88,207)`.

### 12.3 A bridge and a ship

Suppose the second `tower_piece` above (rotation `NONE`) is the bridge parent and the draw for `TOWER_BRIDGES[1]` is true: `bridge_end` at `(6,-1,1)` with rotation `CLOCKWISE_90`: position `(106,79,201)`, box `(105,79,201)-(106,84,205)`. In `TOWER_BRIDGE_GENERATOR` (rotation `CLOCKWISE_90`, so offsets turn by `(x,z) -> (-z,x)`): the first `bridge_piece` offset `(0,0,-4)` -> `(4,0,0)`: `(110,79,201)`, box `(107,79,201)-(110,84,205)`. If the next repetition draws steep stairs (flat boolean false, stairs boolean true): `bridge_steep_stairs` at `(0,0,-4)`: `(114,79,201)`, box `(111,79,201)-(114,85,205)`; `y = 4`.
A ship with draws `a = 0`, `b = 0`: offset `(-8, 4, -70)` -> `(70, 4, -8)`: position `(184,83,193)`, box `(156,83,193)-(184,106,205)` (its west edge x = 156 lies 42 blocks east of the last bridge piece's east edge x = 114). The alternative branch, the house tower, uses offset `(-3, 5, -11)` -> `(11, 5, -3)`: `base_floor` at `(125,84,198)`, box `(116,84,198)-(125,87,207)`. In both branches the final `bridge_end` has rotation `CLOCKWISE_90.getRotated(CLOCKWISE_180)` = `COUNTERCLOCKWISE_90`
and offset `(4, 4, 0)` -> `(0, 4, 4)` from the last bridge piece.

### 12.4 Start rule

Chunk (3, -2) (min block `(48, -32)`): `x = 55`, `z = -25`. With rotation `CLOCKWISE_90` the corners tested are `(55,-25)`, `(55,-20)`, `(50,-25)`, `(50,-20)` (sizes `(-5, 5)`); the stub y is the minimum of those four heights, and the city is skipped when it is below 60.

---

## 13. C. Bastion remnant: use of the jigsaw engine

The bastion has **no code of its own**: it is a `jigsaw` structure (36-3 section 8) whose behaviour is the assembler of 36-3 sections 9 to 14 run over the data below. This part names the parameters, derives what they mean for the bastion and records
what is specific to its pools. The shared engine facts used here are: the start procedure (36-3 section 9), the attach rule and jigsaw order (36-3 section 4), the candidate loop and collision volumes (36-3 sections 10 and 13), the queue (36-3 section 11), the piece and the
placement of its template (36-3 section 14, 36-2 sections 5 and 6), jigsaw replacement (36-2 section 9.6) and the rule processor (36-2 section 8).

### 13.1 Parameters (`worldgen/structure/bastion_remnant.json`; 37-6 section 3.2)

| Field | Value | Effect |
|---|---|---|
| `start_pool` | `minecraft:bastion/starts` | four elements, weight 1 each, all `single_pool_element`, processor list `bastion_generic_degradation`, projection `rigid`; fallback `minecraft:empty` |
| `start_jigsaw_name` | absent | the start piece's origin is the start position (36-3 section 9.3) |
| `size` | 6 | pieces exist down to depth 6; a piece at depth 6 is expanded with fallback elements only, so it gets no children (36-3 section 10.3 step 12) |
| `start_height` | `{absolute: 33}` | constant 33, no random draw (the anchor decodes to a constant height provider whose `sample` just resolves the anchor and ignores the random source; read) |
| `project_start_to_heightmap` | absent | the start y is 33 whatever the terrain |
| `use_expansion_hack` | false | `h = 0` (36-3 section 10.4) |
| `max_distance_from_center` | 80 | horizontal radius 80 about the start box centre; the vertical bound covers the whole dimension height (37-6 Open question 1) |
| `pool_aliases`, `dimension_padding`, `liquid_settings` | absent | no aliases; zero padding; `apply_waterlogging` |
| `step`, `terrain_adaptation`, `spawn_overrides` | `surface_structures`, none, `{}` | no beardifier; no override of any spawn list |

All four closures (section 14) contain only elements of type `single_pool_element` with projection `rigid` (counted over every element of every pool of the four closures: 40 + 64 + 72 + 21 element entries), so every connection is purely geometric (`Yj = Y0 + d`, 36-3 section 10.3 step 3): the bastion
never follows the terrain after its start. All 637 jigsaw blocks of the 167 bastion templates have default priorities (the keys `placement_priority` and `selection_priority` are absent in every one), so the queue is first-in first-out and the jigsaw order of a piece is the plain shuffle of 36-3 section 4.3.

### 13.2 The start (`JigsawStructure.findGenerationPoint` and `JigsawPlacement.addPieces`)

1. `pos = (chunk.minBlockX, 33, chunk.minBlockZ)` (the height provider is sampled first, with no draw).
2. `rotation = Rotation.getRandom(random)`: **first draw**, one `nextInt(4)` over `NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90`.
3. `element = pool.getRandomTemplate(random)`: **second draw**, `nextInt(4)` over the expanded list of the four starts (index 0 units, 1 hoglin stable, 2 treasure, 3 bridge, in pool order). So the four variants are equally likely given a start in the chunk.
4. The piece origin is `pos`; its box is the template's box for the rotation at `pos` (36-2 section 3.3); `groundLevelDelta` is 1 (`StructurePoolElement` default); the piece is moved vertically by `33 - (box.minY + 1)` = -1, so the start box has `minY = 32`.
5. `cx = (box.maxX + box.minX) / 2`, `cz = (box.maxZ + box.minZ) / 2` (Java integer division, truncating toward zero); the stub is `(cx, 33, cz)`; its biome (noise biome at that block position) must be in `has_structure/bastion_remnant` (37-6 section 8).
6. The callback then runs the assembler (36-3 section 9.7) with depth limit 6.

Start geometry for chunk (0, 0) and rotation `NONE` (the box is `(0, 32, 0)` to `(sx-1, 31+sy, sz-1)`):

| Variant | Start template | Size `x y z` | Box | Centre `(cx, cz)` | Stored cells | Jigsaw blocks |
|---|---|---|---|---|---|---|
| housing units | `bastion/units/air_base` | 46 x 24 x 46 | `(0,32,0)-(45,55,45)` | (22, 22) | 23447 (23444 air) | 3 |
| hoglin stable | `bastion/hoglin_stable/air_base` | 30 x 24 x 48 | `(0,32,0)-(29,55,47)` | (14, 23) | 29938 (29936 air) | 2 |
| treasure room | `bastion/treasure/big_air_full` | 38 x 48 x 38 | `(0,32,0)-(37,79,37)` | (18, 18) | 27650 (27648 air) | 2 |
| bridge | `bastion/bridge/starting_pieces/entrance_base` | 16 x 32 x 32 | `(0,32,0)-(15,63,31)` | (7, 15) | 15836 (blackstone, bricks, 1494 air, 285 lava, ...) | 11 |

Rotated by `CLOCKWISE_90` the units box is x -45..0, z 0..45 (corner `(45, 45)` becomes `(-45, 45)`) and the centre `(-22, 22)`; by `CLOCKWISE_180` x -45..0, z -45..0, centre `(-22, -22)`; by `COUNTERCLOCKWISE_90` x 0..45, z -45..0, centre `(22, -22)` (the transform of section 9.2).

### 13.3 What the start templates are

Three of the four start templates are **air volumes**: almost every stored cell is `air`, plus two or three jigsaw blocks. Element settings include the block-ignore processor for structure blocks only, so template air is *written*: placing `air_base`,
`big_air_full` or the hoglin stable's `air_base` carves a large cavity in the netherrack into which the later pieces are built. The bridge start (`entrance_base`) is a built piece (blackstone, polished blackstone bricks, 285 lava cells) and carves only its own 1494 air cells.
The three air volumes' jigsaws lead to the first built pieces (section 14).

---

## 14. C. The four variants and their pool graphs

A variant is fixed by the start template; every later pool belongs to the variant's own family (a directory of `template_pool/bastion/`) or to the shared mob and block pools. The closures below were recomputed in this round by following every `pool` value of every jigsaw block of
every template and every element of every pool, starting from each start template; they agree with 37-6 section 5.

| Variant | Pools in closure | Templates in closure | Pool-element entries | Processor lists referenced (element count) | Chest blocks in the closure's templates |
|---|---|---|---|---|---|
| housing units (`units`) | 18 | 38 | 40 | `housing` 31; inline empty 9 | `bastion_other` 11 |
| hoglin stable (`hoglin_stable`) | 17 | 62 | 64 | `stable_degradation` 51; `side_wall_degradation` 2; inline empty 11 | `bastion_hoglin_stable` 2; `bastion_other` 8 |
| treasure room (`treasure`) | 22 | 66 | 72 | `treasure_rooms` 50; `high_wall` 10; `roof` 3; `bottom_rampart` 1; `high_rampart` 1; inline empty 7 | `bastion_treasure` 5; `bastion_other` 6; one **spawner** (section 15.4) |
| bridge (`bridge`) | 10 | 19 | 21 | `bastion_generic_degradation` 5; `rampart_degradation` 5; `bridge` 1; `entrance_replacement` 1; inline empty 9 | `bastion_bridge` 1; `bastion_other` 4 |

(Pool counts exclude `bastion/starts`; "templates" count each distinct template once including the start; the pool-element entries are the entries of the closure's pools. The three mob pools and `blocks/gold` are counted in the pools for the variants that reach them: `blocks/gold` for units and hoglin stable only, `mobs/hoglin` for every
variant but the treasure room, `mobs/piglin` and `mobs/piglin_melee` for all four.)

### 14.1 Shape of each family

* **Housing units.** The start's three jigsaws go to `units/center_pieces`, `units/walls/wall_bases` and `units/edge_wall_units`. The main chain of pools is `center_pieces -> pathways -> stages/stage_0 -> stage_1 -> stage_2 -> stage_3`, six
  hops from the start template, so with `size = 6` the stage_3 pieces can exist (depth 6) but their own connectors (gold blocks) cannot be served. The side chain is `walls/wall_bases` (recursive: it contains itself) leading to `ramparts`, `large_ramparts` and `edge_wall_units`; `rampart_plates` close ramparts; `fillers/stage_0` and `edges` feed stage 1.
* **Hoglin stable.** Start jigsaws: `starting_pieces` (aligned) and `wall_bases`. `starting_pieces` leads to `posts`, `stairs`, `small_stables/inner` and `large_stables/inner`; `stairs` is recursive (a stairs element's jigsaws point back to `stairs`); `posts` leads to `mirrored_starting_pieces` and `connectors`; an inner stable leads to the outer stable of the other size (large inner to small outer, small inner to large outer) and outer stables end the chain; the stables carry the hoglin and piglin connectors and the two hoglin-stable chests; `wall_bases -> walls/ramparts`.
* **Treasure room.** Start jigsaws: `treasure/bases` (aligned) and `treasure/entrances` (rollable). `bases -> walls/bottom, bases/centers, stairs, brains`; `brains -> connectors, roofs`; `connectors -> walls/mid, walls/top`; the wall pools carry `corners/*`, `extensions/*`, `walls/outer` and the mob connectors. `entrances -> ramparts` (recursive),
  `ramparts -> walls -> entrances`. The five treasure chests and the magma cube spawner are in `bases/centers/*` and `bases/lava_basin`; the ten "melee connectors" (section 15.2) are all in this family.
* **Bridge.** The only variant whose start is a solid built piece with many connectors: eleven jigsaws (`bridge/walls` left and right, seven `mobs/piglin`, one `bridge/connectors`, one `bridge/starting_pieces`). `bridge/starting_pieces` is recursive and leads to `bridge_pieces -> legs`, `connectors`; `walls -> ramparts -> rampart_plates`. The single `bastion_bridge` chest is in `bridge/starting_pieces/entrance`.

Every pool of the bastion has the fallback `minecraft:empty` and weights as listed in the data; the largest pool of the four closures has 15 entries (`hoglin_stable/stairs`).

---

## 15. C. Mobs, blocks, spawner, loot

### 15.1 Connectors and mob templates

The three "mob" pools and the two "block" pools hold single-purpose templates:

| Pool | Elements (weight): template -> result |
|---|---|
| `mobs/piglin` (total 10) | `mobs/melee_piglin` (1) -> a `piglin_brute`; `mobs/sword_piglin` (4) -> a `piglin` with a golden sword in the main hand; `mobs/crossbow_piglin` (4) -> a `piglin` with a crossbow; `mobs/empty` (1) -> nothing |
| `mobs/piglin_melee` (total 7) | `mobs/melee_piglin_always` (1) -> a `piglin_brute`; `mobs/melee_piglin` (5) -> a `piglin_brute`; `mobs/sword_piglin` (1) -> a sword `piglin` |
| `mobs/hoglin` (total 3) | `mobs/hoglin` (2) -> a `hoglin`; `mobs/empty` (1) -> nothing |
| `blocks/gold` (total 4) | `blocks/air` (3) -> air; `blocks/gold` (1) -> a gold block |

(`mobs/empty` and the block templates are used with the inline empty processor list and projection `rigid`.) Each mob template is 1 x 3 x 1 (the hoglin 2 x 3 x 2) with a single `jigsaw` block at its bottom (local `(0,0,0)`, the hoglin's at `(0,0,1)`), orientation `down_*`, joint `rollable`, `pool` and `target` `minecraft:empty`, `final_state` `minecraft:air`, and **name**:
`minecraft:mob_connector` for every mob template **except `melee_piglin_always`, whose connector is named `minecraft:melee_connector`**. The block templates are 1 x 1 x 1 jigsaws named `minecraft:block_connector`, joint `aligned`, with `final_state` `minecraft:gold_block` (`blocks/gold`) or `minecraft:air` (`blocks/air`).
The mob templates store one entity (cell `(0, 1, 0)`, `(1, 1, 1)` for the hoglin) and no block except air (the other cells of the template are air).

The parent-side connectors (in the family templates) are `up_*` jigsaws with pool `bastion/mobs/...` (or `blocks/gold`), `target` the child's connector name, and a `final_state` that is usually a solid block of the wall. The attach rule (36-3 section 4.1: `target(parent) == name(child)`) therefore
decides which elements of a pool can serve a given connector (section 15.2).

### 15.2 Which element a connector gets, and the piglin brute placement

For one connector the assembler tries the pool's expanded list in a shuffled order and the first candidate that **attaches** (attach rule, any of four rotations) and **fits** wins (36-3 section 10.2). A uniform shuffle makes the first attachable element win with probability proportional to
its weight among the attachable elements. Counted over the jigsaw blocks of every template in the four closures (each template once):

| Pool | `target` of the parent connector | Connectors per variant (units / hoglin stable / treasure / bridge) | Attachable elements | Result probabilities (if the 1 x 3 x 1 template fits) |
|---|---|---|---|---|
| `mobs/piglin` | `mob_connector` | 20 / 27 / 22 / 29 | all four | brute 1/10, sword piglin 4/10, crossbow piglin 4/10, nothing 1/10 |
| `mobs/piglin_melee` | `mob_connector` | 6 / 6 / 8 / 4 | `melee_piglin`, `sword_piglin` (the `melee_connector` of `melee_piglin_always` does not match) | brute 5/6, sword piglin 1/6 |
| `mobs/piglin_melee` | `melee_connector` | 0 / 0 / 10 / 0 | only `melee_piglin_always` (the others are named `mob_connector`) | brute with certainty |
| `mobs/hoglin` | `mob_connector` | 0 / 10 / 0 / 2 | both | hoglin 2/3, nothing 1/3 |
| `blocks/gold` | `block_connector` | 8 / 3 / 0 / 0 | both | air 3/4, gold block 1/4 |

So **piglin brutes** come from three sources: the guaranteed brute at each of the ten `melee_connector` connectors, which exist only in treasure-room templates (`bases/centers/center_0..3` (5 of them), `bases/lava_basin`, `ramparts/mid_wall_main`, `walls/bottom/wall_0`, `walls/mid/wall_0`, `walls/top/main_entrance`);
5 in 6 of the `piglin_melee` connectors with a `mob_connector` target; and 1 in 10 of the ordinary `piglin` connectors. Every variant has some. Hoglins appear in the hoglin stable (stables) and the bridge (its entrance), never in the housing units or the treasure room.

The probabilities are first-choice odds. A mob piece occupies two cells above its connector cell besides the connector cell; if those cells are already reserved by another piece, the first candidate fails the volume test and the next attachable candidate is tried (so the 1 x 1 x 1 `mobs/empty`, which fits more often, is
somewhat favoured when space is tight). The same applies to `blocks/*`.

### 15.3 Entity data and `finalizeSpawn` (36-2 section 5.6; 44-2 section 10.5)

The jigsaw element settings place entities (`ignoreEntities` false) and **finalize** them: for each stored entity inside the chunk box, create it from the stored tag with `Pos` replaced and `UUID` removed, reason `STRUCTURE`, yaw rotated by the piece rotation, and call `finalizeSpawn(difficulty at the block, STRUCTURE, null)` for a `Mob`.
The stored tags (read from `mobs/*.nbt`; the tag still carries old-format keys such as `HandItems`, `ArmorItems`, `Dimension`, `Brain` with empty memories): `PersistenceRequired` 1 on all three mobs (they never despawn), `CannotHunt` 1 on the piglin and brute templates, `CanPickUpLoot` 1 on piglins and brutes and 0 on the hoglin,
`Health` 16 (piglin), 50 (brute), 40 (hoglin), `CannotBeHunted` 1 on the hoglin template (read from `mobs/hoglin.nbt`); hands: golden sword (`sword_piglin`), crossbow (`crossbow_piglin`), empty (brutes). The effects of `finalizeSpawn` with reason `STRUCTURE` (read from `Piglin`, `PiglinBrute`, `Hoglin`):

| Mob | Effect |
|---|---|
| `piglin` | skips the baby roll and the random spawn weapon (both only happen for other reasons); then sets its memories (`PiglinAi.initMemories`); an **adult** then tries each of golden helmet, chestplate, leggings and boots **in that order**, one `random.nextFloat()` each, wearing the piece when the draw is `< 0.1` (it replaces whatever is in the slot); then rolls default equipment enchantments (`populateDefaultEquipmentEnchantments`, 28; chances in the list below); then the generic `Mob.finalizeSpawn` (below) |
| `piglin_brute` | sets its memories (`PiglinBruteAi.initMemories`); sets the main hand to a **golden axe** (always; the template's empty hands are overwritten); **no** call to `populateDefaultEquipmentEnchantments` (neither `PiglinBrute.finalizeSpawn` nor `Mob.finalizeSpawn` makes it), so the axe is not enchanted here; then the generic `Mob.finalizeSpawn` (below) |
| `hoglin` | `random.nextFloat() < 0.2` makes it a baby (this branch has no `STRUCTURE` exemption); then the chain `Animal` (no override) -> `AgeableMob.finalizeSpawn` (creates group data when it is null; makes a baby only when the group size is above 0, which it is not for a null start, so **no extra draw**) -> `PathfinderMob` (no override) -> the generic `Mob.finalizeSpawn` (below) |

The generic `Mob.finalizeSpawn` also runs for `piglin`, `piglin_brute` (`AbstractPiglin` has no override) and `hoglin`, with the level's random (`ServerLevelAccessor.getRandom`), after all the mob-specific draws above:

1. If the mob has no permanent `FOLLOW_RANGE` modifier with the id `RANDOM_SPAWN_BONUS_ID`, add one of operation `ADD_MULTIPLIED_BASE` whose value is `random.triangle(0, 0.11485)` (one triangle draw).
2. `setLeftHanded(random.nextFloat() < 0.05)` (one float draw). The stored `LeftHanded` 0 of the template is overwritten.

`populateDefaultEquipmentEnchantments` (read from `Mob`; called only by the piglin): first `enchantSpawnedWeapon` for the main hand with chance 0.25, then `enchantSpawnedArmor` with chance 0.5 for each of the four humanoid armor slots (`EquipmentSlot.VALUES` order, armor-type slots only). For one slot (`enchantSpawnedEquipment`): when the slot is non-empty, draw `random.nextFloat()`; when it is below `chance * difficulty.getSpecialMultiplier()`, enchant the item from the provider (`EnchantmentHelper.enchantItemFromProvider`, 28). An empty slot draws nothing. `Piglin` and `PiglinBrute` do not override `enchantSpawnedWeapon`. So a structure piglin's golden sword or crossbow and any golden armor it wore can be enchanted; the exact slot iteration order of `EquipmentSlot.VALUES` and the provider's draws are not traced (Open question 5).

### 15.4 The magma cube spawner

`bastion/treasure/bases/lava_basin` holds one `spawner` block at local `(11, 7, 19)` with stored data `SpawnData.entity = {id: magma_cube}`, `SpawnPotentials = [{data: {entity: {id: magma_cube}}, weight 1}]`, `SpawnCount` 4, `SpawnRange` 4, `RequiredPlayerRange` 16, `MaxNearbyEntities` 6, `MinSpawnDelay` 200, `MaxSpawnDelay` 800, `Delay` 0 (the engine: 31-7).

### 15.5 Chests and loot

Chests are template block entities with a `LootTable` key (not placed by code; 36-2 section 5.3 for block entities of templates, 26 for the roller): `chests/bastion_treasure` in the five chests of `treasure/bases/centers/*` (`center_0` `(4,3,6)`, `center_1` `(2,3,6)` and `(4,3,6)`, `center_2` `(1,2,4)`, `center_3` `(3,3,5)`);
`chests/bastion_hoglin_stable` in `hoglin_stable/large_stables/inner_3` `(1,1,5)` and `small_stables/inner_2` `(3,1,6)`; `chests/bastion_bridge` in `bridge/starting_pieces/entrance` `(9,16,4)`; `chests/bastion_other` in every other chest (counts in section 14).
Shape of the four tables (read; entries are data): all are `chest` tables whose entries are `item` or `empty`. The entry key that holds the functions is `modifier` and it holds either one object or a list; the function types that occur are `set_count`, `set_damage` and `enchant_randomly` (options tag `#minecraft:on_random_loot`), alone or chained in the order shown below, and some item entries have no modifier. Counts of item entries per modifier chain (read):

| Table | Pool: chains (entries) |
|---|---|
| `bastion_treasure` | 1: `set_count` 6, `set_damage` + `enchant_randomly` 6, none 6; 2: `set_count` 9; 3: none 1 (+ 1 `empty`); 4: none 1 |
| `bastion_bridge` | 1: `set_count` 1; 2: `set_count` 7, `set_count` + `enchant_randomly` 5, `set_damage` + `enchant_randomly` 1; 3: `set_count` 5; 4 and 5: none 1 each (+ 1 `empty` each) |
| `bastion_hoglin_stable` | 1: `set_count` 7, `set_damage` + `enchant_randomly` 1, `set_damage` + `set_count` + `enchant_randomly` 1; 2: `set_count` 13, `set_count` + `enchant_randomly` 1; 3 and 4: none 1 each (+ 1 `empty` each) |
| `bastion_other` | 1: `set_count` 8, `set_count` + `enchant_randomly` 1, `set_damage` + `enchant_randomly` 1, `enchant_randomly` alone 1; 2: `set_count` 11, `set_count` + `enchant_randomly` 2, `set_damage` + `set_count` + `enchant_randomly` 1; 3: `set_count` 10; 4 and 5: none 1 each (+ 1 `empty` each) |

Pool rolls, entry counts and weight sums:

| Table | Pools: rolls / entries / total weight |
|---|---|
| `bastion_treasure` | 3 / 18 / 112; uniform 3 to 4 / 9 / 9; 1 / 2 / 12; 1 / 1 / 1 |
| `bastion_bridge` | 1 / 1 / 1; uniform 1 to 2 / 13 / 13; uniform 2 to 4 / 5 / 5; 1 / 2 / 12; 1 / 2 / 10 |
| `bastion_hoglin_stable` | 1 / 9 / 100; uniform 3 to 4 / 14 / 14; 1 / 2 / 12; 1 / 2 / 10 |
| `bastion_other` | 1 / 11 / 89; 2 / 14 / 20; uniform 3 to 4 / 10 / 13; 1 / 2 / 12; 1 / 2 / 10 |

### 15.6 Spawn overrides

`spawn_overrides` is `{}`: no structure-specific natural spawns; the Nether biome lists apply inside a bastion (37-6 section 9). All mobs of a bastion that are not natural spawns are the template mobs above.

---

## 16. C. Processors

Every bastion element has a processor list that is either one of the 12 named lists below or the inline empty list; each named list contains exactly one processor, a `rule` processor (36-2 section 8) whose rules have the input predicate `random_block_match` (block, probability) and the location predicate `always_true`, except one rule of
`high_rampart` (a position predicate). The jigsaw element settings add the block-ignore processor for structure blocks and the jigsaw replacement processor first, then the list's processors (36-2; 36-3 section 5). The rule processor seeds a private random from the cell's position and, for each rule **in list order**, tests the block, draws one float only if the block matches the
rule's block, and applies the **first** rule that passes (36-2 section 8.1). A cell can therefore be changed by at most one rule.

| List | Used by | Rules | What it does (probabilities are data) |
|---|---|---|---|
| `bastion_generic_degradation` | the four start elements; bridge | 5 | polished blackstone bricks to cracked; blackstone to air (rare); gold block to cracked bricks; gilded blackstone to blackstone; blackstone to gilded blackstone |
| `housing` | units | 4 | as generic without the gold block rule |
| `stable_degradation` | hoglin stable | 4 | as `housing` with a lower cracking chance |
| `side_wall_degradation` | hoglin stable | 4 | chiseled polished blackstone to air; gold block to cracked bricks; the two gilded rules |
| `treasure_rooms` | treasure | 4 | bricks to cracked (higher chance), chiseled to cracked bricks; the two gilded rules |
| `high_wall` | treasure | 4 | bricks to air, to cracked bricks and to blackstone; gilded to blackstone |
| `roof` | treasure | 3 | bricks to cracked, to air and to blackstone |
| `bottom_rampart` | treasure | 4 | magma block to cracked bricks; cracked to plain bricks; the two gilded rules |
| `high_rampart` | treasure | 3 | gold block to cracked bricks; **any block to air with a position-dependent chance** (`axis_aligned_linear_pos`, `max_chance` 0.05, `max_dist` 100); gilded to blackstone |
| `bridge` | bridge | 2 | bricks to cracked; blackstone to air (rare) |
| `rampart_degradation` | bridge | 7 | cracked and air variants of bricks and blackstone, the gold rule, the two gilded rules |
| `entrance_replacement` | bridge | 4 | chiseled to air; gold block to cracked bricks (high chance); the two gilded rules |

Example (`bastion_generic_degradation`, rule order as read): for a cell of polished blackstone bricks only rule 1 can match (probability 0.3 to become cracked). A blackstone cell is tested by rule 2 (draw `f1`; air if `f1 < 0.0001`), and, only if that fails, by rule 5 (draw `f2`, the next float of the same private source; gilded if `f2 < 0.01`), so
P(air) = 0.0001 and P(gilded) = 0.9999 x 0.01 = 0.009999. A gold block cell is tested by rule 3 (0.3 to cracked bricks); a gilded blackstone cell by rule 4 (0.5 to plain blackstone).

(37-6 section 5 lists 11 names including `empty` and omitting `high_wall` and `roof`; counting the processor references of every pool element in the four closures gives the 12 names above, and the list called `empty` is not referenced by any bastion element: the mob and block pools write the empty list inline.)

---

## 17. C. Worked examples

### 17.1 Mob connector, step by step

A parent template (family wall) has an `up_north` jigsaw at `p` with pool `bastion/mobs/piglin`, target `minecraft:mob_connector`, joint `rollable`. The assembler (36-3 section 10.2) builds the candidate list: the shuffled expanded list of `mobs/piglin` (10 entries: `melee_piglin`, four `sword_piglin`, four `crossbow_piglin`, `mobs/empty`), then the fallback pool (empty).
For the first candidate, say `sword_piglin`, the rotations are tried in a shuffled order: its jigsaw (`down_west`, name `mob_connector`) attaches (front opposite, name equals the parent's target, parent joint rollable); the child's origin is `t - q` with `t = p + (0, 1, 0)` and `q = (0, 0, 0)`, so the 1 x 3 x 1 template stands at `t`; if the cell volume is free the piece is created, and when the template is placed
the piglin appears at the template cell `(0, 1, 0)` = `t + (0, 1, 0)`, two cells above the parent's connector block; each jigsaw block of a placed template is replaced by its own `final_state` (36-2 section 9.6): the child's by `air`, the parent's connector by the parent's `final_state`.

### 17.2 Four starts

Chunk (4, 7) (min block `(64, 112)`), the draws give rotation `CLOCKWISE_90` and element index 2 (treasure): the origin is `(64, 33, 112)`; the template `big_air_full` is 38 x 48 x 38, so the rotated corner `(37, 47, 37)` becomes `(-37, 47, 37)` and the box is x `64-37 = 27` .. 64, z 112 .. 149, y (before the move) 33 .. 80, then moved by -1: y 32 .. 79. `cx = (64 + 27) / 2 = 45`, `cz = (149 + 112) / 2 = 130`; the stub is `(45, 33, 130)`. Every later piece must lie within x 45-80 = -35 .. 125, z 50 .. 210 (the box test of 36-3 section 13.2 with a deflation of 0.25).

### 17.3 Brute odds in a treasure room

Per template the `melee_connector` connectors are: `center_0` 1, `center_1` 2, `center_2` 1, `center_3` 1, `lava_basin` 1, `mid_wall_main` 1, `walls/bottom/wall_0` 1, `walls/mid/wall_0` 1, `walls/top/main_entrance` 1 (total 10). A treasure room that places `center_1` gets two certain brutes there. `walls/top/main_entrance` has three
`piglin_melee` connectors: one targets `melee_connector` (a certain brute) and two target `mob_connector` (each a brute with probability 5/6 when the space is free): the expected number of brutes it produces is `1 + 2 x 5/6` = 2.67.

---

## 18. Validation: checkable facts

Items marked **(artifact)** were read from the shipped artifact in this round and can be re-derived from it; items marked **(computed)** are arithmetic on those values.

### 18.1 Nether fortress

1. The two weight tables: bridge weights 30, 10, 10, 10, 5, 5 with maxima unlimited, 4, 4, 3, 2, 1; castle weights 25, 15, 5, 5, 10, 7, 5 with maxima unlimited, 5, 10, 10, 3, 2, 2; `allowInRow` true for `BridgeStraight`, `CastleSmallCorridorPiece` and `CastleCorridorStairsPiece` only. Sums 70 and 72; limited maxima 14 and 32 (artifact, computed).
2. The concrete piece classes of `NetherFortressPieces` are 15: `StartPiece`, `BridgeCrossing`, `BridgeStraight`, `BridgeEndFiller`, `RoomCrossing`, `StairsRoom`, `MonsterThrone`, `CastleEntrance`, `CastleStalkRoom`, `CastleSmallCorridorPiece`, `CastleSmallCorridorCrossingPiece`, `CastleSmallCorridorLeftTurnPiece`,
   `CastleSmallCorridorRightTurnPiece`, `CastleCorridorStairsPiece`, `CastleCorridorTBalconyPiece` (artifact). The abstract base is `NetherBridgePiece`, the table entry is `PieceWeight`.
3. Start piece box for chunk (cx, cz): `(16 cx + 2, 64, 16 cz + 2)` to `(16 cx + 20, 73, 16 cz + 20)`, any orientation (computed).
4. Child anchors for a start with box `(2,64,2)-(20,73,20)` and orientation NORTH: forward `(10, 67, 1)` NORTH, left `(1, 67, 10)` WEST, right `(21, 67, 10)` EAST (computed, section 7.1).
5. A `BridgeStraight` at anchor `(10, 67, 1)` facing NORTH has the box `(9, 64, -17)-(13, 73, 1)`; at `(1, 67, 10)` facing WEST `(-17, 64, 9)-(1, 73, 13)`; at `(21, 67, 10)` facing EAST `(21, 64, 9)-(39, 73, 13)` (computed).
6. Every `fill` and `put` of the geometry lists lies inside the piece's local box (width x height x depth of the catalogue) with these exceptions that the artifact makes: the last three `put` rows of the throne room (y = 8 against height 8), and the column fills below y = 0; checked mechanically over the lists of sections 5.1 to 5.14 (the corridor stairs piece
   uses per-step formulas and was checked by hand: `a <= 7`, `b <= 13`).
7. `BridgeEndFiller` draws 27 numbers from its own seeded source (10 x `nextInt(8)`, 2 x `nextInt(8)`, 5 x `nextInt(5)`, 10 x `nextInt(3)`) (artifact, computed).
8. Saved keys: `Seed` (filler), `Mob` (throne), `Chest` (two turn pieces) (artifact).
9. Registered ids are those of 36-1 section 2.4 / 37-6 section 4 (`NeBCr`, `NeBS`, `NeBEF`, `NeRC`, `NeSR`, `NeMT`, `NeCE`, `NeCSR`, `NeSC`, `NeSCSC`, `NeSCLT`, `NeSCRT`, `NeCCS`, `NeCTB`, `NeStart`, lower-cased on registration).
10. `moveInsideHeights(48, 70)`: `room = 23 - ySpan`; for ySpan 10 (the start alone) `room` is 13 and the minimum y is `48 + nextInt(13)` (computed).
11. FORTRESS_ENEMIES equals the five entries of `fortress.json` (artifact).

### 18.2 End city

1. Start rule: `(chunk.minBlockX + 7, chunk.minBlockZ + 7)`; one `nextInt(4)` for the rotation first; corner offsets `(5,5)`, `(-5,5)`, `(-5,-5)`, `(5,-5)` for `NONE`, `CLOCKWISE_90`, `CLOCKWISE_180`, `COUNTERCLOCKWISE_90`; reject when the lowest corner height is below 60 (artifact).
2. The 20 end city templates and their sizes and markers of section 11.1 (artifact, re-derivable with any NBT reader); 13 `Sentry`, 5 `Chest`, 1 `Elytra` markers; no entities, no jigsaw blocks; `tower_base` stores 202 of 343 cells.
3. Offsets: `TOWER_BRIDGES` `(1,-1,0)`, `(6,-1,1)`, `(0,-1,5)`, `(5,-1,6)` with rotations `NONE`, `CLOCKWISE_90`, `COUNTERCLOCKWISE_90`, `CLOCKWISE_180`; `FAT_TOWER_BRIDGES` `(4,-1,0)`, `(12,-1,4)`, `(0,-1,8)`, `(8,-1,12)` with the same rotations (artifact).
4. The geometry of section 12.1 to 12.3 (computed from the connection arithmetic and the template sizes; both rotations).
5. Depth: `recursiveChildren` fails for depth greater than 8; reachable tower depths are 1, 4, 5, 7, 8 and a branch has at most three towers (computed; section 10.7).
6. Loot: `end_city_treasure` has pools 25 entries / weight 89 / rolls uniform 2 to 6 and 2 entries / weight 15 / 1 roll (artifact).

### 18.3 Bastion

1. Closures (pools, templates): units 18 / 38, hoglin stable 17 / 62, treasure 22 / 66, bridge 10 / 19 (artifact; equal to 37-6 section 5). 60 pool files and 167 template files under the bastion directories (counted with `unzip -Z1 | grep -v '/$'`); 637 jigsaw blocks in those templates, all with default priorities.
2. Start geometry for chunk (0, 0), rotation `NONE`: boxes and centres of the table in section 13.2 (computed from the template sizes, `groundLevelDelta` 1 and the start y 33).
3. Connector counts and attach rules of section 15.2 (artifact: names `mob_connector` / `melee_connector` / `block_connector` and the targets of 637 jigsaw blocks); the probabilities are computed from the weights.
4. Entities stored in the bastion mob templates: 2 `piglin`, 2 `piglin_brute`, 1 `hoglin` (artifact; equal to 44-2 section 10.5). One spawner block (magma cube) in the treasure closure.
5. Twelve named processor lists referenced by pool elements; each one `rule` processor (artifact).

### 18.4 Cross-document

The fortress and End city weights, extents and ids agree with 37-6 section 4 (re-read here), the End city marker counts and the fortress spawner rule with 44-2 sections 10.2 and 10.9, and the end city structure and structure set values with 38 section 10. The one difference found is the processor-list count of 37-6 section 5 (section 16).

---

## 19. Open questions

1. **Spawner block entity details.** The throne's spawner is set with `setEntityId(blaze, random)`; the resulting stored spawner state (delay, counts, ranges set by the call) is the spawner engine of 31-7 and was not re-read here. Likewise the stored data of the bastion magma cube spawner is quoted from the template NBT without a trace of how the loader merges it.
2. **Generation height of End islands.** The `getFirstOccupiedHeight` values that decide the `lowestY >= 60` test come from the End noise column query (10 section 4.4, 37-2 section 6.5, 38); the distribution of city sites is not computed here.
3. **Heights of grown fortresses.** The vertical extent of a finished fortress (hence `moveInsideHeights`) was not simulated; section 7.4 gives only the formula. The span depends on the number of castle stairs pieces (each lowers the corridor by 7) and on the piece mix.
4. **Block states beyond those named.** Nether brick stairs and fences are written with the properties named in section 1.2 and defaults elsewhere (`half` bottom, `shape` straight, `waterlogged` false, inferred from the use of the default state with only `facing` or the sides set); the defaults themselves are the block registry's (24).
5. **`populateDefaultEquipmentEnchantments` for structure piglins** (section 15.3): the call order, the chances (0.25 weapon, 0.5 armor times the difficulty special multiplier) and the empty-slot rule were read; not read: the enchantment provider used by `enchantItemFromProvider` for the equipment (its draws belong to the enchantment documents, 28) and the order of `EquipmentSlot.VALUES`.
6. **Entity tag format.** The bastion mob templates store entity tags with old-format keys (`HandItems`, `ArmorItems`, `Brain`, `Dimension`, `Rotation`) although the template data version is 5023; how the entity loader reads or ignores them is the entity NBT documents' (45), not traced here.
7. **Rule processor draws for blocks with several matching rules.** Section 16 states the first-match behaviour read from `RuleProcessor`/`ProcessorRule`; the exact private random (`RandomSource.create(Mth.getSeed(pos))`) and the float sequence are specified in 36-2 section 8.1 and were not re-derived.
8. **Probability that a mob piece fits.** The odds of section 15.2 are first-choice odds under the assumption that the candidate's volume is free; the real frequency depends on the placements around each connector and was not measured.
9. **`couldStructureExistInColumn` biome sampling.** The test uses the biome source's chunk resolver over the quart column; its exact sampling is the climate and biome documents' (37-3, 10 section 7), not re-read here.
10. **Which `Direction` the `ItemFrame` constructor expects for the elytra frame.** The call passes `rotation.rotate(SOUTH)`; the item frame's own facing semantics (which wall it hangs on) are the entity documents' (45).
11. **`tower_floor`** (closed): the template file `data/minecraft/structure/end_city/tower_floor.nbt` exists, but the string `tower_floor` appears in no class under `net/` and in no text data file of the jar, so the template is unused anywhere in the jar (the file contents are compressed NBT and were not searched for the name).
