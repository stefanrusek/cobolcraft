# Block registry, part 4: stems, glass panes, vines, cauldrons, the End, flower pots, buttons and skulls

| Item | Value |
|---|---|
| Covers | The `Blocks` static fields 315 to 419 in declaration order, `MUSHROOM_STEM` to `WITHER_SKELETON_SKULL`, and what the registry needs for each: registry key and numeric id, block class, state properties with value order and default state, state count, material and strength properties, collision and outline geometry, placement state and survival rule, and the per-class behaviour that the registry round (RS4) owns. Cross-block rules (block updates, fluids, redstone, growth engines, block entities, loot, tags) are cited, not repeated |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact recorded in `README.md`) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`) and of the data files stored in the same archive (`data/minecraft/tags/block/*.json`, `data/minecraft/loot_table/blocks/*.json`), with no execution. Classes read: `Blocks` (static initialiser and helpers), `BlockBehaviour` and `BlockBehaviour$Properties`, `BlockStateProperties`, `Block`, `Shapes`, `OctahedralGroup`, `SymmetricGroup3`, `Direction` and `Direction$Plane`, `Mirror`, `Rotation`, `RotationSegment`, `SegmentedAnglePrecision`, `UseOnContext`, `BlockPlaceContext`, `Util`, `WeatheringCopper`, `WeatheringCopperCollection`, `ChangeOverTimeBlock`, `FireBlock`, `SimpleWaterloggedBlock`, `WoodType`, `LeadItem`, `Leashable`, `references.BlockItemIds`, `references.BlockIds`, `BlockColors`, and the block classes named in section 6. Constants quoted in section 6 were re-checked against the class named beside them |
| Round | RS4 (docs/design/README.md Part 6), part 4 of 8. The block-registry family is the eight documents named `24-block-registry-N-...`; this one is part 4 ("24 part 4"). Parts 1 to 3 cover fields 0 to 314 and parts 5 to 8 cover fields 420 to 910 (fields 420 to 524 are 24 part 5). The shared rules (registration order, id assignment, the `Properties` builder, tag checks, shape vocabulary, tint classes) belong to 24 part 1, and this document only restates the pieces it needs to be read alone |
| Form | Prose, tables, formulas and worked examples. Artifact class and method names are cited in backticks as locations only |
| Data versus code | Per the operator decision "Vanilla assets and data", data rows (block states and models, loot tables, tags, recipes) are extracted by the tool and are not listed here. Behaviour is code content. Where behaviour reads a tag (for example `supports_pumpkin_stem`), the tag name is given and the membership is data. Section 4.1 additionally names, per block, the `mineable/*` and `needs_*_tool` tag membership and whether a loot table file exists, read from the data files of the same archive, so that an implementer sees which tool class mines each block; the extraction tool remains the authority for the data itself |

## 1. Scope and how the range was taken

1. The range is the 105 `public static final` fields of `Blocks` with 0-based declaration index 315 to 419. Index 315 is `MUSHROOM_STEM` and index 419 is `WITHER_SKELETON_SKULL`. The `Blocks` class declares 911 `public static final` fields (878 `Block`, 18 `ColorCollection`, 15 `WeatheringCopperCollection`); the static initialiser holds 914 `putstatic` instructions, the three extra ones assigning private predicate constants (`NOT_CLOSED_SHULKER`, `NOT_EXTENDED_PISTON`, `NEAR_PLANE_INTERSECTS_OUTLINE`). The order of the 911 public fields equals the order of the `putstatic` instructions that target them (checked name by name, recounted in this round), and that order is the registration order (04 section 5.1).
2. Two of the 105 fields (`COPPER_BARS`, `COPPER_CHAIN`) are `WeatheringCopperCollection` fields. Each registers **8 blocks**, so the range registers 119 blocks, not 105 (section 3).
3. Scope boundary. The fields that sit after index 419 are **not** specified here: `WITHER_SKELETON_WALL_SKULL` is 420, `ZOMBIE_HEAD` 421, `DRAGON_HEAD` 427, `ANVIL` 431 (with `CHIPPED_ANVIL` 432 and `DAMAGED_ANVIL` 433), `TRAPPED_CHEST` 434, the two weighted plates 435 and 436, `COMPARATOR` 437. Their rows, shapes, the other heads, the anvils, the trapped chest, the weighted plates and the comparator are all in **24 part 5** (fields 420 to 524), which lists every one of these fields by name (confirmed by reading that document's table). Only the 30 potted blocks that are declared between `FLOWER_POT` and `CARROTS` are in this range; the other `POTTED_*` fields are declared later (24 part 6 covers up to `POTTED_BAMBOO`, field 629; 24 part 8 lists the eyeblossom and azalea pots).
4. `WITHER_SKELETON_WALL_SKULL` (index 420) is carried as an appendix row in the tables because the wall-skull pair shares its class hierarchy with `SKELETON_WALL_SKULL` (section 6.33). It is not part of the range, it is specified in 24 part 5, and its id is counted as 509 only to show the sequence.
5. Numeric ids. Block ids are registration indices (04 section 5.1). Before index 315 the declaration list contains five `ColorCollection` fields (`BED`, `WOOL`, `WOOL_STAIRS`, `WOOL_SLAB`, `STAINED_GLASS`, 16 blocks each; confirmed by listing the `Collection`-typed fields among the first 315) and no weathering collection, so the first block of this range has id 315 - 5 + 80 = **390** (derived from the field order and the collection sizes, not printed by the artifact, "(inferred)"). Cross-check: 24 part 8 gives `mushroom_stem` first state id 9628 and the appendix `wither_skeleton_wall_skull` first state id 12754, and 12754 - 9628 = 3126, equal to this document's range total. State ids are given as an offset from the first state of `mushroom_stem` ("relative first state"); the implementer adds the base 9628 (24 part 8). 24 part 3 gives `red_mushroom_block` first state 9312, which disagrees with 24 part 8 (9564); that conflict belongs to part 3 (Open question 1).

## 2. Vocabulary used by every section

### 2.1 Directions and orders

| Name | Order or value |
|---|---|
| `Direction` constants (enum order) | DOWN, UP, NORTH, SOUTH, WEST, EAST |
| Horizontal plane order (`Direction$Plane.HORIZONTAL`) | NORTH, EAST, SOUTH, WEST. `getRandomDirection` picks index `nextInt(4)` of this list |
| `HORIZONTAL_FACING` property values | NORTH, EAST, SOUTH, WEST in that order |
| `FACING` (six-way) property values | NORTH, EAST, SOUTH, WEST, UP, DOWN in that order (a list given explicitly, not the enum order) |
| `Direction$Axis` | X, Y, Z. Horizontal axes are X and Z |
| `AttachFace` | FLOOR, WALL, CEILING |
| `Half` | TOP, BOTTOM |
| `SlabType` | TOP, BOTTOM, DOUBLE |
| `StairsShape` | STRAIGHT, INNER_LEFT, INNER_RIGHT, OUTER_LEFT, OUTER_RIGHT |
| `WallSide` | NONE, LOW, TALL |
| Boolean property | `true` first, then `false` (04 section 5.2) |
| Integer property `name 0..n` | ascending from the minimum |

`Direction` constants as read from the enum initialiser (columns: ordinal, step vector (x, y, z), 2D data value used by yaw conversion, opposite):

| Direction | Ordinal | Step (x, y, z) | 2D data value | Opposite |
|---|---|---|---|---|
| DOWN | 0 | (0, -1, 0) | none (-1) | UP |
| UP | 1 | (0, 1, 0) | none (-1) | DOWN |
| NORTH | 2 | (0, 0, -1) | 2 | SOUTH |
| SOUTH | 3 | (0, 0, 1) | 0 | NORTH |
| WEST | 4 | (-1, 0, 0) | 1 | EAST |
| EAST | 5 | (1, 0, 0) | 3 | WEST |

Clockwise and counter-clockwise (`getClockWise`, `getCounterClockWise`, read from their jump tables) are the horizontal quarter turns seen from above:

| Direction | `getClockWise` | `getCounterClockWise` |
|---|---|---|
| NORTH | EAST | WEST |
| EAST | SOUTH | NORTH |
| SOUTH | WEST | EAST |
| WEST | NORTH | SOUTH |

Rules read from `Direction`, `UseOnContext` and `BlockPlaceContext` that the placement rules below use:

1. `Direction.getRandom(random)` is `values()[random.nextInt(6)]` over the enum order DOWN, UP, NORTH, SOUTH, WEST, EAST (`Util.getRandom` on the `VALUES` array). `Plane.HORIZONTAL.getRandomDirection(random)` is element `random.nextInt(4)` of [NORTH, EAST, SOUTH, WEST].
2. `Direction.fromYRot(y)` is the direction whose 2D data value equals `floor(y / 90 + 0.5) & 3`: yaw 0 gives SOUTH, 90 gives WEST, 180 gives NORTH, 270 (or -90) gives EAST. An entity's `getDirection()` is `fromYRot` of its Y rotation.
3. `UseOnContext.getHorizontalDirection()` is the placing player's `getDirection()` (so **the direction the player is facing, not its opposite**), and NORTH when there is no player. `UseOnContext.getRotation()` is the player's Y rotation in degrees, 0.0 when there is no player.
4. `Direction.orderedByNearest(entity)` returns six directions ordered by how closely they match the entity's view. With p = view X rotation and y = view Y rotation in radians (y negated), sx = sin(y), sp = sin(p), cy = cos(y), cp = cos(p): the three candidates are X = EAST when sx is greater than 0 and WEST otherwise, Y = UP when sp is below 0 and DOWN otherwise, Z = SOUTH when cy is greater than 0 and NORTH otherwise; the magnitudes are ax = |sx|, ay = |sp|, az = |cy|, and the thresholds are tx = ax * cp and tz = az * cp. The first, second and third axes are chosen as in the table, and the result is [first, second, third, opposite of third, opposite of second, opposite of first].

| Condition (evaluated top to bottom) | first, second, third |
|---|---|
| ax > az and ay > tx | Y, X, Z |
| ax > az and tz > ay | X, Z, Y |
| ax > az (otherwise) | X, Y, Z |
| ax <= az and ay > tz | Y, Z, X |
| ax <= az and tx > ay | Z, X, Y |
| ax <= az (otherwise) | Z, Y, X |

5. `BlockPlaceContext.getNearestLookingDirections()` is the array of rule 4 when the context replaces the clicked block (`replacingClickedOnBlock`). Otherwise the opposite of the clicked face is moved to the front: if it is found at index i greater than 0, entries 0 to i - 1 shift one place back and the opposite of the clicked face becomes entry 0 (if it is already first, the array is unchanged). `getClickedPos()` is the clicked block when the clicked block is replaceable by the item, else the block next to the clicked face.

Worked example of rule 4. A player looking due south and level (yaw 0, pitch 0): y = -0 so sx = 0, cy = 1, sp = 0, cp = 1; X = WEST (sx not above 0), Y = DOWN (sp not below 0), Z = SOUTH. ax = 0, az = 1, so the `ax <= az` rows apply; ay = 0 is not greater than tz = 1 and tx = 0 is not greater than ay = 0, so the order is Z, Y, X = SOUTH, DOWN, WEST and the array is [SOUTH, DOWN, WEST, EAST, UP, NORTH]. Rule 2 for the same player gives `getDirection()` = SOUTH.

### 2.2 Property names and ranges used in this part

All are fields of `BlockStateProperties` unless noted; the serialized name is the first argument of `create`.

| Field | Name | Type and values |
|---|---|---|
| `AGE_1`, `AGE_2`, `AGE_3`, `AGE_7` | `age` | integer 0..1, 0..2, 0..3, 0..7 |
| `WATERLOGGED` | `waterlogged` | boolean |
| `AXIS` | `axis` | enum x, y, z |
| `UP`, `DOWN`, `NORTH`, `EAST`, `SOUTH`, `WEST` | `up`, `down`, `north`, `east`, `south`, `west` | boolean |
| `NORTH_WALL`, `EAST_WALL`, `SOUTH_WALL`, `WEST_WALL` | `north`, `east`, `south`, `west` | enum `WallSide` |
| `HORIZONTAL_FACING` (`HorizontalDirectionalBlock.FACING`) | `facing` | four horizontal directions |
| `ATTACH_FACE` | `face` | enum `AttachFace` |
| `HALF` | `half` | enum `Half` |
| `STAIRS_SHAPE` | `shape` | enum `StairsShape` |
| `SLAB_TYPE` | `type` | enum `SlabType` |
| `LEVEL_CAULDRON` | `level` | integer 1..3 |
| `HAS_BOTTLE_0`, `HAS_BOTTLE_1`, `HAS_BOTTLE_2` | `has_bottle_0` ... | boolean |
| `EYE` | `eye` | boolean |
| `SNOWY` | `snowy` | boolean |
| `LIT` | `lit` | boolean |
| `OPEN`, `POWERED`, `IN_WALL`, `ATTACHED`, `DISARMED`, `CONDITIONAL` | same lower-case names | boolean |
| `ROTATION_16` | `rotation` | integer 0..15 (see 2.4) |

### 2.3 State order and state ids

A block's states are the Cartesian product of its properties sorted by name, in value order, with the first sorted name varying slowest (04 section 5.2). "Relative first state" in the registry table is the running total of state counts inside this part. The relative state of a given combination is that block's relative first state plus the index computed by the formula in 04 section 5.2; section 8 gives worked examples. The default state is set by the constructor call `registerDefaultState`; a property the constructor leaves unset keeps the first value of its list (so an unset `facing` is NORTH, an unset boolean is `true`). Every row of the table below states the default explicitly, and no block here leaves a boolean unset.

### 2.4 Shape vocabulary

All lengths are in sixteenths of a block (pixels), x east, y up, z south; a block occupies 0..16 on each axis. `Block.box(x0, y0, z0, x1, y1, z1)` is that box divided by 16. The helpers below are static methods of `Block`; they are how every shape in this document is defined.

| Helper | Meaning |
|---|---|
| `column(s, y0, y1)` | square column: x and z each from 8 - s/2 to 8 + s/2, y from y0 to y1 |
| `column(sx, sz, y0, y1)` | rectangular column: x from 8 - sx/2 to 8 + sx/2, z from 8 - sz/2 to 8 + sz/2 |
| `cube(sx, sy, sz)` and `cube(s)` | box centred on the block centre with those extents (y from 8 - sy/2 to 8 + sy/2) |
| `boxZ(sx, y0, y1, z0, z1)` | x centred with width sx, y from y0 to y1, z from z0 to z1 |
| `boxZ(sx, sy, z0, z1)` | x and y both centred (widths sx and sy), z from z0 to z1 |
| `boxZ(s, z0, z1)` | x and y both centred with width s, z from z0 to z1 |
| `boxes(n, f)` | the array `f(0)`, `f(1)`, ..., `f(n)` (n + 1 entries) |

Shape operations used: union (`Shapes.or`), difference (`Shapes.join` with `ONLY_FIRST`: the first shape minus the second), `move(dx, dy, dz)` (dx, dy, dz in blocks, so 3 pixels is 0.1875), `optimize` (no change to the point set), `Shapes.empty()` and `Shapes.block()` (the full 0..16 cube). `BooleanOp.ONLY_FIRST` leaves the part of the first operand not covered by the second.

Rotation, read from `Shapes.rotate`, `Shapes.rotateHorizontal`, `OctahedralGroup` and `SymmetricGroup3`. A shape written "facing north" is the arm or part on the NORTH (z small) side. A rotation group is described by a permutation of the axes and three invert flags (`OctahedralGroup(name, permutation, invertX, invertY, invertZ)`). `Shapes.rotate(shape, group)` builds the new shape whose coordinate list on axis A is the old list of the axis `permutation(A)`, mirrored about the block centre (v becomes 16 - v in pixels) when the group inverts A. The groups used here:

| Constant | Used as | Permutation | Inverted axes | Effect on a pixel point (x, y, z) |
|---|---|---|---|---|
| `IDENTITY` | none | identity | none | unchanged |
| `ROT_90_Y_NEG` = `BLOCK_ROT_Y_90` | EAST entry | swaps X and Z (`P321`) | X | (16 - z, y, x) |
| `ROT_180_FACE_XZ` = `BLOCK_ROT_Y_180` | SOUTH entry | identity | X and Z | (16 - x, y, 16 - z) |
| `ROT_90_Y_POS` = `BLOCK_ROT_Y_270` | WEST entry | swaps X and Z (`P321`) | Z | (z, y, 16 - x) |
| `ROT_90_X_NEG` = `BLOCK_ROT_X_90` | DOWN entry; part of CEILING | swaps Y and Z (`P132`) | Z | (x, z, 16 - y) |
| `ROT_90_X_POS` = `BLOCK_ROT_X_270` | UP entry; part of FLOOR | swaps Y and Z (`P132`) | Y | (x, 16 - z, y) |
| `INVERT_Y` | the `top` stairs maps | identity | Y | (x, 16 - y, z) |

`Shapes.rotateHorizontal(shape)` returns a map NORTH to the shape as written, EAST to the shape under `BLOCK_ROT_Y_90`, SOUTH under `BLOCK_ROT_Y_180`, WEST under `BLOCK_ROT_Y_270`. EAST is therefore a quarter turn clockwise seen from above, matching `Direction.getClockWise` (a point (x, z) of the north shape maps to (16 - z, x) in the east shape, to (16 - x, 16 - z) in the south shape and to (z, 16 - x) in the west shape; all read). The two-argument form first applies the given group to the shape and then the horizontal turn (the horizontal group is composed with the given one: `BLOCK_ROT_Y_90.compose(group)`). `rotateHorizontalAxis` returns only an axis map: Z is the shape as written and X is the east turn. `rotateAllAxis` returns Z = as written, X = the east turn, Y = the shape under `BLOCK_ROT_X_90`. `rotateAll` returns the four horizontal entries plus UP (`BLOCK_ROT_X_270`) and DOWN (`BLOCK_ROT_X_90`). `rotateAttachFace` returns, per `AttachFace`: WALL = `rotateHorizontal(shape)`, FLOOR = `rotateHorizontal(shape, BLOCK_ROT_X_270)`, CEILING = `rotateHorizontal(shape, BLOCK_ROT_Y_180.compose(BLOCK_ROT_X_90))`.

Worked example for `rotateAttachFace` with the button base box (pixels x 5 to 11, y 6 to 10, z 8 to 16, 6.32), north entry. WALL: unchanged. FLOOR: apply (x, 16 - z, y): the box becomes x 5 to 11, y 0 to 8, z 6 to 10 (a plate on the floor). CEILING: the `compose` is an element of the table; reading the factors as "`BLOCK_ROT_X_90` first, then the half turn about Y", the box becomes y 8 to 16, z 6 to 10, x 5 to 11 (a plate on the ceiling); with the opposite order the box would lie on the floor at y 0 to 8, which contradicts the face name, so the order "X turn first" is taken, and it matches the order used for the horizontal entries above (the given group first, then the horizontal turn). The order inside `OctahedralGroup.compose` was traced through the Cayley table builder (`compose(a, b)` applies b first, then a), confirming this reading.

`StateDefinition`-driven shape tables: `getShapeForEachState(f, ignoredProperties)` evaluates `f` once per state and ignores the listed properties (here only `waterlogged`), so those blocks have one shape per combination of the other properties.

`Properties.noCollision` sets both `hasCollision = false` and `canOcclude = false`; `noOcclusion` sets `canOcclude = false` only. `Properties.strength(a)` is `strength(a, a)`; `strength(h, r)` sets destroy time `h` and explosion resistance `max(0, r)`; `instabreak` is `strength(0)`. A destroy time of -1 is unbreakable.

`Properties.ofLegacyCopy(block)` copies from the block's properties: destroy time, explosion resistance, collision flag, random-tick flag, light function, map colour, sound, friction, speed factor, bounce restitution, dynamic-shape flag, can-occlude, air, ignited-by-lava, liquid, force-solid-off, force-solid-on, push reaction, requires-correct-tool, offset function, terrain-particles flag, required features, emissive predicate, instrument and replaceable. It does **not** copy jump factor, fall-distance reduction, the redstone-conductor, valid-spawn, suffocation and view-blocking predicates, the post-process hook, the drop table and the description id; those keep their `Properties` defaults for the copy.

Defaults of a fresh `Properties`: collision true, sound STONE, light 0, destroy time 0, resistance 0, tool not required, no random ticks, friction 0.6, speed factor 1, jump factor 1, can-occlude true, push reaction PUSH_PULL, terrain particles true, instrument HARP, not replaceable, map colour NONE, valid-spawn = (top face sturdy and light emission below 14), redstone-conductor = collision shape is a full block, suffocating = (state is in tag `causes_suffocation` and its collision shape is a full block), view-blocking = the suffocating predicate, no post-process, not emissive, default loot table `blocks/<block path>`.

## 3. The registry table

Columns: `Ord` is the 0-based position in this part, `Block id` the derived registry index (section 1, item 5), `States` the state count, `First state (relative)` the running offset. Registry keys come from two classes, read from the argument that each `Blocks` field initialiser passes: a `references.BlockItemIds` constant (a `BlockItemId`: a block key and the key of the item that places it, 04 section 5.1 and 24 part 1 section 2.2) or a `references.BlockIds` constant (a block key with no item of its own).

1. `BlockItemIds` constants whose name differs from the field, with the key strings read from `BlockItemIds`' initialiser: `PUMPKIN_STEM` uses `PUMPKIN_CROP` (block `pumpkin_stem`, item `pumpkin_seeds`); `MELON_STEM` uses `MELON_CROP` (block `melon_stem`, item `melon_seeds`); `COCOA` uses `COCOA_CROP` (block `cocoa`, item `cocoa_beans`); `CARROTS` uses `CARROT_CROP` (block `carrots`, item `carrot`); `POTATOES` uses `POTATO_CROP` (block `potatoes`, item `potato`); `TRIPWIRE` uses `TRIPWIRE` (block `tripwire`, item `string`). The same-named constant, with block and item sharing the key, is used by every other `BlockItemIds` field in the range, and the key is the field name in lower case.
2. Fields that use a `BlockIds` constant of the same name as the field and therefore have **no item of their own**: `ATTACHED_PUMPKIN_STEM`, `ATTACHED_MELON_STEM`, `WATER_CAULDRON`, `LAVA_CAULDRON`, `POWDER_SNOW_CAULDRON`, `END_PORTAL`, all 30 `POTTED_*` fields and `SKELETON_WALL_SKULL` (and `WITHER_SKELETON_WALL_SKULL`, index 420). Their key is the field name in lower case. Every other field in the range has a block and an item with the same key except as listed in item 1.
3. The associated item of a block is therefore the item of the same key (item 1 lists the exceptions). Blocks of item 2 have no placing item; the loot table files show that the filled cauldrons drop the item `cauldron` and the potted blocks drop `flower_pot` plus the content item, and the wall skulls share the standing skull's drop table (section 4.1).

The two weathering collections register eight blocks each, in this order: `copper_bars` (unaffected), `exposed_copper_bars`, `weathered_copper_bars`, `oxidized_copper_bars`, `waxed_copper_bars`, `waxed_exposed_copper_bars`, `waxed_weathered_copper_bars`, `waxed_oxidized_copper_bars` (prefixes "", `exposed_`, `weathered_`, `oxidized_`, `waxed_`, `waxed_exposed_`, `waxed_weathered_`, `waxed_oxidized_`, read from `WeatheringCopperCollection.PREFIXES`); the same for `copper_chain`. The four unwaxed blocks use the weathering classes (`WeatheringCopperBarsBlock`, `WeatheringCopperChainBlock`, each constructed with its `WeatherState`), the four waxed blocks use the plain `IronBarsBlock` / `ChainBlock`. All eight use the same properties. The unwaxed blocks are registered first (`registerBlocks` applies the weathering function before the waxed function).

| Ord | Block id | Registry key | Class | States | First state (relative) | Default state |
|---|---|---|---|---|---|---|
| 0 | 390 | `minecraft:mushroom_stem` | `HugeMushroomBlock` | 64 | 0 | all six faces true |
| 1 | 391 | `minecraft:iron_bars` | `IronBarsBlock` | 32 | 64 | all four sides false, waterlogged false |
| 2 | 392 | `minecraft:copper_bars` | `WeatheringCopperBarsBlock` | 32 | 96 | all four sides false, waterlogged false |
| 3 | 393 | `minecraft:exposed_copper_bars` | `WeatheringCopperBarsBlock` | 32 | 128 | all four sides false, waterlogged false |
| 4 | 394 | `minecraft:weathered_copper_bars` | `WeatheringCopperBarsBlock` | 32 | 160 | all four sides false, waterlogged false |
| 5 | 395 | `minecraft:oxidized_copper_bars` | `WeatheringCopperBarsBlock` | 32 | 192 | all four sides false, waterlogged false |
| 6 | 396 | `minecraft:waxed_copper_bars` | `IronBarsBlock` | 32 | 224 | all four sides false, waterlogged false |
| 7 | 397 | `minecraft:waxed_exposed_copper_bars` | `IronBarsBlock` | 32 | 256 | all four sides false, waterlogged false |
| 8 | 398 | `minecraft:waxed_weathered_copper_bars` | `IronBarsBlock` | 32 | 288 | all four sides false, waterlogged false |
| 9 | 399 | `minecraft:waxed_oxidized_copper_bars` | `IronBarsBlock` | 32 | 320 | all four sides false, waterlogged false |
| 10 | 400 | `minecraft:iron_chain` | `ChainBlock` | 6 | 352 | axis y, waterlogged false |
| 11 | 401 | `minecraft:copper_chain` | `WeatheringCopperChainBlock` | 6 | 358 | axis y, waterlogged false |
| 12 | 402 | `minecraft:exposed_copper_chain` | `WeatheringCopperChainBlock` | 6 | 364 | axis y, waterlogged false |
| 13 | 403 | `minecraft:weathered_copper_chain` | `WeatheringCopperChainBlock` | 6 | 370 | axis y, waterlogged false |
| 14 | 404 | `minecraft:oxidized_copper_chain` | `WeatheringCopperChainBlock` | 6 | 376 | axis y, waterlogged false |
| 15 | 405 | `minecraft:waxed_copper_chain` | `ChainBlock` | 6 | 382 | axis y, waterlogged false |
| 16 | 406 | `minecraft:waxed_exposed_copper_chain` | `ChainBlock` | 6 | 388 | axis y, waterlogged false |
| 17 | 407 | `minecraft:waxed_weathered_copper_chain` | `ChainBlock` | 6 | 394 | axis y, waterlogged false |
| 18 | 408 | `minecraft:waxed_oxidized_copper_chain` | `ChainBlock` | 6 | 400 | axis y, waterlogged false |
| 19 | 409 | `minecraft:glass_pane` | `IronBarsBlock` | 32 | 406 | all four sides false, waterlogged false |
| 20 | 410 | `minecraft:pumpkin` | `PumpkinBlock` | 1 | 438 | (none) |
| 21 | 411 | `minecraft:melon` | `Block` | 1 | 439 | (none) |
| 22 | 412 | `minecraft:attached_pumpkin_stem` | `AttachedStemBlock` | 4 | 440 | facing north |
| 23 | 413 | `minecraft:attached_melon_stem` | `AttachedStemBlock` | 4 | 444 | facing north |
| 24 | 414 | `minecraft:pumpkin_stem` | `StemBlock` | 8 | 448 | age 0 |
| 25 | 415 | `minecraft:melon_stem` | `StemBlock` | 8 | 456 | age 0 |
| 26 | 416 | `minecraft:vine` | `VineBlock` | 32 | 464 | all five false |
| 27 | 417 | `minecraft:glow_lichen` | `GlowLichenBlock` | 128 | 496 | all faces false, waterlogged false |
| 28 | 418 | `minecraft:resin_clump` | `MultifaceBlock` | 128 | 624 | all faces false, waterlogged false |
| 29 | 419 | `minecraft:oak_fence_gate` | `FenceGateBlock` | 32 | 752 | facing north, open false, powered false, in_wall false |
| 30 | 420 | `minecraft:brick_stairs` | `StairBlock` | 80 | 784 | facing north, half bottom, shape straight, waterlogged false |
| 31 | 421 | `minecraft:stone_brick_stairs` | `StairBlock` | 80 | 864 | facing north, half bottom, shape straight, waterlogged false |
| 32 | 422 | `minecraft:mud_brick_stairs` | `StairBlock` | 80 | 944 | facing north, half bottom, shape straight, waterlogged false |
| 33 | 423 | `minecraft:mycelium` | `MyceliumBlock` | 2 | 1024 | snowy false |
| 34 | 424 | `minecraft:lily_pad` | `LilyPadBlock` | 1 | 1026 | (none) |
| 35 | 425 | `minecraft:resin_block` | `Block` | 1 | 1027 | (none) |
| 36 | 426 | `minecraft:resin_bricks` | `Block` | 1 | 1028 | (none) |
| 37 | 427 | `minecraft:resin_brick_stairs` | `StairBlock` | 80 | 1029 | facing north, half bottom, shape straight, waterlogged false |
| 38 | 428 | `minecraft:resin_brick_slab` | `SlabBlock` | 6 | 1109 | type bottom, waterlogged false |
| 39 | 429 | `minecraft:resin_brick_wall` | `WallBlock` | 324 | 1115 | up true, four sides none, waterlogged false |
| 40 | 430 | `minecraft:chiseled_resin_bricks` | `Block` | 1 | 1439 | (none) |
| 41 | 431 | `minecraft:nether_bricks` | `Block` | 1 | 1440 | (none) |
| 42 | 432 | `minecraft:nether_brick_fence` | `FenceBlock` | 32 | 1441 | all four sides false, waterlogged false |
| 43 | 433 | `minecraft:nether_brick_stairs` | `StairBlock` | 80 | 1473 | facing north, half bottom, shape straight, waterlogged false |
| 44 | 434 | `minecraft:nether_wart` | `NetherWartBlock` | 4 | 1553 | age 0 |
| 45 | 435 | `minecraft:enchanting_table` | `EnchantingTableBlock` | 1 | 1557 | (none) |
| 46 | 436 | `minecraft:brewing_stand` | `BrewingStandBlock` | 8 | 1558 | has_bottle_0..2 all false |
| 47 | 437 | `minecraft:cauldron` | `CauldronBlock` | 1 | 1566 | (none) |
| 48 | 438 | `minecraft:water_cauldron` | `LayeredCauldronBlock` | 3 | 1567 | level 1 |
| 49 | 439 | `minecraft:lava_cauldron` | `LavaCauldronBlock` | 1 | 1570 | (none) |
| 50 | 440 | `minecraft:powder_snow_cauldron` | `LayeredCauldronBlock` | 3 | 1571 | level 1 |
| 51 | 441 | `minecraft:end_portal` | `EndPortalBlock` | 1 | 1574 | (none) |
| 52 | 442 | `minecraft:end_portal_frame` | `EndPortalFrameBlock` | 8 | 1575 | facing north, eye false |
| 53 | 443 | `minecraft:end_stone` | `Block` | 1 | 1583 | (none) |
| 54 | 444 | `minecraft:dragon_egg` | `DragonEggBlock` | 1 | 1584 | (none) |
| 55 | 445 | `minecraft:redstone_lamp` | `RedstoneLampBlock` | 2 | 1585 | lit false |
| 56 | 446 | `minecraft:cocoa` | `CocoaBlock` | 12 | 1587 | facing north, age 0 |
| 57 | 447 | `minecraft:shelf_mushroom` | `ShelfMushroomBlock` | 8 | 1599 | facing north, age 0 |
| 58 | 448 | `minecraft:sandstone_stairs` | `StairBlock` | 80 | 1607 | facing north, half bottom, shape straight, waterlogged false |
| 59 | 449 | `minecraft:emerald_ore` | `DropExperienceBlock` | 1 | 1687 | (none) |
| 60 | 450 | `minecraft:deepslate_emerald_ore` | `DropExperienceBlock` | 1 | 1688 | (none) |
| 61 | 451 | `minecraft:ender_chest` | `EnderChestBlock` | 8 | 1689 | facing north, waterlogged false |
| 62 | 452 | `minecraft:tripwire_hook` | `TripWireHookBlock` | 16 | 1697 | facing north, powered false, attached false |
| 63 | 453 | `minecraft:tripwire` | `TripWireBlock` | 128 | 1713 | all seven false |
| 64 | 454 | `minecraft:emerald_block` | `Block` | 1 | 1841 | (none) |
| 65 | 455 | `minecraft:spruce_stairs` | `StairBlock` | 80 | 1842 | facing north, half bottom, shape straight, waterlogged false |
| 66 | 456 | `minecraft:birch_stairs` | `StairBlock` | 80 | 1922 | facing north, half bottom, shape straight, waterlogged false |
| 67 | 457 | `minecraft:jungle_stairs` | `StairBlock` | 80 | 2002 | facing north, half bottom, shape straight, waterlogged false |
| 68 | 458 | `minecraft:command_block` | `CommandBlock` | 12 | 2082 | facing north, conditional false |
| 69 | 459 | `minecraft:beacon` | `BeaconBlock` | 1 | 2094 | (none) |
| 70 | 460 | `minecraft:cobblestone_wall` | `WallBlock` | 324 | 2095 | up true, four sides none, waterlogged false |
| 71 | 461 | `minecraft:mossy_cobblestone_wall` | `WallBlock` | 324 | 2419 | up true, four sides none, waterlogged false |
| 72 | 462 | `minecraft:flower_pot` | `FlowerPotBlock` | 1 | 2743 | (none) |
| 73 | 463 | `minecraft:potted_torchflower` | `FlowerPotBlock` | 1 | 2744 | (none) |
| 74 | 464 | `minecraft:potted_oak_sapling` | `FlowerPotBlock` | 1 | 2745 | (none) |
| 75 | 465 | `minecraft:potted_spruce_sapling` | `FlowerPotBlock` | 1 | 2746 | (none) |
| 76 | 466 | `minecraft:potted_birch_sapling` | `FlowerPotBlock` | 1 | 2747 | (none) |
| 77 | 467 | `minecraft:potted_jungle_sapling` | `FlowerPotBlock` | 1 | 2748 | (none) |
| 78 | 468 | `minecraft:potted_acacia_sapling` | `FlowerPotBlock` | 1 | 2749 | (none) |
| 79 | 469 | `minecraft:potted_cherry_sapling` | `FlowerPotBlock` | 1 | 2750 | (none) |
| 80 | 470 | `minecraft:potted_dark_oak_sapling` | `FlowerPotBlock` | 1 | 2751 | (none) |
| 81 | 471 | `minecraft:potted_pale_oak_sapling` | `FlowerPotBlock` | 1 | 2752 | (none) |
| 82 | 472 | `minecraft:potted_poplar_sapling` | `FlowerPotBlock` | 1 | 2753 | (none) |
| 83 | 473 | `minecraft:potted_mangrove_propagule` | `FlowerPotBlock` | 1 | 2754 | (none) |
| 84 | 474 | `minecraft:potted_fern` | `FlowerPotBlock` | 1 | 2755 | (none) |
| 85 | 475 | `minecraft:potted_dandelion` | `FlowerPotBlock` | 1 | 2756 | (none) |
| 86 | 476 | `minecraft:potted_golden_dandelion` | `FlowerPotBlock` | 1 | 2757 | (none) |
| 87 | 477 | `minecraft:potted_poppy` | `FlowerPotBlock` | 1 | 2758 | (none) |
| 88 | 478 | `minecraft:potted_blue_orchid` | `FlowerPotBlock` | 1 | 2759 | (none) |
| 89 | 479 | `minecraft:potted_allium` | `FlowerPotBlock` | 1 | 2760 | (none) |
| 90 | 480 | `minecraft:potted_azure_bluet` | `FlowerPotBlock` | 1 | 2761 | (none) |
| 91 | 481 | `minecraft:potted_red_tulip` | `FlowerPotBlock` | 1 | 2762 | (none) |
| 92 | 482 | `minecraft:potted_orange_tulip` | `FlowerPotBlock` | 1 | 2763 | (none) |
| 93 | 483 | `minecraft:potted_white_tulip` | `FlowerPotBlock` | 1 | 2764 | (none) |
| 94 | 484 | `minecraft:potted_pink_tulip` | `FlowerPotBlock` | 1 | 2765 | (none) |
| 95 | 485 | `minecraft:potted_oxeye_daisy` | `FlowerPotBlock` | 1 | 2766 | (none) |
| 96 | 486 | `minecraft:potted_cornflower` | `FlowerPotBlock` | 1 | 2767 | (none) |
| 97 | 487 | `minecraft:potted_lily_of_the_valley` | `FlowerPotBlock` | 1 | 2768 | (none) |
| 98 | 488 | `minecraft:potted_wither_rose` | `FlowerPotBlock` | 1 | 2769 | (none) |
| 99 | 489 | `minecraft:potted_red_mushroom` | `FlowerPotBlock` | 1 | 2770 | (none) |
| 100 | 490 | `minecraft:potted_brown_mushroom` | `FlowerPotBlock` | 1 | 2771 | (none) |
| 101 | 491 | `minecraft:potted_dead_bush` | `FlowerPotBlock` | 1 | 2772 | (none) |
| 102 | 492 | `minecraft:potted_cactus` | `FlowerPotBlock` | 1 | 2773 | (none) |
| 103 | 493 | `minecraft:carrots` | `CarrotBlock` | 8 | 2774 | age 0 |
| 104 | 494 | `minecraft:potatoes` | `PotatoBlock` | 8 | 2782 | age 0 |
| 105 | 495 | `minecraft:oak_button` | `ButtonBlock` | 24 | 2790 | facing north, powered false, face wall |
| 106 | 496 | `minecraft:spruce_button` | `ButtonBlock` | 24 | 2814 | facing north, powered false, face wall |
| 107 | 497 | `minecraft:birch_button` | `ButtonBlock` | 24 | 2838 | facing north, powered false, face wall |
| 108 | 498 | `minecraft:jungle_button` | `ButtonBlock` | 24 | 2862 | facing north, powered false, face wall |
| 109 | 499 | `minecraft:acacia_button` | `ButtonBlock` | 24 | 2886 | facing north, powered false, face wall |
| 110 | 500 | `minecraft:cherry_button` | `ButtonBlock` | 24 | 2910 | facing north, powered false, face wall |
| 111 | 501 | `minecraft:dark_oak_button` | `ButtonBlock` | 24 | 2934 | facing north, powered false, face wall |
| 112 | 502 | `minecraft:pale_oak_button` | `ButtonBlock` | 24 | 2958 | facing north, powered false, face wall |
| 113 | 503 | `minecraft:mangrove_button` | `ButtonBlock` | 24 | 2982 | facing north, powered false, face wall |
| 114 | 504 | `minecraft:poplar_button` | `ButtonBlock` | 24 | 3006 | facing north, powered false, face wall |
| 115 | 505 | `minecraft:bamboo_button` | `ButtonBlock` | 24 | 3030 | facing north, powered false, face wall |
| 116 | 506 | `minecraft:skeleton_skull` | `SkullBlock` | 32 | 3054 | rotation 0, powered false |
| 117 | 507 | `minecraft:skeleton_wall_skull` | `WallSkullBlock` | 8 | 3086 | facing north, powered false |
| 118 | 508 | `minecraft:wither_skeleton_skull` | `WitherSkullBlock` | 32 | 3094 | rotation 0, powered false |
| 119 | 509 | `minecraft:wither_skeleton_wall_skull` | `WitherWallSkullBlock` | 8 | 3126 | facing north, powered false |

Totals: 119 blocks in the range (ids 390 to 508) with 3126 states (relative first states 0 to 3125); the appendix row `wither_skeleton_wall_skull` (id 509) adds 8 states, relative first state 3126.

## 4. Material and strength properties

This table is the `Properties` chain of each field, resolved through `ofLegacyCopy` and the helper methods (`buttonProperties`, `flowerPotProperties`, `wallVariant`, `registerLegacyStair`, `registerWall`, `registerSlab`). Light is the `lightLevel` value (a constant function unless stated). "Other flags": `lava` = `ignitedByLava`, `noCollision` includes the implied no-occlusion. Map colours, instruments and sounds are names of `MapColor`, `NoteBlockInstrument` and `SoundType` constants whose tables belong to part 1. The stairs rows copy from their base block (`BRICKS`, `STONE_BRICKS`, `MUD_BRICKS`, `RESIN_BRICKS`, `NETHER_BRICKS`, `SANDSTONE`, `SPRUCE_PLANKS`, `BIRCH_PLANKS`, `JUNGLE_PLANKS`) and then replace the view-blocking predicate; the values shown are the base block's values as read from the base block's own `Properties` chain.

| Field | mapColor | instrument | hardness | resistance | needs tool | sound | light | push reaction | other flags |
|---|---|---|---|---|---|---|---|---|---|
| `MUSHROOM_STEM` | WOOL | BASS | 0.2 | 0.2 | no | WOOD | 0 | PUSH_PULL | lava |
| `IRON_BARS` | NONE | HARP | 5 | 6 | yes | IRON | 0 | PUSH_PULL | noOcclusion |
| `IRON_CHAIN` | NONE | HARP | 5 | 6 | yes | CHAIN | 0 | PUSH_PULL | noOcclusion, forceSolidOn |
| `GLASS_PANE` | NONE | HAT | 0.3 | 0.3 | no | GLASS | 0 | PUSH_PULL | noOcclusion |
| `PUMPKIN` | COLOR_ORANGE | DIDGERIDOO | 1 | 1 | no | WOOD | 0 | POPPED | - |
| `MELON` | COLOR_LIGHT_GREEN | HARP | 1 | 1 | no | WOOD | 0 | POPPED | - |
| `ATTACHED_PUMPKIN_STEM` | PLANT | HARP | 0 | 0 | no | WOOD | 0 | POPPED | noCollision(also no occlude) |
| `ATTACHED_MELON_STEM` | PLANT | HARP | 0 | 0 | no | WOOD | 0 | POPPED | noCollision(also no occlude) |
| `PUMPKIN_STEM` | PLANT | HARP | 0 | 0 | no | HARD_CROP | 0 | POPPED | noCollision(also no occlude), randomTicks |
| `MELON_STEM` | PLANT | HARP | 0 | 0 | no | HARD_CROP | 0 | POPPED | noCollision(also no occlude), randomTicks |
| `VINE` | PLANT | HARP | 0.2 | 0.2 | no | VINE | 0 | POPPED | noCollision(also no occlude), randomTicks, lava, replaceable |
| `GLOW_LICHEN` | GLOW_LICHEN | HARP | 0.2 | 0.2 | no | GLOW_LICHEN | 7 if any face is set, else 0 | POPPED | noCollision(also no occlude), lava, replaceable |
| `RESIN_CLUMP` | TERRACOTTA_ORANGE | HARP | 0 | 0 | no | RESIN | 0 | POPPED | noCollision(also no occlude), lava, replaceable |
| `OAK_FENCE_GATE` | WOOD | BASS | 2 | 3 | no | WOOD (read: `WoodType.OAK` is built by the two-argument `WoodType` constructor, which passes `SoundType.WOOD`; the gate's constructor then applies it) | 0 | PUSH_PULL | lava, forceSolidOn |
| `BRICK_STAIRS` | COLOR_RED | BASEDRUM | 2 | 6 | yes | STONE | 0 | PUSH_PULL | isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `STONE_BRICK_STAIRS` | STONE | BASEDRUM | 1.5 | 6 | yes | STONE | 0 | PUSH_PULL | isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `MUD_BRICK_STAIRS` | TERRACOTTA_LIGHT_GRAY | BASEDRUM | 1.5 | 3 | yes | MUD_BRICKS | 0 | PUSH_PULL | isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `MYCELIUM` | COLOR_PURPLE | HARP | 0.6 | 0.6 | no | GRASS | 0 | PUSH_PULL | randomTicks |
| `LILY_PAD` | PLANT | HARP | 0 | 0 | no | LILY_PAD | 0 | POPPED | noOcclusion |
| `RESIN_BLOCK` | TERRACOTTA_ORANGE | BASEDRUM | 0 | 0 | no | RESIN | 0 | PUSH_PULL | - |
| `RESIN_BRICKS` | TERRACOTTA_ORANGE | BASEDRUM | 1.5 | 6 | yes | RESIN_BRICKS | 0 | PUSH_PULL | - |
| `RESIN_BRICK_STAIRS` | TERRACOTTA_ORANGE | BASEDRUM | 1.5 | 6 | yes | RESIN_BRICKS | 0 | PUSH_PULL | isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `RESIN_BRICK_SLAB` | TERRACOTTA_ORANGE | BASEDRUM | 1.5 | 6 | yes | RESIN_BRICKS | 0 | PUSH_PULL | isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `RESIN_BRICK_WALL` | TERRACOTTA_ORANGE | BASEDRUM | 1.5 | 6 | yes | RESIN_BRICKS | 0 | PUSH_PULL | forceSolidOn |
| `CHISELED_RESIN_BRICKS` | TERRACOTTA_ORANGE | BASEDRUM | 1.5 | 6 | yes | RESIN_BRICKS | 0 | PUSH_PULL | - |
| `NETHER_BRICKS` | NETHER | BASEDRUM | 2 | 6 | yes | NETHER_BRICKS | 0 | PUSH_PULL | - |
| `NETHER_BRICK_FENCE` | NETHER | BASEDRUM | 2 | 6 | yes | NETHER_BRICKS | 0 | PUSH_PULL | - |
| `NETHER_BRICK_STAIRS` | NETHER | BASEDRUM | 2 | 6 | yes | NETHER_BRICKS | 0 | PUSH_PULL | isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `NETHER_WART` | COLOR_RED | HARP | 0 | 0 | no | NETHER_WART | 0 | POPPED | noCollision(also no occlude), randomTicks |
| `ENCHANTING_TABLE` | COLOR_RED | BASEDRUM | 5 | 1200 | yes | STONE | 7 | PUSH_PULL | - |
| `BREWING_STAND` | METAL | HARP | 0.5 | 0.5 | no | STONE | 1 | PUSH_PULL | noOcclusion |
| `CAULDRON` | STONE | HARP | 2 | 2 | yes | STONE | 0 | PUSH_PULL | noOcclusion |
| `WATER_CAULDRON` | STONE | HARP | 2 | 2 | yes | STONE | 0 | PUSH_PULL | noOcclusion |
| `LAVA_CAULDRON` | STONE | HARP | 2 | 2 | yes | STONE | 15 | PUSH_PULL | noOcclusion |
| `POWDER_SNOW_CAULDRON` | STONE | HARP | 2 | 2 | yes | STONE | 0 | PUSH_PULL | noOcclusion |
| `END_PORTAL` | COLOR_BLACK | HARP | -1 | 3.6e+06 | no | STONE | 15 | IMMOVEABLE | noCollision(also no occlude); no loot table |
| `END_PORTAL_FRAME` | COLOR_GREEN | BASEDRUM | -1 | 3.6e+06 | no | GLASS | 1 | PUSH_PULL | no loot table |
| `END_STONE` | SAND | BASEDRUM | 3 | 9 | yes | STONE | 0 | PUSH_PULL | - |
| `DRAGON_EGG` | COLOR_BLACK | HARP | 3 | 9 | no | STONE | 1 | POPPED | noOcclusion |
| `REDSTONE_LAMP` | TERRACOTTA_ORANGE | HARP | 0.3 | 0.3 | no | GLASS | 15 if lit, else 0 | PUSH_PULL | isValidSpawn(always) |
| `COCOA` | PLANT | HARP | 0.2 | 3 | no | WOOD | 0 | POPPED | noOcclusion, randomTicks |
| `SHELF_MUSHROOM` | TERRACOTTA_YELLOW | HARP | 0 | 0 | no | SHELF_MUSHROOM | 0 | POPPED | noOcclusion; bounceRestitution(0.75f);fallDistanceReduction(0.5f) |
| `SANDSTONE_STAIRS` | SAND | BASEDRUM | 0.8 | 0.8 | yes | STONE | 0 | PUSH_PULL | isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `EMERALD_ORE` | STONE | BASEDRUM | 3 | 3 | yes | STONE | 0 | PUSH_PULL | - |
| `DEEPSLATE_EMERALD_ORE` | DEEPSLATE | BASEDRUM | 4.5 | 3 | yes | DEEPSLATE | 0 | PUSH_PULL | - |
| `ENDER_CHEST` | STONE | BASEDRUM | 22.5 | 600 | no | STONE | 7 | PUSH_PULL | - |
| `TRIPWIRE_HOOK` | NONE | HARP | 0 | 0 | no | WOOD | 0 | POPPED | noCollision(also no occlude) |
| `TRIPWIRE` | NONE | HARP | 0 | 0 | no | STONE | 0 | POPPED | noCollision(also no occlude) |
| `EMERALD_BLOCK` | EMERALD | BIT | 5 | 6 | yes | METAL | 0 | PUSH_PULL | - |
| `SPRUCE_STAIRS` | PODZOL | BASS | 2 | 3 | no | WOOD | 0 | PUSH_PULL | lava; isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `BIRCH_STAIRS` | SAND | BASS | 2 | 3 | no | WOOD | 0 | PUSH_PULL | lava; isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `JUNGLE_STAIRS` | DIRT | BASS | 2 | 3 | no | WOOD | 0 | PUSH_PULL | lava; isViewBlocking = NEAR_PLANE_INTERSECTS_OUTLINE |
| `COMMAND_BLOCK` | COLOR_BROWN | HARP | -1 | 3.6e+06 | yes | STONE | 0 | PUSH_PULL | no loot table |
| `BEACON` | DIAMOND | HAT | 3 | 3 | no | STONE | 15 | PUSH_PULL | noOcclusion; isRedstoneConductor(never) |
| `COBBLESTONE_WALL` | STONE | BASEDRUM | 2 | 6 | yes | STONE | 0 | PUSH_PULL | forceSolidOn |
| `MOSSY_COBBLESTONE_WALL` | STONE | BASEDRUM | 2 | 6 | yes | STONE | 0 | PUSH_PULL | forceSolidOn |
| `FLOWER_POT` and all 30 `POTTED_*` | NONE | HARP | 0 | 0 | no | STONE | 0 | POPPED | noOcclusion |
| `CARROTS` | PLANT | HARP | 0 | 0 | no | CROP | 0 | POPPED | noCollision(also no occlude), randomTicks |
| `POTATOES` | PLANT | HARP | 0 | 0 | no | CROP | 0 | POPPED | noCollision(also no occlude), randomTicks |
| all 11 `*_BUTTON` | NONE | HARP | 0.5 | 0.5 | no | BlockSetType sound (WOOD; CHERRY_WOOD for cherry; BAMBOO_WOOD for bamboo) | 0 | POPPED | noCollision(also no occlude) |
| `SKELETON_SKULL` | NONE | SKELETON | 1 | 1 | no | STONE | 0 | POPPED | noOcclusion |
| `SKELETON_WALL_SKULL` | NONE | HARP | 1 | 1 | no | STONE | 0 | POPPED | wall variant of (SKELETON_SKULL) |
| `WITHER_SKELETON_SKULL` | NONE | WITHER_SKELETON | 1 | 1 | no | STONE | 0 | POPPED | noOcclusion |
| `WITHER_SKELETON_WALL_SKULL` | NONE | HARP | 1 | 1 | no | STONE | 0 | POPPED | wall variant of (WITHER_SKELETON_SKULL) |

Rows not covered by the table because the collection builds them:

| Field | mapColor | instrument | hardness | resistance | needs tool | sound | other |
|---|---|---|---|---|---|---|---|
| `COPPER_BARS` (8 blocks) | NONE | HARP | 5 | 6 | yes | COPPER | noOcclusion |
| `COPPER_CHAIN` (8 blocks) | NONE | HARP | 5 | 6 | yes | CHAIN | noOcclusion, forceSolidOn |

Notes on specific rows:

- Walls: `registerWall` is `ofLegacyCopy(base).forceSolidOn()`; `MOSSY_COBBLESTONE_WALL` copies `COBBLESTONE` (not a mossy block), so both walls have the same strength.
- Slabs and stairs call `isViewBlocking(NEAR_PLANE_INTERSECTS_OUTLINE)`. That predicate (a `Blocks` lambda) is true when any box of the state's occlusion shape, moved to the block position, intersects the test box it is given.
- `*_CAULDRON` blocks other than the empty one copy `CAULDRON` (`ofLegacyCopy`), the lava cauldron then sets light 15.
- `END_PORTAL` and `END_PORTAL_FRAME` have no loot table. `COMMAND_BLOCK` has no loot table and `requiresCorrectToolForDrops`.
- Wall skulls use `wallVariant(skull, true)`: a fresh `Properties` whose drop table is the base skull's drop table and whose description id is the base skull's, then `strength(1)` and `pushReaction(POPPED)`. A wall skull therefore has instrument HARP and does not clear `canOcclude`.
- `SHELF_MUSHROOM` also sets bounce restitution 0.75 and fall-distance reduction 0.5.
- The 11 buttons use `buttonProperties` and then `ButtonBlock`'s constructor replaces the sound with the block set type's sound type (`BlockSetType.soundType`): WOOD for oak, spruce, birch, acacia, jungle, dark oak, pale oak, poplar and mangrove; CHERRY_WOOD for cherry; BAMBOO_WOOD for bamboo. `OAK_FENCE_GATE` likewise has its sound replaced by the wood type's sound type.

### 4.1 Derived per-block columns (friction, tint, loot, item, tool, burn, occlusion)

These columns are given per group because every block of a group has the same value. Sources: the `Properties` chains of section 4 (friction, speed factor, jump factor, `canOcclude`), `BlockColors.createDefault` (tint, shared with 24 part 1 section 9), the data files of the archive (tool tags and loot tables), `FireBlock.bootStrap` (burn) and the shape methods of `BlockBehaviour` and the block classes (occlusion).

Friction, speed factor and jump factor. A scan of every `Properties` call in the static initialiser between `MUSHROOM_STEM` and `WITHER_SKELETON_WALL_SKULL`, and of the helpers `buttonProperties`, `flowerPotProperties`, `registerLegacyStair`, `registerSlab`, `registerWall` and `wallVariant`, finds **no** call of `friction`, `speedFactor` or `jumpFactor`. In the whole initialiser those methods are called only for `ICE`, `SLIME_BLOCK`, `PACKED_ICE`, `FROSTED_ICE`, `BLUE_ICE` (friction), `SOUL_SAND` (speed factor) and `HONEY_BLOCK` (speed factor and jump factor). Every block of this part therefore has friction 0.6, speed factor 1 and jump factor 1 (the defaults of section 2.4); the stairs copy from base blocks (`BRICKS`, `STONE_BRICKS`, `MUD_BRICKS`, `RESIN_BRICKS`, `NETHER_BRICKS`, `SANDSTONE`, `SPRUCE_PLANKS`, `BIRCH_PLANKS`, `JUNGLE_PLANKS`) that are not in the list above. The only movement-related override is the `SHELF_MUSHROOM` bounce (restitution 0.75, fall-distance reduction 0.5, section 6.24); that is not a friction, speed or jump factor.

Tint class (24 part 1 section 9 holds the tint sources): `VINE` uses the foliage source; `PUMPKIN_STEM` and `MELON_STEM` use the stem source (state dependent on `age`); `ATTACHED_PUMPKIN_STEM` and `ATTACHED_MELON_STEM` a constant colour 0xFFE0C71C; `LILY_PAD` a constant (0xFF71C35C in hand, 0xFF208030 in the world); `WATER_CAULDRON` the water source; `POTTED_FERN` the grass source. The scan of the block list of `BlockColors.createDefault` against this range finds exactly these eight fields; every other block here, including `MYCELIUM`, `GLASS_PANE`, `GLOW_LICHEN` and all other stems, has no tint source.

| Blocks | Loot table (file `loot_table/blocks/<key>.json` unless noted; data) | Tool tag and tier (data) | Burn (ignite, burn; `FireBlock.bootStrap`, 17 section 3.3a) | Occlusion shape (per state) |
|---|---|---|---|---|
| `mushroom_stem` | exists; drops only with silk touch | `mineable/axe`, no tool required | none | full block, so it occludes |
| `iron_bars`, 8 copper bars | exists; always drops itself (survives-explosion condition) | `mineable/pickaxe`, tool required, no `needs_*_tool` tag | none | none: `canOcclude` is false (`noOcclusion`), so the occlusion shape is empty |
| `iron_chain`, 8 copper chains | exists; always drops itself | `mineable/pickaxe`, tool required, no `needs_*_tool` tag | none | empty (`noOcclusion`) |
| `glass_pane` | exists; drops only with silk touch | none (not tool-gated) | none | empty (`noOcclusion`) |
| `pumpkin`, `melon` | exist; pumpkin always drops itself, melon drops slices or the block with silk touch | `mineable/axe` and `sword_efficient` (data file `tags/block/sword_efficient.json`), no tool required | none | full block |
| `attached_pumpkin_stem`, `attached_melon_stem`, `pumpkin_stem`, `melon_stem` | exist; seeds with a count that depends on `age` for the stems and a fixed binomial for the attached stems (the formulas are data) | none | none | empty (`noCollision` implies `canOcclude` false) |
| `vine` | exists; drops itself only when the tool can shear | `mineable/axe`; also the shears tags `shears_minor_breaking_speed` and `sword_efficient`; no tool required | (15, 100) | empty |
| `glow_lichen` | exists; shears-dependent count | `mineable/axe`, `shears_minor_breaking_speed`, `sword_efficient` | (15, 100) | empty |
| `resin_clump` | exists; count by faces (data) | none | none | empty |
| `oak_fence_gate` | exists; drops itself | `mineable/axe` | (5, 20) | `SHAPE_OCCLUSION` of 6.9 (two posts; moved down 3 pixels when `in_wall`); this is an override, not the outline |
| `brick_stairs`, `stone_brick_stairs`, `mud_brick_stairs`, `resin_brick_stairs`, `nether_brick_stairs`, `sandstone_stairs` | exist; drop themselves | `mineable/pickaxe`, tool required, no `needs_*_tool` tag | none | the stairs outline of 6.10 (default rule: the occlusion shape is the state's shape; `useShapeForLightOcclusion` is true) |
| `spruce_stairs`, `birch_stairs`, `jungle_stairs` | exist; drop themselves | `mineable/axe`, no tool required | (5, 20) | the stairs outline of 6.10 |
| `mycelium` | exists; silk touch gives the block, otherwise dirt (data) | `mineable/shovel` | none | full block |
| `lily_pad` | exists; always drops itself | none | none | empty (`noOcclusion`) |
| `resin_block` | exists | none | none | full block |
| `resin_bricks`, `chiseled_resin_bricks`, `resin_brick_stairs`, `resin_brick_slab`, `resin_brick_wall` | exist | `mineable/pickaxe`, tool required, no `needs_*_tool` tag | none | full block for the two plain blocks; outline of the class for the stairs, slab (`bottom`, `top`, `double`) and wall |
| `nether_bricks`, `nether_brick_fence` | exist | `mineable/pickaxe`, tool required, no `needs_*_tool` tag | none | full block; the fence uses the override of 6.3 (post `column(4, 0, 16)`, arms `boxZ(2, 6, 15, 0, 8)`) |
| `nether_wart` | exists; count by `age` | none | none | empty |
| `enchanting_table` | exists; copies the custom name from the block entity | `mineable/pickaxe`, tool required | none | the table outline (default rule; `useShapeForLightOcclusion`) |
| `brewing_stand` | exists; copies the custom name | `mineable/pickaxe` | none | empty (`noOcclusion`) |
| 4 cauldrons | exist; all four drop the item `cauldron` | `mineable/pickaxe`, tool required | none | empty (`noOcclusion`) |
| `end_portal`, `end_portal_frame`, `command_block` | **no loot table file** (`noLootTable`) | `end_portal` and `end_portal_frame`: none; `command_block`: none (unbreakable) | none | `end_portal` empty (no collision); `end_portal_frame` its outline (`useShapeForLightOcclusion`); `command_block` full block |
| `end_stone` | exists | `mineable/pickaxe`, tool required | none | full block |
| `dragon_egg` | exists; always drops itself (no explosion condition) | none | none | empty (`noOcclusion`) |
| `redstone_lamp` | exists | none | none | full block |
| `cocoa` | exists; 3 beans at age 2 (data) | `mineable/axe`, `sword_efficient` | none | empty (`noOcclusion`) |
| `shelf_mushroom` | exists; count by `age` | none | none | empty (`noOcclusion`) |
| `emerald_ore`, `deepslate_emerald_ore` | exist; silk touch gives the ore block, otherwise the item `emerald` (the count modifier is data) | `mineable/pickaxe`, `needs_iron_tool` | none | full block |
| `emerald_block` | exists | `mineable/pickaxe`, `needs_iron_tool` | none | full block |
| `ender_chest` | exists; silk touch or obsidian (data) | `mineable/pickaxe` | none | the chest outline `column(14, 0, 14)` (default rule) |
| `tripwire_hook`, `tripwire` | exist; the hook drops itself, the tripwire drops `string` | none | none | empty |
| `beacon` | exists; copies the custom name | none | none | empty (`noOcclusion`) |
| `cobblestone_wall`, `mossy_cobblestone_wall` | exist | `mineable/pickaxe`, tool required | none | the wall outline of 6.12 |
| `flower_pot`, 30 `potted_*` | exist; the pot drops `flower_pot`, a potted block drops `flower_pot` and the content item | none | none | empty (`noOcclusion`) |
| `carrots`, `potatoes` | exist; age dependent counts (data) | none | none | empty |
| 11 buttons | exist; drop themselves | `mineable/axe` | none | empty (`noCollision`) |
| `skeleton_skull`, `wither_skeleton_skull` | exist; copy the custom name | none | none | empty (`noOcclusion`) |
| `skeleton_wall_skull` (and index 420, `wither_skeleton_wall_skull`) | **no file of its own**: the wall variant overrides its drop table with the standing skull's table, key `blocks/skeleton_skull` (`blocks/wither_skeleton_skull`) | none | none | the wall skull outline of 6.33 (the wall variant does not clear `canOcclude`) |

Notes. (1) "Tool required" is the `requiresCorrectToolForDrops` flag of section 4; a block that needs a tool but is in no `needs_*_tool` tag has no tier gate beyond the `incorrect_for_*_tool` tags (24 part 1 section 12.2 and 17 Appendix A); `needs_stone_tool` and `needs_diamond_tool` contain none of the blocks of this part, `needs_iron_tool` contains exactly the two emerald ores and the emerald block. (2) `mineable/hoe` contains none of these blocks. (3) The default occlusion shape of `BlockBehaviour.getOcclusionShape` is the state's own shape; it is replaced by the empty shape when `canOcclude` is false, and only `FenceBlock` and `FenceGateBlock` of the classes in this part override it. (4) The default support shape is the state's collision shape; `FenceGateBlock` overrides it (6.9). (5) Tag membership was read from the data files and is exact for the registry keys of this part; the extraction tool is the authority for the data (Open question 12).

## 5. Rules shared by several classes

### 5.1 Waterlogging

`IronBarsBlock`, `FenceBlock`, `ChainBlock`, `WallBlock`, `StairBlock`, `SlabBlock`, `MultifaceBlock` (and so glow lichen and resin clump) and `EnderChestBlock` carry the `waterlogged` property. For all of them:

1. The fluid state of a waterlogged state is the water source (not falling); otherwise it is the block's normal fluid state (empty).
2. When the state is waterlogged and a neighbour update (`updateShape`) reaches the block, a water tick is scheduled at the position with delay `Fluids.WATER.getTickDelay(level)`.
3. Placement sets `waterlogged` true when the fluid at the clicked position is water (`FluidState.is(Fluids.WATER)`). Slab placement into an existing slab (making a double slab) sets it to false. The multiface placement path sets it when the existing fluid is a water source.
4. `propagatesSkylightDown` is `!waterlogged` for the cross-collision blocks (iron bars, glass panes, fences, copper bars) and for walls. Glow lichen and vegetation-derived blocks (lily pad, nether wart, stems, crops) use "the state's fluid state is empty". Vines return true unconditionally.
5. The `SimpleWaterloggedBlock` methods (read in the interface; the blocks above use the defaults unless 6.11 says otherwise): `canPlaceLiquid(fluid)` is true exactly when the fluid is water (the current `waterlogged` value is not consulted there); `placeLiquid(level, pos, state, fluidState)` does nothing and returns false when the state is already waterlogged or the fluid is not water; otherwise, on the server only, it sets `waterlogged` true (`setBlockAndUpdate`) and schedules a fluid tick at the position with delay `fluid.getTickDelay(level)`, and in both server and client cases returns true; `pickupBlock` returns an empty stack when the state is not waterlogged, otherwise sets `waterlogged` false, destroys the block with drops if the new state cannot survive, and returns a water bucket; the pickup sound is the water pickup sound.

### 5.2 Connection test for panes, bars and fences

`Block.isExceptionForConnection(state)` is true for: any `LeavesBlock`, `BARRIER`, `CARVED_PUMPKIN`, `JACK_O_LANTERN`, `MELON`, `PUMPKIN`, and any block in tag `shulker_boxes`.

| Block class | Side connects (side = true) when the neighbour state `n` across that side satisfies |
|---|---|
| `IronBarsBlock` (iron bars, glass panes, all copper bars) | (`n` is not an exception block and the neighbour's face toward this block is sturdy) or `n` is an `IronBarsBlock` or `n` is in tag `walls` |
| `FenceBlock` (nether brick fence) | (`n` is not an exception block and its facing face is sturdy) or `n` is a "same fence" or (`n` is a `FenceGateBlock` and the gate's facing axis is perpendicular to the connecting direction) |
| `WallBlock` | `n` in tag `walls`, or (not an exception block and its facing face is sturdy), or `n` is an `IronBarsBlock`, or (`n` is a `FenceGateBlock` that connects in that direction) |
| `TripWireBlock` | see 6.27 |

"Facing face is sturdy" is `BlockState.isFaceSturdy(level, neighbourPos, directionTowardThisBlock)`. "Same fence" is: `n` is in tag `fences` and (`n` is in tag `wooden_fences`) equals (this fence's default state is in tag `wooden_fences`); so the nether brick fence (not wooden) connects to other non-wooden fences and not to wooden fences. The gate connection test (`FenceGateBlock.connectsToDirection(state, dir)`) is: the gate's facing axis equals the axis of `dir` rotated one quarter turn clockwise.

For placement the test is evaluated for the four horizontal neighbours (north, east, south, west) and the face-sturdiness is evaluated toward the opposite direction (the neighbour north of the block is tested for its SOUTH face and so on). On a neighbour shape update from a horizontal direction the one property for that direction is recomputed the same way; vertical updates fall through to the block default.

### 5.3 Crop growth speed (`CropBlock.getGrowthSpeed(block, level, pos)`)

Used by stems, carrots and potatoes.

1. Start with speed = 1.
2. For each of the 9 positions in the 3 x 3 square one block **below** the crop (dx and dz each -1, 0, 1), read the block state there. A position contributes 0 unless the state is in tag `grows_crops`. If it is, it contributes 1, or 3 if its `moisture` property (default 0 when absent) is above 0. If the position is not the centre (dx is not 0 or dz is not 0), the contribution is divided by 4. Add all nine to the speed.
3. Let W and E be the west and east neighbours of the crop's own position and N and S the north and south ones. If (W or E is the same block as the crop) and (N or S is the same block), halve the speed. Otherwise, if any of the four diagonal neighbours (the position north of W, north of E, south of E, south of W) is the same block, halve the speed. At most one halving applies.
4. Return the speed.

A crop's random tick requires `rawBrightness(pos, 0) >= 9` (stems and `CropBlock`); it advances when `random.nextInt(floor(25.0 / speed) + 1) == 0`.

### 5.4 Support and survival helpers

- `VegetationBlock.canSurvive`: `mayPlaceOn(blockBelow)`; the default `mayPlaceOn` is "state is in tag `supports_vegetation`". An update from any direction re-checks it and turns the block into air when it fails.
- `FaceAttachedHorizontalDirectionalBlock.canAttach(level, pos, direction)`: the block at `pos.relative(direction)` has its face toward the opposite direction sturdy. `getConnectedDirection(state)`: CEILING gives DOWN, FLOOR gives UP, WALL gives the `facing` value.
- `Block.canAttachTo` for multiface blocks: the neighbour's support shape (or, failing that, its collision shape) has the full face toward the block.
- Block entities and menus are named here and specified by RS13 (document 31) and the menus round (GAP-19): `EnchantingTableBlockEntity`, `BrewingStandBlockEntity`, `EnderChestBlockEntity`, `BeaconBlockEntity`, `CommandBlockEntity`, `SkullBlockEntity`, `TheEndPortalBlockEntity`.

### 5.5 Copper weathering engine (`WeatheringCopper`, `ChangeOverTimeBlock`)

Used by the unwaxed copper bars and copper chains of this part, and by the other weathering copper families of 24 part 8. All values read from `ChangeOverTimeBlock`, `WeatheringCopper`, `WeatheringCopper$WeatherState`, `WeatheringCopperCollection$ByState` and `WeatheringCopperBarsBlock`.

| Item | Value |
|---|---|
| Weather states in order (ordinal 0 to 3) | UNAFFECTED, EXPOSED, WEATHERED, OXIDIZED |
| Per-tick base chance | a random float below 0.05688889 (a float constant); the same float source is drawn once for this test and once for the second test below |
| Chance modifier (`getChanceModifier`) | 0.75 for UNAFFECTED, 1.0 for every other state |
| Scan distance | 4 (`ChangeOverTimeBlock.SCAN_DISTANCE`) |
| Next-block map (`NEXT_BY_BLOCK`) | for each of the 15 collections `COPPER_BLOCK`, `CUT_COPPER`, `CHISELED_COPPER`, `CUT_COPPER_SLAB`, `CUT_COPPER_STAIRS`, `COPPER_DOOR`, `COPPER_TRAPDOOR`, `COPPER_BARS`, `COPPER_GRATE`, `COPPER_BULB`, `COPPER_LANTERN`, `COPPER_CHEST`, `COPPER_GOLEM_STATUE`, `LIGHTNING_ROD`, `COPPER_CHAIN` the links unaffected to exposed, exposed to weathered, weathered to oxidized (`progressMapping`); the oxidized block and every waxed block have no entry |
| Property transfer | the next state is the next block's default state with the current state's property values copied (`withPropertiesOf`) |

1. A block of a weathering class is randomly ticked only when `WeatheringCopper.getNext(block)` has an entry, so unaffected, exposed and weathered blocks tick; oxidized and waxed blocks do not.
2. On a random tick: draw a float; if it is not below 0.05688889 nothing happens. Otherwise compute the next state (steps 3 and 4) and, if there is one, replace the block with it (`setBlockAndUpdate`).
3. Neighbour census. Look at every position within Manhattan distance 4 of the block (`BlockPos.withinManhattan(pos, 4)`, ordered by growing distance; the bound being inclusive is inferred from how the extent is passed), excluding the block's own position, and keep those whose block is a `ChangeOverTimeBlock` whose age type is the same enumeration (so only weathering copper counts). Let `older` be the number with a higher weather state than this block and `same` the number with an equal state. If any kept block has a **lower** state than this block the census aborts and there is no change.
4. Otherwise f = (older + 1) / (older + same + 1) (float division), p = f * f * (chance modifier). Draw a second float; if it is below p the result is the next state from the map, else there is no change.

Combined chance per random tick for a block that is not aborted: 0.05688889 * p.

Worked example. A lone unaffected copper bars block (no weathering copper within distance 4): older 0, same 0, f = 1, p = 0.75, so the chance per random tick is 0.05688889 * 0.75, about 0.0427. An exposed block with 3 other exposed blocks and 1 oxidized block within range and nothing lower: older 1, same 3, f = 2 / 5 = 0.4, p = 0.16 (modifier 1), chance about 0.0091. The same exposed block with one unaffected block within range never changes (census aborts).

## 6. Block classes

Each subsection gives: the fields it covers, the state properties (with default), the shapes, the placement state, survival and update behaviour read from the class, and notable interactions. "Update" means `updateShape` (called when a neighbour changes, with the changed direction); "survive" means `canSurvive`.

### 6.1 `HugeMushroomBlock` (`mushroom_stem`)

- Properties: `up`, `down`, `north`, `east`, `south`, `west` (64 states). Default: all six `true`. Shape: the full block (no override).
- Placement: each of the six properties is `true` when the block on that side is **not** the same block (`BlockState.is(this)`), so a stem touching another stem hides that face.
- Update: when the changed neighbour is the same block, the property for that direction becomes `false`; otherwise unchanged.
- Rotation and mirror permute the four horizontal properties by the rotation or mirror of each direction.

### 6.2 `IronBarsBlock` (`iron_bars`, `glass_pane`, 8 copper bars)

- Properties: `north`, `east`, `south`, `west`, `waterlogged` (32 states). Default: all false. (`CrossCollisionBlock` supplies the properties and shapes; `IronBarsBlock` supplies the connection rule of 5.2.)
- Constructor parameters: node width 2, extension width 16, node height 2 (used as the arm width), extension height 16, collision height 16. The construction yields these shapes, which are the same for outline and collision:
  - post = `column(2, 0, 16)` (x 7 to 9, z 7 to 9, y 0 to 16);
  - arm toward north = `boxZ(2, 0, 16, 0, 8)` (x 7 to 9, y 0 to 16, z 0 to 8), turned for east, south and west with `rotateHorizontal`;
  - the shape of a state is the union of the post and the arm of every side whose property is true.
- `getVisualShape` returns the empty shape. `isPathfindable` is false (all pathfinding modes). `skipRendering` (client face culling): returns true when the neighbour state is this same block, or when both are `bars`-tagged blocks that both have a horizontal connection toward each other; details (client only) belong to RS24.
- Placement: each side from the connection test of 5.2 (neighbour north tested against its SOUTH face and so on), `waterlogged` from the fluid state.
- Update: waterlogged scheduling per 5.1; for a horizontal change direction the single side property is recomputed with the connection test; otherwise default.
- Rotation (`rotate`) and mirror (`mirror`) (read in `CrossCollisionBlock`, shared by bars, panes, fences; the same permutations are used by `WallBlock`'s sides in 6.12, the vine in 6.7 and the tripwire in 6.27). For a rotation, the new value of each side is taken from the old side as follows:

| Rotation | new `north` | new `east` | new `south` | new `west` |
|---|---|---|---|---|
| `CLOCKWISE_90` | old `west` | old `north` | old `east` | old `south` |
| `CLOCKWISE_180` | old `south` | old `west` | old `north` | old `east` |
| `COUNTERCLOCKWISE_90` | old `east` | old `south` | old `west` | old `north` |
| `NONE` | unchanged | unchanged | unchanged | unchanged |

  For a mirror: `LEFT_RIGHT` swaps the values of `north` and `south` (it is the inversion of the Z axis, `OctahedralGroup.INVERT_Z`) and leaves `east` and `west`; `FRONT_BACK` swaps `east` and `west` (inversion of X) and leaves `north` and `south`; `NONE` is unchanged. Note that `LEFT_RIGHT` exchanges the two Z-axis neighbours (north and south), not east and west.
- Copper bars: `WeatheringCopperBarsBlock` is an `IronBarsBlock` that is randomly ticked only when `WeatheringCopper.getNext(block)` is present and whose random tick calls `changeOverTime` (the oxidation engine, section 5.5). `waxed_*` are plain `IronBarsBlock` and do not tick; the wax interactions (honeycomb, axes, lightning) belong to the item and entity rounds, not to the block classes read here.

### 6.3 `FenceBlock` (`nether_brick_fence`)

- Properties as 6.2 (32 states), default all false, same placement and update structure with the fence connection test of 5.2.
- Constructor parameters 4, 16, 4, 16, 24: outline shape: post `column(4, 0, 16)`, arm `boxZ(4, 0, 16, 0, 8)` (x 6 to 10, y 0 to 16, z 0 to 8, rotated); collision shape: post `column(4, 0, 24)`, arm `boxZ(4, 0, 24, 0, 8)` (so the collision is 24 pixels tall); occlusion shape: post `column(4, 0, 16)`, arm `boxZ(2, 6, 15, 0, 8)` (x 7 to 9, y 6 to 15, z 0 to 8).
- `getVisualShape` equals the outline shape. `isPathfindable` false.
- `useWithoutItem` (read): on the client it returns PASS. On the server it calls `LeadItem.bindPlayerMobs(player, level, pos)` and returns its result:
  1. Collect every `Leashable` entity whose bounding box intersects the cube of side 32 centred on the block centre (x + 0.5, y + 0.5, z + 0.5), keeping those whose current leash holder is this player. If there are none the result is PASS.
  2. Find the leash knot entity at the position (`LeashFenceKnotEntity.getKnot`), or create one (`createKnot`) if there is none. For each collected entity for which `canHaveALeashAttachedTo(knot)` is true, set its leash holder to the knot (`setLeashedTo(knot, true)`) and remember that at least one was attached.
  3. If at least one was attached: play the knot's placement sound, emit game event `block_attach` at the position with the player as the context entity, and return SUCCESS_SERVER. Otherwise, if the knot was newly created for this call, discard it, and return PASS.

### 6.4 `ChainBlock` (`iron_chain`, 8 copper chains)

- Properties: `axis` (x, y, z) and `waterlogged` (6 states). Default: `axis` y, `waterlogged` false.
- Shape: `Shapes.rotateAllAxis(cube(3, 3, 16))`: the Z entry is the box x 6.5 to 9.5, y 6.5 to 9.5, z 0 to 16; the X entry is that box turned a quarter turn about Y (spanning x 0 to 16); the Y entry is the same box turned about X (spanning y 0 to 16). The state shape is the entry for its `axis`.
- Placement: `axis` is the axis of the clicked face (`RotatedPillarBlock.getStateForPlacement`), `waterlogged` from the fluid. Rotation of a quarter turn (90 or 270) swaps axis x and z, leaves y alone.
- Update per 5.1. `isPathfindable` false. Copper chains: same class split as bars (`WeatheringCopperChainBlock` ticks and oxidises by the engine of 5.5, waxed ones do not).

### 6.5 Plain blocks and `PumpkinBlock` (`melon`, `pumpkin`, `resin_block`, `resin_bricks`, `chiseled_resin_bricks`, `nether_bricks`, `end_stone`, `emerald_block`, the two emerald ores)

- No properties (1 state). Default shape the full block.
- `melon` is a plain `Block`. `pumpkin` is `PumpkinBlock`; both are in the connection exceptions of 5.2.
- `PumpkinBlock.useItemOn` with shears (server side): (1) the carve direction is the clicked face, or, if the clicked face is vertical, the opposite of the player's horizontal facing; (2) drop the contents of the block-interact loot table `carve_pumpkin` (data) as an item entity at (x + 0.5 + 0.65 * stepX, y + 0.1, z + 0.5 + 0.65 * stepZ) with velocity (0.05 * stepX + 0.02 * random double, 0.05, 0.05 * stepZ + 0.02 * random double); (3) play `pumpkin_carve`; (4) set the block to `carved_pumpkin` facing the carve direction with update flags 11; (5) damage the shears by 1, emit game event `shear`, award the stat for using shears. Other items fall through to the default. Client side returns SUCCESS.
- The two emerald ores are `DropExperienceBlock(UniformInt(3, 7))`: after the block is broken with drops enabled (`spawnAfterBreak` with the flag), `tryDropExperience(level, pos, tool, range)` spawns experience equal to a random integer in 3 to 7 inclusive (silk-touch and enchantment handling lives in that method and in RS9/RS5).

### 6.6 `StemBlock` (`pumpkin_stem`, `melon_stem`) and `AttachedStemBlock` (`attached_pumpkin_stem`, `attached_melon_stem`)

`StemBlock`:
- Property `age` 0..7 (8 states), default 0. Shape: `boxes(7, i -> column(2, 0, 2 + 2 * i))`: age i is a column x 7 to 9, z 7 to 9, height 2, 4, 6, 8, 10, 12, 14, 16 for ages 0 to 7. Random ticks enabled.
- Each stem is built with five constants (fruit block key, attached-stem block key, seed item key, stem-support tag, fruit-support tag): pumpkin: fruit `pumpkin`, attached `attached_pumpkin_stem`, seed `pumpkin_seeds`, tags `supports_pumpkin_stem` and `supports_pumpkin_stem_fruit`; melon: `melon`, `attached_melon_stem`, `melon_seeds`, `supports_melon_stem`, `supports_melon_stem_fruit`.
- Survive: the block below is in the stem-support tag (`mayPlaceOn`), plus the standard vegetation update (air when it fails).
- Random tick: (1) nothing if `rawBrightness(pos, 0) < 9`. (2) speed = growth speed of 5.3. (3) with probability `1 / (floor(25.0 / speed) + 1)` (the test `nextInt(floor(25/speed) + 1) == 0`) continue. (4) If age < 7 set age + 1 (update flags 2). (5) If age is already 7: choose a random horizontal direction d (`Plane.HORIZONTAL.getRandomDirection`), let target = pos + d; if the target is air and the block below the target is in the fruit-support tag and both the fruit block and the attached-stem block exist, set the target to the fruit block's default state and replace the stem with the attached stem block (default state with `facing` = d), both through `setBlockAndUpdate`.
- Bonemeal: valid while age is not 7; always succeeds; adds `Mth.nextInt(random, 2, 5)` (2 to 5 inclusive) to age capped at 7, and if the result is 7 immediately applies one random tick.
- Clone item: the seed item.

`AttachedStemBlock`:
- Property `facing` (four horizontal values, 4 states), default NORTH. Shape: `rotateHorizontal(boxZ(4, 0, 10, 0, 10))` per facing: for north x 6 to 10, y 0 to 10, z 0 to 10; the other facings are the rotations. No random ticks.
- Update: if the changed neighbour is in the `facing` direction and is **not** the fruit block, and the stem block exists, the block becomes the stem's default state with `age` 7 (a stem returns when its fruit is removed); otherwise the vegetation update (survive check against the `supports_*_stem` tag).
- Rotate and mirror act on `facing`.

### 6.7 `VineBlock` (`vine`)

- Properties `up`, `north`, `east`, `south`, `west` (no `down`), 32 states, default all false. Random ticks enabled. `propagatesSkylightDown` true. Replaceable.
- Shape: union over true sides of `rotateAll(boxZ(16, 0, 1))`, that is a one-pixel plate against the face (north: x 0 to 16, y 0 to 16, z 0 to 1; up: the plate at the top y 15 to 16 by the `rotateAll` up entry); if no side is true the shape is `Shapes.block()` (the empty-union case).
- Acceptable support on a face `d` of the neighbour position: `isAcceptableNeighbour(level, pos, d)` is `MultifaceBlock.canAttachTo(level, d, pos, state at pos)` (the neighbour's full face toward the vine, 5.4). `canSupportAtFace(pos, d)`: false for DOWN; true if the neighbour at `pos + d` is acceptable toward `d`; for a horizontal `d` also true when the block above the vine is a vine whose property for `d` is true; otherwise false.
- `getUpdatedState`: if `up` is true it is kept only when the block above is acceptable toward DOWN; for each horizontal direction whose property is true it is kept when `canSupportAtFace` holds or the block above is a vine with that side set. `canSurvive` = the updated state has at least one face; `updateShape` for a non-DOWN direction defers to the default, for DOWN recomputes the state and returns air if no face remains.
- Placement (`getStateForPlacement`): the base state is the vine already at the clicked position when there is one (`BlockState.is(this)`), otherwise the default state. Walk `getNearestLookingDirections` (section 2.1, rule 5); the first direction `d` that is not DOWN, whose face is not already set on the existing vine, and for which `canSupportAtFace(clickedPos, d)` holds is returned with that face set on the base state. If no direction qualifies the result is null for a fresh placement and the existing vine unchanged when there was one. `canBeReplaced`: when the block at the clicked position is a vine (read from the level at the clicked position), it can be replaced while it has fewer than 5 faces set (5 = the size of the face-property map); otherwise the default replacement rule applies.
- Rotate and mirror use the permutation tables of 6.2 (the four horizontal properties; `up` is not touched): rotation as in the table of 6.2, `LEFT_RIGHT` swaps `north` and `south`, `FRONT_BACK` swaps `east` and `west`.
- Random tick (server; gated by the game rule `spread_vines`, engine context RS11). Inputs: the vine state `S` at `pos`, the world, a random source. Constants: acceptance chance of the tick 1 in 4 (`nextInt(4) == 0`), the top-of-wrap placement chance 0.05 (`nextFloat() < 0.05`), the crowding box x and z within 4 and y within 1 of the vine (9 x 3 x 9 blocks, including the vine itself) with at most 4 vine blocks inside. All placements and changes use update flags 2.

  Draw order and outputs:
  1. The tick does nothing unless `spread_vines` is true and `nextInt(4)` returns 0.
  2. Draw `d = Direction.getRandom(random)` (uniform over DOWN, UP, NORTH, SOUTH, WEST, EAST, one `nextInt(6)` call, 2.1 rule 1). The outcome depends on `d` only through the classes in the table; the behaviours are listed by class of `d`, with `cw` = `d.getClockWise()`, `ccw` = `d.getCounterClockWise()`, `p` = `pos + d`, `opp` = `d.getOpposite()`, "acceptable(q, f)" = `isAcceptableNeighbour(level, q, f)` and `canSpread` the crowding test above.

| Class of `d` | Precondition | Result |
|---|---|---|
| horizontal, `S.d` already true | none | falls to the DOWN class below |
| horizontal, `S.d` false | `canSpread` false | nothing |
| horizontal, `S.d` false | `canSpread`, and the block at `p` is **not** air | if acceptable(`p`, `d`): set `S.d` true on this vine (no new block); else nothing |
| horizontal, `S.d` false | `canSpread`, `p` is air | exactly one of the following, tried in this order, then stop: **(a)** `S.cw` true and acceptable(`p + cw`, `cw`): place a new vine at `p` with only face `cw`; **(b)** `S.ccw` true and acceptable(`p + ccw`, `ccw`): place a new vine at `p` with only face `ccw`; **(c)** `S.cw` true, the position `p + cw` is empty (air) and acceptable(`pos + cw`, `opp`): place a new vine at `p + cw` with only face `opp`; **(d)** `S.ccw` true, `p + ccw` empty and acceptable(`pos + ccw`, `opp`): place a new vine at `p + ccw` with only face `opp`; **(e)** otherwise, if `nextFloat() < 0.05` and acceptable(`p` + UP, UP): place a new vine at `p` with only face UP. If none applies nothing happens |
| UP, and `pos.y` below the world's maximum build y | `canSupportAtFace(pos, UP)` | set `S.up` true (then stop) |
| UP, and `pos.y` below the maximum, `canSupportAtFace(pos, UP)` false | the block above is air: then `canSpread` false gives nothing, and `canSpread` true gives the result in the next cell. If the block above is **not** air the tick continues with the DOWN row | start from `S`; for each horizontal direction `f` in order NORTH, EAST, SOUTH, WEST, draw one `nextBoolean()`; the face `f` of the copy is cleared when that draw is true **or** when acceptable(`above + f`, `f`) is false, otherwise kept as in `S`. If the copy has at least one horizontal face place it at the block above; else nothing |
| DOWN, or UP at the maximum build y, or UP with no support and a non-air block above, or a horizontal `d` whose face is already set | `pos.y` above the world's minimum build y, and the block below `b` is air or a vine | target `T` = the default vine state if `b` is air, else `b`'s state; for each horizontal `f` in order NORTH, EAST, SOUTH, WEST draw one `nextBoolean()` and, when it is true and `S.f` is true, set `T.f` true; if the result differs from `T` and has at least one horizontal face place it at the block below; else nothing |

  The three horizontal-face conditions use the property of the **face**, never `up`; `up` is only produced by the UP rows and by (e).
  Worked example. A vine at `pos` with only `north` set whose tick draws `d` = EAST (property `east` is false) with `canSpread` true and the block east of it air: `cw` = SOUTH, `ccw` = NORTH. (a) needs `S.south`, false; (b) needs `S.north` (true) and acceptable(`p` + NORTH, NORTH): when the block north of the position east of the vine can hold a face toward NORTH, a new vine with only `north` is placed east of the vine (the growth wraps around a solid wall to the north). Otherwise (c) and (d) are tried (only (d) can apply), then (e) with probability 0.05 (a hanging top vine at `p`).
  Worked example, DOWN. A vine with `north` and `south` set whose tick draws DOWN with air below: `T` is the default vine; each of the four draws of `nextBoolean()` is consumed in the order N, E, S, W; if the draws for north and south are true and the others whatever, `T` gets `north` and `south`; if neither draw is true `T` equals the default state so nothing is placed.

### 6.8 `MultifaceBlock` and `GlowLichenBlock` (`glow_lichen`, `resin_clump`)

- Properties: `down`, `up`, `north`, `east`, `south`, `west` and `waterlogged` (128 states). Default: all false. `resin_clump` is a plain `MultifaceBlock`; `glow_lichen` is a `GlowLichenBlock` (adds a `MultifaceSpreader`, bonemeal spreading and the light function). Both are replaceable, no collision, random-tick flag not set.
- Shape: union over set faces of `rotateAll(boxZ(16, 0, 1))` (a one-pixel plate on that face); no face gives `Shapes.block()`.
- Light of glow lichen: 7 if the state has any face set, otherwise 0 (`emission(7)`).
- Survive: for each set face the neighbour in that direction can be attached to (5.4); with no set face the block cannot survive (`canSurvive` requires at least one set face that is attachable). Update: if the state has no face the block becomes air; if the changed direction is a set face and no longer attachable that face is cleared (and the block becomes air when it was the last face); waterlogging per 5.1.
- Replace rule (`canBeReplaced`): replaceable by the same item while at least one face is vacant. Placement: iterate `getNearestLookingDirections` and take the first direction for which the placement is valid (the face is supported, and an existing multiface of the same block does not already have it); the new state sets that face (and `waterlogged` as in 5.1).
- Rotation and mirror permute the horizontal faces (only when the block's face set is symmetric under the transform; `canRotate`, `canMirrorX`, `canMirrorZ` are computed from `isFaceSupported`, which is true for all six faces here, so all transforms apply).
- Bonemeal: valid when `spreader.canSpreadInAnyDirection` is true for some direction; always succeeds; `spreadFromRandomFaceTowardRandomDirection`. The spreader class (`MultifaceSpreader`) is not specified here (Open question 5).

### 6.9 `FenceGateBlock` (`oak_fence_gate`)

- Properties: `facing`, `in_wall`, `open`, `powered` (32 states in the sorted order facing, in_wall, open, powered). Default: facing north, all booleans false. Constructed with `WoodType.OAK`, which also sets the block's sound: `WoodType.OAK` is `WoodType("oak", BlockSetType.OAK)`, built by the constructor that supplies `SoundType.WOOD` (block sound), `SoundType.HANGING_SIGN`, and the sound events `FENCE_GATE_CLOSE` and `FENCE_GATE_OPEN` (the gate sounds used below).
- Shapes (axis = axis of `facing`; entry Z for facing north or south, X for east or west):
  - outline `SHAPES`: `rotateHorizontalAxis(cube(16, 16, 4))`, i.e. Z entry x 0 to 16, y 0 to 16, z 6 to 10; X entry turned (x 6 to 10, z 0 to 16). When `in_wall` the outline is `SHAPES_WALL`: the same shape minus `column(16, 13, 16)` (everything above y 13 removed, leaving y 0 to 13).
  - collision `SHAPE_COLLISION`: `rotateHorizontalAxis(column(16, 4, 0, 24))` (x 0 to 16, z 6 to 10, y 0 to 24); the empty shape when `open`.
  - support shape `SHAPE_SUPPORT`: `rotateHorizontalAxis(column(16, 4, 5, 24))` (y 5 to 24); empty when `open`.
  - occlusion `SHAPE_OCCLUSION`: `rotateHorizontalAxis(or(box(0, 5, 7, 2, 16, 9), box(14, 5, 7, 16, 16, 9)))` (two posts); when `in_wall` it is that shape moved down 3 pixels (y 2 to 13).
- Placement: `facing` = the placer's horizontal direction; `powered` = `open` = whether the position has a neighbour redstone signal; `in_wall` = a wall (tag `walls`) is on either side perpendicular to the facing (for facing along Z the west or east neighbour is a wall; along X the north or south neighbour).
- Update: for a changed direction perpendicular to the gate's facing, `in_wall` = the changed neighbour is a wall or the block on the opposite side is a wall.
- `useWithoutItem`: if open, close it (set `open` false, flags 10). Otherwise, if the gate's facing is the opposite of the clicked face direction, set `facing` to the clicked face direction, then set `open` true (flags 10). Plays the wood type's gate open or close sound (volume 1, pitch `random.nextFloat() * 0.1 + 0.9`) and emits `block_open` or `block_close`.
- `neighborChanged` (server): when the neighbour redstone signal differs from `powered`, set `powered` and `open` to the signal (flags 2) and emit sound and game event only if `open` changed. Explosion hit with block-triggering power closes an open unpowered gate (sound close, event close).
- `isPathfindable(state, type)` (read, with the switch map of `FenceGateBlock$1`): for type LAND the result is the `open` value, for type AIR the `open` value, for type WATER false. So a closed gate blocks land and air navigation and an open one allows it.

### 6.10 `StairBlock` (all nine stairs here)

- Properties: `facing`, `half`, `shape`, `waterlogged` (80 states). Default: facing north, half bottom, shape straight, waterlogged false. Each stairs block carries its base block's default state (`baseState`) and uses the base block's explosion resistance. `useShapeForLightOcclusion` is true. Not pathfindable.
- Base shapes (pixels): `OUTER` = `column(16, 0, 8)` (the bottom slab) union `box(0, 8, 0, 8, 16, 8)` (the north-west upper quarter); `STRAIGHT` = `OUTER` union `OUTER` turned a quarter turn clockwise (so the upper half on the north side: x 0 to 16, y 8 to 16, z 0 to 8); `INNER` = `STRAIGHT` union `STRAIGHT` turned a quarter turn (three upper quarters). Bottom maps = `rotateHorizontal` of each; top maps = `rotateHorizontal(shape, INVERT_Y)` (vertically mirrored). A state with `facing` f has the high step on the f side.
- Shape lookup: pick the map by half (BOTTOM or TOP) and by `shape` (STRAIGHT, INNER_LEFT and INNER_RIGHT use STRAIGHT / INNER; OUTER_LEFT and OUTER_RIGHT use OUTER; precisely STRAIGHT uses the straight map, INNER_LEFT and INNER_RIGHT the inner map, OUTER_LEFT and OUTER_RIGHT the outer map). Then the key into the map is: `facing` for STRAIGHT, OUTER_LEFT and INNER_RIGHT; `facing.getCounterClockWise()` for INNER_LEFT; `facing.getClockWise()` for OUTER_RIGHT.
- Placement: `half` is TOP when the clicked face is DOWN, or when the clicked face is horizontal and the click height within the block is above 0.5; BOTTOM otherwise. `facing` is the placer's horizontal direction: `UseOnContext.getHorizontalDirection()` is the player's own `getDirection()` (2.1 rule 3), not its opposite, so a player facing south places a stair with `facing` south. `waterlogged` from the fluid; `shape` from the corner rule below.
- Corner rule `getStairsShape(state, level, pos)` with f = `facing`:
  1. Look at the block in front, `pos + f`. If it is a stairs block of the same `half`, whose `facing` g is on the other axis than f, and the block at `pos + g.opposite` is **not** a same-`half`, same-`facing` stairs (`canTakeShape`, see below): shape is OUTER_LEFT if g is f's counter-clockwise direction, otherwise OUTER_RIGHT.
  2. Otherwise look at the block behind, `pos + f.opposite`. If it is a stairs block of the same `half`, with `facing` g on the other axis, and the block at `pos + g` is **not** a same-`half`, same-`facing` stairs: INNER_LEFT if g is f's counter-clockwise direction, otherwise INNER_RIGHT.
  3. Otherwise STRAIGHT.
  `canTakeShape(state, level, pos, dir)` is true unless the block at `pos + dir` is a stairs block with the same `facing` and the same `half` as `state` (in which case that neighbour already provides the shape).
- Update: waterlogging per 5.1; for a horizontal direction the `shape` is recomputed with the corner rule; vertical updates use the default.
- Rotate sets `facing` to the rotated facing (`Rotation.rotate(direction)`). Mirror (read, with the switch maps of `StairBlock$1`): the result is the state rotated by `CLOCKWISE_180` (so `facing` becomes its opposite, `half` unchanged) with `shape` replaced as in the table; a mirror that does not apply to the stair's facing axis returns the state unchanged (`Block.mirror` is `BlockBehaviour.mirror`, which returns its argument), and `Mirror.NONE` is unchanged.

| Mirror | Applies when `facing` is on axis | STRAIGHT | OUTER_LEFT | OUTER_RIGHT | INNER_LEFT | INNER_RIGHT |
|---|---|---|---|---|---|---|
| `LEFT_RIGHT` (inversion of Z) | Z (north or south) | STRAIGHT | OUTER_RIGHT | OUTER_LEFT | INNER_RIGHT | INNER_LEFT |
| `FRONT_BACK` (inversion of X) | X (east or west) | STRAIGHT | OUTER_RIGHT | OUTER_LEFT | INNER_LEFT | INNER_RIGHT |

  Columns give the current `shape` and cells the new `shape`. The `FRONT_BACK` row is as read: for `FRONT_BACK` the inner shapes are left as they are (only the 180 degree rotation applies to them), while `LEFT_RIGHT` swaps the inner shapes. The two tables differ exactly in the two inner entries, and no rule other than this table is applied. Worked example: a bottom stair `facing` north, shape `inner_left`, mirrored `LEFT_RIGHT`: the axis is Z so the state becomes `facing` south, shape `inner_right`; the same stair mirrored `FRONT_BACK` is returned unchanged (axis is Z, not X). An east-facing `inner_left` stair mirrored `FRONT_BACK` becomes `facing` west, shape `inner_left`.

### 6.11 `SlabBlock` (`resin_brick_slab`)

- Properties `type` (top, bottom, double) and `waterlogged` (6 states). Default: bottom, not waterlogged. Shapes: bottom `column(16, 0, 8)` (y 0 to 8), top `column(16, 8, 16)` (y 8 to 16), double the full block. `useShapeForLightOcclusion` is true unless `type` is DOUBLE.
- Placement: if the position already holds a slab of the same block, the result is that state with `type` DOUBLE and `waterlogged` false. Otherwise default state with `waterlogged` from the fluid, and `type` TOP when the clicked face is DOWN or (the clicked face is horizontal and the click height within the block is above 0.5), else BOTTOM.
- Replace rule (`canBeReplaced(state, context)`, read in full). Result false when `type` is DOUBLE or when the held item is not this slab's item. Otherwise, if the context does not replace the clicked block (`replacingClickedOnBlock` false), the result is true. Otherwise let `above` be true when (click location y - clicked block y) is greater than 0.5, and `face` the clicked face: for `type` BOTTOM the result is true when `face` is UP, or when `above` is true and `face` is horizontal, and false in every other case; for `type` TOP the result is true when `face` is DOWN, or when `above` is false and `face` is horizontal, and false in every other case. Examples: a bottom slab clicked on its top face (UP) with the same item becomes replaceable (a double slab results); a bottom slab clicked on a side face in its lower half (`above` false) is not replaceable, so a new slab is placed beside it instead; a top slab clicked on its bottom face (DOWN) is replaceable.
- Waterlogging: `placeLiquid` and `canPlaceLiquid` return false for a DOUBLE slab; for `top` and `bottom` they are the interface defaults of 5.1 item 5 (read in `SlabBlock`, which delegates to `SimpleWaterloggedBlock`).

### 6.12 `WallBlock` (`resin_brick_wall`, `cobblestone_wall`, `mossy_cobblestone_wall`)

- Properties: `up` (boolean), `north`, `east`, `south`, `west` (each `none`, `low`, `tall`), `waterlogged`: 324 states, sorted order east, north, south, up, waterlogged, west. Default: `up` true, all four sides `none`, `waterlogged` false.
- Shapes: `makeShapes(postHeight, lowHeight)`; outline = `makeShapes(16, 14)`, collision = `makeShapes(24, 24)`. In `makeShapes(post, low)`: the post is `column(8, 0, post)`; the low arm is `rotateHorizontal(boxZ(6, 0, low, 0, 11))` (x 5 to 11, y 0 to `low`, z 0 to 11 for north); the tall arm is `rotateHorizontal(boxZ(6, 0, post, 0, 11))`. The state shape is: the post if `up` is true; union the low arm for each side that is `low` and the tall arm for each side that is `tall`. So outline: post height 16, low arms 14 tall, tall arms 16 tall; collision: post and all arms 24 tall. `waterlogged` does not change shapes.
- Placement and update (the "top update" and "side update"): let `above` be the block above the wall and `topFace` the DOWN face of `above`'s collision shape. The four sides are first set to booleans by the connection test of 5.2, where the north neighbour is tested with its SOUTH face (and direction argument SOUTH), the east neighbour with WEST, the south neighbour with NORTH and the west neighbour with EAST. `updateSides` then sets each side to `none` when not connected, `tall` when connected and `topFace` covers the test arm shape for that direction, `low` when connected and not covered. The test arm shapes are `rotateHorizontal(boxZ(2, 16, 0, 9))` (x 7 to 9, y 0 to 16, z 0 to 9 for north). "Covered(a, b)" means `b` minus `a` is empty (the second shape lies inside the first).
- `up` is then recomputed by `shouldRaisePost(state, above, topFace)`: (1) true if `above` is a wall whose `up` is true; (2) otherwise let noneN, noneS, noneE, noneW be "side is `none`": true if all four are none, or if noneN is not equal to noneS, or if noneW is not equal to noneE; (3) otherwise false if (north is `tall` and south is `tall`) or (east is `tall` and west is `tall`); (4) otherwise true if `above` is in tag `wall_post_override` or the test post `column(2, 0, 16)` is covered by `topFace`; otherwise false.
- Update: waterlogging per 5.1; a DOWN change uses the default; an UP change re-evaluates sides from the current properties (top update); a horizontal change recomputes with the changed side taken from the new neighbour and the other sides from the current state (side update).
- Rotation and mirror permute the four side properties with the tables of 6.2 (`WallBlock.rotate` and `mirror` use the same switch structure: `LEFT_RIGHT` swaps `north` and `south`, `FRONT_BACK` swaps `east` and `west`; the `up` property and `waterlogged` are untouched). Not pathfindable. `propagatesSkylightDown` is true when not waterlogged.

### 6.13 `SpreadingSnowyBlock` and `MyceliumBlock` (`mycelium`)

- Property `snowy` (2 states), default false. Random ticks enabled. `MyceliumBlock(props)` passes the base block key `dirt`.
- `snowy` placement: true when the block above is in tag `snow`; an UP update recomputes it from the changed neighbour (`updateShape` for direction UP sets `snowy` from that neighbour, other directions default).
- Random tick: (1) if the base block (`dirt`) cannot be found, nothing. (2) If the block cannot stay alive, replace it by the base block's default state (`setBlockAndUpdate`) and stop. "Can stay alive": let `a` be the block above; true when `a` is `snow` with 1 layer; false when `a`'s fluid is a full source or flowing full (`FluidState.isFull`); otherwise true when `LightEngine.getLightDampeningInto(this, a, UP, a.getLightDampening()) < 15`. (3) If the maximum local raw brightness at the block above is at least 9, try 4 times: pick a position offset from this block by (`nextInt(3) - 1`, `nextInt(5) - 3`, `nextInt(3) - 1`) (x, y, z; the three calls in that order); if that position holds the base block and "can propagate" (it can stay alive as this block would, and the fluid above it is not water), set it to this block's default state with `snowy` = the snowy test of the block above it.
- Client `animateTick` spawns a `mycelium` particle with probability 1/10 at y + 1.1 (RS24).

### 6.14 `LilyPadBlock` (`lily_pad`)

- No properties. Shape `column(14, 0, 1.5)`. Survive: the block below is a fluid that is in `fluid` tag `supports_lily_pad` or a state in block tag `supports_lily_pad`, and the fluid above the pad is empty. `entityInside`: a server-side entity that is an `AbstractBoat` destroys the block with drops (`destroyBlock(pos, true, entity)`).

### 6.15 `NetherWartBlock` (`nether_wart`)

- Property `age` 0..3 (4 states), default 0. Shape: `boxes(3, i -> column(16, 0, 5 + 3 * i))` (heights 5, 8, 11, 14). Survive: block below in tag `supports_nether_wart`. Random ticks only while age < 3: each tick, when `nextInt(10) == 0` and age < 3, age + 1 (flags 2). Clone item: nether wart.

### 6.16 `EnchantingTableBlock` (`enchanting_table`)

- No properties. Shape `column(16, 0, 12)`; `useShapeForLightOcclusion` true. Light 7. Not pathfindable. Block entity `EnchantingTableBlockEntity`; the ticker exists on the client only.
- `useWithoutItem` (server): open the menu `EnchantmentMenu` with `ContainerLevelAccess` at the position; the title is the block entity's display name. The power providers are the positions of `BOOKSHELF_OFFSETS`: all positions with (dx, dy, dz) from (-2, 0, -2) to (2, 1, 2) inclusive where |dx| = 2 or |dz| = 2 (the ring at distance 2, two layers: 16 per layer, 32 in total; filter and order as in the artifact's `betweenClosedStream`). A position `o` counts when the block at `pos + o` is in tag `enchantment_power_provider` and the block at `pos + (o.x / 2, o.y, o.z / 2)` (integer division) is in tag `enchantment_power_transmitter` (isValidBookShelf). Enchanting-table particle spawning on the client: for each such offset with probability 1/16, particle `enchant` at (x + 0.5, y + 2.0, z + 0.5) with velocity (o.x + random float - 0.5, o.y - random float - 1, o.z + random float - 0.5).

### 6.17 `BrewingStandBlock` (`brewing_stand`)

- Properties `has_bottle_0`, `has_bottle_1`, `has_bottle_2` (8 states), default all false. Shape `or(column(2, 2, 14), column(14, 0, 2))`. Light 1. Not pathfindable. Block entity `BrewingStandBlockEntity` with a server ticker. `useWithoutItem` (server): open the block entity as a menu and award stat `interact_with_brewingstand`. Analog output: the container redstone signal of the block entity. Client particle: `smoke` at (x + 0.4 + 0.2 * random, y + 0.7 + 0.3 * random, z + 0.4 + 0.2 * random), zero velocity. Contents drop on removal (`Containers.updateNeighboursAfterDestroy`).

### 6.18 Cauldrons (`cauldron`, `water_cauldron`, `lava_cauldron`, `powder_snow_cauldron`)

- `AbstractCauldronBlock` shape (all four blocks): the full cube minus four boxes: `column(16, 8, 0, 3)` (x 0 to 16, z 4 to 12, y 0 to 3), `column(8, 16, 0, 3)` (x 4 to 12, z 0 to 16, y 0 to 3), `column(12, 0, 3)` (x 2 to 14, z 2 to 14, y 0 to 3) and the inside `column(12, 4, 16)` (x 2 to 14, z 2 to 14, y 4 to 16). The interaction shape is the inside box. `FLOOR_LEVEL` 4. Not pathfindable. Analog output is available (`hasAnalogOutputSignal`). Item use is dispatched through a `CauldronInteraction.Dispatcher` held by the block (`EMPTY`, `WATER`, `LAVA`, `POWDER_SNOW` sets in `CauldronInteractions`); those interaction tables are not specified here (Open question 6).
- `CauldronBlock` (empty): no properties, 1 state; not full. Precipitation: when `handlePrecipitation` is invoked, a rain event fills it with probability 0.05 and a snow event with probability 0.1 (both are the float tests in `CauldronBlock.shouldHandlePrecipitation`: rain passes when `level.getRandom().nextFloat() < 0.05f`, snow when `nextFloat() < 0.1f`, any other precipitation type never), turning it into `water_cauldron` (level default 1) or `powder_snow_cauldron` respectively; both emit `block_change`. It can receive stalactite drips: water drip turns it into `water_cauldron` (level event 1047), lava drip into `lava_cauldron` (event 1046).
- `LayeredCauldronBlock` (`water_cauldron` with precipitation RAIN and `powder_snow_cauldron` with SNOW): property `level` 1..3 (3 states), default 1. Content height in pixels `6 + 3 * level`; the entity-inside collision shape for level L is the cauldron shape plus `column(12, 4, 6 + 3 * L)` (L = 1, 2, 3 give top heights 9, 12, 15). Full when level is 3. Analog output = level. Precipitation: ignored when level is 3, or when the event type differs from the cauldron's type, or the random test fails (0.05 for rain, 0.1 for snow, the same `CauldronBlock.shouldHandlePrecipitation` test, evaluated once); otherwise level + 1 (`cycle(LEVEL)`; from 3 it would wrap, but is excluded). Stalactite drip: water drips fill a water cauldron (rain type) by one level (level event 1047). Fire: an entity that is on fire and can interact lowers the level (a powder-snow cauldron first converts to the water cauldron at the same level, then lowers); `lowerFillLevel` goes from level 1 to the empty `cauldron` and otherwise to level - 1; every extinguish clears the entity's fire.
- `LavaCauldronBlock`: no properties; light 15; full; content height 0.9375 (`LavaCauldronBlock.getContentHeight`, a double constant); entity-inside collision shape = cauldron shape union `column(12, 4, 15)`; inside effect: clears freeze, ignites with the lava effect; analog output 3.

### 6.19 `EndPortalBlock` (`end_portal`)

- No properties. Shape `column(16, 6, 12)` (x 0 to 16, z 0 to 16, y 6 to 12); entity-inside collision equals the shape; not replaceable by fluids; light 15; render shape INVISIBLE; no collision; the clone item is empty; unbreakable (-1), resistance 3600000, push IMMOVEABLE. Block entity `TheEndPortalBlockEntity`.
- Entity inside: an entity that can use portals (`canUsePortal(false)`) that is not a client: in the End, a `ServerPlayer` that has not seen the credits is shown the credits; otherwise the entity is marked as inside the portal (`setAsInsidePortal`). Destination (`getPortalDestination`): from the Overworld (or any dimension other than the End) to the End at `ServerLevel.END_SPAWN_POINT` after creating the End platform at that position (`EndPlatformFeature.createEndPlatform`, one block below the spawn point, with its boolean argument true), yaw = `Direction.WEST` rotation, delta and X rotation relative; from the End to the player's respawn data (or the world spawn adjusted for non-players), the transition plays the portal sound and requests a portal ticket. Client particle `smoke` at (x + random, y + 0.8, z + random).

### 6.20 `EndPortalFrameBlock` (`end_portal_frame`)

- Properties `eye`, `facing` (8 states), default facing north, eye false. Shape: `column(16, 0, 13)` (x 0 to 16, y 0 to 13) when `eye` is false; `or(column(16, 0, 13), column(8, 13, 16))` when `eye` is true. `useShapeForLightOcclusion` true. Light 1. Unbreakable (-1), resistance 3600000. Analog output 15 when `eye`, else 0. Not pathfindable.
- Placement: `facing` = the opposite of the placer's horizontal direction; `eye` false.
- The portal-opening pattern `getOrCreatePortalShape` is a 5 x 5 block pattern whose rows (in the order of `aisle`) are `?vvv?`, `>???<`, `>???<`, `>???<`, `?^^^?` with these predicates: `?` any state; `^` an end portal frame with `eye` true and `facing` SOUTH; `>` frame with eye true, facing WEST; `v` frame with eye true, facing NORTH; `<` frame with eye true, facing EAST. (Which pattern axis maps to which world axis, and how the item-use code orients the search, belong to the portal round; Open question 3.)

### 6.21 `DragonEggBlock` (`dragon_egg`) and `FallingBlock`

- No properties. Shape `column(14, 0, 16)`. Light 1. Push reaction POPPED. `FallingBlock` rules: `onPlace` and any neighbour update schedule a tick with delay `getDelayAfterPlace()` (2 for ordinary falling blocks, from `FallingBlock.getDelayAfterPlace`; 5 for the dragon egg, from its override). The tick: if the block below is "free" and `y >= minY`, the block becomes a falling block entity (`FallingBlockEntity.fall`). "Free" (`isFree`) = the state is air, in tag `fire`, a liquid, or replaceable. Dust colour -16777216 (black) for the dragon egg.
- Teleport on right-click or on attack (server only): choose up to 1000 candidate positions (the loop bound and the 16, 8, 16 ranges are the constants of `DragonEggBlock.teleport`; all six `nextInt` draws are made for every attempt) `pos + (nextInt(16) - nextInt(16), nextInt(8) - nextInt(8), nextInt(16) - nextInt(16))` (the six `nextInt` calls in x, y, z order, each pair x first then second); the first candidate whose block is air, whose block below is not air, is inside the world border and inside the build height is used: send level event 2015 with the packed difference (`BlockUtil.packDifferenceInPosition(pos, newPos, 16, 8, 16)`), set the new position to the egg state (flags 2) and remove the old block. Not pathfindable.

### 6.22 `RedstoneLampBlock` (`redstone_lamp`)

- Property `lit` (2 states), default false; light 15 when `lit` (function `litBlockEmission(15)`: `lit ? 15 : 0`); the lamp allows mob spawning (valid-spawn always true).
- Placement: `lit` = the position has a neighbour redstone signal. `neighborChanged` (server): when `lit` differs from the signal, if currently lit schedule a tick with delay 4; if currently unlit set `lit` true immediately (`cycle`, flags 2). `tick`: if lit and no signal, set unlit (flags 2).

### 6.23 `CocoaBlock` (`cocoa`)

- Properties `age` 0..2 and `facing` (12 states, sorted order age, facing), default facing north, age 0. Random ticks while age < 2: `nextInt(5) == 0` on the level's own random source, then age + 1 (flags 2). Shape (age a, facing north before rotation): `column(4 + 2a, 7 - 2a, 12)` moved by (0, 0, (a - 5) / 16) then rotated with `rotateHorizontal`; i.e. a square column of width 4 + 2a, from y 7 - 2a to 12, shifted north by 5 - a pixels: age 0: x 6 to 10, z 1 to 5, y 7 to 12; age 1: x 5 to 11, z 1 to 7, y 5 to 12; age 2: x 4 to 12, z 1 to 9, y 3 to 12 (derived from the formula).
- Survive: the block in the `facing` direction is in tag `supports_cocoa`. Placement: walk `getNearestLookingDirections` (2.1 rule 5) and take the first horizontal direction for which the state with that `facing` can survive; none gives no placement. Update: if the changed direction is the `facing` direction and the block cannot survive, it becomes air. Bonemeal: valid while age < 2; always succeeds; age + 1. Not pathfindable.

### 6.24 `ShelfMushroomBlock` (`shelf_mushroom`)

- Properties `age` 0..1 and `facing` (8 states, sorted order age, facing), default facing north, age 0. Push reaction POPPED; bounce restitution 0.75 and fall-distance reduction 0.5 (bounces entities; plays `shelf_mushroom_bounce` for entities other than items and primed TNT).
- Survive: the block opposite to `facing` has its face toward `facing` sturdy. Placement: the first horizontal direction d in the looking-direction order such that the state with `facing` = d.opposite can survive. Update: if the changed direction is the opposite of `facing` and the block cannot survive, it becomes air. Bonemeal: valid while age < 1; adds 1 to age.
- Shape (age a in {0, 1}; the base is attached to the south side for facing north): union of (1) the cap `column(10 + 4a, 7 + 3a, 1 + a, 3 + 2a)` (width x, depth z, y from 1 + a to 3 + 2a) moved by (0, (8 - 2a) / 16, (4.5 - 1.5a) / 16) and (2) the stem `column(6 + 2a, 4 + 2a, 0, 1 + a)` moved by (0, (8 - 2a) / 16, (6 - a) / 16), then `rotateHorizontal`. Numbers for facing north: age 0: cap x 3 to 13, y 9 to 11, z 9 to 16; stem x 5 to 11, y 8 to 9, z 12 to 16; age 1: cap x 1 to 15, y 8 to 11, z 6 to 16; stem x 4 to 12, y 6 to 8, z 10 to 16 (derived from the formulas).

### 6.25 `EnderChestBlock` (`ender_chest`)

- Properties `facing`, `waterlogged` (8 states), default facing north, not waterlogged. Shape `column(14, 0, 14)`. Light 7. Strength 22.5 and resistance 600; instrument BASEDRUM. Not pathfindable. Block entity `EnderChestBlockEntity` with a server ticker.
- Placement: `facing` = opposite of the placer's horizontal direction; `waterlogged` from the fluid. Use (server): requires the player's ender inventory and the block entity; if the block above is a redstone conductor the chest does not open (returns SUCCESS without opening); otherwise sets the active chest, opens a 3-row chest menu titled `container.enderchest`, awards stat `open_enderchest`, and angers nearby piglins. The tick rechecks the open state. Client particle: 3 `portal` particles per animate tick, each at (x + 0.5 + 0.25 * s1, y + random, z + 0.5 + 0.25 * s2) with s1, s2 = `nextInt(2) * 2 - 1`, velocity (random * s1, (random - 0.5) * 0.125, random * s2).

### 6.26 `TripWireHookBlock` (`tripwire_hook`)

- Properties `attached`, `facing`, `powered` (16 states, sorted order attached, facing, powered), default facing north, powered false, attached false. No collision. Shape: `rotateHorizontal(boxZ(6, 0, 10, 10, 16))` (north: x 5 to 11, y 0 to 10, z 10 to 16). Signal source (`isSignalSource` true); direct signal 15 toward `facing` when powered; own signal 15 when powered.
- Survive: `facing` horizontal and the block opposite to `facing` has its face toward `facing` sturdy. Placement: the first horizontal direction d in looking order for which the state with `facing` = d.opposite can survive. Update: when the changed direction is the opposite of `facing` and the block cannot survive, it becomes air.
- Hook state calculation (`TripWireHookBlock.calculateState(level, pos, state, removing, updateNeighbours, changedDistance, changedWireState)`; it runs on placement, from the wire's `updateSource`, from the scheduled tick and on removal). Inputs: the hook's position P and facing f (a hook state without a readable `facing` makes the call a no-op), `removing`, `updateNeighbours`, an optional "changed" cell at distance c along the line (c = 0 means none) together with the wire state W that is to be assumed there, and the previous `attached` and `powered` values of this hook.

  Definitions. The line is the cells P + f * k for k = 1 to 41. A cell is a *wire cell* if its block is a tripwire, or if k equals c (then its state is W). The *far hook* is the first cell, in increasing k, that holds a tripwire hook; the scan stops there, and the far hook counts only when its `facing` is the opposite of f. D is the distance k of a counted far hook, 0 when there is none (a hook facing the same way as f ends the scan with D = 0). A cell that is neither a wire cell nor a hook is a *gap*; gaps do not end the scan (cells beyond a gap, up to 41, are still examined).

  Outputs and invariants:
  1. `attached` of the new state is true only if `removing` is false, D is at least 2, none of the scanned cells (those before the scan stopped) is a gap, and the cell at k = c (when it was scanned as a wire cell) holds a state that is not `disarmed`.
  2. `powered` of the new state is true only if `attached` is true and at least one wire cell (using W at k = c) is both `powered` and not `disarmed`. A disarmed wire contributes nothing to `powered`.
  3. When the line has a counted far hook (D greater than 0): the far hook is set (update flags 3) to the new state's `attached` and `powered` with `facing` = the opposite of f, the far hook's neighbours and the block it hangs on are notified, and if this hook has meanwhile been replaced (the block at P is no longer a tripwire hook) the removal handler runs and the calculation ends; the transition effects (below) are emitted for the far hook, comparing the new flags with this hook's previous flags.
  4. The transition effects for this hook are then emitted. Unless `removing`, this hook is set (flags 3) to the new state with `facing` = f, and its neighbours are notified when `updateNeighbours` is true.
  5. If the new `attached` differs from this hook's previous `attached`, every wire cell with 1 <= k < D that is still a tripwire or a hook gets its `attached` property set to the new value (all other properties as they were when scanned, flags 3).
  6. Whenever c is within the scanned cells and the cell is a wire cell, a tick is scheduled at P with delay 10; the delay does not depend on the result.

  Worked example 1. Hook A at P facing east (f = EAST), tripwires at P + 1, P + 2 and P + 3 (none disarmed, none powered, none attached), hook B at P + 4 facing west, `removing` false, c = 0: D = 4, no gap, so `attached` true; no wire is powered so `powered` false. B becomes (facing west, attached true, powered false) and so does A (facing east); because A's previous `attached` was false the three wires get `attached` true.
  Worked example 2. The same line with the tripwire at P + 2 replaced by air: the scan passes the gap and still finds B at k = 4 (D = 4), but the gap sets `attached` false, so `powered` is false as well; A and B are set to `attached` false, and if A had been attached before, the wires at P + 1 and P + 3 have `attached` cleared.
  Worked example 3. The line of example 1 with the wire at P + 2 `powered` true (an entity stands on it): `powered` true for both hooks, `attached` true; the transition effects of 6.26 play `tripwire_click_on` for each hook whose `powered` rose.
- Effects of a state transition: sounds `tripwire_click_on` (volume 0.4, pitch 0.6), `tripwire_click_off` (0.4, 0.5), `tripwire_attach` (0.4, 0.7), `tripwire_detach` (0.4, pitch `1.2 / (random * 0.2 + 0.9)`) with matching game events. Removal (`onRemoved`, when the block is not replaced by the same block) re-runs the scan with `removing` true when the hook was attached or powered, and notifies neighbours when it was powered. The transition table: powered rises: click_on; powered falls: click_off; otherwise attached rises: attach; otherwise attached falls: detach.

### 6.27 `TripWireBlock` (`tripwire`)

- Properties `attached`, `disarmed`, `east`, `north`, `powered`, `south`, `west` (128 states, sorted order attached, disarmed, east, north, powered, south, west), default all false. No collision. Constructed with the hook block (`tripwire_hook`). Shape: `column(16, 1, 2.5)` (y 1 to 2.5) when `attached`, else `column(16, 0, 8)` (y 0 to 8). Entity-inside collision equals the shape. Instrument HARP, sound STONE, hardness 0.
- Placement: each horizontal side = the connection rule: the neighbour is the hook with `facing` equal to the opposite of the direction toward the neighbour, or the neighbour is another tripwire. An update from a horizontal direction recomputes that side.
- `onPlace` (when the previous state was not this block) and removal run `updateSource`: for the south and west directions, scan 1 to 41 blocks until a hook is reached whose `facing` is the opposite of the scan direction (runs the hook state calculation of 6.26 with this wire as the changed cell and its distance as c) or a non-wire block stops it.
- Breaking with shears in the main hand (`playerWillDestroy`, server) sets `disarmed` true first (flags 260) and emits `shear`.
- Pressing: `entityInside` (server) when not yet powered and no tick is scheduled: `checkPressed` over that entity. `tick` (when powered) runs `checkPressed` over all entities in the shape's bounds at the position. `checkPressed`: pressed = any entity in the list that does not ignore block triggers; if pressed differs from `powered`, set `powered` (`setBlockAndUpdate`) and run `updateSource`; then if pressed schedule a tick in 10, else if it was powered schedule a tick in 1.
- Rotate permutes `north`, `east`, `south`, `west` as in 6.2; mirror swaps sides for the two mirror axes as for vines.

### 6.28 `CommandBlock` (`command_block`)

- Properties `conditional` (2) and `facing` (6 directions: `CommandBlock.FACING` is `DirectionalBlock.FACING`, which is `BlockStateProperties.FACING`; 12 states, sorted order conditional then facing), default facing north, conditional false. Constructed as `CommandBlock(false, properties)`: the `false` is the "automatic" flag copied into its block entity (the impulse command block; the chain and repeating variants are other fields). Unbreakable (-1), resistance 3600000, requires the correct tool for drops, no loot table. Block entity `CommandBlockEntity`; `neighborChanged` (server) feeds the neighbour redstone signal into the entity (`setPoweredAndUpdate`). The execution engine is outside this document (Open question 7).

### 6.29 `BeaconBlock` (`beacon`)

- No properties. Light 15. Redstone conductor false. `noOcclusion`. Shape default (full block). `getColor` returns white. Block entity `BeaconBlockEntity` with a ticker. `useWithoutItem` (server): open the block entity as a menu and award stat `interact_with_beacon`. Hardness 3, resistance 3, instrument HAT, map colour DIAMOND.

### 6.30 `FlowerPotBlock` (`flower_pot` and the 30 `potted_*`)

- No properties (1 state each). Shape `column(6, 0, 6)`. Hardness 0 (instabreak), no occlusion, push reaction POPPED. Not pathfindable.
- Each block is `FlowerPotBlock(potted, props)` where `potted` is the content block, and the constructor records `content to this pot` in a static map. `flower_pot` has content `air`. The 30 potted blocks and their contents: `potted_torchflower` (`torchflower`), `potted_oak_sapling`, `potted_spruce_sapling`, `potted_birch_sapling`, `potted_jungle_sapling`, `potted_acacia_sapling`, `potted_cherry_sapling`, `potted_dark_oak_sapling`, `potted_pale_oak_sapling`, `potted_poplar_sapling` (content blocks `oak_sapling` and so on), `potted_mangrove_propagule` (`mangrove_propagule`), `potted_fern` (`fern`), `potted_dandelion`, `potted_golden_dandelion`, `potted_poppy`, `potted_blue_orchid`, `potted_allium`, `potted_azure_bluet`, `potted_red_tulip`, `potted_orange_tulip`, `potted_white_tulip`, `potted_pink_tulip`, `potted_oxeye_daisy`, `potted_cornflower`, `potted_lily_of_the_valley`, `potted_wither_rose`, `potted_red_mushroom`, `potted_brown_mushroom`, `potted_dead_bush`, `potted_cactus`: the content of `potted_x` is the block `x`. Read from the 31 factory lambdas `lambda$static$199` to `lambda$static$229` of `Blocks`, taken in field order: the constructor argument is `AIR` for `flower_pot` and the block of the matching name for each of the 30 pots (for example `potted_red_mushroom` holds `red_mushroom`, `potted_torchflower` holds `torchflower`, `potted_cactus` holds `cactus`).
- `useItemOn`: the held item must be a `BlockItem` whose block has a registered pot (the map lookup; no entry gives air); when the lookup is air the result is "try with empty hand"; if the target pot is not empty (already potted) the result is CONSUME; otherwise the pot is replaced by the potted block (`setBlockAndUpdate`), `block_change` is emitted, stat `pot_flower` awarded and one item consumed. `useWithoutItem` on a potted block (non-empty): give the player the content item (drop it if the inventory is full) and set the block back to `flower_pot`. On the empty pot it returns CONSUME. Clone item: the content item for a potted block, the default for the empty pot. Update: a DOWN change that makes `canSurvive` false turns it into air.
- Random ticking is only for the eyeblossom pots (outside this range).

### 6.31 `CarrotBlock` and `PotatoBlock` (`carrots`, `potatoes`) over `CropBlock`

- Property `age` 0..7 (8 states), default 0; random ticks only while age < 7 (`isRandomlyTicking` = not max age). No collision. Instabreak. Sound CROP.
- Shape: `boxes(7, i -> column(16, 0, 2 + i))` (heights 2 to 9 for ages 0 to 7); the generic `CropBlock` shape (wheat) uses `2 + 2i` but carrot and potato override it.
- Survive: the block below is in tag `supports_crops` (`mayPlaceOn`) and `rawBrightness(pos, 0) >= 8`.
- Random tick: when `rawBrightness(pos, 0) >= 9` and age < 7, with the stem rule of 5.3 (probability `1 / (floor(25 / speed) + 1)`), age + 1 (flags 2). Bonemeal: valid while not max age; always succeeds; adds `Mth.nextInt(random, 2, 5)` capped at 7. `entityInside` (`CropBlock`, read): on a server level, when the entity is a `Ravager` and the game rule `mob_griefing` is true, the crop block is destroyed with drops (`ServerLevel.destroyBlock(pos, true, entity)`, the drop flag is true and the entity is the ravager); in every case the `VegetationBlock` behaviour then runs.
- Clone item and seed id: carrots give `carrot`, potatoes give `potato` (the base seed item `getBaseSeedId`).

### 6.32 `ButtonBlock` (11 wooden buttons)

- Properties `face`, `facing`, `powered` (24 states, sorted order face, facing, powered), default facing north, powered false, face wall. All eleven use ticks-to-stay-pressed 30 and the wooden block set type with the arrows flag true (see section 4 for the sound).
- Shapes: base = `rotateAttachFace(boxZ(6, 4, 8, 16))` (the box x 5 to 11, y 6 to 10, z 8 to 16 for WALL and north). The shape of a state is the base entry for its `face` and `facing` minus `cube(14)` when powered, minus `cube(12)` when not powered. Hence an unpressed button is 2 pixels thick (z 14 to 16) and a pressed one is 1 pixel thick (z 15 to 16) in the wall-north case.
  Resulting boxes (pixels; computed with the transforms of 2.4 and the two subtractions, `cube(14)` = 1 to 15 and `cube(12)` = 2 to 14 on every axis; the thickness is 2 unpressed and 1 pressed):

| `face` | `facing` | Box when unpressed (powered false) | Box when pressed (powered true) |
|---|---|---|---|
| WALL | north | x 5 to 11, y 6 to 10, z 14 to 16 | x 5 to 11, y 6 to 10, z 15 to 16 |
| WALL | east | x 0 to 2, y 6 to 10, z 5 to 11 | x 0 to 1, y 6 to 10, z 5 to 11 |
| WALL | south | x 5 to 11, y 6 to 10, z 0 to 2 | x 5 to 11, y 6 to 10, z 0 to 1 |
| WALL | west | x 14 to 16, y 6 to 10, z 5 to 11 | x 15 to 16, y 6 to 10, z 5 to 11 |
| FLOOR | north or south | x 5 to 11, y 0 to 2, z 6 to 10 | x 5 to 11, y 0 to 1, z 6 to 10 |
| FLOOR | east or west | x 6 to 10, y 0 to 2, z 5 to 11 | x 6 to 10, y 0 to 1, z 5 to 11 |
| CEILING | north or south | x 5 to 11, y 14 to 16, z 6 to 10 | x 5 to 11, y 15 to 16, z 6 to 10 |
| CEILING | east or west | x 6 to 10, y 14 to 16, z 5 to 11 | x 6 to 10, y 15 to 16, z 5 to 11 |

  For `WALL` the support block is the one on the side opposite to `facing` (the survival test of 5.4 looks at the block opposite to the connected direction, which for WALL is `facing`), so a button with `facing` north hangs on the block to its south and its plate lies at the south edge of its own cell, as in the table. The CEILING rows rest on the order of composition discussed in 2.4 (order confirmed from the Cayley table builder).
- Placement and survival come from `FaceAttachedHorizontalDirectionalBlock` (5.4): placement iterates the looking directions: for a vertical looking direction d the state is face CEILING when d is UP and FLOOR when d is DOWN (the button sits on the block the player is looking at), with `facing` = the placer's horizontal direction; for a horizontal direction d the state is face WALL with `facing` = d.opposite; the first candidate that can survive is used (none returns null). Update: when the changed direction is the connected direction's opposite and the block cannot survive, it becomes air.
- Use: if already powered return CONSUME; otherwise press: set `powered` true, update neighbours, schedule a tick in 30, play the click sound, emit `block_activate`. Neighbour updates go to the block and to the block in the connected direction's opposite (`updateNeighbours`). Signals: direct signal 15 toward the connected direction when powered; own signal 15 when powered; `isSignalSource` true. `tick`: when powered re-check pressing. `entityInside` (server, only when the block set type allows arrows): re-check pressing against arrows (the check looks for an `AbstractArrow` in the shape bounds). Explosions that can trigger blocks press an unpowered button.
- Sound, event and orientation functions follow the same structure for release: `block_deactivate` with the off sound.

### 6.33 Skulls (`skeleton_skull`, `skeleton_wall_skull`, `wither_skeleton_skull`; appendix `wither_skeleton_wall_skull`)

- `AbstractSkullBlock` adds property `powered` (default false) and a `SkullBlockEntity`; placement sets `powered` to the neighbour signal and `neighborChanged` (server) updates it (flags 2). The ticker runs only on the client side for dragon and piglin heads (not in this range). Not pathfindable.
- `SkullBlock` (standing): properties `powered`, `rotation` 0..15 (32 states, sorted order powered, rotation), default powered false, rotation 0. Shape: `column(8, 0, 8)` (x 4 to 12, z 4 to 12, y 0 to 8); outline and collision are the same here (the dragon outline `column(8, 0, 8.5)` and piglin shape `column(10, 0, 8)` apply to other heads). Placement sets `rotation` to `RotationSegment.convertToSegment(context.getRotation())`, where `getRotation()` is the placer's Y rotation in degrees (0.0 with no placer, 2.1 rule 3). `convertToSegment(float)` is `SegmentedAnglePrecision(4).fromDegrees`: the float `yaw * (16 / 360)` rounded with `Math.round` (half rounds up) and masked with 15 (`& 15`, so negative values wrap). Examples: yaw 0 gives 0, yaw 90 gives 4, yaw 180 gives 8, yaw -90 gives (-4 & 15) = 12, yaw 11.25 gives round(0.5) = 1, yaw 10 gives round(0.444) = 0, yaw 359 gives round(15.96) = 16 & 15 = 0. `RotationSegment` names four of the 16 segments by constants: 0 is NORTH_0, 4 EAST_90, 8 SOUTH_180, 12 WEST_270 (`convertToDirection` maps exactly these four values to NORTH, EAST, SOUTH, WEST and every other value to none). Since yaw 0 is a player looking south (2.1 rule 2), segment 0 is the skull whose front points back toward that player, which is why the constant is called NORTH (inferred reading of the naming; how the renderer turns a segment into a model rotation is a client-rendering matter, 12). Rotate and mirror transform `rotation` with the 16-segment rotate and mirror helpers of `Rotation` and `Mirror`.
- `WallSkullBlock`: properties `facing`, `powered` (8 states, sorted order facing, powered), default facing north, powered false. Shape `rotateHorizontal(boxZ(8, 8, 16))` (north: x 4 to 12, y 4 to 12, z 8 to 16). Placement: walk `getNearestLookingDirections`; for each horizontal direction d, the candidate `facing` is d.opposite and it is accepted when the block at `pos + d` is **not** replaceable by this placement (`BlockState.canBeReplaced(context)` is false), i.e. there is a block to hang on; the first accepted candidate wins and none gives no placement.
- `WitherSkullBlock`: the standing wither skeleton skull; after placement (`setPlacedBy`) and for its wall variant it calls `checkSpawn`: server only, the skull must be a wither skeleton skull or wall skull, `y >= minY` and difficulty not peaceful. The pattern `witherPatternFull` is three rows `^^^`, `###`, `~#~` where `^` is a wither skeleton skull or wall skull block, `#` a block in tag `wither_summon_base_blocks` and `~` an air block. When it matches: create a `wither` entity (spawn reason TRIGGERED), clear the pattern blocks, position it at (x + 0.5, y + 0.55, z + 0.5) where (x, y, z) is the block at cell (1, 2, 0) of the match (the match lookup is called with the arguments 1, 2, 0; by the pattern's shape that is the middle column of the last row `~#~`, the lowest block of the stem, with the argument order of the lookup inferred), with yaw 0 when the pattern's forward direction is on the X axis and 90 otherwise (the body rotation takes the same value, pitch 0), make it invulnerable, trigger the `summoned_entity` criterion for every `ServerPlayer` whose bounding box intersects the wither's bounding box inflated by 50 blocks on every side (`getEntitiesOfClass`), add the entity (`addFreshEntity`) and update the pattern blocks (`CarvedPumpkinBlock.updatePatternBlocks`). All constants (0.5, 0.55, 90.0, 50.0) were read in `WitherSkullBlock.checkSpawn`. `canSpawnMob(level, pos, stack)` (used by dispensers): the stack is the wither skeleton skull item, `y >= minY + 2`, difficulty not peaceful, not client, and `witherPatternBase` (rows `###`, `~#~`) matches at the position. Open question 3 covers pattern orientation.

## 7. Block entities and menus named in this part

| Block | Block entity class | Menu or ticker |
|---|---|---|
| `enchanting_table` | `EnchantingTableBlockEntity` | client ticker only; menu `EnchantmentMenu` |
| `brewing_stand` | `BrewingStandBlockEntity` | server ticker `serverTick`; the entity is the menu |
| `ender_chest` | `EnderChestBlockEntity` | server ticker; 3-row chest menu on the player's ender inventory |
| `beacon` | `BeaconBlockEntity` | ticker; the entity is the menu |
| `command_block` | `CommandBlockEntity` | automatic flag false for this field |
| skulls | `SkullBlockEntity` | none in this range |
| `end_portal` | `TheEndPortalBlockEntity` | none |

Their NBT schemas and ticks are RS13's (document 31); menus belong to the menus round (GAP-19).

## 8. Worked examples

All state offsets are relative to the first state of `mushroom_stem` (section 3); the implementer adds the state-id base of part 1 to 3. Each uses the formula of 04 section 5.2 with the properties sorted by name.

### 8.1 A cobblestone wall state

`cobblestone_wall` (id 460, relative first state 2095, 324 states). Sorted properties and counts: `east` 3, `north` 3, `south` 3, `up` 2, `waterlogged` 2, `west` 3. Strides (product of the counts after it): west 1, waterlogged 3, up 6, south 12, north 36, east 108.

State: east none, north low, south tall, up false, waterlogged true, west none. Value indices: east 0 (`none`), north 1 (`low`), south 2 (`tall`), up 1 (`false` is second), waterlogged 0 (`true` is first), west 0. Offset = 0 * 108 + 1 * 36 + 2 * 12 + 1 * 6 + 0 * 3 + 0 = 66, so relative state 2161. The default state (up true = 0, sides none = 0, waterlogged false = 1) has offset 3 and relative state 2098.

### 8.2 A stairs state

`brick_stairs` (id 420, relative first state 784, 80 states). Sorted: `facing` 4, `half` 2, `shape` 5, `waterlogged` 2. Strides: waterlogged 1, shape 2, half 10, facing 20. State: facing east (index 1), half top (index 0), shape outer_left (index 3), waterlogged false (index 1): offset 20 + 0 + 6 + 1 = 27, relative state 811. Default (north 0, bottom 1, straight 0, false 1): offset 11, relative state 795.

### 8.3 A vine state

`vine` (id 416, relative first 464, 32 states). Sorted: `east`, `north`, `south`, `up`, `west`, all boolean (strides 16, 8, 4, 2, 1). State east true, north false, south false, up true, west false: indices 0, 1, 1, 0, 1: offset 0 + 8 + 4 + 0 + 1 = 13, relative state 477. Default (all false) is offset 31, relative state 495. Its shape for the first state is the union of the east plate and the up plate (section 6.7).

### 8.4 A button state

`oak_button` (id 495, relative first 2790, 24 states). Sorted: `face` 3, `facing` 4, `powered` 2. Strides: powered 1, facing 2, face 8. State face ceiling (index 2), facing east (1), powered true (0): offset 16 + 2 + 0 = 18, relative state 2808. Default (face wall = 1, north = 0, false = 1): offset 8 + 0 + 1 = 9, relative state 2799.

### 8.5 A tripwire and a skull state

`tripwire` (id 453, relative first 1713, 128 states). Sorted: `attached`, `disarmed`, `east`, `north`, `powered`, `south`, `west`, all boolean (strides 64, 32, 16, 8, 4, 2, 1). State attached true, disarmed false, east true, north false, powered true, south false, west false: indices 0, 1, 0, 1, 0, 1, 1: offset 32 + 8 + 2 + 1 = 43, relative state 1756. Default (all false, indices all 1) is offset 127, relative state 1840.

`skeleton_skull` (id 506, relative first 3054, 32 states). Sorted: `powered` 2, `rotation` 16 (strides 16 and 1). State powered true, rotation 5: offset 0 * 16 + 5 = 5, relative state 3059. Default (powered false, rotation 0): offset 16, relative state 3070.

### 8.6 Registry ids around the copper collections

`iron_bars` is id 391. `copper_bars` is 392, `exposed_copper_bars` 393, `weathered_copper_bars` 394, `oxidized_copper_bars` 395, `waxed_copper_bars` 396, `waxed_exposed_copper_bars` 397, `waxed_weathered_copper_bars` 398, `waxed_oxidized_copper_bars` 399, then `iron_chain` 400, `copper_chain` 401 to `waxed_oxidized_copper_chain` 408, `glass_pane` 409, `pumpkin` 410, `melon` 411. The sequence continues in the table of section 3 to `wither_skeleton_skull` 508.

### 8.7 Shapes in pixel boxes

Glass pane with `north` true and `east` true: post x 7 to 9, z 7 to 9, y 0 to 16; north arm x 7 to 9, z 0 to 8, y 0 to 16; east arm x 8 to 16, z 7 to 9, y 0 to 16 (the north arm turned a quarter turn clockwise: a point (x, z) maps to (16 - z, x)). The union is the outline and the collision shape.

Cobblestone wall, `up` true, `north` low, `east` tall, others none: outline = post x 4 to 12, z 4 to 12, y 0 to 16; north low arm x 5 to 11, z 0 to 11, y 0 to 14; east tall arm x 5 to 16, z 5 to 11, y 0 to 16. The collision shape of the same state has post y 0 to 24, the north arm y 0 to 24 and the east arm y 0 to 24.

Oak fence gate facing north, closed, not in a wall: outline x 0 to 16, y 0 to 16, z 6 to 10; collision x 0 to 16, y 0 to 24, z 6 to 10; the same gate open has an empty collision shape. In a wall the outline becomes x 0 to 16, y 0 to 13, z 6 to 10.

Bottom stairs facing north, straight: slab y 0 to 8 over the whole block, plus x 0 to 16, y 8 to 16, z 0 to 8. Bottom stairs facing north, outer_right: the key into the outer map is `facing.getClockWise()` = east, so the high quarter is the quarter obtained by turning the north-west quarter (x 0 to 8, z 0 to 8) a quarter turn clockwise, which is the north-east quarter x 8 to 16, z 0 to 8 (derived from the rotation rule of 2.4). Outer_left uses the key `facing` and so the north-west quarter.

Cauldron: the cauldron shape is the full cube minus the four boxes of 6.18; the level-2 water cauldron's entity-inside shape adds the box x 2 to 14, z 2 to 14, y 4 to 12.

### 8.8 Crop growth

A carrot with no other carrots nearby, planted above farmland, and a light level of at least 9:

- All nine farmland blocks wet (`moisture` above 0): the centre contributes 3.0 and each of the eight others 3.0 / 4 = 0.75, so the sum is 3.0 + 6.0 = 9.0 and the speed is 1 + 9.0 = 10.0. The age advances on a random tick when `nextInt(floor(25.0 / 10.0) + 1) = nextInt(3)` returns 0, a probability of 1/3.
- All nine farmland blocks dry (moisture 0, but in `grows_crops`): centre 1.0 and eight times 0.25 = 2.0, speed 4.0; `nextInt(floor(6.25) + 1) = nextInt(7)`, probability 1/7.
- The wet case with another carrot directly west of the crop and another directly north: both the east-west and north-south tests are true, so the speed is halved to 5.0 and the test is `nextInt(floor(25 / 5) + 1) = nextInt(6)`, probability 1/6.
- The wet case with only a diagonal carrot (north-west): halved once, speed 5.0.

### 8.9 Stem fruit placement

A pumpkin stem at age 7 whose random tick passes the light test and the 1 / (floor(25 / speed) + 1) test chooses a direction (for example SOUTH). If the block south of the stem is air and the block below that position is in tag `supports_pumpkin_stem_fruit`, the south position becomes a `pumpkin` and the stem becomes `attached_pumpkin_stem` with `facing` south. If the pumpkin is later broken, the update on the attached stem (changed direction SOUTH, new neighbour not a pumpkin) turns it back into a `pumpkin_stem` with `age` 7.

## 9. Validation

### 9.1 Structural invariants (tests can recompute these)

| # | Check | Expected |
|---|---|---|
| V1 | Number of `Blocks` fields with index 315 to 419 (of the 911 declared public fields; the initialiser has 914 `putstatic` instructions, three of which assign private predicates) | 105 |
| V2 | Number of blocks the range registers | 119 (103 single fields plus 2 collections of 8) |
| V3 | Sum of state counts in the range | 3126 (section 3) |
| V4 | Block id of `mushroom_stem` and of `wither_skeleton_skull` | 390 and 508 (inferred from the field order and collection sizes, consistent with 24 part 3's `red_mushroom_block` = 389) |
| V5 | State count per class | `HugeMushroomBlock` 64, `IronBarsBlock` and `FenceBlock` 32, `ChainBlock` 6, `StemBlock` and crops 8, `AttachedStemBlock` 4, `VineBlock` 32, `MultifaceBlock` and `GlowLichenBlock` 128, `FenceGateBlock` 32, `StairBlock` 80, `SlabBlock` 6, `WallBlock` 324, `NetherWartBlock` 4, `BrewingStandBlock` 8, `LayeredCauldronBlock` 3, `EndPortalFrameBlock` 8, `RedstoneLampBlock` and `MyceliumBlock` 2, `CocoaBlock` 12, `ShelfMushroomBlock` 8, `EnderChestBlock` 8, `TripWireHookBlock` 16, `TripWireBlock` 128, `CommandBlock` 12, `ButtonBlock` 24, `SkullBlock` 32, `WallSkullBlock` 8; all others 1 |
| V6 | Families | 9 stairs, 3 walls, 11 buttons, 31 flower-pot blocks (`flower_pot` plus 30 `potted_*`), 8 copper bars and 8 copper chains plus `iron_bars`, `iron_chain`, `glass_pane` |
| V7 | Every default state has the stated property values | table of section 3, last column |
| V8 | Light emission | `enchanting_table` 7, `ender_chest` 7, `beacon` 15, `end_portal` 15, `lava_cauldron` 15, `brewing_stand` 1, `dragon_egg` 1, `end_portal_frame` 1, `redstone_lamp` 15 when lit, `glow_lichen` 7 when any face is set; every other block 0 |
| V9 | Unbreakable blocks (destroy time -1) | `end_portal`, `end_portal_frame`, `command_block`, all with resistance 3600000 |
| V10 | Blocks with no collision | `attached_pumpkin_stem`, `attached_melon_stem`, `pumpkin_stem`, `melon_stem`, `vine`, `glow_lichen`, `resin_clump`, `nether_wart`, `end_portal`, `tripwire_hook`, `tripwire`, `carrots`, `potatoes`, the 11 buttons |

### 9.2 Test vectors

| Input | Expected output |
|---|---|
| Relative state of `cobblestone_wall` east none, north low, south tall, up false, waterlogged true, west none | 2161 (section 8.1) |
| Default relative state of `brick_stairs` | 795 |
| Relative state of `vine` east true, north false, south false, up true, west false | 477 |
| Relative state of `oak_button` face ceiling, facing east, powered true | 2808 |
| Relative state of `tripwire` attached, east, powered true; others false | 1756 (disarmed false, north false, south false, west false) |
| Default relative state of `skeleton_skull` | 3070 |
| Crop speed, wet farmland all around, no other crops | 10.0; advance probability 1/3 |
| Crop speed, dry farmland, no other crops | 4.0; 1/7 |
| Crop speed, wet, same crop west and north | 5.0; 1/6 |
| `rotation` of a standing skull for yaw degrees y | round(y * 16 / 360) masked with 15 (`SegmentedAnglePrecision(4)`) |
| Shape of `oak_fence_gate` facing east, closed | x 6 to 10, y 0 to 16, z 0 to 16 (turned entry); collision y 0 to 24 |
| Shape of `cocoa` age 2, facing north | x 4 to 12, y 3 to 12, z 1 to 9 |
| Shape of a `glass_pane` with no side set | x 7 to 9, y 0 to 16, z 7 to 9 |
| Nether brick fence collision with no side set | x 6 to 10, y 0 to 24, z 6 to 10 |
| `getNearestLookingDirections` order for a player at yaw 0, pitch 0 who clicked the top face of a block, placing beside it (`replacingClickedOnBlock` false) | `orderedByNearest` gives [SOUTH, DOWN, WEST, EAST, UP, NORTH]; the opposite of the clicked face (DOWN) is at index 1, so entry 0 becomes DOWN and SOUTH moves to index 1: [DOWN, SOUTH, WEST, EAST, UP, NORTH] |
| `Direction.fromYRot(-90)`, `fromYRot(0)`, `fromYRot(90)`, `fromYRot(180)` | EAST, SOUTH, WEST, NORTH |
| Bottom stair `facing` north `inner_left`, mirror `LEFT_RIGHT` | `facing` south, `inner_right` |
| East stair `inner_left`, mirror `FRONT_BACK` | `facing` west, `inner_left` |
| Pane or fence with only `north` true, rotation `CLOCKWISE_90` | only `east` true |
| Pane with only `north` true, mirror `LEFT_RIGHT` | only `south` true |
| `rotation` of a standing skull at yaw -90 and at yaw 11.25 | 12 and 1 |
| Chance per random tick that a lone unaffected copper bars block oxidises | 0.05688889 * 0.75 = 0.04267 (5.5) |
| Hook at P facing east, wires at P + 1 to P + 3, hook facing west at P + 4, nothing powered, `removing` false | both hooks `attached` true, `powered` false |
| Same line with the wire at P + 2 powered | both hooks `attached` true, `powered` true |
| Same line with air at P + 2 | both hooks `attached` false, `powered` false |

### 9.3 Cross-document consistency

- 04 section 5.2 (state order and id formula) was applied to every example above and agrees with each class's property list: the property declaration order in the artifact (for example the order of `createBlockStateDefinition` calls in `FenceGateBlock`, which is not alphabetical) is irrelevant, only the sorted names count.
- 06 (palettes) uses these state ids; nothing here changes the palette rules.
- 17 section 3.16 and Appendix A (tool and tier tables, `mineable/*`) use hardness and `requiresCorrectToolForDrops`; the values here are the registry side of that table.
- Document 11 section 8 places `emerald_ore` and `deepslate_emerald_ore` in worldgen and section 9 covers ore drops and experience; their registry rows are here (`emerald_ore` hardness 3, `deepslate_emerald_ore` hardness 4.5, both resistance 3, experience range 3 to 7 inclusive from `DropExperienceBlock`).

## Open questions

1. **Cross-document state base (not this document).** Closed for this document: with `command_block` at 12 states (six-way `facing` times `conditional`), every relative first state here matches 24 part 8 (checked for the 104 rows part 8 lists; its listing omits the 16 copper rows), base 9628, and 12754 - 9628 = 3126. Remaining conflict for the owner of 24 part 3: it gives `red_mushroom_block` first state 9312, part 8 gives 9564. Searched: tables of parts 3, 4, 5 and 8 as quoted.
2. (Closed.) The operand order of `OctahedralGroup.compose` was traced through the Cayley table builder: permutations compose a then b, the invert flag of axis A is a.inverts(A) XOR b.inverts(a.permutation.permuteAxis(A)), which under the shape rule means b is applied first, then a. The CEILING entry therefore applies the X quarter turn first, then the half turn about Y.
3. **Block pattern orientation.** For the end-portal frame pattern (`?vvv?`, `>???<` three times, `?^^^?`) and the wither patterns (`^^^`, `###`, `~#~` and `###`, `~#~`), the mapping from the pattern's rows, columns and depth to world axes, the argument order of the match lookup (the wither is placed at the cell (1, 2, 0) of the match, 6.33), and the meaning of the "forwards" direction belong to `BlockPattern.find` and `BlockPatternBuilder`, which were not read. `makeInvulnerable` (the number of ticks of invulnerability of the spawned wither) was not read.
4. **Copper wax and lightning interactions.** The weathering engine is specified (5.5). The conversions to and from the waxed blocks (honeycomb, axes scraping and waxing off, lightning strikes on lightning rods) are item and entity behaviour and were not read here.
5. **`MultifaceSpreader`.** The spreading algorithm used by glow lichen bonemeal (and by sculk-like growth elsewhere) is not specified here.
6. **Cauldron interactions.** The `CauldronInteractions` tables (buckets, bottles, dyed items, banners, shulker boxes, powder snow), the stalactite drip tick delays and `PointedDripstoneBlock.findStalactiteTipAboveCauldron` were not read. Items belong to RS5, interactions to RS9.
7. **Command block engine.** The execution engine, chain and repeating variants, the conditional rule and `CommandBlockEntity` are outside this round (RS13 and the commands documents).
8. **Decoded boolean expressions.** The following were decoded from jump structure and not re-read a second time: fence gate shape selection (`in_wall`, `open`), end portal frame eye shape, tripwire shape (`attached`), button powered cube (14 powered, 12 unpowered), `FlowerPotBlock.useItemOn` result order, and the cocoa, shelf mushroom and wall skull placement filters. Re-read and confirmed in this round: stairs half and shape keys, slab replace rule, vine empty-shape fallback and placement, `PumpkinBlock` carve numbers, tripwire hook scan values.
9. **Stair mirror, inner shapes.** The `FRONT_BACK` mirror leaves `inner_left` and `inner_right` unchanged apart from the half turn, while `LEFT_RIGHT` swaps them (6.10). This was read twice from the two jump tables; there is no behavioural cross-check available without running the artifact, so an implementer that finds the asymmetry surprising should re-read `StairBlock.mirror` before changing it.
10. **Constant tables owned elsewhere.** `MapColor`, `SoundType` and `NoteBlockInstrument` constant values and the `PushReaction` semantics are cited by name only; their tables belong to 24 part 1.
11. **Lighting, redstone helpers, menus and entities.** `LightEngine.getLightDampeningInto` and `BlockState.getLightDampening` used by the mycelium survival test belong to the light engine round (RS15). `Level.hasNeighborSignal`, `getDirectSignal`, `ExperimentalRedstoneUtils.initialOrientation` and the neighbour-update ordering used by buttons, lamps, gates, hooks and skulls are RS12's. The menu classes (`EnchantmentMenu`, brewing stand and beacon menus, the chest menu) and block-entity schemas are outside this round (GAP-19 and RS13). The leash knot entity (`LeashFenceKnotEntity`, its placement sound and `Leashable` rules) belongs to the entity documents.
12. **Tags named but not listed.** Tag memberships (`supports_vegetation`, `supports_crops`, `supports_pumpkin_stem`, `supports_pumpkin_stem_fruit`, `supports_melon_stem`, `supports_melon_stem_fruit`, `supports_nether_wart`, `supports_cocoa`, `supports_lily_pad`, `walls`, `fences`, `wooden_fences`, `shulker_boxes`, `bars`, `snow`, `grows_crops`, `enchantment_power_provider`, `enchantment_power_transmitter`, `wall_post_override`, `wither_summon_base_blocks`, `causes_suffocation`, `fire`) are data, delivered by the data pack; the extraction tool must produce them. The membership of `mineable/*` and `needs_*_tool` for the blocks of this part (4.1) was read from the data files in the archive, and `wither_summon_base_blocks` was read as `soul_sand` and `soul_soil`; the extraction tool, not this document, is the authority.
13. **Skull rotation naming.** The numeric conversion from yaw to segment is exact (6.33). The reading that segment 0 is called NORTH because the skull front points back at a player looking south is inferred from the names; the renderer's use of the segment belongs to the client rendering document (12).
