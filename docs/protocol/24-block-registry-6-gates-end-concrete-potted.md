# Block registry, part 6: gates, fences, doors, the End, concrete, the sea and bamboo (Blocks fields 525 to 629)

| Item | Value |
|---|---|
| Covers | The 105 `Blocks` fields `MANGROVE_FENCE_GATE` (field 525) to `POTTED_BAMBOO` (field 629): three fence gates, ten fences, ten doors, end rod, chorus plant and flower, purpur block, slab, pillar and stairs, end stone bricks, torchflower crop, pitcher crop and plant, beetroots, dirt path, end gateway, repeating and chain command blocks, frosted ice, magma block, nether wart block, red nether bricks, bone block, structure void, observer, shulker boxes (plain and the 16 dyed), glazed terracotta, concrete, concrete stairs, concrete slabs and concrete powder (16 each), kelp, kelp plant, dried kelp block, turtle egg, sniffer egg, dried ghast, the live and dead coral blocks, coral plants, coral fans and coral wall fans, sea pickle, blue ice, conduit, bamboo sapling, bamboo and potted bamboo. 105 fields register 195 blocks (block ids 689 to 883) with 3094 block states. For each field: key, class, state properties with value order, state count, default state, builder values (hardness, resistance, tool, light, map colour, sound, push reaction, instrument, flags), the voxel shapes, and the placement, survival and interaction rules that the registry needs (GAP-1, and the GAP-29 and GAP-30 columns). |
| Source artifact | `minecraft-26.3-client.jar`, SHA-256 `4508d006323f24fa02876310c192d739af56516eb259000ac50f0909a68c9a2d` (the artifact already recorded in [README.md](README.md); version 26.3, protocol 777, data version 5023) |
| Method | Static reading of the shipped bytecode (`javap -c -p -constants`, and `javap -v` for the bootstrap method arguments of lambdas), with no execution. The `Blocks` static initialiser was summarised field by field (builder calls, factory lambda, helper); each block class named below was read for its state definition, shapes, placement, survival and update methods. Values not read are marked "(inferred)" or "(recalled, not verified)" and listed in the Open questions. |
| Status | Round RS4, part 6 of 8 (design map Part 5 GAP-1; GAP-29 and GAP-30 columns) |
| Siblings | Part 1: [24-block-registry-1-model-and-foundation.md](24-block-registry-1-model-and-foundation.md) (cited as "24 part 1"; it defines the model and every column); part 2: [24-block-registry-2-leaves-flora-signs.md](24-block-registry-2-leaves-flora-signs.md); part 3: [24-block-registry-3-signs-doors-redstone.md](24-block-registry-3-signs-doors-redstone.md); part 4: [24-block-registry-4-stems-glass-skulls.md](24-block-registry-4-stems-glass-skulls.md); part 5: [24-block-registry-5-quartz-concrete-gates.md](24-block-registry-5-quartz-concrete-gates.md); part 7: [24-block-registry-7-stairs-slabs-walls-workstations.md](24-block-registry-7-stairs-slabs-walls-workstations.md); part 8: [24-block-registry-8-blackstone-copper-deepslate-modern.md](24-block-registry-8-blackstone-copper-deepslate-modern.md). Each is cited as "24 part N". Flammability odds are in 17 section 3.3a. |

Class, method and field names in backticks say where a fact was read. They are not the design. "04 §5" means section 5 of
[04-registry-sync.md](04-registry-sync.md); "46 §14" means section 14 of [46-registry-ids.md](46-registry-ids.md); "33 §2.4" means
section 2.4 of [33-world-simulation.md](33-world-simulation.md); the design map is `docs/design/README.md`.

Data versus code (design map R7). This document specifies code: ids, state properties, builder values, shapes, placement
and survival rules, block-local behaviour. It does not list data that the extraction tool copies out of the jar: loot
tables, recipes, block tags, block models and block states JSON. Where a rule reads a block tag by name (for example
`supports_crops`), the tag name is given and the contents are data (24 part 1 §12).

## Contents

1. Scope and conventions
2. Block ids and keys of this part
3. Shared lookups used by the rows (wood and block set types, dye colours, copy builders, helper constants)
4. Shape notation and the shape helpers used here
5. State properties used here
6. Families (rules, shapes, placement, survival, updates)
7. The registry rows (tables 7.1, 7.2 and 7.3)
8. Tint and placement columns (GAP-29 and GAP-30) for this part
9. Worked examples
10. Validation
11. Open questions

---

## 1. Scope and conventions

- Field numbering is the declaration order of the `public static final` fields of `net.minecraft.world.level.block.Blocks`
  (0-based; this order equals the registration order, 24 part 1 §2.2). Field 525 is `MANGROVE_FENCE_GATE` and field 629 is
  `POTTED_BAMBOO`. Fields 525 to 629 are 105 fields. The previous field (524) is `PALE_OAK_FENCE_GATE`, the next (630) is
  `VOID_AIR`.
- Columns, units and flag spellings are those of 24 part 1 §7 (hardness, resistance, tool required, light, map colour, sound,
  push reaction, instrument, flags). Numbers are as written in the artifact with the `f` suffix dropped. A hardness of
  -1.0 is unbreakable. Strength is written as hardness and resistance; `strength(v)` means both equal `v`.
- A builder call order matters when two calls set the same field: the last call wins. This part has two cases:
  `BAMBOO_SAPLING` and `BAMBOO` call `instabreak()` (strength 0) and then `strength(1.0)`, so their hardness and resistance
  are 1.0, not 0.
- Where this document says "shared rule", the rule is in 24 part 1 and is not repeated: builder defaults (§4.1 there),
  setters (§4.2), copy builders (§4.3), offset functions (§4.4), derived per-state values (§5), the shape model and its
  helpers (§6), column definitions (§7), `MapColor` (§8.1), `PushReaction` (§8.2), `NoteBlockInstrument` (§8.3),
  `SoundType` (§8.4), tint classes (§9) and the replaceable and `canSurvive` model (§10).
- Behaviour owned by other documents is named and not specified here: fluids and waterlogging mechanics (29a), falling
  blocks and growth rules (29b), redstone and pistons (30, in particular 30 part 3 for push reactions), block entities (31)
  and their menus (40), block updates, neighbour notification order and the general placement path (29), random ticks
  selection (33 §2.4), the portal and end gateway rules (39), chorus tree generation (35 part 7). Where such a document is
  needed for a rule below, the section says so.
- Hardness and resistance feed the break formula of 13 §2.1 and the table of 13 §2.6; a hardness of 0.0 is an instant break.
- Tag names are written as in `net.minecraft.tags.BlockTags` (the key is `minecraft:<name>`). The set of blocks in a tag is
  data (extraction tool) and is read from the loaded data pack.

## 2. Block ids and keys of this part

1. **Registration.** Every row is registered by the private `Blocks.register` helpers (24 part 1 §2.1). The id of a block is
   the number of blocks registered before it.
2. **Collections.** Six fields of this part are `ColorCollection` fields: `DYED_SHULKER_BOX`, `GLAZED_TERRACOTTA`, `CONCRETE`,
   `CONCRETE_STAIRS`, `CONCRETE_SLAB`, `CONCRETE_POWDER`. Each registers 16 blocks, consecutively, in the dye order below,
   at the position of the field (24 part 1 §2.3). `CONCRETE_STAIRS` and `CONCRETE_SLAB` are built by `zipMap` over the 16
   dye colours and the matching `CONCRETE` block of the same colour (`CONCRETE.pick(colour)`). The key of a collection block
   is `<colour>_<base>` (the string concatenation pattern is `<first>_<second>` with the colour name first,
   `ColorCollection.prefixWithColor`); for `DYED_SHULKER_BOX` the base is `shulker_box`.
3. **Dye order** (the `ColorCollection` record order, which is also the registration order): 0 `white`, 1 `orange`, 2
   `magenta`, 3 `light_blue`, 4 `yellow`, 5 `lime`, 6 `pink`, 7 `gray`, 8 `light_gray`, 9 `cyan`, 10 `purple`, 11 `blue`, 12
   `brown`, 13 `green`, 14 `red`, 15 `black`. The `DyeColor` id equals this index (read from the `DyeColor` constants).
4. **Id of field 525.** 689. Check: field index 525 plus 15 for each of the 10 earlier 16-block collection fields (`BED`,
   `WOOL`, `WOOL_STAIRS`, `WOOL_SLAB`, `STAINED_GLASS`, `DYED_TERRACOTTA`, `STAINED_GLASS_PANE`, `CARPET`, `BANNER`,
   `WALL_BANNER`) plus 7 for each of the 2 earlier 8-block weathering copper fields (`COPPER_BARS`, `COPPER_CHAIN`):
   525 + 150 + 14 = 689. The sum over all 911 fields is 1286 registered blocks (counted from the static initialiser; 24 part N
   cross-checks).
5. **Keys.** For every field of this part except the collections the block key is the lower-case field name
   (`BlockItemIds.<FIELD>` or `BlockIds.<FIELD>` string, all read; the one field whose constant has a different name is `BEETROOTS`, registered with `BlockItemIds.BEETROOT_CROP`). Two further facts:
   - Fields registered through `BlockIds` (no item): `END_GATEWAY`, `FROSTED_ICE`, `KELP_PLANT`, the ten `*_CORAL_WALL_FAN`
     fields, `BAMBOO_SAPLING` and `POTTED_BAMBOO`.
   - Item keys that differ from the block key (`BlockItemId.create(block, item)`): `TORCHFLOWER_CROP` has the item
     `torchflower_seeds`, `PITCHER_CROP` has `pitcher_pod`, `BEETROOTS` (constant `BlockItemIds.BEETROOT_CROP`; block key `beetroots`) has `beetroot_seeds`. Every
     other field with an item uses the block key as item key (including each colour of every collection).
6. **Ids of the fields** are in table 7.1 (first id of a collection and the count).

## 3. Shared lookups used by the rows

### 3.1 Wood set types

Fence gates and doors take their sounds from the wood set. `WoodType` (fence gate) and `BlockSetType` (door) are records
constructed in static initialisers. The ten wood types of this part:

| Wood | `WoodType` fence gate close / open event | `WoodType.soundType` | `BlockSetType` door close / open event | `BlockSetType.soundType` | canOpenByHand, canOpenByWindCharge, canButtonBeActivatedByArrows |
|---|---|---|---|---|---|
| spruce, birch, jungle, acacia, dark oak, pale oak, mangrove, poplar | `FENCE_GATE_CLOSE` / `FENCE_GATE_OPEN` | `WOOD` | `WOODEN_DOOR_CLOSE` / `WOODEN_DOOR_OPEN` | `WOOD` | true, true, true |
| cherry | `CHERRY_WOOD_FENCE_GATE_CLOSE` / `..._OPEN` | `CHERRY_WOOD` | `CHERRY_WOOD_DOOR_CLOSE` / `..._OPEN` | `CHERRY_WOOD` | true, true, true |
| bamboo | `BAMBOO_WOOD_FENCE_GATE_CLOSE` / `..._OPEN` | `BAMBOO_WOOD` | `BAMBOO_WOOD_DOOR_CLOSE` / `..._OPEN` | `BAMBOO_WOOD` | true, true, true |

(Read from the one-argument and the full constructors of `BlockSetType` and `WoodType`; the one-argument forms are used for
spruce, birch, jungle, acacia, dark oak, pale oak, mangrove and poplar. `poplar` is a wood type of this version.) A
door's or gate's block sound is set by the class constructor from the set type (`Properties.sound(type.soundType())`), after
the builder chain: the constructor value overrides any `sound` call of the chain. Fences have no set type; their chain sets
the sound itself (`WOOD`, `CHERRY_WOOD` for cherry, `BAMBOO_WOOD` for bamboo). The pressure plate sensitivity and the
trapdoor, button and pressure plate events of the set types are not used by the rows of this part (24 part N).

Planks map colours used by the rows (`Block.defaultMapColor()` of the planks block, read from the planks rows): spruce
`PODZOL`, birch `SAND`, jungle `DIRT`, acacia `COLOR_ORANGE`, cherry `TERRACOTTA_WHITE`, dark oak `COLOR_BROWN`, pale oak
`QUARTZ`, mangrove `COLOR_RED`, poplar `COLOR_LIGHT_GRAY`, bamboo `COLOR_YELLOW`.

### 3.2 Dye colours

`DyeColor.getMapColor()` (the field `mapColor`, first of the two map colours in the constructor; the second is
`getTerracottaColor`): white `SNOW`, orange `COLOR_ORANGE`, magenta `COLOR_MAGENTA`, light_blue `COLOR_LIGHT_BLUE`, yellow
`COLOR_YELLOW`, lime `COLOR_LIGHT_GREEN`, pink `COLOR_PINK`, gray `COLOR_GRAY`, light_gray `COLOR_LIGHT_GRAY`, cyan
`COLOR_CYAN`, purple `COLOR_PURPLE`, blue `COLOR_BLUE`, brown `COLOR_BROWN`, green `COLOR_GREEN`, red `COLOR_RED`, black
`COLOR_BLACK`. The colours of the concrete, glazed terracotta, concrete powder and shulker box rows use this function
(`Properties.mapColor(DyeColor)`); the one exception is the purple dyed shulker box (section 6.12).

### 3.3 Copy builders used here

`ofLegacyCopy` and `ofFullCopy` are specified in 24 part 1 §4.3. In this part:

| Row | Builder |
|---|---|
| `PURPUR_STAIRS` | `ofLegacyCopy(PURPUR_BLOCK)` then `isViewBlocking(NEAR_PLANE_INTERSECTS_OUTLINE)` |
| `PURPUR_SLAB` | `ofLegacyCopy(PURPUR_BLOCK)`, `isViewBlocking(NEAR_PLANE_INTERSECTS_OUTLINE)`, then `destroyTime(2.0)` (hardness 2.0, resistance stays 6.0) |
| `<colour>_CONCRETE_STAIRS` | `ofFullCopy(<colour>_CONCRETE)` then `isViewBlocking(NEAR_PLANE_INTERSECTS_OUTLINE)` |
| `<colour>_CONCRETE_SLAB` | `ofLegacyCopy(<colour>_CONCRETE)` then `isViewBlocking(NEAR_PLANE_INTERSECTS_OUTLINE)` |

`NEAR_PLANE_INTERSECTS_OUTLINE` (a static predicate of `Blocks`, arguments state, level, position, box): the list of boxes
of the state's occlusion shape (`VoxelShape.toAabbs`); each box is moved to the block position (`AABB.move`); the predicate is
true as soon as one moved box intersects the argument box (`AABB.intersects`), else false (the argument box is the camera's
near-plane box, inferred from the name). It replaces the default `isViewBlocking` (which is `isSuffocating`) for stairs and
slabs. It is a client-side camera rule; no server rule reads it.

The copied blocks give: the stairs and slabs of this part have the instrument, map colour, sound, push reaction,
`requiresCorrectToolForDrops` and strength of their base. Because the stairs use `ofFullCopy`, they also inherit the base
block's `isRedstoneConductor`, `isValidSpawn`, `isSuffocating`, `postProcess`, loot table key function and description key
function (those two are functions of the block key, so each stairs block still uses its own `blocks/<path>` key). The legacy
copies (purpur stairs, purpur slab, concrete slab) leave those fields at the builder defaults.

### 3.4 Helper constants and helper builders of `Blocks` used by this part

| Helper | Value |
|---|---|
| `shulkerBoxProperties(mapColor)` | `of()`, `mapColor(c)`, `forceSolidOn()`, `strength(2.0)`, `dynamicShape()`, `noOcclusion()`, `isSuffocating(NOT_CLOSED_SHULKER)`, `pushReaction(POPPED)` |
| `NOT_CLOSED_SHULKER` | for a position whose block entity is a `ShulkerBoxBlockEntity`: its `isClosed()`; for any other block entity or none: true. (The name is misleading: the predicate is true when the box is closed.) |
| `flowerPotProperties()` | `of()`, `instabreak()`, `noOcclusion()`, `pushReaction(POPPED)` |
| `wallVariant(fan, false)` | `of()` then `overrideLootTable(fan.getLootTable())`; the boolean (false for all rows of this part) would also override the description id. A coral wall fan therefore has its own description key but the loot table key of its fan block |
| `Blocks.never` / `always` (as `isValidSpawn`) | constant false / true |
| `Blocks.never` / `always` (as `isRedstoneConductor`, `isSuffocating`) | constant false / true |
| `postProcessAbove` | the position above the state's position (used by `MAGMA_BLOCK`) |

## 4. Shape notation and the shape helpers used here

All boxes below are in **pixel units** (a block is 16 pixels), as `Block.box(x1, y1, z1, x2, y2, z2)` takes them. 24 part 1
§6.2 defines `Block.box`, `column`, `cube` and `boxZ`; this section states the exact argument meaning, read in this round:

| Helper | Box (pixels) |
|---|---|
| `box(x1,y1,z1,x2,y2,z2)` | the box |
| `column(s, y1, y2)` | `box(8 - s/2, y1, 8 - s/2, 8 + s/2, y2, 8 + s/2)` |
| `column(sx, sz, y1, y2)` | `box(8 - sx/2, y1, 8 - sz/2, 8 + sx/2, y2, 8 + sz/2)` |
| `cube(sx, sy, sz)` | `column(sx, sz, 8 - sy/2, 8 + sy/2)` |
| `cube(s)` | `cube(s, s, s)` |
| `boxZ(sx, y1, y2, z1, z2)` | `box(8 - sx/2, y1, z1, 8 + sx/2, y2, z2)` |
| `boxZ(sx, sy, z1, z2)` | `boxZ(sx, 8 - sy/2, 8 + sy/2, z1, z2)` |
| `boxZ(s, z1, z2)` | `boxZ(s, s, z1, z2)` |

Rotation helpers (`Shapes`), all about the block centre (0.5, 0.5, 0.5):

| Helper | Result |
|---|---|
| `rotateHorizontal(shape)` | a map from the four horizontal directions to a shape: `NORTH` is the shape unchanged; `EAST`, `SOUTH`, `WEST` are the shape rotated by `BLOCK_ROT_Y_90`, twice and three times (each step turns features that point north towards east, clockwise as seen from above; the sense is inferred from the entry order and the use in the stair and door tables; `BLOCK_ROT_Y_90` is read to be the constant `ROT_90_Y_NEG` of `OctahedralGroup`, whose matrix was not decoded, Open question 3) |
| `rotateHorizontalAxis(shape)` | a map from the axes `Z` and `X` to a shape: `Z` is the shape unchanged, `X` is the shape rotated by `BLOCK_ROT_Y_90` |
| `rotateAll(shape)` | a map from all six directions: the shape rotated so that features pointing north point in that direction (inferred from use by `PipeBlock`: the arm shape of property `up` reaches the top face, `down` the bottom face) |
| `rotateAllAxis(shape)` | a map from the three axes: `Z` unchanged, `X` rotated by `BLOCK_ROT_Y_90`, `Y` rotated by `BLOCK_ROT_X_90` |
| `rotate(shape, INVERT_Y)` (`OctahedralGroup.INVERT_Y`) | the shape mirrored top to bottom |

`Shapes.or` unions shapes; `Shapes.join(a, b, ONLY_FIRST)` is a minus b (`BooleanOp.ONLY_FIRST`). The default `Block.getShape`
is `Shapes.block()`; the default collision shape is the shape when `hasCollision` else empty; the default block support
shape is the collision shape; the default occlusion shape is the shape; the default visual shape is the collision shape
(`BlockBehaviour` methods, read). A row's shape below says "default shape" when the class does not override `getShape`.

## 5. State properties used here

`BlockStateProperties` constants and their value order (24 part 1 §13 lists the others; section 3 of 24 part 1 gives the state
numbering rule; the first listed value has index 0):

