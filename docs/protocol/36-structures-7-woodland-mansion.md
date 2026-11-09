# 36 Structures, part 7: the woodland mansion

| Item | Value |
|---|---|
| Covers | The woodland mansion in full: the structure definition and its start rules (position, rotation, height test), the `MansionGrid` generator (11 by 11 cell grid, corridor growth, edge cleaning, room identification and merging, secret rooms, the third floor and its stair room), the piece layout (`MansionPiecePlacer`: entrance, outer walls and corners, three roof passes, corridor floors and carpets, indoor walls and doors, 1x1, 1x2 and 2x2 room placement with rotation and mirror tables), room template selection per floor, the piece class (`WoodlandMansionPiece`: template naming, placement settings, serialisation, data markers for chests and for the evoker, vindicator and allay markers), the loot hook, the terrain foundation (`afterPlace`), the random-number order, a catalogue of the template sizes and markers, worked examples and a validation section |
| Does not cover | Data rows. The extraction tool copies the structure NBT (`data/minecraft/structure/woodland_mansion/*.nbt`, 73 files), the structure and structure-set JSON, the biome and structure tags and the loot table (see 22 and 23); they are cited to show wiring, never tabulated. Engines owned by the sibling parts of document 36 and by other documents, cited by name here: random-spread placement and the structure-start loop (36-1 sections 4 and 5), the structure-start and piece-container model (36-1 section 5.6), the template (structure NBT) loader and the block placement engine (36-2) (`StructureTemplate.placeInWorld`: palette, block-state rotation and mirror, flags, entity handling), the chunk-status pipeline. The behaviour of evokers, vindicators and allays (20 section 13, 19 section 15). Chest block entities and loot rolling (31-1, 26) |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the classes named in each section and of the JSON and structure NBT under `data/minecraft/` in the jar, with no execution of the artifact. Examples marked "(computed)" were produced by applying this document's text with a throwaway reference script written in the reader's scratchpad (not part of the repository); they are consequences of the text, not observations of the game |
| Round | RS20 (GAP-12b and GAP-18 of [../design/README.md](../design/README.md)), structures, part 7 |
| Operator decisions | Standard Minecraft content is the target; a COBOL tool extracts the data pack and resource pack from the user's jar, so data rows are not tabulated and the engine is specified; code-defined content is specified completely (ticket CC-0001, Decisions "World scope", "Vanilla assets and data") |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not verified)" a
statement not read in this round; both are listed in the Open questions. No value in this document is taken from recall. References such as
"10 section 2.6" are to documents of this directory; "36-1" and "36-2" are sibling parts of document 36 (36-1: placement, start loop, structure start and piece container; 36-2: template loader, placement and processors). A "cell" is a cell of the 11 by 11 mansion grid; a "block" is a world block.

---

## 1. Overview

A mansion is built in two stages. First `MansionGrid` draws an abstract floor plan on an 11 by 11 grid: a fixed entrance block, four randomly grown
corridors, rooms filled in around the corridors, and then a partition of the room cells into 1x1, 1x2 and 2x2 rooms, separately for the first and the
second floor (both use the same footprint) and a smaller third-floor plan around one stair room. Then `MansionPiecePlacer` walks the grids and emits
an ordered list of template pieces: the entrance, the outer walls with corner pieces on three levels, the roofs, corridor floors and carpets, indoor
walls and doors, and the rooms. Every piece is a `WoodlandMansionPiece`, a template piece that places one structure NBT file with a rotation and a
mirror. Rooms and some corridors carry data markers (structure blocks in DATA mode) that the piece turns into chests with loot and into mobs.

| Class (`net.minecraft.world.level.levelgen.structure.structures.*`) | Role | Section |
|---|---|---|
| `WoodlandMansionStructure` | structure type: start point, rotation, height test, foundation after placement | 3, 8 |
| `WoodlandMansionPieces` | entry point `generateMansion` (builds the grid, then the placer) | 1 |
| `WoodlandMansionPieces$MansionGrid` | floor-plan generator | 5 |
| `WoodlandMansionPieces$SimpleGrid`, `$MansionGrid$GridPos` | int grid with an outside value, and an (x, y) record | 5.2 |
| `WoodlandMansionPieces$MansionPiecePlacer` | piece layout | 6 |
| `WoodlandMansionPieces$FloorRoomCollection` and the three per-floor collections | template-name selection | 6.8 |
| `WoodlandMansionPieces$WoodlandMansionPiece` | the piece class and its data markers | 7 |
| `WoodlandMansionPieces$PlacementData` | a mutable cursor (position, rotation, wall type) used while walking walls | 6.3 |

The whole mansion is generated from the structure-start random (section 3); its placement-time work (blocks, chests, mobs, foundation) happens in
the chunk steps of the decoration stage (sections 7 and 8).

### 1.1 Structure-level facts read from the data pack

| Item | Value |
|---|---|
| Structure id and file | `minecraft:mansion` (`worldgen/structure/mansion.json`), `type` = `minecraft:woodland_mansion` (`StructureType.WOODLAND_MANSION`) |
| Biomes | tag `#minecraft:has_structure/woodland_mansion` (values: `minecraft:dark_forest`, `minecraft:pale_garden`) |
| Generation step | `surface_structures` (decoration step index 4, 11 section 6.2) |
| `spawn_overrides` | empty object: no structure-specific natural spawns |
| `terrain_adaptation` | absent in the JSON; the codec default is `none` (no beardifier). The mansion adapts to terrain only through the foundation of section 8 |
| Structure set | `worldgen/structure_set/woodland_mansions.json`: one entry (`minecraft:mansion`, weight 1); placement `random_spread`, `spacing` 80, `separation` 20, `salt` 10387319, `spread_type` `triangular` (the algorithm is the placement part of document 36) |
| Piece type | `StructurePieceType.WOODLAND_MANSION_PIECE`, registered through `StructurePieceType.setTemplatePieceId` -> `setFullContextPieceId` with the string `WMP`; that method lowercases it with `Locale.ROOT` and registers it in `BuiltInRegistries.STRUCTURE_PIECE`, so the piece id is `wmp` (read); the `minecraft:` namespace comes from the String overload of `Registry.register`, which was not read (inferred) (Open question 9) |
| Templates | 73 NBT files under `data/minecraft/structure/woodland_mansion/` (counted with `unzip -Z1 ... \| grep -v '/$'`); all 73 files carry `DataVersion` 5023 (read by parsing every file) |
| Loot | `chests/woodland_mansion` (`BuiltInLootTables.WOODLAND_MANSION`): four pools (9, 11, 4 and 2 entries), rolls uniform 1 to 3, uniform 1 to 4, constant 3 and constant 1 (data; the engine is 26) |
| Set fields absent | The structure set JSON has no `frequency_reduction_method`, no `exclusion_zone` and no `locate_offset` (read; the defaults of 36-1 section 3.3 apply: default reduction, no exclusion, offset 0). `/locate` therefore reports the structure start's chunk minimum corner at y 0 (36-1 section 4.8, 16 section 7.7), not the piece-box centre and not the lowest piece corner |
| Map | `minecraft:mansion` is the only value of the structure tag `on_woodland_mansion_maps` (explorer map target; cartographer and map code are elsewhere). Trade wiring (read, data only): `villager_trade/cartographer/5/emerald_and_compass_woodland_mansion_map.json` wants 14 `minecraft:emerald` plus a `minecraft:compass`, gives `minecraft:woodland_mansion_map`, `max_uses` 12, `reputation_discount` 0.2, `xp` 30, and applies an `exploration_map` item modifier with destination `#minecraft:on_woodland_mansion_maps` and `search_radius` 100 (followed by a `filtered` modifier that discards the result when it has no `map_id`); the trade is also listed in the tags `villager_trade/cartographer/level_5` and `item/clonable_maps` (read: each tag file contains the entry). The villager trade engine is in 44 (villagers); assets `textures/map/decorations/woodland_mansion.png` and `items/woodland_mansion_map.json` exist (rendering, out of scope) |

---

## 2. Conventions used below

### 2.1 Directions, rotations, mirrors

Read from `Direction`, `Rotation`, `Mirror`, `BlockPos.rotate` and `StructureTemplate.transform`.

| Item | Value |
|---|---|
| Horizontal steps (x, z) | NORTH (0, -1), EAST (+1, 0), SOUTH (0, +1), WEST (-1, 0) |
| `Direction.Plane.HORIZONTAL` iteration order | NORTH, EAST, SOUTH, WEST |
| `getClockWise` | NORTH to EAST to SOUTH to WEST to NORTH; `getCounterClockWise` is the inverse; `getOpposite` swaps N/S and E/W |
| `Direction.from2DDataValue(i)` | `BY_2D_DATA[|i| mod 4]` with `data2d`: SOUTH 0, WEST 1, NORTH 2, EAST 3 |
| `Rotation` (enum order, ordinal) | NONE 0, CLOCKWISE_90 1, CLOCKWISE_180 2, COUNTERCLOCKWISE_90 3 (so a rotation is a number of clockwise quarter turns, `q`) |
| `Rotation.getRotated(b)` | the rotation whose turns are `(q_a + q_b) mod 4` (the tables in `Rotation` were read: e.g. CLOCKWISE_90 plus CLOCKWISE_90 is CLOCKWISE_180, COUNTERCLOCKWISE_90 plus CLOCKWISE_90 is NONE) |
| `Rotation.rotate(Direction)` | NONE: same; CLOCKWISE_90: `getClockWise`; CLOCKWISE_180: `getOpposite`; COUNTERCLOCKWISE_90: `getCounterClockWise`; vertical directions unchanged |
| `BlockPos.rotate(Rotation)` on (x, y, z) | NONE: (x, y, z); CLOCKWISE_90: (-z, y, x); CLOCKWISE_180: (-x, y, -z); COUNTERCLOCKWISE_90: (z, y, -x) |
| `Rotation.getRandom(random)` | `Util.getRandom(values(), random)` = `values()[random.nextInt(4)]` (NONE, CLOCKWISE_90, CLOCKWISE_180, COUNTERCLOCKWISE_90) |
| `pos.relative(d, n)` | `pos + n * step(d)`; `n` may be negative; `above(n)` adds n to y |
| Template transform (`StructureTemplate.transform`, pivot (0, 0, 0)) | first mirror: LEFT_RIGHT negates z, FRONT_BACK negates x, NONE nothing; then rotate as `BlockPos.rotate` |
| Template bounding box (`StructureTemplate.getBoundingBox(pos, rotation, pivot, mirror, size)`) | corners `transform(0,0,0)` and `transform(size - 1)` (per axis), sorted per axis, then moved by `pos` |

