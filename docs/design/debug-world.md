# The debug world type

Status: design record for the operator addition "debug world" (specs/002-client-polish/plan.md, section "Operator
addition: debug world"; contracts/core-host-delta.md, `CS-WORLD-TYPE`). Written by us from the documents cited below
(24, 04, 06, 10, 13, 33, WT): it is our own layout, it reads no vanilla artifact, and it holds no Mojang artifact content. Section references:
"24" is docs/protocol/24-block-registry-*.md, "04 §5" is docs/protocol/04-registry-sync.md section 5, "06 §5" is
docs/protocol/06-chunk-format.md section 5, "WT" is [world-types.md](world-types.md). It is a test tool, not a user
story, and it is not one of the "two world types" of spec FR-003 to FR-005.

Every number below is either a decision of this document (marked **Decision DW-n**) or computed from the cited document
with the formula shown. An implementer can compute the position of any state from the formulas alone.

## 1. What it is

The `debug` world type is a flat grid in which every block state of the standard block registry appears exactly once,
in state-id order, so that one walk through the world shows every state and a test can check every state against its
position.

| Property | Value |
|---|---|
| Key | `WorldType` = `debug` in `level.dat` (WT §2.1; the third accepted value). `CS-WORLD-TYPE` accepts `debug` |
| Visibility | Hidden. It is not listed by the create-world screen's type button cycle and not in the normal UI; it is chosen by holding Ctrl while clicking the type button (plan), or by `CS-WORLD-TYPE` in tests. It never becomes the default (WT §3.2 is unchanged) |
| Content set | The standard content set (WT §1): the standard registries, ids, recipes, tags and the generated packs. It therefore needs a valid generated directory exactly as a standard world does (WT Decision WT-17, WT §8.1) |
| Dimensions | One: `minecraft:overworld`, dimension type `minecraft:overworld`. The `extra-dimensions` setting is ignored (no nether, no end) |
| Generation | None beyond the layout of section 3: no terrain, no caves, no ores, no structures, no features, no mobs |
| Ticking | Nothing ticks (section 6) |

## 2. The totals

| Quantity | Value | Source |
|---|---|---|
| Blocks | 1286 (block ids 0 to 1285) | 24 part 1 section 2.3 and 18 open question 1; 24 part 8 section 10 (check V6) and section 11.1 (totals): 1286 registrations, 911 fields |
| Block states | 35723 (state ids 0 to 35722, contiguous with no gap) | 24 part 8 section 10 (V6) and section 11.1: highest state id 35722 (`firefly_bush`, block id 1285), "the sum of the state counts of all 1286 blocks" |
| States of the first 105 blocks | 575 (ids 0 to 574) | 24 part 1 section 17 item 1 |
| Direct (global) palette width of block states | `ceillog2(35723)` = 16 bits (2^15 = 32768 < 35723 <= 65536) | 06 §5.2 (palette kinds) and §5.3 (bits-per-entry thresholds: 9 or more bits is the global kind, packed at `ceillog2(number of block states)`) |

The grid has exactly one cell per state id, so it holds 35723 cells. The other ids a client needs (the
`minecraft:overworld` dimension type id, the biome id of `minecraft:plains`) come from the registry data the server
sends (04 §3, §5; document 46 gives the id rule of the static registries): the grid uses no id from them in its layout.

## 3. The layout: position as a function of the state id

**Decision DW-1 (the grid).** Cells are placed on a grid of **192 columns** along x, in rows along z, one cell every
**2 blocks** (one air block between neighbouring cells), at height **y = 70**, with the origin at block (0, 70, 0).
Reasons: 192 columns of spacing 2 span 384 blocks = exactly 24 chunks, so the grid is chunk-aligned and a chunk holds a
block of 8 by 8 consecutive columns and rows; 35723 / 192 = 186.05, so there are 187 rows, the last one partial.

Constants:

| Name | Value |
|---|---|
| `W` (grid width in cells) | 192 |
| `S` (spacing in blocks) | 2 |
| `Y0` (cell y level) | 70 |
| `X0`, `Z0` (origin) | 0, 0 |
| `N` (cells) | 35723 |
| Rows | `ceil(N / W)` = 187 (rows 0 to 185 full, row 186 holds 11 cells) |

For a state id `s` with 0 <= s < N:

```
col = s mod W
row = s div W
x   = X0 + S * col        (0 to 382)
y   = Y0                  (70)
z   = Z0 + S * row        (0 to 372)
```

Inverse: a block at (x, 70, z) with `x` and `z` both even, `0 <= x <= 382`, `0 <= z <= 372` holds the state
`s = (z / 2) * 192 + x / 2` when `s < 35723`; every other block of the grid area (an odd x or z, or `s >= 35723`, which
is columns 11 to 191 of row 186) is air. State 0 (`air`) is the cell at the origin: it is air, so the origin looks empty;
tests read the state, not the look.

**Chunk and section addressing.** The grid occupies chunks (cx, cz) with cx, cz from 0 to 23 (x 0 to 383, z 0 to 383;
the cell extents are x 0 to 382 and z 0 to 372, so chunk row 23 is partly empty). A chunk holds columns `8*cx` to
`8*cx + 7` and rows `8*cz` to `8*cz + 7`: 64 state ids per full chunk, `s = (8*cz + r) * 192 + 8*cx + c` for
`r, c` from 0 to 7. The level is the standard overworld (section 5), min y -64, so y = 70 is in section index 8
(block y 64 to 79) at local y 6; the floor (section 4) at y = 69 is in the same section at local y 5. Every other section
of the chunk is the single value `air`. A chunk section therefore has at most 64 cell states plus `air` plus the floor block
= 66 distinct values: palette bits `ceillog2(66)` = 7, the hash map kind of 06 §5.2 and §5.3 (5 to 8 bits; never the 16-bit global kind for
the generated chunk; the 16-bit width is the width the client allocates when it decodes a global palette, and tests
round-trip both kinds).

### 3.1 Worked examples

| State id `s` | col = s mod 192 | row = s div 192 | Position (x, y, z) | Remark |
|---|---|---|---|---|
| 0 (`air`) | 0 | 0 | (0, 70, 0) | first state; the origin |
| 1 | 1 | 0 | (2, 70, 0) | second cell of row 0 |
| 191 | 191 | 0 | (382, 70, 0) | last cell of row 0 (wrap point) |
| 192 | 0 | 1 | (0, 70, 2) | first cell of row 1: the row wraps, x returns to 0, z grows by 2 |
| 193 | 1 | 1 | (2, 70, 2) | |
| 1000 | 40 | 5 | (80, 70, 10) | 1000 = 5 * 192 + 40 |
| 35711 | 191 | 185 | (382, 70, 370) | last cell of the last full row (185 * 192 + 191) |
| 35712 | 0 | 186 | (0, 70, 372) | first cell of the last row (186 * 192 = 35712) |
| 35722 (`firefly_bush`, last state, block id 1285) | 10 | 186 | (20, 70, 372) | 35722 = 186 * 192 + 10; chunk (1, 23) |
| 35723 | n/a | n/a | none | past the last state: the block at (22, 70, 372) is air |

Chunk of the last state: x = 20 gives cx = 1 (20 div 16), z = 372 gives cz = 23 (372 div 16), local x 4, local z 4,
local y 6, section index 8.

## 4. The floor

**Decision DW-2 (floor).** A one-block-thick floor of `minecraft:stone` (state id 1) at **y = 69** under and around the
grid: every block column of the chunks (cx, cz) with cx and cz from -1 to 24 (x and z from -16 to 399) has stone at
y = 69. The cells at y = 70 sit on it, and the walkway of 16 blocks around the grid lets a player spawn and walk round it.
Below y = 69 and above y = 70 everything is `air`: no bedrock layer, no stone below. Outside those chunks nothing is
generated: a chunk request outside cx, cz in -1 to 24 is answered with an all-air chunk. Reason: a floor is the least
that lets a player stand; the layout of the cells is independent of it. Stone is also one of the cell states (it is
state 1, cell (2, 70, 0)): the floor is a block of the floor, not a cell, so a test reads only y = 70 for states.

## 5. Dimension, light, biome

| Item | Value | Source |
|---|---|---|
| Dimension (level) key | `minecraft:overworld` | WT §4 (standard) |
| Dimension type | `minecraft:overworld` (the standard entry of the dimension type registry): min y -64, height 384 (24 sections), logical height 384, sky light on, no ceiling, ambient light 0.0 | 10 §5 (dimension type `minecraft:overworld`) |
| Sea level | 63 (below the floor: no water exists) | 10 §5, 09 §3.2 |
| Biome | `minecraft:plains` in every biome cell of every section of every chunk: a single-value biome palette per section | 04 §3.2 (the registry holds `minecraft:plains`); 06 §5.2 and §5.3 (a single-value biome palette is bits byte 0) |
| Light | The shared light engine of document 32 applied to the generated chunk, unchanged: sky light 15 above the floor (nothing is above y = 70 except air), so the cells are lit by the sky; block light only from emitting states (torch, lava, glowstone, and so on) as 32 computes it. No special-casing: a test that needs the light data reads it as the engine gives it | 32 |
| Heightmaps | The standard heightmaps of 06 §3.1, computed from the chunk's blocks as for any chunk (y = 70 or 69) | 06 §3.1 |
| Weather and time | The world is created with the rules `advance_time` false and `advance_weather` false, the clock at time of day 6000 and clear weather (**Decision DW-3**: a fixed noon so that every state is seen in daylight; the rules are those of 33 §8) | 33 |
| Spawn | **Decision DW-4.** World spawn block (0, 70, -3), spawn position (0.5, 70.0, -2.5), yaw 0.0 (looks along +z, toward row 0 of the grid: 13 §1 gives movement as `(-sin(yaw), 0, cos(yaw))`), pitch 0.0. It stands on the floor, on the walkway, three blocks before the first cell. The Set Default Spawn Position packet carries that block and yaw (09 §3.2) |
| Default game mode | Creative (so that the whole grid can be flown over, 13 §1.4); the `gamemode` command changes it |

## 6. Nothing ticks, nothing generates

- **Block placement is direct.** The generator writes state ids into chunk sections; it does not call the placement rules
  of 29, so it sends no neighbour update, no shape update, no support check. A state that normally needs support
  (a torch, a door, a sapling, a pressure plate) stays as written.
- **No ticks.** `random_tick_speed` is 0 and `spawn_mobs` is false in the created world rules (33 §8; tick order 33 §2). No scheduled
  block or fluid tick is queued for a generated block (a water or lava state is a still block of that state and does not
  flow). Cells hold no block entity data (`level.dat` records none and no chunk stores any, 31): a state of a
  block that has a block entity is stored as the block state alone, and the client draws it as 12 draws a block whose entity
  data is absent (open question 1).
- **No generation.** There is no terrain, no feature and no structure stage (10, 11, 35, 36 are not run); the chunk is
  the function of sections 3 and 4 alone. The same chunk is produced every time, with no seed (the stored `Seed` is
  written, as WT §2.1 requires for a uniform schema, and never read).
- **No mobs, no items.** Nothing spawns; the player's inventory is empty (the standard start, README decision 6).

## 7. What a test can rely on

1. Every state id 0 to 35722 appears once, at the position of section 3, and no cell exists for 35723 and above.
2. The block of the cell of id `s` has the block id and the property values that 24 gives for state `s` (the state ranges of
   24 are contiguous).
3. A chunk of the grid, written with the 7-bit hash map palette and read back, and written with the 16-bit global
   palette and read back, gives the same 4096 states (06 §5).
4. The client mesher, given the generated vanilla resource pack, draws every cell without the missing-texture look
   (plan; real input, the test fails loudly when the packs are absent).

## Open questions

1. **Block entities.** Whether the debug world should create an empty block entity for each state of a block that has one
   (chests, signs, beds, banners, skulls, shulker boxes, and so on) so that the client draws it fully, or none (this
   document says none). The look of a block without its entity is the client's concern (12); the choice does not affect
   any position of section 3.
2. **Height of the cells.** y = 70 was chosen so the cells stand one block above the floor at y = 69 and in a section
   that holds both; no other document constrains it.