| Name (property key) | Type | Values in order | Count |
|---|---|---|---:|
| `facing` (`HORIZONTAL_FACING`) | enum `Direction`, filtered by `Plane.HORIZONTAL` | north, south, west, east (ordinal order of `Direction`: down, up, north, south, west, east, filtered) | 4 |
| `facing` (`FACING`) | enum `Direction`, explicit list | north, east, south, west, up, down | 6 |
| `axis` | enum `Direction.Axis` | x, y, z | 3 |
| `half` (`HALF`, stairs) | enum `Half` | top, bottom | 2 |
| `half` (`DOUBLE_BLOCK_HALF`, doors, tall plants) | enum `DoubleBlockHalf` | upper, lower | 2 |
| `hinge` | enum `DoorHingeSide` | left, right | 2 |
| `type` (`SLAB_TYPE`) | enum `SlabType` | top, bottom, double | 3 |
| `shape` (`STAIRS_SHAPE`) | enum `StairsShape` | straight, inner_left, inner_right, outer_left, outer_right | 5 |
| `leaves` (`BAMBOO_LEAVES`) | enum `BambooLeaves` | none, small, large | 3 |
| boolean properties (`open`, `powered`, `in_wall`, `waterlogged`, `conditional`, `north`, `east`, `south`, `west`, `up`, `down`) | boolean | true, false | 2 |
| `age` | int | `AGE_1` 0..1, `AGE_3` 0..3, `AGE_4` 0..4, `AGE_5` 0..5, `AGE_25` 0..25 | 2, 4, 5, 6, 26 |
| `eggs` | int | 1..4 | 4 |
| `hatch` | int | 0..2 | 3 |
| `pickles` | int | 1..4 | 4 |
| `stage` | int | 0..1 | 2 |
| `hydration` (`DRIED_GHAST_HYDRATION_LEVELS`) | int | 0..3 | 4 |

Property order inside a block is by property **name** (natural string order), not declaration order (04 §5.2). For the
property sets of this part the sorted orders are:

| Block class | Sorted property names |
|---|---|
| fence gate | facing, in_wall, open, powered |
| fence | east, north, south, waterlogged, west |
| door | facing, half, hinge, open, powered |
| chorus plant | down, east, north, south, up, west |
| stairs | facing, half, shape, waterlogged |
| slab | type, waterlogged |
| command block | conditional, facing |
| observer | facing, powered |
| dried ghast | facing, hydration, waterlogged |
| turtle egg | eggs, hatch |
| pitcher crop | age, half |
| bamboo | age, leaves, stage |
| sea pickle | pickles, waterlogged |
| coral wall fan | facing, waterlogged |

Index of a state inside a block: with the properties in the sorted order, `index = (((v0 * c1) + v1) * c2 + v2) ...` where `vi` is
the 0-based position of the value in the property's value list and `ci` the value count (04 §5.2). Table 7.1 gives the
default state index inside the block for every row.

---

## 6. Families

Each subsection gives, in this order, where applicable: the state set, the shapes, the placement state, the survival rule
(`canSurvive`), the neighbour update rule (`updateShape`), the interaction and tick rules that belong to the block itself.
"Flags 2, 3, 10, 35" are the `Level.setBlock` update flags of the call (24 part N and 29 define the bits; read from the
calls). A direction `cw` / `ccw` is `Direction.getClockWise` / `getCounterClockWise` (horizontal, seen from above: north to
east is `cw`).

### 6.1 Fence gates (`FenceGateBlock`: fields 525 to 527; same class for the earlier gates of part 5)

- **Class.** `FenceGateBlock(WoodType, Properties)` extends `HorizontalDirectionalBlock`. The constructor applies
  `Properties.sound(type.soundType())` (section 3.1). Builder: planks map colour, `forceSolidOn()`, instrument `BASS`,
  `strength(2.0, 3.0)`, `ignitedByLava()` (rows in 7.2).
- **States.** 32: `facing` (4), `in_wall`, `open`, `powered`. Default: facing north, `in_wall` false, `open` false,
  `powered` false (index 7).
- **Axis.** The shapes below are chosen by the **axis of `facing`**: facing north or south uses the `Z` entry, east or west the
  `X` entry. The `X` entry is the `Z` entry rotated by `BLOCK_ROT_Y_90`.

| Shape | `Z` entry (pixels) | `X` entry (pixels) | Used for |
|---|---|---|---|
| `SHAPES` | box(0,0,6, 16,16,10) (`cube(16,16,4)`) | box(6,0,0, 10,16,16) | selection shape when `in_wall` is false |
| `SHAPES_WALL` | `SHAPES` minus box(0,13,0, 16,16,16): box(0,0,6, 16,13,10) | box(6,0,0, 10,13,16) | selection shape when `in_wall` is true |
| `SHAPE_COLLISION` | box(0,0,6, 16,24,10) (`column(16,4,0,24)`) | box(6,0,0, 10,24,16) | collision shape when `open` is false (empty when open) |
| `SHAPE_SUPPORT` | box(0,5,6, 16,24,10) (`column(16,4,5,24)`) | box(6,5,0, 10,24,16) | block support shape when `open` is false (empty when open) |
| `SHAPE_OCCLUSION` | union (`Shapes.or`) of box(0,5,7, 2,16,9) and box(14,5,7, 16,16,9): both posts are present together | the same union rotated by `BLOCK_ROT_Y_90`: box(7,5,0, 9,16,2) together with box(7,5,14, 9,16,16) | occlusion shape when `in_wall` is false |
| `SHAPE_OCCLUSION_WALL` | the `SHAPE_OCCLUSION` union moved by -0.1875 on y (3 pixels down) | likewise | occlusion shape when `in_wall` is true |

  The collision box is 24 pixels (1.5 blocks) tall (read from the shape constants); that an entity cannot step or jump onto a
  closed gate follows from the step and jump rules of 13 (inferred, not read here). `isPathfindable`: for the
  path computation types `LAND` and `AIR` the result is the `open` value; for `WATER` it is false (the synthetic switch class `FenceGateBlock$1` assigns the numbers by enum constant, read from its static initialiser: `LAND` is 1, `WATER` is 2, `AIR` is 3; the results are open, false, open).
- **Placement** (`getStateForPlacement`): `powered = open = level.hasNeighborSignal(pos)`; `facing` = the player's
  horizontal direction (`getHorizontalDirection`, not opposite); `in_wall` = true when the facing axis is `Z` and the block to the west or
  east is in tag `walls`, or the facing axis is `X` and the block to the north or south is in tag `walls`.
- **Neighbour shape update** (`updateShape`): when the changed direction's axis equals the axis of `facing.cw`
  (that is, the axis along the gate's length), `in_wall` is recomputed as: the neighbour state (in the changed direction) is in
  tag `walls`, or the block on the opposite side of the gate is in tag `walls`. Otherwise the generic update.
- **Use** (`useWithoutItem`): if `open`, set `open` false (flags 10). Otherwise let `d` = the player's direction
  (`Player.getDirection`); if the gate's `facing` equals `d.getOpposite()`, set `facing` to `d` (the gate opens away from the
  player); set `open` true (flags 10). Then play the set's gate open or close sound at volume 1.0 and pitch
  `random.nextFloat() * 0.1 + 0.9` (from the level's random source), send game event `block_open` or `block_close`, return success.
- **Redstone** (`neighborChanged`, server only): `p = level.hasNeighborSignal(pos)`. If `powered != p`: set `powered = p` and
  `open = p` (flags 2); if `open` had differed from `p`, play the open or close sound (same volume and pitch formula) and send
  the game event.
- **Explosion** (`onExplosionHit`): when the explosion can trigger blocks and `powered` is false: toggle `open` with
  `setBlockAndUpdate`, play the gate sound of the **new** state (close sound when it was open, open sound when it was
  closed) and send game event `block_close` when it was open, else `block_open`. The sound uses volume 1.0 and pitch `random.nextFloat() * 0.1 + 0.9` from the level's random source, the same formula as the use and redstone handlers (three call sites in all).
- **Fence connection query.** `FenceGateBlock.connectsToDirection(state, dir)` is true when the axis of `state.facing.cw`
  equals the axis of `dir` (a gate connects to fences along its length).

### 6.2 Fences (`FenceBlock`: fields 528 to 537; same class for the oak fence and the nether fences of other parts)

- **Class.** `FenceBlock(Properties)` extends `CrossCollisionBlock`. The constructor passes `(4.0, 16.0, 4.0, 16.0, 24.0)`
  to the superclass (post width, post height, arm width, arm height for the selection shape, collision height). Builder: planks map
  colour, instrument `BASS`, `strength(2.0, 3.0)`, `ignitedByLava()`, sound `WOOD` (`CHERRY_WOOD` for cherry,
  `BAMBOO_WOOD` for bamboo). No `forceSolid` and no `noOcclusion`, so the fence is not a solid block for `isSolid` unless its
  collision shape qualifies (24 part 1 §5.2).
- **States.** 32: `east`, `north`, `south`, `waterlogged`, `west` (all booleans, true first). Default: all false (index 31).
- **Shapes.** `CrossCollisionBlock.makeShapes(post, postHeight, arm, armBottom=0, armTop)` builds a per-state shape: the post
  `column(post, 0, postHeight)` united with, for every direction property that is true, the arm
  `boxZ(arm, armBottom, armTop, 0, 8)` rotated to that direction (the `NORTH` arm covers z 0 to 8, the `SOUTH` arm z 8 to 16, the
  `WEST` arm x 0 to 8, the `EAST` arm x 8 to 16, inferred from `rotateHorizontal`). `waterlogged` does not change the shape.

| Shape | Post (pixels) | Arm for north (pixels) | Used for |
|---|---|---|---|
| selection / visual shape (`shapes`) | box(6,0,6, 10,16,10) | box(6,0,0, 10,16,8) | `getShape`, `getVisualShape` |
| collision shape (`collisionShapes`) | box(6,0,6, 10,24,10) | box(6,0,0, 10,24,8) | `getCollisionShape` |
| occlusion shape (`FenceBlock.occlusionShapes`, built with `makeShapes(4,16,2,6,15)`) | box(6,0,6, 10,16,10) | box(7,6,0, 9,15,8) | `getOcclusionShape` |

  `isPathfindable` is false for every path type. `propagatesSkylightDown` is true when `waterlogged` is false.
- **Connection rule.** `FenceBlock.connectsTo(state, faceSturdy, direction)` is true when any one of these three holds:

  | # | Condition |
  |---|---|
  | 1 | the state is not an exception for connection (`Block.isExceptionForConnection`) and the face towards the fence is sturdy (`faceSturdy`) |
  | 2 | `isSameFence(state)` |
  | 3 | the state's block is a fence gate and `FenceGateBlock.connectsToDirection(state, direction)` holds |

  where:
  - `isSameFence(state)`: the state is in tag `fences` and `state.is(wooden_fences)` equals `this.defaultBlockState().is(wooden_fences)`
    (wooden fences connect to wooden fences, the other fences to the other fences);
  - `Block.isExceptionForConnection(state)`: the block is an instance of `LeavesBlock`, or is `BARRIER`, `CARVED_PUMPKIN`,
    `JACK_O_LANTERN`, `MELON`, `PUMPKIN`, or the state is in tag `shulker_boxes`.
- **Placement.** For each of the four directions `d` (north, east, south, west in that order): `n` = the state at
  `pos.relative(d)`; the property of `d` = `connectsTo(n, n.isFaceSturdy(level, pos.relative(d), d.getOpposite()), d.getOpposite())`.
  `waterlogged` = the fluid at the position is water (`FluidState.is(Fluids.WATER)`).
- **Neighbour shape update.** If `waterlogged`, schedule a water tick (delay `Fluids.WATER.getTickDelay`). If the changed
  direction is horizontal: the property of that direction becomes
  `connectsTo(neighbour, neighbour.isFaceSturdy(level, neighbourPos, d.getOpposite()), d.getOpposite())`. Otherwise the generic update.
- **Use** (`useWithoutItem`): on the server, `LeadItem.bindPlayerMobs(player, level, pos)` (tie leashed mobs of the player to the
  fence post; the result is `SUCCESS` when it did something, else `PASS`); on the client `PASS`.
- **Rotation and mirror.** `CrossCollisionBlock.rotate` and `mirror` permute the four direction properties by the rotation or
  mirror (180 degrees: north with south and east with west; clockwise 90: each property takes the value of the one counter-clockwise of
  it; mirror left-right swaps north and south, mirror front-back swaps east and west).

### 6.3 Doors (`DoorBlock`: fields 538 to 547; ten wood types)

- **Class.** `DoorBlock(BlockSetType, Properties)` extends `Block`; constructor applies `Properties.sound(type.soundType())`
  (section 3.1). Builder: planks map colour, instrument `BASS`, `strength(3.0)`, `noOcclusion()`, `ignitedByLava()`,
  `pushReaction(POPPED)`.
- **States.** 64: `facing` (4), `half`, `hinge`, `open`, `powered`. Default: facing north, half `lower`, hinge `left`,
  `open` false, `powered` false (index 11).
- **Shape.** `SHAPES = rotateHorizontal(boxZ(16, 13, 16))`: for `NORTH` the box (0,0,13, 16,16,16) (a 3-pixel slab on the south
  side of the cell); the other directions are its rotations. `getShape(state)`: let `d = facing`; when `open`,
  `d = (hinge == right) ? facing.ccw : facing.cw`; the result is `SHAPES[d]`. The same shape is used for the collision shape
  (the class does not override `getCollisionShape`; the default is the shape because `hasCollision` stays true). Both halves have the same shape.
- **Placement.** Returns null (placement refused) unless `pos.getY() < level.getMaxY()` and the block above can be replaced
  (`BlockState.canBeReplaced(context)`). `powered = open` = `hasNeighborSignal(pos) || hasNeighborSignal(pos.above())`; `facing` =
  the player's horizontal direction; `half` = lower; `hinge` from the rule below. After placement, `setPlacedBy` sets the
  block above to the same block with `half = upper` (`setBlockAndUpdate`).
- **Hinge rule** (`getHinge`): with `d = horizontal direction`, let `L` = the cell `pos.relative(d.ccw)` and `La` = the
  cell above it, `R` = `pos.relative(d.cw)` and `Ra` the cell above it. `s = (L full ? -1 : 0) + (La full ? -1 : 0) +
  (R full ? 1 : 0) + (Ra full ? 1 : 0)` where "full" is `BlockState.isCollisionShapeFullBlock`. `lDoor` = the state at `L`
  is a `DoorBlock` with half lower; `rDoor` likewise for `R`.
  1. If `(lDoor && !rDoor) || s > 0`: hinge `right`.
  2. Else if `(rDoor && !lDoor) || s < 0`: hinge `left`.
  3. Else with `k = d.getStepX()`, `l = d.getStepZ()`, `dx` and `dz` = the click location minus the block position on x and z:
     hinge `right` if `(k < 0 && dz < 0.5) || (k > 0 && dz > 0.5) || (l < 0 && dx > 0.5) || (l > 0 && dx < 0.5)`,
     otherwise `left`.
- **Survival** (`canSurvive`): let `b` = the state below. For `half = lower`: `b.isFaceSturdy(level, pos.below(), UP)`. For
  `half = upper`: `b.is(this block)` (the upper half needs the same door block below it; the `half` of the lower block is not
  tested here, `updateShape` handles it).
- **Neighbour shape update** (`updateShape`): when the changed direction is vertical and corresponds to the other half (this
  half lower and direction up, or this half upper and direction down): if the neighbour is a `DoorBlock` whose `half` differs from
  this half, the result is the **neighbour's state with `half` set to this half** (the two halves copy each other's
  `facing`, `hinge`, `open` and `powered`); otherwise the result is air. Else, when this half is lower and the changed
  direction is down and `!state.canSurvive`, the result is air; otherwise the generic update.
- **Use** (`useWithoutItem`): if `!type.canOpenByHand()` the result is `PASS`; otherwise `state.cycle(open)` (flags 10), play
  the set's door open or close sound at volume 1.0 and pitch `random * 0.1 + 0.9`, send game event `block_open` or `block_close`,
  return `SUCCESS`. `isWoodenDoor(state)` = the block is a `DoorBlock` and its set can be opened by hand.
- **Redstone** (`neighborChanged`): `p = hasNeighborSignal(pos) || hasNeighborSignal(pos.relative(half == lower ? UP : DOWN))`.
  If the changed neighbour is not this block (`!defaultBlockState().is(neighbourBlock)`) and `p != powered`: when `p != open`
  play the sound and send the game event; then set `powered = p` and `open = p` (flags 2). Both halves do this independently.
- **Wind charge / explosion** (`onExplosionHit`): when the explosion can trigger blocks, `half` is lower, the set
  `canOpenByWindCharge`, `powered` is false: toggle `open` (`setOpen`, flags 10 with sound and game event).
- **Breaking** (`playerWillDestroy`): on the server, when the player prevents drops (creative) or does not have the correct tool,
  `DoublePlantBlock.preventDropFromBottomPart`: for the upper half, when the block below is the same block with half lower,
  replace the lower half by water (when its fluid is water) or air (flags 35) and send level event 2001 (block break
  particles and sound) with the lower state's id.
- **Pathing.** `isPathfindable`: `LAND` and `AIR` give `open`, `WATER` gives false (the synthetic switch class `DoorBlock$1` assigns `LAND` 1, `AIR` 2, `WATER` 3, read from its static initialiser; results open, open, false).
- **Rotation, mirror.** `rotate` rotates `facing`; `mirror` rotates by the mirror's rotation and, unless the mirror is
  `NONE`, cycles `hinge`.

### 6.4 End rod (`EndRodBlock`: field 548)

- **Class.** `EndRodBlock(Properties)` extends `RodBlock` extends `DirectionalBlock` (property `facing` with six values).
  Builder: `forceSolidOff()`, `instabreak()`, `lightLevel(constant 14)`, sound `WOOD`, `noOcclusion()`.
- **States.** 6: `facing` north, east, south, west, up, down. Default `up` (index 4).
- **Shape.** `rotateAllAxis(cube(4, 4, 16))`: the rod is a 4 by 4 pixel bar along the facing axis: `Z` axis (north or south):
  box(6,6,0, 10,10,16); `X` axis (east or west): box(0,6,6, 16,10,10); `Y` axis (up or down): box(6,0,6, 10,16,10). The
  shape depends only on the axis of `facing`. `isPathfindable` is false. The default collision shape is this shape.
- **Placement.** Let `c = context.getClickedFace()`; let `n` = the state at `clickedPos.relative(c.getOpposite())` (the block the
  player clicked against). If `n` is an end rod with `facing == c`, the new rod has `facing = c.getOpposite()`; otherwise
  `facing = c`. Rotation and mirror apply to `facing`.
- **Client effect.** `animateTick` (client only, 12). Draw order within one call, read in full: first the three position
  floats `nextFloat` (x, then y, then z), then the two floats `nextFloat` of the shift distance, on **every** call; then the
  test `random.nextInt(5) == 0`; only when it passes is a particle spawned, and then three gaussian draws (x, y, z velocity
  order) are made. The `end_rod` particle position on each axis is the cell coordinate plus `0.55 - nextFloat * 0.1`, plus
  the facing's step on that axis times `d` where `d = 0.4 - (nextFloat + nextFloat) * 0.4`; the velocity is gaussian times
  0.005 on each axis. This is client-side presentation only and no server rule reads it.

### 6.5 Chorus plant and chorus flower (`ChorusPlantBlock`, `ChorusFlowerBlock`: fields 549 and 550)

**Chorus plant.**
- **Class.** `ChorusPlantBlock(Properties)` extends `PipeBlock`: the constructor passes `10.0` (pixels) as the node size.
  Builder: map colour `COLOR_PURPLE`, `forceSolidOff()`, `strength(0.4)`, sound `WOOD`, `noOcclusion()`, `pushReaction(POPPED)`.
  No instrument (default `HARP`), no `requiresCorrectToolForDrops`.
- **States.** 64: `down`, `east`, `north`, `south`, `up`, `west` (booleans, sorted names). Default: all false (index 63).
- **Shape.** `PipeBlock.makeShapes(10)`: the node `cube(10)` = box(3,3,3, 13,13,13) united with, for each true direction
  property, the arm `boxZ(10, 0, 8)` = box(3,3,0, 13,13,8) rotated to that direction by `rotateAll` (the arm of `up`
  reaches y 16, of `down` y 0, and so on). No override of collision or occlusion shape: both follow the shape; `noOcclusion`
  makes `canOcclude` false.
  `propagatesSkylightDown` is false. `isPathfindable` is false.
