# 36-3 Structures, part 3: jigsaw assembly

| Item | Value |
|---|---|
| Covers | The jigsaw assembly engine: the structure type `minecraft:jigsaw` (`JigsawStructure`) and its parameters, the start of the assembly (`JigsawPlacement.addPieces`), the expansion of a piece (`JigsawPlacement$Placer.tryPlacingChildren`), the queue that orders it, template pools (`StructureTemplatePool`) with weights and fallbacks, the pool element types (`single_pool_element`, `legacy_single_pool_element`, `list_pool_element`, `feature_pool_element`, `empty_pool_element`), projections (`rigid`, `terrain_matching`), jigsaw block attributes (name, target, pool, joint, final state, placement priority, selection priority) and the attach rule, maximum depth, maximum distance from the centre, dimension padding, pool aliases (`direct`, `random`, `random_group`, `PoolAliasLookup`), the expansion hack, start height and heightmap projection, liquid settings, ground-level delta, element rotation, the bounding-box collision volumes, junctions, the piece class (`PoolElementStructurePiece`) with its NBT, the two other entry points (`/place jigsaw`, the jigsaw block's Generate button) and the hooks to terrain adaptation (the beardifier). |
| Does not cover | Data rows (the 245 template pool files, the 28 `minecraft:jigsaw` structure files, the 1511 structure NBT files): the extraction tool copies them (22, 23); they are cited only as examples and for the validation counts. The structure framework (structure start, structure sets and placement, the `StructureStart` checks, `terrain_adaptation` and the beardifier density math, spawn overrides): 36-1 sections 5 to 10. The template format, `placeInWorld`, block processors, entity placement: 36-2 (only the facts the assembler depends on are stated here). The per-family structure parameters and the pieces that are not jigsaw pieces (mineshaft, stronghold, monument, mansion, temples, ruins, shipwrecks, End city, fortress): 36-4 to 36-10. The jigsaw block entity fields, packets and screen: 31-6 section 8 (the attach rule is repeated here with the artifact's argument order). Heightmaps and column queries: 10 section 4.4, 37-2 section 6.5. Random sources, `WorldgenRandom`, `setLargeFeatureSeed`: 10 section 2, 11 section 4. |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md)) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) of the classes named in each section and of the JSON and NBT under `data/minecraft/` in the jar, with no execution of the artifact. Examples marked "(computed)" were produced by applying this document's text (and, for the random draws, the generator of 10 section 2.6) with a throwaway script written for the round; they are not read from the artifact. Structure NBT files were decoded with a throwaway reader to list jigsaw blocks. |
| Round | RS20 (GAP-12b, GAP-18 structures of [../design/README.md](../design/README.md)) |
| Operator decisions | Standard Minecraft content is the target; a tool extracts the data pack and this document specifies the engine (ticket CC-0001, Decisions "World scope", "Vanilla assets and data"). Code-defined content is specified completely. |

Class names in backticks say where a fact was read; they are not the design. "(inferred)" marks a deduction and "(recalled, not verified)" a statement not read in this round; both are listed in the Open questions. Section references such as "10 section 2.6" are to documents of this directory; "36-N section M" names a sibling part of this document (36-1 model, placement and starts; 36-2 templates and processors; 36-4 to 36-10 per-family structures). Int arithmetic is 32-bit two's complement; integer division truncates toward zero (this matters for negative coordinates, see 2.2). A block position is `(x, y, z)`; a bounding box is `(minX, minY, minZ, maxX, maxY, maxZ)` with all six bounds inclusive, so a box of one block has equal minimum and maximum.

---

## 1. Overview

A jigsaw structure is built in two phases.

1. **Assembly** (this document, at structure start time, no world access except heightmap and biome queries): starting from a start pool, a start piece is chosen and positioned; then pieces are attached to the open jigsaw blocks of the pieces already placed, breadth first with priorities, until the depth limit or until nothing fits. The result is a list of `PoolElementStructurePiece` objects (position, rotation, bounding box, element, junction list). No block has been written.
2. **Placement** (later, per chunk, by the structure framework, 36-1 sections 7 and 8): each piece writes its element's blocks into the chunks that intersect its bounding box (`PoolElementStructurePiece.postProcess`, section 14). The element decides what is written (a template through the template engine of 36-2 section 5, a feature, a list of elements, nothing).

Between the phases the pieces' bounding boxes and junctions feed terrain adaptation (the beardifier changes the density of the terrain next to the structure, section 16).

Entry points of the assembler (read by finding every class that references `JigsawPlacement`): `JigsawStructure.findGenerationPoint` (world generation), `JigsawBlockEntity.generate` (the Generate button of the jigsaw block screen, 31-6 section 8.2) and `PlaceCommand.placeJigsaw` (`/place jigsaw`, 16). Section 15 gives the second and third.

Terms used below.

| Term | Meaning |
|---|---|
| start piece | the first piece, picked from the start pool |
| parent, child | a piece whose open jigsaw is being served, and the piece attached to it |
| jigsaw block | a block of the template carrying a name, a target, a pool, a joint, a final state and two priorities (section 4) |
| front, top | the two directions of a jigsaw block's orientation: the front points at the cell the neighbour piece's jigsaw will occupy, the top is the neighbour's "up" |
| target cell | the cell next to a parent's jigsaw block in its front direction |
| free volume | the set of block cells in which new pieces may still be placed (section 13) |
| depth | the number of attachment steps from the start piece (start piece 0). With `size` 0 no piece is produced at all and the structure start is discarded (9.7 step 1) |
| ground level | for a rigid piece, `bounding box minY + groundLevelDelta` (section 12) |

---

## 2. Conventions the algorithm relies on

### 2.1 Rotation, orientation and template transforms

`Rotation` has four values in this order (ordinals 0 to 3): `NONE`, `CLOCKWISE_90`, `CLOCKWISE_180`, `COUNTERCLOCKWISE_90`. Block positions inside a template are rotated about the origin `(0, 0, 0)` (a jigsaw element always uses the default pivot) by `StructureTemplate.transform`, with `y` unchanged:

| Rotation | `(x, z)` becomes |
|---|---|
| `NONE` | `(x, z)` |
| `CLOCKWISE_90` | `(-z, x)` |
| `CLOCKWISE_180` | `(-x, -z)` |
| `COUNTERCLOCKWISE_90` | `(z, -x)` |

(read: the three non-trivial branches of `StructureTemplate.transform` with the pivot at zero; the mapping from the branch to the enum constant was read in `StructureTemplate$1`.) Seen from above with `+x` east and `+z` south, `CLOCKWISE_90` turns north into east into south into west into north.

The jigsaw block's `orientation` property is a `FrontAndTop` with 12 values, each a (front, top) pair of directions (serialized names): `down_east`, `down_north`, `down_south`, `down_west` (front down, top as named), `up_east`, `up_north`, `up_south`, `up_west` (front up), `west_up`, `east_up`, `north_up`, `south_up` (front horizontal, top up). `JigsawBlock.rotate(state, rotation)` replaces the orientation by the rotated orientation (`OctahedralGroup.rotate(FrontAndTop)`): a vertical direction is unchanged, a horizontal direction is turned as in the table above (read: `Rotation.CLOCKWISE_90` is `OctahedralGroup.ROT_90_Y_NEG`, an axis permutation with one sign inversion that turns horizontal directions as in the table and leaves up and down fixed). Example: `north_up` rotated `CLOCKWISE_90` is `east_up`; `up_north` rotated `CLOCKWISE_180` is `up_south`.

The bounding box of a template of size `(sx, sy, sz)` at position `P` with rotation `R` (`StructureTemplate.getBoundingBox`, pivot zero, no mirror): take the corner `(0, 0, 0)` and the corner `(sx-1, sy-1, sz-1)`, transform both as above, build the box from the two points (min and max of each coordinate), and move it by `P`. The rotated size swaps `sx` and `sz` for the two 90-degree rotations.

### 2.2 Integers and shapes

- The centre of a piece's box on one axis is `(max + min) / 2` with Java integer division, which truncates toward zero. For a negative sum this is one more than the floor: `(-49) / 2 = -24`, not `-25`.
- `BoundingBox.getYSpan()` is `maxY - minY + 1`.
- `BoundingBox.encapsulate(pos)` **mutates** the box in place (each bound becomes the min or max with the position) and returns it. `moved(dx, dy, dz)` returns a new box; `move` mutates.
- `AABB.of(box)` is the real-valued box `(minX, minY, minZ, maxX+1, maxY+1, maxZ+1)`; `deflate(0.25)` shrinks each side by `0.25`. The collision test of section 13 uses these with voxel-shape set operations; it is equivalent to a test on whole block cells (13.1).

### 2.3 Shuffles and weighted picks

- `Util.shuffle(list, random)`: for `i` from the list size down to 2: `j = random.nextInt(i)`; swap the elements at index `i-1` and `j`. It draws `size - 1` values for a list of `size >= 1` (none for an empty or one-element list). `Util.shuffledCopy` shuffles a copy; `Rotation.getShuffled` is `shuffledCopy` of the four rotations in the order of 2.1.
- `Util.getRandom(array, random)`: element at index `random.nextInt(length)`; `Rotation.getRandom` is this on the four rotations.
- `WeightedList.getRandomOrThrow(random)` (aliases, section 7): `r = random.nextInt(totalWeight)`, then walk the entries in list order subtracting each weight; the first entry for which the running value becomes negative is the result. A weight list is non-empty by codec.
- `nextInt(bound)` of the structure context's random: the context's `WorldgenRandom` wraps a **legacy** (Java LCG) source, so `nextInt` is the legacy rule of 10 section 2.6 as wrapped by `WorldgenRandom` (11 section 4). Pool aliases use their own legacy-generator source (7.2).

### 2.4 Constants

| Constant | Value | Where |
|---|---|---|
| `MAX_TOTAL_STRUCTURE_RANGE` | 128 | `JigsawStructure` |
| `MIN_DEPTH`, `MAX_DEPTH` (field `size`) | 0, 20 | `JigsawStructure` |
| terrain adaptation extra range | 12 (any `terrain_adaptation` except `none`), 0 for `none` | `JigsawStructure.verifyRange` |
| default `max_distance_from_center` vertical | `DimensionType.Y_SIZE` = 4064 (computed from `BlockPos.PACKED_Y_LENGTH` = 12: `(1 << 12) - 32`) | `JigsawStructure$MaxDistance` |
| `DimensionType.MIN_Y`, `MAX_Y` | -2032, 2031 (computed: `MAX_Y = Y_SIZE / 2 - 1`, `MIN_Y = MAX_Y - Y_SIZE + 1`) | `DimensionType` |
| collision deflation | 0.25 block per side | `JigsawPlacement$Placer` |
| expansion-hack height limit | candidate element height at most 16 | `JigsawPlacement$Placer` |
| jigsaw block default `final_state` | `minecraft:air` | `JigsawBlockEntity` |
| `/place jigsaw` and Generate depth | 1 to 20 | `PlaceCommand` |
| Generate: maximum distance | horizontal 128 and vertical 128 (a single integer 128 gives both) | `JigsawPlacement.generateJigsaw` |
| pool element weight | 1 to 150 | `StructureTemplatePool` codec |

---

## 3. Data the engine interprets

The files are data (extracted by the tool); this section is the schema and the meaning of every field that the engine reads.

### 3.1 `worldgen/structure/*.json` with `"type": "minecraft:jigsaw"`

The common structure fields (`biomes`, `step`, `terrain_adaptation`, `spawn_overrides`) belong to 36-1; the jigsaw type adds:

| Field | Type, range | Default | Meaning |
|---|---|---|---|
| `start_pool` | template pool reference (registry key or inline) | required | pool of the start piece |
| `start_jigsaw_name` | identifier | absent | when present, the start piece is positioned so that its jigsaw block of this name sits exactly on the start position (9.3) |
| `size` | int 0 to 20 | required | maximum depth (`maxDepth`): pieces are attached up to this many steps from the start piece; `0` gives no structure at all: the callback returns before any piece is added to the builder, so the start is invalid (9.7 step 1); `1` gives the start piece plus its depth-1 children |
| `start_height` | height provider | required | the Y of the start position, sampled once with the context random (8.2) |
| `use_expansion_hack` | bool | required | enables the expansion of candidate boxes (10.4) |
| `project_start_to_heightmap` | `Heightmap$Types` name (serialized names `WORLD_SURFACE_WG`, `WORLD_SURFACE`, `OCEAN_FLOOR_WG`, `OCEAN_FLOOR`, `MOTION_BLOCKING`, `MOTION_BLOCKING_NO_LEAVES`, upper case as in the data files) | absent | when present the start piece is moved onto that heightmap (9.4) |
| `max_distance_from_center` | int 1 to 128, or an object `{horizontal: int 1 to 128, vertical: int 1 to 4064 (default 4064)}` | required | limits of the free volume (13.2) |
| `pool_aliases` | list of alias bindings | empty | section 7 |
| `dimension_padding` | int >= 0, or `{bottom, top}` (both int >= 0, default 0, read leniently) | 0 | minimum clearance of the start piece from the dimension's vertical limits (9.5) |
| `liquid_settings` | `ignore_waterlogging` or `apply_waterlogging` | `apply_waterlogging` | given to every piece; elements may override (5.2); effect: 36-2 |

Validation at load (`JigsawStructure.verifyRange`): let `extra` be 0 when `terrain_adaptation` is `none` and 12 otherwise; if `max_distance_from_center.horizontal + extra > 128` the structure is rejected with the message "Horizontal structure size including terrain adaptation must not exceed 128". The structure's type id is `jigsaw` (`StructureType.JIGSAW`).

### 3.2 `worldgen/template_pool/*.json`

An object with `elements`: a list (possibly empty) of `{element: <pool element>, weight: int 1..150}` and `fallback`: a pool reference (required; the value `minecraft:empty` means "no fallback"). The pool named `minecraft:empty` exists as a file with no elements and fallback `minecraft:empty`.

### 3.3 Pool element JSON

Every element is an object whose `element_type` selects the codec (registered names, shown with the `minecraft:` prefix used in data):

| `element_type` | Fields | Class |
|---|---|---|
| `minecraft:single_pool_element` | `location` (identifier of a structure NBT, without `.nbt`), `processors` (a processor list reference or an inline `{processors: [...]}`), `projection`, `override_liquid_settings` (optional) | `SinglePoolElement` |
| `minecraft:legacy_single_pool_element` | same four fields | `LegacySinglePoolElement` |
| `minecraft:list_pool_element` | `elements` (list of pool elements), `projection` | `ListPoolElement` |
| `minecraft:feature_pool_element` | `feature` (placed feature reference), `projection` | `FeaturePoolElement` |
| `minecraft:empty_pool_element` | none | `EmptyPoolElement` (a single shared instance) |

`projection` is `rigid` or `terrain_matching` (`StructureTemplatePool$Projection`, serialized names). A `location` that cannot be loaded as a template is the template engine's concern (36-2).

### 3.4 Pool alias bindings

`{type: minecraft:direct, alias: <pool key>, target: <pool key>}`; `{type: minecraft:random, alias: <pool key>, targets: <non-empty weighted list of pool keys>}` (each entry `{data: key, weight: int}`); `{type: minecraft:random_group, groups: <non-empty weighted list of lists of bindings>}`. Section 7 gives the semantics.

### 3.5 Jigsaw blocks inside a template

Each jigsaw block of a structure NBT has block entity data (`JigsawBlockInfo.parse` reads it; a jigsaw block without block entity data aborts the load with an exception) with the keys below; missing or invalid keys take the default. The assembler's record `JigsawBlockInfo` has eight components (position, state, joint type, name, pool, target, placement priority, selection priority) and **no final state**: `parse` reads `joint` (through `StructureTemplate.getJointType`, default `getDefaultJointType`), `name`, `pool`, `target`, `placement_priority` and `selection_priority`. `final_state` is read separately, at write time, by `JigsawReplacementProcessor` (`getStringOr("final_state", "minecraft:air")`, 5.6), and is listed here only because it is a key of the same block entity data:

| Key | Default | Meaning |
|---|---|---|
| `name` | `minecraft:empty` | identity of this jigsaw as seen by an attaching parent |
| `target` | `minecraft:empty` | the `name` a child jigsaw must have to attach to this one |
| `pool` | `minecraft:empty` | pool that supplies the child pieces for this jigsaw |
| `joint` | `aligned` when the block's front is horizontal, else `rollable` (`getDefaultJointType`) | `rollable` or `aligned` |
| `final_state` | `minecraft:air` | block state that replaces the jigsaw block when the piece is written (5.6) |
| `placement_priority` | 0 | order in which the child attached here is expanded (section 11) |
| `selection_priority` | 0 | order in which this jigsaw is tried among its siblings (4.3) |

The block state's `orientation` is the `FrontAndTop` of 2.1. The saved format of these keys is 31-6 section 8.1.

---

## 4. Jigsaw blocks: matching and ordering

### 4.1 The attach rule

`JigsawBlock.canAttach(a, b)` with `a` the parent's jigsaw and `b` the candidate child's jigsaw is true iff all three hold:

1. `front(a)` is the opposite direction of `front(b)`;
2. `joint(a)` is `rollable`, or `top(a) == top(b)`;
3. `name(b)` is absent (null), or `target(a)` equals `name(b)` (identifier equality; `minecraft:empty` is an ordinary identifier, so a jigsaw with target `minecraft:empty` attaches to child jigsaws named `minecraft:empty`).

Only the **parent's** joint matters: a child's own joint is never consulted when it is the second argument. `aligned` means the two tops must agree (the child cannot be turned about the connection axis); `rollable` accepts any top. For vertical connections the tops are horizontal directions, so an `aligned` vertical jigsaw (`up_north` aligned) only accepts a child whose top is also north.

The synthetic jigsaw of a feature element (5.5) has a null name, so it always passes rule 3.

### 4.2 Where a jigsaw lands

For a piece at position `P` with rotation `R`, the world position of a template jigsaw at template position `q` is `rotate(q, R) + P`, and its orientation is the orientation rotated by `R` (2.1). In a candidate evaluation the child element is rotated at position `(0, 0, 0)` (`getShuffledJigsawBlocks(manager, ZERO, rotation, random)`); the real position is applied afterwards (10.3).

### 4.3 Order of a piece's jigsaws

`SinglePoolElement.getShuffledJigsawBlocks(manager, pos, rotation, random)`:

1. take the template's jigsaw list: the jigsaw blocks of the template's palette in the order of the block list (`Palette.jigsaws()`); the palette is chosen with `getRandomPalette(palettes, pos)`, which seeds its own generator from `pos` and does not touch the assembler's random (every template in the jar that holds jigsaw blocks has exactly one palette; the 20 multi-palette templates, all shipwrecks, have none);
2. transform each (position and orientation) as in 4.2;
3. shuffle the list with the context random (2.3);
4. stable-sort by `selection_priority`, highest first. Equal priorities keep their shuffled order.

`JigsawPlacement.getRandomNamedJigsaw` (9.3 step 1) is named "random" but takes the **first** jigsaw of this already shuffled and sorted list whose `name` matches; it makes no draw of its own, so the only draws are the `n-1` of the shuffle.

The block list of a template is sorted when it is loaded: blocks that carry NBT are kept in a separate group, and the final order is "full-cube blocks without NBT, then the other blocks without NBT, then the blocks with NBT", each group sorted by `y`, then `x`, then `z` (`StructureTemplate.buildInfoList`; 36-2 section 1.3). A jigsaw block always has NBT, so jigsaws appear in `(y, x, z)` ascending order before the shuffle. Because the shuffle draws `n-1` values for `n` jigsaws, the number of jigsaw blocks in a template changes the random sequence for everything after it.

A `ListPoolElement` returns the jigsaws of its **first** sub-element. An `EmptyPoolElement` returns an empty list. A `FeaturePoolElement` returns one synthetic jigsaw (5.5), with no shuffle draw.

### 4.4 Data profile of the jar (for validation)

Across the 1511 structure NBT files, 1291 contain jigsaw blocks (4272 jigsaw blocks in total): 2427 `rollable`, 1845 `aligned`; orientations: `up_north` 879, `west_up` 850, `east_up` 764, `north_up` 574, `south_up` 504, `up_west` 154, `up_east` 141, `down_south` 137, `up_south` 86, `down_west` 75, `down_north` 72, `down_east` 36. `placement_priority` is nonzero on 50 blocks (44 with 1, 5 with 2, 1 with 3) and `selection_priority` on 37 (34 with 1, 3 with 2); all nonzero priorities are in `trial_chambers/*` templates. The most common `final_state` values are `minecraft:structure_void` (1158) and `minecraft:air` (715); 72 distinct values occur.

---

## 5. Pool elements

All elements share (`StructurePoolElement`):

| Member | Meaning |
|---|---|
| `projection` | `rigid` or `terrain_matching` (from the JSON; mutable through `setProjection`) |
| `getSize(manager, rotation)` | size of the element's box at that rotation |
| `getShuffledJigsawBlocks(manager, pos, rotation, random)` | 4.3 |
| `getBoundingBox(manager, pos, rotation)` | the element's box when placed at `pos` |
| `place(...)` | writes the element (section 14) |
| `getGroundLevelDelta()` | 1 for every element type (no subclass overrides it); stored per piece (section 12) |
| `handleDataMarker(...)` | does nothing by default; a hook for subclasses used by per-structure code (36-4 to 36-10) |

### 5.1 `single_pool_element`

- Template: the structure NBT named by `location`, loaded through the template manager (36-2).
- Box: the template box of 2.1 with the element's rotation.
- Jigsaws: 4.3.
- Placement settings (`SinglePoolElement.getSettings(rotation, box, liquidSettings, keepJigsaws)`): bounding-box limit = the box handed to `place` (the chunk's write box, section 14.3), rotation, `knownShape` true, `ignoreEntities` false, `finalizeEntities` true, liquid settings = `override_liquid_settings` if present else the piece's, and the processors in this order: (1) `BlockIgnoreProcessor.STRUCTURE_BLOCK` (drops blocks of the block `structure_block`); (2) unless `keepJigsaws`, `JigsawReplacementProcessor` (5.6); (3) the element's processor list in list order; (4) the projection's processors (empty for `rigid`; for `terrain_matching` one `GravityProcessor` with heightmap `WORLD_SURFACE_WG` and offset `-1`, 12.4).
- Writing: `StructureTemplate.placeInWorld(level, position, pivot, settings, random, 18)` (flag value 18; meaning in 36-2 section 5); when it succeeds, the template's `structure_block` blocks of mode `data` are processed through the same processors and handed to `handleDataMarker` (a no-op for pool elements; per-structure subclasses use it).

### 5.2 `legacy_single_pool_element`

Identical to 5.1 except for the processor list: the `STRUCTURE_BLOCK` ignore processor is removed (`popProcessor`) and `BlockIgnoreProcessor.STRUCTURE_AND_AIR` (ignores `structure_block` **and** `air`) is appended at the **end** of the list, after the element's processors and the projection's. Consequence: in a legacy element the air blocks of the template do not overwrite existing blocks, and a jigsaw block whose `final_state` is `minecraft:air` leaves the terrain in place; in a `single_pool_element` they are written as air. The data uses the legacy type for 1665 of the 2287 element objects of the pool files and the plain type for 531.

### 5.3 `list_pool_element`

- Holds a non-empty list of elements (an empty list is rejected at construction, "Elements are empty").
- The list's projection is **pushed onto every sub-element** at construction and whenever `setProjection` is called, replacing whatever the sub-elements had.
- Size: the component-wise maximum of the sub-elements' sizes.
- Box: the smallest box containing the boxes of all sub-elements except `EmptyPoolElement` (an exception if none remain).
- Jigsaws: those of the first sub-element (4.3).
- `place`: place the sub-elements in list order at the same position and rotation; stop and return false at the first one that fails.

### 5.4 `empty_pool_element`

The single shared instance `EmptyPoolElement.INSTANCE`, projection `terrain_matching`, size zero, no jigsaws, `place` returns true and writes nothing. It is the element for "place nothing here": the assembler stops looking at further candidates for a jigsaw when it draws it (10.2 step 4). Asking it for a bounding box is an error; every caller filters it out first.

### 5.5 `feature_pool_element`

- Holds a placed feature reference.
- Size zero, so its box at position `P` is the single block `P` (`BoundingBox(P, P + size)` with a zero size). The rotation is ignored.
- Jigsaws: exactly one synthetic jigsaw at the **given** position: orientation `down_south` (front down, top south), joint `rollable`, name null, pool `minecraft:empty`, target `minecraft:empty`, both priorities 0. Because its front is down, it attaches only to a parent jigsaw whose front is up, and because its name is null it attaches whatever the parent's target is.
- `place`: `PlacedFeature.place(level, generator, random, position)` with the piece's position (the target cell moved by the vertical correction of 10.3). The bounding box passed to `place` is ignored by the feature (feature placement engine: 35-1).

### 5.6 Jigsaw replacement (`JigsawReplacementProcessor`)

For each block of the template: if it is not a `jigsaw` block it is unchanged (a debug constant that keeps jigsaw blocks exists and is off in a release). A jigsaw block with no block entity data is kept and a warning is logged. Otherwise the text of `final_state` (default `minecraft:air`) is parsed as a block state (`BlockStateParser.parseForBlock(lookup, text, allowNbt)`; the third argument is stored in the parser's `allowNbt` field and is true here, so a trailing `{...}` NBT part is accepted by the parser and then discarded, because the replacement carries no NBT; 36-2 section 9.6); a parse error logs an error and **drops** the block (result null); the state `minecraft:structure_void` also drops the block (nothing is written there); any other state replaces the jigsaw with that state and **no** block entity data. The parsed state is then rotated and mirrored by `placeInWorld` like any template state (36-2 sections 5 and 9.6), so a `final_state` with a facing keeps its relation to the piece. In `rigid` elements this is how the connection cell is finished (for example `minecraft:dirt_path`, `minecraft:grass_block`, 72 distinct values in the jar).

---

## 6. Template pools

`StructureTemplatePool` holds the raw list of `(element, weight)` pairs, the expanded list `templates`, the fallback pool and a cached `maxSize`.

- **Expanded list:** for each raw pair in order, the element is appended `weight` times. The list of a pool with weights `[2, 1]` over elements `A`, `B` is `[A, A, B]`.
- `size()`: the length of the expanded list. A pool of size 0 is "empty".
- `getRandomTemplate(random)`: `EmptyPoolElement.INSTANCE` when the expanded list is empty (no draw), else the element at index `random.nextInt(size)`.
- `getShuffledTemplates(random)`: a shuffled copy of the whole expanded list (2.3), so duplicates stay duplicated and a heavier element is likelier to come first.
- `getMaxSize(manager)`: the maximum, over the non-empty elements of the expanded list, of `getBoundingBox(manager, (0,0,0), NONE).getYSpan()`, or 0 when there is none; computed once and cached (used by the expansion hack, 10.4). For a list element the box is the union of its non-empty sub-elements; for a feature element the Y span is 1.
- `getFallback()`: the fallback pool (a registry holder; the pool named `minecraft:empty` when none).

A pool with a weight-150 entry and a weight-1 entry therefore has a 151-element expanded list. The 245 pool files hold 2281 top-level entries with these weights (entries per weight): 1 (1691), 2 (326), 3 (73), 4 (103), 5 (10), 6 (12), 7 (18), 8 (2), 9 (1), 10 (19), 11 (1), 22 (1), 49 (3), 50 (6), 98 (2), 100 (2), 150 (11). The element objects, counting the 6 inside the three list elements, number 2287.

The jar's fallbacks: 223 of the 245 pools have fallback `minecraft:empty`; the others name a "terminators" pool (villages, 20 pools) or `trial_chambers/hallway/fallback` (2 pools).

---

## 7. Pool aliases

An alias lets one jigsaw's pool name be redirected, per structure start, to another pool. The same template can then draw different content in different starts.

### 7.1 Bindings

| Type | `forEachResolved(random, sink)` |
|---|---|
| `direct` | `sink(alias, target)` (no draw) |
| `random` | `sink(alias, targets.getRandomOrThrow(random))` (one `nextInt(totalWeight)`, 2.3) |
| `random_group` | pick one group with `groups.getRandomOrThrow(random)` (one draw), then for each binding of the group in list order call its `forEachResolved(random, sink)` with the same random (groups may nest) |

### 7.2 The lookup

`PoolAliasLookup.create(bindings, pos, seed)`:

1. if `bindings` is empty, the result is `PoolAliasLookup.EMPTY`, which maps every key to itself;
2. otherwise `random = positional(seed).at(pos)`, where `positional(seed)` is `RandomSource.create(seed).forkPositional()` and **`RandomSource.create(long)` creates the legacy generator** (`LegacyRandomSource`, 10 section 2.6): the factory seed is the first `nextLong()` of that generator and `at(pos)` is a new legacy generator seeded with `getSeed(x, y, z) xor factorySeed` (10 section 2.4 gives `getSeed`; section 2.6 gives the generator);
3. the bindings are resolved **in list order** into one map (alias key to target key) by calling `forEachResolved(random, putIntoMap)` for each; the map is built with an immutable-map builder whose `build()` rejects duplicate keys (a duplicate alias in one resolution throws);
4. `lookup(key)` is the map's value for `key`, or `key` itself when absent. The lookup is one step: a target is not looked up again.

`pos` and `seed` are the structure's start position `(chunkMinX, startY, chunkMinZ)` (8.2) and the world seed. Pool aliases never consume the assembler's random.

### 7.3 Where the lookup is applied

Only to pool keys read from jigsaw blocks and to the start pool: the start pool key (9.2 step 3), each parent's jigsaw `pool` key (10.2 step 3), and the same key for each candidate's own jigsaws inside the expansion hack (10.4). The `fallback` pool of a looked-up pool is not looked up again.

### 7.4 Worked draws (computed)

The trial chambers structure binds, in this order: one `random_group` of three groups (equal weights 1, total 3; each group is two `direct` bindings that redirect `.../contents/ranged` and `.../contents/slow_ranged` to the skeleton, stray or poison-skeleton pools), one `random` with three targets for `.../contents/melee` (zombie, husk, spider; weights 1) and one `random` with four targets for `.../contents/small_melee` (slime, cave_spider, silverfish, baby_zombie; weights 1). A resolution therefore makes exactly three draws, in the order `nextInt(3)` (group), `nextInt(3)` (melee), `nextInt(4)` (small melee).

| World seed | Start position | Draws (computed) | Result |
|---|---|---|---|
| 0 | `(0, -30, 0)` | 0, 0, 1 | skeleton group, zombie, cave_spider |
| 12345 | `(16, -30, -32)` | 2, 2, 3 | poison_skeleton group, spider, baby_zombie |

(Computed with the legacy generator of 10 section 2.6, `getSeed` of 10 section 2.4, the factory seed being the first `nextLong()`; `startY = -30` is an arbitrary value inside the structure's start-height range, not a drawn value.)

---

## 8. The structure type `JigsawStructure`

### 8.1 Fields

`startPool`, `startJigsawName` (optional), `maxDepth` (`size`), `startHeight`, `useExpansionHack`, `projectStartToHeightmap` (optional), `maxDistanceFromCenter` (`MaxDistance`), `poolAliases`, `dimensionPadding`, `liquidSettings` (3.1). Two convenience constructors used by code exist (heightmap-projected with maximum distance 80, or not projected with distance 80); they are not reachable from data.

### 8.2 `findGenerationPoint(context)`

1. `chunkPos = context.chunkPos`.
2. `startY = startHeight.sample(context.random, WorldGenerationContext(generator, heightAccessor))` (height providers: 11 section 4; the sample draws from the context random only if the provider type does; an `absolute` height draws nothing, `uniform` draws one value).
3. `pos = (chunkPos.minBlockX, startY, chunkPos.minBlockZ)`: the start position is the **south-west corner of the start chunk**, not its centre.
4. `aliases = PoolAliasLookup.create(poolAliases, pos, context.seed)` (7.2).
5. return `JigsawPlacement.addPieces(context, startPool, startJigsawName, maxDepth, pos, useExpansionHack, projectStartToHeightmap, maxDistanceFromCenter, aliases, dimensionPadding, liquidSettings)`: an optional generation stub (the stub's position and the piece-building callback), absent when the structure cannot start here.

`context.random` is a `WorldgenRandom` over a `LegacyRandomSource(0)` seeded by `setLargeFeatureSeed(worldSeed, chunkX, chunkZ)` (`Structure$GenerationContext.makeRandom`; 11 section 4 for the seeding formula). The same random serves the height sample and the whole assembly (section 17).

---

## 9. Starting the assembly: `JigsawPlacement.addPieces`

Inputs: context, start pool holder, optional start jigsaw name, maximum depth `D`, start position `pos`, expansion-hack flag, optional heightmap type `H`, `MaxDistance (hor, ver)`, alias lookup, padding `(bottom, top)`, liquid settings. Let `heightAccessor` be the context's (the dimension's `min_y` and `height`; `getMaxY()` is `min_y + height - 1`, the highest block Y).

### 9.1 Registry and random

`random = context.random`; `rotation = Rotation.getRandom(random)` (**first draw**: `nextInt(4)`).

### 9.2 Start element

1. Resolve the start pool: take the start pool holder's key, apply the alias lookup, look the result up in the template pool registry; if the aliased key is not in the registry use the holder's own pool.
2. `element = pool.getRandomTemplate(random)` (one draw `nextInt(size)` if the pool is non-empty).
3. If `element` is the empty element, return "no structure".

### 9.3 Start position of the piece

1. If `start_jigsaw_name` is present: take `element.getShuffledJigsawBlocks(manager, pos, rotation, random)` (4.3, positions already offset by `pos`), and use the **first** jigsaw (in that shuffled and priority-sorted order) whose `name` equals the given identifier; if none exists, log "No starting jigsaw ... found in start pool ..." and return "no structure". The anchor `A` is that jigsaw's world position.
2. Otherwise `A = pos`.
3. `offset = A - pos`; the piece's origin is `pos - offset`. So, before 9.4, the named jigsaw is on `pos`: if the jigsaw's position relative to the piece origin is `r` (rotated), the origin is `pos - r` and `offset = r`. Whether it stays there depends on 9.4: with a heightmap the anchor offset plays no part in the final Y, and without one the piece is dropped by its ground-level delta (see the worked example in 9.4).
4. `startPiece = PoolElementStructurePiece(manager, element, origin, element.groundLevelDelta, rotation, element.getBoundingBox(manager, origin, rotation), liquidSettings)`.

### 9.4 Vertical placement of the start piece

Let `box` be the start piece's box, `cx = (box.maxX + box.minX) / 2`, `cz = (box.maxZ + box.minZ) / 2` (integer division, 2.2).

1. If `H` is absent: `y = origin.y` (the piece origin, `pos.y - offset.y`, not `pos.y`).
2. Otherwise: if `context.couldStructureExistInColumn(cx, cz, minY, maxY)` is false return "no structure" (this tests whether any biome of the structure's valid set exists in the biome column at `(cx, cz)` from `minY` to `maxY`, iterating the quart cells of that column; `minY = heightAccessor.getMinY()`, `maxY = heightAccessor.getMaxY()`); else `y = pos.y + generator.getFirstFreeHeight(cx, cz, H, heightAccessor, randomState)`. `getFirstFreeHeight` is `getBaseHeight` (the Y above the highest block that satisfies the heightmap predicate; 37-2 section 6.5, 10 section 4.4).
3. `groundY = box.minY + startPiece.groundLevelDelta`.
4. `startPiece.move(0, y - groundY, 0)` (moves the piece position and its box).

After the move, `box.minY + groundLevelDelta == y`: the ground-level layer of the start piece sits at `y`. Two consequences:

- **With a heightmap** (`y = pos.y + firstFreeHeight`): the Y of the anchor offset does not enter `y`; the named jigsaw ends wherever the piece's ground layer puts it, not at `pos`.
- **Without a heightmap** (`y = origin.y`): the move is `y - (box.minY + groundLevelDelta)`, which equals `-groundLevelDelta` when `box.minY == origin.y` (a template whose lowest layer is at local Y 0). The piece is dropped by its ground-level delta, so the named jigsaw ends at `pos.y - groundLevelDelta`, while the stub Y (9.6) is still `y + offset.y = pos.y`.

Worked example (computed from the formulas; the ancient city: `start_jigsaw_name = minecraft:city_anchor`, start height absolute -27, no heightmap, so `pos.y = -27`). The start pool's `single_pool_element` elements have `groundLevelDelta = 1`. Let the anchor jigsaw sit at rotated local position `r = (rx, ry, rz)`. Then `origin = pos - r`, `origin.y = -27 - ry`; no heightmap so `y = origin.y`; the piece moves by `y - (box.minY + 1) = -1`; the final `box.minY = origin.y - 1 = -28 - ry`; the anchor jigsaw ends at Y `-27 - 1 = -28`; the stub position Y is `y + offset.y = (-27 - ry) + ry = -27`.

### 9.5 Dimension padding check

`isStartTooCloseToWorldHeightLimits(heightAccessor, padding, box)`: false when `padding` is the constant `DimensionPadding.ZERO` (**reference identity**: the default value and nothing decoded from data; a decoded `0` or `{bottom: 0, top: 0}` is a different object and is checked); otherwise true iff `box.minY < minY + padding.bottom` or `box.maxY > maxY - padding.top`. When true, log (debug) and return "no structure". This is evaluated after the vertical move of 9.4. (With the zero padding decoded from data the test still rejects a start piece that sticks out of the dimension.)

### 9.6 The stub

`stubY = y + offset.y` (the vertical offset of the start jigsaw from `pos`; 0 when no start jigsaw name is used). The result is a generation stub with position `(cx, stubY, cz)` and a callback that, given the structure's pieces builder, performs the expansion below. The stub's position is where the structure framework tests the biome (`isValidBiome` takes the noise biome at that position) and where it records the start (36-1).

### 9.7 The callback

1. `pieces = [startPiece]` (a local list). If `D <= 0` (the field `size` is 0) the callback **returns at once, before step 4**: nothing is added to the `StructurePiecesBuilder`, so the generated `PiecesContainer` is empty, `StructureStart.isValid()` (`!pieceContainer.isEmpty()`) is false and the start is discarded: no structure generates. (Read in the lambda `addPieces$2`: the start piece is put in the list, the `maxDepth > 0` test follows, and the copy of the list into the builder is the last step.) Size 0 therefore does not mean "start piece alone". No jar structure uses it (sizes are 2, 6, 7 and 20).
2. Free volume (13.2): the real box `(cx - hor, max(stubY - ver, minY + bottom), cz - hor)` to `(cx + hor + 1, min(stubY + ver + 1, maxY + 1 - top), cz + hor + 1)` (note `cx`, `cz` and `stubY` are those of 9.4 and 9.6), minus the start piece's box (`AABB.of`), as one shape in one mutable holder `F0`.
3. `tryPlacingChildren(startPiece, F0, depth 0)`; then repeatedly take the next entry from the priority queue (section 11) and call `tryPlacingChildren(entry.piece, entry.free, entry.depth)` until the queue is empty.
4. Every piece in `pieces`, in creation order (start piece first), is added to the builder.

---

## 10. Expanding a piece: `tryPlacingChildren(parent, free, depth)`

Inputs: the parent piece, a shared mutable free-volume holder `free`, the parent's depth, the expansion-hack flag, the height accessor, the random state, the alias lookup, the liquid settings. State of the call: `Y0 = parent.box.minY`, `parentRigid = (parent.element.projection == rigid)`, `ownFree` (a holder that starts unset and is shared by the interior jigsaws of this parent).

### 10.1 The loop over the parent's jigsaws

Take `parent.element.getShuffledJigsawBlocks(manager, parent.position, parent.rotation, random)` (4.3; **draws**). For each jigsaw `J` in that order, run 10.2. Let `f = front(J)`, `p = J.pos` (world), `t = p + f` (target cell), `rel = p.y - Y0`, and `surfaceY` = unset (reset for every jigsaw).

### 10.2 Serving one jigsaw `J`

1. `poolKey = aliases.lookup(J.pool)`. If the registry has no pool with that key, log "Empty or non-existent pool" and go to the next jigsaw.
2. If that pool's `size()` is 0 and the pool is not `minecraft:empty`, log and go to the next jigsaw. (A jigsaw whose pool is `minecraft:empty` passes silently but has no candidates.)
3. `fallback = pool.getFallback()`. If the fallback's `size()` is 0 and it is not `minecraft:empty`, log and go to the next jigsaw.
4. Select the free holder for this jigsaw: if the parent's box contains `t` (inclusive test), `F' = ownFree`, setting it on first use to the **parent's own box** (a shape equal to the parent's box, not reduced by anything); otherwise `F' = free` (the holder passed in).
5. Build the candidate list `L`: if `depth != maxDepth`, `pool.getShuffledTemplates(random)`; then always append `fallback.getShuffledTemplates(random)`. (So at the maximum depth only fallback elements are used. The pool is shuffled before the fallback, so the draw order is pool then fallback.)
6. `priority = J.placementPriority`.
7. For each candidate `C` in `L` in order: if `C` is the empty element, **stop the candidate loop for this jigsaw** (nothing is attached to `J`); otherwise try every rotation of `C` in the order of `Rotation.getShuffled(random)`:
   1. `jigsaws = C.getShuffledJigsawBlocks(manager, ZERO, rotation, random)` (**draws**), `box0 = C.getBoundingBox(manager, ZERO, rotation)`.
   2. `h` (expansion extent, 10.4).
   3. For each `K` in `jigsaws` in order: if `!canAttach(J, K)` skip; else run 10.3. If 10.3 places a piece, **stop everything for this jigsaw** and go to the next one (no further `K`, rotation or candidate is tried).

### 10.3 Attaching candidate `C` through its jigsaw `K`

Let `q = K.pos` (relative to `C` at the origin and the chosen rotation), `qy = q.y`.

1. Origin: `o = t - q`. `box = C.getBoundingBox(manager, o, rotation)`, `childRigid = (C.projection == rigid)`.
2. Vertical offset: `d = rel - qy + stepY(f)` where `stepY(f)` is the Y component of the direction `f` (+1 up, -1 down, 0 horizontal). `d` is how far the child's origin lies above the parent's box bottom, relative to a child whose jigsaw is at the same height.
3. Height `Yj` that the child's origin should have:
   - both `parentRigid` and `childRigid`: `Yj = Y0 + d`. (This equals `o.y`: pure geometric alignment, no vertical shift.)
   - otherwise: if `surfaceY` is unset, set `surfaceY = generator.getFirstFreeHeight(p.x, p.z, WORLD_SURFACE_WG, heightAccessor, randomState)` (the heightmap type is fixed to `WORLD_SURFACE_WG` here, whatever the structure's `project_start_to_heightmap`); `Yj = surfaceY - qy`. (The child's jigsaw cell is put at the first free height above the surface at the parent's jigsaw column.)
4. `dy = Yj - box.minY`; `box := box.moved(0, dy, 0)`; `childPos = o + (0, dy, 0)`.
5. Expansion: if `h > 0`, `k = max(h + 1, box.maxY - box.minY)` and the box is encapsulated with the point `(box.minX, box.minY + k, box.minZ)` (in place). The effect is `box.maxY := max(box.maxY, box.minY + h + 1)`.
6. Collision: let `limit = F'.value`. If the real box `AABB.of(box).deflate(0.25)` is **not entirely inside** `limit` (set difference "second minus first" non-empty), skip this `K` (13.1).
7. Reserve: `F'.value := limit` minus `AABB.of(box)` (the undeflated box).
8. Ground-level deltas: `gParent = parent.groundLevelDelta`; `gChild = gParent - d` if `childRigid`, else `C.groundLevelDelta` (which is 1).
9. Create `child = PoolElementStructurePiece(manager, C, childPos, gChild, rotation, box, liquidSettings)`.
10. Junction ground height `G`:
    - `parentRigid`: `G = Y0 + rel` (the Y of `J`);
    - else if `childRigid`: `G = Yj + qy`;
    - else: if `surfaceY` is unset compute it as in 3; `G = surfaceY + d / 2` (integer division toward zero).
11. Junctions (12.3): `parent.addJunction(JigsawJunction(t.x, G - rel + gParent, t.z, d, C.projection))` and `child.addJunction(JigsawJunction(p.x, G - qy + gChild, p.z, -d, parent.element.projection))`.
12. `pieces.add(child)`. If `depth + 1 <= maxDepth`, enqueue `(child, F', depth + 1)` with `priority` (section 11). A child whose depth `depth + 1` exceeds `maxDepth` is created and kept in `pieces` but never expanded (a child at depth exactly `maxDepth` is expanded, with fallback elements only, step 5 of 10.2).

### 10.4 The expansion hack

`h` is computed per candidate rotation, before the loop over `K`:

- if the structure's `use_expansion_hack` is false, or `box0.getYSpan() > 16`: `h = 0`;
- otherwise `h` is the maximum, over every jigsaw `K'` of `jigsaws` whose **front cell** `K'.pos + front(K')` lies inside `box0` (an inward-pointing jigsaw), of `max(maxSize(poolOf(K')), maxSize(fallbackOf(poolOf(K'))))`, where `poolOf(K')` is the pool found for `aliases.lookup(K'.pool)` (a missing pool counts as 0, and its fallback as 0) and `maxSize` is 6's `getMaxSize`; jigsaws that point outward contribute 0; the maximum over no jigsaws is 0.

So a short element that has jigsaws pointing into itself reserves, above its own top, the height of the tallest thing those jigsaws could bring in. The enlargement changes the piece's box for the rest of the generation (the same box object is the piece's bounding box and the volume subtracted from the free space), (inferred purpose: reserve room for interior children).

### 10.5 What the interior case means

When the parent's box contains the target cell, the child is confined to the parent's own box (10.2 step 4), not to the global free volume; the holder `ownFree` is shared between all interior children of that parent, so two interior children cannot overlap each other. The child entered into the queue carries `ownFree` as its own `free`; **its** children that attach through an outward-pointing jigsaw therefore also use that holder (confined to the original parent's box), not the global one. A child attached through an outward-pointing jigsaw carries the incoming `free` holder unchanged.

### 10.6 Order of choices, summarised

parents are expanded in queue order; for one parent the jigsaws are tried in shuffled, selection-priority order; for one jigsaw the candidates are tried in pool-then-fallback shuffled order; for one candidate the rotations in shuffled order; for one rotation the candidate's jigsaws in shuffled, selection-priority order; the first geometrically valid combination wins and ends the jigsaw. Nothing is retried globally: a jigsaw that finds no fit stays open and generates nothing, without error.

---

## 11. The placement queue

The queue (`SequencedPriorityIterator`) holds entries `(piece, free holder, depth)` each with an integer priority (the `placement_priority` of the jigsaw of the **parent** that produced the child). `next()` returns the entry with the **highest priority**; among equal priorities, first in first out. An entry added later with a higher priority than the queue's current maximum is returned before the older lower-priority ones. This is exactly a priority queue ordered by (priority descending, insertion order ascending) (the implementation keeps one FIFO deque per priority and a cached highest one).

Initial state: empty. The start piece is expanded directly (depth 0) before the queue is first read. `placement_priority` therefore decides which open connections are served first when several are waiting, and so which pieces win the free space; `selection_priority` decides the order within one piece (4.3).

Implementation note (read in `SequencedPriorityIterator.add`): when an entry is added with a priority greater than or equal to the cached highest queue's priority, the cached highest queue is switched to the queue of the new priority; this keeps `next()` returning the highest priority without a scan, and does not change the order described above.

Worked order (computed): parents `A` (priority 0 jigsaws `a1` then `a2`) and `B` (a `1`-priority jigsaw `b1`). Expanding the start piece queues `A1` (priority 0) and `B1` (priority 1) in jigsaw order; the queue returns `B1` first, then `A1`.

---

## 12. Projection, ground level, junctions

### 12.1 Projection

`rigid`: the piece keeps the vertical position given by its jigsaw alignment with a rigid parent (10.3 step 3). `terrain_matching`: the piece's origin is set from the **surface** at the connection column (`getFirstFreeHeight` with `WORLD_SURFACE_WG`), and the piece's blocks are individually moved to the terrain when written (12.4). A piece's projection is that of its element (a list element imposes its projection on its sub-elements, 5.3).

| Parent | Child | `Yj` | `gChild` | junction ground `G` |
|---|---|---|---|---|
| rigid | rigid | `Y0 + d` | `gParent - d` | `Y0 + rel` |
| rigid | terrain_matching | `surfaceY - qy` | element's (1) | `Y0 + rel` |
| terrain_matching | rigid | `surfaceY - qy` | `gParent - d` | `Yj + qy` |
| terrain_matching | terrain_matching | `surfaceY - qy` | element's (1) | `surfaceY + d / 2` |

### 12.2 Ground-level delta

A piece stores `groundLevelDelta`: the number of blocks above the box bottom at which the piece's "ground" lies. A freshly created start piece gets the element's value (1); a rigid child gets `gParent - d` (it inherits the parent's ground height relative to the connection); a terrain-matching child gets 1. `ground level = box.minY + groundLevelDelta` is used by the beardifier for rigid pieces (16) and in the junction heights (10.3 step 11). It is saved in the piece's NBT (14.2).

### 12.3 Junctions

`JigsawJunction(sourceX, sourceGroundY, sourceZ, deltaY, destProjection)` records one connection from the point of view of one of the two pieces. For a connection between parent `P` (jigsaw at `p`, target cell `t`) and child `C`:

| Held by | `sourceX`, `sourceZ` | `sourceGroundY` | `deltaY` | `destProjection` |
|---|---|---|---|---|
| parent | `t.x`, `t.z` (the cell outside the parent) | `G - rel + gParent` | `d` | the child's projection |
| child | `p.x`, `p.z` | `G - qy + gChild` | `-d` | the parent's projection |

(`G`, `rel`, `qy`, `d`, `gParent`, `gChild` are those of 10.3.) Saved keys `source_x`, `source_ground_y`, `source_z`, `delta_y` (ints) and `dest_proj` (the projection's serialized name, `rigid` or `terrain_matching`). Junctions are not read by the assembler again. Only the beardifier reads them, and it uses only `sourceX`, `sourceGroundY` and `sourceZ` (16): `deltaY` and `destProjection` are stored and serialized but unused by terrain adaptation in this version.

### 12.4 Gravity (terrain matching of blocks)

`GravityProcessor(heightmap = WORLD_SURFACE_WG, offset = -1)` is added to every `terrain_matching` element's settings (5.1). For each template block it computes the new block Y as `height(x, z) + offset + templateY`, where `(x, z)` is the block's already transformed world column, `height` is the level's heightmap value for the heightmap type (when the level that is read is a `ServerLevel`, as for `/place` and the Generate button, `WORLD_SURFACE_WG` is replaced by `WORLD_SURFACE` and `OCEAN_FLOOR_WG` by `OCEAN_FLOOR`; for any other level the heightmap type is used as it is, which is the case during chunk generation (inferred: a generation region is not a `ServerLevel`)), and `templateY` is the block's Y inside the template (the third `BlockPos` argument of `processBlock`: its template-local position). The block keeps its state and NBT. With offset `-1`, template layer 0 therefore lies on the surface block (the last solid block, since `height` is the first free Y). Elements with `terrain_matching` thus drape column by column over the terrain; their stored position and box are not changed.

---

## 13. Collision volumes

### 13.1 Equivalence to a cell test

The free volume is a voxel shape built from boxes whose coordinates are whole numbers (`AABB.of(box)` gives integer corners). The test in 10.3 step 6 asks whether the child's box, shrunk by 0.25 on every side, lies entirely inside the free shape. A shrunk box touches exactly the block cells of the unshrunk box and has non-zero volume in each of them, so the test is equivalent to: **every block cell of the child's box is a free cell**. The shrinking only keeps the test immune to the shape code's rounding tolerance. Step 7 removes the cells of the child's box (unshrunk) from the free shape.

A practical representation: each free holder is a "limit box" (initially the structure limit box of 9.7 or a parent's own box, 10.2 step 4) and a list of boxes removed from it; a cell is free iff it is inside the limit box and inside none of the removed boxes. For the global holder the removed list starts with the start piece's box (9.7 step 2).

### 13.2 The structure limit box

With `hor`, `ver` from `max_distance_from_center` (a single integer gives `hor = ver`), padding `(bottom, top)`, centre `(cx, cz)` and `stubY` (9.4, 9.6), the free cells at the start are those with `cx - hor <= x <= cx + hor`, `cz - hor <= z <= cz + hor` and `max(stubY - ver, minY + bottom) <= y <= min(stubY + ver, maxY - top)`, minus the start piece's cells (the real box of 9.7 has the upper bounds one larger, `min(stubY + ver + 1, maxY + 1 - top)` in Y). A piece is accepted only if all its cells lie in this region. Horizontally the region is at most 257 cells wide (`hor <= 128`).

A feature element's one-cell box also has to be inside this region and not overlap anything; if it does not fit it is skipped like any other element.

---

## 14. The piece: `PoolElementStructurePiece`

### 14.1 Fields

`element`, `position` (the element's origin; for a template this is the template's `(0, 0, 0)` corner transformed by the rotation, i.e. the minimum corner only for `NONE`), `groundLevelDelta`, `rotation`, `junctions` (list), `boundingBox` (from the base class), `liquidSettings`, the template manager. The piece type is `StructurePieceType.JIGSAW`, registered id `jigsaw`.

### 14.2 NBT

In addition to the base class's keys (36-1: id, bounding box, generation depth `GD`, orientation `O`; for a jigsaw piece the generation depth is always 0, because the constructor used by the assembler passes the constant 0 to the base class and the assembler's own depth counter is never stored in the piece; the NBT constructor reads `GD` back from the tag, so a piece generated here always reloads 0), `addAdditionalSaveData` writes `PosX`, `PosY`, `PosZ` (ints), `ground_level_delta` (int), `pool_element` (the element codec of 3.3, with `element_type`), `rotation` (the legacy enum name: `NONE`, `CLOCKWISE_90`, `CLOCKWISE_180` or `COUNTERCLOCKWISE_90`), `junctions` (list of compounds, 12.3) and, only when the piece's liquid settings are not the default `apply_waterlogging`, `liquid_settings`. Loading reads the same keys (missing ints read as 0, a missing `liquid_settings` as the default) and **recomputes the bounding box from the element, position and rotation** (`element.getBoundingBox(manager, position, rotation)`), discarding the box that was saved by the base class. A box enlarged by the expansion hack (10.4) is therefore not what a reloaded piece reports (Open question 4).

### 14.3 Writing

`postProcess(level, structureManager, generator, random, chunkBox, pivot)` calls `place(..., chunkBox, pivot, keepJigsaws = false)`; `place` calls `element.place(manager, level, structureManager, generator, position, pivot, rotation, chunkBox, random, liquidSettings, keepJigsaws)`. The element writes only inside `chunkBox`, so a piece spanning several chunks is written chunk by chunk (36-2 section 5 for the template writing and the bounding-box clipping). `move(dx, dy, dz)` moves the base box and the position together.

---

## 15. Other entry points

`JigsawPlacement.generateJigsaw(level, poolHolder, targetName, maxDepth, pos, keepJigsaws)`:

1. Builds a generation context over the level's generator and biome source with the level's seed and the chunk containing `pos` (so the context random is `setLargeFeatureSeed(levelSeed, chunkX, chunkZ)` like worldgen), with a biome predicate that is always true.
2. Calls `addPieces(context, pool, Optional.of(targetName), maxDepth, pos, expansionHack = false, heightmap = none, MaxDistance(128), EMPTY aliases, ZERO padding, apply_waterlogging)`. The start element therefore gets its jigsaw named `targetName` placed on `pos`, no heightmap projection and no height clamp (the free box is 128 around `pos` in all directions).
3. If a stub results, builds its pieces and, for each `PoolElementStructurePiece`, calls `place(level, structureManager, generator, levelRandom, BoundingBox.infinite(), pos, keepJigsaws)` (the level's own random and an unbounded write box), and returns true; false when no stub resulted.

The block's **Generate** action (`JigsawBlockEntity.generate(level, levels, keepJigsaws)`) calls it with `pos = block position + front`, `targetName` = the block's `target` field, the block's `pool`, `maxDepth = levels` from the packet and `keepJigsaws` from the packet (31-6 section 8.2); the **`/place jigsaw <pool> <target> <max_depth 1..20> [position]`** command calls it with `keepJigsaws = false` after checking that the chunk at the position is loaded and fails when the result is false. Details of the command: the `[position]` argument is optional (both the `max_depth` node and the `position` node are executable); when given it is resolved through `BlockPosArgument.getLoadedBlockPos`, and when omitted the position is the block containing the source's position (`BlockPos.containing(source.getPosition())`); in both cases the chunk is then checked with `checkLoaded`. The `<pool>` argument is a template-pool resource key; an unknown pool fails with the key `commands.place.jigsaw.invalid` (English text: `There is no template pool with type "%s"`). A false result fails with the key `commands.place.jigsaw.failed` (English text: `Failed to generate jigsaw`); success uses `commands.place.jigsaw.success` (`Generated jigsaw at %s, %s, %s`) (texts read in `en_us.json`). 16 section 7.5 should say that `position` is optional. With `keepJigsaws` true the jigsaw replacement processor is not added (5.1), so the jigsaw blocks stay in the world.

---

## 16. Terrain adaptation interplay

Terrain adaptation (`terrain_adaptation` of the structure: `none`, `bury`, `beard_thin`, `beard_box`, `encapsulate`) is applied by the beardifier term of the terrain density (36-1 section 9 gives its kernels and formulas). What the assembly supplies to it:

- For each structure start with `terrain_adaptation != none` near the chunk, each piece within 12 blocks of the chunk (the piece's box intersects the chunk's block rectangle widened by 12) contributes:
  - **pool pieces whose element projection is `rigid`:** one "rigid" entry `(box, adjustment, groundLevelDelta)`; the beardifier's reference Y for the piece is `box.minY + groundLevelDelta`;
  - **pool pieces that are `terrain_matching`:** no box entry;
  - **every junction** of every pool piece close to the chunk (any projection) whose `sourceX` lies strictly between `chunkMinX - 12` and `chunkMinX + 15 + 12` and whose `sourceZ` likewise: one junction entry; the beardifier adds `0.4f * beard(dx, dy, dz, dy)` per junction (the weight is the float constant 0.4f and `beard` returns a float, multiplied and accumulated in single precision; 36-1 section 9.3), with `(dx, dy, dz)` the offset of the sampled point from `(sourceX, sourceGroundY, sourceZ)`;
  - non-pool pieces of such a structure: a rigid entry with `groundLevelDelta = 0`.
- The affected region is the union of those boxes and junction points, widened by 24.

So a `terrain_matching` piece does not push the terrain by itself; it only reshapes it through its junctions with rigid neighbours, and a village road (a `terrain_matching` piece between rigid buildings) is shaped by the junctions at its two ends. Gravity (12.4) is the complementary half: it moves the piece's blocks to the terrain after the density terrain exists.

The extra range of 12 blocks is why a structure with any terrain adaptation can have `max_distance_from_center.horizontal` at most 116 (`116 + 12 = 128`, 3.1); the jar uses 80 for most structures and 116 for `ancient_city` (`beard_box`) and `trial_chambers` (`encapsulate`).

---

## 17. Random-number consumption, in order

All draws come from the context random (`WorldgenRandom`, section 8.2) unless stated.

1. `startHeight.sample` (provider-dependent: 0 draws for `absolute`).
2. `Rotation.getRandom`: `nextInt(4)`.
3. `getRandomTemplate` on the start pool: `nextInt(size)` when non-empty.
4. If a start jigsaw name is used: the shuffle (`n - 1` draws) of the start element's jigsaws.
5. For the start piece, then for every queue entry in queue order: the shuffle of the piece's jigsaws (`n - 1` draws); then for each jigsaw in order: a shuffle of the pool's expanded template list (`size - 1` draws; skipped at the maximum depth), a shuffle of the fallback's expanded list; then for each candidate until one is placed: a four-element rotation shuffle (3 draws), and for each rotation a shuffle of the candidate's jigsaws (`n - 1`), the jigsaw lists being evaluated at the **origin**, so the draws are the same whatever the final position.
6. Pool aliases use the separate generator of 7.2 (draws in binding order).
7. Block placement (36-2) uses the random passed to `postProcess`, not this sequence.

Note that candidates that do not fit still consume the draws of their rotation shuffles and jigsaw shuffles: a candidate's failure is not free.

---

## 18. Worked examples

All positions are examples; the three template files are in the jar (`pillager_outpost/base_plate` is 16 by 30 by 16, `pillager_outpost/watchtower` 15 by 21 by 15, `pillager_outpost/feature_plate` 16 by 4 by 32). Jigsaw positions are read from the NBT. The structure parameters are those of `pillager_outpost.json`: `start_pool = pillager_outpost/base_plates`, `size = 7`, `start_height = absolute 0`, `project_start_to_heightmap = WORLD_SURFACE_WG`, `max_distance_from_center = 80`, `use_expansion_hack = true`.

### 18.1 Start piece (computed)

Chunk `(3, -2)`: start position `pos = (48, 0, -32)`. `base_plates` holds one `legacy_single_pool_element` of `pillager_outpost/base_plate` (rigid), so `getRandomTemplate` draws `nextInt(1) = 0`. Suppose `Rotation.getRandom` gave `NONE`. Box at `pos`: `(48, 0, -32)` to `(63, 29, -17)`. Centre: `cx = (63 + 48) / 2 = 55`, `cz = (-17 + -32) / 2 = -49 / 2 = -24` (truncated toward zero; the floor would give `-25`). Suppose `getFirstFreeHeight(55, -24, WORLD_SURFACE_WG)` is 72 (a hypothetical terrain value). Then `y = 0 + 72 = 72`; `groundY = 0 + 1 = 1`; the piece moves by `72 - 1 = 71`: position `(48, 71, -32)`, box y `71` to `100`. The piece's first layer (`y = 71`) is the surface block, the layer above it (`y = 72`) is the first free cell. The stub position is `(55, 72, -24)`. With rotation `CLOCKWISE_90`: the far corner `(15, 29, 15)` rotates to `(-15, 29, 15)`, so the box is `x 33..48`, `z -32..-17` and `cx = (48 + 33) / 2 = 40`.

### 18.2 The limit box (computed)

Same structure, overworld `min_y = -64`, height 384 (`maxY = 319`, 10 section 5), padding zero, `max_distance_from_center = 80` so `hor = 80`, `ver = 4064`: cells `x -25..135`, `z -104..56`, `y max(72 - 4064, -64) = -64` to `min(72 + 4064, 319) = 319`, minus the start box `x 48..63, y 71..100, z -32..-17`. The real box passed to the shape code is `(-25, -64, -104)` to `(136, 320, 57)`.

### 18.3 An interior attachment (computed, from the jar)

The base plate (position `(48, 71, -32)`, `NONE`) holds two `minecraft:entrance` jigsaws at template positions `(7, 1, 14)` and `(8, 1, 14)`, both `north_up`, `aligned`, target `minecraft:entrance`, pool `pillager_outpost/towers`. Take the first: `p = (55, 72, -18)`, `f = north` (step `(0, 0, -1)`), `t = (55, 72, -19)`, `rel = 72 - 71 = 1`. The `towers` pool has one `list_pool_element` (watchtower, then watchtower_overgrown; rigid; the jigsaws of the first sub-element are used): one jigsaw at template `(7, 1, 13)`, `south_up`, `aligned`, name `minecraft:entrance`, pool `minecraft:empty`.

- `canAttach`: `north` is the opposite of `south`; the parent is `aligned`, tops are both up; the parent's target equals the child's name. Only the rotation `NONE` of the child turns its jigsaw to face south, so the other three rotations never attach.
- `t` lies in the parent's box (`x 48..63, y 71..100, z -32..-17`), so the free holder is the parent's own box.
- Origin `o = t - q = (55, 72, -19) - (7, 1, 13) = (48, 71, -32)`; child box (15 by 21 by 15) `x 48..62, y 71..91, z -32..-18`. Both rigid: `d = 1 - 1 + 0 = 0`; `Yj = 71 + 0 = 71`; `dy = 71 - 71 = 0`. The expansion hack does not apply: the tower is 21 blocks high (more than 16), so `h = 0`. The box lies inside the parent's box: it fits. `gChild = 1 - 0 = 1`; `G = 71 + 1 = 72`.
- Junctions: parent gets `(55, 72 - 1 + 1 = 72, -19, 0, rigid)`, child gets `(55, 72 - 1 + 1 = 72, -18, 0, rigid)`.
- The child's single jigsaw has pool `minecraft:empty`: when it is expanded nothing is attached.
- The second entrance jigsaw `(8, 1, 14)`: its candidate origin would be `(49, 71, -32)`, box `x 49..63`: it overlaps the tower just placed (its holder is the same `ownFree`), so no tower is placed there. Which of the two jigsaws is served first depends on the shuffle, so the tower stands at `x 48..62` or at `x 49..63`; exactly one tower is placed.

### 18.4 A terrain-matching attachment (computed, from the jar)

The base plate also has three `plate_entry` jigsaws (`aligned`) with pool `pillager_outpost/feature_plates`; one is at template `(0, 0, 7)`, `west_up`. The pool's element is a `legacy_single_pool_element` of `feature_plate` with projection `terrain_matching`; the plate has an `east_up` `plate_entry` jigsaw at `(15, 0, 7)` (and `up_north` `minecraft:feature` jigsaws with pool `pillager_outpost/features`, `rollable`, for the next level).

`p = (48, 71, -25)`, `f = west`, `t = (47, 71, -25)`, `rel = 0`. Candidate rotation `NONE` (its `east_up` jigsaw faces east, the opposite of west; tops both up). `q = (15, 0, 7)`, `o = (47 - 15, 71 - 0, -25 - 7) = (32, 71, -32)`; box (16 by 4 by 32) `x 32..47, y 71..74, z -32..-1`. `t` lies outside the parent's box (`x < 48`), so the free holder is the global one. Not both rigid: suppose `getFirstFreeHeight(48, -25, WORLD_SURFACE_WG) = 70`: `surfaceY = 70`, `Yj = 70 - 0 = 70`, `dy = 70 - 71 = -1`: child position `(32, 70, -32)`, box y `70..73`. `d = 0 - 0 + 0 = 0`, `gChild = 1` (terrain-matching child takes the element's delta). Parent is rigid so `G = Y0 + rel = 71`. Junctions: parent `(47, 71 - 0 + 1 = 72, -25, 0, terrain_matching)`, child `(48, 71 - 0 + 1 = 72, -25, 0, rigid)`. The feature plate is 4 blocks high, so the expansion hack applies to it: its `minecraft:feature` jigsaws point up into its own box, so `h` is the largest `maxSize` among the elements of `pillager_outpost/features` and its fallback (not computed here), and the box may be enlarged upward before the collision test (10.4); the numbers above are without that enlargement. The beardifier will see the base plate as a rigid entry with reference Y `71 + 1 = 72`, will not see the plate (terrain-matching) as a box, and will see both junctions.

### 18.5 Rotation of a jigsaw (computed)

Base plate at `(48, 71, -32)` rotated `CLOCKWISE_90`: the jigsaw at template `(7, 1, 14)` `north_up` moves to `(-z, y, x) = (-14, 1, 7)`, world `(34, 72, -25)`, orientation `east_up`, target cell `(35, 72, -25)`; the box is `x 33..48, y 71..100, z -32..-17`.

### 18.6 The expansion hack (computed)

A candidate element with box (at its rotation) `y 64..70` (`getYSpan = 7 <= 16`) has an inward jigsaw whose target pool has `maxSize 12`: `h = 12`, `k = max(13, 70 - 64 = 6) = 13`, the box is encapsulated with `(minX, 77, minZ)`: new `maxY = 77`. With `h = 3`: `k = max(4, 6) = 6`, the point has `y = 70`, nothing changes.

### 18.7 Depth and fallback (computed)

`size = 2`. The start piece (depth 0) is expanded with its pool's elements and the fallback's; each child made then has depth 1 and is enqueued (`0 + 1 <= 2`). A depth-1 piece is expanded with pool elements (`depth != maxDepth`); its children have depth 2 and are enqueued (`1 + 1 <= 2`). A depth-2 piece is dequeued with `depth == maxDepth`, so only **fallback** elements are used for its jigsaws; its children have depth 3, are created and kept, but are not enqueued (`2 + 1 > 2`). So with `size = N` pieces exist up to depth `N + 1`, the last level made only of fallback elements (the "terminators" pools of the village structures).

Worked check of the limits. `size = 0`: the callback returns before the builder copy, the piece list is empty, the start is invalid and no structure generates. `size = 1`: the start piece (depth 0) is expanded with pool and fallback elements; its depth-1 children are created and enqueued (`0 + 1 <= 1`); each is dequeued with `depth == maxDepth`, so its jigsaws are served from fallback elements only; their depth-2 children are kept but not enqueued (`1 + 1 > 1`). The result is the start piece, its depth-1 children and the depth-2 fallback pieces.

---

## 19. Validation (checkable facts)

1. Constants: `MAX_TOTAL_STRUCTURE_RANGE` 128, depth range 0 to 20, extra range 12 for any `terrain_adaptation` except `none`, collision deflation 0.25, expansion-hack height limit 16, `Y_SIZE` 4064, `MIN_Y` -2032, `MAX_Y` 2031, default final state `minecraft:air`, `/place jigsaw` depth 1 to 20.
2. The attach rule's three conditions and its argument order (4.1): parent first; only the parent's joint matters; a null child name passes.
3. The rotation table of 2.1 and the box rule (two transformed corners, then move). Example: a 16 by 30 by 16 template rotated `CLOCKWISE_90` has box `x -15..0`, `z 0..15` relative to its origin.
4. Draw order (section 17): rotation first, then the start pool pick, then shuffles; `Util.shuffle` draws `size - 1` values from the end of the list.
5. The queue is a priority queue by (priority descending, insertion ascending).
6. The start position is the chunk's minimum corner; the centre of the start box uses truncating division; the stub is `(cx, y + offsetY, cz)`.
7. Free box formula of 9.7 with the padding, and the interior case (13.2, 10.2 step 4).
8. `verifyRange`: all 28 jigsaw structures of the jar satisfy it: horizontal distance 80 (26 structures), 116 (2: `ancient_city` with `beard_box`, `trial_chambers` with `encapsulate`); extra 12 for all with adaptation: `116 + 12 = 128`.
9. Counts from the archive (`unzip -Z1 | grep -v '/$'`): 52 files under `data/minecraft/worldgen/structure/` of which 28 have type `minecraft:jigsaw` (18 `abandoned_camp_*`, `ancient_city`, `bastion_remnant`, `pillager_outpost`, `trail_ruins`, `trial_chambers`, 5 villages); 245 template pool files; element types over all pool files: `legacy_single_pool_element` 1665, `single_pool_element` 531, `feature_pool_element` 57, `empty_pool_element` 31, `list_pool_element` 3; projections `rigid` 2073, `terrain_matching` 183 (31 empty elements carry none); `override_liquid_settings` appears nowhere in the pools; 1511 structure NBT files of which 1291 hold jigsaws (4272 jigsaw blocks, 4.4).
10. Structure parameters read: `use_expansion_hack` true for the 18 abandoned camps, the outpost and the 5 villages; false for `ancient_city`, `bastion_remnant`, `trail_ruins` and `trial_chambers`; `project_start_to_heightmap` is `WORLD_SURFACE_WG` for the same set plus `trail_ruins`; `start_jigsaw_name` only on `ancient_city` (`minecraft:city_anchor`); `dimension_padding` 10 and `liquid_settings` `ignore_waterlogging` only on `trial_chambers`, which also has pool aliases; `size` 2 (camps), 6 (villages, `bastion_remnant`), 7 (outpost, `trail_ruins`, `ancient_city`), 20 (`trial_chambers`); `terrain_adaptation`: `beard_thin` (camps, outpost, villages), `beard_box` (`ancient_city`), `bury` (`trail_ruins`), `encapsulate` (`trial_chambers`), key absent, so the default `none` applies (`bastion_remnant`; its JSON has no `terrain_adaptation` key; the default itself was not read from `Structure$StructureSettings` here, 36-1 section 3.1 owns it).
11. The alias example of 7.4: three draws `nextInt(3)`, `nextInt(3)`, `nextInt(4)`.
12. Piece NBT keys: `PosX`, `PosY`, `PosZ`, `ground_level_delta`, `pool_element`, `rotation`, `junctions`, optional `liquid_settings`; junction keys `source_x`, `source_ground_y`, `source_z`, `delta_y`, `dest_proj`; piece id `jigsaw`.
13. Real-data check (18.3): the two `entrance` jigsaws of the base plate at template `(7, 1, 14)` and `(8, 1, 14)`, the tower's at `(7, 1, 13)`, the plate entries at `(0, 0, 7)` west_up, `(7, 0, 15)` south_up, `(15, 0, 8)` east_up.

---

## 20. Open questions

1. **Palette selection on position (resolved by 36-2 section 4.3).** The palette index is `getRandom(pos).nextInt(n)`, a position-seeded draw (or a shared random if the settings hold one), evaluated again by `getJigsaws` with its origin argument; so an assembler that evaluates a candidate at its origin and a placement at the real position may pick different palettes for a multi-palette jigsaw template. No jigsaw-bearing template of the jar has more than one palette, so there is no effect on vanilla data.
2. **Orientation rotation (resolved).** `Rotation.CLOCKWISE_90` is `OctahedralGroup.ROT_90_Y_NEG` (an axis permutation with an inversion on one output); the horizontal result matches the table of 2.1 and the vertical axis is fixed. The 12 by 4 table was not enumerated element by element; the 2.1 examples follow from the group definition.
3. **Shape code tolerance.** The reduction of the voxel-shape test (10.3 step 6) to a whole-cell test (13.1) is derived from the 0.25 deflation and integer box corners; the shape library's epsilon behaviour (`Shapes.joinIsNotEmpty`, `joinUnoptimized`) was not read.
4. **Reloaded boxes.** A piece loaded from NBT recomputes its box from the element (14.2), losing a box that the expansion hack enlarged; whether anything outside the generation depends on the enlarged box after a reload (chunk membership of pieces, structure bounding box saved in the start) is in 36-1 and was not traced.
5. **Placement flags (resolved in 36-2 section 5).** The flag value 18, `knownShape`, `finalizeEntities`, `liquid_settings`, the box limit, entity placement and processor semantics are in 36-2 section 5 and 7 to 9. The "world generation" to live heightmap substitution of 12.4 was read in `GravityProcessor` only (see also 36-2 section 9.5).
6. **Heightmap predicates and `getFirstFreeHeight` per generator.** Only the noise generator's column query is documented (37-2 section 6.5); the flat, debug and void generators' `getBaseHeight` were not read.
7. **Structure framework checks after the stub.** What the framework does with the stub (biome test, piece order, saving the box) is 36-1; the class `Structure$GenerationContext.isValidBiome` was read (noise biome at the stub position converted to quart coordinates).
8. **`StructurePiece` base keys.** The base class's saved keys and `isCloseToChunk` (read: box intersects the chunk rectangle widened by the given margin, 12 for the beardifier) are cross-referenced to 36-1; the base keys were not re-read here.
9. **Debug switches (cross-referenced).** The shared constant `DEBUG_KEEP_JIGSAW_BLOCKS_DURING_STRUCTURE_GEN` keeps jigsaw blocks during generation; 36-2 section 9.6 states it is normally off.
10. **Per-structure `handleDataMarker` and subclasses of the pool elements.** No class outside `structure.pools` extends a pool element in this jar (the references to `StructurePoolElement` are all in the `pools` package and `PoolElementStructurePiece`), so data markers of jigsaw templates are ignored by the assembler; structures whose pieces are not pool pieces (36-4 to 36-10) handle their own markers.
11. **Admin interactions.** The permission check and the client packet of the Generate button were read in 31-6 only; the `levels` range sent by the client's screen was not read here.
12. **Weight list order.** The weighted list used by aliases is walked in list order (read in `WeightedList$Compact`); the construction of the list from JSON order (and of the `Flat` variant, which indexes an expanded array) was assumed to keep the JSON order for equal weights.
13. **Why the volume's vertical default is 4064.** The default `vertical` equals the dimension-type size constant, not the actual dimension height; for 24-section dimensions it is larger than the dimension, so the vertical clamp always comes from `min_y` and `max_y` (computed from the formula of 13.2; not observed in a run).
14. **Recalled statements.** None of this document is taken from recall; every constant was read in this round. The description of the purposes of the expansion hack and of interior connections (10.4, 10.5) is inferred from the mechanism.
15. **Cross-document corrections still owed.** (a) 36-1 section 6 piece table, row `genDepth` says "jigsaw as the depth"; the artifact shows jigsaw pieces always have generation depth 0 (14.2). (b) 16 section 7.5 says `/place jigsaw` requires its `position`; the command accepts it as optional (15). (c) 16 and 12.3 style texts writing `0.4 * beard(...)` should say `0.4f`, single precision. (d) 36-10 section 2 step 15 ("If size <= 0 stop") is ambiguous and should say that size 0 adds no pieces, so the start is invalid and no structure generates (9.7 step 1). These files are outside this round's edit targets; searched: `PoolElementStructurePiece` constructors, `PlaceCommand` command nodes, `en_us.json` keys `commands.place.jigsaw.*`.
16. **Resolved: NBT constructor default of `GD`.** The base-class NBT constructor reads `getIntOr("GD", 0)`, so a missing key gives generation depth 0 (read in `StructurePiece`).