In the text below, `R·D` means `R.rotate(D)` where R is the mansion rotation (sections 3 and 6). "R + X" means `R.getRotated(X)`. The grid is the
**unrotated frame**: grid x grows toward EAST and grid y toward SOUTH, and the floor-plan frame is turned into the world by R (a rotation about the
piece position, section 6.1). The grid is addressed `(x, y)`.

### 2.2 Random numbers

Every draw in sections 3 to 6 uses one object, the structure-start random `GenerationContext.random()` (section 3, step 1): a `WorldgenRandom`
over a `LegacyRandomSource`, i.e. `java.util.Random` (10 section 2.6, 11 section 4). Draws used here:

| Call | Meaning |
|---|---|
| `nextInt(n)` | the legacy rule of 10 section 2.6: a power of two takes `(n * next(31)) >> 31`, otherwise the rejection loop on `next(31) % n`. `nextInt(1)` is legal, returns 0 and still consumes one `next(31)` |
| `nextBoolean()` | `next(1) != 0` |
| `Util.shuffle(list, random)` | for `i` from `size` down to 2: `j = nextInt(i)`; swap `list[i-1]` and `list[j]` (a list of size 0 or 1 draws nothing) |

The placement-time work uses two other sources, named where used (sections 7 and 8).

---

## 3. The structure start (`WoodlandMansionStructure.findGenerationPoint`)

Inputs: the generation context (chunk position `(cx, cz)`, chunk generator, height accessor, random state, template manager, the structure-start
random). Steps:

1. The structure-start random is `new WorldgenRandom(new LegacyRandomSource(0))` followed by `setLargeFeatureSeed(worldSeed, cx, cz)` (`Structure$GenerationContext.makeRandom`; the seeding rule is in 11 section 4: `setSeed(s)`, `a = nextLong()`, `b = nextLong()`, `setSeed((cx * a) XOR (cz * b) XOR s)` in 64-bit arithmetic). The same object feeds sections 3 to 6, in the order given in section 9.
2. `x = cx * 16 + 7`, `z = cz * 16 + 7` (`ChunkPos.getBlockX(7)`, `getBlockZ(7)`, constant `START_OFFSET_IN_CHUNK = 7`).
3. If `couldValidBiomeExistInTerrainColumn(x, z)` is false, there is no start (no random draw is made).
4. `R = Rotation.getRandom(random)`: **the first draw**, `nextInt(4)`.
5. `Structure.getLowestYIn5by5Box(context, x, z, R)`: let `dx = dz = 5`; for R = CLOCKWISE_90 `dx = -5`; for CLOCKWISE_180 `dx = dz = -5`; for COUNTERCLOCKWISE_90 `dz = -5` (NONE keeps +5, +5). The four corner heights are `H(x, z)`, `H(x, z + dz)`, `H(x + dx, z)`, `H(x + dx, z + dz)` with `H(a, b) = chunkGenerator.getFirstOccupiedHeight(a, b, WORLD_SURFACE_WG, heightAccessor, randomState)`, which is `getBaseHeight(...) - 1`: the y of the highest block the terrain fill produces for which the `WORLD_SURFACE_WG` test is true, found by scanning a 1 by 1 column of the final density from the top down (`NoiseBasedChunkGenerator.iterateNoiseColumn`; `getBaseHeight` returns that y plus 1, or the world minimum y when nothing qualifies). `WORLD_SURFACE_WG` records every state that is not air (10 section 8.1, 35-1). `y0` is the minimum of the four. The start position is `P = (x, y0, z)`.
6. If `y0 < 60` there is no start. (The mansion therefore never starts on a column whose lowest corner surface is below y 60.)
7. Otherwise the stub is `GenerationStub(P, builder -> generatePieces)`. The generic start loop (36-1 section 5.2 and 5.3) additionally filters the stub with the biome test at the stub position. `generatePieces` creates a linked list of pieces, calls `WoodlandMansionPieces.generateMansion(templateManager, P, R, list, random)` and adds the list's pieces to the builder in list order. No height shifting (`moveInsideHeights`) is applied.

`generateMansion` is two statements: `grid = new MansionGrid(random)` (section 5), then `new MansionPiecePlacer(templateManager, random).createMansion(P, R, list, grid)` (section 6).

---

## 4. Data layout of the grid

### 4.1 Cell values of the base and third-floor grids

`MansionGrid` holds the grids `baseGrid` and `thirdFloorGrid` (cell values below) and three room grids `floorRooms[0..2]` (room codes, section 4.2). All are
`SimpleGrid` of 11 by 11 `int` cells initialised to 0, with an **outside value** of 5 returned by `get` for any `(x, y)` outside 0 to 10; `set` outside
the grid is ignored.

| Value | Constant | Meaning |
|---|---|---|
| 0 | `CLEAR` | empty, not part of the house |
| 1 | `CORRIDOR` | corridor |
| 2 | `ROOM` | a room cell (before merging into rooms) |
| 3 | `START_ROOM` | entrance block (base grid) or a stair-room cell (third-floor grid) |
| 4 | `TEST_ROOM` | declared, never written |
| 5 | `BLOCKED` | a cell that must stay empty (and also the value `get` returns outside the grid) |

`isHouse(grid, x, y)` is true when `grid.get(x, y)` is 1, 2, 3 or 4. The outside value 5 is not house.

`SimpleGrid` operations: `set(x, y, v)`; `set(x0, y0, x1, y1, v)` fills the inclusive rectangle, iterating y in the outer loop; `setif(x, y, a, b)` sets
`b` only if the cell currently holds `a`; `edgesTo(x, y, v)` is true when any of the four orthogonal neighbours (x-1, x+1, y+1, y-1) equals `v`.

### 4.2 Room codes (`floorRooms[f]`)

A room code is a bit field; a cell with code 0 belongs to no room.

| Mask | Constant | Meaning |
|---|---|---|
| `0x0000FFFF` (65535) | `ROOM_ID_MASK` | the room id; ids are assigned from 10 upward per `identifyRooms` call |
| `0x000F0000` (983040) | `ROOM_TYPE_MASK` | room type, one of the next three |
| `0x00010000` (65536) | `ROOM_1x1` | a 1x1 room |
| `0x00020000` (131072) | `ROOM_1x2` | a 1x2 room |
| `0x00040000` (262144) | `ROOM_2x2` | a 2x2 room |
| `0x00100000` (1048576) | `ROOM_ORIGIN_FLAG` | this cell is the room's origin cell (exactly one per room) |
| `0x00200000` (2097152) | `ROOM_DOOR_FLAG` | the origin cell is next to a corridor and the room has a door there |
| `0x00400000` (4194304) | `ROOM_STAIRS_FLAG` | a 1x2 room of floor 1 that carries the stairs to floor 2 |
| `0x00800000` (8388608) | `ROOM_CORRIDOR_FLAG` | a cell that is not a room but whose side must receive a carpet (section 6.6) |

---

## 5. The floor plan (`MansionGrid`)

### 5.1 Construction, in order

The constructor draws from the structure-start random. Let `EX = 7` (`entranceX`), `EY = 4` (`entranceY`).

1. `baseGrid` = 11 by 11, outside value 5.
2. Fixed shapes, each an inclusive rectangle `(x0, y0, x1, y1)`, written in this order:

   | Rectangle | Value | Cells |
   |---|---|---|
   | (EX, EY, EX+1, EY+1) | 3 | (7,4) to (8,5): the entrance block |
   | (EX-1, EY, EX-1, EY+1) | 2 | (6,4), (6,5) |
   | (EX+2, EY-2, EX+3, EY+3) | 5 | (9,2) to (10,7) |
   | (EX+1, EY-2, EX+1, EY-1) | 1 | (8,2), (8,3) |
   | (EX+1, EY+2, EX+1, EY+3) | 1 | (8,6), (8,7) |
   | (EX-1, EY-1) single cell | 1 | (6,3) |
   | (EX-1, EY+2) single cell | 1 | (6,6) |
   | (0, 0, 11, 1) | 5 | rows 0 and 1 |
   | (0, 9, 11, 11) | 5 | rows 9 and 10 |

   The result before any corridor growth is (rows are y = 0 to 10, columns x = 0 to 10):

   ```
   5 5 5 5 5 5 5 5 5 5 5
   5 5 5 5 5 5 5 5 5 5 5
   0 0 0 0 0 0 0 0 1 5 5
   0 0 0 0 0 0 1 0 1 5 5
   0 0 0 0 0 0 2 3 3 5 5
   0 0 0 0 0 0 2 3 3 5 5
   0 0 0 0 0 0 1 0 1 5 5
   0 0 0 0 0 0 0 0 1 5 5
   0 0 0 0 0 0 0 0 0 0 0
   5 5 5 5 5 5 5 5 5 5 5
   5 5 5 5 5 5 5 5 5 5 5
   ```
3. Four corridor growths, in this order: `recursiveCorridor(baseGrid, EX, EY-2, WEST, 6)` = from (7,2); `(EX, EY+3, WEST, 6)` = from (7,7); `(EX-2, EY-1, WEST, 3)` = from (5,3); `(EX-2, EY+2, WEST, 3)` = from (5,6).
4. Repeat `cleanEdges(baseGrid)` until it returns false.
5. Create `floorRooms[0]`, `[1]`, `[2]` as empty 11 by 11 grids (outside 5).
6. `identifyRooms(baseGrid, floorRooms[0])`, then `identifyRooms(baseGrid, floorRooms[1])` (two independent random partitions of the same footprint).
7. In `floorRooms[0]` and in `floorRooms[1]`, set the rectangle (EX+1, EY, EX+1, EY+1) = cells (8,4) and (8,5) to `ROOM_CORRIDOR_FLAG` (0x800000). (These are entrance-block cells with no room code, so the corridor flag marks the entrance side for carpets.)
8. `thirdFloorGrid` = a new grid with the width and height of `baseGrid` (11 by 11), outside value 5; call `setupThirdFloor()` (5.5), then `identifyRooms(thirdFloorGrid, floorRooms[2])`.