- **Connection state** (`getStateWithConnections(level, pos, state)`, used by placement and by the flower's growth):
  `down` = the block below is a chorus plant, a chorus flower, or is in tag `supports_chorus_plant`; `up`, `north`, `east`,
  `south`, `west` = the neighbour in that direction is a chorus plant or a chorus flower.
- **Placement** (`getStateForPlacement`): `getStateWithConnections(level, pos, defaultBlockState())`.
- **Neighbour shape update**: if `!state.canSurvive`, schedule a tick (delay 1) and return the generic update; otherwise set the
  property of the changed direction to: the neighbour is a chorus plant or flower, or (direction `down` and the neighbour is
  in tag `supports_chorus_plant`).
- **Tick**: `tick` destroys the block with drops (`ServerLevel.destroyBlock(pos, true)`) when `!canSurvive`.
- **Survival** (`canSurvive`), with `B` the state below and `A` the state above: let `both = !A.isAir() && !B.isAir()`.
  For each horizontal direction `d` in `Plane.HORIZONTAL` order (north, east, south, west): let `N = pos.relative(d)` state;
  if `N` is a chorus plant: if `both`, return false; let `NB` = the state below `N`; if `NB` is a chorus plant or in tag
  `supports_chorus_plant`, return true. After the loop: return `B` is a chorus plant or `B` in tag `supports_chorus_plant`.
  The same rule as a condition table (first matching row wins, horizontal neighbours examined in the order north, east, south, west; `both` = the cells above and below are both non-air):

  | Neighbour `N` (horizontal) | `both` | State below `N` | Result |
  |---|---|---|---|
  | not a chorus plant | any | any | no effect, next direction |
  | chorus plant | true | any | not survivable (stop) |
  | chorus plant | false | chorus plant or in `supports_chorus_plant` | survivable (stop) |
  | chorus plant | false | anything else | no effect, next direction |
  | (no direction decided) | | `B` is a chorus plant or in `supports_chorus_plant` | survivable; otherwise not survivable |

**Chorus flower.**
- **Class.** `ChorusFlowerBlock(plant: CHORUS_PLANT, Properties)`. Builder: map colour `COLOR_PURPLE`, `forceSolidOff()`,
  `randomTicks()`, `strength(0.4)`, sound `WOOD`, `noOcclusion()`, `isValidSpawn(never)`, `pushReaction(POPPED)`,
  `isRedstoneConductor(never)`.
- **States.** 6: `age` 0 to 5 (5 is "dead"). Default age 0. `isRandomlyTicking` is true while `age < 5` (the builder flag is
  not the test).
- **Shapes.** No `getShape` override: the shape is the full cube (default); the block support shape is `column(14, 0, 15)` =
  box(1,0,1, 15,15,15).
- **Survival** (`canSurvive`), with `B` = the state below: if `B` is the chorus plant or in tag `supports_chorus_flower`,
  true. If `B` is not air, false. Otherwise (air below): let `count = 0`; for each horizontal direction: `N` = the neighbour
  state; if `N` is a chorus plant: if `count` is already 1, return false, else `count = 1`; else if `N` is not air, return false.
  Return `count == 1` (exactly one plant neighbour and all other horizontal neighbours air).
- **Neighbour shape update**: for any direction other than up, when `!canSurvive` schedule a tick (delay 1); then the generic update.
  `tick`: destroy with drops when `!canSurvive`.
- **Random tick** (`randomTick`), `age < 5` only, and only if `pos.above()` is empty and `pos.getY() <= maxY`:
  1. `grow = false`, `endBelow = false`. Let `B` = the state below.
  2. If `B` is in tag `supports_chorus_flower`: `grow = true`.
  3. Else if `B` is the chorus plant: let `h = 1`; for `j` in 0 to 3: `S` = the state at `pos.below(h + 1)`; if `S` is the plant, `h += 1` and
     the loop continues; any other `S` ends the loop, and when that `S` is in `supports_chorus_flower` first `endBelow = true`. Then `grow = (h < 2) || (h <= random.nextInt(endBelow ? 5 : 4))`
     (`nextInt(bound)` returns 0 to bound-1).
  4. Else if `B` is air: `grow = true`.
  5. If `grow` and all four horizontal neighbours of `pos.above()` are empty (`allNeighborsEmpty(level, above, null)`: no direction
     excluded) and `pos.above(2)` is empty: set `pos` to the chorus plant with connections (flags 2), then place a flower of age `age`
     at `pos.above()` (`placeGrownFlower`: set the cell to this block with that age, flags 2, then level event 1033).
  6. Else if `age < 4`: `n = random.nextInt(4)`, plus 1 if `endBelow`. Repeat `n` times: pick a random horizontal direction
     (`Plane.HORIZONTAL.getRandomDirection`); `c = pos.relative(dir)`; if `c` is empty and the cell below `c` is empty and
     `allNeighborsEmpty(level, c, dir.getOpposite())` (the three other horizontal neighbours of `c`, excluding the direction
     back towards the flower, are empty): place a flower of age `age + 1` at `c` and remember that a branch grew. After the
     loop: if a branch grew, set `pos` to the chorus plant with connections (flags 2); else place a dead flower at `pos`
     (`age = 5`, flags 2, level event 1034).
  7. Else (`age >= 4` and not grown): place a dead flower at `pos`.
- **Projectiles**: `onProjectileHit` destroys the block with drops when a server-level projectile may interact and break
  (`mayInteract`, `mayBreak`).
- **World generation helpers** `ChorusFlowerBlock.generatePlant` and `growTreeRecursive` (used by End island generation) are not
  specified here; they are specified in 35 part 7 (Open question 6). Level events 1033 and 1034 (grown and dead flower) are sent with data 0.

### 6.6 Purpur, end stone bricks, and the stair and slab classes (fields 551 to 555 and 575 to 576)

- **`PURPUR_BLOCK`, `END_STONE_BRICKS`.** Plain `Block`, no state properties (1 state), default full-cube shape. Builder values
  in table 7.2 (purpur: `COLOR_MAGENTA`, `BASEDRUM`, tool required, 1.5 / 6.0; end stone bricks: `SAND`, `BASEDRUM`, tool
  required, 3.0 / 9.0; both with sound `STONE`).
- **`PURPUR_PILLAR`.** `RotatedPillarBlock`; builder as the purpur block. 3 states: `axis` x, y, z; default `y` (index 1).
  Placement: `axis` = the axis of the clicked face. Rotation by 90 or 270 degrees swaps `x` and `z` (`rotatePillar`).
  `BONE_BLOCK` uses the same class and rules.
- **`PURPUR_STAIRS`** (`StairBlock(PURPUR_BLOCK.defaultBlockState(), Properties)`, builder `ofLegacyCopy(PURPUR_BLOCK)`) and
  **`<colour>_CONCRETE_STAIRS`** (`StairBlock(<colour>_CONCRETE.defaultBlockState(), ...)`, builder `ofFullCopy`): the stair class below.
- **`PURPUR_SLAB`** and **`<colour>_CONCRETE_SLAB`** (`SlabBlock`, builder `ofLegacyCopy`): the slab class below.

**Stair class (`StairBlock`).** States 80: `facing` (4), `half` (top, bottom), `shape` (5), `waterlogged`. Default: facing north,
half bottom, shape straight, not waterlogged (index 11). `useShapeForLightOcclusion` is true. `getExplosionResistance`
returns the base block's resistance. `isPathfindable` is false.

Shape construction (pixels), per direction key as `rotateHorizontal` (the `NORTH` entry is the base):

| Name | Construction | Boxes for key `north` |
|---|---|---|
| `SHAPE_OUTER` | `column(16,0,8)` united with box(0,8,0, 8,16,8) | slab box(0,0,0, 16,8,16) and the north-west quarter box(0,8,0, 8,16,8) |
| `SHAPE_STRAIGHT` | `SHAPE_OUTER` united with itself rotated by `BLOCK_ROT_Y_90` | slab and box(0,8,0, 16,16,8) (the north half) |
| `SHAPE_INNER` | `SHAPE_STRAIGHT` united with itself rotated by `BLOCK_ROT_Y_90` | slab and the north half and the east half (all of the upper layer but the south-west quarter) |
| `SHAPE_BOTTOM_*` | `rotateHorizontal(SHAPE_*)` | as above for key `north`; key `east`, `south`, `west` are the same shape turned 90, 180, 270 degrees clockwise |
| `SHAPE_TOP_*` | `rotateHorizontal(SHAPE_*, INVERT_Y)`: the base mirrored top to bottom, then the four directions | the slab at y 8 to 16 and the step pieces at y 0 to 8 |

`getShape(state)`: pick the map by `half` (bottom: `SHAPE_BOTTOM_*`, top: `SHAPE_TOP_*`) and by `shape` (straight:
`STRAIGHT`; outer_left and outer_right: `OUTER`; inner_left and inner_right: `INNER`). The map key is `facing` for
`straight`, `outer_left` and `inner_right`; `facing.ccw` for `inner_left`; `facing.cw` for `outer_right` (read from the two
`StairsShape` switches). For `facing = north`, bottom half, the raised part is therefore: straight, the north half;
outer_left, the north-west quarter; outer_right, the north-east quarter; inner_right, the north half and the east half;
inner_left, the north half and the west half. (The sense of the 90-degree rotation, clockwise seen from above, is inferred
from this table: it is the sense for which outer_left of a north-facing stair lies to the west, that is to the left of a
viewer facing north, Open question 3.) The collision shape is the shape (default).

Placement (`getStateForPlacement`): `facing` = the player's horizontal direction; `half` = `top` when the clicked face is
`down`, or the clicked face is not `up` and the click's height inside the cell exceeds 0.5 (`clickLocation.y - pos.y > 0.5`);
otherwise `bottom`; `waterlogged` = the fluid at the position is water; `shape` = `getStairsShape(state, level, pos)`.

`getStairsShape(state, level, pos)`: let `f = facing`.
1. `A` = the state at `pos.relative(f)`. If `A` is a stair of the same `half` and `A.facing.axis != f.axis` and
   `canTakeShape(state, level, pos, A.facing.opposite)`: return `outer_left` when `A.facing == f.ccw`, else `outer_right`.
2. `B` = the state at `pos.relative(f.opposite)`. If `B` is a stair of the same `half` and `B.facing.axis != f.axis` and
   `canTakeShape(state, level, pos, B.facing)`: return `inner_left` when `B.facing == f.ccw`, else `inner_right`.
3. Otherwise `straight`.
`canTakeShape(state, level, pos, d)`: `N` = the state at `pos.relative(d)`; true when `N` is not a stair, or its `facing` differs from
`state.facing`, or its `half` differs from `state.half`.
`updateShape`: when `waterlogged`, schedule a water tick; when the changed direction is horizontal, recompute `shape`
with `getStairsShape`; else the generic update. `rotate` rotates `facing`. `mirror`: when the mirror flips the axis of `facing`
(read in two branches, one for each of `Z` and `X`), the state is rotated by 180 degrees and the corner shapes swap left and
right (`inner_left` with `inner_right`, `outer_left` with `outer_right`; `straight` is only rotated); otherwise the generic mirror.

**Slab class (`SlabBlock`).** States 6: `type` (top, bottom, double), `waterlogged`. Default: bottom, not waterlogged
(index 3). Shapes: `SHAPE_BOTTOM = column(16,0,8)` = box(0,0,0, 16,8,16); `SHAPE_TOP = column(16,8,16)` = box(0,8,0, 16,16,16);
`double`: `Shapes.block()`. `useShapeForLightOcclusion` is true unless the slab is double.
- Placement: if the position already holds this slab block, the result is that state with `type = double` and `waterlogged = false`.
  Otherwise the default state with `waterlogged` = fluid is water, and `type = top` when the clicked face is `down`, or the
  clicked face is not `up` and the click height exceeds 0.5; else bottom.
- `canBeReplaced(state, context)`: false when `type == double` or the held item is not this slab's item. Otherwise, when the
  context replaces the clicked block: `up = (click.y - pos.y) > 0.5`, `face` = the clicked face; for `bottom`:
  `face == up || (up && face is horizontal)`; for `top`: `face == down || (!up && face is horizontal)`. When the context does
  not replace the clicked block: true.
- Liquids: `placeLiquid` and `canPlaceLiquid` act as `SimpleWaterloggedBlock` unless `type == double` (then false).
- `isPathfindable`: false for `LAND` and `AIR`; for `WATER` the state's fluid is in tag `water` (the synthetic switch class `SlabBlock$1` assigns `LAND` 1, `WATER` 2, `AIR` 3, read from its static initialiser; results false, fluid test, false).

### 6.7 Plants of this part (fields 556 to 559)

All four use `Properties.of()`, map colour `PLANT`, `noCollision()` (hasCollision false, canOcclude false), sound `CROP`,
`pushReaction(POPPED)`, strength 0.0 (`instabreak`, except where stated), no tool. They are `VegetationBlock` subclasses:
`VegetationBlock.updateShape` returns air when `!state.canSurvive`; `canSurvive` is `mayPlaceOn(state below)`; the default
`mayPlaceOn` is "the state is in tag `supports_vegetation`"; `propagatesSkylightDown` is "the block's fluid state is empty";
`isPathfindable` is true for the air path type when `hasCollision` is false (and otherwise as `Block`).

**Crop growth shared rule** (`CropBlock`, the superclass of `TorchflowerCropBlock` and `BeetrootBlock`; `PitcherCropBlock` uses
`getGrowthSpeed` and `hasSufficientLight` only):
- `hasSufficientLight(level, pos)`: `level.getRawBrightness(pos, 0) >= 8`. `canSurvive` = sufficient light **and**
  `VegetationBlock.canSurvive`. `mayPlaceOn`: the state below is in tag `supports_crops`.
- `isRandomlyTicking` = not at max age. Random tick: if `level.getRawBrightness(pos, 0) >= 9` and `age < maxAge`: `speed =
  getGrowthSpeed(this, level, pos)`; if `random.nextInt((int)(25.0 / speed) + 1) == 0`, set the state of `age + 1`
  (flags 2).
- `getGrowthSpeed`: `f = 1.0`; for `dx` and `dz` each -1 to 1: `soil` = the state at `pos.below().offset(dx, 0, dz)`;
  `s = 0`; if `soil` is in tag `grows_crops`: `s = 1.0`, and if its property `moisture` (default 0 when absent,
  `FarmlandBlock.MOISTURE`) is above 0, `s = 3.0`; if `(dx, dz) != (0, 0)` then `s /= 4.0`; `f += s`. Then
  `row = west or east of pos is this block`, `col = north or south of pos is this block`; if both, `f /= 2.0`; else if any of the four diagonal neighbours is this block, `f /= 2.0`. Return `f`.
- Bone meal (`isValidBonemealTarget` = not at max age; always succeeds): `growCrops` sets `min(maxAge, age + increase)` where
  `getBonemealAgeIncrease` is `Mth.nextInt(random, 2, 5)` by default.
- A ravager entering the block destroys it (with drops) when the `mobGriefing` game rule is true (`entityInside`).

**`TORCHFLOWER_CROP`** (`TorchflowerCropBlock`). States 2: `age` 0 to 1 (default 0). `getMaxAge` returns 2: when growth
would reach age 2, the block is replaced by the `TORCHFLOWER` block (`getStateForAge(2)`). Random tick forwards to the
crop rule only when `random.nextInt(3) != 0` (two of three ticks; read: a zero result returns without ticking). Bone meal increase 1.
Shape: `boxes(1, age -> column(6, 0, 6 + 4*age))`: age 0 box(5,0,5, 11,6,11), age 1 box(5,0,5, 11,10,11). Seed item `torchflower_seeds`.

**`BEETROOTS`** (`BeetrootBlock`, key `beetroots`, item `beetroot_seeds`). States 4: `age` 0 to 3 (default 0). Random tick
forwards to the crop rule only when `random.nextInt(3) != 0`. Bone meal increase `Mth.nextInt(random, 2, 5) / 3` (integer
division: 0 or 1). Shape: `boxes(3, age -> column(16, 0, 2 + 2*age))`: box(0,0,0, 16,h,16) with `h` = 2, 4, 6, 8 for ages 0 to 3.

**`PITCHER_CROP`** (`PitcherCropBlock extends DoublePlantBlock`; item `pitcher_pod`). States 10: `age` 0 to 4 and `half`
(upper, lower); default age 0, half lower (index 1). Map colour `PLANT`, `noCollision`, `randomTicks`, `instabreak`.
- A tall plant stage starts at age 3 (`isDouble(age) = age >= 3`; the constant `DOUBLE_PLANT_AGE_INTERSECTION` is 3); max age 4.
- Placement returns the default state (age 0, lower) with no check of the cell above; `setPlacedBy` does nothing (no upper half
  at age 0); `canBeReplaced` is always false; a ravager destroys it as above.
- Shapes. `H = [0, 9, 11, 22, 26]`; `a = (age == 0 ? 4 : 6) + H[age]`, `w = (age == 0 ? 6 : 10)`. Selection shape: lower half
  `column(w, -1, min(16, a - 1))`, upper half `column(w, 0, max(0, a - 1 - 16))`. Collision shape: lower half only: age 0
  `column(6, -1, 3)` = box(5,-1,5, 11,3,11), ages 1 to 4 `column(10, -1, 5)` = box(3,-1,3, 13,5,13); upper half empty.
  Example: age 3 lower: `a = 6 + 22 = 28`, `w = 10`, shape box(3,-1,3, 13,16,13); upper: box(3,0,3, 13,11,13).
- Survival (`canSurvive`): for the lower half, requires `hasSufficientLight` (raw brightness >= 8) and then
  `DoublePlantBlock.canSurvive`; for the upper half `DoublePlantBlock.canSurvive`. `DoublePlantBlock.canSurvive`: for
  `half != upper`, `VegetationBlock.canSurvive` (`mayPlaceOn`: tag `supports_crops`); for `upper`, the state below is
  this block with `half = lower`.
- Neighbour shape update: when `age >= 3` the double-plant update applies (see `DoublePlantBlock` below); when `age < 3` the
  result is the state itself when `canSurvive`, else air.
- Random tick (lower half only; `isRandomlyTicking` = lower and `age < 4`): `speed = getGrowthSpeed`; if
  `random.nextInt((int)(25.0 / speed) + 1) == 0`, grow by 1. `grow(level, state, pos, inc)`: `n = min(age + inc, 4)`;
  if `canGrow(level, pos, state, n)` (the state is not at max age, there is sufficient light, `pos.above()` is inside the build
  height, and when `n >= 3` the cell above is air or this block): set `age = n` (flags 2) and, when `n >= 3`, set `pos.above()` to the
  same block with `age = n` and `half = upper` (`setBlockAndUpdate`).
- Bone meal: valid when the lower half's `canGrow` for `age + 1`; always succeeds; increases `age` by 1.

**`PITCHER_PLANT`** (`DoublePlantBlock`; builder: `PLANT`, `noCollision`, `instabreak`, sound `CROP`, `offsetType(XZ)`,
`ignitedByLava()`, `pushReaction(POPPED)`). States 2: `half` (upper, lower), default lower (index 1). With offset type `XZ`
its shape and render are moved by the offset function of 24 part 1 §4.4 (`dynamicShape()` is not set; the collision shape is
empty, so no shape cache error occurs; the selection shape is the default full cube moved by the offset: the class does
not override `getShape`; `DoublePlantBlock` and `VegetationBlock` were checked for `getShape` and `getCollisionShape` overrides and have none, and the registry factory for `PITCHER_PLANT` constructs `DoublePlantBlock` directly: read, Open question 5 is closed).
`DoublePlantBlock` rules:
- Placement: null unless `pos.getY() < maxY` and the cell above can be replaced; else the default state. `setPlacedBy` sets
  `pos.above()` to the block with `half = upper` (waterlogged copied when the property exists; `setBlockAndUpdate`).
- `canSurvive`: as described under `PITCHER_CROP`, with `mayPlaceOn` = tag `supports_vegetation`.
- Neighbour shape update (`updateShape`): when the changed direction is vertical and corresponds to the other half (lower and
  up, or upper and down): if the neighbour is not this block, or has the same `half`, the result is air (the other half
  is missing); otherwise (the neighbour is this block with the other half) the generic update. When lower, direction down
  and `!canSurvive`: air. Else the generic vegetation update (air when `!canSurvive`).
- Breaking: `playerWillDestroy` on the server: when the player prevents drops (creative): `preventDropFromBottomPart` as for doors
  (6.3). Otherwise the drops are produced at that moment for the broken state (`dropResources` with the player's main-hand item), and
  `DoublePlantBlock.playerDestroy` runs the generic destroy with the air state instead of the broken state (so the generic path
  produces no second set of drops; the last clause is read from the call shape).

### 6.8 Dirt path (`PathBlock`: field 560)

- **Class.** `PathBlock(DIRT, Properties)`. Builder: map colour `DIRT`, `strength(0.65)`, sound `GRASS`,
  `isSuffocating(always)`. 1 state. `useShapeForLightOcclusion` is true.
- **Shape.** `column(16, 0, 15)` = box(0,0,0, 16,15,16) for selection and collision (15 pixels tall). `isPathfindable` false.
- **Survival** (`canSurvive`): the state above is not solid (`BlockState.isSolid()` false) **or** is a fence gate block
  (any `FenceGateBlock`).
- **Placement**: if the default state cannot survive at the position, the result is the `DIRT` block's default state pushed up
  (`Block.pushEntitiesUp(default, dirt, level, pos)`); otherwise the default state.
- **Update**: `updateShape` for the direction up, when `!canSurvive`, schedules a tick (delay 1). `tick` turns the path into dirt
  (`turnToBaseBlock`: sets the dirt state pushed up, `setBlockAndUpdate`, game event `block_change`).

### 6.9 End gateway (`EndGatewayBlock`: field 561)

- **Class.** `EndGatewayBlock(Properties)` extends `BaseEntityBlock`. Block entity: `TheEndGatewayBlockEntity` (31).
  Builder: map colour `COLOR_BLACK`, `noCollision()`, `lightLevel(15)`, `strength(-1.0, 3600000.0)`, `noLootTable()`,
  `pushReaction(IMMOVEABLE)`. 1 state. Item: none.
- **Shape.** Default full cube for selection; collision empty (`noCollision`). Render shape `INVISIBLE` (the block is drawn by
  its block entity). `getCloneItemStack` returns the empty stack. `canBeReplaced(state, fluid)` is false.
- **Entity contact** (`entityInside`): when `entity.canUsePortal(false)`, on the server, and the block entity is a gateway that is
  not cooling down: `entity.setAsInsidePortal(this, pos)` and `blockEntity.triggerCooldown(serverLevel)`.
- **Destination** (`getPortalDestination`): the block entity's portal position, with a teleport transition; an ender pearl
  gets a transition without velocity (`TeleportTransition` with the `PLACE_PORTAL_TICKET` flag); the portal rules belong to the
  portal document (39).
- **Client**: `animateTick` spawns `portal` particles by `getParticleAmount()` of the block entity.

### 6.10 Command blocks (`CommandBlock`: fields 562 and 563; `COMMAND_BLOCK` itself is in part 5)

- **Class.** `CommandBlock(boolean automatic, Properties)` extends `BaseEntityBlock`; block entity `CommandBlockEntity`
  (31). Repeating: `automatic = false` (artifact value, read); chain: `automatic = true`. (The plain `COMMAND_BLOCK` also uses
  `false`.) `newBlockEntity` creates the entity and calls `setAutomatic(automatic)`.
  Builder: map colour `COLOR_PURPLE` (repeating) or `COLOR_GREEN` (chain), `requiresCorrectToolForDrops()`,
  `strength(-1.0, 3600000.0)`, `noLootTable()`.
- **States.** 12: `conditional` (boolean), `facing` (six values: north, east, south, west, up, down). Default: `conditional`
  false, facing north (index 6).
- **Placement**: `facing` = `context.getNearestLookingDirection().getOpposite()`.
- **Block rules**: `rotate` and `mirror` apply to `facing`. `hasAnalogOutputSignal` true; the signal is the command's last success
  count (`BaseCommandBlock.getSuccessCount`, from the block entity). `useWithoutItem` opens the command block screen for a
  player who can use game master blocks (`Player.canUseGameMasterBlocks`, `SUCCESS`), else `PASS`.
- **Redstone and chain execution** (`neighborChanged`, `tick`, `executeChain`, `setPoweredAndUpdate`): the entity's powered flag is
  updated from `level.hasNeighborSignal(pos)`; a rising edge on a non-automatic entity whose mode is `SEQUENCE` marks
  the condition met and schedules a tick (delay 1). `tick` reads the entity's mode: `AUTO` or `REDSTONE` modes run the
  command (`BaseCommandBlock.performCommand`) when the condition is met (conditional blocks check the previous block's success)
  and update comparator neighbours; after execution a chain follows `facing` through blocks that are `CHAIN_COMMAND_BLOCK`, bounded by the game
  rule `maxCommandSequenceLength`, with the warning "Command Block chain tried to execute more than {} steps!" when the
  bound is hit. The mode (impulse, repeating, chain) is a property of the block entity, derived from which block it is on. The full
  chain algorithm belongs to the block entity documents (31 part 6): Open question 8.
- `setPlacedBy`: the command feedback flag (`SEND_COMMAND_FEEDBACK`) is copied to the command block's `trackOutput`
  when the item has no block entity data; `automatic` is applied; `setPoweredAndUpdate` with the current neighbour signal.

### 6.11 Small blocks of the Nether and the End, and the observer (fields 564 to 570)

- **`FROSTED_ICE`** (`FrostedIceBlock`, key `frosted_ice`, no item; extends `IceBlock` extends `HalfTransparentBlock`). Builder:
  map colour `ICE`, `friction(0.98)`, `strength(0.5)`, sound `GLASS`, `noOcclusion()`, `isValidSpawn` true only for polar bears
  (`entityType == POLAR_BEAR`), `isRedstoneConductor(never)`. States 4: `age` 0 to 3, default 0. Default full-cube shape.
  `getCloneItemStack` returns the empty stack. `HalfTransparentBlock.skipRendering(state, neighbour, direction)`: true when
  the neighbour state is this block, else the generic rule (client).
  - `onPlace`: schedule a tick in `Mth.nextInt(random, 60, 120)` ticks.
  - `tick`: let `n3 = random.nextInt(3) == 0` and `f4 = fewerNeighboursThan(level, pos, 4)`; continue only when `n3 || f4`.
    The light value `L` = the block light at the position when the level is the End (`Level.END`), else
    `getMaxLocalRawBrightness(pos)`. If `L > 11 - age - state.getLightDampening()`: call `slightlyMelt`; if it returned true
    (the block was removed or turned to water), for each of the six directions whose neighbour is frosted ice: call
    `slightlyMelt` on it, and if that did not melt it completely, schedule its tick in 20 to 40 ticks (`Mth.nextInt`). In every
    other case reschedule this block's tick in `Mth.nextInt(random, 20, 40)` ticks (the artifact reschedules also when the light
    test fails).
  - `slightlyMelt(state, level, pos)`: if `age < 3`: set `age + 1` (flags 2) and return false; else `melt` and return true.
  - `melt` (`IceBlock.melt`): when the environment attribute `water_evaporates` is true at the block position (`getValue(attribute, pos)`), remove the block
    (`removeBlock(pos, false)`); otherwise set water (`Blocks.WATER.defaultBlockState()`, `setBlockAndUpdate`), notify
    neighbours with the water block, and send game event `block_destroy`.
  - `playerDestroy` (inherited from `IceBlock`): after the normal destroy, unless the tool carries an enchantment in the enchantment tag `prevents_ice_melting`: (a) when the environment attribute `water_evaporates` at the broken position is true, remove the block (`removeBlock(pos, false)`) and stop; (b) otherwise, when the state below is in block tag `ice_melts_when_destroyed_above` or is a liquid, set water at the broken position (`setBlockAndUpdate`).
  - Frosted ice has no `randomTicks` flag, so `IceBlock.randomTick` never runs for it; only the scheduled `tick` above melts it.
  - `neighborChanged`: when the changed neighbour block is frosted ice and `fewerNeighboursThan(level, pos, 2)`, `melt`; then the generic rule.
  - `fewerNeighboursThan(level, pos, limit)`: counts the six neighbours (in `Direction.values()` order) that are frosted ice; returns
    false as soon as the count reaches `limit` (`count >= limit`); true after the loop.
- **`MAGMA_BLOCK`** (`MagmaBlock`). Builder: map colour `NETHER`, instrument `BASEDRUM`, `requiresCorrectToolForDrops()`,
  `lightLevel(3)`, `strength(0.5)`, `isValidSpawn` true only for fire-immune entity types (`EntityType.fireImmune()`),
  `postProcess(position above)`, `emissiveRendering(always)`. 1 state, full cube. `stepOn(level, pos, state, entity)`: unless the entity is
  stepping carefully (`isSteppingCarefully`, sneaking) and when it is a `LivingEntity`, `entity.hurt(damageSources.hotFloor(),
  1.0)`.
- **`NETHER_WART_BLOCK`** (map colour `COLOR_RED`, `strength(1.0)`, sound `WART_BLOCK`), **`RED_NETHER_BRICKS`** (`NETHER`,
  `BASEDRUM`, tool required, 2.0 / 6.0, sound `NETHER_BRICKS`), **`BONE_BLOCK`** (`RotatedPillarBlock`, `SAND`, `XYLOPHONE`,
  tool required, `strength(2.0)`, sound `BONE_BLOCK`; states `axis`, rules as the purpur pillar): plain, no further rules.
- **`STRUCTURE_VOID`** (`StructureVoidBlock`; key `structure_void`, an item exists). Builder: `replaceable()`, `noCollision()`,
  `noLootTable()`, `noTerrainParticles()`, `pushReaction(POPPED)`, strength 0.0 (no strength call). 1 state. Shape `cube(6)` =
  box(5,5,5, 11,11,11). Render shape `INVISIBLE`. `getShadeBrightness` returns 1.0 (client).
- **`OBSERVER`** (`ObserverBlock`; extends `DirectionalBlock`). Builder: map colour `STONE`, `BASEDRUM`, `strength(3.0)`,
  `requiresCorrectToolForDrops()`, `isRedstoneConductor(never)`. States 12: `facing` (six values), `powered` (boolean). Default:
  facing south, `powered` false (index 5). Placement: `facing` = the nearest looking direction (the artifact applies
  `getOpposite()` twice, which cancels; so the observer's face points the way the player looks).
  Signal rules (specified with redstone in 30 part 2): `isSignalSource` true; `getSignal(dir)` = 15 when `powered` and `dir == facing`,
  else 0 (`getDirectSignal` equals `getSignal`); `shouldRedstoneWireConnectTo(dir)` is `dir == facing`. `updateShape` for the neighbour in the `facing`
  direction, when not `powered`, schedules a tick in 2 ticks unless one is already scheduled (`startSignal`, server only).
  `tick`: when `powered`, set it false (flags 2); otherwise set it true (flags 2) and schedule another tick in 2 ticks; in both cases
  `updateNeighborsInFront` (notify the block behind the observer, `pos.relative(facing.opposite)`, and the blocks around it
  except from the facing side). `onPlace` and `affectNeighborsAfterRemoval` clear `powered` (flags 18) and notify when needed.

### 6.12 Shulker boxes (`ShulkerBoxBlock`: fields 571 and 572)

- **Class.** `ShulkerBoxBlock(DyeColor, Properties)` extends `BaseEntityBlock`; block entity `ShulkerBoxBlockEntity(color)`
  (31); the plain box `SHULKER_BOX` passes no colour (null: the registry lambda passes `aconst_null` as the first constructor argument, read). Builder
  (`shulkerBoxProperties(mapColor)`, section 3.4): `forceSolidOn()`, `strength(2.0)`, `dynamicShape()`, `noOcclusion()`,
  `isSuffocating(NOT_CLOSED_SHULKER)`, `pushReaction(POPPED)`. Map colour: the plain box `COLOR_PURPLE`; a dyed box
  `DyeColor.getMapColor()` of its colour, except that the **purple** dyed box uses `TERRACOTTA_PURPLE` (so that it differs
  from the plain box). No `requiresCorrectToolForDrops`.
- **States.** 6: `facing` (north, east, south, west, up, down). Default `up` (index 4). Placement: `facing` = the clicked face.
- **Shape.** From the block entity: the box `Shulker.getProgressAabb(1.0, facing, 0.5 * progress, origin (0.5, 0, 0.5))` where `progress`
  is the lid animation value in 0 to 1; read from `Shulker.getProgressDeltaAabb`: the unit cube extended along `facing` by
  `0.5 * progress` (the second argument minimum is -1, so no contraction). With no block entity the shape is `Shapes.block()`.
  A closed box is the full cube. `getBlockSupportShape`: when the entity is not closed, `SHAPES_OPEN_SUPPORT[facing.opposite]`
  = `rotateAll(boxZ(16, 0, 1))` (a one-pixel plate on the face opposite to the lid, for example box(0,0,0, 16,16,1) for key
  north); otherwise the full cube. `propagatesSkylightDown` is false.
- **Opening** (`useWithoutItem`): on the server with a shulker box entity: `canOpen(state, level, pos, entity)`: true when the
  lid animation status is not `CLOSED`, else the extension box `getProgressDeltaAabb(1.0, facing, 0.0, 0.5, (pos bottom
  centre))` deflated by 1.0E-6 has no collisions (`Level.noCollision`). When allowed: open the menu, award the stat
  `open_shulker_box`, anger nearby piglins (`PiglinAi.angerNearbyPiglins`); return `SUCCESS` (also for the client). The menu is in 40.
- **Breaking** (`playerWillDestroy`): when the entity is not empty and the player does not prevent drops, the item is
  dropped with the entity's components (`BlockEntity.collectComponents`, contents kept) as a fresh item entity at the block
  centre; when the player prevents drops (creative) and the box is not empty, the loot table is unpacked. `getDrops` adds a
  dynamic drop named `contents` (the stored items). The analogue signal is the container fullness
  (`AbstractContainerMenu.getRedstoneSignalFromBlockEntity`). `rotate`/`mirror` apply to `facing`.

### 6.13 Glazed terracotta, concrete, concrete powder (fields 573 to 577)

- **`<colour>_GLAZED_TERRACOTTA`** (`GlazedTerracottaBlock extends HorizontalDirectionalBlock`). Builder: `mapColor(dye)`,
  `BASEDRUM`, `requiresCorrectToolForDrops()`, `strength(1.4)`, `pushReaction(PUSH)` (note: `PUSH`, not `PUSH_PULL`; the
  meaning, pushed only along the piston's facing and never pulled, is specified in 30 part 3 and not read again here). States 4: `facing` (north, south, west, east); default north (index 0). Placement:
  `facing` = the opposite of the player's horizontal direction. Full cube.
- **`<colour>_CONCRETE`** (`Block`): `mapColor(dye)`, `BASEDRUM`, tool required, `strength(1.8)`. 1 state.
- **`<colour>_CONCRETE_STAIRS`**, **`<colour>_CONCRETE_SLAB`**: sections 3.3 and 6.6; hardness and resistance 1.8, tool required,
  instrument `BASEDRUM`, map colour of the colour, sound `STONE`.
- **`<colour>_CONCRETE_POWDER`** (`ConcretePowderBlock(concrete, Properties)` extends `FallingBlock`; `concrete` = the concrete block of the same
  colour). Builder: `mapColor(dye)`, instrument `SNARE`, `strength(0.5)`, sound `SAND`. 1 state. The falling behaviour
  (gravity, `onLand`) is the falling block rule (29b part 1). Block-local rules:
  - `canSolidify(state)` = the state's fluid is in tag `water`.
  - `touchesLiquid(level, pos)`: for each `d` in `Direction.values()` order (down, up, north, south, west, east): `s` = the state at the
    last set position (`pos` itself at the start); when `d == down` and `!canSolidify(s)`, skip this direction; otherwise `m =
    pos.relative(d)`, `s = state at m`; if `canSolidify(s)` and `!s.isFaceSturdy(level, pos, d.opposite)` the result is true and
    the loop stops. The state is read at `m` but the position argument of `isFaceSturdy` is the powder's own `pos` (read from the call's arguments, not `m`); the direction is `d.opposite`. For water states the answer is the same either way. (So the cell below is considered only when the powder's own cell already holds water.)
  - `shouldSolidify(level, pos, state)` = `canSolidify(state) || touchesLiquid(level, pos)`.
  - Placement: when `shouldSolidify(level, pos, level.getBlockState(pos))` the placed state is the matching concrete block; else
    the falling block's placement (the default state).
  - `updateShape`: when `touchesLiquid(level, pos)` the result is the matching concrete state; else the falling block's update.
  - `onLand(level, pos, state, replacedState, entity)`: when `shouldSolidify(level, pos, replacedState)`, set the concrete state
    (`setBlockAndUpdate`). `getDustColor` is the map colour's `col` value (client particles).

### 6.14 Kelp and dried kelp (fields 578 to 580)

- **`KELP`** (`KelpBlock extends GrowingPlantHeadBlock`). Builder: map colour `WATER`, `noCollision()`, `randomTicks()`,
  `instabreak()`, sound `WET_GRASS`, `pushReaction(POPPED)`. States 26: `age` 0 to 25 (default 0). Constructor arguments:
  growth direction `up`, shape `column(16, 0, 9)` = box(0,0,0, 16,9,16), `scheduleFluidTicks` true, grow probability 0.14.
- **`KELP_PLANT`** (`KelpPlantBlock extends GrowingPlantBodyBlock`, key `kelp_plant`, no item). Builder: as kelp without
  `randomTicks`. 1 state. Shape `Shapes.block()` for selection (collision empty). Growth direction `up`, `scheduleFluidTicks` true.
- **Both**: the fluid state is always the water source (`Fluids.WATER.getSource(false)`); `canPlaceLiquid` and `placeLiquid` are false.
- **Survival** (`GrowingPlantBlock.canSurvive`): let `B` = the state below. False when `!canAttachTo(B)`. Otherwise true when `B` is
  kelp or kelp plant, or `B.isFaceSturdy(level, pos.below(), up)`. `canAttachTo` for kelp is `!state.is(cannot_support_kelp)`; for
  the plant it is the head's rule. A failed survival schedules a tick (delay 1) from `updateShape` when the changed direction is
  down; `tick` destroys with drops when `!canSurvive`.
- **Placement** (`KelpBlock.getStateForPlacement`): null unless the fluid at the position is water **and** full
  (`isFull`). Otherwise `GrowingPlantBlock.getStateForPlacement`: when the cell above (the growth direction) is kelp or kelp plant,
  the plant block's default state; else the kelp default state with `age = random.nextInt(25)` (0 to 24).
- **Growth.** `isRandomlyTicking` = `age < 25`. Random tick: when `age < 25` and `random.nextDouble() < 0.14` and the cell above is
  water (`canGrowInto(state)` = `state.is(Blocks.WATER)`): set the cell above to the kelp state with `age + 1`
  (`getGrowIntoState` = `age` cycled, `setBlockAndUpdate`). Bone meal: valid when the cell above can be grown into and is inside the
  build height; always succeeds; grows `getBlocksToGrowWhenBonemealed` = 1 block. Kelp with a kelp or kelp plant block above becomes the
  plant (`updateShape` for the growth direction: the result is `KELP_PLANT.defaultBlockState()`); a kelp plant whose upper neighbour
  is neither kelp nor kelp plant becomes a kelp head with a random age 0 to 24 (`updateShape` of the body).
  When the changed neighbour is below and `!canSurvive`, a tick is scheduled; when `scheduleFluidTicks` a water tick is scheduled.
- **`DRIED_KELP_BLOCK`**: plain `Block`: map colour `COLOR_GREEN`, `strength(0.5, 2.5)`, sound `GRASS`. 1 state.

### 6.15 Eggs and the dried ghast (fields 581 to 583)

- **`TURTLE_EGG`** (`TurtleEggBlock`). Builder: map colour `SAND`, `forceSolidOn()`, `strength(0.5)`, sound `METAL`, `randomTicks()`,
  `noOcclusion()`, `pushReaction(POPPED)`. States 12: `eggs` 1 to 4, `hatch` 0 to 2 (sorted names: eggs, hatch). Default eggs 1,
  hatch 0 (index 0). Shapes: `eggs == 1`: box(3,0,3, 12,7,12); `eggs > 1`: `column(14, 0, 7)` = box(1,0,1, 15,7,15).
  - Placement: when the position already holds a turtle egg, `eggs = min(4, eggs + 1)`; else the default state.
    `canBeReplaced(context)`: true when the player is not using secondary use (sneaking), the held item is this egg item and
    `eggs < 4`; else the generic rule.
  - `onPlace`: when the block below is sand (`onSand`: tag `sand`) and on the server, level event 2012 (sand particles) with data 15.
  - Random tick: `shouldUpdateHatchLevel` = the environment attribute `turtle_egg_hatch_chance` (33 §3.4) is above 0 and
    `random.nextFloat() < chance`; the egg advances only when that is true **and** the block below is sand. When `hatch < 2`:
    play `turtle_egg_crack` (volume 0.7, pitch `0.9 + random * 0.2`), set `hatch + 1` (flags 2), game event `block_change`.
    At `hatch == 2`: play `turtle_egg_hatch` (volume 0.7, pitch `0.9 + random * 0.2`), remove the block (`removeBlock(pos, false)`), game event `block_destroy`; for each
    egg (`eggs` times): level event 2001 with the block state id, create a baby turtle (`EntityTypes.TURTLE`, spawn reason
    `BREEDING`), age `-24000`, home position the block's position, positioned at `x + 0.3 + i * 0.2`, `y`, `z + 0.3`, add
    to the level.
  - Trampling: `stepOn` (unless the entity is stepping carefully) calls `destroyEgg(level, state, pos, entity, 100)`; `fallOn` calls
    `destroyEgg(.., 3)` for every entity that is not a zombie. `destroyEgg(level, state, pos, entity, divisor)`: only when the state
    is a turtle egg, the level is a server level, `canDestroyEgg(level, pos, entity)` is true and `random.nextInt(divisor) == 0`:
    then `decreaseEggs`.
    `canDestroyEgg`: false for a turtle; false for a bat; for a player, true unless the server's spawn protection covers
    the position (33 §6.5); for any other living entity, the value of the game rule `mobGriefing`; for every other entity false.
  - `decreaseEggs`: play `turtle_egg_break` (volume 0.7, pitch `0.9 + random * 0.2`); when `eggs <= 1` destroy the block
    (`destroyBlock(pos, false)`), else `eggs - 1` (flags 2) and game event `block_destroy`; level event 2001.
  - `playerDestroy`: the normal destroy then `decreaseEggs` (breaking an egg block removes one egg at a time).
- **`SNIFFER_EGG`** (`SnifferEggBlock`). Builder: map colour `COLOR_RED`, `strength(0.5)`, sound `METAL`, `noOcclusion()`. States 3:
  `hatch` 0 to 2 (default 0). Shape `column(14, 12, 0, 16)` = box(1,0,2, 15,16,14). `isPathfindable` false.
  `onPlace`: when the block below is in tag `sniffer_egg_hatch_boost` the hatch time is 12000 ticks, else 24000; the
  first tick is scheduled after `time / 3 + random.nextInt(300)` ticks (`RANDOM_HATCH_OFFSET_TICKS` = 300), game event `block_place`, level event
  3009 with data 0 (on the server, only when boosted). `tick`: when `hatch < 2` play `sniffer_egg_crack` and set `hatch + 1` (flags 2); at
  `hatch == 2` play `sniffer_egg_hatch`, destroy the block (`destroyBlock(pos, false)`), spawn a baby sniffer (`EntityTypes.SNIFFER`,
  spawn reason `BREEDING`, baby) at the block centre with a random yaw, then add it. (Tick rescheduling after each stage is by the same hatch time
  rule; `tick` contains no scheduling call, so the next stage is scheduled by `onPlace`, which must run again when the stage change is
  placed with `setBlock` (inferred, Open question 9).) Sound parameters read in `tick`: `sniffer_egg_crack` and `sniffer_egg_hatch` are both played at volume 0.7 and pitch `0.9 + random.nextFloat() * 0.2`. `onPlace` is the only caller of `scheduleTick` in the class (read).
- **`DRIED_GHAST`** (`DriedGhastBlock extends HorizontalDirectionalBlock`). Builder: map colour `COLOR_GRAY`, `forceSolidOn()`, `instabreak()`,
  sound `DRIED_GHAST`, `noOcclusion()`, `randomTicks()`. States 32: `facing` (4), `hydration` 0 to 3, `waterlogged`; default facing
  north, hydration 0, not waterlogged (index 1). Shape `column(10, 10, 0, 10)` = box(3,0,3, 13,10,13). `isPathfindable` false.
  - Placement: `facing` = the opposite of the player's horizontal direction; `waterlogged` = the fluid at the position is water.
  - `placeLiquid` (when not already waterlogged and the fluid is water): set `waterlogged`, schedule the fluid tick, play
    `dried_ghast_place_in_water`, result true. `setPlacedBy` plays `dried_ghast_place_in_water` or `dried_ghast_place`.
  - Random tick: when (the block is waterlogged or `hydration > 0`) and no tick is scheduled for the block at the position, schedule
    a tick in 5000 ticks.
  - Tick: when waterlogged: if `hydration == 3` spawn a ghastling (remove the block; create a `HAPPY_GHAST` (baby, spawn reason
    `BREEDING`) at the block's bottom centre with head yaw `facing.getYRot()`; play `ghastling_spawn`); else play `dried_ghast_transition`
    and set `hydration + 1` (flags 2), game event `block_change`. When not waterlogged and `hydration > 0`: set `hydration - 1`
    (flags 2), game event `block_change`.
  - `animateTick` (client; read in full). Let `c` = the block centre (x+0.5, y+0.5, z+0.5). Two branches, chosen by `waterlogged`:
    - **Not waterlogged.** (a) `random.nextInt(40) == 0` and the state below is in block tag `triggers_ambient_dried_ghast_block_sounds`: play `dried_ghast_ambient` (source BLOCKS, volume 1.0, pitch 1.0, no distance delay) as a local sound at `c`. (b) Independently, `random.nextInt(6) == 0`: spawn a `white_smoke` particle at `c` with velocity (0, 0.02, 0). The particle is not conditioned on the tag.
    - **Waterlogged.** (a) `random.nextInt(40) == 0`: play `dried_ghast_ambient_water` (BLOCKS, volume 1.0, pitch 1.0, local, no distance delay) at `c`. (b) Independently, `random.nextInt(6) == 0`: spawn a `happy_villager` particle at x = `x + 0.5 + (nextFloat * 2 - 1) / 3`, y = `y + 0.5 + 0.4` (that is `y + 0.9`), z = `z + 0.5 + (nextFloat * 2 - 1) / 3`, with velocity (0, `nextFloat`, 0): x and z velocity are 0 and the y velocity is one fresh `nextFloat` value. (Read: the centre y of 0.5 plus the constant 0.4.)
    The draw order within a call is: `nextInt(40)` first, then the tag test (not waterlogged only), then `nextInt(6)`, then for the waterlogged particle `nextFloat` for x, `nextFloat` for z, `nextFloat` for the y velocity (in that order of evaluation).

### 6.16 Corals (fields 584 to 623: 5 coral kinds, 8 field groups of 5)

Five kinds in this order: `tube`, `brain`, `bubble`, `fire`, `horn`. The 40 fields are in eight groups of five, in field order:
dead blocks (584 to 588), live blocks (589 to 593), dead plants (594 to 598), live plants (599 to 603), dead fans (604 to 608),
live fans (609 to 613), dead wall fans (614 to 618), live wall fans (619 to 623). Keys are `dead_<kind>_coral_block`,
`<kind>_coral_block`, `dead_<kind>_coral`, `<kind>_coral`, `dead_<kind>_coral_fan`, `<kind>_coral_fan`,
`dead_<kind>_coral_wall_fan`, `<kind>_coral_wall_fan`.

Colours by kind (live blocks, plants, fans and wall fans): tube `COLOR_BLUE`, brain `COLOR_PINK`, bubble `COLOR_PURPLE`, fire
`COLOR_RED`, horn `COLOR_YELLOW`. Every dead variant has map colour `COLOR_GRAY`.

| Group | Class (constructor extra) | Builder (besides the map colour) | States |
|---|---|---|---|
| dead block | plain `Block` | `forceSolidOn()`, instrument `BASEDRUM`, tool required, `strength(1.5, 6.0)`, sound `STONE` | 1 |
| live block | `CoralBlock(deadBlock)` | instrument `BASEDRUM`, tool required, `strength(1.5, 6.0)`, sound `CORAL_BLOCK` | 1 |
| dead plant | `BaseCoralPlantBlock` | `forceSolidOn()`, `BASEDRUM`, tool required, `noCollision()`, `instabreak()`, sound `STONE` | 2 (`waterlogged`) |
| live plant | `CoralPlantBlock(deadBlock = dead plant)` | `noCollision()`, `instabreak()`, sound `WET_GRASS`, `pushReaction(POPPED)` | 2 |
| dead fan | `BaseCoralFanBlock` | as dead plant | 2 |
| live fan | `CoralFanBlock(deadBlock = dead fan)` | as live plant | 2 |
| dead wall fan | `BaseCoralWallFanBlock`, properties `wallVariant(dead fan, false)` | as dead plant | 8 (`facing`, `waterlogged`) |
| live wall fan | `CoralWallFanBlock(deadBlock = dead wall fan)`, properties `wallVariant(live fan, false)` | as live plant | 8 |

The default state of every plant, fan and wall fan has `waterlogged` **true** (index 0 for plants and fans; wall fans have
facing north and waterlogged true, index 0). The wall fans' loot table key is the loot table key of the corresponding fan
(`overrideLootTable`), see section 3.4.

**Water rule.** `scanForWater` for a live coral block is: any of the six neighbours has a fluid state in tag `water`
(`Direction.values()`). For plants, fans and wall fans (`BaseCoralPlantTypeBlock.scanForWater(state, level, pos)`) it is true when
`state.waterlogged`, else the same six-neighbour test.
- **Coral block** (`CoralBlock`): placement: when `!scanForWater` schedule a tick in `60 + random.nextInt(40)` ticks; the placed
  state is the default state. `updateShape`: when `!scanForWater` schedule a tick (same delay), then the generic update. `tick`: when
  `!scanForWater`, set the dead block (`defaultBlockState`, flags 2).
- **Live plant, fan, wall fan**: `onPlace` runs `tryScheduleDieTick` (when `!scanForWater` schedule a tick in `60 + random.nextInt(40)`
  ticks). `updateShape`: when the changed direction is `down` (plant, fan) and `!canSurvive` the result is air; for a wall fan
  when the changed direction is the opposite of `facing` and `!canSurvive` the result is air; then the die tick is scheduled again
  by the same test, a water tick is scheduled when `waterlogged`, and the generic update. `tick`: when `!scanForWater` set the
  dead block with `waterlogged = false` (and, for a wall fan, the same `facing`), flags 2.
- **Placement** of plants, fans and wall fans: `waterlogged` = the fluid at the position is in tag `water` **and** is full
  (`FluidState.isFull()`). For wall fans, additionally, the placement tries the directions of `context.getNearestLookingDirections()` in
  order; for the first horizontal one `d`, `facing = d.opposite`; the state is returned when it can survive; no horizontal
  direction works: null.
- **Survival.** Plants and fans (`BaseCoralPlantTypeBlock.canSurvive`): the state below has its `up` face sturdy
  (`isFaceSturdy(level, pos.below(), UP)`). Wall fans: the state at `pos.relative(facing.opposite)` has the face towards the fan
  sturdy (the direction argument is `facing`, read from `BaseCoralWallFanBlock.canSurvive`).
- **Shapes** (pixels): coral plant (live and dead): `column(12, 0, 15)` = box(2,0,2, 14,15,14); fan (live and dead):
  `column(12, 0, 4)` = box(2,0,2, 14,4,14); wall fan: `rotateHorizontal(boxZ(16, 8, 5, 16))` = for key `north` box(0,4,5, 16,12,16),
  the other keys are rotations (the fan hangs on the wall opposite to `facing`). Plants and fans have `noCollision`, so their
  collision shape is empty. The `BaseCoralPlantTypeBlock` default shape `column(12,0,4)` is overridden by the plant class.
- **Liquid.** `getFluidState` returns the water source when `waterlogged`, else the empty fluid state (via `Block.getFluidState`).
  `waterlogged` blocks schedule water ticks from `updateShape`. Placement and removal of liquid use the standard waterlogged
  rules (29a).
- **Bone meal and ecology**: coral blocks are in tag `coral_blocks`, plants in `coral_plants`, fans in `corals`, wall fans in
  `wall_corals` (the tag contents are data; the tag names exist in `BlockTags`, 24 part 1 §12.3). The coral growth feature is world generation (35).

### 6.17 Sea pickle, blue ice, conduit (fields 624 to 626)

- **`SEA_PICKLE`** (`SeaPickleBlock extends VegetationBlock`). Builder: map colour `COLOR_GREEN`, sound `SLIME_BLOCK`, `noOcclusion()`,
  `pushReaction(POPPED)`, `lightLevel(dead ? 0 : 3 + 3 * pickles)` (`dead` is `waterlogged == false`: `SeaPickleBlock.isDead`),
  strength 0.0 (no strength call). States 8: `pickles` 1 to 4 and `waterlogged`; default pickles 1, waterlogged true (index 0).
  - Light: waterlogged pickles give 6, 9, 12, 15 for 1 to 4 pickles; a dry pickle (`waterlogged` false) gives 0.
  - Shapes (pixels): 1 pickle `column(4, 0, 6)` = box(6,0,6, 10,6,10); 2 pickles `column(10, 0, 6)` = box(3,0,3, 13,6,13); 3 pickles
    `column(12, 0, 6)` = box(2,0,2, 14,6,14); 4 pickles `column(12, 0, 7)` = box(2,0,2, 14,7,14). Collision: default (the shape; the
    block has collision).
  - `mayPlaceOn(state, level, pos)`: the state's collision shape has a non-empty face shape on `up`, **or** `state.isFaceSturdy(level, pos, up)`.
    `canSurvive` is `mayPlaceOn(state below)`. `updateShape`: when `!canSurvive` air; when `waterlogged` schedule a water tick; else
    the generic update.
  - Placement: when the position already holds a sea pickle, that state with `pickles = min(4, pickles + 1)`; otherwise the
    default state with `waterlogged` = the fluid at the position is water (`FluidState.is(Fluids.WATER)`, not required to be full).
    `canBeReplaced(context)`: true when not using secondary use, the held item is the sea pickle item and `pickles < 4`; else
    the generic vegetation rule.
  - `isPathfindable` false. The fluid state is the water source when `waterlogged`.
  - Bone meal (`isValidBonemealTarget`): not dead and the block below is in tag `coral_blocks`; always succeeds (`performBonemeal`):
    1. Scatter. Iterate five columns `i = 0..4` at `x = pos.x - 2 + i`. The z-span of column `i` is centred on `pos.z` with width `w` = 1, 3, 5, 3, 1 for `i` = 0..4 (z from `pos.z - (w-1)/2` to `pos.z + (w-1)/2`). For each z of the span and for `y = pos.y - 1` and `y = pos.y`: skip the candidate equal to `pos`; otherwise with probability 1/6 (`nextInt(6) == 0`), when the candidate state is the water block (`Blocks.WATER`, any level) and the state below it is in block tag `coral_blocks`, set the candidate to the sea pickle default state with `pickles = nextInt(4) + 1` (`setBlockAndUpdate`; the default `waterlogged` is true).
    2. Finally set `pos` to its state with `pickles = 4` (`setBlock`, flags 2).
- **`BLUE_ICE`** (`HalfTransparentBlock`). Builder: map colour `ICE`, `strength(2.8)`, `friction(0.989)`, sound `GLASS`. 1 state, full
  cube, tool not required. `skipRendering` is true when the neighbour is the same block (client face culling). Friction 0.989 is the
  slipperiness value used by the movement rule (13).
- **`CONDUIT`** (`ConduitBlock`, block entity `ConduitBlockEntity`, 31). Builder: map colour `DIAMOND`, `forceSolidOn()`,
  instrument `HAT`, `strength(3.0)`, `lightLevel(15)`, `noOcclusion()`. States 2: `waterlogged`; default true (index 0). Shape
  `cube(6)` = box(5,5,5, 11,11,11). Placement: `waterlogged` = fluid in tag `water` and full. `updateShape` schedules a water tick when
  waterlogged. `isPathfindable` false. The block entity ticks on the server and on the client (separate tickers).

### 6.18 Bamboo (fields 627 to 629)

- **`BAMBOO_SAPLING`** (`BambooSaplingBlock`, key `bamboo_sapling`, no item). Builder: map colour `WOOD`, `forceSolidOn()`,
  `randomTicks()`, `instabreak()` then `noCollision()` then `strength(1.0)` (so hardness and resistance are 1.0), sound
  `BAMBOO_SAPLING`, `offsetType(XZ)`, `ignitedByLava()`, `pushReaction(POPPED)`. 1 state.
  - Shape: `column(8, 0, 12)` = box(4,0,4, 12,12,12) moved by the block's offset (`BlockState.getOffset`, 24 part 1 §4.4, horizontal
    only; maximum offset 0.25). No collision.
  - Survival: the state below is in tag `supports_bamboo`. `updateShape`: when `!canSurvive` air; when the changed direction is
    `up` and the neighbour is `BAMBOO`, the result is `BAMBOO.defaultBlockState()`; else the generic update.
  - Random tick: when `random.nextInt(3) == 0`, `pos.above()` is empty and `level.getRawBrightness(pos.above(), 0) >= 9`:
    `growBamboo`: set `pos.above()` to the `BAMBOO` default state with `leaves = small` (`setBlockAndUpdate`). Bone meal: valid when
    the cell above is air and inside the build height; always succeeds; the same `growBamboo`. Clone item: bamboo.
- **`BAMBOO`** (`BambooStalkBlock`, item `bamboo`). Builder: map colour `PLANT`, `forceSolidOn()`, `randomTicks()`, `instabreak()` then
  `strength(1.0)` (hardness and resistance 1.0), sound `BAMBOO`, `noOcclusion()`, `dynamicShape()`, `offsetType(XZ)`, `ignitedByLava()`,
  `pushReaction(POPPED)`, `isRedstoneConductor(never)`. States 12: `age` 0 to 1, `leaves` (none, small, large), `stage` 0 to 1 (sorted names
  age, leaves, stage); default age 0, leaves none, stage 0 (index 0; index = `age * 6 + leaves * 2 + stage`). `isRandomlyTicking` is true when `stage == 0`.
  - Shapes (pixels, all moved by the block offset): selection shape: `leaves == large`: `column(10, 0, 16)` = box(3,0,3, 13,16,13); else
    `column(6, 0, 16)` = box(5,0,5, 11,16,11). Collision shape: `column(3, 0, 16)` = box(6.5,0,6.5, 9.5,16,9.5). `isCollisionShapeFullBlock` is
    false. `propagatesSkylightDown` is true. `isPathfindable` is false.
  - Survival: the state below is in tag `supports_bamboo`. `tick`: destroy with drops when `!canSurvive`.
  - Placement (`getStateForPlacement`): null when the fluid at the position is not empty; null when the state below is not in tag
    `supports_bamboo`. Let `B` = the state below. If `B` is `BAMBOO_SAPLING`: the default state with `age = 0`. If `B` is `BAMBOO`:
    the default state with `age = 1` when `B.age > 0`, else 0. Otherwise let `A` = the state above: when `A` is `BAMBOO` the default
    state with `age = A.age`; else `BAMBOO_SAPLING.defaultBlockState()` (placing the item on the ground plants a sapling).
  - Neighbour shape update: when `!canSurvive` schedule a tick (delay 1); when the changed direction is `up`, the neighbour is bamboo and
    `neighbour.age > age`, the result is the state with `age` cycled (0 to 1); else the generic update.
  - Random tick (`stage == 0` only): when `random.nextInt(3) == 0`, `pos.above()` is empty and `getRawBrightness(pos.above(), 0) >= 9`, let
    `h = getHeightBelowUpToMax(level, pos) + 1` (the number of bamboo blocks below, counted up to 16, plus 1); when `h < 16`, `growBamboo(state, level, pos, random, h)`.
  - `growBamboo(state, level, pos, random, h)`: `B` = the state below, `B2` = the state two below. `leaves = none`. When `h >= 1`:
    if `B` is not bamboo or `B.leaves == none`: `leaves = small`; otherwise (`B` is bamboo with leaves): `leaves = large` and, when `B2` is
    bamboo, set `pos.below()` to `B` with `leaves = small` and `pos.below(2)` to `B2` with `leaves = none` (flags 3 each).
    `age = (state.age == 1 || B2 is bamboo) ? 1 : 0`. `stage = ((h >= 11 && random.nextFloat() < 0.25) || h == 15) ? 1 : 0`. Set
    `pos.above()` to the bamboo default state with those `age`, `leaves` and `stage` (flags 3). `MAX_HEIGHT` is 16; `getHeightAboveUpToMax` and
    `getHeightBelowUpToMax` count contiguous bamboo blocks up to 16.
  - Bone meal. Let `a` = the number of contiguous bamboo blocks above `pos` (`getHeightAboveUpToMax`, at most 16), `b` the number below
    (`getHeightBelowUpToMax`), `top = pos.above(a)` (the top stalk block) and `p = pos.above(a + 1)`.
    `isValidBonemealTarget` is true when `a + b + 1 < 16`, the state at `top` has `stage != 1`, `p` is inside the build height and `p` is empty.
    It always succeeds. `performBonemeal`: `total = a + b + 1`, `n = 1 + random.nextInt(2)`; repeat `n` times: `S` = the state at `top`,
    `p = top.above()`; stop when `total >= 16`, or `S.stage == 1`, or `p` is not empty, or `p` is outside the build height; otherwise
    `growBamboo(S, level, top, random, total)`, then `top = top.above()`, `total += 1`.
- **`POTTED_BAMBOO`** (`FlowerPotBlock(BAMBOO, Properties)`, key `potted_bamboo`, no item). Builder (`flowerPotProperties`): `instabreak()`,
  `noOcclusion()`, `pushReaction(POPPED)`; map colour none, sound `STONE`. 1 state. Shape `column(6, 0, 6)` = box(5,0,5, 11,6,11). The
  constructor registers the pot in the static map `POTTED_BY_CONTENT` (content block to potted block, so the empty pot can look up
  `POTTED_BAMBOO` for a bamboo item). `getCloneItemStack` returns the potted block item (bamboo) when not empty. `updateShape`: when the changed
  direction is `down` and `!canSurvive` the result is air (the default `canSurvive` is true, so this only matters for subclass
  overrides: none here). `isPathfindable` false. `isRandomlyTicking` is true only for the two eyeblossom pots.
  - `useItemOn`: let `P` = the potted block of the held item (the item must be a `BlockItem` whose block is a key of `POTTED_BY_CONTENT`; the
    value is the potted block). When there is none: `TRY_WITH_EMPTY_HAND`. When the pot is not empty (`potted != AIR`): `CONSUME`. Otherwise
    set `P`'s default state (`setBlockAndUpdate`), game event `block_change`, award the stat `pot_flower`, consume one item, `SUCCESS`.
    `useWithoutItem`: on an empty pot `CONSUME`; otherwise give the player one item of the potted block (dropped by the player when the inventory is full),
    set the empty `FLOWER_POT` default state, game event `block_change`, `SUCCESS`.

---

## 7. The registry rows

Row order is field order (field 525 first). Section 2 gives the id rule; section 5 the index rule. "Blocks" is the number of
registered blocks of the field (16 for a collection). "Default idx" is the index of the default state inside the block's state range.
"State offset" is the offset of the first state of the **first** block of the field from the first state of field 525 (`mangrove_fence_gate`);
the first state id of a block is `S6 + offset` where `S6` is the first state id of block id 689, that is the sum of the state counts of block
ids 0 to 688 (parts 1 to 5, Open question 1). For a collection the k-th colour (dye order, k from 0) starts at `offset + k * states`.
Counts: 105 fields, 195 blocks (ids 689 to 883), 3094 states (offsets 0 to 3093).

### 7.1 Identity, class, state properties

| Field | Key (block) | Block id | Blocks | Class | Properties (sorted by name; value order as listed) | States | Default idx | State offset |
|---:|---|---:|---:|---|---|---:|---:|---:|
| 525 | `mangrove_fence_gate` | 689 | 1 | FenceGateBlock(WoodType.MANGROVE) | facing: north/south/west/east; in_wall: bool; open: bool; powered: bool | 32 | 7 | 0 |
| 526 | `poplar_fence_gate` | 690 | 1 | FenceGateBlock(WoodType.POPLAR) | facing: north/south/west/east; in_wall: bool; open: bool; powered: bool | 32 | 7 | 32 |
| 527 | `bamboo_fence_gate` | 691 | 1 | FenceGateBlock(WoodType.BAMBOO) | facing: north/south/west/east; in_wall: bool; open: bool; powered: bool | 32 | 7 | 64 |
| 528 | `spruce_fence` | 692 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 96 |
| 529 | `birch_fence` | 693 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 128 |
| 530 | `jungle_fence` | 694 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 160 |
| 531 | `acacia_fence` | 695 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 192 |
| 532 | `cherry_fence` | 696 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 224 |
| 533 | `dark_oak_fence` | 697 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 256 |
| 534 | `pale_oak_fence` | 698 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 288 |
| 535 | `mangrove_fence` | 699 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 320 |
| 536 | `poplar_fence` | 700 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 352 |
| 537 | `bamboo_fence` | 701 | 1 | FenceBlock | east: bool; north: bool; south: bool; waterlogged: bool; west: bool | 32 | 31 | 384 |
| 538 | `spruce_door` | 702 | 1 | DoorBlock(BlockSetType.SPRUCE) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 416 |
| 539 | `birch_door` | 703 | 1 | DoorBlock(BlockSetType.BIRCH) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 480 |
| 540 | `jungle_door` | 704 | 1 | DoorBlock(BlockSetType.JUNGLE) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 544 |
| 541 | `acacia_door` | 705 | 1 | DoorBlock(BlockSetType.ACACIA) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 608 |
| 542 | `cherry_door` | 706 | 1 | DoorBlock(BlockSetType.CHERRY) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 672 |
| 543 | `dark_oak_door` | 707 | 1 | DoorBlock(BlockSetType.DARK_OAK) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 736 |
| 544 | `pale_oak_door` | 708 | 1 | DoorBlock(BlockSetType.PALE_OAK) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 800 |
| 545 | `mangrove_door` | 709 | 1 | DoorBlock(BlockSetType.MANGROVE) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 864 |
| 546 | `poplar_door` | 710 | 1 | DoorBlock(BlockSetType.POPLAR) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 928 |
| 547 | `bamboo_door` | 711 | 1 | DoorBlock(BlockSetType.BAMBOO) | facing: north/south/west/east; half: upper/lower; hinge: left/right; open: bool; powered: bool | 64 | 11 | 992 |
| 548 | `end_rod` | 712 | 1 | EndRodBlock | facing: north/east/south/west/up/down | 6 | 4 | 1056 |
| 549 | `chorus_plant` | 713 | 1 | ChorusPlantBlock | down: bool; east: bool; north: bool; south: bool; up: bool; west: bool | 64 | 63 | 1062 |
| 550 | `chorus_flower` | 714 | 1 | ChorusFlowerBlock(plant: CHORUS_PLANT) | age: 0..5 | 6 | 0 | 1126 |
| 551 | `purpur_block` | 715 | 1 | Block | - | 1 | 0 | 1132 |
| 552 | `purpur_slab` | 716 | 1 | SlabBlock | type: top/bottom/double; waterlogged: bool | 6 | 3 | 1133 |
| 553 | `purpur_pillar` | 717 | 1 | RotatedPillarBlock | axis: x/y/z | 3 | 1 | 1139 |
| 554 | `purpur_stairs` | 718 | 1 | StairBlock(base: PURPUR_BLOCK) | facing: north/south/west/east; half: top/bottom; shape: straight/inner_left/inner_right/outer_left/outer_right; waterlogged: bool | 80 | 11 | 1142 |
| 555 | `end_stone_bricks` | 719 | 1 | Block | - | 1 | 0 | 1222 |
| 556 | `torchflower_crop` | 720 | 1 | TorchflowerCropBlock | age: 0..1 | 2 | 0 | 1223 |
| 557 | `pitcher_crop` | 721 | 1 | PitcherCropBlock | age: 0..4; half: upper/lower | 10 | 1 | 1225 |
| 558 | `pitcher_plant` | 722 | 1 | DoublePlantBlock | half: upper/lower | 2 | 1 | 1235 |
| 559 | `beetroots` | 723 | 1 | BeetrootBlock | age: 0..3 | 4 | 0 | 1237 |
| 560 | `dirt_path` | 724 | 1 | PathBlock(base: DIRT) | - | 1 | 0 | 1241 |
| 561 | `end_gateway` | 725 | 1 | EndGatewayBlock | - | 1 | 0 | 1242 |
| 562 | `repeating_command_block` | 726 | 1 | CommandBlock(automatic=false) | conditional: bool; facing: north/east/south/west/up/down | 12 | 6 | 1243 |
| 563 | `chain_command_block` | 727 | 1 | CommandBlock(automatic=true) | conditional: bool; facing: north/east/south/west/up/down | 12 | 6 | 1255 |
| 564 | `frosted_ice` | 728 | 1 | FrostedIceBlock | age: 0..3 | 4 | 0 | 1267 |
| 565 | `magma_block` | 729 | 1 | MagmaBlock | - | 1 | 0 | 1271 |
| 566 | `nether_wart_block` | 730 | 1 | Block | - | 1 | 0 | 1272 |
| 567 | `red_nether_bricks` | 731 | 1 | Block | - | 1 | 0 | 1273 |
| 568 | `bone_block` | 732 | 1 | RotatedPillarBlock | axis: x/y/z | 3 | 1 | 1274 |
| 569 | `structure_void` | 733 | 1 | StructureVoidBlock | - | 1 | 0 | 1277 |
| 570 | `observer` | 734 | 1 | ObserverBlock | facing: north/east/south/west/up/down; powered: bool | 12 | 5 | 1278 |
| 571 | `shulker_box` | 735 | 1 | ShulkerBoxBlock(color=none) | facing: north/east/south/west/up/down | 6 | 4 | 1290 |
| 572 | `<colour>_shulker_box` | 736..751 | 16 | ShulkerBoxBlock(color) | facing: north/east/south/west/up/down | 6 | 4 | 1296 |
| 573 | `<colour>_glazed_terracotta` | 752..767 | 16 | GlazedTerracottaBlock | facing: north/south/west/east | 4 | 0 | 1392 |
| 574 | `<colour>_concrete` | 768..783 | 16 | Block | - | 1 | 0 | 1456 |
| 575 | `<colour>_concrete_stairs` | 784..799 | 16 | StairBlock(base: same-colour concrete) | facing: north/south/west/east; half: top/bottom; shape: straight/inner_left/inner_right/outer_left/outer_right; waterlogged: bool | 80 | 11 | 1472 |
| 576 | `<colour>_concrete_slab` | 800..815 | 16 | SlabBlock | type: top/bottom/double; waterlogged: bool | 6 | 3 | 2752 |
| 577 | `<colour>_concrete_powder` | 816..831 | 16 | ConcretePowderBlock(concrete=same colour) | - | 1 | 0 | 2848 |
| 578 | `kelp` | 832 | 1 | KelpBlock | age: 0..25 | 26 | 0 | 2864 |
| 579 | `kelp_plant` | 833 | 1 | KelpPlantBlock | - | 1 | 0 | 2890 |
| 580 | `dried_kelp_block` | 834 | 1 | Block | - | 1 | 0 | 2891 |
| 581 | `turtle_egg` | 835 | 1 | TurtleEggBlock | eggs: 1..4; hatch: 0..2 | 12 | 0 | 2892 |
| 582 | `sniffer_egg` | 836 | 1 | SnifferEggBlock | hatch: 0..2 | 3 | 0 | 2904 |
| 583 | `dried_ghast` | 837 | 1 | DriedGhastBlock | facing: north/south/west/east; hydration: 0..3; waterlogged: bool | 32 | 1 | 2907 |
| 584 | `dead_tube_coral_block` | 838 | 1 | Block | - | 1 | 0 | 2939 |
| 585 | `dead_brain_coral_block` | 839 | 1 | Block | - | 1 | 0 | 2940 |
| 586 | `dead_bubble_coral_block` | 840 | 1 | Block | - | 1 | 0 | 2941 |
| 587 | `dead_fire_coral_block` | 841 | 1 | Block | - | 1 | 0 | 2942 |
| 588 | `dead_horn_coral_block` | 842 | 1 | Block | - | 1 | 0 | 2943 |
| 589 | `tube_coral_block` | 843 | 1 | CoralBlock(dead=DEAD_TUBE_CORAL_BLOCK) | - | 1 | 0 | 2944 |
| 590 | `brain_coral_block` | 844 | 1 | CoralBlock(dead=DEAD_BRAIN_CORAL_BLOCK) | - | 1 | 0 | 2945 |
| 591 | `bubble_coral_block` | 845 | 1 | CoralBlock(dead=DEAD_BUBBLE_CORAL_BLOCK) | - | 1 | 0 | 2946 |
| 592 | `fire_coral_block` | 846 | 1 | CoralBlock(dead=DEAD_FIRE_CORAL_BLOCK) | - | 1 | 0 | 2947 |
| 593 | `horn_coral_block` | 847 | 1 | CoralBlock(dead=DEAD_HORN_CORAL_BLOCK) | - | 1 | 0 | 2948 |
| 594 | `dead_tube_coral` | 848 | 1 | BaseCoralPlantBlock | waterlogged: bool | 2 | 0 | 2949 |
| 595 | `dead_brain_coral` | 849 | 1 | BaseCoralPlantBlock | waterlogged: bool | 2 | 0 | 2951 |
| 596 | `dead_bubble_coral` | 850 | 1 | BaseCoralPlantBlock | waterlogged: bool | 2 | 0 | 2953 |
| 597 | `dead_fire_coral` | 851 | 1 | BaseCoralPlantBlock | waterlogged: bool | 2 | 0 | 2955 |
| 598 | `dead_horn_coral` | 852 | 1 | BaseCoralPlantBlock | waterlogged: bool | 2 | 0 | 2957 |
| 599 | `tube_coral` | 853 | 1 | CoralPlantBlock(dead=DEAD_TUBE_CORAL) | waterlogged: bool | 2 | 0 | 2959 |
| 600 | `brain_coral` | 854 | 1 | CoralPlantBlock(dead=DEAD_BRAIN_CORAL) | waterlogged: bool | 2 | 0 | 2961 |
| 601 | `bubble_coral` | 855 | 1 | CoralPlantBlock(dead=DEAD_BUBBLE_CORAL) | waterlogged: bool | 2 | 0 | 2963 |
| 602 | `fire_coral` | 856 | 1 | CoralPlantBlock(dead=DEAD_FIRE_CORAL) | waterlogged: bool | 2 | 0 | 2965 |
| 603 | `horn_coral` | 857 | 1 | CoralPlantBlock(dead=DEAD_HORN_CORAL) | waterlogged: bool | 2 | 0 | 2967 |
| 604 | `dead_tube_coral_fan` | 858 | 1 | BaseCoralFanBlock | waterlogged: bool | 2 | 0 | 2969 |
| 605 | `dead_brain_coral_fan` | 859 | 1 | BaseCoralFanBlock | waterlogged: bool | 2 | 0 | 2971 |
| 606 | `dead_bubble_coral_fan` | 860 | 1 | BaseCoralFanBlock | waterlogged: bool | 2 | 0 | 2973 |
| 607 | `dead_fire_coral_fan` | 861 | 1 | BaseCoralFanBlock | waterlogged: bool | 2 | 0 | 2975 |
| 608 | `dead_horn_coral_fan` | 862 | 1 | BaseCoralFanBlock | waterlogged: bool | 2 | 0 | 2977 |
| 609 | `tube_coral_fan` | 863 | 1 | CoralFanBlock(dead=DEAD_TUBE_CORAL_FAN) | waterlogged: bool | 2 | 0 | 2979 |
| 610 | `brain_coral_fan` | 864 | 1 | CoralFanBlock(dead=DEAD_BRAIN_CORAL_FAN) | waterlogged: bool | 2 | 0 | 2981 |
| 611 | `bubble_coral_fan` | 865 | 1 | CoralFanBlock(dead=DEAD_BUBBLE_CORAL_FAN) | waterlogged: bool | 2 | 0 | 2983 |
| 612 | `fire_coral_fan` | 866 | 1 | CoralFanBlock(dead=DEAD_FIRE_CORAL_FAN) | waterlogged: bool | 2 | 0 | 2985 |
| 613 | `horn_coral_fan` | 867 | 1 | CoralFanBlock(dead=DEAD_HORN_CORAL_FAN) | waterlogged: bool | 2 | 0 | 2987 |
| 614 | `dead_tube_coral_wall_fan` | 868 | 1 | BaseCoralWallFanBlock | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 2989 |
| 615 | `dead_brain_coral_wall_fan` | 869 | 1 | BaseCoralWallFanBlock | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 2997 |
| 616 | `dead_bubble_coral_wall_fan` | 870 | 1 | BaseCoralWallFanBlock | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 3005 |
| 617 | `dead_fire_coral_wall_fan` | 871 | 1 | BaseCoralWallFanBlock | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 3013 |
| 618 | `dead_horn_coral_wall_fan` | 872 | 1 | BaseCoralWallFanBlock | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 3021 |
| 619 | `tube_coral_wall_fan` | 873 | 1 | CoralWallFanBlock(dead=DEAD_TUBE_CORAL_WALL_FAN) | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 3029 |
| 620 | `brain_coral_wall_fan` | 874 | 1 | CoralWallFanBlock(dead=DEAD_BRAIN_CORAL_WALL_FAN) | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 3037 |
| 621 | `bubble_coral_wall_fan` | 875 | 1 | CoralWallFanBlock(dead=DEAD_BUBBLE_CORAL_WALL_FAN) | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 3045 |
| 622 | `fire_coral_wall_fan` | 876 | 1 | CoralWallFanBlock(dead=DEAD_FIRE_CORAL_WALL_FAN) | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 3053 |
| 623 | `horn_coral_wall_fan` | 877 | 1 | CoralWallFanBlock(dead=DEAD_HORN_CORAL_WALL_FAN) | facing: north/south/west/east; waterlogged: bool | 8 | 0 | 3061 |
| 624 | `sea_pickle` | 878 | 1 | SeaPickleBlock | pickles: 1..4; waterlogged: bool | 8 | 0 | 3069 |
| 625 | `blue_ice` | 879 | 1 | HalfTransparentBlock | - | 1 | 0 | 3077 |
| 626 | `conduit` | 880 | 1 | ConduitBlock | waterlogged: bool | 2 | 0 | 3078 |
| 627 | `bamboo_sapling` | 881 | 1 | BambooSaplingBlock | - | 1 | 0 | 3080 |
| 628 | `bamboo` | 882 | 1 | BambooStalkBlock | age: 0..1; leaves: none/small/large; stage: 0..1 | 12 | 0 | 3081 |
| 629 | `potted_bamboo` | 883 | 1 | FlowerPotBlock(potted=BAMBOO) | - | 1 | 0 | 3093 |
(`facing` value lists: the four-value form is north, south, west, east; the six-value form of the command blocks, observer, end rod
and shulker boxes is north, east, south, west, up, down. Class arguments in parentheses are constructor arguments other than the
`Properties`. A `WoodType` or `BlockSetType` argument is named after the wood.)

### 7.2 Builder values

Columns as in 24 part 1 §7 (hardness, resistance, tool required, light, map colour, sound, push reaction, instrument, flags).
"planks:X" means the map colour of the planks block of that wood, which is `X` (section 3.1). "dye colour" means `DyeColor.getMapColor()`
of the block's colour (section 3.2). Flags not defined in 24 part 1 §7 are: `forceSolidOn`, `forceSolidOff`, `dynamicShape`,
`noTerrainParticles`, `friction:<v>`, `validSpawn:polarBearOnly`, `validSpawn:fireImmuneOnly`, `postProcess:above`, `emissive:always`,
`suffocating:always`, `suffocating:closedOrNoBlockEntity` (`NOT_CLOSED_SHULKER`), `viewBlocking:nearPlane`
(`NEAR_PLANE_INTERSECTS_OUTLINE`), `fullCopy:<source>`, `legacyCopy:<source>`, `destroyTime:<v>` (a `destroyTime` call after the copy),
`overrideLootTable:fan`. **Friction, speed factor, jump factor.** Every row of this part keeps the builder defaults friction 0.6, speed factor 1.0 and jump factor 1.0 (24 part 1 §4.1), except `frosted_ice` (friction 0.98) and `blue_ice` (friction 0.989); read from the static initialiser, no row of this part calls `speedFactor` or `jumpFactor` (the only calls in `Blocks` belong to soul sand and honey block). The occlusion flag (`noOcclusion`, `canOcclude`), `useShapeForLightOcclusion`, light dampening and skylight propagation are per class and are in section 6 and in table 8.1. The light of `sea_pickle` is the formula of 6.17. Hardness 0.0 together with resistance 0.0 for a row without a
`strength` or `instabreak` call is the builder default. A hardness of -1.0 is unbreakable.

| Field | Key | Hardness | Resistance | Tool req. | Light | Map colour | Sound | Push | Instrument | Flags |
|---:|---|---:|---:|---|---|---|---|---|---|---|
| 525 | `mangrove_fence_gate` | 2.0 | 3.0 | no | 0 | planks:COLOR_RED | WOOD | PUSH_PULL | BASS | forceSolidOn, ignitedByLava |
| 526 | `poplar_fence_gate` | 2.0 | 3.0 | no | 0 | planks:COLOR_LIGHT_GRAY | WOOD | PUSH_PULL | BASS | forceSolidOn, ignitedByLava |
| 527 | `bamboo_fence_gate` | 2.0 | 3.0 | no | 0 | planks:COLOR_YELLOW | BAMBOO_WOOD | PUSH_PULL | BASS | forceSolidOn, ignitedByLava |
| 528 | `spruce_fence` | 2.0 | 3.0 | no | 0 | planks:PODZOL | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 529 | `birch_fence` | 2.0 | 3.0 | no | 0 | planks:SAND | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 530 | `jungle_fence` | 2.0 | 3.0 | no | 0 | planks:DIRT | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 531 | `acacia_fence` | 2.0 | 3.0 | no | 0 | planks:COLOR_ORANGE | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 532 | `cherry_fence` | 2.0 | 3.0 | no | 0 | planks:TERRACOTTA_WHITE | CHERRY_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 533 | `dark_oak_fence` | 2.0 | 3.0 | no | 0 | planks:COLOR_BROWN | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 534 | `pale_oak_fence` | 2.0 | 3.0 | no | 0 | planks:QUARTZ | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 535 | `mangrove_fence` | 2.0 | 3.0 | no | 0 | planks:COLOR_RED | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 536 | `poplar_fence` | 2.0 | 3.0 | no | 0 | planks:COLOR_LIGHT_GRAY | WOOD | PUSH_PULL | BASS | ignitedByLava |
| 537 | `bamboo_fence` | 2.0 | 3.0 | no | 0 | planks:COLOR_YELLOW | BAMBOO_WOOD | PUSH_PULL | BASS | ignitedByLava |
| 538 | `spruce_door` | 3.0 | 3.0 | no | 0 | planks:PODZOL | WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 539 | `birch_door` | 3.0 | 3.0 | no | 0 | planks:SAND | WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 540 | `jungle_door` | 3.0 | 3.0 | no | 0 | planks:DIRT | WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 541 | `acacia_door` | 3.0 | 3.0 | no | 0 | planks:COLOR_ORANGE | WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 542 | `cherry_door` | 3.0 | 3.0 | no | 0 | planks:TERRACOTTA_WHITE | CHERRY_WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 543 | `dark_oak_door` | 3.0 | 3.0 | no | 0 | planks:COLOR_BROWN | WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 544 | `pale_oak_door` | 3.0 | 3.0 | no | 0 | planks:QUARTZ | WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 545 | `mangrove_door` | 3.0 | 3.0 | no | 0 | planks:COLOR_RED | WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 546 | `poplar_door` | 3.0 | 3.0 | no | 0 | planks:COLOR_LIGHT_GRAY | WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 547 | `bamboo_door` | 3.0 | 3.0 | no | 0 | planks:COLOR_YELLOW | BAMBOO_WOOD | POPPED | BASS | noOcclusion, ignitedByLava |
| 548 | `end_rod` | 0.0 | 0.0 | no | 14 | NONE | WOOD | PUSH_PULL | HARP | forceSolidOff, noOcclusion |
| 549 | `chorus_plant` | 0.4 | 0.4 | no | 0 | COLOR_PURPLE | WOOD | POPPED | HARP | forceSolidOff, noOcclusion |
| 550 | `chorus_flower` | 0.4 | 0.4 | no | 0 | COLOR_PURPLE | WOOD | POPPED | HARP | forceSolidOff, noOcclusion, randomTicks, validSpawn:never, redstoneConductor:never |
| 551 | `purpur_block` | 1.5 | 6.0 | yes | 0 | COLOR_MAGENTA | STONE | PUSH_PULL | BASEDRUM | - |
| 552 | `purpur_slab` | 2.0 | 6.0 | yes | 0 | COLOR_MAGENTA | STONE | PUSH_PULL | BASEDRUM | legacyCopy:PURPUR_BLOCK, destroyTime:2.0, viewBlocking:nearPlane |
| 553 | `purpur_pillar` | 1.5 | 6.0 | yes | 0 | COLOR_MAGENTA | STONE | PUSH_PULL | BASEDRUM | - |
| 554 | `purpur_stairs` | 1.5 | 6.0 | yes | 0 | COLOR_MAGENTA | STONE | PUSH_PULL | BASEDRUM | legacyCopy:PURPUR_BLOCK, viewBlocking:nearPlane |
| 555 | `end_stone_bricks` | 3.0 | 9.0 | yes | 0 | SAND | STONE | PUSH_PULL | BASEDRUM | - |
| 556 | `torchflower_crop` | 0.0 | 0.0 | no | 0 | PLANT | CROP | POPPED | HARP | noCollision, randomTicks |
| 557 | `pitcher_crop` | 0.0 | 0.0 | no | 0 | PLANT | CROP | POPPED | HARP | noCollision, randomTicks |
| 558 | `pitcher_plant` | 0.0 | 0.0 | no | 0 | PLANT | CROP | POPPED | HARP | noCollision, offset:XZ, ignitedByLava |
| 559 | `beetroots` | 0.0 | 0.0 | no | 0 | PLANT | CROP | POPPED | HARP | noCollision, randomTicks |
| 560 | `dirt_path` | 0.65 | 0.65 | no | 0 | DIRT | GRASS | PUSH_PULL | HARP | suffocating:always |
| 561 | `end_gateway` | -1.0 | 3600000.0 | no | 15 | COLOR_BLACK | STONE | IMMOVEABLE | HARP | noCollision, noLootTable |
| 562 | `repeating_command_block` | -1.0 | 3600000.0 | yes | 0 | COLOR_PURPLE | STONE | PUSH_PULL | HARP | noLootTable |
| 563 | `chain_command_block` | -1.0 | 3600000.0 | yes | 0 | COLOR_GREEN | STONE | PUSH_PULL | HARP | noLootTable |
| 564 | `frosted_ice` | 0.5 | 0.5 | no | 0 | ICE | GLASS | PUSH_PULL | HARP | noOcclusion, friction:0.98, validSpawn:polarBearOnly, redstoneConductor:never |
| 565 | `magma_block` | 0.5 | 0.5 | yes | 3 | NETHER | STONE | PUSH_PULL | BASEDRUM | validSpawn:fireImmuneOnly, postProcess:above, emissive:always |
| 566 | `nether_wart_block` | 1.0 | 1.0 | no | 0 | COLOR_RED | WART_BLOCK | PUSH_PULL | HARP | - |
| 567 | `red_nether_bricks` | 2.0 | 6.0 | yes | 0 | NETHER | NETHER_BRICKS | PUSH_PULL | BASEDRUM | - |
| 568 | `bone_block` | 2.0 | 2.0 | yes | 0 | SAND | BONE_BLOCK | PUSH_PULL | XYLOPHONE | - |
| 569 | `structure_void` | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | replaceable, noCollision, noLootTable, noTerrainParticles |
| 570 | `observer` | 3.0 | 3.0 | yes | 0 | STONE | STONE | PUSH_PULL | BASEDRUM | redstoneConductor:never |
| 571 | `shulker_box` | 2.0 | 2.0 | no | 0 | COLOR_PURPLE | STONE | POPPED | HARP | forceSolidOn, dynamicShape, noOcclusion, suffocating:closedOrNoBlockEntity |
| 572 | `<colour>_shulker_box` | 2.0 | 2.0 | no | 0 | dye colour (purple: TERRACOTTA_PURPLE) | STONE | POPPED | HARP | forceSolidOn, dynamicShape, noOcclusion, suffocating:closedOrNoBlockEntity |
| 573 | `<colour>_glazed_terracotta` | 1.4 | 1.4 | yes | 0 | dye colour | STONE | PUSH | BASEDRUM | - |
| 574 | `<colour>_concrete` | 1.8 | 1.8 | yes | 0 | dye colour | STONE | PUSH_PULL | BASEDRUM | - |
| 575 | `<colour>_concrete_stairs` | 1.8 | 1.8 | yes | 0 | dye colour | STONE | PUSH_PULL | BASEDRUM | fullCopy:<colour>_concrete, viewBlocking:nearPlane |
| 576 | `<colour>_concrete_slab` | 1.8 | 1.8 | yes | 0 | dye colour | STONE | PUSH_PULL | BASEDRUM | legacyCopy:<colour>_concrete, viewBlocking:nearPlane |
| 577 | `<colour>_concrete_powder` | 0.5 | 0.5 | no | 0 | dye colour | SAND | PUSH_PULL | SNARE | - |
| 578 | `kelp` | 0.0 | 0.0 | no | 0 | WATER | WET_GRASS | POPPED | HARP | noCollision, randomTicks |
| 579 | `kelp_plant` | 0.0 | 0.0 | no | 0 | WATER | WET_GRASS | POPPED | HARP | noCollision |
| 580 | `dried_kelp_block` | 0.5 | 2.5 | no | 0 | COLOR_GREEN | GRASS | PUSH_PULL | HARP | - |
| 581 | `turtle_egg` | 0.5 | 0.5 | no | 0 | SAND | METAL | POPPED | HARP | forceSolidOn, noOcclusion, randomTicks |
| 582 | `sniffer_egg` | 0.5 | 0.5 | no | 0 | COLOR_RED | METAL | PUSH_PULL | HARP | noOcclusion |
| 583 | `dried_ghast` | 0.0 | 0.0 | no | 0 | COLOR_GRAY | DRIED_GHAST | PUSH_PULL | HARP | forceSolidOn, noOcclusion, randomTicks |
| 584 | `dead_tube_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn |
| 585 | `dead_brain_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn |
| 586 | `dead_bubble_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn |
| 587 | `dead_fire_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn |
| 588 | `dead_horn_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn |
| 589 | `tube_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_BLUE | CORAL_BLOCK | PUSH_PULL | BASEDRUM | - |
| 590 | `brain_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_PINK | CORAL_BLOCK | PUSH_PULL | BASEDRUM | - |
| 591 | `bubble_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_PURPLE | CORAL_BLOCK | PUSH_PULL | BASEDRUM | - |
| 592 | `fire_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_RED | CORAL_BLOCK | PUSH_PULL | BASEDRUM | - |
| 593 | `horn_coral_block` | 1.5 | 6.0 | yes | 0 | COLOR_YELLOW | CORAL_BLOCK | PUSH_PULL | BASEDRUM | - |
| 594 | `dead_tube_coral` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 595 | `dead_brain_coral` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 596 | `dead_bubble_coral` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 597 | `dead_fire_coral` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 598 | `dead_horn_coral` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 599 | `tube_coral` | 0.0 | 0.0 | no | 0 | COLOR_BLUE | WET_GRASS | POPPED | HARP | noCollision |
| 600 | `brain_coral` | 0.0 | 0.0 | no | 0 | COLOR_PINK | WET_GRASS | POPPED | HARP | noCollision |
| 601 | `bubble_coral` | 0.0 | 0.0 | no | 0 | COLOR_PURPLE | WET_GRASS | POPPED | HARP | noCollision |
| 602 | `fire_coral` | 0.0 | 0.0 | no | 0 | COLOR_RED | WET_GRASS | POPPED | HARP | noCollision |
| 603 | `horn_coral` | 0.0 | 0.0 | no | 0 | COLOR_YELLOW | WET_GRASS | POPPED | HARP | noCollision |
| 604 | `dead_tube_coral_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 605 | `dead_brain_coral_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 606 | `dead_bubble_coral_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 607 | `dead_fire_coral_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 608 | `dead_horn_coral_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision |
| 609 | `tube_coral_fan` | 0.0 | 0.0 | no | 0 | COLOR_BLUE | WET_GRASS | POPPED | HARP | noCollision |
| 610 | `brain_coral_fan` | 0.0 | 0.0 | no | 0 | COLOR_PINK | WET_GRASS | POPPED | HARP | noCollision |
| 611 | `bubble_coral_fan` | 0.0 | 0.0 | no | 0 | COLOR_PURPLE | WET_GRASS | POPPED | HARP | noCollision |
| 612 | `fire_coral_fan` | 0.0 | 0.0 | no | 0 | COLOR_RED | WET_GRASS | POPPED | HARP | noCollision |
| 613 | `horn_coral_fan` | 0.0 | 0.0 | no | 0 | COLOR_YELLOW | WET_GRASS | POPPED | HARP | noCollision |
| 614 | `dead_tube_coral_wall_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision, overrideLootTable:fan |
| 615 | `dead_brain_coral_wall_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision, overrideLootTable:fan |
| 616 | `dead_bubble_coral_wall_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision, overrideLootTable:fan |
| 617 | `dead_fire_coral_wall_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision, overrideLootTable:fan |
| 618 | `dead_horn_coral_wall_fan` | 0.0 | 0.0 | yes | 0 | COLOR_GRAY | STONE | PUSH_PULL | BASEDRUM | forceSolidOn, noCollision, overrideLootTable:fan |
| 619 | `tube_coral_wall_fan` | 0.0 | 0.0 | no | 0 | COLOR_BLUE | WET_GRASS | POPPED | HARP | noCollision, overrideLootTable:fan |
| 620 | `brain_coral_wall_fan` | 0.0 | 0.0 | no | 0 | COLOR_PINK | WET_GRASS | POPPED | HARP | noCollision, overrideLootTable:fan |
| 621 | `bubble_coral_wall_fan` | 0.0 | 0.0 | no | 0 | COLOR_PURPLE | WET_GRASS | POPPED | HARP | noCollision, overrideLootTable:fan |
| 622 | `fire_coral_wall_fan` | 0.0 | 0.0 | no | 0 | COLOR_RED | WET_GRASS | POPPED | HARP | noCollision, overrideLootTable:fan |
| 623 | `horn_coral_wall_fan` | 0.0 | 0.0 | no | 0 | COLOR_YELLOW | WET_GRASS | POPPED | HARP | noCollision, overrideLootTable:fan |
| 624 | `sea_pickle` | 0.0 | 0.0 | no | dead: 0; else 3 + 3*pickles | COLOR_GREEN | SLIME_BLOCK | POPPED | HARP | noOcclusion |
| 625 | `blue_ice` | 2.8 | 2.8 | no | 0 | ICE | GLASS | PUSH_PULL | HARP | friction:0.989 |
| 626 | `conduit` | 3.0 | 3.0 | no | 15 | DIAMOND | STONE | PUSH_PULL | HAT | forceSolidOn, noOcclusion |
| 627 | `bamboo_sapling` | 1.0 | 1.0 | no | 0 | WOOD | BAMBOO_SAPLING | POPPED | HARP | forceSolidOn, randomTicks, noCollision, offset:XZ, ignitedByLava |
| 628 | `bamboo` | 1.0 | 1.0 | no | 0 | PLANT | BAMBOO | POPPED | HARP | forceSolidOn, randomTicks, noOcclusion, dynamicShape, offset:XZ, ignitedByLava, redstoneConductor:never |
| 629 | `potted_bamboo` | 0.0 | 0.0 | no | 0 | NONE | STONE | POPPED | HARP | noOcclusion |
### 7.3 Burnable odds, loot key, item key and light opacity per row

**Burnable (flammability odds).** Read in `FireBlock.bootStrap` (the table and the fire tick are in 17 section 3.3a; they are not repeated). For the rows of this part, (ignite, burn):

| Rows (fields) | (ignite, burn) |
|---|---|
| all 3 fence gates (525 to 527, including `mangrove`, `poplar`, `bamboo`) and all 10 fences (528 to 537) | (5, 20) |
| `torchflower_crop` (556) is not registered; the separate `torchflower` block (another part) is (60, 100) in the same table | see 17 3.3a |
| `pitcher_plant` (558) | (60, 100) |
| `dried_kelp_block` (580) | (30, 60) |
| `bamboo` (628) | (60, 60) |
| every other row of this part, including the ten doors (538 to 547, which carry `ignitedByLava` but are not registered), `end_rod`, chorus plant and flower, `bamboo_sapling`, `torchflower_crop`, `pitcher_crop`, `beetroots`, `potted_bamboo` | not flammable (odds 0) |

`ignitedByLava` (the builder flag of table 7.2) and the fire odds are independent: a row can carry the flag without being in the fire table.

**Loot table key.** Rule: the key of every row is `blocks/<block key>` (the block key of section 2) except: (a) `noLootTable` rows `end_gateway`, `repeating_command_block`, `chain_command_block`, `structure_void` have no loot table; (b) each of the ten coral wall fans uses the key of the corresponding coral fan (`overrideLootTable:fan`, 3.3); (c) the collections follow the rule with the colour-prefixed key.

**Item key.** The item key is the block key, except `torchflower_crop` (`torchflower_seeds`), `pitcher_crop` (`pitcher_pod`) and `beetroots` (`beetroot_seeds`); the 15 rows registered through `BlockIds` have no item: `end_gateway`, `frosted_ice`, `kelp_plant`, the ten coral wall fans, `bamboo_sapling`, `potted_bamboo`.

**Correct-tool tags.** Tag membership (`mineable/*`, `needs_*`) is data and is not listed (Open question 15).

**Light opacity per row.** Map from fields to a row of table 8.1:

| Fields | Row of 8.1 | Dampening |
|---|---|---|
| 525 to 527, 538 to 547, 548, 569 | fence gates, doors, end rod, structure void | 0 |
| 528 to 537 | fences | 0 (1 waterlogged) |
| 549 | chorus plant | 1 |
| 550, 561 | chorus flower, end gateway | 1 |
| 551, 553, 555, 565 to 568, 570, 562, 563, 573, 574, 577, 580, 584 to 593 | solid full blocks | 15 |
| 625 | blue ice | 15 |
| 564 | frosted ice | 1 |
| 554, 575 | stairs | 0 (1 waterlogged) |
| 552, 576 | slabs | 15 when double, else 0 (1 waterlogged) |
| 560 | dirt path | 0 |
| 556 to 559 | torchflower crop, pitcher crop, pitcher plant, beetroots | 0 |
| 571, 572 | shulker boxes | 1 |
| 578, 579 | kelp, kelp plant | 1 |
| 581, 582 | turtle egg, sniffer egg | 0 |
| 583, 626, 624, 594 to 623 | dried ghast, conduit, sea pickle, coral plants, fans, wall fans | 0 (1 waterlogged) |
| 627, 628, 629 | bamboo sapling, bamboo, potted bamboo | 0 |

## 8. Tint and placement columns (GAP-29 and GAP-30)

**Tint class (GAP-29).** None of the 105 rows is in the `BlockColors.createDefault` table of 24 part 1 §9.3, so every row has tint class
"none" (the models carry no tint source for these blocks).

**Placement columns (GAP-30).** The `replaceable` flag is set only on `structure_void` (24 part 1 §10.1). Placement state and survival, by
class:

| Rows | Replaceable | Placement state | `canSurvive` | Section |
|---|---|---|---|---|
| fence gates | no | facing = player direction; powered = open = neighbour signal; in_wall by `walls` tag | default (true) | 6.1 |
| fences | no | four connections from neighbours; waterlogged by fluid | default (true) | 6.2 |
| doors | no | needs a replaceable cell above and below max height; facing, hinge, powered, open | lower: sturdy top face below; upper: the same block below | 6.3 |
| end rod | no | facing = clicked face, flipped against an opposing rod | default | 6.4 |
| chorus plant | no | connections from neighbours | the chorus support rule (6.5) | 6.5 |
| chorus flower | no | default | below plant or end stone support, or one plant neighbour over air | 6.5 |
| purpur pillar, bone block | no | axis = clicked face axis | default | 6.6 |
| stairs, slabs | no (slab merges, see `canBeReplaced`) | 6.6 | default | 6.6 |
| torchflower crop, beetroots | no | default | light >= 8 and `supports_crops` below | 6.7 |
| pitcher crop | never replaceable (`canBeReplaced` false) | default | light and the double plant rule | 6.7 |
| pitcher plant | no | default if the cell above is replaceable | `supports_vegetation` below (lower) or the lower half (upper) | 6.7 |
| dirt path | no | default, or dirt pushed up when it cannot survive | above not solid, or a fence gate above | 6.8 |
| end gateway, command blocks, observer, shulker boxes, glazed terracotta | no | 6.9 to 6.13 | default | 6.9 to 6.13 |
| concrete powder | no | concrete if touching water, else default | default | 6.13 |
| kelp | no | kelp or plant, random age | below not in `cannot_support_kelp` and sturdy or kelp | 6.14 |
| turtle egg, sniffer egg, dried ghast | egg merge (turtle) | 6.15 | default | 6.15 |
| coral plants, fans, wall fans | no | waterlogged if full water; wall fans choose a surviving face | sturdy face below / behind | 6.16 |
| sea pickle | pickle merge | pickles + 1 or default | collision face on top or sturdy top | 6.17 |
| conduit | no | waterlogged by full water | default | 6.17 |
| bamboo sapling, bamboo | no | 6.18 | `supports_bamboo` below | 6.18 |
| potted bamboo | no | not placed by an item | default | 6.18 |

### 8.1 Light opacity and skylight propagation

Rules (24 part 1 §5.2, confirmed by reading `BlockBehaviour.getLightDampening`): `Block.getLightDampening(state)` is 15 when the state's `solidRender` is true (its occlusion shape is a full block; the occlusion shape is empty when `noOcclusion` or `noCollision` clears `canOcclude`), else 0 when `propagatesSkylightDown` is true, else 1. The default `propagatesSkylightDown` is: the shape is not a full block and the fluid state is empty. No class of this part overrides `getLightDampening` (only `LeavesBlock` and `TintedGlassBlock` do, outside this part). The overrides of `propagatesSkylightDown` that apply here are `CrossCollisionBlock` (true when not waterlogged), `PipeBlock` (false), `ShulkerBoxBlock` (false), `BambooStalkBlock` (true) and `VegetationBlock` (the fluid state is empty). `FrostedIceBlock` and `IceBlock` read the state's dampening in their melt tests (6.11 uses `11 - age - dampening`; `IceBlock.randomTick` compares block light with `11 - dampening`).

| Rows | `solidRender` | `propagatesSkylightDown` | Dampening |
|---|---|---|---:|
| fence gates, doors, end rod, structure void | false | true (default; fluid empty) | 0 |
| fences | false | true when not waterlogged | 0 (1 when waterlogged) |
| chorus plant | false | false (`PipeBlock`) | 1 |
| chorus flower, end gateway | false (`noOcclusion` / `noCollision`) | false (full-cube shape) | 1 |
| purpur block, pillar, end stone bricks, nether wart block, red nether bricks, bone block, magma block, observer, command blocks, glazed terracotta (16), concrete (16), concrete powder (16), dried kelp block, the ten coral blocks | true | false | 15 |
| blue ice | true (full occlusion, `canOcclude` stays true) | false | 15 |
| frosted ice (all ages) | false (`noOcclusion`) | false (full-cube shape) | 1 |
| stairs (purpur, concrete) | false | true when not waterlogged | 0 (1 when waterlogged) |
| slabs (purpur, concrete) | true when `double`, else false | false when `double`; else true when not waterlogged | 15 when `double`; else 0 (1 when waterlogged) |
| dirt path | false (15-pixel shape) | true | 0 |
| torchflower crop, pitcher crop, pitcher plant, beetroots | false (`noCollision`) | true (`VegetationBlock`, fluid empty) | 0 |
| shulker boxes (17) | false (`noOcclusion`) | false (`ShulkerBoxBlock`) | 1 |
| kelp, kelp plant | false | false (`getFluidState` is always the water source) | 1 |
| turtle egg, sniffer egg | false | true (fluid empty, shape not full) | 0 |
| dried ghast, conduit, sea pickle | false | true when not waterlogged (sea pickle through `VegetationBlock`) | 0 (1 when waterlogged) |
| coral plants, fans, wall fans (live and dead) | false | true when not waterlogged | 0 (1 when waterlogged) |
| bamboo sapling | false | true (default) | 0 |
| bamboo | false | true (`BambooStalkBlock`) | 0 |
| potted bamboo | false | true | 0 |

Rows not in a table row above do not exist in this part. The values for the rows with a waterlogged state follow the shape and fluid rules of this section and were not each read as a separate call (each is the rule applied to the shape of its family in section 6).

## 9. Worked examples

1. **Ids.** `mangrove_fence_gate` is block 689, `poplar_fence_gate` 690, `bamboo_fence_gate` 691; `spruce_fence` 692, `bamboo_fence` 701, `spruce_door` 702, `bamboo_door`
   711, `end_rod` 712, `shulker_box` 735, `white_shulker_box` 736, `black_shulker_box` 751, `white_concrete` 768, `red_concrete_stairs` 784 + 14 = 798, `kelp` 832,
   `potted_bamboo` 883. Check of the last: 689 + 195 - 1 = 883.
2. **State index, fence gate.** `mangrove_fence_gate` with facing east (index 3), `in_wall` true (index 0), `open` true (0), `powered` false (1):
   `3 * 8 + 0 * 4 + 0 * 2 + 1 = 25`. Its state offset is `0 + 25 = 25`. The default (north, all false) is `0 * 8 + 1 * 4 + 1 * 2 + 1 = 7`.
3. **State index, door.** `bamboo_door` (offset 992): facing east (3), half upper (0), hinge right (1), open true (0), powered false (1):
   `3 * 16 + 0 * 8 + 1 * 4 + 0 * 2 + 1 = 53`; offset `992 + 53 = 1045`. Default: `0 * 16 + 1 * 8 + 0 * 4 + 1 * 2 + 1 = 11` (north, lower, left, closed,
   unpowered).
4. **Concrete stairs.** The 16 blocks of the field have 80 states each, starting at offset 1472: `red_concrete_stairs` (colour index 14) starts at
   `1472 + 14 * 80 = 2592`; its default state (north, bottom, straight, not waterlogged, index 11) is offset 2603.
5. **Door hinge.** A player facing north (`d = north`) places a door with a full-collision block at `pos.relative(d.ccw) = pos.west` (one cell high on the lower
   cell only) and nothing east: `s = -1`; there is no neighbouring door, so rule 2 applies (`s < 0`): hinge `left`. With nothing around (`s = 0`, no
   doors) rule 3 uses the click: facing north (`k = 0`, `l = -1`), a click at `dx = 0.7` gives `l < 0 && dx > 0.5`: hinge `right`; `dx = 0.3` gives `left`.
6. **Stair shape.** A new stair facing east at `pos`; an existing bottom stair facing north at `pos.east`; nothing at `pos.south`. Step 1: `A.facing = north` has axis `Z`, not `X`;
   `canTakeShape(state, level, pos, north.opposite = south)` looks at `pos.south`: not a stair, so true; `A.facing == east.ccw = north`: the shape is `outer_left`. The
   shape key is `facing = east` (for `outer_left`), so the raised part is the base `OUTER` quarter turned once clockwise: the north-east quarter. Checks: `east.ccw` is north (the
   left of a viewer facing east), the corner is on the north side, consistent with the name.
7. **Fence connection.** A `spruce_fence` placed with an `oak_fence` to the west: both are in tag `wooden_fences`, `isSameFence` true: `west = true` without any
   sturdiness test. With a `nether_brick_fence` to the east (tag `fences` but not `wooden_fences`): `isSameFence` is false and a fence's side face
   is not sturdy (inferred: its support shape, the default, is the collision shape, which is not a full face), so `east = false`. With a `stone` block to the north: `isExceptionForConnection` is false and the stone's south
   face is sturdy: `north = true`.
8. **Fence collision height.** A fence's collision box is 24 pixels (1.5 blocks) tall (post box(6,0,6, 10,24,10)), while its selection box is 16 pixels tall:
   that an entity at ground level cannot step onto the fence top by normal jumping is an inference from the box height and the step and jump rules of 13 (not read here).
9. **Sea pickle light.** Waterlogged pickles 1, 2, 3, 4 emit 6, 9, 12, 15; the same blocks with `waterlogged = false` emit 0. A sea pickle placed on a sea pickle with `pickles = 3`
   by a player who is not sneaking becomes `pickles = 4` (`canBeReplaced` is true while `pickles < 4`).
10. **Pitcher crop shape.** Age 0 lower: `a = 4 + 0 = 4`, `w = 6`: selection box(5,-1,5, 11,3,11) (`column(6, -1, min(16, 3))`); collision `column(6,-1,3)`. Age 4 lower: `a = 6 + 26 = 32`,
   `w = 10`: selection `column(10, -1, 16)` = box(3,-1,3, 13,16,13); upper: `column(10, 0, max(0, 32 - 1 - 16)) = column(10,0,15)` = box(3,0,3, 13,15,13); collision for the lower half only: `column(10,-1,5)`.
11. **Concrete powder.** A powder block placed with water in the cell above it: `touchesLiquid`: `d = down`: the state at the cell itself (air or the replaced block) is not water, skip; `d = up`:
    `m = pos.up` holds water, `canSolidify` true and water's down face is not sturdy: result true, so the placed state is the concrete block of the powder's colour.
12. **Chorus flower survival.** A flower at `pos` with air below, a chorus plant to the north and air to the east, south and west: the loop counts one plant, all others
    air: survives. With plants to the north and east: the second plant gives false. With a stone block to the east: a non-air non-plant neighbour gives false.
13. **Bamboo growth heights.** A stalk with 10 bamboo blocks below it (`h = 11`): the new top has `stage` 1 with probability 0.25; at `h = 15` the new top always has `stage 1`.
    Starting from a sapling with `leaves = small` stalk on top (`h = 1`, no bamboo below): the next stalk has `leaves = small`.
14. **Magma.** A walking (not sneaking) player on `magma_block`: `hurt(hotFloor, 1.0)` each step event; a sneaking player takes none.

## 10. Validation

1. **Counts.** 105 fields (525 to 629); the six collection fields contribute 96 blocks, the other 99 fields contribute 99 blocks: 96 + 99 = 195
   registered blocks. States: 3094 (table in item 5).
2. **Id range.** First id 689, last id 883, so 195 consecutive ids. The next field, `VOID_AIR` (630), has id 884 by the same count, and `CAVE_AIR` 885.
3. **Check of the first id.** `525 + 15 * 10 + 7 * 2 = 689` with 10 earlier 16-block fields (`BED`, `WOOL`, `WOOL_STAIRS`, `WOOL_SLAB`, `STAINED_GLASS`,
   `DYED_TERRACOTTA`, `STAINED_GLASS_PANE`, `CARPET`, `BANNER`, `WALL_BANNER`) and 2 earlier 8-block weathering fields (`COPPER_BARS`, `COPPER_CHAIN`). The sum over all 911 fields is
   1286 blocks. Parts 3 to 5 must end their last row at block id 688 (field 524, `PALE_OAK_FENCE_GATE`).
4. **Declaration order equals registration order** for the 105 fields (the `putstatic` order of `Blocks.<clinit>` was compared field by field).
5. **State counts by family** (fields, blocks, states):

| Family | Fields | Blocks | States |
|---|---:|---:|---:|
| fence gates | 3 | 3 | 96 |
| fences | 10 | 10 | 320 |
| doors | 10 | 10 | 640 |
| end rod, chorus plant, chorus flower | 3 | 3 | 76 |
| purpur block, slab, pillar, stairs, end stone bricks | 5 | 5 | 91 |
| torchflower crop, pitcher crop, pitcher plant, beetroots | 4 | 4 | 18 |
| dirt path, end gateway, command blocks | 4 | 4 | 26 |
| frosted ice, magma, nether wart block, red nether bricks, bone block, structure void, observer | 7 | 7 | 23 |
| shulker boxes (plain and 16 dyed) | 2 | 17 | 102 |
| glazed terracotta | 1 | 16 | 64 |
| concrete | 1 | 16 | 16 |
| concrete stairs | 1 | 16 | 1280 |
| concrete slabs | 1 | 16 | 96 |
| concrete powder | 1 | 16 | 16 |
| kelp, kelp plant, dried kelp block | 3 | 3 | 28 |
| turtle egg, sniffer egg, dried ghast | 3 | 3 | 47 |
| coral blocks (dead and live) | 10 | 10 | 10 |
| coral plants (dead and live) | 10 | 10 | 20 |
| coral fans (dead and live) | 10 | 10 | 20 |
| coral wall fans (dead and live) | 10 | 10 | 80 |
| sea pickle, blue ice, conduit | 3 | 3 | 11 |
| bamboo sapling, bamboo, potted bamboo | 3 | 3 | 14 |
| **Total** | **105** | **195** | **3094** |

6. **Offsets.** The offset of `end_rod` (1056) equals the states of fence gates, fences and doors (96 + 320 + 640); the offset of `potted_bamboo`
   (3093) plus its one state equals 3094.
7. **Default index formula** (section 5): for each row the default index equals the sum over the sorted properties of `value index * radix`. Spot checks: fence
   gate 7; fence 31; door 11; chorus plant 63; stairs 11 (`((0 * 2 + 1) * 5 + 0) * 2 + 1`); slab 3; command block 6; observer 5; shulker box 4; dried ghast 1.
8. **Cross-checks with the other documents.** (a) The registry key of every row was read from `BlockItemIds` or `BlockIds`; the three item-key exceptions are in section 2.
   (b) 46 §14 lists sound events; the `SoundType` constants used here (`WOOD`, `CHERRY_WOOD`, `BAMBOO_WOOD`, `GRASS`, `SAND`, `WET_GRASS`, `CROP`, `GLASS`, `SLIME_BLOCK`,
   `WART_BLOCK`, `NETHER_BRICKS`, `BONE_BLOCK`, `CORAL_BLOCK`, `METAL`, `BAMBOO`, `BAMBOO_SAPLING`, `DRIED_GHAST`, `STONE`) are constants of the table in 24 part 1 §8.4
   (`METAL` has pitch 1.5, `DRIED_GHAST` has empty place and hit sounds). (c) The map colours used are in the `MapColor` table of 24 part 1 §8.1; `TERRACOTTA_PURPLE` is id 46.
   (d) Closed: field numbering. The declaration order gives `BED` 119 (with `STRAW_BED` 120), `MANGROVE_FENCE_GATE` 525, `VOID_AIR` 630, `CAVE_AIR` 631 and `CUT_COPPER` 836, and 24 part 1 states the same values (its section 3 table row for `BED` and the text "Field 119 is `BED`"; `VOID_AIR` 630, `CAVE_AIR` 631). No correction is owed in part 1 and it must not be changed. The id statements of 24 part 1 (ids coincide with field indices for fields 0 to 118) are consistent with `BED` at field 119.
9. **Shape invariants.** Every row with `noCollision` has an empty collision shape (coral plants, fans, wall fans, kelp, crops, end gateway, structure void, bamboo sapling); every
   box listed has its minimum below its maximum on all axes (`Shapes.box` fails otherwise); all box coordinates are within 0 to 16 pixels except the pitcher crop's lower half which starts at y = -1
   and the gate and fence collision boxes which reach 24 pixels (these cross the cell and make `largeCollisionShape` true, 24 part 1 §5.2).
10. **Class coverage.** Each class named in section 6 was read for state definition, shapes and placement, and the classes' superclass chains were followed
    (`CrossCollisionBlock`, `PipeBlock`, `GrowingPlantBlock`, `GrowingPlantHeadBlock`, `GrowingPlantBodyBlock`, `VegetationBlock`, `CropBlock`, `DoublePlantBlock`, `IceBlock`, `HalfTransparentBlock`,
    `BaseCoralPlantTypeBlock`, `BaseEntityBlock`, `HorizontalDirectionalBlock`, `DirectionalBlock`, `RotatedPillarBlock`).

## 11. Open questions

1. **Absolute first state id.** Closed by cross-reference, not by a new read: `S6`, the first state id of block id 689, is **15555** (24 part 5: `pale_oak_fence_gate` has first state 15523 and 32 states, so `mangrove_fence_gate` follows at 15555). Consistency check against this document: 24 part 7 gives `VOID_AIR` (block id 884) the first state id 18649, and 15555 + 3094 = 18649. The first state id of a block of this part is `S6 + offset` (table 7.1).
2. **Field numbering in 24 part 1.** Closed. The field order read in the artifact is `BED` 119, `STRAW_BED` 120, `PALE_OAK_FENCE_GATE` 524, `MANGROVE_FENCE_GATE` 525, `POTTED_BAMBOO` 629, `VOID_AIR` 630, `CAVE_AIR` 631, `CUT_COPPER` 836, `CHISELED_COPPER` 837; 911 fields and 1286 blocks agree, and 24 part 1 now states the same numbers.
3. **Direction of the 90-degree rotation.** `OctahedralGroup.BLOCK_ROT_Y_90` and `Shapes.rotateHorizontal` were read as calls and as the entry order, not as matrices. The statement that the `EAST` entry
   is the `NORTH` shape turned clockwise (seen from above) is inferred from the names of the stair shapes (6.6) and the use in pipes; the artifact's `BLOCK_ROT_Y_90` is assigned the `ROT_90_Y_NEG` constant (read), which supports but does not prove that reading; a fence or door shape is symmetric or follows from its
   direction names, but an asymmetric shape (stairs) depends on the sense. A reference client check or reading of `OctahedralGroup` is needed.
4. **Path computation mapping.** Closed: the numbering of `FenceGateBlock$1`, `DoorBlock$1` and `SlabBlock$1` was read by enum constant (6.1, 6.3, 6.6).
5. **Outline of the pitcher plant.** Closed: no `getShape` or `getCollisionShape` override exists in `DoublePlantBlock` or `VegetationBlock`, so the outline is the default full cube moved by the XZ offset (read, 6.7). It has not been compared with a rendered outline.
6. **Chorus flower world generation.** Closed here by reference: `ChorusFlowerBlock.generatePlant` and `growTreeRecursive` (used by the End island features) are specified in 35 part 7, not in this document.
7. **Waterlogging mechanics.** Blocks with a `waterlogged` property return the water source as their fluid state; which of them implement the liquid placement interface
   (`SimpleWaterloggedBlock`), the water tick delay (`Fluids.WATER.getTickDelay`) and the removal of water on break belong to 29a. Only the slab was read to use the interface.
8. **Block entities.** The behaviour of `CommandBlockEntity` (modes, the exact chain algorithm), `ShulkerBoxBlockEntity` (animation progress, container, `getBoundingBox`),
   `TheEndGatewayBlockEntity` and `ConduitBlockEntity` belongs to 31 (parts 1, 5, 6 and 8). This document gives only the block-side rules.
9. **Sniffer egg staging.** `SnifferEggBlock.tick` contains no scheduling call; the next stage must therefore be scheduled by `onPlace` when the changed state is placed
   (inferred; whether `Level.setBlock` of a changed state of the same block calls `onPlace`, which 29 specifies).
10. **Update flags and context methods.** The flag bits of `Level.setBlock` (2, 3, 10, 18, 35 appear here), `BlockPlaceContext.getNearestLookingDirection(s)`, `getHorizontalDirection`,
    `isSecondaryUseActive`, `replacingClickedOnBlock` and `getClickLocation` are specified in 29 and are only used here.
11. **Items.** The items `torchflower_seeds`, `pitcher_pod`, `beetroot_seeds` and the items of the other rows are listed by key only; their behaviour (planting) belongs to the item registry
    (RS5). Game rules (`mobGriefing`, `maxCommandSequenceLength`, `sendCommandFeedback`), environment attributes (`water_evaporates`, `turtle_egg_hatch_chance`) and block tags
    are named; their values and contents are data or other documents (33 §3.4 for the attributes).
12. **Block tag membership.** The tags read by name (`supports_crops`, `supports_vegetation`, `supports_bamboo`, `supports_chorus_plant`, `supports_chorus_flower`, `sniffer_egg_hatch_boost`,
    `cannot_support_kelp`, `coral_blocks`, `triggers_ambient_dried_ghast_block_sounds` (dried ghast), `ice_melts_when_destroyed_above` (frosted ice), `unstable_bottom_center` (read by `FallingBlock`, so concrete powder), `guarded_by_piglins` and `fire` (read in `Block`, outside this part), the enchantment tag `prevents_ice_melting` (frosted ice), `walls`, `fences`, `wooden_fences`, `shulker_boxes`, `grows_crops`, `sand`, `water` (fluid tag)) are data; no membership list is given.
13. **`NEAR_PLANE_INTERSECTS_OUTLINE` argument.** The meaning of the box argument (camera near plane) is inferred from the name; no server rule reads it.
14. **Dried ghast particles.** Closed: both branches of `DriedGhastBlock.animateTick` were read in full (6.15).
15. **Tool columns and tag membership.** The flammability odds are given in 7.3 (read in `FireBlock.bootStrap`, cited to 17 section 3.3a). The correct-tool tag per row (`mineable/*`, `needs_*`, `incorrect_for_*`) and the tag membership of `triggers_ambient_dried_ghast_block_sounds` and the other tags read by name are data: an extraction-tool item, not read here (searched: the `Blocks` initialiser and the block classes, which carry only `requiresCorrectToolForDrops`). The per-state tables of fence arms, stair corners and door rotations are given by construction rule (6.2, 6.3, 6.6), not enumerated; an implementer derives them.