### 5.2 `recursiveCorridor(grid, x, y, dir, depth)`

Inputs: a grid, a cell, a heading `dir` (a horizontal direction) and a depth. Steps:

1. If `depth <= 0`, return.
2. `grid(x, y) = 1`. Then `setif(x + dir.x, y + dir.z, 0, 1)`: the cell straight ahead becomes a corridor if it was clear.
3. Up to 8 attempts, in order (attempt counter 0 to 7):
   a. `d = Direction.from2DDataValue(random.nextInt(4))` (so the draw 0, 1, 2, 3 gives SOUTH, WEST, NORTH, EAST).
   b. If `d` is the opposite of `dir`, next attempt.
   c. If `d` is EAST, draw `random.nextBoolean()`; if true, next attempt. (The boolean is drawn only for EAST.)
   d. With `(ax, ay) = (x + dir.x, y + dir.z)`: if `grid(ax + d.x, ay + d.z) == 0` and `grid(ax + 2*d.x, ay + 2*d.z) == 0`: recurse `recursiveCorridor(grid, ax + d.x, ay + d.z, d, depth - 1)` and stop the attempts. Otherwise next attempt.
4. With `c = dir.getClockWise()` and `k = dir.getCounterClockWise()`, apply `setif(cell, 0, 2)` (clear cell becomes a room cell) to these seven cells, in this order: `(x+c)`, `(x+k)`, `(x+dir+c)`, `(x+dir+k)`, `(x+2*dir)`, `(x+2*c)`, `(x+2*k)` (each as `x + vector`, `y + vector` with the direction's step). The order is irrelevant to the result; the cells are independent.

Step 4 runs after the recursion returns (the deepest call finishes first).

### 5.3 `cleanEdges(grid)`

Scans y from 0 to height-1 (outer) and x from 0 to width-1 (inner), modifying in place. For a cell with value 0: `n` = number of the four orthogonal neighbours that are house. If `n >= 3`, the cell becomes 2 and the pass is marked changed. Otherwise, if `n == 2`, let `m` = number of the four diagonal neighbours that are house; if `m <= 1` the cell becomes 2 and the pass is marked changed. The method returns whether anything changed; callers repeat it until it returns false. It draws no random numbers.

### 5.4 `identifyRooms(grid, rooms)`

Partitions the cells with value 2 of `grid` into rooms and writes room codes into `rooms` (initially all 0).

1. Collect the cells with `grid == 2`, scanning y outer, x inner. `Util.shuffle` them (section 2.2).
2. `id = 10`. For each cell `(x, y)` of the shuffled list, in order; skip it if `rooms(x, y) != 0` (already part of a room):
   1. Initial rectangle `x0 = x1 = x`, `y0 = y1 = y`, type 1x1.
   2. Test the following patterns **in this order**; the first that holds sets the rectangle and the type, and the remaining tests are skipped. "free(c)" means `rooms(c) == 0`, "room(c)" means `grid(c) == 2`:
      | # | Condition | Effect |
      |---|---|---|
      | 1 | free and room of (x+1, y), (x, y+1), (x+1, y+1) | `x1 += 1`, `y1 += 1`, 2x2 |
      | 2 | free and room of (x-1, y), (x, y+1), (x-1, y+1) | `x0 -= 1`, `y1 += 1`, 2x2 |
      | 3 | free and room of (x-1, y), (x, y-1), (x-1, y-1) | `x0 -= 1`, `y0 -= 1`, 2x2 |
      | 4 | free and room of (x+1, y) | `x1 += 1`, 1x2 |
      | 5 | free and room of (x, y+1) | `y1 += 1`, 1x2 |
      | 6 | free and room of (x-1, y) | `x0 -= 1`, 1x2 |
      | 7 | free and room of (x, y-1) | `y0 -= 1`, 1x2 |
      | none | | the room stays 1x1 |

      There is no test for the 2x2 block to the north-east (x+1, y-1). Cells outside the grid read as 5 in both grids, so they never match.
   3. Choose the origin cell and the door. `a = nextBoolean() ? x0 : x1` then `b = nextBoolean() ? y0 : y1` (two draws, always made, in this order). `door = ROOM_DOOR_FLAG`.
   4. If `grid.edgesTo(a, b, 1)` (the corner is orthogonally next to a corridor) the choice stands. Otherwise try, in this order, stopping at the first success: (i) flip **both** `a` and `b` at once (`a = (a == x0) ? x1 : x0`, `b = (b == y0) ? y1 : y0`), giving (a', b'); (ii) flip `b` back, giving (a', b); (iii) flip `a` back and flip `b` again, giving (a, b'). Each attempt tests `grid.edgesTo(a, b, 1)` (read in the `identifyRooms` bytecode: three flip groups each followed by an `edgesTo` call). The four corners are therefore tried in the order (a,b), (a',b'), (a',b), (a,b'), where (a,b) is the corner chosen by the two draws and a', b' are the opposite coordinates. If all four fail: `door = 0`, `a = x0`, `b = y0`.
   5. Write the codes: for every cell of the rectangle (y outer, x inner): the origin cell `(a, b)` gets `ROOM_ORIGIN_FLAG | door | type | id`; every other cell gets `type | id`.
   6. `id += 1`.

Because the shuffle is the first step and two booleans follow each new room, the number of draws depends on the number of rooms.

Consequences: every room has exactly one origin; a room has a door flag only if its chosen origin corner touches a corridor; a room with `door == 0` has its origin at `(x0, y0)` (the corner order above decides which corner is the origin and door of a 2x2 room, and of a 1x2 room whose first corner has no corridor) and is the "secret" kind (it has no door; section 6.6). A 2x2 block of four room cells can only form when the first of its four cells reached in the shuffled order is its north-west, north-east or south-east cell (patterns 1, 2, 3 respectively); if the south-west cell is reached first there is no pattern for it, and that cell becomes a 1x2 room (pattern 4 or 5) instead.

### 5.5 `setupThirdFloor`

Runs after the floor-0 and floor-1 room identification (section 5.1 step 6) and before the third-floor identification. `base` is `baseGrid`, `third` is `thirdFloorGrid`, `F1 = floorRooms[1]`.

1. Candidates: every cell `(x, y)` of the grid (y outer, x inner) with `(F1(x, y) & TYPE) == ROOM_1x2` and `(F1(x, y) & DOOR) != 0`: door-bearing origin cells of 1x2 rooms of floor 1.
2. If there are none: set the whole `third` grid to 5 (`set(0, 0, width, height, 5)`) and return (the mansion then has no third floor).
3. `pick = candidates[random.nextInt(candidates.size())]` (the draw is made even when there is one candidate). `v = F1(pick)`. Set `F1(pick) = v | ROOM_STAIRS_FLAG`.
4. `d = get1x2RoomDirection(pick, floor 1, id = v & 0xFFFF)`: the first direction in HORIZONTAL order (N, E, S, W) such that the neighbouring cell `pick + d` has `(F1 & 0xFFFF) == id`. `(x2, y2) = pick + d` is the other half of the stair room.
5. For every cell (y outer, x inner): if `base` is not house there: `third = 5`; else if the cell is `pick`: `third = 3`; else if the cell is `(x2, y2)`: `third = 3` and `floorRooms[2](x2, y2) = ROOM_CORRIDOR_FLAG`. Every other house cell keeps 0.
6. `dirs` = the directions in HORIZONTAL order whose neighbour `(x2 + d.x, y2 + d.z)` has `third == 0`.
7. If `dirs` is empty: set `third` to 5 everywhere, restore `F1(pick) = v` (the stairs flag is removed), return.
8. `d = dirs[random.nextInt(dirs.size())]` (drawn even when one entry); `recursiveCorridor(third, x2 + d.x, y2 + d.z, d, 4)`.
9. Repeat `cleanEdges(third)` until it returns false.

So the third floor is: the two stair-room cells (value 3), and a depth-4 corridor from the far half of the stair room, with room cells (value 2) around it, restricted to cells that are house on the base grid. Remaining house cells keep value 0 and do not take part in the third floor (not `isHouse`).

---

## 6. The piece layout (`MansionPiecePlacer`)

### 6.1 Coordinate model

`createMansion(origin O, rotation R, list, grid)` receives the start position `P` as `O` and the start rotation as `R`. Constants `startX = EX + 1 = 8`, `startY = EY + 1 = 5` (fields of the placer).

All pieces are emitted as `(templateName, position, rotation, mirror)` and appended to `list` in emission order. The order matters: later pieces overwrite earlier ones where they overlap, and the piece list is also the processing order of the decoration stage (section 7).

Cell origin on a floor with floor origin `F` (a block position):

```
K(x, y)  = F + (R·SOUTH) * (8 + (y - startY) * 8) + (R·EAST) * ((x - startX) * 8)
         = F + (R·SOUTH) * 8 * (y - 4)            + (R·EAST) * 8 * (x - 8)
```

So a cell is 8 blocks wide and the cell (8, 4) has `K = F`. Floor origins: floor 0: `O`; floor 1: `O.above(8)`; floor 2: `O.above(19)` (8 times the floor index, plus 3 for floor 2 only).

### 6.2 `createMansion` in order

1. `d5` = a `PlacementData` with position `O`, rotation `R`, wall type `wall_flat`. `d6` is a second one (filled in step 3).
2. `entrance(list, d5)` (6.3).
3. `d6.position = d5.position.above(8)` (this uses `d5`'s position **after** the entrance step), `d6.rotation = d5.rotation` (which is still `R`), `d6.wallType = wall_window`.
4. `traverseOuterWalls(list, d5, baseGrid, SOUTH, startX, startY, EX+1, EY)`, i.e. start cell (8, 5), end cell (8, 4), heading SOUTH, wall type `wall_flat` (the first-floor outer wall). Then the same call with `d6` (second-floor outer wall, `wall_window`, 8 blocks higher).
5. Third-floor outer wall: `d11` with position `d5.position.above(19)` evaluated after both walks of step 4 (`d5` is the cursor of the first walk; after the closed lap it is at `O` itself with rotation `R`, a property checked over 300 sampled inputs with the reference script (computed; the script is not in the repository, so the property is a hypothesis for an implementer to test, see item 7 of section 12), so `d11.position` starts as `O.above(19)`), rotation `R`, wall type `wall_window`. Search for the start cell: for `y` from 0 to height-1 while not found, for `x` from width-1 **down to** 0 while not found: the first cell with `isHouse(thirdFloorGrid, x, y)`. At that cell: `d11.position = d11.position.relative(R·SOUTH, 8 + (y - startY) * 8)`, then `.relative(R·EAST, (x - startX) * 8)`; `traverseWallPiece(list, d11)`; `traverseOuterWalls(list, d11, thirdFloorGrid, SOUTH, x, y, x, y)`.
6. `createRoof(list, O.above(16), R, baseGrid, thirdFloorGrid)`, then `createRoof(list, O.above(27), R, thirdFloorGrid, none)` (6.5). (Here `O` is the start position, not a cursor.)
7. For floor `i` = 0, 1, 2: carpets and corridor floors, indoor walls and doors, rooms (6.6).

The three room-collection objects of 6.8 are created once, between steps 6 and 7: `[FirstFloor, SecondFloor, ThirdFloor]`.

### 6.3 Outer-wall cursor (`PlacementData`) and its moves

The cursor holds a position, a rotation and a wall type. Each helper adds pieces with the cursor's current rotation.

| Helper | Pieces added | Cursor change |
|---|---|---|
| `entrance` (called with `d5`) | `entrance` at `d.position.relative(d.rotation·WEST, 9)`, rotation `d.rotation` | `d.position = d.position.relative(d.rotation·SOUTH, 16)` |
| `traverseWallPiece` | wall type of the cursor at `d.position.relative(d.rotation·EAST, 7)`, rotation `d.rotation` | `d.position = d.position.relative(d.rotation·SOUTH, 8)` |
| `traverseTurn` (convex corner) | first `d.position = d.position.relative(d.rotation·SOUTH, -1)`; then `wall_corner` at that position, rotation `d.rotation` | then `d.position.relative(d.rotation·SOUTH, -7)`, then `.relative(d.rotation·WEST, -6)` (that is 6 blocks toward EAST), then `d.rotation = d.rotation + CLOCKWISE_90` |
| `traverseInnerTurn` (concave corner) | none | `d.position.relative(d.rotation·SOUTH, 6)`, then `.relative(d.rotation·EAST, 8)`, then `d.rotation = d.rotation + COUNTERCLOCKWISE_90` |

In each line the direction is computed from the cursor's rotation **before** the rotation change of that line. Positions are updated in the order listed.

`traverseOuterWalls(list, d, grid, dir, x, y, endX, endY)` walks the outline of the house on `grid`, clockwise as seen from above, from cell `(x, y)` heading `dir`, ending when the walker is back at `(endX, endY)` with the heading `dir` it started with. Let `startDir = dir`. Repeat until the stop condition (checked at the end of each round):

1. If `isHouse(grid, x + dir.x, y + dir.z)` is **false** (the cell ahead is outside): `traverseTurn`; `dir = dir.getClockWise()`; then, unless `(x, y) == (endX, endY)` and `dir == startDir`, `traverseWallPiece`.
2. Else if the cell ahead is house **and** the cell ahead-and-to-the-left, `(x + dir.x + k.x, y + dir.z + k.z)` with `k = dir.getCounterClockWise()`, is house: `traverseInnerTurn`; `x += dir.x`, `y += dir.z`; `dir = k` (counter-clockwise).
3. Else: `x += dir.x`, `y += dir.z`; then, unless `(x, y) == (endX, endY)` and `dir == startDir`, `traverseWallPiece`.

Stop when `(x, y) == (endX, endY)` and `dir == startDir`.

The cursor is a mutable object shared with the caller. The first-floor walk starts with the cursor at `O.relative(R·SOUTH, 16)` (just after the entrance) and ends with the cursor at `O` with rotation `R` (computed: this held for all 300 sampled inputs; it is the property of a closed outline that the test in section 12 item 7 uses).

**One-cell house.** For a single isolated house cell `c`, the walk from `(c, SOUTH)` to `(c, SOUTH)` (called after the caller's own initial `traverseWallPiece`, as in 6.2 step 5) emits: turn, wall, turn, wall, turn, wall, turn (no wall at the end): 4 `wall_corner` and 3 wall pieces, which with the caller's initial wall piece make 4 corners and 4 walls, one wall per side.

### 6.4 The third floor and the wall type names

The first-floor and second-floor outer walls use the **base** grid (both floors share the footprint); the third floor uses `thirdFloorGrid`. Wall types: `wall_flat` for the first floor, `wall_window` for floors 1 and 2.

### 6.5 `createRoof(list, origin, R, grid, upper)`

`upper` is the grid of the floor above, or none. For each pass, cells are scanned y from 0 to height-1 (outer), x from 0 to width-1 (inner). `K(x, y)` is the cell origin of 6.1 with `F = origin`. `hasUpper(x, y)` is `upper != none and isHouse(upper, x, y)`. Positions use `K = K(x, y)`; "rotation" means `R` plus the stated extra rotation. Unless noted, template pieces carry no mirror.

**Pass A** (every cell where `isHouse(grid, x, y)` and not `hasUpper`):

| Piece | Condition | Position | Rotation |
|---|---|---|---|
| `roof` | always | `K.above(3)` | R |
| `roof_front` | not house (x+1, y) | `K.relative(R·EAST, 6)` | R |
| `roof_front` | not house (x-1, y) | `K.relative(R·EAST, 0).relative(R·SOUTH, 7)` | R + CLOCKWISE_180 |
| `roof_front` | not house (x, y-1) | `K.relative(R·WEST, 1)` | R + COUNTERCLOCKWISE_90 |
| `roof_front` | not house (x, y+1) | `K.relative(R·EAST, 6).relative(R·SOUTH, 6)` | R + CLOCKWISE_90 |

The four `roof_front` tests are made in that order after the `roof` piece of the cell.

**Pass B** (only when `upper != none`; cells with `isHouse(grid, x, y)` and `hasUpper`), small walls where the floor below is exposed next to a house cell of the upper floor:

| Piece | Condition (house is on `grid`) | Position | Rotation |
|---|---|---|---|
| `small_wall` | not house (x+1, y) | `K.relative(R·EAST, 7)` | R |
| `small_wall` | not house (x-1, y) | `K.relative(R·WEST, 1).relative(R·SOUTH, 6)` | R + CLOCKWISE_180 |
| `small_wall` | not house (x, y-1) | `K.relative(R·WEST, 0).relative(R·NORTH, 1)` | R + COUNTERCLOCKWISE_90 |
| `small_wall` | not house (x, y+1) | `K.relative(R·EAST, 6).relative(R·SOUTH, 7)` | R + CLOCKWISE_90 |
| `small_wall_corner` | not house (x+1, y) and not house (x, y-1) | `K.relative(R·EAST, 7).relative(R·NORTH, 2)` | R |
| `small_wall_corner` | not house (x+1, y) and not house (x, y+1) | `K.relative(R·EAST, 8).relative(R·SOUTH, 7)` | R + CLOCKWISE_90 |
| `small_wall_corner` | not house (x-1, y) and not house (x, y-1) | `K.relative(R·WEST, 2).relative(R·NORTH, 1)` | R + COUNTERCLOCKWISE_90 |
| `small_wall_corner` | not house (x-1, y) and not house (x, y+1) | `K.relative(R·WEST, 1).relative(R·SOUTH, 8)` | R + CLOCKWISE_180 |

Rows are evaluated in the order listed.

**Pass C** (always run; cells with `isHouse(grid, x, y)` and not `hasUpper`), roof corners. In each block the `roof_corner` row and the `roof_inner_corner` row that follows it test the same y neighbour and form an if / else-if: the inner corner is emitted only when the `roof_corner` condition failed (the y neighbour is house) and the diagonal is house. For the east side (when (x+1, y) is not house), `V = K.relative(R·EAST, 6)`:

| Piece | Condition | Position | Rotation |
|---|---|---|---|
| `roof_corner` | (x, y+1) not house | `V.relative(R·SOUTH, 6)` | R |
| `roof_inner_corner` (else) | (x, y+1) house and (x+1, y+1) house | `V.relative(R·SOUTH, 5)` | R |
| `roof_corner` | (x, y-1) not house | `V` | R + COUNTERCLOCKWISE_90 |
| `roof_inner_corner` (else) | (x, y-1) house and (x+1, y-1) house | `K.relative(R·EAST, 9).relative(R·NORTH, 2)` | R + CLOCKWISE_90 |

For the west side (when (x-1, y) is not house), `V = K` (offsets 0 and 0):

| Piece | Condition | Position | Rotation |
|---|---|---|---|
| `roof_corner` | (x, y+1) not house | `V.relative(R·SOUTH, 6)` | R + CLOCKWISE_90 |
| `roof_inner_corner` (else) | (x, y+1) house and (x-1, y+1) house | `V.relative(R·SOUTH, 8).relative(R·WEST, 3)` | R + COUNTERCLOCKWISE_90 |
| `roof_corner` | (x, y-1) not house | `V` | R + CLOCKWISE_180 |
| `roof_inner_corner` (else) | (x, y-1) house and (x-1, y-1) house | `V.relative(R·SOUTH, 1)` | R + CLOCKWISE_180 |

The east block is emitted before the west block of the same cell; within a block rows are in the order listed. There is no corner logic on the north and south sides: the corners are produced from the east and west tests with the y neighbours.

Passes A, B and C are three full scans, emitted in that order (all of A, then all of B, then all of C).

### 6.6 Floors: corridors, carpets, indoor walls, doors, rooms

For floor `i` in 0, 1, 2 (floors in this order). `F = O.above(8*i + (i == 2 ? 3 : 0))`; `fr = floorRooms[i]`; `g = thirdFloorGrid` if `i == 2` else `baseGrid`; templates by floor:

| Item | i = 0 | i = 1, 2 |
|---|---|---|
| `carpetSouth` | `carpet_south_1` | `carpet_south_2` |
| `carpetWest` | `carpet_west_1` | `carpet_west_2` |
| `wall` | `indoors_wall_1` | `indoors_wall_2` |
| `door` | `indoors_door_1` | `indoors_door_2` |
| Room-name collection | `FirstFloorRoomCollection` | `SecondFloorRoomCollection` (floor 1), `ThirdFloorRoomCollection` (floor 2, identical rules) |

**Pass 1: corridor floors and carpets.** Scan `y` outer, `x` inner over `g`. For every cell with `g(x, y) == 1`: `p = K(x, y)` (with `F`); add `corridor_floor` at `p`, rotation R. Then, in this order, for each of the four neighbours: a carpet is added when the neighbour's grid value is 1 **or** `(fr(neighbour) & 0x800000) != 0`:

| Neighbour | Piece | Position |
|---|---|---|
| (x, y-1) | `carpet_north` | `p.relative(R·EAST, 1).above()` |
| (x+1, y) | `carpet_east` | `p.relative(R·SOUTH, 1).relative(R·EAST, 5).above()` |
| (x, y+1) | `carpetSouth` | `p.relative(R·SOUTH, 5).relative(R·WEST, 1)` |
| (x-1, y) | `carpetWest` | `p.relative(R·WEST, 1).relative(R·NORTH, 1)` |

All four pieces have rotation R. (`.above()` is above(1); the south and west carpets are not raised.)

**Pass 2: per-cell rooms and walls.** Scan `y` outer, `x` inner over `g`. Let `stairCell = (i == 2 and g(x, y) == 3)`. Process the cell only if `g(x, y) == 2` or `stairCell`. Then:

1. `code = fr(x, y)`, `type = code & 0xF0000`, `id = code & 0xFFFF`. `stairCell = stairCell and (code & 0x800000) != 0` (true only for the stair-room half that has the corridor flag, section 5.5 step 5; the other half keeps a code of 0).
2. **Door direction** `doorDir`: build the list of directions (HORIZONTAL order) `d` for which `g(x + d.x, y + d.z) == 1`, but only if `(code & 0x200000) != 0` (otherwise the list is empty). If the list is non-empty: `doorDir = list[random.nextInt(list.size())]` (**a draw**, also for a one-element list). Else if `(code & 0x100000) != 0` (origin without door): `doorDir = UP`. Else `doorDir = none`.
3. `q = K(x, y).relative(R·EAST, -1)` (the room-cell origin is one block west of the cell origin).
4. Indoor walls, tested in this order. `isRoomId(x', y')` is `(floorRooms[i](x', y') & 0xFFFF) == id` (it reads the room grid of the current floor):

   | Side | Condition | Piece | Position | Rotation |
   |---|---|---|---|---|
   | west | `isHouse(g, x-1, y)` and not `isRoomId(x-1, y)` | `door` if `doorDir == WEST` else `wall` | `q` | R |
   | east | `g(x+1, y) == 1` and not `stairCell` | `door` if `doorDir == EAST` else `wall` | `q.relative(R·EAST, 8)` | R |
   | south | `isHouse(g, x, y+1)` and not `isRoomId(x, y+1)` | `door` if `doorDir == SOUTH` else `wall` | `q.relative(R·SOUTH, 7).relative(R·EAST, 7)` | R + CLOCKWISE_90 |
   | north | `g(x, y-1) == 1` and not `stairCell` | `door` if `doorDir == NORTH` else `wall` | `q.relative(R·NORTH, 1).relative(R·EAST, 7)` | R + CLOCKWISE_90 |

   West and south walls fire against any house neighbour that is not the same room (corridors, other rooms); east and north walls fire only against corridor cells, because a neighbouring room's own west or south wall covers that boundary. Together every room boundary gets exactly one wall piece, and a door only appears where the door direction coincides.
5. Room pieces, by `type`:
   * `ROOM_1x1`: `addRoom1x1(q, R, doorDir, collection[i])`.
   * `ROOM_1x2` and `doorDir != none`: `roomDir = get1x2RoomDirection(g, x, y, i, id)` (the first HORIZONTAL direction whose neighbour belongs to room `id` on floor `i`), `stairs = (code & 0x400000) != 0`; `addRoom1x2(q, R, roomDir, doorDir, collection[i], stairs)`.
   * `ROOM_2x2` and `doorDir` neither `none` nor `UP`: `s = doorDir.getClockWise()`; if not `isRoomId(x + s.x, y + s.z)` then `s = s.getOpposite()`; `addRoom2x2(q, R, s, doorDir, collection[i])`.
   * `ROOM_2x2` and `doorDir == UP`: `addRoom2x2Secret(q, R, collection[i])`.
   * Any other combination (a 1x2 or 2x2 cell that is not the origin, `doorDir == none`; type 0, as for the third-floor stair cells): nothing.

   A 1x1 room always has its single cell as origin, so `doorDir` is never `none` for it.

### 6.7 Room placement tables

In every table `q` is the position passed in (step 3 above), and "offset (e, s)" means `q.relative(R·EAST, e).relative(R·SOUTH, s)` (east applied first). A template piece is created with `rotation = R + extra` and the stated mirror. The 4-argument piece constructor (no mirror) is the mirror `NONE` case.

**`addRoom1x1(q, R, doorDir, coll)`**

1. `name = coll.get1x1(random)` (always drawn).
2. By `doorDir`, `extra` and the local offset `(lx, lz)` (before rotation), in this table:

   | doorDir | extra | (lx, lz) | name |
   |---|---|---|---|
   | EAST | NONE | (1, 0) | as drawn |
   | NORTH | COUNTERCLOCKWISE_90 | (1, 6) | as drawn |
   | WEST | CLOCKWISE_180 | (7, 6) | as drawn |
   | SOUTH | CLOCKWISE_90 | (7, 0) | as drawn |
   | UP (no door) | NONE | (1, 0) | replaced: `name = coll.get1x1Secret(random)` (a second draw) |

   The offsets come from `StructureTemplate.getZeroPositionWithTransform((1,0,0), NONE, extra, 7, 7)` (the block position of the template's origin so that the 7 by 7 room turns about its own centre; with `s = 6`: NONE adds (0,0), CLOCKWISE_90 adds (6, 0), CLOCKWISE_180 adds (6, 6), COUNTERCLOCKWISE_90 adds (0, 6) to (1, 0), and the mirror is NONE).
3. `rotation = extra + R` (`extra.getRotated(R)`), `(lx, lz)` is rotated with `BlockPos.rotate(R)` (section 2.1) giving `(rx, rz)`, and the piece is placed at `q + (rx, 0, rz)`. (This is the same as offset `(lx, lz)` along `R·EAST`, `R·SOUTH`.)

**`addRoom1x2(q, R, roomDir, doorDir, coll, stairs)`** (first matching row wins; if no row matches, nothing is added and nothing is drawn):

| # | doorDir | roomDir | name source | offset (e, s) | extra | mirror |
|---|---|---|---|---|---|---|
| 1 | EAST | SOUTH | side | (1, 0) | NONE | NONE |
| 2 | EAST | NORTH | side | (1, 6) | NONE | LEFT_RIGHT |
| 3 | WEST | NORTH | side | (7, 6) | CLOCKWISE_180 | NONE |
| 4 | WEST | SOUTH | side | (7, 0) | NONE | FRONT_BACK |
| 5 | SOUTH | EAST | side | (1, 0) | CLOCKWISE_90 | LEFT_RIGHT |
| 6 | SOUTH | WEST | side | (7, 0) | CLOCKWISE_90 | NONE |
| 7 | NORTH | WEST | side | (7, 6) | CLOCKWISE_90 | FRONT_BACK |
| 8 | NORTH | EAST | side | (1, 6) | COUNTERCLOCKWISE_90 | NONE |
| 9 | SOUTH | NORTH | front | (1, -8) | NONE | NONE |
| 10 | NORTH | SOUTH | front | (7, 14) | CLOCKWISE_180 | NONE |
| 11 | WEST | EAST | front | (15, 0) | CLOCKWISE_90 | NONE |
| 12 | EAST | WEST | front | (-7, 6) | COUNTERCLOCKWISE_90 | NONE |
| 13 | UP | EAST | secret | (15, 0) | CLOCKWISE_90 | NONE |
| 14 | UP | SOUTH | secret | (1, 0) | NONE | NONE |

"side" = `coll.get1x2SideEntrance(random, stairs)`, "front" = `coll.get1x2FrontEntrance(random, stairs)`, "secret" = `coll.get1x2Secret(random)`. The name is chosen when the row matches (one draw, or none for the floor-1/2 stairs names, section 6.8). (`doorDir` is the direction of the corridor next to the origin cell, `roomDir` the direction from the origin cell to the second cell of the room; "side entrance" means the door is on a long side of the 7 by 15 room, "front entrance" a short side.) Rows 13 and 14 are the only ones with `UP`; `UP` with NORTH or WEST never occurs because a door-less origin is `(x0, y0)`.

**`addRoom2x2(q, R, sideDir, doorDir, coll)`** (note the argument order: `sideDir`, then `doorDir`). The template name `coll.get2x2(random)` is drawn **after** the row is chosen and **always**, because the default row exists:

| # | doorDir | sideDir | offset (e, s) | extra | mirror |
|---|---|---|---|---|---|
| 1 | EAST | SOUTH | (-7, 0) | NONE | NONE |
| 2 | EAST | NORTH | (-7, 6) | NONE | LEFT_RIGHT |
| 3 | NORTH | EAST | (1, 14) | COUNTERCLOCKWISE_90 | NONE |
| 4 | NORTH | WEST | (7, 14) | COUNTERCLOCKWISE_90 | LEFT_RIGHT |
| 5 | SOUTH | WEST | (7, -8) | CLOCKWISE_90 | NONE |
| 6 | SOUTH | EAST | (1, -8) | CLOCKWISE_90 | LEFT_RIGHT |
| 7 | WEST | NORTH | (15, 6) | CLOCKWISE_180 | NONE |
| 8 | WEST | SOUTH | (15, 0) | NONE | FRONT_BACK |
| default | any other pair | | (0, 0) | NONE | NONE |

Rotation of the piece: `R + extra`. Position: `q.relative(R·EAST, e).relative(R·SOUTH, s)`.

**`addRoom2x2Secret(q, R, coll)`**: one piece, name `coll.get2x2Secret(random)` (`2x2_s1` for every floor, no draw), position `q.relative(R·EAST, 1)`, rotation R, mirror NONE.

### 6.8 Template-name selection (`FloorRoomCollection`)

`get...` methods draw from the structure-start random; "k = nextInt(n) + 1".

| Method | First floor | Floors 1 and 2 (same class rules) |
|---|---|---|
| `get1x1` | `1x1_a` + (nextInt(5) + 1) | `1x1_b` + (nextInt(5) + 1) |
| `get1x1Secret` | `1x1_as` + (nextInt(4) + 1) | `1x1_as` + (nextInt(4) + 1) |
| `get1x2SideEntrance(stairs)` | `1x2_a` + (nextInt(9) + 1) (the flag is ignored) | stairs: `1x2_c_stairs` (**no draw**); else `1x2_c` + (nextInt(4) + 1) |
| `get1x2FrontEntrance(stairs)` | `1x2_b` + (nextInt(5) + 1) (flag ignored) | stairs: `1x2_d_stairs` (**no draw**); else `1x2_d` + (nextInt(5) + 1) |
| `get1x2Secret` | `1x2_s` + (nextInt(2) + 1) | `1x2_se` + (nextInt(1) + 1) (still one draw; always `1x2_se1`) |
| `get2x2` | `2x2_a` + (nextInt(4) + 1) | `2x2_b` + (nextInt(5) + 1) |
| `get2x2Secret` | `2x2_s1` | `2x2_s1` |

All names exist as templates: of the 73 files, 52 are room templates (5 `1x1_a`, 4 `1x1_as`, 5 `1x1_b`; 9 `1x2_a`, 5 `1x2_b`, 2 `1x2_s`, 4 `1x2_c`, `1x2_c_stairs`, 5 `1x2_d`, `1x2_d_stairs`, `1x2_se1`; 4 `2x2_a`, 5 `2x2_b`, `2x2_s1`) and 21 are structural pieces (section 10). The third-floor class extends the second-floor class and overrides nothing.

---

## 7. The piece class (`WoodlandMansionPiece`)

A `TemplateStructurePiece` (generic template piece, 36-2). Facts specific to the mansion:

| Item | Value |
|---|---|
| Constructors | `(manager, name, position, rotation)` (mirror NONE) and `(manager, name, position, rotation, mirror)`; the placer uses both |
| Piece type, gen depth | `WOODLAND_MANSION_PIECE`, depth 0 |
| Template location | `minecraft:woodland_mansion/<name>` (`Identifier.withDefaultNamespace("woodland_mansion/" + name)`) |
| Placement settings | `ignoreEntities = true`, `rotation` and `mirror` as given, pivot (0, 0, 0), one processor `BlockIgnoreProcessor.STRUCTURE_BLOCK` (structure blocks are never placed; air and every other state of the template are placed) |
| Bounding box | `template.getBoundingBox(settings, position)` (section 2.1) |
| Saved fields | the base template keys (`Template` = the short name, `TPX`, `TPY`, `TPZ`) plus `Rot` and `Mi` (via `Rotation.LEGACY_CODEC`, `Mirror.LEGACY_CODEC`) |

Placement at decoration time (`TemplateStructurePiece.postProcess`, called per chunk by `StructureStart.placeInChunk` for every piece whose bounding box intersects the chunk's write box, in list order; the pivot position passed down is `(center x of the first piece's box, its minY, center z)`; the first piece is the entrance):

1. `settings.boundingBox = box` (the clip box of the chunk), the piece's bounding box is recomputed, and `template.placeInWorld(level, position, pivot, settings, random, 2)` runs (block flag 2; the engine is a sibling part).
2. If that returned true: every template block that is a structure block with NBT `mode = DATA` (collected by `filterBlocks`, which keeps only blocks whose transformed position is inside `box`, so each marker is handled by the one chunk step that contains it) is passed, with its `metadata` string, its world position `pos`, the level and the piece's random, to `handleDataMarker`.
3. Jigsaw blocks (none in the mansion templates) would be replaced by their `final_state`.

### 7.1 `handleDataMarker(metadata, pos, level, random, box)`

* **Chest markers**: if `metadata` starts with `Chest`: `rot = settings.rotation`; the chest state is the default `minecraft:chest`; if the string equals exactly `ChestWest`, `ChestEast`, `ChestSouth` or `ChestNorth`, then `FACING = rot.rotate(WEST / EAST / SOUTH / NORTH)` respectively; any other `Chest...` string keeps the default facing. Then `createChest(level, box, random, pos, WOODLAND_MANSION loot table, state)` (from `StructurePiece`): if `pos` is not inside `box` or the block at `pos` is already a chest, it returns false and does nothing; otherwise it sets the block (flag 2) and, if the block entity is a chest, sets its loot table to `chests/woodland_mansion` with the loot seed `random.nextLong()` (one draw of the piece random per chest). The random here is the piece random of the decoration stage (35-1 section 5.1 item 3: reseeded per structure of the step).
* **Mob markers**: any other string, by exact match:

  | `metadata` | Mobs created |
  |---|---|
  | `Mage` | one evoker |
  | `Warrior` | one vindicator |
  | `Group of Allays` | `n = level.getRandom().nextInt(3) + 1` allays (1 to 3), each created separately; note this is the **level accessor's random**, not the piece random |
  | anything else | the method returns at once: nothing is created and the marker position is not touched |

  Each mob is created with `EntityType.create(level.getLevel(), EntitySpawnReason.STRUCTURE)`. After the list is complete, each non-null mob is processed in list order: `setPersistenceRequired()`; `snapTo(pos, 0, 0)` (`Entity.snapTo(BlockPos, float, float)` calls `snapTo(Vec3.atBottomCenterOf(pos), yRot, xRot)` and `Vec3.atBottomCenterOf` adds (0.5, 0, 0.5) to the block corner, so the mob stands at (x + 0.5, y, z + 0.5), the bottom centre of the marker block, with yaw 0 and pitch 0; read); `finalizeSpawn(level, level.getCurrentDifficultyAt(mob.blockPosition()), STRUCTURE, null)` (18 section 7.1; evoker and vindicator behaviour is 20 section 13, the allay is 19 section 15); `level.addFreshEntityWithPassengers(mob)`; then `level.setBlock(pos, AIR, 2)` for the marker position. The marker block itself was never placed, so the position holds the template's neighbour state before this step (usually air from the template or the terrain); the set-to-air is applied once per mob (an allay group sets it up to three times).

The version read here has **no wood or cobblestone golem markers**: the only data markers in the 73 templates are the `Chest*` names, `Mage`, `Warrior` and `Group of Allays` (section 10).

---

## 8. After placement: the foundation (`WoodlandMansionStructure.afterPlace`)

Called by `StructureStart.placeInChunk` after the pieces of the chunk have been placed, with the level, the chunk's write box `box` and the piece container. It fills the space under the lowest layer of the mansion with cobblestone so the building does not hang over a slope:

1. `minWorldY = level.getMinY()`. `bb = container.calculateBoundingBox()` (the union of all piece boxes); `y0 = bb.minY`.
2. For every `x` from `box.minX` to `box.maxX` and `z` from `box.minZ` to `box.maxZ` (x outer, z inner), with `pos = (x, y0, z)`:
   * Act only if the block at `pos` is **not air** (`isEmptyBlock` false), and `bb.isInside(pos)`, and `container.isInsidePiece(pos)` (true when `pos` is inside the bounding box of at least one piece; bounding boxes, not blocks).
   * Then for `y` from `y0 - 1` downward while `y > minWorldY`: if the block at `(x, y, z)` is air or its state is a liquid (`BlockState.liquid()`), set it to `minecraft:cobblestone` with flag 2 and continue; otherwise stop for this column.

The test `isEmptyBlock` is true for air, cave air and void air. Water and lava are replaced by cobblestone below the mansion. There is no terrain carving above the mansion other than the template's own air.

---

## 9. Order of random draws (summary)

For one mansion, from the structure-start random (section 2.2), in this order:

1. `Rotation.getRandom`: one `nextInt(4)` (section 3, step 4).
2. `MansionGrid`: the four corridor growths (draws inside `recursiveCorridor`, 5.2, depth-first in recursion order); then `identifyRooms` for floor 0 (the shuffle's draws, then per new room two `nextBoolean`); then for floor 1; then `setupThirdFloor` (a `nextInt(candidates)`, a `nextInt(dirs)`, a corridor growth of depth 4); then `identifyRooms` for floor 2.
3. `MansionPiecePlacer`: for floors 0, 1, 2 in this order, cells in y-outer x-inner order; for each processed cell, first the door draw (`nextInt(list.size())` when the list is not empty), then the room's name draws as the placement helper executes (6.7, 6.8). Entrance, walls, roofs, carpets and corridor floors draw nothing.

Decoration stage: the piece random (one `nextLong()` per chest created, in marker order within each piece, pieces in list order, per chunk) and the level accessor random (allay group sizes) are separate sources (section 7.1); the level accessor random is `RandomState`'s named positional factory `minecraft:worldgen_region_random` taken `.at(center chunk's world position)` when the generation region object is created (`WorldGenRegion` constructor); it is one stream shared by every consumer of that region (Open question 1).

---

## 10. Template catalogue: sizes and markers

Sizes are `[x, y, z]` blocks read from the `size` tag of each NBT file (the only part of the template data needed to check the bounding-box arithmetic); `markers` lists the structure blocks of DATA mode (position `(x, y, z)` in template coordinates, metadata). This is data and is given only to define the marker inventory the engine must handle and to support the validation tests.

| Template family | Size | Count of files |
|---|---|---|
| `1x1_a1` to `1x1_a5`, `1x1_as1` to `1x1_as4`, `corridor_floor` | 7, 8, 7 | 9 + 1 |
| `1x1_b1` to `1x1_b5` | 7, 11, 7 | 5 |
| `1x2_a1` to `1x2_a9`, `1x2_b1` to `1x2_b5`, `1x2_s1`, `1x2_s2` | 7, 8, 15 | 16 |
| `1x2_c1` to `1x2_c4`, `1x2_d1` to `1x2_d5`, `1x2_se1` | 7, 11, 15 | 10 |
| `1x2_c_stairs`, `1x2_d_stairs` | 7, 22, 15 | 2 |
| `2x2_a1` to `2x2_a4` | 15, 8, 15 | 4 |
| `2x2_b1` to `2x2_b5`, `2x2_s1` | 15, 11, 15 | 6 |
| `entrance` | 21, 19, 16 | 1 |
| `wall_flat`, `wall_window` | 2, 8, 8 | 2 |
| `wall_corner` | 9, 8, 2 | 1 |
| `indoors_wall_1`, `indoors_door_1` | 1, 8, 8 | 2 |
| `indoors_wall_2`, `indoors_door_2` | 1, 11, 8 | 2 |
| `carpet_south_1`, `carpet_west_1` | 8, 8, 3 and 3, 8, 8 | 2 |
| `carpet_south_2`, `carpet_west_2` | 8, 11, 3 and 3, 11, 8 | 2 |
| `carpet_north` | 5, 1, 2 | 1 |
| `carpet_east` | 2, 1, 5 | 1 |
| `roof` | 8, 1, 8 | 1 |
| `roof_front` | 4, 4, 8 | 1 |
| `roof_corner`, `roof_inner_corner` | 4, 4, 4 | 2 |
| `small_wall` | 2, 4, 8 | 1 |
| `small_wall_corner` | 2, 4, 2 | 1 |

(The total is 73.) All templates carry no entities in their `entities` list (and `ignoreEntities` is set anyway). Templates **with** data markers (all of mode DATA; position, metadata):

| Template | Markers |
|---|---|
| `1x1_a4` | (6,6,3) ChestWest |
| `1x1_as1` | (5,1,1) ChestWest |
| `1x2_a1` | (3,1,3) Warrior; (3,1,12) ChestSouth |
| `1x2_a3` | (3,2,8) Warrior |
| `1x2_a8` | (2,1,2) Warrior |
| `1x2_a9` | (5,1,1) Warrior |
| `1x2_b1` | (3,1,13) Warrior |
| `1x2_b2` | (5,1,11) Warrior |
| `1x2_b3` | (3,1,0) ChestSouth; (3,1,4) Warrior |
| `1x2_b4` | (4,3,9) ChestNorth |
| `1x2_c3` | (4,1,6), (4,1,9), (4,1,12) Warrior |
| `1x2_d2` | (6,7,12) ChestWest |
| `1x2_d3` | (2,2,10), (4,2,10) Warrior; (3,3,3) Mage |
| `1x2_s1` | (3,1,4) ChestSouth |
| `1x2_se1` | (3,9,1) ChestSouth; (3,9,13) ChestNorth |
| `2x2_a1` | (12,1,3) Warrior; (2,2,8), (4,2,2), (5,2,12), (12,2,12) Group of Allays |
| `2x2_a2` | (9,1,2) Warrior |
| `2x2_b1` | (2,1,8) Mage; (4,1,4), (8,1,9) Warrior |
| `2x2_b2` | (2,1,7) Mage; (9,1,8), (13,1,2) Warrior |
| `2x2_b4` | (3,1,3), (4,1,11) Warrior; (3,1,8) Mage |
| `2x2_b5` | (7,7,0) ChestSouth |

Every other template has no markers. In total: 10 chest markers (`1x1_a4`, `1x1_as1`, `1x2_a1`, `1x2_b3`, `1x2_b4`, `1x2_d2`, `1x2_s1`, `1x2_se1` twice, `2x2_b5`), 20 Warrior markers (`1x2_a1`, `a3`, `a8`, `a9`, `b1`, `b2`, `b3` one each; `1x2_c3` three; `1x2_d3` two; `2x2_a1`, `2x2_a2` one each; `2x2_b1`, `b2`, `b4` two each), 4 Mage, 4 Group of Allays markers.

---

## 11. Worked examples (computed)

### 11.1 Grid and piece list for world seed 0, chunk (2, 0)

Inputs: `worldSeed = 0`, `cx = 2`, `cz = 0` (start block x = 39, z = 7). Section 3 step 1: `setLargeFeatureSeed(0, 2, 0)`. Step 4 draws `nextInt(4) = 0`: the rotation is **NONE**. (Whether the height test passes at that column is a terrain question and is not part of this example; positions below are relative to `O = (0, 0, 0)`.)

Base grid after construction (rows y = 0 to 10, columns x = 0 to 10):

```
5 5 5 5 5 5 5 5 5 5 5
5 5 5 5 5 5 5 5 5 5 5
0 2 2 2 2 2 1 1 1 5 5
0 2 1 1 1 1 1 2 1 5 5
2 2 1 2 2 2 2 3 3 5 5
2 2 1 1 1 2 2 3 3 5 5
0 0 2 2 1 1 1 2 1 5 5
0 0 2 2 1 1 1 1 1 5 5
0 0 0 0 2 2 2 2 2 0 0
5 5 5 5 5 5 5 5 5 5 5
5 5 5 5 5 5 5 5 5 5 5
```

Floor 0 room codes (hex, `.` = 0), same orientation:

```
.       .       .       .       .       .       .       .       .       .       .
.       .       .       .       .       .       .       .       .       .       .
.       20015   320015  2000d   32000d  310016  .       .       .       .       .
.       32000a  .       .       .       .       .       310013  .       .       .
110018  2000a   .       20014   320014  4000c   34000c  .       800000  .       .
2000f   32000f  .       .       .       4000c   4000c   .       800000  .       .
.       .       320010  20010   .       .       .       31000b  .       .       .
.       .       2000e   32000e  .       .       .       .       .       .       .
.       .       .       .       20012   320012  310017  20011   320011  .       .
.       .       .       .       .       .       .       .       .       .       .
.       .       .       .       .       .       .       .       .       .       .
```

Reading it: cell (0,4) `0x110018` is a 1x1 room (id 0x18) with the origin flag and no door (a secret room); (5,4) to (6,5) is the 2x2 room id 0x0c whose origin (6,4) has door flag and 2x2 (`0x34000c`: origin, door, 2x2, id 12); (8,4) and (8,5) hold only the corridor flag (the entrance block). Floor 1 codes differ (its own shuffle); it holds one stairs room under the superseded order (floor-1 codes not regenerated, not a test vector; Open question 14). The third-floor grid is:

```
5 5 5 5 5 5 5 5 5 5 5
5 5 5 5 5 5 5 5 5 5 5
5 0 0 0 0 0 0 0 0 5 5
5 0 0 0 0 0 0 0 0 5 5
0 2 2 2 0 0 0 0 0 5 5
0 2 1 2 2 3 3 0 0 5 5
5 5 1 2 2 2 1 2 2 5 5
5 5 1 1 1 1 1 2 2 5 5
5 5 5 5 2 2 2 0 0 5 5
5 5 5 5 5 5 5 5 5 5 5
5 5 5 5 5 5 5 5 5 5 5
```

with the stair-room cells (5,5) and (6,5) both 3 and `floorRooms[2](6,5) = 0x800000`.

Pieces (the first entries, in emission order; position is `(x, y, z)` relative to `O`; rotation is the piece rotation; mirror NONE unless shown):

| # | Piece | Position | Rotation |
|---|---|---|---|
| 1 | `entrance` | (-9, 0, 0) | NONE |
| 2 | `wall_flat` | (7, 0, 16) | NONE |
| 3 | `wall_flat` | (7, 0, 24) | NONE |
| 4 | `wall_flat` | (7, 0, 32) | NONE |
| 5 | `wall_corner` | (0, 0, 39) | NONE |
| 6 | `wall_flat` | (6, 0, 39) | CLOCKWISE_90 |
| 7 | `wall_flat` | (-2, 0, 39) | CLOCKWISE_90 |

Check of pieces 1 to 7 by hand: the cursor starts at `O`; `entrance` is placed at `O.relative(R·WEST, 9) = (-9, 0, 0)`; the cursor then moves to `O.relative(R·SOUTH, 16) = (0, 0, 16)`. The first wall piece is at `(0,0,16).relative(EAST, 7) = (7, 0, 16)` and the cursor moves 8 south to `(0, 0, 24)`; so pieces 2 to 4 are at z = 16, 24, 32 and the cursor ends at `(0, 0, 40)`. The cell ahead is then outside, so `traverseTurn` runs: the cursor moves by -1 along SOUTH to `(0, 0, 39)` and `wall_corner` is placed there (piece 5); the cursor moves by -7 along SOUTH to `(0, 0, 32)` and by -6 along WEST (6 toward EAST) to `(6, 0, 32)`; the rotation becomes CLOCKWISE_90 (`R'`). The next wall piece is at `(6, 0, 32).relative(R'·EAST, 7)` with `R'·EAST = SOUTH`, i.e. `(6, 0, 39)` (piece 6); the cursor moves 8 along `R'·SOUTH = WEST` to `(-2, 0, 32)` and piece 7 is at `(-2, 0, 39)`.

Non-normative, unverified totals (computed with the superseded corner-trial order of section 5.4 step 4; the base grid and floor-0 room codes of this example are identical under the corrected order, but the totals below, the union box and the floor-1 codes quoted above for the stairs room were not regenerated; do not use them as test vectors, Open question 14): 558 pieces; per name: `entrance` 1; `wall_flat` 30; `wall_window` 56; `wall_corner` 23; `roof` 53, `roof_front` 47, `roof_corner` 14, `roof_inner_corner` 6; `small_wall` 11, `small_wall_corner` 2; `corridor_floor` 52; carpets: `carpet_north` 24, `carpet_east` 32, `carpet_south_1` 10, `carpet_south_2` 13, `carpet_west_1` 14, `carpet_west_2` 18; `indoors_wall_1` 31, `indoors_door_1` 14, `indoors_wall_2` 46, `indoors_door_2` 22; rooms: `1x1_*` 12, `1x2_*` 25 (including 1 `1x2_c_stairs` and 1 `1x2_se1`), `2x2_*` 2. Union of the template boxes (section 2.1) relative to `O`: x from -67 to 11, y from 0 to 30, z from -19 to 41 (79 by 31 by 61 blocks). The lowest layer is `y = 0`, so the foundation of section 8 starts at `O.y - 1`.

A room piece, by hand: the floor-0 cell (0, 4) is the secret 1x1 room. `K(0, 4) = O + SOUTH * 8 * (4 - 4) + EAST * 8 * (0 - 8) = (-64, 0, 0)`; `q = K.relative(EAST, -1) = (-65, 0, 0)`. `doorDir = UP`, so `extra = NONE`, local offset (1, 0): the position is `(-64, 0, 0)`, rotation NONE, name `1x1_as` plus a draw (here `1x1_as3`).

### 11.2 Hand-checkable fragments

1. **1x1 rooms, all four doors, rotation R = NONE, q = (0, 0, 0):** door EAST: piece at (1,0,0), rotation NONE; door NORTH: (1,0,6), COUNTERCLOCKWISE_90; door WEST: (7,0,6), CLOCKWISE_180; door SOUTH: (7,0,0), CLOCKWISE_90. With R = CLOCKWISE_90 the local offset is rotated first: door EAST gives `(1,0)` rotated to `(0, 1)`, so the piece is at `q + (0, 0, 1)` with rotation CLOCKWISE_90; door SOUTH gives `(7, 0)` rotated to `(0, 7)`, position `q + (0, 0, 7)`, rotation CLOCKWISE_180.
2. **Edge cleaning** on a clear cell at (5, 5): house at (5, 4), (5, 6), (4, 5) (three orthogonal neighbours) gives value 2; house at (5, 4) and (5, 6) only (n = 2, m = 0) gives 2; house at (5, 4), (6, 5), (6, 4) (n = 2, m = 1) gives 2; house at (5, 4), (6, 5), (6, 4), (4, 6) (n = 2, m = 2) stays 0; house at (5, 4) only stays 0.
3. **Third floor without candidates:** if no 1x2 room of floor 1 has a door, `thirdFloorGrid` is all 5, `isHouse` is false everywhere, the third-floor start search of 6.2 step 5 finds no cell (no wall pieces), the second `createRoof` emits nothing and the floor-2 pass 1 and pass 2 emit nothing (no value 1 or 2 cells).
4. **Loot seed of a chest:** if the piece random has just produced `s = nextLong()`, the chest block entity gets loot table `chests/woodland_mansion` and loot seed `s`; two chests in one piece (such as `1x2_se1`) take consecutive `nextLong()` values in the order of the template's block list (the marker order of `filterBlocks`, i.e. palette block order) (inferred; the order within `filterBlocks` is the template's own block order).

---

## 12. Validation

An implementation is correct when all the following hold; checks 1 to 7 are testable from the grid alone.

1. **Fixed layout.** After section 5.1 step 2 the base grid equals the table given there, exactly.
2. **Rows.** After the whole construction the base grid still has value 5 in rows 0, 1, 9, 10 and in columns 9 and 10 for rows 2 to 7; the entrance block (7,4) to (8,5) is 3; (6,4) and (6,5) are 2.
3. **No fillable clear cell.** After section 5.1 step 4 no clear cell satisfies the `cleanEdges` condition.
4. **Room partition.** On floors 0 and 1 every value-2 cell has a non-zero room code; a room's cells share one id; 1x1 rooms have 1 cell, 1x2 rooms 2 orthogonally adjacent cells, 2x2 rooms 4 cells; every room has exactly one origin cell; ids are unique per floor and at least 10; ids on floor `f` are not comparable with ids on another floor.
5. **Doors.** A room with the door flag has its origin orthogonally next to a corridor cell; a room without it has its origin at its minimum x and minimum y cell.
6. **Third floor.** If any floor-1 room is a 1x2 with a door flag, exactly one floor-1 room has the stairs flag, its two cells are 3 on the third-floor grid, and `floorRooms[2]` holds the corridor flag on exactly one of the two cells, the one found by `get1x2RoomDirection` from the picked cell. Otherwise the third-floor grid is all 5.
7. **Outer walls.** There is exactly one `entrance` piece. The closed-lap property of the cursor arithmetic (6.3): after `traverseOuterWalls(d5, baseGrid, ...)` the cursor is at `O` with rotation `R`; on a one-cell grid the walk (after the caller's initial wall piece) emits 4 `wall_corner` and 3 wall pieces and the cursor returns to the position it had before the initial wall piece was added.
8. **Piece list (end to end).** For world seed 0, chunk (2, 0) the first seven pieces of section 11.1 are reproduced. The totals, union box and sampled count range of 11.1 are not part of this check (computed with the superseded corner order; Open question 14).
9. **Selection rules.** The collection tables of 6.8 draw exactly the stated number of random values (a stairs name draws none; `1x2_se` draws one).
10. **Markers.** Applying section 7.1 to each template of section 10 creates 10 chests of loot table `chests/woodland_mansion`, 20 vindicators, 4 evokers and 4 groups of 1 to 3 allays; an unknown marker string does nothing.
11. **Foundation.** On a slope, for each column of the clip box whose lowest-layer block is non-air and inside a piece box, air and liquid below are replaced by cobblestone down to the first non-air non-liquid block or the world minimum.

---

## Open questions

1. **Region random for allays.** The allay group size uses the level accessor's `getRandom()`. In the decoration stage that is the `WorldGenRegion` random, `RandomState`'s `minecraft:worldgen_region_random` factory positioned at the centre chunk's world position (read: `WorldGenRegion` constructor). The exact position vector (the y component of `ChunkPos.getWorldPosition`) and whether the stream is shared by all consumers during one chunk step were not traced; the exact draw index of a given allay marker is therefore not specified.
2. **Single-column height.** `getFirstOccupiedHeight` evaluates a 1 by 1 density volume column (`iterateNoiseColumn`). Whether this equals the height of the chunk fill with its cell interpolation for every column was not verified; the bytecode path (final density, aquifer `computeSubstance`, default block, the `WORLD_SURFACE_WG` predicate) is the one in 10 section 8 and 9, but the numeric equivalence is (inferred).
3. **Marker position state.** For mob markers the position is set to air (flag 2) after the mob is added. The state of the block at a marker position before that (the structure block is never placed, so the block there is whatever was written before: terrain or an earlier piece) was not traced for every template.
4. **(closed)** `snapTo` placement is now stated in section 7.1. Evoker, vindicator and allay `finalizeSpawn` differences by difficulty are in 18 and 20.
5. **Template placement flags and block-state handling.** `placeInWorld(level, position, pivot, settings, random, 2)` is called as written; the per-block behaviour (flag 2 meaning, waterlogging, shape updates, block-state `rotate` and `mirror`, block entity NBT, structure void) is the template engine of the sibling parts and was not re-read here.
6. **Biome test at the stub.** The generic filter that validates the biome at the start position (`Structure.isValidBiome`) and the random-spread placement algorithm are in 36-1 (sections 4.3 and 5); only the numbers of the structure set are given here (1.1).
7. **Third floor extent.** `thirdFloorGrid` cells that remain 0 (house cells outside the third-floor plan) are not `isHouse`, so no pieces are emitted for them on floor 2; the roof pass for `thirdFloorGrid` uses the same rule. That the visible result is a smaller third storey was derived from the grids and is (inferred); no rendering was checked.
8. **Chest order inside a piece.** The order of `filterBlocks` results (template palette block order, assumed to be the order of the `blocks` list in the NBT) determines which chest receives which `nextLong()` in templates with two chests (`1x2_a1`, `1x2_b3`, `1x2_se1`); it is (inferred) from `StructureTemplate$Palette.blocks`, not read.
9. **Saved spelling of rotation and mirror.** `Rotation.LEGACY_CODEC` and `Mirror.LEGACY_CODEC` are built with `ExtraCodecs.legacyEnum`; the constant pool holds both spellings (NONE and none, CLOCKWISE_90 and clockwise_90, LEFT_RIGHT and left_right and so on), and which one is written for `Rot` and `Mi` was not determined. The `minecraft:` prefix of the piece id is also (inferred). This only matters for compatibility with saved vanilla worlds.
10. **Duplicate chest and entity creation across chunks.** `filterBlocks` clips markers to the chunk box, so each marker is handled once; mob creation does not check the box separately. That no marker can be handled twice (a marker belongs to one chunk) is derived from that clipping (inferred).
11. **Cell 4 (`TEST_ROOM`).** The value 4 is declared and treated as house by `isHouse` but is never written; the artifact's purpose for it was not found.
12. **`createMansion` no-op branches.** The bytecode of `createMansion` contains three conditions on `list.isEmpty()` whose bodies are empty (no effect on the result); they were read as no-ops.
13. **Loot content.** The four pools of `chests/woodland_mansion` are data and were not tabulated; only the pool count, entry counts and roll specs were read.
14. **Computed totals.** The totals of 11.1 and the sampled range in section 12 item 8 came from a reference script that used an outdated corner-trial order in `identifyRooms` (corrected in 5.4). They were not regenerated and are removed from the validation list; the grid, the first seven pieces and the hand-checked pieces are unaffected. Regenerate the totals, the union box and the floor-1 stairs-room codes from the corrected text before using them as test vectors.
